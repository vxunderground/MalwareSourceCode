;This is a disassembly of Thunderbyte's anti-viral partition code.
;An org statement was not used because it appears that all offsets used 
;herein are either relative or absolute, i.e. it just doesn't matter.
;This should be compiled as a binary image file, it *WILL NOT* create 
;an executable file. This code is exactly 512 bytes long and should be 
;implanted into the hard drive at physical sector 1, cylinder 0, head 0
;using the BIOS direct write to disk function. *DO NOT* use DOS write to 
;disk functions or DEBUG because these functions can't access hidden sectors
;and you'll probably just overwrite the disk drive.

;have fun, folks!

code_start:

        cli                     ;no interrupts
        xor     cx, cx
        mov     ss, cx
        mov     sp, 7c00h
        mov     si, sp
        sti
        cld

        mov     es, cx          ;cs already equals 0
        mov     ds, cx

        mov     di, 0600h       ;

        mov     ch, 01          ;cx = 100h
        repz    movsw           ;mov 200h bytes from 0000:7c00h to 0000:0600h
                                ;to make room for boot sector

jump_pt db      0e9h, 00, 8ah   ;this will act like far jmp to first_pt label
                                ;i.e. 0000:061ah, wraps around segment
first_pt:                       ;when execution continues, this will be offset
                                ;061ah here
        mov     si, 06ddh
        call    routine_1
        mov     si, 07eeh
        call    routine_2
        mov     bp, si
        mov     si, 0733h
        jb      second_pt
        
        mov     bx, sp          ;buffer at stack pointer (7c00h?)
        mov     ax, 0201h       ;func 2, 1 sector - possibily boot sector?
        int     13h             ;BIOS read sector

        mov     si, 0725h
second_pt:
        jb      sixth_pt

        mov     si, 745h
        call    routine_1
        call    routine_1
                
        mov     si, 7c40h
        mov     cx, 01c0h
loop_1:
        xchg    ax, bx
        shl     bx, 1
        lodsb                   ;from 0000:7c40h
        add     ax, bx
        mov     ah, bh
        test    ah, ah
        jns     third_pt
        xor     ax, 0a097h
third_pt:
        loop    loop_1

        cmp     ax, 7805h
        jnz     fourth_pt
        mov     si, 0740h
        call    routine_1

        mov     si, 0762h
        call    01cdh
        mov     dx, [si + 0fc9fh]
        cmp     dx, 27eh
        jb      fourth_pt

        mov     si, 740h
        call    routine_1
        mov     si, 774h
        call    routine_1

        les     ax, [004c]
        mov     bx, es
        mov     cl, 04
        shr     ax, cl
        add     ax, bx
        inc     cx
        inc     cx
        shl     dx, cl
        cmp     ax, dx
        jnb     fifth_pt

fourth_pt:
        mov     si, 0787h
        call    routine_1
        int     16h
        mov     si, 783h
        or      al, 20h
        cmp     al, 79h
        jnz     seventh_pt

fifth_pt:
        call    routine_1
        mov     si, bp
        mov     dx, [si]
        jmp     sp              ;control goes to boot sector

sixth_pt:
        call    routine_1
        int     16h

seventh_pt:
        int     18h             ;rom BASIC!

eighth_pt:
        jmp     eighth_pt        ;infinite loop Lock Up!


routine_2:
        lea     di, [si - 30h]
boot_chk:
        cmp     byte ptr [si], 80h      ;looks like check for bootable parttn
        jz      bootable
        sub     si, 10h
        cmp     si, di
        jnb     boot_chk
        ret
bootable:
        mov     dx, [si]
        mov     cx, [si + 2]
return_pt:
        ret

routine_1:
        lodsb
        cbw                             ;convert to word
        test    ax, ax                  ;huh?
        jz      return_pt               ;like ret to original caller      
                        
        mov     ah, 0eh
        xor     bx, bx
        push    si
        int     10h
        pop     si
        jmp     routine_1

code_end:

        msg1    db      13, 10, "Thunderbyte anti-virus partition "
                db      "v6.24 (C) 1993-94 Thunderbyte BV.", 13, 10, 10, 0
        msg2    db      "Disk error!", 13, 10, 00
        msg3    db      "No system!", 13, 10, 00
        msg4    db      "OK!", 13, 10,"Checking ",0
        msg5    db      "bootsector CRC -> ",0
        msg6    db      "available RAM -> ",0
        msg7    db      "INT 13h -> ",0
        msg8    db      "OK!",13, 10, 10, 0
        msg9    db      "Failed!", 13, 10, "System might be infected. Continue? (N/Y)", 07, 0

        misc    db      0, 0, 0, 80h, 01h, 01, 0, 06, 0dh, 0feh, 0f8h
                db      03eh, 0, 0, 0, 06h, 78h, 0dh, 0, 0, 0
                db      10h     dup(0)
                db      10h     dup(0)
                db      0eh     dup(0)

        id_sig  db      55h, 0aah

