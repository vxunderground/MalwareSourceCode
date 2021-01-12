; +---------------------------------------------------+ ;
; | Sample program DIARY for use with Magic Assembler | ;
; +---------------------------------------------------+ ;
        mov     ah,09
        mov     dx,offset(headtxt)
        int     21
        cmp     byte [0081],0d
        jne     @1
        mov     dx,offset(syntax)
        jmp     error
@1      cmp     byte [0082],'A'
        je      @2
        cmp     byte [0082],'a'
        je      @2
        cmp     byte [0082],'!'
        jne     @10
        jmp     @f
@10     cmp     byte [0082],'D'
        je      @1a
        cmp     byte [0082],'d'
        je      @1a
        jmps    @1b
@1a     jmp     @1d
@1b     cmp     byte [0082],'O'
        je      @1e
        cmp     byte [0082],'o'
        je      @1e
        jmps    @29
@1e     jmp     @1f
@29     cmp     byte [0082],'S'
        je      @2c
        cmp     byte [0082],'s'
        je      @2c
        jmps    @2d
@2c     jmp     @2e
@2d     mov     dx,offset(unpar)
        jmp     error
; Add item
@2      mov     ah,3c
        mov     cx,0020
        mov     dx,offset(tempnam)
        int     21
        mov     thandle,ax
        mov     ax,3d00
        mov     dx,offset(datanam)
        int     21
        jc      @3
;Copy the data
        mov     bx,ax
@5      mov     ah,3f
        mov     cx,0003
        mov     dx,offset(date)
        int     21
        cmp     ax,cx
        jne     @4
        mov     ah,3f
        mov     cx,0001
        mov     dx,offset(tsize)
        int     21
        mov     ah,3f
        mov     ch,0
        mov     cl,tsize
        mov     dx,offset(txt)
        int     21
        push    bx
        mov     ah,40
        mov     bx,thandle
        mov     ch,00
        mov     cl,tsize
        add     cx,0004
        mov     dx,offset(date)
        int     21
        pop     bx
        jmps    @5
;Close and delete DIARY.DAT
@4      mov     ah,3e
        int     21
        mov     ah,41
        mov     dx,offset(datanam)
        int     21
;Ask for data
@3      mov     ah,09
        mov     dx,offset(askdate)
        int     21
@9      call    readdat
        mov     ah,09
        mov     dx,offset(message)
        int     21
        mov     tsize,00
        mov     di,offset(txt)
@e      mov     ah,00
        int     16
        cmp     al,0d
        je      @c
        cmp     al,08
        jne     @d
        cmp     tsize,00
        je      @e
        mov     ah,09
        mov     dx,offset(bs)
        int     21
        dec     di
        dec     tsize
        jmps    @e
@d      inc     tsize
        stosb
        mov     ah,0e
        mov     bx,0007
        int     10
        jmps    @e

;End of lineread
@c      mov     ah,40
        mov     bx,thandle
        mov     ch,00
        mov     cl,tsize
        add     cx,0004
        mov     dx,offset(date)
        int     21
        mov     ah,3e
        int     21
        mov     ah,56
        mov     dx,offset(tempnam)
        mov     di,offset(datanam)
        int     21
        int     20
;Look for warning
@f      mov     ah,2a
        int     21
        sub     cx,076c
        mov     byte [offset(cdate)],dl
        mov     byte [offset(cdate)+1],dh
        mov     byte [offset(cdate)+2],cl
@1c     mov     ax,3d00
        mov     dx,offset(datanam)
        int     21
        jnc     @11
        mov     dx,offset(datanf)
        jmp     error
@11     push    ax
        mov     ah,3c
        mov     cx,0020
        mov     dx,offset(tempnam)
        int     21
        mov     thandle,ax
        pop     ax
        mov     bx,ax
@19     mov     ah,3f
        mov     cx,0003
        mov     dx,offset(date)
        int     21
        cmp     ax,cx
        jne     @12
        mov     ah,3f
        mov     cx,0001
        mov     dx,offset(tsize)
        int     21
        mov     ah,3f
        mov     ch,00
        mov     cl,tsize
        mov     dx,offset(txt)
        int     21
        mov     si,offset(cdate)
        mov     di,offset(date)
        mov     cx,0003
