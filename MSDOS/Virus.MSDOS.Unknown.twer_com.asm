SEG_A   segment byte public
        assume cs:seg_a,ds:seg_a
        org 100h

MULTIPLEXOR proc far
start:
        jmp BEGIN
MULTIPLEXOR endp

; Subroutine work on the DOS Int2Fh (Multiplexor)
; It stay rezident and calling  Old Int2Fh, if don't call FnBAh.
; Functions (ah=BAh):           ³   Return:
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;        al=0                   ³   al=0ffh, bl=READ_ON
;        al=1                   ³   bl=READ_ON=1
;        al=2                   ³   bl=READ_ON=0
;        al=3                   ³   Calling WRITE; bl=READ_ON=1

ADM     proc
        cmp ah,byte ptr cs:ADM_INT
        je ADM_WORK
            db 0eah
INT2F_JUMP  db 0,0,0b2h,89h
ADM_WORK:
        cmp al,0
        jne ADM_WORK1
        mov al,0ffh
        IRET
ADM_WORK1:
        push dx
        push ax
        mov dl,al
        mov ah,2
        int 21h
        pop ax
        pop dx
        IRET
ADM     endp

ADM_INT   db 93h

REZIDENT:
BEGIN:
                               ; Init interrupt vectors
        mov ax,352fh
        int 21h
        mov word ptr cs:INT2F_JUMP,bx
        mov word ptr cs:INT2F_JUMP+2,es
        mov al,2fh
        mov dx,offset ADM
        mov ah,25h
        int 21h
        mov ah,093h
        mov al,'*'
        int 2fh
        mov dx,offset REZIDENT
        int 27h
SEG_A   ends
        end    start