; +----------------------------------------------------+ ;
; | Sample DVM Shower for use with the Magic Assembler | ;
; +----------------------------------------------------+ ;
        mov     ah,09
        mov     dx,offset(headtxt)
        int     21
        cmp     byte [0081],0d
        jne     @1
        mov     dx,offset(syntax)
        jmp     error
@1      mov     si,0082
        mov     showit,00
@4      lodsb
        cmp     al,'/'
        jne     @5
        mov     byte [si-01],00
        lodsb
        cmp     al,'i'
        jne     @6
        mov     showit,ff
        jmps    @5
@6      cmp     al,'I'
        jne     @5
        mov     showit,ff
@5      cmp     al,0d
        jne     @4
        mov     byte [si-01],00
        mov     ax,3d00
        mov     dx,0082
        int     21
        jnc     @7
        mov     dx,offset(openerr)
        jmp     error
@7      mov     handle,ax
        mov     bx,ax
        mov     ah,3f
        mov     cx,0003
        mov     dx,offset(header)
        int     21
        mov     si,offset(header)
        mov     di,offset(musthd)
        mov     cx,0003
@8      cmpsb
        jne     @9
        loop    @8
        jmps    @10
@9      mov     dx,offset(notdvm)
        jmp     error
@10     mov     ah,3f
        mov     cx,0001
        mov     dx,offset(fullqrt)
        int     21
        cmp     fullqrt,'V'
        je      @11
        cmp     fullqrt,'Q'
        je      @12
        mov     infobyt,a0
        jmps    @13
@12     mov     infobyt,20
        jmps    @13
@11     mov     ah,3f
        mov     dx,offset(version)
        int     21
        cmp     version,31
        jna     @14
        mov     dx,offset(verr)
        jmp     error
@14     mov     ah,3f
        mov     dx,offset(infobyt)
        int     21
@13     mov     ah,3f
        mov     cx,0002
        mov     dx,offset(dtime)
        int     21
        test    infobyt,08
        jz      @15
        mov     ah,3f
        mov     dx,offset(l)
        int     21
        mov     cx,l
@16     push    cx
        mov     ah,3f
        mov     cx,0001
        mov     dx,offset(ch)
        int     21
        push    bx
        mov     ah,0e
        mov     al,ch
        xor     bh,bh
        cmp     showit,ff
        je      @17
        int     10
@17     pop     bx
        pop     cx
        loop    @16
        xor     ah,ah
        cmp     showit,ff
        jne     @15
        int     16
@15     mov     ax,0013
        int     10
        push    bx
        mov     ax,1012
        mov     bx,0000
        mov     cx,0100
        mov     dx,offset(palette)
        int     10
        pop     bx
        mov     ax,a000
        mov     es,ax
@28     test    infobyt,20
        jz      @32
        mov     ah,3f
        mov     dx,offset(palette)
        test    infobyt,10
        jnz     @33
        mov     cx,0030
        jmps    @34
@33     mov     cx,0300
@34     int     21
        cmp     ax,cx
        jne     @27
        push    bx
        push    es
        mov     ax,ds
        mov     es,ax
        mov     ax,1012
        xor     bx,bx
        test    infobyt,10
        jnz     @35
        mov     cx,0010
        jmps    @36
@35     mov     cx,0100
@36     int     10
        pop     es
        pop     bx
@32     xor     di,di
        test    infobyt,80
        jz      @18
        mov     cx,00c8
        jmps    @19
@18     mov     cx,0064
@19     push    cx
        test    infobyt,40
        jz      @20
        call    showcpr
        jmps    @21
@20     call    showucp
@21     cmp     ah,00
        ja      @27
        test    infobyt,80
        jnz     @22
        add     di,00a0
@22     pop     cx
        loop    @19
        jmps    @28
@27     mov     ah,3e
        mov     bx,handle
        int     21
        xor     ah,ah
        int     16
        mov     ax,0003
        int     10
        mov     ax,4c00
        int     21

showcpr test    infobyt,80
        jz      @23
        mov     cx,00a0
        jmps    @24
@23     mov     cx,0050
@24     mov     ah,3f
        mov     dx,offset(line)
        int     21
        cmp     ax,cx
        je      @26
        mov     ah,ff
        ret
@26     mov     si,offset(line)
@25     push    cx
        lodsb
        push    ax
        and     al,f0
        mov     cl,04
        shr     al,cl
        es:
        mov     [di],al
        pop     ax
        and     al,0f
        es:
        mov     [di+01],al
        add     di,0002
        pop     cx
        loop    @25
        xor     ah,ah
        ret

showucp test    infobyt,80
        jz      @31
        mov     cx,0140
        jmps    @29
@31     mov     cx,00a0
@29     mov     ah,3f
        mov     dx,offset(line)
        int     21
        mov     si,offset(line)
        cmp     cx,ax
        je      @30
        mov     ah,ff
        ret
@30     movsb
        loop    @30
        xor     ah,ah
        ret

error   mov     ah,09
        int     21
        mov     ax,4c00
        int     21

headtxt db      'Show DVM - Written by Bert for Magic Software - Development Kit Version' 0a 0d '$'
musthd  db      'DVM'
notdvm  db      'Not a DVM' 0a 0d '$'
openerr db      'Cannot open file' 0a 0d '$'
palette dbe     DVMPAL.BIN
syntax  db      'Syntax: SDA [Filename.DVM][/I]' 0a 0d '/I shows included text (if exist)' 0a 0d '$'
verr    db      'Cannot display this version' 0a 0d '$'
-
ch      db      ?
dtime   dw      ?
fullqrt db      ?
handle  dw      ?
header  ds      3
infobyt db      ?
l       dw      ?
line    ds      140
showit  db      ?
version db      ?