@13     cmpsb   
        jne     @14
        loop    @13
        call    delit
        cmp     al,01
        jne     @14
        jmps    @19
@14     push    bx
        mov     ah,40
        mov     bx,thandle
        mov     ch,00
        mov     cl,tsize
        add     cx,0004
        mov     dx,offset(date)
        int     21
        pop     bx
        jmps    @19
;End of file
@12     mov     ah,3e
        int     21
        mov     ah,41
        mov     dx,offset(datanam)
        int     21
        mov     ah,3e
        mov     bx,thandle
        int     21
        mov     ah,56
        mov     dx,offset(tempnam)
        mov     di,offset(datanam)
        int     21
        int     20
;Delete item
@1d     mov     ah,09
        mov     dx,offset(wdel)
        int     21
        call    readdat
        mov     si,offset(date)
        mov     di,offset(cdate)
        mov     cx,0003
@3c     movsb
        loop    @3c
        jmp     @1c
;Delete old dates
@1f     mov     ah,2a
        int     21
        mov     bx,offset(cdate)
        mov     [offset(cdate)],dl
        mov     [offset(cdate)+1],dh
        sub     cx,076c
        mov     [offset(cdate)+2],cl
        mov     ax,3d00
        mov     dx,offset(datanam)
        int     21
        jnc     @21
        mov     dx,offset(datanf)
        jmp     error
@21     push    ax
        mov     ah,3c
        mov     cx,0020
        mov     dx,offset(tempnam)
        int     21
        mov     thandle,ax
        pop     bx
@25     mov     ah,3f
        mov     cx,0003
        mov     dx,offset(date)
        int     21
        cmp     ax,cx
        jne     @22
        mov     ah,3f
        mov     cx,0001
        mov     dx,offset(tsize)
        int     21
        mov     ah,3f
        mov     ch,00
        mov     cl,tsize
        mov     dx,offset(txt)
        int     21
        mov     si,offset(date)+2
        mov     di,offset(cdate)+2
        mov     cx,0003
@23     std
        cmpsb
        cld
        ja      @20
        jb      @24
        loop    @23
@24     call    delit
        cmp     al,01
        je      @25
;Still future
@20     push    bx
        mov     ah,40
        mov     bx,thandle
        mov     ch,00
        mov     cl,tsize
        add     cx,0004
        mov     dx,offset(date)
        int     21
        pop     bx
        jmps    @25
;End of file
@22     mov     ah,3e
        int     21
        mov     ah,3e
        mov     bx,thandle
        int     21
        mov     ah,41
        mov     dx,offset(datanam)
        int     21
        mov     ah,56
        mov     dx,offset(tempnam)
        mov     di,offset(datanam)
        int     21
        int     20
;Show dates
@2e     mov     ax,3d00
        mov     dx,offset(datanam)
        int     21
        jnc     @2f
        mov     dx,offset(datanf)
        jmp     error
@2f     mov     bx,ax
@3b     mov     ah,3f
        mov     cx,0003
        mov     dx,offset(date)
        int     21
        cmp     ax,cx
        jne     @30
        mov     ah,3f
        mov     cx,0001
        mov     dx,offset(tsize)
        int     21
        mov     cl,tsize
        mov     ch,00
        mov     ah,3f
        mov     dx,offset(txt)
        int     21
        mov     si,ax
        mov     byte [offset(txt)+si],'$'
        mov     al,date
        call    shownum
        push    bx
        mov     ah,09
        mov     dx,offset(slash)
        int     21
        mov     al,[offset(date)+01]
        call    shownum
        mov     ah,09
        mov     dx,offset(slash)
        int     21
        mov     al,[offset(date)+02]
        call    shownum
        mov     ah,09
        mov     dx,offset(space)
        int     21
        mov     ah,09
        mov     dx,offset(txt)
        int     21
        mov     ah,09
        mov     dx,offset(crlf)
        int     21
        pop     bx
        jmps    @3b
@30     mov     ah,3e
        int     21
        int     20

