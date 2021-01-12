; +----------------------------------------------------------+ ;
; | Sample ASKASCII program for use with the Magic Assembler | ;
; +----------------------------------------------------------+ ;
        
        mov     ah,09
        mov     dx,offset(headtxt)
        int     21
        mov     dx,offset(crlf)
        int     21
@5      mov     ah,09
        mov     dx,offset(quest)
        int     21
        mov     ah,00
        int     16
        push    ax
        mov     ah,0e
        mov     bh,00
        int     10
        mov     ah,09
        mov     dx,offset(a1)
        int     21
        pop     ax
        push    ax
        mov     al,ah
        call    wrtnum
        mov     ah,09
        mov     dx,offset(a2)
        int     21
        pop     ax
        push    ax
        call    wrtnum
        mov     ah,09
        mov     dx,offset(crlf)
        int     21
        mov     ah,0a
        mov     al,'Ä'
        mov     bh,00
        mov     cx,50
        int     10
        mov     ah,09
        mov     cx,offset(crlf)
        int     21
        pop     ax
        cmp     ax,011b
        jne     @5
        int     20

wrtnum  mov     ah,00
        mov     bl,64
        div     bl
        cmp     al,00
        je      @1
        push    ax
        mov     ah,0e
        add     al,30
        mov     bh,00
        int     10
        pop     ax
        mov     cl,01
        jmps    @2
@1      mov     cl,00
@2      mov     al,ah
        mov     ah,00
        mov     bl,0a
        div     bl
        cmp     cl,00
        jne     @3
        cmp     al,00
        je      @4
@3      push    ax
        mov     ah,0e
        add     al,30
        mov     bh,00
        int     10
        pop     ax
@4      mov     al,ah
        add     al,30
        mov     ah,0e
        mov     bh,00
        int     10
        ret

a1      db      0a 0d 'Scan code: $'
a2      db      '; ASCII code: $'
crlf    db      0a 0d '$'
headtxt db      'Ask ASCII - Written by Bert Greevenbosch for Magic Software' 0a 0d 
        db      'Public Domain Version' 0a 0d '$'
quest   db      'Enter character to give ASCII code for (ESC quits): $'

