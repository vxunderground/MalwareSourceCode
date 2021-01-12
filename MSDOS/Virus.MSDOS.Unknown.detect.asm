cseg    segment para public 'CODE'
        assume  cs:cseg,ds:cseg,es:cseg,ss:cseg
        org     100h

begin:  mov     dx,offset virus_get             ; Set Int F2h Handler
        mov     ax,25F2h
        int     21H
        mov     dx,offset signon                ; Tell Them We're Here
        mov     ah,9
        int     21h
        mov     dx,((offset pgm_len+15)/16)+10h ; Reserve DX Paragraphs Mem
        mov     ax,3100h                        ; TSR Code 0
        int     21h

virus_get       proc    near

        sti
        push    ax                              ; Save Registers
        push    bx
        push    cx
        push    dx
        push    di
        push    si
        push    bp
        push    ds
        push    es
        cmp     dx, 'As'                        ; Virus?
        jne     okay                            ; Nope
        mov     ax,cs
        mov     ds,ax
        mov     dx,offset warning               ; Warn User
        mov     ah,9
        int     21h

check:  mov     ah,1                            ; Read Keyboard
        int     21h
        cmp     al,'C'                          ; User Wants To Continue
        je      cont
        cmp     al,'c'
        je      cont
        cmp     al,'Q'                          ; User Wants To Quit
        je      quit
        cmp     al,'q'
        je      quit
        mov     dx,offset bad                   ; Incorrect Key
        mov     ah,9
        int     21h
        jmp     check

quit:   mov     ah,9                            ; 'Contact Havoc The ...'
        mov     dx,offset ending
        int     21h
        mov     ax,4cffh                        ; Exit Code 255
        int     21h

cont:   mov     dx,offset crlf                  ; Send CR/LF
        mov     ah,9
        int     21h

okay:   pop     es                              ; Restore Registers
        pop     ds
        pop     bp
        pop     si
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        iret                                    ; Interrupt Return

virus_get       endp

signon  db      10,13,'Gunther Virus Detection Handler Installed.'
        db      10,13,'Created by Havoc The Chaos'
        db      10,13,'Copywrite (c) 1992, 1993 by John Burnette'
        db      10,13,'All Rights Reserved.',10,13,'$'
warning db      7,7,7,10,13,'Warning, Interrupt F2h Detected: Gunther Virus is active!'
        db      10,13,'Continue or Quit (C/Q) ? $'
ending  db      10,10,13,'Contact Havoc The Chaos for a cure by sending him the virus!',7,'$'
bad     db      7,7,8,' ',8,'$'
crlf    db      10,13,'$'

pgm_len equ     $-begin

cseg    ends
        end     begin