delit   push    bx
        mov     al,date
        call    shownum
        mov     ah,09
        mov     dx,offset(slash)
        int     21
        mov     al,[offset(date)+01]
        call    shownum
        mov     ah,09
        mov     dx,offset(slash)
        int     21
        mov     al,[offset(date)+02]
        call    shownum
        mov     ah,09
        mov     dx,offset(space)
        int     21
        mov     bh,00
        mov     bl,tsize
        mov     byte [offset(txt)+bx],'$'
        pop     bx
        mov     ah,09
        mov     dx,offset(txt)
        int     21
        mov     ah,09
        mov     dx,offset(delete)
        int     21
        call    flag
        push    ax
        mov     ah,09
        mov     dx,offset(crlf)
        int     21
        pop     ax
        ret

error   mov     ah,09
        int     21
        int     20

flag    push    bx
@16     mov     ah,00
        int     16
        mov     ah,0e
        mov     bx,0007
        int     10
        cmp     al,'Y'
        je      @15
        cmp     al,'y'
        je      @15
        cmp     al,'N'
        je      @17
        cmp     al,'n'
        je      @17
        mov     ah,09
        mov     dx,offset(bs)
        int     21
        jmps    @16
@15     mov     al,01
        jmps    @18
@17     mov     al,00
@18     pop     bx
        ret

readdat mov     di,offset(date)
@2a     call    readnum
        cmp     al,1f
        jna     @a
        mov     ah,09
        mov     dx,offset(backerr)
        int     21
        jmps    @2a
@a      stosb
        mov     ah,09
        mov     dx,offset(slash)
        int     21
@2b     call    readnum
        cmp     al,0c
        jna     @8
        mov     ah,09
        mov     dx,offset(backerr)
        int     21
        jmps    @2b
@8      stosb
        mov     ah,09
        mov     dx,offset(slash)
        int     21
        call    readnum
        stosb
        mov     ah,09
        mov     dx,offset(crlf)
        int     21
        ret

;AL=NUMBER
shownum push    ax
        push    bx
        mov     ah,00
        mov     bl,0a
        div     bl
        cmp     al,00
        je      @31
        push    ax
        mov     ah,0e
        add     al,30
        mov     bx,0007
        int     10
        pop     ax
@31     mov     al,ah
        add     al,30
        mov     ah,0e
        mov     bx,0007
        int     10
        pop     bx
        pop     ax
        ret

readnum mov     ah,00
@6      int     16
        cmp     al,30
        jb      @6
        cmp     al,39
        ja      @6
        mov     ah,0e
        mov     bx,0007
        int     10
        sub     al,30
        mov     bl,0a
        mul     bl
        mov     bl,al
        mov     ah,00
@7      int     16
        cmp     al,30
        jb      @7
        cmp     al,39
        ja      @7
        mov     ah,0e
        push    bx
        mov     bx,0007
        int     10
        pop     bx
        sub     al,30
        add     al,bl
        ret

backerr db      07 08 08 '$'
bs      db      08 20 08 '$'
crlf    db      0a 0d '$'
datanam db      'DIARY.DAT' 00
datanf  db      'DIARY.DAT not found' 0a 0d '$'
delete  db      0a 0d 'Delete this entry? $'
askdate db      'Enter date (DD/MM/YY): $'
headtxt db      'Diary - Written by Bert Greevenbosch for Magic Software' 0a 0d
        db      'Public Domain Version' 0a 0d '$'
message db      'Enter message to display on that date: $'
slash   db      '/$'
space   db      ' $'
syntax  db      0a 0d 'Syntax: DIARY [A/D/O/S/!]' 0a 0a 0d 'A = Add' 0a 0d 'D = Delete' 0a 0d 'O = Delete all decayed dates' 0a 0d 'S = Show all dates' 0a 0d '! = Warn' 0a 0d '$'
tempnam db      'DIARY.TMP' 00
unpar   db      'Unknown parameter' 0a 0d '$'
wdel    db      'Enter date to delete from (DD/MM/YY): $'
-
cdate   ds      3
thandle dw      ?
;the record
date    ds      3
tsize   db      ?
txt     ds      100
