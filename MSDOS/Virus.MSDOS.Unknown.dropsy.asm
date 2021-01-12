;DROPSY TEXT effect for Nowhere Man's VCL - TASM will assemble as is using
;VCL recommended switches.  When screen is thoroughly dropsie'd, that is all
;letters have fallen to a single line across the bottom of the monitor,
;the routine will exit to DOS and restore the command prompt. I excerpted
;quite a bit of this from some public domain video routines optimized for
;the accursed a86 assembler and reworked the whole magilla until TASM
;wouldn't choke when swallowing the source. It attempts to meet 
;minimum requirements for VCL formatting. Heck, this is a nice routine
;to have at your fingertips; you gotta admit a CASCADE-virus-like effect 
;is always something people wanna see. And it's commented up the 
;kazoo, one of the features I like best about VCL code. Hope you find
;it useful. -URNST KOUCH

code           segment byte public
               assume  cs:code,ds:code,es:code,ss:code
               org     0100h

               jmp  Start

main           proc near

Row            dw   24             ;Rows to do initially

                                   ;First, get current video mode and page.
Start:         mov  cx,0B800h      ;color display, color video mem for page 1
               mov  ah,15          ;Get current video mode
               int  10h
               cmp  al,2           ;Color?
               je   A2             ;Yes
               cmp  al,3           ;Color?
               je   A2             ;Yes
               cmp  al,7           ;Mono?
               je   A1             ;Yes
               int  20h            ;No,quit

                                   ;here if 80 col text mode; put video segment in ds.
A1:            mov  cx,0A300h      ;Set for mono; mono videomem for page 1
A2:            mov  bl,0           ;bx=page offset
               add  cx,bx          ;Video segment
               mov  ds,cx          ;in ds

                                   ;start dropsy effect
               xor  bx,bx          ;Start at top left corner
A3:            push bx             ;Save row start on stack
               mov  bp,80          ;Reset column counter
                                   ;Do next column in a row.
A4:            mov  si,bx          ;Set row top in si
               mov  ax,[si]        ;Get char & attr from screen
               cmp  al,20h         ;Is it a blank?
               je   A7             ;Yes, skip it
               mov  dx,ax          ;No, save it in dx
               mov  al,20h         ;Make it a space
               mov  [si],ax        ;and put on screen
               add  si,160         ;Set for next row
               mov  di,cs:Row      ;Get rows remaining
A5:            mov  ax,[si]        ;Get the char & attr from screen
               mov  [si],dx        ;Put top row char & attr there
A6:            call Vert           ;Wait for 2 vert retraces
               mov  [si],ax        ;Put original char & attr back
                                   ;Do next row, this column.
              add  si,160          ;Next row
              dec  di              ;Done all rows remaining?
              jne  A5              ;No, do next one
              mov  [si-160],dx     ;Put char & attr on line 25 as junk
                                   ;Do next column on this row.
A7:           add  bx,2            ;Next column, same row
              dec  bp              ;Dec column counter; done?
              jne  A4              ;No, do this column
;Do next row.
A8:           pop  bx              ;Get current row start
              add  bx,160          ;Next row
              dec  cs:Row          ;All rows done?
              jne  A3              ;No
A9:           mov  ax,4C00h  
              int  21h             ;Yes, quit to DOS with error code

                                   ;routine to deal with snow on CGA screen.
Vert:         push ax
              push dx
              push cx              ;Save all registers used
              mov  cl,2            ;Wait for 2 vert retraces
              mov  dx,3DAh         ;CRT status port
F1:           in   al,dx           ;Read status
              test al,8            ;Vert retrace went hi?
              je   F1              ;No, wait for it
              dec  cl              ;2nd one?
              je   F3              ;Yes, write during blanking time
F2:           in   al,dx           ;No, get status
              test al,8            ;Vert retrace went low?
              jne  F2              ;No, wait for it
              jmp  F1              ;Yes, wait for next hi
F3:           pop  cx
              pop  dx
              pop  ax              ;Restore registers
              ret                  ;and return
              
              main   endp
              code   ends
              end    main
