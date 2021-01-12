;                  Binary Obsession Cleaner
;                    -   By Ratman   -


data_18e        equ     9CDh                    ;*
data_19e        equ     4F43h                   ;*

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h

irm_kill        proc    far

start:

                mov     ah,9
                mov     dx,offset data_1        ; ('IR Multi-Partite Virus K')
                int     21h                     ; DOS Services  ah=function 09h
                                                ; display char string at ds:dx

;====( Here is the program's self-check routine )==============================;

                cmp     word ptr ds:data_18e,3E8h 
                jne     loc_1                   

;               jmp     short loc_1             ; 'Crack it'

; If you want it 'cracked', exchange the jne loc_1 to "jmp short loc_1" and
; voila!..  Program run like it wasn't modified..  All trivia really, and
; very usuful if one want a trojanized version of this program :). 

                mov     ah,9
                mov     dx,offset data_6        ; ('Scanner fails Self-Check')
                int     21h                     ; DOS Services  ah=function 09h
                                                ; display char string at ds:dx
                int     20h                     ; DOS program terminate

loc_1:
                mov     ax,201h
                mov     bx,offset data_15
                mov     cx,1
                mov     dx,80h
                int     13h                     ; Disk  dl=drive 0  ah=func 02h
                                                ; read sectors to memory es:bx
                                                ; al=#,ch=cyl,cl=sectr,dh=head
                cmp     data_15,3E8h
                jne     loc_2                   ; Jump if not equal
                mov     ah,9
                mov     dx,offset data_2        ; ('Warning!: IR MultiPartit')
                int     21h                     ; DOS Services  ah=function 09h
                                                ; display char string at ds:dx
                mov     ah,0
                int     16h                     ; Keyboard i/o  ah=function 00h
                                                ; get keybd char in al, ah=scan
                cmp     ah,15h
                jne     loc_2                   ; Jump if not equal
                mov     ax,201h
                mov     bx,offset data_15
                mov     cx,2
                mov     dx,80h
                int     13h                     ; Disk  dl=drive 0  ah=func 02h
                                                ; read sectors to memory es:bx
                                                ; al=#,ch=cyl,cl=sectr,dh=head
                mov     ax,301h
                mov     bx,offset data_15
                mov     cx,1
                mov     dx,80h
                int     13h                     ; Disk  dl=drive 0  ah=func 03h
                                                ; write sectors from mem es:bx
                                                ; al=#,ch=cyl,cl=sectr,dh=head
                mov     ah,9
                mov     dx,offset data_4        ; ('Drive C: MBR is now Clea')
                int     21h                     ; DOS Services  ah=function 09h
                                                ; display char string at ds:dx
loc_2:
                mov     ah,9
                mov     dx,offset data_5        ; ('Scanning the files in th')
                int     21h                     ; DOS Services  ah=function 09h
                                                ; display char string at ds:dx
                mov     ah,2Fh
                int     21h                     ; DOS Services  ah=function 2Fh
                                                ; get DTA ptr into es:bx
                mov     ah,4Eh                  
                mov     cx,7
                mov     dx,586h
                int     21h                     ; DOS Services  ah=function 4Eh
                                                ; find 1st filenam match @ds:dx
                jc      loc_4                   ; Jump if carry Set
loc_3:
                call    sub_1
                mov     ah,4Fh
                int     21h                     ; DOS Services  ah=function 4Fh
                                                ; find next filename match
                jnc     loc_3                   ; Jump if carry=0
loc_4:
                jmp     short $+3               ; delay for I/O
                nop
                int     20h                     ; DOS program terminate

irm_kill        endp

sub_1           proc    near
                push    ax
                push    bx
                push    cx
                push    dx
                push    di
                push    si
                push    es
                push    es
                pop     ds
                push    cs
                pop     es
                mov     si,bx
                add     si,1Eh
                mov     di,58Ch
                mov     cx,0Fh
                push    cx
                push    di
                rep     movsb                   
                pop     di
                pop     cx
                xor     al,al                   
                cld                             
                repne   scasb                   
                mov     al,20h                  
                rep     stosb                   
                mov     byte ptr es:[di],24h    ; '$'
                pop     es
                push    cs
                pop     ds
                mov     ah,9
                mov     dx,58Ch
                int     21h                     ; DOS Services  ah=function 09h
                                                ; display char string at ds:dx
                mov     ax,3D02h
                mov     dx,bx
                add     dx,1Eh
                push    es
                pop     ds
                int     21h                     ; DOS Services  ah=function 3Dh
                                                ; open file, al=mode,name@ds:dx
                mov     bx,ax
                mov     ax,4202h
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                int     21h                     ; DOS Services  ah=function 42h
                                                ; move file ptr, bx=file handle
                                                ; al=method, cx,dx=offset
                xor     cx,cx                   ; Zero register
                mov     dx,ax
                sub     dx,1B9h                 ; EOF-441
                mov     ax,4200h
                int     21h                     ; DOS Services  ah=function 42h
                                                ; move file ptr, bx=file handle
                                                ; al=method, cx,dx=offset
                mov     ah,3Fh                  
                mov     cx,1B9h                 ; 441 bytes
                mov     dx,offset data_15
                int     21h                     ; DOS Services  ah=function 3Fh
                                                ; read file, bx=file handle
                                                ; cx=bytes to ds:dx buffer
                cmp     data_15,3E8h
                jne     loc_5                   ; Jump if not equal
                mov     ah,9
                mov     dx,offset data_9        ; ('is infected by IR MultiP')
                int     21h                     ; DOS Services  ah=function 09h
                                                ; display char string at ds:dx
                mov     ah,0
                int     16h                     ; Keyboard i/o  ah=function 00h
                                                ; get keybd char in al, ah=scan
                cmp     ah,15h
                je      loc_7                   ; Jump if equal
                mov     ah,9
                mov     dx,offset data_11       ; (' - No')
                int     21h                     ; DOS Services  ah=function 09h
                                                ; display char string at ds:dx
                jmp     short loc_6
                db      90h
