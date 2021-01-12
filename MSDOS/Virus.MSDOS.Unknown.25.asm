; Basic little bitty program for people learning about the different modes
; you can stick on your monitor.  This program will put you into 80*50 on a
; VGA monitor, and should be 80*43 on an EGA monitor (I dunno, haven't tested
; it.)  Anyways, I tried to comment it so someone not knowing asm would be 
; able to understand it.
;
; Coded by The Crypt Keeper/Kevin Marcus
; You may feel free to do absolutely anything to this code, so long as it is
; not distributed in a modified state.  (Incorporate it in your programs, I
; don't care.  Just do not change >THIS< program.)
;
; The Programmer's Paradise.  (619)/457-1836 

IDEAL                     ; Ideal Mode in TASM is t0tallie /< rad man.
DOSSEG                    ; Standard Segment shit.
MODEL tiny                ; What model are we in?!
DATASEG                   ; Data Segment starts here, man.
exitcode db 0             ; 'exitcode' be zer0, man.
CODESEG                   ; Code Segment starts here, dude.
  org 100h                ; Where do .COM files start?
Start:
   mov ax,0003h           ; stick 3 into ax.
   int 10h                ; Set up 80*25, text mode.  Clear the screen, too.
   
Exit:
   
   mov ah,4ch            ; Lets ditch.
   mov al,[exitcode]     ; Make al 0.  Why not xor!?  Suck a ____.
   int 21h               ; "Make it so."
   END Start             ; No more program.