; +-------------------------------------------------------------+ ;        
; | Sample hello world program for use with the Magic Assembler | ;
; +-------------------------------------------------------------+ ;
        mov     ah,09
        mov     dx,offset(hello)
        int     21
        mov     ax,4c00
        int     20

hello   db      'Hello, world!$'