loc_5:
                mov     ah,9
                mov     dx,offset data_8        ; ('is clean...')
                int     21h                     ; DOS Services  ah=function 09h
                                                ; display char string at ds:dx
loc_6:
                mov     ah,3Eh
                int     21h                     ; DOS Services  ah=function 3Eh
                                                ; close file, bx=file handle
                mov     data_15,0
                pop     si
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                retn
loc_7:
                mov     ah,9
                mov     dx,offset data_10       ; (' - Yes')
                int     21h                     ; DOS Services  ah=function 09h
                                                ; display char string at ds:dx
                mov     ax,5700h
                int     21h                     ; DOS Services  ah=function 57h
                                                ; get file date+time, bx=handle
                                                ; returns cx=time, dx=time
                push    cx
                push    dx
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                mov     ax,4200h
                int     21h                     ; DOS Services  ah=function 42h
                                                ; move file ptr, bx=file handle
                                                ; al=method, cx,dx=offset
                mov     ah,40h                  ; '@'
                mov     cx,3                    
                mov     dx,offset data_17
                int     21h                     ; DOS Services  ah=function 40h
                                                ; write file  bx=file handle
                                                ; cx=bytes from ds:dx buffer
                mov     ax,4202h
                xor     cx,cx                   ; Zero register
                xor     dx,dx                   ; Zero register
                int     21h                     ; DOS Services  ah=function 42h
                                                ; move file ptr, bx=file handle
                                                ; al=method, cx,dx=offset
                xor     cx,cx                   ; Zero register
                mov     dx,ax
                sub     dx,1B9h
                mov     ax,4200h
                int     21h                     ; DOS Services  ah=function 42h
                                                ; move file ptr, bx=file handle
                                                ; al=method, cx,dx=offset
                mov     ah,40h                  ; '@'
                mov     cx,0
                mov     dx,offset data_15
                int     21h                     ; DOS Services  ah=function 40h
                                                ; write file  bx=file handle
                                                ; cx=bytes from ds:dx buffer
                pop     dx
                pop     cx
                mov     ax,5701h
                int     21h                     ; DOS Services  ah=function 57h
                                                ; set file date+time, bx=handle
                                                ; cx=time, dx=time
                jmp     short loc_6
sub_1           endp

data_1          db      'IR Multi-Partite Virus Killer by'
                db      ' -+ RatMan +-', 0Ah, 0Dh
copyright       db      '(C) 1994 RatMan - This program i'
                db      's free of charge for all use'
                db      'rs.', 0Ah, 0Dh, 'DISCLAIMER: Thi'
                db      's software is provided "AS IS"  '
                db      'without warranty of any kind,', 0Ah
                db      0Dh, 'either expressed or implied'
                db      ', including but not limmited to '
                db      'the fitness for', 0Ah, 0Dh, 'any'
                db      ' particular purpose. The entire '
                db      'risk as to its quality or perfor'
                db      'mance', 0Ah, 0Dh, 'is assumed by'
                db      ' the user.', 0Ah, 0Dh, 0Ah, 0Dh, '$'
data_2          db      'Warning!: IR MultiPartite Virus '
                db      'found in MBR of Drive C: - Clean'
                db      ' (Y/N)', 0Ah, 0Dh, '          (I'
                db      'f the System was booted from Dri'
                db      've C: you should reboot', 0Ah, 0Dh
                db      '           from a clean floppy b'
                db      'efore trying to clean your syste'
                db      'm.....)', 7, 0Ah, 0Dh, 0Ah, 0Dh, '$'
data_4          db      'Drive C: MBR is now Clean......', 0Ah
                db      0Dh, 0Ah, 0Dh, '$'
data_5          db      'Scanning the files in the Curren'
                db      't Directory.....', 0Ah, 0Dh, 0Ah
                db      0Dh, '$'
data_6          db      'Scanner fails Self-Check.....', 7
                db      0Ah, 0Dh, '$'
data_8          db      'is clean...', 0Dh, 0Ah, '$'
data_9          db      'is infected by IR MultiPartite V'
                db      'irus - Clean ? (Y/N)', 7, '$'
data_10         db      ' - Yes', 0Ah, 0Dh, '$'
data_11         db      ' - No', 0Ah, 0Dh, '$'
                db      0, 0
data_12         db      2Ah
                db       2Eh, 43h, 4Fh, 4Dh, 00h
data_13         db      1
                db      63 dup (1)
data_15         dw      0
                db      0
data_17         db      0
                db      1021 dup (0)

seg_a           ends
                end     start
